
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


interface IRiskProviderRegistry {


    function isProvider(address provider) external view returns (bool);


    function getRisk(address riskProvider, address strategy) external view returns (uint8);


    function getRisks(address riskProvider, address[] memory strategies) external view returns (uint8[] memory);



    event RiskAssessed(address indexed provider, address indexed strategy, uint8 riskScore);
    event ProviderAdded(address provider);
    event ProviderRemoved(address provider);
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolOwner {

    function isSpoolOwner(address user) external view returns(bool);

}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract SpoolOwnable {
    ISpoolOwner internal immutable spoolOwner;

    constructor(ISpoolOwner _spoolOwner) {
        require(
            address(_spoolOwner) != address(0),
            "SpoolOwnable::constructor: Spool owner contract address cannot be 0"
        );

        spoolOwner = _spoolOwner;
    }

    function isSpoolOwner() internal view returns(bool) {
        return spoolOwner.isSpoolOwner(msg.sender);
    }


    function _onlyOwner() private view {
        require(isSpoolOwner(), "SpoolOwnable::onlyOwner: Caller is not the Spool owner");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
}// BUSL-1.1

pragma solidity 0.8.11;


interface IFeeHandler {

    function payFees(
        IERC20 underlying,
        uint256 profit,
        address riskProvider,
        address vaultOwner,
        uint16 vaultFee
    ) external returns (uint256 feesPaid);


    function setRiskProviderFee(address riskProvider, uint16 fee) external;



    event FeesPaid(address indexed vault, uint profit, uint ecosystemCollected, uint treasuryCollected, uint riskProviderColected, uint vaultFeeCollected);
    event RiskProviderFeeUpdated(address indexed riskProvider, uint indexed fee);
    event EcosystemFeeUpdated(uint indexed fee);
    event TreasuryFeeUpdated(uint indexed fee);
    event EcosystemCollectorUpdated(address indexed collector);
    event TreasuryCollectorUpdated(address indexed collector);
    event FeeCollected(address indexed collector, IERC20 indexed underlying, uint amount);
    event EcosystemFeeCollected(IERC20 indexed underlying, uint amount);
    event TreasuryFeeCollected(IERC20 indexed underlying, uint amount);
}// BUSL-1.1

pragma solidity 0.8.11;



contract RiskProviderRegistry is IRiskProviderRegistry, SpoolOwnable {


    uint8 public constant MAX_RISK_SCORE = 100;


    IFeeHandler public immutable feeHandler;

    mapping(address => mapping(address => uint8)) private _risk;

    mapping(address => bool) private _provider;


    constructor(
        IFeeHandler _feeHandler,
        ISpoolOwner _spoolOwner
    )
        SpoolOwnable(_spoolOwner)
    {
        require(address(_feeHandler) != address(0), "RiskProviderRegistry::constructor: Fee Handler address cannot be 0");
        feeHandler = _feeHandler;
    }


    function isProvider(address provider) public view override returns (bool) {

        return _provider[provider];
    }

    function getRisks(address riskProvider, address[] memory strategies)
        external
        view
        override
        returns (uint8[] memory)
    {

        uint8[] memory riskScores = new uint8[](strategies.length);
        for (uint256 i = 0; i < strategies.length; i++) {
            riskScores[i] = _risk[riskProvider][strategies[i]];
        }

        return riskScores;
    }

    function getRisk(address riskProvider, address strategy)
        external
        view
        override
        returns (uint8)
    {

        return _risk[riskProvider][strategy];
    }


    function setRisks(address[] memory strategies, uint8[] memory riskScores) external {

        require(
            isProvider(msg.sender),
            "RiskProviderRegistry::setRisks: Insufficient Privileges"
        );

        require(
            strategies.length == riskScores.length,
            "RiskProviderRegistry::setRisks: Strategies and risk scores lengths don't match"
        );    

        for (uint i = 0; i < strategies.length; i++) {
            _setRisk(strategies[i], riskScores[i]);
        }
    }

    function setRisk(address strategy, uint8 riskScore) external {

        require(
            isProvider(msg.sender),
            "RiskProviderRegistry::setRisk: Insufficient Privileges"
        );

        _setRisk(strategy, riskScore);
    }


    function addProvider(address provider, uint16 fee) external onlyOwner {

        require(
            !_provider[provider],
            "RiskProviderRegistry::addProvider: Provider already exists"
        );

        _provider[provider] = true;
        feeHandler.setRiskProviderFee(provider, fee);

        emit ProviderAdded(provider);
    }

    function removeProvider(address provider) external onlyOwner {

        require(
            _provider[provider],
            "RiskProviderRegistry::removeProvider: Provider does not exist"
        );

        _provider[provider] = false;
        feeHandler.setRiskProviderFee(provider, 0);

        emit ProviderRemoved(provider);
    }


    function _setRisk(address strategy, uint8 riskScore) private {

        require(riskScore <= MAX_RISK_SCORE, "RiskProviderRegistry::_setRisk: Risk score too big");

        _risk[msg.sender][strategy] = riskScore;

        emit RiskAssessed(msg.sender, strategy, riskScore);
    }
}