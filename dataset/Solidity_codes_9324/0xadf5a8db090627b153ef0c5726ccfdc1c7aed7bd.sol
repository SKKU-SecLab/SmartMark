

pragma solidity 0.6.12;

interface IExternalPositionVault {

    function getExternalPositionLibForType(uint256) external view returns (address);

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
pragma experimental ABIEncoderV2;

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


interface IPolicy {

    function activateForFund(address _comptrollerProxy) external;


    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings) external;


    function canDisable() external pure returns (bool canDisable_);


    function identifier() external pure returns (string memory identifier_);


    function implementedHooks()
        external
        pure
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_);


    function updateFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external;


    function validateRule(
        address _comptrollerProxy,
        IPolicyManager.PolicyHook _hook,
        bytes calldata _encodedArgs
    ) external returns (bool isValid_);

}// GPL-3.0


pragma solidity 0.6.12;

interface IBeacon {

    function getCanonicalLib() external view returns (address);

}// GPL-3.0



pragma solidity 0.6.12;

interface IBeaconProxyFactory is IBeacon {

    function deployProxy(bytes memory _constructData) external returns (address proxy_);


    function setCanonicalLib(address _canonicalLib) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IGsnForwarder {

    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IGsnTypes {

    struct RelayData {
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IGsnForwarder.ForwardRequest request;
        RelayData relayData;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IGsnPaymaster {

    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits() external view returns (GasAndDataLimits memory limits);


    function getHubAddr() external view returns (address);


    function getRelayHubDeposit() external view returns (uint256);


    function preRelayedCall(
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    ) external returns (bytes memory context, bool rejectOnRecipientRevert);


    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        IGsnTypes.RelayData calldata relayData
    ) external;


    function trustedForwarder() external view returns (address);


    function versionPaymaster() external view returns (string memory);

}// GPL-3.0


pragma solidity 0.6.12;


interface IGasRelayPaymaster is IGsnPaymaster {

    function deposit() external;


    function withdrawBalance() external;

}// GPL-3.0



pragma solidity 0.6.12;

abstract contract GasRelayRecipientMixin {
    address internal immutable GAS_RELAY_PAYMASTER_FACTORY;

    constructor(address _gasRelayPaymasterFactory) internal {
        GAS_RELAY_PAYMASTER_FACTORY = _gasRelayPaymasterFactory;
    }

    function __msgSender() internal view returns (address payable canonicalSender_) {
        if (msg.data.length >= 24 && msg.sender == getGasRelayTrustedForwarder()) {
            assembly {
                canonicalSender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return canonicalSender_;
        }

        return msg.sender;
    }


    function getGasRelayPaymasterFactory()
        public
        view
        returns (address gasRelayPaymasterFactory_)
    {
        return GAS_RELAY_PAYMASTER_FACTORY;
    }

    function getGasRelayTrustedForwarder() public view returns (address trustedForwarder_) {
        return
            IGasRelayPaymaster(
                IBeaconProxyFactory(getGasRelayPaymasterFactory()).getCanonicalLib()
            )
                .trustedForwarder();
    }
}// GPL-3.0


pragma solidity 0.6.12;

library AddressArrayLib {


    function removeStorageItem(address[] storage _self, address _itemToRemove)
        internal
        returns (bool removed_)
    {

        uint256 itemCount = _self.length;
        for (uint256 i; i < itemCount; i++) {
            if (_self[i] == _itemToRemove) {
                if (i < itemCount - 1) {
                    _self[i] = _self[itemCount - 1];
                }
                _self.pop();
                removed_ = true;
                break;
            }
        }

        return removed_;
    }


    function addItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {

        nextArray_ = new address[](_self.length + 1);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        nextArray_[_self.length] = _itemToAdd;

        return nextArray_;
    }

    function addUniqueItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {

        if (contains(_self, _itemToAdd)) {
            return _self;
        }

        return addItem(_self, _itemToAdd);
    }

    function contains(address[] memory _self, address _target)
        internal
        pure
        returns (bool doesContain_)
    {

        for (uint256 i; i < _self.length; i++) {
            if (_target == _self[i]) {
                return true;
            }
        }
        return false;
    }

    function mergeArray(address[] memory _self, address[] memory _arrayToMerge)
        internal
        pure
        returns (address[] memory nextArray_)
    {

        uint256 newUniqueItemCount;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                newUniqueItemCount++;
            }
        }

        if (newUniqueItemCount == 0) {
            return _self;
        }

        nextArray_ = new address[](_self.length + newUniqueItemCount);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        uint256 nextArrayIndex = _self.length;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                nextArray_[nextArrayIndex] = _arrayToMerge[i];
                nextArrayIndex++;
            }
        }

        return nextArray_;
    }

    function isUniqueSet(address[] memory _self) internal pure returns (bool isUnique_) {

        if (_self.length <= 1) {
            return true;
        }

        uint256 arrayLength = _self.length;
        for (uint256 i; i < arrayLength; i++) {
            for (uint256 j = i + 1; j < arrayLength; j++) {
                if (_self[i] == _self[j]) {
                    return false;
                }
            }
        }

        return true;
    }

    function removeItems(address[] memory _self, address[] memory _itemsToRemove)
        internal
        pure
        returns (address[] memory nextArray_)
    {

        if (_itemsToRemove.length == 0) {
            return _self;
        }

        bool[] memory indexesToRemove = new bool[](_self.length);
        uint256 remainingItemsCount = _self.length;
        for (uint256 i; i < _self.length; i++) {
            if (contains(_itemsToRemove, _self[i])) {
                indexesToRemove[i] = true;
                remainingItemsCount--;
            }
        }

        if (remainingItemsCount == _self.length) {
            nextArray_ = _self;
        } else if (remainingItemsCount > 0) {
            nextArray_ = new address[](remainingItemsCount);
            uint256 nextArrayIndex;
            for (uint256 i; i < _self.length; i++) {
                if (!indexesToRemove[i]) {
                    nextArray_[nextArrayIndex] = _self[i];
                    nextArrayIndex++;
                }
            }
        }

        return nextArray_;
    }
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


contract PolicyManager is IPolicyManager, ExtensionBase, GasRelayRecipientMixin {

    using AddressArrayLib for address[];

    event PolicyDisabledOnHookForFund(
        address indexed comptrollerProxy,
        address indexed policy,
        PolicyHook indexed hook
    );

    event PolicyEnabledForFund(
        address indexed comptrollerProxy,
        address indexed policy,
        bytes settingsData
    );

    uint256 private constant POLICY_HOOK_COUNT = 10;

    mapping(address => mapping(PolicyHook => address[])) private comptrollerProxyToHookToPolicies;

    modifier onlyFundOwner(address _comptrollerProxy) {

        require(
            __msgSender() == IVault(getVaultProxyForFund(_comptrollerProxy)).getOwner(),
            "Only the fund owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer, address _gasRelayPaymasterFactory)
        public
        ExtensionBase(_fundDeployer)
        GasRelayRecipientMixin(_gasRelayPaymasterFactory)
    {}


    function activateForFund(bool _isMigratedFund) external override {

        address comptrollerProxy = msg.sender;

        if (_isMigratedFund) {
            address[] memory enabledPolicies = getEnabledPoliciesForFund(comptrollerProxy);
            for (uint256 i; i < enabledPolicies.length; i++) {
                __activatePolicyForFund(comptrollerProxy, enabledPolicies[i]);
            }
        }
    }

    function disablePolicyForFund(address _comptrollerProxy, address _policy)
        external
        onlyFundOwner(_comptrollerProxy)
    {

        require(IPolicy(_policy).canDisable(), "disablePolicyForFund: _policy cannot be disabled");

        PolicyHook[] memory implementedHooks = IPolicy(_policy).implementedHooks();
        for (uint256 i; i < implementedHooks.length; i++) {

                bool disabled
             = comptrollerProxyToHookToPolicies[_comptrollerProxy][implementedHooks[i]]
                .removeStorageItem(_policy);
            if (disabled) {
                emit PolicyDisabledOnHookForFund(_comptrollerProxy, _policy, implementedHooks[i]);
            }
        }
    }

    function enablePolicyForFund(
        address _comptrollerProxy,
        address _policy,
        bytes calldata _settingsData
    ) external onlyFundOwner(_comptrollerProxy) {

        PolicyHook[] memory implementedHooks = IPolicy(_policy).implementedHooks();
        for (uint256 i; i < implementedHooks.length; i++) {
            require(
                !__policyHookRestrictsCurrentInvestorActions(implementedHooks[i]),
                "enablePolicyForFund: _policy restricts actions of current investors"
            );
        }

        __enablePolicyForFund(_comptrollerProxy, _policy, _settingsData, implementedHooks);

        __activatePolicyForFund(_comptrollerProxy, _policy);
    }

    function setConfigForFund(
        address _comptrollerProxy,
        address _vaultProxy,
        bytes calldata _configData
    ) external override onlyFundDeployer {

        __setValidatedVaultProxy(_comptrollerProxy, _vaultProxy);

        if (_configData.length == 0) {
            return;
        }

        (address[] memory policies, bytes[] memory settingsData) = abi.decode(
            _configData,
            (address[], bytes[])
        );

        require(
            policies.length == settingsData.length,
            "setConfigForFund: policies and settingsData array lengths unequal"
        );

        for (uint256 i; i < policies.length; i++) {
            __enablePolicyForFund(
                _comptrollerProxy,
                policies[i],
                settingsData[i],
                IPolicy(policies[i]).implementedHooks()
            );
        }
    }

    function updatePolicySettingsForFund(
        address _comptrollerProxy,
        address _policy,
        bytes calldata _settingsData
    ) external onlyFundOwner(_comptrollerProxy) {

        IPolicy(_policy).updateFundSettings(_comptrollerProxy, _settingsData);
    }

    function validatePolicies(
        address _comptrollerProxy,
        PolicyHook _hook,
        bytes calldata _validationData
    ) external override {

        address[] memory policies = getEnabledPoliciesOnHookForFund(_comptrollerProxy, _hook);
        if (policies.length == 0) {
            return;
        }

        require(
            msg.sender == _comptrollerProxy ||
                msg.sender == IComptroller(_comptrollerProxy).getIntegrationManager() ||
                msg.sender == IComptroller(_comptrollerProxy).getExternalPositionManager(),
            "validatePolicies: Caller not allowed"
        );

        for (uint256 i; i < policies.length; i++) {
            require(
                IPolicy(policies[i]).validateRule(_comptrollerProxy, _hook, _validationData),
                string(
                    abi.encodePacked(
                        "Rule evaluated to false: ",
                        IPolicy(policies[i]).identifier()
                    )
                )
            );
        }
    }


    function __activatePolicyForFund(address _comptrollerProxy, address _policy) private {

        IPolicy(_policy).activateForFund(_comptrollerProxy);
    }

    function __enablePolicyForFund(
        address _comptrollerProxy,
        address _policy,
        bytes memory _settingsData,
        PolicyHook[] memory _hooks
    ) private {

        if (_settingsData.length > 0) {
            IPolicy(_policy).addFundSettings(_comptrollerProxy, _settingsData);
        }

        for (uint256 i; i < _hooks.length; i++) {
            require(
                !policyIsEnabledOnHookForFund(_comptrollerProxy, _hooks[i], _policy),
                "__enablePolicyForFund: Policy is already enabled"
            );
            comptrollerProxyToHookToPolicies[_comptrollerProxy][_hooks[i]].push(_policy);
        }

        emit PolicyEnabledForFund(_comptrollerProxy, _policy, _settingsData);
    }

    function __getAllPolicyHooks()
        private
        pure
        returns (PolicyHook[POLICY_HOOK_COUNT] memory hooks_)
    {

        return [
            PolicyHook.PostBuyShares,
            PolicyHook.PostCallOnIntegration,
            PolicyHook.PreTransferShares,
            PolicyHook.RedeemSharesForSpecificAssets,
            PolicyHook.AddTrackedAssets,
            PolicyHook.RemoveTrackedAssets,
            PolicyHook.CreateExternalPosition,
            PolicyHook.PostCallOnExternalPosition,
            PolicyHook.RemoveExternalPosition,
            PolicyHook.ReactivateExternalPosition
        ];
    }

    function __policyHookRestrictsCurrentInvestorActions(PolicyHook _hook)
        private
        pure
        returns (bool restrictsActions_)
    {

        return
            _hook == PolicyHook.PreTransferShares ||
            _hook == PolicyHook.RedeemSharesForSpecificAssets;
    }


    function getEnabledPoliciesForFund(address _comptrollerProxy)
        public
        view
        returns (address[] memory enabledPolicies_)
    {

        PolicyHook[POLICY_HOOK_COUNT] memory hooks = __getAllPolicyHooks();

        for (uint256 i; i < hooks.length; i++) {
            enabledPolicies_ = enabledPolicies_.mergeArray(
                getEnabledPoliciesOnHookForFund(_comptrollerProxy, hooks[i])
            );
        }

        return enabledPolicies_;
    }

    function getEnabledPoliciesOnHookForFund(address _comptrollerProxy, PolicyHook _hook)
        public
        view
        returns (address[] memory enabledPolicies_)
    {

        return comptrollerProxyToHookToPolicies[_comptrollerProxy][_hook];
    }

    function policyIsEnabledOnHookForFund(
        address _comptrollerProxy,
        PolicyHook _hook,
        address _policy
    ) public view returns (bool isEnabled_) {

        return getEnabledPoliciesOnHookForFund(_comptrollerProxy, _hook).contains(_policy);
    }
}