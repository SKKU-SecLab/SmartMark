
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