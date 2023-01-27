

pragma solidity 0.5.7;


contract Proxy {

    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    function implementation() public view returns (address);

}


pragma solidity 0.5.7;



contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    constructor() public {}

    function implementation() public view returns (address impl) {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    function _upgradeTo(address _newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}


pragma solidity 0.5.7;



contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {

        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {

        _upgradeTo(_implementation);
    }

    function _setUpgradeabilityOwner(address _newProxyOwner) internal {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}



pragma solidity 0.5.7;


contract IMaster {

    mapping(address => bool) public whitelistedSponsor;
    function dAppToken() public view returns(address);

    function isInternal(address _address) public view returns(bool);

    function getLatestAddress(bytes2 _module) public view returns(address);

    function isAuthorizedToGovern(address _toCheck) public view returns(bool);

}


contract Governed {


    address public masterAddress; // Name of the dApp, needs to be set by contracts inheriting this contract

    modifier onlyAuthorizedToGovern() {

        IMaster ms = IMaster(masterAddress);
        require(ms.getLatestAddress("GV") == msg.sender, "Not authorized");
        _;
    }

    function isAuthorizedToGovern(address _toCheck) public view returns(bool) {

        IMaster ms = IMaster(masterAddress);
        return (ms.getLatestAddress("GV") == _toCheck);
    } 

}



pragma solidity 0.5.7;


contract IMemberRoles {


    event MemberRole(uint256 indexed roleId, bytes32 roleName, string roleDescription);
    
    enum Role {UnAssigned, AdvisoryBoard, TokenHolder, DisputeResolution}

    function setInititorAddress(address _initiator) external;


    function addRole(bytes32 _roleName, string memory _roleDescription, address _authorized) public;


    function updateRole(address _memberAddress, uint _roleId, bool _active) public;


    function changeAuthorized(uint _roleId, address _authorized) public;


    function totalRoles() public view returns(uint256);


    function members(uint _memberRoleId) public view returns(uint, address[] memory allMemberAddress);


    function numberOfMembers(uint _memberRoleId) public view returns(uint);

    
    function authorized(uint _memberRoleId) public view returns(address);


    function roles(address _memberAddress) public view returns(uint[] memory assignedRoles);


    function checkRole(address _memberAddress, uint _roleId) public view returns(bool);   

}


pragma solidity 0.5.7;

contract IMarketRegistry {


    enum MarketType {
      HourlyMarket,
      DailyMarket,
      WeeklyMarket
    }
    address public owner;
    address public tokenController;
    address public marketUtility;
    bool public marketCreationPaused;

    mapping(address => bool) public isMarket;
    function() external payable{}

    function marketDisputeStatus(address _marketAddress) public view returns(uint _status);


    function burnDisputedProposalTokens(uint _proposaId) external;


    function isWhitelistedSponsor(address _address) public view returns(bool);


    function transferAssets(address _asset, address _to, uint _amount) external;


    function initiate(address _defaultAddress, address _marketConfig, address _plotToken, address payable[] memory _configParams) public;


    function createGovernanceProposal(string memory proposalTitle, string memory description, string memory solutionHash, bytes memory actionHash, uint256 stakeForDispute, address user, uint256 ethSentToPool, uint256 tokenSentToPool, uint256 proposedValue) public {

    }

    function setUserGlobalPredictionData(address _user,uint _value, uint _predictionPoints, address _predictionAsset, uint _prediction,uint _leverage) public{

    }

    function callClaimedEvent(address _user , uint[] memory _reward, address[] memory predictionAssets, uint incentives, address incentiveToken) public {

    }

    function callMarketResultEvent(uint[] memory _totalReward, uint _winningOption, uint _closeValue, uint roundId) public {

    }
}


pragma solidity 0.5.7;

contract IbLOTToken {

    function initiatebLOT(address _defaultMinter) external;

    function convertToPLOT(address _of, address _to, uint256 amount) public;

}


pragma solidity 0.5.7;

contract ITokenController {

	address public token;
    address public bLOTToken;

    function swapBLOT(address _of, address _to, uint256 amount) public;


    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount);


    function transferFrom(address _token, address _of, address _to, uint256 amount) public;


    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount);


    function burnCommissionTokens(uint256 amount) external returns(bool);

 
    function initiateVesting(address _vesting) external;


    function lockForGovernanceVote(address _of, uint _days) public;


    function totalSupply() public view returns (uint256);


    function mint(address _member, uint _amount) public;


}


pragma solidity 0.5.7;

contract Iupgradable {


    function setMasterAddress() public;

}



pragma solidity 0.5.7;








contract Master is Governed {

    bytes2[] public allContractNames;
    address public dAppToken;
    address public dAppLocker;
    bool public masterInitialised;

    mapping(address => bool) public contractsActive;
    mapping(address => bool) public whitelistedSponsor;
    mapping(bytes2 => address payable) public contractAddress;

    modifier onlyAuthorizedToGovern() {

        require(getLatestAddress("GV") == msg.sender, "Not authorized");
        _;
    }

    function initiateMaster(
        address[] calldata _implementations,
        address _token,
        address _defaultAddress,
        address _marketUtiliy,
        address payable[] calldata _configParams,
        address _vesting
    ) external {

        OwnedUpgradeabilityProxy proxy = OwnedUpgradeabilityProxy(
            address(uint160(address(this)))
        );
        require(!masterInitialised);
        require(msg.sender == proxy.proxyOwner(), "Sender is not proxy owner.");
        masterInitialised = true;

        allContractNames.push("MR");
        allContractNames.push("PC");
        allContractNames.push("GV");
        allContractNames.push("PL");
        allContractNames.push("TC");
        allContractNames.push("BL");

        require(
            allContractNames.length == _implementations.length,
            "Implementation length not match"
        );
        contractsActive[address(this)] = true;
        dAppToken = _token;
        for (uint256 i = 0; i < allContractNames.length; i++) {
            _generateProxy(allContractNames[i], _implementations[i]);
        }
        dAppLocker = contractAddress["TC"];

        _setMasterAddress();

        IMarketRegistry(contractAddress["PL"]).initiate(
            _defaultAddress,
            _marketUtiliy,
            _token,
            _configParams
        );
        IbLOTToken(contractAddress["BL"]).initiatebLOT(_defaultAddress);
        ITokenController(contractAddress["TC"]).initiateVesting(_vesting);
        IMemberRoles(contractAddress["MR"]).setInititorAddress(_defaultAddress);
    }

    function addNewContract(bytes2 _contractName, address _contractAddress)
        external
        onlyAuthorizedToGovern
    {

        require(_contractName != "MS", "Name cannot be master");
        require(_contractAddress != address(0), "Zero address");
        require(
            contractAddress[_contractName] == address(0),
            "Contract code already available"
        );
        allContractNames.push(_contractName);
        _generateProxy(_contractName, _contractAddress);
        Iupgradable up = Iupgradable(contractAddress[_contractName]);
        up.setMasterAddress();
    }

    function upgradeMultipleImplementations(
        bytes2[] calldata _contractNames,
        address[] calldata _contractAddresses
    ) external onlyAuthorizedToGovern {

        require(
            _contractNames.length == _contractAddresses.length,
            "Array length should be equal."
        );
        for (uint256 i = 0; i < _contractNames.length; i++) {
            require(
                _contractAddresses[i] != address(0),
                "null address is not allowed."
            );
            _replaceImplementation(_contractNames[i], _contractAddresses[i]);
        }
    }

    function whitelistSponsor(address _address) external onlyAuthorizedToGovern {

        whitelistedSponsor[_address] = true;
    }

    
    function isInternal(address _address) public view returns (bool) {

        return contractsActive[_address];
    }

    function getLatestAddress(bytes2 _contractName)
        public
        view
        returns (address)
    {

        return contractAddress[_contractName];
    }

    function isAuthorizedToGovern(address _toCheck) public view returns (bool) {

        return (getLatestAddress("GV") == _toCheck);
    }

    function _setMasterAddress() internal {

        for (uint256 i = 0; i < allContractNames.length; i++) {
            Iupgradable up = Iupgradable(contractAddress[allContractNames[i]]);
            up.setMasterAddress();
        }
    }

    function _replaceImplementation(
        bytes2 _contractsName,
        address _contractAddress
    ) internal {

        OwnedUpgradeabilityProxy tempInstance = OwnedUpgradeabilityProxy(
            contractAddress[_contractsName]
        );
        tempInstance.upgradeTo(_contractAddress);
    }

    function _generateProxy(bytes2 _contractName, address _contractAddress)
        internal
    {

        OwnedUpgradeabilityProxy tempInstance = new OwnedUpgradeabilityProxy(
            _contractAddress
        );
        contractAddress[_contractName] = address(tempInstance);
        contractsActive[address(tempInstance)] = true;
    }
}