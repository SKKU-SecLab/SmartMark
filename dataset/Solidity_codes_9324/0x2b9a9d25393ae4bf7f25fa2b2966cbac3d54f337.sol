
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
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
    uint256 internal constant liquidationThreshold = 7500;
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

    event updateRevenueFeeLog(uint256 oldRevenueFee_, uint256 newRevenueFee_);

    event updateWithdrawalFeeLog(
        uint256 oldWithdrawalFee_,
        uint256 newWithdrawalFee_
    );

    event changeStatusLog(uint256 status_);

    event supplyLog(address token_, uint256 amount_, address to_);

    event withdrawLog(uint256 amount_, address to_);

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

        IERC20 wethCon_ = IERC20(wethAddr);
        IERC20 stethCon_ = IERC20(stEthAddr);
        balances_.wethVaultBal = wethCon_.balanceOf(address(this));
        balances_.wethDsaBal = wethCon_.balanceOf(address(vaultDsa));
        balances_.stethVaultBal = stethCon_.balanceOf(address(this));
        balances_.stethDsaBal = stethCon_.balanceOf(address(vaultDsa));
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

    function updateRevenueFee(uint256 newRevenueFee_) external onlyAuth {

        uint256 oldRevenueFee_ = revenueFee;
        revenueFee = newRevenueFee_;
        emit updateRevenueFeeLog(oldRevenueFee_, newRevenueFee_);
    }

    function updateWithdrawalFee(uint256 newWithdrawalFee_) external onlyAuth {

        uint256 oldWithdrawalFee_ = withdrawalFee;
        withdrawalFee = newWithdrawalFee_;
        emit updateWithdrawalFeeLog(oldWithdrawalFee_, newWithdrawalFee_);
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

    function supplyToken(address token_, uint256 amount_) external onlyAuth {

        IERC20(token_).safeTransferFrom(msg.sender, address(vaultDsa), amount_);
        string[] memory targets_ = new string[](1);
        bytes[] memory calldata_ = new bytes[](1);
        targets_[0] = "AAVE-V2-A";
        calldata_[0] = abi.encodeWithSignature(
            "deposit(address,uint256,uint256,uint256)",
            token_,
            amount_,
            0,
            0
        );
        vaultDsa.cast(targets_, calldata_, address(this));
    }

    function withdrawToken(address token_, uint256 amount_) external onlyAuth {

        string[] memory targets_ = new string[](2);
        bytes[] memory calldata_ = new bytes[](2);
        targets_[0] = "AAVE-V2-A";
        calldata_[0] = abi.encodeWithSignature(
            "withdraw(address,uint256,uint256,uint256)",
            token_,
            amount_,
            0,
            0
        );
        targets_[1] = "BASIC-A";
        calldata_[1] = abi.encodeWithSignature(
            "withdraw(address,uint256,address,uint256,uint256)",
            token_,
            amount_,
            auth,
            0,
            0
        );
        vaultDsa.cast(targets_, calldata_, address(this));
    }

    function spell(address to_, bytes memory calldata_, uint256 value_, uint256 operation_) external payable onlyAuth {

        if (operation_ == 0) {
            Address.functionCallWithValue(to_, calldata_, value_, "spell: .call failed");
        } else if (operation_ == 1) {
            Address.functionDelegateCall(to_, calldata_, "spell: .delegateCall failed");
        } else {
            revert("no operation");
        }
    }

    function addDSAAuth(address auth_) external onlyAuth {

        string[] memory targets_ = new string[](1);
        bytes[] memory calldata_ = new bytes[](1);
        targets_[0] = "AUTHORITY-A";
        calldata_[0] = abi.encodeWithSignature(
            "add(address)",
            auth_
        );
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
            if (token_ == stEthAddr) {
                IERC20(token_).safeTransferFrom(
                    msg.sender,
                    address(this),
                    amount_
                );
            } else if (token_ == wethAddr) {
                IERC20(token_).safeTransferFrom(
                    msg.sender,
                    address(this),
                    amount_
                );
            } else {
                revert("wrong-token");
            }
        }
        vtokenAmount_ = (amount_ * 1e18) / exchangePrice_;
        _mint(to_, vtokenAmount_);
        emit supplyLog(token_, amount_, to_);
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

        uint256 ratio_ = netCollateral_ > 0
            ? (netBorrow_ * 1e4) / netCollateral_
            : 0;
        require(ratio_ < ratios.maxLimit, "already-risky"); // don't allow any withdrawal if aave position is risky

        require(amount_ < balances_.totalBal, "excess-withdrawal");

        transferAmts_ = new uint256[](4);
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
    }

    function withdrawTransfers(uint256 amount_, uint256[] memory transferAmts_)
        internal
        returns (uint256 wethAmt_, uint256 stEthAmt_)
    {

        wethAmt_ = transferAmts_[0] + transferAmts_[1];
        stEthAmt_ = transferAmts_[2] + transferAmts_[3];
        uint256 totalTransferAmount_ = wethAmt_ + stEthAmt_;
        require(amount_ == totalTransferAmount_, "transfers-not-valid");
        uint256 i;
        uint256 j;
        if (transferAmts_[1] > 0 && transferAmts_[3] > 0) {
            i = 2;
        } else if (transferAmts_[3] > 0 || transferAmts_[1] > 0) {
            i = 1;
        } else {
            return (wethAmt_, stEthAmt_);
        }
        string[] memory targets_ = new string[](i);
        bytes[] memory calldata_ = new bytes[](i);
        if (transferAmts_[1] > 0) {
            targets_[j] = "BASIC-A";
            calldata_[j] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                wethAddr,
                transferAmts_[1],
                address(this),
                0,
                0
            );
            j++;
        }
        if (transferAmts_[3] > 0) {
            targets_[j] = "BASIC-A";
            calldata_[j] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                stEthAddr,
                transferAmts_[3],
                address(this),
                0,
                0
            );
            j++;
        }
        if (i > 0) vaultDsa.cast(targets_, calldata_, address(this));
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
    }

    function supply(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant returns (uint256 vtokenAmount_) {

        vtokenAmount_ = supplyInternal(token_, amount_, to_, false);
    }

    function withdraw(uint256 amount_, address to_)
        external
        nonReentrant
        returns (uint256 vtokenAmount_)
    {

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

        uint256[] memory transferAmts_ = withdrawFinal(amountAfterFee_);

        (uint256 wethAmt_, uint256 stEthAmt_) = withdrawTransfers(
            amountAfterFee_,
            transferAmts_
        );

        if (wethAmt_ > 0) {
            wethCoreContract.withdraw(wethAmt_);
            Address.sendValue(payable(to_), wethAmt_);
        }
        if (stEthAmt_ > 0) stEthContract.safeTransfer(to_, stEthAmt_);

        emit withdrawLog(amount_, to_);
    }

    struct RebalanceOneVariables {
        uint256 stETHBal_;
        string[] targets;
        bytes[] calldatas;
        bool[] checks;
        uint length;
        bool isOk;
        bytes encodedFlashData;
        string[] flashTarget;
        bytes[] flashCalldata;
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

        if (excessDebt_ < 1e14) excessDebt_ = 0;
        if (paybackDebt_ < 1e14) paybackDebt_ = 0;
        if (totalAmountToSwap_ < 1e14) totalAmountToSwap_ = 0;
        if (extraWithdraw_ < 1e14) extraWithdraw_ = 0;

        RebalanceOneVariables memory v_;

        v_.length = amts_.length;
        require(vaults_.length == v_.length, "unequal-length");

        require(
            !(excessDebt_ > 0 && paybackDebt_ > 0),
            "cannot-borrow-and-payback-at-once"
        );
        require(
            !(totalAmountToSwap_ > 0 && paybackDebt_ > 0),
            "cannot-swap-and-payback-at-once"
        );
        require(
            !((totalAmountToSwap_ > 0 || v_.length > 0) && excessDebt_ == 0),
            "cannot-swap-and-when-zero-excess-debt"
        );

        BalVariables memory balances_ = getIdealBalances();

        if (balances_.wethVaultBal > 1e14)
            wethContract.safeTransfer(
                address(vaultDsa),
                balances_.wethVaultBal
            );
        if (balances_.stethVaultBal > 1e14)
            stEthContract.safeTransfer(
                address(vaultDsa),
                balances_.stethVaultBal
            );
        v_.stETHBal_ = balances_.stethVaultBal + balances_.stethDsaBal;
        if (v_.stETHBal_ < 1e14) v_.stETHBal_ = 0;

        uint256 i;
        uint256 j;
        if (excessDebt_ > 0) j += 4;
        if (v_.length > 0) j += v_.length;
        if (totalAmountToSwap_ > 0) j += 1;
        if (excessDebt_ > 0 && (totalAmountToSwap_ > 0 || v_.stETHBal_ > 0)) j += 1;
        if (paybackDebt_ > 0) j += 1;
        if (v_.stETHBal_ > 0 && excessDebt_ == 0) j += 1;
        if (extraWithdraw_ > 0) j += 2;
        v_.targets = new string[](j);
        v_.calldatas = new bytes[](j);
        if (excessDebt_ > 0) {
            v_.targets[0] = "AAVE-V2-A";
            v_.calldatas[0] = abi.encodeWithSignature(
                "deposit(address,uint256,uint256,uint256)",
                flashTkn_,
                flashAmt_,
                0,
                0
            );
            v_.targets[1] = "AAVE-V2-A";
            v_.calldatas[1] = abi.encodeWithSignature(
                "borrow(address,uint256,uint256,uint256,uint256)",
                wethAddr,
                excessDebt_,
                2,
                0,
                0
            );
            i = 2;
            for (uint k = 0; k < v_.length; k++) {
                v_.targets[i] = "LITE-A"; // Instadapp Lite vaults connector
                v_.calldatas[i] = abi.encodeWithSignature(
                    "deleverage(address,uint256,uint256,uint256)",
                    vaults_[k],
                    amts_[k],
                    0,
                    0
                );
                i++;
            }
            if (totalAmountToSwap_ > 0) {
                require(unitAmt_ > (1e18 - 10), "invalid-unit-amt");
                v_.targets[i] = "1INCH-A";
                v_.calldatas[i] = abi.encodeWithSignature(
                    "sell(address,address,uint256,uint256,bytes,uint256)",
                    stEthAddr,
                    wethAddr,
                    totalAmountToSwap_,
                    unitAmt_,
                    oneInchData_,
                    0
                );
                i++;
            }
            if (totalAmountToSwap_ > 0 || v_.stETHBal_ > 0) {
                v_.targets[i] = "AAVE-V2-A";
                v_.calldatas[i] = abi.encodeWithSignature(
                    "deposit(address,uint256,uint256,uint256)",
                    stEthAddr,
                    type(uint256).max,
                    0,
                    0
                );
                i++;
            }
            v_.targets[i] = "AAVE-V2-A";
            v_.calldatas[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                flashTkn_,
                flashAmt_,
                0,
                0
            );
            v_.targets[i + 1] = "INSTAPOOL-C";
            v_.calldatas[i + 1] = abi.encodeWithSignature(
                "flashPayback(address,uint256,uint256,uint256)",
                flashTkn_,
                flashAmt_,
                0,
                0
            );
            i += 2;
        }
        if (paybackDebt_ > 0) {
            v_.targets[i] = "AAVE-V2-A";
            v_.calldatas[i] = abi.encodeWithSignature(
                "payback(address,uint256,uint256,uint256,uint256)",
                wethAddr,
                paybackDebt_,
                2,
                0,
                0
            );
            i++;
        }
        if (v_.stETHBal_ > 0 && excessDebt_ == 0) {
            v_.targets[i] = "AAVE-V2-A";
            v_.calldatas[i] = abi.encodeWithSignature(
                "deposit(address,uint256,uint256,uint256)",
                stEthAddr,
                type(uint256).max,
                0,
                0
            );
            i++;
        }
        if (extraWithdraw_ > 0) {
            v_.targets[i] = "AAVE-V2-A";
            v_.calldatas[i] = abi.encodeWithSignature(
                "withdraw(address,uint256,uint256,uint256)",
                stEthAddr,
                extraWithdraw_,
                0,
                0
            );
            v_.targets[i + 1] = "BASIC-A";
            v_.calldatas[i + 1] = abi.encodeWithSignature(
                "withdraw(address,uint256,address,uint256,uint256)",
                stEthAddr,
                extraWithdraw_,
                address(this),
                0,
                0
            );
        }

        if (excessDebt_ > 0) {
            v_.encodedFlashData = abi.encode(
                v_.targets,
                v_.calldatas
            );

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
            require(
                getWethBorrowRate() < ratios.maxBorrowRate,
                "high-borrow-rate"
            );
        } else {
            if (j > 0) vaultDsa.cast(v_.targets, v_.calldatas, address(this));
        }

        v_.checks = new bool[](4);
        (v_.checks[0],, v_.checks[1], v_.checks[2], v_.checks[3]) = validateFinalRatio();
        if (excessDebt_ > 0) require(v_.checks[1], "position-risky-after-leverage");
        if (extraWithdraw_ > 0) require(v_.checks[0], "position-risky");
        if (excessDebt_ > 0 && extraWithdraw_ > 0) require(v_.checks[3], "position-hf-risky");

        emit rebalanceOneLog(
            flashTkn_,
            flashAmt_,
            route_,
            vaults_,
            amts_,
            excessDebt_,
            paybackDebt_,
            totalAmountToSwap_,
            extraWithdraw_,
            unitAmt_
        );
    }

    function rebalanceTwo(
        uint256 withdrawAmt_,
        address flashTkn_,
        uint256 flashAmt_,
        uint256 route_,
        uint256 saveAmt_,
        uint256 unitAmt_,
        bytes memory oneInchData_
    ) external nonReentrant onlyRebalancer {

        (,,,, bool hfIsOk_) = validateFinalRatio();
        if (hfIsOk_) {
            require(unitAmt_ > (1e18 - (2 * 1e16)), "excess-slippage"); // Here's it's 2% slippage.
        } else {
            require(unitAmt_ > (1e18 - (5 * 1e16)), "excess-slippage");
        }
        uint j = 3;
        uint i = 0;
        if (flashAmt_ > 0) j += 3;
        string[] memory targets_ = new string[](j);
        bytes[] memory calldata_ = new bytes[](j);
        if (flashAmt_ > 0) {
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
            "withdraw(address,uint256,uint256,uint256)",
            stEthAddr,
            (saveAmt_ + withdrawAmt_),
            0,
            0
        );
        targets_[i + 1] = "1INCH-A";
        calldata_[i + 1] = abi.encodeWithSignature(
            "sell(address,address,uint256,uint256,bytes,uint256)",
            wethAddr,
            stEthAddr,
            saveAmt_,
            unitAmt_,
            oneInchData_,
            0
        );
        targets_[i + 2] = "AAVE-V2-A";
        calldata_[i + 2] = abi.encodeWithSignature(
            "payback(address,uint256,uint256,uint256,uint256)",
            wethAddr,
            type(uint256).max,
            2,
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
            bytes memory encodedFlashData_ = abi.encode(targets_, calldata_);

            string[] memory flashTarget_ = new string[](1);
            bytes[] memory flashCalldata_ = new bytes[](1);
            flashTarget_[0] = "INSTAPOOL-C";
            flashCalldata_[0] = abi.encodeWithSignature(
                "flashBorrowAndCast(address,uint256,uint256,bytes,bytes)",
                flashTkn_,
                flashAmt_,
                route_,
                encodedFlashData_,
                "0x"
            );

            vaultDsa.cast(flashTarget_, flashCalldata_, address(this));
        } else {
            vaultDsa.cast(targets_, calldata_, address(this));
        }

        (, bool maxGapIsOk_, , bool minGapIsOk_,) = validateFinalRatio();
        if (!hfIsOk_) {
            require(minGapIsOk_, "position-over-saved");
        } else {
            require(maxGapIsOk_, "position-over-saved");
        }

        emit rebalanceTwoLog(
            withdrawAmt_,
            flashTkn_,
            flashAmt_,
            route_,
            saveAmt_,
            unitAmt_
        );
    }

    function name() public pure override returns (string memory) {

        return "Instadapp ETH";
    }

    function symbol() public pure override returns (string memory) {

        return "iETH";
    }


    receive() external payable {}
}