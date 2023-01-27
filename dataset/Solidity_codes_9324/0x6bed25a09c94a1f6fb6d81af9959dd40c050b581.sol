
pragma solidity ^0.5.0;


interface ERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);

    function approve(address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);

 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface ERCIndex {

    function topTokensLength() external returns (uint);

    function getTokenAddressAndBalance(uint index) external returns (ERC20, uint);

}

contract UniswapFactoryInterface {

    address public exchangeTemplate;
    uint256 public tokenCount;
    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}

contract UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setup(address token_addr) external;

}

contract MyUniswapProxy {

    
    UniswapFactoryInterface factory;

    ERCIndex ercIndex;
    
    bool public contractSet = false;
    
    ERC20 daiToken = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // mainnet
    
    constructor () public {

        factory = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95); // mainnet

    }
    
    
    function setERCIndexContract(address _address) public {

        
        require(!contractSet);
        
        ercIndex = ERCIndex(_address);
        
        contractSet = true;
        
    }
    
    function calculateIndexValueAndNext2Tokens(uint _numberOfTokens) public returns(uint, uint, uint) {

        
        require(_numberOfTokens > 0);
        
        ERC20 token; // token instance
        
        uint rate; // token's rate
        
        uint tokenBalance; // token's balance
        
        uint tokenBalanceEth; // token's eth value (rate * balance)
        
        uint ethValue = 0; // sum value of all tokens
        
        uint indexOfTokenWithLowestBalance = 0;
        uint lowestBalance = uint(-1);
        
        uint indexOfTokenWithLowestBalance2 = 0;
        uint lowestBalance2 = uint(-1);
        
        for (uint i = 0; i < _numberOfTokens; i++) {
            
            (token, tokenBalance) = ercIndex.getTokenAddressAndBalance(i);
            
            rate = getTokenEthPrice(address(token)); // 1 token is x ETH * (10 ** 18)
            
            tokenBalanceEth = rate * tokenBalance;
            
            ethValue += tokenBalanceEth;
            
            if (tokenBalanceEth < lowestBalance) {
                
                lowestBalance2 = lowestBalance;
                indexOfTokenWithLowestBalance2 = indexOfTokenWithLowestBalance;
                
                indexOfTokenWithLowestBalance = i;
                lowestBalance = tokenBalanceEth;
                
            } else if (tokenBalanceEth < lowestBalance2) {
                
                indexOfTokenWithLowestBalance2 = i;
                lowestBalance2 = tokenBalanceEth;
                
            }
            
        }
        
        uint daiValue = daiToken.balanceOf(address(ercIndex));
        
        daiValue += ethValue / getTokenEthPrice(address(daiToken)); // DAIEUR > 0
        
        return (daiValue, indexOfTokenWithLowestBalance, indexOfTokenWithLowestBalance2);
    
        
    }
    
    
    
    function getTokenEthPrice(address _token) public view returns (uint) {


        address exchange = factory.getExchange(_token);
        
        uint tokenReserve = ERC20(_token).balanceOf(exchange);
        
        uint ethReserve = exchange.balance;
        
        if (tokenReserve == 0) {
            
            return 0;
            
        } else {
            
            return (ethReserve * (10 ** 18)) / tokenReserve;
        
        }
        
    }
    
    function executeSwap(ERC20 _srcToken, uint _tokensSold, address _destToken, address _destAddress) public {

        
        require(_srcToken.transferFrom(msg.sender, address(this), _tokensSold));

        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(address(_srcToken)));
        
        require(!(address(exchange) == address(0)));
        
        require(_srcToken.approve(address(exchange), 0));

        require(_srcToken.approve(address(exchange), _tokensSold));
        
        exchange.tokenToTokenTransferInput(_tokensSold, 1, 1, now + 10 minutes, _destAddress, _destToken);
    }
    
    
}