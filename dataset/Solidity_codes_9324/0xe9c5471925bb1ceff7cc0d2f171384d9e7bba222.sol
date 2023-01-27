
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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


    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal onlyInitializing {
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// GPL-3.0
pragma solidity ^0.8.4;


abstract contract NoContractUpgradeable is OwnableUpgradeable {

    event ContractWhitelistChanged(address indexed addr, bool isWhitelisted);

    mapping(address => bool) public whitelistedContracts;

    modifier noContract() {
        require(
            msg.sender == tx.origin || whitelistedContracts[msg.sender],
            "NO_CONTRACTS"
        );
        _;
    }

    function __noContract_init() internal onlyInitializing {
        __Ownable_init();
    }

    function setContractWhitelisted(address addr, bool isWhitelisted)
        external
        onlyOwner
    {
        whitelistedContracts[addr] = isWhitelisted;

        emit ContractWhitelistChanged(addr, isWhitelisted);
    }

    uint256[50] __gap;
}// GPL-3.0
pragma solidity ^0.8.4;

interface IStrategy {

    function deposit() external;


    function withdraw(address _to, address _asset) external;


    function withdraw(address _to, uint256 _amount) external;


    function withdrawAll() external;


    function totalAssets() external view returns (uint256);

}// GPL-3.0
pragma solidity ^0.8.4;



contract Vault is ERC20PausableUpgradeable, NoContractUpgradeable {

    using SafeERC20Upgradeable for ERC20Upgradeable;

    event Deposit(address indexed from, address indexed to, uint256 value);
    event Withdrawal(address indexed withdrawer, address indexed to, uint256 wantAmount);
    event StrategyMigrated(
        IStrategy indexed newStrategy,
        IStrategy indexed oldStrategy
    );
    event FeeRecipientChanged(
        address indexed newRecipient,
        address indexed oldRecipient
    );

    struct Rate {
        uint128 numerator;
        uint128 denominator;
    }

    ERC20Upgradeable public token;

    IStrategy public strategy;

    address public feeRecipient;
    Rate public depositFeeRate;

    function initialize(
        ERC20Upgradeable _token,
        address _feeRecipient,
        Rate memory _depositFeeRate
    ) external initializer {

        __ERC20_init(
            string(abi.encodePacked("JPEG\xE2\x80\x99d ", _token.name())),
            string(abi.encodePacked("JPEGD", _token.symbol()))
        );
        __noContract_init();

        _pause();

        setFeeRecipient(_feeRecipient);
        setDepositFeeRate(_depositFeeRate);
        token = _token;
    }

    function decimals() public view virtual override returns (uint8) {

        return token.decimals();
    }

    function totalAssets() public view returns (uint256 assets) {

        assets = token.balanceOf(address(this));

        IStrategy _strategy = strategy;
        if (address(_strategy) != address(0)) assets += strategy.totalAssets();
    }

    function exchangeRate() external view returns (uint256) {

        uint256 supply = totalSupply();
        if (supply == 0) return 0;
        return (totalAssets() * (10**decimals())) / supply;
    }

    function deposit(address _to, uint256 _amount)
        external
        noContract
        whenNotPaused
        returns (uint256 shares)
    {

        require(_amount != 0, "INVALID_AMOUNT");

        IStrategy _strategy = strategy;
        require(address(_strategy) != address(0), "NO_STRATEGY");

        uint256 balanceBefore = totalAssets();
        uint256 supply = totalSupply();

        uint256 depositFee = (depositFeeRate.numerator * _amount) /
            depositFeeRate.denominator;
        uint256 amountAfterFee = _amount - depositFee;

        if (supply == 0) {
            shares = amountAfterFee;
        } else {
            shares = (amountAfterFee * supply) / balanceBefore;
        }

        require(shares != 0, "ZERO_SHARES_MINTED");

        ERC20Upgradeable _token = token;

        if (depositFee != 0)
            _token.safeTransferFrom(msg.sender, feeRecipient, depositFee);
        _token.safeTransferFrom(msg.sender, address(_strategy), amountAfterFee);
        _mint(_to, shares);

        _strategy.deposit();

        emit Deposit(msg.sender, _to, amountAfterFee);
    }

    function depositBalance() external {

        IStrategy _strategy = strategy;
        require(address(_strategy) != address(0), "NO_STRATEGY");

        ERC20Upgradeable _token = token;

        uint256 balance = _token.balanceOf(address(this));
        require(balance > 0, "NO_BALANCE");

        _token.safeTransfer(address(_strategy), balance);

        _strategy.deposit();
    }

    function withdraw(address _to, uint256 _shares)
        external
        noContract
        whenNotPaused
        returns (uint256 backingTokens)
    {

        require(_shares != 0, "INVALID_AMOUNT");

        uint256 supply = totalSupply();
        require(supply != 0, "NO_TOKENS_DEPOSITED");

        uint256 assets = totalAssets();
        backingTokens = (assets * _shares) / supply;
        _burn(msg.sender, _shares);

        ERC20Upgradeable _token = token;
        uint256 vaultBalance = _token.balanceOf(address(this));
        if (vaultBalance >= backingTokens) {
            _token.safeTransfer(_to, backingTokens);
        } else {
            IStrategy _strategy = strategy;
            assert(address(_strategy) != address(0));

            if (assets - vaultBalance >= backingTokens) {
                _strategy.withdraw(_to, backingTokens);
            } else {
                _token.safeTransfer(_to, vaultBalance);
                _strategy.withdraw(_to, backingTokens - vaultBalance);
            }
        }

        emit Withdrawal(msg.sender, _to, backingTokens);
    }

    function migrateStrategy(IStrategy _newStrategy) external onlyOwner {

        IStrategy _strategy = strategy;
        require(_newStrategy != _strategy, "SAME_STRATEGY");

        if (address(_strategy) != address(0)) {
            _strategy.withdrawAll();
        }
        if (address(_newStrategy) != address(0)) {
            uint256 balance = token.balanceOf(address(this));
            if (balance > 0) {
                token.safeTransfer(address(_newStrategy), balance);
                _newStrategy.deposit();
            }
        }

        strategy = _newStrategy;

        emit StrategyMigrated(_newStrategy, _strategy);
    }

    function setFeeRecipient(address _newAddress) public onlyOwner {

        require(_newAddress != address(0), "INVALID_ADDRESS");

        emit FeeRecipientChanged(_newAddress, feeRecipient);

        feeRecipient = _newAddress;
    }

    function setDepositFeeRate(Rate memory _rate) public onlyOwner {

        require(
            _rate.denominator != 0 && _rate.denominator > _rate.numerator,
            "INVALID_RATE"
        );
        depositFeeRate = _rate;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function renounceOwnership() public view override onlyOwner {

        revert("Cannot renounce ownership");
    }
}