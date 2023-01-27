
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT
pragma solidity 0.7.6;

abstract contract OwnableUpgradeable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init(address owner_) internal initializer {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.7.6;

interface IStrategy2 {

    function deposit(uint256) external;


    function withdraw(uint256) external returns (uint256);


    function refund(uint256) external;


    function balanceOf(address) external view returns (uint256);


    function pool() external view returns (uint256);


    function getPseudoPool() external view returns (uint256);


    function invest(uint256) external;

}// MIT
pragma solidity 0.7.6;



contract DAOVault is Initializable, ERC20Upgradeable, OwnableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    bytes32 public vaultName;
    IERC20Upgradeable public token;
    uint256 private _fees;
    IStrategy2 public strategy;
    address public pendingStrategy;

    bool public canSetPendingStrategy;
    uint256 public unlockTime;

    uint256[] public networkFeeTier2;
    uint256 public customNetworkFeeTier;
    uint256[] public networkFeePercentage;
    uint256 public customNetworkFeePercentage;

    address public treasuryWallet;
    address public communityWallet;
    address public admin;

    event SetNetworkFeeTier2(
        uint256[] oldNetworkFeeTier2,
        uint256[] newNetworkFeeTier2
    );
    event SetNetworkFeePercentage(
        uint256[] oldNetworkFeePercentage,
        uint256[] newNetworkFeePercentage
    );
    event SetCustomNetworkFeeTier(
        uint256 indexed oldCustomNetworkFeeTier,
        uint256 indexed newCustomNetworkFeeTier
    );
    event SetCustomNetworkFeePercentage(
        uint256 oldCustomNetworkFeePercentage,
        uint256 newCustomNetworkFeePercentage
    );
    event SetTreasuryWallet(
        address indexed oldTreasuryWallet,
        address indexed newTreasuryWallet
    );
    event SetCommunityWallet(
        address indexed oldCommunityWallet,
        address indexed newCommunityWallet
    );
    event MigrateFunds(
        address indexed fromStrategy,
        address indexed toStrategy,
        uint256 amount
    );

    modifier onlyAdmin {

        require(msg.sender == address(admin), "Only admin");
        _;
    }

    modifier onlyEOA {

        require(msg.sender == tx.origin, "Only EOA");
        _;
    }

    function init(
        bytes32 _vaultName,
        address _token,
        address _strategy,
        address _owner
    ) external initializer {

        __ERC20_init("DAO Vault Harvest", "daoHAR");
        __Ownable_init(_owner);

        vaultName = _vaultName;
        token = IERC20Upgradeable(_token);
        strategy = IStrategy2(_strategy);
        admin = _owner;

        canSetPendingStrategy = true;
        uint8 decimals = ERC20Upgradeable(_token).decimals();
        networkFeeTier2 = [50000 * 10**decimals + 1, 100000 * 10**decimals];
        customNetworkFeeTier = 1000000 * 10**decimals;
        networkFeePercentage = [100, 75, 50];
        customNetworkFeePercentage = 25;
        treasuryWallet = 0x59E83877bD248cBFe392dbB5A8a29959bcb48592;
        communityWallet = 0xdd6c35aFF646B2fB7d8A8955Ccbe0994409348d0;

        token.safeApprove(address(strategy), type(uint256).max);
    }

    function deposit(uint256 _amount) external onlyEOA {

        require(_amount > 0, "Amount must > 0");

        uint256 _pool = strategy.getPseudoPool().add(token.balanceOf(address(this))).sub(_fees);
        token.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _networkFeePercentage;
        if (_amount < networkFeeTier2[0]) {
            _networkFeePercentage = networkFeePercentage[0];
        } else if (_amount <= networkFeeTier2[1]) {
            _networkFeePercentage = networkFeePercentage[1];
        } else if (_amount < customNetworkFeeTier) {
            _networkFeePercentage = networkFeePercentage[2];
        } else {
            _networkFeePercentage = customNetworkFeePercentage;
        }
        uint256 _fee = _amount.mul(_networkFeePercentage).div(10000 /*DENOMINATOR*/);
        _amount = _amount.sub(_fee);
        _fees = _fees.add(_fee);

        uint256 _shares = totalSupply() == 0
            ? _amount
            : _amount.mul(totalSupply()).div(_pool);
        _mint(msg.sender, _shares);
    }

    function withdraw(uint256 _shares) external onlyEOA {

        uint256 _balanceOfVault = (token.balanceOf(address(this))).sub(_fees);
        uint256 _withdrawAmt = (_balanceOfVault.add(strategy.pool()).mul(_shares).div(totalSupply()));

        require(0 < _withdrawAmt, "Amount must > 0");

        _burn(msg.sender, _shares);

        if (_withdrawAmt > _balanceOfVault) {
            uint256 _diff = strategy.withdraw(_withdrawAmt.sub(_balanceOfVault));
            token.safeTransfer(msg.sender, _balanceOfVault.add(_diff));
        } else {
            token.safeTransfer(msg.sender, _withdrawAmt);
        }
    }

    function refund() external onlyEOA {

        require(balanceOf(msg.sender) > 0, "No balance to refund");

        uint256 _shares = balanceOf(msg.sender);
        uint256 _balanceOfVault = (token.balanceOf(address(this))).sub(_fees);
        uint256 _refundAmt = (_balanceOfVault.add(strategy.pool()).mul(_shares).div(totalSupply()));

        _burn(msg.sender, _shares);

        if (_balanceOfVault < _refundAmt) {
            strategy.refund(_refundAmt.sub(_balanceOfVault));
            token.safeTransfer(tx.origin, _balanceOfVault);
        } else {
            token.safeTransfer(tx.origin, _refundAmt);
        }
    }

    function invest() external onlyAdmin {

        if (_fees > 0) {
            uint256 _treasuryFee = _fees.div(2);
            token.safeTransfer(treasuryWallet, _treasuryFee);
            token.safeTransfer(communityWallet, _fees.sub(_treasuryFee));
            _fees = 0;
        }

        uint256 _toInvest = token.balanceOf(address(this));
        strategy.invest(_toInvest);
    }

    function setNetworkFeeTier2(uint256[] calldata _networkFeeTier2)
        external
        onlyOwner
    {

        require(_networkFeeTier2[0] != 0, "Minimun amount cannot be 0");
        require(
            _networkFeeTier2[1] > _networkFeeTier2[0],
            "Maximun amount must greater than minimun amount"
        );
        uint256[] memory oldNetworkFeeTier2 = networkFeeTier2;
        networkFeeTier2 = _networkFeeTier2;
        emit SetNetworkFeeTier2(oldNetworkFeeTier2, _networkFeeTier2);
    }

    function setCustomNetworkFeeTier(uint256 _customNetworkFeeTier)
        external
        onlyOwner
    {

        require(
            _customNetworkFeeTier > networkFeeTier2[1],
            "Custom network fee tier must greater than tier 2"
        );

        uint256 oldCustomNetworkFeeTier = customNetworkFeeTier;
        customNetworkFeeTier = _customNetworkFeeTier;
        emit SetCustomNetworkFeeTier(
            oldCustomNetworkFeeTier,
            _customNetworkFeeTier
        );
    }

    function setNetworkFeePercentage(uint256[] calldata _networkFeePercentage)
        external
        onlyOwner
    {

        require(
            _networkFeePercentage[0] < 3000 &&
                _networkFeePercentage[1] < 3000 &&
                _networkFeePercentage[2] < 3000,
            "Network fee percentage cannot be more than 30%"
        );
        uint256[] memory oldNetworkFeePercentage = networkFeePercentage;
        networkFeePercentage = _networkFeePercentage;
        emit SetNetworkFeePercentage(
            oldNetworkFeePercentage,
            _networkFeePercentage
        );
    }

    function setCustomNetworkFeePercentage(uint256 _percentage)
        public
        onlyOwner
    {

        require(
            _percentage < networkFeePercentage[2],
            "Custom network fee percentage cannot be more than tier 2"
        );

        uint256 oldCustomNetworkFeePercentage = customNetworkFeePercentage;
        customNetworkFeePercentage = _percentage;
        emit SetCustomNetworkFeePercentage(
            oldCustomNetworkFeePercentage,
            _percentage
        );
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyOwner {

        address oldTreasuryWallet = treasuryWallet;
        treasuryWallet = _treasuryWallet;
        emit SetTreasuryWallet(oldTreasuryWallet, _treasuryWallet);
    }

    function setCommunityWallet(address _communityWallet) external onlyOwner {

        address oldCommunityWallet = communityWallet;
        communityWallet = _communityWallet;
        emit SetCommunityWallet(oldCommunityWallet, _communityWallet);
    }

    function setAdmin(address _admin) external onlyOwner {

        admin = _admin;
    }

    function setPendingStrategy(address _pendingStrategy) external onlyOwner {

        require(canSetPendingStrategy, "Cannot set pending strategy now");
        require(_pendingStrategy.isContract(), "New strategy is not contract");

        pendingStrategy = _pendingStrategy;
    }

    function unlockMigrateFunds() external onlyOwner {

        unlockTime = block.timestamp.add(2 days /*LOCKTIME*/);
        canSetPendingStrategy = false;
    }

    function migrateFunds() external onlyOwner {

        require(
            unlockTime <= block.timestamp &&
                unlockTime.add(1 days) >= block.timestamp,
            "Function locked"
        );
        require(
            token.balanceOf(address(strategy)) > 0,
            "No balance to migrate"
        );
        require(pendingStrategy != address(0), "No pendingStrategy");
        uint256 _amount = token.balanceOf(address(strategy));

        token.safeTransferFrom(address(strategy), pendingStrategy, _amount);

        address oldStrategy = address(strategy);
        strategy = IStrategy2(pendingStrategy);
        pendingStrategy = address(0);
        canSetPendingStrategy = true;

        token.safeApprove(address(oldStrategy), 0);
        token.safeApprove(address(strategy), type(uint256).max);

        unlockTime = 0; // Lock back this function
        emit MigrateFunds(oldStrategy, address(strategy), _amount);
    }
}