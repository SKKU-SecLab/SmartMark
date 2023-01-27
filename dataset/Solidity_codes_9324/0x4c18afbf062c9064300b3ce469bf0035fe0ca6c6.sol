
pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    require(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    require(c >= _a);
    return c;
  }
}

contract TwoKeyCongressMembersRegistry {


    using SafeMath for uint;

    event MembershipChanged(address member, bool isMember);

    address public TWO_KEY_CONGRESS;

    uint256 public maxVotingPower;
    uint256 public minimumQuorum;

    mapping (address => bool) public isMemberInCongress;
    mapping(address => Member) public address2Member;
    address[] public allMembers;

    struct Member {
        address memberAddress;
        bytes32 name;
        uint votingPower;
        uint memberSince;
    }

    modifier onlyTwoKeyCongress () {

        require(msg.sender == TWO_KEY_CONGRESS);
        _;
    }

    constructor(
        address[] initialCongressMembers,
        bytes32[] initialCongressMemberNames,
        uint[] memberVotingPowers,
        address _twoKeyCongress
    )
    public
    {
        uint length = initialCongressMembers.length;
        for(uint i=0; i<length; i++) {
            addMemberInternal(
                initialCongressMembers[i],
                initialCongressMemberNames[i],
                memberVotingPowers[i]
            );
        }
        TWO_KEY_CONGRESS = _twoKeyCongress;
    }

    function addMember(
        address targetMember,
        bytes32 memberName,
        uint _votingPower
    )
    public
    onlyTwoKeyCongress
    {

        addMemberInternal(targetMember, memberName, _votingPower);
    }

    function addMemberInternal(
        address targetMember,
        bytes32 memberName,
        uint _votingPower
    )
    internal
    {

        require(isMemberInCongress[targetMember] == false);
        minimumQuorum = allMembers.length;
        maxVotingPower = maxVotingPower.add(_votingPower);
        address2Member[targetMember] = Member(
            {
            memberAddress: targetMember,
            memberSince: block.timestamp,
            votingPower: _votingPower,
            name: memberName
            }
        );
        allMembers.push(targetMember);
        isMemberInCongress[targetMember] = true;
        emit MembershipChanged(targetMember, true);
    }

    function removeMember(
        address targetMember
    )
    public
    onlyTwoKeyCongress
    {

        require(isMemberInCongress[targetMember] == true);

        uint votingPower = getMemberVotingPower(targetMember);
        maxVotingPower-= votingPower;

        uint length = allMembers.length;
        uint i=0;
        while(allMembers[i] != targetMember) {
            if(i == length) {
                revert();
            }
            i++;
        }

        allMembers[i] = allMembers[length-1];

        delete allMembers[allMembers.length-1];

        uint newLength = allMembers.length.sub(1);
        allMembers.length = newLength;

        isMemberInCongress[targetMember] = false;

        address2Member[targetMember] = Member(
            {
                memberAddress: address(0),
                memberSince: block.timestamp,
                votingPower: 0,
                name: "0x0"
            }
        );
        minimumQuorum = minimumQuorum.sub(1);
    }

    function getMemberVotingPower(
        address _memberAddress
    )
    public
    view
    returns (uint)
    {

        Member memory _member = address2Member[_memberAddress];
        return _member.votingPower;
    }

    function isMember(
        address _address
    )
    public
    view
    returns (bool)
    {

        return isMemberInCongress[_address];
    }

    function getMembersLength()
    public
    view
    returns (uint)
    {

        return allMembers.length;
    }

    function getAllMemberAddresses()
    public
    view
    returns (address[])
    {

        return allMembers;
    }

    function getMemberInfo()
    public
    view
    returns (address, bytes32, uint, uint)
    {

        Member memory member = address2Member[msg.sender];
        return (member.memberAddress, member.name, member.votingPower, member.memberSince);
    }
}