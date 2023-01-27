
pragma solidity >=0.5.0 <0.7.0;

contract Whitelist
{


    uint256 groupId;
    address public whiteListManager;
    struct WhitelistGroup
    {
        mapping(address => bool) members;
        address whitelistGroupAdmin;
        bool created;
    }
    mapping(uint256 => WhitelistGroup) private whitelistGroups;
    event GroupCreated(address, uint256);

    constructor() public
    {
        whiteListManager = msg.sender;
    }

    modifier onlyWhitelistManager{

        require(msg.sender == whiteListManager, "Only Whitelist manager can call this function.");
        _;
    }

    function changeManager(address _manager) 
        public 
        onlyWhitelistManager
    {

        whiteListManager = _manager;
    }

    function _isGroup(uint256 _groupId) 
        private 
        view 
        returns(bool)
    {

        return whitelistGroups[_groupId].created;
    }

    function _isGroupAdmin(uint256 _groupId) 
        private 
        view 
        returns(bool)
    {

        return whitelistGroups[_groupId].whitelistGroupAdmin == msg.sender;
    }

    function createGroup(address _whitelistGroupAdmin) 
        public
        returns(uint256) 
    {

        groupId += 1;
        require(!whitelistGroups[groupId].created, "Group already exists");
        WhitelistGroup memory newGroup = 
        WhitelistGroup({ whitelistGroupAdmin : _whitelistGroupAdmin, created : true });
        whitelistGroups[groupId] = newGroup;
        whitelistGroups[groupId].members[_whitelistGroupAdmin] = true;
        whitelistGroups[groupId].members[msg.sender] = true;
        emit GroupCreated(msg.sender, groupId);
        return groupId;
    }

    function deleteGroup(uint256 _groupId) 
        public 
    {

        require(_isGroup(_groupId), "Group doesn't exist!");
        require(_isGroupAdmin(_groupId), "Only Whitelist Group admin is permitted for this operation");
        delete whitelistGroups[_groupId];
    }

    function addMembersToGroup(uint256 _groupId, address[] memory _memberAddress) 
        public
    {

        require(_isGroup(_groupId), "Group doesn't exist!");
        require(_isGroupAdmin(_groupId), "Only goup admin is permitted for this operation");

        for (uint256 i = 0; i < _memberAddress.length; i++) 
        {
            whitelistGroups[_groupId].members[_memberAddress[i]] = true;
        }
    }

    function removeMembersFromGroup(uint256 _groupId, address[] memory _memberAddress) 
        public
    {

        require(_isGroup(_groupId), "Group doesn't exist!");
        require(_isGroupAdmin(_groupId), "Only Whitelist Group admin is permitted for this operation");

        for (uint256 i = 0; i < _memberAddress.length; i++) 
        {
            whitelistGroups[_groupId].members[_memberAddress[i]] = false;
        }
    }

    function isMember(uint256 _groupId, address _memberAddress) 
        public 
        view 
        returns(bool)
    {

        require(_isGroup(_groupId), "Group doesn't exist!");
        return whitelistGroups[_groupId].members[_memberAddress];
    }

    function getWhitelistAdmin(uint256 _groupId)
        public
        view
        returns(address)
    {

        require(_isGroup(_groupId), "Group doesn't exist!");
        return whitelistGroups[_groupId].whitelistGroupAdmin;
    }

    function changeWhitelistAdmin(uint256 _groupId, address _whitelistGroupAdmin)
        public
    {

        require(_isGroup(_groupId), "Group doesn't exist!");
        require(whitelistGroups[_groupId].whitelistGroupAdmin == msg.sender, "Only existing whitelist admin can perform this operation");
        whitelistGroups[_groupId].whitelistGroupAdmin = _whitelistGroupAdmin;
    }

}