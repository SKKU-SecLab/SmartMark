

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
}

interface ITransferProvider {

  event TransferApproved(address indexed from, address indexed to, uint256 value);
  event TransferDeclined(address indexed from, address indexed to, uint256 value);

  function approveTransfer(address from, address to, uint256 value, address spender) external returns(bool);


  function considerTransfer(address from, address to, uint256 value) external returns(bool);

}

interface IRBAC {

  event RoleCreated(uint256 role);
  event BearerAdded(address indexed account, uint256 role);
  event BearerRemoved(address indexed account, uint256 role);

  function addRootRole(string calldata roleDescription) external returns(uint256);

  function removeBearer(address account, uint256 role) external;

  function addRole(string calldata roleDescription, uint256 admin) external returns(uint256);

  function totalRoles() external view returns(uint256);

  function hasRole(address account, uint256 role) external view returns(bool);

  function addBearer(address account, uint256 role) external;

}

interface IERC20PermitUpgradeable {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}

interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


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
}

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
}

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}

library ECDSAUpgradeable {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

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
}

abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");


    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}


abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    bytes32 private _PERMIT_TYPEHASH;

    function __ERC20Permit_init(string memory name) internal initializer {
        __Context_init_unchained();
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained(name);
    }

    function __ERC20Permit_init_unchained(string memory name) internal initializer {
        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner) internal virtual returns (uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
    uint256[49] private __gap;
}

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
}

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}


abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}


contract VNXDGR is Initializable, OwnableUpgradeable, ERC20PausableUpgradeable, ERC20PermitUpgradeable {

    uint8 public assetProtectionRole;
    mapping(address => bool) internal frozen;

    uint8 public supplyControllerRole;

    ITransferProvider private transferProvider;
    IRBAC private rbacManager;
    address private feeRecipient;

    uint8 public constant feeDecimals = 6;
    uint256 private feeRate;

    modifier onlyAdmin() {

      require(isAdmin(), "Only Admin role");
      _;
    }

    function isAdmin() public view returns (bool) {

      return rbacManager.hasRole(msg.sender, 0);
    }


    event TransferProviderChanged(address indexed oldProvider, address indexed newProvider);

    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event AssetProtectionRoleSet (
        uint8 indexed oldAssetProtectionRole,
        uint8 indexed newAssetProtectionRole
    );

    event SupplyIncreased(address indexed to, uint256 value);
    event SupplyDecreased(address indexed from, uint256 value);
    event SupplyControllerSet(
        uint8 indexed oldSupplyController,
        uint8 indexed newSupplyController
    );

    event FeeCollected(address indexed from, address indexed to, uint256 value);
    event FeeRateSet(
        uint256 indexed oldFeeRate,
        uint256 indexed newFeeRate
    );
    event FeeRecipientSet(
        address indexed oldFeeRecipient,
        address indexed newFeeRecipient
    );


    function transfer(address _to, uint256 _value) public whenNotPaused override returns (bool) {

        require(_to != msg.sender, "Useless");
        require(!frozen[_to] && !frozen[msg.sender], "Frozen");
        require(_value > 0, "VAL>0!");

        uint256 _cleanvalue = _transferFee(_msgSender(), _value);
        return super.transfer(_to, _cleanvalue);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused override returns (bool) {

        require(_to != _from, "Useless");
        require(!frozen[_to] && !frozen[_from] && !frozen[msg.sender], "Frozen");
        require(_value > 0, "VAL>0!");

        uint256 _cleanvalue = _transferFee(_from, _value);
        return super.transferFrom(_from, _to, _cleanvalue);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused override returns (bool) {

        require(!frozen[_spender] && !frozen[_msgSender()], "Frozen");
        return super.approve(_spender, _value);
    }

    function transferAnyERC20Token(address _token, address _to, uint _amount) external onlyAdmin returns (bool success) {

        require(_token!=address(0), "_token=0!");

        return IERC20Upgradeable(_token).transfer(_to, _amount);
    }


    function setAssetProtectionRole(uint8 _newAssetProtectionRole) external onlyAdmin {

        require(assetProtectionRole!=_newAssetProtectionRole, "Same AP!");

        emit AssetProtectionRoleSet(assetProtectionRole, _newAssetProtectionRole);
        assetProtectionRole = _newAssetProtectionRole;
    }

    modifier onlyAssetProtectionRole() {

        require(rbacManager.hasRole(_msgSender(), assetProtectionRole), "Only AP!");
        _;
    }

    function freeze(address _addr) external onlyAssetProtectionRole {

        require(!frozen[_addr], "Frozen");
		
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    function unfreeze(address _addr) external onlyAssetProtectionRole {

        require(frozen[_addr], "Unfrozen");
		
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    function reclaimTokensFromFrozenAddress(address _addr) external onlyAssetProtectionRole onlySupplyControllerRole {

        require(frozen[_addr], "!Frozen");
        super._transfer(_addr, _msgSender(), balanceOf(_addr));
    }

    function isFrozen(address _addr) external view returns (bool) {

        return frozen[_addr];
    }


    function setSupplyControllerRole(uint8 _newSupplyControllerRole) external onlyAdmin {

		require(supplyControllerRole!=_newSupplyControllerRole, "Same SC!");
		
        emit SupplyControllerSet(supplyControllerRole, _newSupplyControllerRole);
        supplyControllerRole = _newSupplyControllerRole;
    }

    modifier onlySupplyControllerRole() {

        require(rbacManager.hasRole(_msgSender(), supplyControllerRole), "Only SC!");
        _;
    }

    function increaseSupply(address _wallet, uint256 _value) external onlySupplyControllerRole returns (bool success) {

        require(_value > 0, "VAL>0!");

        emit SupplyIncreased(_wallet, _value);
        _mint(_wallet, _value);

        return true;
    }

    function decreaseSupply(address _wallet, uint256 _value) external onlySupplyControllerRole returns (bool success) {

        require(_wallet != address(0), "WALLET=0!");
        require(_value > 0, "VAL>0!");
	
        if (_wallet != _msgSender()) {
          uint256 currentAllowance = allowance(_wallet, _msgSender());
          require(currentAllowance >= _value, "ERC20: burn > allowance");
          _approve(_wallet, _msgSender(), currentAllowance - _value);
        }
        _burn(_wallet, _value);

        emit SupplyDecreased(_wallet, _value);
        return true;
    }

   function changeTransferProvider(address _newProvider) external onlyAdmin {

        require(address(transferProvider) != _newProvider, "Same provider!");
        require(_newProvider != address(0), "Provider=0!");

        emit TransferProviderChanged(address(transferProvider), _newProvider);
     	transferProvider = ITransferProvider(_newProvider);
    }

   function initialize(address _initTransferProvider, address _rbac, uint8 _supplyControllerRole, 
     uint8 _assetProtectionRole, address _owner, string memory _name, string memory _symbol) external initializer
    {

        require(_initTransferProvider != address(0), "Init=0!");
        require(_rbac != address(0), "RBAC=0!");

        transferProvider = ITransferProvider(_initTransferProvider);
        rbacManager = IRBAC(_rbac);
        assetProtectionRole = _assetProtectionRole;
        supplyControllerRole = _supplyControllerRole;
        __Ownable_init();
        __ERC20_init(_name, _symbol);
        __ERC20Pausable_init();
        __ERC20Permit_init(_name);
		
        transferOwnership(_owner);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {

        require(transferProvider.approveTransfer(from, to, amount, _msgSender()), "Declined by TP!");
        super._beforeTokenTransfer(from, to, amount);
    }

	
    function setFeeRecipient(address _newFeeRecipient) external onlyAdmin {

        require(_newFeeRecipient != address(0), "Fee recpient=0!");
        address _oldFeeRecipient = feeRecipient;
        feeRecipient = _newFeeRecipient;
        emit FeeRecipientSet(_oldFeeRecipient, feeRecipient);
    }

    function setFeeRate(uint256 _newFeeRate) external onlyAdmin {

        require(_newFeeRate <= 10**uint256(feeDecimals), "Fee rate>100%");
        uint256 _oldFeeRate = feeRate;
        feeRate = _newFeeRate;
        emit FeeRateSet(_oldFeeRate, feeRate);
    }

    function getFeeFor(uint256 _value) public view returns (uint256) {

        if (feeRate == 0) {
            return 0;
        }
        return _value * feeRate / (10**uint256(feeDecimals));
    }

    function _transferFee(address _from, uint256 _value) internal returns (uint256 _remainder)
    {

        uint256 _fee = getFeeFor(_value);
        if (_fee > 0 && feeRecipient != address(0)) {
            _remainder = _value - _fee;
            super._transfer(_from, feeRecipient, _fee);
			
            emit FeeCollected(_from, feeRecipient, _fee);
        } else { // no fee deduction
            _remainder = _value;
        }
    }

    function pause() external onlyAssetProtectionRole
    {

      _pause();
    }

    function unpause() external onlyAssetProtectionRole
    {

      _unpause();
    }

    function getChainId() external view returns (uint256) {

        return block.chainid;
    }
}