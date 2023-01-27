
pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
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


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) public payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view virtual override returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal virtual {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _admin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external virtual ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {

        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    function _admin() internal view virtual returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
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
}// MIT
pragma solidity 0.7.6;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init(address _ownerAddress) internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained(_ownerAddress);
    }

    function __Ownable_init_unchained(address _ownerAddress) internal initializer {
        _owner = _ownerAddress;
        emit OwnershipTransferred(address(0), _ownerAddress);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function safeTransferOwnership(address newOwner, bool safely) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        if (safely) {
            _pendingOwner = newOwner;
        } else {
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
            _pendingOwner = address(0);
        }
    }

    function safeAcceptOwnership() public virtual {
        require(_msgSender() == _pendingOwner, "acceptOwnership: Call must come from pendingOwner.");
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
    }

    uint256[48] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// GPL-3.0-or-later
pragma solidity 0.7.6;


library ArrayUtil {


    function findLowerBound(uint256[] memory array, uint256 element) internal pure returns (bool, uint256) {

        if (array.length == 0) {
            return (false, 0);
        }
        if (element < array[0]) {
            return (false, 0);
        }

        uint256 low = 0;
        uint256 high = array.length;
        uint256 mid;

        for (uint16 i = 0; i < 256; i ++) {
            mid = MathUpgradeable.average(low, high);

            if (element < array[mid]) {
                high = mid;
            } else if (element == array[mid] || low == mid) {
                break;
            } else {
                low = mid;
            }
        }
        return (true, mid);
    }
}// GPL-3.0-or-later
pragma solidity 0.7.6;
pragma abicoder v2;

interface IBaseNftUpgradeable {


    function initialize(
        address _nymLib,
        address _priceOracle,
        address _ownerAddress,
        string memory _name,
        string memory _symbol,
        string[] memory _metafileUris,
        uint256 _capacity,
        uint256 _price,
        bool _nameChangeable,
        bool _colorChangeable,
        bytes4[] memory _color
    ) external;


    function doAirdrop(address[] memory _accounts) external returns(uint256 leftCapacity);


}// GPL-3.0-or-later
pragma solidity 0.7.6;

interface IMultiModelNftUpgradeable {

    function doAirdrop(uint256 _modelId, address[] memory _accounts) external returns(uint256 leftCapacity);

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}// GPL-3.0-or-later
pragma solidity 0.7.6;


interface IPriceOracleUpgradeable {

    function zoneToken() external view returns(address);


    function lpZoneEth() external view returns(IUniswapV2Pair);


    function getOutAmount(address token, uint256 tokenAmount) external view returns (uint256);


    function mintPriceInZone(uint256 _mintPrice) external returns (uint256);


    function getLPFairPrice() external view returns (uint256);

}// GPL-3.0-or-later
pragma solidity 0.7.6;



contract LPStakingUpgradeable is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using AddressUpgradeable for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    struct Pool {
        address lpTokenAddress;
        uint256 lpSupply;
        uint256 poolWeight;
        uint256 lastRewardTime;
        uint256 accZONEPerLP; 
        uint256 pid;
    }

    struct User {
        uint256 lpAmount;     
        uint256 finishedZONE;
        uint256 lockStartTime;
    }

    uint256 private constant SECONDS_IN_DAY = 24 * 3600;

    uint256 private constant LP_LOCKED_AMOUNT = 5856918985268619881152;
    uint256 private constant LP_UNLOCK_DATE = 1661997600;

    uint256 public totalPoolWeight;
    Pool[] public pool;
    mapping (address => Pool) public poolMap;

    mapping (uint256 => mapping (address => User)) public user;
    uint256 public minDepositAmountInEth;

    bool public rewardInZoneEnabled;
    bool public rewardInNftEnabled;
    bool private _lpUnlockedFromUniswapV2Locker;

    uint256 public START_TIME;
    uint256 public lockPeriod;
    uint256 public zonePerMinute;

    uint256 private _totalFinishedZONE;
    uint256 private _lastFinishUpdateTime;
    uint256 public unusedZone;

    address[] public nftAddresses;
    uint256[] public nftModels;
    uint256[] public nftPrices;

    IERC20Upgradeable public zoneToken;
    IPriceOracleUpgradeable public priceOracle;

    address public governorTimelock;

    event SetLockPeriod(uint256 newLockPeriod);
    event SetZonePerMinute(uint256 newZonePerMinute);
    event SetMinDepositAmountInEth(uint256 newMinDepositAmountInEth);
    event EnableRewardInZone(bool enabled);
    event EnableRewardInNft(bool enabled);
    event AddPool(address indexed lpTokenAddress, uint256 indexed poolWeight, uint256 indexed lastRewardTime);
    event SetPoolWeight(uint256 indexed poolId, uint256 indexed poolWeight, uint256 totalPoolWeight);
    event UpdatePool(uint256 indexed poolId, uint256 indexed lastRewardTime, uint256 rewardToPool);
    event Deposit(address indexed account, uint256 indexed poolId, uint256 amount);
    event Withdraw(address indexed account, uint256 indexed poolId, uint256 amount);
    event RewardZone(address indexed account, uint256 indexed poolId, uint256 amount);
    event RewardNft(address indexed account, uint256 indexed poolId, address indexed rewardNftAddress, uint256 rewardNftModel, uint256 rewardNftPrice);
    event RemoveRewardNft(address indexed rewardNftAddress, uint256 indexed rewardNftModel, uint256 indexed rewardNftPrice);
    event EmergencyWithdraw(address indexed account, uint256 indexed poolId, uint256 amount);

    modifier onlyOwnerOrCommunity() {

        address sender = _msgSender();
        require((owner() == sender) || (governorTimelock == sender), "The caller should be owner or governor");
        _;
    }

    function initialize(
        address _ownerAddress,
        address _priceOracle,
        uint256 _zonePerMinute,
        uint256 _minDepositAmountInEth,
        address[] memory _nftAddresses,
        uint256[] memory _nftModels,
        uint256[] memory _nftPrices
    ) public initializer {

        require(_ownerAddress != address(0), "Owner address is invalid");
        require(_priceOracle != address(0), "Price oracle address is invalid");

        __Ownable_init(_ownerAddress);
        __ReentrancyGuard_init();

        rewardInZoneEnabled = true;
        rewardInNftEnabled = true;

        lockPeriod = 180 * SECONDS_IN_DAY; // 180 days by default
        START_TIME = block.timestamp;
        _lastFinishUpdateTime = START_TIME;

        priceOracle = IPriceOracleUpgradeable(_priceOracle);
        zoneToken = IERC20Upgradeable(priceOracle.zoneToken());
        zonePerMinute = _zonePerMinute;
        minDepositAmountInEth = _minDepositAmountInEth;
        _setRewardNfts(_nftAddresses, _nftModels, _nftPrices);

        _addPool(address(priceOracle.lpZoneEth()), 100, false);
        pool[0].lpSupply = LP_LOCKED_AMOUNT;
    }

    function setGovernorTimelock(address _governorTimelock) external onlyOwner()  {

        governorTimelock = _governorTimelock;
    }

    function setLockPeriod(uint256 _lockPeriod) external onlyOwnerOrCommunity() {

        require(SECONDS_IN_DAY * 30 <= _lockPeriod, "lockDay should be equal or greater than 30 day");
        lockPeriod = _lockPeriod;
        emit SetLockPeriod(lockPeriod);
    }

    function setZonePerMinute(uint256 _zonePerMinute) external onlyOwnerOrCommunity() {

        _setZonePerMinute(_zonePerMinute);
    }

    function _setZonePerMinute(uint256 _zonePerMinute) private {

        massUpdatePools();

        uint256 multiplier = _getMultiplier(_lastFinishUpdateTime, block.timestamp);
        _totalFinishedZONE = _totalFinishedZONE.add(multiplier.mul(zonePerMinute));
        _lastFinishUpdateTime = block.timestamp;

        zonePerMinute = _zonePerMinute;
        emit SetZonePerMinute(zonePerMinute);
    }

    function setMinDepositAmountInEth(uint256 _minDepositAmountInEth) external onlyOwnerOrCommunity() {

        minDepositAmountInEth = _minDepositAmountInEth;
        emit SetMinDepositAmountInEth(minDepositAmountInEth);
    }

    function finish() external onlyOwnerOrCommunity() {

        if (0 < zonePerMinute) {
            _setZonePerMinute(0);
        }
        uint256 length = poolLength();
        for (uint256 pid = 0; pid < length; pid++) {
            Pool memory pool_ = pool[pid];
            if (0 < pool_.lpSupply) {
                return;
            }
        }
        uint256 zoneBalance = zoneToken.balanceOf(address(this));
        if (0 < zoneBalance) {
            zoneToken.safeTransfer(owner(), zoneBalance);
        }
    }

    function enableRewardInZone(bool _enable) external onlyOwnerOrCommunity() {

        rewardInZoneEnabled = _enable;
        emit EnableRewardInZone(rewardInZoneEnabled);
    }

    function enableRewardInNft(bool _enable) external onlyOwnerOrCommunity() {

        rewardInNftEnabled = _enable;
        emit EnableRewardInNft(rewardInNftEnabled);
    }

    function setRewardNfts(
        address[] memory _contractAddresses,
        uint256[] memory _modelIds,
        uint256[] memory _pricesInEth
    ) external onlyOwner() {

        _setRewardNfts(_contractAddresses, _modelIds, _pricesInEth);
    }

    function _setRewardNfts(
        address[] memory _contractAddresses,
        uint256[] memory _modelIds,
        uint256[] memory _pricesInEth
    ) internal {

        require(
            _contractAddresses.length == _modelIds.length
            && _contractAddresses.length == _pricesInEth.length,
            "Mismatched data"
        );

        nftAddresses = _contractAddresses;
        nftModels = _modelIds;
        nftPrices = _pricesInEth;
    }

    function _getMultiplier(uint256 _from, uint256 _to) internal pure returns(uint256 multiplier) {

        return _to.sub(_from).div(60);
    }

    function pendingZONE(uint256 _pid, address _account) public view returns(uint256) {

        Pool storage pool_ = pool[_pid];
        if (pool_.lpSupply == 0) {
            return 0;
        }

        User storage user_ = user[_pid][_account];
        uint256 accZONEPerLP = pool_.accZONEPerLP;

        if (pool_.lastRewardTime < block.timestamp) {
            uint256 multiplier = _getMultiplier(pool_.lastRewardTime, block.timestamp);
            uint256 rewardToPool = multiplier.mul(zonePerMinute).mul(pool_.poolWeight).div(totalPoolWeight);
            accZONEPerLP = accZONEPerLP.add(rewardToPool.mul(1 ether).div(pool_.lpSupply));
        }

        return user_.lpAmount.mul(accZONEPerLP).div(1 ether).sub(user_.finishedZONE);
    }

    function totalFinishedZONE() public view returns(uint256) {

        uint256 multiplier = _getMultiplier(_lastFinishUpdateTime, block.timestamp);
        return _totalFinishedZONE.add(multiplier.mul(zonePerMinute));
    }

    function poolLength() public view returns(uint256) {

        return pool.length;
    }

    function addPool(address _lpTokenAddress, uint256 _poolWeight, bool _withUpdate) external onlyOwner() {

        _addPool(_lpTokenAddress, _poolWeight, _withUpdate);
    }

    function _addPool(address _lpTokenAddress, uint256 _poolWeight, bool _withUpdate) private {

        require(_lpTokenAddress.isContract(), "LP token address should be smart contract address");
        require(poolMap[_lpTokenAddress].lpTokenAddress == address(0), "LP token already added");

        if (_withUpdate) {
            massUpdatePools();
        }
        
        uint256 lastRewardTime = START_TIME < block.timestamp ? block.timestamp : START_TIME;
        totalPoolWeight = totalPoolWeight + _poolWeight;

        Pool memory newPool_ = Pool({
            lpTokenAddress: _lpTokenAddress,
            lpSupply: 0,
            poolWeight: _poolWeight,
            lastRewardTime: lastRewardTime,
            accZONEPerLP: 0,
            pid: poolLength()
        });

        pool.push(newPool_);
        poolMap[_lpTokenAddress] = newPool_;

        emit AddPool(_lpTokenAddress, _poolWeight, lastRewardTime);
    }

    function setPoolWeight(uint256 _pid, uint256 _poolWeight, bool _withUpdate) external onlyOwnerOrCommunity() {

        if (_withUpdate) {
            massUpdatePools();
        }

        totalPoolWeight = totalPoolWeight.sub(pool[_pid].poolWeight).add(_poolWeight);
        pool[_pid].poolWeight = _poolWeight;

        emit SetPoolWeight(_pid, _poolWeight, totalPoolWeight);
    }

    function updatePool(uint256 _pid) public {

        Pool storage pool_ = pool[_pid];
        if (block.timestamp <= pool_.lastRewardTime) {
            return;
        }

        uint256 multiplier = _getMultiplier(pool_.lastRewardTime, block.timestamp);
        uint256 rewardToPool = multiplier.mul(zonePerMinute).mul(pool_.poolWeight).div(totalPoolWeight);

        if (0 < pool_.lpSupply) {
            pool_.accZONEPerLP = pool_.accZONEPerLP.add(rewardToPool.mul(1 ether).div(pool_.lpSupply));
        } else {
            unusedZone = unusedZone.add(rewardToPool);
        }

        if (_pid == 0 && _lpUnlockedFromUniswapV2Locker == false && LP_UNLOCK_DATE < block.timestamp) {
            pool_.lpSupply = pool_.lpSupply.sub(LP_LOCKED_AMOUNT);
            _lpUnlockedFromUniswapV2Locker = true;
        }

        pool_.lastRewardTime = block.timestamp;
        emit UpdatePool(_pid, pool_.lastRewardTime, rewardToPool);
    }

    function massUpdatePools() public {

        uint256 length = poolLength();
        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    function _getClaimIn(uint256 _lockStartTime) internal view returns(uint256) {

        uint256 endTs = _lockStartTime.add(lockPeriod);
        return (block.timestamp < endTs) ? endTs - block.timestamp : 0;
    }

    function _chooseRewardNft(uint256 _zoneAmount) internal view returns(bool, uint256) {

        uint256 rewardAmountInEth = priceOracle.getOutAmount(address(zoneToken), _zoneAmount);
        (bool found, uint256 index) = ArrayUtil.findLowerBound(nftPrices, rewardAmountInEth);
        return (found, index);
    }

    function getStakeInfo(uint256 _pid, address _account) external view returns (
        uint256 stakedAmount,
        uint256 claimIn,
        uint256 rewardAmount,
        address rewardNftAddress,
        uint256 rewardNftModel,
        uint256 rewardNftPrice
    ) {

        User storage user_ = user[_pid][_account];
        if (user_.lpAmount == 0) {
            return (0, 0, 0, address(0), 0, 0);
        }

        stakedAmount = user_.lpAmount;
        claimIn = _getClaimIn(user_.lockStartTime);
        rewardAmount = pendingZONE(_pid, _account);

        (bool found, uint256 index) = _chooseRewardNft(rewardAmount);
        if (found == true) {
            rewardNftAddress = nftAddresses[index];
            rewardNftModel = nftModels[index];
            rewardNftPrice = nftPrices[index];
        }
    }

    function getMinDepositLpAmount() public view returns(uint256) {

        uint256 lpPriceInEth = priceOracle.getLPFairPrice();
        return (0 < minDepositAmountInEth && 0 < lpPriceInEth) ? minDepositAmountInEth.mul(1e18).div(lpPriceInEth) : 0;
    }

    function deposit(uint256 _pid, uint256 _amount) external nonReentrant() {

        require(0 < _pid || minDepositAmountInEth == 0 || getMinDepositLpAmount() <= _amount, "The worth of LP amount should greater than minimum value");

        address _account = _msgSender();
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][_account];

        updatePool(_pid);

        uint256 pendingZONE_;
        if (user_.lpAmount > 0) {
            pendingZONE_ = user_.lpAmount.mul(pool_.accZONEPerLP).div(1 ether).sub(user_.finishedZONE);
        } else {
            user_.lockStartTime = block.timestamp;
        }

        if(_amount > 0) {
            uint256 prevSupply = IERC20Upgradeable(pool_.lpTokenAddress).balanceOf(address(this));
            IERC20Upgradeable(pool_.lpTokenAddress).safeTransferFrom(_account, address(this), _amount);
            uint256 newSupply = IERC20Upgradeable(pool_.lpTokenAddress).balanceOf(address(this));
            uint256 depositedAmount = newSupply.sub(prevSupply);
            user_.lpAmount = user_.lpAmount.add(depositedAmount);
            pool_.lpSupply = pool_.lpSupply.add(depositedAmount);
        }

        user_.finishedZONE = user_.lpAmount.mul(pool_.accZONEPerLP).div(1 ether).sub(pendingZONE_);
        emit Deposit(_account, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant() {

        address _account = _msgSender();
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][_account];
        require(_amount <= user_.lpAmount, "Not enough LP token balance");

        updatePool(_pid);

        uint256 pendingZONE_ = user_.lpAmount.mul(pool_.accZONEPerLP).div(1 ether).sub(user_.finishedZONE);
        uint256 claimIn = _getClaimIn(user_.lockStartTime);
        if(0 < pendingZONE_ && claimIn == 0) {
            _reward(_pid, _account, pendingZONE_);
            pendingZONE_ = 0;
        } else if(0 < _amount) {
            pendingZONE_ = pendingZONE_.mul(user_.lpAmount.sub(_amount)).div(user_.lpAmount);
        }
        user_.lockStartTime = block.timestamp;

        if(0 < _amount) {
            pool_.lpSupply = pool_.lpSupply.sub(_amount);
            user_.lpAmount = user_.lpAmount.sub(_amount);
            IERC20Upgradeable(pool_.lpTokenAddress).safeTransfer(_account, _amount);
        }

        user_.finishedZONE = user_.lpAmount.mul(pool_.accZONEPerLP).div(1 ether).sub(pendingZONE_);
        emit Withdraw(_account, _pid, _amount);
    }

    function claim(uint256 _pid) external nonReentrant() {

        address _account = _msgSender();
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][_account];

        updatePool(_pid);

        uint256 pendingZONE_ = user_.lpAmount.mul(pool_.accZONEPerLP).div(1 ether).sub(user_.finishedZONE);
        require(0 < pendingZONE_, "No pending ZONE to reward");

        uint256 claimIn = _getClaimIn(user_.lockStartTime);
        require(claimIn == 0, "The reward not allowed yet. please wait for more"); 

        _reward(_pid, _account, pendingZONE_);

        user_.finishedZONE = user_.lpAmount.mul(pool_.accZONEPerLP).div(1 ether);
    }

    function _reward(uint256 _pid, address _account, uint256 _pendingZONE) private {

        if (rewardInZoneEnabled) {
            _safeZONETransfer(_account, _pendingZONE);
            emit RewardZone(_account, _pid, _pendingZONE);
        }

        if (rewardInNftEnabled) {
            (bool found, uint256 index) = _chooseRewardNft(_pendingZONE);
            if (found == true) {
                address rewardNftAddress = nftAddresses[index];
                uint256 rewardNftModel = nftModels[index];
                uint256 rewardNftPrice = nftPrices[index];

                uint256 leftCapacity;
                if (rewardNftModel != type(uint256).max) {
                    IMultiModelNftUpgradeable multiModelNft = IMultiModelNftUpgradeable(rewardNftAddress);
                    address[] memory addresses = new address[](1);
                    addresses[0] = _account;
                    leftCapacity = multiModelNft.doAirdrop(rewardNftModel, addresses);
                } else {
                    IBaseNftUpgradeable baseNft = IBaseNftUpgradeable(rewardNftAddress);
                    address[] memory addresses = new address[](1);
                    addresses[0] = _account;
                    leftCapacity = baseNft.doAirdrop(addresses);
                }
                emit RewardNft(_account, _pid, rewardNftAddress, rewardNftModel, rewardNftPrice);

                if (leftCapacity == 0) {
                    nftAddresses[index] = nftAddresses[nftAddresses.length - 1];
                    nftAddresses.pop();
                    nftModels[index] = nftModels[nftModels.length - 1];
                    nftModels.pop();
                    nftPrices[index] = nftPrices[nftPrices.length - 1];
                    nftPrices.pop();
                    emit RemoveRewardNft(rewardNftAddress, rewardNftModel, rewardNftPrice);
                }
            }
        }
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant() {

        address _account = _msgSender();
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][_account];

        uint256 amount = user_.lpAmount;
        user_.lpAmount = 0;
        pool_.lpSupply = pool_.lpSupply.sub(amount);
        IERC20Upgradeable(pool_.lpTokenAddress).safeTransfer(_account, amount);
        emit EmergencyWithdraw(_account, _pid, amount);
    }

    function _safeZONETransfer(address _to, uint256 _amount) internal {

        uint256 balance = zoneToken.balanceOf(address(this));
        
        if (balance < _amount) {
            zoneToken.safeTransfer(_to, balance);
        } else {
            zoneToken.safeTransfer(_to, _amount);
        }
    }

    function fund(address _from, uint256 _amount) external {

        require(_from != address(0), '_from is invalid');
        require(0 < _amount, '_amount is invalid');
        require(_amount <= zoneToken.balanceOf(_from), 'Insufficient balance');
        zoneToken.safeTransferFrom(_from, address(this), _amount);
    }

    uint256[32] private __gap;
}

contract LPStakingUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) public {
    }
}