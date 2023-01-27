
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

    function getUserReserveData(address asset, address user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentStableDebt,
            uint256 currentVariableDebt,
            uint256 principalStableDebt,
            uint256 scaledVariableDebt,
            uint256 stableBorrowRate,
            uint256 liquidityRate,
            uint40 stableRateLastUpdated,
            bool usageAsCollateralEnabled
        );


    function getReserveConfigurationData(address asset)
        external
        view
        returns (
            uint256 decimals,
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            uint256 reserveFactor,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive,
            bool isFrozen
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

    address internal constant ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IInstaIndex internal constant instaIndex =
        IInstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
    address internal constant wethAddr =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant stEthAddr =
        0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    IAaveProtocolDataProvider internal constant aaveProtocolDataProvider =
        IAaveProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
}

contract Variables is ConstantVariables {


    uint256 internal _status;

    IDSA public vaultDsa;

    uint256 public lastRevenueExchangePrice;

    uint256 public safeDistancePercentage; // 10000 = 100%, used in withdraw & rebalance with leverage

    uint256 public withdrawalTime; // in seconds.

    uint256 public revenueFee; // 1000 = 10% (10% of user's profit)

    uint256 public revenue;

    uint256 public totalWithdrawAwaiting;

    struct Withdraw {
        uint128 amount;
        uint128 time; // time at which amount will be available to withdraw
    }

    mapping (address => Withdraw[]) public userWithdrawAwaiting;

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
}//Unlicense
pragma solidity ^0.8.0;


contract Helpers is Variables {

    using SafeERC20 for IERC20;

    modifier nonReentrant() {

        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function getStEthCollateralAmount()
        internal
        view
        returns (uint256 stEthAmount_)
    {

        (stEthAmount_, , , , , , , , ) = aaveProtocolDataProvider
            .getUserReserveData(stEthAddr, address(vaultDsa));
    }

    function getWethDebtAmount()
        internal
        view
        returns (uint256 ethDebtAmount_)
    {

        (, , ethDebtAmount_, , , , , , ) = aaveProtocolDataProvider
            .getUserReserveData(wethAddr, address(vaultDsa));
    }

    struct BalVariables {
        uint wethVaultBal;
        uint wethDsaBal;
        uint stethVaultBal;
        uint stethDsaBal;
        uint totalBal;
    }

    function getIdealBalances() public view returns (
        BalVariables memory balances_
    ) {

        IERC20 wethCon_ = IERC20(wethAddr);
        IERC20 stethCon_ = IERC20(stEthAddr);
        balances_.wethVaultBal = wethCon_.balanceOf(address(this));
        balances_.wethDsaBal = wethCon_.balanceOf(address(vaultDsa));
        balances_.stethVaultBal = stethCon_.balanceOf(address(this));
        balances_.stethDsaBal = stethCon_.balanceOf(address(vaultDsa));
        balances_.totalBal = balances_.wethVaultBal + balances_.wethDsaBal + balances_.stethVaultBal + balances_.stethDsaBal;
    }

    function getNetExcessBalance() public view returns (
        uint excessBal_,
        uint excessWithdraw_
    ) {

        BalVariables memory balances_ = getIdealBalances();
        excessBal_ = balances_.totalBal;
        excessWithdraw_ = totalWithdrawAwaiting;
        if (excessWithdraw_ >= excessBal_) {
            excessBal_ = 0;
            excessWithdraw_ = excessWithdraw_ - excessBal_;
        } else {
            excessBal_ = excessBal_ - excessWithdraw_;
            excessWithdraw_ = 0;
        }
    }

    function getCurrentExchangePrice()
        public
        view
        returns (
            uint256 exchangePrice_,
            uint256 newRevenue_,
            uint256 stEthCollateralAmount_,
            uint256 wethDebtAmount_
        )
    {

        stEthCollateralAmount_ = getStEthCollateralAmount();
        wethDebtAmount_ = getWethDebtAmount();
        (uint excessBal_, uint excessWithdraw_) = getNetExcessBalance();
        uint256 netSupply = stEthCollateralAmount_ +
            excessBal_ -
            wethDebtAmount_ -
            excessWithdraw_ -
            revenue;
        uint totalSupply_ = totalSupply();
        uint exchangePriceWithRevenue_;
        if (totalSupply_ != 0) {
            exchangePriceWithRevenue_ = (netSupply * 1e18) / totalSupply_;
        } else {
            exchangePriceWithRevenue_ = 1e18;
        }
        if (exchangePriceWithRevenue_ > lastRevenueExchangePrice) {
            uint revenueCut_ = ((exchangePriceWithRevenue_ - lastRevenueExchangePrice) * revenueFee) / 10000; // 10% revenue fee cut
            newRevenue_ = revenueCut_ * netSupply / 1e18;
            exchangePrice_ = exchangePriceWithRevenue_ - revenueCut_;
        } else {
            exchangePrice_ = exchangePriceWithRevenue_;
        }
    }

}//Unlicense
pragma solidity ^0.8.0;


contract CoreHelpers is Helpers {

    using SafeERC20 for IERC20;

    function updateStorage(
        uint256 exchangePrice_,
        uint256 newRevenue_
    ) internal {

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
            uint256 newRevenue_,
            ,
        ) = getCurrentExchangePrice(); // TODO: Update revenue and then return the updated price
        updateStorage(exchangePrice_, newRevenue_);
        if (isEth_) {
            TokenInterface(wethAddr).deposit{value: amount_}();
        } else {
            if (token_ == stEthAddr) {
                IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
            } else if (token_ == wethAddr) {
                IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
            } else {
                revert("wrong-token");
            }
        }
        vtokenAmount_ = (amount_ * 1e18) / exchangePrice_;
        _mint(to_, vtokenAmount_);
    }

    function withdrawHelper(
        uint amount_,
        uint limit_,
        uint totalBal_
    ) internal pure returns (
        uint,
        uint,
        uint,
        uint
    ) {

        uint transferAmt_;
        if (limit_ > amount_) {
            transferAmt_ = amount_;
            limit_ = limit_ - amount_;
            amount_ = 0;
            totalBal_ = totalBal_ - amount_;
        } else {
            transferAmt_ = limit_;
            limit_ = 0;
            amount_ = amount_ - limit_;
            totalBal_ = totalBal_ - limit_;
        }
        return (amount_, limit_, totalBal_, transferAmt_);
    }

    function withdrawFinal(
        uint amount_,
        BalVariables memory balances_,
        address to_
    ) internal returns (
        uint,
        BalVariables memory 
    ) {

        require(amount_ > 0, "amount-invalid");
        uint transferAmt_;
        string[] memory targets_ = new string[](1);
        bytes[] memory calldata_ = new bytes[](1);
        if (balances_.wethVaultBal > 10) {
            (amount_, balances_.wethVaultBal, balances_.totalBal, transferAmt_) =  withdrawHelper(amount_, balances_.wethVaultBal, balances_.totalBal);
            IERC20(wethAddr).transfer(to_, transferAmt_);
        }
        if (balances_.wethDsaBal > 10 && amount_ > 0) {
            (amount_, balances_.wethDsaBal, balances_.totalBal, transferAmt_) =  withdrawHelper(amount_, balances_.wethDsaBal, balances_.totalBal);
            targets_[0] = "BASIC-A";
            calldata_[0] = abi.encodeWithSignature("withdraw(address,uint256,address,uint256,uint256)", wethAddr, transferAmt_, to_, 0, 0);
            vaultDsa.cast(targets_, calldata_, address(this));
        }
        if (balances_.stethVaultBal > 10 && amount_ > 0) {
            (amount_, balances_.stethVaultBal, balances_.totalBal, transferAmt_) =  withdrawHelper(amount_, balances_.stethVaultBal, balances_.totalBal);
            IERC20(stEthAddr).transfer(to_, transferAmt_);
        }
        if (balances_.stethDsaBal > 10 && amount_ > 0) {
            (amount_, balances_.stethDsaBal, balances_.totalBal, transferAmt_) =  withdrawHelper(amount_, balances_.stethDsaBal, balances_.totalBal);
            targets_[0] = "BASIC-A";
            calldata_[0] = abi.encodeWithSignature("withdraw(address,uint256,address,uint256,uint256)", stEthAddr, transferAmt_, to_, 0, 0);
            vaultDsa.cast(targets_, calldata_, address(this));
        }
        return (amount_, balances_);
    }

}

contract InstaVaultImplementation is CoreHelpers {

    using SafeERC20 for IERC20;

    function userWithdrawals(address user_) external view returns (Withdraw[] memory) {

        return userWithdrawAwaiting[user_];
    }
    
    function supplyEth(address to_) external payable nonReentrant returns (uint vtokenAmount_) {

        uint amount_ = msg.value;
        vtokenAmount_ = supplyInternal(
            ethAddr,
            amount_,
            to_,
            true
        );
    }


    function supply(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant returns (uint256 vtokenAmount_) {

        vtokenAmount_ = supplyInternal(
            token_,
            amount_,
            to_,
            false
        );
    }

    function withdrawStart(
        uint256 amount_,
        address to_
    ) external nonReentrant returns (uint256 vtokenAmount_) {

        require(amount_ != 0, "amount cannot be zero");
        (
            uint256 exchangePrice_,
            uint256 newRevenue_,
            ,
        ) = getCurrentExchangePrice(); // TODO: Update revenue and then return the updated price
        updateStorage(exchangePrice_, newRevenue_);
        if (amount_ == type(uint).max) {
            vtokenAmount_ = balanceOf(msg.sender);
            amount_ = vtokenAmount_ * exchangePrice_ / 1e18;
        } else {
            vtokenAmount_ = (amount_ * 1e18) / exchangePrice_;
        }
        _burn(msg.sender, vtokenAmount_);
        userWithdrawAwaiting[to_].push(Withdraw(uint128(amount_), uint128(block.timestamp + withdrawalTime)));
        totalWithdrawAwaiting = totalWithdrawAwaiting + amount_;
    }

    function withdrawClaim(
        uint[] memory indexes,
        address to_
    ) external nonReentrant returns (uint256 totalWithdraw_) {

        BalVariables memory balances_ = getIdealBalances();
        for (uint i = 0; i < indexes.length; i++) {
            uint256 time_ = userWithdrawAwaiting[to_][indexes[i]].time;
            uint256 amount_ = userWithdrawAwaiting[to_][indexes[i]].amount;
            require(time_ < block.timestamp && amount_ > 0, "wrong-withdrawal");
            totalWithdraw_ = totalWithdraw_ + amount_;
            (amount_, balances_) = withdrawFinal(
                amount_,
                balances_,
                to_
            );
            userWithdrawAwaiting[to_][indexes[i]].amount = uint128(amount_);
            if (amount_ != 0) {
                totalWithdraw_ = totalWithdraw_ - amount_;
                break;
            }
        }
        totalWithdrawAwaiting = totalWithdrawAwaiting - totalWithdraw_;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 safeDistancePercentage_,
        uint256 withdrawalTime_,
        uint256 revenueFee_
    ) public initializer {

        address vaultDsaAddr_ = instaIndex.build(address(this), 2, address(0));
        vaultDsa = IDSA(vaultDsaAddr_);
        __ERC20_init(name_, symbol_);
        safeDistancePercentage = safeDistancePercentage_;
        withdrawalTime = withdrawalTime_;
        revenueFee = revenueFee_;
        lastRevenueExchangePrice = 1e18;
        _status = 1;
    }

}