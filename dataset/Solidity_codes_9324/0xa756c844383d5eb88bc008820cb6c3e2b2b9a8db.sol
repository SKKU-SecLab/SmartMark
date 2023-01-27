

pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.16;

interface PurchaseListener {


    function onPurchase(bytes32 productId, address subscriber, uint endTimestamp, uint priceDatacoin, uint feeDatacoin)
        external returns (bool accepted);

}


pragma solidity ^0.5.16;

contract Ownable {

    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "onlyOwner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == pendingOwner, "onlyPendingOwner");
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


pragma solidity ^0.5.16;






contract IMarketplace {

    enum ProductState {
        NotDeployed,                // non-existent or deleted
        Deployed                    // created or redeployed
    }

    enum Currency {
        DATA,                       // "token wei" (10^-18 DATA)
        USD                         // attodollars (10^-18 USD)
    }

    enum WhitelistState{
        None,
        Pending,
        Approved,
        Rejected
    }
    function getSubscription(bytes32 productId, address subscriber) public view returns (bool isValid, uint endTimestamp) {}

    function getPriceInData(uint subscriptionSeconds, uint price, Currency unit) public view returns (uint datacoinAmount) {}
}
contract IMarketplace1 is IMarketplace{

    function getProduct(bytes32 id) public view returns (string memory name, address owner, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds, ProductState state) {}

}
contract IMarketplace2 is IMarketplace{
    function getProduct(bytes32 id) public view returns (string memory name, address owner, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds, ProductState state, bool requiresWhitelist) {}
    function buyFor(bytes32 productId, uint subscriptionSeconds, address recipient) public {}
}
contract Marketplace is Ownable, IMarketplace2 {
    using SafeMath for uint256;

    event ProductCreated(address indexed owner, bytes32 indexed id, string name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds);
    event ProductUpdated(address indexed owner, bytes32 indexed id, string name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds);
    event ProductDeleted(address indexed owner, bytes32 indexed id, string name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds);
    event ProductImported(address indexed owner, bytes32 indexed id, string name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds);
    event ProductRedeployed(address indexed owner, bytes32 indexed id, string name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds);
    event ProductOwnershipOffered(address indexed owner, bytes32 indexed id, address indexed to);
    event ProductOwnershipChanged(address indexed newOwner, bytes32 indexed id, address indexed oldOwner);

    event Subscribed(bytes32 indexed productId, address indexed subscriber, uint endTimestamp);
    event NewSubscription(bytes32 indexed productId, address indexed subscriber, uint endTimestamp);
    event SubscriptionExtended(bytes32 indexed productId, address indexed subscriber, uint endTimestamp);
    event SubscriptionImported(bytes32 indexed productId, address indexed subscriber, uint endTimestamp);
    event SubscriptionTransferred(bytes32 indexed productId, address indexed from, address indexed to, uint secondsTransferred);

    event ExchangeRatesUpdated(uint timestamp, uint dataInUsd);

    event WhitelistRequested(bytes32 indexed productId, address indexed subscriber);
    event WhitelistApproved(bytes32 indexed productId, address indexed subscriber);
    event WhitelistRejected(bytes32 indexed productId, address indexed subscriber);
    event WhitelistEnabled(bytes32 indexed productId);
    event WhitelistDisabled(bytes32 indexed productId);

    event TxFeeChanged(uint256 indexed newTxFee);


    struct Product {
        bytes32 id;
        string name;
        address owner;
        address beneficiary;        // account where revenue is directed to
        uint pricePerSecond;
        Currency priceCurrency;
        uint minimumSubscriptionSeconds;
        ProductState state;
        address newOwnerCandidate;  // Two phase hand-over to minimize the chance that the product ownership is lost to a non-existent address.
        bool requiresWhitelist;
        mapping(address => TimeBasedSubscription) subscriptions;
        mapping(address => WhitelistState) whitelist;
    }

    struct TimeBasedSubscription {
        uint endTimestamp;
    }


    ERC20 public datacoin;

    address public currencyUpdateAgent;
    IMarketplace1 prev_marketplace;
    uint256 public txFee;

    constructor(address datacoinAddress, address currencyUpdateAgentAddress, address prev_marketplace_address) Ownable() public {
        _initialize(datacoinAddress, currencyUpdateAgentAddress, prev_marketplace_address);
    }

    function _initialize(address datacoinAddress, address currencyUpdateAgentAddress, address prev_marketplace_address) internal {
        currencyUpdateAgent = currencyUpdateAgentAddress;
        datacoin = ERC20(datacoinAddress);
        prev_marketplace = IMarketplace1(prev_marketplace_address);
    }


    mapping (bytes32 => Product) public products;
    function getProduct(bytes32 id) public view returns (string memory name, address owner, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds, ProductState state, bool requiresWhitelist) {
        (name, owner, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds, state, requiresWhitelist) = _getProductLocal(id);
        if (owner != address(0))
            return (name, owner, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds, state, requiresWhitelist);
        (name, owner, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds, state) = prev_marketplace.getProduct(id);
        return (name, owner, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds, state, false);
    }


    function _getProductLocal(bytes32 id) internal view returns (string memory name, address owner, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds, ProductState state, bool requiresWhitelist) {
        Product memory p = products[id];
        return (
            p.name,
            p.owner,
            p.beneficiary,
            p.pricePerSecond,
            p.priceCurrency,
            p.minimumSubscriptionSeconds,
            p.state,
            p.requiresWhitelist
        );
    }

    modifier onlyProductOwner(bytes32 productId) {
        (,address _owner,,,,,,) = getProduct(productId);
        require(_owner != address(0), "error_notFound");
        require(_owner == msg.sender || owner == msg.sender, "error_productOwnersOnly");
        _;
    }

    function _importProductIfNeeded(bytes32 productId) internal returns (bool imported){
        Product storage p = products[productId];
        if(p.id != 0x0)
            return false;
        (string memory _name, address _owner, address _beneficiary, uint _pricePerSecond, IMarketplace1.Currency _priceCurrency, uint _minimumSubscriptionSeconds, IMarketplace1.ProductState _state) = prev_marketplace.getProduct(productId);
        if(_owner == address(0))
            return false;
        p.id = productId;
        p.name = _name;
        p.owner = _owner;
        p.beneficiary = _beneficiary;
        p.pricePerSecond = _pricePerSecond;
        p.priceCurrency = _priceCurrency;
        p.minimumSubscriptionSeconds = _minimumSubscriptionSeconds;
        p.state = _state;
        emit ProductImported(p.owner, p.id, p.name, p.beneficiary, p.pricePerSecond, p.priceCurrency, p.minimumSubscriptionSeconds);
        return true;
    }

    function _importSubscriptionIfNeeded(bytes32 productId, address subscriber) internal returns (bool imported) {
        bool _productImported = _importProductIfNeeded(productId);

        (Product storage product, TimeBasedSubscription storage sub) = _getSubscriptionLocal(productId, subscriber);
        if (sub.endTimestamp != 0x0) { return false; }

        if(!_productImported){
            (,address _owner_prev,,,,,) = prev_marketplace.getProduct(productId);
            if (_owner_prev == address(0)) { return false; }
        }
        (, uint _endTimestamp) = prev_marketplace.getSubscription(productId, subscriber);
        if (_endTimestamp == 0x0) { return false; }
        product.subscriptions[subscriber] = TimeBasedSubscription(_endTimestamp);
        emit SubscriptionImported(productId, subscriber, _endTimestamp);
        return true;
    }
    function createProduct(bytes32 id, string memory name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds) public whenNotHalted {
        _createProduct(id, name, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds, false);
    }

    function createProductWithWhitelist(bytes32 id, string memory name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds) public whenNotHalted {
        _createProduct(id, name, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds, true);
        emit WhitelistEnabled(id);
    }


    function _createProduct(bytes32 id, string memory name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds, bool requiresWhitelist) internal {
        require(id != 0x0, "error_nullProductId");
        require(pricePerSecond > 0, "error_freeProductsNotSupported");
        (,address _owner,,,,,,) = getProduct(id);
        require(_owner == address(0), "error_alreadyExists");
        products[id] = Product({id: id, name: name, owner: msg.sender, beneficiary: beneficiary, pricePerSecond: pricePerSecond,
            priceCurrency: currency, minimumSubscriptionSeconds: minimumSubscriptionSeconds, state: ProductState.Deployed, newOwnerCandidate: address(0), requiresWhitelist: requiresWhitelist});
        emit ProductCreated(msg.sender, id, name, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds);
    }

    function deleteProduct(bytes32 productId) public onlyProductOwner(productId) {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(p.state == ProductState.Deployed, "error_notDeployed");
        p.state = ProductState.NotDeployed;
        emit ProductDeleted(p.owner, productId, p.name, p.beneficiary, p.pricePerSecond, p.priceCurrency, p.minimumSubscriptionSeconds);
    }

    function redeployProduct(bytes32 productId) public onlyProductOwner(productId) {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(p.state == ProductState.NotDeployed, "error_mustBeNotDeployed");
        p.state = ProductState.Deployed;
        emit ProductRedeployed(p.owner, productId, p.name, p.beneficiary, p.pricePerSecond, p.priceCurrency, p.minimumSubscriptionSeconds);
    }

    function updateProduct(bytes32 productId, string memory name, address beneficiary, uint pricePerSecond, Currency currency, uint minimumSubscriptionSeconds, bool redeploy) public onlyProductOwner(productId) {
        require(pricePerSecond > 0, "error_freeProductsNotSupported");
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        p.name = name;
        p.beneficiary = beneficiary;
        p.pricePerSecond = pricePerSecond;
        p.priceCurrency = currency;
        p.minimumSubscriptionSeconds = minimumSubscriptionSeconds;
        emit ProductUpdated(p.owner, p.id, name, beneficiary, pricePerSecond, currency, minimumSubscriptionSeconds);
        if(redeploy)
            redeployProduct(productId);
    }

    function offerProductOwnership(bytes32 productId, address newOwnerCandidate) public onlyProductOwner(productId) {
        _importProductIfNeeded(productId);
        products[productId].newOwnerCandidate = newOwnerCandidate;
        emit ProductOwnershipOffered(products[productId].owner, productId, newOwnerCandidate);
    }

    function claimProductOwnership(bytes32 productId) public whenNotHalted {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(msg.sender == p.newOwnerCandidate, "error_notPermitted");
        emit ProductOwnershipChanged(msg.sender, productId, p.owner);
        p.owner = msg.sender;
        p.newOwnerCandidate = address(0);
    }


    function setRequiresWhitelist(bytes32 productId, bool _requiresWhitelist) public onlyProductOwner(productId) {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(p.id != 0x0, "error_notFound");
        p.requiresWhitelist = _requiresWhitelist;
        if(_requiresWhitelist)
            emit WhitelistEnabled(productId);
        else
            emit WhitelistDisabled(productId);
    }

    function whitelistApprove(bytes32 productId, address subscriber) public onlyProductOwner(productId) {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(p.id != 0x0, "error_notFound");
        require(p.requiresWhitelist, "error_whitelistNotEnabled");
        p.whitelist[subscriber] = WhitelistState.Approved;
        emit WhitelistApproved(productId, subscriber);
    }

    function whitelistReject(bytes32 productId, address subscriber) public onlyProductOwner(productId) {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(p.id != 0x0, "error_notFound");
        require(p.requiresWhitelist, "error_whitelistNotEnabled");
        p.whitelist[subscriber] = WhitelistState.Rejected;
        emit WhitelistRejected(productId, subscriber);
    }

    function whitelistRequest(bytes32 productId) public {
        _importProductIfNeeded(productId);
        Product storage p = products[productId];
        require(p.id != 0x0, "error_notFound");
        require(p.requiresWhitelist, "error_whitelistNotEnabled");
        require(p.whitelist[msg.sender] == WhitelistState.None, "error_whitelistRequestAlreadySubmitted");
        p.whitelist[msg.sender] = WhitelistState.Pending;
        emit WhitelistRequested(productId, msg.sender);
    }

    function getWhitelistState(bytes32 productId, address subscriber) public view returns (WhitelistState wlstate) {
        (, address _owner,,,,,,) = getProduct(productId);
        require(_owner != address(0), "error_notFound");
        Product storage p = products[productId];
        return p.whitelist[subscriber];
    }


    function getSubscription(bytes32 productId, address subscriber) public view returns (bool isValid, uint endTimestamp) {
        (,address _owner,,,,,,) = _getProductLocal(productId);
        if (_owner == address(0)) {
            return prev_marketplace.getSubscription(productId,subscriber);
        }

        (, TimeBasedSubscription storage sub) = _getSubscriptionLocal(productId, subscriber);
        if (sub.endTimestamp == 0x0) {
            (,address _owner_prev,,,,,) = prev_marketplace.getProduct(productId);
            if (_owner_prev != address(0)) {
                return prev_marketplace.getSubscription(productId,subscriber);
            }
        }
        return (_isValid(sub), sub.endTimestamp);
    }

    function getSubscriptionTo(bytes32 productId) public view returns (bool isValid, uint endTimestamp) {
        return getSubscription(productId, msg.sender);
    }

    function hasValidSubscription(bytes32 productId, address subscriber) public view returns (bool isValid) {
        (isValid,) = getSubscription(productId, subscriber);
    }

    function _subscribe(bytes32 productId, uint addSeconds, address subscriber, bool requirePayment) internal {
        _importSubscriptionIfNeeded(productId, subscriber);
        (Product storage p, TimeBasedSubscription storage oldSub) = _getSubscriptionLocal(productId, subscriber);
        require(p.state == ProductState.Deployed, "error_notDeployed");
        require(!p.requiresWhitelist || p.whitelist[subscriber] == WhitelistState.Approved, "error_whitelistNotAllowed");
        uint endTimestamp;

        if (oldSub.endTimestamp > block.timestamp) {
            require(addSeconds > 0, "error_topUpTooSmall");
            endTimestamp = oldSub.endTimestamp.add(addSeconds);
            oldSub.endTimestamp = endTimestamp;
            emit SubscriptionExtended(p.id, subscriber, endTimestamp);
        } else {
            require(addSeconds >= p.minimumSubscriptionSeconds, "error_newSubscriptionTooSmall");
            endTimestamp = block.timestamp.add(addSeconds);
            TimeBasedSubscription memory newSub = TimeBasedSubscription(endTimestamp);
            p.subscriptions[subscriber] = newSub;
            emit NewSubscription(p.id, subscriber, endTimestamp);
        }
        emit Subscribed(p.id, subscriber, endTimestamp);

        uint256 price = 0;
        uint256 fee = 0;
        address recipient = p.beneficiary;
        if (requirePayment) {
            price = getPriceInData(addSeconds, p.pricePerSecond, p.priceCurrency);
            fee = txFee.mul(price).div(1 ether);
            require(datacoin.transferFrom(msg.sender, recipient, price.sub(fee)), "error_paymentFailed");
            if (fee > 0) {
                require(datacoin.transferFrom(msg.sender, owner, fee), "error_paymentFailed");
            }
        }

        uint256 codeSize;
        assembly { codeSize := extcodesize(recipient) }  // solium-disable-line security/no-inline-assembly
        if (codeSize > 0) {
            (bool success, bytes memory returnData) = recipient.call(
                abi.encodeWithSignature("onPurchase(bytes32,address,uint256,uint256,uint256)",
                productId, subscriber, oldSub.endTimestamp, price, fee)
            );

            if (success) {
                (bool accepted) = abi.decode(returnData, (bool));
                require(accepted, "error_rejectedBySeller");
            }
        }
    }

    function grantSubscription(bytes32 productId, uint subscriptionSeconds, address recipient) public whenNotHalted onlyProductOwner(productId){
        return _subscribe(productId, subscriptionSeconds, recipient, false);
    }


    function buyFor(bytes32 productId, uint subscriptionSeconds, address recipient) public whenNotHalted {
        return _subscribe(productId, subscriptionSeconds, recipient, true);
    }


    function buy(bytes32 productId, uint subscriptionSeconds) public whenNotHalted {
        buyFor(productId,subscriptionSeconds, msg.sender);
    }


    function _getSubscriptionLocal(bytes32 productId, address subscriber) internal view returns (Product storage p, TimeBasedSubscription storage s) {
        p = products[productId];
        require(p.id != 0x0, "error_notFound");
        s = p.subscriptions[subscriber];
    }

    function _isValid(TimeBasedSubscription storage s) internal view returns (bool) {
        return s.endTimestamp >= block.timestamp;   // solium-disable-line security/no-block-members
    }



    uint public dataPerUsd = 100000000000000000;   // ~= 0.1 DATA/USD

    function updateExchangeRates(uint timestamp, uint dataUsd) public {
        require(msg.sender == currencyUpdateAgent, "error_notPermitted");
        require(dataUsd > 0, "error_invalidRate");
        dataPerUsd = dataUsd;
        emit ExchangeRatesUpdated(timestamp, dataUsd);
    }

    function getPriceInData(uint subscriptionSeconds, uint price, Currency unit) public view returns (uint datacoinAmount) {
        if (unit == Currency.DATA) {
            return price.mul(subscriptionSeconds);
        }
        return price.mul(dataPerUsd).div(10**18).mul(subscriptionSeconds);
    }


    event Halted();
    event Resumed();
    bool public halted = false;

    modifier whenNotHalted() {
        require(!halted || owner == msg.sender, "error_halted");
        _;
    }
    function halt() public onlyOwner {
        halted = true;
        emit Halted();
    }
    function resume() public onlyOwner {
        halted = false;
        emit Resumed();
    }

    function reInitialize(address datacoinAddress, address currencyUpdateAgentAddress, address prev_marketplace_address) public onlyOwner {
        _initialize(datacoinAddress, currencyUpdateAgentAddress, prev_marketplace_address);
    }

    function setTxFee(uint256 newTxFee) public onlyOwner {
        require(newTxFee <= 1 ether, "error_invalidTxFee");
        txFee = newTxFee;
        emit TxFeeChanged(txFee);
    }
}