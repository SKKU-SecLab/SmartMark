

pragma solidity ^0.5.0;

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


pragma solidity 0.5.12;


interface IUniswapSwapper {

    event Swap(
        address caller,
        address guy,
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        uint256 inputTokenSpent
    );

    function init(address _factoryAddress) external returns (bool);


    function isDestroyed() external view returns (bool);


    function swap(
        address payable guy,
        address inputTokenAddress,
        address outputTokenAddress,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    ) external;


    function swapEth(address payable guy, address outputTokenAddress, uint256 outputTokenAmount)
        external
        payable;

}


pragma solidity 0.5.12;

interface IUniswapFactory {

    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}


pragma solidity 0.5.12;

interface IUniswapExchange {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline)
        external
        payable
        returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline)
        external
        returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought)
        external
        view
        returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought)
        external
        view
        returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient)
        external
        payable
        returns (uint256 tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline)
        external
        payable
        returns (uint256 eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient)
        external
        payable
        returns (uint256 eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline)
        external
        returns (uint256 eth_bought);

    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline)
        external
        returns (uint256 tokens_sold);

    function tokenToEthTransferOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    ) external returns (uint256 tokens_sold);

    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);

    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_bought);

    function tokenToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_sold);

    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_sold);

    function tokenToExchangeSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256 tokens_bought);

    function tokenToExchangeTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256 tokens_bought);

    function tokenToExchangeSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256 tokens_sold);

    function tokenToExchangeTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256 tokens_sold);

}


pragma solidity 0.5.12;







contract UniswapSwapper is IUniswapSwapper {

    using SafeMath for uint256;

    bool internal destroyed;
    bool isTemplate;

    address internal factoryAddress;

    uint16 constant DEADLINE_TIME_LENGTH = 300;

    event Swap(
        address caller,
        address guy,
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        uint256 inputTokenSpent,
        address factoryAddress
    );

    constructor() public {
        isTemplate = true;
    }

    function init(address _factoryAddress) external notTemplate returns (bool) {

        require(factoryAddress == address(0), "factory already init");
        factoryAddress = _factoryAddress;
        return true;
    }

    modifier notTemplate() {

        require(isTemplate == false, "is template contract");
        require(destroyed == false, "this contract will selfdestruct");
        _;
    }

    function swapTokenToTokenOutput(
        address caller,
        address guy,
        address inputTokenAddress,
        address outputTokenAddress,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    ) internal returns (uint256) {

        uint256 inputBalancePriorOps = IERC20(inputTokenAddress).balanceOf(address(this));
        uint256 outputBalancePriorOps = IERC20(outputTokenAddress).balanceOf(address(this));
        require(
            IERC20(inputTokenAddress).transferFrom(msg.sender, address(this), inputTokenAmount),
            "error transfer input token to swap"
        );
        IUniswapExchange exchange = IUniswapExchange(
            IUniswapFactory(factoryAddress).getExchange(inputTokenAddress)
        );
        require(address(exchange) != address(0), "exchange can not be 0 address");
        IERC20(inputTokenAddress).approve(address(exchange), inputTokenAmount);
        uint256 inputTokenSpent = exchange.tokenToTokenSwapOutput(
            outputTokenAmount,
            inputTokenAmount, // at least prevent to consume more input tokens than the transfer
            uint256(-1), // do not check how much eth is sold prior the swap: input token --> eth --> output token
            block.timestamp.add(DEADLINE_TIME_LENGTH), // prevent swap to go throught if is not mined after deadline
            outputTokenAddress
        );
        require(inputTokenSpent > 0, "Swap not spent input token");
        require(
            IERC20(inputTokenAddress).transfer(guy, inputTokenAmount.sub(inputTokenSpent)),
            "error transfer remaining input"
        );
        require(
            IERC20(outputTokenAddress).transfer(caller, outputTokenAmount),
            "error transfer remaining output"
        );
        require(
            IERC20(inputTokenAddress).balanceOf(address(this)) == inputBalancePriorOps,
            "input token still here"
        );
        require(
            IERC20(outputTokenAddress).balanceOf(address(this)) == outputBalancePriorOps,
            "output token still here"
        );
        return inputTokenSpent;
    }

    function isDestroyed() external view returns (bool) {

        return destroyed;
    }

    function swapEth(address payable guy, address outputTokenAddress, uint256 outputTokenAmount)
        external
        payable
        notTemplate
    {

        require(factoryAddress != address(0), "factory address not init");
        require(guy != address(0), "guy address can not be 0");
        require(outputTokenAddress != address(0), "output token can not be 0");
        require(msg.value > 0, "ETH value amount can not be 0");
        require(outputTokenAmount > 0, "output token amount can not be 0");

        uint256 outputBalancePriorOps = IERC20(outputTokenAddress).balanceOf(address(this));
        IUniswapExchange exchange = IUniswapExchange(
            IUniswapFactory(factoryAddress).getExchange(outputTokenAddress)
        );
        require(address(exchange) != address(0), "exchange can not be 0 address");
        uint256 ethCost = exchange.getEthToTokenOutputPrice(outputTokenAmount);
        require(ethCost <= msg.value, "Eth costs greater than input");
        uint256 ethSpent = exchange.ethToTokenSwapOutput.value(ethCost)(
            outputTokenAmount,
            block.timestamp.add(DEADLINE_TIME_LENGTH) // prevent swap to go throught if is not mined after deadline
        );
        require(ethSpent > 0, "ETH not spent");
        require(
            IERC20(outputTokenAddress).balanceOf(address(this)) ==
                outputBalancePriorOps.add(outputTokenAmount),
            "no output token from uniswap"
        );
        require(
            IERC20(outputTokenAddress).transfer(msg.sender, outputTokenAmount),
            "error transfer remaining output"
        );
        require(
            IERC20(outputTokenAddress).balanceOf(address(this)) == outputBalancePriorOps,
            "output token still here"
        );
        emit Swap(
            msg.sender,
            guy,
            address(0),
            outputTokenAddress,
            msg.value,
            outputTokenAmount,
            ethSpent,
            factoryAddress
        );
        destroyed = true;
        selfdestruct(guy);
    }

    function swap(
        address payable guy,
        address inputTokenAddress,
        address outputTokenAddress,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    ) external notTemplate {

        require(factoryAddress != address(0), "factory address not init");
        require(guy != address(0), "depositor address can not be 0");
        require(inputTokenAddress != address(0), "input address can not be 0");
        require(outputTokenAddress != address(0), "output token can not be 0");
        require(inputTokenAmount > 0, "input token amount can not be 0");
        require(outputTokenAmount > 0, "output token amount can not be 0");
        uint256 inputTokenSpent = swapTokenToTokenOutput(
            msg.sender,
            guy,
            inputTokenAddress,
            outputTokenAddress,
            inputTokenAmount,
            outputTokenAmount
        );
        emit Swap(
            msg.sender,
            guy,
            inputTokenAddress,
            outputTokenAddress,
            inputTokenAmount,
            outputTokenAmount,
            inputTokenSpent,
            factoryAddress
        );
        destroyed = true;
        selfdestruct(guy);
    }
}