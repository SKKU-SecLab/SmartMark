pragma solidity ^0.5.0;

interface OrganizationFactoryInterface {

    function createOrganization(address lotFactory, address owner, bool isActive) external returns (address);

}pragma solidity ^0.5.0;


contract Application {


    struct OrganizationOwner {
        address organizationAddress;
        address organizationOwner;
        bool isActive;
    }

    address public lotFactory;
    address public applicationOwner;
    address[] public organizations;
    address[] public organizationOwners;
    OrganizationFactoryInterface public organizationFactory;

    mapping(address => OrganizationOwner) public organizationOwnersMap;

    event OrganizationCreated (
        address organization,
        address owner,
        address lotFactory
    );

    event OrganizationRemoved (
        address organization,
        address owner
    );

    event DefaultLotFactoryChanged (
        address oldLotFactory,
        address newLotFactory
    );
    
    event OrganizationFactoryChanged (
        address oldOrganizationFactory,
        address newOrganizationFactory
    );
    
    modifier onlyOwnerAccess() {

        require(msg.sender == applicationOwner,  "Only Owner accessible");
        _;
    }

    constructor(address _organizationFactory, address _lotFactory) public {
        applicationOwner = msg.sender;
        organizationFactory = OrganizationFactoryInterface(_organizationFactory);
        lotFactory = _lotFactory;
    }

    function setLotFactory(address _newLotFactory)
    public
    onlyOwnerAccess
    returns (address) {

        address _oldLotFactory = lotFactory;
        lotFactory = _newLotFactory;
        emit DefaultLotFactoryChanged(_oldLotFactory, lotFactory);
    }

    function setOrganizationFactory(address _newOrgFactory)
    public
    onlyOwnerAccess
    returns (address) {

        address _oldOrgFactory = address(organizationFactory);
        organizationFactory = OrganizationFactoryInterface(_newOrgFactory);
        emit OrganizationFactoryChanged(_oldOrgFactory, address(organizationFactory));
    }

    function createOrganization(
        address _organizationOwner
    )
    public
    onlyOwnerAccess
    returns (address)
    {

        return createOrganization(_organizationOwner,lotFactory);
    }

    function createOrganization(
        address _organizationOwner,
        address _lotFactory
    )
    public
    onlyOwnerAccess
    returns (address)
    {

        address newOrgAddress = organizationFactory.createOrganization( _lotFactory,_organizationOwner, true);
        organizationOwners.push(_organizationOwner);
        organizations.push(newOrgAddress);
        organizationOwnersMap[_organizationOwner] = OrganizationOwner(
            newOrgAddress,
            _organizationOwner,
            true
        );

        emit OrganizationCreated(newOrgAddress, _organizationOwner, _lotFactory);

        return newOrgAddress;
    }

    function getOrganizations()
    public
    view
    returns (address[] memory) {

        return organizations;
    }

    function removeOrganization(address _organization)
    public
    onlyOwnerAccess
    {

        organizationOwnersMap[_organization].isActive = false;

        emit OrganizationRemoved(_organization, msg.sender);
    }

    function getOrganization(address _organization)
    public view
    returns (address, bool)
    {

        return (organizationOwnersMap[_organization].organizationOwner, organizationOwnersMap[_organization].isActive);
    }
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
pragma solidity ^0.5.0;

contract Migrations {

    address public owner;
    uint public last_completed_migration;

    modifier restricted() {

        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setCompleted(uint completed) public restricted {

        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {

        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
pragma solidity ^0.5.0;



contract Organization is OrganizationInterface, PermissionsEnum {


    address public lotFactory;

    mapping(address => bool) public adminDevices;

    mapping(address => bool) public permittedDevices;

    bool public isActive;

    event DeviceAdded (
        address device
    );

    event DeviceRemoved (
        address device
    );

    event AdminDeviceAdded (
        address device
    );

    event AdminDeviceRemoved (
        address device
    );

    event LotFactoryChanged (
        address oldFactory,
        address newFactory
    );

    modifier onlyOwnerAccess() {

        require(isAdminDevice(msg.sender), "Only admin device accesible");
        _;
    }

    modifier onlyPermittedAccess() {

        require(isPermittedDevice(msg.sender), "Only permitted device accesible");
        _;
    }

    constructor(
        address _lotFactory,
        address _organizationOwner,
        bool _isActive
    )
    public {
        lotFactory = _lotFactory;

        isActive = _isActive;

        _permitAdminDevice(_organizationOwner);
    }
    
    function organizationInfo()
    public
    view
    returns (bool status) {

        status = isActive;
    }

    function isAdminDevice(address _device)
    public
    view
    returns (bool deviceAdmin)
    {

        return adminDevices[_device];
    }

    function isPermittedDevice(address _device)
    public
    view
    returns (bool devicePermitted)
    {

        return (permittedDevices[_device] || adminDevices[_device]);
    }

    function setLotFactory(address _lotFactory)
    public
    onlyOwnerAccess
    {

        address oldFactory = lotFactory;
        lotFactory = _lotFactory;

        emit LotFactoryChanged(oldFactory, _lotFactory);
    }

    function permitDevice(address _deviceAddress)
    public
    onlyOwnerAccess
    returns (bool devicePermitted)
    {

        return _permitDevice(_deviceAddress);
    }

    function removeDevice(address _deviceAddress)
    public
    onlyOwnerAccess
    returns (bool devicePermitted)
    {

        return _removeDevice(_deviceAddress);
    }

    function _permitDevice(address _deviceAddress)
    private
    returns (bool devicePermitted)
    {

        permittedDevices[_deviceAddress] = true;

        emit DeviceAdded(_deviceAddress);
        return true;
    }

    function _removeDevice(address _deviceAddress)
    private

    returns (bool devicePermitted)
    {

        permittedDevices[_deviceAddress] = false;

        emit DeviceRemoved(_deviceAddress);
        return true;
    }

    function permitAdminDevice(address _deviceAddress)
    public
    onlyOwnerAccess
    returns (bool deviceAdmin)
    {

        return _permitAdminDevice(_deviceAddress);
    }

    function removeAdminDevice(address _deviceAddress)
    public
    onlyOwnerAccess
    returns (bool deviceAdmin)
    {

        return _removeAdminDevice(_deviceAddress);
    }

    function _permitAdminDevice(address _deviceAddress)
    private
    returns (bool deviceAdmin)
    {

        adminDevices[_deviceAddress] = true;
        permittedDevices[_deviceAddress] = true;

        emit AdminDeviceAdded(_deviceAddress);
        return true;
    }

    function _removeAdminDevice(address _deviceAddress)
    private
    returns (bool deviceAdmin)
    {

        adminDevices[_deviceAddress] = false;
        permittedDevices[_deviceAddress] = false;

        emit AdminDeviceRemoved(_deviceAddress);
        return true;
    }
    

    function hasPermissions(address permittee, uint256 permission)
    public
    view
    returns (bool)
    {

        if (permittee == address(this)) return true;

        if (permission == uint256(Permissions.CREATE_LOT)) return isPermittedDevice(permittee);
        if (permission == uint256(Permissions.CREATE_SUB_LOT)) return isPermittedDevice(permittee);
        if (permission == uint256(Permissions.UPDATE_LOT)) return isPermittedDevice(permittee);
        if (permission == uint256(Permissions.TRANSFER_LOT_OWNERSHIP)) return isPermittedDevice(permittee);
        if (permission == uint256(Permissions.ALLOCATE_SUPPLY)) return permittee == address(lotFactory);

        return false;
    }
}
pragma solidity ^0.5.0;


contract OrganizationFactory is OrganizationFactoryInterface {


    function createOrganization(address _lotFactory, address _organizationOwner, bool _isActive) public returns (address) {

        Organization organization = new Organization( _lotFactory, _organizationOwner, _isActive);
        return address(organization);
    }
} 
