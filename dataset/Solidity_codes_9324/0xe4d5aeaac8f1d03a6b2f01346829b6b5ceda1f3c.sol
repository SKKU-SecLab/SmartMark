
pragma solidity >= 0.4.21 <= 0.5.12;


library ECDSA {


  function recover(bytes32 __hash, bytes memory __signature)
    internal
    pure
    returns (address)
  {

    bytes32 r;
    bytes32 s;
    uint8 v;

    if (__signature.length != 65) {
      return (address(0));
    }

    assembly {
      r := mload(add(__signature, 0x20))
      s := mload(add(__signature, 0x40))
      v := byte(0, mload(add(__signature, 0x60)))
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(__hash, v, r, s);
    }
  }  
}

contract DigitalSignatureRegistry {

    using ECDSA for bytes32;
    
    event DSA(bytes signature, bytes32 message, address consumer);
    
    event Allowance(address owner, address consumer);
    
    event Denial(address owner, address consumer);
    
    
    mapping(address => mapping(address => bool)) _allowedTo;
    
    mapping(bytes => address) private _consumer;
    
    mapping(bytes => bytes32) private _message;
    
    function allow(address __consumer) public {

        require(__consumer != address(0));
        require(msg.sender != address(0));
        
        _allowedTo[msg.sender][__consumer] = true;
        
        emit Allowance(msg.sender, __consumer);
    }
    
    function deny(address __consumer) public {

        require(__consumer != address(0));
        require(msg.sender != address(0));
        
        _allowedTo[msg.sender][__consumer] = false;
        
        emit Denial(msg.sender, __consumer);
    }
    
    function add(bytes memory __signature, bytes32 __message) public returns (bool) {

        
        require(_consumer[__signature] == address(0));
        
        require(msg.sender != address(0));
        
        address signer = __message.recover(__signature);
        
        require(msg.sender == signer || _allowedTo[signer][msg.sender]); 
        
        _consumer[__signature] = msg.sender;
        _message[__signature] = __message;
        
        emit DSA(__signature, __message, msg.sender);
        
        return true;
    }
    
    function consumer(bytes memory __signature) public view returns (address) {

        return _consumer[__signature];
    }
    
    function message(bytes memory __signature) public view returns (bytes32) {

        return _message[__signature];
    }
}