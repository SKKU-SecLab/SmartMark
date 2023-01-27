
pragma solidity ^0.8.0;

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
}// BUSL-1.1

pragma solidity 0.8.11;


interface IController {


    function strategies(uint256 i) external view returns (address);


    function validStrategy(address strategy) external view returns (bool);


    function validVault(address vault) external view returns (bool);


    function getStrategiesCount() external view returns(uint8);


    function supportedUnderlying(IERC20 underlying)
        external
        view
        returns (bool);


    function getAllStrategies() external view returns (address[] memory);


    function verifyStrategies(address[] calldata _strategies) external view;


    function transferToSpool(
        address transferFrom,
        uint256 amount
    ) external;


    function checkPaused() external view;



    event EmergencyWithdrawStrategy(address indexed strategy);
    event EmergencyRecipientUpdated(address indexed recipient);
    event EmergencyWithdrawerUpdated(address indexed withdrawer, bool set);
    event PauserUpdated(address indexed user, bool set);
    event UnpauserUpdated(address indexed user, bool set);
    event VaultCreated(address indexed vault, address underlying, address[] strategies, uint256[] proportions,
        uint16 vaultFee, address riskProvider, int8 riskTolerance);
    event StrategyAdded(address strategy);
    event StrategyRemoved(address strategy);
    event VaultInvalid(address vault);
    event DisableStrategy(address strategy);
}// BUSL-1.1

pragma solidity 0.8.11;

interface IStrategyRegistry {



    function upgradeToAndCall(address strategy, bytes calldata data) external;

    function changeAdmin(address newAdmin) external;

    function addStrategy(address strategy) external;

    function getImplementation(address strategy) view external returns (address);



    event AdminChanged(address previousAdmin, address newAdmin);

    event StrategyUpgraded(address strategy, address newImplementation);

    event StrategyRegistered(address strategy);
}// BUSL-1.1

pragma solidity 0.8.11;


contract StrategyRegistry is IStrategyRegistry {


    IController internal immutable controller;

    address public admin;

    mapping(address => address) private _strategyImplementations;

    constructor(address _admin, IController _controller)
    {
        _setAdmin(_admin);
        controller = _controller;
    }


    function getImplementation(address strategy) view external returns (address) {

        address implementation = _strategyImplementations[strategy];
        require(
            implementation != address(0),
            "StrategyRegistry::getImplementation: Implementation address not set."
        );

        return implementation;
    }

    function upgradeToAndCall(address strategy, bytes calldata data) ifAdmin external {

        (address newImpl) = abi.decode(data, (address));

        require(
            newImpl != address(0) && _strategyImplementations[strategy] != address(0),
            "StrategyRegistry::upgradeToAndCall: Current or previous implementation can not be zero."
        );

        _strategyImplementations[strategy] = newImpl;
        emit StrategyUpgraded(strategy, newImpl);
    }

    function changeAdmin(address newAdmin) external ifAdmin {

        _changeAdmin(newAdmin);
    }

    function addStrategy(address strategy) onlyController external {

        require(
            _strategyImplementations[strategy] == address(0),
            "StrategyRegistry::addStrategy: Can not add if already registered"
        );

        require(
            strategy != address(0),
            "StrategyRegistry::addStrategy: Can not add zero address"
        );

        _strategyImplementations[strategy] = strategy;
        emit StrategyRegistered(strategy);
    }


    function _ifAdmin() view internal {

        require(
            msg.sender == admin,
            "StrategyRegistry::_ifAdmin: Can only be invoked by admin"
        );
    }

    function _changeAdmin(address newAdmin) internal {

        emit AdminChanged(admin, newAdmin);
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) internal {

        require(
            newAdmin != address(0),
            "StrategyRegistry::_setAdmin: newAdmin cannot be zero address."
        );
        admin = newAdmin;
    }

    function _onlyController() internal view {

        require(
            msg.sender == address(controller),
            "StrategyRegistry::_onlyController: Only controller"
        );
    }


    modifier ifAdmin() {

        _ifAdmin();
        _;
    }

    modifier onlyController() {

        _onlyController();
        _;
    }
}