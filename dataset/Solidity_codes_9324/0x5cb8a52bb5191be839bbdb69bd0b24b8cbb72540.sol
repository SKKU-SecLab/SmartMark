

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

    mapping (uint256 => mapping (address => bool)) internal isUserContractSender;
    mapping (uint256 => uint256) public poolTokenAmountLimit;

    function setDividendWeight(uint256 _userDividendWeight, uint256 _devDividendWeight) external virtual{

        checkAdmin();
        require(
            _userDividendWeight != 0 && _devDividendWeight != 0,
            "invalid input"
        );
        userDividendWeight = _userDividendWeight;
        devDividendWeight = _devDividendWeight;
    }

    function setDeveloperDAOFund(address _developerDAOFund) external virtual onlyOwner {

        developerDAOFund = _developerDAOFund;
    }

    function setTokenAmountLimit(uint256 _pid, uint256 _tokenAmountLimit) external virtual {

        checkAdmin();
        poolTokenAmountLimit[_pid] = _tokenAmountLimit;
    }

    function setTokenAmountLimitFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) external virtual {

        checkAdmin();
        require(
            _feeRateDenominator >= _feeRateNumerator, "invalid input"
        );
        amountFeeRateNumerator = _feeRateNumerator;
        amountfeeRateDenominator = _feeRateDenominator;
    }

    function setContracSenderFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) external virtual {

        checkAdmin();
        require(
            _feeRateDenominator >= _feeRateNumerator, "invalid input"
        );
        contractFeeRateNumerator = _feeRateNumerator;
        contractFeeRateDenominator = _feeRateDenominator;
    }

    function setStartBlock(uint256 _startBlock) external virtual onlyOwner { 

        require(startBlock > block.number, "invalid start block");
        startBlock = _startBlock;
        updateAfterModifyStartBlock(_startBlock);
    }

    function transferAdmin(address _admin) external virtual {

        checkAdmin();
        admin = _admin;
    }

    function setMarketingFund(address _marketingFund) external virtual onlyOwner {

        marketingFund = _marketingFund;
    }

    function updateAfterModifyStartBlock(uint256 _newStartBlock) internal virtual{

    }

    function calculateDividend(uint256 _pending, uint256 _pid, uint256 _userAmount, bool _isContractSender) internal view returns (uint256 _marketingFundDividend, uint256 _devDividend, uint256 _userDividend){

        uint256 fee = 0;
        if(devDividendWeight > 0){
            fee = _pending.mul(devDividendWeight).div(devDividendWeight.add(userDividendWeight));
            _devDividend = _devDividend.add(fee);
            _pending = _pending.sub(fee);
        }
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
    uint256[] internal rankPoolIndex;
    mapping(uint256 => uint256) internal rankPoolIndexMap;
    mapping(address => InvitationInfo) internal usersRelationshipInfo;
    mapping(uint256 => mapping(address => UserInfo)) internal userInfo;
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
    uint256 internal shardMintWeight = 1;
    uint256 internal reserveMintWeight = 0;
    uint256 internal reserveToMint;
    EvilPoolInfo[] internal blackList;
    mapping(uint256 => uint256) internal blackListMap;
    uint256 public unDividendShard;
    uint256 public shardPoolDividendWeight = 2;
    uint256 public otherPoolDividendWeight = 8;

    mapping(uint256 => uint256) public poolAccs;
    struct UserRevenueInfo {
        uint256 userRewardDebt;
        uint256 revenue;
    }
    mapping(uint256 => mapping(address => UserRevenueInfo)) public userRevenueInfo;

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
    ) external onlyOwner{
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
        developerDAOFund = _developerDAOFund;
        marketingFund = _marketingFund;
        InvitationInfo storage initialInvitor =
            usersRelationshipInfo[address(this)];
        initialInvitor.isUsed =true;

        userDividendWeight = 8;
        devDividendWeight = 2;

        amountFeeRateNumerator = 0;
        amountfeeRateDenominator = 0;

        contractFeeRateNumerator = 1;
        contractFeeRateDenominator = 5;
    
        depositTimeWeight = [1238,1383,1495,1587,1665,1732,1790,1842,1888,1929,1966,2000,
                             2031,2059,2085,2108,2131,2152,2171,2189,2206,2221,2236,2250,
                             2263,2276,2287,2298,2309,2319,2328,2337,2346,2355,2363,2370];
    }

    function setNftShard(address _nftShard) external virtual {
        checkAdmin();
        nftShard = _nftShard;
    }

    function add(
        uint256 _nftPoolId,
        IUniswapV2Pair _lpTokenSwap,
        IUniswapV2Pair _tokenToEthSwap
    ) external virtual {
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

    function setPriceUpdateTerm(uint256 _term) external virtual onlyOwner{
        updateTokenPriceTerm = _term;
    }

    function kickEvilPoolByPid(uint256 _pid, string calldata description)
        external
        virtual
        onlyOwner
    {
        require(_pid > 0, "invalid pid");
        require(blackListMap[_pid] == 0, "pool has been added into blacklist");
        uint256 poolRankIndex = rankPoolIndexMap[_pid];
        uint256 addReward = 0;
        if (poolRankIndex > 0) {  
            PoolInfo storage pool = poolInfo[_pid];
            uint256 accumulativeDividendBeforeUpdate = pool.accumulativeDividend;
            massUpdatePools();
            uint256 lastPidInRank = rankPoolIndex[rankPoolIndex.length.sub(1)];
            rankPoolIndex[poolRankIndex.sub(1)] = lastPidInRank;
            rankPoolIndexMap[lastPidInRank] = poolRankIndex;
            delete rankPoolIndexMap[_pid];
            rankPoolIndex.pop();
            addReward = pool.accumulativeDividend.sub(accumulativeDividendBeforeUpdate);
            if(addReward > 0 && pool.usersTotalWeight > 0){
                poolAccs[_pid] = poolAccs[_pid].sub(addReward.mul(1e12).div(pool.usersTotalWeight));
            }
        }
        blackList.push(EvilPoolInfo({pid: _pid, description: description}));
        blackListMap[_pid] = blackList.length;
        dealEvilPoolDiviend(_pid, addReward);
        emit AddToBlacklist(_pid);
    }

    function resetEvilPool(uint256 _pid) external virtual onlyOwner {
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

    function dealEvilPoolDiviend(uint256 _pid, uint256 _undistributeDividend) private {
        PoolInfo storage pool = poolInfo[_pid];
        if (_undistributeDividend == 0) {
            return;
        }
        uint256 currentRankCount = rankPoolIndex.length;
        if (currentRankCount > 0) {
            uint256 averageDividend =
                _undistributeDividend.div(currentRankCount);
            for (uint256 i = 0; i < currentRankCount; i++) {
                uint256 currentPid = rankPoolIndex[i];
                PoolInfo storage poolInRank = poolInfo[currentPid];
                uint256 addDividend;
                if (i < currentRankCount - 1){
                    addDividend = averageDividend;
                    _undistributeDividend = _undistributeDividend.sub(averageDividend);
                }
                else{
                    addDividend = _undistributeDividend;
                }
                poolInRank.accumulativeDividend = poolInRank.accumulativeDividend.add(addDividend);
                if(poolInRank.usersTotalWeight > 0){
                    poolAccs[currentPid] = poolAccs[currentPid].add(addDividend.mul(1e12).div(poolInRank.usersTotalWeight));
                }
            }
        } else {
            unDividendShard = unDividendShard.add(_undistributeDividend);
        }
        pool.accumulativeDividend = pool.accumulativeDividend.sub(_undistributeDividend);
    }

    function setShardPoolDividendWeight(
        uint256 _shardPoolWeight,
        uint256 _otherPoolWeight
    ) external virtual {
        checkAdmin();
        require(
            _shardPoolWeight != 0 && _otherPoolWeight != 0,
            "invalid input"
        );
        massUpdatePools();
        shardPoolDividendWeight = _shardPoolWeight;
        otherPoolDividendWeight = _otherPoolWeight;
    }

    function setSHDPerBlock(uint256 _SHDPerBlock, bool _withUpdate) external virtual {
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
        if (totalReward > 0) {
            SHD.mint(_address, totalReward);
            lastRewardBlock = _toBlock;
        }
        return totalReward;
    }

    function updatePoolAccumulativeDividend(
        uint256 _pid,
        uint256 _validRankPoolCount,
        uint256 _toBlock
    ) private {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 accumulativeSHDPerWeight = poolAccs[_pid];
        uint256 existedDividend = pool.accumulativeDividend;
        if(accumulativeSHDPerWeight == 0 && existedDividend > 0 && pool.usersTotalWeight > 0){
            accumulativeSHDPerWeight = existedDividend.mul(1e12).div(pool.usersTotalWeight);
            poolAccs[_pid] = accumulativeSHDPerWeight;
        }
        if (pool.lastDividendHeight >= _toBlock) return;
        if (rankPoolIndexMap[_pid] == 0) {
            return;
        }
        uint256 poolReward =
            getRewardToken(pool.lastDividendHeight.add(1), _toBlock)
                                    .mul(otherPoolDividendWeight)
                                    .div(shardPoolDividendWeight.add(otherPoolDividendWeight));

        uint256 otherPoolReward = poolReward.div(_validRankPoolCount);                            
        pool.lastDividendHeight = _toBlock;
        existedDividend = existedDividend.add(otherPoolReward);
        pool.accumulativeDividend = existedDividend;
        if(pool.usersTotalWeight > 0){
            accumulativeSHDPerWeight = accumulativeSHDPerWeight.add(otherPoolReward.mul(1e12).div(pool.usersTotalWeight));
        }
        poolAccs[_pid] = accumulativeSHDPerWeight;
    }

    function updateSHARDPoolAccumulativeDividend (uint256 _toBlock) private{
        PoolInfo storage pool = poolInfo[0];
        uint256 existedDividend = pool.accumulativeDividend;
        uint256 accumulativeSHDPerWeight = poolAccs[0]; 
        if(accumulativeSHDPerWeight == 0 && existedDividend > 0 && pool.usersTotalWeight > 0){
            accumulativeSHDPerWeight = existedDividend.mul(1e12).div(pool.usersTotalWeight);
            poolAccs[0] = accumulativeSHDPerWeight;
        }
        if (pool.lastDividendHeight >= _toBlock) return;
        uint256 poolReward =
            getRewardToken(pool.lastDividendHeight.add(1), _toBlock);

        uint256 shardPoolDividend = poolReward.mul(shardPoolDividendWeight)
                                               .div(shardPoolDividendWeight.add(otherPoolDividendWeight));                              
        pool.lastDividendHeight = _toBlock;
        existedDividend = existedDividend.add(shardPoolDividend);
        pool.accumulativeDividend = existedDividend;
        if(pool.usersTotalWeight > 0){
            accumulativeSHDPerWeight = accumulativeSHDPerWeight.add(shardPoolDividend.mul(1e12).div(pool.usersTotalWeight));
        }
        poolAccs[0] = accumulativeSHDPerWeight;
    }

    struct InvitationRelationParam {
        uint256 pid;
        address user;
        uint256 addWeight;
        uint256 addInvitorWeight;
        uint256 addInviteeWeight;
        uint256 existedAmount;
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        uint256 _lockTime
    ) external virtual {
        require(_amount > 0, "invalid deposit amount");
        InvitationInfo storage senderInfo = usersRelationshipInfo[msg.sender];
        require(senderInfo.isUsed, "must accept an invitation firstly");
        require(_lockTime > 0 && _lockTime <= 36, "invalid lock time"); // less than 36 months
        updatePoolDividend(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lpTokenAmount = pool.lpTokenAmount.add(_amount);
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 newOriginWeight = user.originWeight;
        InvitationRelationParam memory p;  // Relieves stack pressure
        p.existedAmount = user.amount;
        uint256 endBlock = user.endBlock;
        uint256 newEndBlock =
            block.number.add(produceBlocksPerMonth.mul(_lockTime));
        if (p.existedAmount > 0) {
            if(newEndBlock < endBlock){
                newOriginWeight = newOriginWeight.add(getDepositWeight(
                    _amount,
                    endBlock.sub(block.number).div(produceBlocksPerMonth)
                ));
                newEndBlock = endBlock;
            }
            else{
                newOriginWeight = newOriginWeight.add(getDepositWeight(
                    _amount,
                    _lockTime
                ));
                newOriginWeight = newOriginWeight.add(getDepositWeight(
                    p.existedAmount,
                    newEndBlock.sub(endBlock).div(produceBlocksPerMonth)
                ));
            }
        } else {
            judgeContractSender(_pid);
            newOriginWeight = getDepositWeight(_amount, _lockTime);
        }
        p.pid = _pid;
        p.user = msg.sender;
        p.addWeight = newOriginWeight.sub(user.originWeight);
        p.addInvitorWeight = newOriginWeight.div(INVITOR_WEIGHT).sub(user.originWeight.div(INVITOR_WEIGHT));
        p.addInviteeWeight = newOriginWeight.div(INVITEE_WEIGHT).sub(user.originWeight.div(INVITEE_WEIGHT));
        modifyWeightByInvitation(p);
        user.amount = p.existedAmount.add(_amount);
        user.originWeight = newOriginWeight;
        user.endBlock = newEndBlock;
        IERC20(pool.lpTokenSwap).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.oracleWeight =  calculateOracleWeight(pool, lpTokenAmount);
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

    function withdraw(uint256 _pid) external virtual {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        require(amount > 0, "user is not existed");
        require(user.endBlock < block.number, "token is still locked");
        mintSHARD(address(this), block.number);
        updatePoolDividend(_pid);
        uint256 originWeight = user.originWeight;
        PoolInfo storage pool = poolInfo[_pid];
        uint256 userWeight = user.inviteeWeight.add(originWeight);
        if(user.isCalculateInvitation){
            userWeight = userWeight.add(originWeight.div(INVITOR_WEIGHT));
        }
        UserRevenueInfo storage senderRevenueInfo = userRevenueInfo[_pid][msg.sender];
        uint256 pending = poolAccs[_pid].mul(userWeight).div(1e12);
        pending = pending.sub(senderRevenueInfo.userRewardDebt);
        pending = pending.add(senderRevenueInfo.revenue);
        senderRevenueInfo.revenue = 0;
        if(pending > 0){
            pool.accumulativeDividend = pool.accumulativeDividend.sub(pending);
            dividendBonus(_pid, pending, amount, isUserContractSender[_pid][msg.sender]);
        }
        pool.usersTotalWeight = pool.usersTotalWeight.sub(userWeight);
        user.amount = 0;
        user.originWeight = 0;
        user.endBlock = 0;
        IERC20(pool.lpTokenSwap).safeTransfer(address(msg.sender), amount);
        pool.lpTokenAmount = pool.lpTokenAmount.sub(amount);
        if (pool.lpTokenAmount == 0) pool.oracleWeight = 0;
        else {
            pool.oracleWeight = calculateOracleWeight(pool, pool.lpTokenAmount);
        }
        resetInvitationRelationship(_pid, msg.sender, originWeight);
        emit Withdraw(msg.sender, _pid, amount);
    }

    function dividendBonus(uint256 _pid, uint256 _pending, uint256 _amount, bool _isContract) private {
        uint256 treasruyDividend;
        uint256 devDividend;
        (treasruyDividend, devDividend, _pending) = calculateDividend(_pending, _pid, _amount, _isContract);
        if(treasruyDividend > 0){
            safeSHARDTransfer(marketingFund, treasruyDividend);
        }
        if(devDividend > 0){
            safeSHARDTransfer(developerDAOFund, devDividend);
        }
        if(_pending > 0){
            safeSHARDTransfer(msg.sender, _pending);
        }
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
            if(_pool.usersTotalWeight > 0){
                poolAccs[_pid] = poolAccs[_pid].add(unDividendShard.mul(1e12).div(_pool.usersTotalWeight));
            }
            unDividendShard = 0;
        }
        emit Replace(msg.sender, rankPoolIndex.length.sub(1), _pid);
        return;
    }

    function tryToReplacePoolInRank(uint256 _poolIndexInRank, uint256 _pid)
        external
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
        targetPool.oracleWeight = calculateOracleWeight(targetPool, targetPool.lpTokenAmount);
        pool.oracleWeight = calculateOracleWeight(pool, pool.lpTokenAmount);
        if (pool.oracleWeight <= targetPool.oracleWeight) {
            return;
        }
        updatePoolDividend(targetPid);
        rankPoolIndex[_poolIndexInRank] = _pid;
        delete rankPoolIndexMap[targetPid];
        rankPoolIndexMap[_pid] = _poolIndexInRank.add(1);
        pool.lastDividendHeight = block.number;
        emit Replace(msg.sender, _poolIndexInRank, _pid);
    }

    function acceptInvitation(address _invitor) external virtual override {
        require(_invitor != msg.sender, "invitee should not be invitor");
        InvitationInfo storage invitee = usersRelationshipInfo[msg.sender];
        require(!invitee.isUsed, "has accepted invitation");
        invitee.isUsed = true;
        InvitationInfo storage invitor = usersRelationshipInfo[_invitor];
        require(invitor.isUsed, "invitor has not acceptted invitation");
        invitee.invitor = _invitor;
        invitor.invitees.push(msg.sender);
        invitor.inviteeIndexMap[msg.sender] = invitor.invitees.length.sub(1);
    }

    function setMaxRankNumber(uint256 _count) external virtual {
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
        UserRevenueInfo storage userRevenue = userRevenueInfo[_pid][_user];
        if (user.amount == 0) {
            return (0, 0);
        }
        uint256 userModifiedWeight = getUserModifiedWeight(_pid, _user);
        uint256 accumulativSHDPerWeight = poolAccs[_pid];
        if(accumulativSHDPerWeight == 0 && pool.accumulativeDividend > 0){
            accumulativSHDPerWeight = pool.accumulativeDividend.mul(1e12).div(pool.usersTotalWeight);
        }
        _pending = userRevenue.revenue;
        _pending = _pending.add(accumulativSHDPerWeight.mul(userModifiedWeight).div(1e12));
        _pending = _pending.sub(userRevenue.userRewardDebt);
        bool isContractSender = isUserContractSender[_pid][_user];
        (,,_pending) = calculateDividend(_pending, _pid, user.amount, isContractSender);
        if (pool.lastDividendHeight >= block.number) {
            return (_pending, 0);
        }
        if (_pid != 0 && (rankPoolIndex.length == 0 || rankPoolIndexMap[_pid] == 0)) {
            return (_pending, 0);
        }
        uint256 poolReward =
            getRewardToken(pool.lastDividendHeight.add(1), block.number);
        uint256 toBeDividend = poolReward.mul(shardPoolDividendWeight)
                                               .div(shardPoolDividendWeight.add(otherPoolDividendWeight));  
        if(_pid > 0){
            toBeDividend = poolReward.sub(toBeDividend).div(rankPoolIndex.length);
        }    
        _potential = toBeDividend.mul(userModifiedWeight).div(pool.usersTotalWeight);
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

    function getPoolLength() external view virtual returns (uint256) {
        return poolInfo.length;
    }

    function getInstantPagePoolInfo(uint256 _fromIndex, uint256 _toIndex)
    external
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
            _oracleWeight[startIndex] = calculateOracleWeight(pool, pool.lpTokenAmount);
            _swapAddress[startIndex] = pool.lpTokenSwap;
            startIndex++;
        }
    }

    function getRankList() external view virtual returns (uint256[] memory) {
        uint256[] memory rankIdList = rankPoolIndex;
        return rankIdList;
    }

    function getBlackList()
        external
        view
        virtual
        returns (EvilPoolInfo[] memory _blackList)
    {
        _blackList = blackList;
    }

    function getInvitation(address _sender)
        external
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

    function getUserInfoByPids(uint256[] memory _pids, address _user)
        external
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
             UserInfo storage user = userInfo[_pids[i]][_user];
            _amount[i] = user.amount;
            _originWeight[i] = user.originWeight;
            _modifiedWeight[i] = getUserModifiedWeight(_pids[i], _user);
            _endBlock[i] = user.endBlock;
        }
    }

    function safeSHARDTransfer(address _to, uint256 _amount) internal {
        uint256 SHARDBal = SHD.balanceOf(address(this));
        if (_amount > SHARDBal) {
            SHD.transfer(_to, SHARDBal);
        } else {
            SHD.transfer(_to, _amount);
        }
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
        FixedPoint.uq112x112 memory price;
        if(_pool.tokenToEthPairInfo.blockTimestampLast == 0){
            price = initializeTokenOracle(_pool.tokenToEthPairInfo);
        }
        else{
            price = updateTokenOracle(_pool.tokenToEthPairInfo);
        }
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
            cancleInvitation(senderRelationshipInfo, _user);
        }
        UserInfo storage invitorInfo =
            userInfo[_pid][senderRelationshipInfo.invitor];
        UserInfo storage user =
            userInfo[_pid][_user];
        if(!user.isCalculateInvitation){
            return;
        }
        user.isCalculateInvitation = false;
        uint256 invitorModifiedWeight = getUserModifiedWeight(_pid, senderRelationshipInfo.invitor);
        uint256 inviteeToSubWeight = _originWeight.div(INVITEE_WEIGHT);
        invitorInfo.inviteeWeight = invitorInfo.inviteeWeight.sub(inviteeToSubWeight);
        if (invitorInfo.amount == 0){
            return;
        }
        UserRevenueInfo storage invitorRevenueInfo = userRevenueInfo[_pid][senderRelationshipInfo.invitor];
        uint256 pending = poolAccs[_pid].mul(invitorModifiedWeight);
        pending = pending.div(1e12).sub(invitorRevenueInfo.userRewardDebt);
        invitorRevenueInfo.revenue = invitorRevenueInfo.revenue.add(pending);
        invitorModifiedWeight = invitorModifiedWeight.sub(inviteeToSubWeight);
        invitorRevenueInfo.userRewardDebt = poolAccs[_pid].mul(invitorModifiedWeight).div(1e12);
        PoolInfo storage pool = poolInfo[_pid];
        pool.usersTotalWeight = pool.usersTotalWeight.sub(inviteeToSubWeight);
    }

    function cancleInvitation(InvitationInfo storage senderRelationshipInfo, address _user) private{
        senderRelationshipInfo.isWithdrawn = true;
        InvitationInfo storage invitorRelationshipInfo = usersRelationshipInfo[senderRelationshipInfo.invitor];
        uint256 targetIndex = invitorRelationshipInfo.inviteeIndexMap[_user];
        uint256 inviteesCount = invitorRelationshipInfo.invitees.length;
        address lastInvitee = invitorRelationshipInfo.invitees[inviteesCount.sub(1)];
        invitorRelationshipInfo.inviteeIndexMap[lastInvitee] = targetIndex;
        invitorRelationshipInfo.invitees[targetIndex] = lastInvitee;
        delete invitorRelationshipInfo.inviteeIndexMap[_user];
        invitorRelationshipInfo.invitees.pop();
    }

    function modifyWeightByInvitation(
        InvitationRelationParam memory p
    ) private{
        PoolInfo storage pool = poolInfo[p.pid];
        InvitationInfo storage senderInfo = usersRelationshipInfo[p.user];
        uint256 poolTotalWeight = pool.usersTotalWeight.add(p.addWeight);
        uint256 senderTotalWeight = getUserModifiedWeight(p.pid, p.user);
        UserInfo storage user = userInfo[p.pid][p.user];
        uint256 poolSHDPerWeight = poolAccs[p.pid];
        UserRevenueInfo storage senderRevenueInfo = userRevenueInfo[p.pid][p.user];
        uint256 senderRevenue;
        if(p.existedAmount == 0){
            poolTotalWeight = poolTotalWeight.add(user.inviteeWeight);
            if(pool.usersTotalWeight == 0 && pool.accumulativeDividend > 0 && poolSHDPerWeight > 0){
                senderRevenue = pool.accumulativeDividend;
            }
        }else{
            senderRevenue = senderTotalWeight.mul(poolSHDPerWeight).div(1e12).sub(senderRevenueInfo.userRewardDebt);   
        }
        senderRevenueInfo.revenue = senderRevenueInfo.revenue.add(senderRevenue);
        senderTotalWeight = senderTotalWeight.add(p.addWeight);    
        if (!senderInfo.isWithdrawn || (p.existedAmount > 0 && user.isCalculateInvitation)) {
            senderTotalWeight = senderTotalWeight.add(p.addInvitorWeight);
            UserInfo storage invitorInfo = userInfo[p.pid][senderInfo.invitor];
            uint256 invitorModifiedWeight = getUserModifiedWeight(p.pid, senderInfo.invitor);
            user.isCalculateInvitation = true;
            invitorInfo.inviteeWeight = invitorInfo.inviteeWeight.add(p.addInviteeWeight);
            poolTotalWeight = poolTotalWeight.add(p.addInvitorWeight);
            if (invitorInfo.amount > 0) {
                poolTotalWeight = poolTotalWeight.add(p.addInviteeWeight);
                UserRevenueInfo storage invitorRevenueInfo = userRevenueInfo[p.pid][senderInfo.invitor];
                uint256 invitorRevenue = invitorModifiedWeight.mul(poolSHDPerWeight).div(1e12).sub(invitorRevenueInfo.userRewardDebt);
                invitorRevenueInfo.revenue = invitorRevenueInfo.revenue.add(invitorRevenue);
                uint256 invitorRewardDebt = invitorModifiedWeight.add(p.addInviteeWeight);
                invitorRewardDebt = invitorRewardDebt.mul(poolSHDPerWeight).div(1e12);
                invitorRevenueInfo.userRewardDebt = invitorRewardDebt;
            } 
        }
        senderRevenueInfo.userRewardDebt = senderTotalWeight.mul(poolSHDPerWeight).div(1e12);
        pool.usersTotalWeight = poolTotalWeight;
    }

    function getUserModifiedWeight(uint256 _pid, address _user) private view returns (uint256){
        UserInfo storage user =  userInfo[_pid][_user];
        if(user.amount == 0){
            return 0;
        }
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
        uint32 tokenBlockTimestampLast = 0;
        if(priceTokenCumulativeLast != 0){
            (, , tokenBlockTimestampLast) = _pairSwap.getReserves();
        }
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

    function initializeTokenOracle(TokenPairInfo storage _pairInfo) internal returns (FixedPoint.uq112x112 memory _price){
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed;
        uint256 initialPriceCumulative;
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(_pairInfo.tokenToEthSwap).getReserves();
        if(_pairInfo.isFirstTokenEth){
            _price = FixedPoint.fraction(reserve0, reserve1);
            initialPriceCumulative = IUniswapV2Pair(_pairInfo.tokenToEthSwap).price1CumulativeLast();
        }
        else{
            _price = FixedPoint.fraction(reserve1, reserve0);
            initialPriceCumulative = IUniswapV2Pair(_pairInfo.tokenToEthSwap).price0CumulativeLast();
        }
        _pairInfo.price = _price;
        timeElapsed = blockTimestamp - blockTimestampLast;
        initialPriceCumulative = initialPriceCumulative.add(uint(_price._x).mul(timeElapsed));
        _pairInfo.priceCumulativeLast = initialPriceCumulative;
        _pairInfo.lastPriceUpdateHeight = block.number;
        _pairInfo.blockTimestampLast = blockTimestamp;
        return _price;
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



contract ShardingDAOMiningDelegate is DelegateInterface, ShardingDAOMining {
    constructor() public {}

    function _becomeImplementation(bytes memory data)
        public
        override
    {
        checkAdmin();
        data;

        if (false) {
            implementation = address(0);
        }
    }

    function _resignImplementation() public override {
        checkAdmin();
        if (false) {
            implementation = address(0);
        }
    }
}