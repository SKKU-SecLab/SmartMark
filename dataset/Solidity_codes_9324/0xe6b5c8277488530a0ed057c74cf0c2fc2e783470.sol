

pragma solidity ^0.5.16;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract MultiOwnable is
    Initializable
{


    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 15 seconds;
    uint public constant MAXIMUM_DELAY = 30 days;

    struct VoteInfo {
        uint32 timelockFrom;
        uint32 votesCounter;
        uint64 curVote;
        mapping(uint => mapping (address => bool)) isVoted; // [curVote][owner]
    }
    mapping(bytes => VoteInfo) public votes;

    mapping(address => bool) public  multiOwners;

    uint public multiOwnersCounter;

    uint public minVotes = 2;           // initial value

    uint public delay = MINIMUM_DELAY;  // initial value

    event QueueVote(address indexed owner, bytes data);
    event TxTimelockStart(bytes data, uint32 start);
    event CancelVote(address indexed owner, bytes data);
    event ExecuteVote(bytes data);
    event NewMinVotes(uint newMinVotes);
    event NewDelay(uint newDelay);
    event MultiOwnerAdded(address indexed newMultiOwner);
    event MultiOwnerRemoved(address indexed exMultiOwner);

    modifier onlyMultiOwners {

        if (_onlyMultiOwnersCall()) {
            _;
        }
    }

    modifier _onlyMultiOwnersHelper {

        address account = msg.sender;
        bytes memory data = msg.data;
        require(multiOwners[account], "Permission denied");

        uint curVote = votes[data].curVote;
        uint32 curTimestamp = uint32(block.timestamp);

        if (!votes[data].isVoted[curVote][account]) {
            votes[data].isVoted[curVote][account] = true;
            votes[data].votesCounter++;
            emit QueueVote(account, data);

            if (votes[data].votesCounter == min(minVotes, multiOwnersCounter)) {
                votes[data].timelockFrom = curTimestamp;
                emit TxTimelockStart(data, curTimestamp);
            }
        }

        if (votes[data].votesCounter >= min(minVotes, multiOwnersCounter) &&
            votes[data].timelockFrom + delay <= curTimestamp &&
            votes[data].timelockFrom + delay + GRACE_PERIOD >= curTimestamp
        ){
            votes[data].votesCounter = 0;
            votes[data].timelockFrom = 0;
            votes[data].curVote++;
            emit ExecuteVote(data);
            _;  // tx execution
        }
    }


    function initialize() public initializer {

        _addMultiOwner(msg.sender);
    }

    function initialize(address[] memory _newMultiOwners) public initializer {

        require(_newMultiOwners.length > 0, "Array lengths have to be greater than zero");

        for (uint i = 0; i < _newMultiOwners.length; i++) {
            _addMultiOwner(_newMultiOwners[i]);
        }
    }


    function addMultiOwner(address _newMultiOwner) public onlyMultiOwners {

        _addMultiOwner(_newMultiOwner);
    }

    function addMultiOwners(address[] memory _newMultiOwners) public onlyMultiOwners {

        require(_newMultiOwners.length > 0, "Array lengths have to be greater than zero");

        for (uint i = 0; i < _newMultiOwners.length; i++) {
            _addMultiOwner(_newMultiOwners[i]);
        }
    }

    function removeMultiOwner(address _exMultiOwner) public onlyMultiOwners {

        _removeMultiOwner(_exMultiOwner);
    }

    function removeMultiOwners(address[] memory _exMultiOwners) public onlyMultiOwners {

        require(_exMultiOwners.length > 0, "Array lengths have to be greater than zero");

        for (uint i = 0; i < _exMultiOwners.length; i++) {
            _removeMultiOwner(_exMultiOwners[i]);
        }
    }

    function setMinVotes(uint _minVotes) public onlyMultiOwners {

        require(_minVotes > 0, "MinVotes have to be greater than zero");
        minVotes = _minVotes;
        emit NewMinVotes(_minVotes);
    }

    function setDelay(uint _delay) public onlyMultiOwners {

        require(_delay >= MINIMUM_DELAY, "Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "Delay must not exceed maximum delay.");
        delay = _delay;

        emit NewDelay(_delay);
    }

    function cancelVote(bytes memory _data) public {

        address account = msg.sender;
        require(multiOwners[account], "Permission denied");

        uint curVote = votes[_data].curVote;
        require(votes[_data].isVoted[curVote][account] && votes[_data].votesCounter > 0, "Incorrect vote data");

        votes[_data].isVoted[curVote][account] = false;
        votes[_data].votesCounter--;    // safe
        emit CancelVote(account, _data);
    }


    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }

    function _onlyMultiOwnersCall() internal _onlyMultiOwnersHelper returns (bool success) {

        success = true;
    }

    function _addMultiOwner(address _newMultiOwner) internal {

        require(!multiOwners[_newMultiOwner], "The owner has already been added");

        multiOwners[_newMultiOwner] = true;
        multiOwnersCounter++;

        emit MultiOwnerAdded(_newMultiOwner);
    }

    function _removeMultiOwner(address _exMultiOwner) internal {

        require(multiOwners[_exMultiOwner], "This address is not the owner");
        require(multiOwnersCounter > 1, "At least one owner required");

        multiOwners[_exMultiOwner] = false;
        multiOwnersCounter--;   // safe

        emit MultiOwnerRemoved(_exMultiOwner);
    }

}


interface IAdminUpgradeabilityProxy {

    function changeAdmin(address newAdmin) external;

    function upgradeTo(address newImplementation) external;

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

}

contract ProxyAdminMultisig is MultiOwnable {


    constructor() public {
        address[] memory newOwners = new address[](1);
        newOwners[0] = 0x596c92A7a464acbc64Ba171f9647c39d4d755712;
        initialize(newOwners);
    }

    function getProxyImplementation(IAdminUpgradeabilityProxy proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(IAdminUpgradeabilityProxy proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(IAdminUpgradeabilityProxy proxy, address newAdmin) public onlyMultiOwners {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(IAdminUpgradeabilityProxy proxy, address implementation) public onlyMultiOwners {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(IAdminUpgradeabilityProxy proxy, address implementation, bytes memory data) public payable  onlyMultiOwners {

        proxy.upgradeToAndCall.value(msg.value)(implementation, data);
    }
}