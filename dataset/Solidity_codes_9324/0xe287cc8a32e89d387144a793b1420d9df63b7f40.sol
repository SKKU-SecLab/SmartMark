


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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




pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
}




pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.2 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;




abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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




pragma solidity >=0.6.0 <0.8.0;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}



pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;







interface IERC721 {

    function safeMint(address to, uint256 tokenId) external;


    function totalSupply() external view returns (uint256);

}


contract NFTFactory is AccessControl, ReentrancyGuard {

    using SafeMath for uint256;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    IERC721 public nft;

    struct UserInfo {
        uint256 claimedNum;
    }

    struct PoolInfo {
        uint256 maxNum;
        uint256 supply;
        bool paused;
        uint256 price;
        bytes32 root;
        uint256 limitPerAccount;
    }

    PoolInfo[] private pools;

    mapping(uint256 => mapping(address => UserInfo)) private users;

    event NewPool(uint256 indexed pid, uint256 maxNum, bool paused, uint256 price, bytes32 root, uint256 limitPerAccount);
    event ChangePoolMaxAndLimit(uint256 indexed pid, uint256 maxNum, uint256 price, uint256 limitPerAccount);
    event SetPoolRoot(uint256 indexed pid, bytes32 root);
    event MintNFT(uint256 indexed pid, address indexed account, uint256 tokenId, uint256 payAmount);
    event Withdraw(address indexed account, uint256 amount);
    event Paused(uint256 indexed pid);
    event Unpaused(uint256 indexed pid);

    constructor(IERC721 _nft) public {
        nft = _nft;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(OPERATOR_ROLE, _msgSender());
        _setupRole(TREASURY_ROLE, _msgSender());
    }

    modifier onlyOperator() {

        require(hasRole(OPERATOR_ROLE, _msgSender()), "NFTFactory::caller is not operator");
        _;
    }

    modifier onlyTreasury() {

        require(hasRole(TREASURY_ROLE, _msgSender()), "NFTFactory::caller is not treasury");
        _;
    }

    function addPool(uint256 _maxNum, bool _paused, uint256 _price, uint256 _limitPerAccount, bytes32 _root) external onlyOperator {

        require(_limitPerAccount > 0, "NFTFactory::addPool: Limit per account must great than zero");
        require(_maxNum > 0, "NFTFactory::addPool: Max num must be higher than zero");

        pools.push(PoolInfo({
        maxNum : _maxNum,
        supply : 0,
        paused : _paused,
        price : _price, // allow to zero
        root : _root,
        limitPerAccount : _limitPerAccount
        }));

        emit NewPool(pools.length.sub(1), _maxNum, _paused, _price, _root, _limitPerAccount);
    }

    function poolInfo(uint256 _pid) external view returns (PoolInfo memory) {

        return pools[_pid];
    }

    function userInfo(uint256 _pid, address account) external view returns (UserInfo memory) {

        return users[_pid][account];
    }

    function poolLength() external view returns (uint256) {

        return pools.length;
    }

    function mintNFT(uint256 _pid, uint256 _num, bytes32[] calldata _proof) external payable nonReentrant {

        address account = _msgSender();
        PoolInfo storage pool = pools[_pid];

        require(!pool.paused, "NFTFactory::mintNFT: Has paused");
        require(MerkleProof.verify(_proof, pool.root, keccak256(abi.encodePacked(account))), "NFTFactory::mintNFT: Not in whitelist");
        require(_num > 0, "NFTFactory:mintNFT: num must be great than zero");
        require(pool.supply.add(_num) <= pool.maxNum, "NFTFactory:mintNFT: Pool cap exceeded");
        require(pool.price.mul(_num) == msg.value, "NFTFactory::mintNFT: Pay amount error");

        UserInfo storage userinfo = users[_pid][account];
        require(userinfo.claimedNum.add(_num) <= pool.limitPerAccount, "NFTFactory::mintNFT: Claim num exceeded");

        for (uint256 i = 0; i < _num; i++) {
            uint256 tokenId = nft.totalSupply().add(1);

            pool.supply = pool.supply.add(1);
            userinfo.claimedNum = userinfo.claimedNum.add(1);
            nft.safeMint(account, tokenId);

            emit MintNFT(_pid, account, tokenId, pool.price);
        }
    }

    function mintAirdrop(uint256 _pid, address[] calldata _accounts) external onlyOperator {

        PoolInfo storage pool = pools[_pid];
        require(!pool.paused, "NFTFactory::mintAirdrop: Has paused");
        require(_accounts.length > 0, "NFTFactory::mintAirdrop: Accounts is empty");
        require(pool.supply.add(_accounts.length) <= pool.maxNum, "NFTFactory:mintAirdrop: Pool cap exceeded");

        for (uint256 i = 0; i < _accounts.length; i++) {
            address account = _accounts[i];
            uint256 tokenId = nft.totalSupply().add(1);

            UserInfo storage userinfo = users[_pid][account];
            pool.supply = pool.supply.add(1);
            userinfo.claimedNum = userinfo.claimedNum.add(1);
            nft.safeMint(account, tokenId);

            emit MintNFT(_pid, account, tokenId, 0);
        }
    }

    function setPoolMaxNumAndLimit(uint256 _pid, uint256 _maxNum, uint256 _price, uint256 _limitPerAccount) external onlyOperator {

        PoolInfo storage pool = pools[_pid];

        require(pool.paused, "NFTFactory::setPoolMaxNumAndLimit: Has started");
        require(_limitPerAccount > 0, "NFTFactory::setPoolMaxNumAndLimit: Limit must great than zero");
        require(_maxNum > 0, "NFTFactory::setPoolMaxNumAndLimit: Max num must be higher than zero");
        require(_maxNum >= pool.supply, "NFTFactory::setPoolMaxNumAndLimit: Max num cap exceeded");

        pool.maxNum = _maxNum;
        pool.price = _price;
        pool.limitPerAccount = _limitPerAccount;

        emit ChangePoolMaxAndLimit(_pid, _maxNum, _price, _limitPerAccount);
    }

    function setPoolRoot(uint256 _pid, bytes32 _root) external onlyOperator {

        require(pools[_pid].paused, "NFTFactory::setPoolRoot: Has started");

        pools[_pid].root = _root;
        emit SetPoolRoot(_pid, _root);
    }

    function pause(uint256 _pid) external onlyOperator {

        require(!pools[_pid].paused, "NFTFactory::pause: Has paused");

        pools[_pid].paused = true;
        emit Paused(_pid);
    }

    function unpause(uint256 _pid) external onlyOperator {

        require(pools[_pid].paused, "NFTFactory::pause: Has started");

        pools[_pid].paused = false;
        emit Unpaused(_pid);
    }

    function totalMaxNum() public view returns (uint256) {

        uint256 maxNum;
        for (uint256 i = 0; i < pools.length; i++) {
            maxNum = maxNum.add(pools[i].maxNum);
        }
        return maxNum;
    }

    function totalSupply() public view returns (uint256) {

        uint256 supply;
        for (uint256 i = 0; i < pools.length; i++) {
            supply = supply.add(pools[i].supply);
        }
        return supply;
    }

    function withdrawETH() public onlyTreasury {

        uint256 balance = address(this).balance;
        Address.sendValue(msg.sender, balance);

        emit Withdraw(msg.sender, balance);
    }
}