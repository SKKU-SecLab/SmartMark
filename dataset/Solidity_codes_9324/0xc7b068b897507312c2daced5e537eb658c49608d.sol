





pragma solidity 0.5.16;

contract RegistryErrors {

    string constant internal ERROR_REGISTRY_ONLY_INITIALIZER = "REGISTRY:ONLY_INITIALIZER";
    string constant internal ERROR_REGISTRY_ONLY_OPIUM_ADDRESS_ALLOWED = "REGISTRY:ONLY_OPIUM_ADDRESS_ALLOWED";

    string constant internal ERROR_REGISTRY_CANT_BE_ZERO_ADDRESS = "REGISTRY:CANT_BE_ZERO_ADDRESS";

    string constant internal ERROR_REGISTRY_ALREADY_SET = "REGISTRY:ALREADY_SET";
}


pragma solidity 0.5.16;


contract Registry is RegistryErrors {


    address private minter;

    address private core;

    address private oracleAggregator;

    address private syntheticAggregator;

    address private tokenSpender;

    address private opiumAddress;

    address public initializer;

    modifier onlyInitializer() {

        require(msg.sender == initializer, ERROR_REGISTRY_ONLY_INITIALIZER);
        _;
    }

    constructor() public {
        initializer = msg.sender;
    }


    function init(
        address _minter,
        address _core,
        address _oracleAggregator,
        address _syntheticAggregator,
        address _tokenSpender,
        address _opiumAddress
    ) external onlyInitializer {

        require(
            minter == address(0) &&
            core == address(0) &&
            oracleAggregator == address(0) &&
            syntheticAggregator == address(0) &&
            tokenSpender == address(0) &&
            opiumAddress == address(0),
            ERROR_REGISTRY_ALREADY_SET
        );

        require(
            _minter != address(0) &&
            _core != address(0) &&
            _oracleAggregator != address(0) &&
            _syntheticAggregator != address(0) &&
            _tokenSpender != address(0) &&
            _opiumAddress != address(0),
            ERROR_REGISTRY_CANT_BE_ZERO_ADDRESS
        );

        minter = _minter;
        core = _core;
        oracleAggregator = _oracleAggregator;
        syntheticAggregator = _syntheticAggregator;
        tokenSpender = _tokenSpender;
        opiumAddress = _opiumAddress;
    }

    function changeOpiumAddress(address _opiumAddress) external {

        require(opiumAddress == msg.sender, ERROR_REGISTRY_ONLY_OPIUM_ADDRESS_ALLOWED);
        require(_opiumAddress != address(0), ERROR_REGISTRY_CANT_BE_ZERO_ADDRESS);
        opiumAddress = _opiumAddress;
    }


    function getMinter() external view returns (address result) {

        return minter;
    }

    function getCore() external view returns (address result) {

        return core;
    }

    function getOracleAggregator() external view returns (address result) {

        return oracleAggregator;
    }

    function getSyntheticAggregator() external view returns (address result) {

        return syntheticAggregator;
    }

    function getTokenSpender() external view returns (address result) {

        return tokenSpender;
    }

    function getOpiumAddress() external view returns (address result) {

        return opiumAddress;
    }
}