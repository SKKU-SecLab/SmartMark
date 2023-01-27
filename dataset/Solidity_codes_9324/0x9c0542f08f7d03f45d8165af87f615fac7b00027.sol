
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
pragma solidity 0.8.13;

interface IPriceModule
{

    function getUSDPrice(address ) external view returns(uint256);

}// MIT
pragma solidity 0.8.13;

interface IHexUtils {

    function fromHex(bytes calldata) external pure returns (bytes memory);


    function toDecimals(address, uint256) external view returns (uint256);


    function fromDecimals(address, uint256) external view returns (uint256);

}// MIT
pragma solidity 0.8.13;

contract APContract is Initializable {

    address public yieldsterDAO;

    address public yieldsterTreasury;

    address public yieldsterGOD;

    address public emergencyVault;

    address public yieldsterExchange;

    address public stringUtils;

    address public whitelistModule;

    address public proxyFactory;

    address public priceModule;

    address public safeMinter;

    address public safeUtils;

    address public exchangeRegistry;

    address public stockDeposit;

    address public stockWithdraw;

    address public platFormManagementFee;

    address public profitManagementFee;

    address public wEth;

    address public sdkContract;

    address public mStorage; //SET

    struct Vault {
        mapping(address => bool) vaultAssets;
        mapping(address => bool) vaultDepositAssets;
        mapping(address => bool) vaultWithdrawalAssets;
        address depositStrategy;
        address withdrawStrategy;
        uint256[] whitelistGroup;
        address vaultAdmin;
        bool created;
        uint256 slippage;
    }


    mapping(address => bool) assets;

    mapping(address => Vault) vaults;

    mapping(address => bool) vaultCreated;

    mapping(address => bool) APSManagers;

    mapping(address => uint256) vaultsOwnedByAdmin;

    struct SmartStrategy {
        address minter;
        address executor;
        bool created;
    }

    mapping(address => SmartStrategy) smartStrategies;

    mapping(address => address) minterStrategyMap;

    struct vaultActiveManagemetFee {
        mapping(address => bool) isActiveManagementFee;
        mapping(address => uint256) activeManagementFeeIndex;
        address[] activeManagementFeeList;
    }

    mapping(address => vaultActiveManagemetFee) managementFeeStrategies;

    mapping(address => bool) permittedWalletAddresses;

    function initialize(
        address _yieldsterDAO,
        address _yieldsterTreasury,
        address _yieldsterGOD,
        address _emergencyVault,
        address _apsAdmin
    ) public initializer {

        yieldsterDAO = _yieldsterDAO;
        yieldsterTreasury = _yieldsterTreasury;
        yieldsterGOD = _yieldsterGOD;
        emergencyVault = _emergencyVault;
        APSManagers[_apsAdmin] = true;
    }

    function setInitialValues(
        address _whitelistModule,
        address _platformManagementFee,
        address _profitManagementFee,
        address _stringUtils,
        address _yieldsterExchange,
        address _exchangeRegistry,
        address _priceModule,
        address _safeUtils,
        address _mStorage
    ) public onlyYieldsterDAO {

        whitelistModule = _whitelistModule;
        platFormManagementFee = _platformManagementFee;
        stringUtils = _stringUtils;
        yieldsterExchange = _yieldsterExchange;
        exchangeRegistry = _exchangeRegistry;
        priceModule = _priceModule;
        safeUtils = _safeUtils;
        profitManagementFee = _profitManagementFee;
        mStorage = _mStorage;
    }

    function addProxyFactory(address _proxyFactory) public onlyManager {

        proxyFactory = _proxyFactory;
    }

    function addManager(address _manager) public onlyYieldsterDAO {

        APSManagers[_manager] = true;
    }

    function removeManager(address _manager) public onlyYieldsterDAO {

        APSManagers[_manager] = false;
    }

    function setYieldsterGOD(address _yieldsterGOD) public {

        require(
            msg.sender == yieldsterGOD,
            "Only Yieldster GOD can perform this operation"
        );
        yieldsterGOD = _yieldsterGOD;
    }

    function setYieldsterDAO(address _yieldsterDAO) public {

        require(
            msg.sender == yieldsterDAO,
            "Only Yieldster DAO can perform this operation"
        );
        yieldsterDAO = _yieldsterDAO;
    }

    function setYieldsterTreasury(address _yieldsterTreasury) public {

        require(
            msg.sender == yieldsterDAO,
            "Only Yieldster DAO can perform this operation"
        );
        yieldsterTreasury = _yieldsterTreasury;
    }

    function disableYieldsterGOD() public {

        require(
            msg.sender == yieldsterGOD,
            "Only Yieldster GOD can perform this operation"
        );
        yieldsterGOD = address(0);
    }

    function setEmergencyVault(address _emergencyVault)
        public
        onlyYieldsterDAO
    {

        emergencyVault = _emergencyVault;
    }

    function setSafeMinter(address _safeMinter) public onlyYieldsterDAO {

        safeMinter = _safeMinter;
    }

    function setSafeUtils(address _safeUtils) public onlyYieldsterDAO {

        safeUtils = _safeUtils;
    }

    function setStringUtils(address _stringUtils) public onlyYieldsterDAO {

        stringUtils = _stringUtils;
    }

    function setWhitelistModule(address _whitelistModule)
        public
        onlyYieldsterDAO
    {

        whitelistModule = _whitelistModule;
    }

    function setExchangeRegistry(address _exchangeRegistry)
        public
        onlyYieldsterDAO
    {

        exchangeRegistry = _exchangeRegistry;
    }

    function setYieldsterExchange(address _yieldsterExchange)
        public
        onlyYieldsterDAO
    {

        yieldsterExchange = _yieldsterExchange;
    }

    function changeVaultAdmin(address _vaultAdmin) external {

        require(vaults[msg.sender].created, "Vault is not present");
        vaultsOwnedByAdmin[vaults[msg.sender].vaultAdmin] =
            vaultsOwnedByAdmin[vaults[msg.sender].vaultAdmin] -
            1;
        vaultsOwnedByAdmin[_vaultAdmin] = vaultsOwnedByAdmin[_vaultAdmin] + 1;
        vaults[msg.sender].vaultAdmin = _vaultAdmin;
    }

    function setVaultSlippage(uint256 _slippage) external {

        require(vaults[msg.sender].created, "Vault is not present");
        vaults[msg.sender].slippage = _slippage;
    }

    function getVaultSlippage() external view returns (uint256) {

        require(vaults[msg.sender].created, "Vault is not present");
        return vaults[msg.sender].slippage;
    }

    function setPriceModule(address _priceModule) public onlyManager {

        priceModule = _priceModule;
    }

    function getUSDPrice(address _tokenAddress) public view returns (uint256) {

        return IPriceModule(priceModule).getUSDPrice(_tokenAddress);
    }

    function setProfitAndPlatformManagementFeeStrategies(
        address _platformManagement,
        address _profitManagement
    ) public onlyYieldsterDAO {

        if (_profitManagement != address(0))
            profitManagementFee = _profitManagement;
        if (_platformManagement != address(0))
            platFormManagementFee = _platformManagement;
    }

    function getVaultManagementFee() public view returns (address[] memory) {

        require(vaults[msg.sender].created, "Vault not present");
        return managementFeeStrategies[msg.sender].activeManagementFeeList;
    }

    function addManagementFeeStrategies(
        address _vaultAddress,
        address _managementFeeAddress
    ) public {

        require(vaults[_vaultAddress].created, "Vault not present");
        require(
            vaults[_vaultAddress].vaultAdmin == msg.sender,
            "Sender not Authorized"
        );
        managementFeeStrategies[_vaultAddress].isActiveManagementFee[
            _managementFeeAddress
        ] = true;
        managementFeeStrategies[_vaultAddress].activeManagementFeeIndex[
                _managementFeeAddress
            ] = managementFeeStrategies[_vaultAddress]
            .activeManagementFeeList
            .length;
        managementFeeStrategies[_vaultAddress].activeManagementFeeList.push(
            _managementFeeAddress
        );
    }

    function removeManagementFeeStrategies(
        address _vaultAddress,
        address _managementFeeAddress
    ) public {

        require(vaults[_vaultAddress].created, "Vault not present");
        require(
            managementFeeStrategies[_vaultAddress].isActiveManagementFee[
                _managementFeeAddress
            ],
            "Provided ManagementFee is not active"
        );
        require(
            vaults[_vaultAddress].vaultAdmin == msg.sender ||
                yieldsterDAO == msg.sender,
            "Sender not Authorized"
        );
        require(
            platFormManagementFee != _managementFeeAddress ||
                yieldsterDAO == msg.sender,
            "Platfrom Management only changable by dao!"
        );
        managementFeeStrategies[_vaultAddress].isActiveManagementFee[
            _managementFeeAddress
        ] = false;

        if (
            managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList
                .length == 1
        ) {
            managementFeeStrategies[_vaultAddress].activeManagementFeeList.pop();
        } else {
            uint256 index = managementFeeStrategies[_vaultAddress]
                .activeManagementFeeIndex[_managementFeeAddress];
            uint256 lastIndex = managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList
                .length - 1;
            delete managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList[index];
            managementFeeStrategies[_vaultAddress].activeManagementFeeIndex[
                    managementFeeStrategies[_vaultAddress]
                        .activeManagementFeeList[lastIndex]
                ] = index;
            managementFeeStrategies[_vaultAddress].activeManagementFeeList[
                    index
                ] = managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList[lastIndex];
            managementFeeStrategies[_vaultAddress].activeManagementFeeList.pop();
        }
    }

    function setVaultStatus(address _vaultAddress) public {

        require(
            msg.sender == proxyFactory,
            "Only Proxy Factory can perform this operation"
        );
        vaultCreated[_vaultAddress] = true;
    }

    function addVault(address _vaultAdmin, uint256[] memory _whitelistGroup)
        public
    {

        require(vaultCreated[msg.sender], "Vault not created");
        Vault storage newVault = vaults[msg.sender];
        newVault.vaultAdmin = _vaultAdmin;
        newVault.depositStrategy = stockDeposit;
        newVault.withdrawStrategy = stockWithdraw;
        newVault.whitelistGroup = _whitelistGroup;
        newVault.created = true;
        newVault.slippage = 50;
        vaultsOwnedByAdmin[_vaultAdmin] = vaultsOwnedByAdmin[_vaultAdmin] + 1;

        managementFeeStrategies[msg.sender].isActiveManagementFee[
            platFormManagementFee
        ] = true;
        managementFeeStrategies[msg.sender].activeManagementFeeIndex[
                platFormManagementFee
            ] = managementFeeStrategies[msg.sender]
            .activeManagementFeeList
            .length;
        managementFeeStrategies[msg.sender].activeManagementFeeList.push(
            platFormManagementFee
        );

        managementFeeStrategies[msg.sender].isActiveManagementFee[
            profitManagementFee
        ] = true;
        managementFeeStrategies[msg.sender].activeManagementFeeIndex[
                profitManagementFee
            ] = managementFeeStrategies[msg.sender]
            .activeManagementFeeList
            .length;
        managementFeeStrategies[msg.sender].activeManagementFeeList.push(
            profitManagementFee
        );
    }

    function setVaultAssets(
        address[] memory _enabledDepositAsset,
        address[] memory _enabledWithdrawalAsset,
        address[] memory _disabledDepositAsset,
        address[] memory _disabledWithdrawalAsset
    ) public {

        require(vaults[msg.sender].created, "Vault not present");

        for (uint256 i = 0; i < _enabledDepositAsset.length; i++) {
            address asset = _enabledDepositAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = true;
            vaults[msg.sender].vaultDepositAssets[asset] = true;
        }

        for (uint256 i = 0; i < _enabledWithdrawalAsset.length; i++) {
            address asset = _enabledWithdrawalAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = true;
            vaults[msg.sender].vaultWithdrawalAssets[asset] = true;
        }

        for (uint256 i = 0; i < _disabledDepositAsset.length; i++) {
            address asset = _disabledDepositAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = false;
            vaults[msg.sender].vaultDepositAssets[asset] = false;
        }

        for (uint256 i = 0; i < _disabledWithdrawalAsset.length; i++) {
            address asset = _disabledWithdrawalAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = false;
            vaults[msg.sender].vaultWithdrawalAssets[asset] = false;
        }
    }

    function _isVaultAsset(address cleanUpAsset) public view returns (bool) {

        require(vaults[msg.sender].created, "Vault is not present");
        return vaults[msg.sender].vaultAssets[cleanUpAsset];
    }

    function _isAssetPresent(address _address) private view returns (bool) {

        return assets[_address];
    }

    function addAsset(address _tokenAddress) public onlyManager {

        require(!_isAssetPresent(_tokenAddress), "Asset already present!");
        assets[_tokenAddress] = true;
    }

    function removeAsset(address _tokenAddress) public onlyManager {

        require(_isAssetPresent(_tokenAddress), "Asset not present!");
        delete assets[_tokenAddress];
    }

    function isDepositAsset(address _assetAddress) public view returns (bool) {

        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].vaultDepositAssets[_assetAddress];
    }

    function isWithdrawalAsset(address _assetAddress)
        public
        view
        returns (bool)
    {

        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].vaultWithdrawalAssets[_assetAddress];
    }

    function setStockDepositWithdraw(
        address _stockDeposit,
        address _stockWithdraw
    ) public onlyYieldsterDAO {

        stockDeposit = _stockDeposit;
        stockWithdraw = _stockWithdraw;
    }

    function setVaultSmartStrategy(address _smartStrategyAddress, uint256 _type)
        external
    {

        require(vaults[msg.sender].created, "Vault not present");
        require(
            _isSmartStrategyPresent(_smartStrategyAddress),
            "Smart Strategy not Supported by Yieldster"
        );
        if (_type == 1) {
            vaults[msg.sender].depositStrategy = _smartStrategyAddress;
        } else if (_type == 2) {
            vaults[msg.sender].withdrawStrategy = _smartStrategyAddress;
        } else {
            revert("Invalid type provided");
        }
    }

    function _isSmartStrategyPresent(address _address)
        private
        view
        returns (bool)
    {

        return smartStrategies[_address].created;
    }

    function addSmartStrategy(
        address _smartStrategyAddress,
        address _minter,
        address _executor
    ) public onlyManager {

        require(
            !_isSmartStrategyPresent(_smartStrategyAddress),
            "Smart Strategy already present!"
        );
        SmartStrategy storage newSmartStrategy = smartStrategies[
            _smartStrategyAddress
        ];
        newSmartStrategy.minter = _minter;
        newSmartStrategy.executor = _executor;
        newSmartStrategy.created = true;

        minterStrategyMap[_minter] = _smartStrategyAddress;
    }

    function removeSmartStrategy(address _smartStrategyAddress)
        public
        onlyManager
    {

        require(
            !_isSmartStrategyPresent(_smartStrategyAddress),
            "Smart Strategy not present"
        );
        delete smartStrategies[_smartStrategyAddress];
    }

    function smartStrategyExecutor(address _smartStrategy)
        external
        view
        returns (address)
    {

        return smartStrategies[_smartStrategy].executor;
    }

    function changeSmartStrategyExecutor(
        address _smartStrategy,
        address _executor
    ) public onlyManager {

        require(
            _isSmartStrategyPresent(_smartStrategy),
            "Smart Strategy not present!"
        );
        smartStrategies[_smartStrategy].executor = _executor;
    }

    function getDepositStrategy() public view returns (address) {

        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].depositStrategy;
    }

    function getWithdrawStrategy() public view returns (address) {

        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].withdrawStrategy;
    }

    function getStrategyFromMinter(address _minter)
        external
        view
        returns (address)
    {

        return minterStrategyMap[_minter];
    }

    modifier onlyYieldsterDAO() {

        require(
            yieldsterDAO == msg.sender,
            "Only Yieldster DAO is allowed to perform this operation"
        );
        _;
    }

    modifier onlyManager() {

        require(
            APSManagers[msg.sender],
            "Only APS managers allowed to perform this operation!"
        );
        _;
    }

    function isVault(address _address) public view returns (bool) {

        return vaults[_address].created;
    }

    function getWETH() external view returns (address) {

        return wEth;
    }

    function setWETH(address _wEth) external onlyYieldsterDAO {

        wEth = _wEth;
    }

    function calculateSlippage(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 slippagePercent
    ) public view returns (uint256) {

        uint256 fromTokenUSD = getUSDPrice(fromToken);
        uint256 toTokenUSD = getUSDPrice(toToken);
        uint256 fromTokenAmountDecimals = IHexUtils(stringUtils).toDecimals(
            fromToken,
            amount
        );

        uint256 expectedToTokenDecimal = (fromTokenAmountDecimals *
            fromTokenUSD) / toTokenUSD;

        uint256 expectedToToken = IHexUtils(stringUtils).fromDecimals(
            toToken,
            expectedToTokenDecimal
        );

        uint256 minReturn = expectedToToken -
            ((expectedToToken * slippagePercent) / (10000));
        return minReturn;
    }

    function vaultsCount(address _vaultAdmin) public view returns (uint256) {

        return vaultsOwnedByAdmin[_vaultAdmin];
    }

    function getPlatformFeeStorage() public view returns (address) {

        return mStorage;
    }

    function setManagementFeeStorage(address _mStorage)
        external
        onlyYieldsterDAO
    {

        mStorage = _mStorage;
    }

    function setSDKContract(address _sdkContract) external onlyYieldsterDAO {

        sdkContract = _sdkContract;
    }

    function setWalletAddress(
        address[] memory _walletAddresses,
        bool[] memory _permission
    ) external onlyYieldsterDAO {

        for (uint256 i = 0; i < _walletAddresses.length; i++) {
            if (_walletAddresses[i] != address(0))
                if (
                    permittedWalletAddresses[_walletAddresses[i]] !=
                    _permission[i]
                )
                    permittedWalletAddresses[_walletAddresses[i]] = _permission[
                        i
                    ];
        }
    }


    function checkWalletAddress(address _walletAddress)
        public
        view
        returns (bool)
    {

        return permittedWalletAddresses[_walletAddress];
    }
}