
pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/v3.0.0/contracts/Initializable.sol

pragma solidity 0.6.10;

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    function isInitialized() public view returns (bool) {

        return initialized;
    }

    uint256[50] private ______gap;
}// MIT
pragma solidity 0.6.10;



contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_initialize(string memory name, string memory symbol) internal initializer {

        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public virtual view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public virtual override view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function updateNameAndSymbol(string memory __name, string memory __symbol) internal {

        _name = __name;
        _symbol = __symbol;
    }
}// MIT
pragma solidity 0.6.10;


interface IERC20WithDecimals is IERC20 {

    function decimals() external view returns (uint256);

}// MIT
pragma solidity 0.6.10;


interface ITrueFiPoolOracle {

    function token() external view returns (IERC20WithDecimals);


    function truToToken(uint256 truAmount) external view returns (uint256);


    function tokenToTru(uint256 tokenAmount) external view returns (uint256);


    function tokenToUsd(uint256 tokenAmount) external view returns (uint256);

}// MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

interface I1Inch3 {

    struct SwapDescription {
        address srcToken;
        address dstToken;
        address srcReceiver;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
        external
        returns (
            uint256 returnAmount,
            uint256 gasLeft,
            uint256 chiSpent
        );


    function unoswap(
        address srcToken,
        uint256 amount,
        uint256 minReturn,
        bytes32[] calldata /* pools */
    ) external payable returns (uint256 returnAmount);

}// MIT
pragma solidity 0.6.10;


interface ILoanToken2 is IERC20 {

    enum Status {Awaiting, Funded, Withdrawn, Settled, Defaulted, Liquidated}

    function borrower() external view returns (address);


    function amount() external view returns (uint256);


    function term() external view returns (uint256);


    function apy() external view returns (uint256);


    function start() external view returns (uint256);


    function lender() external view returns (address);


    function debt() external view returns (uint256);


    function pool() external view returns (ITrueFiPool2);


    function profit() external view returns (uint256);


    function status() external view returns (Status);


    function getParameters()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function fund() external;


    function withdraw(address _beneficiary) external;


    function settle() external;


    function enterDefault() external;


    function liquidate() external;


    function redeem(uint256 _amount) external;


    function repay(address _sender, uint256 _amount) external;


    function repayInFull(address _sender) external;


    function reclaim() external;


    function allowTransfer(address account, bool _status) external;


    function repaid() external view returns (uint256);


    function isRepaid() external view returns (bool);


    function balance() external view returns (uint256);


    function value(uint256 _balance) external view returns (uint256);


    function token() external view returns (ERC20);


    function version() external pure returns (uint8);

}

pragma solidity 0.6.10;


interface IDeficiencyToken is IERC20 {

    function loan() external view returns (ILoanToken2);


    function burnFrom(address account, uint256 amount) external;


    function version() external pure returns (uint8);

}// MIT
pragma solidity 0.6.10;


interface ISAFU {

    function poolDeficit(address pool) external view returns (uint256);


    function deficiencyToken(ILoanToken2 loan) external view returns (IDeficiencyToken);


    function reclaim(ILoanToken2 loan, uint256 amount) external;

}// MIT
pragma solidity 0.6.10;


interface ITrueFiPool2 is IERC20 {

    function initialize(
        ERC20 _token,
        ITrueLender2 _lender,
        ISAFU safu,
        address __owner
    ) external;


    function singleBorrowerInitialize(
        ERC20 _token,
        ITrueLender2 _lender,
        ISAFU safu,
        address __owner,
        string memory borrowerName,
        string memory borrowerSymbol
    ) external;


    function token() external view returns (ERC20);


    function oracle() external view returns (ITrueFiPoolOracle);


    function poolValue() external view returns (uint256);


    function liquidRatio(uint256 afterAmountLent) external view returns (uint256);


    function join(uint256 amount) external;


    function borrow(uint256 amount) external;


    function repay(uint256 currencyAmount) external;


    function liquidate(ILoanToken2 loan) external;

}// MIT
pragma solidity 0.6.10;


interface ITrueLender2 {

    function value(ITrueFiPool2 pool) external view returns (uint256);


    function distribute(
        address recipient,
        uint256 numerator,
        uint256 denominator
    ) external;


    function transferAllLoanTokens(ILoanToken2 loan, address recipient) external;

}// MIT
pragma solidity 0.6.10;



contract DeficiencyToken is IDeficiencyToken, ERC20 {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ILoanToken2 public override loan;

    constructor(ILoanToken2 _loan, uint256 _amount) public {
        ERC20.__ERC20_initialize("TrueFi Deficiency Token", "DEF");

        loan = _loan;
        _mint(address(_loan.pool()), _amount);
    }

    function burnFrom(address account, uint256 amount) external override {

        _approve(
            account,
            _msgSender(),
            allowance(account, _msgSender()).sub(amount, "DeficiencyToken: Burn amount exceeds allowance")
        );
        _burn(account, amount);
    }

    function version() external override pure returns (uint8) {

        return 0;
    }
}// MIT
pragma solidity 0.6.10;



contract UpgradeableClaimable is Initializable, Context {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address __owner) internal initializer {

        _owner = __owner;
        emit OwnershipTransferred(address(0), __owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function pendingOwner() public view returns (address) {

        return _pendingOwner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}// MIT
pragma solidity 0.6.10;


interface ILoanFactory2 {

    function createLoanToken(
        ITrueFiPool2 _pool,
        uint256 _amount,
        uint256 _term
    ) external;


    function isLoanToken(address) external view returns (bool);

}// MIT
pragma solidity 0.6.10;


interface ILiquidator2 {

    function liquidate(ILoanToken2 loan) external;

}// MIT
pragma solidity 0.6.10;


interface IUniRouter {

    function token0() external view returns (address);


    function token1() external view returns (address);

}

library OneInchExchange {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 constant ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 constant REVERSE_MASK = 0x8000000000000000000000000000000000000000000000000000000000000000;

    event Swapped(I1Inch3.SwapDescription description, uint256 returnedAmount);


    function exchange(I1Inch3 _1inchExchange, bytes calldata data)
        internal
        returns (I1Inch3.SwapDescription memory description, uint256 returnedAmount)
    {

        if (data[0] == 0x7c) {
            (, description, ) = abi.decode(data[4:], (address, I1Inch3.SwapDescription, bytes));
        } else {
            (address srcToken, uint256 amount, uint256 minReturn, bytes32[] memory pathData) = abi.decode(
                data[4:],
                (address, uint256, uint256, bytes32[])
            );
            description.srcToken = srcToken;
            description.amount = amount;
            description.minReturnAmount = minReturn;
            description.flags = 0;
            uint256 lastPath = uint256(pathData[pathData.length - 1]);
            IUniRouter uniRouter = IUniRouter(address(lastPath & ADDRESS_MASK));
            bool isReverse = lastPath & REVERSE_MASK > 0;
            description.dstToken = isReverse ? uniRouter.token0() : uniRouter.token1();
            description.dstReceiver = address(this);
        }

        IERC20(description.srcToken).safeApprove(address(_1inchExchange), description.amount);
        uint256 balanceBefore = IERC20(description.dstToken).balanceOf(description.dstReceiver);
        (bool success, ) = address(_1inchExchange).call(data);
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        uint256 balanceAfter = IERC20(description.dstToken).balanceOf(description.dstReceiver);
        returnedAmount = balanceAfter.sub(balanceBefore);

        emit Swapped(description, returnedAmount);
    }
}// MIT
pragma solidity 0.6.10;



contract SAFU is ISAFU, UpgradeableClaimable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IDeficiencyToken;
    using SafeERC20 for ERC20;
    using OneInchExchange for I1Inch3;


    ILoanFactory2 public loanFactory;
    ILiquidator2 public liquidator;
    I1Inch3 public _1Inch;

    mapping(ILoanToken2 => IDeficiencyToken) public override deficiencyToken;
    mapping(address => uint256) public override poolDeficit;


    event Redeemed(ILoanToken2 loan, uint256 burnedAmount, uint256 redeemedAmount);

    event Liquidated(ILoanToken2 loan, uint256 repaid, IDeficiencyToken deficiencyToken, uint256 deficit);

    event Reclaimed(ILoanToken2 loan, uint256 reclaimed);

    event Swapped(uint256 amount, address srcToken, uint256 returnAmount, address dstToken);

    function initialize(
        ILoanFactory2 _loanFactory,
        ILiquidator2 _liquidator,
        I1Inch3 __1Inch
    ) public initializer {

        UpgradeableClaimable.initialize(msg.sender);
        loanFactory = _loanFactory;
        liquidator = _liquidator;
        _1Inch = __1Inch;
    }

    function liquidate(ILoanToken2 loan) external {

        require(loanFactory.isLoanToken(address(loan)), "SAFU: Unknown loan");
        require(loan.status() == ILoanToken2.Status.Defaulted, "SAFU: Loan is not defaulted");

        ITrueFiPool2 pool = ITrueFiPool2(loan.pool());
        IERC20 token = IERC20(pool.token());

        liquidator.liquidate(loan);
        pool.liquidate(loan);
        uint256 owedToPool = loan.debt().mul(tokenBalance(loan)).div(loan.totalSupply());
        uint256 safuTokenBalance = tokenBalance(token);

        uint256 deficit = 0;
        uint256 toTransfer = owedToPool;
        if (owedToPool > safuTokenBalance) {
            deficit = owedToPool.sub(safuTokenBalance);
            toTransfer = safuTokenBalance;
            deficiencyToken[loan] = new DeficiencyToken(loan, deficit);
            poolDeficit[address(loan.pool())] = poolDeficit[address(loan.pool())].add(deficit);
        }
        token.safeTransfer(address(pool), toTransfer);
        emit Liquidated(loan, toTransfer, deficiencyToken[loan], deficit);
    }

    function tokenBalance(IERC20 token) public view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function redeem(ILoanToken2 loan) public onlyOwner {

        require(loanFactory.isLoanToken(address(loan)), "SAFU: Unknown loan");
        uint256 amountToBurn = tokenBalance(loan);
        uint256 balanceBeforeRedeem = tokenBalance(loan.token());
        loan.redeem(amountToBurn);
        uint256 redeemedAmount = tokenBalance(loan.token()).sub(balanceBeforeRedeem);
        emit Redeemed(loan, amountToBurn, redeemedAmount);
    }

    function reclaim(ILoanToken2 loan, uint256 amount) external override {

        require(loanFactory.isLoanToken(address(loan)), "SAFU: Unknown loan");
        address poolAddress = address(loan.pool());
        require(msg.sender == poolAddress, "SAFU: caller is not the loan's pool");
        require(tokenBalance(loan) == 0, "SAFU: Loan has to be fully redeemed by SAFU");
        IDeficiencyToken dToken = deficiencyToken[loan];
        require(address(dToken) != address(0), "SAFU: No deficiency token found for loan");
        require(dToken.balanceOf(poolAddress) > 0, "SAFU: Pool does not have deficiency tokens to be reclaimed");

        poolDeficit[poolAddress] = poolDeficit[poolAddress].sub(amount);
        dToken.burnFrom(msg.sender, amount);
        loan.token().safeTransfer(poolAddress, amount);

        emit Reclaimed(loan, amount);
    }

    function swap(bytes calldata data, uint256 minReturnAmount) external onlyOwner {

        (I1Inch3.SwapDescription memory swapResult, uint256 returnAmount) = _1Inch.exchange(data);
        require(swapResult.dstReceiver == address(this), "SAFU: Receiver is not SAFU");
        require(returnAmount >= minReturnAmount, "SAFU: Not enough tokens returned from swap");

        emit Swapped(swapResult.amount, swapResult.srcToken, returnAmount, swapResult.dstToken);
    }
}