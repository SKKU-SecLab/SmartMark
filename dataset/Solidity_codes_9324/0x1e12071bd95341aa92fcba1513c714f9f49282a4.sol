
pragma solidity 0.8.11;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IAaveEcosystemReserveController {

    function approve(
        address collector,
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;


    function transfer(
        address collector,
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;


    function createStream(
        address collector,
        address recipient,
        uint256 deposit,
        IERC20 tokenAddress,
        uint256 startTime,
        uint256 stopTime
    ) external returns (uint256);


    function withdrawFromStream(
        address collector,
        uint256 streamId,
        uint256 funds
    ) external returns (bool);


    function cancelStream(address collector, uint256 streamId)
        external
        returns (bool);

}
interface IStreamable {

    struct Stream {
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 remainingBalance;
        uint256 startTime;
        uint256 stopTime;
        address recipient;
        address sender;
        address tokenAddress;
        bool isEntity;
    }

    event CreateStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime
    );

    event WithdrawFromStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    event CancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    function balanceOf(uint256 streamId, address who)
        external
        view
        returns (uint256 balance);


    function getStream(uint256 streamId)
        external
        view
        returns (
            address sender,
            address recipient,
            uint256 deposit,
            address token,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance,
            uint256 ratePerSecond
        );


    function createStream(
        address recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime
    ) external returns (uint256 streamId);


    function withdrawFromStream(uint256 streamId, uint256 funds)
        external
        returns (bool);


    function cancelStream(uint256 streamId) external returns (bool);


    function initialize(address fundsAdmin) external;

}
interface IInitializableAdminUpgradeabilityProxy {

    function upgradeTo(address newImplementation) external;


    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable;


    function admin() external returns (address);


    function implementation() external returns (address);

}
interface IAdminControlledEcosystemReserve {

    event NewFundsAdmin(address indexed fundsAdmin);

    function ETH_MOCK_ADDRESS() external pure returns (address);


    function getFundsAdmin() external view returns (address);


    function approve(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;


    function transfer(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;

}


contract PayloadAaveBGD {

    IInitializableAdminUpgradeabilityProxy public constant COLLECTOR_V2_PROXY =
        IInitializableAdminUpgradeabilityProxy(
            0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c
        );

    IInitializableAdminUpgradeabilityProxy
        public constant AAVE_TOKEN_COLLECTOR_PROXY =
        IInitializableAdminUpgradeabilityProxy(
            0x25F2226B597E8F9514B3F68F00f494cF4f286491
        );

    address public constant GOV_SHORT_EXECUTOR =
        0xEE56e2B3D491590B5b31738cC34d5232F378a8D5;

    IAaveEcosystemReserveController public constant CONTROLLER_OF_COLLECTOR =
        IAaveEcosystemReserveController(
            0x3d569673dAa0575c936c7c67c4E6AedA69CC630C
        );

    IStreamable public constant ECOSYSTEM_RESERVE_V2_IMPL =
        IStreamable(0x1aa435ed226014407Fa6b889e9d06c02B1a12AF3);

    IERC20 public constant AUSDC =
        IERC20(0xBcca60bB61934080951369a648Fb03DF4F96263C);
    IERC20 public constant ADAI =
        IERC20(0x028171bCA77440897B824Ca71D1c56caC55b68A3);
    IERC20 public constant AUSDT =
        IERC20(0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811);
    IERC20 public constant AAVE =
        IERC20(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);

    uint256 public constant AUSDC_UPFRONT_AMOUNT = 1200000 * 1e6; // 1'200'000 aUSDC
    uint256 public constant ADAI_UPFRONT_AMOUNT = 1000000 ether; // 1'000'000 aDAI
    uint256 public constant AUSDT_UPFRONT_AMOUNT = 1000000 * 1e6; // 1'000'000 aUSDT
    uint256 public constant AAVE_UPFRONT_AMOUNT = 8400 ether; // 8'400 AAVE

    uint256 public constant AUSDC_STREAM_AMOUNT = 4800008160000; // ~4'800'000 aUSDC. A bit more for the streaming requirements
    uint256 public constant AAVE_STREAM_AMOUNT = 12600000000000074880000; // ~12'600 AAVE. A bit more for the streaming requirements
    uint256 public constant STREAMS_DURATION = 450 days; // 15 months of 30 days

    address public constant BGD_RECIPIENT =
        0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF;

    function execute() external {

        COLLECTOR_V2_PROXY.upgradeToAndCall(
            address(ECOSYSTEM_RESERVE_V2_IMPL),
            abi.encodeWithSelector(
                IStreamable.initialize.selector,
                address(CONTROLLER_OF_COLLECTOR)
            )
        );
        AAVE_TOKEN_COLLECTOR_PROXY.upgradeToAndCall(
            address(ECOSYSTEM_RESERVE_V2_IMPL),
            abi.encodeWithSelector(
                IStreamable.initialize.selector,
                address(CONTROLLER_OF_COLLECTOR)
            )
        );
        ECOSYSTEM_RESERVE_V2_IMPL.initialize(address(CONTROLLER_OF_COLLECTOR));

        CONTROLLER_OF_COLLECTOR.transfer(
            address(COLLECTOR_V2_PROXY),
            AUSDC,
            BGD_RECIPIENT,
            AUSDC_UPFRONT_AMOUNT
        );
        CONTROLLER_OF_COLLECTOR.transfer(
            address(COLLECTOR_V2_PROXY),
            ADAI,
            BGD_RECIPIENT,
            ADAI_UPFRONT_AMOUNT
        );
        CONTROLLER_OF_COLLECTOR.transfer(
            address(COLLECTOR_V2_PROXY),
            AUSDT,
            BGD_RECIPIENT,
            AUSDT_UPFRONT_AMOUNT
        );
        CONTROLLER_OF_COLLECTOR.transfer(
            address(AAVE_TOKEN_COLLECTOR_PROXY),
            AAVE,
            BGD_RECIPIENT,
            AAVE_UPFRONT_AMOUNT
        );

        CONTROLLER_OF_COLLECTOR.createStream(
            address(COLLECTOR_V2_PROXY),
            BGD_RECIPIENT,
            AUSDC_STREAM_AMOUNT,
            AUSDC,
            block.timestamp,
            block.timestamp + STREAMS_DURATION
        );
        CONTROLLER_OF_COLLECTOR.createStream(
            address(AAVE_TOKEN_COLLECTOR_PROXY),
            BGD_RECIPIENT,
            AAVE_STREAM_AMOUNT,
            AAVE,
            block.timestamp,
            block.timestamp + STREAMS_DURATION
        );
    }
}