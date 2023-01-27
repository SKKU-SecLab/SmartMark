pragma solidity ^0.8.4;

library TribeRoles {


    bytes32 internal constant GOVERNOR = keccak256("GOVERN_ROLE");

    bytes32 internal constant GUARDIAN = keccak256("GUARDIAN_ROLE");

    bytes32 internal constant PCV_CONTROLLER = keccak256("PCV_CONTROLLER_ROLE");

    bytes32 internal constant MINTER = keccak256("MINTER_ROLE");


    bytes32 internal constant PARAMETER_ADMIN = keccak256("PARAMETER_ADMIN");

    bytes32 internal constant ORACLE_ADMIN = keccak256("ORACLE_ADMIN_ROLE");

    bytes32 internal constant TRIBAL_CHIEF_ADMIN =
        keccak256("TRIBAL_CHIEF_ADMIN_ROLE");

    bytes32 internal constant PCV_GUARDIAN_ADMIN =
        keccak256("PCV_GUARDIAN_ADMIN_ROLE");

    bytes32 internal constant MINOR_ROLE_ADMIN = keccak256("MINOR_ROLE_ADMIN");

    bytes32 internal constant FUSE_ADMIN = keccak256("FUSE_ADMIN");

    bytes32 internal constant VETO_ADMIN = keccak256("VETO_ADMIN");

    bytes32 internal constant MINTER_ADMIN = keccak256("MINTER_ADMIN");

    bytes32 internal constant OPTIMISTIC_ADMIN = keccak256("OPTIMISTIC_ADMIN");

    bytes32 internal constant METAGOVERNANCE_VOTE_ADMIN =
        keccak256("METAGOVERNANCE_VOTE_ADMIN");

    bytes32 internal constant METAGOVERNANCE_TOKEN_STAKING =
        keccak256("METAGOVERNANCE_TOKEN_STAKING");

    bytes32 internal constant METAGOVERNANCE_GAUGE_ADMIN =
        keccak256("METAGOVERNANCE_GAUGE_ADMIN");


    bytes32 internal constant LBP_SWAP_ROLE = keccak256("SWAP_ADMIN_ROLE");

    bytes32 internal constant VOTIUM_ROLE = keccak256("VOTIUM_ADMIN_ROLE");

    bytes32 internal constant MINOR_PARAM_ROLE = keccak256("MINOR_PARAM_ROLE");
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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPermissionsRead {


    function isBurner(address _address) external view returns (bool);


    function isMinter(address _address) external view returns (bool);


    function isGovernor(address _address) external view returns (bool);


    function isGuardian(address _address) external view returns (bool);


    function isPCVController(address _address) external view returns (bool);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IPermissions is IAccessControl, IPermissionsRead {


    function createRole(bytes32 role, bytes32 adminRole) external;


    function grantMinter(address minter) external;


    function grantBurner(address burner) external;


    function grantPCVController(address pcvController) external;


    function grantGovernor(address governor) external;


    function grantGuardian(address guardian) external;


    function revokeMinter(address minter) external;


    function revokeBurner(address burner) external;


    function revokePCVController(address pcvController) external;


    function revokeGovernor(address governor) external;


    function revokeGuardian(address guardian) external;



    function revokeOverride(bytes32 role, address account) external;



    function GUARDIAN_ROLE() external view returns (bytes32);


    function GOVERN_ROLE() external view returns (bytes32);


    function BURNER_ROLE() external view returns (bytes32);


    function MINTER_ROLE() external view returns (bytes32);


    function PCV_CONTROLLER_ROLE() external view returns (bytes32);

}// MIT

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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IFei is IERC20 {


    event Minting(
        address indexed _to,
        address indexed _minter,
        uint256 _amount
    );

    event Burning(
        address indexed _to,
        address indexed _burner,
        uint256 _amount
    );

    event IncentiveContractUpdate(
        address indexed _incentivized,
        address indexed _incentiveContract
    );


    function burn(uint256 amount) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function burnFrom(address account, uint256 amount) external;



    function mint(address account, uint256 amount) external;



    function setIncentiveContract(address account, address incentive) external;



    function incentiveContract(address account) external view returns (address);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ICore is IPermissions {


    event FeiUpdate(address indexed _fei);
    event TribeUpdate(address indexed _tribe);
    event GenesisGroupUpdate(address indexed _genesisGroup);
    event TribeAllocation(address indexed _to, uint256 _amount);
    event GenesisPeriodComplete(uint256 _timestamp);


    function init() external;



    function setFei(address token) external;


    function setTribe(address token) external;


    function allocateTribe(address to, uint256 amount) external;



    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ICoreRef {


    event CoreUpdate(address indexed oldCore, address indexed newCore);

    event ContractAdminRoleUpdate(
        bytes32 indexed oldContractAdminRole,
        bytes32 indexed newContractAdminRole
    );


    function setContractAdminRole(bytes32 newContractAdminRole) external;



    function pause() external;


    function unpause() external;



    function core() external view returns (ICore);


    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);


    function feiBalance() external view returns (uint256);


    function tribeBalance() external view returns (uint256);


    function CONTRACT_ADMIN_ROLE() external view returns (bytes32);


    function isContractAdmin(address admin) external view returns (bool);

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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


abstract contract CoreRef is ICoreRef, Pausable {
    ICore private immutable _core;
    IFei private immutable _fei;
    IERC20 private immutable _tribe;

    bytes32 public override CONTRACT_ADMIN_ROLE;

    constructor(address coreAddress) {
        _core = ICore(coreAddress);

        _fei = ICore(coreAddress).fei();
        _tribe = ICore(coreAddress).tribe();

        _setContractAdminRole(ICore(coreAddress).GOVERN_ROLE());
    }

    function _initialize(address) internal {} // no-op for backward compatibility

    modifier ifMinterSelf() {
        if (_core.isMinter(address(this))) {
            _;
        }
    }

    modifier onlyMinter() {
        require(_core.isMinter(msg.sender), "CoreRef: Caller is not a minter");
        _;
    }

    modifier onlyBurner() {
        require(_core.isBurner(msg.sender), "CoreRef: Caller is not a burner");
        _;
    }

    modifier onlyPCVController() {
        require(
            _core.isPCVController(msg.sender),
            "CoreRef: Caller is not a PCV controller"
        );
        _;
    }

    modifier onlyGovernorOrAdmin() {
        require(
            _core.isGovernor(msg.sender) || isContractAdmin(msg.sender),
            "CoreRef: Caller is not a governor or contract admin"
        );
        _;
    }

    modifier onlyGovernor() {
        require(
            _core.isGovernor(msg.sender),
            "CoreRef: Caller is not a governor"
        );
        _;
    }

    modifier onlyGuardianOrGovernor() {
        require(
            _core.isGovernor(msg.sender) || _core.isGuardian(msg.sender),
            "CoreRef: Caller is not a guardian or governor"
        );
        _;
    }

    modifier isGovernorOrGuardianOrAdmin() {
        require(
            _core.isGovernor(msg.sender) ||
                _core.isGuardian(msg.sender) ||
                isContractAdmin(msg.sender),
            "CoreRef: Caller is not governor or guardian or admin"
        );
        _;
    }

    modifier onlyTribeRole(bytes32 role) {
        require(_core.hasRole(role, msg.sender), "UNAUTHORIZED");
        _;
    }

    modifier hasAnyOfTwoRoles(bytes32 role1, bytes32 role2) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier hasAnyOfThreeRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3
    ) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender) ||
                _core.hasRole(role3, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier hasAnyOfFourRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        bytes32 role4
    ) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender) ||
                _core.hasRole(role3, msg.sender) ||
                _core.hasRole(role4, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier hasAnyOfFiveRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        bytes32 role4,
        bytes32 role5
    ) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender) ||
                _core.hasRole(role3, msg.sender) ||
                _core.hasRole(role4, msg.sender) ||
                _core.hasRole(role5, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier onlyFei() {
        require(msg.sender == address(_fei), "CoreRef: Caller is not FEI");
        _;
    }

    function setContractAdminRole(bytes32 newContractAdminRole)
        external
        override
        onlyGovernor
    {
        _setContractAdminRole(newContractAdminRole);
    }

    function isContractAdmin(address _admin)
        public
        view
        override
        returns (bool)
    {
        return _core.hasRole(CONTRACT_ADMIN_ROLE, _admin);
    }

    function pause() public override onlyGuardianOrGovernor {
        _pause();
    }

    function unpause() public override onlyGuardianOrGovernor {
        _unpause();
    }

    function core() public view override returns (ICore) {
        return _core;
    }

    function fei() public view override returns (IFei) {
        return _fei;
    }

    function tribe() public view override returns (IERC20) {
        return _tribe;
    }

    function feiBalance() public view override returns (uint256) {
        return _fei.balanceOf(address(this));
    }

    function tribeBalance() public view override returns (uint256) {
        return _tribe.balanceOf(address(this));
    }

    function _burnFeiHeld() internal {
        _fei.burn(feiBalance());
    }

    function _mintFei(address to, uint256 amount) internal virtual {
        if (amount != 0) {
            _fei.mint(to, amount);
        }
    }

    function _setContractAdminRole(bytes32 newContractAdminRole) internal {
        bytes32 oldContractAdminRole = CONTRACT_ADMIN_ROLE;
        CONTRACT_ADMIN_ROLE = newContractAdminRole;
        emit ContractAdminRoleUpdate(
            oldContractAdminRole,
            newContractAdminRole
        );
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPCVDepositBalances {


    function balance() external view returns (uint256);


    function balanceReportedIn() external view returns (address);


    function resistantBalanceAndFei() external view returns (uint256, uint256);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IPCVDeposit is IPCVDepositBalances {

    event Deposit(address indexed _from, uint256 _amount);

    event Withdrawal(
        address indexed _caller,
        address indexed _to,
        uint256 _amount
    );

    event WithdrawERC20(
        address indexed _caller,
        address indexed _token,
        address indexed _to,
        uint256 _amount
    );

    event WithdrawETH(
        address indexed _caller,
        address indexed _to,
        uint256 _amount
    );


    function deposit() external;



    function withdraw(address to, uint256 amount) external;


    function withdrawERC20(
        address token,
        address to,
        uint256 amount
    ) external;


    function withdrawETH(address payable to, uint256 amount) external;

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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


abstract contract PCVDeposit is IPCVDeposit, CoreRef {
    using SafeERC20 for IERC20;

    function withdrawERC20(
        address token,
        address to,
        uint256 amount
    ) public virtual override onlyPCVController {
        _withdrawERC20(token, to, amount);
    }

    function _withdrawERC20(
        address token,
        address to,
        uint256 amount
    ) internal {
        IERC20(token).safeTransfer(to, amount);
        emit WithdrawERC20(msg.sender, token, to, amount);
    }

    function withdrawETH(address payable to, uint256 amountOut)
        external
        virtual
        override
        onlyPCVController
    {
        Address.sendValue(to, amountOut);
        emit WithdrawETH(msg.sender, to, amountOut);
    }

    function balance() public view virtual override returns (uint256);

    function resistantBalanceAndFei()
        public
        view
        virtual
        override
        returns (uint256, uint256)
    {
        return (balance(), 0);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


interface DelegateRegistry {

    function setDelegate(bytes32 id, address delegate) external;


    function clearDelegate(bytes32 id) external;


    function delegation(address delegator, bytes32 id)
        external
        view
        returns (address delegatee);

}

contract SnapshotDelegatorPCVDeposit is PCVDeposit {

    event DelegateUpdate(
        address indexed oldDelegate,
        address indexed newDelegate
    );

    DelegateRegistry public constant DELEGATE_REGISTRY =
        DelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

    IERC20 public immutable token;

    bytes32 public spaceId;

    address public delegate;

    constructor(
        address _core,
        IERC20 _token,
        bytes32 _spaceId,
        address _initialDelegate
    ) CoreRef(_core) {
        token = _token;
        spaceId = _spaceId;
        _delegate(_initialDelegate);
    }

    function withdraw(address to, uint256 amountUnderlying)
        external
        override
        onlyPCVController
    {

        _withdrawERC20(address(token), to, amountUnderlying);
    }

    function deposit() external override {}


    function balance() public view virtual override returns (uint256) {

        return token.balanceOf(address(this));
    }

    function balanceReportedIn() public view override returns (address) {

        return address(token);
    }

    function setSpaceId(bytes32 _spaceId)
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
    {

        DELEGATE_REGISTRY.clearDelegate(spaceId);
        spaceId = _spaceId;
        _delegate(delegate);
    }

    function setDelegate(address newDelegate)
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
    {

        _delegate(newDelegate);
    }

    function clearDelegate()
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
    {

        address oldDelegate = delegate;
        DELEGATE_REGISTRY.clearDelegate(spaceId);

        emit DelegateUpdate(oldDelegate, address(0));
    }

    function _delegate(address newDelegate) internal {

        address oldDelegate = delegate;
        DELEGATE_REGISTRY.setDelegate(spaceId, newDelegate);
        delegate = newDelegate;

        emit DelegateUpdate(oldDelegate, newDelegate);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


interface IVeToken {

    function balanceOf(address) external view returns (uint256);


    function locked(address) external view returns (uint256);


    function create_lock(uint256 value, uint256 unlock_time) external;


    function increase_amount(uint256 value) external;


    function increase_unlock_time(uint256 unlock_time) external;


    function withdraw() external;


    function locked__end(address) external view returns (uint256);


    function checkpoint() external;


    function commit_smart_wallet_checker(address) external;


    function apply_smart_wallet_checker() external;

}

abstract contract VoteEscrowTokenManager is CoreRef {
    event Lock(uint256 cummulativeTokensLocked, uint256 lockHorizon);
    event Unlock(uint256 tokensUnlocked);

    uint256 private constant WEEK = 7 * 86400; // 1 week, in seconds

    uint256 public lockDuration;

    IVeToken public immutable veToken;

    IERC20 public immutable liquidToken;

    constructor(
        IERC20 _liquidToken,
        IVeToken _veToken,
        uint256 _lockDuration
    ) {
        liquidToken = _liquidToken;
        veToken = _veToken;
        lockDuration = _lockDuration;
    }

    function setLockDuration(uint256 newLockDuration)
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_TOKEN_STAKING)
    {
        lockDuration = newLockDuration;
    }

    function lock()
        external
        whenNotPaused
        onlyTribeRole(TribeRoles.METAGOVERNANCE_TOKEN_STAKING)
    {
        uint256 tokenBalance = liquidToken.balanceOf(address(this));
        uint256 locked = veToken.locked(address(this));
        uint256 lockHorizon = ((block.timestamp + lockDuration) / WEEK) * WEEK;

        if (tokenBalance != 0 && locked == 0) {
            liquidToken.approve(address(veToken), tokenBalance);
            veToken.create_lock(tokenBalance, lockHorizon);
        }
        else if (tokenBalance != 0 && locked != 0) {
            liquidToken.approve(address(veToken), tokenBalance);
            veToken.increase_amount(tokenBalance);
            if (veToken.locked__end(address(this)) != lockHorizon) {
                veToken.increase_unlock_time(lockHorizon);
            }
        }
        else if (tokenBalance == 0 && locked != 0) {
            veToken.increase_unlock_time(lockHorizon);
        }

        emit Lock(tokenBalance + locked, lockHorizon);
    }

    function exitLock()
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_TOKEN_STAKING)
    {
        veToken.withdraw();

        emit Unlock(liquidToken.balanceOf(address(this)));
    }

    function _totalTokensManaged() internal view returns (uint256) {
        return
            liquidToken.balanceOf(address(this)) +
            veToken.locked(address(this));
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


interface ILiquidityGauge {

    function deposit(uint256 value) external;


    function withdraw(uint256 value, bool claim_rewards) external;


    function claim_rewards() external;


    function balanceOf(address) external view returns (uint256);


    function lp_token() external view returns (address);


    function staking_token() external view returns (address);


    function reward_tokens(uint256 i) external view returns (address token);


    function reward_count() external view returns (uint256 nTokens);

}

interface ILiquidityGaugeController {

    function vote_for_gauge_weights(address gauge_addr, uint256 user_weight)
        external;


    function last_user_vote(address user, address gauge)
        external
        view
        returns (uint256);


    function vote_user_power(address user) external view returns (uint256);


    function gauge_types(address gauge) external view returns (int128);

}

abstract contract LiquidityGaugeManager is CoreRef {
    event GaugeControllerChanged(
        address indexed oldController,
        address indexed newController
    );
    event GaugeSetForToken(address indexed token, address indexed gauge);
    event GaugeVote(address indexed gauge, uint256 amount);
    event GaugeStake(address indexed gauge, uint256 amount);
    event GaugeUnstake(address indexed gauge, uint256 amount);
    event GaugeRewardsClaimed(
        address indexed gauge,
        address indexed token,
        uint256 amount
    );

    address public gaugeController;

    mapping(address => address) public tokenToGauge;

    constructor(address _gaugeController) {
        gaugeController = _gaugeController;
    }

    function setGaugeController(address _gaugeController)
        public
        onlyTribeRole(TribeRoles.METAGOVERNANCE_GAUGE_ADMIN)
    {
        require(
            gaugeController != _gaugeController,
            "LiquidityGaugeManager: same controller"
        );

        address oldController = gaugeController;
        gaugeController = _gaugeController;

        emit GaugeControllerChanged(oldController, gaugeController);
    }

    function _tokenStakedInGauge(address gaugeAddress)
        internal
        view
        virtual
        returns (address)
    {
        return ILiquidityGauge(gaugeAddress).lp_token();
    }

    function setTokenToGauge(address token, address gaugeAddress)
        public
        onlyTribeRole(TribeRoles.METAGOVERNANCE_GAUGE_ADMIN)
    {
        require(
            _tokenStakedInGauge(gaugeAddress) == token,
            "LiquidityGaugeManager: wrong gauge for token"
        );
        require(
            ILiquidityGaugeController(gaugeController).gauge_types(
                gaugeAddress
            ) >= 0,
            "LiquidityGaugeManager: wrong gauge address"
        );
        tokenToGauge[token] = gaugeAddress;

        emit GaugeSetForToken(token, gaugeAddress);
    }

    function voteForGaugeWeight(address token, uint256 gaugeWeight)
        public
        whenNotPaused
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
    {
        address gaugeAddress = tokenToGauge[token];
        require(
            gaugeAddress != address(0),
            "LiquidityGaugeManager: token has no gauge configured"
        );
        ILiquidityGaugeController(gaugeController).vote_for_gauge_weights(
            gaugeAddress,
            gaugeWeight
        );

        emit GaugeVote(gaugeAddress, gaugeWeight);
    }

    function stakeInGauge(address token, uint256 amount)
        public
        whenNotPaused
        onlyTribeRole(TribeRoles.METAGOVERNANCE_GAUGE_ADMIN)
    {
        address gaugeAddress = tokenToGauge[token];
        require(
            gaugeAddress != address(0),
            "LiquidityGaugeManager: token has no gauge configured"
        );
        IERC20(token).approve(gaugeAddress, amount);
        ILiquidityGauge(gaugeAddress).deposit(amount);

        emit GaugeStake(gaugeAddress, amount);
    }

    function stakeAllInGauge(address token)
        public
        whenNotPaused
        onlyTribeRole(TribeRoles.METAGOVERNANCE_GAUGE_ADMIN)
    {
        address gaugeAddress = tokenToGauge[token];
        require(
            gaugeAddress != address(0),
            "LiquidityGaugeManager: token has no gauge configured"
        );
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(gaugeAddress, amount);
        ILiquidityGauge(gaugeAddress).deposit(amount);

        emit GaugeStake(gaugeAddress, amount);
    }

    function unstakeFromGauge(address token, uint256 amount)
        public
        whenNotPaused
        onlyTribeRole(TribeRoles.METAGOVERNANCE_GAUGE_ADMIN)
    {
        address gaugeAddress = tokenToGauge[token];
        require(
            gaugeAddress != address(0),
            "LiquidityGaugeManager: token has no gauge configured"
        );
        ILiquidityGauge(gaugeAddress).withdraw(amount, false);

        emit GaugeUnstake(gaugeAddress, amount);
    }

    function claimGaugeRewards(address token) public whenNotPaused {
        address gaugeAddress = tokenToGauge[token];
        require(
            gaugeAddress != address(0),
            "LiquidityGaugeManager: token has no gauge configured"
        );

        uint256 nTokens = ILiquidityGauge(gaugeAddress).reward_count();
        address[] memory tokens = new address[](nTokens);
        uint256[] memory amounts = new uint256[](nTokens);

        for (uint256 i = 0; i < nTokens; i++) {
            tokens[i] = ILiquidityGauge(gaugeAddress).reward_tokens(i);
            amounts[i] = IERC20(tokens[i]).balanceOf(address(this));
        }

        ILiquidityGauge(gaugeAddress).claim_rewards();

        for (uint256 i = 0; i < nTokens; i++) {
            amounts[i] =
                IERC20(tokens[i]).balanceOf(address(this)) -
                amounts[i];

            emit GaugeRewardsClaimed(gaugeAddress, tokens[i], amounts[i]);
        }
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


interface IMetagovGovernor {

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId);


    function propose(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId);


    function castVote(uint256 proposalId, uint8 support)
        external
        returns (uint256 weight);


    function state(uint256 proposalId) external view returns (uint256);

}

abstract contract GovernorVoter is CoreRef {
    event Proposed(IMetagovGovernor indexed governor, uint256 proposalId);
    event Voted(
        IMetagovGovernor indexed governor,
        uint256 proposalId,
        uint256 weight,
        uint8 support
    );

    function proposeOZ(
        IMetagovGovernor governor,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
        returns (uint256)
    {
        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            description
        );
        emit Proposed(governor, proposalId);
        return proposalId;
    }

    function proposeBravo(
        IMetagovGovernor governor,
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    )
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
        returns (uint256)
    {
        uint256 proposalId = governor.propose(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        emit Proposed(governor, proposalId);
        return proposalId;
    }

    function castVote(
        IMetagovGovernor governor,
        uint256 proposalId,
        uint8 support
    )
        external
        onlyTribeRole(TribeRoles.METAGOVERNANCE_VOTE_ADMIN)
        returns (uint256)
    {
        uint256 weight = governor.castVote(proposalId, support);
        emit Voted(governor, proposalId, weight, support);
        return weight;
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


contract VeBalDelegatorPCVDeposit is
    SnapshotDelegatorPCVDeposit,
    VoteEscrowTokenManager,
    LiquidityGaugeManager,
    GovernorVoter
{

    address public constant B_80BAL_20WETH =
        0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;
    address public constant VE_BAL = 0xC128a9954e6c874eA3d62ce62B468bA073093F25;
    address public constant BALANCER_GAUGE_CONTROLLER =
        0xC128468b7Ce63eA702C1f104D55A2566b13D3ABD;

    constructor(address _core, address _initialDelegate)
        SnapshotDelegatorPCVDeposit(
            _core,
            IERC20(B_80BAL_20WETH), // token used in reporting
            "balancer.eth", // initial snapshot spaceId
            _initialDelegate
        )
        VoteEscrowTokenManager(
            IERC20(B_80BAL_20WETH), // liquid token
            IVeToken(VE_BAL), // vote-escrowed token
            365 * 86400 // vote-escrow time = 1 year
        )
        LiquidityGaugeManager(BALANCER_GAUGE_CONTROLLER)
        GovernorVoter()
    {}

    function balance() public view override returns (uint256) {

        return _totalTokensManaged(); // liquid and vote-escrowed tokens
    }
}