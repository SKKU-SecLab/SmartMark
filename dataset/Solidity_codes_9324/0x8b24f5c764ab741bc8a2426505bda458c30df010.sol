
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





interface BondMakerInterface {

    event LogNewBond(
        bytes32 indexed bondID,
        address bondTokenAddress,
        uint64 stableStrikePrice,
        bytes32 fnMapID
    );

    event LogNewBondGroup(uint256 indexed bondGroupID);

    event LogIssueNewBonds(
        uint256 indexed bondGroupID,
        address indexed issuer,
        uint256 amount
    );

    event LogReverseBondToETH(
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

    event LogTransferETH(
        address indexed from,
        address indexed to,
        uint256 value
    );

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function registerNewBondGroup(
        bytes32[] calldata bondIDList,
        uint256 maturity
    ) external returns (uint256 bondGroupID);


    function issueNewBonds(uint256 bondGroupID)
        external
        payable
        returns (uint256 amount);


    function reverseBondToETH(uint256 bondGroupID, uint256 amount)
        external
        returns (bool success);


    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external returns (bool);


    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID) external;


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


    function generateBondID(uint256 maturity, bytes calldata functionHash)
        external
        pure
        returns (bytes32 bondID);

}





abstract contract Time {
    function _getBlockTimestampSec()
        internal
        view
        returns (uint256 unixtimesec)
    {
        unixtimesec = now; // solium-disable-line security/no-block-members
    }
}





interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(
        address indexed from,
        address indexed to,
        uint256 value
    );
}






abstract contract TransferETH is TransferETHInterface {
    receive() external override payable {
        emit LogTransferETH(msg.sender, address(this), msg.value);
    }

    function _hasSufficientBalance(uint256 amount)
        internal
        view
        returns (bool ok)
    {
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
        _transferETH(
            recipient,
            amount,
            "TransferETH: transfer amount exceeds balance"
        );
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







interface BondTokenInterface is TransferETHInterface, IERC20 {
    event LogExpire(
        uint128 rateNumerator,
        uint128 rateDenominator,
        bool firstTime
    );

    function mint(address account, uint256 amount)
        external
        returns (bool success);

    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);

    function burn(uint256 amount) external returns (bool success);

    function burnAll() external returns (uint256 amount);

    function isMinter(address account) external view returns (bool minter);

    function getRate()
        external
        view
        returns (uint128 rateNumerator, uint128 rateDenominator);
}





abstract contract DeployerRole {
    address internal immutable _deployer;

    modifier onlyDeployer() {
        require(
            _isDeployer(msg.sender),
            "only deployer is allowed to call this function"
        );
        _;
    }

    constructor() public {
        _deployer = msg.sender;
    }

    function _isDeployer(address account) internal view returns (bool) {
        return account == _deployer;
    }
}









contract BondToken is DeployerRole, BondTokenInterface, TransferETH, ERC20 {
    struct Frac128x128 {
        uint128 numerator;
        uint128 denominator;
    }

    Frac128x128 internal _rate;

    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
        _setupDecimals(8);
    }

    function mint(address account, uint256 amount)
        public
        virtual
        override
        onlyDeployer
        returns (bool success)
    {
        require(!isExpired(), "this token contract has expired");
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
            allowance(sender, msg.sender).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function expire(uint128 rateNumerator, uint128 rateDenominator)
        public
        override
        onlyDeployer
        returns (bool isFirstTime)
    {
        isFirstTime = !isExpired();
        if (isFirstTime) {
            _setRate(Frac128x128(rateNumerator, rateDenominator));
        }

        emit LogExpire(rateNumerator, rateDenominator, isFirstTime);
    }

    function simpleBurn(address from, uint256 amount)
        public
        onlyDeployer
        returns (bool)
    {
        if (amount > balanceOf(from)) {
            return false;
        }

        _burn(from, amount);
        return true;
    }

    function burn(uint256 amount) public override returns (bool success) {
        if (!isExpired()) {
            return false;
        }

        _burn(msg.sender, amount);

        if (_rate.numerator != 0) {
            uint256 withdrawAmount = amount
                .mul(10**(18 - 8))
                .mul(_rate.numerator)
                .div(_rate.denominator);
            _transferETH(
                msg.sender,
                withdrawAmount,
                "system error: insufficient balance"
            );
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

    function isExpired() public view returns (bool) {
        return _rate.denominator != 0;
    }

    function isMinter(address account) public override view returns (bool) {
        return _isDeployer(account);
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
        require(numOfSegment > 0, "polyline must not be empty array");

        LineSegment memory firstSegment = polyline[0];

        require(
            firstSegment.left.x == uint64(0),
            "the x coordinate of left end of the first segment is 0"
        );
        require(
            firstSegment.left.y == uint64(0),
            "the y coordinate of left end of the first segment is 0"
        );

        LineSegment memory lastSegment = polyline[numOfSegment - 1];

        int256 gradientNumerator = int256(lastSegment.right.y).sub(
            lastSegment.left.y
        );
        int256 gradientDenominator = int256(lastSegment.right.x).sub(
            lastSegment.left.x
        );
        require(
            gradientNumerator >= 0 && gradientNumerator <= gradientDenominator,
            "the gradient of last line segment must be non-negative number equal to or less than 1"
        );

        assertLineSegment(firstSegment);

        for (uint256 i = 1; i < numOfSegment; i++) {
            LineSegment memory leftSegment = polyline[i - 1];
            LineSegment memory rightSegment = polyline[i];

            assertLineSegment(rightSegment);

            require(
                leftSegment.right.x == rightSegment.left.x,
                "given polyline is not single-valued function."
            );

            require(
                leftSegment.right.y == rightSegment.left.y,
                "given polyline is not continuous function"
            );
        }
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





interface OracleInterface {
    function alive() external view returns (bool);

    function latestId() external returns (uint256);

    function latestPrice() external returns (uint256);

    function latestTimestamp() external returns (uint256);

    function getPrice(uint256 id) external returns (uint256);

    function getTimestamp(uint256 id) external returns (uint256);

    function getVolatility() external returns (uint256);
}






abstract contract UseOracle {
    OracleInterface internal _oracleContract;

    constructor(address contractAddress) public {
        require(
            contractAddress != address(0),
            "contract should be non-zero address"
        );
        _oracleContract = OracleInterface(contractAddress);
    }

    function _getOracleData()
        internal
        returns (uint256 rateETH2USDE8, uint256 volatilityE8)
    {
        rateETH2USDE8 = _oracleContract.latestPrice();
        volatilityE8 = _oracleContract.getVolatility();

        return (rateETH2USDE8, volatilityE8);
    }

    function _getPriceOn(uint256 timestamp, uint256 hintID)
        internal
        returns (uint256 rateETH2USDE8)
    {
        uint256 latestID = _oracleContract.latestId();
        require(
            latestID != 0,
            "system error: the ID of oracle data should not be zero"
        );

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






abstract contract UseBondTokenName {
    BondTokenNameInterface internal immutable _bondTokenNameContract;

    constructor(address contractAddress) public {
        require(
            contractAddress != address(0),
            "contract should be non-zero address"
        );
        _bondTokenNameContract = BondTokenNameInterface(contractAddress);
    }
}













contract BondMaker is
    UseSafeMath,
    BondMakerInterface,
    Time,
    TransferETH,
    Polyline,
    UseOracle,
    UseBondTokenName
{
    uint8 internal constant DECIMALS_OF_BOND_AMOUNT = 8;

    address internal immutable LIEN_TOKEN_ADDRESS;
    uint256 internal immutable MATURITY_SCALE;

    uint256 public nextBondGroupID = 1;

    struct BondInfo {
        uint256 maturity;
        BondToken contractInstance;
        uint64 solidStrikePriceE4;
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
        address lienTokenAddress,
        address bondTokenNameAddress,
        uint256 maturityScale
    ) public UseOracle(oracleAddress) UseBondTokenName(bondTokenNameAddress) {
        LIEN_TOKEN_ADDRESS = lienTokenAddress;
        require(maturityScale != 0, "MATURITY_SCALE must be positive");
        MATURITY_SCALE = maturityScale;
    }

    function registerNewBond(uint256 maturity, bytes memory fnMap)
        public
        override
        returns (
            bytes32,
            address,
            uint64,
            bytes32
        )
    {
        require(
            maturity > _getBlockTimestampSec(),
            "the maturity has already expired"
        );
        require(maturity % MATURITY_SCALE == 0, "maturity must be HH:00:00");

        bytes32 bondID = generateBondID(maturity, fnMap);

        require(
            address(_bonds[bondID].contractInstance) == address(0),
            "already register given bond type"
        );

        bytes32 fnMapID = generateFnMapID(fnMap);
        if (_registeredFnMap[fnMapID].length == 0) {
            uint256[] memory polyline = decodePolyline(fnMap);
            for (uint256 i = 0; i < polyline.length; i++) {
                _registeredFnMap[fnMapID].push(unzipLineSegment(polyline[i]));
            }

            assertPolyline(_registeredFnMap[fnMapID]);
        }

        uint64 solidStrikePrice = _getSolidStrikePrice(
            _registeredFnMap[fnMapID]
        );
        uint64 rateLBTWorthless = _getRateLBTWorthless(
            _registeredFnMap[fnMapID]
        );

        (
            string memory shortName,
            string memory longName
        ) = _bondTokenNameContract.getBondTokenName(
            maturity,
            solidStrikePrice,
            rateLBTWorthless
        );

        BondToken bondTokenContract = _createNewBondToken(longName, shortName);

        _bonds[bondID] = BondInfo({
            maturity: maturity,
            contractInstance: bondTokenContract,
            solidStrikePriceE4: solidStrikePrice,
            fnMapID: fnMapID
        });

        emit LogNewBond(
            bondID,
            address(bondTokenContract),
            solidStrikePrice,
            fnMapID
        );

        return (bondID, address(bondTokenContract), solidStrikePrice, fnMapID);
    }

    function _assertBondGroup(bytes32[] memory bondIDs, uint256 maturity)
        internal
        view
    {
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

    function registerNewBondGroup(bytes32[] memory bondIDs, uint256 maturity)
        public
        override
        returns (uint256 bondGroupID)
    {
        _assertBondGroup(bondIDs, maturity);

        bondGroupID = nextBondGroupID;
        nextBondGroupID = nextBondGroupID.add(1);

        _bondGroupList[bondGroupID] = BondGroup(bondIDs, maturity);

        emit LogNewBondGroup(bondGroupID);

        return bondGroupID;
    }

    function issueNewBonds(uint256 bondGroupID)
        public
        override
        payable
        returns (uint256)
    {
        BondGroup storage bondGroup = _bondGroupList[bondGroupID];
        bytes32[] storage bondIDs = bondGroup.bondIDs;
        require(
            _getBlockTimestampSec() < bondGroup.maturity,
            "the maturity has already expired"
        );

        uint256 fee = msg.value.mul(2).div(1002);

        uint256 amount = msg.value.sub(fee).div(10**10); // ether's decimal is 18 and that of LBT is 8;

        bytes32 bondID;
        for (
            uint256 bondFnMapIndex = 0;
            bondFnMapIndex < bondIDs.length;
            bondFnMapIndex++
        ) {
            bondID = bondIDs[bondFnMapIndex];
            _issueNewBond(bondID, msg.sender, amount);
        }

        _transferETH(payable(LIEN_TOKEN_ADDRESS), fee);

        emit LogIssueNewBonds(bondGroupID, msg.sender, amount);

        return amount;
    }

    function reverseBondToETH(uint256 bondGroupID, uint256 amountE8)
        public
        override
        returns (bool)
    {
        BondGroup storage bondGroup = _bondGroupList[bondGroupID];
        bytes32[] storage bondIDs = bondGroup.bondIDs;
        require(
            _getBlockTimestampSec() < bondGroup.maturity,
            "the maturity has already expired"
        );
        bytes32 bondID;
        for (
            uint256 bondFnMapIndex = 0;
            bondFnMapIndex < bondIDs.length;
            bondFnMapIndex++
        ) {
            bondID = bondIDs[bondFnMapIndex];
            _burnBond(bondID, msg.sender, amountE8);
        }

        _transferETH(
            msg.sender,
            amountE8.mul(10**10),
            "system error: insufficient Ether balance"
        );

        emit LogReverseBondToETH(bondGroupID, msg.sender, amountE8.mul(10**10));

        return true;
    }

    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] memory exceptionBonds
    ) public override returns (bool) {
        (bytes32[] memory inputIDs, uint256 inputMaturity) = getBondGroup(
            inputBondGroupID
        );
        (bytes32[] memory outputIDs, uint256 outputMaturity) = getBondGroup(
            outputBondGroupID
        );
        require(
            inputMaturity == outputMaturity,
            "cannot exchange bonds with different maturities"
        );
        require(
            _getBlockTimestampSec() < inputMaturity,
            "the maturity has already expired"
        );
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
                _issueNewBond(outputIDs[i], msg.sender, amount);
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
        public
        override
    {
        if (oracleHintID == 0) {
            _distributeETH2BondTokenContract(
                bondGroupID,
                _oracleContract.latestId()
            );
        } else {
            _distributeETH2BondTokenContract(bondGroupID, oracleHintID);
        }
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
        solidStrikePrice = bondInfo.solidStrikePriceE4;
        fnMapID = bondInfo.fnMapID;
    }

    function getFnMap(bytes32 fnMapID)
        public
        override
        view
        returns (bytes memory)
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
        virtual
        override
        view
        returns (bytes32[] memory bondIDs, uint256 maturity)
    {
        BondGroup memory bondGroup = _bondGroupList[bondGroupID];
        bondIDs = bondGroup.bondIDs;
        maturity = bondGroup.maturity;
    }

    function generateFnMapID(bytes memory fnMap) public pure returns (bytes32) {
        return keccak256(fnMap);
    }

    function generateBondID(uint256 maturity, bytes memory fnMap)
        public
        override
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(maturity, fnMap));
    }

    function _createNewBondToken(string memory name, string memory symbol)
        internal
        virtual
        returns (BondToken)
    {
        return new BondToken(name, symbol);
    }

    function _issueNewBond(
        bytes32 bondID,
        address account,
        uint256 amount
    ) internal {
        BondToken bondTokenContract = _bonds[bondID].contractInstance;
        require(
            address(bondTokenContract) != address(0),
            "the bond is not registered"
        );
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
        BondToken bondTokenContract = _bonds[bondID].contractInstance;
        require(
            address(bondTokenContract) != address(0),
            "the bond is not registered"
        );
        require(
            bondTokenContract.simpleBurn(account, amount),
            "failed to burn bond token"
        );
    }

    function _distributeETH2BondTokenContract(
        uint256 bondGroupID,
        uint256 oracleHintID
    ) internal {
        BondGroup storage bondGroup = _bondGroupList[bondGroupID];
        require(bondGroup.bondIDs.length > 0, "the bond group does not exist");
        require(
            _getBlockTimestampSec() >= bondGroup.maturity,
            "the bond has not expired yet"
        );

        uint256 rateETH2USDE8 = _getPriceOn(bondGroup.maturity, oracleHintID);

        uint256 rateETH2USDE4 = rateETH2USDE8.div(10000);
        require(
            rateETH2USDE4 != 0,
            "system error: rate should be non-zero value"
        );
        require(
            rateETH2USDE4 < 2**64,
            "system error: rate should be less than the maximum value of uint64"
        );

        for (uint256 i = 0; i < bondGroup.bondIDs.length; i++) {
            bytes32 bondID = bondGroup.bondIDs[i];
            BondToken bondTokenContract = _bonds[bondID].contractInstance;
            require(
                address(bondTokenContract) != address(0),
                "the bond is not registered"
            );

            LineSegment[] storage segments = _registeredFnMap[_bonds[bondID]
                .fnMapID];

            (uint256 segmentIndex, bool ok) = _correspondSegment(
                segments,
                uint64(rateETH2USDE4)
            );

            require(
                ok,
                "system error: did not found a segment whose price range include USD/ETH rate"
            );
            LineSegment storage segment = segments[segmentIndex];
            (uint128 n, uint64 _d) = _mapXtoY(segment, uint64(rateETH2USDE4));

            uint128 d = uint128(_d) * uint128(rateETH2USDE4);

            uint256 totalSupply = bondTokenContract.totalSupply();
            bool expiredFlag = bondTokenContract.expire(n, d);

            if (expiredFlag) {
                uint256 payment = totalSupply.mul(10**(18 - 8)).mul(n).div(d);
                _transferETH(
                    address(bondTokenContract),
                    payment,
                    "system error: BondMaker's balance is less than payment"
                );
            }
        }
    }

    function _getSolidStrikePrice(LineSegment[] memory polyline)
        internal
        pure
        returns (uint64)
    {
        uint64 solidStrikePrice = polyline[0].right.x;

        if (solidStrikePrice == 0) {
            return 0;
        }

        for (uint256 i = 0; i < polyline.length; i++) {
            LineSegment memory segment = polyline[i];
            if (segment.right.y != solidStrikePrice) {
                return 0;
            }
        }

        return uint64(solidStrikePrice);
    }

    function _getRateLBTWorthless(LineSegment[] memory polyline)
        internal
        pure
        returns (uint64)
    {
        uint64 rateLBTWorthless = polyline[0].right.x;

        if (rateLBTWorthless == 0) {
            return 0;
        }

        for (uint256 i = 0; i < polyline.length; i++) {
            LineSegment memory segment = polyline[i];
            if (segment.right.y.add(rateLBTWorthless) != segment.right.x) {
                return 0;
            }
        }

        return uint64(rateLBTWorthless);
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
}