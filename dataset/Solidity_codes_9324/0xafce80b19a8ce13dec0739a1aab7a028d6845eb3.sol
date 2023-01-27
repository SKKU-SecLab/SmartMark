
pragma solidity 0.5.16;

interface INexus {

    function governor() external view returns (address);

    function getModule(bytes32 key) external view returns (address);


    function proposeModule(bytes32 _key, address _addr) external;

    function cancelProposedModule(bytes32 _key) external;

    function acceptProposedModule(bytes32 _key) external;

    function acceptProposedModules(bytes32[] calldata _keys) external;


    function requestLockModule(bytes32 _key) external;

    function cancelLockModule(bytes32 _key) external;

    function lockModule(bytes32 _key) external;

}

contract Governable {


    event GovernorChanged(address indexed previousGovernor, address indexed newGovernor);

    address private _governor;


    constructor () internal {
        _governor = msg.sender;
        emit GovernorChanged(address(0), _governor);
    }

    function governor() public view returns (address) {

        return _governor;
    }

    modifier onlyGovernor() {

        require(isGovernor(), "GOV: caller is not the Governor");
        _;
    }

    function isGovernor() public view returns (bool) {

        return msg.sender == _governor;
    }

    function changeGovernor(address _newGovernor) external onlyGovernor {

        _changeGovernor(_newGovernor);
    }

    function _changeGovernor(address _newGovernor) internal {

        require(_newGovernor != address(0), "GOV: new Governor is address(0)");
        emit GovernorChanged(_governor, _newGovernor);
        _governor = _newGovernor;
    }
}

contract ClaimableGovernor is Governable {


    event GovernorChangeClaimed(address indexed proposedGovernor);
    event GovernorChangeCancelled(address indexed governor, address indexed proposed);
    event GovernorChangeRequested(address indexed governor, address indexed proposed);

    address public proposedGovernor = address(0);

    modifier onlyProposedGovernor() {

        require(msg.sender == proposedGovernor, "Sender is not proposed governor");
        _;
    }

    constructor(address _governorAddr) public {
        _changeGovernor(_governorAddr);
    }

    function changeGovernor(address) external onlyGovernor {

        revert("Direct change not allowed");
    }

    function requestGovernorChange(address _proposedGovernor) public onlyGovernor {

        require(_proposedGovernor != address(0), "Proposed governor is address(0)");
        require(proposedGovernor == address(0), "Proposed governor already set");

        proposedGovernor = _proposedGovernor;
        emit GovernorChangeRequested(governor(), _proposedGovernor);
    }

    function cancelGovernorChange() public onlyGovernor {

        require(proposedGovernor != address(0), "Proposed Governor not set");

        emit GovernorChangeCancelled(governor(), proposedGovernor);
        proposedGovernor = address(0);
    }

    function claimGovernorChange() public onlyProposedGovernor {

        _changeGovernor(proposedGovernor);
        emit GovernorChangeClaimed(proposedGovernor);
        proposedGovernor = address(0);
    }
}
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

contract DelayedClaimableGovernor is ClaimableGovernor {


    using SafeMath for uint256;

    uint256 public delay = 0;
    uint256 public requestTime = 0;

    constructor(address _governorAddr, uint256 _delay)
        public
        ClaimableGovernor(_governorAddr)
    {
        require(_delay > 0, "Delay must be greater than zero");
        delay = _delay;
    }

    function requestGovernorChange(address _proposedGovernor) public onlyGovernor {

        requestTime = now;
        super.requestGovernorChange(_proposedGovernor);
    }

    function cancelGovernorChange() public onlyGovernor {

        requestTime = 0;
        super.cancelGovernorChange();
    }

    function claimGovernorChange() public onlyProposedGovernor {

        require(now >= (requestTime.add(delay)), "Delay not over");
        super.claimGovernorChange();
        requestTime = 0;
    }
}

contract Nexus is INexus, DelayedClaimableGovernor {


    event ModuleProposed(bytes32 indexed key, address addr, uint256 timestamp);
    event ModuleAdded(bytes32 indexed key, address addr, bool isLocked);
    event ModuleCancelled(bytes32 indexed key);
    event ModuleLockRequested(bytes32 indexed key, uint256 timestamp);
    event ModuleLockEnabled(bytes32 indexed key);
    event ModuleLockCancelled(bytes32 indexed key);

    struct Module {
        address addr;       // Module address
        bool isLocked;      // Module lock status
    }

    struct Proposal {
        address newAddress; // Proposed Module address
        uint256 timestamp;  // Timestamp when module upgrade was proposed
    }

    uint256 public constant UPGRADE_DELAY = 1 weeks;

    mapping(bytes32 => Module) public modules;
    mapping(address => bytes32) private addressToModule;
    mapping(bytes32 => Proposal) public proposedModules;
    mapping(bytes32 => uint256) public proposedLockModules;

    bool public initialized = false;

    modifier whenNotInitialized() {

        require(!initialized, "Nexus is already initialized");
        _;
    }

    constructor(address _governorAddr)
        public
        DelayedClaimableGovernor(_governorAddr, UPGRADE_DELAY)
    {}

    function initialize(
        bytes32[] calldata _keys,
        address[] calldata _addresses,
        bool[] calldata _isLocked,
        address _governorAddr
    )
        external
        onlyGovernor
        whenNotInitialized
        returns (bool)
    {

        uint256 len = _keys.length;
        require(len > 0, "No keys provided");
        require(len == _addresses.length, "Insufficient address data");
        require(len == _isLocked.length, "Insufficient locked statuses");

        for(uint256 i = 0 ; i < len; i++) {
            _publishModule(_keys[i], _addresses[i], _isLocked[i]);
        }

        if(_governorAddr != governor()) _changeGovernor(_governorAddr);

        initialized = true;
        return true;
    }


    function proposeModule(bytes32 _key, address _addr)
        external
        onlyGovernor
    {

        require(_key != bytes32(0x0), "Key must not be zero");
        require(_addr != address(0), "Module address must not be 0");
        require(!modules[_key].isLocked, "Module must be unlocked");
        require(modules[_key].addr != _addr, "Module already has same address");
        Proposal storage p = proposedModules[_key];
        require(p.timestamp == 0, "Module already proposed");

        p.newAddress = _addr;
        p.timestamp = now;
        emit ModuleProposed(_key, _addr, now);
    }

    function cancelProposedModule(bytes32 _key)
        external
        onlyGovernor
    {

        uint256 timestamp = proposedModules[_key].timestamp;
        require(timestamp > 0, "Proposed module not found");

        delete proposedModules[_key];
        emit ModuleCancelled(_key);
    }

    function acceptProposedModule(bytes32 _key)
        external
        onlyGovernor
    {

        _acceptProposedModule(_key);
    }

    function acceptProposedModules(bytes32[] calldata _keys)
        external
        onlyGovernor
    {

        uint256 len = _keys.length;
        require(len > 0, "Keys array empty");

        for(uint256 i = 0 ; i < len; i++) {
            _acceptProposedModule(_keys[i]);
        }
    }

    function _acceptProposedModule(bytes32 _key) internal {

        Proposal memory p = proposedModules[_key];
        require(_isDelayOver(p.timestamp), "Module upgrade delay not over");

        delete proposedModules[_key];
        _publishModule(_key, p.newAddress, false);
    }

    function _publishModule(bytes32 _key, address _addr, bool _isLocked) internal {

        require(addressToModule[_addr] == bytes32(0x0), "Modules must have unique addr");
        require(!modules[_key].isLocked, "Module must be unlocked");
        address oldModuleAddr = modules[_key].addr;
        if(oldModuleAddr != address(0x0)) {
            addressToModule[oldModuleAddr] = bytes32(0x0);
        }
        modules[_key].addr = _addr;
        modules[_key].isLocked = _isLocked;
        addressToModule[_addr] = _key;
        emit ModuleAdded(_key, _addr, _isLocked);
    }


    function requestLockModule(bytes32 _key)
        external
        onlyGovernor
    {

        require(moduleExists(_key), "Module must exist");
        require(!modules[_key].isLocked, "Module must be unlocked");
        require(proposedLockModules[_key] == 0, "Lock already proposed");

        proposedLockModules[_key] = now;
        emit ModuleLockRequested(_key, now);
    }

    function cancelLockModule(bytes32 _key)
        external
        onlyGovernor
    {

        require(proposedLockModules[_key] > 0, "Module lock request not found");

        delete proposedLockModules[_key];
        emit ModuleLockCancelled(_key);
    }

    function lockModule(bytes32 _key)
        external
        onlyGovernor
    {

        require(_isDelayOver(proposedLockModules[_key]), "Delay not over");

        modules[_key].isLocked = true;
        delete proposedLockModules[_key];
        emit ModuleLockEnabled(_key);
    }


    function moduleExists(bytes32 _key) public view returns (bool) {

        if(_key != 0 && modules[_key].addr != address(0))
            return true;
        return false;
    }

    function getModule(bytes32 _key) external view returns (address addr) {

        addr = modules[_key].addr;
    }

    function _isDelayOver(uint256 _timestamp) private view returns (bool) {

        if(_timestamp > 0 && now >= _timestamp.add(UPGRADE_DELAY))
            return true;
        return false;
    }
}