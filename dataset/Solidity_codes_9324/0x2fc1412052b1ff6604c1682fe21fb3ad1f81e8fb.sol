
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

interface IFundDeployer {
    enum ReleaseStatus {PreLaunch, Live, Paused}

    function getOwner() external view returns (address);

    function getReleaseStatus() external view returns (ReleaseStatus);

    function isRegisteredVaultCall(address, bytes4) external view returns (bool);
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

interface IIdleTokenV4 {
    function getGovTokensAmounts(address) external view returns (uint256[] calldata);

    function govTokens(uint256) external view returns (address);

    function mintIdleToken(
        uint256,
        bool,
        address
    ) external returns (uint256);

    function redeemIdleToken(uint256) external returns (uint256);

    function token() external view returns (address);

    function tokenPrice() external view returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;

interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }


    function getFundDeployer() external view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract SingleUnderlyingDerivativeRegistryMixin is FundDeployerOwnerMixin {
    event DerivativeAdded(address indexed derivative, address indexed underlying);

    event DerivativeRemoved(address indexed derivative);

    mapping(address => address) private derivativeToUnderlying;

    constructor(address _fundDeployer) public FundDeployerOwnerMixin(_fundDeployer) {}

    function addDerivatives(address[] memory _derivatives, address[] memory _underlyings)
        external
        virtual
        onlyFundDeployerOwner
    {
        require(_derivatives.length > 0, "addDerivatives: Empty _derivatives");
        require(_derivatives.length == _underlyings.length, "addDerivatives: Unequal arrays");

        for (uint256 i; i < _derivatives.length; i++) {
            require(_derivatives[i] != address(0), "addDerivatives: Empty derivative");
            require(_underlyings[i] != address(0), "addDerivatives: Empty underlying");
            require(
                getUnderlyingForDerivative(_derivatives[i]) == address(0),
                "addDerivatives: Value already set"
            );

            __validateDerivative(_derivatives[i], _underlyings[i]);

            derivativeToUnderlying[_derivatives[i]] = _underlyings[i];

            emit DerivativeAdded(_derivatives[i], _underlyings[i]);
        }
    }

    function removeDerivatives(address[] memory _derivatives) external onlyFundDeployerOwner {
        require(_derivatives.length > 0, "removeDerivatives: Empty _derivatives");

        for (uint256 i; i < _derivatives.length; i++) {
            require(
                getUnderlyingForDerivative(_derivatives[i]) != address(0),
                "removeDerivatives: Value not set"
            );

            delete derivativeToUnderlying[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }

    function __validateDerivative(address, address) internal virtual {
    }


    function getUnderlyingForDerivative(address _derivative)
        public
        view
        returns (address underlying_)
    {
        return derivativeToUnderlying[_derivative];
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract IdlePriceFeed is IDerivativePriceFeed, SingleUnderlyingDerivativeRegistryMixin {
    using SafeMath for uint256;

    uint256 private constant IDLE_TOKEN_UNIT = 10**18;

    constructor(address _fundDeployer)
        public
        SingleUnderlyingDerivativeRegistryMixin(_fundDeployer)
    {}

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        underlyings_ = new address[](1);
        underlyings_[0] = getUnderlyingForDerivative(_derivative);
        require(underlyings_[0] != address(0), "calcUnderlyingValues: Unsupported derivative");

        underlyingAmounts_ = new uint256[](1);
        underlyingAmounts_[0] = _derivativeAmount.mul(IIdleTokenV4(_derivative).tokenPrice()).div(
            IDLE_TOKEN_UNIT
        );
    }

    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {
        return getUnderlyingForDerivative(_asset) != address(0);
    }

    function __validateDerivative(address _derivative, address _underlying) internal override {
        require(
            IIdleTokenV4(_derivative).token() == _underlying,
            "__validateDerivative: Invalid underlying for IdleToken"
        );
    }
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


abstract contract IdleV4ActionsMixin is AssetHelpers {
    address private constant IDLE_V4_REFERRAL_ACCOUNT = 0x1ad1fc9964c551f456238Dd88D6a38344B5319D7;

    function __idleV4ClaimRewards(address _idleToken) internal {
        IIdleTokenV4(_idleToken).redeemIdleToken(0);
    }

    function __idleV4GetRewardsTokens(address _idleToken)
        internal
        view
        returns (address[] memory rewardsTokens_)
    {
        IIdleTokenV4 idleTokenContract = IIdleTokenV4(_idleToken);

        rewardsTokens_ = new address[](idleTokenContract.getGovTokensAmounts(address(0)).length);
        for (uint256 i; i < rewardsTokens_.length; i++) {
            rewardsTokens_[i] = IIdleTokenV4(idleTokenContract).govTokens(i);
        }

        return rewardsTokens_;
    }

    function __idleV4Lend(
        address _idleToken,
        address _underlying,
        uint256 _underlyingAmount
    ) internal {
        __approveAssetMaxAsNeeded(_underlying, _idleToken, _underlyingAmount);
        IIdleTokenV4(_idleToken).mintIdleToken(_underlyingAmount, true, IDLE_V4_REFERRAL_ACCOUNT);
    }

    function __idleV4Redeem(address _idleToken, uint256 _idleTokenAmount) internal {
        IIdleTokenV4(_idleToken).redeemIdleToken(_idleTokenAmount);
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


contract IdleAdapter is AdapterBase2, IdleV4ActionsMixin, UniswapV2ActionsMixin {
    using AddressArrayLib for address[];

    address private immutable IDLE_PRICE_FEED;
    address private immutable WETH_TOKEN;

    constructor(
        address _integrationManager,
        address _idlePriceFeed,
        address _wethToken,
        address _uniswapV2Router2
    ) public AdapterBase2(_integrationManager) UniswapV2ActionsMixin(_uniswapV2Router2) {
        IDLE_PRICE_FEED = _idlePriceFeed;
        WETH_TOKEN = _wethToken;
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "IDLE";
    }

    function approveAssets(
        address,
        bytes calldata,
        bytes calldata
    ) external {}

    function claimRewards(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionSpendAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (, address idleToken) = __decodeClaimRewardsCallArgs(_encodedCallArgs);

        __idleV4ClaimRewards(idleToken);

        __pushFullAssetBalances(_vaultProxy, __idleV4GetRewardsTokens(idleToken));
    }

    function claimRewardsAndReinvest(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionSpendAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (, address idleToken, , bool useFullBalances) = __decodeClaimRewardsAndReinvestCallArgs(
            _encodedCallArgs
        );

        address underlying = __getUnderlyingForIdleToken(idleToken);
        require(underlying != address(0), "claimRewardsAndReinvest: Unsupported idleToken");

        (
            address[] memory rewardsTokens,
            uint256[] memory rewardsTokenAmountsToUse
        ) = __claimRewardsAndPullRewardsTokens(_vaultProxy, idleToken, useFullBalances);

        __uniswapV2SwapManyToOne(
            address(this),
            rewardsTokens,
            rewardsTokenAmountsToUse,
            underlying,
            WETH_TOKEN
        );

        uint256 underlyingBalance = ERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            __idleV4Lend(idleToken, underlying, underlyingBalance);
        }
    }

    function claimRewardsAndSwap(
        address _vaultProxy,
        bytes calldata _encodedCallArgs,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionSpendAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            ,
            address idleToken,
            address incomingAsset,
            ,
            bool useFullBalances
        ) = __decodeClaimRewardsAndSwapCallArgs(_encodedCallArgs);

        (
            address[] memory rewardsTokens,
            uint256[] memory rewardsTokenAmountsToUse
        ) = __claimRewardsAndPullRewardsTokens(_vaultProxy, idleToken, useFullBalances);

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
        bytes calldata,
        bytes calldata _encodedAssetTransferArgs
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _encodedAssetTransferArgs)
    {
        (
            ,
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts,
            address[] memory incomingAssets
        ) = __decodeEncodedAssetTransferArgs(_encodedAssetTransferArgs);

        __idleV4Lend(incomingAssets[0], spendAssets[0], spendAssetAmounts[0]);
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
        (address idleToken, , ) = __decodeRedeemCallArgs(_encodedCallArgs);

        __idleV4Redeem(idleToken, ERC20(idleToken).balanceOf(address(this)));

        __pushFullAssetBalances(_vaultProxy, __idleV4GetRewardsTokens(idleToken));
    }

    function __claimRewardsAndPullRewardsTokens(
        address _vaultProxy,
        address _idleToken,
        bool _useFullBalances
    )
        private
        returns (address[] memory rewardsTokens_, uint256[] memory rewardsTokenAmountsToUse_)
    {
        __idleV4ClaimRewards(_idleToken);

        rewardsTokens_ = __idleV4GetRewardsTokens(_idleToken);
        if (_useFullBalances) {
            __pullFullAssetBalances(_vaultProxy, rewardsTokens_);
        }

        return (rewardsTokens_, __getAssetBalances(address(this), rewardsTokens_));
    }

    function __getUnderlyingForIdleToken(address _idleToken)
        private
        view
        returns (address underlying_)
    {
        return IdlePriceFeed(IDLE_PRICE_FEED).getUnderlyingForDerivative(_idleToken);
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
            return __parseAssetsForClaimRewards(_encodedCallArgs);
        } else if (_selector == CLAIM_REWARDS_AND_REINVEST_SELECTOR) {
            return __parseAssetsForClaimRewardsAndReinvest(_encodedCallArgs);
        } else if (_selector == CLAIM_REWARDS_AND_SWAP_SELECTOR) {
            return __parseAssetsForClaimRewardsAndSwap(_encodedCallArgs);
        } else if (_selector == LEND_SELECTOR) {
            return __parseAssetsForLend(_encodedCallArgs);
        } else if (_selector == REDEEM_SELECTOR) {
            return __parseAssetsForRedeem(_encodedCallArgs);
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
        address idleToken;
        (idleToken, spendAssets_, spendAssetAmounts_) = __decodeApproveAssetsCallArgs(
            _encodedCallArgs
        );
        require(
            __getUnderlyingForIdleToken(idleToken) != address(0),
            "__parseAssetsForApproveAssets: Unsupported idleToken"
        );
        require(
            spendAssets_.length == spendAssetAmounts_.length,
            "__parseAssetsForApproveAssets: Unequal arrays"
        );

        address[] memory rewardsTokens = __idleV4GetRewardsTokens(idleToken);
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

    function __parseAssetsForClaimRewards(bytes calldata _encodedCallArgs)
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
        (address vaultProxy, address idleToken) = __decodeClaimRewardsCallArgs(_encodedCallArgs);

        require(
            __getUnderlyingForIdleToken(idleToken) != address(0),
            "__parseAssetsForClaimRewards: Unsupported idleToken"
        );

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForClaimRewardsCalls(
            vaultProxy,
            idleToken
        );

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
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
            address vaultProxy,
            address idleToken,
            uint256 minIncomingIdleTokenAmount,

        ) = __decodeClaimRewardsAndReinvestCallArgs(_encodedCallArgs);


        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForClaimRewardsCalls(
            vaultProxy,
            idleToken
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = idleToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingIdleTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseAssetsForClaimRewardsAndSwap(bytes calldata _encodedCallArgs)
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
            address vaultProxy,
            address idleToken,
            address incomingAsset,
            uint256 minIncomingAssetAmount,

        ) = __decodeClaimRewardsAndSwapCallArgs(_encodedCallArgs);

        require(
            __getUnderlyingForIdleToken(idleToken) != address(0),
            "__parseAssetsForClaimRewardsAndSwap: Unsupported idleToken"
        );

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForClaimRewardsCalls(
            vaultProxy,
            idleToken
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingAsset;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingAssetAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
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
            address idleToken,
            uint256 outgoingUnderlyingAmount,
            uint256 minIncomingIdleTokenAmount
        ) = __decodeLendCallArgs(_encodedCallArgs);

        address underlying = __getUnderlyingForIdleToken(idleToken);
        require(underlying != address(0), "__parseAssetsForLend: Unsupported idleToken");

        spendAssets_ = new address[](1);
        spendAssets_[0] = underlying;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingUnderlyingAmount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = idleToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingIdleTokenAmount;

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
            address idleToken,
            uint256 outgoingIdleTokenAmount,
            uint256 minIncomingUnderlyingAmount
        ) = __decodeRedeemCallArgs(_encodedCallArgs);

        address underlying = __getUnderlyingForIdleToken(idleToken);
        require(underlying != address(0), "__parseAssetsForRedeem: Unsupported idleToken");

        spendAssets_ = new address[](1);
        spendAssets_[0] = idleToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingIdleTokenAmount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = underlying;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingUnderlyingAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    function __parseSpendAssetsForClaimRewardsCalls(address _vaultProxy, address _idleToken)
        private
        view
        returns (address[] memory spendAssets_, uint256[] memory spendAssetAmounts_)
    {
        spendAssets_ = new address[](1);
        spendAssets_[0] = _idleToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = ERC20(_idleToken).balanceOf(_vaultProxy);

        return (spendAssets_, spendAssetAmounts_);
    }


    function __decodeApproveAssetsCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address idleToken_,
            address[] memory assets_,
            uint256[] memory amounts_
        )
    {
        return abi.decode(_encodedCallArgs, (address, address[], uint256[]));
    }

    function __decodeClaimRewardsCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (address vaultProxy_, address idleToken_)
    {
        return abi.decode(_encodedCallArgs, (address, address));
    }

    function __decodeClaimRewardsAndReinvestCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address vaultProxy_,
            address idleToken_,
            uint256 minIncomingIdleTokenAmount_,
            bool useFullBalances_
        )
    {
        return abi.decode(_encodedCallArgs, (address, address, uint256, bool));
    }

    function __decodeClaimRewardsAndSwapCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address vaultProxy_,
            address idleToken_,
            address incomingAsset_,
            uint256 minIncomingAssetAmount_,
            bool useFullBalances_
        )
    {
        return abi.decode(_encodedCallArgs, (address, address, address, uint256, bool));
    }

    function __decodeLendCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address idleToken_,
            uint256 outgoingUnderlyingAmount_,
            uint256 minIncomingIdleTokenAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address, uint256, uint256));
    }

    function __decodeRedeemCallArgs(bytes memory _encodedCallArgs)
        private
        pure
        returns (
            address idleToken_,
            uint256 outgoingIdleTokenAmount_,
            uint256 minIncomingUnderlyingAmount_
        )
    {
        return abi.decode(_encodedCallArgs, (address, uint256, uint256));
    }


    function getIdlePriceFeed() external view returns (address idlePriceFeed_) {
        return IDLE_PRICE_FEED;
    }

    function getWethToken() external view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}