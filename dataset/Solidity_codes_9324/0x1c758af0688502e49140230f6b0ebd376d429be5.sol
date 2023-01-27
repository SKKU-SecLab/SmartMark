



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



pragma solidity 0.6.12;

interface IKSFactory {

    function createPool(
        IERC20 tokenA,
        IERC20 tokenB,
        uint32 ampBps,
        uint24 feeUnits
    ) external returns (address pool);


    function setFeeConfiguration(address feeTo, uint24 governmentFeeUnits) external;


    function enableFeeOption(uint24 feeUnits) external;


    function disableFeeOption(uint24 feeUnits) external;


    function setFeeToSetter(address) external;


    function getFeeConfiguration() external view returns (address feeTo, uint24 governmentFeeUnits);


    function feeToSetter() external view returns (address);


    function allPools(uint256) external view returns (address pool);


    function allPoolsLength() external view returns (uint256);


    function getUnamplifiedPool(IERC20 token0, IERC20 token1) external view returns (address);


    function getPools(IERC20 token0, IERC20 token1)
        external
        view
        returns (address[] memory _tokenPools);


    function isPool(
        IERC20 token0,
        IERC20 token1,
        address pool
    ) external view returns (bool);

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



pragma solidity 0.6.12;

library MathExt {

    using SafeMath for uint256;

    uint256 public constant PRECISION = (10**18);

    function mulInPrecision(uint256 x, uint256 y) internal pure returns (uint256) {

        return x.mul(y) / PRECISION;
    }

    function unsafePowInPrecision(uint256 xInPrecision, uint256 k)
        internal
        pure
        returns (uint256 zInPrecision)
    {

        require(xInPrecision <= PRECISION, "MathExt: x > PRECISION");
        zInPrecision = k % 2 != 0 ? xInPrecision : PRECISION;

        for (k /= 2; k != 0; k /= 2) {
            xInPrecision = (xInPrecision * xInPrecision) / PRECISION;

            if (k % 2 != 0) {
                zInPrecision = (zInPrecision * xInPrecision) / PRECISION;
            }
        }
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

interface IERC20Permit is IERC20 {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}



pragma solidity 0.6.12;

contract ERC20Permit is ERC20, IERC20Permit {
    bytes32 public domainSeparator;
    bytes32
        public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    mapping(address => uint256) public nonces;

    constructor(
        string memory name,
        string memory symbol,
        string memory version
    ) public ERC20(name, symbol) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        domainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, "ERC20Permit: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline)
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "ERC20Permit: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}



pragma solidity 0.6.12;

interface IKSCallee {
    function ksSwapCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}



pragma solidity 0.6.12;

interface IKSPool {
    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1);

    function getTradeInfo()
        external
        view
        returns (
            uint112 _vReserve0,
            uint112 _vReserve1,
            uint112 reserve0,
            uint112 reserve1,
            uint256 feeInPrecision
        );

    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function ampBps() external view returns (uint32);

    function factory() external view returns (IKSFactory);

    function kLast() external view returns (uint256);
}




pragma solidity 0.6.12;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}



pragma solidity 0.6.12;








contract KSPool is IKSPool, ERC20Permit, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 internal constant MAX_UINT112 = 2**112 - 1;
    uint256 internal constant BPS = 10000;
    uint256 internal constant FEE_UNITS = 100000;

    struct ReserveData {
        uint256 reserve0;
        uint256 reserve1;
        uint256 vReserve0;
        uint256 vReserve1; // only used when isAmpPool = true
    }

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    uint256 internal constant PRECISION = 10**18;

    IKSFactory public override factory;
    IERC20 public override token0;
    IERC20 public override token1;

    uint112 internal reserve0;
    uint112 internal reserve1;
    uint32 public override ampBps;
    uint112 internal vReserve0;
    uint112 internal vReserve1;

    uint256 public override kLast;

    uint256 internal feeInPrecision;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to,
        uint256 feeInPrecision
    );
    event Sync(uint256 vReserve0, uint256 vReserve1, uint256 reserve0, uint256 reserve1);

    constructor() public ERC20Permit("KyberSwap LP", "KS-LP", "1") {
        factory = IKSFactory(msg.sender);
    }

    function initialize(
        IERC20 _token0,
        IERC20 _token1,
        uint32 _ampBps,
        uint24 _feeUnits
    ) external {
        require(msg.sender == address(factory), "KS: FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
        ampBps = _ampBps;
        feeInPrecision = (_feeUnits * PRECISION) / FEE_UNITS;
    }

    function mint(address to) external override nonReentrant returns (uint256 liquidity) {
        (bool isAmpPool, ReserveData memory data) = getReservesData();
        ReserveData memory _data;
        _data.reserve0 = token0.balanceOf(address(this));
        _data.reserve1 = token1.balanceOf(address(this));
        uint256 amount0 = _data.reserve0.sub(data.reserve0);
        uint256 amount1 = _data.reserve1.sub(data.reserve1);

        bool feeOn = _mintFee(isAmpPool, data);
        uint256 _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            if (isAmpPool) {
                uint32 _ampBps = ampBps;
                _data.vReserve0 = _data.reserve0.mul(_ampBps) / BPS;
                _data.vReserve1 = _data.reserve1.mul(_ampBps) / BPS;
            }
            liquidity = MathExt.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(-1), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / data.reserve0,
                amount1.mul(_totalSupply) / data.reserve1
            );
            if (isAmpPool) {
                uint256 b = liquidity.add(_totalSupply);
                _data.vReserve0 = Math.max(data.vReserve0.mul(b) / _totalSupply, _data.reserve0);
                _data.vReserve1 = Math.max(data.vReserve1.mul(b) / _totalSupply, _data.reserve1);
            }
        }
        require(liquidity > 0, "KS: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(isAmpPool, _data);
        if (feeOn) kLast = getK(isAmpPool, _data);
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to)
        external
        override
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
        (bool isAmpPool, ReserveData memory data) = getReservesData(); // gas savings
        IERC20 _token0 = token0; // gas savings
        IERC20 _token1 = token1; // gas savings

        uint256 balance0 = _token0.balanceOf(address(this));
        uint256 balance1 = _token1.balanceOf(address(this));
        require(balance0 >= data.reserve0 && balance1 >= data.reserve1, "KS: UNSYNC_RESERVES");
        uint256 liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(isAmpPool, data);
        uint256 _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 || amount1 > 0, "KS: INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this), liquidity);
        if (amount0 > 0) _token0.safeTransfer(to, amount0);
        if (amount1 > 0) _token1.safeTransfer(to, amount1);
        ReserveData memory _data;
        _data.reserve0 = _token0.balanceOf(address(this));
        _data.reserve1 = _token1.balanceOf(address(this));
        if (isAmpPool) {
            uint256 b = Math.min(
                _data.reserve0.mul(_totalSupply) / data.reserve0,
                _data.reserve1.mul(_totalSupply) / data.reserve1
            );
            _data.vReserve0 = Math.max(data.vReserve0.mul(b) / _totalSupply, _data.reserve0);
            _data.vReserve1 = Math.max(data.vReserve1.mul(b) / _totalSupply, _data.reserve1);
        }
        _update(isAmpPool, _data);
        if (feeOn) kLast = getK(isAmpPool, _data); // data are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata callbackData
    ) external override nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "KS: INSUFFICIENT_OUTPUT_AMOUNT");
        (bool isAmpPool, ReserveData memory data) = getReservesData(); // gas savings
        require(
            amount0Out < data.reserve0 && amount1Out < data.reserve1,
            "KS: INSUFFICIENT_LIQUIDITY"
        );

        ReserveData memory newData;
        {
            IERC20 _token0 = token0;
            IERC20 _token1 = token1;
            require(to != address(_token0) && to != address(_token1), "KS: INVALID_TO");
            if (amount0Out > 0) _token0.safeTransfer(to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _token1.safeTransfer(to, amount1Out); // optimistically transfer tokens
            if (callbackData.length > 0)
                IKSCallee(to).ksSwapCall(msg.sender, amount0Out, amount1Out, callbackData);
            newData.reserve0 = _token0.balanceOf(address(this));
            newData.reserve1 = _token1.balanceOf(address(this));
            if (isAmpPool) {
                newData.vReserve0 = data.vReserve0.add(newData.reserve0).sub(data.reserve0);
                newData.vReserve1 = data.vReserve1.add(newData.reserve1).sub(data.reserve1);
            }
        }
        uint256 amount0In = newData.reserve0 > data.reserve0 - amount0Out
            ? newData.reserve0 - (data.reserve0 - amount0Out)
            : 0;
        uint256 amount1In = newData.reserve1 > data.reserve1 - amount1Out
            ? newData.reserve1 - (data.reserve1 - amount1Out)
            : 0;
        require(amount0In > 0 || amount1In > 0, "KS: INSUFFICIENT_INPUT_AMOUNT");
        verifyBalance(
            amount0In,
            amount1In,
            isAmpPool ? data.vReserve0 : data.reserve0,
            isAmpPool ? data.vReserve1 : data.reserve1,
            isAmpPool ? newData.vReserve0 : newData.reserve0,
            isAmpPool ? newData.vReserve1 : newData.reserve1
        );

        _update(isAmpPool, newData);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to, feeInPrecision);
    }

    function skim(address to) external nonReentrant {
        token0.safeTransfer(to, token0.balanceOf(address(this)).sub(reserve0));
        token1.safeTransfer(to, token1.balanceOf(address(this)).sub(reserve1));
    }

    function sync() external override nonReentrant {
        (bool isAmpPool, ReserveData memory data) = getReservesData();
        bool feeOn = _mintFee(isAmpPool, data);
        ReserveData memory newData;
        newData.reserve0 = IERC20(token0).balanceOf(address(this));
        newData.reserve1 = IERC20(token1).balanceOf(address(this));
        if (isAmpPool) {
            uint256 _totalSupply = totalSupply();
            uint256 b = Math.min(
                newData.reserve0.mul(_totalSupply) / data.reserve0,
                newData.reserve1.mul(_totalSupply) / data.reserve1
            );
            newData.vReserve0 = Math.max(data.vReserve0.mul(b) / _totalSupply, newData.reserve0);
            newData.vReserve1 = Math.max(data.vReserve1.mul(b) / _totalSupply, newData.reserve1);
        }
        _update(isAmpPool, newData);
        if (feeOn) kLast = getK(isAmpPool, newData);
    }

    function getTradeInfo()
        external
        virtual
        override
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint112 _vReserve0,
            uint112 _vReserve1,
            uint256 _feeInPrecision
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        uint32 _ampBps = ampBps;
        _vReserve0 = vReserve0;
        _vReserve1 = vReserve1;
        if (_ampBps == BPS) {
            _vReserve0 = _reserve0;
            _vReserve1 = _reserve1;
        }
        _feeInPrecision = feeInPrecision;
    }

    function getReserves() external override view returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function name() public override view returns (string memory) {
        IERC20Metadata _token0 = IERC20Metadata(address(token0));
        IERC20Metadata _token1 = IERC20Metadata(address(token1));
        return string(abi.encodePacked("KyberSwap LP ", _token0.symbol(), "-", _token1.symbol()));
    }

    function symbol() public override view returns (string memory) {
        IERC20Metadata _token0 = IERC20Metadata(address(token0));
        IERC20Metadata _token1 = IERC20Metadata(address(token1));
        return string(abi.encodePacked("KS-LP ", _token0.symbol(), "-", _token1.symbol()));
    }

    function verifyBalance(
        uint256 amount0In,
        uint256 amount1In,
        uint256 beforeReserve0,
        uint256 beforeReserve1,
        uint256 afterReserve0,
        uint256 afterReserve1
    ) internal virtual view {
        uint256 balance0Adjusted = afterReserve0.mul(PRECISION);
        balance0Adjusted = balance0Adjusted.sub(amount0In.mul(feeInPrecision));
        balance0Adjusted = balance0Adjusted / PRECISION;
        uint256 balance1Adjusted = afterReserve1.mul(PRECISION);
        balance1Adjusted = balance1Adjusted.sub(amount1In.mul(feeInPrecision));
        balance1Adjusted = balance1Adjusted / PRECISION;
        require(
            balance0Adjusted.mul(balance1Adjusted) >= beforeReserve0.mul(beforeReserve1),
            "KS: K"
        );
    }

    function _update(bool isAmpPool, ReserveData memory data) internal {
        reserve0 = safeUint112(data.reserve0);
        reserve1 = safeUint112(data.reserve1);
        if (isAmpPool) {
            assert(data.vReserve0 >= data.reserve0 && data.vReserve1 >= data.reserve1); // never happen
            vReserve0 = safeUint112(data.vReserve0);
            vReserve1 = safeUint112(data.vReserve1);
        }
        emit Sync(data.vReserve0, data.vReserve1, data.reserve0, data.reserve1);
    }

    function _mintFee(bool isAmpPool, ReserveData memory data) internal returns (bool feeOn) {
        (address feeTo, uint24 governmentFeeUnits) = factory.getFeeConfiguration();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        uint256 _vReserve0 = isAmpPool ? data.vReserve0 : data.reserve0; // gas savings
        uint256 _vReserve1 = isAmpPool ? data.vReserve1 : data.reserve1; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 collectedFee0;
                uint256 _tmp = _kLast * _vReserve0;
                if (_tmp / _vReserve0 == _kLast) {
                    collectedFee0 = _vReserve0.sub(MathExt.sqrt(_tmp.div(_vReserve1)));
                } else {
                    collectedFee0 = _vReserve0.sub(
                        MathExt.sqrt(_kLast.div(_vReserve1).mul(_vReserve0))
                    );
                }
                uint256 poolValueInToken0 = data.reserve0.add(
                    data.reserve1.mul(_vReserve0).div(_vReserve1)
                );
                uint256 numerator = totalSupply().mul(collectedFee0).mul(governmentFeeUnits);
                uint256 denominator = (poolValueInToken0.sub(collectedFee0)).mul(50000);
                uint256 liquidity = numerator / denominator;
                if (liquidity > 0) _mint(feeTo, liquidity);
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function getReservesData() internal view returns (bool isAmpPool, ReserveData memory data) {
        data.reserve0 = reserve0;
        data.reserve1 = reserve1;
        isAmpPool = ampBps != BPS;
        if (isAmpPool) {
            data.vReserve0 = vReserve0;
            data.vReserve1 = vReserve1;
        }
    }

    function getK(bool isAmpPool, ReserveData memory data) internal pure returns (uint256) {
        return isAmpPool ? data.vReserve0 * data.vReserve1 : data.reserve0 * data.reserve1;
    }

    function safeUint112(uint256 x) internal pure returns (uint112) {
        require(x <= MAX_UINT112, "KS: OVERFLOW");
        return uint112(x);
    }
}



pragma solidity 0.6.12;


contract KSFactory is IKSFactory {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 internal constant BPS = 10000;
    uint256 internal constant FEE_UNITS = 100000;

    address private feeTo;
    uint24 private governmentFeeUnits;
    address public override feeToSetter;

    mapping(uint24 => bool) public feeOptions;

    mapping(IERC20 => mapping(IERC20 => EnumerableSet.AddressSet)) internal tokenPools;
    mapping(IERC20 => mapping(IERC20 => address)) public override getUnamplifiedPool;
    address[] public override allPools;

    event PoolCreated(
        IERC20 indexed token0,
        IERC20 indexed token1,
        address pool,
        uint32 ampBps,
        uint24 feeUnits,
        uint256 totalPool
    );
    event SetFeeConfiguration(address feeTo, uint24 governmentFeeUnits);
    event EnableFeeOption(uint24 feeUnits);
    event DisableFeeOption(uint24 feeUnits);
    event SetFeeToSetter(address feeToSetter);

    modifier onlyFeeSetter() {
        require(msg.sender == feeToSetter, "only fee setter");
        _;
    }

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;

        feeOptions[8] = true;
        feeOptions[10] = true;
        feeOptions[50] = true;
        feeOptions[300] = true;
        feeOptions[500] = true;
        feeOptions[1000] = true;
    }

    function createPool(
        IERC20 tokenA,
        IERC20 tokenB,
        uint32 ampBps,
        uint24 feeUnits
    ) external override returns (address pool) {
        require(tokenA != tokenB, "KS: IDENTICAL_ADDRESSES");
        (IERC20 token0, IERC20 token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(address(token0) != address(0), "KS: ZERO_ADDRESS");
        require(ampBps >= BPS, "KS: INVALID_BPS");
        require(
            ampBps != BPS || getUnamplifiedPool[token0][token1] == address(0),
            "KS: UNAMPLIFIED_POOL_EXISTS"
        );
        require(feeUnits > 0 && feeOptions[feeUnits], "KS: FEE_OPTION_NOT_EXISTS");
        pool = address(new KSPool());
        KSPool(pool).initialize(token0, token1, ampBps, feeUnits);
        tokenPools[token0][token1].add(pool);
        tokenPools[token1][token0].add(pool);
        if (ampBps == BPS) {
            getUnamplifiedPool[token0][token1] = pool;
            getUnamplifiedPool[token1][token0] = pool;
        }
        allPools.push(pool);

        emit PoolCreated(token0, token1, pool, ampBps, feeUnits, allPools.length);
    }

    function setFeeConfiguration(address _feeTo, uint24 _governmentFeeUnits)
        external
        override
        onlyFeeSetter
    {
        require(_governmentFeeUnits > 0 && _governmentFeeUnits < 20000, "KS: INVALID FEE");
        feeTo = _feeTo;
        governmentFeeUnits = _governmentFeeUnits;

        emit SetFeeConfiguration(_feeTo, _governmentFeeUnits);
    }

    function enableFeeOption(uint24 _feeUnits) external override onlyFeeSetter {
        require(_feeUnits > 0, "KS: INVALID FEE");
        feeOptions[_feeUnits] = true;

        emit EnableFeeOption(_feeUnits);
    }

    function disableFeeOption(uint24 _feeUnits) external override onlyFeeSetter {
        require(_feeUnits > 0, "KS: INVALID FEE");
        feeOptions[_feeUnits] = false;

        emit DisableFeeOption(_feeUnits);
    }

    function setFeeToSetter(address _feeToSetter) external override onlyFeeSetter {
        feeToSetter = _feeToSetter;

        emit SetFeeToSetter(_feeToSetter);
    }

    function getFeeConfiguration()
        external
        override
        view
        returns (address _feeTo, uint24 _governmentFeeUnits)
    {
        _feeTo = feeTo;
        _governmentFeeUnits = governmentFeeUnits;
    }

    function allPoolsLength() external override view returns (uint256) {
        return allPools.length;
    }

    function getPools(IERC20 token0, IERC20 token1)
        external
        override
        view
        returns (address[] memory _tokenPools)
    {
        uint256 length = tokenPools[token0][token1].length();
        _tokenPools = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            _tokenPools[i] = tokenPools[token0][token1].at(i);
        }
    }

    function getPoolsLength(IERC20 token0, IERC20 token1) external view returns (uint256) {
        return tokenPools[token0][token1].length();
    }

    function getPoolAtIndex(
        IERC20 token0,
        IERC20 token1,
        uint256 index
    ) external view returns (address pool) {
        return tokenPools[token0][token1].at(index);
    }

    function isPool(
        IERC20 token0,
        IERC20 token1,
        address pool
    ) external override view returns (bool) {
        return tokenPools[token0][token1].contains(pool);
    }
}