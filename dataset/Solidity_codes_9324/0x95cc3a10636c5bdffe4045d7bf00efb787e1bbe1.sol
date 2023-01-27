



pragma solidity 0.8.4;

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
}







interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}







library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}







interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}








abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}




pragma solidity 0.8.4;


abstract contract ERC2771ContextUpgradeable is Initializable {
    address public _trustedForwarder;

    function __ERC2771Context_init(address trustedForwarder) internal initializer {
        __ERC2771Context_init_unchained(trustedForwarder);
    }

    function __ERC2771Context_init_unchained(address trustedForwarder) internal initializer {
        _trustedForwarder = trustedForwarder;
    }
    
    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
    uint256[49] private __gap;
}



abstract contract PausableUpgradeable is Initializable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;
  
    function __Pausable_init() internal initializer {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "BICO:: Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "BICO:: Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
    uint256[49] private __gap;
}



abstract contract AccessControlUpgradeable is Initializable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __ERC165_init();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "BICO:: AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == msg.sender, "BICO:: AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
    uint256[49] private __gap;
}



contract GovernedUpgradeable is Initializable {


    address public governor;
    address public pendingGovernor;


    event NewPendingOwnership(address indexed from, address indexed to);
    event NewOwnership(address indexed from, address indexed to);

    modifier onlyGovernor {

        require(msg.sender == governor, "BICO:: Only Governor can call");
        _;
    }

    function __Governed_init(address _initGovernor) internal initializer {

        __Governed_init_unchained(_initGovernor);
    }

    function __Governed_init_unchained(address _initGovernor) internal initializer {

        governor = _initGovernor;
    }

    function transferOwnership(address _newGovernor) external onlyGovernor {

        require(_newGovernor != address(0), "BICO:: Governor must be set");

        address oldPendingGovernor = pendingGovernor;
        pendingGovernor = _newGovernor;

        emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
    }

    function acceptOwnership() external {

        require(
            pendingGovernor != address(0) && msg.sender == pendingGovernor,
            "Caller must be pending governor"
        );

        address oldGovernor = governor;
        address oldPendingGovernor = pendingGovernor;

        governor = pendingGovernor;
        pendingGovernor = address(0);

        emit NewOwnership(oldGovernor, governor);
        emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
    }
    uint256[49] private __gap;
}



library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("BICO:: ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "BICO:: ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "BICO:: ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "BICO:: ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


contract BicoTokenImplementation is Initializable, ERC2771ContextUpgradeable, PausableUpgradeable, AccessControlUpgradeable, GovernedUpgradeable, ReentrancyGuardUpgradeable {

    mapping(address => uint256) private _balances;

    uint8 internal _initializedVersion;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint public mintingAllowedAfter;

    uint32 public minimumTimeBetweenMints;

    uint8 public mintCap;


    bytes32 public constant DOMAIN_TYPE_HASH = keccak256(
        "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
    );
    bytes32 public constant APPROVE_TYPEHASH = keccak256(
        "Approve(address owner,address spender,uint256 value,uint256 batchId,uint256 batchNonce,uint256 deadline)"
    );
    bytes32 public constant TRANSFER_TYPEHASH = keccak256(
        "Transfer(address sender,address recipient,uint256 amount,uint256 batchId,uint256 batchNonce,uint256 deadline)"
    );
    bytes32 private DOMAIN_SEPARATOR;
    mapping(address => mapping(uint256 => uint256)) public nonces;


    event TrustedForwarderChanged(address indexed truestedForwarder, address indexed actor);

    event MintingAllowedAfterChanged(uint indexed _mintingAllowedAfter, address indexed actor);

    event MinimumTimeBetweenMintsChanged(uint32 indexed _minimumTimeBetweenMints, address indexed actor);

    event MintCapChanged(uint8 indexed _mintCap, address indexed actor);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function initialize(address beneficiary, address trustedForwarder, address governor, address accessControlAdmin, address pauser, address minter) public initializer {

       __BicoTokenImplementation_init_unchained(accessControlAdmin,pauser,minter);
       _mint(beneficiary, 1000000000 * 10 ** decimals());
       __ERC2771Context_init(trustedForwarder);
       __Pausable_init();
       __AccessControl_init();
       __Governed_init(governor);
       __ReentrancyGuard_init();
       _initializedVersion = 0;
       mintingAllowedAfter = 0;
       minimumTimeBetweenMints = 1 days * 365;
       mintCap = 2;
    }
    
    function __BicoTokenImplementation_init_unchained(address accessControlAdmin, address pauser, address minter) internal initializer {

        _name = "Biconomy Token";
        _symbol = "BICO";
        _setupRole(DEFAULT_ADMIN_ROLE, accessControlAdmin);
        _setupRole(PAUSER_ROLE, pauser);
        _setupRole(MINTER_ROLE, minter);

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPE_HASH,
                keccak256("Biconomy Token"),
                keccak256("1"),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {

        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual nonReentrant whenNotPaused returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual nonReentrant whenNotPaused returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual nonReentrant whenNotPaused returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BICO:: ERC20: transfer amount exceeds allowance");  
        unchecked {      
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual nonReentrant whenNotPaused returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual nonReentrant whenNotPaused returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BICO:: ERC20: decreased allowance below zero");
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

        require(sender != address(0), "BICO:: ERC20: transfer from the zero address");
        require(recipient != address(0), "BICO:: ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BICO:: ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "BICO:: ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "BICO:: ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BICO:: ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "BICO:: ERC20: approve from the zero address");
        require(spender != address(0), "BICO:: ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _updateNonce(address _user, uint256 _batchId) internal {

        nonces[_user][_batchId]++;
    }

    function approveWithSig(
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint256 _deadline,
        address _owner,
        uint256 _batchId,
        address _spender,
        uint256 _value
    ) public virtual nonReentrant whenNotPaused {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        APPROVE_TYPEHASH,
                        _owner,
                        _spender,
                        _value,
                        _batchId,
                        nonces[_owner][_batchId],
                        _deadline
                    )
                )
            )
        );
        
        address recoveredAddress = ECDSA.recover(digest, abi.encodePacked(_r, _s, _v));
        require(recoveredAddress != address(0), "BICO:: invalid signature");
        require(_owner == recoveredAddress, "BICO:: invalid approval:Unauthorized");
        require(_deadline == 0 || block.timestamp <= _deadline, "BICO:: expired approval");
          _updateNonce(_owner,_batchId);
        _approve(_owner, _spender, _value);
    }

    function transferWithSig(
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint256 _deadline,
        address _sender,
        uint256 _batchId,
        address _recipient,
        uint256 _amount
    ) public virtual nonReentrant whenNotPaused {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        TRANSFER_TYPEHASH,
                        _sender,
                        _recipient,
                        _amount,
                        _batchId,
                        nonces[_sender][_batchId],
                        _deadline
                    )
                )
            )
        );
        

        address recoveredAddress = ECDSA.recover(digest, abi.encodePacked(_r, _s, _v));
        require(recoveredAddress != address(0), "BICO:: invalid signature");
        require(_sender == recoveredAddress, "BICO:: invalid transfer:Unauthorized");
        require(_deadline == 0 || block.timestamp <= _deadline, "BICO:: expired transfer");
        _updateNonce(_sender,_batchId);
        _transfer(_sender, _recipient, _amount);
    }

    function pause() public onlyRole(PAUSER_ROLE) {

        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {

        _unpause();
    }

    function setTrustedForwarder(address payable _forwarder) external onlyGovernor {

        require(_forwarder != address(0), "BICO:: Invalid address for new trusted forwarder");
        _trustedForwarder = _forwarder;
        emit TrustedForwarderChanged(_forwarder, msg.sender);
    }

    function setMintingAllowedAfter(uint _mintingAllowedAfter) external onlyGovernor {

        mintingAllowedAfter = _mintingAllowedAfter;
        emit MintingAllowedAfterChanged(_mintingAllowedAfter,msg.sender);
    }

    function setMinimumTimeBetweenMints(uint32 _minimumTimeBetweenMints) external onlyGovernor {

        minimumTimeBetweenMints = _minimumTimeBetweenMints;
        emit MinimumTimeBetweenMintsChanged(_minimumTimeBetweenMints,msg.sender);
    }

    function setMintCap(uint8 _mintCap) external onlyGovernor {

        mintCap = _mintCap;
        emit MintCapChanged(_mintCap, msg.sender);
    }

    function getChainId() internal view returns (uint) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

}