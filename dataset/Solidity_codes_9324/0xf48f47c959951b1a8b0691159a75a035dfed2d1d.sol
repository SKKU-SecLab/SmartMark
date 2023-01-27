


pragma solidity ^0.6.8;

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
}



pragma solidity ^0.6.8;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.8;



library SafeERC20 {

    function transfer(IERC20 _token, address _to, uint256 _val) internal returns (bool) {

        (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _val));
        return success && (data.length == 0 || abi.decode(data, (bool)));
    }
}



pragma solidity ^0.6.8;




library PineUtils {

    address internal constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    function balanceOf(IERC20 _token, address _addr) internal view returns (uint256) {

        if (ETH_ADDRESS == address(_token)) {
            return _addr.balance;
        }

        return _token.balanceOf(_addr);
    }

    function transfer(IERC20 _token, address _to, uint256 _val) internal returns (bool) {

        if (ETH_ADDRESS == address(_token)) {
            (bool success, ) = _to.call{value:_val}("");
            return success;
        }

        return SafeERC20.transfer(_token, _to, _val);
    }
}



pragma solidity ^0.6.8;


contract Order {

    address public constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
}


pragma solidity ^0.6.8;


interface IHandler {

    receive() external payable;

    function handle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external payable returns (uint256 bought);


    function canHandle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external view returns (bool);

}



pragma solidity ^0.6.8;


abstract contract IUniswapExchange {
    function tokenAddress() external virtual view returns (address token);
    function factoryAddress() external virtual view returns (address factory);
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external virtual payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external virtual returns (uint256, uint256);
    function getEthToTokenInputPrice(uint256 eth_sold) external virtual view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external virtual view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external virtual view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external virtual view returns (uint256 tokens_sold);
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external virtual payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external virtual payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external virtual payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external virtual payable returns (uint256  eth_sold);
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external virtual returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external virtual returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external virtual returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external virtual returns (uint256  tokens_sold);
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external virtual returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external virtual returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external virtual returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external virtual returns (uint256  tokens_sold);
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external virtual returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external virtual returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external virtual returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external virtual returns (uint256  tokens_sold);
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external virtual returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external virtual returns (bool);
    function approve(address _spender, uint256 _value) external virtual returns (bool);
    function allowance(address _owner, address _spender) external virtual view returns (uint256);
    function balanceOf(address _owner) external virtual view returns (uint256);
    function totalSupply() external virtual view returns (uint256);
    function setup(address token_addr) external virtual;
}



pragma solidity ^0.6.8;




abstract contract IUniswapFactory {
    address public exchangeTemplate;
    uint256 public tokenCount;
    function createExchange(address token) external virtual returns (address exchange);
    function getExchange(address token) external virtual view returns (IUniswapExchange exchange);
    function getToken(address exchange) external virtual view returns (IERC20 token);
    function getTokenWithId(uint256 tokenId) external virtual view returns (address token);
    function initializeFactory(address template) external virtual;
}


pragma solidity ^0.6.8;








contract UniswapV1Handler is IHandler, Order {


    using SafeMath for uint256;

    uint256 private constant never = uint(-1);

    IUniswapFactory public immutable uniswapFactory;

    constructor(IUniswapFactory _uniswapFactory) public {
        uniswapFactory = _uniswapFactory;
    }

    receive() external override payable {
        require(msg.sender != tx.origin, "UniswapV1Handler#receive: NO_SEND_ETH_PLEASE");
    }

    function handle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256,
        uint256,
        bytes calldata _data
    ) external payable override returns (uint256 bought) {

        uint256 inputAmount = PineUtils.balanceOf(_inputToken, address(this));

        (,address payable relayer, uint256 fee) = abi.decode(_data, (address, address, uint256));

        if (address(_inputToken) == ETH_ADDRESS) {
            uint256 sell = inputAmount.sub(fee);
            bought = _ethToToken(uniswapFactory, _outputToken, sell, msg.sender);
        } else if (address(_outputToken) == ETH_ADDRESS) {
            bought = _tokenToEth(uniswapFactory, _inputToken, inputAmount);
            bought = bought.sub(fee);

            (bool successSender,) = msg.sender.call{value: bought}("");
            require(successSender, "UniswapV1Handler#handle: TRANSFER_ETH_TO_CALLER_FAILED");
        } else {
            uint256 boughtEth = _tokenToEth(uniswapFactory, _inputToken, inputAmount);

            bought = _ethToToken(uniswapFactory, _outputToken, boughtEth.sub(fee), msg.sender);
        }

        (bool successRelayer,) = relayer.call{value: fee}("");
        require(successRelayer, "UniswapV1Handler#handle: TRANSFER_ETH_TO_RELAYER_FAILED");
    }

    function canHandle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external override view returns (bool) {

        (,,uint256 fee) = abi.decode(_data, (address, address, uint256));

        uint256 bought;

        if (address(_inputToken) == ETH_ADDRESS) {
            if (_inputAmount <= fee) {
                return false;
            }

            uint256 sell = _inputAmount.sub(fee);
            bought = _outEthToToken(uniswapFactory, _outputToken, sell);
        } else if (address(_outputToken) == ETH_ADDRESS) {
            bought = _outTokenToEth(uniswapFactory ,_inputToken, _inputAmount);

            if (bought <= fee) {
                return false;
            }

            bought = bought.sub(fee);
        } else {
            uint256 boughtEth =  _outTokenToEth(uniswapFactory, _inputToken, _inputAmount);
            if (boughtEth <= fee) {
                return false;
            }

            bought = _outEthToToken(uniswapFactory, _outputToken, boughtEth.sub(fee));
        }

        return bought >= _minReturn;
    }

    function simulate(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external view returns (bool, uint256) {

        (,,uint256 fee) = abi.decode(_data, (address, address, uint256));

        uint256 bought;

        if (address(_inputToken) == ETH_ADDRESS) {
            if (_inputAmount <= fee) {
                return (false, 0);
            }

            uint256 sell = _inputAmount.sub(fee);
            bought = _outEthToToken(uniswapFactory, _outputToken, sell);
        } else if (address(_outputToken) == ETH_ADDRESS) {
            bought = _outTokenToEth(uniswapFactory ,_inputToken, _inputAmount);

            if (bought <= fee) {
                return (false, 0);
            }

            bought = bought.sub(fee);
        } else {
            uint256 boughtEth =  _outTokenToEth(uniswapFactory, _inputToken, _inputAmount);
            if (boughtEth <= fee) {
                return (false, 0);
            }

            bought = _outEthToToken(uniswapFactory, _outputToken, boughtEth.sub(fee));
        }

        return (bought >= _minReturn, bought);
    }

    function _ethToToken(
        IUniswapFactory _uniswapFactory,
        IERC20 _token,
        uint256 _amount,
        address _dest
    ) private returns (uint256) {

        IUniswapExchange uniswap = _uniswapFactory.getExchange(address(_token));

        return uniswap.ethToTokenTransferInput{value: _amount}(1, never, _dest);
    }

    function _tokenToEth(
        IUniswapFactory _uniswapFactory,
        IERC20 _token,
        uint256 _amount
    ) private returns (uint256) {

        IUniswapExchange uniswap = _uniswapFactory.getExchange(address(_token));
        require(address(uniswap) != address(0), "UniswapV1Handler#_tokenToEth: EXCHANGE_DOES_NOT_EXIST");

        uint256 prevAllowance = _token.allowance(address(this), address(uniswap));
        if (prevAllowance < _amount) {
            if (prevAllowance != 0) {
                _token.approve(address(uniswap), 0);
            }

            _token.approve(address(uniswap), uint(-1));
        }

        return uniswap.tokenToEthSwapInput(_amount, 1, never);
    }

    function _outEthToToken(IUniswapFactory _uniswapFactory, IERC20 _token, uint256 _amount) private view returns (uint256) {

        return _uniswapFactory.getExchange(address(_token)).getEthToTokenInputPrice(_amount);
    }

    function _outTokenToEth(IUniswapFactory _uniswapFactory, IERC20 _token, uint256 _amount) private view returns (uint256) {

        return _uniswapFactory.getExchange(address(_token)).getTokenToEthInputPrice(_amount);
    }
}