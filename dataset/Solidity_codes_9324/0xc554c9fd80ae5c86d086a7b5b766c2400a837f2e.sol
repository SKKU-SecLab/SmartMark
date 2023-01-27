
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// agpl-3.0

pragma solidity 0.6.12;

contract ModuleStorage {

    mapping(bytes32 => address) private _addresses;

    event ModuleSet(bytes32 indexed name, address indexed newAddress);

    function getModule(bytes32 name) public view returns (address) {

        return _addresses[name];
    }

    function _setModule(bytes32 name, address module) internal {

        require(module != address(0), "ModuleStorage: Invalid module");
        _addresses[name] = module;
        emit ModuleSet(name, module);
    }
}// agpl-3.0

pragma solidity >=0.6.12;

interface IConfigurationManager {

    function setParameter(bytes32 name, uint256 value) external;


    function setEmergencyStop(address emergencyStop) external;


    function setPricingMethod(address pricingMethod) external;


    function setIVGuesser(address ivGuesser) external;


    function setIVProvider(address ivProvider) external;


    function setPriceProvider(address priceProvider) external;


    function setCapProvider(address capProvider) external;


    function setAMMFactory(address ammFactory) external;


    function setOptionFactory(address optionFactory) external;


    function setOptionHelper(address optionHelper) external;


    function setOptionPoolRegistry(address optionPoolRegistry) external;


    function getParameter(bytes32 name) external view returns (uint256);


    function owner() external view returns (address);


    function getEmergencyStop() external view returns (address);


    function getPricingMethod() external view returns (address);


    function getIVGuesser() external view returns (address);


    function getIVProvider() external view returns (address);


    function getPriceProvider() external view returns (address);


    function getCapProvider() external view returns (address);


    function getAMMFactory() external view returns (address);


    function getOptionFactory() external view returns (address);


    function getOptionHelper() external view returns (address);


    function getOptionPoolRegistry() external view returns (address);

}// agpl-3.0

pragma solidity 0.6.12;


contract ConfigurationManager is IConfigurationManager, ModuleStorage, Ownable {

    mapping(bytes32 => uint256) private _parameters;

    bytes32 private constant EMERGENCY_STOP = "EMERGENCY_STOP";
    bytes32 private constant PRICING_METHOD = "PRICING_METHOD";
    bytes32 private constant IV_GUESSER = "IV_GUESSER";
    bytes32 private constant IV_PROVIDER = "IV_PROVIDER";
    bytes32 private constant PRICE_PROVIDER = "PRICE_PROVIDER";
    bytes32 private constant CAP_PROVIDER = "CAP_PROVIDER";
    bytes32 private constant AMM_FACTORY = "AMM_FACTORY";
    bytes32 private constant OPTION_FACTORY = "OPTION_FACTORY";
    bytes32 private constant OPTION_HELPER = "OPTION_HELPER";
    bytes32 private constant OPTION_POOL_REGISTRY = "OPTION_POOL_REGISTRY";


    event ParameterSet(bytes32 name, uint256 value);

    constructor() public {
        _parameters["MIN_UPDATE_INTERVAL"] = 11100;

        _parameters["GUESSER_ACCEPTABLE_RANGE"] = 10;
    }

    function setParameter(bytes32 name, uint256 value) external override onlyOwner {

        _parameters[name] = value;
        emit ParameterSet(name, value);
    }

    function setEmergencyStop(address emergencyStop) external override onlyOwner {

        _setModule(EMERGENCY_STOP, emergencyStop);
    }

    function setPricingMethod(address pricingMethod) external override onlyOwner {

        _setModule(PRICING_METHOD, pricingMethod);
    }

    function setIVGuesser(address ivGuesser) external override onlyOwner {

        _setModule(IV_GUESSER, ivGuesser);
    }

    function setIVProvider(address ivProvider) external override onlyOwner {

        _setModule(IV_PROVIDER, ivProvider);
    }

    function setPriceProvider(address priceProvider) external override onlyOwner {

        _setModule(PRICE_PROVIDER, priceProvider);
    }

    function setCapProvider(address capProvider) external override onlyOwner {

        _setModule(CAP_PROVIDER, capProvider);
    }

    function setAMMFactory(address ammFactory) external override onlyOwner {

        _setModule(AMM_FACTORY, ammFactory);
    }

    function setOptionFactory(address optionFactory) external override onlyOwner {

        _setModule(OPTION_FACTORY, optionFactory);
    }

    function setOptionHelper(address optionHelper) external override onlyOwner {

        _setModule(OPTION_HELPER, optionHelper);
    }

    function setOptionPoolRegistry(address optionPoolRegistry) external override onlyOwner {

        _setModule(OPTION_POOL_REGISTRY, optionPoolRegistry);
    }

    function getParameter(bytes32 name) external override view returns (uint256) {

        return _parameters[name];
    }

    function getEmergencyStop() external override view returns (address) {

        return getModule(EMERGENCY_STOP);
    }

    function getPricingMethod() external override view returns (address) {

        return getModule(PRICING_METHOD);
    }

    function getIVGuesser() external override view returns (address) {

        return getModule(IV_GUESSER);
    }

    function getIVProvider() external override view returns (address) {

        return getModule(IV_PROVIDER);
    }

    function getPriceProvider() external override view returns (address) {

        return getModule(PRICE_PROVIDER);
    }

    function getCapProvider() external override view returns (address) {

        return getModule(CAP_PROVIDER);
    }

    function getAMMFactory() external override view returns (address) {

        return getModule(AMM_FACTORY);
    }

    function getOptionFactory() external override view returns (address) {

        return getModule(OPTION_FACTORY);
    }

    function getOptionHelper() external override view returns (address) {

        return getModule(OPTION_HELPER);
    }

    function getOptionPoolRegistry() external override view returns (address) {

        return getModule(OPTION_POOL_REGISTRY);
    }

    function owner() public override(Ownable, IConfigurationManager) view returns (address) {

        return super.owner();
    }
}