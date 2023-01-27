
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

contract Ownable {

    address public ownerAddress;

    constructor() {
        ownerAddress = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == ownerAddress, "Ownable: caller is not the owner");
        _;
    }

    function setOwnerAddress(address _ownerAddress) public onlyOwner {

        ownerAddress = _ownerAddress;
    }
}

 interface IYearnAddressesProvider {

    function addressById(string memory) external view returns (address);

}

interface ICyToken {

    function underlying() external view returns (address);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function supplyRatePerBlock() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function reserveFactorMantissa() external view returns (uint256);


    function getCash() external view returns (uint256);


    function getAccountSnapshot(address account) external view returns (uint256, uint256, uint256, uint256);


    function totalBorrows() external view returns (uint256);


    function borrowBalanceStored(address accountAddress)
        external
        view
        returns (uint256);


    function totalReserves() external view returns (uint256);


    function balanceOf(address accountAddress) external view returns (uint256);


    function decimals() external view returns (uint8);


    function totalCollateralTokens() external view returns (uint256);


    function collateralCap() external view returns (uint256);

}

interface IUnitroller {

    struct Market {
        bool isListed;
        uint256 collateralFactorMantissa;
        uint256 version;
    }

    function oracle() external view returns (address);


    function getAssetsIn(address accountAddress)
        external
        view
        returns (address[] memory);


    function markets(address marketAddress)
        external
        view
        returns (Market memory);

}

interface IAddressesGenerator {

    function assetsAddresses() external view returns (address[] memory);


    function assetsLength() external view returns (uint256);


    function registry() external view returns (address);


    function getPositionSpenderAddresses()
        external
        view
        returns (address[] memory);

}

interface IHelper {

    struct Allowance {
        address owner;
        address spender;
        uint256 amount;
        address token;
    }

    function allowances(
        address ownerAddress,
        address[] memory tokensAddresses,
        address[] memory spenderAddresses
    ) external view returns (Allowance[] memory);


    function uniqueAddresses(address[] memory input)
        external
        pure
        returns (address[] memory);

}

interface ICreamOracle {

    function getUnderlyingPrice(address) external view returns (uint256);

}

interface IOracle {

    function getNormalizedValueUsdc(
        address tokenAddress,
        uint256 amount,
        uint256 priceUsdc
    ) external view returns (uint256);

}

interface IERC20 {

    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function approve(address spender, uint256 amount) external;


    function balanceOf(address account) external view returns (uint256);


    function allowance(address spender, address owner)
        external
        view
        returns (uint256);

}

contract RegistryAdapterIronBank is Ownable {

    uint256 public blocksPerYear = 31540000; // Fantom

    address public yearnAddressesProviderAddress; // Yearn addresses provider
    address[] private _extensionsAddresses; // Optional contract extensions provide a way to add new features at a later date

    struct AssetStatic {
        address id; // Asset address
        string typeId; // Asset typeId (for example "VAULT_V2" or "IRON_BANK_MARKET")
        address tokenId; // Underlying token address
        string name; // Asset Name
        string version; // Asset version
        string symbol; // Asset symbol
        uint8 decimals; // Asset decimals
    }

    struct AssetDynamic {
        address id; // Asset address
        string typeId; // Asset typeId (for example "VAULT_V2" or "IRON_BANK_MARKET")
        address tokenId; // Underlying token address;
        TokenAmount underlyingTokenBalance; // Underlying token balances
        AssetMetadata metadata; // Metadata specific to the asset type of this adapter
    }

    struct Position {
        address assetId; // Asset address
        address tokenId; // Underlying asset token address
        string typeId; // Position typeId (for example "DEPOSIT," "BORROW," "LEND")
        uint256 balance; // asset.balanceOf(account)
        TokenAmount underlyingTokenBalance; // Represents a user's asset position in underlying tokens
        Allowance[] tokenAllowances; // Underlying token allowances
        Allowance[] assetAllowances; // Asset allowances
    }

    struct TokenAmount {
        uint256 amount; // Amount in underlying token decimals
        uint256 amountUsdc; // Amount in USDC (6 decimals)
    }

    struct Allowance {
        address owner; // Allowance owner
        address spender; // Allowance spender
        uint256 amount; // Allowance amount (in underlying token)
    }

    struct AdapterInfo {
        address id; // Adapter address
        string typeId; // Adapter typeId (for example "VAULT_V2" or "IRON_BANK_MARKET")
        string categoryId; // Adapter categoryId (for example "VAULT")
    }

    function assetsStatic(address[] memory _assetsAddresses)
        public
        view
        returns (AssetStatic[] memory)
    {

        uint256 numberOfAssets = _assetsAddresses.length;
        AssetStatic[] memory _assets = new AssetStatic[](numberOfAssets);
        for (uint256 assetIdx = 0; assetIdx < numberOfAssets; assetIdx++) {
            address assetAddress = _assetsAddresses[assetIdx];
            AssetStatic memory _asset = assetStatic(assetAddress);
            _assets[assetIdx] = _asset;
        }
        return _assets;
    }

    function assetsDynamic(address[] memory _assetsAddresses)
        public
        view
        returns (AssetDynamic[] memory)
    {

        uint256 numberOfAssets = _assetsAddresses.length;
        AssetDynamic[] memory _assets = new AssetDynamic[](numberOfAssets);
        for (uint256 assetIdx = 0; assetIdx < numberOfAssets; assetIdx++) {
            address assetAddress = _assetsAddresses[assetIdx];
            AssetDynamic memory _asset = assetDynamic(assetAddress);
            _assets[assetIdx] = _asset;
        }
        return _assets;
    }

    function assetsStatic() external view returns (AssetStatic[] memory) {

        address[] memory _assetsAddresses = assetsAddresses();
        return assetsStatic(_assetsAddresses);
    }

    function assetsDynamic() external view returns (AssetDynamic[] memory) {

        address[] memory _assetsAddresses = assetsAddresses();
        return assetsDynamic(_assetsAddresses);
    }

    function tokenAllowances(address accountAddress, address assetAddress)
        public
        view
        returns (Allowance[] memory)
    {

        address tokenAddress = assetUnderlyingTokenAddress(assetAddress);
        address[] memory tokenAddresses = new address[](1);
        address[] memory assetAddresses = new address[](1);
        tokenAddresses[0] = tokenAddress;
        assetAddresses[0] = assetAddress;
        bytes memory allowances =
            abi.encode(
                helper().allowances(
                    accountAddress,
                    tokenAddresses,
                    assetAddresses
                )
            );
        return abi.decode(allowances, (Allowance[]));
    }

    function assetAllowances(address accountAddress, address assetAddress)
        public
        view
        returns (Allowance[] memory)
    {

        address[] memory assetAddresses = new address[](1);
        assetAddresses[0] = assetAddress;
        bytes memory allowances =
            abi.encode(
                helper().allowances(
                    accountAddress,
                    assetAddresses,
                    addressesGenerator().getPositionSpenderAddresses()
                )
            );
        return abi.decode(allowances, (Allowance[]));
    }

    function assetsLength() public view returns (uint256) {

        return addressesGenerator().assetsLength();
    }

    function assetsAddresses() public view returns (address[] memory) {

        return addressesGenerator().assetsAddresses();
    }

    function comptrollerAddress() public view returns (address) {

        return registryAddress();
    }

    function registryAddress() public view returns (address) {

        return addressesGenerator().registry();
    }

    function yearnAddressesProvider() public view returns (IYearnAddressesProvider) {

        return IYearnAddressesProvider(yearnAddressesProviderAddress);
    }
    
    function oracle() public view returns (IOracle) {

        return IOracle(yearnAddressesProvider().addressById("ORACLE"));
    }

    function helper() public view returns (IHelper) {

        return IHelper(yearnAddressesProvider().addressById("HELPER"));
    }

    function addressesGenerator() public view returns (IAddressesGenerator) {

        return IAddressesGenerator(yearnAddressesProvider().addressById("ADDRESSES_GENERATOR_IRON_BANK"));
    }

    function updateSlot(bytes32 slot, bytes32 value) external onlyOwner {

        assembly {
            sstore(slot, value)
        }
    }
    
    function updateYearnAddressesProviderAddress(address _yearnAddressesProviderAddress) external onlyOwner {

        yearnAddressesProviderAddress = _yearnAddressesProviderAddress;
    }

    function setExtensionsAddresses(address[] memory _newExtensionsAddresses)
        external
        onlyOwner
    {

        _extensionsAddresses = _newExtensionsAddresses;
    }

    function extensionsAddresses() external view returns (address[] memory) {

        return (_extensionsAddresses);
    }

    function tokenAmount(
        uint256 amount,
        address tokenAddress,
        uint256 tokenPriceUsdc
    ) internal view returns (TokenAmount memory) {

        return
            TokenAmount({
                amount: amount,
                amountUsdc: oracle().getNormalizedValueUsdc(
                    tokenAddress,
                    amount,
                    tokenPriceUsdc
                )
            });
    }

    constructor(
        address _yearnAddressesProviderAddress
      
    ) {
        yearnAddressesProviderAddress = _yearnAddressesProviderAddress;
    }

    function adapterInfo() public view returns (AdapterInfo memory) {

        return
            AdapterInfo({
                id: address(this),
                typeId: "IRON_BANK_MARKET",
                categoryId: "LENDING"
            });
    }

    string constant positionLend = "LEND";
    string constant positionBorrow = "BORROW";
    string[] public supportedPositions = [positionLend, positionBorrow];

    struct AssetMetadata {
        uint256 totalSuppliedUsdc;
        uint256 totalBorrowedUsdc;
        uint256 lendApyBips;
        uint256 borrowApyBips;
        uint256 liquidity;
        uint256 liquidityUsdc;
        uint256 totalCollateralTokens;
        uint256 collateralFactor;
        uint256 collateralCap;
        bool isActive;
        uint256 reserveFactor;
        uint256 exchangeRate;
    }

    struct AdapterPosition {
        uint256 supplyBalanceUsdc;
        uint256 borrowBalanceUsdc;
        uint256 borrowLimitUsdc;
        uint256 utilizationRatioBips;
    }

    struct AssetUserMetadata {
        address assetId;
        bool enteredMarket;
        uint256 supplyBalanceUsdc;
        uint256 borrowBalanceUsdc;
        uint256 collateralBalanceUsdc;
        uint256 borrowLimitUsdc;
    }

    function assetUserMetadata(address accountAddress, address assetAddress)
        public
        view
        returns (AssetUserMetadata memory)
    {

        bool enteredMarket;
        address[] memory markets =
            IUnitroller(comptrollerAddress()).getAssetsIn(accountAddress);
        for (uint256 marketIdx; marketIdx < markets.length; marketIdx++) {
            address marketAddress = markets[marketIdx];
            if (marketAddress == assetAddress) {
                enteredMarket = true;
                break;
            }
        }
        ICyToken asset = ICyToken(assetAddress);
        IUnitroller.Market memory market =
            IUnitroller(comptrollerAddress()).markets(assetAddress);
        address tokenAddress = assetUnderlyingTokenAddress(assetAddress);
        uint256 tokenPriceUsdc = assetUnderlyingTokenPriceUsdc(assetAddress);
        uint256 supplyBalanceUsdc = userSupplyBalanceUsdc(accountAddress, asset, tokenAddress, tokenPriceUsdc);
        uint256 borrowBalanceUsdc = userBorrowBalanceUsdc(accountAddress, asset, tokenAddress, tokenPriceUsdc);
        uint256 collateralBalanceUsdc = userCollateralBalanceUsdc(accountAddress, asset, tokenAddress, tokenPriceUsdc);
        uint256 borrowLimitUsdc =
            (collateralBalanceUsdc * market.collateralFactorMantissa) / 10**18;

        return
            AssetUserMetadata({
                assetId: assetAddress,
                enteredMarket: enteredMarket,
                supplyBalanceUsdc: supplyBalanceUsdc,
                borrowBalanceUsdc: borrowBalanceUsdc,
                collateralBalanceUsdc: collateralBalanceUsdc,
                borrowLimitUsdc: borrowLimitUsdc
            });
    }

    function assetsUserMetadata(address accountAddress, address[] memory _assetsAddresses)
        public
        view
        returns (AssetUserMetadata[] memory)
    {

        uint256 numberOfAssets = _assetsAddresses.length;
        AssetUserMetadata[] memory _assetsUserMetadata =
            new AssetUserMetadata[](numberOfAssets);
        for (uint256 assetIdx = 0; assetIdx < numberOfAssets; assetIdx++) {
            address assetAddress = _assetsAddresses[assetIdx];
            _assetsUserMetadata[assetIdx] = assetUserMetadata(
                accountAddress,
                assetAddress
            );
        }
        return _assetsUserMetadata;
    }

    function assetsUserMetadata(address accountAddress)
        public
        view
        returns (AssetUserMetadata[] memory)
    {

        address[] memory _assetsAddresses = assetsAddresses();
        return assetsUserMetadata(accountAddress, _assetsAddresses);
    }

    function assetUnderlyingTokenAddress(address assetAddress)
        public
        view
        returns (address)
    {

        ICyToken cyToken = ICyToken(assetAddress);
        address tokenAddress = cyToken.underlying();
        return tokenAddress;
    }

    function assetStatic(address assetAddress)
        public
        view
        returns (AssetStatic memory)
    {

        ICyToken asset = ICyToken(assetAddress);
        address tokenAddress = assetUnderlyingTokenAddress(assetAddress);
        return
            AssetStatic({
                id: assetAddress,
                typeId: adapterInfo().typeId,
                tokenId: tokenAddress,
                name: asset.name(),
                version: "2.0.0",
                symbol: asset.symbol(),
                decimals: asset.decimals()
            });
    }

    function assetUnderlyingTokenPriceUsdc(address assetAddress)
        public
        view
        returns (uint256)
    {

        address _underlyingTokenAddress =
            assetUnderlyingTokenAddress(assetAddress);
        IERC20 underlyingToken = IERC20(_underlyingTokenAddress);
        uint8 underlyingTokenDecimals = underlyingToken.decimals();
        uint256 underlyingTokenPrice =
            ICreamOracle(IUnitroller(comptrollerAddress()).oracle())
                .getUnderlyingPrice(assetAddress) /
                (10**(36 - underlyingTokenDecimals - 6));
        return underlyingTokenPrice;
    }

    function assetDynamic(address assetAddress)
        public
        view
        returns (AssetDynamic memory)
    {

        ICyToken asset = ICyToken(assetAddress);
        address tokenAddress = assetUnderlyingTokenAddress(assetAddress);
        uint256 liquidity = asset.getCash();
        uint256 liquidityUsdc;
        uint256 tokenPriceUsdc = assetUnderlyingTokenPriceUsdc(assetAddress);
        if (liquidity > 0) {
            liquidityUsdc = oracle().getNormalizedValueUsdc(
                tokenAddress,
                liquidity,
                tokenPriceUsdc
            );
        }
        IUnitroller.Market memory market =
            IUnitroller(comptrollerAddress()).markets(assetAddress);

        TokenAmount memory underlyingTokenBalance =
            tokenAmount(assetBalance(assetAddress), tokenAddress, tokenPriceUsdc);

        uint256 totalBorrowedUsdc =
            oracle().getNormalizedValueUsdc(
                tokenAddress,
                asset.totalBorrows(),
                tokenPriceUsdc
            );

        uint256 collateralCap = type(uint256).max;
        uint256 totalCollateralTokens;
        if (market.version >= 1) {
            collateralCap = asset.collateralCap();
            totalCollateralTokens = asset.totalCollateralTokens();
        }

        AssetMetadata memory metadata =
            AssetMetadata({
                totalSuppliedUsdc: underlyingTokenBalance.amountUsdc,
                totalBorrowedUsdc: totalBorrowedUsdc,
                lendApyBips: (asset.supplyRatePerBlock() * blocksPerYear) /
                    10**14,
                borrowApyBips: (asset.borrowRatePerBlock() * blocksPerYear) /
                    10**14,
                liquidity: liquidity,
                liquidityUsdc: liquidityUsdc,
                totalCollateralTokens: totalCollateralTokens,
                collateralFactor: market.collateralFactorMantissa,
                collateralCap: collateralCap,
                isActive: market.isListed,
                reserveFactor: asset.reserveFactorMantissa(),
                exchangeRate: asset.exchangeRateStored()
            });

        return
            AssetDynamic({
                id: assetAddress,
                typeId: adapterInfo().typeId,
                tokenId: tokenAddress,
                underlyingTokenBalance: underlyingTokenBalance,
                metadata: metadata
            });
    }

    function assetPositionsOf(address accountAddress, address assetAddress)
        public
        view
        returns (Position[] memory)
    {

        ICyToken asset = ICyToken(assetAddress);
        address tokenAddress = assetUnderlyingTokenAddress(assetAddress);
        uint256 supplyBalanceShares = asset.balanceOf(accountAddress);
        uint256 borrowBalanceShares = asset.borrowBalanceStored(accountAddress);

        uint8 currentPositionIdx;
        Position[] memory positions = new Position[](2);

        uint256 tokenPriceUsdc = assetUnderlyingTokenPriceUsdc(assetAddress);

        if (supplyBalanceShares > 0) {
            uint256 supplyBalanceUnderlying =
                (supplyBalanceShares * asset.exchangeRateStored()) / 10**18;
            positions[currentPositionIdx] = Position({
                assetId: assetAddress,
                tokenId: tokenAddress,
                typeId: positionLend,
                balance: supplyBalanceShares,
                underlyingTokenBalance: tokenAmount(
                    supplyBalanceUnderlying,
                    tokenAddress,
                    tokenPriceUsdc
                ),
                tokenAllowances: tokenAllowances(accountAddress, assetAddress),
                assetAllowances: assetAllowances(accountAddress, assetAddress)
            });
            currentPositionIdx++;
        }
        if (borrowBalanceShares > 0) {
            uint256 borrowedCyTokenBalance = (borrowBalanceShares * 10**18) / asset.exchangeRateStored();
            positions[currentPositionIdx] = Position({
                assetId: assetAddress,
                tokenId: tokenAddress,
                typeId: positionBorrow,
                balance: borrowedCyTokenBalance,
                underlyingTokenBalance: tokenAmount(
                    borrowBalanceShares,
                    tokenAddress,
                    tokenPriceUsdc
                ),
                tokenAllowances: tokenAllowances(accountAddress, assetAddress),
                assetAllowances: assetAllowances(accountAddress, assetAddress)
            });
            currentPositionIdx++;
        }

        bytes memory positionsEncoded = abi.encode(positions);
        assembly {
            mstore(add(positionsEncoded, 0x40), currentPositionIdx)
        }
        positions = abi.decode(positionsEncoded, (Position[]));

        return positions;
    }

    function assetsPositionsOf(
        address accountAddress,
        address[] memory _assetsAddresses
    ) public view returns (Position[] memory) {

        uint256 numberOfAssets = _assetsAddresses.length;

        Position[] memory positions = new Position[](numberOfAssets * 2);
        uint256 currentPositionIdx;
        for (uint256 assetIdx = 0; assetIdx < numberOfAssets; assetIdx++) {
            address assetAddress = _assetsAddresses[assetIdx];
            Position[] memory assetPositions =
                assetPositionsOf(accountAddress, assetAddress);

            for (
                uint256 assetPositionIdx = 0;
                assetPositionIdx < assetPositions.length;
                assetPositionIdx++
            ) {
                Position memory position = assetPositions[assetPositionIdx];
                if (position.balance > 0) {
                    positions[currentPositionIdx] = position;
                    currentPositionIdx++;
                }
            }
        }

        bytes memory encodedData = abi.encode(positions);
        assembly {
            mstore(add(encodedData, 0x40), currentPositionIdx)
        }
        positions = abi.decode(encodedData, (Position[]));
        return positions;
    }

    function assetsPositionsOf(address accountAddress)
        public
        view
        returns (Position[] memory)
    {

        address[] memory _assetsAddresses = assetsAddresses();
        return assetsPositionsOf(accountAddress, _assetsAddresses);
    }

    function assetBalance(address assetAddress) public view returns (uint256) {

        ICyToken cyToken = ICyToken(assetAddress);
        uint256 cash = cyToken.getCash();
        uint256 totalBorrows = cyToken.totalBorrows();
        uint256 totalReserves = cyToken.totalReserves();
        uint256 totalSupplied = (cash + totalBorrows - totalReserves);
        return totalSupplied;
    }

    function adapterPositionOf(address accountAddress)
        external
        view
        returns (AdapterPosition memory)
    {

        AssetUserMetadata[] memory _assetsUserMetadata =
            assetsUserMetadata(accountAddress);
        uint256 supplyBalanceUsdc;
        uint256 borrowBalanceUsdc;
        uint256 borrowLimitUsdc;
        for (
            uint256 metadataIdx = 0;
            metadataIdx < _assetsUserMetadata.length;
            metadataIdx++
        ) {
            AssetUserMetadata memory _assetUserMetadata =
                _assetsUserMetadata[metadataIdx];
            supplyBalanceUsdc += _assetUserMetadata.supplyBalanceUsdc;
            borrowBalanceUsdc += _assetUserMetadata.borrowBalanceUsdc;
            borrowLimitUsdc += _assetUserMetadata.borrowLimitUsdc;
        }
        uint256 utilizationRatioBips;
        if (borrowLimitUsdc > 0) {
            utilizationRatioBips =
                (borrowBalanceUsdc * 10000) /
                borrowLimitUsdc;
        }
        return
            AdapterPosition({
                supplyBalanceUsdc: supplyBalanceUsdc,
                borrowBalanceUsdc: borrowBalanceUsdc,
                borrowLimitUsdc: borrowLimitUsdc,
                utilizationRatioBips: utilizationRatioBips
            });
    }

    function assetsTokensAddresses() public view returns (address[] memory) {

        address[] memory _assetsAddresses = assetsAddresses();
        uint256 numberOfAssets = _assetsAddresses.length;
        address[] memory _tokensAddresses = new address[](numberOfAssets);
        for (uint256 assetIdx = 0; assetIdx < numberOfAssets; assetIdx++) {
            address assetAddress = _assetsAddresses[assetIdx];
            _tokensAddresses[assetIdx] = assetUnderlyingTokenAddress(
                assetAddress
            );
        }
        return _tokensAddresses;
    }
    
    function userSupplyBalanceUsdc(address accountAddress, ICyToken asset, address tokenAddress, uint256 tokenPriceUsdc)
        public
        view
        returns (uint256)
    {

        uint256 supplyBalanceShares = asset.balanceOf(accountAddress);
        uint256 supplyBalanceUnderlying =
            (supplyBalanceShares * asset.exchangeRateStored()) / 10**18;
        return oracle().getNormalizedValueUsdc(
            tokenAddress,
            supplyBalanceUnderlying,
            tokenPriceUsdc
        );
    }

    function userBorrowBalanceUsdc(address accountAddress, ICyToken asset, address tokenAddress, uint256 tokenPriceUsdc)
        public
        view
        returns (uint256)
    {

        uint256 borrowBalanceShares = asset.borrowBalanceStored(accountAddress);
        return oracle().getNormalizedValueUsdc(
            tokenAddress,
            borrowBalanceShares,
            tokenPriceUsdc
        );
    }

    function userCollateralBalanceUsdc(address accountAddress, ICyToken asset, address tokenAddress, uint256 tokenPriceUsdc)
        public
        view
        returns (uint256)
    {

        (, uint256 collateralBalanceShare, , ) = asset.getAccountSnapshot(accountAddress);
        uint256 collateralBalanceUnderlying =
            (collateralBalanceShare * asset.exchangeRateStored()) / 10**18;
        return oracle().getNormalizedValueUsdc(
            tokenAddress,
            collateralBalanceUnderlying,
            tokenPriceUsdc
        );
    }


    fallback() external {
        for (uint256 i = 0; i < _extensionsAddresses.length; i++) {
            address extension = _extensionsAddresses[i];
            assembly {
                let _target := extension
                calldatacopy(0, 0, calldatasize())
                let success := staticcall(
                    gas(),
                    _target,
                    0,
                    calldatasize(),
                    0,
                    0
                )
                returndatacopy(0, 0, returndatasize())
                if success {
                    return(0, returndatasize())
                }
            }
        }
        revert("Extensions: Fallback proxy failed to return data");
    }
}