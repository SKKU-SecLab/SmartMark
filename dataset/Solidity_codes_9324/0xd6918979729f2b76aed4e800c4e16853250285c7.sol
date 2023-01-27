

pragma solidity 0.6.12;

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
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

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

        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IBPool is IERC20 {

    function version() external view returns (uint256);


    function swapExactAmountIn(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256, uint256);


    function swapExactAmountOut(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256, uint256);


    function calcInGivenOut(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256);


    function calcOutGivenIn(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256);


    function getDenormalizedWeight(address) external view returns (uint256);


    function swapFee() external view returns (uint256);


    function setSwapFee(uint256 _swapFee) external;


    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function finalize(
        uint256 _swapFee,
        uint256 _initPoolSupply,
        address[] calldata _bindTokens,
        uint256[] calldata _bindDenorms
    ) external;


    function setPublicSwap(bool _publicSwap) external;


    function setController(address _controller) external;


    function setExchangeProxy(address _exchangeProxy) external;


    function getFinalTokens() external view returns (address[] memory tokens);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function getBalance(address token) external view returns (uint256);


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


    function joinPoolFor(
        address account,
        uint256 rewardAmountOut,
        uint256[] calldata maxAmountsIn
    ) external;


    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function finalizeRewardFundInfo(address _rewardFund, uint256 _unstakingFrozenTime) external;


    function addRewardPool(
        IERC20 _rewardToken,
        uint256 _startBlock,
        uint256 _endRewardBlock,
        uint256 _rewardPerBlock,
        uint256 _lockRewardPercent,
        uint256 _startVestingBlock,
        uint256 _endVestingBlock
    ) external;


    function isBound(address t) external view returns (bool);


    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);

}

interface IFreeFromUpTo {

    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

}

interface IOracle {

    function updateCumulative() external;


    function update() external;


    function consult(address token, uint256 _amountIn) external view returns (uint144 _amountOut);


    function twap(uint256 _amountIn) external view returns (uint144 _amountOut);

}

interface IBoardroom {

    function balanceOf(address _director) external view returns (uint256);


    function earned(address _director) external view returns (uint256);


    function canWithdraw(address _director) external view returns (bool);


    function canClaimReward(address _director) external view returns (bool);


    function setOperator(address _operator) external;


    function setLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external;


    function stake(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function exit() external;


    function claimReward() external;


    function allocateSeigniorage(uint256 _amount) external;


    function governanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external;

}

interface IShare {

    function unclaimedTreasuryFund() external view returns (uint256 _pending);


    function claimRewards() external;

}

interface ITreasury {

    function epoch() external view returns (uint256);


    function getDollarUpdatedPrice() external view returns (uint256);


    function buyBonds(uint256 amount, uint256 targetPrice) external;


    function redeemBonds(uint256 amount, uint256 targetPrice) external;

}

contract CommunityFund {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 flag) {

        if ((flag & 0x1) == 0) {
            _;
        } else {
            uint256 gasStart = gasleft();
            _;
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }


    address public operator;

    bool public initialized = false;
    bool public publicAllowed; // set to true to allow public to call rebalance()

    uint256 public dollarPriceCeiling;

    address public dollar = address(0x003e0af2916e598Fa5eA5Cb2Da4EDfdA9aEd9Fde);
    address public bond = address(0x9f48b2f14517770F2d238c787356F3b961a6616F);
    address public share = address(0xE7C9C188138f7D70945D420d75F8Ca7d8ab9c700);

    address public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    address public boardroom = address(0xb9Fb8a22908c570C09a4Dbf5F89b87f9D91FBf4a);
    address public dollarOracle = address(0x90F42043E638094d710bdCF1D1CbE6268AEB22d7);

    mapping(address => address) public vliquidPools; // DAI/USDC -> value_liquid_pool

    uint256 private usdcDecimalFactor;

    uint256[] public expansionPercent;
    uint256[] public contractionPercent;

    address public treasury = address(0x18D6E366D854D73ca9C5A557ef79CcFAA732ab7b);
    uint256 public dollarPriceToBuyBack;
    mapping(address => uint256) public maxAmountToTrade; // BSD, DAI, USDC


    event Initialized(address indexed executor, uint256 at);
    event SwapToken(address inputToken, address outputToken, uint256 amount);
    event BoughtBonds(uint256 amount);
    event RedeemedBonds(uint256 amount);
    event ExecuteTransaction(address indexed target, uint256 value, string signature, bytes data);


    modifier onlyOperator() {

        require(operator == msg.sender, "CommunityFund: caller is not the operator");
        _;
    }

    modifier notInitialized() {

        require(!initialized, "CommunityFund: already initialized");
        _;
    }

    modifier checkPublicAllow() {

        require(publicAllowed || msg.sender == operator, "CommunityFund: caller is not the operator nor public call not allowed");
        _;
    }


    function initialize(
        address _dollar,
        address _bond,
        address _share,
        address _dai,
        address _usdc,
        address _boardroom,
        address _dollarOracle
    ) public notInitialized {

        dollar = _dollar;
        bond = _bond;
        share = _share;
        dai = _dai;
        usdc = _usdc;
        boardroom = _boardroom;
        dollarOracle = _dollarOracle;
        dollarPriceCeiling = 1010 finney; // $1.01
        vliquidPools[dai] = address(0xc1b6296e55b6cA1882a9cefD72Ac246ACdE91414);
        vliquidPools[usdc] = address(0xCDD2bD61D07b8d42843175dd097A4858A8f764e7);
        usdcDecimalFactor = 10**12; // USDC's decimals = 6
        expansionPercent = [20, 40, 40]; // dollar (20%), DAI (40%), USDC (40%) during expansion period
        contractionPercent = [80, 10, 10]; // dollar (80%), DAI (10%), USDC (10%) during contraction period
        publicAllowed = true;
        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {

        operator = _operator;
    }

    function setTreasury(address _treasury) external onlyOperator {

        treasury = _treasury;
    }

    function setDollarOracle(address _dollarOracle) external onlyOperator {

        dollarOracle = _dollarOracle;
    }

    function setPublicAllowed(bool _publicAllowed) external onlyOperator {

        publicAllowed = _publicAllowed;
    }

    function setExpansionPercent(
        uint256 _dollarPercent,
        uint256 _daiPercent,
        uint256 _usdcPercent
    ) external onlyOperator {

        require(_dollarPercent.add(_daiPercent).add(_usdcPercent) == 100, "!100%");
        expansionPercent[0] = _dollarPercent;
        expansionPercent[1] = _daiPercent;
        expansionPercent[2] = _usdcPercent;
    }

    function setContractionPercent(
        uint256 _dollarPercent,
        uint256 _daiPercent,
        uint256 _usdcPercent
    ) external onlyOperator {

        require(_dollarPercent.add(_daiPercent).add(_usdcPercent) == 100, "!100%");
        contractionPercent[0] = _dollarPercent;
        contractionPercent[1] = _daiPercent;
        contractionPercent[2] = _usdcPercent;
    }

    function setMaxAmountToTrade(
        uint256 _dollarAmount,
        uint256 _daiAmount,
        uint256 _usdcAmount
    ) external onlyOperator {

        maxAmountToTrade[dollar] = _dollarAmount;
        maxAmountToTrade[dai] = _daiAmount;
        maxAmountToTrade[usdc] = _usdcAmount;
    }

    function setDollarPriceCeiling(uint256 _dollarPriceCeiling) external onlyOperator {

        require(_dollarPriceCeiling >= 950 finney && _dollarPriceCeiling <= 1200 finney, "_dollarPriceCeiling: out of range"); // [$0.95, $1.20]
        dollarPriceCeiling = _dollarPriceCeiling;
    }

    function setDollarPriceToBuyBack(uint256 _dollarPriceToBuyBack) external onlyOperator {

        require(_dollarPriceToBuyBack >= 500 finney && _dollarPriceToBuyBack <= 1050 finney, "_dollarPriceToBuyBack: out of range"); // [$0.50, $1.05]
        dollarPriceToBuyBack = _dollarPriceToBuyBack;
    }

    function withdrawShare(uint256 _amount) external onlyOperator {

        IBoardroom(boardroom).withdraw(_amount);
    }

    function exitBoardroom() external onlyOperator {

        IBoardroom(boardroom).exit();
    }

    function grandFund(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {

        IERC20(_token).transfer(_to, _amount);
    }


    function earned() public view returns (uint256) {

        return IBoardroom(boardroom).earned(address(this));
    }

    function stablecoinBalances()
        public
        view
        returns (
            uint256 _dollarBal,
            uint256 _daiBal,
            uint256 _usdcBal,
            uint256 _totalBal
        )
    {

        _dollarBal = IERC20(dollar).balanceOf(address(this));
        _daiBal = IERC20(dai).balanceOf(address(this));
        _usdcBal = IERC20(usdc).balanceOf(address(this));
        _totalBal = _dollarBal.add(_daiBal).add(_usdcBal.mul(usdcDecimalFactor));
    }

    function stablecoinPercents()
        public
        view
        returns (
            uint256 _dollarPercent,
            uint256 _daiPercent,
            uint256 _usdcPercent
        )
    {

        (uint256 _dollarBal, uint256 _daiBal, uint256 _usdcBal, uint256 _totalBal) = stablecoinBalances();
        if (_totalBal > 0) {
            _dollarPercent = _dollarBal.mul(100).div(_totalBal);
            _daiPercent = _daiBal.mul(100).div(_totalBal);
            _usdcPercent = _usdcBal.mul(usdcDecimalFactor).mul(100).div(_totalBal);
        }
    }

    function getDollarPrice() public view returns (uint256 dollarPrice) {

        try IOracle(dollarOracle).consult(dollar, 1e18) returns (uint144 price) {
            return uint256(price);
        } catch {
            revert("CommunityFund: failed to consult dollar price from the oracle");
        }
    }

    function getDollarUpdatedPrice() public view returns (uint256 _dollarPrice) {

        try IOracle(dollarOracle).twap(1e18) returns (uint144 price) {
            return uint256(price);
        } catch {
            revert("Treasury: failed to consult dollar price from the oracle");
        }
    }


    function collectShareRewards() public checkPublicAllow {

        if (IShare(share).unclaimedTreasuryFund() > 0) {
            IShare(share).claimRewards();
        }
    }

    function claimAndRestake() public checkPublicAllow {

        if (IBoardroom(boardroom).canClaimReward(address(this))) {
            if (earned() > 0) {
                IBoardroom(boardroom).claimReward();
            }
            uint256 _shareBal = IERC20(share).balanceOf(address(this));
            if (_shareBal > 0) {
                IERC20(share).safeApprove(boardroom, 0);
                IERC20(share).safeApprove(boardroom, _shareBal);
                IBoardroom(boardroom).stake(_shareBal);
            }
        }
    }

    function rebalance(uint8 flag) public discountCHI(flag) checkPublicAllow {

        collectShareRewards();
        claimAndRestake();
        (uint256 _dollarBal, uint256 _daiBal, uint256 _usdcBal, uint256 _totalBal) = stablecoinBalances();
        if (_totalBal > 0) {
            uint256 _dollarPercent = _dollarBal.mul(100).div(_totalBal);
            uint256 _daiPercent = _daiBal.mul(100).div(_totalBal);
            uint256 _usdcPercent = _usdcBal.mul(usdcDecimalFactor).mul(100).div(_totalBal);
            uint256 _dollarUpdatedPrice = getDollarUpdatedPrice();
            if (_dollarUpdatedPrice >= dollarPriceCeiling) {
                if (_dollarPercent > expansionPercent[0]) {
                    uint256 _sellingBSD = _dollarBal.mul(_dollarPercent.sub(expansionPercent[0])).div(100);
                    if (_daiPercent >= expansionPercent[1]) {
                        if (_usdcPercent < expansionPercent[2]) {
                            _swapToken(dollar, usdc, _sellingBSD);
                        } else {
                            if (_daiPercent.sub(expansionPercent[1]) <= _usdcPercent.sub(expansionPercent[2])) {
                                _swapToken(dollar, dai, _sellingBSD);
                            } else {
                                _swapToken(dollar, usdc, _sellingBSD);
                            }
                        }
                    } else {
                        if (_usdcPercent >= expansionPercent[2]) {
                            _swapToken(dollar, dai, _sellingBSD);
                        } else {
                            uint256 _shortDaiPercent = expansionPercent[1].sub(_daiPercent);
                            uint256 _shortUsdcPercent = expansionPercent[2].sub(_usdcPercent);
                            uint256 _sellingBSDToDai = _sellingBSD.mul(_shortDaiPercent).div(_shortDaiPercent.add(_shortUsdcPercent));
                            _swapToken(dollar, dai, _sellingBSDToDai);
                            _swapToken(dollar, usdc, _sellingBSD.sub(_sellingBSDToDai));
                        }
                    }
                }
            } else if (_dollarUpdatedPrice <= dollarPriceToBuyBack) {
                if (_daiPercent >= contractionPercent[1]) {
                    if (_usdcPercent <= contractionPercent[2]) {
                        uint256 _sellingDAI = _daiBal.mul(_daiPercent.sub(contractionPercent[1])).div(100);
                        _swapToken(dai, dollar, _sellingDAI);
                    } else {
                        if (_daiPercent.sub(contractionPercent[1]) > _usdcPercent.sub(contractionPercent[2])) {
                            uint256 _sellingDAI = _daiBal.mul(_daiPercent.sub(contractionPercent[1])).div(100);
                            _swapToken(dai, dollar, _sellingDAI);
                        } else {
                            uint256 _sellingUSDC = _usdcBal.mul(_usdcPercent.sub(contractionPercent[2])).div(100);
                            _swapToken(usdc, dollar, _sellingUSDC);
                        }
                    }
                } else {
                    if (_usdcPercent > contractionPercent[2]) {
                        uint256 _sellingUSDC = _usdcBal.mul(_usdcPercent.sub(contractionPercent[2])).div(100);
                        _swapToken(usdc, dollar, _sellingUSDC);
                    }
                }
            }
        }
    }

    function buyBonds(uint256 _dollarAmount) external onlyOperator {

        uint256 _dollarPrice = ITreasury(treasury).getDollarUpdatedPrice();
        ITreasury(treasury).buyBonds(_dollarAmount, _dollarPrice);
        emit BoughtBonds(_dollarAmount);
    }

    function redeemBonds(uint256 _bondAmount) external onlyOperator {

        uint256 _dollarPrice = ITreasury(treasury).getDollarUpdatedPrice();
        ITreasury(treasury).redeemBonds(_bondAmount, _dollarPrice);
        emit RedeemedBonds(_bondAmount);
    }

    function _bpoolSwap(
        address _pool,
        address _input,
        address _output,
        uint256 _amount
    ) internal {

        IERC20(_input).safeApprove(_pool, 0);
        IERC20(_input).safeApprove(_pool, _amount);
        IBPool(_pool).swapExactAmountIn(_input, _amount, _output, 1, type(uint256).max);
        emit SwapToken(_input, _output, _amount);
    }

    function _swapToken(
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) internal {

        if (_amount == 0) return;
        uint256 _maxAmount = maxAmountToTrade[_inputToken];
        if (_maxAmount > 0 && _maxAmount < _amount) {
            _amount = _maxAmount;
        }
        address _pool;
        if (_outputToken == dollar) {
            _pool = vliquidPools[_inputToken];
        } else if (_inputToken == dollar) {
            _pool = vliquidPools[_outputToken];
        }
        require(_pool != address(0), "!pool");
        _bpoolSwap(_pool, _inputToken, _outputToken, _amount);
    }

    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) public onlyOperator returns (bytes memory) {

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, string("CommunityFund::executeTransaction: Transaction execution reverted."));

        emit ExecuteTransaction(target, value, signature, data);

        return returnData;
    }
}