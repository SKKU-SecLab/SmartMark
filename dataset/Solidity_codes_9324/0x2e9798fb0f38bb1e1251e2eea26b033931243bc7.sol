
pragma solidity ^0.8.6;

contract Context {

    constructor () { }

    function _msgSender() internal view returns (address payable) {

        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.6;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.8.6;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.8.6;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
pragma solidity ^0.8.6;

abstract contract ProjectToken_interface {
    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);

    function owner() public view virtual returns (address);
    function balanceOf(address who) public view virtual returns (uint256);
    
    function transfer(address _to, uint256 _value) public virtual returns (bool);
    function allowance(address _owner, address _spender) public virtual returns (uint);
    function transferFrom(address _from, address _to, uint _value) public virtual returns (bool);
    
}
pragma solidity ^0.8.6;

abstract contract TetherToken_interface {
    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);

    function owner() public view virtual returns (address);
    function balanceOf(address who) public view virtual returns (uint256);
    
    function allowance(address _owner, address _spender) public virtual returns (uint);
    
    function transfer(address _to, uint256 _value) public virtual;
    function transferFrom(address _from, address _to, uint _value) public virtual;
}
pragma solidity ^0.8.6;



contract AdminRole is Context, Ownable {

    using Roles for Roles.Role;
    using SafeMath for uint256;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    uint256 private _qty_admins = 0;
    Roles.Role private _admins;
    address[] private _signatures;

    modifier onlyAdmin() {

        require(isAdmin(_msgSender()), "AdminRole: caller does not have the Admin role");
        _;
    }

    modifier onlyOwnerOrAdmin() {

      require(isAdminOrOwner(_msgSender()), "Can call only owner or admin");
      _;
    }

    function isAdminOrOwner(address account) public view returns (bool) {

        return isAdmin(account) || isOwner();
    }

    function isAdmin(address account) public view returns (bool) {

        return _admins.has(account);
    }

    function _addAdmin(address account) internal {


        require(!isAdmin(account) && account != owner(), "already exist");

        _admins.add(account);
        _qty_admins = _qty_admins.add(1);
        emit AdminAdded(account);
    }

    function addSignature4NextOperation() public onlyOwnerOrAdmin {

      bool exist = false;
      for(uint256 i=0; i<_signatures.length; i++){
        if(_signatures[i] == _msgSender()){
          exist = true;
          break;
        }
      }
      require(!exist, "already exist");
      _signatures.push(_msgSender());
    }

    function cancelSignature4NextOperation() public onlyOwnerOrAdmin {

      for(uint256 i=0; i<_signatures.length; i++){
        if(_signatures[i] == _msgSender()){
          _remove_signatures(i);
          return;
        }
      }
      require(false, "not found");

    }

    function checkValidMultiSignatures() public view returns(bool){

      uint256 all_signatures = _qty_admins.add(1); // 1 for owner
      if(all_signatures <= 2){
        return all_signatures == _signatures.length;
      }
      uint256 approved_signatures = all_signatures.mul(2).div(3);
      return _signatures.length >= approved_signatures;
    }

    function cancelAllMultiSignatures() public onlyOwnerOrAdmin{

      uint256 l = _signatures.length;
      for(uint256 i=0; i<l; i++){
        _signatures.pop();
      }
    }

    function checkExistSignature(address account) public view returns(bool){

      bool exist = false;
      for(uint256 i=0; i<_signatures.length; i++){
        if(_signatures[i] == account){
          exist = true;
          break;
        }
      }
      return exist;
    }

    function m_signaturesTransferOwnership(address newOwner) public onlyOwnerOrAdmin {

      require(isOwner() || checkValidMultiSignatures(), "There is no required number of signatures");
      transferOwnership(newOwner);
      cancelAllMultiSignatures();
    }

    function _remove_signatures(uint index) private {

      if (index >= _signatures.length) return;
      for (uint i = index; i<_signatures.length-1; i++){
        _signatures[i] = _signatures[i+1];
      }
      _signatures.pop();
    }

}


contract VerifySignature{


    function getMessageHash(address holder, uint _maxvalue) public pure returns (bytes32){

        return keccak256(abi.encodePacked(holder, _maxvalue));
    }

    function getSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(address _signer, address holder, uint _maxvalue, bytes memory signature) public pure returns (bool) {

        bytes32 messageHash = getMessageHash(holder, _maxvalue);
        bytes32 signedMessageHash = getSignedMessageHash(messageHash);
        return recoverSigner(signedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _signedMessageHash, bytes memory _signature) public pure returns (address) {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_signedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {

        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}


contract ProjectName is AdminRole, VerifySignature{

  using SafeMath for uint256;

  event TokensaleInfo(address indexed signer, uint256 coinsvalue, uint256 tokensvalue, uint256 holder_max_project_tokens, uint256 allowed_coinsvalue, uint256 allowed_tokensvalue);

  uint8 private _tokensale_status;

  address public currency_token_address;
  TetherToken_interface private _currency_token;

  address public project_token_address;
  ProjectToken_interface private _project_token;

  uint256 private _token_price;

  address private _signer_address;

  mapping(address => uint256) private _sold_amounts;
  uint256 private _totalsold = 0;
  address[] private _participants;

  constructor () public {

    _tokensale_status = 2;

    _token_price = 1000000000000000000; //1 USDT * (10**18) = 1000000000000000000 wei, where 18 is decimal of USDT

    _signer_address = address(0xEe3EA17E0Ed56a794e9bAE6F7A6c6b43b93333F5);

    currency_token_address = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    _currency_token = TetherToken_interface(currency_token_address);

    project_token_address = address(0x7426d1A249672749945b6F217086D9F18E0df481);
    _project_token = ProjectToken_interface(project_token_address);

    _addAdmin(address(0x92C3b65677700eD595DA15A402f5d7C9A10a4e49));
    _addAdmin(address(0x1489a398BeB2171D48C458CfbA9Cf1Bd739C0438));
    _addAdmin(address(0xd0cF831E3a2E171220094C066Ec4263d24c0C715));

    transferOwnership(address(0));
  }

  function saleStatus() public view returns(string memory){

    if(_tokensale_status == 0){
      return "Closed";
    }else if(_tokensale_status == 1){
      return "Active";
    }else if(_tokensale_status == 2){
      return "Disabled";
    }
    return "Unknown"; //impossible
  }

  receive() external payable {
    require(false, "The contract does not accept the base coin of network.");
  }

  function tokenWithdrawal(address token_address, address recipient, uint256 value) public onlyOwnerOrAdmin {

    require(checkValidMultiSignatures(), "There is no required number of signatures");

    TetherToken_interface ct = TetherToken_interface(token_address);

    ct.transfer(recipient, value);

    cancelAllMultiSignatures();
  }

  function USDTWithdrawal(address recipient, uint256 value) public onlyOwnerOrAdmin {

    tokenWithdrawal(currency_token_address, recipient, value);
  }

  function getTokenPrice() public view returns(uint256){

    return _token_price;
  }

  function totalTokensSoldByAddress(address holder) public view returns(uint256){

    return _sold_amounts[holder];
  }

  function totalTokensSold() public view returns (uint256) {

      return _totalsold;
  }

  function getParticipantAddressByIndex(uint256 index) public view returns(address){

    return _participants[index];
  }

  function getNumberOfParticipants() public view returns(uint256){

    return _participants.length;
  }


  function setWhitelistAuthorityAddress(address signer) public onlyOwnerOrAdmin {

    require(checkValidMultiSignatures(), "There is no required number of signatures");

    require(_tokensale_status > 0, "Sales closed");

    _signer_address = signer;

    cancelAllMultiSignatures();
  }


  function getRemainingBalance(address holder, uint256 holder_max_project_tokens, bytes memory signature) public view returns (uint256) {

    require(verify(_signer_address, holder, holder_max_project_tokens, signature), "Incoming data have incorrectly signed");
    uint256 c = totalTokensSoldByAddress(holder);
    return holder_max_project_tokens.sub(c);
  }

  function checkEligibility(address holder, uint256 require_token_value, uint256 holder_max_project_tokens, bytes memory signature) public view returns (bool){

    uint256 v = getRemainingBalance(holder, holder_max_project_tokens, signature);
    if(v == 0 || require_token_value == 0){ return false; }
    return v >= require_token_value;
  }

  function tokenPurchase(uint256 require_token_value, uint256 holder_max_project_tokens, bytes memory signature) public{


    require(_tokensale_status==1, "Sales are not allowed");
    require(require_token_value > 0, "The requested amount of tokens for purchase must be greater than 0 (zero)");

    address sender = _msgSender();

    require(checkEligibility(sender, require_token_value, holder_max_project_tokens, signature), "Customer limited by max value");

    uint256 topay_value = require_token_value.mul(_token_price).div(10**_currency_token.decimals());

    uint256 c_value = _currency_token.balanceOf(sender);
    require(c_value >= topay_value, "The customer does not have enough USDT balance");

    c_value = _currency_token.allowance(sender, address(this));
    require(c_value >= topay_value, "Smart contact is not entitled to such an USDT amount");

    uint256 p_value = _project_token.balanceOf(_signer_address);
    require(p_value >= require_token_value, "The holder does not have enough project token balance");

    p_value = _project_token.allowance(_signer_address, address(this));
    require(p_value >= require_token_value, "Smart contact is not entitled to such a project token amount");

    emit TokensaleInfo(_signer_address, topay_value, require_token_value, holder_max_project_tokens, c_value, p_value);


    _currency_token.transferFrom(sender, address(this), topay_value);
    _project_token.transferFrom(_signer_address, sender, require_token_value);

    if(_sold_amounts[sender] == 0){
      _participants.push(sender);
    }

    _sold_amounts[sender] = _sold_amounts[sender].add(require_token_value);
    _totalsold = _totalsold.add(require_token_value);
  }

  function stopSales() public onlyOwnerOrAdmin{


    require(checkValidMultiSignatures(), "There is no required number of signatures");

    require(_tokensale_status > 0, "Sales is close");

    _tokensale_status = 2;

    cancelAllMultiSignatures();
  }

  function startSales() public onlyOwnerOrAdmin{


    require(checkValidMultiSignatures(), "There is no required number of signatures");

    require(_tokensale_status > 0, "Sales is close");

    _tokensale_status = 1;

    cancelAllMultiSignatures();
  }


  function stopTokensale() public onlyOwnerOrAdmin{

    require(checkValidMultiSignatures(), "There is no required number of signatures");

    _signer_address = address(0);

    _tokensale_status = 0;

    cancelAllMultiSignatures();
  }

}
