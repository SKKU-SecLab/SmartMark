





pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}


interface IFlashBorrower {

    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external;

}

interface IBatchFlashBorrower {

    function onBatchFlashLoan(
        address sender,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata data
    ) external;

}


interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;

}


interface IStrategy {

    function skim(uint256 amount) external;


    function harvest(uint256 balance, address sender) external returns (int256 amountAdded);


    function withdraw(uint256 amount) external returns (uint256 actualAmount);


    function exit(uint256 balance) external returns (int256 amountAdded);

}


library BoringERC20 {

    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}


library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}


struct Rebase {
    uint128 elastic;
    uint128 base;
}

library RebaseLibrary {

    using BoringMath for uint256;
    using BoringMath128 for uint128;

    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {

        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = elastic.mul(total.base) / total.elastic;
            if (roundUp && base.mul(total.elastic) / total.base < elastic) {
                base = base.add(1);
            }
        }
    }

    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {

        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = base.mul(total.elastic) / total.base;
            if (roundUp && elastic.mul(total.base) / total.elastic < base) {
                elastic = elastic.add(1);
            }
        }
    }

    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {

        base = toBase(total, elastic, roundUp);
        total.elastic = total.elastic.add(elastic.to128());
        total.base = total.base.add(base.to128());
        return (total, base);
    }

    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {

        elastic = toElastic(total, base, roundUp);
        total.elastic = total.elastic.sub(elastic.to128());
        total.base = total.base.sub(base.to128());
        return (total, elastic);
    }

    function add(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {

        total.elastic = total.elastic.add(elastic.to128());
        total.base = total.base.add(base.to128());
        return total;
    }

    function sub(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {

        total.elastic = total.elastic.sub(elastic.to128());
        total.base = total.base.sub(base.to128());
        return total;
    }

    function addElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {

        newElastic = total.elastic = total.elastic.add(elastic.to128());
    }

    function subElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {

        newElastic = total.elastic = total.elastic.sub(elastic.to128());
    }
}



contract BoringOwnableData {

    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
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


interface IMasterContract {

    function init(bytes calldata data) external payable;

}


contract BoringFactory {

    event LogDeploy(address indexed masterContract, bytes data, address indexed cloneAddress);

    mapping(address => address) public masterContractOf;

    function deploy(
        address masterContract,
        bytes calldata data,
        bool useCreate2
    ) public payable returns (address cloneAddress) {

        require(masterContract != address(0), "BoringFactory: No masterContract");
        bytes20 targetBytes = bytes20(masterContract); // Takes the first 20 bytes of the masterContract's address

        if (useCreate2) {
            bytes32 salt = keccak256(data);

            assembly {
                let clone := mload(0x40)
                mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
                mstore(add(clone, 0x14), targetBytes)
                mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
                cloneAddress := create2(0, clone, 0x37, salt)
            }
        } else {
            assembly {
                let clone := mload(0x40)
                mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
                mstore(add(clone, 0x14), targetBytes)
                mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
                cloneAddress := create(0, clone, 0x37)
            }
        }
        masterContractOf[cloneAddress] = masterContract;

        IMasterContract(cloneAddress).init{value: msg.value}(data);

        emit LogDeploy(masterContract, data, cloneAddress);
    }
}


contract MasterContractManager is BoringOwnable, BoringFactory {

    event LogWhiteListMasterContract(address indexed masterContract, bool approved);
    event LogSetMasterContractApproval(address indexed masterContract, address indexed user, bool approved);
    event LogRegisterProtocol(address indexed protocol);

    mapping(address => mapping(address => bool)) public masterContractApproved;
    mapping(address => bool) public whitelistedMasterContracts;
    mapping(address => uint256) public nonces;

    bytes32 private constant DOMAIN_SEPARATOR_SIGNATURE_HASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = "\x19\x01";
    bytes32 private constant APPROVAL_SIGNATURE_HASH =
        keccak256("SetMasterContractApproval(string warning,address user,address masterContract,bool approved,uint256 nonce)");

    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable DOMAIN_SEPARATOR_CHAIN_ID;

    constructor() public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID = chainId);
    }

    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {

        return keccak256(abi.encode(DOMAIN_SEPARATOR_SIGNATURE_HASH, keccak256("BentoBox V1"), chainId, address(this)));
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId == DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }

    function registerProtocol() public {

        masterContractOf[msg.sender] = msg.sender;
        emit LogRegisterProtocol(msg.sender);
    }

    function whitelistMasterContract(address masterContract, bool approved) public onlyOwner {

        require(masterContract != address(0), "MasterCMgr: Cannot approve 0");

        whitelistedMasterContracts[masterContract] = approved;
        emit LogWhiteListMasterContract(masterContract, approved);
    }

    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        require(masterContract != address(0), "MasterCMgr: masterC not set"); // Important for security

        if (r == 0 && s == 0 && v == 0) {
            require(user == msg.sender, "MasterCMgr: user not sender");
            require(masterContractOf[user] == address(0), "MasterCMgr: user is clone");
            require(whitelistedMasterContracts[masterContract], "MasterCMgr: not whitelisted");
        } else {
            require(user != address(0), "MasterCMgr: User cannot be 0");

            bytes32 digest =
                keccak256(
                    abi.encodePacked(
                        EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA,
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                APPROVAL_SIGNATURE_HASH,
                                approved
                                    ? keccak256("Give FULL access to funds in (and approved to) BentoBox?")
                                    : keccak256("Revoke access to BentoBox?"),
                                user,
                                masterContract,
                                approved,
                                nonces[user]++
                            )
                        )
                    )
                );
            address recoveredAddress = ecrecover(digest, v, r, s);
            require(recoveredAddress == user, "MasterCMgr: Invalid Signature");
        }

        masterContractApproved[masterContract][user] = approved;
        emit LogSetMasterContractApproval(masterContract, user, approved);
    }
}


contract BaseBoringBatchable {

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results) {

        successes = new bool[](calls.length);
        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            require(success || !revertOnFail, _getRevertMsg(result));
            successes[i] = success;
            results[i] = result;
        }
    }
}

contract BoringBatchable is BaseBoringBatchable {

    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        token.permit(from, to, amount, deadline, v, r, s);
    }
}


contract DegenBox is MasterContractManager, BoringBatchable {

    using BoringMath for uint256;
    using BoringMath128 for uint128;
    using BoringERC20 for IERC20;
    using RebaseLibrary for Rebase;


    event LogDeposit(IERC20 indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
    event LogWithdraw(IERC20 indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
    event LogTransfer(IERC20 indexed token, address indexed from, address indexed to, uint256 share);

    event LogFlashLoan(address indexed borrower, IERC20 indexed token, uint256 amount, uint256 feeAmount, address indexed receiver);

    event LogStrategyTargetPercentage(IERC20 indexed token, uint256 targetPercentage);
    event LogStrategyQueued(IERC20 indexed token, IStrategy indexed strategy);
    event LogStrategySet(IERC20 indexed token, IStrategy indexed strategy);
    event LogStrategyInvest(IERC20 indexed token, uint256 amount);
    event LogStrategyDivest(IERC20 indexed token, uint256 amount);
    event LogStrategyProfit(IERC20 indexed token, uint256 amount);
    event LogStrategyLoss(IERC20 indexed token, uint256 amount);


    struct StrategyData {
        uint64 strategyStartDate;
        uint64 targetPercentage;
        uint128 balance; // the balance of the strategy that BentoBox thinks is in there
    }


    IERC20 private immutable wethToken;

    IERC20 private constant USE_ETHEREUM = IERC20(0);
    uint256 private constant FLASH_LOAN_FEE = 50; // 0.05%
    uint256 private constant FLASH_LOAN_FEE_PRECISION = 1e5;
    uint256 private constant STRATEGY_DELAY = 3 days;
    uint256 private constant MAX_TARGET_PERCENTAGE = 95; // 95%
    uint256 private constant MINIMUM_SHARE_BALANCE = 1000; // To prevent the ratio going off


    mapping(IERC20 => mapping(address => uint256)) public balanceOf;

    mapping(IERC20 => Rebase) public totals;

    mapping(IERC20 => IStrategy) public strategy;
    mapping(IERC20 => IStrategy) public pendingStrategy;
    mapping(IERC20 => StrategyData) public strategyData;


    constructor(IERC20 wethToken_) public {
        wethToken = wethToken_;
    }


    modifier allowed(address from) {

        if (from != msg.sender && from != address(this)) {
            address masterContract = masterContractOf[msg.sender];
            require(masterContract != address(0), "BentoBox: no masterContract");
            require(masterContractApproved[masterContract][from], "BentoBox: Transfer not approved");
        }
        _;
    }


    function _tokenBalanceOf(IERC20 token) internal view returns (uint256 amount) {

        amount = token.balanceOf(address(this)).add(strategyData[token].balance);
    }


    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share) {

        share = totals[token].toBase(amount, roundUp);
    }

    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount) {

        amount = totals[token].toElastic(share, roundUp);
    }

    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) public payable allowed(from) returns (uint256 amountOut, uint256 shareOut) {

        require(to != address(0), "BentoBox: to not set"); // To avoid a bad UI from burning funds

        IERC20 token = token_ == USE_ETHEREUM ? wethToken : token_;
        Rebase memory total = totals[token];

        require(total.elastic != 0 || token.totalSupply() > 0, "BentoBox: No tokens");
        if (share == 0) {
            share = total.toBase(amount, false);
            if (total.base.add(share.to128()) < MINIMUM_SHARE_BALANCE) {
                return (0, 0);
            }
        } else {
            amount = total.toElastic(share, true);
        }

        require(
            from != address(this) || token_ == USE_ETHEREUM || amount <= _tokenBalanceOf(token).sub(total.elastic),
            "BentoBox: Skim too much"
        );

        balanceOf[token][to] = balanceOf[token][to].add(share);
        total.base = total.base.add(share.to128());
        total.elastic = total.elastic.add(amount.to128());
        totals[token] = total;

        if (token_ == USE_ETHEREUM) {
            IWETH(address(wethToken)).deposit{value: amount}();
        } else if (from != address(this)) {
            token.safeTransferFrom(from, address(this), amount);
        }
        emit LogDeposit(token, from, to, amount, share);
        amountOut = amount;
        shareOut = share;
    }

    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) public allowed(from) returns (uint256 amountOut, uint256 shareOut) {

        require(to != address(0), "BentoBox: to not set"); // To avoid a bad UI from burning funds

        IERC20 token = token_ == USE_ETHEREUM ? wethToken : token_;
        Rebase memory total = totals[token];
        if (share == 0) {
            share = total.toBase(amount, true);
        } else {
            amount = total.toElastic(share, false);
        }

        balanceOf[token][from] = balanceOf[token][from].sub(share);
        total.elastic = total.elastic.sub(amount.to128());
        total.base = total.base.sub(share.to128());
        require(total.base >= MINIMUM_SHARE_BALANCE || total.base == 0, "BentoBox: cannot empty");
        totals[token] = total;

        if (token_ == USE_ETHEREUM) {
            IWETH(address(wethToken)).withdraw(amount);
            (bool success, ) = to.call{value: amount}("");
            require(success, "BentoBox: ETH transfer failed");
        } else {
            token.safeTransfer(to, amount);
        }
        emit LogWithdraw(token, from, to, amount, share);
        amountOut = amount;
        shareOut = share;
    }

    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) public allowed(from) {

        require(to != address(0), "BentoBox: to not set"); // To avoid a bad UI from burning funds

        balanceOf[token][from] = balanceOf[token][from].sub(share);
        balanceOf[token][to] = balanceOf[token][to].add(share);

        emit LogTransfer(token, from, to, share);
    }

    function transferMultiple(
        IERC20 token,
        address from,
        address[] calldata tos,
        uint256[] calldata shares
    ) public allowed(from) {

        require(tos[0] != address(0), "BentoBox: to[0] not set"); // To avoid a bad UI from burning funds

        uint256 totalAmount;
        uint256 len = tos.length;
        for (uint256 i = 0; i < len; i++) {
            address to = tos[i];
            balanceOf[token][to] = balanceOf[token][to].add(shares[i]);
            totalAmount = totalAmount.add(shares[i]);
            emit LogTransfer(token, from, to, shares[i]);
        }
        balanceOf[token][from] = balanceOf[token][from].sub(totalAmount);
    }

    function flashLoan(
        IFlashBorrower borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) public {

        uint256 fee = amount.mul(FLASH_LOAN_FEE) / FLASH_LOAN_FEE_PRECISION;
        token.safeTransfer(receiver, amount);

        borrower.onFlashLoan(msg.sender, token, amount, fee, data);

        require(_tokenBalanceOf(token) >= totals[token].addElastic(fee.to128()), "BentoBox: Wrong amount");
        emit LogFlashLoan(address(borrower), token, amount, fee, receiver);
    }

    function batchFlashLoan(
        IBatchFlashBorrower borrower,
        address[] calldata receivers,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata data
    ) public {

        uint256[] memory fees = new uint256[](tokens.length);

        uint256 len = tokens.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 amount = amounts[i];
            fees[i] = amount.mul(FLASH_LOAN_FEE) / FLASH_LOAN_FEE_PRECISION;

            tokens[i].safeTransfer(receivers[i], amounts[i]);
        }

        borrower.onBatchFlashLoan(msg.sender, tokens, amounts, fees, data);

        for (uint256 i = 0; i < len; i++) {
            IERC20 token = tokens[i];
            require(_tokenBalanceOf(token) >= totals[token].addElastic(fees[i].to128()), "BentoBox: Wrong amount");
            emit LogFlashLoan(address(borrower), token, amounts[i], fees[i], receivers[i]);
        }
    }

    function setStrategyTargetPercentage(IERC20 token, uint64 targetPercentage_) public onlyOwner {

        require(targetPercentage_ <= MAX_TARGET_PERCENTAGE, "StrategyManager: Target too high");

        strategyData[token].targetPercentage = targetPercentage_;
        emit LogStrategyTargetPercentage(token, targetPercentage_);
    }

    function setStrategy(IERC20 token, IStrategy newStrategy) public onlyOwner {

        StrategyData memory data = strategyData[token];
        IStrategy pending = pendingStrategy[token];
        if (data.strategyStartDate == 0 || pending != newStrategy) {
            pendingStrategy[token] = newStrategy;
            data.strategyStartDate = (block.timestamp + STRATEGY_DELAY).to64();
            emit LogStrategyQueued(token, newStrategy);
        } else {
            require(data.strategyStartDate != 0 && block.timestamp >= data.strategyStartDate, "StrategyManager: Too early");
            if (address(strategy[token]) != address(0)) {
                int256 balanceChange = strategy[token].exit(data.balance);
                if (balanceChange > 0) {
                    uint256 add = uint256(balanceChange);
                    totals[token].addElastic(add);
                    emit LogStrategyProfit(token, add);
                } else if (balanceChange < 0) {
                    uint256 sub = uint256(-balanceChange);
                    totals[token].subElastic(sub);
                    emit LogStrategyLoss(token, sub);
                }

                emit LogStrategyDivest(token, data.balance);
            }
            strategy[token] = pending;
            data.strategyStartDate = 0;
            data.balance = 0;
            pendingStrategy[token] = IStrategy(0);
            emit LogStrategySet(token, newStrategy);
        }
        strategyData[token] = data;
    }

    function harvest(
        IERC20 token,
        bool balance,
        uint256 maxChangeAmount
    ) public {

        StrategyData memory data = strategyData[token];
        IStrategy _strategy = strategy[token];
        int256 balanceChange = _strategy.harvest(data.balance, msg.sender);
        if (balanceChange == 0 && !balance) {
            return;
        }

        uint256 totalElastic = totals[token].elastic;

        if (balanceChange > 0) {
            uint256 add = uint256(balanceChange);
            totalElastic = totalElastic.add(add);
            totals[token].elastic = totalElastic.to128();
            emit LogStrategyProfit(token, add);
        } else if (balanceChange < 0) {
            uint256 sub = uint256(-balanceChange);
            totalElastic = totalElastic.sub(sub);
            totals[token].elastic = totalElastic.to128();
            data.balance = data.balance.sub(sub.to128());
            emit LogStrategyLoss(token, sub);
        }

        if (balance) {
            uint256 targetBalance = totalElastic.mul(data.targetPercentage) / 100;
            if (data.balance < targetBalance) {
                uint256 amountOut = targetBalance.sub(data.balance);
                if (maxChangeAmount != 0 && amountOut > maxChangeAmount) {
                    amountOut = maxChangeAmount;
                }
                token.safeTransfer(address(_strategy), amountOut);
                data.balance = data.balance.add(amountOut.to128());
                _strategy.skim(amountOut);
                emit LogStrategyInvest(token, amountOut);
            } else if (data.balance > targetBalance) {
                uint256 amountIn = data.balance.sub(targetBalance.to128());
                if (maxChangeAmount != 0 && amountIn > maxChangeAmount) {
                    amountIn = maxChangeAmount;
                }

                uint256 actualAmountIn = _strategy.withdraw(amountIn);

                data.balance = data.balance.sub(actualAmountIn.to128());
                emit LogStrategyDivest(token, actualAmountIn);
            }
        }

        strategyData[token] = data;
    }

    receive() external payable {}
}