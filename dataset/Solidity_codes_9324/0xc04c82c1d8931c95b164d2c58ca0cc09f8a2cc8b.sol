
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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
}// AGPL-3.0
pragma solidity ^0.8;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0


interface IERC20Metadata is IERC20 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// AGPL-3.0

interface IBondingCalculator {

    function valuation( address pair_, uint amount_ ) external view returns ( uint _value );


    function getBondTokenValue( address _pair, uint amount_ ) external view returns ( uint _value );


    function getPrincipleTokenValue( address _pair, uint amount_ ) external view returns ( uint _value );


    function getPrincipleTokenValue( address _pairSwap, address _pairPrinciple, uint amount_ ) external view returns ( uint _value );


    function getBondTokenPrice( address _pair ) external view returns ( uint _value );


    function getBondTokenPrice( address _pairSwap, address _pairPrinciple ) external view returns ( uint _value );

}// AGPL-3.0-or-later

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

    function sqrrt(uint256 a) internal pure returns (uint c) {

        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}// AGPL-3.0


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

        return _functionCallWithValue(target, data, 0, errorMessage);
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

    function addressToString(address _address) internal pure returns(string memory) {

        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = "0";
        _addr[1] = "x";

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// AGPL-3.0-or-later

library FullMath {

    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {

        uint256 mm = mulmod(x, y, type(uint256).max);
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {

        uint256 pow2 = d & (type(uint256).max - d + 1);
        d /= pow2;
        l /= pow2;
        l += h * ((type(uint256).max - pow2 + 1) / pow2 + 1);
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
        require(h < d, "FullMath::mulDiv: overflow");
        return fullDiv(l, h, d);
    }
}// AGPL-3.0-or-later


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

library BitMath {


    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0, "BitMath::mostSignificantBit: zero");

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
}

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self) internal pure returns (uint) {

        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= type(uint144).max) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= type(uint224).max, "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= type(uint224).max, "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        }
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        if (self._x <= type(uint144).max) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}// AGPL-3.0-or-later



contract SwapBondDepository is Ownable, ReentrancyGuard {


    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using SafeMath for uint;


    event BondCreated( uint deposit, uint indexed payout, uint indexed expires, uint indexed priceInUSD );
    event BondRedeemed( address indexed recipient, uint payout, uint remaining );
    event BondPriceChanged( uint indexed priceInUSD, uint indexed internalPrice, uint indexed debtRatio );
    event ControlVariableAdjustment( uint initialBCV, uint newBCV, uint adjustment, bool addition );


    address public immutable SWAP; // token given as payment for bond
    address public immutable principal; // token used to create bond
    address public immutable treasury; // mints SWAP when receives principal
    address public immutable DAO; // receives profit share from bond

    bool public immutable isLiquidityBond; // LP and Reserve bonds are treated slightly different
    address public immutable bondCalculator; // calculates value of LP tokens
    address private pairAddressSwap;
    address private pairAddressPrinciple;

    Terms public terms; // stores terms for new bonds
    Adjust public adjustment; // stores adjustment to BCV data

    mapping( uint => mapping(address => Bond)) public bondInfo; // stores bond information for depositors
    mapping( address => bool ) public whitelist; // stores whitelist for minters

    uint public totalDebt; // total value of outstanding bonds; used for pricing
    uint public lastDecay; // reference timestamp for debt decay
    uint public constant CONTROL_VARIABLE_PRECISION = 10_000;



    struct Terms {
        uint controlVariable; // scaling variable for price, in hundreths
        uint[] vestingTerm; // in time
        uint minimumPrice; // vs principal value
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint[] fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
    }

    struct Bond {
        uint payout; // SWAP remaining to be paid
        uint vesting; // Time left to vest
        uint lastTimestamp; // Last interaction
        uint pricePaid; // In USDT, for front end viewing
    }

    struct Adjust {
        bool add; // addition or subtraction
        uint rate; // increment
        uint target; // BCV when adjustment finished
        uint buffer; // minimum length (in blocks) between adjustments
        uint lastTimestamp; // block when last adjustment made
    }


    constructor ( 
        address _SWAP,
        address _principal,
        address _treasury, 
        address _DAO, 
        address _bondCalculator,
        address _pairAddressSwap,
        address _pairAddressPrinciple
    ) {
        require( _SWAP != address(0) );
        SWAP = _SWAP;
        require( _principal != address(0) );
        principal = _principal;
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _DAO != address(0) );
        DAO = _DAO;
        bondCalculator = _bondCalculator;
        pairAddressSwap = _pairAddressSwap;
        pairAddressPrinciple = _pairAddressPrinciple;
        isLiquidityBond = ( _bondCalculator != address(0) );
        whitelist[_msgSender()] = true;
    }

    modifier onlyWhitelisted() {

        require(whitelist[_msgSender()], "Not Whitelisted");
        _;
    }

    modifier notContract(address _addr) {

        require(!isContract(_addr), "Contract address");
        _;
    }

    function updateWhitelist(address _target, bool _value) external onlyOwner {

        whitelist[_target] = _value;
    }

    function updatePairAddress(address _pair, bool _swap) external onlyOwner {

        if (_swap) {
            pairAddressSwap = _pair;
        } else {
            pairAddressPrinciple = _pair;
        }
    }

    function updateBatchWhitelist(address[] calldata _target, bool[] calldata _value) external onlyOwner {

        require(_target.length == _value.length, "Invalid request");
        for (uint256 index = 0; index < _target.length; index++) {
            whitelist[_target[index]] = _value[index];
        }
    }

    function initializeBondTerms( 
        uint _controlVariable, 
        uint[] calldata _vestingTerm,
        uint _minimumPrice,
        uint _maxPayout,
        uint[] calldata _fee,
        uint _maxDebt,
        uint _initialDebt
    ) external onlyOwner {

        require( terms.controlVariable == 0, "Bonds must be initialized from 0" );
        terms = Terms ({
            controlVariable: _controlVariable,
            vestingTerm: _vestingTerm,
            minimumPrice: _minimumPrice,
            maxPayout: _maxPayout,
            fee: _fee,
            maxDebt: _maxDebt
        });
        totalDebt = _initialDebt;
        lastDecay = block.timestamp;
    }

    

    enum PARAMETER { VESTING, PAYOUT, FEE, DEBT }
    function setBondTerms ( PARAMETER _parameter, uint _input, uint _term ) external onlyOwner {
        if ( _parameter == PARAMETER.VESTING ) { // 0
            require( _input >= 3, "Vesting must be longer than 3 days" );
            terms.vestingTerm[_term] = _input;
        } else if ( _parameter == PARAMETER.PAYOUT ) { // 1
            require( _input <= 1000, "Payout cannot be above 1 percent" );
            terms.maxPayout = _input;
        } else if ( _parameter == PARAMETER.FEE ) { // 2
            require( _input <= 10000, "DAO fee cannot exceed payout" );
            terms.fee[_term] = _input;
        } else if ( _parameter == PARAMETER.DEBT ) { // 3
            terms.maxDebt = _input;
        }
    }

    function setAdjustment ( 
        bool _addition,
        uint _increment, 
        uint _target,
        uint _buffer 
    ) external onlyOwner {
        require( _increment <= terms.controlVariable.mul( 25 ).div( 1000 ), "Increment too large" );

        adjustment = Adjust({
            add: _addition,
            rate: _increment,
            target: _target,
            buffer: _buffer,
            lastTimestamp: block.timestamp
        });
    }
    

    function deposit( 
        uint _amount, 
        uint _maxPrice,
        address _depositor,
        uint _term
    ) external onlyWhitelisted nonReentrant notContract(_msgSender()) returns ( uint ) {

        require( _depositor != address(0), "Invalid address" );

        require( totalDebt <= terms.maxDebt, "Max capacity reached" );
        
        uint priceInUSD = bondPriceInUSD(_term); // Stored in bond info
        uint nativePrice = _bondPrice();

        require( _maxPrice >= nativePrice, "Slippage limit: more than max price" ); // slippage protection

        uint value = tokenValue( principal, _amount );

        require( value >= 1e16, "Bond too small" ); // must be > 0.01 SWAP ( underflow protection )
        require( value <= maxPayout(), "Bond too large"); // size protection because there is no slippage

        uint payout = value.mul( nativePrice ).div( priceInUSD );

        IERC20( principal ).safeTransferFrom( msg.sender, address( treasury ), _amount );

        IERC20( SWAP ).safeTransferFrom(address( treasury ), address(this), payout);

        totalDebt = totalDebt.add( value ); 
                
        bondInfo[_term][ _depositor ] = Bond({ 
            payout: bondInfo[_term][ _depositor ].payout.add( payout ),
            vesting: terms.vestingTerm[_term] * 1 days,
            lastTimestamp: block.timestamp,
            pricePaid: priceInUSD
        });

        emit BondCreated( _amount, payout, block.timestamp.add( terms.vestingTerm[_term] * 1 days ), priceInUSD );
        emit BondPriceChanged( bondPriceInUSD(_term), _bondPrice(), debtRatio() );

        adjust(); // control variable is adjusted
        return payout; 
    }

    function redeem( address _recipient, uint _term ) external onlyWhitelisted nonReentrant notContract(_msgSender()) returns ( uint ) {        

        Bond memory info = bondInfo[_term][ _recipient ];
        uint percentVested = percentVestedFor( _recipient, _term ); // (blocks since last interaction / vesting term remaining)

        if ( percentVested >= 1e9 ) { // if fully vested
            delete bondInfo[_term][ _recipient ]; // delete user info
            emit BondRedeemed( _recipient, info.payout, 0 ); // emit bond data
            return sendTo( _recipient, info.payout ); // pay user everything due
        }
    }



    function sendTo( address _recipient, uint _amount ) internal returns ( uint ) {

        IERC20( SWAP ).transfer( _recipient, _amount ); // send payout
        return _amount;
    }

    function adjust() internal {

        uint blockCanAdjust = adjustment.lastTimestamp.add( adjustment.buffer );
        if( adjustment.rate != 0 && block.timestamp >= blockCanAdjust ) {
            uint initial = terms.controlVariable;
            if ( adjustment.add ) {
                terms.controlVariable = terms.controlVariable.add( adjustment.rate );
                if ( terms.controlVariable >= adjustment.target ) {
                    adjustment.rate = 0;
                }
            } else {
                terms.controlVariable = terms.controlVariable.sub( adjustment.rate );
                if ( terms.controlVariable <= adjustment.target ) {
                    adjustment.rate = 0;
                }
            }
            adjustment.lastTimestamp = block.timestamp;
            emit ControlVariableAdjustment( initial, terms.controlVariable, adjustment.rate, adjustment.add );
        }
    }

    function decayDebt() internal {

        totalDebt = totalDebt;
        lastDecay = block.timestamp;
    }



    function isContract(address _addr) private view returns (bool){

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function maxPayout() public view returns ( uint ) {

        return IERC20( SWAP ).totalSupply().mul( terms.maxPayout ).div( 100000 );
    }

    function bondPrice() internal view returns ( uint price_ ) {

        uint bondTokenPrice;
        if (pairAddressPrinciple != address(0)) {
            bondTokenPrice = IBondingCalculator( bondCalculator ).getBondTokenPrice( pairAddressSwap, pairAddressPrinciple );
        } else {
            bondTokenPrice = IBondingCalculator( bondCalculator ).getBondTokenPrice( pairAddressSwap );
        }
        price_ = CONTROL_VARIABLE_PRECISION.sub(terms.controlVariable).mul(bondTokenPrice).div(CONTROL_VARIABLE_PRECISION);

        if ( price_ < terms.minimumPrice ) {
            price_ = terms.minimumPrice;
        }
    }

    function _bondPrice() internal returns ( uint price_ ) {

        if (pairAddressPrinciple != address(0)) {
            price_ = IBondingCalculator( bondCalculator ).getBondTokenPrice( pairAddressSwap, pairAddressPrinciple );
        } else {
            price_ = IBondingCalculator( bondCalculator ).getBondTokenPrice( pairAddressSwap );
        }
        if ( price_ < terms.minimumPrice ) {
            price_ = terms.minimumPrice;        
        } else if ( terms.minimumPrice != 0 ) {
            terms.minimumPrice = 0;
        }
    }

    function tokenValue(address _token, uint256 _amount) internal view returns (uint256 value_) {

        if ( !isLiquidityBond ) {
            value_ = _amount.mul( 10 ** IERC20Metadata( SWAP ).decimals() ).div( 10 ** IERC20Metadata( _token ).decimals() );
        } else {
            if (pairAddressPrinciple != address(0)) {
                value_ = IBondingCalculator( bondCalculator ).getPrincipleTokenValue( pairAddressSwap, pairAddressPrinciple, _amount );
            } else {
                value_ = IBondingCalculator( bondCalculator ).getPrincipleTokenValue( pairAddressSwap, _amount );
            }
        }
    }

    function bondPriceInUSD(uint _term) public view returns ( uint price_ ) {

        if( isLiquidityBond ) {
            price_ = bondPrice().mul( CONTROL_VARIABLE_PRECISION - terms.fee[_term] ).div( CONTROL_VARIABLE_PRECISION );
        } else {
            price_ = bondPrice().mul( 10 ** IERC20Metadata( principal ).decimals() ).div( 100 );
        }
    }

    function debtRatio() public view returns ( uint debtRatio_ ) {   

        uint supply = IERC20( SWAP ).totalSupply();
        debtRatio_ = FixedPoint.fraction( 
            currentDebt().mul( 1e9 ), 
            supply
        ).decode112with18().div( 1e18 );
    }

    function currentDebt() public view returns ( uint ) {

        return totalDebt;
    }

    function percentVestedFor( address _depositor, uint _term ) public view returns ( uint percentVested_ ) {

        Bond memory bond = bondInfo[_term][ _depositor ];
        uint blocksSinceLast = block.timestamp.sub( bond.lastTimestamp );
        uint vesting = bond.vesting;

        if ( vesting > 0 && blocksSinceLast >= vesting ) {
            percentVested_ = 1e9;
        } else {
            percentVested_ = 0;
        }
    }

    function pendingPayoutFor( address _depositor, uint _term ) external view returns ( uint pendingPayout_ ) {

        uint percentVested = percentVestedFor( _depositor, _term );
        uint payout = bondInfo[_term][ _depositor ].payout;

        if ( percentVested >= 1e9 ) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul( percentVested ).div( 1e9 );
        }
    }



    function recoverLostToken( address _token ) external returns ( bool ) {

        require( _token != SWAP );
        require( _token != principal );
        IERC20( _token ).safeTransfer( DAO, IERC20( _token ).balanceOf( address(this) ) );
        return true;
    }
}