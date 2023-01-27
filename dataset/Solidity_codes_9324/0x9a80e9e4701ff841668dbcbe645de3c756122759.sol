pragma solidity 0.5.0;

contract IHasAdmin {


    function isAdmin(address accountAddress) public view returns (bool);


}pragma solidity 0.5.0;


contract Secured is IHasAdmin {


    uint256 private _count;
    mapping(address => bool) private _admins;

    constructor() public {
        _count = 1;
        _admins[msg.sender] = true;
    }

    modifier onlyAdmin() {

        require(_admins[msg.sender]);
        _;
    }

    function isAdmin(address accountAddress) public view returns (bool)
    {

        return _admins[accountAddress];
    }

    function addAdmin(address accountAddress) public onlyAdmin {

        require(!_admins[accountAddress]);
        _count++;
        _admins[accountAddress] = true;
    }

    function removeAdmin(address accountAddress) public onlyAdmin {

        require(_count > 1);
        require(_admins[accountAddress]);
        _count--;
        delete _admins[accountAddress];
    }

    function transferAdmin(address fromAddress, address toAddress) public onlyAdmin {

        require(_admins[fromAddress]);
        require(!_admins[toAddress]);
        delete _admins[fromAddress];
        _admins[toAddress] = true;
    }
}pragma solidity 0.5.0;


contract SecuredSwitchable is Secured {


    bool private _isEnabled;

    modifier onlyEnabled() {

        require(_isEnabled);
        _;
    }

    function isEnabled() public view returns (bool) {

        return _isEnabled;
    }

    function setEnabled() public onlyAdmin {

        require(!_isEnabled);
        _isEnabled = true;
    }

    function setDisabled() public onlyAdmin {

        require(_isEnabled);
        _isEnabled = false;
    }
}
pragma solidity 0.5.0;


contract CentralSecuritiesDepository is SecuredSwitchable {


    struct CertificationTicket {
        bool registered;
        bytes32 ticketHash;
        uint256 timestamp;
    }

      struct PromissoryNoteTicket {
        bool registered;
        bytes32 ticketHash;
        uint256 timestamp;
    }
   
    bytes32 private _metadataHash;

    mapping(uint64 => CertificationTicket) private _certificationTickets;
    mapping(uint256 => PromissoryNoteTicket) private _promissoryNoteTickets;

    constructor(bytes32 metadataHash) public {
        _metadataHash = metadataHash;
    }

    function getMetadataHash() public view returns (bytes32) {

        return _metadataHash;
    }

    function registerTicket(uint64 ticketId, bytes32 ticketHash) public onlyAdmin onlyEnabled {

        require(!_certificationTickets[ticketId].registered);
        _certificationTickets[ticketId].registered = true;
        _certificationTickets[ticketId].ticketHash = ticketHash;
        _certificationTickets[ticketId].timestamp = now;
    }

    function getTicketHash(uint64 ticketId) public view returns (bytes32) {

        return _certificationTickets[ticketId].ticketHash;
    }

    function getTicketTimestamp(uint64 ticketId) public view returns (uint256) {

        return _certificationTickets[ticketId].timestamp;
    }

    function registerPromissoryNoteTicket(uint8 category, uint64 ticketId, bytes32 ticketHash) public onlyAdmin onlyEnabled{

        uint256 pkey = ticketId | (category * 2**8);
        require(!_promissoryNoteTickets[pkey].registered);
        _promissoryNoteTickets[pkey].registered = true;
        _promissoryNoteTickets[pkey].ticketHash = ticketHash;
        _promissoryNoteTickets[pkey].timestamp = now;
    }

    function getPromissoryNoteTicketHash(uint8 category, uint64 ticketId) public view returns (bytes32) {

        uint256 pkey = ticketId | (category * 2**8);
        return _promissoryNoteTickets[pkey].ticketHash;
    }

    function getPromissoryNoteTicketTimestamp(uint8 category, uint64 ticketId) public view returns (uint256) {

        uint256 pkey = ticketId | (category * 2**8);
        return _promissoryNoteTickets[pkey].timestamp;
    }
}