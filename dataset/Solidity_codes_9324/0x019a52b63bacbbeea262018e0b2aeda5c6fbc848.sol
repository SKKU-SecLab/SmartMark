
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


library Roles {

  struct Role {
    mapping (address => bool) bearer;
  }

  function add(Role storage _role, address _addr)
    internal
  {

    _role.bearer[_addr] = true;
  }

  function remove(Role storage _role, address _addr)
    internal
  {

    _role.bearer[_addr] = false;
  }

  function check(Role storage _role, address _addr)
    internal
    view
  {

    require(has(_role, _addr));
  }

  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {

    return _role.bearer[_addr];
  }
}


contract RBAC {

  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  function checkRole(address _operator, string _role)
    public
    view
  {

    roles[_role].check(_operator);
  }

  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {

    return roles[_role].has(_operator);
  }

  function addRole(address _operator, string _role)
    internal
  {

    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  function removeRole(address _operator, string _role)
    internal
  {

    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  modifier onlyRole(string _role)
  {

    checkRole(msg.sender, _role);
    _;
  }



}


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract Contributions is RBAC, Ownable {

  using SafeMath for uint256;

  uint256 private constant TIER_DELETED = 999;
  string public constant ROLE_MINTER = "minter";
  string public constant ROLE_OPERATOR = "operator";

  uint256 public tierLimit;

  modifier onlyMinter () {

    checkRole(msg.sender, ROLE_MINTER);
    _;
  }

  modifier onlyOperator () {

    checkRole(msg.sender, ROLE_OPERATOR);
    _;
  }

  uint256 public totalSoldTokens;
  mapping(address => uint256) public tokenBalances;
  mapping(address => uint256) public ethContributions;
  mapping(address => uint256) private _whitelistTier;
  address[] public tokenAddresses;
  address[] public ethAddresses;
  address[] private whitelistAddresses;

  constructor(uint256 _tierLimit) public {
    addRole(owner, ROLE_OPERATOR);
    tierLimit = _tierLimit;
  }

  function addMinter(address minter) external onlyOwner {

    addRole(minter, ROLE_MINTER);
  }

  function removeMinter(address minter) external onlyOwner {

    removeRole(minter, ROLE_MINTER);
  }

  function addOperator(address _operator) external onlyOwner {

    addRole(_operator, ROLE_OPERATOR);
  }

  function removeOperator(address _operator) external onlyOwner {

    removeRole(_operator, ROLE_OPERATOR);
  }

  function addTokenBalance(
    address _address,
    uint256 _tokenAmount
  )
    external
    onlyMinter
  {

    if (tokenBalances[_address] == 0) {
      tokenAddresses.push(_address);
    }
    tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);
    totalSoldTokens = totalSoldTokens.add(_tokenAmount);
  }

  function addEthContribution(
    address _address,
    uint256 _weiAmount
  )
    external
    onlyMinter
  {

    if (ethContributions[_address] == 0) {
      ethAddresses.push(_address);
    }
    ethContributions[_address] = ethContributions[_address].add(_weiAmount);
  }

  function setTierLimit(uint256 _newTierLimit) external onlyOperator {

    require(_newTierLimit > 0, "Tier must be greater than zero");

    tierLimit = _newTierLimit;
  }

  function addToWhitelist(
    address _investor,
    uint256 _tier
  )
    external
    onlyOperator
  {

    require(_tier == 1 || _tier == 2, "Only two tier level available");
    if (_whitelistTier[_investor] == 0) {
      whitelistAddresses.push(_investor);
    }
    _whitelistTier[_investor] = _tier;
  }

  function removeFromWhitelist(address _investor) external onlyOperator {

    _whitelistTier[_investor] = TIER_DELETED;
  }

  function whitelistTier(address _investor) external view returns (uint256) {

    return _whitelistTier[_investor] <= 2 ? _whitelistTier[_investor] : 0;
  }

  function getWhitelistedAddresses(
    uint256 _tier
  )
    external
    view
    returns (address[])
  {

    address[] memory tmp = new address[](whitelistAddresses.length);

    uint y = 0;
    if (_tier == 1 || _tier == 2) {
      uint len = whitelistAddresses.length;
      for (uint i = 0; i < len; i++) {
        if (_whitelistTier[whitelistAddresses[i]] == _tier) {
          tmp[y] = whitelistAddresses[i];
          y++;
        }
      }
    }

    address[] memory toReturn = new address[](y);

    for (uint k = 0; k < y; k++) {
      toReturn[k] = tmp[k];
    }

    return toReturn;
  }

  function isAllowedPurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    external
    view
    returns (bool)
  {

    if (_whitelistTier[_beneficiary] == 2) {
      return true;
    } else if (_whitelistTier[_beneficiary] == 1 && ethContributions[_beneficiary].add(_weiAmount) <= tierLimit) {
      return true;
    }

    return false;
  }

  function getTokenAddressesLength() external view returns (uint) {

    return tokenAddresses.length;
  }

  function getEthAddressesLength() external view returns (uint) {

    return ethAddresses.length;
  }
}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract DetailedERC20 is ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {

    require(msg.sender == owner);
    _;
  }

  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() public onlyOwner canMint returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract RBACMintableToken is MintableToken, RBAC {

  string public constant ROLE_MINTER = "minter";

  modifier hasMintPermission() {

    checkRole(msg.sender, ROLE_MINTER);
    _;
  }

  function addMinter(address _minter) public onlyOwner {

    addRole(_minter, ROLE_MINTER);
  }

  function removeMinter(address _minter) public onlyOwner {

    removeRole(_minter, ROLE_MINTER);
  }
}


contract BurnableToken is BasicToken {


  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


interface ERC165 {


  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}


contract SupportsInterfaceWithLookup is ERC165 {


  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;

  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {

    return supportedInterfaces[_interfaceId];
  }

  function _registerInterface(bytes4 _interfaceId)
    internal
  {

    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}


contract ERC1363 is ERC20, ERC165 {



  function transferAndCall(address _to, uint256 _value) public returns (bool);


  function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool); // solium-disable-line max-len


  function transferFromAndCall(address _from, address _to, uint256 _value) public returns (bool); // solium-disable-line max-len



  function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public returns (bool); // solium-disable-line max-len, arg-overflow


  function approveAndCall(address _spender, uint256 _value) public returns (bool); // solium-disable-line max-len


  function approveAndCall(address _spender, uint256 _value, bytes _data) public returns (bool); // solium-disable-line max-len

}


contract ERC1363Receiver {


  function onTransferReceived(address _operator, address _from, uint256 _value, bytes _data) external returns (bytes4); // solium-disable-line max-len, arg-overflow

}


contract ERC1363Spender {


  function onApprovalReceived(address _owner, uint256 _value, bytes _data) external returns (bytes4); // solium-disable-line max-len

}









contract ERC1363BasicToken is SupportsInterfaceWithLookup, StandardToken, ERC1363 { // solium-disable-line max-len

  using AddressUtils for address;

  bytes4 internal constant InterfaceId_ERC1363Transfer = 0x4bbee2df;

  bytes4 internal constant InterfaceId_ERC1363Approve = 0xfb9ec8ce;

  bytes4 private constant ERC1363_RECEIVED = 0x88a7ca5c;

  bytes4 private constant ERC1363_APPROVED = 0x7b04a2d0;

  constructor() public {
    _registerInterface(InterfaceId_ERC1363Transfer);
    _registerInterface(InterfaceId_ERC1363Approve);
  }

  function transferAndCall(
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    return transferAndCall(_to, _value, "");
  }

  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    returns (bool)
  {

    require(transfer(_to, _value));
    require(
      checkAndCallTransfer(
        msg.sender,
        _to,
        _value,
        _data
      )
    );
    return true;
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    return transferFromAndCall(_from, _to, _value, "");
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    returns (bool)
  {

    require(transferFrom(_from, _to, _value));
    require(
      checkAndCallTransfer(
        _from,
        _to,
        _value,
        _data
      )
    );
    return true;
  }

  function approveAndCall(
    address _spender,
    uint256 _value
  )
    public
    returns (bool)
  {

    return approveAndCall(_spender, _value, "");
  }

  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    returns (bool)
  {

    approve(_spender, _value);
    require(
      checkAndCallApprove(
        _spender,
        _value,
        _data
      )
    );
    return true;
  }

  function checkAndCallTransfer(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    internal
    returns (bool)
  {

    if (!_to.isContract()) {
      return false;
    }
    bytes4 retval = ERC1363Receiver(_to).onTransferReceived(
      msg.sender, _from, _value, _data
    );
    return (retval == ERC1363_RECEIVED);
  }

  function checkAndCallApprove(
    address _spender,
    uint256 _value,
    bytes _data
  )
    internal
    returns (bool)
  {

    if (!_spender.isContract()) {
      return false;
    }
    bytes4 retval = ERC1363Spender(_spender).onApprovalReceived(
      msg.sender, _value, _data
    );
    return (retval == ERC1363_APPROVED);
  }
}


contract TokenRecover is Ownable {


  function recoverERC20(
    address _tokenAddress,
    uint256 _tokens
  )
  public
  onlyOwner
  returns (bool success)
  {

    return ERC20Basic(_tokenAddress).transfer(owner, _tokens);
  }
}


contract FidelityHouseToken is DetailedERC20, RBACMintableToken, BurnableToken, ERC1363BasicToken, TokenRecover {


  uint256 public lockedUntil;
  mapping(address => uint256) internal lockedBalances;

  modifier canTransfer(address _from, uint256 _value) {

    require(
      mintingFinished,
      "Minting should be finished before transfer."
    );
    require(
      _value <= balances[_from].sub(lockedBalanceOf(_from)),
      "Can't transfer more than unlocked tokens"
    );
    _;
  }

  constructor(uint256 _lockedUntil)
    DetailedERC20("FidelityHouse Token", "FIH", 18)
    public
  {
    lockedUntil = _lockedUntil;
  }

  function lockedBalanceOf(address _owner) public view returns (uint256) {

    return block.timestamp <= lockedUntil ? lockedBalances[_owner] : 0;
  }

  function mintAndLock(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {

    lockedBalances[_to] = lockedBalances[_to].add(_amount);
    return super.mint(_to, _amount);
  }

  function transfer(
    address _to,
    uint256 _value
  )
    public
    canTransfer(msg.sender, _value)
    returns (bool)
  {

    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    canTransfer(_from, _value)
    returns (bool)
  {

    return super.transferFrom(_from, _to, _value);
  }
}


contract FidelityHousePrivateSale is TokenRecover {

  using SafeMath for uint256;

  mapping (address => uint256) public sentTokens;

  FidelityHouseToken public token;
  Contributions public contributions;

  constructor(address _token, address _contributions) public {
    require(
      _token != address(0),
      "Token shouldn't be the zero address."
    );
    require(
      _contributions != address(0),
      "Contributions address can't be the zero address."
    );

    token = FidelityHouseToken(_token);
    contributions = Contributions(_contributions);
  }

  function multiSend(
    address[] _addresses,
    uint256[] _amounts,
    uint256[] _bonuses
  )
    external
    onlyOwner
  {

    require(
      _addresses.length > 0,
      "Addresses array shouldn't be empty."
    );
    require(
      _amounts.length > 0,
      "Amounts array shouldn't be empty."
    );
    require(
      _bonuses.length > 0,
      "Bonuses array shouldn't be empty."
    );
    require(
      _addresses.length == _amounts.length && _addresses.length == _bonuses.length,
      "Arrays should have the same length."
    );

    uint len = _addresses.length;
    for (uint i = 0; i < len; i++) {
      address _beneficiary = _addresses[i];
      uint256 _tokenAmount = _amounts[i];
      uint256 _bonusAmount = _bonuses[i];

      if (sentTokens[_beneficiary] == 0) {
        uint256 totalTokens = _tokenAmount.add(_bonusAmount);
        sentTokens[_beneficiary] = totalTokens;
        token.mintAndLock(_beneficiary, _tokenAmount);
        token.mint(_beneficiary, _bonusAmount);
        contributions.addTokenBalance(_beneficiary, totalTokens);
      }
    }
  }
}