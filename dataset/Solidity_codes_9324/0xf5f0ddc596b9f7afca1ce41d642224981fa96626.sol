

pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.0;




contract ERC20 is Initializable, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;




contract MinterRole is Initializable {

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

        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
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




contract ERC20Mintable is Initializable, ERC20, MinterRole {

    function initialize(address sender) public initializer {

        MinterRole.initialize(sender);
    }

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract PauserRole is Initializable {

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

        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
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



contract Pausable is Initializable, PauserRole {

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

        require(!_paused);
        _;
    }

    modifier whenPaused() {

        require(_paused);
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract ERC20Pausable is Initializable, ERC20, Pausable {

    function initialize(address sender) public initializer {

        Pausable.initialize(sender);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    uint256[50] private ______gap;
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



contract WhitelistAdminRole is Initializable {

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

        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(msg.sender);
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

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
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


pragma solidity ^0.5.2;

contract HolderIterableRole {


    event HolderAdded(address indexed account);
    event HolderRemoved(address indexed account);

    struct Holder {
        bool isHolder;
        uint index; // starts with 1
    }

    mapping (address => Holder) private _holders;
    address[] internal holderList;

    modifier onlyHolder() {

        require(isHolder(msg.sender));
        _;
    }

    function isHolder(address account) public view returns (bool) {

        Holder storage holder = _holders[account];
        return holder.isHolder;
    }

    function addHolder(address account) internal {

        Holder storage holder = _holders[account];
        require(holder.isHolder == false);

        holder.isHolder = true;

        holderList.push(account);
        holder.index = holderList.length; // starts with 1, no decreasing 1 here.
        emit HolderAdded(account);
    }

    function removeHolder(address account) internal {

        Holder storage holder = _holders[account];

        require(holder.isHolder == true);
        require(holder.index != 0); // entry not exist
        require(holder.index <= holderList.length); // should not exceed max index

        uint holderListIndex = holder.index - 1;
        uint holderListLastIndex = holderList.length - 1;

        address lastAddressInHolderList = holderList[holderListLastIndex];
        _holders[lastAddressInHolderList].index = holderListIndex + 1;
        holderList[holderListIndex] = holderList[holderListLastIndex];
        holderList.length--;

        holder.isHolder = false;
        holder.index = 0;
        emit HolderRemoved(account);
    }

    function getHolders() internal view returns (address[] memory) {

        return holderList;
    }

    function getHolderCount() view public returns (uint256 holderCount) {

        return holderList.length;
    }
}


pragma solidity ^0.5.2;



contract ERC20HolderListable is ERC20, HolderIterableRole {


    function initialize(address sender) public initializer {

        addHolder(sender);
    }

    function _transfer(address from, address to, uint256 value) internal {

        super._transfer(from, to, value);

        if (balanceOf(from) == 0) {
            removeHolder(from);
        }

        if (!isHolder(to) && balanceOf(to) > 0) {
            addHolder(to);
        }
    }
}


pragma solidity ^0.5.2;







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

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
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

contract ERC20Rewardable is Initializable, ERC20HolderListable, WhitelistAdminRole {


    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function initialize(address sender) public initializer {

        WhitelistAdminRole.initialize(sender);
        ERC20HolderListable.initialize(sender);
    }

    enum RewardStatus { Unknown, Created, Cancelled, Executed }

    struct Reward {
        string identifier; // identifier of the reward
        RewardStatus status;
        string rewardType;
        string data;
        IERC20 token; // token to be granted
        uint256 amount; // amount to be distributed
        mapping(address => bool) grantedMap; // granted account map
    }

    mapping(address => uint256) private _tokenBatchCount;
    mapping(address => uint256) private _tokenRewardBalance;
    mapping(string => Reward) identifierRewardMap;

    function getReward(string calldata identifier) external view returns (
        uint256 status,
        string memory rewardType,
        string memory data,
        address token,
        uint256 amount
    ) {

        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status != RewardStatus.Unknown);
        return (uint256(reward.status), reward.rewardType, reward.data, address(reward.token), reward.amount);
    }

    function createReward(
        string calldata identifier,
        string calldata rewardType,
        string calldata data,
        IERC20 token,
        uint256 amount
    ) external onlyWhitelistAdmin {

        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status == RewardStatus.Unknown);

        uint256 balance = token.balanceOf(address(this));
        uint256 tokenRewardBalance = _tokenRewardBalance[address(token)];
        uint256 newTokenRewardBalance = tokenRewardBalance.add(amount);
        require(balance >= newTokenRewardBalance);

        _tokenRewardBalance[address(token)] = newTokenRewardBalance;

        reward.identifier = identifier;
        reward.status = RewardStatus.Created;
        reward.rewardType = rewardType;
        reward.data = data;
        reward.token = token;
        reward.amount = amount;
    }

    function cancelReward(string calldata identifier) external onlyWhitelistAdmin {

        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status != RewardStatus.Executed);

        reward.status = RewardStatus.Cancelled;

        uint256 tokenRewardBalance = _tokenRewardBalance[address(reward.token)];
        uint256 newTokenRewardBalance = tokenRewardBalance.sub(reward.amount);
        _tokenRewardBalance[address(reward.token)] = newTokenRewardBalance;
    }

    function withdrawRemainingTokenReward(IERC20 token, address to) external onlyWhitelistAdmin {

        uint256 amount = token.balanceOf(address(this));
        uint256 tokenRewardBalance = _tokenRewardBalance[address(token)];
        token.safeTransfer(to, amount.sub(tokenRewardBalance));
    }

    function setTokenRewardBatchCount(IERC20 token, uint256 batchCount) external onlyWhitelistAdmin {

        _tokenBatchCount[address(token)] = batchCount;
    }

    function executeReward(string memory identifier) public onlyWhitelistAdmin {

        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status == RewardStatus.Created);

        address[] memory holders = getHolders();
        for (uint index = 0; index < holders.length; index++) {
            require(reward.grantedMap[holders[index]] == false);
            uint256 amount = reward.amount.mul(balanceOf(holders[index])).div(totalSupply());
            reward.token.safeTransfer(holders[index], amount);
            reward.grantedMap[holders[index]] = true;
        }

        _tokenRewardBalance[address(reward.token)] = _tokenRewardBalance[address(reward.token)].sub(reward.amount);
        reward.status = RewardStatus.Executed;
    }

    function executeRewardBatch(string memory identifier, uint256 batchOffset) public onlyWhitelistAdmin {

        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status == RewardStatus.Created || reward.status == RewardStatus.Executed);

        uint256 tokenBatchCount = _tokenBatchCount[address(reward.token)];
        require(tokenBatchCount != 0);
        uint256 offset = batchOffset * _tokenBatchCount[address(reward.token)];
        address[] memory holders = getHolders();
        uint256 maxIndex = Math.min(offset + tokenBatchCount, holders.length);

        for (uint256 index = offset; index < maxIndex; index++) {
            require(reward.grantedMap[holders[index]] == false);
            uint256 amount = reward.amount.mul(balanceOf(holders[index])).div(totalSupply());
            reward.token.safeTransfer(holders[index], amount);
            reward.grantedMap[holders[index]] = true;
            _tokenRewardBalance[address(reward.token)] = _tokenRewardBalance[address(reward.token)].sub(amount);
        }
        reward.status = RewardStatus.Executed;
    }
}


pragma solidity ^0.5.2;







contract KFALKToken is Initializable, ERC20Detailed, ERC20Mintable, ERC20Pausable, ERC20Rewardable {


    string public Token_ID;
    string public ArtistID;
    string public ISRC;

    function initialize() public initializer {

        Token_ID = "KFALK";
        ArtistID = "Jae Chong, Luke Tsui";
        ISRC = "";

        ERC20Detailed.initialize("", "KFALK", 18);
        ERC20Mintable.initialize(msg.sender);
        ERC20Pausable.initialize(msg.sender);
        ERC20Rewardable.initialize(msg.sender);
    }

    function executeReward(string memory identifier) public onlyWhitelistAdmin {

        require(paused(), "require paused when rewarding");
        super.executeReward(identifier);
    }

    function executeRewardBatch(string memory identifier, uint256 batchOffset) public onlyWhitelistAdmin {

        require(paused(), "require paused when rewarding");
        super.executeRewardBatch(identifier, batchOffset);
    }
}