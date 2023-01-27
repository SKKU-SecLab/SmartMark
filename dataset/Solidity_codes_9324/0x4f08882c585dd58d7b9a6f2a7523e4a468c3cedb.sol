
pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;


interface IExperiPie is IERC20 {

    function setEntryFee(uint256 _fee) external;


    function getEntryFee() external view returns (uint256);


    function setExitFee(uint256 _fee) external;


    function getExitFee() external view returns (uint256);


    function setAnnualizedFee(uint256 _fee) external;


    function getAnnualizedFee() external view returns (uint256);


    function setFeeBeneficiary(address _beneficiary) external;


    function getFeeBeneficiary() external view returns (address);


    function setEntryFeeBeneficiaryShare(uint256 _share) external;


    function getEntryFeeBeneficiaryShare() external view returns (uint256);


    function setExitFeeBeneficiaryShare(uint256 _share) external;


    function getExitFeeBeneficiaryShare() external view returns (uint256);


    function calcOutStandingAnnualizedFee() external view returns (uint256);


    function chargeOutstandingAnnualizedFee() external;


    function joinPool(uint256 _amount) external;


    function exitPool(uint256 _amount) external;


    function getLock() external view returns (bool);


    function getLockBlock() external view returns (uint256);


    function setLock(uint256 _lock) external;


    function getCap() external view returns (uint256);


    function setCap(uint256 _maxCap) external returns (uint256);


    function balance(address _token) external view returns (uint256);


    function getTokens() external view returns (address[] memory);


    function addToken(address _token) external;


    function removeToken(address _token) external;


    function getTokenInPool(address _token) external view returns (bool);


    function mint(address _receiver, uint256 _amount) external;


    function burn(address _from, uint256 _amount) external;


    function calcTokensForAmount(uint256 _amount)
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);


    function calcTokensForAmountExit(uint256 _amount)
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);


    function call(
        address[] memory _targets,
        bytes[] memory _calldata,
        uint256[] memory _values
    ) external;


    function addCaller(address _caller) external;


    function removeCaller(address _caller) external;


    function canCall(address _caller) external view returns (bool);


    function getCallers() external view returns (address[] memory);



    function transferOwnership(address _newOwner) external;


    function owner() external view returns (address);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function initialize(
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) external;

}// MIT

pragma solidity ^0.7.0;

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
}// MIT
pragma solidity ^0.7.1;

interface PieRecipe {

    function toPie(address _pie, uint256 _poolAmount) external payable;


    function calcToPie(address _pie, uint256 _poolAmount)
        external
        view
        returns (uint256);

}// MIT
pragma solidity ^0.7.1;



contract TestPieRecipe {

    using SafeMath for uint256;
    mapping(address => uint256) private balance;

    uint256 public calcToPieAmount;

    function toPie(address _pie, uint256 _poolAmount) public payable {

        IERC20 pie = IERC20(_pie);
        uint256 amount = calcToPie(_pie, _poolAmount);
        require(msg.value == amount, "Amount ETH too low");
        pie.transfer(msg.sender, _poolAmount);
    }

    function testSetCalcToPieAmount(uint256 _amount) external {

        calcToPieAmount = _amount;
    }

    function calcToPie(address _pie, uint256 _poolAmount)
        public
        view
        returns (uint256)
    {

        return calcToPieAmount;
    }
}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


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
}// MIT
pragma solidity ^0.7.1;


contract Oven is AccessControl {

    using SafeMath for uint256;

    event Deposit(address user, uint256 amount);
    event WithdrawETH(address user, uint256 amount, address receiver);
    event WithdrawOuput(address user, uint256 amount, address receiver);
    event Bake(address user, uint256 amount, uint256 price);

    bytes32 constant public CONTROLLER_ROLE = DEFAULT_ADMIN_ROLE;
    bytes32 constant public CAP_SETTER_ROLE = keccak256(abi.encode("CAP_SETTER"));
    bytes32 constant public BAKER_ROLE = keccak256(abi.encode("BAKER"));

    address payable constant public TOKEN_SAFE = 0xAF2fE0d4fe879066B2BaA68d9e56cC375DF22815;

    mapping(address => uint256) public ethBalanceOf;
    mapping(address => uint256) public outputBalanceOf;

    IERC20 public pie;
    PieRecipe public recipe;
    uint256 public cap;

    constructor(
        address _controller,
        address _capSetter,
        address _baker,
        address _pie,
        address _recipe
    ) public {
        _setupRole(CONTROLLER_ROLE, _controller);
        _setupRole(CAP_SETTER_ROLE, _capSetter);
        _setupRole(BAKER_ROLE, _baker);
        pie = IERC20(_pie);
        recipe = PieRecipe(_recipe);
    }

    modifier ovenIsReady {

        require(address(pie) != address(0), "PIE_NOT_SET");
        require(address(recipe) != address(0), "RECIPE_NOT_SET");
        _;
    }

    modifier onlyRole(bytes32 _role) {

        require(hasRole(_role, msg.sender), "AUTH_FAILED");
        _;
    }

    function bake(
        address[] calldata _receivers,
        uint256 _outputAmount,
        uint256 _maxPrice
    ) public ovenIsReady onlyRole(BAKER_ROLE) {

        uint256 realPrice = recipe.calcToPie(address(pie), _outputAmount);
        require(realPrice <= _maxPrice, "PRICE_ERROR");

        uint256 totalInputAmount = 0;
        for (uint256 i = 0; i < _receivers.length; i++) {

            uint256 userAmount = ethBalanceOf[_receivers[i]];
            if (totalInputAmount == realPrice) {
                break;
            } else if (totalInputAmount.add(userAmount) <= realPrice) {
                totalInputAmount = totalInputAmount.add(userAmount);
            } else {
                userAmount = realPrice.sub(totalInputAmount);
                totalInputAmount = totalInputAmount.add(userAmount);
            }

            ethBalanceOf[_receivers[i]] = ethBalanceOf[_receivers[i]].sub(
                userAmount
            );

            uint256 userBakeAmount = _outputAmount.mul(userAmount).div(
                realPrice
            );
            outputBalanceOf[_receivers[i]] = outputBalanceOf[_receivers[i]].add(
                userBakeAmount
            );

            emit Bake(_receivers[i], userBakeAmount, userAmount);
        }
        require(totalInputAmount == realPrice, "INSUFFICIENT_FUNDS");
        recipe.toPie{value: realPrice}(address(pie), _outputAmount);
    }

    function deposit() public payable ovenIsReady {

        ethBalanceOf[msg.sender] = ethBalanceOf[msg.sender].add(msg.value);
        require(address(this).balance <= cap, "MAX_CAP");
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {
        deposit();
    }

    function withdrawAll(address payable _receiver) external ovenIsReady {

        withdrawAllETH(_receiver);
        withdrawOutput(_receiver);
    }

    function withdrawAllETH(address payable _receiver) public ovenIsReady {

        withdrawETH(ethBalanceOf[msg.sender], _receiver);
    }

    function withdrawETH(uint256 _amount, address payable _receiver)
        public
        ovenIsReady
    {

        ethBalanceOf[msg.sender] = ethBalanceOf[msg.sender].sub(_amount);
        _receiver.transfer(_amount);
        emit WithdrawETH(msg.sender, _amount, _receiver);
    }

    function withdrawOutput(address _receiver) public ovenIsReady {

        uint256 _amount = outputBalanceOf[msg.sender];
        outputBalanceOf[msg.sender] = 0;
        pie.transfer(_receiver, _amount);
        emit WithdrawOuput(msg.sender, _amount, _receiver);
    }

    function setCap(uint256 _cap) external onlyRole(CAP_SETTER_ROLE) {

        cap = _cap;
    }

    function setPie(address _pie) public onlyRole(CONTROLLER_ROLE) {

        require(address(pie) == address(0), "PIE_ALREADY_SET");
        pie = IERC20(_pie);
    }

    function setRecipe(address _recipe) public onlyRole(CONTROLLER_ROLE) {

        require(address(recipe) == address(0), "RECIPE_ALREADY_SET");
        recipe = PieRecipe(_recipe);
    }

    function setPieAndRecipe(address _pie, address _recipe) external {

        setPie(_pie);
        setRecipe(_recipe);
    }

    function getCap() external view returns (uint256) {

        return cap;
    }

    function saveToken(address _token) external onlyRole(CONTROLLER_ROLE) {

        IERC20 token = IERC20(_token);

        token.transfer(
            TOKEN_SAFE,
            token.balanceOf(address(this))
        );
    }

    function saveETH() external onlyRole(CONTROLLER_ROLE) {

        TOKEN_SAFE.transfer(address(this).balance);
    }
}// MIT

pragma solidity ^0.7.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT
pragma solidity ^0.7.1;


contract OvenFactoryContract is Ownable {

    event OvenCreated(
        address Oven,
        address Controller,
        address Pie,
        address Recipe
    );

    address[] public ovens;
    mapping(address => bool) public isOven;
    address public defaultController;
    address public defaultBaker;
    address public defaultCapSetter;

    function setDefaultController(address _controller) external onlyOwner {

        defaultController = _controller;
    }

    function setDefaultBaker(address _baker) external onlyOwner {

        defaultBaker = _baker;
    }

    function setDefaultCapSetter(address _capSetter) external onlyOwner {

        defaultCapSetter = _capSetter;
    }

    function CreateEmptyOven() external {

        CreateOven(address(0), address(0));
    }

    function CreateOven(address _pie, address _recipe) public {

        require(defaultController != address(0), "CONTROLLER_NOT_SET");

        Oven oven = new Oven(
            address(this), address(this), defaultBaker, _pie, _recipe
        );
        ovens.push(address(oven));
        isOven[address(oven)] = true;

        oven.setCap(uint256(-1));

        oven.grantRole(oven.CAP_SETTER_ROLE(), defaultCapSetter);
        oven.grantRole(oven.CONTROLLER_ROLE(), defaultController);

        oven.renounceRole(oven.CAP_SETTER_ROLE(), address(this));
        oven.renounceRole(oven.CONTROLLER_ROLE(), address(this));

        emit OvenCreated(address(oven), defaultController, _pie, _recipe);
    }
}// MIT
pragma solidity ^0.7.1;


contract TestPie {

    using SafeMath for uint256;

    mapping(address => uint256) private balance;

    constructor(uint256 _supply, address _address) {
        balance[_address] = _supply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        balance[msg.sender] = balance[msg.sender].sub(_value);
        balance[_to] = balance[_to].add(_value);
        return true;
    }

    function balanceOf(address _address) public view returns (uint256) {

        return balance[_address];
    }
}// MIT
pragma solidity ^0.7.1;

interface IOven {

    function bake(
        address[] calldata _receivers,
        uint256 _outputAmount,
        uint256 _maxPrice
    ) external;


    function deposit() external payable;


    function withdrawAll(address payable _receiver) external;


    function withdrawAllETH(address payable _receiver) external;


    function withdrawETH(uint256 _amount, address payable _receiver) external;


    function withdrawOutput(address _receiver) external;


    function setCap(uint256 _cap) external;


    function setController(address _controller) external;


    function setPie(address _pie) external;


    function getCap() external view returns (uint256);


    function saveToken(address _token) external;

}pragma solidity >=0.5.0;

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

}pragma solidity >=0.5.0;



library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}interface IUniswapV2Exchange {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

}