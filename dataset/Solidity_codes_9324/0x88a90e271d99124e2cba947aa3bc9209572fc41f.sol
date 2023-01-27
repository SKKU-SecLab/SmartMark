
pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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
}pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}pragma solidity >=0.5.0;

interface ITomiStaking {

    function updateRevenueShare(uint256 revenueShared) external;

}pragma solidity >=0.5.0;

interface ITomiConfig {

    function governor() external view returns (address);

    function dev() external view returns (address);

    function PERCENT_DENOMINATOR() external view returns (uint);

    function getConfig(bytes32 _name) external view returns (uint minValue, uint maxValue, uint maxSpan, uint value, uint enable);

    function getConfigValue(bytes32 _name) external view returns (uint);

    function changeConfigValue(bytes32 _name, uint _value) external returns (bool);

    function checkToken(address _token) external view returns(bool);

    function checkPair(address tokenA, address tokenB) external view returns (bool);

    function listToken(address _token) external returns (bool);

    function getDefaultListTokens() external returns (address[] memory);

    function platform() external view returns  (address);

    function addToken(address _token) external returns (bool);

}pragma solidity >=0.5.0;

interface ITomiBallotFactory {

    function create(
        address _proposer,
        uint _value,
        uint _endTime,
        uint _executionTime,
        string calldata _subject,
        string calldata _content
    ) external returns (address);


     function createShareRevenue(
        address _proposer,
        uint _endTime,
        uint _executionTime,
        string calldata _subject,
        string calldata _content
    ) external returns (address);

}pragma solidity >=0.5.0;

interface ITomiBallot {

    function proposer() external view returns(address);

    function endTime() external view returns(uint);

    function executionTime() external view returns(uint);

    function value() external view returns(uint);

    function result() external view returns(bool);

    function end() external returns (bool);

    function total() external view returns(uint);

    function weight(address user) external view returns (uint);

    function voteByGovernor(address user, uint256 proposal) external;

}pragma solidity >=0.5.0;

interface ITomiBallotRevenue {

    function proposer() external view returns(address);

    function endTime() external view returns(uint);

    function executionTime() external view returns(uint);

    function end() external returns (bool);

    function total() external view returns(uint);

    function weight(address user) external view returns (uint);

    function participateByGovernor(address user) external;

}pragma solidity >=0.5.0;

interface ITgas {

    function amountPerBlock() external view returns (uint);

    function changeInterestRatePerBlock(uint value) external returns (bool);

    function getProductivity(address user) external view returns (uint, uint);

    function increaseProductivity(address user, uint value) external returns (bool);

    function decreaseProductivity(address user, uint value) external returns (bool);

    function take() external view returns (uint);

    function takeWithBlock() external view returns (uint, uint);

    function mint() external returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function upgradeImpl(address _newImpl) external;

    function upgradeGovernance(address _newGovernor) external;

    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

}pragma solidity >=0.5.16;

interface ITokenRegistry {

    function tokenStatus(address _token) external view returns(uint);

    function pairStatus(address tokenA, address tokenB) external view returns (uint);

    function NONE() external view returns(uint);

    function REGISTERED() external view returns(uint);

    function PENDING() external view returns(uint);

    function OPENED() external view returns(uint);

    function CLOSED() external view returns(uint);

    function registryToken(address _token) external returns (bool);

    function publishToken(address _token) external returns (bool);

    function updateToken(address _token, uint _status) external returns (bool);

    function updatePair(address tokenA, address tokenB, uint _status) external returns (bool);

    function tokenCount() external view returns(uint);

    function validTokens() external view returns(address[] memory);

    function iterateValidTokens(uint32 _start, uint32 _end) external view returns (address[] memory);

}pragma solidity >=0.5.16;

library ConfigNames {

    bytes32 public constant PRODUCE_TGAS_RATE = bytes32('PRODUCE_TGAS_RATE');
    bytes32 public constant SWAP_FEE_PERCENT = bytes32('SWAP_FEE_PERCENT');
    bytes32 public constant LIST_TGAS_AMOUNT = bytes32('LIST_TGAS_AMOUNT');
    bytes32 public constant UNSTAKE_DURATION = bytes32('UNSTAKE_DURATION');
    bytes32 public constant REMOVE_LIQUIDITY_DURATION = bytes32('REMOVE_LIQUIDITY_DURATION');
    bytes32 public constant TOKEN_TO_TGAS_PAIR_MIN_PERCENT = bytes32('TOKEN_TO_TGAS_PAIR_MIN_PERCENT');
    bytes32 public constant LIST_TOKEN_FAILURE_BURN_PRECENT = bytes32('LIST_TOKEN_FAILURE_BURN_PRECENT');
    bytes32 public constant LIST_TOKEN_SUCCESS_BURN_PRECENT = bytes32('LIST_TOKEN_SUCCESS_BURN_PRECENT');
    bytes32 public constant PROPOSAL_TGAS_AMOUNT = bytes32('PROPOSAL_TGAS_AMOUNT');
    bytes32 public constant VOTE_REWARD_PERCENT = bytes32('VOTE_REWARD_PERCENT');
    bytes32 public constant TOKEN_PENGDING_SWITCH = bytes32('TOKEN_PENGDING_SWITCH');
    bytes32 public constant TOKEN_PENGDING_TIME = bytes32('TOKEN_PENGDING_TIME');
    bytes32 public constant LIST_TOKEN_SWITCH = bytes32('LIST_TOKEN_SWITCH');
    bytes32 public constant DEV_PRECENT = bytes32('DEV_PRECENT');
    bytes32 public constant FEE_GOVERNANCE_REWARD_PERCENT = bytes32('FEE_GOVERNANCE_REWARD_PERCENT');
    bytes32 public constant FEE_LP_REWARD_PERCENT = bytes32('FEE_LP_REWARD_PERCENT');
    bytes32 public constant FEE_FUNDME_REWARD_PERCENT = bytes32('FEE_FUNDME_REWARD_PERCENT');
    bytes32 public constant FEE_LOTTERY_REWARD_PERCENT = bytes32('FEE_LOTTERY_REWARD_PERCENT');
    bytes32 public constant FEE_STAKING_REWARD_PERCENT = bytes32('FEE_STAKING_REWARD_PERCENT');
}// GPL-3.0-or-later

pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// MIT

pragma solidity >=0.6.6;

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
}pragma solidity >=0.5.16;

contract BaseToken {

    address public baseToken;

    function initBaseToken(address _baseToken) internal {

        require(baseToken == address(0), 'INITIALIZED');
        require(_baseToken != address(0), 'ADDRESS_IS_ZERO');
        baseToken = _baseToken;  // it should be tgas token address
    }
}pragma solidity >=0.5.16;



contract TgasStaking is BaseToken {

    using SafeMath for uint;

    uint public lockTime;
    uint public totalSupply;
    uint public stakingSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public allowance;

    constructor (address _baseToken) public {
        initBaseToken(_baseToken);
    }

    function estimateLocktime(address user, uint _endTime) internal view returns(uint) {

        uint collateralLocktime = allowance[user];

        if (_endTime == 0) {
            uint depositLockTime = block.timestamp + lockTime;
            return depositLockTime > collateralLocktime ? depositLockTime: collateralLocktime;
        }

        return _endTime > collateralLocktime ? _endTime: collateralLocktime; 
    }

    function _add(address user, uint value, uint endTime) internal {

        require(value > 0, 'ZERO');
        balanceOf[user] = balanceOf[user].add(value);
        stakingSupply = stakingSupply.add(value);
        allowance[user] = estimateLocktime(user, endTime);
    }

    function _reduce(address user, uint value) internal {

        require(balanceOf[user] >= value && value > 0, 'TgasStaking: INSUFFICIENT_BALANCE');
        balanceOf[user] = balanceOf[user].sub(value);
        stakingSupply = stakingSupply.sub(value);
    }

    function deposit(uint _amount) external returns (bool) {

        TransferHelper.safeTransferFrom(baseToken, msg.sender, address(this), _amount);
        _add(msg.sender, _amount, 0);
        totalSupply = IERC20(baseToken).balanceOf(address(this));
        return true;
    }


    function withdraw(uint _amount) external returns (bool) {

        require(block.timestamp > allowance[msg.sender], 'TgasStaking: NOT_DUE');
        TransferHelper.safeTransfer(baseToken, msg.sender, _amount);
        _reduce(msg.sender, _amount);
        totalSupply = IERC20(baseToken).balanceOf(address(this));
        return true;
    }

}pragma solidity >=0.5.16;

contract Ownable {

    address public owner;

    event OwnerChanged(address indexed _oldOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, 'Ownable: FORBIDDEN');
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), 'Ownable: INVALID_ADDRESS');
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

}// MIT
pragma solidity >=0.6.6;



contract TomiGovernance is TgasStaking, Ownable, AccessControl {

    using SafeMath for uint;

    uint public version = 1;
    address public configAddr;
    address public ballotFactoryAddr;
    address public rewardAddr;
    address public stakingAddr;

    uint public T_CONFIG = 1;
    uint public T_LIST_TOKEN = 2;
    uint public T_TOKEN = 3;
    uint public T_SNAPSHOT = 4;
    uint public T_REVENUE = 5;

    uint public VOTE_DURATION;
    uint public FREEZE_DURATION;
    uint public REVENUE_VOTE_DURATION;
    uint public REVENUE_FREEZE_DURATION;
    uint public MINIMUM_TOMI_REQUIRED_IN_BALANCE = 100e18;

    bytes32 public constant SUPER_ADMIN_ROLE = keccak256(abi.encodePacked("SUPER_ADMIN_ROLE"));
    bytes32 REVENUE_PROPOSAL = bytes32('REVENUE_PROPOSAL');
    bytes32 SNAPSHOT_PROPOSAL = bytes32('SNAPSHOT_PROPOSAL');

    mapping(address => uint) public ballotTypes;
    mapping(address => bytes32) public configBallots;
    mapping(address => address) public tokenBallots;
    mapping(address => uint) public rewardOf;
    mapping(address => uint) public ballotOf;
    mapping(address => mapping(address => uint)) public applyTokenOf;
    mapping(address => mapping(address => bool)) public collectUsers;
    mapping(address => address) public tokenUsers;

    address[] public ballots;
    address[] public revenueBallots;

    event ConfigAudited(bytes32 name, address indexed ballot, uint proposal);
    event ConfigBallotCreated(address indexed proposer, bytes32 name, uint value, address indexed ballotAddr, uint reward);
    event TokenBallotCreated(address indexed proposer, address indexed token, uint value, address indexed ballotAddr, uint reward);
    event ProposalerRewardRateUpdated(uint oldVaue, uint newValue);
    event RewardTransfered(address indexed from, address indexed to, uint value);
    event TokenListed(address user, address token, uint amount);
    event ListTokenAudited(address user, address token, uint status, uint burn, uint reward, uint refund);
    event TokenAudited(address user, address token, uint status, bool result);
    event RewardCollected(address indexed user, address indexed ballot, uint value);
    event RewardReceived(address indexed user, uint value);

    modifier onlyRewarder() {

        require(msg.sender == rewardAddr, 'TomiGovernance: ONLY_REWARDER');
        _;
    }

    modifier onlyRole(bytes32 role) {

        require(hasRole(role, msg.sender), "TomiGovernance: sender not allowed to do!");
        _;
    }

    constructor (
        address _tgas, 
        uint _VOTE_DURATION,
        uint _FREEZE_DURATION,
        uint _REVENUE_VOTE_DURATION,
        uint _REVENUE_FREEZE_DURATION
    ) TgasStaking(_tgas) public {
        _setupRole(SUPER_ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, SUPER_ADMIN_ROLE);

        VOTE_DURATION = _VOTE_DURATION;
        FREEZE_DURATION = _FREEZE_DURATION;
        REVENUE_VOTE_DURATION = _REVENUE_VOTE_DURATION;
        REVENUE_FREEZE_DURATION = _REVENUE_FREEZE_DURATION;
    }

    function initialize(address _rewardAddr, address _configContractAddr, address _ballotFactoryAddr, address _stakingAddr) external onlyOwner {

        require(_rewardAddr != address(0) && _configContractAddr != address(0) && _ballotFactoryAddr != address(0) && _stakingAddr != address(0), 'TomiGovernance: INPUT_ADDRESS_IS_ZERO');

        stakingAddr = _stakingAddr;
        rewardAddr = _rewardAddr;
        configAddr = _configContractAddr;
        ballotFactoryAddr = _ballotFactoryAddr;
        lockTime = getConfigValue(ConfigNames.UNSTAKE_DURATION);
    }

    function newStakingSettle(address _STAKING) external onlyRole(SUPER_ADMIN_ROLE) {

        require(stakingAddr != _STAKING, "STAKING ADDRESS IS THE SAME");
        require(_STAKING != address(0), "STAKING ADDRESS IS DEFAULT ADDRESS");
        stakingAddr = _STAKING;
    }

    function changeProposalDuration(uint[4] calldata _durations) external onlyRole(SUPER_ADMIN_ROLE) {

        VOTE_DURATION = _durations[0];
        FREEZE_DURATION = _durations[1];
        REVENUE_VOTE_DURATION = _durations[2];
        REVENUE_FREEZE_DURATION = _durations[3];
    }

    function changeTomiMinimumRequired(uint _newMinimum) external onlyRole(SUPER_ADMIN_ROLE) {

        require(_newMinimum != MINIMUM_TOMI_REQUIRED_IN_BALANCE, "TomiGovernance::Tomi required is identical!");
        MINIMUM_TOMI_REQUIRED_IN_BALANCE = _newMinimum;
    }





    function vote(address _ballot, uint256 _proposal, uint256 _collateral) external {

        require(configBallots[_ballot] != REVENUE_PROPOSAL, "TomiGovernance::Fail due to wrong ballot");
        uint256 collateralRemain = balanceOf[msg.sender]; 

        if (_collateral > collateralRemain) {
            uint256 collateralMore = _collateral.sub(collateralRemain);
            _transferForBallot(collateralMore, true, ITomiBallot(_ballot).executionTime());
        }

        ITomiBallot(_ballot).voteByGovernor(msg.sender, _proposal);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_collateral);

        _transferToStaking(_collateral);
    }

    function participate(address _ballot, uint256 _collateral) external {

        require(configBallots[_ballot] == REVENUE_PROPOSAL, "TomiGovernance::Fail due to wrong ballot");
        
        uint256 collateralRemain = balanceOf[msg.sender];
        uint256 collateralMore = _collateral.sub(collateralRemain);

        _transferForBallot(collateralMore, true, ITomiBallot(_ballot).executionTime());
        ITomiBallotRevenue(_ballot).participateByGovernor(msg.sender);
    }

    function audit(address _ballot) external returns (bool) {

        if(ballotTypes[_ballot] == T_CONFIG) {
            return auditConfig(_ballot);
        } else if (ballotTypes[_ballot] == T_LIST_TOKEN) {
            return auditListToken(_ballot);
        } else if (ballotTypes[_ballot] == T_TOKEN) {
            return auditToken(_ballot);
        } else {
            revert('TomiGovernance: UNKNOWN_TYPE');
        }
    }

    function auditConfig(address _ballot) public returns (bool) {

        bool result = ITomiBallot(_ballot).end();
        require(result, 'TomiGovernance: NO_PASS');
        uint value = ITomiBallot(_ballot).value();
        bytes32 name = configBallots[_ballot];
        result = ITomiConfig(configAddr).changeConfigValue(name, value);
        if (name == ConfigNames.UNSTAKE_DURATION) {
            lockTime = value;
        } else if (name == ConfigNames.PRODUCE_TGAS_RATE) {
            _changeAmountPerBlock(value);
        }
        emit ConfigAudited(name, _ballot, value);
        return result;
    }

    function auditListToken(address _ballot) public returns (bool) {

        bool result = ITomiBallot(_ballot).end();
        address token = tokenBallots[_ballot];
        address user = tokenUsers[token];
        require(ITokenRegistry(configAddr).tokenStatus(token) == ITokenRegistry(configAddr).REGISTERED(), 'TomiGovernance: AUDITED');
        uint status = result ? ITokenRegistry(configAddr).PENDING() : ITokenRegistry(configAddr).CLOSED();
	    uint amount = applyTokenOf[user][token];
        (uint burnAmount, uint rewardAmount, uint refundAmount) = (0, 0, 0);
        if (result) {
            burnAmount = amount * getConfigValue(ConfigNames.LIST_TOKEN_SUCCESS_BURN_PRECENT) / ITomiConfig(configAddr).PERCENT_DENOMINATOR();
            rewardAmount = amount - burnAmount;
            if (burnAmount > 0) {
                TransferHelper.safeTransfer(baseToken, address(0), burnAmount);
                totalSupply = totalSupply.sub(burnAmount);
            }
            if (rewardAmount > 0) {
                rewardOf[rewardAddr] = rewardOf[rewardAddr].add(rewardAmount);
                ballotOf[_ballot] = ballotOf[_ballot].add(rewardAmount);
                _rewardTransfer(rewardAddr, _ballot, rewardAmount);
            }
            ITokenRegistry(configAddr).publishToken(token);
        } else {
            burnAmount = amount * getConfigValue(ConfigNames.LIST_TOKEN_FAILURE_BURN_PRECENT) / ITomiConfig(configAddr).PERCENT_DENOMINATOR();
            refundAmount = amount - burnAmount;
            if (burnAmount > 0) TransferHelper.safeTransfer(baseToken, address(0), burnAmount);
            if (refundAmount > 0) TransferHelper.safeTransfer(baseToken, user, refundAmount);
            totalSupply = totalSupply.sub(amount);
            ITokenRegistry(configAddr).updateToken(token, status);
        }
	    emit ListTokenAudited(user, token, status, burnAmount, rewardAmount, refundAmount);
        return result;
    }

    function auditToken(address _ballot) public returns (bool) {

        bool result = ITomiBallot(_ballot).end();
        uint status = ITomiBallot(_ballot).value();
        address token = tokenBallots[_ballot];
        address user = tokenUsers[token];
        require(ITokenRegistry(configAddr).tokenStatus(token) != status, 'TomiGovernance: TOKEN_STATUS_NO_CHANGE');
        if (result) {
            ITokenRegistry(configAddr).updateToken(token, status);
        } else {
            status = ITokenRegistry(configAddr).tokenStatus(token);
        }
	    emit TokenAudited(user, token, status, result);
        return result;
    }

    function getConfigValue(bytes32 _name) public view returns (uint) {

        return ITomiConfig(configAddr).getConfigValue(_name);
    }

    function _createProposalPrecondition(uint _amount, uint _executionTime) private {

        address sender = msg.sender;
        if (!hasRole(DEFAULT_ADMIN_ROLE, sender)) {
            require(IERC20(baseToken).balanceOf(sender).add(balanceOf[sender]) >= MINIMUM_TOMI_REQUIRED_IN_BALANCE, "TomiGovernance::Require minimum TOMI in balance");
            require(_amount >= getConfigValue(ConfigNames.PROPOSAL_TGAS_AMOUNT), "TomiGovernance: NOT_ENOUGH_AMOUNT_TO_PROPOSAL");
            
            uint256 collateralRemain = balanceOf[sender];

            if (_amount > collateralRemain) {
                uint256 collateralMore = _amount.sub(collateralRemain);
                _transferForBallot(collateralMore, true, _executionTime);
            } 

            collateralRemain = balanceOf[sender];
            
            require(collateralRemain >= getConfigValue(ConfigNames.PROPOSAL_TGAS_AMOUNT), "TomiGovernance: COLLATERAL_NOT_ENOUGH_AMOUNT_TO_PROPOSAL");
            balanceOf[sender] = collateralRemain.sub(_amount);

            _transferToStaking(_amount);
        }
    }

    function createRevenueBallot(
        string calldata _subject, 
        string calldata _content
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (address) {

        uint endTime = block.timestamp.add(REVENUE_VOTE_DURATION);
        uint executionTime = endTime.add(REVENUE_FREEZE_DURATION);

        address ballotAddr = ITomiBallotFactory(ballotFactoryAddr).createShareRevenue(msg.sender, endTime, executionTime, _subject, _content);
        configBallots[ballotAddr] = REVENUE_PROPOSAL;
        uint reward = _createdBallot(ballotAddr, T_REVENUE);
        emit ConfigBallotCreated(msg.sender, REVENUE_PROPOSAL, 0, ballotAddr, reward);
        return ballotAddr;
    }

    function createSnapshotBallot(
        uint _amount, 
        string calldata _subject, 
        string calldata _content
    ) external returns (address) {

        uint endTime = block.timestamp.add(VOTE_DURATION);
        uint executionTime = endTime.add(FREEZE_DURATION);

        _createProposalPrecondition(_amount, executionTime);

        address ballotAddr = ITomiBallotFactory(ballotFactoryAddr).create(msg.sender, 0, endTime, executionTime, _subject, _content);
        
        configBallots[ballotAddr] = SNAPSHOT_PROPOSAL;

        uint reward = _createdBallot(ballotAddr, T_SNAPSHOT);
        emit ConfigBallotCreated(msg.sender, SNAPSHOT_PROPOSAL, 0, ballotAddr, reward);
        return ballotAddr;
    }

    function createConfigBallot(bytes32 _name, uint _value, uint _amount, string calldata _subject, string calldata _content) external returns (address) {

        require(_value >= 0, 'TomiGovernance: INVALID_PARAMTERS');
        { // avoids stack too deep errors
        (uint minValue, uint maxValue, uint maxSpan, uint value, uint enable) = ITomiConfig(configAddr).getConfig(_name);
        require(enable == 1, "TomiGovernance: CONFIG_DISABLE");
        require(_value >= minValue && _value <= maxValue, "TomiGovernance: OUTSIDE");
        uint span = _value >= value? (_value - value) : (value - _value);
        require(maxSpan >= span, "TomiGovernance: OVERSTEP");
        }

        uint endTime = block.timestamp.add(VOTE_DURATION);
        uint executionTime = endTime.add(FREEZE_DURATION);

        _createProposalPrecondition(_amount, executionTime);
        
        address ballotAddr = ITomiBallotFactory(ballotFactoryAddr).create(msg.sender, _value, endTime, executionTime, _subject, _content);
        
        configBallots[ballotAddr] = _name;

        uint reward = _createdBallot(ballotAddr, T_CONFIG);
        emit ConfigBallotCreated(msg.sender, _name, _value, ballotAddr, reward);
        return ballotAddr;
    }

    function createTokenBallot(address _token, uint _value, uint _amount, string calldata _subject, string calldata _content) external returns (address) {

        require(!_isDefaultToken(_token), 'TomiGovernance: DEFAULT_LIST_TOKENS_PROPOSAL_DENY');
        uint status = ITokenRegistry(configAddr).tokenStatus(_token);
        require(status == ITokenRegistry(configAddr).PENDING(), 'TomiGovernance: ONLY_ALLOW_PENDING');
        require(_value == ITokenRegistry(configAddr).OPENED() || _value == ITokenRegistry(configAddr).CLOSED(), 'TomiGovernance: INVALID_STATUS');
        require(status != _value, 'TomiGovernance: STATUS_NO_CHANGE');

        uint endTime = block.timestamp.add(VOTE_DURATION);
        uint executionTime = endTime.add(FREEZE_DURATION);

        _createProposalPrecondition(_amount, executionTime);

        address ballotAddr = _createTokenBallot(T_TOKEN, _token, _value, _subject, _content, endTime, executionTime);
        return ballotAddr;
    }

	function listToken(address _token, uint _amount, string calldata _subject, string calldata _content) external returns (address) {

        uint status = ITokenRegistry(configAddr).tokenStatus(_token);
        require(status == ITokenRegistry(configAddr).NONE() || status == ITokenRegistry(configAddr).CLOSED(), 'TomiGovernance: LISTED');
	    tokenUsers[_token] = msg.sender;

        uint endTime = block.timestamp.add(VOTE_DURATION);
        uint executionTime = endTime.add(FREEZE_DURATION);

        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            require(_amount >= getConfigValue(ConfigNames.PROPOSAL_TGAS_AMOUNT), "TomiGovernance: NOT_ENOUGH_AMOUNT_TO_PROPOSAL");
            
            uint256 collateralRemain = balanceOf[msg.sender]; 
            uint256 collateralMore = _amount.sub(collateralRemain);
            
            applyTokenOf[msg.sender][_token] = _transferForBallot(collateralMore, true, executionTime);
            collateralRemain = balanceOf[msg.sender];

            require(collateralRemain >= getConfigValue(ConfigNames.PROPOSAL_TGAS_AMOUNT), "TomiGovernance: COLLATERAL_NOT_ENOUGH_AMOUNT_TO_PROPOSAL");
            balanceOf[msg.sender] = collateralRemain.sub(_amount);

            _transferToStaking(_amount);
        }

	    ITokenRegistry(configAddr).registryToken(_token);
        address ballotAddr = _createTokenBallot(T_LIST_TOKEN, _token, ITokenRegistry(configAddr).PENDING(), _subject, _content, endTime, executionTime);
        emit TokenListed(msg.sender, _token, _amount);
        return ballotAddr;
	}

    function _createTokenBallot(uint _type, address _token, uint _value, string memory _subject, string memory _content, uint _endTime, uint _executionTime) private returns (address) {

        address ballotAddr = ITomiBallotFactory(ballotFactoryAddr).create(msg.sender, _value, _endTime, _executionTime, _subject, _content);
        
        uint reward = _createdBallot(ballotAddr, _type);
        ballotOf[ballotAddr] = reward;
        tokenBallots[ballotAddr] = _token;
        emit TokenBallotCreated(msg.sender, _token, _value, ballotAddr, reward);
        return ballotAddr;
    }

    function collectReward(address _ballot) external returns (uint) {

        require(block.timestamp >= ITomiBallot(_ballot).endTime(), "TomiGovernance: NOT_YET_ENDED");
        require(!collectUsers[_ballot][msg.sender], 'TomiGovernance: REWARD_COLLECTED');
        require(configBallots[_ballot] == REVENUE_PROPOSAL, "TomiGovernance::Fail due to wrong ballot");
        
        uint amount = getRewardForRevenueProposal(_ballot);
        _rewardTransfer(_ballot, msg.sender, amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        stakingSupply = stakingSupply.add(amount);
        rewardOf[msg.sender] = rewardOf[msg.sender].sub(amount);
        collectUsers[_ballot][msg.sender] = true;
       
        emit RewardCollected(msg.sender, _ballot, amount);
    }





    function getRewardForRevenueProposal(address _ballot) public view returns (uint) {

        if (block.timestamp < ITomiBallotRevenue(_ballot).endTime() || collectUsers[_ballot][msg.sender]) {
            return 0;
        }
        
        uint amount = 0;
        uint shares = ballotOf[_ballot];

        if (ITomiBallotRevenue(_ballot).total() > 0) {  
            uint reward = shares * ITomiBallotRevenue(_ballot).weight(msg.sender) / ITomiBallotRevenue(_ballot).total();
            amount += ITomiBallotRevenue(_ballot).proposer() == msg.sender ? 0 : reward; 
        }
        return amount;
    }

    function addReward(uint _value) external returns (bool) {

        require(_value > 0, 'TomiGovernance: ADD_REWARD_VALUE_IS_ZERO');
        uint total = IERC20(baseToken).balanceOf(address(this));
        uint diff = total.sub(totalSupply);
        require(_value <= diff, 'TomiGovernance: ADD_REWARD_EXCEED');
        rewardOf[rewardAddr] = rewardOf[rewardAddr].add(_value);
        totalSupply = total;
        emit RewardReceived(rewardAddr, _value);
    }

    function _rewardTransfer(address _from, address _to, uint _value) private returns (bool) {

        require(_value >= 0 && rewardOf[_from] >= _value, 'TomiGovernance: INSUFFICIENT_BALANCE');
        rewardOf[_from] = rewardOf[_from].sub(_value);
        rewardOf[_to] = rewardOf[_to].add(_value);
        emit RewardTransfered(_from, _to, _value);
    }

    function _isDefaultToken(address _token) internal returns (bool) {

        address[] memory tokens = ITomiConfig(configAddr).getDefaultListTokens();
        for(uint i = 0 ; i < tokens.length; i++){
            if (tokens[i] == _token) {
                return true;
            }
        }
        return false;
    }

    function _transferForBallot(uint _amount, bool _wallet, uint _endTime) internal returns (uint) {

        if (_wallet && _amount > 0) {
            _add(msg.sender, _amount, _endTime);
            TransferHelper.safeTransferFrom(baseToken, msg.sender, address(this), _amount);
            totalSupply += _amount;
        } 

        if (_amount == 0) allowance[msg.sender] = estimateLocktime(msg.sender, _endTime);

        return _amount;
    }

    function _transferToStaking(uint _amount) internal {

        if (stakingAddr != address(0)) {
            TransferHelper.safeTransfer(baseToken, stakingAddr, _amount);
            ITomiStaking(stakingAddr).updateRevenueShare(_amount);
        }
    }

    function _createdBallot(address _ballot, uint _type) internal returns (uint) {

        uint reward = 0;
        
        if (_type == T_REVENUE) {
            reward = rewardOf[rewardAddr];
            ballotOf[_ballot] = reward;
            _rewardTransfer(rewardAddr, _ballot, reward);
        }

        _type == T_REVENUE ? revenueBallots.push(_ballot): ballots.push(_ballot);
        ballotTypes[_ballot] = _type;
        return reward;
    }

    function ballotCount() external view returns (uint) {

        return ballots.length;
    }

    function ballotRevenueCount() external view returns (uint) {

        return revenueBallots.length;
    }

    function _changeAmountPerBlock(uint _value) internal returns (bool) {

        return ITgas(baseToken).changeInterestRatePerBlock(_value);
    }

    function updateTgasGovernor(address _new) external onlyOwner {

        ITgas(baseToken).upgradeGovernance(_new);
    }

    function upgradeApproveReward() external returns (uint) {

        require(rewardOf[rewardAddr] > 0, 'TomiGovernance: UPGRADE_NO_REWARD');
        require(ITomiConfig(configAddr).governor() != address(this), 'TomiGovernance: UPGRADE_NO_CHANGE');
        TransferHelper.safeApprove(baseToken, ITomiConfig(configAddr).governor(), rewardOf[rewardAddr]);
        return rewardOf[rewardAddr]; 
    }

    function receiveReward(address _from, uint _value) external returns (bool) {

        require(_value > 0, 'TomiGovernance: RECEIVE_REWARD_VALUE_IS_ZERO');
        TransferHelper.safeTransferFrom(baseToken, _from, address(this), _value);
        rewardOf[rewardAddr] += _value;
        totalSupply += _value;
        emit RewardReceived(_from, _value);
        return true;
    }

}