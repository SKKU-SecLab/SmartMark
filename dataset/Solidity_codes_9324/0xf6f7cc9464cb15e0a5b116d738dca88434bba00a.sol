
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
}// GPL-3.0


pragma solidity 0.6.12;

interface IIntegrationManager {
    enum SpendAssetsHandleType {None, Approve, Transfer, Remove}
}// GPL-3.0


pragma solidity 0.6.12;


interface IIntegrationAdapter {
    function identifier() external pure returns (string memory identifier_);

    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
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

interface ICurveStableSwapAave {
    function add_liquidity(
        uint256[3] calldata,
        uint256,
        bool
    ) external returns (uint256);

    function remove_liquidity(
        uint256,
        uint256[3] calldata,
        bool
    ) external returns (uint256[3] memory);

    function remove_liquidity_one_coin(
        uint256,
        int128,
        uint256,
        bool
    ) external returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract CurveAaveLiquidityActionsMixin {
    using SafeERC20 for ERC20;

    address private immutable CURVE_AAVE_LIQUIDITY_POOL;

    constructor(
        address _pool,
        address[3] memory _aaveTokensToApprove,
        address[3] memory _underlyingTokensToApprove
    ) public {
        CURVE_AAVE_LIQUIDITY_POOL = _pool;

        for (uint256 i; i < 3; i++) {
            if (_aaveTokensToApprove[i] != address(0)) {
                ERC20(_aaveTokensToApprove[i]).safeApprove(_pool, type(uint256).max);
            }
            if (_underlyingTokensToApprove[i] != address(0)) {
                ERC20(_underlyingTokensToApprove[i]).safeApprove(_pool, type(uint256).max);
            }
        }
    }

    function __curveAaveLend(
        uint256[3] memory _orderedOutgoingAssetAmounts,
        uint256 _minIncomingLPTokenAmount,
        bool _useUnderlyings
    ) internal {
        ICurveStableSwapAave(CURVE_AAVE_LIQUIDITY_POOL).add_liquidity(
            _orderedOutgoingAssetAmounts,
            _minIncomingLPTokenAmount,
            _useUnderlyings
        );
    }

    function __curveAaveRedeem(
        uint256 _outgoingLPTokenAmount,
        uint256[3] memory _orderedMinIncomingAssetAmounts,
        bool _redeemSingleAsset,
        bool _useUnderlyings
    ) internal {
        if (_redeemSingleAsset) {
            for (uint256 i; i < _orderedMinIncomingAssetAmounts.length; i++) {
                if (_orderedMinIncomingAssetAmounts[i] > 0) {
                    ICurveStableSwapAave(CURVE_AAVE_LIQUIDITY_POOL).remove_liquidity_one_coin(
                        _outgoingLPTokenAmount,
                        int128(i),
                        _orderedMinIncomingAssetAmounts[i],
                        _useUnderlyings
                    );
                    return;
                }
            }
        } else {
            ICurveStableSwapAave(CURVE_AAVE_LIQUIDITY_POOL).remove_liquidity(
                _outgoingLPTokenAmount,
                _orderedMinIncomingAssetAmounts,
                _useUnderlyings
            );
        }
    }


    function getCurveAaveLiquidityPool() public view returns (address pool_) {
        return CURVE_AAVE_LIQUIDITY_POOL;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveMinter {
    function mint_for(address, address) external;
}// GPL-3.0


pragma solidity 0.6.12;

library AddressArrayLib {
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

    function fill(address[] memory _self, address _value)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        nextArray_ = new address[](_self.length);
        for (uint256 i; i < nextArray_.length; i++) {
            nextArray_[i] = _value;
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
        if (ERC20(_asset).allowance(address(this), _target) < _neededAmount) {
            ERC20(_asset).safeApprove(_target, type(uint256).max);
        }
    }

    function __getAssetBalances(address _target, address[] memory _assets)
        internal
        view
        returns (uint256[] memory balances_)
    {
        balances_ = new uint256[](_assets.length);
        for (uint256 i; i < _assets.length; i++) {
            balances_[i] = ERC20(_assets[i]).balanceOf(_target);
        }

        return balances_;
    }

    function __pullFullAssetBalances(address _target, address[] memory _assets)
        internal
        returns (uint256[] memory amountsTransferred_)
    {
        amountsTransferred_ = new uint256[](_assets.length);
        for (uint256 i; i < _assets.length; i++) {
            ERC20 assetContract = ERC20(_assets[i]);
            amountsTransferred_[i] = assetContract.balanceOf(_target);
            if (amountsTransferred_[i] > 0) {
                assetContract.safeTransferFrom(_target, address(this), amountsTransferred_[i]);
            }
        }

        return amountsTransferred_;
    }

    function __pullPartialAssetBalances(
        address _target,
        address[] memory _assets,
        uint256[] memory _amountsToExclude
    ) internal returns (uint256[] memory amountsTransferred_) {
        amountsTransferred_ = new uint256[](_assets.length);
        for (uint256 i; i < _assets.length; i++) {
            ERC20 assetContract = ERC20(_assets[i]);
            amountsTransferred_[i] = assetContract.balanceOf(_target).sub(_amountsToExclude[i]);
            if (amountsTransferred_[i] > 0) {
                assetContract.safeTransferFrom(_target, address(this), amountsTransferred_[i]);
            }
        }

        return amountsTransferred_;
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


abstract contract CurveGaugeV2RewardsHandlerBase is CurveGaugeV2ActionsMixin {
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

    function __curveGaugeV2ClaimRewardsAndPullBalances(
        address _gauge,
        address _target,
        bool _useFullBalances
    )
        internal
        returns (address[] memory rewardsTokens_, uint256[] memory rewardsTokenAmountsPulled_)
    {
        if (_useFullBalances) {
            return __curveGaugeV2ClaimRewardsAndPullFullBalances(_gauge, _target);
        }

        return __curveGaugeV2ClaimRewardsAndPullClaimedBalances(_gauge, _target);
    }

    function __curveGaugeV2ClaimRewardsAndPullClaimedBalances(address _gauge, address _target)
        internal
        returns (address[] memory rewardsTokens_, uint256[] memory rewardsTokenAmountsPulled_)
    {
        rewardsTokens_ = __curveGaugeV2GetRewardsTokensWithCrv(_gauge);

        uint256[] memory rewardsTokenPreClaimBalances = new uint256[](rewardsTokens_.length);
        for (uint256 i; i < rewardsTokens_.length; i++) {
            rewardsTokenPreClaimBalances[i] = ERC20(rewardsTokens_[i]).balanceOf(_target);
        }

        __curveGaugeV2ClaimAllRewards(_gauge, _target);

        rewardsTokenAmountsPulled_ = __pullPartialAssetBalances(
            _target,
            rewardsTokens_,
            rewardsTokenPreClaimBalances
        );

        return (rewardsTokens_, rewardsTokenAmountsPulled_);
    }

    function __curveGaugeV2ClaimRewardsAndPullFullBalances(address _gauge, address _target)
        internal
        returns (address[] memory rewardsTokens_, uint256[] memory rewardsTokenAmountsPulled_)
    {
        __curveGaugeV2ClaimAllRewards(_gauge, _target);

        rewardsTokens_ = __curveGaugeV2GetRewardsTokensWithCrv(_gauge);
        rewardsTokenAmountsPulled_ = __pullFullAssetBalances(_target, rewardsTokens_);

        return (rewardsTokens_, rewardsTokenAmountsPulled_);
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

interface IUniswapV2Router2 {
    function addLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    function removeLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external returns (uint256, uint256);

    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external returns (uint256[] memory);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract UniswapV2ActionsMixin is AssetHelpers {
    address private immutable UNISWAP_V2_ROUTER2;

    constructor(address _router) public {
        UNISWAP_V2_ROUTER2 = _router;
    }


    function __uniswapV2Lend(
        address _recipient,
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) internal {
        __approveAssetMaxAsNeeded(_tokenA, UNISWAP_V2_ROUTER2, _amountADesired);
        __approveAssetMaxAsNeeded(_tokenB, UNISWAP_V2_ROUTER2, _amountBDesired);

        IUniswapV2Router2(UNISWAP_V2_ROUTER2).addLiquidity(
            _tokenA,
            _tokenB,
            _amountADesired,
            _amountBDesired,
            _amountAMin,
            _amountBMin,
            _recipient,
            __uniswapV2GetActionDeadline()
        );
    }

    function __uniswapV2Redeem(
        address _recipient,
        address _poolToken,
        uint256 _poolTokenAmount,
        address _tokenA,
        address _tokenB,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) internal {
        __approveAssetMaxAsNeeded(_poolToken, UNISWAP_V2_ROUTER2, _poolTokenAmount);

        IUniswapV2Router2(UNISWAP_V2_ROUTER2).removeLiquidity(
            _tokenA,
            _tokenB,
            _poolTokenAmount,
            _amountAMin,
            _amountBMin,
            _recipient,
            __uniswapV2GetActionDeadline()
        );
    }

    function __uniswapV2Swap(
        address _recipient,
        uint256 _outgoingAssetAmount,
        uint256 _minIncomingAssetAmount,
        address[] memory _path
    ) internal {
        __approveAssetMaxAsNeeded(_path[0], UNISWAP_V2_ROUTER2, _outgoingAssetAmount);

        IUniswapV2Router2(UNISWAP_V2_ROUTER2).swapExactTokensForTokens(
            _outgoingAssetAmount,
            _minIncomingAssetAmount,
            _path,
            _recipient,
            __uniswapV2GetActionDeadline()
        );
    }

    function __uniswapV2SwapManyToOne(
        address _recipient,
        address[] memory _outgoingAssets,
        uint256[] memory _outgoingAssetAmounts,
        address _incomingAsset,
        address _intermediaryAsset
    ) internal {
        bool noIntermediary = _intermediaryAsset == address(0) ||
            _intermediaryAsset == _incomingAsset;
        for (uint256 i; i < _outgoingAssets.length; i++) {
            if (
                _outgoingAssetAmounts[i] == 0 ||
                _outgoingAssets[i] == address(0) ||
                _outgoingAssets[i] == _incomingAsset
            ) {
                continue;
            }

            address[] memory uniswapPath;
            if (noIntermediary || _outgoingAssets[i] == _intermediaryAsset) {
                uniswapPath = new address[](2);
                uniswapPath[0] = _outgoingAssets[i];
                uniswapPath[1] = _incomingAsset;
            } else {
                uniswapPath = new address[](3);
                uniswapPath[0] = _outgoingAssets[i];
                uniswapPath[1] = _intermediaryAsset;
                uniswapPath[2] = _incomingAsset;
            }

            __uniswapV2Swap(_recipient, _outgoingAssetAmounts[i], 1, uniswapPath);
        }
    }

    function __uniswapV2GetActionDeadline() private view returns (uint256 deadline_) {
        return block.timestamp + 1;
    }


    function getUniswapV2Router2() public view returns (address router_) {
        return UNISWAP_V2_ROUTER2;
    }
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract IntegrationSelectors {
    bytes4 public constant ADD_TRACKED_ASSETS_SELECTOR = bytes4(
        keccak256("addTrackedAssets(address,bytes,bytes)")
    );

    bytes4 public constant APPROVE_ASSETS_SELECTOR = bytes4(
        keccak256("approveAssets(address,bytes,bytes)")
    );

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

    bytes4 public constant CLAIM_REWARDS_AND_REINVEST_SELECTOR = bytes4(
        keccak256("claimRewardsAndReinvest(address,bytes,bytes)")
    );
    bytes4 public constant CLAIM_REWARDS_AND_SWAP_SELECTOR = bytes4(
        keccak256("claimRewardsAndSwap(address,bytes,bytes)")
    );
    bytes4 public constant LEND_AND_STAKE_SELECTOR = bytes4(
        keccak256("lendAndStake(address,bytes,bytes)")
    );
    bytes4 public constant UNSTAKE_AND_REDEEM_SELECTOR = bytes4(
        keccak256("unstakeAndRedeem(address,bytes,bytes)")
    );
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AdapterBase is IIntegrationAdapter, IntegrationSelectors {
    using SafeERC20 for ERC20;

    address internal immutable INTEGRATION_MANAGER;

    modifier fundAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _encodedAssetTransferArgs
    ) {
        (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType,
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts,
            address[] memory incomingAssets
        ) = __decodeEncodedAssetTransferArgs(_encodedAssetTransferArgs);

        if (spendAssetsHandleType == IIntegrationManager.SpendAssetsHandleType.Approve) {
            for (uint256 i = 0; i < spendAssets.length; i++) {
                ERC20(spendAssets[i]).safeTransferFrom(
                    _vaultProxy,
                    address(this),
                    spendAssetAmounts[i]
                );
            }
        }

        _;

        __transferContractAssetBalancesToFund(_vaultProxy, incomingAssets);
        __transferContractAssetBalancesToFund(_vaultProxy, spendAssets);
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


    function __approveMaxAsNeeded(
        address _asset,
        address _target,
        uint256 _neededAmount
    ) internal {
        if (ERC20(_asset).allowance(address(this), _target) < _neededAmount) {
            ERC20(_asset).safeApprove(_target, type(uint256).max);
        }
    }

    function __decodeEncodedAssetTransferArgs(bytes memory _encodedAssetTransferArgs)
        internal
        pure
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_
        )
    {
        return
            abi.decode(
                _encodedAssetTransferArgs,
                (IIntegrationManager.SpendAssetsHandleType, address[], uint256[], address[])
            );
    }

    function __transferContractAssetBalancesToFund(address _vaultProxy, address[] memory _assets)
        private
    {
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 postCallAmount = ERC20(_assets[i]).balanceOf(address(this));
            if (postCallAmount > 0) {
                ERC20(_assets[i]).safeTransfer(_vaultProxy, postCallAmount);
            }
        }
    }


    function getIntegrationManager() external view returns (address integrationManager_) {
        return INTEGRATION_MANAGER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AdapterBase2 is AdapterBase {
    modifier postActionAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _encodedAssetTransferArgs
    ) {
        _;

        (
            ,
            address[] memory spendAssets,
            ,
            address[] memory incomingAssets
        ) = __decodeEncodedAssetTransferArgs(_encodedAssetTransferArgs);

        __transferFullAssetBalances(_vaultProxy, incomingAssets);
        __transferFullAssetBalances(_vaultProxy, spendAssets);
    }

    modifier postActionIncomingAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _encodedAssetTransferArgs
    ) {
        _;

        (, , , address[] memory incomingAssets) = __decodeEncodedAssetTransferArgs(
            _encodedAssetTransferArgs
        );

        __transferFullAssetBalances(_vaultProxy, incomingAssets);
    }

    modifier postActionSpendAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _encodedAssetTransferArgs
    ) {
        _;

        (, address[] memory spendAssets, , ) = __decodeEncodedAssetTransferArgs(
            _encodedAssetTransferArgs
        );

        __transferFullAssetBalances(_vaultProxy, spendAssets);
    }

    constructor(address _integrationManager) public AdapterBase(_integrationManager) {}

    function __transferFullAssetBalances(address _target, address[] memory _assets) internal {
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 balance = ERC20(_assets[i]).balanceOf(address(this));
            if (balance > 0) {
                ERC20(_assets[i]).safeTransfer(_target, balance);
            }
        }
    }
}// GPL-3.0
pragma solidity 0.6.12;


contract CurveLiquidityAaveAdapter is
    AdapterBase2,
    CurveGaugeV2RewardsHandlerBase,
    CurveAaveLiquidityActionsMixin,
    UniswapV2ActionsMixin
{
    address private immutable AAVE_DAI_TOKEN;
    address private immutable AAVE_USDC_TOKEN;
    address private immutable AAVE_USDT_TOKEN;

    address private immutable DAI_TOKEN;
    address private immutable USDC_TOKEN;
    address private immutable USDT_TOKEN;

    address private immutable LIQUIDITY_GAUGE_TOKEN;
    address private immutable LP_TOKEN;
    address private immutable WETH_TOKEN;

    constructor(
        address _integrationManager,
        address _liquidityGaugeToken,
        address _lpToken,
        address _minter,
        address _pool,
        address _crvToken,
        address _wethToken,
        address[3] memory _aaveTokens, // [aDAI, aUSDC, aUSDT]
        address[3] memory _underlyingTokens, // [DAI, USDC, USDT]
        address _uniswapV2Router2
    )
        public
        AdapterBase2(_integrationManager)
        CurveAaveLiquidityActionsMixin(_pool, _aaveTokens, _underlyingTokens)
        CurveGaugeV2RewardsHandlerBase(_minter, _crvToken)
        UniswapV2ActionsMixin(_uniswapV2Router2)
    {
        AAVE_DAI_TOKEN = _aaveTokens[0];
        AAVE_USDC_TOKEN = _aaveTokens[1];
        AAVE_USDT_TOKEN = _aaveTokens[2];

        DAI_TOKEN = _underlyingTokens[0];
        USDC_TOKEN = _underlyingTokens[1];
        USDT_TOKEN = _underlyingTokens[2];

        LIQUIDITY_GAUGE_TOKEN = _liquidityGaugeToken;
        LP_TOKEN = _lpToken;
        WETH_TOKEN = _wethToken;

        ERC20(_lpToken).safeApprove(_liquidityGaugeToken, type(uint256).max);
    }


    function identifier() external pure override returns (string memory identifier_) {
        return "CURVE_LIQUIDITY_AAVE";
    }

    function approveAssets(
        address,
        bytes calldata,
        bytes calldata
    ) external {}

    function claimRewards(
        address _vaultProxy,
        bytes calldata,
        bytes calldata
    ) external onlyIntegrationManager {
        __curveGaugeV2ClaimAllRewards(LIQUIDITY_GAUGE_TOKEN, _vaultProxy);
    }

    function claimRewardsAndReinvest(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            bool useFullBalances,
            uint256 minIncomingLiquidityGaugeTokenAmount,
            uint8 intermediaryUnderlyingAssetIndex
        ) = __decodeClaimRewardsAndReinvestCallArgs(_encodedCallArgs);

        (
            address[] memory rewardsTokens,
            uint256[] memory rewardsTokenAmountsToUse
        ) = __curveGaugeV2ClaimRewardsAndPullBalances(
            LIQUIDITY_GAUGE_TOKEN,
            _vaultProxy,
            useFullBalances
        );

        address intermediaryUnderlyingAsset = getAssetByPoolIndex(
            intermediaryUnderlyingAssetIndex,
            true
        );

        __uniswapV2SwapManyToOne(
            address(this),
            rewardsTokens,
            rewardsTokenAmountsToUse,
            intermediaryUnderlyingAsset,
            WETH_TOKEN
        );

        uint256 intermediaryUnderlyingAssetBalance = ERC20(intermediaryUnderlyingAsset).balanceOf(
            address(this)
        );
        if (intermediaryUnderlyingAssetBalance > 0) {
            uint256[3] memory orderedUnderlyingAssetAmounts;
            orderedUnderlyingAssetAmounts[intermediaryUnderlyingAssetIndex] = intermediaryUnderlyingAssetBalance;

            __curveAaveLend(
                orderedUnderlyingAssetAmounts,
                minIncomingLiquidityGaugeTokenAmount,
                true
            );
            __curveGaugeV2Stake(
                LIQUIDITY_GAUGE_TOKEN,
                LP_TOKEN,
                ERC20(LP_TOKEN).balanceOf(address(this))
            );
        }
    }

    function claimRewardsAndSwap(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata
    ) external onlyIntegrationManager {
        (bool useFullBalances, address incomingAsset, ) = __decodeClaimRewardsAndSwapCallArgs(
            _encodedCallArgs
        );

        (
            address[] memory rewardsTokens,
            uint256[] memory rewardsTokenAmountsToUse
        ) = __curveGaugeV2ClaimRewardsAndPullBalances(
            LIQUIDITY_GAUGE_TOKEN,
            _vaultProxy,
            useFullBalances
        );

        __uniswapV2SwapManyToOne(
            _vaultProxy,
            rewardsTokens,
            rewardsTokenAmountsToUse,
            incomingAsset,
            WETH_TOKEN
        );
    }

    function lend(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            uint256[3] memory orderedOutgoingAmounts,
            uint256 minIncomingLPTokenAmount,
            bool useUnderlyings
        ) = __decodeLendCallArgs(_encodedCallArgs);

        __curveAaveLend(orderedOutgoingAmounts, minIncomingLPTokenAmount, useUnderlyings);
    }

    function lendAndStake(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            uint256[3] memory orderedOutgoingAmounts,
            uint256 minIncomingLiquidityGaugeTokenAmount,
            bool useUnderlyings
        ) = __decodeLendCallArgs(_encodedCallArgs);

        __curveAaveLend(
            orderedOutgoingAmounts,
            minIncomingLiquidityGaugeTokenAmount,
            useUnderlyings
        );
        __curveGaugeV2Stake(
            LIQUIDITY_GAUGE_TOKEN,
            LP_TOKEN,
            ERC20(LP_TOKEN).balanceOf(address(this))
        );
    }

    function redeem(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            uint256 outgoingLPTokenAmount,
            uint256[3] memory orderedMinIncomingAssetAmounts,
            bool redeemSingleAsset,
            bool useUnderlyings
        ) = __decodeRedeemCallArgs(_encodedCallArgs);

        __curveAaveRedeem(
            outgoingLPTokenAmount,
            orderedMinIncomingAssetAmounts,
            redeemSingleAsset,
            useUnderlyings
        );
    }

    function stake(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        uint256 outgoingLPTokenAmount = __decodeStakeCallArgs(_encodedCallArgs);

        __curveGaugeV2Stake(LIQUIDITY_GAUGE_TOKEN, LP_TOKEN, outgoingLPTokenAmount);
    }

    function unstake(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        uint256 outgoingLiquidityGaugeTokenAmount = __decodeUnstakeCallArgs(_encodedCallArgs);

        __curveGaugeV2Unstake(LIQUIDITY_GAUGE_TOKEN, outgoingLiquidityGaugeTokenAmount);
    }

    function unstakeAndRedeem(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            uint256 outgoingLiquidityGaugeTokenAmount,
            uint256[3] memory orderedMinIncomingAssetAmounts,
            bool redeemSingleAsset,
            bool useUnderlyings
        ) = __decodeRedeemCallArgs(_encodedCallArgs);

        __curveGaugeV2Unstake(LIQUIDITY_GAUGE_TOKEN, outgoingLiquidityGaugeTokenAmount);
        __curveAaveRedeem(
            outgoingLiquidityGaugeTokenAmount,
            orderedMinIncomingAssetAmounts,
            redeemSingleAsset,
            useUnderlyings
        );
    }


    function parseAssetsForMethod(bytes4 _selector, bytes calldata _encodedCallArgs)
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
        if (_selector == APPROVE_ASSETS_SELECTOR) {
            return __parseAssetsForApproveAssets(_encodedCallArgs);
        } else if (_selector == CLAIM_REWARDS_SELECTOR) {
            return __parseAssetsForClaimRewards();
        } else if (_selector == CLAIM_REWARDS_AND_REINVEST_SELECTOR) {
            return __parseAssetsForClaimRewardsAndReinvest(_encodedCallArgs);
        } else if (_selector == CLAIM_REWARDS_AND_SWAP_SELECTOR) {
            return __parseAssetsForClaimRewardsAndSwap(_encodedCallArgs);
        } else if (_selector == LEND_SELECTOR) {
            return __parseAssetsForLend(_encodedCallArgs);
        } else if (_selector == LEND_AND_STAKE_SELECTOR) {
            return __parseAssetsForLendAndStake(_encodedCallArgs);
        } else if (_selector == REDEEM_SELECTOR) {
            return __parseAssetsForRedeem(_encodedCallArgs);
        } else if (_selector == STAKE_SELECTOR) {
            return __parseAssetsForStake(_encodedCallArgs);
        } else if (_selector == UNSTAKE_SELECTOR) {
            return __parseAssetsForUnstake(_encodedCallArgs);
        } else if (_selector == UNSTAKE_AND_REDEEM_SELECTOR) {
            return __parseAssetsForUnstakeAndRedeem(_encodedCallArgs);
        }

        revert("parseAssetsForMethod: _selector invalid");
    }

    function __parseAssetsForApproveAssets(bytes calldata _encodedCallArgs)
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
        (spendAssets_, spendAssetAmounts_) = __decodeApproveAssetsCallArgs(_encodedCallArgs);
        require(
            spendAssets_.length == spendAssetAmounts_.length,
            "__parseAssetsForApproveAssets: Unequal arrays"
        );

        address[] memory rewardsTokens = __curveGaugeV2GetRewardsTokensWithCrv(
            LIQUIDITY_GAUGE_TOKEN
        );
        for (uint256 i; i < spendAssets_.length; i++) {
            if (spendAssetAmounts_[i] > 0) {
                require(
                    rewardsTokens.contains(spendAssets_[i]),
                    "__parseAssetsForApproveAssets: Invalid reward token"
                );
            }
        }

        return (
            IIntegrationManager.SpendAssetsHandleType.Approve,
            spendAssets_,
            spendAssetAmounts_,
            new address[](0),
            new uint256[](0)
        );
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

    function __parseAssetsForClaimRewardsAndReinvest(bytes calldata _encodedCallArgs)
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
            ,
            uint256 minIncomingLiquidityGaugeTokenAmount,
            uint8 intermediaryUnderlyingAssetIndex
        ) = __decodeClaimRewardsAndReinvestCallArgs(_encodedCallArgs);
        require(
            intermediaryUnderlyingAssetIndex < 3,
            "__parseAssetsForClaimRewardsAndReinvest: Out-of-bounds intermediaryUnderlyingAssetIndex"
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = LIQUIDITY_GAUGE_TOKEN;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingLiquidityGaugeTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.None,
            new address[](0),
            new uint256[](0),
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForClaimRewardsAndSwap(bytes calldata _encodedCallArgs)
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
        (
            ,
            address incomingAsset,
            uint256 minIncomingAssetAmount
        ) = __decodeClaimRewardsAndSwapCallArgs(_encodedCallArgs);

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingAsset;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingAssetAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.None,
            new address[](0),
            new uint256[](0),
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForLend(bytes calldata _encodedCallArgs)
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
            uint256[3] memory orderedOutgoingAssetAmounts,
            uint256 minIncomingLpTokenAmount,
            bool useUnderlyings
        ) = __decodeLendCallArgs(_encodedCallArgs);

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForLendingCalls(
            orderedOutgoingAssetAmounts,
            useUnderlyings
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = LP_TOKEN;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingLpTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForLendAndStake(bytes calldata _encodedCallArgs)
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
            uint256[3] memory orderedOutgoingAssetAmounts,
            uint256 minIncomingLiquidityGaugeTokenAmount,
            bool useUnderlyings
        ) = __decodeLendCallArgs(_encodedCallArgs);

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForLendingCalls(
            orderedOutgoingAssetAmounts,
            useUnderlyings
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = LIQUIDITY_GAUGE_TOKEN;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingLiquidityGaugeTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForRedeem(bytes calldata _encodedCallArgs)
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
            uint256 outgoingLpTokenAmount,
            uint256[3] memory orderedMinIncomingAssetAmounts,
            bool receiveSingleAsset,
            bool useUnderlyings
        ) = __decodeRedeemCallArgs(_encodedCallArgs);

        spendAssets_ = new address[](1);
        spendAssets_[0] = LP_TOKEN;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingLpTokenAmount;

        (incomingAssets_, minIncomingAssetAmounts_) = __parseIncomingAssetsForRedemptionCalls(
            orderedMinIncomingAssetAmounts,
            receiveSingleAsset,
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

    function __parseAssetsForStake(bytes calldata _encodedCallArgs)
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
        uint256 outgoingLpTokenAmount = __decodeStakeCallArgs(_encodedCallArgs);

        spendAssets_ = new address[](1);
        spendAssets_[0] = LP_TOKEN;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingLpTokenAmount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = LIQUIDITY_GAUGE_TOKEN;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = outgoingLpTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForUnstake(bytes calldata _encodedCallArgs)
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
        uint256 outgoingLiquidityGaugeTokenAmount = __decodeUnstakeCallArgs(_encodedCallArgs);

        spendAssets_ = new address[](1);
        spendAssets_[0] = LIQUIDITY_GAUGE_TOKEN;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingLiquidityGaugeTokenAmount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = LP_TOKEN;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = outgoingLiquidityGaugeTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForUnstakeAndRedeem(bytes calldata _encodedCallArgs)
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
            uint256 outgoingLiquidityGaugeTokenAmount,
            uint256[3] memory orderedMinIncomingAssetAmounts,
            bool receiveSingleAsset,
            bool useUnderlyings
        ) = __decodeRedeemCallArgs(_encodedCallArgs);

        spendAssets_ = new address[](1);
        spendAssets_[0] = LIQUIDITY_GAUGE_TOKEN;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingLiquidityGaugeTokenAmount;

        (incomingAssets_, minIncomingAssetAmounts_) = __parseIncomingAssetsForRedemptionCalls(
            orderedMinIncomingAssetAmounts,
            receiveSingleAsset,
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

    function __parseIncomingAssetsForRedemptionCalls(
        uint256[3] memory _orderedMinIncomingAssetAmounts,
        bool _receiveSingleAsset,
        bool _useUnderlyings
    )
        private
        view
        returns (address[] memory incomingAssets_, uint256[] memory minIncomingAssetAmounts_)
    {
        if (_receiveSingleAsset) {
            incomingAssets_ = new address[](1);
            minIncomingAssetAmounts_ = new uint256[](1);

            for (uint256 i; i < _orderedMinIncomingAssetAmounts.length; i++) {
                if (_orderedMinIncomingAssetAmounts[i] == 0) {
                    continue;
                }

                for (uint256 j = i + 1; j < _orderedMinIncomingAssetAmounts.length; j++) {
                    require(
                        _orderedMinIncomingAssetAmounts[j] == 0,
                        "__parseIncomingAssetsForRedemptionCalls: Too many min asset amounts specified"
                    );
                }

                incomingAssets_[0] = getAssetByPoolIndex(i, _useUnderlyings);
                minIncomingAssetAmounts_[0] = _orderedMinIncomingAssetAmounts[i];

                break;
            }
            require(
                incomingAssets_[0] != address(0),
                "__parseIncomingAssetsForRedemptionCalls: No min asset amount"
            );
        } else {
            incomingAssets_ = new address[](3);
            minIncomingAssetAmounts_ = new uint256[](3);
            for (uint256 i; i < incomingAssets_.length; i++) {
                incomingAssets_[i] = getAssetByPoolIndex(i, _useUnderlyings);
                minIncomingAssetAmounts_[i] = _orderedMinIncomingAssetAmounts[i];
            }
        }

        return (incomingAssets_, minIncomingAssetAmounts_);
    }

    function __parseSpendAssetsForLendingCalls(
        uint256[3] memory _orderedOutgoingAssetAmounts,
        bool _useUnderlyings
    ) private view returns (address[] memory spendAssets_, uint256[] memory spendAssetAmounts_) {
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
                spendAssets_[spendAssetsIndex] = getAssetByPoolIndex(i, _useUnderlyings);
                spendAssetAmounts_[spendAssetsIndex] = _orderedOutgoingAssetAmounts[i];
                spendAssetsIndex++;
            }
        }

        return (spendAssets_, spendAssetAmounts_);
    }


    function __decodeApproveAssetsCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (address[] memory assets_, uint256[] memory amounts_)
    {
        return abi.decode(_encodedCallArgs, (address[], uint256[]));
    }

    function __decodeClaimRewardsAndReinvestCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            bool useFullBalances_,
            uint256 minIncomingLiquidityGaugeTokenAmount_,
            uint8 intermediaryUnderlyingAssetIndex_
        )
    {
        return abi.decode(_encodedCallArgs, (bool, uint256, uint8));
    }

    function __decodeClaimRewardsAndSwapCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            bool useFullBalances_,
            address incomingAsset_,
            uint256 minIncomingAssetAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (bool, address, uint256));
    }

    function __decodeLendCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            uint256[3] memory orderedOutgoingAmounts_,
            uint256 minIncomingAssetAmount_,
            bool useUnderlyings_
        )
    {
        return abi.decode(_encodedCallArgs, (uint256[3], uint256, bool));
    }

    function __decodeRedeemCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            uint256 outgoingAssetAmount_,
            uint256[3] memory orderedMinIncomingAmounts_,
            bool receiveSingleAsset_,
            bool useUnderlyings_
        )
    {
        return abi.decode(_encodedCallArgs, (uint256, uint256[3], bool, bool));
    }

    function __decodeStakeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (uint256 outgoingLPTokenAmount_)
    {
        return abi.decode(_encodedCallArgs, (uint256));
    }

    function __decodeUnstakeCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (uint256 outgoingLiquidityGaugeTokenAmount_)
    {
        return abi.decode(_encodedCallArgs, (uint256));
    }


    function getLiquidityGaugeToken() external view returns (address liquidityGaugeToken_) {
        return LIQUIDITY_GAUGE_TOKEN;
    }

    function getLPToken() external view returns (address lpToken_) {
        return LP_TOKEN;
    }

    function getWethToken() external view returns (address wethToken_) {
        return WETH_TOKEN;
    }

    function getAssetByPoolIndex(uint256 _index, bool _useUnderlying)
        public
        view
        returns (address asset_)
    {
        if (_index == 0) {
            if (_useUnderlying) {
                return DAI_TOKEN;
            }
            return AAVE_DAI_TOKEN;
        } else if (_index == 1) {
            if (_useUnderlying) {
                return USDC_TOKEN;
            }
            return AAVE_USDC_TOKEN;
        } else if (_index == 2) {
            if (_useUnderlying) {
                return USDT_TOKEN;
            }
            return AAVE_USDT_TOKEN;
        }
    }
}