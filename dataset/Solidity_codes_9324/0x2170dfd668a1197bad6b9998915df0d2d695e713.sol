



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}



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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

}



pragma solidity ^0.8.0;

interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}



pragma solidity ^0.8.0;

library Strings {
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



pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



pragma solidity ^0.8.0;




abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

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



pragma solidity ^0.8.7;


contract WhitelistRole is Context, AccessControl {
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event WhitelistRevoked(address indexed account);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        grantRole(WHITELIST_ROLE, _msgSender());
        emit WhitelistAdded(_msgSender());
    }


    modifier onlyWhitelist() {
        require(
            hasRole(WHITELIST_ROLE, _msgSender()),
            "WhitelistRole: Caller is not a whitelist role"
        );
        _;
    }

    function isWhitelist(address account) public view returns (bool) {
        return hasRole(WHITELIST_ROLE, account);
    }

    function addWhitelist(address account) public {
        grantRole(WHITELIST_ROLE, account);
        emit WhitelistAdded(account);
    }

    function renounceWhitelist() public onlyWhitelist{
        renounceRole(WHITELIST_ROLE, _msgSender());
        emit WhitelistRemoved(_msgSender());
    }


    function revokeWhitelist(address account_) public onlyWhitelist{
        revokeRole(WHITELIST_ROLE, account_);
        emit WhitelistRevoked(account_);
    }
}



pragma solidity ^0.8.7;


contract MutiSender is Ownable, WhitelistRole {
    address _dev;
    address _soneAddr;
    uint256 _batchTxFee;
    uint256 _freeCost;

    mapping(address => bool) private _whiteList;

    event BatchETHSent(address from, uint256 value, uint256 total);
    event BatchTokenSent(address token, uint256 value, uint256 total);

    constructor(address dev_, address soneAddr_) {
        _dev = dev_;
        _soneAddr = soneAddr_;
        _batchTxFee = 0.02 ether;
        _freeCost = 1 ether;
    }

    modifier checkLength(uint256 length) {
        require(length <= 255, "MutiSender: address list is too long");
        _;
    }

    function registerFreeWhitelist() public payable {
        require(msg.value >= _freeCost);
        (bool sent,) = _dev.call{value: msg.value}("");
        require(sent, "MutiSender: failed to send Ether");
        addWhitelist(msg.sender);
    }

    function addFreeWhitelist(address[] memory whiteList_) public onlyOwner {
        for (uint256 i = 0; i < whiteList_.length; i++) {
            addWhitelist(whiteList_[i]);
        }
    }

    function removeFreeWhitelist(address[] memory whiteList_) public onlyOwner {
        for (uint256 i = 0; i < whiteList_.length; i++) {
            revokeWhitelist(whiteList_[i]);
        }
    }

    function setFreeCost(uint256 fee_) public onlyOwner {
        _freeCost = fee_;
    }

    function setBatchFee(uint256 fee_) public onlyOwner {
        _batchTxFee = fee_;
    }

    function batchSendEthSameValue(address[] memory to_, uint256 value_)
        public
        payable
        checkLength(to_.length)
    {
        uint256 sentAmount = to_.length * value_;
        uint256 remainingValue = msg.value;

        bool isFree = isWhitelist(msg.sender);
        if (isFree) {
            require(
                remainingValue >= sentAmount,
                "MutiSender: ether value is not enough for total amount"
            );
        } else {
            require(
                remainingValue >= sentAmount + _batchTxFee,
                "MutiSender: ether value is not enough for total amount + batch transaction fee"
            );
        }

        for (uint8 i = 0; i < to_.length; i++) {
            remainingValue = remainingValue - value_;
            (bool sent,) = to_[i].call{value: value_}("");
            require(sent, "MutiSender: failed to send Ether");
        }

        if (remainingValue > 0) {
            (bool sent,) = _dev.call{value: remainingValue}("");
            require(sent, "MutiSender: failed to send Ether");
        }

        emit BatchETHSent(msg.sender, msg.value, sentAmount);
    }

    function batchSendEthDiffValue(
        address[] memory to_,
        uint256[] memory value_
    ) public payable checkLength(to_.length) {
        require(
            to_.length == value_.length,
            "MutiSender: number of addresses is difference to number of values"
        );

        uint256 sentAmount = 0;
        uint256 remainingValue = msg.value;

        bool isFree = isWhitelist(msg.sender);
        if (isFree) {
            require(
                remainingValue >= sentAmount,
                "MutiSender: ether value is not enough for total amount"
            );
        } else {
            require(
                remainingValue >= sentAmount + _batchTxFee,
                "MutiSender: ether value is not enough for total amount + batch transaction fee"
            );
        }

        for (uint8 i = 0; i < to_.length; i++) {
            require(
                remainingValue >= value_[i],
                "MutiSender: ether value is not enough for total amount"
            );
            remainingValue = remainingValue - value_[i];
            sentAmount = sentAmount + value_[i];
            (bool sent,) = to_[i].call{value: value_[i]}("");
            require(sent, "MutiSender: failed to send Ether");
        }

        if (!isFree) {
            require(
                remainingValue >= _batchTxFee,
                "MutiSender: ether value is not enough for total amount + batch transaction fee"
            );
        }
        if (remainingValue > 0) {
            (bool sent,) = _dev.call{value: remainingValue}("");
            require(sent, "MutiSender: failed to send Ether");
        }

        emit BatchETHSent(msg.sender, msg.value, sentAmount);
    }

    function batchSendTokenSameValue(
        address tokenAddress_,
        address[] memory to_,
        uint256 value_
    ) public payable checkLength(to_.length) {
        uint256 sendValue = msg.value;
        bool isFree = isWhitelist(msg.sender);
        if (!isFree) {
            require(
                sendValue >= _batchTxFee,
                "MutiSender: ether value is not enough for total amount + batch transaction fee"
            );
            (bool sent,) = _dev.call{value: sendValue}("");
            require(sent, "MutiSender: failed to send Ether");
        }

        address from = msg.sender;
        uint256 sentAmount = to_.length * value_;

        ERC20 token = ERC20(tokenAddress_);
        for (uint8 i = 0; i < to_.length; i++) {
            token.transferFrom(from, to_[i], value_);
        }

        emit BatchTokenSent(tokenAddress_, sendValue, sentAmount);
    }

    function batchSendTokenDiffValue(
        address tokenAddress_,
        address[] memory to_,
        uint256[] memory value_
    ) public payable checkLength(to_.length) {
        require(
            to_.length == value_.length,
            "MutiSender: number of addresses is difference to number of values"
        );

        uint256 sendValue = msg.value;
        bool isFree = isWhitelist(msg.sender);
        if (!isFree) {
            require(
                sendValue >= _batchTxFee,
                "MutiSender: ether value is not enough for total amount + batch transaction fee"
            );
            (bool sent,) = _dev.call{value: sendValue}("");
            require(sent, "MutiSender: failed to send Ether");
        }

        uint256 sentAmount = value_[0];
        ERC20 token = ERC20(tokenAddress_);

        for (uint8 i = 0; i < to_.length; i++) {
            token.transferFrom(msg.sender, to_[i], value_[i]);
        }
        emit BatchTokenSent(tokenAddress_, sendValue, sentAmount);
    }

    function dropSONE(address[] memory _to, uint256 _value) public payable {
        batchSendTokenSameValue(_soneAddr, _to, _value);
    }
}