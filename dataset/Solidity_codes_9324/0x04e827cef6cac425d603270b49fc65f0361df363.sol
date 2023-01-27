
pragma solidity >=0.5.0 <0.6.0;

interface IRelay {


    function withdraw(address _from, address _to, uint256 _value) external returns (bool ok);


    function burnZeroAddress() external;


    function disable() external;


    function disableTokenUpgradability() external;


    function changeTokenDelegate(address _newDelegate) external;


    function executeUpgradeDelegate(address _multisig, address _delegateV3) external;


    function destroyStake(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) external;


}


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


    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);

}


interface IErasureStake {

    function increaseStake(uint256 currentStake, uint256 amountToAdd) external;

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


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
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








contract NumeraiTournamentV3 is Initializable, Pausable {


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


    using SafeMath for uint256;
    using SafeMath for uint128;

    event Staked(
        uint256 indexed tournamentID,
        uint256 indexed roundID,
        address indexed staker,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    );
    event StakeResolved(
        uint256 indexed tournamentID,
        uint256 indexed roundID,
        address indexed staker,
        bytes32 tag,
        uint256 originalStake,
        uint256 burnAmount
    );
    event RoundCreated(
        uint256 indexed tournamentID,
        uint256 indexed roundID,
        uint256 stakeDeadline
    );
    event TournamentCreated(
        uint256 indexed tournamentID
    );
    event IncreaseStakeErasure(
        address indexed agreement,
        address indexed staker,
        uint256 oldStakeAmount,
        uint256 amountAdded
    );

    address private constant _TOKEN = address(
        0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671
    );

    address private constant _RELAY = address(
        0xB17dF4a656505570aD994D023F632D48De04eDF2
    );

    modifier onlyNewRounds(uint256 tournamentID, uint256 roundID) {

        uint256 length = tournaments[tournamentID].roundIDs.length;
        if (length > 0) {
            uint256 lastRoundID = tournaments[tournamentID].roundIDs[length - 1];
            require(roundID > lastRoundID, "roundID must be increasing");
        }
        _;
    }

    modifier onlyUint128(uint256 a) {

        require(
            a < 0x100000000000000000000000000000000,
            "Input uint256 cannot be larger than uint128"
        );
        _;
    }

    function initialize(
        address _owner
    ) public initializer {

        Pausable.initialize(_owner);
    }


    function recoverETH(address payable recipient) public onlyOwner {

        recipient.transfer(address(this).balance);
    }

    function recoverNMR(address payable recipient) public onlyOwner {

        uint256 balance = INMR(_TOKEN).balanceOf(address(this));
        uint256 amount = balance.sub(totalStaked);
        require(INMR(_TOKEN).transfer(recipient, amount));
    }


    function batchStakeOnBehalf(
        uint256[] calldata tournamentID,
        uint256[] calldata roundID,
        address[] calldata staker,
        bytes32[] calldata tag,
        uint256[] calldata stakeAmount,
        uint256[] calldata confidence
    ) external {

        uint256 len = tournamentID.length;
        require(
            roundID.length == len &&
            staker.length == len &&
            tag.length == len &&
            stakeAmount.length == len &&
            confidence.length == len,
            "Inputs must be same length"
        );
        for (uint i = 0; i < len; i++) {
            stakeOnBehalf(tournamentID[i], roundID[i], staker[i], tag[i], stakeAmount[i], confidence[i]);
        }
    }

    function batchWithdraw(
        address[] calldata from,
        address[] calldata to,
        uint256[] calldata value
    ) external {

        uint256 len = from.length;
        require(
            to.length == len &&
            value.length == len,
            "Inputs must be same length"
        );
        for (uint i = 0; i < len; i++) {
            withdraw(from[i], to[i], value[i]);
        }
    }

    function batchResolveStake(
        uint256[] calldata tournamentID,
        uint256[] calldata roundID,
        address[] calldata staker,
        bytes32[] calldata tag,
        uint256[] calldata burnAmount
    ) external {

        uint256 len = tournamentID.length;
        require(
            roundID.length == len &&
            staker.length == len &&
            tag.length == len &&
            burnAmount.length == len,
            "Inputs must be same length"
        );
        for (uint i = 0; i < len; i++) {
            resolveStake(tournamentID[i], roundID[i], staker[i], tag[i], burnAmount[i]);
        }
    }


    function stakeOnBehalf(
        uint256 tournamentID,
        uint256 roundID,
        address staker,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    ) public onlyManagerOrOwner whenNotPaused {

        _stake(tournamentID, roundID, staker, tag, stakeAmount, confidence);
        IRelay(_RELAY).withdraw(staker, address(this), stakeAmount);
    }

    function withdraw(
        address from,
        address to,
        uint256 value
    ) public onlyManagerOrOwner whenNotPaused {

        IRelay(_RELAY).withdraw(from, to, value);
    }


    function stake(
        uint256 tournamentID,
        uint256 roundID,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    ) public whenNotPaused {

        _stake(tournamentID, roundID, msg.sender, tag, stakeAmount, confidence);
        require(INMR(_TOKEN).transferFrom(msg.sender, address(this), stakeAmount),
            "Stake was not successfully transfered");
    }


    function resolveStake(
        uint256 tournamentID,
        uint256 roundID,
        address staker,
        bytes32 tag,
        uint256 burnAmount
    )
    public
    onlyManagerOrOwner
    whenNotPaused
    onlyUint128(burnAmount)
    {

        Stake storage stakeObj = tournaments[tournamentID].rounds[roundID].stakes[staker][tag];
        uint128 originalStakeAmount = stakeObj.amount;
        if (burnAmount >= 0x100000000000000000000000000000000)
            burnAmount = originalStakeAmount;
        uint128 releaseAmount = uint128(originalStakeAmount.sub(burnAmount));

        assert(originalStakeAmount == releaseAmount + burnAmount);
        require(originalStakeAmount > 0, "The stake must exist");
        require(!stakeObj.resolved, "The stake must not already be resolved");
        require(
            uint256(
                tournaments[tournamentID].rounds[roundID].stakeDeadline
            ) < block.timestamp,
            "Cannot resolve before stake deadline"
        );

        stakeObj.amount = 0;
        stakeObj.burnAmount = uint128(burnAmount);
        stakeObj.resolved = true;

        require(
            INMR(_TOKEN).transfer(staker, releaseAmount),
            "Stake was not succesfully released"
        );
        _burn(burnAmount);

        totalStaked = totalStaked.sub(originalStakeAmount);

        emit StakeResolved(tournamentID, roundID, staker, tag, originalStakeAmount, burnAmount);
    }

    function createTournament(uint256 tournamentID) public onlyManagerOrOwner {


        Tournament storage tournament = tournaments[tournamentID];

        require(
            tournament.creationTime == 0,
            "Tournament must not already be initialized"
        );

        uint256 oldCreationTime;
        (oldCreationTime,) = getTournamentV1(tournamentID);
        require(
            oldCreationTime == 0,
            "This tournament must not be initialized in V1"
        );

        tournament.creationTime = block.timestamp;

        emit TournamentCreated(tournamentID);
    }

    function createRound(
        uint256 tournamentID,
        uint256 roundID,
        uint256 stakeDeadline
    )
    public
    onlyManagerOrOwner
    onlyNewRounds(tournamentID, roundID)
    onlyUint128(stakeDeadline)
    {

        Tournament storage tournament = tournaments[tournamentID];
        Round storage round = tournament.rounds[roundID];

        require(tournament.creationTime > 0, "This tournament must be initialized");
        require(round.creationTime == 0, "This round must not be initialized");

        tournament.roundIDs.push(roundID);
        round.creationTime = uint128(block.timestamp);
        round.stakeDeadline = uint128(stakeDeadline);

        emit RoundCreated(tournamentID, roundID, stakeDeadline);
    }

    function increaseStakeErasure(address agreement, address staker, uint256 currentStake, uint256 stakeAmount) public onlyManagerOrOwner {

        require(stakeAmount > 0, "Cannot stake zero NMR");

        uint256 oldBalance = INMR(_TOKEN).balanceOf(address(this));

        require(IRelay(_RELAY).withdraw(staker, address(this), stakeAmount), "Failed to withdraw");

        uint256 oldAllowance = INMR(_TOKEN).allowance(address(this), agreement);
        uint256 newAmount = oldAllowance.add(stakeAmount);
        require(INMR(_TOKEN).changeApproval(agreement, oldAllowance, newAmount), "Failed to approve");

        IErasureStake(agreement).increaseStake(currentStake, stakeAmount);

        uint256 newBalance = INMR(_TOKEN).balanceOf(address(this));
        require(oldBalance == newBalance, "Balance before/after did not match");

        emit IncreaseStakeErasure(agreement, staker, currentStake, stakeAmount);
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

    function relay() external pure returns (address) {

        return _RELAY;
    }

    function token() external pure returns (address) {

        return _TOKEN;
    }


    function _stake(
        uint256 tournamentID,
        uint256 roundID,
        address staker,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    ) internal onlyUint128(stakeAmount) {

        Tournament storage tournament = tournaments[tournamentID];
        Round storage round = tournament.rounds[roundID];
        Stake storage stakeObj = round.stakes[staker][tag];

        uint128 currentStake = stakeObj.amount;
        uint32 currentConfidence = stakeObj.confidence;

        require(tournament.creationTime > 0, "This tournament must be initialized");
        require(round.creationTime > 0, "This round must be initialized");
        require(
            uint256(round.stakeDeadline) > block.timestamp,
            "Cannot stake after stake deadline"
        );
        require(stakeAmount > 0 || currentStake > 0, "Cannot stake zero NMR");
        require(confidence <= 1000000000, "Confidence is capped at 9 decimal places");
        require(currentConfidence <= confidence, "Confidence can only be increased");

        stakeObj.amount = uint128(currentStake.add(stakeAmount));
        stakeObj.confidence = uint32(confidence);

        totalStaked = totalStaked.add(stakeAmount);

        emit Staked(tournamentID, roundID, staker, tag, stakeObj.amount, confidence);
    }

    function _burn(uint256 _value) internal {

        if (INMR(_TOKEN).contractUpgradable()) {
            require(INMR(_TOKEN).transfer(address(0), _value));
        } else {
            require(INMR(_TOKEN).mint(_value), "burn not successful");
        }
    }
}