
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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



interface IDSToken is IConverterAnchor, IERC20 {

    function issue(address _to, uint256 _amount) external;


    function destroy(address _from, uint256 _amount) external;

}// MIT
pragma solidity 0.6.12;



struct PoolProgram {
    uint256 startTime;
    uint256 endTime;
    uint256 rewardRate;
    IERC20[2] reserveTokens;
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


    function isReserveParticipating(IDSToken poolToken, IERC20 reserveToken) external view returns (bool);


    function addPoolProgram(
        IDSToken poolToken,
        IERC20[2] calldata reserveTokens,
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
            IERC20[2] memory,
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
            IERC20[2][] memory,
            uint32[2][] memory
        );


    function poolRewards(IDSToken poolToken, IERC20 reserveToken)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function updatePoolRewardsData(
        IDSToken poolToken,
        IERC20 reserveToken,
        uint256 lastUpdateTime,
        uint256 rewardPerToken,
        uint256 totalClaimedRewards
    ) external;


    function providerRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken
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
        IERC20 reserveToken,
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.6.12;

interface IClaimable {

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    function acceptOwnership() external;

}// MIT
pragma solidity 0.6.12;



interface IMintableToken is IERC20, IClaimable {

    function issue(address to, uint256 amount) external;


    function destroy(address from, uint256 amount) external;

}// MIT
pragma solidity 0.6.12;


interface ITokenGovernance {

    function token() external view returns (IMintableToken);


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

contract Owned is IOwned {

    address public override owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {

        _ownerOnly();
        _;
    }

    function _ownerOnly() internal view {

        require(msg.sender == owner, "ERR_ACCESS_DENIED");
    }

    function transferOwnership(address _newOwner) public override ownerOnly {

        require(_newOwner != owner, "ERR_SAME_OWNER");
        newOwner = _newOwner;
    }

    function acceptOwnership() public override {

        require(msg.sender == newOwner, "ERR_ACCESS_DENIED");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
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

interface IContractRegistry {

    function addressOf(bytes32 _contractName) external view returns (address);

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

contract ContractRegistryClient is Owned, Utils {

    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant CONVERTER_FACTORY = "ConverterFactory";
    bytes32 internal constant CONVERSION_PATH_FINDER = "ConversionPathFinder";
    bytes32 internal constant CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";
    bytes32 internal constant LIQUIDITY_PROTECTION = "LiquidityProtection";

    IContractRegistry public registry; // address of the current contract-registry
    IContractRegistry public prevRegistry; // address of the previous contract-registry
    bool public onlyOwnerCanUpdateRegistry; // only an owner can update the contract-registry

    modifier only(bytes32 _contractName) {

        _only(_contractName);
        _;
    }

    function _only(bytes32 _contractName) internal view {

        require(msg.sender == addressOf(_contractName), "ERR_ACCESS_DENIED");
    }

    constructor(IContractRegistry _registry) internal validAddress(address(_registry)) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    function updateRegistry() public {

        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry, "ERR_ACCESS_DENIED");

        IContractRegistry newRegistry = IContractRegistry(addressOf(CONTRACT_REGISTRY));

        require(newRegistry != registry && address(newRegistry) != address(0), "ERR_INVALID_REGISTRY");

        require(newRegistry.addressOf(CONTRACT_REGISTRY) != address(0), "ERR_INVALID_REGISTRY");

        prevRegistry = registry;

        registry = newRegistry;
    }

    function restoreRegistry() public ownerOnly {

        registry = prevRegistry;
    }

    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) public ownerOnly {

        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
    }

    function addressOf(bytes32 _contractName) internal view returns (address) {

        return registry.addressOf(_contractName);
    }
}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

contract Time {

    function time() internal view virtual returns (uint256) {

        return block.timestamp;
    }
}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface ICheckpointStore {

    function addCheckpoint(address _address) external;


    function addPastCheckpoint(address _address, uint256 _time) external;


    function addPastCheckpoints(address[] calldata _addresses, uint256[] calldata _times) external;


    function checkpoint(address _address) external view returns (uint256);

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ILiquidityProtectionStore is IOwned {

    function withdrawTokens(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;


    function protectedLiquidity(uint256 _id)
        external
        view
        returns (
            address,
            IDSToken,
            IERC20,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function addProtectedLiquidity(
        address _provider,
        IDSToken _poolToken,
        IERC20 _reserveToken,
        uint256 _poolAmount,
        uint256 _reserveAmount,
        uint256 _reserveRateN,
        uint256 _reserveRateD,
        uint256 _timestamp
    ) external returns (uint256);


    function updateProtectedLiquidityAmounts(
        uint256 _id,
        uint256 _poolNewAmount,
        uint256 _reserveNewAmount
    ) external;


    function removeProtectedLiquidity(uint256 _id) external;


    function lockedBalance(address _provider, uint256 _index) external view returns (uint256, uint256);


    function lockedBalanceRange(
        address _provider,
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (uint256[] memory, uint256[] memory);


    function addLockedBalance(
        address _provider,
        uint256 _reserveAmount,
        uint256 _expirationTime
    ) external returns (uint256);


    function removeLockedBalance(address _provider, uint256 _index) external;


    function systemBalance(IERC20 _poolToken) external view returns (uint256);


    function incSystemBalance(IERC20 _poolToken, uint256 _poolAmount) external;


    function decSystemBalance(IERC20 _poolToken, uint256 _poolAmount) external;

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ILiquidityProtectionStats {

    function increaseTotalAmounts(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;


    function decreaseTotalAmounts(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;


    function addProviderPool(address provider, IDSToken poolToken) external returns (bool);


    function removeProviderPool(address provider, IDSToken poolToken) external returns (bool);


    function totalPoolAmount(IDSToken poolToken) external view returns (uint256);


    function totalReserveAmount(IDSToken poolToken, IERC20 reserveToken) external view returns (uint256);


    function totalProviderAmount(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken
    ) external view returns (uint256);


    function providerPools(address provider) external view returns (IDSToken[] memory);

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ILiquidityProtectionEventsSubscriber {

    function onAddingLiquidity(
        address provider,
        IConverterAnchor poolAnchor,
        IERC20 reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;


    function onRemovingLiquidity(
        uint256 id,
        address provider,
        IConverterAnchor poolAnchor,
        IERC20 reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ILiquidityProtectionSettings {

    function isPoolWhitelisted(IConverterAnchor poolAnchor) external view returns (bool);


    function poolWhitelist() external view returns (address[] memory);


    function subscribers() external view returns (address[] memory);


    function isPoolSupported(IConverterAnchor poolAnchor) external view returns (bool);


    function minNetworkTokenLiquidityForMinting() external view returns (uint256);


    function defaultNetworkTokenMintingLimit() external view returns (uint256);


    function networkTokenMintingLimits(IConverterAnchor poolAnchor) external view returns (uint256);


    function addLiquidityDisabled(IConverterAnchor poolAnchor, IERC20 reserveToken) external view returns (bool);


    function minProtectionDelay() external view returns (uint256);


    function maxProtectionDelay() external view returns (uint256);


    function minNetworkCompensation() external view returns (uint256);


    function lockDuration() external view returns (uint256);


    function averageRateMaxDeviation() external view returns (uint32);

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ILiquidityProtectionSystemStore {

    function systemBalance(IERC20 poolToken) external view returns (uint256);


    function incSystemBalance(IERC20 poolToken, uint256 poolAmount) external;


    function decSystemBalance(IERC20 poolToken, uint256 poolAmount) external;


    function networkTokensMinted(IConverterAnchor poolAnchor) external view returns (uint256);


    function incNetworkTokensMinted(IConverterAnchor poolAnchor, uint256 amount) external;


    function decNetworkTokensMinted(IConverterAnchor poolAnchor, uint256 amount) external;

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ITokenHolder is IOwned {

    function withdrawTokens(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

}// SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



interface ILiquidityProtection {

    function store() external view returns (ILiquidityProtectionStore);


    function stats() external view returns (ILiquidityProtectionStats);


    function settings() external view returns (ILiquidityProtectionSettings);


    function systemStore() external view returns (ILiquidityProtectionSystemStore);


    function wallet() external view returns (ITokenHolder);


    function addLiquidityFor(
        address owner,
        IConverterAnchor poolAnchor,
        IERC20 reserveToken,
        uint256 amount
    ) external payable returns (uint256);


    function addLiquidity(
        IConverterAnchor poolAnchor,
        IERC20 reserveToken,
        uint256 amount
    ) external payable returns (uint256);


    function removeLiquidity(uint256 id, uint32 portion) external;

}// MIT
pragma solidity 0.6.12;




contract StakingRewards is ILiquidityProtectionEventsSubscriber, AccessControl, Time, Utils, ContractRegistryClient {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 public constant ROLE_SUPERVISOR = keccak256("ROLE_SUPERVISOR");

    bytes32 public constant ROLE_PUBLISHER = keccak256("ROLE_PUBLISHER");

    bytes32 public constant ROLE_UPDATER = keccak256("ROLE_UPDATER");

    uint32 private constant PPM_RESOLUTION = 1000000;

    uint32 private constant MULTIPLIER_INCREMENT = PPM_RESOLUTION / 4;

    uint32 private constant MAX_MULTIPLIER = PPM_RESOLUTION + MULTIPLIER_INCREMENT * 4;

    uint8 private constant REWARDS_HALVING_FACTOR = 2;

    uint256 private constant REWARD_RATE_FACTOR = 1e18;

    uint256 private constant MAX_UINT256 = uint256(-1);

    IStakingRewardsStore private immutable _store;

    ITokenGovernance private immutable _networkTokenGovernance;

    IERC20 private immutable _networkToken;

    ICheckpointStore private immutable _lastRemoveTimes;

    event RewardsClaimed(address indexed provider, uint256 amount);

    event RewardsStaked(address indexed provider, IDSToken indexed poolToken, uint256 amount, uint256 indexed newId);

    constructor(
        IStakingRewardsStore store,
        ITokenGovernance networkTokenGovernance,
        ICheckpointStore lastRemoveTimes,
        IContractRegistry registry
    )
        public
        validAddress(address(store))
        validAddress(address(networkTokenGovernance))
        validAddress(address(lastRemoveTimes))
        ContractRegistryClient(registry)
    {
        _store = store;
        _networkTokenGovernance = networkTokenGovernance;
        _networkToken = networkTokenGovernance.token();
        _lastRemoveTimes = lastRemoveTimes;

        _setRoleAdmin(ROLE_SUPERVISOR, ROLE_SUPERVISOR);
        _setRoleAdmin(ROLE_PUBLISHER, ROLE_SUPERVISOR);
        _setRoleAdmin(ROLE_UPDATER, ROLE_SUPERVISOR);

        _setupRole(ROLE_SUPERVISOR, _msgSender());
    }

    modifier onlyPublisher() {

        _onlyPublisher();
        _;
    }

    function _onlyPublisher() internal view {

        require(hasRole(ROLE_PUBLISHER, msg.sender), "ERR_ACCESS_DENIED");
    }

    modifier onlyUpdater() {

        _onlyUpdater();
        _;
    }

    function _onlyUpdater() internal view {

        require(hasRole(ROLE_UPDATER, msg.sender), "ERR_ACCESS_DENIED");
    }

    function onAddingLiquidity(
        address provider,
        IConverterAnchor poolAnchor,
        IERC20 reserveToken,
        uint256, /* poolAmount */
        uint256 /* reserveAmount */
    ) external override onlyPublisher validExternalAddress(provider) {

        IDSToken poolToken = IDSToken(address(poolAnchor));
        PoolProgram memory program = poolProgram(poolToken);
        if (program.startTime == 0) {
            return;
        }

        updateRewards(provider, poolToken, reserveToken, program, liquidityProtectionStats());
    }

    function onRemovingLiquidity(
        uint256, /* id */
        address provider,
        IConverterAnchor, /* poolAnchor */
        IERC20, /* reserveToken */
        uint256, /* poolAmount */
        uint256 /* reserveAmount */
    ) external override onlyPublisher validExternalAddress(provider) {

        ILiquidityProtectionStats lpStats = liquidityProtectionStats();

        storeRewards(provider, lpStats.providerPools(provider), lpStats);
    }

    function store() external view returns (IStakingRewardsStore) {

        return _store;
    }

    function networkTokenGovernance() external view returns (ITokenGovernance) {

        return _networkTokenGovernance;
    }

    function lastRemoveTimes() external view returns (ICheckpointStore) {

        return _lastRemoveTimes;
    }

    function pendingRewards(address provider) external view returns (uint256) {

        return pendingRewards(provider, liquidityProtectionStats());
    }

    function pendingReserveRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken
    ) external view returns (uint256) {

        PoolProgram memory program = poolProgram(poolToken);

        return pendingRewards(provider, poolToken, reserveToken, program, liquidityProtectionStats());
    }

    function pendingRewards(address provider, ILiquidityProtectionStats lpStats) private view returns (uint256) {

        return pendingRewards(provider, lpStats.providerPools(provider), lpStats);
    }

    function pendingRewards(
        address provider,
        IDSToken[] memory poolTokens,
        ILiquidityProtectionStats lpStats
    ) private view returns (uint256) {

        uint256 reward = 0;

        uint256 length = poolTokens.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 poolReward = pendingRewards(provider, poolTokens[i], lpStats);
            reward = reward.add(poolReward);
        }

        return reward;
    }

    function pendingRewards(
        address provider,
        IDSToken poolToken,
        ILiquidityProtectionStats lpStats
    ) private view returns (uint256) {

        uint256 reward = 0;
        PoolProgram memory program = poolProgram(poolToken);

        for (uint256 i = 0; i < program.reserveTokens.length; ++i) {
            uint256 reserveReward = pendingRewards(provider, poolToken, program.reserveTokens[i], program, lpStats);
            reward = reward.add(reserveReward);
        }

        return reward;
    }


    function pendingRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private view returns (uint256) {

        if (
            address(reserveToken) == address(0) ||
            (program.reserveTokens[0] != reserveToken && program.reserveTokens[1] != reserveToken)
        ) {
            return 0;
        }

        PoolRewards memory poolRewardsData = poolRewards(poolToken, reserveToken);

        poolRewardsData.rewardPerToken = rewardPerToken(poolToken, reserveToken, poolRewardsData, program, lpStats);
        poolRewardsData.lastUpdateTime = Math.min(time(), program.endTime);

        ProviderRewards memory providerRewards = providerRewards(provider, poolToken, reserveToken);

        if (
            providerRewards.effectiveStakingTime == 0 &&
            lpStats.totalProviderAmount(provider, poolToken, reserveToken) == 0
        ) {
            providerRewards.effectiveStakingTime = time();
        }

        providerRewards.pendingBaseRewards = providerRewards.pendingBaseRewards.add(
            baseRewards(provider, poolToken, reserveToken, poolRewardsData, providerRewards, program, lpStats)
        );
        providerRewards.rewardPerToken = poolRewardsData.rewardPerToken;

        (uint256 fullReward, ) =
            fullRewards(provider, poolToken, reserveToken, poolRewardsData, providerRewards, program, lpStats);

        return fullReward;
    }

    function claimPendingRewards(
        address provider,
        IDSToken[] memory poolTokens,
        uint256 maxAmount,
        ILiquidityProtectionStats lpStats,
        bool resetStakingTime
    ) private returns (uint256) {

        uint256 reward = 0;

        uint256 length = poolTokens.length;
        for (uint256 i = 0; i < length && maxAmount > 0; ++i) {
            uint256 poolReward = claimPendingRewards(provider, poolTokens[i], maxAmount, lpStats, resetStakingTime);
            reward = reward.add(poolReward);

            if (maxAmount != MAX_UINT256) {
                maxAmount = maxAmount.sub(poolReward);
            }
        }

        return reward;
    }

    function claimPendingRewards(
        address provider,
        IDSToken poolToken,
        uint256 maxAmount,
        ILiquidityProtectionStats lpStats,
        bool resetStakingTime
    ) private returns (uint256) {

        uint256 reward = 0;
        PoolProgram memory program = poolProgram(poolToken);

        for (uint256 i = 0; i < program.reserveTokens.length && maxAmount > 0; ++i) {
            uint256 reserveReward =
                claimPendingRewards(
                    provider,
                    poolToken,
                    program.reserveTokens[i],
                    program,
                    maxAmount,
                    lpStats,
                    resetStakingTime
                );
            reward = reward.add(reserveReward);

            if (maxAmount != MAX_UINT256) {
                maxAmount = maxAmount.sub(reserveReward);
            }
        }

        return reward;
    }


    function claimPendingRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolProgram memory program,
        uint256 maxAmount,
        ILiquidityProtectionStats lpStats,
        bool resetStakingTime
    ) private returns (uint256) {

        (PoolRewards memory poolRewardsData, ProviderRewards memory providerRewards) =
            updateRewards(provider, poolToken, reserveToken, program, lpStats);

        (uint256 fullReward, uint32 multiplier) =
            fullRewards(provider, poolToken, reserveToken, poolRewardsData, providerRewards, program, lpStats);

        providerRewards.baseRewardsDebt = 0;
        providerRewards.baseRewardsDebtMultiplier = 0;

        if (maxAmount != MAX_UINT256 && fullReward > maxAmount) {
            if (multiplier == PPM_RESOLUTION) {
                providerRewards.baseRewardsDebt = fullReward.sub(maxAmount);
            } else {
                providerRewards.baseRewardsDebt = fullReward.sub(maxAmount).mul(PPM_RESOLUTION).div(multiplier);
            }

            providerRewards.baseRewardsDebtMultiplier = multiplier;

            fullReward = maxAmount;
        }

        _store.updatePoolRewardsData(
            poolToken,
            reserveToken,
            poolRewardsData.lastUpdateTime,
            poolRewardsData.rewardPerToken,
            poolRewardsData.totalClaimedRewards.add(fullReward)
        );

        _store.updateProviderRewardsData(
            provider,
            poolToken,
            reserveToken,
            providerRewards.rewardPerToken,
            0,
            providerRewards.totalClaimedRewards.add(fullReward),
            resetStakingTime ? time() : providerRewards.effectiveStakingTime,
            providerRewards.baseRewardsDebt,
            providerRewards.baseRewardsDebtMultiplier
        );

        return fullReward;
    }

    function rewardsMultiplier(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken
    ) external view returns (uint32) {

        ProviderRewards memory providerRewards = providerRewards(provider, poolToken, reserveToken);
        PoolProgram memory program = poolProgram(poolToken);
        return rewardsMultiplier(provider, providerRewards.effectiveStakingTime, program);
    }

    function totalClaimedRewards(address provider) external view returns (uint256) {

        uint256 totalRewards = 0;

        ILiquidityProtectionStats lpStats = liquidityProtectionStats();
        IDSToken[] memory poolTokens = lpStats.providerPools(provider);

        for (uint256 i = 0; i < poolTokens.length; ++i) {
            IDSToken poolToken = poolTokens[i];
            PoolProgram memory program = poolProgram(poolToken);

            for (uint256 j = 0; j < program.reserveTokens.length; ++j) {
                IERC20 reserveToken = program.reserveTokens[j];

                ProviderRewards memory providerRewards = providerRewards(provider, poolToken, reserveToken);

                totalRewards = totalRewards.add(providerRewards.totalClaimedRewards);
            }
        }

        return totalRewards;
    }

    function claimRewards() external returns (uint256) {

        return claimRewards(msg.sender, liquidityProtectionStats());
    }

    function claimRewards(address provider, ILiquidityProtectionStats lpStats) private returns (uint256) {

        return claimRewards(provider, lpStats.providerPools(provider), MAX_UINT256, lpStats);
    }

    function claimRewards(
        address provider,
        IDSToken[] memory poolTokens,
        uint256 maxAmount,
        ILiquidityProtectionStats lpStats
    ) private returns (uint256) {

        uint256 amount = claimPendingRewards(provider, poolTokens, maxAmount, lpStats, true);
        if (amount == 0) {
            return amount;
        }

        _store.updateProviderLastClaimTime(provider);

        _networkTokenGovernance.mint(provider, amount);

        emit RewardsClaimed(provider, amount);

        return amount;
    }

    function stakeRewards(uint256 maxAmount, IDSToken poolToken) external returns (uint256, uint256) {

        return stakeRewards(msg.sender, maxAmount, poolToken, liquidityProtectionStats());
    }

    function stakeRewards(
        address provider,
        uint256 maxAmount,
        IDSToken poolToken,
        ILiquidityProtectionStats lpStats
    ) private returns (uint256, uint256) {

        return stakeRewards(provider, lpStats.providerPools(provider), maxAmount, poolToken, lpStats);
    }

    function stakeRewards(
        address provider,
        IDSToken[] memory poolTokens,
        uint256 maxAmount,
        IDSToken newPoolToken,
        ILiquidityProtectionStats lpStats
    ) private returns (uint256, uint256) {

        uint256 amount = claimPendingRewards(provider, poolTokens, maxAmount, lpStats, false);
        if (amount == 0) {
            return (amount, 0);
        }

        ILiquidityProtection liquidityProtection = liquidityProtection();
        address liquidityProtectionAddress = address(liquidityProtection);
        uint256 allowance = _networkToken.allowance(address(this), liquidityProtectionAddress);
        if (allowance < amount) {
            if (allowance > 0) {
                _networkToken.safeApprove(liquidityProtectionAddress, 0);
            }
            _networkToken.safeApprove(liquidityProtectionAddress, amount);
        }

        _networkTokenGovernance.mint(address(this), amount);

        uint256 newId =
            liquidityProtection.addLiquidityFor(provider, newPoolToken, IERC20(address(_networkToken)), amount);


        emit RewardsStaked(provider, newPoolToken, amount, newId);

        return (amount, newId);
    }

    function storePoolRewards(address[] calldata providers, IDSToken poolToken) external onlyUpdater {

        ILiquidityProtectionStats lpStats = liquidityProtectionStats();
        PoolProgram memory program = poolProgram(poolToken);

        for (uint256 i = 0; i < providers.length; ++i) {
            for (uint256 j = 0; j < program.reserveTokens.length; ++j) {
                storeRewards(providers[i], poolToken, program.reserveTokens[j], program, lpStats, false);
            }
        }
    }

    function storeRewards(
        address provider,
        IDSToken[] memory poolTokens,
        ILiquidityProtectionStats lpStats
    ) private {

        for (uint256 i = 0; i < poolTokens.length; ++i) {
            IDSToken poolToken = poolTokens[i];
            PoolProgram memory program = poolProgram(poolToken);

            for (uint256 j = 0; j < program.reserveTokens.length; ++j) {
                storeRewards(provider, poolToken, program.reserveTokens[j], program, lpStats, true);
            }
        }
    }

    function storeRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats,
        bool resetStakingTime
    ) private {

        if (
            address(reserveToken) == address(0) ||
            (program.reserveTokens[0] != reserveToken && program.reserveTokens[1] != reserveToken)
        ) {
            return;
        }

        (PoolRewards memory poolRewardsData, ProviderRewards memory providerRewards) =
            updateRewards(provider, poolToken, reserveToken, program, lpStats);

        (uint256 fullReward, uint32 multiplier) =
            fullRewards(provider, poolToken, reserveToken, poolRewardsData, providerRewards, program, lpStats);

        if (resetStakingTime) {
            if (multiplier == PPM_RESOLUTION) {
                providerRewards.baseRewardsDebt = fullReward;
            } else {
                providerRewards.baseRewardsDebt = fullReward.mul(PPM_RESOLUTION).div(multiplier);
            }
        } else {
            multiplier = PPM_RESOLUTION;

            providerRewards.baseRewardsDebt = fullReward;
        }

        _store.updateProviderRewardsData(
            provider,
            poolToken,
            reserveToken,
            providerRewards.rewardPerToken,
            0,
            providerRewards.totalClaimedRewards,
            resetStakingTime ? time() : providerRewards.effectiveStakingTime,
            providerRewards.baseRewardsDebt,
            multiplier
        );
    }

    function updateReserveRewards(
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private returns (PoolRewards memory) {

        PoolRewards memory poolRewardsData = poolRewards(poolToken, reserveToken);

        bool update = false;

        uint256 newRewardPerToken = rewardPerToken(poolToken, reserveToken, poolRewardsData, program, lpStats);
        if (poolRewardsData.rewardPerToken != newRewardPerToken) {
            poolRewardsData.rewardPerToken = newRewardPerToken;

            update = true;
        }

        uint256 newLastUpdateTime = Math.min(time(), program.endTime);
        if (poolRewardsData.lastUpdateTime != newLastUpdateTime) {
            poolRewardsData.lastUpdateTime = newLastUpdateTime;

            update = true;
        }

        if (update) {
            _store.updatePoolRewardsData(
                poolToken,
                reserveToken,
                poolRewardsData.lastUpdateTime,
                poolRewardsData.rewardPerToken,
                poolRewardsData.totalClaimedRewards
            );
        }

        return poolRewardsData;
    }

    function updateProviderRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolRewards memory poolRewardsData,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private returns (ProviderRewards memory) {

        ProviderRewards memory providerRewards = providerRewards(provider, poolToken, reserveToken);

        bool update = false;

        if (
            providerRewards.effectiveStakingTime == 0 &&
            lpStats.totalProviderAmount(provider, poolToken, reserveToken) == 0
        ) {
            providerRewards.effectiveStakingTime = time();

            update = true;
        }

        uint256 rewards =
            baseRewards(provider, poolToken, reserveToken, poolRewardsData, providerRewards, program, lpStats);
        if (rewards != 0) {
            providerRewards.pendingBaseRewards = providerRewards.pendingBaseRewards.add(rewards);

            update = true;
        }

        if (providerRewards.rewardPerToken != poolRewardsData.rewardPerToken) {
            providerRewards.rewardPerToken = poolRewardsData.rewardPerToken;

            update = true;
        }

        if (update) {
            _store.updateProviderRewardsData(
                provider,
                poolToken,
                reserveToken,
                providerRewards.rewardPerToken,
                providerRewards.pendingBaseRewards,
                providerRewards.totalClaimedRewards,
                providerRewards.effectiveStakingTime,
                providerRewards.baseRewardsDebt,
                providerRewards.baseRewardsDebtMultiplier
            );
        }

        return providerRewards;
    }

    function updateRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private returns (PoolRewards memory, ProviderRewards memory) {

        PoolRewards memory poolRewardsData = updateReserveRewards(poolToken, reserveToken, program, lpStats);
        ProviderRewards memory providerRewards =
            updateProviderRewards(provider, poolToken, reserveToken, poolRewardsData, program, lpStats);

        return (poolRewardsData, providerRewards);
    }

    function rewardPerToken(
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolRewards memory poolRewardsData,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private view returns (uint256) {

        uint256 totalReserveAmount = lpStats.totalReserveAmount(poolToken, reserveToken);
        if (totalReserveAmount == 0) {
            return poolRewardsData.rewardPerToken;
        }

        uint256 currentTime = time();
        if (currentTime < program.startTime) {
            return 0;
        }

        uint256 stakingEndTime = Math.min(currentTime, program.endTime);
        uint256 stakingStartTime = Math.max(program.startTime, poolRewardsData.lastUpdateTime);
        if (stakingStartTime == stakingEndTime) {
            return poolRewardsData.rewardPerToken;
        }

        return
            poolRewardsData.rewardPerToken.add( // the aggregated reward rate
                stakingEndTime
                    .sub(stakingStartTime) // the duration of the staking
                    .mul(program.rewardRate) // multiplied by the rate
                    .mul(REWARD_RATE_FACTOR) // and factored to increase precision
                    .mul(rewardShare(reserveToken, program)) // and applied the specific token share of the whole reward
                    .div(totalReserveAmount.mul(PPM_RESOLUTION)) // and divided by the total protected tokens amount in the pool
            );
    }

    function baseRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolRewards memory poolRewardsData,
        ProviderRewards memory providerRewards,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private view returns (uint256) {

        uint256 totalProviderAmount = lpStats.totalProviderAmount(provider, poolToken, reserveToken);
        uint256 newRewardPerToken = rewardPerToken(poolToken, reserveToken, poolRewardsData, program, lpStats);

        return
            totalProviderAmount // the protected tokens amount held by the provider
                .mul(newRewardPerToken.sub(providerRewards.rewardPerToken)) // multiplied by the difference between the previous and the current rate
                .div(REWARD_RATE_FACTOR); // and factored back
    }

    function fullRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken,
        PoolRewards memory poolRewardsData,
        ProviderRewards memory providerRewards,
        PoolProgram memory program,
        ILiquidityProtectionStats lpStats
    ) private view returns (uint256, uint32) {

        uint256 newBaseRewards =
            baseRewards(provider, poolToken, reserveToken, poolRewardsData, providerRewards, program, lpStats);

        verifyBaseReward(newBaseRewards, providerRewards.effectiveStakingTime, reserveToken, program);

        uint32 multiplier = rewardsMultiplier(provider, providerRewards.effectiveStakingTime, program);
        uint256 fullReward = providerRewards.pendingBaseRewards.add(newBaseRewards);
        if (multiplier != PPM_RESOLUTION) {
            fullReward = fullReward.mul(multiplier).div(PPM_RESOLUTION);
        }

        fullReward = fullReward.add(
            applyHigherMultiplier(
                providerRewards.baseRewardsDebt,
                multiplier,
                providerRewards.baseRewardsDebtMultiplier
            )
        );

        verifyFullReward(fullReward, reserveToken, poolRewardsData, program);

        return (fullReward, multiplier);
    }

    function rewardShare(IERC20 reserveToken, PoolProgram memory program) private pure returns (uint32) {

        if (reserveToken == program.reserveTokens[0]) {
            return program.rewardShares[0];
        }

        return program.rewardShares[1];
    }

    function rewardsMultiplier(
        address provider,
        uint256 stakingStartTime,
        PoolProgram memory program
    ) private view returns (uint32) {

        uint256 effectiveStakingEndTime = Math.min(time(), program.endTime);
        uint256 effectiveStakingStartTime =
            Math.max( // take the latest of actual staking start time and the latest multiplier reset
                Math.max(stakingStartTime, program.startTime), // don't count staking before the start of the program
                Math.max(_lastRemoveTimes.checkpoint(provider), _store.providerLastClaimTime(provider)) // get the latest multiplier reset timestamp
            );

        if (effectiveStakingStartTime >= effectiveStakingEndTime) {
            return PPM_RESOLUTION;
        }

        uint256 effectiveStakingDuration = effectiveStakingEndTime.sub(effectiveStakingStartTime);

        return PPM_RESOLUTION + MULTIPLIER_INCREMENT * uint32(Math.min(effectiveStakingDuration.div(1 weeks), 4));
    }

    function poolProgram(IDSToken poolToken) private view returns (PoolProgram memory) {

        PoolProgram memory program;
        (program.startTime, program.endTime, program.rewardRate, program.reserveTokens, program.rewardShares) = _store
            .poolProgram(poolToken);

        return program;
    }

    function poolRewards(IDSToken poolToken, IERC20 reserveToken) private view returns (PoolRewards memory) {

        PoolRewards memory data;
        (data.lastUpdateTime, data.rewardPerToken, data.totalClaimedRewards) = _store.poolRewards(
            poolToken,
            reserveToken
        );

        return data;
    }

    function providerRewards(
        address provider,
        IDSToken poolToken,
        IERC20 reserveToken
    ) private view returns (ProviderRewards memory) {

        ProviderRewards memory data;
        (
            data.rewardPerToken,
            data.pendingBaseRewards,
            data.totalClaimedRewards,
            data.effectiveStakingTime,
            data.baseRewardsDebt,
            data.baseRewardsDebtMultiplier
        ) = _store.providerRewards(provider, poolToken, reserveToken);

        return data;
    }

    function applyHigherMultiplier(
        uint256 amount,
        uint32 multiplier1,
        uint32 multiplier2
    ) private pure returns (uint256) {

        uint256 bestMultiplier = Math.max(multiplier1, multiplier2);
        if (bestMultiplier == PPM_RESOLUTION) {
            return amount;
        }

        return amount.mul(bestMultiplier).div(PPM_RESOLUTION);
    }

    function verifyBaseReward(
        uint256 baseReward,
        uint256 stakingStartTime,
        IERC20 reserveToken,
        PoolProgram memory program
    ) private view {

        uint256 currentTime = time();
        if (currentTime < program.startTime || stakingStartTime >= program.endTime) {
            require(baseReward == 0, "ERR_BASE_REWARD_TOO_HIGH");

            return;
        }

        uint256 effectiveStakingStartTime = Math.max(stakingStartTime, program.startTime);
        uint256 effectiveStakingEndTime = Math.min(currentTime, program.endTime);

        require(
            baseReward <=
                (program.rewardRate * REWARDS_HALVING_FACTOR)
                    .mul(effectiveStakingEndTime.sub(effectiveStakingStartTime))
                    .mul(rewardShare(reserveToken, program))
                    .div(PPM_RESOLUTION),
            "ERR_BASE_REWARD_RATE_TOO_HIGH"
        );
    }

    function verifyFullReward(
        uint256 fullReward,
        IERC20 reserveToken,
        PoolRewards memory poolRewardsData,
        PoolProgram memory program
    ) private pure {

        uint256 maxClaimableReward =
            (
                (program.rewardRate * REWARDS_HALVING_FACTOR)
                    .mul(program.endTime.sub(program.startTime))
                    .mul(rewardShare(reserveToken, program))
                    .mul(MAX_MULTIPLIER)
                    .div(PPM_RESOLUTION)
                    .div(PPM_RESOLUTION)
            )
                .sub(poolRewardsData.totalClaimedRewards);

        require(fullReward <= maxClaimableReward, "ERR_REWARD_RATE_TOO_HIGH");
    }

    function liquidityProtectionStats() private view returns (ILiquidityProtectionStats) {

        return liquidityProtection().stats();
    }

    function liquidityProtection() private view returns (ILiquidityProtection) {

        return ILiquidityProtection(addressOf(LIQUIDITY_PROTECTION));
    }
}