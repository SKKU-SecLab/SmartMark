
pragma solidity 0.8.10;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
library SafeTransferLib {

    event Debug(bool one, bool two, uint256 retsize);


    function safeTransferETH(address to, uint256 amount) internal {

        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
library FixedPointMathLib {


    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }


    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, y)

            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            z := div(z, denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, y)

            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {

        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := scalar
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := scalar
                }
                default {
                    z := x
                }

                let half := shr(1, scalar)

                for {
                    n := shr(1, n)
                } n {
                    n := shr(1, n)
                } {
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    let xx := mul(x, x)

                    let xxRound := add(xx, half)

                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    x := div(xxRound, scalar)

                    if mod(n, 2) {
                        let zx := mul(z, x)

                        if iszero(eq(div(zx, x), z)) {
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        let zxRound := add(zx, half)

                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }


    function sqrt(uint256 x) internal pure returns (uint256 z) {

        assembly {
            z := 1

            let y := x

            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
            }
            if iszero(lt(y, 0x8)) {
                z := shl(1, z)
            }

            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            let zRoundDown := div(x, z)

            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
}

abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;


    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );


    ERC20 public immutable asset;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }


    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }


    function totalAssets() public view virtual returns (uint256);

    function convertToShares(uint256 assets) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }


    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }


    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
abstract contract CERC20 is ERC20 {
    function mint(uint256 underlyingAmount) external virtual returns (uint256);

    function borrow(uint256 underlyingAmount) external virtual returns (uint256);

    function repayBorrow(uint256 underlyingAmount) external virtual returns (uint256);

    function balanceOfUnderlying(address user) external view virtual returns (uint256);

    function exchangeRateStored() external view virtual returns (uint256);

    function redeemUnderlying(uint256 underlyingAmount) external virtual returns (uint256);

    function borrowBalanceCurrent(address user) external virtual returns (uint256);

    function repayBorrowBehalf(address user, uint256 underlyingAmount) external virtual returns (uint256);
}
interface PriceFeed {

    function getUnderlyingPrice(CERC20 cToken) external view returns (uint256);


    function add(address[] calldata underlyings, address[] calldata _oracles) external;


    function changeAdmin(address newAdmin) external;

}

interface Comptroller {

    function admin() external view returns (address);


    function oracle() external view returns (PriceFeed);


    function cTokensByUnderlying(ERC20 token) external view returns (CERC20);



    function markets(CERC20 cToken) external view returns (bool isListed, uint256 collateralFactor);


    function enterMarkets(CERC20[] calldata cTokens) external returns (uint256[] memory);


    function _setPendingAdmin(address newPendingAdmin)
        external
        returns (uint256);


    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;


    function _setMarketSupplyCaps(
        CERC20[] calldata cTokens,
        uint256[] calldata newSupplyCaps
    ) external;


    function _setMarketBorrowCaps(
        CERC20[] calldata cTokens,
        uint256[] calldata newBorrowCaps
    ) external;


    function _setPauseGuardian(address newPauseGuardian)
        external
        returns (uint256);


    function _setMintPaused(CERC20 cToken, bool state)
        external
        returns (bool);


    function _setBorrowPaused(CERC20 cToken, bool borrowPaused)
        external
        returns (bool);


    function _setTransferPaused(bool state) external returns (bool);


    function _setSeizePaused(bool state) external returns (bool);


    function _setPriceOracle(address newOracle)
        external
        returns (uint256);


    function _setCloseFactor(uint256 newCloseFactorMantissa)
        external
        returns (uint256);


    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa)
        external
        returns (uint256);


    function _setCollateralFactor(
        CERC20 cToken,
        uint256 newCollateralFactorMantissa
    ) external returns (uint256);


    function _acceptAdmin() external virtual returns (uint256);


    function _deployMarket(
        bool isCEther,
        bytes calldata constructionData,
        uint256 collateralFactorMantissa
    ) external returns (uint256);


    function borrowGuardianPaused(address cToken)
        external
        view
        returns (bool);


    function comptrollerImplementation()
        external
        view
        returns (address);


    function rewardsDistributors(uint256 index)
        external
        view
        returns (address);


    function _addRewardsDistributor(address distributor)
        external
        returns (uint256);


    function _setWhitelistEnforcement(bool enforce)
        external
        returns (uint256);


    function _setWhitelistStatuses(
        address[] calldata suppliers,
        bool[] calldata statuses
    ) external returns (uint256);


    function _unsupportMarket(CERC20 cToken) external returns (uint256);


    function _toggleAutoImplementations(bool enabled)
        external
        returns (uint256);


    function getAccountLiquidity(address account) external returns (uint256, uint256, uint256);

}/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
abstract contract Auth {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

interface Authority {

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);

}

abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}






interface FuseAdmin {

    function _setWhitelistStatuses(address[] calldata users, bool[] calldata enabled) external;


    function _deployMarket(
        address underlying,
        address irm,
        string calldata name,
        string calldata symbol,
        address impl,
        bytes calldata data,
        uint256 reserveFactor,
        uint256 adminFee,
        uint256 collateralFactorMantissa
    ) external;

}



interface IReverseRegistrar {

    function setName(string memory name) external returns (bytes32);

}

abstract contract ENSReverseRecordAuth is Auth {

    IReverseRegistrar public constant REVERSE_REGISTRAR = IReverseRegistrar(0x084b1c3C81545d370f3634392De611CaaBFf8148);

    function setENSName(string memory name) external requiresAuth {
        REVERSE_REGISTRAR.setName(name);
    }
}

contract TurboBooster is Auth, ENSReverseRecordAuth {


    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}


    bool public frozen;

    event FreezeStatusUpdated(address indexed user, bool frozen);

    function setFreezeStatus(bool freeze) external requiresAuth {

        frozen = freeze;

        emit FreezeStatusUpdated(msg.sender, freeze);
    }


    ERC4626[] public boostableVaults;

    function getBoostableVaults() external view returns(ERC4626[] memory) {

        return boostableVaults;
    }

    mapping(ERC4626 => uint256) public getBoostCapForVault;

    event BoostCapUpdatedForVault(address indexed user, ERC4626 indexed vault, uint256 newBoostCap);

    function setBoostCapForVault(ERC4626 vault, uint256 newBoostCap) external requiresAuth {

        require(newBoostCap != 0, "cap is zero");

        if (getBoostCapForVault[vault] == 0) {
            boostableVaults.push(vault);
        }
        
        getBoostCapForVault[vault] = newBoostCap;

        emit BoostCapUpdatedForVault(msg.sender, vault, newBoostCap);
    }


    mapping(ERC20 => uint256) public getBoostCapForCollateral;

    event BoostCapUpdatedForCollateral(address indexed user, ERC20 indexed collateral, uint256 newBoostCap);

    function setBoostCapForCollateral(ERC20 collateral, uint256 newBoostCap) external requiresAuth {

        getBoostCapForCollateral[collateral] = newBoostCap;

        emit BoostCapUpdatedForCollateral(msg.sender, collateral, newBoostCap);
    }


    function canSafeBoostVault(
        TurboSafe safe,
        ERC20 collateral,
        ERC4626 vault,
        uint256 feiAmount,
        uint256 newTotalBoostedForVault,
        uint256 newTotalBoostedAgainstCollateral
    ) external view returns (bool) {

        return
            !frozen &&
            getBoostCapForVault[vault] >= newTotalBoostedForVault &&
            getBoostCapForCollateral[collateral] >= newTotalBoostedAgainstCollateral;
    }
}





contract TurboMaster is Auth, ENSReverseRecordAuth {

    using SafeTransferLib for ERC20;


    Comptroller public immutable pool;

    ERC20 public immutable fei;


    constructor(
        Comptroller _pool,
        ERC20 _fei,
        address _owner,
        Authority _authority
    ) Auth(_owner, _authority) {
        pool = _pool;

        fei = _fei;

        safes.push(TurboSafe(address(0)));
    }


    TurboBooster public booster;

    event BoosterUpdated(address indexed user, TurboBooster newBooster);

    function setBooster(TurboBooster newBooster) external requiresAuth {

        booster = newBooster;

        emit BoosterUpdated(msg.sender, newBooster);
    }


    TurboClerk public clerk;

    event ClerkUpdated(address indexed user, TurboClerk newClerk);

    function setClerk(TurboClerk newClerk) external requiresAuth {

        clerk = newClerk;

        emit ClerkUpdated(msg.sender, newClerk);
    }


    Authority public defaultSafeAuthority;

    event DefaultSafeAuthorityUpdated(address indexed user, Authority newDefaultSafeAuthority);

    function setDefaultSafeAuthority(Authority newDefaultSafeAuthority) external requiresAuth {

        defaultSafeAuthority = newDefaultSafeAuthority;

        emit DefaultSafeAuthorityUpdated(msg.sender, newDefaultSafeAuthority);
    }


    uint256 public totalBoosted;

    mapping(TurboSafe => uint256) public getSafeId;

    mapping(ERC4626 => uint256) public getTotalBoostedForVault;

    mapping(ERC20 => uint256) public getTotalBoostedAgainstCollateral;

    TurboSafe[] public safes;

    function getAllSafes() external view returns (TurboSafe[] memory) {

        return safes;
    }


    event TurboSafeCreated(address indexed user, ERC20 indexed asset, TurboSafe safe, uint256 id);

    function createSafe(ERC20 asset) external requiresAuth returns (TurboSafe safe, uint256 id) {

        safe = new TurboSafe(msg.sender, defaultSafeAuthority, asset);

        safes.push(safe);

        unchecked {
            id = safes.length - 1;
        }

        getSafeId[safe] = id;

        emit TurboSafeCreated(msg.sender, asset, safe, id);

        address[] memory users = new address[](1);
        users[0] = address(safe);

        bool[] memory enabled = new bool[](1);
        enabled[0] = true;

        FuseAdmin(pool.admin())._setWhitelistStatuses(users, enabled);
    }


    function onSafeBoost(
        ERC20 asset,
        ERC4626 vault,
        uint256 feiAmount
    ) external {

        TurboSafe safe = TurboSafe(msg.sender);

        require(getSafeId[safe] != 0, "INVALID_SAFE");

        totalBoosted += feiAmount;

        uint256 newTotalBoostedForVault;

        uint256 newTotalBoostedAgainstCollateral;

        getTotalBoostedForVault[vault] = (newTotalBoostedForVault = getTotalBoostedForVault[vault] + feiAmount);

        getTotalBoostedAgainstCollateral[asset] = (newTotalBoostedAgainstCollateral =
            getTotalBoostedAgainstCollateral[asset] +
            feiAmount);

        require(
            booster.canSafeBoostVault(
                safe,
                asset,
                vault,
                feiAmount,
                newTotalBoostedForVault,
                newTotalBoostedAgainstCollateral
            ),
            "BOOSTER_REJECTED"
        );
    }

    function onSafeLess(
        ERC20 asset,
        ERC4626 vault,
        uint256 feiAmount
    ) external {

        TurboSafe safe = TurboSafe(msg.sender);

        require(getSafeId[safe] != 0, "INVALID_SAFE");

        getTotalBoostedForVault[vault] -= feiAmount;

        totalBoosted -= feiAmount;

        getTotalBoostedAgainstCollateral[asset] -= feiAmount;
    }


    event TokenSweeped(address indexed user, address indexed to, ERC20 indexed token, uint256 amount);

    function sweep(
        address to,
        ERC20 token,
        uint256 amount
    ) external requiresAuth {

        emit TokenSweeped(msg.sender, to, token, amount);

        token.safeTransfer(to, amount);
    }
}

contract TurboSafe is Auth, ERC4626, ReentrancyGuard {

    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;


    TurboMaster public immutable master;

    ERC20 public immutable fei;

    Comptroller public immutable pool;

    CERC20 public immutable feiTurboCToken;

    CERC20 public immutable assetTurboCToken;


    constructor(
        address _owner,
        Authority _authority,
        ERC20 _asset
    )
        Auth(_owner, _authority)
        ERC4626(
            _asset,
            string(abi.encodePacked(_asset.name(), " Turbo Safe")),
            string(abi.encodePacked("ts", _asset.symbol()))
        )
    {
        master = TurboMaster(msg.sender);

        fei = master.fei();

        require(asset != fei, "INVALID_ASSET");

        pool = master.pool();

        feiTurboCToken = pool.cTokensByUnderlying(fei);

        assetTurboCToken = pool.cTokensByUnderlying(asset);

        require(address(assetTurboCToken) != address(0), "UNSUPPORTED_ASSET");

        CERC20[] memory marketsToEnter = new CERC20[](1);
        marketsToEnter[0] = assetTurboCToken;

        require(pool.enterMarkets(marketsToEnter)[0] == 0, "ENTER_MARKETS_FAILED");

        asset.safeApprove(address(assetTurboCToken), type(uint256).max);

        fei.safeApprove(address(feiTurboCToken), type(uint256).max);
    }


    uint256 public totalFeiBoosted;

    mapping(ERC4626 => uint256) public getTotalFeiBoostedForVault;


    modifier requiresLocalOrMasterAuth() {

        if (msg.sender != owner) {
            Authority masterAuth = master.authority(); // Avoid wasting gas calling the Master twice.

            if (address(masterAuth) == address(0) || !masterAuth.canCall(msg.sender, address(this), msg.sig)) {
                Authority auth = authority; // Memoizing saves us a warm SLOAD, around 100 gas.

                require(
                    address(auth) != address(0) && auth.canCall(msg.sender, address(this), msg.sig),
                    "UNAUTHORIZED"
                );
            }
        }

        _;
    }

    modifier requiresMasterAuth() {

        Authority masterAuth = master.authority(); // Avoid wasting gas calling the Master twice.

        require(
            (address(masterAuth) != address(0) && masterAuth.canCall(msg.sender, address(this), msg.sig)) ||
                msg.sender == master.owner(),
            "UNAUTHORIZED"
        );

        _;
    }


    function afterDeposit(uint256 assetAmount, uint256) internal override nonReentrant requiresAuth {

        require(assetTurboCToken.mint(assetAmount) == 0, "MINT_FAILED");
    }

    function beforeWithdraw(uint256 assetAmount, uint256) internal override nonReentrant requiresAuth {

        require(assetTurboCToken.redeemUnderlying(assetAmount) == 0, "REDEEM_FAILED");
    }

    function totalAssets() public view override returns (uint256) {

        return assetTurboCToken.balanceOf(address(this)).mulWadDown(assetTurboCToken.exchangeRateStored());
    }


    event VaultBoosted(address indexed user, ERC4626 indexed vault, uint256 feiAmount);

    function boost(ERC4626 vault, uint256 feiAmount) external nonReentrant requiresAuth {

        require(vault.asset() == fei, "NOT_FEI");

        master.onSafeBoost(asset, vault, feiAmount);

        totalFeiBoosted += feiAmount;

        getTotalFeiBoostedForVault[vault] += feiAmount;

        emit VaultBoosted(msg.sender, vault, feiAmount);

        require(feiTurboCToken.borrow(feiAmount) == 0, "BORROW_FAILED");

        fei.safeApprove(address(vault), feiAmount);

        vault.deposit(feiAmount, address(this));
    }

    event VaultLessened(address indexed user, ERC4626 indexed vault, uint256 feiAmount);

    function less(ERC4626 vault, uint256 feiAmount) external nonReentrant requiresLocalOrMasterAuth {

        getTotalFeiBoostedForVault[vault] -= feiAmount;

        totalFeiBoosted -= feiAmount;

        emit VaultLessened(msg.sender, vault, feiAmount);

        vault.withdraw(feiAmount, address(this), address(this));

        uint256 feiDebt = feiTurboCToken.borrowBalanceCurrent(address(this));

        master.onSafeLess(asset, vault, feiAmount);

        if (feiAmount > feiDebt) feiAmount = feiDebt;

        if (feiAmount != 0) require(feiTurboCToken.repayBorrow(feiAmount) == 0, "REPAY_FAILED");
    }


    event VaultSlurped(
        address indexed user,
        ERC4626 indexed vault,
        uint256 protocolFeeAmount,
        uint256 safeInterestAmount
    );

    function slurp(ERC4626 vault) external nonReentrant requiresLocalOrMasterAuth returns(uint256 safeInterestAmount) {

        uint256 totalFeiBoostedForVault = getTotalFeiBoostedForVault[vault];

        require(totalFeiBoostedForVault != 0, "NO_FEI_BOOSTED");

        uint256 interestEarned = vault.previewRedeem(vault.balanceOf(address(this))) - totalFeiBoostedForVault;

        uint256 protocolFeePercent = master.clerk().getFeePercentageForSafe(this, asset);

        uint256 protocolFeeAmount = interestEarned.mulWadDown(protocolFeePercent);

        safeInterestAmount = interestEarned - protocolFeeAmount;

        emit VaultSlurped(msg.sender, vault, protocolFeeAmount, safeInterestAmount);

        vault.withdraw(interestEarned, address(this), address(this));

        if (protocolFeeAmount != 0) fei.transfer(address(master), protocolFeeAmount);
    }


    event TokenSweeped(address indexed user, address indexed to, ERC20 indexed token, uint256 amount);

    function sweep(
        address to,
        ERC20 token,
        uint256 amount
    ) external requiresAuth {

        require(getTotalFeiBoostedForVault[ERC4626(address(token))] == 0 && token != assetTurboCToken, "INVALID_TOKEN");

        emit TokenSweeped(msg.sender, to, token, amount);

        token.safeTransfer(to, amount);
    }


    event SafeGibbed(address indexed user, address indexed to, uint256 assetAmount);

    function gib(address to, uint256 assetAmount) external nonReentrant requiresMasterAuth {

        emit SafeGibbed(msg.sender, to, assetAmount);

        require(assetTurboCToken.redeemUnderlying(assetAmount) == 0, "REDEEM_FAILED");

        asset.safeTransfer(to, assetAmount);
    }
}



contract TurboClerk is Auth, ENSReverseRecordAuth {


    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}


    uint256 public defaultFeePercentage;

    event DefaultFeePercentageUpdated(address indexed user, uint256 newDefaultFeePercentage);

    function setDefaultFeePercentage(uint256 newDefaultFeePercentage) external requiresAuth {

        require(newDefaultFeePercentage <= 1e18, "FEE_TOO_HIGH");

        defaultFeePercentage = newDefaultFeePercentage;

        emit DefaultFeePercentageUpdated(msg.sender, newDefaultFeePercentage);
    }


    mapping(ERC20 => uint256) public getCustomFeePercentageForCollateral;

    mapping(TurboSafe => uint256) public getCustomFeePercentageForSafe;

    event CustomFeePercentageUpdatedForCollateral(
        address indexed user,
        ERC20 indexed collateral,
        uint256 newFeePercentage
    );

    function setCustomFeePercentageForCollateral(ERC20 collateral, uint256 newFeePercentage) external requiresAuth {

        require(newFeePercentage <= 1e18, "FEE_TOO_HIGH");

        getCustomFeePercentageForCollateral[collateral] = newFeePercentage;

        emit CustomFeePercentageUpdatedForCollateral(msg.sender, collateral, newFeePercentage);
    }

    event CustomFeePercentageUpdatedForSafe(address indexed user, TurboSafe indexed safe, uint256 newFeePercentage);

    function setCustomFeePercentageForSafe(TurboSafe safe, uint256 newFeePercentage) external requiresAuth {

        require(newFeePercentage <= 1e18, "FEE_TOO_HIGH");

        getCustomFeePercentageForSafe[safe] = newFeePercentage;

        emit CustomFeePercentageUpdatedForSafe(msg.sender, safe, newFeePercentage);
    }


    function getFeePercentageForSafe(TurboSafe safe, ERC20 collateral) external view returns (uint256) {

        uint256 customFeePercentageForSafe = getCustomFeePercentageForSafe[safe];

        if (customFeePercentageForSafe != 0) return customFeePercentageForSafe;

        uint256 customFeePercentageForCollateral = getCustomFeePercentageForCollateral[collateral];

        if (customFeePercentageForCollateral != 0) return customFeePercentageForCollateral;

        return defaultFeePercentage;
    }
}

contract TurboLens {

    Comptroller public immutable pool;

    TurboMaster public immutable master;

    struct StrategyInfo {
        ERC4626 strategy;
        
        uint256 boostedAmount;
        
        uint256 feiAmount;
    }

    struct SafeInfo {
        address safeAddress;

        ERC20 collateralAsset;

        uint256 collateralAmount;

        uint256 collateralPrice;

        uint256 collateralFactor;

        uint256 feiPrice;
        
        uint256 collateralValue;

        uint256 debtAmount;

        uint256 debtValue;

        uint256 boostedAmount;

        uint256 feiAmount;

        uint256 tribeDAOFee;

        StrategyInfo[] strategyInfo;
    }

    constructor (TurboMaster _master) {
        master = _master;
        pool = _master.pool();
    }

    function getAllUserSafes(address owner) external returns (SafeInfo[] memory) {

        TurboSafe[] memory safes = master.getAllSafes();
        uint256 userSafeCount;
        for (uint256 i = 1; i < safes.length; i++) {
            if (safes[i].owner() == owner) userSafeCount += 1;
        }
        
        TurboBooster booster = master.booster();
        TurboClerk clerk = master.clerk();

        ERC4626[] memory strategies = booster.getBoostableVaults();
        PriceFeed oracle = pool.oracle();
        
        SafeInfo[] memory userSafes = new SafeInfo[](userSafeCount);
        uint256 userSafesAdded;
        for (uint256 j = 1; j < safes.length; j++) {
            if (safes[j].owner() == owner) {
                userSafes[userSafesAdded] = _getSafeInfo(safes[j], strategies, oracle, clerk);
                userSafesAdded += 1; 
            }
        }

        return userSafes;
    }

    function getSafeInfo(TurboSafe safe) external returns(SafeInfo memory) {

        TurboBooster booster = master.booster();
        ERC4626[] memory strategies = booster.getBoostableVaults();
        return _getSafeInfo(safe, strategies, pool.oracle(), master.clerk());
    }

    function _getSafeInfo(TurboSafe safe, ERC4626[] memory strategies, PriceFeed oracle, TurboClerk clerk) internal returns (SafeInfo memory) {

        StrategyInfo[] memory info = new StrategyInfo[](strategies.length);

        uint256 totalFeiAmount;
        {
            for (uint256 i = 0; i < strategies.length; i++) {
                ERC4626 strategy = strategies[i];
                uint256 boosted = safe.getTotalFeiBoostedForVault(strategy);
                uint256 feiAmount = strategy.previewRedeem(strategy.balanceOf(address(safe)));

                totalFeiAmount += feiAmount;
                info[i] = StrategyInfo({strategy: strategy, boostedAmount: boosted, feiAmount: feiAmount});
            }
        }

        ERC20 collateral = safe.asset();
        uint256 fee = clerk.getFeePercentageForSafe(safe, collateral);
        uint256 debtAmount = safe.feiTurboCToken().borrowBalanceCurrent(address(safe));
        uint256 feiPrice = oracle.getUnderlyingPrice(safe.feiTurboCToken());

        uint256 collateralAmount = safe.previewRedeem(safe.totalSupply());
        uint256 collateralPrice = oracle.getUnderlyingPrice(safe.assetTurboCToken());
        (, uint256 collateralFactor) = pool.markets(safe.assetTurboCToken());

        return SafeInfo({
            safeAddress: address(safe),
            collateralAsset: collateral, 
            collateralPrice: collateralPrice,
            collateralFactor: collateralFactor,
            feiPrice: feiPrice,
            collateralAmount: collateralAmount,
            collateralValue: collateralAmount * collateralPrice / 1e18,
            debtAmount: debtAmount,
            debtValue: debtAmount * feiPrice / 1e18,
            boostedAmount: safe.totalFeiBoosted(),
            feiAmount: totalFeiAmount,
            tribeDAOFee: fee,
            strategyInfo: info
        });
    }
}