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

abstract contract Proxy {
    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal virtual view returns (address);

    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () payable external {
        _fallback();
    }

    receive () payable external {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
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


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal override view returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {

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

pragma solidity ^0.7.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address _admin, bytes memory _data) payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
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

    function admin() external ifAdmin returns (address) {

        return _admin();
    }

    function implementation() external ifAdmin returns (address) {

        return _implementation();
    }

    function changeAdmin(address newAdmin) external ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeTo(newImplementation);
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

    function _admin() internal view returns (address adm) {

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

    function _beforeFallback() internal override virtual {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
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
        uint256 _a_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;


    function totalLiquidity() external view returns (uint256);

    function addPolicyPremium(uint256 epochsNumber, uint256 premiumAmount) external;

    function listleveragedCoveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _coveragePools);

    function countleveragedCoveragePools() external view returns (uint256);
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

    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;

    function withdrawLiquidity() external;

    function getPoolsData()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address
        );

    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external;

    function deployVirtualFundsAfterRebalance(uint256 deployedAmount) external;

    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL) external;

    function setRebalancingThreshold(uint256 _newRebalancingThreshold) external;

    function setSafePricingModel(bool _safePricingModel) external;

    function getClaimApprovalAmount(address user) external view returns (uint256);

    function requestWithdrawal(uint256 _tokensToWithdraw) external;
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
    ) external;

    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw, address _user) external;


    function unlockTokens() external;

    function withdrawLiquidity(address sender) external returns (uint256);

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

interface IPolicyBookAdmin {
    function getUpgrader() external view returns (address);

    function getImplementationOfPolicyBook(address policyBookAddress) external returns (address);

    function getImplementationOfPolicyBookFacade(address policyBookFacadeAddress)
        external
        returns (address);

    function getCurrentPolicyBooksImplementation() external view returns (address);

    function getCurrentPolicyBooksFacadeImplementation() external view returns (address);

    function getCurrentUserLeverageImplementation() external view returns (address);

    function whitelist(address policyBookAddress, bool whitelisted) external;

    function whitelistDistributor(address _distributor, uint256 _distributorFee) external;

    function blacklistDistributor(address _distributor) external;

    function isWhitelistedDistributor(address _distributor) external view returns (bool);

    function distributorFees(address _distributor) external view returns (uint256);

    function listDistributors(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _distributors, uint256[] memory _distributorsFees);

    function countDistributors() external view returns (uint256);

    function setPolicyBookFacadeMPLs(
        address _facadeAddress,
        uint256 _userLeverageMPL,
        uint256 _reinsuranceLeverageMPL
    ) external;

    function setPolicyBookFacadeRebalancingThreshold(
        address _facadeAddress,
        uint256 _newRebalancingThreshold
    ) external;

    function setPolicyBookFacadeSafePricingModel(address _facadeAddress, bool _safePricingModel)
        external;

    function setLeveragePortfolioRebalancingThreshold(
        address _LeveragePoolAddress,
        uint256 _newRebalancingThreshold
    ) external;

    function setLeveragePortfolioProtocolConstant(
        address _LeveragePoolAddress,
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;

    function setUserLeverageMaxCapacities(address _userLeverageAddress, uint256 _maxCapacities)
        external;

    function setupPricingModel(
        uint256 _riskyAssetThresholdPercentage,
        uint256 _minimumCostPercentage,
        uint256 _minimumInsuranceCost,
        uint256 _lowRiskMaxPercentPremiumCost,
        uint256 _lowRiskMaxPercentPremiumCost100Utilization,
        uint256 _highRiskMaxPercentPremiumCost,
        uint256 _highRiskMaxPercentPremiumCost100Utilization
    ) external;
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

    function getLiquidityMiningContract() external view returns (address);

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

interface ILiquidityMining {
    struct TeamDetails {
        string teamName;
        address referralLink;
        uint256 membersNumber;
        uint256 totalStakedAmount;
        uint256 totalReward;
    }

    struct UserInfo {
        address userAddr;
        string teamName;
        uint256 stakedAmount;
        uint256 mainNFT; // 0 or NFT index if available
        uint256 platinumNFT; // 0 or NFT index if available
    }

    struct UserRewardsInfo {
        string teamName;
        uint256 totalBMIReward; // total BMI reward
        uint256 availableBMIReward; // current claimable BMI reward
        uint256 incomingPeriods; // how many month are incoming
        uint256 timeToNextDistribution; // exact time left to next distribution
        uint256 claimedBMI; // actual number of claimed BMI
        uint256 mainNFTAvailability; // 0 or NFT index if available
        uint256 platinumNFTAvailability; // 0 or NFT index if available
        bool claimedNFTs; // true if user claimed NFTs
    }

    struct MyTeamInfo {
        TeamDetails teamDetails;
        uint256 myStakedAmount;
        uint256 teamPlace;
    }

    struct UserTeamInfo {
        address teamAddr;
        uint256 stakedAmount;
        uint256 countOfRewardedMonth;
        bool isNFTDistributed;
    }

    struct TeamInfo {
        string name;
        uint256 totalAmount;
        address[] teamLeaders;
    }

    function startLiquidityMiningTime() external view returns (uint256);

    function getTopTeams() external view returns (TeamDetails[] memory teams);

    function getTopUsers() external view returns (UserInfo[] memory users);

    function getAllTeamsLength() external view returns (uint256);

    function getAllTeamsDetails(uint256 _offset, uint256 _limit)
        external
        view
        returns (TeamDetails[] memory _teamDetailsArr);

    function getMyTeamsLength() external view returns (uint256);

    function getMyTeamMembers(uint256 _offset, uint256 _limit)
        external
        view
        returns (address[] memory _teamMembers, uint256[] memory _memberStakedAmount);

    function getAllUsersLength() external view returns (uint256);

    function getAllUsersInfo(uint256 _offset, uint256 _limit)
        external
        view
        returns (UserInfo[] memory _userInfos);

    function getMyTeamInfo() external view returns (MyTeamInfo memory _myTeamInfo);

    function getRewardsInfo(address user)
        external
        view
        returns (UserRewardsInfo memory userRewardInfo);

    function createTeam(string calldata _teamName) external;

    function deleteTeam() external;

    function joinTheTeam(address _referralLink) external;

    function getSlashingPercentage() external view returns (uint256);

    function investSTBL(uint256 _tokensAmount, address _policyBookAddr) external;

    function distributeNFT() external;

    function checkPlatinumNFTReward(address _userAddr) external view returns (uint256);

    function checkMainNFTReward(address _userAddr) external view returns (uint256);

    function distributeBMIReward() external;

    function getTotalUserBMIReward(address _userAddr) external view returns (uint256);

    function checkAvailableBMIReward(address _userAddr) external view returns (uint256);

    function isLMLasting() external view returns (bool);

    function isLMEnded() external view returns (bool);

    function getEndLMTime() external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;


interface IShieldMining {
    struct ShieldMiningInfo {
        IERC20 rewardsToken;
        uint8 decimals;
        uint256 rewardPerBlock;
        uint256 lastUpdateBlock;
        uint256 lastBlockBeforePause;
        uint256 rewardPerTokenStored;
        uint256 rewardTokensLocked;
        uint256 totalSupply;
        uint256[] endsOfDistribution;
    }

    struct ShieldMiningDeposit {
        address policyBook;
        uint256 amount;
        uint256 duration;
        uint256 rewardPerBlock;
        uint256 startBlock;
        uint256 endBlock;
    }

    function blocksWithRewardsPassed(address _policyBook, uint256 _to)
        external
        view
        returns (uint256);

    function rewardPerToken(address _policyBook) external returns (uint256);

    function earned(address _policyBook, address _account) external returns (uint256);

    function updateTotalSupply(
        address _policyBook,
        uint256 newTotalSupply,
        address liquidityProvider
    ) external;

    function associateShieldMining(address _policyBook, address _shieldMiningToken) external;

    function fillShieldMining(
        address _policyBook,
        uint256 _amount,
        uint256 _duration
    ) external;

    function getReward(address _policyBook) external;

    function getAPY(address _policyBook, uint256 _liquidityAdded) external view returns (uint256);

    function recoverNonLockedRewardTokens(address _policyBook) external;

    function getShieldTokenAddress(address _policyBook) external view returns (address);

    function getUserRewardPaid(address _policyBook, address _account)
        external
        view
        returns (uint256);

    function getShieldMiningInfo(address _policyBook)
        external
        view
        returns (ShieldMiningInfo memory _shieldMiningInfo);

    function getDepositList(
        address _account,
        uint256 _offset,
        uint256 _limit
    ) external view returns (ShieldMiningDeposit[] memory _depositsList);
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

    function forceUpdateBMICoverStakingRewardMultiplier() external;

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

interface ILiquidityRegistry {
    struct LiquidityInfo {
        address policyBookAddr;
        uint256 lockedAmount;
        uint256 availableAmount;
        uint256 bmiXRatio; // multiply availableAmount by this num to get stable coin
    }

    struct WithdrawalRequestInfo {
        address policyBookAddr;
        uint256 requestAmount;
        uint256 requestSTBLAmount;
        uint256 availableLiquidity;
        uint256 readyToWithdrawDate;
        uint256 endWithdrawDate;
    }

    struct WithdrawalSetInfo {
        address policyBookAddr;
        uint256 requestAmount;
        uint256 requestSTBLAmount;
        uint256 availableSTBLAmount;
    }

    function tryToAddPolicyBook(address _userAddr, address _policyBookAddr) external;

    function tryToRemovePolicyBook(address _userAddr, address _policyBookAddr) external;

    function getPolicyBooksArrLength(address _userAddr) external view returns (uint256);

    function getPolicyBooksArr(address _userAddr)
        external
        view
        returns (address[] memory _resultArr);

    function getLiquidityInfos(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (LiquidityInfo[] memory _resultArr);

    function getWithdrawalRequests(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256 _arrLength, WithdrawalRequestInfo[] memory _resultArr);

    function getWithdrawalSet(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256 _arrLength, WithdrawalSetInfo[] memory _resultArr);

    function registerWithdrawl(address _policyBook, address _users) external;

    function getAllPendingWithdrawalRequestsAmount()
        external
        returns (uint256 _totalWithdrawlAmount);
}// MIT
pragma solidity ^0.7.4;

interface IPriceFeed {
    function howManyBMIsInUSDT(uint256 usdtAmount) external view returns (uint256);

    function howManyUSDTsInBMI(uint256 bmiAmount) external view returns (uint256);
}// SPDX-Licene-Identifier: MIT
pragma solidity ^0.7.4;





contract PolicyBookFacade is IPolicyBookFacade, AbstractDependant, Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    IPolicyBookAdmin public policyBookAdmin;
    ILeveragePortfolio public reinsurancePool;
    IPolicyBook public override policyBook;
    IShieldMining public shieldMining;
    IPolicyBookRegistry public policyBookRegistry;

    using SafeMath for uint256;

    ILiquidityRegistry public liquidityRegistry;

    address public capitalPoolAddress;
    address public priceFeed;

    uint256 public override VUreinsurnacePool;
    uint256 public override LUreinsurnacePool;
    mapping(address => uint256) public override LUuserLeveragePool;
    uint256 public override totalLeveragedLiquidity;

    uint256 public override userleveragedMPL;
    uint256 public override reinsurancePoolMPL;

    uint256 public override rebalancingThreshold;

    bool public override safePricingModel;

    mapping(address => uint256) public override userLiquidity;

    EnumerableSet.AddressSet internal userLeveragePools;

    event DeployLeverageFunds(uint256 _deployedAmount);

    modifier onlyCapitalPool() {
        require(msg.sender == capitalPoolAddress, "PBFC: only CapitalPool");
        _;
    }

    modifier onlyPolicyBookAdmin() {
        require(msg.sender == address(policyBookAdmin), "PBFC: Not a PBA");
        _;
    }

    modifier onlyLeveragePortfolio() {
        require(
            msg.sender == address(reinsurancePool) ||
                policyBookRegistry.isUserLeveragePool(msg.sender),
            "PBFC: only LeveragePortfolio"
        );
        _;
    }

    modifier onlyPolicyBookRegistry() {
        require(msg.sender == address(policyBookRegistry), "PBFC: Not a policy book registry");
        _;
    }

    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 _initialDeposit
    ) external override initializer {
        policyBook = IPolicyBook(pbProxy);
        rebalancingThreshold = DEFAULT_REBALANCING_THRESHOLD;
        userLiquidity[liquidityProvider] = _initialDeposit;
    }

    function setDependencies(IContractsRegistry contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        IContractsRegistry _contractsRegistry = IContractsRegistry(contractsRegistry);

        capitalPoolAddress = _contractsRegistry.getCapitalPoolContract();
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        policyBookAdmin = IPolicyBookAdmin(_contractsRegistry.getPolicyBookAdminContract());
        priceFeed = _contractsRegistry.getPriceFeedContract();
        reinsurancePool = ILeveragePortfolio(_contractsRegistry.getReinsurancePoolContract());

        shieldMining = IShieldMining(_contractsRegistry.getShieldMiningContract());
    }

    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external override {
        _buyPolicy(msg.sender, msg.sender, _epochsNumber, _coverTokens, 0, address(0));
    }

    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external override {
        _buyPolicy(msg.sender, _holder, _epochsNumber, _coverTokens, 0, address(0));
    }

    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external override {
        uint256 _distributorFee = policyBookAdmin.distributorFees(_distributor);
        _buyPolicy(
            msg.sender,
            msg.sender,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );
    }

    function buyPolicyFromDistributorFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external override {
        uint256 _distributorFee = policyBookAdmin.distributorFees(_distributor);
        _buyPolicy(
            msg.sender,
            _holder,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );
    }

    function addLiquidity(uint256 _liquidityAmount) external override {
        _addLiquidity(msg.sender, msg.sender, _liquidityAmount, 0);
    }

    function addLiquidityFromDistributorFor(address _liquidityHolderAddr, uint256 _liquidityAmount)
        external
        override
    {
        _addLiquidity(msg.sender, _liquidityHolderAddr, _liquidityAmount, 0);
    }

    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount)
        external
        override
    {
        _addLiquidity(msg.sender, msg.sender, _liquidityAmount, _stakeSTBLAmount);
    }

    function _addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) internal {
        policyBook.addLiquidity(
            _liquidityBuyerAddr,
            _liquidityHolderAddr,
            _liquidityAmount,
            _stakeSTBLAmount
        );

        _reevaluateProvidedLeverageStable(_liquidityAmount);
        _updateShieldMining(_liquidityHolderAddr, _liquidityAmount, false);
    }

    function _buyPolicy(
        address _policyBuyerAddr,
        address _policyHolderAddr,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) internal {
        (uint256 _premium, ) =
            policyBook.buyPolicy(
                _policyBuyerAddr,
                _policyHolderAddr,
                _epochsNumber,
                _coverTokens,
                _distributorFee,
                _distributor
            );

        _reevaluateProvidedLeverageStable(_premium);
    }

    function _reevaluateProvidedLeverageStable(uint256 newAmount) internal {
        uint256 _newAmountPercentage;
        uint256 _totalLiq = policyBook.totalLiquidity();

        if (_totalLiq > 0) {
            _newAmountPercentage = newAmount.mul(PERCENTAGE_100).div(_totalLiq);
        }
        if ((_totalLiq > 0 && _newAmountPercentage > rebalancingThreshold) || _totalLiq == 0) {
            _deployLeveragedFunds();
        }
    }

    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external override onlyLeveragePortfolio {
        if (leveragePool == ILeveragePortfolio.LeveragePortfolio.USERLEVERAGEPOOL) {
            LUuserLeveragePool[msg.sender] = deployedAmount;
            LUuserLeveragePool[msg.sender] > 0
                ? userLeveragePools.add(msg.sender)
                : userLeveragePools.remove(msg.sender);
        } else {
            LUreinsurnacePool = deployedAmount;
        }
        uint256 _LUuserLeveragePool;
        if (userLeveragePools.length() > 0) {
            _LUuserLeveragePool = LUuserLeveragePool[userLeveragePools.at(0)];
        }
        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
        emit DeployLeverageFunds(deployedAmount);
    }

    function deployVirtualFundsAfterRebalance(uint256 deployedAmount)
        external
        override
        onlyLeveragePortfolio
    {
        VUreinsurnacePool = deployedAmount;
        uint256 _LUuserLeveragePool;
        if (userLeveragePools.length() > 0) {
            _LUuserLeveragePool = LUuserLeveragePool[userLeveragePools.at(0)];
        }
        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
        emit DeployLeverageFunds(deployedAmount);
    }

    function _deployLeveragedFunds() internal {
        uint256 _deployedAmount;

        uint256 _LUuserLeveragePool;

        _deployedAmount = reinsurancePool.deployVirtualStableToCoveragePools();
        VUreinsurnacePool = _deployedAmount;

        _deployedAmount = reinsurancePool.deployLeverageStableToCoveragePools(
            ILeveragePortfolio.LeveragePortfolio.REINSURANCEPOOL
        );
        LUreinsurnacePool = _deployedAmount;

        address[] memory _userLeverageArr =
            policyBookRegistry.listByType(
                IPolicyBookFabric.ContractType.VARIOUS,
                0,
                policyBookRegistry.countByType(IPolicyBookFabric.ContractType.VARIOUS)
            );
        for (uint256 i = 0; i < _userLeverageArr.length; i++) {
            _deployedAmount = ILeveragePortfolio(_userLeverageArr[i])
                .deployLeverageStableToCoveragePools(
                ILeveragePortfolio.LeveragePortfolio.USERLEVERAGEPOOL
            );
            LUuserLeveragePool[_userLeverageArr[i]] = _deployedAmount;
            _deployedAmount > 0
                ? userLeveragePools.add(_userLeverageArr[i])
                : userLeveragePools.remove(_userLeverageArr[i]);

            _LUuserLeveragePool += _deployedAmount;
        }

        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
    }

    function _updateShieldMining(
        address liquidityProvider,
        uint256 liquidityAmount,
        bool isWithdraw
    ) internal {
        if (shieldMining.getShieldTokenAddress(address(policyBook)) != address(0)) {
            uint256 totalSupplyAfterMint = IERC20(address(policyBook)).totalSupply();
            shieldMining.updateTotalSupply(
                address(policyBook),
                totalSupplyAfterMint,
                liquidityProvider
            );
        }

        if (isWithdraw) {
            userLiquidity[liquidityProvider] -= liquidityAmount;
        } else {
            userLiquidity[liquidityProvider] += liquidityAmount;
        }
    }

    function withdrawLiquidity() external override {
        uint256 _withdrawAmount = policyBook.withdrawLiquidity(msg.sender);
        _reevaluateProvidedLeverageStable(_withdrawAmount);
        _updateShieldMining(msg.sender, _withdrawAmount, true);
    }

    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL)
        external
        override
        onlyPolicyBookAdmin
    {
        userleveragedMPL = _userLeverageMPL;
        reinsurancePoolMPL = _reinsuranceLeverageMPL;
    }

    function setRebalancingThreshold(uint256 _newRebalancingThreshold)
        external
        override
        onlyPolicyBookAdmin
    {
        require(_newRebalancingThreshold > 0, "PBF: threshold can not be 0");
        rebalancingThreshold = _newRebalancingThreshold;
    }

    function setSafePricingModel(bool _safePricingModel) external override onlyPolicyBookAdmin {
        safePricingModel = _safePricingModel;
    }

    function getPoolsData()
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            address
        )
    {
        uint256 _LUuserLeveragePool;
        address _userLeverageAddress;
        if (userLeveragePools.length() > 0) {
            _LUuserLeveragePool = DecimalsConverter.convertFrom18(
                LUuserLeveragePool[userLeveragePools.at(0)],
                policyBook.stblDecimals()
            );
            _userLeverageAddress = userLeveragePools.at(0);
        }
        return (
            DecimalsConverter.convertFrom18(VUreinsurnacePool, policyBook.stblDecimals()),
            DecimalsConverter.convertFrom18(LUreinsurnacePool, policyBook.stblDecimals()),
            _LUuserLeveragePool,
            _userLeverageAddress
        );
    }

    function getClaimApprovalAmount(address user) external view override returns (uint256) {
        (uint256 _coverTokens, , , , ) = policyBook.policyHolders(user);
        _coverTokens = DecimalsConverter.convertFrom18(
            _coverTokens.div(100),
            policyBook.stblDecimals()
        );

        return IPriceFeed(priceFeed).howManyBMIsInUSDT(_coverTokens);
    }

    function requestWithdrawal(uint256 _tokensToWithdraw) external override {
        IPolicyBook.WithdrawalStatus _withdrawlStatus = policyBook.getWithdrawalStatus(msg.sender);

        require(
            _withdrawlStatus == IPolicyBook.WithdrawalStatus.NONE ||
                _withdrawlStatus == IPolicyBook.WithdrawalStatus.EXPIRED,
            "PBf: ongoing withdrawl request"
        );

        policyBook.requestWithdrawal(_tokensToWithdraw, msg.sender);

        liquidityRegistry.registerWithdrawl(address(policyBook), msg.sender);
    }
}// MIT
pragma solidity ^0.7.4;







contract PolicyBookFabric is IPolicyBookFabric, OwnableUpgradeable, AbstractDependant {
    using SafeERC20 for ERC20;
    using Address for address;

    uint256 public constant MINIMAL_INITIAL_DEPOSIT = 100 * DECIMALS18; // 1000 STBL

    IContractsRegistry public contractsRegistry;
    IPolicyBookRegistry public policyBookRegistry;
    IPolicyBookAdmin public policyBookAdmin;
    ILiquidityMining public liquidityMining;
    IShieldMining public shieldMining;
    ERC20 public stblToken;

    address public capitalPoolAddress;

    uint256 public stblDecimals;

    event Created(address insured, ContractType contractType, address at, address facade);

    function __PolicyBookFabric_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        contractsRegistry = _contractsRegistry;

        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        policyBookAdmin = IPolicyBookAdmin(_contractsRegistry.getPolicyBookAdminContract());
        liquidityMining = ILiquidityMining(_contractsRegistry.getLiquidityMiningContract());
        stblToken = ERC20(_contractsRegistry.getUSDTContract());
        capitalPoolAddress = IContractsRegistry(_contractsRegistry).getCapitalPoolContract();
        stblDecimals = stblToken.decimals();
        shieldMining = IShieldMining(_contractsRegistry.getShieldMiningContract());
    }

    function create(
        address _insuranceContract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit,
        address _shieldMiningToken
    ) public override returns (address) {
        require(_insuranceContract != address(0), "PBF: Null address");
        require(bytes(_description).length <= 200, "PBF: Project description is too long");
        require(
            bytes(_projectSymbol).length != 0 && bytes(_projectSymbol).length <= 30,
            "PBF: Project symbol is too long/short"
        );
        require(!liquidityMining.isLMLasting(), "PBF: Creation is blocked during LME");
        require(
            !liquidityMining.isLMEnded() || _initialDeposit >= MINIMAL_INITIAL_DEPOSIT,
            "PBF: Too small deposit"
        );

        TransparentUpgradeableProxy _policyBookProxy =
            new TransparentUpgradeableProxy(
                policyBookAdmin.getCurrentPolicyBooksImplementation(),
                policyBookAdmin.getUpgrader(),
                ""
            );

        IPolicyBook(address(_policyBookProxy)).__PolicyBook_init(
            _insuranceContract,
            _contractType,
            _description,
            _projectSymbol
        );

        TransparentUpgradeableProxy _policyBookFacadeProxy =
            new TransparentUpgradeableProxy(
                policyBookAdmin.getCurrentPolicyBooksFacadeImplementation(),
                policyBookAdmin.getUpgrader(),
                ""
            );

        IPolicyBookFacade(address(_policyBookFacadeProxy)).__PolicyBookFacade_init(
            address(_policyBookProxy),
            msg.sender,
            _initialDeposit
        );

        AbstractDependant(address(_policyBookProxy)).setDependencies(contractsRegistry);
        AbstractDependant(address(_policyBookProxy)).setInjector(address(policyBookAdmin));

        AbstractDependant(address(_policyBookFacadeProxy)).setDependencies(contractsRegistry);
        AbstractDependant(address(_policyBookFacadeProxy)).setInjector(address(policyBookAdmin));

        IPolicyBook(address(_policyBookProxy)).setPolicyBookFacade(
            address(_policyBookFacadeProxy)
        );

        policyBookRegistry.add(
            _insuranceContract,
            _contractType,
            address(_policyBookProxy),
            address(_policyBookFacadeProxy)
        );

        emit Created(
            _insuranceContract,
            _contractType,
            address(_policyBookProxy),
            address(_policyBookFacadeProxy)
        );


        stblToken.safeTransferFrom(
            msg.sender,
            capitalPoolAddress,
            DecimalsConverter.convertFrom18(_initialDeposit, stblDecimals)
        );

        IPolicyBook(address(_policyBookProxy)).addLiquidityFor(msg.sender, _initialDeposit);

        if (_shieldMiningToken != address(0)) {
            shieldMining.associateShieldMining(address(_policyBookProxy), _shieldMiningToken);
        }

        return address(_policyBookProxy);
    }

    function createLeveragePools(
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) public override onlyOwner returns (address) {
        require(bytes(_description).length <= 200, "PBF: Project description is too long");
        require(
            bytes(_projectSymbol).length != 0 && bytes(_projectSymbol).length <= 30,
            "PBF: Project symbol is too long/short"
        );

        TransparentUpgradeableProxy _userLeverageProxy =
            new TransparentUpgradeableProxy(
                policyBookAdmin.getCurrentUserLeverageImplementation(),
                policyBookAdmin.getUpgrader(),
                ""
            );

        IUserLeveragePool(address(_userLeverageProxy)).__UserLeveragePool_init(
            _contractType,
            _description,
            _projectSymbol
        );

        AbstractDependant(address(_userLeverageProxy)).setDependencies(contractsRegistry);
        AbstractDependant(address(_userLeverageProxy)).setInjector(address(policyBookAdmin));
        policyBookRegistry.add(address(0), _contractType, address(_userLeverageProxy), address(0));

        emit Created(address(0), _contractType, address(_userLeverageProxy), address(0));

        return address(_userLeverageProxy);
    }
}