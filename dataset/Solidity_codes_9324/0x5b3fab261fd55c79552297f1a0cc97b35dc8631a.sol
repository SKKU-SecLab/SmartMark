
pragma solidity 0.5.2;


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

library MathLib {

    int256 constant INT256_MIN = int256((uint256(1) << 255));
    int256 constant INT256_MAX = int256(~((uint256(1) << 255)));

    function multiply(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'MathLib: multiplication overflow');

        return c;
    }

    function divideFractional(
        uint256 a,
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (uint256) {

        return multiply(a, numerator) / denominator;
    }

    function subtract(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, 'MathLib: subtraction overflow');
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, 'MathLib: addition overflow');
        return c;
    }

    function calculateCollateralToReturn(
        uint priceFloor,
        uint priceCap,
        uint qtyMultiplier,
        uint longQty,
        uint shortQty,
        uint price
    ) internal pure returns (uint) {

        uint neededCollateral = 0;
        uint maxLoss;
        if (longQty > 0) {
            if (price <= priceFloor) {
                maxLoss = 0;
            } else {
                maxLoss = subtract(price, priceFloor);
            }
            neededCollateral = multiply(multiply(maxLoss, longQty), qtyMultiplier);
        }

        if (shortQty > 0) {
            if (price >= priceCap) {
                maxLoss = 0;
            } else {
                maxLoss = subtract(priceCap, price);
            }
            neededCollateral = add(
                neededCollateral,
                multiply(multiply(maxLoss, shortQty), qtyMultiplier)
            );
        }
        return neededCollateral;
    }

    function calculateTotalCollateral(
        uint priceFloor,
        uint priceCap,
        uint qtyMultiplier
    ) internal pure returns (uint) {

        return multiply(subtract(priceCap, priceFloor), qtyMultiplier);
    }

    function calculateFeePerUnit(
        uint priceFloor,
        uint priceCap,
        uint qtyMultiplier,
        uint feeInBasisPoints
    ) internal pure returns (uint) {

        uint midPrice = add(priceCap, priceFloor) / 2;
        return multiply(multiply(midPrice, qtyMultiplier), feeInBasisPoints) / 10000;
    }
}

library StringLib {

    function bytes32ToString(bytes32 bytesToConvert)
        internal
        pure
        returns (string memory)
    {

        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = bytesToConvert[i];
        }
        return string(bytesArray);
    }
}

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

contract PositionToken is ERC20, Ownable {

    string public name;
    string public symbol;
    uint8 public decimals;

    MarketSide public MARKET_SIDE; // 0 = Long, 1 = Short
    enum MarketSide { Long, Short }

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 marketSide
    ) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = 0;
        MARKET_SIDE = MarketSide(marketSide);
    }

    function mintAndSendToken(uint256 qtyToMint, address recipient) external onlyOwner {

        _mint(recipient, qtyToMint);
    }

    function redeemToken(uint256 qtyToRedeem, address redeemer) external onlyOwner {

        _burn(redeemer, qtyToRedeem);
    }
}

contract MarketContract is Ownable {

    using StringLib for *;

    string public CONTRACT_NAME;
    address public COLLATERAL_TOKEN_ADDRESS;
    address public COLLATERAL_POOL_ADDRESS;
    uint public PRICE_CAP;
    uint public PRICE_FLOOR;
    uint public PRICE_DECIMAL_PLACES; // how to convert the pricing from decimal format (if valid) to integer
    uint public QTY_MULTIPLIER; // multiplier corresponding to the value of 1 increment in price to token base units
    uint public COLLATERAL_PER_UNIT; // required collateral amount for the full range of outcome tokens
    uint public COLLATERAL_TOKEN_FEE_PER_UNIT;
    uint public MKT_TOKEN_FEE_PER_UNIT;
    uint public EXPIRATION;
    uint public SETTLEMENT_DELAY = 1 days;
    address public LONG_POSITION_TOKEN;
    address public SHORT_POSITION_TOKEN;

    uint public lastPrice;
    uint public settlementPrice;
    uint public settlementTimeStamp;
    bool public isSettled = false;

    event UpdatedLastPrice(uint256 price);
    event ContractSettled(uint settlePrice);

    constructor(
        bytes32[3] memory contractNames,
        address[3] memory baseAddresses,
        uint[7] memory contractSpecs
    ) public {
        PRICE_FLOOR = contractSpecs[0];
        PRICE_CAP = contractSpecs[1];
        require(PRICE_CAP > PRICE_FLOOR, 'PRICE_CAP must be greater than PRICE_FLOOR');

        PRICE_DECIMAL_PLACES = contractSpecs[2];
        QTY_MULTIPLIER = contractSpecs[3];
        EXPIRATION = contractSpecs[6];
        require(EXPIRATION > now, 'EXPIRATION must be in the future');
        require(QTY_MULTIPLIER != 0, 'QTY_MULTIPLIER cannot be 0');

        COLLATERAL_TOKEN_ADDRESS = baseAddresses[1];
        COLLATERAL_POOL_ADDRESS = baseAddresses[2];
        COLLATERAL_PER_UNIT = MathLib.calculateTotalCollateral(
            PRICE_FLOOR,
            PRICE_CAP,
            QTY_MULTIPLIER
        );
        COLLATERAL_TOKEN_FEE_PER_UNIT = MathLib.calculateFeePerUnit(
            PRICE_FLOOR,
            PRICE_CAP,
            QTY_MULTIPLIER,
            contractSpecs[4]
        );
        MKT_TOKEN_FEE_PER_UNIT = MathLib.calculateFeePerUnit(
            PRICE_FLOOR,
            PRICE_CAP,
            QTY_MULTIPLIER,
            contractSpecs[5]
        );

        CONTRACT_NAME = contractNames[0].bytes32ToString();
        PositionToken longPosToken = new PositionToken(
            'MARKET Protocol Long Position Token',
            contractNames[1].bytes32ToString(),
            uint8(PositionToken.MarketSide.Long)
        );
        PositionToken shortPosToken = new PositionToken(
            'MARKET Protocol Short Position Token',
            contractNames[2].bytes32ToString(),
            uint8(PositionToken.MarketSide.Short)
        );

        LONG_POSITION_TOKEN = address(longPosToken);
        SHORT_POSITION_TOKEN = address(shortPosToken);

        transferOwnership(baseAddresses[0]);
    }


    function mintPositionTokens(uint256 qtyToMint, address minter)
        external
        onlyCollateralPool
    {

        PositionToken(LONG_POSITION_TOKEN).mintAndSendToken(qtyToMint, minter);
        PositionToken(SHORT_POSITION_TOKEN).mintAndSendToken(qtyToMint, minter);
    }

    function redeemLongToken(uint256 qtyToRedeem, address redeemer)
        external
        onlyCollateralPool
    {

        PositionToken(LONG_POSITION_TOKEN).redeemToken(qtyToRedeem, redeemer);
    }

    function redeemShortToken(uint256 qtyToRedeem, address redeemer)
        external
        onlyCollateralPool
    {

        PositionToken(SHORT_POSITION_TOKEN).redeemToken(qtyToRedeem, redeemer);
    }


    function isPostSettlementDelay() public view returns (bool) {

        return isSettled && (now >= (settlementTimeStamp + SETTLEMENT_DELAY));
    }


    function checkSettlement() internal {

        require(!isSettled, 'Contract is already settled'); // already settled.

        uint newSettlementPrice;
        if (now > EXPIRATION) {
            isSettled = true; // time based expiration has occurred.
            newSettlementPrice = lastPrice;
        } else if (lastPrice >= PRICE_CAP) {
            isSettled = true;
            newSettlementPrice = PRICE_CAP;
        } else if (lastPrice <= PRICE_FLOOR) {
            isSettled = true;
            newSettlementPrice = PRICE_FLOOR;
        }

        if (isSettled) {
            settleContract(newSettlementPrice);
        }
    }

    function settleContract(uint finalSettlementPrice) internal {

        settlementTimeStamp = now;
        settlementPrice = finalSettlementPrice;
        emit ContractSettled(finalSettlementPrice);
    }

    modifier onlyCollateralPool {

        require(
            msg.sender == COLLATERAL_POOL_ADDRESS,
            'Only callable from the collateral pool'
        );
        _;
    }
}

contract MarketContractRegistryInterface {

    function addAddressToWhiteList(address contractAddress) external;


    function isAddressWhiteListed(address contractAddress) external view returns (bool);

}

contract MarketCollateralPool is ReentrancyGuard, Ownable {

    using MathLib for uint;
    using MathLib for int;
    using SafeERC20 for ERC20;

    address public marketContractRegistry;
    address public mktToken;

    mapping(address => uint) public contractAddressToCollateralPoolBalance; // current balance of all collateral committed
    mapping(address => uint) public feesCollectedByTokenAddress;

    event TokensMinted(
        address indexed marketContract,
        address indexed user,
        address indexed feeToken,
        uint qtyMinted,
        uint collateralLocked,
        uint feesPaid
    );

    event TokensRedeemed(
        address indexed marketContract,
        address indexed user,
        uint longQtyRedeemed,
        uint shortQtyRedeemed,
        uint collateralUnlocked
    );

    constructor(address marketContractRegistryAddress, address mktTokenAddress)
        public
        ReentrancyGuard()
    {
        marketContractRegistry = marketContractRegistryAddress;
        mktToken = mktTokenAddress;
    }


    function mintPositionTokens(
        address marketContractAddress,
        uint qtyToMint,
        bool isAttemptToPayInMKT
    ) external onlyWhiteListedAddress(marketContractAddress) nonReentrant {

        MarketContract marketContract = MarketContract(marketContractAddress);
        require(!marketContract.isSettled(), 'Contract is already settled');

        address collateralTokenAddress = marketContract.COLLATERAL_TOKEN_ADDRESS();
        uint neededCollateral = MathLib.multiply(
            qtyToMint,
            marketContract.COLLATERAL_PER_UNIT()
        );
        bool isPayFeesInMKT = (isAttemptToPayInMKT &&
            marketContract.MKT_TOKEN_FEE_PER_UNIT() != 0) ||
            (!isAttemptToPayInMKT &&
                marketContract.MKT_TOKEN_FEE_PER_UNIT() != 0 &&
                marketContract.COLLATERAL_TOKEN_FEE_PER_UNIT() == 0);

        uint feeAmount;
        uint totalCollateralTokenTransferAmount;
        address feeToken;
        if (isPayFeesInMKT) {
            feeAmount = MathLib.multiply(
                qtyToMint,
                marketContract.MKT_TOKEN_FEE_PER_UNIT()
            );
            totalCollateralTokenTransferAmount = neededCollateral;
            feeToken = mktToken;

            ERC20(mktToken).safeTransferFrom(msg.sender, address(this), feeAmount);
        } else {
            feeAmount = MathLib.multiply(
                qtyToMint,
                marketContract.COLLATERAL_TOKEN_FEE_PER_UNIT()
            );
            totalCollateralTokenTransferAmount = neededCollateral.add(feeAmount);
            feeToken = collateralTokenAddress;
        }

        ERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransferFrom(
            msg.sender,
            address(this),
            totalCollateralTokenTransferAmount
        );

        if (feeAmount != 0) {
            feesCollectedByTokenAddress[feeToken] = feesCollectedByTokenAddress[feeToken]
                .add(feeAmount);
        }

        contractAddressToCollateralPoolBalance[marketContractAddress] = contractAddressToCollateralPoolBalance[marketContractAddress]
            .add(neededCollateral);

        marketContract.mintPositionTokens(qtyToMint, msg.sender);

        emit TokensMinted(
            marketContractAddress,
            msg.sender,
            feeToken,
            qtyToMint,
            neededCollateral,
            feeAmount
        );
    }

    function redeemPositionTokens(address marketContractAddress, uint qtyToRedeem)
        external
        onlyWhiteListedAddress(marketContractAddress)
    {

        MarketContract marketContract = MarketContract(marketContractAddress);

        marketContract.redeemLongToken(qtyToRedeem, msg.sender);
        marketContract.redeemShortToken(qtyToRedeem, msg.sender);

        uint collateralToReturn = MathLib.multiply(
            qtyToRedeem,
            marketContract.COLLATERAL_PER_UNIT()
        );
        contractAddressToCollateralPoolBalance[marketContractAddress] = contractAddressToCollateralPoolBalance[marketContractAddress]
            .subtract(collateralToReturn);

        ERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransfer(
            msg.sender,
            collateralToReturn
        );

        emit TokensRedeemed(
            marketContractAddress,
            msg.sender,
            qtyToRedeem,
            qtyToRedeem,
            collateralToReturn
        );
    }

    function settleAndClose(
        address marketContractAddress,
        uint longQtyToRedeem,
        uint shortQtyToRedeem
    ) external onlyWhiteListedAddress(marketContractAddress) {

        MarketContract marketContract = MarketContract(marketContractAddress);
        require(
            marketContract.isPostSettlementDelay(),
            'Contract is not past settlement delay'
        );

        if (longQtyToRedeem > 0) {
            marketContract.redeemLongToken(longQtyToRedeem, msg.sender);
        }

        if (shortQtyToRedeem > 0) {
            marketContract.redeemShortToken(shortQtyToRedeem, msg.sender);
        }

        uint collateralToReturn = MathLib.calculateCollateralToReturn(
            marketContract.PRICE_FLOOR(),
            marketContract.PRICE_CAP(),
            marketContract.QTY_MULTIPLIER(),
            longQtyToRedeem,
            shortQtyToRedeem,
            marketContract.settlementPrice()
        );

        contractAddressToCollateralPoolBalance[marketContractAddress] = contractAddressToCollateralPoolBalance[marketContractAddress]
            .subtract(collateralToReturn);

        ERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransfer(
            msg.sender,
            collateralToReturn
        );

        emit TokensRedeemed(
            marketContractAddress,
            msg.sender,
            longQtyToRedeem,
            shortQtyToRedeem,
            collateralToReturn
        );
    }

    function withdrawFees(address feeTokenAddress, address feeRecipient)
        public
        onlyOwner
    {

        uint feesAvailableForWithdrawal = feesCollectedByTokenAddress[feeTokenAddress];
        require(feesAvailableForWithdrawal != 0, 'No fees available for withdrawal');
        require(feeRecipient != address(0), 'Cannot send fees to null address');
        feesCollectedByTokenAddress[feeTokenAddress] = 0;
        ERC20(feeTokenAddress).safeTransfer(feeRecipient, feesAvailableForWithdrawal);
    }

    function setMKTTokenAddress(address mktTokenAddress) public onlyOwner {

        require(mktTokenAddress != address(0), 'Cannot set MKT Token Address To Null');
        mktToken = mktTokenAddress;
    }

    function setMarketContractRegistryAddress(address marketContractRegistryAddress)
        public
        onlyOwner
    {

        require(
            marketContractRegistryAddress != address(0),
            'Cannot set Market Contract Registry Address To Null'
        );
        marketContractRegistry = marketContractRegistryAddress;
    }


    modifier onlyWhiteListedAddress(address marketContractAddress) {

        require(
            MarketContractRegistryInterface(marketContractRegistry).isAddressWhiteListed(
                marketContractAddress
            ),
            'Contract is not whitelisted'
        );
        _;
    }
}

contract MarketContractMPX is MarketContract {

    address public ORACLE_HUB_ADDRESS;
    string public ORACLE_URL;
    string public ORACLE_STATISTIC;

    constructor(
        bytes32[3] memory contractNames,
        address[3] memory baseAddresses,
        address oracleHubAddress,
        uint[7] memory contractSpecs,
        string memory oracleURL,
        string memory oracleStatistic
    ) public MarketContract(contractNames, baseAddresses, contractSpecs) {
        ORACLE_URL = oracleURL;
        ORACLE_STATISTIC = oracleStatistic;
        ORACLE_HUB_ADDRESS = oracleHubAddress;
    }


    function oracleCallBack(uint256 price) public onlyOracleHub {

        require(!isSettled);
        lastPrice = price;
        emit UpdatedLastPrice(price);
        checkSettlement(); // Verify settlement at expiration or requested early settlement.
    }

    function arbitrateSettlement(uint256 price) public onlyOwner {

        require(
            price >= PRICE_FLOOR && price <= PRICE_CAP,
            'arbitration price must be within contract bounds'
        );
        lastPrice = price;
        emit UpdatedLastPrice(price);
        settleContract(price);
        isSettled = true;
    }

    modifier onlyOracleHub() {

        require(msg.sender == ORACLE_HUB_ADDRESS, 'only callable by the oracle hub');
        _;
    }

    function setOracleHubAddress(address oracleHubAddress) public onlyOwner {

        require(
            oracleHubAddress != address(0),
            'cannot set oracleHubAddress to null address'
        );
        ORACLE_HUB_ADDRESS = oracleHubAddress;
    }
}

contract MarketContractFactoryMPX is Ownable {

    address public marketContractRegistry;
    address public oracleHub;
    address public MARKET_COLLATERAL_POOL;

    event MarketContractCreated(address indexed creator, address indexed contractAddress);

    constructor(
        address registryAddress,
        address collateralPoolAddress,
        address oracleHubAddress
    ) public {
        require(registryAddress != address(0), 'registryAddress can not be null');
        require(
            collateralPoolAddress != address(0),
            'collateralPoolAddress can not be null'
        );
        require(oracleHubAddress != address(0), 'oracleHubAddress can not be null');

        marketContractRegistry = registryAddress;
        MARKET_COLLATERAL_POOL = collateralPoolAddress;
        oracleHub = oracleHubAddress;
    }

    function deployMarketContractMPX(
        bytes32[3] calldata contractNames,
        address collateralTokenAddress,
        uint[7] calldata contractSpecs,
        string calldata oracleURL,
        string calldata oracleStatistic
    ) external onlyOwner returns (address) {

        MarketContractMPX mktContract = new MarketContractMPX(
            contractNames,
            [owner(), collateralTokenAddress, MARKET_COLLATERAL_POOL],
            oracleHub, /*  */
            contractSpecs,
            oracleURL,
            oracleStatistic
        );

        MarketContractRegistryInterface(marketContractRegistry).addAddressToWhiteList(
            address(mktContract)
        );
        emit MarketContractCreated(msg.sender, address(mktContract));
        return address(mktContract);
    }

    function setRegistryAddress(address registryAddress) external onlyOwner {

        require(registryAddress != address(0), 'registryAddress can not be null');
        marketContractRegistry = registryAddress;
    }

    function setOracleHubAddress(address oracleHubAddress) external onlyOwner {

        require(oracleHubAddress != address(0), 'oracleHubAddress can not be null');
        oracleHub = oracleHubAddress;
    }
}

contract DSNote {

    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 bar,
        uint wad,
        bytes fax
    );

    modifier note {

        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }
        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract DSAuthority {

    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view returns (bool);

}

contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority public authority;
    address public owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract DSProxy is DSAuth, DSNote {

    function() external payable {}

    function execute(address _target, bytes memory _data)
        public
        payable
        auth
        note
        returns (bytes memory response)
    {

        require(_target != address(0), 'ds-proxy-target-address-required');

        assembly {
            let succeeded := delegatecall(
                sub(gas, 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    revert(add(response, 0x20), size)
                }
        }
    }
}

contract DSProxyFactory {

    event Created(address indexed sender, address indexed owner, address proxy);
    mapping(address => bool) public isProxy;
    address marketContractProxy;

    constructor() public {
        marketContractProxy = msg.sender;
    }

    modifier onlyMarketContractProxy() {

        require(
            msg.sender == marketContractProxy,
            'Only callable by MarketContractProxy'
        );
        _;
    }

    function build(address owner)
        public
        onlyMarketContractProxy()
        returns (address payable proxy)
    {

        proxy = address(new DSProxy());
        emit Created(msg.sender, owner, address(proxy));
        DSProxy(proxy).setOwner(owner);
        isProxy[proxy] = true;
    }

    function build() internal returns (address payable proxy) {

        proxy = build(msg.sender);
    }
}

contract MarketContractProxy is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    MarketContractFactoryMPX public marketContractFactoryMPX;

    address public HONEY_LEMON_ORACLE_ADDRESS;
    address public MINTER_BRIDGE_ADDRESS;
    address public COLLATERAL_TOKEN_ADDRESS; //imBTC

    uint public CONTRACT_DURATION_DAYS = 2; // for kovan deployment
    uint public CONTRACT_DURATION = CONTRACT_DURATION_DAYS * 24 * 60 * 60; // 28 days in seconds
    uint public CONTRACT_COLLATERAL_RATIO = 125000000; //1.25e8; 1.25, with 8 decimal places

    uint[7] public marketContractSpecs = [
        0, // floorPrice - the lower bound price for the CFD [constant]
        0, // capPrice - the upper bound price for the CFD [updated before deployment]
        8, // priceDecimalPlaces - number of decimals used to convert prices [constant]
        1, // qtyMultiplier - multiply traded qty by this value from base units of collateral token. [constant]
        0, // feeInBasisPoints - fee for minting tokens [constant]
        0, // mktFeeInBasisPoints - fees charged by the market in MKT [constant]
        0 // expirationTimeStamp [updated before deployment]
    ];

    address[] public marketContracts;

    mapping(address => uint256) addressToMarketId;

    uint256 internal latestMri = 0;

    DSProxyFactory dSProxyFactory;

    mapping(address => address) public addressToDSProxy;

    mapping(address => address) public dSProxyToAddress;

    constructor(
        address _marketContractFactoryMPX,
        address _honeyLemonOracle,
        address _minterBridge,
        address _imBTCTokenAddress
    ) public ReentrancyGuard() {
        require(
            _marketContractFactoryMPX != address(0),
            'invalid MarketContractFactoryMPX address'
        );
        require(_honeyLemonOracle != address(0), 'invalid HoneyLemonOracle address');
        require(_minterBridge != address(0), 'invalid MinterBridge address');
        require(_imBTCTokenAddress != address(0), 'invalid IMBTC address');

        marketContractFactoryMPX = MarketContractFactoryMPX(_marketContractFactoryMPX);
        HONEY_LEMON_ORACLE_ADDRESS = _honeyLemonOracle;
        MINTER_BRIDGE_ADDRESS = _minterBridge;
        COLLATERAL_TOKEN_ADDRESS = _imBTCTokenAddress;

        dSProxyFactory = new DSProxyFactory();
    }

    event PositionTokensMinted(
        uint256 qtyToMint,
        uint indexed marketId,
        string contractName,
        address indexed longTokenRecipient,
        address longTokenDSProxy,
        address indexed shortTokenRecipient,
        address shortTokenDSProxy,
        address latestMarketContract,
        address longTokenAddress,
        address shortTokenAddress,
        uint time
    );

    event MarketContractSettled(
        address indexed contractAddress,
        uint revenuePerUnit,
        uint index
    );

    event MarketContractDeployed(
        uint currentMRI,
        bytes32 contractName,
        uint expiration,
        uint indexed index,
        address contractAddress,
        uint collateralPerUnit
    );

    event dSProxyCreated(address owner, address DSProxy);


    modifier onlyHoneyLemonOracle() {

        require(msg.sender == HONEY_LEMON_ORACLE_ADDRESS, 'Only Honey Lemon Oracle');
        _;
    }

    modifier onlyMinterBridge() {

        require(msg.sender == MINTER_BRIDGE_ADDRESS, 'Only Minter Bridge');
        _;
    }

    modifier onlyIfFreshDailyContract() {

        require(isDailyContractDeployed(), "No contract has been deployed yet today");
        _;
    }


    function setOracleAddress(address _honeyLemonOracleAddress) external onlyOwner {

        require(
            _honeyLemonOracleAddress != address(0),
            'invalid HoneyLemonOracle address'
        );

        HONEY_LEMON_ORACLE_ADDRESS = _honeyLemonOracleAddress;
    }

    function setMinterBridgeAddress(address _minterBridgeAddress) external onlyOwner {

        require(_minterBridgeAddress != address(0), 'invalid MinterBridge address');

        MINTER_BRIDGE_ADDRESS = _minterBridgeAddress;
    }


    function getFillableAmounts(address[] calldata makerAddresses)
        external
        view
        returns (uint256[] memory fillableAmounts)
    {

        uint256 length = makerAddresses.length;
        fillableAmounts = new uint256[](length);

        for (uint256 i = 0; i != length; i++) {
            fillableAmounts[i] = getFillableAmount(makerAddresses[i]);
        }

        return fillableAmounts;
    }

    function getLatestMri() external view returns (uint256) {

        return latestMri;
    }

    function getAllMarketContracts() public view returns (address[] memory) {

        return marketContracts;
    }

    function getFillableAmount(address makerAddress) public view returns (uint256) {

        ERC20 collateralToken = ERC20(COLLATERAL_TOKEN_ADDRESS);

        uint minerBalance = collateralToken.balanceOf(makerAddress);
        uint minerAllowance = collateralToken.allowance(
            makerAddress,
            MINTER_BRIDGE_ADDRESS
        );

        uint uintMinAllowanceBalance = minerBalance < minerAllowance
            ? minerBalance
            : minerAllowance;

        MarketContract latestMarketContract = getLatestMarketContract();

        return
            MathLib.divideFractional(
                1,
                uintMinAllowanceBalance,
                latestMarketContract.COLLATERAL_PER_UNIT()
            );
    }

    function getLatestMarketContract() public view returns (MarketContractMPX) {

        uint lastIndex = marketContracts.length.sub(1);
        return MarketContractMPX(marketContracts[lastIndex]);
    }

    function getExpiringMarketContract() public view returns (MarketContractMPX) {

        uint contractsAdded = marketContracts.length;

        if (contractsAdded < CONTRACT_DURATION_DAYS) {
            return MarketContractMPX(address(0x0));
        }
        uint expiringIndex = contractsAdded.sub(CONTRACT_DURATION_DAYS);
        return MarketContractMPX(marketContracts[expiringIndex]);
    }

    function getCollateralPool(MarketContractMPX market)
        public
        view
        returns (MarketCollateralPool)
    {

        return MarketCollateralPool(market.COLLATERAL_POOL_ADDRESS());
    }

    function getLatestMarketCollateralPool() public view returns (MarketCollateralPool) {

        MarketContractMPX latestMarketContract = getLatestMarketContract();
        return getCollateralPool(latestMarketContract);
    }

    function calculateRequiredCollateral(uint amount) public view returns (uint) {

        MarketContractMPX latestMarketContract = getLatestMarketContract();
        return MathLib.multiply(amount, latestMarketContract.COLLATERAL_PER_UNIT());
    }

    function balanceOf(address owner) public view returns (uint) {

        address addressToCheck = getUserAddressOrDSProxy(owner);
        MarketContract latestMarketContract = getLatestMarketContract();
        ERC20 longToken = ERC20(latestMarketContract.LONG_POSITION_TOKEN());
        return longToken.balanceOf(addressToCheck);
    }

    function getTime() public view returns (uint) {

        return now;
    }

    function generateContractSpecs(uint currentMRI, uint expiration)
        public
        view
        returns (uint[7] memory)
    {

        uint[7] memory dailySpecs = marketContractSpecs;
        dailySpecs[1] = (
            CONTRACT_DURATION_DAYS.mul(currentMRI).mul(CONTRACT_COLLATERAL_RATIO)
        )
            .div(1e8);
        dailySpecs[6] = expiration;
        return dailySpecs;
    }

    function getUserAddressOrDSProxy(address inputAddress) public view returns (address) {

        return
            addressToDSProxy[inputAddress] == address(0)
                ? inputAddress
                : addressToDSProxy[inputAddress];
    }

    function isDailyContractDeployed() public view returns (bool) {

        uint settlementTimestamp = MarketContractMPX(getLatestMarketContract()).EXPIRATION();
        uint oneDayFromLatestDeployment = settlementTimestamp - CONTRACT_DURATION + 60 * 60 * 24;
        return getTime() < oneDayFromLatestDeployment;
    }


    function createDSProxyWallet() public returns (address) {

        address payable dsProxyWallet = dSProxyFactory.build(msg.sender);
        addressToDSProxy[msg.sender] = dsProxyWallet;
        dSProxyToAddress[dsProxyWallet] = msg.sender;

        emit dSProxyCreated(msg.sender, dsProxyWallet);

        return dsProxyWallet;
    }

    function batchRedeem(
        address[] memory tokenAddresses, // Address of the long or short token to redeem
        uint256[] memory tokensToRedeem // the number of tokens to redeem
    ) public nonReentrant {

        require(tokenAddresses.length == tokensToRedeem.length, 'Invalid input params');
        require(this.owner() == msg.sender, "You don't own this DSProxy GTFO");

        MarketContractMPX marketInstance;
        MarketCollateralPool marketCollateralPool;
        PositionToken tokenInstance;

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            tokenInstance = PositionToken(tokenAddresses[i]);

            require(
                tokenInstance.balanceOf(address(this)) >= tokensToRedeem[i],
                'Insufficient position token balance'
            );

            marketInstance = MarketContractMPX(tokenInstance.owner());
            marketCollateralPool = getCollateralPool(marketInstance);

            tokenInstance.approve(address(marketInstance), tokensToRedeem[i]);

            if (uint8(tokenInstance.MARKET_SIDE()) == 0) {
                marketCollateralPool.settleAndClose(
                    address(marketInstance),
                    tokensToRedeem[i],
                    0
                );
            } else {
                marketCollateralPool.settleAndClose(
                    address(marketInstance),
                    0,
                    tokensToRedeem[i]
                );
            }
        }
        ERC20 collateralToken = ERC20(marketInstance.COLLATERAL_TOKEN_ADDRESS());

        uint dSProxyBalance = collateralToken.balanceOf(address(this));

        collateralToken.transfer(msg.sender, dSProxyBalance);
    }


    function dailySettlement(
        uint lookbackIndexValue,
        uint currentIndexValue,
        bytes32[3] memory marketAndsTokenNames,
        uint newMarketExpiration
    ) public onlyHoneyLemonOracle {

        require(currentIndexValue != 0, 'Current MRI value cant be zero');

        MarketContractMPX expiringMarketContract = getExpiringMarketContract();
        if (address(expiringMarketContract) != address(0x0)) {
            settleMarketContract(lookbackIndexValue, address(expiringMarketContract));
        }

        deployContract(currentIndexValue, marketAndsTokenNames, newMarketExpiration);

        latestMri = currentIndexValue;
    }

    function settleMarketContract(uint mri, address marketContractAddress)
        public
        onlyHoneyLemonOracle
    {

        require(mri != 0, 'The mri loockback value can not be 0');
        require(marketContractAddress != address(0x0), 'Invalid market contract address');

        MarketContractMPX marketContract = MarketContractMPX(marketContractAddress);
        marketContract.oracleCallBack(mri);

        latestMri = mri;

        emit MarketContractSettled(marketContractAddress, mri, marketContracts.length);
    }

    function mintPositionTokens(
        uint qtyToMint,
        address longTokenRecipient,
        address shortTokenRecipient
    ) public onlyMinterBridge onlyIfFreshDailyContract nonReentrant {

        uint collateralNeeded = calculateRequiredCollateral(qtyToMint);

        MarketContractMPX latestMarketContract = getLatestMarketContract();
        MarketCollateralPool marketCollateralPool = getLatestMarketCollateralPool();

        ERC20 longToken = ERC20(latestMarketContract.LONG_POSITION_TOKEN());
        ERC20 shortToken = ERC20(latestMarketContract.SHORT_POSITION_TOKEN());
        ERC20 collateralToken = ERC20(COLLATERAL_TOKEN_ADDRESS);

        collateralToken.transferFrom(
            MINTER_BRIDGE_ADDRESS,
            address(this),
            collateralNeeded
        );

        collateralToken.approve(address(marketCollateralPool), collateralNeeded);

        marketCollateralPool.mintPositionTokens(
            address(latestMarketContract),
            qtyToMint,
            false
        );

        longToken.transfer(getUserAddressOrDSProxy(longTokenRecipient), qtyToMint);
        shortToken.transfer(getUserAddressOrDSProxy(shortTokenRecipient), qtyToMint);

        emit PositionTokensMinted(
            qtyToMint,
            addressToMarketId[address(latestMarketContract)], // MarketID
            latestMarketContract.CONTRACT_NAME(),
            longTokenRecipient,
            getUserAddressOrDSProxy(longTokenRecipient),
            shortTokenRecipient,
            getUserAddressOrDSProxy(shortTokenRecipient),
            address(latestMarketContract),
            address(longToken),
            address(shortToken),
            getTime()
        );
    }


    function deployContract(
        uint currentMRI,
        bytes32[3] memory marketAndsTokenNames,
        uint expiration
    ) internal returns (address) {

        address contractAddress = marketContractFactoryMPX.deployMarketContractMPX(
            marketAndsTokenNames,
            COLLATERAL_TOKEN_ADDRESS,
            generateContractSpecs(currentMRI, expiration),
            'null', //ORACLE_URL
            'null' // ORACLE_STATISTIC
        );

        uint index = marketContracts.push(contractAddress) - 1;
        addressToMarketId[contractAddress] = index;
        MarketContractMPX marketContract = MarketContractMPX(contractAddress);
        marketContract.transferOwnership(owner());
        emit MarketContractDeployed(
            currentMRI,
            marketAndsTokenNames[0],
            expiration,
            index,
            contractAddress,
            marketContract.COLLATERAL_PER_UNIT()
        );
        return (contractAddress);
    }
}