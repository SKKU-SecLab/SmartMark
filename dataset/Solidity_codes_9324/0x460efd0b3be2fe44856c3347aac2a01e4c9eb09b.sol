

pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

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
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
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



pragma solidity >=0.8.0;

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



pragma solidity >=0.8.0;

library Bytes32AddressLib {

    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {

        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {

        return bytes32(bytes20(addressValue));
    }
}



pragma solidity >=0.8.0;

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



pragma solidity >=0.8.0;

contract WETH is ERC20("Wrapped Ether", "WETH", 18) {

    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {

        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {

        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

    receive() external payable virtual {
        deposit();
    }
}



pragma solidity >=0.8.0;

library SafeCastLib {

    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {

        require(x <= type(uint248).max);

        y = uint248(x);
    }

    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {

        require(x <= type(uint128).max);

        y = uint128(x);
    }

    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {

        require(x <= type(uint96).max);

        y = uint96(x);
    }

    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {

        require(x <= type(uint64).max);

        y = uint64(x);
    }

    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {

        require(x <= type(uint32).max);

        y = uint32(x);
    }
}



pragma solidity >=0.8.0;

library FixedPointMathLib {


    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivDown(x, y, WAD);
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivUp(x, y, WAD);
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivDown(x, WAD, y);
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivUp(x, WAD, y);
    }

    function fmul(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, y)

            if iszero(or(iszero(x), eq(div(z, x), y))) {
                revert(0, 0)
            }

            z := div(z, baseUnit)
        }
    }

    function fdiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, baseUnit)

            if iszero(and(iszero(iszero(y)), or(iszero(x), eq(div(z, x), baseUnit)))) {
                revert(0, 0)
            }

            z := div(z, y)
        }
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
        uint256 denominator
    ) internal pure returns (uint256 z) {

        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := denominator
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := denominator
                }
                default {
                    z := x
                }

                let half := shr(1, denominator)

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

                    x := div(xxRound, denominator)

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

                        z := div(zxRound, denominator)
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



pragma solidity ^0.8.11;

abstract contract Strategy is ERC20 {
    function isCEther() external view virtual returns (bool);

    function redeemUnderlying(uint256 amount) external virtual returns (uint256);

    function balanceOfUnderlying(address user) external virtual returns (uint256);
}

abstract contract ERC20Strategy is Strategy {
    function underlying() external view virtual returns (ERC20);

    function mint(uint256 amount) external virtual returns (uint256);
}

abstract contract ETHStrategy is Strategy {
    function mint() external payable virtual;
}



pragma solidity ^0.8.11;






contract Vault is ERC20, Auth {

    using SafeCastLib for uint256;
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;


    uint256 internal constant MAX_WITHDRAWAL_STACK_SIZE = 32;


    ERC20 public immutable UNDERLYING;

    uint256 internal immutable BASE_UNIT;

    constructor(ERC20 _UNDERLYING)
        ERC20(
            string(abi.encodePacked("Aphra ", _UNDERLYING.name(), " Vault")),
            string(abi.encodePacked("av", _UNDERLYING.symbol())),
            _UNDERLYING.decimals()
        )
        Auth(Auth(msg.sender).owner(), Auth(msg.sender).authority())
    {
        UNDERLYING = _UNDERLYING;

        BASE_UNIT = 10**decimals;

        totalSupply = type(uint256).max;
    }


    uint256 public feePercent;

    event FeePercentUpdated(address indexed user, uint256 newFeePercent);

    function setFeePercent(uint256 newFeePercent) external requiresAuth {

        require(newFeePercent <= 1e18, "FEE_TOO_HIGH");

        feePercent = newFeePercent;

        emit FeePercentUpdated(msg.sender, newFeePercent);
    }


    event HarvestWindowUpdated(address indexed user, uint128 newHarvestWindow);

    event HarvestDelayUpdated(address indexed user, uint64 newHarvestDelay);

    event HarvestDelayUpdateScheduled(address indexed user, uint64 newHarvestDelay);

    uint128 public harvestWindow;

    uint64 public harvestDelay;

    uint64 public nextHarvestDelay;

    function setHarvestWindow(uint128 newHarvestWindow) external requiresAuth {

        require(newHarvestWindow <= harvestDelay, "WINDOW_TOO_LONG");

        harvestWindow = newHarvestWindow;

        emit HarvestWindowUpdated(msg.sender, newHarvestWindow);
    }

    function setHarvestDelay(uint64 newHarvestDelay) external requiresAuth {

        require(newHarvestDelay != 0, "DELAY_CANNOT_BE_ZERO");

        require(newHarvestDelay <= 365 days, "DELAY_TOO_LONG");

        if (harvestDelay == 0) {
            harvestDelay = newHarvestDelay;

            emit HarvestDelayUpdated(msg.sender, newHarvestDelay);
        } else {
            nextHarvestDelay = newHarvestDelay;

            emit HarvestDelayUpdateScheduled(msg.sender, newHarvestDelay);
        }
    }


    uint256 public targetFloatPercent;

    event TargetFloatPercentUpdated(address indexed user, uint256 newTargetFloatPercent);

    function setTargetFloatPercent(uint256 newTargetFloatPercent) external requiresAuth {

        require(newTargetFloatPercent <= 1e18, "TARGET_TOO_HIGH");

        targetFloatPercent = newTargetFloatPercent;

        emit TargetFloatPercentUpdated(msg.sender, newTargetFloatPercent);
    }


    bool public underlyingIsWETH;

    event UnderlyingIsWETHUpdated(address indexed user, bool newUnderlyingIsWETH);

    function setUnderlyingIsWETH(bool newUnderlyingIsWETH) external requiresAuth {

        require(!newUnderlyingIsWETH || UNDERLYING.decimals() == 18, "WRONG_DECIMALS");

        underlyingIsWETH = newUnderlyingIsWETH;

        emit UnderlyingIsWETHUpdated(msg.sender, newUnderlyingIsWETH);
    }


    uint256 public totalStrategyHoldings;

    struct StrategyData {
        bool trusted;
        uint248 balance;
    }

    mapping(Strategy => StrategyData) public getStrategyData;


    uint64 public lastHarvestWindowStart;

    uint64 public lastHarvest;

    uint128 public maxLockedProfit;


    Strategy[] public withdrawalStack;

    function getWithdrawalStack() external view returns (Strategy[] memory) {

        return withdrawalStack;
    }


    event Deposit(address indexed user, uint256 underlyingAmount);

    event Withdraw(address indexed user, uint256 underlyingAmount);

    function deposit(uint256 underlyingAmount) external {

        _mint(msg.sender, underlyingAmount.fdiv(exchangeRate(), BASE_UNIT));

        emit Deposit(msg.sender, underlyingAmount);

        UNDERLYING.safeTransferFrom(msg.sender, address(this), underlyingAmount);
    }

    function withdraw(uint256 underlyingAmount) external {

        _burn(msg.sender, underlyingAmount.fdiv(exchangeRate(), BASE_UNIT));

        emit Withdraw(msg.sender, underlyingAmount);

        transferUnderlyingTo(msg.sender, underlyingAmount);
    }

    function redeem(uint256 avTokenAmount) external {

        uint256 underlyingAmount = avTokenAmount.fmul(exchangeRate(), BASE_UNIT);

        _burn(msg.sender, avTokenAmount);

        emit Withdraw(msg.sender, underlyingAmount);

        transferUnderlyingTo(msg.sender, underlyingAmount);
    }

    function transferUnderlyingTo(address recipient, uint256 underlyingAmount) internal {

        uint256 float = totalFloat();

        if (underlyingAmount > float) {
            uint256 floatMissingForTarget = (totalHoldings() - underlyingAmount).fmul(targetFloatPercent, 1e18);

            uint256 floatMissingForWithdrawal = underlyingAmount - float;

            pullFromWithdrawalStack(floatMissingForWithdrawal + floatMissingForTarget);
        }

        UNDERLYING.safeTransfer(recipient, underlyingAmount);
    }


    function balanceOfUnderlying(address user) external view returns (uint256) {

        return balanceOf[user].fmul(exchangeRate(), BASE_UNIT);
    }

    function exchangeRate() public view returns (uint256) {

        uint256 avTokenSupply = totalSupply;

        if (avTokenSupply == 0) return BASE_UNIT;

        return totalHoldings().fdiv(avTokenSupply, BASE_UNIT);
    }

    function totalHoldings() public view returns (uint256 totalUnderlyingHeld) {

        unchecked {
            totalUnderlyingHeld = totalStrategyHoldings - lockedProfit();
        }

        totalUnderlyingHeld += totalFloat();
    }

    function lockedProfit() public view returns (uint256) {

        uint256 previousHarvest = lastHarvest;
        uint256 harvestInterval = harvestDelay;

        unchecked {
            if (block.timestamp >= previousHarvest + harvestInterval) return 0;

            uint256 maximumLockedProfit = maxLockedProfit;

            return maximumLockedProfit - (maximumLockedProfit * (block.timestamp - previousHarvest)) / harvestInterval;
        }
    }

    function totalFloat() public view returns (uint256) {

        return UNDERLYING.balanceOf(address(this));
    }


    event Harvest(address indexed user, Strategy[] strategies);

    function harvest(Strategy[] calldata strategies) external requiresAuth {

        if (block.timestamp >= lastHarvest + harvestDelay) {
            lastHarvestWindowStart = uint64(block.timestamp);
        } else {
            require(block.timestamp <= lastHarvestWindowStart + harvestWindow, "BAD_HARVEST_TIME");
        }

        uint256 oldTotalStrategyHoldings = totalStrategyHoldings;

        uint256 totalProfitAccrued;

        uint256 newTotalStrategyHoldings = oldTotalStrategyHoldings;

        for (uint256 i = 0; i < strategies.length; i++) {
            Strategy strategy = strategies[i];

            require(getStrategyData[strategy].trusted, "UNTRUSTED_STRATEGY");

            uint256 balanceLastHarvest = getStrategyData[strategy].balance;
            uint256 balanceThisHarvest = strategy.balanceOfUnderlying(address(this));

            getStrategyData[strategy].balance = balanceThisHarvest.safeCastTo248();

            newTotalStrategyHoldings = newTotalStrategyHoldings + balanceThisHarvest - balanceLastHarvest;

            unchecked {
                totalProfitAccrued += balanceThisHarvest > balanceLastHarvest
                    ? balanceThisHarvest - balanceLastHarvest // Profits since last harvest.
                    : 0; // If the strategy registered a net loss we don't have any new profit.
            }
        }

        uint256 feesAccrued = totalProfitAccrued.fmul(feePercent, 1e18);

        _mint(address(this), feesAccrued.fdiv(exchangeRate(), BASE_UNIT));

        maxLockedProfit = (lockedProfit() + totalProfitAccrued - feesAccrued).safeCastTo128();

        totalStrategyHoldings = newTotalStrategyHoldings;

        lastHarvest = uint64(block.timestamp);

        emit Harvest(msg.sender, strategies);

        uint64 newHarvestDelay = nextHarvestDelay;

        if (newHarvestDelay != 0) {
            harvestDelay = newHarvestDelay;

            nextHarvestDelay = 0;

            emit HarvestDelayUpdated(msg.sender, newHarvestDelay);
        }
    }


    event StrategyDeposit(address indexed user, Strategy indexed strategy, uint256 underlyingAmount);

    event StrategyWithdrawal(address indexed user, Strategy indexed strategy, uint256 underlyingAmount);

    function depositIntoStrategy(Strategy strategy, uint256 underlyingAmount) external requiresAuth {

        require(getStrategyData[strategy].trusted, "UNTRUSTED_STRATEGY");

        totalStrategyHoldings += underlyingAmount;

        unchecked {
            getStrategyData[strategy].balance += underlyingAmount.safeCastTo248();
        }

        emit StrategyDeposit(msg.sender, strategy, underlyingAmount);

        if (strategy.isCEther()) {
            WETH(payable(address(UNDERLYING))).withdraw(underlyingAmount);

            ETHStrategy(address(strategy)).mint{value: underlyingAmount}();
        } else {
            UNDERLYING.safeApprove(address(strategy), underlyingAmount);

            require(ERC20Strategy(address(strategy)).mint(underlyingAmount) == 0, "MINT_FAILED");
        }
    }

    function withdrawFromStrategy(Strategy strategy, uint256 underlyingAmount) external requiresAuth {

        require(getStrategyData[strategy].trusted, "UNTRUSTED_STRATEGY");

        getStrategyData[strategy].balance -= underlyingAmount.safeCastTo248();

        unchecked {
            totalStrategyHoldings -= underlyingAmount;
        }

        emit StrategyWithdrawal(msg.sender, strategy, underlyingAmount);

        require(strategy.redeemUnderlying(underlyingAmount) == 0, "REDEEM_FAILED");

        if (strategy.isCEther()) WETH(payable(address(UNDERLYING))).deposit{value: underlyingAmount}();
    }


    event StrategyTrusted(address indexed user, Strategy indexed strategy);

    event StrategyDistrusted(address indexed user, Strategy indexed strategy);

    function trustStrategy(Strategy strategy) external requiresAuth {

        require(
            strategy.isCEther() ? underlyingIsWETH : ERC20Strategy(address(strategy)).underlying() == UNDERLYING,
            "WRONG_UNDERLYING"
        );

        getStrategyData[strategy].trusted = true;

        emit StrategyTrusted(msg.sender, strategy);
    }

    function distrustStrategy(Strategy strategy) external requiresAuth {

        getStrategyData[strategy].trusted = false;

        emit StrategyDistrusted(msg.sender, strategy);
    }


    event WithdrawalStackPushed(address indexed user, Strategy indexed pushedStrategy);

    event WithdrawalStackPopped(address indexed user, Strategy indexed poppedStrategy);

    event WithdrawalStackSet(address indexed user, Strategy[] replacedWithdrawalStack);

    event WithdrawalStackIndexReplaced(
        address indexed user,
        uint256 index,
        Strategy indexed replacedStrategy,
        Strategy indexed replacementStrategy
    );

    event WithdrawalStackIndexReplacedWithTip(
        address indexed user,
        uint256 index,
        Strategy indexed replacedStrategy,
        Strategy indexed previousTipStrategy
    );

    event WithdrawalStackIndexesSwapped(
        address indexed user,
        uint256 index1,
        uint256 index2,
        Strategy indexed newStrategy1,
        Strategy indexed newStrategy2
    );

    function pullFromWithdrawalStack(uint256 underlyingAmount) internal {

        uint256 amountLeftToPull = underlyingAmount;

        uint256 currentIndex = withdrawalStack.length - 1;

        for (; ; currentIndex--) {
            Strategy strategy = withdrawalStack[currentIndex];

            uint256 strategyBalance = getStrategyData[strategy].balance;

            if (!getStrategyData[strategy].trusted || strategyBalance == 0) {
                withdrawalStack.pop();

                emit WithdrawalStackPopped(msg.sender, strategy);

                continue;
            }

            uint256 amountToPull = strategyBalance > amountLeftToPull ? amountLeftToPull : strategyBalance;

            unchecked {
                uint256 strategyBalanceAfterWithdrawal = strategyBalance - amountToPull;

                getStrategyData[strategy].balance = strategyBalanceAfterWithdrawal.safeCastTo248();

                amountLeftToPull -= amountToPull;

                emit StrategyWithdrawal(msg.sender, strategy, amountToPull);

                require(strategy.redeemUnderlying(amountToPull) == 0, "REDEEM_FAILED");

                if (strategyBalanceAfterWithdrawal == 0) {
                    withdrawalStack.pop();

                    emit WithdrawalStackPopped(msg.sender, strategy);
                }
            }

            if (amountLeftToPull == 0) break;
        }

        unchecked {
            totalStrategyHoldings -= underlyingAmount;
        }

        uint256 ethBalance = address(this).balance;

        if (ethBalance != 0 && underlyingIsWETH) WETH(payable(address(UNDERLYING))).deposit{value: ethBalance}();
    }

    function pushToWithdrawalStack(Strategy strategy) external requiresAuth {

        require(withdrawalStack.length < MAX_WITHDRAWAL_STACK_SIZE, "STACK_FULL");

        withdrawalStack.push(strategy);

        emit WithdrawalStackPushed(msg.sender, strategy);
    }

    function popFromWithdrawalStack() external requiresAuth {

        Strategy poppedStrategy = withdrawalStack[withdrawalStack.length - 1];

        withdrawalStack.pop();

        emit WithdrawalStackPopped(msg.sender, poppedStrategy);
    }

    function setWithdrawalStack(Strategy[] calldata newStack) external requiresAuth {

        require(newStack.length <= MAX_WITHDRAWAL_STACK_SIZE, "STACK_TOO_BIG");

        withdrawalStack = newStack;

        emit WithdrawalStackSet(msg.sender, newStack);
    }

    function replaceWithdrawalStackIndex(uint256 index, Strategy replacementStrategy) external requiresAuth {

        Strategy replacedStrategy = withdrawalStack[index];

        withdrawalStack[index] = replacementStrategy;

        emit WithdrawalStackIndexReplaced(msg.sender, index, replacedStrategy, replacementStrategy);
    }

    function replaceWithdrawalStackIndexWithTip(uint256 index) external requiresAuth {

        Strategy previousTipStrategy = withdrawalStack[withdrawalStack.length - 1];
        Strategy replacedStrategy = withdrawalStack[index];

        withdrawalStack[index] = previousTipStrategy;

        withdrawalStack.pop();

        emit WithdrawalStackIndexReplacedWithTip(msg.sender, index, replacedStrategy, previousTipStrategy);
    }

    function swapWithdrawalStackIndexes(uint256 index1, uint256 index2) external requiresAuth {

        Strategy newStrategy2 = withdrawalStack[index1];
        Strategy newStrategy1 = withdrawalStack[index2];

        withdrawalStack[index1] = newStrategy1;
        withdrawalStack[index2] = newStrategy2;

        emit WithdrawalStackIndexesSwapped(msg.sender, index1, index2, newStrategy1, newStrategy2);
    }


    event StrategySeized(address indexed user, Strategy indexed strategy);

    function seizeStrategy(Strategy strategy) external requiresAuth {

        uint256 strategyBalance = getStrategyData[strategy].balance;

        if (strategyBalance > totalHoldings()) maxLockedProfit = 0;

        getStrategyData[strategy].balance = 0;

        unchecked {
            totalStrategyHoldings -= strategyBalance;
        }

        emit StrategySeized(msg.sender, strategy);

        ERC20(strategy).safeTransfer(msg.sender, strategy.balanceOf(address(this)));
    }


    event FeesClaimed(address indexed user, uint256 avTokenAmount);

    function claimFees(uint256 avTokenAmount) external requiresAuth {

        emit FeesClaimed(msg.sender, avTokenAmount);

        ERC20(this).safeTransfer(msg.sender, avTokenAmount);
    }


    event Initialized(address indexed user);

    bool public isInitialized;

    function initialize() external requiresAuth {

        require(!isInitialized, "ALREADY_INITIALIZED");

        isInitialized = true;

        totalSupply = 0;

        emit Initialized(msg.sender);
    }

    function destroy() external requiresAuth {

        selfdestruct(payable(msg.sender));
    }


    receive() external payable {}
}



pragma solidity ^0.8.11;



contract VaultFactory is Auth {

    using Bytes32AddressLib for address;
    using Bytes32AddressLib for bytes32;


    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}


    event VaultDeployed(Vault vault, ERC20 underlying);

    function deployVault(ERC20 underlying) external returns (Vault vault) {

        vault = new Vault{salt: address(underlying).fillLast12Bytes()}(underlying);

        emit VaultDeployed(vault, underlying);
    }


    function getVaultFromUnderlying(ERC20 underlying) external view returns (Vault) {

        return
            Vault(
                payable(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xFF),
                            address(this),
                            address(underlying).fillLast12Bytes(),
                            keccak256(
                                abi.encodePacked(
                                    type(Vault).creationCode,
                                    abi.encode(underlying)
                                )
                            )
                        )
                    ).fromLast20Bytes() // Convert the CREATE2 hash into an address.
                )
            );
    }

    function isVaultDeployed(Vault vault) external view returns (bool) {

        return address(vault).code.length > 0;
    }
}