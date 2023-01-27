



pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}




pragma solidity 0.8.2;

contract FactoryProxy is Initializable {

    event Deployed(
        address addr,
        string proxyName,
        string implName,
        bytes32 salt
    );

    address public factoryOwner;

    address[] public templateCreator;

    struct ProxyTypes {
        bytes templateByteCode;
        address[] adminAddress;
        bool isPublic;
        bool enabled;
    }

    struct ImplementationTypes {
        address templateAddress;
        address[] adminAddress;
        bool isPublic;
        bool enabled;
        bool initialised;
    }

    mapping(string => ImplementationTypes) public implTemplateTypes;

    mapping(string => ProxyTypes) public proxyTemplateTypes;

    constructor(address _factoryOwner) {
        factoryOwner = _factoryOwner;
        templateCreator.push(_factoryOwner);
    }

    function initialize(address _factoryOwner) external initializer {

        factoryOwner = _factoryOwner;
        templateCreator.push(_factoryOwner);
    }



    function getFactoryOwner() external view returns (address) {

        return factoryOwner;
    }

    function getTemplateCreators() external view returns (address[] memory) {

        return templateCreator;
    }

    function getTemplateBytes(string calldata _templateName)
        external
        view
        returns (bytes memory)
    {

        return proxyTemplateTypes[_templateName].templateByteCode;
    }

    function getTemplateAddress(string calldata _templateName)
        external
        view
        returns (address)
    {

        return implTemplateTypes[_templateName].templateAddress;
    }



    function addProxyTemplateType(
        string calldata _templateName,
        bytes memory _templateByteCode,
        bool _isPublic
    ) external onlyFactoryOwnerOrCreator {

        if (proxyTemplateTypes[_templateName].templateByteCode.length > 0) {
            revert("This template name has already been taken");
        }

        ProxyTypes memory tempTemplate;

        tempTemplate.templateByteCode = _templateByteCode;
        tempTemplate.adminAddress = new address[](1);
        tempTemplate.adminAddress[0] = msg.sender;
        tempTemplate.isPublic = _isPublic;
        tempTemplate.enabled = true;

        proxyTemplateTypes[_templateName] = (tempTemplate);
    }

    function toggleProxyStatus(string calldata _templateName)
        external
        onlyFactoryOwner
    {

        proxyTemplateTypes[_templateName].enabled = !proxyTemplateTypes[
            _templateName
        ].enabled;
    }

    function addImplTemplateType(
        string calldata _templateName,
        address _templateAddress,
        bool _isPublic
    ) external onlyFactoryOwnerOrCreator {

        require(
            implTemplateTypes[_templateName].initialised != true,
            "This template name has already been taken"
        );

        implTemplateTypes[_templateName].templateAddress = _templateAddress;
        implTemplateTypes[_templateName].adminAddress = new address[](1);
        implTemplateTypes[_templateName].adminAddress[0] = msg.sender;
        implTemplateTypes[_templateName].isPublic = _isPublic;
        implTemplateTypes[_templateName].enabled = true;
        implTemplateTypes[_templateName].initialised = true;
    }

    function toggleImplStatus(string calldata _templateName)
        external
        onlyFactoryOwner
    {

        implTemplateTypes[_templateName].enabled = !implTemplateTypes[
            _templateName
        ].enabled;
    }

    function setNewFactoryOwner(address _newFactoryOwner)
        external
        onlyFactoryOwner
    {

        factoryOwner = _newFactoryOwner;
    }

    function setTemplateCreator(address _newTemplateCreator)
        external
        onlyFactoryOwner
    {

        for (uint256 i = 0; i < templateCreator.length; i++) {
            if (_newTemplateCreator == templateCreator[i]) {
                revert("Template creator already exists");
            }
        }

        templateCreator.push(_newTemplateCreator);
    }

    function removeTemplateCreator(address _newTemplateCreator)
        external
        onlyFactoryOwner
    {

        for (uint256 i = 0; i < templateCreator.length - 1; i++) {
            if (templateCreator[i] == _newTemplateCreator) {
                templateCreator[i] = templateCreator[i + 1];
            }
        }
        delete templateCreator[templateCreator.length - 1];
    }

    function addImplAdmin(string calldata _pooName, address _newAdmin)
        external
        onlyFactoryOwner
    {

        for (
            uint256 i = 0;
            i < implTemplateTypes[_pooName].adminAddress.length;
            i++
        ) {
            if (implTemplateTypes[_pooName].adminAddress[i] == _newAdmin) {
                revert("This admin already exists");
            }
        }

        implTemplateTypes[_pooName].adminAddress.push(_newAdmin);
    }

    function removeImplAdmin(string calldata _pooName, address _admin)
        external
        onlyFactoryOwner
    {

        for (uint256 i = 0; i < templateCreator.length - 1; i++) {
            if (implTemplateTypes[_pooName].adminAddress[i] == _admin) {
                implTemplateTypes[_pooName].adminAddress[i] = templateCreator[
                    i + 1
                ];
            }
        }
        delete implTemplateTypes[_pooName].adminAddress[
            implTemplateTypes[_pooName].adminAddress.length - 1
        ];
    }

    function addProxyAdmin(string calldata _pooName, address _newAdmin)
        external
        onlyFactoryOwner
    {

        for (
            uint256 i = 0;
            i < proxyTemplateTypes[_pooName].adminAddress.length;
            i++
        ) {
            if (proxyTemplateTypes[_pooName].adminAddress[i] == _newAdmin) {
                revert("This admin already exists");
            }
        }

        proxyTemplateTypes[_pooName].adminAddress.push(_newAdmin);
    }

    function removeProxyAdmin(string calldata _pooName, address _admin)
        external
        onlyFactoryOwner
    {

        for (uint256 i = 0; i < templateCreator.length - 1; i++) {
            if (proxyTemplateTypes[_pooName].adminAddress[i] == _admin) {
                proxyTemplateTypes[_pooName].adminAddress[i] = templateCreator[
                    i + 1
                ];
            }
        }
        delete proxyTemplateTypes[_pooName].adminAddress[
            proxyTemplateTypes[_pooName].adminAddress.length - 1
        ];
    }

    function toggleImplPublic(string calldata _pooName)
        external
        isAdminImpl(_pooName)
    {

        implTemplateTypes[_pooName].isPublic = !implTemplateTypes[_pooName]
            .isPublic;
    }

    function toggleProxyPublic(string calldata _proxyName)
        external
        isAdminProxy(_proxyName)
    {

        proxyTemplateTypes[_proxyName].isPublic = !proxyTemplateTypes[
            _proxyName
        ].isPublic;
    }



    function createTemplate(
        string calldata _proxy,
        string calldata _implementation,
        bytes calldata _args
    )
        external
        isAdminOrPublicImpl(_implementation)
        isAdminOrPublicProxy(_proxy)
        returns (address addr)
    {

        string memory proxy = _proxy;
        string memory implementation = _implementation;

        bytes memory _tempMemory = proxyTemplateTypes[proxy].templateByteCode;
        bytes memory _bytecode = abi.encodePacked(
            _tempMemory,
            abi.encode(
                implTemplateTypes[implementation].templateAddress,
                address(this),
                _args
            )
        );

        bytes32 _salt = keccak256(
            abi.encodePacked(block.number, implementation)
        );

        assembly {
            addr := create2(
                0, // wei sent with current call
                add(_bytecode, 0x20),
                mload(_bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, proxy, implementation, _salt);

        return addr;
    }

    function transact(address _templateAddress, bytes memory _data)
        external
        onlyFactoryOwner
        returns (bool success, bytes memory result)
    {

        (success, result) = _templateAddress.call(_data);
    }



    modifier onlyFactoryOwner() {

        require(msg.sender == factoryOwner);
        _;
    }

    modifier onlyFactoryOwnerOrCreator() {

        bool success = false;

        for (uint256 i = 0; i < templateCreator.length; i++) {
            if (
                templateCreator[i] == msg.sender || factoryOwner == msg.sender
            ) {
                success = true;
            }
        }

        if (success == true) {
            _;
        } else {
            revert("I am neither an admin or creator");
        }
    }

    modifier isAdminOrPublicProxy(string calldata _templateName) {

        require(
            proxyTemplateTypes[_templateName].enabled,
            "Proxy template not enabled"
        );

        if (proxyTemplateTypes[_templateName].isPublic) {
            _;
        } else {
            for (
                uint256 i = 0;
                i < proxyTemplateTypes[_templateName].adminAddress.length;
                i++
            ) {
                if (
                    proxyTemplateTypes[_templateName].adminAddress[i] ==
                    msg.sender ||
                    factoryOwner == msg.sender
                ) {
                    _;
                }
            }
        }
    }

    modifier isAdminOrPublicImpl(string calldata _templateName) {

        require(
            implTemplateTypes[_templateName].enabled,
            "Implementation template not enabled"
        );

        if (implTemplateTypes[_templateName].isPublic) {
            _;
        } else {
            for (
                uint256 i = 0;
                i < implTemplateTypes[_templateName].adminAddress.length;
                i++
            ) {
                if (
                    implTemplateTypes[_templateName].adminAddress[i] ==
                    msg.sender ||
                    factoryOwner == msg.sender
                ) {
                    _;
                }
            }
        }
    }

    modifier isAdminProxy(string calldata _templateName) {

        for (
            uint256 i = 0;
            i < proxyTemplateTypes[_templateName].adminAddress.length;
            i++
        ) {
            if (
                proxyTemplateTypes[_templateName].adminAddress[i] ==
                msg.sender ||
                factoryOwner == msg.sender
            ) {
                _;
            }
        }
    }

    modifier isAdminImpl(string calldata _templateName) {

        for (
            uint256 i = 0;
            i < implTemplateTypes[_templateName].adminAddress.length;
            i++
        ) {
            if (
                implTemplateTypes[_templateName].adminAddress[i] ==
                msg.sender ||
                factoryOwner == msg.sender
            ) {
                _;
            }
        }
    }

}