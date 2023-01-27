
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// GPL-3.0
pragma solidity 0.8.13;


interface VaultAPI is IERC20 {

    function decimals() external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool);


    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);


    function withdraw(uint256 maxShares, address recipient)
        external
        returns (uint256);


    function token() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function totalAssets() external view returns (uint256);


    function depositLimit() external view returns (uint256);


    function maxAvailableShares() external view returns (uint256);

}

interface RegistryAPI {

    function governance() external view returns (address);


    function latestVault(address token) external view returns (VaultAPI);


    function numVaults(address token) external view returns (uint256);


    function vaults(address token, uint256 deploymentId)
        external
        view
        returns (VaultAPI);

}// GPL-3.0
pragma solidity 0.8.13;



contract YearnRouter is OwnableUpgradeable {

    RegistryAPI public registry;

    uint256 constant UNLIMITED_APPROVAL = type(uint256).max;

    uint256 constant DEPOSIT_EVERYTHING = type(uint256).max;
    uint256 constant WITHDRAW_EVERYTHING = type(uint256).max;
    uint256 constant MIGRATE_EVERYTHING = type(uint256).max;
    uint256 constant MAX_VAULT_ID = type(uint256).max;

    event Deposit(
        address recipient,
        address vault,
        uint256 shares,
        uint256 amount
    );
    event Withdraw(
        address recipient,
        address vault,
        uint256 shares,
        uint256 amount
    );

    function initialize(address yearnRegistry) public initializer {

        __Ownable_init();

        registry = RegistryAPI(yearnRegistry);
    }

    function setRegistry(address yearnRegistry) external onlyOwner {

        address currentYearnGovernanceAddress = registry.governance();
        registry = RegistryAPI(yearnRegistry);
        require(
            currentYearnGovernanceAddress == registry.governance(),
            "invalid registry"
        );
    }

    function numVaults(address token) external view returns (uint256) {

        return registry.numVaults(token);
    }

    function vaults(address token, uint256 deploymentId)
        external
        view
        returns (VaultAPI)
    {

        return registry.vaults(token, deploymentId);
    }

    function latestVault(address token) external view returns (VaultAPI) {

        return registry.latestVault(token);
    }

    function totalVaultBalance(address token, address account)
        external
        view
        returns (uint256)
    {

        return this.totalVaultBalance(token, account, 0, MAX_VAULT_ID);
    }

    function totalVaultBalance(
        address token,
        address account,
        uint256 firstVaultId,
        uint256 lastVaultId
    ) external view returns (uint256 balance) {

        require(firstVaultId <= lastVaultId);

        uint256 _lastVaultId = lastVaultId;
        if (_lastVaultId == MAX_VAULT_ID)
            _lastVaultId = registry.numVaults(address(token)) - 1;

        for (uint256 i = firstVaultId; i <= _lastVaultId; i++) {
            VaultAPI vault = registry.vaults(token, i);
            uint256 vaultTokenBalance = (vault.balanceOf(account) *
                vault.pricePerShare()) / 10**vault.decimals();
            balance += vaultTokenBalance;
        }
    }

    function totalAssets(address token) external view returns (uint256) {

        return this.totalAssets(token, 0, MAX_VAULT_ID);
    }

    function totalAssets(
        address token,
        uint256 firstVaultId,
        uint256 lastVaultId
    ) external view returns (uint256 assets) {

        require(firstVaultId <= lastVaultId);

        uint256 _lastVaultId = lastVaultId;
        if (_lastVaultId == MAX_VAULT_ID)
            _lastVaultId = registry.numVaults(address(token)) - 1;

        for (uint256 i = firstVaultId; i <= _lastVaultId; i++) {
            VaultAPI vault = registry.vaults(token, i);
            assets += vault.totalAssets();
        }
    }

    function getVaultId(address token, address vault)
        external
        view
        returns (uint256)
    {

        uint256 _numVaults = registry.numVaults(token);
        uint256 vaultId = _numVaults;
        for (uint256 i = 0; i < _numVaults; i++) {
            VaultAPI _vault = registry.vaults(token, i);
            if (address(_vault) == vault) {
                vaultId = i;
                break;
            }
        }
        require(vaultId < _numVaults, "vault not registered");
        return vaultId;
    }

    function deposit(
        address token,
        address recipient,
        uint256 amount
    ) external returns (uint256) {

        return
            _deposit(
                IERC20(token),
                _msgSender(),
                recipient,
                amount,
                MAX_VAULT_ID
            );
    }

    function deposit(
        address token,
        address recipient,
        uint256 amount,
        uint256 vaultId
    ) external returns (uint256) {

        return
            _deposit(IERC20(token), _msgSender(), recipient, amount, vaultId);
    }

    function _deposit(
        IERC20 token,
        address depositor,
        address recipient,
        uint256 amount,
        uint256 vaultId
    ) internal returns (uint256 shares) {

        bool pullFunds = depositor != address(this);

        VaultAPI vault;
        if (vaultId == MAX_VAULT_ID) {
            vault = registry.latestVault(address(token));
        } else {
            vault = registry.vaults(address(token), vaultId);
        }

        if (token.allowance(address(this), address(vault)) < amount) {
            SafeERC20.safeApprove(token, address(vault), 0); // Avoid issues with some tokens requiring 0
            SafeERC20.safeApprove(token, address(vault), UNLIMITED_APPROVAL); // Vaults are trusted
        }

        uint256 depositorBeforeBal = token.balanceOf(depositor);

        if (amount == DEPOSIT_EVERYTHING) amount = depositorBeforeBal;

        if (pullFunds) {
            uint256 routerBeforeBal = token.balanceOf(address(this));
            SafeERC20.safeTransferFrom(token, depositor, address(this), amount);

            shares = vault.deposit(amount, recipient);

            uint256 routerAfterBal = token.balanceOf(address(this));
            if (routerAfterBal > routerBeforeBal)
                SafeERC20.safeTransfer(
                    token,
                    depositor,
                    routerAfterBal - routerBeforeBal
                );
        } else {
            shares = vault.deposit(amount, recipient);
        }
        uint256 depositorAfterBal = token.balanceOf(depositor);
        uint256 depositedAmount = depositorBeforeBal - depositorAfterBal;
        emit Deposit(recipient, address(vault), shares, depositedAmount);
    }

    function withdraw(address token, address recipient)
        external
        returns (uint256)
    {

        return
            _withdraw(
                IERC20(token),
                _msgSender(),
                recipient,
                WITHDRAW_EVERYTHING,
                0,
                MAX_VAULT_ID
            );
    }

    function withdraw(
        address token,
        address recipient,
        uint256 amount
    ) external returns (uint256) {

        return
            _withdraw(
                IERC20(token),
                _msgSender(),
                recipient,
                amount,
                0,
                MAX_VAULT_ID
            );
    }

    function withdraw(
        address token,
        address recipient,
        uint256 amount,
        uint256 firstVaultId,
        uint256 lastVaultId
    ) external returns (uint256) {

        return
            _withdraw(
                IERC20(token),
                _msgSender(),
                recipient,
                amount,
                firstVaultId,
                lastVaultId
            );
    }

    function _withdraw(
        IERC20 token,
        address withdrawer,
        address recipient,
        uint256 amount,
        uint256 firstVaultId,
        uint256 lastVaultId
    ) internal returns (uint256 totalWithdrawn) {

        require(firstVaultId <= lastVaultId);

        if (lastVaultId == MAX_VAULT_ID)
            lastVaultId = registry.numVaults(address(token)) - 1;

        for (
            uint256 i = firstVaultId;
            totalWithdrawn + 1 < amount && i <= lastVaultId;
            i++
        ) {
            VaultAPI vault = registry.vaults(address(token), i);

            uint256 withdrawerShares = vault.balanceOf(withdrawer);
            uint256 availableShares = Math.min(
                withdrawerShares,
                vault.maxAvailableShares()
            );
            availableShares = Math.min(
                availableShares,
                vault.allowance(withdrawer, address(this))
            );
            if (availableShares == 0) continue;

            uint256 maxShares;
            if (amount != WITHDRAW_EVERYTHING) {
                uint256 estimatedShares = ((amount - totalWithdrawn) *
                    10**vault.decimals()) / vault.pricePerShare();

                maxShares = Math.min(availableShares, estimatedShares);
            } else {
                maxShares = availableShares;
            }

            uint256 routerBeforeBal = vault.balanceOf(address(this));

            SafeERC20.safeTransferFrom(
                vault,
                withdrawer,
                address(this),
                maxShares
            );

            uint256 withdrawn = vault.withdraw(maxShares, recipient);
            totalWithdrawn += withdrawn;

            uint256 routerAfterBal = vault.balanceOf(address(this));
            if (routerAfterBal > routerBeforeBal) {
                SafeERC20.safeTransfer(
                    vault,
                    withdrawer,
                    routerAfterBal - routerBeforeBal
                );
            }

            withdrawerShares -= vault.balanceOf(withdrawer);
            emit Withdraw(
                recipient,
                address(vault),
                withdrawerShares,
                withdrawn
            );
        }
    }

    function withdrawShares(
        address token,
        address recipient,
        uint256 vaultId
    ) external returns (uint256) {

        return
            _withdrawShares(
                IERC20(token),
                _msgSender(),
                recipient,
                WITHDRAW_EVERYTHING,
                vaultId
            );
    }

    function withdrawShares(
        address token,
        address recipient,
        uint256 sharesAmount,
        uint256 vaultId
    ) external returns (uint256) {

        return
            _withdrawShares(
                IERC20(token),
                _msgSender(),
                recipient,
                sharesAmount,
                vaultId
            );
    }

    function _withdrawShares(
        IERC20 token,
        address withdrawer,
        address recipient,
        uint256 sharesAmount,
        uint256 vaultId
    ) internal returns (uint256 withdrawn) {

        VaultAPI vault = registry.vaults(address(token), vaultId);

        uint256 sharesBeforeWithdrawal = vault.balanceOf(withdrawer);
        uint256 availableShares = Math.min(
            sharesBeforeWithdrawal,
            vault.maxAvailableShares()
        );

        uint256 maxShares;
        if (sharesAmount != WITHDRAW_EVERYTHING) {
            maxShares = Math.min(availableShares, sharesAmount);
        } else {
            maxShares = availableShares;
        }

        uint256 routerBeforeBal = vault.balanceOf(address(this));

        SafeERC20.safeTransferFrom(vault, withdrawer, address(this), maxShares);

        withdrawn = vault.withdraw(maxShares, recipient);

        uint256 routerAfterBal = vault.balanceOf(address(this));
        if (routerAfterBal > routerBeforeBal) {
            SafeERC20.safeTransfer(
                vault,
                withdrawer,
                routerAfterBal - routerBeforeBal
            );
        }

        uint256 sharesAfterWithdrawal = vault.balanceOf(withdrawer);
        uint256 shares = sharesBeforeWithdrawal - sharesAfterWithdrawal;
        emit Withdraw(recipient, address(vault), shares, withdrawn);
    }

    function migrate(address token) external returns (uint256) {

        return
            _migrate(
                IERC20(token),
                _msgSender(),
                MIGRATE_EVERYTHING,
                0,
                MAX_VAULT_ID
            );
    }

    function migrate(address token, uint256 amount) external returns (uint256) {

        return _migrate(IERC20(token), _msgSender(), amount, 0, MAX_VAULT_ID);
    }

    function migrate(
        address token,
        uint256 amount,
        uint256 firstVaultId,
        uint256 lastVaultId
    ) external returns (uint256) {

        return
            _migrate(
                IERC20(token),
                _msgSender(),
                amount,
                firstVaultId,
                lastVaultId
            );
    }

    function _migrate(
        IERC20 token,
        address migrator,
        uint256 amount,
        uint256 firstVaultId,
        uint256 lastVaultId
    ) internal returns (uint256 migrated) {

        uint256 latestVaultId = registry.numVaults(address(token)) - 1;
        if (amount == 0 || latestVaultId == 0) return 0; // Nothing to migrate, or nowhere to go (not a failure)

        VaultAPI _latestVault = registry.vaults(address(token), latestVaultId);
        uint256 _amount = Math.min(
            amount,
            _latestVault.depositLimit() - _latestVault.totalAssets()
        );

        uint256 beforeWithdrawBal = token.balanceOf(address(this));
        _withdraw(
            token,
            migrator,
            address(this),
            _amount,
            firstVaultId,
            Math.min(lastVaultId, latestVaultId - 1)
        );
        uint256 afterWithdrawBal = token.balanceOf(address(this));
        require(afterWithdrawBal > beforeWithdrawBal, "withdraw failed");

        _deposit(
            token,
            address(this),
            migrator,
            afterWithdrawBal - beforeWithdrawBal,
            latestVaultId
        );
        uint256 afterDepositBal = token.balanceOf(address(this));
        require(afterWithdrawBal > afterDepositBal, "deposit failed");
        migrated = afterWithdrawBal - afterDepositBal;

        if (afterWithdrawBal - beforeWithdrawBal > migrated) {
            SafeERC20.safeTransfer(
                token,
                migrator,
                afterDepositBal - beforeWithdrawBal
            );
        }
    }
}