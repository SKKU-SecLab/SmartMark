

pragma solidity ^0.6.6;


interface ENSRegistry {

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

}

abstract contract ENSResolver {
    function addr(bytes32 _node) public view virtual returns (address);
    function setAddr(bytes32 _node, address _addr) public virtual;
    function name(bytes32 _node) public view virtual returns (string memory);
    function setName(bytes32 _node, string memory _name) public virtual;
}

abstract contract ENSReverseRegistrar {
    function claim(address _owner) public virtual returns (bytes32 _node);
    function claimWithResolver(address _owner, address _resolver) public virtual returns (bytes32);
    function setName(string memory _name) public virtual returns (bytes32);
    function node(address _addr) public view virtual returns (bytes32);
}

contract ENSReverseRegistrarImpl is ENSReverseRegistrar {

    bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    ENSRegistry public ens;
    ENSResolver public defaultResolver;

    constructor(address ensAddr, address resolverAddr) public {
        ens = ENSRegistry(ensAddr);
        defaultResolver = ENSResolver(resolverAddr);
    }

    function claim(address owner) public override returns (bytes32) {

        return claimWithResolver(owner, address(0));
    }

    function claimWithResolver(address owner, address resolver) public override returns (bytes32) {

        bytes32 label = sha3HexAddress(msg.sender);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentOwner = ens.owner(node);

        if(resolver != address(0) && resolver != address(ens.resolver(node))) {
            if(currentOwner != address(this)) {
                ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, address(this));
                currentOwner = address(this);
            }
            ens.setResolver(node, resolver);
        }

        if(currentOwner != owner) {
            ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);
        }

        return node;
    }

    function setName(string memory name) public override returns (bytes32 node) {

        node = claimWithResolver(address(this), address(defaultResolver));
        defaultResolver.setName(node, name);
        return node;
    }

    function node(address addr) public view override returns (bytes32 ret) {

        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    function sha3HexAddress(address addr) private view returns (bytes32 ret) {

        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000
            let i := 40

            for { } gt(i, 0) { } {
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
}