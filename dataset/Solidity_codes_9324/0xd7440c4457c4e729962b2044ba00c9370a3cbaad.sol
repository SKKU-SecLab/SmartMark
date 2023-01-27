



pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}



pragma solidity 0.6.12;


contract TokensFarmCongressMembersRegistry {

    using SafeMath for *;

    string public constant name = "TokensFarmCongressMembersRegistry";

    event MembershipChanged(address member, bool isMember);

    address public tokensFarmCongress;

    uint256 minimalQuorum;

    mapping (address => bool) isMemberInCongress;

    mapping(address => Member) public address2Member;

    address[] public allMembers;

    struct Member {
        bytes32 name;
        uint memberSince;
    }

    modifier onlyTokensFarmCongress {

        require(msg.sender == tokensFarmCongress);
        _;
    }

    constructor(
        address[] memory initialCongressMembers,
        bytes32[] memory initialCongressMemberNames,
        address _tokensFarmCongress
    )
        public
    {
        uint length = initialCongressMembers.length;

        for(uint i=0; i<length; i++) {
            addMemberInternal(
                initialCongressMembers[i],
                initialCongressMemberNames[i]
            );
        }

        tokensFarmCongress = _tokensFarmCongress;
    }

    function changeMinimumQuorum(
        uint newMinimumQuorum
    )
       external
       onlyTokensFarmCongress
    {

        require(
            newMinimumQuorum > 0,
            "Minimum quorum must be higher than 0"
        );

        minimalQuorum = newMinimumQuorum;
    }

    function addMember(
        address targetMember,
        bytes32 memberName
    )
        external
        onlyTokensFarmCongress
    {

        require(
            targetMember != address(0x0),
            "Target member can not be 0x0 address"
        );
        addMemberInternal(targetMember, memberName);
    }


    function addMemberInternal(
        address targetMember,
        bytes32 memberName
    )
        internal
    {

        require(!isMemberInCongress[targetMember], "Member already exists");
        address2Member[targetMember] = Member({
        memberSince: block.timestamp,
        name: memberName
        });
        allMembers.push(targetMember);
        minimalQuorum = allMembers.length.sub(1);
        isMemberInCongress[targetMember] = true;
        emit MembershipChanged(targetMember, true);
    }

    function removeMember(
        address targetMember
    )
        external
        onlyTokensFarmCongress
    {

        require(isMemberInCongress[targetMember], "Member does not exits");

        uint length = allMembers.length;

        uint i=0;

        while(allMembers[i] != targetMember) {
            if(i == length) {
                revert();
            }
            i++;
        }

        allMembers[i] = allMembers[length-1];

        allMembers.pop();

        isMemberInCongress[targetMember] = false;

        address2Member[targetMember] = Member({
        memberSince: block.timestamp,
        name: "0x0"
        });

        minimalQuorum = minimalQuorum.sub(1);

        emit MembershipChanged(targetMember, false);
    }

    function isMember(
        address _address
    )
        external
        view
        returns (bool)
    {

        return isMemberInCongress[_address];
    }

    function getNumberOfMembers()
        external
        view
        returns (uint)
    {

        return allMembers.length;
    }

    function getAllMemberAddresses()
        external
        view
        returns (address[] memory)
    {

        return allMembers;
    }

    function getMemberInfo(
        address _member
    )
        external
        view
        returns (address, bytes32, uint)
    {

        Member memory member = address2Member[_member];
        return (
            _member,
            member.name,
            member.memberSince
        );
    }

    function getMinimalQuorum()
        external
        view
        returns (uint256)
    {

        return minimalQuorum;
    }
}