
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IPoolInitializer {

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface IERC721Permit is IERC721 {

    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPeripheryImmutableState {

    function factory() external view returns (address);


    function WETH9() external view returns (address);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xc02f72e8ae5e68802e6d893d58ddfb0df89a2f4c9c2f04927db1186a29373660;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {

        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}// GPL-2.0-or-later
pragma solidity >=0.7.5;



interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{

    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );


    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );


    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);


    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);


    function burn(uint256 tokenId) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}// MIT
pragma solidity 0.7.6;


interface IERC20Extended is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT
pragma solidity 0.7.6;

interface IRewardEscrow {

    function MAX_VESTING_ENTRIES() external view returns (uint256);


    function addRewardsContract(address _rewardContract) external;


    function appendVestingEntry(
        address token,
        address account,
        address pool,
        uint256 quantity
    ) external;


    function balanceOf(address token, address account)
        external
        view
        returns (uint256);


    function checkAccountSchedule(
        address pool,
        address token,
        address account
    ) external view returns (uint256[] memory);


    function clrPoolVestingPeriod(address) external view returns (uint256);


    function getNextVestingEntry(
        address pool,
        address token,
        address account
    ) external view returns (uint256[2] memory);


    function getNextVestingIndex(
        address pool,
        address token,
        address account
    ) external view returns (uint256);


    function getNextVestingQuantity(
        address pool,
        address token,
        address account
    ) external view returns (uint256);


    function getNextVestingTime(
        address pool,
        address token,
        address account
    ) external view returns (uint256);


    function getVestingQuantity(
        address pool,
        address token,
        address account,
        uint256 index
    ) external view returns (uint256);


    function getVestingScheduleEntry(
        address pool,
        address token,
        address account,
        uint256 index
    ) external view returns (uint256[2] memory);


    function getVestingTime(
        address pool,
        address token,
        address account,
        uint256 index
    ) external view returns (uint256);


    function initialize() external;


    function isRewardContract(address) external view returns (bool);


    function numVestingEntries(
        address pool,
        address token,
        address account
    ) external view returns (uint256);


    function owner() external view returns (address);


    function removeRewardsContract(address _rewardContract) external;


    function renounceOwnership() external;


    function setCLRPoolVestingPeriod(address pool, uint256 vestingPeriod)
        external;


    function totalEscrowedAccountBalance(address, address)
        external
        view
        returns (uint256);


    function totalEscrowedBalance(address) external view returns (uint256);


    function totalSupply(address token) external view returns (uint256);


    function totalVestedAccountBalance(address, address)
        external
        view
        returns (uint256);


    function transferOwnership(address newOwner) external;


    function vest(address pool, address token) external;


    function vestAll(address pool, address[] memory tokens) external;


    function vestingSchedules(
        address,
        address,
        address,
        uint256,
        uint256
    ) external view returns (uint256);

}// MIT
pragma solidity 0.7.6;


interface IStakingRewards {

    function earned(address account, address token)
        external
        view
        returns (uint256);


    function getRewardForDuration(address token)
        external
        view
        returns (uint256);


    function getRewardTokens() external view returns (address[] memory tokens);


    function getRewardTokensCount() external view returns (uint256);


    function lastTimeRewardApplicable() external view returns (uint256);


    function lastUpdateTime(address) external view returns (uint256);


    function periodFinish() external view returns (uint256);


    function rewardEscrow() external view returns (IRewardEscrow);


    function rewardInfo(address)
        external
        view
        returns (
            uint256 rewardRate,
            uint256 rewardPerTokenStored,
            uint256 totalRewardAmount,
            uint256 remainingRewardAmount
        );


    function rewardPerToken(address token) external view returns (uint256);


    function rewardTokens(uint256) external view returns (address);


    function rewardsAreEscrowed() external view returns (bool);


    function rewardsDuration() external view returns (uint256);


    function stakedBalanceOf(address account) external view returns (uint256);


    function stakedTotalSupply() external view returns (uint256);


    function claimReward() external;


    function initializeReward(uint256 rewardAmount, address token) external;


    function setRewardsDuration(uint256 _rewardsDuration) external;

}// BUSL-1.1
pragma solidity 0.7.6;


interface ICLR is IERC20, IStakingRewards {

    function addManager(address _manager) external;


    function adminStake(uint256 amount0, uint256 amount1) external;


    function adminSwap(uint256 amount, bool _0for1) external;


    function calculateAmountsMintedSingleToken(uint8 inputAsset, uint256 amount)
        external
        view
        returns (uint256 amount0Minted, uint256 amount1Minted);


    function calculateMintAmount(uint256 amount0, uint256 amount1)
        external
        view
        returns (uint256 mintAmount);


    function calculatePoolMintedAmounts(uint256 amount0, uint256 amount1)
        external
        view
        returns (uint256 amount0Minted, uint256 amount1Minted);


    function collect()
        external
        returns (uint256 collected0, uint256 collected1);


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);


    function deposit(uint8 inputAsset, uint256 amount) external;


    function getAmountsForLiquidity(uint128 liquidity)
        external
        view
        returns (uint256 amount0, uint256 amount1);


    function getBufferToken0Balance() external view returns (uint256 amount0);


    function getBufferToken1Balance() external view returns (uint256 amount1);


    function getBufferTokenBalance()
        external
        view
        returns (uint256 amount0, uint256 amount1);


    function getLiquidityForAmounts(uint256 amount0, uint256 amount1)
        external
        view
        returns (uint128 liquidity);


    function getPositionLiquidity() external view returns (uint128 liquidity);


    function getStakedTokenBalance()
        external
        view
        returns (uint256 amount0, uint256 amount1);


    function getTicks() external view returns (int24 tick0, int24 tick1);


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function initialize(
        string memory _symbol,
        int24 _tickLower,
        int24 _tickUpper,
        uint24 _poolFee,
        uint256 _tradeFee,
        address _token0,
        address _token1,
        address _stakedToken,
        address _terminal,
        address _uniswapPool,
        UniswapContracts memory contracts,
        StakingDetails memory stakingParams
    ) external;


    function manager() external view returns (address);


    function mintInitial(
        uint256 amount0,
        uint256 amount1,
        address sender
    ) external;


    function name() external view returns (string memory);


    function owner() external view returns (address);


    function pauseContract() external returns (bool);


    function paused() external view returns (bool);


    function poolFee() external view returns (uint24);


    function reinvest() external;


    function renounceOwnership() external;


    function stakedToken() external view returns (address);


    function symbol() external view returns (string memory);


    function token0() external view returns (address);


    function token0DecimalMultiplier() external view returns (uint256);


    function token0Decimals() external view returns (uint8);


    function token1() external view returns (address);


    function token1DecimalMultiplier() external view returns (uint256);


    function token1Decimals() external view returns (uint8);


    function tokenId() external view returns (uint256);


    function tradeFee() external view returns (uint256);


    function transferOwnership(address newOwner) external;


    function uniContracts()
        external
        view
        returns (
            address router,
            address quoter,
            address positionManager
        );


    function uniswapPool() external view returns (address);


    function unpauseContract() external returns (bool);


    function withdraw(uint256 amount) external;


    function withdrawAndClaimReward(uint256 amount) external;


    struct UniswapContracts {
        address router;
        address quoter;
        address positionManager;
    }

    struct StakingDetails {
        address[] rewardTokens;
        address rewardEscrow;
        bool rewardsAreEscrowed;
    }
}// BUSL-1.1
pragma solidity 0.7.6;


interface IStakedCLRToken is IERC20 {

    function mint(address _recipient, uint256 _amount) external returns (bool);


    function burnFrom(address _sender, uint256 _amount) external returns (bool);


    function initialize(
        string memory _name,
        string memory _symbol,
        address _clrPool,
        bool _transferable
    ) external;

}//MIT
pragma solidity 0.7.6;

interface IxTokenManager {

    function addManager(address manager, address fund) external;


    function removeManager(address manager, address fund) external;


    function isManager(address manager, address fund)
        external
        view
        returns (bool);


    function setRevenueController(address controller) external;


    function isRevenueController(address caller) external view returns (bool);

}// MIT
pragma solidity 0.7.6;

interface IProxyAdmin {

    function addProxyAdmin(address proxy, address admin) external;


    function changeProxyAdmin(address proxy, address newAdmin) external;


    function getProxyAdmin(address proxy) external view returns (address);


    function getProxyImplementation(address proxy)
        external
        view
        returns (address);


    function owner() external view returns (address);


    function renounceOwnership() external;


    function transferOwnership(address newOwner) external;


    function upgrade(address proxy, address implementation) external;

}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) payable {
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

pragma solidity ^0.7.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) payable UpgradeableProxy(_logic, _data) {
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
}//MIT
pragma solidity 0.7.6;

interface ICLRDeployer {

    function clrImplementation() external view returns (address);


    function deployCLRPool(address _proxyAdmin) external returns (address pool);


    function deploySCLRToken(address _proxyAdmin)
        external
        returns (address token);


    function owner() external view returns (address);


    function renounceOwnership() external;


    function sCLRTokenImplementation() external view returns (address);


    function setCLRImplementation(address _clrImplementation) external;


    function setsCLRTokenImplementation(address _sCLRTokenImplementation)
        external;


    function transferOwnership(address newOwner) external;

}// BUSL-1.1
pragma solidity 0.7.6;



contract CLRProxy is TransparentUpgradeableProxy {

    bytes32 private constant _DEPLOYER_SLOT =
        0x3d08d612cd86aed0e9677508733085e4cbe15d53bdc770ec5b581bb4e0a721ca;

    constructor(
        address _logic,
        address _proxyAdmin,
        address __clrDeployer
    ) TransparentUpgradeableProxy(_logic, _proxyAdmin, "") {
        assert(
            _DEPLOYER_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.clrDeployer")) - 1)
        );
        _setCLRDeployer(__clrDeployer);
    }

    function _clrDeployer()
        internal
        view
        virtual
        returns (address clrDeployer)
    {

        bytes32 slot = _DEPLOYER_SLOT;
        assembly {
            clrDeployer := sload(slot)
        }
    }

    function _setCLRDeployer(address clrDeployer) private {

        bytes32 slot = _DEPLOYER_SLOT;

        assembly {
            sstore(slot, clrDeployer)
        }
    }

    function upgradeTo(address _implementation) external override ifAdmin {

        require(
            ICLRDeployer(_clrDeployer()).clrImplementation() == _implementation,
            "Can only upgrade to latest CLR implementation"
        );
        _upgradeTo(_implementation);
    }

    function upgradeToAndCall(address _implementation, bytes calldata data)
        external
        payable
        override
        ifAdmin
    {

        require(
            ICLRDeployer(_clrDeployer()).clrImplementation() == _implementation,
            "Can only upgrade to latest CLR implementation"
        );
        _upgradeTo(_implementation);
        Address.functionDelegateCall(_implementation, data);
    }
}// BUSL-1.1
pragma solidity 0.7.6;



contract StakedCLRTokenProxy is TransparentUpgradeableProxy {

    bytes32 private constant _DEPLOYER_SLOT =
        0x3d08d612cd86aed0e9677508733085e4cbe15d53bdc770ec5b581bb4e0a721ca;

    constructor(
        address _logic,
        address _proxyAdmin,
        address __clrDeployer
    ) TransparentUpgradeableProxy(_logic, _proxyAdmin, "") {
        assert(
            _DEPLOYER_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.clrDeployer")) - 1)
        );
        _setCLRDeployer(__clrDeployer);
    }

    function _clrDeployer()
        internal
        view
        virtual
        returns (address clrDeployer)
    {

        bytes32 slot = _DEPLOYER_SLOT;
        assembly {
            clrDeployer := sload(slot)
        }
    }

    function _setCLRDeployer(address clrDeployer) private {

        bytes32 slot = _DEPLOYER_SLOT;

        assembly {
            sstore(slot, clrDeployer)
        }
    }

    function upgradeTo(address _implementation) external override ifAdmin {

        require(
            ICLRDeployer(_clrDeployer()).sCLRTokenImplementation() ==
                _implementation,
            "Can only upgrade to latest Staked CLR token implementation"
        );
        _upgradeTo(_implementation);
    }

    function upgradeToAndCall(address _implementation, bytes calldata data)
        external
        payable
        override
        ifAdmin
    {

        require(
            ICLRDeployer(_clrDeployer()).sCLRTokenImplementation() ==
                _implementation,
            "Can only upgrade to latest Staked CLR token implementation"
        );
        _upgradeTo(_implementation);
        Address.functionDelegateCall(_implementation, data);
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

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// BUSL-1.1
pragma solidity 0.7.6;


contract CLRDeployer is Ownable {

    address public clrImplementation;
    address public sCLRTokenImplementation;

    constructor(address _clrImplementation, address _sclrTokenImplementation) {
        clrImplementation = _clrImplementation;
        sCLRTokenImplementation = _sclrTokenImplementation;
        emit CLRImplementationSet(_clrImplementation);
        emit CLRTokenImplementationSet(_sclrTokenImplementation);
    }

    function deployCLRPool(address _proxyAdmin)
        external
        returns (address pool)
    {

        CLRProxy clrInstance = new CLRProxy(
            clrImplementation,
            _proxyAdmin,
            address(this)
        );
        return address(clrInstance);
    }

    function deploySCLRToken(address _proxyAdmin)
        external
        returns (address token)
    {

        StakedCLRTokenProxy clrTokenInstance = new StakedCLRTokenProxy(
            sCLRTokenImplementation,
            _proxyAdmin,
            address(this)
        );
        return address(clrTokenInstance);
    }

    function setCLRImplementation(address _clrImplementation)
        external
        onlyOwner
    {

        clrImplementation = _clrImplementation;
        emit CLRImplementationSet(_clrImplementation);
    }

    function setsCLRTokenImplementation(address _sCLRTokenImplementation)
        external
        onlyOwner
    {

        sCLRTokenImplementation = _sCLRTokenImplementation;
        emit CLRTokenImplementationSet(_sCLRTokenImplementation);
    }


    event CLRImplementationSet(address indexed clrImplementation);

    event CLRTokenImplementationSet(address indexed sCLRTokenImplementation);
}// BUSL-1.1
pragma solidity 0.7.6;






contract LMTerminal is Initializable, OwnableUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    IRewardEscrow public rewardEscrow; // Contract for token vesting after deployment
    ICLR[] public deployedCLRPools;

    uint256 public deploymentFee; // Flat CLR pool deployment fee in ETH
    uint256 public rewardFee; // Fee applied on initiating rewards program as a fee divisor (100 = 1%)
    uint256 public tradeFee; // Fee applied when collecting CLR fees as a fee divisor (100 = 1%)

    mapping(address => uint256) public customDeploymentFee; // Premium deployment fees for select partners
    mapping(address => bool) public customDeploymentFeeEnabled; // True if premium fee is enabled

    CLRDeployer public clrDeployer; // Deployer contract for CLR pools and Staked CLR Tokens
    IxTokenManager public xTokenManager; // xTokenManager contract
    address public proxyAdmin; // Proxy Admin of CLR instances

    IUniswapV3Factory public uniswapFactory; // Uniswap V3 Factory Contract
    INonfungiblePositionManager public positionManager; // Uniswap V3 Position Manager contract
    ICLR.UniswapContracts public uniContracts; // Uniswap V3 Contracts

    mapping(address => bool) private isCLRPool; // True if address is CLR pool


    struct PositionTicks {
        int24 lowerTick;
        int24 upperTick;
    }

    struct RewardsProgram {
        address[] rewardTokens;
        uint256 vestingPeriod;
    }

    struct PoolDetails {
        uint24 fee;
        address token0;
        address token1;
        uint256 amount0;
        uint256 amount1;
    }


    event DeployedUniV3Pool(
        address indexed pool,
        address indexed token0,
        address indexed token1,
        uint24 fee
    );
    event DeployedIncentivizedPool(
        address indexed clrInstance,
        address indexed token0,
        address indexed token1,
        uint24 fee,
        int24 lowerTick,
        int24 upperTick
    );
    event InitiatedRewardsProgram(
        address indexed clrInstance,
        address[] rewardTokens,
        uint256[] totalRewardAmounts,
        uint256 rewardsDuration
    );
    event TokenFeeWithdraw(address indexed token, uint256 amount);
    event EthFeeWithdraw(uint256 amount);


    function initialize(
        address _xTokenManager,
        address _rewardEscrow,
        address _proxyAdmin,
        address _clrDeployer,
        address _uniswapFactory,
        ICLR.UniswapContracts memory _uniContracts,
        uint256 _deploymentFee,
        uint256 _rewardFee,
        uint256 _tradeFee
    ) external initializer {

        __Ownable_init();
        xTokenManager = IxTokenManager(_xTokenManager);
        rewardEscrow = IRewardEscrow(_rewardEscrow);
        proxyAdmin = _proxyAdmin;
        clrDeployer = CLRDeployer(_clrDeployer);
        positionManager = INonfungiblePositionManager(
            _uniContracts.positionManager
        );
        uniswapFactory = IUniswapV3Factory(_uniswapFactory);
        uniContracts = _uniContracts;
        deploymentFee = _deploymentFee;
        rewardFee = _rewardFee;
        tradeFee = _tradeFee;
    }

    function deployUniswapPool(
        address token0,
        address token1,
        uint24 fee,
        uint160 initPrice
    ) external returns (address pool) {

        if (token0 > token1) {
            (token0, token1) = (token1, token0);
        }
        pool = positionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            fee,
            initPrice
        );
        emit DeployedUniV3Pool(pool, token0, token1, fee);
    }

    function deployIncentivizedPool(
        string memory symbol,
        PositionTicks memory ticks,
        RewardsProgram memory rewardsProgram,
        PoolDetails memory pool
    ) external payable {

        uint256 feeOwed = customDeploymentFeeEnabled[msg.sender]
            ? customDeploymentFee[msg.sender]
            : deploymentFee;
        require(
            msg.value == feeOwed,
            "Need to send ETH for CLR pool deployment"
        );
        ICLR clrPool = ICLR(clrDeployer.deployCLRPool(proxyAdmin));
        IStakedCLRToken stakedToken = IStakedCLRToken(
            clrDeployer.deploySCLRToken(proxyAdmin)
        );
        stakedToken.initialize(
            "StakedCLRToken",
            symbol,
            address(clrPool),
            false
        );

        if (pool.token0 > pool.token1) {
            (pool.token0, pool.token1) = (pool.token1, pool.token0);
            (pool.amount0, pool.amount1) = (pool.amount1, pool.amount0);
        }
        bool rewardsAreEscrowed = rewardsProgram.vestingPeriod > 0
            ? true
            : false;
        address poolAddress = getPool(pool.token0, pool.token1, pool.fee);
        ICLR.StakingDetails memory stakingParams = ICLR.StakingDetails({
            rewardTokens: rewardsProgram.rewardTokens,
            rewardEscrow: address(rewardEscrow),
            rewardsAreEscrowed: rewardsAreEscrowed
        });

        clrPool.initialize(
            symbol,
            ticks.lowerTick,
            ticks.upperTick,
            pool.fee,
            tradeFee,
            pool.token0,
            pool.token1,
            address(stakedToken),
            address(this),
            poolAddress,
            uniContracts,
            stakingParams
        );

        {
            (uint256 actualAmount0, uint256 actualAmount1) = clrPool
                .calculatePoolMintedAmounts(pool.amount0, pool.amount1);

            IERC20(pool.token0).safeApprove(address(clrPool), actualAmount0);
            IERC20(pool.token1).safeApprove(address(clrPool), actualAmount1);

            IERC20(pool.token0).safeTransferFrom(
                msg.sender,
                address(this),
                actualAmount0
            );
            IERC20(pool.token1).safeTransferFrom(
                msg.sender,
                address(this),
                actualAmount1
            );

            clrPool.mintInitial(actualAmount0, actualAmount1, msg.sender);
        }

        if (rewardsAreEscrowed) {
            rewardEscrow.setCLRPoolVestingPeriod(
                address(clrPool),
                rewardsProgram.vestingPeriod
            );
        }

        clrPool.transferOwnership(msg.sender);

        IProxyAdmin(proxyAdmin).addProxyAdmin(address(clrPool), msg.sender);
        IProxyAdmin(proxyAdmin).addProxyAdmin(address(stakedToken), msg.sender);

        deployedCLRPools.push(clrPool);
        isCLRPool[address(clrPool)] = true;
        emit DeployedIncentivizedPool(
            address(clrPool),
            pool.token0,
            pool.token1,
            pool.fee,
            ticks.lowerTick,
            ticks.upperTick
        );
    }

    function initiateRewardsProgram(
        ICLR clrPool,
        uint256[] memory totalRewardAmounts,
        uint256 rewardsDuration
    ) external {

        require(isCLRPool[address(clrPool)], "Not CLR pool");
        require(
            clrPool.periodFinish() == 0,
            "Reward program has been initiated"
        );
        if (clrPool.rewardsAreEscrowed()) {
            rewardEscrow.addRewardsContract(address(clrPool));
        }
        clrPool.setRewardsDuration(rewardsDuration);
        _initiateRewardsProgram(clrPool, totalRewardAmounts);
    }

    function initiateNewRewardsProgram(
        ICLR clrPool,
        uint256[] memory totalRewardAmounts,
        uint256 rewardsDuration
    ) external {

        require(
            clrPool.periodFinish() != 0,
            "First program must be initialized using initiateRewardsProgram"
        );
        require(
            block.timestamp > clrPool.periodFinish(),
            "Previous program must finish before initializing a new one"
        );
        clrPool.setRewardsDuration(rewardsDuration);
        _initiateRewardsProgram(clrPool, totalRewardAmounts);
    }

    function _initiateRewardsProgram(
        ICLR clrPool,
        uint256[] memory totalRewardAmounts
    ) private {

        address[] memory rewardTokens = clrPool.getRewardTokens();
        require(
            totalRewardAmounts.length == rewardTokens.length,
            "Total reward amounts count should be the same as reward tokens count"
        );
        address owner = clrPool.owner();
        address manager = clrPool.manager();
        require(
            msg.sender == owner || msg.sender == manager,
            "Only owner or manager can initiate the rewards program"
        );
        for (uint256 i = 0; i < rewardTokens.length; ++i) {
            address rewardToken = rewardTokens[i];
            uint256 rewardAmountFee = totalRewardAmounts[i].div(rewardFee);
            uint256 rewardAmount = totalRewardAmounts[i];
            IERC20(rewardToken).safeTransferFrom(
                msg.sender,
                address(this),
                rewardAmountFee
            );
            IERC20(rewardToken).safeTransferFrom(
                msg.sender,
                address(clrPool),
                rewardAmount
            );
            clrPool.initializeReward(rewardAmount, rewardToken);
        }
        emit InitiatedRewardsProgram(
            address(clrPool),
            rewardTokens,
            totalRewardAmounts,
            clrPool.rewardsDuration()
        );
    }


    function getPool(
        address token0,
        address token1,
        uint24 fee
    ) public view returns (address pool) {

        return uniswapFactory.getPool(token0, token1, fee);
    }

    function enableCustomDeploymentFee(address deployer, uint256 feeAmount)
        public
        onlyOwner
    {

        require(
            feeAmount < deploymentFee,
            "Custom fee should be less than flat deployment fee"
        );
        customDeploymentFeeEnabled[deployer] = true;
        customDeploymentFee[deployer] = feeAmount;
    }

    function disableCustomDeploymentFee(address deployer) public onlyOwner {

        customDeploymentFeeEnabled[deployer] = false;
    }

    function setCLRDeployer(address newDeployer) public onlyOwner {

        clrDeployer = CLRDeployer(newDeployer);
    }

    function withdrawFees(IERC20 token) external onlyRevenueController {

        uint256 fees = token.balanceOf(address(this));
        if (fees > 0) {
            token.safeTransfer(msg.sender, fees);
            emit TokenFeeWithdraw(address(token), fees);
        }

        if (address(this).balance > 0) {
            bool sent = transferETH(address(this).balance, msg.sender);
            if (sent) {
                emit EthFeeWithdraw(address(this).balance);
            }
        }
    }

    function transferETH(uint256 amount, address payable to)
        private
        returns (bool sent)
    {

        (sent, ) = to.call{value: amount}("");
    }

    receive() external payable {}


    modifier onlyRevenueController() {

        require(
            xTokenManager.isRevenueController(msg.sender),
            "Callable only by Revenue Controller"
        );
        _;
    }
}