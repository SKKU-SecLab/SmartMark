

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library Signer
{

    function recoverSigner(bytes32 dataHash, bytes memory sig) internal pure returns (address)
    {

        require(sig.length == 65, "Signature incorrect length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        return ecrecover(dataHash, v, r, s);
    }

    function recoverPrefixedTxData(bytes memory sig, bytes memory txData) internal pure returns (address)
    {

        bytes memory prefix = "\x19Ethereum Signed Message:\n112";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, txData));
        address signer = recoverSigner(prefixedHash, sig);
        return signer;
    }

    function recover(bytes memory sig, bytes memory txData) internal pure returns (address)
    {

        address signer = recoverSigner(keccak256(txData), sig);
        return signer;
    }
}



library BitShifter
{

    function readUint64(bytes memory buffer, uint offset) internal pure returns (uint64)
    {

        require(buffer.length >= offset + 32, "Uint64 out of range");

        uint256 res;
        assembly {
            res := mload(add(buffer, add(0x20, offset)))
        }

        return uint64(res >> 192);
    }

    function readUint256(bytes memory buffer, uint offset) internal pure returns (uint256)
    {

        require(buffer.length >= offset + 32, "Uint256 out of range");

        uint256 res;
        assembly {
            res := mload(add(buffer, add(0x20, offset)))
        }

        return res;
    }

    function readAddress(bytes memory buffer, uint offset) internal pure returns (address)
    {

        require(buffer.length >= offset + 32, "Address out of range");

        address res;
        assembly {
            res := mload(add(buffer, add(0x20, offset)))
        }

        return res;
    }

    function decompose(bytes memory txData) internal pure returns (uint256, uint64, uint64, uint256, address)
    {

        uint256 numTokens = readUint256(txData, 0);
        uint64 withdrawalBridgeId = readUint64(txData, 32);
        uint64 depositBridgeId = readUint64(txData, 40);
        uint256 nonce = readUint256(txData, 48);
        address user = readAddress(txData, 80);

        return ( numTokens, withdrawalBridgeId, depositBridgeId, nonce, user );
    }
}














interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}










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
}


library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
























abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



abstract contract SecureContract is AccessControl
{
    event ContractPaused (uint height, address user);
    event ContractUnpaused (uint height, address user);
    event OwnershipTransferred(address oldOwner, address newOwner);
    event TokensRecovered (address token, address user, uint256 numTokens);

    bytes32 public constant _ADMIN = keccak256("_ADMIN");

    bool private paused_;
    address private owner_;

    using SafeERC20 for IERC20;

    modifier pause()
    {
        require(!paused_, "SecureContract: Contract is paused");
        _;
    }

    modifier isAdmin()
    {
        require(hasRole(_ADMIN, msg.sender), "SecureContract: Not admin - Permission denied");
        _;
    }

    modifier isOwner()
    {
        require(msg.sender == owner_, "SecureContract: Not owner - Permission denied");
        _;
    }

    constructor()
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(_ADMIN, msg.sender);
        paused_ = true;
        owner_ = msg.sender;
    }

    function setPaused(bool paused) public isAdmin
    {
        if (paused != paused_)
        {
            paused_ = paused;
            if (paused)
                emit ContractPaused(block.number, msg.sender);
            else 
                emit ContractUnpaused(block.number, msg.sender);
        }
    }

    function queryPaused() public view returns (bool)
    {
        return paused_;
    }

    function transferOwnership(address newOwner) public isOwner
    {
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        grantRole(_ADMIN, newOwner);

        revokeRole(_ADMIN, owner_);
        revokeRole(DEFAULT_ADMIN_ROLE, owner_);

        address oldOwner = owner_;
        owner_ = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function recoverTokens(address token, address user, uint256 numTokens) public isOwner
    {
        IERC20(token).safeTransfer(user, numTokens);
        emit TokensRecovered(token, user, numTokens);
    }
}


abstract contract CiviPortBridgeVerifier is SecureContract
{
    bytes32 public constant _DEPOSIT = keccak256("_DEPOSIT");

    event EnergizeOnlyChanged (address sender, bool newValue);

    mapping(uint256 => bool) public withdrawNonces;
    mapping(uint256 => bool) public depositNonces;

    uint64 private bridgeId_;
    uint8 private numSigners_;

    bool private energizeOnly_;

    using BitShifter for bytes;

    constructor(uint64 bridgeId, uint8 numSigners) SecureContract()
    {
        _setupRole(_DEPOSIT, msg.sender);
        _setRoleAdmin(_DEPOSIT, _ADMIN);
        bridgeId_ = bridgeId;
        numSigners_ = numSigners;
        energizeOnly_ = true;
    }

    modifier energizeOnly()
    {
        require(!energizeOnly_, "SecureContract: Contract only allows energize");
        _;
    }

    function queryBridgeID() public view returns (uint64)
    {
        return bridgeId_;
    }

    function queryWithdrawNonceUsed(bytes memory nonceBytes) public view returns (bool)
    {
        uint256 nonce = nonceBytes.readUint256(0);
        return withdrawNonces[nonce];
    }

    function queryDepositNonceUsed(bytes memory nonceBytes) public view returns (bool)
    {
        uint256 nonce = nonceBytes.readUint256(0);
        return depositNonces[nonce];
    }

    function queryConfirmationCount() public view returns (uint8)
    {
        return numSigners_;
    }

    function setConfirmationCount(uint8 count) public isAdmin
    {
        numSigners_ = count;
    }

    function queryEnergizeOnly() public view returns (bool)
    {
        return energizeOnly_;
    }

    function setEnergizeOnly(bool allowEnergizeOnly) public isAdmin
    {
        if (allowEnergizeOnly != energizeOnly_)
        {
            energizeOnly_ = allowEnergizeOnly;
            emit EnergizeOnlyChanged(msg.sender, energizeOnly_);
        }
    }

    function exists(address[] memory array, address entry) private pure returns (bool)
    {
        uint len = array.length;
        for (uint i = 0; i < len; i++)
        {
            if (array[i] == entry)
                return true;
        }

        return false;
    }

    function verifyDeposit(bytes memory clientSignature, bytes[] memory serverSignatures, bytes memory transactionData) pause
        public view returns(address, uint256, uint256)
    {
        address clientSigner = Signer.recoverPrefixedTxData(clientSignature, transactionData);
        uint8 sigCount = (uint8)(serverSignatures.length);
        require (sigCount >= numSigners_, "Not enough signatures");

        address[] memory usedAddresses = new address[](numSigners_);

        for (uint i = 0; i < numSigners_; i++)
        {
            address serverSigner = Signer.recoverPrefixedTxData(serverSignatures[i], transactionData);
            require (hasRole(_DEPOSIT, serverSigner), "Multisig signer not permitted");
            require (!exists(usedAddresses, serverSigner), "Duplicate multisig signer");
            usedAddresses[i] = serverSigner;
        }

        uint256 numTokens;
        uint64 withdrawalBridgeId;
        uint64 depositBridgeId;
        uint256 nonce;
        address user;

        (numTokens, withdrawalBridgeId, depositBridgeId, nonce, user) = transactionData.decompose();

        require (clientSigner == user, "Not signed by client");
        require (clientSigner == msg.sender, "Not sent by client");
        require (depositBridgeId == bridgeId_, "Incorrect network");
        require (!depositNonces[nonce], "Nonce already used");

        return (user, nonce, numTokens);
    }

    function verifyWithdraw(bytes memory clientSignature, bytes memory transactionData) pause energizeOnly
        public view returns(address, uint256, uint256)
    {
        address signer = Signer.recoverPrefixedTxData(clientSignature, transactionData);

        uint256 numTokens;
        uint64 withdrawalBridgeId;
        uint64 depositBridgeId;
        uint256 nonce;
        address user;

        (numTokens, withdrawalBridgeId, depositBridgeId, nonce, user) = transactionData.decompose();

        require (signer == user, "Not signed by client");
        require (signer == msg.sender, "Not sent by client");
        require (withdrawalBridgeId == bridgeId_, "Incorrect network");
        require (!withdrawNonces[nonce], "Nonce already used");

        return (user, nonce, numTokens);
    }
}






interface TokenInterface {
    function mintTo(address user, uint256 amount) external;
    function burnFrom(address user, uint256 amount) external;
}

contract CiviPortBridge is CiviPortBridgeVerifier
{
    event Deposit(uint256 indexed nonce, bytes data);
    event Withdraw(uint256 indexed nonce, bytes data);

    TokenInterface private token_;

    constructor(address tokenContract, uint64 bridgeId, uint8 numSigners) CiviPortBridgeVerifier(bridgeId, numSigners)
    {
        require(tokenContract != address(0), "Bridge: Backing token not configured");
        token_ = TokenInterface(tokenContract);
    }

    function queryToken() public view returns (TokenInterface)
    {
        return token_;
    }

    function deposit(bytes memory clientSignature, bytes[] memory serverSignatures, bytes memory transactionData) public pause
    {
        address user;
        uint256 nonce;
        uint256 numTokens;
        (user, nonce, numTokens) = verifyDeposit(clientSignature, serverSignatures, transactionData);

        token_.mintTo(user, numTokens);
        depositNonces[nonce] = true;
        emit Deposit(nonce, transactionData);
    }

    function withdraw(bytes memory clientSignature, bytes memory transactionData) public pause
    {
        address user;
        uint256 nonce;
        uint256 numTokens;
        (user, nonce, numTokens) = verifyWithdraw(clientSignature, transactionData);

        token_.burnFrom(user, numTokens);
        withdrawNonces[nonce] = true;
        emit Withdraw(nonce, transactionData);
    }
}


interface WrappedTokenInterface {
    function mintTo(address user, uint256 amount) external;
    function burnFrom(address user, uint256 amount) external;
    function transferBackingTokenFrom(address user, uint256 amount) external;
    function transferBackingTokenTo(address user, uint256 amount) external;
}

contract CiviPortWrappedBridge is CiviPortBridgeVerifier, CiviPortBridge
{
    using SafeERC20 for IERC20;

    IERC20 private backingToken_;
    WrappedTokenInterface private wrappedToken_;
    
    constructor(address backingTokenContract, address wrappedTokenContract, uint64 bridgeId, uint8 numSigners)
        CiviPortBridge(wrappedTokenContract, bridgeId, numSigners)
    {
        require(backingTokenContract != address(0), "WrappedBridge: Backing token not configured");
        require(wrappedTokenContract != address(0), "WrappedBridge: Wrapped token not configured");

        backingToken_ = IERC20(backingTokenContract);
        wrappedToken_ = WrappedTokenInterface(wrappedTokenContract);
    }

    function queryBackingToken() public view returns (IERC20)
    {
        return backingToken_;
    }

    function queryWrappedToken() public view returns (WrappedTokenInterface)
    {
        return wrappedToken_;
    }

    function depositAndUnwrap(bytes memory clientSignature, bytes[] memory serverSignatures, bytes memory transactionData) public pause
    {
        address user;
        uint256 nonce;
        uint256 numTokens;
        (user, nonce, numTokens) = verifyDeposit(clientSignature, serverSignatures, transactionData);

        wrappedToken_.transferBackingTokenTo(user, numTokens);
        depositNonces[nonce] = true;
        emit Deposit(nonce, transactionData);
    }

    function wrapAndWithdraw(bytes memory clientSignature, bytes memory transactionData) public pause
    {
        address user;
        uint256 nonce;
        uint256 numTokens;
        (user, nonce, numTokens) = verifyWithdraw(clientSignature, transactionData);
        
        wrappedToken_.transferBackingTokenFrom(user, numTokens);
        withdrawNonces[nonce] = true;
        emit Withdraw(nonce, transactionData);
    }
}