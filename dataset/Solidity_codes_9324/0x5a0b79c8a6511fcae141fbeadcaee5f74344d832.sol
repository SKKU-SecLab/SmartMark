
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


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
}

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
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;


    function _ReentrancyGuard() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

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
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

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
}

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
}

interface IERC20Decimals {

    function decimals() external pure returns (uint8);

}

interface IMintable {

    function mint(address account, uint256 amount) external;

}

interface IBurnable {

    function burnFrom(address account, uint256 amount) external;

}

interface IOracle {

    function getLatestPrice() external view returns (uint256);

}

interface IWrappedNativeToken {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}

interface IFlashLoanReceiver {

    function execute(address token, uint256 amount, uint256 fee, address back, bytes calldata params) external;

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
}

contract Admined is AccessControl {

    function _Admined(address admin) internal {

        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    modifier onlyAdmin() {

        require(isAdmin(msg.sender), "Restricted to admins");
        _;
    }

    function isAdmin(address account) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function getAdminCount() public view returns(uint256) {

        return getRoleMemberCount(DEFAULT_ADMIN_ROLE);
    }

    function addAdmin(address account) public virtual onlyAdmin {

        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function renounceAdmin() public virtual {

        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
        require(
            getRoleMemberCount(DEFAULT_ADMIN_ROLE) >= 1,
            "At least one admin required"
        );
    }

    uint256[50] private __gap;
}

contract Owned is Admined {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    event AddedOwner(address indexed account);
    event RemovedOwner(address indexed account);
    event RenouncedOwner(address indexed account);

    function _Owned(address admin, address owner) internal {

        _Admined(admin);
        _setRoleAdmin(OWNER_ROLE, DEFAULT_ADMIN_ROLE);
        _setupRole(OWNER_ROLE, owner);
    }

    modifier onlyOwner() {

        require(isOwner(msg.sender), "restricted-to-owners");
        _;
    }

    function isOwner(address account) public view returns (bool) {

        return hasRole(OWNER_ROLE, account);
    }

    function getOwners() public view returns (address[] memory) {

        uint256 count = getRoleMemberCount(OWNER_ROLE);
        address[] memory owners = new address[](count);
        for (uint256 i = 0; i < count; ++i) {
            owners[i] = getRoleMember(OWNER_ROLE, i);
        }
        return owners;
    }

    function addOwner(address account) public onlyAdmin {

        grantRole(OWNER_ROLE, account);
        emit AddedOwner(account);
    }

    function removeOwner(address account) public onlyAdmin {

        revokeRole(OWNER_ROLE, account);
        emit RemovedOwner(account);
    }

    function renounceOwner() public {

        renounceRole(OWNER_ROLE, msg.sender);
        emit RenouncedOwner(msg.sender);
    }

    uint256[50] private __gap;
}

contract Lockable is Owned {

    
    mapping(bytes4 => bool) public disabledList; 
    bool public globalDisable; 

    function _Lockable() internal {

    }

    modifier notLocked() {

        require(!globalDisable && !disabledList[msg.sig], "locked");
        _;
    }

    function enableListAccess(bytes4 sig) public onlyOwner {

        disabledList[sig] = false;
    }

    function disableListAccess(bytes4 sig) public onlyOwner {

        disabledList[sig] = true;
    }

    function enableGlobalAccess() public onlyOwner {

        globalDisable = false;
    }

    function disableGlobalAccess() public onlyOwner {

        globalDisable = true;
    }

    uint256[50] private __gap;
}

contract Vault is Initializable, ReentrancyGuard, Lockable {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    event MintCollateral(address indexed sender, address indexed collateralToken, uint256 collateralAmount, uint256 mintAmount, uint256 mintFeeAmount);
    event MintShare(address indexed sender, uint256 shareAmount, uint256 mintAmount);
    event MintCollateralAndShare(address indexed sender, address indexed collateralToken, uint256 collateralAmount, uint256 shareAmount, uint256 mintAmount, uint256 mintFeeCollateralAmount, uint256 globalCollateralRatio);
    event RedeemCollateral(address indexed sender, uint256 stableAmount, address indexed collateralToken, uint256 redeemAmount, uint256 redeemFeeAmount);
    event RedeemShare(address indexed sender, uint256 shareAmount, uint256 redeemAmount);
    event RedeemCollateralAndShare(address indexed sender, uint256 stableAmount, address indexed collateralToken, uint256 redeemCollateralAmount, uint256 redeemShareAmount, uint256 redeemCollateralFeeAmount, uint256 globalCollateralRatio);
    event ExchangeShareBond(address indexed sender, uint256 shareBondAmount);
    event Recollateralize(address indexed sender, uint256 recollateralizeAmount, address indexed collateralToken, uint256 paidbackShareAmount);
    event Buyback(address indexed sender, uint256 shareAmount, address indexed receivedCollateralToken, uint256 buybackAmount, uint256 buybackFeeAmount);
    event FlashLoan(address indexed receiver, address indexed token, uint256 amount, uint256 fee, uint256 timestamp);

    address constant public NATIVE_TOKEN_ADDRESS = address(0x0000000000000000000000000000000000000000);
    uint256 constant public TARGET_PRICE = 1000000000000000000; //$1
    uint256 constant public SHARE_TOKEN_PRECISION = 1000000000000000000;    //1e18
    uint256 constant public STABLE_TOKEN_PRECISION = 1000000000000000000;   //1e18
    uint256 constant public DELAY_CLAIM_BLOCK = 3;  //prevent flash redeem!! 

    uint256 public redeemFee;               //赎回手续费率 [1e18] 0.45% => 4500000000000000
    uint256 public mintFee;                 //增发手续费率 [1e18] 0.45% => 4500000000000000
    uint256 public buybackFee;              //回购手续费率 [1e18] 0.45% => 4500000000000000
    uint256 public globalCollateralRatio;   //全局质押率 [1e18] 1000000000000000000
    uint256 public flashloanFee;            //闪电贷手续费率
    uint256 public shareBondCeiling;        //股份币债券发行上限.
    uint256 public shareBondSupply;         //股份币债券当前发行量
    uint256 public lastRefreshTime;         //全局质押率的最后调节时间.

    uint256 public refreshStep;             //全局质押率的单次调节幅度 [1e18] 0.05 => 50000000000000000
    uint256 public refreshPeriod;           //全局质押率的调节周期(seconds)
    uint256 public refreshBand;             //全局质押率的调节线 [1e18] 0.05 => 50000000000000000 

    address public stableToken;             //stable token
    address public shareToken;              //share token
    address public stableBondToken;         //锚定稳定币的债券代币, 在适当的时候可以赎回. [废弃]
    address public shareBondToken;          //锚定股份币的债券代币, 在适当的时候可以赎回 
    address payable public protocolFund;    //收益基金

    struct Collateral {
        bool deprecated;                    //抵押物废弃标记 
        uint256 recollateralizeFee;         //在抵押奖励率 [1e18]
        uint256 ceiling;                    //抵押物的铸币上限
        uint256 precision;                  //抵押物的精度
        address oracle;                     //抵押物的预言机
    }

    mapping(address => uint256) public lastRedeemBlock;         //账户的最后赎回交易块号. account => block.number
    mapping(address => uint256) public redeemedShareBonds;      //账户已赎回但未取回的share代币总量. account => shareAmount
    mapping(address => uint256) public unclaimedCollaterals;    //系统内已赎回但未取回的某抵押物总量. collateralToken => collateralAmount
    mapping(address => mapping(address => uint256)) public redeemedCollaterals; //账户已赎回但未取回的某抵押物总量. account => token => amount
    
    address public shareTokenOracle;
    address public stableTokenOracle;
    
    EnumerableSet.AddressSet private collateralTokens;  //抵押物代币集合.
    mapping(address => Collateral) public collaterals;  //抵押物配置. collateralToken => Collateral 

    address public wrappedNativeToken;    
    bool public kbtToKunImmediately;
    uint256 public buybackBonus;

    function initialize(
        address _stableToken,
        address _shareToken,
        address _shareBondToken,
        address _wrappedNativeToken,
        address _admin,
        address _stableTokenOracle,
        address _shareTokenOracle
    ) public initializer {

        _Owned(_admin, msg.sender); 
        _ReentrancyGuard();
        stableToken = _stableToken;
        shareToken = _shareToken;
        wrappedNativeToken = _wrappedNativeToken;
        shareBondToken = _shareBondToken;
        stableTokenOracle = _stableTokenOracle;
        shareTokenOracle = _shareTokenOracle;
        globalCollateralRatio = 1e18;
    }

    function calculateCollateralValue(address collateralToken, uint256 collateralAmount) public view returns (uint256) {

        return collateralAmount.mul(getCollateralPrice(collateralToken)).div(collaterals[collateralToken].precision); 
    }

    function calculateCollateralMintAmount(address collateralToken, uint256 collateralAmount) public view returns (uint256, uint256) {

        uint256 mintFeeAmount = collateralAmount.mul(mintFee).div(1e18);
        collateralAmount = collateralAmount.sub(mintFeeAmount);
        return (calculateCollateralValue(collateralToken, collateralAmount), mintFeeAmount);
    }

    function calculateShareMintAmount(uint256 shareAmount) public view returns(uint256) {

        return shareAmount.mul(getShareTokenPrice()).div(SHARE_TOKEN_PRECISION);
    }


    function calculateCollateralAndShareMintAmount(address collateralToken, uint256 collateralAmount) public view returns(uint256, uint256, uint256) {

        uint256 collateralValue = calculateCollateralValue(collateralToken, collateralAmount);
        uint256 shareTokenPrice = getShareTokenPrice();

        uint256 shareValue = collateralValue.mul(1e18).div(globalCollateralRatio).sub(collateralValue);
        uint256 shareAmount = shareValue.mul(SHARE_TOKEN_PRECISION).div(shareTokenPrice);

        uint256 mintFeeValue = collateralValue.mul(mintFee).div(1e18);
        uint256 mintFeeCollateralAmount = calculateEquivalentCollateralAmount(mintFeeValue, collateralToken);
        
        uint256 mintAmount = collateralValue.sub(mintFeeValue).add(shareValue); 
        return (mintAmount, shareAmount, mintFeeCollateralAmount);
    }

    function calculateCollateralRedeemAmount(uint256 stableAmount, address collateralToken) public view returns (uint256, uint256) {

        uint256 redeemAmount = calculateEquivalentCollateralAmount(stableAmount, collateralToken);
        uint256 redeemFeeAmount = redeemAmount.mul(redeemFee).div(1e18);
        return (redeemAmount.sub(redeemFeeAmount), redeemFeeAmount);
    }

    function calculateShareRedeemAmount(uint256 stableAmount) public view returns (uint256) {

        uint256 shareAmount = stableAmount.mul(SHARE_TOKEN_PRECISION).div(getShareTokenPrice());
        return shareAmount;
    }


    function calculateCollateralAndShareRedeemAmount(uint256 stableAmount, address collateralToken) public view returns (uint256, uint256, uint256) {

        uint256 collateralValue = stableAmount.mul(globalCollateralRatio).div(1e18);
        uint256 collateralAmount = calculateEquivalentCollateralAmount(collateralValue, collateralToken);

        uint256 shareValue = stableAmount.sub(collateralValue);
        uint256 shareAmount = shareValue.mul(SHARE_TOKEN_PRECISION).div(getShareTokenPrice());

        uint256 redeemFeeCollateralAmount = collateralAmount.mul(redeemFee).div(1e18);
        
        return (collateralAmount.sub(redeemFeeCollateralAmount), shareAmount, redeemFeeCollateralAmount);
    }

    function calculateEquivalentCollateralAmount(uint256 stableAmount, address collateralToken) public view returns (uint256) {

        return stableAmount.mul(collaterals[collateralToken].precision).div(getCollateralPrice(collateralToken));    //1e18
    }

    function mint(address collateralToken, uint256 collateralAmount, uint256 minimumReceived) external payable notLocked nonReentrant {

        require(isCollateralToken(collateralToken) && !collaterals[collateralToken].deprecated, "invalid/deprecated-collateral-token");
        require(globalCollateralRatio >= 1e18, "mint-not-allowed");
        (uint256 mintAmount, uint256 mintFeeAmount) = calculateCollateralMintAmount(collateralToken, collateralAmount);
        require(minimumReceived <= mintAmount, "slippage-limit-reached");
        require(getCollateralizedBalance(collateralToken).add(collateralAmount) <= collaterals[collateralToken].ceiling, "ceiling-reached");

        _depositFrom(collateralToken, msg.sender, collateralAmount);
        _withdrawTo(collateralToken, protocolFund, mintFeeAmount);

        IMintable(stableToken).mint(msg.sender, mintAmount);
        emit MintCollateral(msg.sender, collateralToken, collateralAmount, mintAmount, mintFeeAmount);
    }

    function mint(uint256 shareAmount, uint256 minimumReceived) external notLocked nonReentrant {

        require(globalCollateralRatio == 0, "mint-not-allowed");
        uint256 mintAmount = calculateShareMintAmount(shareAmount);
        require(minimumReceived <= mintAmount, "slippage-limit-reached");
        IBurnable(shareToken).burnFrom(msg.sender, shareAmount);
        IMintable(stableToken).mint(msg.sender, mintAmount);
        emit MintShare(msg.sender, shareAmount, mintAmount);
    }

    function mint(address collateralToken, uint256 collateralAmount, uint256 shareAmount, uint256 minimumReceived) external payable notLocked nonReentrant {

        require(isCollateralToken(collateralToken) && !collaterals[collateralToken].deprecated, "invalid/deprecated-collateral-token");
        require(globalCollateralRatio < 1e18 && globalCollateralRatio > 0, "mint-not-allowed");
        require(getCollateralizedBalance(collateralToken).add(collateralAmount) <= collaterals[collateralToken].ceiling, "ceiling-reached");
        (uint256 mintAmount, uint256 shareNeeded, uint256 mintFeeCollateralAmount) = calculateCollateralAndShareMintAmount(collateralToken, collateralAmount);
        require(minimumReceived <= mintAmount, "slippage-limit-reached");
        require(shareNeeded <= shareAmount, "need-more-shares");
        
        IBurnable(shareToken).burnFrom(msg.sender, shareNeeded);

        _depositFrom(collateralToken, msg.sender, collateralAmount);
        _withdrawTo(collateralToken, protocolFund, mintFeeCollateralAmount);

        IMintable(stableToken).mint(msg.sender, mintAmount);
        emit MintCollateralAndShare(msg.sender, collateralToken, collateralAmount, shareNeeded, mintAmount, mintFeeCollateralAmount, globalCollateralRatio);
    }

    function redeem(uint256 stableAmount, address receivedCollateralToken, uint256 minimumReceivedCollateralAmount) external notLocked nonReentrant {

        require(globalCollateralRatio == 1e18, "redeem-not-allowed");
        (uint256 redeemAmount, uint256 redeemFeeAmount) = calculateCollateralRedeemAmount(stableAmount, receivedCollateralToken);
        require(redeemAmount.add(redeemFeeAmount) <= getCollateralizedBalance(receivedCollateralToken), "not-enough-collateral");
        require(minimumReceivedCollateralAmount <= redeemAmount, "slippage-limit-reached");
        redeemedCollaterals[msg.sender][receivedCollateralToken] = redeemedCollaterals[msg.sender][receivedCollateralToken].add(redeemAmount);
        unclaimedCollaterals[receivedCollateralToken] = unclaimedCollaterals[receivedCollateralToken].add(redeemAmount);
        lastRedeemBlock[msg.sender] = block.number;
        IBurnable(stableToken).burnFrom(msg.sender, stableAmount);
        _withdrawTo(receivedCollateralToken, protocolFund, redeemFeeAmount);
        emit RedeemCollateral(msg.sender, stableAmount, receivedCollateralToken, redeemAmount, redeemFeeAmount);
    }

    function redeem(uint256 stableAmount, address collateralToken, uint256 minimumReceivedCollateralAmount, uint256 minimumReceivedShareAmount) external notLocked nonReentrant {

        require(globalCollateralRatio < 1e18 && globalCollateralRatio > 0, "redeem-not-allowed");
        (uint256 collateralAmount, uint256 shareAmount, uint256 redeemFeeCollateralAmount) = calculateCollateralAndShareRedeemAmount(stableAmount, collateralToken);
        require(collateralAmount.add(redeemFeeCollateralAmount) <= getCollateralizedBalance(collateralToken), "not-enough-collateral");
        require(minimumReceivedCollateralAmount <= collateralAmount && minimumReceivedShareAmount <= shareAmount, "collaterals/shares-slippage-limit-reached");
        redeemedCollaterals[msg.sender][collateralToken] = redeemedCollaterals[msg.sender][collateralToken].add(collateralAmount);
        unclaimedCollaterals[collateralToken] = unclaimedCollaterals[collateralToken].add(collateralAmount);
        redeemedShareBonds[msg.sender] = redeemedShareBonds[msg.sender].add(shareAmount);
        shareBondSupply = shareBondSupply.add(shareAmount);
        require(shareBondSupply <= shareBondCeiling, "sharebond-ceiling-reached");
        lastRedeemBlock[msg.sender] = block.number;
        IBurnable(stableToken).burnFrom(msg.sender, stableAmount);
        _withdrawTo(collateralToken, protocolFund, redeemFeeCollateralAmount);
        emit RedeemCollateralAndShare(msg.sender, stableAmount, collateralToken, collateralAmount, shareAmount, redeemFeeCollateralAmount, globalCollateralRatio);
    }

    function redeem(uint256 stableAmount, uint256 minimumReceivedShareAmount) external notLocked nonReentrant {

        require(globalCollateralRatio == 0, "redeem-not-allowed");
        uint256 shareAmount = calculateShareRedeemAmount(stableAmount);
        require(minimumReceivedShareAmount <= shareAmount, "slippage-limit-reached");
        redeemedShareBonds[msg.sender] = redeemedShareBonds[msg.sender].add(shareAmount);
        shareBondSupply = shareBondSupply.add(shareAmount);
        require(shareBondSupply <= shareBondCeiling, "sharebond-ceiling-reached");
        lastRedeemBlock[msg.sender] = block.number;
        IBurnable(stableToken).burnFrom(msg.sender, stableAmount);
        emit RedeemShare(msg.sender, stableAmount, shareAmount);
    }

    function claim() external notLocked nonReentrant {

        require(lastRedeemBlock[msg.sender].add(DELAY_CLAIM_BLOCK) <= block.number,"not-delay-claim-redeemed");
        uint256 length = collateralTokens.length();
        for (uint256 i = 0; i < length; ++i) {
            address collateralToken = collateralTokens.at(i);
            if (redeemedCollaterals[msg.sender][collateralToken] > 0) {
                uint256 collateralAmount = redeemedCollaterals[msg.sender][collateralToken];
                redeemedCollaterals[msg.sender][collateralToken] = 0;
                unclaimedCollaterals[collateralToken] = unclaimedCollaterals[collateralToken].sub(collateralAmount);
                _withdrawTo(collateralToken, msg.sender, collateralAmount);
            }
        }
        if (redeemedShareBonds[msg.sender] > 0) {
            uint256 shareAmount = redeemedShareBonds[msg.sender];
            redeemedShareBonds[msg.sender] = 0;
            IMintable(shareBondToken).mint(msg.sender, shareAmount);
        }
    }

    function recollateralize(address collateralToken, uint256 collateralAmount, uint256 minimumReceivedShareAmount) external payable notLocked nonReentrant {

        require(isCollateralToken(collateralToken) && !collaterals[collateralToken].deprecated, "deprecated-collateral-token");
        
        uint256 gapCollateralValue = getGapCollateralValue();
        require(gapCollateralValue > 0, "no-gap-collateral-to-recollateralize");
        uint256 recollateralizeValue = Math.min(gapCollateralValue, calculateCollateralValue(collateralToken, collateralAmount));
        uint256 paidbackShareAmount = recollateralizeValue.mul(uint256(1e18).add(collaterals[collateralToken].recollateralizeFee)).div(getShareTokenPrice());
        require(minimumReceivedShareAmount <= paidbackShareAmount, "slippage-limit-reached");
       
        uint256 recollateralizeAmount = recollateralizeValue.mul(1e18).div(getCollateralPrice(collateralToken));
        require(getCollateralizedBalance(collateralToken).add(recollateralizeAmount) <= collaterals[collateralToken].ceiling, "ceiling-reached");
        shareBondSupply = shareBondSupply.add(paidbackShareAmount);
        require(shareBondSupply <= shareBondCeiling, "sharebond-ceiling-reached");
        
        _depositFrom(collateralToken, msg.sender, collateralAmount);
        _withdrawTo(collateralToken, msg.sender, collateralAmount.sub(recollateralizeAmount));

        IMintable(shareBondToken).mint(msg.sender, paidbackShareAmount);
        emit Recollateralize(msg.sender, recollateralizeAmount, collateralToken, paidbackShareAmount);
    }

    function buyback(uint256 shareAmount, address receivedCollateralToken) external notLocked nonReentrant {

        uint256 excessCollateralValue = getExcessCollateralValue();
        require(excessCollateralValue > 0, "no-excess-collateral-to-buyback");
        uint256 shareTokenPrice = getShareTokenPrice();
        uint256 shareValue = shareAmount.mul(shareTokenPrice).div(1e18);
        shareValue = shareValue.mul(uint256(1e18).add(buybackBonus)).div(1e18); //0.01e18
        uint256 buybackValue = excessCollateralValue > shareValue ? shareValue : excessCollateralValue;
        uint256 neededAmount = buybackValue.mul(1e18).div(shareTokenPrice);
        neededAmount = neededAmount.mul(1e18).div(uint256(1e18).add(buybackBonus));
        IBurnable(shareToken).burnFrom(msg.sender, neededAmount);
        uint256 buybackAmount = calculateEquivalentCollateralAmount(buybackValue, receivedCollateralToken);
        require(buybackAmount <= getCollateralizedBalance(receivedCollateralToken), "insufficient-collateral-amount");
        uint256 buybackFeeAmount = buybackAmount.mul(buybackFee).div(1e18);
        buybackAmount = buybackAmount.sub(buybackFeeAmount);

        _withdrawTo(receivedCollateralToken, msg.sender, buybackAmount);
        _withdrawTo(receivedCollateralToken, protocolFund, buybackFeeAmount);

        emit Buyback(msg.sender, shareAmount, receivedCollateralToken, buybackAmount, buybackFeeAmount);
    }

    function exchangeShareBond(uint256 shareBondAmount) external notLocked nonReentrant {

        if(!kbtToKunImmediately) {
            uint256 excessCollateralValue = getExcessCollateralValue();
            require(excessCollateralValue > 0, "no-excess-collateral-to-buyback");
            uint256 stableTokenPrice = getStableTokenPrice(); 
            require(stableTokenPrice > TARGET_PRICE, "price-not-eligible-for-bond-redeem");
        }
        shareBondSupply = shareBondSupply.sub(shareBondAmount);
        IBurnable(shareBondToken).burnFrom(msg.sender, shareBondAmount);
        IMintable(shareToken).mint(msg.sender, shareBondAmount);
        emit ExchangeShareBond(msg.sender, shareBondAmount);
    }

    function refreshCollateralRatio() public notLocked {

        uint256 stableTokenPrice = getStableTokenPrice();
        require(block.timestamp - lastRefreshTime >= refreshPeriod, "refresh-cooling-period");
        if (stableTokenPrice > TARGET_PRICE.add(refreshBand)) { //decrease collateral ratio
            if (globalCollateralRatio <= refreshStep) {  
                globalCollateralRatio = 0;  //if within a step of 0, go to 0
            } else {
                globalCollateralRatio = globalCollateralRatio.sub(refreshStep);
            }
        } else if (stableTokenPrice < TARGET_PRICE.sub(refreshBand)) { //increase collateral ratio
            if (globalCollateralRatio.add(refreshStep) >= 1e18) {  
                globalCollateralRatio = 1e18; // cap collateral ratio at 1
            } else {
                globalCollateralRatio = globalCollateralRatio.add(refreshStep);
            }
        }
        lastRefreshTime = block.timestamp; // Set the time of the last expansion
    }

    function flashloan(
        address receiver,
        address token,
        uint256 amount,
        bytes memory params
    ) public notLocked nonReentrant {

        require(isCollateralToken(token), "invalid-collateral-token");
        require(amount > 0, "invalid-flashloan-amount");

        address t = (token == NATIVE_TOKEN_ADDRESS) ? wrappedNativeToken : token;
        uint256 balancesBefore = IERC20(t).balanceOf(address(this));
        require(balancesBefore >= amount, "insufficient-balance");

        uint256 balance = address(this).balance;

        uint256 fee = amount.mul(flashloanFee).div(1e18);
        require(fee > 0, "invalid-flashloan-fee");

        IFlashLoanReceiver flashLoanReceiver = IFlashLoanReceiver(receiver);
        address payable _receiver = address(uint160(receiver));

        _withdrawTo(token, _receiver, amount);
        flashLoanReceiver.execute(token, amount, fee, address(this), params);

        if(token == NATIVE_TOKEN_ADDRESS) {
            require(address(this).balance >= balance.add(amount).add(fee), "ether-balance-exception");
            IWrappedNativeToken(wrappedNativeToken).deposit{value: amount.add(fee)}();
        }

        uint256 balancesAfter = IERC20(t).balanceOf(address(this));
        require(balancesAfter >= balancesBefore.add(fee), "balance-exception");

        _withdrawTo(token, protocolFund, fee);
        emit FlashLoan(receiver, token, amount, fee, block.timestamp);
    }

    function getNeededCollateralValue() public view returns(uint256) {

        uint256 stableSupply = IERC20(stableToken).totalSupply();
        return stableSupply.mul(globalCollateralRatio).div(1e18);
    }

    function getExcessCollateralValue() public view returns (uint256) {

        uint256 totalCollateralValue = getTotalCollateralValue(); 
        uint256 neededCollateralValue = getNeededCollateralValue();
        if (totalCollateralValue > neededCollateralValue)
            return totalCollateralValue.sub(neededCollateralValue);
        return 0;
    }

    function getGapCollateralValue() public view returns(uint256) {

        uint256 totalCollateralValue = getTotalCollateralValue();
        uint256 neededCollateralValue = getNeededCollateralValue();
        if(totalCollateralValue < neededCollateralValue)
            return neededCollateralValue.sub(totalCollateralValue);
        return 0;
    }
    
    function getShareTokenPrice() public view returns(uint256) {

        return IOracle(shareTokenOracle).getLatestPrice();
    }
    function getStableTokenPrice() public view returns(uint256) {

        return IOracle(stableTokenOracle).getLatestPrice();
    }
    function getCollateralPrice(address token) public view returns (uint256) {

        return IOracle(collaterals[token].oracle).getLatestPrice();
    }

    function getTotalCollateralValue() public view returns (uint256) {

        uint256 totalCollateralValue = 0;
        uint256 length = collateralTokens.length();
        for (uint256 i = 0; i < length; ++i)
            totalCollateralValue = totalCollateralValue.add(getCollateralValue(collateralTokens.at(i)));
        return totalCollateralValue;
    }

    function getCollateralValue(address token) public view returns (uint256) {

        if(isCollateralToken(token))
            return getCollateralizedBalance(token).mul(getCollateralPrice(token)).div(collaterals[token].precision);
        return 0;
    }

    function isCollateralToken(address token) public view returns (bool) {

        return collateralTokens.contains(token);
    }

    function getCollateralTokens() public view returns (address[] memory) {

        uint256 length = collateralTokens.length();
        address[] memory tokens = new address[](length);
        for (uint256 i = 0; i < length; ++i)
            tokens[i] = collateralTokens.at(i);
        return tokens;
    }

    function getCollateralizedBalance(address token) public view returns(uint256) {

        address tt = (token == NATIVE_TOKEN_ADDRESS) ? wrappedNativeToken : token;
        uint256 balance = IERC20(tt).balanceOf(address(this));
        return balance.sub(Math.min(balance, unclaimedCollaterals[token]));
    }

    function setStableTokenOracle(address newStableTokenOracle) public onlyOwner {

        stableTokenOracle = newStableTokenOracle;
    }

    function setShareTokenOracle(address newShareTokenOracle) public onlyOwner {

        shareTokenOracle = newShareTokenOracle;
    }

    function setRedeemFee(uint256 newRedeemFee) external onlyOwner {

        redeemFee = newRedeemFee;
    }

    function setMintFee(uint256 newMintFee) external onlyOwner {

        mintFee = newMintFee;
    }

    function setBuybackFee(uint256 newBuybackFee) external onlyOwner {

        buybackFee = newBuybackFee;
    }

    function addCollateralToken(address token, address oracle, uint256 ceiling, uint256 recollateralizeFee) external onlyOwner {

        require(collateralTokens.add(token) || collaterals[token].deprecated, "duplicated-collateral-token");
        if(token == NATIVE_TOKEN_ADDRESS) {
            collaterals[token].precision = 10**18;
        } else {
            uint256 decimals = IERC20Decimals(token).decimals();
            require(decimals <= 18, "unexpected-collateral-token");
            collaterals[token].precision = 10**decimals;
        }
        collaterals[token].deprecated = false;
        collaterals[token].oracle = oracle;
        collaterals[token].ceiling = ceiling;
        collaterals[token].recollateralizeFee = recollateralizeFee;
    }

    function deprecateCollateralToken(address token) external onlyOwner {

        require(isCollateralToken(token), "not-found-collateral-token");
        collaterals[token].deprecated = true;
    }

    function removeCollateralToken(address token) external onlyOwner {

        require(collaterals[token].deprecated, "undeprecated-collateral-token");
        require(collateralTokens.remove(token), "not-found-token");
        delete collaterals[token];
    }

    function updateCollateralToken(address token, address newOracle, uint256 newCeiling, uint256 newRecollateralizeFee) public onlyOwner {

        require(isCollateralToken(token), "not-found-collateral-token");
        collaterals[token].ceiling = newCeiling;
        collaterals[token].oracle = newOracle;
        collaterals[token].recollateralizeFee = newRecollateralizeFee;
    }

    function setRefreshPeriod(uint256 newRefreshPeriod) external onlyOwner {

        refreshPeriod = newRefreshPeriod;
    }

    function setRefreshStep(uint256 newRefreshStep) external onlyOwner {

        refreshStep = newRefreshStep;
    }

    function setRefreshBand(uint256 newRefreshBand) external onlyOwner {

        refreshBand = newRefreshBand;
    }

    function setProtocolFund(address payable newProtocolFund) public onlyOwner {

        protocolFund =  newProtocolFund;
    }

    function setFlashloanFee(uint256 newFlashloanFee) public onlyOwner {

        flashloanFee = newFlashloanFee;
    }

    function setGlobalCollateralRatio(uint256 newGlobalCollateralRatio) public onlyOwner {

        globalCollateralRatio = newGlobalCollateralRatio;
    }

    function setShareBondCeiling(uint256 newShareBondCeiling) public onlyOwner {

        shareBondCeiling = newShareBondCeiling;
    }

    function setBuybackBonus(uint256 newBuybackBonus) public onlyOwner {

        buybackBonus = newBuybackBonus;
    }
    
    function setKbtToKunImmediately() public onlyOwner {

        kbtToKunImmediately = !kbtToKunImmediately;
    }

    function _withdrawTo(address token, address payable to, uint256 amount) internal {

        if(token == NATIVE_TOKEN_ADDRESS) {
            IWrappedNativeToken(wrappedNativeToken).withdraw(amount);
            to.transfer(amount);
        } else {
           IERC20(token).transfer(to, amount);
        }
    }

    function _depositFrom(address token, address from, uint256 amount) internal {

        if(token == NATIVE_TOKEN_ADDRESS) {
            require(msg.value == amount, "msg.value != amount");
            IWrappedNativeToken(wrappedNativeToken).deposit{value: amount}();
        } else {
           IERC20(token).transferFrom(from, address(this), amount);
        }
    }

    receive() external payable {
    }   
}