
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
}//MIT
pragma solidity 0.8.6;

interface IVoters {

  function snapshot() external returns (uint);

  function totalSupplyAt(uint snapshotId) external view returns (uint);

  function votesAt(address account, uint snapshotId) external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function balanceOfAt(address account, uint snapshotId) external view returns (uint);

  function donate(uint amount) external;

}// GPL-3.0
pragma solidity 0.8.6;

interface IUniswapV2Pair {

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}// MIT
pragma solidity ^0.8.0;

interface IERC677Receiver {

  function onTokenTransfer(address _sender, uint _value, bytes calldata _data) external;

}//MIT
pragma solidity 0.8.6;



contract Voters is IVoters, IERC677Receiver, AccessControl { 

    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint lastFeeGrowth;
        uint lockedToken;
        uint lockedSsLpValue;
        uint lockedSsLpAmount;
        uint lockedTcLpValue;
        uint lockedTcLpAmount;
        address delegate;
    }
    struct Snapshots {
        uint[] ids;
        uint[] values;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Snapshot(uint id);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    string public constant name = "Thorstarter Voting Token";
    string public constant symbol = "vXRUNE";
    uint8 public constant decimals = 18;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER");
    bytes32 public constant SNAPSHOTTER_ROLE = keccak256("SNAPSHOTTER");
    IERC20 public token;
    IERC20 public sushiLpToken;
    uint public lastFeeGrowth;
    uint public totalSupply;
    mapping(address => UserInfo) private _userInfos;
    uint public currentSnapshotId;
    Snapshots private _totalSupplySnapshots;
    mapping(address => Snapshots) private _balancesSnapshots;
    mapping(address => uint) private _votes;
    mapping(address => Snapshots) private _votesSnapshots;
    mapping(address => bool) public historicalTcLps;
    address[] private _historicalTcLpsList;
    mapping(address => uint) public lastLockBlock;

    constructor(address _owner, address _token, address _sushiLpToken) {
        _setRoleAdmin(KEEPER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(SNAPSHOTTER_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _owner);
        _setupRole(KEEPER_ROLE, _owner);
        _setupRole(SNAPSHOTTER_ROLE, _owner);
        token = IERC20(_token);
        sushiLpToken = IERC20(_sushiLpToken);
        currentSnapshotId = 1;
    }

    function userInfo(address user) external view returns (uint, uint, uint, uint, uint, uint, address) {

      UserInfo storage userInfo = _userInfos[user];
      return (
        userInfo.lastFeeGrowth,
        userInfo.lockedToken,
        userInfo.lockedSsLpValue,
        userInfo.lockedSsLpAmount,
        userInfo.lockedTcLpValue,
        userInfo.lockedTcLpAmount,
        userInfo.delegate
      );
    }

    function balanceOf(address user) override public view returns (uint) {

        UserInfo storage userInfo = _userInfos[user];
        return _userInfoTotal(userInfo);
    }

    function balanceOfAt(address user, uint snapshotId) override external view returns (uint) {

        (bool snapshotted, uint value) = _valueAt(_balancesSnapshots[user], snapshotId);
        return snapshotted ? value : balanceOf(user);
    }

    function votes(address user) public view returns (uint) {

        return _votes[user];
    }

    function votesAt(address user, uint snapshotId) override external view returns (uint) {

        (bool snapshotted, uint value) = _valueAt(_votesSnapshots[user], snapshotId);
        return snapshotted ? value : votes(user);
    }

    function totalSupplyAt(uint snapshotId) override external view returns (uint) {

        (bool snapshotted, uint value) = _valueAt(_totalSupplySnapshots, snapshotId);
        return snapshotted ? value : totalSupply;
    }

    function approve(address spender, uint amount) external returns (bool) {

        revert("not implemented");
    }

    function transfer(address to, uint amount) external returns (bool) {

        revert("not implemented");
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {

        revert("not implemented");
    }

    function snapshot() override external onlyRole(SNAPSHOTTER_ROLE) returns (uint) {

        currentSnapshotId += 1;
        emit Snapshot(currentSnapshotId);
        return currentSnapshotId;
    }

    function _valueAt(Snapshots storage snapshots, uint snapshotId) private view returns (bool, uint) {

        if (snapshots.ids.length == 0) {
            return (false, 0);
        }
        uint lower = 0;
        uint upper = snapshots.ids.length;
        while (lower < upper) {
            uint mid = (lower & upper) + (lower ^ upper) / 2;
            if (snapshots.ids[mid] > snapshotId) {
                upper = mid;
            } else {
                lower = mid + 1;
            }
        }

        uint index = lower;
        if (lower > 0 && snapshots.ids[lower - 1] == snapshotId) {
          index = lower -1;
        }

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateSnapshot(Snapshots storage snapshots, uint value) private {

        uint currentId = currentSnapshotId;
        uint lastSnapshotId = 0;
        if (snapshots.ids.length > 0) {
            lastSnapshotId = snapshots.ids[snapshots.ids.length - 1];
        }
        if (lastSnapshotId < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(value);
        }
    }

    function delegate(address delegatee) external {

        require(delegatee != address(0), "zero address provided");
        UserInfo storage userInfo = _userInfos[msg.sender];
        address currentDelegate = userInfo.delegate;
        userInfo.delegate = delegatee;

        _updateSnapshot(_votesSnapshots[currentDelegate], votes(currentDelegate));
        _updateSnapshot(_votesSnapshots[delegatee], votes(delegatee));
        uint amount = balanceOf(msg.sender);
        _votes[currentDelegate] -= amount;
        _votes[delegatee] += amount;

        emit DelegateChanged(msg.sender, currentDelegate, delegatee);
    }

    function _lock(address user, uint amount) private {

        require(amount > 0, "!zero");
        UserInfo storage userInfo = _userInfo(user);

        lastLockBlock[user] = block.number;

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[user], balanceOf(user));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        totalSupply += amount;
        userInfo.lockedToken += amount;
        _votes[userInfo.delegate] += amount;
        emit Transfer(address(0), user, amount);
    }

    function lock(uint amount) external {

        _transferFrom(token, msg.sender, amount);
        _lock(msg.sender, amount);
    }

    function onTokenTransfer(address user, uint amount, bytes calldata _data) external override {

        require(msg.sender == address(token), "onTokenTransfer: not xrune");
        _lock(user, amount);
    }

    function unlock(uint amount) external {

        require(block.number > lastLockBlock[msg.sender], "no lock-unlock in same tx");

        UserInfo storage userInfo = _userInfo(msg.sender);
        require(amount <= userInfo.lockedToken, "locked balance too low");

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[msg.sender], balanceOf(msg.sender));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        totalSupply -= amount;
        userInfo.lockedToken -= amount;
        _votes[userInfo.delegate] -= amount;
        emit Transfer(msg.sender, address(0), amount);

        if (amount > 0) {
            token.safeTransfer(msg.sender, amount);
        }
    }

    function lockSslp(uint lpAmount) external {

        UserInfo storage userInfo = _userInfo(msg.sender);
        require(lpAmount > 0, "!zero");
        _transferFrom(sushiLpToken, msg.sender, lpAmount);

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[msg.sender], balanceOf(msg.sender));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        uint previousValue = userInfo.lockedSsLpValue;
        totalSupply -= userInfo.lockedSsLpValue;
        _votes[userInfo.delegate] -= userInfo.lockedSsLpValue;

        userInfo.lockedSsLpAmount += lpAmount;

        uint lpTokenSupply = sushiLpToken.totalSupply();
        uint lpTokenReserve = token.balanceOf(address(sushiLpToken));
        require(lpTokenSupply > 0, "lp token supply can not be zero");
        uint amount = (2 * userInfo.lockedSsLpAmount * lpTokenReserve) / lpTokenSupply;
        totalSupply += amount; // Increment as we decremented
        _votes[userInfo.delegate] += amount; // Increment as we decremented
        userInfo.lockedSsLpValue = amount; // Set a we didn't ajust and amount is full value
        if (previousValue < userInfo.lockedSsLpValue) {
            emit Transfer(address(0), msg.sender, userInfo.lockedSsLpValue - previousValue);
        } else if (previousValue > userInfo.lockedSsLpValue) {
            emit Transfer(msg.sender, address(0), previousValue - userInfo.lockedSsLpValue);
        }
    }

    function unlockSslp(uint lpAmount) external {

        UserInfo storage userInfo = _userInfo(msg.sender);
        require(lpAmount > 0, "amount can't be 0");
        require(lpAmount <= userInfo.lockedSsLpAmount, "locked balance too low");

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[msg.sender], balanceOf(msg.sender));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        uint amount = lpAmount * userInfo.lockedSsLpValue / userInfo.lockedSsLpAmount;
        totalSupply -= amount;
        userInfo.lockedSsLpValue -= amount;
        userInfo.lockedSsLpAmount -= lpAmount;
        _votes[userInfo.delegate] -= amount;
        emit Transfer(msg.sender, address(0), amount);

        sushiLpToken.safeTransfer(msg.sender, lpAmount);
    }

    function updateTclp(address[] calldata users, uint[] calldata amounts, uint[] calldata values) external onlyRole(KEEPER_ROLE) {

        require(users.length == amounts.length && users.length == values.length, "length");
        for (uint i = 0; i < users.length; i++) {
            address user = users[i];
            UserInfo storage userInfo = _userInfo(user);
            _updateSnapshot(_totalSupplySnapshots, totalSupply);
            _updateSnapshot(_balancesSnapshots[user], balanceOf(user));
            _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

            uint previousValue = userInfo.lockedTcLpValue;
            totalSupply = totalSupply - previousValue + values[i];
            _votes[userInfo.delegate] = _votes[userInfo.delegate] - previousValue + values[i];
            userInfo.lockedTcLpValue = values[i];
            userInfo.lockedTcLpAmount = amounts[i];
            if (previousValue < values[i]) {
                emit Transfer(address(0), user, values[i] - previousValue);
            } else if (previousValue > values[i]) {
                emit Transfer(user, address(0), previousValue - values[i]);
            }

            if (!historicalTcLps[user]) {
              historicalTcLps[user] = true;
              _historicalTcLpsList.push(user);
            }
        }
    }

    function historicalTcLpsList(uint page, uint pageSize) external view returns (address[] memory) {

      address[] memory list = new address[](pageSize);
      for (uint i = page * pageSize; i < (page + 1) * pageSize && i < _historicalTcLpsList.length; i++) {
        list[i-(page*pageSize)] = _historicalTcLpsList[i];
      }
      return list;
    }

    function donate(uint amount) override external {

        _transferFrom(token, msg.sender, amount);
        lastFeeGrowth += (amount * 1e12) / totalSupply;
    }

    function _userInfo(address user) private returns (UserInfo storage) {

        require(user != address(0), "zero address provided");
        UserInfo storage userInfo = _userInfos[user];
        if (userInfo.delegate == address(0)) {
            userInfo.delegate = user;
        }
        if (userInfo.lastFeeGrowth == 0 && lastFeeGrowth != 0) {
            userInfo.lastFeeGrowth = lastFeeGrowth;
        } else {
            uint fees = (_userInfoTotal(userInfo) * (lastFeeGrowth - userInfo.lastFeeGrowth)) / 1e12;
            if (fees > 0) {
                _updateSnapshot(_totalSupplySnapshots, totalSupply);
                _updateSnapshot(_balancesSnapshots[user], balanceOf(user));
                _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

                totalSupply += fees;
                userInfo.lockedToken += fees;
                userInfo.lastFeeGrowth = lastFeeGrowth;
                _votes[userInfo.delegate] += fees;
                emit Transfer(address(0), user, fees);
            }
        }
        return userInfo;
    }

    function _userInfoTotal(UserInfo storage userInfo) private view returns (uint) {

        return userInfo.lockedToken + userInfo.lockedSsLpValue + userInfo.lockedTcLpValue;
    }

    function _transferFrom(IERC20 token, address from, uint amount) private {

        uint balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(from, address(this), amount);
        uint balanceAfter = token.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amount, "_transferFrom: balance change does not match amount");
    }
}