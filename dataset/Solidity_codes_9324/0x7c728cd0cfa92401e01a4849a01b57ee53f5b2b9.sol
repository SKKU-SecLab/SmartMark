

pragma solidity 0.6.12;

interface IDispatcher {

    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;


    function claimOwnership() external;


    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);


    function executeMigration(address _vaultProxy, bool _bypassFailure) external;


    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);


    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);


    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );


    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);


    function getNominatedOwner() external view returns (address nominatedOwner_);


    function getOwner() external view returns (address owner_);


    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);


    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);


    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);


    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);


    function removeNominatedOwner() external;


    function setCurrentFundDeployer(address _nextFundDeployer) external;


    function setMigrationTimelock(uint256 _nextTimelock) external;


    function setNominatedOwner(address _nextNominatedOwner) external;


    function setSharesTokenSymbol(string calldata _nextSymbol) external;


    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IFundValueCalculator {

    function calcGav(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 gav_);


    function calcGavInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 gav_);


    function calcGrossShareValue(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 grossShareValue_);


    function calcGrossShareValueInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 grossShareValue_);


    function calcNav(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 nav_);


    function calcNavInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 nav_);


    function calcNetShareValue(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 netShareValue_);


    function calcNetShareValueInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 netShareValue_);


    function calcNetValueForSharesHolder(address _vaultProxy, address _sharesHolder)
        external
        returns (address denominationAsset_, uint256 netValue_);


    function calcNetValueForSharesHolderInAsset(
        address _vaultProxy,
        address _sharesHolder,
        address _quoteAsset
    ) external returns (uint256 netValue_);

}// GPL-3.0


pragma solidity 0.6.12;


contract FundValueCalculatorRouter {

    event FundValueCalculatorUpdated(address indexed fundDeployer, address fundValueCalculator);

    address private immutable DISPATCHER;

    mapping(address => address) private fundDeployerToFundValueCalculator;

    constructor(
        address _dispatcher,
        address[] memory _fundDeployers,
        address[] memory _fundValueCalculators
    ) public {
        DISPATCHER = _dispatcher;

        __setFundValueCalculators(_fundDeployers, _fundValueCalculators);
    }


    function calcGav(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 gav_)
    {

        return getFundValueCalculatorForVault(_vaultProxy).calcGav(_vaultProxy);
    }

    function calcGavInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 gav_)
    {

        return
            getFundValueCalculatorForVault(_vaultProxy).calcGavInAsset(_vaultProxy, _quoteAsset);
    }

    function calcGrossShareValue(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 grossShareValue_)
    {

        return getFundValueCalculatorForVault(_vaultProxy).calcGrossShareValue(_vaultProxy);
    }

    function calcGrossShareValueInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 grossShareValue_)
    {

        return
            getFundValueCalculatorForVault(_vaultProxy).calcGrossShareValueInAsset(
                _vaultProxy,
                _quoteAsset
            );
    }

    function calcNav(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 nav_)
    {

        return getFundValueCalculatorForVault(_vaultProxy).calcNav(_vaultProxy);
    }

    function calcNavInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 nav_)
    {

        return
            getFundValueCalculatorForVault(_vaultProxy).calcNavInAsset(_vaultProxy, _quoteAsset);
    }

    function calcNetShareValue(address _vaultProxy)
        external
        returns (address denominationAsset_, uint256 netShareValue_)
    {

        return getFundValueCalculatorForVault(_vaultProxy).calcNetShareValue(_vaultProxy);
    }

    function calcNetShareValueInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 netShareValue_)
    {

        return
            getFundValueCalculatorForVault(_vaultProxy).calcNetShareValueInAsset(
                _vaultProxy,
                _quoteAsset
            );
    }

    function calcNetValueForSharesHolder(address _vaultProxy, address _sharesHolder)
        external
        returns (address denominationAsset_, uint256 netValue_)
    {

        return
            getFundValueCalculatorForVault(_vaultProxy).calcNetValueForSharesHolder(
                _vaultProxy,
                _sharesHolder
            );
    }

    function calcNetValueForSharesHolderInAsset(
        address _vaultProxy,
        address _sharesHolder,
        address _quoteAsset
    ) external returns (uint256 netValue_) {

        return
            getFundValueCalculatorForVault(_vaultProxy).calcNetValueForSharesHolderInAsset(
                _vaultProxy,
                _sharesHolder,
                _quoteAsset
            );
    }


    function getFundValueCalculatorForVault(address _vaultProxy)
        public
        view
        returns (IFundValueCalculator fundValueCalculatorContract_)
    {

        address fundDeployer = IDispatcher(DISPATCHER).getFundDeployerForVaultProxy(_vaultProxy);
        require(fundDeployer != address(0), "getFundValueCalculatorForVault: Invalid _vaultProxy");

        address fundValueCalculator = getFundValueCalculatorForFundDeployer(fundDeployer);
        require(
            fundValueCalculator != address(0),
            "getFundValueCalculatorForVault: No FundValueCalculator set"
        );

        return IFundValueCalculator(fundValueCalculator);
    }


    function setFundValueCalculators(
        address[] memory _fundDeployers,
        address[] memory _fundValueCalculators
    ) external {

        require(
            msg.sender == IDispatcher(getDispatcher()).getOwner(),
            "Only the Dispatcher owner can call this function"
        );

        __setFundValueCalculators(_fundDeployers, _fundValueCalculators);
    }

    function __setFundValueCalculators(
        address[] memory _fundDeployers,
        address[] memory _fundValueCalculators
    ) private {

        require(
            _fundDeployers.length == _fundValueCalculators.length,
            "__setFundValueCalculators: Unequal array lengths"
        );

        for (uint256 i; i < _fundDeployers.length; i++) {
            fundDeployerToFundValueCalculator[_fundDeployers[i]] = _fundValueCalculators[i];

            emit FundValueCalculatorUpdated(_fundDeployers[i], _fundValueCalculators[i]);
        }
    }


    function getDispatcher() public view returns (address dispatcher_) {

        return DISPATCHER;
    }

    function getFundValueCalculatorForFundDeployer(address _fundDeployer)
        public
        view
        returns (address fundValueCalculator_)
    {

        return fundDeployerToFundValueCalculator[_fundDeployer];
    }
}