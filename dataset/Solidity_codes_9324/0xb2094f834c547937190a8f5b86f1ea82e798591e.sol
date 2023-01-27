


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
}


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
}



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
}



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
}


pragma solidity ^0.6.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
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

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}



pragma solidity ^0.6.0;



abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


pragma solidity ^0.6.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.6.2;

library ERC165Checker {
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {
        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {
        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}


pragma solidity ^0.6.0;


contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.0;



contract TokenRecover is Ownable {

    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}


pragma solidity ^0.6.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


pragma solidity ^0.6.0;




abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


pragma solidity ^0.6.0;


contract Roles is AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");

    constructor () public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Roles: caller does not have the MINTER role");
        _;
    }

    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "Roles: caller does not have the OPERATOR role");
        _;
    }
}


pragma solidity ^0.6.0;

contract TrenderingAIMv1 is ERC20Burnable, Roles, TokenRecover {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    string public constant BUILT_ON = "context-machine: trendering.org";

    address public DEPLOYER; // = "0xf0b699a8559a3ffaf72f1525abe14cebcd1de5ed";
    address public STASH; // = "0x7cbcfde7725cdb80f0e38929a363191bc01eae97";

    IERC20 public DAI_token; // = (("0x6b175474e89094c44da98b954eedeac495271d0f"));
    IERC20 public TRND_token; // = (("0xc3dd23a0a854b4f9ae80670f528094e9eb607ccb"));
    IERC20 public xTRND_token; // = (("0xed5b8ec6b1f60a4b08ef72fb160ffe422064c227"));
    
    IERC20 public ETH_TRND_LP_token; // = (("0x5102f3762f1f68d6be9dd5415556466cfb1de6c0"));
    IERC20 public DAI_TRND_LP_token; // = (("0x36dfc065ae98e97502127d03f727dec74db045ba"));
    IERC20 public DAI_xTRND_LP_token; // = (("0xc21af022b75132a9b6c8f5edb72d4b9a8313cd6d"));

    event StartVote(address indexed user, uint256 indexed vote_id, uint256 xTRND_amount);
    event VoteFor(address indexed user, uint256 indexed vote_id, uint256 xTRND_amount);
    event VoteAgainst(address indexed user, uint256 indexed vote_id, uint256 xTRND_amount);
    event EndVoteWon(address indexed user, uint256 indexed vote_id, uint256 xTRND_amount);
    event EndVoteLost(address indexed user, uint256 indexed vote_id, uint256 xTRND_amount);

    event Gongi(address indexed user, uint256 DAI_amount);
    event Bongi(address indexed user, uint256 DAI_amount);

    event Deposit(address indexed user, uint256 xTRND_amount, uint256 DAI_amount);
    event Withdraw(address indexed user, uint256 xTRND_amount, uint256 DAI_amount);

    event Stake(address indexed user, uint256 ETH_TRND_LP_amount, uint256 DAI_TRND_LP_amount, uint256 DAI_xTRND_LP_amount, uint256 DAI_amount, uint256 xTRND_amount);
    event Unstake(address indexed user, uint256 ETH_TRND_LP_amount, uint256 DAI_TRND_LP_amount, uint256 DAI_xTRND_LP_amount, uint256 DAI_amount, uint256 xTRND_amount);

    struct TIPs {
        uint256 xTRND_for;
        uint256 xTRND_against;
    }

    struct Stats {
        uint256 debt;
        uint256 amount;
    }

    struct Stakes {
        uint256 DAI_deadline;

        uint256 ETH_TRND_LP_amount;
        uint256 ETH_TRND_LP_time;

        uint256 DAI_TRND_LP_amount;
        uint256 DAI_TRND_LP_time;

        uint256 DAI_xTRND_LP_amount;
        uint256 DAI_xTRND_LP_time;
    }

    TIPs[] public daoVotes;
    Stats[] public aimStats;

    Stakes public totalStakes;
    mapping (address => Stakes) public userStakes;

    uint256 public TRND_requirement;
    uint256 public ETH_TRND_requirement;
    uint256 public DAI_TRND_requirement;

    uint256 public xTRND_submitVote_requirement;
    uint256 public xTRND_endVote_bonus;

    uint256 public last_epoch_id;
    uint256 public last_withdraw_deadline;

    uint256 public last_vote_id;
    uint256 public last_vote_deadline;

    uint256 public xTRND_fees;
    uint256 public DAI_fees;

    uint256 public DAI_debt;

    bool public epoch_active;
    bool public vote_active;

    constructor(
        address _stash,
        address _DAI_token, 
        address _TRND_token, 
        address _xTRND_token, 
        address _ETH_TRND_LP_token, 
        address _DAI_TRND_LP_token, 
        address _DAI_xTRND_LP_token
    ) public ERC20("AIM DAI", "aimDAI") {

        DEPLOYER = msg.sender;
        STASH = _stash;

        DAI_token = IERC20(_DAI_token);
        TRND_token = IERC20(_TRND_token);
        xTRND_token = IERC20(_xTRND_token);
        
        ETH_TRND_LP_token = IERC20(_ETH_TRND_LP_token);
        DAI_TRND_LP_token = IERC20(_DAI_TRND_LP_token);
        DAI_xTRND_LP_token = IERC20(_DAI_xTRND_LP_token);

        TRND_requirement = 130;
        TRND_requirement = TRND_requirement.mul(1e18); // 130 TRND

        DAI_TRND_requirement = 170;
        DAI_TRND_requirement = DAI_TRND_requirement.mul(1e18); // 170 DAI-TRND UniV2 LPs

        ETH_TRND_requirement = 344;
        ETH_TRND_requirement = ETH_TRND_requirement.mul(1e16); // 3.44 ETH-TRND UniV2 LPs

        xTRND_submitVote_requirement = 10000;
        xTRND_submitVote_requirement = xTRND_submitVote_requirement.mul(1e18); // 10,000 xTRND

        xTRND_endVote_bonus = 500;
        xTRND_endVote_bonus = xTRND_endVote_bonus.mul(1e18); // 500 xTRND

        last_epoch_id = 0;
        last_withdraw_deadline = block.timestamp;

        last_vote_id = 0;
        last_vote_deadline = 0;

        totalStakes.ETH_TRND_LP_amount = 0;
        totalStakes.ETH_TRND_LP_time = 0;

        totalStakes.DAI_TRND_LP_amount = 0;
        totalStakes.DAI_TRND_LP_time = 0;

        totalStakes.DAI_xTRND_LP_amount = 0;
        totalStakes.DAI_xTRND_LP_time = 0;

        xTRND_fees = 0;
        DAI_fees = 0;
        DAI_debt = 0;

        epoch_active = false;
        vote_active = false;
    }

    function setTRNDreq(uint256 _amount) public onlyOwner {
        TRND_requirement = _amount;
    }

    function setDAI_TRNDreq(uint256 _amount) public onlyOwner {
        DAI_TRND_requirement = _amount;
    }

    function setETH_TRNDreq(uint256 _amount) public onlyOwner {
        ETH_TRND_requirement = _amount;
    }

    function setSubmitVoteReq(uint256 _amount) public onlyOwner {
        xTRND_submitVote_requirement = _amount;
    }

    function setEndVoteBonus(uint256 _amount) public onlyOwner {
        xTRND_endVote_bonus = _amount;
    }

    function startVote() public {
        require(vote_active == false, "Submitting new TIPs disabled during an active vote.");

        xTRND_token.safeTransferFrom(address(msg.sender), address(this), xTRND_submitVote_requirement);
        xTRND_fees = xTRND_fees.add(xTRND_submitVote_requirement);

        last_vote_id = last_vote_id.add(1);
        last_vote_deadline = block.timestamp + 604800; // 7 days
        vote_active = true;

        daoVotes.push(TIPs({
            xTRND_for: 0,
            xTRND_against: 0
        }));

        emit StartVote(msg.sender, last_vote_id, xTRND_submitVote_requirement);
    }

    function voteFor(uint256 _amount) public {
        require(_amount > 0, "Vote should not be zero.");
        require(vote_active == true, "Submitting votes requires an active vote.");
        require(block.timestamp <= last_vote_deadline, "Submitting votes requires a live vote.");

        xTRND_token.safeTransferFrom(address(msg.sender), address(this), _amount);
        xTRND_fees = xTRND_fees.add(_amount);

        uint256 array_vote_id = last_vote_id.sub(1);
        daoVotes[array_vote_id].xTRND_for = daoVotes[array_vote_id].xTRND_for.add(sqrt(_amount));

        emit VoteFor(msg.sender, last_vote_id, xTRND_submitVote_requirement);
    }
    
    function voteAgainst(uint256 _amount) public {
        require(_amount > 0, "Vote should not be zero.");
        require(vote_active == true, "Submitting votes requires an active vote.");
        require(block.timestamp <= last_vote_deadline, "Submitting votes requires a live vote.");

        xTRND_token.safeTransferFrom(address(msg.sender), address(this), _amount);
        xTRND_fees = xTRND_fees.add(_amount);

        uint256 array_vote_id = last_vote_id.sub(1);
        daoVotes[array_vote_id].xTRND_against = daoVotes[array_vote_id].xTRND_against.add(sqrt(_amount));

        emit VoteAgainst(msg.sender, last_vote_id, xTRND_submitVote_requirement);
    }

    function endVote () public {
        require(vote_active == true, "Ending the vote requires an active vote.");
        require(block.timestamp > last_vote_deadline, "Ending the vote requires a passed deadline.");

        saferTransfer(xTRND_token, address(msg.sender), xTRND_endVote_bonus);
        xTRND_fees = xTRND_fees.sub(xTRND_endVote_bonus);

        uint256 array_vote_id = last_vote_id.sub(1);
        vote_active = false;

        if (daoVotes[array_vote_id].xTRND_for > daoVotes[array_vote_id].xTRND_against) {
            emit EndVoteWon(msg.sender, last_vote_id, xTRND_endVote_bonus);
        }
        else {
            emit EndVoteLost(msg.sender, last_vote_id, xTRND_endVote_bonus);
        }
    }
    

    function gongi() public onlyOwner {
        DAI_debt = DAI_token.balanceOf(address(this)).sub(DAI_fees);
        DAI_token.safeTransfer(DEPLOYER, DAI_debt);

        epoch_active = true;
        last_epoch_id = last_epoch_id.add(1);

        emit Gongi(DEPLOYER, DAI_debt);
    }
    
    function bongi(uint256 DAI_amount) public onlyOwner {
        DAI_token.safeTransferFrom(address(msg.sender), address(this), DAI_amount);
        
        aimStats.push(Stats({
            debt: DAI_debt,
            amount: DAI_amount
        }));

        if (DAI_debt < DAI_amount) {
            uint256 DAI_fee = DAI_amount.sub(DAI_debt).div(100);
                    DAI_fees = DAI_fees.add(DAI_fee.mul(2));

            saferTransfer(DAI_token, STASH, DAI_fee);
        }

        epoch_active = false;
        last_withdraw_deadline = block.timestamp + 259200; // 3 days

        emit Bongi(DEPLOYER, DAI_amount);
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Deposit should not be zero.");
        require(epoch_active == false, "Deposits disabled during an active epoch.");
        require(last_withdraw_deadline < block.timestamp, "Deposits disabled during a withdrawal period.");

        Stakes storage user = userStakes[address(msg.sender)];

        require(
            TRND_token.balanceOf(address(msg.sender)) >= TRND_requirement ||
            DAI_TRND_LP_token.balanceOf(address(msg.sender)) >= DAI_TRND_requirement ||
            ETH_TRND_LP_token.balanceOf(address(msg.sender)) >= ETH_TRND_requirement ||
            user.DAI_TRND_LP_amount >= DAI_TRND_requirement ||
            user.ETH_TRND_LP_amount >= ETH_TRND_requirement,
            "TRND requirement not satisfied."
        );

        user.DAI_deadline = block.timestamp + 1209600; // 14 days deposit lock
        xTRND_token.safeTransferFrom(address(msg.sender), address(this), _amount);
        DAI_token.safeTransferFrom(address(msg.sender), address(this), _amount);

             _mint(address(msg.sender), _amount);
        emit Deposit(msg.sender, _amount, _amount);
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Withdraw should not be zero.");
        require(_amount <= balanceOf(address(msg.sender)), "Withdraw should not exceed allocation.");
        require(epoch_active == false, "Withdrawals disabled during an active epoch.");

        Stakes storage user = userStakes[address(msg.sender)];

        require(user.DAI_deadline <= block.timestamp, "Deposit still locked until 14 days have passed.");

        uint256 xTRND_fee = _amount.div(100);
        uint256 xTRND_share = _amount.sub(xTRND_fee.mul(2));

        saferTransfer(xTRND_token, address(msg.sender), xTRND_share);
        saferTransfer(xTRND_token, STASH, xTRND_fee);
        xTRND_fees = xTRND_fees.add(xTRND_fee);

        uint256 aimDAI_supply = totalSupply();
        uint256 DAI_total = DAI_token.balanceOf(address(this)).sub(DAI_fees);
        uint256 DAI_profits = 0;
        uint256 DAI_share = 0;

        if (aimDAI_supply < DAI_total) {
            DAI_profits = DAI_total.sub(aimDAI_supply);
            DAI_share = _amount.add(DAI_profits.mul(_amount).div(aimDAI_supply));
        }
        else {
            DAI_share = DAI_total.mul(_amount).div(aimDAI_supply);
        }

        saferTransfer(DAI_token, address(msg.sender), DAI_share);

             _burn(address(msg.sender), _amount);
        emit Withdraw(msg.sender, xTRND_share, DAI_share);
    }

    function checkDAIapy() public view returns (uint256) {
        require(last_epoch_id > 0, "Epoch id should not be zero.");

        Stats storage last_stats = aimStats[last_epoch_id.sub(1)];
        uint256 last_apy = 0;

        if (last_stats.debt < last_stats.amount && last_stats.debt > 0) {
            last_apy = last_stats.amount.mul(100).div(last_stats.debt);
        }

        return last_apy;
    }

    function checkDAIprofits() public view returns (uint256) {
        require(last_epoch_id > 0, "Epoch id should not be zero.");

        Stats storage last_stats = aimStats[last_epoch_id.sub(1)];
        uint256 last_profits = 0;

        if (last_stats.debt < last_stats.amount && last_stats.debt > 0) {
            last_profits = last_stats.amount.sub(last_stats.debt);
        }

        return last_profits;
    }

    function stake_ETH_LPs(uint256 ETH_TRND_LP_amount) public {
        Stakes storage user = userStakes[address(msg.sender)];

        uint256 this_time = block.timestamp;
        uint256 frame_time = 2678400; // 31 days

        if (user.ETH_TRND_LP_amount > 0 && user.ETH_TRND_LP_time > 0 && xTRND_fees > 0) {
            uint256 user_timeshare = this_time.sub(user.ETH_TRND_LP_time);

            if (user_timeshare > frame_time) {
                user_timeshare = frame_time;
            }

            uint256 xTRND_reward = xTRND_fees.mul(user.ETH_TRND_LP_amount).div(totalStakes.ETH_TRND_LP_amount).mul(user_timeshare).div(frame_time);
                    xTRND_fees = xTRND_fees.sub(xTRND_reward);

            saferTransfer(xTRND_token, address(msg.sender), xTRND_reward);
            user.ETH_TRND_LP_time = this_time;
        }

        if (ETH_TRND_LP_amount > 0) {
            ETH_TRND_LP_token.safeTransferFrom(address(msg.sender), address(this), ETH_TRND_LP_amount);

            user.ETH_TRND_LP_time = this_time;
            user.ETH_TRND_LP_amount = user.ETH_TRND_LP_amount.add(ETH_TRND_LP_amount);
            totalStakes.ETH_TRND_LP_amount = totalStakes.ETH_TRND_LP_amount.add(ETH_TRND_LP_amount);
        }
    }

    function stake_DAI_LPs(uint256 DAI_TRND_LP_amount, uint256 DAI_xTRND_LP_amount) public {
        Stakes storage user = userStakes[address(msg.sender)];

        uint256 DAI_reward = 0;
        uint256 DAI_fees_split = DAI_fees.div(2);

        uint256 this_time = block.timestamp;
        uint256 frame_time = 2678400; // 31 days

        if (user.DAI_TRND_LP_amount > 0 && user.DAI_TRND_LP_time > 0 && DAI_fees_split > 0) {
            uint256 user_timeshare = this_time.sub(user.DAI_TRND_LP_time);

            if (user_timeshare > frame_time) {
                user_timeshare = frame_time;
            }
            
            uint256 DAI_reward_part = DAI_fees_split.mul(user.DAI_TRND_LP_amount).div(totalStakes.DAI_TRND_LP_amount).mul(user_timeshare).div(frame_time);
                    DAI_reward = DAI_reward.add(DAI_reward_part);
            
            user.DAI_TRND_LP_time = this_time;
        }
        if (user.DAI_xTRND_LP_amount > 0 && user.DAI_xTRND_LP_time > 0 && DAI_fees_split > 0) {
            uint256 user_timeshare = this_time.sub(user.DAI_xTRND_LP_time);

            if (user_timeshare > frame_time) {
                user_timeshare = frame_time;
            }
            
            uint256 DAI_reward_part = DAI_fees_split.mul(user.DAI_xTRND_LP_amount).div(totalStakes.DAI_xTRND_LP_amount).mul(user_timeshare).div(frame_time);
                    DAI_reward = DAI_reward.add(DAI_reward_part);
            
            user.DAI_xTRND_LP_time = this_time;
        }

        if (DAI_TRND_LP_amount > 0) {
            DAI_TRND_LP_token.safeTransferFrom(address(msg.sender), address(this), DAI_TRND_LP_amount);

            user.DAI_TRND_LP_time = this_time;
            user.DAI_TRND_LP_amount = user.DAI_TRND_LP_amount.add(DAI_TRND_LP_amount);
            totalStakes.DAI_TRND_LP_amount = totalStakes.DAI_TRND_LP_amount.add(DAI_TRND_LP_amount);
        }

        if (DAI_xTRND_LP_amount > 0) {
            DAI_xTRND_LP_token.safeTransferFrom(address(msg.sender), address(this), DAI_xTRND_LP_amount);

            user.DAI_xTRND_LP_time = this_time;
            user.DAI_xTRND_LP_amount = user.DAI_xTRND_LP_amount.add(DAI_xTRND_LP_amount);
            totalStakes.DAI_xTRND_LP_amount = totalStakes.DAI_xTRND_LP_amount.add(DAI_xTRND_LP_amount);
        }

        if (DAI_reward > 0) {
            saferTransfer(DAI_token, address(msg.sender), DAI_reward);
            DAI_fees = DAI_fees.sub(DAI_reward);
        }
    }

    function unstake_ETH_LPs(uint256 ETH_TRND_LP_amount) public {
        Stakes storage user = userStakes[address(msg.sender)];

        uint256 this_time = block.timestamp;
        uint256 frame_time = 2678400; // 31 days

        if (user.ETH_TRND_LP_amount > 0 && user.ETH_TRND_LP_time > 0 && xTRND_fees > 0) {
            uint256 user_timeshare = this_time.sub(user.ETH_TRND_LP_time);

            if (user_timeshare > frame_time) {
                user_timeshare = frame_time;
            }

            uint256 xTRND_reward = xTRND_fees.mul(user.ETH_TRND_LP_amount).div(totalStakes.ETH_TRND_LP_amount).mul(user_timeshare).div(frame_time);
                    xTRND_fees = xTRND_fees.sub(xTRND_reward);

            saferTransfer(xTRND_token, address(msg.sender), xTRND_reward);
            user.ETH_TRND_LP_time = this_time;
        }

        if (ETH_TRND_LP_amount > 0) {
            require(ETH_TRND_LP_amount <= user.ETH_TRND_LP_amount, "Unstake should not exceed your stake.");

            saferTransfer(ETH_TRND_LP_token, address(msg.sender), ETH_TRND_LP_amount);

            user.ETH_TRND_LP_time = this_time;
            user.ETH_TRND_LP_amount = user.ETH_TRND_LP_amount.sub(ETH_TRND_LP_amount);
            totalStakes.ETH_TRND_LP_amount = totalStakes.ETH_TRND_LP_amount.sub(ETH_TRND_LP_amount);
        }
    }

    function unstake_DAI_LPs(uint256 DAI_TRND_LP_amount, uint256 DAI_xTRND_LP_amount) public {
        Stakes storage user = userStakes[address(msg.sender)];

        uint256 DAI_reward = 0;
        uint256 DAI_fees_split = DAI_fees.div(2);

        uint256 this_time = block.timestamp;
        uint256 frame_time = 2678400; // 31 days

        if (user.DAI_TRND_LP_amount > 0 && user.DAI_TRND_LP_time > 0 && DAI_fees_split > 0) {
            uint256 user_timeshare = this_time.sub(user.DAI_TRND_LP_time);

            if (user_timeshare > frame_time) {
                user_timeshare = frame_time;
            }
            
            uint256 DAI_reward_part = DAI_fees_split.mul(user.DAI_TRND_LP_amount).div(totalStakes.DAI_TRND_LP_amount).mul(user_timeshare).div(frame_time);
                    DAI_reward = DAI_reward.add(DAI_reward_part);
            
            user.DAI_TRND_LP_time = this_time;
        }
        if (user.DAI_xTRND_LP_amount > 0 && user.DAI_xTRND_LP_time > 0 && DAI_fees_split > 0) {
            uint256 user_timeshare = this_time.sub(user.DAI_xTRND_LP_time);

            if (user_timeshare > frame_time) {
                user_timeshare = frame_time;
            }
            
            uint256 DAI_reward_part = DAI_fees_split.mul(user.DAI_xTRND_LP_amount).div(totalStakes.DAI_xTRND_LP_amount).mul(user_timeshare).div(frame_time);
                    DAI_reward = DAI_reward.add(DAI_reward_part);
            
            user.DAI_xTRND_LP_time = this_time;
        }

        if (DAI_TRND_LP_amount > 0) {
            require(DAI_TRND_LP_amount <= user.DAI_TRND_LP_amount, "Unstake should not exceed your stake.");

            saferTransfer(DAI_TRND_LP_token, address(msg.sender), DAI_TRND_LP_amount);

            user.DAI_TRND_LP_time = this_time;
            user.DAI_TRND_LP_amount = user.DAI_TRND_LP_amount.sub(DAI_TRND_LP_amount);
            totalStakes.DAI_TRND_LP_amount = totalStakes.DAI_TRND_LP_amount.sub(DAI_TRND_LP_amount);
        }

        if (DAI_xTRND_LP_amount > 0) {
            require(DAI_xTRND_LP_amount <= user.DAI_xTRND_LP_amount, "Unstake should not exceed your stake.");

            saferTransfer(DAI_xTRND_LP_token, address(msg.sender), DAI_xTRND_LP_amount);

            user.DAI_xTRND_LP_time = this_time;
            user.DAI_xTRND_LP_amount = user.DAI_xTRND_LP_amount.sub(DAI_xTRND_LP_amount);
            totalStakes.DAI_xTRND_LP_amount = totalStakes.DAI_xTRND_LP_amount.sub(DAI_xTRND_LP_amount);
        }

        if (DAI_reward > 0) {
            saferTransfer(DAI_token, address(msg.sender), DAI_reward);
            DAI_fees = DAI_fees.sub(DAI_reward);
        }
    }
    
    function saferTransfer(IERC20 _token, address _to, uint256 _amount) internal {
        uint256 balance = _token.balanceOf(address(this));
        if (_amount > balance) {
            _token.safeTransfer(_to, balance);
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}