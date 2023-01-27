pragma solidity >=0.7.0;

contract Authorizable {


    address public owner;
    mapping(address => bool) public authorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    function isAuthorized(address who) public view returns (bool) {

        return authorized[who];
    }

    function authorize(address who) external onlyOwner() {

        _authorize(who);
    }

    function deauthorize(address who) external onlyOwner() {

        authorized[who] = false;
    }

    function setOwner(address who) public onlyOwner() {

        owner = who;
    }

    function _authorize(address who) internal {

        authorized[who] = true;
    }
}// Apache-2.0
pragma solidity ^0.8.3;

contract ReentrancyBlock {

    bool private _entered;
    modifier nonReentrant() {

        require(!_entered, "Reentrancy");
        _entered = true;
        _;
        _entered = false;
    }
}// Apache-2.0
pragma solidity ^0.8.3;



contract Timelock is Authorizable, ReentrancyBlock {

    uint256 public waitTime;

    mapping(bytes32 => uint256) public callTimestamps;
    mapping(bytes32 => bool) public timeIncreases;

    constructor(
        uint256 _waitTime,
        address _governance,
        address _gsc
    ) Authorizable() {
        _authorize(_gsc);
        waitTime = _waitTime;
        setOwner(_governance);
    }

    function registerCall(bytes32 callHash) external onlyOwner {

        require(callTimestamps[callHash] == 0, "already registered");
        callTimestamps[callHash] = block.timestamp;
    }

    function stopCall(bytes32 callHash) external onlyOwner {

        require(callTimestamps[callHash] != 0, "No call to be removed");
        delete callTimestamps[callHash];
        delete timeIncreases[callHash];
    }

    function execute(address[] memory targets, bytes[] calldata calldatas)
        public
        nonReentrant
    {

        bytes32 callHash = keccak256(abi.encode(targets, calldatas));
        require(callTimestamps[callHash] != 0, "call has not been initialized");
        require(
            callTimestamps[callHash] + waitTime < block.timestamp,
            "not enough time has passed"
        );
        require(targets.length == calldatas.length, "invalid formatting");
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, ) = targets[i].call(calldatas[i]);
            require(success == true, "call reverted");
        }
        delete callTimestamps[callHash];
        delete timeIncreases[callHash];
    }

    function setWaitTime(uint256 _waitTime) public {

        require(msg.sender == address(this), "contract must be self");
        waitTime = _waitTime;
    }

    function increaseTime(uint256 timeValue, bytes32 callHash)
        external
        onlyAuthorized
    {

        require(
            timeIncreases[callHash] == false,
            "value can only be changed once"
        );
        require(
            callTimestamps[callHash] != 0,
            "must have been previously registered"
        );
        callTimestamps[callHash] += timeValue;
        timeIncreases[callHash] = true;
    }
}