
pragma solidity 0.6.11;


library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {

        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {

        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


abstract contract ReentrancyGuard {

    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    uint private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint);


    function balanceOf(address account) external view returns (uint);


    function transfer(address recipient, uint amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}


library SafeERC20 {

    using SafeMath for uint;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        uint newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        uint newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata =
            address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract ERC20 is Context, IERC20 {

    using SafeMath for uint;

    mapping(address => uint) private _balances;

    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {

        return _balances[account];
    }

    function transfer(address recipient, uint amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint amount
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
        uint amount
    ) internal virtual {}

}



interface IStrategy {
    function admin() external view returns (address);

    function controller() external view returns (address);

    function vault() external view returns (address);

    function underlying() external view returns (address);

    function totalDebt() external view returns (uint);

    function performanceFee() external view returns (uint);

    function slippage() external view returns (uint);

    function delta() external view returns (uint);

    function setAdmin(address _admin) external;

    function setController(address _controller) external;

    function setPerformanceFee(uint _fee) external;

    function setSlippage(uint _slippage) external;

    function setDelta(uint _delta) external;

    function totalAssets() external view returns (uint);

    function withdraw(uint _amount) external;

    function withdrawAll() external;

    function harvest() external;

    function skim() external;

    function exit() external;

    function sweep(address _token) external;
}


interface IStrategyERC20 is IStrategy {
    function deposit(uint _amount) external;
}



interface IVault {
    function admin() external view returns (address);

    function controller() external view returns (address);

    function timeLock() external view returns (address);

    function token() external view returns (address);

    function strategy() external view returns (address);

    function strategies(address _strategy) external view returns (bool);

    function reserveMin() external view returns (uint);

    function withdrawFee() external view returns (uint);

    function paused() external view returns (bool);

    function whitelist(address _addr) external view returns (bool);

    function setWhitelist(address _addr, bool _approve) external;

    function setAdmin(address _admin) external;

    function setController(address _controller) external;

    function setTimeLock(address _timeLock) external;

    function setPause(bool _paused) external;

    function setReserveMin(uint _reserveMin) external;

    function setWithdrawFee(uint _fee) external;

    function balanceInVault() external view returns (uint);

    function balanceInStrategy() external view returns (uint);

    function totalDebtInStrategy() external view returns (uint);

    function totalAssets() external view returns (uint);

    function minReserve() external view returns (uint);

    function availableToInvest() external view returns (uint);

    function approveStrategy(address _strategy) external;

    function revokeStrategy(address _strategy) external;

    function setStrategy(address _strategy, uint _min) external;

    function invest() external;

    function getExpectedReturn(uint _shares) external view returns (uint);

    function withdraw(uint _shares, uint _min) external;

    function sweep(address _token) external;
}


interface IERC20Vault is IVault {
    function deposit(uint _amount) external;
}


interface IController {
    function ADMIN_ROLE() external view returns (bytes32);

    function HARVESTER_ROLE() external view returns (bytes32);

    function admin() external view returns (address);

    function treasury() external view returns (address);

    function setAdmin(address _admin) external;

    function setTreasury(address _treasury) external;

    function grantRole(bytes32 _role, address _addr) external;

    function revokeRole(bytes32 _role, address _addr) external;

    function setStrategy(
        address _vault,
        address _strategy,
        uint _min
    ) external;

    function invest(address _vault) external;

    function harvest(address _strategy) external;

    function skim(address _strategy) external;

    function withdraw(
        address _strategy,
        uint _amount,
        uint _min
    ) external;

    function withdrawAll(address _strategy, uint _min) external;

    function exit(address _strategy, uint _min) external;
}



contract ERC20Vault is IERC20Vault, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event SetStrategy(address strategy);
    event ApproveStrategy(address strategy);
    event RevokeStrategy(address strategy);
    event SetWhitelist(address addr, bool approved);

    address public override admin;
    address public override controller;
    address public override timeLock;
    address public immutable override token;
    address public override strategy;

    mapping(address => bool) public override strategies;

    uint public override reserveMin = 500;
    uint private constant RESERVE_MAX = 10000;

    uint private constant FEE_MAX = 10000;

    uint public override withdrawFee;
    uint private constant WITHDRAW_FEE_CAP = 500; // upper limit to withdrawFee

    bool public override paused;

    mapping(address => bool) public override whitelist;

    constructor(
        address _controller,
        address _timeLock,
        address _token
    )
        public
        ERC20(
            string(abi.encodePacked("unagii_", ERC20(_token).name())),
            string(abi.encodePacked("u", ERC20(_token).symbol()))
        )
    {
        require(_controller != address(0), "controller = zero address");
        require(_timeLock != address(0), "time lock = zero address");

        _setupDecimals(ERC20(_token).decimals());

        admin = msg.sender;
        controller = _controller;
        token = _token;
        timeLock = _timeLock;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "!admin");
        _;
    }

    modifier onlyTimeLock() {
        require(msg.sender == timeLock, "!time lock");
        _;
    }

    modifier onlyAdminOrController() {
        require(msg.sender == admin || msg.sender == controller, "!authorized");
        _;
    }

    modifier whenStrategyDefined() {
        require(strategy != address(0), "strategy = zero address");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        _;
    }

    modifier guard() {
        require((msg.sender == tx.origin) || whitelist[msg.sender], "!whitelist");
        _;
    }

    function setAdmin(address _admin) external override onlyAdmin {
        require(_admin != address(0), "admin = zero address");
        admin = _admin;
    }

    function setController(address _controller) external override onlyAdmin {
        require(_controller != address(0), "controller = zero address");
        controller = _controller;
    }

    function setTimeLock(address _timeLock) external override onlyTimeLock {
        require(_timeLock != address(0), "time lock = zero address");
        timeLock = _timeLock;
    }

    function setPause(bool _paused) external override onlyAdmin {
        paused = _paused;
    }

    function setWhitelist(address _addr, bool _approve) external override onlyAdmin {
        whitelist[_addr] = _approve;
        emit SetWhitelist(_addr, _approve);
    }

    function setReserveMin(uint _reserveMin) external override onlyAdmin {
        require(_reserveMin <= RESERVE_MAX, "reserve min > max");
        reserveMin = _reserveMin;
    }

    function setWithdrawFee(uint _fee) external override onlyAdmin {
        require(_fee <= WITHDRAW_FEE_CAP, "withdraw fee > cap");
        withdrawFee = _fee;
    }

    function _balanceInVault() private view returns (uint) {
        return IERC20(token).balanceOf(address(this));
    }

    function balanceInVault() external view override returns (uint) {
        return _balanceInVault();
    }

    function _balanceInStrategy() private view returns (uint) {
        if (strategy == address(0)) {
            return 0;
        }

        return IStrategyERC20(strategy).totalAssets();
    }

    function balanceInStrategy() external view override returns (uint) {
        return _balanceInStrategy();
    }

    function _totalDebtInStrategy() private view returns (uint) {
        if (strategy == address(0)) {
            return 0;
        }
        return IStrategyERC20(strategy).totalDebt();
    }

    function totalDebtInStrategy() external view override returns (uint) {
        return _totalDebtInStrategy();
    }

    function _totalAssets() private view returns (uint) {
        return _balanceInVault().add(_totalDebtInStrategy());
    }

    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    function _minReserve() private view returns (uint) {
        return _totalAssets().mul(reserveMin) / RESERVE_MAX;
    }

    function minReserve() external view override returns (uint) {
        return _minReserve();
    }

    function _availableToInvest() private view returns (uint) {
        if (strategy == address(0)) {
            return 0;
        }

        uint balInVault = _balanceInVault();
        uint reserve = _minReserve();

        if (balInVault <= reserve) {
            return 0;
        }

        return balInVault - reserve;
    }

    function availableToInvest() external view override returns (uint) {
        return _availableToInvest();
    }

    function approveStrategy(address _strategy) external override onlyTimeLock {
        require(_strategy != address(0), "strategy = zero address");
        strategies[_strategy] = true;

        emit ApproveStrategy(_strategy);
    }

    function revokeStrategy(address _strategy) external override onlyAdmin {
        require(_strategy != address(0), "strategy = zero address");
        strategies[_strategy] = false;

        emit RevokeStrategy(_strategy);
    }

    function setStrategy(address _strategy, uint _min)
        external
        override
        onlyAdminOrController
    {
        require(strategies[_strategy], "!approved");
        require(_strategy != strategy, "new strategy = current strategy");
        require(
            IStrategyERC20(_strategy).underlying() == token,
            "strategy.token != vault.token"
        );
        require(
            IStrategyERC20(_strategy).vault() == address(this),
            "strategy.vault != vault"
        );

        if (strategy != address(0)) {
            IERC20(token).safeApprove(strategy, 0);

            uint balBefore = _balanceInVault();
            IStrategyERC20(strategy).exit();
            uint balAfter = _balanceInVault();

            require(balAfter.sub(balBefore) >= _min, "withdraw < min");
        }

        strategy = _strategy;

        emit SetStrategy(strategy);
    }

    function invest()
        external
        override
        whenStrategyDefined
        whenNotPaused
        onlyAdminOrController
    {
        uint amount = _availableToInvest();
        require(amount > 0, "available = 0");

        IERC20(token).safeApprove(strategy, 0);
        IERC20(token).safeApprove(strategy, amount);

        IStrategyERC20(strategy).deposit(amount);

        IERC20(token).safeApprove(strategy, 0);
    }

    function deposit(uint _amount) external override whenNotPaused nonReentrant guard {
        require(_amount > 0, "amount = 0");

        uint totalUnderlying = _totalAssets();
        uint totalShares = totalSupply();

        uint shares;
        if (totalShares == 0) {
            shares = _amount;
        } else {
            shares = _amount.mul(totalShares).div(totalUnderlying);
        }

        _mint(msg.sender, shares);
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function _getExpectedReturn(
        uint _shares,
        uint _balInVault,
        uint _balInStrat
    ) private view returns (uint) {

        uint totalDebt = _totalDebtInStrategy();
        uint totalUnderlying;
        if (_balInStrat > totalDebt) {
            totalUnderlying = _balInVault.add(totalDebt);
        } else {
            totalUnderlying = _balInVault.add(_balInStrat);
        }

        uint totalShares = totalSupply();
        if (totalShares > 0) {
            return _shares.mul(totalUnderlying) / totalShares;
        }
        return 0;
    }

    function getExpectedReturn(uint _shares) external view override returns (uint) {
        uint balInVault = _balanceInVault();
        uint balInStrat = _balanceInStrategy();

        return _getExpectedReturn(_shares, balInVault, balInStrat);
    }

    function withdraw(uint _shares, uint _min) external override nonReentrant guard {
        require(_shares > 0, "shares = 0");

        uint balInVault = _balanceInVault();
        uint balInStrat = _balanceInStrategy();
        uint withdrawAmount = _getExpectedReturn(_shares, balInVault, balInStrat);

        _burn(msg.sender, _shares);

        if (balInVault < withdrawAmount) {
            uint amountFromStrat = withdrawAmount;
            if (balInStrat < withdrawAmount) {
                amountFromStrat = balInStrat;
            }

            IStrategyERC20(strategy).withdraw(amountFromStrat);

            uint balAfter = _balanceInVault();
            uint diff = balAfter.sub(balInVault);

            if (diff < amountFromStrat) {
                withdrawAmount = (withdrawAmount - amountFromStrat).add(diff);
            }

            uint fee = withdrawAmount.mul(withdrawFee) / FEE_MAX;
            if (fee > 0) {
                address treasury = IController(controller).treasury();
                require(treasury != address(0), "treasury = zero address");

                withdrawAmount = withdrawAmount - fee;
                IERC20(token).safeTransfer(treasury, fee);
            }
        }

        require(withdrawAmount >= _min, "withdraw < min");

        IERC20(token).safeTransfer(msg.sender, withdrawAmount);
    }

    function sweep(address _token) external override onlyAdmin {
        require(_token != token, "token = vault.token");
        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}