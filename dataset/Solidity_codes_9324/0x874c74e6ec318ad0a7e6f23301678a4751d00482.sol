

pragma solidity 0.5.11;

interface ICurvePool {

    function get_virtual_price() external view returns (uint256);


    function add_liquidity(uint256[3] calldata _amounts, uint256 _min) external;


    function balances(uint256) external view returns (uint256);


    function calc_token_amount(uint256[3] calldata _amounts, bool _deposit)
        external
        returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _amount,
        int128 _index,
        uint256 _minAmount
    ) external;


    function remove_liquidity(
        uint256 _amount,
        uint256[3] calldata _minWithdrawAmounts
    ) external;


    function calc_withdraw_one_coin(uint256 _amount, int128 _index)
        external
        view
        returns (uint256);


    function coins(uint256 _index) external view returns (address);

}


pragma solidity 0.5.11;

interface ICurveGauge {

    function balanceOf(address account) external view returns (uint256);


    function deposit(uint256 value, address account) external;


    function withdraw(uint256 value) external;

}


pragma solidity 0.5.11;

interface ICRVMinter {

    function mint(address gaugeAddress) external;

}


pragma solidity >=0.4.24 <0.7.0;


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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.0;



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


pragma solidity 0.5.11;

contract Governable {

    bytes32
        private constant governorPosition = 0x7bea13895fa79d2831e0a9e28edede30099005a50d652d8957cf8a607ee6ca4a;

    bytes32
        private constant pendingGovernorPosition = 0x44c4d30b2eaad5130ad70c3ba6972730566f3e6359ab83e800d905c61b1c51db;

    bytes32
        private constant reentryStatusPosition = 0x53bf423e48ed90e97d02ab0ebab13b2a235a6bfbe9c321847d5c175333ac4535;

    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    event PendingGovernorshipTransfer(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    event GovernorshipTransferred(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    constructor() internal {
        _setGovernor(msg.sender);
        emit GovernorshipTransferred(address(0), _governor());
    }

    function governor() public view returns (address) {

        return _governor();
    }

    function _governor() internal view returns (address governorOut) {

        bytes32 position = governorPosition;
        assembly {
            governorOut := sload(position)
        }
    }

    function _pendingGovernor()
        internal
        view
        returns (address pendingGovernor)
    {

        bytes32 position = pendingGovernorPosition;
        assembly {
            pendingGovernor := sload(position)
        }
    }

    modifier onlyGovernor() {

        require(isGovernor(), "Caller is not the Governor");
        _;
    }

    function isGovernor() public view returns (bool) {

        return msg.sender == _governor();
    }

    function _setGovernor(address newGovernor) internal {

        bytes32 position = governorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    modifier nonReentrant() {

        bytes32 position = reentryStatusPosition;
        uint256 _reentry_status;
        assembly {
            _reentry_status := sload(position)
        }

        require(_reentry_status != _ENTERED, "Reentrant call");

        assembly {
            sstore(position, _ENTERED)
        }

        _;

        assembly {
            sstore(position, _NOT_ENTERED)
        }
    }

    function _setPendingGovernor(address newGovernor) internal {

        bytes32 position = pendingGovernorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    function transferGovernance(address _newGovernor) external onlyGovernor {

        _setPendingGovernor(_newGovernor);
        emit PendingGovernorshipTransfer(_governor(), _newGovernor);
    }

    function claimGovernance() external {

        require(
            msg.sender == _pendingGovernor(),
            "Only the pending Governor can complete the claim"
        );
        _changeGovernor(msg.sender);
    }

    function _changeGovernor(address _newGovernor) internal {

        require(_newGovernor != address(0), "New Governor is address(0)");
        emit GovernorshipTransferred(_governor(), _newGovernor);
        _setGovernor(_newGovernor);
    }
}


pragma solidity 0.5.11;




contract InitializableAbstractStrategy is Initializable, Governable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event PTokenAdded(address indexed _asset, address _pToken);
    event PTokenRemoved(address indexed _asset, address _pToken);
    event Deposit(address indexed _asset, address _pToken, uint256 _amount);
    event Withdrawal(address indexed _asset, address _pToken, uint256 _amount);
    event RewardTokenCollected(address recipient, uint256 amount);

    address public platformAddress;

    address public vaultAddress;

    mapping(address => address) public assetToPToken;

    address[] internal assetsMapped;

    address public rewardTokenAddress;
    uint256 public rewardLiquidationThreshold;

    function initialize(
        address _platformAddress,
        address _vaultAddress,
        address _rewardTokenAddress,
        address[] calldata _assets,
        address[] calldata _pTokens
    ) external onlyGovernor initializer {

        InitializableAbstractStrategy._initialize(
            _platformAddress,
            _vaultAddress,
            _rewardTokenAddress,
            _assets,
            _pTokens
        );
    }

    function _initialize(
        address _platformAddress,
        address _vaultAddress,
        address _rewardTokenAddress,
        address[] memory _assets,
        address[] memory _pTokens
    ) internal {

        platformAddress = _platformAddress;
        vaultAddress = _vaultAddress;
        rewardTokenAddress = _rewardTokenAddress;
        uint256 assetCount = _assets.length;
        require(assetCount == _pTokens.length, "Invalid input arrays");
        for (uint256 i = 0; i < assetCount; i++) {
            _setPTokenAddress(_assets[i], _pTokens[i]);
        }
    }

    function collectRewardToken() external onlyVault nonReentrant {

        IERC20 rewardToken = IERC20(rewardTokenAddress);
        uint256 balance = rewardToken.balanceOf(address(this));
        emit RewardTokenCollected(vaultAddress, balance);
        rewardToken.safeTransfer(vaultAddress, balance);
    }

    modifier onlyVault() {

        require(msg.sender == vaultAddress, "Caller is not the Vault");
        _;
    }

    modifier onlyVaultOrGovernor() {

        require(
            msg.sender == vaultAddress || msg.sender == governor(),
            "Caller is not the Vault or Governor"
        );
        _;
    }

    function setRewardTokenAddress(address _rewardTokenAddress)
        external
        onlyGovernor
    {

        rewardTokenAddress = _rewardTokenAddress;
    }

    function setRewardLiquidationThreshold(uint256 _threshold)
        external
        onlyGovernor
    {

        rewardLiquidationThreshold = _threshold;
    }

    function setPTokenAddress(address _asset, address _pToken)
        external
        onlyGovernor
    {

        _setPTokenAddress(_asset, _pToken);
    }

    function removePToken(uint256 _assetIndex) external onlyGovernor {

        require(_assetIndex < assetsMapped.length, "Invalid index");
        address asset = assetsMapped[_assetIndex];
        address pToken = assetToPToken[asset];

        if (_assetIndex < assetsMapped.length - 1) {
            assetsMapped[_assetIndex] = assetsMapped[assetsMapped.length - 1];
        }
        assetsMapped.pop();
        assetToPToken[asset] = address(0);

        emit PTokenRemoved(asset, pToken);
    }

    function _setPTokenAddress(address _asset, address _pToken) internal {

        require(assetToPToken[_asset] == address(0), "pToken already set");
        require(
            _asset != address(0) && _pToken != address(0),
            "Invalid addresses"
        );

        assetToPToken[_asset] = _pToken;
        assetsMapped.push(_asset);

        emit PTokenAdded(_asset, _pToken);

        _abstractSetPToken(_asset, _pToken);
    }

    function transferToken(address _asset, uint256 _amount)
        public
        onlyGovernor
    {

        IERC20(_asset).safeTransfer(governor(), _amount);
    }


    function _abstractSetPToken(address _asset, address _pToken) internal;


    function safeApproveAllTokens() external;


    function deposit(address _asset, uint256 _amount) external;


    function depositAll() external;


    function withdraw(
        address _recipient,
        address _asset,
        uint256 _amount
    ) external;


    function withdrawAll() external;


    function checkBalance(address _asset)
        external
        view
        returns (uint256 balance);


    function supportsAsset(address _asset) external view returns (bool);

}


pragma solidity 0.5.11;


library StableMath {

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;


    function scaleBy(uint256 x, int8 adjustment)
        internal
        pure
        returns (uint256)
    {

        if (adjustment > 0) {
            x = x.mul(10**uint256(adjustment));
        } else if (adjustment < 0) {
            x = x.div(10**uint256(adjustment * -1));
        }
        return x;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

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
}


pragma solidity 0.5.11;

interface IBasicToken {

    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity 0.5.11;

library Helpers {

    function getSymbol(address _token) internal view returns (string memory) {

        string memory symbol = IBasicToken(_token).symbol();
        return symbol;
    }

    function getDecimals(address _token) internal view returns (uint256) {

        uint256 decimals = IBasicToken(_token).decimals();
        require(
            decimals >= 4 && decimals <= 18,
            "Token must have sufficient decimal places"
        );

        return decimals;
    }
}


pragma solidity 0.5.11;







contract ThreePoolStrategy is InitializableAbstractStrategy {

    using StableMath for uint256;

    event RewardTokenCollected(address recipient, uint256 amount);

    address crvGaugeAddress;
    address crvMinterAddress;
    uint256 constant maxSlippage = 1e16; // 1%, same as the Curve UI

    function initialize(
        address _platformAddress, // 3Pool address
        address _vaultAddress,
        address _rewardTokenAddress, // CRV
        address[] calldata _assets,
        address[] calldata _pTokens,
        address _crvGaugeAddress,
        address _crvMinterAddress
    ) external onlyGovernor initializer {

        crvGaugeAddress = _crvGaugeAddress;
        crvMinterAddress = _crvMinterAddress;
        InitializableAbstractStrategy._initialize(
            _platformAddress,
            _vaultAddress,
            _rewardTokenAddress,
            _assets,
            _pTokens
        );
    }

    function collectRewardToken() external onlyVault nonReentrant {

        IERC20 crvToken = IERC20(rewardTokenAddress);
        ICRVMinter minter = ICRVMinter(crvMinterAddress);
        uint256 balance = crvToken.balanceOf(address(this));
        emit RewardTokenCollected(vaultAddress, balance);
        minter.mint(crvGaugeAddress);
        crvToken.safeTransfer(vaultAddress, balance);
    }

    function deposit(address _asset, uint256 _amount)
        external
        onlyVault
        nonReentrant
    {

        require(_amount > 0, "Must deposit something");
        emit Deposit(_asset, address(platformAddress), _amount);
        uint256[3] memory _amounts;
        uint256 poolCoinIndex = _getPoolCoinIndex(_asset);
        _amounts[poolCoinIndex] = _amount;
        ICurvePool curvePool = ICurvePool(platformAddress);
        uint256 assetDecimals = Helpers.getDecimals(_asset);
        uint256 depositValue = _amount
            .scaleBy(int8(18 - assetDecimals))
            .divPrecisely(curvePool.get_virtual_price());
        uint256 minMintAmount = depositValue.mulTruncate(
            uint256(1e18).sub(maxSlippage)
        );
        curvePool.add_liquidity(_amounts, minMintAmount);
        IERC20 pToken = IERC20(assetToPToken[_asset]);
        ICurveGauge(crvGaugeAddress).deposit(
            pToken.balanceOf(address(this)),
            address(this)
        );
    }

    function depositAll() external onlyVault nonReentrant {

        uint256[3] memory _amounts = [uint256(0), uint256(0), uint256(0)];
        uint256 depositValue = 0;
        ICurvePool curvePool = ICurvePool(platformAddress);

        for (uint256 i = 0; i < assetsMapped.length; i++) {
            address assetAddress = assetsMapped[i];
            uint256 balance = IERC20(assetAddress).balanceOf(address(this));
            if (balance > 0) {
                uint256 poolCoinIndex = _getPoolCoinIndex(assetAddress);
                _amounts[poolCoinIndex] = balance;
                uint256 assetDecimals = Helpers.getDecimals(assetAddress);
                depositValue = depositValue.add(
                    balance.scaleBy(int8(18 - assetDecimals)).divPrecisely(
                        curvePool.get_virtual_price()
                    )
                );
                emit Deposit(assetAddress, address(platformAddress), balance);
            }
        }

        uint256 minMintAmount = depositValue.mulTruncate(
            uint256(1e18).sub(maxSlippage)
        );
        curvePool.add_liquidity(_amounts, minMintAmount);
        IERC20 pToken = IERC20(assetToPToken[assetsMapped[0]]);
        ICurveGauge(crvGaugeAddress).deposit(
            pToken.balanceOf(address(this)),
            address(this)
        );
    }

    function withdraw(
        address _recipient,
        address _asset,
        uint256 _amount
    ) external onlyVault nonReentrant {

        require(_recipient != address(0), "Invalid recipient");
        require(_amount > 0, "Invalid amount");

        emit Withdrawal(_asset, address(assetToPToken[_asset]), _amount);

        (uint256 contractPTokens, , uint256 totalPTokens) = _getTotalPTokens();

        require(totalPTokens > 0, "Insufficient 3CRV balance");

        uint256 poolCoinIndex = _getPoolCoinIndex(_asset);
        ICurvePool curvePool = ICurvePool(platformAddress);
        uint256 maxAmount = curvePool.calc_withdraw_one_coin(
            totalPTokens,
            int128(poolCoinIndex)
        );

        uint256 withdrawPTokens = totalPTokens.mul(_amount).div(maxAmount);
        if (contractPTokens < withdrawPTokens) {
            ICurveGauge(crvGaugeAddress).withdraw(
                withdrawPTokens.sub(contractPTokens)
            );
        }

        uint256 assetDecimals = Helpers.getDecimals(_asset);
        uint256 minWithdrawAmount = withdrawPTokens
            .mulTruncate(uint256(1e18).sub(maxSlippage))
            .scaleBy(int8(assetDecimals - 18));

        curvePool.remove_liquidity_one_coin(
            withdrawPTokens,
            int128(poolCoinIndex),
            minWithdrawAmount
        );
        IERC20(_asset).safeTransfer(_recipient, _amount);

        uint256 dust = IERC20(_asset).balanceOf(address(this));
        if (dust > 0) {
            IERC20(_asset).safeTransfer(vaultAddress, dust);
        }
    }

    function withdrawAll() external onlyVaultOrGovernor nonReentrant {

        (, uint256 gaugePTokens, uint256 totalPTokens) = _getTotalPTokens();
        ICurveGauge(crvGaugeAddress).withdraw(gaugePTokens);
        uint256[3] memory minWithdrawAmounts = [
            uint256(0),
            uint256(0),
            uint256(0)
        ];
        for (uint256 i = 0; i < assetsMapped.length; i++) {
            address assetAddress = assetsMapped[i];
            uint256 virtualBalance = checkBalance(assetAddress);
            uint256 poolCoinIndex = _getPoolCoinIndex(assetAddress);
            minWithdrawAmounts[poolCoinIndex] = virtualBalance.mulTruncate(
                uint256(1e18).sub(maxSlippage)
            );
        }
        ICurvePool threePool = ICurvePool(platformAddress);
        threePool.remove_liquidity(totalPTokens, minWithdrawAmounts);
        for (uint256 i = 0; i < assetsMapped.length; i++) {
            IERC20 asset = IERC20(threePool.coins(i));
            asset.safeTransfer(vaultAddress, asset.balanceOf(address(this)));
        }
    }

    function checkBalance(address _asset)
        public
        view
        returns (uint256 balance)
    {

        require(assetToPToken[_asset] != address(0), "Unsupported asset");
        (, , uint256 totalPTokens) = _getTotalPTokens();
        ICurvePool curvePool = ICurvePool(platformAddress);

        uint256 pTokenTotalSupply = IERC20(assetToPToken[_asset]).totalSupply();
        if (pTokenTotalSupply > 0) {
            uint256 poolCoinIndex = _getPoolCoinIndex(_asset);
            uint256 curveBalance = curvePool.balances(poolCoinIndex);
            if (curveBalance > 0) {
                balance = totalPTokens.mul(curveBalance).div(pTokenTotalSupply);
            }
        }
    }

    function supportsAsset(address _asset) external view returns (bool) {

        return assetToPToken[_asset] != address(0);
    }

    function safeApproveAllTokens() external {

        for (uint256 i = 0; i < assetsMapped.length; i++) {
            _abstractSetPToken(assetsMapped[i], assetToPToken[assetsMapped[i]]);
        }
    }

    function _getTotalPTokens()
        internal
        view
        returns (
            uint256 contractPTokens,
            uint256 gaugePTokens,
            uint256 totalPTokens
        )
    {

        contractPTokens = IERC20(assetToPToken[assetsMapped[0]]).balanceOf(
            address(this)
        );
        ICurveGauge gauge = ICurveGauge(crvGaugeAddress);
        gaugePTokens = gauge.balanceOf(address(this));
        totalPTokens = contractPTokens.add(gaugePTokens);
    }

    function _abstractSetPToken(address _asset, address _pToken) internal {

        IERC20 asset = IERC20(_asset);
        IERC20 pToken = IERC20(_pToken);
        asset.safeApprove(platformAddress, 0);
        asset.safeApprove(platformAddress, uint256(-1));
        pToken.safeApprove(platformAddress, 0);
        pToken.safeApprove(platformAddress, uint256(-1));
        pToken.safeApprove(crvGaugeAddress, 0);
        pToken.safeApprove(crvGaugeAddress, uint256(-1));
    }

    function _getPoolCoinIndex(address _asset) internal view returns (uint256) {

        for (uint256 i = 0; i < 3; i++) {
            if (assetsMapped[i] == _asset) return i;
        }
        revert("Invalid 3pool asset");
    }
}