

pragma solidity >=0.4.24;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}

pragma solidity ^0.5.0;


contract ENSRegistry is ENS {


    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping (bytes32 => Record) records;
    mapping (address => mapping(address => bool)) operators;

    modifier authorised(bytes32 node) {

        address owner = records[node].owner;
        require(owner == msg.sender || operators[owner][msg.sender]);
        _;
    }

    constructor() public {
        records[0x0].owner = msg.sender;
    }

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external {

        setOwner(node, owner);
        _setResolverAndTTL(node, resolver, ttl);
    }

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external {

        bytes32 subnode = setSubnodeOwner(node, label, owner);
        _setResolverAndTTL(subnode, resolver, ttl);
    }

    function setOwner(bytes32 node, address owner) public authorised(node) {

        _setOwner(node, owner);
        emit Transfer(node, owner);
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public authorised(node) returns(bytes32) {

        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _setOwner(subnode, owner);
        emit NewOwner(node, label, owner);
        return subnode;
    }

    function setResolver(bytes32 node, address resolver) public authorised(node) {

        emit NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

    function setTTL(bytes32 node, uint64 ttl) public authorised(node) {

        emit NewTTL(node, ttl);
        records[node].ttl = ttl;
    }

    function setApprovalForAll(address operator, bool approved) external {

        operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function owner(bytes32 node) public view returns (address) {

        address addr = records[node].owner;
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    function resolver(bytes32 node) public view returns (address) {

        return records[node].resolver;
    }

    function ttl(bytes32 node) public view returns (uint64) {

        return records[node].ttl;
    }

    function recordExists(bytes32 node) public view returns (bool) {

        return records[node].owner != address(0x0);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {

        return operators[owner][operator];
    }

    function _setOwner(bytes32 node, address owner) internal {

        records[node].owner = owner;
    }

    function _setResolverAndTTL(bytes32 node, address resolver, uint64 ttl) internal {

        if(resolver != records[node].resolver) {
            records[node].resolver = resolver;
            emit NewResolver(node, resolver);
        }

        if(ttl != records[node].ttl) {
            records[node].ttl = ttl;
            emit NewTTL(node, ttl);
        }
    }
}



pragma solidity ^0.5.0;



contract ENSRegistryWithFallback is ENSRegistry {


    ENS public old;

    constructor(ENS _old) public ENSRegistry() {
        old = _old;
    }

    function resolver(bytes32 node) public view returns (address) {

        if (!recordExists(node)) {
            return old.resolver(node);
        }

        return super.resolver(node);
    }

    function owner(bytes32 node) public view returns (address) {

        if (!recordExists(node)) {
            return old.owner(node);
        }

        return super.owner(node);
    }

    function ttl(bytes32 node) public view returns (uint64) {

        if (!recordExists(node)) {
            return old.ttl(node);
        }

        return super.ttl(node);
    }

    function _setOwner(bytes32 node, address owner) internal {

        address addr = owner;
        if (addr == address(0x0)) {
            addr = address(this);
        }

        super._setOwner(node, addr);
    }
}