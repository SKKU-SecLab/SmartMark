pragma solidity 0.8.4;

interface ILendPoolAddressesProvider {

  event MarketIdSet(string newMarketId);
  event LendPoolUpdated(address indexed newAddress, bytes encodedCallData);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendPoolConfiguratorUpdated(address indexed newAddress, bytes encodedCallData);
  event ReserveOracleUpdated(address indexed newAddress);
  event NftOracleUpdated(address indexed newAddress);
  event LendPoolLoanUpdated(address indexed newAddress, bytes encodedCallData);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy, bytes encodedCallData);
  event BNFTRegistryUpdated(address indexed newAddress);
  event LendPoolLiquidatorUpdated(address indexed newAddress);
  event IncentivesControllerUpdated(address indexed newAddress);
  event UIDataProviderUpdated(address indexed newAddress);
  event BendDataProviderUpdated(address indexed newAddress);
  event WalletBalanceProviderUpdated(address indexed newAddress);

  function getMarketId() external view returns (string memory);


  function setMarketId(string calldata marketId) external;


  function setAddress(bytes32 id, address newAddress) external;


  function setAddressAsProxy(
    bytes32 id,
    address impl,
    bytes memory encodedCallData
  ) external;


  function getAddress(bytes32 id) external view returns (address);


  function getLendPool() external view returns (address);


  function setLendPoolImpl(address pool, bytes memory encodedCallData) external;


  function getLendPoolConfigurator() external view returns (address);


  function setLendPoolConfiguratorImpl(address configurator, bytes memory encodedCallData) external;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external;


  function getReserveOracle() external view returns (address);


  function setReserveOracle(address reserveOracle) external;


  function getNFTOracle() external view returns (address);


  function setNFTOracle(address nftOracle) external;


  function getLendPoolLoan() external view returns (address);


  function setLendPoolLoanImpl(address loan, bytes memory encodedCallData) external;


  function getBNFTRegistry() external view returns (address);


  function setBNFTRegistry(address factory) external;


  function getLendPoolLiquidator() external view returns (address);


  function setLendPoolLiquidator(address liquidator) external;


  function getIncentivesController() external view returns (address);


  function setIncentivesController(address controller) external;


  function getUIDataProvider() external view returns (address);


  function setUIDataProvider(address provider) external;


  function getBendDataProvider() external view returns (address);


  function setBendDataProvider(address provider) external;


  function getWalletBalanceProvider() external view returns (address);


  function setWalletBalanceProvider(address provider) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// agpl-3.0
pragma solidity 0.8.4;

library Errors {

  enum ReturnCode {
    SUCCESS,
    FAILED
  }

  string public constant SUCCESS = "0";

  string public constant CALLER_NOT_POOL_ADMIN = "100"; // 'The caller must be the pool admin'
  string public constant CALLER_NOT_ADDRESS_PROVIDER = "101";
  string public constant INVALID_FROM_BALANCE_AFTER_TRANSFER = "102";
  string public constant INVALID_TO_BALANCE_AFTER_TRANSFER = "103";

  string public constant MATH_MULTIPLICATION_OVERFLOW = "200";
  string public constant MATH_ADDITION_OVERFLOW = "201";
  string public constant MATH_DIVISION_BY_ZERO = "202";

  string public constant VL_INVALID_AMOUNT = "301"; // 'Amount must be greater than 0'
  string public constant VL_NO_ACTIVE_RESERVE = "302"; // 'Action requires an active reserve'
  string public constant VL_RESERVE_FROZEN = "303"; // 'Action cannot be performed because the reserve is frozen'
  string public constant VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE = "304"; // 'User cannot withdraw more than the available balance'
  string public constant VL_BORROWING_NOT_ENABLED = "305"; // 'Borrowing is not enabled'
  string public constant VL_COLLATERAL_BALANCE_IS_0 = "306"; // 'The collateral balance is 0'
  string public constant VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD = "307"; // 'Health factor is lesser than the liquidation threshold'
  string public constant VL_COLLATERAL_CANNOT_COVER_NEW_BORROW = "308"; // 'There is not enough collateral to cover a new borrow'
  string public constant VL_NO_DEBT_OF_SELECTED_TYPE = "309"; // 'for repayment of stable debt, the user needs to have stable debt, otherwise, he needs to have variable debt'
  string public constant VL_NO_ACTIVE_NFT = "310";
  string public constant VL_NFT_FROZEN = "311";
  string public constant VL_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = "312"; // 'User did not borrow the specified currency'
  string public constant VL_INVALID_HEALTH_FACTOR = "313";
  string public constant VL_INVALID_ONBEHALFOF_ADDRESS = "314";
  string public constant VL_INVALID_TARGET_ADDRESS = "315";
  string public constant VL_INVALID_RESERVE_ADDRESS = "316";
  string public constant VL_SPECIFIED_LOAN_NOT_BORROWED_BY_USER = "317";
  string public constant VL_SPECIFIED_RESERVE_NOT_BORROWED_BY_USER = "318";
  string public constant VL_HEALTH_FACTOR_HIGHER_THAN_LIQUIDATION_THRESHOLD = "319";

  string public constant LP_CALLER_NOT_LEND_POOL_CONFIGURATOR = "400"; // 'The caller of the function is not the lending pool configurator'
  string public constant LP_IS_PAUSED = "401"; // 'Pool is paused'
  string public constant LP_NO_MORE_RESERVES_ALLOWED = "402";
  string public constant LP_NOT_CONTRACT = "403";
  string public constant LP_BORROW_NOT_EXCEED_LIQUIDATION_THRESHOLD = "404";
  string public constant LP_BORROW_IS_EXCEED_LIQUIDATION_PRICE = "405";
  string public constant LP_NO_MORE_NFTS_ALLOWED = "406";
  string public constant LP_INVALIED_USER_NFT_AMOUNT = "407";
  string public constant LP_INCONSISTENT_PARAMS = "408";
  string public constant LP_NFT_IS_NOT_USED_AS_COLLATERAL = "409";
  string public constant LP_CALLER_MUST_BE_AN_BTOKEN = "410";
  string public constant LP_INVALIED_NFT_AMOUNT = "411";
  string public constant LP_NFT_HAS_USED_AS_COLLATERAL = "412";
  string public constant LP_DELEGATE_CALL_FAILED = "413";
  string public constant LP_AMOUNT_LESS_THAN_EXTRA_DEBT = "414";
  string public constant LP_AMOUNT_LESS_THAN_REDEEM_THRESHOLD = "415";

  string public constant LPL_INVALID_LOAN_STATE = "480";
  string public constant LPL_INVALID_LOAN_AMOUNT = "481";
  string public constant LPL_INVALID_TAKEN_AMOUNT = "482";
  string public constant LPL_AMOUNT_OVERFLOW = "483";
  string public constant LPL_BID_PRICE_LESS_THAN_LIQUIDATION_PRICE = "484";
  string public constant LPL_BID_PRICE_LESS_THAN_HIGHEST_PRICE = "485";
  string public constant LPL_BID_REDEEM_DURATION_HAS_END = "486";
  string public constant LPL_BID_USER_NOT_SAME = "487";
  string public constant LPL_BID_REPAY_AMOUNT_NOT_ENOUGH = "488";
  string public constant LPL_BID_AUCTION_DURATION_HAS_END = "489";
  string public constant LPL_BID_AUCTION_DURATION_NOT_END = "490";
  string public constant LPL_BID_PRICE_LESS_THAN_BORROW = "491";
  string public constant LPL_INVALID_BIDDER_ADDRESS = "492";
  string public constant LPL_AMOUNT_LESS_THAN_BID_FINE = "493";

  string public constant CT_CALLER_MUST_BE_LEND_POOL = "500"; // 'The caller of this function must be a lending pool'
  string public constant CT_INVALID_MINT_AMOUNT = "501"; //invalid amount to mint
  string public constant CT_INVALID_BURN_AMOUNT = "502"; //invalid amount to burn

  string public constant RL_RESERVE_ALREADY_INITIALIZED = "601"; // 'Reserve has already been initialized'
  string public constant RL_LIQUIDITY_INDEX_OVERFLOW = "602"; //  Liquidity index overflows uint128
  string public constant RL_VARIABLE_BORROW_INDEX_OVERFLOW = "603"; //  Variable borrow index overflows uint128
  string public constant RL_LIQUIDITY_RATE_OVERFLOW = "604"; //  Liquidity rate overflows uint128
  string public constant RL_VARIABLE_BORROW_RATE_OVERFLOW = "605"; //  Variable borrow rate overflows uint128

  string public constant LPC_RESERVE_LIQUIDITY_NOT_0 = "700"; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_CONFIGURATION = "701"; // 'Invalid risk parameters for the reserve'
  string public constant LPC_CALLER_NOT_EMERGENCY_ADMIN = "702"; // 'The caller must be the emergency admin'
  string public constant LPC_INVALIED_BNFT_ADDRESS = "703";
  string public constant LPC_INVALIED_LOAN_ADDRESS = "704";
  string public constant LPC_NFT_LIQUIDITY_NOT_0 = "705";

  string public constant RC_INVALID_LTV = "730";
  string public constant RC_INVALID_LIQ_THRESHOLD = "731";
  string public constant RC_INVALID_LIQ_BONUS = "732";
  string public constant RC_INVALID_DECIMALS = "733";
  string public constant RC_INVALID_RESERVE_FACTOR = "734";
  string public constant RC_INVALID_REDEEM_DURATION = "735";
  string public constant RC_INVALID_AUCTION_DURATION = "736";
  string public constant RC_INVALID_REDEEM_FINE = "737";
  string public constant RC_INVALID_REDEEM_THRESHOLD = "738";

  string public constant LPAPR_PROVIDER_NOT_REGISTERED = "760"; // 'Provider is not registered'
  string public constant LPAPR_INVALID_ADDRESSES_PROVIDER_ID = "761";
}// agpl-3.0
pragma solidity 0.8.4;


contract BendUpgradeableProxy is TransparentUpgradeableProxy {

  constructor(
    address _logic,
    address admin_,
    bytes memory _data
  ) payable TransparentUpgradeableProxy(_logic, admin_, _data) {}

  modifier OnlyAdmin() {

    require(msg.sender == _getAdmin(), Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  function getImplementation() external view OnlyAdmin returns (address) {

    return _getImplementation();
  }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// agpl-3.0
pragma solidity 0.8.4;



contract LendPoolAddressesProvider is Ownable, ILendPoolAddressesProvider {

  string private _marketId;
  mapping(bytes32 => address) private _addresses;

  bytes32 private constant LEND_POOL = "LEND_POOL";
  bytes32 private constant LEND_POOL_CONFIGURATOR = "LEND_POOL_CONFIGURATOR";
  bytes32 private constant POOL_ADMIN = "POOL_ADMIN";
  bytes32 private constant EMERGENCY_ADMIN = "EMERGENCY_ADMIN";
  bytes32 private constant RESERVE_ORACLE = "RESERVE_ORACLE";
  bytes32 private constant NFT_ORACLE = "NFT_ORACLE";
  bytes32 private constant BEND_ORACLE = "BEND_ORACLE";
  bytes32 private constant LEND_POOL_LOAN = "LEND_POOL_LOAN";
  bytes32 private constant BNFT_REGISTRY = "BNFT_REGISTRY";
  bytes32 private constant LEND_POOL_LIQUIDATOR = "LEND_POOL_LIQUIDATOR";
  bytes32 private constant INCENTIVES_CONTROLLER = "INCENTIVES_CONTROLLER";
  bytes32 private constant BEND_DATA_PROVIDER = "BEND_DATA_PROVIDER";
  bytes32 private constant UI_DATA_PROVIDER = "UI_DATA_PROVIDER";
  bytes32 private constant WALLET_BALANCE_PROVIDER = "WALLET_BALANCE_PROVIDER";

  constructor(string memory marketId) {
    _setMarketId(marketId);
  }

  function getMarketId() external view override returns (string memory) {

    return _marketId;
  }

  function setMarketId(string memory marketId) external override onlyOwner {

    _setMarketId(marketId);
  }

  function setAddressAsProxy(
    bytes32 id,
    address implementationAddress,
    bytes memory encodedCallData
  ) external override onlyOwner {

    _updateImpl(id, implementationAddress);
    emit AddressSet(id, implementationAddress, true, encodedCallData);

    if (encodedCallData.length > 0) {
      Address.functionCall(_addresses[id], encodedCallData);
    }
  }

  function setAddress(bytes32 id, address newAddress) external override onlyOwner {

    _addresses[id] = newAddress;
    emit AddressSet(id, newAddress, false, new bytes(0));
  }

  function getAddress(bytes32 id) public view override returns (address) {

    return _addresses[id];
  }

  function getLendPool() external view override returns (address) {

    return getAddress(LEND_POOL);
  }

  function setLendPoolImpl(address pool, bytes memory encodedCallData) external override onlyOwner {

    _updateImpl(LEND_POOL, pool);
    emit LendPoolUpdated(pool, encodedCallData);

    if (encodedCallData.length > 0) {
      Address.functionCall(_addresses[LEND_POOL], encodedCallData);
    }
  }

  function getLendPoolConfigurator() external view override returns (address) {

    return getAddress(LEND_POOL_CONFIGURATOR);
  }

  function setLendPoolConfiguratorImpl(address configurator, bytes memory encodedCallData) external override onlyOwner {

    _updateImpl(LEND_POOL_CONFIGURATOR, configurator);
    emit LendPoolConfiguratorUpdated(configurator, encodedCallData);

    if (encodedCallData.length > 0) {
      Address.functionCall(_addresses[LEND_POOL_CONFIGURATOR], encodedCallData);
    }
  }


  function getPoolAdmin() external view override returns (address) {

    return getAddress(POOL_ADMIN);
  }

  function setPoolAdmin(address admin) external override onlyOwner {

    _addresses[POOL_ADMIN] = admin;
    emit ConfigurationAdminUpdated(admin);
  }

  function getEmergencyAdmin() external view override returns (address) {

    return getAddress(EMERGENCY_ADMIN);
  }

  function setEmergencyAdmin(address emergencyAdmin) external override onlyOwner {

    _addresses[EMERGENCY_ADMIN] = emergencyAdmin;
    emit EmergencyAdminUpdated(emergencyAdmin);
  }

  function getReserveOracle() external view override returns (address) {

    return getAddress(RESERVE_ORACLE);
  }

  function setReserveOracle(address reserveOracle) external override onlyOwner {

    _addresses[RESERVE_ORACLE] = reserveOracle;
    emit ReserveOracleUpdated(reserveOracle);
  }

  function getNFTOracle() external view override returns (address) {

    return getAddress(NFT_ORACLE);
  }

  function setNFTOracle(address nftOracle) external override onlyOwner {

    _addresses[NFT_ORACLE] = nftOracle;
    emit NftOracleUpdated(nftOracle);
  }

  function getLendPoolLoan() external view override returns (address) {

    return getAddress(LEND_POOL_LOAN);
  }

  function setLendPoolLoanImpl(address loanAddress, bytes memory encodedCallData) external override onlyOwner {

    _updateImpl(LEND_POOL_LOAN, loanAddress);
    emit LendPoolLoanUpdated(loanAddress, encodedCallData);

    if (encodedCallData.length > 0) {
      Address.functionCall(_addresses[LEND_POOL_LOAN], encodedCallData);
    }
  }

  function getBNFTRegistry() external view override returns (address) {

    return getAddress(BNFT_REGISTRY);
  }

  function setBNFTRegistry(address factory) external override onlyOwner {

    _addresses[BNFT_REGISTRY] = factory;
    emit BNFTRegistryUpdated(factory);
  }

  function getLendPoolLiquidator() external view override returns (address) {

    return getAddress(LEND_POOL_LIQUIDATOR);
  }

  function setLendPoolLiquidator(address liquidator) external override onlyOwner {

    _addresses[LEND_POOL_LIQUIDATOR] = liquidator;
    emit LendPoolLiquidatorUpdated(liquidator);
  }

  function getIncentivesController() external view override returns (address) {

    return getAddress(INCENTIVES_CONTROLLER);
  }

  function setIncentivesController(address controller) external override onlyOwner {

    _addresses[INCENTIVES_CONTROLLER] = controller;
    emit IncentivesControllerUpdated(controller);
  }

  function getUIDataProvider() external view override returns (address) {

    return getAddress(UI_DATA_PROVIDER);
  }

  function setUIDataProvider(address provider) external override onlyOwner {

    _addresses[UI_DATA_PROVIDER] = provider;
    emit UIDataProviderUpdated(provider);
  }

  function getBendDataProvider() external view override returns (address) {

    return getAddress(BEND_DATA_PROVIDER);
  }

  function setBendDataProvider(address provider) external override onlyOwner {

    _addresses[BEND_DATA_PROVIDER] = provider;
    emit BendDataProviderUpdated(provider);
  }

  function getWalletBalanceProvider() external view override returns (address) {

    return getAddress(WALLET_BALANCE_PROVIDER);
  }

  function setWalletBalanceProvider(address provider) external override onlyOwner {

    _addresses[WALLET_BALANCE_PROVIDER] = provider;
    emit WalletBalanceProviderUpdated(provider);
  }

  function getImplementation(address proxyAddress) external view onlyOwner returns (address) {

    BendUpgradeableProxy proxy = BendUpgradeableProxy(payable(proxyAddress));
    return proxy.getImplementation();
  }

  function _updateImpl(bytes32 id, address newAddress) internal {

    address payable proxyAddress = payable(_addresses[id]);

    if (proxyAddress == address(0)) {
      bytes memory params = abi.encodeWithSignature("initialize(address)", address(this));

      BendUpgradeableProxy proxy = new BendUpgradeableProxy(newAddress, address(this), params);

      _addresses[id] = address(proxy);
      emit ProxyCreated(id, address(proxy));
    } else {
      BendUpgradeableProxy proxy = BendUpgradeableProxy(proxyAddress);

      proxy.upgradeTo(newAddress);
    }
  }

  function _setMarketId(string memory marketId) internal {

    _marketId = marketId;
    emit MarketIdSet(marketId);
  }
}