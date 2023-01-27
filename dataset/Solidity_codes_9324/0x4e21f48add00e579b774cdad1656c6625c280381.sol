pragma solidity 0.8.10;

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
}// MIT

pragma solidity 0.8.10;

interface IERC165 {

  function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// agpl-3.0
pragma solidity 0.8.10;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
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
}// LGPL-3.0-or-later
pragma solidity 0.8.10;


library GPv2SafeERC20 {

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    bytes4 selector_ = token.transfer.selector;

    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(freeMemoryPointer, selector_)
      mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(freeMemoryPointer, 36), value)

      if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    require(getLastTransferResult(token), 'GPv2: failed transfer');
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    bytes4 selector_ = token.transferFrom.selector;

    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(freeMemoryPointer, selector_)
      mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(freeMemoryPointer, 68), value)

      if iszero(call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    require(getLastTransferResult(token), 'GPv2: failed transferFrom');
  }

  function getLastTransferResult(IERC20 token) private view returns (bool success) {

    assembly {
      function revertWithMessage(length, message) {
        mstore(0x00, '\x08\xc3\x79\xa0')
        mstore(0x04, 0x20)
        mstore(0x24, length)
        mstore(0x44, message)
        revert(0x00, 0x64)
      }

      switch returndatasize()
      case 0 {
        if iszero(extcodesize(token)) {
          revertWithMessage(20, 'GPv2: not a contract')
        }

        success := 1
      }
      case 32 {
        returndatacopy(0, 0, returndatasize())

        success := iszero(iszero(mload(0)))
      }
      default {
        revertWithMessage(31, 'GPv2: malformed transfer result')
      }
    }
  }
}// MIT
pragma solidity 0.8.10;

library SafeCast {

  function toUint224(uint256 value) internal pure returns (uint224) {

    require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
    return uint224(value);
  }

  function toUint128(uint256 value) internal pure returns (uint128) {

    require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
    return uint128(value);
  }

  function toUint96(uint256 value) internal pure returns (uint96) {

    require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
    return uint96(value);
  }

  function toUint64(uint256 value) internal pure returns (uint64) {

    require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
    return uint64(value);
  }

  function toUint32(uint256 value) internal pure returns (uint32) {

    require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
    return uint32(value);
  }

  function toUint16(uint256 value) internal pure returns (uint16) {

    require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
    return uint16(value);
  }

  function toUint8(uint256 value) internal pure returns (uint8) {

    require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
    return uint8(value);
  }

  function toUint256(int256 value) internal pure returns (uint256) {

    require(value >= 0, 'SafeCast: value must be positive');
    return uint256(value);
  }

  function toInt128(int256 value) internal pure returns (int128) {

    require(
      value >= type(int128).min && value <= type(int128).max,
      "SafeCast: value doesn't fit in 128 bits"
    );
    return int128(value);
  }

  function toInt64(int256 value) internal pure returns (int64) {

    require(
      value >= type(int64).min && value <= type(int64).max,
      "SafeCast: value doesn't fit in 64 bits"
    );
    return int64(value);
  }

  function toInt32(int256 value) internal pure returns (int32) {

    require(
      value >= type(int32).min && value <= type(int32).max,
      "SafeCast: value doesn't fit in 32 bits"
    );
    return int32(value);
  }

  function toInt16(int256 value) internal pure returns (int16) {

    require(
      value >= type(int16).min && value <= type(int16).max,
      "SafeCast: value doesn't fit in 16 bits"
    );
    return int16(value);
  }

  function toInt8(int256 value) internal pure returns (int8) {

    require(
      value >= type(int8).min && value <= type(int8).max,
      "SafeCast: value doesn't fit in 8 bits"
    );
    return int8(value);
  }

  function toInt256(uint256 value) internal pure returns (int256) {

    require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
    return int256(value);
  }
}// AGPL-3.0
pragma solidity 0.8.10;

abstract contract VersionedInitializable {
    uint256 private lastInitializedRevision = 0;

    bool private initializing;

    modifier initializer() {
        uint256 revision = getRevision();
        require(
            initializing ||
                isConstructor() ||
                revision > lastInitializedRevision,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            lastInitializedRevision = revision;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function getRevision() internal pure virtual returns (uint256);

    function isConstructor() private view returns (bool) {
        uint256 cs;
        assembly {
            cs := extcodesize(address())
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}// BUSL-1.1
pragma solidity 0.8.10;

library Errors {

    string public constant CALLER_NOT_POOL_ADMIN = "1"; // 'The caller of the function is not a pool admin'
    string public constant CALLER_NOT_EMERGENCY_ADMIN = "2"; // 'The caller of the function is not an emergency admin'
    string public constant CALLER_NOT_POOL_OR_EMERGENCY_ADMIN = "3"; // 'The caller of the function is not a pool or emergency admin'
    string public constant CALLER_NOT_RISK_OR_POOL_ADMIN = "4"; // 'The caller of the function is not a risk or pool admin'
    string public constant CALLER_NOT_ASSET_LISTING_OR_POOL_ADMIN = "5"; // 'The caller of the function is not an asset listing or pool admin'
    string public constant CALLER_NOT_BRIDGE = "6"; // 'The caller of the function is not a bridge'
    string public constant ADDRESSES_PROVIDER_NOT_REGISTERED = "7"; // 'Pool addresses provider is not registered'
    string public constant INVALID_ADDRESSES_PROVIDER_ID = "8"; // 'Invalid id for the pool addresses provider'
    string public constant NOT_CONTRACT = "9"; // 'Address is not a contract'
    string public constant CALLER_NOT_POOL_CONFIGURATOR = "10"; // 'The caller of the function is not the pool configurator'
    string public constant CALLER_NOT_XTOKEN = "11"; // 'The caller of the function is not an OToken'
    string public constant INVALID_ADDRESSES_PROVIDER = "12"; // 'The address of the pool addresses provider is invalid'
    string public constant INVALID_FLASHLOAN_EXECUTOR_RETURN = "13"; // 'Invalid return value of the flashloan executor function'
    string public constant RESERVE_ALREADY_ADDED = "14"; // 'Reserve has already been added to reserve list'
    string public constant NO_MORE_RESERVES_ALLOWED = "15"; // 'Maximum amount of reserves in the pool reached'
    string public constant EMODE_CATEGORY_RESERVED = "16"; // 'Zero eMode category is reserved for volatile heterogeneous assets'
    string public constant INVALID_EMODE_CATEGORY_ASSIGNMENT = "17"; // 'Invalid eMode category assignment to asset'
    string public constant RESERVE_LIQUIDITY_NOT_ZERO = "18"; // 'The liquidity of the reserve needs to be 0'
    string public constant FLASHLOAN_PREMIUM_INVALID = "19"; // 'Invalid flashloan premium'
    string public constant INVALID_RESERVE_PARAMS = "20"; // 'Invalid risk parameters for the reserve'
    string public constant INVALID_EMODE_CATEGORY_PARAMS = "21"; // 'Invalid risk parameters for the eMode category'
    string public constant BRIDGE_PROTOCOL_FEE_INVALID = "22"; // 'Invalid bridge protocol fee'
    string public constant CALLER_MUST_BE_POOL = "23"; // 'The caller of this function must be a pool'
    string public constant INVALID_MINT_AMOUNT = "24"; // 'Invalid amount to mint'
    string public constant INVALID_BURN_AMOUNT = "25"; // 'Invalid amount to burn'
    string public constant INVALID_AMOUNT = "26"; // 'Amount must be greater than 0'
    string public constant RESERVE_INACTIVE = "27"; // 'Action requires an active reserve'
    string public constant RESERVE_FROZEN = "28"; // 'Action cannot be performed because the reserve is frozen'
    string public constant RESERVE_PAUSED = "29"; // 'Action cannot be performed because the reserve is paused'
    string public constant BORROWING_NOT_ENABLED = "30"; // 'Borrowing is not enabled'
    string public constant STABLE_BORROWING_NOT_ENABLED = "31"; // 'Stable borrowing is not enabled'
    string public constant NOT_ENOUGH_AVAILABLE_USER_BALANCE = "32"; // 'User cannot withdraw more than the available balance'
    string public constant INVALID_INTEREST_RATE_MODE_SELECTED = "33"; // 'Invalid interest rate mode selected'
    string public constant COLLATERAL_BALANCE_IS_ZERO = "34"; // 'The collateral balance is 0'
    string public constant HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD =
        "35"; // 'Health factor is lesser than the liquidation threshold'
    string public constant COLLATERAL_CANNOT_COVER_NEW_BORROW = "36"; // 'There is not enough collateral to cover a new borrow'
    string public constant COLLATERAL_SAME_AS_BORROWING_CURRENCY = "37"; // 'Collateral is (mostly) the same currency that is being borrowed'
    string public constant AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE = "38"; // 'The requested amount is greater than the max loan size in stable rate mode'
    string public constant NO_DEBT_OF_SELECTED_TYPE = "39"; // 'For repayment of a specific type of debt, the user needs to have debt that type'
    string public constant NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF = "40"; // 'To repay on behalf of a user an explicit amount to repay is needed'
    string public constant NO_OUTSTANDING_STABLE_DEBT = "41"; // 'User does not have outstanding stable rate debt on this reserve'
    string public constant NO_OUTSTANDING_VARIABLE_DEBT = "42"; // 'User does not have outstanding variable rate debt on this reserve'
    string public constant UNDERLYING_BALANCE_ZERO = "43"; // 'The underlying balance needs to be greater than 0'
    string public constant INTEREST_RATE_REBALANCE_CONDITIONS_NOT_MET = "44"; // 'Interest rate rebalance conditions were not met'
    string public constant HEALTH_FACTOR_NOT_BELOW_THRESHOLD = "45"; // 'Health factor is not below the threshold'
    string public constant COLLATERAL_CANNOT_BE_LIQUIDATED = "46"; // 'The collateral chosen cannot be liquidated'
    string public constant SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = "47"; // 'User did not borrow the specified currency'
    string public constant SAME_BLOCK_BORROW_REPAY = "48"; // 'Borrow and repay in same block is not allowed'
    string public constant INCONSISTENT_FLASHLOAN_PARAMS = "49"; // 'Inconsistent flashloan parameters'
    string public constant BORROW_CAP_EXCEEDED = "50"; // 'Borrow cap is exceeded'
    string public constant SUPPLY_CAP_EXCEEDED = "51"; // 'Supply cap is exceeded'
    string public constant UNBACKED_MINT_CAP_EXCEEDED = "52"; // 'Unbacked mint cap is exceeded'
    string public constant DEBT_CEILING_EXCEEDED = "53"; // 'Debt ceiling is exceeded'
    string public constant XTOKEN_SUPPLY_NOT_ZERO = "54"; // 'OToken supply is not zero'
    string public constant STABLE_DEBT_NOT_ZERO = "55"; // 'Stable debt supply is not zero'
    string public constant VARIABLE_DEBT_SUPPLY_NOT_ZERO = "56"; // 'Variable debt supply is not zero'
    string public constant LTV_VALIDATION_FAILED = "57"; // 'Ltv validation failed'
    string public constant INCONSISTENT_EMODE_CATEGORY = "58"; // 'Inconsistent eMode category'
    string public constant PRICE_ORACLE_SENTINEL_CHECK_FAILED = "59"; // 'Price oracle sentinel validation failed'
    string public constant ASSET_NOT_BORROWABLE_IN_ISOLATION = "60"; // 'Asset is not borrowable in isolation mode'
    string public constant RESERVE_ALREADY_INITIALIZED = "61"; // 'Reserve has already been initialized'
    string public constant USER_IN_ISOLATION_MODE = "62"; // 'User is in isolation mode'
    string public constant INVALID_LTV = "63"; // 'Invalid ltv parameter for the reserve'
    string public constant INVALID_LIQ_THRESHOLD = "64"; // 'Invalid liquidity threshold parameter for the reserve'
    string public constant INVALID_LIQ_BONUS = "65"; // 'Invalid liquidity bonus parameter for the reserve'
    string public constant INVALID_DECIMALS = "66"; // 'Invalid decimals parameter of the underlying asset of the reserve'
    string public constant INVALID_RESERVE_FACTOR = "67"; // 'Invalid reserve factor parameter for the reserve'
    string public constant INVALID_BORROW_CAP = "68"; // 'Invalid borrow cap for the reserve'
    string public constant INVALID_SUPPLY_CAP = "69"; // 'Invalid supply cap for the reserve'
    string public constant INVALID_LIQUIDATION_PROTOCOL_FEE = "70"; // 'Invalid liquidation protocol fee for the reserve'
    string public constant INVALID_EMODE_CATEGORY = "71"; // 'Invalid eMode category for the reserve'
    string public constant INVALID_UNBACKED_MINT_CAP = "72"; // 'Invalid unbacked mint cap for the reserve'
    string public constant INVALID_DEBT_CEILING = "73"; // 'Invalid debt ceiling for the reserve
    string public constant INVALID_RESERVE_INDEX = "74"; // 'Invalid reserve index'
    string public constant ACL_ADMIN_CANNOT_BE_ZERO = "75"; // 'ACL admin cannot be set to the zero address'
    string public constant INCONSISTENT_PARAMS_LENGTH = "76"; // 'Array parameters that should be equal length are not'
    string public constant ZERO_ADDRESS_NOT_VALID = "77"; // 'Zero address not valid'
    string public constant INVALID_EXPIRATION = "78"; // 'Invalid expiration'
    string public constant INVALID_SIGNATURE = "79"; // 'Invalid signature'
    string public constant OPERATION_NOT_SUPPORTED = "80"; // 'Operation not supported'
    string public constant DEBT_CEILING_NOT_ZERO = "81"; // 'Debt ceiling is not zero'
    string public constant ASSET_NOT_LISTED = "82"; // 'Asset is not listed'
    string public constant INVALID_OPTIMAL_USAGE_RATIO = "83"; // 'Invalid optimal usage ratio'
    string public constant INVALID_OPTIMAL_STABLE_TO_TOTAL_DEBT_RATIO = "84"; // 'Invalid optimal stable to total debt ratio'
    string public constant UNDERLYING_CANNOT_BE_RESCUED = "85"; // 'The underlying asset cannot be rescued'
    string public constant ADDRESSES_PROVIDER_ALREADY_ADDED = "86"; // 'Reserve has already been added to reserve list'
    string public constant POOL_ADDRESSES_DO_NOT_MATCH = "87"; // 'The token implementation pool address and the pool address provided by the initializing pool do not match'
    string public constant STABLE_BORROWING_ENABLED = "88"; // 'Stable borrowing is enabled'
    string public constant SILOED_BORROWING_VIOLATION = "89"; // 'User is trying to borrow multiple assets including a siloed one'
    string public constant RESERVE_DEBT_NOT_ZERO = "90"; // the total debt of the reserve needs to be 0
    string public constant NOT_THE_OWNER = "91"; // user is not the owner of a given asset
    string public constant LIQUIDATION_AMOUNT_NOT_ENOUGH = "92";
    string public constant INVALID_ASSET_TYPE = "93"; // invalid asset type for action.
    string public constant INVALID_FLASH_CLAIM_RECEIVER = "94"; // invalid flash claim receiver.
    string public constant ERC721_HEALTH_FACTOR_NOT_BELOW_THRESHOLD = "95"; // 'ERC721 Health factor is not below the threshold. Can only liquidate ERC20'
    string public constant UNDERLYING_ASSET_CAN_NOT_BE_TRANSFERRED = "96"; //underlying asset can not be transferred.
    string public constant TOKEN_TRANSFERRED_CAN_NOT_BE_SELF_ADDRESS = "97"; //token transferred can not be self address.
    string public constant INVALID_AIRDROP_CONTRACT_ADDRESS = "98"; //invalid airdrop contract address.
    string public constant INVALID_AIRDROP_PARAMETERS = "99"; //invalid airdrop parameters.
    string public constant CALL_AIRDROP_METHOD_FAILED = "100"; //call airdrop method failed.
}// BUSL-1.1
pragma solidity 0.8.10;

library WadRayMath {

    uint256 internal constant WAD = 1e18;
    uint256 internal constant HALF_WAD = 0.5e18;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant HALF_RAY = 0.5e27;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

    function wadMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_WAD), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_WAD), WAD)
        }
    }

    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, WAD), div(b, 2)), b)
        }
    }

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_RAY), RAY)
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), RAY))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, RAY), div(b, 2)), b)
        }
    }

    function rayToWad(uint256 a) internal pure returns (uint256 b) {

        assembly {
            b := div(a, WAD_RAY_RATIO)
            let remainder := mod(a, WAD_RAY_RATIO)
            if iszero(lt(remainder, div(WAD_RAY_RATIO, 2))) {
                b := add(b, 1)
            }
        }
    }

    function wadToRay(uint256 a) internal pure returns (uint256 b) {

        assembly {
            b := mul(a, WAD_RAY_RATIO)

            if iszero(eq(div(b, WAD_RAY_RATIO), a)) {
                revert(0, 0)
            }
        }
    }
}// AGPL-3.0
pragma solidity 0.8.10;

interface IPoolAddressesProvider {

    event MarketIdSet(string indexed oldMarketId, string indexed newMarketId);

    event PoolUpdated(address indexed oldAddress, address indexed newAddress);

    event PoolConfiguratorUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event PriceOracleUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event ACLManagerUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event ACLAdminUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event PriceOracleSentinelUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event PoolDataProviderUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event ProxyCreated(
        bytes32 indexed id,
        address indexed proxyAddress,
        address indexed implementationAddress
    );

    event AddressSet(
        bytes32 indexed id,
        address indexed oldAddress,
        address indexed newAddress
    );

    event AddressSetAsProxy(
        bytes32 indexed id,
        address indexed proxyAddress,
        address oldImplementationAddress,
        address indexed newImplementationAddress
    );

    function getMarketId() external view returns (string memory);


    function setMarketId(string calldata newMarketId) external;


    function getAddress(bytes32 id) external view returns (address);


    function setAddressAsProxy(bytes32 id, address newImplementationAddress)
        external;


    function setAddress(bytes32 id, address newAddress) external;


    function getPool() external view returns (address);


    function setPoolImpl(address newPoolImpl) external;


    function getPoolConfigurator() external view returns (address);


    function setPoolConfiguratorImpl(address newPoolConfiguratorImpl) external;


    function getPriceOracle() external view returns (address);


    function setPriceOracle(address newPriceOracle) external;


    function getACLManager() external view returns (address);


    function setACLManager(address newAclManager) external;


    function getACLAdmin() external view returns (address);


    function setACLAdmin(address newAclAdmin) external;


    function getPriceOracleSentinel() external view returns (address);


    function setPriceOracleSentinel(address newPriceOracleSentinel) external;


    function getPoolDataProvider() external view returns (address);


    function setPoolDataProvider(address newDataProvider) external;

}// BUSL-1.1
pragma solidity 0.8.10;

library DataTypes {

    enum AssetType {
        ERC20,
        ERC721,
        ERC1155
    }

    struct ReserveData {
        ReserveConfigurationMap configuration;
        uint128 liquidityIndex;
        uint128 currentLiquidityRate;
        uint128 variableBorrowIndex;
        uint128 currentVariableBorrowRate;
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        uint16 id;
        AssetType assetType;
        address xTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint128 accruedToTreasury;
    }

    struct ReserveConfigurationMap {

        uint256 data;
    }

    struct UserConfigurationMap {
        uint256 data;
    }

    struct ERC721SupplyParams {
        uint256 tokenId;
        bool useAsCollateral;
    }

    enum InterestRateMode {
        NONE,
        STABLE,
        VARIABLE
    }

    struct ReserveCache {
        AssetType assetType;
        uint256 currScaledVariableDebt;
        uint256 nextScaledVariableDebt;
        uint256 currPrincipalStableDebt;
        uint256 currAvgStableBorrowRate;
        uint256 currTotalStableDebt;
        uint256 nextAvgStableBorrowRate;
        uint256 nextTotalStableDebt;
        uint256 currLiquidityIndex;
        uint256 nextLiquidityIndex;
        uint256 currVariableBorrowIndex;
        uint256 nextVariableBorrowIndex;
        uint256 currLiquidityRate;
        uint256 currVariableBorrowRate;
        uint256 reserveFactor;
        ReserveConfigurationMap reserveConfiguration;
        address xTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        uint40 reserveLastUpdateTimestamp;
        uint40 stableDebtLastUpdateTimestamp;
    }



    struct ExecuteLiquidationCallParams {
        uint256 reservesCount;
        uint256 liquidationAmount;
        uint256 collateralTokenId;
        address collateralAsset;
        address liquidationAsset;
        address user;
        bool receiveXToken;
        address priceOracle;
        address priceOracleSentinel;
    }

    struct ExecuteSupplyParams {
        address asset;
        uint256 amount;
        address onBehalfOf;
        uint16 referralCode;
    }

    struct ExecuteSupplyERC721Params {
        address asset;
        DataTypes.ERC721SupplyParams[] tokenData;
        address onBehalfOf;
        uint16 referralCode;
    }

    struct ExecuteBorrowParams {
        address asset;
        address user;
        address onBehalfOf;
        uint256 amount;
        InterestRateMode interestRateMode;
        uint16 referralCode;
        bool releaseUnderlying;
        uint256 maxStableRateBorrowSizePercent;
        uint256 reservesCount;
        address oracle;
        address priceOracleSentinel;
    }

    struct ExecuteRepayParams {
        address asset;
        uint256 amount;
        InterestRateMode interestRateMode;
        address onBehalfOf;
        bool useOTokens;
    }

    struct ExecuteWithdrawParams {
        address asset;
        uint256 amount;
        address to;
        uint256 reservesCount;
        address oracle;
    }

    struct ExecuteWithdrawERC721Params {
        address asset;
        uint256[] tokenIds;
        address to;
        uint256 reservesCount;
        address oracle;
    }

    struct FinalizeTransferParams {
        address asset;
        address from;
        address to;
        bool usedAsCollateral;
        uint256 value;
        uint256 balanceFromBefore;
        uint256 balanceToBefore;
        uint256 reservesCount;
        address oracle;
    }

    struct CalculateUserAccountDataParams {
        UserConfigurationMap userConfig;
        uint256 reservesCount;
        address user;
        address oracle;
    }

    struct ValidateBorrowParams {
        ReserveCache reserveCache;
        UserConfigurationMap userConfig;
        address asset;
        address userAddress;
        uint256 amount;
        InterestRateMode interestRateMode;
        uint256 maxStableLoanPercent;
        uint256 reservesCount;
        address oracle;
        address priceOracleSentinel;
        AssetType assetType;
    }

    struct ValidateLiquidationCallParams {
        ReserveCache debtReserveCache;
        uint256 totalDebt;
        uint256 healthFactor;
        address priceOracleSentinel;
        AssetType assetType;
    }

    struct ValidateERC721LiquidationCallParams {
        ReserveCache debtReserveCache;
        uint256 totalDebt;
        uint256 healthFactor;
        uint256 tokenId;
        uint256 collateralDiscountedPrice;
        uint256 liquidationAmount;
        address priceOracleSentinel;
        address xTokenAddress;
        AssetType assetType;
    }

    struct CalculateInterestRatesParams {
        uint256 liquidityAdded;
        uint256 liquidityTaken;
        uint256 totalStableDebt;
        uint256 totalVariableDebt;
        uint256 averageStableBorrowRate;
        uint256 reserveFactor;
        address reserve;
        address xToken;
    }

    struct InitReserveParams {
        address asset;
        AssetType assetType;
        address xTokenAddress;
        address stableDebtAddress;
        address variableDebtAddress;
        address interestRateStrategyAddress;
        uint16 reservesCount;
        uint16 maxNumberReserves;
    }

    struct ExecuteFlashClaimParams {
        address receiverAddress;
        address nftAsset;
        uint256[] nftTokenIds;
        bytes params;
    }
}// AGPL-3.0
pragma solidity 0.8.10;


interface IPool {

    event Supply(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referralCode
    );

    event SupplyERC721(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        DataTypes.ERC721SupplyParams[] tokenData,
        uint16 indexed referralCode
    );

    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

    event WithdrawERC721(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256[] tokenIds
    );

    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        DataTypes.InterestRateMode interestRateMode,
        uint256 borrowRate,
        uint16 indexed referralCode
    );

    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount,
        bool useOTokens
    );

    event SwapBorrowRateMode(
        address indexed reserve,
        address indexed user,
        DataTypes.InterestRateMode interestRateMode
    );

    event ReserveUsedAsCollateralEnabled(
        address indexed reserve,
        address indexed user
    );

    event ReserveUsedAsCollateralDisabled(
        address indexed reserve,
        address indexed user
    );

    event RebalanceStableBorrowRate(
        address indexed reserve,
        address indexed user
    );

    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receiveOToken
    );

    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );

    event MintedToTreasury(address indexed reserve, uint256 amountMinted);

    event FlashClaim(
        address indexed target,
        address indexed initiator,
        address indexed nftAsset,
        uint256 tokenId
    );

    function flashClaim(
        address receiverAddress,
        address nftAsset,
        uint256[] calldata nftTokenIds,
        bytes calldata params
    ) external;


    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function supplyERC721(
        address asset,
        DataTypes.ERC721SupplyParams[] calldata tokenData,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function supplyWithPermit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function withdrawERC721(
        address asset,
        uint256[] calldata tokenIds,
        address to
    ) external returns (uint256);


    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;


    function repay(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf
    ) external returns (uint256);


    function repayWithPermit(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external returns (uint256);


    function repayWithOTokens(
        address asset,
        uint256 amount,
        uint256 interestRateMode
    ) external returns (uint256);


    function swapBorrowRateMode(address asset, uint256 interestRateMode)
        external;


    function rebalanceStableBorrowRate(address asset, address user) external;


    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral)
        external;


    function setUserUseERC721AsCollateral(
        address asset,
        uint256 tokenId,
        bool useAsCollateral
    ) external virtual;


    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveOToken
    ) external;


    function liquidationERC721(
        address collateralAsset,
        address liquidationAsset,
        address user,
        uint256 collateralTokenId,
        uint256 liquidationAmount,
        bool receiveNToken
    ) external;


    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor,
            uint256 erc721HealthFactor
        );


    function initReserve(
        address asset,
        DataTypes.AssetType assetType,
        address xTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;


    function dropReserve(address asset) external;


    function setReserveInterestRateStrategyAddress(
        address asset,
        address rateStrategyAddress
    ) external;


    function setConfiguration(
        address asset,
        DataTypes.ReserveConfigurationMap calldata configuration
    ) external;


    function getConfiguration(address asset)
        external
        view
        returns (DataTypes.ReserveConfigurationMap memory);


    function getUserConfiguration(address user)
        external
        view
        returns (DataTypes.UserConfigurationMap memory);


    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);


    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);


    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);


    function finalizeTransfer(
        address asset,
        address from,
        address to,
        bool usedAsCollateral,
        uint256 amount,
        uint256 balanceFromBefore,
        uint256 balanceToBefore
    ) external;


    function getReservesList() external view returns (address[] memory);


    function getReserveAddressById(uint16 id) external view returns (address);


    function ADDRESSES_PROVIDER()
        external
        view
        returns (IPoolAddressesProvider);


    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT()
        external
        view
        returns (uint256);


    function MAX_NUMBER_RESERVES() external view returns (uint16);


    function mintToTreasury(address[] calldata assets) external;


    function rescueTokens(
        address token,
        address to,
        uint256 amount
    ) external;

}// MIT

pragma solidity 0.8.10;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// AGPL-3.0
pragma solidity 0.8.10;

interface IRewardController {

    event RewardsAccrued(address indexed user, uint256 amount);

    event RewardsClaimed(
        address indexed user,
        address indexed to,
        uint256 amount
    );

    event RewardsClaimed(
        address indexed user,
        address indexed to,
        address indexed claimer,
        uint256 amount
    );

    event ClaimerSet(address indexed user, address indexed claimer);

    function getAssetData(address asset)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function assets(address asset)
        external
        view
        returns (
            uint128,
            uint128,
            uint256
        );


    function setClaimer(address user, address claimer) external;


    function getClaimer(address user) external view returns (address);


    function configureAssets(
        address[] calldata assets,
        uint256[] calldata emissionsPerSecond
    ) external;


    function handleAction(
        address asset,
        uint256 totalSupply,
        uint256 userBalance
    ) external;


    function getRewardsBalance(address[] calldata assets, address user)
        external
        view
        returns (uint256);


    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);


    function claimRewardsOnBehalf(
        address[] calldata assets,
        uint256 amount,
        address user,
        address to
    ) external returns (uint256);


    function getUserUnclaimedRewards(address user)
        external
        view
        returns (uint256);


    function getUserAssetData(address user, address asset)
        external
        view
        returns (uint256);


    function REWARD_TOKEN() external view returns (address);


    function PRECISION() external view returns (uint8);


    function DISTRIBUTION_END() external view returns (uint256);

}// AGPL-3.0
pragma solidity 0.8.10;


interface IInitializableNToken {

    event Initialized(
        address indexed underlyingAsset,
        address indexed pool,
        address treasury,
        address incentivesController,
        string nTokenName,
        string nTokenSymbol,
        bytes params
    );

    function initialize(
        IPool pool,
        address treasury,
        address underlyingAsset,
        IRewardController incentivesController,
        uint8 aTokenDecimals,
        string calldata nTokenName,
        string calldata nTokenSymbol,
        bytes calldata params
    ) external;

}// AGPL-3.0
pragma solidity 0.8.10;



interface INToken is
    IERC721Enumerable,
    IInitializableNToken,
    IERC721Receiver,
    IERC1155Receiver
{

    event BalanceTransfer(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );

    event ClaimERC20Airdrop(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event ClaimERC721Airdrop(
        address indexed token,
        address indexed to,
        uint256[] ids
    );

    event ClaimERC1155Airdrop(
        address indexed token,
        address indexed to,
        uint256[] ids,
        uint256[] amounts,
        bytes data
    );

    event ExecuteAirdrop(address indexed airdropContract);

    function mint(
        address caller,
        address onBehalfOf,
        DataTypes.ERC721SupplyParams[] calldata tokenData,
        uint256 index
    ) external returns (bool);


    function burn(
        address from,
        address receiverOfUnderlying,
        uint256[] calldata tokenIds,
        uint256 index
    ) external returns (bool);



    function transferOnLiquidation(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferUnderlyingTo(address user, uint256 tokenId) external;


    function handleRepayment(address user, uint256 tokenId) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function UNDERLYING_ASSET_ADDRESS() external view returns (address);


    function RESERVE_TREASURY_ADDRESS() external view returns (address);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function rescueTokens(
        address token,
        address to,
        uint256 value
    ) external;


    function claimERC20Airdrop(
        address token,
        address to,
        uint256 amount
    ) external;


    function claimERC721Airdrop(
        address token,
        address to,
        uint256[] calldata ids
    ) external;


    function claimERC1155Airdrop(
        address token,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;


    function executeAirdrop(
        address airdropContract,
        bytes calldata airdropParams
    ) external;

}// AGPL-3.0
pragma solidity 0.8.10;


interface IInitializableOToken {

    event Initialized(
        address indexed underlyingAsset,
        address indexed pool,
        address treasury,
        address incentivesController,
        uint8 oTokenDecimals,
        string oTokenName,
        string oTokenSymbol,
        bytes params
    );

    function initialize(
        IPool pool,
        address treasury,
        address underlyingAsset,
        IRewardController incentivesController,
        uint8 oTokenDecimals,
        string calldata oTokenName,
        string calldata oTokenSymbol,
        bytes calldata params
    ) external;

}// AGPL-3.0
pragma solidity 0.8.10;

interface IScaledBalanceToken {

    event Mint(
        address indexed caller,
        address indexed onBehalfOf,
        uint256 value,
        uint256 balanceIncrease,
        uint256 index
    );

    event Burn(
        address indexed from,
        address indexed target,
        uint256 value,
        uint256 balanceIncrease,
        uint256 index
    );

    function scaledBalanceOf(address user) external view returns (uint256);


    function getScaledUserBalanceAndSupply(address user)
        external
        view
        returns (uint256, uint256);


    function scaledTotalSupply() external view returns (uint256);


    function getPreviousIndex(address user) external view returns (uint256);

}// MIT
pragma solidity 0.8.10;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}// MIT

pragma solidity 0.8.10;

library Strings {

  bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';

  function toString(uint256 value) internal pure returns (string memory) {


    if (value == 0) {
      return '0';
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  function toHexString(uint256 value) internal pure returns (string memory) {

    if (value == 0) {
      return '0x00';
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = '0';
    buffer[1] = 'x';
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, 'Strings: hex length insufficient');
    return string(buffer);
  }
}// AGPL-3.0
pragma solidity 0.8.10;

interface ICollaterizableERC721 {

    function collaterizedBalanceOf(address user)
        external
        view
        virtual
        returns (uint256);


    function isUsedAsCollateral(uint256 tokenId) external view returns (bool);


    function setIsUsedAsCollateral(uint256 tokenId, bool useAsCollateral)
        external
        virtual
        returns (
            bool,
            address,
            uint256
        );

}// AGPL-3.0
pragma solidity 0.8.10;


interface IACLManager {

    function ADDRESSES_PROVIDER()
        external
        view
        returns (IPoolAddressesProvider);


    function POOL_ADMIN_ROLE() external view returns (bytes32);


    function EMERGENCY_ADMIN_ROLE() external view returns (bytes32);


    function RISK_ADMIN_ROLE() external view returns (bytes32);


    function FLASH_BORROWER_ROLE() external view returns (bytes32);


    function BRIDGE_ROLE() external view returns (bytes32);


    function ASSET_LISTING_ADMIN_ROLE() external view returns (bytes32);


    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;


    function addPoolAdmin(address admin) external;


    function removePoolAdmin(address admin) external;


    function isPoolAdmin(address admin) external view returns (bool);


    function addEmergencyAdmin(address admin) external;


    function removeEmergencyAdmin(address admin) external;


    function isEmergencyAdmin(address admin) external view returns (bool);


    function addRiskAdmin(address admin) external;


    function removeRiskAdmin(address admin) external;


    function isRiskAdmin(address admin) external view returns (bool);


    function addFlashBorrower(address borrower) external;


    function removeFlashBorrower(address borrower) external;


    function isFlashBorrower(address borrower) external view returns (bool);


    function addBridge(address bridge) external;


    function removeBridge(address bridge) external;


    function isBridge(address bridge) external view returns (bool);


    function addAssetListingAdmin(address admin) external;


    function removeAssetListingAdmin(address admin) external;


    function isAssetListingAdmin(address admin) external view returns (bool);

}// BUSL-1.1
pragma solidity 0.8.10;




abstract contract MintableIncentivizedERC721 is
    ICollaterizableERC721,
    Context,
    IERC721Metadata,
    IERC721Enumerable,
    IERC165
{
    using WadRayMath for uint256;
    using SafeCast for uint256;
    using Address for address;
    using Strings for uint256;

    modifier onlyPoolAdmin() {
        IACLManager aclManager = IACLManager(
            _addressesProvider.getACLManager()
        );
        require(
            aclManager.isPoolAdmin(msg.sender),
            Errors.CALLER_NOT_POOL_ADMIN
        );
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == address(POOL), Errors.CALLER_MUST_BE_POOL);
        _;
    }

    struct UserState {
        uint64 balance;
        uint64 collaterizedBalance;
        uint128 additionalData;
    }

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => UserState) internal _userState;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => mapping(address => uint256)) private _allowances;

    IRewardController internal _rewardController;
    IPoolAddressesProvider internal immutable _addressesProvider;
    IPool public immutable POOL;

    mapping(uint256 => bool) _isUsedAsCollateral;

    constructor(
        IPool pool,
        string memory name,
        string memory symbol
    ) {
        _addressesProvider = pool.ADDRESSES_PROVIDER();
        _name = name;
        _symbol = symbol;
        POOL = pool;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _userState[account].balance;
    }

    function getIncentivesController()
        external
        view
        virtual
        returns (IRewardController)
    {
        return _rewardController;
    }

    function setIncentivesController(IRewardController controller)
        external
        onlyPoolAdmin
    {
        _rewardController = controller;
    }

    function _setName(string memory newName) internal {
        _name = newName;
    }

    function _setSymbol(string memory newSymbol) internal {
        _symbol = newSymbol;
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        return _owners[tokenId];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to old owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    function _mintMultiple(
        address to,
        DataTypes.ERC721SupplyParams[] calldata tokenData
    ) internal virtual returns (bool) {
        require(to != address(0), "ERC721: mint to the zero address");
        uint64 oldBalance = _userState[to].balance;
        uint256 oldTotalSupply = totalSupply();
        uint64 collaterizedTokens;

        uint256 length = _allTokens.length;

        for (uint256 index = 0; index < tokenData.length; index++) {
            uint256 tokenId = tokenData[index].tokenId;

            require(!_exists(tokenId), "ERC721: token already minted");

            _addTokenToAllTokensEnumeration(tokenId, length + index);
            _addTokenToOwnerEnumeration(to, tokenId, oldBalance + index);

            _owners[tokenId] = to;

            if (
                tokenData[index].useAsCollateral &&
                !_isUsedAsCollateral[tokenId]
            ) {
                _isUsedAsCollateral[tokenId] = true;
                collaterizedTokens++;
            }

            emit Transfer(address(0), to, tokenId);


            require(
                _checkOnERC721Received(address(0), to, tokenId, ""),
                "ERC721: transfer to non ERC721Receiver implementer"
            );
        }

        _userState[to].collaterizedBalance += collaterizedTokens;

        _userState[to].balance = oldBalance + uint64(tokenData.length);

        IRewardController rewardControllerLocal = _rewardController;
        if (address(rewardControllerLocal) != address(0)) {
            rewardControllerLocal.handleAction(to, oldTotalSupply, oldBalance);
        }

        return (oldBalance == 0 && collaterizedTokens != 0);
    }

    function _burnMultiple(address user, uint256[] calldata tokenIds)
        internal
        virtual
        returns (bool allCollaterizedBurnt)
    {
        uint64 burntCollaterizedTokens;
        uint64 balanceToBurn;
        uint256 oldTotalSupply = totalSupply();
        uint256 oldBalance = _userState[user].balance;

        uint64 oldCollaterizedBalance = _userState[user].collaterizedBalance;

        uint256 length = _allTokens.length;

        for (uint256 index = 0; index < tokenIds.length; index++) {
            uint256 tokenId = tokenIds[index];
            address owner = ownerOf(tokenId);
            require(owner == user, "not the owner of Ntoken");

            _removeTokenFromAllTokensEnumeration(tokenId, length - index);
            _removeTokenFromOwnerEnumeration(user, tokenId, oldBalance - index);

            _approve(address(0), tokenId);

            balanceToBurn++;
            delete _owners[tokenId];

            if (_isUsedAsCollateral[tokenId]) {
                delete _isUsedAsCollateral[tokenId];
                burntCollaterizedTokens++;
            }
            emit Transfer(owner, address(0), tokenId);

        }

        _userState[user].balance -= balanceToBurn;
        _userState[user].collaterizedBalance =
            oldCollaterizedBalance -
            burntCollaterizedTokens;

        IRewardController rewardControllerLocal = _rewardController;

        if (address(rewardControllerLocal) != address(0)) {
            rewardControllerLocal.handleAction(
                user,
                oldTotalSupply,
                oldBalance
            );
        }

        return (oldCollaterizedBalance == burntCollaterizedTokens);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        uint64 oldSenderBalance = _userState[from].balance;
        _userState[from].balance = oldSenderBalance - 1;
        uint64 oldRecipientBalance = _userState[to].balance;
        _userState[to].balance = oldRecipientBalance + 1;

        _owners[tokenId] = to;


        IRewardController rewardControllerLocal = _rewardController;
        if (address(rewardControllerLocal) != address(0)) {
            uint256 oldTotalSupply = totalSupply();
            rewardControllerLocal.handleAction(
                from,
                oldTotalSupply,
                oldSenderBalance
            );
            if (from != to) {
                rewardControllerLocal.handleAction(
                    to,
                    oldTotalSupply,
                    oldRecipientBalance
                );
            }
        }

        emit Transfer(from, to, tokenId);

    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _transferCollaterizable(
        address from,
        address to,
        uint256 tokenId,
        bool isUsedAsCollateral
    ) internal virtual {
        MintableIncentivizedERC721._transfer(from, to, tokenId);

        if (isUsedAsCollateral) {
            _userState[from].collaterizedBalance -= 1;
            _userState[to].collaterizedBalance += 1;
        }
    }

    function collaterizedBalanceOf(address account)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _userState[account].collaterizedBalance;
    }

    function setIsUsedAsCollateral(uint256 tokenId, bool useAsCollateral)
        external
        virtual
        override
        onlyPool
        returns (
            bool,
            address,
            uint256
        )
    {
        if (_isUsedAsCollateral[tokenId] == useAsCollateral)
            return (false, address(0x0), 0);

        address owner = ownerOf(tokenId);

        uint64 collaterizedBalance = _userState[owner].collaterizedBalance;

        _isUsedAsCollateral[tokenId] = useAsCollateral;
        collaterizedBalance = useAsCollateral
            ? collaterizedBalance + 1
            : collaterizedBalance - 1;
        _userState[owner].collaterizedBalance = collaterizedBalance;

        return (true, owner, collaterizedBalance);
    }

    function isUsedAsCollateral(uint256 tokenId)
        external
        view
        override
        returns (bool)
    {
        return _isUsedAsCollateral[tokenId];
    }

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        if (from == address(0)) {
            uint256 length = _allTokens.length;
            _addTokenToAllTokensEnumeration(tokenId, length);
        } else if (from != to) {
            uint256 userBalance = balanceOf(from);
            _removeTokenFromOwnerEnumeration(from, tokenId, userBalance);
        }
        if (to == address(0)) {
            uint256 length = _allTokens.length;
            _removeTokenFromAllTokensEnumeration(tokenId, length);
        } else if (to != from) {
            uint256 length = balanceOf(to);
            _addTokenToOwnerEnumeration(to, tokenId, length);
        }
    }

    function _addTokenToOwnerEnumeration(
        address to,
        uint256 tokenId,
        uint256 length
    ) private {
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId, uint256 length)
        private
    {
        _allTokensIndex[tokenId] = length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(
        address from,
        uint256 tokenId,
        uint256 userBalance
    ) private {

        uint256 lastTokenIndex = userBalance - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(
        uint256 tokenId,
        uint256 length
    ) private {

        uint256 lastTokenIndex = length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}// agpl-3.0
pragma solidity 0.8.10;


abstract contract ScaledBalanceTokenBaseERC721 is
    MintableIncentivizedERC721,
    IScaledBalanceToken
{
    using WadRayMath for uint256;
    using SafeCast for uint256;

    constructor(
        IPool pool,
        string memory name,
        string memory symbol
    ) MintableIncentivizedERC721(pool, name, symbol) {
    }

    function scaledBalanceOf(address user)
        external
        view
        override
        returns (uint256)
    {
        return balanceOf(user);
    }

    function getScaledUserBalanceAndSupply(address user)
        external
        view
        returns (uint256, uint256)
    {
        return (balanceOf(user), totalSupply());
    }

    function scaledTotalSupply()
        public
        view
        virtual
        override
        returns (uint256)
    {
        return totalSupply();
    }

    function getPreviousIndex(address user)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _userState[user].additionalData;
    }

    function decimals() external view returns (uint8) {
        return 0;
    }
}// agpl-3.0
pragma solidity 0.8.10;


interface IERC20Detailed is IERC20 {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}// BUSL-1.1
pragma solidity 0.8.10;


abstract contract IncentivizedERC20 is Context, IERC20Detailed {
    using WadRayMath for uint256;
    using SafeCast for uint256;

    modifier onlyPoolAdmin() {
        IACLManager aclManager = IACLManager(
            _addressesProvider.getACLManager()
        );
        require(
            aclManager.isPoolAdmin(msg.sender),
            Errors.CALLER_NOT_POOL_ADMIN
        );
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == address(POOL), Errors.CALLER_MUST_BE_POOL);
        _;
    }

    struct UserState {
        uint128 balance;
        uint128 additionalData;
    }
    mapping(address => UserState) internal _userState;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    IRewardController internal _rewardController;
    IPoolAddressesProvider internal immutable _addressesProvider;
    IPool public immutable POOL;

    constructor(
        IPool pool,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) {
        _addressesProvider = pool.ADDRESSES_PROVIDER();
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        POOL = pool;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _userState[account].balance;
    }

    function getIncentivesController()
        external
        view
        virtual
        returns (IRewardController)
    {
        return _rewardController;
    }

    function setIncentivesController(IRewardController controller)
        external
        onlyPoolAdmin
    {
        _rewardController = controller;
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        uint128 castAmount = amount.toUint128();
        _transfer(_msgSender(), recipient, castAmount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        uint128 castAmount = amount.toUint128();
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - castAmount
        );
        _transfer(sender, recipient, castAmount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint128 amount
    ) internal virtual {
        uint128 oldSenderBalance = _userState[sender].balance;
        _userState[sender].balance = oldSenderBalance - amount;
        uint128 oldRecipientBalance = _userState[recipient].balance;
        _userState[recipient].balance = oldRecipientBalance + amount;

        IRewardController rewardControllerLocal = _rewardController;
        if (address(rewardControllerLocal) != address(0)) {
            uint256 currentTotalSupply = _totalSupply;
            rewardControllerLocal.handleAction(
                sender,
                currentTotalSupply,
                oldSenderBalance
            );
            if (sender != recipient) {
                rewardControllerLocal.handleAction(
                    recipient,
                    currentTotalSupply,
                    oldRecipientBalance
                );
            }
        }
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setName(string memory newName) internal {
        _name = newName;
    }

    function _setSymbol(string memory newSymbol) internal {
        _symbol = newSymbol;
    }

    function _setDecimals(uint8 newDecimals) internal {
        _decimals = newDecimals;
    }
}// agpl-3.0
pragma solidity 0.8.10;

abstract contract EIP712Base {
    bytes public constant EIP712_REVISION = bytes("1");
    bytes32 internal constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    mapping(address => uint256) internal _nonces;

    bytes32 internal _domainSeparator;
    uint256 internal immutable _chainId;

    constructor() {
        _chainId = block.chainid;
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        if (block.chainid == _chainId) {
            return _domainSeparator;
        }
        return _calculateDomainSeparator();
    }

    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    function _calculateDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN,
                    keccak256(bytes(_EIP712BaseId())),
                    keccak256(EIP712_REVISION),
                    block.chainid,
                    address(this)
                )
            );
    }

    function _EIP712BaseId() internal view virtual returns (string memory);
}// BUSL-1.1
pragma solidity 0.8.10;


contract NToken is
    VersionedInitializable,
    ScaledBalanceTokenBaseERC721,
    EIP712Base,
    INToken
{

    using WadRayMath for uint256;
    using SafeCast for uint256;
    using GPv2SafeERC20 for IERC20;

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    uint256 public constant NTOKEN_REVISION = 0x1;

    address internal _treasury;
    address internal _underlyingAsset;

    function getRevision() internal pure virtual override returns (uint256) {

        return NTOKEN_REVISION;
    }

    constructor(IPool pool)
        ScaledBalanceTokenBaseERC721(pool, "NTOKEN_IMPL", "NTOKEN_IMPL")
    {
    }

    function initialize(
        IPool initializingPool,
        address treasury,
        address underlyingAsset,
        IRewardController incentivesController,
        uint8 nTokenDecimals,
        string calldata nTokenName,
        string calldata nTokenSymbol,
        bytes calldata params
    ) external override initializer {

        require(initializingPool == POOL, Errors.POOL_ADDRESSES_DO_NOT_MATCH);
        _setName(nTokenName);
        _setSymbol(nTokenSymbol);

        _treasury = treasury;
        _underlyingAsset = underlyingAsset;
        _rewardController = incentivesController;

        _domainSeparator = _calculateDomainSeparator();

        emit Initialized(
            underlyingAsset,
            address(POOL),
            treasury,
            address(incentivesController),
            nTokenName,
            nTokenSymbol,
            params
        );
    }

    function mint(
        address caller,
        address onBehalfOf,
        DataTypes.ERC721SupplyParams[] calldata tokenData,
        uint256 index
    ) external virtual override onlyPool returns (bool) {

        return _mintMultiple(onBehalfOf, tokenData);
    }

    function burn(
        address from,
        address receiverOfUnderlying,
        uint256[] calldata tokenIds,
        uint256 index
    ) external virtual override onlyPool returns (bool) {

        bool withdrawingAllTokens = _burnMultiple(from, tokenIds);

        if (receiverOfUnderlying != address(this)) {
            for (uint256 index = 0; index < tokenIds.length; index++) {
                IERC721(_underlyingAsset).safeTransferFrom(
                    address(this),
                    receiverOfUnderlying,
                    tokenIds[index]
                );
            }
        }

        return withdrawingAllTokens;
    }


    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external override onlyPool {

        _transfer(from, to, value, false);
    }

    function claimERC20Airdrop(
        address token,
        address to,
        uint256 amount
    ) external override onlyPoolAdmin {

        require(
            token != _underlyingAsset,
            Errors.UNDERLYING_ASSET_CAN_NOT_BE_TRANSFERRED
        );
        require(
            token != address(this),
            Errors.TOKEN_TRANSFERRED_CAN_NOT_BE_SELF_ADDRESS
        );
        IERC20(token).transfer(to, amount);
        emit ClaimERC20Airdrop(token, to, amount);
    }

    function claimERC721Airdrop(
        address token,
        address to,
        uint256[] calldata ids
    ) external override onlyPoolAdmin {

        require(
            token != _underlyingAsset,
            Errors.UNDERLYING_ASSET_CAN_NOT_BE_TRANSFERRED
        );
        require(
            token != address(this),
            Errors.TOKEN_TRANSFERRED_CAN_NOT_BE_SELF_ADDRESS
        );
        for (uint256 i = 0; i < ids.length; i++) {
            IERC721(token).safeTransferFrom(address(this), to, ids[i]);
        }
        emit ClaimERC721Airdrop(token, to, ids);
    }

    function claimERC1155Airdrop(
        address token,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override onlyPoolAdmin {

        require(
            token != _underlyingAsset,
            Errors.UNDERLYING_ASSET_CAN_NOT_BE_TRANSFERRED
        );
        require(
            token != address(this),
            Errors.TOKEN_TRANSFERRED_CAN_NOT_BE_SELF_ADDRESS
        );
        IERC1155(token).safeBatchTransferFrom(
            address(this),
            to,
            ids,
            amounts,
            data
        );
        emit ClaimERC1155Airdrop(token, to, ids, amounts, data);
    }

    function executeAirdrop(
        address airdropContract,
        bytes calldata airdropParams
    ) external override onlyPoolAdmin {

        require(
            airdropContract != address(0),
            Errors.INVALID_AIRDROP_CONTRACT_ADDRESS
        );
        require(airdropParams.length >= 4, Errors.INVALID_AIRDROP_PARAMETERS);

        Address.functionCall(
            airdropContract,
            airdropParams,
            Errors.CALL_AIRDROP_METHOD_FAILED
        );

        emit ExecuteAirdrop(airdropContract);
    }

    function RESERVE_TREASURY_ADDRESS()
        external
        view
        override
        returns (address)
    {

        return _treasury;
    }

    function UNDERLYING_ASSET_ADDRESS()
        external
        view
        override
        returns (address)
    {

        return _underlyingAsset;
    }

    function transferUnderlyingTo(address target, uint256 tokenId)
        external
        virtual
        override
        onlyPool
    {

        IERC721(_underlyingAsset).safeTransferFrom(
            address(this),
            target,
            tokenId
        );
    }

    function handleRepayment(address user, uint256 amount)
        external
        virtual
        override
        onlyPool
    {

    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        require(owner != address(0), Errors.ZERO_ADDRESS_NOT_VALID);
        require(block.timestamp <= deadline, Errors.INVALID_EXPIRATION);
        uint256 currentValidNonce = _nonces[owner];
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        currentValidNonce,
                        deadline
                    )
                )
            )
        );
        require(owner == ecrecover(digest, v, r, s), Errors.INVALID_SIGNATURE);
        _nonces[owner] = currentValidNonce + 1;
        _approve(spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId,
        bool validate
    ) internal {

        address underlyingAsset = _underlyingAsset;

        uint256 fromBalanceBefore = balanceOf(from);
        uint256 toBalanceBefore = balanceOf(to);

        bool isUsedAsCollateral = _isUsedAsCollateral[tokenId];
        _transferCollaterizable(from, to, tokenId, isUsedAsCollateral);

        if (validate) {
            POOL.finalizeTransfer(
                underlyingAsset,
                from,
                to,
                isUsedAsCollateral,
                tokenId,
                fromBalanceBefore,
                toBalanceBefore
            );
        }

    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {

        _transfer(from, to, tokenId, true);
    }

    function DOMAIN_SEPARATOR()
        public
        view
        override(INToken, EIP712Base)
        returns (bytes32)
    {

        return super.DOMAIN_SEPARATOR();
    }

    function nonces(address owner)
        public
        view
        override(INToken, EIP712Base)
        returns (uint256)
    {

        return super.nonces(owner);
    }

    function _EIP712BaseId() internal view override returns (string memory) {

        return name();
    }

    function rescueTokens(
        address token,
        address to,
        uint256 tokenId
    ) external override onlyPoolAdmin {

        require(token != _underlyingAsset, Errors.UNDERLYING_CANNOT_BE_RESCUED);

        IERC721(token).safeTransferFrom(address(this), to, tokenId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {

        operator;
        from;
        id;
        value;
        data;
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {

        operator;
        from;
        ids;
        values;
        data;
        return this.onERC1155BatchReceived.selector;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        return IERC721Metadata(_underlyingAsset).tokenURI(tokenId);
    }
}