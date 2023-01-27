
pragma solidity >=0.5.0 <0.6.0;

interface INMR {



    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


    function withdraw(address _from, address _to, uint256 _value) external returns(bool ok);


    function destroyStake(address _staker, bytes32 _tag, uint256 _tournamentID, uint256 _roundID) external returns (bool ok);


    function createRound(uint256, uint256, uint256, uint256) external returns (bool ok);


    function createTournament(uint256 _newDelegate) external returns (bool ok);


    function mint(uint256 _value) external returns (bool ok);


    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);


    function contractUpgradable() external view returns (bool);


    function getTournament(uint256 _tournamentID) external view returns (uint256, uint256[] memory);


    function getRound(uint256 _tournamentID, uint256 _roundID) external view returns (uint256, uint256, uint256);


    function getStake(uint256 _tournamentID, uint256 _roundID, address _staker, bytes32 _tag) external view returns (uint256, uint256, bool, bool);


}


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



contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


contract Ownable is Initializable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
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

    uint256[50] private ______gap;
}



contract Manageable is Initializable, Ownable {

    address private _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    function initialize(address sender) initializer public {

        Ownable.initialize(sender);
        _manager = sender;
        emit ManagementTransferred(address(0), _manager);
    }

    function manager() public view returns (address) {

        return _manager;
    }

    modifier onlyManagerOrOwner() {

        require(isManagerOrOwner());
        _;
    }

    function isManagerOrOwner() public view returns (bool) {

        return (msg.sender == _manager || isOwner());
    }

    function transferManagement(address newManager) public onlyOwner {

        require(newManager != address(0));
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }

    uint256[50] private ______gap;
}



contract Pausable is Initializable, Manageable {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {

        Manageable.initialize(sender);
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

    function pause() public onlyManagerOrOwner whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyManagerOrOwner whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    uint256[50] private ______gap;
}






contract NumeraiTournamentV1 is Initializable, Pausable {


    uint256 public totalStaked;

    mapping (uint256 => Tournament) public tournaments;

    struct Tournament {
        uint256 creationTime;
        uint256[] roundIDs;
        mapping (uint256 => Round) rounds;
    }

    struct Round {
        uint128 creationTime;
        uint128 stakeDeadline;
        mapping (address => mapping (bytes32 => Stake)) stakes;
    }

    struct Stake {
        uint128 amount;
        uint32 confidence;
        uint128 burnAmount;
        bool resolved;
    }


    event StakeInitializationProgress(
        bool initialized, // true if stake initialization complete, else false.
        uint256 firstUnprocessedStakeItem // index of the skipped stake, if any.
    );

    using SafeMath for uint256;
    using SafeMath for uint128;

    address private constant _TOKEN = address(
        0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671
    );

    constructor() public {
        require(
            address(this) == address(0xb2C4DbB78c7a34313600aD2e6E35d188ab4381a8),
            "Incorrect deployment address - check submitting account & nonce."
        );
    }

    function initialize(
        address _owner
    ) public initializer {

        Pausable.initialize(_owner);
    }

    function initializeTournamentsAndActiveRounds(
        uint256 _startingRoundID
    ) public onlyManagerOrOwner {

        INMR nmr = INMR(_TOKEN);

        for (uint256 tournamentID = 1; tournamentID <= 7; tournamentID++) {
            (
                uint256 tournamentCreationTime,
                uint256[] memory roundIDs
            ) = nmr.getTournament(tournamentID);

            tournaments[tournamentID].creationTime = tournamentCreationTime;

            if (roundIDs.length == 0) {
                continue;
            }

            uint256 mostRecentRoundID = roundIDs[roundIDs.length - 1];

            if (mostRecentRoundID < _startingRoundID) {
                continue;
            }

            uint256 initializedRounds = 0;

            for (uint256 j = 0; j < roundIDs.length; j++) {               
                uint256 roundID = roundIDs[j];

                if (roundID < _startingRoundID) {
                    continue;
                }

                tournaments[tournamentID].roundIDs.push(roundID);

                (
                    uint256 creationTime,
                    uint256 endTime,
                ) = nmr.getRound(tournamentID, roundID);

                tournaments[tournamentID].rounds[roundID] = Round({
                    creationTime: uint128(creationTime),
                    stakeDeadline: uint128(endTime)
                });

                initializedRounds++;
            }

            require(
                nmr.createRound(tournamentID, initializedRounds, 0, 0),
                "Could not delete round from legacy tournament."
            );
        }
    }

    function initializeStakes(
        uint256[] memory tournamentID,
        uint256[] memory roundID,
        address[] memory staker,
        bytes32[] memory tag
    ) public onlyManagerOrOwner {

        uint256 num = tournamentID.length;
        require(
            roundID.length == num &&
            staker.length == num &&
            tag.length == num,
            "Input data arrays must all have same length."
        );

        uint256 stakeAmt = 0;

        INMR nmr = INMR(_TOKEN);

        bool completed = true;

        uint256 progress;

        for (uint256 i = 0; i < num; i++) {
            if (gasleft() < 100000) {
                completed = false;
                progress = i;
                break;
            }

            (uint256 confidence, uint256 amount, , bool resolved) = nmr.getStake(
                tournamentID[i],
                roundID[i],
                staker[i],
                tag[i]
            );

            if (amount > 0 || resolved) {
                uint256 currentTournamentID = tournamentID[i];
                uint256 currentRoundID = roundID[i];

                require(
                    nmr.destroyStake(
                        staker[i], tag[i], currentTournamentID, currentRoundID
                    ),
                    "Could not destroy stake from legacy tournament."
                );

                Stake storage stakeObj = tournaments[currentTournamentID]
                                           .rounds[currentRoundID]
                                           .stakes[staker[i]][tag[i]];

                if (stakeObj.amount == 0 && !stakeObj.resolved) {

                    stakeAmt = stakeAmt.add(amount);

                    if (amount > 0) {
                        stakeObj.amount = uint128(amount);
                    }

                    stakeObj.confidence = uint32(confidence);

                    if (resolved) {
                        stakeObj.resolved = true;
                    }

                }
            }
        }

        totalStaked = totalStaked.add(stakeAmt);

        emit StakeInitializationProgress(completed, progress);
    }

    function settleStakeBalance() public onlyManagerOrOwner {

        require(INMR(_TOKEN).withdraw(address(0), address(0), totalStaked),
            "Stake balance was not successfully set on new tournament.");
    }

    function getTournamentV2(uint256 tournamentID) public view returns (
        uint256 creationTime,
        uint256[] memory roundIDs
    ) {

        Tournament storage tournament = tournaments[tournamentID];
        return (tournament.creationTime, tournament.roundIDs);
    }

    function getRoundV2(uint256 tournamentID, uint256 roundID) public view returns (
        uint256 creationTime,
        uint256 stakeDeadline
    ) {

        Round storage round = tournaments[tournamentID].rounds[roundID];
        return (uint256(round.creationTime), uint256(round.stakeDeadline));
    }

    function getStakeV2(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) public view returns (
        uint256 amount,
        uint256 confidence,
        uint256 burnAmount,
        bool resolved
    ) {

        Stake storage stakeObj = tournaments[tournamentID].rounds[roundID].stakes[staker][tag];
        return (stakeObj.amount, stakeObj.confidence, stakeObj.burnAmount, stakeObj.resolved);
    }

    function getTournamentV1(uint256 tournamentID) public view returns (
        uint256 creationTime,
        uint256[] memory roundIDs
    ) {

        return INMR(_TOKEN).getTournament(tournamentID);
    }

    function getRoundV1(uint256 tournamentID, uint256 roundID) public view returns (
        uint256 creationTime,
        uint256 endTime,
        uint256 resolutionTime
    ) {

        return INMR(_TOKEN).getRound(tournamentID, roundID);
    }

    function getStakeV1(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) public view returns (
        uint256 confidence,
        uint256 amount,
        bool successful,
        bool resolved
    ) {

        return INMR(_TOKEN).getStake(tournamentID, roundID, staker, tag);
    }
}