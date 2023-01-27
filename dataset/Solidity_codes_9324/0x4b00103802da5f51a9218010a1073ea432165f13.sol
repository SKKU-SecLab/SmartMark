
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
}// GPL-3.0

pragma solidity ^0.8.7;


interface IAngleDistributor {

    function rewardToken() external view returns (IERC20);


    function delegateGauge() external view returns (address);

}// GPL-3.0

pragma solidity ^0.8.7;

interface IAngleMiddlemanGauge {

    function notifyReward(address gauge, uint256 amount) external;

}// GPL-3.0
pragma solidity ^0.8.7;



interface ICurveGauge {

    function deposit_reward_token(address _reward_token, uint256 _amount) external; // solhint-disable-line

}

interface IPolygonBridge {

    function depositFor(
        address user,
        address rootToken,
        bytes memory depositData
    ) external;


    function tokenToType(address) external view returns (bytes32);


    function typeToPredicate(bytes32) external view returns (address);

}

contract AngleMiddleman is AccessControl, IAngleMiddlemanGauge {

    using SafeERC20 for IERC20;

    enum RecipientType {
        Curve,
        Anyswap,
        PolygonPoS
    }

    struct Recipient {
        address recipient;
        address bridge;
        RecipientType recipientType;
    }

    IERC20 public immutable rewardToken;
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    mapping(address => Recipient) public gaugeToRecipient;

    event AddGauge(
        address indexed gauge,
        address indexed recipient,
        address indexed bridge,
        RecipientType recipientType
    );
    event RemoveGauge(address indexed gauge);
    event NotifyReward(address indexed gauge, address indexed recipient, uint256 amount);
    event Recovered(address indexed tokenAddress, address indexed to, uint256 amount);

    constructor(address[] memory guardians, IAngleDistributor distributor) {
        require(address(distributor) != address(0), "0");
        require(guardians.length > 0, "5");

        rewardToken = distributor.rewardToken();

        for (uint256 i = 0; i < guardians.length; i++) {
            require(guardians[i] != address(0), "0");
            _setupRole(GUARDIAN_ROLE, guardians[i]);
        }

        _setupRole(DISTRIBUTOR_ROLE, address(distributor));
        _setRoleAdmin(DISTRIBUTOR_ROLE, GUARDIAN_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, GUARDIAN_ROLE);
    }

    receive() external payable {}

    function addGauges(
        address[] memory gauges,
        address[] memory recipients,
        address[] memory bridges,
        RecipientType[] memory recipientType
    ) external onlyRole(GUARDIAN_ROLE) {

        require(gauges.length > 0, "5");
        require(
            gauges.length == recipients.length &&
                gauges.length == bridges.length &&
                gauges.length == recipientType.length,
            "104"
        );

        for (uint256 i = 0; i < gauges.length; i++) {
            require(gauges[i] != address(0) && recipients[i] != address(0), "0");

            if (recipientType[i] == RecipientType.Curve) {
                require(bridges[i] == address(0), "113");
            }
            if (recipientType[i] == RecipientType.PolygonPoS || recipientType[i] == RecipientType.Anyswap) {
                require(bridges[i] != address(0), "0");
            }

            Recipient storage _recipient = gaugeToRecipient[gauges[i]];
            require(_recipient.recipient == address(0), "112");

            _recipient.recipient = recipients[i];
            _recipient.recipientType = recipientType[i];
            _recipient.bridge = bridges[i];

            if (recipientType[i] == RecipientType.Curve) {
                rewardToken.safeApprove(recipients[i], type(uint256).max);
            } else if (recipientType[i] == RecipientType.PolygonPoS) {
                address spender = _getSpenderPolygon(bridges[i]);
                uint256 currentAllowance = rewardToken.allowance(address(this), spender);
                if (currentAllowance == 0) {
                    rewardToken.safeApprove(spender, type(uint256).max);
                }
            }

            emit AddGauge(gauges[i], recipients[i], bridges[i], recipientType[i]);
        }
    }

    function _getSpenderPolygon(address bridge) internal view returns (address spender) {

        bytes32 tokenType = IPolygonBridge(bridge).tokenToType(address(rewardToken));
        spender = IPolygonBridge(bridge).typeToPredicate(tokenType);
    }

    function notifyReward(address gauge, uint256 amount) external override onlyRole(DISTRIBUTOR_ROLE) {

        Recipient memory _recipient = gaugeToRecipient[gauge];
        require(_recipient.recipient != address(0), "110");

        if (_recipient.recipientType == RecipientType.Curve) {
            ICurveGauge(_recipient.recipient).deposit_reward_token(address(rewardToken), amount);
        } else if (_recipient.recipientType == RecipientType.PolygonPoS) {
            IPolygonBridge(_recipient.bridge).depositFor(
                _recipient.recipient,
                address(rewardToken),
                abi.encodePacked(amount)
            );
        } else if (_recipient.recipientType == RecipientType.Anyswap) {
            rewardToken.safeTransfer(_recipient.bridge, amount);
        }

        emit NotifyReward(gauge, _recipient.recipient, amount);
    }

    function revokeApproval(address spender) public onlyRole(GUARDIAN_ROLE) {

        rewardToken.safeApprove(spender, 0);
    }

    function changeAllowance(address spender, uint256 approvedAmount) public onlyRole(GUARDIAN_ROLE) {

        uint256 currentAllowance = rewardToken.allowance(address(this), spender);
        if (currentAllowance < approvedAmount) {
            rewardToken.safeIncreaseAllowance(spender, approvedAmount - currentAllowance);
        } else if (currentAllowance > approvedAmount) {
            rewardToken.safeDecreaseAllowance(spender, currentAllowance - approvedAmount);
        }
    }

    function removeGauge(address gauge) external onlyRole(GUARDIAN_ROLE) {

        Recipient memory _recipient = gaugeToRecipient[gauge];
        require(_recipient.recipient != address(0), "110");
        if (_recipient.recipientType == RecipientType.Curve) {
            revokeApproval(_recipient.recipient);
        } else if (_recipient.recipientType == RecipientType.PolygonPoS) {
            revokeApproval(_getSpenderPolygon(_recipient.bridge));
        }

        delete gaugeToRecipient[gauge];
        emit RemoveGauge(gauge);
    }

    function recoverERC20(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(GUARDIAN_ROLE) {

        IERC20(token).safeTransfer(to, amount);
        emit Recovered(token, to, amount);
    }

    function recoverETH(address to, uint256 amount) external onlyRole(GUARDIAN_ROLE) {

        require(payable(to).send(amount), "98");
        emit Recovered(address(0), to, amount);
    }
}