
pragma solidity 0.6.12;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

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

contract LumosToken is ERC20("Lumos", "LMS"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

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

library Babylonian {
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

library FixedPoint {
    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

library UniswapV2OracleLibrary {
    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair,
        bool isToken0
    ) internal view returns (uint priceCumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (isToken0) {
          priceCumulative = IUniswapV2Pair(pair).price0CumulativeLast();

          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
          }
        } else {
          priceCumulative = IUniswapV2Pair(pair).price1CumulativeLast();
          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
          }
        }

    }
    function getUniswapV2Pair(address _token0, address _token1) internal pure returns (address uni_pair, bool isToken0) {
        
        (address token0, address token1) = UniswapV2OracleLibrary.sortTokens(
            _token0,
            _token1
        );
        if (token0 == _token0) {
            isToken0 = true;
        } else {
            isToken0 = false;
        }

        uni_pair = UniswapV2OracleLibrary.pairFor(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f), token0, token1);

        return (uni_pair, isToken0);

    }

    function pairFor(
        address factory,
        address token0,
        address token1
    ) internal pure returns (address pair) {
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
}

interface IMakerPriceFeed {
  function read() external view returns (bytes32);
}

library DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y > 0, "ds-math-division-by-zero");
        return x / y;
    }

    function add(
        uint256 x,
        uint256 y,
        string memory errorMessage
    ) internal pure returns (uint256 z) {
        require((z = x + y) >= x, errorMessage);
    }

    function sub(
        uint256 x,
        uint256 y,
        string memory errorMessage
    ) internal pure returns (uint256 z) {
        require((z = x - y) <= x, errorMessage);
    }

    function mul(
        uint256 x,
        uint256 y,
        string memory errorMessage
    ) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, errorMessage);
    }

    function div(
        uint256 x,
        uint256 y,
        string memory errorMessage
    ) internal pure returns (uint256 z) {
        require(y > 0, errorMessage);
        return x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function toWAD18(uint256 x) internal pure returns (uint256 z) {
        z = mul(x, WAD);
    }

    function toRAY27(uint256 x) internal pure returns (uint256 z) {
        z = mul(x, RAY);
    }


    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract MasterWizard is Ownable {
    using DSMath for uint;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint amount; // How many LP tokens the adventurer has provided.
        uint rewardDebt; // Reward debt. See explanation below.
        uint lastHarvestBlock;
        uint totalHarvestReward;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint allocPoint; // How many allocation points assigned to this pool. LMS to distribute per block.
        uint lastRewardBlock; // Last block number that LMS distribution occurs.
        uint accLumosPerShare; // Accumulated LMS per share, times 1e6. See below.
    }

    LumosToken public lumos;
    uint public devFundDivRate = 50 * 1e18; //Wizards casting spells while teaching so some LMS is created. These will be used wisely to develop Lumos. 
    address public devaddr;
    uint public lumosPerBlock;

    PoolInfo[] public poolInfo;

    mapping(address => uint256) public poolId1; // poolId1 count from 1, subtraction 1 before using with poolInfo

    mapping(uint => mapping(address => UserInfo)) public userInfo;
    uint public totalAllocPoint = 0;
    uint public startBlock;

    uint public endBlock;
    uint public startBlockTime;

    address public uniswap_pair;

    uint public blockTimestampLast;

    uint public priceCumulativeLast;

    bool public isToken0;

    uint public lmsPriceMultiplier;

    uint public minLMSTWAPIntervalSec;

    address public makerEthPriceFeed;

    uint public timeOfInitTWAP;


    bool public craftingEnded;

    event Recovered(address token, uint amount);
    event Deposit(address indexed user, uint indexed pid, uint amount);
    event Withdraw(address indexed user, uint indexed pid, uint amount);
    event EmergencyWithdraw(
        address indexed user,
        uint indexed pid,
        uint amount
    );

    constructor(
        LumosToken _lumos,
        address reserveToken_,//WETH
        address _devaddr
    ) public {
        lumos = _lumos;
        devaddr = _devaddr;

        (address _uniswap_pair, bool _isToken0) = UniswapV2OracleLibrary.getUniswapV2Pair(address(lumos),reserveToken_);

        uniswap_pair = _uniswap_pair;
        isToken0 = _isToken0;

        makerEthPriceFeed = 0x729D19f657BD0614b4985Cf1D82531c67569197B;
        minLMSTWAPIntervalSec = 24 hours;

    }

    function poolLength() external view returns (uint) {
        return poolInfo.length;
    }

    function start_crafting() external onlyOwner {
        require(startBlock > 0 && block.number > startBlock, "not this time.!");
        require(startBlockTime == 0, "crafting already started.!");

        startBlockTime = block.timestamp;

        lumosPerBlock = getLumosPerBlock();
        lmsPriceMultiplier = 1e18;

        massUpdatePools();
    }
   function end_crafting() external 
    {
        require(startBlockTime > 0, "crafting not started.!");

        if(lumos.totalSupply() > (1e18 * 2000000)) {

            massUpdatePools();

            craftingEnded = true;
            endBlock = block.number;
        }

    }
    function init_TWAP() public onlyOwner {
        require(timeOfInitTWAP == 0,"already initialized.!");
        (uint priceCumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair, isToken0);

        require(blockTimestamp > 0, "no trades");

        blockTimestampLast = blockTimestamp;
        priceCumulativeLast = priceCumulative;
        timeOfInitTWAP = blockTimestamp;
    }

    function add(
        uint _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        require(poolId1[address(_lpToken)] == 0, "add: lp is already in pool");

        if (_withUpdate) {
            massUpdatePools();
        }
        _allocPoint = _allocPoint.toWAD18();

        uint lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolId1[address(_lpToken)] = poolInfo.length + 1;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accLumosPerShare: 0
            })
        );
    }

    function set(
        uint _pid,
        uint _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }

        _allocPoint = _allocPoint.toWAD18();

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    function getTWAP() private returns (uint) {

        (uint priceCumulative,uint blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair, isToken0);
        
        uint timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
        );

        priceCumulativeLast = priceCumulative;
        blockTimestampLast = blockTimestamp;

        return FixedPoint.decode144(FixedPoint.mul(priceAverage, 10**18));
    }
    function getCurrentTWAP() public view returns (uint) {

        (uint priceCumulative,uint blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair, isToken0);
        
        uint timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
        );

        return FixedPoint.decode144(FixedPoint.mul(priceAverage, 10**18));
    }
    function getETHUSDPrice() public view returns(uint) {
        return uint(IMakerPriceFeed(makerEthPriceFeed).read());
    }
    function getMultiplier(uint _from, uint _to) private view returns (uint) {
        uint _blockCount = _to.sub(_from);

        return lumosPerBlock.wmul(lmsPriceMultiplier).mul(_blockCount);//.wdiv(1 ether);
    }

    function pendingLumos(uint _pid, address _user)
        external
        view
        returns (uint)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint accLumosPerShare = pool.accLumosPerShare;
        uint lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0 && craftingEnded == false) {
            uint multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint lumosReward = multiplier
                .wmul(pool.allocPoint)
                .wdiv(totalAllocPoint);
            accLumosPerShare = accLumosPerShare.add(
                lumosReward
                .mul(1e6)
                .wdiv(lpSupply)
            );
        }
        return user.amount.wmul(accLumosPerShare)
        .div(1e6)
        .sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint length = poolInfo.length;
        for (uint pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint _pid) public {
        if(startBlock == 0) {
            return;
        }

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        if(craftingEnded){
            return;
        }

        uint multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint lmsReward = multiplier
            .wmul(pool.allocPoint)
            .wdiv(totalAllocPoint);
        lumos.mint(devaddr, lmsReward.wdiv(devFundDivRate));
        lumos.mint(address(this), lmsReward);
        pool.accLumosPerShare = pool.accLumosPerShare.add(
            lmsReward
            .mul(1e6)
            .wdiv(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint _pid, uint _amount) public {
        require(startBlockTime > 0, "crafting not activated yet.!");
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint pending = user
                .amount
                .wmul(pool.accLumosPerShare)
                .div(1e6)
                .sub(user.rewardDebt);
            if (pending > 0) {
                uint _harvestMultiplier = getLumosHarvestMultiplier(
                    user.lastHarvestBlock
                );

                uint _harvestBonus = pending.wmul(_harvestMultiplier);

                if (_harvestBonus > 1e18) {
                    lumos.mint(msg.sender, _harvestBonus);
                    user.totalHarvestReward = user.totalHarvestReward.add(
                        _harvestBonus
                    );
                }
                safeLMSTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        user.lastHarvestBlock = block.number;
        user.rewardDebt = user.amount.wmul(pool.accLumosPerShare).div(1e6);

        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint _pid, uint _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint pending = user.amount.wmul(pool.accLumosPerShare)
        .div(1e6)
        .sub(user.rewardDebt);

        if (pending > 0) {
            safeLMSTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.wmul(pool.accLumosPerShare).div(1e6);

        user.lastHarvestBlock = block.number;

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastHarvestBlock = block.number;
    }

    function safeLMSTransfer(address _to, uint _amount) private {
        uint lmsBalance = lumos.balanceOf(address(this));
        if (_amount > lmsBalance) {
            lumos.transfer(_to, lmsBalance);
        } else {
            lumos.transfer(_to, _amount);
        }
    }

    function setLumosPerBlock() external {
        require(startBlockTime > 0, "crafting not activated yet.!");

        uint _lumosPerBlock = getLumosPerBlock();
        if(_lumosPerBlock != lumosPerBlock){
            massUpdatePools();
            
            lumosPerBlock = _lumosPerBlock;
        }
    }
    function setLMSPriceMultiplier() external {
        require(startBlockTime > 0 && blockTimestampLast.add(minLMSTWAPIntervalSec) < now, "not this time.!");
        require(timeOfInitTWAP > 0, "crafting not initialized.!");
        require(craftingEnded == false, "crafting ended :(");
        
        massUpdatePools();
        
        setLMSPriceMultiplierInt();
    }
    function getCurrentPriceMultiplier() external view returns(uint){

        uint _lmsPriceETH = getCurrentTWAP();
        uint _ethPriceUSD = getETHUSDPrice();
        uint _price = _lmsPriceETH.wmul(_ethPriceUSD);

        if (_price < 3e18) 
            return 1e18;
        else if (_price >= 3e18 && _price < 5e18)
            return 2e18; 
        else if (_price >= 5e18 && _price < 8e18)
            return 3e18;
        else return 4e18;
    }
    function setLMSPriceMultiplierInt() private {
        if(startBlockTime == 0 || blockTimestampLast.add(minLMSTWAPIntervalSec) > now || timeOfInitTWAP == 0 || craftingEnded == true) {
            return;
        }
        uint _lmsPriceETH = getTWAP();
        uint _ethPriceUSD = getETHUSDPrice();
        uint _price = _lmsPriceETH.wmul(_ethPriceUSD);

        if (_price < 3e18) 
            lmsPriceMultiplier = 1e18;
        else if (_price >= 3e18 && _price < 5e18)
            lmsPriceMultiplier = 2e18; 
        else if (_price >= 5e18 && _price < 8e18)
            lmsPriceMultiplier = 3e18;
        else lmsPriceMultiplier = 4e18;

        lumosPerBlock = getLumosPerBlock();
    }

    function getLumosPerBlock() private view returns (uint) {
        uint elapsedDays = ((now - startBlockTime).div(86400) + 1) * 1e6;
        return elapsedDays.sqrt().wdiv(6363);
    }

    function getLumosHarvestMultiplier(uint _lastHarvestBlock) private view returns (uint) {
        return
            (block.number - _lastHarvestBlock).wdiv(67000).min(1e18);
    }

    function setStartBlock(uint _startBlock) external onlyOwner {
        require(startBlock == 0 && _startBlock > 0, " startBlock > 0 ?");
        startBlock = _startBlock;
    }

    function setDevFundDivRate(uint _devFundDivRate) external onlyOwner {
        require(_devFundDivRate > 0, "dev fund rate 0 ?");
        devFundDivRate = _devFundDivRate;
    }

    function setminLMSTWAPIntervalSec(uint _interval) external onlyOwner {
        require(_interval > 0, "minLMSTWAPIntervalSec 0 ?");
        minLMSTWAPIntervalSec = _interval;
    }    
}