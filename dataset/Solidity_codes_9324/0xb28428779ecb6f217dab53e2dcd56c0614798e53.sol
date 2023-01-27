
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
}//UNLICENSED
pragma solidity 0.8.9;


abstract contract AccessLevel is AccessControlUpgradeable {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    function __AccessLevel_init(address owner) initializer public {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
    }
}// MIT

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
}//UNLICENSED
pragma solidity 0.8.9;


contract Launchpad is AccessLevel {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,address verifyingContract,uint256 chainId)");
    bytes32 private constant STAKING_INFO_TYPEHASH = keccak256("StakingInfo(address owner,uint256 tickets,uint256 validity)");

    struct StakingInfo{
        address owner;
        uint256 tickets;
        uint256 validity;
    }

    event BuyTickets(uint amount, address staker);
    event ClaimedTokend(uint amount, address claimer);

    uint public launchpadId;
    uint public totalTickets;
    uint public ticketCost;
    uint public ticketToLaunchedTokenRatio;
    uint public launchedTokenAmount;
    bool public buyPeriod;
    bool public buyAndClaimTicketsPeriod;
    bool public claimingPeriod;
    bool public recoverFundsPeriod;
    address public ticketPaymentTokenAddress;
    address public launchedTokenAddress;
    address public backendAddress;
    mapping(address => uint) public ticketsBoughtPerAddress;
    
    function initialize(address owner, uint launchpadId_, uint totalTickets_, uint ticketCost_, 
        address ticketPaymentTokenAddress_, address launchedTokenAddress_, 
        uint ticketToLaunchedTokenRatio_, address backendAddress_) initializer external {

        __AccessLevel_init(owner);
        _setupRole(OPERATOR_ROLE, owner);
        launchpadId = launchpadId_;
        totalTickets = totalTickets_;
        ticketCost = ticketCost_;
        ticketPaymentTokenAddress = ticketPaymentTokenAddress_;
        launchedTokenAddress = launchedTokenAddress_;
        ticketToLaunchedTokenRatio = ticketToLaunchedTokenRatio_;
        backendAddress = backendAddress_;
    }

    function buyTickets(uint tickets_, StakingInfo calldata info_, bytes memory sig_) external {

        require(buyPeriod, "Cannot buy at this time");
        require(backendAddress == recover(hashSwap(info_), sig_), "Backend address does not match");
        require(msg.sender == info_.owner, "Only owner can buy tickets");
        require(info_.validity >= block.timestamp, "Backend signatura timed out");
        require(totalTickets - tickets_ >= 0, "Not enough tickets");
        require(ticketsBoughtPerAddress[msg.sender] + tickets_ <= info_.tickets,
         "Cannot buy more tickets than assigned");
     
        totalTickets -= tickets_;
        ticketsBoughtPerAddress[msg.sender] += tickets_;
        emit BuyTickets(tickets_, msg.sender);
        IERC20Upgradeable(ticketPaymentTokenAddress).safeTransferFrom(msg.sender, address(this), tickets_ * ticketCost);
    }

    function buyAndClaimTickets(StakingInfo calldata info_, bytes memory sig_) external {

        require(buyAndClaimTicketsPeriod, "Cannot buy at this time");
        require(backendAddress == recover(hashSwap(info_), sig_), "Backend address does not match");
        require(msg.sender == info_.owner, "Only owner can buy and claim tickets");
        require(info_.validity >= block.timestamp, "Backend signatura timed out");
        require(totalTickets - info_.tickets >= 0, "Not enough tickets");
        require(ticketsBoughtPerAddress[msg.sender] == 0, "Cannot buy more tickets than assigned");
     
        totalTickets -= info_.tickets;
        ticketsBoughtPerAddress[msg.sender] += info_.tickets;
        emit BuyTickets(info_.tickets, msg.sender);
        IERC20Upgradeable(launchedTokenAddress).safeTransfer(msg.sender, 
        ticketsBoughtPerAddress[msg.sender]*ticketToLaunchedTokenRatio);
    }

    function addRewardToken(uint amount_) external {

        launchedTokenAmount += amount_;
        IERC20Upgradeable(launchedTokenAddress).safeTransferFrom(msg.sender, address(this), amount_);
    }

    function setTicketToLaunchedTokenRatio(uint ticketToLaunchedTokenRatio_) external onlyRole(DEFAULT_ADMIN_ROLE) {

        ticketToLaunchedTokenRatio = ticketToLaunchedTokenRatio_;
    }

    function setLaunchedTokenAddress(address launchedTokenAddress_) external onlyRole(DEFAULT_ADMIN_ROLE) {

        launchedTokenAddress = launchedTokenAddress_;
    }

    function setTotalTickets(uint totalTickets_) external onlyRole(DEFAULT_ADMIN_ROLE) {

        totalTickets = totalTickets_;
    }

    function setTicketCost(uint ticketCost_) external onlyRole(DEFAULT_ADMIN_ROLE) {

        ticketCost = ticketCost_;
    }

    function startBuyPeriod(bool buyPeriod_) external onlyRole(OPERATOR_ROLE) {

        buyPeriod = buyPeriod_;
        claimingPeriod = false;
        recoverFundsPeriod = false;
        buyAndClaimTicketsPeriod = false;
    }

    function startBuyAndClaimTicketsPeriod(bool buyAndClaimTicketsPeriod_) 
    external onlyRole(OPERATOR_ROLE) {

        buyPeriod = false;
        claimingPeriod = false;
        recoverFundsPeriod = false;
        buyAndClaimTicketsPeriod = buyAndClaimTicketsPeriod_;
    }

    function startClaimingPeriod(bool claimingPeriod_) external onlyRole(OPERATOR_ROLE) {

        buyPeriod = false;
        claimingPeriod = claimingPeriod_;
        recoverFundsPeriod = false;
        buyAndClaimTicketsPeriod = false;
    }

    function setBackendAddress(address backendAddress_) external onlyRole(DEFAULT_ADMIN_ROLE) {

        backendAddress = backendAddress_;
    }

    function startRecoverFundsPeriod(bool recoverFundsPeriod_) external onlyRole(OPERATOR_ROLE) {

        buyPeriod = false;
        claimingPeriod = false;
        recoverFundsPeriod = recoverFundsPeriod_;
        buyAndClaimTicketsPeriod = false;
    }

    function claimFunds(address teamAddress_) external onlyRole(DEFAULT_ADMIN_ROLE) {

        IERC20Upgradeable(ticketPaymentTokenAddress).safeTransfer(teamAddress_, 
        IERC20Upgradeable(ticketPaymentTokenAddress).balanceOf(address(this)));
    }

    function claimRemainingTokens(address teamAddress_) public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(!buyPeriod, "Cannot claim remaining yet");
        require(!claimingPeriod, "Cannot claim remaining yet");
        require(!recoverFundsPeriod, "Cannot claim remaining yet");
        IERC20Upgradeable(launchedTokenAddress).safeTransfer(teamAddress_, 
        IERC20Upgradeable(launchedTokenAddress).balanceOf(address(this)));
    }

    function claimTokens() external {

        require(claimingPeriod, "Cannot claim tokens yet");
        require(launchedTokenAmount > 0, "Tokens not funded yet");
        require(ticketsBoughtPerAddress[msg.sender] > 0, "No tokens to claim");

        uint ticketsToClaim = ticketsBoughtPerAddress[msg.sender] * ticketToLaunchedTokenRatio;
        ticketsBoughtPerAddress[msg.sender] = 0;
        emit ClaimedTokend(ticketsToClaim, msg.sender);
        IERC20Upgradeable(launchedTokenAddress).safeTransfer(msg.sender, ticketsToClaim);
    }

    function claimFundsBack() external {

        require(recoverFundsPeriod, "Cannot claimFunds back yet");
        require(ticketsBoughtPerAddress[msg.sender] > 0, "Do not have what to claim");
        IERC20Upgradeable(ticketPaymentTokenAddress).safeTransfer(msg.sender,
        ticketsBoughtPerAddress[msg.sender] * ticketCost);
        ticketsBoughtPerAddress[msg.sender] = 0;
    }

    function hashSwap(StakingInfo calldata stakingInfo) view private returns (bytes32) {

        return keccak256(abi.encodePacked(
	        "\x19\x01",
	        keccak256(abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("VLAUNCH"),
                keccak256("1"),
                address(this),
                block.chainid
            )),
            keccak256(abi.encode(
                STAKING_INFO_TYPEHASH,
                stakingInfo.owner,
                stakingInfo.tickets,
                stakingInfo.validity
            ))
        ));
    }

    function recover(bytes32 hash, bytes memory sig) pure private returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }
}