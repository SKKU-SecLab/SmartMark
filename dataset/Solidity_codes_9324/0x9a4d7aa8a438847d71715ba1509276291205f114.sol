




pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.6.0 <0.8.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


pragma solidity 0.6.12;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function transfer(address _to, uint256 _amount) external returns (bool);

}

interface CvpInterface {

  function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

}

contract PPTimedVesting is CvpInterface, Ownable {

  using SafeMath for uint256;
  using SafeCast for uint256;

  event DisableMember(address indexed member, uint256 tokensRemainder);

  event Init(address[] members);

  event IncreaseDurationT(uint256 prevDurationT, uint256 prevEndT, uint256 newDurationT, uint256 newEndT);

  event IncreasePersonalDurationT(
    address indexed member,
    uint256 prevEvaluatedDurationT,
    uint256 prevEvaluatedEndT,
    uint256 prevPersonalDurationT,
    uint256 newPersonalDurationT,
    uint256 newPersonalEndT
  );

  event DelegateVotes(address indexed from, address indexed to, address indexed previousDelegate, uint96 adjustedVotes);

  event Transfer(
    address indexed from,
    address indexed to,
    uint96 alreadyClaimedVotes,
    uint96 alreadyClaimedTokens,
    address currentDelegate
  );

  event ClaimVotes(
    address indexed member,
    address indexed delegate,
    uint96 lastAlreadyClaimedVotes,
    uint96 lastAlreadyClaimedTokens,
    uint96 newAlreadyClaimedVotes,
    uint96 newAlreadyClaimedTokens,
    uint96 lastMemberAdjustedVotes,
    uint96 adjustedVotes,
    uint96 diff
  );

  event ClaimTokens(
    address indexed member,
    address indexed to,
    uint96 amount,
    uint256 newAlreadyClaimed,
    uint256 votesAvailable
  );

  event UnclaimedBalanceChanged(address indexed member, uint256 previousUnclaimed, uint256 newUnclaimed);

  struct Member {
    bool active;
    bool transferred;
    uint32 personalDurationT;
    uint96 alreadyClaimedVotes;
    uint96 alreadyClaimedTokens;
  }

  struct Checkpoint {
    uint32 fromBlock;
    uint96 votes;
  }

  address public immutable token;

  uint256 public immutable startV;

  uint256 public immutable durationV;

  uint256 public immutable endV;

  uint256 public immutable startT;

  uint256 public memberCount;

  uint96 public immutable amountPerMember;

  uint256 public durationT;

  uint256 public endT;

  mapping(address => Member) public members;

  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

  mapping(address => uint32) public numCheckpoints;

  mapping(address => address) public voteDelegations;

  constructor(
    address _tokenAddress,
    uint256 _startV,
    uint256 _durationV,
    uint256 _startT,
    uint256 _durationT,
    uint96 _amountPerMember
  ) public {
    require(_durationV > 1, "Vesting: Invalid durationV");
    require(_durationT > 1, "Vesting: Invalid durationT");
    require(_startV < _startT, "Vesting: Requires startV < startT");
    require((_startV.add(_durationV)) <= (_startT.add(_durationT)), "Vesting: Requires endV <= endT");
    require(_amountPerMember > 0, "Vesting: Invalid amount per member");
    require(IERC20(_tokenAddress).totalSupply() > 0, "Vesting: Missing supply of the token");

    token = _tokenAddress;

    startV = _startV;
    durationV = _durationV;
    endV = _startV + _durationV;

    startT = _startT;
    durationT = _durationT;
    endT = _startT + _durationT;

    amountPerMember = _amountPerMember;
  }

  function initializeMembers(address[] calldata _memberList) external onlyOwner {

    require(memberCount == 0, "Vesting: Already initialized");

    uint256 len = _memberList.length;
    require(len > 0, "Vesting: Empty member list");

    memberCount = len;

    for (uint256 i = 0; i < len; i++) {
      members[_memberList[i]].active = true;
    }

    emit Init(_memberList);
  }

  function hasVoteVestingStarted() external view returns (bool) {

    return block.timestamp >= startV;
  }

  function hasVoteVestingEnded() external view returns (bool) {

    return block.timestamp >= endV;
  }

  function hasTokenVestingStarted() external view returns (bool) {

    return block.timestamp >= startT;
  }

  function hasTokenVestingEnded() external view returns (bool) {

    return block.timestamp >= endT;
  }

  function getVoteUser(address _voteHolder) public view returns (address) {

    address currentDelegate = voteDelegations[_voteHolder];
    if (currentDelegate == address(0)) {
      return _voteHolder;
    }
    return currentDelegate;
  }

  function getLastCachedVotes(address _member) external view returns (uint256) {

    uint32 dstRepNum = numCheckpoints[_member];
    return dstRepNum > 0 ? checkpoints[_member][dstRepNum - 1].votes : 0;
  }

  function getPriorVotes(address account, uint256 blockNumber) external view override returns (uint96) {

    require(blockNumber < block.number, "Vesting::getPriorVotes: Not yet determined");

    uint32 nCheckpoints = numCheckpoints[account];

    Member memory member = members[account];

    if (member.transferred == true) {
      return 0;
    }

    if (block.timestamp > getLoadedMemberEndT(member) || block.timestamp > endT) {
      return 0;
    }

    if (nCheckpoints == 0 || checkpoints[account][0].fromBlock > blockNumber) {
      return 0;
    }

    if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
      return checkpoints[account][nCheckpoints - 1].votes;
    }

    uint32 lower = 0;
    uint32 upper = nCheckpoints - 1;
    while (upper > lower) {
      uint32 center = upper - (upper - lower) / 2;
      Checkpoint memory cp = checkpoints[account][center];
      if (cp.fromBlock == blockNumber) {
        return cp.votes;
      } else if (cp.fromBlock < blockNumber) {
        lower = center;
      } else {
        upper = center - 1;
      }
    }
    return checkpoints[account][lower].votes;
  }


  function getAvailableTokensForMemberAt(uint256 _atTimestamp, address _member) external view returns (uint256) {

    Member memory member = members[_member];
    if (member.active == false) {
      return 0;
    }

    return
      getAvailable(
        _atTimestamp,
        startT,
        amountPerMember,
        getLoadedMemberDurationT(member),
        member.alreadyClaimedTokens
      );
  }

  function getMemberEndT(address _member) external view returns (uint256) {

    return startT.add(getMemberDurationT(_member));
  }

  function getMemberDurationT(address _member) public view returns (uint256) {

    return getLoadedMemberDurationT(members[_member]);
  }

  function getLoadedMemberEndT(Member memory _member) internal view returns (uint256) {

    return startT.add(getLoadedMemberDurationT(_member));
  }

  function getLoadedMemberDurationT(Member memory _member) internal view returns (uint256) {

    uint256 _personalDurationT = uint256(_member.personalDurationT);
    if (_personalDurationT == 0) {
      return durationT;
    }

    return _personalDurationT;
  }

  function getAvailableTokensForMember(address _member) external view returns (uint256) {

    Member memory member = members[_member];
    if (member.active == false) {
      return 0;
    }

    return getAvailableTokens(member.alreadyClaimedTokens, getLoadedMemberDurationT(member));
  }

  function getAvailableVotesForMember(address _member) external view returns (uint256) {

    Member storage member = members[_member];
    if (member.active == false) {
      return 0;
    }

    return getAvailableVotes({ _alreadyClaimed: member.alreadyClaimedVotes, _memberEndT: getLoadedMemberEndT(member) });
  }

  function getAvailableTokens(uint256 _alreadyClaimed, uint256 _durationT) public view returns (uint256) {

    return getAvailable(block.timestamp, startT, amountPerMember, _durationT, _alreadyClaimed);
  }

  function getAvailableVotes(uint256 _alreadyClaimed, uint256 _memberEndT) public view returns (uint256) {

    if (block.timestamp > _memberEndT || block.timestamp > endT) {
      return 0;
    }
    return getAvailable(block.timestamp, startV, amountPerMember, durationV, _alreadyClaimed);
  }

  function getAvailable(
    uint256 _now,
    uint256 _start,
    uint256 _amountPerMember,
    uint256 _duration,
    uint256 _alreadyClaimed
  ) public pure returns (uint256) {

    if (_now <= _start) {
      return 0;
    }

    uint256 vestingEndsAt = _start.add(_duration);
    uint256 to = _now > vestingEndsAt ? vestingEndsAt : _now;

    uint256 accrued = ((to - _start).mul(_amountPerMember).div(_duration));

    return accrued.sub(_alreadyClaimed);
  }


  function increaseDurationT(uint256 _newDurationT) external onlyOwner {

    require(block.timestamp < endT, "Vesting::increaseDurationT: Vesting is over");
    require(_newDurationT > durationT, "Vesting::increaseDurationT: Too small duration");
    require((_newDurationT - durationT) <= 180 days, "Vesting::increaseDurationT: Too big duration");

    uint256 prevDurationT = durationT;
    uint256 prevEndT = endT;

    durationT = _newDurationT;
    uint256 newEndT = startT.add(_newDurationT);
    endT = newEndT;

    emit IncreaseDurationT(prevDurationT, prevEndT, _newDurationT, newEndT);
  }

  function increasePersonalDurationsT(address[] calldata _members, uint256[] calldata _newPersonalDurationsT)
    external
    onlyOwner
  {

    uint256 len = _members.length;
    require(_newPersonalDurationsT.length == len, "LENGTH_MISMATCH");

    for (uint256 i = 0; i < len; i++) {
      _increasePersonalDurationT(_members[i], _newPersonalDurationsT[i]);
    }
  }

  function _increasePersonalDurationT(address _member, uint256 _newPersonalDurationT) internal {

    Member memory member = members[_member];
    uint256 prevPersonalDurationT = getLoadedMemberDurationT(member);

    require(_newPersonalDurationT > prevPersonalDurationT, "Vesting::increasePersonalDurationT: Too small duration");
    require(
      (_newPersonalDurationT - prevPersonalDurationT) <= 180 days,
      "Vesting::increasePersonalDurationT: Too big duration"
    );
    require(_newPersonalDurationT >= durationT, "Vesting::increasePersonalDurationT: Less than durationT");

    uint256 prevPersonalEndT = startT.add(prevPersonalDurationT);

    members[_member].personalDurationT = _newPersonalDurationT.toUint32();

    uint256 newPersonalEndT = startT.add(_newPersonalDurationT);
    emit IncreasePersonalDurationT(
      _member,
      prevPersonalDurationT,
      prevPersonalEndT,
      member.personalDurationT,
      _newPersonalDurationT,
      newPersonalEndT
    );
  }

  function disableMember(address _member) external onlyOwner {

    _disableMember(_member);
  }

  function _disableMember(address _member) internal {

    Member memory from = members[_member];

    require(from.active == true, "Vesting::_disableMember: The member is inactive");

    members[_member].active = false;

    address currentDelegate = voteDelegations[_member];

    uint32 nCheckpoints = numCheckpoints[_member];
    if (nCheckpoints != 0 && currentDelegate != address(0) && currentDelegate != _member) {
      uint96 adjustedVotes =
        sub96(from.alreadyClaimedVotes, from.alreadyClaimedTokens, "Vesting::_disableMember: AdjustedVotes underflow");

      if (adjustedVotes > 0) {
        _subDelegatedVotesCache(currentDelegate, adjustedVotes);
      }
    }

    delete voteDelegations[_member];

    uint256 tokensRemainder =
      sub96(amountPerMember, from.alreadyClaimedTokens, "Vesting::_disableMember: BalanceRemainder overflow");
    require(IERC20(token).transfer(address(1), uint256(tokensRemainder)), "ERC20::transfer: failed");

    emit DisableMember(_member, tokensRemainder);
  }


  function renounceMembership() external {

    _disableMember(msg.sender);
  }

  function claimVotes(address _to) external {

    Member memory member = members[_to];
    require(member.active == true, "Vesting::claimVotes: User not active");

    uint256 endT_ = getLoadedMemberEndT(member);
    uint256 votes = getAvailableVotes({ _alreadyClaimed: member.alreadyClaimedVotes, _memberEndT: endT_ });

    require(block.timestamp <= endT_, "Vesting::claimVotes: Vote vesting has ended");
    require(votes > 0, "Vesting::claimVotes: Nothing to claim");

    _claimVotes(_to, member, votes);
  }

  function _claimVotes(
    address _memberAddress,
    Member memory _member,
    uint256 _availableVotes
  ) internal {

    uint96 newAlreadyClaimedVotes;

    if (_availableVotes > 0) {
      uint96 amount = safe96(_availableVotes, "Vesting::_claimVotes: Amount overflow");

      newAlreadyClaimedVotes = add96(
        _member.alreadyClaimedVotes,
        amount,
        "Vesting::claimVotes: newAlreadyClaimed overflow"
      );
      members[_memberAddress].alreadyClaimedVotes = newAlreadyClaimedVotes;
    } else {
      newAlreadyClaimedVotes = _member.alreadyClaimedVotes;
    }

    uint96 lastMemberAdjustedVotes =
      sub96(
        _member.alreadyClaimedVotes,
        _member.alreadyClaimedTokens,
        "Vesting::_claimVotes: lastMemberAdjustedVotes overflow"
      );

    uint96 adjustedVotes =
      sub96(
        newAlreadyClaimedVotes,
        members[_memberAddress].alreadyClaimedTokens,
        "Vesting::_claimVotes: adjustedVotes underflow"
      );

    address delegate = getVoteUser(_memberAddress);
    uint96 diff;

    if (adjustedVotes > lastMemberAdjustedVotes) {
      diff = sub96(adjustedVotes, lastMemberAdjustedVotes, "Vesting::_claimVotes: Positive diff underflow");
      _addDelegatedVotesCache(delegate, diff);
    } else if (lastMemberAdjustedVotes > adjustedVotes) {
      diff = sub96(lastMemberAdjustedVotes, adjustedVotes, "Vesting::_claimVotes: Negative diff underflow");
      _subDelegatedVotesCache(delegate, diff);
    }

    emit ClaimVotes(
      _memberAddress,
      delegate,
      _member.alreadyClaimedVotes,
      _member.alreadyClaimedTokens,
      newAlreadyClaimedVotes,
      members[_memberAddress].alreadyClaimedTokens,
      lastMemberAdjustedVotes,
      adjustedVotes,
      diff
    );
  }

  function claimTokens(address _to) external {

    Member memory member = members[msg.sender];
    require(member.active == true, "Vesting::claimTokens: User not active");

    uint256 durationT_ = getLoadedMemberDurationT(member);
    uint256 bigAmount = getAvailableTokens(member.alreadyClaimedTokens, durationT_);
    require(bigAmount > 0, "Vesting::claimTokens: Nothing to claim");
    uint96 amount = safe96(bigAmount, "Vesting::claimTokens: Amount overflow");

    uint96 newAlreadyClaimed =
      add96(member.alreadyClaimedTokens, amount, "Vesting::claimTokens: NewAlreadyClaimed overflow");
    members[msg.sender].alreadyClaimedTokens = newAlreadyClaimed;

    uint256 endT_ = startT.add(durationT_);
    uint256 votes = getAvailableVotes({ _alreadyClaimed: member.alreadyClaimedVotes, _memberEndT: endT_ });

    if (block.timestamp <= endT) {
      _claimVotes(msg.sender, member, votes);
    }

    emit ClaimTokens(msg.sender, _to, amount, newAlreadyClaimed, votes);

    require(IERC20(token).transfer(_to, bigAmount), "ERC20::transfer: failed");
  }

  function delegateVotes(address _to) external {

    Member memory member = members[msg.sender];
    require(_to != address(0), "Vesting::delegateVotes: Can't delegate to 0 address");
    require(member.active == true, "Vesting::delegateVotes: msg.sender not active");

    address currentDelegate = getVoteUser(msg.sender);
    require(_to != currentDelegate, "Vesting::delegateVotes: Already delegated to this address");

    voteDelegations[msg.sender] = _to;
    uint96 adjustedVotes =
      sub96(member.alreadyClaimedVotes, member.alreadyClaimedTokens, "Vesting::claimVotes: AdjustedVotes underflow");

    _subDelegatedVotesCache(currentDelegate, adjustedVotes);
    _addDelegatedVotesCache(_to, adjustedVotes);

    emit DelegateVotes(msg.sender, _to, currentDelegate, adjustedVotes);
  }

  function transfer(address _to) external {

    Member memory from = members[msg.sender];
    Member memory to = members[_to];

    uint96 alreadyClaimedTokens = from.alreadyClaimedTokens;
    uint96 alreadyClaimedVotes = from.alreadyClaimedVotes;
    uint32 personalDurationT = from.personalDurationT;

    require(from.active == true, "Vesting::transfer: From member is inactive");
    require(to.active == false, "Vesting::transfer: To address is already active");
    require(to.transferred == false, "Vesting::transfer: To address has been already used");
    require(numCheckpoints[_to] == 0, "Vesting::transfer: To address already had a checkpoint");

    members[msg.sender] = Member({
      active: false,
      transferred: true,
      alreadyClaimedVotes: 0,
      alreadyClaimedTokens: 0,
      personalDurationT: 0
    });
    members[_to] = Member({
      active: true,
      transferred: false,
      alreadyClaimedVotes: alreadyClaimedVotes,
      alreadyClaimedTokens: alreadyClaimedTokens,
      personalDurationT: personalDurationT
    });

    address currentDelegate = voteDelegations[msg.sender];

    uint32 currentBlockNumber = safe32(block.number, "Vesting::transfer: Block number exceeds 32 bits");

    checkpoints[_to][0] = Checkpoint(uint32(0), 0);
    if (currentDelegate == address(0)) {
      uint96 adjustedVotes =
        sub96(from.alreadyClaimedVotes, from.alreadyClaimedTokens, "Vesting::claimVotes: AdjustedVotes underflow");
      _subDelegatedVotesCache(msg.sender, adjustedVotes);
      checkpoints[_to][1] = Checkpoint(currentBlockNumber, adjustedVotes);
      numCheckpoints[_to] = 2;
    } else {
      numCheckpoints[_to] = 1;
    }

    voteDelegations[_to] = voteDelegations[msg.sender];
    delete voteDelegations[msg.sender];

    Member memory toMember = members[_to];

    emit Transfer(msg.sender, _to, alreadyClaimedVotes, alreadyClaimedTokens, currentDelegate);

    uint256 votes =
      getAvailableVotes({ _alreadyClaimed: toMember.alreadyClaimedVotes, _memberEndT: getLoadedMemberEndT(toMember) });

    _claimVotes(_to, toMember, votes);
  }

  function _subDelegatedVotesCache(address _member, uint96 _subAmount) internal {

    uint32 dstRepNum = numCheckpoints[_member];
    uint96 dstRepOld = dstRepNum > 0 ? checkpoints[_member][dstRepNum - 1].votes : 0;
    uint96 dstRepNew = sub96(dstRepOld, _subAmount, "Vesting::_cacheUnclaimed: Sub amount overflows");
    _writeCheckpoint(_member, dstRepNum, dstRepOld, dstRepNew);
  }

  function _addDelegatedVotesCache(address _member, uint96 _addAmount) internal {

    uint32 dstRepNum = numCheckpoints[_member];
    uint96 dstRepOld = dstRepNum > 0 ? checkpoints[_member][dstRepNum - 1].votes : 0;
    uint96 dstRepNew = add96(dstRepOld, _addAmount, "Vesting::_cacheUnclaimed: Add amount overflows");
    _writeCheckpoint(_member, dstRepNum, dstRepOld, dstRepNew);
  }

  function _writeCheckpoint(
    address delegatee,
    uint32 nCheckpoints,
    uint96 oldVotes,
    uint96 newVotes
  ) internal {

    uint32 blockNumber = safe32(block.number, "Vesting::_writeCheckpoint: Block number exceeds 32 bits");

    if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
      checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
    } else {
      checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
      numCheckpoints[delegatee] = nCheckpoints + 1;
    }

    emit UnclaimedBalanceChanged(delegatee, oldVotes, newVotes);
  }

  function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

    require(n < 2**32, errorMessage);
    return uint32(n);
  }

  function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {

    require(n < 2**96, errorMessage);
    return uint96(n);
  }

  function sub96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {

    require(b <= a, errorMessage);
    return a - b;
  }

  function add96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {

    uint96 c = a + b;
    require(c >= a, errorMessage);
    return c;
  }
}