pragma solidity ^0.6.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}
pragma solidity ^0.6.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

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


pragma solidity 0.6.10;

interface IProxyFactory {

    function deploy(uint256 _salt, address _logic, address _admin, bytes memory _data) external returns (address);

}// AGPL-3.0-only


pragma solidity 0.6.10;

interface IProxyAdmin {

    function getProxyImplementation(address proxy) external view returns (address);

}// AGPL-3.0-only


pragma solidity 0.6.10;

interface ITimeHelpers {

    function getCurrentMonth() external view returns (uint);

    function monthToTimestamp(uint month) external view returns (uint timestamp);

}pragma solidity ^0.6.0;

interface IERC777Sender {

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}


pragma solidity 0.6.10;

interface IDelegationController {


    function delegate(
        uint256 validatorId,
        uint256 amount,
        uint256 delegationPeriod,
        string calldata info
    )
        external;


    function requestUndelegation(uint256 delegationId) external;


    function cancelPendingDelegation(uint delegationId) external;

}// AGPL-3.0-only


pragma solidity 0.6.10;

interface IDistributor {


    function withdrawBounty(uint256 validatorId, address to) external;

}// AGPL-3.0-only


pragma solidity 0.6.10;

interface ITokenState {


    function getAndUpdateLockedAmount(address holder) external returns (uint);

    function getAndUpdateForbiddenForDelegationAmount(address holder) external returns (uint);

}pragma solidity ^0.6.0;

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

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}
pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}
pragma solidity ^0.6.0;


abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}


pragma solidity 0.6.10;

interface IContractManager {

    function getContract(string calldata name) external view returns (address contractAddress);

}


pragma solidity 0.6.10;




contract Permissions is AccessControlUpgradeSafe {

    using SafeMath for uint;
    using Address for address;

    IContractManager public contractManager;

    modifier onlyOwner() {

        require(_isOwner(), "Caller is not the owner");
        _;
    }

    modifier allow(string memory contractName) {

        require(
            contractManager.getContract(contractName) == msg.sender || _isOwner(),
            "Message sender is invalid");
        _;
    }

    function initialize(address contractManagerAddress) public virtual initializer {

        AccessControlUpgradeSafe.__AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setContractManager(contractManagerAddress);
    }

    function _isOwner() internal view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _setContractManager(address contractManagerAddress) private {

        require(contractManagerAddress != address(0), "ContractManager address is not set");
        require(contractManagerAddress.isContract(), "Address is not contract");
        contractManager = IContractManager(contractManagerAddress);
    }
}


pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;





contract Escrow is IERC777Recipient, IERC777Sender, Permissions {


    address private _beneficiary;

    uint256 private _availableAmountAfterTermination;

    IERC1820Registry private _erc1820;

    modifier onlyBeneficiary() {

        require(_msgSender() == _beneficiary, "Message sender is not a plan beneficiary");
        _;
    }

    modifier onlyVestingManager() {

        Allocator allocator = Allocator(contractManager.getContract("Allocator"));
        require(
            allocator.hasRole(allocator.VESTING_MANAGER_ROLE(), _msgSender()),
            "Message sender is not a vesting manager"
        );
        _;
    }

    modifier onlyActiveBeneficiaryOrVestingManager() {

        Allocator allocator = Allocator(contractManager.getContract("Allocator"));
        if (allocator.isVestingActive(_beneficiary)) {
            require(_msgSender() == _beneficiary, "Message sender is not beneficiary");
        } else {
            require(
                allocator.hasRole(allocator.VESTING_MANAGER_ROLE(), _msgSender()),
                "Message sender is not authorized"
            );
        }
        _;
    }   

    function initialize(address contractManagerAddress, address beneficiary) external initializer {

        require(beneficiary != address(0), "Beneficiary address is not set");
        Permissions.initialize(contractManagerAddress);
        _beneficiary = beneficiary;
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensSender"), address(this));
    } 

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external override
        allow("SkaleToken")
    {


    }

    function tokensToSend(
        address,
        address,
        address to,
        uint256,
        bytes calldata,
        bytes calldata
    )
        external override
        allow("SkaleToken")
    {


    }

    function retrieve() external onlyBeneficiary {

        Allocator allocator = Allocator(contractManager.getContract("Allocator"));
        ITokenState tokenState = ITokenState(contractManager.getContract("TokenState"));
        uint256 vestedAmount = 0;
        if (allocator.isVestingActive(_beneficiary)) {
            vestedAmount = allocator.calculateVestedAmount(_beneficiary);
        } else {
            vestedAmount = _availableAmountAfterTermination;
        }
        uint256 escrowBalance = IERC20(contractManager.getContract("SkaleToken")).balanceOf(address(this));
        uint256 fullAmount = allocator.getFullAmount(_beneficiary);
        uint256 forbiddenToSend = tokenState.getAndUpdateForbiddenForDelegationAmount(address(this));
        if (vestedAmount > fullAmount.sub(escrowBalance)) {
            if (vestedAmount.sub(fullAmount.sub(escrowBalance)) > forbiddenToSend)
            require(
                IERC20(contractManager.getContract("SkaleToken")).transfer(
                    _beneficiary,
                    vestedAmount
                        .sub(
                            fullAmount
                                .sub(escrowBalance)
                            )
                        .sub(forbiddenToSend)
                ),
                "Error of token send"
            );
        }
    }

    function retrieveAfterTermination(address destination) external onlyVestingManager {

        Allocator allocator = Allocator(contractManager.getContract("Allocator"));
        ITokenState tokenState = ITokenState(contractManager.getContract("TokenState"));

        require(destination != address(0), "Destination address is not set");
        require(!allocator.isVestingActive(_beneficiary), "Vesting is active");
        uint256 escrowBalance = IERC20(contractManager.getContract("SkaleToken")).balanceOf(address(this));
        uint256 forbiddenToSend = tokenState.getAndUpdateLockedAmount(address(this));
        if (escrowBalance > forbiddenToSend) {
            require(
                IERC20(contractManager.getContract("SkaleToken")).transfer(
                    destination,
                    escrowBalance.sub(forbiddenToSend)
                ),
                "Error of token send"
            );
        }
    }

    function delegate(
        uint256 validatorId,
        uint256 amount,
        uint256 delegationPeriod,
        string calldata info
    )
        external
        onlyBeneficiary
    {

        Allocator allocator = Allocator(contractManager.getContract("Allocator"));
        require(allocator.isDelegationAllowed(_beneficiary), "Delegation is not allowed");
        require(allocator.isVestingActive(_beneficiary), "Beneficiary is not Active");
        
        IDelegationController delegationController = IDelegationController(
            contractManager.getContract("DelegationController")
        );
        delegationController.delegate(validatorId, amount, delegationPeriod, info);
    }

    function requestUndelegation(uint256 delegationId) external onlyActiveBeneficiaryOrVestingManager {

        IDelegationController delegationController = IDelegationController(
            contractManager.getContract("DelegationController")
        );
        delegationController.requestUndelegation(delegationId);
    }

    function cancelPendingDelegation(uint delegationId) external onlyActiveBeneficiaryOrVestingManager {

        IDelegationController delegationController = IDelegationController(
            contractManager.getContract("DelegationController")
        );
        delegationController.cancelPendingDelegation(delegationId);
    }

    function withdrawBounty(uint256 validatorId, address to) external onlyActiveBeneficiaryOrVestingManager {        

        IDistributor distributor = IDistributor(contractManager.getContract("Distributor"));
        distributor.withdrawBounty(validatorId, to);
    }

    function cancelVesting(uint256 vestedAmount) external allow("Allocator") {

        _availableAmountAfterTermination = vestedAmount;
    }
}


pragma solidity 0.6.10;


contract Allocator is Permissions, IERC777Recipient {


    uint256 constant private _SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant private _MONTHS_PER_YEAR = 12;

    enum TimeUnit {
        DAY,
        MONTH,
        YEAR
    }

    enum BeneficiaryStatus {
        UNKNOWN,
        CONFIRMED,
        ACTIVE,
        TERMINATED
    }

    struct Plan {
        uint256 totalVestingDuration; // months
        uint256 vestingCliff; // months
        TimeUnit vestingIntervalTimeUnit;
        uint256 vestingInterval; // amount of days/months/years
        bool isDelegationAllowed;
        bool isTerminatable;
    }

    struct Beneficiary {
        BeneficiaryStatus status;
        uint256 planId;
        uint256 startMonth;
        uint256 fullAmount;
        uint256 amountAfterLockup;
    }

    event PlanCreated(
        uint256 id
    );

    IERC1820Registry private _erc1820;

    Plan[] private _plans;

    bytes32 public constant VESTING_MANAGER_ROLE = keccak256("VESTING_MANAGER_ROLE");

    mapping (address => Beneficiary) private _beneficiaries;

    mapping (address => Escrow) private _beneficiaryToEscrow;

    modifier onlyVestingManager() {

        require(
            hasRole(VESTING_MANAGER_ROLE, _msgSender()),
            "Message sender is not a vesting manager"
        );
        _;
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external override
        allow("SkaleToken")
    {


    }

    function startVesting(address beneficiary) external onlyVestingManager {

        require(
            _beneficiaries[beneficiary].status == BeneficiaryStatus.CONFIRMED,
            "Beneficiary has inappropriate status"
        );
        _beneficiaries[beneficiary].status = BeneficiaryStatus.ACTIVE;
        require(
            IERC20(contractManager.getContract("SkaleToken")).transfer(
                address(_beneficiaryToEscrow[beneficiary]),
                _beneficiaries[beneficiary].fullAmount
            ),
            "Error of token sending"
        );
    }

    function addPlan(
        uint256 vestingCliff, // months
        uint256 totalVestingDuration, // months
        TimeUnit vestingIntervalTimeUnit, // 0 - day 1 - month 2 - year
        uint256 vestingInterval, // months or days or years
        bool canDelegate, // can beneficiary delegate all un-vested tokens
        bool isTerminatable
    )
        external
        onlyVestingManager
    {

        require(totalVestingDuration > 0, "Vesting duration can't be zero");
        require(vestingInterval > 0, "Vesting interval can't be zero");
        require(totalVestingDuration >= vestingCliff, "Cliff period exceeds total vesting duration");
        if (vestingIntervalTimeUnit == TimeUnit.MONTH) {
            uint256 vestingDurationAfterCliff = totalVestingDuration - vestingCliff;
            require(
                vestingDurationAfterCliff.mod(vestingInterval) == 0,
                "Vesting duration can't be divided into equal intervals"
            );
        } else if (vestingIntervalTimeUnit == TimeUnit.YEAR) {
            uint256 vestingDurationAfterCliff = totalVestingDuration - vestingCliff;
            require(
                vestingDurationAfterCliff.mod(vestingInterval.mul(_MONTHS_PER_YEAR)) == 0,
                "Vesting duration can't be divided into equal intervals"
            );
        }
        
        _plans.push(Plan({
            totalVestingDuration: totalVestingDuration,
            vestingCliff: vestingCliff,
            vestingIntervalTimeUnit: vestingIntervalTimeUnit,
            vestingInterval: vestingInterval,
            isDelegationAllowed: canDelegate,
            isTerminatable: isTerminatable
        }));
        emit PlanCreated(_plans.length);
    }

    function connectBeneficiaryToPlan(
        address beneficiary,
        uint256 planId,
        uint256 startMonth,
        uint256 fullAmount,
        uint256 lockupAmount
    )
        external
        onlyVestingManager
    {

        require(_plans.length >= planId && planId > 0, "Plan does not exist");
        require(fullAmount >= lockupAmount, "Incorrect amounts");
        require(_beneficiaries[beneficiary].status == BeneficiaryStatus.UNKNOWN, "Beneficiary is already added");
        if (_plans[planId - 1].vestingIntervalTimeUnit == TimeUnit.DAY) {
            uint256 vestingDurationInDays = _daysBetweenMonths(
                startMonth.add(_plans[planId - 1].vestingCliff),
                startMonth.add(_plans[planId - 1].totalVestingDuration)
            );
            require(
                vestingDurationInDays.mod(_plans[planId - 1].vestingInterval) == 0,
                "Vesting duration can't be divided into equal intervals"
            );
        }
        _beneficiaries[beneficiary] = Beneficiary({
            status: BeneficiaryStatus.CONFIRMED,
            planId: planId,
            startMonth: startMonth,
            fullAmount: fullAmount,
            amountAfterLockup: lockupAmount
        });
        _beneficiaryToEscrow[beneficiary] = _deployEscrow(beneficiary);
    }

    function stopVesting(address beneficiary) external onlyVestingManager {

        require(
            _beneficiaries[beneficiary].status == BeneficiaryStatus.ACTIVE,
            "Cannot stop vesting for a non active beneficiary"
        );
        require(
            _plans[_beneficiaries[beneficiary].planId - 1].isTerminatable,
            "Can't stop vesting for beneficiary with this plan"
        );
        _beneficiaries[beneficiary].status = BeneficiaryStatus.TERMINATED;
        Escrow(_beneficiaryToEscrow[beneficiary]).cancelVesting(calculateVestedAmount(beneficiary));
    }

    function getStartMonth(address beneficiary) external view returns (uint) {

        return _beneficiaries[beneficiary].startMonth;
    }

    function getFinishVestingTime(address beneficiary) external view returns (uint) {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        Beneficiary memory beneficiaryPlan = _beneficiaries[beneficiary];
        Plan memory planParams = _plans[beneficiaryPlan.planId - 1];
        return timeHelpers.monthToTimestamp(beneficiaryPlan.startMonth.add(planParams.totalVestingDuration));
    }

    function getVestingCliffInMonth(address beneficiary) external view returns (uint) {

        return _plans[_beneficiaries[beneficiary].planId - 1].vestingCliff;
    }

    function isVestingActive(address beneficiary) external view returns (bool) {

        return _beneficiaries[beneficiary].status == BeneficiaryStatus.ACTIVE;
    }

    function isBeneficiaryRegistered(address beneficiary) external view returns (bool) {

        return _beneficiaries[beneficiary].status != BeneficiaryStatus.UNKNOWN;
    }

    function isDelegationAllowed(address beneficiary) external view returns (bool) {

        return _plans[_beneficiaries[beneficiary].planId - 1].isDelegationAllowed;
    }

    function getFullAmount(address beneficiary) external view returns (uint) {

        return _beneficiaries[beneficiary].fullAmount;
    }

    function getEscrowAddress(address beneficiary) external view returns (address) {

        return address(_beneficiaryToEscrow[beneficiary]);
    }

    function getLockupPeriodEndTimestamp(address beneficiary) external view returns (uint) {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        Beneficiary memory beneficiaryPlan = _beneficiaries[beneficiary];
        Plan memory planParams = _plans[beneficiaryPlan.planId - 1];
        return timeHelpers.monthToTimestamp(beneficiaryPlan.startMonth.add(planParams.vestingCliff));
    }

    function getTimeOfNextVest(address beneficiary) external view returns (uint) {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));

        Beneficiary memory beneficiaryPlan = _beneficiaries[beneficiary];
        Plan memory planParams = _plans[beneficiaryPlan.planId - 1];

        uint256 firstVestingMonth = beneficiaryPlan.startMonth.add(planParams.vestingCliff);
        uint256 lockupEndTimestamp = timeHelpers.monthToTimestamp(firstVestingMonth);
        if (now < lockupEndTimestamp) {
            return lockupEndTimestamp;
        }
        require(
            now < timeHelpers.monthToTimestamp(beneficiaryPlan.startMonth.add(planParams.totalVestingDuration)),
            "Vesting is over"
        );
        require(beneficiaryPlan.status != BeneficiaryStatus.TERMINATED, "Vesting was stopped");
        
        uint256 currentMonth = timeHelpers.getCurrentMonth();
        if (planParams.vestingIntervalTimeUnit == TimeUnit.DAY) {
            uint daysPassedBeforeCurrentMonth = _daysBetweenMonths(firstVestingMonth, currentMonth);
            uint256 currentMonthBeginningTimestamp = timeHelpers.monthToTimestamp(currentMonth);
            uint256 daysPassedInCurrentMonth = now.sub(currentMonthBeginningTimestamp).div(_SECONDS_PER_DAY);
            uint256 daysPassedBeforeNextVest = _calculateNextVestingStep(
                daysPassedBeforeCurrentMonth.add(daysPassedInCurrentMonth),
                planParams.vestingInterval
            );
            return currentMonthBeginningTimestamp.add(
                daysPassedBeforeNextVest
                    .sub(daysPassedBeforeCurrentMonth)
                    .mul(_SECONDS_PER_DAY)
            );
        } else if (planParams.vestingIntervalTimeUnit == TimeUnit.MONTH) {
            return timeHelpers.monthToTimestamp(
                firstVestingMonth.add(
                    _calculateNextVestingStep(currentMonth.sub(firstVestingMonth), planParams.vestingInterval)
                )
            );
        } else if (planParams.vestingIntervalTimeUnit == TimeUnit.YEAR) {
            return timeHelpers.monthToTimestamp(
                firstVestingMonth.add(
                    _calculateNextVestingStep(
                        currentMonth.sub(firstVestingMonth),
                        planParams.vestingInterval.mul(_MONTHS_PER_YEAR)
                    )
                )
            );
        } else {
            revert("Vesting interval timeunit is incorrect");
        }
    }

    function getPlan(uint256 planId) external view returns (Plan memory) {

        require(planId > 0 && planId <= _plans.length, "Plan Round does not exist");
        return _plans[planId - 1];
    }

    function getBeneficiaryPlanParams(address beneficiary) external view returns (Beneficiary memory) {

        require(_beneficiaries[beneficiary].status != BeneficiaryStatus.UNKNOWN, "Plan beneficiary is not registered");
        return _beneficiaries[beneficiary];
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function calculateVestedAmount(address wallet) public view returns (uint256 vestedAmount) {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        Beneficiary memory beneficiaryPlan = _beneficiaries[wallet];
        Plan memory planParams = _plans[beneficiaryPlan.planId - 1];
        vestedAmount = 0;
        uint256 currentMonth = timeHelpers.getCurrentMonth();
        if (currentMonth >= beneficiaryPlan.startMonth.add(planParams.vestingCliff)) {
            vestedAmount = beneficiaryPlan.amountAfterLockup;
            if (currentMonth >= beneficiaryPlan.startMonth.add(planParams.totalVestingDuration)) {
                vestedAmount = beneficiaryPlan.fullAmount;
            } else {
                uint256 payment = _getSinglePaymentSize(
                    wallet,
                    beneficiaryPlan.fullAmount,
                    beneficiaryPlan.amountAfterLockup
                );
                vestedAmount = vestedAmount.add(payment.mul(_getNumberOfCompletedVestingEvents(wallet)));
            }
        }
    }

    function _getNumberOfCompletedVestingEvents(address wallet) internal view returns (uint) {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        
        Beneficiary memory beneficiaryPlan = _beneficiaries[wallet];
        Plan memory planParams = _plans[beneficiaryPlan.planId - 1];

        uint256 firstVestingMonth = beneficiaryPlan.startMonth.add(planParams.vestingCliff);
        if (now < timeHelpers.monthToTimestamp(firstVestingMonth)) {
            return 0;
        } else {
            uint256 currentMonth = timeHelpers.getCurrentMonth();
            if (planParams.vestingIntervalTimeUnit == TimeUnit.DAY) {
                return _daysBetweenMonths(firstVestingMonth, currentMonth)
                    .add(
                        now
                            .sub(timeHelpers.monthToTimestamp(currentMonth))
                            .div(_SECONDS_PER_DAY)
                    )
                    .div(planParams.vestingInterval);
            } else if (planParams.vestingIntervalTimeUnit == TimeUnit.MONTH) {
                return currentMonth
                    .sub(firstVestingMonth)
                    .div(planParams.vestingInterval);
            } else if (planParams.vestingIntervalTimeUnit == TimeUnit.YEAR) {
                return currentMonth
                    .sub(firstVestingMonth)
                    .div(_MONTHS_PER_YEAR)
                    .div(planParams.vestingInterval);
            } else {
                revert("Unknown time unit");
            }
        }
    }

    function _getNumberOfAllVestingEvents(address wallet) internal view returns (uint) {

        Beneficiary memory beneficiaryPlan = _beneficiaries[wallet];
        Plan memory planParams = _plans[beneficiaryPlan.planId - 1];
        if (planParams.vestingIntervalTimeUnit == TimeUnit.DAY) {
            return _daysBetweenMonths(
                beneficiaryPlan.startMonth.add(planParams.vestingCliff),
                beneficiaryPlan.startMonth.add(planParams.totalVestingDuration)
            ).div(planParams.vestingInterval);
        } else if (planParams.vestingIntervalTimeUnit == TimeUnit.MONTH) {
            return planParams.totalVestingDuration
                .sub(planParams.vestingCliff)
                .div(planParams.vestingInterval);
        } else if (planParams.vestingIntervalTimeUnit == TimeUnit.YEAR) {
            return planParams.totalVestingDuration
                .sub(planParams.vestingCliff)
                .div(_MONTHS_PER_YEAR)
                .div(planParams.vestingInterval);
        } else {
            revert("Unknown time unit");
        }
    }

    function _getSinglePaymentSize(
        address wallet,
        uint256 fullAmount,
        uint256 afterLockupPeriodAmount
    )
        internal
        view
        returns(uint)
    {

        return fullAmount.sub(afterLockupPeriodAmount).div(_getNumberOfAllVestingEvents(wallet));
    }

    function _deployEscrow(address beneficiary) private returns (Escrow) {

        IProxyFactory proxyFactory = IProxyFactory(contractManager.getContract("ProxyFactory"));
        Escrow escrow = Escrow(contractManager.getContract("Escrow"));
        IProxyAdmin proxyAdmin = IProxyAdmin(contractManager.getContract("ProxyAdmin"));

        return Escrow(
            proxyFactory.deploy(
                uint256(bytes32(bytes20(beneficiary))),
                proxyAdmin.getProxyImplementation(address(escrow)),
                address(proxyAdmin),
                abi.encodeWithSelector(
                    Escrow.initialize.selector,
                    address(contractManager),
                    beneficiary
                )
            )
        );
    }

    function _daysBetweenMonths(uint256 beginMonth, uint256 endMonth) private view returns (uint256) {

        assert(beginMonth <= endMonth);
        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        uint256 beginTimestamp = timeHelpers.monthToTimestamp(beginMonth);
        uint256 endTimestamp = timeHelpers.monthToTimestamp(endMonth);
        uint256 secondsPassed = endTimestamp.sub(beginTimestamp);
        require(secondsPassed.mod(_SECONDS_PER_DAY) == 0, "Internal error in calendar");
        return secondsPassed.div(_SECONDS_PER_DAY);
    }

    function _calculateNextVestingStep(uint256 currentStep, uint256 vestingInterval) private pure returns (uint256) {

        return currentStep
            .add(vestingInterval)
            .sub(
                currentStep.mod(vestingInterval)
            );
    }
}