
pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT
pragma solidity >=0.6.11;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// GPL-3.0-or-later

interface IPoolLibrary {

     struct MintFractionalDeiParams {
        uint256 deusPrice;
        uint256 collateralPrice;
        uint256 collateralAmount;
        uint256 collateralRatio;
    }

    struct BuybackDeusParams {
        uint256 excessCollateralValueD18;
        uint256 deusPrice;
        uint256 collateralPrice;
        uint256 deusAmount;
    }

    function calcMint1t1DEI(uint256 col_price, uint256 collateral_amount_d18)
        external
        pure
        returns (uint256);


    function calcMintAlgorithmicDEI(
        uint256 deus_price_usd,
        uint256 deus_amount_d18
    ) external pure returns (uint256);


    function calcMintFractionalDEI(MintFractionalDeiParams memory params)
        external
        pure
        returns (uint256, uint256);


    function calcRedeem1t1DEI(uint256 col_price_usd, uint256 DEI_amount)
        external
        pure
        returns (uint256);


    function calcBuyBackDEUS(BuybackDeusParams memory params)
        external
        pure
        returns (uint256);


    function recollateralizeAmount(
        uint256 total_supply,
        uint256 global_collateral_ratio,
        uint256 global_collat_value
    ) external pure returns (uint256);


    function calcRecollateralizeDEIInner(
        uint256 collateral_amount,
        uint256 col_price,
        uint256 global_collat_value,
        uint256 dei_total_supply,
        uint256 global_collateral_ratio
    ) external pure returns (uint256, uint256);

}// GPL-3.0

struct SchnorrSign {
    uint256 signature;
    address owner;
    address nonce;
}

interface IMuonV02 {

    function verify(
        bytes calldata reqId,
        uint256 hash,
        SchnorrSign[] calldata _sigs
    ) external returns (bool);

}// MIT




interface IDEIPool {

    struct RecollateralizeDeiParams {
        uint256 collateralAmount;
        uint256 poolCollateralPrice;
        uint256[] collateralPrice;
        uint256 deusPrice;
        uint256 expireBlock;
        bytes[] sigs;
    }

    struct RedeemPosition {
        uint256 amount;
        uint256 timestamp;
    }


    function collatDollarBalance(uint256 collateralPrice)
        external
        view
        returns (uint256 balance);


    function positionsLength(address user)
        external
        view
        returns (uint256 length);


    function getAllPositions(address user)
        external
        view
        returns (RedeemPosition[] memory positinos);


    function getUnRedeemedPositions(address user)
        external
        view
        returns (RedeemPosition[] memory positions);


    function mint1t1DEI(uint256 collateralAmount)
        external
        returns (uint256 deiAmount);


    function mintAlgorithmicDEI(
        uint256 deusAmount,
        uint256 deusPrice,
        uint256 expireBlock,
        bytes[] calldata sigs
    ) external returns (uint256 deiAmount);


    function mintFractionalDEI(
        uint256 collateralAmount,
        uint256 deusAmount,
        uint256 deusPrice,
        uint256 expireBlock,
        bytes[] calldata sigs
    ) external returns (uint256 mintAmount);


    function redeem1t1DEI(uint256 deiAmount) external;


    function redeemFractionalDEI(uint256 deiAmount) external;


    function redeemAlgorithmicDEI(uint256 deiAmount) external;


    function collectCollateral() external;


    function collectDeus(
        uint256 price,
        bytes calldata _reqId,
        SchnorrSign[] calldata sigs
    ) external;


    function RecollateralizeDei(RecollateralizeDeiParams memory inputs)
        external;


    function buyBackDeus(
        uint256 deusAmount,
        uint256[] memory collateralPrice,
        uint256 deusPrice,
        uint256 expireBlock,
        bytes[] calldata sigs
    ) external;


    function collectDaoShare(uint256 amount, address to) external;


    function emergencyWithdrawERC20(
        address token,
        uint256 amount,
        address to
    ) external;


    function toggleMinting() external;


    function toggleRedeeming() external;


    function toggleRecollateralize() external;


    function toggleBuyBack() external;


    function setPoolParameters(
        uint256 poolCeiling_,
        uint256 bonusRate_,
        uint256 collateralRedemptionDelay_,
        uint256 deusRedemptionDelay_,
        uint256 mintingFee_,
        uint256 redemptionFee_,
        uint256 buybackFee_,
        uint256 recollatFee_,
        address muon_,
        uint32 appId_,
        uint256 minimumRequiredSignatures_
    ) external;



    event PoolParametersSet(
        uint256 poolCeiling,
        uint256 bonusRate,
        uint256 collateralRedemptionDelay,
        uint256 deusRedemptionDelay,
        uint256 mintingFee,
        uint256 redemptionFee,
        uint256 buybackFee,
        uint256 recollatFee,
        address muon,
        uint32 appId,
        uint256 minimumRequiredSignatures
    );
    event daoShareCollected(uint256 daoShare, address to);
    event MintingToggled(bool toggled);
    event RedeemingToggled(bool toggled);
    event RecollateralizeToggled(bool toggled);
    event BuybackToggled(bool toggled);
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// GPL-3.0-or-later

interface IDEUS {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function pool_burn_from(address b_address, uint256 b_amount) external;

    function pool_mint(address m_address, uint256 m_amount) external;

    function mint(address to, uint256 amount) external;

    function setDEIAddress(address dei_contract_address) external;

    function setNameAndSymbol(string memory _name, string memory _symbol) external;

}// GPL-3.0-or-later

interface IDEI {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function global_collateral_ratio() external view returns (uint256);

    function dei_pools(address _address) external view returns (bool);

    function dei_pools_array() external view returns (address[] memory);

    function verify_price(bytes32 sighash, bytes[] calldata sigs) external view returns (bool);

    function dei_info(uint256[] memory collat_usd_price) external view returns (uint256, uint256, uint256);

    function getChainID() external view returns (uint256);

    function globalCollateralValue(uint256[] memory collat_usd_price) external view returns (uint256);

    function refreshCollateralRatio(uint deus_price, uint dei_price, uint256 expire_block, bytes[] calldata sigs) external;

    function useGrowthRatio(bool _use_growth_ratio) external;

    function setGrowthRatioBands(uint256 _GR_top_band, uint256 _GR_bottom_band) external;

    function setPriceBands(uint256 _top_band, uint256 _bottom_band) external;

    function activateDIP(bool _activate) external;

    function pool_burn_from(address b_address, uint256 b_amount) external;

    function pool_mint(address m_address, uint256 m_amount) external;

    function addPool(address pool_address) external;

    function removePool(address pool_address) external;

    function setNameAndSymbol(string memory _name, string memory _symbol) external;

    function setOracle(address _oracle) external;

    function setDEIStep(uint256 _new_step) external;

    function setReserveTracker(address _reserve_tracker_address) external;

    function setRefreshCooldown(uint256 _new_cooldown) external;

    function setDEUSAddress(address _deus_address) external;

    function toggleCollateralRatio() external;

}// Be name Khoda

pragma solidity 0.8.13;
pragma abicoder v2;




contract DEIPool is IDEIPool, AccessControl {

    address public collateral;
    address private dei;
    address private deus;

    uint256 public mintingFee;
    uint256 public redemptionFee = 10000;
    uint256 public buybackFee = 5000;
    uint256 public recollatFee = 5000;

    mapping(address => uint256) public redeemCollateralBalances;
    uint256 public unclaimedPoolCollateral;
    mapping(address => uint256) public lastCollateralRedeemed;

    mapping(address => IDEIPool.RedeemPosition[]) public redeemPositions;
    mapping(address => uint256) public nextRedeemId;

    uint256 public collateralRedemptionDelay;
    uint256 public deusRedemptionDelay;

    uint256 private constant PRICE_PRECISION = 1e6;
    uint256 private constant COLLATERAL_RATIO_PRECISION = 1e6;
    uint256 private constant COLLATERAL_RATIO_MAX = 1e6;
    uint256 private constant COLLATERAL_PRICE = 1e6;
    uint256 private constant SCALE = 1e6;

    uint256 private immutable missingDecimals;

    uint256 public poolCeiling;

    uint256 public bonusRate = 7500;

    uint256 public daoShare = 0; // fees goes to daoWallet

    address public poolLibrary; // Pool library contract

    address public muon;
    uint32 public appId;
    uint256 minimumRequiredSignatures;

    bytes32 public constant PARAMETER_SETTER_ROLE =
        keccak256("PARAMETER_SETTER_ROLE");
    bytes32 public constant DAO_SHARE_COLLECTOR =
        keccak256("DAO_SHARE_COLLECTOR");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TRUSTY_ROLE = keccak256("TRUSTY_ROLE");

    bool public mintPaused = false;
    bool public redeemPaused = false;
    bool public recollateralizePaused = false;
    bool public buyBackPaused = false;

    modifier notRedeemPaused() {

        require(redeemPaused == false, "DEIPool: REDEEM_PAUSED");
        _;
    }

    modifier notMintPaused() {

        require(mintPaused == false, "DEIPool: MINTING_PAUSED");
        _;
    }


    constructor(
        address dei_,
        address deus_,
        address collateral_,
        address muon_,
        address library_,
        address admin,
        uint256 minimumRequiredSignatures_,
        uint256 collateralRedemptionDelay_,
        uint256 deusRedemptionDelay_,
        uint256 poolCeiling_,
        uint32 appId_
    ) {
        require(
            (dei_ != address(0)) &&
                (deus_ != address(0)) &&
                (collateral_ != address(0)) &&
                (library_ != address(0)) &&
                (admin != address(0)),
            "DEIPool: ZERO_ADDRESS_DETECTED"
        );
        dei = dei_;
        deus = deus_;
        collateral = collateral_;
        muon = muon_;
        appId = appId_;
        minimumRequiredSignatures = minimumRequiredSignatures_;
        collateralRedemptionDelay = collateralRedemptionDelay_;
        deusRedemptionDelay = deusRedemptionDelay_;
        poolCeiling = poolCeiling_;
        poolLibrary = library_;
        missingDecimals = uint256(18) - IERC20(collateral).decimals();

        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }


    function collatDollarBalance(uint256 collateralPrice)
        public
        view
        returns (uint256 balance)
    {

        balance =
            ((IERC20(collateral).balanceOf(address(this)) -
                unclaimedPoolCollateral) *
                (10**missingDecimals) *
                collateralPrice) /
            (PRICE_PRECISION);
    }

    function availableExcessCollatDV(uint256[] memory collateralPrice)
        public
        view
        returns (uint256)
    {

        uint256 totalSupply = IDEI(dei).totalSupply();
        uint256 globalCollateralRatio = IDEI(dei).global_collateral_ratio();
        uint256 globalCollateralValue = IDEI(dei).globalCollateralValue(
            collateralPrice
        );

        if (globalCollateralRatio > COLLATERAL_RATIO_PRECISION)
            globalCollateralRatio = COLLATERAL_RATIO_PRECISION; // Handles an overcollateralized contract with CR > 1
        uint256 requiredCollateralDollarValued18 = (totalSupply *
            globalCollateralRatio) / (COLLATERAL_RATIO_PRECISION); // Calculates collateral needed to back each 1 DEI with $1 of collateral at current collat ratio
        if (globalCollateralValue > requiredCollateralDollarValued18)
            return globalCollateralValue - requiredCollateralDollarValued18;
        else return 0;
    }

    function positionsLength(address user)
        external
        view
        returns (uint256 length)
    {

        length = redeemPositions[user].length;
    }

    function getAllPositions(address user)
        external
        view
        returns (RedeemPosition[] memory positions)
    {

        positions = redeemPositions[user];
    }

    function getUnRedeemedPositions(address user)
        external
        view
        returns (RedeemPosition[] memory)
    {

        uint256 totalRedeemPositions = redeemPositions[user].length;
        uint256 redeemId = nextRedeemId[user];

        RedeemPosition[] memory positions = new RedeemPosition[](
            totalRedeemPositions - redeemId + 1
        );
        uint256 index = 0;
        for (uint256 i = redeemId; i < totalRedeemPositions; i++) {
            positions[index] = redeemPositions[user][i];
            index++;
        }

        return positions;
    }

    function _getChainId() internal view returns (uint256 id) {

        assembly {
            id := chainid()
        }
    }


    function mint1t1DEI(uint256 collateralAmount)
        external
        notMintPaused
        returns (uint256 deiAmount)
    {

        require(
            IDEI(dei).global_collateral_ratio() >= COLLATERAL_RATIO_MAX,
            "DEIPool: INVALID_COLLATERAL_RATIO"
        );
        require(
            IERC20(collateral).balanceOf(address(this)) -
                unclaimedPoolCollateral +
                collateralAmount <=
                poolCeiling,
            "DEIPool: CEILING_REACHED"
        );

        uint256 collateralAmountD18 = collateralAmount * (10**missingDecimals);
        deiAmount = IPoolLibrary(poolLibrary).calcMint1t1DEI(
            COLLATERAL_PRICE,
            collateralAmountD18
        ); //1 DEI for each $1 worth of collateral

        deiAmount = (deiAmount * (SCALE - mintingFee)) / SCALE; //remove precision at the end

        TransferHelper.safeTransferFrom(
            collateral,
            msg.sender,
            address(this),
            collateralAmount
        );

        daoShare += (deiAmount * mintingFee) / SCALE;
        IDEI(dei).pool_mint(msg.sender, deiAmount);
    }

    function mintAlgorithmicDEI(
        uint256 deusAmount,
        uint256 deusPrice,
        uint256 expireBlock,
        bytes[] calldata sigs
    ) external notMintPaused returns (uint256 deiAmount) {

        require(
            IDEI(dei).global_collateral_ratio() == 0,
            "DEIPool: INVALID_COLLATERAL_RATIO"
        );
        require(expireBlock >= block.number, "DEIPool: EXPIRED_SIGNATURE");
        bytes32 sighash = keccak256(
            abi.encodePacked(deus, deusPrice, expireBlock, _getChainId())
        );
        require(
            IDEI(dei).verify_price(sighash, sigs),
            "DEIPool: UNVERIFIED_SIGNATURE"
        );

        deiAmount = IPoolLibrary(poolLibrary).calcMintAlgorithmicDEI(
            deusPrice, // X DEUS / 1 USD
            deusAmount
        );

        deiAmount = (deiAmount * (SCALE - (mintingFee))) / SCALE;
        daoShare += (deiAmount * mintingFee) / SCALE;

        IDEUS(deus).pool_burn_from(msg.sender, deusAmount);
        IDEI(dei).pool_mint(msg.sender, deiAmount);
    }

    function mintFractionalDEI(
        uint256 collateralAmount,
        uint256 deusAmount,
        uint256 deusPrice,
        uint256 expireBlock,
        bytes[] calldata sigs
    ) external notMintPaused returns (uint256 mintAmount) {

        uint256 globalCollateralRatio = IDEI(dei).global_collateral_ratio();
        require(
            globalCollateralRatio < COLLATERAL_RATIO_MAX &&
                globalCollateralRatio > 0,
            "DEIPool: INVALID_COLLATERAL_RATIO"
        );
        require(
            IERC20(collateral).balanceOf(address(this)) -
                unclaimedPoolCollateral +
                collateralAmount <=
                poolCeiling,
            "DEIPool: CEILING_REACHED"
        );

        require(expireBlock >= block.number, "DEIPool: EXPIRED_SIGNATURE");
        bytes32 sighash = keccak256(
            abi.encodePacked(deus, deusPrice, expireBlock, _getChainId())
        );
        require(
            IDEI(dei).verify_price(sighash, sigs),
            "DEIPool: UNVERIFIED_SIGNATURE"
        );

        IPoolLibrary.MintFractionalDeiParams memory inputParams;

        {
            uint256 collateralAmountD18 = collateralAmount *
                (10**missingDecimals);
            inputParams = IPoolLibrary.MintFractionalDeiParams(
                deusPrice,
                COLLATERAL_PRICE,
                collateralAmountD18,
                globalCollateralRatio
            );
        }

        uint256 deusNeeded;
        (mintAmount, deusNeeded) = IPoolLibrary(poolLibrary)
            .calcMintFractionalDEI(inputParams);
        require(deusNeeded <= deusAmount, "INSUFFICIENT_DEUS_INPUTTED");

        mintAmount = (mintAmount * (SCALE - mintingFee)) / SCALE;

        IDEUS(deus).pool_burn_from(msg.sender, deusNeeded);

        TransferHelper.safeTransferFrom(
            collateral,
            msg.sender,
            address(this),
            collateralAmount
        );

        daoShare += (mintAmount * mintingFee) / SCALE;
        IDEI(dei).pool_mint(msg.sender, mintAmount);
    }

    function redeem1t1DEI(uint256 deiAmount) external notRedeemPaused {

        require(
            IDEI(dei).global_collateral_ratio() == COLLATERAL_RATIO_MAX,
            "DEIPool: INVALID_COLLATERAL_RATIO"
        );

        uint256 deiAmountPrecision = deiAmount / (10**missingDecimals);
        uint256 collateralNeeded = IPoolLibrary(poolLibrary).calcRedeem1t1DEI(
            COLLATERAL_PRICE,
            deiAmountPrecision
        );

        collateralNeeded = (collateralNeeded * (SCALE - redemptionFee)) / SCALE;
        require(
            collateralNeeded <=
                IERC20(collateral).balanceOf(address(this)) -
                    unclaimedPoolCollateral,
            "DEIPool: INSUFFICIENT_COLLATERAL_BALANCE"
        );

        redeemCollateralBalances[msg.sender] =
            redeemCollateralBalances[msg.sender] +
            collateralNeeded;
        unclaimedPoolCollateral = unclaimedPoolCollateral + collateralNeeded;
        lastCollateralRedeemed[msg.sender] = block.number;

        daoShare += (deiAmount * redemptionFee) / SCALE;
        IDEI(dei).pool_burn_from(msg.sender, deiAmount);
    }

    function redeemFractionalDEI(uint256 deiAmount) external notRedeemPaused {

        uint256 globalCollateralRatio = IDEI(dei).global_collateral_ratio();
        require(
            globalCollateralRatio < COLLATERAL_RATIO_MAX &&
                globalCollateralRatio > 0,
            "DEIPool: INVALID_COLLATERAL_RATIO"
        );

        uint256 collateralAmount;
        {
            uint256 deiAmountPostFee = (deiAmount * (SCALE - redemptionFee)) /
                (PRICE_PRECISION);
            uint256 deiAmountPrecision = deiAmountPostFee /
                (10**missingDecimals);
            collateralAmount =
                (deiAmountPrecision * globalCollateralRatio) /
                PRICE_PRECISION;
        }
        require(
            collateralAmount <=
                IERC20(collateral).balanceOf(address(this)) -
                    unclaimedPoolCollateral,
            "DEIPool: NOT_ENOUGH_COLLATERAL"
        );

        redeemCollateralBalances[msg.sender] += collateralAmount;
        lastCollateralRedeemed[msg.sender] = block.timestamp;
        unclaimedPoolCollateral = unclaimedPoolCollateral + collateralAmount;

        {
            uint256 deiAmountPostFee = (deiAmount * (SCALE - redemptionFee)) /
                SCALE;
            uint256 deusDollarAmount = (deiAmountPostFee *
                (SCALE - globalCollateralRatio)) / SCALE;

            redeemPositions[msg.sender].push(
                RedeemPosition({
                    amount: deusDollarAmount,
                    timestamp: block.timestamp
                })
            );
        }

        daoShare += (deiAmount * redemptionFee) / SCALE;

        IDEI(dei).pool_burn_from(msg.sender, deiAmount);
    }

    function redeemAlgorithmicDEI(uint256 deiAmount) external notRedeemPaused {

        require(
            IDEI(dei).global_collateral_ratio() == 0,
            "DEIPool: INVALID_COLLATERAL_RATIO"
        );

        uint256 deusDollarAmount = (deiAmount * (SCALE - redemptionFee)) /
            (PRICE_PRECISION);
        redeemPositions[msg.sender].push(
            RedeemPosition({
                amount: deusDollarAmount,
                timestamp: block.timestamp
            })
        );
        daoShare += (deiAmount * redemptionFee) / SCALE;
        IDEI(dei).pool_burn_from(msg.sender, deiAmount);
    }

    function collectCollateral() external {

        require(
            (lastCollateralRedeemed[msg.sender] + collateralRedemptionDelay) <=
                block.timestamp,
            "DEIPool: COLLATERAL_REDEMPTION_DELAY"
        );

        if (redeemCollateralBalances[msg.sender] > 0) {
            uint256 collateralAmount = redeemCollateralBalances[msg.sender];
            redeemCollateralBalances[msg.sender] = 0;
            TransferHelper.safeTransfer(
                collateral,
                msg.sender,
                collateralAmount
            );
            unclaimedPoolCollateral =
                unclaimedPoolCollateral -
                collateralAmount;
        }
    }

    function collectDeus(
        uint256 price,
        bytes calldata _reqId,
        SchnorrSign[] calldata sigs
    ) external {

        require(
            sigs.length >= minimumRequiredSignatures,
            "DEIPool: INSUFFICIENT_SIGNATURES"
        );

        uint256 redeemId = nextRedeemId[msg.sender]++;

        require(
            redeemPositions[msg.sender][redeemId].timestamp +
                deusRedemptionDelay <=
                block.timestamp,
            "DEIPool: DEUS_REDEMPTION_DELAY"
        );

        {
            bytes32 hash = keccak256(
                abi.encodePacked(
                    appId,
                    msg.sender,
                    redeemId,
                    price,
                    _getChainId()
                )
            );
            require(
                IMuonV02(muon).verify(_reqId, uint256(hash), sigs),
                "DEIPool: UNVERIFIED_SIGNATURES"
            );
        }

        uint256 deusAmount = (redeemPositions[msg.sender][redeemId].amount *
            1e18) / price;

        IDEUS(deus).pool_mint(msg.sender, deusAmount);
    }

    function RecollateralizeDei(RecollateralizeDeiParams memory inputs)
        external
    {

        require(
            recollateralizePaused == false,
            "DEIPool: RECOLLATERALIZE_PAUSED"
        );

        require(
            inputs.expireBlock >= block.number,
            "DEIPool: EXPIRE_SIGNATURE"
        );
        bytes32 sighash = keccak256(
            abi.encodePacked(
                deus,
                inputs.deusPrice,
                inputs.expireBlock,
                _getChainId()
            )
        );
        require(
            IDEI(dei).verify_price(sighash, inputs.sigs),
            "DEIPool: UNVERIFIED_SIGNATURES"
        );

        uint256 collateralAmountD18 = inputs.collateralAmount *
            (10**missingDecimals);

        uint256 deiTotalSupply = IDEI(dei).totalSupply();
        uint256 globalCollateralRatio = IDEI(dei).global_collateral_ratio();
        uint256 globalCollateralValue = IDEI(dei).globalCollateralValue(
            inputs.collateralPrice
        );

        (uint256 collateralUnits, uint256 amountToRecollat) = IPoolLibrary(
            poolLibrary
        ).calcRecollateralizeDEIInner(
                collateralAmountD18,
                inputs.collateralPrice[inputs.collateralPrice.length - 1], // pool collateral price exist in last index
                globalCollateralValue,
                deiTotalSupply,
                globalCollateralRatio
            );

        uint256 collateralUnitsPrecision = collateralUnits /
            (10**missingDecimals);

        uint256 deusPaidBack = (amountToRecollat *
            (SCALE + bonusRate - recollatFee)) / inputs.deusPrice;

        TransferHelper.safeTransferFrom(
            collateral,
            msg.sender,
            address(this),
            collateralUnitsPrecision
        );
        IDEUS(deus).pool_mint(msg.sender, deusPaidBack);
    }

    function buyBackDeus(
        uint256 deusAmount,
        uint256[] memory collateralPrice,
        uint256 deusPrice,
        uint256 expireBlock,
        bytes[] calldata sigs
    ) external {

        require(buyBackPaused == false, "DEIPool: BUYBACK_PAUSED");
        require(expireBlock >= block.number, "DEIPool: EXPIRED_SIGNATURE");
        bytes32 sighash = keccak256(
            abi.encodePacked(
                collateral,
                collateralPrice,
                deus,
                deusPrice,
                expireBlock,
                _getChainId()
            )
        );
        require(
            IDEI(dei).verify_price(sighash, sigs),
            "DEIPool: UNVERIFIED_SIGNATURE"
        );

        IPoolLibrary.BuybackDeusParams memory inputParams = IPoolLibrary
            .BuybackDeusParams(
                availableExcessCollatDV(collateralPrice),
                deusPrice,
                collateralPrice[collateralPrice.length - 1], // pool collateral price exist in last index
                deusAmount
            );

        uint256 collateralEquivalentD18 = (IPoolLibrary(poolLibrary)
            .calcBuyBackDEUS(inputParams) * (SCALE - buybackFee)) / SCALE;
        uint256 collateralPrecision = collateralEquivalentD18 /
            (10**missingDecimals);

        IDEUS(deus).pool_burn_from(msg.sender, deusAmount);
        TransferHelper.safeTransfer(
            collateral,
            msg.sender,
            collateralPrecision
        );
    }


    function collectDaoShare(uint256 amount, address to)
        external
        onlyRole(DAO_SHARE_COLLECTOR)
    {

        require(amount <= daoShare, "DEIPool: INVALID_AMOUNT");

        IDEI(dei).pool_mint(to, amount);
        daoShare -= amount;

        emit daoShareCollected(amount, to);
    }

    function emergencyWithdrawERC20(
        address token,
        uint256 amount,
        address to
    ) external onlyRole(TRUSTY_ROLE) {

        IERC20(token).transfer(to, amount);
    }

    function toggleMinting() external onlyRole(PAUSER_ROLE) {

        mintPaused = !mintPaused;
        emit MintingToggled(mintPaused);
    }

    function toggleRedeeming() external onlyRole(PAUSER_ROLE) {

        redeemPaused = !redeemPaused;
        emit RedeemingToggled(redeemPaused);
    }

    function toggleRecollateralize() external onlyRole(PAUSER_ROLE) {

        recollateralizePaused = !recollateralizePaused;
        emit RecollateralizeToggled(recollateralizePaused);
    }

    function toggleBuyBack() external onlyRole(PAUSER_ROLE) {

        buyBackPaused = !buyBackPaused;
        emit BuybackToggled(buyBackPaused);
    }

    function setPoolParameters(
        uint256 poolCeiling_,
        uint256 bonusRate_,
        uint256 collateralRedemptionDelay_,
        uint256 deusRedemptionDelay_,
        uint256 mintingFee_,
        uint256 redemptionFee_,
        uint256 buybackFee_,
        uint256 recollatFee_,
        address muon_,
        uint32 appId_,
        uint256 minimumRequiredSignatures_
    ) external onlyRole(PARAMETER_SETTER_ROLE) {

        poolCeiling = poolCeiling_;
        bonusRate = bonusRate_;
        collateralRedemptionDelay = collateralRedemptionDelay_;
        deusRedemptionDelay = deusRedemptionDelay_;
        mintingFee = mintingFee_;
        redemptionFee = redemptionFee_;
        buybackFee = buybackFee_;
        recollatFee = recollatFee_;
        muon = muon_;
        appId = appId_;
        minimumRequiredSignatures = minimumRequiredSignatures_;

        emit PoolParametersSet(
            poolCeiling_,
            bonusRate_,
            collateralRedemptionDelay_,
            deusRedemptionDelay_,
            mintingFee_,
            redemptionFee_,
            buybackFee_,
            recollatFee_,
            muon_,
            appId_,
            minimumRequiredSignatures_
        );
    }
}

