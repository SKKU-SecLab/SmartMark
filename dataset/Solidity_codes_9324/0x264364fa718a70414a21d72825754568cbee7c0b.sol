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

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
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


interface ISTKBMIToken is IERC20Upgradeable {

    function mint(address account, uint256 amount) external;


    function burn(address account, uint256 amount) external;

}// MIT

pragma solidity ^0.7.4;


interface IBMIStaking {

    event StakedBMI(uint256 stakedBMI, uint256 mintedStkBMI, address indexed recipient);
    event BMIWithdrawn(uint256 amountBMI, uint256 burnedStkBMI, address indexed recipient);

    event UnusedRewardPoolRevoked(address recipient, uint256 amount);

    struct WithdrawalInfo {
        uint256 coolDownTimeEnd;
        uint256 amountBMIRequested;
    }

    function stakeWithPermit(
        uint256 _amountBMI,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;


    function stakeFor(address _user, uint256 _amountBMI) external;


    function stake(uint256 _amountBMI) external;


    function maturityAt() external view returns (uint256);


    function isBMIRewardUnlocked() external view returns (bool);


    function whenCanWithdrawBMIReward(address _address) external view returns (uint256);


    function unlockTokensToWithdraw(uint256 _amountBMIUnlock) external;


    function withdraw() external;


    function getWithdrawalInfo(address _userAddr)
        external
        view
        returns (
            uint256 _amountBMIRequested,
            uint256 _amountStkBMI,
            uint256 _unlockPeriod,
            uint256 _availableFor
        );


    function addToPool(uint256 _amount) external;


    function stakingReward(uint256 _amount) external view returns (uint256);


    function getStakedBMI(address _address) external view returns (uint256);


    function getAPY() external view returns (uint256);


    function setRewardPerBlock(uint256 _amount) external;


    function revokeUnusedRewardPool() external;

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

interface ILiquidityMiningStaking {

    function blocksWithRewardsPassed() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function earned(address _account) external view returns (uint256);


    function earnedSlashed(address _account) external view returns (uint256);


    function stakeFor(address _user, uint256 _amount) external;


    function stake(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function getReward() external;


    function restake() external;


    function exit() external;


    function getAPY() external view returns (uint256);

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



abstract contract AbstractSlasher {
    using SafeMath for uint256;
    using Math for uint256;

    uint256 public constant MAX_EXIT_FEE = 90 * PRECISION;
    uint256 public constant MIN_EXIT_FEE = 20 * PRECISION;
    uint256 public constant EXIT_FEE_DURATION = 100 days;

    function getSlashingPercentage(uint256 startTime) public view returns (uint256) {
        startTime = startTime == 0 || startTime > block.timestamp ? block.timestamp : startTime;

        uint256 feeSpan = MAX_EXIT_FEE.sub(MIN_EXIT_FEE);
        uint256 feePerSecond = feeSpan.div(EXIT_FEE_DURATION);
        uint256 fee = Math.min(block.timestamp.sub(startTime).mul(feePerSecond), feeSpan);

        return MAX_EXIT_FEE.sub(fee);
    }

    function getSlashingPercentage() external view virtual returns (uint256);

    function _applySlashing(uint256 amount, uint256 startTime) internal view returns (uint256) {
        return amount.sub(_getSlashed(amount, startTime));
    }

    function _getSlashed(uint256 amount, uint256 startTime) internal view returns (uint256) {
        return amount.mul(getSlashingPercentage(startTime)).div(PERCENTAGE_100);
    }
}// MIT
pragma solidity ^0.7.4;






contract LiquidityMiningStaking is
    ILiquidityMiningStaking,
    OwnableUpgradeable,
    ReentrancyGuard,
    AbstractDependant,
    AbstractSlasher
{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public legacyLiquidityMiningStakingAddress;
    IERC20 public rewardsToken;
    address public stakingToken;
    IBMIStaking public bmiStaking;
    ILiquidityMining public liquidityMining;

    uint256 public rewardPerBlock;
    uint256 public firstBlockWithReward;
    uint256 public lastBlockWithReward;
    uint256 public lastUpdateBlock;
    uint256 public rewardPerTokenStored;
    uint256 public rewardTokensLocked;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) internal _rewards;

    uint256 public totalStaked;
    mapping(address => uint256) public staked;

    event RewardsSet(
        uint256 rewardPerBlock,
        uint256 firstBlockWithReward,
        uint256 lastBlockWithReward
    );
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRestaked(address indexed user, uint256 reward);
    event RewardTokensRecovered(uint256 amount);

    modifier onlyStaking() {

        require(
            _msgSender() == legacyLiquidityMiningStakingAddress,
            "LMS: Not a staking contract"
        );
        _;
    }

    modifier updateReward(address account) {

        _updateReward(account);
        _;
    }

    function __LiquidityMiningStaking_init() external initializer {

        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {

        legacyLiquidityMiningStakingAddress = _contractsRegistry
            .getLegacyLiquidityMiningStakingContract();
        rewardsToken = IERC20(_contractsRegistry.getBMIContract());
        bmiStaking = IBMIStaking(_contractsRegistry.getBMIStakingContract());
        stakingToken = _contractsRegistry.getUniswapBMIToETHPairContract();
        liquidityMining = ILiquidityMining(_contractsRegistry.getLiquidityMiningContract());
    }

    function blocksWithRewardsPassed() public view override returns (uint256) {

        uint256 from = Math.max(lastUpdateBlock, firstBlockWithReward);
        uint256 to = Math.min(block.number, lastBlockWithReward);

        return from >= to ? 0 : to.sub(from);
    }

    function rewardPerToken() public view override returns (uint256) {

        uint256 totalPoolStaked = totalStaked;

        if (totalPoolStaked == 0) {
            return rewardPerTokenStored;
        }

        uint256 accumulatedReward =
            blocksWithRewardsPassed().mul(rewardPerBlock).mul(DECIMALS18).div(totalPoolStaked);

        return rewardPerTokenStored.add(accumulatedReward);
    }

    function earned(address _account) public view override returns (uint256) {

        uint256 rewardsDifference = rewardPerToken().sub(userRewardPerTokenPaid[_account]);
        uint256 newlyAccumulated = staked[_account].mul(rewardsDifference).div(DECIMALS18);

        return _rewards[_account].add(newlyAccumulated);
    }

    function getSlashingPercentage() external view override returns (uint256) {

        return getSlashingPercentage(liquidityMining.startLiquidityMiningTime());
    }

    function earnedSlashed(address _account) external view override returns (uint256) {

        return _applySlashing(earned(_account), liquidityMining.startLiquidityMiningTime());
    }

    function stakeFor(address _user, uint256 _amount) external override onlyStaking {

        require(_amount > 0, "LMS: Amount should be greater than 0");

        _stake(_user, _amount);
    }

    function stake(uint256 _amount) external override nonReentrant updateReward(_msgSender()) {

        require(_amount > 0, "LMS: Amount should be greater than 0");

        IERC20(stakingToken).safeTransferFrom(_msgSender(), address(this), _amount);
        _stake(_msgSender(), _amount);
    }

    function withdraw(uint256 _amount) public override nonReentrant updateReward(_msgSender()) {

        require(_amount > 0, "LMS: Amount should be greater than 0");

        uint256 userStaked = staked[_msgSender()];

        require(userStaked >= _amount, "LMS: Insufficient staked amount");

        totalStaked = totalStaked.sub(_amount);
        staked[_msgSender()] = userStaked.sub(_amount);
        IERC20(stakingToken).safeTransfer(_msgSender(), _amount);

        emit Withdrawn(_msgSender(), _amount);
    }

    function getReward() public override nonReentrant updateReward(_msgSender()) {

        uint256 reward = _rewards[_msgSender()];

        if (reward > 0) {
            delete _rewards[_msgSender()];

            uint256 bmiStakingProfit =
                _getSlashed(reward, liquidityMining.startLiquidityMiningTime());
            uint256 profit = reward.sub(bmiStakingProfit);

            rewardsToken.safeTransfer(address(bmiStaking), bmiStakingProfit);
            bmiStaking.addToPool(bmiStakingProfit);

            rewardsToken.safeTransfer(_msgSender(), profit);

            rewardTokensLocked = rewardTokensLocked.sub(reward);

            emit RewardPaid(_msgSender(), profit);
        }
    }

    function restake() external override nonReentrant updateReward(_msgSender()) {

        uint256 reward = _rewards[_msgSender()];

        if (reward > 0) {
            delete _rewards[_msgSender()];

            rewardsToken.transfer(address(bmiStaking), reward);
            bmiStaking.stakeFor(_msgSender(), reward);

            rewardTokensLocked = rewardTokensLocked.sub(reward);

            emit RewardRestaked(_msgSender(), reward);
        }
    }

    function exit() external override {

        withdraw(staked[_msgSender()]);
        getReward();
    }

    function getAPY() external view override returns (uint256) {

        uint256 totalSupply = IUniswapV2Pair(stakingToken).totalSupply();
        (uint256 reserveBMI, , ) = IUniswapV2Pair(stakingToken).getReserves();

        if (totalSupply == 0 || reserveBMI == 0) {
            return 0;
        }

        return
            rewardPerBlock.mul(BLOCKS_PER_YEAR).mul(PERCENTAGE_100).div(
                totalStaked.add(APY_TOKENS).mul(reserveBMI.mul(2).mul(10**20).div(totalSupply))
            );
    }

    function setRewards(
        uint256 _rewardPerBlock,
        uint256 _startingBlock,
        uint256 _blocksAmount
    ) external onlyOwner updateReward(address(0)) {

        uint256 unlockedTokens = _getFutureRewardTokens();

        rewardPerBlock = _rewardPerBlock;
        firstBlockWithReward = _startingBlock;
        lastBlockWithReward = _startingBlock.add(_blocksAmount).sub(1);

        uint256 lockedTokens = _getFutureRewardTokens();
        rewardTokensLocked = rewardTokensLocked.sub(unlockedTokens).add(lockedTokens);

        require(
            rewardTokensLocked <= rewardsToken.balanceOf(address(this)),
            "LMS: Not enough tokens for the rewards"
        );

        emit RewardsSet(_rewardPerBlock, _startingBlock, lastBlockWithReward);
    }

    function recoverNonLockedRewardTokens() external onlyOwner {

        uint256 nonLockedTokens = rewardsToken.balanceOf(address(this)).sub(rewardTokensLocked);

        rewardsToken.safeTransfer(owner(), nonLockedTokens);

        emit RewardTokensRecovered(nonLockedTokens);
    }

    function _stake(address _user, uint256 _amount) internal {

        totalStaked = totalStaked.add(_amount);
        staked[_user] = staked[_user].add(_amount);

        emit Staked(_user, _amount);
    }

    function _updateReward(address account) internal {

        uint256 currentRewardPerToken = rewardPerToken();

        rewardPerTokenStored = currentRewardPerToken;
        lastUpdateBlock = block.number;

        if (account != address(0)) {
            _rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = currentRewardPerToken;
        }
    }

    function _getFutureRewardTokens() internal view returns (uint256) {

        uint256 blocksLeft = _calculateBlocksLeft(firstBlockWithReward, lastBlockWithReward);

        return blocksLeft.mul(rewardPerBlock);
    }

    function _calculateBlocksLeft(uint256 _from, uint256 _to) internal view returns (uint256) {

        if (block.number >= _to) return 0;

        if (block.number < _from) return _to.sub(_from).add(1);

        return _to.sub(block.number);
    }
}