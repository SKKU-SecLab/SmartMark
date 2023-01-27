

pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


pragma solidity ^0.5.0;


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;


contract WhitelistAdminRole {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract WhitelistedRole is WhitelistAdminRole {

    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {

        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {

        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {

        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {

        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {

        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {

        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {

        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}


pragma solidity ^0.5.0;


contract PauserRole {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {

        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


pragma solidity ^0.5.0;


contract Pausable is PauserRole {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused);
        _;
    }

    modifier whenPaused() {

        require(_paused);
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}


pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.17;

interface IDPoS {

    enum ValidatorChangeType { Add, Removal }

    function contributeToMiningPool(uint _amount) external;


    function redeemMiningReward(address _receiver, uint _cumulativeReward) external;


    function registerSidechain(address _addr) external;


    function initializeCandidate(uint _minSelfStake, uint _commissionRate, uint _rateLockEndTime) external;


    function announceIncreaseCommissionRate(uint _newRate, uint _newLockEndTime) external;


    function confirmIncreaseCommissionRate() external;


    function nonIncreaseCommissionRate(uint _newRate, uint _newLockEndTime) external;


    function updateMinSelfStake(uint256 _minSelfStake) external;


    function delegate(address _candidateAddr, uint _amount) external;


    function withdrawFromUnbondedCandidate(address _candidateAddr, uint _amount) external;


    function intendWithdraw(address _candidateAddr, uint _amount) external;


    function confirmWithdraw(address _candidateAddr) external;


    function claimValidator() external;


    function confirmUnbondedCandidate(address _candidateAddr) external;


    function slash(bytes calldata _penaltyRequest) external;


    function validateMultiSigMessage(bytes calldata _request) external returns(bool);


    function isValidDPoS() external view returns (bool);


    function isValidator(address _addr) external view returns (bool);


    function getValidatorNum() external view returns (uint);


    function getMinStakingPool() external view returns (uint);


    function getCandidateInfo(address _candidateAddr) external view returns (bool, uint, uint, uint, uint, uint, uint);


    function getDelegatorInfo(address _candidateAddr, address _delegatorAddr) external view returns (uint, uint, uint[] memory, uint[] memory);


    function getMinQuorumStakingPool() external view returns(uint);


    function getTotalValidatorStakingPool() external view returns(uint);






    event InitializeCandidate(address indexed candidate, uint minSelfStake, uint commissionRate, uint rateLockEndTime);

    event CommissionRateAnnouncement(address indexed candidate, uint announcedRate, uint announcedLockEndTime);

    event UpdateCommissionRate(address indexed candidate, uint newRate, uint newLockEndTime);

    event UpdateMinSelfStake(address indexed candidate, uint minSelfStake);

    event Delegate(address indexed delegator, address indexed candidate, uint newStake, uint stakingPool);

    event ValidatorChange(address indexed ethAddr, ValidatorChangeType indexed changeType);

    event WithdrawFromUnbondedCandidate(address indexed delegator, address indexed candidate, uint amount);

    event IntendWithdraw(address indexed delegator, address indexed candidate, uint withdrawAmount, uint proposedTime);

    event ConfirmWithdraw(address indexed delegator, address indexed candidate, uint amount);

    event Slash(address indexed validator, address indexed delegator, uint amount);

    event UpdateDelegatedStake(address indexed delegator, address indexed candidate, uint delegatorStake, uint candidatePool);

    event Compensate(address indexed indemnitee, uint amount);

    event CandidateUnbonded(address indexed candidate);

    event RedeemMiningReward(address indexed receiver, uint reward, uint miningPool);

    event MiningPoolContribution(address indexed contributor, uint contribution, uint miningPoolSize);
}


pragma solidity 0.5.17;

library Pb {

    enum WireType { Varint, Fixed64, LengthDelim, StartGroup, EndGroup, Fixed32 }

    struct Buffer {
        uint idx;  // the start index of next read. when idx=b.length, we're done
        bytes b;   // hold serialized proto msg, readonly
    }

    function fromBytes(bytes memory raw) internal pure returns (Buffer memory buf) {

        buf.b = raw;
        buf.idx = 0;
    }

    function hasMore(Buffer memory buf) internal pure returns (bool) {

        return buf.idx < buf.b.length;
    }

    function decKey(Buffer memory buf) internal pure returns (uint tag, WireType wiretype) {

        uint v = decVarint(buf);
        tag = v / 8;
        wiretype = WireType(v & 7);
    }

    function cntTags(Buffer memory buf, uint maxtag) internal pure returns (uint[] memory cnts) {

        uint originalIdx = buf.idx;
        cnts = new uint[](maxtag+1);  // protobuf's tags are from 1 rather than 0
        uint tag;
        WireType wire;
        while (hasMore(buf)) {
            (tag, wire) = decKey(buf);
            cnts[tag] += 1;
            skipValue(buf, wire);
        }
        buf.idx = originalIdx;
    }

    function decVarint(Buffer memory buf) internal pure returns (uint v) {

        bytes10 tmp;  // proto int is at most 10 bytes (7 bits can be used per byte)
        bytes memory bb = buf.b;  // get buf.b mem addr to use in assembly
        v = buf.idx;  // use v to save one additional uint variable
        assembly {
            tmp := mload(add(add(bb, 32), v)) // load 10 bytes from buf.b[buf.idx] to tmp
        }
        uint b; // store current byte content
        v = 0; // reset to 0 for return value
        for (uint i=0; i<10; i++) {
            assembly {
                b := byte(i, tmp)  // don't use tmp[i] because it does bound check and costs extra
            }
            v |= (b & 0x7F) << (i * 7);
            if (b & 0x80 == 0) {
                buf.idx += i + 1;
                return v;
            }
        }
        revert(); // i=10, invalid varint stream
    }

    function decBytes(Buffer memory buf) internal pure returns (bytes memory b) {

        uint len = decVarint(buf);
        uint end = buf.idx + len;
        require(end <= buf.b.length);  // avoid overflow
        b = new bytes(len);
        bytes memory bufB = buf.b;  // get buf.b mem addr to use in assembly
        uint bStart;
        uint bufBStart = buf.idx;
        assembly {
            bStart := add(b, 32)
            bufBStart := add(add(bufB, 32), bufBStart)
        }
        for (uint i=0; i<len; i+=32) {
            assembly{
                mstore(add(bStart, i), mload(add(bufBStart, i)))
            }
        }
        buf.idx = end;
    }

    function decPacked(Buffer memory buf) internal pure returns (uint[] memory t) {

        uint len = decVarint(buf);
        uint end = buf.idx + len;
        require(end <= buf.b.length);  // avoid overflow
        uint[] memory tmp = new uint[](len);
        uint i; // count how many ints are there
        while (buf.idx < end) {
            tmp[i] = decVarint(buf);
            i++;
        }
        t = new uint[](i); // init t with correct length
        for (uint j=0; j<i; j++) {
            t[j] = tmp[j];
        }
        return t;
    }

    function skipValue(Buffer memory buf, WireType wire) internal pure {

        if (wire == WireType.Varint) { decVarint(buf); }
        else if (wire == WireType.LengthDelim) {
            uint len = decVarint(buf);
            buf.idx += len; // skip len bytes value data
            require(buf.idx <= buf.b.length);  // avoid overflow
        } else { revert(); }  // unsupported wiretype
    }

    function _bool(uint x) internal pure returns (bool v) {
        return x != 0;
    }

    function _uint256(bytes memory b) internal pure returns (uint256 v) {
        require(b.length <= 32);  // b's length must be smaller than or equal to 32
        assembly { v := mload(add(b, 32)) }  // load all 32bytes to v
        v = v >> (8 * (32 - b.length));  // only first b.length is valid
    }

    function _address(bytes memory b) internal pure returns (address v) {
        v = _addressPayable(b);
    }

    function _addressPayable(bytes memory b) internal pure returns (address payable v) {
        require(b.length == 20);
        assembly { v := div(mload(add(b, 32)), 0x1000000000000000000000000) }
    }

    function _bytes32(bytes memory b) internal pure returns (bytes32 v) {
        require(b.length == 32);
        assembly { v := mload(add(b, 32)) }
    }

    function uint8s(uint[] memory arr) internal pure returns (uint8[] memory t) {
        t = new uint8[](arr.length);
        for (uint i = 0; i < t.length; i++) { t[i] = uint8(arr[i]); }
    }

    function uint32s(uint[] memory arr) internal pure returns (uint32[] memory t) {
        t = new uint32[](arr.length);
        for (uint i = 0; i < t.length; i++) { t[i] = uint32(arr[i]); }
    }

    function uint64s(uint[] memory arr) internal pure returns (uint64[] memory t) {
        t = new uint64[](arr.length);
        for (uint i = 0; i < t.length; i++) { t[i] = uint64(arr[i]); }
    }

    function bools(uint[] memory arr) internal pure returns (bool[] memory t) {
        t = new bool[](arr.length);
        for (uint i = 0; i < t.length; i++) { t[i] = arr[i]!=0; }
    }
}


pragma solidity 0.5.17;


library PbSgn {

    using Pb for Pb.Buffer;  // so we can call Pb funcs on Buffer obj

    struct MultiSigMessage {
        bytes msg;   // tag: 1
        bytes[] sigs;   // tag: 2
    } // end struct MultiSigMessage

    function decMultiSigMessage(bytes memory raw) internal pure returns (MultiSigMessage memory m) {

        Pb.Buffer memory buf = Pb.fromBytes(raw);

        uint[] memory cnts = buf.cntTags(2);
        m.sigs = new bytes[](cnts[2]);
        cnts[2] = 0;  // reset counter for later use
        
        uint tag;
        Pb.WireType wire;
        while (buf.hasMore()) {
            (tag, wire) = buf.decKey();
            if (false) {} // solidity has no switch/case
            else if (tag == 1) {
                m.msg = bytes(buf.decBytes());
            }
            else if (tag == 2) {
                m.sigs[cnts[2]] = bytes(buf.decBytes());
                cnts[2]++;
            }
            else { buf.skipValue(wire); } // skip value of unknown tag
        }
    } // end decoder MultiSigMessage

    struct PenaltyRequest {
        bytes penalty;   // tag: 1
        bytes[] sigs;   // tag: 2
    } // end struct PenaltyRequest

    function decPenaltyRequest(bytes memory raw) internal pure returns (PenaltyRequest memory m) {

        Pb.Buffer memory buf = Pb.fromBytes(raw);

        uint[] memory cnts = buf.cntTags(2);
        m.sigs = new bytes[](cnts[2]);
        cnts[2] = 0;  // reset counter for later use
        
        uint tag;
        Pb.WireType wire;
        while (buf.hasMore()) {
            (tag, wire) = buf.decKey();
            if (false) {} // solidity has no switch/case
            else if (tag == 1) {
                m.penalty = bytes(buf.decBytes());
            }
            else if (tag == 2) {
                m.sigs[cnts[2]] = bytes(buf.decBytes());
                cnts[2]++;
            }
            else { buf.skipValue(wire); } // skip value of unknown tag
        }
    } // end decoder PenaltyRequest

    struct RewardRequest {
        bytes reward;   // tag: 1
        bytes[] sigs;   // tag: 2
    } // end struct RewardRequest

    function decRewardRequest(bytes memory raw) internal pure returns (RewardRequest memory m) {

        Pb.Buffer memory buf = Pb.fromBytes(raw);

        uint[] memory cnts = buf.cntTags(2);
        m.sigs = new bytes[](cnts[2]);
        cnts[2] = 0;  // reset counter for later use
        
        uint tag;
        Pb.WireType wire;
        while (buf.hasMore()) {
            (tag, wire) = buf.decKey();
            if (false) {} // solidity has no switch/case
            else if (tag == 1) {
                m.reward = bytes(buf.decBytes());
            }
            else if (tag == 2) {
                m.sigs[cnts[2]] = bytes(buf.decBytes());
                cnts[2]++;
            }
            else { buf.skipValue(wire); } // skip value of unknown tag
        }
    } // end decoder RewardRequest

    struct Penalty {
        uint64 nonce;   // tag: 1
        uint64 expireTime;   // tag: 2
        address validatorAddress;   // tag: 3
        AccountAmtPair[] penalizedDelegators;   // tag: 4
        AccountAmtPair[] beneficiaries;   // tag: 5
    } // end struct Penalty

    function decPenalty(bytes memory raw) internal pure returns (Penalty memory m) {

        Pb.Buffer memory buf = Pb.fromBytes(raw);

        uint[] memory cnts = buf.cntTags(5);
        m.penalizedDelegators = new AccountAmtPair[](cnts[4]);
        cnts[4] = 0;  // reset counter for later use
        m.beneficiaries = new AccountAmtPair[](cnts[5]);
        cnts[5] = 0;  // reset counter for later use
        
        uint tag;
        Pb.WireType wire;
        while (buf.hasMore()) {
            (tag, wire) = buf.decKey();
            if (false) {} // solidity has no switch/case
            else if (tag == 1) {
                m.nonce = uint64(buf.decVarint());
            }
            else if (tag == 2) {
                m.expireTime = uint64(buf.decVarint());
            }
            else if (tag == 3) {
                m.validatorAddress = Pb._address(buf.decBytes());
            }
            else if (tag == 4) {
                m.penalizedDelegators[cnts[4]] = decAccountAmtPair(buf.decBytes());
                cnts[4]++;
            }
            else if (tag == 5) {
                m.beneficiaries[cnts[5]] = decAccountAmtPair(buf.decBytes());
                cnts[5]++;
            }
            else { buf.skipValue(wire); } // skip value of unknown tag
        }
    } // end decoder Penalty

    struct AccountAmtPair {
        address account;   // tag: 1
        uint256 amt;   // tag: 2
    } // end struct AccountAmtPair

    function decAccountAmtPair(bytes memory raw) internal pure returns (AccountAmtPair memory m) {

        Pb.Buffer memory buf = Pb.fromBytes(raw);

        uint tag;
        Pb.WireType wire;
        while (buf.hasMore()) {
            (tag, wire) = buf.decKey();
            if (false) {} // solidity has no switch/case
            else if (tag == 1) {
                m.account = Pb._address(buf.decBytes());
            }
            else if (tag == 2) {
                m.amt = Pb._uint256(buf.decBytes());
            }
            else { buf.skipValue(wire); } // skip value of unknown tag
        }
    } // end decoder AccountAmtPair

    struct Reward {
        address receiver;   // tag: 1
        uint256 cumulativeMiningReward;   // tag: 2
        uint256 cumulativeServiceReward;   // tag: 3
    } // end struct Reward

    function decReward(bytes memory raw) internal pure returns (Reward memory m) {

        Pb.Buffer memory buf = Pb.fromBytes(raw);

        uint tag;
        Pb.WireType wire;
        while (buf.hasMore()) {
            (tag, wire) = buf.decKey();
            if (false) {} // solidity has no switch/case
            else if (tag == 1) {
                m.receiver = Pb._address(buf.decBytes());
            }
            else if (tag == 2) {
                m.cumulativeMiningReward = Pb._uint256(buf.decBytes());
            }
            else if (tag == 3) {
                m.cumulativeServiceReward = Pb._uint256(buf.decBytes());
            }
            else { buf.skipValue(wire); } // skip value of unknown tag
        }
    } // end decoder Reward

}


pragma solidity 0.5.17;

library DPoSCommon {

    enum CandidateStatus { Unbonded, Bonded, Unbonding }
}


pragma solidity 0.5.17;

interface IGovern {

    enum ParamNames { ProposalDeposit, GovernVoteTimeout, SlashTimeout, MinValidatorNum, MaxValidatorNum, MinStakeInPool, AdvanceNoticePeriod, MigrationTime }

    enum ProposalStatus { Uninitiated, Voting, Closed }

    enum VoteType { Unvoted, Yes, No, Abstain }

    function getUIntValue(uint _record) external view returns (uint);


    function getParamProposalVote(uint _proposalId, address _voter) external view returns (VoteType);


    function isSidechainRegistered(address _sidechainAddr) external view returns (bool);


    function getSidechainProposalVote(uint _proposalId, address _voter) external view returns (VoteType);


    function createParamProposal(uint _record, uint _value) external;


    function registerSidechain(address _addr) external;


    function createSidechainProposal(address _sidechainAddr, bool _registered) external;


    event CreateParamProposal(uint proposalId, address proposer, uint deposit, uint voteDeadline, uint record, uint newValue);

    event VoteParam(uint proposalId, address voter, VoteType voteType);

    event ConfirmParamProposal(uint proposalId, bool passed, uint record, uint newValue);

    event CreateSidechainProposal(uint proposalId, address proposer, uint deposit, uint voteDeadline, address sidechainAddr, bool registered);

    event VoteSidechain(uint proposalId, address voter, VoteType voteType);

    event ConfirmSidechainProposal(uint proposalId, bool passed, address sidechainAddr, bool registered);
}


pragma solidity 0.5.17;






contract Govern is IGovern, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct ParamProposal {
        address proposer;
        uint256 deposit;
        uint256 voteDeadline;
        uint256 record;
        uint256 newValue;
        ProposalStatus status;
        mapping(address => VoteType) votes;
    }

    struct SidechainProposal {
        address proposer;
        uint256 deposit;
        uint256 voteDeadline;
        address sidechainAddr;
        bool registered;
        ProposalStatus status;
        mapping(address => VoteType) votes;
    }

    IERC20 public celerToken;
    mapping(uint256 => uint256) public UIntStorage;
    mapping(uint256 => ParamProposal) public paramProposals;
    uint256 public nextParamProposalId;
    mapping(address => bool) public registeredSidechains;
    mapping(uint256 => SidechainProposal) public sidechainProposals;
    uint256 public nextSidechainProposalId;

    constructor(
        address _celerTokenAddress,
        uint256 _governProposalDeposit,
        uint256 _governVoteTimeout,
        uint256 _slashTimeout,
        uint256 _minValidatorNum,
        uint256 _maxValidatorNum,
        uint256 _minStakeInPool,
        uint256 _advanceNoticePeriod
    ) public {
        celerToken = IERC20(_celerTokenAddress);

        UIntStorage[uint256(ParamNames.ProposalDeposit)] = _governProposalDeposit;
        UIntStorage[uint256(ParamNames.GovernVoteTimeout)] = _governVoteTimeout;
        UIntStorage[uint256(ParamNames.SlashTimeout)] = _slashTimeout;
        UIntStorage[uint256(ParamNames.MinValidatorNum)] = _minValidatorNum;
        UIntStorage[uint256(ParamNames.MaxValidatorNum)] = _maxValidatorNum;
        UIntStorage[uint256(ParamNames.MinStakeInPool)] = _minStakeInPool;
        UIntStorage[uint256(ParamNames.AdvanceNoticePeriod)] = _advanceNoticePeriod;
    }

    function getUIntValue(uint256 _record) public view returns (uint256) {

        return UIntStorage[_record];
    }

    function getParamProposalVote(uint256 _proposalId, address _voter)
        public
        view
        returns (VoteType)
    {

        return paramProposals[_proposalId].votes[_voter];
    }

    function isSidechainRegistered(address _sidechainAddr) public view returns (bool) {

        return registeredSidechains[_sidechainAddr];
    }

    function getSidechainProposalVote(uint256 _proposalId, address _voter)
        public
        view
        returns (VoteType)
    {

        return sidechainProposals[_proposalId].votes[_voter];
    }

    function createParamProposal(uint256 _record, uint256 _value) external {

        ParamProposal storage p = paramProposals[nextParamProposalId];
        nextParamProposalId = nextParamProposalId + 1;
        address msgSender = msg.sender;
        uint256 deposit = UIntStorage[uint256(ParamNames.ProposalDeposit)];

        p.proposer = msgSender;
        p.deposit = deposit;
        p.voteDeadline = block.number.add(UIntStorage[uint256(ParamNames.GovernVoteTimeout)]);
        p.record = _record;
        p.newValue = _value;
        p.status = ProposalStatus.Voting;

        celerToken.safeTransferFrom(msgSender, address(this), deposit);

        emit CreateParamProposal(
            nextParamProposalId - 1,
            msgSender,
            deposit,
            p.voteDeadline,
            _record,
            _value
        );
    }

    function internalVoteParam(
        uint256 _proposalId,
        address _voter,
        VoteType _vote
    ) internal {

        ParamProposal storage p = paramProposals[_proposalId];
        require(p.status == ProposalStatus.Voting, 'Invalid proposal status');
        require(block.number < p.voteDeadline, 'Vote deadline reached');
        require(p.votes[_voter] == VoteType.Unvoted, 'Voter has voted');

        p.votes[_voter] = _vote;

        emit VoteParam(_proposalId, _voter, _vote);
    }

    function internalConfirmParamProposal(uint256 _proposalId, bool _passed) internal {

        ParamProposal storage p = paramProposals[_proposalId];
        require(p.status == ProposalStatus.Voting, 'Invalid proposal status');
        require(block.number >= p.voteDeadline, 'Vote deadline not reached');

        p.status = ProposalStatus.Closed;
        if (_passed) {
            celerToken.safeTransfer(p.proposer, p.deposit);
            UIntStorage[p.record] = p.newValue;
        }

        emit ConfirmParamProposal(_proposalId, _passed, p.record, p.newValue);
    }

    function registerSidechain(address _addr) external onlyOwner {

        registeredSidechains[_addr] = true;
    }

    function createSidechainProposal(address _sidechainAddr, bool _registered) external {

        SidechainProposal storage p = sidechainProposals[nextSidechainProposalId];
        nextSidechainProposalId = nextSidechainProposalId + 1;
        address msgSender = msg.sender;
        uint256 deposit = UIntStorage[uint256(ParamNames.ProposalDeposit)];

        p.proposer = msgSender;
        p.deposit = deposit;
        p.voteDeadline = block.number.add(UIntStorage[uint256(ParamNames.GovernVoteTimeout)]);
        p.sidechainAddr = _sidechainAddr;
        p.registered = _registered;
        p.status = ProposalStatus.Voting;

        celerToken.safeTransferFrom(msgSender, address(this), deposit);

        emit CreateSidechainProposal(
            nextSidechainProposalId - 1,
            msgSender,
            deposit,
            p.voteDeadline,
            _sidechainAddr,
            _registered
        );
    }

    function internalVoteSidechain(
        uint256 _proposalId,
        address _voter,
        VoteType _vote
    ) internal {

        SidechainProposal storage p = sidechainProposals[_proposalId];
        require(p.status == ProposalStatus.Voting, 'Invalid proposal status');
        require(block.number < p.voteDeadline, 'Vote deadline reached');
        require(p.votes[_voter] == VoteType.Unvoted, 'Voter has voted');

        p.votes[_voter] = _vote;

        emit VoteSidechain(_proposalId, _voter, _vote);
    }

    function internalConfirmSidechainProposal(uint256 _proposalId, bool _passed) internal {

        SidechainProposal storage p = sidechainProposals[_proposalId];
        require(p.status == ProposalStatus.Voting, 'Invalid proposal status');
        require(block.number >= p.voteDeadline, 'Vote deadline not reached');

        p.status = ProposalStatus.Closed;
        if (_passed) {
            celerToken.safeTransfer(p.proposer, p.deposit);
            registeredSidechains[p.sidechainAddr] = p.registered;
        }

        emit ConfirmSidechainProposal(_proposalId, _passed, p.sidechainAddr, p.registered);
    }
}


pragma solidity 0.5.17;












contract DPoS is IDPoS, Ownable, Pausable, WhitelistedRole, Govern {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    enum MathOperation { Add, Sub }

    struct WithdrawIntent {
        uint256 amount;
        uint256 proposedTime;
    }

    struct Delegator {
        uint256 delegatedStake;
        uint256 undelegatingStake;
        mapping(uint256 => WithdrawIntent) withdrawIntents;
        uint256 intentStartIndex;
        uint256 intentEndIndex;
    }

    struct ValidatorCandidate {
        bool initialized;
        uint256 minSelfStake;
        uint256 stakingPool; // sum of all delegations to this candidate
        mapping(address => Delegator) delegatorProfiles;
        DPoSCommon.CandidateStatus status;
        uint256 unbondTime;
        uint256 commissionRate; // equal to real commission rate * COMMISSION_RATE_BASE
        uint256 rateLockEndTime; // must be monotonic increasing. Use block number
        uint256 announcedRate;
        uint256 announcedLockEndTime;
        uint256 announcementTime;
        uint256 earliestBondTime;
    }

    mapping(uint256 => address) public validatorSet;
    mapping(uint256 => bool) public usedPenaltyNonce;
    mapping(address => bool) public checkedValidators;
    mapping(address => ValidatorCandidate) private candidateProfiles;
    mapping(address => uint256) public redeemedMiningReward;

    uint256 constant DECIMALS_MULTIPLIER = 10**18;
    uint256 public constant COMMISSION_RATE_BASE = 10000; // 1 commissionRate means 0.01%

    uint256 public dposGoLiveTime; // used when bootstrapping initial validators
    uint256 public miningPool;
    bool public enableWhitelist;
    bool public enableSlash;

    modifier onlyNonZeroAddr(address _addr) {

        require(_addr != address(0), '0 address');
        _;
    }

    modifier onlyValidDPoS() {

        require(isValidDPoS(), 'DPoS is not valid');
        _;
    }

    modifier onlyRegisteredSidechains() {

        require(isSidechainRegistered(msg.sender), 'Sidechain not registered');
        _;
    }

    modifier onlyWhitelist() {

        if (enableWhitelist) {
            require(
                isWhitelisted(msg.sender),
                'WhitelistedRole: caller does not have the Whitelisted role'
            );
        }
        _;
    }

    modifier onlyNotMigrating() {

        require(!isMigrating(), 'contract migrating');
        _;
    }

    modifier minAmount(uint256 _amount, uint256 _min) {

        require(_amount >= _min, 'Amount is smaller than minimum requirement');
        _;
    }

    modifier onlyValidator() {

        require(isValidator(msg.sender), 'msg sender is not a validator');
        _;
    }

    modifier isCandidateInitialized() {

        require(candidateProfiles[msg.sender].initialized, 'Candidate is not initialized');
        _;
    }

    constructor(
        address _celerTokenAddress,
        uint256 _governProposalDeposit,
        uint256 _governVoteTimeout,
        uint256 _slashTimeout,
        uint256 _minValidatorNum,
        uint256 _maxValidatorNum,
        uint256 _minStakeInPool,
        uint256 _advanceNoticePeriod,
        uint256 _dposGoLiveTimeout
    )
        public
        Govern(
            _celerTokenAddress,
            _governProposalDeposit,
            _governVoteTimeout,
            _slashTimeout,
            _minValidatorNum,
            _maxValidatorNum,
            _minStakeInPool,
            _advanceNoticePeriod
        )
    {
        dposGoLiveTime = block.number.add(_dposGoLiveTimeout);
        enableSlash = true;
    }

    function updateEnableWhitelist(bool _enable) external onlyOwner {

        enableWhitelist = _enable;
    }

    function updateEnableSlash(bool _enable) external onlyOwner {

        enableSlash = _enable;
    }

    function drainToken(uint256 _amount) external whenPaused onlyOwner {

        celerToken.safeTransfer(msg.sender, _amount);
    }

    function voteParam(uint256 _proposalId, VoteType _vote) external onlyValidator {

        internalVoteParam(_proposalId, msg.sender, _vote);
    }

    function confirmParamProposal(uint256 _proposalId) external {

        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));

        uint256 yesVoteStakes;
        for (uint256 i = 0; i < maxValidatorNum; i++) {
            if (getParamProposalVote(_proposalId, validatorSet[i]) == VoteType.Yes) {
                yesVoteStakes = yesVoteStakes.add(candidateProfiles[validatorSet[i]].stakingPool);
            }
        }

        bool passed = yesVoteStakes >= getMinQuorumStakingPool();
        if (!passed) {
            miningPool = miningPool.add(paramProposals[_proposalId].deposit);
        }
        internalConfirmParamProposal(_proposalId, passed);
    }

    function voteSidechain(uint256 _proposalId, VoteType _vote) external onlyValidator {

        internalVoteSidechain(_proposalId, msg.sender, _vote);
    }

    function confirmSidechainProposal(uint256 _proposalId) external {

        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));

        uint256 yesVoteStakes;
        for (uint256 i = 0; i < maxValidatorNum; i++) {
            if (getSidechainProposalVote(_proposalId, validatorSet[i]) == VoteType.Yes) {
                yesVoteStakes = yesVoteStakes.add(candidateProfiles[validatorSet[i]].stakingPool);
            }
        }

        bool passed = yesVoteStakes >= getMinQuorumStakingPool();
        if (!passed) {
            miningPool = miningPool.add(sidechainProposals[_proposalId].deposit);
        }
        internalConfirmSidechainProposal(_proposalId, passed);
    }

    function contributeToMiningPool(uint256 _amount) external whenNotPaused {

        address msgSender = msg.sender;
        miningPool = miningPool.add(_amount);
        celerToken.safeTransferFrom(msgSender, address(this), _amount);

        emit MiningPoolContribution(msgSender, _amount, miningPool);
    }

    function redeemMiningReward(address _receiver, uint256 _cumulativeReward)
        external
        whenNotPaused
        onlyRegisteredSidechains
    {

        uint256 newReward = _cumulativeReward.sub(redeemedMiningReward[_receiver]);
        require(miningPool >= newReward, 'Mining pool is smaller than new reward');

        redeemedMiningReward[_receiver] = _cumulativeReward;
        miningPool = miningPool.sub(newReward);
        celerToken.safeTransfer(_receiver, newReward);

        emit RedeemMiningReward(_receiver, newReward, miningPool);
    }

    function initializeCandidate(
        uint256 _minSelfStake,
        uint256 _commissionRate,
        uint256 _rateLockEndTime
    ) external whenNotPaused onlyWhitelist {

        ValidatorCandidate storage candidate = candidateProfiles[msg.sender];
        require(!candidate.initialized, 'Candidate is initialized');
        require(_commissionRate <= COMMISSION_RATE_BASE, 'Invalid commission rate');

        candidate.initialized = true;
        candidate.minSelfStake = _minSelfStake;
        candidate.commissionRate = _commissionRate;
        candidate.rateLockEndTime = _rateLockEndTime;

        emit InitializeCandidate(msg.sender, _minSelfStake, _commissionRate, _rateLockEndTime);
    }

    function nonIncreaseCommissionRate(uint256 _newRate, uint256 _newLockEndTime)
        external
        isCandidateInitialized
    {

        ValidatorCandidate storage candidate = candidateProfiles[msg.sender];
        require(_newRate <= candidate.commissionRate, 'Invalid new rate');

        _updateCommissionRate(candidate, _newRate, _newLockEndTime);
    }

    function announceIncreaseCommissionRate(uint256 _newRate, uint256 _newLockEndTime)
        external
        isCandidateInitialized
    {

        ValidatorCandidate storage candidate = candidateProfiles[msg.sender];
        require(candidate.commissionRate < _newRate, 'Invalid new rate');

        candidate.announcedRate = _newRate;
        candidate.announcedLockEndTime = _newLockEndTime;
        candidate.announcementTime = block.number;

        emit CommissionRateAnnouncement(msg.sender, _newRate, _newLockEndTime);
    }

    function confirmIncreaseCommissionRate() external isCandidateInitialized {

        ValidatorCandidate storage candidate = candidateProfiles[msg.sender];
        require(
            block.number >
                candidate.announcementTime.add(
                    getUIntValue(uint256(ParamNames.AdvanceNoticePeriod))
                ),
            'Still in notice period'
        );

        _updateCommissionRate(candidate, candidate.announcedRate, candidate.announcedLockEndTime);

        delete candidate.announcedRate;
        delete candidate.announcedLockEndTime;
        delete candidate.announcementTime;
    }

    function updateMinSelfStake(uint256 _minSelfStake) external isCandidateInitialized {

        ValidatorCandidate storage candidate = candidateProfiles[msg.sender];
        if (_minSelfStake < candidate.minSelfStake) {
            require(candidate.status != DPoSCommon.CandidateStatus.Bonded, 'Candidate is bonded');
            candidate.earliestBondTime = block.number.add(
                getUIntValue(uint256(ParamNames.AdvanceNoticePeriod))
            );
        }
        candidate.minSelfStake = _minSelfStake;
        emit UpdateMinSelfStake(msg.sender, _minSelfStake);
    }

    function delegate(address _candidateAddr, uint256 _amount)
        external
        whenNotPaused
        onlyNonZeroAddr(_candidateAddr)
        minAmount(_amount, 1 * DECIMALS_MULTIPLIER) // minimal amount per delegate operation is 1 CELR
    {

        ValidatorCandidate storage candidate = candidateProfiles[_candidateAddr];
        require(candidate.initialized, 'Candidate is not initialized');

        address msgSender = msg.sender;
        _updateDelegatedStake(candidate, _candidateAddr, msgSender, _amount, MathOperation.Add);

        celerToken.safeTransferFrom(msgSender, address(this), _amount);

        emit Delegate(msgSender, _candidateAddr, _amount, candidate.stakingPool);
    }

    function claimValidator() external isCandidateInitialized {

        address msgSender = msg.sender;
        ValidatorCandidate storage candidate = candidateProfiles[msgSender];
        require(
            candidate.status == DPoSCommon.CandidateStatus.Unbonded ||
                candidate.status == DPoSCommon.CandidateStatus.Unbonding,
            'Invalid candidate status'
        );
        require(block.number >= candidate.earliestBondTime, 'Not earliest bond time yet');
        require(
            candidate.stakingPool >= getUIntValue(uint256(ParamNames.MinStakeInPool)),
            'Insufficient staking pool'
        );
        require(
            candidate.delegatorProfiles[msgSender].delegatedStake >= candidate.minSelfStake,
            'Not enough self stake'
        );

        uint256 minStakingPoolIndex;
        uint256 minStakingPool = candidateProfiles[validatorSet[0]].stakingPool;
        require(validatorSet[0] != msgSender, 'Already in validator set');
        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));
        for (uint256 i = 1; i < maxValidatorNum; i++) {
            require(validatorSet[i] != msgSender, 'Already in validator set');
            if (candidateProfiles[validatorSet[i]].stakingPool < minStakingPool) {
                minStakingPoolIndex = i;
                minStakingPool = candidateProfiles[validatorSet[i]].stakingPool;
            }
        }
        require(candidate.stakingPool > minStakingPool, 'Not larger than smallest pool');

        address removedValidator = validatorSet[minStakingPoolIndex];
        if (removedValidator != address(0)) {
            _removeValidator(minStakingPoolIndex);
        }
        _addValidator(msgSender, minStakingPoolIndex);
    }

    function confirmUnbondedCandidate(address _candidateAddr) external {

        ValidatorCandidate storage candidate = candidateProfiles[_candidateAddr];
        require(
            candidate.status == DPoSCommon.CandidateStatus.Unbonding,
            'Candidate not unbonding'
        );
        require(block.number >= candidate.unbondTime, 'Unbonding time not reached');

        candidate.status = DPoSCommon.CandidateStatus.Unbonded;
        delete candidate.unbondTime;
        emit CandidateUnbonded(_candidateAddr);
    }

    function withdrawFromUnbondedCandidate(address _candidateAddr, uint256 _amount)
        external
        onlyNonZeroAddr(_candidateAddr)
        minAmount(_amount, 1 * DECIMALS_MULTIPLIER)
    {

        ValidatorCandidate storage candidate = candidateProfiles[_candidateAddr];
        require(
            candidate.status == DPoSCommon.CandidateStatus.Unbonded || isMigrating(),
            'invalid status'
        );

        address msgSender = msg.sender;
        _updateDelegatedStake(candidate, _candidateAddr, msgSender, _amount, MathOperation.Sub);
        celerToken.safeTransfer(msgSender, _amount);

        emit WithdrawFromUnbondedCandidate(msgSender, _candidateAddr, _amount);
    }

    function intendWithdraw(address _candidateAddr, uint256 _amount)
        external
        onlyNonZeroAddr(_candidateAddr)
        minAmount(_amount, 1 * DECIMALS_MULTIPLIER)
    {

        address msgSender = msg.sender;

        ValidatorCandidate storage candidate = candidateProfiles[_candidateAddr];
        Delegator storage delegator = candidate.delegatorProfiles[msgSender];

        _updateDelegatedStake(candidate, _candidateAddr, msgSender, _amount, MathOperation.Sub);
        delegator.undelegatingStake = delegator.undelegatingStake.add(_amount);
        _validateValidator(_candidateAddr);

        WithdrawIntent storage withdrawIntent = delegator.withdrawIntents[delegator.intentEndIndex];
        withdrawIntent.amount = _amount;
        withdrawIntent.proposedTime = block.number;
        delegator.intentEndIndex++;

        emit IntendWithdraw(msgSender, _candidateAddr, _amount, withdrawIntent.proposedTime);
    }

    function confirmWithdraw(address _candidateAddr) external onlyNonZeroAddr(_candidateAddr) {

        address msgSender = msg.sender;
        Delegator storage delegator = candidateProfiles[_candidateAddr]
            .delegatorProfiles[msgSender];

        uint256 slashTimeout = getUIntValue(uint256(ParamNames.SlashTimeout));
        bool isUnbonded = candidateProfiles[_candidateAddr].status ==
            DPoSCommon.CandidateStatus.Unbonded;
        uint256 i;
        for (i = delegator.intentStartIndex; i < delegator.intentEndIndex; i++) {
            if (
                isUnbonded ||
                delegator.withdrawIntents[i].proposedTime.add(slashTimeout) <= block.number
            ) {
                delete delegator.withdrawIntents[i];
                continue;
            }
            break;
        }
        delegator.intentStartIndex = i;
        uint256 undelegatingStakeWithoutSlash;
        for (; i < delegator.intentEndIndex; i++) {
            undelegatingStakeWithoutSlash = undelegatingStakeWithoutSlash.add(
                delegator.withdrawIntents[i].amount
            );
        }

        uint256 withdrawAmt;
        if (delegator.undelegatingStake > undelegatingStakeWithoutSlash) {
            withdrawAmt = delegator.undelegatingStake.sub(undelegatingStakeWithoutSlash);
            delegator.undelegatingStake = undelegatingStakeWithoutSlash;

            celerToken.safeTransfer(msgSender, withdrawAmt);
        }

        emit ConfirmWithdraw(msgSender, _candidateAddr, withdrawAmt);
    }

    function slash(bytes calldata _penaltyRequest)
        external
        whenNotPaused
        onlyValidDPoS
        onlyNotMigrating
    {

        require(enableSlash, 'Slash is disabled');
        PbSgn.PenaltyRequest memory penaltyRequest = PbSgn.decPenaltyRequest(_penaltyRequest);
        PbSgn.Penalty memory penalty = PbSgn.decPenalty(penaltyRequest.penalty);

        ValidatorCandidate storage validator = candidateProfiles[penalty.validatorAddress];
        require(validator.status != DPoSCommon.CandidateStatus.Unbonded, 'Validator unbounded');

        bytes32 h = keccak256(penaltyRequest.penalty);
        require(_checkValidatorSigs(h, penaltyRequest.sigs), 'Validator sigs verification failed');
        require(block.number < penalty.expireTime, 'Penalty expired');
        require(!usedPenaltyNonce[penalty.nonce], 'Used penalty nonce');
        usedPenaltyNonce[penalty.nonce] = true;

        uint256 totalSubAmt;
        for (uint256 i = 0; i < penalty.penalizedDelegators.length; i++) {
            PbSgn.AccountAmtPair memory penalizedDelegator = penalty.penalizedDelegators[i];
            totalSubAmt = totalSubAmt.add(penalizedDelegator.amt);
            emit Slash(
                penalty.validatorAddress,
                penalizedDelegator.account,
                penalizedDelegator.amt
            );

            Delegator storage delegator = validator.delegatorProfiles[penalizedDelegator.account];
            uint256 _amt;
            if (delegator.delegatedStake >= penalizedDelegator.amt) {
                _amt = penalizedDelegator.amt;
            } else {
                uint256 remainingAmt = penalizedDelegator.amt.sub(delegator.delegatedStake);
                delegator.undelegatingStake = delegator.undelegatingStake.sub(remainingAmt);
                _amt = delegator.delegatedStake;
            }
            _updateDelegatedStake(
                validator,
                penalty.validatorAddress,
                penalizedDelegator.account,
                _amt,
                MathOperation.Sub
            );
        }
        _validateValidator(penalty.validatorAddress);

        uint256 totalAddAmt;
        for (uint256 i = 0; i < penalty.beneficiaries.length; i++) {
            PbSgn.AccountAmtPair memory beneficiary = penalty.beneficiaries[i];
            totalAddAmt = totalAddAmt.add(beneficiary.amt);

            if (beneficiary.account == address(0)) {
                miningPool = miningPool.add(beneficiary.amt);
            } else if (beneficiary.account == address(1)) {
                celerToken.safeTransfer(msg.sender, beneficiary.amt);
                emit Compensate(msg.sender, beneficiary.amt);
            } else {
                celerToken.safeTransfer(beneficiary.account, beneficiary.amt);
                emit Compensate(beneficiary.account, beneficiary.amt);
            }
        }

        require(totalSubAmt == totalAddAmt, 'Amount not match');
    }

    function validateMultiSigMessage(bytes calldata _request)
        external
        onlyRegisteredSidechains
        returns (bool)
    {

        PbSgn.MultiSigMessage memory request = PbSgn.decMultiSigMessage(_request);
        bytes32 h = keccak256(request.msg);

        return _checkValidatorSigs(h, request.sigs);
    }

    function getMinStakingPool() external view returns (uint256) {

        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));

        uint256 minStakingPool = candidateProfiles[validatorSet[0]].stakingPool;
        for (uint256 i = 0; i < maxValidatorNum; i++) {
            if (validatorSet[i] == address(0)) {
                return 0;
            }
            if (candidateProfiles[validatorSet[i]].stakingPool < minStakingPool) {
                minStakingPool = candidateProfiles[validatorSet[i]].stakingPool;
            }
        }

        return minStakingPool;
    }

    function getCandidateInfo(address _candidateAddr)
        external
        view
        returns (
            bool initialized,
            uint256 minSelfStake,
            uint256 stakingPool,
            uint256 status,
            uint256 unbondTime,
            uint256 commissionRate,
            uint256 rateLockEndTime
        )
    {

        ValidatorCandidate memory c = candidateProfiles[_candidateAddr];

        initialized = c.initialized;
        minSelfStake = c.minSelfStake;
        stakingPool = c.stakingPool;
        status = uint256(c.status);
        unbondTime = c.unbondTime;
        commissionRate = c.commissionRate;
        rateLockEndTime = c.rateLockEndTime;
    }

    function getDelegatorInfo(address _candidateAddr, address _delegatorAddr)
        external
        view
        returns (
            uint256 delegatedStake,
            uint256 undelegatingStake,
            uint256[] memory intentAmounts,
            uint256[] memory intentProposedTimes
        )
    {

        Delegator storage d = candidateProfiles[_candidateAddr].delegatorProfiles[_delegatorAddr];

        uint256 len = d.intentEndIndex.sub(d.intentStartIndex);
        intentAmounts = new uint256[](len);
        intentProposedTimes = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            intentAmounts[i] = d.withdrawIntents[i + d.intentStartIndex].amount;
            intentProposedTimes[i] = d.withdrawIntents[i + d.intentStartIndex].proposedTime;
        }

        delegatedStake = d.delegatedStake;
        undelegatingStake = d.undelegatingStake;
    }

    function isValidDPoS() public view returns (bool) {

        return
            block.number >= dposGoLiveTime &&
            getValidatorNum() >= getUIntValue(uint256(ParamNames.MinValidatorNum));
    }

    function isValidator(address _addr) public view returns (bool) {

        return candidateProfiles[_addr].status == DPoSCommon.CandidateStatus.Bonded;
    }

    function isMigrating() public view returns (bool) {

        uint256 migrationTime = getUIntValue(uint256(ParamNames.MigrationTime));
        return migrationTime != 0 && block.number >= migrationTime;
    }

    function getValidatorNum() public view returns (uint256) {

        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));

        uint256 num;
        for (uint256 i = 0; i < maxValidatorNum; i++) {
            if (validatorSet[i] != address(0)) {
                num++;
            }
        }
        return num;
    }

    function getMinQuorumStakingPool() public view returns (uint256) {

        return getTotalValidatorStakingPool().mul(2).div(3).add(1);
    }

    function getTotalValidatorStakingPool() public view returns (uint256) {

        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));

        uint256 totalValidatorStakingPool;
        for (uint256 i = 0; i < maxValidatorNum; i++) {
            totalValidatorStakingPool = totalValidatorStakingPool.add(
                candidateProfiles[validatorSet[i]].stakingPool
            );
        }

        return totalValidatorStakingPool;
    }

    function _updateCommissionRate(
        ValidatorCandidate storage _candidate,
        uint256 _newRate,
        uint256 _newLockEndTime
    ) private {

        require(_newRate <= COMMISSION_RATE_BASE, 'Invalid new rate');
        require(_newLockEndTime >= block.number, 'Outdated new lock end time');

        if (_newRate <= _candidate.commissionRate) {
            require(_newLockEndTime >= _candidate.rateLockEndTime, 'Invalid new lock end time');
        } else {
            require(block.number > _candidate.rateLockEndTime, 'Commission rate is locked');
        }

        _candidate.commissionRate = _newRate;
        _candidate.rateLockEndTime = _newLockEndTime;

        emit UpdateCommissionRate(msg.sender, _newRate, _newLockEndTime);
    }

    function _updateDelegatedStake(
        ValidatorCandidate storage _candidate,
        address _candidateAddr,
        address _delegatorAddr,
        uint256 _amount,
        MathOperation _op
    ) private {

        Delegator storage delegator = _candidate.delegatorProfiles[_delegatorAddr];

        if (_op == MathOperation.Add) {
            _candidate.stakingPool = _candidate.stakingPool.add(_amount);
            delegator.delegatedStake = delegator.delegatedStake.add(_amount);
        } else if (_op == MathOperation.Sub) {
            _candidate.stakingPool = _candidate.stakingPool.sub(_amount);
            delegator.delegatedStake = delegator.delegatedStake.sub(_amount);
        } else {
            assert(false);
        }
        emit UpdateDelegatedStake(
            _delegatorAddr,
            _candidateAddr,
            delegator.delegatedStake,
            _candidate.stakingPool
        );
    }

    function _addValidator(address _validatorAddr, uint256 _setIndex) private {

        require(validatorSet[_setIndex] == address(0), 'Validator slot occupied');

        validatorSet[_setIndex] = _validatorAddr;
        candidateProfiles[_validatorAddr].status = DPoSCommon.CandidateStatus.Bonded;
        delete candidateProfiles[_validatorAddr].unbondTime;
        emit ValidatorChange(_validatorAddr, ValidatorChangeType.Add);
    }

    function _removeValidator(uint256 _setIndex) private {

        address removedValidator = validatorSet[_setIndex];
        if (removedValidator == address(0)) {
            return;
        }

        delete validatorSet[_setIndex];
        candidateProfiles[removedValidator].status = DPoSCommon.CandidateStatus.Unbonding;
        candidateProfiles[removedValidator].unbondTime = block.number.add(
            getUIntValue(uint256(ParamNames.SlashTimeout))
        );
        emit ValidatorChange(removedValidator, ValidatorChangeType.Removal);
    }

    function _validateValidator(address _validatorAddr) private {

        ValidatorCandidate storage v = candidateProfiles[_validatorAddr];
        if (v.status != DPoSCommon.CandidateStatus.Bonded) {
            return;
        }

        bool lowSelfStake = v.delegatorProfiles[_validatorAddr].delegatedStake < v.minSelfStake;
        bool lowStakingPool = v.stakingPool < getUIntValue(uint256(ParamNames.MinStakeInPool));

        if (lowSelfStake || lowStakingPool) {
            _removeValidator(_getValidatorIdx(_validatorAddr));
        }
    }

    function _checkValidatorSigs(bytes32 _h, bytes[] memory _sigs) private returns (bool) {

        uint256 minQuorumStakingPool = getMinQuorumStakingPool();

        bytes32 hash = _h.toEthSignedMessageHash();
        address[] memory addrs = new address[](_sigs.length);
        uint256 quorumStakingPool;
        bool hasDuplicatedSig;
        for (uint256 i = 0; i < _sigs.length; i++) {
            addrs[i] = hash.recover(_sigs[i]);
            if (checkedValidators[addrs[i]]) {
                hasDuplicatedSig = true;
                break;
            }
            if (candidateProfiles[addrs[i]].status != DPoSCommon.CandidateStatus.Bonded) {
                continue;
            }

            quorumStakingPool = quorumStakingPool.add(candidateProfiles[addrs[i]].stakingPool);
            checkedValidators[addrs[i]] = true;
        }

        for (uint256 i = 0; i < _sigs.length; i++) {
            checkedValidators[addrs[i]] = false;
        }

        return !hasDuplicatedSig && quorumStakingPool >= minQuorumStakingPool;
    }

    function _getValidatorIdx(address _addr) private view returns (uint256) {

        uint256 maxValidatorNum = getUIntValue(uint256(ParamNames.MaxValidatorNum));

        for (uint256 i = 0; i < maxValidatorNum; i++) {
            if (validatorSet[i] == _addr) {
                return i;
            }
        }

        revert('No such a validator');
    }
}