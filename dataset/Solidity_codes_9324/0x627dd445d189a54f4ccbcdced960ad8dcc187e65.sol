pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;// MIT

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

    function getWETHContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getLiquidityMiningContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getPolicyBookAdminContract() external view returns (address);

    function getPolicyQuoteContract() external view returns (address);

    function getLegacyBMIStakingContract() external view returns (address);

    function getBMIStakingContract() external view returns (address);

    function getSTKBMIContract() external view returns (address);

    function getVBMIContract() external view returns (address);

    function getLegacyLiquidityMiningStakingContract() external view returns (address);

    function getLiquidityMiningStakingContract() external view returns (address);

    function getReputationSystemContract() external view returns (address);
}// MIT
pragma solidity ^0.7.4;

interface IPolicyBookFabric {
    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE}

    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit
    ) external returns (address);
}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookRegistry {
    struct PolicyBookStats {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 maxCapacity;
        uint256 totalSTBLLiquidity;
        uint256 stakedSTBL;
        uint256 APY;
        uint256 annualInsuranceCost;
        uint256 bmiXRatio;
        bool whitelisted;
    }

    function add(
        address insuredContract,
        IPolicyBookFabric.ContractType contractType,
        address policyBook
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

interface IRewardsGenerator {
    struct PolicyBookRewardInfo {
        uint256 rewardMultiplier; // includes 5 decimal places
        uint256 totalStaked;
        uint256 startStakeBlock;
        uint256 lastUpdateBlock;
        uint256 cumulativeSum; // includes 100 percentage
        uint256 cumulativeReward;
        uint256 average; // includes 100 percentage
        uint256 toUpdateAverage; // includes 100 percentage
    }

    struct StakeRewardInfo {
        uint256 averageOnStake; // includes 100 percentage
        uint256 aggregatedReward;
        uint256 stakeAmount;
        uint256 stakeBlock;
    }

    function updatePolicyBookShare(uint256 newRewardMultiplier) external;

    function aggregate(
        address policyBookAddress,
        uint256[] calldata nftIndexes,
        uint256 nftIndexTo
    ) external;

    function stake(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 amount
    ) external;

    function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function getPolicyBookRewardPerBlock(address policyBookAddress)
        external
        view
        returns (uint256);

    function getStakedPolicyBookSTBL(address policyBookAddress) external view returns (uint256);

    function getStakedNFTSTBL(uint256 nftIndex) external view returns (uint256);

    function getReward(address policyBookAddress, uint256 nftIndex)
        external
        view
        returns (uint256);

    function withdrawFunds(address policyBookAddress, uint256 nftIndex) external returns (uint256);

    function withdrawReward(address policyBookAddress, uint256 nftIndex)
        external
        returns (uint256);
}// MIT
pragma solidity ^0.7.4;

interface IBMICoverStaking {
    struct StakingInfo {
        address policyBookAddress;
        uint256 stakedBMIXAmount;
    }

    struct PolicyBookInfo {
        uint256 totalStakedSTBL;
        uint256 rewardPerBlock;
        uint256 stakingAPY;
        uint256 liquidityAPY;
    }

    struct UserInfo {
        uint256 totalStakedBMIX;
        uint256 totalStakedSTBL;
        uint256 totalBmiReward;
    }

    struct NFTsInfo {
        uint256 nftIndex;
        string uri;
        uint256 stakedBMIXAmount;
        uint256 stakedSTBLAmount;
        uint256 reward;
    }

    function aggregateNFTs(address policyBookAddress, uint256[] calldata tokenIds) external;

    function stakeBMIX(uint256 amount, address policyBookAddress) external;

    function stakeBMIXWithPermit(
        uint256 bmiXAmount,
        address policyBookAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function stakeBMIXFrom(address user, uint256 amount) external;

    function stakeBMIXFromWithPermit(
        address user,
        uint256 bmiXAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function restakeBMIProfit(uint256 tokenId) external;

    function restakeStakerBMIProfit(address policyBookAddress) external;

    function withdrawBMIProfit(uint256 tokenID) external;

    function withdrawStakerBMIProfit(address policyBookAddress) external;

    function withdrawFundsWithProfit(uint256 tokenID) external;

    function withdrawStakerFundsWithProfit(address policyBookAddress) external;

    function stakingInfoByToken(uint256 tokenID) external view returns (StakingInfo memory);

    function stakingInfoByStaker(
        address staker,
        address[] calldata policyBooksAddresses,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            PolicyBookInfo[] memory policyBooksInfo,
            UserInfo[] memory usersInfo,
            uint256[] memory nftsCount,
            NFTsInfo[][] memory nftsInfo
        );

    function getSlashedBMIProfit(uint256 tokenId) external view returns (uint256);

    function getBMIProfit(uint256 tokenId) external view returns (uint256);

    function getSlashedStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);

    function getStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);

    function totalStaked(address user) external view returns (uint256);

    function totalStakedSTBL(address user) external view returns (uint256);

    function stakedByNFT(uint256 tokenId) external view returns (uint256);

    function stakedSTBLByNFT(uint256 tokenId) external view returns (uint256);

    function policyBookByNFT(uint256 tokenId) external view returns (address);

    function balanceOf(address user) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function tokenOfOwnerByIndex(address user, uint256 index) external view returns (uint256);
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// MIT
pragma solidity ^0.7.4;

interface IPriceFeed {
    function howManyBMIsInUSDT(uint256 usdtAmount) external view returns (uint256);

    function howManyUSDTsInBMI(uint256 bmiAmount) external view returns (uint256);
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




contract PriceFeed is IPriceFeed, AbstractDependant {
    IUniswapV2Router02 public uniswapRouter;

    address public wethToken;
    address public bmiToken;
    address public usdtToken;

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        uniswapRouter = IUniswapV2Router02(_contractsRegistry.getUniswapRouterContract());
        wethToken = _contractsRegistry.getWETHContract();
        bmiToken = _contractsRegistry.getBMIContract();
        usdtToken = _contractsRegistry.getUSDTContract();
    }

    function howManyBMIsInUSDT(uint256 usdtAmount) external view override returns (uint256) {
        if (usdtAmount == 0) {
            return 0;
        }

        address[] memory pairs = new address[](3);
        pairs[0] = usdtToken;
        pairs[1] = wethToken;
        pairs[2] = bmiToken;

        uint256[] memory amounts = uniswapRouter.getAmountsOut(usdtAmount, pairs);

        return amounts[amounts.length - 1];
    }

    function howManyUSDTsInBMI(uint256 bmiAmount) external view override returns (uint256) {
        if (bmiAmount == 0) {
            return 0;
        }

        address[] memory pairs = new address[](3);
        pairs[0] = bmiToken;
        pairs[1] = wethToken;
        pairs[2] = usdtToken;

        uint256[] memory amounts = uniswapRouter.getAmountsOut(bmiAmount, pairs);

        return amounts[amounts.length - 1];
    }
}// MIT
pragma solidity ^0.7.4;






contract RewardsGenerator is IRewardsGenerator, OwnableUpgradeable, AbstractDependant {
    using SafeMath for uint256;
    using Math for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public bmiToken;
    IPolicyBookRegistry public policyBookRegistry;
    IPriceFeed public priceFeed;
    address public bmiCoverStakingAddress;
    address public bmiStakingAddress;

    uint256 public stblDecimals;

    uint256 public rewardPerBlock; // is zero by default
    uint256 public totalPoolStaked; // includes 5 decimal places

    uint256 public cumulativeSum; // includes 100 percentage
    uint256 public toUpdateRatio; // includes 100 percentage

    uint256 public startStakeBlock;
    uint256 public lastUpdateBlock;

    mapping(address => PolicyBookRewardInfo) internal _policyBooksRewards; // policybook -> policybook info
    mapping(uint256 => StakeRewardInfo) internal _stakes; // nft index -> stake info

    address public newRewardsGeneratorAddress;

    event TokensSent(address stakingAddress, uint256 amount);
    event TokensRecovered(address to, uint256 amount);
    event RewardPerBlockSet(uint256 rewardPerBlock);
    event Migrated(uint256 nftIndex, uint256 reward);

    modifier onlyBMICoverStaking() {
        require(
            _msgSender() == bmiCoverStakingAddress,
            "RewardsGenerator: Caller is not a BMICoverStaking contract"
        );
        _;
    }

    modifier onlyPolicyBooks() {
        require(
            policyBookRegistry.isPolicyBook(_msgSender()),
            "RewardsGenerator: The caller does not have access"
        );
        _;
    }

    function __RewardsGenerator_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        bmiToken = IERC20(_contractsRegistry.getBMIContract());
        bmiStakingAddress = _contractsRegistry.getBMIStakingContract();
        bmiCoverStakingAddress = _contractsRegistry.getBMICoverStakingContract();
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        priceFeed = IPriceFeed(_contractsRegistry.getPriceFeedContract());

        stblDecimals = ERC20(_contractsRegistry.getUSDTContract()).decimals();
    }

    function setNewRewardsGenerator(address _newRewardsGeneratorAddress) external onlyOwner {
        newRewardsGeneratorAddress = _newRewardsGeneratorAddress;
    }

    function recoverTokens() external onlyOwner {
        uint256 balance = bmiToken.balanceOf(address(this));

        bmiToken.transfer(_msgSender(), balance);

        emit TokensRecovered(_msgSender(), balance);
    }

    function sendFundsToBMIStaking(uint256 amount) external onlyOwner {
        bmiToken.transfer(bmiStakingAddress, amount);

        emit TokensSent(bmiStakingAddress, amount);
    }

    function sendFundsToBMICoverStaking(uint256 amount) external onlyOwner {
        bmiToken.transfer(bmiCoverStakingAddress, amount);

        emit TokensSent(bmiCoverStakingAddress, amount);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        rewardPerBlock = _rewardPerBlock;

        _updateCumulativeSum(address(0));

        emit RewardPerBlockSet(_rewardPerBlock);
    }

    function _updateCumulativeSum(address policyBookAddress) internal {
        uint256 toAddSum = block.number.sub(lastUpdateBlock).mul(toUpdateRatio);
        uint256 totalStaked = totalPoolStaked;

        uint256 newCumulativeSum = cumulativeSum.add(toAddSum);

        totalStaked > 0
            ? toUpdateRatio = rewardPerBlock.mul(PERCENTAGE_100 * 10**5).div(totalStaked)
            : toUpdateRatio = 0;

        if (policyBookAddress != address(0)) {
            PolicyBookRewardInfo storage info = _policyBooksRewards[policyBookAddress];

            info.cumulativeReward = info.cumulativeReward.add(
                newCumulativeSum
                    .sub(info.cumulativeSum)
                    .mul(info.totalStaked)
                    .mul(info.rewardMultiplier)
                    .div(PERCENTAGE_100 * 10**5)
            );

            info.cumulativeSum = newCumulativeSum;
        }

        cumulativeSum = newCumulativeSum;
        lastUpdateBlock = block.number;
    }

    function _getNewPoolAverage(address policyBookAddress)
        internal
        view
        returns (uint256 average, uint256 toUpdateAverage)
    {
        PolicyBookRewardInfo storage info = _policyBooksRewards[policyBookAddress];

        uint256 startStakeBlockPB = info.startStakeBlock;
        uint256 lastUpdateBlockPB = info.lastUpdateBlock;
        uint256 totalStaked = info.totalStaked;

        uint256 prevStakedBlocks = lastUpdateBlockPB.sub(startStakeBlockPB);
        uint256 stakedBlocks = block.number.sub(lastUpdateBlockPB);
        uint256 allBlocks = block.number.sub(startStakeBlockPB);

        allBlocks > 0
            ? average = prevStakedBlocks
                .mul(info.average)
                .add(info.toUpdateAverage.mul(stakedBlocks))
                .div(allBlocks)
            : average = 0;

        totalStaked > 0
            ? toUpdateAverage = PERCENTAGE_100.mul(10**18).div(totalStaked)
            : toUpdateAverage = 0;
    }

    function _updatePoolAverage(address policyBookAddress) internal {
        PolicyBookRewardInfo storage info = _policyBooksRewards[policyBookAddress];

        (info.average, info.toUpdateAverage) = _getNewPoolAverage(policyBookAddress);

        info.lastUpdateBlock = block.number;
    }

    function _getPoolCumulativeReward(address policyBookAddress) internal view returns (uint256) {
        PolicyBookRewardInfo storage info = _policyBooksRewards[policyBookAddress];

        uint256 toAddSum = block.number.sub(lastUpdateBlock).mul(toUpdateRatio);

        return
            info.cumulativeReward.add(
                cumulativeSum
                    .add(toAddSum)
                    .sub(info.cumulativeSum)
                    .mul(info.totalStaked)
                    .mul(info.rewardMultiplier)
                    .div(PERCENTAGE_100 * 10**5)
            );
    }

    function _getNFTPoolShare(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 currentAverage
    ) internal view returns (uint256) {
        uint256 startStakeBlockPB = _policyBooksRewards[policyBookAddress].startStakeBlock;
        uint256 allBlocks = block.number.sub(startStakeBlockPB);
        uint256 depositBlock = _stakes[nftIndex].stakeBlock.sub(startStakeBlockPB);

        return
            currentAverage
                .mul(allBlocks)
                .sub(_stakes[nftIndex].averageOnStake.mul(depositBlock))
                .mul(_stakes[nftIndex].stakeAmount)
                .div(allBlocks * 10**18);
    }

    function _getReward(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 currentAverage,
        uint256 currentCumulativeReward
    ) internal view returns (uint256) {
        return
            _stakes[nftIndex].aggregatedReward.add(
                _getNFTPoolShare(policyBookAddress, nftIndex, currentAverage)
                    .mul(currentCumulativeReward)
                    .div(PERCENTAGE_100)
            );
    }

    function updatePolicyBookShare(uint256 newRewardMultiplier) external override onlyPolicyBooks {
        PolicyBookRewardInfo storage info = _policyBooksRewards[_msgSender()];

        uint256 totalStaked = info.totalStaked;

        totalPoolStaked = totalPoolStaked.sub(totalStaked.mul(info.rewardMultiplier));
        totalPoolStaked = totalPoolStaked.add(totalStaked.mul(newRewardMultiplier));

        _updateCumulativeSum(_msgSender());

        info.rewardMultiplier = newRewardMultiplier;
    }

    function aggregate(
        address policyBookAddress,
        uint256[] calldata nftIndexes,
        uint256 nftIndexTo
    ) external override onlyBMICoverStaking {
        require(_stakes[nftIndexTo].stakeBlock == 0, "RewardsGenerator: Aggregator is staked");

        _updateCumulativeSum(policyBookAddress);
        _updatePoolAverage(policyBookAddress);

        uint256 currentAverage = _policyBooksRewards[policyBookAddress].average;
        uint256 currentCumulativeReward = _policyBooksRewards[policyBookAddress].cumulativeReward;
        uint256 aggregatedReward;
        uint256 aggregatedStakeAmount;

        for (uint256 i = 0; i < nftIndexes.length; i++) {
            aggregatedReward = aggregatedReward.add(
                _getReward(
                    policyBookAddress,
                    nftIndexes[i],
                    currentAverage,
                    currentCumulativeReward
                )
            );
            aggregatedStakeAmount = aggregatedStakeAmount.add(_stakes[nftIndexes[i]].stakeAmount);

            delete _stakes[nftIndexes[i]];
        }

        require(aggregatedStakeAmount > 0, "RewardsGenerator: Aggregated not staked");

        _stakes[nftIndexTo] = StakeRewardInfo(
            currentAverage,
            aggregatedReward,
            aggregatedStakeAmount,
            block.number
        );
    }

    function stake(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 amount
    ) external override onlyBMICoverStaking {
        require(_stakes[nftIndex].stakeBlock == 0, "RewardsGenerator: Already staked");

        PolicyBookRewardInfo storage info = _policyBooksRewards[policyBookAddress];

        if (info.totalStaked == 0) {
            info.lastUpdateBlock = info.startStakeBlock = block.number;

            if (info.cumulativeReward > 0) {
                info.cumulativeReward = 0;
            }
        }

        totalPoolStaked = totalPoolStaked.add(amount.mul(info.rewardMultiplier));

        _updateCumulativeSum(policyBookAddress);

        info.totalStaked = info.totalStaked.add(amount);

        _updatePoolAverage(policyBookAddress);

        _stakes[nftIndex] = StakeRewardInfo(info.average, 0, amount, block.number);
    }

    function getPolicyBookAPY(address policyBookAddress)
        external
        view
        override
        onlyBMICoverStaking
        returns (uint256)
    {
        uint256 policyBookRewardMultiplier =
            _policyBooksRewards[policyBookAddress].rewardMultiplier;
        uint256 totalStakedPolicyBook =
            _policyBooksRewards[policyBookAddress].totalStaked.add(APY_TOKENS);

        uint256 rewardPerBlockPolicyBook =
            policyBookRewardMultiplier.mul(totalStakedPolicyBook).mul(rewardPerBlock).div(
                totalPoolStaked.add(policyBookRewardMultiplier.mul(APY_TOKENS))
            );

        if (rewardPerBlockPolicyBook == 0) {
            return 0;
        }

        uint256 rewardPerBlockPolicyBookSTBL =
            DecimalsConverter
                .convertTo18(priceFeed.howManyUSDTsInBMI(rewardPerBlockPolicyBook), stblDecimals)
                .mul(10**5); // 5 decimals of precision

        return
            rewardPerBlockPolicyBookSTBL.mul(BLOCKS_PER_DAY * 365).mul(100).div(
                totalStakedPolicyBook
            );
    }

    function getPolicyBookRewardPerBlock(address policyBookAddress)
        external
        view
        override
        returns (uint256)
    {
        uint256 totalStaked = totalPoolStaked;

        return
            totalStaked > 0
                ? _policyBooksRewards[policyBookAddress]
                    .rewardMultiplier
                    .mul(_policyBooksRewards[policyBookAddress].totalStaked)
                    .mul(rewardPerBlock)
                    .mul(PRECISION)
                    .div(totalStaked)
                : 0;
    }

    function getStakedPolicyBookSTBL(address policyBookAddress)
        external
        view
        override
        returns (uint256)
    {
        return _policyBooksRewards[policyBookAddress].totalStaked;
    }

    function getStakedNFTSTBL(uint256 nftIndex) external view override returns (uint256) {
        return _stakes[nftIndex].stakeAmount;
    }

    function getReward(address policyBookAddress, uint256 nftIndex)
        external
        view
        override
        onlyBMICoverStaking
        returns (uint256)
    {
        uint256 cumulativeRewardPB = _getPoolCumulativeReward(policyBookAddress);
        (uint256 currentAverage, ) = _getNewPoolAverage(policyBookAddress);

        return _getReward(policyBookAddress, nftIndex, currentAverage, cumulativeRewardPB);
    }

    function _withdraw(
        address policyBookAddress,
        uint256 nftIndex,
        bool onlyReward
    ) internal returns (uint256) {
        require(_stakes[nftIndex].stakeBlock > 0, "RewardsGenerator: Not staked");

        PolicyBookRewardInfo storage info = _policyBooksRewards[policyBookAddress];

        if (!onlyReward) {
            uint256 amount = _stakes[nftIndex].stakeAmount;

            totalPoolStaked = totalPoolStaked.sub(amount.mul(info.rewardMultiplier));

            _updateCumulativeSum(policyBookAddress);

            info.totalStaked = info.totalStaked.sub(amount);
        } else {
            _updateCumulativeSum(policyBookAddress);
        }

        _updatePoolAverage(policyBookAddress);

        return _getReward(policyBookAddress, nftIndex, info.average, info.cumulativeReward);
    }

    function withdrawFunds(address policyBookAddress, uint256 nftIndex)
        external
        override
        onlyBMICoverStaking
        returns (uint256)
    {
        uint256 reward = _withdraw(policyBookAddress, nftIndex, false);

        delete _stakes[nftIndex];

        return reward;
    }

    function withdrawReward(address policyBookAddress, uint256 nftIndex)
        external
        override
        onlyBMICoverStaking
        returns (uint256)
    {
        uint256 reward = _withdraw(policyBookAddress, nftIndex, true);

        _stakes[nftIndex].averageOnStake = _policyBooksRewards[policyBookAddress].average;
        _stakes[nftIndex].aggregatedReward = 0;
        _stakes[nftIndex].stakeBlock = block.number;

        return reward;
    }

    function migrate(uint256 offset, uint256 limit) external onlyOwner {
        require(
            newRewardsGeneratorAddress != address(0),
            "RewardsGenerator: Migration is blocked"
        );

        IBMICoverStaking bmiCoverStaking = IBMICoverStaking(bmiCoverStakingAddress);

        uint256 to = offset.add(limit);
        uint256 migratedNFTs;

        for (uint256 i = offset; i < to; i++) {
            if (_stakes[i].stakeBlock == 0) {
                continue;
            }

            address policyBookAddress = bmiCoverStaking.stakingInfoByToken(i).policyBookAddress;

            uint256 reward = _withdraw(policyBookAddress, i, false);

            (bool succ, ) =
                newRewardsGeneratorAddress.call(
                    abi.encodeWithSignature(
                        "migrationStake(address,uint256,uint256,uint256)",
                        policyBookAddress,
                        i,
                        _stakes[i].stakeAmount,
                        reward
                    )
                );

            require(succ, "Something went wrong");

            emit Migrated(i, reward);

            delete _stakes[i];

            migratedNFTs++;
        }

        require(migratedNFTs > 0, "RewardsGenerator: Nothing to migrate");
    }
}