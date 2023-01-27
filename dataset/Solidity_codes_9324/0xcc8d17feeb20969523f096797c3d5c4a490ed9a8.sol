


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;


abstract contract WarpVaultSCI {

      uint256 public totalReserves;
    function borrowBalanceCurrent(address account)
        public
        virtual
        returns (uint256);

    function borrowBalancePrior(address account)
        public
        view
        virtual
        returns (uint256);

    function exchangeRateCurrent() public virtual returns (uint256);

    function _borrow(uint256 _borrowAmount, address _borrower) external virtual;

    function _repayLiquidatedLoan(
        address _borrower,
        address _liquidator,
        uint256 _amount
    ) public virtual;

    function setNewInterestModel(address _newModel) public virtual;


    function transferOwnership(address _newOwner) public virtual;

    function getSCDecimals() public view virtual returns(uint8);
    function getSCAddress() public view virtual returns(address);

    function upgrade(address _warpControl) public virtual;
    function updateTeam(address _warpTeam) public virtual;

}


pragma solidity ^0.6.0;


abstract contract WarpVaultLPI {
    function getAssetAdd() public view virtual returns (address);


    function collateralOfAccount(address _account)
        public
        view
        virtual
        returns (uint256);

    function _liquidateAccount(address _account, address _liquidator)
        public
        virtual;

    function transferOwnership(address _newOwner) public virtual;

    function upgrade(address _warpControl) public virtual;

}


pragma solidity ^0.6.0;


abstract contract WarpVaultLPFactoryI {
    function createWarpVaultLP(uint256 _timelock, address _lp, string memory _lpName)
        public
        virtual
        returns (address);

    function transferOwnership(address _newOwner) public virtual;

}


pragma solidity ^0.6.0;


abstract contract WarpVaultSCFactoryI {
    function createNewWarpVaultSC(
        address _InterestRate,
        address _StableCoin,
        address _warpTeam,
        uint256 _initialExchangeRate,
        uint256 _timelock,
        uint256 _reserveFactorMantissa
    ) public virtual returns (address);

    function transferOwnership(address _newOwner) public virtual;

}


pragma solidity ^0.6.0;


abstract contract UniswapLPOracleFactoryI {

    function createNewOracles(
        address _tokenA,
        address _tokenB,
        address _lpToken
    ) public virtual;

    function OneUSDC() public virtual view returns (uint256);

    function getUnderlyingPrice(address _MMI)
        public
        virtual
        returns (uint256);

    function viewUnderlyingPrice(address _MMI)
        public
        view
        virtual
        returns (uint256);

    function getPriceOfToken(address _token, uint256 _amount) public virtual returns (uint256);
    function viewPriceOfToken(address token, uint256 _amount) public view virtual returns (uint256);

    function transferOwnership(address _newOwner) public virtual;

      function _calculatePriceOfLP(uint256 supply, uint256 value0, uint256 value1, uint8 supplyDecimals)
      public pure virtual returns (uint256);
}


pragma solidity ^0.6.0;


contract BaseJumpRateModelV2 {

    using SafeMath for uint;

    event NewInterestParams(uint baseRatePerBlock, uint multiplierPerBlock, uint jumpMultiplierPerBlock, uint kink);

    address public owner;

    uint public constant blocksPerYear = 2102400;

    uint public multiplierPerBlock;

    uint public baseRatePerBlock;

    uint public jumpMultiplierPerBlock;

    uint public kink;

    constructor(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_, address owner_) internal {
        owner = owner_;

        updateJumpRateModelInternal(baseRatePerYear,  multiplierPerYear, jumpMultiplierPerYear, kink_);
    }

    function updateJumpRateModel(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_) external {

        require(msg.sender == owner, "only the owner may call this function.");

        updateJumpRateModelInternal(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink_);
    }

    function utilizationRate(uint cash, uint borrows, uint reserves) public pure returns (uint) {

        if (borrows == 0) {
            return 0;
        }

        return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
    }

    function getBorrowRateInternal(uint cash, uint borrows, uint reserves) internal view returns (uint) {

        uint util = utilizationRate(cash, borrows, reserves);

        if (util <= kink) {
            return util.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
        } else {
            uint normalRate = kink.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
            uint excessUtil = util.sub(kink);
            return excessUtil.mul(jumpMultiplierPerBlock).div(1e18).add(normalRate);
        }
    }

    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) public  view returns (uint) {

        uint oneMinusReserveFactor = uint(1e18).sub(reserveFactorMantissa);
        uint borrowRate = getBorrowRateInternal(cash, borrows, reserves);
        uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
        return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
    }

    function updateJumpRateModelInternal(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_) internal {

        baseRatePerBlock = baseRatePerYear.div(blocksPerYear);
        multiplierPerBlock = (multiplierPerYear.mul(1e18)).div(blocksPerYear.mul(kink_));
        jumpMultiplierPerBlock = jumpMultiplierPerYear.div(blocksPerYear);
        kink = kink_;

        emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink);
    }


}


pragma solidity ^0.6.0;




contract JumpRateModelV2 is  BaseJumpRateModelV2  {


    function getBorrowRate(uint cash, uint borrows, uint reserves) external  view returns (uint) {

        return getBorrowRateInternal(cash, borrows, reserves);
    }

    constructor(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_, address owner_)
    	BaseJumpRateModelV2(baseRatePerYear,multiplierPerYear,jumpMultiplierPerYear,kink_,owner_) public {}
}


pragma solidity ^0.6.0;

contract CarefulMath {


    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {

        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {

        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}


pragma solidity ^0.6.0;


contract Exponential is CarefulMath {

    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {

        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {


        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {

        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {

        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) pure internal returns (uint) {

        return exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa <= right.mantissa;
    }

    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa > right.mantissa;
    }

    function isZeroExp(Exp memory value) pure internal returns (bool) {

        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {

        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {

        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {

        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {

        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {

        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}


pragma solidity ^0.6.0;











contract WarpControl is Ownable, Exponential {

    using SafeMath for uint256;

    UniswapLPOracleFactoryI public Oracle; //oracle factory contract interface
    WarpVaultLPFactoryI public WVLPF;
    WarpVaultSCFactoryI public WVSCF;
    address public warpTeam;
    address public newWarpControl;
    uint public graceSpace;

    address[] public lpVaults;
    address[] public scVaults;
    address[] public launchParticipants;
    address[] public groups;

    mapping(address => address) public instanceLPTracker; //maps LP token address to the assets WarpVault
    mapping(address => address) public instanceSCTracker;
    mapping(address => address) public getVaultByAsset;
    mapping(address => uint) public lockedLPValue;
    mapping(address => bool) public isVault;
    mapping(address => address[]) public refferalCodeTracker;
    mapping(address => string) public refferalCodeToGroupName;
    mapping(address => bool) public isParticipant;
    mapping(address => bool) public existingRefferalCode;
    mapping(address => bool) public isInGroup;
    mapping(address => address) public groupsYourIn;

    event NewLPVault(address _newVault);
    event NewSCVault(address _newVault, address _interestRateModel);
    event NewBorrow(address _borrower, address _StableCoin, uint _amountBorrowed);
    event NotCompliant(address _account, uint _time);
    event Liquidation(address _account, address liquidator);
    event complianceReset(address _account, uint _time);
    modifier onlyVault() {

        require(isVault[msg.sender] == true);
        _;
    }

    modifier onlyWarpT() {

        require(msg.sender == warpTeam);
        _;
    }

    constructor(
        address _oracle,
        address _WVLPF,
        address _WVSCF,
        address _warpTeam
    ) public {
        Oracle = UniswapLPOracleFactoryI(_oracle);
        WVLPF = WarpVaultLPFactoryI(_WVLPF);
        WVSCF = WarpVaultSCFactoryI(_WVSCF);
        warpTeam = _warpTeam;
    }

    function viewNumLPVaults() external view returns(uint256) {

        return lpVaults.length;
    }

    function viewNumSCVaults() external view returns(uint256) {

        return scVaults.length;
    }

    function viewLaunchParticipants() public view returns(address[] memory) {

      return launchParticipants;
    }

    function viewAllGroups() public view returns(address[] memory) {

      return groups;
    }

    function viewAllMembersOfAGroup(address _refferalCode) public view returns(address[] memory) {

      return refferalCodeTracker[_refferalCode];
    }

    function getGroupName(address _refferalCode) public view returns(string memory) {

      return refferalCodeToGroupName[_refferalCode];
    }

    function getAccountsGroup(address _account) public view returns(address) {

      return groupsYourIn[_account];
    }


    function createNewLPVault(
        uint256 _timelock,
        address _lp,
        address _lpAsset1,
        address _lpAsset2,
        string memory _lpName
    ) public onlyOwner {

        Oracle.createNewOracles(_lpAsset1, _lpAsset2, _lp);
        address _WarpVault = WVLPF.createWarpVaultLP(_timelock, _lp, _lpName);
        instanceLPTracker[_lp] = _WarpVault;
        lpVaults.push(_WarpVault);
        isVault[_WarpVault] = true;
        getVaultByAsset[_WarpVault] = _lp;
        emit NewLPVault(_WarpVault);
    }

    function createNewSCVault(
        uint256 _timelock,
        uint256 _baseRatePerYear,
        uint256 _multiplierPerYear,
        uint256 _jumpMultiplierPerYear,
        uint256 _optimal,
        uint256 _initialExchangeRate,
        uint256 _reserveFactorMantissa,
        address _StableCoin
    ) public onlyOwner {

        address IR = address(
            new JumpRateModelV2(
                _baseRatePerYear,
                _multiplierPerYear,
                _jumpMultiplierPerYear,
                _optimal,
                address(this)
            )
        );
        address _WarpVault = WVSCF.createNewWarpVaultSC(
            IR,
            _StableCoin,
            warpTeam,
            _initialExchangeRate,
            _timelock,
            _reserveFactorMantissa
        );
        instanceSCTracker[_StableCoin] = _WarpVault;
        scVaults.push(_WarpVault);
        isVault[_WarpVault] = true;
        getVaultByAsset[_WarpVault] = _StableCoin;
        emit NewSCVault(_WarpVault, IR);
    }

    function createGroup(string memory _groupName) public {

        require(isInGroup[msg.sender] == false, "Cant create a group once already in one");

        existingRefferalCode[msg.sender] = true;
        refferalCodeToGroupName[msg.sender] = _groupName;
        groups.push(msg.sender);

        refferalCodeTracker[msg.sender].push(msg.sender);
        isInGroup[msg.sender] = true;
        groupsYourIn[msg.sender] = msg.sender;

        launchParticipants.push(msg.sender);
    }

    function addMemberToGroup(address _refferalCode) public {

        require(isInGroup[msg.sender] == false, "Cant join more than one group");
        require(existingRefferalCode[_refferalCode] == true, "Group doesn't exist.");

        refferalCodeTracker[_refferalCode].push(msg.sender);
        isInGroup[msg.sender] = true;
        groupsYourIn[msg.sender] = _refferalCode;

        launchParticipants.push(msg.sender);
    }




    function getMaxWithdrawAllowed(address account, address lpToken) public returns (uint256) {

        uint256 borrowedTotal = getTotalBorrowedValue(account);
        uint256 collateralValue = getTotalAvailableCollateralValue(account);
        uint256 requiredCollateral = calcCollateralRequired(borrowedTotal);
        uint256 leftoverCollateral = collateralValue.sub(requiredCollateral);
        uint256 lpValue = Oracle.getUnderlyingPrice(lpToken);
        return leftoverCollateral.mul(1e18).div(lpValue);
    }

    function viewMaxWithdrawAllowed(address account, address lpToken) public view returns (uint256) {

        uint256 borrowedTotal = viewTotalBorrowedValue(account);
        uint256 collateralValue = viewTotalAvailableCollateralValue(account);
        uint256 requiredCollateral = calcCollateralRequired(borrowedTotal);
        uint256 leftoverCollateral = collateralValue.sub(requiredCollateral);
        uint256 lpValue = Oracle.viewUnderlyingPrice(lpToken);
        return leftoverCollateral.mul(1e18).div(lpValue);
    }

    function getTotalAvailableCollateralValue(address _account)
        public
        returns (uint256)
    {

        uint256 numVaults = lpVaults.length;
        uint256 totalCollateral = 0;
        for (uint256 i = 0; i < numVaults; ++i) {
            WarpVaultLPI vault = WarpVaultLPI(lpVaults[i]);
            address asset = vault.getAssetAdd();
            uint256 assetPrice = Oracle.getUnderlyingPrice(asset);

            uint256 accountCollateral = vault.collateralOfAccount(_account);

            uint256 accountAssetsValue = accountCollateral.mul(assetPrice);
            totalCollateral = totalCollateral.add(accountAssetsValue);
        }
        return totalCollateral.div(1e18);
    }

    function viewTotalAvailableCollateralValue(address _account)
        public
        view
        returns (uint256)
    {

        uint256 numVaults = lpVaults.length;
        uint256 totalCollateral = 0;
        for (uint256 i = 0; i < numVaults; ++i) {
            WarpVaultLPI vault = WarpVaultLPI(lpVaults[i]);
            address asset = vault.getAssetAdd();
            uint256 assetPrice = Oracle.viewUnderlyingPrice(asset);

            uint256 accountCollateral = vault.collateralOfAccount(_account);

            uint256 accountAssetsValue = accountCollateral.mul(assetPrice);
            totalCollateral = totalCollateral.add(accountAssetsValue);
        }
        return totalCollateral.div(1e18);
    }

    function viewPriceOfCollateral(address lpToken) public view returns(uint256)
    {

        return Oracle.viewUnderlyingPrice(lpToken);
    }

    function getPriceOfCollateral(address lpToken) public returns(uint256)
    {

        return Oracle.getUnderlyingPrice(lpToken);
    }

    function viewPriceOfToken(address token, uint256 amount) public view returns(uint256)
    {

        return Oracle.viewPriceOfToken(token, amount);
    }

    function getPriceOfToken(address token, uint256 amount) public returns(uint256)
    {

        return Oracle.getPriceOfToken(token, amount);
    }

    function viewTotalBorrowedValue(address _account) public view returns (uint256) {

        uint256 numSCVaults = scVaults.length;
        uint256 totalBorrowedValue = 0;
        for (uint256 i = 0; i < numSCVaults; ++i) {
            WarpVaultSCI WVSC = WarpVaultSCI(scVaults[i]);
            uint256 borrowBalanceInStable = WVSC.borrowBalancePrior(_account);
            if (borrowBalanceInStable == 0) {
                continue;
            }
            uint256 usdcBorrowedAmount = viewPriceOfToken(WVSC.getSCAddress(), borrowBalanceInStable);
            totalBorrowedValue = totalBorrowedValue.add(
                usdcBorrowedAmount
            );
        }
        return totalBorrowedValue;
    }

    function getTotalBorrowedValue(address _account) public returns (uint256) {

        uint256 numSCVaults = scVaults.length;
        uint256 totalBorrowedValue = 0;
        for (uint256 i = 0; i < numSCVaults; ++i) {
            WarpVaultSCI WVSC = WarpVaultSCI(scVaults[i]);
            uint borrowBalanceInStable = WVSC.borrowBalanceCurrent(_account);
            if (borrowBalanceInStable == 0) {
                continue;
            }
            uint256 usdcBorrowedAmount = getPriceOfToken(WVSC.getSCAddress(), borrowBalanceInStable);
            totalBorrowedValue = totalBorrowedValue.add(
                usdcBorrowedAmount
            );
        }
        return totalBorrowedValue;
    }

    function calcBorrowLimit(uint256 _collateralValue)
        public
        pure
        returns (uint256)
    {

        uint256 thirdCollatVal = _collateralValue.div(3);
        return thirdCollatVal.add(thirdCollatVal);
    }

    function calcCollateralRequired(uint256 _borrowAmount) public pure returns (uint256) {

        return _borrowAmount.mul(3).div(2);
    }

    function getBorrowLimit(address _account) public returns (uint256) {

        uint256 availibleCollateralValue = getTotalAvailableCollateralValue(
            _account
        );

        return calcBorrowLimit(availibleCollateralValue);
    }

    function viewBorrowLimit(address _account) public view returns (uint256) {

        uint256 availibleCollateralValue = viewTotalAvailableCollateralValue(
            _account
        );
        return calcBorrowLimit(availibleCollateralValue);
    }

    function borrowSC(address _StableCoin, uint256 _amount) public {

        uint256 borrowedTotalInUSDC = getTotalBorrowedValue(msg.sender);
        uint256 borrowLimitInUSDC = getBorrowLimit(msg.sender);
        uint256 borrowAmountAllowedInUSDC = borrowLimitInUSDC.sub(borrowedTotalInUSDC);

        uint256 borrowAmountInUSDC = getPriceOfToken(_StableCoin, _amount);

        require(borrowAmountAllowedInUSDC >= borrowAmountInUSDC, "Borrowing more than allowed");
        lockedLPValue[msg.sender] = lockedLPValue[msg.sender].add(_amount);
        WarpVaultSCI WV = WarpVaultSCI(instanceSCTracker[_StableCoin]);
        WV._borrow(_amount, msg.sender);
        emit NewBorrow(msg.sender, _StableCoin, _amount);
    }



    function liquidateAccount(address _borrower) public {

        require(msg.sender != _borrower, "you cant liquidate yourself");
        uint256 numSCVaults = scVaults.length;
        uint256 numLPVaults = lpVaults.length;
        uint256 borrowedAmount = 0;
        uint256[] memory scBalances = new uint256[](numSCVaults);
        for (uint256 i = 0; i < numSCVaults; ++i) {
            WarpVaultSCI scVault = WarpVaultSCI(scVaults[i]);
            scBalances[i] = scVault.borrowBalanceCurrent(_borrower);
            uint256 borrowedAmountInUSDC = viewPriceOfToken(getVaultByAsset[address(scVault)], scBalances[i]);

            borrowedAmount = borrowedAmount.add(borrowedAmountInUSDC);
        }
        uint256 borrowLimit = getBorrowLimit(_borrower);
        if (borrowLimit <= borrowedAmount) {
            for (uint256 i = 0; i < numSCVaults; ++i) {
                WarpVaultSCI scVault = WarpVaultSCI(scVaults[i]);
                scVault._repayLiquidatedLoan(
                    _borrower,
                    msg.sender,
                    scBalances[i]
                );
            }
            for (uint256 i = 0; i < numLPVaults; ++i) {
                WarpVaultLPI lpVault = WarpVaultLPI(lpVaults[i]);
                lpVault._liquidateAccount(_borrower, msg.sender);
            }
            emit Liquidation(_borrower, msg.sender);
        }
    }

    function updateInterestRateModel(
        address _token,
        uint256 _baseRatePerYear,
        uint256 _multiplierPerYear,
        uint256 _jumpMultiplierPerYear,
        uint256 _optimal
      ) public onlyWarpT {

      address IR = address(
          new JumpRateModelV2(
              _baseRatePerYear,
              _multiplierPerYear,
              _jumpMultiplierPerYear,
              _optimal,
              address(this)
          )
      );
      address vault = instanceSCTracker[_token];
      WarpVaultSCI WV = WarpVaultSCI(vault);
      WV.setNewInterestModel(IR);
    }

    function startUpgradeTimer(address _newWarpControl) public onlyWarpT{

      newWarpControl = _newWarpControl;
      graceSpace = now.add(172800);
    }

    function upgradeWarp() public onlyOwner {

      require(now >= graceSpace, "you cant ugrade yet, less than two days");
        uint256 numVaults = lpVaults.length;
        uint256 numSCVaults = scVaults.length;
      for (uint256 i = 0; i < numVaults; ++i) {
          WarpVaultLPI vault = WarpVaultLPI(lpVaults[i]);
          vault.upgrade(newWarpControl);
    }

      for (uint256 i = 0; i < numSCVaults; ++i) {
          WarpVaultSCI WVSC = WarpVaultSCI(scVaults[i]);
            WVSC.upgrade(newWarpControl);
        }
          WVLPF.transferOwnership(newWarpControl);
          WVSCF.transferOwnership(newWarpControl);
          Oracle.transferOwnership(newWarpControl);
  }

    function transferWarpTeam(address _newWarp) public onlyOwner {

        uint256 numSCVaults = scVaults.length;
        warpTeam = _newWarp;
        for (uint256 i = 0; i < numSCVaults; ++i) {
            WarpVaultSCI WVSC = WarpVaultSCI(scVaults[i]);
            WVSC.updateTeam(_newWarp);
        }
      
    }
}