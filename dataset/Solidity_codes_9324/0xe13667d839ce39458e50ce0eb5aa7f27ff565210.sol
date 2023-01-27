
pragma solidity 0.5.17;

library SafeMath {


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;}
}

interface Uniswap{

    function getExchange(address token) external view returns (address exchange);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    
}

interface Token{

    function getTokens(address sendTo) external payable;

    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    function primary() external view returns (address payable);

    function transfer(address to, uint tokens) external returns (bool success);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function approve(address spender, uint tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

}

contract Secondary{

    
    address constant public OUSDAddress = 0xD2d01dd6Aa7a2F5228c7c17298905A7C7E1dfE81;
    
    modifier onlyPrimary() {

        require(msg.sender == primary(), "Secondary: caller is not the primary account");
        _;
    }

    function primary() internal view returns (address payable) {

        return Token(OUSDAddress).primary();
    }
}

contract Arb is Secondary{

    
    using SafeMath for uint256;
    
    address constant public UniswapFactoryAddress = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address public OUSDPoolAddress;
    
    uint constant public INF = 33136721784;
    
    constructor () public {
        
        uint zero = 0;
        uint one = 1;
        
        address OSPVAddress  = 0xFCCe9526E030F1691966d5A651F5EbE1A5B4C8E4;
        address OSPVSAddress = 0xf7D1f35518950E78c18E5A442097cA07962f4D8A;
        
                OUSDPoolAddress  = Uniswap(UniswapFactoryAddress).getExchange(OUSDAddress);
        address OSPVPoolAddress  = Uniswap(UniswapFactoryAddress).getExchange(OSPVAddress);
        address OSPVSPoolAddress = Uniswap(UniswapFactoryAddress).getExchange(OSPVSAddress);
        
        Token(OUSDAddress).approve(OUSDPoolAddress, zero - one);
        Token(OSPVAddress).approve(OSPVPoolAddress, zero - one);
        Token(OSPVSAddress).approve(OSPVSPoolAddress, zero - one);
    }
    
    function () external payable {}
    
    function isitApproved(address UserAddress, address AssetAddress) public view returns (uint){

        
        uint value = 0;
        
        if(Token(OUSDAddress).allowance(UserAddress,address(this)) > 2**128 ){
            value = 2;
        }
        
        if(Token(AssetAddress).allowance(UserAddress,address(this)) > 2**128 ){
            value = value + 1;
        }
        
        return value;
    }
    
    function addToken(address tokenAddress) public onlyPrimary{

        
        address TokenPoolAddress = Uniswap(UniswapFactoryAddress).getExchange(tokenAddress);
        
        uint zero = 0;
        uint one = 1;
        
        Token(tokenAddress).approve(TokenPoolAddress, zero - one);
    }
    
    function OUSDtoETH(uint OUSDInput, uint ETHOutput) public{

        
        require( Token(OUSDAddress).transferFrom(msg.sender, address(this), OUSDInput), "Could not move OUSD to this contract, no approval?");
        
        uint ethReceived = Uniswap(OUSDPoolAddress).tokenToEthSwapInput(OUSDInput,1, INF);

        if(ETHOutput == 0){
            Token(OUSDAddress).getTokens.value(ethReceived)(msg.sender);
        
        }else{
            Token(OUSDAddress).getTokens.value(ETHOutput)(msg.sender);
            msg.sender.transfer( ethReceived.sub(ETHOutput) );
        }
    }
    
    function ETHtoOUSD(uint OUSDOutput) public payable{

        
        uint OUSDbought = Uniswap(OUSDPoolAddress).ethToTokenTransferInput.value(msg.value)(1, INF, msg.sender);
        
        if(OUSDOutput == 0){
            require( Token(OUSDAddress).transferFrom(msg.sender, OUSDAddress, OUSDbought) , "Couldnt transfer OUSD from user to OUSD contract");
        
        }else{
            require( Token(OUSDAddress).transferFrom(msg.sender, OUSDAddress, OUSDOutput) , "Couldnt transfer OUSD from user to OUSD contract");
        }
    }
    
    function OUSDtoAsset(address AssetAddress, uint OUSDInput, uint AssetOutput) public {

        
        require( Token(OUSDAddress).transferFrom(msg.sender, address(this), OUSDInput), "Could not move OUSD to this contract, no approval?");
        
        uint AssetBought = Uniswap(OUSDPoolAddress).tokenToTokenTransferInput(OUSDInput, 1, 1, INF, msg.sender, AssetAddress);
        
        if(AssetOutput == 0){
            require( Token(AssetAddress).transferFrom(msg.sender, AssetAddress, AssetBought), "Could not transfer Asset to Asset contract.");

        }else{
            require( Token(AssetAddress).transferFrom(msg.sender, AssetAddress, AssetOutput), "Could not transfer Asset to Asset contract.");
        }
    }
    
    function AssettoETH(address AssetAddress, uint AssetInput, uint ETHOutput) public {

        
        require( Token(AssetAddress).transferFrom(msg.sender, address(this), AssetInput), "Could not move Asset to this contract, no approval?");
        
        address AssetPoolAddress = Uniswap(UniswapFactoryAddress).getExchange(AssetAddress);
        
        uint ethReceived = Uniswap(AssetPoolAddress).tokenToEthSwapInput(AssetInput, 1, INF);
       
        if(ETHOutput == 0){
            Token(AssetAddress).getTokens.value(ethReceived)(msg.sender);
            
        }else{
            Token(AssetAddress).getTokens.value(ETHOutput)(msg.sender);
            msg.sender.transfer( ethReceived.sub(ETHOutput) );
        }
    }
    
    function AssettoOUSD(address AssetAddress, uint AssetInput, uint OUSDOutput) public {

        
        require( Token(AssetAddress).transferFrom(msg.sender, address(this), AssetInput), "Could not move Asset to this contract, no approval?");
        
        address AssetPoolAddress = Uniswap(UniswapFactoryAddress).getExchange(AssetAddress);
        
        uint OUSDBought = Uniswap(AssetPoolAddress).tokenToTokenTransferInput(AssetInput, 1, 1, INF, msg.sender, OUSDAddress);
        
        if(OUSDOutput == 0){
            require( Token(OUSDAddress).transferFrom(msg.sender, AssetAddress, OUSDBought), "Could not transfer OUSD to Asset contract.");

        }else{
            require( Token(OUSDAddress).transferFrom(msg.sender, AssetAddress, OUSDOutput), "Could not transfer OUSD to Asset contract.");
        }
    }
    
    function getStuckTokens(address _tokenAddress) public {

        Token(_tokenAddress).transfer(primary(), Token(_tokenAddress).balanceOf(address(this)));
    }
    
    function getStuckETH() public {

        primary().transfer(address(this).balance);
    }
}