

pragma solidity 0.6.6;


interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.6.0;

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


pragma solidity 0.6.6;




interface BondTokenInterface is IERC20 {

    event LogExpire(uint128 rateNumerator, uint128 rateDenominator, bool firstTime);

    function mint(address account, uint256 amount) external returns (bool success);


    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);


    function simpleBurn(address account, uint256 amount) external returns (bool success);


    function burn(uint256 amount) external returns (bool success);


    function burnAll() external returns (uint256 amount);


    function getRate() external view returns (uint128 rateNumerator, uint128 rateDenominator);

}


pragma solidity 0.6.6;


interface LatestPriceOracleInterface {

    function isWorking() external returns (bool);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);

}


pragma solidity 0.6.6;



interface PriceOracleInterface is LatestPriceOracleInterface {

    function latestId() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);

}


pragma solidity 0.6.6;


abstract contract AdvancedMath {
    int256 internal constant SQRT_2PI_E8 = 250662827;
    int256 internal constant PI_E8 = 314159265;
    int256 internal constant E_E8 = 271828182;
    int256 internal constant INV_E_E8 = 36787944; // 1/e
    int256 internal constant LOG2_E8 = 30102999;
    int256 internal constant LOG3_E8 = 47712125;

    int256 internal constant p = 23164190;
    int256 internal constant b1 = 31938153;
    int256 internal constant b2 = -35656378;
    int256 internal constant b3 = 178147793;
    int256 internal constant b4 = -182125597;
    int256 internal constant b5 = 133027442;

    function _sqrt(int256 x) internal pure returns (int256 y) {
        require(x >= 0, "cannot calculate the square root of a negative number");
        int256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function _logTaylor(int256 inputE4) internal pure returns (int256 outputE4) {
        require(inputE4 > 1, "input should be positive number");
        int256 inputE8 = inputE4 * 10**4;
        while (inputE8 < INV_E_E8) {
            inputE8 = (inputE8 * E_E8) / 10**8;
            outputE4 -= 10**4;
        }
        while (inputE8 > 10**8) {
            inputE8 = (inputE8 * INV_E_E8) / 10**8;
            outputE4 += 10**4;
        }
        outputE4 += _logTaylor1(inputE8 / 10**4 - 10**4);
    }

    function _logTaylor1(int256 inputE4) internal pure returns (int256 outputE4) {
        outputE4 =
            inputE4 -
            inputE4**2 /
            (2 * 10**4) +
            inputE4**3 /
            (3 * 10**8) -
            inputE4**4 /
            (4 * 10**12) +
            inputE4**5 /
            (5 * 10**16) -
            inputE4**6 /
            (6 * 10**20) +
            inputE4**7 /
            (7 * 10**24) -
            inputE4**8 /
            (8 * 10**28);
    }

    function _calcPnorm(int256 inputE4) internal pure returns (int256 outputE8) {
        require(inputE4 < 440 * 10**4 && inputE4 > -440 * 10**4, "input is too large");
        int256 _inputE4 = inputE4 > 0 ? inputE4 : inputE4 * (-1);
        int256 t = 10**16 / (10**8 + (p * _inputE4) / 10**4);
        int256 X2 = (inputE4 * inputE4) / 2;
        int256 exp2X2 = 10**8 +
            X2 +
            (X2**2 / (2 * 10**8)) +
            (X2**3 / (6 * 10**16)) +
            (X2**4 / (24 * 10**24)) +
            (X2**5 / (120 * 10**32)) +
            (X2**6 / (720 * 10**40));
        int256 Z = (10**24 / exp2X2) / SQRT_2PI_E8;
        int256 y = (b5 * t) / 10**8;
        y = ((y + b4) * t) / 10**8;
        y = ((y + b3) * t) / 10**8;
        y = ((y + b2) * t) / 10**8;
        y = 10**8 - (Z * ((y + b1) * t)) / 10**16;
        return inputE4 > 0 ? y : 10**8 - y;
    }
}


pragma solidity 0.6.6;



contract CallOptionCalculator is AdvancedMath {

    int256 internal constant SQRT_YEAR_E8 = 561569229926;

    int256 internal constant MIN_ND1_E8 = 0.0001 * 10**8;
    int256 internal constant MAX_ND1_E8 = 0.9999 * 10**8;

    function _calcLbtPrice(
        int256 etherPriceE4,
        int256 strikePriceE4,
        int256 nd1E8,
        int256 nd2E8
    ) public pure returns (int256 lbtPriceE4) {

        int256 lowestPriceE4 = (etherPriceE4 > strikePriceE4) ? etherPriceE4 - strikePriceE4 : 0; // max(etherPriceE8 - strikePriceE8, 0)
        lbtPriceE4 = (etherPriceE4 * (nd1E8) - (strikePriceE4 * nd2E8)) / 10**8; // mutable
        if (lbtPriceE4 < lowestPriceE4) {
            lbtPriceE4 = lowestPriceE4; // max(lbtPriceE8, lowestPriceE8)
        }
    }

    function _calcLbtLeverage(
        uint256 etherPriceE4,
        uint256 lbtPriceE4,
        int256 nd1E8
    ) public pure returns (uint256 lbtLeverageE4) {

        int256 modifiedNd1E8 = nd1E8 < MIN_ND1_E8 ? MIN_ND1_E8 : nd1E8 > MAX_ND1_E8
            ? MAX_ND1_E8
            : nd1E8; // clamp(MIN_ND1, nd1E4, MAX_ND1)
        return
            lbtPriceE4 != 0
                ? (uint256(modifiedNd1E8) * (etherPriceE4)) / (lbtPriceE4) / 10**4
                : 100 * 10**4;
    }

    function calcLbtPriceAndLeverage(
        int256 etherPriceE4,
        int256 strikePriceE4,
        int256 ethVolatilityE8,
        int256 untilMaturity
    )
        public
        pure
        returns (
            uint256 priceE4,
            uint256 leverageE4,
            int256 sigE8
        )
    {

        require(etherPriceE4 > 0, "the price of ETH should be positive");
        require(ethVolatilityE8 > 0, "the volatility of ETH should be positive");
        require(strikePriceE4 > 0, "the strike price should be positive");
        require(untilMaturity >= 0, "LBT should not have expired");
        require(untilMaturity <= 12 weeks, "the maturity of LBT should not be so distant");

        int256 nd1E8;
        {
            int256 spotPerStrikeE4 = (etherPriceE4 * (10**4)) / strikePriceE4;
            sigE8 = (ethVolatilityE8 * (_sqrt(untilMaturity)) * (10**8)) / (SQRT_YEAR_E8);

            int256 logSigE4 = _logTaylor(spotPerStrikeE4);
            int256 d1E4 = ((logSigE4 * 10**8) / sigE8) + (sigE8 / (2 * 10**4));
            nd1E8 = _calcPnorm(d1E4);

            int256 d2E4 = d1E4 - (sigE8 / 10**4);
            int256 nd2E8 = _calcPnorm(d2E4);
            if (nd1E8 > 0.0001 * 10**8 && nd2E8 > 0.0001 * 10**8) {
                int256 lbtPriceE4 = _calcLbtPrice(etherPriceE4, strikePriceE4, nd1E8, nd2E8);
                priceE4 = uint256(lbtPriceE4);
            }
        }

        leverageE4 = _calcLbtLeverage(uint256(etherPriceE4), priceE4, nd1E8);

        return (priceE4, leverageE4, sigE8);
    }
}


pragma solidity 0.6.6;



abstract contract TransferETH is TransferETHInterface {
    receive() external override payable {
        emit LogTransferETH(msg.sender, address(this), msg.value);
    }

    function _hasSufficientBalance(uint256 amount) internal view returns (bool ok) {
        address thisContract = address(this);
        return amount <= thisContract.balance;
    }

    function _transferETH(
        address payable recipient,
        uint256 amount,
        string memory errorMessage
    ) internal {
        require(_hasSufficientBalance(amount), errorMessage);
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "transferring Ether failed");
        emit LogTransferETH(address(this), recipient, amount);
    }

    function _transferETH(address payable recipient, uint256 amount) internal {
        _transferETH(recipient, amount, "TransferETH: transfer amount exceeds balance");
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

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}


pragma solidity ^0.6.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


pragma solidity ^0.6.0;






library SafeMathDivRoundUp {

    using SafeMath for uint256;

    function divRoundUp(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        require(b > 0, errorMessage);
        return ((a - 1) / b) + 1;
    }

    function divRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {

        return divRoundUp(a, b, "SafeMathDivRoundUp: modulo by zero");
    }
}


abstract contract UseSafeMath {
    using SafeMath for uint256;
    using SafeMathDivRoundUp for uint256;
    using SafeMath for uint64;
    using SafeMathDivRoundUp for uint64;
    using SafeMath for uint16;
    using SignedSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
}


pragma solidity 0.6.6;


interface BondMakerInterface {

    event LogNewBond(
        bytes32 indexed bondID,
        address indexed bondTokenAddress,
        uint256 indexed maturity,
        bytes32 fnMapID
    );

    event LogNewBondGroup(
        uint256 indexed bondGroupID,
        uint256 indexed maturity,
        uint64 indexed sbtStrikePrice,
        bytes32[] bondIDs
    );

    event LogIssueNewBonds(uint256 indexed bondGroupID, address indexed issuer, uint256 amount);

    event LogReverseBondGroupToCollateral(
        uint256 indexed bondGroupID,
        address indexed owner,
        uint256 amount
    );

    event LogExchangeEquivalentBonds(
        address indexed owner,
        uint256 indexed inputBondGroupID,
        uint256 indexed outputBondGroupID,
        uint256 amount
    );

    event LogLiquidateBond(bytes32 indexed bondID, uint128 rateNumerator, uint128 rateDenominator);

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            bytes32 fnMapID
        );


    function registerNewBondGroup(bytes32[] calldata bondIDList, uint256 maturity)
        external
        returns (uint256 bondGroupID);


    function reverseBondGroupToCollateral(uint256 bondGroupID, uint256 amount)
        external
        returns (bool success);


    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external returns (bool);


    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID)
        external
        returns (uint256 totalPayment);


    function collateralAddress() external view returns (address);


    function oracleAddress() external view returns (address);


    function feeTaker() external view returns (address);


    function decimalsOfBond() external view returns (uint8);


    function decimalsOfOraclePrice() external view returns (uint8);


    function maturityScale() external view returns (uint256);


    function getBond(bytes32 bondID)
        external
        view
        returns (
            address bondAddress,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function getFnMap(bytes32 fnMapID) external view returns (bytes memory fnMap);


    function getBondGroup(uint256 bondGroupID)
        external
        view
        returns (bytes32[] memory bondIDs, uint256 maturity);


    function generateFnMapID(bytes calldata fnMap) external view returns (bytes32 fnMapID);


    function generateBondID(uint256 maturity, bytes calldata fnMap)
        external
        view
        returns (bytes32 bondID);

}


pragma solidity 0.6.6;



interface BondMakerCollateralizedErc20Interface is BondMakerInterface {

    function issueNewBonds(uint256 bondGroupID) external returns (uint256 amount);

}


pragma solidity 0.6.6;


abstract contract Time {
    function _getBlockTimestampSec() internal view returns (uint256 unixtimesec) {
        unixtimesec = now; // solium-disable-line security/no-block-members
    }
}


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.2;

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
}


pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

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


pragma solidity 0.6.6;






abstract contract BondToken is Ownable, BondTokenInterface, ERC20 {
    struct Frac128x128 {
        uint128 numerator;
        uint128 denominator;
    }

    Frac128x128 internal _rate;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(address account, uint256 amount)
        public
        virtual
        override
        onlyOwner
        returns (bool success)
    {
        require(!_isExpired(), "this token contract has expired");
        _mint(account, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override(ERC20, IERC20)
        returns (bool success)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(ERC20, IERC20) returns (bool success) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function expire(uint128 rateNumerator, uint128 rateDenominator)
        public
        override
        onlyOwner
        returns (bool isFirstTime)
    {
        isFirstTime = !_isExpired();
        if (isFirstTime) {
            _setRate(Frac128x128(rateNumerator, rateDenominator));
        }

        emit LogExpire(rateNumerator, rateDenominator, isFirstTime);
    }

    function simpleBurn(address from, uint256 amount) public override onlyOwner returns (bool) {
        if (amount > balanceOf(from)) {
            return false;
        }

        _burn(from, amount);
        return true;
    }

    function burn(uint256 amount) public override returns (bool success) {
        if (!_isExpired()) {
            return false;
        }

        _burn(msg.sender, amount);

        if (_rate.numerator != 0) {
            uint8 decimalsOfCollateral = _getCollateralDecimals();
            uint256 withdrawAmount = _applyDecimalGap(amount, decimals(), decimalsOfCollateral)
                .mul(_rate.numerator)
                .div(_rate.denominator);

            _sendCollateralTo(msg.sender, withdrawAmount);
        }

        return true;
    }

    function burnAll() public override returns (uint256 amount) {
        amount = balanceOf(msg.sender);
        bool success = burn(amount);
        if (!success) {
            amount = 0;
        }
    }

    function _isExpired() internal view returns (bool) {
        return _rate.denominator != 0;
    }

    function getRate()
        public
        override
        view
        returns (uint128 rateNumerator, uint128 rateDenominator)
    {
        rateNumerator = _rate.numerator;
        rateDenominator = _rate.denominator;
    }

    function _setRate(Frac128x128 memory rate) internal {
        require(
            rate.denominator != 0,
            "system error: the exchange rate must be non-negative number"
        );
        _rate = rate;
    }

    function _applyDecimalGap(
        uint256 baseAmount,
        uint8 decimalsOfBase,
        uint8 decimalsOfQuote
    ) internal pure returns (uint256 quoteAmount) {
        uint256 n;
        uint256 d;

        if (decimalsOfBase > decimalsOfQuote) {
            d = decimalsOfBase - decimalsOfQuote;
        } else if (decimalsOfBase < decimalsOfQuote) {
            n = decimalsOfQuote - decimalsOfBase;
        }

        require(n < 19 && d < 19, "decimal gap needs to be lower than 19");
        quoteAmount = baseAmount.mul(10**n).div(10**d);
    }

    function _getCollateralDecimals() internal virtual view returns (uint8);

    function _sendCollateralTo(address receiver, uint256 amount) internal virtual;
}


pragma solidity 0.6.6;



contract BondTokenCollateralizedErc20 is BondToken {
    ERC20 internal immutable COLLATERALIZED_TOKEN;

    constructor(
        address collateralizedTokenAddress,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public BondToken(name, symbol, decimals) {
        COLLATERALIZED_TOKEN = ERC20(collateralizedTokenAddress);
    }

    function _getCollateralDecimals() internal override view returns (uint8) {
        return COLLATERALIZED_TOKEN.decimals();
    }

    function _sendCollateralTo(address receiver, uint256 amount) internal override {
        COLLATERALIZED_TOKEN.transfer(receiver, amount);
    }
}


pragma solidity 0.6.6;




contract BondTokenCollateralizedEth is BondToken, TransferETH {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public BondToken(name, symbol, decimals) {}

    function _getCollateralDecimals() internal override view returns (uint8) {
        return 18;
    }

    function _sendCollateralTo(address receiver, uint256 amount) internal override {
        _transferETH(payable(receiver), amount);
    }
}


pragma solidity 0.6.6;




contract BondTokenFactory {
    address private constant ETH = address(0);

    function createBondToken(
        address collateralizedTokenAddress,
        string calldata name,
        string calldata symbol,
        uint8 decimals
    ) external returns (address) {
        if (collateralizedTokenAddress == ETH) {
            BondTokenCollateralizedEth bond = new BondTokenCollateralizedEth(
                name,
                symbol,
                decimals
            );
            bond.transferOwnership(msg.sender);
            return address(bond);
        } else {
            BondTokenCollateralizedErc20 bond = new BondTokenCollateralizedErc20(
                collateralizedTokenAddress,
                name,
                symbol,
                decimals
            );
            bond.transferOwnership(msg.sender);
            return address(bond);
        }
    }
}


pragma solidity 0.6.6;



contract Polyline is UseSafeMath {
    struct Point {
        uint64 x; // Value of the x-axis of the x-y plane
        uint64 y; // Value of the y-axis of the x-y plane
    }

    struct LineSegment {
        Point left; // The left end of the line definition range
        Point right; // The right end of the line definition range
    }

    function _mapXtoY(LineSegment memory line, uint64 x)
        internal
        pure
        returns (uint128 numerator, uint64 denominator)
    {
        int256 x1 = int256(line.left.x);
        int256 y1 = int256(line.left.y);
        int256 x2 = int256(line.right.x);
        int256 y2 = int256(line.right.y);

        require(x2 > x1, "must be left.x < right.x");

        denominator = uint64(x2 - x1);

        int256 n = (x - x1) * y2 + (x2 - x) * y1;

        require(n >= 0, "underflow n");
        require(n < 2**128, "system error: overflow n");
        numerator = uint128(n);
    }

    function assertLineSegment(LineSegment memory segment) internal pure {
        uint64 x1 = segment.left.x;
        uint64 x2 = segment.right.x;
        require(x1 < x2, "must be left.x < right.x");
    }

    function assertPolyline(LineSegment[] memory polyline) internal pure {
        uint256 numOfSegment = polyline.length;
        require(numOfSegment != 0, "polyline must not be empty array");

        LineSegment memory firstSegment = polyline[0];

        require(
            firstSegment.left.x == uint64(0),
            "the x coordinate of left end of the first segment must be 0"
        );
        require(
            firstSegment.left.y == uint64(0),
            "the y coordinate of left end of the first segment must be 0"
        );

        LineSegment memory lastSegment = polyline[numOfSegment - 1];

        int256 gradientNumerator = int256(lastSegment.right.y).sub(lastSegment.left.y);
        int256 gradientDenominator = int256(lastSegment.right.x).sub(lastSegment.left.x);
        require(
            gradientNumerator >= 0 && gradientNumerator <= gradientDenominator,
            "the gradient of last line segment must be non-negative, and equal to or less than 1"
        );

        assertLineSegment(firstSegment);

        for (uint256 i = 1; i < numOfSegment; i++) {
            LineSegment memory leftSegment = polyline[i - 1];
            LineSegment memory rightSegment = polyline[i];

            assertLineSegment(rightSegment);

            require(
                leftSegment.right.x == rightSegment.left.x,
                "given polyline has an undefined domain."
            );

            require(
                leftSegment.right.y == rightSegment.left.y,
                "given polyline is not a continuous function"
            );
        }
    }

    function zipLineSegment(LineSegment memory segment) internal pure returns (uint256 zip) {
        uint256 x1U256 = uint256(segment.left.x) << (64 + 64 + 64); // uint64
        uint256 y1U256 = uint256(segment.left.y) << (64 + 64); // uint64
        uint256 x2U256 = uint256(segment.right.x) << 64; // uint64
        uint256 y2U256 = uint256(segment.right.y); // uint64
        zip = x1U256 | y1U256 | x2U256 | y2U256;
    }

    function unzipLineSegment(uint256 zip) internal pure returns (LineSegment memory) {
        uint64 x1 = uint64(zip >> (64 + 64 + 64));
        uint64 y1 = uint64(zip >> (64 + 64));
        uint64 x2 = uint64(zip >> 64);
        uint64 y2 = uint64(zip);
        return LineSegment({left: Point({x: x1, y: y1}), right: Point({x: x2, y: y2})});
    }

    function decodePolyline(bytes memory fnMap) internal pure returns (uint256[] memory) {
        return abi.decode(fnMap, (uint256[]));
    }
}


pragma solidity ^0.6.6;



interface OracleInterface is PriceOracleInterface {
    function getVolatility() external returns (uint256);

    function lastCalculatedVolatility() external view returns (uint256);
}


pragma solidity 0.6.6;



abstract contract UseOracle {
    OracleInterface internal _oracleContract;

    constructor(address contractAddress) public {
        require(contractAddress != address(0), "contract should be non-zero address");
        _oracleContract = OracleInterface(contractAddress);
    }
    function _getOracleData() internal returns (uint256 priceE8, uint256 volatilityE8) {
        priceE8 = _oracleContract.latestPrice();
        volatilityE8 = _oracleContract.lastCalculatedVolatility();

        return (priceE8, volatilityE8);
    }
    function _getPriceOn(uint256 timestamp, uint256 hintID) internal returns (uint256 priceE8) {
        uint256 latestID = _oracleContract.latestId();
        require(latestID != 0, "system error: the ID of oracle data should not be zero");

        require(hintID != 0, "the hint ID must not be zero");
        uint256 id = hintID;
        if (hintID > latestID) {
            id = latestID;
        }

        require(
            _oracleContract.getTimestamp(id) > timestamp,
            "there is no price data after maturity"
        );

        id--;
        while (id != 0) {
            if (_oracleContract.getTimestamp(id) <= timestamp) {
                break;
            }
            id--;
        }

        return _oracleContract.getPrice(id + 1);
    }
}


pragma solidity ^0.6.6;


interface BondTokenNameInterface {
    function genBondTokenName(
        string calldata shortNamePrefix,
        string calldata longNamePrefix,
        uint256 maturity,
        uint256 solidStrikePriceE4
    ) external pure returns (string memory shortName, string memory longName);

    function getBondTokenName(
        uint256 maturity,
        uint256 solidStrikePriceE4,
        uint256 rateLBTWorthlessE4
    ) external pure returns (string memory shortName, string memory longName);
}


pragma solidity 0.6.6;



abstract contract UseBondTokenName {
    BondTokenNameInterface internal immutable _bondTokenNameContract;

    constructor(address contractAddress) public {
        require(contractAddress != address(0), "contract should be non-zero address");
        _bondTokenNameContract = BondTokenNameInterface(contractAddress);
    }
}


pragma solidity 0.6.6;









abstract contract BondMaker is UseSafeMath, BondMakerInterface, Time, Polyline, UseOracle {
    uint8 internal immutable DECIMALS_OF_BOND;
    uint8 internal immutable DECIMALS_OF_ORACLE_PRICE;
    address internal immutable FEE_TAKER;
    uint256 internal immutable MATURITY_SCALE;

    uint256 public nextBondGroupID = 1;

    struct BondInfo {
        uint256 maturity;
        BondTokenInterface contractInstance;
        uint64 strikePrice;
        bytes32 fnMapID;
    }
    mapping(bytes32 => BondInfo) internal _bonds;

    mapping(bytes32 => LineSegment[]) internal _registeredFnMap;

    struct BondGroup {
        bytes32[] bondIDs;
        uint256 maturity;
    }
    mapping(uint256 => BondGroup) internal _bondGroupList;

    constructor(
        address oracleAddress,
        address feeTaker,
        uint256 maturityScale,
        uint8 decimalsOfBond,
        uint8 decimalsOfOraclePrice
    ) public UseOracle(oracleAddress) {
        require(decimalsOfBond < 19, "the decimals of bond must be less than 19");
        DECIMALS_OF_BOND = decimalsOfBond;
        require(decimalsOfOraclePrice < 19, "the decimals of oracle price must be less than 19");
        DECIMALS_OF_ORACLE_PRICE = decimalsOfOraclePrice;
        require(feeTaker != address(0), "the fee taker must be non-zero address");
        FEE_TAKER = feeTaker;
        require(maturityScale != 0, "MATURITY_SCALE must be positive");
        MATURITY_SCALE = maturityScale;
    }

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        virtual
        override
        returns (
            bytes32,
            address,
            bytes32
        )
    {
        _assertBeforeMaturity(maturity);
        require(maturity < _getBlockTimestampSec() + 365 days, "the maturity is too far");
        require(
            maturity % MATURITY_SCALE == 0,
            "the maturity must be the multiple of MATURITY_SCALE"
        );

        bytes32 bondID = generateBondID(maturity, fnMap);

        require(
            address(_bonds[bondID].contractInstance) == address(0),
            "the bond type has been already registered"
        );

        bytes32 fnMapID = generateFnMapID(fnMap);
        uint64 sbtStrikePrice;
        if (_registeredFnMap[fnMapID].length == 0) {
            uint256[] memory polyline = decodePolyline(fnMap);
            for (uint256 i = 0; i < polyline.length; i++) {
                _registeredFnMap[fnMapID].push(unzipLineSegment(polyline[i]));
            }

            LineSegment[] memory segments = _registeredFnMap[fnMapID];
            assertPolyline(segments);
            require(!_isBondWorthless(segments), "the bond is 0-value at any price");
            sbtStrikePrice = _getSbtStrikePrice(segments);
        } else {
            LineSegment[] memory segments = _registeredFnMap[fnMapID];
            sbtStrikePrice = _getSbtStrikePrice(segments);
        }

        BondTokenInterface bondTokenContract = _createNewBondToken(maturity, fnMap);

        _bonds[bondID] = BondInfo({
            maturity: maturity,
            contractInstance: bondTokenContract,
            strikePrice: sbtStrikePrice,
            fnMapID: fnMapID
        });

        emit LogNewBond(bondID, address(bondTokenContract), maturity, fnMapID);

        return (bondID, address(bondTokenContract), fnMapID);
    }

    function _assertBondGroup(bytes32[] memory bondIDs, uint256 maturity) internal view {
        require(bondIDs.length >= 2, "the bond group should consist of 2 or more bonds");

        uint256 numOfBreakPoints = 0;
        for (uint256 i = 0; i < bondIDs.length; i++) {
            BondInfo storage bond = _bonds[bondIDs[i]];
            require(bond.maturity == maturity, "the maturity of the bonds must be same");
            LineSegment[] storage polyline = _registeredFnMap[bond.fnMapID];
            numOfBreakPoints = numOfBreakPoints.add(polyline.length);
        }

        uint256 nextBreakPointIndex = 0;
        uint64[] memory rateBreakPoints = new uint64[](numOfBreakPoints);
        for (uint256 i = 0; i < bondIDs.length; i++) {
            BondInfo storage bond = _bonds[bondIDs[i]];
            LineSegment[] storage segments = _registeredFnMap[bond.fnMapID];
            for (uint256 j = 0; j < segments.length; j++) {
                uint64 breakPoint = segments[j].right.x;
                bool ok = false;

                for (uint256 k = 0; k < nextBreakPointIndex; k++) {
                    if (rateBreakPoints[k] == breakPoint) {
                        ok = true;
                        break;
                    }
                }

                if (ok) {
                    continue;
                }

                rateBreakPoints[nextBreakPointIndex] = breakPoint;
                nextBreakPointIndex++;
            }
        }

        for (uint256 k = 0; k < rateBreakPoints.length; k++) {
            uint64 rate = rateBreakPoints[k];
            uint256 totalBondPriceN = 0;
            uint256 totalBondPriceD = 1;
            for (uint256 i = 0; i < bondIDs.length; i++) {
                BondInfo storage bond = _bonds[bondIDs[i]];
                LineSegment[] storage segments = _registeredFnMap[bond.fnMapID];
                (uint256 segmentIndex, bool ok) = _correspondSegment(segments, rate);

                require(ok, "invalid domain expression");

                (uint128 n, uint64 d) = _mapXtoY(segments[segmentIndex], rate);

                if (n != 0) {
                    totalBondPriceN = totalBondPriceD.mul(n).add(totalBondPriceN.mul(d));
                    totalBondPriceD = totalBondPriceD.mul(d);
                }
            }
            require(
                totalBondPriceN == totalBondPriceD.mul(rate),
                "the total price at any rateBreakPoints should be the same value as the rate"
            );
        }
    }

    function registerNewBondGroup(bytes32[] calldata bondIDs, uint256 maturity)
        external
        virtual
        override
        returns (uint256 bondGroupID)
    {
        _assertBondGroup(bondIDs, maturity);

        (, , uint64 sbtStrikePrice, ) = getBond(bondIDs[0]);
        require(sbtStrikePrice != 0, "the first bond must be SBT");

        bondGroupID = nextBondGroupID;
        nextBondGroupID = nextBondGroupID.add(1);

        _bondGroupList[bondGroupID] = BondGroup(bondIDs, maturity);

        emit LogNewBondGroup(bondGroupID, maturity, sbtStrikePrice, bondIDs);

        return bondGroupID;
    }

    function _issueNewBonds(uint256 bondGroupID, uint256 collateralAmountWithFee)
        internal
        returns (uint256 bondAmount)
    {
        (bytes32[] memory bondIDs, uint256 maturity) = getBondGroup(bondGroupID);
        _assertNonEmptyBondGroup(bondIDs);
        _assertBeforeMaturity(maturity);

        uint256 fee = collateralAmountWithFee.mul(2).divRoundUp(1002);

        uint8 decimalsOfCollateral = _getCollateralDecimals();
        bondAmount = _applyDecimalGap(
            collateralAmountWithFee.sub(fee),
            decimalsOfCollateral,
            DECIMALS_OF_BOND
        );
        require(bondAmount != 0, "the minting amount must be non-zero");

        for (uint256 i = 0; i < bondIDs.length; i++) {
            _mintBond(bondIDs[i], msg.sender, bondAmount);
        }

        emit LogIssueNewBonds(bondGroupID, msg.sender, bondAmount);
    }

    function reverseBondGroupToCollateral(uint256 bondGroupID, uint256 bondAmount)
        external
        virtual
        override
        returns (bool)
    {
        (bytes32[] memory bondIDs, uint256 maturity) = getBondGroup(bondGroupID);
        _assertNonEmptyBondGroup(bondIDs);
        _assertBeforeMaturity(maturity);
        for (uint256 i = 0; i < bondIDs.length; i++) {
            _burnBond(bondIDs[i], msg.sender, bondAmount);
        }

        uint8 decimalsOfCollateral = _getCollateralDecimals();
        uint256 collateralAmount = _applyDecimalGap(
            bondAmount,
            DECIMALS_OF_BOND,
            decimalsOfCollateral
        );
        _sendCollateralTo(msg.sender, collateralAmount);

        emit LogReverseBondGroupToCollateral(bondGroupID, msg.sender, collateralAmount);

        return true;
    }

    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external virtual override returns (bool) {
        (bytes32[] memory inputIDs, uint256 inputMaturity) = getBondGroup(inputBondGroupID);
        _assertNonEmptyBondGroup(inputIDs);
        (bytes32[] memory outputIDs, uint256 outputMaturity) = getBondGroup(outputBondGroupID);
        _assertNonEmptyBondGroup(outputIDs);
        require(inputMaturity == outputMaturity, "cannot exchange bonds with different maturities");
        _assertBeforeMaturity(inputMaturity);

        bool flag;
        uint256 exceptionCount;
        for (uint256 i = 0; i < inputIDs.length; i++) {
            flag = true;
            for (uint256 j = 0; j < exceptionBonds.length; j++) {
                if (exceptionBonds[j] == inputIDs[i]) {
                    flag = false;
                    exceptionCount = exceptionCount.add(1);
                }
            }
            if (flag) {
                _burnBond(inputIDs[i], msg.sender, amount);
            }
        }

        require(
            exceptionBonds.length == exceptionCount,
            "All the exceptionBonds need to be included in input"
        );

        for (uint256 i = 0; i < outputIDs.length; i++) {
            flag = true;
            for (uint256 j = 0; j < exceptionBonds.length; j++) {
                if (exceptionBonds[j] == outputIDs[i]) {
                    flag = false;
                    exceptionCount = exceptionCount.sub(1);
                }
            }
            if (flag) {
                _mintBond(outputIDs[i], msg.sender, amount);
            }
        }

        require(
            exceptionCount == 0,
            "All the exceptionBonds need to be included both in input and output"
        );

        emit LogExchangeEquivalentBonds(msg.sender, inputBondGroupID, outputBondGroupID, amount);

        return true;
    }

    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID)
        external
        virtual
        override
        returns (uint256 totalPayment)
    {
        (bytes32[] memory bondIDs, uint256 maturity) = getBondGroup(bondGroupID);
        _assertNonEmptyBondGroup(bondIDs);
        require(_getBlockTimestampSec() >= maturity, "the bond has not expired yet");

        uint256 price = _getPriceOn(
            maturity,
            (oracleHintID != 0) ? oracleHintID : _oracleContract.latestId()
        );
        require(price != 0, "price should be non-zero value");
        require(price < 2**64, "price should be less than 2^64");

        for (uint256 i = 0; i < bondIDs.length; i++) {
            bytes32 bondID = bondIDs[i];
            uint256 payment = _sendCollateralToBondTokenContract(bondID, uint64(price));
            totalPayment = totalPayment.add(payment);
        }

        if (totalPayment != 0) {
            uint256 fee = totalPayment.mul(2).div(1000);
            _sendCollateralTo(payable(FEE_TAKER), fee);
        }
    }

    function collateralAddress() external override view returns (address) {
        return _collateralAddress();
    }

    function oracleAddress() external override view returns (address) {
        return address(_oracleContract);
    }

    function feeTaker() external override view returns (address) {
        return FEE_TAKER;
    }

    function decimalsOfBond() external override view returns (uint8) {
        return DECIMALS_OF_BOND;
    }

    function decimalsOfOraclePrice() external override view returns (uint8) {
        return DECIMALS_OF_ORACLE_PRICE;
    }

    function maturityScale() external override view returns (uint256) {
        return MATURITY_SCALE;
    }

    function getBond(bytes32 bondID)
        public
        override
        view
        returns (
            address bondTokenAddress,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        )
    {
        BondInfo memory bondInfo = _bonds[bondID];
        bondTokenAddress = address(bondInfo.contractInstance);
        maturity = bondInfo.maturity;
        solidStrikePrice = bondInfo.strikePrice;
        fnMapID = bondInfo.fnMapID;
    }

    function getFnMap(bytes32 fnMapID) public override view returns (bytes memory fnMap) {
        LineSegment[] storage segments = _registeredFnMap[fnMapID];
        uint256[] memory polyline = new uint256[](segments.length);
        for (uint256 i = 0; i < segments.length; i++) {
            polyline[i] = zipLineSegment(segments[i]);
        }
        return abi.encode(polyline);
    }

    function getBondGroup(uint256 bondGroupID)
        public
        override
        view
        returns (bytes32[] memory bondIDs, uint256 maturity)
    {
        require(bondGroupID < nextBondGroupID, "the bond group does not exist");
        BondGroup memory bondGroup = _bondGroupList[bondGroupID];
        bondIDs = bondGroup.bondIDs;
        maturity = bondGroup.maturity;
    }

    function generateFnMapID(bytes memory fnMap) public override view returns (bytes32 fnMapID) {
        return keccak256(fnMap);
    }

    function generateBondID(uint256 maturity, bytes memory fnMap)
        public
        override
        view
        returns (bytes32 bondID)
    {
        return keccak256(abi.encodePacked(address(this), maturity, fnMap));
    }

    function _mintBond(
        bytes32 bondID,
        address account,
        uint256 amount
    ) internal {
        BondTokenInterface bondTokenContract = _bonds[bondID].contractInstance;
        _assertRegisteredBond(bondTokenContract);
        require(bondTokenContract.mint(account, amount), "failed to mint bond token");
    }

    function _burnBond(
        bytes32 bondID,
        address account,
        uint256 amount
    ) internal {
        BondTokenInterface bondTokenContract = _bonds[bondID].contractInstance;
        _assertRegisteredBond(bondTokenContract);
        require(bondTokenContract.simpleBurn(account, amount), "failed to burn bond token");
    }

    function _sendCollateralToBondTokenContract(bytes32 bondID, uint64 price)
        internal
        returns (uint256 collateralAmount)
    {
        BondTokenInterface bondTokenContract = _bonds[bondID].contractInstance;
        _assertRegisteredBond(bondTokenContract);

        LineSegment[] storage segments = _registeredFnMap[_bonds[bondID].fnMapID];

        (uint256 segmentIndex, bool ok) = _correspondSegment(segments, price);
        assert(ok); // not found a segment whose price range include current price

        (uint128 n, uint64 _d) = _mapXtoY(segments[segmentIndex], price); // x = price, y = n / _d

        uint128 d = uint128(_d) * uint128(price);

        uint256 totalSupply = bondTokenContract.totalSupply();
        bool expiredFlag = bondTokenContract.expire(n, d); // rateE0 = n / d = f(price) / price

        if (expiredFlag) {
            uint8 decimalsOfCollateral = _getCollateralDecimals();
            collateralAmount = _applyDecimalGap(totalSupply, DECIMALS_OF_BOND, decimalsOfCollateral)
                .mul(n)
                .div(d);
            _sendCollateralTo(address(bondTokenContract), collateralAmount);

            emit LogLiquidateBond(bondID, n, d);
        }
    }

    function _applyDecimalGap(
        uint256 baseAmount,
        uint8 decimalsOfBase,
        uint8 decimalsOfQuote
    ) internal pure returns (uint256 quoteAmount) {
        uint256 n;
        uint256 d;

        if (decimalsOfBase > decimalsOfQuote) {
            d = decimalsOfBase - decimalsOfQuote;
        } else if (decimalsOfBase < decimalsOfQuote) {
            n = decimalsOfQuote - decimalsOfBase;
        }

        require(n < 19 && d < 19, "decimal gap needs to be lower than 19");
        quoteAmount = baseAmount.mul(10**n).div(10**d);
    }

    function _assertRegisteredBond(BondTokenInterface bondTokenContract) internal pure {
        require(address(bondTokenContract) != address(0), "the bond is not registered");
    }

    function _assertNonEmptyBondGroup(bytes32[] memory bondIDs) internal pure {
        require(bondIDs.length != 0, "the list of bond ID must be non-empty");
    }

    function _assertBeforeMaturity(uint256 maturity) internal view {
        require(_getBlockTimestampSec() < maturity, "the maturity has already expired");
    }

    function _isBondWorthless(LineSegment[] memory polyline) internal pure returns (bool) {
        for (uint256 i = 0; i < polyline.length; i++) {
            LineSegment memory segment = polyline[i];
            if (segment.right.y != 0) {
                return false;
            }
        }

        return true;
    }

    function _getSbtStrikePrice(LineSegment[] memory polyline) internal pure returns (uint64) {
        if (polyline.length == 0) {
            return 0;
        }

        uint64 strikePrice = polyline[0].right.x;

        if (strikePrice == 0) {
            return 0;
        }

        for (uint256 i = 0; i < polyline.length; i++) {
            LineSegment memory segment = polyline[i];
            if (segment.right.y != strikePrice) {
                return 0;
            }
        }

        return uint64(strikePrice);
    }

    function _getLbtStrikePrice(LineSegment[] memory polyline) internal pure returns (uint64) {
        if (polyline.length == 0) {
            return 0;
        }

        uint64 strikePrice = polyline[0].right.x;

        if (strikePrice == 0) {
            return 0;
        }

        for (uint256 i = 0; i < polyline.length; i++) {
            LineSegment memory segment = polyline[i];
            if (segment.right.y.add(strikePrice) != segment.right.x) {
                return 0;
            }
        }

        return uint64(strikePrice);
    }

    function _correspondSegment(LineSegment[] memory segments, uint64 x)
        internal
        pure
        returns (uint256 i, bool ok)
    {
        i = segments.length;
        while (i > 0) {
            i--;
            if (segments[i].left.x <= x) {
                ok = true;
                break;
            }
        }
    }


    function _createNewBondToken(uint256 maturity, bytes memory fnMap)
        internal
        virtual
        returns (BondTokenInterface);

    function _collateralAddress() internal virtual view returns (address);

    function _getCollateralDecimals() internal virtual view returns (uint8);

    function _sendCollateralTo(address receiver, uint256 amount) internal virtual;
}


pragma solidity 0.6.6;




contract BondMakerCollateralizedEth is BondMaker, UseBondTokenName, TransferETH {
    address private constant ETH = address(0);

    BondTokenFactory internal immutable BOND_TOKEN_FACTORY;

    constructor(
        address oracleAddress,
        address feeTaker,
        address bondTokenNameAddress,
        address bondTokenFactoryAddress,
        uint256 maturityScale
    )
        public
        BondMaker(oracleAddress, feeTaker, maturityScale, 8, 8)
        UseBondTokenName(bondTokenNameAddress)
    {
        BOND_TOKEN_FACTORY = BondTokenFactory(bondTokenFactoryAddress);
    }

    function issueNewBonds(uint256 bondGroupID) public payable returns (uint256 bondAmount) {
        return _issueNewBonds(bondGroupID, msg.value);
    }

    function _createNewBondToken(uint256 maturity, bytes memory fnMap)
        internal
        override
        returns (BondTokenInterface)
    {
        (string memory symbol, string memory name) = _getBondTokenName(maturity, fnMap);
        address bondAddress = BOND_TOKEN_FACTORY.createBondToken(
            ETH,
            name,
            symbol,
            DECIMALS_OF_BOND
        );
        return BondTokenInterface(bondAddress);
    }

    function _getBondTokenName(uint256 maturity, bytes memory fnMap)
        internal
        virtual
        view
        returns (string memory symbol, string memory name)
    {
        bytes32 fnMapID = generateFnMapID(fnMap);
        LineSegment[] memory segments = _registeredFnMap[fnMapID];
        uint64 sbtStrikePrice = _getSbtStrikePrice(segments);
        uint64 lbtStrikePrice = _getLbtStrikePrice(segments);
        uint64 sbtStrikePriceE0 = sbtStrikePrice / (uint64(10)**DECIMALS_OF_ORACLE_PRICE);
        uint64 lbtStrikePriceE0 = lbtStrikePrice / (uint64(10)**DECIMALS_OF_ORACLE_PRICE);

        if (sbtStrikePrice != 0) {
            return
                _bondTokenNameContract.genBondTokenName("SBT", "SBT", maturity, sbtStrikePriceE0);
        } else if (lbtStrikePrice != 0) {
            return
                _bondTokenNameContract.genBondTokenName("LBT", "LBT", maturity, lbtStrikePriceE0);
        } else {
            return _bondTokenNameContract.genBondTokenName("IMT", "Immortal Option", maturity, 0);
        }
    }

    function _collateralAddress() internal override view returns (address) {
        return address(0);
    }

    function _getCollateralDecimals() internal override view returns (uint8) {
        return 18;
    }

    function _sendCollateralTo(address receiver, uint256 amount) internal override {
        _transferETH(payable(receiver), amount);
    }
}


pragma solidity 0.6.6;



interface BondMakerCollateralizedEthInterface is BondMakerInterface {
    function issueNewBonds(uint256 bondGroupID) external payable returns (uint256 amount);
}


pragma solidity 0.6.6;



abstract contract UseBondMaker {
    BondMakerCollateralizedEthInterface internal _bondMakerContract;

    constructor(address contractAddress) public {
        require(contractAddress != address(0), "contract should be non-zero address");
        _bondMakerContract = BondMakerCollateralizedEthInterface(payable(contractAddress));
    }
}


pragma solidity 0.6.6;











contract DecentralizedOTC is UseOracle, UseBondMaker, UseSafeMath, Time, CallOptionCalculator {
    uint256 internal constant MIN_EXCHANGE_RATE_E8 = 0.000001 * 10**8;
    uint256 internal constant MAX_EXCHANGE_RATE_E8 = 1000000 * 10**8;

    int256 internal constant MAX_SPREAD_E8 = 0.15 * 10**8; // 15%

    mapping(bytes32 => address) public deployer;

    struct PoolInfo {
        ERC20 ERC20Address;
        int16 spread;
        bool isLBTSellPool;
    }
    mapping(bytes32 => PoolInfo) public poolMap;

    mapping(bytes32 => PriceOracleInterface) internal _erc20OracleMap;

    event LogERC20TokenLBTSwap(
        bytes32 indexed poolID,
        address indexed sender,
        uint256 indexed bondGroupID,
        uint256 volume, // decimal: 8
        uint256 LBTAmount, // decimal: BondToken.decimals()
        uint256 ERC20Amount // decimal: ERC20.decimals()
    );

    event LogLBTERC20TokenSwap(
        bytes32 indexed poolID,
        address indexed sender,
        uint256 indexed bondGroupID,
        uint256 volume, // decimal: 8
        uint256 LBTAmount, // decimal: BondToken.decimals()
        uint256 ERC20Amount // decimal: ERC20.decimals()
    );

    event LogCreateERC20Pool(
        address indexed deployer,
        address indexed ERC20Address,
        bytes32 indexed poolID,
        int16 spread,
        bool isLBTSellPool
    );

    event LogDeleteERC20Pool(bytes32 indexed poolID);

    modifier isExistentPool(bytes32 erc20PoolID) {
        require(deployer[erc20PoolID] != address(0), "the pool does not exist");
        _;
    }

    constructor(address bondMakerAddress, address oracleAddress)
        public
        UseOracle(oracleAddress)
        UseBondMaker(bondMakerAddress)
    {
        require(
            _bondMakerContract.decimalsOfOraclePrice() == 8,
            "the decimals of oracle price must be 8"
        );
        require(_bondMakerContract.decimalsOfBond() == 8, "the decimals of bond token must be 8");
        require(
            oracleAddress == _bondMakerContract.oracleAddress(),
            "the oracle address is differ"
        );
    }

    function setPoolMap(
        address ERC20Address,
        int16 spread,
        bool isLBTSellPool
    ) external returns (bytes32 erc20PoolID) {
        erc20PoolID = keccak256(abi.encode(msg.sender, ERC20Address, spread, isLBTSellPool));
        require(deployer[erc20PoolID] == address(0), "already registered");
        require(msg.sender != address(0), "deployer must be non-zero address");
        require(spread > -1000 && spread < 1000, "the range of fee base must be -999~999");
        require(ERC20Address != address(0), "ERC20 address is 0x0");

        poolMap[erc20PoolID] = PoolInfo(ERC20(ERC20Address), spread, isLBTSellPool);
        deployer[erc20PoolID] = msg.sender;
        emit LogCreateERC20Pool(msg.sender, ERC20Address, erc20PoolID, spread, isLBTSellPool);
    }

    function setProvider(
        bytes32 erc20PoolID,
        address oracleAddress,
        address
    ) external isExistentPool(erc20PoolID) {
        require(msg.sender == deployer[erc20PoolID], "only deployer is allowed to execute");
        _erc20OracleMap[erc20PoolID] = PriceOracleInterface(oracleAddress);
    }

    function oracleInfo(bytes32 poolID)
        external
        view
        returns (address oracleAddress, address calculatorAddress)
    {
        oracleAddress = address(_erc20OracleMap[poolID]);
        calculatorAddress = address(0);
    }

    function getPoolInfo(bytes32 poolID)
        external
        view
        isExistentPool(poolID)
        returns (
            address deployerAddress,
            address erc20Address,
            int16 feeBase,
            bool isLBTSellPool,
            address erc20OracleAddress
        )
    {
        deployerAddress = deployer[poolID];
        PoolInfo memory poolInfo = poolMap[poolID];
        erc20Address = address(poolInfo.ERC20Address);
        feeBase = poolInfo.spread;
        isLBTSellPool = poolInfo.isLBTSellPool;
        erc20OracleAddress = address(_erc20OracleMap[poolID]);
    }

    function getOraclePrice(bytes32 erc20PoolID) external returns (uint256 priceE8) {
        return _getOraclePrice(erc20PoolID);
    }

    function _getOraclePrice(bytes32 erc20PoolID)
        internal
        isExistentPool(erc20PoolID)
        returns (uint256 priceE8)
    {
        PriceOracleInterface oracleContract = _erc20OracleMap[erc20PoolID];
        require(address(oracleContract) != address(0), "invalid ERC20 price oracle");
        return oracleContract.latestPrice();
    }

    function calcRateLBT2ERC20(
        bytes32 sbtID,
        bytes32 erc20PoolID,
        uint256 maturity
    ) external returns (uint256 rateLBT2ERC20E8) {
        (rateLBT2ERC20E8, , , ) = _calcRateLBT2ERC20(sbtID, erc20PoolID, maturity);
    }

    function _calcRateLBT2ERC20(
        bytes32 sbtID,
        bytes32 erc20PoolID,
        uint256 maturity
    )
        internal
        returns (
            uint256 rateLBT2ERC20E8,
            uint256 lbtPriceE8,
            uint256 erc20PriceE8,
            int256 spreadE8
        )
    {
        PoolInfo memory pool = poolMap[erc20PoolID];
        (uint256 etherPriceE8, uint256 ethVolatilityE8) = _getOracleData();
        (, , uint256 strikePriceE8, ) = _bondMakerContract.getBond(sbtID);
        erc20PriceE8 = _getOraclePrice(erc20PoolID);

        (lbtPriceE8, spreadE8) = _calcLbtPriceAndSpread(
            strikePriceE8,
            etherPriceE8,
            ethVolatilityE8,
            maturity,
            pool.spread * 10 // feeBaseE4
        );
        uint256 rateE8 = lbtPriceE8.mul(10**8).div(
            erc20PriceE8,
            "ERC20 oracle price must be non-zero"
        );
        require(rateE8 > MIN_EXCHANGE_RATE_E8, "exchange rate is too small");

        if (pool.isLBTSellPool) {
            rateLBT2ERC20E8 = rateE8.mul(uint256(10**8 + spreadE8)) / (10**8);
        } else {
            rateLBT2ERC20E8 = rateE8.mul(uint256(10**8 - spreadE8)) / (10**8);
        }
    }

    function _calcLbtPriceAndSpread(
        uint256 strikePriceE8,
        uint256 etherPriceE8,
        uint256 ethVolatilityE8,
        uint256 maturity,
        int256 feeBaseE4
    ) internal view returns (uint256 lbtPriceE8, int256 spreadE8) {
        uint256 untilMaturity = maturity.sub(
            _getBlockTimestampSec(),
            "LBT should not have expired"
        );

        uint8 decimalsOfPrice = 0; // mutable
        {
            uint256 threshould = 1000000 * 10**8;
            while (threshould >= 10) {
                if (strikePriceE8 >= threshould) {
                    break;
                }
                decimalsOfPrice++;
                threshould /= 10;
            }
        }

        uint256 lbtLeverageE4;
        {
            uint256 etherPrice = _applyDecimalGap(etherPriceE8, 8, decimalsOfPrice);
            uint256 strikePrice = _applyDecimalGap(strikePriceE8, 8, decimalsOfPrice);
            uint256 lbtPrice;
            (lbtPrice, lbtLeverageE4, ) = calcLbtPriceAndLeverage(
                etherPrice.toInt256(),
                strikePrice.toInt256(),
                ethVolatilityE8.toInt256(),
                untilMaturity.toInt256()
            );

            lbtPriceE8 = _applyDecimalGap(lbtPrice, decimalsOfPrice, 8);
        }

        uint256 volE8 = ethVolatilityE8 < 10**8 ? 10**8 : ethVolatilityE8 > 2 * 10**8
            ? 2 * 10**8
            : ethVolatilityE8;
        uint256 volTimesLevE4 = (volE8 * lbtLeverageE4) / 10**8;
        spreadE8 =
            feeBaseE4 *
            (feeBaseE4 < 0 || volTimesLevE4 < 10**4 ? 10**4 : volTimesLevE4).toInt256();
        spreadE8 = spreadE8 > MAX_SPREAD_E8 ? MAX_SPREAD_E8 : spreadE8;
    }

    function _applyDecimalGap(
        uint256 baseAmount,
        ERC20 baseToken,
        ERC20 quoteToken
    ) private view returns (uint256) {
        uint8 decimalsOfBase = baseToken.decimals();
        uint8 decimalsOfQuote = quoteToken.decimals();
        return _applyDecimalGap(baseAmount, decimalsOfBase, decimalsOfQuote);
    }

    function _applyDecimalGap(
        uint256 amount,
        uint8 decimalsOfBase,
        uint8 decimalsOfQuote
    ) private pure returns (uint256) {
        uint256 n;
        uint256 d;

        if (decimalsOfBase > decimalsOfQuote) {
            d = decimalsOfBase - decimalsOfQuote;
        } else if (decimalsOfBase < decimalsOfQuote) {
            n = decimalsOfQuote - decimalsOfBase;
        }

        require(n < 19 && d < 19, "decimal gap needs to be lower than 19");
        return amount.mul(10**n).div(10**d);
    }

    function exchangeERC20ToLBT(
        uint256 bondGroupID,
        bytes32 erc20PoolID,
        uint256 ERC20Amount,
        uint256 expectedAmount,
        uint256 range
    ) public returns (uint256 LBTAmount) {
        LBTAmount = _exchangeERC20ToLBT(bondGroupID, erc20PoolID, ERC20Amount);
        if (expectedAmount != 0) {
            require(LBTAmount.mul(1000 + range).div(1000) >= expectedAmount, "out of price range");
        }
    }

    function _exchangeERC20ToLBT(
        uint256 bondGroupID,
        bytes32 erc20PoolID,
        uint256 ERC20Amount
    ) internal isExistentPool(erc20PoolID) returns (uint256 LBTAmount) {
        bytes32 sbtID;
        bytes32 lbtID;
        {
            (bytes32[] memory bonds, ) = _bondMakerContract.getBondGroup(bondGroupID);
            require(bonds.length == 2, "the bond group must include only 2 types of bond.");
            lbtID = bonds[1];
            sbtID = bonds[0];
        }

        ERC20 bondToken;
        uint256 maturity;
        {
            address contractAddress;
            (contractAddress, maturity, , ) = _bondMakerContract.getBond(lbtID);
            require(contractAddress != address(0), "the bond is not registered");
            bondToken = ERC20(contractAddress);
        }

        ERC20 token;
        {
            PoolInfo memory pool = poolMap[erc20PoolID];
            require(pool.isLBTSellPool, "This pool is for buying LBT");
            token = pool.ERC20Address;
        }

        uint256 volumeE8;
        {
            (uint256 rateE8, , uint256 erc20PriceE8, ) = _calcRateLBT2ERC20(
                sbtID,
                erc20PoolID,
                maturity
            );
            require(rateE8 != 0, "exchange rate included spread must be non-zero");
            LBTAmount = _applyDecimalGap(ERC20Amount.mul(10**8), token, bondToken).div(rateE8);
            require(LBTAmount != 0, "must transfer non-zero LBT amount");
            volumeE8 = erc20PriceE8.mul(ERC20Amount).div(10**uint256(token.decimals()));
            volumeE8 = _calcUsdVolume(volumeE8);
        }

        require(
            token.transferFrom(msg.sender, deployer[erc20PoolID], ERC20Amount),
            "fail to transfer ERC20 token"
        );
        require(
            bondToken.transferFrom(deployer[erc20PoolID], msg.sender, LBTAmount),
            "fail to transfer LBT"
        );

        emit LogERC20TokenLBTSwap(
            erc20PoolID,
            msg.sender,
            bondGroupID,
            volumeE8,
            LBTAmount,
            ERC20Amount
        );
    }

    function exchangeLBT2ERC20(
        uint256 bondGroupID,
        bytes32 erc20PoolID,
        uint256 LBTAmount,
        uint256 expectedAmount,
        uint256 range
    ) public returns (uint256 ERC20Amount) {
        ERC20Amount = _exchangeLBT2ERC20(bondGroupID, erc20PoolID, LBTAmount);
        if (expectedAmount != 0) {
            require(
                ERC20Amount.mul(1000 + range).div(1000) >= expectedAmount,
                "out of price range"
            );
        }
    }

    function _exchangeLBT2ERC20(
        uint256 bondGroupID,
        bytes32 erc20PoolID,
        uint256 LBTAmount
    ) internal isExistentPool(erc20PoolID) returns (uint256 ERC20Amount) {
        bytes32 lbtID;
        bytes32 sbtID;
        {
            (bytes32[] memory bonds, ) = _bondMakerContract.getBondGroup(bondGroupID);
            require(bonds.length == 2, "the bond group must include only 2 types of bond.");
            lbtID = bonds[1];
            sbtID = bonds[0];
        }

        ERC20 bondToken;
        uint256 maturity;
        {
            address contractAddress;
            (contractAddress, maturity, , ) = _bondMakerContract.getBond(lbtID);
            require(contractAddress != address(0), "the bond is not registered");
            bondToken = ERC20(contractAddress);
        }

        ERC20 token;
        {
            PoolInfo memory pool = poolMap[erc20PoolID];
            require(!pool.isLBTSellPool, "This pool is not for buying LBT");
            token = pool.ERC20Address;
        }

        uint256 volumeE8;
        {
            (uint256 rateE8, uint256 lbtPriceE8, , ) = _calcRateLBT2ERC20(
                sbtID,
                erc20PoolID,
                maturity
            );
            require(rateE8 != 0, "exchange rate included spread must be non-zero");
            ERC20Amount = _applyDecimalGap(LBTAmount.mul(rateE8), bondToken, token).div(10**8);
            require(ERC20Amount != 0, "must transfer non-zero token amount");
            volumeE8 = lbtPriceE8.mul(LBTAmount).div(10**uint256(bondToken.decimals()));
            volumeE8 = _calcUsdVolume(volumeE8);
        }

        require(
            token.transferFrom(deployer[erc20PoolID], msg.sender, ERC20Amount),
            "fail to transfer ERC20 token"
        );
        require(
            bondToken.transferFrom(msg.sender, deployer[erc20PoolID], LBTAmount),
            "fail to transfer LBT"
        );

        emit LogLBTERC20TokenSwap(
            erc20PoolID,
            msg.sender,
            bondGroupID,
            volumeE8,
            LBTAmount,
            ERC20Amount
        );
    }

    function deletePoolAndProvider(bytes32 erc20PoolID) public isExistentPool(erc20PoolID) {
        require(deployer[erc20PoolID] == msg.sender, "this pool is not owned");
        delete deployer[erc20PoolID];
        delete poolMap[erc20PoolID];
        delete _erc20OracleMap[erc20PoolID];

        emit LogDeleteERC20Pool(erc20PoolID);
    }

    function bondMakerAddress() external view returns (address) {
        return address(_bondMakerContract);
    }

    function _calcUsdVolume(uint256 volume) internal virtual returns (uint256) {
        return volume;
    }
}


pragma solidity 0.6.6;



contract DecentralizedOtcCollateralizedUsdc is DecentralizedOTC {
    constructor(address ethBondMakerCollateralizedUsdcAddress, address ethPriceInverseOracleAddress)
        public
        DecentralizedOTC(ethBondMakerCollateralizedUsdcAddress, ethPriceInverseOracleAddress)
    {}

    function _calcUsdVolume(uint256 volume) internal override returns (uint256) {
        (uint256 ethPriceInverseE8, ) = _getOracleData();
        return volume.mul(10**8) / ethPriceInverseE8;
    }
}