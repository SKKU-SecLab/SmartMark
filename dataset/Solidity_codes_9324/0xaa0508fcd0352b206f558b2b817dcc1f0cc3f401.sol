
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity ^0.8.0;

library AddrArrayLib {
    using AddrArrayLib for Addresses;

    struct Addresses {
        address[] _items;
    }

    function pushAddress(Addresses storage self, address element) internal {
        if (!exists(self, element)) {
            self._items.push(element);
        }
    }

    function removeAddress(Addresses storage self, address element) internal {
        for (uint256 i = 0; i < self.size(); i++) {
            if (self._items[i] == element) {
                self._items[i] = self._items[self.size() - 1];
                self._items.pop();
            }
        }
    }

    function getAddressAtIndex(Addresses memory self, uint256 index)
        internal
        view
        returns (address)
    {
        require(index < size(self), "INVALID_INDEX");
        return self._items[index];
    }

    function size(Addresses memory self) internal view returns (uint256) {
        return self._items.length;
    }

    function exists(Addresses memory self, address element)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < self.size(); i++) {
            if (self._items[i] == element) {
                return true;
            }
        }
        return false;
    }

    function getAllAddresses(Addresses memory self)
        internal
        view
        returns (address[] memory)
    {
        return self._items;
    }
}//GPL-3.0-only
pragma solidity ^0.8.0;

interface ITradeExecutor {
    struct ActionStatus {
        bool inProcess;
        address from;
    }
    function vault() external view returns (address);

    function depositStatus() external returns (bool, address);

    function withdrawalStatus() external returns (bool, address);

    function initiateDeposit(bytes calldata _data) external;

    function confirmDeposit() external;

    function initateWithdraw(bytes calldata _data) external;

    function confirmWithdraw() external;

    function totalFunds()
        external
        view
        returns (uint256 posValue, uint256 lastUpdatedBlock);
}/// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IVault {
    function keeper() external view returns (address);

    function governance() external view returns (address);

    function wantToken() external view returns (address);

    function deposit(uint256 amountIn, address receiver)
        external
        returns (uint256 shares);

    function withdraw(uint256 sharesIn, address receiver)
        external
        returns (uint256 amountOut);
}/// GPL-3.0-or-later
pragma solidity ^0.8.0;




contract Vault is IVault, ERC20, ReentrancyGuard {
    using AddrArrayLib for AddrArrayLib.Addresses;
    using SafeERC20 for IERC20;
    uint256 constant BLOCK_LIMIT = 50;
    uint256 constant DUST_LIMIT = 10**6;
    uint256 constant MAX_BPS = 10000;
    address public immutable override wantToken;
    uint8 private immutable tokenDecimals;

    bool public batcherOnlyDeposit;

    bool public emergencyMode;

    address public batcher;
    address public override keeper;
    address public override governance;
    address public pendingGovernance;

    constructor(
        string memory _name,
        string memory _symbol,
        address _wantToken,
        address _keeper,
        address _governance
    ) ERC20(_name, _symbol) {
        tokenDecimals = IERC20Metadata(_wantToken).decimals();
        wantToken = _wantToken;
        keeper = _keeper;
        governance = _governance;
        batcherOnlyDeposit = true;
    }

    function decimals() public view override returns (uint8) {
        return tokenDecimals;
    }

    function deposit(uint256 amountIn, address receiver)
        public
        override
        nonReentrant
        ensureFeesAreCollected
        returns (uint256 shares)
    {
        onlyBatcher();
        isValidAddress(receiver);
        require(amountIn > 0, "ZERO_AMOUNT");
        shares = totalSupply() > 0
            ? (totalSupply() * amountIn) / totalVaultFunds()
            : amountIn;
        IERC20(wantToken).safeTransferFrom(msg.sender, address(this), amountIn);
        _mint(receiver, shares);
    }

    function withdraw(uint256 sharesIn, address receiver)
        public
        override
        nonReentrant
        ensureFeesAreCollected
        returns (uint256 amountOut)
    {
        onlyBatcher();
        isValidAddress(receiver);
        require(sharesIn > 0, "ZERO_SHARES");
        amountOut = (sharesIn * totalVaultFunds()) / totalSupply();
        _burn(msg.sender, sharesIn);
        IERC20(wantToken).safeTransfer(receiver, amountOut);
    }

    function totalVaultFunds() public view returns (uint256) {
        return
            IERC20(wantToken).balanceOf(address(this)) + totalExecutorFunds();
    }


    AddrArrayLib.Addresses tradeExecutorsList;

    event ExecutorDeposit(address indexed executor, uint256 underlyingAmount);

    event ExecutorWithdrawal(
        address indexed executor,
        uint256 underlyingAmount
    );

    function depositIntoExecutor(address _executor, uint256 _amount)
        public
        nonReentrant
    {
        isActiveExecutor(_executor);
        onlyKeeper();
        require(_amount > 0, "ZERO_AMOUNT");
        IERC20(wantToken).safeTransfer(_executor, _amount);
        emit ExecutorDeposit(_executor, _amount);
    }

    function withdrawFromExecutor(address _executor, uint256 _amount)
        public
        nonReentrant
    {
        isActiveExecutor(_executor);
        onlyKeeper();
        require(_amount > 0, "ZERO_AMOUNT");
        IERC20(wantToken).safeTransferFrom(_executor, address(this), _amount);
        emit ExecutorWithdrawal(_executor, _amount);
    }

    uint256 public prevVaultFunds = type(uint256).max;
    uint256 public performanceFee;
    event UpdatePerformanceFee(uint256 fee);

    function setPerformanceFee(uint256 _fee) public {
        onlyGovernance();
        require(_fee < MAX_BPS / 2, "FEE_TOO_HIGH");
        performanceFee = _fee;
        emit UpdatePerformanceFee(_fee);
    }

    event FeesCollected(uint256 collectedFees);

    function collectFees() internal {
        uint256 currentFunds = totalVaultFunds();
        if ((performanceFee > 0) && (currentFunds > prevVaultFunds)) {
            uint256 yieldEarned = (currentFunds - prevVaultFunds);
            uint256 fees = ((yieldEarned * performanceFee) / MAX_BPS);
            IERC20(wantToken).safeTransfer(governance, fees);
            emit FeesCollected(fees);
        }
    }

    modifier ensureFeesAreCollected() {
        collectFees();
        _;
        prevVaultFunds = totalVaultFunds();
    }

    event ExecutorAdded(address indexed executor);

    event ExecutorRemoved(address indexed executor);

    function addExecutor(address _tradeExecutor) public {
        onlyGovernance();
        isValidAddress(_tradeExecutor);
        require(
            ITradeExecutor(_tradeExecutor).vault() == address(this),
            "INVALID_VAULT"
        );
        require(
            IERC20(wantToken).allowance(_tradeExecutor, address(this)) > 0,
            "NO_ALLOWANCE"
        );
        tradeExecutorsList.pushAddress(_tradeExecutor);
        emit ExecutorAdded(_tradeExecutor);
    }

    function removeExecutor(address _tradeExecutor) public {
        onlyGovernance();
        isValidAddress(_tradeExecutor);
        isActiveExecutor(_tradeExecutor);

        (uint256 executorFunds, uint256 blockUpdated) = ITradeExecutor(
            _tradeExecutor
        ).totalFunds();
        areFundsUpdated(blockUpdated);
        require(executorFunds < DUST_LIMIT, "FUNDS_TOO_HIGH");
        tradeExecutorsList.removeAddress(_tradeExecutor);
        emit ExecutorRemoved(_tradeExecutor);
    }

    function totalExecutors() public view returns (uint256) {
        return tradeExecutorsList.size();
    }

    function executorByIndex(uint256 _index) public view returns (address) {
        return tradeExecutorsList.getAddressAtIndex(_index);
    }

    function totalExecutorFunds() public view returns (uint256) {
        uint256 totalFunds = 0;
        for (uint256 i = 0; i < totalExecutors(); i++) {
            address executor = executorByIndex(i);
            (uint256 executorFunds, uint256 blockUpdated) = ITradeExecutor(
                executor
            ).totalFunds();
            areFundsUpdated(blockUpdated);
            totalFunds += executorFunds;
        }
        return totalFunds;
    }


    event UpdatedBatcher(
        address indexed oldBatcher,
        address indexed newBatcher
    );

    function setBatcher(address _batcher) public {
        onlyGovernance();
        emit UpdatedBatcher(batcher, _batcher);
        batcher = _batcher;
    }

    event UpdatedBatcherOnlyDeposit(bool state);

    function setBatcherOnlyDeposit(bool _batcherOnlyDeposit) public {
        onlyGovernance();
        batcherOnlyDeposit = _batcherOnlyDeposit;
        emit UpdatedBatcherOnlyDeposit(_batcherOnlyDeposit);
    }

    function setGovernance(address _governance) public {
        onlyGovernance();
        pendingGovernance = _governance;
    }

    event UpdatedGovernance(
        address indexed oldGovernance,
        address indexed newGovernance
    );

    function acceptGovernance() public {
        require(msg.sender == pendingGovernance, "INVALID_ADDRESS");
        emit UpdatedGovernance(governance, pendingGovernance);
        governance = pendingGovernance;
    }

    event UpdatedKeeper(address indexed keeper);

    function setKeeper(address _keeper) public {
        onlyGovernance();
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

    event EmergencyModeStatus(bool emergencyMode);

    function setEmergencyMode(bool _emergencyMode) public {
        onlyGovernance();
        emergencyMode = _emergencyMode;
        batcherOnlyDeposit = true;
        batcher = address(0);
        emit EmergencyModeStatus(_emergencyMode);
    }

    function sweep(address _token) public {
        isEmergencyMode();
        IERC20(_token).safeTransfer(
            governance,
            IERC20(_token).balanceOf(address(this))
        );
    }

    function onlyGovernance() internal view {
        require(msg.sender == governance, "ONLY_GOV");
    }

    function onlyKeeper() internal view {
        require(msg.sender == keeper, "ONLY_KEEPER");
    }

    function onlyBatcher() internal view {
        if (batcherOnlyDeposit) {
            require(msg.sender == batcher, "ONLY_BATCHER");
        }
    }

    function isEmergencyMode() internal view {
        require(emergencyMode == true, "EMERGENCY_MODE");
    }

    function isValidAddress(address _addr) internal pure {
        require(_addr != address(0), "NULL_ADDRESS");
    }

    function isActiveExecutor(address _tradeExecutor) internal view {
        require(tradeExecutorsList.exists(_tradeExecutor), "INVALID_EXECUTOR");
    }

    function areFundsUpdated(uint256 _blockUpdated) internal view {
        require(
            block.number <= _blockUpdated + BLOCK_LIMIT,
            "FUNDS_NOT_UPDATED"
        );
    }
}