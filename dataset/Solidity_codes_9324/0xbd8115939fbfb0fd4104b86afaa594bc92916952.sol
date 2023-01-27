pragma solidity ^0.6.0;

interface IMVDProxy {


    function init(address votingTokenAddress, address functionalityProposalManagerAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalitiesManagerAddress, address walletAddress, address doubleProxyAddress) external;


    function getDelegates() external view returns(address[] memory);

    function getToken() external view returns(address);

    function getMVDFunctionalityProposalManagerAddress() external view returns(address);

    function getStateHolderAddress() external view returns(address);

    function getMVDFunctionalityModelsManagerAddress() external view returns(address);

    function getMVDFunctionalitiesManagerAddress() external view returns(address);

    function getMVDWalletAddress() external view returns(address);

    function getDoubleProxyAddress() external view returns(address);

    function setDelegate(uint256 position, address newAddress) external returns(address oldAddress);

    function changeProxy(address newAddress, bytes calldata initPayload) external;

    function isValidProposal(address proposal) external view returns (bool);

    function isAuthorizedFunctionality(address functionality) external view returns(bool);

    function newProposal(string calldata codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnParametersJSONArray, bool isInternal, bool needsSender, string calldata replaces) external returns(address proposalAddress);

    function startProposal(address proposalAddress) external;

    function disableProposal(address proposalAddress) external;

    function transfer(address receiver, uint256 value, address token) external;

    function transfer721(address receiver, uint256 tokenId, bytes calldata data, bool safe, address token) external;

    function flushToWallet(address tokenAddress, bool is721, uint256 tokenId) external;

    function setProposal() external;

    function read(string calldata codeName, bytes calldata data) external view returns(bytes memory returnData);

    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);

    function callFromManager(address location, bytes calldata payload) external returns(bool, bytes memory);

    function emitFromManager(string calldata codeName, address proposal, string calldata replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address location, bool submitable, string calldata methodSignature, bool isInternal, bool needsSender, address proposalAddress) external;


    function emitEvent(string calldata eventSignature, bytes calldata firstIndex, bytes calldata secondIndex, bytes calldata data) external;


    event ProxyChanged(address indexed newAddress);
    event DelegateChanged(uint256 position, address indexed oldAddress, address indexed newAddress);

    event Proposal(address proposal);
    event ProposalCheck(address indexed proposal);
    event ProposalSet(address indexed proposal, bool success);
    event FunctionalitySet(string codeName, address indexed proposal, string replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address indexed replacedLocation, bool replacedWasSubmitable, string replacedMethodSignature, bool replacedWasInternal, bool replacedNeededSender, address indexed replacedProposal);

    event Event(string indexed key, bytes32 indexed firstIndex, bytes32 indexed secondIndex, bytes data);
}pragma solidity ^0.6.0;

interface IMVDFunctionalityProposalManager {

    function newProposal(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces) external returns(address);

    function checkProposal(address proposalAddress) external;

    function getProxy() external view returns (address);

    function setProxy() external;

    function isValidProposal(address proposal) external view returns (bool);

}pragma solidity ^0.6.0;

interface IMVDFunctionalityProposal {


    function init(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces, address proxy) external;

    function setCollateralData(bool emergency, address sourceLocation, uint256 sourceLocationId, bool submitable, bool isInternal, bool needsSender, address proposer, uint256 votesHardCap) external;


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

    function isVotesHardCapReached() external view returns(bool);

    function getVotesHardCapToReach() external view returns(uint256);

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

    function getFunctionalityData(string calldata codeName) external view returns(address, uint256, string memory, address, uint256);

    function hasFunctionality(string calldata codeName) external view returns(bool);

    function getFunctionalitiesAmount() external view returns(uint256);

    function functionalitiesToJSON() external view returns(string memory);

    function functionalitiesToJSON(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);

    function functionalityNames() external view returns(string memory);

    function functionalityNames(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);

    function functionalityToJSON(string calldata codeName) external view returns(string memory);


    function preConditionCheck(string calldata codeName, bytes calldata data, uint8 submitable, address sender, uint256 value) external view returns(address location, bytes memory payload);


    function setupFunctionality(address proposalAddress) external returns (bool);

}pragma solidity ^0.6.0;

interface IMVDWallet {


    function getProxy() external view returns (address);


    function setProxy() external;


    function setNewWallet(address payable newWallet, address tokenAddress) external;


    function transfer(address receiver, uint256 value, address tokenAddress) external;

    
    function transfer(address receiver, uint256 tokenId, bytes calldata data, bool safe, address token) external;


    function flushToNewWallet(address token) external;


    function flush721ToNewWallet(uint256 tokenId, bytes calldata data, bool safe, address tokenAddress) external;

}pragma solidity ^0.6.0;

interface IERC721 {

    function ownerOf(uint256 _tokenId) external view returns (address);

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}pragma solidity ^0.6.0;


contract MVDProxy is IMVDProxy {


    address[] private _delegates;

    constructor(address votingTokenAddress, address functionalityProposalManagerAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalitiesManagerAddress, address walletAddress, address doubleProxyAddress) public {
        if(votingTokenAddress == address(0)) {
            return;
        }
        init(votingTokenAddress, functionalityProposalManagerAddress, stateHolderAddress, functionalityModelsManagerAddress, functionalitiesManagerAddress, walletAddress, doubleProxyAddress);
    }

    function init(address votingTokenAddress, address functionalityProposalManagerAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalitiesManagerAddress, address walletAddress, address doubleProxyAddress) public override {


        require(_delegates.length == 0, "Init already called!");

        _delegates = new address[](7);

        IMVDProxyDelegate(_delegates[0] = votingTokenAddress).setProxy();

        IMVDProxyDelegate(_delegates[1] = functionalityProposalManagerAddress).setProxy();

        IMVDProxyDelegate(_delegates[2] = stateHolderAddress).setProxy();

        _delegates[3] = functionalityModelsManagerAddress;

        IMVDProxyDelegate(_delegates[4] = functionalitiesManagerAddress).setProxy();

        IMVDProxyDelegate(_delegates[5] = walletAddress).setProxy();

        IMVDProxyDelegate(_delegates[6] = doubleProxyAddress).setProxy();
    }

    receive() external payable {
        revert("No Eth Accepted");
    }

    function getDelegates() public override view returns(address[] memory) {

        return _delegates;
    }

    function getToken() public override view returns(address) {

        return _delegates[0];
    }

    function getMVDFunctionalityProposalManagerAddress() public override view returns(address) {

        return _delegates[1];
    }

    function getStateHolderAddress() public override view returns(address) {

        return _delegates[2];
    }

    function getMVDFunctionalityModelsManagerAddress() public override view returns(address) {

        return _delegates[3];
    }

    function getMVDFunctionalitiesManagerAddress() public override view returns(address) {

        return _delegates[4];
    }

    function getMVDWalletAddress() public override view returns(address) {

        return _delegates[5];
    }

    function getDoubleProxyAddress() public override view returns(address) {

        return _delegates[6];
    }

    function flushToWallet(address tokenAddress, bool is721, uint256 tokenId) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        if(tokenAddress == address(0)) {
            payable(_delegates[5]).transfer(payable(address(this)).balance);
            return;
        }
        if(is721) {
            IERC721(tokenAddress).transferFrom(address(this), _delegates[5], tokenId);
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        token.transfer(_delegates[5], token.balanceOf(address(this)));
    }

    function setDelegate(uint256 position, address newAddress) public override returns(address oldAddress) {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        require(newAddress != address(0), "Cannot set void address!");
        if(position == 5) {
            IMVDWallet(_delegates[5]).setNewWallet(payable(newAddress), _delegates[0]);
        }
        oldAddress = _delegates[position];
        _delegates[position] = newAddress;
        if(position != 3) {
            IMVDProxyDelegate(oldAddress).setProxy();
            IMVDProxyDelegate(newAddress).setProxy();
        }
        emit DelegateChanged(position, oldAddress, newAddress);
    }

    function changeProxy(address newAddress, bytes memory initPayload) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        require(newAddress != address(0), "Cannot set void address!");
        for(uint256 i = 0; i < _delegates.length; i++) {
            if(i != 3) {
                IMVDProxyDelegate(_delegates[i]).setProxy();
            }
        }
        _delegates = new address[](0);
        emit ProxyChanged(newAddress);
        (bool response,) = newAddress.call(initPayload);
        require(response, "New Proxy initPayload failed!");
    }

    function isValidProposal(address proposal) public override view returns (bool) {

        return IMVDFunctionalityProposalManager(_delegates[1]).isValidProposal(proposal);
    }

    function isAuthorizedFunctionality(address functionality) public override view returns(bool) {

        return IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(functionality);
    }

    function newProposal(string memory codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string memory methodSignature, string memory returnAbiParametersArray, bool isInternal, bool needsSender, string memory replaces) public override returns(address proposalAddress) {

        emergencyBehavior(emergency);

        IMVDFunctionalityModelsManager(_delegates[3]).checkWellKnownFunctionalities(codeName, submitable, methodSignature, returnAbiParametersArray, isInternal, needsSender, replaces);

        IMVDFunctionalitiesManager functionalitiesManager = IMVDFunctionalitiesManager(_delegates[4]);

        IMVDFunctionalityProposal proposal = IMVDFunctionalityProposal(proposalAddress = IMVDFunctionalityProposalManager(_delegates[1]).newProposal(codeName, location, methodSignature, returnAbiParametersArray, replaces));
        proposal.setCollateralData(emergency, sourceLocation, sourceLocationId, submitable, isInternal, needsSender, msg.sender, functionalitiesManager.hasFunctionality("getVotesHardCap") ? toUint256(read("getVotesHardCap", "")) : 0);

        if(functionalitiesManager.hasFunctionality("onNewProposal")) {
            submit("onNewProposal", abi.encode(proposalAddress));
        }

        if(!IMVDFunctionalitiesManager(_delegates[4]).hasFunctionality("startProposal") || !IMVDFunctionalitiesManager(_delegates[4]).hasFunctionality("disableProposal")) {
            proposal.start();
        }

        emit Proposal(proposalAddress);
    }

    function emergencyBehavior(bool emergency) private {

        if(!emergency) {
            return;
        }
        (address loc, , string memory meth,,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData("getEmergencySurveyStaking");
        (, bytes memory payload) = loc.staticcall(abi.encodeWithSignature(meth));
        uint256 staking = toUint256(payload);
        if(staking > 0) {
            IERC20(_delegates[0]).transferFrom(msg.sender, address(this), staking);
        }
    }

    function startProposal(address proposalAddress) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        (address location,,,,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData("startProposal");
        require(location == msg.sender, "Only startProposal Functionality can enable a delayed proposal");
        require(IMVDFunctionalityProposalManager(_delegates[1]).isValidProposal(proposalAddress), "Invalid Proposal Address!");
        IMVDFunctionalityProposal(proposalAddress).start();
    }

    function disableProposal(address proposalAddress) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Unauthorized action!");
        (address location,,,,) = IMVDFunctionalitiesManager(_delegates[4]).getFunctionalityData("disableProposal");
        require(location == msg.sender, "Only disableProposal Functionality can disable a delayed proposal");
        IMVDFunctionalityProposal(proposalAddress).disable();
    }

    function transfer(address receiver, uint256 value, address token) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Only functionalities can transfer Proxy balances!");
        IMVDWallet(_delegates[5]).transfer(receiver, value, token);
    }

    function transfer721(address receiver, uint256 tokenId, bytes memory data, bool safe, address token) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Only functionalities can transfer Proxy balances!");
        IMVDWallet(_delegates[5]).transfer(receiver, tokenId, data, safe, token);
    }

    function setProposal() public override {


        IMVDFunctionalityProposalManager(_delegates[1]).checkProposal(msg.sender);

        emit ProposalCheck(msg.sender);

        IMVDFunctionalitiesManager functionalitiesManager = IMVDFunctionalitiesManager(_delegates[4]);

        (address addressToCall,,string memory methodSignature,,) = functionalitiesManager.getFunctionalityData("checkSurveyResult");

        (bool surveyResult, bytes memory response) = addressToCall.staticcall(abi.encodeWithSignature(methodSignature, msg.sender));

        surveyResult = toUint256(response) > 0;

        bool collateralCallResult = true;
        (addressToCall,,methodSignature,,) = functionalitiesManager.getFunctionalityData("proposalEnd");
        if(addressToCall != address(0)) {
            functionalitiesManager.setCallingContext(addressToCall);
            (collateralCallResult,) = addressToCall.call(abi.encodeWithSignature(methodSignature, msg.sender, surveyResult));
            functionalitiesManager.clearCallingContext();
        }

        IMVDFunctionalityProposal proposal = IMVDFunctionalityProposal(msg.sender);

        uint256 staking = 0;
        address tokenAddress = _delegates[0];
        address walletAddress = _delegates[5];

        if(proposal.isEmergency()) {
            (addressToCall,,methodSignature,,) = functionalitiesManager.getFunctionalityData("getEmergencySurveyStaking");
            (, response) = addressToCall.staticcall(abi.encodeWithSignature(methodSignature));
            staking = toUint256(response);
        }

        if(!surveyResult) {
            if(collateralCallResult) {
                proposal.set();
                emit ProposalSet(msg.sender, surveyResult);
                if(staking > 0) {
                    IERC20(tokenAddress).transfer(walletAddress, staking);
                }
            }
            return;
        }

        if(collateralCallResult) {
            try functionalitiesManager.setupFunctionality(msg.sender) returns(bool managerResult) {
                collateralCallResult = managerResult;
            } catch {
                collateralCallResult = false;
            }
        }

        if(collateralCallResult) {
            proposal.set();
            emit ProposalSet(msg.sender, surveyResult);
            if(staking > 0) {
                IERC20(tokenAddress).transfer(surveyResult ? proposal.getProposer() : walletAddress, staking);
            }
        }
    }

    function read(string memory codeName, bytes memory data) public override view returns(bytes memory returnData) {


        (address location, bytes memory payload) = IMVDFunctionalitiesManager(_delegates[4]).preConditionCheck(codeName, data, 0, msg.sender, 0);

        bool ok;
        (ok, returnData) = location.staticcall(payload);

        require(ok, "Failed to read from functionality");
    }

    function submit(string memory codeName, bytes memory data) public override payable returns(bytes memory returnData) {


        if(msg.value > 0) {
            payable(_delegates[5]).transfer(msg.value);
        }

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

        require(msg.sender == _delegates[4], "Only Functionalities Manager can call this!");
        return location.call(payload);
    }

    function emitFromManager(string memory codeName, address proposal, string memory replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address location, bool submitable, string memory methodSignature, bool isInternal, bool needsSender, address proposalAddress) public override {

        require(msg.sender == _delegates[4], "Only Functionalities Manager can call this!");
        emit FunctionalitySet(codeName, proposal, replaced, replacedSourceLocation, replacedSourceLocationId, location, submitable, methodSignature, isInternal, needsSender, proposalAddress);
    }

    function emitEvent(string memory eventSignature, bytes memory firstIndex, bytes memory secondIndex, bytes memory data) public override {

        require(IMVDFunctionalitiesManager(_delegates[4]).isAuthorizedFunctionality(msg.sender), "Only authorized functionalities can emit events!");
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

}pragma solidity ^0.6.0;

interface IDoubleProxy {

    function init(address[] calldata proxies, address currentProxy) external;

    function proxy() external view returns(address);

    function setProxy() external;

    function isProxy(address) external view returns(bool);

    function proxiesLength() external view returns(uint256);

    function proxies(uint256 start, uint256 offset) external view returns(address[] memory);

    function proxies() external view returns(address[] memory);

}pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

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

}