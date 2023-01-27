
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


interface IPlatformIntegration {


    function deposit(address _bAsset, uint256 _amount, bool isTokenFeeCharged)
        external returns (uint256 quantityDeposited);


    function withdraw(address _receiver, address _bAsset, uint256 _amount, bool _hasTxFee) external;


    function withdraw(address _receiver, address _bAsset, uint256 _amount, uint256 _totalAmount, bool _hasTxFee) external;


    function withdrawRaw(address _receiver, address _bAsset, uint256 _amount) external;


    function checkBalance(address _bAsset) external returns (uint256 balance);


    function bAssetToPToken(address _bAsset) external returns (address pToken);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract InitializableModuleKeys {


    bytes32 internal KEY_GOVERNANCE;          // 2.x
    bytes32 internal KEY_STAKING;             // 1.2
    bytes32 internal KEY_PROXY_ADMIN;         // 1.0

    bytes32 internal KEY_ORACLE_HUB;          // 1.2
    bytes32 internal KEY_MANAGER;             // 1.2
    bytes32 internal KEY_RECOLLATERALISER;    // 2.x
    bytes32 internal KEY_META_TOKEN;          // 1.1
    bytes32 internal KEY_SAVINGS_MANAGER;     // 1.0

    function _initialize() internal {

        KEY_GOVERNANCE = keccak256("Governance");
        KEY_STAKING = keccak256("Staking");
        KEY_PROXY_ADMIN = keccak256("ProxyAdmin");

        KEY_ORACLE_HUB = keccak256("OracleHub");
        KEY_MANAGER = keccak256("Manager");
        KEY_RECOLLATERALISER = keccak256("Recollateraliser");
        KEY_META_TOKEN = keccak256("MetaToken");
        KEY_SAVINGS_MANAGER = keccak256("SavingsManager");
    }
}

interface INexus {

    function governor() external view returns (address);

    function getModule(bytes32 key) external view returns (address);


    function proposeModule(bytes32 _key, address _addr) external;

    function cancelProposedModule(bytes32 _key) external;

    function acceptProposedModule(bytes32 _key) external;

    function acceptProposedModules(bytes32[] calldata _keys) external;


    function requestLockModule(bytes32 _key) external;

    function cancelLockModule(bytes32 _key) external;

    function lockModule(bytes32 _key) external;

}

contract InitializableModule is InitializableModuleKeys {


    INexus public nexus;

    modifier onlyGovernor() {

        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    modifier onlyGovernance() {

        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    modifier onlyProxyAdmin() {

        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    modifier onlyManager() {

        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    function _initialize(address _nexus) internal {

        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
        InitializableModuleKeys._initialize();
    }

    function _governor() internal view returns (address) {

        return nexus.governor();
    }

    function _governance() internal view returns (address) {

        return nexus.getModule(KEY_GOVERNANCE);
    }

    function _staking() internal view returns (address) {

        return nexus.getModule(KEY_STAKING);
    }

    function _proxyAdmin() internal view returns (address) {

        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    function _metaToken() internal view returns (address) {

        return nexus.getModule(KEY_META_TOKEN);
    }

    function _oracleHub() internal view returns (address) {

        return nexus.getModule(KEY_ORACLE_HUB);
    }

    function _manager() internal view returns (address) {

        return nexus.getModule(KEY_MANAGER);
    }

    function _savingsManager() internal view returns (address) {

        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    function _recollateraliser() internal view returns (address) {

        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

contract InitializablePausableModule is InitializableModule {


    event Paused(address account);

    event Unpaused(address account);

    bool private _paused = false;

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _initialize(address _nexus) internal {

        InitializableModule._initialize(_nexus);
        _paused = false;
    }

    function paused() external view returns (bool) {

        return _paused;
    }

    function pause() external onlyGovernor whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyGovernor whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface MassetStructs {


    struct Basket {

        Basset[] bassets;

        uint8 maxBassets;

        bool undergoingRecol;

        bool failed;
        uint256 collateralisationRatio;

    }

    struct Basset {

        address addr;

        BassetStatus status; // takes uint8 datatype (1 byte) in storage

        bool isTransferFeeCharged; // takes a byte in storage

        uint256 ratio;

        uint256 maxWeight;

        uint256 vaultBalance;

    }

    enum BassetStatus {
        Default,
        Normal,
        BrokenBelowPeg,
        BrokenAbovePeg,
        Blacklisted,
        Liquidating,
        Liquidated,
        Failed
    }

    struct BassetDetails {
        Basset bAsset;
        address integrator;
        uint8 index;
    }

    struct ForgePropsMulti {
        bool isValid; // Flag to signify that forge bAssets have passed validity check
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
    struct RedeemProps {
        bool isValid;
        Basset[] allBassets;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }

    struct RedeemPropsMulti {
        uint256 colRatio;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
}

contract IBasketManager is MassetStructs {


    function increaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _increaseAmount) external;

    function increaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _increaseAmount) external;

    function decreaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _decreaseAmount) external;

    function decreaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _decreaseAmount) external;

    function collectInterest() external
        returns (uint256 interestCollected, uint256[] memory gains);


    function addBasset(
        address _basset,
        address _integration,
        bool _isTransferFeeCharged) external returns (uint8 index);

    function setBasketWeights(address[] calldata _bassets, uint256[] calldata _weights) external;

    function setTransferFeesFlag(address _bAsset, bool _flag) external;


    function getBasket() external view returns (Basket memory b);

    function prepareForgeBasset(address _token, uint256 _amt, bool _mint) external
        returns (bool isValid, BassetDetails memory bInfo);

    function prepareSwapBassets(address _input, address _output, bool _isMint) external view
        returns (bool, string memory, BassetDetails memory, BassetDetails memory);

    function prepareForgeBassets(address[] calldata _bAssets, uint256[] calldata _amts, bool _mint) external
        returns (ForgePropsMulti memory props);

    function prepareRedeemBassets(address[] calldata _bAssets) external view
        returns (RedeemProps memory props);

    function prepareRedeemMulti() external view
        returns (RedeemPropsMulti memory props);

    function getBasset(address _token) external view
        returns (Basset memory bAsset);

    function getBassets() external view
        returns (Basset[] memory bAssets, uint256 len);

    function paused() external view returns (bool);


    function handlePegLoss(address _basset, bool _belowPeg) external returns (bool actioned);

    function negateIsolation(address _basset) external;

}

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

interface IBasicToken {

    function decimals() external view returns (uint8);

}

library CommonHelpers {


    function getDecimals(address _token)
    internal
    view
    returns (uint256) {

        uint256 decimals = IBasicToken(_token).decimals();
        require(decimals >= 4 && decimals <= 18, "Token must have sufficient decimal places");

        return decimals;
    }

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library StableMath {


    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {

        return x.mul(FULL_SCALE);
    }


    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(y);
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }



    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(ratio);
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        return ceil.div(RATIO_SCALE);
    }


    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        uint256 y = x.mul(RATIO_SCALE);
        return y.div(ratio);
    }


    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {

        return x > upperBound ? upperBound : x;
    }
}

contract InitializableReentrancyGuard {

    bool private _notEntered;

    function _initialize() internal {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

contract BasketManager is
    Initializable,
    IBasketManager,
    InitializablePausableModule,
    InitializableReentrancyGuard
{

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeERC20 for IERC20;

    event BassetAdded(address indexed bAsset, address integrator);
    event BassetRemoved(address indexed bAsset);
    event BassetsMigrated(address[] bAssets, address newIntegrator);
    event BasketWeightsUpdated(address[] bAssets, uint256[] maxWeights);
    event BassetStatusChanged(address indexed bAsset, BassetStatus status);
    event BasketStatusChanged();
    event TransferFeeEnabled(address indexed bAsset, bool enabled);

    address public mAsset;

    Basket public basket;
    mapping(address => uint8) private bAssetsMap;
    address[] public integrations;


    modifier whenBasketIsHealthy() {

        require(!basket.failed, "Basket must be alive");
        _;
    }

    modifier whenNotRecolling() {

        require(!basket.undergoingRecol, "No bAssets can be undergoing recol");
        _;
    }

    modifier managerOrGovernor() {

        require(
            _manager() == msg.sender || _governor() == msg.sender,
            "Must be manager or governor");
        _;
    }

    modifier onlyMasset() {

        require(mAsset == msg.sender, "Must be called by mAsset");
        _;
    }


    function increaseVaultBalance(
        uint8 _bAssetIndex,
        address /* _integrator */,
        uint256 _increaseAmount
    )
        external
        onlyMasset
        whenBasketIsHealthy
        nonReentrant
    {

        basket.bassets[_bAssetIndex].vaultBalance =
            basket.bassets[_bAssetIndex].vaultBalance.add(_increaseAmount);
    }

    function increaseVaultBalances(
        uint8[] calldata _bAssetIndices,
        address[] calldata /* _integrator */,
        uint256[] calldata _increaseAmount
    )
        external
        onlyMasset
        whenBasketIsHealthy
        nonReentrant
    {

        uint256 len = _bAssetIndices.length;
        for(uint i = 0; i < len; i++) {
            basket.bassets[_bAssetIndices[i]].vaultBalance =
                basket.bassets[_bAssetIndices[i]].vaultBalance.add(_increaseAmount[i]);
        }
    }

    function decreaseVaultBalance(
        uint8 _bAssetIndex,
        address /* _integrator */,
        uint256 _decreaseAmount
    )
        external
        onlyMasset
        nonReentrant
    {

        basket.bassets[_bAssetIndex].vaultBalance =
            basket.bassets[_bAssetIndex].vaultBalance.sub(_decreaseAmount);
    }

    function decreaseVaultBalances(
        uint8[] calldata _bAssetIndices,
        address[] calldata /* _integrator */,
        uint256[] calldata _decreaseAmount
    )
        external
        onlyMasset
        nonReentrant
    {

        uint256 len = _bAssetIndices.length;
        for(uint i = 0; i < len; i++) {
            basket.bassets[_bAssetIndices[i]].vaultBalance =
                basket.bassets[_bAssetIndices[i]].vaultBalance.sub(_decreaseAmount[i]);
        }
    }

    function collectInterest()
        external
        onlyMasset
        whenNotPaused
        whenBasketIsHealthy
        nonReentrant
        returns (uint256 interestCollected, uint256[] memory gains)
    {

        (Basset[] memory allBassets, uint256 count) = _getBassets();
        gains = new uint256[](count);
        interestCollected = 0;

        for(uint8 i = 0; i < count; i++) {
            Basset memory b = allBassets[i];
            address bAsset = b.addr;

            address integration = integrations[i];
            uint256 lending = IPlatformIntegration(integration).checkBalance(bAsset);
            uint256 cache = 0;
            if (!b.isTransferFeeCharged) {
                cache = IERC20(bAsset).balanceOf(integration);
            }
            uint256 balance = lending.add(cache);

            uint256 oldVaultBalance = b.vaultBalance;

            if(balance > oldVaultBalance && b.status == BassetStatus.Normal) {
                basket.bassets[i].vaultBalance = balance;

                uint256 interestDelta = balance.sub(oldVaultBalance);
                gains[i] = interestDelta;

                uint256 ratioedDelta = interestDelta.mulRatioTruncate(b.ratio);
                interestCollected = interestCollected.add(ratioedDelta);
            } else {
                gains[i] = 0;
            }
        }
    }



    function addBasset(address _bAsset, address _integration, bool _isTransferFeeCharged)
        external
        onlyGovernor
        whenBasketIsHealthy
        whenNotRecolling
        returns (uint8 index)
    {

        index = _addBasset(
            _bAsset,
            _integration,
            StableMath.getRatioScale(),
            _isTransferFeeCharged
        );
    }

    function _addBasset(
        address _bAsset,
        address _integration,
        uint256 _measurementMultiple,
        bool _isTransferFeeCharged
    )
        internal
        returns (uint8 index)
    {

        require(_bAsset != address(0), "bAsset address must be valid");
        require(_integration != address(0), "Integration address must be valid");
        require(_measurementMultiple >= 1e6 && _measurementMultiple <= 1e10, "MM out of range");

        (bool alreadyInBasket, ) = _isAssetInBasket(_bAsset);
        require(!alreadyInBasket, "bAsset already exists in Basket");

        IPlatformIntegration(_integration).checkBalance(_bAsset);

        uint256 bAsset_decimals = CommonHelpers.getDecimals(_bAsset);
        uint256 delta = uint256(18).sub(bAsset_decimals);

        uint256 ratio = _measurementMultiple.mul(10 ** delta);

        uint8 numberOfBassetsInBasket = uint8(basket.bassets.length);
        require(numberOfBassetsInBasket < basket.maxBassets, "Max bAssets in Basket");

        bAssetsMap[_bAsset] = numberOfBassetsInBasket;

        integrations.push(_integration);
        basket.bassets.push(Basset({
            addr: _bAsset,
            ratio: ratio,
            maxWeight: 0,
            vaultBalance: 0,
            status: BassetStatus.Normal,
            isTransferFeeCharged: _isTransferFeeCharged
        }));

        emit BassetAdded(_bAsset, _integration);

        index = numberOfBassetsInBasket;
    }


    function setBasketWeights(
        address[] calldata _bAssets,
        uint256[] calldata _weights
    )
        external
        onlyGovernor
        whenBasketIsHealthy
    {

        _setBasketWeights(_bAssets, _weights, false);
    }

    function _setBasketWeights(
        address[] memory _bAssets,
        uint256[] memory _weights,
        bool _isBootstrap
    )
        internal
    {

        uint256 bAssetCount = _bAssets.length;
        require(bAssetCount > 0, "Empty bAssets array passed");
        require(bAssetCount == _weights.length, "Must be matching bAsset arrays");

        for (uint256 i = 0; i < bAssetCount; i++) {
            (bool exists, uint8 index) = _isAssetInBasket(_bAssets[i]);
            require(exists, "bAsset must exist");

            Basset memory bAsset = _getBasset(index);

            uint256 bAssetWeight = _weights[i];

            if(bAsset.status == BassetStatus.Normal) {
                require(
                    bAssetWeight <= 1e18,
                    "Asset weight must be <= 100%"
                );
                basket.bassets[index].maxWeight = bAssetWeight;
            } else {
                require(
                    bAssetWeight == basket.bassets[index].maxWeight,
                    "Affected bAssets must be static"
                );
            }
        }

        if(!_isBootstrap){
            _validateBasketWeight();
        }

        emit BasketWeightsUpdated(_bAssets, _weights);
    }

    function _validateBasketWeight() internal view {

        uint256 len = basket.bassets.length;
        uint256 weightSum = 0;
        for(uint256 i = 0; i < len; i++) {
            weightSum = weightSum.add(basket.bassets[i].maxWeight);
        }
        require(weightSum >= 1e18 && weightSum <= 4e18, "Basket weight must be >= 100 && <= 400%");
    }

    function setTransferFeesFlag(address _bAsset, bool _flag)
        external
        managerOrGovernor
    {

        (bool exist, uint8 index) = _isAssetInBasket(_bAsset);
        require(exist, "bAsset does not exist");
        basket.bassets[index].isTransferFeeCharged = _flag;

        if(_flag){
            uint256 bal = IERC20(_bAsset).balanceOf(integrations[index]);
            if(bal > 0){
                IPlatformIntegration(integrations[index]).deposit(_bAsset, bal, true);
            }
        }

        emit TransferFeeEnabled(_bAsset, _flag);
    }


    function removeBasset(address _assetToRemove)
        external
        whenBasketIsHealthy
        whenNotRecolling
        managerOrGovernor
    {

        _removeBasset(_assetToRemove);
    }

    function _removeBasset(address _assetToRemove) internal {

        (bool exists, uint8 index) = _isAssetInBasket(_assetToRemove);
        require(exists, "bAsset does not exist");

        uint256 len = basket.bassets.length;
        Basset memory bAsset = basket.bassets[index];

        require(bAsset.maxWeight == 0, "bAsset must have a target weight of 0");
        require(bAsset.vaultBalance == 0, "bAsset vault must be empty");
        require(bAsset.status != BassetStatus.Liquidating, "bAsset must be active");

        uint8 lastIndex = uint8(len.sub(1));
        if(index == lastIndex) {
            basket.bassets.pop();
            bAssetsMap[_assetToRemove] = 0;
            integrations.pop();
        } else {
            basket.bassets[index] = basket.bassets[lastIndex];
            basket.bassets.pop();
            Basset memory swappedBasset = basket.bassets[index];
            bAssetsMap[_assetToRemove] = 0;
            bAssetsMap[swappedBasset.addr] = index;
            integrations[index] = integrations[lastIndex];
            integrations.pop();
        }

        emit BassetRemoved(bAsset.addr);
    }

    function migrateBassets(
        address[] calldata _bAssets,
        address _newIntegration
    )
        external
        onlyGovernor
    {

        uint256 len = _bAssets.length;
        require(len > 0, "Must migrate some bAssets");

        for(uint i = 0; i < len; i++){
            address bAsset = _bAssets[i];
            (bool inBasket, uint8 index) = _isAssetInBasket(bAsset);
            require(inBasket, "bAsset does not exist");
            require(!basket.bassets[index].isTransferFeeCharged, "Cannot migrate bAssets with xfer fee");

            IPlatformIntegration oldIntegration = IPlatformIntegration(integrations[index]);
            require(address(oldIntegration) != _newIntegration, "Must transfer to new integrator");
            uint256 cache = IERC20(bAsset).balanceOf(address(oldIntegration));
            uint256 lendingBal = oldIntegration.checkBalance(bAsset);
            oldIntegration.withdraw(address(this), bAsset, lendingBal, false);
            oldIntegration.withdrawRaw(address(this), bAsset, cache);
            uint256 total = lendingBal.add(cache);

            integrations[index] = _newIntegration;

            IERC20(bAsset).safeTransfer(_newIntegration, total);
            IPlatformIntegration newIntegration = IPlatformIntegration(_newIntegration);
            newIntegration.deposit(bAsset, lendingBal, false);
            uint256 newLendingBal = newIntegration.checkBalance(bAsset);
            uint256 newCache = IERC20(bAsset).balanceOf(address(newIntegration));
            uint256 upperMargin = 10001e14;
            uint256 lowerMargin =  9999e14;

            require(
                newLendingBal >= lendingBal.mulTruncate(lowerMargin) &&
                newLendingBal <= lendingBal.mulTruncate(upperMargin),
                "Must transfer full amount");
            require(
                newCache >= cache.mulTruncate(lowerMargin) &&
                newCache <= cache.mulTruncate(upperMargin),
                "Must transfer full amount");
        }

        emit BassetsMigrated(_bAssets, _newIntegration);
    }



    function getBasket()
        external
        view
        returns (Basket memory b)
    {

        b = basket;
    }

    function prepareForgeBasset(address _bAsset, uint256 /*_amt*/, bool /*_mint*/)
        external
        whenNotPaused
        whenNotRecolling
        returns (bool isValid, BassetDetails memory bInfo)
    {

        (bool exists, uint8 idx) = _isAssetInBasket(_bAsset);
        require(exists, "bAsset does not exist");
        isValid = true;
        bInfo = BassetDetails({
            bAsset: basket.bassets[idx],
            integrator: integrations[idx],
            index: idx
        });
    }

    function prepareSwapBassets(address _input, address _output, bool _isMint)
        external
        view
        whenNotPaused
        returns (bool, string memory, BassetDetails memory, BassetDetails memory)
    {

        BassetDetails memory input;
        BassetDetails memory output;
        if(basket.failed || basket.undergoingRecol){
            return (false, "Basket is undergoing change", input, output);
        }

        (bool inputExists, uint8 inputIdx) = _isAssetInBasket(_input);
        if(!inputExists) {
            return (false, "Input asset does not exist", input, output);
        }
        input = BassetDetails({
            bAsset: basket.bassets[inputIdx],
            integrator: integrations[inputIdx],
            index: inputIdx
        });

        if(_isMint) {
            return (true, "", input, output);
        }

        (bool outputExists, uint8 outputIdx) = _isAssetInBasket(_output);
        if(!outputExists) {
            return (false, "Output asset does not exist", input, output);
        }
        output = BassetDetails({
            bAsset: basket.bassets[outputIdx],
            integrator: integrations[outputIdx],
            index: outputIdx
        });
        return (true, "", input, output);
    }

    function prepareForgeBassets(
        address[] calldata _bAssets,
        uint256[] calldata /*_amts*/,
        bool /* _isMint */
    )
        external
        whenNotPaused
        whenNotRecolling
        returns (ForgePropsMulti memory props)
    {

        (Basset[] memory bAssets, uint8[] memory indexes, address[] memory integrators) = _fetchForgeBassets(_bAssets);
        props = ForgePropsMulti({
            isValid: true,
            bAssets: bAssets,
            integrators: integrators,
            indexes: indexes
        });
    }

    function prepareRedeemBassets(
        address[] calldata _bAssets
    )
        external
        view
        whenNotPaused
        whenNotRecolling
        whenBasketIsHealthy
        returns (RedeemProps memory props)
    {

        (Basset[] memory bAssets, uint8[] memory indexes, address[] memory integrators) = _fetchForgeBassets(_bAssets);
        props = RedeemProps({
            isValid: true,
            allBassets: basket.bassets,
            bAssets: bAssets,
            integrators: integrators,
            indexes: indexes
        });
    }

    function prepareRedeemMulti()
        external
        view
        whenNotPaused
        whenNotRecolling
        returns (RedeemPropsMulti memory props)
    {

        (Basset[] memory bAssets, uint256 len) = _getBassets();
        address[] memory orderedIntegrators = new address[](len);
        uint8[] memory indexes = new uint8[](len);
        for(uint8 i = 0; i < len; i++){
            orderedIntegrators[i] = integrations[i];
            indexes[i] = i;
        }
        props = RedeemPropsMulti({
            colRatio: basket.collateralisationRatio,
            bAssets: bAssets,
            integrators: orderedIntegrators,
            indexes: indexes
        });
    }

    function _fetchForgeBassets(address[] memory _bAssets)
        internal
        view
        returns (
            Basset[] memory bAssets,
            uint8[] memory indexes,
            address[] memory integrators
        )
    {

        uint8 len = uint8(_bAssets.length);

        bAssets = new Basset[](len);
        integrators = new address[](len);
        indexes = new uint8[](len);

        for(uint8 i = 0; i < len; i++) {
            address current = _bAssets[i];

            for(uint8 j = i+1; j < len; j++){
                require(current != _bAssets[j], "Must have no duplicates");
            }

            (bool exists, uint8 index) = _isAssetInBasket(current);
            require(exists, "bAsset must exist");
            indexes[i] = index;
            bAssets[i] = basket.bassets[index];
            integrators[i] = integrations[index];
        }
    }

    function getBassets()
        external
        view
        returns (
            Basset[] memory bAssets,
            uint256 len
        )
    {

        return _getBassets();
    }

    function getBasset(address _bAsset)
        external
        view
        returns (Basset memory bAsset)
    {

        (bool exists, uint8 index) = _isAssetInBasket(_bAsset);
        require(exists, "bAsset must exist");
        bAsset = _getBasset(index);
    }

    function getBassetIntegrator(address _bAsset)
        external
        view
        returns (address integrator)
    {

        (bool exists, uint8 index) = _isAssetInBasket(_bAsset);
        require(exists, "bAsset must exist");
        integrator = integrations[index];
    }

    function _getBassets()
        internal
        view
        returns (
            Basset[] memory bAssets,
            uint256 len
        )
    {

        bAssets = basket.bassets;
        len = basket.bassets.length;
    }

    function _getBasset(uint8 _bAssetIndex)
        internal
        view
        returns (Basset memory bAsset)
    {

        bAsset = basket.bassets[_bAssetIndex];
    }



    function _isAssetInBasket(address _asset)
        internal
        view
        returns (bool exists, uint8 index)
    {

        index = bAssetsMap[_asset];
        if(index == 0) {
            if(basket.bassets.length == 0) {
                return (false, 0);
            }
            return (basket.bassets[0].addr == _asset, 0);
        }
        return (true, index);
    }

    function _bAssetHasRecolled(BassetStatus _status)
        internal
        pure
        returns (bool)
    {

        if(_status == BassetStatus.Liquidating ||
            _status == BassetStatus.Liquidated ||
            _status == BassetStatus.Failed) {
            return true;
        }
        return false;
    }



    function handlePegLoss(address _bAsset, bool _belowPeg)
        external
        managerOrGovernor
        whenBasketIsHealthy
        returns (bool alreadyActioned)
    {

        (bool exists, uint256 i) = _isAssetInBasket(_bAsset);
        require(exists, "bAsset must exist in Basket");

        BassetStatus oldStatus = basket.bassets[i].status;
        BassetStatus newStatus =
            _belowPeg ? BassetStatus.BrokenBelowPeg : BassetStatus.BrokenAbovePeg;

        if(oldStatus == newStatus || _bAssetHasRecolled(oldStatus)) {
            return true;
        }

        basket.bassets[i].status = newStatus;
        emit BassetStatusChanged(_bAsset, newStatus);
        return false;
    }

    function negateIsolation(address _bAsset)
        external
        managerOrGovernor
    {

        (bool exists, uint256 i) = _isAssetInBasket(_bAsset);
        require(exists, "bAsset must exist");

        BassetStatus currentStatus = basket.bassets[i].status;
        if(currentStatus == BassetStatus.BrokenBelowPeg ||
            currentStatus == BassetStatus.BrokenAbovePeg ||
            currentStatus == BassetStatus.Blacklisted) {
            basket.bassets[i].status = BassetStatus.Normal;
            emit BassetStatusChanged(_bAsset, BassetStatus.Normal);
        }
    }

    function failBasset(address _bAsset)
        external
        onlyGovernor
    {

        (bool exists, uint256 i) = _isAssetInBasket(_bAsset);
        require(exists, "bAsset must exist");

        BassetStatus currentStatus = basket.bassets[i].status;
        require(
            currentStatus == BassetStatus.BrokenBelowPeg ||
            currentStatus == BassetStatus.BrokenAbovePeg,
            "bAsset must be affected"
        );
        basket.failed = true;
    }
}