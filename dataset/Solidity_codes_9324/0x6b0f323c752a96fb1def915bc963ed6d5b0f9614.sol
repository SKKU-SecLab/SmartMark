pragma solidity 0.6.12;

interface IERC20Token {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256);


    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface IOwned {

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;


    function acceptOwnership() external;

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface IConverterAnchor is IOwned {


}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface IDSToken is IConverterAnchor, IERC20Token {

    function issue(address _to, uint256 _amount) external;


    function destroy(address _from, uint256 _amount) external;

}// MIT
pragma solidity 0.6.12;


struct PoolProgram {
    uint256 startTime;
    uint256 endTime;
    uint256 rewardRate;
    IERC20Token[2] reserveTokens;
    uint32[2] rewardShares;
}

struct PoolRewards {
    uint256 lastUpdateTime;
    uint256 rewardPerToken;
    uint256 totalClaimedRewards;
}

struct ProviderRewards {
    uint256 rewardPerToken;
    uint256 pendingBaseRewards;
    uint256 totalClaimedRewards;
    uint256 effectiveStakingTime;
    uint256 baseRewardsDebt;
    uint32 baseRewardsDebtMultiplier;
}

interface IStakingRewardsStore {

    function isPoolParticipating(IDSToken poolToken) external view returns (bool);


    function isReserveParticipating(IDSToken poolToken, IERC20Token reserveToken) external view returns (bool);


    function addPoolProgram(
        IDSToken poolToken,
        IERC20Token[2] calldata reserveTokens,
        uint32[2] calldata rewardShares,
        uint256 endTime,
        uint256 rewardRate
    ) external;


    function removePoolProgram(IDSToken poolToken) external;


    function setPoolProgramEndTime(IDSToken poolToken, uint256 newEndTime) external;


    function poolProgram(IDSToken poolToken)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            IERC20Token[2] memory,
            uint32[2] memory
        );


    function poolPrograms()
        external
        view
        returns (
            IDSToken[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            IERC20Token[2][] memory,
            uint32[2][] memory
        );


    function poolRewards(IDSToken poolToken, IERC20Token reserveToken)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function updatePoolRewardsData(
        IDSToken poolToken,
        IERC20Token reserveToken,
        uint256 lastUpdateTime,
        uint256 rewardPerToken,
        uint256 totalClaimedRewards
    ) external;


    function providerRewards(
        address provider,
        IDSToken poolToken,
        IERC20Token reserveToken
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint32
        );


    function updateProviderRewardsData(
        address provider,
        IDSToken poolToken,
        IERC20Token reserveToken,
        uint256 rewardPerToken,
        uint256 pendingBaseRewards,
        uint256 totalClaimedRewards,
        uint256 effectiveStakingTime,
        uint256 baseRewardsDebt,
        uint32 baseRewardsDebtMultiplier
    ) external;


    function updateProviderLastClaimTime(address provider) external;


    function providerLastClaimTime(address provider) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

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
}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

contract Utils {

    modifier greaterThanZero(uint256 _value) {

        _greaterThanZero(_value);
        _;
    }

    function _greaterThanZero(uint256 _value) internal pure {

        require(_value > 0, "ERR_ZERO_VALUE");
    }

    modifier validAddress(address _address) {

        _validAddress(_address);
        _;
    }

    function _validAddress(address _address) internal pure {

        require(_address != address(0), "ERR_INVALID_ADDRESS");
    }

    modifier notThis(address _address) {

        _notThis(_address);
        _;
    }

    function _notThis(address _address) internal view {

        require(_address != address(this), "ERR_ADDRESS_IS_SELF");
    }

    modifier validExternalAddress(address _address) {

        _validExternalAddress(_address);
        _;
    }

    function _validExternalAddress(address _address) internal view {

        require(_address != address(0) && _address != address(this), "ERR_INVALID_EXTERNAL_ADDRESS");
    }
}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

contract Time {

    function time() internal view virtual returns (uint256) {

        return block.timestamp;
    }
}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface IConverter is IOwned {

    function converterType() external pure returns (uint16);


    function anchor() external view returns (IConverterAnchor);


    function isActive() external view returns (bool);


    function targetAmountAndFee(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        uint256 _amount
    ) external view returns (uint256, uint256);


    function convert(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary
    ) external payable returns (uint256);


    function conversionFee() external view returns (uint32);


    function maxConversionFee() external view returns (uint32);


    function reserveBalance(IERC20Token _reserveToken) external view returns (uint256);


    receive() external payable;

    function transferAnchorOwnership(address _newOwner) external;


    function acceptAnchorOwnership() external;


    function setConversionFee(uint32 _conversionFee) external;


    function withdrawTokens(
        IERC20Token _token,
        address _to,
        uint256 _amount
    ) external;


    function withdrawETH(address payable _to) external;


    function addReserve(IERC20Token _token, uint32 _ratio) external;


    function token() external view returns (IConverterAnchor);


    function transferTokenOwnership(address _newOwner) external;


    function acceptTokenOwnership() external;


    function connectors(IERC20Token _address)
        external
        view
        returns (
            uint256,
            uint32,
            bool,
            bool,
            bool
        );


    function getConnectorBalance(IERC20Token _connectorToken) external view returns (uint256);


    function connectorTokens(uint256 _index) external view returns (IERC20Token);


    function connectorTokenCount() external view returns (uint16);


    event Activation(uint16 indexed _type, IConverterAnchor indexed _anchor, bool indexed _activated);

    event Conversion(
        IERC20Token indexed _fromToken,
        IERC20Token indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    event TokenRateUpdate(IERC20Token indexed _token1, IERC20Token indexed _token2, uint256 _rateN, uint256 _rateD);

    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);
}// MIT
pragma solidity 0.6.12;




contract StakingRewardsStore is IStakingRewardsStore, AccessControl, Utils, Time {

    using SafeMath for uint32;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant ROLE_SUPERVISOR = keccak256("ROLE_SUPERVISOR");

    bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");

    bytes32 public constant ROLE_MANAGER = keccak256("ROLE_MANAGER");

    bytes32 public constant ROLE_SEEDER = keccak256("ROLE_SEEDER");

    uint32 private constant PPM_RESOLUTION = 1000000;

    mapping(IDSToken => PoolProgram) private _programs;

    EnumerableSet.AddressSet private _pools;

    mapping(IDSToken => mapping(IERC20Token => PoolRewards)) internal _poolRewards;

    mapping(address => mapping(IDSToken => mapping(IERC20Token => ProviderRewards))) internal _providerRewards;

    mapping(address => uint256) private _providerLastClaimTimes;

    event PoolProgramAdded(IDSToken indexed poolToken, uint256 startTime, uint256 endTime, uint256 rewardRate);

    event PoolProgramRemoved(IDSToken indexed poolToken);

    event ProviderLastClaimTimeUpdated(address indexed provider, uint256 claimTime);

    constructor() public {
        _setRoleAdmin(ROLE_SUPERVISOR, ROLE_SUPERVISOR);
        _setRoleAdmin(ROLE_OWNER, ROLE_SUPERVISOR);
        _setRoleAdmin(ROLE_MANAGER, ROLE_SUPERVISOR);
        _setRoleAdmin(ROLE_SEEDER, ROLE_SUPERVISOR);

        _setupRole(ROLE_SUPERVISOR, _msgSender());
    }

    modifier onlyOwner {

        _hasRole(ROLE_OWNER);
        _;
    }

    modifier onlyManager {

        _hasRole(ROLE_MANAGER);
        _;
    }

    modifier onlySeeder {

        _hasRole(ROLE_SEEDER);
        _;
    }

    function _hasRole(bytes32 role) internal view {

        require(hasRole(role, msg.sender), "ERR_ACCESS_DENIED");
    }

    function isPoolParticipating(IDSToken poolToken) public view override returns (bool) {

        PoolProgram memory program = _programs[poolToken];

        return program.endTime > time();
    }

    function isReserveParticipating(IDSToken poolToken, IERC20Token reserveToken) public view override returns (bool) {

        if (!isPoolParticipating(poolToken)) {
            return false;
        }

        PoolProgram memory program = _programs[poolToken];

        return program.reserveTokens[0] == reserveToken || program.reserveTokens[1] == reserveToken;
    }

    function addPoolProgram(
        IDSToken poolToken,
        IERC20Token[2] calldata reserveTokens,
        uint32[2] calldata rewardShares,
        uint256 endTime,
        uint256 rewardRate
    ) external override onlyManager validAddress(address(poolToken)) {

        uint256 currentTime = time();

        addPoolProgram(poolToken, reserveTokens, rewardShares, currentTime, endTime, rewardRate);

        emit PoolProgramAdded(poolToken, currentTime, endTime, rewardRate);
    }

    function addPastPoolPrograms(
        IDSToken[] calldata poolTokens,
        IERC20Token[2][] calldata reserveTokens,
        uint32[2][] calldata rewardShares,
        uint256[] calldata startTime,
        uint256[] calldata endTimes,
        uint256[] calldata rewardRates
    ) external onlySeeder {

        uint256 length = poolTokens.length;
        require(
            length == reserveTokens.length &&
                length == rewardShares.length &&
                length == startTime.length &&
                length == endTimes.length &&
                length == rewardRates.length,
            "ERR_INVALID_LENGTH"
        );

        for (uint256 i = 0; i < length; ++i) {
            addPastPoolProgram(
                poolTokens[i],
                reserveTokens[i],
                rewardShares[i],
                startTime[i],
                endTimes[i],
                rewardRates[i]
            );
        }
    }

    function addPastPoolProgram(
        IDSToken poolToken,
        IERC20Token[2] calldata reserveTokens,
        uint32[2] calldata rewardShares,
        uint256 startTime,
        uint256 endTime,
        uint256 rewardRate
    ) private validAddress(address(poolToken)) {

        require(startTime < time(), "ERR_INVALID_TIME");

        addPoolProgram(poolToken, reserveTokens, rewardShares, startTime, endTime, rewardRate);
    }

    function addPoolProgram(
        IDSToken poolToken,
        IERC20Token[2] calldata reserveTokens,
        uint32[2] calldata rewardShares,
        uint256 startTime,
        uint256 endTime,
        uint256 rewardRate
    ) private {

        require(startTime < endTime && endTime > time(), "ERR_INVALID_DURATION");
        require(rewardRate > 0, "ERR_ZERO_VALUE");
        require(rewardShares[0].add(rewardShares[1]) == PPM_RESOLUTION, "ERR_INVALID_REWARD_SHARES");

        require(_pools.add(address(poolToken)), "ERR_ALREADY_PARTICIPATING");

        PoolProgram storage program = _programs[poolToken];
        program.startTime = startTime;
        program.endTime = endTime;
        program.rewardRate = rewardRate;
        program.rewardShares = rewardShares;

        IConverter converter = IConverter(payable(IConverterAnchor(poolToken).owner()));
        uint256 length = converter.connectorTokenCount();
        require(length == 2, "ERR_POOL_NOT_SUPPORTED");

        require(
            (address(converter.connectorTokens(0)) == address(reserveTokens[0]) &&
                address(converter.connectorTokens(1)) == address(reserveTokens[1])) ||
                (address(converter.connectorTokens(0)) == address(reserveTokens[1]) &&
                    address(converter.connectorTokens(1)) == address(reserveTokens[0])),
            "ERR_INVALID_RESERVE_TOKENS"
        );
        program.reserveTokens = reserveTokens;
    }

    function removePoolProgram(IDSToken poolToken) external override onlyManager {

        require(_pools.remove(address(poolToken)), "ERR_POOL_NOT_PARTICIPATING");

        delete _programs[poolToken];

        emit PoolProgramRemoved(poolToken);
    }

    function setPoolProgramEndTime(IDSToken poolToken, uint256 newEndTime) external override onlyManager {

        require(isPoolParticipating(poolToken), "ERR_POOL_NOT_PARTICIPATING");

        PoolProgram storage program = _programs[poolToken];
        require(newEndTime > time(), "ERR_INVALID_DURATION");

        program.endTime = newEndTime;
    }

    function poolProgram(IDSToken poolToken)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            IERC20Token[2] memory,
            uint32[2] memory
        )
    {

        PoolProgram memory program = _programs[poolToken];

        return (program.startTime, program.endTime, program.rewardRate, program.reserveTokens, program.rewardShares);
    }

    function poolPrograms()
        external
        view
        override
        returns (
            IDSToken[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            IERC20Token[2][] memory,
            uint32[2][] memory
        )
    {

        uint256 length = _pools.length();

        IDSToken[] memory poolTokens = new IDSToken[](length);
        uint256[] memory startTimes = new uint256[](length);
        uint256[] memory endTimes = new uint256[](length);
        uint256[] memory rewardRates = new uint256[](length);
        IERC20Token[2][] memory reserveTokens = new IERC20Token[2][](length);
        uint32[2][] memory rewardShares = new uint32[2][](length);

        for (uint256 i = 0; i < length; ++i) {
            IDSToken poolToken = IDSToken(_pools.at(i));
            PoolProgram memory program = _programs[poolToken];

            poolTokens[i] = poolToken;
            startTimes[i] = program.startTime;
            endTimes[i] = program.endTime;
            rewardRates[i] = program.rewardRate;
            reserveTokens[i] = program.reserveTokens;
            rewardShares[i] = program.rewardShares;
        }

        return (poolTokens, startTimes, endTimes, rewardRates, reserveTokens, rewardShares);
    }

    function poolRewards(IDSToken poolToken, IERC20Token reserveToken)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        PoolRewards memory data = _poolRewards[poolToken][reserveToken];

        return (data.lastUpdateTime, data.rewardPerToken, data.totalClaimedRewards);
    }

    function updatePoolRewardsData(
        IDSToken poolToken,
        IERC20Token reserveToken,
        uint256 lastUpdateTime,
        uint256 rewardPerToken,
        uint256 totalClaimedRewards
    ) external override onlyOwner {

        PoolRewards storage data = _poolRewards[poolToken][reserveToken];
        data.lastUpdateTime = lastUpdateTime;
        data.rewardPerToken = rewardPerToken;
        data.totalClaimedRewards = totalClaimedRewards;
    }

    function setPoolsRewardData(
        IDSToken[] calldata poolTokens,
        IERC20Token[] calldata reserveTokens,
        uint256[] calldata lastUpdateTimes,
        uint256[] calldata rewardsPerToken,
        uint256[] calldata totalClaimedRewards
    ) external onlySeeder {

        uint256 length = poolTokens.length;
        require(
            length == reserveTokens.length && length == lastUpdateTimes.length && length == rewardsPerToken.length,
            "ERR_INVALID_LENGTH"
        );

        for (uint256 i = 0; i < length; ++i) {
            IDSToken poolToken = poolTokens[i];
            _validAddress(address(poolToken));

            IERC20Token reserveToken = reserveTokens[i];
            _validAddress(address(reserveToken));

            PoolRewards storage data = _poolRewards[poolToken][reserveToken];
            data.lastUpdateTime = lastUpdateTimes[i];
            data.rewardPerToken = rewardsPerToken[i];
            data.totalClaimedRewards = totalClaimedRewards[i];
        }
    }

    function providerRewards(
        address provider,
        IDSToken poolToken,
        IERC20Token reserveToken
    )
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint32
        )
    {

        ProviderRewards memory data = _providerRewards[provider][poolToken][reserveToken];

        return (
            data.rewardPerToken,
            data.pendingBaseRewards,
            data.totalClaimedRewards,
            data.effectiveStakingTime,
            data.baseRewardsDebt,
            data.baseRewardsDebtMultiplier
        );
    }

    function updateProviderRewardsData(
        address provider,
        IDSToken poolToken,
        IERC20Token reserveToken,
        uint256 rewardPerToken,
        uint256 pendingBaseRewards,
        uint256 totalClaimedRewards,
        uint256 effectiveStakingTime,
        uint256 baseRewardsDebt,
        uint32 baseRewardsDebtMultiplier
    ) external override onlyOwner {

        ProviderRewards storage data = _providerRewards[provider][poolToken][reserveToken];

        data.rewardPerToken = rewardPerToken;
        data.pendingBaseRewards = pendingBaseRewards;
        data.totalClaimedRewards = totalClaimedRewards;
        data.effectiveStakingTime = effectiveStakingTime;
        data.baseRewardsDebt = baseRewardsDebt;
        data.baseRewardsDebtMultiplier = baseRewardsDebtMultiplier;
    }

    function setProviderRewardData(
        IDSToken poolToken,
        IERC20Token reserveToken,
        address[] memory providers,
        uint256[] memory rewardsPerToken,
        uint256[] memory pendingBaseRewards,
        uint256[] memory totalClaimedRewards,
        uint256[] memory effectiveStakingTimes,
        uint256[] memory baseRewardsDebts,
        uint32[] memory baseRewardsDebtMultipliers
    ) external onlySeeder validAddress(address(poolToken)) validAddress(address(reserveToken)) {

        uint256 length = providers.length;
        require(
            length == rewardsPerToken.length &&
                length == pendingBaseRewards.length &&
                length == totalClaimedRewards.length &&
                length == effectiveStakingTimes.length &&
                length == baseRewardsDebts.length &&
                length == baseRewardsDebtMultipliers.length,
            "ERR_INVALID_LENGTH"
        );

        for (uint256 i = 0; i < length; ++i) {
            ProviderRewards storage data = _providerRewards[providers[i]][poolToken][reserveToken];

            uint256 baseRewardsDebt = baseRewardsDebts[i];
            uint32 baseRewardsDebtMultiplier = baseRewardsDebtMultipliers[i];
            require(
                baseRewardsDebt == 0 ||
                    (baseRewardsDebtMultiplier >= PPM_RESOLUTION && baseRewardsDebtMultiplier <= 2 * PPM_RESOLUTION),
                "ERR_INVALID_MULTIPLIER"
            );

            data.rewardPerToken = rewardsPerToken[i];
            data.pendingBaseRewards = pendingBaseRewards[i];
            data.totalClaimedRewards = totalClaimedRewards[i];
            data.effectiveStakingTime = effectiveStakingTimes[i];
            data.baseRewardsDebt = baseRewardsDebts[i];
            data.baseRewardsDebtMultiplier = baseRewardsDebtMultiplier;
        }
    }

    function updateProviderLastClaimTime(address provider) external override onlyOwner {

        uint256 time = time();
        _providerLastClaimTimes[provider] = time;

        emit ProviderLastClaimTimeUpdated(provider, time);
    }

    function providerLastClaimTime(address provider) external view override returns (uint256) {

        return _providerLastClaimTimes[provider];
    }
}