
pragma solidity 0.4.18;


interface ERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint remaining);

    function decimals() public view returns(uint digits);

    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


interface ConversionRatesInterface {


    function recordImbalance(
        ERC20 token,
        int buyAmount,
        uint rateUpdateBlock,
        uint currentBlock
    )
        public;


    function getRate(ERC20 token, uint currentBlockNumber, bool buy, uint qty) public view returns(uint);

}


contract Utils {


    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal PRECISION = (10**18);
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint  constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;
    mapping(address=>uint) internal decimals;

    function setDecimals(ERC20 token) internal {

        if (token == ETH_TOKEN_ADDRESS) decimals[token] = ETH_DECIMALS;
        else decimals[token] = token.decimals();
    }

    function getDecimals(ERC20 token) internal view returns(uint) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint tokenDecimals = decimals[token];
        if(tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {

        require(srcQty <= MAX_QTY);
        require(rate <= MAX_RATE);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {

        require(dstQty <= MAX_QTY);
        require(rate <= MAX_RATE);
        
        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }
}



contract PermissionGroups {


    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) internal operators;
    mapping(address=>bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;

    function PermissionGroups() public {

        admin = msg.sender;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {

        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {

        require(alerters[msg.sender]);
        _;
    }

    function getOperators () external view returns(address[]) {
        return operatorsGroup;
    }

    function getAlerters () external view returns(address[]) {
        return alertersGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    function transferAdmin(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0));
        TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0));
        TransferAdminPending(newAdmin);
        AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    function claimAdmin() public {

        require(pendingAdmin == msg.sender);
        AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {

        require(!alerters[newAlerter]); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE);

        AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;

        for (uint i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length--;
                AlerterAdded(alerter, false);
                break;
            }
        }
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {

        require(!operators[newOperator]); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE);

        OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;

        for (uint i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                OperatorAdded(operator, false);
                break;
            }
        }
    }
}


contract Withdrawable is PermissionGroups {


    event TokenWithdraw(ERC20 token, uint amount, address sendTo);

    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {

        require(token.transfer(sendTo, amount));
        TokenWithdraw(token, amount, sendTo);
    }

    event EtherWithdraw(uint amount, address sendTo);

    function withdrawEther(uint amount, address sendTo) external onlyAdmin {

        sendTo.transfer(amount);
        EtherWithdraw(amount, sendTo);
    }
}


contract VolumeImbalanceRecorder is Withdrawable {


    uint constant internal SLIDING_WINDOW_SIZE = 5;
    uint constant internal POW_2_64 = 2 ** 64;

    struct TokenControlInfo {
        uint minimalRecordResolution; // can be roughly 1 cent
        uint maxPerBlockImbalance; // in twei resolution
        uint maxTotalImbalance; // max total imbalance (between rate updates)
    }

    mapping(address => TokenControlInfo) internal tokenControlInfo;

    struct TokenImbalanceData {
        int  lastBlockBuyUnitsImbalance;
        uint lastBlock;

        int  totalBuyUnitsImbalance;
        uint lastRateUpdateBlock;
    }

    mapping(address => mapping(uint=>uint)) public tokenImbalanceData;

    function VolumeImbalanceRecorder(address _admin) public {

        require(_admin != address(0));
        admin = _admin;
    }

    function setTokenControlInfo(
        ERC20 token,
        uint minimalRecordResolution,
        uint maxPerBlockImbalance,
        uint maxTotalImbalance
    )
        public
        onlyAdmin
    {

        tokenControlInfo[token] =
            TokenControlInfo(
                minimalRecordResolution,
                maxPerBlockImbalance,
                maxTotalImbalance
            );
    }

    function getTokenControlInfo(ERC20 token) public view returns(uint, uint, uint) {

        return (tokenControlInfo[token].minimalRecordResolution,
                tokenControlInfo[token].maxPerBlockImbalance,
                tokenControlInfo[token].maxTotalImbalance);
    }

    function addImbalance(
        ERC20 token,
        int buyAmount,
        uint rateUpdateBlock,
        uint currentBlock
    )
        internal
    {

        uint currentBlockIndex = currentBlock % SLIDING_WINDOW_SIZE;
        int recordedBuyAmount = int(buyAmount / int(tokenControlInfo[token].minimalRecordResolution));

        int prevImbalance = 0;

        TokenImbalanceData memory currentBlockData =
            decodeTokenImbalanceData(tokenImbalanceData[token][currentBlockIndex]);

        if (currentBlockData.lastBlock == currentBlock) {
            if (uint(currentBlockData.lastRateUpdateBlock) == rateUpdateBlock) {
                currentBlockData.lastBlockBuyUnitsImbalance += recordedBuyAmount;
                currentBlockData.totalBuyUnitsImbalance += recordedBuyAmount;
            } else {
                prevImbalance = getImbalanceInRange(token, rateUpdateBlock, currentBlock);
                currentBlockData.totalBuyUnitsImbalance = int(prevImbalance) + recordedBuyAmount;
                currentBlockData.lastBlockBuyUnitsImbalance += recordedBuyAmount;
                currentBlockData.lastRateUpdateBlock = uint(rateUpdateBlock);
            }
        } else {
            int currentBlockImbalance;
            (prevImbalance, currentBlockImbalance) = getImbalanceSinceRateUpdate(token, rateUpdateBlock, currentBlock);

            currentBlockData.lastBlockBuyUnitsImbalance = recordedBuyAmount;
            currentBlockData.lastBlock = uint(currentBlock);
            currentBlockData.lastRateUpdateBlock = uint(rateUpdateBlock);
            currentBlockData.totalBuyUnitsImbalance = int(prevImbalance) + recordedBuyAmount;
        }

        tokenImbalanceData[token][currentBlockIndex] = encodeTokenImbalanceData(currentBlockData);
    }

    function setGarbageToVolumeRecorder(ERC20 token) internal {

        for (uint i = 0; i < SLIDING_WINDOW_SIZE; i++) {
            tokenImbalanceData[token][i] = 0x1;
        }
    }

    function getImbalanceInRange(ERC20 token, uint startBlock, uint endBlock) internal view returns(int buyImbalance) {

        require(startBlock <= endBlock);

        buyImbalance = 0;

        for (uint windowInd = 0; windowInd < SLIDING_WINDOW_SIZE; windowInd++) {
            TokenImbalanceData memory perBlockData = decodeTokenImbalanceData(tokenImbalanceData[token][windowInd]);

            if (perBlockData.lastBlock <= endBlock && perBlockData.lastBlock >= startBlock) {
                buyImbalance += int(perBlockData.lastBlockBuyUnitsImbalance);
            }
        }
    }

    function getImbalanceSinceRateUpdate(ERC20 token, uint rateUpdateBlock, uint currentBlock)
        internal view
        returns(int buyImbalance, int currentBlockImbalance)
    {

        buyImbalance = 0;
        currentBlockImbalance = 0;
        uint latestBlock = 0;
        int imbalanceInRange = 0;
        uint startBlock = rateUpdateBlock;
        uint endBlock = currentBlock;

        for (uint windowInd = 0; windowInd < SLIDING_WINDOW_SIZE; windowInd++) {
            TokenImbalanceData memory perBlockData = decodeTokenImbalanceData(tokenImbalanceData[token][windowInd]);

            if (perBlockData.lastBlock <= endBlock && perBlockData.lastBlock >= startBlock) {
                imbalanceInRange += perBlockData.lastBlockBuyUnitsImbalance;
            }

            if (perBlockData.lastRateUpdateBlock != rateUpdateBlock) continue;
            if (perBlockData.lastBlock < latestBlock) continue;

            latestBlock = perBlockData.lastBlock;
            buyImbalance = perBlockData.totalBuyUnitsImbalance;
            if (uint(perBlockData.lastBlock) == currentBlock) {
                currentBlockImbalance = perBlockData.lastBlockBuyUnitsImbalance;
            }
        }

        if (buyImbalance == 0) {
            buyImbalance = imbalanceInRange;
        }
    }

    function getImbalance(ERC20 token, uint rateUpdateBlock, uint currentBlock)
        internal view
        returns(int totalImbalance, int currentBlockImbalance)
    {


        int resolution = int(tokenControlInfo[token].minimalRecordResolution);

        (totalImbalance, currentBlockImbalance) =
            getImbalanceSinceRateUpdate(
                token,
                rateUpdateBlock,
                currentBlock);

        totalImbalance *= resolution;
        currentBlockImbalance *= resolution;
    }

    function getMaxPerBlockImbalance(ERC20 token) internal view returns(uint) {

        return tokenControlInfo[token].maxPerBlockImbalance;
    }

    function getMaxTotalImbalance(ERC20 token) internal view returns(uint) {

        return tokenControlInfo[token].maxTotalImbalance;
    }

    function encodeTokenImbalanceData(TokenImbalanceData data) internal pure returns(uint) {

        require(data.lastBlockBuyUnitsImbalance < int(POW_2_64 / 2));
        require(data.lastBlockBuyUnitsImbalance > int(-1 * int(POW_2_64) / 2));
        require(data.lastBlock < POW_2_64);
        require(data.totalBuyUnitsImbalance < int(POW_2_64 / 2));
        require(data.totalBuyUnitsImbalance > int(-1 * int(POW_2_64) / 2));
        require(data.lastRateUpdateBlock < POW_2_64);

        uint result = uint(data.lastBlockBuyUnitsImbalance) & (POW_2_64 - 1);
        result |= data.lastBlock * POW_2_64;
        result |= (uint(data.totalBuyUnitsImbalance) & (POW_2_64 - 1)) * POW_2_64 * POW_2_64;
        result |= data.lastRateUpdateBlock * POW_2_64 * POW_2_64 * POW_2_64;

        return result;
    }

    function decodeTokenImbalanceData(uint input) internal pure returns(TokenImbalanceData) {

        TokenImbalanceData memory data;

        data.lastBlockBuyUnitsImbalance = int(int64(input & (POW_2_64 - 1)));
        data.lastBlock = uint(uint64((input / POW_2_64) & (POW_2_64 - 1)));
        data.totalBuyUnitsImbalance = int(int64((input / (POW_2_64 * POW_2_64)) & (POW_2_64 - 1)));
        data.lastRateUpdateBlock = uint(uint64((input / (POW_2_64 * POW_2_64 * POW_2_64))));

        return data;
    }
}

contract ConversionRates is ConversionRatesInterface, VolumeImbalanceRecorder, Utils {


    struct StepFunction {
        int[] x; // quantity for each step. Quantity of each step includes previous steps.
        int[] y; // rate change per quantity step  in bps.
    }

    struct TokenData {
        bool listed;  // was added to reserve
        bool enabled; // whether trade is enabled

        uint compactDataArrayIndex;
        uint compactDataFieldIndex;

        uint baseBuyRate;  // in PRECISION units. see KyberConstants
        uint baseSellRate; // PRECISION units. without (sell / buy) spread it is 1 / baseBuyRate
        StepFunction buyRateQtyStepFunction; // in bps. higher quantity - bigger the rate.
        StepFunction sellRateQtyStepFunction;// in bps. higher the qua
        StepFunction buyRateImbalanceStepFunction; // in BPS. higher reserve imbalance - bigger the rate.
        StepFunction sellRateImbalanceStepFunction;
    }

    uint public validRateDurationInBlocks = 10; // rates are valid for this amount of blocks
    ERC20[] internal listedTokens;
    mapping(address=>TokenData) internal tokenData;
    bytes32[] internal tokenRatesCompactData;
    uint public numTokensInCurrentCompactData = 0;
    address public reserveContract;
    uint constant internal NUM_TOKENS_IN_COMPACT_DATA = 14;
    uint constant internal BYTES_14_OFFSET = (2 ** (8 * NUM_TOKENS_IN_COMPACT_DATA));
    uint constant internal MAX_STEPS_IN_FUNCTION = 10;
    int  constant internal MAX_BPS_ADJUSTMENT = 10 ** 11; // 1B %
    int  constant internal MIN_BPS_ADJUSTMENT = -100 * 100; // cannot go down by more than 100%

    function ConversionRates(address _admin) public VolumeImbalanceRecorder(_admin)
        { } // solhint-disable-line no-empty-blocks


    function addToken(ERC20 token) public onlyAdmin {


        require(!tokenData[token].listed);
        tokenData[token].listed = true;
        listedTokens.push(token);

        if (numTokensInCurrentCompactData == 0) {
            tokenRatesCompactData.length++; // add new structure
        }

        tokenData[token].compactDataArrayIndex = tokenRatesCompactData.length - 1;
        tokenData[token].compactDataFieldIndex = numTokensInCurrentCompactData;

        numTokensInCurrentCompactData = (numTokensInCurrentCompactData + 1) % NUM_TOKENS_IN_COMPACT_DATA;

        setGarbageToVolumeRecorder(token);

        setDecimals(token);
    }

    function setCompactData(bytes14[] buy, bytes14[] sell, uint blockNumber, uint[] indices) public onlyOperator {


        require(buy.length == sell.length);
        require(indices.length == buy.length);
        require(blockNumber <= 0xFFFFFFFF);

        uint bytes14Offset = BYTES_14_OFFSET;

        for (uint i = 0; i < indices.length; i++) {
            require(indices[i] < tokenRatesCompactData.length);
            uint data = uint(buy[i]) | uint(sell[i]) * bytes14Offset | (blockNumber * (bytes14Offset * bytes14Offset));
            tokenRatesCompactData[indices[i]] = bytes32(data);
        }
    }

    function setBaseRate(
        ERC20[] tokens,
        uint[] baseBuy,
        uint[] baseSell,
        bytes14[] buy,
        bytes14[] sell,
        uint blockNumber,
        uint[] indices
    )
        public
        onlyOperator
    {

        require(tokens.length == baseBuy.length);
        require(tokens.length == baseSell.length);
        require(sell.length == buy.length);
        require(sell.length == indices.length);

        for (uint ind = 0; ind < tokens.length; ind++) {
            require(tokenData[tokens[ind]].listed);
            tokenData[tokens[ind]].baseBuyRate = baseBuy[ind];
            tokenData[tokens[ind]].baseSellRate = baseSell[ind];
        }

        setCompactData(buy, sell, blockNumber, indices);
    }

    function setQtyStepFunction(
        ERC20 token,
        int[] xBuy,
        int[] yBuy,
        int[] xSell,
        int[] ySell
    )
        public
        onlyOperator
    {

        require(xBuy.length == yBuy.length);
        require(xSell.length == ySell.length);
        require(xBuy.length <= MAX_STEPS_IN_FUNCTION);
        require(xSell.length <= MAX_STEPS_IN_FUNCTION);
        require(tokenData[token].listed);

        tokenData[token].buyRateQtyStepFunction = StepFunction(xBuy, yBuy);
        tokenData[token].sellRateQtyStepFunction = StepFunction(xSell, ySell);
    }

    function setImbalanceStepFunction(
        ERC20 token,
        int[] xBuy,
        int[] yBuy,
        int[] xSell,
        int[] ySell
    )
        public
        onlyOperator
    {

        require(xBuy.length == yBuy.length);
        require(xSell.length == ySell.length);
        require(xBuy.length <= MAX_STEPS_IN_FUNCTION);
        require(xSell.length <= MAX_STEPS_IN_FUNCTION);
        require(tokenData[token].listed);

        tokenData[token].buyRateImbalanceStepFunction = StepFunction(xBuy, yBuy);
        tokenData[token].sellRateImbalanceStepFunction = StepFunction(xSell, ySell);
    }

    function setValidRateDurationInBlocks(uint duration) public onlyAdmin {

        validRateDurationInBlocks = duration;
    }

    function enableTokenTrade(ERC20 token) public onlyAdmin {

        require(tokenData[token].listed);
        require(tokenControlInfo[token].minimalRecordResolution != 0);
        tokenData[token].enabled = true;
    }

    function disableTokenTrade(ERC20 token) public onlyAlerter {

        require(tokenData[token].listed);
        tokenData[token].enabled = false;
    }

    function setReserveAddress(address reserve) public onlyAdmin {

        reserveContract = reserve;
    }

    function recordImbalance(
        ERC20 token,
        int buyAmount,
        uint rateUpdateBlock,
        uint currentBlock
    )
        public
    {

        require(msg.sender == reserveContract);

        if (rateUpdateBlock == 0) rateUpdateBlock = getRateUpdateBlock(token);

        return addImbalance(token, buyAmount, rateUpdateBlock, currentBlock);
    }

    function getRate(ERC20 token, uint currentBlockNumber, bool buy, uint qty) public view returns(uint) {

        if (!tokenData[token].enabled) return 0;
        if (tokenControlInfo[token].minimalRecordResolution == 0) return 0; // token control info not set

        bytes32 compactData = tokenRatesCompactData[tokenData[token].compactDataArrayIndex];

        uint updateRateBlock = getLast4Bytes(compactData);
        if (currentBlockNumber >= updateRateBlock + validRateDurationInBlocks) return 0; // rate is expired
        int totalImbalance;
        int blockImbalance;
        (totalImbalance, blockImbalance) = getImbalance(token, updateRateBlock, currentBlockNumber);

        int imbalanceQty;
        int extraBps;
        int8 rateUpdate;
        uint rate;

        if (buy) {
            rate = tokenData[token].baseBuyRate;

            rateUpdate = getRateByteFromCompactData(compactData, token, true);
            extraBps = int(rateUpdate) * 10;
            rate = addBps(rate, extraBps);

            qty = getTokenQty(token, rate, qty);
            imbalanceQty = int(qty);
            totalImbalance += imbalanceQty;

            extraBps = executeStepFunction(tokenData[token].buyRateQtyStepFunction, int(qty));
            rate = addBps(rate, extraBps);

            extraBps = executeStepFunction(tokenData[token].buyRateImbalanceStepFunction, totalImbalance);
            rate = addBps(rate, extraBps);
        } else {
            rate = tokenData[token].baseSellRate;

            rateUpdate = getRateByteFromCompactData(compactData, token, false);
            extraBps = int(rateUpdate) * 10;
            rate = addBps(rate, extraBps);

            imbalanceQty = -1 * int(qty);
            totalImbalance += imbalanceQty;

            extraBps = executeStepFunction(tokenData[token].sellRateQtyStepFunction, int(qty));
            rate = addBps(rate, extraBps);

            extraBps = executeStepFunction(tokenData[token].sellRateImbalanceStepFunction, totalImbalance);
            rate = addBps(rate, extraBps);
        }

        if (abs(totalImbalance) >= getMaxTotalImbalance(token)) return 0;
        if (abs(blockImbalance + imbalanceQty) >= getMaxPerBlockImbalance(token)) return 0;

        return rate;
    }

    function getBasicRate(ERC20 token, bool buy) public view returns(uint) {

        if (buy)
            return tokenData[token].baseBuyRate;
        else
            return tokenData[token].baseSellRate;
    }

    function getCompactData(ERC20 token) public view returns(uint, uint, byte, byte) {

        require(tokenData[token].listed);

        uint arrayIndex = tokenData[token].compactDataArrayIndex;
        uint fieldOffset = tokenData[token].compactDataFieldIndex;

        return (
            arrayIndex,
            fieldOffset,
            byte(getRateByteFromCompactData(tokenRatesCompactData[arrayIndex], token, true)),
            byte(getRateByteFromCompactData(tokenRatesCompactData[arrayIndex], token, false))
        );
    }

    function getTokenBasicData(ERC20 token) public view returns(bool, bool) {

        return (tokenData[token].listed, tokenData[token].enabled);
    }

    function getStepFunctionData(ERC20 token, uint command, uint param) public view returns(int) {

        if (command == 0) return int(tokenData[token].buyRateQtyStepFunction.x.length);
        if (command == 1) return tokenData[token].buyRateQtyStepFunction.x[param];
        if (command == 2) return int(tokenData[token].buyRateQtyStepFunction.y.length);
        if (command == 3) return tokenData[token].buyRateQtyStepFunction.y[param];

        if (command == 4) return int(tokenData[token].sellRateQtyStepFunction.x.length);
        if (command == 5) return tokenData[token].sellRateQtyStepFunction.x[param];
        if (command == 6) return int(tokenData[token].sellRateQtyStepFunction.y.length);
        if (command == 7) return tokenData[token].sellRateQtyStepFunction.y[param];

        if (command == 8) return int(tokenData[token].buyRateImbalanceStepFunction.x.length);
        if (command == 9) return tokenData[token].buyRateImbalanceStepFunction.x[param];
        if (command == 10) return int(tokenData[token].buyRateImbalanceStepFunction.y.length);
        if (command == 11) return tokenData[token].buyRateImbalanceStepFunction.y[param];

        if (command == 12) return int(tokenData[token].sellRateImbalanceStepFunction.x.length);
        if (command == 13) return tokenData[token].sellRateImbalanceStepFunction.x[param];
        if (command == 14) return int(tokenData[token].sellRateImbalanceStepFunction.y.length);
        if (command == 15) return tokenData[token].sellRateImbalanceStepFunction.y[param];

        revert();
    }

    function getRateUpdateBlock(ERC20 token) public view returns(uint) {

        bytes32 compactData = tokenRatesCompactData[tokenData[token].compactDataArrayIndex];
        return getLast4Bytes(compactData);
    }

    function getListedTokens() public view returns(ERC20[]) {

        return listedTokens;
    }

    function getTokenQty(ERC20 token, uint ethQty, uint rate) internal view returns(uint) {

        uint dstDecimals = getDecimals(token);
        uint srcDecimals = ETH_DECIMALS;

        return calcDstQty(ethQty, srcDecimals, dstDecimals, rate);
    }

    function getLast4Bytes(bytes32 b) internal pure returns(uint) {

        return uint(b) / (BYTES_14_OFFSET * BYTES_14_OFFSET);
    }

    function getRateByteFromCompactData(bytes32 data, ERC20 token, bool buy) internal view returns(int8) {

        uint fieldOffset = tokenData[token].compactDataFieldIndex;
        uint byteOffset;
        if (buy)
            byteOffset = 32 - NUM_TOKENS_IN_COMPACT_DATA + fieldOffset;
        else
            byteOffset = 4 + fieldOffset;

        return int8(data[byteOffset]);
    }

    function executeStepFunction(StepFunction f, int x) internal pure returns(int) {

        uint len = f.y.length;
        for (uint ind = 0; ind < len; ind++) {
            if (x <= f.x[ind]) return f.y[ind];
        }

        return f.y[len-1];
    }

    function addBps(uint rate, int bps) internal pure returns(uint) {

        require(rate <= MAX_RATE);
        require(bps >= MIN_BPS_ADJUSTMENT);
        require(bps <= MAX_BPS_ADJUSTMENT);

        uint maxBps = 100 * 100;
        return (rate * uint(int(maxBps) + bps)) / maxBps;
    }

    function abs(int x) internal pure returns(uint) {

        if (x < 0)
            return uint(-1 * x);
        else
            return uint(x);
    }
}


interface ExpectedRateInterface {

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty, bool usePermissionless) public view
        returns (uint expectedRate, uint slippageRate);

}


interface FeeBurnerInterface {

    function handleFees (uint tradeWeiAmount, address reserve, address wallet) public returns(bool);
    function setReserveData(address reserve, uint feesInBps, address kncWallet) public;

}


interface KyberReserveInterface {


    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool);


    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint);

}


contract WhiteListInterface {

    function getUserCapInWei(address user) external view returns (uint userCapWei);

}


contract ReentrancyGuard {


    uint256 private guardCounter = 1;

    modifier nonReentrant() {

        guardCounter += 1;
        uint256 localCounter = guardCounter;
        _;
        require(localCounter == guardCounter);
    }
}


contract Utils2 is Utils {


    function getBalance(ERC20 token, address user) public view returns(uint) {

        if (token == ETH_TOKEN_ADDRESS)
            return user.balance;
        else
            return token.balanceOf(user);
    }

    function getDecimalsSafe(ERC20 token) internal returns(uint) {


        if (decimals[token] == 0) {
            setDecimals(token);
        }

        return decimals[token];
    }

    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns(uint) {

        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns(uint) {

        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns(uint)
    {

        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }
}


interface KyberNetworkInterface {

    function maxGasPrice() public view returns(uint);

    function getUserCapInWei(address user) public view returns(uint);

    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);

    function enabled() public view returns(bool);

    function info(bytes32 id) public view returns(uint);


    function searchBestRate(ERC20 src, ERC20 dest, uint srcAmount, bool usePermissionless) public view
        returns(address, uint);


    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);


    function tradeWithHint(address trader, ERC20 src, uint srcAmount, ERC20 dest, address destAddress,
        uint maxDestAmount, uint minConversionRate, address walletId, bytes hint) public payable returns(uint);

}


contract KyberNetwork is Withdrawable, Utils2, KyberNetworkInterface, ReentrancyGuard {


    bytes public constant PERM_HINT = "PERM";
    uint  public constant PERM_HINT_GET_RATE = 1 << 255; // for get rate. bit mask hint.

    uint public negligibleRateDiff = 10; // basic rate steps will be in 0.01%
    KyberReserveInterface[] public reserves;
    mapping(address=>ReserveType) public reserveType;
    WhiteListInterface public whiteListContract;
    ExpectedRateInterface public expectedRateContract;
    FeeBurnerInterface    public feeBurnerContract;
    address               public kyberNetworkProxyContract;
    uint                  public maxGasPriceValue = 50 * 1000 * 1000 * 1000; // 50 gwei
    bool                  public isEnabled = false; // network is enabled
    mapping(bytes32=>uint) public infoFields; // this is only a UI field for external app.

    mapping(address=>address[]) public reservesPerTokenSrc; //reserves supporting token to eth
    mapping(address=>address[]) public reservesPerTokenDest;//reserves support eth to token

    enum ReserveType {NONE, PERMISSIONED, PERMISSIONLESS}
    bytes internal constant EMPTY_HINT = "";

    function KyberNetwork(address _admin) public {

        require(_admin != address(0));
        admin = _admin;
    }

    event EtherReceival(address indexed sender, uint amount);

    function() public payable {
        require(reserveType[msg.sender] != ReserveType.NONE);
        EtherReceival(msg.sender, msg.value);
    }

    struct TradeInput {
        address trader;
        ERC20 src;
        uint srcAmount;
        ERC20 dest;
        address destAddress;
        uint maxDestAmount;
        uint minConversionRate;
        address walletId;
        bytes hint;
    }

    function tradeWithHint(
        address trader,
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes hint
    )
        public
        nonReentrant
        payable
        returns(uint)
    {

        require(msg.sender == kyberNetworkProxyContract);
        require((hint.length == 0) || (hint.length == 4));

        TradeInput memory tradeInput;

        tradeInput.trader = trader;
        tradeInput.src = src;
        tradeInput.srcAmount = srcAmount;
        tradeInput.dest = dest;
        tradeInput.destAddress = destAddress;
        tradeInput.maxDestAmount = maxDestAmount;
        tradeInput.minConversionRate = minConversionRate;
        tradeInput.walletId = walletId;
        tradeInput.hint = hint;

        return trade(tradeInput);
    }

    event AddReserveToNetwork(KyberReserveInterface indexed reserve, bool add, bool isPermissionless);

    function addReserve(KyberReserveInterface reserve, bool isPermissionless) public onlyOperator
        returns(bool)
    {

        require(reserveType[reserve] == ReserveType.NONE);
        reserves.push(reserve);

        reserveType[reserve] = isPermissionless ? ReserveType.PERMISSIONLESS : ReserveType.PERMISSIONED;

        AddReserveToNetwork(reserve, true, isPermissionless);

        return true;
    }

    event RemoveReserveFromNetwork(KyberReserveInterface reserve);

    function removeReserve(KyberReserveInterface reserve, uint index) public onlyOperator
        returns(bool)
    {


        require(reserveType[reserve] != ReserveType.NONE);
        require(reserves[index] == reserve);

        reserveType[reserve] = ReserveType.NONE;
        reserves[index] = reserves[reserves.length - 1];
        reserves.length--;

        RemoveReserveFromNetwork(reserve);

        return true;
    }

    event ListReservePairs(address indexed reserve, ERC20 src, ERC20 dest, bool add);

    function listPairForReserve(address reserve, ERC20 token, bool ethToToken, bool tokenToEth, bool add)
        public
        onlyOperator
        returns(bool)
    {

        require(reserveType[reserve] != ReserveType.NONE);

        if (ethToToken) {
            listPairs(reserve, token, false, add);

            ListReservePairs(reserve, ETH_TOKEN_ADDRESS, token, add);
        }

        if (tokenToEth) {
            listPairs(reserve, token, true, add);

            if (add) {
                require(token.approve(reserve, 2**255)); // approve infinity
            } else {
                require(token.approve(reserve, 0));
            }

            ListReservePairs(reserve, token, ETH_TOKEN_ADDRESS, add);
        }

        setDecimals(token);

        return true;
    }

    event WhiteListContractSet(WhiteListInterface newContract, WhiteListInterface currentContract);

    function setWhiteList(WhiteListInterface whiteList) public onlyAdmin {

        WhiteListContractSet(whiteList, whiteListContract);
        whiteListContract = whiteList;
    }

    event ExpectedRateContractSet(ExpectedRateInterface newContract, ExpectedRateInterface currentContract);

    function setExpectedRate(ExpectedRateInterface expectedRate) public onlyAdmin {

        require(expectedRate != address(0));

        ExpectedRateContractSet(expectedRate, expectedRateContract);
        expectedRateContract = expectedRate;
    }

    event FeeBurnerContractSet(FeeBurnerInterface newContract, FeeBurnerInterface currentContract);

    function setFeeBurner(FeeBurnerInterface feeBurner) public onlyAdmin {

        require(feeBurner != address(0));

        FeeBurnerContractSet(feeBurner, feeBurnerContract);
        feeBurnerContract = feeBurner;
    }

    event KyberNetwrokParamsSet(uint maxGasPrice, uint negligibleRateDiff);

    function setParams(
        uint                  _maxGasPrice,
        uint                  _negligibleRateDiff
    )
        public
        onlyAdmin
    {

        require(_negligibleRateDiff <= 100 * 100); // at most 100%

        maxGasPriceValue = _maxGasPrice;
        negligibleRateDiff = _negligibleRateDiff;
        KyberNetwrokParamsSet(maxGasPriceValue, negligibleRateDiff);
    }

    event KyberNetworkSetEnable(bool isEnabled);

    function setEnable(bool _enable) public onlyAdmin {

        if (_enable) {
            require(feeBurnerContract != address(0));
            require(expectedRateContract != address(0));
            require(kyberNetworkProxyContract != address(0));
        }
        isEnabled = _enable;

        KyberNetworkSetEnable(isEnabled);
    }

    function setInfo(bytes32 field, uint value) public onlyOperator {

        infoFields[field] = value;
    }

    event KyberProxySet(address proxy, address sender);

    function setKyberProxy(address networkProxy) public onlyAdmin {

        require(networkProxy != address(0));
        kyberNetworkProxyContract = networkProxy;
        KyberProxySet(kyberNetworkProxyContract, msg.sender);
    }

    function getNumReserves() public view returns(uint) {

        return reserves.length;
    }

    function getReserves() public view returns(KyberReserveInterface[]) {

        return reserves;
    }

    function maxGasPrice() public view returns(uint) {

        return maxGasPriceValue;
    }

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
        public view
        returns(uint expectedRate, uint slippageRate)
    {

        require(expectedRateContract != address(0));
        bool includePermissionless = true;

        if (srcQty & PERM_HINT_GET_RATE > 0) {
            includePermissionless = false;
            srcQty = srcQty & ~PERM_HINT_GET_RATE;
        }

        return expectedRateContract.getExpectedRate(src, dest, srcQty, includePermissionless);
    }

    function getExpectedRateOnlyPermission(ERC20 src, ERC20 dest, uint srcQty)
        public view
        returns(uint expectedRate, uint slippageRate)
    {

        require(expectedRateContract != address(0));
        return expectedRateContract.getExpectedRate(src, dest, srcQty, false);
    }

    function getUserCapInWei(address user) public view returns(uint) {

        if (whiteListContract == address(0)) return (2 ** 255);
        return whiteListContract.getUserCapInWei(user);
    }

    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint) {

        user;
        token;
        require(false);
    }

    struct BestRateResult {
        uint rate;
        address reserve1;
        address reserve2;
        uint weiAmount;
        uint rateSrcToEth;
        uint rateEthToDest;
        uint destAmount;
    }

    function findBestRate(ERC20 src, ERC20 dest, uint srcAmount) public view returns(uint obsolete, uint rate) {

        BestRateResult memory result = findBestRateTokenToToken(src, dest, srcAmount, EMPTY_HINT);
        return(0, result.rate);
    }

    function findBestRateOnlyPermission(ERC20 src, ERC20 dest, uint srcAmount)
        public
        view
        returns(uint obsolete, uint rate)
    {

        BestRateResult memory result = findBestRateTokenToToken(src, dest, srcAmount, PERM_HINT);
        return(0, result.rate);
    }

    function enabled() public view returns(bool) {

        return isEnabled;
    }

    function info(bytes32 field) public view returns(uint) {

        return infoFields[field];
    }

    function searchBestRate(ERC20 src, ERC20 dest, uint srcAmount, bool usePermissionless)
        public
        view
        returns(address, uint)
    {

        uint bestRate = 0;
        uint bestReserve = 0;
        uint numRelevantReserves = 0;

        if (src == dest) return (reserves[bestReserve], PRECISION);

        address[] memory reserveArr;

        reserveArr = src == ETH_TOKEN_ADDRESS ? reservesPerTokenDest[dest] : reservesPerTokenSrc[src];

        if (reserveArr.length == 0) return (reserves[bestReserve], bestRate);

        uint[] memory rates = new uint[](reserveArr.length);
        uint[] memory reserveCandidates = new uint[](reserveArr.length);

        for (uint i = 0; i < reserveArr.length; i++) {
            if (!usePermissionless && reserveType[reserveArr[i]] == ReserveType.PERMISSIONLESS) {
                continue;
            }

            rates[i] = (KyberReserveInterface(reserveArr[i])).getConversionRate(src, dest, srcAmount, block.number);

            if (rates[i] > bestRate) {
                bestRate = rates[i];
            }
        }

        if (bestRate > 0) {
            uint smallestRelevantRate = (bestRate * 10000) / (10000 + negligibleRateDiff);

            for (i = 0; i < reserveArr.length; i++) {
                if (rates[i] >= smallestRelevantRate) {
                    reserveCandidates[numRelevantReserves++] = i;
                }
            }

            if (numRelevantReserves > 1) {
                bestReserve = reserveCandidates[uint(block.blockhash(block.number-1)) % numRelevantReserves];
            } else {
                bestReserve = reserveCandidates[0];
            }

            bestRate = rates[bestReserve];
        }

        return (reserveArr[bestReserve], bestRate);
    }

    function findBestRateTokenToToken(ERC20 src, ERC20 dest, uint srcAmount, bytes hint) internal view
        returns(BestRateResult result)
    {

        bool usePermissionless = true;

        if ((hint.length >= 4) && (keccak256(hint[0], hint[1], hint[2], hint[3]) == keccak256(PERM_HINT))) {
            usePermissionless = false;
        }

        (result.reserve1, result.rateSrcToEth) =
            searchBestRate(src, ETH_TOKEN_ADDRESS, srcAmount, usePermissionless);

        result.weiAmount = calcDestAmount(src, ETH_TOKEN_ADDRESS, srcAmount, result.rateSrcToEth);

        (result.reserve2, result.rateEthToDest) =
            searchBestRate(ETH_TOKEN_ADDRESS, dest, result.weiAmount, usePermissionless);

        result.destAmount = calcDestAmount(ETH_TOKEN_ADDRESS, dest, result.weiAmount, result.rateEthToDest);

        result.rate = calcRateFromQty(srcAmount, result.destAmount, getDecimals(src), getDecimals(dest));
    }

    function listPairs(address reserve, ERC20 token, bool isTokenToEth, bool add) internal {

        uint i;
        address[] storage reserveArr = reservesPerTokenDest[token];

        if (isTokenToEth) {
            reserveArr = reservesPerTokenSrc[token];
        }

        for (i = 0; i < reserveArr.length; i++) {
            if (reserve == reserveArr[i]) {
                if (add) {
                    break; //already added
                } else {
                    reserveArr[i] = reserveArr[reserveArr.length - 1];
                    reserveArr.length--;
                    break;
                }
            }
        }

        if (add && i == reserveArr.length) {
            reserveArr.push(reserve);
        }
    }

    event KyberTrade(address indexed trader, ERC20 src, ERC20 dest, uint srcAmount, uint dstAmount,
        address destAddress, uint ethWeiValue, address reserve1, address reserve2, bytes hint);

    function trade(TradeInput tradeInput) internal returns(uint) {

        require(isEnabled);
        require(tx.gasprice <= maxGasPriceValue);
        require(validateTradeInput(tradeInput.src, tradeInput.srcAmount, tradeInput.dest, tradeInput.destAddress));

        BestRateResult memory rateResult =
            findBestRateTokenToToken(tradeInput.src, tradeInput.dest, tradeInput.srcAmount, tradeInput.hint);

        require(rateResult.rate > 0);
        require(rateResult.rate < MAX_RATE);
        require(rateResult.rate >= tradeInput.minConversionRate);

        uint actualDestAmount;
        uint weiAmount;
        uint actualSrcAmount;

        (actualSrcAmount, weiAmount, actualDestAmount) = calcActualAmounts(tradeInput.src,
            tradeInput.dest,
            tradeInput.srcAmount,
            tradeInput.maxDestAmount,
            rateResult);

        require(getUserCapInWei(tradeInput.trader) >= weiAmount);
        require(handleChange(tradeInput.src, tradeInput.srcAmount, actualSrcAmount, tradeInput.trader));

        require(doReserveTrade(     //src to ETH
                tradeInput.src,
                actualSrcAmount,
                ETH_TOKEN_ADDRESS,
                this,
                weiAmount,
                KyberReserveInterface(rateResult.reserve1),
                rateResult.rateSrcToEth,
                true));

        require(doReserveTrade(     //Eth to dest
                ETH_TOKEN_ADDRESS,
                weiAmount,
                tradeInput.dest,
                tradeInput.destAddress,
                actualDestAmount,
                KyberReserveInterface(rateResult.reserve2),
                rateResult.rateEthToDest,
                true));

        if (tradeInput.src != ETH_TOKEN_ADDRESS) //"fake" trade. (ether to ether) - don't burn.
            require(feeBurnerContract.handleFees(weiAmount, rateResult.reserve1, tradeInput.walletId));
        if (tradeInput.dest != ETH_TOKEN_ADDRESS) //"fake" trade. (ether to ether) - don't burn.
            require(feeBurnerContract.handleFees(weiAmount, rateResult.reserve2, tradeInput.walletId));

        KyberTrade({
            trader: tradeInput.trader,
            src: tradeInput.src,
            dest: tradeInput.dest,
            srcAmount: actualSrcAmount,
            dstAmount: actualDestAmount,
            destAddress: tradeInput.destAddress,
            ethWeiValue: weiAmount,
            reserve1: (tradeInput.src == ETH_TOKEN_ADDRESS) ? address(0) : rateResult.reserve1,
            reserve2:  (tradeInput.dest == ETH_TOKEN_ADDRESS) ? address(0) : rateResult.reserve2,
            hint: tradeInput.hint
        });

        return actualDestAmount;
    }

    function calcActualAmounts (ERC20 src, ERC20 dest, uint srcAmount, uint maxDestAmount, BestRateResult rateResult)
        internal view returns(uint actualSrcAmount, uint weiAmount, uint actualDestAmount)
    {
        if (rateResult.destAmount > maxDestAmount) {
            actualDestAmount = maxDestAmount;
            weiAmount = calcSrcAmount(ETH_TOKEN_ADDRESS, dest, actualDestAmount, rateResult.rateEthToDest);
            actualSrcAmount = calcSrcAmount(src, ETH_TOKEN_ADDRESS, weiAmount, rateResult.rateSrcToEth);
            require(actualSrcAmount <= srcAmount);
        } else {
            actualDestAmount = rateResult.destAmount;
            actualSrcAmount = srcAmount;
            weiAmount = rateResult.weiAmount;
        }
    }

    function doReserveTrade(
        ERC20 src,
        uint amount,
        ERC20 dest,
        address destAddress,
        uint expectedDestAmount,
        KyberReserveInterface reserve,
        uint conversionRate,
        bool validate
    )
        internal
        returns(bool)
    {

        uint callValue = 0;

        if (src == dest) {
            if (destAddress != (address(this)))
                destAddress.transfer(amount);
            return true;
        }

        if (src == ETH_TOKEN_ADDRESS) {
            callValue = amount;
        }

        require(reserve.trade.value(callValue)(src, amount, dest, this, conversionRate, validate));

        if (destAddress != address(this)) {
            if (dest == ETH_TOKEN_ADDRESS) {
                destAddress.transfer(expectedDestAmount);
            } else {
                require(dest.transfer(destAddress, expectedDestAmount));
            }
        }

        return true;
    }

    function handleChange (ERC20 src, uint srcAmount, uint requiredSrcAmount, address trader) internal returns (bool) {

        if (requiredSrcAmount < srcAmount) {
            if (src == ETH_TOKEN_ADDRESS) {
                trader.transfer(srcAmount - requiredSrcAmount);
            } else {
                require(src.transfer(trader, (srcAmount - requiredSrcAmount)));
            }
        }

        return true;
    }

    function validateTradeInput(ERC20 src, uint srcAmount, ERC20 dest, address destAddress)
        internal
        view
        returns(bool)
    {

        require(srcAmount <= MAX_QTY);
        require(srcAmount != 0);
        require(destAddress != address(0));
        require(src != dest);

        if (src == ETH_TOKEN_ADDRESS) {
            require(msg.value == srcAmount);
        } else {
            require(msg.value == 0);
            require(src.balanceOf(this) >= srcAmount);
        }

        return true;
    }
}


interface KyberNetworkProxyInterface {

    function maxGasPrice() public view returns(uint);

    function getUserCapInWei(address user) public view returns(uint);

    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);

    function enabled() public view returns(bool);

    function info(bytes32 id) public view returns(uint);


    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);


    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) public payable returns(uint);

}


interface SimpleNetworkInterface {

    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);

    function swapEtherToToken(ERC20 token, uint minConversionRate) public payable returns(uint);

    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) public returns(uint);

}


contract KyberNetworkProxy is KyberNetworkProxyInterface, SimpleNetworkInterface, Withdrawable, Utils2 {


    KyberNetworkInterface public kyberNetworkContract;

    function KyberNetworkProxy(address _admin) public {

        require(_admin != address(0));
        admin = _admin;
    }

    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint)
    {

        bytes memory hint;

        return tradeWithHint(
            src,
            srcAmount,
            dest,
            destAddress,
            maxDestAmount,
            minConversionRate,
            walletId,
            hint
        );
    }

    function swapTokenToToken(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        uint minConversionRate
    )
        public
        returns(uint)
    {

        bytes memory hint;

        return tradeWithHint(
            src,
            srcAmount,
            dest,
            msg.sender,
            MAX_QTY,
            minConversionRate,
            0,
            hint
        );
    }

    function swapEtherToToken(ERC20 token, uint minConversionRate) public payable returns(uint) {

        bytes memory hint;

        return tradeWithHint(
            ETH_TOKEN_ADDRESS,
            msg.value,
            token,
            msg.sender,
            MAX_QTY,
            minConversionRate,
            0,
            hint
        );
    }

    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) public returns(uint) {

        bytes memory hint;

        return tradeWithHint(
            token,
            srcAmount,
            ETH_TOKEN_ADDRESS,
            msg.sender,
            MAX_QTY,
            minConversionRate,
            0,
            hint
        );
    }

    struct UserBalance {
        uint srcBalance;
        uint destBalance;
    }

    event ExecuteTrade(address indexed trader, ERC20 src, ERC20 dest, uint actualSrcAmount, uint actualDestAmount);

    function tradeWithHint(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes hint
    )
        public
        payable
        returns(uint)
    {

        require(src == ETH_TOKEN_ADDRESS || msg.value == 0);
        
        UserBalance memory userBalanceBefore;

        userBalanceBefore.srcBalance = getBalance(src, msg.sender);
        userBalanceBefore.destBalance = getBalance(dest, destAddress);

        if (src == ETH_TOKEN_ADDRESS) {
            userBalanceBefore.srcBalance += msg.value;
        } else {
            require(src.transferFrom(msg.sender, kyberNetworkContract, srcAmount));
        }

        uint reportedDestAmount = kyberNetworkContract.tradeWithHint.value(msg.value)(
            msg.sender,
            src,
            srcAmount,
            dest,
            destAddress,
            maxDestAmount,
            minConversionRate,
            walletId,
            hint
        );

        TradeOutcome memory tradeOutcome = calculateTradeOutcome(
            userBalanceBefore.srcBalance,
            userBalanceBefore.destBalance,
            src,
            dest,
            destAddress
        );

        require(reportedDestAmount == tradeOutcome.userDeltaDestAmount);
        require(tradeOutcome.userDeltaDestAmount <= maxDestAmount);
        require(tradeOutcome.actualRate >= minConversionRate);

        ExecuteTrade(msg.sender, src, dest, tradeOutcome.userDeltaSrcAmount, tradeOutcome.userDeltaDestAmount);
        return tradeOutcome.userDeltaDestAmount;
    }

    event KyberNetworkSet(address newNetworkContract, address oldNetworkContract);

    function setKyberNetworkContract(KyberNetworkInterface _kyberNetworkContract) public onlyAdmin {


        require(_kyberNetworkContract != address(0));

        KyberNetworkSet(_kyberNetworkContract, kyberNetworkContract);

        kyberNetworkContract = _kyberNetworkContract;
    }

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
        public view
        returns(uint expectedRate, uint slippageRate)
    {

        return kyberNetworkContract.getExpectedRate(src, dest, srcQty);
    }

    function getUserCapInWei(address user) public view returns(uint) {

        return kyberNetworkContract.getUserCapInWei(user);
    }

    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint) {

        return kyberNetworkContract.getUserCapInTokenWei(user, token);
    }

    function maxGasPrice() public view returns(uint) {

        return kyberNetworkContract.maxGasPrice();
    }

    function enabled() public view returns(bool) {

        return kyberNetworkContract.enabled();
    }

    function info(bytes32 field) public view returns(uint) {

        return kyberNetworkContract.info(field);
    }

    struct TradeOutcome {
        uint userDeltaSrcAmount;
        uint userDeltaDestAmount;
        uint actualRate;
    }

    function calculateTradeOutcome (uint srcBalanceBefore, uint destBalanceBefore, ERC20 src, ERC20 dest,
        address destAddress)
        internal returns(TradeOutcome outcome)
    {
        uint userSrcBalanceAfter;
        uint userDestBalanceAfter;

        userSrcBalanceAfter = getBalance(src, msg.sender);
        userDestBalanceAfter = getBalance(dest, destAddress);

        require(userDestBalanceAfter > destBalanceBefore);
        require(srcBalanceBefore > userSrcBalanceAfter);

        outcome.userDeltaDestAmount = userDestBalanceAfter - destBalanceBefore;
        outcome.userDeltaSrcAmount = srcBalanceBefore - userSrcBalanceAfter;

        outcome.actualRate = calcRateFromQty(
                outcome.userDeltaSrcAmount,
                outcome.userDeltaDestAmount,
                getDecimalsSafe(src),
                getDecimalsSafe(dest)
            );
    }
}


interface SanityRatesInterface {

    function getSanityRate(ERC20 src, ERC20 dest) public view returns(uint);

}

contract KyberReserve is KyberReserveInterface, Withdrawable, Utils {


    address public kyberNetwork;
    bool public tradeEnabled;
    ConversionRatesInterface public conversionRatesContract;
    SanityRatesInterface public sanityRatesContract;
    mapping(bytes32=>bool) public approvedWithdrawAddresses; // sha3(token,address)=>bool

    function KyberReserve(address _kyberNetwork, ConversionRatesInterface _ratesContract, address _admin) public {

        require(_admin != address(0));
        require(_ratesContract != address(0));
        require(_kyberNetwork != address(0));
        kyberNetwork = _kyberNetwork;
        conversionRatesContract = _ratesContract;
        admin = _admin;
        tradeEnabled = true;
    }

    event DepositToken(ERC20 token, uint amount);

    function() public payable {
        DepositToken(ETH_TOKEN_ADDRESS, msg.value);
    }

    event TradeExecute(
        address indexed origin,
        address src,
        uint srcAmount,
        address destToken,
        uint destAmount,
        address destAddress
    );

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool)
    {

        require(tradeEnabled);
        require(msg.sender == kyberNetwork);

        require(doTrade(srcToken, srcAmount, destToken, destAddress, conversionRate, validate));

        return true;
    }

    event TradeEnabled(bool enable);

    function enableTrade() public onlyAdmin returns(bool) {

        tradeEnabled = true;
        TradeEnabled(true);

        return true;
    }

    function disableTrade() public onlyAlerter returns(bool) {

        tradeEnabled = false;
        TradeEnabled(false);

        return true;
    }

    event WithdrawAddressApproved(ERC20 token, address addr, bool approve);

    function approveWithdrawAddress(ERC20 token, address addr, bool approve) public onlyAdmin {

        approvedWithdrawAddresses[keccak256(token, addr)] = approve;
        WithdrawAddressApproved(token, addr, approve);

        setDecimals(token);
    }

    event WithdrawFunds(ERC20 token, uint amount, address destination);

    function withdraw(ERC20 token, uint amount, address destination) public onlyOperator returns(bool) {

        require(approvedWithdrawAddresses[keccak256(token, destination)]);

        if (token == ETH_TOKEN_ADDRESS) {
            destination.transfer(amount);
        } else {
            require(token.transfer(destination, amount));
        }

        WithdrawFunds(token, amount, destination);

        return true;
    }

    event SetContractAddresses(address network, address rate, address sanity);

    function setContracts(address _kyberNetwork, ConversionRatesInterface _conversionRates, SanityRatesInterface _sanityRates)
        public
        onlyAdmin
    {

        require(_kyberNetwork != address(0));
        require(_conversionRates != address(0));

        kyberNetwork = _kyberNetwork;
        conversionRatesContract = _conversionRates;
        sanityRatesContract = _sanityRates;

        SetContractAddresses(kyberNetwork, conversionRatesContract, sanityRatesContract);
    }

    function getBalance(ERC20 token) public view returns(uint) {

        if (token == ETH_TOKEN_ADDRESS)
            return this.balance;
        else
            return token.balanceOf(this);
    }

    function getDestQty(ERC20 src, ERC20 dest, uint srcQty, uint rate) public view returns(uint) {

        uint dstDecimals = getDecimals(dest);
        uint srcDecimals = getDecimals(src);

        return calcDstQty(srcQty, srcDecimals, dstDecimals, rate);
    }

    function getSrcQty(ERC20 src, ERC20 dest, uint dstQty, uint rate) public view returns(uint) {

        uint dstDecimals = getDecimals(dest);
        uint srcDecimals = getDecimals(src);

        return calcSrcQty(dstQty, srcDecimals, dstDecimals, rate);
    }

    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint) {

        ERC20 token;
        bool  buy;

        if (!tradeEnabled) return 0;

        if (ETH_TOKEN_ADDRESS == src) {
            buy = true;
            token = dest;
        } else if (ETH_TOKEN_ADDRESS == dest) {
            buy = false;
            token = src;
        } else {
            return 0; // pair is not listed
        }

        uint rate = conversionRatesContract.getRate(token, blockNumber, buy, srcQty);
        uint destQty = getDestQty(src, dest, srcQty, rate);

        if (getBalance(dest) < destQty) return 0;

        if (sanityRatesContract != address(0)) {
            uint sanityRate = sanityRatesContract.getSanityRate(src, dest);
            if (rate > sanityRate) return 0;
        }

        return rate;
    }

    function doTrade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        internal
        returns(bool)
    {

        if (validate) {
            require(conversionRate > 0);
            if (srcToken == ETH_TOKEN_ADDRESS)
                require(msg.value == srcAmount);
            else
                require(msg.value == 0);
        }

        uint destAmount = getDestQty(srcToken, destToken, srcAmount, conversionRate);
        require(destAmount > 0);

        ERC20 token;
        int buy;
        if (srcToken == ETH_TOKEN_ADDRESS) {
            buy = int(destAmount);
            token = destToken;
        } else {
            buy = -1 * int(srcAmount);
            token = srcToken;
        }

        conversionRatesContract.recordImbalance(
            token,
            buy,
            0,
            block.number
        );

        if (srcToken != ETH_TOKEN_ADDRESS) {
            require(srcToken.transferFrom(msg.sender, this, srcAmount));
        }

        if (destToken == ETH_TOKEN_ADDRESS) {
            destAddress.transfer(destAmount);
        } else {
            require(destToken.transfer(destAddress, destAmount));
        }

        TradeExecute(msg.sender, srcToken, srcAmount, destToken, destAmount, destAddress);

        return true;
    }
}


contract OrderIdManager {

    struct OrderIdData {
        uint32 firstOrderId;
        uint takenBitmap;
    }

    uint constant public NUM_ORDERS = 32;

    function fetchNewOrderId(OrderIdData storage freeOrders)
        internal
        returns(uint32)
    {

        uint orderBitmap = freeOrders.takenBitmap;
        uint bitPointer = 1;

        for (uint i = 0; i < NUM_ORDERS; ++i) {

            if ((orderBitmap & bitPointer) == 0) {
                freeOrders.takenBitmap = orderBitmap | bitPointer;
                return(uint32(uint(freeOrders.firstOrderId) + i));
            }

            bitPointer *= 2;
        }

        revert();
    }

    function releaseOrderId(OrderIdData storage freeOrders, uint32 orderId)
        internal
        returns(bool)
    {

        require(orderId >= freeOrders.firstOrderId);
        require(orderId < (freeOrders.firstOrderId + NUM_ORDERS));

        uint orderBitNum = uint(orderId) - uint(freeOrders.firstOrderId);
        uint bitPointer = uint(1) << orderBitNum;

        require(bitPointer & freeOrders.takenBitmap > 0);

        freeOrders.takenBitmap &= ~bitPointer;
        return true;
    }

    function allocateOrderIds(
        OrderIdData storage makerOrders,
        uint32 firstAllocatedId
    )
        internal
        returns(bool)
    {

        if (makerOrders.firstOrderId > 0) {
            return false;
        }

        makerOrders.firstOrderId = firstAllocatedId;
        makerOrders.takenBitmap = 0;

        return true;
    }

    function orderAllocationRequired(OrderIdData storage freeOrders) internal view returns (bool) {


        if (freeOrders.firstOrderId == 0) return true;
        return false;
    }

    function getNumActiveOrderIds(OrderIdData storage makerOrders) internal view returns (uint numActiveOrders) {

        for (uint i = 0; i < NUM_ORDERS; ++i) {
            if ((makerOrders.takenBitmap & (uint(1) << i)) > 0) numActiveOrders++;
        }
    }
}


interface OrderListInterface {

    function getOrderDetails(uint32 orderId) public view returns (address, uint128, uint128, uint32, uint32);

    function add(address maker, uint32 orderId, uint128 srcAmount, uint128 dstAmount) public returns (bool);

    function remove(uint32 orderId) public returns (bool);

    function update(uint32 orderId, uint128 srcAmount, uint128 dstAmount) public returns (bool);

    function getFirstOrder() public view returns(uint32 orderId, bool isEmpty);

    function allocateIds(uint32 howMany) public returns(uint32);

    function findPrevOrderId(uint128 srcAmount, uint128 dstAmount) public view returns(uint32);


    function addAfterId(address maker, uint32 orderId, uint128 srcAmount, uint128 dstAmount, uint32 prevId) public
        returns (bool);


    function updateWithPositionHint(uint32 orderId, uint128 srcAmount, uint128 dstAmount, uint32 prevId) public
        returns(bool, uint);

}


interface OrderListFactoryInterface {

    function newOrdersContract(address admin) public returns(OrderListInterface);

}


interface OrderbookReserveInterface {

    function init() public returns(bool);

    function kncRateBlocksTrade() public view returns(bool);

}


contract FeeBurnerRateInterface {

    uint public kncPerEthRatePrecision;
}


interface MedianizerInterface {

    function peek() public view returns (bytes32, bool);

}


contract OrderbookReserve is OrderIdManager, Utils2, KyberReserveInterface, OrderbookReserveInterface {


    uint public constant BURN_TO_STAKE_FACTOR = 5;      // stake per order must be x4 then expected burn amount.
    uint public constant MAX_BURN_FEE_BPS = 100;        // 1%
    uint public constant MIN_REMAINING_ORDER_RATIO = 2; // Ratio between min new order value and min order value.
    uint public constant MAX_USD_PER_ETH = 100000;      // Above this value price is surely compromised.

    uint32 constant public TAIL_ID = 1;         // tail Id in order list contract
    uint32 constant public HEAD_ID = 2;         // head Id in order list contract

    struct OrderLimits {
        uint minNewOrderSizeUsd; // Basis for setting min new order size Eth
        uint maxOrdersPerTrade;     // Limit number of iterated orders per trade / getRate loops.
        uint minNewOrderSizeWei;    // Below this value can't create new order.
        uint minOrderSizeWei;       // below this value order will be removed.
    }

    uint public kncPerEthBaseRatePrecision; // according to base rate all stakes are calculated.

    struct ExternalContracts {
        ERC20 kncToken;          // not constant. to enable testing while not on main net
        ERC20 token;             // only supported token.
        FeeBurnerRateInterface feeBurner;
        address kyberNetwork;
        MedianizerInterface medianizer; // price feed Eth - USD from maker DAO.
        OrderListFactoryInterface orderListFactory;
    }

    struct OrderData {
        address maker;
        uint32 nextId;
        bool isLastOrder;
        uint128 srcAmount;
        uint128 dstAmount;
    }

    OrderLimits public limits;
    ExternalContracts public contracts;

    OrderListInterface public tokenToEthList;
    OrderListInterface public ethToTokenList;

    mapping(address => mapping(address => uint)) public makerFunds; // deposited maker funds.
    mapping(address => uint) public makerKnc;            // for knc staking.
    mapping(address => uint) public makerTotalOrdersWei; // per maker how many Wei in orders, for stake calculation.

    uint public makerBurnFeeBps;    // knc burn fee per order that is taken.

    mapping(address => OrderIdData) public makerOrdersTokenToEth;
    mapping(address => OrderIdData) public makerOrdersEthToToken;

    function OrderbookReserve(
        ERC20 knc,
        ERC20 reserveToken,
        address burner,
        address network,
        MedianizerInterface medianizer,
        OrderListFactoryInterface factory,
        uint minNewOrderUsd,
        uint maxOrdersPerTrade,
        uint burnFeeBps
    )
        public
    {


        require(knc != address(0));
        require(reserveToken != address(0));
        require(burner != address(0));
        require(network != address(0));
        require(medianizer != address(0));
        require(factory != address(0));
        require(burnFeeBps != 0);
        require(burnFeeBps <= MAX_BURN_FEE_BPS);
        require(maxOrdersPerTrade != 0);
        require(minNewOrderUsd > 0);

        contracts.kyberNetwork = network;
        contracts.feeBurner = FeeBurnerRateInterface(burner);
        contracts.medianizer = medianizer;
        contracts.orderListFactory = factory;
        contracts.kncToken = knc;
        contracts.token = reserveToken;

        makerBurnFeeBps = burnFeeBps;
        limits.minNewOrderSizeUsd = minNewOrderUsd;
        limits.maxOrdersPerTrade = maxOrdersPerTrade;

        require(setMinOrderSizeEth());
    
        require(contracts.kncToken.approve(contracts.feeBurner, (2**255)));

        setDecimals(contracts.token);

        kncPerEthBaseRatePrecision = contracts.feeBurner.kncPerEthRatePrecision();
    }

    function init() public returns(bool) {

        if ((tokenToEthList != address(0)) && (ethToTokenList != address(0))) return true;
        if ((tokenToEthList != address(0)) || (ethToTokenList != address(0))) revert();

        tokenToEthList = contracts.orderListFactory.newOrdersContract(this);
        ethToTokenList = contracts.orderListFactory.newOrdersContract(this);

        return true;
    }

    function setKncPerEthBaseRate() public {

        uint kncPerEthRatePrecision = contracts.feeBurner.kncPerEthRatePrecision();
        if (kncPerEthRatePrecision < kncPerEthBaseRatePrecision) {
            kncPerEthBaseRatePrecision = kncPerEthRatePrecision;
        }
    }

    function getConversionRate(ERC20 src, ERC20 dst, uint srcQty, uint blockNumber) public view returns(uint) {

        require((src == ETH_TOKEN_ADDRESS) || (dst == ETH_TOKEN_ADDRESS));
        require((src == contracts.token) || (dst == contracts.token));
        require(srcQty <= MAX_QTY);

        if (kncRateBlocksTrade()) return 0;

        blockNumber; // in this reserve no order expiry == no use for blockNumber. here to avoid compiler warning.

        OrderListInterface list = (src == ETH_TOKEN_ADDRESS) ? tokenToEthList : ethToTokenList;

        uint32 orderId;
        OrderData memory orderData;

        uint128 userRemainingSrcQty = uint128(srcQty);
        uint128 totalUserDstAmount = 0;
        uint maxOrders = limits.maxOrdersPerTrade;

        for (
            (orderId, orderData.isLastOrder) = list.getFirstOrder();
            ((userRemainingSrcQty > 0) && (!orderData.isLastOrder) && (maxOrders-- > 0));
            orderId = orderData.nextId
        ) {
            orderData = getOrderData(list, orderId);
            if (orderData.dstAmount <= userRemainingSrcQty) {
                totalUserDstAmount += orderData.srcAmount;
                userRemainingSrcQty -= orderData.dstAmount;
            } else {
                totalUserDstAmount += orderData.srcAmount * userRemainingSrcQty / orderData.dstAmount;
                userRemainingSrcQty = 0;
            }
        }

        if (userRemainingSrcQty != 0) return 0; //not enough tokens to exchange.

        return calcRateFromQty(srcQty, totalUserDstAmount, getDecimals(src), getDecimals(dst));
    }

    event OrderbookReserveTrade(ERC20 srcToken, ERC20 dstToken, uint srcAmount, uint dstAmount);

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 dstToken,
        address dstAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool)
    {

        require(msg.sender == contracts.kyberNetwork);
        require((srcToken == ETH_TOKEN_ADDRESS) || (dstToken == ETH_TOKEN_ADDRESS));
        require((srcToken == contracts.token) || (dstToken == contracts.token));
        require(srcAmount <= MAX_QTY);

        conversionRate;
        validate;

        if (srcToken == ETH_TOKEN_ADDRESS) {
            require(msg.value == srcAmount);
        } else {
            require(msg.value == 0);
            require(srcToken.transferFrom(msg.sender, this, srcAmount));
        }

        uint totalDstAmount = doTrade(
                srcToken,
                srcAmount,
                dstToken
            );

        require(conversionRate <= calcRateFromQty(srcAmount, totalDstAmount, getDecimals(srcToken),
            getDecimals(dstToken)));

        if (dstToken == ETH_TOKEN_ADDRESS) {
            dstAddress.transfer(totalDstAmount);
        } else {
            require(dstToken.transfer(dstAddress, totalDstAmount));
        }

        OrderbookReserveTrade(srcToken, dstToken, srcAmount, totalDstAmount);
        return true;
    }

    function doTrade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 dstToken
    )
        internal
        returns(uint)
    {

        OrderListInterface list = (srcToken == ETH_TOKEN_ADDRESS) ? tokenToEthList : ethToTokenList;

        uint32 orderId;
        OrderData memory orderData;
        uint128 userRemainingSrcQty = uint128(srcAmount);
        uint128 totalUserDstAmount = 0;

        for (
            (orderId, orderData.isLastOrder) = list.getFirstOrder();
            ((userRemainingSrcQty > 0) && (!orderData.isLastOrder));
            orderId = orderData.nextId
        ) {
            orderData = getOrderData(list, orderId);
            if (orderData.dstAmount <= userRemainingSrcQty) {
                totalUserDstAmount += orderData.srcAmount;
                userRemainingSrcQty -= orderData.dstAmount;
                require(takeFullOrder({
                    maker: orderData.maker,
                    orderId: orderId,
                    userSrc: srcToken,
                    userDst: dstToken,
                    userSrcAmount: orderData.dstAmount,
                    userDstAmount: orderData.srcAmount
                }));
            } else {
                uint128 partialDstQty = orderData.srcAmount * userRemainingSrcQty / orderData.dstAmount;
                totalUserDstAmount += partialDstQty;
                require(takePartialOrder({
                    maker: orderData.maker,
                    orderId: orderId,
                    userSrc: srcToken,
                    userDst: dstToken,
                    userPartialSrcAmount: userRemainingSrcQty,
                    userTakeDstAmount: partialDstQty,
                    orderSrcAmount: orderData.srcAmount,
                    orderDstAmount: orderData.dstAmount
                }));
                userRemainingSrcQty = 0;
            }
        }

        require(userRemainingSrcQty == 0 && totalUserDstAmount > 0);

        return totalUserDstAmount;
    }

    function submitTokenToEthOrder(uint128 srcAmount, uint128 dstAmount)
        public
        returns(bool)
    {

        return submitTokenToEthOrderWHint(srcAmount, dstAmount, 0);
    }

    function submitTokenToEthOrderWHint(uint128 srcAmount, uint128 dstAmount, uint32 hintPrevOrder)
        public
        returns(bool)
    {

        uint32 newId = fetchNewOrderId(makerOrdersTokenToEth[msg.sender]);
        return addOrder(false, newId, srcAmount, dstAmount, hintPrevOrder);
    }

    function submitEthToTokenOrder(uint128 srcAmount, uint128 dstAmount)
        public
        returns(bool)
    {

        return submitEthToTokenOrderWHint(srcAmount, dstAmount, 0);
    }

    function submitEthToTokenOrderWHint(uint128 srcAmount, uint128 dstAmount, uint32 hintPrevOrder)
        public
        returns(bool)
    {

        uint32 newId = fetchNewOrderId(makerOrdersEthToToken[msg.sender]);
        return addOrder(true, newId, srcAmount, dstAmount, hintPrevOrder);
    }

    function addOrderBatch(bool[] isEthToToken, uint128[] srcAmount, uint128[] dstAmount,
        uint32[] hintPrevOrder, bool[] isAfterPrevOrder)
        public
        returns(bool)
    {

        require(isEthToToken.length == hintPrevOrder.length);
        require(isEthToToken.length == dstAmount.length);
        require(isEthToToken.length == srcAmount.length);
        require(isEthToToken.length == isAfterPrevOrder.length);

        address maker = msg.sender;
        uint32 prevId;
        uint32 newId = 0;

        for (uint i = 0; i < isEthToToken.length; ++i) {
            prevId = isAfterPrevOrder[i] ? newId : hintPrevOrder[i];
            newId = fetchNewOrderId(isEthToToken[i] ? makerOrdersEthToToken[maker] : makerOrdersTokenToEth[maker]);
            require(addOrder(isEthToToken[i], newId, srcAmount[i], dstAmount[i], prevId));
        }

        return true;
    }

    function updateTokenToEthOrder(uint32 orderId, uint128 newSrcAmount, uint128 newDstAmount)
        public
        returns(bool)
    {

        require(updateTokenToEthOrderWHint(orderId, newSrcAmount, newDstAmount, 0));
        return true;
    }

    function updateTokenToEthOrderWHint(
        uint32 orderId,
        uint128 newSrcAmount,
        uint128 newDstAmount,
        uint32 hintPrevOrder
    )
        public
        returns(bool)
    {

        require(updateOrder(false, orderId, newSrcAmount, newDstAmount, hintPrevOrder));
        return true;
    }

    function updateEthToTokenOrder(uint32 orderId, uint128 newSrcAmount, uint128 newDstAmount)
        public
        returns(bool)
    {

        return updateEthToTokenOrderWHint(orderId, newSrcAmount, newDstAmount, 0);
    }

    function updateEthToTokenOrderWHint(
        uint32 orderId,
        uint128 newSrcAmount,
        uint128 newDstAmount,
        uint32 hintPrevOrder
    )
        public
        returns(bool)
    {

        require(updateOrder(true, orderId, newSrcAmount, newDstAmount, hintPrevOrder));
        return true;
    }

    function updateOrderBatch(bool[] isEthToToken, uint32[] orderId, uint128[] newSrcAmount,
        uint128[] newDstAmount, uint32[] hintPrevOrder)
        public
        returns(bool)
    {

        require(isEthToToken.length == orderId.length);
        require(isEthToToken.length == newSrcAmount.length);
        require(isEthToToken.length == newDstAmount.length);
        require(isEthToToken.length == hintPrevOrder.length);

        for (uint i = 0; i < isEthToToken.length; ++i) {
            require(updateOrder(isEthToToken[i], orderId[i], newSrcAmount[i], newDstAmount[i],
                hintPrevOrder[i]));
        }

        return true;
    }

    event TokenDeposited(address indexed maker, uint amount);

    function depositToken(address maker, uint amount) public {

        require(maker != address(0));
        require(amount < MAX_QTY);

        require(contracts.token.transferFrom(msg.sender, this, amount));

        makerFunds[maker][contracts.token] += amount;
        TokenDeposited(maker, amount);
    }

    event EtherDeposited(address indexed maker, uint amount);

    function depositEther(address maker) public payable {

        require(maker != address(0));

        makerFunds[maker][ETH_TOKEN_ADDRESS] += msg.value;
        EtherDeposited(maker, msg.value);
    }

    event KncFeeDeposited(address indexed maker, uint amount);

    function depositKncForFee(address maker, uint amount) public {

        require(maker != address(0));
        require(amount < MAX_QTY);

        require(contracts.kncToken.transferFrom(msg.sender, this, amount));

        makerKnc[maker] += amount;

        KncFeeDeposited(maker, amount);

        if (orderAllocationRequired(makerOrdersTokenToEth[maker])) {
            require(allocateOrderIds(
                makerOrdersTokenToEth[maker], /* makerOrders */
                tokenToEthList.allocateIds(uint32(NUM_ORDERS)) /* firstAllocatedId */
            ));
        }

        if (orderAllocationRequired(makerOrdersEthToToken[maker])) {
            require(allocateOrderIds(
                makerOrdersEthToToken[maker], /* makerOrders */
                ethToTokenList.allocateIds(uint32(NUM_ORDERS)) /* firstAllocatedId */
            ));
        }
    }

    function withdrawToken(uint amount) public {


        address maker = msg.sender;
        uint makerFreeAmount = makerFunds[maker][contracts.token];

        require(makerFreeAmount >= amount);

        makerFunds[maker][contracts.token] -= amount;

        require(contracts.token.transfer(maker, amount));
    }

    function withdrawEther(uint amount) public {


        address maker = msg.sender;
        uint makerFreeAmount = makerFunds[maker][ETH_TOKEN_ADDRESS];

        require(makerFreeAmount >= amount);

        makerFunds[maker][ETH_TOKEN_ADDRESS] -= amount;

        maker.transfer(amount);
    }

    function withdrawKncFee(uint amount) public {


        address maker = msg.sender;
        
        require(makerKnc[maker] >= amount);
        require(makerUnlockedKnc(maker) >= amount);

        makerKnc[maker] -= amount;

        require(contracts.kncToken.transfer(maker, amount));
    }

    function cancelTokenToEthOrder(uint32 orderId) public returns(bool) {

        require(cancelOrder(false, orderId));
        return true;
    }

    function cancelEthToTokenOrder(uint32 orderId) public returns(bool) {

        require(cancelOrder(true, orderId));
        return true;
    }

    function setMinOrderSizeEth() public returns(bool) {

        bytes32 usdPerEthInWei;
        bool valid;
        (usdPerEthInWei, valid) = contracts.medianizer.peek();
        require(valid);

        uint usdPerEth = uint(usdPerEthInWei) / (1 ether);
        require(usdPerEth != 0);
        require(usdPerEth < MAX_USD_PER_ETH);

        uint minNewOrderSizeWei = limits.minNewOrderSizeUsd * PRECISION * (1 ether) / uint(usdPerEthInWei);

        limits.minNewOrderSizeWei = minNewOrderSizeWei;
        limits.minOrderSizeWei = limits.minNewOrderSizeWei / MIN_REMAINING_ORDER_RATIO;

        return true;
    }

    function kncRateBlocksTrade() public view returns (bool) {

        return (contracts.feeBurner.kncPerEthRatePrecision() > kncPerEthBaseRatePrecision * BURN_TO_STAKE_FACTOR);
    }

    function getTokenToEthAddOrderHint(uint128 srcAmount, uint128 dstAmount) public view returns (uint32) {

        require(dstAmount >= limits.minNewOrderSizeWei);
        return tokenToEthList.findPrevOrderId(srcAmount, dstAmount);
    }

    function getEthToTokenAddOrderHint(uint128 srcAmount, uint128 dstAmount) public view returns (uint32) {

        require(srcAmount >= limits.minNewOrderSizeWei);
        return ethToTokenList.findPrevOrderId(srcAmount, dstAmount);
    }

    function getTokenToEthUpdateOrderHint(uint32 orderId, uint128 srcAmount, uint128 dstAmount)
        public
        view
        returns (uint32)
    {

        require(dstAmount >= limits.minNewOrderSizeWei);
        uint32 prevId = tokenToEthList.findPrevOrderId(srcAmount, dstAmount);
        address add;
        uint128 noUse;
        uint32 next;

        if (prevId == orderId) {
            (add, noUse, noUse, prevId, next) = tokenToEthList.getOrderDetails(orderId);
        }

        return prevId;
    }

    function getEthToTokenUpdateOrderHint(uint32 orderId, uint128 srcAmount, uint128 dstAmount)
        public
        view
        returns (uint32)
    {

        require(srcAmount >= limits.minNewOrderSizeWei);
        uint32 prevId = ethToTokenList.findPrevOrderId(srcAmount, dstAmount);
        address add;
        uint128 noUse;
        uint32 next;

        if (prevId == orderId) {
            (add, noUse, noUse, prevId, next) = ethToTokenList.getOrderDetails(orderId);
        }

        return prevId;
    }

    function getTokenToEthOrder(uint32 orderId)
        public view
        returns (
            address _maker,
            uint128 _srcAmount,
            uint128 _dstAmount,
            uint32 _prevId,
            uint32 _nextId
        )
    {

        return tokenToEthList.getOrderDetails(orderId);
    }

    function getEthToTokenOrder(uint32 orderId)
        public view
        returns (
            address _maker,
            uint128 _srcAmount,
            uint128 _dstAmount,
            uint32 _prevId,
            uint32 _nextId
        )
    {

        return ethToTokenList.getOrderDetails(orderId);
    }

    function makerRequiredKncStake(address maker) public view returns (uint) {

        return(calcKncStake(makerTotalOrdersWei[maker]));
    }

    function makerUnlockedKnc(address maker) public view returns (uint) {

        uint requiredKncStake = makerRequiredKncStake(maker);
        if (requiredKncStake > makerKnc[maker]) return 0;
        return (makerKnc[maker] - requiredKncStake);
    }

    function calcKncStake(uint weiAmount) public view returns(uint) {

        return(calcBurnAmount(weiAmount) * BURN_TO_STAKE_FACTOR);
    }

    function calcBurnAmount(uint weiAmount) public view returns(uint) {

        return(weiAmount * makerBurnFeeBps * kncPerEthBaseRatePrecision / (10000 * PRECISION));
    }

    function calcBurnAmountFromFeeBurner(uint weiAmount) public view returns(uint) {

        return(weiAmount * makerBurnFeeBps * contracts.feeBurner.kncPerEthRatePrecision() / (10000 * PRECISION));
    }

    function getEthToTokenMakerOrderIds(address maker) public view returns(uint32[] orderList) {

        OrderIdData storage makerOrders = makerOrdersEthToToken[maker];
        orderList = new uint32[](getNumActiveOrderIds(makerOrders));
        uint activeOrder = 0;

        for (uint32 i = 0; i < NUM_ORDERS; ++i) {
            if ((makerOrders.takenBitmap & (uint(1) << i) > 0)) orderList[activeOrder++] = makerOrders.firstOrderId + i;
        }
    }

    function getTokenToEthMakerOrderIds(address maker) public view returns(uint32[] orderList) {

        OrderIdData storage makerOrders = makerOrdersTokenToEth[maker];
        orderList = new uint32[](getNumActiveOrderIds(makerOrders));
        uint activeOrder = 0;

        for (uint32 i = 0; i < NUM_ORDERS; ++i) {
            if ((makerOrders.takenBitmap & (uint(1) << i) > 0)) orderList[activeOrder++] = makerOrders.firstOrderId + i;
        }
    }

    function getEthToTokenOrderList() public view returns(uint32[] orderList) {

        OrderListInterface list = ethToTokenList;
        return getList(list);
    }

    function getTokenToEthOrderList() public view returns(uint32[] orderList) {

        OrderListInterface list = tokenToEthList;
        return getList(list);
    }

    event NewLimitOrder(
        address indexed maker,
        uint32 orderId,
        bool isEthToToken,
        uint128 srcAmount,
        uint128 dstAmount,
        bool addedWithHint
    );

    function addOrder(bool isEthToToken, uint32 newId, uint128 srcAmount, uint128 dstAmount, uint32 hintPrevOrder)
        internal
        returns(bool)
    {

        require(srcAmount < MAX_QTY);
        require(dstAmount < MAX_QTY);
        address maker = msg.sender;

        require(secureAddOrderFunds(maker, isEthToToken, srcAmount, dstAmount));
        require(validateLegalRate(srcAmount, dstAmount, isEthToToken));

        bool addedWithHint = false;
        OrderListInterface list = isEthToToken ? ethToTokenList : tokenToEthList;

        if (hintPrevOrder != 0) {
            addedWithHint = list.addAfterId(maker, newId, srcAmount, dstAmount, hintPrevOrder);
        }

        if (!addedWithHint) {
            require(list.add(maker, newId, srcAmount, dstAmount));
        }

        NewLimitOrder(maker, newId, isEthToToken, srcAmount, dstAmount, addedWithHint);

        return true;
    }

    event OrderUpdated(
        address indexed maker,
        bool isEthToToken,
        uint orderId,
        uint128 srcAmount,
        uint128 dstAmount,
        bool updatedWithHint
    );

    function updateOrder(bool isEthToToken, uint32 orderId, uint128 newSrcAmount,
        uint128 newDstAmount, uint32 hintPrevOrder)
        internal
        returns(bool)
    {

        require(newSrcAmount < MAX_QTY);
        require(newDstAmount < MAX_QTY);
        address maker;
        uint128 currDstAmount;
        uint128 currSrcAmount;
        uint32 noUse;
        uint noUse2;

        require(validateLegalRate(newSrcAmount, newDstAmount, isEthToToken));

        OrderListInterface list = isEthToToken ? ethToTokenList : tokenToEthList;

        (maker, currSrcAmount, currDstAmount, noUse, noUse) = list.getOrderDetails(orderId);
        require(maker == msg.sender);

        if (!secureUpdateOrderFunds(maker, isEthToToken, currSrcAmount, currDstAmount, newSrcAmount, newDstAmount)) {
            return false;
        }

        bool updatedWithHint = false;

        if (hintPrevOrder != 0) {
            (updatedWithHint, noUse2) = list.updateWithPositionHint(orderId, newSrcAmount, newDstAmount, hintPrevOrder);
        }

        if (!updatedWithHint) {
            require(list.update(orderId, newSrcAmount, newDstAmount));
        }

        OrderUpdated(maker, isEthToToken, orderId, newSrcAmount, newDstAmount, updatedWithHint);

        return true;
    }

    event OrderCanceled(address indexed maker, bool isEthToToken, uint32 orderId, uint128 srcAmount, uint dstAmount);

    function cancelOrder(bool isEthToToken, uint32 orderId) internal returns(bool) {


        address maker = msg.sender;
        OrderListInterface list = isEthToToken ? ethToTokenList : tokenToEthList;
        OrderData memory orderData = getOrderData(list, orderId);

        require(orderData.maker == maker);

        uint weiAmount = isEthToToken ? orderData.srcAmount : orderData.dstAmount;
        require(releaseOrderStakes(maker, weiAmount, 0));

        require(removeOrder(list, maker, isEthToToken ? ETH_TOKEN_ADDRESS : contracts.token, orderId));

        makerFunds[maker][isEthToToken ? ETH_TOKEN_ADDRESS : contracts.token] += orderData.srcAmount;

        OrderCanceled(maker, isEthToToken, orderId, orderData.srcAmount, orderData.dstAmount);

        return true;
    }

    function bindOrderFunds(address maker, bool isEthToToken, int srcAmount)
        internal
        returns(bool)
    {

        address fundsAddress = isEthToToken ? ETH_TOKEN_ADDRESS : contracts.token;

        if (srcAmount < 0) {
            makerFunds[maker][fundsAddress] += uint(-srcAmount);
        } else {
            require(makerFunds[maker][fundsAddress] >= uint(srcAmount));
            makerFunds[maker][fundsAddress] -= uint(srcAmount);
        }

        return true;
    }

    function bindOrderStakes(address maker, int weiAmount) internal returns(bool) {


        if (weiAmount < 0) {
            uint decreaseWeiAmount = uint(-weiAmount);
            if (decreaseWeiAmount > makerTotalOrdersWei[maker]) decreaseWeiAmount = makerTotalOrdersWei[maker];
            makerTotalOrdersWei[maker] -= decreaseWeiAmount;
            return true;
        }

        require(makerKnc[maker] >= calcKncStake(makerTotalOrdersWei[maker] + uint(weiAmount)));

        makerTotalOrdersWei[maker] += uint(weiAmount);

        return true;
    }

    function releaseOrderStakes(address maker, uint totalWeiAmount, uint weiForBurn) internal returns(bool) {


        require(weiForBurn <= totalWeiAmount);

        if (totalWeiAmount > makerTotalOrdersWei[maker]) {
            makerTotalOrdersWei[maker] = 0;
        } else {
            makerTotalOrdersWei[maker] -= totalWeiAmount;
        }

        if (weiForBurn == 0) return true;

        uint burnAmount = calcBurnAmountFromFeeBurner(weiForBurn);

        require(makerKnc[maker] >= burnAmount);
        makerKnc[maker] -= burnAmount;

        return true;
    }

    function secureAddOrderFunds(address maker, bool isEthToToken, uint128 srcAmount, uint128 dstAmount)
        internal returns(bool)
    {

        uint weiAmount = isEthToToken ? srcAmount : dstAmount;

        require(weiAmount >= limits.minNewOrderSizeWei);
        require(bindOrderFunds(maker, isEthToToken, int(srcAmount)));
        require(bindOrderStakes(maker, int(weiAmount)));

        return true;
    }

    function secureUpdateOrderFunds(address maker, bool isEthToToken, uint128 prevSrcAmount, uint128 prevDstAmount,
        uint128 newSrcAmount, uint128 newDstAmount)
        internal
        returns(bool)
    {

        uint weiAmount = isEthToToken ? newSrcAmount : newDstAmount;
        int weiDiff = isEthToToken ? (int(newSrcAmount) - int(prevSrcAmount)) :
            (int(newDstAmount) - int(prevDstAmount));

        require(weiAmount >= limits.minNewOrderSizeWei);

        require(bindOrderFunds(maker, isEthToToken, int(newSrcAmount) - int(prevSrcAmount)));

        require(bindOrderStakes(maker, weiDiff));

        return true;
    }

    event FullOrderTaken(address maker, uint32 orderId, bool isEthToToken);

    function takeFullOrder(
        address maker,
        uint32 orderId,
        ERC20 userSrc,
        ERC20 userDst,
        uint128 userSrcAmount,
        uint128 userDstAmount
    )
        internal
        returns (bool)
    {

        OrderListInterface list = (userSrc == ETH_TOKEN_ADDRESS) ? tokenToEthList : ethToTokenList;

        require(removeOrder(list, maker, userDst, orderId));

        FullOrderTaken(maker, orderId, userSrc == ETH_TOKEN_ADDRESS);

        return takeOrder(maker, userSrc, userSrcAmount, userDstAmount, 0);
    }

    event PartialOrderTaken(address maker, uint32 orderId, bool isEthToToken, bool isRemoved);

    function takePartialOrder(
        address maker,
        uint32 orderId,
        ERC20 userSrc,
        ERC20 userDst,
        uint128 userPartialSrcAmount,
        uint128 userTakeDstAmount,
        uint128 orderSrcAmount,
        uint128 orderDstAmount
    )
        internal
        returns(bool)
    {

        require(userPartialSrcAmount < orderDstAmount);
        require(userTakeDstAmount < orderSrcAmount);

        orderSrcAmount -= userTakeDstAmount;
        orderDstAmount -= userPartialSrcAmount;

        OrderListInterface list = (userSrc == ETH_TOKEN_ADDRESS) ? tokenToEthList : ethToTokenList;
        uint weiValueNotReleasedFromOrder = (userSrc == ETH_TOKEN_ADDRESS) ? orderDstAmount : orderSrcAmount;
        uint additionalReleasedWei = 0;

        if (weiValueNotReleasedFromOrder < limits.minOrderSizeWei) {
            makerFunds[maker][userDst] += orderSrcAmount;
            additionalReleasedWei = weiValueNotReleasedFromOrder;

            require(removeOrder(list, maker, userDst, orderId));
        } else {
            bool isSuccess;

            (isSuccess,) = list.updateWithPositionHint(orderId, orderSrcAmount, orderDstAmount, HEAD_ID);
            require(isSuccess);
        }

        PartialOrderTaken(maker, orderId, userSrc == ETH_TOKEN_ADDRESS, additionalReleasedWei > 0);

        return(takeOrder(maker, userSrc, userPartialSrcAmount, userTakeDstAmount, additionalReleasedWei));
    }
    
    function takeOrder(
        address maker,
        ERC20 userSrc,
        uint userSrcAmount,
        uint userDstAmount,
        uint additionalReleasedWei
    )
        internal
        returns(bool)
    {

        uint weiAmount = userSrc == (ETH_TOKEN_ADDRESS) ? userSrcAmount : userDstAmount;

        makerFunds[maker][userSrc] += userSrcAmount;

        return releaseOrderStakes(maker, (weiAmount + additionalReleasedWei), weiAmount);
    }

    function removeOrder(
        OrderListInterface list,
        address maker,
        ERC20 makerSrc,
        uint32 orderId
    )
        internal returns(bool)
    {

        require(list.remove(orderId));
        OrderIdData storage orders = (makerSrc == ETH_TOKEN_ADDRESS) ?
            makerOrdersEthToToken[maker] : makerOrdersTokenToEth[maker];
        require(releaseOrderId(orders, orderId));

        return true;
    }

    function getList(OrderListInterface list) internal view returns(uint32[] memory orderList) {

        OrderData memory orderData;
        uint32 orderId;
        bool isEmpty;

        (orderId, isEmpty) = list.getFirstOrder();
        if (isEmpty) return(new uint32[](0));

        uint numOrders = 0;

        for (; !orderData.isLastOrder; orderId = orderData.nextId) {
            orderData = getOrderData(list, orderId);
            numOrders++;
        }

        orderList = new uint32[](numOrders);

        (orderId, orderData.isLastOrder) = list.getFirstOrder();

        for (uint i = 0; i < numOrders; i++) {
            orderList[i] = orderId;
            orderData = getOrderData(list, orderId);
            orderId = orderData.nextId;
        }
    }

    function getOrderData(OrderListInterface list, uint32 orderId) internal view returns (OrderData data) {

        uint32 prevId;
        (data.maker, data.srcAmount, data.dstAmount, prevId, data.nextId) = list.getOrderDetails(orderId);
        data.isLastOrder = (data.nextId == TAIL_ID);
    }

    function validateLegalRate (uint srcAmount, uint dstAmount, bool isEthToToken)
        internal view returns(bool)
    {
        uint rate;

        if (isEthToToken) {
            rate = calcRateFromQty(dstAmount, srcAmount, getDecimals(contracts.token), ETH_DECIMALS);
        } else {
            rate = calcRateFromQty(dstAmount, srcAmount, ETH_DECIMALS, getDecimals(contracts.token));
        }

        if (rate > MAX_RATE) return false;
        return true;
    }
}


contract Wrapper is Utils {


    function getBalances(address reserve, ERC20[] tokens) public view returns(uint[]) {

        uint[] memory result = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            uint balance = 0;
            if (tokens[i] == ETH_TOKEN_ADDRESS) {
                balance = reserve.balance;
            } else {
                balance = tokens[i].balanceOf(reserve);
            }

            result[i] = balance;
        }

        return result;
    }

    function getByteFromBytes14(bytes14 x, uint byteInd) public pure returns(byte) {

        require(byteInd <= 13);
        return x[byteInd];
    }

    function getInt8FromByte(bytes14 x, uint byteInd) public pure returns(int8) {

        require(byteInd <= 13);
        return int8(x[byteInd]);
    }


    function getCompactData(ConversionRates ratesContract, ERC20 token) internal view returns(int8,int8,uint) {

        uint bulkIndex; uint index; byte buy; byte sell; uint updateBlock;
        (bulkIndex, index, buy, sell) = ratesContract.getCompactData(token);
        updateBlock = ratesContract.getRateUpdateBlock(token);

        return (int8(buy), int8(sell), updateBlock);
    }

    function getTokenRates(ConversionRates ratesContract, ERC20[] tokenList)
        public view
        returns(uint[], uint[], int8[], int8[], uint[])
    {

        uint[] memory buyBases = new uint[](tokenList.length);
        uint[] memory sellBases = new uint[](tokenList.length);
        int8[] memory compactBuy = new int8[](tokenList.length);
        int8[] memory compactSell = new int8[](tokenList.length);
        uint[] memory updateBlock = new uint[](tokenList.length);

        for (uint i = 0;  i < tokenList.length; i++) {
            buyBases[i] = ratesContract.getBasicRate(tokenList[i], true);
            sellBases[i] = ratesContract.getBasicRate(tokenList[i], false);

            (compactBuy[i], compactSell[i], updateBlock[i]) = getCompactData(ratesContract, tokenList[i]);
        }

        return (buyBases, sellBases, compactBuy, compactSell, updateBlock);
    }

    function getTokenIndicies(ConversionRates ratesContract, ERC20[] tokenList) public view returns(uint[], uint[]) {

        uint[] memory bulkIndices = new uint[](tokenList.length);
        uint[] memory tokenIndexInBulk = new uint[](tokenList.length);

        for (uint i = 0; i < tokenList.length; i++) {
            uint bulkIndex; uint index; byte buy; byte sell;
            (bulkIndex, index, buy, sell) = ratesContract.getCompactData(tokenList[i]);

            bulkIndices[i] = bulkIndex;
            tokenIndexInBulk[i] = index;
        }

        return (bulkIndices,tokenIndexInBulk);
    }


    function getExpectedRates( KyberNetwork network, ERC20[] srcs, ERC20[] dests, uint[] qty )
        public view returns(uint[], uint[])
    {

        require( srcs.length == dests.length );
        require( srcs.length == dests.length );

        uint[] memory rates = new uint[](srcs.length);
        uint[] memory slippage = new uint[](srcs.length);
        for ( uint i = 0; i < srcs.length; i++ ) {
            (rates[i],slippage[i]) = network.getExpectedRate(srcs[i],dests[i],qty[i]);
        }

        return (rates, slippage);
    }

    function getReserveRate(KyberReserve reserve, ERC20[] srcs, ERC20[] dests)
        public view returns(uint[], uint[])
    {

        require( srcs.length == dests.length );
        require( srcs.length == dests.length );

        uint[] memory rates      = new uint[](srcs.length);
        uint[] memory sanityRate = new uint[](srcs.length);

        for(uint i = 0 ; i < srcs.length ; i++) {
            if(reserve.sanityRatesContract() != address(0x0)){
                sanityRate[i] = reserve.sanityRatesContract().getSanityRate(srcs[i],
                                                                            dests[i]);
            }
            rates[i] = reserve.getConversionRate(srcs[i],
                                                 dests[i],
                                                 0,
                                                 block.number);
        }

        return (rates,sanityRate);
    }

    function getListPermissionlessData(KyberNetworkProxy networkProxy, uint startIndex, uint endIndex)
      public
      view
      returns (KyberReserveInterface[] memory permissionlessReserves, ERC20[] memory permissionlessTokens, uint[] memory decimals, bool isEnded)
    {

        KyberNetwork network = KyberNetwork(networkProxy.kyberNetworkContract());
        uint numReserves = network.getNumReserves();
        if (startIndex >= numReserves || startIndex > endIndex) {
            permissionlessReserves = new KyberReserveInterface[](0);
            permissionlessTokens = new ERC20[](0);
            decimals = new uint[](0);
            isEnded = true;
            return (permissionlessReserves, permissionlessTokens, decimals, isEnded);
        }
        uint endIterator = numReserves <= endIndex ? numReserves - 1 : endIndex;
        uint numberTokens = 0;
        uint rID; // reserveID
        ERC20 token;
        KyberReserveInterface reserve;
        for(rID = startIndex; rID <= endIterator; rID++) {
            reserve = network.reserves(rID);
            if ( reserve != address(0)
              && network.reserveType(reserve) == KyberNetwork.ReserveType.PERMISSIONLESS)
            {
                (, token , , , ,) = OrderbookReserve(reserve).contracts();
                if (token != address(0)) { numberTokens += 1; }
            }
        }
        permissionlessReserves = new KyberReserveInterface[](numberTokens);
        permissionlessTokens = new ERC20[](numberTokens);
        decimals = new uint[](numberTokens);
        numberTokens = 0;
        for(rID = startIndex; rID <= endIterator; rID++) {
            reserve = network.reserves(rID);
            if ( reserve != address(0)
              && network.reserveType(reserve) == KyberNetwork.ReserveType.PERMISSIONLESS)
            {
                (, token , , , ,) = OrderbookReserve(reserve).contracts();
                if (token != address(0)) {
                    permissionlessReserves[numberTokens] = reserve;
                    permissionlessTokens[numberTokens] = token;
                    decimals[numberTokens] = getDecimals(token);
                    numberTokens += 1;
                }
            }
        }
        isEnded = endIterator == numReserves - 1;
        return (permissionlessReserves, permissionlessTokens, decimals, isEnded);
    }
}