pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant DAYS_IN_THE_YEAR = 365;
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;

uint256 constant PROTOCOL_PERCENTAGE = 20 * PRECISION;

uint256 constant DEFAULT_REBALANCING_THRESHOLD = 10**23;

uint256 constant EPOCH_DAYS_AMOUNT = 7;// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

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

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
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

}// MIT

pragma solidity ^0.7.0;

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;


library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity ^0.7.0;

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
}// MIT
pragma solidity ^0.7.4;


library DecimalsConverter {
    using SafeMath for uint256;

    function convert(
        uint256 amount,
        uint256 baseDecimals,
        uint256 destinationDecimals
    ) internal pure returns (uint256) {
        if (baseDecimals > destinationDecimals) {
            amount = amount.div(10**(baseDecimals - destinationDecimals));
        } else if (baseDecimals < destinationDecimals) {
            amount = amount.mul(10**(destinationDecimals - baseDecimals));
        }

        return amount;
    }

    function convertTo18(uint256 amount, uint256 baseDecimals) internal pure returns (uint256) {
        return convert(amount, baseDecimals, 18);
    }

    function convertFrom18(uint256 amount, uint256 destinationDecimals)
        internal
        pure
        returns (uint256)
    {
        return convert(amount, 18, destinationDecimals);
    }
}// MIT
pragma solidity ^0.7.4;

interface IContractsRegistry {
    function getUniswapRouterContract() external view returns (address);

    function getUniswapBMIToETHPairContract() external view returns (address);

    function getUniswapBMIToUSDTPairContract() external view returns (address);

    function getSushiswapRouterContract() external view returns (address);

    function getSushiswapBMIToETHPairContract() external view returns (address);

    function getSushiswapBMIToUSDTPairContract() external view returns (address);

    function getSushiSwapMasterChefV2Contract() external view returns (address);

    function getWETHContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getBMICoverStakingViewContract() external view returns (address);

    function getLegacyRewardsGeneratorContract() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getNFTStakingContract() external view returns (address);

    function getLiquidityBridgeContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getLeveragePortfolioViewContract() external view returns (address);

    function getCapitalPoolContract() external view returns (address);

    function getPolicyBookAdminContract() external view returns (address);

    function getPolicyQuoteContract() external view returns (address);

    function getLegacyBMIStakingContract() external view returns (address);

    function getBMIStakingContract() external view returns (address);

    function getSTKBMIContract() external view returns (address);

    function getVBMIContract() external view returns (address);

    function getLegacyLiquidityMiningStakingContract() external view returns (address);

    function getLiquidityMiningStakingETHContract() external view returns (address);

    function getLiquidityMiningStakingUSDTContract() external view returns (address);

    function getReputationSystemContract() external view returns (address);

    function getAaveProtocolContract() external view returns (address);

    function getAaveLendPoolAddressProvdierContract() external view returns (address);

    function getAaveATokenContract() external view returns (address);

    function getCompoundProtocolContract() external view returns (address);

    function getCompoundCTokenContract() external view returns (address);

    function getCompoundComptrollerContract() external view returns (address);

    function getYearnProtocolContract() external view returns (address);

    function getYearnVaultContract() external view returns (address);

    function getYieldGeneratorContract() external view returns (address);

    function getShieldMiningContract() external view returns (address);
}// MIT
pragma solidity ^0.7.4;

interface IPolicyBookFabric {
    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE, VARIOUS}

    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit,
        address _shieldMiningToken
    ) external returns (address);

    function createLeveragePools(
        address _insuranceContract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external returns (address);
}// MIT
pragma solidity ^0.7.4;


interface IClaimingRegistry {
    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED
    }

    struct ClaimInfo {
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        uint256 dateSubmitted;
        uint256 dateEnded;
        bool appeal;
        ClaimStatus status;
        uint256 claimAmount;
    }

    function anonymousVotingDuration(uint256 index) external view returns (uint256);

    function votingDuration(uint256 index) external view returns (uint256);

    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);

    function canBuyNewPolicy(address buyer, address policyBookAddress)
        external
        view
        returns (bool);

    function submitClaim(
        address user,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external returns (uint256);

    function claimExists(uint256 index) external view returns (bool);

    function claimSubmittedTime(uint256 index) external view returns (uint256);

    function claimEndTime(uint256 index) external view returns (uint256);

    function isClaimAnonymouslyVotable(uint256 index) external view returns (bool);

    function isClaimExposablyVotable(uint256 index) external view returns (bool);

    function isClaimVotable(uint256 index) external view returns (bool);

    function canClaimBeCalculatedByAnyone(uint256 index) external view returns (bool);

    function isClaimPending(uint256 index) external view returns (bool);

    function countPolicyClaimerClaims(address user) external view returns (uint256);

    function countPendingClaims() external view returns (uint256);

    function countClaims() external view returns (uint256);

    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        returns (uint256);

    function pendingClaimIndexAt(uint256 orderIndex) external view returns (uint256);

    function claimIndexAt(uint256 orderIndex) external view returns (uint256);

    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        returns (uint256);

    function isClaimAppeal(uint256 index) external view returns (bool);

    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        returns (ClaimStatus);

    function claimStatus(uint256 index) external view returns (ClaimStatus);

    function claimOwner(uint256 index) external view returns (address);

    function claimPolicyBook(uint256 index) external view returns (address);

    function claimInfo(uint256 index) external view returns (ClaimInfo memory _claimInfo);

    function getAllPendingClaimsAmount() external view returns (uint256 _totalClaimsAmount);

    function getClaimableAmounts(uint256[] memory _claimIndexes) external view returns (uint256);

    function acceptClaim(uint256 index) external;

    function rejectClaim(uint256 index) external;

    function updateImageUriOfClaim(uint256 _claimIndex, string calldata _newEvidenceURI) external;
}// MIT
pragma solidity ^0.7.4;


interface IPolicyBook {
    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
        uint256 reinsurancePrice;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BuyPolicyParameters {
        address buyer;
        address holder;
        uint256 epochsNumber;
        uint256 coverTokens;
        uint256 distributorFee;
        address distributor;
    }

    function policyHolders(address _holder)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function policyBookFacade() external view returns (IPolicyBookFacade);

    function setPolicyBookFacade(address _policyBookFacade) external;

    function EPOCH_DURATION() external view returns (uint256);

    function stblDecimals() external view returns (uint256);

    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);

    function whitelisted() external view returns (bool);

    function epochStartTime() external view returns (uint256);

    function insuranceContractAddress() external view returns (address _contract);

    function contractType() external view returns (IPolicyBookFabric.ContractType _type);

    function totalLiquidity() external view returns (uint256);

    function totalCoverTokens() external view returns (uint256);




    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );

    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;

    function whitelist(bool _whitelisted) external;

    function getEpoch(uint256 time) external view returns (uint256);

    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);

    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);

    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;

    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;

    function commitClaim(
        address claimer,
        uint256 claimAmount,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;

    function forceUpdateBMICoverStakingRewardMultiplier() external;

    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);

    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _buyer
    )
        external
        view
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        );

    function buyPolicy(
        address _buyer,
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) external returns (uint256, uint256);

    function updateEpochsInfo() external;

    function secondsToEndCurrentEpoch() external view returns (uint256);

    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;

    function addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external returns (uint256);

    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw, address _user) external;


    function unlockTokens() external;

    function withdrawLiquidity(address sender) external returns (uint256);

    function updateLiquidity(uint256 _newLiquidity) external;

    function getAPY() external view returns (uint256);

    function userStats(address _user) external view returns (PolicyHolder memory);

    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );

    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );
}// MIT
pragma solidity ^0.7.4;

interface ILeveragePortfolio {
    enum LeveragePortfolio {USERLEVERAGEPOOL, REINSURANCEPOOL}
    struct LevFundsFactors {
        uint256 netMPL;
        uint256 netMPLn;
        address policyBookAddr;
    }

    function targetUR() external view returns (uint256);

    function d_ProtocolConstant() external view returns (uint256);

    function a_ProtocolConstant() external view returns (uint256);

    function max_ProtocolConstant() external view returns (uint256);

    function deployLeverageStableToCoveragePools(LeveragePortfolio leveragePoolType)
        external
        returns (uint256);

    function deployVirtualStableToCoveragePools() external returns (uint256);

    function setRebalancingThreshold(uint256 threshold) external;

    function setProtocolConstant(
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a1_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;


    function totalLiquidity() external view returns (uint256);

    function addPolicyPremium(uint256 epochsNumber, uint256 premiumAmount) external;

    function listleveragedCoveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _coveragePools);

    function countleveragedCoveragePools() external view returns (uint256);

    function updateLiquidity(uint256 _lostLiquidity) external;

    function forceUpdateBMICoverStakingRewardMultiplier() external;
}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookFacade {
    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external;

    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;

    function policyBook() external view returns (IPolicyBook);

    function userLiquidity(address account) external view returns (uint256);

    function VUreinsurnacePool() external view returns (uint256);

    function LUreinsurnacePool() external view returns (uint256);

    function LUuserLeveragePool(address userLeveragePool) external view returns (uint256);

    function totalLeveragedLiquidity() external view returns (uint256);

    function userleveragedMPL() external view returns (uint256);

    function reinsurancePoolMPL() external view returns (uint256);

    function rebalancingThreshold() external view returns (uint256);

    function safePricingModel() external view returns (bool);

    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 initialDeposit
    ) external;

    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    function buyPolicyFromDistributorFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    function addLiquidity(uint256 _liquidityAmount) external;

    function addLiquidityFromDistributorFor(address _user, uint256 _liquidityAmount) external;

    function addLiquidityAndStakeFor(
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external;

    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;

    function withdrawLiquidity() external;

    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external;

    function deployVirtualFundsAfterRebalance(uint256 deployedAmount) external;

    function reevaluateProvidedLeverageStable() external;

    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL) external;

    function setRebalancingThreshold(uint256 _newRebalancingThreshold) external;

    function setSafePricingModel(bool _safePricingModel) external;

    function getClaimApprovalAmount(address user) external view returns (uint256);

    function requestWithdrawal(uint256 _tokensToWithdraw) external;

    function listUserLeveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _userLeveragePools);

    function countUserLeveragePools() external view returns (uint256);

    function getUtilizationRatioPercentage(bool withLeverage) external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookRegistry {
    struct PolicyBookStats {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 maxCapacity;
        uint256 totalSTBLLiquidity;
        uint256 totalLeveragedLiquidity;
        uint256 stakedSTBL;
        uint256 APY;
        uint256 annualInsuranceCost;
        uint256 bmiXRatio;
        bool whitelisted;
    }

    function policyBooksByInsuredAddress(address insuredContract) external view returns (address);

    function policyBookFacades(address facadeAddress) external view returns (address);

    function add(
        address insuredContract,
        IPolicyBookFabric.ContractType contractType,
        address policyBook,
        address facadeAddress
    ) external;

    function whitelist(address policyBookAddress, bool whitelisted) external;

    function getPoliciesPrices(
        address[] calldata policyBooks,
        uint256[] calldata epochsNumbers,
        uint256[] calldata coversTokens
    ) external view returns (uint256[] memory _durations, uint256[] memory _allowances);

    function buyPolicyBatch(
        address[] calldata policyBooks,
        uint256[] calldata epochsNumbers,
        uint256[] calldata coversTokens
    ) external;

    function isPolicyBook(address policyBook) external view returns (bool);

    function isPolicyBookFacade(address _facadeAddress) external view returns (bool);

    function isUserLeveragePool(address policyBookAddress) external view returns (bool);

    function countByType(IPolicyBookFabric.ContractType contractType)
        external
        view
        returns (uint256);

    function count() external view returns (uint256);

    function countByTypeWhitelisted(IPolicyBookFabric.ContractType contractType)
        external
        view
        returns (uint256);

    function countWhitelisted() external view returns (uint256);

    function listByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr);

    function list(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr);

    function listByTypeWhitelisted(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr);

    function listWhitelisted(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr);

    function listWithStatsByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);

    function listWithStats(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);

    function listWithStatsByTypeWhitelisted(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);

    function listWithStatsWhitelisted(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);

    function stats(address[] calldata policyBooks)
        external
        view
        returns (PolicyBookStats[] memory _stats);

    function policyBookFor(address insuredContract) external view returns (address);

    function statsByInsuredContracts(address[] calldata insuredContracts)
        external
        view
        returns (PolicyBookStats[] memory _stats);
}// MIT
pragma solidity ^0.7.4;


interface IShieldMining {
    struct ShieldMiningInfo {
        IERC20 rewardsToken;
        uint8 decimals;
        uint256 firstBlockWithReward;
        uint256 lastBlockWithReward;
        uint256 lastUpdateBlock;
        uint256 rewardTokensLocked;
        uint256 rewardPerTokenStored;
        uint256 totalSupply;
        uint256[] endsOfDistribution;
        uint256 nearestLastBlocksWithReward;
        mapping(uint256 => uint256) rewardPerBlock;
    }

    struct ShieldMiningDeposit {
        address policyBook;
        uint256 amount;
        uint256 duration;
        uint256 depositRewardPerBlock;
        uint256 startBlock;
        uint256 endBlock;
    }

    function blocksWithRewardsPassed(address _policyBook) external view returns (uint256);

    function rewardPerToken(address _policyBook) external view returns (uint256);

    function earned(
        address _policyBook,
        address _userLeveragePool,
        address _account
    ) external view returns (uint256);

    function updateTotalSupply(
        address _policyBook,
        address _userLeveragePool,
        address liquidityProvider
    ) external;

    function associateShieldMining(address _policyBook, address _shieldMiningToken) external;

    function fillShieldMining(
        address _policyBook,
        uint256 _amount,
        uint256 _duration
    ) external;

    function getRewardFor(
        address _userAddress,
        address _policyBook,
        address _userLeveragePool
    ) external;

    function getRewardFor(address _userAddress, address _userLeveragePoolAddress) external;

    function getReward(address _policyBook, address _userLeveragePool) external;

    function getReward(address _userLeveragePoolAddress) external;

    function getShieldTokenAddress(address _policyBook) external view returns (address);

    function getShieldMiningInfo(address _policyBook)
        external
        view
        returns (
            address _rewardsToken,
            uint256 _decimals,
            uint256 _firstBlockWithReward,
            uint256 _lastBlockWithReward,
            uint256 _lastUpdateBlock,
            uint256 _nearestLastBlocksWithReward,
            uint256 _rewardTokensLocked,
            uint256 _rewardPerTokenStored,
            uint256 _rewardPerBlock,
            uint256 _tokenPerDay,
            uint256 _totalSupply
        );

    function getDepositList(
        address _account,
        uint256 _offset,
        uint256 _limit
    ) external view returns (ShieldMiningDeposit[] memory _depositsList);

    function countUsersDeposits(address _account) external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;


interface IUserLeveragePool {
    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BMIMultiplierFactors {
        uint256 poolMultiplier;
        uint256 leverageProvided;
        uint256 multiplier;
    }

    function contractType() external view returns (IPolicyBookFabric.ContractType _type);

    function userLiquidity(address account) external view returns (uint256);

    function a2_ProtocolConstant() external view returns (uint256);

    function EPOCH_DURATION() external view returns (uint256);

    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);

    function epochStartTime() external view returns (uint256);

    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );

    function __UserLeveragePool_init(
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;

    function getEpoch(uint256 time) external view returns (uint256);

    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);

    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);

    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);

    function updateEpochsInfo() external;

    function secondsToEndCurrentEpoch() external view returns (uint256);

    function addLiquidity(uint256 _liqudityAmount) external;


    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;

    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw) external;


    function unlockTokens() external;

    function withdrawLiquidity() external;

    function getAPY() external view returns (uint256);

    function whitelisted() external view returns (bool);

    function whitelist(bool _whitelisted) external;

    function setMaxCapacities(uint256 _maxCapacities) external;

    function setA2_ProtocolConstant(uint256 _a2_ProtocolConstant) external;

    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );

    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );
}// MIT
pragma solidity ^0.7.4;


interface ILeveragePortfolioView {
    function calcM(uint256 poolUR, address leveragePoolAddress) external view returns (uint256);

    function calcMaxLevFunds(ILeveragePortfolio.LevFundsFactors memory factors)
        external
        view
        returns (uint256);

    function calcBMIMultiplier(IUserLeveragePool.BMIMultiplierFactors memory factors)
        external
        view
        returns (uint256);

    function getPolicyBookFacade(address _policybookAddress)
        external
        view
        returns (IPolicyBookFacade _coveragePool);

    function calcNetMPLn(
        ILeveragePortfolio.LeveragePortfolio leveragePoolType,
        address _policyBookFacade
    ) external view returns (uint256 _netMPLn);

    function calcMaxVirtualFunds(address policyBookAddress, uint256 vStableWeight)
        external
        returns (uint256 _amountToDeploy, uint256 _maxAmount);

    function calcvStableFormulaforAllPools() external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;


abstract contract AbstractDependant {
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier onlyInjectorOrZero() {
        address _injector = injector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
        _;
    }

    function setInjector(address _injector) external onlyInjectorOrZero {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }

    function setDependencies(IContractsRegistry) external virtual;

    function injector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }
}// MIT
pragma solidity ^0.7.4;






contract ShieldMining is IShieldMining, OwnableUpgradeable, ReentrancyGuard, AbstractDependant {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;
    using Math for uint256;

    address public policyBookFabric;
    IPolicyBookRegistry public policyBookRegistry;

    mapping(address => ShieldMiningInfo) public shieldMiningInfo;
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint256)) internal _rewards;

    mapping(address => mapping(uint256 => uint256)) public endOfRewards;

    Counters.Counter public lastDepositId;
    mapping(address => EnumerableSet.UintSet) private _usersDepositsId;
    mapping(uint256 => ShieldMiningDeposit) public usersDeposits;

    ILeveragePortfolioView public leveragePortfolioView;

    mapping(address => EnumerableSet.UintSet) internal lastBlockWithRewardList;
    mapping(address => uint256) public userleveragepoolsParticipatedAmounts;

    address public bmiCoverStakingAddress;
    mapping(address => uint256) public userleveragepoolsTotalSupply;

    event ShieldMiningAssociated(address indexed policyBook, address indexed shieldToken);
    event ShieldMiningFilled(
        address indexed policyBook,
        address indexed shieldToken,
        address indexed depositor,
        uint256 amount,
        uint256 lastBlockWithReward
    );
    event ShieldMiningClaimed(address indexed user, address indexed policyBook, uint256 reward);
    event ShieldMiningRecovered(address indexed policyBook, uint256 amount);

    modifier shieldMiningEnabled(address _policyBook) {
        require(
            address(shieldMiningInfo[_policyBook].rewardsToken) != address(0),
            "SM: no shield mining associated"
        );
        _;
    }

    modifier updateReward(
        address _policyBook,
        address _userLeveragePool,
        address account
    ) {
        _updateReward(_policyBook, _userLeveragePool, account);
        _;
    }

    modifier onlyBMICoverStaking() {
        require(
            bmiCoverStakingAddress == _msgSender(),
            "SM: Caller is not BMICoverStaking contract"
        );
        _;
    }

    function __ShieldMining_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        policyBookFabric = _contractsRegistry.getPolicyBookFabricContract();
        leveragePortfolioView = ILeveragePortfolioView(
            _contractsRegistry.getLeveragePortfolioViewContract()
        );
        bmiCoverStakingAddress = _contractsRegistry.getBMICoverStakingContract();
    }

    function blocksWithRewardsPassed(address _policyBook) public view override returns (uint256) {
        uint256 from = shieldMiningInfo[_policyBook].lastUpdateBlock;

        uint256 to =
            Math.min(block.number, shieldMiningInfo[_policyBook].nearestLastBlocksWithReward);

        return from >= to ? 0 : to.sub(from);
    }

    function rewardPerToken(address _policyBook) public view override returns (uint256) {
        uint256 totalPoolStaked = shieldMiningInfo[_policyBook].totalSupply;

        if (totalPoolStaked == 0) {
            return shieldMiningInfo[_policyBook].rewardPerTokenStored;
        }

        uint256 accumulatedReward =
            blocksWithRewardsPassed(_policyBook)
                .mul(getCurrentRewardPerBlock(_policyBook))
                .mul(DECIMALS18)
                .div(totalPoolStaked);

        return shieldMiningInfo[_policyBook].rewardPerTokenStored.add(accumulatedReward);
    }

    function earned(
        address _policyBook,
        address _userLeveragePool,
        address _account
    ) public view override returns (uint256) {
        address _userPool = _userLeveragePool != address(0) ? _userLeveragePool : _policyBook;
        uint256 rewardsDifference =
            rewardPerToken(_policyBook).sub(userRewardPerTokenPaid[_account][_userPool]);

        uint256 userLiquidity;

        if (_userLeveragePool == address(0)) {
            userLiquidity = IPolicyBookFacade(IPolicyBook(_policyBook).policyBookFacade())
                .userLiquidity(_account);
        } else {
            userLiquidity = IUserLeveragePool(_userLeveragePool).userLiquidity(_account);
            uint256 totalSupply = userleveragepoolsTotalSupply[_userLeveragePool];
            if (totalSupply > 0) {
                userLiquidity = userLiquidity
                    .mul(userleveragepoolsParticipatedAmounts[_userLeveragePool])
                    .div(totalSupply);
            }
        }

        uint256 newlyAccumulated = userLiquidity.mul(rewardsDifference).div(DECIMALS18);

        return _rewards[_account][_userPool].add(newlyAccumulated);
    }

    function updateTotalSupply(
        address _policyBook,
        address _userLeveragePool,
        address _liquidityProvider
    ) external override updateReward(_policyBook, _userLeveragePool, _liquidityProvider) {
        require(
            policyBookRegistry.isPolicyBookFacade(_msgSender()) ||
                policyBookRegistry.isPolicyBook(_policyBook),
            "SM: No access"
        );
        uint256 _participatedLeverageAmounts;

        IPolicyBook _coveragePool = IPolicyBook(_policyBook);
        IPolicyBookFacade _policyFacade = IPolicyBookFacade(_coveragePool.policyBookFacade());

        uint256 _userLeveragePoolsCount = _policyFacade.countUserLeveragePools();

        if (_userLeveragePoolsCount > 0) {
            address[] memory _userLeverageArr =
                _policyFacade.listUserLeveragePools(0, _userLeveragePoolsCount);
            uint256 _participatedLeverageAmount;
            for (uint256 i = 0; i < _userLeverageArr.length; i++) {
                _participatedLeverageAmount = clacParticipatedLeverageAmount(
                    _userLeverageArr[i],
                    _coveragePool
                );
                userleveragepoolsParticipatedAmounts[
                    _userLeverageArr[i]
                ] = _participatedLeverageAmount;
                _participatedLeverageAmounts = _participatedLeverageAmounts.add(
                    _participatedLeverageAmount
                );
                userleveragepoolsTotalSupply[_userLeverageArr[i]] = IERC20(_userLeverageArr[i])
                    .totalSupply();
            }
        }

        shieldMiningInfo[_policyBook].totalSupply = _participatedLeverageAmounts.add(
            IERC20(_policyBook).totalSupply()
        );
    }

    function clacParticipatedLeverageAmount(address _userLeveragePool, IPolicyBook _coveragePool)
        internal
        view
        returns (uint256)
    {
        IPolicyBookFacade _policyFacade = IPolicyBookFacade(_coveragePool.policyBookFacade());
        uint256 _poolUtilizationRation;
        uint256 _coverageLiq = _coveragePool.totalLiquidity();
        if (_coverageLiq > 0) {
            _poolUtilizationRation = _coveragePool.totalCoverTokens().mul(PERCENTAGE_100).div(
                _coverageLiq
            );
        }

        return
            _policyFacade
                .LUuserLeveragePool(_userLeveragePool)
                .mul(leveragePortfolioView.calcM(_poolUtilizationRation, _userLeveragePool))
                .div(PERCENTAGE_100);
    }

    function associateShieldMining(address _policyBook, address _shieldMiningToken)
        external
        override
    {
        require(_msgSender() == policyBookFabric || _msgSender() == owner(), "SM: no access");
        require(policyBookRegistry.isPolicyBook(_policyBook), "SM: Not a PolicyBook");

        _shieldMiningToken.functionCall(
            abi.encodeWithSignature("totalSupply()", ""),
            "SM: is not an ERC20"
        );

        delete shieldMiningInfo[_policyBook];

        shieldMiningInfo[_policyBook].totalSupply = IERC20(_policyBook).totalSupply();
        shieldMiningInfo[_policyBook].rewardsToken = IERC20(_shieldMiningToken);
        shieldMiningInfo[_policyBook].decimals = ERC20(_shieldMiningToken).decimals();

        emit ShieldMiningAssociated(_policyBook, _shieldMiningToken);
    }

    function fillShieldMining(
        address _policyBook,
        uint256 _amount,
        uint256 _duration
    ) external override shieldMiningEnabled(_policyBook) {
        require(_duration >= 22 && _duration <= 366, "SM: out of minimum/maximum duration");

        uint256 _tokenDecimals = shieldMiningInfo[_policyBook].decimals;
        uint256 tokenLiquidity = DecimalsConverter.convertFrom18(_amount, _tokenDecimals);

        require(tokenLiquidity > 0, "SM: amount is zero");

        uint256 _blocksAmount = _duration.mul(BLOCKS_PER_DAY).sub(1);

        uint256 _rewardPerBlock = _amount.div(_blocksAmount);

        shieldMiningInfo[_policyBook].rewardsToken.safeTransferFrom(
            _msgSender(),
            address(this),
            tokenLiquidity
        );

        shieldMiningInfo[_policyBook].rewardTokensLocked = shieldMiningInfo[_policyBook]
            .rewardTokensLocked
            .add(_amount);

        uint256 _lastBlockWithReward =
            _setRewards(_policyBook, _rewardPerBlock, block.number, _blocksAmount);

        lastDepositId.increment();
        _usersDepositsId[_msgSender()].add(lastDepositId.current());
        usersDeposits[lastDepositId.current()] = ShieldMiningDeposit(
            _policyBook,
            _amount,
            _duration,
            _rewardPerBlock,
            block.number,
            _lastBlockWithReward
        );

        emit ShieldMiningFilled(
            _policyBook,
            address(shieldMiningInfo[_policyBook].rewardsToken),
            _msgSender(),
            _amount,
            shieldMiningInfo[_policyBook].lastBlockWithReward
        );
    }

    function getRewardFor(
        address _user,
        address _policyBook,
        address _userLeveragePool
    )
        public
        override
        nonReentrant
        updateReward(_policyBook, _userLeveragePool, _user)
        onlyBMICoverStaking
    {
        _getReward(_user, _policyBook, _userLeveragePool);
    }

    function getRewardFor(address _user, address _userLeveragePool)
        public
        override
        nonReentrant
        onlyBMICoverStaking
    {
        _getRewardFromLeverage(_user, _userLeveragePool, true);
    }

    function getReward(address _policyBook, address _userLeveragePool)
        public
        override
        nonReentrant
        updateReward(_policyBook, _userLeveragePool, _msgSender())
    {
        _getReward(_msgSender(), _policyBook, _userLeveragePool);
    }

    function getReward(address _userLeveragePool) public override nonReentrant {
        _getRewardFromLeverage(_msgSender(), _userLeveragePool, false);
    }

    function _getRewardFromLeverage(
        address _user,
        address _userLeveragePool,
        bool isRewardFor
    ) internal {
        ILeveragePortfolio userLeveragePool = ILeveragePortfolio(_userLeveragePool);
        address[] memory _coveragePools =
            userLeveragePool.listleveragedCoveragePools(
                0,
                userLeveragePool.countleveragedCoveragePools()
            );
        for (uint256 i = 0; i < _coveragePools.length; i++) {
            if (getShieldTokenAddress(_coveragePools[i]) != address(0)) {
                if (isRewardFor) {
                    getRewardFor(_user, _coveragePools[i], _userLeveragePool);
                } else {
                    getReward(_coveragePools[i], _userLeveragePool);
                }
            }
        }
    }

    function _getReward(
        address _user,
        address _policyBook,
        address _userLeveragePool
    ) internal {
        address _userPool = _userLeveragePool != address(0) ? _userLeveragePool : _policyBook;
        uint256 reward = _rewards[_user][_userPool];

        if (reward > 0) {
            delete _rewards[_user][_userPool];

            uint256 _tokenDecimals = shieldMiningInfo[_policyBook].decimals;

            shieldMiningInfo[_policyBook].rewardsToken.safeTransfer(
                _user,
                DecimalsConverter.convertFrom18(reward, _tokenDecimals)
            );

            shieldMiningInfo[_policyBook].rewardTokensLocked = shieldMiningInfo[_policyBook]
                .rewardTokensLocked
                .sub(reward);

            emit ShieldMiningClaimed(_user, _policyBook, reward);
        }
    }

    function recoverNonLockedRewardTokens(address _policyBook) public onlyOwner {
        uint256 _tokenDecimals = shieldMiningInfo[_policyBook].decimals;

        uint256 _futureRewardTokens = _getFutureRewardTokens(_policyBook);

        uint256 tokenBalance =
            DecimalsConverter.convertTo18(
                shieldMiningInfo[_policyBook].rewardsToken.balanceOf(address(this)),
                _tokenDecimals
            );

        if (tokenBalance > _futureRewardTokens) {
            uint256 nonLockedTokens = tokenBalance.sub(_futureRewardTokens);

            shieldMiningInfo[_policyBook].rewardsToken.safeTransfer(
                owner(),
                DecimalsConverter.convertFrom18(nonLockedTokens, _tokenDecimals)
            );

            emit ShieldMiningRecovered(_policyBook, nonLockedTokens);
        }
    }

    function getShieldTokenAddress(address _policyBook) public view override returns (address) {
        return address(shieldMiningInfo[_policyBook].rewardsToken);
    }

    function getShieldMiningInfo(address _policyBook)
        external
        view
        override
        returns (
            address _rewardsToken,
            uint256 _decimals,
            uint256 _firstBlockWithReward,
            uint256 _lastBlockWithReward,
            uint256 _lastUpdateBlock,
            uint256 _nearestLastBlocksWithReward,
            uint256 _rewardTokensLocked,
            uint256 _rewardPerTokenStored,
            uint256 _rewardPerBlock,
            uint256 _tokenPerDay,
            uint256 _totalSupply
        )
    {
        _rewardsToken = address(shieldMiningInfo[_policyBook].rewardsToken);
        _decimals = shieldMiningInfo[_policyBook].decimals;
        _firstBlockWithReward = shieldMiningInfo[_policyBook].firstBlockWithReward;
        _lastBlockWithReward = shieldMiningInfo[_policyBook].lastBlockWithReward;
        _lastUpdateBlock = shieldMiningInfo[_policyBook].lastUpdateBlock;
        _nearestLastBlocksWithReward = shieldMiningInfo[_policyBook].nearestLastBlocksWithReward;
        _rewardPerTokenStored = shieldMiningInfo[_policyBook].rewardPerTokenStored;
        _rewardPerBlock = getCurrentRewardPerBlock(_policyBook);
        _tokenPerDay = _rewardPerBlock.mul(BLOCKS_PER_DAY);
        _totalSupply = shieldMiningInfo[_policyBook].totalSupply;
        _rewardTokensLocked = shieldMiningInfo[_policyBook].rewardTokensLocked;
    }

    function getDepositList(
        address _account,
        uint256 _offset,
        uint256 _limit
    ) external view override returns (ShieldMiningDeposit[] memory _depositsList) {
        uint256 nbOfDeposit = _usersDepositsId[_account].length();

        uint256 to = (_offset.add(_limit)).min(nbOfDeposit).max(_offset);
        uint256 size = to.sub(_offset);

        _depositsList = new ShieldMiningDeposit[](size);
        for (uint256 i = _offset; i < to; i++) {
            ShieldMiningDeposit memory smd = usersDeposits[_usersDepositsId[_account].at(i)];
            _depositsList[i].policyBook = smd.policyBook;
            _depositsList[i].amount = smd.amount;
            _depositsList[i].duration = smd.duration;
            _depositsList[i].depositRewardPerBlock = smd.depositRewardPerBlock;
            _depositsList[i].startBlock = smd.startBlock;
            _depositsList[i].endBlock = smd.endBlock;
        }
    }

    function countUsersDeposits(address _account) external view override returns (uint256) {
        return _usersDepositsId[_account].length();
    }

    function _setRewards(
        address _policyBook,
        uint256 _rewardPerBlock,
        uint256 _startingBlock,
        uint256 _blocksAmount
    )
        internal
        updateReward(_policyBook, address(0), address(0))
        returns (uint256 _lastBlockWithReward)
    {
        shieldMiningInfo[_policyBook].firstBlockWithReward = _startingBlock;

        _lastBlockWithReward = _startingBlock.add(_blocksAmount);

        if (shieldMiningInfo[_policyBook].lastBlockWithReward < _lastBlockWithReward) {
            shieldMiningInfo[_policyBook].lastBlockWithReward = _lastBlockWithReward;
        }

        shieldMiningInfo[_policyBook].rewardPerBlock[_lastBlockWithReward] = shieldMiningInfo[
            _policyBook
        ]
            .rewardPerBlock[_lastBlockWithReward]
            .add(_rewardPerBlock);
        lastBlockWithRewardList[_policyBook].add(_lastBlockWithReward);
    }

    function _updateReward(
        address _policyBook,
        address _userLeveragePool,
        address _account
    ) internal {
        _updateNearestLastBlocksWithReward(_policyBook);

        uint256 currentRewardPerToken = rewardPerToken(_policyBook);

        shieldMiningInfo[_policyBook].rewardPerTokenStored = currentRewardPerToken;

        uint256 _nearestLastBlocksWithReward =
            shieldMiningInfo[_policyBook].nearestLastBlocksWithReward;

        uint256 _lastBlockWithReward = shieldMiningInfo[_policyBook].lastBlockWithReward;

        if (
            _nearestLastBlocksWithReward != 0 &&
            block.number > _nearestLastBlocksWithReward &&
            _lastBlockWithReward != _nearestLastBlocksWithReward
        ) {
            shieldMiningInfo[_policyBook].lastUpdateBlock = _nearestLastBlocksWithReward;
            lastBlockWithRewardList[_policyBook].remove(_nearestLastBlocksWithReward);
            _updateReward(_policyBook, _userLeveragePool, _account);
        } else {
            shieldMiningInfo[_policyBook].lastUpdateBlock = block.number;
        }

        if (_account != address(0)) {
            address _userPool = _userLeveragePool != address(0) ? _userLeveragePool : _policyBook;

            _rewards[_account][_userPool] = earned(_policyBook, _userLeveragePool, _account);
            userRewardPerTokenPaid[_account][_userPool] = currentRewardPerToken;
        }
    }

    function getCurrentRewardPerBlock(address _policyBook)
        public
        view
        returns (uint256 _rewardPerBlock)
    {
        uint256 _lastUpdateBlock = shieldMiningInfo[_policyBook].lastUpdateBlock;

        for (uint256 i = 0; i < lastBlockWithRewardList[_policyBook].length(); i++) {
            uint256 _lastBlockWithReward = lastBlockWithRewardList[_policyBook].at(i);
            uint256 _firstBlockWithReward = lastBlockWithRewardList[_policyBook].at(i);
            if (_lastBlockWithReward > _lastUpdateBlock && _firstBlockWithReward != block.number) {
                _rewardPerBlock = _rewardPerBlock.add(
                    shieldMiningInfo[_policyBook].rewardPerBlock[_lastBlockWithReward]
                );
            }
        }
    }

    function _updateNearestLastBlocksWithReward(address _policyBook) internal {
        uint256 _lastUpdateBlock = shieldMiningInfo[_policyBook].lastUpdateBlock;

        uint256 _lastBlockWithReward = shieldMiningInfo[_policyBook].lastBlockWithReward;

        uint256 _nearestLastBlocksWithReward = _lastBlockWithReward;
        uint256 _lastBlock;

        for (uint256 i = 0; i < lastBlockWithRewardList[_policyBook].length(); i++) {
            _lastBlock = lastBlockWithRewardList[_policyBook].at(i);
            if (_lastBlock <= _nearestLastBlocksWithReward && _lastUpdateBlock < _lastBlock) {
                _nearestLastBlocksWithReward = _lastBlock;
            }
        }
        shieldMiningInfo[_policyBook].nearestLastBlocksWithReward = _nearestLastBlocksWithReward;
    }

    function _getFutureRewardTokens(address _policyBook)
        internal
        view
        returns (uint256 _futureRewardTokens)
    {
        uint256 _lastUpdateBlock = shieldMiningInfo[_policyBook].lastUpdateBlock;
        for (uint256 i = 0; i < lastBlockWithRewardList[_policyBook].length(); i++) {
            uint256 _lastBlockWithReward = lastBlockWithRewardList[_policyBook].at(i);

            uint256 blocksLeft = _calculateBlocksLeft(_lastUpdateBlock, _lastBlockWithReward);

            _futureRewardTokens = _futureRewardTokens.add(
                (
                    blocksLeft.mul(
                        shieldMiningInfo[_policyBook].rewardPerBlock[_lastBlockWithReward]
                    )
                )
            );
        }
    }

    function _calculateBlocksLeft(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (block.number >= _to) return 0;

        if (block.number < _from) return _to.sub(_from).add(1);

        return _to.sub(block.number);
    }
}