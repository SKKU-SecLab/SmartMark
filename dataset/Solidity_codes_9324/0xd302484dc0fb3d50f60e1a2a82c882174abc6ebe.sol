
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// GPL-3.0

pragma solidity ^0.8.7;

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// GPL-3.0

pragma solidity ^0.8.7;



abstract contract AccessControl is Context, IAccessControl {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
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

    function grantRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) external override {
        require(account == _msgSender(), "71");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// GPL-3.0

pragma solidity ^0.8.7;

interface IFeeDistributor {

    function burn(address token) external;

}// GPL-3.0

pragma solidity ^0.8.7;

struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
}

interface IUniswapV3Router {

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

}

interface IUniswapV2Router {

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 swapAmount,
        uint256 minExpected,
        address[] calldata path,
        address receiver,
        uint256 swapDeadline
    ) external;

}// GPL-3.0

pragma solidity ^0.8.7;



abstract contract BaseSurplusConverter is AccessControl, Pausable, IFeeDistributor {
    using SafeERC20 for IERC20;

    event FeeDistributorUpdated(address indexed newFeeDistributor, address indexed oldFeeDistributor);
    event Recovered(address indexed tokenAddress, address indexed to, uint256 amount);

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    IFeeDistributor public feeDistributor;

    IERC20 public immutable rewardToken;

    constructor(
        address _rewardToken,
        address _feeDistributor,
        address whitelisted,
        address governor,
        address[] memory guardians
    ) {
        require(_feeDistributor != address(0) && whitelisted != address(0) && governor != address(0), "0");
        feeDistributor = IFeeDistributor(_feeDistributor);
        rewardToken = IERC20(_rewardToken);
        IERC20(_rewardToken).safeApprove(_feeDistributor, type(uint256).max);
        require(guardians.length > 0, "101");
        for (uint256 i = 0; i < guardians.length; i++) {
            require(guardians[i] != address(0), "0");
            _setupRole(GUARDIAN_ROLE, guardians[i]);
        }
        _setupRole(WHITELISTED_ROLE, whitelisted);
        _setupRole(GOVERNOR_ROLE, governor);
        _setRoleAdmin(GOVERNOR_ROLE, GOVERNOR_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, GOVERNOR_ROLE);
        _setRoleAdmin(WHITELISTED_ROLE, GUARDIAN_ROLE);
        _pause();
    }

    function setFeeDistributor(address _feeDistributor) external onlyRole(GOVERNOR_ROLE) {
        require(_feeDistributor != address(0), "0");
        address oldFeeDistributor = address(feeDistributor);
        feeDistributor = IFeeDistributor(_feeDistributor);
        IERC20 rewardTokenMem = rewardToken;
        rewardTokenMem.safeApprove(_feeDistributor, type(uint256).max);
        rewardTokenMem.safeApprove(oldFeeDistributor, 0);
        emit FeeDistributorUpdated(_feeDistributor, oldFeeDistributor);
    }

    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyRole(GOVERNOR_ROLE) {
        IERC20(tokenAddress).safeTransfer(to, amount);
        emit Recovered(tokenAddress, to, amount);
    }

    function pause() external onlyRole(GUARDIAN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(GUARDIAN_ROLE) {
        _unpause();
    }

    function buyback(
        address token,
        uint256 amount,
        uint256 minAmount,
        bool transfer
    ) external virtual;

    function burn(address token) external override whenNotPaused {
        IERC20(token).safeTransferFrom(msg.sender, address(this), IERC20(token).balanceOf(msg.sender));
    }

    function sendToFeeDistributor() external whenNotPaused {
        feeDistributor.burn(address(rewardToken));
    }
}// GPL-3.0

pragma solidity ^0.8.7;


contract SurplusConverterUniV3 is BaseSurplusConverter {

    using SafeERC20 for IERC20;

    event PathUpdated(address indexed token, bytes newPath, bytes oldPath);
    event TokenRevoked(address indexed token);

    IUniswapV3Router public immutable uniswapV3Router;

    mapping(address => bytes) public uniswapPaths;

    constructor(
        address _rewardToken,
        address _feeDistributor,
        address _uniswapV3Router,
        address whitelisted,
        address governor,
        address[] memory guardians
    ) BaseSurplusConverter(_rewardToken, _feeDistributor, whitelisted, governor, guardians) {
        require(_uniswapV3Router != address(0), "0");
        uniswapV3Router = IUniswapV3Router(_uniswapV3Router);
    }

    function addToken(
        address token,
        address[] memory pathAddresses,
        uint24[] memory pathFees
    ) external onlyRole(GUARDIAN_ROLE) {

        require(token != address(0), "0");
        require(pathAddresses.length >= 2, "5");
        require(pathAddresses.length == (pathFees.length + 1), "104");
        require(pathAddresses[0] == token && pathAddresses[pathAddresses.length - 1] == address(rewardToken), "111");

        bytes memory path;
        for (uint256 i = 0; i < pathFees.length; i++) {
            require(pathAddresses[i] != address(0) && pathAddresses[i + 1] != address(0), "0");
            path = abi.encodePacked(path, pathAddresses[i], pathFees[i]);
        }
        path = abi.encodePacked(path, pathAddresses[pathFees.length]);

        bytes memory oldPath = uniswapPaths[token];
        if (oldPath.length == 0) {
            IERC20(token).safeApprove(address(uniswapV3Router), type(uint256).max);
        }
        uniswapPaths[token] = path;
        emit PathUpdated(token, path, oldPath);
    }

    function revokeToken(address token) external onlyRole(GUARDIAN_ROLE) {

        delete uniswapPaths[token];
        IERC20(token).safeApprove(address(uniswapV3Router), 0);
        emit TokenRevoked(token);
    }

    function buyback(
        address token,
        uint256 amount,
        uint256 minAmount,
        bool transfer
    ) external override whenNotPaused onlyRole(WHITELISTED_ROLE) {

        bytes memory path = uniswapPaths[token];
        require(path.length != 0, "111");
        uniswapV3Router.exactInput(ExactInputParams(path, address(this), block.timestamp, amount, minAmount));
        if (transfer) {
            feeDistributor.burn(address(rewardToken));
        }
    }
}