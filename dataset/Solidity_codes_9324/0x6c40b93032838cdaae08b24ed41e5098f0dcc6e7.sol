
pragma solidity ^0.8.0;

interface ManagerRoleInterface {    


    function isManager(address account) external view returns (bool);


    function addManager(address account) external;


    function renounceManager() external;


}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

interface ERC20AllowanceInterface {


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


}// MIT

pragma solidity ^0.8.0;

interface IERC20Burnable {

    
    function burn(uint256 amount) external returns (bool);


    function burnFrom(address account, uint256 amount) external returns (bool);


}// MIT

pragma solidity ^0.8.0;

interface FreezableInterface {


    function frozen(address account) external view returns (bool);


    function freeze(address account)  external;


    function unfreeze(address account) external;


}// MIT

pragma solidity ^0.8.0;

interface PausableInterface {


    function paused() external view returns (bool);


    function pause() external;


    function unpause() external;


}// MIT

pragma solidity ^0.8.0;

interface RecoverableInterface {


    function recover(IERC20 token, uint256 amount) external;


}// MIT

pragma solidity ^0.8.0;





interface IXenoERC20 is
    ManagerRoleInterface,
    IERC20,
    IERC20Metadata,
    ERC20AllowanceInterface,
    IERC20Burnable,
    FreezableInterface,
    PausableInterface,
    RecoverableInterface
{ }// MIT


pragma solidity ^0.8.0;


struct InitializableStore {
    bool initialized;

    bool initializing;
}// MIT

pragma solidity ^0.8.0;


struct Role {
    mapping (address => bool) bearer;
    uint256 numberOfBearers;
}// MIT

pragma solidity ^0.8.0;




struct ManagerRoleStore {
    bool initialized;
    Role managers;
}// MIT

pragma solidity ^0.8.0;


struct ERC20Store {
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 total;
    string named;
    string symboled;
    uint8 decimaled;
}// MIT

pragma solidity ^0.8.0;


struct PausableStore {
    bool isPaused;
}// MIT

pragma solidity ^0.8.0;


struct FreezableStore {
    mapping(address => bool) isFrozen;
}// MIT

pragma solidity ^0.8.0;



struct XenoERC20Store {
    InitializableStore initializable;
    ManagerRoleStore managerRole;
    ERC20Store erc20;
    PausableStore pausable;
    FreezableStore freezable; // the slot taken by the struct of this is the last slotted item
}// MIT

pragma solidity ^0.8.0;




contract ERC20Storage {

    XenoERC20Store internal x;
    uint256[50] private ______gap;
}// MIT

pragma solidity ^0.8.0;



abstract contract Initializable is ERC20Storage {

    modifier initializer() {
        require(x.initializable.initializing || !x.initializable.initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !x.initializable.initializing;
        if (isTopLevelCall) {
            x.initializable.initializing = true;
            x.initializable.initialized = true;
        }

        _;

        if (isTopLevelCall) {
            x.initializable.initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;



abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }
}// MIT

pragma solidity ^0.8.0;



abstract contract UUPSUpgradeable is ERC1967Upgrade {
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}// MIT

pragma solidity ^0.8.0;



library Roles {

    

    function _has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles._has: ZERO_ADDRESS");
        return role.bearer[account];
    }

    function _atLeastOneBearer(uint256 numberOfBearers) internal pure returns (bool) {

        if (numberOfBearers > 0) {
            return true;
        } else {
            return false;
        }
    }


    function _add(
        Role storage role,
        address account
    )
        internal
    {

        require(
            !_has(role, account),
            "Roles._add: ALREADY_ASSIGNED"
        );

        role.bearer[account] = true;
        role.numberOfBearers += 1;
    }

    function _safeRemove(
        Role storage role,
        address account
    )
        internal
    {

        require(
            _has(role, account),
            "Roles._safeRemove: INVALID_ACCOUNT"
        );
        uint256 numberOfBearers = role.numberOfBearers -= 1; // roles that use safeRemove must implement initializeRole() and onlyIntialized() and must set the contract deployer as the first account, otherwise this can underflow below zero
        require(
            _atLeastOneBearer(numberOfBearers),
            "Roles._safeRemove: MINIMUM_ACCOUNTS"
        );
        
        role.bearer[account] = false;
    }

    function _remove(Role storage role, address account) internal {

        require(_has(role, account), "Roles.remove: INVALID_ACCOUNT");
        role.numberOfBearers -= 1;
        
        role.bearer[account] = false;
    }
}// MIT

pragma solidity ^0.8.0;

contract Context {

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function _msgData() internal pure returns (bytes calldata) {

        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

interface ManagerRoleEvents {


    event ManagerAdded(address indexed account);
    
    event ManagerRemoved(address indexed account);
    
}// MIT

pragma solidity ^0.8.0;









contract ManagerRole is Context, ManagerRoleEvents, ERC20Storage {

    
    using Roles for Role;


    modifier onlyUninitialized() {

        require(!x.managerRole.initialized, "ManagerRole.onlyUninitialized: ALREADY_INITIALIZED");
        _;
    }

    modifier onlyInitialized() {

        require(x.managerRole.initialized, "ManagerRole.onlyInitialized: NOT_INITIALIZED");
        _;
    }

    modifier onlyManager() {

        require(_isManager(_msgSender()), "ManagerRole.onlyManager: NOT_MANAGER");
        _;
    }

    
    function _initializeManagerRole(
        address account
    )
        internal
        onlyUninitialized
     {

        _addManager_(account);
        x.managerRole.initialized = true;
    }


    function _isManager(
        address account
    )
        internal
        view
        returns (bool)
    {

        return _isManager_(account);
    }


    
    function _addManager(
        address account
    )
        internal
        onlyManager
        onlyInitialized
    {

        _addManager_(account);
    }

    function _renounceManager()
        internal
        onlyInitialized
    {

        _removeManager_(_msgSender());
    }


    function _isManager_(
        address account
    )
        private
        view
        returns (bool)
    {

        return x.managerRole.managers._has(account);
    }

    function _addManager_(
        address account
    )
        private
    {

        x.managerRole.managers._add(account);
        emit ManagerAdded(account);
    }

    function _removeManager_(
        address account
    )
        private
    {

        x.managerRole.managers._safeRemove(account);
        emit ManagerRemoved(account);
    }
}// MIT

pragma solidity ^0.8.0;

interface FreezableEvents {

    
    event Frozen(address manager, address account);

    event Unfrozen(address manager, address account);

}// MIT

pragma solidity ^0.8.0;







contract Freezable is Context, FreezableEvents, ERC20Storage {



    modifier whenNotFrozen(address account) {

        require(
            !_frozen_(account),
            "Freezable.whenNotFrozen: FROZEN"
        );
        _;
    }

    modifier whenFrozen(address account) {

        require(
            _frozen_(account),
            "Freezable.whenFrozen: NOT_FROZEN"
        );
        _;
    }


    function _frozen(address account) internal view returns (bool) {

        return _frozen_(account);
    }


    function _freeze(address account) internal whenNotFrozen(account) {

        require(account != address(0), "Freezable._freeze: ACCOUNT_ZERO_ADDRESS");
        x.freezable.isFrozen[account] = true;
        emit Frozen(_msgSender(), account);
    }

    function _unfreeze(address account) internal whenFrozen(account) {

        x.freezable.isFrozen[account] = false;
        emit Unfrozen(_msgSender(), account);
    }


    function _frozen_(address account) private view returns (bool) {

        return x.freezable.isFrozen[account];
    }
}// MIT

pragma solidity ^0.8.0;

interface PausableEvents {


    event Paused(address account);

    event Unpaused(address account);

}// MIT

pragma solidity ^0.8.0;







contract Pausable is Context, PausableEvents, ERC20Storage {



    modifier whenNotPaused() {

        require(!_paused_(), "Pausable.whenNotPaused: PAUSED");
        _;
    }

    modifier whenPaused() {

        require(_paused_(), "Pausable.whenPaused: NOT_PAUSED");
        _;
    }
    

    function _initializePausable() internal {

        x.pausable.isPaused = false;
    }


    function _paused() internal view returns (bool) {

        return _paused_();
    }


    function _pause() internal whenNotPaused {

        x.pausable.isPaused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused {

        x.pausable.isPaused = false;
        emit Unpaused(_msgSender());
    }


    function _paused_() private view returns (bool) {

        return x.pausable.isPaused;
    }
}// MIT

pragma solidity ^0.8.0;



interface RecoverableEvents {

    
    event Recovered(address account, IERC20 token, uint256 amount);

}// MIT

pragma solidity ^0.8.0;






contract Recoverable is Context, RecoverableEvents {

    function _recover(IERC20 token, uint256 amount) internal virtual {

        require(token.balanceOf(address(this)) >= amount, "Recoverable.recover: INVALID_AMOUNT");
        token.transfer(_msgSender(), amount);
        emit Recovered(_msgSender(), token, amount);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Events {


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}// MIT

pragma solidity ^0.8.0;





contract ERC20 is Context, IERC20Events, ERC20Storage {

    

    function _initalizeERC20(string calldata setName, string calldata setSymbol, uint8 setDecimals, uint256 initialSupply) internal {

        x.erc20.named = setName;
        x.erc20.symboled = setSymbol;
        x.erc20.decimaled = setDecimals;
        _mint_(_msgSender(), initialSupply);
    }


    function _name() internal view returns (string memory) {

        return x.erc20.named;
    }

    function _symbol() internal view returns (string memory) {

        return x.erc20.symboled;
    }

    function _decimals() internal view returns (uint8) {

        return x.erc20.decimaled;
    }

    function _totalSupply() internal view returns (uint256) {

        return x.erc20.total;
    }

    function _balanceOf(address account) internal view returns (uint256) {

        return x.erc20.balances[account];
    }


    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        _transfer_(sender, recipient, amount);
        return true;
    }

    function _allowance(address owner, address spender) internal view returns (uint256) {

        return _allowance_(owner, spender);
    }

    function _approve(address spender, uint256 amount) internal returns (bool) {

        _approve_(_msgSender(), spender, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        _transfer_(sender, recipient, amount);

        uint256 currentAllowance = x.erc20.allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20._transferFrom: AMOUNT_EXCEEDS_ALLOWANCE");
        unchecked {
            _approve_(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _increaseAllowance(address spender, uint256 addedValue) internal returns (bool) {

        _approve_(_msgSender(), spender, x.erc20.allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function _decreaseAllowance(address spender, uint256 subtractedValue) internal returns (bool) {

        uint256 currentAllowance = x.erc20.allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20._decreaseAllowance: DECREASE_BELOW_ZERO");
        unchecked {
            _approve_(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _burn(uint256 amount) internal returns (bool) {

        _burn_(_msgSender(), amount);
        return true;
    }

    function _burnFrom(address account, uint256 amount) internal returns (bool) {

        uint256 currentAllowance = _allowance_(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20._burnFrom: AMOUNT_EXCEEDS_ALLOWANCE"
        );
        unchecked {
            _approve_(account, _msgSender(), currentAllowance - amount);
        }
        _burn_(account, amount);
        return true;
    }


    function _allowance_(address owner, address spender) private view returns (uint256) {

        return x.erc20.allowances[owner][spender];
    }

    function _transfer_(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        require(sender != address(0), "ERC20._transfer_: SENDER_ZERO_ADDRESS");
        require(recipient != address(0), "ERC20._transfer_: RECIPIENT_ZERO_ADDRESS");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = x.erc20.balances[sender];
        require(senderBalance >= amount, "ERC20._transfer_: AMOUNT_EXCEEDS_BALANCE");
        unchecked {
            x.erc20.balances[sender] = senderBalance - amount;
        }
        x.erc20.balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint_(address account, uint256 amount) private {

        require(account != address(0), "ERC20._mint_: ACCOUNT_ZERO_ADDRESS");

        _beforeTokenTransfer(address(0), account, amount);

        x.erc20.total += amount;
        x.erc20.balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn_(address account, uint256 amount) private {

        require(account != address(0), "ERC20._burn_: ACCOUNT_ZERO_ADDRESS");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = x.erc20.balances[account];
        require(accountBalance >= amount, "ERC20._burn_: AMOUNT_EXCEEDS_BALANCE");
        unchecked {
            x.erc20.balances[account] = accountBalance - amount;
        }
        x.erc20.total -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve_(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20._approve_: OWNER_ZERO_ADDRESS");
        require(spender != address(0), "ERC20._approve_: SPENDER_ZERO_ADDRESS");

        x.erc20.allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

}// MIT

pragma solidity ^0.8.0;



contract XenoERC20 is IXenoERC20, Initializable, UUPSUpgradeable, ManagerRole, Freezable, Pausable, Recoverable, ERC20 {


    function initialize(string calldata setName, string calldata setSymbol, uint256 initialSupply ) external initializer {
        _initializeManagerRole(msg.sender);
        
        _initalizeERC20(setName, setSymbol, 18, initialSupply);

        _initializePausable();
    }


    function isManager(address account) external view override returns (bool) {
        return _isManager(account);
    }

    function addManager(address account) external override {
       _addManager(account);
    }

    function renounceManager() external override {
        _renounceManager();
    }


    function name() external view override returns (string memory) {
        return _name();
    }

    function symbol() external view override returns (string memory) {
        return _symbol();
    }

    function decimals() external view override returns (uint8) {
        return _decimals();
    }


    function totalSupply() external view override returns (uint256) {
        return _totalSupply();
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOf(account);
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowance(owner, spender);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.transfer: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.transfer: CALLER_FROZEN"
        );
        require(
            !_frozen(recipient),
            "XenoERC20.transfer: RECIPIENT_FROZEN"
        );
        return _transfer(_msgSender(), recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.transferFrom: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.transferFrom: CALLER_FROZEN"
        );
        require(
            !_frozen(sender),
            "XenoERC20.transferFrom: SENDER_FROZEN"
        );
        require(
            !_frozen(recipient),
            "XenoERC20.transferFrom: RECIPIENT_FROZEN"
        );
        return _transferFrom(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.approve: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.approve: CALLER_FROZEN"
        );
        require(
            !_frozen(spender),
            "XenoERC20.approve: SPENDER_FROZEN"
        );
        return _approve(spender, amount);
    }


    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.increaseAllowance: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.increaseAllowance: CALLER_FROZEN"
        );
        require(
            !_frozen(spender),
            "XenoERC20.increaseAllowance: SPENDER_FROZEN"
        );
        return _increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.decreaseAllowance: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.decreaseAllowance: CALLER_FROZEN"
        );
        require(
            !_frozen(spender),
            "XenoERC20.decreaseAllowance: SPENDER_FROZEN"
        );
        return _decreaseAllowance(spender, subtractedValue);
    }


    function burn(uint256 amount) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.burn: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.burn: CALLER_FROZEN"
        );
        return _burn(amount);
    }

    function burnFrom(address account, uint256 amount) external override returns (bool) {
        require(
            !_paused(),
            "XenoERC20.burnFrom: PAUSED"
        );
        require(
            !_frozen(_msgSender()),
            "XenoERC20.burnFrom: CALLER_FROZEN"
        );
        require(
            !_frozen(account),
            "XenoERC20.burnFrom: ACCOUNT_FROZEN"
        );
        return _burnFrom(account, amount);
    }


    function frozen(address account) external view override returns (bool) {
        return _frozen(account);
    }

    function freeze(address account) external override {
        require(
            _isManager(_msgSender()),
            "XenoERC20.freeze: INVALID_CALLER"
        );
        _freeze(account);
    }

    function unfreeze(address account) external override {
        require(
            _isManager(_msgSender()),
            "XenoERC20.unfreeze: INVALID_CALLER"
        );
        _unfreeze(account);
    }


    function paused() external view override returns (bool) {
        return _paused();
    }

    function pause() external override {
        require(
            _isManager(_msgSender()),
            "XenoERC20.pause: INVALID_CALLER"
        );
        _pause();
    }

    function unpause() external override {
        require(
            _isManager(_msgSender()),
            "XenoERC20.unpause: INVALID_CALLER"
        );
        _unpause();
    }


    function recover(IERC20 token, uint256 amount) override external {
        require(
            _isManager(_msgSender()),
            "XenoERC20.recover: INVALID_CALLER"
        );
        _recover(token, amount);
    }


    function getImplementation() external view returns (address) {
        return _getImplementation();
    }


    function _authorizeUpgrade(address) internal view override {
        require(
            _isManager(_msgSender()),
            "XenoERC20._authorizeUpgrade: INVALID_CALLER"
        );
    }
}