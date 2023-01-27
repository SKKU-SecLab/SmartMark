


pragma solidity ^0.8.3;

contract StaticCaller {


    function staticCall(address target, bytes memory data) internal view returns (bool result)
    {

        assembly {
            result := staticcall(gas(), target, add(data, 0x20), mload(data), mload(0x40), 0)
        }
        return result;
    }

    function staticCallUint(address target, bytes memory data) internal view returns (uint ret)
    {

        bool result;
        assembly {
            let size := 0x20
            let free := mload(0x40)
            result := staticcall(gas(), target, add(data, 0x20), mload(data), free, size)
            ret := mload(free)
        }
        require(result, "Static call failed");
        return ret;
    }

}



pragma solidity ^0.8.3;

abstract contract ERC1271 {

  bytes4 constant internal MAGICVALUE = 0x20c13b0b;

  function isValidSignature(
      bytes memory _data,
      bytes memory _signature)
      virtual
      public
      view
      returns (bytes4 magicValue);
}



pragma solidity ^0.8.3;

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



pragma solidity ^0.8.3;

contract ReentrancyGuarded {


    bool reentrancyLock = false;
    modifier reentrancyGuard {

        if (reentrancyLock) {
            revert();
        }
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.3;


contract TokenRecipient{

    event ReceivedEther(address indexed sender, uint amount);
    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);

    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {

        IERC20 t = IERC20(token);
        require(t.transferFrom(from, address(this), value), "ERC20 token transfer failed");
        emit ReceivedTokens(from, value, token, extraData);
    }
   
    fallback () payable external {
        emit ReceivedEther(msg.sender, msg.value);
    }
    receive () payable external {
        emit ReceivedEther(msg.sender, msg.value);
    }
}


pragma solidity ^0.8.3;

contract OwnedUpgradeabilityStorage {


    address internal _implementation;
    address private _upgradeabilityOwner;
    
    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}



pragma solidity ^0.8.3;


abstract contract Proxy {
  
    function implementation() virtual public view returns (address);
    function proxyType() virtual public pure returns (uint256 proxyTypeId);
    
    function _fallback() private{
        
        address _impl = implementation();
        require(_impl != address(0), "Proxy implementation required");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
    
    
    fallback () payable external{
      _fallback();
    }
    
    receive() payable external{
        _fallback();
    }
    
}



pragma solidity ^0.8.3;



contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);
    event Upgraded(address indexed implementation);
    
    function implementation() override public view returns (address) {

        return _implementation;
    }
   
    function proxyType() override public pure returns (uint256 proxyTypeId) {

        return 2;
    }
    
    function _upgradeTo(address implem) internal {

        require(_implementation != implem, "Proxy already uses this implementation");
        _implementation = implem;
        emit Upgraded(implem);
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
   
   
    function upgradeTo(address implem) public onlyProxyOwner {

        _upgradeTo(implem);
    }
   
    function upgradeToAndCall(address implem, bytes memory data) payable public onlyProxyOwner {

        upgradeTo(implem);
        (bool success,) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}



pragma solidity ^0.8.3;


contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {



    constructor(address owner, address initialImplementation, bytes memory data)  {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success,) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }
    

}


pragma solidity ^0.8.3;


interface ProxyRegistryInterface {

    function delegateProxyImplementation() external returns (address);

    function proxies(address owner) external returns (OwnableDelegateProxy);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



pragma solidity ^0.8.3;




contract ProxyRegistry is Ownable, ProxyRegistryInterface {

    
    address public override delegateProxyImplementation;
    mapping(address => OwnableDelegateProxy) public override proxies;
    mapping(address => uint) public pending;
    mapping(address => bool) public contracts;
    uint public DELAY_PERIOD = 2 weeks;

    function startGrantAuthentication (address addr) public onlyOwner{
        require(!contracts[addr] && pending[addr] == 0, "Contract is already allowed in registry, or pending");
        pending[addr] = block.timestamp;
    }

    function endGrantAuthentication (address addr) public onlyOwner{
        require(!contracts[addr] && pending[addr] != 0 && ((pending[addr] + DELAY_PERIOD) < block.timestamp), "Contract is no longer pending or has already been approved by registry");
        pending[addr] = 0;
        contracts[addr] = true;
    }

    function revokeAuthentication (address addr) public onlyOwner{
        contracts[addr] = false;
    }
    
     function grantAuthentication (address addr) public onlyOwner{
        contracts[addr] = true;
    }
   
    function registerProxyOverride() public returns (OwnableDelegateProxy proxy){

        proxy = new OwnableDelegateProxy(msg.sender, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", msg.sender, address(this)));
        proxies[msg.sender] = proxy;
        return proxy;
    }
    
    function registerProxyFor(address user) public returns (OwnableDelegateProxy proxy){

        require(address(proxies[user]) == address(0), "User already has a proxy");
        proxy = new OwnableDelegateProxy(user, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", user, address(this)));
        proxies[user] = proxy;
        return proxy;
    }
    
     function registerProxy() public returns (OwnableDelegateProxy proxy){

        return registerProxyFor(msg.sender);
    }

    function transferAccessTo(address from, address to) public{

        OwnableDelegateProxy proxy = proxies[from];
        require(msg.sender == from, "Proxy transfer can only be called by the proxy");
        require(address(proxies[to]) == address(0), "Proxy transfer has existing proxy as destination");
        delete proxies[from];
        proxies[to] = proxy;
    }

}


pragma solidity ^0.8.3;




contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {


    bool initialized = false;
    address public user;
    ProxyRegistry public registry;
    bool public revoked;
    enum HowToCall { Call, DelegateCall }
    event Revoked(bool revoked);
    function initialize (address addrUser, ProxyRegistry addrRegistry) public {
        require(!initialized, "Authenticated proxy already initialized");
        initialized = true;
        user = addrUser;
        registry = addrRegistry;
    }
    function setRevoke(bool revoke) public{

        require(msg.sender == user, "Authenticated proxy can only be revoked by its user");
        revoked = revoke;
        emit Revoked(revoke);
    }
    function proxy(address dest, HowToCall howToCall, bytes memory data) public  returns (bool result){

        require(msg.sender == user || (!revoked && registry.contracts(msg.sender)), "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access");
        bytes memory ret;
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
        return result;
    }
    function proxyAssert(address dest, HowToCall howToCall, bytes memory data) public{

        require(proxy(dest, howToCall, data), "Proxy assertion failed");
    }

}



pragma solidity ^0.8.3;









contract ExchangeCore is ReentrancyGuarded, StaticCaller,EIP712 {

    bytes4 constant internal EIP_1271_MAGICVALUE = 0x20c13b0b;
   
     struct Order {
        address registry;
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
        "Order(address registry,address maker,address staticTarget,bytes4 staticSelector,bytes staticExtradata,uint256 maximumFill,uint256 listingTime,uint256 expirationTime,uint256 salt)"
    );

    mapping(address => bool) public registries;
    mapping(address => mapping(bytes32 => uint)) public fills;
    mapping(address => mapping(bytes32 => bool)) public approved;

    event OrderApproved     (bytes32 indexed hash, address registry, address indexed maker, address staticTarget, bytes4 staticSelector, bytes staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired);
    event OrderFillChanged  (bytes32 indexed hash, address indexed maker, uint newFill);
    event OrdersMatched     (bytes32 firstHash, bytes32 secondHash, address indexed firstMaker, address indexed secondMaker, uint newFirstFill, uint newSecondFill, bytes32 indexed metadata);

    
    function hashOrder(Order memory order) internal pure returns (bytes32 hash){

        return keccak256(abi.encode(
            ORDER_TYPEHASH,
            order.registry,
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

    function hashToSign(bytes32 orderHash) internal view returns (bytes32 hash){

        return keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            orderHash
        ));
    }
   
    function exists(address what) internal view returns (bool){

        uint size;
        assembly {
            size := extcodesize(what)
        }
        return size > 0;
    }
    
    function validateOrderParameters(Order memory order, bytes32 hash) internal view returns (bool)
    {

        if (order.listingTime > block.timestamp || (order.expirationTime != 0 && order.expirationTime <= block.timestamp)) {
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
    
     function validateOrderAuthorization(bytes32 hash, address maker, bytes memory signature) internal view returns (bool){

        if (fills[maker][hash] > 0) {
            return true;
        }
        if (maker == msg.sender) {
            return true;
        }
        if (approved[maker][hash]) {
            return true;
        }

        bytes32 calculatedHashToSign = hashToSign(hash);
        bool isContract = exists(maker);

        if (isContract) {
            if (ERC1271(maker).isValidSignature(abi.encodePacked(calculatedHashToSign), signature) == EIP_1271_MAGICVALUE) {
                return true;
            }
            return false;
        }
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(signature, (uint8, bytes32, bytes32));
        
        if (ecrecover(calculatedHashToSign, v, r, s) == maker) {
            return true;
        }
        return false;
    }
    
       
    
        
    
    function approveOrderHash(bytes32 hash)  internal{

        require(!approved[msg.sender][hash], "Order has already been approved");
        approved[msg.sender][hash] = true;
    }

    function approveOrder(Order memory order, bool orderbookInclusionDesired) internal{

        require(order.maker == msg.sender, "Sender is not the maker of the order and thus not authorized to approve it");
        bytes32 hash = hashOrder(order);
        approveOrderHash(hash);
        emit OrderApproved(hash, order.registry, order.maker, order.staticTarget, order.staticSelector, order.staticExtradata, order.maximumFill, order.listingTime, order.expirationTime, order.salt, orderbookInclusionDesired);
    }

    function setOrderFill(bytes32 hash, uint fill) internal{

        require(fills[msg.sender][hash] != fill, "Fill is already set to the desired value");
        fills[msg.sender][hash] = fill;
        emit OrderFillChanged(hash, msg.sender, fill);
    }
    
     function encodeStaticCall(Order memory order, Call memory call, Order memory counterorder, Call memory countercall, address matcher, uint value, uint fill)
        internal
        pure
        returns (bytes memory)
    {

        address[7] memory addresses = [order.registry, order.maker, call.target, counterorder.registry, counterorder.maker, countercall.target, matcher];
        
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
    
     function executeCall(ProxyRegistryInterface registry, address maker, Call memory call)
        internal
        returns (bool)
    {

        require(registries[address(registry)]);

        require(exists(call.target), "Call target does not exist");

        OwnableDelegateProxy delegateProxy = registry.proxies(maker);

        require(address(delegateProxy) != address(0x0), "Delegate proxy does not exist for maker");

        require(delegateProxy.implementation() == registry.delegateProxyImplementation(), "Incorrect delegate proxy implementation for maker");

        AuthenticatedProxy proxy = AuthenticatedProxy(payable(address(delegateProxy)));

        return proxy.proxy(call.target, call.howToCall, call.data);
    }
    
    function payEthToProxy(ProxyRegistryInterface registry, address maker,uint256 price)
        internal
        returns (bool)
    {

        
        require(registries[address(registry)]);
        OwnableDelegateProxy delegateProxy = registry.proxies(maker);
        require(address(delegateProxy) != address(0x0), "Delegate proxy does not exist for maker");
        require(delegateProxy.implementation() == registry.delegateProxyImplementation(), "Incorrect delegate proxy implementation for maker");
        AuthenticatedProxy proxy = AuthenticatedProxy(payable(address(delegateProxy)));
        (bool success,)=address(proxy).call{value: price}(abi.encodeWithSignature("nonExistingFunction()"));
        return success;
    }
    
     function atomicMatch(Order memory firstOrder, Call memory firstCall, Order memory secondOrder, Call memory secondCall, bytes memory signatures, bytes32 metadata)
        internal
        reentrancyGuard
    {


        bytes32 firstHash = hashOrder(firstOrder);

        require(validateOrderParameters(firstOrder, firstHash), "First order has invalid parameters");

        bytes32 secondHash = hashOrder(secondOrder);

        require(validateOrderParameters(secondOrder, secondHash), "Second order has invalid parameters");

        require(firstHash != secondHash, "Self-matching orders is prohibited");
        {
            (bytes memory firstSignature, bytes memory secondSignature) = abi.decode(signatures, (bytes, bytes));
            
             require(validateOrderAuthorization(firstHash, firstOrder.maker, firstSignature), "First order failed authorization");

             require(validateOrderAuthorization(secondHash, secondOrder.maker, secondSignature), "Second order failed authorization");
        }


        if (msg.value > 0) {
           require(payEthToProxy(ProxyRegistryInterface(secondOrder.registry), secondOrder.maker,msg.value), "payEthToProxy call failed");
        }

        require(executeCall(ProxyRegistryInterface(firstOrder.registry), firstOrder.maker, firstCall), "First call failed");
        require(executeCall(ProxyRegistryInterface(secondOrder.registry), secondOrder.maker, secondCall), "Second call failed");

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


pragma solidity ^0.8.3;


contract Exchange is ExchangeCore {

    

    function hashOrder_(address registry, address maker, address staticTarget, bytes4 staticSelector, bytes calldata staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt)
        external
        pure
        returns (bytes32 hash)
    {

        return hashOrder(Order(registry, maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt));
    }

    function hashToSign_(bytes32 orderHash)
        external
        view
        returns (bytes32 hash)
    {

        return hashToSign(orderHash);
    }
    
     function validateOrderParameters_(address registry, address maker, address staticTarget, bytes4 staticSelector, bytes calldata staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt)
        external
        view
        returns (bool)
    {

        Order memory order = Order(registry, maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt);
        return validateOrderParameters(order, hashOrder(order));
    }

    function validateOrderAuthorization_(bytes32 hash, address maker, bytes calldata signature)
        external
        view
        returns (bool)
    {

        return validateOrderAuthorization(hash, maker, signature);
    }

    function approveOrderHash_(bytes32 hash)
        external
    {

        return approveOrderHash(hash);
    }

    function approveOrder_(address registry, address maker, address staticTarget, bytes4 staticSelector, bytes calldata staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired)
        external
    {

        return approveOrder(Order(registry, maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt), orderbookInclusionDesired);
    }

    function setOrderFill_(bytes32 hash, uint fill)
        external
    {

        return setOrderFill(hash, fill);
    }
    
    
    function atomicMatch_(address[8] memory addr,uint[8] memory uints, bytes4[2] memory staticSelectors,
        bytes memory firstExtradata, bytes memory firstCalldata, bytes memory secondExtradata, bytes memory secondCalldata,
        uint8[2] memory howToCalls, bytes32 metadata, bytes memory signatures)
        public
        payable
    {

        return atomicMatch(
            Order(addr[0], addr[1], addr[2], staticSelectors[0], firstExtradata, uints[0], uints[1], uints[2], uints[3]),
            Call(addr[3], AuthenticatedProxy.HowToCall(howToCalls[0]), firstCalldata),
            Order(addr[4], addr[5], addr[6], staticSelectors[1], secondExtradata, uints[4], uints[5], uints[6], uints[7]),
            Call(addr[7], AuthenticatedProxy.HowToCall(howToCalls[1]), secondCalldata),
            signatures,
            metadata
        );
    }
   
}


pragma solidity ^0.8.3;


contract WyvernExchange is Exchange {


    string public constant name = "Wyvern Exchange";
  
    string public constant version = "3.1";

    string public constant codename = "Ancalagon";

    constructor (uint chainId, address[] memory registryAddrs){
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name              : name,
            version           : version,
            chainId           : chainId,
            verifyingContract : address(this)
        }));
        for (uint i = 0; i < registryAddrs.length; i++) {
          registries[registryAddrs[i]] = true;
        }
    }
}