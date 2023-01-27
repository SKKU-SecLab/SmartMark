
pragma solidity 0.4.18;


library SafeMath {


    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        } 
        uint256 c = a * b; 
        assert(c / a == b); 
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b; 
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a); 
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b; 
        assert(c >= a); 
        return c;
    }
}

contract respectingBitcoin {

    using SafeMath for uint256;
    

    uint8 public decimals;
    
    address public owner;
    
    address public fifthOpera;
    
    uint256 public supplyCap;
    uint256 public totalSupply;
    
    bool private mintable = true;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) internal allowed;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Mintable(address indexed from, bool enabled);
    event OwnerChanged(address newOwner);
    event ContractChanged(address indexed from, address newContract);


    modifier oO(){

        require(msg.sender == owner);
        _;
    }
    
    modifier oOOrContract(){

        require(msg.sender == owner || msg.sender == fifthOpera); 
        _;
    }
    
    modifier onlyMintable() {

        require(mintable); 
        _;
    }
    
    
    function respectingBitcoin(uint256 _supplyCap, uint8 _decimals) public {

        owner = msg.sender; 
        decimals = _decimals;
        supplyCap = _supplyCap * (10 ** uint256(decimals));
    }
    

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0)); 
        require(_value <= balances[msg.sender]); 
        
        balances[msg.sender] = balances[msg.sender].sub(_value); 
        balances[_to] = balances[_to].add(_value); 
        
        Transfer(msg.sender, _to, _value); 
        return true;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_to != address(0)); 
        require(_value <= balances[_from]); 
        require(_value <= allowed[_from][msg.sender]); 
        
        balances[_from] = balances[_from].sub(_value); 
        balances[_to] = balances[_to].add(_value); 
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); 
        
        Transfer(_from, _to, _value); 
        return true;
    }
   
    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value; 
        
        Approval(msg.sender, _spender, _value); 
        return true;
    }
   
    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];
    }
  
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue); 
        
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
        return true;
    }
  
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowed[msg.sender][_spender]; 
        
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        } 
        
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
        return true;
    }
  
    function mint(address _to, uint256 _amount) public oOOrContract onlyMintable returns (bool) {

        require(totalSupply.add(_amount) <= supplyCap); 
        
        totalSupply = totalSupply.add(_amount); 
        balances[_to] = balances[_to].add(_amount); 
        Mint(_to, _amount); 
        
        Transfer(address(0), _to, _amount); 
        return true;
    }
  
    function burn(uint256 _value) external {

        require(_value <= balances[msg.sender]); 
        
        address burner = msg.sender; 
        balances[burner] = balances[burner].sub(_value); 
        totalSupply = totalSupply.sub(_value);
        
        Burn(msg.sender, _value);
    }
    
    function setMintable(bool _isMintable) external oO {

        mintable = _isMintable;
        
        Mintable(msg.sender, _isMintable);
    }
    
    function setOwner(address _newOwner) external oO {

        require(_newOwner != address(0)); 
        
        owner = _newOwner;
        
        OwnerChanged(_newOwner);
    }
  
    function setContract(address _newContract) external oO {

        require(_newContract != address(0)); 
        
        fifthOpera = _newContract; 
        
        ContractChanged(msg.sender, _newContract);
    }
}

contract FIFTH is respectingBitcoin(20968750, 15) {

    
    
    string public constant name = "fifth";
    string public constant symbol = "FIFTH";
}

contract OPERA is respectingBitcoin(3355, 8) {

    
    
    string public constant name = "opera";
    string public constant symbol = "OPERA";
}

contract FifthOpera {

    using SafeMath for uint256;
    

    FIFTH public fifth;
    OPERA public opera;
    
    string public constant NAME = "FIFTH OPERA";
    
    address public wallet;
    address public owner;
    
    uint8 public plot;
    
    uint256 public eta;
    
    uint24[3] public plotValue = [16775000,1000,4192750];

    uint256 public funds;
    
    uint128 internal constant WAD = 10 ** 18;

    mapping (uint8 => uint256) public plotTotal;
    mapping (uint8 => mapping (address => uint256)) public contribution;
    mapping (uint8 => mapping (address => bool)) public claimed;
    
    
    event OwnerChanged(address newOwner);
    event WalletChanged(address newWallet);
    
    event FundsCollected(address indexed to, uint256 amount);
    event FundsForwarded(address indexed to, uint256 amount);
    
    event PioneerContribution(address indexed to, uint256 amount);
    event PatronContribution(address indexed to, uint256 amount);
    event ExcessTransferred(address indexed to, uint256 amount);
    
    event Donated(address indexed from, uint256 FIFTH, uint256  OPERA);
    event Claimed(address indexed to, uint256 amount);
    
    
    modifier oO() {

        require(msg.sender == owner); 
        _;
    }
    
    
    function FifthOpera(address _baseToken, address _bonusToken) public {

        fifth = FIFTH(_baseToken); 
        opera = OPERA(_bonusToken); 
        owner = msg.sender;
    }
    

    function cast(uint256 x) private pure returns (uint128 z) {

        assert((z = uint128(x)) == x);
    }
    
    function wdiv(uint128 x, uint128 y) private pure returns (uint128 z) {

        z = cast((uint256(x) * WAD + y / 2) / y);
    }
    
    function wmul(uint128 x, uint128 y) private pure returns (uint128 z) {

        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {

        return a < b ? a : b;
    }
   
    function max(uint256 a, uint256 b) private pure returns (uint256) {

        return a > b ? a : b;
    }
    
    function () external payable {
        buyTokens(msg.sender);
    }
    
    function buyTokens(address _beneficiary) public payable {

        require(_beneficiary != address(0)); 
        require(msg.value != 0); 
        
        if (plot == 0) {
            pioneer(_beneficiary);
        } else {
            patron(_beneficiary);
        }
    }
    
    function pioneer(address _beneficiary) internal {

        
        uint256 bonusRate = 2;
        uint256 baseRate = 10000;
        
        uint256 excess;
        uint256 participation = msg.value; 
        
        uint256 maxEther = 1677.5 ether;

        if (plotTotal[0] + participation > maxEther) {
            excess = participation.sub(maxEther.sub(plotTotal[0])); 
            participation = participation.sub(excess); 
            plot++; 
            eta = now.add(24 hours);
        } 
        
        funds = funds.add(participation); 
        plotTotal[0] = plotTotal[0].add(participation); 
        
        uint256 bonus = participation.div(10 ** 10).mul(bonusRate); 
        uint256 base = participation.div(10 ** 3).mul(baseRate);
        
        if (excess > 0) {
            excessTransfer(_beneficiary, excess);
        } 
        else forwardFunds(); 
        
        opera.mint(_beneficiary, bonus); 
        fifth.mint(_beneficiary, base);
        
        PioneerContribution(_beneficiary, participation);
    }
    
    function excessTransfer(address _beneficiary, uint256 _amount) internal {

        uint256 participation = _amount;
        
        funds = funds.add(participation);
        plotTotal[plot] = plotTotal[plot].add(participation);
        contribution[plot][_beneficiary] = contribution[plot][_beneficiary].add(participation); 
        
        ExcessTransferred(_beneficiary, _amount);
    }
    
    function patron(address _beneficiary) internal {

        if (now > eta) {
            plot++; 
            eta = now.add(24 hours);
        } 
        
        uint256 participation = msg.value; 
        
        funds = funds.add(participation); 
        plotTotal[plot] = plotTotal[plot].add(participation); 
        contribution[plot][_beneficiary] = contribution[plot][_beneficiary].add(participation); 
        
        forwardFunds(); 
        
        PatronContribution(_beneficiary, participation);
    }
    
    function donate(uint256 _amount) public {

        require(plot >= 0);
        require(_amount > 0);
        require(opera.totalSupply() < opera.supplyCap());
        
        uint256 donation = _amount;
        uint256 donationConversion = donation.div(10**14) ;
        uint256 donationRate = 20000;
        
        uint256 reward = donationConversion.div(donationRate).mul(10**7);
        uint256 excess;
        
        if (opera.totalSupply() + reward > opera.supplyCap()) {
            excess = reward.sub(opera.supplyCap()); 
            donation = donation.sub(excess); 
        }
        require(fifth.transferFrom(msg.sender, address(this), donation));
        opera.mint(msg.sender, reward);
        
        Donated(msg.sender, donation, reward);
    }
    
    function donations() public view returns (uint) {

        return (fifth.balanceOf(address(this)));
    }
    
    function claim(uint8 _day, address _beneficiary) public {

        assert(plot > _day); 
        
        if (claimed[_day][_beneficiary] || plotTotal[_day] == 0) {
            return;
        } 
        var dailyTotal = cast(plotTotal[_day]); 
        var userTotal = cast(contribution[_day][_beneficiary]); 
        var price = wdiv(cast(uint256(plotValue[_day]) * (10 ** uint256(15))), dailyTotal); 
        var reward = wmul(price, userTotal); 
        
        claimed[_day][_beneficiary] = true; 
        fifth.mint(_beneficiary, reward);
        
        Claimed(_beneficiary, reward);
    }
    
    function claimEverything(address _beneficiary) public {

        for (uint8 i = 1; i < plot; i++) {
            claim(i, _beneficiary);
        }
    }

    function forwardFunds() internal {

        wallet.transfer(msg.value);
        
        FundsForwarded(wallet, msg.value);
    }
    
    function setOwner(address _newOwner) external oO {

        require(_newOwner != address(0)); 
        owner = _newOwner;
        
        OwnerChanged(_newOwner);
    }
    
    function setWallet(address _newWallet) external oO {

        require(_newWallet != address(0)); 
        wallet = _newWallet;
        
        WalletChanged(_newWallet);
    }
    
    function collectFunds() external oO {

        wallet.transfer(this.balance);
        
        FundsCollected(wallet, this.balance);
    }
}

contract Distributor {

    
    
    FifthOpera public fifthOpera;
    
    
    function Distributor(FifthOpera _setAddress) public {

        fifthOpera = _setAddress;
    }
    
    
    function () external payable {
        fifthOpera.claimEverything(msg.sender); 
        
        if(msg.value > 0) 
        msg.sender.transfer(msg.value);
    }
}