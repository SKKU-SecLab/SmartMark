
pragma solidity 0.7.5;
pragma abicoder v2;

interface IOwnable {

  function policy() external view returns (address);


  function renounceManagement() external;

  
  function pushManagement( address newOwner_ ) external;

  
  function pullManagement() external;

}

contract OwnableData {

    address public owner;
    address public pendingOwner;
}

contract Ownable is OwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

library LowGasSafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }

    function add32(uint32 x, uint32 y) internal pure returns (uint32 z) {

        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }

    function sub32(uint32 x, uint32 y) internal pure returns (uint32 z) {

        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(x == 0 || (z = x * y) / x == y);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x - y) <= x == (y >= 0));
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

    function functionCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 value, 
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 weiValue, 
        string memory errorMessage
    ) private returns (bytes memory) {

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

    function functionStaticCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success, 
        bytes memory returndata, 
        string memory errorMessage
    ) private pure returns(bytes memory) {

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

        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}
interface IERC20 {

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using LowGasSafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender)
            .sub(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library FullMath {

    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {

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
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
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
}

interface ITreasury {

    function deposit( uint _amount, address _token, uint _profit ) external returns ( uint send_ );

    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );

}

interface IBondCalculator {

    function valuation( address _LP, uint _amount ) external view returns ( uint );

    function markdown( address _LP ) external view returns ( uint );

    function marketPrice( address _LP ) external view returns ( uint );

}

interface IStaking {

    enum LOCKUPS { NONE, MONTH1, MONTH3, MONTH6 }
    function stake( uint _amount, address _recipient, LOCKUPS _lockup ) external returns ( bool );

}

interface IStakingHelper {

    function stake( uint _amount, address _recipient ) external;

    function stakeOneMonth( uint _amount, address _recipient ) external;

    function stakeThreeMonths( uint _amount, address _recipient ) external;

    function stakeSixMonths( uint _amount, address _recipient ) external;

}

contract SINBondDepository is Ownable {


    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using LowGasSafeMath for uint;
    using LowGasSafeMath for uint32;





    event BondCreated( uint deposit, uint indexed payout, uint indexed expires, uint indexed priceInUSD );
    event BondRedeemed( address indexed recipient, uint payout, uint remaining );
    event BondPriceChanged( uint indexed priceInUSD, uint indexed internalPrice, uint indexed debtRatio );
    event DiscountAdjustment( uint initialDiscount, uint newDiscount, uint adjustment, bool addition );
    event InitTerms( Terms terms);
    event LogSetTerms(PARAMETER param, uint value);
    event LogSetAdjustment( Adjust adjust);
    event LogSetStaking( address indexed stakingContract, bool isHelper);
    event LogRecoverLostToken( address indexed tokenToRecover, uint amount);




    IERC20 public immutable SIN; // token given as payment for bond
    IERC20 public immutable principle; // token used to create bond
    ITreasury public immutable treasury; // mints SIN when receives principle
    address public immutable DAO; // receives profit share from bond

    bool public immutable isLiquidityBond; // LP and Reserve bonds are treated slightly different
    IBondCalculator public immutable bondCalculator; // calculates value of LP tokens

    IStaking public staking; // to auto-stake payout
    IStakingHelper public stakingHelper; // to stake and claim if no staking warmup
    bool public useHelper;

    Terms public terms; // stores terms for new bonds
    Adjust public adjustment; // stores adjustment to BCV data

    mapping( address => Bond ) public bondInfo; // stores bond information for depositors

    uint public totalDebt; // total value of outstanding bonds; used for pricing
    uint32 public lastDecay; // reference time for debt decay

    mapping (address => bool) public allowedZappers;
    
    address public liquidityPool;




    struct Terms {
        uint discount; // scaling variable for price
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
        uint32 vestingTerm; // in seconds
    }

    struct Bond {
        uint payout; // SIN remaining to be paid
        uint pricePaid; // In DAI, for front end viewing
        uint32 lastTime; // Last interaction
        uint32 vesting; // Seconds left to vest
    }

    struct Adjust {
        bool add; // addition or subtraction
        uint rate; // increment
        uint target; // BCV when adjustment finished
        uint32 buffer; // minimum length (in seconds) between adjustments
        uint32 lastTime; // time when last adjustment made
    }





    constructor ( 
        address _SIN,
        address _principle,
        address _treasury, 
        address _DAO, 
        address _bondCalculator,
        address _liquidityPool,
        bool _isLiquidityBond
    ) {
        require( _SIN != address(0) );
        SIN = IERC20(_SIN);
        require( _principle != address(0) );
        principle = IERC20(_principle);
        require( _treasury != address(0) );
        treasury = ITreasury(_treasury);
        require( _DAO != address(0) );
        DAO = _DAO;
        bondCalculator = IBondCalculator(_bondCalculator);
        isLiquidityBond = _isLiquidityBond;
        liquidityPool = _liquidityPool;
    }

    function initializeBondTerms( 
        uint _discount, 
        uint _maxPayout,
        uint _fee,
        uint _maxDebt,
        uint32 _vestingTerm
    ) external onlyOwner() {

        require( terms.discount == 0, "Bonds must be initialized from 0" );
        require( _discount <= 10000, "Discount can't be more than 10000 percent" );
        require( _maxPayout <= 1000, "Payout cannot be above 1 percent" );
        require( _vestingTerm >= 129600, "Vesting must be longer than 36 hours" );
        require( _fee <= 10000, "DAO fee cannot exceed payout" );
        terms = Terms ({
            discount: _discount,
            maxPayout: _maxPayout,
            fee: _fee,
            maxDebt: _maxDebt,
            vestingTerm: _vestingTerm
        });
        lastDecay = uint32(block.timestamp);
        emit InitTerms(terms);
    }



    

    enum PARAMETER { VESTING, PAYOUT, FEE, DEBT}
    function setBondTerms ( PARAMETER _parameter, uint _input ) external onlyOwner() {
        if ( _parameter == PARAMETER.VESTING ) { // 0
            require( _input >= 129600, "Vesting must be longer than 36 hours" );
            terms.vestingTerm = uint32(_input);
        } else if ( _parameter == PARAMETER.PAYOUT ) { // 1
            require( _input <= 1000, "Payout cannot be above 1 percent" );
            terms.maxPayout = _input;
        } else if ( _parameter == PARAMETER.FEE ) { // 2
            require( _input <= 10000, "DAO fee cannot exceed payout" );
            terms.fee = _input;
        } else if ( _parameter == PARAMETER.DEBT ) { // 3
            terms.maxDebt = _input;
        }
        emit LogSetTerms(_parameter, _input);
    }

    function setAdjustment ( 
        bool _addition,
        uint _increment, 
        uint _target,
        uint32 _buffer 
    ) external onlyOwner() {
        require(_target <= 10000, "Target can't be more than 10000");
        require(_increment <= 200, "Increment can't be greater than 2 percent");
        adjustment = Adjust({
            add: _addition,
            rate: _increment,
            target: _target,
            buffer: _buffer,
            lastTime: uint32(block.timestamp)
        });
        emit LogSetAdjustment(adjustment);
    }

    function setStaking( address _staking, bool _helper ) external onlyOwner() {

        require( _staking != address(0), "IA" );
        if ( _helper ) {
            useHelper = true;
            stakingHelper = IStakingHelper(_staking);
        } else {
            useHelper = false;
            staking = IStaking(_staking);
        }
        emit LogSetStaking(_staking, _helper);
    }

    function allowZapper(address zapper) external onlyOwner {

        require(zapper != address(0), "ZNA");
        
        allowedZappers[zapper] = true;
    }

    function removeZapper(address zapper) external onlyOwner {

       
        allowedZappers[zapper] = false;
    }


    


    function deposit( 
        uint _amount, 
        uint _maxPrice,
        address _depositor
    ) external returns ( uint ) {

        require( _depositor != address(0), "Invalid address" );
        require(msg.sender == _depositor || allowedZappers[msg.sender], "LFNA");
        
        
        uint priceInUSD = bondPriceInUSD(); // Stored in bond info
        uint nativePrice = bondPrice();

        require( _maxPrice >= nativePrice, "Slippage limit: more than max price" ); // slippage protection

        uint value = treasury.valueOf( address(principle), _amount );
        uint payout = payoutFor( value ); // payout to bonder is computed
        require( totalDebt.add(value) <= terms.maxDebt, "Max capacity reached" );
        require( payout >= 10000000, "Bond too small" ); // must be > 0.01 SIN ( underflow protection )
        require( payout <= maxPayout(), "Bond too large"); // size protection because there is no slippage

        uint fee = payout.mul( terms.fee )/ 10000 ;
        uint profit = value.sub( payout ).sub( fee );

        principle.safeTransferFrom( msg.sender, address(this), _amount );
        principle.approve( address( treasury ), _amount );
        treasury.deposit( _amount, address(principle), profit );
        
        if ( fee != 0 ) { // fee is transferred to dao 
            SIN.safeTransfer( DAO, fee ); 
        }
        totalDebt = totalDebt.add( value ); 
                
        bondInfo[ _depositor ] = Bond({ 
            payout: bondInfo[ _depositor ].payout.add( payout ),
            vesting: terms.vestingTerm,
            lastTime: uint32(block.timestamp),
            pricePaid: priceInUSD
        });

        emit BondCreated( _amount, payout, block.timestamp.add( terms.vestingTerm ), priceInUSD );
        emit BondPriceChanged( bondPriceInUSD(), bondPrice(), debtRatio() );

        adjust(); // control variable is adjusted
        return payout; 
    }

    function redeem( address _recipient, bool _stake, IStaking.LOCKUPS _lockup ) external returns ( uint ) {

        require(msg.sender == _recipient, "NA");     
        Bond memory info = bondInfo[ _recipient ];
        uint percentVested = percentVestedFor( _recipient );

        if ( percentVested >= 10000 ) { // if fully vested
            delete bondInfo[ _recipient ]; // delete user info
            emit BondRedeemed( _recipient, info.payout, 0 ); // emit bond data
            return stakeOrSend( _recipient, _stake, info.payout, _lockup ); // pay user everything due

        } else { // if unfinished
            uint payout = info.payout.mul( percentVested ) / 10000 ;
            bondInfo[ _recipient ] = Bond({
                payout: info.payout.sub( payout ),
                vesting: info.vesting.sub32( uint32( block.timestamp ).sub32( info.lastTime ) ),
                lastTime: uint32(block.timestamp),
                pricePaid: info.pricePaid
            });

            emit BondRedeemed( _recipient, payout, bondInfo[ _recipient ].payout );
            return stakeOrSend( _recipient, _stake, payout, _lockup ); // pay user everything due
        }
    }



    


    function stakeOrSend( address _recipient, bool _stake, uint _amount, IStaking.LOCKUPS _lockup ) internal returns ( uint ) {

        if ( !_stake ) { // if user does not want to stake
            SIN.transfer( _recipient, _amount ); // send payout
        } else { // if user wants to stake
            if ( useHelper ) { // use if staking warmup is 0
                SIN.approve( address(stakingHelper), _amount );
                if (_lockup == IStaking.LOCKUPS.NONE){
                    stakingHelper.stake( _amount, _recipient );
                }
                if (_lockup == IStaking.LOCKUPS.MONTH1){
                    stakingHelper.stakeOneMonth( _amount, _recipient );
                }
                if (_lockup == IStaking.LOCKUPS.MONTH3){
                    stakingHelper.stakeThreeMonths( _amount, _recipient );
                }
                if (_lockup == IStaking.LOCKUPS.MONTH6){
                    stakingHelper.stakeSixMonths( _amount, _recipient );
                }
            } else {
                SIN.approve( address(staking), _amount );
                staking.stake( _amount, _recipient, _lockup);
            }
        }
        return _amount;
    }

    function adjust() internal {

        uint timeCanAdjust = adjustment.lastTime.add32( adjustment.buffer );
        if( adjustment.rate != 0 && block.timestamp >= timeCanAdjust ) {
            uint initial = terms.discount;
            uint discount = initial;
            if ( adjustment.add ) {
                discount = discount.add(adjustment.rate);
                if ( discount >= adjustment.target ) {
                    adjustment.rate = 0;
                    discount = adjustment.target;
                }
            } else {
                discount = discount.sub(adjustment.rate);
                if ( discount <= adjustment.target ) {
                    adjustment.rate = 0;
                    discount = adjustment.target;
                }
            }
            terms.discount = discount;
            adjustment.lastTime = uint32(block.timestamp);
            emit DiscountAdjustment( initial, discount, adjustment.rate, adjustment.add );
        }
    }




    function maxPayout() public view returns ( uint ) {

        return SIN.totalSupply().mul( terms.maxPayout ) / 100000 ;
    }

    function payoutFor( uint _value ) public view returns ( uint ) {

        return FixedPoint.fraction( _value, bondPrice() ).decode112with18() / 1e16 ;
    }


    function bondPrice() public view returns ( uint price_ ) {        

        uint current_price = bondCalculator.marketPrice(liquidityPool);
        price_ = current_price.sub(current_price.mul(terms.discount)/10000) / 1e7;
        return price_;
    }


    function bondPriceInUSD() public view returns ( uint price_ ) {

        return bondPrice().mul(1e16);
    }


    function debtRatio() public view returns ( uint debtRatio_ ) {   

        uint supply = SIN.totalSupply();
        debtRatio_ = FixedPoint.fraction( 
            currentDebt().mul( 1e9 ), 
            supply
        ).decode112with18() / 1e18;
    }

    function standardizedDebtRatio() external view returns ( uint ) {

        if ( isLiquidityBond ) {
            return debtRatio().mul( bondCalculator.markdown( address(principle) ) ) / 1e9;
        } else {
            return debtRatio();
        }
    }

    function currentDebt() public view returns ( uint ) {

        return totalDebt.sub( debtDecay() );
    }

    function debtDecay() public view returns ( uint decay_ ) {

        uint32 timeSinceLast = uint32(block.timestamp).sub32( lastDecay );
        decay_ = totalDebt.mul( timeSinceLast ) / terms.vestingTerm;
        if ( decay_ > totalDebt ) {
            decay_ = totalDebt;
        }
    }


    function percentVestedFor( address _depositor ) public view returns ( uint percentVested_ ) {

        Bond memory bond = bondInfo[ _depositor ];
        uint secondsSinceLast = uint32(block.timestamp).sub32( bond.lastTime );
        uint vesting = bond.vesting;

        if ( vesting > 0 ) {
            percentVested_ = secondsSinceLast.mul( 10000 ) / vesting;
        } else {
            percentVested_ = 0;
        }
    }

    function pendingPayoutFor( address _depositor ) external view returns ( uint pendingPayout_ ) {

        uint percentVested = percentVestedFor( _depositor );
        uint payout = bondInfo[ _depositor ].payout;

        if ( percentVested >= 10000 ) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul( percentVested ) / 10000;
        }
    }





    function recoverLostToken(IERC20 _token ) external returns ( bool ) {

        require( _token != SIN, "NAT" );
        require( _token != principle, "NAP" );
        uint balance = _token.balanceOf( address(this));
        _token.safeTransfer( DAO,  balance );
        emit LogRecoverLostToken(address(_token), balance);
        return true;
    }
}