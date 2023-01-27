

pragma solidity 0.5.15;


contract Proxy {


    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("xsnx.implementationPosition");
    bytes32 private constant PROPOSED_IMPLEMENTATION_POSITION = keccak256("xsnx.proposedImplementationPosition");

    bytes32 private constant PROXY_ADMIN_POSITION = keccak256("xsnx.proxyAdmin");
    bytes32 private constant PROXY_COSIGNER1_POSITION = keccak256("xsnx.cosigner1");
    bytes32 private constant PROXY_COSIGNER2_POSITION = keccak256("xsnx.cosigner2");

    bytes32 private constant PROPOSED_NEW_ADMIN  = keccak256("xsnx.proposedNewAdmin");
    bytes32 private constant PROPOSED_NEW_ADMIN_TIMESTAMP  = keccak256("xsnx.proposedNewAdminTimestamp");

    modifier onlyProxyAdmin() {

        require(msg.sender == readAddressAtPosition(PROXY_ADMIN_POSITION));
        _;
    }

    modifier onlySigner() {

        address signer1 = readAddressAtPosition(PROXY_COSIGNER1_POSITION);
        address signer2 = readAddressAtPosition(PROXY_COSIGNER2_POSITION);
        require(msg.sender == signer1 || msg.sender == signer2);
        _;
    }

    constructor(
        address implementation,
        address proxyAdmin,
        address signer1,
        address signer2
    ) public {
        require(
            implementation != address(0),
            "Invalid implementation address provided"
        );
        require(
            proxyAdmin != address(0),
            "Invalid proxyAdmin address provided"
        );
        require(signer1 != address(0), "Invalid signer1 address provided");
        require(signer2 != address(0), "Invalid signer2 address provided");
        require(signer1 != signer2, "Signers must have different addresses");
        setNewAddressAtPosition(IMPLEMENTATION_POSITION, implementation);
        setNewAddressAtPosition(PROXY_ADMIN_POSITION, proxyAdmin);
        setNewAddressAtPosition(PROXY_COSIGNER1_POSITION, signer1);
        setNewAddressAtPosition(PROXY_COSIGNER2_POSITION, signer2);
    }

    function proposeNewImplementation(address newImplementation) public onlyProxyAdmin {

        require(newImplementation != address(0), "new proposed implementation cannot be address(0)");
        require(isContract(newImplementation), "new proposed implementation is not a contract");
        require(newImplementation != implementation(), "new proposed address cannot be the same as the current implementation address");
        setNewAddressAtPosition(PROPOSED_IMPLEMENTATION_POSITION, newImplementation);
    }

    function confirmImplementation(address confirmedImplementation)
        public
        onlySigner
    {

        address proposedImplementation = readAddressAtPosition(
            PROPOSED_IMPLEMENTATION_POSITION
        );
        require(
            proposedImplementation != address(0),
            "proposed implementation cannot be address(0)"
        );
        require(
            confirmedImplementation == proposedImplementation,
            "proposed implementation doesn't match the confirmed implementation"
        );
        setNewAddressAtPosition(IMPLEMENTATION_POSITION, confirmedImplementation);
        setNewAddressAtPosition(PROPOSED_IMPLEMENTATION_POSITION, address(0));
    }

    function proposeAdminTransfer(address newAdminAddress) public onlyProxyAdmin {

        require(newAdminAddress != address(0), "new Admin address cannot be address(0)");
        setProposedAdmin(newAdminAddress);
    }


    function confirmAdminTransfer() public onlyProxyAdmin {

        address newAdminAddress = proposedNewAdmin();
        require(newAdminAddress != address(0), "new Admin address cannot be address(0)");
        require(proposedNewAdminTimestamp() <= block.timestamp, "admin change can only be submitted after 1 day");
        setProxyAdmin(newAdminAddress);
        setProposedAdmin(address(0));
    }

    function isContract(address _addr) private view returns (bool){

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function implementation() public view returns (address impl) {

        impl = readAddressAtPosition(IMPLEMENTATION_POSITION);
    }

    function proxyAdmin() public view returns (address admin) {

        admin = readAddressAtPosition(PROXY_ADMIN_POSITION);
    }

    function proposedNewImplementation() public view returns (address impl) {

        impl = readAddressAtPosition(PROPOSED_IMPLEMENTATION_POSITION);
    }

    function proposedNewAdmin() public view returns (address newAdmin) {

        newAdmin = readAddressAtPosition(PROPOSED_NEW_ADMIN);
    }

    function proposedNewAdminTimestamp() public view returns (uint256 timestamp) {

        timestamp = readIntAtPosition(PROPOSED_NEW_ADMIN_TIMESTAMP);
    }

    function proxySigner(uint256 id) public view returns (address signer) {

        if (id == 0) {
            signer = readAddressAtPosition(PROXY_COSIGNER1_POSITION);
        } else {
            signer = readAddressAtPosition(PROXY_COSIGNER2_POSITION);
        }
    }

    function proxyType() public pure returns (uint256) {

        return 2; // type 2 is for upgradeable proxy as per EIP-897
    }


    function setProposedAdmin(address proposedAdmin) private {

        setNewAddressAtPosition(PROPOSED_NEW_ADMIN, proposedAdmin);
        setNewIntAtPosition(PROPOSED_NEW_ADMIN_TIMESTAMP, block.timestamp + 1 days);
    }

    function setProxyAdmin(address newAdmin) private {

        setNewAddressAtPosition(PROXY_ADMIN_POSITION, newAdmin);
    }

    function setNewAddressAtPosition(bytes32 position, address newAddr) private {

        assembly { sstore(position, newAddr) }
    }

    function readAddressAtPosition(bytes32 position) private view returns (address result) {

        assembly { result := sload(position) }
    }

    function setNewIntAtPosition(bytes32 position, uint256 newInt) private {

        assembly { sstore(position, newInt) }
    }

    function readIntAtPosition(bytes32 position) private view returns (uint256 result) {

        assembly { result := sload(position) }
    }

    function() external payable {
        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            let masterCopy := and(
                sload(position),
                0xffffffffffffffffffffffffffffffffffffffff
            )
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let success := delegatecall(
                gas,
                masterCopy,
                ptr,
                calldatasize(),
                0,
                0
            )
            returndatacopy(ptr, 0, returndatasize())
            switch eq(success, 0)
                case 1 {
                    revert(ptr, returndatasize())
                }
            return(ptr, returndatasize())
        }
    }
}


pragma solidity 0.5.15;


contract xSNXProxy is Proxy {

    constructor(
        address implementation,
        address proxyAdmin,
        address signer1,
        address signer2
    ) public Proxy(
        implementation,
        proxyAdmin,
        signer1,
        signer2
    ) {}
}