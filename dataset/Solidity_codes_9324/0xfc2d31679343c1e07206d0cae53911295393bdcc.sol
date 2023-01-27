
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

pragma solidity ^0.8.7;


contract Treasury {

    using SafeERC20 for IERC20;

    function _takeMoneyFromSender(
        IERC20 currency,
        address sender,
        uint256 amount
    ) internal {

        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = currency.allowance(sender, address(this));
        require(allowance >= amount, "Check the token allowance");

        currency.safeTransferFrom(address(sender), address(this), amount);
    }

    function _sendMoneyToIDOOwner(
        IERC20 currency,
        address to,
        uint256 amount
    ) internal {

        currency.safeTransfer(to, amount);
    }
}// MIT

pragma solidity ^0.8.7;

interface ISharedData {

    struct Token {
        address _tokenAddress;
        uint256 _presaleRate;
    }

    struct VestingInfo {
        uint256 _time;
        uint256 _percent;
    }

    struct VestingInfoParams {
        VestingInfo[] _vestingInfo;
    }

    struct IDOParams {
        uint256 _minimumContributionLimit;
        uint256 _maximumContributionLimit;
        uint256 _softCap;
        uint256 _hardCap;
        uint256 _startDepositTime;
        uint256 _endDepositTime;
        uint256 _presaleRate;
        address _tokenAddress;
        address _admin;
        address _manager;
        Token[] _tokens;
        address[] _allowance;
        VestingInfo[] _vestingInfo;
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
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

pragma solidity ^0.8.7;




contract IDO is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    Treasury,
    ISharedData
{

    struct UserInfo {
        uint256 deposit;
        uint256 tokenInfoId;
        uint256 claimedAmount;
        uint256 refundedAmount;
    }

    struct TokenInfo {
        IERC20 token;
        uint256 presaleRate;
        uint256 amount;
        bool isActive;
    }

    address[] public users;
    TokenInfo[] public tokenInfo;
    VestingInfo[] public vestingInfo;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    address public tokenAddress;
    uint256 public minimumContributionLimit;
    uint256 public maximumContributionLimit;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public totalCap;
    uint256 public startDepositTime;
    uint256 public endDepositTime;
    uint256 public depositCount;
    address public admin;
    address public manager;
    bool public isMainTokenAllowed;

    mapping(address => UserInfo) public allowanceToUserInfo;

    event Claim(address indexed user, uint256 amount);
    event Refund(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event DepositToken(
        address indexed currency,
        address indexed user,
        uint256 amount
    );

    event Debug(string key, uint256 value);

    function initialize(IDOParams memory params) public virtual initializer {

        __Pausable_init();
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, params._admin);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, params._manager);

        admin = params._admin;
        manager = params._manager;

        tokenAddress = params._tokenAddress;
        minimumContributionLimit = params._minimumContributionLimit;
        maximumContributionLimit = params._maximumContributionLimit;
        softCap = params._softCap;
        hardCap = params._hardCap;

        isMainTokenAllowed = params._presaleRate == 0 ? false : true;

        startDepositTime = params._startDepositTime;
        endDepositTime = params._endDepositTime;

        tokenAddress = params._tokenAddress;
        depositCount = 0;

        for (uint256 index = 0; index < params._vestingInfo.length; index++) {
            vestingInfo.push(
                VestingInfo(
                    params._vestingInfo[index]._time,
                    params._vestingInfo[index]._percent
                )
            );
        }

        if (isMainTokenAllowed) {
            tokenInfo.push(
                TokenInfo({
                    presaleRate: params._presaleRate,
                    token: IERC20(address(0)),
                    amount: 0,
                    isActive: true
                })
            );
        } else {
            uint256 tokensLength = params._tokens.length;

            for (uint256 index = 0; index < tokensLength; index++) {
                addToken(
                    IERC20(params._tokens[index]._tokenAddress),
                    params._tokens[index]._presaleRate
                );
            }
        }
    }

    function userInfoList() public view returns (address[] memory) {

        return users;
    }

    function tokenInfoList() public view returns (TokenInfo[] memory) {

        return tokenInfo;
    }

    function isClaimAllowed() public view returns (bool) {

        return block.timestamp > vestingInfo[0]._time;
    }

    function isClaimOrRefund() public view returns (uint256 result) {

        if (block.timestamp > vestingInfo[0]._time) {
            result = 1;
            if (isMainTokenAllowed) {
                uint256 idoBalance = address(this).balance;
                if (idoBalance < softCap) {
                    result = 2;
                }
            } else {
                if (totalCap < softCap) {
                    result = 2;
                }
            }
        }
    }

    function vestingLength() public view returns (uint256) {

        return vestingInfo.length;
    }

    function deposit() public payable virtual whenNotPaused {

        require(isMainTokenAllowed);
        _deposirRequire(msg.sender, msg.value);

        allowanceToUserInfo[msg.sender].deposit = msg.value;

        depositCount++;
        users.push(msg.sender);
        totalCap = totalCap + msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function depositToken(IERC20 currency, uint256 amount)
        public
        whenNotPaused
    {

        require(!isMainTokenAllowed);

        _deposirRequire(msg.sender, amount);
        uint256 tokenInfoId = getTokenInfoId(currency);

        uint256 amountToProcess = amount;

        if (currency == IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)) {
            amountToProcess = amount / 1000000000000;
        }

        _takeMoneyFromSender(currency, msg.sender, amountToProcess);
        allowanceToUserInfo[msg.sender].deposit = amount;
        allowanceToUserInfo[msg.sender].tokenInfoId = tokenInfoId;
        depositCount++;

        users.push(msg.sender);

        addTokenInfoAmount(tokenInfoId, amount);

        emit DepositToken(msg.sender, msg.sender, amount);
    }

    function claim() public virtual whenNotPaused {

        if (isMainTokenAllowed) {
            uint256 idoBalance = address(this).balance;
            require(idoBalance >= softCap);
        } else {
            require(totalCap >= softCap);
        }

        require(block.timestamp > vestingInfo[0]._time, "Claim not started");
        require(
            allowanceToUserInfo[msg.sender].deposit > 0,
            "You don't have an allocation to Claim"
        );

        TokenInfo storage _tokenInfo = tokenInfo[
            allowanceToUserInfo[msg.sender].tokenInfoId
        ];

        uint256 allowedPercentage = 0;

        for (uint256 index = 0; index < vestingInfo.length; index++) {
            if (block.timestamp > vestingInfo[index]._time) {
                allowedPercentage += vestingInfo[index]._percent;
            }
        }

        uint256 claimAmount = (_tokenInfo.presaleRate *
            allowanceToUserInfo[msg.sender].deposit) / (1 ether);

        require(
            claimAmount > allowanceToUserInfo[msg.sender].claimedAmount,
            "Clamed all allocation"
        );

        uint256 calculatedClaimAmount = (claimAmount * allowedPercentage) /
            (1 ether) /
            100;

        calculatedClaimAmount -= allowanceToUserInfo[msg.sender].claimedAmount;

        require(calculatedClaimAmount > 0, "Zero transfer");

        uint256 amountToProcess = calculatedClaimAmount;

        if (
            IERC20(tokenAddress) ==
            IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)
        ) {
            amountToProcess = calculatedClaimAmount * 1000000000000;
        }

        IERC20(tokenAddress).transfer(msg.sender, amountToProcess);

        allowanceToUserInfo[msg.sender].claimedAmount += calculatedClaimAmount;
        emit Claim(msg.sender, calculatedClaimAmount);
    }

    function refund() public virtual whenNotPaused {

        require(block.timestamp > endDepositTime, "Claim not started");
        require(
            allowanceToUserInfo[msg.sender].refundedAmount == 0,
            "You have already claimed"
        );
        require(
            allowanceToUserInfo[msg.sender].deposit > 0,
            "You don't have an allocation to Claim"
        );
        uint256 amount = 0;
        if (isMainTokenAllowed) {
            uint256 idoBalance = address(this).balance;
            require(idoBalance <= softCap);
            amount = allowanceToUserInfo[msg.sender].deposit;

            payable(msg.sender).transfer(amount);
        } else {
            require(totalCap <= softCap);
            amount = allowanceToUserInfo[msg.sender].deposit;
            IERC20 token = tokenInfo[
                allowanceToUserInfo[msg.sender].tokenInfoId
            ].token;
            token.transfer(msg.sender, amount);
        }

        allowanceToUserInfo[msg.sender].refundedAmount = amount;
        emit Refund(msg.sender, amount);
    }

    function transferBalance(uint256 tokenId)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {

        require(block.timestamp > endDepositTime, "IDO in progress");

        if (isMainTokenAllowed) {
            uint256 idoBalance = address(this).balance;
            require(idoBalance >= softCap);
            payable(msg.sender).transfer(idoBalance);
        } else {
            uint256 amountToProcess = tokenInfo[tokenId].amount;

            if (
                tokenInfo[tokenId].token ==
                IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)
            ) {
                amountToProcess = tokenInfo[tokenId].amount / 1000000000000;
            }
            _sendMoneyToIDOOwner(
                tokenInfo[tokenId].token,
                msg.sender,
                amountToProcess
            );
        }
    }

    function updateTokenAddress(address _address)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        tokenAddress = _address;
    }

    function updateStartDepositTime(uint256 _time)
        public
        onlyRole(MANAGER_ROLE)
    {

        require(_time < endDepositTime, "Should be less than endDepositTime");
        startDepositTime = _time;
    }

    function updateEndDepositTime(uint256 _time) public onlyRole(MANAGER_ROLE) {

        require(
            _time > startDepositTime,
            "Should be more than startDepositTime"
        );

        endDepositTime = _time;
    }

    function updateStartClaimTime(VestingInfoParams memory params)
        public
        onlyRole(MANAGER_ROLE)
    {

        require(params._vestingInfo.length > 0, "vesting Info needed");

        require(
            params._vestingInfo[0]._time > endDepositTime,
            "Start Claim Time should be more than End Deposit Time"
        );

        for (
            uint256 index = 0;
            index < params._vestingInfo.length - 1;
            index++
        ) {
            require(
                params._vestingInfo[index + 1]._time >=
                    params._vestingInfo[index]._time,
                "Each vesting time should be equal or more then previous"
            );
        }

        for (uint256 index = 0; index < params._vestingInfo.length; index++) {
            delete vestingInfo[index];
            vestingInfo[index] = VestingInfo(
                params._vestingInfo[index]._time,
                params._vestingInfo[index]._percent
            );
        }
    }

    function updateSoftCap(uint256 _softCap) public onlyRole(MANAGER_ROLE) {

        softCap = _softCap;
    }

    function updateHardCap(uint256 _hardCap) public onlyRole(MANAGER_ROLE) {

        hardCap = _hardCap;
    }

    function updateMinimumContributionLimit(uint256 _limit)
        public
        onlyRole(MANAGER_ROLE)
    {

        minimumContributionLimit = _limit;
    }

    function updateMaximumContributionLimit(uint256 _limit)
        public
        onlyRole(MANAGER_ROLE)
    {

        maximumContributionLimit = _limit;
    }

    function addToken(IERC20 _token, uint256 _price)
        public
        onlyRole(MANAGER_ROLE)
    {

        require(!isMainTokenAllowed);

        tokenInfo.push(
            TokenInfo({
                token: _token,
                presaleRate: _price,
                amount: 0,
                isActive: true
            })
        );
    }

    function multiAddToken(IERC20[] memory _tokens, uint256[] memory _prices)
        public
        onlyRole(MANAGER_ROLE)
    {

        require(!isMainTokenAllowed);

        require(
            _tokens.length == _prices.length,
            "_tokens and _prices should has the same length"
        );
        uint256 length = _tokens.length;
        for (uint256 id = 0; id < length; ++id) {
            addToken(_tokens[id], _prices[id]);
        }
    }

    function transferToken(address to) public onlyRole(MANAGER_ROLE) {

        uint256 idoBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(to, idoBalance);
    }

    function deactivateToken(uint256 id) public {

        tokenInfo[id].isActive = false;
    }

    function activateToken(uint256 id) public {

        tokenInfo[id].isActive = true;
    }

    function pause() public onlyRole(MANAGER_ROLE) {

        _pause();
    }

    function unpause() public onlyRole(MANAGER_ROLE) {

        _unpause();
    }

    function getTokenInfoId(IERC20 _token) private view returns (uint256) {

        uint256 length = tokenInfo.length;
        uint256 id = 0;
        for (id; id < length; ++id) {
            if (_token == tokenInfo[id].token) {
                break;
            }
        }

        return id;
    }

    function addTokenInfoAmount(uint256 _tokenId, uint256 _amount) private {

        tokenInfo[_tokenId].amount = tokenInfo[_tokenId].amount + _amount;
        totalCap = totalCap + _amount;
    }

    function _deposirRequire(address sender, uint256 amount) private view {

        require(block.timestamp > startDepositTime, "IDO not started");
        require(block.timestamp < endDepositTime, "IDO canceled");
        require(
            allowanceToUserInfo[sender].deposit == 0,
            "You have already made a deposit"
        );
        uint256 tempTotalCap = totalCap + amount;
        require(tempTotalCap <= hardCap, "The totalCap exceeds the HardCap");

        require(
            amount >= minimumContributionLimit,
            "Value is less than min allowed"
        );
        require(
            amount <= maximumContributionLimit,
            "Value is more than max allowed"
        );
        require(totalCap <= hardCap, "HardCap is filled");
    }
}// MIT

pragma solidity ^0.8.7;


contract IDOAllowance is IDO {

    uint256 public allowanceCount;
    address[] public allowanceArray;
    mapping(address => bool) public allowances;
    mapping(address => uint256) indexOfAllowances;

    function initialize(IDOParams memory params) public override {

        allowanceArray = params._allowance;

        allowanceCount = allowanceArray.length;
        require(
            (params._hardCap / allowanceCount) >=
                params._maximumContributionLimit
        );
        for (uint256 i = 0; i < allowanceCount; i++) {
            indexOfAllowances[allowanceArray[i]] = i;
            allowances[allowanceArray[i]] = true;
        }

        super.initialize(params);
    }

    modifier onlyAllowance() {

        require(allowances[msg.sender]);
        _;
    }

    modifier whenNotStarted() {

        require(block.timestamp < startDepositTime, "IDO  started");
        _;
    }

    function allowanceList() public view returns (address[] memory) {

        return allowanceArray;
    }

    function deposit() public payable override whenNotPaused onlyAllowance {

        super.deposit();
    }

    function claim() public override whenNotPaused onlyAllowance {

        super.claim();
    }

    function refund() public override whenNotPaused onlyAllowance {

        super.refund();
    }

    function addAllowance(address _allowance)
        public
        whenNotStarted
        onlyRole(MANAGER_ROLE)
    {

        allowances[_allowance] = true;
        allowanceArray.push(_allowance);
        allowanceCount++;
        _calculateUserAllocation();
    }

    function addAllowanceList(address[] memory _allowances)
        public
        whenNotStarted
        onlyRole(MANAGER_ROLE)
    {

        for (uint256 index = 0; index < _allowances.length; index++) {
            addAllowance(_allowances[index]);
        }
    }

    function removeAllowance(address _allowance)
        public
        whenNotStarted
        onlyRole(MANAGER_ROLE)
    {

        allowances[_allowance] = false;
        allowanceCount--;

        uint256 index = indexOfAllowances[_allowance];

        if (allowanceArray.length > 1) {
            allowanceArray[index] = allowanceArray[allowanceArray.length - 1];
        }

        _calculateUserAllocation();
    }

    function _calculateUserAllocation() private {

        uint256 allocationPerUser = hardCap / allowanceCount;
        maximumContributionLimit = allocationPerUser;
        minimumContributionLimit = maximumContributionLimit <=
            minimumContributionLimit
            ? maximumContributionLimit
            : minimumContributionLimit;
    }
}