




pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}

interface IUniswapRouter02 {

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


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


    function swapETHForExactTokens(
        uint256 amountOut,
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

}

interface yVault {

    function deposit(uint256) external;


    function withdraw(uint256) external;


    function getPricePerFullShare() external view returns (uint256);


    function token() external view returns (address);

}

interface ICurveZapInGeneral {

    function ZapIn(
        address toWhomToIssue,
        address fromToken,
        address swapAddress,
        uint256 incomingTokenQty,
        uint256 minPoolTokens
    ) external payable returns (uint256 crvTokensBought);

}

interface ICurveZapOutGeneral {

    function ZapOut(
        address payable toWhomToIssue,
        address swapAddress,
        uint256 incomingCrv,
        address toToken,
        uint256 minToTokens
    ) external returns (uint256 ToTokensBought);

}

interface IAaveLendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);


    function getLendingPoolCore() external view returns (address payable);

}

interface IAaveLendingPool {

    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;

}

interface IAToken {

    function redeem(uint256 _amount) external;


    function underlyingAssetAddress() external returns (address);

}

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;

}

contract yVault_ZapInOut_General_V1_5 is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    bool public stopped = false;
    uint16 public goodwill;

    IUniswapV2Factory
        private constant UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );
    IUniswapRouter02 private constant uniswapRouter = IUniswapRouter02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    ICurveZapInGeneral public CurveZapInGeneral = ICurveZapInGeneral(
        0xf9A724c2607E5766a7Bbe530D6a7e173532F9f3a
    );
    ICurveZapOutGeneral public CurveZapOutGeneral = ICurveZapOutGeneral(
        0xA3061Cf6aC1423c6F40917AD49602cBA187181Dc
    );

    IAaveLendingPoolAddressesProvider
        private constant lendingPoolAddressProvider = IAaveLendingPoolAddressesProvider(
        0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
    );

    address
        private constant yCurveExchangeAddress = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
    address
        private constant sBtcCurveExchangeAddress = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;
    address
        private constant bUSDCurveExchangeAddress = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
    address
        private constant threeCurveExchangeAddress = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address
        private constant cUSDCurveExchangeAddress = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;

    address
        private constant yCurvePoolTokenAddress = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address
        private constant sBtcCurvePoolTokenAddress = 0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3;
    address
        private constant bUSDCurvePoolTokenAddress = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    address
        private constant threeCurvePoolTokenAddress = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address
        private constant cUSDCurvePoolTokenAddress = 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2;

    mapping(address => address) public token2Exchange; //Curve token to Curve exchange

    address
        private constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address
        private constant wethTokenAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address
        private constant zgoodwillAddress = 0x3CE37278de6388532C3949ce4e886F365B14fB56;

    uint256
        private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;

    event Zapin(
        address _toWhomToIssue,
        address _toYVaultAddress,
        uint256 _Outgoing
    );

    event Zapout(
        address _toWhomToIssue,
        address _fromYVaultAddress,
        address _toTokenAddress,
        uint256 _tokensRecieved
    );

    constructor() public {
        token2Exchange[yCurvePoolTokenAddress] = yCurveExchangeAddress;
        token2Exchange[bUSDCurvePoolTokenAddress] = bUSDCurveExchangeAddress;
        token2Exchange[sBtcCurvePoolTokenAddress] = sBtcCurveExchangeAddress;
        token2Exchange[threeCurvePoolTokenAddress] = threeCurveExchangeAddress;
        token2Exchange[cUSDCurvePoolTokenAddress] = cUSDCurveExchangeAddress;
    }

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function updateCurveZapIn(address CurveZapInGeneralAddress)
        public
        onlyOwner
    {

        require(CurveZapInGeneralAddress != address(0), "Invalid Address");
        CurveZapInGeneral = ICurveZapInGeneral(CurveZapInGeneralAddress);
    }

    function updateCurveZapOut(address CurveZapOutGeneralAddress)
        public
        onlyOwner
    {

        require(CurveZapOutGeneralAddress != address(0), "Invalid Address");
        CurveZapOutGeneral = ICurveZapOutGeneral(CurveZapOutGeneralAddress);
    }

    function addNewCurveExchange(
        address curvePoolToken,
        address curveExchangeAddress
    ) public onlyOwner {

        require(
            curvePoolToken != address(0) && curveExchangeAddress != address(0),
            "Invalid Address"
        );
        token2Exchange[curvePoolToken] = curveExchangeAddress;
    }

    function ZapIn(
        address _toWhomToIssue,
        address _toYVaultAddress,
        uint16 _vaultType,
        address _fromTokenAddress,
        uint256 _amount,
        uint256 _minYTokens
    ) public payable nonReentrant stopInEmergency returns (uint256) {

        yVault vaultToEnter = yVault(_toYVaultAddress);
        address underlyingVaultToken = vaultToEnter.token();

        if (_fromTokenAddress == address(0)) {
            require(msg.value > 0, "ERR: No ETH sent");
        } else {
            require(_amount > 0, "Err: No Tokens Sent");
            require(msg.value == 0, "ERR: ETH sent with Token");

            IERC20(_fromTokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        uint256 iniYTokensBal = IERC20(address(vaultToEnter)).balanceOf(
            address(this)
        );

        if (underlyingVaultToken == _fromTokenAddress) {
            IERC20(underlyingVaultToken).safeApprove(
                address(vaultToEnter),
                _amount
            );
            vaultToEnter.deposit(_amount);
        } else {
            if (_vaultType == 2) {

                    address curveExchangeAddr
                 = token2Exchange[underlyingVaultToken];

                uint256 tokensBought;
                if (_fromTokenAddress == address(0)) {
                    tokensBought = CurveZapInGeneral.ZapIn.value(msg.value)(
                        address(this),
                        address(0),
                        curveExchangeAddr,
                        msg.value,
                        0
                    );
                } else {
                    IERC20(_fromTokenAddress).safeApprove(
                        address(CurveZapInGeneral),
                        _amount
                    );
                    tokensBought = CurveZapInGeneral.ZapIn(
                        address(this),
                        _fromTokenAddress,
                        curveExchangeAddr,
                        _amount,
                        0
                    );
                }

                IERC20(underlyingVaultToken).safeApprove(
                    address(vaultToEnter),
                    tokensBought
                );
                vaultToEnter.deposit(tokensBought);
            } else if (_vaultType == 1) {
                address underlyingAsset = IAToken(underlyingVaultToken)
                    .underlyingAssetAddress();

                uint256 tokensBought;
                if (_fromTokenAddress == address(0)) {
                    tokensBought = _eth2Token(underlyingAsset);
                } else {
                    tokensBought = _token2Token(
                        _fromTokenAddress,
                        underlyingAsset,
                        _amount
                    );
                }

                IERC20(underlyingAsset).safeApprove(
                    lendingPoolAddressProvider.getLendingPoolCore(),
                    tokensBought
                );

                IAaveLendingPool(lendingPoolAddressProvider.getLendingPool())
                    .deposit(underlyingAsset, tokensBought, 0);

                uint256 aTokensBought = IERC20(underlyingVaultToken).balanceOf(
                    address(this)
                );
                IERC20(underlyingVaultToken).safeApprove(
                    address(vaultToEnter),
                    aTokensBought
                );
                vaultToEnter.deposit(aTokensBought);
            } else {
                uint256 tokensBought;
                if (_fromTokenAddress == address(0)) {
                    tokensBought = _eth2Token(underlyingVaultToken);
                } else {
                    tokensBought = _token2Token(
                        _fromTokenAddress,
                        underlyingVaultToken,
                        _amount
                    );
                }

                IERC20(underlyingVaultToken).safeApprove(
                    address(vaultToEnter),
                    tokensBought
                );
                vaultToEnter.deposit(tokensBought);
            }
        }

        uint256 yTokensRec = IERC20(address(vaultToEnter))
            .balanceOf(address(this))
            .sub(iniYTokensBal);
        require(yTokensRec >= _minYTokens, "High Slippage");

        uint256 goodwillPortion = _transferGoodwill(
            address(vaultToEnter),
            yTokensRec
        );

        IERC20(address(vaultToEnter)).safeTransfer(
            _toWhomToIssue,
            yTokensRec.sub(goodwillPortion)
        );

        emit Zapin(
            _toWhomToIssue,
            address(vaultToEnter),
            yTokensRec.sub(goodwillPortion)
        );

        return (yTokensRec.sub(goodwillPortion));
    }

    function ZapOut(
        address payable _toWhomToIssue,
        address _ToTokenContractAddress,
        address _fromYVaultAddress,
        uint16 _vaultType,
        uint256 _IncomingAmt,
        uint256 _minTokensRec
    ) public nonReentrant stopInEmergency returns (uint256) {

        yVault vaultToExit = yVault(_fromYVaultAddress);
        address underlyingVaultToken = vaultToExit.token();

        IERC20(address(vaultToExit)).safeTransferFrom(
            msg.sender,
            address(this),
            _IncomingAmt
        );

        uint256 goodwillPortion = _transferGoodwill(
            address(vaultToExit),
            _IncomingAmt
        );

        vaultToExit.withdraw(_IncomingAmt.sub(goodwillPortion));
        uint256 underlyingReceived = IERC20(underlyingVaultToken).balanceOf(
            address(this)
        );

        uint256 toTokensReceived;
        if (_ToTokenContractAddress == underlyingVaultToken) {
            IERC20(underlyingVaultToken).safeTransfer(
                _toWhomToIssue,
                underlyingReceived
            );
            toTokensReceived = underlyingReceived;
        } else {
            if (_vaultType == 2) {
                toTokensReceived = _withdrawFromCurve(
                    underlyingVaultToken,
                    underlyingReceived,
                    _toWhomToIssue,
                    _ToTokenContractAddress,
                    0
                );
            } else if (_vaultType == 1) {
                IAToken(underlyingVaultToken).redeem(underlyingReceived);
                address underlyingAsset = IAToken(underlyingVaultToken)
                    .underlyingAssetAddress();

                if (_ToTokenContractAddress == address(0)) {
                    toTokensReceived = _token2Eth(
                        underlyingAsset,
                        underlyingReceived,
                        _toWhomToIssue
                    );
                } else {
                    toTokensReceived = _token2Token(
                        underlyingAsset,
                        _ToTokenContractAddress,
                        underlyingReceived
                    );
                    IERC20(_ToTokenContractAddress).safeTransfer(
                        _toWhomToIssue,
                        toTokensReceived
                    );
                }
            } else {
                if (_ToTokenContractAddress == address(0)) {
                    toTokensReceived = _token2Eth(
                        underlyingVaultToken,
                        underlyingReceived,
                        _toWhomToIssue
                    );
                } else {
                    toTokensReceived = _token2Token(
                        underlyingVaultToken,
                        _ToTokenContractAddress,
                        underlyingReceived
                    );

                    IERC20(_ToTokenContractAddress).safeTransfer(
                        _toWhomToIssue,
                        toTokensReceived
                    );
                }
            }
        }

        require(toTokensReceived >= _minTokensRec, "High Slippage");

        emit Zapout(
            _toWhomToIssue,
            _fromYVaultAddress,
            _ToTokenContractAddress,
            toTokensReceived
        );

        return toTokensReceived;
    }

    function _withdrawFromCurve(
        address _CurvePoolToken,
        uint256 _tokenAmt,
        address _toWhomToIssue,
        address _ToTokenContractAddress,
        uint256 _minTokensRec
    ) internal returns (uint256) {

        IERC20(_CurvePoolToken).safeApprove(
            address(CurveZapOutGeneral),
            _tokenAmt
        );

        address curveExchangeAddr = token2Exchange[_CurvePoolToken];

        return (
            CurveZapOutGeneral.ZapOut(
                Address.toPayable(_toWhomToIssue),
                curveExchangeAddr,
                _tokenAmt,
                _ToTokenContractAddress,
                _minTokensRec
            )
        );
    }

    function _eth2Token(address _tokenContractAddress)
        internal
        returns (uint256 tokensBought)
    {

        if (_tokenContractAddress == wethTokenAddress) {
            IWETH(wethTokenAddress).deposit.value(msg.value)();
            return msg.value;
        }

        address[] memory path = new address[](2);
        path[0] = wethTokenAddress;
        path[1] = _tokenContractAddress;
        tokensBought = uniswapRouter.swapExactETHForTokens.value(msg.value)(
            1,
            path,
            address(this),
            deadline
        )[path.length - 1];
    }

    function _token2Token(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {

        if (_FromTokenContractAddress == _ToTokenContractAddress) {
            return tokens2Trade;
        }

        IERC20(_FromTokenContractAddress).safeApprove(
            address(uniswapRouter),
            tokens2Trade
        );

        if (_FromTokenContractAddress != wethTokenAddress) {
            if (_ToTokenContractAddress != wethTokenAddress) {
                address[] memory path = new address[](3);
                path[0] = _FromTokenContractAddress;
                path[1] = wethTokenAddress;
                path[2] = _ToTokenContractAddress;
                tokenBought = uniswapRouter.swapExactTokensForTokens(
                    tokens2Trade,
                    1,
                    path,
                    address(this),
                    deadline
                )[path.length - 1];
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

    function _token2Eth(
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        address payable _toWhomToIssue
    ) internal returns (uint256) {

        if (_FromTokenContractAddress == wethTokenAddress) {
            IWETH(wethTokenAddress).withdraw(tokens2Trade);
            _toWhomToIssue.transfer(tokens2Trade);
            return tokens2Trade;
        }

        IERC20(_FromTokenContractAddress).safeApprove(
            address(uniswapRouter),
            tokens2Trade
        );

        address[] memory path = new address[](2);
        path[0] = _FromTokenContractAddress;
        path[1] = wethTokenAddress;
        uint256 ethBought = uniswapRouter.swapExactTokensForETH(
            tokens2Trade,
            1,
            path,
            _toWhomToIssue,
            deadline
        )[path.length - 1];

        return ethBought;
    }

    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 goodwillPortion) {

        goodwillPortion = SafeMath.div(
            SafeMath.mul(tokens2Trade, goodwill),
            10000
        );

        if (goodwillPortion == 0) {
            return 0;
        }

        IERC20(_tokenContractAddress).safeTransfer(
            zgoodwillAddress,
            goodwillPortion
        );
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {

        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {

        uint256 qty = _TokenAddress.balanceOf(address(this));
        IERC20(address(_TokenAddress)).safeTransfer(owner(), qty);
    }

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;
    }

    function withdraw() public onlyOwner {

        uint256 contractBalance = address(this).balance;
        address payable _to = Address.toPayable(owner());
        _to.transfer(contractBalance);
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}