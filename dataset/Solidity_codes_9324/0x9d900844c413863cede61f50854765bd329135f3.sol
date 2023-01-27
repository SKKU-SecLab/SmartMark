pragma solidity ^0.5.0;

contract LotFactoryInterface {

    function createLot(
        address _organization,
        string memory _name)
    public
    returns(
        address);


    function createSubLot(
        address _organization,
        address _parentLot,
        string memory _name,
        uint32 _totalSupply,
        address _nextPermitted)
    public
    returns (
        address);

}
pragma solidity ^0.5.0;

contract LotInterface {

    function getOrganization() public view returns (address);

    function allocateSupply(address _lotAddress, uint32 _quantity) public;

}
pragma solidity ^0.5.0;

contract OrganizationInterface {

    function hasPermissions(address permittee, uint256 permission) public view returns (bool);

}
pragma solidity ^0.5.0;

contract PermissionsEnum {

    enum Permissions {
        CREATE_LOT,
        CREATE_SUB_LOT,
        UPDATE_LOT,
        TRANSFER_LOT_OWNERSHIP,
        ALLOCATE_SUPPLY
    }
}
pragma solidity ^0.5.0;



contract Lot is PermissionsEnum, LotInterface {

    address public factory;

    address public organization;
    address public parentLot;
    address public nextPermitted;

    string public infoFileHash;
    string public name;

    uint32 public totalSupply;
    uint32 public transferredSupply;

    mapping(address => uint32) public supplyDistributionInfo;

    enum LotState {
        NEW,
        INITIAL,
        GROW,
        HARVEST,
        EXTRACTING,
        EXTRACTED,
        TESTING,
        TESTED,
        PRODUCT,
        COMPLETE
    }

    LotState public state;

    event LotTotalSupplyConfigured (
        address organization,
        address lot,
        uint32 totalSupply
    );

    event LotNextPermittedChanged (
        address lot,
        address permitted
    );

    event LotStateChanged (
        address organization,
        address lot,
        uint previousState,
        uint nextState,
        string infoFileHash
    );

    event LotOwnershipTransferred (
        address lot,
        address currentOwner,
        address newOwner
    );

    modifier hasPermission(Permissions perm) {

        require(OrganizationInterface(organization).hasPermissions(msg.sender, uint256(perm)), "Not Allowed");
        _;
    }

    constructor(
        address _organization,
        address _factory,
        string memory _name,
        uint32 _totalSupply,
        address _parentLot,
        address _permitted)
    public {
        organization = _organization;
        factory = _factory;

        name = _name;
        totalSupply = _totalSupply;
        parentLot = _parentLot;
        initLot(0);

        nextPermitted = _permitted;
        if (_permitted != address(0)) {
            emit LotNextPermittedChanged(address(this), _permitted);
        }
    }

    function getOrganization() public view returns (address) {

        return organization;
    }

    function _getSubmittingOrganization(Permissions perm) internal view returns (address) {

        if (nextPermitted != address(0) && OrganizationInterface(nextPermitted).hasPermissions(msg.sender, uint256(perm))) return nextPermitted;

        if (OrganizationInterface(organization).hasPermissions(msg.sender, uint256(perm))) return organization;

        return address(0);
    }

    function changeLotState(
        uint _nextState,
        string memory _infoFileHash
    )
    public
    {

        address submittingOrganization = _getSubmittingOrganization(Permissions.UPDATE_LOT);
        require(submittingOrganization != address(0), "Not Allowed");

        uint previousState = uint(state);
        require(_nextState != previousState, "Cannot submit the same state over");
        
        state = LotState(_nextState);
        infoFileHash = _infoFileHash;

        nextPermitted = address(0);

        emit LotStateChanged(submittingOrganization, address(this), previousState, _nextState, _infoFileHash);
    }

    function changeLotStateWithNextPermitted(
        uint _nextState,
        string memory _infoFileHash,
        address _permitted
    )
    public
    {

        address submittingOrganization = _getSubmittingOrganization(Permissions.UPDATE_LOT);
        require(submittingOrganization != address(0), "Not Allowed");

        uint previousState = uint(state);
        require(_nextState != previousState, "Cannot submit the same state over");

        state = LotState(_nextState);
        infoFileHash = _infoFileHash;

        nextPermitted = _permitted;

        emit LotStateChanged(submittingOrganization, address(this), previousState, _nextState, _infoFileHash);
        emit LotNextPermittedChanged(address(this), _permitted);
    }

    function setLotState(uint _lotState)
    public
    {

        address submittingOrganization = _getSubmittingOrganization(Permissions.UPDATE_LOT);
        require(submittingOrganization != address(0), "Not Allowed");

        uint previousState = uint256(state);

        state = LotState(_lotState);

        emit LotStateChanged(submittingOrganization, address(this), previousState, _lotState, infoFileHash);
    }

    function setInfoFileHash(string memory _infoFileHash)
    public
    {

        address submittingOrganization = _getSubmittingOrganization(Permissions.UPDATE_LOT);
        require(submittingOrganization != address(0), "Not Allowed");

        infoFileHash = _infoFileHash;
    }

    function setTotalSupply(uint32 _totalSupply)
    public
    hasPermission(Permissions.UPDATE_LOT)
    {

        require(totalSupply == 0, "Total supply already set");

        totalSupply = _totalSupply;

        emit LotTotalSupplyConfigured(organization, address(this), _totalSupply);
    }

    function setNextPermitted(address _permitted)
    public
    hasPermission(Permissions.UPDATE_LOT)
    {

        nextPermitted = _permitted;
        emit LotNextPermittedChanged(address(this), _permitted);
    }

    function transferOwnership(address _newOwner)
    public
    hasPermission(Permissions.TRANSFER_LOT_OWNERSHIP)
    returns (bool)
    {

        address currentOwner = organization;
        organization = _newOwner;

        emit LotOwnershipTransferred(address(this), currentOwner, _newOwner);
        return true;
    }

    function retrieveFileHash()
    public
    view
    returns (string memory)
    {

        return infoFileHash;
    }

    function retrieveState()
    public
    view
    returns (uint)
    {

        return uint(state);
    }

    function retrieveTotalSupply()
    public
    view
    returns (uint32)
    {

        return totalSupply;
    }

    function retrieveTransferredSupply()
    public
    view
    returns (uint32)
    {

        return transferredSupply;
    }

    function retrieveSubLotSupply(address _lotAddress)
    public
    view
    returns (uint32)
    {

        return supplyDistributionInfo[_lotAddress];
    }

    function initLot(
        uint _lotState
    )
    private
    {

        state = LotState(_lotState);
    }

    function allocateSupply(address _lotAddress, uint32 _quantity)
    public
    hasPermission(Permissions.ALLOCATE_SUPPLY)
    {

        require((transferredSupply + _quantity) <= totalSupply, "Cannot allocate supply, exceeds total supply");
        supplyDistributionInfo[_lotAddress] = _quantity;
        transferredSupply += _quantity;
    }
}
pragma solidity ^0.5.0;



contract LotFactory is PermissionsEnum, LotFactoryInterface {

    event LotCreated (
        address organization,
        address lot,
        string name
    );

    event SubLotCreated (
        address organization,
        address lot,
        address parentLot,
        string name,
        uint32 totalSupply
    );

    function createLot(
        address _organization,
        string memory _name)
    public 
    returns (address) 
    {

        require(OrganizationInterface(_organization).hasPermissions(msg.sender, uint256(Permissions.CREATE_LOT)), "Not Allowed");

        address lot = _createLot(_organization, _name, 0, address(0), address(0));

        emit LotCreated(_organization, lot, _name);
        return lot;
    }

    function createSubLot(
        address _organization,
        address _parentLot,
        string memory _name,
        uint32 _totalSupply,
        address _nextPermitted)
    public
    returns (address)
    {

        require(OrganizationInterface(_organization).hasPermissions(msg.sender, uint256(Permissions.CREATE_SUB_LOT)), "Not Allowed");
        require(LotInterface(_parentLot).getOrganization() == _organization, "Lot does not belong to the organization");
        require(_totalSupply > 0, "Total supply must be greater than 0");

        address lot = _createLot(_organization, _name, _totalSupply, _parentLot, _nextPermitted);
        LotInterface(_parentLot).allocateSupply(lot, _totalSupply);

        emit SubLotCreated(_organization, lot, _parentLot, _name, _totalSupply);
        return lot;
    }

    function _createLot(
        address _organization,
        string memory _name,
        uint32 _totalSupply,
        address _parentLot,
        address _nextPermitted
    ) internal returns (address) {

        return address (new Lot(_organization, address(this), _name, _totalSupply, _parentLot, _nextPermitted));
    }
}
