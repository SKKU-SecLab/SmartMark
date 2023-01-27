



pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}



pragma solidity 0.8.9;

interface IGasBank {

    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, address indexed receiver, uint256 value);

    function depositFor(address account) external payable;


    function withdrawUnused(address account) external;


    function withdrawFrom(address account, uint256 amount) external;


    function withdrawFrom(
        address account,
        address payable to,
        uint256 amount
    ) external;


    function balanceOf(address account) external view returns (uint256);

}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity 0.8.9;

interface IPreparable {

    event ConfigPreparedAddress(bytes32 indexed key, address value, uint256 delay);
    event ConfigPreparedNumber(bytes32 indexed key, uint256 value, uint256 delay);

    event ConfigUpdatedAddress(bytes32 indexed key, address oldValue, address newValue);
    event ConfigUpdatedNumber(bytes32 indexed key, uint256 oldValue, uint256 newValue);

    event ConfigReset(bytes32 indexed key);
}



pragma solidity 0.8.9;

interface IStrategy {

    function name() external view returns (string memory);


    function deposit() external payable returns (bool);


    function balance() external view returns (uint256);


    function withdraw(uint256 amount) external returns (bool);


    function withdrawAll() external returns (uint256);


    function harvestable() external view returns (uint256);


    function harvest() external returns (uint256);


    function strategist() external view returns (address);


    function shutdown() external returns (bool);


    function hasPendingFunds() external view returns (bool);

}



pragma solidity 0.8.9;



interface IVault is IPreparable {

    event StrategyActivated(address indexed strategy);

    event StrategyDeactivated(address indexed strategy);

    event Harvest(uint256 indexed netProfit, uint256 indexed loss);

    function initialize(
        address _pool,
        uint256 _debtLimit,
        uint256 _targetAllocation,
        uint256 _bound
    ) external;


    function withdrawFromStrategyWaitingForRemoval(address strategy) external returns (uint256);


    function deposit() external payable;


    function withdraw(uint256 amount) external returns (bool);


    function initializeStrategy(address strategy_) external returns (bool);


    function withdrawAll() external;


    function withdrawFromReserve(uint256 amount) external;


    function getStrategy() external view returns (IStrategy);


    function getStrategiesWaitingForRemoval() external view returns (address[] memory);


    function getAllocatedToStrategyWaitingForRemoval(address strategy)
        external
        view
        returns (uint256);


    function getTotalUnderlying() external view returns (uint256);


    function getUnderlying() external view returns (address);

}



pragma solidity 0.8.9;


interface ILiquidityPool is IPreparable {

    event Deposit(address indexed minter, uint256 depositAmount, uint256 mintedLpTokens);

    event DepositFor(
        address indexed minter,
        address indexed mintee,
        uint256 depositAmount,
        uint256 mintedLpTokens
    );

    event Redeem(address indexed redeemer, uint256 redeemAmount, uint256 redeemTokens);

    event LpTokenSet(address indexed lpToken);

    event StakerVaultSet(address indexed stakerVault);

    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeem(uint256 redeemTokens, uint256 minRedeemAmount) external returns (uint256);


    function calcRedeem(address account, uint256 underlyingAmount) external returns (uint256);


    function deposit(uint256 mintAmount) external payable returns (uint256);


    function deposit(uint256 mintAmount, uint256 minTokenAmount) external payable returns (uint256);


    function depositAndStake(uint256 depositAmount, uint256 minTokenAmount)
        external
        payable
        returns (uint256);


    function depositFor(address account, uint256 depositAmount) external payable returns (uint256);


    function depositFor(
        address account,
        uint256 depositAmount,
        uint256 minTokenAmount
    ) external payable returns (uint256);


    function unstakeAndRedeem(uint256 redeemLpTokens, uint256 minRedeemAmount)
        external
        returns (uint256);


    function handleLpTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external;


    function executeNewVault() external returns (address);


    function executeNewMaxWithdrawalFee() external returns (uint256);


    function executeNewRequiredReserves() external returns (uint256);


    function executeNewReserveDeviation() external returns (uint256);


    function setLpToken(address _lpToken) external returns (bool);


    function setStaker() external returns (bool);


    function isCapped() external returns (bool);


    function uncap() external returns (bool);


    function updateDepositCap(uint256 _depositCap) external returns (bool);


    function getUnderlying() external view returns (address);


    function getLpToken() external view returns (address);


    function getWithdrawalFee(address account, uint256 amount) external view returns (uint256);


    function getVault() external view returns (IVault);


    function exchangeRate() external view returns (uint256);

}



pragma solidity 0.8.9;

interface IOracleProvider {

    function getPriceUSD(address baseAsset) external view returns (uint256);


    function getPriceETH(address baseAsset) external view returns (uint256);

}



pragma solidity 0.8.9;

library AddressProviderMeta {

    struct Meta {
        bool freezable;
        bool frozen;
    }

    function fromUInt(uint256 value) internal pure returns (Meta memory) {

        Meta memory meta;
        meta.freezable = (value & 1) == 1;
        meta.frozen = ((value >> 1) & 1) == 1;
        return meta;
    }

    function toUInt(Meta memory meta) internal pure returns (uint256) {

        uint256 value;
        value |= meta.freezable ? 1 : 0;
        value |= meta.frozen ? 1 << 1 : 0;
        return value;
    }
}



pragma solidity 0.8.9;






interface IAddressProvider is IPreparable {

    event KnownAddressKeyAdded(bytes32 indexed key);
    event StakerVaultListed(address indexed stakerVault);
    event StakerVaultDelisted(address indexed stakerVault);
    event ActionListed(address indexed action);
    event PoolListed(address indexed pool);
    event PoolDelisted(address indexed pool);
    event VaultUpdated(address indexed previousVault, address indexed newVault);

    function getKnownAddressKeys() external view returns (bytes32[] memory);


    function freezeAddress(bytes32 key) external;



    function allPools() external view returns (address[] memory);


    function addPool(address pool) external;


    function poolsCount() external view returns (uint256);


    function getPoolAtIndex(uint256 index) external view returns (address);


    function isPool(address pool) external view returns (bool);


    function removePool(address pool) external returns (bool);


    function getPoolForToken(address token) external view returns (ILiquidityPool);


    function safeGetPoolForToken(address token) external view returns (address);



    function updateVault(address previousVault, address newVault) external;


    function allVaults() external view returns (address[] memory);


    function vaultsCount() external view returns (uint256);


    function getVaultAtIndex(uint256 index) external view returns (address);


    function isVault(address vault) external view returns (bool);



    function allActions() external view returns (address[] memory);


    function addAction(address action) external returns (bool);


    function isAction(address action) external view returns (bool);


    function initializeAddress(
        bytes32 key,
        address initialAddress,
        bool frezable
    ) external;


    function initializeAndFreezeAddress(bytes32 key, address initialAddress) external;


    function getAddress(bytes32 key) external view returns (address);


    function getAddress(bytes32 key, bool checkExists) external view returns (address);


    function getAddressMeta(bytes32 key) external view returns (AddressProviderMeta.Meta memory);


    function prepareAddress(bytes32 key, address newAddress) external returns (bool);


    function executeAddress(bytes32 key) external returns (address);


    function resetAddress(bytes32 key) external returns (bool);


    function allStakerVaults() external view returns (address[] memory);


    function tryGetStakerVault(address token) external view returns (bool, address);


    function getStakerVault(address token) external view returns (address);


    function addStakerVault(address stakerVault) external returns (bool);


    function isStakerVault(address stakerVault, address token) external view returns (bool);


    function isStakerVaultRegistered(address stakerVault) external view returns (bool);


    function isWhiteListedFeeHandler(address feeHandler) external view returns (bool);

}



pragma solidity 0.8.9;

interface IStakerVault {

    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function initialize(address _token) external;


    function initializeLpGauge(address _lpGauge) external returns (bool);


    function stake(uint256 amount) external returns (bool);


    function stakeFor(address account, uint256 amount) external returns (bool);


    function unstake(uint256 amount) external returns (bool);


    function unstakeFor(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address account, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function getToken() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function stakedAndActionLockedBalanceOf(address account) external view returns (uint256);


    function actionLockedBalanceOf(address account) external view returns (uint256);


    function increaseActionLockedBalance(address account, uint256 amount) external returns (bool);


    function decreaseActionLockedBalance(address account, uint256 amount) external returns (bool);


    function getStakedByActions() external view returns (uint256);


    function addStrategy(address strategy) external returns (bool);


    function getPoolTotalStaked() external view returns (uint256);


    function prepareLpGauge(address _lpGauge) external returns (bool);


    function executeLpGauge() external returns (bool);


    function getLpGauge() external view returns (address);


    function poolCheckpoint() external returns (bool);


    function isStrategy(address user) external view returns (bool);

}




pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}



pragma solidity 0.8.9;

library EnumerableMapping {

    using EnumerableSet for EnumerableSet.Bytes32Set;



    struct Map {
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {

        map._values[key] = value;
        return map._keys.add(key);
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        delete map._values[key];
        return map._keys.remove(key);
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._keys.contains(key);
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._keys.length();
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }


    struct AddressToAddressMap {
        Map _inner;
    }

    function set(
        AddressToAddressMap storage map,
        address key,
        address value
    ) internal returns (bool) {

        return _set(map._inner, bytes32(uint256(uint160(key))), bytes32(uint256(uint160(value))));
    }

    function remove(AddressToAddressMap storage map, address key) internal returns (bool) {

        return _remove(map._inner, bytes32(uint256(uint160(key))));
    }

    function contains(AddressToAddressMap storage map, address key) internal view returns (bool) {

        return _contains(map._inner, bytes32(uint256(uint160(key))));
    }

    function length(AddressToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(AddressToAddressMap storage map, uint256 index)
        internal
        view
        returns (address, address)
    {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (address(uint160(uint256(key))), address(uint160(uint256(value))));
    }

    function tryGet(AddressToAddressMap storage map, address key)
        internal
        view
        returns (bool, address)
    {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, address(uint160(uint256(value))));
    }

    function get(AddressToAddressMap storage map, address key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(uint256(uint160(key)))))));
    }


    struct AddressToUintMap {
        Map _inner;
    }

    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {

        return _set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    function remove(AddressToUintMap storage map, address key) internal returns (bool) {

        return _remove(map._inner, bytes32(uint256(uint160(key))));
    }

    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {

        return _contains(map._inner, bytes32(uint256(uint160(key))));
    }

    function length(AddressToUintMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(AddressToUintMap storage map, uint256 index)
        internal
        view
        returns (address, uint256)
    {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    function tryGet(AddressToUintMap storage map, address key)
        internal
        view
        returns (bool, uint256)
    {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {

        return uint256(_get(map._inner, bytes32(uint256(uint160(key)))));
    }


    struct Bytes32ToUIntMap {
        Map _inner;
    }

    function set(
        Bytes32ToUIntMap storage map,
        bytes32 key,
        uint256 value
    ) internal returns (bool) {

        return _set(map._inner, key, bytes32(value));
    }

    function remove(Bytes32ToUIntMap storage map, bytes32 key) internal returns (bool) {

        return _remove(map._inner, key);
    }

    function contains(Bytes32ToUIntMap storage map, bytes32 key) internal view returns (bool) {

        return _contains(map._inner, key);
    }

    function length(Bytes32ToUIntMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(Bytes32ToUIntMap storage map, uint256 index)
        internal
        view
        returns (bytes32, uint256)
    {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (key, uint256(value));
    }

    function tryGet(Bytes32ToUIntMap storage map, bytes32 key)
        internal
        view
        returns (bool, uint256)
    {

        (bool success, bytes32 value) = _tryGet(map._inner, key);
        return (success, uint256(value));
    }

    function get(Bytes32ToUIntMap storage map, bytes32 key) internal view returns (uint256) {

        return uint256(_get(map._inner, key));
    }
}



pragma solidity 0.8.9;


library EnumerableExtensions {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableMapping for EnumerableMapping.AddressToAddressMap;
    using EnumerableMapping for EnumerableMapping.AddressToUintMap;
    using EnumerableMapping for EnumerableMapping.Bytes32ToUIntMap;

    function toArray(EnumerableSet.AddressSet storage addresses)
        internal
        view
        returns (address[] memory)
    {

        uint256 len = addresses.length();
        address[] memory result = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = addresses.at(i);
        }
        return result;
    }

    function toArray(EnumerableSet.Bytes32Set storage values)
        internal
        view
        returns (bytes32[] memory)
    {

        uint256 len = values.length();
        bytes32[] memory result = new bytes32[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = values.at(i);
        }
        return result;
    }

    function keyAt(EnumerableMapping.AddressToAddressMap storage map, uint256 index)
        internal
        view
        returns (address)
    {

        (address key, ) = map.at(index);
        return key;
    }

    function valueAt(EnumerableMapping.AddressToAddressMap storage map, uint256 index)
        internal
        view
        returns (address)
    {

        (, address value) = map.at(index);
        return value;
    }

    function keyAt(EnumerableMapping.AddressToUintMap storage map, uint256 index)
        internal
        view
        returns (address)
    {

        (address key, ) = map.at(index);
        return key;
    }

    function keyAt(EnumerableMapping.Bytes32ToUIntMap storage map, uint256 index)
        internal
        view
        returns (bytes32)
    {

        (bytes32 key, ) = map.at(index);
        return key;
    }

    function valueAt(EnumerableMapping.AddressToUintMap storage map, uint256 index)
        internal
        view
        returns (uint256)
    {

        (, uint256 value) = map.at(index);
        return value;
    }

    function keysArray(EnumerableMapping.AddressToAddressMap storage map)
        internal
        view
        returns (address[] memory)
    {

        uint256 len = map.length();
        address[] memory result = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = keyAt(map, i);
        }
        return result;
    }

    function valuesArray(EnumerableMapping.AddressToAddressMap storage map)
        internal
        view
        returns (address[] memory)
    {

        uint256 len = map.length();
        address[] memory result = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = valueAt(map, i);
        }
        return result;
    }

    function keysArray(EnumerableMapping.AddressToUintMap storage map)
        internal
        view
        returns (address[] memory)
    {

        uint256 len = map.length();
        address[] memory result = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = keyAt(map, i);
        }
        return result;
    }

    function keysArray(EnumerableMapping.Bytes32ToUIntMap storage map)
        internal
        view
        returns (bytes32[] memory)
    {

        uint256 len = map.length();
        bytes32[] memory result = new bytes32[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = keyAt(map, i);
        }
        return result;
    }
}



pragma solidity 0.8.9;

library AddressProviderKeys {

    bytes32 internal constant _TREASURY_KEY = "treasury";
    bytes32 internal constant _GAS_BANK_KEY = "gasBank";
    bytes32 internal constant _VAULT_RESERVE_KEY = "vaultReserve";
    bytes32 internal constant _SWAPPER_REGISTRY_KEY = "swapperRegistry";
    bytes32 internal constant _ORACLE_PROVIDER_KEY = "oracleProvider";
    bytes32 internal constant _POOL_FACTORY_KEY = "poolFactory";
    bytes32 internal constant _CONTROLLER_KEY = "controller";
    bytes32 internal constant _BKD_LOCKER_KEY = "bkdLocker";
    bytes32 internal constant _ROLE_MANAGER_KEY = "roleManager";
}



pragma solidity 0.8.9;


library Roles {

    bytes32 internal constant GOVERNANCE = "governance";
    bytes32 internal constant ADDRESS_PROVIDER = "address_provider";
    bytes32 internal constant POOL_FACTORY = "pool_factory";
    bytes32 internal constant CONTROLLER = "controller";
    bytes32 internal constant GAUGE_ZAP = "gauge_zap";
    bytes32 internal constant MAINTENANCE = "maintenance";
    bytes32 internal constant INFLATION_MANAGER = "inflation_manager";
    bytes32 internal constant POOL = "pool";
    bytes32 internal constant VAULT = "vault";
}



pragma solidity 0.8.9;

interface IRoleManager {

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function hasRole(bytes32 role, address account) external view returns (bool);


    function hasAnyRole(bytes32[] memory roles, address account) external view returns (bool);


    function hasAnyRole(
        bytes32 role1,
        bytes32 role2,
        address account
    ) external view returns (bool);


    function hasAnyRole(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        address account
    ) external view returns (bool);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);


    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

}



pragma solidity 0.8.9;


library Error {

    string internal constant ADDRESS_WHITELISTED = "address already whitelisted";
    string internal constant ADMIN_ALREADY_SET = "admin has already been set once";
    string internal constant ADDRESS_NOT_WHITELISTED = "address not whitelisted";
    string internal constant ADDRESS_NOT_FOUND = "address not found";
    string internal constant CONTRACT_INITIALIZED = "contract can only be initialized once";
    string internal constant CONTRACT_PAUSED = "contract is paused";
    string internal constant INVALID_AMOUNT = "invalid amount";
    string internal constant INVALID_INDEX = "invalid index";
    string internal constant INVALID_VALUE = "invalid msg.value";
    string internal constant INVALID_SENDER = "invalid msg.sender";
    string internal constant INVALID_TOKEN = "token address does not match pool's LP token address";
    string internal constant INVALID_DECIMALS = "incorrect number of decimals";
    string internal constant INVALID_ARGUMENT = "invalid argument";
    string internal constant INVALID_PARAMETER_VALUE = "invalid parameter value attempted";
    string internal constant INVALID_IMPLEMENTATION = "invalid pool implementation for given coin";
    string internal constant INVALID_POOL_IMPLEMENTATION =
        "invalid pool implementation for given coin";
    string internal constant INVALID_LP_TOKEN_IMPLEMENTATION =
        "invalid LP Token implementation for given coin";
    string internal constant INVALID_VAULT_IMPLEMENTATION =
        "invalid vault implementation for given coin";
    string internal constant INVALID_STAKER_VAULT_IMPLEMENTATION =
        "invalid stakerVault implementation for given coin";
    string internal constant INSUFFICIENT_BALANCE = "insufficient balance";
    string internal constant ADDRESS_ALREADY_SET = "Address is already set";
    string internal constant INSUFFICIENT_STRATEGY_BALANCE = "insufficient strategy balance";
    string internal constant INSUFFICIENT_FUNDS_RECEIVED = "insufficient funds received";
    string internal constant ADDRESS_DOES_NOT_EXIST = "address does not exist";
    string internal constant ADDRESS_FROZEN = "address is frozen";
    string internal constant ROLE_EXISTS = "role already exists";
    string internal constant CANNOT_REVOKE_ROLE = "cannot revoke role";
    string internal constant UNAUTHORIZED_ACCESS = "unauthorized access";
    string internal constant SAME_ADDRESS_NOT_ALLOWED = "same address not allowed";
    string internal constant SELF_TRANSFER_NOT_ALLOWED = "self-transfer not allowed";
    string internal constant ZERO_ADDRESS_NOT_ALLOWED = "zero address not allowed";
    string internal constant ZERO_TRANSFER_NOT_ALLOWED = "zero transfer not allowed";
    string internal constant THRESHOLD_TOO_HIGH = "threshold is too high, must be under 10";
    string internal constant INSUFFICIENT_THRESHOLD = "insufficient threshold";
    string internal constant NO_POSITION_EXISTS = "no position exists";
    string internal constant POSITION_ALREADY_EXISTS = "position already exists";
    string internal constant PROTOCOL_NOT_FOUND = "protocol not found";
    string internal constant TOP_UP_FAILED = "top up failed";
    string internal constant SWAP_PATH_NOT_FOUND = "swap path not found";
    string internal constant UNDERLYING_NOT_SUPPORTED = "underlying token not supported";
    string internal constant NOT_ENOUGH_FUNDS_WITHDRAWN =
        "not enough funds were withdrawn from the pool";
    string internal constant FAILED_TRANSFER = "transfer failed";
    string internal constant FAILED_MINT = "mint failed";
    string internal constant FAILED_REPAY_BORROW = "repay borrow failed";
    string internal constant FAILED_METHOD_CALL = "method call failed";
    string internal constant NOTHING_TO_CLAIM = "there is no claimable balance";
    string internal constant ERC20_BALANCE_EXCEEDED = "ERC20: transfer amount exceeds balance";
    string internal constant INVALID_MINTER =
        "the minter address of the LP token and the pool address do not match";
    string internal constant STAKER_VAULT_EXISTS = "a staker vault already exists for the token";
    string internal constant DEADLINE_NOT_ZERO = "deadline must be 0";
    string internal constant DEADLINE_NOT_SET = "deadline is 0";
    string internal constant DEADLINE_NOT_REACHED = "deadline has not been reached yet";
    string internal constant DELAY_TOO_SHORT = "delay be at least 3 days";
    string internal constant INSUFFICIENT_UPDATE_BALANCE =
        "insufficient funds for updating the position";
    string internal constant SAME_AS_CURRENT = "value must be different to existing value";
    string internal constant NOT_CAPPED = "the pool is not currently capped";
    string internal constant ALREADY_CAPPED = "the pool is already capped";
    string internal constant EXCEEDS_DEPOSIT_CAP = "deposit exceeds deposit cap";
    string internal constant VALUE_TOO_LOW_FOR_GAS = "value too low to cover gas";
    string internal constant NOT_ENOUGH_FUNDS = "not enough funds to withdraw";
    string internal constant ESTIMATED_GAS_TOO_HIGH = "too much ETH will be used for gas";
    string internal constant DEPOSIT_FAILED = "deposit failed";
    string internal constant GAS_TOO_HIGH = "too much ETH used for gas";
    string internal constant GAS_BANK_BALANCE_TOO_LOW = "not enough ETH in gas bank to cover gas";
    string internal constant INVALID_TOKEN_TO_ADD = "Invalid token to add";
    string internal constant INVALID_TOKEN_TO_REMOVE = "token can not be removed";
    string internal constant TIME_DELAY_NOT_EXPIRED = "time delay not expired yet";
    string internal constant UNDERLYING_NOT_WITHDRAWABLE =
        "pool does not support additional underlying coins to be withdrawn";
    string internal constant STRATEGY_SHUT_DOWN = "Strategy is shut down";
    string internal constant STRATEGY_DOES_NOT_EXIST = "Strategy does not exist";
    string internal constant UNSUPPORTED_UNDERLYING = "Underlying not supported";
    string internal constant NO_DEX_SET = "no dex has been set for token";
    string internal constant INVALID_TOKEN_PAIR = "invalid token pair";
    string internal constant TOKEN_NOT_USABLE = "token not usable for the specific action";
    string internal constant ADDRESS_NOT_ACTION = "address is not registered action";
    string internal constant INVALID_SLIPPAGE_TOLERANCE = "Invalid slippage tolerance";
    string internal constant POOL_NOT_PAUSED = "Pool must be paused to withdraw from reserve";
    string internal constant INTERACTION_LIMIT = "Max of one deposit and withdraw per block";
    string internal constant GAUGE_EXISTS = "Gauge already exists";
    string internal constant GAUGE_DOES_NOT_EXIST = "Gauge does not exist";
    string internal constant EXCEEDS_MAX_BOOST = "Not allowed to exceed maximum boost on Convex";
    string internal constant PREPARED_WITHDRAWAL =
        "Cannot relock funds when withdrawal is being prepared";
    string internal constant ASSET_NOT_SUPPORTED = "Asset not supported";
    string internal constant STALE_PRICE = "Price is stale";
    string internal constant NEGATIVE_PRICE = "Price is negative";
    string internal constant NOT_ENOUGH_BKD_STAKED = "Not enough BKD tokens staked";
    string internal constant RESERVE_ACCESS_EXCEEDED = "Reserve access exceeded";
}



pragma solidity 0.8.9;


abstract contract AuthorizationBase {
    modifier onlyRole(bytes32 role) {
        require(_roleManager().hasRole(role, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    modifier onlyGovernance() {
        require(_roleManager().hasRole(Roles.GOVERNANCE, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    modifier onlyRoles2(bytes32 role1, bytes32 role2) {
        require(_roleManager().hasAnyRole(role1, role2, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    modifier onlyRoles3(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3
    ) {
        require(
            _roleManager().hasAnyRole(role1, role2, role3, msg.sender),
            Error.UNAUTHORIZED_ACCESS
        );
        _;
    }

    function roleManager() external view virtual returns (IRoleManager) {
        return _roleManager();
    }

    function _roleManager() internal view virtual returns (IRoleManager);
}



pragma solidity 0.8.9;


contract Preparable is IPreparable {

    uint256 private constant _MIN_DELAY = 3 days;

    mapping(bytes32 => address) public pendingAddresses;
    mapping(bytes32 => uint256) public pendingUInts256;

    mapping(bytes32 => address) public currentAddresses;
    mapping(bytes32 => uint256) public currentUInts256;

    mapping(bytes32 => uint256) public deadlines;

    function _prepareDeadline(bytes32 key, uint256 delay) internal {

        require(deadlines[key] == 0, Error.DEADLINE_NOT_ZERO);
        require(delay >= _MIN_DELAY, Error.DELAY_TOO_SHORT);
        deadlines[key] = block.timestamp + delay;
    }

    function _prepare(
        bytes32 key,
        uint256 value,
        uint256 delay
    ) internal returns (bool) {

        _prepareDeadline(key, delay);
        pendingUInts256[key] = value;
        emit ConfigPreparedNumber(key, value, delay);
        return true;
    }

    function _prepare(bytes32 key, uint256 value) internal returns (bool) {

        return _prepare(key, value, _MIN_DELAY);
    }

    function _prepare(
        bytes32 key,
        address value,
        uint256 delay
    ) internal returns (bool) {

        _prepareDeadline(key, delay);
        pendingAddresses[key] = value;
        emit ConfigPreparedAddress(key, value, delay);
        return true;
    }

    function _prepare(bytes32 key, address value) internal returns (bool) {

        return _prepare(key, value, _MIN_DELAY);
    }

    function _resetUInt256Config(bytes32 key) internal returns (bool) {

        require(deadlines[key] != 0, Error.DEADLINE_NOT_ZERO);
        deadlines[key] = 0;
        pendingUInts256[key] = 0;
        emit ConfigReset(key);
        return true;
    }

    function _resetAddressConfig(bytes32 key) internal returns (bool) {

        require(deadlines[key] != 0, Error.DEADLINE_NOT_ZERO);
        deadlines[key] = 0;
        pendingAddresses[key] = address(0);
        emit ConfigReset(key);
        return true;
    }

    function _executeDeadline(bytes32 key) internal {

        uint256 deadline = deadlines[key];
        require(block.timestamp >= deadline, Error.DEADLINE_NOT_REACHED);
        require(deadline != 0, Error.DEADLINE_NOT_SET);
        deadlines[key] = 0;
    }

    function _executeUInt256(bytes32 key) internal returns (uint256) {

        _executeDeadline(key);
        uint256 newValue = pendingUInts256[key];
        _setConfig(key, newValue);
        return newValue;
    }

    function _executeAddress(bytes32 key) internal returns (address) {

        _executeDeadline(key);
        address newValue = pendingAddresses[key];
        _setConfig(key, newValue);
        return newValue;
    }

    function _setConfig(bytes32 key, address value) internal returns (address) {

        address oldValue = currentAddresses[key];
        currentAddresses[key] = value;
        pendingAddresses[key] = address(0);
        deadlines[key] = 0;
        emit ConfigUpdatedAddress(key, oldValue, value);
        return value;
    }

    function _setConfig(bytes32 key, uint256 value) internal returns (uint256) {

        uint256 oldValue = currentUInts256[key];
        currentUInts256[key] = value;
        pendingUInts256[key] = 0;
        deadlines[key] = 0;
        emit ConfigUpdatedNumber(key, oldValue, value);
        return value;
    }
}



pragma solidity 0.8.9;










contract AddressProvider is IAddressProvider, AuthorizationBase, Initializable, Preparable {

    using EnumerableMapping for EnumerableMapping.AddressToAddressMap;
    using EnumerableMapping for EnumerableMapping.Bytes32ToUIntMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableExtensions for EnumerableSet.AddressSet;
    using EnumerableExtensions for EnumerableSet.Bytes32Set;
    using EnumerableExtensions for EnumerableMapping.AddressToAddressMap;
    using EnumerableExtensions for EnumerableMapping.Bytes32ToUIntMap;
    using AddressProviderMeta for AddressProviderMeta.Meta;

    EnumerableMapping.AddressToAddressMap internal _stakerVaults;

    EnumerableSet.AddressSet internal _whiteListedFeeHandlers;

    EnumerableMapping.Bytes32ToUIntMap internal _addressKeyMetas;

    EnumerableSet.AddressSet internal _actions; // list of all actions ever registered

    EnumerableSet.AddressSet internal _vaults; // list of all active vaults

    EnumerableMapping.AddressToAddressMap internal _tokenToPools;

    constructor(address treasury) {
        AddressProviderMeta.Meta memory meta = AddressProviderMeta.Meta(true, false);
        _addressKeyMetas.set(AddressProviderKeys._TREASURY_KEY, meta.toUInt());
        _setConfig(AddressProviderKeys._TREASURY_KEY, treasury);
    }

    function initialize(address roleManager) external initializer {

        AddressProviderMeta.Meta memory meta = AddressProviderMeta.Meta(true, true);
        _addressKeyMetas.set(AddressProviderKeys._ROLE_MANAGER_KEY, meta.toUInt());
        _setConfig(AddressProviderKeys._ROLE_MANAGER_KEY, roleManager);
    }

    function getKnownAddressKeys() external view returns (bytes32[] memory) {

        return _addressKeyMetas.keysArray();
    }

    function addFeeHandler(address feeHandler) external onlyGovernance returns (bool) {

        require(!_whiteListedFeeHandlers.contains(feeHandler), Error.ADDRESS_WHITELISTED);
        _whiteListedFeeHandlers.add(feeHandler);
        return true;
    }

    function removeFeeHandler(address feeHandler) external onlyGovernance returns (bool) {

        require(_whiteListedFeeHandlers.contains(feeHandler), Error.ADDRESS_NOT_WHITELISTED);
        _whiteListedFeeHandlers.remove(feeHandler);
        return true;
    }

    function addAction(address action) external onlyGovernance returns (bool) {

        bool result = _actions.add(action);
        if (result) {
            emit ActionListed(action);
        }
        return result;
    }

    function addPool(address pool)
        external
        override
        onlyRoles2(Roles.POOL_FACTORY, Roles.GOVERNANCE)
    {

        require(pool != address(0), Error.ZERO_ADDRESS_NOT_ALLOWED);

        ILiquidityPool ipool = ILiquidityPool(pool);
        address poolToken = ipool.getLpToken();
        require(poolToken != address(0), Error.ZERO_ADDRESS_NOT_ALLOWED);
        if (_tokenToPools.set(poolToken, pool)) {
            address vault = address(ipool.getVault());
            if (vault != address(0)) {
                _vaults.add(vault);
            }
            emit PoolListed(pool);
        }
    }

    function removePool(address pool) external override onlyRole(Roles.CONTROLLER) returns (bool) {

        address lpToken = ILiquidityPool(pool).getLpToken();
        bool removed = _tokenToPools.remove(lpToken);
        if (removed) {
            address vault = address(ILiquidityPool(pool).getVault());
            if (vault != address(0)) {
                _vaults.remove(vault);
            }
            emit PoolDelisted(pool);
        }

        return removed;
    }


    function allVaults() external view returns (address[] memory) {

        return _vaults.toArray();
    }

    function getVaultAtIndex(uint256 index) external view returns (address) {

        return _vaults.at(index);
    }

    function vaultsCount() external view returns (uint256) {

        return _vaults.length();
    }

    function isVault(address vault) external view returns (bool) {

        return _vaults.contains(vault);
    }

    function updateVault(address previousVault, address newVault) external onlyRole(Roles.POOL) {

        if (previousVault != address(0)) {
            _vaults.remove(previousVault);
        }
        if (newVault != address(0)) {
            _vaults.add(newVault);
        }
        emit VaultUpdated(previousVault, newVault);
    }

    function getAddress(bytes32 key) public view returns (address) {

        require(_addressKeyMetas.contains(key), Error.ADDRESS_DOES_NOT_EXIST);
        return currentAddresses[key];
    }

    function getAddress(bytes32 key, bool checkExists) public view returns (address) {

        require(!checkExists || _addressKeyMetas.contains(key), Error.ADDRESS_DOES_NOT_EXIST);
        return currentAddresses[key];
    }

    function getAddressMeta(bytes32 key) public view returns (AddressProviderMeta.Meta memory) {

        (bool exists, uint256 metadata) = _addressKeyMetas.tryGet(key);
        require(exists, Error.ADDRESS_DOES_NOT_EXIST);
        return AddressProviderMeta.fromUInt(metadata);
    }

    function initializeAddress(bytes32 key, address initialAddress) external {

        initializeAddress(key, initialAddress, false);
    }

    function initializeAddress(
        bytes32 key,
        address initialAddress,
        bool freezable
    ) public override onlyGovernance {

        AddressProviderMeta.Meta memory meta = AddressProviderMeta.Meta(freezable, false);
        _initializeAddress(key, initialAddress, meta);
    }

    function initializeAndFreezeAddress(bytes32 key, address initialAddress)
        external
        override
        onlyGovernance
    {

        AddressProviderMeta.Meta memory meta = AddressProviderMeta.Meta(true, true);
        _initializeAddress(key, initialAddress, meta);
    }

    function freezeAddress(bytes32 key) external override onlyGovernance {

        AddressProviderMeta.Meta memory meta = getAddressMeta(key);
        require(!meta.frozen, Error.ADDRESS_FROZEN);
        require(meta.freezable, Error.INVALID_ARGUMENT);
        meta.frozen = true;
        _addressKeyMetas.set(key, meta.toUInt());
    }

    function prepareAddress(bytes32 key, address newAddress)
        external
        override
        onlyGovernance
        returns (bool)
    {

        AddressProviderMeta.Meta memory meta = getAddressMeta(key);
        require(!meta.frozen, Error.ADDRESS_FROZEN);
        return _prepare(key, newAddress);
    }

    function executeAddress(bytes32 key) external override returns (address) {

        AddressProviderMeta.Meta memory meta = getAddressMeta(key);
        require(!meta.frozen, Error.ADDRESS_FROZEN);
        return _executeAddress(key);
    }

    function resetAddress(bytes32 key) external onlyGovernance returns (bool) {

        return _resetAddressConfig(key);
    }

    function addStakerVault(address stakerVault)
        external
        override
        onlyRole(Roles.CONTROLLER)
        returns (bool)
    {

        address token = IStakerVault(stakerVault).getToken();
        require(token != address(0), Error.ZERO_ADDRESS_NOT_ALLOWED);
        require(!_stakerVaults.contains(token), Error.STAKER_VAULT_EXISTS);
        _stakerVaults.set(token, stakerVault);
        emit StakerVaultListed(stakerVault);
        return true;
    }

    function isWhiteListedFeeHandler(address feeHandler) external view override returns (bool) {

        return _whiteListedFeeHandlers.contains(feeHandler);
    }

    function safeGetPoolForToken(address token) external view override returns (address) {

        (, address poolAddress) = _tokenToPools.tryGet(token);
        return poolAddress;
    }

    function getPoolForToken(address token) external view override returns (ILiquidityPool) {

        (bool exists, address poolAddress) = _tokenToPools.tryGet(token);
        require(exists, Error.ADDRESS_NOT_FOUND);
        return ILiquidityPool(poolAddress);
    }

    function allActions() external view override returns (address[] memory) {

        return _actions.toArray();
    }

    function isAction(address action) external view override returns (bool) {

        return _actions.contains(action);
    }

    function isPool(address pool) external view returns (bool) {

        address lpToken = ILiquidityPool(pool).getLpToken();
        (bool exists, address poolAddress) = _tokenToPools.tryGet(lpToken);
        return exists && pool == poolAddress;
    }

    function allPools() external view override returns (address[] memory) {

        return _tokenToPools.valuesArray();
    }

    function getPoolAtIndex(uint256 index) external view returns (address) {

        return _tokenToPools.valueAt(index);
    }

    function poolsCount() external view returns (uint256) {

        return _tokenToPools.length();
    }

    function allStakerVaults() external view override returns (address[] memory) {

        return _stakerVaults.valuesArray();
    }

    function getStakerVault(address token) external view override returns (address) {

        return _stakerVaults.get(token);
    }

    function tryGetStakerVault(address token) external view override returns (bool, address) {

        return _stakerVaults.tryGet(token);
    }

    function isStakerVaultRegistered(address stakerVault) external view override returns (bool) {

        address token = IStakerVault(stakerVault).getToken();
        return isStakerVault(stakerVault, token);
    }

    function isStakerVault(address stakerVault, address token) public view override returns (bool) {

        (bool exists, address vault) = _stakerVaults.tryGet(token);
        return exists && vault == stakerVault;
    }

    function _roleManager() internal view override returns (IRoleManager) {

        return IRoleManager(getAddress(AddressProviderKeys._ROLE_MANAGER_KEY));
    }

    function _initializeAddress(
        bytes32 key,
        address initialAddress,
        AddressProviderMeta.Meta memory meta
    ) internal {

        require(!_addressKeyMetas.contains(key), Error.INVALID_ARGUMENT);
        _addKnownAddressKey(key, meta);
        _setConfig(key, initialAddress);
    }

    function _addKnownAddressKey(bytes32 key, AddressProviderMeta.Meta memory meta) internal {

        require(_addressKeyMetas.set(key, meta.toUInt()), Error.INVALID_ARGUMENT);
        emit KnownAddressKeyAdded(key);
    }
}