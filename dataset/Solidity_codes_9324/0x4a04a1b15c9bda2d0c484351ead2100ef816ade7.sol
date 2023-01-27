

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

contract Authorizable is Ownable {

  mapping(address => bool) public authorized;

		modifier onlyAuthorized() {

			require(isAuthorized(msg.sender), "AuthorizeError: caller does not have the Owner or Authorized role");
			_;
		}

		function isAuthorized(address account) public view returns (bool) {

			return authorized[account];
		}

		function addAuthorized(address _addr) public onlyOwner {


			authorized[_addr] = true;
		}

		function addAuthorizedInternal( address _addr ) internal {

			authorized[_addr] = true;
		}

		function removeAuthorizedInternal( address _addr ) internal {

			authorized[_addr] = false;
		}

		function removeAuthorized(address _addr) public onlyOwner {

   
			authorized[_addr] = false;
		}
}


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
		_name = "XfiniteAsset";
		_symbol = "XFA";

		_supply = 11500000000000000000000000; // 18 decimal places are allowed
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


pragma solidity ^0.4.24;


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


pragma solidity >=0.4.21 <0.6.0;




contract XFAFirstVersion is Authorizable {

	using SafeMath for uint256;

	TokenStorage private dataStore;

	uint256 public _version;

	event Burn(address indexed _burner, uint256 _value);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);	

	constructor(address storeAddress) public {
		dataStore = TokenStorage(storeAddress);
	}

	function name() public view returns (string) {

		return dataStore._getName();
	}

	function symbol() public view returns (string) {

		return dataStore._getSymbol();
	}

	function decimals() public view returns (uint8) {

		return dataStore._getDecimals();
	}


	function version() public view returns (uint256){

		return _version;
	}

	function totalSupply() public view returns (uint256) {

		return dataStore._getSupply();
	}

	function balanceOf(address account) public view returns (uint256) {

		return dataStore._getBalance(account);
	}

	function allowance(address _owner, address _spender) public view returns (uint256) {


		return dataStore._getAllowance(_owner, _spender);
	}

	function getAttributes(address _of) public view returns (bytes32 dochash, bool status) {


		return dataStore._getKyc(_of);
	}

	function verifyTransfer(address sender, address recipient, uint256 amount) public view returns (bool success) {

   
		require(sender != address(0), "AddressError: transfer from the zero address");
		require(recipient != address(0), "AddressError: transfer to the zero address");
		require(amount > 0, "Amount can not be 0 or less");
		return dataStore._verifyKyc(sender, recipient);
	}

	function transfer(address _to, uint256 _value) public onlyAuthorized returns (bool) {

   
		require(verifyTransfer(msg.sender, _to, _value), "VerificationError: Unable ro process the transaction.");
		_transfer(msg.sender, _to, _value);
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _value) public onlyAuthorized returns (bool) {

 
		require(verifyTransfer(_from, _to, _value), "VerificationError: Unable ro process the transaction.");
		require(dataStore._getAllowance(_from, msg.sender) >= _value, "AllowanceError: The spender does not hve the required allowance.");
		_transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public onlyAuthorized returns (bool) {

    
		_approve(msg.sender, _spender, _value);
		return true;
	}


	function burn(uint256 _value) public onlyOwner returns (bool) {

  
		_burn(msg.sender, _value);
		return true;
	}

	function burnFrom(address _of, uint256 _value) public returns (bool) {

		bool isWhitelisted = dataStore.isWhitelistedContract( msg.sender );
		require( msg.sender == _owner || isWhitelisted );
		_burn(_of, _value);
		return true;
	}

	function setAttributes (address _of, bytes32 _dochash) public onlyOwner returns (bool) {
  
		_setAttributes(_of, _dochash);
		return true;
	}

	function removeAttributes(address _of) public onlyOwner returns (bool) {

		
		_removeAttributes(_of);
		return true;
	}

	function addRole(address _addr) public onlyOwner returns (bool) {

		super.addAuthorized(_addr);
		return true;
	}

	function removeRole(address _addr) public onlyOwner returns (bool) {

		super.removeAuthorized(_addr);
		return true;
	}


	function _approve(address owner, address spender, uint256 amount) internal {

   
		require(owner != address(0), "AddressError: approve from the zero address");
		require(spender != address(0), "AddressError: approve to the zero address");
		require(amount > 0, "Amount can not be 0 or less");
		require(dataStore._getBalance(owner) >= amount, "Insufficient Funds");

		dataStore._setAllowance(owner, spender, amount);
		emit Approval(owner, spender, amount);
	}

	function _transfer(address sender, address recipient, uint256 amount) internal {

   
		require(sender != address(0), "AddressError: transfer from the zero address");
		require(recipient != address(0), "AddressError: transfer to the zero address");
		require(amount > 0, "Amount can not be 0 or less");
		require(dataStore._getBalance(sender) >= amount, "Insufficient Funds");

		dataStore._subBalance(sender, amount);
		dataStore._addBalance(recipient, amount);
		emit Transfer(sender, recipient, amount);
	}

	function _burn(address sender, uint256 amount) internal {

		require(sender != address(0), "AddressError: transfer from the zero address");
		require(amount > 0, "Amount can not be 0 or less");
		require(dataStore._getBalance(sender) >= amount, "Insufficient Funds");

		dataStore._subBalance(sender, amount);
		dataStore._subSupply(amount);
		emit Burn(sender, amount);
	}

	function _setAttributes(address account, bytes32 dochash) internal {

		require(account != address(0), "AddressError: from the zero address");
		require(dochash.length > 0, "HashError: Hash can never be empty");
		dataStore._setKyc(account, dochash);
	}

	function _removeAttributes(address account) internal {

		require(account != address(0), "AddressError: from the zero address");
		dataStore._removeKyc(account);
	}
}