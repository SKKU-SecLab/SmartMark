
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.9;

interface IMultiMerkleStash {

    struct claimParam {
        address token;
        uint256 index;
        uint256 amount;
        bytes32[] merkleProof;
    }

    function isClaimed(address token, uint256 index)
        external
        view
        returns (bool);


    function claim(
        address token,
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external;


    function claimMulti(address account, claimParam[] calldata claims) external;


    function updateMerkleRoot(address token, bytes32 _merkleRoot) external;


    event Claimed(
        address indexed token,
        uint256 index,
        uint256 amount,
        address indexed account,
        uint256 indexed update
    );
    event MerkleRootUpdated(
        address indexed token,
        bytes32 indexed merkleRoot,
        uint256 indexed update
    );
}// MIT
pragma solidity 0.8.9;

interface IMerkleDistributorV2 {

    enum Option {
        Claim,
        ClaimAsETH,
        ClaimAsCRV,
        ClaimAsCVX,
        ClaimAndStake
    }

    function vault() external view returns (address);


    function merkleRoot() external view returns (bytes32);


    function week() external view returns (uint32);


    function frozen() external view returns (bool);


    function isClaimed(uint256 index) external view returns (bool);


    function setApprovals() external;


    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external;


    function claimAs(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        Option option
    ) external;


    function claimAs(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        Option option,
        uint256 minAmountOut
    ) external;


    function freeze() external;


    function unfreeze() external;


    function stake() external;


    function updateMerkleRoot(bytes32 newMerkleRoot, bool unfreeze) external;


    function updateDepositor(address newDepositor) external;


    function updateAdmin(address newAdmin) external;


    function updateVault(address newVault) external;


    event Claimed(
        uint256 index,
        uint256 amount,
        address indexed account,
        uint256 indexed week,
        Option option
    );

    event DepositorUpdated(
        address indexed oldDepositor,
        address indexed newDepositor
    );

    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    event VaultUpdated(address indexed oldVault, address indexed newVault);

    event MerkleRootUpdated(bytes32 indexed merkleRoot, uint32 indexed week);
}// MIT
pragma solidity 0.8.9;

interface IUniV2Router {

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

}// MIT
pragma solidity 0.8.9;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}// MIT
pragma solidity 0.8.9;

interface ICvxCrvDeposit {

    function deposit(uint256, bool) external;

}// MIT
pragma solidity 0.8.9;

interface IVotiumRegistry {

    struct Registry {
        uint256 start;
        address to;
        uint256 expiration;
    }

    function registry(address _from)
        external
        view
        returns (Registry memory registry);


    function setRegistry(address _to) external;

}// MIT
pragma solidity 0.8.9;

interface IUniV3Router {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

}// MIT
pragma solidity 0.8.9;

interface ICurveV2Pool {

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256);


    function calc_token_amount(uint256[2] calldata amounts)
        external
        view
        returns (uint256);


    function exchange_underlying(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external
        returns (uint256);


    function lp_price() external view returns (uint256);


    function price_oracle() external view returns (uint256);


    function remove_liquidity_one_coin(
        uint256 token_amount,
        uint256 i,
        uint256 min_amount,
        bool use_eth,
        address receiver
    ) external returns (uint256);

}// MIT
pragma solidity 0.8.9;

interface ISwapper {

    function buy(uint256 amount) external returns (uint256);


    function sell(uint256 amount) external returns (uint256);

}// MIT
pragma solidity 0.8.9;

interface ICurveFactoryPool {

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_balances() external view returns (uint256[2] memory);


    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy,
        address _receiver
    ) external returns (uint256);

}// UNLICENSED
pragma solidity 0.8.9;

interface IBasicRewards {

    function stakeFor(address, uint256) external returns (bool);


    function balanceOf(address) external view returns (uint256);


    function earned(address) external view returns (uint256);


    function withdrawAll(bool) external returns (bool);


    function withdraw(uint256, bool) external returns (bool);


    function withdrawAndUnwrap(uint256 amount, bool claim)
        external
        returns (bool);


    function getReward() external returns (bool);


    function stake(uint256) external returns (bool);


    function extraRewards(uint256) external view returns (address);


    function exit() external returns (bool);

}// MIT
pragma solidity 0.8.9;


contract UnionBase {

    address public constant CVXCRV_STAKING_CONTRACT =
        0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e;
    address public constant CURVE_CRV_ETH_POOL =
        0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511;
    address public constant CURVE_CVX_ETH_POOL =
        0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;
    address public constant CURVE_CVXCRV_CRV_POOL =
        0x9D0464996170c6B9e75eED71c68B99dDEDf279e8;

    address public constant CRV_TOKEN =
        0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant CVXCRV_TOKEN =
        0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address public constant CVX_TOKEN =
        0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    uint256 public constant CRVETH_ETH_INDEX = 0;
    uint256 public constant CRVETH_CRV_INDEX = 1;
    int128 public constant CVXCRV_CRV_INDEX = 0;
    int128 public constant CVXCRV_CVXCRV_INDEX = 1;
    uint256 public constant CVXETH_ETH_INDEX = 0;
    uint256 public constant CVXETH_CVX_INDEX = 1;

    IBasicRewards cvxCrvStaking = IBasicRewards(CVXCRV_STAKING_CONTRACT);
    ICurveV2Pool cvxEthSwap = ICurveV2Pool(CURVE_CVX_ETH_POOL);
    ICurveV2Pool crvEthSwap = ICurveV2Pool(CURVE_CRV_ETH_POOL);
    ICurveFactoryPool crvCvxCrvSwap = ICurveFactoryPool(CURVE_CVXCRV_CRV_POOL);

    function _swapCrvToCvxCrv(uint256 amount, address recipient)
        internal
        returns (uint256)
    {

        return _crvToCvxCrv(amount, recipient, 0);
    }

    function _swapCrvToCvxCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return _crvToCvxCrv(amount, recipient, minAmountOut);
    }

    function _crvToCvxCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return
            crvCvxCrvSwap.exchange(
                CVXCRV_CRV_INDEX,
                CVXCRV_CVXCRV_INDEX,
                amount,
                minAmountOut,
                recipient
            );
    }

    function _swapCvxCrvToCrv(uint256 amount, address recipient)
        internal
        returns (uint256)
    {

        return _cvxCrvToCrv(amount, recipient, 0);
    }

    function _swapCvxCrvToCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return _cvxCrvToCrv(amount, recipient, minAmountOut);
    }

    function _cvxCrvToCrv(
        uint256 amount,
        address recipient,
        uint256 minAmountOut
    ) internal returns (uint256) {

        return
            crvCvxCrvSwap.exchange(
                CVXCRV_CVXCRV_INDEX,
                CVXCRV_CRV_INDEX,
                amount,
                minAmountOut,
                recipient
            );
    }

    function _swapCrvToEth(uint256 amount) internal returns (uint256) {

        return _crvToEth(amount, 0);
    }

    function _swapCrvToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _crvToEth(amount, minAmountOut);
    }

    function _crvToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            crvEthSwap.exchange_underlying{value: 0}(
                CRVETH_CRV_INDEX,
                CRVETH_ETH_INDEX,
                amount,
                minAmountOut
            );
    }

    function _swapEthToCrv(uint256 amount) internal returns (uint256) {

        return _ethToCrv(amount, 0);
    }

    function _swapEthToCrv(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _ethToCrv(amount, minAmountOut);
    }

    function _ethToCrv(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            crvEthSwap.exchange_underlying{value: amount}(
                CRVETH_ETH_INDEX,
                CRVETH_CRV_INDEX,
                amount,
                minAmountOut
            );
    }

    function _swapEthToCvx(uint256 amount) internal returns (uint256) {

        return _ethToCvx(amount, 0);
    }

    function _swapEthToCvx(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _ethToCvx(amount, minAmountOut);
    }

    function _ethToCvx(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            cvxEthSwap.exchange_underlying{value: amount}(
                CVXETH_ETH_INDEX,
                CVXETH_CVX_INDEX,
                amount,
                minAmountOut
            );
    }

    modifier notToZeroAddress(address _to) {

        require(_to != address(0), "Invalid address!");
        _;
    }
}// MIT
pragma solidity 0.8.9;


contract UnionZap is Ownable, UnionBase {

    using SafeERC20 for IERC20;

    address public votiumDistributor =
        0x378Ba9B73309bE80BF4C2c027aAD799766a7ED5A;

    address private constant SUSHI_ROUTER =
        0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address private constant CVXCRV_DEPOSIT =
        0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae;
    address public constant VOTIUM_REGISTRY =
        0x92e6E43f99809dF84ed2D533e1FD8017eb966ee2;
    address private constant T_TOKEN =
        0xCdF7028ceAB81fA0C6971208e83fa7872994beE5;
    address private constant T_ETH_POOL =
        0x752eBeb79963cf0732E9c0fec72a49FD1DEfAEAC;
    address private constant UNISWAP_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNIV3_ROUTER =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private constant WETH_TOKEN =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address[] public outputTokens;
    address public platform = 0x9Bc7c6ad7E7Cf3A6fCB58fb21e27752AC1e53f99;

    uint256 private constant DECIMALS = 1e9;
    uint256 public platformFee = 2e7;

    mapping(uint256 => address) private routers;
    mapping(uint256 => uint24) private fees;

    struct tokenContracts {
        address pool;
        address swapper;
        address distributor;
    }

    struct curveSwapParams {
        address pool;
        uint16 ethIndex;
    }

    mapping(address => tokenContracts) public tokenInfo;
    mapping(address => curveSwapParams) public curveRegistry;

    event Received(address sender, uint256 amount);
    event Distributed(uint256 amount, address token, address distributor);
    event VotiumDistributorUpdated(address distributor);
    event FundsRetrieved(address token, address to, uint256 amount);
    event CurvePoolUpdated(address token, address pool);
    event OutputTokenUpdated(
        address token,
        address pool,
        address swapper,
        address distributor
    );
    event PlatformFeeUpdated(uint256 _fee);
    event PlatformUpdated(address indexed _platform);

    constructor() {
        routers[0] = SUSHI_ROUTER;
        routers[1] = UNISWAP_ROUTER;
        fees[0] = 3000;
        fees[1] = 10000;
        curveRegistry[CVX_TOKEN] = curveSwapParams(CURVE_CVX_ETH_POOL, 0);
        curveRegistry[T_TOKEN] = curveSwapParams(T_ETH_POOL, 0);
    }

    function addCurvePool(address token, curveSwapParams calldata params)
        external
        onlyOwner
    {

        curveRegistry[token] = params;
        IERC20(token).safeApprove(params.pool, 0);
        IERC20(token).safeApprove(params.pool, type(uint256).max);
        emit CurvePoolUpdated(token, params.pool);
    }

    function updateOutputToken(address token, tokenContracts calldata params)
        external
        onlyOwner
    {

        assert(params.pool != address(0));
        if (tokenInfo[token].pool == address(0)) {
            outputTokens.push(token);
        }
        tokenInfo[token] = params;
        emit OutputTokenUpdated(
            token,
            params.pool,
            params.swapper,
            params.distributor
        );
    }

    function removeCurvePool(address token) external onlyOwner {

        IERC20(token).safeApprove(curveRegistry[token].pool, 0);
        delete curveRegistry[token];
        emit CurvePoolUpdated(token, address(0));
    }

    function setForwarding(address _to) external onlyOwner {

        IVotiumRegistry(VOTIUM_REGISTRY).setRegistry(_to);
    }

    function setPlatformFee(uint256 _fee) external onlyOwner {

        platformFee = _fee;
        emit PlatformFeeUpdated(_fee);
    }

    function setPlatform(address _platform)
        external
        onlyOwner
        notToZeroAddress(_platform)
    {

        platform = _platform;
        emit PlatformUpdated(_platform);
    }

    function updateVotiumDistributor(address _distributor)
        external
        onlyOwner
        notToZeroAddress(_distributor)
    {

        votiumDistributor = _distributor;
        emit VotiumDistributorUpdated(_distributor);
    }

    function retrieveTokens(address[] calldata tokens, address to)
        external
        onlyOwner
        notToZeroAddress(to)
    {

        for (uint256 i; i < tokens.length; ++i) {
            address token = tokens[i];
            uint256 tokenBalance = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransfer(to, tokenBalance);
            emit FundsRetrieved(token, to, tokenBalance);
        }
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {

        (bool success, bytes memory result) = _to.call{value: _value}(_data);
        return (success, result);
    }

    function setApprovals() external onlyOwner {

        IERC20(CRV_TOKEN).safeApprove(CURVE_CVXCRV_CRV_POOL, 0);
        IERC20(CRV_TOKEN).safeApprove(CURVE_CVXCRV_CRV_POOL, type(uint256).max);

        IERC20(CRV_TOKEN).safeApprove(CURVE_CRV_ETH_POOL, 0);
        IERC20(CRV_TOKEN).safeApprove(CURVE_CRV_ETH_POOL, type(uint256).max);

        IERC20(CRV_TOKEN).safeApprove(CVXCRV_DEPOSIT, 0);
        IERC20(CRV_TOKEN).safeApprove(CVXCRV_DEPOSIT, type(uint256).max);

        IERC20(CVXCRV_TOKEN).safeApprove(CURVE_CVXCRV_CRV_POOL, 0);
        IERC20(CVXCRV_TOKEN).safeApprove(
            CURVE_CVXCRV_CRV_POOL,
            type(uint256).max
        );

        IERC20(CVXCRV_TOKEN).safeApprove(CVXCRV_STAKING_CONTRACT, 0);
        IERC20(CVXCRV_TOKEN).safeApprove(
            CVXCRV_STAKING_CONTRACT,
            type(uint256).max
        );
    }

    function _swapToETHCurve(address token, uint256 amount) internal {

        curveSwapParams memory params = curveRegistry[token];
        require(params.pool != address(0));
        IERC20(token).safeApprove(params.pool, 0);
        IERC20(token).safeApprove(params.pool, amount);
        ICurveV2Pool(params.pool).exchange_underlying(
            params.ethIndex ^ 1,
            params.ethIndex,
            amount,
            0
        );
    }

    function _swapToETH(
        address token,
        uint256 amount,
        address router
    ) internal notToZeroAddress(router) {

        address[] memory _path = new address[](2);
        _path[0] = token;
        _path[1] = WETH_TOKEN;

        IERC20(token).safeApprove(router, 0);
        IERC20(token).safeApprove(router, amount);

        IUniV2Router(router).swapExactTokensForETH(
            amount,
            1,
            _path,
            address(this),
            block.timestamp + 1
        );
    }

    function _swapToETHUniV3(
        address token,
        uint256 amount,
        uint24 fee
    ) internal {

        IERC20(token).safeApprove(UNIV3_ROUTER, 0);
        IERC20(token).safeApprove(UNIV3_ROUTER, amount);
        IUniV3Router.ExactInputSingleParams memory _params = IUniV3Router
            .ExactInputSingleParams(
                token,
                WETH_TOKEN,
                fee,
                address(this),
                block.timestamp + 1,
                amount,
                1,
                0
            );
        uint256 _wethReceived = IUniV3Router(UNIV3_ROUTER).exactInputSingle(
            _params
        );
        IWETH(WETH_TOKEN).withdraw(_wethReceived);
    }

    function _isEffectiveOutputToken(address _token, uint32[] calldata _weights)
        internal
        returns (bool)
    {

        for (uint256 j; j < _weights.length; ++j) {
            if (_token == outputTokens[j] && _weights[j] > 0) {
                return true;
            }
        }
        return false;
    }

    function claim(IMultiMerkleStash.claimParam[] calldata claimParams)
        public
        onlyOwner
    {

        require(claimParams.length > 0, "No claims");
        IMultiMerkleStash(votiumDistributor).claimMulti(
            address(this),
            claimParams
        );
    }

    function swap(
        IMultiMerkleStash.claimParam[] calldata claimParams,
        uint256 routerChoices,
        bool claimBeforeSwap,
        uint256 minAmountOut,
        uint256 gasRefund,
        uint32[] calldata weights
    ) public onlyOwner {

        require(weights.length == outputTokens.length, "Invalid weight length");
        if (claimBeforeSwap) {
            claim(claimParams);
        }

        for (uint256 i; i < claimParams.length; ++i) {
            address _token = claimParams[i].token;
            uint256 _balance = IERC20(_token).balanceOf(address(this));
            if (_balance <= 1) {
                continue;
            } else {
                _balance -= 1;
            }
            if (_token == WETH_TOKEN) {
                IWETH(WETH_TOKEN).withdraw(_balance);
            }
            else {
                if (_isEffectiveOutputToken(_token, weights)) {
                    continue;
                }
                uint256 _choice = routerChoices & 7;
                if (_choice >= 4) {
                    _swapToETHCurve(_token, _balance);
                } else if (_choice >= 2) {
                    _swapToETHUniV3(_token, _balance, fees[_choice - 2]);
                } else {
                    _swapToETH(_token, _balance, routers[_choice]);
                }
                routerChoices = routerChoices >> 3;
            }
        }

        assert(address(this).balance > minAmountOut);

        (bool success, ) = (tx.origin).call{value: gasRefund}("");
        require(success, "ETH transfer failed");
    }

    function _sell(address _token, uint256 _amount) internal {

        if (_token == CRV_TOKEN) {
            _crvToEth(_amount, 0);
        } else if (_token == CVX_TOKEN) {
            _swapToETHCurve(_token, _amount);
        } else {
            IERC20(_token).safeTransfer(tokenInfo[_token].swapper, _amount);
            ISwapper(tokenInfo[_token].swapper).sell(_amount);
        }
    }

    function _buy(address _token, uint256 _amount) internal {

        if (_token == CRV_TOKEN) {
            _ethToCrv(_amount, 0);
        } else if (_token == CVX_TOKEN) {
            _ethToCvx(_amount, 0);
        } else {
            (bool success, ) = tokenInfo[_token].swapper.call{value: _amount}(
                ""
            );
            require(success, "ETH transfer failed");
            ISwapper(tokenInfo[_token].swapper).buy(_amount);
        }
    }

    function _toCvxCrv(uint256 _minAmountOut, bool _lock)
        internal
        returns (uint256)
    {

        uint256 _crvBalance = IERC20(CRV_TOKEN).balanceOf(address(this));
        if (!_lock) {
            return _swapCrvToCvxCrv(_crvBalance, address(this), _minAmountOut);
        }
        assert(_crvBalance > _minAmountOut);
        ICvxCrvDeposit(CVXCRV_DEPOSIT).deposit(_crvBalance, true);
        return _crvBalance;
    }

    function _levyFees(uint256 _totalEthBalance) internal returns (uint256) {

        uint256 _feeAmount = (_totalEthBalance * platformFee) / DECIMALS;
        if (address(this).balance >= _feeAmount) {
            (bool success, ) = (platform).call{value: _feeAmount}("");
            require(success, "ETH transfer failed");
            return _feeAmount;
        }
        return 0;
    }

    function adjust(
        bool lock,
        uint32[] calldata weights,
        uint256[] calldata minAmounts
    ) public onlyOwner validWeights(weights) {

        require(
            minAmounts.length == outputTokens.length,
            "Invalid min amounts"
        );
        uint256 _totalEthBalance = address(this).balance;

        uint256[] memory prices = new uint256[](outputTokens.length);
        uint256[] memory amounts = new uint256[](outputTokens.length);
        address _outputToken;

        for (uint256 i; i < weights.length; ++i) {
            if (weights[i] > 0) {
                _outputToken = outputTokens[i];
                prices[i] = ICurveV2Pool(tokenInfo[_outputToken].pool)
                    .price_oracle();
                amounts[i] =
                    (IERC20(_outputToken).balanceOf(address(this)) *
                        prices[i]) /
                    1e18;
                _totalEthBalance += amounts[i];
            }
        }

        _totalEthBalance -= _levyFees(_totalEthBalance);

        for (uint256 i; i < weights.length; ++i) {
            if (weights[i] > 0) {
                _outputToken = outputTokens[i];
                uint256 _desired = (_totalEthBalance * weights[i]) / DECIMALS;
                if (amounts[i] > _desired) {
                    _sell(
                        _outputToken,
                        (((amounts[i] - _desired) * 1e18) / prices[i])
                    );
                } else {
                    _buy(_outputToken, _desired - amounts[i]);
                }
                if (_outputToken == CRV_TOKEN) {
                    _toCvxCrv(minAmounts[i], lock);
                } else {
                    assert(
                        IERC20(_outputToken).balanceOf(address(this)) >
                            minAmounts[i]
                    );
                }
            }
        }
    }

    function distribute(uint32[] calldata weights)
        public
        onlyOwner
        validWeights(weights)
    {

        for (uint256 i; i < weights.length; ++i) {
            if (weights[i] > 0) {
                address _outputToken = outputTokens[i];
                address _distributor = tokenInfo[_outputToken].distributor;
                IMerkleDistributorV2(_distributor).freeze();
                if (_outputToken == CRV_TOKEN) {
                    _outputToken = CVXCRV_TOKEN;
                }
                uint256 _balance = IERC20(_outputToken).balanceOf(
                    address(this)
                );
                IERC20(_outputToken).safeTransfer(_distributor, _balance);
                IMerkleDistributorV2(_distributor).stake();
                emit Distributed(_balance, _outputToken, _distributor);
            }
        }
    }

    function processIncentives(
        IMultiMerkleStash.claimParam[] calldata claimParams,
        uint256 routerChoices,
        bool claimBeforeSwap,
        bool lock,
        uint256 gasRefund,
        uint32[] calldata weights,
        uint256[] calldata minAmounts
    ) external onlyOwner {

        require(
            minAmounts.length == outputTokens.length,
            "Invalid min amounts"
        );
        swap(
            claimParams,
            routerChoices,
            claimBeforeSwap,
            0,
            gasRefund,
            weights
        );
        adjust(lock, weights, minAmounts);
        distribute(weights);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    modifier validWeights(uint32[] calldata _weights) {

        require(
            _weights.length == outputTokens.length,
            "Invalid weight length"
        );
        uint256 _totalWeights;
        for (uint256 i; i < _weights.length; ++i) {
            _totalWeights += _weights[i];
        }
        require(_totalWeights == DECIMALS, "Invalid weights");
        _;
    }
}