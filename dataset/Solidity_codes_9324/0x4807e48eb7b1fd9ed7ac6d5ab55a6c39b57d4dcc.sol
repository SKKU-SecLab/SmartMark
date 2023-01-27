

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

abstract contract GlobalConfigProxyConstants {
    bytes32
        internal constant EIP_1822_PROXIABLE_UUID = 0xf25d88d51901d7fabc9924b03f4c2fe4300e6fe1aae4b5134c0a90b68cd8e81c;
    bytes32
        internal constant EIP_1967_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract ProxiableGlobalConfigLib is GlobalConfigProxyConstants {
    function __updateCodeAddress(address _nextGlobalConfigLib) internal {
        require(
            ProxiableGlobalConfigLib(_nextGlobalConfigLib).proxiableUUID() ==
                bytes32(EIP_1822_PROXIABLE_UUID),
            "__updateCodeAddress: _nextGlobalConfigLib not compatible"
        );
        assembly {
            sstore(EIP_1967_SLOT, _nextGlobalConfigLib)
        }
    }

    function proxiableUUID() public pure returns (bytes32 uuid_) {
        return EIP_1822_PROXIABLE_UUID;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract GlobalConfigLibBaseCore is ProxiableGlobalConfigLib {
    event GlobalConfigLibSet(address nextGlobalConfigLib);

    address internal dispatcher;

    modifier onlyDispatcherOwner {
        require(
            msg.sender == IDispatcher(getDispatcher()).getOwner(),
            "Only the Dispatcher owner can call this function"
        );

        _;
    }

    function init(address _dispatcher) external {
        require(getDispatcher() == address(0), "init: Proxy already initialized");

        dispatcher = _dispatcher;

        emit GlobalConfigLibSet(getGlobalConfigLib());
    }

    function setGlobalConfigLib(address _nextGlobalConfigLib) external onlyDispatcherOwner {
        __updateCodeAddress(_nextGlobalConfigLib);

        emit GlobalConfigLibSet(_nextGlobalConfigLib);
    }


    function getDispatcher() public view returns (address dispatcher_) {
        return dispatcher;
    }

    function getGlobalConfigLib() public view returns (address globalConfigLib_) {
        assembly {
            globalConfigLib_ := sload(EIP_1967_SLOT)
        }

        return globalConfigLib_;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract GlobalConfigLibBase1 is GlobalConfigLibBaseCore {
    address
        internal constant NO_VALIDATION_DUMMY_ADDRESS = 0x000000000000000000000000000000000000aaaa;
    uint256 internal constant NO_VALIDATION_DUMMY_AMOUNT = type(uint256).max - 1;
}// GPL-3.0


pragma solidity 0.6.12;

interface IGlobalConfig1 {

    function isValidRedeemSharesCall(
        address _vaultProxy,
        address _recipientToValidate,
        uint256 _sharesAmountToValidate,
        address _redeemContract,
        bytes4 _redeemSelector,
        bytes calldata _redeemData
    ) external view returns (bool isValid_);

}// GPL-3.0


pragma solidity 0.6.12;

interface IGlobalConfigVaultAccessGetter {

    function getAccessor() external view returns (address);

}// GPL-3.0


pragma solidity 0.6.12;


contract GlobalConfigLib is IGlobalConfig1, GlobalConfigLibBase1 {

    bytes4 private constant REDEEM_IN_KIND_V4 = 0x6af8e7eb;
    bytes4 private constant REDEEM_SPECIFIC_ASSETS_V4 = 0x3462fcc1;

    address private immutable FUND_DEPLOYER_V4;

    constructor(address _fundDeployerV4) public {
        FUND_DEPLOYER_V4 = _fundDeployerV4;
    }

    function isValidRedeemSharesCall(
        address _vaultProxy,
        address _recipientToValidate,
        uint256 _sharesAmountToValidate,
        address _redeemContract,
        bytes4 _redeemSelector,
        bytes calldata _redeemData
    ) external view override returns (bool isValid_) {

        address fundDeployer = IDispatcher(getDispatcher()).getFundDeployerForVaultProxy(
            _vaultProxy
        );

        if (fundDeployer == FUND_DEPLOYER_V4) {
            if (_redeemContract != IGlobalConfigVaultAccessGetter(_vaultProxy).getAccessor()) {
                return false;
            }

            if (
                !(_redeemSelector == REDEEM_SPECIFIC_ASSETS_V4 ||
                    _redeemSelector == REDEEM_IN_KIND_V4)
            ) {
                return false;
            }

            (address encodedRecipient, uint256 encodedSharesAmount) = abi.decode(
                _redeemData,
                (address, uint256)
            );

            if (
                _recipientToValidate != NO_VALIDATION_DUMMY_ADDRESS &&
                _recipientToValidate != encodedRecipient
            ) {
                return false;
            }

            if (
                _sharesAmountToValidate != NO_VALIDATION_DUMMY_AMOUNT &&
                _sharesAmountToValidate != encodedSharesAmount
            ) {
                return false;
            }

            return true;
        }

        return false;
    }
}