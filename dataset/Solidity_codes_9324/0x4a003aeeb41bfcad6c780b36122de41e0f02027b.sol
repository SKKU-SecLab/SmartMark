
pragma solidity 0.8.4;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract IDOSale is AccessControl, Pausable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    address public owner;
    address public newOwner;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public purchasedAmounts;
    mapping(address => uint256) public claimedAmounts;
    address[] private _whitelistedUsers;
    uint256 public idoPrice;
    IERC20 public ido;
    IERC20 public purchaseToken;
    uint256 public purchaseCap;
    uint256 public totalPurchasedAmount;

    uint256 public startTime;
    uint256 public endTime;

    struct Purchase {
        address account;
        uint256 amount;
    }
    struct PermitRequest {
        uint256 nonce;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event IdoPriceChanged(uint256 idoPrice);
    event PurchaseCapChanged(uint256 purchaseCap);
    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event Deposited(address indexed sender, uint256 amount);
    event Purchased(address indexed sender, uint256 amount);
    event Claimed(address indexed sender, uint256 amount);
    event Swept(address indexed sender, uint256 amount);

    constructor(
        IERC20 _ido,
        IERC20 _purchaseToken,
        uint256 _idoPrice,
        uint256 _purchaseCap,
        uint256 _startTime,
        uint256 _endTime
    ) {
        require(address(_ido) != address(0), "IDOSale: IDO_ADDRESS_INVALID");
        require(address(_purchaseToken) != address(0), "IDOSale: PURCHASE_TOKEN_ADDRESS_INVALID");
        require(_idoPrice > 0, "IDOSale: TOKEN_PRICE_INVALID");
        require(_purchaseCap > 0, "IDOSale: PURCHASE_CAP_INVALID");
        require(block.timestamp <= _startTime && _startTime < _endTime, "IDOSale: TIMESTAMP_INVALID");

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());

        ido = _ido;
        purchaseToken = _purchaseToken;
        owner = _msgSender();
        idoPrice = _idoPrice;
        purchaseCap = _purchaseCap;
        startTime = _startTime;
        endTime = _endTime;

        emit OwnershipTransferred(address(0), _msgSender());
    }


    function setIdoPrice(uint256 _idoPrice) external onlyOwner {

        idoPrice = _idoPrice;

        emit IdoPriceChanged(_idoPrice);
    }

    function setPurchaseCap(uint256 _purchaseCap) external onlyOwner {

        purchaseCap = _purchaseCap;

        emit PurchaseCapChanged(_purchaseCap);
    }


    modifier onlyOwner() {

        require(owner == _msgSender(), "IDOSale: CALLER_NO_OWNER");
        _;
    }

    function renounceOwnership() external onlyOwner {

        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "IDOSale: INVALID_ADDRESS");
        require(_newOwner != owner, "IDOSale: OWNERSHIP_SELF_TRANSFER");
        newOwner = _newOwner;
    }

    function acceptOwnership() external {

        require(_msgSender() == newOwner, "IDOSale: CALLER_NO_NEW_OWNER");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }


    modifier onlyOperator() {

        require(hasRole(OPERATOR_ROLE, _msgSender()), "IDOSale: CALLER_NO_OPERATOR_ROLE");
        _;
    }

    function addOperator(address account) public onlyOwner {

        require(!hasRole(OPERATOR_ROLE, account), "IDOSale: ALREADY_OERATOR_ROLE");
        grantRole(OPERATOR_ROLE, account);
    }

    function removeOperator(address account) public onlyOwner {

        require(hasRole(OPERATOR_ROLE, account), "IDOSale: NO_OPERATOR_ROLE");
        revokeRole(OPERATOR_ROLE, account);
    }

    function checkOperator(address account) public view returns (bool) {

        return hasRole(OPERATOR_ROLE, account);
    }


    function pause() external onlyOperator {

        super._pause();
    }

    function unpause() external onlyOperator {

        super._unpause();
    }



    function whitelistedUsers() external view returns (address[] memory) {

        address[] memory __whitelistedUsers = new address[](_whitelistedUsers.length);
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            if (!whitelist[_whitelistedUsers[i]]) {
                continue;
            }
            __whitelistedUsers[i] = _whitelistedUsers[i];
        }

        return __whitelistedUsers;
    }

    function addWhitelist(address[] memory accounts) external onlyOperator whenNotPaused {

        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (!whitelist[accounts[i]]) {
                whitelist[accounts[i]] = true;
                _whitelistedUsers.push(accounts[i]);

                emit WhitelistAdded(accounts[i]);
            }
        }
    }

    function removeWhitelist(address[] memory accounts) external onlyOperator whenNotPaused {

        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (whitelist[accounts[i]]) {
                whitelist[accounts[i]] = false;

                emit WhitelistRemoved(accounts[i]);
            }
        }
    }


    function purchaseHistory() external view returns (Purchase[] memory) {

        Purchase[] memory purchases = new Purchase[](_whitelistedUsers.length);
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            purchases[i].account = _whitelistedUsers[i];
            purchases[i].amount = purchasedAmounts[_whitelistedUsers[i]];
        }

        return purchases;
    }

    function depositTokens(uint256 amount) external onlyOperator whenNotPaused {

        require(amount > 0, "IDOSale: DEPOSIT_AMOUNT_INVALID");
        ido.safeTransferFrom(_msgSender(), address(this), amount);

        emit Deposited(_msgSender(), amount);
    }

    function permitAndDepositTokens(
        uint256 amount,
        PermitRequest calldata permitOptions
    ) external onlyOperator whenNotPaused {

        require(amount > 0, "IDOSale: DEPOSIT_AMOUNT_INVALID");

        IERC20Permit(address(ido)).permit(_msgSender(), address(this), amount, permitOptions.deadline, permitOptions.v, permitOptions.r, permitOptions.s);
        ido.safeTransferFrom(_msgSender(), address(this), amount);

        emit Deposited(_msgSender(), amount);
    }

    function purchase(uint256 amount) external nonReentrant whenNotPaused {

        require(startTime <= block.timestamp, "IDOSale: SALE_NOT_STARTED");
        require(block.timestamp < endTime, "IDOSale: SALE_ALREADY_ENDED");
        require(amount > 0, "IDOSale: PURCHASE_AMOUNT_INVALID");
        require(whitelist[_msgSender()], "IDOSale: CALLER_NO_WHITELIST");
        require(purchasedAmounts[_msgSender()] + amount <= purchaseCap, "IDOSale: PURCHASE_CAP_EXCEEDED");
        uint256 idoBalance = ido.balanceOf(address(this));
        require(totalPurchasedAmount + amount <= idoBalance, "IDOSale: INSUFFICIENT_SELL_BALANCE");
        uint256 purchaseTokenAmount = amount * idoPrice / (10 ** 18);
        require(purchaseTokenAmount <= purchaseToken.balanceOf(_msgSender()), "IDOSale: INSUFFICIENT_FUNDS");

        purchasedAmounts[_msgSender()] += amount;
        totalPurchasedAmount += amount;
        purchaseToken.safeTransferFrom(_msgSender(), address(this), purchaseTokenAmount);

        emit Purchased(_msgSender(), amount);
    }

    function permitAndPurchase(
        uint256 amount,
        PermitRequest calldata permitOptions
    ) external nonReentrant whenNotPaused {

        require(startTime <= block.timestamp, "IDOSale: SALE_NOT_STARTED");
        require(block.timestamp < endTime, "IDOSale: SALE_ALREADY_ENDED");
        require(amount > 0, "IDOSale: PURCHASE_AMOUNT_INVALID");
        require(whitelist[_msgSender()], "IDOSale: CALLER_NO_WHITELIST");
        require(purchasedAmounts[_msgSender()] + amount <= purchaseCap, "IDOSale: PURCHASE_CAP_EXCEEDED");
        uint256 idoBalance = ido.balanceOf(address(this));
        require(totalPurchasedAmount + amount <= idoBalance, "IDOSale: INSUFFICIENT_SELL_BALANCE");
        uint256 purchaseTokenAmount = amount * idoPrice / (10 ** 18);
        require(purchaseTokenAmount <= purchaseToken.balanceOf(_msgSender()), "IDOSale: INSUFFICIENT_FUNDS");

        purchasedAmounts[_msgSender()] += amount;
        totalPurchasedAmount += amount;
        IERC20Permit(address(purchaseToken)).permit(_msgSender(), address(this), amount, permitOptions.deadline, permitOptions.v, permitOptions.r, permitOptions.s);
        purchaseToken.safeTransferFrom(_msgSender(), address(this), purchaseTokenAmount);

        emit Purchased(_msgSender(), amount);
    }


    function claim(uint256 amount) external nonReentrant whenNotPaused {

        require(endTime <= block.timestamp, "IDOSale: SALE_NOT_ENDED");
        require(amount > 0, "IDOSale: CLAIM_AMOUNT_INVALID");
        require(claimedAmounts[_msgSender()] + amount <= purchasedAmounts[_msgSender()], "IDOSale: CLAIM_AMOUNT_EXCEEDED");

        claimedAmounts[_msgSender()] += amount;
        ido.safeTransfer(_msgSender(), amount);

        emit Claimed(_msgSender(), amount);
    }

    function sweep(address to) external onlyOwner {

        require(to != address(0), "IDOSale: ADDRESS_INVALID");
        require(endTime <= block.timestamp, "IDOSale: SALE_NOT_ENDED");
        uint256 bal = purchaseToken.balanceOf(address(this));
        purchaseToken.transfer(to, bal);

        emit Swept(to, bal);
    }
}