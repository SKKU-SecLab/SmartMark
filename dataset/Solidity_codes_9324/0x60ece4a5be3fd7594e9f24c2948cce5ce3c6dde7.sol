
pragma solidity ^0.4.24;

contract IHandleCampaignDeployment {


    function setInitialParamsCampaign(
        address _twoKeySingletonesRegistry,
        address _twoKeyAcquisitionLogicHandler,
        address _conversionHandler,
        address _moderator,
        address _assetContractERC20,
        address _contractor,
        address _twoKeyEconomy,
        uint [] values
    ) public;


    function setInitialParamsLogicHandler(
        uint [] values,
        string _currency,
        address _assetContractERC20,
        address _moderator,
        address _contractor,
        address _acquisitionCampaignAddress,
        address _twoKeySingletoneRegistry,
        address _twoKeyConversionHandler
    ) public;


    function setInitialParamsConversionHandler(
        uint [] values,
        address _twoKeyAcquisitionCampaignERC20,
        address _twoKeyPurchasesHandler,
        address _contractor,
        address _assetContractERC20,
        address _twoKeySingletonRegistry
    ) public;



    function setInitialParamsPurchasesHandler(
        uint[] values,
        address _contractor,
        address _assetContractERC20,
        address _twoKeyEventSource,
        address _proxyConversionHandler
    ) public;



    function setInitialParamsDonationCampaign(
        address _contractor,
        address _moderator,
        address _twoKeySingletonRegistry,
        address _twoKeyDonationConversionHandler,
        address _twoKeyDonationLogicHandler,
        uint [] numberValues,
        bool [] booleanValues
    ) public;


    function setInitialParamsDonationConversionHandler(
        string tokenName,
        string tokenSymbol,
        string _currency,
        address _contractor,
        address _twoKeyDonationCampaign,
        address _twoKeySingletonRegistry
    ) public;



    function setInitialParamsDonationLogicHandler(
        uint[] numberValues,
        string currency,
        address contractor,
        address moderator,
        address twoKeySingletonRegistry,
        address twoKeyDonationCampaign,
        address twokeyDonationConversionHandler
    ) public;



    function setInitialParamsCPCCampaign(
        address _contractor,
        address _twoKeySingletonRegistry,
        string _url,
        address _mirrorCampaignOnPlasma,
        uint _bountyPerConversion,
        address _twoKeyEconomy
    )
    public;

}

contract IStructuredStorage {


    function setProxyLogicContractAndDeployer(address _proxyLogicContract, address _deployer) external;

    function setProxyLogicContract(address _proxyLogicContract) external;


    function getUint(bytes32 _key) external view returns(uint);

    function getString(bytes32 _key) external view returns(string);

    function getAddress(bytes32 _key) external view returns(address);

    function getBytes(bytes32 _key) external view returns(bytes);

    function getBool(bytes32 _key) external view returns(bool);

    function getInt(bytes32 _key) external view returns(int);

    function getBytes32(bytes32 _key) external view returns(bytes32);


    function getBytes32Array(bytes32 _key) external view returns (bytes32[]);

    function getAddressArray(bytes32 _key) external view returns (address[]);

    function getUintArray(bytes32 _key) external view returns (uint[]);

    function getIntArray(bytes32 _key) external view returns (int[]);

    function getBoolArray(bytes32 _key) external view returns (bool[]);


    function setUint(bytes32 _key, uint _value) external;

    function setString(bytes32 _key, string _value) external;

    function setAddress(bytes32 _key, address _value) external;

    function setBytes(bytes32 _key, bytes _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setInt(bytes32 _key, int _value) external;

    function setBytes32(bytes32 _key, bytes32 _value) external;


    function setBytes32Array(bytes32 _key, bytes32[] _value) external;

    function setAddressArray(bytes32 _key, address[] _value) external;

    function setUintArray(bytes32 _key, uint[] _value) external;

    function setIntArray(bytes32 _key, int[] _value) external;

    function setBoolArray(bytes32 _key, bool[] _value) external;


    function deleteUint(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteAddress(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;

    function deleteBytes32(bytes32 _key) external;

}

contract ITwoKeyCampaignValidator {

    function isCampaignValidated(address campaign) public view returns (bool);

    function validateAcquisitionCampaign(address campaign, string nonSingletonHash) public;

    function validateDonationCampaign(address campaign, address donationConversionHandler, address donationLogicHandler, string nonSingletonHash) public;

    function validateCPCCampaign(address campaign, string nonSingletonHash) public;

}

contract ITwoKeyMaintainersRegistry {

    function checkIsAddressMaintainer(address _sender) public view returns (bool);

    function checkIsAddressCoreDev(address _sender) public view returns (bool);


    function addMaintainers(address [] _maintainers) public;

    function addCoreDevs(address [] _coreDevs) public;

    function removeMaintainers(address [] _maintainers) public;

    function removeCoreDevs(address [] _coreDevs) public;

}

interface ITwoKeySingletonesRegistry {


    event ProxyCreated(address proxy);


    event VersionAdded(string version, address implementation, string contractName);

    function addVersion(string _contractName, string version, address implementation) public;


    function getVersion(string _contractName, string version) public view returns (address);

}

contract TwoKeySingletonRegistryAbstract is ITwoKeySingletonesRegistry {


    address public deployer;

    string congress;
    string maintainersRegistry;

    mapping (string => mapping(string => address)) internal versions;

    mapping (string => address) contractNameToProxyAddress;
    mapping (string => string) contractNameToLatestAddedVersion;
    mapping (string => address) nonUpgradableContractToAddress;
    mapping (string => string) campaignTypeToLastApprovedVersion;


    event ProxiesDeployed(
        address logicProxy,
        address storageProxy
    );

    modifier onlyMaintainer {

        address twoKeyMaintainersRegistry = contractNameToProxyAddress[maintainersRegistry];
        require(msg.sender == deployer || ITwoKeyMaintainersRegistry(twoKeyMaintainersRegistry).checkIsAddressMaintainer(msg.sender));
        _;
    }

    modifier onlyCoreDev {

        address twoKeyMaintainersRegistry = contractNameToProxyAddress[maintainersRegistry];
        require(msg.sender == deployer || ITwoKeyMaintainersRegistry(twoKeyMaintainersRegistry).checkIsAddressCoreDev(msg.sender));
        _;
    }

    function getVersion(
        string contractName,
        string version
    )
    public
    view
    returns (address)
    {

        return versions[contractName][version];
    }



    function getLatestAddedContractVersion(
        string contractName
    )
    public
    view
    returns (string)
    {

        return contractNameToLatestAddedVersion[contractName];
    }


    function getNonUpgradableContractAddress(
        string contractName
    )
    public
    view
    returns (address)
    {

        return nonUpgradableContractToAddress[contractName];
    }

    function getContractProxyAddress(
        string _contractName
    )
    public
    view
    returns (address)
    {

        return contractNameToProxyAddress[_contractName];
    }

    function getLatestCampaignApprovedVersion(
        string campaignType
    )
    public
    view
    returns (string)
    {

        return campaignTypeToLastApprovedVersion[campaignType];
    }


    function addNonUpgradableContractToAddress(
        string contractName,
        address contractAddress
    )
    public
    onlyCoreDev
    {

        require(nonUpgradableContractToAddress[contractName] == 0x0);
        nonUpgradableContractToAddress[contractName] = contractAddress;
    }

    function changeNonUpgradableContract(
        string contractName,
        address contractAddress
    )
    public
    {

        require(msg.sender == nonUpgradableContractToAddress[congress]);
        nonUpgradableContractToAddress[contractName] = contractAddress;
    }


    function addVersion(
        string contractName,
        string version,
        address implementation
    )
    public
    onlyCoreDev
    {

        require(implementation != address(0)); //Require that version implementation is not 0x0
        require(versions[contractName][version] == 0x0); //No overriding of existing versions
        versions[contractName][version] = implementation; //Save the version for the campaign
        contractNameToLatestAddedVersion[contractName] = version;
        emit VersionAdded(version, implementation, contractName);
    }

    function addVersionDuringCreation(
        string contractLogicName,
        string contractStorageName,
        address contractLogicImplementation,
        address contractStorageImplementation,
        string version
    )
    public
    {

        require(msg.sender == deployer);
        bytes memory logicVersion = bytes(contractNameToLatestAddedVersion[contractLogicName]);
        bytes memory storageVersion = bytes(contractNameToLatestAddedVersion[contractStorageName]);

        require(logicVersion.length == 0 && storageVersion.length == 0); //Requiring that this is first time adding a version
        require(keccak256(version) == keccak256("1.0.0")); //Requiring that first version is 1.0.0

        versions[contractLogicName][version] = contractLogicImplementation; //Storing version
        versions[contractStorageName][version] = contractStorageImplementation; //Storing version

        contractNameToLatestAddedVersion[contractLogicName] = version; // Mapping latest contract name to the version
        contractNameToLatestAddedVersion[contractStorageName] = version; //Mapping latest contract name to the version
    }

    function deployProxy(
        string contractName,
        string version
    )
    internal
    returns (address)
    {

        UpgradeabilityProxy proxy = new UpgradeabilityProxy(contractName, version);
        contractNameToProxyAddress[contractName] = proxy;
        emit ProxyCreated(proxy);
        return address(proxy);
    }

    function upgradeContract(
        string contractName,
        string version
    )
    public
    {

        require(msg.sender == nonUpgradableContractToAddress[congress]);
        address proxyAddress = getContractProxyAddress(contractName);
        address _impl = getVersion(contractName, version);

        UpgradeabilityProxy(proxyAddress).upgradeTo(contractName, version, _impl);
    }

    function approveCampaignVersionDuringCreation(
        string campaignType
    )
    public
    onlyCoreDev
    {

        bytes memory campaign = bytes(campaignTypeToLastApprovedVersion[campaignType]);

        require(campaign.length == 0);

        campaignTypeToLastApprovedVersion[campaignType] = "1.0.0";
    }

    function approveCampaignVersion(
        string campaignType,
        string versionToApprove
    )
    public
    {

        require(msg.sender == nonUpgradableContractToAddress[congress]);
        campaignTypeToLastApprovedVersion[campaignType] = versionToApprove;
    }

    function createProxy(
        string contractName,
        string contractNameStorage,
        string version
    )
    public
    {

        require(msg.sender == deployer);
        require(contractNameToProxyAddress[contractName] == address(0));
        address logicProxy = deployProxy(contractName, version);
        address storageProxy = deployProxy(contractNameStorage, version);

        IStructuredStorage(storageProxy).setProxyLogicContractAndDeployer(logicProxy, msg.sender);
        emit ProxiesDeployed(logicProxy, storageProxy);
    }

    function transferOwnership(
        address _newOwner
    )
    public
    {

        require(msg.sender == deployer);
        deployer = _newOwner;
    }



}

contract TwoKeySingletonesRegistry is TwoKeySingletonRegistryAbstract {


    constructor()
    public
    {
        deployer = msg.sender;
        congress = "TwoKeyCongress";
        maintainersRegistry = "TwoKeyMaintainersRegistry";
    }

}

contract Proxy {





    function implementation() public view returns (address);


    function () payable public {
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
}

contract UpgradeabilityStorage {

    ITwoKeySingletonesRegistry internal registry;

    address internal _implementation;

    function implementation() public view returns (address) {

        return _implementation;
    }
}

contract UpgradabilityProxyAcquisition is Proxy, UpgradeabilityStorage {


    constructor (string _contractName, string _version) public {
        registry = ITwoKeySingletonesRegistry(msg.sender);
        _implementation = registry.getVersion(_contractName, _version);
    }
}

contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {


    constructor (string _contractName, string _version) public {
        registry = ITwoKeySingletonesRegistry(msg.sender);
        _implementation = registry.getVersion(_contractName, _version);
    }

    function upgradeTo(string _contractName, string _version, address _impl) public {

        require(msg.sender == address(registry));
        require(_impl != address(0));
        _implementation = _impl;
    }

}

contract Upgradeable is UpgradeabilityStorage {

    function initialize(address sender) public payable {

        require(msg.sender == address(registry));
    }
}