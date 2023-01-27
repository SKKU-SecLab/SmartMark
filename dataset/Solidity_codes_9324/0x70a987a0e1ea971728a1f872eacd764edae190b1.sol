
pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


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


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
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
  string public constant CALLER_NOT_ONBEHALFOF_OR_IN_WHITELIST = "104";

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
  string public constant LP_AMOUNT_GREATER_THAN_MAX_REPAY = "416";

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
  string public constant LPL_BID_INVALID_BID_FINE = "494";

  string public constant CT_CALLER_MUST_BE_LEND_POOL = "500"; // 'The caller of this function must be a lending pool'
  string public constant CT_INVALID_MINT_AMOUNT = "501"; //invalid amount to mint
  string public constant CT_INVALID_BURN_AMOUNT = "502"; //invalid amount to burn
  string public constant CT_BORROW_ALLOWANCE_NOT_ENOUGH = "503";

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

}// agpl-3.0
pragma solidity 0.8.4;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint40 lastUpdateTimestamp;
    address bTokenAddress;
    address debtTokenAddress;
    address interestRateAddress;
    uint8 id;
  }

  struct NftData {
    NftConfigurationMap configuration;
    address bNftAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct NftConfigurationMap {
    uint256 data;
  }

  enum LoanState {
    None,
    Created,
    Active,
    Auction,
    Repaid,
    Defaulted
  }

  struct LoanData {
    uint256 loanId;
    LoanState state;
    address borrower;
    address nftAsset;
    uint256 nftTokenId;
    address reserveAsset;
    uint256 scaledAmount;
    uint256 bidStartTimestamp;
    address bidderAddress;
    uint256 bidPrice;
    uint256 bidBorrowAmount;
  }
}// agpl-3.0
pragma solidity 0.8.4;


interface ILendPool {

  event Deposit(
    address user,
    address indexed reserve,
    uint256 amount,
    address indexed onBehalfOf,
    uint16 indexed referral
  );

  event Withdraw(address indexed user, address indexed reserve, uint256 amount, address indexed to);

  event Borrow(
    address user,
    address indexed reserve,
    uint256 amount,
    address nftAsset,
    uint256 nftTokenId,
    address indexed onBehalfOf,
    uint256 borrowRate,
    uint256 loanId,
    uint16 indexed referral
  );

  event Repay(
    address user,
    address indexed reserve,
    uint256 amount,
    address indexed nftAsset,
    uint256 nftTokenId,
    address indexed borrower,
    uint256 loanId
  );

  event Auction(
    address user,
    address indexed reserve,
    uint256 bidPrice,
    address indexed nftAsset,
    uint256 nftTokenId,
    address onBehalfOf,
    address indexed borrower,
    uint256 loanId
  );

  event Redeem(
    address user,
    address indexed reserve,
    uint256 borrowAmount,
    uint256 fineAmount,
    address indexed nftAsset,
    uint256 nftTokenId,
    address indexed borrower,
    uint256 loanId
  );

  event Liquidate(
    address user,
    address indexed reserve,
    uint256 repayAmount,
    uint256 remainAmount,
    address indexed nftAsset,
    uint256 nftTokenId,
    address indexed borrower,
    uint256 loanId
  );

  event Paused();

  event Unpaused();

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address reserve,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function withdraw(
    address reserve,
    uint256 amount,
    address to
  ) external returns (uint256);


  function borrow(
    address reserveAsset,
    uint256 amount,
    address nftAsset,
    uint256 nftTokenId,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function batchBorrow(
    address[] calldata assets,
    uint256[] calldata amounts,
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function repay(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external returns (uint256, bool);


  function batchRepay(
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    uint256[] calldata amounts
  ) external returns (uint256[] memory, bool[] memory);


  function auction(
    address nftAsset,
    uint256 nftTokenId,
    uint256 bidPrice,
    address onBehalfOf
  ) external;


  function redeem(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount,
    uint256 bidFine
  ) external returns (uint256);


  function liquidate(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external returns (uint256);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromBefore,
    uint256 balanceToBefore
  ) external view;


  function getReserveConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);


  function getNftConfiguration(address asset) external view returns (DataTypes.NftConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function getReservesList() external view returns (address[] memory);


  function getNftData(address asset) external view returns (DataTypes.NftData memory);


  function getNftCollateralData(address nftAsset, address reserveAsset)
    external
    view
    returns (
      uint256 totalCollateralInETH,
      uint256 totalCollateralInReserve,
      uint256 availableBorrowsInETH,
      uint256 availableBorrowsInReserve,
      uint256 ltv,
      uint256 liquidationThreshold,
      uint256 liquidationBonus
    );


  function getNftDebtData(address nftAsset, uint256 nftTokenId)
    external
    view
    returns (
      uint256 loanId,
      address reserveAsset,
      uint256 totalCollateral,
      uint256 totalDebt,
      uint256 availableBorrows,
      uint256 healthFactor
    );


  function getNftAuctionData(address nftAsset, uint256 nftTokenId)
    external
    view
    returns (
      uint256 loanId,
      address bidderAddress,
      uint256 bidPrice,
      uint256 bidBorrowAmount,
      uint256 bidFine
    );


  function getNftLiquidatePrice(address nftAsset, uint256 nftTokenId)
    external
    view
    returns (uint256 liquidatePrice, uint256 paybackAmount);


  function getNftsList() external view returns (address[] memory);


  function setPause(bool val) external;


  function paused() external view returns (bool);


  function getAddressesProvider() external view returns (ILendPoolAddressesProvider);


  function initReserve(
    address asset,
    address bTokenAddress,
    address debtTokenAddress,
    address interestRateAddress
  ) external;


  function initNft(address asset, address bNftAddress) external;


  function setReserveInterestRateAddress(address asset, address rateAddress) external;


  function setReserveConfiguration(address asset, uint256 configuration) external;


  function setNftConfiguration(address asset, uint256 configuration) external;


  function setMaxNumberOfReserves(uint256 val) external;


  function setMaxNumberOfNfts(uint256 val) external;


  function getMaxNumberOfReserves() external view returns (uint256);


  function getMaxNumberOfNfts() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;


interface ILendPoolLoan {

  event Initialized(address indexed pool);

  event LoanCreated(
    address indexed user,
    address indexed onBehalfOf,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  );

  event LoanUpdated(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amountAdded,
    uint256 amountTaken,
    uint256 borrowIndex
  );

  event LoanRepaid(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  );

  event LoanAuctioned(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount,
    uint256 borrowIndex,
    address bidder,
    uint256 price,
    address previousBidder,
    uint256 previousPrice
  );

  event LoanRedeemed(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amountTaken,
    uint256 borrowIndex
  );

  event LoanLiquidated(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  );

  function initNft(address nftAsset, address bNftAddress) external;


  function createLoan(
    address initiator,
    address onBehalfOf,
    address nftAsset,
    uint256 nftTokenId,
    address bNftAddress,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  ) external returns (uint256);


  function updateLoan(
    address initiator,
    uint256 loanId,
    uint256 amountAdded,
    uint256 amountTaken,
    uint256 borrowIndex
  ) external;


  function repayLoan(
    address initiator,
    uint256 loanId,
    address bNftAddress,
    uint256 amount,
    uint256 borrowIndex
  ) external;


  function auctionLoan(
    address initiator,
    uint256 loanId,
    address onBehalfOf,
    uint256 bidPrice,
    uint256 borrowAmount,
    uint256 borrowIndex
  ) external;


  function redeemLoan(
    address initiator,
    uint256 loanId,
    uint256 amountTaken,
    uint256 borrowIndex
  ) external;


  function liquidateLoan(
    address initiator,
    uint256 loanId,
    address bNftAddress,
    uint256 borrowAmount,
    uint256 borrowIndex
  ) external;


  function borrowerOf(uint256 loanId) external view returns (address);


  function getCollateralLoanId(address nftAsset, uint256 nftTokenId) external view returns (uint256);


  function getLoan(uint256 loanId) external view returns (DataTypes.LoanData memory loanData);


  function getLoanCollateralAndReserve(uint256 loanId)
    external
    view
    returns (
      address nftAsset,
      uint256 nftTokenId,
      address reserveAsset,
      uint256 scaledAmount
    );


  function getLoanReserveBorrowScaledAmount(uint256 loanId) external view returns (address, uint256);


  function getLoanReserveBorrowAmount(uint256 loanId) external view returns (address, uint256);


  function getLoanHighestBid(uint256 loanId) external view returns (address, uint256);


  function getNftCollateralAmount(address nftAsset) external view returns (uint256);


  function getUserNftCollateralAmount(address user, address nftAsset) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface IPunks {

  function balanceOf(address account) external view returns (uint256);


  function punkIndexToAddress(uint256 punkIndex) external view returns (address owner);


  function buyPunk(uint256 punkIndex) external;


  function transferPunk(address to, uint256 punkIndex) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


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


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// agpl-3.0
pragma solidity 0.8.4;


interface IWrappedPunks is IERC721 {

  function punkContract() external view returns (address);


  function mint(uint256 punkIndex) external;


  function burn(uint256 punkIndex) external;


  function registerProxy() external;


  function proxyInfo(address user) external returns (address proxy);

}// agpl-3.0
pragma solidity 0.8.4;

interface IPunkGateway {

  function borrow(
    address reserveAsset,
    uint256 amount,
    uint256 punkIndex,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function batchBorrow(
    address[] calldata reserveAssets,
    uint256[] calldata amounts,
    uint256[] calldata punkIndexs,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function repay(uint256 punkIndex, uint256 amount) external returns (uint256, bool);


  function batchRepay(uint256[] calldata punkIndexs, uint256[] calldata amounts)
    external
    returns (uint256[] memory, bool[] memory);


  function auction(
    uint256 punkIndex,
    uint256 bidPrice,
    address onBehalfOf
  ) external;


  function redeem(
    uint256 punkIndex,
    uint256 amount,
    uint256 bidFine
  ) external returns (uint256);


  function liquidate(uint256 punkIndex, uint256 amount) external returns (uint256);


  function borrowETH(
    uint256 amount,
    uint256 punkIndex,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function batchBorrowETH(
    uint256[] calldata amounts,
    uint256[] calldata punkIndexs,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function repayETH(uint256 punkIndex, uint256 amount) external payable returns (uint256, bool);


  function batchRepayETH(uint256[] calldata punkIndexs, uint256[] calldata amounts)
    external
    payable
    returns (uint256[] memory, bool[] memory);


  function auctionETH(uint256 punkIndex, address onBehalfOf) external payable;


  function redeemETH(
    uint256 punkIndex,
    uint256 amount,
    uint256 bidFine
  ) external payable returns (uint256);


  function liquidateETH(uint256 punkIndex) external payable returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface IWETHGateway {

  function depositETH(address onBehalfOf, uint16 referralCode) external payable;


  function withdrawETH(uint256 amount, address to) external;


  function borrowETH(
    uint256 amount,
    address nftAsset,
    uint256 nftTokenId,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function batchBorrowETH(
    uint256[] calldata amounts,
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function repayETH(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external payable returns (uint256, bool);


  function batchRepayETH(
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    uint256[] calldata amounts
  ) external payable returns (uint256[] memory, bool[] memory);


  function auctionETH(
    address nftAsset,
    uint256 nftTokenId,
    address onBehalfOf
  ) external payable;


  function redeemETH(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount,
    uint256 bidFine
  ) external payable returns (uint256);


  function liquidateETH(address nftAsset, uint256 nftTokenId) external payable returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;



abstract contract EmergencyTokenRecoveryUpgradeable is OwnableUpgradeable {
  event EmergencyEtherTransfer(address indexed to, uint256 amount);

  function __EmergencyTokenRecovery_init() internal onlyInitializing {
    __Ownable_init();
  }

  function emergencyERC20Transfer(
    address token,
    address to,
    uint256 amount
  ) external onlyOwner {
    IERC20Upgradeable(token).transfer(to, amount);
  }

  function emergencyERC721Transfer(
    address token,
    address to,
    uint256 id
  ) external onlyOwner {
    IERC721Upgradeable(token).safeTransferFrom(address(this), to, id);
  }

  function emergencyPunksTransfer(
    address punks,
    address to,
    uint256 index
  ) external onlyOwner {
    IPunks(punks).transferPunk(to, index);
  }

  function emergencyEtherTransfer(address to, uint256 amount) external onlyOwner {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    require(success, "ETH_TRANSFER_FAILED");
    emit EmergencyEtherTransfer(to, amount);
  }

  uint256[50] private __gap;
}// agpl-3.0
pragma solidity 0.8.4;




contract PunkGateway is IPunkGateway, ERC721HolderUpgradeable, EmergencyTokenRecoveryUpgradeable {

  using SafeERC20Upgradeable for IERC20Upgradeable;

  ILendPoolAddressesProvider internal _addressProvider;
  IWETHGateway internal _wethGateway;

  IPunks public punks;
  IWrappedPunks public wrappedPunks;
  address public proxy;

  mapping(address => bool) internal _callerWhitelists;

  uint256 private constant _NOT_ENTERED = 0;
  uint256 private constant _ENTERED = 1;
  uint256 private _status;

  modifier nonReentrant() {

    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

    _status = _ENTERED;

    _;

    _status = _NOT_ENTERED;
  }

  function initialize(
    address addressProvider,
    address wethGateway,
    address _punks,
    address _wrappedPunks
  ) public initializer {

    __ERC721Holder_init();
    __EmergencyTokenRecovery_init();

    _addressProvider = ILendPoolAddressesProvider(addressProvider);
    _wethGateway = IWETHGateway(wethGateway);

    punks = IPunks(_punks);
    wrappedPunks = IWrappedPunks(_wrappedPunks);
    wrappedPunks.registerProxy();
    proxy = wrappedPunks.proxyInfo(address(this));

    IERC721Upgradeable(address(wrappedPunks)).setApprovalForAll(address(_getLendPool()), true);
    IERC721Upgradeable(address(wrappedPunks)).setApprovalForAll(address(_wethGateway), true);
  }

  function _getLendPool() internal view returns (ILendPool) {

    return ILendPool(_addressProvider.getLendPool());
  }

  function _getLendPoolLoan() internal view returns (ILendPoolLoan) {

    return ILendPoolLoan(_addressProvider.getLendPoolLoan());
  }

  function authorizeLendPoolERC20(address[] calldata tokens) external nonReentrant onlyOwner {

    for (uint256 i = 0; i < tokens.length; i++) {
      IERC20Upgradeable(tokens[i]).approve(address(_getLendPool()), type(uint256).max);
    }
  }

  function authorizeCallerWhitelist(address[] calldata callers, bool flag) external nonReentrant onlyOwner {

    for (uint256 i = 0; i < callers.length; i++) {
      _callerWhitelists[callers[i]] = flag;
    }
  }

  function isCallerInWhitelist(address caller) external view returns (bool) {

    return _callerWhitelists[caller];
  }

  function _checkValidCallerAndOnBehalfOf(address onBehalfOf) internal view {

    require(
      (onBehalfOf == _msgSender()) || (_callerWhitelists[_msgSender()] == true),
      Errors.CALLER_NOT_ONBEHALFOF_OR_IN_WHITELIST
    );
  }

  function _depositPunk(uint256 punkIndex) internal {

    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    if (loanId != 0) {
      return;
    }

    address owner = punks.punkIndexToAddress(punkIndex);
    require(owner == _msgSender(), "PunkGateway: not owner of punkIndex");

    punks.buyPunk(punkIndex);
    punks.transferPunk(proxy, punkIndex);

    wrappedPunks.mint(punkIndex);
  }

  function borrow(
    address reserveAsset,
    uint256 amount,
    uint256 punkIndex,
    address onBehalfOf,
    uint16 referralCode
  ) external override nonReentrant {

    _checkValidCallerAndOnBehalfOf(onBehalfOf);

    ILendPool cachedPool = _getLendPool();

    _depositPunk(punkIndex);

    cachedPool.borrow(reserveAsset, amount, address(wrappedPunks), punkIndex, onBehalfOf, referralCode);
    IERC20Upgradeable(reserveAsset).transfer(onBehalfOf, amount);
  }

  function batchBorrow(
    address[] calldata reserveAssets,
    uint256[] calldata amounts,
    uint256[] calldata punkIndexs,
    address onBehalfOf,
    uint16 referralCode
  ) external override nonReentrant {

    require(punkIndexs.length == reserveAssets.length, "inconsistent reserveAssets length");
    require(punkIndexs.length == amounts.length, "inconsistent amounts length");

    _checkValidCallerAndOnBehalfOf(onBehalfOf);

    ILendPool cachedPool = _getLendPool();

    for (uint256 i = 0; i < punkIndexs.length; i++) {
      _depositPunk(punkIndexs[i]);

      cachedPool.borrow(reserveAssets[i], amounts[i], address(wrappedPunks), punkIndexs[i], onBehalfOf, referralCode);

      IERC20Upgradeable(reserveAssets[i]).transfer(onBehalfOf, amounts[i]);
    }
  }

  function _withdrawPunk(uint256 punkIndex, address onBehalfOf) internal {

    address owner = wrappedPunks.ownerOf(punkIndex);
    require(owner == _msgSender(), "PunkGateway: caller is not owner");
    require(owner == onBehalfOf, "PunkGateway: onBehalfOf is not owner");

    wrappedPunks.safeTransferFrom(onBehalfOf, address(this), punkIndex);
    wrappedPunks.burn(punkIndex);
    punks.transferPunk(onBehalfOf, punkIndex);
  }

  function repay(uint256 punkIndex, uint256 amount) external override nonReentrant returns (uint256, bool) {

    return _repay(punkIndex, amount);
  }

  function batchRepay(uint256[] calldata punkIndexs, uint256[] calldata amounts)
    external
    override
    nonReentrant
    returns (uint256[] memory, bool[] memory)
  {

    require(punkIndexs.length == amounts.length, "inconsistent amounts length");

    uint256[] memory repayAmounts = new uint256[](punkIndexs.length);
    bool[] memory repayAlls = new bool[](punkIndexs.length);

    for (uint256 i = 0; i < punkIndexs.length; i++) {
      (repayAmounts[i], repayAlls[i]) = _repay(punkIndexs[i], amounts[i]);
    }

    return (repayAmounts, repayAlls);
  }

  function _repay(uint256 punkIndex, uint256 amount) internal returns (uint256, bool) {

    ILendPool cachedPool = _getLendPool();
    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");
    (, , address reserve, ) = cachedPoolLoan.getLoanCollateralAndReserve(loanId);
    (, uint256 debt) = cachedPoolLoan.getLoanReserveBorrowAmount(loanId);
    address borrower = cachedPoolLoan.borrowerOf(loanId);

    if (amount > debt) {
      amount = debt;
    }

    IERC20Upgradeable(reserve).transferFrom(msg.sender, address(this), amount);

    (uint256 paybackAmount, bool burn) = cachedPool.repay(address(wrappedPunks), punkIndex, amount);

    if (burn) {
      require(borrower == _msgSender(), "PunkGateway: caller is not borrower");
      _withdrawPunk(punkIndex, borrower);
    }

    return (paybackAmount, burn);
  }

  function auction(
    uint256 punkIndex,
    uint256 bidPrice,
    address onBehalfOf
  ) external override nonReentrant {

    _checkValidCallerAndOnBehalfOf(onBehalfOf);

    ILendPool cachedPool = _getLendPool();
    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");

    (, , address reserve, ) = cachedPoolLoan.getLoanCollateralAndReserve(loanId);

    IERC20Upgradeable(reserve).transferFrom(msg.sender, address(this), bidPrice);

    cachedPool.auction(address(wrappedPunks), punkIndex, bidPrice, onBehalfOf);
  }

  function redeem(
    uint256 punkIndex,
    uint256 amount,
    uint256 bidFine
  ) external override nonReentrant returns (uint256) {

    ILendPool cachedPool = _getLendPool();
    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");

    DataTypes.LoanData memory loan = cachedPoolLoan.getLoan(loanId);

    IERC20Upgradeable(loan.reserveAsset).transferFrom(msg.sender, address(this), (amount + bidFine));

    uint256 paybackAmount = cachedPool.redeem(address(wrappedPunks), punkIndex, amount, bidFine);

    if ((amount + bidFine) > paybackAmount) {
      IERC20Upgradeable(loan.reserveAsset).safeTransfer(msg.sender, ((amount + bidFine) - paybackAmount));
    }

    return paybackAmount;
  }

  function liquidate(uint256 punkIndex, uint256 amount) external override nonReentrant returns (uint256) {

    ILendPool cachedPool = _getLendPool();
    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");

    DataTypes.LoanData memory loan = cachedPoolLoan.getLoan(loanId);
    require(loan.bidderAddress == _msgSender(), "PunkGateway: caller is not bidder");

    if (amount > 0) {
      IERC20Upgradeable(loan.reserveAsset).transferFrom(msg.sender, address(this), amount);
    }

    uint256 extraRetAmount = cachedPool.liquidate(address(wrappedPunks), punkIndex, amount);

    _withdrawPunk(punkIndex, loan.bidderAddress);

    if (amount > extraRetAmount) {
      IERC20Upgradeable(loan.reserveAsset).safeTransfer(msg.sender, (amount - extraRetAmount));
    }

    return (extraRetAmount);
  }

  function borrowETH(
    uint256 amount,
    uint256 punkIndex,
    address onBehalfOf,
    uint16 referralCode
  ) external override nonReentrant {

    _checkValidCallerAndOnBehalfOf(onBehalfOf);

    _depositPunk(punkIndex);
    _wethGateway.borrowETH(amount, address(wrappedPunks), punkIndex, onBehalfOf, referralCode);
  }

  function batchBorrowETH(
    uint256[] calldata amounts,
    uint256[] calldata punkIndexs,
    address onBehalfOf,
    uint16 referralCode
  ) external override nonReentrant {

    require(punkIndexs.length == amounts.length, "inconsistent amounts length");

    _checkValidCallerAndOnBehalfOf(onBehalfOf);

    address[] memory nftAssets = new address[](punkIndexs.length);
    for (uint256 i = 0; i < punkIndexs.length; i++) {
      nftAssets[i] = address(wrappedPunks);
      _depositPunk(punkIndexs[i]);
    }

    _wethGateway.batchBorrowETH(amounts, nftAssets, punkIndexs, onBehalfOf, referralCode);
  }

  function repayETH(uint256 punkIndex, uint256 amount) external payable override nonReentrant returns (uint256, bool) {

    (uint256 paybackAmount, bool burn) = _repayETH(punkIndex, amount, 0);

    if (msg.value > paybackAmount) {
      _safeTransferETH(msg.sender, msg.value - paybackAmount);
    }

    return (paybackAmount, burn);
  }

  function batchRepayETH(uint256[] calldata punkIndexs, uint256[] calldata amounts)
    external
    payable
    override
    nonReentrant
    returns (uint256[] memory, bool[] memory)
  {

    require(punkIndexs.length == amounts.length, "inconsistent amounts length");

    uint256[] memory repayAmounts = new uint256[](punkIndexs.length);
    bool[] memory repayAlls = new bool[](punkIndexs.length);
    uint256 allRepayAmount = 0;

    for (uint256 i = 0; i < punkIndexs.length; i++) {
      (repayAmounts[i], repayAlls[i]) = _repayETH(punkIndexs[i], amounts[i], allRepayAmount);
      allRepayAmount += repayAmounts[i];
    }

    if (msg.value > allRepayAmount) {
      _safeTransferETH(msg.sender, msg.value - allRepayAmount);
    }

    return (repayAmounts, repayAlls);
  }

  function _repayETH(
    uint256 punkIndex,
    uint256 amount,
    uint256 accAmount
  ) internal returns (uint256, bool) {

    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");

    address borrower = cachedPoolLoan.borrowerOf(loanId);
    require(borrower == _msgSender(), "PunkGateway: caller is not borrower");

    (, uint256 repayDebtAmount) = cachedPoolLoan.getLoanReserveBorrowAmount(loanId);
    if (amount < repayDebtAmount) {
      repayDebtAmount = amount;
    }

    require(msg.value >= (accAmount + repayDebtAmount), "msg.value is less than repay amount");

    (uint256 paybackAmount, bool burn) = _wethGateway.repayETH{value: repayDebtAmount}(
      address(wrappedPunks),
      punkIndex,
      amount
    );

    if (burn) {
      _withdrawPunk(punkIndex, borrower);
    }

    return (paybackAmount, burn);
  }

  function auctionETH(uint256 punkIndex, address onBehalfOf) external payable override nonReentrant {

    _checkValidCallerAndOnBehalfOf(onBehalfOf);

    _wethGateway.auctionETH{value: msg.value}(address(wrappedPunks), punkIndex, onBehalfOf);
  }

  function redeemETH(
    uint256 punkIndex,
    uint256 amount,
    uint256 bidFine
  ) external payable override nonReentrant returns (uint256) {

    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");


    uint256 paybackAmount = _wethGateway.redeemETH{value: msg.value}(address(wrappedPunks), punkIndex, amount, bidFine);

    if (msg.value > paybackAmount) {
      _safeTransferETH(msg.sender, msg.value - paybackAmount);
    }

    return paybackAmount;
  }

  function liquidateETH(uint256 punkIndex) external payable override nonReentrant returns (uint256) {

    ILendPoolLoan cachedPoolLoan = _getLendPoolLoan();

    uint256 loanId = cachedPoolLoan.getCollateralLoanId(address(wrappedPunks), punkIndex);
    require(loanId != 0, "PunkGateway: no loan with such punkIndex");

    DataTypes.LoanData memory loan = cachedPoolLoan.getLoan(loanId);
    require(loan.bidderAddress == _msgSender(), "PunkGateway: caller is not bidder");

    uint256 extraAmount = _wethGateway.liquidateETH{value: msg.value}(address(wrappedPunks), punkIndex);

    _withdrawPunk(punkIndex, loan.bidderAddress);

    if (msg.value > extraAmount) {
      _safeTransferETH(msg.sender, msg.value - extraAmount);
    }

    return extraAmount;
  }

  function _safeTransferETH(address to, uint256 value) internal {

    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "ETH_TRANSFER_FAILED");
  }

  receive() external payable {}

  fallback() external payable {
    revert("Fallback not allowed");
  }
}