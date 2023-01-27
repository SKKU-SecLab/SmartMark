

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract DelegationStorage {

    address public implementation;
}

abstract contract DelegatorInterface is DelegationStorage {
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public virtual;
}

abstract contract DelegateInterface is DelegationStorage {
    function _becomeImplementation(bytes memory data) public virtual;

    function _resignImplementation() public virtual;
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


pragma solidity >=0.4.0;

library FullMath {

    function fullMul(uint256 x, uint256 y) internal pure returns (uint256 l, uint256 h) {

        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {

        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {

        (uint256 l, uint256 h) = fullMul(x, y);

        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;

        if (h == 0) return l / d;

        require(h < d, 'FullMath: FULLDIV_OVERFLOW');
        return fullDiv(l, h, d);
    }
}



pragma solidity >=0.4.0;

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}


pragma solidity >=0.5.0;

library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0, 'BitMath::mostSignificantBit: zero');

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0, 'BitMath::leastSignificantBit: zero');

        r = 255;
        if (x & uint128(-1) > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & uint64(-1) > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & uint32(-1) > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & uint16(-1) > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & uint8(-1) > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}


pragma solidity >=0.4.0;




library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 public constant RESOLUTION = 112;
    uint256 public constant Q112 = 0x10000000000000000000000000000; // 2**112
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000; // 2**224
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }

    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {

        uint256 z = 0;
        require(y == 0 || (z = self._x * y) / y == self._x, 'FixedPoint::mul: overflow');
        return uq144x112(z);
    }

    function muli(uq112x112 memory self, int256 y) internal pure returns (int256) {

        uint256 z = FullMath.mulDiv(self._x, uint256(y < 0 ? -y : y), Q112);
        require(z < 2**255, 'FixedPoint::muli: overflow');
        return y < 0 ? -int256(z) : int256(z);
    }

    function muluq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {

        if (self._x == 0 || other._x == 0) {
            return uq112x112(0);
        }
        uint112 upper_self = uint112(self._x >> RESOLUTION); // * 2^0
        uint112 lower_self = uint112(self._x & LOWER_MASK); // * 2^-112
        uint112 upper_other = uint112(other._x >> RESOLUTION); // * 2^0
        uint112 lower_other = uint112(other._x & LOWER_MASK); // * 2^-112

        uint224 upper = uint224(upper_self) * upper_other; // * 2^0
        uint224 lower = uint224(lower_self) * lower_other; // * 2^-224
        uint224 uppers_lowero = uint224(upper_self) * lower_other; // * 2^-112
        uint224 uppero_lowers = uint224(upper_other) * lower_self; // * 2^-112

        require(upper <= uint112(-1), 'FixedPoint::muluq: upper overflow');

        uint256 sum = uint256(upper << RESOLUTION) + uppers_lowero + uppero_lowers + (lower >> RESOLUTION);

        require(sum <= uint224(-1), 'FixedPoint::muluq: sum overflow');

        return uq112x112(uint224(sum));
    }

    function divuq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {

        require(other._x > 0, 'FixedPoint::divuq: division by zero');
        if (self._x == other._x) {
            return uq112x112(uint224(Q112));
        }
        if (self._x <= uint144(-1)) {
            uint256 value = (uint256(self._x) << RESOLUTION) / other._x;
            require(value <= uint224(-1), 'FixedPoint::divuq: overflow');
            return uq112x112(uint224(value));
        }

        uint256 result = FullMath.mulDiv(Q112, self._x, other._x);
        require(result <= uint224(-1), 'FixedPoint::divuq: overflow');
        return uq112x112(uint224(result));
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x != 0, 'FixedPoint::reciprocal: reciprocal of zero');
        require(self._x != 1, 'FixedPoint::reciprocal: overflow');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        if (self._x <= uint144(-1)) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
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


pragma solidity >=0.5.0;



library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}


pragma solidity 0.6.12;

interface IInvitation{


    function acceptInvitation(address _invitor) external;


    function getInvitation(address _sender) external view returns(address _invitor, address[] memory _invitees, bool _isWithdrawn);

    
}



pragma solidity 0.6.12;



contract ActivityBase is Ownable{

    using SafeMath for uint256;

    address public admin;
    
    address public marketingFund;
    address public WETHToken;
    uint256 public constant INVITEE_WEIGHT = 20; 
    uint256 public constant INVITOR_WEIGHT = 10;

    uint256 public startBlock;

    uint256 public userDividendWeight;
    uint256 public devDividendWeight;
    address public developerDAOFund;

    uint256 public amountFeeRateNumerator;
    uint256 public amountfeeRateDenominator;

    uint256 public contractFeeRateNumerator;
    uint256 public contractFeeRateDenominator;

    mapping (uint256 => mapping (address => bool)) public isUserContractSender;
    mapping (uint256 => uint256) public poolTokenAmountLimit;

    function setDividendWeight(uint256 _userDividendWeight, uint256 _devDividendWeight) public virtual{

        checkAdmin();
        require(
            _userDividendWeight != 0 && _devDividendWeight != 0,
            "invalid input"
        );
        userDividendWeight = _userDividendWeight;
        devDividendWeight = _devDividendWeight;
    }

    function setDeveloperDAOFund(address _developerDAOFund) public virtual onlyOwner {

        developerDAOFund = _developerDAOFund;
    }

    function setTokenAmountLimit(uint256 _pid, uint256 _tokenAmountLimit) public virtual {

        checkAdmin();
        poolTokenAmountLimit[_pid] = _tokenAmountLimit;
    }

    function setTokenAmountLimitFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) public virtual {

        checkAdmin();
        require(
            _feeRateDenominator >= _feeRateNumerator, "invalid input"
        );
        amountFeeRateNumerator = _feeRateNumerator;
        amountfeeRateDenominator = _feeRateDenominator;
    }

    function setContracSenderFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) public virtual {

        checkAdmin();
        require(
            _feeRateDenominator >= _feeRateNumerator, "invalid input"
        );
        contractFeeRateNumerator = _feeRateNumerator;
        contractFeeRateDenominator = _feeRateDenominator;
    }

    function setStartBlock(uint256 _startBlock) public virtual onlyOwner { 

        require(startBlock > block.number, "invalid start block");
        startBlock = _startBlock;
        updateAfterModifyStartBlock(_startBlock);
    }

    function transferAdmin(address _admin) public virtual {

        checkAdmin();
        admin = _admin;
    }

    function setMarketingFund(address _marketingFund) public virtual onlyOwner {

        marketingFund = _marketingFund;
    }

    function updateAfterModifyStartBlock(uint256 _newStartBlock) internal virtual{

    }

    function calculateDividend(uint256 _pending, uint256 _pid, uint256 _userAmount, bool _isContractSender) internal view returns (uint256 _marketingFundDividend, uint256 _devDividend, uint256 _userDividend){

        uint256 fee = 0;
        if(_isContractSender && contractFeeRateDenominator > 0){
            fee = _pending.mul(contractFeeRateNumerator).div(contractFeeRateDenominator);
            _marketingFundDividend = _marketingFundDividend.add(fee);
            _pending = _pending.sub(fee);
        }
        if(poolTokenAmountLimit[_pid] > 0 && amountfeeRateDenominator > 0 && _userAmount >= poolTokenAmountLimit[_pid]){
            fee = _pending.mul(amountFeeRateNumerator).div(amountfeeRateDenominator);
            _marketingFundDividend =_marketingFundDividend.add(fee);
            _pending = _pending.sub(fee);
        }
        if(devDividendWeight > 0){
            fee = _pending.mul(devDividendWeight).div(devDividendWeight.add(userDividendWeight));
            _devDividend = _devDividend.add(fee);
            _pending = _pending.sub(fee);
        }
        _userDividend = _pending;
    }

    function judgeContractSender(uint256 _pid) internal {

        if(msg.sender != tx.origin){
            isUserContractSender[_pid][msg.sender] = true;
        }
    }

    function checkAdmin() internal view {

        require(admin == msg.sender, "invalid authorized");
    }
}




pragma solidity >=0.6.0 <0.8.0;




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






contract SHDToken is ERC20("ShardingDAO", "SHD"), Ownable {
    mapping(address => bool) public minters;

    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }
    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;

    mapping(address => uint256) public numCheckpoints;
    event VotesBalanceChanged(
        address indexed user,
        uint256 previousBalance,
        uint256 newBalance
    );

    function mint(address _to, uint256 _amount) public {
        require(minters[msg.sender] == true, "SHD : You are not the miner");
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }

    function addMiner(address _miner) external onlyOwner {
        minters[_miner] = true;
    }

    function removeMiner(address _miner) external onlyOwner {
        minters[_miner] = false;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {
        require(
            blockNumber < block.number,
            "getPriorVotes: not yet determined"
        );

        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _voteTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                uint256 fromNum = numCheckpoints[from];
                uint256 fromOld =
                    fromNum > 0 ? checkpoints[from][fromNum - 1].votes : 0;
                uint256 fromNew = fromOld.sub(amount);
                _writeCheckpoint(from, fromNum, fromOld, fromNew);
            }

            if (to != address(0)) {
                uint256 toNum = numCheckpoints[to];
                uint256 toOld =
                    toNum > 0 ? checkpoints[to][toNum - 1].votes : 0;
                uint256 toNew = toOld.add(amount);
                _writeCheckpoint(to, toNum, toOld, toNew);
            }
        }
    }

    function _writeCheckpoint(
        address user,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint256 blockNumber = block.number;
        if (
            nCheckpoints > 0 &&
            checkpoints[user][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[user][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[user][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[user] = nCheckpoints + 1;
        }

        emit VotesBalanceChanged(user, oldVotes, newVotes);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        _voteTransfer(from, to, amount);
    }
}



pragma solidity 0.6.12;











contract ShardingDAOMining is IInvitation, ActivityBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20; 
    using FixedPoint for *;

    struct UserInfo {
        uint256 amount; // How much LP token the user has provided.
        uint256 originWeight; //initial weight
        uint256 inviteeWeight; // invitees' weight
        uint256 endBlock;
        bool isCalculateInvitation;
    }

    struct PoolInfo {
        uint256 nftPoolId;
        address lpTokenSwap; // uniswapPair contract address
        uint256 accumulativeDividend;
        uint256 usersTotalWeight; // user's sum weight
        uint256 lpTokenAmount; // lock amount
        uint256 oracleWeight; // eth value
        uint256 lastDividendHeight; // last dividend block height
        TokenPairInfo tokenToEthPairInfo;
        bool isFirstTokenShard;
    }

    struct TokenPairInfo{
        IUniswapV2Pair tokenToEthSwap; 
        FixedPoint.uq112x112 price; 
        bool isFirstTokenEth;
        uint256 priceCumulativeLast;
        uint32  blockTimestampLast;
        uint256 lastPriceUpdateHeight;
    }

    struct InvitationInfo {
        address invitor;
        address[] invitees;
        bool isUsed;
        bool isWithdrawn;
        mapping(address => uint256) inviteeIndexMap;
    }

    struct EvilPoolInfo {
        uint256 pid;
        string description;
    }

    SHDToken public SHD;
    uint256[] public rankPoolIndex;
    mapping(uint256 => uint256) public rankPoolIndexMap;
    mapping(address => InvitationInfo) public usersRelationshipInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    PoolInfo[] private poolInfo;
    uint256 public maxRankNumber = 10;
    uint256 public lastRewardBlock;
    uint256 public constant produceBlocksPerDay = 6496;
    uint256 public constant produceBlocksPerMonth = produceBlocksPerDay * 30;
    uint256 public SHDPerBlock = 104994 * (1e13);
    uint256 public constant MINT_DECREASE_TERM = 9500000;
    uint256[] private depositTimeWeight;
    uint256 private constant MAX_MONTH = 36;
    address public nftShard;
    uint256 public updateTokenPriceTerm = 120;
    uint256 public shardMintWeight = 1;
    uint256 public reserveMintWeight = 0;
    uint256 public reserveToMint;
    EvilPoolInfo[] public blackList;
    mapping(uint256 => uint256) public blackListMap;
    uint256 public unDividendShard;
    uint256 public shardPoolDividendWeight = 2;
    uint256 public otherPoolDividendWeight = 8;

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 weight
    );
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Replace(
        address indexed user,
        uint256 indexed rankIndex,
        uint256 newPid
    );

    event AddToBlacklist(
        uint256 indexed pid
    );

    event RemoveFromBlacklist(
        uint256 indexed pid
    );
    event AddPool(uint256 indexed pid, uint256 nftId, address tokenAddress);

    function initialize(
        SHDToken _SHD,
        address _wethToken,
        address _developerDAOFund,
        address _marketingFund,
        uint256 _maxRankNumber,
        uint256 _startBlock
    ) public virtual onlyOwner{
        require(WETHToken == address(0), "already initialized");
        SHD = _SHD;
        maxRankNumber = _maxRankNumber;
        if (_startBlock < block.number) {
            startBlock = block.number;
        } else {
            startBlock = _startBlock;
        }
        lastRewardBlock = startBlock.sub(1);
        WETHToken = _wethToken;
        initializeTimeWeight();
        developerDAOFund = _developerDAOFund;
        marketingFund = _marketingFund;
        InvitationInfo storage initialInvitor =
            usersRelationshipInfo[address(this)];

        userDividendWeight = 8;
        devDividendWeight = 2;

        amountFeeRateNumerator = 0;
        amountfeeRateDenominator = 0;

        contractFeeRateNumerator = 1;
        contractFeeRateDenominator = 5;
        initialInvitor.isUsed = true;
    }

    function initializeTimeWeight() private {
        depositTimeWeight = [
            1238,
            1383,
            1495,
            1587,
            1665,
            1732,
            1790,
            1842,
            1888,
            1929,
            1966,
            2000,
            2031,
            2059,
            2085,
            2108,
            2131,
            2152,
            2171,
            2189,
            2206,
            2221,
            2236,
            2250,
            2263,
            2276,
            2287,
            2298,
            2309,
            2319,
            2328,
            2337,
            2346,
            2355,
            2363,
            2370
        ];
    }

    function setNftShard(address _nftShard) public virtual {
        checkAdmin();
        nftShard = _nftShard;
    }

    function add(
        uint256 _nftPoolId,
        IUniswapV2Pair _lpTokenSwap,
        IUniswapV2Pair _tokenToEthSwap
    ) public virtual {
        require(msg.sender == nftShard || msg.sender == admin, "invalid sender");
        TokenPairInfo memory tokenToEthInfo;
        uint256 lastDividendHeight = 0;
        if(poolInfo.length == 0){
            _nftPoolId = 0;
            lastDividendHeight = lastRewardBlock;
        }
        bool isFirstTokenShard;
        if (address(_tokenToEthSwap) != address(0)) {
            (address token0, address token1, uint256 targetTokenPosition) =
                getTargetTokenInSwap(_tokenToEthSwap, WETHToken);
            address wantToken;
            bool isFirstTokenEthToken;
            if (targetTokenPosition == 0) {
                isFirstTokenEthToken = true;
                wantToken = token1;
            } else {
                isFirstTokenEthToken = false;
                wantToken = token0;
            }
            (, , targetTokenPosition) = getTargetTokenInSwap(
                _lpTokenSwap,
                wantToken
            );
            if (targetTokenPosition == 0) {
                isFirstTokenShard = false;
            } else {
                isFirstTokenShard = true;
            }
            tokenToEthInfo = generateOrcaleInfo(
                _tokenToEthSwap,
                isFirstTokenEthToken
            );
        } else {
            (, , uint256 targetTokenPosition) =
                getTargetTokenInSwap(_lpTokenSwap, WETHToken);
            if (targetTokenPosition == 0) {
                isFirstTokenShard = false;
            } else {
                isFirstTokenShard = true;
            }
            tokenToEthInfo = generateOrcaleInfo(
                _lpTokenSwap,
                !isFirstTokenShard
            );
        }
        poolInfo.push(
            PoolInfo({
                nftPoolId: _nftPoolId,
                lpTokenSwap: address(_lpTokenSwap),
                lpTokenAmount: 0,
                usersTotalWeight: 0,
                accumulativeDividend: 0,
                oracleWeight: 0,
                lastDividendHeight: lastDividendHeight,
                tokenToEthPairInfo: tokenToEthInfo,
                isFirstTokenShard: isFirstTokenShard
            })
        );
        emit AddPool(poolInfo.length.sub(1), _nftPoolId, address(_lpTokenSwap));
    }

    function setPriceUpdateTerm(uint256 _term) public virtual onlyOwner{
        updateTokenPriceTerm = _term;
    }

    function kickEvilPoolByPid(uint256 _pid, string calldata description)
        public
        virtual
        onlyOwner
    {
        bool isDescriptionLeagal = verifyDescription(description);
        require(isDescriptionLeagal, "invalid description, just ASCII code is allowed");
        require(_pid > 0, "invalid pid");
        uint256 poolRankIndex = rankPoolIndexMap[_pid];
        if (poolRankIndex > 0) {
            massUpdatePools();
            uint256 _rankIndex = poolRankIndex.sub(1);
            uint256 currentRankLastIndex = rankPoolIndex.length.sub(1);
            uint256 lastPidInRank = rankPoolIndex[currentRankLastIndex];
            rankPoolIndex[_rankIndex] = lastPidInRank;
            rankPoolIndexMap[lastPidInRank] = poolRankIndex;
            delete rankPoolIndexMap[_pid];
            rankPoolIndex.pop();
        }
        addInBlackList(_pid, description);
        dealEvilPoolDiviend(_pid);
        emit AddToBlacklist(_pid);
    }

    function addInBlackList(uint256 _pid, string calldata description) private {
        if (blackListMap[_pid] > 0) {
            return;
        }
        blackList.push(EvilPoolInfo({pid: _pid, description: description}));
        blackListMap[_pid] = blackList.length;
    }

    function resetEvilPool(uint256 _pid) public virtual onlyOwner {
        uint256 poolPosition = blackListMap[_pid];
        if (poolPosition == 0) {
            return;
        }
        uint256 poolIndex = poolPosition.sub(1);
        uint256 lastIndex = blackList.length.sub(1);
        EvilPoolInfo storage lastEvilInBlackList = blackList[lastIndex];
        uint256 lastPidInBlackList = lastEvilInBlackList.pid;
        blackListMap[lastPidInBlackList] = poolPosition;
        blackList[poolIndex] = blackList[lastIndex];
        delete blackListMap[_pid];
        blackList.pop();
        emit RemoveFromBlacklist(_pid);
    }

    function dealEvilPoolDiviend(uint256 _pid) private {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 undistributeDividend = pool.accumulativeDividend;
        if (undistributeDividend == 0) {
            return;
        }
        uint256 currentRankCount = rankPoolIndex.length;
        if (currentRankCount > 0) {
            uint256 averageDividend =
                undistributeDividend.div(currentRankCount);
            for (uint256 i = 0; i < currentRankCount; i++) {
                PoolInfo storage poolInRank = poolInfo[rankPoolIndex[i]];
                if (i < currentRankCount - 1) {
                    poolInRank.accumulativeDividend = poolInRank
                        .accumulativeDividend
                        .add(averageDividend);
                    undistributeDividend = undistributeDividend.sub(
                        averageDividend
                    );
                } else {
                    poolInRank.accumulativeDividend = poolInRank
                        .accumulativeDividend
                        .add(undistributeDividend);
                }
            }
        } else {
            unDividendShard = unDividendShard.add(undistributeDividend);
        }
        pool.accumulativeDividend = 0;
    }

    function setMintCoefficient(
        uint256 _shardMintWeight,
        uint256 _reserveMintWeight
    ) public virtual {
        checkAdmin();
        require(
            _shardMintWeight != 0 && _reserveMintWeight != 0,
            "invalid input"
        );
        massUpdatePools();
        shardMintWeight = _shardMintWeight;
        reserveMintWeight = _reserveMintWeight;
    }

    function setShardPoolDividendWeight(
        uint256 _shardPoolWeight,
        uint256 _otherPoolWeight
    ) public virtual {
        checkAdmin();
        require(
            _shardPoolWeight != 0 && _otherPoolWeight != 0,
            "invalid input"
        );
        massUpdatePools();
        shardPoolDividendWeight = _shardPoolWeight;
        otherPoolDividendWeight = _otherPoolWeight;
    }

    function setSHDPerBlock(uint256 _SHDPerBlock, bool _withUpdate) public virtual {
        checkAdmin();
        if (_withUpdate) {
            massUpdatePools();
        }
        SHDPerBlock = _SHDPerBlock;
    }

    function massUpdatePools() public virtual {
        uint256 poolCountInRank = rankPoolIndex.length;
        uint256 farmMintShard = mintSHARD(address(this), block.number);
        updateSHARDPoolAccumulativeDividend(block.number);
        if(poolCountInRank == 0){
            farmMintShard = farmMintShard.mul(otherPoolDividendWeight)
                                     .div(shardPoolDividendWeight.add(otherPoolDividendWeight));
            if(farmMintShard > 0){
                unDividendShard = unDividendShard.add(farmMintShard);
            }
        }
        for (uint256 i = 0; i < poolCountInRank; i++) {
            updatePoolAccumulativeDividend(
                rankPoolIndex[i],
                poolCountInRank,
                block.number
            );
        }
    }

    function updatePoolDividend(uint256 _pid) public virtual {
        if(_pid == 0){
            updateSHARDPoolAccumulativeDividend(block.number);
            return;
        }
        if (rankPoolIndexMap[_pid] == 0) {
            return;
        }
        updatePoolAccumulativeDividend(
            _pid,
            rankPoolIndex.length,
            block.number
        );
    }

    function mintSHARD(address _address, uint256 _toBlock) private returns (uint256){
        uint256 recentlyRewardBlock = lastRewardBlock;
        if (recentlyRewardBlock >= _toBlock) {
            return 0;
        }
        uint256 totalReward =
            getRewardToken(recentlyRewardBlock.add(1), _toBlock);
        uint256 farmMint =
            totalReward.mul(shardMintWeight).div(
                reserveMintWeight.add(shardMintWeight)
            );
        uint256 reserve = totalReward.sub(farmMint);
        if (totalReward > 0) {
            SHD.mint(_address, farmMint);
            if (reserve > 0) {
                reserveToMint = reserveToMint.add(reserve);
            }
            lastRewardBlock = _toBlock;
        }
        return farmMint;
    }

    function updatePoolAccumulativeDividend(
        uint256 _pid,
        uint256 _validRankPoolCount,
        uint256 _toBlock
    ) private {
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.lastDividendHeight >= _toBlock) return;
        uint256 poolReward =
            getModifiedRewardToken(pool.lastDividendHeight.add(1), _toBlock)
                                    .mul(otherPoolDividendWeight)
                                    .div(shardPoolDividendWeight.add(otherPoolDividendWeight));

        uint256 otherPoolReward = poolReward.div(_validRankPoolCount);                            
        pool.lastDividendHeight = _toBlock;
        uint256 existedDividend = pool.accumulativeDividend;
        pool.accumulativeDividend = existedDividend.add(otherPoolReward);
    }

    function updateSHARDPoolAccumulativeDividend (uint256 _toBlock) private{
        PoolInfo storage pool = poolInfo[0];
        if (pool.lastDividendHeight >= _toBlock) return;
        uint256 poolReward =
            getModifiedRewardToken(pool.lastDividendHeight.add(1), _toBlock);

        uint256 shardPoolDividend = poolReward.mul(shardPoolDividendWeight)
                                               .div(shardPoolDividendWeight.add(otherPoolDividendWeight));                              
        pool.lastDividendHeight = _toBlock;
        uint256 existedDividend = pool.accumulativeDividend;
        pool.accumulativeDividend = existedDividend.add(shardPoolDividend);
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        uint256 _lockTime
    ) public virtual {
        require(_amount > 0, "invalid deposit amount");
        InvitationInfo storage senderInfo = usersRelationshipInfo[msg.sender];
        require(senderInfo.isUsed, "must accept an invitation firstly");
        require(_lockTime > 0 && _lockTime <= 36, "invalid lock time"); // less than 36 months
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lpTokenAmount = pool.lpTokenAmount.add(_amount);
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 newOriginWeight = user.originWeight;
        uint256 existedAmount = user.amount;
        uint256 endBlock = user.endBlock;
        uint256 newEndBlock =
            block.number.add(produceBlocksPerMonth.mul(_lockTime));
        if (existedAmount > 0) {
            if (block.number >= endBlock) {
                newOriginWeight = getDepositWeight(
                    _amount.add(existedAmount),
                    _lockTime
                );
            } else {
                newOriginWeight = newOriginWeight.add(getDepositWeight(_amount, _lockTime));
                newOriginWeight = newOriginWeight.add(
                    getDepositWeight(
                        existedAmount,
                        newEndBlock.sub(endBlock).div(produceBlocksPerMonth)
                    )
                );
            }
        } else {
            judgeContractSender(_pid);
            newOriginWeight = getDepositWeight(_amount, _lockTime);
        }
        modifyWeightByInvitation(
            _pid,
            msg.sender,
            user.originWeight,
            newOriginWeight,
            user.inviteeWeight,
            existedAmount
        );   
        updateUserInfo(
            user,
            existedAmount.add(_amount),
            newOriginWeight,
            newEndBlock
        );
        IERC20(pool.lpTokenSwap).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.oracleWeight =  getOracleWeight(pool, lpTokenAmount);
        pool.lpTokenAmount = lpTokenAmount;
        if (
            rankPoolIndexMap[_pid] == 0 &&
            rankPoolIndex.length < maxRankNumber &&
            blackListMap[_pid] == 0
        ) {
            addToRank(pool, _pid);
        }
        emit Deposit(msg.sender, _pid, _amount, newOriginWeight);
    }

    function withdraw(uint256 _pid) public virtual {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        require(amount > 0, "user is not existed");
        require(user.endBlock < block.number, "token is still locked");
        mintSHARD(address(this), block.number);
        updatePoolDividend(_pid);
        uint256 originWeight = user.originWeight;
        PoolInfo storage pool = poolInfo[_pid];
        uint256 usersTotalWeight = pool.usersTotalWeight;
        uint256 userWeight = user.inviteeWeight.add(originWeight);
        if(user.isCalculateInvitation){
            userWeight = userWeight.add(originWeight.div(INVITOR_WEIGHT));
        }
        if (pool.accumulativeDividend > 0) {
            uint256 pending = pool.accumulativeDividend.mul(userWeight).div(usersTotalWeight);
            pool.accumulativeDividend = pool.accumulativeDividend.sub(pending);
            uint256 treasruyDividend;
            uint256 devDividend;
            (treasruyDividend, devDividend, pending) = calculateDividend(pending, _pid, amount, isUserContractSender[_pid][msg.sender]);
            if(treasruyDividend > 0){
                safeSHARDTransfer(marketingFund, treasruyDividend);
            }
            if(devDividend > 0){
                safeSHARDTransfer(developerDAOFund, devDividend);
            }
            if(pending > 0){
                safeSHARDTransfer(msg.sender, pending);
            }
        }
        pool.usersTotalWeight = usersTotalWeight.sub(userWeight);
        user.amount = 0;
        user.originWeight = 0;
        user.endBlock = 0;
        IERC20(pool.lpTokenSwap).safeTransfer(address(msg.sender), amount);
        pool.lpTokenAmount = pool.lpTokenAmount.sub(amount);
        if (pool.lpTokenAmount == 0) pool.oracleWeight = 0;
        else {
            pool.oracleWeight = getOracleWeight(pool, pool.lpTokenAmount);
        }
        resetInvitationRelationship(_pid, msg.sender, originWeight);
        emit Withdraw(msg.sender, _pid, amount);
    }

    function addToRank(
        PoolInfo storage _pool,
        uint256 _pid
    ) private {
        if(_pid == 0){
            return;
        }
        massUpdatePools();
        _pool.lastDividendHeight = block.number;
        rankPoolIndex.push(_pid);
        rankPoolIndexMap[_pid] = rankPoolIndex.length;
        if(unDividendShard > 0){
            _pool.accumulativeDividend = _pool.accumulativeDividend.add(unDividendShard);
            unDividendShard = 0;
        }
        emit Replace(msg.sender, rankPoolIndex.length.sub(1), _pid);
        return;
    }

    function tryToReplacePoolInRank(uint256 _poolIndexInRank, uint256 _pid)
        public
        virtual
    {
        if(_pid == 0){
            return;
        }
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.lpTokenAmount > 0, "there is not any lp token depsoited");
        require(blackListMap[_pid] == 0, "pool is in the black list");
        if (rankPoolIndexMap[_pid] > 0) {
            return;
        }
        uint256 currentPoolCountInRank = rankPoolIndex.length;
        require(currentPoolCountInRank == maxRankNumber, "invalid operation");
        uint256 targetPid = rankPoolIndex[_poolIndexInRank];
        PoolInfo storage targetPool = poolInfo[targetPid];
        uint256 targetPoolOracleWeight = getOracleWeight(targetPool, targetPool.lpTokenAmount);
        uint256 challengerOracleWeight = getOracleWeight(pool, pool.lpTokenAmount);
        if (challengerOracleWeight <= targetPoolOracleWeight) {
            return;
        }
        updatePoolDividend(targetPid);
        rankPoolIndex[_poolIndexInRank] = _pid;
        delete rankPoolIndexMap[targetPid];
        rankPoolIndexMap[_pid] = _poolIndexInRank.add(1);
        pool.lastDividendHeight = block.number;
        emit Replace(msg.sender, _poolIndexInRank, _pid);
    }

    function acceptInvitation(address _invitor) public virtual override {
        require(_invitor != msg.sender, "invitee should not be invitor");
        buildInvitation(_invitor, msg.sender);
    }

    function buildInvitation(address _invitor, address _invitee) private {
        InvitationInfo storage invitee = usersRelationshipInfo[_invitee];
        require(!invitee.isUsed, "has accepted invitation");
        invitee.isUsed = true;
        InvitationInfo storage invitor = usersRelationshipInfo[_invitor];
        require(invitor.isUsed, "invitor has not acceptted invitation");
        invitee.invitor = _invitor;
        invitor.invitees.push(_invitee);
        invitor.inviteeIndexMap[_invitee] = invitor.invitees.length.sub(1);
    }

    function setMaxRankNumber(uint256 _count) public virtual {
        checkAdmin();
        require(_count > 0, "invalid count");
        if (maxRankNumber == _count) return;
        massUpdatePools();
        maxRankNumber = _count;
        uint256 currentPoolCountInRank = rankPoolIndex.length;
        if (_count >= currentPoolCountInRank) {
            return;
        }
        uint256 sparePoolCount = currentPoolCountInRank.sub(_count);
        uint256 lastPoolIndex = currentPoolCountInRank.sub(1);
        while (sparePoolCount > 0) {
            delete rankPoolIndexMap[rankPoolIndex[lastPoolIndex]];
            rankPoolIndex.pop();
            lastPoolIndex--;
            sparePoolCount--;
        }
    }

    function getModifiedRewardToken(uint256 _fromBlock, uint256 _toBlock)
        private
        view
        returns (uint256)
    {
        return
            getRewardToken(_fromBlock, _toBlock).mul(shardMintWeight).div(
                reserveMintWeight.add(shardMintWeight)
            );
    }

    function pendingSHARD(uint256 _pid, address _user)
        external
        view
        virtual
        returns (uint256 _pending, uint256 _potential, uint256 _blockNumber)
    {
        _blockNumber = block.number;
        (_pending, _potential) = calculatePendingSHARD(_pid, _user);
        
    }

    function pendingSHARDByPids(uint256[] memory _pids, address _user)
        external
        view
        virtual
        returns (uint256[] memory _pending, uint256[] memory _potential, uint256 _blockNumber)
    {
         uint256 poolCount = _pids.length;
        _pending = new uint256[](poolCount);
        _potential = new uint256[](poolCount);
        _blockNumber = block.number;
        for(uint i = 0; i < poolCount; i ++){
            (_pending[i], _potential[i]) = calculatePendingSHARD(_pids[i], _user);
        }
    }

    function calculatePendingSHARD(uint256 _pid, address _user) private view returns (uint256 _pending, uint256 _potential){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (user.amount == 0) {
            return (0, 0);
        }
        uint256 userModifiedWeight = getUserModifiedWeight(_pid, _user);
        _pending = pool.accumulativeDividend.mul(userModifiedWeight);
        _pending = _pending.div(pool.usersTotalWeight);
        bool isContractSender = isUserContractSender[_pid][_user];
        (,,_pending) = calculateDividend(_pending, _pid, user.amount, isContractSender);
        if (pool.lastDividendHeight >= block.number) {
            return (_pending, 0);
        }
        if (_pid != 0 && (rankPoolIndex.length == 0 || rankPoolIndexMap[_pid] == 0)) {
            return (_pending, 0);
        }
        uint256 poolReward = getModifiedRewardToken(pool.lastDividendHeight.add(1), block.number);
        uint256 numerator;
        uint256 denominator = otherPoolDividendWeight.add(shardPoolDividendWeight);
        if(_pid == 0){
            numerator = shardPoolDividendWeight;
        }
        else{
            numerator = otherPoolDividendWeight;
        }
        poolReward = poolReward       
            .mul(numerator)
            .div(denominator);
        if(_pid != 0){
            poolReward = poolReward.div(rankPoolIndex.length);
        }                          
        _potential = poolReward
            .mul(userModifiedWeight)
            .div(pool.usersTotalWeight);
        (,,_potential) = calculateDividend(_potential, _pid, user.amount, isContractSender);
    }

    function getDepositWeight(uint256 _lockAmount, uint256 _lockTime)
        private
        view
        returns (uint256)
    {
        if (_lockTime == 0) return 0;
        if (_lockTime.div(MAX_MONTH) > 1) _lockTime = MAX_MONTH;
        return depositTimeWeight[_lockTime.sub(1)].sub(500).mul(_lockAmount);
    }

    function getPoolLength() public view virtual returns (uint256) {
        return poolInfo.length;
    }

    function getPagePoolInfo(uint256 _fromIndex, uint256 _toIndex)
        public
        view
        virtual
        returns (
            uint256[] memory _nftPoolId,
            uint256[] memory _accumulativeDividend,
            uint256[] memory _usersTotalWeight,
            uint256[] memory _lpTokenAmount,
            uint256[] memory _oracleWeight,
            address[] memory _swapAddress
        )
    {
        uint256 poolCount = _toIndex.sub(_fromIndex).add(1);
        _nftPoolId = new uint256[](poolCount);
        _accumulativeDividend = new uint256[](poolCount);
        _usersTotalWeight = new uint256[](poolCount);
        _lpTokenAmount = new uint256[](poolCount);
        _oracleWeight = new uint256[](poolCount);
        _swapAddress = new address[](poolCount);
        uint256 startIndex = 0;
        for (uint256 i = _fromIndex; i <= _toIndex; i++) {
            PoolInfo storage pool = poolInfo[i];
            _nftPoolId[startIndex] = pool.nftPoolId;
            _accumulativeDividend[startIndex] = pool.accumulativeDividend;
            _usersTotalWeight[startIndex] = pool.usersTotalWeight;
            _lpTokenAmount[startIndex] = pool.lpTokenAmount;
            _oracleWeight[startIndex] = pool.oracleWeight;
            _swapAddress[startIndex] = pool.lpTokenSwap;
            startIndex++;
        }
    }

    function getInstantPagePoolInfo(uint256 _fromIndex, uint256 _toIndex)
    public
    virtual
    returns (
        uint256[] memory _nftPoolId,
        uint256[] memory _accumulativeDividend,
        uint256[] memory _usersTotalWeight,
        uint256[] memory _lpTokenAmount,
        uint256[] memory _oracleWeight,
        address[] memory _swapAddress
    )
    {
        uint256 poolCount = _toIndex.sub(_fromIndex).add(1);
        _nftPoolId = new uint256[](poolCount);
        _accumulativeDividend = new uint256[](poolCount);
        _usersTotalWeight = new uint256[](poolCount);
        _lpTokenAmount = new uint256[](poolCount);
        _oracleWeight = new uint256[](poolCount);
        _swapAddress = new address[](poolCount);
        uint256 startIndex = 0;
        for (uint256 i = _fromIndex; i <= _toIndex; i++) {
            PoolInfo storage pool = poolInfo[i];
            _nftPoolId[startIndex] = pool.nftPoolId;
            _accumulativeDividend[startIndex] = pool.accumulativeDividend;
            _usersTotalWeight[startIndex] = pool.usersTotalWeight;
            _lpTokenAmount[startIndex] = pool.lpTokenAmount;
            _oracleWeight[startIndex] = getOracleWeight(pool, _lpTokenAmount[startIndex]);
            _swapAddress[startIndex] = pool.lpTokenSwap;
            startIndex++;
        }
    }

    function getRankList() public view virtual returns (uint256[] memory) {
        uint256[] memory rankIdList = rankPoolIndex;
        return rankIdList;
    }

    function getBlackList()
        public
        view
        virtual
        returns (EvilPoolInfo[] memory _blackList)
    {
        _blackList = blackList;
    }

    function getInvitation(address _sender)
        public
        view
        virtual
        override
        returns (
            address _invitor,
            address[] memory _invitees,
            bool _isWithdrawn
        )
    {
        InvitationInfo storage invitation = usersRelationshipInfo[_sender];
        _invitees = invitation.invitees;
        _invitor = invitation.invitor;
        _isWithdrawn = invitation.isWithdrawn;
    }

    function getUserInfo(uint256 _pid, address _user)
        public
        view
        virtual
        returns (
            uint256 _amount,
            uint256 _originWeight,
            uint256 _modifiedWeight,
            uint256 _endBlock
        )
    {
        UserInfo storage user = userInfo[_pid][_user];
        _amount = user.amount;
        _originWeight = user.originWeight;
        _modifiedWeight = getUserModifiedWeight(_pid, _user);
        _endBlock = user.endBlock;
    }

    function getUserInfoByPids(uint256[] memory _pids, address _user)
        public
        view
        virtual
        returns (
            uint256[] memory _amount,
            uint256[] memory _originWeight,
            uint256[] memory _modifiedWeight,
            uint256[] memory _endBlock
        )
    {
        uint256 poolCount = _pids.length;
        _amount = new uint256[](poolCount);
        _originWeight = new uint256[](poolCount);
        _modifiedWeight = new uint256[](poolCount);
        _endBlock = new uint256[](poolCount);
        for(uint i = 0; i < poolCount; i ++){
            (_amount[i], _originWeight[i], _modifiedWeight[i], _endBlock[i]) = getUserInfo(_pids[i], _user);
        }
    }

    function getOracleInfo(uint256 _pid)
        public
        view
        virtual
        returns (
            address _swapToEthAddress,
            uint256 _priceCumulativeLast,
            uint256 _blockTimestampLast,
            uint256 _price,
            uint256 _lastPriceUpdateHeight
        )
    {
        PoolInfo storage pool = poolInfo[_pid];
        _swapToEthAddress = address(pool.tokenToEthPairInfo.tokenToEthSwap);
        _priceCumulativeLast = pool.tokenToEthPairInfo.priceCumulativeLast;
        _blockTimestampLast = pool.tokenToEthPairInfo.blockTimestampLast;
        _price = pool.tokenToEthPairInfo.price._x;
        _lastPriceUpdateHeight = pool.tokenToEthPairInfo.lastPriceUpdateHeight;
    }

    function safeSHARDTransfer(address _to, uint256 _amount) internal {
        uint256 SHARDBal = SHD.balanceOf(address(this));
        if (_amount > SHARDBal) {
            SHD.transfer(_to, SHARDBal);
        } else {
            SHD.transfer(_to, _amount);
        }
    }

    function updateUserInfo(
        UserInfo storage _user,
        uint256 _amount,
        uint256 _originWeight,
        uint256 _endBlock
    ) private {
        _user.amount = _amount;
        _user.originWeight = _originWeight;
        _user.endBlock = _endBlock;
    }

    function getOracleWeight(
        PoolInfo storage _pool,
        uint256 _amount
    ) private returns (uint256 _oracleWeight) {
        _oracleWeight = calculateOracleWeight(_pool, _amount);
        _pool.oracleWeight = _oracleWeight;
    }

    function calculateOracleWeight(PoolInfo storage _pool, uint256 _amount)
        private
        returns (uint256 _oracleWeight)
    {
        uint256 lpTokenTotalSupply =
            IUniswapV2Pair(_pool.lpTokenSwap).totalSupply();
        (uint112 shardReserve, uint112 wantTokenReserve, ) =
            IUniswapV2Pair(_pool.lpTokenSwap).getReserves();
        if (_amount == 0) {
            _amount = _pool.lpTokenAmount;
            if (_amount == 0) {
                return 0;
            }
        }
        if (!_pool.isFirstTokenShard) {
            uint112 wantToken = wantTokenReserve;
            wantTokenReserve = shardReserve;
            shardReserve = wantToken;
        }
        FixedPoint.uq112x112 memory price =
            updateTokenOracle(_pool.tokenToEthPairInfo);
        if (
            address(_pool.tokenToEthPairInfo.tokenToEthSwap) ==
            _pool.lpTokenSwap
        ) {
            _oracleWeight = uint256(price.mul(shardReserve).decode144())
                .mul(2)
                .mul(_amount)
                .div(lpTokenTotalSupply);
        } else {
            _oracleWeight = uint256(price.mul(wantTokenReserve).decode144())
                .mul(2)
                .mul(_amount)
                .div(lpTokenTotalSupply);
        }
    }

    function resetInvitationRelationship(
        uint256 _pid,
        address _user,
        uint256 _originWeight
    ) private {
        InvitationInfo storage senderRelationshipInfo =
            usersRelationshipInfo[_user];
        if (!senderRelationshipInfo.isWithdrawn){
            senderRelationshipInfo.isWithdrawn = true;
            InvitationInfo storage invitorRelationshipInfo =
            usersRelationshipInfo[senderRelationshipInfo.invitor];
            uint256 targetIndex = invitorRelationshipInfo.inviteeIndexMap[_user];
            uint256 inviteesCount = invitorRelationshipInfo.invitees.length;
            address lastInvitee =
            invitorRelationshipInfo.invitees[inviteesCount.sub(1)];
            invitorRelationshipInfo.inviteeIndexMap[lastInvitee] = targetIndex;
            invitorRelationshipInfo.invitees[targetIndex] = lastInvitee;
            delete invitorRelationshipInfo.inviteeIndexMap[_user];
            invitorRelationshipInfo.invitees.pop();
        }
        
        UserInfo storage invitorInfo =
            userInfo[_pid][senderRelationshipInfo.invitor];
        UserInfo storage user =
            userInfo[_pid][_user];
        if(!user.isCalculateInvitation){
            return;
        }
        user.isCalculateInvitation = false;
        uint256 inviteeToSubWeight = _originWeight.div(INVITEE_WEIGHT);
        invitorInfo.inviteeWeight = invitorInfo.inviteeWeight.sub(inviteeToSubWeight);
        if (invitorInfo.amount == 0){
            return;
        }
        PoolInfo storage pool = poolInfo[_pid];
        pool.usersTotalWeight = pool.usersTotalWeight.sub(inviteeToSubWeight);
    }

    function modifyWeightByInvitation(
        uint256 _pid,
        address _user,
        uint256 _oldOriginWeight,
        uint256 _newOriginWeight,
        uint256 _inviteeWeight,
        uint256 _existedAmount
    ) private{
        PoolInfo storage pool = poolInfo[_pid];
        InvitationInfo storage senderInfo = usersRelationshipInfo[_user];
        uint256 poolTotalWeight = pool.usersTotalWeight;
        poolTotalWeight = poolTotalWeight.sub(_oldOriginWeight).add(_newOriginWeight);
        if(_existedAmount == 0){
            poolTotalWeight = poolTotalWeight.add(_inviteeWeight);
        }     
        UserInfo storage user = userInfo[_pid][_user];
        if (!senderInfo.isWithdrawn || (_existedAmount > 0 && user.isCalculateInvitation)) {
            UserInfo storage invitorInfo = userInfo[_pid][senderInfo.invitor];
            user.isCalculateInvitation = true;
            uint256 addInviteeWeight =
                    _newOriginWeight.div(INVITEE_WEIGHT).sub(
                        _oldOriginWeight.div(INVITEE_WEIGHT)
                    );
            invitorInfo.inviteeWeight = invitorInfo.inviteeWeight.add(
                addInviteeWeight
            );
            uint256 addInvitorWeight = 
                    _newOriginWeight.div(INVITOR_WEIGHT).sub(
                        _oldOriginWeight.div(INVITOR_WEIGHT)
                    );
            
            poolTotalWeight = poolTotalWeight.add(addInvitorWeight);
            if (invitorInfo.amount > 0) {
                poolTotalWeight = poolTotalWeight.add(addInviteeWeight);
            } 
        }
        pool.usersTotalWeight = poolTotalWeight;
    }

    function verifyDescription(string memory description)
        internal
        pure
        returns (bool success)
    {
        bytes memory nameBytes = bytes(description);
        uint256 nameLength = nameBytes.length;
        require(nameLength > 0, "INVALID INPUT");
        success = true;
        bool n7;
        for (uint256 i = 0; i <= nameLength - 1; i++) {
            n7 = (nameBytes[i] & 0x80) == 0x80 ? true : false;
            if (n7) {
                success = false;
                break;
            }
        }
    }

    function getUserModifiedWeight(uint256 _pid, address _user) private view returns (uint256){
        UserInfo storage user =  userInfo[_pid][_user];
        uint256 originWeight = user.originWeight;
        uint256 modifiedWeight = originWeight.add(user.inviteeWeight);
        if(user.isCalculateInvitation){
            modifiedWeight = modifiedWeight.add(originWeight.div(INVITOR_WEIGHT));
        }
        return modifiedWeight;
    }

    function getRewardToken(uint256 _fromBlock, uint256 _toBlock) public view virtual returns (uint256){
        return calculateRewardToken(MINT_DECREASE_TERM, SHDPerBlock, startBlock, _fromBlock, _toBlock);
    }

    function calculateRewardToken(uint _term, uint256 _initialBlock, uint256 _startBlock, uint256 _fromBlock, uint256 _toBlock) private pure returns (uint256){
        if(_fromBlock > _toBlock || _startBlock > _toBlock)
            return 0;
        if(_startBlock > _fromBlock)
            _fromBlock = _startBlock;
        uint256 totalReward = 0;
        uint256 blockPeriod = _fromBlock.sub(_startBlock).add(1);
        uint256 yearPeriod = blockPeriod.div(_term);  // produce 5760 blocks per day, 2102400 blocks per year.
        for (uint256 i = 0; i < yearPeriod; i++){
            _initialBlock = _initialBlock.div(2);
        }
        uint256 termStartIndex = yearPeriod.add(1).mul(_term).add(_startBlock);
        uint256 beforeCalculateIndex = _fromBlock.sub(1);
        while(_toBlock >= termStartIndex && _initialBlock > 0){
            totalReward = totalReward.add(termStartIndex.sub(beforeCalculateIndex).mul(_initialBlock));
            beforeCalculateIndex = termStartIndex.add(1);
            _initialBlock = _initialBlock.div(2);
            termStartIndex = termStartIndex.add(_term);
        }
        if(_toBlock > beforeCalculateIndex){
            totalReward = totalReward.add(_toBlock.sub(beforeCalculateIndex).mul(_initialBlock));
        }
        return totalReward;
    }

    function getTargetTokenInSwap(IUniswapV2Pair _lpTokenSwap, address _targetToken) internal view returns (address, address, uint256){
        address token0 = _lpTokenSwap.token0();
        address token1 = _lpTokenSwap.token1();
        if(token0 == _targetToken){
            return(token0, token1, 0);
        }
        if(token1 == _targetToken){
            return(token0, token1, 1);
        }
        require(false, "invalid uniswap");
    }

    function generateOrcaleInfo(IUniswapV2Pair _pairSwap, bool _isFirstTokenEth) internal view returns(TokenPairInfo memory){
        uint256 priceTokenCumulativeLast = _isFirstTokenEth? _pairSwap.price1CumulativeLast(): _pairSwap.price0CumulativeLast();
        uint112 reserve0;
        uint112 reserve1;
        uint32 tokenBlockTimestampLast;
        (reserve0, reserve1, tokenBlockTimestampLast) = _pairSwap.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'ExampleOracleSimple: NO_RESERVES'); // ensure that there's liquidity in the pair
        TokenPairInfo memory tokenBInfo = TokenPairInfo({
            tokenToEthSwap: _pairSwap,
            isFirstTokenEth: _isFirstTokenEth,
            priceCumulativeLast: priceTokenCumulativeLast,
            blockTimestampLast: tokenBlockTimestampLast,
            price: FixedPoint.uq112x112(0),
            lastPriceUpdateHeight: block.number
        });
        return tokenBInfo;
    }

    function updateTokenOracle(TokenPairInfo storage _pairInfo) internal returns (FixedPoint.uq112x112 memory _price) {
        FixedPoint.uq112x112 memory cachedPrice = _pairInfo.price;
        if(cachedPrice._x > 0 && block.number.sub(_pairInfo.lastPriceUpdateHeight) <= updateTokenPriceTerm){
            return cachedPrice;
        }
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_pairInfo.tokenToEthSwap));
        uint32 timeElapsed = blockTimestamp - _pairInfo.blockTimestampLast; // overflow is desired
        if(_pairInfo.isFirstTokenEth){
            _price = FixedPoint.uq112x112(uint224(price1Cumulative.sub(_pairInfo.priceCumulativeLast).div(timeElapsed)));
            _pairInfo.priceCumulativeLast = price1Cumulative;
        }     
        else{
            _price = FixedPoint.uq112x112(uint224(price0Cumulative.sub(_pairInfo.priceCumulativeLast).div(timeElapsed)));
            _pairInfo.priceCumulativeLast = price0Cumulative;
        }
        _pairInfo.price = _price;
        _pairInfo.lastPriceUpdateHeight = block.number;
        _pairInfo.blockTimestampLast = blockTimestamp;
    }

    function updateAfterModifyStartBlock(uint256 _newStartBlock) internal override{
        lastRewardBlock = _newStartBlock.sub(1);
        if(poolInfo.length > 0){
            PoolInfo storage shdPool = poolInfo[0];
            shdPool.lastDividendHeight = lastRewardBlock;
        }
    }
}



pragma solidity 0.6.12;



contract ShardingDAOMiningDelegator is DelegatorInterface, ShardingDAOMining {
    constructor(
        SHDToken _SHD,
        address _wethToken,
        address _developerDAOFund,
        address _marketingFund,
        uint256 _maxRankNumber,
        uint256 _startBlock,
        address implementation_,
        bytes memory becomeImplementationData
    ) public {
        delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,address,address,address,uint256,uint256)",
                _SHD,
                _wethToken,
                _developerDAOFund,
                _marketingFund,
                _maxRankNumber,
                _startBlock
            )
        );
        admin = msg.sender;
        _setImplementation(implementation_, false, becomeImplementationData);
    }

    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public override {
        checkAdmin();
        if (allowResign) {
            delegateToImplementation(
                abi.encodeWithSignature("_resignImplementation()")
            );
        }

        address oldImplementation = implementation;
        implementation = implementation_;

        delegateToImplementation(
            abi.encodeWithSignature(
                "_becomeImplementation(bytes)",
                becomeImplementationData
            )
        );

        emit NewImplementation(oldImplementation, implementation);
    }

    function delegateTo(address callee, bytes memory data)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return returnData;
    }

    function delegateToImplementation(bytes memory data)
        public
        returns (bytes memory)
    {
        return delegateTo(implementation, data);
    }

    function delegateToViewImplementation(bytes memory data)
        public
        view
        returns (bytes memory)
    {
        (bool success, bytes memory returnData) =
            address(this).staticcall(
                abi.encodeWithSignature("delegateToImplementation(bytes)", data)
            );
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return abi.decode(returnData, (bytes));
    }

    fallback() external payable {
        if (msg.value > 0) return;
        (bool success, ) = implementation.delegatecall(msg.data);
        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())
            switch success
                case 0 {
                    revert(free_mem_ptr, returndatasize())
                }
                default {
                    return(free_mem_ptr, returndatasize())
                }
        }
    }

    function setNftShard(address _nftShard) public override {
        delegateToImplementation(
            abi.encodeWithSignature("setNftShard(address)", _nftShard)
        );
    }

    function add(
        uint256 _nftPoolId,
        IUniswapV2Pair _lpTokenSwap,
        IUniswapV2Pair _tokenToEthSwap
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "add(uint256,address,address)",
                _nftPoolId,
                _lpTokenSwap,
                _tokenToEthSwap
            )
        );
    }

    function setPriceUpdateTerm(uint256 _term) 
        public 
        override
    {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setPriceUpdateTerm(uint256)",
                _term
            )
        );
    }

    function kickEvilPoolByPid(uint256 _pid, string calldata description)
        public
        override
    {
        delegateToImplementation(
            abi.encodeWithSignature(
                "kickEvilPoolByPid(uint256,string)",
                _pid,
                description
            )
        );
    }

    function resetEvilPool(uint256 _pid)
        public
        override
    {
        delegateToImplementation(
            abi.encodeWithSignature(
                "resetEvilPool(uint256)",
                _pid
            )
        );
    }

    function setMintCoefficient(
        uint256 _nftMintWeight,
        uint256 _reserveMintWeight
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setMintCoefficient(uint256,uint256)",
                _nftMintWeight,
                _reserveMintWeight
            )
        );
    }

    function setShardPoolDividendWeight(
        uint256 _shardPoolWeight,
        uint256 _otherPoolWeight
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setShardPoolDividendWeight(uint256,uint256)",
                _shardPoolWeight,
                _otherPoolWeight
            )
        );
    }

    function setStartBlock(
        uint256 _startBlock
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setStartBlock(uint256)",
                _startBlock
            )
        );
    }

    function setSHDPerBlock(uint256 _shardPerBlock, bool _withUpdate) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setSHDPerBlock(uint256,bool)",
                _shardPerBlock,
                _withUpdate
            )
        );
    }

    function massUpdatePools() public override {
        delegateToImplementation(abi.encodeWithSignature("massUpdatePools()"));
    }

    function updatePoolDividend(uint256 _pid) public override {
        delegateToImplementation(
            abi.encodeWithSignature("updatePoolDividend(uint256)", _pid)
        );
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        uint256 _lockTime
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "deposit(uint256,uint256,uint256)",
                _pid,
                _amount,
                _lockTime
            )
        );
    }

    function withdraw(uint256 _pid) public override {
        delegateToImplementation(
            abi.encodeWithSignature("withdraw(uint256)", _pid)
        );
    }

    function tryToReplacePoolInRank(uint256 _poolIndexInRank, uint256 _pid)
        public
        override
    {
        delegateToImplementation(
            abi.encodeWithSignature(
                "tryToReplacePoolInRank(uint256,uint256)",
                _poolIndexInRank,
                _pid
            )
        );
    }

    function acceptInvitation(address _invitor) public override {
        delegateToImplementation(
            abi.encodeWithSignature("acceptInvitation(address)", _invitor)
        );
    }

    function setMaxRankNumber(uint256 _count) public override {
        delegateToImplementation(
            abi.encodeWithSignature("setMaxRankNumber(uint256)", _count)
        );
    }

    function setDeveloperDAOFund(
    address _developer
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setDeveloperDAOFund(address)",
                _developer
            )
        );
    }

    function setDividendWeight(
        uint256 _userDividendWeight,
        uint256 _devDividendWeight
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setDividendWeight(uint256,uint256)",
                _userDividendWeight,
                _devDividendWeight
            )
        );
    }

    function setTokenAmountLimit(
        uint256 _pid, 
        uint256 _tokenAmountLimit
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setTokenAmountLimit(uint256,uint256)",
                _pid,
                _tokenAmountLimit
            )
        );
    }

    function setTokenAmountLimitFeeRate(
        uint256 _feeRateNumerator,
        uint256 _feeRateDenominator
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setTokenAmountLimitFeeRate(uint256,uint256)",
                _feeRateNumerator,
                _feeRateDenominator
            )
        );
    }

    function setContracSenderFeeRate(
        uint256 _feeRateNumerator,
        uint256 _feeRateDenominator
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setContracSenderFeeRate(uint256,uint256)",
                _feeRateNumerator,
                _feeRateDenominator
            )
        );
    }

    function transferAdmin(
        address _admin
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "transferAdmin(address)",
                _admin
            )
        );
    }

    function setMarketingFund(
        address _marketingFund
    ) public override {
        delegateToImplementation(
            abi.encodeWithSignature(
                "setMarketingFund(address)",
                _marketingFund
            )
        );
    }

    function pendingSHARD(uint256 _pid, address _user)
        external
        view
        override
        returns (uint256, uint256, uint256)
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "pendingSHARD(uint256,address)",
                    _pid,
                    _user
                )
            );
        return abi.decode(data, (uint256, uint256, uint256));
    }

    function pendingSHARDByPids(uint256[] memory _pids, address _user)
        external
        view
        override
        returns (uint256[] memory _pending, uint256[] memory _potential, uint256 _blockNumber)
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "pendingSHARDByPids(uint256[],address)",
                    _pids,
                    _user
                )
            );
        return abi.decode(data, (uint256[], uint256[], uint256));
    }

    function getPoolLength() public view override returns (uint256) {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getPoolLength()")
            );
        return abi.decode(data, (uint256));
    }

    function getPagePoolInfo(uint256 _fromIndex, uint256 _toIndex)
        public
        view
        override
        returns (
            uint256[] memory _nftPoolId,
            uint256[] memory _accumulativeDividend,
            uint256[] memory _usersTotalWeight,
            uint256[] memory _lpTokenAmount,
            uint256[] memory _oracleWeight,
            address[] memory _swapAddress
        )
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "getPagePoolInfo(uint256,uint256)",
                    _fromIndex,
                    _toIndex
                )
            );
        return
            abi.decode(
                data,
                (
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[],
                    address[]
                )
            );
    }

    function getInstantPagePoolInfo(uint256 _fromIndex, uint256 _toIndex)
    public
    override
    returns (
        uint256[] memory _nftPoolId,
        uint256[] memory _accumulativeDividend,
        uint256[] memory _usersTotalWeight,
        uint256[] memory _lpTokenAmount,
        uint256[] memory _oracleWeight,
        address[] memory _swapAddress
    )
    {
        bytes memory data =
            delegateToImplementation(
                abi.encodeWithSignature(
                    "getInstantPagePoolInfo(uint256,uint256)",
                    _fromIndex,
                    _toIndex
                )
            );
        return
            abi.decode(
                data,
                (
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[],
                    address[]
                )
            );
    }

    function getRankList() public view override returns (uint256[] memory) {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getRankList()")
            );
        return abi.decode(data, (uint256[]));
    }

    function getBlackList()
        public
        view
        override
        returns (EvilPoolInfo[] memory _blackList)
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getBlackList()")
            );
        return abi.decode(data, (EvilPoolInfo[]));
    }

    function getInvitation(address _sender)
        public
        view
        override
        returns (
            address _invitor,
            address[] memory _invitees,
            bool _isWithdrawn
        )
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getInvitation(address)", _sender)
            );
        return abi.decode(data, (address, address[], bool));
    }

    function getUserInfo(uint256 _pid, address _sender)
        public
        view
        override
        returns (
            uint256 _amount,
            uint256 _originWeight,
            uint256 _modifiedWeight,
            uint256 _endBlock
        )
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "getUserInfo(uint256,address)",
                    _pid,
                    _sender
                )
            );
        return abi.decode(data, (uint256, uint256, uint256, uint256));
    }

    function getUserInfoByPids(uint256[] memory _pids, address _sender)
        public
        view
        override
        returns (
            uint256[] memory _amount,
            uint256[] memory _originWeight,
            uint256[] memory _modifiedWeight,
            uint256[] memory _endBlock
        )
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "getUserInfoByPids(uint256[],address)",
                    _pids,
                    _sender
                )
            );
        return abi.decode(data, (uint256[], uint256[], uint256[], uint256[]));
    }

    function getOracleInfo(uint256 _pid)
        public
        view
        override
        returns (
            address _swapToEthAddress,
            uint256 _priceCumulativeLast,
            uint256 _blockTimestampLast,
            uint256 _price,
            uint256 _lastPriceUpdateHeight
        )
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getOracleInfo(uint256)", _pid)
            );
        return abi.decode(data, (address, uint256, uint256, uint256, uint256));
    }

    function getRewardToken(uint256 _fromBlock, uint256 _toBlock)
        public
        view
        override
        returns (
            uint256
        )
    {
        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getRewardToken(uint256,uint256)", _fromBlock, _toBlock)
            );
        return abi.decode(data, (uint256));
    }
}