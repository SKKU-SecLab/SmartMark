



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



pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}




pragma solidity ^0.6.2;

abstract contract IOracle {
    function update() external virtual returns (uint256);

    function pairAddress() external view virtual returns (address);
}



pragma solidity ^0.6.2;

abstract contract IWETH {
    function deposit() public payable virtual;
}



pragma solidity ^0.6.2;

abstract contract IPriceConsumerV3 {
    function getLatestPrice() public view virtual returns (int256);
}




pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

abstract contract IPool {
    function stake(uint256 value) external virtual;

    function unstake(uint256 value) external virtual;

    function harvest(uint256 value) public virtual;

    function claim(uint256 value) public virtual;

    function zapStake(uint256 value, address userAddress) external virtual;
}



pragma solidity >=0.5.0;


library UniswapV2Library {

    using SafeMath for uint256;

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                    )
                )
            )
        );
    }

    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) =
            IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {

        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) =
                getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) =
                getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}



pragma solidity ^0.6.2;










contract CookDistribution is Ownable, AccessControl {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event AllocationRegistered(address indexed beneficiary, uint256 amount);
    event TokensWithdrawal(address userAddress, uint256 amount);

    struct Allocation {
        uint256 amount;
        uint256 released;
        bool blackListed;
        bool isRegistered;
    }

    mapping(address => Allocation) private _beneficiaryAllocations;

    mapping(uint256 => uint256) public _oraclePriceFeed;

    address[] private _allBeneficiary;

    uint256 private _start;

    uint256 public _duration;

    uint32 public _interval;

    uint256 public _advancePercentage;

    uint256 public _lastPriceUnlockDay;

    uint32 public _nextPriceUnlockStep;

    uint32 public _maxPriceUnlockMoveStep;

    IERC20 private _token;

    IOracle private _oracle;
    IPriceConsumerV3 private _priceConsumer;

    uint32 private constant SECONDS_PER_DAY = 86400; /* 86400 seconds in a day */

    uint256[] private _priceKey;
    uint256[] private _percentageValue;
    mapping(uint256 => uint256) private _pricePercentageMapping;

    bool public _pauseClaim;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    constructor(
        IERC20 token_,
        address[] memory beneficiaries_,
        uint256[] memory amounts_,
        uint256 start, // in unix
        uint256 duration, // in day
        uint32 interval, // in day
        address oracle_,
        address priceConsumer_
    ) public {
        for (uint256 i = 0; i < beneficiaries_.length; i++) {
            require(
                beneficiaries_[i] != address(0),
                "Beneficiary cannot be 0 address."
            );

            require(amounts_[i] > 0, "Cannot allocate zero amount.");

            _allBeneficiary.push(beneficiaries_[i]);

            _beneficiaryAllocations[beneficiaries_[i]] = Allocation(
                amounts_[i],
                0,
                false,
                true
            );

            emit AllocationRegistered(beneficiaries_[i], amounts_[i]);
        }

        _token = token_;
        _duration = duration;
        _start = start;
        _interval = interval;
        _advancePercentage = 1;
        _oracle = IOracle(oracle_);
        _priceConsumer = IPriceConsumerV3(priceConsumer_);
        _lastPriceUnlockDay = 0;
        _nextPriceUnlockStep = 0;
        _maxPriceUnlockMoveStep = 1;
        _pauseClaim = false;

        _priceKey = [500000, 800000, 1100000, 1400000, 1700000, 2000000, 2300000, 2600000, 2900000, 3200000, 3500000, 3800000, 4100000,
                    4400000, 4700000, 5000000, 5300000, 5600000, 5900000, 6200000, 6500000];
        _percentageValue = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100];

        for (uint256 i = 0; i < _priceKey.length; i++) {
            _pricePercentageMapping[_priceKey[i]] = _percentageValue[i];
        }

        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
    }

    fallback() external payable {
        revert();
    }

    function start() public view returns (uint256) {

        return _start;
    }

    function duration() public view returns (uint256) {

        return _duration;
    }

    function getRegisteredStatus(address userAddress) public view returns (bool) {

        return _beneficiaryAllocations[userAddress].isRegistered;
    }

    function getUserVestingAmount(address userAddress) public view returns (uint256) {

        return _beneficiaryAllocations[userAddress].amount;
    }
    
    function getOraclePriceFeed(uint256 day) public view returns (uint256) {

        return _oraclePriceFeed[day];
    }

    function getUserAvailableAmount(address userAddress, uint256 onDayOrToday) public view returns (uint256) {

        uint256 avalible =
            _getVestedAmount(userAddress, onDayOrToday).sub(
                _beneficiaryAllocations[userAddress].released
            );
        return avalible;
    }

    function getUserVestedAmount(address userAddress, uint256 onDayOrToday)
        public
        view
        returns (uint256 amountVested)
    {

        return _getVestedAmount(userAddress, onDayOrToday);
    }

    function today() public view virtual returns (uint256 dayNumber) {

        return uint256(block.timestamp / SECONDS_PER_DAY);
    }

    function startDay() public view returns (uint256) {

        return uint256(_start / SECONDS_PER_DAY);
    }

    function _effectiveDay(uint256 onDayOrToday) internal view returns (uint256) {

        return onDayOrToday == 0 ? today() : onDayOrToday;
    }

    function _getVestedAmount(address userAddress, uint256 onDayOrToday) internal view returns (uint256) {

        uint256 onDay = _effectiveDay(onDayOrToday); // day

        if (onDay >= (startDay() + _duration)) {
            return _beneficiaryAllocations[userAddress].amount;
        }
        else if (onDay < startDay()) {
            return 0;
        }
        else {
            uint256 daysVested = onDay - startDay();
            uint256 effectiveDaysVested = (daysVested / _interval) * _interval;


            uint256 vested = 0;

            if (
                _beneficiaryAllocations[userAddress]
                    .amount
                    .mul(effectiveDaysVested)
                    .div(_duration) >
                _beneficiaryAllocations[userAddress]
                    .amount
                    .mul(_advancePercentage)
                    .div(100)
            ) {
                vested = _beneficiaryAllocations[userAddress]
                    .amount
                    .mul(effectiveDaysVested)
                    .div(_duration);
            } else {
                vested = _beneficiaryAllocations[userAddress]
                    .amount
                    .mul(_advancePercentage)
                    .div(100);
            }

            return vested;
        }
    }

    function withdraw(uint256 withdrawAmount) public {

        address userAddress = msg.sender;

        require(
            _beneficiaryAllocations[userAddress].isRegistered == true,
            "You have to be a registered address."
        );

        require(
            _beneficiaryAllocations[userAddress].blackListed == false,
            "Your address is blacklisted."
        );

        require(
            _pauseClaim == false,
            "Cook token is not claimable due to emgergency"
        );

        require(
            getUserAvailableAmount(userAddress, today()) >= withdrawAmount,
            "insufficient avalible cook balance"
        );

        _beneficiaryAllocations[userAddress].released = _beneficiaryAllocations[
            userAddress
        ]
            .released
            .add(withdrawAmount);

        _token.safeTransfer(userAddress, withdrawAmount);

        emit TokensWithdrawal(userAddress, withdrawAmount);
    }

    function _getPricePercentage(uint256 priceKey) internal view returns (uint256) {

        return _pricePercentageMapping[priceKey];
    }

    function _calWethAmountToPairCook(uint256 cookAmount) internal returns (uint256, address) {

        IUniswapV2Pair lpPair = IUniswapV2Pair(_oracle.pairAddress());
        uint256 reserve0;
        uint256 reserve1;
        address weth;

        if (lpPair.token0() == address(_token)) {
            (reserve0, reserve1, ) = lpPair.getReserves();
            weth = lpPair.token1();
        } else {
            (reserve1, reserve0, ) = lpPair.getReserves();
            weth = lpPair.token0();
        }

        uint256 wethAmount =
            (reserve0 == 0 && reserve1 == 0)
                ? cookAmount
                : UniswapV2Library.quote(cookAmount, reserve0, reserve1);

        return (wethAmount, weth);
    }

    function zapLP(uint256 cookAmount, address poolAddress) external {

        _zapLP(cookAmount, poolAddress, false);
    }

    function _zapLP(uint256 cookAmount, address poolAddress, bool isWithEth) internal {

        address userAddress = msg.sender;
        _checkValidZap(userAddress, cookAmount);

        uint256 newUniv2 = 0;

        (, newUniv2) = addLiquidity(cookAmount);

        IERC20(_oracle.pairAddress()).approve(poolAddress, newUniv2);

        IPool(poolAddress).zapStake(newUniv2, userAddress);
    }

    function _checkValidZap(address userAddress, uint256 cookAmount) internal {

        require(_beneficiaryAllocations[userAddress].isRegistered == true, "You have to be a registered address.");

        require(
            _beneficiaryAllocations[userAddress].blackListed == false,
            "Your address is blacklisted"
        );

        require(_pauseClaim == false, "Cook token can not be zap.");

        require(cookAmount > 0, "zero zap amount");

        require(
            getUserAvailableAmount(userAddress, today()) >= cookAmount, "insufficient avalible cook balance"
        );

        _beneficiaryAllocations[userAddress].released = _beneficiaryAllocations[userAddress].released.add(cookAmount);
    }

    function addLiquidity(uint256 cookAmount) internal returns (uint256, uint256) {

        (uint256 wethAmount, ) = _calWethAmountToPairCook(cookAmount);
        _token.safeTransfer(_oracle.pairAddress(), cookAmount);

        IUniswapV2Pair lpPair = IUniswapV2Pair(_oracle.pairAddress());
        if (lpPair.token0() == address(_token)) {
            require(IERC20(lpPair.token1()).balanceOf(msg.sender) >= wethAmount, "insufficient weth balance");
            require(IERC20(lpPair.token1()).allowance(msg.sender, address(this)) >= wethAmount, "insufficient weth allowance");
            IERC20(lpPair.token1()).safeTransferFrom(
                msg.sender,
                _oracle.pairAddress(),
                wethAmount
            );
        } else if (lpPair.token1() == address(_token)) {
            require(IERC20(lpPair.token0()).balanceOf(msg.sender) >= wethAmount, "insufficient weth balance");
            require(IERC20(lpPair.token0()).allowance(msg.sender, address(this)) >= wethAmount, "insufficient weth allowance");
            IERC20(lpPair.token0()).safeTransferFrom(msg.sender, _oracle.pairAddress(), wethAmount);
        }

        return (wethAmount, lpPair.mint(address(this)));
    }

    function zapCook(uint256 cookAmount, address cookPoolAddress) external {

        address userAddress = msg.sender;
        _checkValidZap(userAddress, cookAmount);
        IERC20(address(_token)).approve(cookPoolAddress, cookAmount);
        IPool(cookPoolAddress).zapStake(cookAmount, userAddress);
    }

    function setPriceBasedMaxStep(uint32 newMaxPriceBasedStep) public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        _maxPriceUnlockMoveStep = newMaxPriceBasedStep;
    }

    function getPriceBasedMaxSetp() public view returns (uint32) {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        return _maxPriceUnlockMoveStep;
    }

    function getNextPriceUnlockStep() public view returns (uint32) {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        return _nextPriceUnlockStep;
    }

    function addAddressWithAllocation(address beneficiaryAddress, uint256 amount ) public  {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");

        require(
            _beneficiaryAllocations[beneficiaryAddress].isRegistered == false,
            "The address to be added already exisits."
        );

        _beneficiaryAllocations[beneficiaryAddress].isRegistered = true;
        _beneficiaryAllocations[beneficiaryAddress] = Allocation( amount, 0, false, true
        );

        emit AllocationRegistered(beneficiaryAddress, amount);
    }

    function addMultipleAddressWithAllocations(address[] memory beneficiaryAddresses, uint256[] memory amounts) public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");

        require(beneficiaryAddresses.length > 0 && amounts.length > 0 && beneficiaryAddresses.length == amounts.length,
            "Inconsistent length input"
        );

        for (uint256 i = 0; i < beneficiaryAddresses.length; i++) {
            require(_beneficiaryAllocations[beneficiaryAddresses[i]].isRegistered == false,
                "The address to be added already exisits."
            );
            _beneficiaryAllocations[beneficiaryAddresses[i]].isRegistered = true;
            _beneficiaryAllocations[beneficiaryAddresses[i]] = Allocation(amounts[i], 0, false, true);

            emit AllocationRegistered(beneficiaryAddresses[i], amounts[i]);
        }
    }

    function updatePricePercentage(uint256[] memory priceKey_, uint256[] memory percentageValue_) public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");

        require(
            priceKey_.length == percentageValue_.length && priceKey_.length > 0,
            "length inconsistency."
        );

        _priceKey = priceKey_;
        _percentageValue = percentageValue_;

        for (uint256 i = 0; i < _priceKey.length; i++) {
            _pricePercentageMapping[_priceKey[i]] = _percentageValue[i];
        }
    }

    function getTotalAvailable() public view returns (uint256) {uint256 totalAvailable = 0;

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");

        for (uint256 i = 0; i < _allBeneficiary.length; ++i) {
            totalAvailable += getUserAvailableAmount(
                _allBeneficiary[i],
                today()
            );
        }

        return totalAvailable;
    }

    function getLatestSevenSMA() public view returns (uint256) {

        uint256 priceSum = uint256(0);
        uint256 priceCount = uint256(0);
        for (uint32 i = 0; i < 7; ++i) {
            if (_oraclePriceFeed[today() - i] != 0) {
                priceSum = priceSum + _oraclePriceFeed[today() - i];
                priceCount += 1;
            }
        }

        uint256 sevenSMA = 0;
        if (priceCount == 7) {
            sevenSMA = priceSum.div(priceCount);
        }
        return sevenSMA;
    }

    function updatePriceFeed() public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");

        uint256 cookPrice = _oracle.update();

        uint256 ethPrice = uint256(_priceConsumer.getLatestPrice());

        uint256 price = cookPrice.mul(ethPrice).div(10**18);

        _oraclePriceFeed[today()] = price;

        if (today() >= _lastPriceUnlockDay.add(7)) {
            uint256 sevenSMA = getLatestSevenSMA();
            uint256 priceRef = 0;

            for (uint32 i = 0; i < _priceKey.length; ++i) {
                if (sevenSMA >= _priceKey[i]) {
                    priceRef = _pricePercentageMapping[_priceKey[i]];
                }
            }

            if (priceRef > _advancePercentage) {
                if (_nextPriceUnlockStep >= _percentageValue.length) {
                    _nextPriceUnlockStep = uint32(_percentageValue.length - 1);
                }

                _advancePercentage = _pricePercentageMapping[
                    _priceKey[_nextPriceUnlockStep]
                ];

                _nextPriceUnlockStep =
                    _nextPriceUnlockStep +
                    _maxPriceUnlockMoveStep;

                _lastPriceUnlockDay = today();
            }
        }
    }

    function blacklistAddress(address userAddress) public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        _beneficiaryAllocations[userAddress].blackListed = true;
    }

    function removeAddressFromBlacklist(address userAddress) public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        _beneficiaryAllocations[userAddress].blackListed = false;
    }

    function pauseClaim() public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        _pauseClaim = true;
    }

    function resumeCliam() public {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a manager");
        _pauseClaim = false;
    }

    function emergencyWithdraw(uint256 amount) public onlyOwner {

        _token.safeTransfer(msg.sender, amount);
    }

    function getManagerRole() public returns (bytes32) {

        return MANAGER_ROLE;
    }
}