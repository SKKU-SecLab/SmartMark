


pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;

library Counters {

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




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}




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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




pragma solidity ^0.8.0;

contract RoleControl is AccessControl {

  bytes32 public constant STAFF = keccak256("STAFF"); // hash a USER as a role constant

  constructor (address root) {
    _setupRole(DEFAULT_ADMIN_ROLE, root); // The creator of the contract is the default admin

    _setRoleAdmin(STAFF, DEFAULT_ADMIN_ROLE);
  }

  function isAdmin(address account) public virtual view returns(bool)
  {

    return hasRole(DEFAULT_ADMIN_ROLE, account);
  }

  modifier onlyAdmin() {

    require(isAdmin(msg.sender), "Restricted to admins.");
      _;
  }

  function addAdmin(address account) public virtual onlyAdmin
  {

    grantRole(DEFAULT_ADMIN_ROLE, account);
  }

  function isStaff(address account) public virtual view returns(bool)
  {

    return hasRole(STAFF, account);
  }

  modifier onlyAdminAndStaff() {

    require(isAdmin(msg.sender) || isStaff(msg.sender), "Restricted to Staff and Admins.");
      _;
  }

  function addStaff(address account) public virtual onlyAdmin
  {

    grantRole(STAFF, account);
  }
}


pragma solidity ^0.8.0;

contract NBEthDistributor is RoleControl
{

    constructor() RoleControl(msg.sender) {}

    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter private NodeID;
    Counters.Counter private WinnerID;


    struct NodeToken {
        uint256 nodeId_;
        string tokenName_;
        uint256 rewardAmount_;
        address contractAddress_;
    }

    struct Winner {
        uint256 Id_;
        uint256 NodeTokenId_;
        address walletAddress_;
    }

    NodeToken nodeToken;
    Winner winner;

    mapping(uint256 => NodeToken) public NodeTokens;
    mapping(uint256 => Winner) public WinnerAddresses;
    mapping(uint256 => address[]) private AddressByNodeTokenId;
    mapping(uint256 => uint256) public WinnerCountByNodeTokenId;

    function addToNodeToken (string memory tokenName, uint256 rewardAmount, address contractAddress) public onlyAdminAndStaff {
        NodeID.increment();
        nodeToken = NodeToken(NodeID.current(), tokenName, rewardAmount, contractAddress);
        NodeTokens[NodeID.current()] = nodeToken;
    }

    function UpdateNodeToken (uint256 NodeTokenId_, string memory tokenName, uint256 rewardAmount, address contractAddress) public onlyAdminAndStaff {
        nodeToken = NodeToken(NodeTokenId_, tokenName, rewardAmount, contractAddress);
        NodeTokens[NodeTokenId_] = nodeToken;
    }

    function addToWinnerAddress (uint256 nodeTokenId, address[] memory newWinners) public onlyAdminAndStaff {
        require(nodeTokenId <= NodeID.current(), "Node Token Id doesn't exist");

        for (uint256 i = 0; i < newWinners.length; i++) {
            WinnerID.increment();
            winner = Winner(WinnerID.current(), nodeTokenId, newWinners[i]);
            WinnerAddresses[WinnerID.current()] = winner;
        }
        AddressByNodeTokenId[nodeTokenId] = newWinners;
        WinnerCountByNodeTokenId[nodeTokenId] = newWinners.length;
    }

    function withdraw(uint256 nodeId) public payable onlyAdmin {

        require(nodeId <= NodeID.current(), "Node Token Id doesn't exist");

        address tokenAddress = NodeTokens[nodeId].contractAddress_;
        IERC20 token = IERC20(tokenAddress);

        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function sendRewards (uint256 nodeId) public onlyAdminAndStaff {
        require(nodeId <= NodeID.current(), "Node Token Id doesn't exist");

        address tokenAddress = NodeTokens[nodeId].contractAddress_;
        uint256 rewardAmount = NodeTokens[nodeId].rewardAmount_;
        IERC20 token = IERC20(tokenAddress);

        require(token.balanceOf(address(this)) > 0 , "Token balance must be greater than 0");

        for (uint256 i = 0; i < WinnerCountByNodeTokenId[nodeId]; i++) {
            sendReward(tokenAddress, AddressByNodeTokenId[nodeId][i], rewardAmount);
        }
    }

    function clearWinners () public onlyAdminAndStaff {
        require(WinnerID.current() > 0, 'No winners to delete');
        for (uint256 i = 1; i <= NodeID.current(); i++) {
            delete WinnerAddresses[i];
        }
        WinnerID.reset();
    }

    function sendReward (address _token, address _toaddress, uint256 amount) internal {
        IERC20(_token).transfer(_toaddress, amount);
    }

    function getBalanceOfCoin (uint256 nodeId) public view returns (uint256) {
        require(nodeId <= NodeID.current(), "Node Token Id doesn't exist");
        address tokenAddress = NodeTokens[nodeId].contractAddress_;
        return IERC20(tokenAddress).balanceOf(address(this));
    }
}