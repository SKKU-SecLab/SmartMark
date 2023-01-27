
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IIntegrationManager {
    enum SpendAssetsHandleType {None, Approve, Transfer}
}// GPL-3.0


pragma solidity 0.6.12;


interface IIntegrationAdapter {
    function parseAssetsForAction(
        address _vaultProxy,
        bytes4 _selector,
        bytes calldata _encodedCallArgs
    )
        external
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        );
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveAddressProvider {
    function get_address(uint256) external view returns (address);

    function get_registry() external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveRegistry {
    function get_coins(address) external view returns (address[8] memory);

    function get_gauges(address) external view returns (address[10] memory, int128[10] memory);

    function get_lp_token(address) external view returns (address);

    function get_pool_from_lp_token(address) external view returns (address);

    function get_underlying_coins(address) external view returns (address[8] memory);
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveMinter {
    function mint_for(address, address) external;
}// GPL-3.0


pragma solidity 0.6.12;

library AddressArrayLib {

    function removeStorageItem(address[] storage _self, address _itemToRemove)
        internal
        returns (bool removed_)
    {
        uint256 itemCount = _self.length;
        for (uint256 i; i < itemCount; i++) {
            if (_self[i] == _itemToRemove) {
                if (i < itemCount - 1) {
                    _self[i] = _self[itemCount - 1];
                }
                _self.pop();
                removed_ = true;
                break;
            }
        }

        return removed_;
    }


    function addItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        nextArray_ = new address[](_self.length + 1);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        nextArray_[_self.length] = _itemToAdd;

        return nextArray_;
    }

    function addUniqueItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (contains(_self, _itemToAdd)) {
            return _self;
        }

        return addItem(_self, _itemToAdd);
    }

    function contains(address[] memory _self, address _target)
        internal
        pure
        returns (bool doesContain_)
    {
        for (uint256 i; i < _self.length; i++) {
            if (_target == _self[i]) {
                return true;
            }
        }
        return false;
    }

    function mergeArray(address[] memory _self, address[] memory _arrayToMerge)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        uint256 newUniqueItemCount;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                newUniqueItemCount++;
            }
        }

        if (newUniqueItemCount == 0) {
            return _self;
        }

        nextArray_ = new address[](_self.length + newUniqueItemCount);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        uint256 nextArrayIndex = _self.length;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                nextArray_[nextArrayIndex] = _arrayToMerge[i];
                nextArrayIndex++;
            }
        }

        return nextArray_;
    }

    function isUniqueSet(address[] memory _self) internal pure returns (bool isUnique_) {
        if (_self.length <= 1) {
            return true;
        }

        uint256 arrayLength = _self.length;
        for (uint256 i; i < arrayLength; i++) {
            for (uint256 j = i + 1; j < arrayLength; j++) {
                if (_self[i] == _self[j]) {
                    return false;
                }
            }
        }

        return true;
    }

    function removeItems(address[] memory _self, address[] memory _itemsToRemove)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (_itemsToRemove.length == 0) {
            return _self;
        }

        bool[] memory indexesToRemove = new bool[](_self.length);
        uint256 remainingItemsCount = _self.length;
        for (uint256 i; i < _self.length; i++) {
            if (contains(_itemsToRemove, _self[i])) {
                indexesToRemove[i] = true;
                remainingItemsCount--;
            }
        }

        if (remainingItemsCount == _self.length) {
            nextArray_ = _self;
        } else if (remainingItemsCount > 0) {
            nextArray_ = new address[](remainingItemsCount);
            uint256 nextArrayIndex;
            for (uint256 i; i < _self.length; i++) {
                if (!indexesToRemove[i]) {
                    nextArray_[nextArrayIndex] = _self[i];
                    nextArrayIndex++;
                }
            }
        }

        return nextArray_;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveLiquidityGaugeV2 {
    function claim_rewards(address) external;

    function deposit(uint256, address) external;

    function reward_tokens(uint256) external view returns (address);

    function withdraw(uint256) external;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AssetHelpers {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    function __approveAssetMaxAsNeeded(
        address _asset,
        address _target,
        uint256 _neededAmount
    ) internal {
        uint256 allowance = ERC20(_asset).allowance(address(this), _target);
        if (allowance < _neededAmount) {
            if (allowance > 0) {
                ERC20(_asset).safeApprove(_target, 0);
            }
            ERC20(_asset).safeApprove(_target, type(uint256).max);
        }
    }

    function __pushFullAssetBalances(address _target, address[] memory _assets)
        internal
        returns (uint256[] memory amountsTransferred_)
    {
        amountsTransferred_ = new uint256[](_assets.length);
        for (uint256 i; i < _assets.length; i++) {
            ERC20 assetContract = ERC20(_assets[i]);
            amountsTransferred_[i] = assetContract.balanceOf(address(this));
            if (amountsTransferred_[i] > 0) {
                assetContract.safeTransfer(_target, amountsTransferred_[i]);
            }
        }

        return amountsTransferred_;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract CurveGaugeV2ActionsMixin is AssetHelpers {
    uint256 private constant CURVE_GAUGE_V2_MAX_REWARDS = 8;

    function __curveGaugeV2ClaimRewards(address _gauge, address _target) internal {
        ICurveLiquidityGaugeV2(_gauge).claim_rewards(_target);
    }

    function __curveGaugeV2GetRewardsTokens(address _gauge)
        internal
        view
        returns (address[] memory rewardsTokens_)
    {
        address[] memory lpRewardsTokensWithEmpties = new address[](CURVE_GAUGE_V2_MAX_REWARDS);
        uint256 rewardsTokensCount;
        for (uint256 i; i < CURVE_GAUGE_V2_MAX_REWARDS; i++) {
            address rewardToken = ICurveLiquidityGaugeV2(_gauge).reward_tokens(i);
            if (rewardToken != address(0)) {
                lpRewardsTokensWithEmpties[i] = rewardToken;
                rewardsTokensCount++;
            } else {
                break;
            }
        }

        rewardsTokens_ = new address[](rewardsTokensCount);
        for (uint256 i; i < rewardsTokensCount; i++) {
            rewardsTokens_[i] = lpRewardsTokensWithEmpties[i];
        }

        return rewardsTokens_;
    }

    function __curveGaugeV2Stake(
        address _gauge,
        address _lpToken,
        uint256 _amount
    ) internal {
        __approveAssetMaxAsNeeded(_lpToken, _gauge, _amount);
        ICurveLiquidityGaugeV2(_gauge).deposit(_amount, address(this));
    }

    function __curveGaugeV2Unstake(address _gauge, uint256 _amount) internal {
        ICurveLiquidityGaugeV2(_gauge).withdraw(_amount);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract CurveGaugeV2RewardsHandlerMixin is CurveGaugeV2ActionsMixin {
    using AddressArrayLib for address[];

    address private immutable CURVE_GAUGE_V2_REWARDS_HANDLER_CRV_TOKEN;
    address private immutable CURVE_GAUGE_V2_REWARDS_HANDLER_MINTER;

    constructor(address _minter, address _crvToken) public {
        CURVE_GAUGE_V2_REWARDS_HANDLER_CRV_TOKEN = _crvToken;
        CURVE_GAUGE_V2_REWARDS_HANDLER_MINTER = _minter;
    }

    function __curveGaugeV2ClaimAllRewards(address _gauge, address _target) internal {
        ICurveMinter(CURVE_GAUGE_V2_REWARDS_HANDLER_MINTER).mint_for(_gauge, _target);

        __curveGaugeV2ClaimRewards(_gauge, _target);
    }

    function __curveGaugeV2GetRewardsTokensWithCrv(address _gauge)
        internal
        view
        returns (address[] memory rewardsTokens_)
    {
        return
            __curveGaugeV2GetRewardsTokens(_gauge).addUniqueItem(
                CURVE_GAUGE_V2_REWARDS_HANDLER_CRV_TOKEN
            );
    }


    function getCurveGaugeV2RewardsHandlerCrvToken() public view returns (address crvToken_) {
        return CURVE_GAUGE_V2_REWARDS_HANDLER_CRV_TOKEN;
    }

    function getCurveGaugeV2RewardsHandlerMinter() public view returns (address minter_) {
        return CURVE_GAUGE_V2_REWARDS_HANDLER_MINTER;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract CurveLiquidityActionsMixin is AssetHelpers {
    using Strings for uint256;

    uint256 private constant ASSET_APPROVAL_TOP_UP_THRESHOLD = 1e76; // Arbitrary, slightly less than 1/11 of max uint256

    bytes4 private constant CURVE_REMOVE_LIQUIDITY_ONE_COIN_SELECTOR = 0x1a4d01d2;
    bytes4 private constant CURVE_REMOVE_LIQUIDITY_ONE_COIN_USE_UNDERLYINGS_SELECTOR = 0x517a55a3;

    address private immutable CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET;

    constructor(address _wrappedNativeAsset) public {
        CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET = _wrappedNativeAsset;
    }

    function __curveAddLiquidity(
        address _pool,
        address[] memory _squashedOutgoingAssets,
        uint256[] memory _orderedOutgoingAssetAmounts,
        uint256 _minIncomingLpTokenAmount,
        bool _useUnderlyings
    ) internal {
        uint256 outgoingNativeAssetAmount;
        for (uint256 i; i < _squashedOutgoingAssets.length; i++) {
            if (_squashedOutgoingAssets[i] == getCurveLiquidityWrappedNativeAsset()) {
                outgoingNativeAssetAmount = ERC20(getCurveLiquidityWrappedNativeAsset()).balanceOf(
                    address(this)
                );
                IWETH(getCurveLiquidityWrappedNativeAsset()).withdraw(outgoingNativeAssetAmount);
            } else {
                __approveAssetMaxAsNeeded(
                    _squashedOutgoingAssets[i],
                    _pool,
                    ASSET_APPROVAL_TOP_UP_THRESHOLD
                );
            }
        }

        (bool success, bytes memory returnData) = _pool.call{value: outgoingNativeAssetAmount}(
            __curveAddLiquidityEncodeCalldata(
                _orderedOutgoingAssetAmounts,
                _minIncomingLpTokenAmount,
                _useUnderlyings
            )
        );
        require(success, string(returnData));
    }

    function __curveRemoveLiquidity(
        address _pool,
        uint256 _outgoingLpTokenAmount,
        uint256[] memory _orderedMinIncomingAssetAmounts,
        bool _useUnderlyings
    ) internal {
        (bool success, bytes memory returnData) = _pool.call(
            __curveRemoveLiquidityEncodeCalldata(
                _outgoingLpTokenAmount,
                _orderedMinIncomingAssetAmounts,
                _useUnderlyings
            )
        );
        require(success, string(returnData));

        __curveLiquidityWrapNativeAssetBalance();
    }

    function __curveRemoveLiquidityOneCoin(
        address _pool,
        uint256 _outgoingLpTokenAmount,
        int128 _incomingAssetPoolIndex,
        uint256 _minIncomingAssetAmount,
        bool _useUnderlyings
    ) internal {
        bytes memory callData;
        if (_useUnderlyings) {
            callData = abi.encodeWithSelector(
                CURVE_REMOVE_LIQUIDITY_ONE_COIN_USE_UNDERLYINGS_SELECTOR,
                _outgoingLpTokenAmount,
                _incomingAssetPoolIndex,
                _minIncomingAssetAmount,
                true
            );
        } else {
            callData = abi.encodeWithSelector(
                CURVE_REMOVE_LIQUIDITY_ONE_COIN_SELECTOR,
                _outgoingLpTokenAmount,
                _incomingAssetPoolIndex,
                _minIncomingAssetAmount
            );
        }

        (bool success, bytes memory returnData) = _pool.call(callData);
        require(success, string(returnData));

        __curveLiquidityWrapNativeAssetBalance();
    }


    function __curveAddLiquidityEncodeCalldata(
        uint256[] memory _orderedOutgoingAssetAmounts,
        uint256 _minIncomingLpTokenAmount,
        bool _useUnderlyings
    ) private pure returns (bytes memory callData_) {
        bytes memory finalEncodedArgOrEmpty;
        if (_useUnderlyings) {
            finalEncodedArgOrEmpty = abi.encode(true);
        }

        return
            abi.encodePacked(
                __curveAddLiquidityEncodeSelector(
                    _orderedOutgoingAssetAmounts.length,
                    _useUnderlyings
                ),
                abi.encodePacked(_orderedOutgoingAssetAmounts),
                _minIncomingLpTokenAmount,
                finalEncodedArgOrEmpty
            );
    }

    function __curveAddLiquidityEncodeSelector(uint256 _numberOfCoins, bool _useUnderlyings)
        private
        pure
        returns (bytes4 selector_)
    {
        string memory finalArgOrEmpty;
        if (_useUnderlyings) {
            finalArgOrEmpty = ",bool";
        }

        return
            bytes4(
                keccak256(
                    abi.encodePacked(
                        "add_liquidity(uint256[",
                        _numberOfCoins.toString(),
                        "],",
                        "uint256",
                        finalArgOrEmpty,
                        ")"
                    )
                )
            );
    }

    function __curveLiquidityWrapNativeAssetBalance() private {
        uint256 nativeAssetBalance = payable(address(this)).balance;
        if (nativeAssetBalance > 0) {
            IWETH(payable(getCurveLiquidityWrappedNativeAsset())).deposit{
                value: nativeAssetBalance
            }();
        }
    }

    function __curveRemoveLiquidityEncodeCalldata(
        uint256 _outgoingLpTokenAmount,
        uint256[] memory _orderedMinIncomingAssetAmounts,
        bool _useUnderlyings
    ) private pure returns (bytes memory callData_) {
        bytes memory finalEncodedArgOrEmpty;
        if (_useUnderlyings) {
            finalEncodedArgOrEmpty = abi.encode(true);
        }

        return
            abi.encodePacked(
                __curveRemoveLiquidityEncodeSelector(
                    _orderedMinIncomingAssetAmounts.length,
                    _useUnderlyings
                ),
                _outgoingLpTokenAmount,
                abi.encodePacked(_orderedMinIncomingAssetAmounts),
                finalEncodedArgOrEmpty
            );
    }

    function __curveRemoveLiquidityEncodeSelector(uint256 _numberOfCoins, bool _useUnderlyings)
        private
        pure
        returns (bytes4 selector_)
    {
        string memory finalArgOrEmpty;
        if (_useUnderlyings) {
            finalArgOrEmpty = ",bool";
        }

        return
            bytes4(
                keccak256(
                    abi.encodePacked(
                        "remove_liquidity(uint256,",
                        "uint256[",
                        _numberOfCoins.toString(),
                        "]",
                        finalArgOrEmpty,
                        ")"
                    )
                )
            );
    }


    function getCurveLiquidityWrappedNativeAsset() public view returns (address addressProvider_) {
        return CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET;
    }
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract IntegrationSelectors {
    bytes4 public constant TAKE_ORDER_SELECTOR = bytes4(
        keccak256("takeOrder(address,bytes,bytes)")
    );

    bytes4 public constant LEND_SELECTOR = bytes4(keccak256("lend(address,bytes,bytes)"));
    bytes4 public constant REDEEM_SELECTOR = bytes4(keccak256("redeem(address,bytes,bytes)"));

    bytes4 public constant STAKE_SELECTOR = bytes4(keccak256("stake(address,bytes,bytes)"));
    bytes4 public constant UNSTAKE_SELECTOR = bytes4(keccak256("unstake(address,bytes,bytes)"));

    bytes4 public constant CLAIM_REWARDS_SELECTOR = bytes4(
        keccak256("claimRewards(address,bytes,bytes)")
    );

    bytes4 public constant LEND_AND_STAKE_SELECTOR = bytes4(
        keccak256("lendAndStake(address,bytes,bytes)")
    );
    bytes4 public constant UNSTAKE_AND_REDEEM_SELECTOR = bytes4(
        keccak256("unstakeAndRedeem(address,bytes,bytes)")
    );
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AdapterBase is IIntegrationAdapter, IntegrationSelectors, AssetHelpers {
    using SafeERC20 for ERC20;

    address internal immutable INTEGRATION_MANAGER;

    modifier postActionIncomingAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _assetData
    ) {
        _;

        (, , address[] memory incomingAssets) = __decodeAssetData(_assetData);

        __pushFullAssetBalances(_vaultProxy, incomingAssets);
    }

    modifier postActionSpendAssetsTransferHandler(address _vaultProxy, bytes memory _assetData) {
        _;

        (address[] memory spendAssets, , ) = __decodeAssetData(_assetData);

        __pushFullAssetBalances(_vaultProxy, spendAssets);
    }

    modifier onlyIntegrationManager {
        require(
            msg.sender == INTEGRATION_MANAGER,
            "Only the IntegrationManager can call this function"
        );
        _;
    }

    constructor(address _integrationManager) public {
        INTEGRATION_MANAGER = _integrationManager;
    }


    function __decodeAssetData(bytes memory _assetData)
        internal
        pure
        returns (
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_
        )
    {
        return abi.decode(_assetData, (address[], uint256[], address[]));
    }


    function getIntegrationManager() external view returns (address integrationManager_) {
        return INTEGRATION_MANAGER;
    }
}// GPL-3.0
pragma solidity 0.6.12;


abstract contract CurveLiquidityAdapterBase is AdapterBase, CurveLiquidityActionsMixin {
    enum RedeemType {Standard, OneCoin}

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address private immutable ADDRESS_PROVIDER;

    constructor(
        address _integrationManager,
        address _addressProvider,
        address _wrappedNativeAsset
    ) public AdapterBase(_integrationManager) CurveLiquidityActionsMixin(_wrappedNativeAsset) {
        ADDRESS_PROVIDER = _addressProvider;
    }

    receive() external payable {}


    function __castWrappedIfNativeAsset(address _tokenOrNativeAsset)
        internal
        view
        returns (address token_)
    {
        if (_tokenOrNativeAsset == ETH_ADDRESS) {
            return getCurveLiquidityWrappedNativeAsset();
        }

        return _tokenOrNativeAsset;
    }

    function __curveRedeem(
        address _pool,
        uint256 _outgoingLpTokenAmount,
        bool _useUnderlyings,
        RedeemType _redeemType,
        bytes memory _incomingAssetsData
    ) internal {
        if (_redeemType == RedeemType.OneCoin) {
            (
                uint256 incomingAssetPoolIndex,
                uint256 minIncomingAssetAmount
            ) = __decodeIncomingAssetsDataRedeemOneCoin(_incomingAssetsData);

            __curveRemoveLiquidityOneCoin(
                _pool,
                _outgoingLpTokenAmount,
                int128(incomingAssetPoolIndex),
                minIncomingAssetAmount,
                _useUnderlyings
            );
        } else {
            __curveRemoveLiquidity(
                _pool,
                _outgoingLpTokenAmount,
                __decodeIncomingAssetsDataRedeemStandard(_incomingAssetsData),
                _useUnderlyings
            );
        }
    }

    function __parseIncomingAssetsForRedemptionCalls(
        address _curveRegistry,
        address _pool,
        bool _useUnderlyings,
        RedeemType _redeemType,
        bytes memory _incomingAssetsData
    )
        internal
        view
        returns (address[] memory incomingAssets_, uint256[] memory minIncomingAssetAmounts_)
    {
        address[8] memory canonicalPoolAssets;
        if (_useUnderlyings) {
            canonicalPoolAssets = ICurveRegistry(_curveRegistry).get_underlying_coins(_pool);
        } else {
            canonicalPoolAssets = ICurveRegistry(_curveRegistry).get_coins(_pool);
        }

        if (_redeemType == RedeemType.OneCoin) {
            (
                uint256 incomingAssetPoolIndex,
                uint256 minIncomingAssetAmount
            ) = __decodeIncomingAssetsDataRedeemOneCoin(_incomingAssetsData);

            incomingAssets_ = new address[](1);
            incomingAssets_[0] = __castWrappedIfNativeAsset(
                canonicalPoolAssets[incomingAssetPoolIndex]
            );

            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minIncomingAssetAmount;
        } else {
            minIncomingAssetAmounts_ = __decodeIncomingAssetsDataRedeemStandard(
                _incomingAssetsData
            );

            incomingAssets_ = new address[](minIncomingAssetAmounts_.length);
            for (uint256 i; i < incomingAssets_.length; i++) {
                incomingAssets_[i] = __castWrappedIfNativeAsset(canonicalPoolAssets[i]);
            }
        }

        return (incomingAssets_, minIncomingAssetAmounts_);
    }

    function __parseSpendAssetsForLendingCalls(
        address _curveRegistry,
        address _pool,
        uint256[] memory _orderedOutgoingAssetAmounts,
        bool _useUnderlyings
    ) internal view returns (address[] memory spendAssets_, uint256[] memory spendAssetAmounts_) {
        address[8] memory canonicalPoolAssets;
        if (_useUnderlyings) {
            canonicalPoolAssets = ICurveRegistry(_curveRegistry).get_underlying_coins(_pool);
        } else {
            canonicalPoolAssets = ICurveRegistry(_curveRegistry).get_coins(_pool);
        }

        uint256 spendAssetsCount;
        for (uint256 i; i < _orderedOutgoingAssetAmounts.length; i++) {
            if (_orderedOutgoingAssetAmounts[i] > 0) {
                spendAssetsCount++;
            }
        }

        spendAssets_ = new address[](spendAssetsCount);
        spendAssetAmounts_ = new uint256[](spendAssetsCount);
        uint256 spendAssetsIndex;
        for (uint256 i; i < _orderedOutgoingAssetAmounts.length; i++) {
            if (_orderedOutgoingAssetAmounts[i] > 0) {
                spendAssets_[spendAssetsIndex] = __castWrappedIfNativeAsset(
                    canonicalPoolAssets[i]
                );
                spendAssetAmounts_[spendAssetsIndex] = _orderedOutgoingAssetAmounts[i];
                spendAssetsIndex++;

                if (spendAssetsIndex == spendAssetsCount) {
                    break;
                }
            }
        }

        return (spendAssets_, spendAssetAmounts_);
    }



    function __decodeClaimRewardsCallArgs(bytes memory _actionData)
        internal
        pure
        returns (address stakingToken_)
    {
        return abi.decode(_actionData, (address));
    }

    function __decodeLendAndStakeCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            uint256[] memory orderedOutgoingAssetAmounts_,
            address incomingStakingToken_,
            uint256 minIncomingStakingTokenAmount_,
            bool useUnderlyings_
        )
    {
        return abi.decode(_actionData, (address, uint256[], address, uint256, bool));
    }

    function __decodeLendCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            uint256[] memory orderedOutgoingAssetAmounts_,
            uint256 minIncomingLpTokenAmount_,
            bool useUnderlyings_
        )
    {
        return abi.decode(_actionData, (address, uint256[], uint256, bool));
    }

    function __decodeRedeemCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            uint256 outgoingLpTokenAmount_,
            bool useUnderlyings_,
            RedeemType redeemType_,
            bytes memory incomingAssetsData_
        )
    {
        return abi.decode(_actionData, (address, uint256, bool, RedeemType, bytes));
    }

    function __decodeIncomingAssetsDataRedeemOneCoin(bytes memory _incomingAssetsData)
        internal
        pure
        returns (uint256 incomingAssetPoolIndex_, uint256 minIncomingAssetAmount_)
    {
        return abi.decode(_incomingAssetsData, (uint256, uint256));
    }

    function __decodeIncomingAssetsDataRedeemStandard(bytes memory _incomingAssetsData)
        internal
        pure
        returns (uint256[] memory orderedMinIncomingAssetAmounts_)
    {
        return abi.decode(_incomingAssetsData, (uint256[]));
    }

    function __decodeStakeCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            address incomingStakingToken_,
            uint256 amount_
        )
    {
        return abi.decode(_actionData, (address, address, uint256));
    }

    function __decodeUnstakeAndRedeemCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            address outgoingStakingToken_,
            uint256 outgoingStakingTokenAmount_,
            bool useUnderlyings_,
            RedeemType redeemType_,
            bytes memory incomingAssetsData_
        )
    {
        return abi.decode(_actionData, (address, address, uint256, bool, RedeemType, bytes));
    }

    function __decodeUnstakeCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            address outgoingStakingToken_,
            uint256 amount_
        )
    {
        return abi.decode(_actionData, (address, address, uint256));
    }


    function getAddressProvider() public view returns (address addressProvider_) {
        return ADDRESS_PROVIDER;
    }
}// GPL-3.0
pragma solidity 0.6.12;


contract CurveLiquidityAdapter is CurveLiquidityAdapterBase, CurveGaugeV2RewardsHandlerMixin {
    constructor(
        address _integrationManager,
        address _curveAddressProvider,
        address _wrappedNativeAsset,
        address _curveMinter,
        address _crvToken
    )
        public
        CurveLiquidityAdapterBase(_integrationManager, _curveAddressProvider, _wrappedNativeAsset)
        CurveGaugeV2RewardsHandlerMixin(_curveMinter, _crvToken)
    {}


    function claimRewards(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata
    ) external onlyIntegrationManager {
        __curveGaugeV2ClaimAllRewards(__decodeClaimRewardsCallArgs(_actionData), _vaultProxy);
    }

    function lend(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (
            address pool,
            uint256[] memory orderedOutgoingAssetAmounts,
            uint256 minIncomingLpTokenAmount,
            bool useUnderlyings
        ) = __decodeLendCallArgs(_actionData);
        (address[] memory spendAssets, , ) = __decodeAssetData(_assetData);

        __curveAddLiquidity(
            pool,
            spendAssets,
            orderedOutgoingAssetAmounts,
            minIncomingLpTokenAmount,
            useUnderlyings
        );
    }

    function lendAndStake(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (
            address pool,
            uint256[] memory orderedOutgoingAssetAmounts,
            address incomingStakingToken,
            uint256 minIncomingStakingTokenAmount,
            bool useUnderlyings
        ) = __decodeLendAndStakeCallArgs(_actionData);
        (address[] memory spendAssets, , ) = __decodeAssetData(_assetData);

        address lpToken = ICurveRegistry(
            ICurveAddressProvider(getAddressProvider()).get_registry()
        )
            .get_lp_token(pool);

        __curveAddLiquidity(
            pool,
            spendAssets,
            orderedOutgoingAssetAmounts,
            minIncomingStakingTokenAmount,
            useUnderlyings
        );

        __curveGaugeV2Stake(
            incomingStakingToken,
            lpToken,
            ERC20(lpToken).balanceOf(address(this))
        );
    }

    function redeem(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (
            address pool,
            uint256 outgoingLpTokenAmount,
            bool useUnderlyings,
            RedeemType redeemType,
            bytes memory incomingAssetsData
        ) = __decodeRedeemCallArgs(_actionData);

        __curveRedeem(pool, outgoingLpTokenAmount, useUnderlyings, redeemType, incomingAssetsData);
    }

    function stake(
        address _vaultProxy,
        bytes calldata,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts,
            address[] memory incomingAssets
        ) = __decodeAssetData(_assetData);

        __curveGaugeV2Stake(incomingAssets[0], spendAssets[0], spendAssetAmounts[0]);
    }

    function unstake(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (, address outgoingStakingToken, uint256 amount) = __decodeUnstakeCallArgs(_actionData);

        __curveGaugeV2Unstake(outgoingStakingToken, amount);
    }

    function unstakeAndRedeem(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (
            address pool,
            address outgoingStakingToken,
            uint256 outgoingStakingTokenAmount,
            bool useUnderlyings,
            RedeemType redeemType,
            bytes memory incomingAssetsData
        ) = __decodeUnstakeAndRedeemCallArgs(_actionData);

        __curveGaugeV2Unstake(outgoingStakingToken, outgoingStakingTokenAmount);

        __curveRedeem(
            pool,
            outgoingStakingTokenAmount,
            useUnderlyings,
            redeemType,
            incomingAssetsData
        );
    }


    function parseAssetsForAction(
        address,
        bytes4 _selector,
        bytes calldata _actionData
    )
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        if (_selector == CLAIM_REWARDS_SELECTOR) {
            return __parseAssetsForClaimRewards();
        } else if (_selector == LEND_SELECTOR) {
            return __parseAssetsForLend(_actionData);
        } else if (_selector == LEND_AND_STAKE_SELECTOR) {
            return __parseAssetsForLendAndStake(_actionData);
        } else if (_selector == REDEEM_SELECTOR) {
            return __parseAssetsForRedeem(_actionData);
        } else if (_selector == STAKE_SELECTOR) {
            return __parseAssetsForStake(_actionData);
        } else if (_selector == UNSTAKE_SELECTOR) {
            return __parseAssetsForUnstake(_actionData);
        } else if (_selector == UNSTAKE_AND_REDEEM_SELECTOR) {
            return __parseAssetsForUnstakeAndRedeem(_actionData);
        }

        revert("parseAssetsForAction: _selector invalid");
    }

    function __parseAssetsForClaimRewards()
        private
        pure
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        return (
            IIntegrationManager.SpendAssetsHandleType.None,
            new address[](0),
            new uint256[](0),
            new address[](0),
            new uint256[](0)
        );
    }

    function __parseAssetsForLend(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            address pool,
            uint256[] memory orderedOutgoingAssetAmounts,
            uint256 minIncomingLpTokenAmount,
            bool useUnderlyings
        ) = __decodeLendCallArgs(_actionData);

        address curveRegistry = ICurveAddressProvider(getAddressProvider()).get_registry();

        address lpToken = ICurveRegistry(curveRegistry).get_lp_token(pool);
        require(lpToken != address(0), "__parseAssetsForLend: Invalid pool");

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = lpToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingLpTokenAmount;

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForLendingCalls(
            curveRegistry,
            pool,
            orderedOutgoingAssetAmounts,
            useUnderlyings
        );

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForLendAndStake(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            address pool,
            uint256[] memory orderedOutgoingAssetAmounts,
            address incomingStakingToken,
            uint256 minIncomingStakingTokenAmount,
            bool useUnderlyings
        ) = __decodeLendAndStakeCallArgs(_actionData);

        address curveRegistry = ICurveAddressProvider(getAddressProvider()).get_registry();

        __validateGauge(curveRegistry, pool, incomingStakingToken);

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForLendingCalls(
            curveRegistry,
            pool,
            orderedOutgoingAssetAmounts,
            useUnderlyings
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingStakingToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingStakingTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForRedeem(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            address pool,
            uint256 outgoingLpTokenAmount,
            bool useUnderlyings,
            RedeemType redeemType,
            bytes memory incomingAssetsData
        ) = __decodeRedeemCallArgs(_actionData);

        address curveRegistry = ICurveAddressProvider(getAddressProvider()).get_registry();
        address lpToken = ICurveRegistry(curveRegistry).get_lp_token(pool);
        require(lpToken != address(0), "__parseAssetsForRedeem: Invalid pool");

        spendAssets_ = new address[](1);
        spendAssets_[0] = lpToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingLpTokenAmount;

        (incomingAssets_, minIncomingAssetAmounts_) = __parseIncomingAssetsForRedemptionCalls(
            curveRegistry,
            pool,
            useUnderlyings,
            redeemType,
            incomingAssetsData
        );

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForStake(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (address pool, address incomingStakingToken, uint256 amount) = __decodeStakeCallArgs(
            _actionData
        );

        address curveRegistry = ICurveAddressProvider(getAddressProvider()).get_registry();
        address lpToken = ICurveRegistry(curveRegistry).get_lp_token(pool);

        __validateGauge(curveRegistry, pool, incomingStakingToken);

        spendAssets_ = new address[](1);
        spendAssets_[0] = lpToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = amount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingStakingToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = amount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForUnstake(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (address pool, address outgoingStakingToken, uint256 amount) = __decodeUnstakeCallArgs(
            _actionData
        );

        address curveRegistry = ICurveAddressProvider(getAddressProvider()).get_registry();
        address lpToken = ICurveRegistry(curveRegistry).get_lp_token(pool);

        __validateGauge(curveRegistry, pool, outgoingStakingToken);

        spendAssets_ = new address[](1);
        spendAssets_[0] = outgoingStakingToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = amount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = lpToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = amount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForUnstakeAndRedeem(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            address pool,
            address outgoingStakingToken,
            uint256 outgoingStakingTokenAmount,
            bool useUnderlyings,
            RedeemType redeemType,
            bytes memory incomingAssetsData
        ) = __decodeUnstakeAndRedeemCallArgs(_actionData);

        address curveRegistry = ICurveAddressProvider(getAddressProvider()).get_registry();

        __validateGauge(curveRegistry, pool, outgoingStakingToken);

        spendAssets_ = new address[](1);
        spendAssets_[0] = outgoingStakingToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingStakingTokenAmount;

        (incomingAssets_, minIncomingAssetAmounts_) = __parseIncomingAssetsForRedemptionCalls(
            curveRegistry,
            pool,
            useUnderlyings,
            redeemType,
            incomingAssetsData
        );

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __validateGauge(
        address _curveRegistry,
        address _pool,
        address _gauge
    ) private view {
        require(_gauge != address(0), "__validateGauge: Empty gauge");
        (address[10] memory gauges, ) = ICurveRegistry(_curveRegistry).get_gauges(_pool);
        bool isValid;
        for (uint256 i; i < gauges.length; i++) {
            if (_gauge == gauges[i]) {
                isValid = true;
                break;
            }
        }
        require(isValid, "__validateGauge: Invalid gauge");
    }
}