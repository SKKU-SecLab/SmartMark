
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.0;

interface IERC677Receiver {

  function onTokenTransfer(address _sender, uint _value, bytes calldata _data) external;

}//MIT
pragma solidity ^0.8.0;


contract TiersV1 is IERC677Receiver, Initializable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    struct UserInfo {
        uint256 lastFeeGrowth;
        uint256 lastDeposit;
        uint256 lastWithdraw;
        mapping(address => uint256) amounts;
    }

    uint256 private constant PRECISION = 1e8;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG");
    bool public pausedDeposit;
    bool public pausedWithdraw;
    address public dao;
    IERC20Upgradeable public rewardToken;
    IERC20Upgradeable public votersToken;
    mapping(address => uint256) public totalAmounts;
    uint256 public lastFeeGrowth;
    mapping(address => UserInfo) public userInfos;
    address[] public users;
    mapping(address => uint256) public tokenRates;
    EnumerableSetUpgradeable.AddressSet private tokens;
    mapping(address => uint256) public nftRates;
    EnumerableSetUpgradeable.AddressSet private nfts;
    uint256[50] private __gap;

    event TokenUpdated(address token, uint256 rate);
    event NftUpdated(address token, uint256 rate);
    event DepositPaused(bool paused);
    event WithdrawPaused(bool paused);
    event Donate(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event WithdrawNow(address indexed user, uint256 amount, address indexed to);

    constructor() initializer {}

    function initialize(address _owner, address _dao, address _rewardToken, address _votersToken) public initializer {

        __ReentrancyGuard_init();
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CONFIG_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _owner);
        _setupRole(CONFIG_ROLE, _owner);
        dao = _dao;
        rewardToken = IERC20Upgradeable(_rewardToken);
        votersToken = IERC20Upgradeable(_votersToken);
        lastFeeGrowth = 1;
    }

    function updateToken(address[] calldata _tokens, uint256[] calldata _rates) external onlyRole(CONFIG_ROLE) {

        require(_tokens.length == _rates.length, "tokens and rates length");
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            require(token != address(0), "token is zero");
            require(token != address(votersToken), "do not add voters to tokens");
            tokens.add(token);
            tokenRates[token] = _rates[i];
            emit TokenUpdated(token, _rates[i]);
        }
    }

    function updateNft(address _token, uint _rate) external onlyRole(CONFIG_ROLE) {

        require(_token != address(0), "token is zero");
        nfts.add(_token);
        nftRates[_token] = _rate;
        emit NftUpdated(_token, _rate);
    }

    function updateVotersToken(address _token) external onlyRole(CONFIG_ROLE) {

        require(_token != address(0), "token is zero");
        votersToken = IERC20Upgradeable(_token);
    }

    function updateVotersTokenRate(uint _rate) external onlyRole(CONFIG_ROLE) {

        tokenRates[address(votersToken)] = _rate;
    }

    function updateDao(address _dao) external onlyRole(CONFIG_ROLE) {

        require(_dao != address(0), "address is zero");
        dao = _dao;
    }

    function togglePausedDeposit() external onlyRole(CONFIG_ROLE) {

        pausedDeposit = !pausedDeposit;
        emit DepositPaused(pausedDeposit);
    }

    function togglePausedWithdraw() external onlyRole(CONFIG_ROLE) {

        pausedWithdraw = !pausedWithdraw;
        emit WithdrawPaused(pausedWithdraw);
    }

    function totalAmount() public view returns (uint256 total) {

        uint256 length = tokens.length();
        for (uint256 i = 0; i < length; i++) {
            address token = tokens.at(i);
            total += totalAmounts[token] * tokenRates[token] / PRECISION;
        }
    }

    function usersList(uint page, uint pageSize) external view returns (address[] memory) {

        address[] memory list = new address[](pageSize);
        for (uint i = page * pageSize; i < (page + 1) * pageSize && i < users.length; i++) {
            list[i-(page*pageSize)] = users[i];
        }
        return list;
    }

    function userInfoPendingFees(address user, uint256 tokensOnlyTotal) public view returns (uint256) {

        return (tokensOnlyTotal * (lastFeeGrowth - userInfos[user].lastFeeGrowth)) / PRECISION;
    }

    function userInfoAmount(address user, address token) private view returns (uint256) {

        return userInfos[user].amounts[token];
    }

    function userInfoBalance(address user, address token) private view returns (uint256) {

        return IERC20Upgradeable(token).balanceOf(user);
    }

    function userInfoAmounts(address user) external view returns (uint256, uint256, address[] memory, uint256[] memory, uint256[] memory) {

        (uint256 tokensOnlyTotal, uint256 total) = userInfoTotal(user);
        uint256 tmp = tokens.length() + 1 + nfts.length();
        address[] memory addresses = new address[](tmp);
        uint256[] memory rates = new uint256[](tmp);
        uint256[] memory amounts = new uint256[](tmp);

        {
            uint256 tokensLength = tokens.length();
            for (uint256 i = 0; i < tokensLength; i++) {
                address token = tokens.at(i);
                addresses[i] = token;
                rates[i] = tokenRates[token];
                amounts[i] = userInfoAmount(user, token);
                if (token == address(rewardToken)) {
                    amounts[i] += userInfoPendingFees(user, tokensOnlyTotal);
                }
            }
        }

        tmp = tokens.length() + 1;
        addresses[tmp - 1] = address(votersToken);
        rates[tmp - 1] = tokenRates[address(votersToken)];
        amounts[tmp - 1] = votersToken.balanceOf(user);

        {
            uint256 nftLength = nfts.length();
            for (uint256 i = 0; i < nftLength; i++) {
                address token = nfts.at(i);
                addresses[tmp + i] = token;
                rates[tmp + i] = nftRates[token];
                amounts[tmp + i] = userInfoBalance(user, token);
            }
        }

        return (tokensOnlyTotal, total, addresses, rates, amounts);
    }

    function userInfoTotal(address user) public view returns (uint256, uint256) {

        uint256 total = 0;
        uint256 tokensLength = tokens.length();
        for (uint256 i = 0; i < tokensLength; i++) {
            address token = tokens.at(i);
            total += userInfos[user].amounts[token] * tokenRates[token] / PRECISION;
        }
        uint256 tokensOnlyTotal = total;
        total += votersToken.balanceOf(user) * tokenRates[address(votersToken)] / PRECISION;
        for (uint256 i = 0; i < nfts.length(); i++) {
            address token = nfts.at(i);
            if (IERC20Upgradeable(token).balanceOf(user) > 0) {
                total += nftRates[token];
            }
        }
        return (tokensOnlyTotal, total);
    }

    function _userInfo(address user) private returns (UserInfo storage, uint256, uint256) {

        require(user != address(0), "zero address provided");
        UserInfo storage userInfo = userInfos[user];
        (uint256 tokensOnlyTotal, uint256 total) = userInfoTotal(user);
        if (userInfo.lastFeeGrowth == 0) {
            users.push(user);
        } else {
            uint fees = (tokensOnlyTotal * (lastFeeGrowth - userInfo.lastFeeGrowth)) / PRECISION;
            userInfo.amounts[address(rewardToken)] += fees;
        }
        userInfo.lastFeeGrowth = lastFeeGrowth;
        return (userInfo, tokensOnlyTotal, total);
    }

    function donate(uint256 amount) external {

        _transferFrom(rewardToken, msg.sender, amount);
        lastFeeGrowth += (amount * PRECISION) / totalAmount();
        emit Donate(msg.sender, amount);
    }

    function deposit(address token, uint256 amount) external nonReentrant {

        require(!pausedDeposit, "paused");
        require(tokenRates[token] > 0, "not a supported token");
        (UserInfo storage userInfo,,) = _userInfo(msg.sender);

        _transferFrom(IERC20Upgradeable(token), msg.sender, amount);

        totalAmounts[token] += amount;
        userInfo.amounts[token] += amount;
        userInfo.lastDeposit = block.timestamp;

        emit Deposit(msg.sender, amount);
    }

    function onTokenTransfer(address user, uint amount, bytes calldata _data) external override {

        require(!pausedDeposit, "paused");
        require(msg.sender == address(rewardToken), "onTokenTransfer: not rewardToken");
        (UserInfo storage userInfo,,) = _userInfo(user);
        totalAmounts[address(rewardToken)] += amount;
        userInfo.amounts[address(rewardToken)] += amount;
        userInfo.lastDeposit = block.timestamp;
        emit Deposit(user, amount);
    }

    function withdraw(address token, uint256 amount, address to) external nonReentrant {

        (UserInfo storage user,,) = _userInfo(msg.sender);
        require(!pausedWithdraw, "paused");
        require(block.timestamp > user.lastDeposit + 7 days, "can't withdraw before 7 days after last deposit");

        totalAmounts[token] -= amount;
        user.amounts[token] -= amount;
        user.lastWithdraw = block.timestamp;

        IERC20Upgradeable(token).safeTransfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
    }

    function withdrawNow(address token, uint256 amount, address to) external nonReentrant {

        (UserInfo storage user,,) = _userInfo(msg.sender);
        require(!pausedWithdraw, "paused");

        uint256 half = amount / 2;
        totalAmounts[token] -= amount;
        user.amounts[token] -= amount;
        user.lastWithdraw = block.timestamp;

        if (token == address(rewardToken)) {
            lastFeeGrowth += (half * PRECISION) / totalAmount();
            emit Donate(msg.sender, half);
        } else {
            IERC20Upgradeable(token).safeTransfer(dao, half);
        }

        IERC20Upgradeable(token).safeTransfer(to, amount - half);

        emit WithdrawNow(msg.sender, amount, to);
    }

    function migrateRewards(uint256 amount) external onlyRole(ADMIN_ROLE) {

        rewardToken.safeTransfer(msg.sender, amount);
    }

    function _transferFrom(IERC20Upgradeable token, address from, uint256 amount) private {

        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(from, address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amount, "_transferFrom: balance change does not match amount");
    }
}