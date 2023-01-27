
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
}//MIT
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

interface IAaveLendingPool {

    function getUserAccountData(address) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

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
}//MIT
pragma solidity ^0.8.0;


contract ConstantVariables is ERC20Upgradeable {

    using SafeERC20 for IERC20;

    address internal constant ethAddr =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IInstaIndex internal constant instaIndex =
        IInstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
    address internal constant wethAddr =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant stEthAddr =
        0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    IAaveProtocolDataProvider internal constant aaveProtocolDataProvider =
        IAaveProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
    IERC20 internal constant awethVariableDebtToken =
        IERC20(0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf);
    IERC20 internal constant astethToken =
        IERC20(0x1982b2F5814301d4e9a8b0201555376e62F82428);
    TokenInterface internal constant wethCoreContract =
        TokenInterface(wethAddr); // contains deposit & withdraw for weth
    IAaveLendingPool internal constant aaveLendingPool =
        IAaveLendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    IERC20 internal constant wethContract = IERC20(wethAddr);
    IERC20 internal constant stEthContract = IERC20(stEthAddr);
    IInstaList internal constant instaList =
        IInstaList(0x4c8a1BEb8a87765788946D6B19C6C6355194AbEb);
    address internal constant rebalancerModuleAddr =
        0xcfCdB64a551478E07Bd07d17CF1525f740173a35;
}

contract Variables is ConstantVariables {

    uint256 internal _status = 1;

    address public auth;

    mapping(address => bool) public isRebalancer;

    IDSA public vaultDsa;

    struct Ratios {
        uint16 maxLimit; // Above this withdrawals are not allowed
        uint16 minLimit; // After leverage the ratio should be below minLimit & above minLimitGap
        uint16 minLimitGap;
        uint128 maxBorrowRate; // maximum borrow rate above this leveraging should not happen
    }

    Ratios public ratios;

    uint256 public lastRevenueExchangePrice;

    uint256 public revenueFee; // 1000 = 10% (10% of user's profit)

    uint256 public revenue;

    uint256 public withdrawalFee; // 10000 = 100%

    uint256 public swapFee;

    uint256 public deleverageFee;
}//MIT
pragma solidity ^0.8.0;

contract Events is Variables {

    event updateAuthLog(address auth_);

    event updateRebalancerLog(address auth_, bool isAuth_);

    event updateRatiosLog(
        uint16 maxLimit,
        uint16 minLimit,
        uint16 gap,
        uint128 maxBorrowRate
    );

    event updateFeesLog(
        uint256 revenueFee_,
        uint256 withdrawalFee_,
        uint256 swapFee_,
        uint256 deleverageFee_
    );

    event changeStatusLog(uint256 status_);

    event supplyLog(address token_, uint256 amount_, address to_);

    event withdrawLog(uint256 amount_, address to_);

    event leverageLog(uint256 amt_, uint256 transferAmt_);

    event deleverageLog(uint256 amt_, uint256 transferAmt_);

    event deleverageAndWithdrawLog(
        uint256 deleverageAmt_,
        uint256 transferAmt_,
        uint256 vtokenAmount_,
        address to_
    );

    event importLog(
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        address to_,
        uint256 stEthAmt_,
        uint256 wethAmt_
    );

    event rebalanceOneLog(
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        address[] vaults_,
        uint256[] amts_,
        uint256 excessDebt_,
        uint256 paybackDebt_,
        uint256 totalAmountToSwap_,
        uint256 extraWithdraw_,
        uint256 unitAmt_
    );

    event rebalanceTwoLog(
        uint256 withdrawAmt_,
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        uint256 saveAmt_,
        uint256 unitAmt_
    );

    event collectRevenueLog(
        uint256 amount_,
        uint256 stethAmt_,
        uint256 wethAmt_,
        address to_
    );
}//MIT
pragma solidity ^0.8.0;


contract Helpers is Events {

    using SafeERC20 for IERC20;

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
            .getReserveData(wethAddr);
    }

    function getStEthCollateralAmount()
        internal
        view
        returns (uint256 stEthAmount_)
    {

        stEthAmount_ = astethToken.balanceOf(address(vaultDsa));
    }

    function getWethDebtAmount()
        internal
        view
        returns (uint256 wethDebtAmount_)
    {

        wethDebtAmount_ = awethVariableDebtToken.balanceOf(address(vaultDsa));
    }

    struct BalVariables {
        uint256 wethVaultBal;
        uint256 wethDsaBal;
        uint256 stethVaultBal;
        uint256 stethDsaBal;
        uint256 totalBal;
    }

    function getIdealBalances()
        public
        view
        returns (BalVariables memory balances_)
    {

        balances_.wethVaultBal = wethContract.balanceOf(address(this));
        balances_.wethDsaBal = wethContract.balanceOf(address(vaultDsa));
        balances_.stethVaultBal = stEthContract.balanceOf(address(this));
        balances_.stethDsaBal = stEthContract.balanceOf(address(vaultDsa));
        balances_.totalBal =
            balances_.wethVaultBal +
            balances_.wethDsaBal +
            balances_.stethVaultBal +
            balances_.stethDsaBal;
    }

    function netAssets()
        public
        view
        returns (
            uint256 netCollateral_,
            uint256 netBorrow_,
            BalVariables memory balances_,
            uint256 netSupply_,
            uint256 netBal_
        )
    {

        netCollateral_ = getStEthCollateralAmount();
        netBorrow_ = getWethDebtAmount();
        balances_ = getIdealBalances();
        netSupply_ = netCollateral_ + balances_.totalBal;
        netBal_ = netSupply_ - netBorrow_;
    }

    function getCurrentExchangePrice()
        public
        view
        returns (uint256 exchangePrice_, uint256 newRevenue_)
    {

        (, , , , uint256 netBal_) = netAssets();
        netBal_ = netBal_ - revenue;
        uint256 totalSupply_ = totalSupply();
        uint256 exchangePriceWithRevenue_;
        if (totalSupply_ != 0) {
            exchangePriceWithRevenue_ = (netBal_ * 1e18) / totalSupply_;
        } else {
            exchangePriceWithRevenue_ = 1e18;
        }
        if (exchangePriceWithRevenue_ > lastRevenueExchangePrice) {
            uint256 newProfit_ = netBal_ -
                ((lastRevenueExchangePrice * totalSupply_) / 1e18);
            newRevenue_ = (newProfit_ * revenueFee) / 10000;
            exchangePrice_ = ((netBal_ - newRevenue_) * 1e18) / totalSupply_;
        } else {
            exchangePrice_ = exchangePriceWithRevenue_;
        }
    }

    function validateFinalRatio()
        internal
        view
        returns (
            bool maxIsOk_,
            bool maxGapIsOk_,
            bool minIsOk_,
            bool minGapIsOk_,
            bool hfIsOk_
        )
    {

        (,,,,,uint hf_) = aaveLendingPool.getUserAccountData(address(vaultDsa));
        (
            uint256 netCollateral_,
            uint256 netBorrow_,
            ,
            uint256 netSupply_,

        ) = netAssets();
        uint256 ratioMax_ = (netBorrow_ * 1e4) / netCollateral_; // Aave position ratio should not go above max limit
        maxIsOk_ = ratios.maxLimit > ratioMax_;
        maxGapIsOk_ = ratioMax_ > ratios.maxLimit - 100;
        uint256 ratioMin_ = (netBorrow_ * 1e4) / netSupply_; // net ratio (position + ideal) should not go above min limit
        minIsOk_ = ratios.minLimit > ratioMin_;
        minGapIsOk_ = ratios.minLimitGap < ratioMin_;
        hfIsOk_ = hf_ > 1015 * 1e15; // HF should be more than 1.015 (this will allow ratio to always stay below 74%)
    }

}//MIT
pragma solidity ^0.8.0;



contract AdminModule is Helpers {

    using SafeERC20 for IERC20;

    modifier onlyAuth() {

        require(auth == msg.sender, "only auth");
        _;
    }

    modifier onlyRebalancer() {

        require(
            isRebalancer[msg.sender] || auth == msg.sender,
            "only rebalancer"
        );
        _;
    }

    function updateAuth(address auth_) external onlyAuth {

        auth = auth_;
        emit updateAuthLog(auth_);
    }

    function updateRebalancer(address rebalancer_, bool isRebalancer_)
        external
        onlyAuth
    {

        isRebalancer[rebalancer_] = isRebalancer_;
        emit updateRebalancerLog(rebalancer_, isRebalancer_);
    }

    function updateFees(
        uint256 revenueFee_,
        uint256 withdrawalFee_,
        uint256 swapFee_,
        uint256 deleverageFee_
    ) external onlyAuth {

        require(revenueFee_ < 10000, "fees-not-valid");
        require(withdrawalFee_ < 10000, "fees-not-valid");
        require(swapFee_ < 10000, "fees-not-valid");
        require(deleverageFee_ < 10000, "fees-not-valid");
        revenueFee = revenueFee_;
        withdrawalFee = withdrawalFee_;
        swapFee = swapFee_;
        deleverageFee = deleverageFee_;
        emit updateFeesLog(
            revenueFee_,
            withdrawalFee_,
            swapFee_,
            deleverageFee_
        );
    }

    function updateRatios(uint16[] memory ratios_) external onlyAuth {

        ratios = Ratios(
            ratios_[0],
            ratios_[1],
            ratios_[2],
            uint128(ratios_[3]) * 1e23
        );
        emit updateRatiosLog(
            ratios_[0],
            ratios_[1],
            ratios_[2],
            uint128(ratios_[3]) * 1e23
        );
    }

    function changeStatus(uint256 status_) external onlyAuth {

        _status = status_;
        emit changeStatusLog(status_);
    }



    function spell(
        address to_,
        bytes memory calldata_,
        uint256 value_,
        uint256 operation_
    ) external payable onlyAuth {

        if (operation_ == 0) {
            Address.functionCallWithValue(
                to_,
                calldata_,
                value_,
                "spell: .call failed"
            );
        } else if (operation_ == 1) {
            Address.functionDelegateCall(
                to_,
                calldata_,
                "spell: .delegateCall failed"
            );
        } else {
            revert("no operation");
        }
    }

    function addDSAAuth(address auth_) external onlyAuth {

        string[] memory targets_ = new string[](1);
        bytes[] memory calldata_ = new bytes[](1);
        targets_[0] = "AUTHORITY-A";
        calldata_[0] = abi.encodeWithSignature("add(address)", auth_);
        vaultDsa.cast(targets_, calldata_, address(this));
    }
}

contract CoreHelpers is AdminModule {

    using SafeERC20 for IERC20;

    function updateStorage(uint256 exchangePrice_, uint256 newRevenue_)
        internal
    {

        if (exchangePrice_ > lastRevenueExchangePrice) {
            lastRevenueExchangePrice = exchangePrice_;
            revenue = revenue + newRevenue_;
        }
    }

    function supplyInternal(
        address token_,
        uint256 amount_,
        address to_,
        bool isEth_
    ) internal returns (uint256 vtokenAmount_) {

        require(amount_ != 0, "amount cannot be zero");
        (
            uint256 exchangePrice_,
            uint256 newRevenue_
        ) = getCurrentExchangePrice();
        updateStorage(exchangePrice_, newRevenue_);
        if (isEth_) {
            wethCoreContract.deposit{value: amount_}();
        } else {
            require(token_ == stEthAddr || token_ == wethAddr, "wrong-token");
            IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
        }
        vtokenAmount_ = (amount_ * 1e18) / exchangePrice_;
        _mint(to_, vtokenAmount_);
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

    function withdrawFinal(uint256 amount_, bool afterDeleverage_)
        public
        view
        returns (uint256[] memory transferAmts_)
    {

        require(amount_ > 0, "amount-invalid");

        (
            uint256 netCollateral_,
            uint256 netBorrow_,
            BalVariables memory balances_,
            ,

        ) = netAssets();

        uint256 margin_ = afterDeleverage_ ? 5 : 10; // 0.05% margin or  0.1% margin
        uint256 colCoveringDebt_ = ((netBorrow_ * 10000) /
            (ratios.maxLimit - margin_));
        uint256 netColLimit_ = netCollateral_ > colCoveringDebt_
            ? netCollateral_ - colCoveringDebt_
            : 0;

        require(
            amount_ < (balances_.totalBal + netColLimit_),
            "excess-withdrawal"
        );

        transferAmts_ = new uint256[](5);
        if (balances_.wethVaultBal > 10) {
            (amount_, transferAmts_[0]) = withdrawHelper(
                amount_,
                balances_.wethVaultBal
            );
        }
        if (balances_.wethDsaBal > 10 && amount_ > 0) {
            (amount_, transferAmts_[1]) = withdrawHelper(
                amount_,
                balances_.wethDsaBal
            );
        }
        if (balances_.stethVaultBal > 10 && amount_ > 0) {
            (amount_, transferAmts_[2]) = withdrawHelper(
                amount_,
                balances_.stethVaultBal
            );
        }
        if (balances_.stethDsaBal > 10 && amount_ > 0) {
            (amount_, transferAmts_[3]) = withdrawHelper(
                amount_,
                balances_.stethDsaBal
            );
        }
        if (netColLimit_ > 10 && amount_ > 0) {
            (amount_, transferAmts_[4]) = withdrawHelper(amount_, netColLimit_);
        }
    }

    function withdrawTransfers(uint256 amount_, uint256[] memory transferAmts_)
        internal
        returns (uint256 wethAmt_, uint256 stEthAmt_)
    {

        wethAmt_ = transferAmts_[0] + transferAmts_[1];
        stEthAmt_ = transferAmts_[2] + transferAmts_[3] + transferAmts_[4];
        uint256 totalTransferAmount_ = wethAmt_ + stEthAmt_;
        require(amount_ == totalTransferAmount_, "transfers-not-valid");
        uint256 i;
        uint256 j;
        if (transferAmts_[4] > 0) j += 1;
        if (transferAmts_[1] > 0) j += 1;
        if (transferAmts_[3] > 0 || transferAmts_[4] > 0) j += 1;
        if (j == 0) return (wethAmt_, stEthAmt_);
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        if (transferAmts_[4] > 0) {
            targets_[i] = "AAVE-V2-A";
            calldata_[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                stEthAddr,
                transferAmts_[4],
                0,
                0
            );
            i++;
        }
        if (transferAmts_[1] > 0) {
            targets_[i] = "BASIC-A";
            calldata_[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                wethAddr,
                transferAmts_[1],
                address(this),
                0,
                0
            );
            i++;
        }
        if (transferAmts_[3] > 0 || transferAmts_[4] > 0) {
            targets_[i] = "BASIC-A";
            calldata_[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                stEthAddr,
                transferAmts_[3] + transferAmts_[4],
                address(this),
                0,
                0
            );
            i++;
        }
        if (j > 0) vaultDsa.cast(targets_, calldata_, address(this));
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
        uint256 fee_ = (amount_ * withdrawalFee) / 10000;
        uint256 amountAfterFee_ = amount_ - fee_;

        uint256[] memory transferAmts_ = withdrawFinal(
            amountAfterFee_,
            afterDeleverage_
        );

        (uint256 wethAmt_, uint256 stEthAmt_) = withdrawTransfers(
            amountAfterFee_,
            transferAmts_
        );
        (bool maxIsOk_, , , , bool hfIsOk_) = validateFinalRatio();

        require(maxIsOk_ && hfIsOk_, "Aave-position-risky");

        if (wethAmt_ > 0) {
            wethCoreContract.withdraw(wethAmt_);
            Address.sendValue(payable(to_), wethAmt_);
        }
        if (stEthAmt_ > 0) stEthContract.safeTransfer(to_, stEthAmt_);

        if (afterDeleverage_) {
            (, , , bool minGapIsOk_, ) = validateFinalRatio();
            require(minGapIsOk_, "Aave-position-risky");
        }
    }

    function deleverageInternal(uint256 amt_)
        internal
        returns (uint256 transferAmt_)
    {

        require(amt_ > 0, "not-valid-amount");
        wethContract.safeTransferFrom(msg.sender, address(vaultDsa), amt_);

        bool isDsa_ = instaList.accountID(msg.sender) > 0;

        uint256 i;
        uint256 j = isDsa_ ? 2 : 3;
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        targets_[0] = "AAVE-V2-A";
        calldata_[0] = abi.encodeWithSignature(
            "payback(address,uint256,uint256,uint256,uint256)",
            wethAddr,
            amt_,
            2,
            0,
            0
        );
        if (!isDsa_) {
            transferAmt_ = amt_ + ((amt_ * deleverageFee) / 10000);
            targets_[1] = "AAVE-V2-A";
            calldata_[1] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                stEthAddr,
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
            isDsa_ ? address(astethToken) : stEthAddr,
            transferAmt_,
            msg.sender,
            0,
            0
        );
        vaultDsa.cast(targets_, calldata_, address(this));
    }
}

contract InstaVaultImplementation is CoreHelpers {

    using SafeERC20 for IERC20;

    function supplyEth(address to_)
        external
        payable
        nonReentrant
        returns (uint256 vtokenAmount_)
    {

        uint256 amount_ = msg.value;
        vtokenAmount_ = supplyInternal(ethAddr, amount_, to_, true);
        emit supplyLog(ethAddr, amount_, to_);
    }

    function supply(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant returns (uint256 vtokenAmount_) {

        vtokenAmount_ = supplyInternal(token_, amount_, to_, false);
        emit supplyLog(token_, amount_, to_);
    }

    function withdraw(uint256 amount_, address to_)
        external
        nonReentrant
        returns (uint256 vtokenAmount_)
    {

        vtokenAmount_ = withdrawInternal(amount_, to_, false);
        emit withdrawLog(amount_, to_);
    }

    function leverage(uint256 amt_) external nonReentrant {

        require(amt_ > 0, "not-valid-amount");
        uint256 fee_ = (amt_ * swapFee) / 10000;
        uint256 transferAmt_ = amt_ - fee_;
        revenue += fee_;

        stEthContract.safeTransferFrom(msg.sender, address(this), amt_);

        uint256 wethVaultBal_ = wethContract.balanceOf(address(this));
        uint256 stethVaultBal_ = stEthContract.balanceOf(address(this));

        if (wethVaultBal_ >= transferAmt_) {
            wethContract.safeTransfer(msg.sender, transferAmt_);
        } else {
            uint256 remainingTransferAmt_ = transferAmt_;
            if (wethVaultBal_ > 1e14) {
                remainingTransferAmt_ -= wethVaultBal_;
                wethContract.safeTransfer(msg.sender, wethVaultBal_);
            }
            uint256 i;
            uint256 j = 2;
            if (stethVaultBal_ > 1e14) {
                stEthContract.safeTransfer(address(vaultDsa), stethVaultBal_);
                j = 3;
            }
            string[] memory targets_ = new string[](j);
            bytes[] memory calldata_ = new bytes[](j);
            if (stethVaultBal_ > 1e14) {
                targets_[i] = "AAVE-V2-A";
                calldata_[i] = abi.encodeWithSignature(
                    "deposit(address,uint256,uint256,uint256)",
                    stEthAddr,
                    stethVaultBal_,
                    0,
                    0
                );
                i++;
            }
            targets_[i] = "AAVE-V2-A";
            calldata_[i] = abi.encodeWithSignature(
                "borrow(address,uint256,uint256,uint256,uint256)",
                wethAddr,
                remainingTransferAmt_,
                2,
                0,
                0
            );
            targets_[i + 1] = "BASIC-A";
            calldata_[i + 1] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                wethAddr,
                remainingTransferAmt_,
                msg.sender,
                0,
                0
            );
            vaultDsa.cast(targets_, calldata_, address(this));
            (bool maxIsOk_, , bool minIsOk_, , ) = validateFinalRatio();
            require(minIsOk_ && maxIsOk_, "excess-leverage");
        }

        emit leverageLog(amt_, transferAmt_);
    }

    function deleverage(uint256 amt_) external nonReentrant {

        uint256 transferAmt_ = deleverageInternal(amt_);
        (, , , bool minGapIsOk_, ) = validateFinalRatio();
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

    struct ImportPositionVariables {
        uint256 ratioLimit;
        uint256 importNetAmt;
        uint256 initialDsaAsteth;
        uint256 initialDsaWethDebt;
        uint256 finalDsaAsteth;
        uint256 finalDsaWethDebt;
        uint256 dsaDif;
        bytes encodedFlashData;
        string[] flashTarget;
        bytes[] flashCalldata;
        bool[] checks;
    }

    function importPosition(
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        address to_,
        uint256 stEthAmt_,
        uint256 wethAmt_
    ) external nonReentrant {

        ImportPositionVariables memory v_;

        stEthAmt_ = stEthAmt_ == type(uint256).max
            ? astethToken.balanceOf(msg.sender)
            : stEthAmt_;
        wethAmt_ = wethAmt_ == type(uint256).max
            ? awethVariableDebtToken.balanceOf(msg.sender)
            : wethAmt_;

        v_.importNetAmt = stEthAmt_ - wethAmt_;
        v_.ratioLimit = (wethAmt_ * 1e4) / stEthAmt_;
        require(v_.ratioLimit <= ratios.maxLimit, "risky-import");

        (
            uint256 exchangePrice_,
            uint256 newRevenue_
        ) = getCurrentExchangePrice();
        updateStorage(exchangePrice_, newRevenue_);

        v_.initialDsaAsteth = astethToken.balanceOf(address(vaultDsa));
        v_.initialDsaWethDebt = awethVariableDebtToken.balanceOf(
            address(vaultDsa)
        );

        uint256 j = flashAmt_ > 0 ? 6 : 3;
        uint256 i;
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        if (flashAmt_ > 0) {
            require(flashTkn_ != address(0), "wrong-flash-token");
            targets_[0] = "AAVE-V2-A";
            calldata_[0] = abi.encodeWithSignature(
                "deposit(address,uint256,uint256,uint256)",
                flashTkn_,
                flashAmt_,
                0,
                0
            );
            i++;
        }
        targets_[i] = "AAVE-V2-A";
        calldata_[i] = abi.encodeWithSignature(
            "borrow(address,uint256,uint256,uint256)",
            wethAddr,
            wethAmt_,
            0,
            0
        );
        targets_[i + 1] = "AAVE-V2-A";
        calldata_[i + 1] = abi.encodeWithSignature(
            "paybackOnBehalfOf(address,uint256,uint256,address,uint256,uint256)",
            wethAddr,
            wethAmt_,
            2,
            msg.sender,
            0,
            0
        );
        targets_[i + 2] = "BASIC-A";
        calldata_[i + 2] = abi.encodeWithSignature(
            "depositFrom(address,uint256,address,uint256,uint256)",
            astethToken,
            stEthAmt_,
            msg.sender,
            0,
            0
        );
        if (flashAmt_ > 0) {
            targets_[i + 3] = "AAVE-V2-A";
            calldata_[i + 3] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                flashTkn_,
                flashAmt_,
                0,
                0
            );
            targets_[i + 4] = "INSTAPOOL-C";
            calldata_[i + 4] = abi.encodeWithSignature(
                "flashPayback(address,uint256,uint256,uint256)",
                flashTkn_,
                flashAmt_,
                0,
                0
            );
        }
        if (flashAmt_ > 0) {
            v_.encodedFlashData = abi.encode(targets_, calldata_);

            v_.flashTarget = new string[](1);
            v_.flashCalldata = new bytes[](1);
            v_.flashTarget[0] = "INSTAPOOL-C";
            v_.flashCalldata[0] = abi.encodeWithSignature(
                "flashBorrowAndCast(address,uint256,uint256,bytes,bytes)",
                flashTkn_,
                flashAmt_,
                route_,
                v_.encodedFlashData,
                "0x"
            );

            vaultDsa.cast(v_.flashTarget, v_.flashCalldata, address(this));
        } else {
            vaultDsa.cast(targets_, calldata_, address(this));
        }

        v_.finalDsaAsteth = astethToken.balanceOf(address(vaultDsa));
        v_.finalDsaWethDebt = awethVariableDebtToken.balanceOf(
            address(vaultDsa)
        );

        v_.dsaDif =
            (v_.finalDsaAsteth - v_.finalDsaWethDebt) -
            (v_.initialDsaAsteth - v_.initialDsaWethDebt);
        require(v_.importNetAmt < v_.dsaDif + 1e9, "import-check-fail"); // Adding 1e9 for decimal problem that might occur due to Aave's calculation

        v_.checks = new bool[](2);

        (v_.checks[0], , , , v_.checks[1]) = validateFinalRatio();
        require(v_.checks[0] && v_.checks[1], "Import: position-is-risky");

        uint256 vtokenAmount_ = (v_.importNetAmt * 1e18) / exchangePrice_;
        _mint(to_, vtokenAmount_);

        emit importLog(flashTkn_, flashAmt_, route_, to_, stEthAmt_, wethAmt_);
    }

    function rebalanceOne(
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        address[] memory vaults_, // leverage using other vaults
        uint256[] memory amts_,
        uint256 excessDebt_,
        uint256 paybackDebt_,
        uint256 totalAmountToSwap_,
        uint256 extraWithdraw_,
        uint256 unitAmt_,
        bytes memory oneInchData_
    ) external nonReentrant onlyRebalancer {

        Address.functionDelegateCall(rebalancerModuleAddr, msg.data);
    }

    function rebalanceTwo(
        uint256 withdrawAmt_,
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        uint256 totalAmountToSwap_,
        uint256 unitAmt_,
        bytes memory oneInchData_
    ) external nonReentrant onlyRebalancer {

        Address.functionDelegateCall(rebalancerModuleAddr, msg.data);
    }

    function collectRevenue(uint256 amount_, address to_) external onlyAuth {

        require(amount_ != 0, "amount-cannot-be-zero");
        if (amount_ == type(uint256).max) amount_ = revenue;
        require(amount_ <= revenue, "not-enough-revenue");
        revenue -= amount_;

        uint256 stethAmt_;
        uint256 wethAmt_;
        uint256 wethVaultBal_ = wethContract.balanceOf(address(this));
        uint256 stethVaultBal_ = stEthContract.balanceOf(address(this));
        if (wethVaultBal_ > 10)
            (amount_, wethAmt_) = withdrawHelper(amount_, wethVaultBal_);
        if (amount_ > 0 && stethVaultBal_ > 10)
            (amount_, stethAmt_) = withdrawHelper(amount_, stethVaultBal_);
        require(amount_ == 0, "not-enough-amount-inside-vault");
        if (wethAmt_ > 0) wethContract.safeTransfer(to_, wethAmt_);
        if (stethAmt_ > 0) stEthContract.safeTransfer(to_, stethAmt_);

        emit collectRevenueLog(stethAmt_ + wethAmt_, stethAmt_, wethAmt_, to_);
    }

    function name() public pure override returns (string memory) {

        return "Instadapp ETH";
    }

    function symbol() public pure override returns (string memory) {

        return "iETH";
    }


    receive() external payable {}
}