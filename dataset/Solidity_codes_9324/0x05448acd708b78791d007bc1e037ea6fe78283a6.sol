



pragma solidity ^0.5.5;

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


pragma solidity ^0.5.0;

contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity ^0.5.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IUniswapV2Router02 {

    function WETH() external pure returns (address);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

}

interface IUniswapV2Pair {

    function token0() external pure returns (address);


    function token1() external pure returns (address);


    function balanceOf(address user) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

contract UniswapV2_ZapOut_General_V3 is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    bool public stopped = false;
    uint256 public goodwill;

    mapping(address => bool) public feeWhitelist;

    uint256 affiliateSplit;
    mapping(address => bool) public affiliates;
    mapping(address => mapping(address => uint256)) public affiliateBalance;
    mapping(address => uint256) public totalAffiliateBalance;

    address
        private constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256
        private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;

    IUniswapV2Router02 private constant uniswapV2Router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    address private constant wethTokenAddress = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    constructor(uint256 _goodwill, uint256 _affiliateSplit) public {
        goodwill = _goodwill;
        affiliateSplit = _affiliateSplit;
    }

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    event zapOut(
        address sender,
        address pool,
        address token,
        uint256 tokensRec
    );

    function ZapOut2PairToken(
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        address affiliate
    )
        public
        nonReentrant
        stopInEmergency
        returns (uint256 amountA, uint256 amountB)
    {

        IUniswapV2Pair pair = IUniswapV2Pair(_FromUniPoolAddress);

        require(address(pair) != address(0), "Error: Invalid Unipool Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        IERC20(_FromUniPoolAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _IncomingLP
        );

        IERC20(_FromUniPoolAddress).safeApprove(
            address(uniswapV2Router),
            _IncomingLP
        );

        if (token0 == wethTokenAddress || token1 == wethTokenAddress) {
            address _token = token0 == wethTokenAddress ? token1 : token0;
            (amountA, amountB) = uniswapV2Router.removeLiquidityETH(
                _token,
                _IncomingLP,
                1,
                1,
                address(this),
                deadline
            );

            uint256 tokenGoodwill = _subtractGoodwill(
                _token,
                amountA,
                affiliate
            );
            uint256 ethGoodwill = _subtractGoodwill(
                ETHAddress,
                amountB,
                affiliate
            );

            IERC20(_token).safeTransfer(msg.sender, amountA.sub(tokenGoodwill));
            Address.sendValue(msg.sender, amountB.sub(ethGoodwill));
        } else {
            (amountA, amountB) = uniswapV2Router.removeLiquidity(
                token0,
                token1,
                _IncomingLP,
                1,
                1,
                address(this),
                deadline
            );

            uint256 tokenAGoodwill = _subtractGoodwill(
                token0,
                amountA,
                affiliate
            );
            uint256 tokenBGoodwill = _subtractGoodwill(
                token1,
                amountB,
                affiliate
            );

            IERC20(token0).safeTransfer(
                msg.sender,
                amountA.sub(tokenAGoodwill)
            );
            IERC20(token1).safeTransfer(
                msg.sender,
                amountB.sub(tokenBGoodwill)
            );
        }
        emit zapOut(msg.sender, _FromUniPoolAddress, token0, amountA);
        emit zapOut(msg.sender, _FromUniPoolAddress, token1, amountB);
    }

    function ZapOut(
        address _ToTokenContractAddress,
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        uint256 _minTokensRec,
        address[] memory _swapTarget,
        bytes memory swap1Data,
        bytes memory swap2Data,
        address affiliate
    ) public nonReentrant stopInEmergency returns (uint256 tokenBought) {

        (uint256 amountA, uint256 amountB) = _removeLiquidity(
            _FromUniPoolAddress,
            _IncomingLP
        );

        tokenBought = _swapTokens(
            _FromUniPoolAddress,
            amountA,
            amountB,
            _ToTokenContractAddress,
            _swapTarget,
            swap1Data,
            swap2Data
        );
        require(tokenBought >= _minTokensRec, "High slippage");

        emit zapOut(
            msg.sender,
            _FromUniPoolAddress,
            _ToTokenContractAddress,
            tokenBought
        );

        uint256 totalGoodwillPortion;

        if (_ToTokenContractAddress == address(0)) {
            totalGoodwillPortion = _subtractGoodwill(
                ETHAddress,
                tokenBought,
                affiliate
            );

            msg.sender.transfer(tokenBought.sub(totalGoodwillPortion));
        } else {
            totalGoodwillPortion = _subtractGoodwill(
                _ToTokenContractAddress,
                tokenBought,
                affiliate
            );

            IERC20(_ToTokenContractAddress).safeTransfer(
                msg.sender,
                tokenBought.sub(totalGoodwillPortion)
            );
        }

        return tokenBought.sub(totalGoodwillPortion);
    }

    function ZapOut2PairTokenWithPermit(
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        address affiliate,
        bytes calldata _permitData
    ) external stopInEmergency returns (uint256 amountA, uint256 amountB) {

        (bool success, ) = _FromUniPoolAddress.call(_permitData);
        require(success, "Could Not Permit");

        (amountA, amountB) = ZapOut2PairToken(
            _FromUniPoolAddress,
            _IncomingLP,
            affiliate
        );
    }

    function ZapOutWithPermit(
        address _ToTokenContractAddress,
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        uint256 _minTokensRec,
        bytes memory _permitData,
        address[] memory _swapTarget,
        bytes memory swap1Data,
        bytes memory swap2Data,
        address affiliate
    ) public stopInEmergency returns (uint256) {

        (bool success, ) = _FromUniPoolAddress.call(_permitData);
        require(success, "Could Not Permit");

        return (
            ZapOut(
                _ToTokenContractAddress,
                _FromUniPoolAddress,
                _IncomingLP,
                _minTokensRec,
                _swapTarget,
                swap1Data,
                swap2Data,
                affiliate
            )
        );
    }

    function _removeLiquidity(address _FromUniPoolAddress, uint256 _IncomingLP)
        internal
        returns (uint256 amountA, uint256 amountB)
    {

        IUniswapV2Pair pair = IUniswapV2Pair(_FromUniPoolAddress);

        require(address(pair) != address(0), "Error: Invalid Unipool Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        IERC20(_FromUniPoolAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _IncomingLP
        );

        IERC20(_FromUniPoolAddress).safeApprove(
            address(uniswapV2Router),
            _IncomingLP
        );

        (amountA, amountB) = uniswapV2Router.removeLiquidity(
            token0,
            token1,
            _IncomingLP,
            1,
            1,
            address(this),
            deadline
        );
        require(amountA > 0 && amountB > 0, "Insufficient Liquidity");
    }

    function _swapTokens(
        address _FromUniPoolAddress,
        uint256 _amountA,
        uint256 _amountB,
        address _toToken,
        address[] memory _swapTarget,
        bytes memory swap1Data,
        bytes memory swap2Data
    ) internal returns (uint256 tokensBought) {

        require(_swapTarget.length == 2, "Invalid data for 0x swap");

        address token0 = IUniswapV2Pair(_FromUniPoolAddress).token0();
        address token1 = IUniswapV2Pair(_FromUniPoolAddress).token1();

        if (token0 == _toToken) {
            tokensBought = tokensBought.add(_amountA);
        } else {
            tokensBought = tokensBought.add(
                _fillQuote(
                    token0,
                    _toToken,
                    _amountA,
                    _swapTarget[0],
                    swap1Data
                )
            );
        }

        if (token1 == _toToken) {
            tokensBought = tokensBought.add(_amountB);
        } else {
            tokensBought = tokensBought.add(
                _fillQuote(
                    token1,
                    _toToken,
                    _amountB,
                    _swapTarget[1],
                    swap2Data
                )
            );
        }
    }

    function _fillQuote(
        address _fromTokenAddress,
        address _toToken,
        uint256 _amount,
        address _swapTarget,
        bytes memory swapData
    ) internal returns (uint256) {

        uint256 valueToSend;
        if (_fromTokenAddress == address(0)) {
            valueToSend = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);
            fromToken.safeApprove(address(_swapTarget), 0);
            fromToken.safeApprove(address(_swapTarget), _amount);
        }

        uint256 initialBalance = _toToken == address(0)
            ? address(this).balance
            : IERC20(_toToken).balanceOf(address(this));

        (bool success, ) = _swapTarget.call.value(valueToSend)(swapData);
        require(success, "Error Swapping Tokens");

        uint256 finalBalance = _toToken == address(0)
            ? (address(this).balance).sub(initialBalance)
            : IERC20(_toToken).balanceOf(address(this)).sub(initialBalance);

        require(finalBalance > 0, "Swapped to Invalid Intermediate");

        return finalBalance;
    }

    function removeLiquidityReturn(
        address _FromUniPoolAddress,
        address _tokenA,
        address _tokenB,
        uint256 _liquidity
    ) external view returns (uint256 amountA, uint256 amountB) {

        IUniswapV2Pair pair = IUniswapV2Pair(_FromUniPoolAddress);

        (uint256 amount0, uint256 amount1) = _getBurnAmount(
            _FromUniPoolAddress,
            pair,
            _tokenA,
            _tokenB,
            _liquidity
        );

        (address token0, ) = _sortTokens(_tokenA, _tokenB);

        (amountA, amountB) = _tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);

        require(amountA >= 1, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= 1, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
    }

    function _sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function _getBurnAmount(
        address _FromUniPoolAddress,
        IUniswapV2Pair pair,
        address _token0,
        address _token1,
        uint256 _liquidity
    ) internal view returns (uint256 amount0, uint256 amount1) {

        uint256 balance0 = IERC20(_token0).balanceOf(_FromUniPoolAddress);
        uint256 balance1 = IERC20(_token1).balanceOf(_FromUniPoolAddress);

        uint256 _totalSupply = pair.totalSupply();

        amount0 = _liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = _liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED"
        );
    }

    function _subtractGoodwill(
        address token,
        uint256 amount,
        address affiliate
    ) internal returns (uint256 totalGoodwillPortion) {

        bool whitelisted = feeWhitelist[msg.sender];
        if (!whitelisted && goodwill > 0) {
            totalGoodwillPortion = SafeMath.div(
                SafeMath.mul(amount, goodwill),
                10000
            );

            if (affiliates[affiliate]) {
                uint256 affiliatePortion = totalGoodwillPortion
                    .mul(affiliateSplit)
                    .div(100);
                affiliateBalance[affiliate][token] = affiliateBalance[affiliate][token]
                    .add(affiliatePortion);
                totalAffiliateBalance[token] = totalAffiliateBalance[token].add(
                    affiliatePortion
                );
            }
        }
    }

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;
    }

    function set_new_goodwill(uint256 _new_goodwill) public onlyOwner {

        require(
            _new_goodwill >= 0 && _new_goodwill <= 100,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_feeWhitelist(address zapAddress, bool status)
        external
        onlyOwner
    {

        feeWhitelist[zapAddress] = status;
    }

    function set_new_affiliateSplit(uint256 _new_affiliateSplit)
        external
        onlyOwner
    {

        require(
            _new_affiliateSplit <= 100,
            "Affiliate Split Value not allowed"
        );
        affiliateSplit = _new_affiliateSplit;
    }

    function set_affiliate(address _affiliate, bool _status)
        external
        onlyOwner
    {

        affiliates[_affiliate] = _status;
    }

    function ownerWithdrawTokens(address[] calldata tokens) external onlyOwner {


        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance.sub(
                    totalAffiliateBalance[tokens[i]]
                );
                Address.sendValue(Address.toPayable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this)).sub(
                    totalAffiliateBalance[tokens[i]]
                );
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    function affilliateWithdraw(address[] calldata tokens) external {

        uint256 tokenBal;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBal = affiliateBalance[msg.sender][tokens[i]];
            affiliateBalance[msg.sender][tokens[i]] = 0;
            totalAffiliateBalance[tokens[i]] = totalAffiliateBalance[tokens[i]]
                .sub(tokenBal);

            if (tokens[i] == ETHAddress) {
                Address.sendValue(msg.sender, tokenBal);
            } else {
                IERC20(tokens[i]).safeTransfer(msg.sender, tokenBal);
            }
        }
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}