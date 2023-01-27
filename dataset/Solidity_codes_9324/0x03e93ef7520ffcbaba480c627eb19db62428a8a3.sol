

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


pragma solidity ^0.5.0;



contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


pragma solidity ^0.5.0;





contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract ERC20Burnable is Initializable, Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
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




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;




contract MinterRole is Initializable, Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {

        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract PauserRole is Initializable, Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {

        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract Pausable is Initializable, Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {

        PauserRole.initialize(sender);

        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.0;




contract WhitelistAdminRole is Initializable, Context {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    function initialize(address sender) public initializer {

        if (!isWhitelistAdmin(sender)) {
            _addWhitelistAdmin(sender);
        }
    }

    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;





contract WhitelistedRole is Initializable, Context, WhitelistAdminRole {

    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {

        require(isWhitelisted(_msgSender()), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function initialize(address sender) public initializer {

        WhitelistAdminRole.initialize(sender);
    }

    function isWhitelisted(address account) public view returns (bool) {

        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {

        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {

        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {

        _removeWhitelisted(_msgSender());
    }

    function _addWhitelisted(address account) internal {

        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {

        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.6;




contract InvictusWhitelist is Initializable, Ownable, WhitelistedRole {


    function initialize() public initializer {

        Ownable.initialize(msg.sender);
        WhitelistedRole.initialize(msg.sender);
    }

    function verifyParticipant(address participant) public onlyWhitelistAdmin {

        if (!isWhitelisted(participant)) {
            addWhitelisted(participant);
        }
    }

    function removeWhitelistAdmin(address account) public onlyOwner {

        require(account != msg.sender, "Use renounceWhitelistAdmin");
        _removeWhitelistAdmin(account);
    }
}


pragma solidity ^0.5.6;












contract InvictusToken is Initializable, ERC20Detailed, ERC20Burnable, Ownable, Pausable, MinterRole {


    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    mapping (address => uint256) public pendingWithdrawals;
    address[] public withdrawals;

    uint256 private minTokenRedemption;
    uint256 private maxWithdrawalsPerTx;
    Price public price;

    address public whitelistContract;
    address public stableContract;

    struct Price {
        uint256 numerator;
        uint256 denominator;
    }

    event PriceUpdate(uint256 numerator, uint256 denominator);
    event AddLiquidity(address indexed account, address indexed stableAddress, uint256 value);
    event RemoveLiquidity(address indexed account, uint256 value);
    event WithdrawRequest(address indexed participant, uint256 amountTokens);
    event Withdraw(address indexed participant, uint256 amountTokens, uint256 etherAmount);
    event WithdrawInvalidAddress(address indexed participant, uint256 amountTokens);
    event WithdrawFailed(address indexed participant, uint256 amountTokens);
    event TokensClaimed(address indexed token, uint256 balance);

    function setMaxWithdrawalsPerTx(uint256 newMaxWithdrawalsPerTx) external onlyOwner {

        require(newMaxWithdrawalsPerTx > 0, "Must be greater than 0");
        maxWithdrawalsPerTx = newMaxWithdrawalsPerTx;
    }

    function setMinimumTokenRedemption(uint256 newMinTokenRedemption) external onlyOwner {

        require(newMinTokenRedemption > 0, "Minimum must be greater than 0");
        minTokenRedemption = newMinTokenRedemption;
    }

    function updatePrice(uint256 newNumerator) external onlyMinter {

        require(newNumerator > 0, "Must be positive value");

        price.numerator = newNumerator;

        processWithdrawals();
        emit PriceUpdate(price.numerator, price.denominator);
    }

    function updatePriceDenominator(uint256 newDenominator) external onlyMinter {

        require(newDenominator > 0, "Must be positive value");

        price.denominator = newDenominator;
    }

    function requestWithdrawal(uint256 amountTokensToWithdraw) external whenNotPaused
        onlyWhitelisted {


        address participant = msg.sender;
        require(balanceOf(participant) >= amountTokensToWithdraw,
            "Cannot withdraw more than balance held");
        require(amountTokensToWithdraw >= minTokenRedemption, "Too few tokens");

        burn(amountTokensToWithdraw);

        uint256 pendingAmount = pendingWithdrawals[participant];
        if (pendingAmount == 0) {
            withdrawals.push(participant);
        }
        pendingWithdrawals[participant] = pendingAmount.add(amountTokensToWithdraw);
        emit WithdrawRequest(participant, amountTokensToWithdraw);
    }

    function claimTokens(ERC20 token) external onlyOwner {

        require(address(token) != address(0), "Invalid address");
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(owner(), token.balanceOf(address(this)));
        emit TokensClaimed(address(token), balance);
    }

    function burnForParticipant(address account, uint256 value) external onlyOwner {

        _burn(account, value);
    }

    function changeStableContract(address stableContractInput) external onlyOwner whenPaused {

        require(stableContractInput != address(0), "Invalid stable coin address");
        stableContract = stableContractInput;
    }

    function addLiquidity(uint256 amount) external {

        ERC20 erc20 = ERC20(stableContract);
        erc20.safeTransferFrom(msg.sender, address(this), amount);
        emit AddLiquidity(msg.sender, stableContract, amount);
    }

    function removeLiquidity(uint256 amount) external onlyOwner {

        ERC20(stableContract).safeTransfer(msg.sender, amount);
        emit RemoveLiquidity(msg.sender, amount);
    }

    function removeMinter(address account) external onlyOwner {

        require(account != msg.sender, "Use renounceMinter");
        _removeMinter(account);
    }

    function removePauser(address account) external onlyOwner {

        require(account != msg.sender, "Use renouncePauser");
        _removePauser(account);
    }

    function numberWithdrawalsPending() external view returns (uint256) {

        return withdrawals.length;
    }

    function initialize(string memory name, string memory symbol, uint8 decimals, uint256 priceNumeratorInput, address whitelistContractInput, address stableContractInput) public initializer {

        ERC20Detailed.initialize(name, symbol, decimals);
        Pausable.initialize(msg.sender);
        Ownable.initialize(msg.sender);
        MinterRole.initialize(msg.sender);
        price = Price(priceNumeratorInput, 1000);
        require(priceNumeratorInput > 0, "Invalid price numerator");
        require(whitelistContractInput != address(0), "Invalid whitelist address");
        require(stableContractInput != address(0), "Invalid stable coin address");
        whitelistContract = whitelistContractInput;
        stableContract = stableContractInput;

        minTokenRedemption = 1 ether;
        maxWithdrawalsPerTx = 50;
    }

    function mint(address to, uint256 value) public onlyMinter whenNotPaused returns (bool) {

        _mint(to, value);
        return true;
    }

    function processWithdrawals() internal {

        uint256 numberOfWithdrawals = Math.min(withdrawals.length, maxWithdrawalsPerTx);
        uint256 startingIndex = withdrawals.length;
        uint256 endingIndex = withdrawals.length.sub(numberOfWithdrawals);

        for (uint256 i = startingIndex; i > endingIndex; i--) {
            handleWithdrawal(i - 1);
        }
    }

    function handleWithdrawal(uint256 index) internal {

        address participant = withdrawals[index];
        uint256 tokens = pendingWithdrawals[participant];
        uint256 withdrawValue = tokens.mul(price.denominator) / price.numerator;
        pendingWithdrawals[participant] = 0;
        withdrawals.pop();

        if (ERC20(stableContract).balanceOf(address(this)) < withdrawValue) {
            mint(participant, tokens);
            emit WithdrawFailed(participant, tokens);
            return;
        }

        ERC20(stableContract).safeTransfer(participant, withdrawValue);
        emit Withdraw(participant, tokens, withdrawValue);
    }

    modifier onlyWhitelisted() {

        require(InvictusWhitelist(whitelistContract).isWhitelisted(msg.sender), "Must be whitelisted");
        _;
    }
}