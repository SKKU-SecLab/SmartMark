pragma solidity 0.8.0;

interface IHandler {

    function withdraw(
        bytes32 id,
        uint256 tokenIdOrAmount,
        address contractAddress
    )
    external
    returns (
        address[] memory token,
        uint256 premium,
        uint128[] memory tokenFees,
        bytes memory data
    );


    function update(
        bytes32 id,
        uint256 tokenValue,
        address contractAddress,
        bytes calldata data
    ) external;

}// MIT
pragma solidity 0.8.0;

library Math {

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// MIT
pragma solidity 0.8.0;

library SafeUint128 {

    function toUint128(uint256 y) internal pure returns (uint128 z) {

        require((z = uint128(y)) == y);
    }
}// MIT

pragma solidity 0.8.0;
interface IAccessController {

    function updatePremiumOfPool(address pool, uint256 newAquaPremium) external;


    function addPools(
        address[] calldata tokenA,
        address[] calldata tokenB,
        uint256[] calldata aquaPremium
    ) external;


    function updatePoolStatus(
        address pool
    ) external;


    function updatePrimary(
        address newAddress
    ) external;


    function whitelistedPools(
        address pool
    )
    external
    returns (
        uint256,
        bool,
        bytes calldata data
    );

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}// MIT
pragma solidity 0.8.0;


contract AccessController is IAccessController, Ownable {

    address public constant SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address public AQUA_PRIMARY;
    address public lpFeeTaker;

    struct Pool {
        uint256 aquaPremium;
        bool status;
        bytes data;
    }

    mapping(address => Pool) public override whitelistedPools;

    modifier onlyPrimaryContract() {

        require(msg.sender == AQUA_PRIMARY, "Sushiswap Handler :: NOT AQUA PRIMARY");
        _;
    }

    event OwnerUpdated(address oldOwner, address newOwner);
    event PoolAdded(address pool, uint256 aquaPremium, bool status);
    event PoolPremiumUpdated(address pool, uint256 oldAquaPremium, uint256 newAquaPremium);
    event AquaPrimaryUpdated(address oldAddress, address newAddress);
    event PoolStatusUpdated(address pool, bool oldStatus, bool newStatus);

    constructor(address primary) {
        AQUA_PRIMARY = primary;
    }

    function addPools(
        address[] memory tokenA,
        address[] memory tokenB,
        uint256[] memory aquaPremium
    ) external override onlyOwner {

        require(
            (tokenA.length == tokenB.length) && (tokenB.length == aquaPremium.length),
            "Sushiswap Handler :: Invalid Args."
        );
        for (uint8 i = 0; i < tokenA.length; i++) {
            address pool = IUniswapV2Factory(SUSHI_FACTORY).getPair(tokenA[i], tokenB[i]);
            require(pool != address(0), "Sushiswap Handler :: Pool does not exist");
            whitelistedPools[pool] = Pool(aquaPremium[i], true, abi.encode(0));
            emit PoolAdded(pool, aquaPremium[i], true);
        }
    }

    function updateIndexFundAddress(address newAddr) external onlyOwner {

        lpFeeTaker = newAddr;
    }

    function updatePremiumOfPool(address pool, uint256 newAquaPremium) external override onlyOwner {

        emit PoolPremiumUpdated(pool, whitelistedPools[pool].aquaPremium, newAquaPremium);
        whitelistedPools[pool].aquaPremium = newAquaPremium;
    }

    function updatePoolStatus(address pool) external override onlyOwner {

        bool status = whitelistedPools[pool].status;
        emit PoolStatusUpdated(pool, status, !status);
        whitelistedPools[pool].status = !status;
    }

    function updatePrimary(address newAddress) external override onlyOwner {

        emit AquaPrimaryUpdated(AQUA_PRIMARY, newAddress);
        AQUA_PRIMARY = newAddress;
    }
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

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.0;


contract SushiswapHandler is AccessController, IHandler {

    using SafeERC20 for IERC20;

    struct Stake {
        bytes32 id;
        address staker;
        uint256 rootK;
        uint256 lpAmount;
        address poolAddress;
    }

    mapping(bytes32 => Stake) public stakes;

    event RootKUpdated(bytes32 stakeId, uint256 rookK);
    event Update(bytes32 id, uint256 depositTime, address handler, address pool);
    event Withdraw(bytes32 id, uint256 aquaPremium, uint256 tokenDifference, address pool);

    constructor(address primary, address index)
    AccessController( primary) {
        lpFeeTaker = index;
    }

    function update(
        bytes32 stakeId,
        uint256 lpAmount,
        address lpToken,
        bytes calldata data
    )
        external
        override
        onlyPrimaryContract
    {

        (address pool, address staker) = abi.decode(abi.encodePacked(data), (address, address));

        require(whitelistedPools[pool].status == true, "Sushiswap Handler :: POOL NOT WHITELISTED.");
        require(stakes[stakeId].rootK == 0, "Sushiswap Handler :: STAKE EXIST");
        require(lpToken == pool, "UNISWAP HANDLER :: POOL MISMATCH");

        (uint256 rootK, , ) = calculateTokenAndRootK(lpAmount, lpToken);
        Stake storage s = stakes[stakeId];
        s.rootK = rootK;
        s.staker = staker;
        s.poolAddress = lpToken;
        s.lpAmount = lpAmount;

        emit RootKUpdated(stakeId, rootK);
        emit Update(stakeId, block.timestamp, address(this), pool);
    }

    function withdraw(
        bytes32 id,
        uint256 tokenIdOrAmount,
        address contractAddress
    )
        external
        override
        onlyPrimaryContract
        returns (
            address[] memory token,
            uint256 premium,
            uint128[] memory tokenFees,
            bytes memory data
        )
    {

        uint256[] memory feesArr = new uint256[](2);
        token = new address[](2);
        tokenFees = new uint128[](2);

        (feesArr[0], feesArr[1], token[0], token[1]) = calculateFee(
            id,
            stakes[id].lpAmount,
            tokenIdOrAmount,
            contractAddress
        );

        premium = whitelistedPools[stakes[id].poolAddress].aquaPremium;

        transferLPTokens(tokenIdOrAmount, feesArr[0], feesArr[1], contractAddress, stakes[id].staker);

        tokenFees[0] = SafeUint128.toUint128(feesArr[0]);
        tokenFees[1] = SafeUint128.toUint128(feesArr[1]);

        if (stakes[id].lpAmount != tokenIdOrAmount) {
            stakes[id].lpAmount -= tokenIdOrAmount;
        } else {
            delete stakes[id];
        }

        return (token, premium, tokenFees, abi.encodePacked(stakes[id].poolAddress));
    }

    function transferLPTokens(
        uint256 amount,
        uint256 tokenFeesA,
        uint256 tokenFeesB,
        address lpToken,
        address staker
    ) internal onlyPrimaryContract {

        uint256 lpTokenFee = calculateLPToken(tokenFeesA, tokenFeesB, lpToken);
        IERC20(lpToken).safeTransfer(staker, amount - lpTokenFee);
        IERC20(lpToken).safeTransfer(lpFeeTaker, lpTokenFee);
    }

    function calculateLPToken(
        uint256 tokenFeesA,
        uint256 tokenFeesB,
        address lpToken
    ) public view returns (uint256 lpAmount) {

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(lpToken).getReserves();
        uint256 lpAmountA = (tokenFeesA * IUniswapV2Pair(lpToken).totalSupply()) / reserve0;
        uint256 lpAmountB = (tokenFeesB * IUniswapV2Pair(lpToken).totalSupply()) / reserve1;
        lpAmount = lpAmountA + lpAmountB;
    }

    function calculateFee(
        bytes32 id,
        uint256 lpAmount,
        uint256 lpUnstakeAmount,
        address lpToken
    )
        internal
        onlyPrimaryContract
        returns (
            uint256 tokenFeesA,
            uint256 tokenFeesB,
            address tokenA,
            address tokenB
        )
    {

        Stake storage s = stakes[id];
        uint256[] memory tokenAmountArr = new uint256[](3);

        uint256 lpPercentage = (lpUnstakeAmount * 10000) / lpAmount;
        (tokenAmountArr[0], tokenAmountArr[1], tokenAmountArr[2]) = calculateTokenAndRootK(lpAmount, lpToken);

        uint256 kDiff;
        uint256 newRootK;
        uint256 kOffset;

        if (tokenAmountArr[0] < s.rootK) {
            kDiff = (s.rootK - tokenAmountArr[0]);
            newRootK = s.rootK;
        } else {
            kDiff = tokenAmountArr[0] - s.rootK;
            newRootK = tokenAmountArr[0];
        }

        kOffset = kDiff;

        (tokenA, tokenB) = getPairTokens(lpToken);

        kDiff = (kDiff * lpPercentage) / 10000;

        tokenFeesA = (tokenAmountArr[1] * kDiff ) / s.lpAmount;
        tokenFeesB = (tokenAmountArr[2] * kDiff ) / s.lpAmount;

        (lpUnstakeAmount,,) = calculateTokenAndRootK(s.lpAmount- lpUnstakeAmount,lpToken);
        s.rootK = lpUnstakeAmount + kDiff - kOffset;

        emit RootKUpdated(id, s.rootK);
    }

    function calculateTokenAndRootK(uint256 lpAmount, address lpToken)
        public
        view
        returns (
            uint256 rootK,
            uint256 tokenAAmount,
            uint256 tokenBAmount
        )
    {

        uint256 totalSupply = IUniswapV2Pair(lpToken).totalSupply();
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(lpToken).getReserves();
        tokenAAmount = (lpAmount * reserve0) / totalSupply;
        tokenBAmount = (lpAmount * reserve1) / totalSupply;
        rootK = Math.sqrt(tokenAAmount * tokenBAmount);
    }

    function getPairTokens(address lpToken) public view returns (address, address) {

        return (IUniswapV2Pair(lpToken).token0(), IUniswapV2Pair(lpToken).token1());
    }
}