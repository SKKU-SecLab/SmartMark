
pragma solidity 0.5.4;


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



pragma solidity 0.5.4;

contract StaticCaller {


    function staticCall(address target, bytes memory data)
        internal
        view
        returns (bool result)
    {

        assembly {
            result := staticcall(gas, target, add(data, 0x20), mload(data), mload(0x40), 0)
        }
        return result;
    }

    function staticCallUint(address target, bytes memory data)
        internal
        view
        returns (uint ret)
    {

        bool result;
        assembly {
            let size := 0x20
            let free := mload(0x40)
            result := staticcall(gas, target, add(data, 0x20), mload(data), free, size)
            ret := mload(free)
        }
        require(result, "Static call failed");
        return ret;
    }

}



pragma solidity 0.5.4;

contract ReentrancyGuarded {


    bool reentrancyLock = false;

    modifier reentrancyGuard {

        require(!reentrancyLock, "Reentrancy detected");
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}



pragma solidity 0.5.4;

contract EIP712 {


    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 DOMAIN_SEPARATOR;

    function hash(EIP712Domain memory eip712Domain)
        internal
        pure
        returns (bytes32)
    {

        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract
        ));
    }

}


contract Proxy {


    function implementation() public view returns (address);


    function proxyType() public pure returns (uint256 proxyTypeId);


    function () payable external {
        address _impl = implementation();
        require(_impl != address(0), "Proxy implementation required");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}


contract OwnedUpgradeabilityStorage {


    address internal _implementation;

    address private _upgradeabilityOwner;

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }

    function implementation() public view returns (address) {

        return _implementation;
    }

    function proxyType() public pure returns (uint256 proxyTypeId) {

        return 2;
    }

}


contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    event Upgraded(address indexed implementation);

    function _upgradeTo(address implementation) internal {

        require(_implementation != implementation, "Proxy already uses this implementation");
        _implementation = implementation;
        emit Upgraded(implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner(), "Only the proxy owner can call this method");
        _;
    }

    function proxyOwner() public view returns (address) {

        return upgradeabilityOwner();
    }

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {

        require(newOwner != address(0), "New owner cannot be the null address");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    function upgradeTo(address implementation) public onlyProxyOwner {

        _upgradeTo(implementation);
    }

    function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {

        upgradeTo(implementation);
        (bool success,) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}



pragma solidity 0.5.4;


contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {


    constructor(address owner, address initialImplementation, bytes memory data)
        public
    {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success,) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }

}



pragma solidity 0.5.4;


interface ProxyRegistryInterface {


    function delegateProxyImplementation() external returns (address);


    function proxies(address owner) external returns (OwnableDelegateProxy);


}



pragma solidity 0.5.4;




contract ProxyRegistry is Ownable, ProxyRegistryInterface {


    address public delegateProxyImplementation;

    mapping(address => OwnableDelegateProxy) public proxies;

    mapping(address => uint) public pending;

    mapping(address => bool) public contracts;

    uint public DELAY_PERIOD = 2 weeks;

    function startGrantAuthentication (address addr)
        public
        onlyOwner
    {
        require(!contracts[addr] && pending[addr] == 0, "Contract is already allowed in registry, or pending");
        pending[addr] = now;
    }

    function endGrantAuthentication (address addr)
        public
        onlyOwner
    {
        require(!contracts[addr] && pending[addr] != 0 && ((pending[addr] + DELAY_PERIOD) < now), "Contract is no longer pending or has already been approved by registry");
        pending[addr] = 0;
        contracts[addr] = true;
    }

    function revokeAuthentication (address addr)
        public
        onlyOwner
    {
        contracts[addr] = false;
    }

    function registerProxy()
        public
        returns (OwnableDelegateProxy proxy)
    {

        return registerProxyFor(msg.sender);
    }

    function registerProxyOverride()
        public
        returns (OwnableDelegateProxy proxy)
    {

        proxy = new OwnableDelegateProxy(msg.sender, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", msg.sender, address(this)));
        proxies[msg.sender] = proxy;
        return proxy;
    }

    function registerProxyFor(address user)
        public
        returns (OwnableDelegateProxy proxy)
    {

        require(proxies[user] == OwnableDelegateProxy(0), "User already has a proxy");
        proxy = new OwnableDelegateProxy(user, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", user, address(this)));
        proxies[user] = proxy;
        return proxy;
    }

    function transferAccessTo(address from, address to)
        public
    {

        OwnableDelegateProxy proxy = proxies[from];

        require(OwnableDelegateProxy(msg.sender) == proxy, "Proxy transfer can only be called by the proxy");
        require(proxies[to] == OwnableDelegateProxy(0), "Proxy transfer has existing proxy as destination");

        delete proxies[from];
        proxies[to] = proxy;
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

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}



pragma solidity 0.5.4;


contract TokenRecipient {

    event ReceivedEther(address indexed sender, uint amount);
    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);

    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {

        ERC20 t = ERC20(token);
        require(t.transferFrom(from, address(this), value), "ERC20 token transfer failed");
        emit ReceivedTokens(from, value, token, extraData);
    }

    function () payable external {
        emit ReceivedEther(msg.sender, msg.value);
    }
}



pragma solidity 0.5.4;




contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {


    bool initialized = false;

    address public user;

    ProxyRegistry public registry;

    bool public revoked;

    enum HowToCall { Call, DelegateCall }

    event Revoked(bool revoked);

    function initialize (address addrUser, ProxyRegistry addrRegistry)
        public
    {
        require(!initialized, "Authenticated proxy already initialized");
        initialized = true;
        user = addrUser;
        registry = addrRegistry;
    }

    function setRevoke(bool revoke)
        public
    {

        require(msg.sender == user, "Authenticated proxy can only be revoked by its user");
        revoked = revoke;
        emit Revoked(revoke);
    }

    function proxy(address dest, HowToCall howToCall, bytes memory data)
        public
        returns (bool result)
    {

        require(msg.sender == user || (!revoked && registry.contracts(msg.sender)), "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access");
        bytes memory ret;
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
        return result;
    }

    function proxyAssert(address dest, HowToCall howToCall, bytes memory data)
        public
    {

        require(proxy(dest, howToCall, data), "Proxy assertion failed");
    }

}



pragma solidity 0.5.4;







contract ExchangeCore is ReentrancyGuarded, StaticCaller, EIP712 {



    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Order {
        address maker;
        address staticTarget;
        bytes4 staticSelector;
        bytes staticExtradata;
        uint maximumFill;
        uint listingTime;
        uint expirationTime;
        uint salt;
    }

    struct Call {
        address target;
        AuthenticatedProxy.HowToCall howToCall;
        bytes data;
    }


    bytes32 constant ORDER_TYPEHASH = keccak256(
        "Order(address maker,address staticTarget,bytes4 staticSelector,bytes staticExtradata,uint256 maximumFill,uint256 listingTime,uint256 expirationTime,uint256 salt)"
    );


    ProxyRegistryInterface public registry;

    mapping(address => mapping(bytes32 => uint)) public fills;

    mapping(address => mapping(bytes32 => bool)) public approved;


    event OrderApproved     (bytes32 indexed hash, address indexed maker, address staticTarget, bytes4 staticSelector, bytes staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired);
    event OrderFillChanged  (bytes32 indexed hash, address indexed maker, uint newFill);
    event OrdersMatched     (bytes32 firstHash, bytes32 secondHash, address indexed firstMaker, address indexed secondMaker, uint newFirstFill, uint newSecondFill, bytes32 indexed metadata);


    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 hash)
    {

        return keccak256(abi.encode(
            ORDER_TYPEHASH,
            order.maker,
            order.staticTarget,
            order.staticSelector,
            keccak256(order.staticExtradata),
            order.maximumFill,
            order.listingTime,
            order.expirationTime,
            order.salt
        ));
    }

    function hashToSign(bytes32 orderHash)
        internal
        view
        returns (bytes32 hash)
    {

        return keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            orderHash
        ));
    }

    function exists(address what)
        internal
        view
        returns (bool)
    {

        uint size;
        assembly {
            size := extcodesize(what)
        }
        return size > 0;
    }

    function validateOrderParameters(Order memory order, bytes32 hash)
        internal
        view
        returns (bool)
    {

        if (order.listingTime > block.timestamp || order.expirationTime <= block.timestamp) {
            return false;
        }

        if (fills[order.maker][hash] >= order.maximumFill) {
            return false;
        }

        if (!exists(order.staticTarget)) {
            return false;
        }

        return true;
    }

    function validateOrderAuthorization(bytes32 hash, address maker, Sig memory sig)
        internal
        view
        returns (bool)
    {

        if (fills[maker][hash] > 0) {
            return true;
        }


        if (maker == msg.sender) {
            return true;
        }

        if (approved[maker][hash]) {
            return true;
        }
    
        if (ecrecover(hashToSign(hash), sig.v, sig.r, sig.s) == maker) {
            return true;
        }

        return false;
    }

    function encodeStaticCall(Order memory order, Call memory call, Order memory counterorder, Call memory countercall, address matcher, uint value, uint fill)
        internal
        pure
        returns (bytes memory)
    {

        address[5] memory addresses = [order.maker, call.target, counterorder.maker, countercall.target, matcher];
        AuthenticatedProxy.HowToCall[2] memory howToCalls = [call.howToCall, countercall.howToCall];
        uint[6] memory uints = [value, order.maximumFill, order.listingTime, order.expirationTime, counterorder.listingTime, fill];
        return abi.encodeWithSelector(order.staticSelector, order.staticExtradata, addresses, howToCalls, uints, call.data, countercall.data);
    }

    function executeStaticCall(Order memory order, Call memory call, Order memory counterorder, Call memory countercall, address matcher, uint value, uint fill)
        internal
        view
        returns (uint)
    {

        return staticCallUint(order.staticTarget, encodeStaticCall(order, call, counterorder, countercall, matcher, value, fill));
    }

    function executeCall(address maker, Call memory call)
        internal
        returns (bool)
    {

        require(exists(call.target), "Call target does not exist");

        OwnableDelegateProxy delegateProxy = registry.proxies(maker);

        require(delegateProxy != OwnableDelegateProxy(0), "Delegate proxy does not exist for maker");

        require(delegateProxy.implementation() == registry.delegateProxyImplementation(), "Incorrect delegate proxy implementation for maker");
      
        AuthenticatedProxy proxy = AuthenticatedProxy(address(delegateProxy));
  
        return proxy.proxy(call.target, call.howToCall, call.data);
    }

    function approveOrderHash(bytes32 hash)
        internal
    {


        require(!approved[msg.sender][hash], "Order has already been approved");


        approved[msg.sender][hash] = true;
    }

    function approveOrder(Order memory order, bool orderbookInclusionDesired)
        internal
    {


        require(order.maker == msg.sender, "Sender is not the maker of the order and thus not authorized to approve it");

        bytes32 hash = hashOrder(order);

        approveOrderHash(hash);

        emit OrderApproved(hash, order.maker, order.staticTarget, order.staticSelector, order.staticExtradata, order.maximumFill, order.listingTime, order.expirationTime, order.salt, orderbookInclusionDesired);
    }

    function setOrderFill(bytes32 hash, uint fill)
        internal
    {


        require(fills[msg.sender][hash] != fill, "Fill is already set to the desired value");


        fills[msg.sender][hash] = fill;

        emit OrderFillChanged(hash, msg.sender, fill);
    }

    function atomicMatch(Order memory firstOrder, Sig memory firstSig, Call memory firstCall, Order memory secondOrder, Sig memory secondSig, Call memory secondCall, bytes32 metadata)
        internal
        reentrancyGuard
    {


        bytes32 firstHash = hashOrder(firstOrder);

        require(validateOrderParameters(firstOrder, firstHash), "First order has invalid parameters");

        require(validateOrderAuthorization(firstHash, firstOrder.maker, firstSig), "First order failed authorization");

        bytes32 secondHash = hashOrder(secondOrder);

        require(validateOrderParameters(secondOrder, secondHash), "Second order has invalid parameters");

        require(validateOrderAuthorization(secondHash, secondOrder.maker, secondSig), "Second order failed authorization");

        require(firstHash != secondHash, "Self-matching orders is prohibited");


        if (msg.value > 0) {
            address(uint160(firstOrder.maker)).transfer(msg.value);
        }

        assert(executeCall(firstOrder.maker, firstCall));

        assert(executeCall(secondOrder.maker, secondCall));


        uint previousFirstFill = fills[firstOrder.maker][firstHash];

        uint previousSecondFill = fills[secondOrder.maker][secondHash];

        uint firstFill = executeStaticCall(firstOrder, firstCall, secondOrder, secondCall, msg.sender, msg.value, previousFirstFill);

        uint secondFill = executeStaticCall(secondOrder, secondCall, firstOrder, firstCall, msg.sender, uint(0), previousSecondFill);


        if (firstOrder.maker != msg.sender) {
            if (firstFill != previousFirstFill) {
                fills[firstOrder.maker][firstHash] = firstFill;
            }
        }

        if (secondOrder.maker != msg.sender) {
            if (secondFill != previousSecondFill) {
                fills[secondOrder.maker][secondHash] = secondFill;
            }
        }


        emit OrdersMatched(firstHash, secondHash, firstOrder.maker, secondOrder.maker, firstFill, secondFill, metadata);
    }

}



pragma solidity 0.5.4;


contract Exchange is ExchangeCore {



    function hashOrder_(address maker, address staticTarget, bytes4 staticSelector, bytes memory staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt)
        public
        pure
        returns (bytes32 hash)
    {

        return hashOrder(Order(maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt));
    }

    function hashToSign_(bytes32 orderHash)
        external
        view
        returns (bytes32 hash)
    {

        return hashToSign(orderHash);
    }

    function validateOrderParameters_(address maker, address staticTarget, bytes4 staticSelector, bytes memory staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt)
        public
        view
        returns (bool)
    {

        Order memory order = Order(maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt);
        return validateOrderParameters(order, hashOrder(order));
    }

    function validateOrderAuthorization_(bytes32 hash, address maker, uint8 v, bytes32 r, bytes32 s)
        external
        view
        returns (bool)
    {

        return validateOrderAuthorization(hash, maker, Sig(v, r, s));
    }

    function approveOrderHash_(bytes32 hash)
        external
    {

        return approveOrderHash(hash);
    }

    function approveOrder_(address maker, address staticTarget, bytes4 staticSelector, bytes memory staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired)
        public
    {

        return approveOrder(Order(maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt), orderbookInclusionDesired);
    }

    function setOrderFill_(bytes32 hash, uint fill)
        external
    {

        return setOrderFill(hash, fill);
    }

    function atomicMatch_(uint[14] memory uints, bytes4[2] memory staticSelectors,
        bytes memory firstExtradata, bytes memory firstCalldata, bytes memory secondExtradata, bytes memory secondCalldata,
        uint8[4] memory howToCallsVs, bytes32[5] memory rssMetadata)
        public
        payable
    {

        return atomicMatch(
            Order(address(uints[0]), address(uints[1]), staticSelectors[0], firstExtradata, uints[2], uints[3], uints[4], uints[5]),
            Sig(howToCallsVs[0], rssMetadata[0], rssMetadata[1]),
            Call(address(uints[6]), AuthenticatedProxy.HowToCall(howToCallsVs[1]), firstCalldata),
            Order(address(uints[7]), address(uints[8]), staticSelectors[1], secondExtradata, uints[9], uints[10], uints[11], uints[12]),
            Sig(howToCallsVs[2], rssMetadata[2], rssMetadata[3]),
            Call(address(uints[13]), AuthenticatedProxy.HowToCall(howToCallsVs[3]), secondCalldata),
            rssMetadata[4]
        );
    }

}



pragma solidity 0.5.4;


contract WyvernExchange is Exchange {


    string public constant name = "Wyvern Exchange";
  
    string public constant version = "3.0";

    string public constant codename = "Ancalagon";

    constructor (uint chainId, ProxyRegistryInterface registryAddr) public {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "Wyvern Exchange",
            version: "3",
            chainId: chainId,
            verifyingContract: address(this)
        }));
        registry = registryAddr;
    }

}