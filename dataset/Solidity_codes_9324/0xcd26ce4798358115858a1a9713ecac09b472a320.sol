
pragma solidity ^0.4.19;


contract ERC20 {

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

}


contract theCyberInterface {

  function newMember(uint8 _memberId, bytes32 _memberName, address _memberAddress) public;

  function proclaimInactive(uint8 _memberId) public;

  function heartbeat() public;

  function revokeMembership(uint8 _memberId) public;

  function getMembershipStatus(address _memberAddress) public view returns (bool member, uint8 memberId);

  function getMemberInformation(uint8 _memberId) public view returns (bytes32 memberName, string memberKey, uint64 memberSince, uint64 inactiveSince, address memberAddress);

  function maxMembers() public pure returns(uint16);

  function inactivityTimeout() public pure returns(uint64);

  function donationAddress() public pure returns(address);

}


contract theCyberMemberUtilities {


  event MembershipStatusSet(bool isMember, uint8 memberId);
  event FundsDonated(uint256 value);
  event TokensDonated(address tokenContractAddress, uint256 value);

  address private constant THECYBERADDRESS_ = 0x97A99C819544AD0617F48379840941eFbe1bfAE1;
  theCyberInterface theCyber = theCyberInterface(THECYBERADDRESS_);

  bool private isMember_;
  uint8 private memberId_;

  uint16 private maxMembers_;
  uint64 private inactivityTimeout_;
  address private donationAddress_;

  uint8 private nextInactiveMemberIndex_;
  uint8 private nextRevokedMemberIndex_;

  modifier membersOnly() {

    bool member;
    (member,) = theCyber.getMembershipStatus(msg.sender);
    require(member);
    _;
  }

  function theCyberMemberUtilities() public {

    maxMembers_ = theCyber.maxMembers();

    inactivityTimeout_ = theCyber.inactivityTimeout();

    donationAddress_ = theCyber.donationAddress();

    isMember_ = false;

    nextInactiveMemberIndex_ = 0;

    nextRevokedMemberIndex_ = 0;
  }

  function setMembershipStatus() public membersOnly {

    (isMember_,memberId_) = theCyber.getMembershipStatus(this);

    MembershipStatusSet(isMember_, memberId_);
  }

  function heartbeat() public membersOnly {

    theCyber.heartbeat();
  }

  function revokeAndSetNewMember(uint8 _memberId, bytes32 _memberName, address _memberAddress) public membersOnly {

    theCyber.revokeMembership(_memberId);

    theCyber.newMember(_memberId, _memberName, _memberAddress);
  }

  function proclaimAllInactive() public membersOnly returns (bool complete) {

    require(isMember_);

    uint8 callingMemberId;
    (,callingMemberId) = theCyber.getMembershipStatus(msg.sender);

    uint64 inactiveSince;
    address memberAddress;
    
    uint8 i = nextInactiveMemberIndex_;

    require(msg.gas > 175000);

    while (msg.gas > 170000) {
      (,,,inactiveSince,memberAddress) = theCyber.getMemberInformation(i);
      if ((i != memberId_) && (i != callingMemberId) && (memberAddress != address(0)) && (inactiveSince == 0)) {
        theCyber.proclaimInactive(i);
      }
      i++;

      if (i == 0) {
        break;
      }
    }

    nextInactiveMemberIndex_ = i;
    return (i == 0);
  }

  function inactivateSelf() public membersOnly {

    uint8 memberId;
    (,memberId) = theCyber.getMembershipStatus(msg.sender);

    theCyber.proclaimInactive(memberId);
  }

  function revokeAllVulnerable() public membersOnly returns (bool complete) {

    require(isMember_);

    uint8 callingMemberId;
    (,callingMemberId) = theCyber.getMembershipStatus(msg.sender);

    uint64 inactiveSince;
    address memberAddress;
    
    uint8 i = nextRevokedMemberIndex_;

    require(msg.gas > 175000);

    while (msg.gas > 175000) {
      (,,,inactiveSince,memberAddress) = theCyber.getMemberInformation(i);
      if ((i != memberId_) && (i != callingMemberId) && (memberAddress != address(0)) && (inactiveSince != 0) && (now >= inactiveSince + inactivityTimeout_)) {
        theCyber.revokeMembership(i);
      }
      i++;

      if (i == 0) {
        break;
      }
    }

    nextRevokedMemberIndex_ = i;
    return (i == 0);
  }

  function revokeSelf() public membersOnly {

    uint8 memberId;
    (,memberId) = theCyber.getMembershipStatus(msg.sender);

    theCyber.revokeMembership(memberId);
  }

  function donateFunds() public membersOnly {

    FundsDonated(this.balance);

    donationAddress_.transfer(this.balance);
  }

  function donateTokens(address _tokenContractAddress) public membersOnly {

    require(_tokenContractAddress != address(this));

    TokensDonated(_tokenContractAddress, ERC20(_tokenContractAddress).balanceOf(this));

    ERC20(_tokenContractAddress).transfer(donationAddress_, ERC20(_tokenContractAddress).balanceOf(this));
  }

  function donationAddress() public view returns(address) {

    return donationAddress_;
  }
}