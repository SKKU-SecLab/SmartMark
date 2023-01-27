



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

library Common {

    struct Distribution {
        bytes32 identifier;
        address token;
        bytes32 merkleRoot;
        bytes32 proof;
    }
}




pragma solidity 0.8.12;




interface IRewardDistributor {

    function updateRewardsMetadata(
        Common.Distribution[] calldata _distributions
    ) external;

}

contract BribeVault is AccessControl {

    using SafeERC20 for IERC20;

    struct Bribe {
        address token;
        uint256 amount;
    }

    struct Transfer {
        uint256 feeAmount;
        uint256 distributorAmountTransferred;
        uint256 distributorAmountReceived;
    }

    uint256 public constant FEE_DIVISOR = 1000000;
    uint256 public immutable FEE_MAX;
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");

    uint256 public fee; // 5000 = 0.5%
    address public feeRecipient; // Protocol treasury
    address public distributor; // RewardDistributor contract

    mapping(bytes32 => Bribe) public bribes;

    mapping(bytes32 => bytes32[]) public rewardToBribes;

    mapping(bytes32 => Transfer) public rewardTransfers;

    event GrantDepositorRole(address depositor);
    event RevokeDepositorRole(address depositor);
    event SetFee(uint256 _fee);
    event SetFeeRecipient(address _feeRecipient);
    event SetDistributor(address _distributor);
    event DepositBribe(
        bytes32 indexed bribeIdentifier,
        bytes32 indexed rewardIdentifier,
        address indexed token,
        uint256 amount,
        uint256 totalAmount,
        address briber
    );
    event TransferBribe(
        bytes32 indexed rewardIdentifier,
        address indexed token,
        uint256 feeAmount,
        uint256 distributorAmount
    );
    event EmergencyWithdrawal(
        address indexed token,
        uint256 amount,
        address admin
    );

    constructor(
        uint256 _fee,
        uint256 _feeMax,
        address _feeRecipient,
        address _distributor
    ) {
        require(_feeMax < FEE_DIVISOR / 2, "Invalid _feeMax");
        FEE_MAX = _feeMax;

        require(_fee <= FEE_MAX, "Invalid _fee");
        fee = _fee;

        require(_feeRecipient != address(0), "Invalid feeRecipient");
        feeRecipient = _feeRecipient;

        require(_distributor != address(0), "Invalid distributor");
        distributor = _distributor;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function grantDepositorRole(address depositor)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(depositor != address(0), "Invalid depositor");
        _grantRole(DEPOSITOR_ROLE, depositor);

        emit GrantDepositorRole(depositor);
    }

    function revokeDepositorRole(address depositor)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(hasRole(DEPOSITOR_ROLE, depositor), "Invalid depositor");
        _revokeRole(DEPOSITOR_ROLE, depositor);

        emit RevokeDepositorRole(depositor);
    }

    function setFee(uint256 _fee) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(_fee <= FEE_MAX, "Fee cannot be higher than max");
        fee = _fee;

        emit SetFee(_fee);
    }

    function setFeeRecipient(address _feeRecipient)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(_feeRecipient != address(0), "Invalid feeRecipient");
        feeRecipient = _feeRecipient;

        emit SetFeeRecipient(_feeRecipient);
    }

    function setDistributor(address _distributor)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(_distributor != address(0), "Invalid distributor");
        distributor = _distributor;

        emit SetDistributor(_distributor);
    }

    function getBribe(bytes32 bribeIdentifier)
        external
        view
        returns (address token, uint256 amount)
    {

        Bribe memory b = bribes[bribeIdentifier];
        return (b.token, b.amount);
    }

    function getBribeIdentifiersByRewardIdentifier(bytes32 rewardIdentifier)
        external
        view
        returns (bytes32[] memory)
    {

        return rewardToBribes[rewardIdentifier];
    }

    function depositBribeERC20(
        bytes32 bribeIdentifier,
        bytes32 rewardIdentifier,
        address token,
        uint256 amount,
        address briber
    ) external onlyRole(DEPOSITOR_ROLE) {

        require(bribeIdentifier != bytes32(0), "Invalid bribeIdentifier");
        require(rewardIdentifier != bytes32(0), "Invalid rewardIdentifier");
        require(token != address(0), "Invalid token");
        require(amount != 0, "Amount must be greater than 0");
        require(briber != address(0), "Invalid briber");

        Bribe storage b = bribes[bribeIdentifier];
        address currentToken = b.token;

        require(
            currentToken == address(0) || currentToken == token,
            "Cannot change token"
        );

        IERC20 erc20 = IERC20(token);

        uint256 balanceBeforeTransfer = erc20.balanceOf(address(this));

        erc20.safeTransferFrom(briber, address(this), amount);

        uint256 bribeAmount = erc20.balanceOf(address(this)) -
            balanceBeforeTransfer;

        b.amount += bribeAmount;

        if (currentToken == address(0)) {
            b.token = token;
            rewardToBribes[rewardIdentifier].push(bribeIdentifier);
        }

        emit DepositBribe(
            bribeIdentifier,
            rewardIdentifier,
            token,
            bribeAmount,
            b.amount,
            briber
        );
    }

    function depositBribe(
        bytes32 bribeIdentifier,
        bytes32 rewardIdentifier,
        address briber
    ) external payable onlyRole(DEPOSITOR_ROLE) {

        require(bribeIdentifier != bytes32(0), "Invalid bribeIdentifier");
        require(rewardIdentifier != bytes32(0), "Invalid rewardIdentifier");
        require(briber != address(0), "Invalid briber");
        require(msg.value != 0, "Value must be greater than 0");

        Bribe storage b = bribes[bribeIdentifier];
        address currentToken = b.token;

        require(
            currentToken == address(0) || currentToken == address(this),
            "Cannot change token"
        );

        b.amount += msg.value; // Allow bribers to increase bribe

        if (currentToken == address(0)) {
            b.token = address(this);
            rewardToBribes[rewardIdentifier].push(bribeIdentifier);
        }

        emit DepositBribe(
            bribeIdentifier,
            rewardIdentifier,
            address(this),
            msg.value,
            b.amount,
            briber
        );
    }

    function calculateTransferAmounts(bytes32 rewardIdentifier)
        private
        view
        returns (uint256 feeAmount, uint256 distributorAmount)
    {

        bytes32[] memory bribeIdentifiers = rewardToBribes[rewardIdentifier];
        uint256 totalAmount;

        for (uint256 i; i < bribeIdentifiers.length; ++i) {
            totalAmount += bribes[bribeIdentifiers[i]].amount;
        }

        feeAmount = (totalAmount * fee) / FEE_DIVISOR;
        distributorAmount = totalAmount - feeAmount;
    }

    function transferBribes(bytes32[] calldata rewardIdentifiers)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(rewardIdentifiers.length != 0, "Invalid rewardIdentifiers");

        for (uint256 i; i < rewardIdentifiers.length; ++i) {
            bytes32 rewardIdentifier = rewardIdentifiers[i];
            require(
                rewardToBribes[rewardIdentifier].length != 0,
                "Invalid rewardIdentifier"
            );

            Transfer storage r = rewardTransfers[rewardIdentifier];
            require(
                r.distributorAmountTransferred == 0,
                "Bribe has already been transferred"
            );

            address token = bribes[rewardToBribes[rewardIdentifier][0]].token;
            (
                uint256 feeAmount,
                uint256 distributorAmount
            ) = calculateTransferAmounts(rewardIdentifier);

            r.feeAmount = feeAmount;
            r.distributorAmountTransferred = distributorAmount;

            if (token == address(this)) {
                (bool sentFeeRecipient, ) = feeRecipient.call{value: feeAmount}(
                    ""
                );
                require(
                    sentFeeRecipient,
                    "Failed to transfer to fee recipient"
                );

                (bool sentDistributor, ) = distributor.call{
                    value: distributorAmount
                }("");
                require(sentDistributor, "Failed to transfer to distributor");

                r.distributorAmountReceived = distributorAmount;
            } else {
                IERC20 t = IERC20(token);

                uint256 distributorBalance = t.balanceOf(distributor);

                t.safeTransfer(feeRecipient, feeAmount);
                t.safeTransfer(distributor, distributorAmount);

                r.distributorAmountReceived =
                    t.balanceOf(distributor) -
                    distributorBalance;
            }

            emit TransferBribe(
                rewardIdentifier,
                token,
                feeAmount,
                distributorAmount
            );
        }
    }

    function emergencyWithdrawERC20(address token, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(token != address(0), "Invalid token");
        require(amount != 0, "Invalid amount");

        IERC20(token).safeTransfer(msg.sender, amount);

        emit EmergencyWithdrawal(token, amount, msg.sender);
    }

    function emergencyWithdraw(uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(amount != 0, "Invalid amount");

        (bool sentAdmin, ) = msg.sender.call{value: amount}("");
        require(sentAdmin, "Failed to withdraw");

        emit EmergencyWithdrawal(address(this), amount, msg.sender);
    }
}