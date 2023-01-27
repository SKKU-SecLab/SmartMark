
pragma solidity 0.8.13;


contract BoringOwnableData {

    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

library Bytes32AddressLib {

    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {

        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {

        return bytes32(bytes20(addressValue));
    }
}

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
}

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

    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
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

abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}

abstract contract IxPYT is ERC4626 {
    function sweep(address receiver) external virtual returns (uint256 shares);
}

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        unchecked {
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            require(denominator > prod1);


            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = (0 - denominator) & denominator;
            assembly {
                denominator := div(denominator, twos)
            }

            assembly {
                prod0 := div(prod0, twos)
            }
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            uint256 inv = (3 * denominator) ^ 2;
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            result = prod0 * inv;
            return result;
        }
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

abstract contract Multicall {
    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

abstract contract SelfPermit {
    function selfPermit(
        ERC20 token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        token.permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    function selfPermitIfNecessary(
        ERC20 token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        if (token.allowance(msg.sender, address(this)) < value)
            selfPermit(token, value, deadline, v, r, s);
    }
}

contract BaseERC20 is ERC20 {


    error Error_NotGate();


    Gate public immutable gate;
    address public immutable vault;


    constructor(
        string memory name_,
        string memory symbol_,
        Gate gate_,
        address vault_
    ) ERC20(name_, symbol_, gate_.getUnderlyingOfVault(vault_).decimals()) {
        gate = gate_;
        vault = vault_;
    }


    function gateMint(address to, uint256 amount) external virtual {

        if (msg.sender != address(gate)) {
            revert Error_NotGate();
        }

        _mint(to, amount);
    }

    function gateBurn(address from, uint256 amount) external virtual {

        if (msg.sender != address(gate)) {
            revert Error_NotGate();
        }

        _burn(from, amount);
    }
}

contract NegativeYieldToken is BaseERC20 {


    constructor(Gate gate_, address vault_)
        BaseERC20(
            gate_.negativeYieldTokenName(vault_),
            gate_.negativeYieldTokenSymbol(vault_),
            gate_,
            vault_
        )
    {}
}

contract PerpetualYieldToken is BaseERC20 {


    constructor(Gate gate_, address vault_)
        BaseERC20(
            gate_.perpetualYieldTokenName(vault_),
            gate_.perpetualYieldTokenSymbol(vault_),
            gate_,
            vault_
        )
    {}


    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        uint256 fromBalance = balanceOf[msg.sender];
        uint256 toBalance = balanceOf[to];

        gate.beforePerpetualYieldTokenTransfer(
            msg.sender,
            to,
            amount,
            fromBalance,
            toBalance
        );

        if (msg.sender != to) {
            balanceOf[msg.sender] = fromBalance - amount;

            unchecked {
                balanceOf[to] = toBalance + amount;
            }
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        uint256 fromBalance = balanceOf[from];
        uint256 toBalance = balanceOf[to];

        gate.beforePerpetualYieldTokenTransfer(
            from,
            to,
            amount,
            fromBalance,
            toBalance
        );

        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        if (from != to) {
            balanceOf[from] = fromBalance - amount;

            unchecked {
                balanceOf[to] = toBalance + amount;
            }
        }

        emit Transfer(from, to, amount);

        return true;
    }
}

abstract contract Gate is
    ReentrancyGuard,
    Multicall,
    SelfPermit,
    BoringOwnable
{

    using SafeTransferLib for ERC20;
    using SafeTransferLib for ERC4626;


    error Error_InvalidInput();
    error Error_VaultSharesNotERC20();
    error Error_TokenPairNotDeployed();
    error Error_EmergencyExitNotActivated();
    error Error_SenderNotPerpetualYieldToken();
    error Error_EmergencyExitAlreadyActivated();


    event EnterWithUnderlying(
        address sender,
        address indexed nytRecipient,
        address indexed pytRecipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    );
    event EnterWithVaultShares(
        address sender,
        address indexed nytRecipient,
        address indexed pytRecipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    );
    event ExitToUnderlying(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    );
    event ExitToVaultShares(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    );
    event ClaimYieldInUnderlying(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        uint256 underlyingAmount
    );
    event ClaimYieldInVaultShares(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        uint256 vaultSharesAmount
    );
    event ClaimYieldAndEnter(
        address sender,
        address indexed nytRecipient,
        address indexed pytRecipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 amount
    );


    struct EmergencyExitStatus {
        bool activated;
        uint96 pytPriceInUnderlying;
    }


    uint256 internal constant PRECISION_DECIMALS = 27;

    uint256 internal constant PRECISION = 10**PRECISION_DECIMALS;


    Factory public immutable factory;


    mapping(address => uint256) public pricePerVaultShareStored;

    mapping(address => uint256) public yieldPerTokenStored;

    mapping(address => mapping(address => uint256))
        public userYieldPerTokenStored;

    mapping(address => mapping(address => uint256)) public userAccruedYield;

    mapping(address => EmergencyExitStatus) public emergencyExitStatusOfVault;


    constructor(Factory factory_) {
        factory = factory_;
    }


    function enterWithUnderlying(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    ) external virtual nonReentrant returns (uint256 mintAmount) {

        if (underlyingAmount == 0) {
            return 0;
        }


        mintAmount = underlyingAmount;
        _enter(
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            underlyingAmount,
            getPricePerVaultShare(vault)
        );

        ERC20 underlying = getUnderlyingOfVault(vault);
        underlying.safeTransferFrom(
            msg.sender,
            address(this),
            underlyingAmount
        );

        _depositIntoVault(underlying, underlyingAmount, vault);

        emit EnterWithUnderlying(
            msg.sender,
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            underlyingAmount
        );
    }

    function enterWithVaultShares(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    ) external virtual nonReentrant returns (uint256 mintAmount) {

        if (vaultSharesAmount == 0) {
            return 0;
        }

        if (!vaultSharesIsERC20()) {
            revert Error_VaultSharesNotERC20();
        }


        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        mintAmount = _vaultSharesAmountToUnderlyingAmount(
            vault,
            vaultSharesAmount,
            updatedPricePerVaultShare
        );
        _enter(
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            mintAmount,
            updatedPricePerVaultShare
        );

        ERC20(vault).safeTransferFrom(
            msg.sender,
            address(this),
            vaultSharesAmount
        );

        emit EnterWithVaultShares(
            msg.sender,
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            vaultSharesAmount
        );
    }

    function exitToUnderlying(
        address recipient,
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    ) external virtual nonReentrant returns (uint256 burnAmount) {

        if (underlyingAmount == 0) {
            return 0;
        }


        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        burnAmount = underlyingAmount;
        _exit(vault, xPYT, underlyingAmount, updatedPricePerVaultShare);

        underlyingAmount = _withdrawFromVault(
            recipient,
            vault,
            underlyingAmount,
            updatedPricePerVaultShare,
            false
        );

        emit ExitToUnderlying(
            msg.sender,
            recipient,
            vault,
            xPYT,
            underlyingAmount
        );
    }

    function exitToVaultShares(
        address recipient,
        address vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    ) external virtual nonReentrant returns (uint256 burnAmount) {

        if (vaultSharesAmount == 0) {
            return 0;
        }

        if (!vaultSharesIsERC20()) {
            revert Error_VaultSharesNotERC20();
        }


        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        burnAmount = _vaultSharesAmountToUnderlyingAmountRoundingUp(
            vault,
            vaultSharesAmount,
            updatedPricePerVaultShare
        );
        _exit(vault, xPYT, burnAmount, updatedPricePerVaultShare);

        ERC20(vault).safeTransfer(recipient, vaultSharesAmount);

        emit ExitToVaultShares(
            msg.sender,
            recipient,
            vault,
            xPYT,
            vaultSharesAmount
        );
    }

    function claimYieldInUnderlying(address recipient, address vault)
        external
        virtual
        nonReentrant
        returns (uint256 yieldAmount)
    {

        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        yieldAmount = _claimYield(vault, updatedPricePerVaultShare);

        if (yieldAmount != 0) {

            (uint8 fee, address protocolFeeRecipient) = factory
                .protocolFeeInfo();

            if (fee != 0) {
                uint256 protocolFee = (yieldAmount * fee) / 1000;
                unchecked {
                    yieldAmount -= protocolFee;
                }

                if (vaultSharesIsERC20()) {
                    protocolFee = _underlyingAmountToVaultSharesAmount(
                        vault,
                        protocolFee,
                        updatedPricePerVaultShare
                    );
                    uint256 vaultSharesBalance = ERC20(vault).balanceOf(
                        address(this)
                    );
                    if (protocolFee > vaultSharesBalance) {
                        protocolFee = vaultSharesBalance;
                    }
                    if (protocolFee != 0) {
                        ERC20(vault).safeTransfer(
                            protocolFeeRecipient,
                            protocolFee
                        );
                    }
                } else {
                    if (protocolFee != 0) {
                        _withdrawFromVault(
                            protocolFeeRecipient,
                            vault,
                            protocolFee,
                            updatedPricePerVaultShare,
                            true
                        );
                    }
                }
            }

            yieldAmount = _withdrawFromVault(
                recipient,
                vault,
                yieldAmount,
                updatedPricePerVaultShare,
                true
            );

            emit ClaimYieldInUnderlying(
                msg.sender,
                recipient,
                vault,
                yieldAmount
            );
        }
    }

    function claimYieldInVaultShares(address recipient, address vault)
        external
        virtual
        nonReentrant
        returns (uint256 yieldAmount)
    {

        if (!vaultSharesIsERC20()) {
            revert Error_VaultSharesNotERC20();
        }


        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        yieldAmount = _claimYield(vault, updatedPricePerVaultShare);

        if (yieldAmount != 0) {

            yieldAmount = _underlyingAmountToVaultSharesAmount(
                vault,
                yieldAmount,
                updatedPricePerVaultShare
            );

            (uint8 fee, address protocolFeeRecipient) = factory
                .protocolFeeInfo();
            uint256 vaultSharesBalance = getVaultShareBalance(vault);
            if (fee != 0) {
                uint256 protocolFee = (yieldAmount * fee) / 1000;
                protocolFee = protocolFee > vaultSharesBalance
                    ? vaultSharesBalance
                    : protocolFee;
                unchecked {
                    yieldAmount -= protocolFee;
                }

                if (protocolFee > 0) {
                    ERC20(vault).safeTransfer(
                        protocolFeeRecipient,
                        protocolFee
                    );

                    vaultSharesBalance -= protocolFee;
                }
            }

            yieldAmount = yieldAmount > vaultSharesBalance
                ? vaultSharesBalance
                : yieldAmount;
            if (yieldAmount > 0) {
                ERC20(vault).safeTransfer(recipient, yieldAmount);
            }

            emit ClaimYieldInVaultShares(
                msg.sender,
                recipient,
                vault,
                yieldAmount
            );
        }
    }

    function claimYieldAndEnter(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT
    ) external virtual nonReentrant returns (uint256 yieldAmount) {
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        yieldAmount = _claimYield(vault, updatedPricePerVaultShare);

        if (yieldAmount != 0) {
            (uint8 fee, address protocolFeeRecipient) = factory
                .protocolFeeInfo();

            if (fee != 0) {
                uint256 protocolFee = (yieldAmount * fee) / 1000;
                unchecked {
                    yieldAmount -= protocolFee;
                }

                if (vaultSharesIsERC20()) {
                    protocolFee = _underlyingAmountToVaultSharesAmount(
                        vault,
                        protocolFee,
                        updatedPricePerVaultShare
                    );
                    uint256 vaultSharesBalance = ERC20(vault).balanceOf(
                        address(this)
                    );
                    if (protocolFee > vaultSharesBalance) {
                        protocolFee = vaultSharesBalance;
                    }
                    if (protocolFee != 0) {
                        ERC20(vault).safeTransfer(
                            protocolFeeRecipient,
                            protocolFee
                        );
                    }
                } else {
                    if (protocolFee != 0) {
                        _withdrawFromVault(
                            protocolFeeRecipient,
                            vault,
                            protocolFee,
                            updatedPricePerVaultShare,
                            true
                        );
                    }
                }
            }

            NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
            PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);

            if (address(xPYT) == address(0)) {
                if (pytRecipient != msg.sender) {
                    _accrueYield(
                        vault,
                        pyt,
                        pytRecipient,
                        updatedPricePerVaultShare
                    );
                }
            } else {
                _accrueYield(
                    vault,
                    pyt,
                    address(xPYT),
                    updatedPricePerVaultShare
                );
            }

            nyt.gateMint(nytRecipient, yieldAmount);
            if (address(xPYT) == address(0)) {
                pyt.gateMint(pytRecipient, yieldAmount);
            } else {
                pyt.gateMint(address(xPYT), yieldAmount);


                xPYT.sweep(pytRecipient);
            }

            emit ClaimYieldAndEnter(
                msg.sender,
                nytRecipient,
                pytRecipient,
                vault,
                xPYT,
                yieldAmount
            );
        }
    }


    function getNegativeYieldTokenForVault(address vault)
        public
        view
        virtual
        returns (NegativeYieldToken)
    {
        return factory.getNegativeYieldToken(this, vault);
    }

    function getPerpetualYieldTokenForVault(address vault)
        public
        view
        virtual
        returns (PerpetualYieldToken)
    {
        return factory.getPerpetualYieldToken(this, vault);
    }

    function getClaimableYieldAmount(address vault, address user)
        external
        view
        virtual
        returns (uint256 yieldAmount)
    {
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        uint256 userYieldPerTokenStored_ = userYieldPerTokenStored[vault][user];
        if (userYieldPerTokenStored_ == 0) {
            return 0;
        }
        yieldAmount = _getClaimableYieldAmount(
            vault,
            user,
            _computeYieldPerToken(vault, pyt, getPricePerVaultShare(vault)),
            userYieldPerTokenStored_,
            pyt.balanceOf(user)
        );
        (uint8 fee, ) = factory.protocolFeeInfo();
        if (fee != 0) {
            uint256 protocolFee = (yieldAmount * fee) / 1000;
            unchecked {
                yieldAmount -= protocolFee;
            }
        }
    }

    function computeYieldPerToken(address vault)
        external
        view
        virtual
        returns (uint256)
    {
        return
            _computeYieldPerToken(
                vault,
                getPerpetualYieldTokenForVault(vault),
                getPricePerVaultShare(vault)
            );
    }

    function getUnderlyingOfVault(address vault)
        public
        view
        virtual
        returns (ERC20);

    function getPricePerVaultShare(address vault)
        public
        view
        virtual
        returns (uint256);

    function getVaultShareBalance(address vault)
        public
        view
        virtual
        returns (uint256);

    function vaultSharesIsERC20() public pure virtual returns (bool);

    function negativeYieldTokenName(address vault)
        external
        view
        virtual
        returns (string memory);

    function negativeYieldTokenSymbol(address vault)
        external
        view
        virtual
        returns (string memory);

    function perpetualYieldTokenName(address vault)
        external
        view
        virtual
        returns (string memory);

    function perpetualYieldTokenSymbol(address vault)
        external
        view
        virtual
        returns (string memory);


    function beforePerpetualYieldTokenTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 fromBalance,
        uint256 toBalance
    ) external virtual {

        if (amount == 0) {
            return;
        }

        address vault = PerpetualYieldToken(msg.sender).vault();
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        if (msg.sender != address(pyt)) {
            revert Error_SenderNotPerpetualYieldToken();
        }


        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        uint256 updatedYieldPerToken = _computeYieldPerToken(
            vault,
            pyt,
            updatedPricePerVaultShare
        );
        yieldPerTokenStored[vault] = updatedYieldPerToken;
        pricePerVaultShareStored[vault] = updatedPricePerVaultShare;

        userAccruedYield[vault][from] =
            _getClaimableYieldAmount(
                vault,
                from,
                updatedYieldPerToken,
                userYieldPerTokenStored[vault][from],
                fromBalance
            ) +
            1;
        userYieldPerTokenStored[vault][from] = updatedYieldPerToken + 1;

        uint256 toUserYieldPerTokenStored = userYieldPerTokenStored[vault][to];
        if (toUserYieldPerTokenStored != 0) {
            userAccruedYield[vault][to] =
                _getClaimableYieldAmount(
                    vault,
                    to,
                    updatedYieldPerToken,
                    toUserYieldPerTokenStored,
                    toBalance
                ) +
                1;
        }
        userYieldPerTokenStored[vault][to] = updatedYieldPerToken + 1;
    }


    function ownerActivateEmergencyExitForVault(
        address vault,
        uint96 pytPriceInUnderlying
    ) external virtual onlyOwner {

        if (emergencyExitStatusOfVault[vault].activated) {
            revert Error_EmergencyExitAlreadyActivated();
        }

        if (pytPriceInUnderlying > PRECISION) {
            revert Error_InvalidInput();
        }

        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        if (address(nyt).code.length == 0) {
            revert Error_TokenPairNotDeployed();
        }


        emergencyExitStatusOfVault[vault] = EmergencyExitStatus({
            activated: true,
            pytPriceInUnderlying: pytPriceInUnderlying
        });
    }

    function ownerDeactivateEmergencyExitForVault(address vault)
        external
        virtual
        onlyOwner
    {

        if (!emergencyExitStatusOfVault[vault].activated) {
            revert Error_EmergencyExitNotActivated();
        }


        delete emergencyExitStatusOfVault[vault];
    }

    function emergencyExitNegativeYieldToken(
        address vault,
        uint256 amount,
        address recipient
    ) external virtual returns (uint256 underlyingAmount) {

        EmergencyExitStatus memory status = emergencyExitStatusOfVault[vault];
        if (!status.activated) {
            revert Error_EmergencyExitNotActivated();
        }


        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);

        _accrueYield(vault, pyt, msg.sender, updatedPricePerVaultShare);

        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        nyt.gateBurn(msg.sender, amount);


        underlyingAmount = FullMath.mulDiv(
            amount,
            PRECISION - status.pytPriceInUnderlying,
            PRECISION
        );

        underlyingAmount = _withdrawFromVault(
            recipient,
            vault,
            underlyingAmount,
            updatedPricePerVaultShare,
            false
        );
    }

    function emergencyExitPerpetualYieldToken(
        address vault,
        IxPYT xPYT,
        uint256 amount,
        address recipient
    ) external virtual returns (uint256 underlyingAmount) {

        EmergencyExitStatus memory status = emergencyExitStatusOfVault[vault];
        if (!status.activated) {
            revert Error_EmergencyExitNotActivated();
        }


        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);

        _accrueYield(vault, pyt, msg.sender, updatedPricePerVaultShare);

        if (address(xPYT) == address(0)) {
            pyt.gateBurn(msg.sender, amount);
        } else {

            xPYT.withdraw(amount, address(this), msg.sender);
            pyt.gateBurn(address(this), amount);
        }


        underlyingAmount = FullMath.mulDiv(
            amount,
            status.pytPriceInUnderlying,
            PRECISION
        );

        underlyingAmount = _withdrawFromVault(
            recipient,
            vault,
            underlyingAmount,
            updatedPricePerVaultShare,
            false
        );
    }


    function _accrueYield(
        address vault,
        PerpetualYieldToken pyt,
        address user,
        uint256 updatedPricePerVaultShare
    ) internal virtual {
        uint256 updatedYieldPerToken = _computeYieldPerToken(
            vault,
            pyt,
            updatedPricePerVaultShare
        );
        uint256 userYieldPerTokenStored_ = userYieldPerTokenStored[vault][user];
        if (userYieldPerTokenStored_ != 0) {
            userAccruedYield[vault][user] =
                _getClaimableYieldAmount(
                    vault,
                    user,
                    updatedYieldPerToken,
                    userYieldPerTokenStored_,
                    pyt.balanceOf(user)
                ) +
                1;
        }
        yieldPerTokenStored[vault] = updatedYieldPerToken;
        pricePerVaultShareStored[vault] = updatedPricePerVaultShare;
        userYieldPerTokenStored[vault][user] = updatedYieldPerToken + 1;
    }

    function _enter(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount,
        uint256 updatedPricePerVaultShare
    ) internal virtual {
        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        if (address(nyt).code.length == 0) {
            factory.deployYieldTokenPair(this, vault);
        }
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);


        _accrueYield(
            vault,
            pyt,
            address(xPYT) == address(0) ? pytRecipient : address(xPYT),
            updatedPricePerVaultShare
        );

        nyt.gateMint(nytRecipient, underlyingAmount);
        if (address(xPYT) == address(0)) {
            pyt.gateMint(pytRecipient, underlyingAmount);
        } else {
            pyt.gateMint(address(xPYT), underlyingAmount);


            xPYT.sweep(pytRecipient);
        }
    }

    function _exit(
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount,
        uint256 updatedPricePerVaultShare
    ) internal virtual {
        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        if (address(nyt).code.length == 0) {
            revert Error_TokenPairNotDeployed();
        }


        _accrueYield(
            vault,
            pyt,
            address(xPYT) == address(0) ? msg.sender : address(this),
            updatedPricePerVaultShare
        );

        nyt.gateBurn(msg.sender, underlyingAmount);
        if (address(xPYT) == address(0)) {
            pyt.gateBurn(msg.sender, underlyingAmount);
        } else {

            xPYT.withdraw(underlyingAmount, address(this), msg.sender);
            pyt.gateBurn(address(this), underlyingAmount);
        }
    }

    function _claimYield(address vault, uint256 updatedPricePerVaultShare)
        internal
        virtual
        returns (uint256 yieldAmount)
    {

        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        if (address(pyt).code.length == 0) {
            revert Error_TokenPairNotDeployed();
        }


        uint256 updatedYieldPerToken = _computeYieldPerToken(
            vault,
            pyt,
            updatedPricePerVaultShare
        );
        uint256 userYieldPerTokenStored_ = userYieldPerTokenStored[vault][
            msg.sender
        ];
        if (userYieldPerTokenStored_ != 0) {
            yieldAmount = _getClaimableYieldAmount(
                vault,
                msg.sender,
                updatedYieldPerToken,
                userYieldPerTokenStored_,
                pyt.balanceOf(msg.sender)
            );
        }
        yieldPerTokenStored[vault] = updatedYieldPerToken;
        pricePerVaultShareStored[vault] = updatedPricePerVaultShare;
        userYieldPerTokenStored[vault][msg.sender] = updatedYieldPerToken + 1;
        if (yieldAmount != 0) {
            userAccruedYield[vault][msg.sender] = 1;
        }
    }

    function _getClaimableYieldAmount(
        address vault,
        address user,
        uint256 updatedYieldPerToken,
        uint256 userYieldPerTokenStored_,
        uint256 userPYTBalance
    ) internal view virtual returns (uint256 yieldAmount) {
        unchecked {
            uint256 actualUserYieldPerToken = userYieldPerTokenStored_ - 1;

            yieldAmount = FullMath.mulDiv(
                userPYTBalance,
                updatedYieldPerToken > actualUserYieldPerToken
                    ? updatedYieldPerToken - actualUserYieldPerToken
                    : 0,
                PRECISION
            );

            uint256 accruedYield = userAccruedYield[vault][user];
            if (accruedYield > 1) {
                yieldAmount += accruedYield - 1;
            }
        }
    }

    function _depositIntoVault(
        ERC20 underlying,
        uint256 underlyingAmount,
        address vault
    ) internal virtual;

    function _withdrawFromVault(
        address recipient,
        address vault,
        uint256 underlyingAmount,
        uint256 pricePerVaultShare,
        bool checkBalance
    ) internal virtual returns (uint256 withdrawnUnderlyingAmount);

    function _vaultSharesAmountToUnderlyingAmount(
        address vault,
        uint256 vaultSharesAmount,
        uint256 pricePerVaultShare
    ) internal view virtual returns (uint256);

    function _vaultSharesAmountToUnderlyingAmountRoundingUp(
        address vault,
        uint256 vaultSharesAmount,
        uint256 pricePerVaultShare
    ) internal view virtual returns (uint256);

    function _underlyingAmountToVaultSharesAmount(
        address vault,
        uint256 underlyingAmount,
        uint256 pricePerVaultShare
    ) internal view virtual returns (uint256);

    function _computeYieldPerToken(
        address vault,
        PerpetualYieldToken pyt,
        uint256 updatedPricePerVaultShare
    ) internal view virtual returns (uint256) {
        uint256 pytTotalSupply = pyt.totalSupply();
        if (pytTotalSupply == 0) {
            return yieldPerTokenStored[vault];
        }
        uint256 pricePerVaultShareStored_ = pricePerVaultShareStored[vault];
        if (updatedPricePerVaultShare <= pricePerVaultShareStored_) {
            return yieldPerTokenStored[vault];
        }
        uint256 newYieldPerTokenAccrued;
        unchecked {
            newYieldPerTokenAccrued = FullMath.mulDiv(
                updatedPricePerVaultShare - pricePerVaultShareStored_,
                getVaultShareBalance(vault),
                pytTotalSupply
            );
        }
        return yieldPerTokenStored[vault] + newYieldPerTokenAccrued;
    }
}

contract Factory is BoringOwnable {


    using Bytes32AddressLib for address;
    using Bytes32AddressLib for bytes32;


    error Error_ProtocolFeeRecipientIsZero();


    event SetProtocolFee(ProtocolFeeInfo protocolFeeInfo_);
    event DeployYieldTokenPair(
        Gate indexed gate,
        address indexed vault,
        NegativeYieldToken nyt,
        PerpetualYieldToken pyt
    );


    struct ProtocolFeeInfo {
        uint8 fee; // each increment represents 0.1%, so max is 25.5%
        address recipient;
    }
    ProtocolFeeInfo public protocolFeeInfo;


    constructor(ProtocolFeeInfo memory protocolFeeInfo_) {
        if (
            protocolFeeInfo_.fee != 0 &&
            protocolFeeInfo_.recipient == address(0)
        ) {
            revert Error_ProtocolFeeRecipientIsZero();
        }
        protocolFeeInfo = protocolFeeInfo_;
        emit SetProtocolFee(protocolFeeInfo_);
    }


    function deployYieldTokenPair(Gate gate, address vault)
        public
        virtual
        returns (NegativeYieldToken nyt, PerpetualYieldToken pyt)
    {

        nyt = new NegativeYieldToken{salt: bytes32(0)}(gate, vault);
        pyt = new PerpetualYieldToken{salt: bytes32(0)}(gate, vault);

        emit DeployYieldTokenPair(gate, vault, nyt, pyt);
    }


    function getNegativeYieldToken(Gate gate, address vault)
        public
        view
        virtual
        returns (NegativeYieldToken)
    {

        return
            NegativeYieldToken(_computeYieldTokenAddress(gate, vault, false));
    }

    function getPerpetualYieldToken(Gate gate, address vault)
        public
        view
        virtual
        returns (PerpetualYieldToken)
    {

        return
            PerpetualYieldToken(_computeYieldTokenAddress(gate, vault, true));
    }


    function ownerSetProtocolFee(ProtocolFeeInfo calldata protocolFeeInfo_)
        external
        virtual
        onlyOwner
    {

        if (
            protocolFeeInfo_.fee != 0 &&
            protocolFeeInfo_.recipient == address(0)
        ) {
            revert Error_ProtocolFeeRecipientIsZero();
        }
        protocolFeeInfo = protocolFeeInfo_;

        emit SetProtocolFee(protocolFeeInfo_);
    }


    function _computeYieldTokenAddress(
        Gate gate,
        address vault,
        bool isPerpetualYieldToken
    ) internal view virtual returns (address) {

        return
            keccak256(
                abi.encodePacked(
                    bytes1(0xFF),
                    address(this),
                    bytes32(0),
                    keccak256(
                        abi.encodePacked(
                            isPerpetualYieldToken
                                ? type(PerpetualYieldToken).creationCode
                                : type(NegativeYieldToken).creationCode,
                            abi.encode(gate, vault)
                        )
                    )
                )
            ).fromLast20Bytes(); // Convert the CREATE2 hash into an address.
    }
}