
pragma solidity ^0.4.19;


contract theCyberInterface {

  function newMember(uint8 _memberId, bytes32 _memberName, address _memberAddress) public;

  function getMembershipStatus(address _memberAddress) public view returns (bool member, uint8 memberId);

  function getMemberInformation(uint8 _memberId) public view returns (bytes32 memberName, string memberKey, uint64 memberSince, uint64 inactiveSince, address memberAddress);

}


contract theCyberGatekeeperTwoInterface {

  function entrants(uint256 i) public view returns (address);

  function totalEntrants() public view returns (uint8);

}


contract theCyberAssigner {


  address private constant THECYBERADDRESS_ = 0x97A99C819544AD0617F48379840941eFbe1bfAE1;

  address private constant THECYBERGATEKEEPERADDRESS_ = 0xbB902569a997D657e8D10B82Ce0ec5A5983C8c7C;

  uint8 private constant MAXENTRANTS_ = 128;

  bool private active_ = true;

  uint8 private nextAssigneeIndex_;

  function assignAll() public returns (bool) {

    require(active_);

    require(msg.gas > 6000000);

    uint8 totalEntrants = theCyberGatekeeperTwoInterface(THECYBERGATEKEEPERADDRESS_).totalEntrants();
    require(totalEntrants >= MAXENTRANTS_);

    bool member;
    address memberAddress;

    (member,) = theCyberInterface(THECYBERADDRESS_).getMembershipStatus(this);
    require(member);
    
    uint8 i = nextAssigneeIndex_;

    while (i < MAXENTRANTS_ && msg.gas > 200000) {
      address entrant = theCyberGatekeeperTwoInterface(THECYBERGATEKEEPERADDRESS_).entrants(i);

      (member,) = theCyberInterface(THECYBERADDRESS_).getMembershipStatus(entrant);

      (,,,,memberAddress) = theCyberInterface(THECYBERADDRESS_).getMemberInformation(i + 1);
      
      if ((entrant != address(0)) && (!member) && (memberAddress == address(0))) {
        theCyberInterface(THECYBERADDRESS_).newMember(i + 1, bytes32(""), entrant);
      }

      i++;
    }

    nextAssigneeIndex_ = i;
    if (nextAssigneeIndex_ >= MAXENTRANTS_) {
      active_ = false;
    }

    return true;
  }

  function nextAssigneeIndex() public view returns(uint8) {

    return nextAssigneeIndex_;
  }

  function maxEntrants() public pure returns(uint8) {

    return MAXENTRANTS_;
  }
}