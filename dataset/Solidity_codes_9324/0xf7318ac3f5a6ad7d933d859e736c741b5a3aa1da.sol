pragma solidity >=0.8.4;

interface HI {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external virtual;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external virtual;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external virtual returns(bytes32);

    function setResolver(bytes32 node, address resolver) external virtual;

    function setOwner(bytes32 node, address owner) external virtual;

    function setTTL(bytes32 node, uint64 ttl) external virtual;

    function setApprovalForAll(address operator, bool approved) external virtual;

    function owner(bytes32 node) external virtual view returns (address);

    function resolver(bytes32 node) external virtual view returns (address);

    function ttl(bytes32 node) external virtual view returns (uint64);

    function recordExists(bytes32 node) external virtual view returns (bool);

    function isApprovedForAll(address owner, address operator) external virtual view returns (bool);

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
}pragma solidity ^0.8.4;


contract Controllable is Ownable {

    mapping(address => bool) public controllers;

    event ControllerChanged(address indexed controller, bool enabled);

    modifier onlyController {

        require(
            controllers[msg.sender],
            "Controllable: Caller is not a controller"
        );
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {

        controllers[controller] = enabled;
        emit ControllerChanged(controller, enabled);
    }
}pragma solidity >=0.8.4;


abstract contract NameResolver {
    function setName(bytes32 node, string memory name) public virtual;
}

bytes32 constant lookup = 0x3031323334353637383961626364656600000000000000000000000000000000;

bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;


contract ReverseRegistrar is Ownable, Controllable {

    HI public hi ;
    NameResolver public defaultResolver;

    event ReverseClaimed(address indexed addr, bytes32 indexed node);

    constructor(HI hiAddr, NameResolver resolverAddr) {
        hi = hiAddr;
        defaultResolver = resolverAddr;

        ReverseRegistrar oldRegistrar = ReverseRegistrar(
            hi.owner(ADDR_REVERSE_NODE)
        );
        if (address(oldRegistrar) != address(0x0)) {
            oldRegistrar.claim(msg.sender);
        }
    }

    modifier authorised(address addr) {

        require(
            addr == msg.sender ||
                controllers[msg.sender] ||
                hi.isApprovedForAll(addr, msg.sender) ||
                ownsContract(addr),
            "Caller is not a controller or authorised by address or the address itself"
        );
        _;
    }

    function claim(address owner) public returns (bytes32) {

        return _claimWithResolver(msg.sender, owner, address(0x0));
    }

    function claimForAddr(address addr, address owner)
        public
        authorised(addr)
        returns (bytes32)
    {

        return _claimWithResolver(addr, owner, address(0x0));
    }

    function claimWithResolver(address owner, address resolver)
        public
        returns (bytes32)
    {

        return _claimWithResolver(msg.sender, owner, resolver);
    }

    function claimWithResolverForAddr(
        address addr,
        address owner,
        address resolver
    ) public authorised(addr) returns (bytes32) {

        return _claimWithResolver(addr, owner, resolver);
    }

    function setName(string memory name) public returns (bytes32) {

        bytes32 node = _claimWithResolver(
            msg.sender,
            address(this),
            address(defaultResolver)
        );
        defaultResolver.setName(node, name);
        return node;
    }

    function setNameForAddr(
        address addr,
        address owner,
        string memory name
    ) public authorised(addr) returns (bytes32) {

        bytes32 node = _claimWithResolver(
            addr,
            address(this),
            address(defaultResolver)
        );
        defaultResolver.setName(node, name);
        hi.setSubnodeOwner(ADDR_REVERSE_NODE, sha3HexAddress(addr), owner);
        return node;
    }

    function node(address addr) public pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr))
            );
    }

    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {

        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }


    function _claimWithResolver(
        address addr,
        address owner,
        address resolver
    ) internal returns (bytes32) {

        bytes32 label = sha3HexAddress(addr);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentResolver = hi.resolver(node);
        bool shouldUpdateResolver = (resolver != address(0x0) &&
            resolver != currentResolver);
        address newResolver = shouldUpdateResolver ? resolver : currentResolver;

        hi.setSubnodeRecord(ADDR_REVERSE_NODE, label, owner, newResolver, 0);

        emit ReverseClaimed(addr, node);

        return node;
    }

    function ownsContract(address addr) internal view returns (bool) {

        try Ownable(addr).owner() returns (address owner) {
            return owner == msg.sender;
        } catch {
            return false;
        }
    }
}