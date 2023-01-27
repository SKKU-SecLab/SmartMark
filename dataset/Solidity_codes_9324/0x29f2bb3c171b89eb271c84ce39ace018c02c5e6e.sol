
pragma solidity 0.6.6;




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





interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(address indexed from, address indexed to, uint256 value);
}




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





interface LatestPriceOracleInterface {

    function isWorking() external returns (bool);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);

}






interface PriceOracleInterface is LatestPriceOracleInterface {

    function latestId() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);

}






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

    event LogIssueNewBonds(
        uint256 indexed bondGroupID,
        address indexed issuer,
        uint256 amount
    );

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

    event LogLiquidateBond(
        bytes32 indexed bondID,
        uint128 rateNumerator,
        uint128 rateDenominator
    );

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            bytes32 fnMapID
        );


    function registerNewBondGroup(
        bytes32[] calldata bondIDList,
        uint256 maturity
    ) external returns (uint256 bondGroupID);


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


    function oracleAddress() external view returns (PriceOracleInterface);


    function feeTaker() external view returns (address);


    function decimalsOfBond() external view returns (uint8);


    function decimalsOfOraclePrice() external view returns (uint8);


    function maturityScale() external view returns (uint256);


    function nextBondGroupID() external view returns (uint256);


    function getBond(bytes32 bondID)
        external
        view
        returns (
            address bondAddress,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function getFnMap(bytes32 fnMapID)
        external
        view
        returns (bytes memory fnMap);


    function getBondGroup(uint256 bondGroupID)
        external
        view
        returns (bytes32[] memory bondIDs, uint256 maturity);


    function generateFnMapID(bytes calldata fnMap)
        external
        view
        returns (bytes32 fnMapID);


    function generateBondID(uint256 maturity, bytes calldata fnMap)
        external
        view
        returns (bytes32 bondID);

}






interface BondMakerCollateralizedErc20Interface is BondMakerInterface {

    function issueNewBonds(uint256 bondGroupID) external returns (uint256 amount);

}




abstract contract Time {
    function _getBlockTimestampSec() internal view returns (uint256 unixtimesec) {
        unixtimesec = block.timestamp; // solhint-disable-line not-rely-on-time
    }
}





abstract contract TransferETH is TransferETHInterface {
    receive() external payable override {
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
        (bool success, ) = recipient.call{value: amount}(""); // solhint-disable-line avoid-low-level-calls
        require(success, "transferring Ether failed");
        emit LogTransferETH(address(this), recipient, amount);
    }

    function _transferETH(address payable recipient, uint256 amount) internal {
        _transferETH(recipient, amount, "TransferETH: transfer amount exceeds balance");
    }
}




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

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}






contract BondTokenCollateralizedErc20 is BondToken {
    using SafeERC20 for ERC20;

    ERC20 internal immutable COLLATERALIZED_TOKEN;

    constructor(
        ERC20 collateralizedTokenAddress,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public BondToken(name, symbol, decimals) {
        COLLATERALIZED_TOKEN = collateralizedTokenAddress;
    }

    function _getCollateralDecimals() internal view override returns (uint8) {
        return COLLATERALIZED_TOKEN.decimals();
    }

    function _sendCollateralTo(address receiver, uint256 amount)
        internal
        override
    {
        COLLATERALIZED_TOKEN.safeTransfer(receiver, amount);
    }
}







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






contract BondTokenFactory {
    address private constant ETH = address(0);

    function createBondToken(
        address collateralizedTokenAddress,
        string calldata name,
        string calldata symbol,
        uint8 decimals
    ) external returns (address createdBondAddress) {
        if (collateralizedTokenAddress == ETH) {
            BondTokenCollateralizedEth bond = new BondTokenCollateralizedEth(
                name,
                symbol,
                decimals
            );
            bond.transferOwnership(msg.sender);
            return address(bond);
        } else {

                BondTokenCollateralizedErc20 bond
             = new BondTokenCollateralizedErc20(
                ERC20(collateralizedTokenAddress),
                name,
                symbol,
                decimals
            );
            bond.transferOwnership(msg.sender);
            return address(bond);
        }
    }
}





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

        LineSegment memory leftSegment = polyline[0]; // mutable
        int256 gradientNumerator = int256(leftSegment.right.y) -
            int256(leftSegment.left.y); // mutable
        int256 gradientDenominator = int256(leftSegment.right.x) -
            int256(leftSegment.left.x); // mutable

        require(
            leftSegment.left.x == uint64(0),
            "the x coordinate of left end of the first segment must be 0"
        );
        require(
            leftSegment.left.y == uint64(0),
            "the y coordinate of left end of the first segment must be 0"
        );

        assertLineSegment(leftSegment);

        LineSegment memory rightSegment; // mutable
        for (uint256 i = 1; i < numOfSegment; i++) {
            rightSegment = polyline[i];

            assertLineSegment(rightSegment);

            require(
                leftSegment.right.x == rightSegment.left.x,
                "given polyline has an undefined domain."
            );

            require(
                leftSegment.right.y == rightSegment.left.y,
                "given polyline is not a continuous function"
            );

            int256 nextGradientNumerator = int256(rightSegment.right.y) -
                int256(rightSegment.left.y);
            int256 nextGradientDenominator = int256(rightSegment.right.x) -
                int256(rightSegment.left.x);
            require(
                nextGradientNumerator * gradientDenominator !=
                    nextGradientDenominator * gradientNumerator,
                "the sequential segments must not have the same gradient"
            );

            leftSegment = rightSegment;
            gradientNumerator = nextGradientNumerator;
            gradientDenominator = nextGradientDenominator;
        }


        require(
            gradientNumerator >= 0 && gradientNumerator <= gradientDenominator,
            "the gradient of last line segment must be non-negative, and equal to or less than 1"
        );
    }

    function zipLineSegment(LineSegment memory segment)
        internal
        pure
        returns (uint256 zip)
    {
        uint256 x1U256 = uint256(segment.left.x) << (64 + 64 + 64); // uint64
        uint256 y1U256 = uint256(segment.left.y) << (64 + 64); // uint64
        uint256 x2U256 = uint256(segment.right.x) << 64; // uint64
        uint256 y2U256 = uint256(segment.right.y); // uint64
        zip = x1U256 | y1U256 | x2U256 | y2U256;
    }

    function unzipLineSegment(uint256 zip)
        internal
        pure
        returns (LineSegment memory)
    {
        uint64 x1 = uint64(zip >> (64 + 64 + 64));
        uint64 y1 = uint64(zip >> (64 + 64));
        uint64 x2 = uint64(zip >> 64);
        uint64 y2 = uint64(zip);
        return
            LineSegment({
                left: Point({x: x1, y: y1}),
                right: Point({x: x2, y: y2})
            });
    }

    function decodePolyline(bytes memory fnMap)
        internal
        pure
        returns (uint256[] memory)
    {
        return abi.decode(fnMap, (uint256[]));
    }
}









abstract contract BondMaker is UseSafeMath, BondMakerInterface, Time, Polyline {
    uint8 internal immutable DECIMALS_OF_BOND;
    uint8 internal immutable DECIMALS_OF_ORACLE_PRICE;
    address internal immutable FEE_TAKER;
    uint256 internal immutable MATURITY_SCALE;
    PriceOracleInterface internal immutable _oracleContract;

    uint256 internal _nextBondGroupID = 1;

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
        PriceOracleInterface oracleAddress,
        address feeTaker,
        uint256 maturityScale,
        uint8 decimalsOfBond,
        uint8 decimalsOfOraclePrice
    ) public {
        require(
            address(oracleAddress) != address(0),
            "oracleAddress should be non-zero address"
        );
        _oracleContract = oracleAddress;
        require(
            decimalsOfBond < 19,
            "the decimals of bond must be less than 19"
        );
        DECIMALS_OF_BOND = decimalsOfBond;
        require(
            decimalsOfOraclePrice < 19,
            "the decimals of oracle price must be less than 19"
        );
        DECIMALS_OF_ORACLE_PRICE = decimalsOfOraclePrice;
        require(
            feeTaker != address(0),
            "the fee taker must be non-zero address"
        );
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
        require(
            maturity < _getBlockTimestampSec() + 365 days,
            "the maturity is too far"
        );
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
            require(
                !_isBondWorthless(segments),
                "the bond is 0-value at any price"
            );
            sbtStrikePrice = _getSbtStrikePrice(segments);
        } else {
            LineSegment[] memory segments = _registeredFnMap[fnMapID];
            sbtStrikePrice = _getSbtStrikePrice(segments);
        }

        BondTokenInterface bondTokenContract = _createNewBondToken(
            maturity,
            fnMap
        );

        _bonds[bondID] = BondInfo({
            maturity: maturity,
            contractInstance: bondTokenContract,
            strikePrice: sbtStrikePrice,
            fnMapID: fnMapID
        });

        emit LogNewBond(bondID, address(bondTokenContract), maturity, fnMapID);

        return (bondID, address(bondTokenContract), fnMapID);
    }

    function _assertBondGroup(bytes32[] memory bondIDs, uint256 maturity)
        internal
        view
    {
        require(
            bondIDs.length >= 2,
            "the bond group should consist of 2 or more bonds"
        );

        uint256 numOfBreakPoints = 0;
        for (uint256 i = 0; i < bondIDs.length; i++) {
            BondInfo storage bond = _bonds[bondIDs[i]];
            require(
                bond.maturity == maturity,
                "the maturity of the bonds must be same"
            );
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
                (uint256 segmentIndex, bool ok) = _correspondSegment(
                    segments,
                    rate
                );

                require(ok, "invalid domain expression");

                (uint128 n, uint64 d) = _mapXtoY(segments[segmentIndex], rate);

                if (n != 0) {
                    totalBondPriceN = totalBondPriceD.mul(n).add(
                        totalBondPriceN.mul(d)
                    );
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
        for (uint256 i = 1; i < bondIDs.length; i++) {
            (, , uint64 strikePrice, ) = getBond(bondIDs[i]);
            require(
                strikePrice == 0,
                "except the first bond must not be pure SBT"
            );
        }

        bondGroupID = _nextBondGroupID;
        _nextBondGroupID = _nextBondGroupID.add(1);

        _bondGroupList[bondGroupID] = BondGroup(bondIDs, maturity);

        emit LogNewBondGroup(bondGroupID, maturity, sbtStrikePrice, bondIDs);

        return bondGroupID;
    }

    function _issueNewBonds(
        uint256 bondGroupID,
        uint256 collateralAmountWithFee
    ) internal returns (uint256 bondAmount) {
        (bytes32[] memory bondIDs, uint256 maturity) = getBondGroup(
            bondGroupID
        );
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

    function reverseBondGroupToCollateral(
        uint256 bondGroupID,
        uint256 bondAmount
    ) external virtual override returns (bool) {
        require(bondAmount != 0, "the bond amount must be non-zero");

        (bytes32[] memory bondIDs, uint256 maturity) = getBondGroup(
            bondGroupID
        );
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

        uint256 fee = collateralAmount.mul(2).div(1000); // collateral:fee = 1000:2
        _sendCollateralTo(payable(FEE_TAKER), fee);
        _sendCollateralTo(msg.sender, collateralAmount);

        emit LogReverseBondGroupToCollateral(
            bondGroupID,
            msg.sender,
            collateralAmount
        );

        return true;
    }

    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external virtual override returns (bool) {
        (bytes32[] memory inputIDs, uint256 inputMaturity) = getBondGroup(
            inputBondGroupID
        );
        _assertNonEmptyBondGroup(inputIDs);
        (bytes32[] memory outputIDs, uint256 outputMaturity) = getBondGroup(
            outputBondGroupID
        );
        _assertNonEmptyBondGroup(outputIDs);
        require(
            inputMaturity == outputMaturity,
            "cannot exchange bonds with different maturities"
        );
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

        emit LogExchangeEquivalentBonds(
            msg.sender,
            inputBondGroupID,
            outputBondGroupID,
            amount
        );

        return true;
    }

    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID)
        external
        virtual
        override
        returns (uint256 totalPayment)
    {
        (bytes32[] memory bondIDs, uint256 maturity) = getBondGroup(
            bondGroupID
        );
        _assertNonEmptyBondGroup(bondIDs);
        require(
            _getBlockTimestampSec() >= maturity,
            "the bond has not expired yet"
        );

        uint256 latestID = _oracleContract.latestId();
        require(
            latestID != 0,
            "system error: the ID of oracle data should not be zero"
        );

        uint256 price = _getPriceOn(
            maturity,
            (oracleHintID != 0 && oracleHintID <= latestID)
                ? oracleHintID
                : latestID
        );
        require(price != 0, "price should be non-zero value");
        require(price < 2**64, "price should be less than 2^64");

        for (uint256 i = 0; i < bondIDs.length; i++) {
            bytes32 bondID = bondIDs[i];
            uint256 payment = _sendCollateralToBondTokenContract(
                bondID,
                uint64(price)
            );
            totalPayment = totalPayment.add(payment);
        }

        if (totalPayment != 0) {
            uint256 fee = totalPayment.mul(2).div(1000); // collateral:fee = 1000:2
            _sendCollateralTo(payable(FEE_TAKER), fee);
        }
    }

    function collateralAddress() external view override returns (address) {
        return _collateralAddress();
    }

    function oracleAddress()
        external
        view
        override
        returns (PriceOracleInterface)
    {
        return _oracleContract;
    }

    function feeTaker() external view override returns (address) {
        return FEE_TAKER;
    }

    function decimalsOfBond() external view override returns (uint8) {
        return DECIMALS_OF_BOND;
    }

    function decimalsOfOraclePrice() external view override returns (uint8) {
        return DECIMALS_OF_ORACLE_PRICE;
    }

    function maturityScale() external view override returns (uint256) {
        return MATURITY_SCALE;
    }

    function nextBondGroupID() external view override returns (uint256) {
        return _nextBondGroupID;
    }

    function getBond(bytes32 bondID)
        public
        view
        override
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

    function getFnMap(bytes32 fnMapID)
        public
        view
        override
        returns (bytes memory fnMap)
    {
        LineSegment[] storage segments = _registeredFnMap[fnMapID];
        uint256[] memory polyline = new uint256[](segments.length);
        for (uint256 i = 0; i < segments.length; i++) {
            polyline[i] = zipLineSegment(segments[i]);
        }
        return abi.encode(polyline);
    }

    function getBondGroup(uint256 bondGroupID)
        public
        view
        override
        returns (bytes32[] memory bondIDs, uint256 maturity)
    {
        require(
            bondGroupID < _nextBondGroupID,
            "the bond group does not exist"
        );
        BondGroup memory bondGroup = _bondGroupList[bondGroupID];
        bondIDs = bondGroup.bondIDs;
        maturity = bondGroup.maturity;
    }

    function generateFnMapID(bytes memory fnMap)
        public
        view
        override
        returns (bytes32 fnMapID)
    {
        return keccak256(fnMap);
    }

    function generateBondID(uint256 maturity, bytes memory fnMap)
        public
        view
        override
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
        require(
            bondTokenContract.mint(account, amount),
            "failed to mint bond token"
        );
    }

    function _burnBond(
        bytes32 bondID,
        address account,
        uint256 amount
    ) internal {
        BondTokenInterface bondTokenContract = _bonds[bondID].contractInstance;
        _assertRegisteredBond(bondTokenContract);
        require(
            bondTokenContract.simpleBurn(account, amount),
            "failed to burn bond token"
        );
    }

    function _sendCollateralToBondTokenContract(bytes32 bondID, uint64 price)
        internal
        returns (uint256 collateralAmount)
    {
        BondTokenInterface bondTokenContract = _bonds[bondID].contractInstance;
        _assertRegisteredBond(bondTokenContract);

        LineSegment[] storage segments = _registeredFnMap[_bonds[bondID]
            .fnMapID];

        (uint256 segmentIndex, bool ok) = _correspondSegment(segments, price);
        assert(ok); // not found a segment whose price range include current price

        (uint128 n, uint64 _d) = _mapXtoY(segments[segmentIndex], price); // x = price, y = n / _d

        uint128 d = uint128(_d) * uint128(price);

        uint256 totalSupply = bondTokenContract.totalSupply();
        bool expiredFlag = bondTokenContract.expire(n, d); // rateE0 = n / d = f(price) / price

        if (expiredFlag) {
            uint8 decimalsOfCollateral = _getCollateralDecimals();
            collateralAmount = _applyDecimalGap(
                totalSupply,
                DECIMALS_OF_BOND,
                decimalsOfCollateral
            )
                .mul(n)
                .div(d);
            _sendCollateralTo(address(bondTokenContract), collateralAmount);

            emit LogLiquidateBond(bondID, n, d);
        }
    }

    function _getPriceOn(uint256 timestamp, uint256 hintID)
        internal
        returns (uint256 priceE8)
    {
        require(
            _oracleContract.getTimestamp(hintID) > timestamp,
            "there is no price data after maturity"
        );

        uint256 id = hintID - 1;
        while (id != 0) {
            if (_oracleContract.getTimestamp(id) <= timestamp) {
                break;
            }
            id--;
        }

        return _oracleContract.getPrice(id + 1);
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

    function _assertRegisteredBond(BondTokenInterface bondTokenContract)
        internal
        pure
    {
        require(
            address(bondTokenContract) != address(0),
            "the bond is not registered"
        );
    }

    function _assertNonEmptyBondGroup(bytes32[] memory bondIDs) internal pure {
        require(bondIDs.length != 0, "the list of bond ID must be non-empty");
    }

    function _assertBeforeMaturity(uint256 maturity) internal view {
        require(
            _getBlockTimestampSec() < maturity,
            "the maturity has already expired"
        );
    }

    function _isBondWorthless(LineSegment[] memory polyline)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < polyline.length; i++) {
            LineSegment memory segment = polyline[i];
            if (segment.right.y != 0) {
                return false;
            }
        }

        return true;
    }

    function _getSbtStrikePrice(LineSegment[] memory polyline)
        internal
        pure
        returns (uint64)
    {
        if (polyline.length != 2) {
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

    function _getLbtStrikePrice(LineSegment[] memory polyline)
        internal
        pure
        returns (uint64)
    {
        if (polyline.length != 2) {
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

    function _collateralAddress() internal view virtual returns (address);

    function _getCollateralDecimals() internal view virtual returns (uint8);

    function _sendCollateralTo(address receiver, uint256 amount)
        internal
        virtual;
}




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







contract BondMakerCollateralizedErc20 is BondMaker {
    using SafeERC20 for ERC20;

    ERC20 internal immutable COLLATERALIZED_TOKEN;
    BondTokenNameInterface internal immutable BOND_TOKEN_NAMER;
    BondTokenFactory internal immutable BOND_TOKEN_FACTORY;

    constructor(
        ERC20 collateralizedTokenAddress,
        PriceOracleInterface oracleAddress,
        address feeTaker,
        BondTokenNameInterface bondTokenNamerAddress,
        BondTokenFactory bondTokenFactoryAddress,
        uint256 maturityScale,
        uint8 decimalsOfBond,
        uint8 decimalsOfOraclePrice
    )
        public
        BondMaker(
            oracleAddress,
            feeTaker,
            maturityScale,
            decimalsOfBond,
            decimalsOfOraclePrice
        )
    {
        uint8 decimalsOfCollateral = collateralizedTokenAddress.decimals();
        require(
            decimalsOfCollateral < 19,
            "the decimals of collateral must be less than 19"
        );
        COLLATERALIZED_TOKEN = collateralizedTokenAddress;
        require(
            address(bondTokenNamerAddress) != address(0),
            "bondTokenNamerAddress should be non-zero address"
        );
        BOND_TOKEN_NAMER = bondTokenNamerAddress;
        require(
            address(bondTokenFactoryAddress) != address(0),
            "bondTokenFactoryAddress should be non-zero address"
        );
        BOND_TOKEN_FACTORY = bondTokenFactoryAddress;
    }

    function issueNewBonds(uint256 bondGroupID, uint256 amount)
        public
        returns (uint256 bondAmount)
    {
        uint256 allowance = COLLATERALIZED_TOKEN.allowance(
            msg.sender,
            address(this)
        );
        require(amount <= allowance, "insufficient allowance");
        uint256 receivedAmount = _receiveCollateralFrom(msg.sender, amount);
        return _issueNewBonds(bondGroupID, receivedAmount);
    }

    function _createNewBondToken(uint256 maturity, bytes memory fnMap)
        internal
        override
        returns (BondTokenInterface)
    {
        (string memory symbol, string memory name) = _getBondTokenName(
            maturity,
            fnMap
        );
        address bondAddress = BOND_TOKEN_FACTORY.createBondToken(
            address(COLLATERALIZED_TOKEN),
            name,
            symbol,
            DECIMALS_OF_BOND
        );
        return BondTokenInterface(bondAddress);
    }

    function _getBondTokenName(uint256 maturity, bytes memory fnMap)
        internal
        view
        virtual
        returns (string memory symbol, string memory name)
    {
        bytes32 fnMapID = generateFnMapID(fnMap);
        LineSegment[] memory segments = _registeredFnMap[fnMapID];
        uint64 sbtStrikePrice = _getSbtStrikePrice(segments);
        uint64 lbtStrikePrice = _getLbtStrikePrice(segments);
        uint64 sbtStrikePriceE0 = sbtStrikePrice /
            (uint64(10)**DECIMALS_OF_ORACLE_PRICE);
        uint64 lbtStrikePriceE0 = lbtStrikePrice /
            (uint64(10)**DECIMALS_OF_ORACLE_PRICE);

        if (sbtStrikePrice != 0) {
            return
                BOND_TOKEN_NAMER.genBondTokenName(
                    "SBT",
                    "SBT",
                    maturity,
                    sbtStrikePriceE0
                );
        } else if (lbtStrikePrice != 0) {
            return
                BOND_TOKEN_NAMER.genBondTokenName(
                    "LBT",
                    "LBT",
                    maturity,
                    lbtStrikePriceE0
                );
        } else {
            return
                BOND_TOKEN_NAMER.genBondTokenName(
                    "IMT",
                    "Immortal Option",
                    maturity,
                    0
                );
        }
    }

    function _collateralAddress() internal view override returns (address) {
        return address(COLLATERALIZED_TOKEN);
    }

    function _getCollateralDecimals() internal view override returns (uint8) {
        return COLLATERALIZED_TOKEN.decimals();
    }

    function _sendCollateralTo(address receiver, uint256 amount)
        internal
        override
    {
        COLLATERALIZED_TOKEN.safeTransfer(receiver, amount);
    }

    function _receiveCollateralFrom(address sender, uint256 amount)
        internal
        virtual
        returns (uint256 receivedAmount)
    {
        uint256 beforeBalance = COLLATERALIZED_TOKEN.balanceOf(address(this));
        COLLATERALIZED_TOKEN.safeTransferFrom(sender, address(this), amount);
        uint256 afterBalance = COLLATERALIZED_TOKEN.balanceOf(address(this));
        receivedAmount = afterBalance.sub(beforeBalance);
    }
}





contract EthBondMakerCollateralizedUsdc is BondMakerCollateralizedErc20 {
    constructor(
        ERC20 usdcAddress,
        PriceOracleInterface ethPriceInverseOracleAddress,
        address feeTaker,
        BondTokenNameInterface bondTokenNameAddress,
        BondTokenFactory bondTokenFactoryAddress,
        uint256 maturityScale
    )
        public
        BondMakerCollateralizedErc20(
            usdcAddress,
            ethPriceInverseOracleAddress,
            feeTaker,
            bondTokenNameAddress,
            bondTokenFactoryAddress,
            maturityScale,
            8,
            8
        )
    {}

    function _receiveCollateralFrom(address sender, uint256 amount)
        internal
        override
        returns (uint256 receivedAmount)
    {
        uint256 beforeBalance = COLLATERALIZED_TOKEN.balanceOf(address(this));
        COLLATERALIZED_TOKEN.safeTransferFrom(sender, address(this), amount);
        uint256 afterBalance = COLLATERALIZED_TOKEN.balanceOf(address(this));
        receivedAmount = afterBalance.sub(beforeBalance);
        require(
            receivedAmount == amount,
            "actual sent amount must be the same as the expected amount"
        );
    }

    function _getBondTokenName(uint256 maturity, bytes memory fnMap)
        internal
        view
        override
        returns (string memory symbol, string memory name)
    {
        bytes32 fnMapID = generateFnMapID(fnMap);
        LineSegment[] memory segments = _registeredFnMap[fnMapID];
        uint64 sbtStrikePrice = _getSbtStrikePrice(segments);
        uint64 lbtStrikePrice = _getLbtStrikePrice(segments);
        uint64 sbtStrikePriceInverseE0 = sbtStrikePrice != 0
            ? uint64(10)**DECIMALS_OF_ORACLE_PRICE / sbtStrikePrice
            : 0;
        uint64 lbtStrikePriceInverseE0 = lbtStrikePrice != 0
            ? uint64(10)**DECIMALS_OF_ORACLE_PRICE / lbtStrikePrice
            : 0;

        if (sbtStrikePrice != 0) {
            return
                BOND_TOKEN_NAMER.genBondTokenName(
                    "SBT",
                    "SBT",
                    maturity,
                    sbtStrikePriceInverseE0
                );
        } else if (lbtStrikePrice != 0) {
            return
                BOND_TOKEN_NAMER.genBondTokenName(
                    "LBT",
                    "LBT",
                    maturity,
                    lbtStrikePriceInverseE0
                );
        } else {
            return
                BOND_TOKEN_NAMER.genBondTokenName(
                    "IMT",
                    "Immortal Option",
                    maturity,
                    0
                );
        }
    }
}