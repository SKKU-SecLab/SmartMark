

pragma solidity ^0.5.0;

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
}


pragma solidity >=0.4.24 <0.7.0;


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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.11;

contract InitializableERC20Detailed is IERC20 {

    uint256[100] private _____gap;

    string public _name;
    string public _symbol;
    uint8 public _decimals;

    function _initialize(
        string memory nameArg,
        string memory symbolArg,
        uint8 decimalsArg
    ) internal {

        _name = nameArg;
        _symbol = symbolArg;
        _decimals = decimalsArg;
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
}


pragma solidity 0.5.11;


library StableMath {

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;


    function scaleBy(uint256 x, int8 adjustment)
        internal
        pure
        returns (uint256)
    {

        if (adjustment > 0) {
            x = x.mul(10**uint256(adjustment));
        } else if (adjustment < 0) {
            x = x.div(10**uint256(adjustment * -1));
        }
        return x;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

        uint256 z = x.mul(y);
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }
}


pragma solidity 0.5.11;

contract Governable {

    bytes32
        private constant governorPosition = 0x7bea13895fa79d2831e0a9e28edede30099005a50d652d8957cf8a607ee6ca4a;

    bytes32
        private constant pendingGovernorPosition = 0x44c4d30b2eaad5130ad70c3ba6972730566f3e6359ab83e800d905c61b1c51db;

    bytes32
        private constant reentryStatusPosition = 0x53bf423e48ed90e97d02ab0ebab13b2a235a6bfbe9c321847d5c175333ac4535;

    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    event PendingGovernorshipTransfer(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    event GovernorshipTransferred(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    constructor() internal {
        _setGovernor(msg.sender);
        emit GovernorshipTransferred(address(0), _governor());
    }

    function governor() public view returns (address) {

        return _governor();
    }

    function _governor() internal view returns (address governorOut) {

        bytes32 position = governorPosition;
        assembly {
            governorOut := sload(position)
        }
    }

    function _pendingGovernor()
        internal
        view
        returns (address pendingGovernor)
    {

        bytes32 position = pendingGovernorPosition;
        assembly {
            pendingGovernor := sload(position)
        }
    }

    modifier onlyGovernor() {

        require(isGovernor(), "Caller is not the Governor");
        _;
    }

    function isGovernor() public view returns (bool) {

        return msg.sender == _governor();
    }

    function _setGovernor(address newGovernor) internal {

        bytes32 position = governorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    modifier nonReentrant() {

        bytes32 position = reentryStatusPosition;
        uint256 _reentry_status;
        assembly {
            _reentry_status := sload(position)
        }

        require(_reentry_status != _ENTERED, "Reentrant call");

        assembly {
            sstore(position, _ENTERED)
        }

        _;

        assembly {
            sstore(position, _NOT_ENTERED)
        }
    }

    function _setPendingGovernor(address newGovernor) internal {

        bytes32 position = pendingGovernorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    function transferGovernance(address _newGovernor) external onlyGovernor {

        _setPendingGovernor(_newGovernor);
        emit PendingGovernorshipTransfer(_governor(), _newGovernor);
    }

    function claimGovernance() external {

        require(
            msg.sender == _pendingGovernor(),
            "Only the pending Governor can complete the claim"
        );
        _changeGovernor(msg.sender);
    }

    function _changeGovernor(address _newGovernor) internal {

        require(_newGovernor != address(0), "New Governor is address(0)");
        emit GovernorshipTransferred(_governor(), _newGovernor);
        _setGovernor(_newGovernor);
    }
}


pragma solidity 0.5.11;







contract OUSD is Initializable, InitializableERC20Detailed, Governable {

    using SafeMath for uint256;
    using StableMath for uint256;

    event TotalSupplyUpdated(
        uint256 totalSupply,
        uint256 rebasingCredits,
        uint256 rebasingCreditsPerToken
    );

    enum RebaseOptions { NotSet, OptOut, OptIn }

    uint256 private constant MAX_SUPPLY = ~uint128(0); // (2^128) - 1
    uint256 public _totalSupply;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public vaultAddress = address(0);
    mapping(address => uint256) private _creditBalances;
    uint256 public rebasingCredits;
    uint256 public rebasingCreditsPerToken;
    uint256 public nonRebasingSupply;
    mapping(address => uint256) public nonRebasingCreditsPerToken;
    mapping(address => RebaseOptions) public rebaseState;

    function initialize(
        string calldata _nameArg,
        string calldata _symbolArg,
        address _vaultAddress
    ) external onlyGovernor initializer {

        InitializableERC20Detailed._initialize(_nameArg, _symbolArg, 18);
        rebasingCreditsPerToken = 1e18;
        vaultAddress = _vaultAddress;
    }

    modifier onlyVault() {

        require(vaultAddress == msg.sender, "Caller is not the Vault");
        _;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {

        if (_creditBalances[_account] == 0) return 0;
        return
            _creditBalances[_account].divPrecisely(_creditsPerToken(_account));
    }

    function creditsBalanceOf(address _account)
        public
        view
        returns (uint256, uint256)
    {

        return (_creditBalances[_account], _creditsPerToken(_account));
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0), "Transfer to zero address");
        require(
            _value <= balanceOf(msg.sender),
            "Transfer greater than balance"
        );

        _executeTransfer(msg.sender, _to, _value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {

        require(_to != address(0), "Transfer to zero address");
        require(_value <= balanceOf(_from), "Transfer greater than balance");

        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(
            _value
        );

        _executeTransfer(_from, _to, _value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function _executeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {

        bool isNonRebasingTo = _isNonRebasingAccount(_to);
        bool isNonRebasingFrom = _isNonRebasingAccount(_from);

        uint256 creditsCredited = _value.mulTruncate(_creditsPerToken(_to));
        uint256 creditsDeducted = _value.mulTruncate(_creditsPerToken(_from));

        _creditBalances[_from] = _creditBalances[_from].sub(
            creditsDeducted,
            "Transfer amount exceeds balance"
        );
        _creditBalances[_to] = _creditBalances[_to].add(creditsCredited);

        if (isNonRebasingTo && !isNonRebasingFrom) {
            nonRebasingSupply = nonRebasingSupply.add(_value);
            rebasingCredits = rebasingCredits.sub(creditsDeducted);
        } else if (!isNonRebasingTo && isNonRebasingFrom) {
            nonRebasingSupply = nonRebasingSupply.sub(_value);
            rebasingCredits = rebasingCredits.add(creditsCredited);
        }
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {

        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {

        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender]
            .add(_addedValue);
        emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {

        uint256 oldValue = _allowances[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            _allowances[msg.sender][_spender] = 0;
        } else {
            _allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
        return true;
    }

    function mint(address _account, uint256 _amount) external onlyVault {

        return _mint(_account, _amount);
    }

    function _mint(address _account, uint256 _amount) internal nonReentrant {

        require(_account != address(0), "Mint to the zero address");

        bool isNonRebasingAccount = _isNonRebasingAccount(_account);

        uint256 creditAmount = _amount.mulTruncate(_creditsPerToken(_account));
        _creditBalances[_account] = _creditBalances[_account].add(creditAmount);

        if (isNonRebasingAccount) {
            nonRebasingSupply = nonRebasingSupply.add(_amount);
        } else {
            rebasingCredits = rebasingCredits.add(creditAmount);
        }

        _totalSupply = _totalSupply.add(_amount);

        require(_totalSupply < MAX_SUPPLY, "Max supply");

        emit Transfer(address(0), _account, _amount);
    }

    function burn(address account, uint256 amount) external onlyVault {

        return _burn(account, amount);
    }

    function _burn(address _account, uint256 _amount) internal nonReentrant {

        require(_account != address(0), "Burn from the zero address");

        bool isNonRebasingAccount = _isNonRebasingAccount(_account);
        uint256 creditAmount = _amount.mulTruncate(_creditsPerToken(_account));
        uint256 currentCredits = _creditBalances[_account];

        if (
            currentCredits == creditAmount || currentCredits - 1 == creditAmount
        ) {
            _creditBalances[_account] = 0;
        } else if (currentCredits > creditAmount) {
            _creditBalances[_account] = _creditBalances[_account].sub(
                creditAmount
            );
        } else {
            revert("Remove exceeds balance");
        }

        if (isNonRebasingAccount) {
            nonRebasingSupply = nonRebasingSupply.sub(_amount);
        } else {
            rebasingCredits = rebasingCredits.sub(creditAmount);
        }

        _totalSupply = _totalSupply.sub(_amount);

        emit Transfer(_account, address(0), _amount);
    }

    function _creditsPerToken(address _account)
        internal
        view
        returns (uint256)
    {

        if (nonRebasingCreditsPerToken[_account] != 0) {
            return nonRebasingCreditsPerToken[_account];
        } else {
            return rebasingCreditsPerToken;
        }
    }

    function _isNonRebasingAccount(address _account) internal returns (bool) {

        if (Address.isContract(_account)) {
            if (rebaseState[_account] == RebaseOptions.OptIn) {
                return false;
            }
            _ensureRebasingMigration(_account);
            return true;
        } else {
            return rebaseState[_account] == RebaseOptions.OptOut;
        }
    }

    function _ensureRebasingMigration(address _account) internal {

        if (nonRebasingCreditsPerToken[_account] == 0) {
            nonRebasingCreditsPerToken[_account] = rebasingCreditsPerToken;
            nonRebasingSupply = nonRebasingSupply.add(balanceOf(_account));
            rebasingCredits = rebasingCredits.sub(_creditBalances[_account]);
        }
    }

    function rebaseOptIn() public nonReentrant {

        require(_isNonRebasingAccount(msg.sender), "Account has not opted out");

        uint256 newCreditBalance = _creditBalances[msg.sender]
            .mul(rebasingCreditsPerToken)
            .div(_creditsPerToken(msg.sender));

        nonRebasingSupply = nonRebasingSupply.sub(balanceOf(msg.sender));

        _creditBalances[msg.sender] = newCreditBalance;

        rebasingCredits = rebasingCredits.add(_creditBalances[msg.sender]);

        rebaseState[msg.sender] = RebaseOptions.OptIn;

        delete nonRebasingCreditsPerToken[msg.sender];
    }

    function rebaseOptOut() public nonReentrant {

        require(!_isNonRebasingAccount(msg.sender), "Account has not opted in");

        nonRebasingSupply = nonRebasingSupply.add(balanceOf(msg.sender));
        nonRebasingCreditsPerToken[msg.sender] = rebasingCreditsPerToken;

        rebasingCredits = rebasingCredits.sub(_creditBalances[msg.sender]);

        rebaseState[msg.sender] = RebaseOptions.OptOut;
    }

    function changeSupply(uint256 _newTotalSupply)
        external
        onlyVault
        nonReentrant
    {

        require(_totalSupply > 0, "Cannot increase 0 supply");

        if (_totalSupply == _newTotalSupply) {
            emit TotalSupplyUpdated(
                _totalSupply,
                rebasingCredits,
                rebasingCreditsPerToken
            );
            return;
        }

        _totalSupply = _newTotalSupply > MAX_SUPPLY
            ? MAX_SUPPLY
            : _newTotalSupply;

        rebasingCreditsPerToken = rebasingCredits.divPrecisely(
            _totalSupply.sub(nonRebasingSupply)
        );

        require(rebasingCreditsPerToken > 0, "Invalid change in supply");

        _totalSupply = rebasingCredits
            .divPrecisely(rebasingCreditsPerToken)
            .add(nonRebasingSupply);

        emit TotalSupplyUpdated(
            _totalSupply,
            rebasingCredits,
            rebasingCreditsPerToken
        );
    }
}


pragma solidity 0.5.11;

contract OUSDReset is OUSD {

    function reset() external onlyGovernor {

        _name = "Origin Dollar";
        _symbol = "OUSD";
        _decimals = 18;
        rebasingCreditsPerToken = 1e18;
    }

    function setVaultAddress(address _vaultAddress) external onlyGovernor {

        vaultAddress = _vaultAddress;
    }
}