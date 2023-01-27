
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

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
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

interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPosition {
    function getDebtAssets() external returns (address[] memory, uint256[] memory);

    function getManagedAssets() external returns (address[] memory, uint256[] memory);

    function init(bytes memory) external;

    function receiveCallFromVault(bytes memory) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IProtocolFeeReserve1 {
    function buyBackSharesViaTrustedVaultProxy(
        uint256 _sharesAmount,
        uint256 _mlnValue,
        uint256 _gav
    ) external returns (uint256 mlnAmountToBurn_);
}// GPL-3.0


pragma solidity 0.6.12;

interface IMigratableVault {
    function canMigrate(address _who) external view returns (bool canMigrate_);

    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external;

    function setAccessor(address _nextAccessor) external;

    function setVaultLib(address _nextVaultLib) external;
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract ProxiableVaultLib {
    function __updateCodeAddress(address _nextVaultLib) internal {
        require(
            bytes32(0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5) ==
                ProxiableVaultLib(_nextVaultLib).proxiableUUID(),
            "__updateCodeAddress: _nextVaultLib not compatible"
        );
        assembly {
            sstore(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                _nextVaultLib
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32 uuid_) {
        return 0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5;
    }
}// GPL-3.0


pragma solidity 0.6.12;

library VaultLibSafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "VaultLibSafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "VaultLibSafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "VaultLibSafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "VaultLibSafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "VaultLibSafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract SharesTokenBase {
    using VaultLibSafeMath for uint256;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    string internal sharesName;
    string internal sharesSymbol;
    uint256 internal sharesTotalSupply;
    mapping(address => uint256) internal sharesBalances;
    mapping(address => mapping(address => uint256)) internal sharesAllowances;


    function approve(address _spender, uint256 _amount) public virtual returns (bool) {
        __approve(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _recipient, uint256 _amount) public virtual returns (bool) {
        __transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual returns (bool) {
        __transfer(_sender, _recipient, _amount);
        __approve(
            _sender,
            msg.sender,
            sharesAllowances[_sender][msg.sender].sub(
                _amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return sharesAllowances[_owner][_spender];
    }

    function balanceOf(address _account) public view virtual returns (uint256) {
        return sharesBalances[_account];
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view virtual returns (string memory) {
        return sharesName;
    }

    function symbol() public view virtual returns (string memory) {
        return sharesSymbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return sharesTotalSupply;
    }


    function __approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        sharesAllowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function __burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "ERC20: burn from the zero address");

        sharesBalances[_account] = sharesBalances[_account].sub(
            _amount,
            "ERC20: burn amount exceeds balance"
        );
        sharesTotalSupply = sharesTotalSupply.sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

    function __mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "ERC20: mint to the zero address");

        sharesTotalSupply = sharesTotalSupply.add(_amount);
        sharesBalances[_account] = sharesBalances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    function __transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");

        sharesBalances[_sender] = sharesBalances[_sender].sub(
            _amount,
            "ERC20: transfer amount exceeds balance"
        );
        sharesBalances[_recipient] = sharesBalances[_recipient].add(_amount);
        emit Transfer(_sender, _recipient, _amount);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBaseCore is IMigratableVault, ProxiableVaultLib, SharesTokenBase {
    event AccessorSet(address prevAccessor, address nextAccessor);

    event MigratorSet(address prevMigrator, address nextMigrator);

    event OwnerSet(address prevOwner, address nextOwner);

    event VaultLibSet(address prevVaultLib, address nextVaultLib);

    address internal accessor;
    address internal creator;
    address internal migrator;
    address internal owner;


    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external override {
        require(creator == address(0), "init: Proxy already initialized");
        creator = msg.sender;
        sharesName = _fundName;

        __setAccessor(_accessor);
        __setOwner(_owner);

        emit VaultLibSet(address(0), getVaultLib());
    }

    function setAccessor(address _nextAccessor) external override {
        require(msg.sender == creator, "setAccessor: Only callable by the contract creator");

        __setAccessor(_nextAccessor);
    }

    function setVaultLib(address _nextVaultLib) external override {
        require(msg.sender == creator, "setVaultLib: Only callable by the contract creator");

        address prevVaultLib = getVaultLib();

        __updateCodeAddress(_nextVaultLib);

        emit VaultLibSet(prevVaultLib, _nextVaultLib);
    }


    function canMigrate(address _who) public view virtual override returns (bool canMigrate_) {
        return _who == owner || _who == migrator;
    }

    function getVaultLib() public view returns (address vaultLib_) {
        assembly {
            vaultLib_ := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
        return vaultLib_;
    }


    function __setAccessor(address _nextAccessor) internal {
        require(_nextAccessor != address(0), "__setAccessor: _nextAccessor cannot be empty");
        address prevAccessor = accessor;

        accessor = _nextAccessor;

        emit AccessorSet(prevAccessor, _nextAccessor);
    }

    function __setOwner(address _nextOwner) internal {
        require(_nextOwner != address(0), "__setOwner: _nextOwner cannot be empty");
        address prevOwner = owner;
        require(_nextOwner != prevOwner, "__setOwner: _nextOwner is the current owner");

        owner = _nextOwner;

        emit OwnerSet(prevOwner, _nextOwner);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBase1 is VaultLibBaseCore {
    event AssetWithdrawn(address indexed asset, address indexed target, uint256 amount);

    event TrackedAssetAdded(address asset);

    event TrackedAssetRemoved(address asset);

    address[] internal trackedAssets;
    mapping(address => bool) internal assetToIsTracked;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBase2 is VaultLibBase1 {
    event AssetManagerAdded(address manager);

    event AssetManagerRemoved(address manager);

    event EthReceived(address indexed sender, uint256 amount);

    event ExternalPositionAdded(address indexed externalPosition);

    event ExternalPositionRemoved(address indexed externalPosition);

    event FreelyTransferableSharesSet();

    event NameSet(string name);

    event NominatedOwnerRemoved(address indexed nominatedOwner);

    event NominatedOwnerSet(address indexed nominatedOwner);

    event ProtocolFeePaidInShares(uint256 sharesAmount);

    event ProtocolFeeSharesBoughtBack(uint256 sharesAmount, uint256 mlnValue, uint256 mlnBurned);

    event OwnershipTransferred(address indexed prevOwner, address indexed nextOwner);

    event SymbolSet(string symbol);

    bool internal freelyTransferableShares;
    address internal nominatedOwner;
    address[] internal activeExternalPositions;
    mapping(address => bool) internal accountToIsAssetManager;
    mapping(address => bool) internal externalPositionToIsActive;
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionVault {
    function getExternalPositionLibForType(uint256) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface IFreelyTransferableSharesVault {
    function sharesAreFreelyTransferable()
        external
        view
        returns (bool sharesAreFreelyTransferable_);
}// GPL-3.0


pragma solidity 0.6.12;


interface IVault is IMigratableVault, IFreelyTransferableSharesVault, IExternalPositionVault {
    enum VaultAction {
        None,
        BurnShares,
        MintShares,
        TransferShares,
        AddTrackedAsset,
        ApproveAssetSpender,
        RemoveTrackedAsset,
        WithdrawAssetTo,
        AddExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition
    }

    function addTrackedAsset(address) external;

    function burnShares(address, uint256) external;

    function buyBackProtocolFeeShares(
        uint256,
        uint256,
        uint256
    ) external;

    function callOnContract(address, bytes calldata) external returns (bytes memory);

    function canManageAssets(address) external view returns (bool);

    function canRelayCalls(address) external view returns (bool);

    function getAccessor() external view returns (address);

    function getOwner() external view returns (address);

    function getActiveExternalPositions() external view returns (address[] memory);

    function getTrackedAssets() external view returns (address[] memory);

    function isActiveExternalPosition(address) external view returns (bool);

    function isTrackedAsset(address) external view returns (bool);

    function mintShares(address, uint256) external;

    function payProtocolFee() external;

    function receiveValidatedVaultAction(VaultAction, bytes calldata) external;

    function setAccessorForFundReconfiguration(address) external;

    function setSymbol(string calldata) external;

    function transferShares(
        address,
        address,
        uint256
    ) external;

    function withdrawAssetTo(
        address,
        address,
        uint256
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;


interface IComptroller {
    function activate(bool) external;

    function calcGav() external returns (uint256);

    function calcGrossShareValue() external returns (uint256);

    function callOnExtension(
        address,
        uint256,
        bytes calldata
    ) external;

    function destructActivated(uint256, uint256) external;

    function destructUnactivated() external;

    function getDenominationAsset() external view returns (address);

    function getExternalPositionManager() external view returns (address);

    function getFeeManager() external view returns (address);

    function getFundDeployer() external view returns (address);

    function getGasRelayPaymaster() external view returns (address);

    function getIntegrationManager() external view returns (address);

    function getPolicyManager() external view returns (address);

    function getVaultProxy() external view returns (address);

    function init(address, uint256) external;

    function permissionedVaultAction(IVault.VaultAction, bytes calldata) external;

    function preTransferSharesHook(
        address,
        address,
        uint256
    ) external;

    function preTransferSharesHookFreelyTransferable(address) external view;

    function setGasRelayPaymaster(address) external;

    function setVaultProxy(address) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IBeacon {
    function getCanonicalLib() external view returns (address);
}// GPL-3.0



pragma solidity 0.6.12;

interface IBeaconProxyFactory is IBeacon {
    function deployProxy(bytes memory _constructData) external returns (address proxy_);

    function setCanonicalLib(address _canonicalLib) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IGsnForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }
}// GPL-3.0


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface IGsnTypes {
    struct RelayData {
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IGsnForwarder.ForwardRequest request;
        RelayData relayData;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IGsnPaymaster {
    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits() external view returns (GasAndDataLimits memory limits);

    function getHubAddr() external view returns (address);

    function getRelayHubDeposit() external view returns (uint256);

    function preRelayedCall(
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    ) external returns (bytes memory context, bool rejectOnRecipientRevert);

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        IGsnTypes.RelayData calldata relayData
    ) external;

    function trustedForwarder() external view returns (address);

    function versionPaymaster() external view returns (string memory);
}// GPL-3.0


pragma solidity 0.6.12;


interface IGasRelayPaymaster is IGsnPaymaster {
    function deposit() external;

    function withdrawBalance() external;
}// GPL-3.0



pragma solidity 0.6.12;

abstract contract GasRelayRecipientMixin {
    address internal immutable GAS_RELAY_PAYMASTER_FACTORY;

    constructor(address _gasRelayPaymasterFactory) internal {
        GAS_RELAY_PAYMASTER_FACTORY = _gasRelayPaymasterFactory;
    }

    function __msgSender() internal view returns (address payable canonicalSender_) {
        if (msg.data.length >= 24 && msg.sender == getGasRelayTrustedForwarder()) {
            assembly {
                canonicalSender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return canonicalSender_;
        }

        return msg.sender;
    }


    function getGasRelayPaymasterFactory()
        public
        view
        returns (address gasRelayPaymasterFactory_)
    {
        return GAS_RELAY_PAYMASTER_FACTORY;
    }

    function getGasRelayTrustedForwarder() public view returns (address trustedForwarder_) {
        return
            IGasRelayPaymaster(
                IBeaconProxyFactory(getGasRelayPaymasterFactory()).getCanonicalLib()
            )
                .trustedForwarder();
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IProtocolFeeTracker {
    function initializeForVault(address) external;

    function payFee() external returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionManager {
    struct ExternalPositionTypeInfo {
        address parser;
        address lib;
    }
    enum ExternalPositionManagerActions {
        CreateExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function getExternalPositionLibForType(uint256) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
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


contract VaultLib is VaultLibBase2, IVault, GasRelayRecipientMixin {
    using AddressArrayLib for address[];
    using SafeERC20 for ERC20;

    address private immutable EXTERNAL_POSITION_MANAGER;
    address private immutable MLN_BURNER;
    address private immutable MLN_TOKEN;
    uint256 private immutable POSITIONS_LIMIT;
    address private immutable PROTOCOL_FEE_RESERVE;
    address private immutable PROTOCOL_FEE_TRACKER;
    address private immutable WETH_TOKEN;

    modifier notShares(address _asset) {
        require(_asset != address(this), "Cannot act on shares");
        _;
    }

    modifier onlyAccessor() {
        require(msg.sender == accessor, "Only the designated accessor can make this call");
        _;
    }

    modifier onlyOwner() {
        require(__msgSender() == owner, "Only the owner can call this function");
        _;
    }

    constructor(
        address _externalPositionManager,
        address _gasRelayPaymasterFactory,
        address _protocolFeeReserve,
        address _protocolFeeTracker,
        address _mlnToken,
        address _mlnBurner,
        address _wethToken,
        uint256 _positionsLimit
    ) public GasRelayRecipientMixin(_gasRelayPaymasterFactory) {
        EXTERNAL_POSITION_MANAGER = _externalPositionManager;
        MLN_BURNER = _mlnBurner;
        MLN_TOKEN = _mlnToken;
        POSITIONS_LIMIT = _positionsLimit;
        PROTOCOL_FEE_RESERVE = _protocolFeeReserve;
        PROTOCOL_FEE_TRACKER = _protocolFeeTracker;
        WETH_TOKEN = _wethToken;
    }

    receive() external payable {
        uint256 ethAmount = payable(address(this)).balance;
        IWETH(payable(getWethToken())).deposit{value: ethAmount}();

        emit EthReceived(msg.sender, ethAmount);
    }


    function getExternalPositionLibForType(uint256 _typeId)
        external
        view
        override
        returns (address externalPositionLib_)
    {
        return
            IExternalPositionManager(getExternalPositionManager()).getExternalPositionLibForType(
                _typeId
            );
    }

    function setFreelyTransferableShares() external onlyOwner {
        require(!sharesAreFreelyTransferable(), "setFreelyTransferableShares: Already set");

        freelyTransferableShares = true;

        emit FreelyTransferableSharesSet();
    }

    function setName(string calldata _nextName) external onlyOwner {
        sharesName = _nextName;

        emit NameSet(_nextName);
    }

    function setSymbol(string calldata _nextSymbol) external override {
        require(__msgSender() == owner || msg.sender == getFundDeployer(), "Unauthorized");

        sharesSymbol = _nextSymbol;

        emit SymbolSet(_nextSymbol);
    }


    function addAssetManagers(address[] calldata _managers) external onlyOwner {
        for (uint256 i; i < _managers.length; i++) {
            require(!isAssetManager(_managers[i]), "addAssetManagers: Manager already registered");

            accountToIsAssetManager[_managers[i]] = true;

            emit AssetManagerAdded(_managers[i]);
        }
    }

    function claimOwnership() external {
        address nextOwner = nominatedOwner;
        require(
            msg.sender == nextOwner,
            "claimOwnership: Only the nominatedOwner can call this function"
        );

        delete nominatedOwner;

        address prevOwner = owner;
        owner = nextOwner;

        emit OwnershipTransferred(prevOwner, nextOwner);
    }

    function removeAssetManagers(address[] calldata _managers) external onlyOwner {
        for (uint256 i; i < _managers.length; i++) {
            require(isAssetManager(_managers[i]), "removeAssetManagers: Manager not registered");

            accountToIsAssetManager[_managers[i]] = false;

            emit AssetManagerRemoved(_managers[i]);
        }
    }

    function removeNominatedOwner() external onlyOwner {
        address removedNominatedOwner = nominatedOwner;
        require(
            removedNominatedOwner != address(0),
            "removeNominatedOwner: There is no nominated owner"
        );

        delete nominatedOwner;

        emit NominatedOwnerRemoved(removedNominatedOwner);
    }

    function setMigrator(address _nextMigrator) external onlyOwner {
        address prevMigrator = migrator;
        require(_nextMigrator != prevMigrator, "setMigrator: Value already set");

        migrator = _nextMigrator;

        emit MigratorSet(prevMigrator, _nextMigrator);
    }

    function setNominatedOwner(address _nextNominatedOwner) external onlyOwner {
        require(
            _nextNominatedOwner != address(0),
            "setNominatedOwner: _nextNominatedOwner cannot be empty"
        );
        require(
            _nextNominatedOwner != owner,
            "setNominatedOwner: _nextNominatedOwner is already the owner"
        );
        require(
            _nextNominatedOwner != nominatedOwner,
            "setNominatedOwner: _nextNominatedOwner is already nominated"
        );

        nominatedOwner = _nextNominatedOwner;

        emit NominatedOwnerSet(_nextNominatedOwner);
    }


    function setAccessorForFundReconfiguration(address _nextAccessor) external override {
        require(msg.sender == getFundDeployer(), "Only the FundDeployer can make this call");

        __setAccessor(_nextAccessor);
    }


    function addTrackedAsset(address _asset) external override onlyAccessor {
        __addTrackedAsset(_asset);
    }

    function burnShares(address _target, uint256 _amount) external override onlyAccessor {
        __burn(_target, _amount);
    }

    function buyBackProtocolFeeShares(
        uint256 _sharesAmount,
        uint256 _mlnValue,
        uint256 _gav
    ) external override onlyAccessor {
        uint256 mlnAmountToBurn = IProtocolFeeReserve1(getProtocolFeeReserve())
            .buyBackSharesViaTrustedVaultProxy(_sharesAmount, _mlnValue, _gav);

        if (mlnAmountToBurn == 0) {
            return;
        }

        __burn(getProtocolFeeReserve(), _sharesAmount);

        if (getMlnBurner() == address(0)) {
            ERC20Burnable(getMlnToken()).burn(mlnAmountToBurn);
        } else {
            ERC20(getMlnToken()).safeTransfer(getMlnBurner(), mlnAmountToBurn);
        }

        emit ProtocolFeeSharesBoughtBack(_sharesAmount, _mlnValue, mlnAmountToBurn);
    }

    function callOnContract(address _contract, bytes calldata _callData)
        external
        override
        onlyAccessor
        returns (bytes memory returnData_)
    {
        bool success;
        (success, returnData_) = _contract.call(_callData);
        require(success, string(returnData_));

        return returnData_;
    }

    function mintShares(address _target, uint256 _amount) external override onlyAccessor {
        __mint(_target, _amount);
    }

    function payProtocolFee() external override onlyAccessor {
        uint256 sharesDue = IProtocolFeeTracker(getProtocolFeeTracker()).payFee();

        if (sharesDue == 0) {
            return;
        }

        __mint(getProtocolFeeReserve(), sharesDue);

        emit ProtocolFeePaidInShares(sharesDue);
    }

    function transferShares(
        address _from,
        address _to,
        uint256 _amount
    ) external override onlyAccessor {
        __transfer(_from, _to, _amount);
    }

    function withdrawAssetTo(
        address _asset,
        address _target,
        uint256 _amount
    ) external override onlyAccessor {
        __withdrawAssetTo(_asset, _target, _amount);
    }


    function receiveValidatedVaultAction(VaultAction _action, bytes calldata _actionData)
        external
        override
        onlyAccessor
    {
        if (_action == VaultAction.AddExternalPosition) {
            __executeVaultActionAddExternalPosition(_actionData);
        } else if (_action == VaultAction.AddTrackedAsset) {
            __executeVaultActionAddTrackedAsset(_actionData);
        } else if (_action == VaultAction.ApproveAssetSpender) {
            __executeVaultActionApproveAssetSpender(_actionData);
        } else if (_action == VaultAction.BurnShares) {
            __executeVaultActionBurnShares(_actionData);
        } else if (_action == VaultAction.CallOnExternalPosition) {
            __executeVaultActionCallOnExternalPosition(_actionData);
        } else if (_action == VaultAction.MintShares) {
            __executeVaultActionMintShares(_actionData);
        } else if (_action == VaultAction.RemoveExternalPosition) {
            __executeVaultActionRemoveExternalPosition(_actionData);
        } else if (_action == VaultAction.RemoveTrackedAsset) {
            __executeVaultActionRemoveTrackedAsset(_actionData);
        } else if (_action == VaultAction.TransferShares) {
            __executeVaultActionTransferShares(_actionData);
        } else if (_action == VaultAction.WithdrawAssetTo) {
            __executeVaultActionWithdrawAssetTo(_actionData);
        }
    }

    function __executeVaultActionAddExternalPosition(bytes memory _actionData) private {
        __addExternalPosition(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionAddTrackedAsset(bytes memory _actionData) private {
        __addTrackedAsset(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionApproveAssetSpender(bytes memory _actionData) private {
        (address asset, address target, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );

        __approveAssetSpender(asset, target, amount);
    }

    function __executeVaultActionBurnShares(bytes memory _actionData) private {
        (address target, uint256 amount) = abi.decode(_actionData, (address, uint256));

        __burn(target, amount);
    }

    function __executeVaultActionCallOnExternalPosition(bytes memory _actionData) private {
        (
            address externalPosition,
            bytes memory callOnExternalPositionActionData,
            address[] memory assetsToTransfer,
            uint256[] memory amountsToTransfer,
            address[] memory assetsToReceive
        ) = abi.decode(_actionData, (address, bytes, address[], uint256[], address[]));

        __callOnExternalPosition(
            externalPosition,
            callOnExternalPositionActionData,
            assetsToTransfer,
            amountsToTransfer,
            assetsToReceive
        );
    }

    function __executeVaultActionMintShares(bytes memory _actionData) private {
        (address target, uint256 amount) = abi.decode(_actionData, (address, uint256));

        __mint(target, amount);
    }

    function __executeVaultActionRemoveExternalPosition(bytes memory _actionData) private {
        __removeExternalPosition(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionRemoveTrackedAsset(bytes memory _actionData) private {
        __removeTrackedAsset(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionTransferShares(bytes memory _actionData) private {
        (address from, address to, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );

        __transfer(from, to, amount);
    }

    function __executeVaultActionWithdrawAssetTo(bytes memory _actionData) private {
        (address asset, address target, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );

        __withdrawAssetTo(asset, target, amount);
    }


    function __addExternalPosition(address _externalPosition) private {
        if (!isActiveExternalPosition(_externalPosition)) {
            __validatePositionsLimit();

            externalPositionToIsActive[_externalPosition] = true;
            activeExternalPositions.push(_externalPosition);

            emit ExternalPositionAdded(_externalPosition);
        }
    }

    function __addTrackedAsset(address _asset) private notShares(_asset) {
        if (!isTrackedAsset(_asset)) {
            __validatePositionsLimit();

            assetToIsTracked[_asset] = true;
            trackedAssets.push(_asset);

            emit TrackedAssetAdded(_asset);
        }
    }

    function __approveAssetSpender(
        address _asset,
        address _target,
        uint256 _amount
    ) private notShares(_asset) {
        ERC20 assetContract = ERC20(_asset);
        if (assetContract.allowance(address(this), _target) > 0) {
            assetContract.safeApprove(_target, 0);
        }
        assetContract.safeApprove(_target, _amount);
    }

    function __callOnExternalPosition(
        address _externalPosition,
        bytes memory _actionData,
        address[] memory _assetsToTransfer,
        uint256[] memory _amountsToTransfer,
        address[] memory _assetsToReceive
    ) private {
        require(
            isActiveExternalPosition(_externalPosition),
            "__callOnExternalPosition: Not an active external position"
        );

        for (uint256 i; i < _assetsToTransfer.length; i++) {
            __withdrawAssetTo(_assetsToTransfer[i], _externalPosition, _amountsToTransfer[i]);
        }

        IExternalPosition(_externalPosition).receiveCallFromVault(_actionData);

        for (uint256 i; i < _assetsToReceive.length; i++) {
            __addTrackedAsset(_assetsToReceive[i]);
        }
    }

    function __getAssetBalance(address _asset) private view returns (uint256 balance_) {
        return ERC20(_asset).balanceOf(address(this));
    }

    function __removeExternalPosition(address _externalPosition) private {
        if (isActiveExternalPosition(_externalPosition)) {
            externalPositionToIsActive[_externalPosition] = false;

            activeExternalPositions.removeStorageItem(_externalPosition);

            emit ExternalPositionRemoved(_externalPosition);
        }
    }

    function __removeTrackedAsset(address _asset) private {
        if (isTrackedAsset(_asset)) {
            assetToIsTracked[_asset] = false;

            trackedAssets.removeStorageItem(_asset);

            emit TrackedAssetRemoved(_asset);
        }
    }

    function __validatePositionsLimit() private view {
        require(
            trackedAssets.length + activeExternalPositions.length < getPositionsLimit(),
            "__validatePositionsLimit: Limit exceeded"
        );
    }

    function __withdrawAssetTo(
        address _asset,
        address _target,
        uint256 _amount
    ) private notShares(_asset) {
        ERC20(_asset).safeTransfer(_target, _amount);

        emit AssetWithdrawn(_asset, _target, _amount);
    }


    function symbol() public view override returns (string memory symbol_) {
        symbol_ = sharesSymbol;
        if (bytes(symbol_).length == 0) {
            symbol_ = IDispatcher(creator).getSharesTokenSymbol();
        }

        return symbol_;
    }

    function transfer(address _recipient, uint256 _amount)
        public
        override
        returns (bool success_)
    {
        __invokePreTransferSharesHook(msg.sender, _recipient, _amount);

        return super.transfer(_recipient, _amount);
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool success_) {
        __invokePreTransferSharesHook(_sender, _recipient, _amount);

        return super.transferFrom(_sender, _recipient, _amount);
    }

    function __invokePreTransferSharesHook(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        if (sharesAreFreelyTransferable()) {
            IComptroller(accessor).preTransferSharesHookFreelyTransferable(_sender);
        } else {
            IComptroller(accessor).preTransferSharesHook(_sender, _recipient, _amount);
        }
    }


    function canManageAssets(address _who) external view override returns (bool canManageAssets_) {
        return _who == getOwner() || isAssetManager(_who);
    }

    function canRelayCalls(address _who) external view override returns (bool canRelayCalls_) {
        return _who == getOwner() || isAssetManager(_who) || _who == getMigrator();
    }

    function getAccessor() public view override returns (address accessor_) {
        return accessor;
    }

    function getCreator() external view returns (address creator_) {
        return creator;
    }

    function getMigrator() public view returns (address migrator_) {
        return migrator;
    }

    function getNominatedOwner() external view returns (address nominatedOwner_) {
        return nominatedOwner;
    }

    function getActiveExternalPositions()
        external
        view
        override
        returns (address[] memory activeExternalPositions_)
    {
        return activeExternalPositions;
    }

    function getTrackedAssets() external view override returns (address[] memory trackedAssets_) {
        return trackedAssets;
    }


    function getExternalPositionManager() public view returns (address externalPositionManager_) {
        return EXTERNAL_POSITION_MANAGER;
    }

    function getFundDeployer() public view returns (address fundDeployer_) {
        return IDispatcher(creator).getFundDeployerForVaultProxy(address(this));
    }

    function getMlnBurner() public view returns (address mlnBurner_) {
        return MLN_BURNER;
    }

    function getMlnToken() public view returns (address mlnToken_) {
        return MLN_TOKEN;
    }

    function getOwner() public view override returns (address owner_) {
        return owner;
    }

    function getPositionsLimit() public view returns (uint256 positionsLimit_) {
        return POSITIONS_LIMIT;
    }

    function getProtocolFeeReserve() public view returns (address protocolFeeReserve_) {
        return PROTOCOL_FEE_RESERVE;
    }

    function getProtocolFeeTracker() public view returns (address protocolFeeTracker_) {
        return PROTOCOL_FEE_TRACKER;
    }

    function isActiveExternalPosition(address _externalPosition)
        public
        view
        override
        returns (bool isActiveExternalPosition_)
    {
        return externalPositionToIsActive[_externalPosition];
    }

    function isAssetManager(address _who) public view returns (bool isAssetManager_) {
        return accountToIsAssetManager[_who];
    }

    function isTrackedAsset(address _asset) public view override returns (bool isTrackedAsset_) {
        return assetToIsTracked[_asset];
    }

    function sharesAreFreelyTransferable()
        public
        view
        override
        returns (bool sharesAreFreelyTransferable_)
    {
        return freelyTransferableShares;
    }

    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}