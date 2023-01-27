
pragma solidity 0.8.2;


interface ILendingPoolAddressesProviderV2 {


    function getLendingPool() external view returns (address);

}

interface IAaveATokenV2 {


    function balanceOf(address _user) external view returns(uint256);

}

interface IAaveLendingPoolV2 {


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
    ) external;

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library MassetHelpers {

    using SafeERC20 for IERC20;

    function transferReturnBalance(
        address _sender,
        address _recipient,
        address _bAsset,
        uint256 _qty
    ) internal returns (uint256 receivedQty, uint256 recipientBalance) {

        uint256 balBefore = IERC20(_bAsset).balanceOf(_recipient);
        IERC20(_bAsset).safeTransferFrom(_sender, _recipient, _qty);
        recipientBalance = IERC20(_bAsset).balanceOf(_recipient);
        receivedQty = recipientBalance - balBefore;
    }

    function safeInfiniteApprove(address _asset, address _spender) internal {

        IERC20(_asset).safeApprove(_spender, 0);
        IERC20(_asset).safeApprove(_spender, 2**256 - 1);
    }
}

interface IPlatformIntegration {

    function deposit(
        address _bAsset,
        uint256 _amount,
        bool isTokenFeeCharged
    ) external returns (uint256 quantityDeposited);


    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external;


    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) external;


    function withdrawRaw(
        address _receiver,
        address _bAsset,
        uint256 _amount
    ) external;


    function checkBalance(address _bAsset) external returns (uint256 balance);


    function bAssetToPToken(address _bAsset) external returns (address pToken);

}

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

contract ModuleKeys {

    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
    bytes32 internal constant KEY_INTEREST_VALIDATOR =
        0xc10a28f028c7f7282a03c90608e38a4a646e136e614e4b07d119280c5f7f839f;
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

abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
    }

    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }

    function _liquidator() internal view returns (address) {
        return nexus.getModule(KEY_LIQUIDATOR);
    }

    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

abstract contract AbstractIntegration is
    IPlatformIntegration,
    Initializable,
    ImmutableModule,
    ReentrancyGuard
{
    event PTokenAdded(address indexed _bAsset, address _pToken);

    event Deposit(address indexed _bAsset, address _pToken, uint256 _amount);
    event Withdrawal(address indexed _bAsset, address _pToken, uint256 _amount);
    event PlatformWithdrawal(
        address indexed bAsset,
        address pToken,
        uint256 totalAmount,
        uint256 userAmount
    );

    address public immutable lpAddress;

    mapping(address => address) public override bAssetToPToken;
    address[] internal bAssetsMapped;

    constructor(address _nexus, address _lp) ReentrancyGuard() ImmutableModule(_nexus) {
        require(_lp != address(0), "Invalid LP address");
        lpAddress = _lp;
    }

    function initialize(address[] calldata _bAssets, address[] calldata _pTokens)
        public
        initializer
    {
        uint256 len = _bAssets.length;
        require(len == _pTokens.length, "Invalid inputs");
        for (uint256 i = 0; i < len; i++) {
            _setPTokenAddress(_bAssets[i], _pTokens[i]);
        }
    }

    modifier onlyLP() {
        require(msg.sender == lpAddress, "Only the LP can execute");
        _;
    }


    function setPTokenAddress(address _bAsset, address _pToken) external onlyGovernor {
        _setPTokenAddress(_bAsset, _pToken);
    }

    function _setPTokenAddress(address _bAsset, address _pToken) internal {
        require(bAssetToPToken[_bAsset] == address(0), "pToken already set");
        require(_bAsset != address(0) && _pToken != address(0), "Invalid addresses");

        bAssetToPToken[_bAsset] = _pToken;
        bAssetsMapped.push(_bAsset);

        emit PTokenAdded(_bAsset, _pToken);

        _abstractSetPToken(_bAsset, _pToken);
    }

    function _abstractSetPToken(address _bAsset, address _pToken) internal virtual;

    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

contract AaveV2Integration is AbstractIntegration {

    using SafeERC20 for IERC20;

    address public immutable platformAddress;
    address public immutable rewardToken;

    event RewardTokenApproved(address rewardToken, address account);

    constructor(
        address _nexus,
        address _lp,
        address _platformAddress,
        address _rewardToken
    ) AbstractIntegration(_nexus, _lp) {
        require(_platformAddress != address(0), "Invalid platform address");

        platformAddress = _platformAddress;

        rewardToken = _rewardToken;
    }


    function approveRewardToken() external onlyGovernor {

        address liquidator = nexus.getModule(keccak256("Liquidator"));
        require(liquidator != address(0), "Liquidator address cannot be zero");

        MassetHelpers.safeInfiniteApprove(rewardToken, liquidator);

        emit RewardTokenApproved(rewardToken, liquidator);
    }


    function deposit(
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant returns (uint256 quantityDeposited) {

        require(_amount > 0, "Must deposit something");

        IAaveATokenV2 aToken = _getATokenFor(_bAsset);

        quantityDeposited = _amount;

        if (_hasTxFee) {
            uint256 prevBal = _checkBalance(aToken);
            _getLendingPool().deposit(_bAsset, _amount, address(this), 36);
            uint256 newBal = _checkBalance(aToken);
            quantityDeposited = _min(quantityDeposited, newBal - prevBal);
        } else {
            _getLendingPool().deposit(_bAsset, _amount, address(this), 36);
        }

        emit Deposit(_bAsset, address(aToken), quantityDeposited);
    }

    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant {

        _withdraw(_receiver, _bAsset, _amount, _amount, _hasTxFee);
    }

    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant {

        _withdraw(_receiver, _bAsset, _amount, _totalAmount, _hasTxFee);
    }

    function _withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) internal {

        require(_totalAmount > 0, "Must withdraw something");

        IAaveATokenV2 aToken = _getATokenFor(_bAsset);

        if (_hasTxFee) {
            require(_amount == _totalAmount, "Cache inactive for assets with fee");
            _getLendingPool().withdraw(_bAsset, _amount, _receiver);
        } else {
            _getLendingPool().withdraw(_bAsset, _totalAmount, address(this));
            IERC20(_bAsset).safeTransfer(_receiver, _amount);
        }

        emit PlatformWithdrawal(_bAsset, address(aToken), _totalAmount, _amount);
    }

    function withdrawRaw(
        address _receiver,
        address _bAsset,
        uint256 _amount
    ) external override onlyLP nonReentrant {

        require(_amount > 0, "Must withdraw something");
        require(_receiver != address(0), "Must specify recipient");

        IERC20(_bAsset).safeTransfer(_receiver, _amount);

        emit Withdrawal(_bAsset, address(0), _amount);
    }

    function checkBalance(address _bAsset) external override returns (uint256 balance) {

        IAaveATokenV2 aToken = _getATokenFor(_bAsset);
        return _checkBalance(aToken);
    }


    function _abstractSetPToken(
        address _bAsset,
        address /*_pToken*/
    ) internal override {

        address lendingPool = address(_getLendingPool());
        MassetHelpers.safeInfiniteApprove(_bAsset, lendingPool);
    }


    function _getLendingPool() internal view returns (IAaveLendingPoolV2) {

        address lendingPool = ILendingPoolAddressesProviderV2(platformAddress).getLendingPool();
        require(lendingPool != address(0), "Lending pool does not exist");
        return IAaveLendingPoolV2(lendingPool);
    }

    function _getATokenFor(address _bAsset) internal view returns (IAaveATokenV2) {

        address aToken = bAssetToPToken[_bAsset];
        require(aToken != address(0), "aToken does not exist");
        return IAaveATokenV2(aToken);
    }

    function _checkBalance(IAaveATokenV2 _aToken) internal view returns (uint256 balance) {

        return _aToken.balanceOf(address(this));
    }
}

interface IAaveIncentivesController {

    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);


    function getRewardsBalance(address[] calldata assets, address user)
        external
        view
        returns (uint256);


    function getUserUnclaimedRewards(address user) external view returns (uint256);

}

contract PAaveIntegration is AaveV2Integration {

    event RewardsClaimed(address[] assets, uint256 amount);

    IAaveIncentivesController public immutable rewardController;

    constructor(
        address _nexus,
        address _lp,
        address _platformAddress,
        address _rewardToken,
        address _rewardController
    ) AaveV2Integration(_nexus, _lp, _platformAddress, _rewardToken) {
        require(_rewardController != address(0), "Invalid controller address");

        rewardController = IAaveIncentivesController(_rewardController);
    }

    function claimRewards() external {

        uint256 len = bAssetsMapped.length;
        address[] memory pTokens = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            pTokens[i] = bAssetToPToken[bAssetsMapped[i]];
        }
        uint256 rewards = rewardController.claimRewards(pTokens, type(uint256).max, address(this));

        emit RewardsClaimed(pTokens, rewards);
    }
}