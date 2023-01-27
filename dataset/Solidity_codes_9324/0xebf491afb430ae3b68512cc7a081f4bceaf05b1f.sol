
pragma solidity ^0.4.21;


contract KujiraBro 
{

    

    modifier onlyOwner()
    {

        require(msg.sender == owner);
        _;
    }
    
    modifier notPoC(address aContract)
    {

        require(aContract != address(pocContract));
        _;
    }
   
    event Deposit(uint256 amount, address depositer);
    event Purchase(uint256 amountSpent);
    event Sell(uint256 tokensSold);
    event Transfer(uint256 amount, address paidTo);

    address owner;
    address RandDWallet;
    uint256 tokenBalance;
    PoC pocContract;
    uint256 minimumTokenBalance;
    uint256 maximumTokenBalance = 5000e18; //5000 tokens
    uint256 tokensToSell = 2500; 
    uint256 RandDFee = 1;
   
    
    constructor(address RDWallet) 
    public 
    {
        owner = msg.sender;
        RandDWallet = RDWallet;
        pocContract = PoC(address(0x1739e311ddBf1efdFbc39b74526Fd8b600755ADa));
        tokenBalance = 0;
    }
    
    function() payable public { }
     
    function donate() 
    public payable 
    {

        require(msg.value > 1000000 wei);
        uint256 ethToRandD = address(this).balance / 100;
        uint256 ethToTransfer = address(this).balance - ethToRandD;
        uint256 PoCEthInContract = address(pocContract).balance;

        RandDWallet.transfer(ethToRandD);
       
        if(PoCEthInContract < 5 ether)
        {
            pocContract.exit();
            tokenBalance = 0;

            owner.transfer(ethToTransfer);
            emit Transfer(ethToTransfer, address(owner));
        }

        else 
        {
            tokenBalance = myTokens();

            if(tokenBalance > maximumTokenBalance)
            {
                pocContract.sell(tokenBalance - tokensToSell);
                pocContract.withdraw();
                tokenBalance = myTokens(); 
                emit Sell(tokenBalance - tokensToSell);
            }
            else 
            {   
                if(ethToTransfer > 0)
                {
                    pocContract.buy.value(ethToTransfer)(0x0);
                    emit Purchase(ethToTransfer);
                }
            }
        }

        emit Deposit(msg.value, msg.sender);
    }

    
    function myTokens() 
    public 
    view 
    returns(uint256)
    {

        return pocContract.myTokens();
    }
    
    function myDividends() 
    public 
    view 
    returns(uint256)
    {

        return pocContract.myDividends(true);
    }

    function ethBalance() 
    public 
    view 
    returns (uint256)
    {

        return address(this).balance;
    }

    function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens) 
    public 
    onlyOwner() 
    notPoC(tokenAddress) 
    returns (bool success) 
    {

        return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
    }
    
    function updateMaxTokenLimit(uint256 amount)
    public
    onlyOwner()
    {

        maximumTokenBalance = amount;
    }

    function updateTokenSellAmount(uint256 amount)
    public
    onlyOwner()
    {

        tokensToSell = amount;
    }

    function sellTokensNow(uint256 tokensToSell)
    public
    onlyOwner()
    {

        require(myTokens() >= tokensToSell);

        pocContract.sell(tokensToSell);
        pocContract.withdraw();

        emit Sell(tokensToSell);
    }
}

contract PoC 
{

    function buy(address) public payable returns(uint256);

    function exit() public;

    function sell(uint256) payable public;

    function withdraw() public;

    function myTokens() public view returns(uint256);

    function myDividends(bool) public view returns(uint256);

    function totalEthereumBalance() public view returns(uint);

}

contract ERC20Interface 
{

    function transfer(address to, uint256 tokens) 
    public 
    returns (bool success);

}