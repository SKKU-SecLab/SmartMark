
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

contract EIP20Interface {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


    function approve(address _spender, uint256 _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20 is EIP20Interface {


    uint256 constant MAX_UINT256 = 2**256 - 1;

    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

     function EIP20(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {

        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {

        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
    view public returns (uint256 remaining) {

      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract Gabicoin is Owned, EIP20
{

    struct IcoBalance
    {
        bool hasTransformed;// Has transformed ico balances to real balance for this user?
        uint[3] balances;// Balances.
    }

    event Mint(address indexed to, uint value, uint phaseNumber);

    event Activate();

    function Gabicoin() EIP20(0, "Gabicoin", 2, "GCO") public
    {

        owner = msg.sender;
    }

    function mint(address to, uint value, uint phase) onlyOwner() external
    {

        require(!isActive);

        icoBalances[to].balances[phase] += value;// Increase ICO balance.

        Mint(to, value, phase);
    }

    function activate(bool i0, bool i1, bool i2) onlyOwner() external
    {

        require(!isActive);// Only for not yet activated token.

        activatedPhases[0] = i0;
        activatedPhases[1] = i1;
        activatedPhases[2] = i2;

        Activate();
        
        isActive = true;// Activate token.
    }

    function transform(address addr) public
    {

        require(isActive);// Only after activation.
        require(!icoBalances[addr].hasTransformed);// Only for not transfromed structs.

        for (uint i = 0; i < 3; i++)
        {
            if (activatedPhases[i])// Check phase activation.
            {
                balances[addr] += icoBalances[addr].balances[i];// Increase balance.
                Transfer(0x00, addr, icoBalances[addr].balances[i]);
                icoBalances[addr].balances[i] = 0;// Set ico balance to zero.
            }
        }

        icoBalances[addr].hasTransformed = true;// Set struct to transformed status.
    }

    function () payable external
    {
        transform(msg.sender);
        msg.sender.transfer(msg.value);
    }

    bool[3] public activatedPhases;

    bool public isActive;

    mapping (address => IcoBalance) public icoBalances;
}

contract Bounty is Owned
{

    event GetBounty(address indexed bountyHunter, uint amount);

    event AddBounty(address indexed bountyHunter, uint amount);

    function Bounty(address gabicoinAddress) public
    {

        owner = msg.sender;
        token = gabicoinAddress;
    }

    function addBountyForHunter(address hunter, uint bounty) onlyOwner() external returns (bool)
    {

        require(!Gabicoin(token).isActive());// Check token activity.

        bounties[hunter] += bounty;// Increase bounty for hunter.
        bountyTotal += bounty;// Increase total bounty value.

        AddBounty(hunter, bounty);// Call add bounty event.

        return true;
    }

    function getBounty() external returns (uint)
    {

        require(Gabicoin(token).isActive());// Check token activity.
        require(bounties[msg.sender] != 0);// Check balance of bounty hunter.
        
        if (Gabicoin(token).transfer(msg.sender, bounties[msg.sender]))// Transfer bounty tokens to bounty hunter.
        {
            uint amount = bounties[msg.sender];
            bountyTotal -= amount;// Decrease total bounty.

            GetBounty(msg.sender, amount);// Get bounty event.
            
            bounties[msg.sender] = 0;// Set bounty for hunter to zero.

            return amount;
        }
        else
        {
            return 0;
        }
    }

    mapping (address => uint) public bounties;

    uint public bountyTotal = 0;

    address public token;
}

contract Ico is Owned
{

    enum State
    {
        Runned,
        Paused,
        Finished,
        Failed
    }

    event Refund(address indexed investor, uint value);

    event UpdateState(State oldState, State newState);

    event Activate();

    event BuyTokens(address indexed buyer, uint value, uint indexed phaseNumber);

    event GetEthereum(address indexed recipient, uint value);

    function Ico(address _token, address _bounty, uint[3] _startDates, uint[3] _endDates, uint[3] _prices, uint[3] _hardCaps) public
    {

        owner = msg.sender;
        token = _token;
        bounty = _bounty;

        for (uint i = 0; i < 3; i++)
        {
            startDates[i] = _startDates[i];
            endDates[i] = _endDates[i];
            prices[i] = _prices[i];
            hardCaps[i] = _hardCaps[i];
        }

        state = State.Runned;
    }

    function isPhase(uint number, uint date) view public returns (bool)
    {

        return startDates[number] <= date && date <= endDates[number];
    }

    function preIcoWasSuccessful() view public returns (bool)
    {

        return ((totalInvested[0] / prices[0]) / 2 >= preIcoSoftCap);
    }

    function icoWasSuccessful() view public returns (bool)
    {

        return ((totalInvested[1] / prices[1]) + (totalInvested[2] * 5 / prices[2] / 4) >= icoSoftCap);
    }

    function refund() public
    {

        uint amount = 0;

        if (state == State.Failed)// Check failed state.
        {
            if (!preIcoCashedOut)// Check cash out from ICO.
            {
                amount += invested[msg.sender][0];// Add Pre-ICO funds.
                invested[msg.sender][0] = 0;// Set Pre-ICO funds to zero.
            }

            amount += invested[msg.sender][1];
            amount += invested[msg.sender][2];
            
            invested[msg.sender][1] = 0;
            invested[msg.sender][2] = 0;
            
            Refund(msg.sender, amount);

            msg.sender.transfer(amount);// Send funds.
        }
        else if (state == State.Finished)// Check finished state.
        {
            if (!preIcoWasSuccessful())
            {
                amount += invested[msg.sender][0];// Add Pre-ICO funds.
                invested[msg.sender][0] = 0;// Set Pre-ICO funds to zero.
            }

            if (!icoWasSuccessful())
            {
                amount += invested[msg.sender][1];
                amount += invested[msg.sender][2];

                invested[msg.sender][1] = 0;
                invested[msg.sender][2] = 0;
            }
            
            Refund(msg.sender, amount);

            msg.sender.transfer(amount);// Send funds.
        }
        else
        {
            revert();
        }
    }

    function updateState() public
    {

        require(state == State.Runned);

        if (now >= endDates[2])// ICO and Pre-ICO softcaps have achieved.
        {
            if (preIcoWasSuccessful() || icoWasSuccessful())
            {
                UpdateState(state, State.Finished);
                state = State.Finished;
            }
            else
            {
                UpdateState(state, State.Failed);
                state = State.Failed;
            }
        }
    }
    
    function activate() public
    {

        require(!Gabicoin(token).isActive());// Check token activity.
        require(state == State.Finished);// Check state.

        Activate();

        Gabicoin(token).mint(bounty, 3 * 100 * 10 ** 6, preIcoWasSuccessful() ? 0 : 1);

        Gabicoin(token).activate(preIcoWasSuccessful(), icoWasSuccessful(), icoWasSuccessful());// Activate Gabicoin.
    }

    function () payable external
    {
        if (state == State.Failed)// Check state for Failed or Expired states.
        {
            refund();// Refund invested funds for sender.
            return;
        }
        else if (state == State.Finished)// Check finished state.
        {
            refund();// Refund invested funds for sender.
            return;
        }
        else if (state == State.Runned)// Check runned state.
        {
            if (isPhase(0, now))
            {
                buyTokens(msg.sender, msg.value, 0);
            }
            else if (isPhase(1, now))
            {
                buyTokens(msg.sender, msg.value, 1);
            }
            else if (isPhase(2, now))
            {
                buyTokens(msg.sender, msg.value, 2);
            }
            else
            {
                msg.sender.transfer(msg.value);
            }

            updateState();// Update ICO state after payable transactions.
        }
        else
        {
            msg.sender.transfer(msg.value);
        }
    }

    function buyTokens(address buyer, uint value, uint phaseNumber) internal
    {

        require(totalInvested[phaseNumber] < hardCaps[phaseNumber]);// Check investment posibility.

        uint amount;
        uint rest;

        if (totalInvested[phaseNumber] + value / prices[phaseNumber] > hardCaps[phaseNumber])
        {
            rest = hardCaps[phaseNumber] * prices[phaseNumber] - totalInvested[phaseNumber];
        }
        else
        {
            rest = value % prices[phaseNumber];
        }

        amount = value - rest;
        require(amount > 0);
        invested[buyer][phaseNumber] += amount;
        totalInvested[phaseNumber] += amount;
        BuyTokens(buyer, amount, phaseNumber);
        Gabicoin(token).mint(buyer, amount / prices[phaseNumber], phaseNumber);
        msg.sender.transfer(rest);// Return changes.
    }

    function pauseIco() onlyOwner() external
    {

        require(state == State.Runned);// Only from Runned state.
        UpdateState(state, State.Paused);
        state = State.Paused;// Set state to Paused.
    }

    function continueIco() onlyOwner() external
    {

        require(state == State.Paused);// Only from Paused state.
        UpdateState(state, State.Runned);
        state = State.Runned;// Set state to Runned.
    }

    function endIco() onlyOwner() external
    {

        require(state == State.Paused);// Only from Paused state.
        UpdateState(state, State.Failed);
        state = State.Failed;// Set state to Expired.
    }

    function getPreIcoFunds() onlyOwner() external returns (uint)
    {

        require(state != State.Failed && state != State.Paused);// Check state.
        require(now >= endDates[0]);// Check ending of Pre-ICO.
        require(!preIcoCashedOut);// Check cash out from Pre-ICO.

        if (preIcoWasSuccessful())
        {
            uint value = totalInvested[0];
            preIcoCashedOut = true;
            msg.sender.transfer(value);
            GetEthereum(msg.sender, value);
            return value;
        }

        return 0;
    }

    function getEtherum() onlyOwner() external returns (uint)
    {

        require(state == State.Finished);// Check state.
        require(now >= endDates[2]);// Check end of ICO.

        if (icoWasSuccessful())
        {
            uint value = totalInvested[1] + totalInvested[2];
            msg.sender.transfer(value);
            GetEthereum(msg.sender, value);
            return value;
        }
        
        return 0;
    }

    State public state;

    mapping (address => uint[3]) public invested;

    uint[3] public totalInvested;

    uint public preIcoSoftCap = 2 * 100 * 10 ** 5;

    uint public icoSoftCap = 100 * 10 ** 6;

    address public bounty;

    address public token;

    uint[3] public startDates;

    uint[3] public endDates;

    uint[3] public prices;

    uint[3] public hardCaps;

    bool public preIcoCashedOut;
}