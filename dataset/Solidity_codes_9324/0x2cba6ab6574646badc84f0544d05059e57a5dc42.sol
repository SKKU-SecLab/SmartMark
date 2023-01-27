




pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



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


contract Domain {

    bytes32 private constant DOMAIN_SEPARATOR_SIGNATURE_HASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = "\x19\x01";

    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable DOMAIN_SEPARATOR_CHAIN_ID;

    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {

        return keccak256(abi.encode(DOMAIN_SEPARATOR_SIGNATURE_HASH, chainId, address(this)));
    }

    constructor() public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID = chainId);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId == DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }

    function _getDigest(bytes32 dataHash) internal view returns (bytes32 digest) {

        digest = keccak256(abi.encodePacked(EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA, DOMAIN_SEPARATOR(), dataHash));
    }
}



contract ERC20Data {

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;
}

contract ERC20 is ERC20Data, Domain {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address to, uint256 amount) public returns (bool) {

        if (amount != 0) {
            uint256 srcBalance = balanceOf[msg.sender];
            require(srcBalance >= amount, "ERC20: balance too low");
            if (msg.sender != to) {
                require(to != address(0), "ERC20: no zero address"); // Moved down so low balance calls safe some gas

                balanceOf[msg.sender] = srcBalance - amount; // Underflow is checked
                balanceOf[to] += amount; // Can't overflow because totalSupply would be greater than 2^256-1
            }
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {

        if (amount != 0) {
            uint256 srcBalance = balanceOf[from];
            require(srcBalance >= amount, "ERC20: balance too low");

            if (from != to) {
                uint256 spenderAllowance = allowance[from][msg.sender];
                if (spenderAllowance != type(uint256).max) {
                    require(spenderAllowance >= amount, "ERC20: allowance too low");
                    allowance[from][msg.sender] = spenderAllowance - amount; // Underflow is checked
                }
                require(to != address(0), "ERC20: no zero address"); // Moved down so other failed calls safe some gas

                balanceOf[from] = srcBalance - amount; // Underflow is checked
                balanceOf[to] += amount; // Can't overflow because totalSupply would be greater than 2^256-1
            }
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    bytes32 private constant PERMIT_SIGNATURE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    function permit(
        address owner_,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        require(owner_ != address(0), "ERC20: Owner cannot be 0");
        require(block.timestamp < deadline, "ERC20: Expired");
        require(
            ecrecover(_getDigest(keccak256(abi.encode(PERMIT_SIGNATURE_HASH, owner_, spender, value, nonces[owner_]++, deadline))), v, r, s) ==
                owner_,
            "ERC20: Invalid Signature"
        );
        allowance[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }
}


interface IMasterContract {

    function init(bytes calldata data) external payable;

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
}


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


library BoringERC20 {

    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function returnDataToString(bytes memory data) internal pure returns (string memory) {

        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while (i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    function safeSymbol(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success ? returnDataToString(data) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success ? returnDataToString(data) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }
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


interface IFlashBorrower {

    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external;

}


interface IStrategy {

    function skim(uint256 amount) external;


    function harvest(uint256 balance, address sender) external returns (int256 amountAdded);


    function withdraw(uint256 amount) external returns (uint256 actualAmount);


    function exit(uint256 balance) external returns (int256 amountAdded);

}


interface IBentoBoxV1 {

    event LogDeploy(address indexed masterContract, bytes data, address indexed cloneAddress);
    event LogDeposit(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
    event LogFlashLoan(address indexed borrower, address indexed token, uint256 amount, uint256 feeAmount, address indexed receiver);
    event LogRegisterProtocol(address indexed protocol);
    event LogSetMasterContractApproval(address indexed masterContract, address indexed user, bool approved);
    event LogStrategyDivest(address indexed token, uint256 amount);
    event LogStrategyInvest(address indexed token, uint256 amount);
    event LogStrategyLoss(address indexed token, uint256 amount);
    event LogStrategyProfit(address indexed token, uint256 amount);
    event LogStrategyQueued(address indexed token, address indexed strategy);
    event LogStrategySet(address indexed token, address indexed strategy);
    event LogStrategyTargetPercentage(address indexed token, uint256 targetPercentage);
    event LogTransfer(address indexed token, address indexed from, address indexed to, uint256 share);
    event LogWhiteListMasterContract(address indexed masterContract, bool approved);
    event LogWithdraw(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function balanceOf(IERC20, address) external view returns (uint256);


    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results);


    function batchFlashLoan(
        IBatchFlashBorrower borrower,
        address[] calldata receivers,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;


    function claimOwnership() external;


    function deploy(
        address masterContract,
        bytes calldata data,
        bool useCreate2
    ) external payable;


    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);


    function flashLoan(
        IFlashBorrower borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;


    function harvest(
        IERC20 token,
        bool balance,
        uint256 maxChangeAmount
    ) external;


    function masterContractApproved(address, address) external view returns (bool);


    function masterContractOf(address) external view returns (address);


    function nonces(address) external view returns (uint256);


    function owner() external view returns (address);


    function pendingOwner() external view returns (address);


    function pendingStrategy(IERC20) external view returns (IStrategy);


    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function registerProtocol() external;


    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function setStrategy(IERC20 token, IStrategy newStrategy) external;


    function setStrategyTargetPercentage(IERC20 token, uint64 targetPercentage_) external;


    function strategy(IERC20) external view returns (IStrategy);


    function strategyData(IERC20)
        external
        view
        returns (
            uint64 strategyStartDate,
            uint64 targetPercentage,
            uint128 balance
        );


    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);


    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);


    function totals(IERC20) external view returns (Rebase memory totals_);


    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) external;


    function transferMultiple(
        IERC20 token,
        address from,
        address[] calldata tos,
        uint256[] calldata shares
    ) external;


    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) external;


    function whitelistMasterContract(address masterContract, bool approved) external;


    function whitelistedMasterContracts(address) external view returns (bool);


    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

}


interface IOracle {

    function get(bytes calldata data) external returns (bool success, uint256 rate);


    function peek(bytes calldata data) external view returns (bool success, uint256 rate);


    function peekSpot(bytes calldata data) external view returns (uint256 rate);


    function symbol(bytes calldata data) external view returns (string memory);


    function name(bytes calldata data) external view returns (string memory);

}


interface ISwapper {

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        address recipient,
        uint256 shareToMin,
        uint256 shareFrom
    ) external returns (uint256 extraShare, uint256 shareReturned);


    function swapExact(
        IERC20 fromToken,
        IERC20 toToken,
        address recipient,
        address refundTo,
        uint256 shareFromSupplied,
        uint256 shareToExact
    ) external returns (uint256 shareUsed, uint256 shareReturned);

}


contract KashiPairMediumRiskV1 is ERC20, BoringOwnable, IMasterContract {

    using BoringMath for uint256;
    using BoringMath128 for uint128;
    using RebaseLibrary for Rebase;
    using BoringERC20 for IERC20;

    event LogExchangeRate(uint256 rate);
    event LogAccrue(uint256 accruedAmount, uint256 feeFraction, uint64 rate, uint256 utilization);
    event LogAddCollateral(address indexed from, address indexed to, uint256 share);
    event LogAddAsset(address indexed from, address indexed to, uint256 share, uint256 fraction);
    event LogRemoveCollateral(address indexed from, address indexed to, uint256 share);
    event LogRemoveAsset(address indexed from, address indexed to, uint256 share, uint256 fraction);
    event LogBorrow(address indexed from, address indexed to, uint256 amount, uint256 feeAmount, uint256 part);
    event LogRepay(address indexed from, address indexed to, uint256 amount, uint256 part);
    event LogFeeTo(address indexed newFeeTo);
    event LogWithdrawFees(address indexed feeTo, uint256 feesEarnedFraction);

    IBentoBoxV1 public immutable bentoBox;
    KashiPairMediumRiskV1 public immutable masterContract;

    address public feeTo;
    mapping(ISwapper => bool) public swappers;

    IERC20 public collateral;
    IERC20 public asset;
    IOracle public oracle;
    bytes public oracleData;

    uint256 public totalCollateralShare; // Total collateral supplied
    Rebase public totalAsset; // elastic = BentoBox shares held by the KashiPair, base = Total fractions held by asset suppliers
    Rebase public totalBorrow; // elastic = Total token amount to be repayed by borrowers, base = Total parts of the debt held by borrowers

    mapping(address => uint256) public userCollateralShare;
    mapping(address => uint256) public userBorrowPart;

    uint256 public exchangeRate;

    struct AccrueInfo {
        uint64 interestPerSecond;
        uint64 lastAccrued;
        uint128 feesEarnedFraction;
    }

    AccrueInfo public accrueInfo;

    function symbol() external view returns (string memory) {

        return string(abi.encodePacked("km", collateral.safeSymbol(), "/", asset.safeSymbol(), "-", oracle.symbol(oracleData)));
    }

    function name() external view returns (string memory) {

        return string(abi.encodePacked("Kashi Medium Risk ", collateral.safeName(), "/", asset.safeName(), "-", oracle.name(oracleData)));
    }

    function decimals() external view returns (uint8) {

        return asset.safeDecimals();
    }

    function totalSupply() public view returns (uint256) {

        return totalAsset.base;
    }

    uint256 private constant CLOSED_COLLATERIZATION_RATE = 75000; // 75%
    uint256 private constant OPEN_COLLATERIZATION_RATE = 77000; // 77%
    uint256 private constant COLLATERIZATION_RATE_PRECISION = 1e5; // Must be less than EXCHANGE_RATE_PRECISION (due to optimization in math)
    uint256 private constant MINIMUM_TARGET_UTILIZATION = 7e17; // 70%
    uint256 private constant MAXIMUM_TARGET_UTILIZATION = 8e17; // 80%
    uint256 private constant UTILIZATION_PRECISION = 1e18;
    uint256 private constant FULL_UTILIZATION = 1e18;
    uint256 private constant FULL_UTILIZATION_MINUS_MAX = FULL_UTILIZATION - MAXIMUM_TARGET_UTILIZATION;
    uint256 private constant FACTOR_PRECISION = 1e18;

    uint64 private constant STARTING_INTEREST_PER_SECOND = 317097920; // approx 1% APR
    uint64 private constant MINIMUM_INTEREST_PER_SECOND = 79274480; // approx 0.25% APR
    uint64 private constant MAXIMUM_INTEREST_PER_SECOND = 317097920000; // approx 1000% APR
    uint256 private constant INTEREST_ELASTICITY = 28800e36; // Half or double in 28800 seconds (8 hours) if linear

    uint256 private constant EXCHANGE_RATE_PRECISION = 1e18;

    uint256 private constant LIQUIDATION_MULTIPLIER = 112000; // add 12%
    uint256 private constant LIQUIDATION_MULTIPLIER_PRECISION = 1e5;

    uint256 private constant PROTOCOL_FEE = 10000; // 10%
    uint256 private constant PROTOCOL_FEE_DIVISOR = 1e5;
    uint256 private constant BORROW_OPENING_FEE = 50; // 0.05%
    uint256 private constant BORROW_OPENING_FEE_PRECISION = 1e5;

    constructor(IBentoBoxV1 bentoBox_) public {
        bentoBox = bentoBox_;
        masterContract = this;
    }

    function init(bytes calldata data) public payable override {

        require(address(collateral) == address(0), "KashiPair: already initialized");
        (collateral, asset, oracle, oracleData) = abi.decode(data, (IERC20, IERC20, IOracle, bytes));
        require(address(collateral) != address(0), "KashiPair: bad pair");

        accrueInfo.interestPerSecond = uint64(STARTING_INTEREST_PER_SECOND); // 1% APR, with 1e18 being 100%
    }

    function accrue() public {

        AccrueInfo memory _accrueInfo = accrueInfo;
        uint256 elapsedTime = block.timestamp - _accrueInfo.lastAccrued;
        if (elapsedTime == 0) {
            return;
        }
        _accrueInfo.lastAccrued = uint64(block.timestamp);

        Rebase memory _totalBorrow = totalBorrow;
        if (_totalBorrow.base == 0) {
            if (_accrueInfo.interestPerSecond != STARTING_INTEREST_PER_SECOND) {
                _accrueInfo.interestPerSecond = STARTING_INTEREST_PER_SECOND;
                emit LogAccrue(0, 0, STARTING_INTEREST_PER_SECOND, 0);
            }
            accrueInfo = _accrueInfo;
            return;
        }

        uint256 extraAmount = 0;
        uint256 feeFraction = 0;
        Rebase memory _totalAsset = totalAsset;

        extraAmount = uint256(_totalBorrow.elastic).mul(_accrueInfo.interestPerSecond).mul(elapsedTime) / 1e18;
        _totalBorrow.elastic = _totalBorrow.elastic.add(extraAmount.to128());
        uint256 fullAssetAmount = bentoBox.toAmount(asset, _totalAsset.elastic, false).add(_totalBorrow.elastic);

        uint256 feeAmount = extraAmount.mul(PROTOCOL_FEE) / PROTOCOL_FEE_DIVISOR; // % of interest paid goes to fee
        feeFraction = feeAmount.mul(_totalAsset.base) / fullAssetAmount;
        _accrueInfo.feesEarnedFraction = _accrueInfo.feesEarnedFraction.add(feeFraction.to128());
        totalAsset.base = _totalAsset.base.add(feeFraction.to128());
        totalBorrow = _totalBorrow;

        uint256 utilization = uint256(_totalBorrow.elastic).mul(UTILIZATION_PRECISION) / fullAssetAmount;
        if (utilization < MINIMUM_TARGET_UTILIZATION) {
            uint256 underFactor = MINIMUM_TARGET_UTILIZATION.sub(utilization).mul(FACTOR_PRECISION) / MINIMUM_TARGET_UTILIZATION;
            uint256 scale = INTEREST_ELASTICITY.add(underFactor.mul(underFactor).mul(elapsedTime));
            _accrueInfo.interestPerSecond = uint64(uint256(_accrueInfo.interestPerSecond).mul(INTEREST_ELASTICITY) / scale);

            if (_accrueInfo.interestPerSecond < MINIMUM_INTEREST_PER_SECOND) {
                _accrueInfo.interestPerSecond = MINIMUM_INTEREST_PER_SECOND; // 0.25% APR minimum
            }
        } else if (utilization > MAXIMUM_TARGET_UTILIZATION) {
            uint256 overFactor = utilization.sub(MAXIMUM_TARGET_UTILIZATION).mul(FACTOR_PRECISION) / FULL_UTILIZATION_MINUS_MAX;
            uint256 scale = INTEREST_ELASTICITY.add(overFactor.mul(overFactor).mul(elapsedTime));
            uint256 newInterestPerSecond = uint256(_accrueInfo.interestPerSecond).mul(scale) / INTEREST_ELASTICITY;
            if (newInterestPerSecond > MAXIMUM_INTEREST_PER_SECOND) {
                newInterestPerSecond = MAXIMUM_INTEREST_PER_SECOND; // 1000% APR maximum
            }
            _accrueInfo.interestPerSecond = uint64(newInterestPerSecond);
        }

        emit LogAccrue(extraAmount, feeFraction, _accrueInfo.interestPerSecond, utilization);
        accrueInfo = _accrueInfo;
    }

    function _isSolvent(
        address user,
        bool open,
        uint256 _exchangeRate
    ) internal view returns (bool) {

        uint256 borrowPart = userBorrowPart[user];
        if (borrowPart == 0) return true;
        uint256 collateralShare = userCollateralShare[user];
        if (collateralShare == 0) return false;

        Rebase memory _totalBorrow = totalBorrow;

        return
            bentoBox.toAmount(
                collateral,
                collateralShare.mul(EXCHANGE_RATE_PRECISION / COLLATERIZATION_RATE_PRECISION).mul(
                    open ? OPEN_COLLATERIZATION_RATE : CLOSED_COLLATERIZATION_RATE
                ),
                false
            ) >=
            borrowPart.mul(_totalBorrow.elastic).mul(_exchangeRate) / _totalBorrow.base;
    }

    modifier solvent() {

        _;
        require(_isSolvent(msg.sender, false, exchangeRate), "KashiPair: user insolvent");
    }

    function updateExchangeRate() public returns (bool updated, uint256 rate) {

        (updated, rate) = oracle.get(oracleData);

        if (updated) {
            exchangeRate = rate;
            emit LogExchangeRate(rate);
        } else {
            rate = exchangeRate;
        }
    }

    function _addTokens(
        IERC20 token,
        uint256 share,
        uint256 total,
        bool skim
    ) internal {

        if (skim) {
            require(share <= bentoBox.balanceOf(token, address(this)).sub(total), "KashiPair: Skim too much");
        } else {
            bentoBox.transfer(token, msg.sender, address(this), share);
        }
    }

    function addCollateral(
        address to,
        bool skim,
        uint256 share
    ) public {

        userCollateralShare[to] = userCollateralShare[to].add(share);
        uint256 oldTotalCollateralShare = totalCollateralShare;
        totalCollateralShare = oldTotalCollateralShare.add(share);
        _addTokens(collateral, share, oldTotalCollateralShare, skim);
        emit LogAddCollateral(skim ? address(bentoBox) : msg.sender, to, share);
    }

    function _removeCollateral(address to, uint256 share) internal {

        userCollateralShare[msg.sender] = userCollateralShare[msg.sender].sub(share);
        totalCollateralShare = totalCollateralShare.sub(share);
        emit LogRemoveCollateral(msg.sender, to, share);
        bentoBox.transfer(collateral, address(this), to, share);
    }

    function removeCollateral(address to, uint256 share) public solvent {

        accrue();
        _removeCollateral(to, share);
    }

    function _addAsset(
        address to,
        bool skim,
        uint256 share
    ) internal returns (uint256 fraction) {

        Rebase memory _totalAsset = totalAsset;
        uint256 totalAssetShare = _totalAsset.elastic;
        uint256 allShare = _totalAsset.elastic + bentoBox.toShare(asset, totalBorrow.elastic, true);
        fraction = allShare == 0 ? share : share.mul(_totalAsset.base) / allShare;
        if (_totalAsset.base.add(fraction.to128()) < 1000) {
            return 0;
        }
        totalAsset = _totalAsset.add(share, fraction);
        balanceOf[to] = balanceOf[to].add(fraction);
        emit Transfer(address(0), to, fraction);
        _addTokens(asset, share, totalAssetShare, skim);
        emit LogAddAsset(skim ? address(bentoBox) : msg.sender, to, share, fraction);
    }

    function addAsset(
        address to,
        bool skim,
        uint256 share
    ) public returns (uint256 fraction) {

        accrue();
        fraction = _addAsset(to, skim, share);
    }

    function _removeAsset(address to, uint256 fraction) internal returns (uint256 share) {

        Rebase memory _totalAsset = totalAsset;
        uint256 allShare = _totalAsset.elastic + bentoBox.toShare(asset, totalBorrow.elastic, true);
        share = fraction.mul(allShare) / _totalAsset.base;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(fraction);
        emit Transfer(msg.sender, address(0), fraction);
        _totalAsset.elastic = _totalAsset.elastic.sub(share.to128());
        _totalAsset.base = _totalAsset.base.sub(fraction.to128());
        require(_totalAsset.base >= 1000, "Kashi: below minimum");
        totalAsset = _totalAsset;
        emit LogRemoveAsset(msg.sender, to, share, fraction);
        bentoBox.transfer(asset, address(this), to, share);
    }

    function removeAsset(address to, uint256 fraction) public returns (uint256 share) {

        accrue();
        share = _removeAsset(to, fraction);
    }

    function _borrow(address to, uint256 amount) internal returns (uint256 part, uint256 share) {

        uint256 feeAmount = amount.mul(BORROW_OPENING_FEE) / BORROW_OPENING_FEE_PRECISION; // A flat % fee is charged for any borrow

        (totalBorrow, part) = totalBorrow.add(amount.add(feeAmount), true);
        userBorrowPart[msg.sender] = userBorrowPart[msg.sender].add(part);
        emit LogBorrow(msg.sender, to, amount, feeAmount, part);

        share = bentoBox.toShare(asset, amount, false);
        Rebase memory _totalAsset = totalAsset;
        require(_totalAsset.base >= 1000, "Kashi: below minimum");
        _totalAsset.elastic = _totalAsset.elastic.sub(share.to128());
        totalAsset = _totalAsset;
        bentoBox.transfer(asset, address(this), to, share);
    }

    function borrow(address to, uint256 amount) public solvent returns (uint256 part, uint256 share) {

        accrue();
        (part, share) = _borrow(to, amount);
    }

    function _repay(
        address to,
        bool skim,
        uint256 part
    ) internal returns (uint256 amount) {

        (totalBorrow, amount) = totalBorrow.sub(part, true);
        userBorrowPart[to] = userBorrowPart[to].sub(part);

        uint256 share = bentoBox.toShare(asset, amount, true);
        uint128 totalShare = totalAsset.elastic;
        _addTokens(asset, share, uint256(totalShare), skim);
        totalAsset.elastic = totalShare.add(share.to128());
        emit LogRepay(skim ? address(bentoBox) : msg.sender, to, amount, part);
    }

    function repay(
        address to,
        bool skim,
        uint256 part
    ) public returns (uint256 amount) {

        accrue();
        amount = _repay(to, skim, part);
    }

    uint8 internal constant ACTION_ADD_ASSET = 1;
    uint8 internal constant ACTION_REPAY = 2;
    uint8 internal constant ACTION_REMOVE_ASSET = 3;
    uint8 internal constant ACTION_REMOVE_COLLATERAL = 4;
    uint8 internal constant ACTION_BORROW = 5;
    uint8 internal constant ACTION_GET_REPAY_SHARE = 6;
    uint8 internal constant ACTION_GET_REPAY_PART = 7;
    uint8 internal constant ACTION_ACCRUE = 8;

    uint8 internal constant ACTION_ADD_COLLATERAL = 10;
    uint8 internal constant ACTION_UPDATE_EXCHANGE_RATE = 11;

    uint8 internal constant ACTION_BENTO_DEPOSIT = 20;
    uint8 internal constant ACTION_BENTO_WITHDRAW = 21;
    uint8 internal constant ACTION_BENTO_TRANSFER = 22;
    uint8 internal constant ACTION_BENTO_TRANSFER_MULTIPLE = 23;
    uint8 internal constant ACTION_BENTO_SETAPPROVAL = 24;

    uint8 internal constant ACTION_CALL = 30;

    int256 internal constant USE_VALUE1 = -1;
    int256 internal constant USE_VALUE2 = -2;

    function _num(
        int256 inNum,
        uint256 value1,
        uint256 value2
    ) internal pure returns (uint256 outNum) {

        outNum = inNum >= 0 ? uint256(inNum) : (inNum == USE_VALUE1 ? value1 : value2);
    }

    function _bentoDeposit(
        bytes memory data,
        uint256 value,
        uint256 value1,
        uint256 value2
    ) internal returns (uint256, uint256) {

        (IERC20 token, address to, int256 amount, int256 share) = abi.decode(data, (IERC20, address, int256, int256));
        amount = int256(_num(amount, value1, value2)); // Done this way to avoid stack too deep errors
        share = int256(_num(share, value1, value2));
        return bentoBox.deposit{value: value}(token, msg.sender, to, uint256(amount), uint256(share));
    }

    function _bentoWithdraw(
        bytes memory data,
        uint256 value1,
        uint256 value2
    ) internal returns (uint256, uint256) {

        (IERC20 token, address to, int256 amount, int256 share) = abi.decode(data, (IERC20, address, int256, int256));
        return bentoBox.withdraw(token, msg.sender, to, _num(amount, value1, value2), _num(share, value1, value2));
    }

    function _call(
        uint256 value,
        bytes memory data,
        uint256 value1,
        uint256 value2
    ) internal returns (bytes memory, uint8) {

        (address callee, bytes memory callData, bool useValue1, bool useValue2, uint8 returnValues) =
            abi.decode(data, (address, bytes, bool, bool, uint8));

        if (useValue1 && !useValue2) {
            callData = abi.encodePacked(callData, value1);
        } else if (!useValue1 && useValue2) {
            callData = abi.encodePacked(callData, value2);
        } else if (useValue1 && useValue2) {
            callData = abi.encodePacked(callData, value1, value2);
        }

        require(callee != address(bentoBox) && callee != address(this), "KashiPair: can't call");

        (bool success, bytes memory returnData) = callee.call{value: value}(callData);
        require(success, "KashiPair: call failed");
        return (returnData, returnValues);
    }

    struct CookStatus {
        bool needsSolvencyCheck;
        bool hasAccrued;
    }

    function cook(
        uint8[] calldata actions,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external payable returns (uint256 value1, uint256 value2) {

        CookStatus memory status;
        for (uint256 i = 0; i < actions.length; i++) {
            uint8 action = actions[i];
            if (!status.hasAccrued && action < 10) {
                accrue();
                status.hasAccrued = true;
            }
            if (action == ACTION_ADD_COLLATERAL) {
                (int256 share, address to, bool skim) = abi.decode(datas[i], (int256, address, bool));
                addCollateral(to, skim, _num(share, value1, value2));
            } else if (action == ACTION_ADD_ASSET) {
                (int256 share, address to, bool skim) = abi.decode(datas[i], (int256, address, bool));
                value1 = _addAsset(to, skim, _num(share, value1, value2));
            } else if (action == ACTION_REPAY) {
                (int256 part, address to, bool skim) = abi.decode(datas[i], (int256, address, bool));
                _repay(to, skim, _num(part, value1, value2));
            } else if (action == ACTION_REMOVE_ASSET) {
                (int256 fraction, address to) = abi.decode(datas[i], (int256, address));
                value1 = _removeAsset(to, _num(fraction, value1, value2));
            } else if (action == ACTION_REMOVE_COLLATERAL) {
                (int256 share, address to) = abi.decode(datas[i], (int256, address));
                _removeCollateral(to, _num(share, value1, value2));
                status.needsSolvencyCheck = true;
            } else if (action == ACTION_BORROW) {
                (int256 amount, address to) = abi.decode(datas[i], (int256, address));
                (value1, value2) = _borrow(to, _num(amount, value1, value2));
                status.needsSolvencyCheck = true;
            } else if (action == ACTION_UPDATE_EXCHANGE_RATE) {
                (bool must_update, uint256 minRate, uint256 maxRate) = abi.decode(datas[i], (bool, uint256, uint256));
                (bool updated, uint256 rate) = updateExchangeRate();
                require((!must_update || updated) && rate > minRate && (maxRate == 0 || rate > maxRate), "KashiPair: rate not ok");
            } else if (action == ACTION_BENTO_SETAPPROVAL) {
                (address user, address _masterContract, bool approved, uint8 v, bytes32 r, bytes32 s) =
                    abi.decode(datas[i], (address, address, bool, uint8, bytes32, bytes32));
                bentoBox.setMasterContractApproval(user, _masterContract, approved, v, r, s);
            } else if (action == ACTION_BENTO_DEPOSIT) {
                (value1, value2) = _bentoDeposit(datas[i], values[i], value1, value2);
            } else if (action == ACTION_BENTO_WITHDRAW) {
                (value1, value2) = _bentoWithdraw(datas[i], value1, value2);
            } else if (action == ACTION_BENTO_TRANSFER) {
                (IERC20 token, address to, int256 share) = abi.decode(datas[i], (IERC20, address, int256));
                bentoBox.transfer(token, msg.sender, to, _num(share, value1, value2));
            } else if (action == ACTION_BENTO_TRANSFER_MULTIPLE) {
                (IERC20 token, address[] memory tos, uint256[] memory shares) = abi.decode(datas[i], (IERC20, address[], uint256[]));
                bentoBox.transferMultiple(token, msg.sender, tos, shares);
            } else if (action == ACTION_CALL) {
                (bytes memory returnData, uint8 returnValues) = _call(values[i], datas[i], value1, value2);

                if (returnValues == 1) {
                    (value1) = abi.decode(returnData, (uint256));
                } else if (returnValues == 2) {
                    (value1, value2) = abi.decode(returnData, (uint256, uint256));
                }
            } else if (action == ACTION_GET_REPAY_SHARE) {
                int256 part = abi.decode(datas[i], (int256));
                value1 = bentoBox.toShare(asset, totalBorrow.toElastic(_num(part, value1, value2), true), true);
            } else if (action == ACTION_GET_REPAY_PART) {
                int256 amount = abi.decode(datas[i], (int256));
                value1 = totalBorrow.toBase(_num(amount, value1, value2), false);
            }
        }

        if (status.needsSolvencyCheck) {
            require(_isSolvent(msg.sender, false, exchangeRate), "KashiPair: user insolvent");
        }
    }

    function liquidate(
        address[] calldata users,
        uint256[] calldata maxBorrowParts,
        address to,
        ISwapper swapper,
        bool open
    ) public {

        (, uint256 _exchangeRate) = updateExchangeRate();
        accrue();

        uint256 allCollateralShare;
        uint256 allBorrowAmount;
        uint256 allBorrowPart;
        Rebase memory _totalBorrow = totalBorrow;
        Rebase memory bentoBoxTotals = bentoBox.totals(collateral);
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            if (!_isSolvent(user, open, _exchangeRate)) {
                uint256 borrowPart;
                {
                    uint256 availableBorrowPart = userBorrowPart[user];
                    borrowPart = maxBorrowParts[i] > availableBorrowPart ? availableBorrowPart : maxBorrowParts[i];
                    userBorrowPart[user] = availableBorrowPart.sub(borrowPart);
                }
                uint256 borrowAmount = _totalBorrow.toElastic(borrowPart, false);
                uint256 collateralShare =
                    bentoBoxTotals.toBase(
                        borrowAmount.mul(LIQUIDATION_MULTIPLIER).mul(_exchangeRate) /
                            (LIQUIDATION_MULTIPLIER_PRECISION * EXCHANGE_RATE_PRECISION),
                        false
                    );

                userCollateralShare[user] = userCollateralShare[user].sub(collateralShare);
                emit LogRemoveCollateral(user, swapper == ISwapper(0) ? to : address(swapper), collateralShare);
                emit LogRepay(swapper == ISwapper(0) ? msg.sender : address(swapper), user, borrowAmount, borrowPart);

                allCollateralShare = allCollateralShare.add(collateralShare);
                allBorrowAmount = allBorrowAmount.add(borrowAmount);
                allBorrowPart = allBorrowPart.add(borrowPart);
            }
        }
        require(allBorrowAmount != 0, "KashiPair: all are solvent");
        _totalBorrow.elastic = _totalBorrow.elastic.sub(allBorrowAmount.to128());
        _totalBorrow.base = _totalBorrow.base.sub(allBorrowPart.to128());
        totalBorrow = _totalBorrow;
        totalCollateralShare = totalCollateralShare.sub(allCollateralShare);

        uint256 allBorrowShare = bentoBox.toShare(asset, allBorrowAmount, true);

        if (!open) {
            require(masterContract.swappers(swapper), "KashiPair: Invalid swapper");

            bentoBox.transfer(collateral, address(this), address(swapper), allCollateralShare);
            swapper.swap(collateral, asset, address(this), allBorrowShare, allCollateralShare);

            uint256 returnedShare = bentoBox.balanceOf(asset, address(this)).sub(uint256(totalAsset.elastic));
            uint256 extraShare = returnedShare.sub(allBorrowShare);
            uint256 feeShare = extraShare.mul(PROTOCOL_FEE) / PROTOCOL_FEE_DIVISOR; // % of profit goes to fee
            bentoBox.transfer(asset, address(this), masterContract.feeTo(), feeShare);
            totalAsset.elastic = totalAsset.elastic.add(returnedShare.sub(feeShare).to128());
            emit LogAddAsset(address(swapper), address(this), extraShare.sub(feeShare), 0);
        } else {
            bentoBox.transfer(collateral, address(this), swapper == ISwapper(0) ? to : address(swapper), allCollateralShare);
            if (swapper != ISwapper(0)) {
                swapper.swap(collateral, asset, msg.sender, allBorrowShare, allCollateralShare);
            }

            bentoBox.transfer(asset, msg.sender, address(this), allBorrowShare);
            totalAsset.elastic = totalAsset.elastic.add(allBorrowShare.to128());
        }
    }

    function withdrawFees() public {

        accrue();
        address _feeTo = masterContract.feeTo();
        uint256 _feesEarnedFraction = accrueInfo.feesEarnedFraction;
        balanceOf[_feeTo] = balanceOf[_feeTo].add(_feesEarnedFraction);
        emit Transfer(address(0), _feeTo, _feesEarnedFraction);
        accrueInfo.feesEarnedFraction = 0;

        emit LogWithdrawFees(_feeTo, _feesEarnedFraction);
    }

    function setSwapper(ISwapper swapper, bool enable) public onlyOwner {

        swappers[swapper] = enable;
    }

    function setFeeTo(address newFeeTo) public onlyOwner {

        feeTo = newFeeTo;
        emit LogFeeTo(newFeeTo);
    }
}