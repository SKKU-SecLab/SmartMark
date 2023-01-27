




pragma solidity ^0.6.0;

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

contract Ownable is Context {

    address payable public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address payable msgSender = _msgSender();
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

    function transferOwnership(address payable newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Babylonian {

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
}

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}

interface IUniswapV2Router02 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


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


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}

interface IUniswapV2Pair {

    function token0() external pure returns (address);


    function token1() external pure returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

}

contract ZapInModified is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    bool public stopped = false;

    IUniswapV2Router02 private constant uniswapRouter = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    IUniswapV2Factory
        private constant UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );

    address
        private wethTokenAddress;

    uint256
        private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;

    constructor() public {
        wethTokenAddress=uniswapRouter.WETH();
    }

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function ZapIn(
        address _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        uint256 _minPoolTokens
    ) public payable nonReentrant stopInEmergency returns (uint256) {

        uint256 toInvest;
        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "Error: ETH not sent");
            toInvest = msg.value;
        } else {
            require(msg.value == 0, "Error: ETH sent");
            require(_amount > 0, "Error: Invalid ERC amount");
            IERC20(_FromTokenContractAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
            toInvest = _amount;
        }

        uint256 LPBought = _performZapIn(
            _toWhomToIssue,
            _FromTokenContractAddress,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            toInvest
        );
        require(LPBought >= _minPoolTokens, "ERR: High Slippage");

        address _ToUniPoolAddress = UniSwapV2FactoryAddress.getPair(
            _ToUnipoolToken0,
            _ToUnipoolToken1
        );

        IERC20(_ToUniPoolAddress).safeTransfer(
            _toWhomToIssue,
            LPBought
        );
        return LPBought;
    }
    event DebugZap(uint256 ethToTrade,uint256 tokens0,uint256 tokens1,uint256 liquidityObtained);
    function _performZapIn(
        address _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount
    ) internal returns (uint256) {

        address intermediate = _getIntermediate(
            _FromTokenContractAddress,
            _amount,
            _ToUnipoolToken0,
            _ToUnipoolToken1
        );

        uint256 interAmt = _token2Token(
            _FromTokenContractAddress,
            intermediate,
            _amount
        );

        uint256 token0Bought;
        uint256 token1Bought;

        IUniswapV2Pair pair = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(_ToUnipoolToken0, _ToUnipoolToken1)
        );
        (uint256 res0, uint256 res1, ) = pair.getReserves();
        uint256 amountToSwap;
        if (intermediate == _ToUnipoolToken0) {
            amountToSwap = calculateSwapInAmount(res0, interAmt);
            if (amountToSwap <= 0) amountToSwap = interAmt.div(2);
            token1Bought = _token2Token(
                intermediate,
                _ToUnipoolToken1,
                amountToSwap
            );
            token0Bought = interAmt.sub(amountToSwap);
        } else {
            amountToSwap = calculateSwapInAmount(res1, interAmt);
            if (amountToSwap <= 0) amountToSwap = interAmt.div(2);
            token0Bought = _token2Token(
                intermediate,
                _ToUnipoolToken0,
                amountToSwap
            );
            token1Bought = interAmt.sub(amountToSwap);
        }

        uint256 lobt=_uniDeposit(
            _toWhomToIssue,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought
        );
        emit DebugZap(amountToSwap,token0Bought,token1Bought,lobt);
        return
            lobt;
    }

    function _uniDeposit(
        address _toWhomToIssue,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 token0Bought,
        uint256 token1Bought
    ) internal returns (uint256) {

        IERC20(_ToUnipoolToken0).safeApprove(
            address(uniswapRouter),
            token0Bought
        );
        IERC20(_ToUnipoolToken1).safeApprove(
            address(uniswapRouter),
            token1Bought
        );

        (uint256 amountA, uint256 amountB, uint256 LP) = uniswapRouter
            .addLiquidity(
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            1,
            1,
            address(this),
            deadline
        );

        IERC20(_ToUnipoolToken0).safeApprove(
            address(uniswapRouter),
            0
        );
        IERC20(_ToUnipoolToken1).safeApprove(
            address(uniswapRouter),
            0
        );

        if (token0Bought.sub(amountA) > 0) {
            IERC20(_ToUnipoolToken0).safeTransfer(
                _toWhomToIssue,
                token0Bought.sub(amountA)
            );
        }

        if (token1Bought.sub(amountB) > 0) {
            IERC20(_ToUnipoolToken1).safeTransfer(
                _toWhomToIssue,
                token1Bought.sub(amountB)
            );
        }

        return LP;
    }

    function _getIntermediate(
        address _FromTokenContractAddress,
        uint256 _amount,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1
    ) internal view returns (address) {

        if (_FromTokenContractAddress == address(0)) {
            _FromTokenContractAddress = wethTokenAddress;
        }

        if (_FromTokenContractAddress == _ToUnipoolToken0) {
            return _ToUnipoolToken0;
        } else if (_FromTokenContractAddress == _ToUnipoolToken1) {
            return _ToUnipoolToken1;
        } else if(_ToUnipoolToken0 == wethTokenAddress || _ToUnipoolToken1 == wethTokenAddress) {
            return wethTokenAddress;
        } else {
            IUniswapV2Pair pair = IUniswapV2Pair(
                UniSwapV2FactoryAddress.getPair(
                    _ToUnipoolToken0,
                    _ToUnipoolToken1
                )
            );
            (uint256 res0, uint256 res1, ) = pair.getReserves();

            uint256 ratio;
            bool isToken0Numerator;
            if (res0 >= res1) {
                ratio = res0 / res1;
                isToken0Numerator = true;
            } else {
                ratio = res1 / res0;
            }

            uint256 output0 = _calculateSwapOutput(
                _FromTokenContractAddress,
                _amount,
                _ToUnipoolToken0
            );
            uint256 output1 = _calculateSwapOutput(
                _FromTokenContractAddress,
                _amount,
                _ToUnipoolToken1
            );

            if (isToken0Numerator) {
                if (output1 * ratio >= output0) return _ToUnipoolToken1;
                else return _ToUnipoolToken0;
            } else {
                if (output0 * ratio >= output1) return _ToUnipoolToken0;
                else return _ToUnipoolToken1;
            }
        }
    }

    function _calculateSwapOutput(
        address _from,
        uint256 _amt,
        address _to
    ) internal view returns (uint256) {

        address pairA = UniSwapV2FactoryAddress.getPair(_from, _to);

        uint256 amtA;
        if (pairA != address(0)) {
            address[] memory pathA = new address[](2);
            pathA[0] = _from;
            pathA[1] = _to;

            amtA = uniswapRouter.getAmountsOut(_amt, pathA)[1];
        }

        uint256 amtB;
        if ((_from != wethTokenAddress) && _to != wethTokenAddress) {
            address[] memory pathB = new address[](3);
            pathB[0] = _from;
            pathB[1] = wethTokenAddress;
            pathB[2] = _to;

            amtB = uniswapRouter.getAmountsOut(_amt, pathB)[2];
        }

        if (amtA >= amtB) {
            return amtA;
        } else {
            return amtB;
        }
    }

    function zapInSimple(
      address _lptaddress,
      uint256 _minPoolTokens
    ) public payable{

      IUniswapV2Pair pair = IUniswapV2Pair(_lptaddress);
      ZapIn(
          msg.sender,
          address(0),
          pair.token0(),
          pair.token1(),
          0,
          _minPoolTokens
      );
    }

    function calculateMinPoolTokens(
    address _pair,
    uint256 _amount,
    uint256 _slippage) external view returns(uint256){

      uint256 numTokens=getResultingTokens(_pair,_amount);
      return numTokens.sub(numTokens.mul(_slippage).div(10000));
    }

    function getResultingTokens(
    address _pair,
    uint256 _amount) public view returns(uint256){

      IUniswapV2Pair pair = IUniswapV2Pair(
          _pair//UniSwapV2FactoryAddress.getPair(_ToUnipoolToken0, _ToUnipoolToken1)
      );

      address intermediate = _getIntermediate(
          address(0),
          _amount,
          pair.token0(),
          pair.token1()
      );

      uint256 interAmount=_amount;
      if(intermediate != wethTokenAddress){
        IUniswapV2Pair pairUpstream = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(wethTokenAddress, intermediate)
        );
        (uint256 resu0, uint256 resu1, ) = pairUpstream.getReserves();
        interAmount=uniswapRouter.getAmountOut(
          _amount,
          pairUpstream.token0()==wethTokenAddress ? resu0 : resu1,
          pairUpstream.token0()==wethTokenAddress ? resu1 : resu0
        );
      }

      (uint256 res0, uint256 res1, ) = pair.getReserves();

      if(pair.token0()==intermediate){
        uint256 toSwapAmount=calculateSwapInAmount(res0, interAmount);
        return getTokensAcquired(res0,IERC20(address(pair)).totalSupply(),interAmount.sub(toSwapAmount));
      }
      else{
        uint256 toSwapAmount=calculateSwapInAmount(res1, interAmount);
        return getTokensAcquired(res1,IERC20(address(pair)).totalSupply(),interAmount.sub(toSwapAmount));
      }
    }

    function getTokensAcquired(uint256 reserve,uint256 totalSupply,uint256 amount) public view returns(uint256){

      return totalSupply.mul(amount).div(reserve.add(amount));
    }

    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
        public
        pure
        returns (uint256)
    {

        return
            Babylonian
                .sqrt(
                reserveIn.mul(userIn.mul(3988000) + reserveIn.mul(3988009))
            )
                .sub(reserveIn.mul(1997)) / 1994;
    }

    event DebugTokenSwap(address from, address to,uint256 totrade,uint256 bought);
    function _token2Token(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {

        if (_FromTokenContractAddress == _ToTokenContractAddress) {
            return tokens2Trade;
        }

        if (_FromTokenContractAddress == address(0)) {
            if (_ToTokenContractAddress == wethTokenAddress) {
                IWETH(wethTokenAddress).deposit.value(tokens2Trade)();
                return tokens2Trade;
            }

            address[] memory path = new address[](2);
            path[0] = wethTokenAddress;
            path[1] = _ToTokenContractAddress;
            tokenBought = uniswapRouter.swapExactETHForTokens.value(
                tokens2Trade
            )(1, path, address(this), deadline)[path.length - 1];
        } else if (_ToTokenContractAddress == address(0)) {
            if (_FromTokenContractAddress == wethTokenAddress) {
                IWETH(wethTokenAddress).withdraw(tokens2Trade);
                return tokens2Trade;
            }

            IERC20(_FromTokenContractAddress).safeApprove(
                address(uniswapRouter),
                tokens2Trade
            );

            address[] memory path = new address[](2);
            path[0] = _FromTokenContractAddress;
            path[1] = wethTokenAddress;
            tokenBought = uniswapRouter.swapExactTokensForETH(
                tokens2Trade,
                1,
                path,
                address(this),
                deadline
            )[path.length - 1];
        } else {
            IERC20(_FromTokenContractAddress).safeApprove(
                address(uniswapRouter),
                tokens2Trade
            );

            if (_FromTokenContractAddress != wethTokenAddress) {
                if (_ToTokenContractAddress != wethTokenAddress) {
                    address pairA = UniSwapV2FactoryAddress.getPair(
                        _FromTokenContractAddress,
                        _ToTokenContractAddress
                    );
                    address[] memory pathA = new address[](2);
                    pathA[0] = _FromTokenContractAddress;
                    pathA[1] = _ToTokenContractAddress;
                    uint256 amtA;
                    if (pairA != address(0)) {
                        amtA = uniswapRouter.getAmountsOut(
                            tokens2Trade,
                            pathA
                        )[1];
                    }

                    address[] memory pathB = new address[](3);
                    pathB[0] = _FromTokenContractAddress;
                    pathB[1] = wethTokenAddress;
                    pathB[2] = _ToTokenContractAddress;

                    uint256 amtB = uniswapRouter.getAmountsOut(
                        tokens2Trade,
                        pathB
                    )[2];

                    if (amtA >= amtB) {
                        tokenBought = uniswapRouter.swapExactTokensForTokens(
                            tokens2Trade,
                            1,
                            pathA,
                            address(this),
                            deadline
                        )[pathA.length - 1];
                    } else {
                        tokenBought = uniswapRouter.swapExactTokensForTokens(
                            tokens2Trade,
                            1,
                            pathB,
                            address(this),
                            deadline
                        )[pathB.length - 1];
                    }
                } else {
                    address[] memory path = new address[](2);
                    path[0] = _FromTokenContractAddress;
                    path[1] = wethTokenAddress;

                    tokenBought = uniswapRouter.swapExactTokensForTokens(
                        tokens2Trade,
                        1,
                        path,
                        address(this),
                        deadline
                    )[path.length - 1];
                }
            } else {
                address[] memory path = new address[](2);
                path[0] = wethTokenAddress;
                path[1] = _ToTokenContractAddress;
                tokenBought = uniswapRouter.swapExactTokensForTokens(
                    tokens2Trade,
                    1,
                    path,
                    address(this),
                    deadline
                )[path.length - 1];
            }
        }
        require(tokenBought > 0, "Error Swapping Tokens");

        emit DebugTokenSwap(_FromTokenContractAddress, _ToTokenContractAddress,tokens2Trade,tokenBought);
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {

        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.safeTransfer(owner(), qty);
    }

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;
    }

    function withdraw() public onlyOwner {

        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

}