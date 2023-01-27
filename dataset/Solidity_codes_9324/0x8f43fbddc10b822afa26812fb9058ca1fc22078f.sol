



pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

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

library Clones {

    function clone(address master) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address master, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address master, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address master, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(master, salt, address(this));
    }
}





pragma solidity >=0.6.0 <0.8.0;

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



contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}





pragma solidity 0.6.12;

interface IAllowlist {
    function getPoolAccountLimit(address poolAddress)
        external
        view
        returns (uint256);

    function getPoolCap(address poolAddress) external view returns (uint256);

    function verifyAddress(address account, bytes32[] calldata merkleProof)
        external
        returns (bool);
}





pragma solidity 0.6.12;


interface ISwap {
    function getA() external view returns (uint256);

    function getAPrecise() external view returns (uint256);

    function getAllowlist() external view returns (IAllowlist);

    function getToken(uint8 index) external view returns (IERC20);

    function getTokenIndex(address tokenAddress) external view returns (uint8);

    function getTokenBalance(uint8 index) external view returns (uint256);

    function getVirtualPrice() external view returns (uint256);

    function owner() external view returns (address);

    function isGuarded() external view returns (bool);

    function paused() external view returns (bool);

    function swapStorage()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function calculateSwap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx
    ) external view returns (uint256);

    function calculateTokenAmount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256);

    function calculateRemoveLiquidity(uint256 amount)
        external
        view
        returns (uint256[] memory);

    function calculateRemoveLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex
    ) external view returns (uint256 availableTokenAmount);

    function initialize(
        IERC20[] memory pooledTokens,
        uint8[] memory decimals,
        string memory lpTokenName,
        string memory lpTokenSymbol,
        uint256 a,
        uint256 fee,
        uint256 adminFee,
        address lpTokenTargetAddress
    ) external;

    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    function addLiquidity(
        uint256[] calldata amounts,
        uint256 minToMint,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256[] calldata minAmounts,
        uint256 deadline
    ) external returns (uint256[] memory);

    function removeLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex,
        uint256 minAmount,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidityImbalance(
        uint256[] calldata amounts,
        uint256 maxBurnAmount,
        uint256 deadline
    ) external returns (uint256);
}





pragma solidity 0.6.12;


interface IMetaSwap {
    function getA() external view returns (uint256);

    function getToken(uint8 index) external view returns (IERC20);

    function getTokenIndex(address tokenAddress) external view returns (uint8);

    function getTokenBalance(uint8 index) external view returns (uint256);

    function getVirtualPrice() external view returns (uint256);

    function isGuarded() external view returns (bool);

    function metaSwapStorage()
        external
        view
        returns (
            address baseSwap,
            uint256 baseVirtualPrice,
            uint256 baseCacheLastUpdated
        );

    function calculateSwap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx
    ) external view returns (uint256);

    function calculateSwapUnderlying(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx
    ) external view returns (uint256);

    function calculateTokenAmount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256);

    function calculateRemoveLiquidity(uint256 amount)
        external
        view
        returns (uint256[] memory);

    function calculateRemoveLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex
    ) external view returns (uint256 availableTokenAmount);

    function initialize(
        IERC20[] memory _pooledTokens,
        uint8[] memory decimals,
        string memory lpTokenName,
        string memory lpTokenSymbol,
        uint256 _a,
        uint256 _fee,
        uint256 _adminFee,
        address lpTokenTargetAddress
    ) external;

    function initializeMetaSwap(
        IERC20[] memory _pooledTokens,
        uint8[] memory decimals,
        string memory lpTokenName,
        string memory lpTokenSymbol,
        uint256 _a,
        uint256 _fee,
        uint256 _adminFee,
        address lpTokenTargetAddress,
        ISwap baseSwap
    ) external;

    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    function swapUnderlying(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    function addLiquidity(
        uint256[] calldata amounts,
        uint256 minToMint,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256[] calldata minAmounts,
        uint256 deadline
    ) external returns (uint256[] memory);

    function removeLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex,
        uint256 minAmount,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidityImbalance(
        uint256[] calldata amounts,
        uint256 maxBurnAmount,
        uint256 deadline
    ) external returns (uint256);
}





pragma solidity 0.6.12;



interface IMetaSwapDeposit {
    function initialize(
        ISwap _baseSwap,
        IMetaSwap _metaSwap,
        IERC20 _metaLPToken
    ) external;
}





pragma solidity ^0.6.0;

interface IPoolRegistry {

    struct PoolInputData {
        address poolAddress;
        uint8 typeOfAsset;
        bytes32 poolName;
        address targetAddress;
        address metaSwapDepositAddress;
        bool isSaddleApproved;
        bool isRemoved;
        bool isGuarded;
    }

    struct PoolData {
        address poolAddress;
        address lpToken;
        uint8 typeOfAsset;
        bytes32 poolName;
        address targetAddress;
        IERC20[] tokens;
        IERC20[] underlyingTokens;
        address basePoolAddress;
        address metaSwapDepositAddress;
        bool isSaddleApproved;
        bool isRemoved;
        bool isGuarded;
    }

    struct SwapStorageData {
        uint256 initialA;
        uint256 futureA;
        uint256 initialATime;
        uint256 futureATime;
        uint256 swapFee;
        uint256 adminFee;
        address lpToken;
    }


    function poolsIndexOfPlusOne(address poolAddress)
        external
        returns (uint256);

    function poolsIndexOfNamePlusOne(bytes32 poolName)
        external
        returns (uint256);


    function addPool(PoolInputData memory inputData) external payable;

    function addCommunityPool(PoolData memory data) external payable;

    function approvePool(address poolAddress) external payable;

    function updatePool(PoolData memory poolData) external payable;

    function removePool(address poolAddress) external payable;

    function getPoolData(address poolAddress)
        external
        view
        returns (PoolData memory);

    function getPoolDataAtIndex(uint256 index)
        external
        view
        returns (PoolData memory);

    function getPoolDataByName(bytes32 poolName)
        external
        view
        returns (PoolData memory);

    function getVirtualPrice(address poolAddress)
        external
        view
        returns (uint256);

    function getA(address poolAddress) external view returns (uint256);

    function getPaused(address poolAddress) external view returns (bool);

    function getSwapStorage(address poolAddress)
        external
        view
        returns (SwapStorageData memory swapStorageData);

    function getTokens(address poolAddress)
        external
        view
        returns (IERC20[] memory);

    function getUnderlyingTokens(address poolAddress)
        external
        view
        returns (IERC20[] memory);

    function getPoolsLength() external view returns (uint256);

    function getEligiblePools(address from, address to)
        external
        view
        returns (address[] memory eligiblePools);

    function getTokenBalances(address poolAddress)
        external
        view
        returns (uint256[] memory balances);

    function getUnderlyingTokenBalances(address poolAddress)
        external
        view
        returns (uint256[] memory balances);
}





pragma solidity ^0.6.0;

interface IMasterRegistry {

    struct ReverseRegistryData {
        bytes32 name;
        uint256 version;
    }


    function addRegistry(bytes32 registryName, address registryAddress)
        external
        payable;

    function resolveNameToLatestAddress(bytes32 name)
        external
        view
        returns (address);

    function resolveNameAndVersionToAddress(bytes32 name, uint256 version)
        external
        view
        returns (address);

    function resolveNameToAllAddresses(bytes32 name)
        external
        view
        returns (address[] memory);

    function resolveAddressToRegistryData(address registryAddress)
        external
        view
        returns (
            bytes32 name,
            uint256 version,
            bool isLatest
        );
}





pragma solidity 0.6.12;








contract PermissionlessDeployer is AccessControl {
    IMasterRegistry public immutable MASTER_REGISTRY;
    bytes32 public constant POOL_REGISTRY_NAME =
        0x506f6f6c52656769737472790000000000000000000000000000000000000000;

    bytes32 public constant SADDLE_MANAGER_ROLE =
        keccak256("SADDLE_MANAGER_ROLE");

    address public targetLPToken;
    address public targetSwap;
    address public targetMetaSwap;
    address public targetMetaSwapDeposit;
    string public constant LP_TOKEN_NAME0 = "Saddle ";
    string public constant LP_TOKEN_NAME1 = " LP Token";

    IPoolRegistry public poolRegistryCached;

    event NewSwapPool(
        address indexed deployer,
        address swapAddress,
        IERC20[] pooledTokens
    );

    event NewClone(address indexed target, address cloneAddress);

    event PoolRegistryUpdated(address indexed poolRegistry);
    event TargetLPTokenUpdated(address indexed target);
    event TargetSwapUpdated(address indexed target);
    event TargetMetaSwapUpdated(address indexed target);
    event TargetMetaSwapDepositUpdated(address indexed target);

    struct DeploySwapInput {
        bytes32 poolName; // name of the pool
        IERC20[] tokens; // array of addresses of the tokens in the pool
        uint8[] decimals; // array of decimals of the tokens in the pool
        string lpTokenSymbol; // symbol of the LPToken
        uint256 a; // a-parameter of the pool
        uint256 fee; // trading fee of the pool
        uint256 adminFee; // admin fee of the pool
        address owner; // owner address of the pool
        uint8 typeOfAsset; // USD/BTC/ETH/OTHER
    }

    struct DeployMetaSwapInput {
        bytes32 poolName; // name of the pool
        IERC20[] tokens; // array of addresses of the tokens in the pool
        uint8[] decimals; // array of decimals of the tokens in the pool
        string lpTokenSymbol; // symbol of the LPToken
        uint256 a; // a-parameter of the pool
        uint256 fee; // trading fee of the pool
        uint256 adminFee; // admin fee of the pool
        address baseSwap; // address of the basepool
        address owner; // owner address of the pool
        uint8 typeOfAsset; // USD/BTC/ETH/OTHER
    }

    constructor(
        address admin,
        address _masterRegistry,
        address _targetLPToken,
        address _targetSwap,
        address _targetMetaSwap,
        address _targetMetaSwapDeposit
    ) public payable {
        require(admin != address(0), "admin == 0");
        require(_masterRegistry != address(0), "masterRegistry == 0");

        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(SADDLE_MANAGER_ROLE, msg.sender);

        _setTargetLPToken(_targetLPToken);
        _setTargetSwap(_targetSwap);
        _setTargetMetaSwap(_targetMetaSwap);
        _setTargetMetaSwapDeposit(_targetMetaSwapDeposit);

        MASTER_REGISTRY = IMasterRegistry(_masterRegistry);
        _updatePoolRegistryCache(_masterRegistry);
    }

    modifier onlyManager() {
        require(hasRole(SADDLE_MANAGER_ROLE, msg.sender), "only manager");
        _;
    }

    function clone(address target) public payable returns (address newClone) {
        newClone = Clones.clone(target);
        emit NewClone(target, newClone);
    }


    function deploySwap(DeploySwapInput memory input)
        external
        payable
        returns (address deployedSwap)
    {
        require(
            poolRegistryCached.poolsIndexOfNamePlusOne(input.poolName) == 0,
            "pool name already exists"
        );

        address swapClone = clone(targetSwap);

        ISwap(swapClone).initialize(
            input.tokens,
            input.decimals,
            string(
                abi.encodePacked(
                    LP_TOKEN_NAME0,
                    input.lpTokenSymbol,
                    LP_TOKEN_NAME1
                )
            ),
            input.lpTokenSymbol,
            input.a,
            input.fee,
            input.adminFee,
            targetLPToken
        );
        Ownable(swapClone).transferOwnership(input.owner);
        (, , , , , , address lpToken) = ISwap(swapClone).swapStorage();

        IPoolRegistry.PoolData memory poolData = IPoolRegistry.PoolData({
            poolAddress: swapClone,
            lpToken: lpToken,
            typeOfAsset: input.typeOfAsset,
            poolName: input.poolName,
            targetAddress: targetSwap,
            tokens: input.tokens,
            underlyingTokens: new IERC20[](0),
            basePoolAddress: address(0),
            metaSwapDepositAddress: address(0),
            isSaddleApproved: false,
            isRemoved: false,
            isGuarded: false
        });

        emit NewSwapPool(msg.sender, swapClone, input.tokens);

        poolRegistryCached.addCommunityPool(poolData);
        return swapClone;
    }

    function deployMetaSwap(DeployMetaSwapInput memory input)
        external
        payable
        returns (address deployedMetaSwap, address deployedMetaSwapDeposit)
    {
        require(
            poolRegistryCached.poolsIndexOfNamePlusOne(input.poolName) == 0,
            "pool name already exists"
        );

        deployedMetaSwap = clone(targetMetaSwap);
        IMetaSwap(deployedMetaSwap).initializeMetaSwap(
            input.tokens,
            input.decimals,
            string(
                abi.encodePacked(
                    LP_TOKEN_NAME0,
                    input.lpTokenSymbol,
                    LP_TOKEN_NAME1
                )
            ),
            input.lpTokenSymbol,
            input.a,
            input.fee,
            input.adminFee,
            targetLPToken,
            ISwap(input.baseSwap)
        );
        (, , , , , , address lpToken) = ISwap(deployedMetaSwap).swapStorage();
        Ownable(deployedMetaSwap).transferOwnership(input.owner);

        deployedMetaSwapDeposit = clone(targetMetaSwapDeposit);
        IMetaSwapDeposit(deployedMetaSwapDeposit).initialize(
            ISwap(input.baseSwap),
            IMetaSwap(deployedMetaSwap),
            IERC20(lpToken)
        );

        IERC20[] memory baseTokens = poolRegistryCached.getTokens(
            input.baseSwap
        ); // revert if baseSwap is not registered
        IERC20[] memory underlyingTokens = new IERC20[](
            input.tokens.length - 1 + baseTokens.length
        );
        uint256 metaLPTokenIndex = input.tokens.length - 1;
        for (uint256 i = 0; i < metaLPTokenIndex; i++) {
            underlyingTokens[i] = input.tokens[i];
        }
        for (uint256 i = metaLPTokenIndex; i < underlyingTokens.length; i++) {
            underlyingTokens[i] = baseTokens[i - metaLPTokenIndex];
        }

        IPoolRegistry.PoolData memory poolData = IPoolRegistry.PoolData({
            poolAddress: deployedMetaSwap,
            lpToken: lpToken,
            typeOfAsset: input.typeOfAsset,
            poolName: input.poolName,
            targetAddress: targetSwap,
            tokens: input.tokens,
            underlyingTokens: underlyingTokens,
            basePoolAddress: input.baseSwap,
            metaSwapDepositAddress: deployedMetaSwapDeposit,
            isSaddleApproved: false,
            isRemoved: false,
            isGuarded: false
        });

        emit NewSwapPool(msg.sender, deployedMetaSwap, input.tokens);
        emit NewSwapPool(msg.sender, deployedMetaSwapDeposit, underlyingTokens);

        poolRegistryCached.addCommunityPool(poolData);
    }

    function updatePoolRegistryCache() external {
        _updatePoolRegistryCache(address(MASTER_REGISTRY));
    }

    function _updatePoolRegistryCache(address masterRegistry) internal {
        poolRegistryCached = IPoolRegistry(
            IMasterRegistry(masterRegistry).resolveNameToLatestAddress(
                POOL_REGISTRY_NAME
            )
        );
    }

    function setTargetLPToken(address _targetLPToken)
        external
        payable
        onlyManager
    {
        _setTargetLPToken(_targetLPToken);
    }

    function _setTargetLPToken(address _targetLPToken) internal {
        require(
            address(_targetLPToken) != address(0),
            "Target LPToken cannot be 0"
        );
        targetLPToken = _targetLPToken;
        emit TargetLPTokenUpdated(_targetLPToken);
    }

    function setTargetSwap(address _targetSwap) external payable onlyManager {
        _setTargetSwap(_targetSwap);
    }

    function _setTargetSwap(address _targetSwap) internal {
        require(address(_targetSwap) != address(0), "Target Swap cannot be 0");
        targetSwap = _targetSwap;
        emit TargetSwapUpdated(_targetSwap);
    }

    function setTargetMetaSwap(address _targetMetaSwap)
        public
        payable
        onlyManager
    {
        _setTargetMetaSwap(_targetMetaSwap);
    }

    function _setTargetMetaSwap(address _targetMetaSwap) internal {
        require(
            address(_targetMetaSwap) != address(0),
            "Target MetaSwap cannot be 0"
        );
        targetMetaSwap = _targetMetaSwap;
        emit TargetMetaSwapUpdated(_targetMetaSwap);
    }

    function setTargetMetaSwapDeposit(address _targetMetaSwapDeposit)
        external
        payable
        onlyManager
    {
        _setTargetMetaSwapDeposit(_targetMetaSwapDeposit);
    }

    function _setTargetMetaSwapDeposit(address _targetMetaSwapDeposit)
        internal
    {
        require(
            address(_targetMetaSwapDeposit) != address(0),
            "Target MetaSwapDeposit cannot be 0"
        );
        targetMetaSwapDeposit = _targetMetaSwapDeposit;
        emit TargetMetaSwapDepositUpdated(_targetMetaSwapDeposit);
    }
}