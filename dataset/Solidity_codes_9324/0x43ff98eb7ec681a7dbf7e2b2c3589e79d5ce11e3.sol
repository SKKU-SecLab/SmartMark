
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// agpl-3.0

pragma solidity 0.6.12;


interface IPodOption is IERC20 {

    enum OptionType { PUT, CALL }
    enum ExerciseType { EUROPEAN, AMERICAN }

    event Mint(address indexed minter, uint256 amount);
    event Unmint(address indexed minter, uint256 optionAmount, uint256 strikeAmount, uint256 underlyingAmount);
    event Exercise(address indexed exerciser, uint256 amount);
    event Withdraw(address indexed minter, uint256 strikeAmount, uint256 underlyingAmount);


    function mint(uint256 amountOfOptions, address owner) external;


    function exercise(uint256 amountOfOptions) external;


    function withdraw() external;


    function unmint(uint256 amountOfOptions) external;


    function optionType() external view returns (OptionType);


    function exerciseType() external view returns (ExerciseType);


    function underlyingAsset() external view returns (address);


    function underlyingAssetDecimals() external view returns (uint8);


    function strikeAsset() external view returns (address);


    function strikeAssetDecimals() external view returns (uint8);


    function strikePrice() external view returns (uint256);


    function strikePriceDecimals() external view returns (uint8);


    function expiration() external view returns (uint256);


    function startOfExerciseWindow() external view returns (uint256);


    function hasExpired() external view returns (bool);


    function isTradeWindow() external view returns (bool);


    function isExerciseWindow() external view returns (bool);


    function isWithdrawWindow() external view returns (bool);


    function strikeToTransfer(uint256 amountOfOptions) external view returns (uint256);


    function getSellerWithdrawAmounts(address owner)
        external
        view
        returns (uint256 strikeAmount, uint256 underlyingAmount);


    function underlyingReserves() external view returns (uint256);


    function strikeReserves() external view returns (uint256);

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


interface IOptionBuilder {

    function buildOption(
        string memory _name,
        string memory _symbol,
        IPodOption.ExerciseType _exerciseType,
        address _underlyingAsset,
        address _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiration,
        uint256 _exerciseWindowSize,
        IConfigurationManager _configurationManager
    ) external returns (IPodOption);

}// agpl-3.0

pragma solidity 0.6.12;

contract Conversion {

    function _parseAddressFromUint(uint256 x) internal pure returns (address) {

        bytes memory data = new bytes(32);
        assembly {
            mstore(add(data, 32), x)
        }
        return abi.decode(data, (address));
    }
}// agpl-3.0

pragma solidity 0.6.12;


interface IOptionFactory {

    function createOption(
        string memory _name,
        string memory _symbol,
        IPodOption.OptionType _optionType,
        IPodOption.ExerciseType _exerciseType,
        address _underlyingAsset,
        address _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiration,
        uint256 _exerciseWindowSize,
        bool _isAave
    ) external returns (address);


    function wrappedNetworkTokenAddress() external returns (address);

}// agpl-3.0

pragma solidity 0.6.12;


contract OptionFactory is IOptionFactory, Conversion {

    IConfigurationManager public immutable configurationManager;
    IOptionBuilder public podPutBuilder;
    IOptionBuilder public wPodPutBuilder;
    IOptionBuilder public aavePodPutBuilder;
    IOptionBuilder public podCallBuilder;
    IOptionBuilder public wPodCallBuilder;
    IOptionBuilder public aavePodCallBuilder;

    event OptionCreated(
        address indexed deployer,
        address option,
        IPodOption.OptionType _optionType,
        IPodOption.ExerciseType _exerciseType,
        address underlyingAsset,
        address strikeAsset,
        uint256 strikePrice,
        uint256 expiration,
        uint256 exerciseWindowSize
    );

    constructor(
        address PodPutBuilder,
        address WPodPutBuilder,
        address AavePodPutBuilder,
        address PodCallBuilder,
        address WPodCallBuilder,
        address AavePodCallBuilder,
        address ConfigurationManager
    ) public {
        configurationManager = IConfigurationManager(ConfigurationManager);
        podPutBuilder = IOptionBuilder(PodPutBuilder);
        wPodPutBuilder = IOptionBuilder(WPodPutBuilder);
        aavePodPutBuilder = IOptionBuilder(AavePodPutBuilder);
        podCallBuilder = IOptionBuilder(PodCallBuilder);
        wPodCallBuilder = IOptionBuilder(WPodCallBuilder);
        aavePodCallBuilder = IOptionBuilder(AavePodCallBuilder);
    }

    function createOption(
        string memory name,
        string memory symbol,
        IPodOption.OptionType optionType,
        IPodOption.ExerciseType exerciseType,
        address underlyingAsset,
        address strikeAsset,
        uint256 strikePrice,
        uint256 expiration,
        uint256 exerciseWindowSize,
        bool isAave
    ) external override returns (address) {

        IOptionBuilder builder;
        address wrappedNetworkToken = wrappedNetworkTokenAddress();

        if (optionType == IPodOption.OptionType.PUT) {
            if (underlyingAsset == wrappedNetworkToken) {
                builder = wPodPutBuilder;
            } else if (isAave) {
                builder = aavePodPutBuilder;
            } else {
                builder = podPutBuilder;
            }
        } else {
            if (underlyingAsset == wrappedNetworkToken) {
                builder = wPodCallBuilder;
            } else if (isAave) {
                builder = aavePodCallBuilder;
            } else {
                builder = podCallBuilder;
            }
        }

        address option = address(
            builder.buildOption(
                name,
                symbol,
                exerciseType,
                underlyingAsset,
                strikeAsset,
                strikePrice,
                expiration,
                exerciseWindowSize,
                configurationManager
            )
        );

        emit OptionCreated(
            msg.sender,
            option,
            optionType,
            exerciseType,
            underlyingAsset,
            strikeAsset,
            strikePrice,
            expiration,
            exerciseWindowSize
        );

        return option;
    }

    function wrappedNetworkTokenAddress() public override returns (address) {

        return _parseAddressFromUint(configurationManager.getParameter("WRAPPED_NETWORK_TOKEN"));
    }
}