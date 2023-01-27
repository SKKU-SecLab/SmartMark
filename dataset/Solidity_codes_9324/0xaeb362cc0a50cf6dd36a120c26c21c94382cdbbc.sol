
pragma solidity ^0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

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
pragma solidity 0.8.9;

interface IPoolFactory {

    function getPoolSymbol(address currency, address manager)
        external
        view
        returns (string memory);


    function isPool(address pool) external view returns (bool);


    function interestRateModel() external view returns (address);


    function auction() external view returns (address);


    function treasury() external view returns (address);


    function reserveFactor() external view returns (uint256);


    function insuranceFactor() external view returns (uint256);


    function warningUtilization() external view returns (uint256);


    function provisionalDefaultUtilization() external view returns (uint256);


    function warningGracePeriod() external view returns (uint256);


    function maxInactivePeriod() external view returns (uint256);


    function periodToStartAuction() external view returns (uint256);


    function owner() external view returns (address);


    function closePool() external;


    function burnStake() external;

}// MIT
pragma solidity 0.8.9;

interface IInterestRateModel {

    function getBorrowRate(
        uint256 balance,
        uint256 totalBorrows,
        uint256 totalReserves
    ) external view returns (uint256);


    function utilizationRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves
    ) external pure returns (uint256);


    function getSupplyRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactor
    ) external view returns (uint256);

}// MIT
pragma solidity 0.8.9;


abstract contract PoolBaseInfo is ERC20Upgradeable {
    address public manager;

    IERC20Upgradeable public currency;

    IPoolFactory public factory;

    IInterestRateModel public interestRateModel;

    uint256 public reserveFactor;

    uint256 public insuranceFactor;

    uint256 public warningUtilization;

    uint256 public provisionalDefaultUtilization;

    uint256 public warningGracePeriod;

    uint256 public maxInactivePeriod;

    uint256 public periodToStartAuction;

    enum State {
        Active,
        Warning,
        ProvisionalDefault,
        Default,
        Closed
    }

    bool public debtClaimed;

    struct BorrowInfo {
        uint256 principal;
        uint256 borrows;
        uint256 reserves;
        uint256 insurance;
        uint256 lastAccrual;
        uint256 enteredProvisionalDefault;
        uint256 enteredZeroUtilization;
        State state;
    }

    BorrowInfo internal _info;

    string internal _symbol;


    event Closed();

    event Provided(
        address indexed provider,
        uint256 currencyAmount,
        uint256 tokens
    );

    event Redeemed(
        address indexed redeemer,
        uint256 currencyAmount,
        uint256 tokens
    );

    event Borrowed(uint256 amount, address indexed receiver);

    event Repaid(uint256 amount);


    function __PoolBaseInfo_init(address manager_, IERC20Upgradeable currency_)
        internal
        onlyInitializing
    {
        require(manager_ != address(0), "AIZ");
        require(address(currency_) != address(0), "AIZ");

        manager = manager_;
        currency = currency_;
        factory = IPoolFactory(msg.sender);

        interestRateModel = IInterestRateModel(factory.interestRateModel());
        reserveFactor = factory.reserveFactor();
        insuranceFactor = factory.insuranceFactor();
        warningUtilization = factory.warningUtilization();
        provisionalDefaultUtilization = factory.provisionalDefaultUtilization();
        warningGracePeriod = factory.warningGracePeriod();
        maxInactivePeriod = factory.maxInactivePeriod();
        periodToStartAuction = factory.periodToStartAuction();

        _symbol = factory.getPoolSymbol(address(currency), address(manager));
        __ERC20_init(string(bytes.concat(bytes("Pool "), bytes(_symbol))), "");

        _info.enteredZeroUtilization = block.timestamp;
        _info.lastAccrual = block.timestamp;
    }
}// MIT
pragma solidity 0.8.9;

library Decimal {

    uint256 internal constant ONE = 1e18;

    function mulDecimal(uint256 number, uint256 decimal)
        internal
        pure
        returns (uint256)
    {

        return (number * decimal) / ONE;
    }

    function divDecimal(uint256 number, uint256 decimal)
        internal
        pure
        returns (uint256)
    {

        return (number * ONE) / decimal;
    }
}// MIT
pragma solidity 0.8.9;

interface IAuction {

    function bid(address pool, uint256 amount) external;


    function ownerOfDebt(address pool) external view returns (address);


    enum State {
        None,
        NotStarted,
        Active,
        Finished,
        Closed
    }

    function state(address pool) external view returns (State);

}// MIT
pragma solidity 0.8.9;


abstract contract PoolBase is PoolBaseInfo {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Decimal for uint256;


    function provide(uint256 currencyAmount) external {
        _provide(currencyAmount);
    }

    function provideWithPermit(
        uint256 currencyAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20PermitUpgradeable(address(currency)).permit(
            msg.sender,
            address(this),
            currencyAmount,
            deadline,
            v,
            r,
            s
        );
        _provide(currencyAmount);
    }

    function redeem(uint256 tokens) external {
        _accrueInterest();

        uint256 exchangeRate = _storedExchangeRate();
        uint256 currencyAmount;
        if (tokens == type(uint256).max) {
            (tokens, currencyAmount) = _maxWithdrawable(exchangeRate);
        } else {
            currencyAmount = tokens.mulDecimal(exchangeRate);
        }
        _redeem(tokens, currencyAmount);
    }

    function redeemCurrency(uint256 currencyAmount) external {
        _accrueInterest();

        uint256 exchangeRate = _storedExchangeRate();
        uint256 tokens;
        if (currencyAmount == type(uint256).max) {
            (tokens, currencyAmount) = _maxWithdrawable(exchangeRate);
        } else {
            tokens = currencyAmount.divDecimal(exchangeRate);
        }
        _redeem(tokens, currencyAmount);
    }

    function borrow(uint256 amount, address receiver)
        external
        onlyManager
        onlyActiveAccrual
    {
        if (amount == type(uint256).max) {
            amount = _availableToBorrow(_info);
        } else {
            require(amount <= _availableToBorrow(_info), "NEL");
        }
        require(amount > 0, "CBZ");

        _info.principal += amount;
        _info.borrows += amount;
        currency.safeTransfer(receiver, amount);

        _checkUtilization();

        emit Borrowed(amount, receiver);
    }

    function repay(uint256 amount, bool closeNow)
        external
        onlyManager
        onlyActiveAccrual
    {
        if (amount == type(uint256).max) {
            amount = _info.borrows;
        } else {
            require(amount <= _info.borrows, "MTB");
        }

        currency.safeTransferFrom(msg.sender, address(this), amount);

        if (amount > _info.borrows - _info.principal) {
            _info.principal -= amount - (_info.borrows - _info.principal);
        }
        _info.borrows -= amount;

        _checkUtilization();

        emit Repaid(amount);

        if (closeNow) {
            require(_info.borrows == 0, "BNZ");
            _close();
        }
    }

    function close() external {
        _accrueInterest();

        address governor = factory.owner();
        address debtOwner = ownerOfDebt();

        bool managerClosing = _info.borrows == 0 && msg.sender == manager;
        bool inactiveOverMax = _info.enteredZeroUtilization != 0 &&
            block.timestamp > _info.enteredZeroUtilization + maxInactivePeriod;
        bool governorClosing = msg.sender == governor &&
            (inactiveOverMax || debtOwner != address(0));
        bool ownerOfDebtClosing = msg.sender == debtOwner;

        require(managerClosing || governorClosing || ownerOfDebtClosing, "SCC");
        _close();
    }

    function allowWithdrawalAfterNoAuction() external {
        _accrueInterest();

        bool isDefaulting = _state(_info) == State.Default;
        bool auctionNotStarted = IAuction(factory.auction()).state(
            address(this)
        ) == IAuction.State.NotStarted;
        bool periodToStartPassed = block.timestamp >=
            _info.lastAccrual + periodToStartAuction;
        require(
            isDefaulting && auctionNotStarted && periodToStartPassed,
            "CDC"
        );
        _info.insurance = 0;
        debtClaimed = true;
        _close();
    }

    function transferReserves() external onlyGovernor {
        _accrueInterest();
        _transferReserves();
    }

    function forceDefault() external onlyGovernor onlyActiveAccrual {
        _info.state = State.Default;
    }

    function processAuctionStart() external onlyAuction {
        _accrueInterest();
        _transferReserves();
        factory.burnStake();
    }

    function processDebtClaim() external onlyAuction {
        _accrueInterest();
        _info.state = State.Default;

        address debtOwner = ownerOfDebt();
        if (_info.insurance > 0) {
            currency.safeTransfer(debtOwner, _info.insurance);
            _info.insurance = 0;
        }
        debtClaimed = true;
    }


    function _provide(uint256 currencyAmount) internal onlyActiveAccrual {
        uint256 exchangeRate = _storedExchangeRate();
        currency.safeTransferFrom(msg.sender, address(this), currencyAmount);
        uint256 tokens = currencyAmount.divDecimal(exchangeRate);
        _mint(msg.sender, tokens);
        _checkUtilization();

        emit Provided(msg.sender, currencyAmount, tokens);
    }

    function _redeem(uint256 tokensAmount, uint256 currencyAmount) internal {
        if (debtClaimed) {
            require(currencyAmount <= cash(), "NEC");
        } else {
            require(
                currencyAmount <= _availableToProviders(_info) &&
                    currencyAmount <= _availableProvisionalDefault(_info),
                "NEC"
            );
        }

        _burn(msg.sender, tokensAmount);
        currency.safeTransfer(msg.sender, currencyAmount);
        if (!debtClaimed) {
            _checkUtilization();
        }

        emit Redeemed(msg.sender, currencyAmount, tokensAmount);
    }

    function _transferReserves() internal {
        currency.safeTransfer(factory.treasury(), _info.reserves);
        _info.reserves = 0;
    }

    function _close() internal {
        require(_info.state != State.Closed, "PIC");

        _info.state = State.Closed;
        _transferReserves();
        if (_info.insurance > 0) {
            currency.safeTransfer(manager, _info.insurance);
            _info.insurance = 0;
        }
        factory.closePool();
        emit Closed();
    }

    function _accrueInterest() internal {
        _info = _accrueInterestVirtual();
    }

    function _checkUtilization() internal {
        if (_info.borrows == 0) {
            _info.enteredProvisionalDefault = 0;
            if (_info.enteredZeroUtilization == 0) {
                _info.enteredZeroUtilization = block.timestamp;
            }
            return;
        }

        _info.enteredZeroUtilization = 0;

        if (_info.borrows >= _poolSize(_info).mulDecimal(warningUtilization)) {
            if (
                _info.enteredProvisionalDefault == 0 &&
                _info.borrows >=
                _poolSize(_info).mulDecimal(provisionalDefaultUtilization)
            ) {
                _info.enteredProvisionalDefault = block.timestamp;
            }
        } else {
            _info.enteredProvisionalDefault = 0;
        }
    }


    function ownerOfDebt() public view returns (address) {
        return IAuction(factory.auction()).ownerOfDebt(address(this));
    }

    function cash() public view returns (uint256) {
        return currency.balanceOf(address(this));
    }


    function _state(BorrowInfo memory info) internal view returns (State) {
        if (info.state == State.Closed || info.state == State.Default) {
            return info.state;
        }
        if (info.enteredProvisionalDefault != 0) {
            if (
                block.timestamp >=
                info.enteredProvisionalDefault + warningGracePeriod
            ) {
                return State.Default;
            } else {
                return State.ProvisionalDefault;
            }
        }
        if (
            info.borrows > 0 &&
            info.borrows >= _poolSize(info).mulDecimal(warningUtilization)
        ) {
            return State.Warning;
        }
        return info.state;
    }

    function _interest(BorrowInfo memory info) internal pure returns (uint256) {
        return info.borrows - info.principal;
    }

    function _availableToProviders(BorrowInfo memory info)
        internal
        view
        returns (uint256)
    {
        return cash() - info.reserves - info.insurance;
    }

    function _availableToBorrow(BorrowInfo memory info)
        internal
        view
        returns (uint256)
    {
        uint256 basicAvailable = _availableToProviders(info) - _interest(info);
        uint256 borrowsForWarning = _poolSize(info).mulDecimal(
            warningUtilization
        );
        if (borrowsForWarning > info.borrows) {
            return
                MathUpgradeable.min(
                    borrowsForWarning - info.borrows,
                    basicAvailable
                );
        } else {
            return 0;
        }
    }

    function _poolSize(BorrowInfo memory info) internal view returns (uint256) {
        return _availableToProviders(info) + info.principal;
    }

    function _availableProvisionalDefault(BorrowInfo memory info)
        internal
        view
        returns (uint256)
    {
        if (provisionalDefaultUtilization == 0) {
            return 0;
        }
        uint256 poolSizeForProvisionalDefault = info.borrows.divDecimal(
            provisionalDefaultUtilization
        );
        uint256 currentPoolSize = _poolSize(info);
        return
            currentPoolSize > poolSizeForProvisionalDefault
                ? currentPoolSize - poolSizeForProvisionalDefault
                : 0;
    }

    function _maxWithdrawable(uint256 exchangeRate)
        internal
        view
        returns (uint256 tokensAmount, uint256 currencyAmount)
    {
        currencyAmount = _availableToProviders(_info);
        if (!debtClaimed) {
            uint256 availableProvisionalDefault = _availableProvisionalDefault(
                _info
            );
            if (availableProvisionalDefault < currencyAmount) {
                currencyAmount = availableProvisionalDefault;
            }
        }
        tokensAmount = currencyAmount.divDecimal(exchangeRate);

        if (balanceOf(msg.sender) < tokensAmount) {
            tokensAmount = balanceOf(msg.sender);
            currencyAmount = tokensAmount.mulDecimal(exchangeRate);
        }
    }

    function _storedExchangeRate() internal view returns (uint256) {
        if (totalSupply() == 0) {
            return Decimal.ONE;
        } else if (debtClaimed) {
            return cash().divDecimal(totalSupply());
        } else {
            return
                (_availableToProviders(_info) + _info.borrows).divDecimal(
                    totalSupply()
                );
        }
    }

    function _entranceOfProvisionalDefault(uint256 interestRate)
        internal
        view
        returns (uint256)
    {
        if (_info.enteredProvisionalDefault != 0) {
            return _info.enteredProvisionalDefault;
        }
        if (_info.borrows == 0 || interestRate == 0) {
            return 0;
        }

        uint256 numerator = _poolSize(_info).mulDecimal(
            provisionalDefaultUtilization
        ) - _info.borrows;
        uint256 denominator = Decimal.ONE +
            provisionalDefaultUtilization.mulDecimal(
                reserveFactor + insuranceFactor
            );
        uint256 interestForProvisionalDefault = numerator.divDecimal(
            denominator
        );

        uint256 interestPerSec = _info.borrows * interestRate;
        uint256 timeDelta = (interestForProvisionalDefault *
            Decimal.ONE +
            interestPerSec -
            1) / interestPerSec;
        uint256 entrance = _info.lastAccrual + timeDelta;
        return entrance <= block.timestamp ? entrance : 0;
    }

    function _accrueInterestVirtual()
        internal
        view
        returns (BorrowInfo memory)
    {
        BorrowInfo memory newInfo = _info;

        if (
            block.timestamp == newInfo.lastAccrual ||
            newInfo.state == State.Default ||
            newInfo.state == State.Closed
        ) {
            return newInfo;
        }

        uint256 interestRate = interestRateModel.getBorrowRate(
            cash(),
            newInfo.borrows,
            newInfo.reserves + newInfo.insurance + _interest(newInfo)
        );

        newInfo.lastAccrual = block.timestamp;
        newInfo.enteredProvisionalDefault = _entranceOfProvisionalDefault(
            interestRate
        );
        if (
            newInfo.enteredProvisionalDefault != 0 &&
            newInfo.enteredProvisionalDefault + warningGracePeriod <
            newInfo.lastAccrual
        ) {
            newInfo.lastAccrual =
                newInfo.enteredProvisionalDefault +
                warningGracePeriod;
        }

        uint256 interestDelta = newInfo.borrows.mulDecimal(
            interestRate * (newInfo.lastAccrual - _info.lastAccrual)
        );
        uint256 reservesDelta = interestDelta.mulDecimal(reserveFactor);
        uint256 insuranceDelta = interestDelta.mulDecimal(insuranceFactor);

        if (
            newInfo.borrows + interestDelta + reservesDelta + insuranceDelta >
            _poolSize(newInfo)
        ) {
            interestDelta = (_poolSize(newInfo) - newInfo.borrows).divDecimal(
                Decimal.ONE + reserveFactor + insuranceFactor
            );
            uint256 interestPerSec = newInfo.borrows.mulDecimal(interestRate);
            if (interestPerSec > 0) {
                newInfo.lastAccrual =
                    _info.lastAccrual +
                    (interestDelta + interestPerSec - 1) /
                    interestPerSec;
            }

            reservesDelta = interestDelta.mulDecimal(reserveFactor);
            insuranceDelta = interestDelta.mulDecimal(insuranceFactor);
            newInfo.state = State.Default;
        }

        newInfo.borrows += interestDelta;
        newInfo.reserves += reservesDelta;
        newInfo.insurance += insuranceDelta;

        return newInfo;
    }


    modifier onlyActiveAccrual() {
        _accrueInterest();
        State currentState = _state(_info);
        require(
            currentState == State.Active ||
                currentState == State.Warning ||
                currentState == State.ProvisionalDefault,
            "PIA"
        );
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "OM");
        _;
    }

    modifier onlyGovernor() {
        require(msg.sender == factory.owner(), "OG");
        _;
    }

    modifier onlyAuction() {
        require(msg.sender == factory.auction(), "OA");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == address(factory), "OF");
        _;
    }
}// MIT
pragma solidity 0.8.9;


abstract contract PoolMetadata is PoolBase {
    using Decimal for uint256;

    function decimals() public view virtual override returns (uint8) {
        return IERC20MetadataUpgradeable(address(currency)).decimals();
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function state() external view returns (State) {
        return _state(_accrueInterestVirtual());
    }

    function lastAccrual() external view returns (uint256) {
        return _accrueInterestVirtual().lastAccrual;
    }

    function interest() external view returns (uint256) {
        return _interest(_accrueInterestVirtual());
    }

    function availableToWithdraw() external view returns (uint256) {
        if (debtClaimed) {
            return cash();
        } else {
            BorrowInfo memory info = _accrueInterestVirtual();
            return
                MathUpgradeable.min(
                    _availableToProviders(info),
                    _availableProvisionalDefault(info)
                );
        }
    }

    function availableToBorrow() external view returns (uint256) {
        return _availableToBorrow(_accrueInterestVirtual());
    }

    function poolSize() external view returns (uint256) {
        return _poolSize(_accrueInterestVirtual());
    }

    function principal() external view returns (uint256) {
        return _info.principal;
    }

    function borrows() external view returns (uint256) {
        return _accrueInterestVirtual().borrows;
    }

    function reserves() public view returns (uint256) {
        return _accrueInterestVirtual().reserves;
    }

    function insurance() external view returns (uint256) {
        return _accrueInterestVirtual().insurance;
    }

    function enteredZeroUtilization() external view returns (uint256) {
        return _info.enteredZeroUtilization;
    }

    function enteredProvisionalDefault() external view returns (uint256) {
        return _accrueInterestVirtual().enteredProvisionalDefault;
    }

    function getCurrentExchangeRate() external view returns (uint256) {
        if (totalSupply() == 0) {
            return Decimal.ONE;
        } else if (debtClaimed) {
            return cash().divDecimal(totalSupply());
        } else {
            BorrowInfo memory info = _accrueInterestVirtual();
            return
                (_availableToProviders(info) + info.borrows).divDecimal(
                    totalSupply()
                );
        }
    }

    function getBorrowRate() public view returns (uint256) {
        BorrowInfo memory info = _accrueInterestVirtual();
        return
            interestRateModel.getBorrowRate(
                currency.balanceOf(address(this)),
                info.borrows,
                info.reserves + info.insurance + (info.borrows - info.principal)
            );
    }

    function getSupplyRate() external view returns (uint256) {
        BorrowInfo memory info = _accrueInterestVirtual();
        return
            interestRateModel.getSupplyRate(
                currency.balanceOf(address(this)),
                info.borrows,
                info.reserves +
                    info.insurance +
                    (info.borrows - info.principal),
                reserveFactor + insuranceFactor
            );
    }

    function getUtilizationRate() external view returns (uint256) {
        BorrowInfo memory info = _accrueInterestVirtual();
        return
            interestRateModel.utilizationRate(
                cash(),
                info.borrows,
                info.insurance + info.reserves + _interest(info)
            );
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCastUpgradeable {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT
pragma solidity 0.8.9;


abstract contract PoolRewards is PoolBase {
    using SafeCastUpgradeable for uint256;
    using SafeCastUpgradeable for int256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 public rewardPerBlock;

    uint256 internal constant REWARD_MAGNITUDE = 2**128;

    uint256 internal _lastRewardDistribution;

    uint256 internal _magnifiedRewardPerShare;

    mapping(address => int256) internal _magnifiedRewardCorrections;

    mapping(address => uint256) internal _withdrawals;


    event RewardWithdrawn(address indexed account, uint256 amount);

    event RewardPerBlockSet(uint256 newRewardPerBlock);


    function withdrawReward(address account)
        external
        onlyFactory
        returns (uint256)
    {
        _accrueInterest();
        _distributeReward();

        uint256 withdrawable = withdrawableRewardOf(account);
        if (withdrawable > 0) {
            _withdrawals[account] += withdrawable;
            emit RewardWithdrawn(account, withdrawable);
        }

        return withdrawable;
    }

    function setRewardPerBlock(uint256 rewardPerBlock_) external onlyFactory {
        _accrueInterest();
        _distributeReward();
        if (_lastRewardDistribution == 0) {
            _lastRewardDistribution = _info.lastAccrual;
        }
        rewardPerBlock = rewardPerBlock_;

        emit RewardPerBlockSet(rewardPerBlock_);
    }


    function accumulativeRewardOf(address account)
        public
        view
        returns (uint256)
    {
        BorrowInfo memory info = _accrueInterestVirtual();
        uint256 currentRewardPerShare = _magnifiedRewardPerShare;
        if (
            _lastRewardDistribution != 0 &&
            info.lastAccrual > _lastRewardDistribution &&
            totalSupply() > 0
        ) {
            uint256 period = info.lastAccrual - _lastRewardDistribution;
            currentRewardPerShare +=
                (REWARD_MAGNITUDE * period * rewardPerBlock) /
                totalSupply();
        }

        return
            ((balanceOf(account) * currentRewardPerShare).toInt256() +
                _magnifiedRewardCorrections[account]).toUint256() /
            REWARD_MAGNITUDE;
    }

    function withdrawnRewardOf(address account) public view returns (uint256) {
        return _withdrawals[account];
    }

    function withdrawableRewardOf(address account)
        public
        view
        returns (uint256)
    {
        return accumulativeRewardOf(account) - withdrawnRewardOf(account);
    }


    function _distributeReward() internal {
        if (
            rewardPerBlock > 0 &&
            _lastRewardDistribution != 0 &&
            _info.lastAccrual > _lastRewardDistribution &&
            totalSupply() > 0
        ) {
            uint256 period = _info.lastAccrual - _lastRewardDistribution;
            _magnifiedRewardPerShare +=
                (REWARD_MAGNITUDE * period * rewardPerBlock) /
                totalSupply();
        }
        _lastRewardDistribution = _info.lastAccrual;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        _distributeReward();

        super._mint(account, amount);
        _magnifiedRewardCorrections[account] -= (_magnifiedRewardPerShare *
            amount).toInt256();
    }

    function _burn(address account, uint256 amount) internal virtual override {
        _distributeReward();

        super._burn(account, amount);
        _magnifiedRewardCorrections[account] += (_magnifiedRewardPerShare *
            amount).toInt256();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        _accrueInterest();
        _distributeReward();

        super._transfer(from, to, amount);
        _magnifiedRewardCorrections[from] += (_magnifiedRewardPerShare * amount)
            .toInt256();
        _magnifiedRewardCorrections[to] -= (_magnifiedRewardPerShare * amount)
            .toInt256();
    }
}// MIT
pragma solidity 0.8.9;


abstract contract PoolConfiguration is PoolBase {
    function setManager(address manager_) external onlyFactory {
        require(manager_ != address(0), "AIZ");
        manager = manager_;
    }

    function setInterestRateModel(IInterestRateModel interestRateModel_)
        external
        onlyGovernor
    {
        require(address(interestRateModel_) != address(0), "AIZ");

        _accrueInterest();
        interestRateModel = interestRateModel_;
    }

    function setReserveFactor(uint256 reserveFactor_) external onlyGovernor {
        require(reserveFactor + insuranceFactor <= Decimal.ONE, "GTO");
        reserveFactor = reserveFactor_;
    }

    function setInsuranceFactor(uint256 insuranceFactor_)
        external
        onlyGovernor
    {
        require(reserveFactor + insuranceFactor <= Decimal.ONE, "GTO");
        insuranceFactor = insuranceFactor_;
    }

    function setWarningUtilization(uint256 warningUtilization_)
        external
        onlyGovernor
    {
        require(warningUtilization <= Decimal.ONE, "GTO");

        _accrueInterest();
        warningUtilization = warningUtilization_;
        _checkUtilization();
    }

    function setProvisionalDefaultUtilization(
        uint256 provisionalDefaultUtilization_
    ) external onlyGovernor {
        require(provisionalDefaultUtilization_ <= Decimal.ONE, "GTO");

        _accrueInterest();
        provisionalDefaultUtilization = provisionalDefaultUtilization_;
        _checkUtilization();
    }

    function setWarningGracePeriod(uint256 warningGracePeriod_)
        external
        onlyGovernor
    {
        _accrueInterest();
        warningGracePeriod = warningGracePeriod_;
        _checkUtilization();
    }

    function setMaxInactivePeriod(uint256 maxInactivePeriod_)
        external
        onlyGovernor
    {
        _accrueInterest();
        maxInactivePeriod = maxInactivePeriod_;
    }

    function setPeriodToStartAuction(uint256 periodToStartAuction_)
        external
        onlyGovernor
    {
        periodToStartAuction = periodToStartAuction_;
    }

    function setSymbol(string memory symbol_) external onlyGovernor {
        _symbol = symbol_;
    }
}// MIT
pragma solidity 0.8.9;


contract PoolMaster is PoolRewards, PoolConfiguration, PoolMetadata {

    string public constant VERSION = "1.1.0";


    function initialize(address manager_, IERC20Upgradeable currency_)
        external
        initializer
    {

        __PoolBaseInfo_init(manager_, currency_);
    }


    function _mint(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, PoolRewards)
    {

        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, PoolRewards)
    {

        super._burn(account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, PoolRewards) {

        super._transfer(from, to, amount);
    }

    function decimals()
        public
        view
        override(ERC20Upgradeable, PoolMetadata)
        returns (uint8)
    {

        return super.decimals();
    }

    function symbol()
        public
        view
        override(ERC20Upgradeable, PoolMetadata)
        returns (string memory)
    {

        return super.symbol();
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20PermitUpgradeable {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}