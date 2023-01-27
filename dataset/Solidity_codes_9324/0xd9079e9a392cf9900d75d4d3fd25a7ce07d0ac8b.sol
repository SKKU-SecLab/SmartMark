
pragma solidity 0.5.11; /*

    ___________________________________________________________________
      _      _                                        ______           
      |  |  /          /                                /              
    --|-/|-/-----__---/----__----__---_--_----__-------/-------__------
      |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
    __/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_
    
    
███████╗███╗░░░███╗░█████╗░██████╗░██╗░░██╗███████╗████████╗████████╗░█████╗░██╗░░██╗███████╗███╗░░██╗
██╔════╝████╗░████║██╔══██╗██╔══██╗██║░██╔╝██╔════╝╚══██╔══╝╚══██╔══╝██╔══██╗██║░██╔╝██╔════╝████╗░██║
█████╗░░██╔████╔██║███████║██████╔╝█████═╝░█████╗░░░░░██║░░░░░░██║░░░██║░░██║█████═╝░█████╗░░██╔██╗██║
██╔══╝░░██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗░██╔══╝░░░░░██║░░░░░░██║░░░██║░░██║██╔═██╗░██╔══╝░░██║╚████║
███████╗██║░╚═╝░██║██║░░██║██║░░██║██║░╚██╗███████╗░░░██║░░░░░░██║░░░╚█████╔╝██║░╚██╗███████╗██║░╚███║
╚══════╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝░░░╚═╝░░░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝

                
*/ 

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

    
contract owned {

    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
 
    
contract eMarketToken is owned {

    

    using SafeMath for uint256;
    string constant public name = "eMarket Token";
    string constant public symbol = "EFI";
    uint256 constant public decimals = 18;
    uint256 public totalSupply = 1000000000 * (10**decimals);   //1 billion tokens
    bool public safeguard = false;  //putting safeguard on will halt all non-owner functions
    bool public tokenSwap = false;  //when tokenSwap is on then all the token transfer to contract will trigger token swap

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);
        
    event FrozenAccounts(address target, bool frozen);
    
    event Approval(address indexed from, address indexed spender, uint256 value);

    event TokenSwap(address indexed user, uint256 value);


    function _transfer(address _from, address _to, uint _value) internal {

        
        require(!safeguard);
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);
        
        if(tokenSwap && _to == address(this)){
            emit TokenSwap(msg.sender, _value);
        }
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        require(!safeguard);
        require(balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    constructor() public{
        balanceOf[owner] = totalSupply;
        
        emit Transfer(address(0), owner, totalSupply);
    }
    
    function () external payable {
        
        buyTokens();
    }

    function burn(uint256 _value) public returns (bool success) {

        require(!safeguard);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);  // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(!safeguard);
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value); // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                                   // Update totalSupply
        emit  Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
        
    function freezeAccount(address target, bool freeze) onlyOwner public {

            frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }

    
    function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner{

        _transfer(address(this), owner, tokenAmount);
    }
    
    function manualWithdrawEther()onlyOwner public{

        address(owner).transfer(address(this).balance);
    }
    
    function changeSafeguardStatus() onlyOwner public{

        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;    
        }
    }
    
    function changeTokenSwapStatus() public onlyOwner{

        if (tokenSwap == false){
            tokenSwap = true;
        }
        else{
            tokenSwap = false;    
        }
    }
    
    
    bool public passiveAirdropStatus;
    uint256 public passiveAirdropTokensAllocation;
    uint256 public airdropAmount;  //in wei
    uint256 public passiveAirdropTokensSold;
    mapping(uint256 => mapping(address => bool)) public airdropClaimed;
    uint256 internal airdropClaimedIndex;
    uint256 public airdropFee = 0.05 ether;
    
    function startNewPassiveAirDrop(uint256 passiveAirdropTokensAllocation_, uint256 airdropAmount_  ) public onlyOwner {

        passiveAirdropTokensAllocation = passiveAirdropTokensAllocation_;
        airdropAmount = airdropAmount_;
        passiveAirdropStatus = true;
    } 
    
    function stopPassiveAirDropCompletely() public onlyOwner{

        passiveAirdropTokensAllocation = 0;
        airdropAmount = 0;
        airdropClaimedIndex++;
        passiveAirdropStatus = false;
    }
    
    function claimPassiveAirdrop() public payable returns(bool) {

        require(airdropAmount > 0, 'Token amount must not be zero');
        require(passiveAirdropStatus, 'Airdrop is not active');
        require(passiveAirdropTokensSold <= passiveAirdropTokensAllocation, 'Airdrop sold out');
        require(!airdropClaimed[airdropClaimedIndex][msg.sender], 'user claimed airdrop already');
        require(!isContract(msg.sender),  'No contract address allowed to claim airdrop');
        require(msg.value >= airdropFee, 'Not enough ether to claim this airdrop');
        
        _transfer(address(this), msg.sender, airdropAmount);
        passiveAirdropTokensSold += airdropAmount;
        airdropClaimed[airdropClaimedIndex][msg.sender] = true; 
        return true;
    }
    
    function changePassiveAirdropAmount(uint256 newAmount) public onlyOwner{

        airdropAmount = newAmount;
    }
    
    function isContract(address _address) public view returns (bool){

        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
    
    function updateAirdropFee(uint256 newFee) public onlyOwner{

        airdropFee = newFee;
    }
    
    function airdropACTIVE(address[] memory recipients,uint256 tokenAmount) public onlyOwner {

        require(recipients.length <= 150);
        uint256 totalAddresses = recipients.length;
        for(uint i = 0; i < totalAddresses; i++)
        {
          _transfer(address(this), recipients[i], tokenAmount);
        }
    }
    
    bool public whitelistingStatus;
    mapping (address => bool) public whitelisted;
    
    function changeWhitelistingStatus() onlyOwner public{

        if (whitelistingStatus == false){
            whitelistingStatus = true;
        }
        else{
            whitelistingStatus = false;    
        }
    }
    
    function whitelistUser(address userAddress) onlyOwner public{

        require(whitelistingStatus == true);
        require(userAddress != address(0));
        whitelisted[userAddress] = true;
    }
    
    function whitelistManyUsers(address[] memory userAddresses) onlyOwner public{

        require(whitelistingStatus == true);
        uint256 addressCount = userAddresses.length;
        require(addressCount <= 150);
        for(uint256 i = 0; i < addressCount; i++){
            whitelisted[userAddresses[i]] = true;
        }
    }
    
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {

        sellPrice = newSellPrice;   //sellPrice is 1 Token = ?? WEI
        buyPrice = newBuyPrice;     //buyPrice is 1 ETH = ?? Tokens
    }

    
    function buyTokens() payable public {

        uint amount = msg.value * buyPrice;                 // calculates the amount
        _transfer(address(this), msg.sender, amount);       // makes the transfers
    }

    function sellTokens(uint256 amount) public {

        uint256 etherAmount = amount * sellPrice/(10**decimals);
        require(address(this).balance >= etherAmount);   // checks if the contract has enough ether to buy
        _transfer(msg.sender, address(this), amount);           // makes the transfers
        msg.sender.transfer(etherAmount);                // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
}