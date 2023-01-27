
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity 0.6.12;

interface IController {

    function balanceOf(address) external view returns (uint256);

    function earn(address, uint256) external;

    function investEnabled() external view returns (bool);

    function harvestStrategy(address) external;

    function strategyTokens(address) external returns (address);

    function vaults(address) external view returns (address);

    function want(address) external view returns (address);

    function withdraw(address, uint256) external;

    function withdrawFee(address, uint256) external view returns (uint256);

}// MIT

pragma solidity 0.6.12;

interface IHarvester {

    function addStrategy(address, address, uint256) external;

    function removeStrategy(address, address, uint256) external;

}// MIT

pragma solidity 0.6.12;

interface IVaultManager {

    function controllers(address) external view returns (bool);

    function getHarvestFeeInfo() external view returns (address, address, uint256, address, uint256, address, uint256);

    function governance() external view returns (address);

    function harvester() external view returns (address);

    function insuranceFee() external view returns (uint256);

    function insurancePool() external view returns (address);

    function insurancePoolFee() external view returns (uint256);

    function stakingPool() external view returns (address);

    function stakingPoolShareFee() external view returns (uint256);

    function strategist() external view returns (address);

    function treasury() external view returns (address);

    function treasuryBalance() external view returns (uint256);

    function treasuryFee() external view returns (uint256);

    function vaults(address) external view returns (bool);

    function withdrawalProtectionFee() external view returns (uint256);

    function yax() external view returns (address);

}// MIT

pragma solidity 0.6.12;



contract yAxisMetaVaultHarvester is IHarvester { // solhint-disable-line contract-name-camelcase

    using SafeMath for uint256;

    IVaultManager public vaultManager;
    IController public controller;

    struct Strategy {
        uint256 timeout;
        uint256 lastCalled;
        address[] addresses;
    }

    mapping(address => Strategy) public strategies;
    mapping(address => bool) public isHarvester;

    event ControllerSet(address indexed controller);

    event Harvest(
        address indexed controller,
        address indexed strategy
    );

    event HarvesterSet(address indexed harvester, bool status);

    event StrategyAdded(address indexed token, address indexed strategy, uint256 timeout);

    event StrategyRemoved(address indexed token, address indexed strategy, uint256 timeout);

    event VaultManagerSet(address indexed vaultManager);

    constructor(address _vaultManager, address _controller) public {
        vaultManager = IVaultManager(_vaultManager);
        controller = IController(_controller);
    }


    function addStrategy(
        address _token,
        address _strategy,
        uint256 _timeout
    ) external override onlyStrategist {

        strategies[_token].addresses.push(_strategy);
        strategies[_token].timeout = _timeout;
        emit StrategyAdded(_token, _strategy, _timeout);
    }

    function removeStrategy(
        address _token,
        address _strategy,
        uint256 _timeout
    ) external override onlyStrategist {

        uint256 tail = strategies[_token].addresses.length;
        uint256 index;
        bool found;
        for (uint i; i < tail; i++) {
            if (strategies[_token].addresses[i] == _strategy) {
                index = i;
                found = true;
                break;
            }
        }

        if (found) {
            strategies[_token].addresses[index] = strategies[_token].addresses[tail.sub(1)];
            strategies[_token].addresses.pop();
            strategies[_token].timeout = _timeout;
            emit StrategyRemoved(_token, _strategy, _timeout);
        }
    }

    function setController(IController _controller) external onlyStrategist {

        controller = _controller;
        emit ControllerSet(address(_controller));
    }

    function setHarvester(address _harvester, bool _status) public onlyStrategist {

        isHarvester[_harvester] = _status;
        emit HarvesterSet(_harvester, _status);
    }

    function setVaultManager(address _vaultManager) external onlyStrategist {

        vaultManager = IVaultManager(_vaultManager);
        emit VaultManagerSet(_vaultManager);
    }


    function harvest(
        IController _controller,
        address _strategy
    ) public onlyHarvester {

        _controller.harvestStrategy(_strategy);
        emit Harvest(address(_controller), _strategy);
    }

    function harvestNextStrategy(address _token) external {

        require(canHarvest(_token), "!canHarvest");
        address strategy = strategies[_token].addresses[0];
        harvest(controller, strategy);
        uint256 k = strategies[_token].addresses.length;
        if (k > 1) {
            address[] memory _strategies = new address[](k);
            for (uint i; i < k-1; i++) {
                _strategies[i] = strategies[_token].addresses[i+1];
            }
            _strategies[k-1] = strategy;
            strategies[_token].addresses = _strategies;
        }
        strategies[_token].lastCalled = block.timestamp;
    }


    function strategyAddresses(address _token) external view returns (address[] memory) {

        return strategies[_token].addresses;
    }


    function canHarvest(address _token) public view returns (bool) {

        Strategy storage strategy = strategies[_token];
        if (strategy.addresses.length == 0 ||
            strategy.lastCalled > block.timestamp.sub(strategy.timeout)) {
            return false;
        }
        return true;
    }


    modifier onlyHarvester() {

        require(isHarvester[msg.sender], "!harvester");
        _;
    }

    modifier onlyStrategist() {

        require(vaultManager.controllers(msg.sender)
             || msg.sender == vaultManager.strategist()
             || msg.sender == vaultManager.governance(),
             "!strategist"
        );
        _;
    }
}