
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}pragma solidity ^0.8.0;


contract BlackholePreventionUpgrade {

  using AddressUpgradeable for address payable;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  event WithdrawStuckEther(address indexed receiver, uint256 amount);
  event WithdrawStuckERC20(address indexed receiver, address indexed tokenAddress, uint256 amount);
  event WithdrawStuckERC721(address indexed receiver, address indexed tokenAddress, uint256 indexed tokenId);

  function _withdrawEther(address payable receiver, uint256 amount) internal virtual {

    require(receiver != address(0x0), "BHP:E-403");
    if (address(this).balance >= amount) {
      receiver.sendValue(amount);
      emit WithdrawStuckEther(receiver, amount);
    }
  }

  function _withdrawERC20(address payable receiver, address tokenAddress, uint256 amount) internal virtual {

    require(receiver != address(0x0), "BHP:E-403");
    if (IERC20Upgradeable(tokenAddress).balanceOf(address(this)) >= amount) {
      IERC20Upgradeable(tokenAddress).safeTransfer(receiver, amount);
      emit WithdrawStuckERC20(receiver, tokenAddress, amount);
    }
  }

  function _withdrawERC721(address payable receiver, address tokenAddress, uint256 tokenId) internal virtual {

    require(receiver != address(0x0), "BHP:E-403");
    if (IERC721Upgradeable(tokenAddress).ownerOf(tokenId) == address(this)) {
      IERC721Upgradeable(tokenAddress).transferFrom(address(this), receiver, tokenId);
      emit WithdrawStuckERC721(receiver, tokenAddress, tokenId);
    }
  }
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity ^0.8.0;

interface IDTOTokenBridge {

    function claimBridgeToken(address _originToken, address _to, uint256 _amount, uint256[] memory _chainIdsIndex, bytes32 _txHash) external;

}pragma solidity >=0.5.16;


abstract contract ChainIdHolding {
    uint256 public chainId;

    function __ChainIdHolding_init() internal {
        uint256 _cid;
        assembly {
            _cid := chainid()
        }
        chainId = _cid;
    }

}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}pragma solidity ^0.8.0;

contract DTOBridgeToken is
    ERC20BurnableUpgradeable,
    IDTOTokenBridge,
    OwnableUpgradeable,
    ChainIdHolding
{

    using SafeMathUpgradeable for uint256;
    mapping(bytes32 => bool) public alreadyClaims;
    address public originalTokenAddress;
    uint256 public originChainId;
    uint8 _decimals;

    function initialize(
        address _originalTokenAddress,
        uint256 _originChainId,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 __decimals
    ) external initializer {

        __Ownable_init();
        __ChainIdHolding_init();
        __ERC20_init(_tokenName, _tokenSymbol);
        _decimals = __decimals;
        originalTokenAddress = _originalTokenAddress;
        originChainId = _originChainId;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }

    function claimBridgeToken(
        address _originToken,
        address _to,
        uint256 _amount,
        uint256[] memory _chainIdsIndex,
        bytes32 _txHash
    ) public override onlyOwner {

        require(_chainIdsIndex.length == 4, "!_chainIdsIndex.length");
        require(_originToken == originalTokenAddress, "!originalTokenAddress");
        require(_chainIdsIndex[2] == chainId, "!invalid chainId");
        require(_to != address(0), "!invalid to");
        bytes32 _claimId = keccak256(
            abi.encode(
                _originToken,
                _to,
                _amount,
                _chainIdsIndex,
                _txHash,
                name(),
                symbol(),
                decimals()
            )
        );
        require(!alreadyClaims[_claimId], "already claim");

        alreadyClaims[_claimId] = true;
        _mint(_to, _amount); //send token to bridge contract, which then distributes token and fee to user and governance
    }
}pragma solidity ^0.8.0;


contract Governable is Initializable, OwnableUpgradeable {

    function __Governable_initialize() internal initializer {

        __Ownable_init();
    }

    modifier onlyGovernance() {

        require(msg.sender == owner(), "!onlyGovernance");
        _;
    }

    address public governance;

    function setGovernance(address _gov) public onlyGovernance {

        governance = _gov;
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library StorageSlotUpgradeable {

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


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
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
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}pragma solidity ^0.8.0;

contract DTOUpgradeableBase is
    Initializable, 
    UUPSUpgradeable,
    OwnableUpgradeable
{

    function __DTOUpgradeableBase_initialize() internal initializer {

        __Ownable_init();
    }

   constructor() initializer {}
   function _authorizeUpgrade(address) internal override onlyOwner {}

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}pragma solidity ^0.8.0;


contract GenericBridge is
    DTOUpgradeableBase,
    ReentrancyGuardUpgradeable,
    BlackholePreventionUpgrade,
    Governable,
    ChainIdHolding
{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address payable;
    struct TokenInfo {
        address addr;
        uint256 chainId;
    }

    address public NATIVE_TOKEN_ADDRESS;
    mapping(bytes32 => bool) public alreadyClaims;
    address[] public bridgeApprovers;
    mapping(address => bool) public approverMap; //easily check approver signature
    mapping(uint256 => bool) public supportedChainIds;
    mapping(address => uint256[]) public tokenMapList; //to which chain ids this token is bridged to
    mapping(address => mapping(uint256 => bool)) public tokenMapSupportCheck; //to which chain ids this token is bridged to
    mapping(uint256 => mapping(address => address)) public tokenMap; //chainid => origin token => bridge token
    mapping(address => TokenInfo) public tokenMapReverse; //bridge token => chain id => origin token
    mapping(address => bool) public bridgeTokens; //mapping of bridge tokens on this chain
    uint256 public claimFee; //fee paid in native token for nodes maintenance

    uint256 public index;
    uint256 public minApprovers;
    address payable public feeReceiver;
    mapping(uint256 => mapping(address => uint256)) public feeForTokens;
    uint256 public defaultFeePercentage;
    uint256 public constant DEFAULT_FEE_DIVISOR = 10_000;
    uint256 public constant DEFAULT_FEE_PERCENTAGE = 10; //0.1%

    event RequestBridge(
        address indexed _token,
        bytes _toAddr,
        uint256 _amount,
        uint256 _originChainId,
        uint256 _fromChainId,
        uint256 _toChainId,
        uint256 _index
    );
    event ClaimToken(
        address indexed _token,
        address indexed _toAddr,
        uint256 _amount,
        uint256 _originChainId,
        uint256 _fromChainId,
        uint256 _toChainId,
        uint256 _index,
        bytes32 _claimId
    );
    event ValidatorSign(
        address _validator,
        bytes32 _claimId,
        uint256 _timestamp
    );

    event SetFeeToken(
        uint256 chainId,
        address token,
        uint256 fee,
        uint256 timestamp
    );

    function initialize(uint256[] memory _chainIds) public initializer {
        __DTOUpgradeableBase_initialize();
        __Governable_initialize();
        __ChainIdHolding_init();
        NATIVE_TOKEN_ADDRESS = 0x1111111111111111111111111111111111111111;
        supportedChainIds[chainId] = true;
        minApprovers = 2;
        claimFee = 0;
        governance = owner();

        for (uint256 i = 0; i < _chainIds.length; i++) {
            supportedChainIds[_chainIds[i]] = true;
        }
        defaultFeePercentage = DEFAULT_FEE_PERCENTAGE; //0.1 %
    }

    function setMinApprovers(uint256 _val) public onlyGovernance {
        require(_val >= 2, "!min set approver");
        minApprovers = _val;
    }

    function setFeeReceiver(address payable _feeReceiver)
        external
        onlyGovernance
    {
        feeReceiver = _feeReceiver;
    }

    function setFeeForTokens(
        uint256[] memory chainIds,
        address[] memory originTokens,
        uint256[] memory fees
    ) external onlyGovernance {
        require(
            chainIds.length == originTokens.length &&
                originTokens.length == fees.length,
            "!input"
        );
        for (uint256 i = 0; i < originTokens.length; i++) {
            feeForTokens[chainIds[i]][originTokens[i]] = fees[i];
            emit SetFeeToken(
                chainIds[i],
                originTokens[i],
                fees[i],
                block.timestamp
            );
        }
    }

    function setDefaultFeePercentage(uint256 _val) external onlyGovernance {
        defaultFeePercentage = _val;
    }

    function addApprover(address _addr) public onlyGovernance {
        require(!approverMap[_addr], "already approver");
        require(_addr != address(0), "non zero address");
        bridgeApprovers.push(_addr);
        approverMap[_addr] = true;
    }

    function addApprovers(address[] memory _addrs) public onlyGovernance {
        for (uint256 i = 0; i < _addrs.length; i++) {
            if (!approverMap[_addrs[i]]) {
                bridgeApprovers.push(_addrs[i]);
                approverMap[_addrs[i]] = true;
            }
        }
    }

    function removeApprover(address _addr) public onlyGovernance {
        require(approverMap[_addr], "not approver");
        for (uint256 i = 0; i < bridgeApprovers.length; i++) {
            if (bridgeApprovers[i] == _addr) {
                bridgeApprovers[i] = bridgeApprovers[
                    bridgeApprovers.length - 1
                ];
                bridgeApprovers.pop();
                approverMap[_addr] = false;
                return;
            }
        }
    }

    function setSupportedChainId(uint256 _chainId, bool _val)
        public
        onlyGovernance
    {
        supportedChainIds[_chainId] = _val;
    }

    function setSupportedChainIds(uint256[] memory _chainIds, bool _val)
        public
        onlyGovernance
    {
        for (uint256 i = 0; i < _chainIds.length; i++) {
            supportedChainIds[_chainIds[i]] = _val;
        }
    }

    function setGovernanceFee(uint256 _fee) public onlyGovernance {
        claimFee = _fee;
    }

    function requestBridge(
        address _tokenAddress,
        bytes memory _toAddr,
        uint256 _amount,
        uint256 _toChainId
    ) public payable nonReentrant {
        require(
            chainId != _toChainId,
            "source and target chain ids must be different"
        );
        require(supportedChainIds[_toChainId], "unsupported chainId");
        if (!isBridgeToken(_tokenAddress)) {

            uint256 feePercent = defaultFeePercentage == 0
                ? DEFAULT_FEE_PERCENTAGE
                : defaultFeePercentage;
            uint256 forUser =
                (_amount * (DEFAULT_FEE_DIVISOR - feePercent)) /
                DEFAULT_FEE_DIVISOR;
            uint256 forFee = _amount - forUser;

            safeTransferIn(_tokenAddress, msg.sender, _amount);
            safeTransferOut(_tokenAddress, msg.sender, 0, forFee);

            emit RequestBridge(
                _tokenAddress,
                _toAddr,
                forUser,
                chainId,
                chainId,
                _toChainId,
                index
            );
            index++;

            if (!tokenMapSupportCheck[_tokenAddress][_toChainId]) {
                tokenMapList[_tokenAddress].push(_toChainId);
                tokenMapSupportCheck[_tokenAddress][_toChainId] = true;
            }
        } else {
            address _originToken = tokenMapReverse[_tokenAddress].addr;
            ERC20BurnableUpgradeable(_tokenAddress).burnFrom(
                msg.sender,
                _amount
            );
            emit RequestBridge(
                _originToken,
                _toAddr,
                _amount,
                tokenMapReverse[_tokenAddress].chainId,
                chainId,
                _toChainId,
                index
            );
            index++;
        }
    }

    function verifySignatures(
        bytes32[] memory r,
        bytes32[] memory s,
        uint8[] memory v,
        bytes32 signedData
    ) internal returns (bool) {
        require(minApprovers >= 2, "!min approvers");
        require(bridgeApprovers.length >= minApprovers, "!min approvers");
        uint256 successSigner = 0;
        if (
            r.length == s.length &&
            s.length == v.length &&
            v.length >= minApprovers
        ) {
            for (uint256 i = 0; i < r.length; i++) {
                address signer = ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            signedData
                        )
                    ),
                    v[i],
                    r[i],
                    s[i]
                );
                if (approverMap[signer]) {
                    successSigner++;
                    emit ValidatorSign(signer, signedData, block.timestamp);
                }
            }
        }

        return successSigner >= minApprovers;
    }

    function claimToken(
        address _originToken,
        address _toAddr,
        uint256 _amount,
        uint256[] memory _chainIdsIndex,
        bytes32 _txHash,
        bytes32[] memory r,
        bytes32[] memory s,
        uint8[] memory v,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) external payable nonReentrant {
        require(
            _chainIdsIndex.length == 4 && chainId == _chainIdsIndex[2],
            "!chain id claim"
        );
        bytes32 _claimId = keccak256(
            abi.encode(
                _originToken,
                _toAddr,
                _amount,
                _chainIdsIndex,
                _txHash,
                _name,
                _symbol,
                _decimals
            )
        );
        require(!alreadyClaims[_claimId], "already claim");
        require(verifySignatures(r, s, v, _claimId), "invalid signatures");

        payClaimFee(msg.value);

        alreadyClaims[_claimId] = true;

        if (_originToken == NATIVE_TOKEN_ADDRESS) {
            if (_chainIdsIndex[0] != chainId) {
                if (tokenMap[_chainIdsIndex[0]][_originToken] == address(0)) {
                    DTOBridgeToken bt = new DTOBridgeToken();
                    bt.initialize(
                        _originToken,
                        _chainIdsIndex[0],
                        _name,
                        _symbol,
                        _decimals
                    );
                    tokenMap[_chainIdsIndex[0]][_originToken] = address(bt);
                    tokenMapReverse[address(bt)] = TokenInfo({
                        addr: _originToken,
                        chainId: _chainIdsIndex[0]
                    });
                    bridgeTokens[address(bt)] = true;
                }
                _mintTokenForUser(
                    _amount,
                    _originToken,
                    _chainIdsIndex,
                    _txHash,
                    _toAddr
                );
                emit ClaimToken(
                    _originToken,
                    _toAddr,
                    _amount,
                    _chainIdsIndex[0],
                    _chainIdsIndex[1],
                    chainId,
                    _chainIdsIndex[3],
                    _claimId
                );
            } else {
                _transferOriginToken(
                    _amount,
                    _originToken,
                    _chainIdsIndex,
                    _toAddr
                );

                emit ClaimToken(
                    _originToken,
                    _toAddr,
                    _amount,
                    _chainIdsIndex[0],
                    _chainIdsIndex[1],
                    chainId,
                    _chainIdsIndex[3],
                    _claimId
                );
            }
        } else if (tokenMapList[_originToken].length == 0) {
            if (tokenMap[_chainIdsIndex[0]][_originToken] == address(0)) {
                DTOBridgeToken bt = new DTOBridgeToken();
                bt.initialize(
                    _originToken,
                    _chainIdsIndex[0],
                    _name,
                    _symbol,
                    _decimals
                );
                tokenMap[_chainIdsIndex[0]][_originToken] = address(bt);
                tokenMapReverse[address(bt)] = TokenInfo({
                    addr: _originToken,
                    chainId: _chainIdsIndex[0]
                });
                bridgeTokens[address(bt)] = true;
            }

            _mintTokenForUser(
                _amount,
                _originToken,
                _chainIdsIndex,
                _txHash,
                _toAddr
            );
            emit ClaimToken(
                _originToken,
                _toAddr,
                _amount,
                _chainIdsIndex[0],
                _chainIdsIndex[1],
                chainId,
                _chainIdsIndex[3],
                _claimId
            );
        } else {
            _transferOriginToken(
                _amount,
                _originToken,
                _chainIdsIndex,
                _toAddr
            );
            emit ClaimToken(
                _originToken,
                _toAddr,
                _amount,
                _chainIdsIndex[0],
                _chainIdsIndex[1],
                chainId,
                _chainIdsIndex[3],
                _claimId
            );
        }
    }

    function _mintTokenForUser(
        uint256 _amount,
        address _originToken,
        uint256[] memory _chainIdsIndex,
        bytes32 _txHash,
        address _toAddr
    ) internal {
        IDTOTokenBridge(tokenMap[_chainIdsIndex[0]][_originToken])
            .claimBridgeToken(
                _originToken,
                _toAddr,
                _amount,
                _chainIdsIndex,
                _txHash
            );
    }

    function _transferOriginToken(
        uint256 _amount,
        address _originToken,
        uint256[] memory _chainIdsIndex,
        address _toAddr
    ) internal {
        (uint256 forUser, uint256 forFee) = getAmountsToSend(
            _amount,
            _originToken,
            _chainIdsIndex[0]
        );
        safeTransferOut(_originToken, _toAddr, forUser, forFee);
    }

    function payClaimFee(uint256 _amount) internal {
        if (claimFee > 0) {
            require(_amount >= claimFee, "!min claim fee");
            payable(governance).sendValue(_amount);
        }
    }

    function isBridgeToken(address _token) public view returns (bool) {
        return bridgeTokens[_token];
    }

    function safeTransferIn(
        address _token,
        address _from,
        uint256 _amount
    ) internal {
        if (_token == NATIVE_TOKEN_ADDRESS) {
            require(msg.value == _amount, "invalid bridge amount");
        } else {
            IERC20Upgradeable erc20 = IERC20Upgradeable(_token);
            uint256 balBefore = erc20.balanceOf(address(this));
            erc20.safeTransferFrom(_from, address(this), _amount);
            require(
                erc20.balanceOf(address(this)).sub(balBefore) == _amount,
                "!transfer from"
            );
        }
    }

    function safeTransferOut(
        address _token,
        address _toAddr,
        uint256 _forUser,
        uint256 _forFee
    ) internal {
        if (_token == NATIVE_TOKEN_ADDRESS) {
            payable(_toAddr).sendValue(_forUser);
            payable(getFeeRecipientAddress()).sendValue(_forFee);
        } else {
            IERC20Upgradeable erc20 = IERC20Upgradeable(_token);
            uint256 balBefore = erc20.balanceOf(address(this));
            if (_forUser > 0) {
                erc20.safeTransfer(_toAddr, _forUser);
            }
            if (_forFee > 0) {
                erc20.safeTransfer(getFeeRecipientAddress(), _forFee);
            }
            require(
                balBefore.sub(erc20.balanceOf(address(this))) ==
                    _forUser + _forFee,
                "!transfer to"
            );
        }
    }

    function getAmountsToSend(
        uint256 amount,
        address originToken,
        uint256 originChainId
    ) internal view returns (uint256 forUser, uint256 forFee) {
        uint256 feePercent = defaultFeePercentage == 0
            ? DEFAULT_FEE_PERCENTAGE
            : defaultFeePercentage;
        forUser =
            (amount * (DEFAULT_FEE_DIVISOR - feePercent)) /
            DEFAULT_FEE_DIVISOR;
        forFee = amount - forUser;
    }

    function getFeeInfo(address token)
        external
        view
        returns (uint256 feeAmount, uint256 feePercent)
    {
        feePercent = defaultFeePercentage == 0
            ? DEFAULT_FEE_PERCENTAGE
            : defaultFeePercentage;
    }

    function getFeeRecipientAddress()
        internal
        view
        returns (address payable ret)
    {
        ret = feeReceiver == address(0) ? payable(owner()) : feeReceiver;
    }

    function getSupportedChainsForToken(address _token)
        external
        view
        returns (uint256[] memory)
    {
        return tokenMapList[_token];
    }

    function getBridgeApprovers() external view returns (address[] memory) {
        return bridgeApprovers;
    }

    function withdrawEther(address payable receiver, uint256 amount)
        external
        virtual
        onlyGovernance
    {
        _withdrawEther(receiver, amount);
    }

    function withdrawERC20(
        address payable receiver,
        address tokenAddress,
        uint256 amount
    ) external virtual onlyGovernance {
        _withdrawERC20(receiver, tokenAddress, amount);
    }

    function withdrawERC721(
        address payable receiver,
        address tokenAddress,
        uint256 tokenId
    ) external virtual onlyGovernance {
        _withdrawERC721(receiver, tokenAddress, tokenId);
    }
}