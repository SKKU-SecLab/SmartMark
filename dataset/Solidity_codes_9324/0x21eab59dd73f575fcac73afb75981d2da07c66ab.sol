
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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;




contract GovernanceToken is AccessControl, ERC20Pausable, ERC20Burnable {

    uint256 public constant INITIALSUPPLY = 2000000000 * (10 ** 18);

    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

    constructor(address adminAddress_)
            ERC20('SyncDAO Governance', 'SDG') {

        _mint(_msgSender(), INITIALSUPPLY);
        _setupRole(DEFAULT_ADMIN_ROLE, adminAddress_);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override(ERC20, ERC20Pausable) {

        ERC20Pausable._beforeTokenTransfer(from, to, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}// MIT

pragma solidity ^0.8.0;






contract GovernanceDistribution is AccessControl {

    using SafeERC20 for GovernanceToken;
    using SafeERC20 for IERC20;

    bytes32 public constant DISTRIBUTOR_ROLE = keccak256('DISTRIBUTOR_ROLE');

    uint256 public constant INITIALSUPPLY = 2000000000 * DECIMALFACTOR;
    uint256 private constant DECIMALFACTOR = 10 ** 18;

    uint256 private constant MONTH = 30 days;
    uint256 private constant YEAR = 365 days;


    GovernanceToken public token;
    uint256 public availableTotalSupply = INITIALSUPPLY;

    uint256 public availableProductUsage1Supply             = 200000000 * DECIMALFACTOR;    // 10%
    uint256 public availableProductUsage2Supply             = 800000000 * DECIMALFACTOR;    // 40%
    uint256 public availableBuildersSupply                  = 140000000 * DECIMALFACTOR;    // 7%
    uint256 public availableAffiliateSupply                 = 120000000 * DECIMALFACTOR;    // 6%
    uint256 public availableTeamSupply                      = 250000000 * DECIMALFACTOR;    // 12.50%
    uint256 public availableAdvisorsSupply                  = 50000000 * DECIMALFACTOR;     // 2.50%
    uint256 public availableAngelsSupply                    = 224887556 * DECIMALFACTOR;    // 11.24%
    uint256 public availablePresaleSupply                   = 101063830 * DECIMALFACTOR;    // 5.05%
    uint256 public availablePublicSupply                    = 19342360 * DECIMALFACTOR;     // 0.97%
    uint256 public availableReserveSupply                   = 94706254 * DECIMALFACTOR;     // 4.74%

    uint256 public grandTotalClaimed = 0;


    mapping (address => Allocation) private _allocations;
    address[] private _allocatedAddresses;


    enum AllocationType {
        ProductUsage1,
        ProductUsage2,
        Builders,
        Affiliate,
        Team,
        Advisors,
        Angels,
        Presale,
        Public,
        Reserve
    }

    enum State {
        NotAllocated,
        Allocated,
        Canceled
    }

    enum UnlockStyle {
        Linear,
        Monthly
    }

    struct Allocation {

        AllocationType allocationType;          // Type of allocation
        uint256 allocationTime;                 // Locking calculated from this time
        uint256 lockupPeriod;                   // After this period tokens can be claimed
        uint256 releasedImmediately;            // Percentage of tokens that will be released immediately
        uint256 vesting;                        // After this period all tokens can be claimed
        UnlockStyle unlockStyle;                // Style of unlocking it can be liner or monthly
        uint256 totalAllocated;                 // Total tokens allocated
        uint256 amountClaimed;                  // Total tokens claimed
        State state;                            // Allocation state
        bool instantRelease;
    }


    event NewAllocation(address indexed recipient, AllocationType indexed allocationType, uint256 amount);
    event TokenClaimed(address indexed recipient,
                        AllocationType indexed allocationType,
                        uint256 amountClaimed);
    event CancelAllocation(address indexed recipient);


    constructor() {

        require(availableTotalSupply == availableProductUsage1Supply
                                            + availableProductUsage2Supply
                                            + availableBuildersSupply
                                            + availableAffiliateSupply
                                            + availableTeamSupply
                                            + availableAdvisorsSupply
                                            + availableAngelsSupply
                                            + availablePresaleSupply
                                            + availablePublicSupply
                                            + availableReserveSupply);

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = new GovernanceToken(_msgSender());
    }

    function getAllocatedAddresses()
        view
        external
        returns(address[] memory) {

        return _allocatedAddresses;
    }

    function getAllocation(address address_)
        view
        external
        returns(AllocationType allocationType,
                bool instantRelease,
                uint256 allocationTime,
                uint256 lockupPeriod,
                uint256 releasedImmediately,
                uint256 vesting,
                uint256 totalAllocated,
                uint256 amountClaimed,
                UnlockStyle unlockStyle,
                State state) {

        allocationType = _allocations[address_].allocationType;
        instantRelease = _allocations[address_].instantRelease;
        allocationTime = _allocations[address_].allocationTime;
        lockupPeriod = _allocations[address_].lockupPeriod;
        releasedImmediately = _allocations[address_].releasedImmediately;
        vesting = _allocations[address_].vesting;
        totalAllocated = _allocations[address_].totalAllocated;
        amountClaimed = _allocations[address_].amountClaimed;
        unlockStyle = _allocations[address_].unlockStyle;
        state = _allocations[address_].state;
    }

    function setAllocation (address recipient_, uint256 amount_, AllocationType
                            allocationType_, bool instantRelease_) external onlyRole(DISTRIBUTOR_ROLE) {

        require(address(0x0) != recipient_, 'Recipient address cannot be 0x0');
        require(0 < amount_, 'Allocated amount must be greater than 0');
        Allocation storage a = _allocations[recipient_];
        if (State.NotAllocated == a.state) {
            a.allocationTime = block.timestamp;
            a.totalAllocated = amount_;
            _allocatedAddresses.push(recipient_);
        } else if (State.Canceled == a.state) {
            a.allocationTime = block.timestamp;
            a.totalAllocated = amount_;
        } else {
            require(allocationType_ == a.allocationType, 'Cannot change already allocated allocation type');
            require(instantRelease_ == a.instantRelease, 'Cannot change already allocated instant release');
            a.totalAllocated += amount_;
        }
        a.state = State.Allocated;
        a.allocationType = allocationType_;
        a.instantRelease = instantRelease_;
        if (AllocationType.ProductUsage1 == allocationType_) {
            availableProductUsage1Supply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 0;
            a.lockupPeriod = 0;
            a.vesting = 3 * MONTH;
        } else if (AllocationType.ProductUsage2 == allocationType_) {
            availableProductUsage2Supply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 0;
            a.lockupPeriod = 3 * MONTH;
            a.vesting = 4 * YEAR;
        } else if (AllocationType.Builders == allocationType_) {
            availableBuildersSupply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 0;
            a.lockupPeriod = 0;
            a.vesting = 8 * YEAR;
        } else if (AllocationType.Affiliate == allocationType_) {
            availableAffiliateSupply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 0;
            a.lockupPeriod = 0;
            a.vesting = 8 * YEAR;
        } else if (AllocationType.Team == allocationType_) {
            availableTeamSupply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 0;
            a.lockupPeriod = 6 * MONTH;
            a.vesting = 30 * MONTH;
        } else if (AllocationType.Advisors == allocationType_) {
            availableAdvisorsSupply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 0;
            a.lockupPeriod = 1 * MONTH;
            a.vesting = 24 * MONTH;
        } else if (AllocationType.Angels == allocationType_) {
            availableAngelsSupply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 250;
            a.lockupPeriod = 0;
            a.vesting = 9 * MONTH;
        } else if (AllocationType.Presale == allocationType_) {
            availablePresaleSupply -= amount_;
            a.unlockStyle = UnlockStyle.Monthly;
            a.releasedImmediately = 1000;
            a.lockupPeriod = 0;
            a.vesting = 3 * MONTH;
        } else if (AllocationType.Public == allocationType_) {
            availablePublicSupply -= amount_;
            a.unlockStyle = UnlockStyle.Monthly;
            a.releasedImmediately = 0;
            a.lockupPeriod = 0;
            a.vesting = 2 * MONTH;
        } else { // Reserve
            availableReserveSupply -= amount_;
            a.unlockStyle = UnlockStyle.Linear;
            a.releasedImmediately = 1525;
            a.lockupPeriod = 0;
            a.vesting = 9 * MONTH;
        }
        availableTotalSupply -= amount_;
        emit NewAllocation(recipient_, allocationType_, amount_);
    }

    function cancelAllocation (address recipient_)
        external onlyRole(DISTRIBUTOR_ROLE) {

        Allocation storage a = _allocations[recipient_];
        require(State.Allocated == a.state, 'There is no allocation');
        require(0 == a.amountClaimed, 'Cannot canceled allocation with claimed tokens');
        a.state = State.Canceled;

        availableTotalSupply += a.totalAllocated;
        if (AllocationType.ProductUsage1 == a.allocationType) {
            availableProductUsage1Supply += a.totalAllocated;
        } else if (AllocationType.ProductUsage2 == a.allocationType) {
            availableProductUsage2Supply += a.totalAllocated;
        } else if (AllocationType.Builders == a.allocationType) {
            availableBuildersSupply += a.totalAllocated;
        } else if (AllocationType.Affiliate == a.allocationType) {
            availableAffiliateSupply += a.totalAllocated;
        } else if (AllocationType.Team == a.allocationType) {
            availableTeamSupply += a.totalAllocated;
        } else if (AllocationType.Advisors == a.allocationType) {
            availableAdvisorsSupply += a.totalAllocated;
        } else if (AllocationType.Angels == a.allocationType) {
            availableAngelsSupply += a.totalAllocated;
        } else if (AllocationType.Presale == a.allocationType) {
            availablePresaleSupply += a.totalAllocated;
        } else if (AllocationType.Public == a.allocationType) {
            availablePublicSupply += a.totalAllocated;
        } else { // Reserve
            availableReserveSupply += a.totalAllocated;
        }
        emit CancelAllocation(recipient_);
    }

    function claimTokens (address recipient_) external returns(uint256) {

        Allocation storage a = _allocations[recipient_];
        require(State.Allocated == a.state, 'There is no allocation for the recipient');
        require(a.amountClaimed < a.totalAllocated, 'Allocations have already been transferred');
        uint256 p100 = 10000;
        uint256 newPercentage = a.releasedImmediately;
        if (a.instantRelease) {
            newPercentage = p100;
        } else if (block.timestamp > a.allocationTime + a.lockupPeriod) {
            if (a.unlockStyle == UnlockStyle.Linear) {
                newPercentage += (block.timestamp - (a.allocationTime + a.lockupPeriod)) *
                                                    (p100 - a.releasedImmediately) / a.vesting;
            } else {
                uint256 m = a.vesting % MONTH > 0 ? 1 : 0;
                uint256 n = a.vesting / MONTH + m; // 0 !== a.vesting
                newPercentage += ((block.timestamp - (a.allocationTime + a.lockupPeriod)) / MONTH) *
                                                    (p100 - a.releasedImmediately) / n;
            }
        }
        uint256 newAmountClaimed = a.totalAllocated;
        if (newPercentage < p100) {
            newAmountClaimed = a.totalAllocated * newPercentage / p100;
        }
        require(newAmountClaimed > a.amountClaimed, 'Tokens for this period are already transferred');
        uint256 tokensToTransfer = newAmountClaimed - a.amountClaimed;
        token.safeTransfer(recipient_, tokensToTransfer);
        grandTotalClaimed += tokensToTransfer;
        a.amountClaimed = newAmountClaimed;
        emit TokenClaimed(recipient_, a.allocationType, tokensToTransfer);
        return tokensToTransfer;
    }

    function refundTokens(address recipientAddress_, address erc20Address_)
        external onlyRole(DISTRIBUTOR_ROLE) {

        require(erc20Address_ != address(token), 'Cannot refund GovernanceToken');
        IERC20 erc20 = IERC20(erc20Address_);
        uint256 balance = erc20.balanceOf(address(this));
        erc20.safeTransfer(recipientAddress_, balance);
    }
}