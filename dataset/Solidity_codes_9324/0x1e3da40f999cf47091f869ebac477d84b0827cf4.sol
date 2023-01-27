

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

interface IExternalPositionVault {

    function getExternalPositionLibForType(uint256) external view returns (address);

}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPosition {

    function getDebtAssets() external returns (address[] memory, uint256[] memory);


    function getManagedAssets() external returns (address[] memory, uint256[] memory);


    function init(bytes memory) external;


    function receiveCallFromVault(bytes memory) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionProxy {

    function getExternalPositionType() external view returns (uint256);


    function getVaultProxy() external view returns (address);

}// GPL-3.0


pragma solidity 0.6.12;


contract ExternalPositionProxy is IExternalPositionProxy {

    uint256 private immutable EXTERNAL_POSITION_TYPE;
    address private immutable VAULT_PROXY;

    receive() external payable {}

    constructor(
        address _vaultProxy,
        uint256 _typeId,
        address _constructLib,
        bytes memory _constructData
    ) public {
        VAULT_PROXY = _vaultProxy;
        EXTERNAL_POSITION_TYPE = _typeId;

        (bool success, bytes memory returnData) = _constructLib.delegatecall(_constructData);

        require(success, string(returnData));
    }

    fallback() external payable {
        address contractLogic = IExternalPositionVault(getVaultProxy())
            .getExternalPositionLibForType(getExternalPositionType());
        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }

    function receiveCallFromVault(bytes calldata _data) external {

        require(
            msg.sender == getVaultProxy(),
            "receiveCallFromVault: Only the vault can make this call"
        );
        address contractLogic = IExternalPositionVault(getVaultProxy())
            .getExternalPositionLibForType(getExternalPositionType());
        (bool success, bytes memory returnData) = contractLogic.delegatecall(
            abi.encodeWithSelector(IExternalPosition.receiveCallFromVault.selector, _data)
        );

        require(success, string(returnData));
    }


    function getExternalPositionType()
        public
        view
        override
        returns (uint256 externalPositionType_)
    {

        return EXTERNAL_POSITION_TYPE;
    }

    function getVaultProxy() public view override returns (address vaultProxy_) {

        return VAULT_PROXY;
    }
}// GPL-3.0


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract ExternalPositionFactory {

    event PositionDeployed(
        address indexed vaultProxy,
        uint256 indexed typeId,
        address indexed constructLib,
        bytes constructData
    );

    event PositionDeployerAdded(address positionDeployer);

    event PositionDeployerRemoved(address positionDeployer);

    event PositionTypeAdded(uint256 typeId, string label);

    event PositionTypeLabelUpdated(uint256 indexed typeId, string label);

    address private immutable DISPATCHER;

    uint256 private positionTypeCounter;
    mapping(uint256 => string) private positionTypeIdToLabel;
    mapping(address => bool) private accountToIsExternalPositionProxy;
    mapping(address => bool) private accountToIsPositionDeployer;

    modifier onlyDispatcherOwner {

        require(
            msg.sender == IDispatcher(getDispatcher()).getOwner(),
            "Only the Dispatcher owner can call this function"
        );
        _;
    }

    constructor(address _dispatcher) public {
        DISPATCHER = _dispatcher;
    }

    function deploy(
        address _vaultProxy,
        uint256 _typeId,
        address _constructLib,
        bytes memory _constructData
    ) external returns (address externalPositionProxy_) {

        require(
            isPositionDeployer(msg.sender),
            "deploy: Only a position deployer can call this function"
        );

        externalPositionProxy_ = address(
            new ExternalPositionProxy(_vaultProxy, _typeId, _constructLib, _constructData)
        );

        accountToIsExternalPositionProxy[externalPositionProxy_] = true;

        emit PositionDeployed(_vaultProxy, _typeId, _constructLib, _constructData);

        return externalPositionProxy_;
    }


    function addNewPositionTypes(string[] calldata _labels) external onlyDispatcherOwner {

        for (uint256 i; i < _labels.length; i++) {
            uint256 typeId = getPositionTypeCounter();
            positionTypeCounter++;

            positionTypeIdToLabel[typeId] = _labels[i];

            emit PositionTypeAdded(typeId, _labels[i]);
        }
    }

    function updatePositionTypeLabels(uint256[] calldata _typeIds, string[] calldata _labels)
        external
        onlyDispatcherOwner
    {

        require(_typeIds.length == _labels.length, "updatePositionTypeLabels: Unequal arrays");
        for (uint256 i; i < _typeIds.length; i++) {
            positionTypeIdToLabel[_typeIds[i]] = _labels[i];

            emit PositionTypeLabelUpdated(_typeIds[i], _labels[i]);
        }
    }


    function addPositionDeployers(address[] memory _accounts) external onlyDispatcherOwner {

        for (uint256 i; i < _accounts.length; i++) {
            require(
                !isPositionDeployer(_accounts[i]),
                "addPositionDeployers: Account is already a position deployer"
            );

            accountToIsPositionDeployer[_accounts[i]] = true;

            emit PositionDeployerAdded(_accounts[i]);
        }
    }

    function removePositionDeployers(address[] memory _accounts) external onlyDispatcherOwner {

        for (uint256 i; i < _accounts.length; i++) {
            require(
                isPositionDeployer(_accounts[i]),
                "removePositionDeployers: Account is not a position deployer"
            );

            accountToIsPositionDeployer[_accounts[i]] = false;

            emit PositionDeployerRemoved(_accounts[i]);
        }
    }



    function getLabelForPositionType(uint256 _typeId)
        external
        view
        returns (string memory label_)
    {

        return positionTypeIdToLabel[_typeId];
    }

    function isExternalPositionProxy(address _account)
        external
        view
        returns (bool isExternalPositionProxy_)
    {

        return accountToIsExternalPositionProxy[_account];
    }


    function getDispatcher() public view returns (address dispatcher_) {

        return DISPATCHER;
    }

    function getPositionTypeCounter() public view returns (uint256 positionTypeCounter_) {

        return positionTypeCounter;
    }

    function isPositionDeployer(address _account) public view returns (bool isPositionDeployer_) {

        return accountToIsPositionDeployer[_account];
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IFreelyTransferableSharesVault {

    function sharesAreFreelyTransferable()
        external
        view
        returns (bool sharesAreFreelyTransferable_);

}// GPL-3.0


pragma solidity 0.6.12;

interface IMigratableVault {

    function canMigrate(address _who) external view returns (bool canMigrate_);


    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external;


    function setAccessor(address _nextAccessor) external;


    function setVaultLib(address _nextVaultLib) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IFundDeployer {

    function getOwner() external view returns (address);


    function hasReconfigurationRequest(address) external view returns (bool);


    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);


    function isAllowedVaultCall(
        address,
        bytes4,
        bytes32
    ) external view returns (bool);

}// GPL-3.0


pragma solidity 0.6.12;


interface IVault is IMigratableVault, IFreelyTransferableSharesVault, IExternalPositionVault {

    enum VaultAction {
        None,
        BurnShares,
        MintShares,
        TransferShares,
        AddTrackedAsset,
        ApproveAssetSpender,
        RemoveTrackedAsset,
        WithdrawAssetTo,
        AddExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition
    }

    function addTrackedAsset(address) external;


    function burnShares(address, uint256) external;


    function buyBackProtocolFeeShares(
        uint256,
        uint256,
        uint256
    ) external;


    function callOnContract(address, bytes calldata) external returns (bytes memory);


    function canManageAssets(address) external view returns (bool);


    function canRelayCalls(address) external view returns (bool);


    function getAccessor() external view returns (address);


    function getOwner() external view returns (address);


    function getActiveExternalPositions() external view returns (address[] memory);


    function getTrackedAssets() external view returns (address[] memory);


    function isActiveExternalPosition(address) external view returns (bool);


    function isTrackedAsset(address) external view returns (bool);


    function mintShares(address, uint256) external;


    function payProtocolFee() external;


    function receiveValidatedVaultAction(VaultAction, bytes calldata) external;


    function setAccessorForFundReconfiguration(address) external;


    function setSymbol(string calldata) external;


    function transferShares(
        address,
        address,
        uint256
    ) external;


    function withdrawAssetTo(
        address,
        address,
        uint256
    ) external;

}// GPL-3.0


pragma solidity 0.6.12;


interface IComptroller {

    function activate(bool) external;


    function calcGav() external returns (uint256);


    function calcGrossShareValue() external returns (uint256);


    function callOnExtension(
        address,
        uint256,
        bytes calldata
    ) external;


    function destructActivated(uint256, uint256) external;


    function destructUnactivated() external;


    function getDenominationAsset() external view returns (address);


    function getExternalPositionManager() external view returns (address);


    function getFeeManager() external view returns (address);


    function getFundDeployer() external view returns (address);


    function getGasRelayPaymaster() external view returns (address);


    function getIntegrationManager() external view returns (address);


    function getPolicyManager() external view returns (address);


    function getVaultProxy() external view returns (address);


    function init(address, uint256) external;


    function permissionedVaultAction(IVault.VaultAction, bytes calldata) external;


    function preTransferSharesHook(
        address,
        address,
        uint256
    ) external;


    function preTransferSharesHookFreelyTransferable(address) external view;


    function setGasRelayPaymaster(address) external;


    function setVaultProxy(address) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IExtension {

    function activateForFund(bool _isMigration) external;


    function deactivateForFund() external;


    function receiveCallFromComptroller(
        address _caller,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external;


    function setConfigForFund(
        address _comptrollerProxy,
        address _vaultProxy,
        bytes calldata _configData
    ) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IPolicyManager {

    enum PolicyHook {
        PostBuyShares,
        PostCallOnIntegration,
        PreTransferShares,
        RedeemSharesForSpecificAssets,
        AddTrackedAssets,
        RemoveTrackedAssets,
        CreateExternalPosition,
        PostCallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function validatePolicies(
        address,
        PolicyHook,
        bytes calldata
    ) external;

}// GPL-3.0


pragma solidity 0.6.12;


abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }


    function getFundDeployer() public view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract ExtensionBase is IExtension, FundDeployerOwnerMixin {
    event ValidatedVaultProxySetForFund(
        address indexed comptrollerProxy,
        address indexed vaultProxy
    );

    mapping(address => address) internal comptrollerProxyToVaultProxy;

    modifier onlyFundDeployer() {
        require(msg.sender == getFundDeployer(), "Only the FundDeployer can make this call");
        _;
    }

    constructor(address _fundDeployer) public FundDeployerOwnerMixin(_fundDeployer) {}

    function activateForFund(bool) external virtual override {
        return;
    }

    function deactivateForFund() external virtual override {
        return;
    }

    function receiveCallFromComptroller(
        address,
        uint256,
        bytes calldata
    ) external virtual override {
        revert("receiveCallFromComptroller: Unimplemented for Extension");
    }

    function setConfigForFund(
        address,
        address,
        bytes calldata
    ) external virtual override {
        return;
    }

    function __setValidatedVaultProxy(address _comptrollerProxy, address _vaultProxy) internal {
        comptrollerProxyToVaultProxy[_comptrollerProxy] = _vaultProxy;

        emit ValidatedVaultProxySetForFund(_comptrollerProxy, _vaultProxy);
    }


    function getVaultProxyForFund(address _comptrollerProxy)
        public
        view
        returns (address vaultProxy_)
    {
        return comptrollerProxyToVaultProxy[_comptrollerProxy];
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PermissionedVaultActionMixin {
    function __addExternalPosition(address _comptrollerProxy, address _externalPosition) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.AddExternalPosition,
            abi.encode(_externalPosition)
        );
    }

    function __addTrackedAsset(address _comptrollerProxy, address _asset) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.AddTrackedAsset,
            abi.encode(_asset)
        );
    }

    function __approveAssetSpender(
        address _comptrollerProxy,
        address _asset,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.ApproveAssetSpender,
            abi.encode(_asset, _target, _amount)
        );
    }

    function __burnShares(
        address _comptrollerProxy,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.BurnShares,
            abi.encode(_target, _amount)
        );
    }

    function __callOnExternalPosition(address _comptrollerProxy, bytes memory _data) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.CallOnExternalPosition,
            _data
        );
    }

    function __mintShares(
        address _comptrollerProxy,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.MintShares,
            abi.encode(_target, _amount)
        );
    }

    function __removeExternalPosition(address _comptrollerProxy, address _externalPosition)
        internal
    {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.RemoveExternalPosition,
            abi.encode(_externalPosition)
        );
    }

    function __removeTrackedAsset(address _comptrollerProxy, address _asset) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.RemoveTrackedAsset,
            abi.encode(_asset)
        );
    }

    function __transferShares(
        address _comptrollerProxy,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.TransferShares,
            abi.encode(_from, _to, _amount)
        );
    }

    function __withdrawAssetTo(
        address _comptrollerProxy,
        address _asset,
        address _target,
        uint256 _amount
    ) internal {
        IComptroller(_comptrollerProxy).permissionedVaultAction(
            IVault.VaultAction.WithdrawAssetTo,
            abi.encode(_asset, _target, _amount)
        );
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionParser {

    function parseAssetsForAction(
        address _externalPosition,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        );


    function parseInitArgs(address _vaultProxy, bytes memory _initializationData)
        external
        returns (bytes memory initArgs_);

}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionManager {

    struct ExternalPositionTypeInfo {
        address parser;
        address lib;
    }
    enum ExternalPositionManagerActions {
        CreateExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function getExternalPositionLibForType(uint256) external view returns (address);

}// GPL-3.0


pragma solidity 0.6.12;


contract ExternalPositionManager is
    IExternalPositionManager,
    ExtensionBase,
    PermissionedVaultActionMixin
{

    event CallOnExternalPositionExecutedForFund(
        address indexed caller,
        address indexed comptrollerProxy,
        address indexed externalPosition,
        uint256 actionId,
        bytes actionArgs,
        address[] assetsToTransfer,
        uint256[] amountsToTransfer,
        address[] assetsToReceive
    );

    event ExternalPositionDeployedForFund(
        address indexed comptrollerProxy,
        address indexed vaultProxy,
        address externalPosition,
        uint256 indexed externalPositionTypeId,
        bytes data
    );

    event ExternalPositionTypeInfoUpdated(uint256 indexed typeId, address lib, address parser);

    address private immutable EXTERNAL_POSITION_FACTORY;
    address private immutable POLICY_MANAGER;

    mapping(uint256 => ExternalPositionTypeInfo) private typeIdToTypeInfo;

    constructor(
        address _fundDeployer,
        address _externalPositionFactory,
        address _policyManager
    ) public ExtensionBase(_fundDeployer) {
        EXTERNAL_POSITION_FACTORY = _externalPositionFactory;
        POLICY_MANAGER = _policyManager;
    }


    function setConfigForFund(
        address _comptrollerProxy,
        address _vaultProxy,
        bytes calldata
    ) external override onlyFundDeployer {

        __setValidatedVaultProxy(_comptrollerProxy, _vaultProxy);
    }


    function receiveCallFromComptroller(
        address _caller,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external override {

        address comptrollerProxy = msg.sender;

        address vaultProxy = getVaultProxyForFund(comptrollerProxy);
        require(vaultProxy != address(0), "receiveCallFromComptroller: Fund is not valid");

        require(
            IVault(vaultProxy).canManageAssets(_caller),
            "receiveCallFromComptroller: Unauthorized"
        );

        if (_actionId == uint256(ExternalPositionManagerActions.CreateExternalPosition)) {
            __createExternalPosition(_caller, comptrollerProxy, vaultProxy, _callArgs);
        } else if (_actionId == uint256(ExternalPositionManagerActions.CallOnExternalPosition)) {
            (
                address externalPosition,
                uint256 actionId,
                bytes memory actionArgs
            ) = __decodeCallOnExternalPositionCallArgs(_callArgs);
            __executeCallOnExternalPosition(
                _caller,
                comptrollerProxy,
                externalPosition,
                actionId,
                actionArgs
            );
        } else if (_actionId == uint256(ExternalPositionManagerActions.RemoveExternalPosition)) {
            __executeRemoveExternalPosition(_caller, comptrollerProxy, _callArgs);
        } else if (
            _actionId == uint256(ExternalPositionManagerActions.ReactivateExternalPosition)
        ) {
            __reactivateExternalPosition(_caller, comptrollerProxy, vaultProxy, _callArgs);
        } else {
            revert("receiveCallFromComptroller: Invalid _actionId");
        }
    }


    function __createExternalPosition(
        address _caller,
        address _comptrollerProxy,
        address _vaultProxy,
        bytes memory _callArgs
    ) private {

        (
            uint256 typeId,
            bytes memory initializationData,
            bytes memory callOnExternalPositionCallArgs
        ) = abi.decode(_callArgs, (uint256, bytes, bytes));

        address parser = getExternalPositionParserForType(typeId);
        require(parser != address(0), "__createExternalPosition: Invalid typeId");

        IPolicyManager(getPolicyManager()).validatePolicies(
            _comptrollerProxy,
            IPolicyManager.PolicyHook.CreateExternalPosition,
            abi.encode(_caller, typeId, initializationData)
        );

        bytes memory initArgs = IExternalPositionParser(parser).parseInitArgs(
            _vaultProxy,
            initializationData
        );

        bytes memory constructData = abi.encodeWithSelector(
            IExternalPosition.init.selector,
            initArgs
        );

        address externalPosition = ExternalPositionFactory(EXTERNAL_POSITION_FACTORY).deploy(
            _vaultProxy,
            typeId,
            getExternalPositionLibForType(typeId),
            constructData
        );

        emit ExternalPositionDeployedForFund(
            _comptrollerProxy,
            _vaultProxy,
            externalPosition,
            typeId,
            initArgs
        );

        __addExternalPosition(_comptrollerProxy, externalPosition);

        if (callOnExternalPositionCallArgs.length != 0) {
            (, uint256 actionId, bytes memory actionArgs) = __decodeCallOnExternalPositionCallArgs(
                callOnExternalPositionCallArgs
            );
            __executeCallOnExternalPosition(
                _caller,
                _comptrollerProxy,
                externalPosition,
                actionId,
                actionArgs
            );
        }
    }

    function __decodeCallOnExternalPositionCallArgs(bytes memory _callArgs)
        private
        pure
        returns (
            address externalPosition_,
            uint256 actionId_,
            bytes memory actionArgs_
        )
    {

        return abi.decode(_callArgs, (address, uint256, bytes));
    }

    function __executeCallOnExternalPosition(
        address _caller,
        address _comptrollerProxy,
        address _externalPosition,
        uint256 _actionId,
        bytes memory _actionArgs
    ) private {

        address parser = getExternalPositionParserForType(
            IExternalPositionProxy(_externalPosition).getExternalPositionType()
        );

        (
            address[] memory assetsToTransfer,
            uint256[] memory amountsToTransfer,
            address[] memory assetsToReceive
        ) = IExternalPositionParser(parser).parseAssetsForAction(
            _externalPosition,
            _actionId,
            _actionArgs
        );

        bytes memory encodedActionData = abi.encode(_actionId, _actionArgs);

        __callOnExternalPosition(
            _comptrollerProxy,
            abi.encode(
                _externalPosition,
                encodedActionData,
                assetsToTransfer,
                amountsToTransfer,
                assetsToReceive
            )
        );

        IPolicyManager(getPolicyManager()).validatePolicies(
            _comptrollerProxy,
            IPolicyManager.PolicyHook.PostCallOnExternalPosition,
            abi.encode(
                _caller,
                _externalPosition,
                assetsToTransfer,
                amountsToTransfer,
                assetsToReceive,
                encodedActionData
            )
        );

        emit CallOnExternalPositionExecutedForFund(
            _caller,
            _comptrollerProxy,
            _externalPosition,
            _actionId,
            _actionArgs,
            assetsToTransfer,
            amountsToTransfer,
            assetsToReceive
        );
    }

    function __executeRemoveExternalPosition(
        address _caller,
        address _comptrollerProxy,
        bytes memory _callArgs
    ) private {

        address externalPosition = abi.decode(_callArgs, (address));

        IPolicyManager(getPolicyManager()).validatePolicies(
            _comptrollerProxy,
            IPolicyManager.PolicyHook.RemoveExternalPosition,
            abi.encode(_caller, externalPosition)
        );

        __removeExternalPosition(_comptrollerProxy, externalPosition);
    }

    function __reactivateExternalPosition(
        address _caller,
        address _comptrollerProxy,
        address _vaultProxy,
        bytes memory _callArgs
    ) private {

        address externalPosition = abi.decode(_callArgs, (address));

        require(
            ExternalPositionFactory(getExternalPositionFactory()).isExternalPositionProxy(
                externalPosition
            ),
            "__reactivateExternalPosition: Account provided is not a valid external position"
        );

        require(
            IExternalPositionProxy(externalPosition).getVaultProxy() == _vaultProxy,
            "__reactivateExternalPosition: External position belongs to a different vault"
        );

        IPolicyManager(getPolicyManager()).validatePolicies(
            _comptrollerProxy,
            IPolicyManager.PolicyHook.ReactivateExternalPosition,
            abi.encode(_caller, externalPosition)
        );

        __addExternalPosition(_comptrollerProxy, externalPosition);
    }


    function updateExternalPositionTypesInfo(
        uint256[] memory _typeIds,
        address[] memory _libs,
        address[] memory _parsers
    ) external onlyFundDeployerOwner {

        require(
            _typeIds.length == _parsers.length && _libs.length == _parsers.length,
            "updateExternalPositionTypesInfo: Unequal arrays"
        );

        for (uint256 i; i < _typeIds.length; i++) {
            require(
                _typeIds[i] <
                    ExternalPositionFactory(getExternalPositionFactory()).getPositionTypeCounter(),
                "updateExternalPositionTypesInfo: Type does not exist"
            );

            typeIdToTypeInfo[_typeIds[i]] = ExternalPositionTypeInfo({
                lib: _libs[i],
                parser: _parsers[i]
            });

            emit ExternalPositionTypeInfoUpdated(_typeIds[i], _libs[i], _parsers[i]);
        }
    }


    function getExternalPositionFactory() public view returns (address externalPositionFactory_) {

        return EXTERNAL_POSITION_FACTORY;
    }

    function getExternalPositionLibForType(uint256 _typeId)
        public
        view
        override
        returns (address lib_)
    {

        return typeIdToTypeInfo[_typeId].lib;
    }

    function getExternalPositionParserForType(uint256 _typeId)
        public
        view
        returns (address parser_)
    {

        return typeIdToTypeInfo[_typeId].parser;
    }

    function getPolicyManager() public view returns (address policyManager_) {

        return POLICY_MANAGER;
    }
}