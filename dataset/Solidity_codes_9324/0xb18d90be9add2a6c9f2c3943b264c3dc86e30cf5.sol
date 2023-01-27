

pragma solidity 0.6.6;


interface IKyberHistory {

    function saveContract(address _contract) external;

    function getContracts() external view returns (address[] memory);

}


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







contract KyberStorage is IKyberStorage, PermissionGroupsNoModifiers, Utils5 {

    IKyberHistory public kyberNetworkHistory;
    IKyberHistory public kyberFeeHandlerHistory;
    IKyberHistory public kyberDaoHistory;
    IKyberHistory public kyberMatchingEngineHistory;

    IKyberReserve[] internal reserves;
    IKyberNetworkProxy[] internal kyberProxyArray;

    mapping(bytes32 => address[]) internal reserveIdToAddresses;
    mapping(bytes32 => address) internal reserveRebateWallet;
    mapping(address => bytes32) internal reserveAddressToId;
    mapping(IERC20 => bytes32[]) internal reservesPerTokenSrc; // reserves supporting token to eth
    mapping(IERC20 => bytes32[]) internal reservesPerTokenDest; // reserves support eth to token
    mapping(bytes32 => IERC20[]) internal srcTokensPerReserve;
    mapping(bytes32 => IERC20[]) internal destTokensPerReserve;

    mapping(IERC20 => mapping(bytes32 => bool)) internal isListedReserveWithTokenSrc;
    mapping(IERC20 => mapping(bytes32 => bool)) internal isListedReserveWithTokenDest;

    uint256 internal feeAccountedPerType = 0xffffffff;
    uint256 internal entitledRebatePerType = 0xffffffff;
    mapping(bytes32 => uint256) internal reserveType; // type from enum ReserveType
    mapping(ReserveType => bytes32[]) internal reservesPerType;

    IKyberNetwork public kyberNetwork;

    constructor(
        address _admin,
        IKyberHistory _kyberNetworkHistory,
        IKyberHistory _kyberFeeHandlerHistory,
        IKyberHistory _kyberDaoHistory,
        IKyberHistory _kyberMatchingEngineHistory
    ) public PermissionGroupsNoModifiers(_admin) {
        require(_kyberNetworkHistory != IKyberHistory(0), "kyberNetworkHistory 0");
        require(_kyberFeeHandlerHistory != IKyberHistory(0), "kyberFeeHandlerHistory 0");
        require(_kyberDaoHistory != IKyberHistory(0), "kyberDaoHistory 0");
        require(_kyberMatchingEngineHistory != IKyberHistory(0), "kyberMatchingEngineHistory 0");

        kyberNetworkHistory = _kyberNetworkHistory;
        kyberFeeHandlerHistory = _kyberFeeHandlerHistory;
        kyberDaoHistory = _kyberDaoHistory;
        kyberMatchingEngineHistory = _kyberMatchingEngineHistory;
    }

    event KyberNetworkUpdated(IKyberNetwork newKyberNetwork);
    event RemoveReserveFromStorage(address indexed reserve, bytes32 indexed reserveId);

    event AddReserveToStorage(
        address indexed reserve,
        bytes32 indexed reserveId,
        IKyberStorage.ReserveType reserveType,
        address indexed rebateWallet
    );

    event ReserveRebateWalletSet(
        bytes32 indexed reserveId,
        address indexed rebateWallet
    );

    event ListReservePairs(
        bytes32 indexed reserveId,
        address reserve,
        IERC20 indexed src,
        IERC20 indexed dest,
        bool add
    );

    function setNetworkContract(IKyberNetwork _kyberNetwork) external {

        onlyAdmin();
        require(_kyberNetwork != IKyberNetwork(0), "kyberNetwork 0");
        emit KyberNetworkUpdated(_kyberNetwork);
        kyberNetworkHistory.saveContract(address(_kyberNetwork));
        kyberNetwork = _kyberNetwork;
    }

    function setRebateWallet(bytes32 reserveId, address rebateWallet) external {

        onlyOperator();
        require(rebateWallet != address(0), "rebate wallet is 0");
        require(reserveId != bytes32(0), "reserveId = 0");
        require(reserveIdToAddresses[reserveId].length > 0, "reserveId not found");
        require(reserveIdToAddresses[reserveId][0] != address(0), "no reserve associated");

        reserveRebateWallet[reserveId] = rebateWallet;
        emit ReserveRebateWalletSet(reserveId, rebateWallet);
    }

    function setContracts(address _kyberFeeHandler, address _kyberMatchingEngine)
        external
        override
    {

        onlyNetwork();
        require(_kyberFeeHandler != address(0), "kyberFeeHandler 0");
        require(_kyberMatchingEngine != address(0), "kyberMatchingEngine 0");

        kyberFeeHandlerHistory.saveContract(_kyberFeeHandler);
        kyberMatchingEngineHistory.saveContract(_kyberMatchingEngine);
    }

    function setKyberDaoContract(address _kyberDao) external override {

        onlyNetwork();

        kyberDaoHistory.saveContract(_kyberDao);
    }

    function addReserve(
        address reserve,
        bytes32 reserveId,
        ReserveType resType,
        address payable rebateWallet
    ) external {

        onlyOperator();
        require(reserveAddressToId[reserve] == bytes32(0), "reserve has id");
        require(reserveId != bytes32(0), "reserveId = 0");
        require(
            (resType != ReserveType.NONE) && (uint256(resType) < uint256(ReserveType.LAST)),
            "bad reserve type"
        );
        require(feeAccountedPerType != 0xffffffff, "fee accounted data not set");
        require(entitledRebatePerType != 0xffffffff, "entitled rebate data not set");
        require(rebateWallet != address(0), "rebate wallet is 0");

        reserveRebateWallet[reserveId] = rebateWallet;

        if (reserveIdToAddresses[reserveId].length == 0) {
            reserveIdToAddresses[reserveId].push(reserve);
        } else {
            require(reserveIdToAddresses[reserveId][0] == address(0), "reserveId taken");
            reserveIdToAddresses[reserveId][0] = reserve;
        }

        reserves.push(IKyberReserve(reserve));
        reservesPerType[resType].push(reserveId);
        reserveAddressToId[reserve] = reserveId;
        reserveType[reserveId] = uint256(resType);

        emit AddReserveToStorage(reserve, reserveId, resType, rebateWallet);
        emit ReserveRebateWalletSet(reserveId, rebateWallet);
    }

    function removeReserve(bytes32 reserveId, uint256 startIndex)
        external
    {

        onlyOperator();
        require(reserveIdToAddresses[reserveId].length > 0, "reserveId not found");
        address reserve = reserveIdToAddresses[reserveId][0];

        delistTokensOfReserve(reserveId);

        uint256 reserveIndex = 2**255;
        for (uint256 i = startIndex; i < reserves.length; i++) {
            if (reserves[i] == IKyberReserve(reserve)) {
                reserveIndex = i;
                break;
            }
        }
        require(reserveIndex != 2**255, "reserve not found");
        reserves[reserveIndex] = reserves[reserves.length - 1];
        reserves.pop();
        require(reserveAddressToId[reserve] != bytes32(0), "reserve's existing reserveId is 0");
        reserveId = reserveAddressToId[reserve];

        reserveIdToAddresses[reserveId].push(reserveIdToAddresses[reserveId][0]);
        reserveIdToAddresses[reserveId][0] = address(0);

        bytes32[] storage reservesOfType = reservesPerType[ReserveType(reserveType[reserveId])];
        for (uint256 i = 0; i < reservesOfType.length; i++) {
            if (reserveId == reservesOfType[i]) {
                reservesOfType[i] = reservesOfType[reservesOfType.length - 1];
                reservesOfType.pop();
                break;
            }
        }

        delete reserveAddressToId[reserve];
        delete reserveType[reserveId];
        delete reserveRebateWallet[reserveId];

        emit RemoveReserveFromStorage(reserve, reserveId);
    }

    function listPairForReserve(
        bytes32 reserveId,
        IERC20 token,
        bool ethToToken,
        bool tokenToEth,
        bool add
    ) public {

        onlyOperator();

        require(reserveIdToAddresses[reserveId].length > 0, "reserveId not found");
        address reserve = reserveIdToAddresses[reserveId][0];
        require(reserve != address(0), "reserve = 0");

        if (ethToToken) {
            listPairs(reserveId, token, false, add);
            emit ListReservePairs(reserveId, reserve, ETH_TOKEN_ADDRESS, token, add);
        }

        if (tokenToEth) {
            kyberNetwork.listTokenForReserve(reserve, token, add);
            listPairs(reserveId, token, true, add);
            emit ListReservePairs(reserveId, reserve, token, ETH_TOKEN_ADDRESS, add);
        }
    }

    function addKyberProxy(address kyberProxy, uint256 maxApprovedProxies)
        external
        override
    {

        onlyNetwork();
        require(kyberProxy != address(0), "kyberProxy 0");
        require(kyberProxyArray.length < maxApprovedProxies, "max kyberProxies limit reached");

        kyberProxyArray.push(IKyberNetworkProxy(kyberProxy));
    }

    function removeKyberProxy(address kyberProxy) external override {

        onlyNetwork();
        uint256 proxyIndex = 2**255;

        for (uint256 i = 0; i < kyberProxyArray.length; i++) {
            if (kyberProxyArray[i] == IKyberNetworkProxy(kyberProxy)) {
                proxyIndex = i;
                break;
            }
        }

        require(proxyIndex != 2**255, "kyberProxy not found");
        kyberProxyArray[proxyIndex] = kyberProxyArray[kyberProxyArray.length - 1];
        kyberProxyArray.pop();
    }

    function setFeeAccountedPerReserveType(
        bool fpr,
        bool apr,
        bool bridge,
        bool utility,
        bool custom,
        bool orderbook
    ) external {

        onlyAdmin();
        uint256 feeAccountedData;

        if (fpr) feeAccountedData |= 1 << uint256(ReserveType.FPR);
        if (apr) feeAccountedData |= 1 << uint256(ReserveType.APR);
        if (bridge) feeAccountedData |= 1 << uint256(ReserveType.BRIDGE);
        if (utility) feeAccountedData |= 1 << uint256(ReserveType.UTILITY);
        if (custom) feeAccountedData |= 1 << uint256(ReserveType.CUSTOM);
        if (orderbook) feeAccountedData |= 1 << uint256(ReserveType.ORDERBOOK);

        feeAccountedPerType = feeAccountedData;
    }

    function setEntitledRebatePerReserveType(
        bool fpr,
        bool apr,
        bool bridge,
        bool utility,
        bool custom,
        bool orderbook
    ) external {

        onlyAdmin();
        require(feeAccountedPerType != 0xffffffff, "fee accounted data not set");
        uint256 entitledRebateData;

        if (fpr) {
            require(feeAccountedPerType & (1 << uint256(ReserveType.FPR)) > 0, "fpr not fee accounted");
            entitledRebateData |= 1 << uint256(ReserveType.FPR);
        }

        if (apr) {
            require(feeAccountedPerType & (1 << uint256(ReserveType.APR)) > 0, "apr not fee accounted");
            entitledRebateData |= 1 << uint256(ReserveType.APR);
        }

        if (bridge) {
            require(feeAccountedPerType & (1 << uint256(ReserveType.BRIDGE)) > 0, "bridge not fee accounted");
            entitledRebateData |= 1 << uint256(ReserveType.BRIDGE);
        }

        if (utility) {
            require(feeAccountedPerType & (1 << uint256(ReserveType.UTILITY)) > 0, "utility not fee accounted");
            entitledRebateData |= 1 << uint256(ReserveType.UTILITY);
        }

        if (custom) {
            require(feeAccountedPerType & (1 << uint256(ReserveType.CUSTOM)) > 0, "custom not fee accounted");
            entitledRebateData |= 1 << uint256(ReserveType.CUSTOM);
        }

        if (orderbook) {
            require(feeAccountedPerType & (1 << uint256(ReserveType.ORDERBOOK)) > 0, "orderbook not fee accounted");
            entitledRebateData |= 1 << uint256(ReserveType.ORDERBOOK);
        }

        entitledRebatePerType = entitledRebateData;
    }

    function getReserves() external view returns (IKyberReserve[] memory) {

        return reserves;
    }

    function getReservesPerType(ReserveType resType) external view returns (bytes32[] memory) {

        return reservesPerType[resType];
    }

    function getReserveId(address reserve) external view override returns (bytes32) {

        return reserveAddressToId[reserve];
    }

    function getReserveIdsFromAddresses(address[] calldata reserveAddresses)
        external
        override
        view
        returns (bytes32[] memory reserveIds)
    {

        reserveIds = new bytes32[](reserveAddresses.length);
        for (uint256 i = 0; i < reserveAddresses.length; i++) {
            reserveIds[i] = reserveAddressToId[reserveAddresses[i]];
        }
    }

    function getReserveAddressesFromIds(bytes32[] calldata reserveIds)
        external
        view
        override
        returns (address[] memory reserveAddresses)
    {

        reserveAddresses = new address[](reserveIds.length);
        for (uint256 i = 0; i < reserveIds.length; i++) {
            reserveAddresses[i] = reserveIdToAddresses[reserveIds[i]][0];
        }
    }

    function getRebateWalletsFromIds(bytes32[] calldata reserveIds)
        external
        view
        override
        returns (address[] memory rebateWallets)
    {

        rebateWallets = new address[](reserveIds.length);
        for (uint256 i = 0; i < rebateWallets.length; i++) {
            rebateWallets[i] = reserveRebateWallet[reserveIds[i]];
        }
    }

    function getReserveIdsPerTokenSrc(IERC20 token)
        external
        view
        override
        returns (bytes32[] memory reserveIds)
    {

        reserveIds = reservesPerTokenSrc[token];
    }

    function getReserveAddressesPerTokenSrc(IERC20 token, uint256 startIndex, uint256 endIndex)
        external
        view
        override
        returns (address[] memory reserveAddresses)
    {

        bytes32[] memory reserveIds = reservesPerTokenSrc[token];
        if (reserveIds.length == 0) {
            return reserveAddresses;
        }
        uint256 endId = (endIndex >= reserveIds.length) ? (reserveIds.length - 1) : endIndex;
        if (endId < startIndex) {
            return reserveAddresses;
        }
        reserveAddresses = new address[](endId - startIndex + 1);
        for(uint256 i = startIndex; i <= endId; i++) {
            reserveAddresses[i - startIndex] = reserveIdToAddresses[reserveIds[i]][0];
        }
    }

    function getReserveIdsPerTokenDest(IERC20 token)
        external
        view
        override
        returns (bytes32[] memory reserveIds)
    {

        reserveIds = reservesPerTokenDest[token];
    }

    function getReserveAddressesByReserveId(bytes32 reserveId)
        external
        view
        override
        returns (address[] memory reserveAddresses)
    {

        reserveAddresses = reserveIdToAddresses[reserveId];
    }

    function getContracts()
        external
        view
        returns (
            address[] memory kyberDaoAddresses,
            address[] memory kyberFeeHandlerAddresses,
            address[] memory kyberMatchingEngineAddresses,
            address[] memory kyberNetworkAddresses
        )
    {

        kyberDaoAddresses = kyberDaoHistory.getContracts();
        kyberFeeHandlerAddresses = kyberFeeHandlerHistory.getContracts();
        kyberMatchingEngineAddresses = kyberMatchingEngineHistory.getContracts();
        kyberNetworkAddresses = kyberNetworkHistory.getContracts();
    }

    function getKyberProxies() external view override returns (IKyberNetworkProxy[] memory) {

        return kyberProxyArray;
    }

    function isKyberProxyAdded() external view override returns (bool) {

        return (kyberProxyArray.length > 0);
    }

    function getReserveDetailsById(bytes32 reserveId)
        external
        view
        override
        returns (
            address reserveAddress,
            address rebateWallet,
            ReserveType resType,
            bool isFeeAccountedFlag,
            bool isEntitledRebateFlag
        )
    {

        address[] memory reserveAddresses = reserveIdToAddresses[reserveId];

        if (reserveAddresses.length != 0) {
            reserveAddress = reserveIdToAddresses[reserveId][0];
            rebateWallet = reserveRebateWallet[reserveId];
            uint256 resTypeUint = reserveType[reserveId];
            resType = ReserveType(resTypeUint);
            isFeeAccountedFlag = (feeAccountedPerType & (1 << resTypeUint)) > 0;
            isEntitledRebateFlag = (entitledRebatePerType & (1 << resTypeUint)) > 0;
        }
    }

    function getReserveDetailsByAddress(address reserve)
        external
        view
        override
        returns (
            bytes32 reserveId,
            address rebateWallet,
            ReserveType resType,
            bool isFeeAccountedFlag,
            bool isEntitledRebateFlag
        )
    {

        reserveId = reserveAddressToId[reserve];
        rebateWallet = reserveRebateWallet[reserveId];
        uint256 resTypeUint = reserveType[reserveId];
        resType = ReserveType(resTypeUint);
        isFeeAccountedFlag = (feeAccountedPerType & (1 << resTypeUint)) > 0;
        isEntitledRebateFlag = (entitledRebatePerType & (1 << resTypeUint)) > 0;
    }

    function getListedTokensByReserveId(bytes32 reserveId)
        external
        view
        returns (
            IERC20[] memory srcTokens,
            IERC20[] memory destTokens
        )
    {

        srcTokens = srcTokensPerReserve[reserveId];
        destTokens = destTokensPerReserve[reserveId];
    }

    function getFeeAccountedData(bytes32[] calldata reserveIds)
        external
        view
        override
        returns (bool[] memory feeAccountedArr)
    {

        feeAccountedArr = new bool[](reserveIds.length);

        uint256 feeAccountedData = feeAccountedPerType;

        for (uint256 i = 0; i < reserveIds.length; i++) {
            feeAccountedArr[i] = (feeAccountedData & (1 << reserveType[reserveIds[i]]) > 0);
        }
    }

    function getEntitledRebateData(bytes32[] calldata reserveIds)
        external
        view
        override
        returns (bool[] memory entitledRebateArr)
    {

        entitledRebateArr = new bool[](reserveIds.length);

        uint256 entitledRebateData = entitledRebatePerType;

        for (uint256 i = 0; i < reserveIds.length; i++) {
            entitledRebateArr[i] = (entitledRebateData & (1 << reserveType[reserveIds[i]]) > 0);
        }
    }

    function getReservesData(bytes32[] calldata reserveIds, IERC20 src, IERC20 dest)
        external
        view
        override
        returns (
            bool areAllReservesListed,
            bool[] memory feeAccountedArr,
            bool[] memory entitledRebateArr,
            IKyberReserve[] memory reserveAddresses)
    {

        feeAccountedArr = new bool[](reserveIds.length);
        entitledRebateArr = new bool[](reserveIds.length);
        reserveAddresses = new IKyberReserve[](reserveIds.length);
        areAllReservesListed = true;

        uint256 entitledRebateData = entitledRebatePerType;
        uint256 feeAccountedData = feeAccountedPerType;

        mapping(bytes32 => bool) storage isListedReserveWithToken = (dest == ETH_TOKEN_ADDRESS) ?
            isListedReserveWithTokenSrc[src]:
            isListedReserveWithTokenDest[dest];

        for (uint256 i = 0; i < reserveIds.length; i++) {
            uint256 resType = reserveType[reserveIds[i]];
            entitledRebateArr[i] = (entitledRebateData & (1 << resType) > 0);
            feeAccountedArr[i] = (feeAccountedData & (1 << resType) > 0);
            reserveAddresses[i] = IKyberReserve(reserveIdToAddresses[reserveIds[i]][0]);

            if (!isListedReserveWithToken[reserveIds[i]]){
                areAllReservesListed = false;
                break;
            }
        }
    }

    function delistTokensOfReserve(bytes32 reserveId) internal {

        IERC20[] memory tokensArr = srcTokensPerReserve[reserveId];
        for (uint256 i = 0; i < tokensArr.length; i++) {
            listPairForReserve(reserveId, tokensArr[i], false, true, false);
        }

        tokensArr = destTokensPerReserve[reserveId];
        for (uint256 i = 0; i < tokensArr.length; i++) {
            listPairForReserve(reserveId, tokensArr[i], true, false, false);
        }
    }

    function listPairs(
        bytes32 reserveId,
        IERC20 token,
        bool isTokenToEth,
        bool add
    ) internal {

        uint256 i;
        bytes32[] storage reserveArr = reservesPerTokenDest[token];
        IERC20[] storage tokensArr = destTokensPerReserve[reserveId];
        mapping(bytes32 => bool) storage isListedReserveWithToken = isListedReserveWithTokenDest[token];

        if (isTokenToEth) {
            reserveArr = reservesPerTokenSrc[token];
            tokensArr = srcTokensPerReserve[reserveId];
            isListedReserveWithToken = isListedReserveWithTokenSrc[token];
        }

        for (i = 0; i < reserveArr.length; i++) {
            if (reserveId == reserveArr[i]) {
                if (add) {
                    return; // reserve already added, no further action needed
                } else {
                    reserveArr[i] = reserveArr[reserveArr.length - 1];
                    reserveArr.pop();

                    break;
                }
            }
        }

        if (add) {
            reserveArr.push(reserveId);
            tokensArr.push(token);
            isListedReserveWithToken[reserveId] = true;
        } else {
            for (i = 0; i < tokensArr.length; i++) {
                if (token == tokensArr[i]) {
                    tokensArr[i] = tokensArr[tokensArr.length - 1];
                    tokensArr.pop();
                    break;
                }
            }
            delete isListedReserveWithToken[reserveId];
        }
    }

    function onlyNetwork() internal view {

        require(msg.sender == address(kyberNetwork), "only kyberNetwork");
    }
}