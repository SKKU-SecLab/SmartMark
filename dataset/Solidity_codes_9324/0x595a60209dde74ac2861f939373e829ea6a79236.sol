



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.8.0;



abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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
}




pragma solidity ^0.8.0;



abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}




pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}




pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;




interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
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




pragma solidity ^0.8.0;



interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}




pragma solidity ^0.8.0;






contract ERC20PresetMinterPauser is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}



pragma solidity ^0.8.0;



pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}


library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity 0.8.4;

interface IPugFactory {
    function claimRewards(uint256 _lastRewardTime, address _baseToken) external returns(uint256);
}



pragma solidity 0.8.4;

interface IPugStaking {
    function addRewards(uint256 _amount) external;
    function addPug(address _baseToken, address _pug) external;
}




pragma solidity ^0.8.4;





interface SushiRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract Pug is ERC20PresetMinterPauser, Ownable {
    using SafeERC20 for ERC20;

    address pugFactory;
    address public baseToken;
    address pugToken;
    address public pugStaking;

    uint256 public pugRatio; // pugToken per native token
    uint256 public fee; // per 10^12

    uint256 lastRewardTime;
    uint256 accPugTokenPerShare;
    mapping(address => uint256) userDebt;

    uint8 DECIMALS;
    address sushiRouter;
    address WETH;

    uint256 constant DENOMINATION = 1e12;
    uint256 constant INFINITY = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    event RewardsWithdrawn(address to, uint256 amount);
    event PugTokenUpdated(address indexed updatedPugToken);
    event PugFactoryUpdated(address indexed updatedFactoryToken);
    event FeeUpdated(uint256 updatedFee);
    event PugStakingUpdated(address indexed updatedPugStaking);
    event SushiRouterUpdated(address updatedSushiRouter);
    event WETHUpdated(address updatedWETH);

    constructor(
        string memory _name, 
        string memory _symbol,
        address _baseToken,
        address _pugToken, 
        uint256 _decimals, 
        uint256 _fee, 
        address _owner,
        address _pugStaking,
        address _sushiRouter,
        address _WETH
    ) ERC20PresetMinterPauser(_name, _symbol) Ownable() {
        baseToken = _baseToken;
        pugToken = _pugToken;
        emit PugTokenUpdated(_pugToken);
        pugStaking = _pugStaking;
        emit PugStakingUpdated(_pugStaking);
        fee = _fee;
        emit FeeUpdated(_fee);
        
        DECIMALS = uint8(_decimals);
        pugRatio = 10**(uint256(ERC20(_baseToken).decimals()) - _decimals);

        transferOwnership(_owner);
        pugFactory = msg.sender;
        emit PugFactoryUpdated(msg.sender);

        lastRewardTime = block.timestamp;
        renounceRole(MINTER_ROLE, msg.sender);

        sushiRouter = _sushiRouter;
        WETH = _WETH;
        IERC20(_baseToken).approve(_sushiRouter, INFINITY);
    }

    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function updateRewards() public {
        uint256 _lastRewardTime = lastRewardTime;
        if(block.timestamp <= _lastRewardTime) {
            return;
        }
        uint256 pugSupply = totalSupply();
        if(pugSupply == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        uint256 reward = getPugRewards(_lastRewardTime);
        accPugTokenPerShare = accPugTokenPerShare + (reward * DENOMINATION / pugSupply);
        lastRewardTime = block.timestamp;
    }

    function getPugRewards(uint256 _lastRewardTime) internal returns(uint256) {
        return IPugFactory(pugFactory).claimRewards(_lastRewardTime, baseToken);
    }

    function pug(uint256 _amount) external {
        uint256 senderBalance = balanceOf(msg.sender);
        updateRewards();
        if(senderBalance != 0) {
            uint256 pendingRewards = (senderBalance * accPugTokenPerShare / DENOMINATION) - userDebt[msg.sender];
            transferRewards(msg.sender, pendingRewards);
        }
        address _baseToken = baseToken;
        uint256 feeAmount = _amount * fee / 2 / DENOMINATION;

        ERC20(_baseToken).transferFrom(msg.sender, address(this), _amount);
        try ERC20PresetMinterPauser(_baseToken).burn(feeAmount) {

        } catch (bytes memory) {
            try ERC20(_baseToken).transfer(address(0), feeAmount) {
                
            } catch (bytes memory) {
                feeAmount = feeAmount * 2;
            }
        }
        address _pugStaking = pugStaking;
        uint256 feeInPugToken = swapForPugAndSend(feeAmount, _pugStaking);
        IPugStaking(_pugStaking).addRewards(feeInPugToken);

        _mint(msg.sender, _amount);
        userDebt[msg.sender] = (senderBalance + _amount) * accPugTokenPerShare / DENOMINATION;
    }

    function swapForPugAndSend(uint256 _fee, address _to) internal returns(uint256) {
        address[] memory path  = new address[](3);
        path[0]= baseToken;
        path[1] = WETH;
        path[2] = pugToken;
        uint[] memory amounts = SushiRouter(sushiRouter).swapExactTokensForTokens(
            _fee, 
            1, 
            path,
            _to,
            block.timestamp + 100
        );
        return amounts[amounts.length - 1];
    }

    function unpug(uint256 _amount) external {
        uint256 senderBalance = balanceOf(msg.sender);
        updateRewards();
        require(senderBalance >= _amount, "Balance not enough");
        uint256 pendingRewards = (senderBalance * accPugTokenPerShare / DENOMINATION) - userDebt[msg.sender];
        transferRewards(msg.sender, pendingRewards);
        
        address _baseToken = baseToken;
        userDebt[msg.sender] = (senderBalance - _amount) * accPugTokenPerShare / DENOMINATION;
        uint256 totalBaseTokensHeld = ERC20(_baseToken).balanceOf(address(this));
        uint256 baseTokenValue = _amount * totalBaseTokensHeld / totalSupply();
        _burn(msg.sender, _amount);
        ERC20(_baseToken).transfer(msg.sender, baseTokenValue);
    }

    function withdrawRewards(address _user) external returns(uint256) {
        updateRewards();
        uint256 balance = balanceOf(_user);
        uint256 totalReward = balance * accPugTokenPerShare / DENOMINATION;
        uint256 pendingRewards = totalReward - userDebt[_user];
        transferRewards(_user, pendingRewards);
        userDebt[_user] = totalReward;
        return pendingRewards;
    }

    function transferRewards(address _to, uint256 _amount) internal {
        if(_amount == 0) {
            return;
        }
        uint256 rewardsLeft = ERC20(pugToken).balanceOf(address(this));
        if(_amount > rewardsLeft) {
            ERC20(pugToken).transfer(_to, rewardsLeft);
        } else {
            ERC20(pugToken).transfer(_to, _amount);
        }
        emit RewardsWithdrawn(_to, _amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20PresetMinterPauser) {
        updateRewards();
        uint256 currentAccPugTokenPerShare = accPugTokenPerShare;

        if(from != address(0)) {
            uint256 fromBalance = balanceOf(from);
            uint256 fromPendingRewards = fromBalance * currentAccPugTokenPerShare / DENOMINATION - userDebt[from];
            userDebt[from] = (fromBalance - amount) * currentAccPugTokenPerShare / DENOMINATION;
            transferRewards(msg.sender, fromPendingRewards);
        }
        
        if(to != address(0)) {
            uint256 toBalance = balanceOf(to);
            uint256 toPendingRewards = toBalance * currentAccPugTokenPerShare / DENOMINATION - userDebt[to];
            userDebt[to] = (toBalance + amount) * currentAccPugTokenPerShare / DENOMINATION;
            transferRewards(msg.sender, toPendingRewards);
        }
    }

    function updatePugToken(address _newPugTokenAddress) external onlyOwner {
        pugToken = _newPugTokenAddress;
        emit PugTokenUpdated(_newPugTokenAddress);
    }

    function updatePugFactory(address _newPugFactoryAddress) external onlyOwner {
        pugFactory = _newPugFactoryAddress;
        emit PugFactoryUpdated(_newPugFactoryAddress);
    }

    function updatePugStaking(address _newPugStaking) external onlyOwner {
        pugStaking = _newPugStaking;
        emit PugStakingUpdated(_newPugStaking);
    }

    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
        emit FeeUpdated(_fee);
    }

    function updateSushiRouter(address _updatedSushiRouter) external onlyOwner {
        sushiRouter = _updatedSushiRouter;
        emit SushiRouterUpdated(_updatedSushiRouter);
    }

    function updateWETH(address _updatedWETH) external onlyOwner {
        WETH = _updatedWETH;
        emit WETHUpdated(_updatedWETH);
    }
}



pragma solidity 0.8.4;

interface IPugToken {
    function mint(address to, uint256 amount) external;
}




pragma solidity ^0.8.4;





interface SushiFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract PugFactory is Ownable {

    mapping(address => uint256) public rewardPoints;
    mapping(address => address) public pugPool;
    uint256 public totalRewardPoints;

    address public pugToken;
    address pugStaking;
    address sushiFactory;
    address sushiRouter;
    address WETH;

    uint256 public rewardsPerSecond;
    uint256 public pugCreationReward;
    uint256 public fee;
    uint256 public rewardEndTime;

    event PugCreated(address indexed pug, string name, string indexed symbol, address indexed baseToken, uint256 decimals);
    event RewardPointsUpdated(address indexed token, uint256 tokenRewardPoints, uint256 currentTotalRewardPoints);
    event AddToWhitelist(address indexed token, uint256 tokenRewardPoints, uint256 currentTotalRewardPoints);
    event RemoveFromWhitelist(address indexed token, uint256 tokenRewardPoints, uint256 currentTotalRewardPoints);
    event PugTokenUpdated(address indexed updatedPugToken);
    event PugCreationRewardUpdated(uint256 updatePugCreationReward);
    event RewardsPerSecondUpdated(uint256 updatedRewardsPerSecond);
    event FeeUpdated(uint256 updatedFee);
    event PugStakingUpdated(address indexed updatedPugStaking);
    event SushiFactoryUpdated(address updatedSushiFactory);
    event SushiRouterUpdated(address updatedSushiRouter);
    event WETHUpdated(address updatedWETH);

    constructor(
        address _admin, 
        address _pugToken, 
        uint256 _pugCreationReward, 
        uint256 _fee, 
        uint256 _rewardsPerSecond, 
        address _pugStaking, 
        address _sushiFactory,
        address _sushiRouter,
        address _WETH
    ) Ownable() {
        transferOwnership(_admin);
        pugToken = _pugToken;
        emit PugTokenUpdated(_pugToken);
        pugCreationReward = _pugCreationReward;
        emit PugCreationRewardUpdated(_pugCreationReward);
        fee = _fee;
        emit FeeUpdated(_fee);
        rewardsPerSecond = _rewardsPerSecond;
        emit RewardsPerSecondUpdated(_rewardsPerSecond);
        pugStaking = _pugStaking;
        sushiFactory = _sushiFactory;
        sushiRouter = _sushiRouter;
        WETH = _WETH;
        rewardEndTime = block.timestamp + 14 days;
    }

    function createPug(string memory _name, string memory _symbol, address _baseToken, uint256 _decimals) external {
        require(pugPool[_baseToken] == address(0), "Pug already exists for baseToken");
        require(
            SushiFactory(sushiFactory).getPair(_baseToken, WETH) != address(0),
            "BaseToken WETH pair necessary to create Pug"
        );
        address _pugToken = pugToken;
        Pug createdPug = new Pug(_name, 
            _symbol,
            _baseToken,
            _pugToken, 
            _decimals,  
            fee, 
            owner(),
            pugStaking,
            sushiRouter,
            WETH
        );
        pugPool[_baseToken] = address(createdPug);
        IPugStaking(pugStaking).addPug(_baseToken, address(createdPug));
        emit PugCreated(address(createdPug), _name, _symbol, _baseToken, _decimals);
        if(rewardPoints[_baseToken] != 0) {
            IPugToken(_pugToken).mint(msg.sender, pugCreationReward);
        }
    }

    function claimRewards(uint256 _lastRewardTime, address _baseToken) external returns(uint256) {
        require(pugPool[_baseToken] == msg.sender, "Only pug can claim rewards");
        uint256 allocatedReward = getRewardsPerSecond(_baseToken);
        uint256 reward = (block.timestamp - _lastRewardTime) * allocatedReward;
        if(reward != 0) {
            IPugToken(pugToken).mint(msg.sender, reward);
        }
        return reward;
    }

    function getRewardsPerSecond(address baseToken) view public returns(uint256) {
        if(block.timestamp > rewardEndTime) {
            return 0;
        }
        uint256 _totalRewardPoints = totalRewardPoints;
        return (_totalRewardPoints != 0 ? (rewardPoints[baseToken] * rewardsPerSecond / _totalRewardPoints): 0);
    }

    function updatePugToken(address _newPugTokenAddress) external onlyOwner {
        pugToken = _newPugTokenAddress;
        emit PugTokenUpdated(_newPugTokenAddress);
    }

    function updateRewardPerSecond(uint256 _updatedRewards) external onlyOwner {
        rewardsPerSecond = _updatedRewards;
        emit RewardsPerSecondUpdated(_updatedRewards);
    }

    function updatePugCreationReward(uint256 _updatedReward) external onlyOwner {
        pugCreationReward = _updatedReward;
        emit PugCreationRewardUpdated(_updatedReward);
    }

    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
        emit FeeUpdated(_fee);
    }

    function updatePugStaking(address _newPugStaking) external onlyOwner {
        pugStaking = _newPugStaking;
        emit PugStakingUpdated(_newPugStaking);
    }

    function updateSushiFactory(address _updatedSushiFactory) external onlyOwner {
        sushiFactory = _updatedSushiFactory;
        emit SushiFactoryUpdated(_updatedSushiFactory);
    }

    function updateSushiRouter(address _updatedSushiRouter) external onlyOwner {
        sushiRouter = _updatedSushiRouter;
        emit SushiRouterUpdated(_updatedSushiRouter);
    }

    function updateWETH(address _updatedWETH) external onlyOwner {
        WETH = _updatedWETH;
        emit WETHUpdated(_updatedWETH);
    }

    function updateRewardPoints(address _token, uint256 _rewardPoints) external onlyOwner {
        uint256 tokenRewardPoints = rewardPoints[_token];
        rewardPoints[_token] = _rewardPoints;
        uint256 currentTotalRewardPoints = totalRewardPoints - tokenRewardPoints + _rewardPoints;
        totalRewardPoints = currentTotalRewardPoints;
        emit RewardPointsUpdated(_token, _rewardPoints, currentTotalRewardPoints);
    }
}