
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}// MIT

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
}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT
pragma solidity 0.8.4;

interface IFlashLoanReceiver {

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool);

}// MIT
pragma solidity 0.8.4;

interface ILendingPoolAddressesProvider {

  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);


  function setMarketId(string calldata marketId) external;


  function setAddress(bytes32 id, address newAddress) external;


  function setAddressAsProxy(bytes32 id, address impl) external;


  function getAddress(bytes32 id) external view returns (address);


  function getLendingPool() external view returns (address);


  function setLendingPoolImpl(address pool) external;


  function getLendingPoolConfigurator() external view returns (address);


  function setLendingPoolConfiguratorImpl(address configurator) external;


  function getLendingPoolCollateralManager() external view returns (address);


  function setLendingPoolCollateralManager(address manager) external;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external;


  function getPriceOracle() external view returns (address);


  function setPriceOracle(address priceOracle) external;


  function getLendingRateOracle() external view returns (address);


  function setLendingRateOracle(address lendingRateOracle) external;

}// MIT
pragma solidity 0.8.4;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}// MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;


interface ILendingPool {

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  event Paused();

  event Unpaused();

  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function withdraw(
    address asset,
    uint256 amount,
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
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);


  function swapBorrowRateMode(address asset, uint256 rateMode) external;


  function rebalanceStableBorrowRate(address asset, address user) external;


  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;


  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );


  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;


  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;


  function setConfiguration(address reserve, uint256 configuration) external;


  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);


  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function getReservesList() external view returns (address[] memory);


  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);


  function setPause(bool val) external;


  function paused() external view returns (bool);

}// MIT
pragma solidity 0.8.4;

interface CERC20 {

    function mint(uint256) external returns (uint256);


    function exchangeRateCurrent() external returns (uint256);


    function supplyRatePerBlock() external returns (uint256);


    function redeem(uint) external returns (uint);


    function redeemUnderlying(uint) external returns (uint);


    function borrow(uint256) external returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function borrowBalanceCurrent(address) external returns (uint256);


    function borrowBalanceStored(address) external view returns (uint256);


    function repayBorrow(uint256) external returns (uint256);


    function balanceOf(address) external view returns (uint256);


    function balanceOfUnderlying(address) external returns (uint256);


    function approve(address, uint256) external returns (bool);

}// MIT
pragma solidity 0.8.4;

interface Comptroller {

    function markets(address) external returns (bool, uint256);


    function enterMarkets(address[] calldata) external returns (uint256[] memory);


    function getAccountLiquidity(address) external view returns (uint256, uint256, uint256);

}// MIT
pragma solidity ^0.8.4;

library StorageSlot {

  function getAddressAt(bytes32 slot) internal view returns (address a) {

    assembly {
      a := sload(slot)
    }
  }

  function setAddressAt(bytes32 slot, address address_) internal {

    assembly {
      sstore(slot, address_)
    }
  }
}// MIT
pragma solidity 0.8.4;


contract YieldPrinterStorage is Initializable {


    function initializeStorage(address _comptroller, address _lpAddressesProvider)  public initializer {

        ILendingPoolAddressesProvider addressesProvider = ILendingPoolAddressesProvider(_lpAddressesProvider);
        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        StorageSlot.setAddressAt(keccak256("yieldprinter.comptroller"), _comptroller);
        StorageSlot.setAddressAt(keccak256("yieldprinter.lendingpool"), address(lendingPool));
    }

    function getLendingPool() public view returns (address) {

        return StorageSlot.getAddressAt(keccak256("yieldprinter.lendingpool"));
    }

    function getComptroller() public view returns (address) {

        return StorageSlot.getAddressAt(keccak256("yieldprinter.comptroller"));
    }
}// MIT
pragma solidity 0.8.4;


contract YieldPrinterV1 is IFlashLoanReceiver, YieldPrinterStorage, OwnableUpgradeable {

    using SafeMath for uint256;

    struct LoanData {
        IERC20Upgradeable underlying;
        CERC20 cToken;
        uint256 flashLoanedAmount;
        uint256 flashLoanPremium;
    }

    modifier onlyPool() {

        require(
            msg.sender == address(getLendingPool()),
            "FlashLoan: could be called by lending pool only"
        );
        _;
    }

    function initialize(address lpAddressesProvider, address comptroller) public initializer {

        __Ownable_init();
        YieldPrinterStorage.initializeStorage(comptroller, lpAddressesProvider);
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address,
        bytes calldata params
    )
        external
        onlyPool
        override
        returns (bool)
    {


        (address cErc20Contract, uint256 totalAmount, bytes32 operation) = abi.decode(params, (address, uint256, bytes32));
        LoanData memory loanData;
        loanData.underlying = IERC20Upgradeable(assets[0]);
        loanData.cToken = CERC20(cErc20Contract);
        loanData.flashLoanedAmount = amounts[0];
        loanData.flashLoanPremium = premiums[0];

        if(operation == keccak256("DEPOSIT")) {
            loanData.underlying.approve(cErc20Contract, totalAmount);

            loanData.cToken.mint(totalAmount);

            address[] memory cTokens = new address[](1);
            cTokens[0] = cErc20Contract;
            Comptroller(getComptroller()).enterMarkets(cTokens);

            uint256 borrowAmount = loanData.flashLoanedAmount.add(loanData.flashLoanPremium);
            loanData.cToken.borrow(borrowAmount);
        }

        if(operation == keccak256("WITHDRAW")) {
            loanData.underlying.approve(cErc20Contract, loanData.flashLoanedAmount);

            uint256 error = loanData.cToken.repayBorrow(loanData.flashLoanedAmount);
            require(error == 0, "RepayBorrow Error");

            uint256 cTokenBalance = loanData.cToken.balanceOf(address(this));

            loanData.cToken.redeem(cTokenBalance);
        }
        
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20Upgradeable(assets[i]).approve(getLendingPool(), amountOwing);
        }
        
        return true;
    }

    function depositToComp(address token, address cToken, uint256 amount) external onlyOwner {

        uint256 totalAmount = (amount.mul(5)).div(2);

        uint256 flashLoanAmount = totalAmount.sub(amount);
        bytes memory data = abi.encode(cToken, totalAmount, keccak256("DEPOSIT"));

        takeLoan(token, flashLoanAmount, data);
    }

    function withdrawFromComp(address token, address cToken) external onlyOwner {

        uint256 borrowBalance = CERC20(cToken).borrowBalanceCurrent(address(this));
        require(borrowBalance > 0, "Borrowed balance must be > 0");

        bytes memory data = abi.encode(cToken, 0, keccak256("WITHDRAW"));

        takeLoan(token, borrowBalance, data);
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {

        uint256 balance = IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
        require(IERC20Upgradeable(_tokenAddress).transfer(owner(), balance), "Failed to withdraw token");
    }

    function withdrawAllEth() external onlyOwner {

        uint amount = address(this).balance;

        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function takeLoan(address asset, uint256 amount, bytes memory params) internal {

        address receiverAddress = address(this);
        uint256 noDebt = 0;
        uint16 referralCode = 0;
        address onBehalfOf = address(this);

        address[] memory assets = new address[](1);
        assets[0] = address(asset);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = noDebt;

        ILendingPool(getLendingPool()).flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    receive() external payable {}
}