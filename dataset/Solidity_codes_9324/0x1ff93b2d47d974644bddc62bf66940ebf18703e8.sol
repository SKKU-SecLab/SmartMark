

pragma solidity ^0.4.24;

library SafeMath{

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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


contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}

contract SiuCoin is Ownable {

    using SafeMath for uint256;
    
    string public constant symbol = "SIU";
    string public constant name = "Siucoin";
    
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1500000 * (10 ** 18);
    
    bytes4 internal constant transferSig = 0xa9059cbb;
    bytes4 internal constant approveSig = 0x095ea7b3;
    bytes4 internal constant increaseApprovalSig = 0xd73dd623;
    bytes4 internal constant decreaseApprovalSig = 0x66188463;
    bytes4 internal constant approveAndCallSig = 0xcae9ca51;
    bytes4 internal constant revokeSignatureSig = 0xe40d89e5;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;
    
    mapping (address => uint256) nonces;
    
    mapping (address => mapping (bytes => bool)) invalidSignatures;

    mapping (bytes4 => bytes4) public standardSigs;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed from, address indexed spender, uint tokens);
    event SignatureRedeemed(bytes _sig, address indexed from);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 value);

       
    constructor()
      public
    {
        balances[0xDbCCd61648edFFD465A50a7929B9f7a278Fd7D56] = 1000000 ether;
        balances[0xca1504e201d4Dc31691b70653EB7Dcb1691bc62B] = 500000 ether;
    }
    
    
        
    function _burn(address _who, uint256 _value) onlyOwner public returns (bool) {

            require(_value <= balances[_who]);
            
            balances[_who] = balances[_who].sub(_value);
            _totalSupply = _totalSupply.sub(_value);
            emit Burn(_who, _value);
            emit Transfer(_who, address(0), _value);
            
            return true;
    
    }
        
    function _mint(address _to, uint256 _amount) onlyOwner public returns (bool) {

            _totalSupply = SafeMath.add(_totalSupply, _amount);
            balances[_to] = balances[_to].add(_amount);
            emit Mint(_to, _amount);
            emit Transfer(0x0000000000000000000000000000000000000000, _to, _amount);
            return true;
        }
    
    function () 
      public
    {
        bytes memory calldata = msg.data;
        bytes4 new_selector = standardSigs[msg.sig];
        require(new_selector != 0);
        
        assembly {
           mstore(add(0x20, calldata), new_selector)
        }
        
        require(address(this).delegatecall(calldata));
        
        assembly {
            if iszero(eq(returndatasize, 0x20)) { revert(0, 0) }
            returndatacopy(0, 0, returndatasize)
            return(0, returndatasize)
        }
    }


    function transfer(address _to, uint256 _amount) public returns (bool success) {

        require(_transfer(msg.sender, _to, _amount));
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {

        require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        require(_transfer(_from, _to, _amount));
        return true;
    }
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {

        require(_approve(msg.sender, _spender, _amount));
        return true;
    }
    
    
    function increaseApproval(address _spender, uint256 _amount) 
      public
    returns (bool success)
    {

        require(_increaseApproval(msg.sender, _spender, _amount));
        return true;
    }
    
    
    function decreaseApproval(address _spender, uint256 _amount) 
      public
    returns (bool success)
    {

        require(_decreaseApproval(msg.sender, _spender, _amount));
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _amount, bytes _data) 
      public
    returns (bool success) 
    {

        require(_approve(msg.sender, _spender, _amount));
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, address(this), _data);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _amount)
      internal
    returns (bool success)
    {

        require (_to != address(0));
        require(balances[_from] >= _amount);
        
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
   
    function _approve(address _owner, address _spender, uint256 _amount) 
      internal
    returns (bool success)
    {

        allowed[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
        return true;
    }
    
    function _increaseApproval(address _owner, address _spender, uint256 _amount)
      internal
    returns (bool success)
    {

        allowed[_owner][_spender] = allowed[_owner][_spender].add(_amount);
        emit Approval(_owner, _spender, allowed[_owner][_spender]);
        return true;
    }
    
    function _decreaseApproval(address _owner, address _spender, uint256 _amount)
      internal
    returns (bool success)
    {

        if (allowed[_owner][_spender] <= _amount) allowed[_owner][_spender] = 0;
        else allowed[_owner][_spender] = allowed[_owner][_spender].sub(_amount);
        
        emit Approval(_owner, _spender, allowed[_owner][_spender]);
        return true;
    }
    
    function transferPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value, 
        bytes _extraData,
        uint256 _nonce) 
      public
      validPayload(292)
    returns (bool) 
    {


        address from = recoverPreSigned(_signature, transferSig, _to, _value, _extraData, _nonce);
        require(from != address(0));
        
        require(!invalidSignatures[from][_signature]);
        invalidSignatures[from][_signature] = true;
        nonces[from]++;
        
        require(_transfer(from, _to, _value));

       
        emit SignatureRedeemed(_signature, from);
        return true;
    }
   
    function approvePreSigned(
        bytes _signature,
        address _to, 
        uint256 _value, 
        bytes _extraData,
        uint256 _nonce) 
      public
      validPayload(292)
    returns (bool) 
    {

        address from = recoverPreSigned(_signature, approveSig, _to, _value, _extraData, _nonce);
        require(from != address(0));
        require(!invalidSignatures[from][_signature]);
        
        invalidSignatures[from][_signature] = true;
        nonces[from]++;
        
        require(_approve(from, _to, _value));

        
        emit SignatureRedeemed(_signature, from);
        return true;
    }
    
  
    function increaseApprovalPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value, 
        bytes _extraData,
        uint256 _nonce)
      public
      validPayload(292)
    returns (bool) 
    {

        address from = recoverPreSigned(_signature, increaseApprovalSig, _to, _value, _extraData, _nonce);
        require(from != address(0));
        require(!invalidSignatures[from][_signature]);
        
        invalidSignatures[from][_signature] = true;
        nonces[from]++;
        
        require(_increaseApproval(from, _to, _value));

        
        emit SignatureRedeemed(_signature, from);
        return true;
    }
    
    function decreaseApprovalPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value, 
        bytes _extraData,

        uint256 _nonce) 
      public
      validPayload(292)
    returns (bool) 
    {

        
        address from = recoverPreSigned(_signature, decreaseApprovalSig, _to, _value, _extraData, _nonce);
        require(from != address(0));
        require(!invalidSignatures[from][_signature]);
        
        invalidSignatures[from][_signature] = true;
        nonces[from]++;
        
        require(_decreaseApproval(from, _to, _value));

    
        emit SignatureRedeemed(_signature, from);
        return true;
    }
    
    function approveAndCallPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value,
        bytes _extraData,
        uint256 _nonce) 
      public
      validPayload(356)
    returns (bool) 
    {

        address from = recoverPreSigned(_signature, approveAndCallSig, _to, _value, _extraData, _nonce);
        require(from != address(0));
        require(!invalidSignatures[from][_signature]);
        
        invalidSignatures[from][_signature] = true;
        nonces[from]++;
        
        require(_approve(from, _to, _value));
        ApproveAndCallFallBack(_to).receiveApproval(from, _value, address(this), _extraData);

      
        
        emit SignatureRedeemed(_signature, from);
        return true;
    }

    function revokeSignature(bytes _sigToRevoke)
      public
    returns (bool)
    {

        invalidSignatures[msg.sender][_sigToRevoke] = true;
        
        emit SignatureRedeemed(_sigToRevoke, msg.sender);
        return true;
    }
    
  
    function revokeSignaturePreSigned(
        bytes _signature,
        bytes _sigToRevoke
        )
      public
      validPayload(356)
    returns (bool)
    {

        address from = recoverRevokeHash(_signature, _sigToRevoke);
        require(!invalidSignatures[from][_signature]);
        invalidSignatures[from][_signature] = true;
        
        invalidSignatures[from][_sigToRevoke] = true;
        
        
        emit SignatureRedeemed(_signature, from);
        return true;
    }
    
    
    function getRevokeHash(bytes _sigToRevoke)
      public
      pure
    returns (bytes32 txHash)
    {

        return keccak256(revokeSignatureSig, _sigToRevoke);
    }

   
    function recoverRevokeHash(bytes _signature, bytes _sigToRevoke)
      public
      pure
    returns (address from)
    {

        return ecrecoverFromSig(getSignHash(getRevokeHash(_sigToRevoke)), _signature);
    }
    
    function getPreSignedHash(
        bytes4 _function,
        address _to, 
        uint256 _value,
        bytes _extraData,
        uint256 _nonce)
      public
      view
    returns (bytes32 txHash) 
    {

        return keccak256(address(this), _function, _to, _value, _extraData, _nonce);
    }
    
   
    function recoverPreSigned(
        bytes _sig,
        bytes4 _function,
        address _to,
        uint256 _value,
        bytes _extraData,
        uint256 _nonce) 
      public
      view
    returns (address recovered)
    {

        bytes32 hexdData = getPreSignedHash(_function, _to, _value, _extraData, _nonce);
        return ecrecoverFromSig( keccak256("\x19Ethereum Signed Message:\n32",hexdData), _sig);
    }
    
    function getSignHash(bytes32 _hash)
      public
      pure
    returns (bytes32 signHash)
    {

        return keccak256("\x19Ethereum Signed Message:\n32", _hash);
    }

    function ecrecoverFromSig(bytes32 hash, bytes sig) 
      public 
      pure 
    returns (address recoveredAddress) 
    {

        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != 65) return address(0);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
          v += 27;
        }
        if (v != 27 && v != 28) return address(0);
        return ecrecover(hash, v, r, s);
    }

    function getNonce(address _owner)
      external
      view
    returns (uint256 nonce)
    {

        return nonces[_owner];
    }
    
    
    function totalSupply() 
      external
      view 
     returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address _owner)
      external
      view 
    returns (uint256) 
    {

        return balances[_owner];
    }
    
    function allowance(address _owner, address _spender) 
      external
      view 
    returns (uint256) 
    {

        return allowed[_owner][_spender];
    }
    
    
    function token_escape(address _tokenContract)
      external
      onlyOwner
    {

        SiuCoin lostToken = SiuCoin(_tokenContract);
        
        uint256 stuckTokens = lostToken.balanceOf(address(this));
        lostToken.transfer(owner, stuckTokens);
    }
    
    function updateStandard(bytes4 _standardSig, bytes4 _ourSig)
      external
      onlyOwner
    returns (bool success)
    {

        require(_ourSig == 0x1296830d || _ourSig == 0x617b390b || _ourSig == 0xadb8249e ||
            _ourSig == 0x8be52783 || _ourSig == 0xc8d4b389 || _ourSig == 0xe391a7c4);
        standardSigs[_standardSig] = _ourSig;
        return true;
    }
    
    
    modifier validPayload(uint _size) {

        uint payload_size;
        assembly {
            payload_size := calldatasize
        }
        require(payload_size >= _size);
        _;
    }
    
}