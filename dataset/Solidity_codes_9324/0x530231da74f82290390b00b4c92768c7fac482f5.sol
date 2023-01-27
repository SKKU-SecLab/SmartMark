pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library SafeCast {

    function toUint160(uint256 y) internal pure returns (uint160 z) {

        require((z = uint160(y)) == y);
    }

    function toInt128(int256 y) internal pure returns (int128 z) {

        require((z = int128(y)) == y);
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {

        require(y < 2**255);
        z = int256(y);
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0 <0.8.0;

library BytesLib {

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    tempBytes := mload(0x40)

                    let lengthmod := and(_length, 31)

                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                default {
                    tempBytes := mload(0x40)
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {

        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library Path {

    using BytesLib for bytes;

    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant FEE_SIZE = 3;

    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    function hasMultiplePools(bytes memory path) internal pure returns (bool) {

        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {

        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {

        return path.slice(0, POP_OFFSET);
    }

    function skipToken(bytes memory path) internal pure returns (bytes memory) {

        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

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
}// MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

struct DecreaseWithV3FlashswapMultihopConnectorParams {
    uint256 withdrawAmount; // Amount that will be withdrawn
    uint256 maxSupplyTokenRepayAmount; // Max amount of supply that will be used to repay the debt (slippage is enforced here)
    uint256 borrowTokenRepayAmount; // Amount of debt that will be repaid
    address platform; // Lending platform
    address supplyToken; // Token to be supplied
    address borrowToken; // Token to be borrowed
    bytes path;
}

struct SwapCallbackData {
    uint256 withdrawAmount;
    uint256 maxSupplyTokenRepayAmount;
    uint256 borrowTokenRepayAmount;
    uint256 positionDebt;
    address platform;
    address lender;
    bytes path;
}

struct FlashCallbackData {
    uint256 withdrawAmount;
    uint256 repayAmount;
    uint256 positionDebt;
    address platform;
    address lender;
    bytes path;
}

interface IDecreaseWithV3FlashswapMultihopConnector {

    function decreasePositionWithV3FlashswapMultihop(DecreaseWithV3FlashswapMultihopConnectorParams calldata params)
        external;

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

pragma solidity 0.6.12;

struct AssetMetadata {
    address assetAddress;
    string assetSymbol;
    uint8 assetDecimals;
    uint256 referencePrice;
    uint256 totalLiquidity;
    uint256 totalSupply;
    uint256 totalBorrow;
    uint256 totalReserves;
    uint256 supplyAPR;
    uint256 borrowAPR;
    address rewardTokenAddress;
    string rewardTokenSymbol;
    uint8 rewardTokenDecimals;
    uint256 estimatedSupplyRewardsPerYear;
    uint256 estimatedBorrowRewardsPerYear;
    uint256 collateralFactor;
    uint256 liquidationFactor;
    bool canSupply;
    bool canBorrow;
}

interface ILendingPlatform {

    function getAssetMetadata(address platform, address asset) external returns (AssetMetadata memory assetMetadata);


    function getCollateralUsageFactor(address platform) external returns (uint256 collateralUsageFactor);


    function getCollateralFactorForAsset(address platform, address asset) external returns (uint256);


    function getReferencePrice(address platform, address token) external returns (uint256 referencePrice);


    function getBorrowBalance(address platform, address token) external returns (uint256 borrowBalance);


    function getSupplyBalance(address platform, address token) external returns (uint256 supplyBalance);


    function claimRewards(address platform) external returns (address rewardsToken, uint256 rewardsAmount);


    function enterMarkets(address platform, address[] memory markets) external;


    function supply(
        address platform,
        address token,
        uint256 amount
    ) external;


    function borrow(
        address platform,
        address token,
        uint256 amount
    ) external;


    function redeemSupply(
        address platform,
        address token,
        uint256 amount
    ) external;


    function repayBorrow(
        address platform,
        address token,
        uint256 amount
    ) external;

}// MIT

pragma solidity 0.6.12;

interface ILendingPlatformAdapterProvider {

    function getPlatformAdapter(address platform) external view returns (address platformAdapter);

}// MIT

pragma solidity 0.6.12;

contract FoldingAccountStorage {

    bytes32 constant ACCOUNT_STORAGE_POSITION = keccak256('folding.account.storage');

    struct AccountStore {
        address entryCaller;
        address callbackTarget;
        bytes4 expectedCallbackSig;
        address foldingRegistry;
        address nft;
        address owner;
    }

    modifier onlyAccountOwner() {

        AccountStore storage s = aStore();
        require(s.entryCaller == s.owner, 'FA2');
        _;
    }

    modifier onlyNFTContract() {

        AccountStore storage s = aStore();
        require(s.entryCaller == s.nft, 'FA3');
        _;
    }

    modifier onlyAccountOwnerOrRegistry() {

        AccountStore storage s = aStore();
        require(s.entryCaller == s.owner || s.entryCaller == s.foldingRegistry, 'FA4');
        _;
    }

    function aStore() internal pure returns (AccountStore storage s) {

        bytes32 position = ACCOUNT_STORAGE_POSITION;
        assembly {
            s_slot := position
        }
    }

    function accountOwner() internal view returns (address) {

        return aStore().owner;
    }
}// MIT

pragma solidity 0.6.12;



contract LendingDispatcher is FoldingAccountStorage {

    using Address for address;

    function getLender(address platform) internal view returns (address) {

        return ILendingPlatformAdapterProvider(aStore().foldingRegistry).getPlatformAdapter(platform);
    }

    function getCollateralUsageFactor(address adapter, address platform)
        internal
        returns (uint256 collateralUsageFactor)
    {

        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getCollateralUsageFactor.selector, platform)
        );
        return abi.decode(returnData, (uint256));
    }

    function getCollateralFactorForAsset(
        address adapter,
        address platform,
        address asset
    ) internal returns (uint256) {

        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getCollateralFactorForAsset.selector, platform, asset)
        );
        return abi.decode(returnData, (uint256));
    }

    function getReferencePrice(
        address adapter,
        address platform,
        address asset
    ) internal returns (uint256 referencePrice) {

        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getReferencePrice.selector, platform, asset)
        );
        return abi.decode(returnData, (uint256));
    }

    function getBorrowBalance(
        address adapter,
        address platform,
        address token
    ) internal returns (uint256 borrowBalance) {

        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getBorrowBalance.selector, platform, token)
        );
        return abi.decode(returnData, (uint256));
    }

    function getSupplyBalance(
        address adapter,
        address platform,
        address token
    ) internal returns (uint256 supplyBalance) {

        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getSupplyBalance.selector, platform, token)
        );
        return abi.decode(returnData, (uint256));
    }

    function enterMarkets(
        address adapter,
        address platform,
        address[] memory markets
    ) internal {

        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatform.enterMarkets.selector, platform, markets));
    }

    function claimRewards(address adapter, address platform)
        internal
        returns (address rewardsToken, uint256 rewardsAmount)
    {

        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.claimRewards.selector, platform)
        );
        return abi.decode(returnData, (address, uint256));
    }

    function supply(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {

        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatform.supply.selector, platform, token, amount));
    }

    function borrow(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {

        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatform.borrow.selector, platform, token, amount));
    }

    function redeemSupply(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {

        adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.redeemSupply.selector, platform, token, amount)
        );
    }

    function repayBorrow(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {

        adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.repayBorrow.selector, platform, token, amount)
        );
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

contract SimplePositionStorage {

    bytes32 private constant SIMPLE_POSITION_STORAGE_LOCATION = keccak256('folding.simplePosition.storage');

    struct SimplePositionStore {
        address platform;
        address supplyToken;
        address borrowToken;
        uint256 principalValue;
    }

    function simplePositionStore() internal pure returns (SimplePositionStore storage s) {

        bytes32 position = SIMPLE_POSITION_STORAGE_LOCATION;
        assembly {
            s_slot := position
        }
    }

    function isSimplePosition() internal view returns (bool) {

        return simplePositionStore().platform != address(0);
    }

    function requireSimplePositionDetails(
        address platform,
        address supplyToken,
        address borrowToken
    ) internal view {

        require(simplePositionStore().platform == platform, 'SP2');
        require(simplePositionStore().supplyToken == supplyToken, 'SP3');
        require(simplePositionStore().borrowToken == borrowToken, 'SP4');
    }
}// MIT

pragma solidity 0.6.12;



contract FundsManager is FoldingAccountStorage, SimplePositionStorage {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 internal constant MANTISSA = 1e18;

    uint256 public immutable principal;
    uint256 public immutable profit;
    address public immutable holder;

    constructor(
        uint256 _principal,
        uint256 _profit,
        address _holder
    ) public {
        require(_principal < MANTISSA, 'ICP1');
        require(_profit < MANTISSA, 'ICP1');
        require(_holder != address(0), 'ICP0');
        principal = _principal;
        profit = _profit;
        holder = _holder;
    }

    function addPrincipal(uint256 amount) internal {

        IERC20(simplePositionStore().supplyToken).safeTransferFrom(accountOwner(), address(this), amount);
        simplePositionStore().principalValue += amount;
    }

    function withdraw(uint256 amount, uint256 positionValue) internal {

        SimplePositionStore memory sp = simplePositionStore();

        uint256 principalFactor = sp.principalValue.mul(MANTISSA).div(positionValue);

        uint256 principalShare = amount;
        uint256 profitShare;

        if (principalFactor < MANTISSA) {
            principalShare = amount.mul(principalFactor) / MANTISSA;
            profitShare = amount.sub(principalShare);
        }

        uint256 subsidy = principalShare.mul(principal).add(profitShare.mul(profit)) / MANTISSA;

        if (sp.principalValue > principalShare) {
            simplePositionStore().principalValue = sp.principalValue - principalShare;
        } else {
            simplePositionStore().principalValue = 0;
        }

        IERC20(sp.supplyToken).safeTransfer(holder, subsidy);
        IERC20(sp.supplyToken).safeTransfer(accountOwner(), amount.sub(subsidy));
    }
}// MIT

pragma solidity 0.6.12;

contract FlashswapStorage {

    bytes32 private constant FLASHSWAP_STORAGE_LOCATION = keccak256('folding.flashswap.storage');

    struct FlashswapStore {
        address expectedCaller;
    }

    function flashswapStore() internal pure returns (FlashswapStore storage s) {

        bytes32 position = FLASHSWAP_STORAGE_LOCATION;
        assembly {
            s_slot := position
        }
    }
}// MIT

pragma solidity 0.6.12;



contract DecreaseWithV3FlashswapMultihopConnector is
    LendingDispatcher,
    FundsManager,
    FlashswapStorage,
    IDecreaseWithV3FlashswapMultihopConnector
{

    using Path for bytes;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeCast for uint256;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
    bytes4 internal constant UNISWAPV3_SWAP_CALLBACK_SIG =
        bytes4(keccak256('uniswapV3SwapCallback(int256,int256,bytes)'));
    bytes4 internal constant UNISWAPV3_FLASH_CALLBACK_SIG =
        bytes4(keccak256('uniswapV3FlashCallback(uint256,uint256,bytes)'));

    uint256 private immutable rewardsFactor;
    address private immutable SELF_ADDRESS;
    address private immutable factory;

    constructor(
        uint256 _principal,
        uint256 _profit,
        uint256 _rewardsFactor,
        address _holder,
        address _factory
    ) public FundsManager(_principal, _profit, _holder) {
        SELF_ADDRESS = address(this);
        rewardsFactor = _rewardsFactor;
        factory = _factory;
    }

    function decreasePositionWithV3FlashswapMultihop(DecreaseWithV3FlashswapMultihopConnectorParams calldata params)
        external
        override
        onlyAccountOwner
    {

        _verifySetup(params.platform, params.supplyToken, params.borrowToken);

        address lender = getLender(params.platform); // Get it once, pass it around and use when needed

        uint256 positionDebt = getBorrowBalance(lender, params.platform, params.borrowToken); // Same as above

        if (positionDebt == 0) {
            require(params.withdrawAmount == uint256(-1));
            uint256 withdrawableAmount = getSupplyBalance(lender, params.platform, params.supplyToken);
            redeemSupply(lender, params.platform, params.supplyToken, withdrawableAmount);
            withdraw(withdrawableAmount, withdrawableAmount);
            claimRewards();
            return;
        }

        uint256 debtToRepay = params.borrowTokenRepayAmount > positionDebt
            ? positionDebt
            : params.borrowTokenRepayAmount;

        if (params.supplyToken != params.borrowToken) {
            exactOutputInternal(
                debtToRepay,
                SwapCallbackData(
                    params.withdrawAmount,
                    params.maxSupplyTokenRepayAmount,
                    params.borrowTokenRepayAmount,
                    positionDebt,
                    params.platform,
                    lender,
                    params.path
                )
            );
        } else {
            requestFlashloan(
                params.supplyToken,
                FlashCallbackData(
                    params.withdrawAmount,
                    debtToRepay,
                    positionDebt,
                    params.platform,
                    lender,
                    params.path
                )
            );
        }

        if (params.withdrawAmount == uint256(-1)) {
            claimRewards();
        }
    }


    function exactOutputInternal(uint256 amountOut, SwapCallbackData memory data) private {

        (address tokenOut, address tokenIn, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;
        address pool = getPool(tokenIn, tokenOut, fee);

        _setExpectedCallback(pool, UNISWAPV3_SWAP_CALLBACK_SIG);

        (int256 amount0Delta, int256 amount1Delta) = IUniswapV3PoolActions(pool).swap(
            address(this),
            zeroForOne,
            -amountOut.toInt256(),
            zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
            abi.encode(data)
        );

        uint256 amountOutReceived;
        (, amountOutReceived) = zeroForOne
            ? (uint256(amount0Delta), uint256(-amount1Delta))
            : (uint256(amount1Delta), uint256(-amount0Delta));

        require(amountOutReceived == amountOut, 'DWV3FMC2');
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external {

        _verifyCallbackAndClear();

        require(amount0Delta > 0 || amount1Delta > 0, 'DWV3FMC3'); // swaps entirely within 0-liquidity regions are not supported
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address receivedToken, address owedToken, ) = data.path.decodeFirstPool();

        if (receivedToken == simplePositionStore().borrowToken) {
            repayBorrow(
                data.lender,
                data.platform,
                receivedToken,
                uint256(amount0Delta < 0 ? -amount0Delta : -amount1Delta)
            );
        }

        uint256 amountToPay = uint256(amount0Delta > 0 ? amount0Delta : amount1Delta);

        if (data.path.hasMultiplePools()) {
            data.path = data.path.skipToken();
            exactOutputInternal(amountToPay, data);
        } else {
            require(owedToken == simplePositionStore().supplyToken, 'DWV3FMC4');
            require(amountToPay <= data.maxSupplyTokenRepayAmount, 'DWV3FMC5');

            uint256 deposit = getSupplyBalance(data.lender, data.platform, owedToken);

            uint256 withdrawableAmount = deposit.sub(amountToPay);
            uint256 amountToWithdraw = withdrawableAmount < data.withdrawAmount
                ? withdrawableAmount
                : data.withdrawAmount;

            redeemSupply(data.lender, data.platform, owedToken, amountToWithdraw + amountToPay);

            if (amountToWithdraw > 0) {
                uint256 positionValue = deposit.sub(
                    data
                        .positionDebt
                        .mul(getReferencePrice(data.lender, data.platform, simplePositionStore().borrowToken))
                        .div(getReferencePrice(data.lender, data.platform, owedToken))
                );
                withdraw(amountToWithdraw, positionValue);
            }
        }
        IERC20(owedToken).safeTransfer(msg.sender, amountToPay);
    }


    function requestFlashloan(address token, FlashCallbackData memory data) internal {

        (address tokenA, address tokenB, uint24 fee) = data.path.decodeFirstPool();
        address pool = getPool(tokenA, tokenB, fee);
        _setExpectedCallback(pool, UNISWAPV3_FLASH_CALLBACK_SIG);

        bool flashToken0;

        if (token == tokenA) {
            flashToken0 = tokenA < tokenB;
        } else if (token == tokenB) {
            flashToken0 = tokenB < tokenA;
        } else {
            revert('DWV3FMC7');
        }

        IUniswapV3PoolActions(pool).flash(
            address(this),
            flashToken0 ? data.repayAmount : 0,
            flashToken0 ? 0 : data.repayAmount,
            abi.encode(data)
        );
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata _data
    ) external {

        _verifyCallbackAndClear();
        FlashCallbackData memory data = abi.decode(_data, (FlashCallbackData));

        address supplyToken = simplePositionStore().supplyToken;
        uint256 owedAmount = fee0 > 0 ? data.repayAmount + fee0 : data.repayAmount + fee1;

        repayBorrow(data.lender, data.platform, supplyToken, data.repayAmount);

        uint256 deposit = getSupplyBalance(data.lender, data.platform, supplyToken);

        uint256 withdrawableAmount = deposit.sub(owedAmount);
        uint256 amountToWithdraw = withdrawableAmount < data.withdrawAmount ? withdrawableAmount : data.withdrawAmount;

        redeemSupply(data.lender, data.platform, supplyToken, amountToWithdraw + owedAmount);

        if (amountToWithdraw > 0) {
            withdraw(amountToWithdraw, simplePositionStore().principalValue);
        }

        IERC20(supplyToken).safeTransfer(msg.sender, owedAmount);
    }

    function _verifySetup(
        address platform,
        address supplyToken,
        address borrowToken
    ) internal view {

        requireSimplePositionDetails(platform, supplyToken, borrowToken);
    }

    function _setExpectedCallback(address pool, bytes4 expectedCallbackSig) internal {

        aStore().callbackTarget = SELF_ADDRESS;
        aStore().expectedCallbackSig = expectedCallbackSig;
        flashswapStore().expectedCaller = pool;
    }

    function _verifyCallbackAndClear() internal {

        require(msg.sender == flashswapStore().expectedCaller, 'DWV3FMC6');
        delete flashswapStore().expectedCaller;
        delete aStore().callbackTarget;
        delete aStore().expectedCallbackSig;
    }

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) private view returns (address) {

        return PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    function claimRewards() private {

        require(isSimplePosition(), 'SP1');
        address lender = getLender(simplePositionStore().platform);

        (address rewardsToken, uint256 rewardsAmount) = claimRewards(lender, simplePositionStore().platform);
        if (rewardsToken != address(0)) {
            uint256 subsidy = rewardsAmount.mul(rewardsFactor) / MANTISSA;
            if (subsidy > 0) {
                IERC20(rewardsToken).safeTransfer(holder, subsidy);
            }
            if (rewardsAmount > subsidy) {
                IERC20(rewardsToken).safeTransfer(accountOwner(), rewardsAmount - subsidy);
            }
        }
    }
}