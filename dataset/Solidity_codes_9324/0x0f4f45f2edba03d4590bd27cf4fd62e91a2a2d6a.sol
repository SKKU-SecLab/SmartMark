pragma solidity 0.6.3;



contract Book {


    constructor(address user, address admin, uint16 minReqMarg, uint8 closefee,
        int16 fundRateLong, int16 fundRateShort)
        public {
            assetSwap = AssetSwap(admin);
            lp = user;
            lpMinTakeRM = minReqMarg;
            lastBookSettleTime = now;
            bookCloseFee = closefee;
            fundingRates[0] = fundRateShort;
            fundingRates[1] = fundRateLong;
            bookEndTime = now + 1100 days;
        }

    address public lp;
    AssetSwap public assetSwap;
    uint[4] public margin;
    uint public lastBookSettleTime;
    uint public burnFactor = 1 szabo;
    uint public settleNum;
    int public lpSettleDebitAcct;
    uint public bookEndTime;
    int16[2] public fundingRates;
    uint16 public lpMinTakeRM;
    uint8 public bookStatus;
    uint8 public bookCloseFee;
    bytes32[][2] public tempContracts;
    bytes32[] public takerContracts;
    mapping(bytes32 => Subcontract) public subcontracts;

    struct Subcontract {
        address taker;
        uint takerMargin;   /// in wei
        uint requiredMargin;     /// in wei
        uint16 index;
        int16 fundingRate;
        uint8 closeFee;
        uint8 subkStatus;
        uint8 priceDay;
        int8 takerSide; /// 1 if long, -1 if short
    }

    modifier onlyAdmin() {

        require(msg.sender == address(assetSwap));
        _;
    }

    function adjustMinRMBook(uint16 _min)
        external
        onlyAdmin
    {

        lpMinTakeRM = _min;
    }

    function updateFeesBook(uint8 newClose, int16 longRate, int16 shortRate)
        external
        onlyAdmin
    {

        fundingRates[0] = shortRate;
        fundingRates[1] = longRate;
        bookCloseFee = newClose;
    }

    function burnTakerBook(bytes32 subkID, address sender, uint msgval)
        external
        onlyAdmin
        returns (uint)
    {

        Subcontract storage k = subcontracts[subkID];
        require(sender == k.taker, "must by party to his subcontract");
        require(settleNum == 0, "not during settlement process");
        require(k.subkStatus < 5, "can only burn active subcontract");
        uint burnFee = k.requiredMargin / 2;
        require(msgval >= burnFee, "Insufficient burn fee");
        burnFee = subzero(msgval, burnFee);
        if (margin[1] > margin[2]) {
            burnFactor = subzero(burnFactor, 1 szabo * k.requiredMargin / margin[1]);
        } else {
            burnFactor = subzero(burnFactor, 1 szabo * k.requiredMargin / margin[2]);
        }
        k.subkStatus = 5;
        return burnFee;
    }

    function burnLPBook(uint msgval)
        external
        onlyAdmin
        returns (uint)
    {

        require(bookStatus != 2, "can only burn once");
        uint burnFee = margin[3] / 2;
        require(msgval >= burnFee, "Insufficient burn fee");
        burnFee = subzero(msgval, burnFee);
        if (margin[2] > margin[1]) {
            burnFactor = subzero(burnFactor, 1 szabo * margin[3] / margin[2]);
        } else {
            burnFactor = subzero(burnFactor, 1 szabo * margin[3] / margin[1]);
        }
        bookStatus = 2;
        return burnFee;
    }

    function cancelBook(uint lastOracleSettle, bytes32 subkID, address sender, uint8 _endDay)
        external
        payable
        onlyAdmin
    {

        Subcontract storage k = subcontracts[subkID];
        require(lastOracleSettle < lastBookSettleTime, "Cannot do during settle period");
        require(sender == k.taker || sender == lp, "Canceller not LP or taker");
        require(k.subkStatus == 1, "redundant or too new");
        uint feeOracle = 250 * k.requiredMargin / 1e4;
        require(msg.value >= (2 * feeOracle), "Insufficient cancel fee");
        uint feeLP = uint(k.closeFee) * k.requiredMargin / 1e4;
        if (bookEndTime < (now + 28 days)) {
            feeLP = 0;
            feeOracle = 0;
        }
        if (sender == k.taker && _endDay == 5) {
            k.subkStatus = 2;  /// regular taker cancel
        } else if (sender == k.taker) {
            require(k.requiredMargin < subzero(margin[0], margin[3]), "Insuff LP RM for immed cancel");
            feeLP = feeOracle;  /// close fee is now max close fee, overriding initial close fee
            k.subkStatus = 4;  /// immediate taker cancel
            k.priceDay = _endDay;  /// this is the end-day of the subcontract's last week
        } else {
            feeOracle = 2 * feeOracle;
            feeLP = subzero(msg.value, feeOracle); /// this is really a refund to the LP, not a fee
            k.subkStatus = 3;  /// LP cancel
        }
        balanceSend(feeOracle, assetSwap.feeAddress());
        tempContracts[1].push(subkID);  /// sets this up to settle as an expiring subcontract
        margin[0] += feeLP;
        k.takerMargin += subzero(msg.value, feeLP + feeOracle);
    }

    function fundLPBook()
        external
        onlyAdmin
        payable
    {

        margin[0] += msg.value;
    }

    function fundTakerBook(bytes32 subkID)
        external
        onlyAdmin
        payable
    {

        Subcontract storage k = subcontracts[subkID];
        require(k.subkStatus < 2);
        k.takerMargin += msg.value;
    }

    function closeBookBook()
        external
        payable
        onlyAdmin
    { /// pays the close fee on the larger side of her book

        uint feeOracle = 250 * (margin[1] + margin[2] - min(margin[1], margin[2])) / 1e4;
        require(msg.value >= feeOracle, "Insufficient cancel fee");
        uint feeOverpay = msg.value - feeOracle;
        balanceSend(feeOracle, assetSwap.feeAddress());
        if (now > bookEndTime)
            bookStatus = 1;
        else
            bookEndTime = now + 28 days;
        margin[0] += feeOverpay;
    }

    function inactiveOracleBook()
        external
        onlyAdmin
        {

        require(now > (lastBookSettleTime + 10 days));
        bookStatus = 3;
    }

    function inactiveLPBook(bytes32 subkID, address sender, uint _lastOracleSettle)
        external
        onlyAdmin
    {


        require(bookStatus != 3);
        Subcontract storage k = subcontracts[subkID];
        require(k.taker == sender);
        require(_lastOracleSettle > lastBookSettleTime);
        require(subzero(now, _lastOracleSettle) > 48 hours);
        uint lpDefFee = min(margin[0], margin[3] / 2);
        margin[0] = subzero(margin[0], lpDefFee);
        margin[3] = 0;
        bookStatus = 3;
        k.takerMargin += lpDefFee;
    }

    function redeemBook(bytes32 subkid, address sender)
        external
        onlyAdmin
    {

        Subcontract storage k = subcontracts[subkid];
        require(k.subkStatus > 5 || bookStatus == 3);
        uint tMargin = k.takerMargin;
        k.takerMargin = 0;
        uint16 index = k.index;
        bool isDefaulted = (k.subkStatus == 6 && bookStatus == 0);
        uint defPay = k.requiredMargin / 2;
        uint lpPayment;
        address tAddress = k.taker;
        if (sender == lp) {
            lpPayment = tMargin - subzero(tMargin, 2e9);
            tMargin -= lpPayment;
            margin[0] += lpPayment;
        }
        Subcontract storage lastTaker = subcontracts[takerContracts[takerContracts.length - 1]];
        lastTaker.index = index;
        takerContracts[index] = takerContracts[takerContracts.length - 1];
        takerContracts.pop();
        delete subcontracts[subkid];
        if (isDefaulted) {
            tMargin = subzero(tMargin, defPay);
            balanceSend(defPay, assetSwap.feeAddress());
        }
        balanceSend(tMargin, tAddress);

    }

    function settleRolling(int assetRet)
        external
        onlyAdmin
    {

        require(settleNum < 2e4, "done with rolling settle");
        int takerRetTemp;
        int lpTemp;
        uint loopCap = min(settleNum - 1e4 + 250, takerContracts.length);
        for (uint i = (settleNum - 1e4); i < loopCap; i++) {
            Subcontract storage k = subcontracts[takerContracts[i]];
            if (k.subkStatus == 1) {
                takerRetTemp = int(k.takerSide) * assetRet * int(k.requiredMargin) / 1
                szabo - (int(k.fundingRate) * int(k.requiredMargin) / 1e4);
                lpTemp = lpTemp - takerRetTemp;
                if (takerRetTemp < 0) {
                    k.takerMargin = subzero(k.takerMargin, uint(-takerRetTemp));
                } else {
                    k.takerMargin += uint(takerRetTemp) * burnFactor / 1 szabo;
                }
                if (k.takerMargin < k.requiredMargin) {
                    k.subkStatus = 6;
                    if (k.takerSide == 1)
                        margin[2] = subzero(margin[2], k.requiredMargin);
                    else
                        margin[1] = subzero(margin[1], k.requiredMargin);
                }
            }
        }
        settleNum += 250;
        if ((settleNum - 1e4) >= takerContracts.length)
            settleNum = 2e4;
        lpSettleDebitAcct += lpTemp;
    }

    function settleFinal()
        external
        onlyAdmin
    {

        require(settleNum == 3e4, "not done with all the subcontracts");
        if (margin[2] > margin[1])
            margin[3] = margin[2] - margin[1];
        else
            margin[3] = margin[1] - margin[2];
        if (lpSettleDebitAcct < 0)
            margin[0] = subzero(margin[0], uint(-lpSettleDebitAcct));
        else
            margin[0] = margin[0] + uint(lpSettleDebitAcct) * burnFactor / 1 szabo;
        if (bookStatus != 0) {
            bookStatus = 3;
            margin[3] = 0;
        } else if (margin[0] < margin[3]) {
            bookStatus = 3;
            uint defPay = min(margin[0], margin[3] / 2);
            margin[0] = subzero(margin[0], defPay);
            balanceSend(defPay, assetSwap.feeAddress());
            margin[3] = 0;
        }
        lpSettleDebitAcct = 0;
        lastBookSettleTime = now;
        settleNum = 0;
        delete tempContracts[1];
        delete tempContracts[0];
        burnFactor = 1 szabo;
    }

    function takeBook(address taker, uint rM, uint lastOracleSettle, uint8 _priceDay, uint isTakerLong)
        external
        payable
        onlyAdmin
        returns (bytes32 subkID)
    {

        require(bookStatus == 0, "book no longer taking positions");

        require((now + 28 days) < bookEndTime, "book closing soon");
        require(rM >= uint(lpMinTakeRM) * 1 szabo, "must be greater than book min");
        require(lastOracleSettle < lastBookSettleTime, "Cannot do during settle period");
        require(takerContracts.length < 4000, "book is full");
        uint availableMargin = subzero(margin[0] / 2 + margin[2 - isTakerLong], margin[1 + isTakerLong]);
        require(rM <= availableMargin && (margin[0] - margin[3]) > rM);
        require(rM <= availableMargin);
        margin[1 + isTakerLong] += rM;
        Subcontract memory order;
        order.requiredMargin = rM;
        order.takerMargin = msg.value;
        order.taker = taker;
        order.takerSide = int8(2 * isTakerLong - 1);
        margin[3] += rM;
        subkID = keccak256(abi.encodePacked(now, takerContracts.length));
        order.index = uint16(takerContracts.length);
        order.priceDay = _priceDay;
        order.fundingRate = fundingRates[isTakerLong];
        order.closeFee = bookCloseFee;
        subcontracts[subkID] = order;
        takerContracts.push(subkID);
        tempContracts[0].push(subkID);
        return subkID;
    }

    function withdrawLPBook(uint amount, uint lastOracleSettle)
        external
        onlyAdmin
    {

        require(margin[0] >= amount, "Cannot withdraw more than the margin");
        if (bookStatus != 3) {
            require(subzero(margin[0], amount) >= margin[3], "Cannot w/d more than excess margin");
            require(lastOracleSettle < lastBookSettleTime, "Cannot w/d during settle period");
        }
        margin[0] = subzero(margin[0], amount);
        balanceSend(amount, lp);
    }

    function withdrawTakerBook(bytes32 subkID, uint amount, uint lastOracleSettle, address sender)
        external
        onlyAdmin
    {

        require(lastOracleSettle < lastBookSettleTime, "Cannot w/d during settle period");
        Subcontract storage k = subcontracts[subkID];
        require(k.subkStatus < 6, "subk dead, must redeem");
        require(sender == k.taker, "Must be taker to call this function");
        require(subzero(k.takerMargin, amount) >= k.requiredMargin, "cannot w/d more than excess margin");
        k.takerMargin = subzero(k.takerMargin, amount);
        balanceSend(amount, k.taker);
    }

    function getSubkData1Book(bytes32 subkID)
        external
        view
        returns (address takerAddress, uint takerMargin, uint requiredMargin)
    {   Subcontract memory k = subcontracts[subkID];

        takerAddress = k.taker;
        takerMargin = k.takerMargin;
        requiredMargin = k.requiredMargin;
    }

    function getSubkData2Book(bytes32 subkID)
        external
        view
        returns (uint8 kStatus, uint8 priceDay, uint8 closeFee, int16 fundingRate, bool takerSide)
    {   Subcontract memory k = subcontracts[subkID];

        kStatus = k.subkStatus;
        priceDay = k.priceDay;
        closeFee = k.closeFee;
        fundingRate = k.fundingRate;
        if (k.takerSide == 1)
            takerSide = true;
    }

    function getSettleInfoBook()
        external
        view
        returns (uint totalLength, uint expiringLength, uint newLength, uint lastBookSettleUTC, uint settleNumber,
            uint bookBalance, uint bookMaturityUTC)
    {

        totalLength = takerContracts.length;
        expiringLength = tempContracts[1].length;
        newLength = tempContracts[0].length;
        lastBookSettleUTC = lastBookSettleTime;
        settleNumber = settleNum;
        bookMaturityUTC = bookEndTime;
        bookBalance = address(this).balance;
    }

    function settleExpiring(int[5] memory assetRetExp)
        public
        onlyAdmin
        {

        require(bookStatus != 3 && settleNum < 1e4, "done with expiry settle");
        int takerRetTemp;
        int lpTemp;
        uint loopCap = min(settleNum + 200, tempContracts[1].length);
        for (uint i = settleNum; i < loopCap; i++) {
            Subcontract storage k = subcontracts[tempContracts[1][i]];
            takerRetTemp = int(k.takerSide) * assetRetExp[k.priceDay - 1] * int(k.requiredMargin) / 1 szabo -
            (int(k.fundingRate) * int(k.requiredMargin) / 1e4);
            lpTemp -= takerRetTemp;
            if (takerRetTemp < 0) {
                k.takerMargin = subzero(k.takerMargin, uint(-takerRetTemp));
            } else {
                k.takerMargin += uint(takerRetTemp) * burnFactor / 1 szabo;
            }
            if (k.takerSide == 1)
                margin[2] = subzero(margin[2], k.requiredMargin);
            else
                margin[1] = subzero(margin[1], k.requiredMargin);
            k.subkStatus = 7;
        }
        settleNum += 200;
        if (settleNum >= tempContracts[1].length)
            settleNum = 1e4;
        lpSettleDebitAcct += lpTemp;
    }

    function settleNew(int[5] memory assetRets)
        public
        onlyAdmin
    {

        require(settleNum < 3e4, "done with new settle");
        int takerRetTemp;
        int lpTemp;
        uint loopCap = min(settleNum - 2e4 + 200, tempContracts[0].length);
        for (uint i = (settleNum - 2e4); i < loopCap; i++) {
            Subcontract storage k = subcontracts[tempContracts[0][i]];
            k.subkStatus = 1;
            if (k.priceDay != 5) {
                takerRetTemp = int(k.takerSide) * assetRets[k.priceDay] * int(k.requiredMargin) / 1
                szabo - (int(k.fundingRate) * int(k.requiredMargin) / 1e4);
                lpTemp = lpTemp - takerRetTemp;
                if (takerRetTemp < 0) {
                    k.takerMargin = subzero(k.takerMargin, uint(-takerRetTemp));
                } else {
                    k.takerMargin += uint(takerRetTemp) * burnFactor / 1 szabo;
                }
                if (k.takerMargin < k.requiredMargin) {
                    k.subkStatus = 6;
                    if (k.takerSide == 1)
                        margin[2] = subzero(margin[2], k.requiredMargin);
                    else
                        margin[1] = subzero(margin[1], k.requiredMargin);
                }
                k.priceDay = 5;
            }
        }
        settleNum += 200;
        if (settleNum >= tempContracts[0].length)
            settleNum = 3e4;
        lpSettleDebitAcct += lpTemp;
    }

    function balanceSend(uint amount, address recipient)
        internal
    {

        assetSwap.balanceInput.value(amount)(recipient);
    }

    function min(uint a, uint b)
        internal
        pure
        returns (uint)
    {

        if (a <= b)
            return a;
        else
            return b;
    }

    function subzero(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {

        if (_b >= _a)
            return 0;
        else
            return _a - _b;
    }


}
pragma solidity 0.6.3;



contract Oracle {


    constructor (uint ethPrice, uint spxPrice, uint btcPrice) public {
        admins[msg.sender] = true;
        prices[0][5] = ethPrice;
        prices[1][5] = spxPrice;
        prices[2][5] = btcPrice;
        lastUpdateTime = now;
        lastSettleTime = now;
        currentDay = 5;
        levRatio[0] = 250;  // ETH contract 2.5 leverage
        levRatio[1] = 1000; /// SPX contract 10.0 leverage
        levRatio[2] = 250;  // BTC contract 2.5 leverage
    }

    address[3] public assetSwaps;
    uint[6][3] private prices;
    uint public lastUpdateTime;
    uint public lastSettleTime;
    int[3] public levRatio;
    uint8 public currentDay;
    bool public nextUpdateSettle;
    mapping(address => bool) public admins;
    mapping(address => bool) public readers;

    event PriceUpdated(
        uint ethPrice,
        uint spxPrice,
        uint btcPrice,
        uint eUTCTime,
        uint eDayNumber,
        bool eisCorrection
    );

    event AssetSwapContractsChange(
        address ethSwapContract,
        address spxSwapContract,
        address btcSwapContract
    );

    event ChangeReaderStatus(
        address reader,
        bool onOrOff
    );

    modifier onlyAdmin() {

        require(admins[msg.sender]);
        _;
    }

    function addAdmin(address newAdmin)
        external
        onlyAdmin
    {

        admins[newAdmin] = true;
    }

    function removeAdmin(address toRemove)
            external
            onlyAdmin
    {

        require(toRemove != msg.sender);
        admins[toRemove] = false;
    }

    function addReaders(address newReader)
        external
        onlyAdmin
    {

        readers[newReader] = true;
        emit ChangeReaderStatus(newReader, true);
    }

    function removeReaders(address oldReader)
        external
        onlyAdmin
    {

        readers[oldReader] = false;
        emit ChangeReaderStatus(oldReader, false);
    }

    function changeAssetSwaps(address newAS0, address newAS1, address newAS2)
        external
        onlyAdmin
    {

        require(now > lastSettleTime && now < lastSettleTime + 1 days, "only 1 day after settle");
        assetSwaps[0] = newAS0;
        assetSwaps[1] = newAS1;
        assetSwaps[2] = newAS2;
        readers[newAS0] = true;
        readers[newAS1] = true;
        readers[newAS2] = true;
        emit AssetSwapContractsChange(newAS0, newAS1, newAS2);
    }

    function editPrice(uint _ethprice, uint _spxprice, uint _btcprice)
        external
        onlyAdmin
    {

        require(now < lastUpdateTime + 60 minutes);
        prices[0][currentDay] = _ethprice;
        prices[1][currentDay] = _spxprice;
        prices[2][currentDay] = _btcprice;
        emit PriceUpdated(_ethprice, _spxprice, _btcprice, now, currentDay, true);
    }

    function updatePrices(uint ethp, uint spxp, uint btcp, bool _newFinalDay)
        external
        onlyAdmin
    {


        require(now > lastUpdateTime + 20 hours);
        require(!nextUpdateSettle);
        require(now > lastSettleTime + 48 hours, "too soon after last settle");
        require(ethp != prices[0][currentDay] && spxp != prices[1][currentDay] && btcp != prices[2][currentDay]);
        require((ethp * 10 < prices[0][currentDay] * 15) && (ethp * 10 > prices[0][currentDay] * 5));
        require((spxp * 10 < prices[1][currentDay] * 15) && (spxp * 10 > prices[1][currentDay] * 5));
        require((btcp * 10 < prices[2][currentDay] * 15) && (btcp * 10 > prices[2][currentDay] * 5));
        if (currentDay == 5) {
            currentDay = 1;
        } else {
            currentDay += 1;
            nextUpdateSettle = _newFinalDay;
        }
        if (currentDay == 4)
            nextUpdateSettle = true;
        updatePriceSingle(0, ethp);
        updatePriceSingle(1, spxp);
        updatePriceSingle(2, btcp);
        emit PriceUpdated(ethp, spxp, btcp, now, currentDay, false);
        lastUpdateTime = now;
    }

    function settlePrice(uint ethp, uint spxp, uint btcp)
        external
        onlyAdmin
    {

        require(nextUpdateSettle);
        require(now > lastUpdateTime + 20 hours);
        require(ethp != prices[0][currentDay] && spxp != prices[1][currentDay] && btcp != prices[2][currentDay]);
        require((ethp * 10 < prices[0][currentDay] * 15) && (ethp * 10 > prices[0][currentDay] * 5));
        require((spxp * 10 < prices[1][currentDay] * 15) && (spxp * 10 > prices[1][currentDay] * 5));
        require((btcp * 10 < prices[2][currentDay] * 15) && (btcp * 10 > prices[2][currentDay] * 5));
        currentDay = 5;
        nextUpdateSettle = false;
        updatePriceSingle(0, ethp);
        updatePriceSingle(1, spxp);
        updatePriceSingle(2, btcp);
        int[5] memory assetReturnsNew;
        int[5] memory assetReturnsExpiring;
        int cap = 975 * 1 szabo / 1000;
        for (uint j = 0; j < 3; j++) {
            for (uint i = 0; i < 5; i++) {
                if (prices[0][i] != 0) {
                    int assetRetFwd = int(prices[j][5] * 1 szabo / prices[j][i]) - 1 szabo;
                    assetReturnsNew[i] = assetRetFwd * int(prices[0][i]) * levRatio[j] /
                        int(prices[0][5]) / 100;
                    assetReturnsNew[i] = bound(assetReturnsNew[i], cap);
                }
                if (prices[0][i+1] != 0) {
                    int assetRetBack = int(prices[j][i+1] * 1 szabo / prices[j][0]) - 1 szabo;
                    assetReturnsExpiring[i] = assetRetBack * int(prices[0][0]) * levRatio[j] /
                        int(prices[0][i+1]) / 100;

                    assetReturnsExpiring[i] = bound(assetReturnsExpiring[i], cap);
                }
            }
            AssetSwap asw = AssetSwap(assetSwaps[j]);
            asw.updateReturns(assetReturnsNew, assetReturnsExpiring);
        }
        lastSettleTime = now;
        emit PriceUpdated(ethp, spxp, btcp, now, currentDay, false);
        lastUpdateTime = now;
    }

    function getUsdPrices(uint _assetID)
        public
        view
        returns (uint[6] memory _priceHist)
    {

        require(admins[msg.sender] || readers[msg.sender]);
        _priceHist = prices[_assetID];
    }

    function getCurrentPrice(uint _assetID)
        public
        view
        returns (uint _price)
    {

        require(admins[msg.sender] || readers[msg.sender]);
        _price = prices[_assetID][currentDay];
    }

    function getStartDay()
        public
        view
        returns (uint8 _startDay)
    {

        if (nextUpdateSettle) {
            _startDay = 5;
        } else if (currentDay == 5) {
            _startDay = 1;
        } else {
            _startDay = currentDay + 1;
        }
    }

    function updatePriceSingle(uint _assetID, uint _price)
        internal
    {

        if (currentDay == 1) {
            uint[6] memory newPrices;
            newPrices[0] = prices[_assetID][5];
            newPrices[1] = _price;
            prices[_assetID] = newPrices;
        } else {
            prices[_assetID][currentDay] = _price;
        }
    }

    function bound(int a, int b)
        internal
        pure
        returns (int)
    {

        if (a > b)
            a = b;
        if (a < -b)
            a = -b;
        return a;
    }

}
pragma solidity 0.6.3;



contract AssetSwap {


    constructor (address priceOracle, int _levRatio)
        public {
            administrators[msg.sender] = true;
            feeAddress = msg.sender;
            oracle = Oracle(priceOracle);
            levRatio = _levRatio;
        }

    Oracle public oracle;
    int[5][2] public assetReturns; /// these are pushed by the oracle each week
    int public levRatio;
    uint public lastOracleSettleTime; /// updates at time of oracle settlement.
    mapping(address => address) public books;  /// LP eth address to book contract address
    mapping(address => uint) public assetSwapBalance;  /// how ETH is ultimately withdrawn
    mapping(address => bool) public administrators;  /// gives user right to key functions
    address payable public feeAddress;   /// address for oracle fees

    event SubkTracker(
        address indexed eLP,
        address indexed eTaker,
        bytes32 eSubkID,
        bool eisOpen);

    event BurnHist(
        address eLP,
        bytes32 eSubkID,
        address eBurner,
        uint eTime);

    event LPNewBook(
        address indexed eLP,
        address eLPBook);

    event RatesUpdated(
        address indexed eLP,
        uint8 closefee,
        int16 longFundingRate,
        int16 shortFundingRate
        );

    modifier onlyAdmin() {

        require(administrators[msg.sender], "admin only");
        _;
    }

    function removeAdmin(address toRemove)
        external
        onlyAdmin
    {

        require(toRemove != msg.sender, "You may not remove yourself as an admin.");
        administrators[toRemove] = false;
    }

    function addAdmin(address newAdmin)
        external
        onlyAdmin
    {

        administrators[newAdmin] = true;
    }

    function adjustMinRM(uint16 _min)
        external
    {

        require(books[msg.sender] != address(0), "User must have a book");
        require(_min >= 1);
        Book b = Book(books[msg.sender]);
        b.adjustMinRMBook(_min);
    }

    function updateFees(uint newClose, int frLong, int frShort)
        external
    {

        require(books[msg.sender] != address(0), "User must have a book");
        int longRate = frLong * levRatio / 1e2;
        int shortRate = frShort * levRatio / 1e2;
        uint closefee = newClose * uint(levRatio) / 1e2;
        require(closefee <= 250);
        require(longRate <= 250 && longRate >= -250);
        require(shortRate <= 250 && shortRate >= -250);
        Book b = Book(books[msg.sender]);
        b.updateFeesBook(uint8(closefee), int16(longRate), int16(shortRate));
        emit RatesUpdated(msg.sender, uint8(closefee), int16(longRate), int16(shortRate));
    }

    function changeFeeAddress(address payable newAddress)
        external
        onlyAdmin
    {

        feeAddress = newAddress;
    }

    function balanceInput(address recipient)
            external
            payable
    {

        assetSwapBalance[recipient] += msg.value;
    }

    function createBook(uint16 _min, uint _closefee, int frLong, int frShort)
        external
        payable
        returns (address newBook)
    {

        require(books[msg.sender] == address(0), "User must not have a preexisting book");
        require(msg.value >= uint(_min) * 10 szabo, "Must prep for book");
        require(_min >= 1);
        int16 longRate = int16(frLong * levRatio / 1e2);
        int16 shortRate = int16(frShort * levRatio / 1e2);
        uint8 closefee = uint8(_closefee * uint(levRatio) / 1e2);
        require(longRate <= 250 && longRate >= -250);
        require(shortRate <= 250 && shortRate >= -250);
        require(closefee <= 250);
        books[msg.sender] = address(new Book(msg.sender, address(this), _min, closefee, longRate, shortRate));
        Book b = Book(books[msg.sender]);
        b.fundLPBook.value(msg.value)();
        emit LPNewBook(msg.sender, books[msg.sender]);
        return books[msg.sender];
    }

    function fundLP(address _lp)
        external
        payable
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.fundLPBook.value(msg.value)();
    }

    function fundTaker(address _lp, bytes32 subkID)
        external
        payable
        {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.fundTakerBook.value(msg.value)(subkID);
    }

    function burnTaker(address _lp, bytes32 subkID)
        external
        payable
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        uint refund = b.burnTakerBook(subkID, msg.sender, msg.value);
        emit BurnHist(_lp, subkID, msg.sender, now);
        assetSwapBalance[msg.sender] += refund;
    }

    function burnLP()
        external
        payable
    {

        require(books[msg.sender] != address(0));
        Book b = Book(books[msg.sender]);
        uint refund = b.burnLPBook(msg.value);
        bytes32 abcnull;
        emit BurnHist(msg.sender, abcnull, msg.sender, now);
        assetSwapBalance[msg.sender] += refund;
    }

    function cancel(address _lp, bytes32 subkID, bool closeNow)
        external
        payable
    {

        require(hourOfDay() != 16, "Cannot cancel during 4 PM ET hour");
        Book b = Book(books[_lp]);
        uint8 priceDay = oracle.getStartDay();
        uint8 endDay = 5;
        if (closeNow)
            endDay = priceDay;
        b.cancelBook.value(msg.value)(lastOracleSettleTime, subkID, msg.sender, endDay);
    }

    function closeBook(address _lp)
        external
        payable
    {

        require(msg.sender == _lp);
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.closeBookBook.value(msg.value)();
    }

    function redeem(address _lp, bytes32 subkID)
        external
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.redeemBook(subkID, msg.sender);
        emit SubkTracker(_lp, msg.sender, subkID, false);
    }

    function settleParts(address _lp)
        external
        returns (bool isComplete)
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        uint lastBookSettleTime = b.lastBookSettleTime();
        require(now > (lastOracleSettleTime + 24 hours));
        require(lastOracleSettleTime > lastBookSettleTime, "one settle per week");
        uint settleNumb = b.settleNum();
        if (settleNumb < 1e4) {
            b.settleExpiring(assetReturns[1]);
        } else if (settleNumb < 2e4) {
            b.settleRolling(assetReturns[0][0]);
        } else if (settleNumb < 3e4) {
            b.settleNew(assetReturns[0]);
        } else if (settleNumb == 3e4) {
            b.settleFinal();
            isComplete = true;
        }
    }

    function settleBatch(address _lp)
        external
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        uint lastBookSettleTime = b.lastBookSettleTime();
        require(now > (lastOracleSettleTime + 24 hours));
        require(lastOracleSettleTime > lastBookSettleTime, "one settle per week");
        b.settleExpiring(assetReturns[1]);
        b.settleRolling(assetReturns[0][0]);
        b.settleNew(assetReturns[0]);
        b.settleFinal();
    }

    function take(address _lp, uint rm, bool isTakerLong)
        external
        payable
        returns (bytes32 newsubkID)
    {

        require(rm < 3, "above max size"); // This is to make this contract economically trivial
        rm = rm * 1 szabo;
        require(msg.value >= 3 * rm / 2, "Insuffient ETH for your RM");
        require(hourOfDay() != 16, "Cannot take during 4 PM ET hour");

        uint takerLong;
        if (isTakerLong)
            takerLong = 1;
        else
            takerLong = 0;
        uint8 priceDay = oracle.getStartDay();
        Book book = Book(books[_lp]);
        newsubkID = book.takeBook.value(msg.value)(msg.sender, rm, lastOracleSettleTime, priceDay, takerLong);
        emit SubkTracker(_lp, msg.sender, newsubkID, true);
    }

    function withdrawLP(uint amount)
        external
    {

        require(amount > 0);
        require(books[msg.sender] != address(0));
        Book b = Book(books[msg.sender]);
        amount = 1e9 * amount;
        b.withdrawLPBook(amount, lastOracleSettleTime);
    }

    function withdrawTaker(uint amount, address _lp, bytes32 subkID)
        external
    {

        require(amount > 0);
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        amount = 1e9 * amount;
        b.withdrawTakerBook(subkID, amount, lastOracleSettleTime, msg.sender);
    }

    function withdrawFromAssetSwap()
        external
    {

        uint amount = assetSwapBalance[msg.sender];
        require(amount > 0);
        assetSwapBalance[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function inactiveOracle(address _lp)
        external
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.inactiveOracleBook();
    }

    function inactiveLP(address _lp, bytes32 subkID)
        external
    {

        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.inactiveLPBook(subkID, msg.sender, lastOracleSettleTime);
    }

    function getBookData(address _lp)
        external
        view
        returns (address book,
            uint lpMargin,
            uint totalLpLong,
            uint totalLpShort,
            uint lpRM,
            uint bookMinimum,
            int16 longFundingRate,
            int16 shortFundingRate,
            uint8 lpCloseFee,
            uint8 bookStatus
            )
    {

        book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            lpMargin = b.margin(0);
            totalLpLong = b.margin(1);
            totalLpShort = b.margin(2);
            lpRM = b.margin(3);
            bookMinimum = b.lpMinTakeRM();
            longFundingRate = b.fundingRates(1);
            shortFundingRate = b.fundingRates(0);
            lpCloseFee = b.bookCloseFee();
            bookStatus = b.bookStatus();
        }
    }

    function getSubkData1(address _lp, bytes32 subkID)
        external
        view
        returns (
            address taker,
            uint takerMargin,
            uint reqMargin
            )
    {

        address book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (taker, takerMargin, reqMargin) = b.getSubkData1Book(subkID);
        }
    }

    function getSubkData2(address _lp, bytes32 subkID)
        external
        view
        returns (
            uint8 subkStatus,
            uint8 priceDay,
            uint8 closeFee,
            int16 fundingRate,
            bool takerSide
            )
    {

        address book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (subkStatus, priceDay, closeFee, fundingRate, takerSide)
                = b.getSubkData2Book(subkID);
        }
    }

    function getSettleInfo(address _lp)
        external
        view
        returns (
            uint totalLength,
            uint expiringLength,
            uint newLength,
            uint lastBookSettleUTC,
            uint settleNumber,
            uint bookBalance,
            uint bookMaturityUTC
            )
    {

        address book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (totalLength, expiringLength, newLength, lastBookSettleUTC, settleNumber,
                bookBalance, bookMaturityUTC) = b.getSettleInfoBook();
        }
    }

    function updateReturns(int[5] memory assetRetNew, int[5] memory assetRetExp)
            public
        {

        require(msg.sender == address(oracle));
        assetReturns[0] = assetRetNew;
        assetReturns[1] = assetRetExp;
        lastOracleSettleTime = now;
    }

    function hourOfDay()
        public
        view
        returns(uint hour1)
    {

        uint nowTemp = now;
        hour1 = (nowTemp % 86400) / 3600 - 5;
        if ((nowTemp > 1583668800 && nowTemp < 1604232000) || (nowTemp > 1615705200 && nowTemp < 1636264800) ||
            (nowTemp > 1647154800 && nowTemp < 1667714400))
            hour1 = hour1 + 1;
    }

    function subzero(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {

        if (_b >= _a) {
            return 0;
        }
        return _a - _b;
    }


}
pragma solidity 0.6.3;



contract ManagedAccount {


    constructor(address payable _manager, uint _fee) public {
        manager = _manager;
        investor[msg.sender] = true;
        lastUpdateTime = now;
        managerStatus = true;
        mgmtFee = _fee;
    }

    address payable public manager;
    mapping(address => bool) public approvedSwaps;
    mapping(address => bool) public investor;
    mapping(bytes32 => Takercontract) public takercontracts;
    bytes32[] public ourTakerContracts;
    address[] public ourSwaps;
    uint public lastUpdateTime;
    uint public managerBalance;
    uint public totAUMlag;
    bool public managerStatus;
    uint public mgmtFee;

    event AddedFunds(uint amount, address payor);
    event RemovedFunds(uint amount, address payee);

    struct Takercontract {
        address swapAddress;
        address lp;
        uint index;
    }

    modifier onlyInvestor() {

        require(investor[msg.sender]);
        _;
    }

    modifier onlyManager() {

        require(msg.sender == manager);
        _;
    }

    modifier onlyApproved() {

        if (managerStatus)
            require(msg.sender == manager || investor[msg.sender]);
        else
            require(investor[msg.sender]);
        _;
    }

    receive ()
        external
        payable
    { emit AddedFunds(msg.value, msg.sender);
    }

    function changeManager(address payable _manager)
        external
        onlyInvestor
    {

        updateFee();
        uint manBal = managerBalance;
        managerBalance = 0;
        emit RemovedFunds(manBal, manager);
        manager.transfer(manBal);
        manager = _manager;
    }

    function addInvestor(address payable newInvestor)
        external
        onlyInvestor
    {

        investor[newInvestor] = true;
    }

    function removeInvestor(address payable oldInvestor)
        external
        onlyInvestor
    {

      require(oldInvestor != msg.sender);
      investor[oldInvestor] = false;
    }

    function disableManager(bool _managerStatus)
        external
        onlyInvestor
    {

        if (managerStatus && !_managerStatus)
            generateFee(totAUMlag);
        managerStatus = _managerStatus;
    }

    function adjFee(uint newFee)
        external
        onlyInvestor
    {

        mgmtFee = newFee;
    }

    function addSwap(address swap)
        external
        onlyInvestor
    {

        require(approvedSwaps[swap] == false);
        approvedSwaps[swap] = true;
        ourSwaps.push(swap);
    }

    function createBook(uint amount, address swap, uint16 min, uint closefee, int fundingLong, int fundingShort)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        amount = amount * 1 szabo;
        require(amount <= address(this).balance);
        AssetSwap s = AssetSwap(swap);
        s.createBook.value(amount)(min, closefee, fundingLong, fundingShort);
    }

    function fundBookMargin(uint amount, address swap)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        amount = amount * 1 szabo;
        uint totAUM = totAUMlag + amount;
        generateFee(totAUM);
        require(amount < address(this).balance);
        AssetSwap s = AssetSwap(swap);
        s.fundLP.value(amount)(address(this));
    }

    function fundTakerMargin(uint amount, address swap, address lp, bytes32 subkid)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        amount = amount * 1 szabo;
        uint totAUM = totAUMlag + amount;
        generateFee(totAUM);
        require(amount < address(this).balance);
        AssetSwap s = AssetSwap(swap);
        s.fundTaker.value(amount)(lp, subkid);
    }

    function takeFromLP(uint amount, address swap, address lp, uint16 rM, bool takerLong)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        amount = 1 szabo * amount;
        require(amount < address(this).balance);
        uint totAUM = totAUMlag + amount;
        generateFee(totAUM);
        bytes32 subkid = s.take.value(amount)(lp, rM, takerLong);
        Takercontract memory t;
        t.swapAddress = swap;
        t.lp = lp;
        t.index = ourTakerContracts.length;
        takercontracts[subkid] = t;
        ourTakerContracts.push(subkid);

    }

    function cancelSubcontract(address swap, address lp, bytes32 id)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        (, , uint rm) = s.getSubkData1(lp, id);
        uint amount = 5 * rm / 100;
        require(amount < address(this).balance);
        s.cancel.value(amount)(lp, id, false);
    }

    function fund()
        external
        payable
        onlyApproved
    {

        emit AddedFunds(msg.value, msg.sender);
    }

    function activateEndBook(address swap)
        external
        payable
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.closeBook.value(msg.value)(address(this));
    }

    function adjMinReqMarg(uint16 amount, address swap)
        external
        onlyInvestor
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.adjustMinRM(amount);
    }

    function setFees(address swap, uint close, int longFR, int shortFR)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.updateFees(close, longFR, shortFR);
    }

    function investorWithdraw(uint amount)
        external
        onlyInvestor
    {

        require(subzero(address(this).balance, amount) > managerBalance);
        emit RemovedFunds(amount, msg.sender);
        msg.sender.transfer(amount);
    }

    function managerWithdraw()
        external
        onlyManager
    {

        uint manBal = managerBalance;
        managerBalance = 0;
        emit RemovedFunds(manBal, manager);
        msg.sender.transfer(manBal);
    }

    function withdrawLPToAS(address swap, uint16 amount)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.withdrawLP(amount);
    }

    function withdrawTakerToAS(address swap, uint16 amount, address lp, bytes2 subkid)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.withdrawTaker(amount, lp, subkid);
    }

    function withdrawFromAS(address swap)
        external
        onlyApproved
    {

        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.withdrawFromAssetSwap();
    }

    function seeAUM()
        external
        view
        returns (uint totTakerBalance, uint totLPBalance, uint thisAccountBalance, uint _managerBalance)
    {

        totLPBalance = 0;
        uint lpMargin = 0;
        for (uint i = 0; i < ourSwaps.length; i++) {
            address ourswap = ourSwaps[i];
            AssetSwap s = AssetSwap(ourswap);
            (, lpMargin, , , , , , , , ) = s.getBookData(address(this));
            totLPBalance += lpMargin;
        }
        totTakerBalance = 0;
        uint takerMargin = 0;
        for (uint i = 0; i < ourTakerContracts.length; i++) {
            Takercontract storage k = takercontracts[ourTakerContracts[i]];
            AssetSwap s = AssetSwap(k.swapAddress);
            (, takerMargin, ) = s.getSubkData1(k.lp, ourTakerContracts[i]);
            totTakerBalance += takerMargin;
        }
        thisAccountBalance = address(this).balance;
        _managerBalance = managerBalance;
    }

    function updateFee()
        public
        onlyApproved
        {

        uint totAUM = 0;
        uint lpMargin;
        for (uint i = 0; i < ourSwaps.length; i++) {
            AssetSwap s = AssetSwap(ourSwaps[i]);
            (, lpMargin, , , , , , , , ) = s.getBookData(address(this));
            totAUM += lpMargin;
        }
        uint takerMargin = 0;
        for (uint i = 0; i < ourTakerContracts.length; i++) {
            Takercontract storage k = takercontracts[ourTakerContracts[i]];
            AssetSwap s = AssetSwap(k.swapAddress);
            (, takerMargin, ) = s.getSubkData1(k.lp, ourTakerContracts[i]);
            totAUM += takerMargin;
        }
        generateFee(totAUM);
    }

    function generateFee(uint newAUM)
    internal
    {

        uint mgmtAccrual = (now - lastUpdateTime) * totAUMlag * mgmtFee / 10000 / 365 / 86400;
        lastUpdateTime = now;
        totAUMlag = newAUM;
        managerBalance += mgmtAccrual;
    }

    function subzero(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {

        if (_b >= _a) {
            return 0;
        }
        return _a - _b;
    }


}
