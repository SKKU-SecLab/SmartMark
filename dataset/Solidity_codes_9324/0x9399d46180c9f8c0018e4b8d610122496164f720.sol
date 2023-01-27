
pragma solidity =0.8.12;

contract LiquidBase {


    uint256 public constant PRECISION_R = 100E18;

    uint256 public constant FEE = 10E18;

    uint256 public constant DEADLINE_TIME = 7 days;

    uint256 public constant CONTRIBUTION_TIME = 5 days;

    uint256 public constant SECONDS_IN_DAY = 86400;

    address public constant FACTORY_ADDRESS = 0x9961f05a53A1944001C0dF650A5aFF65B21A37D0;

    address public constant TRUSTEE_MULTISIG = 0xfEc4264F728C056bD528E9e012cf4D943bd92b53;

    address public constant PAYMENT_TOKEN = 0x66a0f676479Cee1d7373f3DC2e2952778BfF5bd6;

    address constant ZERO_ADDRESS = address(0);

    struct Globals {
        uint256[] tokenId;
        uint256 paymentTime;
        uint256 paymentRate;
        address lockerOwner;
        address tokenAddress;
    }

    Globals public globals;

    address public singleProvider;

    uint256 public floorAsked;

    uint256 public totalAsked;

    uint256 public totalCollected;

    uint256 public claimableBalance;

    uint256 public remainingBalance;

    uint256 public nextDueTime;

    uint256 public creationTime;

    mapping(address => uint256) public contributions;

    mapping(address => uint256) public compensations;

    event SingleProvider(
        address singleProvider
    );

    event PaymentMade(
        uint256 paymentAmount,
        address paymentAddress
    );

    event RefundMade(
        uint256 refundAmount,
        address refundAddress
    );

    event ClaimMade(
        uint256 claimAmount,
        address claimAddress
    );

    event Liquidated(
        address liquidatorAddress
    );

    event PaymentRateIncrease(
        uint256 newRateIncrease
    );

    event PaymentTimeDecrease(
        uint256 newPaymentTime
    );
}

pragma solidity =0.8.12;


contract LiquidHelper is LiquidBase {


    bytes4 constant TRANSFER = bytes4(
        keccak256(
            bytes(
                "transfer(address,uint256)"
            )
        )
    );

    bytes4 constant TRANSFER_FROM = bytes4(
        keccak256(
            bytes(
                "transferFrom(address,address,uint256)"
            )
        )
    );

    function getTokens()
        public
        view
        returns (uint256[] memory)
    {

        return globals.tokenId;
    }

    function floorNotReached()
        public
        view
        returns (bool)
    {

        return contributionPhase() == false && belowFloorAsked() == true;
    }

    function notSingleProvider(
        address _checkAddress
    )
        public
        view
        returns (bool)
    {

        address provider = singleProvider;
        return
            provider != _checkAddress &&
            provider != ZERO_ADDRESS;
    }

    function reachedTotal(
        address _contributor,
        uint256 _tokenAmount
    )
        public
        view
        returns (bool)
    {

        return contributions[_contributor] + _tokenAmount >= totalAsked;
    }

    function missedActivate()
        public
        view
        returns (bool)
    {

        return
            floorNotReached() &&
            startingTimestamp() + DEADLINE_TIME < block.timestamp;
    }

    function missedDeadline()
        public
        view
        returns (bool)
    {

        uint256 nextDueOrDeadline = nextDueTime > paybackTimestamp()
            ? paybackTimestamp()
            : nextDueTime;

        return
            nextDueTime > 0 &&
            nextDueOrDeadline + DEADLINE_TIME < block.timestamp;
    }

    function belowFloorAsked()
        public
        view
        returns (bool)
    {

        return totalCollected < floorAsked;
    }

    function paymentTimeNotSet()
        public
        view
        returns (bool)
    {

        return nextDueTime == 0;
    }

    function contributionPhase()
        public
        view
        returns (bool)
    {

        return timeSince(creationTime) < CONTRIBUTION_TIME;
    }

    function paybackTimestamp()
        public
        view
        returns (uint256)
    {

        return startingTimestamp() + globals.paymentTime;
    }

    function startingTimestamp()
        public
        view
        returns (uint256)
    {

        return creationTime + CONTRIBUTION_TIME;
    }

    function liquidateTo()
        public
        view
        returns (address)
    {

        return singleProvider == ZERO_ADDRESS
            ? TRUSTEE_MULTISIG
            : singleProvider;
    }

    function ownerlessLocker()
        public
        view
        returns (bool)
    {

        return globals.lockerOwner == ZERO_ADDRESS;
    }

    function timeSince(
        uint256 _timeStamp
    )
        public
        view
        returns (uint256)
    {

        return block.timestamp - _timeStamp;
    }

    function _revokeDueTime()
        internal
    {

        nextDueTime = 0;
    }

    function _increaseContributions(
        address _contributorsAddress,
        uint256 _contributionAmount
    )
        internal
    {

        contributions[_contributorsAddress] =
        contributions[_contributorsAddress] + _contributionAmount;
    }

    function _increaseTotalCollected(
        uint256 _increaseAmount
    )
        internal
    {

        totalCollected =
        totalCollected + _increaseAmount;
    }

    function _decreaseTotalCollected(
        uint256 _decreaseAmount
    )
        internal
    {

        totalCollected =
        totalCollected - _decreaseAmount;
    }

    function _adjustBalances(
        uint256 _paymentTokens,
        uint256 _penaltyTokens
    )
        internal
    {

        claimableBalance = claimableBalance
            + _paymentTokens;

        uint256 newBalance = remainingBalance
            + _penaltyTokens;

        remainingBalance = _paymentTokens < newBalance
            ? newBalance - _paymentTokens : 0;
    }

    function _safeTransfer(
        address _token,
        address _to,
        uint256 _value
    )
        internal
    {

        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(
                TRANSFER,
                _to,
                _value
            )
        );

        require(
            success && (
                data.length == 0 || abi.decode(
                    data, (bool)
                )
            ),
            "LiquidHelper: TRANSFER_FAILED"
        );
    }

    function _safeTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    )
        internal
    {

        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(
                TRANSFER_FROM,
                _from,
                _to,
                _value
            )
        );

        require(
            success && (
                data.length == 0 || abi.decode(
                    data, (bool)
                )
            ),
            "LiquidHelper: TRANSFER_FROM_FAILED"
        );
    }
}

pragma solidity =0.8.12;

contract LiquidTransfer {


    address constant PUNKS = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;


    address constant KITTIES = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;

    function _transferNFT(
        address _from,
        address _to,
        address _tokenAddress,
        uint256 _tokenId
    )
        internal
    {

        bytes memory data;

        if (_tokenAddress == KITTIES) {
            data = abi.encodeWithSignature(
                "transfer(address,uint256)",
                _to,
                _tokenId
            );
        } else if (_tokenAddress == PUNKS) {
            data = abi.encodeWithSignature(
                "transferPunk(address,uint256)",
                _to,
                _tokenId
            );
        } else {
            data = abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                _from,
                _to,
                _tokenId
            );
        }

        (bool success,) = address(_tokenAddress).call(
            data
        );

        require(
            success == true,
            'NFT_TRANSFER_FAILED'
        );
    }

    function _transferFromNFT(
        address _from,
        address _to,
        address _tokenAddress,
        uint256 _tokenId
    )
        internal
    {

        bytes memory data;

        if (_tokenAddress == KITTIES) {
            data = abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                _from,
                _to,
                _tokenId
            );
        } else if (_tokenAddress == PUNKS) {
            bytes memory punkIndexToAddress = abi.encodeWithSignature(
                "punkIndexToAddress(uint256)",
                _tokenId
            );

            (bool checkSuccess, bytes memory result) = address(_tokenAddress).staticcall(
                punkIndexToAddress
            );

            (address owner) = abi.decode(
                result,
                (address)
            );

            require(
                checkSuccess &&
                owner == msg.sender,
                'INVALID_OWNER'
            );

            bytes memory buyData = abi.encodeWithSignature(
                "buyPunk(uint256)",
                _tokenId
            );

            (bool buySuccess, bytes memory buyResultData) = address(_tokenAddress).call(
                buyData
            );

            require(
                buySuccess,
                string(buyResultData)
            );

            data = abi.encodeWithSignature(
                "transferPunk(address,uint256)",
                _to,
                _tokenId
            );

        } else {
            data = abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                _from,
                _to,
                _tokenId
            );
        }

        (bool success, bytes memory resultData) = address(_tokenAddress).call(
            data
        );

        require(
            success,
            string(resultData)
        );
    }

    event ERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    )
        external
        returns (bytes4)
    {

        emit ERC721Received(
            _operator,
            _from,
            _tokenId,
            _data
        );

        return this.onERC721Received.selector;
    }
}

pragma solidity =0.8.12;


contract LiquidLocker is LiquidTransfer, LiquidHelper {


    modifier onlyLockerOwner() {

        require(
           msg.sender == globals.lockerOwner,
           "LiquidLocker: INVALID_OWNER"
        );
        _;
    }

    modifier onlyFromFactory() {

        require(
            msg.sender == FACTORY_ADDRESS,
            "LiquidLocker: INVALID_ADDRESS"
        );
        _;
    }

    modifier onlyDuringContributionPhase() {

        require(
            contributionPhase() == true &&
            paymentTimeNotSet() == true,
            "LiquidLocker: INVALID_PHASE"
        );
        _;
    }

    function initialize(
        uint256[] calldata _tokenId,
        address _tokenAddress,
        address _tokenOwner,
        uint256 _floorAsked,
        uint256 _totalAsked,
        uint256 _paymentTime,
        uint256 _paymentRate
    )
        external
        onlyFromFactory
    {

        globals = Globals({
            tokenId: _tokenId,
            lockerOwner: _tokenOwner,
            tokenAddress: _tokenAddress,
            paymentTime: _paymentTime,
            paymentRate: _paymentRate
        });

        floorAsked = _floorAsked;
        totalAsked = _totalAsked;
        creationTime = block.timestamp;
    }

    function increasePaymentRate(
        uint256 _newPaymntRate
    )
        external
        onlyLockerOwner
        onlyDuringContributionPhase
    {

        require(
            _newPaymntRate > globals.paymentRate,
            "LiquidLocker: INVALID_INCREASE"
        );

        globals.paymentRate = _newPaymntRate;

        emit PaymentRateIncrease(
            _newPaymntRate
        );
    }

    function decreasePaymentTime(
        uint256 _newPaymentTime
    )
        external
        onlyLockerOwner
        onlyDuringContributionPhase
    {

        require(
            _newPaymentTime < globals.paymentTime,
            "LiquidLocker: INVALID_DECREASE"
        );

        globals.paymentTime = _newPaymentTime;

        emit PaymentTimeDecrease(
            _newPaymentTime
        );
    }

    function updateSettings(
        uint256 _newPaymntRate,
        uint256 _newPaymentTime
    )
        external
        onlyLockerOwner
        onlyDuringContributionPhase
    {

        require(
            _newPaymntRate > globals.paymentRate,
            "LiquidLocker: INVALID_RATE"
        );

        require(
            _newPaymentTime < globals.paymentTime,
            "LiquidLocker: INVALID_TIME"
        );

        globals.paymentRate = _newPaymntRate;
        globals.paymentTime = _newPaymentTime;

        emit PaymentRateIncrease(
            _newPaymntRate
        );

        emit PaymentTimeDecrease(
            _newPaymentTime
        );
    }

    function makeContribution(
        uint256 _tokenAmount,
        address _tokenHolder
    )
        external
        onlyFromFactory
        onlyDuringContributionPhase
        returns (
            uint256 totalIncrease,
            uint256 usersIncrease
        )
    {

        totalIncrease = _totalIncrease(
            _tokenAmount
        );

        usersIncrease = _usersIncrease(
            _tokenHolder,
            _tokenAmount,
            totalIncrease
        );

        _increaseContributions(
            _tokenHolder,
            usersIncrease
        );

        _increaseTotalCollected(
            totalIncrease
        );
    }

    function _usersIncrease(
        address _tokenHolder,
        uint256 _tokenAmount,
        uint256 _totalAmount
    )
        internal
        returns (uint256)
    {

        return reachedTotal(_tokenHolder, _tokenAmount)
            ? _reachedTotal(_tokenHolder)
            : _totalAmount;
    }

    function _totalIncrease(
        uint256 _tokenAmount
    )
        internal
        view
        returns (uint256 totalIncrease)
    {

        totalIncrease = totalCollected
            + _tokenAmount < totalAsked
            ? _tokenAmount : totalAsked - totalCollected;
    }

    function _reachedTotal(
        address _tokenHolder
    )
        internal
        returns (uint256 totalReach)
    {

        require(
            singleProvider == ZERO_ADDRESS,
            "LiquidLocker: PROVIDER_EXISTS"
        );

        totalReach =
        totalAsked - contributions[_tokenHolder];

        singleProvider = _tokenHolder;

        emit SingleProvider(
            _tokenHolder
        );
    }

    function enableLocker(
        uint256 _prepayAmount
    )
        external
        onlyLockerOwner
    {

        require(
            belowFloorAsked() == false,
            "LiquidLocker: BELOW_FLOOR"
        );

        require(
            paymentTimeNotSet() == true,
            "LiquidLocker: ENABLED_LOCKER"
        );

        (

        uint256 totalPayback,
        uint256 epochPayback,
        uint256 teamsPayback

        ) = calculatePaybacks(
            totalCollected,
            globals.paymentTime,
            globals.paymentRate
        );

        claimableBalance = claimableBalance
            + _prepayAmount;

        remainingBalance = totalPayback
            - _prepayAmount;

        nextDueTime = startingTimestamp()
            + _prepayAmount
            / epochPayback;

        _safeTransfer(
            PAYMENT_TOKEN,
            msg.sender,
            totalCollected - _prepayAmount - teamsPayback
        );

        _safeTransfer(
            PAYMENT_TOKEN,
            TRUSTEE_MULTISIG,
            teamsPayback
        );

        emit PaymentMade(
            _prepayAmount,
            msg.sender
        );
    }

    function disableLocker()
        external
        onlyLockerOwner
    {

        require(
            belowFloorAsked() == true,
            "LiquidLocker: FLOOR_REACHED"
        );

        _returnOwnerTokens();
    }

    function _returnOwnerTokens()
        internal
    {

        address lockerOwner = globals.lockerOwner;
        globals.lockerOwner = ZERO_ADDRESS;

        for (uint256 i = 0; i < globals.tokenId.length; i++) {
            _transferNFT(
                address(this),
                lockerOwner,
                globals.tokenAddress,
                globals.tokenId[i]
            );
        }
    }

    function rescueLocker()
        external
    {

        require(
            msg.sender == TRUSTEE_MULTISIG,
            "LiquidLocker: INVALID_TRUSTEE"
        );

        require(
            timeSince(creationTime) > DEADLINE_TIME,
            "LiquidLocker: NOT_ENOUGHT_TIME"
        );

        require(
            paymentTimeNotSet() == true,
           "LiquidLocker: ALREADY_STARTED"
        );

        _returnOwnerTokens();
    }

    function refundDueExpired(
        address _refundAddress
    )
        external
    {

        require(
            floorNotReached() == true ||
            ownerlessLocker() == true,
            "LiquidLocker: ENABLED_LOCKER"
        );

        uint256 tokenAmount = contributions[_refundAddress];

        _refundTokens(
            tokenAmount,
            _refundAddress
        );

        _decreaseTotalCollected(
            tokenAmount
        );
    }

    function refundDueSingle(
        address _refundAddress
    )
        external
    {

        require(
            notSingleProvider(_refundAddress) == true,
            "LiquidLocker: INVALID_SENDER"
        );

        _refundTokens(
            contributions[_refundAddress],
            _refundAddress
        );
    }

    function donateFunds(
        uint256 _donationAmount
    )
        external
        onlyFromFactory
    {

        claimableBalance =
        claimableBalance + _donationAmount;
    }

    function payBackFunds(
        uint256 _paymentAmount,
        address _paymentAddress
    )
        external
        onlyFromFactory
    {

        require(
            missedDeadline() == false,
            "LiquidLocker: TOO_LATE"
        );

        _adjustBalances(
            _paymentAmount,
            _penaltyAmount()
        );

        if (remainingBalance == 0) {

            _revokeDueTime();
            _returnOwnerTokens();

            return;
        }

        uint256 payedTimestamp = nextDueTime;
        uint256 finalTimestamp = paybackTimestamp();

        if (payedTimestamp == finalTimestamp) return;

        uint256 purchasedTime = _paymentAmount
            / calculateEpoch(
                totalCollected,
                globals.paymentTime,
                globals.paymentRate
            );

        require(
            purchasedTime >= SECONDS_IN_DAY,
            "LiquidLocker: Minimum Payoff"
        );

        payedTimestamp = payedTimestamp > block.timestamp
            ? payedTimestamp + purchasedTime
            : block.timestamp + purchasedTime;

        nextDueTime = payedTimestamp;

        emit PaymentMade(
            _paymentAmount,
            _paymentAddress
        );
    }

    function liquidateLocker()
        external
    {

        require(
            missedActivate() == true ||
            missedDeadline() == true,
            "LiquidLocker: TOO_EARLY"
        );

        _revokeDueTime();
        globals.lockerOwner = ZERO_ADDRESS;

        for (uint256 i = 0; i < globals.tokenId.length; i++) {
            _transferNFT(
                address(this),
                liquidateTo(),
                globals.tokenAddress,
                globals.tokenId[i]
            );
        }

        emit Liquidated(
            msg.sender
        );
    }

    function penaltyAmount(
        uint256 _totalCollected,
        uint256 _lateDaysAmount
    )
        external
        pure
        returns (uint256 result)
    {

        result = _getPenaltyAmount(
            _totalCollected,
            _lateDaysAmount
        );
    }

    function _penaltyAmount()
        internal
        view
        returns (uint256 amount)
    {

        amount = _getPenaltyAmount(
            totalCollected,
            getLateDays()
        );
    }

    function _getPenaltyAmount(
        uint256 _totalCollected,
        uint256 _lateDaysAmount
    )
        private
        pure
        returns (uint256 penalty)
    {

        penalty = _totalCollected
            * _daysBase(_lateDaysAmount)
            / 200;
    }

    function _daysBase(
        uint256 _daysAmount
    )
        internal
        pure
        returns (uint256 res)
    {

        res = _daysAmount > 4
            ? _daysAmount * 2 - 4
            : _daysAmount;
    }

    function getLateDays()
        public
        view
        returns (uint256 late)
    {

        late = block.timestamp > nextDueTime
            ? (block.timestamp - nextDueTime) / SECONDS_IN_DAY : 0;
    }

    function calculatePaybacks(
        uint256 _totalValue,
        uint256 _paymentTime,
        uint256 _paymentRate
    )
        public
        pure
        returns (
            uint256 totalPayback,
            uint256 epochPayback,
            uint256 teamsPayback
        )
    {

        totalPayback = (_paymentRate + PRECISION_R)
            * _totalValue
            / PRECISION_R;

        teamsPayback = (totalPayback - _totalValue)
            * FEE
            / PRECISION_R;

        epochPayback = (totalPayback - _totalValue)
            / _paymentTime;
    }

    function calculateEpoch(
        uint256 _totalValue,
        uint256 _paymentTime,
        uint256 _paymentRate
    )
        public
        pure
        returns (uint256 result)
    {

        result = _totalValue
            * _paymentRate
            / PRECISION_R
            / _paymentTime;
    }

    function claimInterest()
        external
    {

        address provider = singleProvider;

        require(
            provider == ZERO_ADDRESS ||
            provider == msg.sender,
            "LiquidLocker: NOT_AUTHORIZED"
        );

        _claimInterest(
            msg.sender
        );
    }

    function _claimInterest(
        address _claimAddress
    )
        internal
    {

        uint256 claimAmount = claimableBalance
            * contributions[_claimAddress]
            / totalCollected;

        uint256 tokensToTransfer = claimAmount
            - compensations[_claimAddress];

        compensations[_claimAddress] = claimAmount;

        _safeTransfer(
            PAYMENT_TOKEN,
            _claimAddress,
            tokensToTransfer
        );

        emit ClaimMade(
            tokensToTransfer,
            _claimAddress
        );
    }

    function _refundTokens(
        uint256 _refundAmount,
        address _refundAddress
    )
        internal
    {

        contributions[_refundAddress] =
        contributions[_refundAddress] - _refundAmount;

        _safeTransfer(
            PAYMENT_TOKEN,
            _refundAddress,
            _refundAmount
        );

        emit RefundMade(
            _refundAmount,
            _refundAddress
        );
    }
}
