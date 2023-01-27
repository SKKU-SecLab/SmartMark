
pragma solidity ^0.5.10;

contract iInventory {

    
    function createFromTemplate(
        uint256 _templateId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        public
        returns(uint256);


}

contract DistributeItems is iInventory {

    
    modifier onlyAdmin() {

        require(admin == msg.sender, "DISTRIBUTE_ITEMS: Caller is not admin");
        _;
    }
    
    modifier allowedItem(uint256 _templateId) {

        require(allowed[msg.sender][_templateId], "DISTRIBUTE_ITEMS: Caller is not allowed to claim item");
        _;
    }
    
    modifier checkDistEndTime(uint256 _templateId) {

        if(distEndTime[_templateId] != 0) {
            require(distEndTime[_templateId] >= now, "DISTRIBUTE_ITEMS: Distribution for item has ended");
        }
        _;
    }
    
    modifier checkHardCap(uint256 _templateId) {

        if(hardCap[_templateId] != 0) {
            require(amtClaimed[_templateId] < hardCap[_templateId], "DISTRIBUTE_ITEMS: Hard cap for item reached");
        }
        _;
    }
    
    modifier checkIfClaimed(uint256 _templateId) {

        require(!claimed[_templateId][msg.sender], "DISTRIBUTE_ITEMS: Player has already claimed item");
        _;
    }
    
    iInventory inv = iInventory(0x9680223F7069203E361f55fEFC89B7c1A952CDcc);
    
    address private admin;
    
    mapping (address => mapping(uint256 => bool)) public allowed;
    
    mapping (uint256 => uint256) public distEndTime;
    
    mapping (uint256 => uint256) public hardCap;
    
    mapping (uint256 => uint256) public amtClaimed;
    
    mapping (uint256 => mapping(address => bool)) public claimed;

    constructor() public {
        admin = msg.sender;
    }
    
    function addItemAllowance(
        address _player,
        uint256 _templateId,
        bool _allowed
    )
        external
        onlyAdmin
    {

        allowed[_player][_templateId] = _allowed;
    }
    
    function addItemAllowanceForAll(
        address[] calldata _players,
        uint256 _templateId,
        bool _allowed
    )
        external
        onlyAdmin
    {

        for(uint i = 0; i < _players.length; i++) {
            allowed[_players[i]][_templateId] = _allowed;
        }
    }
    
    function addTimedItem(
        uint256 _templateId,
        uint256 _distEndTime,
        uint256 _hardCap
    )
        external
        onlyAdmin
    {

        if(_hardCap > 0) {
            hardCap[_templateId] = _hardCap;
        }
        
        if(_distEndTime > now) {
            distEndTime[_templateId] = _distEndTime;
        }
        
    }
    
    function claimItem(
        uint256 _templateId,
        uint8 _equipmentPosition
    )
        external
        allowedItem(_templateId)
    {

        allowed[msg.sender][_templateId] = false;
        
        inv.createFromTemplate(
            _templateId,
            0,
            0,
            0,
            0,
            _equipmentPosition
        );
    }
    
    function claimTimedItem(
        uint256 _templateId,
        uint8 _equipmentPosition
    )
        external
        checkDistEndTime(_templateId)
        checkHardCap(_templateId)
        checkIfClaimed(_templateId)
    {

        if(hardCap[_templateId] != 0) {
            amtClaimed[_templateId]++;
        }
        
        claimed[_templateId][msg.sender] = true;
        
        inv.createFromTemplate(
            _templateId,
            0,
            0,
            0,
            0,
            _equipmentPosition
        );
    }
    
    function createFromTemplate(
        uint256 _templateId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        public
        returns(uint256)
    {

    }
    
}