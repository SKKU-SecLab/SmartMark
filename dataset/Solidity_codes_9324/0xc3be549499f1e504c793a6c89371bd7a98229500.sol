pragma solidity ^0.6.0;

interface IMVDProxy {


    function init(address votingTokenAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalityProposalManagerAddress, address functionalitiesManagerAddress) external;


    function getToken() external view returns(address);

    function setToken(address newAddress) external;

    function getStateHolderAddress() external view returns(address);

    function setStateHolderAddress(address newAddress) external;

    function getMVDFunctionalityProposalManagerAddress() external view returns(address);

    function setMVDFunctionalityProposalManagerAddress(address newAddress) external;

    function getMVDFunctionalityModelsManagerAddress() external view returns(address);

    function setMVDFunctionalityModelsManagerAddress(address newAddress) external;

    function getMVDFunctionalitiesManagerAddress() external view returns(address);

    function setMVDFunctionalitiesManagerAddress(address newAddress) external;

    function changeProxy(address payable newAddress) external payable;

    function getFunctionalitiesAmount() external view returns(uint256);

    function isValidProposal(address proposal) external view returns (bool);

    function isValidFunctionality(address functionality) external view returns(bool);

    function isAuthorizedFunctionality(address functionality) external view returns(bool);

    function getFunctionalityAddress(string calldata codeName) external view returns(address);

    function hasFunctionality(string calldata codeName) external view returns(bool);

    function functionalitiesToJSON() external view returns(string memory functionsJSONArray);

    function functionalitiesToJSON(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);

    function getPendingProposal(string calldata codeName) external view returns(address proposalAddress, bool isPending);

    function newProposal(string calldata codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnParametersJSONArray, bool isInternal, bool needsSender, string calldata replaces) external returns(address proposalAddress);

    function startProposal(address proposalAddress) external;

    function disableProposal(address proposalAddress) external;

    function transfer(address receiver, uint256 value, address token) external;

    function setProposal() external;

    function read(string calldata codeName, bytes calldata data) external view returns(bytes memory returnData);

    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);

    function callFromManager(address location, bytes calldata payload) external returns(bool, bytes memory);

    function emitFromManager(string calldata codeName, uint256 position, address proposal, string calldata replaced, address location, bool submitable, string calldata methodSignature, bool isInternal, bool needsSender, address proposalAddress, uint256 replacedPosition) external;


    function emitEvent(string calldata eventSignature, bytes calldata firstIndex, bytes calldata secondIndex, bytes calldata data) external;


    event TokenChanged(address indexed oldAddress, address indexed newAddress);
    event MVDFunctionalityProposalManagerChanged(address indexed oldAddress, address indexed newAddress);
    event MVDFunctionalityModelsManagerChanged(address indexed oldAddress, address indexed newAddress);
    event MVDFunctionalitiesManagerChanged(address indexed oldAddress, address indexed newAddress);
    event StateHolderChanged(address indexed oldAddress, address indexed newAddress);
    event ProxyChanged(address indexed newAddress);

    event PaymentReceived(address indexed sender, uint256 value);
    event Proposal(address proposal);
    event ProposalSet(address indexed proposal, bool success);
    event FunctionalitySet(string indexed codeName, uint256 position, address proposal, string indexed replaced, address replacedLocation, bool replacedWasSubmitable, string replacedMethodSignature, bool replacedWasInternal, bool replacedNeededSender, address replacedProposal, uint256 replacedPosition);

    event Event(string indexed key, bytes32 indexed firstIndex, bytes32 indexed secondIndex, bytes data);
}pragma solidity ^0.6.0;

interface IMVDFunctionalityProposalManager {

    function newProposal(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces) external returns(address);

    function checkProposal(address proposalAddress) external;

    function disableProposal(address proposalAddress) external;

    function getProxy() external view returns (address);

    function setProxy() external;

    function isValidProposal(address proposal) external view returns (bool);

    function getPendingProposal(string calldata codeName) external view returns(address proposalAddress, bool isReallyPending);

}pragma solidity ^0.6.0;

interface IMVDFunctionalityProposal {


    function init(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces, address proxy) external;

    function setCollateralData(bool emergency, address sourceLocation, uint256 sourceLocationId, bool submitable, bool isInternal, bool needsSender, address proposer) external;


    function getProxy() external view returns(address);

    function getCodeName() external view returns(string memory);

    function isEmergency() external view returns(bool);

    function getSourceLocation() external view returns(address);

    function getSourceLocationId() external view returns(uint256);

    function getLocation() external view returns(address);

    function isSubmitable() external view returns(bool);

    function getMethodSignature() external view returns(string memory);

    function getReturnAbiParametersArray() external view returns(string memory);

    function isInternal() external view returns(bool);

    function needsSender() external view returns(bool);

    function getReplaces() external view returns(string memory);

    function getProposer() external view returns(address);

    function getSurveyEndBlock() external view returns(uint256);

    function getSurveyDuration() external view returns(uint256);

    function toJSON() external view returns(string memory);

    function getVote(address addr) external view returns(uint256 accept, uint256 refuse);

    function getVotes() external view returns(uint256, uint256);

    function start() external;

    function disable() external;

    function isDisabled() external view returns(bool);

    function isTerminated() external view returns(bool);

    function accept(uint256 amount) external;

    function retireAccept(uint256 amount) external;

    function moveToAccept(uint256 amount) external;

    function refuse(uint256 amount) external;

    function retireRefuse(uint256 amount) external;

    function moveToRefuse(uint256 amount) external;

    function retireAll() external;

    function withdraw() external;

    function terminate() external;

    function set() external;


    event Accept(address indexed voter, uint256 amount);
    event RetireAccept(address indexed voter, uint256 amount);
    event MoveToAccept(address indexed voter, uint256 amount);
    event Refuse(address indexed voter, uint256 amount);
    event RetireRefuse(address indexed voter, uint256 amount);
    event MoveToRefuse(address indexed voter, uint256 amount);
    event RetireAll(address indexed voter, uint256 amount);
}pragma solidity ^0.6.0;

interface IStateHolder {


    function init() external;


    function getProxy() external view returns (address);

    function setProxy() external;

    function toJSON() external view returns(string memory);

    function toJSON(uint256 start, uint256 l) external view returns(string memory);

    function getStateSize() external view returns (uint256);

    function exists(string calldata varName) external view returns(bool);

    function getDataType(string calldata varName) external view returns(string memory dataType);

    function clear(string calldata varName) external returns(string memory oldDataType, bytes memory oldVal);

    function setBytes(string calldata varName, bytes calldata val) external returns(bytes memory);

    function getBytes(string calldata varName) external view returns(bytes memory);

    function setString(string calldata varName, string calldata val) external returns(string memory);

    function getString(string calldata varName) external view returns (string memory);

    function setBool(string calldata varName, bool val) external returns(bool);

    function getBool(string calldata varName) external view returns (bool);

    function getUint256(string calldata varName) external view returns (uint256);

    function setUint256(string calldata varName, uint256 val) external returns(uint256);

    function getAddress(string calldata varName) external view returns (address);

    function setAddress(string calldata varName, address val) external returns (address);

}pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.0;

interface IVotingToken {

    function init(string calldata name, string calldata symbol, uint256 decimals, uint256 totalSupply) external;


    function getProxy() external view returns (address);

    function setProxy() external;


    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external view returns(uint256);


    function mint(uint256 amount) external;

    function burn(uint256 amount) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}pragma solidity ^0.6.0;

interface IMVDFunctionalityModelsManager {

    function init() external;

    function checkWellKnownFunctionalities(string calldata codeName, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender, string calldata replaces) external view;

}pragma solidity ^0.6.0;

interface ICommonUtilities {

    function toString(address _addr) external pure returns(string memory);

    function toString(uint _i) external pure returns(string memory);

    function toUint256(bytes calldata bs) external pure returns(uint256 x);

    function toAddress(bytes calldata b) external pure returns (address addr);

    function compareStrings(string calldata a, string calldata b) external pure returns(bool);

    function getFirstJSONPart(address sourceLocation, uint256 sourceLocationId, address location) external pure returns(bytes memory);

    function formatReturnAbiParametersArray(string calldata m) external pure returns(string memory);

    function toLowerCase(string calldata str) external pure returns(string memory);

}pragma solidity ^0.6.0;

interface IMVDFunctionalitiesManager {


    function getProxy() external view returns (address);

    function setProxy() external;


    function init(address sourceLocation,
        uint256 getMinimumBlockNumberSourceLocationId, address getMinimumBlockNumberFunctionalityAddress,
        uint256 getEmergencyMinimumBlockNumberSourceLocationId, address getEmergencyMinimumBlockNumberFunctionalityAddress,
        uint256 getEmergencySurveyStakingSourceLocationId, address getEmergencySurveyStakingFunctionalityAddress,
        uint256 checkVoteResultSourceLocationId, address checkVoteResultFunctionalityAddress) external;


    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender) external;

    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender, uint256 position) external;

    function removeFunctionality(string calldata codeName) external returns(bool removed, uint256 position);

    function isValidFunctionality(address functionality) external view returns(bool);

    function isAuthorizedFunctionality(address functionality) external view returns(bool);

    function setCallingContext(address location) external returns(bool);

    function clearCallingContext() external;

    function getFunctionalityData(string calldata codeName) external view returns(address, uint256, string memory);

    function hasFunctionality(string calldata codeName) external view returns(bool);

    function getFunctionalitiesAmount() external view returns(uint256);

    function functionalitiesToJSON() external view returns(string memory functionsJSONArray);

    function functionalitiesToJSON(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);


    function preConditionCheck(string calldata codeName, bytes calldata data, uint8 submitable, address sender, uint256 value) external view returns(address location, bytes memory payload);


    function setupFunctionality(address proposalAddress) external;

}pragma solidity ^0.6.0;


contract MVDProxy is IMVDProxy {



    address[] private _delegates;

    constructor(address votingTokenAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalityProposalManagerAddress, address functionalitiesManagerAddress) public {
        if(votingTokenAddress == address(0)) {
            return;
        }
        init(votingTokenAddress, stateHolderAddress, functionalityModelsManagerAddress, functionalityProposalManagerAddress, functionalitiesManagerAddress);
    }

    function init(address votingTokenAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalityProposalManagerAddress, address functionalitiesManagerAddress) public override {


        require(_delegates.length == 0, "Init already called!");

        _delegates = new address[](5);

        IVotingToken(_delegates[0] = votingTokenAddress).setProxy();

        IMVDFunctionalityProposalManager(_delegates[1] = functionalityProposalManagerAddress).setProxy();

        IStateHolder(_delegates[2] = stateHolderAddress).setProxy();

        _delegates[3] = functionalityModelsManagerAddress;

        IMVDFunctionalitiesManager(_delegates[4] = functionalitiesManagerAddress).setProxy();

        raiseFunctionalitySetEvent("getMinimumBlockNumberForSurvey");
        raiseFunctionalitySetEvent("getMinimumBlockNumberForEmergencySurvey");
        raiseFunctionalitySetEvent("getEmergencySurveyStaking");
        raiseFunctionalitySetEvent("checkSurveyResult");
        raiseFunctionalitySetEvent("onNewProposal");
    }

    function raiseFunctionalitySetEvent(string memory codeName) private {

        (address addr, uint256 position,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData(codeName);
        if(addr != address(0)) {
            emit FunctionalitySet(codeName, position, address(0), "", address(0), false, "", false, false, address(0), 0);
        }
    }

    receive() external payable {
        if(msg.value > 0) {
            emit PaymentReceived(msg.sender, msg.value);
        }
    }

    function setDelegate(uint256 position, address newAddress) private returns(address oldAddress) {

        require(isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        require(newAddress != address(0), "Cannot set void address!");
        oldAddress = _delegates[position];
        _delegates[position] = newAddress;
        if(position != 3) {
            IMVDProxyDelegate(oldAddress).setProxy();
            IMVDProxyDelegate(newAddress).setProxy();
        }
    }

    function getToken() public override view returns(address) {

        return _delegates[0];
    }

    function setToken(address newAddress) public override {

        emit TokenChanged(setDelegate(0, newAddress), newAddress);
    }

    function getMVDFunctionalityProposalManagerAddress() public override view returns(address) {

        return _delegates[1];
    }

    function setMVDFunctionalityProposalManagerAddress(address newAddress) public override {

        emit MVDFunctionalityProposalManagerChanged(setDelegate(1, newAddress), newAddress);
    }

    function getStateHolderAddress() public override view returns(address) {

        return _delegates[2];
    }

    function setStateHolderAddress(address newAddress) public override {

        emit StateHolderChanged(setDelegate(2, newAddress), newAddress);
    }

    function getMVDFunctionalityModelsManagerAddress() public override view returns(address) {

        return _delegates[3];
    }

    function setMVDFunctionalityModelsManagerAddress(address newAddress) public override {

        emit MVDFunctionalityModelsManagerChanged(setDelegate(3, newAddress), newAddress);
    }

    function getMVDFunctionalitiesManagerAddress() public override view returns(address) {

        return _delegates[4];
    }

    function setMVDFunctionalitiesManagerAddress(address newAddress) public override {

        emit MVDFunctionalitiesManagerChanged(setDelegate(4, newAddress), newAddress);
    }

    function changeProxy(address payable newAddress) public override payable {

        require(isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        require(newAddress != address(0), "Cannot set void address!");
        newAddress.transfer(msg.value);
        IERC20 votingToken = IERC20(_delegates[0]);
        votingToken.transfer(newAddress, votingToken.balanceOf(address(this)));
        IMVDProxyDelegate(_delegates[0]).setProxy();
        IMVDProxyDelegate(_delegates[1]).setProxy();
        IMVDProxyDelegate(_delegates[2]).setProxy();
        IMVDProxyDelegate(_delegates[4]).setProxy();
        IMVDProxy(newAddress).init(_delegates[0], _delegates[2], _delegates[3], _delegates[1], _delegates[4]);
        _delegates = new address[](0);
        emit ProxyChanged(newAddress);
    }

    function getFunctionalitiesAmount() public override view returns(uint256) {

        return IMVDFunctionalitiesManager(_delegates[4]).getFunctionalitiesAmount();
    }

    function isValidProposal(address proposal) public override view returns (bool) {

        return IMVDFunctionalityProposalManager(_delegates[1]).isValidProposal(proposal);
    }

    function isValidFunctionality(address functionality) public override view returns(bool) {

        return IMVDFunctionalitiesManager(_delegates[4]).isValidFunctionality(functionality);
    }

    function isAuthorizedFunctionality(address functionality) public override view returns(bool) {

        return IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(functionality);
    }

    function getFunctionalityAddress(string memory codeName) public override view returns(address location) {

        (location,,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData(codeName);
    }

    function hasFunctionality(string memory codeName) public override view returns(bool) {

        return IMVDFunctionalitiesManager(_delegates[4]).hasFunctionality(codeName);
    }

    function functionalitiesToJSON() public override view returns(string memory functionsJSONArray) {

        return IMVDFunctionalitiesManager(_delegates[4]).functionalitiesToJSON();
    }

    function functionalitiesToJSON(uint256 start, uint256 l) public override view returns(string memory functionsJSONArray) {

        return IMVDFunctionalitiesManager(_delegates[4]).functionalitiesToJSON(start, l);
    }

    function getPendingProposal(string memory codeName) public override view returns(address proposalAddress, bool isReallyPending) {

        (proposalAddress, isReallyPending) = IMVDFunctionalityProposalManager(_delegates[1]).getPendingProposal(codeName);
    }

    function newProposal(string memory codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string memory methodSignature, string memory returnAbiParametersArray, bool isInternal, bool needsSender, string memory replaces) public override returns(address proposalAddress) {

        emergencyBehavior(emergency);

        IMVDFunctionalityModelsManager(_delegates[3]).checkWellKnownFunctionalities(codeName, submitable, methodSignature, returnAbiParametersArray, isInternal, needsSender, replaces);

        IMVDFunctionalityProposal proposal = IMVDFunctionalityProposal(proposalAddress = IMVDFunctionalityProposalManager(_delegates[1]).newProposal(codeName, location, methodSignature, returnAbiParametersArray, replaces));
        proposal.setCollateralData(emergency, sourceLocation, sourceLocationId, submitable, isInternal, needsSender, msg.sender);

        IMVDFunctionalitiesManager functionalitiesManager = IMVDFunctionalitiesManager(_delegates[4]);
        (address loc, , string memory meth) = functionalitiesManager.getFunctionalityData("onNewProposal");
        if(location != address(0)) {
            functionalitiesManager.setCallingContext(location);
            (bool response,) = loc.call(abi.encodeWithSignature(meth, proposalAddress));
            functionalitiesManager.clearCallingContext();
            require(response, "New Proposal check failed!");
        }

        if(!hasFunctionality("startProposal") || !hasFunctionality("disableProposal")) {
            proposal.start();
        }

        emit Proposal(proposalAddress);
    }

    function emergencyBehavior(bool emergency) private {

        if(!emergency) {
            return;
        }
        (address loc, , string memory meth) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData("getEmergencySurveyStaking");
        (, bytes memory payload) = loc.staticcall(abi.encodeWithSignature(meth));
        uint256 staking = toUint256(payload);
        if(staking > 0) {
            IERC20(_delegates[0]).transferFrom(msg.sender, address(this), staking);
        }
    }

    function startProposal(address proposalAddress) public override {

        require(isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        (address location, ,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData("startProposal");
        require(location == msg.sender, "Only startProposal Functionality can enable a delayed proposal");
        require(isValidProposal(proposalAddress), "Invalid Proposal Address!");
        IMVDFunctionalityProposal(proposalAddress).start();
    }

    function disableProposal(address proposalAddress) public override {

        require(isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        (address location, ,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData("disableProposal");
        require(location == msg.sender, "Only disableProposal Functionality can disable a delayed proposal");
        IMVDFunctionalityProposal(proposalAddress).disable();
        IMVDFunctionalityProposalManager(_delegates[1]).disableProposal(proposalAddress);
    }

    function transfer(address receiver, uint256 value, address token) public override {

        require(isAuthorizedFunctionality(msg.sender), "Only functionalities can transfer Proxy balances!");
        if(value == 0) {
            return;
        }
        if(token == address(0)) {
            payable(receiver).transfer(value);
            return;
        }
        IERC20(token).transfer(receiver, value);
    }

    function setProposal() public override {


        IMVDFunctionalityProposalManager(_delegates[1]).checkProposal(msg.sender);

        IMVDFunctionalitiesManager functionalitiesManager = IMVDFunctionalitiesManager(_delegates[4]);

        (address addressToCall, , string memory methodSignature) = functionalitiesManager.getFunctionalityData("checkSurveyResult");

        (bool result, bytes memory response) = addressToCall.staticcall(abi.encodeWithSignature(methodSignature, msg.sender));

        result = toUint256(response) > 0;

        IMVDFunctionalityProposal proposal = IMVDFunctionalityProposal(msg.sender);
        proposal.set();

        (addressToCall, , methodSignature) = functionalitiesManager.getFunctionalityData("proposalEnd");
        if(addressToCall != address(0)) {
            functionalitiesManager.setCallingContext(addressToCall);
            addressToCall.call(abi.encodeWithSignature(methodSignature, msg.sender, result));
            functionalitiesManager.clearCallingContext();
        }

        emit ProposalSet(msg.sender, result);

        if(!result) {
            return;
        }

        if(proposal.isEmergency()) {
            (addressToCall, , methodSignature) = functionalitiesManager.getFunctionalityData("getEmergencySurveyStaking");
            (, response) = addressToCall.staticcall(abi.encodeWithSignature(methodSignature));
            uint256 staking = toUint256(response);
            if(staking > 0) {
                IERC20(_delegates[0]).transfer(proposal.getProposer(), staking);
            }
        }

        functionalitiesManager.setupFunctionality(msg.sender);
    }

    function read(string memory codeName, bytes memory data) public override view returns(bytes memory returnData) {


        (address location, bytes memory payload) = IMVDFunctionalitiesManager(_delegates[4]).preConditionCheck(codeName, data, 0, msg.sender, 0);

        bool ok;
        (ok, returnData) = location.staticcall(payload);

        require(ok, "Failed to read from functionality");
    }

    function submit(string memory codeName, bytes memory data) public override payable returns(bytes memory returnData) {

        IMVDFunctionalitiesManager manager = IMVDFunctionalitiesManager(_delegates[4]);
        (address location, bytes memory payload) = manager.preConditionCheck(codeName, data, 1, msg.sender, msg.value);

        bool changed = manager.setCallingContext(location);

        bool ok;
        (ok, returnData) = location.call(payload);

        if(changed) {
            manager.clearCallingContext();
        }
        require(ok, "Failed to submit functionality");
    }

    function callFromManager(address location, bytes memory payload) public override returns(bool, bytes memory) {

        require(msg.sender == _delegates[4], "Only Manager can call this!");
        return location.call(payload);
    }

    function emitFromManager(string memory codeName, uint256 position, address proposal, string memory replaced, address location, bool submitable, string memory methodSignature, bool isInternal, bool needsSender, address proposalAddress, uint256 replacedPosition) public override {

        require(msg.sender == _delegates[4], "Only Manager can call this!");
        emit FunctionalitySet(codeName, position, proposal, replaced, location, submitable, methodSignature, isInternal, needsSender, proposalAddress, replacedPosition);
    }

    function emitEvent(string memory eventSignature, bytes memory firstIndex, bytes memory secondIndex, bytes memory data) public override {

        require(isAuthorizedFunctionality(msg.sender), "Only authorized functionalities can emit events!");
        emit Event(eventSignature, keccak256(firstIndex), keccak256(secondIndex), data);
    }

    function compareStrings(string memory a, string memory b) private pure returns(bool) {

        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function toUint256(bytes memory bs) internal pure returns(uint256 x) {

        if(bs.length >= 32) {
            assembly {
                x := mload(add(bs, add(0x20, 0)))
            }
        }
    }
}

interface IMVDProxyDelegate {

    function setProxy() external;

}