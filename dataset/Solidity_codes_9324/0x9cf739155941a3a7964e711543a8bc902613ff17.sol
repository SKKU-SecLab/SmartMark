

pragma solidity 0.6.6;


interface IERC20 {

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function approve(address _spender, uint256 _value) external returns (bool success);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function decimals() external view returns (uint8 digits);


    function totalSupply() external view returns (uint256 supply);

}


abstract contract ERC20 is IERC20 {

}


pragma solidity 0.6.6;


contract PermissionGroupsNoModifiers {

    address public admin;
    address public pendingAdmin;
    mapping(address => bool) internal operators;
    mapping(address => bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint256 internal constant MAX_GROUP_SIZE = 50;

    event AdminClaimed(address newAdmin, address previousAdmin);
    event AlerterAdded(address newAlerter, bool isAdd);
    event OperatorAdded(address newOperator, bool isAdd);
    event TransferAdminPending(address pendingAdmin);

    constructor(address _admin) public {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    function getOperators() external view returns (address[] memory) {

        return operatorsGroup;
    }

    function getAlerters() external view returns (address[] memory) {

        return alertersGroup;
    }

    function addAlerter(address newAlerter) public {

        onlyAdmin();
        require(!alerters[newAlerter], "alerter exists"); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE, "max alerters");

        emit AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function addOperator(address newOperator) public {

        onlyAdmin();
        require(!operators[newOperator], "operator exists"); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE, "max operators");

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function claimAdmin() public {

        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function removeAlerter(address alerter) public {

        onlyAdmin();
        require(alerters[alerter], "not alerter");
        delete alerters[alerter];

        for (uint256 i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.pop();
                emit AlerterAdded(alerter, false);
                break;
            }
        }
    }

    function removeOperator(address operator) public {

        onlyAdmin();
        require(operators[operator], "not operator");
        delete operators[operator];

        for (uint256 i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.pop();
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }

    function transferAdmin(address newAdmin) public {

        onlyAdmin();
        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public {

        onlyAdmin();
        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    function onlyAdmin() internal view {

        require(msg.sender == admin, "only admin");
    }

    function onlyAlerter() internal view {

        require(alerters[msg.sender], "only alerter");
    }

    function onlyOperator() internal view {

        require(operators[msg.sender], "only operator");
    }
}


pragma solidity 0.6.6;




contract WithdrawableNoModifiers is PermissionGroupsNoModifiers {

    constructor(address _admin) public PermissionGroupsNoModifiers(_admin) {}

    event EtherWithdraw(uint256 amount, address sendTo);
    event TokenWithdraw(IERC20 token, uint256 amount, address sendTo);

    function withdrawEther(uint256 amount, address payable sendTo) external {

        onlyAdmin();
        (bool success, ) = sendTo.call{value: amount}("");
        require(success);
        emit EtherWithdraw(amount, sendTo);
    }

    function withdrawToken(
        IERC20 token,
        uint256 amount,
        address sendTo
    ) external {

        onlyAdmin();
        token.transfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }
}


pragma solidity 0.6.6;



interface IKyberReserve {

    function trade(
        IERC20 srcToken,
        uint256 srcAmount,
        IERC20 destToken,
        address payable destAddress,
        uint256 conversionRate,
        bool validate
    ) external payable returns (bool);


    function getConversionRate(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 blockNumber
    ) external view returns (uint256);

}


pragma solidity 0.6.6;



interface IKyberNetwork {

    event KyberTrade(
        IERC20 indexed src,
        IERC20 indexed dest,
        uint256 ethWeiValue,
        uint256 networkFeeWei,
        uint256 customPlatformFeeWei,
        bytes32[] t2eIds,
        bytes32[] e2tIds,
        uint256[] t2eSrcAmounts,
        uint256[] e2tSrcAmounts,
        uint256[] t2eRates,
        uint256[] e2tRates
    );

    function tradeWithHintAndFee(
        address payable trader,
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);


    function listTokenForReserve(
        address reserve,
        IERC20 token,
        bool add
    ) external;


    function enabled() external view returns (bool);


    function getExpectedRateWithHintAndFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    )
        external
        view
        returns (
            uint256 expectedRateAfterNetworkFee,
            uint256 expectedRateAfterAllFees
        );


    function getNetworkData()
        external
        view
        returns (
            uint256 negligibleDiffBps,
            uint256 networkFeeBps,
            uint256 expiryTimestamp
        );


    function maxGasPrice() external view returns (uint256);

}


pragma solidity 0.6.6;



interface IKyberNetworkProxy {


    event ExecuteTrade(
        address indexed trader,
        IERC20 src,
        IERC20 dest,
        address destAddress,
        uint256 actualSrcAmount,
        uint256 actualDestAmount,
        address platformWallet,
        uint256 platformFeeBps
    );

    function tradeWithHint(
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    ) external payable returns (uint256);


    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);


    function trade(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet
    ) external payable returns (uint256);


    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 worstRate);


    function getExpectedRateAfterFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (uint256 expectedRate);

}


pragma solidity 0.6.6;




interface IKyberStorage {

    enum ReserveType {NONE, FPR, APR, BRIDGE, UTILITY, CUSTOM, ORDERBOOK, LAST}

    function addKyberProxy(address kyberProxy, uint256 maxApprovedProxies)
        external;


    function removeKyberProxy(address kyberProxy) external;


    function setContracts(address _kyberFeeHandler, address _kyberMatchingEngine) external;


    function setKyberDaoContract(address _kyberDao) external;


    function getReserveId(address reserve) external view returns (bytes32 reserveId);


    function getReserveIdsFromAddresses(address[] calldata reserveAddresses)
        external
        view
        returns (bytes32[] memory reserveIds);


    function getReserveAddressesFromIds(bytes32[] calldata reserveIds)
        external
        view
        returns (address[] memory reserveAddresses);


    function getReserveIdsPerTokenSrc(IERC20 token)
        external
        view
        returns (bytes32[] memory reserveIds);


    function getReserveAddressesPerTokenSrc(IERC20 token, uint256 startIndex, uint256 endIndex)
        external
        view
        returns (address[] memory reserveAddresses);


    function getReserveIdsPerTokenDest(IERC20 token)
        external
        view
        returns (bytes32[] memory reserveIds);


    function getReserveAddressesByReserveId(bytes32 reserveId)
        external
        view
        returns (address[] memory reserveAddresses);


    function getRebateWalletsFromIds(bytes32[] calldata reserveIds)
        external
        view
        returns (address[] memory rebateWallets);


    function getKyberProxies() external view returns (IKyberNetworkProxy[] memory);


    function getReserveDetailsByAddress(address reserve)
        external
        view
        returns (
            bytes32 reserveId,
            address rebateWallet,
            ReserveType resType,
            bool isFeeAccountedFlag,
            bool isEntitledRebateFlag
        );


    function getReserveDetailsById(bytes32 reserveId)
        external
        view
        returns (
            address reserveAddress,
            address rebateWallet,
            ReserveType resType,
            bool isFeeAccountedFlag,
            bool isEntitledRebateFlag
        );


    function getFeeAccountedData(bytes32[] calldata reserveIds)
        external
        view
        returns (bool[] memory feeAccountedArr);


    function getEntitledRebateData(bytes32[] calldata reserveIds)
        external
        view
        returns (bool[] memory entitledRebateArr);


    function getReservesData(bytes32[] calldata reserveIds, IERC20 src, IERC20 dest)
        external
        view
        returns (
            bool areAllReservesListed,
            bool[] memory feeAccountedArr,
            bool[] memory entitledRebateArr,
            IKyberReserve[] memory reserveAddresses);


    function isKyberProxyAdded() external view returns (bool);

}


pragma solidity 0.6.6;





interface IKyberMatchingEngine {

    enum ProcessWithRate {NotRequired, Required}

    function setNegligibleRateDiffBps(uint256 _negligibleRateDiffBps) external;


    function setKyberStorage(IKyberStorage _kyberStorage) external;


    function getNegligibleRateDiffBps() external view returns (uint256);


    function getTradingReserves(
        IERC20 src,
        IERC20 dest,
        bool isTokenToToken,
        bytes calldata hint
    )
        external
        view
        returns (
            bytes32[] memory reserveIds,
            uint256[] memory splitValuesBps,
            ProcessWithRate processWithRate
        );


    function doMatch(
        IERC20 src,
        IERC20 dest,
        uint256[] calldata srcAmounts,
        uint256[] calldata feesAccountedDestBps,
        uint256[] calldata rates
    ) external view returns (uint256[] memory reserveIndexes);

}


pragma solidity 0.6.6;



contract Utils5 {

    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20 => uint256) internal decimals;

    function getUpdateDecimals(IERC20 token) internal returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }

        return tokenDecimals;
    }

    function setDecimals(IERC20 token) internal {

        if (decimals[token] != 0) return; //already set

        if (token == ETH_TOKEN_ADDRESS) {
            decimals[token] = ETH_DECIMALS;
        } else {
            decimals[token] = token.decimals();
        }
    }

    function getBalance(IERC20 token, address user) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20 token) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        if (tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDestAmount(
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20 src,
        IERC20 dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {

        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }
}


pragma solidity 0.6.6;



interface IKyberHint {

    enum TradeType {BestOfAll, MaskIn, MaskOut, Split}
    enum HintErrors {
        NoError, // Hint is valid
        NonEmptyDataError, // reserveIDs and splits must be empty for BestOfAll hint
        ReserveIdDupError, // duplicate reserveID found
        ReserveIdEmptyError, // reserveIDs array is empty for MaskIn and Split trade type
        ReserveIdSplitsError, // reserveIDs and splitBpsValues arrays do not have the same length
        ReserveIdSequenceError, // reserveID sequence in array is not in increasing order
        ReserveIdNotFound, // reserveID isn't registered or doesn't exist
        SplitsNotEmptyError, // splitBpsValues is not empty for MaskIn or MaskOut trade type
        TokenListedError, // reserveID not listed for the token
        TotalBPSError // total BPS for Split trade type is not 10000 (100%)
    }

    function buildTokenToEthHint(
        IERC20 tokenSrc,
        TradeType tokenToEthType,
        bytes32[] calldata tokenToEthReserveIds,
        uint256[] calldata tokenToEthSplits
    ) external view returns (bytes memory hint);


    function buildEthToTokenHint(
        IERC20 tokenDest,
        TradeType ethToTokenType,
        bytes32[] calldata ethToTokenReserveIds,
        uint256[] calldata ethToTokenSplits
    ) external view returns (bytes memory hint);


    function buildTokenToTokenHint(
        IERC20 tokenSrc,
        TradeType tokenToEthType,
        bytes32[] calldata tokenToEthReserveIds,
        uint256[] calldata tokenToEthSplits,
        IERC20 tokenDest,
        TradeType ethToTokenType,
        bytes32[] calldata ethToTokenReserveIds,
        uint256[] calldata ethToTokenSplits
    ) external view returns (bytes memory hint);


    function parseTokenToEthHint(IERC20 tokenSrc, bytes calldata hint)
        external
        view
        returns (
            TradeType tokenToEthType,
            bytes32[] memory tokenToEthReserveIds,
            IKyberReserve[] memory tokenToEthAddresses,
            uint256[] memory tokenToEthSplits
        );


    function parseEthToTokenHint(IERC20 tokenDest, bytes calldata hint)
        external
        view
        returns (
            TradeType ethToTokenType,
            bytes32[] memory ethToTokenReserveIds,
            IKyberReserve[] memory ethToTokenAddresses,
            uint256[] memory ethToTokenSplits
        );


    function parseTokenToTokenHint(IERC20 tokenSrc, IERC20 tokenDest, bytes calldata hint)
        external
        view
        returns (
            TradeType tokenToEthType,
            bytes32[] memory tokenToEthReserveIds,
            IKyberReserve[] memory tokenToEthAddresses,
            uint256[] memory tokenToEthSplits,
            TradeType ethToTokenType,
            bytes32[] memory ethToTokenReserveIds,
            IKyberReserve[] memory ethToTokenAddresses,
            uint256[] memory ethToTokenSplits
        );

}


pragma solidity 0.6.6;




abstract contract KyberHintHandler is IKyberHint, Utils5 {
    function parseTokenToEthHint(IERC20 tokenSrc, bytes memory hint)
        public
        view
        override
        returns (
            TradeType tokenToEthType,
            bytes32[] memory tokenToEthReserveIds,
            IKyberReserve[] memory tokenToEthAddresses,
            uint256[] memory tokenToEthSplits
        )
    {
        HintErrors error;

        (tokenToEthType, tokenToEthReserveIds, tokenToEthSplits, error) = parseHint(hint);
        if (error != HintErrors.NoError) throwHintError(error);

        if (tokenToEthType == TradeType.MaskIn || tokenToEthType == TradeType.Split) {
            checkTokenListedForReserve(tokenSrc, tokenToEthReserveIds, true);
        }

        tokenToEthAddresses = new IKyberReserve[](tokenToEthReserveIds.length);

        for (uint256 i = 0; i < tokenToEthReserveIds.length; i++) {
            checkReserveIdsExists(tokenToEthReserveIds[i]);
            checkDuplicateReserveIds(tokenToEthReserveIds, i);

            if (i > 0 && tokenToEthType == TradeType.Split) {
                checkSplitReserveIdSeq(tokenToEthReserveIds[i], tokenToEthReserveIds[i - 1]);
            }

            tokenToEthAddresses[i] = IKyberReserve(
                getReserveAddress(tokenToEthReserveIds[i])
            );
        }
    }

    function parseEthToTokenHint(IERC20 tokenDest, bytes memory hint)
        public
        view
        override
        returns (
            TradeType ethToTokenType,
            bytes32[] memory ethToTokenReserveIds,
            IKyberReserve[] memory ethToTokenAddresses,
            uint256[] memory ethToTokenSplits
        )
    {
        HintErrors error;

        (ethToTokenType, ethToTokenReserveIds, ethToTokenSplits, error) = parseHint(hint);
        if (error != HintErrors.NoError) throwHintError(error);

        if (ethToTokenType == TradeType.MaskIn || ethToTokenType == TradeType.Split) {
            checkTokenListedForReserve(tokenDest, ethToTokenReserveIds, false);
        }

        ethToTokenAddresses = new IKyberReserve[](ethToTokenReserveIds.length);

        for (uint256 i = 0; i < ethToTokenReserveIds.length; i++) {
            checkReserveIdsExists(ethToTokenReserveIds[i]);
            checkDuplicateReserveIds(ethToTokenReserveIds, i);

            if (i > 0 && ethToTokenType == TradeType.Split) {
                checkSplitReserveIdSeq(ethToTokenReserveIds[i], ethToTokenReserveIds[i - 1]);
            }

            ethToTokenAddresses[i] = IKyberReserve(
                getReserveAddress(ethToTokenReserveIds[i])
            );
        }
    }

    function parseTokenToTokenHint(IERC20 tokenSrc, IERC20 tokenDest, bytes memory hint)
        public
        view
        override
        returns (
            TradeType tokenToEthType,
            bytes32[] memory tokenToEthReserveIds,
            IKyberReserve[] memory tokenToEthAddresses,
            uint256[] memory tokenToEthSplits,
            TradeType ethToTokenType,
            bytes32[] memory ethToTokenReserveIds,
            IKyberReserve[] memory ethToTokenAddresses,
            uint256[] memory ethToTokenSplits
        )
    {
        bytes memory t2eHint;
        bytes memory e2tHint;

        (t2eHint, e2tHint) = unpackT2THint(hint);

        (
            tokenToEthType,
            tokenToEthReserveIds,
            tokenToEthAddresses,
            tokenToEthSplits
        ) = parseTokenToEthHint(tokenSrc, t2eHint);

        (
            ethToTokenType,
            ethToTokenReserveIds,
            ethToTokenAddresses,
            ethToTokenSplits
        ) = parseEthToTokenHint(tokenDest, e2tHint);
    }

    function buildTokenToEthHint(
        IERC20 tokenSrc,
        TradeType tokenToEthType,
        bytes32[] memory tokenToEthReserveIds,
        uint256[] memory tokenToEthSplits
    ) public view override returns (bytes memory hint) {
        for (uint256 i = 0; i < tokenToEthReserveIds.length; i++) {
            checkReserveIdsExists(tokenToEthReserveIds[i]);
        }

        HintErrors valid = verifyData(
            tokenToEthType,
            tokenToEthReserveIds,
            tokenToEthSplits
        );
        if (valid != HintErrors.NoError) throwHintError(valid);

        if (tokenToEthType == TradeType.MaskIn || tokenToEthType == TradeType.Split) {
            checkTokenListedForReserve(tokenSrc, tokenToEthReserveIds, true);
        }

        if (tokenToEthType == TradeType.Split) {
            bytes32[] memory seqT2EReserveIds;
            uint256[] memory seqT2ESplits;

            (seqT2EReserveIds, seqT2ESplits) = ensureSplitSeq(
                tokenToEthReserveIds,
                tokenToEthSplits
            );

            hint = abi.encode(tokenToEthType, seqT2EReserveIds, seqT2ESplits);
        } else {
            hint = abi.encode(tokenToEthType, tokenToEthReserveIds, tokenToEthSplits);
        }
    }

    function buildEthToTokenHint(
        IERC20 tokenDest,
        TradeType ethToTokenType,
        bytes32[] memory ethToTokenReserveIds,
        uint256[] memory ethToTokenSplits
    ) public view override returns (bytes memory hint) {
        for (uint256 i = 0; i < ethToTokenReserveIds.length; i++) {
            checkReserveIdsExists(ethToTokenReserveIds[i]);
        }

        HintErrors valid = verifyData(
            ethToTokenType,
            ethToTokenReserveIds,
            ethToTokenSplits
        );
        if (valid != HintErrors.NoError) throwHintError(valid);

        if (ethToTokenType == TradeType.MaskIn || ethToTokenType == TradeType.Split) {
            checkTokenListedForReserve(tokenDest, ethToTokenReserveIds, false);
        }

        if (ethToTokenType == TradeType.Split) {
            bytes32[] memory seqE2TReserveIds;
            uint256[] memory seqE2TSplits;

            (seqE2TReserveIds, seqE2TSplits) = ensureSplitSeq(
                ethToTokenReserveIds,
                ethToTokenSplits
            );

            hint = abi.encode(ethToTokenType, seqE2TReserveIds, seqE2TSplits);
        } else {
            hint = abi.encode(ethToTokenType, ethToTokenReserveIds, ethToTokenSplits);
        }
    }

    function buildTokenToTokenHint(
        IERC20 tokenSrc,
        TradeType tokenToEthType,
        bytes32[] memory tokenToEthReserveIds,
        uint256[] memory tokenToEthSplits,
        IERC20 tokenDest,
        TradeType ethToTokenType,
        bytes32[] memory ethToTokenReserveIds,
        uint256[] memory ethToTokenSplits
    ) public view override returns (bytes memory hint) {
        bytes memory t2eHint = buildTokenToEthHint(
            tokenSrc,
            tokenToEthType,
            tokenToEthReserveIds,
            tokenToEthSplits
        );

        bytes memory e2tHint = buildEthToTokenHint(
            tokenDest,
            ethToTokenType,
            ethToTokenReserveIds,
            ethToTokenSplits
        );

        hint = abi.encode(t2eHint, e2tHint);
    }

    function parseHint(bytes memory hint)
        internal
        pure
        returns (
            TradeType tradeType,
            bytes32[] memory reserveIds,
            uint256[] memory splits,
            HintErrors valid
        )
    {
        (tradeType, reserveIds, splits) = abi.decode(hint, (TradeType, bytes32[], uint256[])); // solhint-disable
        valid = verifyData(tradeType, reserveIds, splits);

        if (valid != HintErrors.NoError) {
            reserveIds = new bytes32[](0);
            splits = new uint256[](0);
        }
    }

    function unpackT2THint(bytes memory hint)
        internal
        pure
        returns (bytes memory t2eHint, bytes memory e2tHint)
    {
        (t2eHint, e2tHint) = abi.decode(hint, (bytes, bytes));
    }

    function checkReserveIdsExists(bytes32 reserveId)
        internal
        view
    {
        if (getReserveAddress(reserveId) == address(0))
            throwHintError(HintErrors.ReserveIdNotFound);
    }

    function checkTokenListedForReserve(
        IERC20 token,
        bytes32[] memory reserveIds,
        bool isTokenToEth
    ) internal view {
        IERC20 src = (isTokenToEth) ? token : ETH_TOKEN_ADDRESS;
        IERC20 dest = (isTokenToEth) ? ETH_TOKEN_ADDRESS : token;

        if (!areAllReservesListed(reserveIds, src, dest))
            throwHintError(HintErrors.TokenListedError);
    }

    function checkDuplicateReserveIds(bytes32[] memory reserveIds, uint256 i)
        internal
        pure
    {
        for (uint256 j = i + 1; j < reserveIds.length; j++) {
            if (uint256(reserveIds[i]) == uint256(reserveIds[j])) {
                throwHintError(HintErrors.ReserveIdDupError);
            }
        }
    }

    function checkSplitReserveIdSeq(bytes32 reserveId, bytes32 prevReserveId)
        internal
        pure
    {
        if (uint256(reserveId) <= uint256(prevReserveId)) {
            throwHintError(HintErrors.ReserveIdSequenceError);
        }
    }

    function ensureSplitSeq(
        bytes32[] memory reserveIds,
        uint256[] memory splits
    )
        internal
        pure
        returns (bytes32[] memory, uint256[] memory)
    {
        for (uint256 i = 0; i < reserveIds.length; i++) {
            for (uint256 j = i + 1; j < reserveIds.length; j++) {
                if (uint256(reserveIds[i]) > (uint256(reserveIds[j]))) {
                    bytes32 tempId = reserveIds[i];
                    uint256 tempSplit = splits[i];

                    reserveIds[i] = reserveIds[j];
                    reserveIds[j] = tempId;
                    splits[i] = splits[j];
                    splits[j] = tempSplit;
                } else if (reserveIds[i] == reserveIds[j]) {
                    throwHintError(HintErrors.ReserveIdDupError);
                }
            }
        }

        return (reserveIds, splits);
    }

    function verifyData(
        TradeType tradeType,
        bytes32[] memory reserveIds,
        uint256[] memory splits
    ) internal pure returns (HintErrors) {
        if (tradeType == TradeType.BestOfAll) {
            if (reserveIds.length != 0 || splits.length != 0) return HintErrors.NonEmptyDataError;
        }

        if (
            (tradeType == TradeType.MaskIn || tradeType == TradeType.Split) &&
            reserveIds.length == 0
        ) return HintErrors.ReserveIdEmptyError;

        if (tradeType == TradeType.Split) {
            if (reserveIds.length != splits.length) return HintErrors.ReserveIdSplitsError;

            uint256 bpsSoFar;
            for (uint256 i = 0; i < splits.length; i++) {
                bpsSoFar += splits[i];
            }

            if (bpsSoFar != BPS) return HintErrors.TotalBPSError;
        } else {
            if (splits.length != 0) return HintErrors.SplitsNotEmptyError;
        }

        return HintErrors.NoError;
    }

    function throwHintError(HintErrors error) internal pure {
        if (error == HintErrors.NonEmptyDataError) revert("reserveIds and splits must be empty");
        if (error == HintErrors.ReserveIdDupError) revert("duplicate reserveId");
        if (error == HintErrors.ReserveIdEmptyError) revert("reserveIds cannot be empty");
        if (error == HintErrors.ReserveIdSplitsError) revert("reserveIds.length != splits.length");
        if (error == HintErrors.ReserveIdSequenceError) revert("reserveIds not in increasing order");
        if (error == HintErrors.ReserveIdNotFound) revert("reserveId not found");
        if (error == HintErrors.SplitsNotEmptyError) revert("splits must be empty");
        if (error == HintErrors.TokenListedError) revert("token is not listed for reserveId");
        if (error == HintErrors.TotalBPSError) revert("total BPS != 10000");
    }

    function getReserveAddress(bytes32 reserveId) internal view virtual returns (address);

    function areAllReservesListed(
        bytes32[] memory reserveIds,
        IERC20 src,
        IERC20 dest
    ) internal virtual view returns (bool);
}


pragma solidity 0.6.6;







contract KyberMatchingEngine is KyberHintHandler, IKyberMatchingEngine, WithdrawableNoModifiers {

    struct BestReserveInfo {
        uint256 index;
        uint256 destAmount;
        uint256 numRelevantReserves;
    }
    IKyberNetwork public kyberNetwork;
    IKyberStorage public kyberStorage;

    uint256 negligibleRateDiffBps = 5; // 1 bps is 0.01%

    event KyberStorageUpdated(IKyberStorage newKyberStorage);
    event KyberNetworkUpdated(IKyberNetwork newKyberNetwork);

    constructor(address _admin) public WithdrawableNoModifiers(_admin) {
    }

    function setKyberStorage(IKyberStorage _kyberStorage) external virtual override {

        onlyAdmin();
        emit KyberStorageUpdated(_kyberStorage);
        kyberStorage = _kyberStorage;
    }

    function setNegligibleRateDiffBps(uint256 _negligibleRateDiffBps)
        external
        virtual
        override
    {

        onlyNetwork();
        require(_negligibleRateDiffBps <= BPS, "rateDiffBps exceed BPS"); // at most 100%
        negligibleRateDiffBps = _negligibleRateDiffBps;
    }

    function setNetworkContract(IKyberNetwork _kyberNetwork) external {

        onlyAdmin();
        require(_kyberNetwork != IKyberNetwork(0), "kyberNetwork 0");
        emit KyberNetworkUpdated(_kyberNetwork);
        kyberNetwork = _kyberNetwork;
    }

    function getTradingReserves(
        IERC20 src,
        IERC20 dest,
        bool isTokenToToken,
        bytes calldata hint
    )
        external
        view
        override
        returns (
            bytes32[] memory reserveIds,
            uint256[] memory splitValuesBps,
            ProcessWithRate processWithRate
        )
    {

        HintErrors error;
        if (hint.length == 0 || hint.length == 4) {
            reserveIds = (dest == ETH_TOKEN_ADDRESS)
                ? kyberStorage.getReserveIdsPerTokenSrc(src)
                : kyberStorage.getReserveIdsPerTokenDest(dest);

            splitValuesBps = populateSplitValuesBps(reserveIds.length);
            processWithRate = ProcessWithRate.Required;
            return (reserveIds, splitValuesBps, processWithRate);
        }

        TradeType tradeType;

        if (isTokenToToken) {
            bytes memory unpackedHint;
            if (src == ETH_TOKEN_ADDRESS) {
                (, unpackedHint) = unpackT2THint(hint);
                (tradeType, reserveIds, splitValuesBps, error) = parseHint(unpackedHint);
            }
            if (dest == ETH_TOKEN_ADDRESS) {
                (unpackedHint, ) = unpackT2THint(hint);
                (tradeType, reserveIds, splitValuesBps, error) = parseHint(unpackedHint);
            }
        } else {
            (tradeType, reserveIds, splitValuesBps, error) = parseHint(hint);
        }

        if (error != HintErrors.NoError)
            return (new bytes32[](0), new uint256[](0), ProcessWithRate.NotRequired);

        if (tradeType == TradeType.MaskIn) {
            splitValuesBps = populateSplitValuesBps(reserveIds.length);
        } else if (tradeType == TradeType.BestOfAll || tradeType == TradeType.MaskOut) {
            bytes32[] memory allReserves = (dest == ETH_TOKEN_ADDRESS)
                ? kyberStorage.getReserveIdsPerTokenSrc(src)
                : kyberStorage.getReserveIdsPerTokenDest(dest);

            reserveIds = (tradeType == TradeType.BestOfAll) ?
                allReserves :
                maskOutReserves(allReserves, reserveIds);
            splitValuesBps = populateSplitValuesBps(reserveIds.length);
        }

        processWithRate = (tradeType == TradeType.Split)
            ? ProcessWithRate.NotRequired
            : ProcessWithRate.Required;
    }

    function getNegligibleRateDiffBps() external view override returns (uint256) {

        return negligibleRateDiffBps;
    }

    function doMatch(
        IERC20 src,
        IERC20 dest,
        uint256[] calldata srcAmounts,
        uint256[] calldata feesAccountedDestBps, // 0 for no fee, networkFeeBps when has fee
        uint256[] calldata rates
    ) external view override returns (uint256[] memory reserveIndexes) {

        src;
        dest;
        reserveIndexes = new uint256[](1);

        BestReserveInfo memory bestReserve;
        bestReserve.numRelevantReserves = 1; // assume always best reserve will be relevant

        if (rates.length == 0) {
            reserveIndexes = new uint256[](0);
            return reserveIndexes;
        }

        uint256[] memory reserveCandidates = new uint256[](rates.length);
        uint256[] memory destAmounts = new uint256[](rates.length);
        uint256 destAmount;

        for (uint256 i = 0; i < rates.length; i++) {
            destAmount = (srcAmounts[i] * rates[i] * (BPS - feesAccountedDestBps[i])) / BPS;
            if (destAmount > bestReserve.destAmount) {
                bestReserve.destAmount = destAmount;
                bestReserve.index = i;
            }

            destAmounts[i] = destAmount;
        }

        if (bestReserve.destAmount == 0) {
            reserveIndexes[0] = bestReserve.index;
            return reserveIndexes;
        }

        reserveCandidates[0] = bestReserve.index;

        bestReserve.destAmount = (bestReserve.destAmount * BPS) / (BPS + negligibleRateDiffBps);

        for (uint256 i = 0; i < rates.length; i++) {
            if (i == bestReserve.index) continue;
            if (destAmounts[i] > bestReserve.destAmount) {
                reserveCandidates[bestReserve.numRelevantReserves++] = i;
            }
        }

        if (bestReserve.numRelevantReserves > 1) {
            bestReserve.index = reserveCandidates[uint256(blockhash(block.number - 1)) %
                bestReserve.numRelevantReserves];
        } else {
            bestReserve.index = reserveCandidates[0];
        }

        reserveIndexes[0] = bestReserve.index;
    }

    function getReserveAddress(bytes32 reserveId) internal view override returns (address reserveAddress) {

        (reserveAddress, , , ,) = kyberStorage.getReserveDetailsById(reserveId);
    }

    function areAllReservesListed(
        bytes32[] memory reserveIds,
        IERC20 src,
        IERC20 dest
    ) internal override view returns (bool allReservesListed) {

        (allReservesListed, , ,) = kyberStorage.getReservesData(reserveIds, src, dest);
    }

    function maskOutReserves(
        bytes32[] memory allReservesPerToken,
        bytes32[] memory maskedOutReserves
    ) internal pure returns (bytes32[] memory filteredReserves) {

        require(
            allReservesPerToken.length >= maskedOutReserves.length,
            "mask out exceeds available reserves"
        );
        filteredReserves = new bytes32[](allReservesPerToken.length - maskedOutReserves.length);
        uint256 currentResultIndex = 0;

        for (uint256 i = 0; i < allReservesPerToken.length; i++) {
            bytes32 reserveId = allReservesPerToken[i];
            bool notMaskedOut = true;

            for (uint256 j = 0; j < maskedOutReserves.length; j++) {
                bytes32 maskedOutReserveId = maskedOutReserves[j];
                if (reserveId == maskedOutReserveId) {
                    notMaskedOut = false;
                    break;
                }
            }

            if (notMaskedOut) filteredReserves[currentResultIndex++] = reserveId;
        }
    }

    function onlyNetwork() internal view {

        require(msg.sender == address(kyberNetwork), "only kyberNetwork");
    }

    function populateSplitValuesBps(uint256 length)
        internal
        pure
        returns (uint256[] memory splitValuesBps)
    {

        splitValuesBps = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            splitValuesBps[i] = BPS;
        }
    }
}