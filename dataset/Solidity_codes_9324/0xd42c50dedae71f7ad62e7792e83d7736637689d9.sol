
pragma solidity ^0.4.19;


contract Owned
{

    address public owner;

    modifier onlyOwner
	{

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner()
	{

        owner = newOwner;
    }
}


contract Agricoin is Owned
{

    struct DividendPayout
    {
        uint amount;            // Value of dividend payout.
        uint momentTotalSupply; // Total supply in payout moment,
    }

    struct RedemptionPayout
    {
        uint amount;            // Value of redemption payout.
        uint momentTotalSupply; // Total supply in payout moment.
        uint price;             // Price of Agricoin in weis.
    }

    struct Balance
    {
        uint icoBalance;
        uint balance;                       // Agricoin balance.
        uint posibleDividends;              // Dividend number, which user can get.
        uint lastDividensPayoutNumber;      // Last dividend payout index, which user has gotten.
        uint posibleRedemption;             // Redemption value in weis, which user can use.
        uint lastRedemptionPayoutNumber;    // Last redemption payout index, which user has used.
    }

    modifier onlyPayer()
    {

        require(payers[msg.sender]);
        _;
    }
    
    modifier onlyActivated()
    {

        require(isActive);
        _;
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);    

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event Activate(bool icoSuccessful);

    event PayoutDividends(uint etherAmount, uint indexed id);

    event PayoutRedemption(uint etherAmount, uint indexed id, uint price);

    event GetUnpaid(uint etherAmount);

    event GetDividends(address indexed investor, uint etherAmount);

    function Agricoin(uint payout_period_start, uint payout_period_end, address _payer) public
    {

        owner = msg.sender;// Save the owner.

        payoutPeriodStart = payout_period_start;
        payoutPeriodEnd = payout_period_end;

        payers[_payer] = true;
    }

	function activate(bool icoSuccessful) onlyOwner() external returns (bool)
	{

		require(!isActive);// Check once activation.

        startDate = now;// Save activation date.
		isActive = true;// Make token active.
		owner = 0x00;// Set owner to null.
		
        if (icoSuccessful)
        {
            isSuccessfulIco = true;
            totalSupply += totalSupplyOnIco;
            Activate(true);// Call activation event.
        }
        else
        {
            Activate(false);// Call activation event.
        }

        return true;
	}

    function addPayer(address payer) onlyPayer() external
    {

        payers[payer] = true;
    }

	function balanceOf(address owner) public view returns (uint)
	{

		return balances[owner].balance;
	}

    function posibleDividendsOf(address owner) public view returns (uint)
    {

        return balances[owner].posibleDividends;
    }

    function posibleRedemptionOf(address owner) public view returns (uint)
    {

        return balances[owner].posibleRedemption;
    }

    function transfer(address _to, uint _value) onlyActivated() external returns (bool)
    {

        require(balanceOf(msg.sender) >= _value);

        recalculate(msg.sender);// Recalculate user's struct.
        
        if (_to != 0x00)// For normal transfer.
        {
            recalculate(_to);// Recalculate recipient's struct.

            balances[msg.sender].balance -= _value;
            balances[_to].balance += _value;

            Transfer(msg.sender, _to, _value);// Call transfer event.
        }
        else// For redemption transfer.
        {
            require(payoutPeriodStart <= now && now >= payoutPeriodEnd);// Check redemption period.
            
            uint amount = _value * redemptionPayouts[amountOfRedemptionPayouts].price;// Calculate amount of weis in redemption.

            require(amount <= balances[msg.sender].posibleRedemption);// Check redemption limits.

            balances[msg.sender].posibleRedemption -= amount;
            balances[msg.sender].balance -= _value;

            totalSupply -= _value;// Decrease total supply.

            msg.sender.transfer(amount);// Transfer redemption to user.

            Transfer(msg.sender, _to, _value);// Call transfer event.
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) onlyActivated() external returns (bool)
    {

        require(balances[_from].balance >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(_to != 0x00);

        recalculate(_from);
        recalculate(_to);

        balances[_from].balance -= _value;
        balances[_to].balance += _value;
        
        Transfer(_from, _to, _value);// Call tranfer event.
        
        return true;
    }

    function approve(address _spender, uint _value) onlyActivated() public returns (bool)
    {

        recalculate(msg.sender);
        recalculate(_spender);

        allowed[msg.sender][_spender] = _value;// Set allowed.
        
        Approval(msg.sender, _spender, _value);// Call approval event.
        
        return true;
    }

    function allowance(address _owner, address _spender) onlyActivated() external view returns (uint)
    {

        return allowed[_owner][_spender];
    }

    function mint(address _to, uint _value, bool icoMinting) onlyOwner() external returns (bool)
    {

        require(!isActive);// Check no activation.

        if (icoMinting)
        {
            balances[_to].icoBalance += _value;
            totalSupplyOnIco += _value;
        }
        else
        {
            balances[_to].balance += _value;// Increase user's balance.
            totalSupply += _value;// Increase total supply.

            Transfer(0x00, _to, _value);// Call transfer event.
        }
        
        return true;
    }

    function payDividends() onlyPayer() onlyActivated() external payable returns (bool)
    {

        require(now >= payoutPeriodStart && now <= payoutPeriodEnd);// Check payout period.

        dividendPayouts[amountOfDividendsPayouts].amount = msg.value;// Set payout amount in weis.
        dividendPayouts[amountOfDividendsPayouts].momentTotalSupply = totalSupply;// Save total supply on that moment.
        
        PayoutDividends(msg.value, amountOfDividendsPayouts);// Call dividend payout event.

        amountOfDividendsPayouts++;// Increment dividend payouts amount.

        return true;
    }

    function payRedemption(uint price) onlyPayer() onlyActivated() external payable returns (bool)
    {

        require(now >= payoutPeriodStart && now <= payoutPeriodEnd);// Check payout period.

        redemptionPayouts[amountOfRedemptionPayouts].amount = msg.value;// Set payout amount in weis.
        redemptionPayouts[amountOfRedemptionPayouts].momentTotalSupply = totalSupply;// Save total supply on that moment.
        redemptionPayouts[amountOfRedemptionPayouts].price = price;// Set price of Agricoin in weis at this redemption moment.

        PayoutRedemption(msg.value, amountOfRedemptionPayouts, price);// Call redemption payout event.

        amountOfRedemptionPayouts++;// Increment redemption payouts amount.

        return true;
    }

    function getUnpaid() onlyPayer() onlyActivated() external returns (bool)
    {

        require(now >= payoutPeriodEnd);// Check end payout period.

        GetUnpaid(this.balance);// Call getting unpaid ether event.

        msg.sender.transfer(this.balance);// Transfer all ethers back to payer.

        return true;
    }

    function recalculate(address user) onlyActivated() public returns (bool)
    {

        if (isSuccessfulIco)
        {
            if (balances[user].icoBalance != 0)
            {
                balances[user].balance += balances[user].icoBalance;
                Transfer(0x00, user, balances[user].icoBalance);
                balances[user].icoBalance = 0;
            }
        }

        if (balances[user].lastDividensPayoutNumber == amountOfDividendsPayouts &&
            balances[user].lastRedemptionPayoutNumber == amountOfRedemptionPayouts)
        {
            return true;
        }

        uint addedDividend = 0;

        for (uint i = balances[user].lastDividensPayoutNumber; i < amountOfDividendsPayouts; i++)
        {
            addedDividend += (balances[user].balance * dividendPayouts[i].amount) / dividendPayouts[i].momentTotalSupply;
        }

        balances[user].posibleDividends += addedDividend;
        balances[user].lastDividensPayoutNumber = amountOfDividendsPayouts;

        uint addedRedemption = 0;

        for (uint j = balances[user].lastRedemptionPayoutNumber; j < amountOfRedemptionPayouts; j++)
        {
            addedRedemption += (balances[user].balance * redemptionPayouts[j].amount) / redemptionPayouts[j].momentTotalSupply;
        }

        balances[user].posibleRedemption += addedRedemption;
        balances[user].lastRedemptionPayoutNumber = amountOfRedemptionPayouts;

        return true;
    }

    function () external payable
    {
        if (payoutPeriodStart >= now && now <= payoutPeriodEnd)// Check payout period.
        {
            if (posibleDividendsOf(msg.sender) > 0)// Check posible dividends.
            {
                uint dividendsAmount = posibleDividendsOf(msg.sender);// Get posible dividends amount.

                GetDividends(msg.sender, dividendsAmount);// Call getting dividends event.

                balances[msg.sender].posibleDividends = 0;// Set balance to zero.

                msg.sender.transfer(dividendsAmount);// Transfer dividends amount.
            }
        }
    }

    string public constant name = "Agricoin";
    
    string public constant symbol = "AGR";
    
    uint public constant decimals = 2;

    uint public totalSupply;

    uint public totalSupplyOnIco;
       
    uint public startDate;
    
    uint public payoutPeriodStart;
    
    uint public payoutPeriodEnd;
    
    uint public amountOfDividendsPayouts = 0;

    uint public amountOfRedemptionPayouts = 0;

    mapping (uint => DividendPayout) public dividendPayouts;
    
    mapping (uint => RedemptionPayout) public redemptionPayouts;

    mapping (address => bool) public payers;

    mapping (address => Balance) public balances;

    mapping (address => mapping (address => uint)) public allowed;

    bool public isActive = false;

    bool public isSuccessfulIco = false;
}