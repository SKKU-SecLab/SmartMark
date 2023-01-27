



pragma solidity ^0.5.0;

contract Owned {

	modifier only_owner { require (msg.sender == owner, "Only owner"); _; }


	event NewOwner(address indexed old, address indexed current);

	function setOwner(address _new) public only_owner { emit NewOwner(owner, _new); owner = _new; }


	address public owner;
}

contract FrozenToken is Owned {

	event Transfer(address indexed from, address indexed to, uint256 value);

	struct Account {
		uint balance;
		bool liquid;
	}

	constructor(uint _totalSupply, address _owner)
        public
		when_non_zero(_totalSupply)
	{
		totalSupply = _totalSupply;
		owner = _owner;
		accounts[_owner].balance = totalSupply;
		accounts[_owner].liquid = true;
	}

	function balanceOf(address _who) public view returns (uint256) {

		return accounts[_who].balance;
	}

	function makeLiquid(address _to)
		public
		when_liquid(msg.sender)
		returns(bool)
	{

		accounts[_to].liquid = true;
		return true;
	}

	function transfer(address _to, uint256 _value)
		public
		when_owns(msg.sender, _value)
		when_liquid(msg.sender)
		returns(bool)
	{

		emit Transfer(msg.sender, _to, _value);
		accounts[msg.sender].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	function() external {
		assert(false);
	}

	modifier when_owns(address _owner, uint _amount) {

		require (accounts[_owner].balance >= _amount);
		_;
	}

	modifier when_liquid(address who) {

		require (accounts[who].liquid);
		_;
	}

	modifier when_non_zero(uint _value) {

		require (_value > 0);
		_;
	}

	uint public totalSupply;

	mapping (address => Account) accounts;

	string public constant name = "DOT Allocation Indicator";
	string public constant symbol = "DOT";
	uint8 public constant decimals = 3;
}


pragma solidity 0.5.13;


contract Claims is Owned {


    uint constant public UINT_MAX =  115792089237316195423570985008687907853269984665640564039457584007913129639935;

    struct Claim {
        uint    index;          // Index for short address.
        bytes32 pubKey;         // x25519 public key.
        bool    hasIndex;       // Has the index been set?
        uint    vested;         // Amount of allocation that is vested.
    }

    FrozenToken public allocationIndicator; // 0xb59f67A8BfF5d8Cd03f6AC17265c550Ed8F33907

    uint public nextIndex;

    mapping (address => Claim) public claims;

    mapping (bytes32 => uint) public saleAmounts;

    mapping (bytes32 => address[]) public claimsForPubkey;

    address[] public claimed;

    mapping (address => address) public amended;

    uint public endSetUpDelay;

    event Amended(address indexed original, address indexed amendedTo);
    event Claimed(address indexed eth, bytes32 indexed dot, uint indexed idx);
    event IndexAssigned(address indexed eth, uint indexed idx);
    event Vested(address indexed eth, uint amount);
    event VestedIncreased(address indexed eth, uint newTotal);
    event InjectedSaleAmount(bytes32 indexed pubkey, uint newTotal);

    constructor(address _owner, address _allocations, uint _setUpDelay) public {
        require(_owner != address(0x0), "Must provide an owner address.");
        require(_allocations != address(0x0), "Must provide an allocations address.");
        require(_setUpDelay > 0, "Must provide a non-zero argument to _setUpDelay.");

        owner = _owner;
        allocationIndicator = FrozenToken(_allocations);
        
        endSetUpDelay = block.number + _setUpDelay;
    }

    function amend(address[] calldata _origs, address[] calldata _amends)
        external
        only_owner
    {

        require(
            _origs.length == _amends.length,
            "Must submit arrays of equal length."
        );

        for (uint i = 0; i < _amends.length; i++) {
            require(!hasClaimed(_origs[i]), "Address has already claimed.");
            require(hasAllocation(_origs[i]), "Ethereum address has no DOT allocation.");
            amended[_origs[i]] = _amends[i];
            emit Amended(_origs[i], _amends[i]);
        }
    }

    function setVesting(address[] calldata _eths, uint[] calldata _vestingAmts)
        external
        only_owner
    {

        require(_eths.length == _vestingAmts.length, "Must submit arrays of equal length.");

        for (uint i = 0; i < _eths.length; i++) {
            Claim storage claimData = claims[_eths[i]];
            require(!hasClaimed(_eths[i]), "Account must not be claimed.");
            require(claimData.vested == 0, "Account must not be vested already.");
            require(_vestingAmts[i] != 0, "Vesting amount must be greater than zero.");
            claimData.vested = _vestingAmts[i];
            emit Vested(_eths[i], _vestingAmts[i]);
        }
    }

    function increaseVesting(address[] calldata _eths, uint[] calldata _vestingAmts)
        external
        only_owner
    {

        require(_eths.length == _vestingAmts.length, "Must submit arrays of equal length.");

        for (uint i = 0; i < _eths.length; i++) {
            Claim storage claimData = claims[_eths[i]];
            require(_vestingAmts[i] > 0, "Vesting amount must be greater than zero.");
            uint oldVesting = claimData.vested;
            uint newVesting = oldVesting + _vestingAmts[i];
            require(newVesting > oldVesting, "Overflow in addition.");
            claimData.vested = newVesting;
            emit VestedIncreased(_eths[i], newVesting);
        }
    }

    function injectSaleAmount(bytes32[] calldata _pubkeys, uint[] calldata _amounts)
        external
        only_owner
    {

        require(_pubkeys.length == _amounts.length);

        for (uint i = 0; i < _pubkeys.length; i++) {
            bytes32 pubkey = _pubkeys[i];
            uint amount = _amounts[i];

            require(amount > 0, "Must inject a sale amount greater than zero.");

            uint oldValue = saleAmounts[pubkey];
            uint newValue = oldValue + amount;
            require(newValue > oldValue, "Overflow in addition");
            saleAmounts[pubkey] = newValue;

            emit InjectedSaleAmount(pubkey, newValue);
        }
    }

    function balanceOfPubkey(bytes32 _who) public view returns (uint) {

        address[] storage frozenTokenHolders = claimsForPubkey[_who];
        if (frozenTokenHolders.length > 0) {
            uint total;
            for (uint i = 0; i < frozenTokenHolders.length; i++) {
                total += allocationIndicator.balanceOf(frozenTokenHolders[i]);
            }
            return total + saleAmounts[_who];
        }
        return saleAmounts[_who];
    }

    function freeze() external only_owner {

        endSetUpDelay = UINT_MAX;
    }

    function assignIndices(address[] calldata _eths)
        external
        protected_during_delay
    {

        for (uint i = 0; i < _eths.length; i++) {
            require(assignNextIndex(_eths[i]), "Assigning the next index failed.");
        }
    }

    function claim(address _eth, bytes32 _pubKey)
        external
        after_set_up_delay
        has_allocation(_eth)
        not_claimed(_eth)
    {

        require(_pubKey != bytes32(0), "Failed to provide an Ed25519 or SR25519 public key.");
        
        if (amended[_eth] != address(0x0)) {
            require(amended[_eth] == msg.sender, "Address is amended and sender is not the amendment.");
        } else {
            require(_eth == msg.sender, "Sender is not the allocation address.");
        }

        if (claims[_eth].index == 0 && !claims[_eth].hasIndex) {
            require(assignNextIndex(_eth), "Assigning the next index failed.");
        }

        claims[_eth].pubKey = _pubKey;
        claimed.push(_eth);
        claimsForPubkey[_pubKey].push(_eth);

        emit Claimed(_eth, _pubKey, claims[_eth].index);
    }

    function claimedLength()
        external view returns (uint)
    {   

        return claimed.length;
    }

    function hasClaimed(address _eth)
        public view returns (bool)
    {

        return claims[_eth].pubKey != bytes32(0);
    }

    function hasAllocation(address _eth)
        public view returns (bool)
    {

        uint bal = allocationIndicator.balanceOf(_eth);
        return bal > 0;
    }

    function assignNextIndex(address _eth)
        has_allocation(_eth)
        not_claimed(_eth)
        internal returns (bool)
    {

        require(claims[_eth].index == 0, "Cannot reassign an index.");
        require(!claims[_eth].hasIndex, "Address has already been assigned an index.");
        uint idx = nextIndex;
        nextIndex++;
        claims[_eth].index = idx;
        claims[_eth].hasIndex = true;
        emit IndexAssigned(_eth, idx);
        return true;
    }

    modifier has_allocation(address _eth) {

        require(hasAllocation(_eth), "Ethereum address has no DOT allocation.");
        _;
    }

    modifier not_claimed(address _eth) {

        require(
            claims[_eth].pubKey == bytes32(0),
            "Account has already claimed."
        );
        _;
    }

    modifier after_set_up_delay {

        require(
            block.number >= endSetUpDelay,
            "This function is only evocable after the setUpDelay has elapsed."
        );
        _;
    }

    modifier protected_during_delay {

        if (block.number < endSetUpDelay) {
            require(
                msg.sender == owner,
                "Only owner is allowed to call this function before the end of the set up delay."
            );
        }
        _;
    }
}