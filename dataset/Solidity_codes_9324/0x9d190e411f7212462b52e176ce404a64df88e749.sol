
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
pragma solidity 0.8.14;

contract StaticCaller {

    function staticCall(address target, bytes memory data)
        internal
        view
        returns (bool result)
    {

        assembly {
            result := staticcall(
                gas(),
                target,
                add(data, 0x20),
                mload(data),
                mload(0x40),
                0
            )
        }
        return result;
    }

    function staticCallUint(address target, bytes memory data)
        internal
        view
        returns (uint256 ret)
    {

        bool result;
        assembly {
            let size := 0x20
            let free := mload(0x40)
            result := staticcall(
                gas(),
                target,
                add(data, 0x20),
                mload(data),
                free,
                size
            )
            ret := mload(free)
        }
        require(result, "Static call failed");
        return ret;
    }
}// MIT
pragma solidity 0.8.14;

contract EIP712 {

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 DOMAIN_SEPARATOR;

    function hash(EIP712Domain memory eip712Domain)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    EIP712DOMAIN_TYPEHASH,
                    keccak256(bytes(eip712Domain.name)),
                    keccak256(bytes(eip712Domain.version)),
                    eip712Domain.chainId,
                    eip712Domain.verifyingContract
                )
            );
    }
}// MIT
pragma solidity 0.8.14;

abstract contract ERC1271 {
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    function isValidSignature(bytes32 _hash, bytes memory _signature)
        public
        view
        virtual
        returns (bytes4 magicValue);
}// MIT
pragma solidity ^0.8.14;

abstract contract Proxy {
    function _delegate(address _impl) internal virtual {
        require(_impl != address(0), "Proxy implementation required");
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function implementation() public view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT
pragma solidity ^0.8.14;

contract OwnedUpgradeabilityStorage {

    address internal _implementation;

    address private _upgradeabilityOwner;

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}// MIT
pragma solidity ^0.8.14;


contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    event Upgraded(address indexed implementation);

    function implementation() public view override returns (address) {

        return _implementation;
    }

    function _upgradeTo(address _impl) internal {

        require(
            _implementation != _impl,
            "Proxy already uses this implementation"
        );
        _implementation = _impl;
        emit Upgraded(_impl);
    }

    modifier onlyProxyOwner() {

        require(
            msg.sender == proxyOwner(),
            "Only the proxy owner can call this method"
        );
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

    function upgradeTo(address _impl) public onlyProxyOwner {

        _upgradeTo(_impl);
    }

    function upgradeToAndCall(address _impl, bytes memory data)
        public
        payable
        onlyProxyOwner
    {

        upgradeTo(_impl);
        (bool success, ) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}// MIT
pragma solidity ^0.8.14;


contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {

    constructor(
        address owner,
        address initialImplementation,
        bytes memory data
    ) {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success, ) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }
}// MIT
pragma solidity ^0.8.14;


interface ProxyRegistryInterface {

    function delegateProxyImplementation() external returns (address);


    function proxies(address owner) external returns (OwnableDelegateProxy);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.14;



contract ProxyRegistry is Ownable, ProxyRegistryInterface {

    address public override delegateProxyImplementation;

    mapping(address => OwnableDelegateProxy) public override proxies;

    mapping(address => uint256) public pending;

    mapping(address => bool) public contracts;

    uint256 public DELAY_PERIOD = 2 weeks;

    function startGrantAuthentication(address addr) public onlyOwner {

        require(
            !contracts[addr] && pending[addr] == 0,
            "Contract is already allowed in registry, or pending"
        );
        pending[addr] = block.timestamp;
    }

    function endGrantAuthentication(address addr) public onlyOwner {

        require(
            !contracts[addr] &&
                pending[addr] != 0 &&
                ((pending[addr] + DELAY_PERIOD) < block.timestamp),
            "Contract is no longer pending or has already been approved by registry"
        );
        pending[addr] = 0;
        contracts[addr] = true;
    }

    function revokeAuthentication(address addr) public onlyOwner {

        contracts[addr] = false;
    }

    function registerProxy() public returns (OwnableDelegateProxy proxy) {

        return registerProxyFor(msg.sender);
    }

    function registerProxyOverride()
        public
        returns (OwnableDelegateProxy proxy)
    {

        proxy = new OwnableDelegateProxy(
            msg.sender,
            delegateProxyImplementation,
            abi.encodeWithSignature(
                "initialize(address,address)",
                msg.sender,
                address(this)
            )
        );
        proxies[msg.sender] = proxy;
        return proxy;
    }

    function registerProxyFor(address user)
        public
        returns (OwnableDelegateProxy proxy)
    {

        require(
            proxies[user] == OwnableDelegateProxy(payable(0)),
            "User already has a proxy"
        );
        proxy = new OwnableDelegateProxy(
            user,
            delegateProxyImplementation,
            abi.encodeWithSignature(
                "initialize(address,address)",
                user,
                address(this)
            )
        );
        proxies[user] = proxy;
        return proxy;
    }

    function transferAccessTo(address from, address to) public {

        OwnableDelegateProxy proxy = proxies[from];

        require(
            OwnableDelegateProxy(payable(msg.sender)) == proxy,
            "Proxy transfer can only be called by the proxy"
        );
        require(
            proxies[to] == OwnableDelegateProxy(payable(0)),
            "Proxy transfer has existing proxy as destination"
        );

        delete proxies[from];
        proxies[to] = proxy;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT
pragma solidity ^0.8.14;


contract TokenRecipient {
    event ReceivedEther(address indexed sender, uint256 amount);
    event ReceivedTokens(
        address indexed from,
        uint256 value,
        address indexed token,
        bytes extraData
    );

    function receiveApproval(
        address from,
        uint256 value,
        address token,
        bytes memory extraData
    ) public {
        ERC20 t = ERC20(token);
        require(
            t.transferFrom(from, address(this), value),
            "ERC20 token transfer failed"
        );
        emit ReceivedTokens(from, value, token, extraData);
    }

    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
}// MIT
pragma solidity ^0.8.14;


contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {
    bool initialized = false;

    address public user;

    ProxyRegistry public registry;

    bool public revoked;

    enum HowToCall {
        Call,
        DelegateCall
    }

    event Revoked(bool revoked);

    function initialize(address addrUser, ProxyRegistry addrRegistry) public {
        require(!initialized, "Authenticated proxy already initialized");
        initialized = true;
        user = addrUser;
        registry = addrRegistry;
    }

    function setRevoke(bool revoke) public {
        require(
            msg.sender == user,
            "Authenticated proxy can only be revoked by its user"
        );
        revoked = revoke;
        emit Revoked(revoke);
    }

    function proxy(
        address dest,
        HowToCall howToCall,
        bytes memory data
    ) public returns (bool result) {
        require(
            msg.sender == user || (!revoked && registry.contracts(msg.sender)),
            "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access"
        );
        bytes memory ret;
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
        return result;
    }

    function proxyAssert(
        address dest,
        HowToCall howToCall,
        bytes memory data
    ) public {
        require(proxy(dest, howToCall, data), "Proxy assertion failed");
    }
}// MIT
pragma solidity ^0.8.14;



contract ExchangeCore is ReentrancyGuard, StaticCaller, EIP712 {
    bytes4 internal constant EIP_1271_MAGICVALUE = 0x1626ba7e;
    bytes internal personalSignPrefix = "\x19Ethereum Signed Message:\n";


    struct Order {
        address registry;
        address maker;
        address staticTarget;
        bytes4 staticSelector;
        bytes staticExtradata;
        uint256 maximumFill;
        uint256 listingTime;
        uint256 expirationTime;
        uint256 salt;
    }

    struct Call {
        address target;
        AuthenticatedProxy.HowToCall howToCall;
        bytes data;
    }


    bytes32 constant ORDER_TYPEHASH =
        keccak256(
            "Order(address registry,address maker,address staticTarget,bytes4 staticSelector,bytes staticExtradata,uint256 maximumFill,uint256 listingTime,uint256 expirationTime,uint256 salt)"
        );


    mapping(address => bool) public registries;

    mapping(address => mapping(bytes32 => uint256)) public fills;

    mapping(address => mapping(bytes32 => bool)) public approved;


    event OrderApproved(
        bytes32 indexed hash,
        address registry,
        address indexed maker,
        address staticTarget,
        bytes4 staticSelector,
        bytes staticExtradata,
        uint256 maximumFill,
        uint256 listingTime,
        uint256 expirationTime,
        uint256 salt,
        bool orderbookInclusionDesired
    );
    event OrderFillChanged(
        bytes32 indexed hash,
        address indexed maker,
        uint256 newFill
    );
    event OrdersMatched(
        bytes32 firstHash,
        bytes32 secondHash,
        address indexed firstMaker,
        address indexed secondMaker,
        uint256 newFirstFill,
        uint256 newSecondFill,
        bytes32 indexed metadata
    );


    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 hash)
    {
        return
            keccak256(
                abi.encode(
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
                )
            );
    }

    function hashToSign(bytes32 orderHash)
        internal
        view
        returns (bytes32 hash)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, orderHash)
            );
    }

    function exists(address what) internal view returns (bool) {
        uint256 size;
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
        if (
            order.listingTime > block.timestamp ||
            (order.expirationTime != 0 &&
                order.expirationTime <= block.timestamp)
        ) {
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

    function validateOrderAuthorization(
        bytes32 hash,
        address maker,
        bytes memory signature
    ) internal view returns (bool) {
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
            if (
                ERC1271(maker).isValidSignature(
                    calculatedHashToSign,
                    signature
                ) == EIP_1271_MAGICVALUE
            ) {
                return true;
            }
            return false;
        }

        (uint8 v, bytes32 r, bytes32 s) = abi.decode(
            signature,
            (uint8, bytes32, bytes32)
        );

        if (signature.length > 65 && signature[signature.length - 1] == 0x03) {
            if (
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            personalSignPrefix,
                            "32",
                            calculatedHashToSign
                        )
                    ),
                    v,
                    r,
                    s
                ) == maker
            ) {
                return true;
            }
        }
        else if (ecrecover(calculatedHashToSign, v, r, s) == maker) {
            return true;
        }
        return false;
    }

    function encodeStaticCall(
        Order memory order,
        Call memory call,
        Order memory counterorder,
        Call memory countercall,
        address matcher,
        uint256 value,
        uint256 fill
    ) internal pure returns (bytes memory) {
        address[7] memory addresses = [
            order.registry,
            order.maker,
            call.target,
            counterorder.registry,
            counterorder.maker,
            countercall.target,
            matcher
        ];
        AuthenticatedProxy.HowToCall[2] memory howToCalls = [
            call.howToCall,
            countercall.howToCall
        ];
        uint256[6] memory uints = [
            value,
            order.maximumFill,
            order.listingTime,
            order.expirationTime,
            counterorder.listingTime,
            fill
        ];
        return
            abi.encodeWithSelector(
                order.staticSelector,
                order.staticExtradata,
                addresses,
                howToCalls,
                uints,
                call.data,
                countercall.data
            );
    }

    function executeStaticCall(
        Order memory order,
        Call memory call,
        Order memory counterorder,
        Call memory countercall,
        address matcher,
        uint256 value,
        uint256 fill
    ) internal view returns (uint256) {
        return
            staticCallUint(
                order.staticTarget,
                encodeStaticCall(
                    order,
                    call,
                    counterorder,
                    countercall,
                    matcher,
                    value,
                    fill
                )
            );
    }

    function executeCall(
        ProxyRegistryInterface registry,
        address maker,
        Call memory call
    ) internal returns (bool) {
        require(registries[address(registry)]);

        require(exists(call.target), "Call target does not exist");

        OwnableDelegateProxy delegateProxy = registry.proxies(maker);

        require(
            delegateProxy != OwnableDelegateProxy(payable(0)),
            "Delegate proxy does not exist for maker"
        );

        require(
            delegateProxy.implementation() ==
                registry.delegateProxyImplementation(),
            "Incorrect delegate proxy implementation for maker"
        );

        AuthenticatedProxy proxy = AuthenticatedProxy(payable(delegateProxy));

        return proxy.proxy(call.target, call.howToCall, call.data);
    }

    function approveOrderHash(bytes32 hash) internal {

        require(!approved[msg.sender][hash], "Order has already been approved");


        approved[msg.sender][hash] = true;
    }

    function approveOrder(Order memory order, bool orderbookInclusionDesired)
        internal
    {

        require(
            order.maker == msg.sender,
            "Sender is not the maker of the order and thus not authorized to approve it"
        );

        bytes32 hash = hashOrder(order);

        approveOrderHash(hash);

        emit OrderApproved(
            hash,
            order.registry,
            order.maker,
            order.staticTarget,
            order.staticSelector,
            order.staticExtradata,
            order.maximumFill,
            order.listingTime,
            order.expirationTime,
            order.salt,
            orderbookInclusionDesired
        );
    }

    function setOrderFill(bytes32 hash, uint256 fill) internal {

        require(
            fills[msg.sender][hash] != fill,
            "Fill is already set to the desired value"
        );


        fills[msg.sender][hash] = fill;

        emit OrderFillChanged(hash, msg.sender, fill);
    }

    function atomicMatch(
        Order memory firstOrder,
        Call memory firstCall,
        Order memory secondOrder,
        Call memory secondCall,
        bytes memory signatures,
        bytes32 metadata
    ) internal nonReentrant {

        bytes32 firstHash = hashOrder(firstOrder);

        require(
            validateOrderParameters(firstOrder, firstHash),
            "First order has invalid parameters"
        );

        bytes32 secondHash = hashOrder(secondOrder);

        require(
            validateOrderParameters(secondOrder, secondHash),
            "Second order has invalid parameters"
        );

        require(firstHash != secondHash, "Self-matching orders is prohibited");

        {
            (bytes memory firstSignature, bytes memory secondSignature) = abi
                .decode(signatures, (bytes, bytes));

            require(
                validateOrderAuthorization(
                    firstHash,
                    firstOrder.maker,
                    firstSignature
                ),
                "First order failed authorization"
            );

            require(
                validateOrderAuthorization(
                    secondHash,
                    secondOrder.maker,
                    secondSignature
                ),
                "Second order failed authorization"
            );
        }


        if (msg.value > 0) {
            (bool success, ) = address(uint160(firstOrder.maker)).call{
                value: msg.value
            }("");
            require(success, "native token transfer failed.");
        }

        require(
            executeCall(
                ProxyRegistryInterface(firstOrder.registry),
                firstOrder.maker,
                firstCall
            ),
            "First call failed"
        );

        require(
            executeCall(
                ProxyRegistryInterface(secondOrder.registry),
                secondOrder.maker,
                secondCall
            ),
            "Second call failed"
        );


        uint256 previousFirstFill = fills[firstOrder.maker][firstHash];

        uint256 previousSecondFill = fills[secondOrder.maker][secondHash];

        uint256 firstFill = executeStaticCall(
            firstOrder,
            firstCall,
            secondOrder,
            secondCall,
            msg.sender,
            msg.value,
            previousFirstFill
        );

        uint256 secondFill = executeStaticCall(
            secondOrder,
            secondCall,
            firstOrder,
            firstCall,
            msg.sender,
            uint256(0),
            previousSecondFill
        );


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


        emit OrdersMatched(
            firstHash,
            secondHash,
            firstOrder.maker,
            secondOrder.maker,
            firstFill,
            secondFill,
            metadata
        );
    }
}// MIT
pragma solidity ^0.8.14;


contract Exchange is ExchangeCore {

    function hashOrder_(
        address registry,
        address maker,
        address staticTarget,
        bytes4 staticSelector,
        bytes calldata staticExtradata,
        uint256 maximumFill,
        uint256 listingTime,
        uint256 expirationTime,
        uint256 salt
    ) external pure returns (bytes32 hash) {
        return
            hashOrder(
                Order(
                    registry,
                    maker,
                    staticTarget,
                    staticSelector,
                    staticExtradata,
                    maximumFill,
                    listingTime,
                    expirationTime,
                    salt
                )
            );
    }

    function hashToSign_(bytes32 orderHash)
        external
        view
        returns (bytes32 hash)
    {
        return hashToSign(orderHash);
    }

    function validateOrderParameters_(
        address registry,
        address maker,
        address staticTarget,
        bytes4 staticSelector,
        bytes calldata staticExtradata,
        uint256 maximumFill,
        uint256 listingTime,
        uint256 expirationTime,
        uint256 salt
    ) external view returns (bool) {
        Order memory order = Order(
            registry,
            maker,
            staticTarget,
            staticSelector,
            staticExtradata,
            maximumFill,
            listingTime,
            expirationTime,
            salt
        );
        return validateOrderParameters(order, hashOrder(order));
    }

    function validateOrderAuthorization_(
        bytes32 hash,
        address maker,
        bytes calldata signature
    ) external view returns (bool) {
        return validateOrderAuthorization(hash, maker, signature);
    }

    function approveOrderHash_(bytes32 hash) external {
        return approveOrderHash(hash);
    }

    function approveOrder_(
        address registry,
        address maker,
        address staticTarget,
        bytes4 staticSelector,
        bytes calldata staticExtradata,
        uint256 maximumFill,
        uint256 listingTime,
        uint256 expirationTime,
        uint256 salt,
        bool orderbookInclusionDesired
    ) external {
        return
            approveOrder(
                Order(
                    registry,
                    maker,
                    staticTarget,
                    staticSelector,
                    staticExtradata,
                    maximumFill,
                    listingTime,
                    expirationTime,
                    salt
                ),
                orderbookInclusionDesired
            );
    }

    function setOrderFill_(bytes32 hash, uint256 fill) external {
        return setOrderFill(hash, fill);
    }

    function atomicMatch_(
        uint256[16] memory uints,
        bytes4[2] memory staticSelectors,
        bytes memory firstExtradata,
        bytes memory firstCalldata,
        bytes memory secondExtradata,
        bytes memory secondCalldata,
        uint8[2] memory howToCalls,
        bytes32 metadata,
        bytes memory signatures
    ) public payable {
        return
            atomicMatch(
                Order(
                    address(uint160(uints[0])),
                    address(uint160(uints[1])),
                    address(uint160(uints[2])),
                    staticSelectors[0],
                    firstExtradata,
                    uints[3],
                    uints[4],
                    uints[5],
                    uints[6]
                ),
                Call(
                    address(uint160(uints[7])),
                    AuthenticatedProxy.HowToCall(howToCalls[0]),
                    firstCalldata
                ),
                Order(
                    address(uint160(uints[8])),
                    address(uint160(uints[9])),
                    address(uint160(uints[10])),
                    staticSelectors[1],
                    secondExtradata,
                    uints[11],
                    uints[12],
                    uints[13],
                    uints[14]
                ),
                Call(
                    address(uint160(uints[15])),
                    AuthenticatedProxy.HowToCall(howToCalls[1]),
                    secondCalldata
                ),
                signatures,
                metadata
            );
    }
}// MIT
pragma solidity ^0.8.14;


contract WyvernExchange is Exchange {
    string public constant name = "Unvest Protocol";
    string public constant version = "1.0";

    constructor(
        uint256 chainId,
        address[] memory registryAddrs,
        bytes memory customPersonalSignPrefix
    ) {
        DOMAIN_SEPARATOR = hash(
            EIP712Domain({
                name: name,
                version: version,
                chainId: chainId,
                verifyingContract: address(this)
            })
        );
        for (uint256 ind = 0; ind < registryAddrs.length; ind++) {
            registries[registryAddrs[ind]] = true;
        }
        if (customPersonalSignPrefix.length > 0) {
            personalSignPrefix = customPersonalSignPrefix;
        }
    }
}