
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
            bytes32 digest = keccak256(
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
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

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


    function safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
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
                z := shl(64, z)
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z)
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z)
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z)
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z)
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z)
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


    event Deposit(address indexed from, address indexed to, uint256 amount, uint256 shares);

    event Withdraw(address indexed from, address indexed to, uint256 amount, uint256 shares);


    ERC20 public immutable asset;

    uint256 internal immutable ONE;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;

        unchecked {
            ONE = 10**decimals; // >77 decimals is unlikely.
        }
    }


    function deposit(uint256 amount, address to) public virtual returns (uint256 shares) {
        require((shares = previewDeposit(amount)) != 0, "ZERO_SHARES");

        asset.transferFrom(msg.sender, address(this), amount);

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount, shares);

        afterDeposit(amount, shares);
    }

    function mint(uint256 shares, address to) public virtual returns (uint256 amount) {
        amount = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        asset.safeTransferFrom(msg.sender, address(this), amount);

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount, shares);

        afterDeposit(amount, shares);
    }

    function withdraw(
        uint256 amount,
        address to,
        address from
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(amount); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != from) {
            uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - shares;
        }

        beforeWithdraw(amount, shares);

        _burn(from, shares);

        emit Withdraw(from, to, amount, shares);

        asset.safeTransfer(to, amount);
    }

    function redeem(
        uint256 shares,
        address to,
        address from
    ) public virtual returns (uint256 amount) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - shares;

        require((amount = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(amount, shares);

        _burn(from, shares);

        emit Withdraw(from, to, amount, shares);

        asset.safeTransfer(to, amount);
    }


    function totalAssets() public view virtual returns (uint256);

    function assetsOf(address user) public view virtual returns (uint256) {
        return previewRedeem(balanceOf[user]);
    }

    function assetsPerShare() public view virtual returns (uint256) {
        return previewRedeem(ONE);
    }

    function previewDeposit(uint256 amount) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? amount : amount.mulDivDown(supply, totalAssets());
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    function previewWithdraw(uint256 amount) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? amount : amount.mulDivUp(supply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }


    function maxDeposit(address) public virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address user) public virtual returns (uint256) {
        return assetsOf(user);
    }

    function maxRedeem(address user) public virtual returns (uint256) {
        return balanceOf[user];
    }


    function beforeWithdraw(uint256 amount, uint256 shares) internal virtual {}

    function afterDeposit(uint256 amount, uint256 shares) internal virtual {}
}


contract RewardsClaimer {

    using SafeTransferLib for ERC20;

    event RewardDestinationUpdate(address indexed newDestination);

    event ClaimRewards(address indexed rewardToken, uint256 amount);

    address public rewardDestination;

    ERC20[] public rewardTokens;

    constructor(
        address _rewardDestination, 
        ERC20[] memory _rewardTokens
    ) {
        rewardDestination = _rewardDestination;
        rewardTokens = _rewardTokens;
    }

    function claimRewards() public {

        beforeClaim(); // hook to accrue/pull in rewards, if needed

        uint256 len = rewardTokens.length;
        for (uint256 i = 0; i < len; i++) {
            ERC20 token = rewardTokens[i];
            uint256 amount = token.balanceOf(address(this));        

            token.safeTransfer(rewardDestination, amount);

            emit ClaimRewards(address(token), amount);
        }
    }

    function setRewardDestination(address newDestination) external {

        require(msg.sender == rewardDestination, "UNAUTHORIZED");
        rewardDestination = newDestination;
        emit RewardDestinationUpdate(newDestination);
    }

    function beforeClaim() internal virtual {}

}


interface IConvexBooster {
    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);
}

interface IConvexBaseRewardPool {
    function pid() external view returns (uint256);
    function withdrawAndUnwrap(uint256 amount, bool claim) external returns(bool);
    function getReward(address _account, bool _claimExtras) external returns(bool);
    function balanceOf(address account) external view returns (uint256);
    function extraRewards(uint256 index) external view returns(IRewards);
    function extraRewardsLength() external view returns(uint);
    function rewardToken() external view returns(ERC20);
}

interface IRewards {
    function rewardToken() external view returns(ERC20);
}

contract ConvexERC4626 is ERC4626, RewardsClaimer {
    using SafeTransferLib for ERC20;

    IConvexBooster public immutable convexBooster;
    
    IConvexBaseRewardPool public immutable convexRewards;

    ERC20 CVX = ERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);

    uint256 public immutable pid;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol,
        IConvexBooster _convexBooster,
        IConvexBaseRewardPool _convexRewards,
        address _rewardsDestination,
        ERC20[] memory _rewardTokens
    )
        ERC4626(_asset, _name, _symbol)
        RewardsClaimer(_rewardsDestination, _rewardTokens)
    {
        convexBooster = _convexBooster;
        convexRewards = _convexRewards;

        pid = _convexRewards.pid();

        _asset.approve(address(_convexBooster), type(uint256).max);
    }

    function updateRewardTokens() public {
        uint256 len = convexRewards.extraRewardsLength();
        require(len < 5, "exceed max rewards");
        delete rewardTokens;
        bool cvxReward;

        for (uint256 i = 0; i < len; i++) {
            rewardTokens.push(convexRewards.extraRewards(i).rewardToken());
            if (convexRewards.extraRewards(i).rewardToken() == CVX) cvxReward = true;
        }
        if (!cvxReward) rewardTokens.push(CVX);
        rewardTokens.push(convexRewards.rewardToken());
    }

    function afterDeposit(uint256 amount, uint256) internal override {
        require(convexBooster.deposit(pid, amount, true), "deposit error");
    }

    function beforeWithdraw(uint256 amount, uint256) internal override {
        require(convexRewards.withdrawAndUnwrap(amount, false), "withdraw error");
    }

    function beforeClaim() internal override {
        require(convexRewards.getReward(address(this), true), "rewards error");
    }

    function totalAssets() public view override returns (uint256) {
        return convexRewards.balanceOf(address(this));
    }
}