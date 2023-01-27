
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.7.5;

abstract contract Proxy {
    function implementation() public view virtual returns (address);

    function proxyType() public pure virtual returns (uint256 proxyTypeId);

    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0), "Proxy implementation required");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}// MIT
pragma solidity 0.7.5;

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
pragma solidity 0.7.5;


contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    event Upgraded(address indexed implementation);

    function implementation() public view override returns (address) {

        return _implementation;
    }

    function proxyType() public pure override returns (uint256 proxyTypeId) {

        return 2;
    }

    function _upgradeTo(address implementation_) internal {

        require(
            _implementation != implementation_,
            "Proxy already uses this implementation"
        );
        _implementation = implementation_;
        emit Upgraded(implementation_);
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

    function upgradeTo(address implementation_) public onlyProxyOwner {

        _upgradeTo(implementation_);
    }

    function upgradeToAndCall(address implementation_, bytes memory data)
        public
        payable
        onlyProxyOwner
    {

        upgradeTo(implementation_);
        (bool success, ) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}/*

  OwnableDelegateProxy

*/
pragma solidity 0.7.5;


contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {

    constructor(
        address owner,
        address initialImplementation,
        bytes memory data
    ) public {
        require(owner != address(0), "owner: zero address");
        require(
            initialImplementation != address(0),
            "initialImplementation: zero address"
        );
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success, ) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }
}/*

  Proxy registry interface.

*/
pragma solidity 0.7.5;


interface ProxyRegistryInterface {

    function delegateProxyImplementation() external returns (address);


    function proxies(address owner) external returns (OwnableDelegateProxy);

}/*

  Proxy registry; keeps a mapping of AuthenticatedProxy contracts and mapping of contracts authorized to access them.  
  
  Abstracted away from the Exchange (a) to reduce Exchange attack surface and (b) so that the Exchange contract can be upgraded without users needing to transfer assets to new proxies.

*/
pragma solidity 0.7.5;


contract ProxyRegistry is OwnableUpgradeable, ProxyRegistryInterface {

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
            proxies[user] == OwnableDelegateProxy(0),
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
            OwnableDelegateProxy(msg.sender) == proxy,
            "Proxy transfer can only be called by the proxy"
        );
        require(
            proxies[to] == OwnableDelegateProxy(0),
            "Proxy transfer has existing proxy as destination"
        );

        delete proxies[from];
        proxies[to] = proxy;
    }
}// MIT
pragma solidity 0.7.5;

interface ERC20Basic {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
}// MIT
pragma solidity 0.7.5;


interface ERC20 is ERC20Basic {

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}/*

  Token recipient. Modified very slightly from the example on http://ethereum.org/dao (just to index log parameters).

*/
pragma solidity 0.7.5;


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

    fallback() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
}/* 

  Proxy contract to hold access to assets on behalf of a user (e.g. ERC20 approve) and execute calls under particular conditions.

*/
pragma solidity 0.7.5;


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
    ) public returns (bool result, bytes memory ret) {

        require(
            msg.sender == user || (!revoked && registry.contracts(msg.sender)),
            "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access"
        );
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
    }

    function proxyAssert(
        address dest,
        HowToCall howToCall,
        bytes memory data
    ) public {

        (bool result, ) = proxy(dest, howToCall, data);
        require(result, "Proxy assertion failed");
    }
}// MIT
pragma solidity 0.7.5;


contract VindergoodRegistry is ProxyRegistry, ReentrancyGuardUpgradeable {

    string public constant name = "Wyvern Protocol Proxy Registry";

    bool public initialAddressSet = false;

    function initialize() external initializer {

        AuthenticatedProxy impl = new AuthenticatedProxy();
        impl.initialize(address(this), this);
        impl.setRevoke(true);
        delegateProxyImplementation = address(impl);
        __Ownable_init();
    }

    function grantInitialAuthentication(address authAddress) public onlyOwner {

        require(
            !initialAddressSet,
            "Wyvern Protocol Proxy Registry initial address already set"
        );
        initialAddressSet = true;
        contracts[authAddress] = true;
    }
}