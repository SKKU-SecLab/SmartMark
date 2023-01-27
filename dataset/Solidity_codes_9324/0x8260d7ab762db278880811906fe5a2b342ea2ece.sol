pragma solidity ^0.6.11;

abstract contract SimpleAdminable {

    address owner;
    address ownerCandidate;
    mapping(address => bool) admins;

    constructor() internal {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "ONLY_OWNER");
        _;
    }

    function isOwner(address testedAddress) public view returns (bool) {
        return owner == testedAddress;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "ONLY_ADMIN");
        _;
    }

    function isAdmin(address testedAddress) public view returns (bool) {
        return admins[testedAddress];
    }

    function registerAdmin(address newAdmin) external onlyOwner {
        if (!isAdmin(newAdmin)) {
            admins[newAdmin] = true;
        }
    }

    function removeAdmin(address removedAdmin) external onlyOwner {
        require(!isOwner(removedAdmin), "OWNER_CANNOT_BE_REMOVED_AS_ADMIN");
        delete admins[removedAdmin];
    }

    function nominateNewOwner(address newOwner) external onlyOwner {
        require(!isOwner(newOwner), "ALREADY_OWNER");
        ownerCandidate = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == ownerCandidate, "NOT_A_CANDIDATE");
        owner = ownerCandidate;
        admins[ownerCandidate] = true;
        ownerCandidate = address(0x0);
    }
}
pragma solidity ^0.6.11;


abstract contract Finalizable is SimpleAdminable {
    bool finalized;

    function isFinalized() public view returns(bool) {
        return finalized;
    }

    modifier notFinalized() {
        require(!isFinalized(), "FINALIZED");
        _;
    }

    function finalize() external onlyAdmin {
        finalized = true;
    }
}
pragma solidity ^0.6.11;

interface Identity {


    function identify()
        external pure
        returns(string memory);

}
pragma solidity ^0.6.11;

interface IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.6.11;


interface IQueryableFactRegistry is IFactRegistry {


    function hasRegisteredFact()
        external view
        returns(bool);


}
pragma solidity ^0.6.11;


contract GpsFactRegistryAdapter is IQueryableFactRegistry, Identity {


    IQueryableFactRegistry public gpsContract;
    uint256 public programHash;

    constructor(
        IQueryableFactRegistry gpsStatementContract, uint256 programHash_)
        public
    {
        gpsContract = gpsStatementContract;
        programHash = programHash_;
    }

    function identify()
        external pure virtual override
        returns(string memory)
    {

        return "StarkWare_GpsFactRegistryAdapter_2020_1";
    }

    function isValid(bytes32 fact)
        external view override
        returns(bool)
    {

        return gpsContract.isValid(keccak256(abi.encode(programHash, fact)));
    }


    function hasRegisteredFact()
        external view override
        returns(bool)
    {

        return gpsContract.hasRegisteredFact();
    }
}
pragma solidity ^0.6.11;


contract FinalizableGpsFactAdapter is GpsFactRegistryAdapter , Finalizable {


    constructor(IQueryableFactRegistry gpsStatementContract, uint256 programHash_)
        public
        GpsFactRegistryAdapter(gpsStatementContract, programHash_)
    {
    }

    function setProgramHash(uint256 newProgramHash)
        external
        notFinalized
        onlyAdmin
    {

        programHash = newProgramHash;
    }

    function identify() external override pure returns (string memory) {

        return "StarkWare_FinalizableGpsFactAdapterForTesting_2021_1";
    }
}
