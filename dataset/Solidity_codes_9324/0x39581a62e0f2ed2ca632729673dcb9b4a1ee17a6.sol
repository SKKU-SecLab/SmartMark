
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
}// MIT

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


abstract contract Multicall {
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IERC20Extended {

    function decimals() external view returns (uint8);

}

contract StakingContractEth is AccessControl, Multicall {


    using SafeERC20 for IERC20;
    
    IERC20 public shardToken;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    
    address public treasury;
    uint256 public maxDebtModifier; // maximum lending period
    uint256 public reductionRate; // generation modifier for non stablecoin asset

    mapping(IERC20 => uint256) public totalTokensDeposited;
    mapping(address => mapping(IERC20 => uint256)) public deposited;
    mapping(address => mapping(IERC20 => uint256)) public debt;
    mapping(address => mapping(IERC20 => uint256)) public surplus;
    mapping(address => mapping(IERC20 => uint256)) public lastDebtInteraction;
    mapping(IERC20 => bool) public whitelistedTokens; // tokens && aTokens supported by contract

    modifier sync(IERC20 toSync) {

        require(whitelistedTokens[toSync] == true, "token not supported by protocol");

        uint8 decimalsUtoken = IERC20Extended(address(toSync)).decimals();

        if (toSync.balanceOf(address(this)) > totalTokensDeposited[toSync]) {
            uint256 _surplus = toSync.balanceOf(address(this)) - totalTokensDeposited[toSync];
            deposited[treasury][toSync] += _surplus;
            emit status(toSync,_surplus, totalTokensDeposited[toSync]);
            totalTokensDeposited[toSync] += _surplus;
        }
        _;        
    }
    
    modifier updateDebt(IERC20 toSync, address toUpdate) {

        require(whitelistedTokens[toSync] == true, "token not supported by protocol");
        
        if (deposited[toUpdate][toSync] > 0) {
            uint256 reduction = (deposited[toUpdate][toSync] * (block.timestamp - lastDebtInteraction[toUpdate][toSync])) * reductionRate / 86400;
            if (reduction <= debt[toUpdate][toSync]) {
                debt[toUpdate][toSync] -= reduction;
            } 
            else {
                surplus[toUpdate][toSync] += reduction - debt[toUpdate][toSync];
                debt[toUpdate][toSync] = 0;
            }
        }
        lastDebtInteraction[toUpdate][toSync] = block.timestamp;
        _;
    }

    constructor(IERC20 _shardToken, uint256 _mdm) {
        shardToken = _shardToken;
        _setupRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        maxDebtModifier = _mdm;
        reductionRate = 1;
        treasury = address(0xa7C212DA5881eA88c9472F83dB94049f95B5472F);
    }

    function deposit(IERC20 toDeposit, uint256 amount) external sync(toDeposit) updateDebt(toDeposit, _msgSender()) {

        toDeposit.safeTransferFrom(_msgSender(), address(this), amount);
        
        deposited[_msgSender()][toDeposit] += amount;
        totalTokensDeposited[toDeposit] += amount;
        emit inflow(_msgSender(),amount, toDeposit);
    }

    function withdraw(IERC20 toWithdraw, uint256 amount) external updateDebt(toWithdraw, _msgSender()) {

        IERC20 bookkeeping = toWithdraw;
        require(deposited[_msgSender()][bookkeeping] >= amount, "insufficient respawn.finance balance");
        require(debt[_msgSender()][bookkeeping] <= normalisedDebt(toWithdraw, deposited[_msgSender()][bookkeeping] - amount), "remaining collateral yield would be insufficient to repay loan");
        totalTokensDeposited[bookkeeping] -= amount;
        deposited[_msgSender()][bookkeeping] -= amount;
        toWithdraw.safeTransfer(_msgSender(), amount);
        emit withdrawals(_msgSender(),amount, toWithdraw);
    }

    function lockPartlyAndReceive(IERC20 tokenToLock, uint256 shardsToCredit) external updateDebt(tokenToLock, _msgSender()) {

        uint256 max = normalisedDebt(tokenToLock, deposited[_msgSender()][tokenToLock]);
        require(shardsToCredit + debt[_msgSender()][tokenToLock] <= (max) + surplus[_msgSender()][tokenToLock], "insufficient collateral");
        if (surplus[_msgSender()][tokenToLock] == 0) {
            debt[_msgSender()][tokenToLock] += shardsToCredit;
        }
        else {
            if (shardsToCredit >= surplus[_msgSender()][tokenToLock]) {
                debt[_msgSender()][tokenToLock] = shardsToCredit - surplus[_msgSender()][tokenToLock];
                surplus[_msgSender()][tokenToLock] = 0;
            }
            else {
                surplus[_msgSender()][tokenToLock] -= shardsToCredit;
            }
        }
        shardToken.safeTransfer(_msgSender(), shardsToCredit);
        emit minted(_msgSender(),shardsToCredit,tokenToLock);
    }

    function lockFullyAndReceive(IERC20 tokenToLock) external updateDebt(tokenToLock, _msgSender()) {


        uint256 max = normalisedDebt(tokenToLock, deposited[_msgSender()][tokenToLock]);
        require(max + surplus[_msgSender()][tokenToLock] > debt[_msgSender()][tokenToLock], "insufficient collateral");
        uint256 amount = (max - debt[_msgSender()][tokenToLock]) + surplus[_msgSender()][tokenToLock];
        surplus[_msgSender()][tokenToLock] = 0;
        debt[_msgSender()][tokenToLock] = max;
        shardToken.safeTransfer(_msgSender(), amount);
        emit minted(_msgSender(),amount,tokenToLock);
    }

    function harvestSurplus(IERC20 lockedToken) external updateDebt(lockedToken, _msgSender()) {

        require(surplus[_msgSender()][lockedToken] > 0, "no rewards left");
        uint256 _surplus = surplus[_msgSender()][lockedToken];
        surplus[_msgSender()][lockedToken] = 0;
        shardToken.safeTransfer(_msgSender(), _surplus);
        emit minted(_msgSender(),_surplus,lockedToken);
    }

    function repayPartlyAndUnlock(IERC20 tokenToUnlock, uint256 amount) external updateDebt(tokenToUnlock, _msgSender()) {

        shardToken.safeTransferFrom(_msgSender(), address(this), amount);
        if (amount >= debt[_msgSender()][tokenToUnlock]) {
            surplus[_msgSender()][tokenToUnlock] += amount - debt[_msgSender()][tokenToUnlock];
            debt[_msgSender()][tokenToUnlock] = 0;
        }
        else {
            debt[_msgSender()][tokenToUnlock] -= amount;
        }
        emit repayment(_msgSender(),amount,tokenToUnlock);
    }

    function repayFullyAndUnlock(IERC20 tokenToUnlock) external updateDebt(tokenToUnlock, _msgSender()) {

        require(debt[_msgSender()][tokenToUnlock] > 0, "debt should be > 0");
        shardToken.safeTransferFrom(_msgSender(), address(this), debt[_msgSender()][tokenToUnlock]);
        emit repayment(_msgSender(),debt[_msgSender()][tokenToUnlock],tokenToUnlock);
        debt[_msgSender()][tokenToUnlock] = 0;
    }

    function normalisedDebt(IERC20 tokenToNormalise, uint256 amountToNormalise) internal view returns(uint256) {

        IERC20Extended _iERC20Extended = IERC20Extended(address(tokenToNormalise));
        uint256 decimals = _iERC20Extended.decimals();
        return (amountToNormalise * 10**18 * maxDebtModifier) / 10**decimals;
    }

    function alterMaxDebtModifier(uint256 rate) onlyRole(ADMIN_ROLE) external {

        maxDebtModifier = rate;
    }

    function alterReductionRate(uint256 rate) onlyRole(ADMIN_ROLE) external {

        reductionRate = rate;
    }

    function whitelistToken(IERC20 rebasingToken) onlyRole(ADMIN_ROLE) external {

        whitelistedTokens[rebasingToken] = true;
    }

    function getCDPinfo(address user , IERC20 coin) public view returns(
        uint256 _maxPossCredit, 
        uint256 _deposited, 
        uint256 _outstandingCredit, 
        uint256 _surplus){

            _maxPossCredit = normalisedDebt(coin, deposited[user][coin]);
            _deposited = deposited[user][coin];
            _outstandingCredit = debt[user][coin];
            _surplus = surplus[user][coin];

          return (_maxPossCredit,_deposited,_outstandingCredit,_surplus);
        }

    event withdrawals(address indexed user , uint256 indexed amount, IERC20 indexed token);
    event inflow(address indexed user , uint256 indexed amount, IERC20 indexed token);
    event repayment(address indexed user , uint256 indexed amount, IERC20 indexed token);
    event minted(address indexed user , uint256 indexed amount, IERC20 indexed token);
    event status(IERC20 indexed token , uint256 indexed surpluss, uint256 indexed total);

}