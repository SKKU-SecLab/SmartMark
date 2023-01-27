

pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;



library FixedPoint {

    using SafeMath for uint256;

    uint256 private constant FP_SCALING_FACTOR = 10**18;

    struct Unsigned {
        uint256 rawValue;
    }

    function fromUnscaledUint(uint256 a) internal pure returns (Unsigned memory) {

        return Unsigned(a.mul(FP_SCALING_FACTOR));
    }

    function isEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledUint(b).rawValue;
    }

    function isEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledUint(b).rawValue;
    }

    function isGreaterThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledUint(b).rawValue;
    }

    function isGreaterThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue >= b.rawValue;
    }

    function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledUint(b).rawValue;
    }

    function isLessThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledUint(b).rawValue;
    }

    function isLessThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue <= b.rawValue;
    }

    function min(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.add(b.rawValue));
    }

    function add(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return add(a, fromUnscaledUint(b));
    }

    function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.sub(b.rawValue));
    }

    function sub(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return sub(a, fromUnscaledUint(b));
    }

    function sub(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return sub(fromUnscaledUint(a), b);
    }

    function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
    }

    function mul(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function mulCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 mulRaw = a.rawValue.mul(b.rawValue);
        uint256 mulFloor = mulRaw / FP_SCALING_FACTOR;
        uint256 mod = mulRaw.mod(FP_SCALING_FACTOR);
        if (mod != 0) {
            return Unsigned(mulFloor.add(1));
        } else {
            return Unsigned(mulFloor);
        }
    }

    function mulCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.div(b));
    }

    function div(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return div(fromUnscaledUint(a), b);
    }

    function divCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 aScaled = a.rawValue.mul(FP_SCALING_FACTOR);
        uint256 divFloor = aScaled.div(b.rawValue);
        uint256 mod = aScaled.mod(b.rawValue);
        if (mod != 0) {
            return Unsigned(divFloor.add(1));
        } else {
            return Unsigned(divFloor);
        }
    }

    function divCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return divCeil(a, fromUnscaledUint(b));
    }

    function pow(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory output) {

        output = fromUnscaledUint(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }
}


pragma solidity ^0.6.0;



abstract contract ExpandedIERC20 is IERC20 {
    function burn(uint256 value) external virtual;

    function mint(address to, uint256 value) external virtual returns (bool);
}


pragma solidity ^0.6.0;


interface OracleInterface {

    function requestPrice(bytes32 identifier, uint256 time) external;


    function hasPrice(bytes32 identifier, uint256 time) external view returns (bool);


    function getPrice(bytes32 identifier, uint256 time) external view returns (int256);

}


pragma solidity ^0.6.0;

pragma experimental ABIEncoderV2;


interface IdentifierWhitelistInterface {

    function addSupportedIdentifier(bytes32 identifier) external;


    function removeSupportedIdentifier(bytes32 identifier) external;


    function isIdentifierSupported(bytes32 identifier) external view returns (bool);

}


pragma solidity ^0.6.0;


interface AdministrateeInterface {

    function emergencyShutdown() external;


    function remargin() external;

}


pragma solidity ^0.6.0;


library OracleInterfaces {

    bytes32 public constant Oracle = "Oracle";
    bytes32 public constant IdentifierWhitelist = "IdentifierWhitelist";
    bytes32 public constant Store = "Store";
    bytes32 public constant FinancialContractsAdmin = "FinancialContractsAdmin";
    bytes32 public constant Registry = "Registry";
}


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


pragma solidity ^0.6.0;


library Exclusive {
    struct RoleMembership {
        address member;
    }

    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {
        return roleMembership.member == memberToCheck;
    }

    function resetMember(RoleMembership storage roleMembership, address newMember) internal {
        require(newMember != address(0x0), "Cannot set an exclusive role to 0x0");
        roleMembership.member = newMember;
    }

    function getMember(RoleMembership storage roleMembership) internal view returns (address) {
        return roleMembership.member;
    }

    function init(RoleMembership storage roleMembership, address initialMember) internal {
        resetMember(roleMembership, initialMember);
    }
}


library Shared {
    struct RoleMembership {
        mapping(address => bool) members;
    }

    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {
        return roleMembership.members[memberToCheck];
    }

    function addMember(RoleMembership storage roleMembership, address memberToAdd) internal {
        require(memberToAdd != address(0x0), "Cannot add 0x0 to a shared role");
        roleMembership.members[memberToAdd] = true;
    }

    function removeMember(RoleMembership storage roleMembership, address memberToRemove) internal {
        roleMembership.members[memberToRemove] = false;
    }

    function init(RoleMembership storage roleMembership, address[] memory initialMembers) internal {
        for (uint256 i = 0; i < initialMembers.length; i++) {
            addMember(roleMembership, initialMembers[i]);
        }
    }
}


abstract contract MultiRole {
    using Exclusive for Exclusive.RoleMembership;
    using Shared for Shared.RoleMembership;

    enum RoleType { Invalid, Exclusive, Shared }

    struct Role {
        uint256 managingRole;
        RoleType roleType;
        Exclusive.RoleMembership exclusiveRoleMembership;
        Shared.RoleMembership sharedRoleMembership;
    }

    mapping(uint256 => Role) private roles;

    event ResetExclusiveMember(uint256 indexed roleId, address indexed newMember, address indexed manager);
    event AddedSharedMember(uint256 indexed roleId, address indexed newMember, address indexed manager);
    event RemovedSharedMember(uint256 indexed roleId, address indexed oldMember, address indexed manager);

    modifier onlyRoleHolder(uint256 roleId) {
        require(holdsRole(roleId, msg.sender), "Sender does not hold required role");
        _;
    }

    modifier onlyRoleManager(uint256 roleId) {
        require(holdsRole(roles[roleId].managingRole, msg.sender), "Can only be called by a role manager");
        _;
    }

    modifier onlyExclusive(uint256 roleId) {
        require(roles[roleId].roleType == RoleType.Exclusive, "Must be called on an initialized Exclusive role");
        _;
    }

    modifier onlyShared(uint256 roleId) {
        require(roles[roleId].roleType == RoleType.Shared, "Must be called on an initialized Shared role");
        _;
    }

    function holdsRole(uint256 roleId, address memberToCheck) public view returns (bool) {
        Role storage role = roles[roleId];
        if (role.roleType == RoleType.Exclusive) {
            return role.exclusiveRoleMembership.isMember(memberToCheck);
        } else if (role.roleType == RoleType.Shared) {
            return role.sharedRoleMembership.isMember(memberToCheck);
        }
        revert("Invalid roleId");
    }

    function resetMember(uint256 roleId, address newMember) public onlyExclusive(roleId) onlyRoleManager(roleId) {
        roles[roleId].exclusiveRoleMembership.resetMember(newMember);
        emit ResetExclusiveMember(roleId, newMember, msg.sender);
    }

    function getMember(uint256 roleId) public view onlyExclusive(roleId) returns (address) {
        return roles[roleId].exclusiveRoleMembership.getMember();
    }

    function addMember(uint256 roleId, address newMember) public onlyShared(roleId) onlyRoleManager(roleId) {
        roles[roleId].sharedRoleMembership.addMember(newMember);
        emit AddedSharedMember(roleId, newMember, msg.sender);
    }

    function removeMember(uint256 roleId, address memberToRemove) public onlyShared(roleId) onlyRoleManager(roleId) {
        roles[roleId].sharedRoleMembership.removeMember(memberToRemove);
        emit RemovedSharedMember(roleId, memberToRemove, msg.sender);
    }

    function renounceMembership(uint256 roleId) public onlyShared(roleId) onlyRoleHolder(roleId) {
        roles[roleId].sharedRoleMembership.removeMember(msg.sender);
        emit RemovedSharedMember(roleId, msg.sender, msg.sender);
    }

    modifier onlyValidRole(uint256 roleId) {
        require(roles[roleId].roleType != RoleType.Invalid, "Attempted to use an invalid roleId");
        _;
    }

    modifier onlyInvalidRole(uint256 roleId) {
        require(roles[roleId].roleType == RoleType.Invalid, "Cannot use a pre-existing role");
        _;
    }

    function _createSharedRole(
        uint256 roleId,
        uint256 managingRoleId,
        address[] memory initialMembers
    ) internal onlyInvalidRole(roleId) {
        Role storage role = roles[roleId];
        role.roleType = RoleType.Shared;
        role.managingRole = managingRoleId;
        role.sharedRoleMembership.init(initialMembers);
        require(
            roles[managingRoleId].roleType != RoleType.Invalid,
            "Attempted to use an invalid role to manage a shared role"
        );
    }

    function _createExclusiveRole(
        uint256 roleId,
        uint256 managingRoleId,
        address initialMember
    ) internal onlyInvalidRole(roleId) {
        Role storage role = roles[roleId];
        role.roleType = RoleType.Exclusive;
        role.managingRole = managingRoleId;
        role.exclusiveRoleMembership.init(initialMember);
        require(
            roles[managingRoleId].roleType != RoleType.Invalid,
            "Attempted to use an invalid role to manage an exclusive role"
        );
    }
}


pragma solidity ^0.6.0;





contract ExpandedERC20 is ExpandedIERC20, ERC20, MultiRole {
    enum Roles {
        Owner,
        Minter,
        Burner
    }

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) public ERC20(_tokenName, _tokenSymbol) {
        _setupDecimals(_tokenDecimals);
        _createExclusiveRole(uint256(Roles.Owner), uint256(Roles.Owner), msg.sender);
        _createSharedRole(uint256(Roles.Minter), uint256(Roles.Owner), new address[](0));
        _createSharedRole(uint256(Roles.Burner), uint256(Roles.Owner), new address[](0));
    }

    function mint(address recipient, uint256 value)
        external
        override
        onlyRoleHolder(uint256(Roles.Minter))
        returns (bool)
    {
        _mint(recipient, value);
        return true;
    }

    function burn(uint256 value) external override onlyRoleHolder(uint256(Roles.Burner)) {
        _burn(msg.sender, value);
    }
}


pragma solidity ^0.6.0;


contract Lockable {
    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {
        _preEntranceCheck();
        _preEntranceSet();
        _;
        _postEntranceReset();
    }

    modifier nonReentrantView() {
        _preEntranceCheck();
        _;
    }

    function _preEntranceCheck() internal view {
        require(_notEntered, "ReentrancyGuard: reentrant call");
    }

    function _preEntranceSet() internal {
        _notEntered = false;
    }

    function _postEntranceReset() internal {
        _notEntered = true;
    }
}


pragma solidity ^0.6.0;





contract SyntheticToken is ExpandedERC20, Lockable {
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) public ExpandedERC20(tokenName, tokenSymbol, tokenDecimals) nonReentrant() {}

    function addMinter(address account) external nonReentrant() {
        addMember(uint256(Roles.Minter), account);
    }

    function removeMinter(address account) external nonReentrant() {
        removeMember(uint256(Roles.Minter), account);
    }

    function addBurner(address account) external nonReentrant() {
        addMember(uint256(Roles.Burner), account);
    }

    function removeBurner(address account) external nonReentrant() {
        removeMember(uint256(Roles.Burner), account);
    }

    function resetOwner(address account) external nonReentrant() {
        resetMember(uint256(Roles.Owner), account);
    }

    function isMinter(address account) public view nonReentrantView() returns (bool) {
        return holdsRole(uint256(Roles.Minter), account);
    }

    function isBurner(address account) public view nonReentrantView() returns (bool) {
        return holdsRole(uint256(Roles.Burner), account);
    }
}


pragma solidity ^0.6.0;






contract TokenFactory is Lockable {
    function createToken(
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals
    ) external nonReentrant() returns (ExpandedIERC20 newToken) {
        SyntheticToken mintableToken = new SyntheticToken(tokenName, tokenSymbol, tokenDecimals);
        mintableToken.addMinter(msg.sender);
        mintableToken.addBurner(msg.sender);
        mintableToken.resetOwner(msg.sender);
        newToken = ExpandedIERC20(address(mintableToken));
    }
}


pragma solidity ^0.6.0;


contract Timer {
    uint256 private currentTime;

    constructor() public {
        currentTime = now; // solhint-disable-line not-rely-on-time
    }

    function setCurrentTime(uint256 time) external {
        currentTime = time;
    }

    function getCurrentTime() public view returns (uint256) {
        return currentTime;
    }
}


pragma solidity ^0.6.0;



abstract contract Testable {
    address public timerAddress;

    constructor(address _timerAddress) internal {
        timerAddress = _timerAddress;
    }

    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    function setCurrentTime(uint256 time) external onlyIfTest {
        Timer(timerAddress).setCurrentTime(time);
    }

    function getCurrentTime() public view returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return now; // solhint-disable-line not-rely-on-time
        }
    }
}


pragma solidity ^0.6.0;



interface StoreInterface {
    function payOracleFees() external payable;

    function payOracleFeesErc20(address erc20Address, FixedPoint.Unsigned calldata amount) external;

    function computeRegularFee(
        uint256 startTime,
        uint256 endTime,
        FixedPoint.Unsigned calldata pfc
    ) external view returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty);

    function computeFinalFee(address currency) external view returns (FixedPoint.Unsigned memory);
}


pragma solidity ^0.6.0;


interface FinderInterface {
    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;

    function getImplementationAddress(bytes32 interfaceName) external view returns (address);
}


pragma solidity ^0.6.0;











abstract contract FeePayer is Testable, Lockable {
    using SafeMath for uint256;
    using FixedPoint for FixedPoint.Unsigned;
    using SafeERC20 for IERC20;


    IERC20 public collateralCurrency;

    FinderInterface public finder;

    uint256 private lastPaymentTime;

    FixedPoint.Unsigned public cumulativeFeeMultiplier;


    event RegularFeesPaid(uint256 indexed regularFee, uint256 indexed lateFee);
    event FinalFeesPaid(uint256 indexed amount);


    modifier fees {
        payRegularFees();
        _;
    }

    constructor(
        address _collateralAddress,
        address _finderAddress,
        address _timerAddress
    ) public Testable(_timerAddress) nonReentrant() {
        collateralCurrency = IERC20(_collateralAddress);
        finder = FinderInterface(_finderAddress);
        lastPaymentTime = getCurrentTime();
        cumulativeFeeMultiplier = FixedPoint.fromUnscaledUint(1);
    }


    function payRegularFees() public nonReentrant() returns (FixedPoint.Unsigned memory totalPaid) {
        StoreInterface store = _getStore();
        uint256 time = getCurrentTime();
        FixedPoint.Unsigned memory collateralPool = _pfc();

        if (collateralPool.isEqual(0)) {
            return totalPaid;
        }

        if (lastPaymentTime == time) {
            return totalPaid;
        }

        (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty) = store.computeRegularFee(
            lastPaymentTime,
            time,
            collateralPool
        );
        lastPaymentTime = time;

        totalPaid = regularFee.add(latePenalty);
        if (totalPaid.isEqual(0)) {
            return totalPaid;
        }
        if (totalPaid.isGreaterThan(collateralPool)) {
            FixedPoint.Unsigned memory deficit = totalPaid.sub(collateralPool);
            FixedPoint.Unsigned memory latePenaltyReduction = FixedPoint.min(latePenalty, deficit);
            latePenalty = latePenalty.sub(latePenaltyReduction);
            deficit = deficit.sub(latePenaltyReduction);
            regularFee = regularFee.sub(FixedPoint.min(regularFee, deficit));
            totalPaid = collateralPool;
        }

        emit RegularFeesPaid(regularFee.rawValue, latePenalty.rawValue);

        _adjustCumulativeFeeMultiplier(totalPaid, collateralPool);

        if (regularFee.isGreaterThan(0)) {
            collateralCurrency.safeIncreaseAllowance(address(store), regularFee.rawValue);
            store.payOracleFeesErc20(address(collateralCurrency), regularFee);
        }

        if (latePenalty.isGreaterThan(0)) {
            collateralCurrency.safeTransfer(msg.sender, latePenalty.rawValue);
        }
        return totalPaid;
    }

    function pfc() public view nonReentrantView() returns (FixedPoint.Unsigned memory) {
        return _pfc();
    }


    function _payFinalFees(address payer, FixedPoint.Unsigned memory amount) internal {
        if (amount.isEqual(0)) {
            return;
        }

        if (payer != address(this)) {
            collateralCurrency.safeTransferFrom(payer, address(this), amount.rawValue);
        } else {
            FixedPoint.Unsigned memory collateralPool = _pfc();

            require(collateralPool.isGreaterThan(amount), "Final fee is more than PfC");

            _adjustCumulativeFeeMultiplier(amount, collateralPool);
        }

        emit FinalFeesPaid(amount.rawValue);

        StoreInterface store = _getStore();
        collateralCurrency.safeIncreaseAllowance(address(store), amount.rawValue);
        store.payOracleFeesErc20(address(collateralCurrency), amount);
    }

    function _pfc() internal virtual view returns (FixedPoint.Unsigned memory);

    function _getStore() internal view returns (StoreInterface) {
        return StoreInterface(finder.getImplementationAddress(OracleInterfaces.Store));
    }

    function _computeFinalFees() internal view returns (FixedPoint.Unsigned memory finalFees) {
        StoreInterface store = _getStore();
        return store.computeFinalFee(address(collateralCurrency));
    }

    function _getFeeAdjustedCollateral(FixedPoint.Unsigned memory rawCollateral)
        internal
        view
        returns (FixedPoint.Unsigned memory collateral)
    {
        return rawCollateral.mul(cumulativeFeeMultiplier);
    }

    function _convertToRawCollateral(FixedPoint.Unsigned memory collateral)
        internal
        view
        returns (FixedPoint.Unsigned memory rawCollateral)
    {
        return collateral.div(cumulativeFeeMultiplier);
    }

    function _removeCollateral(FixedPoint.Unsigned storage rawCollateral, FixedPoint.Unsigned memory collateralToRemove)
        internal
        returns (FixedPoint.Unsigned memory removedCollateral)
    {
        FixedPoint.Unsigned memory initialBalance = _getFeeAdjustedCollateral(rawCollateral);
        FixedPoint.Unsigned memory adjustedCollateral = _convertToRawCollateral(collateralToRemove);
        rawCollateral.rawValue = rawCollateral.sub(adjustedCollateral).rawValue;
        removedCollateral = initialBalance.sub(_getFeeAdjustedCollateral(rawCollateral));
    }

    function _addCollateral(FixedPoint.Unsigned storage rawCollateral, FixedPoint.Unsigned memory collateralToAdd)
        internal
        returns (FixedPoint.Unsigned memory addedCollateral)
    {
        FixedPoint.Unsigned memory initialBalance = _getFeeAdjustedCollateral(rawCollateral);
        FixedPoint.Unsigned memory adjustedCollateral = _convertToRawCollateral(collateralToAdd);
        rawCollateral.rawValue = rawCollateral.add(adjustedCollateral).rawValue;
        addedCollateral = _getFeeAdjustedCollateral(rawCollateral).sub(initialBalance);
    }

    function _adjustCumulativeFeeMultiplier(FixedPoint.Unsigned memory amount, FixedPoint.Unsigned memory currentPfc)
        internal
    {
        FixedPoint.Unsigned memory effectiveFee = amount.divCeil(currentPfc);
        cumulativeFeeMultiplier = cumulativeFeeMultiplier.mul(FixedPoint.fromUnscaledUint(1).sub(effectiveFee));
    }
}


pragma solidity ^0.6.0;













contract PricelessPositionManager is FeePayer, AdministrateeInterface {
    using SafeMath for uint256;
    using FixedPoint for FixedPoint.Unsigned;
    using SafeERC20 for IERC20;
    using SafeERC20 for ExpandedIERC20;


    enum ContractState { Open, ExpiredPriceRequested, ExpiredPriceReceived }
    ContractState public contractState;

    struct PositionData {
        FixedPoint.Unsigned tokensOutstanding;
        uint256 withdrawalRequestPassTimestamp;
        FixedPoint.Unsigned withdrawalRequestAmount;
        FixedPoint.Unsigned rawCollateral;
        uint256 transferPositionRequestPassTimestamp;
    }

    mapping(address => PositionData) public positions;

    FixedPoint.Unsigned public totalTokensOutstanding;

    FixedPoint.Unsigned public rawTotalPositionCollateral;

    ExpandedIERC20 public tokenCurrency;

    bytes32 public priceIdentifier;
    uint256 public expirationTimestamp;
    uint256 public withdrawalLiveness;

    FixedPoint.Unsigned public minSponsorTokens;

    FixedPoint.Unsigned public expiryPrice;


    event RequestTransferPosition(address indexed oldSponsor);
    event RequestTransferPositionExecuted(address indexed oldSponsor, address indexed newSponsor);
    event RequestTransferPositionCanceled(address indexed oldSponsor);
    event Deposit(address indexed sponsor, uint256 indexed collateralAmount);
    event Withdrawal(address indexed sponsor, uint256 indexed collateralAmount);
    event RequestWithdrawal(address indexed sponsor, uint256 indexed collateralAmount);
    event RequestWithdrawalExecuted(address indexed sponsor, uint256 indexed collateralAmount);
    event RequestWithdrawalCanceled(address indexed sponsor, uint256 indexed collateralAmount);
    event PositionCreated(address indexed sponsor, uint256 indexed collateralAmount, uint256 indexed tokenAmount);
    event NewSponsor(address indexed sponsor);
    event EndedSponsorPosition(address indexed sponsor);
    event Redeem(address indexed sponsor, uint256 indexed collateralAmount, uint256 indexed tokenAmount);
    event ContractExpired(address indexed caller);
    event SettleExpiredPosition(
        address indexed caller,
        uint256 indexed collateralReturned,
        uint256 indexed tokensBurned
    );
    event EmergencyShutdown(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);


    modifier onlyPreExpiration() {
        _onlyPreExpiration();
        _;
    }

    modifier onlyPostExpiration() {
        _onlyPostExpiration();
        _;
    }

    modifier onlyCollateralizedPosition(address sponsor) {
        _onlyCollateralizedPosition(sponsor);
        _;
    }

    modifier onlyOpenState() {
        _onlyOpenState();
        _;
    }

    modifier noPendingWithdrawal(address sponsor) {
        _positionHasNoPendingWithdrawal(sponsor);
        _;
    }

    constructor(
        uint256 _expirationTimestamp,
        uint256 _withdrawalLiveness,
        address _collateralAddress,
        address _finderAddress,
        bytes32 _priceIdentifier,
        string memory _syntheticName,
        string memory _syntheticSymbol,
        address _tokenFactoryAddress,
        FixedPoint.Unsigned memory _minSponsorTokens,
        address _timerAddress
    ) public FeePayer(_collateralAddress, _finderAddress, _timerAddress) nonReentrant() {
        require(_expirationTimestamp > getCurrentTime(), "Invalid expiration in future");
        require(_getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier), "Unsupported price identifier");

        expirationTimestamp = _expirationTimestamp;
        withdrawalLiveness = _withdrawalLiveness;
        TokenFactory tf = TokenFactory(_tokenFactoryAddress);
        tokenCurrency = tf.createToken(_syntheticName, _syntheticSymbol, 18);
        minSponsorTokens = _minSponsorTokens;
        priceIdentifier = _priceIdentifier;
    }


    function requestTransferPosition() public onlyPreExpiration() nonReentrant() {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(positionData.transferPositionRequestPassTimestamp == 0, "Pending transfer");

        uint256 requestPassTime = getCurrentTime().add(withdrawalLiveness);
        require(requestPassTime < expirationTimestamp, "Request expires post-expiry");

        positionData.transferPositionRequestPassTimestamp = requestPassTime;

        emit RequestTransferPosition(msg.sender);
    }

    function transferPositionPassedRequest(address newSponsorAddress)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        nonReentrant()
    {
        require(
            _getFeeAdjustedCollateral(positions[newSponsorAddress].rawCollateral).isEqual(
                FixedPoint.fromUnscaledUint(0)
            ),
            "Sponsor already has position"
        );
        PositionData storage positionData = _getPositionData(msg.sender);
        require(
            positionData.transferPositionRequestPassTimestamp != 0 &&
                positionData.transferPositionRequestPassTimestamp <= getCurrentTime(),
            "Invalid transfer request"
        );

        positionData.transferPositionRequestPassTimestamp = 0;

        positions[newSponsorAddress] = positionData;
        delete positions[msg.sender];

        emit RequestTransferPositionExecuted(msg.sender, newSponsorAddress);
        emit NewSponsor(newSponsorAddress);
        emit EndedSponsorPosition(msg.sender);
    }

    function cancelTransferPosition() external onlyPreExpiration() nonReentrant() {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(positionData.transferPositionRequestPassTimestamp != 0, "No pending transfer");

        emit RequestTransferPositionCanceled(msg.sender);

        positionData.transferPositionRequestPassTimestamp = 0;
    }

    function depositTo(address sponsor, FixedPoint.Unsigned memory collateralAmount)
        public
        onlyPreExpiration()
        noPendingWithdrawal(sponsor)
        fees()
        nonReentrant()
    {
        require(collateralAmount.isGreaterThan(0), "Invalid collateral amount");
        PositionData storage positionData = _getPositionData(sponsor);

        _incrementCollateralBalances(positionData, collateralAmount);

        emit Deposit(sponsor, collateralAmount.rawValue);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), collateralAmount.rawValue);
    }

    function deposit(FixedPoint.Unsigned memory collateralAmount) public {
        depositTo(msg.sender, collateralAmount);
    }

    function withdraw(FixedPoint.Unsigned memory collateralAmount)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(collateralAmount.isGreaterThan(0), "Invalid collateral amount");

        amountWithdrawn = _decrementCollateralBalancesCheckGCR(positionData, collateralAmount);

        emit Withdrawal(msg.sender, amountWithdrawn.rawValue);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);
    }

    function requestWithdrawal(FixedPoint.Unsigned memory collateralAmount)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        nonReentrant()
    {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(
            collateralAmount.isGreaterThan(0) &&
                collateralAmount.isLessThanOrEqual(_getFeeAdjustedCollateral(positionData.rawCollateral)),
            "Invalid collateral amount"
        );

        uint256 requestPassTime = getCurrentTime().add(withdrawalLiveness);
        require(requestPassTime < expirationTimestamp, "Request expires post-expiry");

        positionData.withdrawalRequestPassTimestamp = requestPassTime;
        positionData.withdrawalRequestAmount = collateralAmount;

        emit RequestWithdrawal(msg.sender, collateralAmount.rawValue);
    }

    function withdrawPassedRequest()
        external
        onlyPreExpiration()
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(
            positionData.withdrawalRequestPassTimestamp != 0 &&
                positionData.withdrawalRequestPassTimestamp <= getCurrentTime(),
            "Invalid withdraw request"
        );

        FixedPoint.Unsigned memory amountToWithdraw = positionData.withdrawalRequestAmount;
        if (positionData.withdrawalRequestAmount.isGreaterThan(_getFeeAdjustedCollateral(positionData.rawCollateral))) {
            amountToWithdraw = _getFeeAdjustedCollateral(positionData.rawCollateral);
        }

        amountWithdrawn = _decrementCollateralBalances(positionData, amountToWithdraw);

        _resetWithdrawalRequest(positionData);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);

        emit RequestWithdrawalExecuted(msg.sender, amountWithdrawn.rawValue);
    }

    function cancelWithdrawal() external onlyPreExpiration() nonReentrant() {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(positionData.withdrawalRequestPassTimestamp != 0, "No pending withdrawal");

        emit RequestWithdrawalCanceled(msg.sender, positionData.withdrawalRequestAmount.rawValue);

        _resetWithdrawalRequest(positionData);
    }

    function create(FixedPoint.Unsigned memory collateralAmount, FixedPoint.Unsigned memory numTokens)
        public
        onlyPreExpiration()
        fees()
        nonReentrant()
    {
        require(_checkCollateralization(collateralAmount, numTokens), "CR below GCR");

        PositionData storage positionData = positions[msg.sender];
        require(positionData.withdrawalRequestPassTimestamp == 0, "Pending withdrawal");
        if (positionData.tokensOutstanding.isEqual(0)) {
            require(numTokens.isGreaterThanOrEqual(minSponsorTokens), "Below minimum sponsor position");
            emit NewSponsor(msg.sender);
        }

        _incrementCollateralBalances(positionData, collateralAmount);

        positionData.tokensOutstanding = positionData.tokensOutstanding.add(numTokens);

        totalTokensOutstanding = totalTokensOutstanding.add(numTokens);

        emit PositionCreated(msg.sender, collateralAmount.rawValue, numTokens.rawValue);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), collateralAmount.rawValue);
        require(tokenCurrency.mint(msg.sender, numTokens.rawValue), "Minting synthetic tokens failed");
    }

    function redeem(FixedPoint.Unsigned memory numTokens)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {
        PositionData storage positionData = _getPositionData(msg.sender);
        require(!numTokens.isGreaterThan(positionData.tokensOutstanding), "Invalid token amount");

        FixedPoint.Unsigned memory fractionRedeemed = numTokens.div(positionData.tokensOutstanding);
        FixedPoint.Unsigned memory collateralRedeemed = fractionRedeemed.mul(
            _getFeeAdjustedCollateral(positionData.rawCollateral)
        );

        if (positionData.tokensOutstanding.isEqual(numTokens)) {
            amountWithdrawn = _deleteSponsorPosition(msg.sender);
        } else {
            amountWithdrawn = _decrementCollateralBalances(positionData, collateralRedeemed);

            FixedPoint.Unsigned memory newTokenCount = positionData.tokensOutstanding.sub(numTokens);
            require(newTokenCount.isGreaterThanOrEqual(minSponsorTokens), "Below minimum sponsor position");
            positionData.tokensOutstanding = newTokenCount;

            totalTokensOutstanding = totalTokensOutstanding.sub(numTokens);
        }

        emit Redeem(msg.sender, amountWithdrawn.rawValue, numTokens.rawValue);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);
        tokenCurrency.safeTransferFrom(msg.sender, address(this), numTokens.rawValue);
        tokenCurrency.burn(numTokens.rawValue);
    }

    function settleExpired()
        external
        onlyPostExpiration()
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {
        require(contractState != ContractState.Open, "Unexpired position");

        if (contractState != ContractState.ExpiredPriceReceived) {
            expiryPrice = _getOraclePrice(expirationTimestamp);
            contractState = ContractState.ExpiredPriceReceived;
        }

        FixedPoint.Unsigned memory tokensToRedeem = FixedPoint.Unsigned(tokenCurrency.balanceOf(msg.sender));
        FixedPoint.Unsigned memory totalRedeemableCollateral = tokensToRedeem.mul(expiryPrice);

        PositionData storage positionData = positions[msg.sender];
        if (_getFeeAdjustedCollateral(positionData.rawCollateral).isGreaterThan(0)) {
            FixedPoint.Unsigned memory tokenDebtValueInCollateral = positionData.tokensOutstanding.mul(expiryPrice);
            FixedPoint.Unsigned memory positionCollateral = _getFeeAdjustedCollateral(positionData.rawCollateral);

            FixedPoint.Unsigned memory positionRedeemableCollateral = tokenDebtValueInCollateral.isLessThan(
                positionCollateral
            )
                ? positionCollateral.sub(tokenDebtValueInCollateral)
                : FixedPoint.Unsigned(0);

            totalRedeemableCollateral = totalRedeemableCollateral.add(positionRedeemableCollateral);

            delete positions[msg.sender];
            emit EndedSponsorPosition(msg.sender);
        }

        FixedPoint.Unsigned memory payout = FixedPoint.min(
            _getFeeAdjustedCollateral(rawTotalPositionCollateral),
            totalRedeemableCollateral
        );

        amountWithdrawn = _removeCollateral(rawTotalPositionCollateral, payout);
        totalTokensOutstanding = totalTokensOutstanding.sub(tokensToRedeem);

        emit SettleExpiredPosition(msg.sender, amountWithdrawn.rawValue, tokensToRedeem.rawValue);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);
        tokenCurrency.safeTransferFrom(msg.sender, address(this), tokensToRedeem.rawValue);
        tokenCurrency.burn(tokensToRedeem.rawValue);
    }


    function expire() external onlyPostExpiration() onlyOpenState() fees() nonReentrant() {
        contractState = ContractState.ExpiredPriceRequested;

        _payFinalFees(address(this), _computeFinalFees());
        _requestOraclePrice(expirationTimestamp);

        emit ContractExpired(msg.sender);
    }

    function emergencyShutdown() external override onlyPreExpiration() onlyOpenState() nonReentrant() {
        require(msg.sender == _getFinancialContractsAdminAddress(), "Caller not Governor");

        contractState = ContractState.ExpiredPriceRequested;
        uint256 oldExpirationTimestamp = expirationTimestamp;
        expirationTimestamp = getCurrentTime();
        _requestOraclePrice(expirationTimestamp);

        emit EmergencyShutdown(msg.sender, oldExpirationTimestamp, expirationTimestamp);
    }

    function remargin() external override onlyPreExpiration() nonReentrant() {
        return;
    }

    function getCollateral(address sponsor)
        external
        view
        nonReentrantView()
        returns (FixedPoint.Unsigned memory collateralAmount)
    {
        return _getFeeAdjustedCollateral(positions[sponsor].rawCollateral);
    }

    function totalPositionCollateral()
        external
        view
        nonReentrantView()
        returns (FixedPoint.Unsigned memory totalCollateral)
    {
        return _getFeeAdjustedCollateral(rawTotalPositionCollateral);
    }


    function _reduceSponsorPosition(
        address sponsor,
        FixedPoint.Unsigned memory tokensToRemove,
        FixedPoint.Unsigned memory collateralToRemove,
        FixedPoint.Unsigned memory withdrawalAmountToRemove
    ) internal {
        PositionData storage positionData = _getPositionData(sponsor);

        if (
            tokensToRemove.isEqual(positionData.tokensOutstanding) &&
            _getFeeAdjustedCollateral(positionData.rawCollateral).isEqual(collateralToRemove)
        ) {
            _deleteSponsorPosition(sponsor);
            return;
        }

        _decrementCollateralBalances(positionData, collateralToRemove);

        FixedPoint.Unsigned memory newTokenCount = positionData.tokensOutstanding.sub(tokensToRemove);
        require(newTokenCount.isGreaterThanOrEqual(minSponsorTokens), "Below minimum sponsor position");
        positionData.tokensOutstanding = newTokenCount;

        positionData.withdrawalRequestAmount = positionData.withdrawalRequestAmount.sub(withdrawalAmountToRemove);

        totalTokensOutstanding = totalTokensOutstanding.sub(tokensToRemove);
    }

    function _deleteSponsorPosition(address sponsor) internal returns (FixedPoint.Unsigned memory) {
        PositionData storage positionToLiquidate = _getPositionData(sponsor);

        FixedPoint.Unsigned memory startingGlobalCollateral = _getFeeAdjustedCollateral(rawTotalPositionCollateral);

        FixedPoint.Unsigned memory remainingRawCollateral = positionToLiquidate.rawCollateral;
        rawTotalPositionCollateral = rawTotalPositionCollateral.sub(remainingRawCollateral);
        totalTokensOutstanding = totalTokensOutstanding.sub(positionToLiquidate.tokensOutstanding);

        delete positions[sponsor];

        emit EndedSponsorPosition(sponsor);

        return startingGlobalCollateral.sub(_getFeeAdjustedCollateral(rawTotalPositionCollateral));
    }

    function _pfc() internal virtual override view returns (FixedPoint.Unsigned memory) {
        return _getFeeAdjustedCollateral(rawTotalPositionCollateral);
    }

    function _getPositionData(address sponsor)
        internal
        view
        onlyCollateralizedPosition(sponsor)
        returns (PositionData storage)
    {
        return positions[sponsor];
    }

    function _getIdentifierWhitelist() internal view returns (IdentifierWhitelistInterface) {
        return IdentifierWhitelistInterface(finder.getImplementationAddress(OracleInterfaces.IdentifierWhitelist));
    }

    function _getOracle() internal view returns (OracleInterface) {
        return OracleInterface(finder.getImplementationAddress(OracleInterfaces.Oracle));
    }

    function _getFinancialContractsAdminAddress() internal view returns (address) {
        return finder.getImplementationAddress(OracleInterfaces.FinancialContractsAdmin);
    }

    function _requestOraclePrice(uint256 requestedTime) internal {
        OracleInterface oracle = _getOracle();
        oracle.requestPrice(priceIdentifier, requestedTime);
    }

    function _getOraclePrice(uint256 requestedTime) internal view returns (FixedPoint.Unsigned memory) {
        OracleInterface oracle = _getOracle();
        require(oracle.hasPrice(priceIdentifier, requestedTime), "Unresolved oracle price");
        int256 oraclePrice = oracle.getPrice(priceIdentifier, requestedTime);

        if (oraclePrice < 0) {
            oraclePrice = 0;
        }
        return FixedPoint.Unsigned(uint256(oraclePrice));
    }

    function _resetWithdrawalRequest(PositionData storage positionData) internal {
        positionData.withdrawalRequestAmount = FixedPoint.fromUnscaledUint(0);
        positionData.withdrawalRequestPassTimestamp = 0;
    }

    function _incrementCollateralBalances(
        PositionData storage positionData,
        FixedPoint.Unsigned memory collateralAmount
    ) internal returns (FixedPoint.Unsigned memory) {
        _addCollateral(positionData.rawCollateral, collateralAmount);
        return _addCollateral(rawTotalPositionCollateral, collateralAmount);
    }

    function _decrementCollateralBalances(
        PositionData storage positionData,
        FixedPoint.Unsigned memory collateralAmount
    ) internal returns (FixedPoint.Unsigned memory) {
        _removeCollateral(positionData.rawCollateral, collateralAmount);
        return _removeCollateral(rawTotalPositionCollateral, collateralAmount);
    }

    function _decrementCollateralBalancesCheckGCR(
        PositionData storage positionData,
        FixedPoint.Unsigned memory collateralAmount
    ) internal returns (FixedPoint.Unsigned memory) {
        _removeCollateral(positionData.rawCollateral, collateralAmount);
        require(_checkPositionCollateralization(positionData), "CR below GCR");
        return _removeCollateral(rawTotalPositionCollateral, collateralAmount);
    }

    function _onlyOpenState() internal view {
        require(contractState == ContractState.Open, "Contract state is not OPEN");
    }

    function _onlyPreExpiration() internal view {
        require(getCurrentTime() < expirationTimestamp, "Only callable pre-expiry");
    }

    function _onlyPostExpiration() internal view {
        require(getCurrentTime() >= expirationTimestamp, "Only callable post-expiry");
    }

    function _onlyCollateralizedPosition(address sponsor) internal view {
        require(
            _getFeeAdjustedCollateral(positions[sponsor].rawCollateral).isGreaterThan(0),
            "Position has no collateral"
        );
    }

    function _positionHasNoPendingWithdrawal(address sponsor) internal view {
        require(_getPositionData(sponsor).withdrawalRequestPassTimestamp == 0, "Pending withdrawal");
    }


    function _checkPositionCollateralization(PositionData storage positionData) private view returns (bool) {
        return
            _checkCollateralization(
                _getFeeAdjustedCollateral(positionData.rawCollateral),
                positionData.tokensOutstanding
            );
    }

    function _checkCollateralization(FixedPoint.Unsigned memory collateral, FixedPoint.Unsigned memory numTokens)
        private
        view
        returns (bool)
    {
        FixedPoint.Unsigned memory global = _getCollateralizationRatio(
            _getFeeAdjustedCollateral(rawTotalPositionCollateral),
            totalTokensOutstanding
        );
        FixedPoint.Unsigned memory thisChange = _getCollateralizationRatio(collateral, numTokens);
        return !global.isGreaterThan(thisChange);
    }

    function _getCollateralizationRatio(FixedPoint.Unsigned memory collateral, FixedPoint.Unsigned memory numTokens)
        private
        pure
        returns (FixedPoint.Unsigned memory ratio)
    {
        if (!numTokens.isGreaterThan(0)) {
            return FixedPoint.fromUnscaledUint(0);
        } else {
            return collateral.div(numTokens);
        }
    }
}


pragma solidity ^0.6.0;






contract Liquidatable is PricelessPositionManager {
    using FixedPoint for FixedPoint.Unsigned;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    enum Status { Uninitialized, PreDispute, PendingDispute, DisputeSucceeded, DisputeFailed }

    struct LiquidationData {
        address sponsor; // Address of the liquidated position's sponsor
        address liquidator; // Address who created this liquidation
        Status state; // Liquidated (and expired or not), Pending a Dispute, or Dispute has resolved
        uint256 liquidationTime; // Time when liquidation is initiated, needed to get price from Oracle
        FixedPoint.Unsigned tokensOutstanding; // Synthetic tokens required to be burned by liquidator to initiate dispute
        FixedPoint.Unsigned lockedCollateral; // Collateral locked by contract and released upon expiry or post-dispute
        FixedPoint.Unsigned liquidatedCollateral;
        FixedPoint.Unsigned rawUnitCollateral;
        address disputer; // Person who is disputing a liquidation
        FixedPoint.Unsigned settlementPrice; // Final price as determined by an Oracle following a dispute
        FixedPoint.Unsigned finalFee;
    }

    struct ConstructorParams {
        uint256 expirationTimestamp;
        uint256 withdrawalLiveness;
        address collateralAddress;
        address finderAddress;
        address tokenFactoryAddress;
        address timerAddress;
        bytes32 priceFeedIdentifier;
        string syntheticName;
        string syntheticSymbol;
        FixedPoint.Unsigned minSponsorTokens;
        uint256 liquidationLiveness;
        FixedPoint.Unsigned collateralRequirement;
        FixedPoint.Unsigned disputeBondPct;
        FixedPoint.Unsigned sponsorDisputeRewardPct;
        FixedPoint.Unsigned disputerDisputeRewardPct;
    }

    mapping(address => LiquidationData[]) public liquidations;

    FixedPoint.Unsigned public rawLiquidationCollateral;

    uint256 public liquidationLiveness;
    FixedPoint.Unsigned public collateralRequirement;
    FixedPoint.Unsigned public disputeBondPct;
    FixedPoint.Unsigned public sponsorDisputeRewardPct;
    FixedPoint.Unsigned public disputerDisputeRewardPct;


    event LiquidationCreated(
        address indexed sponsor,
        address indexed liquidator,
        uint256 indexed liquidationId,
        uint256 tokensOutstanding,
        uint256 lockedCollateral,
        uint256 liquidatedCollateral
    );
    event LiquidationDisputed(
        address indexed sponsor,
        address indexed liquidator,
        address indexed disputer,
        uint256 liquidationId,
        uint256 disputeBondAmount
    );
    event DisputeSettled(
        address indexed caller,
        address indexed sponsor,
        address indexed liquidator,
        address disputer,
        uint256 liquidationId,
        bool disputeSucceeded
    );
    event LiquidationWithdrawn(address indexed caller, uint256 withdrawalAmount, Status indexed liquidationStatus);


    modifier disputable(uint256 liquidationId, address sponsor) {
        _disputable(liquidationId, sponsor);
        _;
    }

    modifier withdrawable(uint256 liquidationId, address sponsor) {
        _withdrawable(liquidationId, sponsor);
        _;
    }

    constructor(ConstructorParams memory params)
        public
        PricelessPositionManager(
            params.expirationTimestamp,
            params.withdrawalLiveness,
            params.collateralAddress,
            params.finderAddress,
            params.priceFeedIdentifier,
            params.syntheticName,
            params.syntheticSymbol,
            params.tokenFactoryAddress,
            params.minSponsorTokens,
            params.timerAddress
        )
        nonReentrant()
    {
        require(params.collateralRequirement.isGreaterThan(1), "CR is more than 100%");
        require(
            params.sponsorDisputeRewardPct.add(params.disputerDisputeRewardPct).isLessThan(1),
            "Rewards are more than 100%"
        );

        liquidationLiveness = params.liquidationLiveness;
        collateralRequirement = params.collateralRequirement;
        disputeBondPct = params.disputeBondPct;
        sponsorDisputeRewardPct = params.sponsorDisputeRewardPct;
        disputerDisputeRewardPct = params.disputerDisputeRewardPct;
    }


    function createLiquidation(
        address sponsor,
        FixedPoint.Unsigned calldata minCollateralPerToken,
        FixedPoint.Unsigned calldata maxCollateralPerToken,
        FixedPoint.Unsigned calldata maxTokensToLiquidate,
        uint256 deadline
    )
        external
        fees()
        onlyPreExpiration()
        nonReentrant()
        returns (
            uint256 liquidationId,
            FixedPoint.Unsigned memory tokensLiquidated,
            FixedPoint.Unsigned memory finalFeeBond
        )
    {
        require(getCurrentTime() <= deadline, "Mined after deadline");

        PositionData storage positionToLiquidate = _getPositionData(sponsor);

        tokensLiquidated = FixedPoint.min(maxTokensToLiquidate, positionToLiquidate.tokensOutstanding);

        FixedPoint.Unsigned memory startCollateral = _getFeeAdjustedCollateral(positionToLiquidate.rawCollateral);
        FixedPoint.Unsigned memory startCollateralNetOfWithdrawal = FixedPoint.fromUnscaledUint(0);
        if (positionToLiquidate.withdrawalRequestAmount.isLessThanOrEqual(startCollateral)) {
            startCollateralNetOfWithdrawal = startCollateral.sub(positionToLiquidate.withdrawalRequestAmount);
        }

        {
            FixedPoint.Unsigned memory startTokens = positionToLiquidate.tokensOutstanding;

            require(
                maxCollateralPerToken.mul(startTokens).isGreaterThanOrEqual(startCollateralNetOfWithdrawal),
                "CR is more than max liq. price"
            );
            require(
                minCollateralPerToken.mul(startTokens).isLessThanOrEqual(startCollateralNetOfWithdrawal),
                "CR is less than min liq. price"
            );
        }

        finalFeeBond = _computeFinalFees();

        FixedPoint.Unsigned memory lockedCollateral;
        FixedPoint.Unsigned memory liquidatedCollateral;

        {
            FixedPoint.Unsigned memory ratio = tokensLiquidated.div(positionToLiquidate.tokensOutstanding);

            lockedCollateral = startCollateral.mul(ratio);

            liquidatedCollateral = startCollateralNetOfWithdrawal.mul(ratio);

            FixedPoint.Unsigned memory withdrawalAmountToRemove = positionToLiquidate.withdrawalRequestAmount.mul(
                ratio
            );
            _reduceSponsorPosition(sponsor, tokensLiquidated, lockedCollateral, withdrawalAmountToRemove);
        }

        _addCollateral(rawLiquidationCollateral, lockedCollateral.add(finalFeeBond));

        liquidationId = liquidations[sponsor].length;
        liquidations[sponsor].push(
            LiquidationData({
                sponsor: sponsor,
                liquidator: msg.sender,
                state: Status.PreDispute,
                liquidationTime: getCurrentTime(),
                tokensOutstanding: tokensLiquidated,
                lockedCollateral: lockedCollateral,
                liquidatedCollateral: liquidatedCollateral,
                rawUnitCollateral: _convertToRawCollateral(FixedPoint.fromUnscaledUint(1)),
                disputer: address(0),
                settlementPrice: FixedPoint.fromUnscaledUint(0),
                finalFee: finalFeeBond
            })
        );

        emit LiquidationCreated(
            sponsor,
            msg.sender,
            liquidationId,
            tokensLiquidated.rawValue,
            lockedCollateral.rawValue,
            liquidatedCollateral.rawValue
        );

        tokenCurrency.safeTransferFrom(msg.sender, address(this), tokensLiquidated.rawValue);
        tokenCurrency.burn(tokensLiquidated.rawValue);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), finalFeeBond.rawValue);
    }

    function dispute(uint256 liquidationId, address sponsor)
        external
        disputable(liquidationId, sponsor)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory totalPaid)
    {
        LiquidationData storage disputedLiquidation = _getLiquidationData(sponsor, liquidationId);

        FixedPoint.Unsigned memory disputeBondAmount = disputedLiquidation.lockedCollateral.mul(disputeBondPct).mul(
            _getFeeAdjustedCollateral(disputedLiquidation.rawUnitCollateral)
        );
        _addCollateral(rawLiquidationCollateral, disputeBondAmount);

        disputedLiquidation.state = Status.PendingDispute;
        disputedLiquidation.disputer = msg.sender;

        _requestOraclePrice(disputedLiquidation.liquidationTime);

        emit LiquidationDisputed(
            sponsor,
            disputedLiquidation.liquidator,
            msg.sender,
            liquidationId,
            disputeBondAmount.rawValue
        );
        totalPaid = disputeBondAmount.add(disputedLiquidation.finalFee);

        _payFinalFees(msg.sender, disputedLiquidation.finalFee);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), disputeBondAmount.rawValue);
    }

    function withdrawLiquidation(uint256 liquidationId, address sponsor)
        public
        withdrawable(liquidationId, sponsor)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {
        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);
        require(
            (msg.sender == liquidation.disputer) ||
                (msg.sender == liquidation.liquidator) ||
                (msg.sender == liquidation.sponsor),
            "Caller cannot withdraw rewards"
        );

        _settle(liquidationId, sponsor);

        FixedPoint.Unsigned memory feeAttenuation = _getFeeAdjustedCollateral(liquidation.rawUnitCollateral);
        FixedPoint.Unsigned memory tokenRedemptionValue = liquidation
            .tokensOutstanding
            .mul(liquidation.settlementPrice)
            .mul(feeAttenuation);
        FixedPoint.Unsigned memory collateral = liquidation.lockedCollateral.mul(feeAttenuation);
        FixedPoint.Unsigned memory disputerDisputeReward = disputerDisputeRewardPct.mul(tokenRedemptionValue);
        FixedPoint.Unsigned memory sponsorDisputeReward = sponsorDisputeRewardPct.mul(tokenRedemptionValue);
        FixedPoint.Unsigned memory disputeBondAmount = collateral.mul(disputeBondPct);
        FixedPoint.Unsigned memory finalFee = liquidation.finalFee.mul(feeAttenuation);

        FixedPoint.Unsigned memory withdrawalAmount = FixedPoint.fromUnscaledUint(0);
        if (liquidation.state == Status.DisputeSucceeded) {
            if (msg.sender == liquidation.disputer) {
                FixedPoint.Unsigned memory payToDisputer = disputerDisputeReward.add(disputeBondAmount).add(finalFee);
                withdrawalAmount = withdrawalAmount.add(payToDisputer);
                delete liquidation.disputer;
            }

            if (msg.sender == liquidation.sponsor) {
                FixedPoint.Unsigned memory remainingCollateral = collateral.sub(tokenRedemptionValue);
                FixedPoint.Unsigned memory payToSponsor = sponsorDisputeReward.add(remainingCollateral);
                withdrawalAmount = withdrawalAmount.add(payToSponsor);
                delete liquidation.sponsor;
            }

            if (msg.sender == liquidation.liquidator) {
                FixedPoint.Unsigned memory payToLiquidator = tokenRedemptionValue.sub(sponsorDisputeReward).sub(
                    disputerDisputeReward
                );
                withdrawalAmount = withdrawalAmount.add(payToLiquidator);
                delete liquidation.liquidator;
            }

            if (
                liquidation.disputer == address(0) &&
                liquidation.sponsor == address(0) &&
                liquidation.liquidator == address(0)
            ) {
                delete liquidations[sponsor][liquidationId];
            }
        } else if (liquidation.state == Status.DisputeFailed && msg.sender == liquidation.liquidator) {
            withdrawalAmount = collateral.add(disputeBondAmount).add(finalFee);
            delete liquidations[sponsor][liquidationId];
        } else if (liquidation.state == Status.PreDispute && msg.sender == liquidation.liquidator) {
            withdrawalAmount = collateral.add(finalFee);
            delete liquidations[sponsor][liquidationId];
        }
        require(withdrawalAmount.isGreaterThan(0), "Invalid withdrawal amount");

        amountWithdrawn = _removeCollateral(rawLiquidationCollateral, withdrawalAmount);

        emit LiquidationWithdrawn(msg.sender, amountWithdrawn.rawValue, liquidation.state);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);

        return amountWithdrawn;
    }

    function getLiquidations(address sponsor)
        external
        view
        nonReentrantView()
        returns (LiquidationData[] memory liquidationData)
    {
        return liquidations[sponsor];
    }


    function _settle(uint256 liquidationId, address sponsor) internal {
        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);

        if (liquidation.state != Status.PendingDispute) {
            return;
        }

        liquidation.settlementPrice = _getOraclePrice(liquidation.liquidationTime);

        FixedPoint.Unsigned memory tokenRedemptionValue = liquidation.tokensOutstanding.mul(
            liquidation.settlementPrice
        );

        FixedPoint.Unsigned memory requiredCollateral = tokenRedemptionValue.mul(collateralRequirement);

        bool disputeSucceeded = liquidation.liquidatedCollateral.isGreaterThanOrEqual(requiredCollateral);
        liquidation.state = disputeSucceeded ? Status.DisputeSucceeded : Status.DisputeFailed;

        emit DisputeSettled(
            msg.sender,
            sponsor,
            liquidation.liquidator,
            liquidation.disputer,
            liquidationId,
            disputeSucceeded
        );
    }

    function _pfc() internal override view returns (FixedPoint.Unsigned memory) {
        return super._pfc().add(_getFeeAdjustedCollateral(rawLiquidationCollateral));
    }

    function _getLiquidationData(address sponsor, uint256 liquidationId)
        internal
        view
        returns (LiquidationData storage liquidation)
    {
        LiquidationData[] storage liquidationArray = liquidations[sponsor];

        require(
            liquidationId < liquidationArray.length && liquidationArray[liquidationId].state != Status.Uninitialized,
            "Invalid liquidation ID"
        );
        return liquidationArray[liquidationId];
    }

    function _getLiquidationExpiry(LiquidationData storage liquidation) internal view returns (uint256) {
        return liquidation.liquidationTime.add(liquidationLiveness);
    }

    function _disputable(uint256 liquidationId, address sponsor) internal view {
        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);
        require(
            (getCurrentTime() < _getLiquidationExpiry(liquidation)) && (liquidation.state == Status.PreDispute),
            "Liquidation not disputable"
        );
    }

    function _withdrawable(uint256 liquidationId, address sponsor) internal view {
        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);
        Status state = liquidation.state;

        require(
            (state > Status.PreDispute) ||
                ((_getLiquidationExpiry(liquidation) <= getCurrentTime()) && (state == Status.PreDispute)),
            "Liquidation not withdrawable"
        );
    }
}


pragma solidity ^0.6.0;



contract ExpiringMultiParty is Liquidatable {
    constructor(ConstructorParams memory params)
        public
        Liquidatable(params)
    {

    }
}


pragma solidity ^0.6.0;



library ExpiringMultiPartyLib {
    function deploy(ExpiringMultiParty.ConstructorParams memory params) public returns (address) {
        ExpiringMultiParty derivative = new ExpiringMultiParty(params);
        return address(derivative);
    }
}