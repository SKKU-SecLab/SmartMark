
pragma solidity ^0.4.13;

library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {

  address public owner;


  function Ownable() {

    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner {

    require(newOwner != address(0));
    owner = newOwner;
  }

}

contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {

    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    Unpause();
  }
}

contract HasNoEther is Ownable {


  function HasNoEther() payable {

    require(msg.value == 0);
  }

  function() external {
  }

  function reclaimEther() external onlyOwner {

    assert(owner.send(this.balance));
  }
}

contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {

    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LimitedTransferToken is ERC20 {


  modifier canTransfer(address _sender, uint256 _value) {

   require(_value <= transferableTokens(_sender, uint64(now)));
   _;
  }

  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) returns (bool) {

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) returns (bool) {

    return super.transferFrom(_from, _to, _value);
  }

  function transferableTokens(address holder, uint64 time) constant public returns (uint256) {

    return balanceOf(holder);
  }
}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    var _allowance = allowed[_from][msg.sender];


    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool) {


    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

    return allowed[_owner][_spender];
  }

}

contract BurnableToken is StandardToken {


    function burn(uint _value)
        public
    {

        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    event Burn(address indexed burner, uint indexed value);
}

contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner returns (bool) {

    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract BearCoin is BurnableToken, MintableToken, LimitedTransferToken, Pausable, HasNoEther {

	struct Tether {
		bytes5 currency;
		uint32 amount;
		uint32 price;
		uint32 startBlock;
		uint32 endBlock;
	}

	address[] public addressById;
	mapping (string => uint256) idByName;
	mapping (address => string) nameByAddress;

	uint256 public constant INITIAL_SUPPLY = 2000000 ether;

	string public constant symbol = "BEAR";
	uint256 public constant decimals = 18;
	string public constant name = "BearCoin";

	string constant genesis = "CR30001";
	uint256 public genesisBlock = 0;

	mapping (address => Tether[]) public currentTethers;
	address public controller;

	event Tethered(address indexed holder, string holderName, string currency, uint256 amount, uint32 price, uint256 indexed tetherID, uint timestamp, string message);
	event Untethered(address indexed holder,string holderName, string currency, uint256 amount, uint32 price, uint32 finalPrice, uint256 outcome, uint256 indexed tetherID, uint timestamp);
	event NameRegistered(address indexed a, uint256 id, string userName, uint timestamp);
	event NameChanged(address indexed a, uint256 id, string newUserName, string oldUserName, uint timestamp);

	function BearCoin() {

		balances[msg.sender] = INITIAL_SUPPLY;
		totalSupply = INITIAL_SUPPLY;
		addressById.push(0x0);
		idByName[genesis] = 0;
		nameByAddress[0x0] = genesis;
		genesisBlock = block.number;
	}

	function transferableTokens(address holder, uint64 time) constant public returns (uint256) {

		uint256 count = tetherCount(holder);

		if (count == 0) return super.transferableTokens(holder, time);

		uint256 tetheredTokens = 0;
		for (uint256 i = 0; i < count; i++) {
			if (currentTethers[holder][i].endBlock == 0) {
				tetheredTokens = tetheredTokens.add(_finneyToWei(currentTethers[holder][i].amount));
			}
		}

		return balances[holder].sub(tetheredTokens);
	}

	modifier onlyController() {

		require(msg.sender == controller);
		_;
	}

	function setController(address a) onlyOwner {

		controller = a;
	}

	function addTether(address a, string _currency, uint256 amount, uint32 price, string m) external onlyController whenNotPaused {

		require(transferableTokens(a, 0) >= amount);
		bytes5 currency = _stringToBytes5(_currency);
		uint256 count = currentTethers[a].push(Tether(currency, _weiToFinney(amount), price, uint32(block.number.sub(genesisBlock)), 0));
		Tethered(a, nameByAddress[a], _currency, amount, price, count - 1, now, m);
	}
	function setTether(address a, uint256 tetherID, uint32 finalPrice, uint256 outcome) external onlyController whenNotPaused {

		currentTethers[a][tetherID].endBlock = uint32(block.number.sub(genesisBlock));
		Tether memory tether = currentTethers[a][tetherID];
		Untethered(a, nameByAddress[a], _bytes5ToString(tether.currency), tether.amount, tether.price, finalPrice, outcome, tetherID, now);
	}
	function controlledMint(address _to, uint256 _amount) external onlyController whenNotPaused returns (bool) {

		totalSupply = totalSupply.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(0x0, _to, _amount);
		return true;
	}
	function controlledBurn(address _from, uint256 _value) external onlyController whenNotPaused returns (bool) {

		require(_value > 0);

		balances[_from] = balances[_from].sub(_value);
		totalSupply = totalSupply.sub(_value);
		Burn(_from, _value);
		return true;
	}

	function registerName(address a, string n) external onlyController whenNotPaused {

		require(!isRegistered(a));
		require(getIdByName(n) == 0);
		require(a != 0x0);
		require(_nameValid(n));
		uint256 length = addressById.push(a);
		uint256 id = length - 1;
		idByName[_toLower(n)] = id;
		nameByAddress[a] = n;
		NameRegistered(a, id, n, now);
	}
	function changeName(address a, string n) external onlyController whenNotPaused {

		require(isRegistered(a));
		require(getIdByName(n) == 0);
		require(a != 0x0);
		require(_nameValid(n));
		string memory old = nameByAddress[a];
		uint256 id = getIdByName(old);
		idByName[_toLower(old)] = 0;
		idByName[_toLower(n)] = id;
		nameByAddress[a] = n;
		NameChanged(a, id, n, old, now);
	}

	function getTether(address a, uint256 tetherID) public constant returns (string, uint256, uint32, uint256, uint256) {

		Tether storage tether = currentTethers[a][tetherID];
		return (_bytes5ToString(tether.currency), _finneyToWei(tether.amount), tether.price, uint256(tether.startBlock).add(genesisBlock), uint256(tether.endBlock).add(genesisBlock));
	}
	function getTetherInts(address a, uint256 tetherID) public constant returns (uint256, uint32, uint32, uint32) {

		Tether memory tether = currentTethers[a][tetherID];
		return (_finneyToWei(tether.amount), tether.price, tether.startBlock, tether.endBlock);
	}
	function tetherCount(address a) public constant returns (uint256) {

		return currentTethers[a].length;
	}
	function getAddressById(uint256 id) returns (address) {

		return addressById[id];
	}
	function getIdByName(string n) returns (uint256) {

		return idByName[_toLower(n)];
	}
	function getNameByAddress(address a) returns (string) {

		return nameByAddress[a];
	}
	function getAddressCount() returns (uint256) {

		return addressById.length;
	}

	function verifyTetherCurrency(address a, uint256 tetherID, string currency) public constant returns (bool) {

		return currentTethers[a][tetherID].currency == _stringToBytes5(currency);
	}
	function verifyTetherLoss(address a, uint256 tetherID, uint256 price) public constant returns (bool) {

		return currentTethers[a][tetherID].price < uint32(price);
	}
	function isRegistered(address a) returns (bool) {

		return keccak256(nameByAddress[a]) != keccak256('');
	}

	function _nameValid(string s) internal returns (bool) {

		return bytes(s).length != 0 && keccak256(s) != keccak256(genesis) && bytes(s).length <= 32;
	}
	function _bytes5ToString(bytes5 b) internal returns (string memory s) {

		bytes memory bs = new bytes(5);
		for (uint8 i = 0; i < 5; i++) {
			bs[i] = b[i];
		}
		s = string(bs);
	}
	function _stringToBytes5(string memory s) internal returns (bytes5 b) {

		assembly {
			b := mload(add(s, 32))
		}
	}
	function _toLower(string str) internal returns (string) {

		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
				bLower[i] = bytes1(int(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}
	function _finneyToWei(uint32 _n) returns (uint256) {

		uint256 n = uint256(_n);
		uint256 f = 1 finney;
		return n.mul(f);
	}
	function _weiToFinney(uint256 n) returns (uint32) {

		uint256 f = 1 finney;
		uint256 p = n.div(f);
		return uint32(p);
	}

}