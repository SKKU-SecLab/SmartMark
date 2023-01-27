
pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//Unlicense
pragma solidity ^0.8.0;


interface IInstaIndex {

    function build(
        address owner_,
        uint256 accountVersion_,
        address origin_
    ) external returns (address account_);

}

interface IDSA {

    function cast(
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32);

}

interface IAaveProtocolDataProvider {

    function getReserveData(address asset)
        external
        view
        returns (
            uint256 availableLiquidity,
            uint256 totalStableDebt,
            uint256 totalVariableDebt,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp
        );

}

interface IAaveAddressProvider {

    function getPriceOracle() external view returns (address);

}

interface IAavePriceOracle {

    function getAssetPrice(address _asset) external view returns (uint256);

}

interface TokenInterface {

    function approve(address, uint256) external;


    function transfer(address, uint256) external;


    function transferFrom(
        address,
        address,
        uint256
    ) external;


    function deposit() external payable;


    function withdraw(uint256) external;


    function balanceOf(address) external view returns (uint256);


    function decimals() external view returns (uint256);


    function totalSupply() external view returns (uint256);

}

interface IInstaList {

    function accountID(address) external view returns (uint64);

}// MIT

pragma solidity ^0.8.1;

library Address {

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    uint256[45] private __gap;
}//Unlicense
pragma solidity ^0.8.0;


contract ConstantVariables is ERC20Upgradeable {

    IInstaIndex internal constant instaIndex =
        IInstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
    IERC20 internal constant wethContract =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant stethContract =
        IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IAaveProtocolDataProvider internal constant aaveProtocolDataProvider =
        IAaveProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
    IAaveAddressProvider internal constant aaveAddressProvider =
        IAaveAddressProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);
    IERC20 internal constant awethVariableDebtToken =
        IERC20(0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf);
    IERC20 internal constant astethToken =
        IERC20(0x1982b2F5814301d4e9a8b0201555376e62F82428);
    IInstaList internal constant instaList =
        IInstaList(0x4c8a1BEb8a87765788946D6B19C6C6355194AbEb);
}

contract Variables is ConstantVariables {

    uint256 internal _status = 1;

    mapping(address => bool) internal _isRebalancer;

    IERC20 internal _token;

    uint8 internal _tokenDecimals;

    uint256 internal _tokenMinLimit;

    IERC20 internal _atoken;

    IDSA internal _vaultDsa;

    struct Ratios {
        uint16 maxLimit; // Above this withdrawals are not allowed
        uint16 maxLimitGap;
        uint16 minLimit; // After leverage the ratio should be below minLimit & above minLimitGap
        uint16 minLimitGap;
        uint16 stEthLimit; // if 7500. Meaning stETH collateral covers 75% of the ETH debt. Excess ETH will be covered by token limit.
        uint128 maxBorrowRate; // maximum borrow rate above this leveraging should not happen
    }

    Ratios internal _ratios;

    uint256 internal _lastRevenueExchangePrice;

    uint256 internal _revenueFee; // 1000 = 10% (10% of user's profit)

    uint256 internal _revenue;

    uint256 internal _revenueEth;

    uint256 internal _withdrawalFee; // 10000 = 100%

    uint256 internal _idealExcessAmt; // 10 means 0.1% of total stEth/Eth supply (collateral + ideal balance)

    uint256 internal _swapFee; // 5 means 0.05%. This is the fee on leverage function which allows swap of stETH -> ETH

    uint256 internal _saveSlippage; // 1e16 means 1%

    uint256 internal _deleverageFee; // 1 means 0.01%
}//Unlicense
pragma solidity ^0.8.0;


contract Helpers is Variables {

    modifier nonReentrant() {

        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function getWethBorrowRate()
        internal
        view
        returns (uint256 wethBorrowRate_)
    {

        (, , , , wethBorrowRate_, , , , , ) = aaveProtocolDataProvider
            .getReserveData(address(wethContract));
    }

    function getTokenCollateralAmount()
        internal
        view
        returns (uint256 tokenAmount_)
    {

        tokenAmount_ = _atoken.balanceOf(address(_vaultDsa));
    }

    function getStethCollateralAmount()
        internal
        view
        returns (uint256 stEthAmount_)
    {

        stEthAmount_ = astethToken.balanceOf(address(_vaultDsa));
    }

    function getWethDebtAmount()
        internal
        view
        returns (uint256 wethDebtAmount_)
    {

        wethDebtAmount_ = awethVariableDebtToken.balanceOf(address(_vaultDsa));
    }

    function getVaultBalances()
        public
        view
        returns (
            uint256 tokenCollateralAmt_,
            uint256 stethCollateralAmt_,
            uint256 wethDebtAmt_,
            uint256 tokenVaultBal_,
            uint256 tokenDSABal_,
            uint256 netTokenBal_
        )
    {

        tokenCollateralAmt_ = getTokenCollateralAmount();
        stethCollateralAmt_ = getStethCollateralAmount();
        wethDebtAmt_ = getWethDebtAmount();
        tokenVaultBal_ = _token.balanceOf(address(this));
        tokenDSABal_ = _token.balanceOf(address(_vaultDsa));
        netTokenBal_ = tokenCollateralAmt_ + tokenVaultBal_ + tokenDSABal_;
    }

    function getNewProfits() public view returns (uint256 profits_) {

        uint256 stEthCol_ = getStethCollateralAmount();
        uint256 stEthDsaBal_ = stethContract.balanceOf(address(_vaultDsa));
        uint256 wethDsaBal_ = wethContract.balanceOf(address(_vaultDsa));
        uint256 positiveEth_ = stEthCol_ + stEthDsaBal_ + wethDsaBal_;
        uint256 negativeEth_ = getWethDebtAmount() + _revenueEth;
        profits_ = negativeEth_ < positiveEth_
            ? positiveEth_ - negativeEth_
            : 0;
    }

    function getCurrentExchangePrice()
        public
        view
        returns (uint256 exchangePrice_, uint256 newTokenRevenue_)
    {

        (, , , , , uint256 netTokenBalance_) = getVaultBalances();
        netTokenBalance_ -= _revenue;
        uint256 totalSupply_ = totalSupply();
        uint256 exchangePriceWithRevenue_;
        if (totalSupply_ != 0) {
            exchangePriceWithRevenue_ =
                (netTokenBalance_ * 1e18) /
                totalSupply_;
        } else {
            exchangePriceWithRevenue_ = 1e18;
        }
        if (exchangePriceWithRevenue_ > _lastRevenueExchangePrice) {
            uint256 newProfit_ = netTokenBalance_ -
                ((_lastRevenueExchangePrice * totalSupply_) / 1e18);
            newTokenRevenue_ = (newProfit_ * _revenueFee) / 10000;
            exchangePrice_ =
                ((netTokenBalance_ - newTokenRevenue_) * 1e18) /
                totalSupply_;
        } else {
            exchangePrice_ = exchangePriceWithRevenue_;
        }
    }

    struct ValidateFinalPosition {
        uint256 tokenPriceInBaseCurrency;
        uint256 ethPriceInBaseCurrency;
        uint256 excessDebtInBaseCurrency;
        uint256 netTokenColInBaseCurrency;
        uint256 netTokenSupplyInBaseCurrency;
        uint256 ratioMax;
        uint256 ratioMin;
    }

    function validateFinalPosition()
        internal
        view
        returns (
            bool criticalIsOk_,
            bool criticalGapIsOk_,
            bool minIsOk_,
            bool minGapIsOk_,
            bool withdrawIsOk_
        )
    {

        (
            uint256 tokenColAmt_,
            uint256 stethColAmt_,
            uint256 wethDebt_,
            ,
            ,
            uint256 netTokenBal_
        ) = getVaultBalances();

        uint256 ethCoveringDebt_ = (stethColAmt_ * _ratios.stEthLimit) / 10000;

        uint256 excessDebt_ = ethCoveringDebt_ < wethDebt_
            ? wethDebt_ - ethCoveringDebt_
            : 0;

        if (excessDebt_ > 0) {
            IAavePriceOracle aaveOracle_ = IAavePriceOracle(
                aaveAddressProvider.getPriceOracle()
            );

            ValidateFinalPosition memory validateFinalPosition_;
            validateFinalPosition_.tokenPriceInBaseCurrency = aaveOracle_
                .getAssetPrice(address(_token));
            validateFinalPosition_.ethPriceInBaseCurrency = aaveOracle_
                .getAssetPrice(address(wethContract));

            validateFinalPosition_.excessDebtInBaseCurrency =
                (excessDebt_ * validateFinalPosition_.ethPriceInBaseCurrency) /
                1e18;

            validateFinalPosition_.netTokenColInBaseCurrency =
                (tokenColAmt_ *
                    validateFinalPosition_.tokenPriceInBaseCurrency) /
                (10**_tokenDecimals);
            validateFinalPosition_.netTokenSupplyInBaseCurrency =
                (netTokenBal_ *
                    validateFinalPosition_.tokenPriceInBaseCurrency) /
                (10**_tokenDecimals);

            validateFinalPosition_.ratioMax =
                (validateFinalPosition_.excessDebtInBaseCurrency * 10000) /
                validateFinalPosition_.netTokenColInBaseCurrency;
            validateFinalPosition_.ratioMin =
                (validateFinalPosition_.excessDebtInBaseCurrency * 10000) /
                validateFinalPosition_.netTokenSupplyInBaseCurrency;

            criticalIsOk_ = validateFinalPosition_.ratioMax < _ratios.maxLimit;
            criticalGapIsOk_ =
                validateFinalPosition_.ratioMax > _ratios.maxLimitGap;
            minIsOk_ = validateFinalPosition_.ratioMin < _ratios.minLimit;
            minGapIsOk_ = validateFinalPosition_.ratioMin > _ratios.minLimitGap;
            withdrawIsOk_ =
                validateFinalPosition_.ratioMax < (_ratios.maxLimit - 100);
        } else {
            criticalIsOk_ = true;
            minIsOk_ = true;
        }
    }

    function validateLeverageAmt(
        address[] memory vaults_,
        uint256[] memory amts_,
        uint256 leverageAmt_,
        uint256 swapAmt_
    ) internal pure returns (bool isOk_) {

        if (leverageAmt_ == 0 && swapAmt_ == 0) {
            isOk_ = true;
            return isOk_;
        }
        uint256 l_ = vaults_.length;
        isOk_ = l_ == amts_.length;
        if (isOk_) {
            uint256 totalAmt_ = swapAmt_;
            for (uint256 i = 0; i < l_; i++) {
                totalAmt_ = totalAmt_ + amts_[i];
            }
            isOk_ = totalAmt_ <= leverageAmt_; // total amount should not be more than leverage amount
            isOk_ = isOk_ && ((leverageAmt_ * 9999) / 10000) < totalAmt_; // total amount should be more than (0.9999 * leverage amount). 0.01% slippage gap.
        }
    }
}//Unlicense
pragma solidity ^0.8.0;

contract Events is Helpers {

    event supplyLog(
        uint256 amount_,
        address indexed caller_,
        address indexed to_
    );

    event withdrawLog(
        uint256 amount_,
        address indexed caller_,
        address indexed to_
    );

    event leverageLog(uint256 amt_, uint256 transferAmt_);

    event deleverageLog(uint256 amt_, uint256 transferAmt_);

    event deleverageAndWithdrawLog(
        uint256 deleverageAmt_,
        uint256 transferAmt_,
        uint256 vtokenAmount_,
        address to_
    );
}//Unlicense
pragma solidity ^0.8.0;


contract CoreHelpers is Events {

    using SafeERC20 for IERC20;

    function updateStorage(uint256 exchangePrice_, uint256 newRevenue_)
        internal
    {

        if (exchangePrice_ > _lastRevenueExchangePrice) {
            _lastRevenueExchangePrice = exchangePrice_;
            _revenue += newRevenue_;
        }
    }

    function withdrawHelper(uint256 amount_, uint256 limit_)
        internal
        pure
        returns (uint256, uint256)
    {

        uint256 transferAmt_;
        if (limit_ > amount_) {
            transferAmt_ = amount_;
            amount_ = 0;
        } else {
            transferAmt_ = limit_;
            amount_ = amount_ - limit_;
        }
        return (amount_, transferAmt_);
    }

    function withdrawFinal(uint256 amount_)
        internal
        view
        returns (uint256[] memory transferAmts_)
    {

        require(amount_ > 0, "amount-invalid");
        (
            uint256 tokenCollateralAmt_,
            ,
            ,
            uint256 tokenVaultBal_,
            uint256 tokenDSABal_,
            uint256 netTokenBal_
        ) = getVaultBalances();
        require(amount_ <= netTokenBal_, "excess-withdrawal");

        transferAmts_ = new uint256[](3);
        if (tokenVaultBal_ > 10) {
            (amount_, transferAmts_[0]) = withdrawHelper(
                amount_,
                tokenVaultBal_
            );
        }
        if (tokenDSABal_ > 10 && amount_ > 0) {
            (amount_, transferAmts_[1]) = withdrawHelper(amount_, tokenDSABal_);
        }
        if (tokenCollateralAmt_ > 10 && amount_ > 0) {
            (amount_, transferAmts_[2]) = withdrawHelper(
                amount_,
                tokenCollateralAmt_
            );
        }
    }

    function withdrawTransfers(uint256 amount_, uint256[] memory transferAmts_)
        internal
    {

        if (transferAmts_[0] == amount_) return;
        uint256 totalTransferAmount_ = transferAmts_[0] +
            transferAmts_[1] +
            transferAmts_[2];
        require(amount_ == totalTransferAmount_, "transfers-not-valid");
        uint256 i;
        uint256 j;
        uint256 withdrawAmtDSA = transferAmts_[1] + transferAmts_[2];
        if (transferAmts_[2] > 0) j++;
        if (withdrawAmtDSA > 0) j++;
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        if (transferAmts_[2] > 0) {
            targets_[i] = "AAVE-V2-A";
            calldata_[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                address(_token),
                transferAmts_[2],
                0,
                0
            );
            i++;
        }
        if (withdrawAmtDSA > 0) {
            targets_[i] = "BASIC-A";
            calldata_[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                address(_token),
                withdrawAmtDSA,
                address(this),
                0,
                0
            );
        }
        _vaultDsa.cast(targets_, calldata_, address(this));
    }

    function withdrawInternal(
        uint256 amount_,
        address to_,
        bool afterDeleverage_
    ) internal returns (uint256 vtokenAmount_) {

        require(amount_ != 0, "amount cannot be zero");

        (
            uint256 exchangePrice_,
            uint256 newRevenue_
        ) = getCurrentExchangePrice();
        updateStorage(exchangePrice_, newRevenue_);

        if (amount_ == type(uint256).max) {
            vtokenAmount_ = balanceOf(msg.sender);
            amount_ = (vtokenAmount_ * exchangePrice_) / 1e18;
        } else {
            vtokenAmount_ = (amount_ * 1e18) / exchangePrice_;
        }

        _burn(msg.sender, vtokenAmount_);
        uint256 fee_ = (amount_ * _withdrawalFee) / 10000;
        uint256 amountAfterFee_ = amount_ - fee_;
        uint256[] memory transferAmts_ = withdrawFinal(amountAfterFee_);
        withdrawTransfers(amountAfterFee_, transferAmts_);

        (, , , , bool isOk_) = validateFinalPosition();
        require(isOk_, "position-risky");

        _token.safeTransfer(to_, amountAfterFee_);

        if (afterDeleverage_) {
            (, , , bool minGapIsOk_, ) = validateFinalPosition();
            require(minGapIsOk_, "excess-deleverage");
        }
    }

    function deleverageInternal(uint256 amt_)
        internal
        returns (uint256 transferAmt_)
    {

        require(amt_ > 0, "not-valid-amount");
        wethContract.safeTransferFrom(msg.sender, address(_vaultDsa), amt_);

        bool isDsa_ = instaList.accountID(msg.sender) > 0;

        uint256 i;
        uint256 j = isDsa_ ? 2 : 3;
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        targets_[0] = "AAVE-V2-A";
        calldata_[0] = abi.encodeWithSignature(
            "payback(address,uint256,uint256,uint256,uint256)",
            address(wethContract),
            amt_,
            2,
            0,
            0
        );
        if (!isDsa_) {
            transferAmt_ = amt_ + ((amt_ * _deleverageFee) / 10000);
            targets_[1] = "AAVE-V2-A";
            calldata_[1] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                address(stethContract),
                transferAmt_,
                0,
                0
            );
            i = 2;
        } else {
            transferAmt_ = amt_;
            i = 1;
        }
        targets_[i] = "BASIC-A";
        calldata_[i] = abi.encodeWithSignature(
            "withdraw(address,uint256,address,uint256,uint256)",
            isDsa_ ? address(astethToken) : address(stethContract),
            transferAmt_,
            msg.sender,
            0,
            0
        );
        _vaultDsa.cast(targets_, calldata_, address(this));
    }
}

contract UserModule is CoreHelpers {

    using SafeERC20 for IERC20;

    function supply(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant returns (uint256 vtokenAmount_) {

        require(token_ == address(_token), "wrong token");
        require(amount_ != 0, "amount cannot be zero");
        (
            uint256 exchangePrice_,
            uint256 newRevenue_
        ) = getCurrentExchangePrice();
        updateStorage(exchangePrice_, newRevenue_);
        _token.safeTransferFrom(msg.sender, address(this), amount_);
        vtokenAmount_ = (amount_ * 1e18) / exchangePrice_;
        _mint(to_, vtokenAmount_);
        emit supplyLog(amount_, msg.sender, to_);
    }

    function withdraw(uint256 amount_, address to_)
        external
        nonReentrant
        returns (uint256 vtokenAmount_)
    {

        vtokenAmount_ = withdrawInternal(amount_, to_, false);
        emit withdrawLog(amount_, msg.sender, to_);
    }

    function leverage(uint256 amt_) external nonReentrant {

        require(amt_ > 0, "not-valid-amount");
        stethContract.safeTransferFrom(msg.sender, address(_vaultDsa), amt_);
        uint256 fee_ = (amt_ * _swapFee) / 10000;
        uint256 transferAmt_ = amt_ - fee_;
        _revenueEth += fee_;

        uint256 tokenBal_ = _token.balanceOf(address(this));
        if (tokenBal_ > _tokenMinLimit)
            _token.safeTransfer(address(_vaultDsa), tokenBal_);
        tokenBal_ = _token.balanceOf(address(_vaultDsa));
        uint256 i;
        uint256 j = tokenBal_ > _tokenMinLimit ? 4 : 3;
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        if (tokenBal_ > _tokenMinLimit) {
            targets_[i] = "AAVE-V2-A";
            calldata_[i] = abi.encodeWithSignature(
                "deposit(address,uint256,uint256,uint256)",
                address(_token),
                tokenBal_,
                0,
                0
            );
            i++;
        }
        targets_[i] = "AAVE-V2-A";
        calldata_[i] = abi.encodeWithSignature(
            "deposit(address,uint256,uint256,uint256)",
            address(stethContract),
            amt_,
            0,
            0
        );
        targets_[i + 1] = "AAVE-V2-A";
        calldata_[i + 1] = abi.encodeWithSignature(
            "borrow(address,uint256,uint256,uint256,uint256)",
            address(wethContract),
            amt_,
            2,
            0,
            0
        );
        targets_[i + 2] = "BASIC-A";
        calldata_[i + 2] = abi.encodeWithSignature(
            "withdraw(address,uint256,address,uint256,uint256)",
            address(wethContract),
            transferAmt_,
            msg.sender,
            0,
            0
        );
        _vaultDsa.cast(targets_, calldata_, address(this));
        (, , bool minIsOk_, , ) = validateFinalPosition();
        require(minIsOk_, "excess-leverage");

        emit leverageLog(amt_, transferAmt_);
    }

    function deleverage(uint256 amt_) external nonReentrant {

        uint256 transferAmt_ = deleverageInternal(amt_);
        (, , , bool minGapIsOk_, ) = validateFinalPosition();
        require(minGapIsOk_, "excess-deleverage");
        emit deleverageLog(amt_, transferAmt_);
    }

    function deleverageAndWithdraw(
        uint256 deleverageAmt_,
        uint256 withdrawAmount_,
        address to_
    ) external nonReentrant {

        uint256 transferAmt_ = deleverageInternal(deleverageAmt_);
        uint256 vtokenAmt_ = withdrawInternal(withdrawAmount_, to_, true);

        emit deleverageAndWithdrawLog(
            deleverageAmt_,
            transferAmt_,
            vtokenAmt_,
            to_
        );
    }
}