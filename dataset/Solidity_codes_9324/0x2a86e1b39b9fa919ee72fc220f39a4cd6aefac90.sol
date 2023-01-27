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
}// AGPL-3.0-only
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
            if iszero(callStatus) {
                returndatacopy(0, 0, returndatasize())

                revert(0, returndatasize())
            }

            switch returndatasize()
            case 32 {
                returndatacopy(0, 0, returndatasize())

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
}// GPL-3.0-or-later

pragma solidity 0.8.7;

interface IStrategy {

    function skim(uint256 amount) external;


    function harvest(uint256 balance, address sender) external returns (int256 amountAdded);


    function withdraw(uint256 amount) external returns (uint256 actualAmount);


    function exit(uint256 balance) external returns (int256 amountAdded);

}// UNLICENSED

pragma solidity 0.8.7;

interface IBentoBoxMinimal {


    struct Rebase {
        uint128 elastic;
        uint128 base;
    }

    struct StrategyData {
        uint64 strategyStartDate;
        uint64 targetPercentage;
        uint128 balance; // the balance of the strategy that BentoBox thinks is in there
    }

    function strategyData(address token) external view returns (StrategyData memory);


    function balanceOf(address, address) external view returns (uint256);


    function deposit(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);


    function withdraw(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);


    function transfer(
        address token,
        address from,
        address to,
        uint256 share
    ) external;


    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);


    function toAmount(
        address token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);


    function registerProtocol() external;


    function totals(address token) external view returns (Rebase memory);


    function harvest(
        address token,
        bool balance,
        uint256 maxChangeAmount
    ) external;

}// GPL-3.0-or-later

pragma solidity 0.8.7;


interface IExchangeRateFeeder {

    function exchangeRateOf(address _token, bool _simulate) external view returns (uint256);

}

interface IUSTStrategy {

    function feeder() external view returns (IExchangeRateFeeder);


    function safeWithdraw(uint256 amount) external;


    function safeHarvest(
        uint256 maxBalance,
        bool rebalance,
        uint256 maxChangeAmount,
        bool harvestRewards
    ) external;

}

contract USTMiddleLayer {

    using SafeTransferLib for ERC20;

    error RedeemingNotReady();
    error StrategyWouldAccountLoss();

    ERC20 public constant UST = ERC20(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD);
    ERC20 public constant aUST = ERC20(0xa8De3e3c934e2A1BB08B010104CcaBBD4D6293ab);
    IUSTStrategy private constant strategy = IUSTStrategy(0xE6191aA754F9a881e0a73F2028eDF324242F39E2);
    IBentoBoxMinimal private constant bentoBox = IBentoBoxMinimal(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);

    uint256 public lastWithdraw;

    function accountEarnings() external {

        uint256 balanceToKeep = IBentoBoxMinimal(bentoBox).strategyData(address(UST)).balance;
        uint256 exchangeRate = strategy.feeder().exchangeRateOf(address(UST), true);
        uint256 liquid = UST.balanceOf(address(strategy));
        uint256 total = toUST(aUST.balanceOf(address(strategy)), exchangeRate) + liquid;

        if (total <= balanceToKeep) {
            revert StrategyWouldAccountLoss();
        }

        strategy.safeHarvest(type(uint256).max, false, type(uint256).max, false);
    }

    function redeemEarningsImproved() external {

        if (lastWithdraw + 20 minutes > block.timestamp) {
            revert RedeemingNotReady();
        }

        uint256 balanceToKeep = IBentoBoxMinimal(bentoBox).strategyData(address(UST)).balance;
        uint256 exchangeRate = strategy.feeder().exchangeRateOf(address(UST), true);
        uint256 liquid = UST.balanceOf(address(strategy));
        uint256 total = toUST(aUST.balanceOf(address(strategy)), exchangeRate) + liquid;

        lastWithdraw = block.timestamp;

        if (total > balanceToKeep) {
            strategy.safeWithdraw(total - balanceToKeep - liquid);
        }
    }

    function toUST(uint256 amount, uint256 exchangeRate) public pure returns (uint256) {

        return (amount * exchangeRate) / 1e18;
    }

    function toAUST(uint256 amount, uint256 exchangeRate) public pure returns (uint256) {

        return (amount * 1e18) / exchangeRate;
    }
}