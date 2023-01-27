
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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}// BSD-3-Clause
pragma solidity >=0.8.9;



abstract contract SecureContract is AccessControl, Initializable
{
    event ContractPaused (uint height, address user);
    event ContractUnpaused (uint height, address user);
    event OwnershipTransferred(address oldOwner, address newOwner);

    bytes32 public constant _ADMIN = keccak256("_ADMIN");

    bool private paused_;
    address private owner_;

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

    constructor() {}

    function init() public initializer
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

    function queryOwner() public view returns (address)
    {
        return owner_;
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
}// BSD-3-Clause
pragma solidity >=0.8.9;


interface DexInterface {

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}// BSD-3-Clause
pragma solidity >=0.8.9;



struct Dex {
    uint256 id;
    address wrappedTokenAddress;
    address router;
    address factory;
    uint256 fee;
}

contract FundamentaTrader is SecureContract
{

    using SafeERC20 for IERC20;

    mapping(uint256 => Dex) private _dexs;

    event Initialized();

    constructor() {}

    function initialize() public initializer
    {

        SecureContract.init();
        emit Initialized();
    }

    function addDex(uint256 id, address wrappedTokenAddress, address router, address factory, uint256 fee) public isAdmin
    {

        _dexs[id] = Dex(id, wrappedTokenAddress, router, factory, fee);
    }

    function queryDex(uint256 id) public view returns (Dex memory) { return _dexs[id]; }


    function calculateFee(uint256 id, uint256 amount) public view returns (uint256) { return (amount / 10000) * _dexs[id].fee; }


    function swapExactTokensForETH(uint256 id, uint256 amountIn, uint256 amountOutMin, address[] calldata path, uint256 deadline)
        public pause returns (uint256[] memory amounts)
    {

        Dex memory dex = _dexs[id];

        uint256 fee = calculateFee(id, amountIn);
        uint256 finalAmount = amountIn - fee;

        IERC20 token = IERC20(path[0]);

        approve(token, address(this), dex.router, amountIn);

        token.safeTransferFrom(msg.sender, address(this), amountIn);

        return DexInterface(dex.router).swapExactTokensForETH(finalAmount, amountOutMin, path, msg.sender, deadline);
    }

    function swapExactETHForTokens(uint256 id, uint256 amountOutMin, address[] calldata path, uint256 deadline)
        public payable pause returns (uint256[] memory amounts)
    {

        Dex memory dex = _dexs[id];

        uint256 fee = calculateFee(id, msg.value);

        return DexInterface(dex.router).swapExactETHForTokens{ value: msg.value - fee }(amountOutMin, path, msg.sender, deadline);
    }

    function swapExactTokensForTokens(uint256 id, uint256 amountIn, uint256 amountOutMin, address[] calldata path, uint256 deadline)
        public pause returns (uint256[] memory amounts)
    {

        Dex memory dex = _dexs[id];

        uint256 fee = calculateFee(id, amountIn);

        IERC20 token = IERC20(path[0]);

        approve(token, address(this), dex.router, amountIn);

        token.safeTransferFrom(msg.sender, address(this), amountIn);

        return DexInterface(dex.router).swapExactTokensForTokens(amountIn - fee, amountOutMin, path, msg.sender, deadline);
    }

    function getAmountsOut(uint256 id, uint256 amountIn, address[] calldata path)
        public view pause returns (uint256[] memory amounts)
    {

        Dex memory dex = _dexs[id];

        uint256 fee = calculateFee(id, amountIn);
        uint256 finalAmount = amountIn - fee;

        return DexInterface(dex.router).getAmountsOut(finalAmount, path);
    }

    function approve(IERC20 token, address owner, address spender, uint256 amount) private
    {

        uint256 allowance = token.allowance(owner, spender);

        if (amount > allowance)
            token.approve(spender, type(uint256).max);
    }

    function withdrawEth(address to) public isAdmin
    {

        payable(to).transfer(address(this).balance);
    }

    function withdrawToken(address to, address token) public isAdmin
    {

        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, balance);
    }
}