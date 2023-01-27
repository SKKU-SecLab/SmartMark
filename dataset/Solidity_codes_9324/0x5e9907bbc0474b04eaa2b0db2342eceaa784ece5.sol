
pragma solidity ^0.8.3;


library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract Governance is ReentrancyGuard {


	uint constant public governance_challenging_period = 10 days;
	uint constant public governance_freeze_period = 30 days;

	address public votingTokenAddress;
	address public governedContractAddress;

	mapping(address => uint) public balances;

	VotedValue[] public votedValues;
	mapping(string => VotedValue) public votedValuesMap;


	constructor(address _governedContractAddress, address _votingTokenAddress){
		init(_governedContractAddress, _votingTokenAddress);
	}

	function init(address _governedContractAddress, address _votingTokenAddress) public {

		require(governedContractAddress == address(0), "governance already initialized");
		governedContractAddress = _governedContractAddress;
		votingTokenAddress = _votingTokenAddress;
	}

	function addressBelongsToGovernance(address addr) public view returns (bool) {

		for (uint i = 0; i < votedValues.length; i++)
			if (address(votedValues[i]) == addr)
				return true;
		return false;
	}

	function isUntiedFromAllVotes(address addr) public view returns (bool) {

		for (uint i = 0; i < votedValues.length; i++)
			if (votedValues[i].hasVote(addr))
				return false;
		return true;
	}

	function addVotedValue(string memory name, VotedValue votedValue) external {

		require(msg.sender == governedContractAddress, "not authorized");
		votedValues.push(votedValue);
		votedValuesMap[name] = votedValue;
	}



	function deposit(uint amount) payable external {

		deposit(msg.sender, amount);
	}

	function deposit(address from, uint amount) nonReentrant payable public {

		require(from == msg.sender || addressBelongsToGovernance(msg.sender), "not allowed");
		if (votingTokenAddress == address(0))
			require(msg.value == amount, "wrong amount received");
		else {
			require(msg.value == 0, "don't send ETH");
			require(IERC20(votingTokenAddress).transferFrom(from, address(this), amount), "failed to pull gov deposit");
		}
		balances[from] += amount;
	}



	function withdraw() external {

		withdraw(balances[msg.sender]);
	}

	function withdraw(uint amount) nonReentrant public {

		require(amount > 0, "zero withdrawal requested");
		require(amount <= balances[msg.sender], "not enough balance");
		require(isUntiedFromAllVotes(msg.sender), "some votes not removed yet");
		balances[msg.sender] -= amount;
		if (votingTokenAddress == address(0))
			payable(msg.sender).transfer(amount);
		else
			require(IERC20(votingTokenAddress).transfer(msg.sender, amount), "failed to withdraw gov deposit");
	}
}


abstract contract VotedValue is ReentrancyGuard {
	Governance public governance;
	uint public challenging_period_start_ts;
	mapping(address => bool) public hasVote;

	constructor(Governance _governance){
		governance = _governance;
	}

	function checkVoteChangeLock() view public {
		require(challenging_period_start_ts + governance.governance_challenging_period() + governance.governance_freeze_period() < block.timestamp, "you cannot change your vote yet");
	}

	function checkChallengingPeriodExpiry() view public {
		require(block.timestamp > challenging_period_start_ts + governance.governance_challenging_period(), "challenging period not expired yet");
	}
}


contract VotedValueUint is VotedValue {


	function(uint) external validationCallback;
	function(uint) external commitCallback;

	uint public leader;
	uint public current_value;

	mapping(address => uint) public choices;
	mapping(uint => uint) public votesByValue;
	mapping(uint => mapping(address => uint)) public votesByValueAddress;

	constructor() VotedValue(Governance(address(0))) {}


	function init(Governance _governance, uint initial_value, function(uint) external _validationCallback, function(uint) external _commitCallback) external {

		require(address(governance) == address(0), "already initialized");
		governance = _governance;
		leader = initial_value;
		current_value = initial_value;
		validationCallback = _validationCallback;
		commitCallback = _commitCallback;
	}

	function vote(uint value) nonReentrant external {

		_vote(value);
	}

	function voteAndDeposit(uint value, uint amount) nonReentrant payable external {

		governance.deposit{value: msg.value}(msg.sender, amount);
		_vote(value);
	}

	function _vote(uint value) private {

		validationCallback(value);
		uint prev_choice = choices[msg.sender];
		bool hadVote = hasVote[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();

		if (hadVote)
			removeVote(prev_choice);

		uint balance = governance.balances(msg.sender);
		require(balance > 0, "no balance");
		votesByValue[value] += balance;
		votesByValueAddress[value][msg.sender] = balance;
		choices[msg.sender] = value;
		hasVote[msg.sender] = true;

		if (votesByValue[value] > votesByValue[leader]){
			leader = value;
			challenging_period_start_ts = block.timestamp;
		}
	}

	function unvote() external {

		if (!hasVote[msg.sender])
			return;
		uint prev_choice = choices[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();
		
		removeVote(prev_choice);
		delete choices[msg.sender];
		delete hasVote[msg.sender];
	}

	function removeVote(uint value) internal {

		votesByValue[value] -= votesByValueAddress[value][msg.sender];
		votesByValueAddress[value][msg.sender] = 0;
	}

	function commit() nonReentrant external {

		require(leader != current_value, "already equal to leader");
		checkChallengingPeriodExpiry();
		current_value = leader;
		commitCallback(leader);
	}
}



contract VotedValueUintArray is VotedValue {


	function(uint[] memory) external validationCallback;
	function(uint[] memory) external commitCallback;

	uint[] public leader;
	uint[] public current_value;

	mapping(address => uint[]) public choices;
	mapping(bytes32 => uint) public votesByValue;
	mapping(bytes32 => mapping(address => uint)) public votesByValueAddress;

	constructor() VotedValue(Governance(address(0))) {}


	function init(Governance _governance, uint[] memory initial_value, function(uint[] memory) external _validationCallback, function(uint[] memory) external _commitCallback) external {

		require(address(governance) == address(0), "already initialized");
		governance = _governance;
		leader = initial_value;
		current_value = initial_value;
		validationCallback = _validationCallback;
		commitCallback = _commitCallback;
	}

	function equal(uint[] memory a1, uint[] memory a2) public pure returns (bool) {

		if (a1.length != a2.length)
			return false;
		for (uint i = 0; i < a1.length; i++)
			if (a1[i] != a2[i])
				return false;
		return true;
	}

	function getKey(uint[] memory a) public pure returns (bytes32){

		return keccak256(abi.encodePacked(a));
	}

	function vote(uint[] memory value) nonReentrant external {

		_vote(value);
	}

	function voteAndDeposit(uint[] memory value, uint amount) nonReentrant payable external {

		governance.deposit{value: msg.value}(msg.sender, amount);
		_vote(value);
	}

	function _vote(uint[] memory value) private {

		validationCallback(value);
		uint[] storage prev_choice = choices[msg.sender];
		bool hadVote = hasVote[msg.sender];
		if (equal(prev_choice, leader))
			checkVoteChangeLock();

		if (hadVote)
			removeVote(prev_choice);

		bytes32 key = getKey(value);
		uint balance = governance.balances(msg.sender);
		require(balance > 0, "no balance");
		votesByValue[key] += balance;
		votesByValueAddress[key][msg.sender] = balance;
		choices[msg.sender] = value;
		hasVote[msg.sender] = true;

		if (votesByValue[key] > votesByValue[getKey(leader)]){
			leader = value;
			challenging_period_start_ts = block.timestamp;
		}
	}

	function unvote() external {

		if (!hasVote[msg.sender])
			return;
		uint[] storage prev_choice = choices[msg.sender];
		if (equal(prev_choice, leader))
			checkVoteChangeLock();
		
		removeVote(prev_choice);
		delete choices[msg.sender];
		delete hasVote[msg.sender];
	}

	function removeVote(uint[] memory value) internal {

		bytes32 key = getKey(value);
		votesByValue[key] -= votesByValueAddress[key][msg.sender];
		votesByValueAddress[key][msg.sender] = 0;
	}

	function commit() nonReentrant external {

		require(!equal(leader, current_value), "already equal to leader");
		checkChallengingPeriodExpiry();
		current_value = leader;
		commitCallback(leader);
	}
}



contract VotedValueAddress is VotedValue {


	function(address) external validationCallback;
	function(address) external commitCallback;

	address public leader;
	address public current_value;

	mapping(address => address) public choices;

	mapping(address => uint) public votesByValue;

	mapping(address => mapping(address => uint)) public votesByValueAddress;

	constructor() VotedValue(Governance(address(0))) {}


	function init(Governance _governance, address initial_value, function(address) external _validationCallback, function(address) external _commitCallback) external {

		require(address(governance) == address(0), "already initialized");
		governance = _governance;
		leader = initial_value;
		current_value = initial_value;
		validationCallback = _validationCallback;
		commitCallback = _commitCallback;
	}

	function vote(address value) nonReentrant external {

		_vote(value);
	}

	function voteAndDeposit(address value, uint amount) nonReentrant payable external {

		governance.deposit{value: msg.value}(msg.sender, amount);
		_vote(value);
	}

	function _vote(address value) private {

		validationCallback(value);
		address prev_choice = choices[msg.sender];
		bool hadVote = hasVote[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();

		if (hadVote)
			removeVote(prev_choice);

		uint balance = governance.balances(msg.sender);
		require(balance > 0, "no balance");
		votesByValue[value] += balance;
		votesByValueAddress[value][msg.sender] = balance;
		choices[msg.sender] = value;
		hasVote[msg.sender] = true;

		if (votesByValue[value] > votesByValue[leader]){
			leader = value;
			challenging_period_start_ts = block.timestamp;
		}
	}

	function unvote() external {

		if (!hasVote[msg.sender])
			return;
		address prev_choice = choices[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();
		
		removeVote(prev_choice);
		delete choices[msg.sender];
		delete hasVote[msg.sender];
	}

	function removeVote(address value) internal {

		votesByValue[value] -= votesByValueAddress[value][msg.sender];
		votesByValueAddress[value][msg.sender] = 0;
	}

	function commit() nonReentrant external {

		require(leader != current_value, "already equal to leader");
		checkChallengingPeriodExpiry();
		current_value = leader;
		commitCallback(leader);
	}
}


contract VotedValueFactory {


	address public votedValueUintMaster;
	address public votedValueUintArrayMaster;
	address public votedValueAddressMaster;

	constructor(address _votedValueUintMaster, address _votedValueUintArrayMaster, address _votedValueAddressMaster) {
		votedValueUintMaster = _votedValueUintMaster;
		votedValueUintArrayMaster = _votedValueUintArrayMaster;
		votedValueAddressMaster = _votedValueAddressMaster;
	}


	function createVotedValueUint(Governance governance, uint initial_value, function(uint) external validationCallback, function(uint) external commitCallback) external returns (VotedValueUint) {

		VotedValueUint vv = VotedValueUint(Clones.clone(votedValueUintMaster));
		vv.init(governance, initial_value, validationCallback, commitCallback);
		return vv;
	}

	function createVotedValueUintArray(Governance governance, uint[] memory initial_value, function(uint[] memory) external validationCallback, function(uint[] memory) external commitCallback) external returns (VotedValueUintArray) {

		VotedValueUintArray vv = VotedValueUintArray(Clones.clone(votedValueUintArrayMaster));
		vv.init(governance, initial_value, validationCallback, commitCallback);
		return vv;
	}

	function createVotedValueAddress(Governance governance, address initial_value, function(address) external validationCallback, function(address) external commitCallback) external returns (VotedValueAddress) {

		VotedValueAddress vv = VotedValueAddress(Clones.clone(votedValueAddressMaster));
		vv.init(governance, initial_value, validationCallback, commitCallback);
		return vv;
	}

}