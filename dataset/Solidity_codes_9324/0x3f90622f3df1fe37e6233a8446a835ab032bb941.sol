
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// AGPLv3
pragma solidity ^0.8.0;


contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;

    event LogAddToWhitelist(address indexed user);
    event LogRemoveFromWhitelist(address indexed user);

    modifier onlyWhitelist() {

        require(whitelist[msg.sender], "only whitelist");
        _;
    }

    function addToWhitelist(address user) external onlyOwner {

        require(user != address(0), "WhiteList: 0x");
        whitelist[user] = true;
        emit LogAddToWhitelist(user);
    }

    function removeFromWhitelist(address user) external onlyOwner {

        require(user != address(0), "WhiteList: 0x");
        whitelist[user] = false;
        emit LogRemoveFromWhitelist(user);
    }
}// AGPLV3
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


contract Registry is Whitelist {


    struct contractData {
        uint256 deployedBlock;
        uint256[] startBlock;
        uint256[] endBlock;
        string abiVersion;
        string tag;
        string metaData;
        uint256[] tokens;
        uint256[] protocols;
        bool active;
    }

    mapping(string => address[]) contractMap;
    mapping(address => contractData ) contractInfo;

    mapping(string => bool) activeKey;
    mapping(string => uint256) protocolMap;
    mapping(address => uint256) tokenMap;

    string[] keys;
    string[] protocols;
    address[] tokens;

    event LogNewContract(string indexed contractName, address indexed contractAddress, bool contractTypeActivated);
    event LogNewProtocol(string indexed protocol, uint256 index);
    event LogNewToken(address indexed token, uint256 index);
    event LogAddTokenExposure(address indexed _contract, address[] token);
    event LogAddProtocolExposure(address indexed _contract, string[] protocol);
    event LogRemovedContract(string indexed contractName, address indexed contractAddress);
    event LogContractActivated(string indexed contractName, address indexed contractActivated, address contractDeactivated);
    event LogForceUpdate(address indexed contractAddress,  uint256 _deployed, uint256 _startBlock, uint256 _endBlock);
    event LogForceUpdateMeta(address contractAddress, string _abiVersion, string _tag, string _metaData);

    function getKeys() external view returns (string[] memory) {

        uint256 keyLength = keys.length; 
        string[] memory _keys = new string[](keyLength);
        uint256 j;
        for (uint256 i; i < keyLength; i++) {
            if (contractMap[keys[i]].length != 0) {
                _keys[j] = keys[i];
                j++;
            }
        }
        return _keys;
    }

    function getProtocol(uint256 index) external view returns (string memory) {

        require(protocols.length > 1, 'getProtocol: No protocols added');
        require(index > 0, 'getProtocol: index = 0');
        return protocols[index - 1];
    }

    function getToken(uint256 index) external view returns (address) {

        require(tokens.length > 1, 'getToken: No tokens added');
        require(index > 0, 'getProtocol: index = 0');
        return tokens[index - 1];
    }

    function addTokenExposures(address contractAddress, address[] calldata tokenAddresses) external onlyWhitelist {

        if (tokenAddresses.length > 0) {
            uint256[] memory indexes = convertToTokenIndexs(tokenAddresses);
            delete contractInfo[contractAddress].tokens;
            contractInfo[contractAddress].tokens = indexes;
        } else {
            delete contractInfo[contractAddress].tokens;
        }
        emit LogAddTokenExposure(contractAddress, tokenAddresses);
    }

    function addProtocolExposures(address contractAddress, string[] calldata protocolNames) external onlyWhitelist {

        if (protocolNames.length > 0) {
            uint256[] memory indexes = convertToProtocolIndexs(protocolNames);
            delete contractInfo[contractAddress].protocols;
            contractInfo[contractAddress].protocols = indexes;  
        } else {
            delete contractInfo[contractAddress].protocols;
        }
        emit LogAddProtocolExposure(contractAddress, protocolNames);
    }

    function convertToTokenIndexs(address[] calldata tokenAddresses) public view returns(uint256[] memory) {

        uint256 length = tokenAddresses.length;
        uint256[] memory tokenIndexes = new uint256[](length);
        for(uint256 i; i < length; i++) {
            require(tokenMap[tokenAddresses[i]] != 0, 'convertToTokenIndexs: token not registred');
            tokenIndexes[i] = tokenMap[tokenAddresses[i]];
        }
        return tokenIndexes;
    }

    function convertToProtocolIndexs(string[] calldata protocolNames) public view returns(uint256[] memory) {

        uint256 length = protocolNames.length;
        uint256[] memory protocolIndexes = new uint256[](length);
        for(uint256 i; i < length; i++) {
            require(protocolMap[protocolNames[i]] != 0, 'convertToProtocolIndexs: protocol not registred');
            protocolIndexes[i] = protocolMap[protocolNames[i]];
        }
        return protocolIndexes;
    }

    function newContract(string calldata contractName, address contractAddress, uint256 _deployed, string calldata _abiVersion, string calldata _tag) external onlyWhitelist {

        require(contractInfo[contractAddress].deployedBlock == 0, 'newContract: Already in registry');

        bool newContractType;
        contractMap[contractName].push(contractAddress);
        contractInfo[contractAddress].deployedBlock = _deployed;  
        contractInfo[contractAddress].abiVersion = _abiVersion;  
        contractInfo[contractAddress].tag = _tag;  
        contractInfo[contractAddress].active = false;  
        if (!activeKey[contractName]) {
            newContractType = true;
            activeKey[contractName] = true;
            keys.push(contractName);
        }
        emit LogNewContract(contractName, contractAddress, newContractType);
    }
    function addProtocol(string calldata _protocol) external onlyWhitelist {

        require(protocolMap[_protocol] == 0, 'addProtocol: protocol already added');
        protocols.push(_protocol);
        uint256 position = protocols.length;
        protocolMap[_protocol] = position;
        emit LogNewProtocol(_protocol, position);
    }

    function addToken(address _token) external onlyWhitelist {

        require(tokenMap[_token] == 0, 'addToken: token already added');
        tokens.push(_token);
        uint256 position = tokens.length;
        tokenMap[_token] = position;
        emit LogNewToken(_token, position);
    }

    function removeContract(string calldata contractName) external onlyWhitelist {

        address[] memory contracts = contractMap[contractName];
        require(contracts.length > 0, 'removeContract: No deployed contracts');
        address _contract = contracts[contracts.length - 1];
        contractMap[contractName].pop();
        contractInfo[_contract].deployedBlock = 0;  
        contractInfo[_contract].abiVersion = "";  
        contractInfo[_contract].tag = "";  
        contractInfo[_contract].metaData = "";
        contractInfo[_contract].active = false;
        delete contractInfo[_contract].tokens;
        delete contractInfo[_contract].protocols;

        emit LogRemovedContract(contractName, _contract);
    }

    function forceUpdate(address contractAddress, uint256 _deployed, uint256 _startBlock, uint256 _endBlock) external onlyOwner {

        require(contractInfo[contractAddress].deployedBlock > 0, 'No contract');
        contractInfo[contractAddress].deployedBlock = _deployed;  
        if (_startBlock > 0) {
            contractInfo[contractAddress].startBlock.pop();  
            contractInfo[contractAddress].startBlock.push(_startBlock);  
        }
        if (_endBlock > 0) {
            contractInfo[contractAddress].endBlock.pop();  
            contractInfo[contractAddress].endBlock.push(_endBlock);
        }
        emit LogForceUpdate(contractAddress,  _deployed, _startBlock, _endBlock);
    }

    function forceUpdateMeta(address contractAddress, string calldata _abiVersion, string calldata _tag, string calldata _metaData) external onlyOwner {

        require(contractInfo[contractAddress].deployedBlock > 0, 'No contract');
        contractInfo[contractAddress].abiVersion = _abiVersion;  
        contractInfo[contractAddress].tag = _tag;  
        contractInfo[contractAddress].metaData = _metaData;  
        emit LogForceUpdateMeta(contractAddress, _abiVersion, _tag, _metaData);
    }

    function activateContract(string calldata _contractName, address _contractAddress, uint256 _startBlock) external onlyWhitelist {

        address[] memory contracts = contractMap[_contractName];
        uint256 contractLength = contracts.length;
        require(contractLength > 0, 'No addresses for contracts');
        address deactivated;
        bool newActiveExists;
        for(uint256 i; i < contractLength; i++) {
            if (contracts[i] == _contractAddress) {
                newActiveExists = true;
            }
            if (contractInfo[contracts[i]].active) {
                require(contracts[i] != _contractAddress, 'activateContract: !Already active');
                deactivated = contracts[i];
                contractInfo[contracts[i]].active = false;
                contractInfo[contracts[i]].endBlock.push(_startBlock);  
            }
        }
        require(newActiveExists, 'activateContract: contract not added to group'); 
        contractInfo[_contractAddress].startBlock.push(_startBlock);  
        contractInfo[_contractAddress].active = true;
        emit LogContractActivated(_contractName, _contractAddress, deactivated);
    }

    function setMetaData(address contractAddress, string calldata _metaData) external onlyWhitelist {

        require(contractInfo[contractAddress].deployedBlock > 0, 'No contract');
        contractInfo[contractAddress].metaData = _metaData;  
    }

    function getContractMap(string calldata contractName) external view returns (address[] memory) {

        return contractMap[contractName];
    }

    function getLatestData(string calldata contractName) external view returns (contractData memory data) {

        address[] memory contracts = contractMap[contractName];
        uint256 contractLength = contracts.length;
        if (contractLength > 0) {
            return contractInfo[contracts[contractLength - 1]];
        }
        return contractInfo[address(0)];
    }

    function getLatest(string calldata contractName) external view returns (address) {

        return contractMap[contractName][contractMap[contractName].length - 1];
    }

    function getActiveData(string calldata contractName) external view returns (contractData memory data) {

        address[] memory contracts = contractMap[contractName];
        for(uint256 i; i < contracts.length; i++) {
            if (contractInfo[contracts[i]].active) {
                return contractInfo[contracts[i]];
            }
        }
        return contractInfo[address(0)];
    }

    function getActive(string calldata contractName) external view returns (address) {

        address[] memory contracts = contractMap[contractName];
        for(uint256 i; i < contracts.length; i++) {
            if (contractInfo[contracts[i]].active) {
                return contracts[i];
            }
        }
        return address(0);
    }

    function getContractData(address contractAddress) external view returns (contractData memory) {

        return contractInfo[contractAddress];
    }
}