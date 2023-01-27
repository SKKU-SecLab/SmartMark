

pragma solidity 0.5.11;

interface IPriceOracle {

    function price(string calldata symbol) external view returns (uint256);

}


pragma solidity 0.5.11;

interface IEthUsdOracle {

    function ethUsdPrice() external view returns (uint256);


    function tokUsdPrice(string calldata symbol)
        external
        view
        returns (uint256);


    function tokEthPrice(string calldata symbol)
        external
        view
        returns (uint256);

}

interface IViewEthUsdOracle {

    function ethUsdPrice() external view returns (uint256);


    function tokUsdPrice(string calldata symbol)
        external
        view
        returns (uint256);


    function tokEthPrice(string calldata symbol)
        external
        view
        returns (uint256);

}


pragma solidity 0.5.11;

interface IMinMaxOracle {

    function priceMin(string calldata symbol) external view returns (uint256);


    function priceMax(string calldata symbol) external view returns (uint256);

}


pragma solidity 0.5.11;

contract Governable {

    bytes32
        private constant governorPosition = 0x7bea13895fa79d2831e0a9e28edede30099005a50d652d8957cf8a607ee6ca4a;

    bytes32
        private constant pendingGovernorPosition = 0x44c4d30b2eaad5130ad70c3ba6972730566f3e6359ab83e800d905c61b1c51db;

    bytes32
        private constant reentryStatusPosition = 0x53bf423e48ed90e97d02ab0ebab13b2a235a6bfbe9c321847d5c175333ac4535;

    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    event PendingGovernorshipTransfer(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    event GovernorshipTransferred(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    constructor() internal {
        _setGovernor(msg.sender);
        emit GovernorshipTransferred(address(0), _governor());
    }

    function governor() public view returns (address) {

        return _governor();
    }

    function _governor() internal view returns (address governorOut) {

        bytes32 position = governorPosition;
        assembly {
            governorOut := sload(position)
        }
    }

    function _pendingGovernor()
        internal
        view
        returns (address pendingGovernor)
    {

        bytes32 position = pendingGovernorPosition;
        assembly {
            pendingGovernor := sload(position)
        }
    }

    modifier onlyGovernor() {

        require(isGovernor(), "Caller is not the Governor");
        _;
    }

    function isGovernor() public view returns (bool) {

        return msg.sender == _governor();
    }

    function _setGovernor(address newGovernor) internal {

        bytes32 position = governorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    modifier nonReentrant() {

        bytes32 position = reentryStatusPosition;
        uint256 _reentry_status;
        assembly {
            _reentry_status := sload(position)
        }

        require(_reentry_status != _ENTERED, "Reentrant call");

        assembly {
            sstore(position, _ENTERED)
        }

        _;

        assembly {
            sstore(position, _NOT_ENTERED)
        }
    }

    function _setPendingGovernor(address newGovernor) internal {

        bytes32 position = pendingGovernorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    function transferGovernance(address _newGovernor) external onlyGovernor {

        _setPendingGovernor(_newGovernor);
        emit PendingGovernorshipTransfer(_governor(), _newGovernor);
    }

    function claimGovernance() external {

        require(
            msg.sender == _pendingGovernor(),
            "Only the pending Governor can complete the claim"
        );
        _changeGovernor(msg.sender);
    }

    function _changeGovernor(address _newGovernor) internal {

        require(_newGovernor != address(0), "New Governor is address(0)");
        emit GovernorshipTransferred(_governor(), _newGovernor);
        _setGovernor(_newGovernor);
    }
}


pragma solidity 0.5.11;





contract MixOracle is IMinMaxOracle, Governable {

    event DriftsUpdated(uint256 _minDrift, uint256 _maxDrift);
    event EthUsdOracleRegistered(address _oracle);
    event EthUsdOracleDeregistered(address _oracle);
    event TokenOracleRegistered(
        string symbol,
        address[] ethOracles,
        address[] usdOracles
    );

    address[] public ethUsdOracles;

    struct MixConfig {
        address[] usdOracles;
        address[] ethOracles;
    }

    mapping(bytes32 => MixConfig) configs;

    uint256 constant MAX_INT = 2**256 - 1;
    uint256 public maxDrift;
    uint256 public minDrift;

    constructor(uint256 _maxDrift, uint256 _minDrift) public {
        maxDrift = _maxDrift;
        minDrift = _minDrift;
        emit DriftsUpdated(_minDrift, _maxDrift);
    }

    function setMinMaxDrift(uint256 _minDrift, uint256 _maxDrift)
        public
        onlyGovernor
    {

        minDrift = _minDrift;
        maxDrift = _maxDrift;
        emit DriftsUpdated(_minDrift, _maxDrift);
    }

    function registerEthUsdOracle(address oracle) public onlyGovernor {

        for (uint256 i = 0; i < ethUsdOracles.length; i++) {
            require(ethUsdOracles[i] != oracle, "Oracle already registered.");
        }
        ethUsdOracles.push(oracle);
        emit EthUsdOracleRegistered(oracle);
    }

    function unregisterEthUsdOracle(address oracle) public onlyGovernor {

        for (uint256 i = 0; i < ethUsdOracles.length; i++) {
            if (ethUsdOracles[i] == oracle) {
                ethUsdOracles[i] = ethUsdOracles[ethUsdOracles.length - 1];
                delete ethUsdOracles[ethUsdOracles.length - 1];
                emit EthUsdOracleDeregistered(oracle);
                ethUsdOracles.pop();
                return;
            }
        }
        revert("Oracle not found");
    }

    function registerTokenOracles(
        string calldata symbol,
        address[] calldata ethOracles,
        address[] calldata usdOracles
    ) external onlyGovernor {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        config.ethOracles = ethOracles;
        config.usdOracles = usdOracles;
        emit TokenOracleRegistered(symbol, ethOracles, usdOracles);
    }

    function priceMin(string calldata symbol)
        external
        view
        returns (uint256 price)
    {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        uint256 ep;
        uint256 p; //holder variables
        price = MAX_INT;
        if (config.ethOracles.length > 0) {
            ep = MAX_INT;
            for (uint256 i = 0; i < config.ethOracles.length; i++) {
                p = IEthUsdOracle(config.ethOracles[i]).tokEthPrice(symbol);
                if (ep > p) {
                    ep = p;
                }
            }
            price = ep;
            ep = MAX_INT;
            for (uint256 i = 0; i < ethUsdOracles.length; i++) {
                p = IEthUsdOracle(ethUsdOracles[i]).ethUsdPrice();
                if (ep > p) {
                    ep = p;
                }
            }
            if (price != MAX_INT && ep != MAX_INT) {
                price = (price * ep) / 1e6;
            }
        }

        if (config.usdOracles.length > 0) {
            for (uint256 i = 0; i < config.usdOracles.length; i++) {
                p = IPriceOracle(config.usdOracles[i]).price(symbol) * 1e2;
                if (price > p) {
                    price = p;
                }
            }
        }
        require(price <= maxDrift, "Price exceeds maxDrift");
        require(price >= minDrift, "Price below minDrift");
        require(
            price != MAX_INT,
            "None of our oracles returned a valid min price!"
        );
    }

    function priceMax(string calldata symbol)
        external
        view
        returns (uint256 price)
    {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        uint256 ep;
        uint256 p; //holder variables
        price = 0;
        if (config.ethOracles.length > 0) {
            ep = 0;
            for (uint256 i = 0; i < config.ethOracles.length; i++) {
                p = IEthUsdOracle(config.ethOracles[i]).tokEthPrice(symbol);
                if (ep < p) {
                    ep = p;
                }
            }
            price = ep;
            ep = 0;
            for (uint256 i = 0; i < ethUsdOracles.length; i++) {
                p = IEthUsdOracle(ethUsdOracles[i]).ethUsdPrice();
                if (ep < p) {
                    ep = p;
                }
            }
            if (price != 0 && ep != 0) {
                price = (price * ep) / 1e6;
            }
        }

        if (config.usdOracles.length > 0) {
            for (uint256 i = 0; i < config.usdOracles.length; i++) {
                p = IPriceOracle(config.usdOracles[i]).price(symbol) * 1e2;
                if (price < p) {
                    price = p;
                }
            }
        }

        require(price <= maxDrift, "Price exceeds maxDrift");
        require(price >= minDrift, "Price below minDrift");
        require(price != 0, "None of our oracles returned a valid max price!");
    }

    function getTokenUSDOraclesLength(string calldata symbol)
        external
        view
        returns (uint256)
    {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        return config.usdOracles.length;
    }

    function getTokenUSDOracle(string calldata symbol, uint256 idx)
        external
        view
        returns (address)
    {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        return config.usdOracles[idx];
    }

    function getTokenETHOraclesLength(string calldata symbol)
        external
        view
        returns (uint256)
    {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        return config.ethOracles.length;
    }

    function getTokenETHOracle(string calldata symbol, uint256 idx)
        external
        view
        returns (address)
    {

        MixConfig storage config = configs[keccak256(abi.encodePacked(symbol))];
        return config.ethOracles[idx];
    }
}