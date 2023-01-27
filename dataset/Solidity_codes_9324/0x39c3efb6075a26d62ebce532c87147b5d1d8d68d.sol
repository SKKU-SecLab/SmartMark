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

interface IIncentivesController {

  function handleAction(
    address asset,
    uint256 totalSupply,
    uint256 userBalance
  ) external;

}// agpl-3.0
pragma solidity 0.8.4;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// agpl-3.0
pragma solidity 0.8.4;



interface IBToken is IScaledBalanceToken, IERC20Upgradeable, IERC20MetadataUpgradeable {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    address incentivesController
  );

  function initialize(
    ILendPoolAddressesProvider addressProvider,
    address treasury,
    address underlyingAsset,
    uint8 bTokenDecimals,
    string calldata bTokenName,
    string calldata bTokenSymbol
  ) external;


  event Mint(address indexed from, uint256 value, uint256 index);

  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external returns (bool);


  event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

  event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external;


  function mintToTreasury(uint256 amount, uint256 index) external;


  function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);


  function getIncentivesController() external view returns (IIncentivesController);


  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// agpl-3.0
pragma solidity 0.8.4;



interface IDebtToken is IScaledBalanceToken, IERC20Upgradeable, IERC20MetadataUpgradeable {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address incentivesController,
    uint8 debtTokenDecimals,
    string debtTokenName,
    string debtTokenSymbol
  );

  function initialize(
    ILendPoolAddressesProvider addressProvider,
    address underlyingAsset,
    uint8 debtTokenDecimals,
    string memory debtTokenName,
    string memory debtTokenSymbol
  ) external;


  event Mint(address indexed from, uint256 value, uint256 index);

  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external returns (bool);


  event Burn(address indexed user, uint256 amount, uint256 index);

  function burn(
    address user,
    uint256 amount,
    uint256 index
  ) external;


  function getIncentivesController() external view returns (IIncentivesController);

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


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// agpl-3.0
pragma solidity 0.8.4;


interface IBNFT is IERC721MetadataUpgradeable, IERC721ReceiverUpgradeable, IERC721EnumerableUpgradeable {

  event Initialized(address indexed underlyingAsset);

  event Mint(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event Burn(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event FlashLoan(address indexed target, address indexed initiator, address indexed nftAsset, uint256 tokenId);

  function initialize(
    address underlyingAsset,
    string calldata bNftName,
    string calldata bNftSymbol
  ) external;


  function mint(address to, uint256 tokenId) external;


  function burn(uint256 tokenId) external;


  function flashLoan(
    address receiverAddress,
    uint256[] calldata nftTokenIds,
    bytes calldata params
  ) external;


  function minterOf(uint256 tokenId) external view returns (address);

}// agpl-3.0
pragma solidity 0.8.4;

interface IBNFTRegistry {

  event Initialized(address genericImpl, string namePrefix, string symbolPrefix);
  event GenericImplementationUpdated(address genericImpl);
  event BNFTCreated(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event BNFTUpgraded(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);

  function getBNFTAddresses(address nftAsset) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAddressesByIndex(uint16 index) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAssetList() external view returns (address[] memory);


  function allBNFTAssetLength() external view returns (uint256);


  function initialize(
    address genericImpl,
    string memory namePrefix_,
    string memory symbolPrefix_
  ) external;


  function setBNFTGenericImpl(address genericImpl) external;


  function createBNFT(address nftAsset) external returns (address bNftProxy);


  function createBNFTWithImpl(address nftAsset, address bNftImpl) external returns (address bNftProxy);


  function upgradeBNFTWithImpl(
    address nftAsset,
    address bNftImpl,
    bytes memory encodedCallData
  ) external;


  function addCustomeSymbols(address[] memory nftAssets_, string[] memory symbols_) external;

}// agpl-3.0
pragma solidity 0.8.4;

interface ILendPoolConfigurator {

  struct InitReserveInput {
    address bTokenImpl;
    address debtTokenImpl;
    uint8 underlyingAssetDecimals;
    address interestRateAddress;
    address underlyingAsset;
    address treasury;
    string underlyingAssetName;
    string bTokenName;
    string bTokenSymbol;
    string debtTokenName;
    string debtTokenSymbol;
  }

  struct InitNftInput {
    address underlyingAsset;
  }

  struct UpdateBTokenInput {
    address asset;
    address implementation;
    bytes encodedCallData;
  }

  struct UpdateDebtTokenInput {
    address asset;
    address implementation;
    bytes encodedCallData;
  }

  event ReserveInitialized(
    address indexed asset,
    address indexed bToken,
    address debtToken,
    address interestRateAddress
  );

  event BorrowingEnabledOnReserve(address indexed asset);

  event BorrowingDisabledOnReserve(address indexed asset);

  event ReserveActivated(address indexed asset);

  event ReserveDeactivated(address indexed asset);

  event ReserveFrozen(address indexed asset);

  event ReserveUnfrozen(address indexed asset);

  event ReserveFactorChanged(address indexed asset, uint256 factor);

  event ReserveDecimalsChanged(address indexed asset, uint256 decimals);

  event ReserveInterestRateChanged(address indexed asset, address strategy);

  event NftInitialized(address indexed asset, address indexed bNft);

  event NftConfigurationChanged(
    address indexed asset,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus
  );

  event NftActivated(address indexed asset);

  event NftDeactivated(address indexed asset);

  event NftFrozen(address indexed asset);

  event NftUnfrozen(address indexed asset);

  event NftAuctionChanged(address indexed asset, uint256 redeemDuration, uint256 auctionDuration, uint256 redeemFine);

  event NftRedeemThresholdChanged(address indexed asset, uint256 redeemThreshold);

  event BTokenUpgraded(address indexed asset, address indexed proxy, address indexed implementation);

  event DebtTokenUpgraded(address indexed asset, address indexed proxy, address indexed implementation);
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


  function repay(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external returns (uint256, bool);


  function auction(
    address nftAsset,
    uint256 nftTokenId,
    uint256 bidPrice,
    address onBehalfOf
  ) external;


  function redeem(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
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
}// agpl-3.0
pragma solidity 0.8.4;


library ReserveConfiguration {

  uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
  uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
  uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
  uint256 constant DECIMALS_MASK =              0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF; // prettier-ignore
  uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant BORROWING_MASK =             0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant STABLE_BORROWING_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant RESERVE_FACTOR_MASK =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF; // prettier-ignore

  uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
  uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
  uint256 constant RESERVE_DECIMALS_START_BIT_POSITION = 48;
  uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
  uint256 constant IS_FROZEN_START_BIT_POSITION = 57;
  uint256 constant BORROWING_ENABLED_START_BIT_POSITION = 58;
  uint256 constant STABLE_BORROWING_ENABLED_START_BIT_POSITION = 59;
  uint256 constant RESERVE_FACTOR_START_BIT_POSITION = 64;

  uint256 constant MAX_VALID_LTV = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_BONUS = 65535;
  uint256 constant MAX_VALID_DECIMALS = 255;
  uint256 constant MAX_VALID_RESERVE_FACTOR = 65535;

  function setLtv(DataTypes.ReserveConfigurationMap memory self, uint256 ltv) internal pure {

    require(ltv <= MAX_VALID_LTV, Errors.RC_INVALID_LTV);

    self.data = (self.data & LTV_MASK) | ltv;
  }

  function getLtv(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return self.data & ~LTV_MASK;
  }

  function setLiquidationThreshold(DataTypes.ReserveConfigurationMap memory self, uint256 threshold) internal pure {

    require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, Errors.RC_INVALID_LIQ_THRESHOLD);

    self.data = (self.data & LIQUIDATION_THRESHOLD_MASK) | (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
  }

  function getLiquidationThreshold(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION;
  }

  function setLiquidationBonus(DataTypes.ReserveConfigurationMap memory self, uint256 bonus) internal pure {

    require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.RC_INVALID_LIQ_BONUS);

    self.data = (self.data & LIQUIDATION_BONUS_MASK) | (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
  }

  function getLiquidationBonus(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION;
  }

  function setDecimals(DataTypes.ReserveConfigurationMap memory self, uint256 decimals) internal pure {

    require(decimals <= MAX_VALID_DECIMALS, Errors.RC_INVALID_DECIMALS);

    self.data = (self.data & DECIMALS_MASK) | (decimals << RESERVE_DECIMALS_START_BIT_POSITION);
  }

  function getDecimals(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION;
  }

  function setActive(DataTypes.ReserveConfigurationMap memory self, bool active) internal pure {

    self.data = (self.data & ACTIVE_MASK) | (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
  }

  function getActive(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.ReserveConfigurationMap memory self, bool frozen) internal pure {

    self.data = (self.data & FROZEN_MASK) | (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
  }

  function getFrozen(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function setBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled) internal pure {

    self.data = (self.data & BORROWING_MASK) | (uint256(enabled ? 1 : 0) << BORROWING_ENABLED_START_BIT_POSITION);
  }

  function getBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~BORROWING_MASK) != 0;
  }

  function setStableRateBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled) internal pure {

    self.data =
      (self.data & STABLE_BORROWING_MASK) |
      (uint256(enabled ? 1 : 0) << STABLE_BORROWING_ENABLED_START_BIT_POSITION);
  }

  function getStableRateBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~STABLE_BORROWING_MASK) != 0;
  }

  function setReserveFactor(DataTypes.ReserveConfigurationMap memory self, uint256 reserveFactor) internal pure {

    require(reserveFactor <= MAX_VALID_RESERVE_FACTOR, Errors.RC_INVALID_RESERVE_FACTOR);

    self.data = (self.data & RESERVE_FACTOR_MASK) | (reserveFactor << RESERVE_FACTOR_START_BIT_POSITION);
  }

  function getReserveFactor(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION;
  }

  function getFlags(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (
      bool,
      bool,
      bool,
      bool
    )
  {

    uint256 dataLocal = self.data;

    return (
      (dataLocal & ~ACTIVE_MASK) != 0,
      (dataLocal & ~FROZEN_MASK) != 0,
      (dataLocal & ~BORROWING_MASK) != 0,
      (dataLocal & ~STABLE_BORROWING_MASK) != 0
    );
  }

  function getParams(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    uint256 dataLocal = self.data;

    return (
      dataLocal & ~LTV_MASK,
      (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (dataLocal & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
      (dataLocal & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
      (dataLocal & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
    );
  }

  function getParamsMemory(DataTypes.ReserveConfigurationMap memory self)
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    return (
      self.data & ~LTV_MASK,
      (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
      (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
      (self.data & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
    );
  }

  function getFlagsMemory(DataTypes.ReserveConfigurationMap memory self)
    internal
    pure
    returns (
      bool,
      bool,
      bool,
      bool
    )
  {

    return (
      (self.data & ~ACTIVE_MASK) != 0,
      (self.data & ~FROZEN_MASK) != 0,
      (self.data & ~BORROWING_MASK) != 0,
      (self.data & ~STABLE_BORROWING_MASK) != 0
    );
  }
}// agpl-3.0
pragma solidity 0.8.4;


library NftConfiguration {

  uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
  uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
  uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
  uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant REDEEM_DURATION_MASK =       0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant AUCTION_DURATION_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant REDEEM_FINE_MASK =           0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant REDEEM_THRESHOLD_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore

  uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
  uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
  uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
  uint256 constant IS_FROZEN_START_BIT_POSITION = 57;
  uint256 constant REDEEM_DURATION_START_BIT_POSITION = 64;
  uint256 constant AUCTION_DURATION_START_BIT_POSITION = 72;
  uint256 constant REDEEM_FINE_START_BIT_POSITION = 80;
  uint256 constant REDEEM_THRESHOLD_START_BIT_POSITION = 96;

  uint256 constant MAX_VALID_LTV = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_BONUS = 65535;
  uint256 constant MAX_VALID_REDEEM_DURATION = 255;
  uint256 constant MAX_VALID_AUCTION_DURATION = 255;
  uint256 constant MAX_VALID_REDEEM_FINE = 65535;
  uint256 constant MAX_VALID_REDEEM_THRESHOLD = 65535;

  function setLtv(DataTypes.NftConfigurationMap memory self, uint256 ltv) internal pure {

    require(ltv <= MAX_VALID_LTV, Errors.RC_INVALID_LTV);

    self.data = (self.data & LTV_MASK) | ltv;
  }

  function getLtv(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return self.data & ~LTV_MASK;
  }

  function setLiquidationThreshold(DataTypes.NftConfigurationMap memory self, uint256 threshold) internal pure {

    require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, Errors.RC_INVALID_LIQ_THRESHOLD);

    self.data = (self.data & LIQUIDATION_THRESHOLD_MASK) | (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
  }

  function getLiquidationThreshold(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION;
  }

  function setLiquidationBonus(DataTypes.NftConfigurationMap memory self, uint256 bonus) internal pure {

    require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.RC_INVALID_LIQ_BONUS);

    self.data = (self.data & LIQUIDATION_BONUS_MASK) | (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
  }

  function getLiquidationBonus(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION;
  }

  function setActive(DataTypes.NftConfigurationMap memory self, bool active) internal pure {

    self.data = (self.data & ACTIVE_MASK) | (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
  }

  function getActive(DataTypes.NftConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.NftConfigurationMap memory self, bool frozen) internal pure {

    self.data = (self.data & FROZEN_MASK) | (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
  }

  function getFrozen(DataTypes.NftConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function setRedeemDuration(DataTypes.NftConfigurationMap memory self, uint256 redeemDuration) internal pure {

    require(redeemDuration <= MAX_VALID_REDEEM_DURATION, Errors.RC_INVALID_REDEEM_DURATION);

    self.data = (self.data & REDEEM_DURATION_MASK) | (redeemDuration << REDEEM_DURATION_START_BIT_POSITION);
  }

  function getRedeemDuration(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~REDEEM_DURATION_MASK) >> REDEEM_DURATION_START_BIT_POSITION;
  }

  function setAuctionDuration(DataTypes.NftConfigurationMap memory self, uint256 auctionDuration) internal pure {

    require(auctionDuration <= MAX_VALID_AUCTION_DURATION, Errors.RC_INVALID_AUCTION_DURATION);

    self.data = (self.data & AUCTION_DURATION_MASK) | (auctionDuration << AUCTION_DURATION_START_BIT_POSITION);
  }

  function getAuctionDuration(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~AUCTION_DURATION_MASK) >> AUCTION_DURATION_START_BIT_POSITION;
  }

  function setRedeemFine(DataTypes.NftConfigurationMap memory self, uint256 redeemFine) internal pure {

    require(redeemFine <= MAX_VALID_REDEEM_FINE, Errors.RC_INVALID_REDEEM_FINE);

    self.data = (self.data & REDEEM_FINE_MASK) | (redeemFine << REDEEM_FINE_START_BIT_POSITION);
  }

  function getRedeemFine(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~REDEEM_FINE_MASK) >> REDEEM_FINE_START_BIT_POSITION;
  }

  function setRedeemThreshold(DataTypes.NftConfigurationMap memory self, uint256 redeemThreshold) internal pure {

    require(redeemThreshold <= MAX_VALID_REDEEM_THRESHOLD, Errors.RC_INVALID_REDEEM_THRESHOLD);

    self.data = (self.data & REDEEM_THRESHOLD_MASK) | (redeemThreshold << REDEEM_THRESHOLD_START_BIT_POSITION);
  }

  function getRedeemThreshold(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~REDEEM_THRESHOLD_MASK) >> REDEEM_THRESHOLD_START_BIT_POSITION;
  }

  function getFlags(DataTypes.NftConfigurationMap storage self) internal view returns (bool, bool) {

    uint256 dataLocal = self.data;

    return ((dataLocal & ~ACTIVE_MASK) != 0, (dataLocal & ~FROZEN_MASK) != 0);
  }

  function getFlagsMemory(DataTypes.NftConfigurationMap memory self) internal pure returns (bool, bool) {

    return ((self.data & ~ACTIVE_MASK) != 0, (self.data & ~FROZEN_MASK) != 0);
  }

  function getCollateralParams(DataTypes.NftConfigurationMap storage self)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    uint256 dataLocal = self.data;

    return (
      dataLocal & ~LTV_MASK,
      (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (dataLocal & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION
    );
  }

  function getAuctionParams(DataTypes.NftConfigurationMap storage self)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    uint256 dataLocal = self.data;

    return (
      (dataLocal & ~REDEEM_DURATION_MASK) >> REDEEM_DURATION_START_BIT_POSITION,
      (dataLocal & ~AUCTION_DURATION_MASK) >> AUCTION_DURATION_START_BIT_POSITION,
      (dataLocal & ~REDEEM_FINE_MASK) >> REDEEM_FINE_START_BIT_POSITION,
      (dataLocal & ~REDEEM_THRESHOLD_MASK) >> REDEEM_THRESHOLD_START_BIT_POSITION
    );
  }

  function getCollateralParamsMemory(DataTypes.NftConfigurationMap memory self)
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    return (
      self.data & ~LTV_MASK,
      (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION
    );
  }

  function getAuctionParamsMemory(DataTypes.NftConfigurationMap memory self)
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    return (
      (self.data & ~REDEEM_DURATION_MASK) >> REDEEM_DURATION_START_BIT_POSITION,
      (self.data & ~AUCTION_DURATION_MASK) >> AUCTION_DURATION_START_BIT_POSITION,
      (self.data & ~REDEEM_FINE_MASK) >> REDEEM_FINE_START_BIT_POSITION,
      (self.data & ~REDEEM_THRESHOLD_MASK) >> REDEEM_THRESHOLD_START_BIT_POSITION
    );
  }
}// agpl-3.0
pragma solidity 0.8.4;



library PercentageMath {

  uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
  uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;
  uint256 constant ONE_PERCENT = 1e2; //100, 1%
  uint256 constant TEN_PERCENT = 1e3; //1000, 10%
  uint256 constant ONE_THOUSANDTH_PERCENT = 1e1; //10, 0.1%
  uint256 constant ONE_TEN_THOUSANDTH_PERCENT = 1; //1, 0.01%

  function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256) {

    if (value == 0 || percentage == 0) {
      return 0;
    }

    require(value <= (type(uint256).max - HALF_PERCENT) / percentage, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
  }

  function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256) {

    require(percentage != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfPercentage = percentage / 2;

    require(value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
  }
}// MIT

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
}// agpl-3.0
pragma solidity 0.8.4;




contract LendPoolConfigurator is Initializable, ILendPoolConfigurator {

  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using NftConfiguration for DataTypes.NftConfigurationMap;

  ILendPoolAddressesProvider internal _addressesProvider;

  modifier onlyPoolAdmin() {

    require(_addressesProvider.getPoolAdmin() == msg.sender, Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  modifier onlyEmergencyAdmin() {

    require(_addressesProvider.getEmergencyAdmin() == msg.sender, Errors.LPC_CALLER_NOT_EMERGENCY_ADMIN);
    _;
  }

  function initialize(ILendPoolAddressesProvider provider) public initializer {

    _addressesProvider = provider;
  }

  function batchInitReserve(InitReserveInput[] calldata input) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    for (uint256 i = 0; i < input.length; i++) {
      _initReserve(cachedPool, input[i]);
    }
  }

  function _initReserve(ILendPool pool_, InitReserveInput calldata input) internal {

    address bTokenProxyAddress = _initTokenWithProxy(
      input.bTokenImpl,
      abi.encodeWithSelector(
        IBToken.initialize.selector,
        _addressesProvider,
        input.treasury,
        input.underlyingAsset,
        input.underlyingAssetDecimals,
        input.bTokenName,
        input.bTokenSymbol
      )
    );

    address debtTokenProxyAddress = _initTokenWithProxy(
      input.debtTokenImpl,
      abi.encodeWithSelector(
        IDebtToken.initialize.selector,
        _addressesProvider,
        input.underlyingAsset,
        input.underlyingAssetDecimals,
        input.debtTokenName,
        input.debtTokenSymbol
      )
    );

    pool_.initReserve(input.underlyingAsset, bTokenProxyAddress, debtTokenProxyAddress, input.interestRateAddress);

    DataTypes.ReserveConfigurationMap memory currentConfig = pool_.getReserveConfiguration(input.underlyingAsset);

    currentConfig.setDecimals(input.underlyingAssetDecimals);

    currentConfig.setActive(true);
    currentConfig.setFrozen(false);

    pool_.setReserveConfiguration(input.underlyingAsset, currentConfig.data);

    emit ReserveInitialized(
      input.underlyingAsset,
      bTokenProxyAddress,
      debtTokenProxyAddress,
      input.interestRateAddress
    );
  }

  function batchInitNft(InitNftInput[] calldata input) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    IBNFTRegistry cachedRegistry = _getBNFTRegistry();

    for (uint256 i = 0; i < input.length; i++) {
      _initNft(cachedPool, cachedRegistry, input[i]);
    }
  }

  function _initNft(
    ILendPool pool_,
    IBNFTRegistry registry_,
    InitNftInput calldata input
  ) internal {

    (address bNftProxy, ) = registry_.getBNFTAddresses(input.underlyingAsset);
    require(bNftProxy != address(0), Errors.LPC_INVALIED_BNFT_ADDRESS);

    pool_.initNft(input.underlyingAsset, bNftProxy);

    DataTypes.NftConfigurationMap memory currentConfig = pool_.getNftConfiguration(input.underlyingAsset);

    currentConfig.setActive(true);
    currentConfig.setFrozen(false);

    pool_.setNftConfiguration(input.underlyingAsset, currentConfig.data);

    emit NftInitialized(input.underlyingAsset, bNftProxy);
  }

  function updateBToken(UpdateBTokenInput calldata input) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();

    DataTypes.ReserveData memory reserveData = cachedPool.getReserveData(input.asset);

    _upgradeTokenImplementation(reserveData.bTokenAddress, input.implementation, input.encodedCallData);

    emit BTokenUpgraded(input.asset, reserveData.bTokenAddress, input.implementation);
  }

  function updateDebtToken(UpdateDebtTokenInput calldata input) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();

    DataTypes.ReserveData memory reserveData = cachedPool.getReserveData(input.asset);

    _upgradeTokenImplementation(reserveData.debtTokenAddress, input.implementation, input.encodedCallData);

    emit DebtTokenUpgraded(input.asset, reserveData.debtTokenAddress, input.implementation);
  }

  function enableBorrowingOnReserve(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setBorrowingEnabled(true);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);

    emit BorrowingEnabledOnReserve(asset);
  }

  function disableBorrowingOnReserve(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setBorrowingEnabled(false);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);
    emit BorrowingDisabledOnReserve(asset);
  }

  function activateReserve(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setActive(true);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);

    emit ReserveActivated(asset);
  }

  function deactivateReserve(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    _checkReserveNoLiquidity(asset);

    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setActive(false);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);

    emit ReserveDeactivated(asset);
  }

  function freezeReserve(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setFrozen(true);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);

    emit ReserveFrozen(asset);
  }

  function unfreezeReserve(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setFrozen(false);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);

    emit ReserveUnfrozen(asset);
  }

  function setReserveFactor(address asset, uint256 reserveFactor) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.ReserveConfigurationMap memory currentConfig = cachedPool.getReserveConfiguration(asset);

    currentConfig.setReserveFactor(reserveFactor);

    cachedPool.setReserveConfiguration(asset, currentConfig.data);

    emit ReserveFactorChanged(asset, reserveFactor);
  }

  function setReserveInterestRateAddress(address asset, address rateAddress) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    cachedPool.setReserveInterestRateAddress(asset, rateAddress);
    emit ReserveInterestRateChanged(asset, rateAddress);
  }

  function configureNftAsCollateral(
    address asset,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus
  ) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    require(ltv <= liquidationThreshold, Errors.LPC_INVALID_CONFIGURATION);

    if (liquidationThreshold != 0) {
      require(liquidationBonus < PercentageMath.PERCENTAGE_FACTOR, Errors.LPC_INVALID_CONFIGURATION);
    } else {
      require(liquidationBonus == 0, Errors.LPC_INVALID_CONFIGURATION);
    }

    currentConfig.setLtv(ltv);
    currentConfig.setLiquidationThreshold(liquidationThreshold);
    currentConfig.setLiquidationBonus(liquidationBonus);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftConfigurationChanged(asset, ltv, liquidationThreshold, liquidationBonus);
  }

  function activateNft(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    currentConfig.setActive(true);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftActivated(asset);
  }

  function deactivateNft(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    _checkNftNoLiquidity(asset);

    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    currentConfig.setActive(false);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftDeactivated(asset);
  }

  function freezeNft(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    currentConfig.setFrozen(true);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftFrozen(asset);
  }

  function unfreezeNft(address asset) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    currentConfig.setFrozen(false);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftUnfrozen(asset);
  }

  function configureNftAsAuction(
    address asset,
    uint256 redeemDuration,
    uint256 auctionDuration,
    uint256 redeemFine
  ) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    require(redeemDuration <= auctionDuration, Errors.LPC_INVALID_CONFIGURATION);

    currentConfig.setRedeemDuration(redeemDuration);
    currentConfig.setAuctionDuration(auctionDuration);
    currentConfig.setRedeemFine(redeemFine);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftAuctionChanged(asset, redeemDuration, auctionDuration, redeemFine);
  }

  function setNftRedeemThreshold(address asset, uint256 redeemThreshold) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    DataTypes.NftConfigurationMap memory currentConfig = cachedPool.getNftConfiguration(asset);

    currentConfig.setRedeemThreshold(redeemThreshold);

    cachedPool.setNftConfiguration(asset, currentConfig.data);

    emit NftRedeemThresholdChanged(asset, redeemThreshold);
  }

  function setMaxNumberOfReserves(uint256 newVal) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    uint256 curVal = cachedPool.getMaxNumberOfReserves();
    require(newVal > curVal, Errors.LPC_INVALID_CONFIGURATION);
    cachedPool.setMaxNumberOfReserves(newVal);
  }

  function setMaxNumberOfNfts(uint256 newVal) external onlyPoolAdmin {

    ILendPool cachedPool = _getLendPool();
    uint256 curVal = cachedPool.getMaxNumberOfNfts();
    require(newVal > curVal, Errors.LPC_INVALID_CONFIGURATION);
    cachedPool.setMaxNumberOfNfts(newVal);
  }

  function setPoolPause(bool val) external onlyEmergencyAdmin {

    ILendPool cachedPool = _getLendPool();
    cachedPool.setPause(val);
  }

  function getTokenImplementation(address proxyAddress) external view onlyPoolAdmin returns (address) {

    BendUpgradeableProxy proxy = BendUpgradeableProxy(payable(proxyAddress));
    return proxy.getImplementation();
  }

  function _initTokenWithProxy(address implementation, bytes memory initParams) internal returns (address) {

    BendUpgradeableProxy proxy = new BendUpgradeableProxy(implementation, address(this), initParams);

    return address(proxy);
  }

  function _upgradeTokenImplementation(
    address proxyAddress,
    address implementation,
    bytes memory encodedCallData
  ) internal {

    BendUpgradeableProxy proxy = BendUpgradeableProxy(payable(proxyAddress));

    if (encodedCallData.length > 0) {
      proxy.upgradeToAndCall(implementation, encodedCallData);
    } else {
      proxy.upgradeTo(implementation);
    }
  }

  function _checkReserveNoLiquidity(address asset) internal view {

    DataTypes.ReserveData memory reserveData = _getLendPool().getReserveData(asset);

    uint256 availableLiquidity = IERC20Upgradeable(asset).balanceOf(reserveData.bTokenAddress);

    require(availableLiquidity == 0 && reserveData.currentLiquidityRate == 0, Errors.LPC_RESERVE_LIQUIDITY_NOT_0);
  }

  function _checkNftNoLiquidity(address asset) internal view {

    uint256 collateralAmount = _getLendPoolLoan().getNftCollateralAmount(asset);

    require(collateralAmount == 0, Errors.LPC_NFT_LIQUIDITY_NOT_0);
  }

  function _getLendPool() internal view returns (ILendPool) {

    return ILendPool(_addressesProvider.getLendPool());
  }

  function _getLendPoolLoan() internal view returns (ILendPoolLoan) {

    return ILendPoolLoan(_addressesProvider.getLendPoolLoan());
  }

  function _getIncentivesController() internal view returns (IIncentivesController) {

    return IIncentivesController(_addressesProvider.getIncentivesController());
  }

  function _getBNFTRegistry() internal view returns (IBNFTRegistry) {

    return IBNFTRegistry(_addressesProvider.getBNFTRegistry());
  }
}