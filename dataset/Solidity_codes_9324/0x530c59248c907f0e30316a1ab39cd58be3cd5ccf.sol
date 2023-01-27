

pragma solidity ^0.4.24;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


pragma solidity >=0.4.21 <0.6.0;

contract Ownable {

  address _owner;

   event transferOwn(address _owner, address newOwner);

		modifier onlyOwner() {

			require(isOwner(msg.sender), "OwnerRole: caller does not have the Owner role");
			_;
		}

		function isOwner(address account) public view returns (bool) {

			return account == _owner;
		}

		function getOwner() public view returns (address) {

			return _owner;
		}

		 function transferOwnership(address newOwner) public onlyOwner returns (address) {

	         require( newOwner != address(0), "new owner address is invalid");
			 emit transferOwn(_owner, newOwner);
	         _owner = newOwner;
			 return _owner;
      }
}


pragma solidity >=0.4.21 <0.6.0;


contract TokenStorage  is Ownable{

  using SafeMath for uint256;

	address internal _registryContract;

	uint8 internal _decimals;
	string internal _name;
	string internal _symbol;
	uint256 internal _supply;

	mapping( address => bool ) public whitelistedContracts;

	struct tkyc {
		bytes32 dochash;
		bool status;
	}

	mapping(address => mapping(address => uint256)) internal _allowances;
	mapping(address => uint256) internal _balances;
	mapping(address => tkyc) internal _kycs;

	constructor() public {
    
		_owner = msg.sender;
		_decimals = 18;
		_name = "XFA";
		_symbol = "XFA";

		_supply = 1000000000 * 10**18; // 18 decimal places are allowed
		_balances[_owner] = _supply;
	}




	function _setRegistry(address _registry) public onlyOwner {

		require(_registry != address(0), "InvalidAddress: invalid address passed for proxy contract");
		_registryContract = _registry;
	}

	function _getRegistry() public view returns (address) {

		return _registryContract;
	}

	modifier isRegistry() {

		require(msg.sender == _registryContract, "AccessDenied: This address is not allowed to access the storage");
		_;
	}





	function _getName() public view isRegistry returns (string) {

		return _name;
	}

	function _getSymbol() public view isRegistry returns (string) {

		return _symbol;
	}

	function _getDecimals() public view isRegistry returns (uint8) {

		return _decimals;
	}

	function _subSupply(uint256 _value) public isRegistry {

		_supply = _supply.sub(_value);
	}

	function _getSupply() public view isRegistry returns (uint256) {

		return _supply;
	}




	function _setAllowance(address _owner, address _spender, uint256 _value) public isRegistry {

 
		_allowances[_owner][_spender] = _value;
	}

	function _getAllowance(address _owner, address _spender) public view isRegistry returns (uint256) {


		return _allowances[_owner][_spender];
	}





	function _addBalance(address _addr, uint256 _value) public isRegistry {

		require(_kycs[_addr].status == true, "KycError: Unable to make transaction");
		_balances[_addr] = _balances[_addr].add(_value);
	}

	function _subBalance(address _addr, uint256 _value) public isRegistry {

		require(_kycs[_addr].status == true, "KycError: Unable to make transaction");
		_balances[_addr] = _balances[_addr].sub(_value);
	}

	function _getBalance(address _addr) public view isRegistry returns (uint256) {

		return _balances[_addr];
	}



	function _setKyc(address _addr, bytes32 _value) public isRegistry {

		 tkyc memory item = tkyc( _value, true );
		_kycs[ _addr ] = item;
	}

	function _removeKyc(address _addr) public isRegistry {

		_kycs[_addr].dochash = "0x0";
		_kycs[_addr].status = false;
	}

	function _getKyc(address _addr) public view isRegistry returns (bytes32 dochash, bool status) {

		return (_kycs[_addr].dochash, _kycs[_addr].status);
	}

	function _verifyKyc(address _from, address _to) public view isRegistry returns (bool) {

		if (_kycs[_from].status == true && _kycs[_to].status == true) return true;
		return false;
	}

	function addWhitelistedContract( address _admin ) public onlyOwner returns (bool) {

		whitelistedContracts[_admin] = true;
	}

	function removeWhitelistedContract( address _admin ) public onlyOwner returns (bool) {

		whitelistedContracts[_admin] = false;
	}

	function isWhitelistedContract( address _admin ) public view returns (bool) {

		return whitelistedContracts[_admin];
	}
}