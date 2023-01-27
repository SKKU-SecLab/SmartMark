

pragma solidity ^0.6.7;

interface IERC20 {

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.8;


interface IERC165 {


    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}


pragma solidity ^0.6.8;


interface IERC1155 {



  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  event URI(string _amount, uint256 indexed _id);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;


  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}


pragma solidity ^0.6.8;

interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);

}


pragma solidity ^0.6.8;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c; 
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }
}


pragma solidity ^0.6.8;


library Address {


  bytes32 constant internal ACCOUNT_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

  function isContract(address _address) internal view returns (bool) {

    bytes32 codehash;

    assembly { codehash := extcodehash(_address) }
    return (codehash != 0x0 && codehash != ACCOUNT_HASH);
  }
}


pragma solidity ^0.6.8;

abstract contract ERC165 {
  function supportsInterface(bytes4 _interfaceID) virtual public pure returns (bool) {
    return _interfaceID == this.supportsInterface.selector;
  }
}


pragma solidity ^0.6.8;







contract ERC1155 is IERC1155, ERC165 {

  using SafeMath for uint256;
  using Address for address;


  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    public override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155#safeTransferFrom: INVALID_RECIPIENT");

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    public override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), _data);
  }



  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
    internal
  {

    balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount
    balances[_to][_id] = balances[_to][_id].add(_amount);     // Add amount

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received{gas: _gasLimit}(msg.sender, _from, _id, _amount, _data);
      require(retval == ERC1155_RECEIVED_VALUE, "ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    require(_ids.length == _amounts.length, "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH");

    uint256 nTransfer = _ids.length;

    for (uint256 i = 0; i < nTransfer; i++) {
      balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
      balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
    }

    emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
  }

  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived{gas: _gasLimit}(msg.sender, _from, _ids, _amounts, _data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
    }
  }



  function setApprovalForAll(address _operator, bool _approved)
    external override
  {

    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator)
    public override view returns (bool isOperator)
  {

    return operators[_owner][_operator];
  }



  function balanceOf(address _owner, uint256 _id)
    public override view returns (uint256)
  {

    return balances[_owner][_id];
  }

  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
    public override view returns (uint256[] memory)
  {

    require(_owners.length == _ids.length, "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH");

    uint256[] memory batchBalances = new uint256[](_owners.length);

    for (uint256 i = 0; i < _owners.length; i++) {
      batchBalances[i] = balances[_owners[i]][_ids[i]];
    }

    return batchBalances;
  }



  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {

    if (_interfaceID == type(IERC1155).interfaceId) {
      return true;
    }
    return super.supportsInterface(_interfaceID);
  }
}



pragma solidity ^0.6.8;


library LibBytes {

  using LibBytes for bytes;


  function popLastByte(bytes memory b)
    internal
    pure
    returns (bytes1 result)
  {

    require(
      b.length > 0,
      "LibBytes#popLastByte: GREATER_THAN_ZERO_LENGTH_REQUIRED"
    );

    result = b[b.length - 1];

    assembly {
      let newLen := sub(mload(b), 1)
      mstore(b, newLen)
    }
    return result;
  }



  function readBytes32(
    bytes memory b,
    uint256 index
  )
    internal
    pure
    returns (bytes32 result)
  {

    require(
      b.length >= index + 32,
      "LibBytes#readBytes32: GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
    );

    index += 32;

    assembly {
      result := mload(add(b, index))
    }
    return result;
  }
}


pragma solidity ^0.6.8;


interface  IERC1271Wallet {


  function isValidSignature(
    bytes calldata _data,
    bytes calldata _signature)
    external
    view
    returns (bytes4 magicValue);


  function isValidSignature(
    bytes32 _hash,
    bytes calldata _signature)
    external
    view
    returns (bytes4 magicValue);

}


pragma solidity ^0.6.8;


contract LibEIP712 {



  bytes32 internal constant DOMAIN_SEPARATOR_TYPEHASH = 0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;

  string constant internal EIP191_HEADER = "\x19\x01";


  function hashEIP712Message(bytes32 hashStruct)
      internal
      view
      returns (bytes32 result)
  {

    return keccak256(
      abi.encodePacked(
        EIP191_HEADER,
        keccak256(
          abi.encode(
            DOMAIN_SEPARATOR_TYPEHASH,
            address(this)
          )
        ),
        hashStruct
    ));
  }
}


pragma solidity ^0.6.8;




contract SignatureValidator is LibEIP712 {

  using LibBytes for bytes;


  bytes4 constant internal ERC1271_MAGICVALUE = 0x20c13b0b;

  bytes4 constant internal ERC1271_MAGICVALUE_BYTES32 = 0x1626ba7e;

  enum SignatureType {
    Illegal,         // 0x00, default value
    EIP712,          // 0x01
    EthSign,         // 0x02
    WalletBytes,     // 0x03 To call isValidSignature(bytes, bytes) on wallet contract
    WalletBytes32,   // 0x04 To call isValidSignature(bytes32, bytes) on wallet contract
    NSignatureTypes  // 0x05, number of signature types. Always leave at end.
  }



  function isValidSignature(
    address _signerAddress,
    bytes32 _hash,
    bytes memory _data,
    bytes memory _sig
  )
    public
    view
    returns (bool isValid)
  {

    require(
      _sig.length > 0,
      "SignatureValidator#isValidSignature: LENGTH_GREATER_THAN_0_REQUIRED"
    );

    require(
      _signerAddress != address(0x0),
      "SignatureValidator#isValidSignature: INVALID_SIGNER"
    );

    uint8 signatureTypeRaw = uint8(_sig.popLastByte());

    require(
      signatureTypeRaw < uint8(SignatureType.NSignatureTypes),
      "SignatureValidator#isValidSignature: UNSUPPORTED_SIGNATURE"
    );

    SignatureType signatureType = SignatureType(signatureTypeRaw);

    uint8 v;
    bytes32 r;
    bytes32 s;
    address recovered;

    if (signatureType == SignatureType.Illegal) {
      revert("SignatureValidator#isValidSignature: ILLEGAL_SIGNATURE");


    } else if (signatureType == SignatureType.EIP712) {
      require(
        _sig.length == 97,
        "SignatureValidator#isValidSignature: LENGTH_97_REQUIRED"
      );
      r = _sig.readBytes32(0);
      s = _sig.readBytes32(32);
      v = uint8(_sig[64]);
      recovered = ecrecover(_hash, v, r, s);
      isValid = _signerAddress == recovered;
      return isValid;


    } else if (signatureType == SignatureType.EthSign) {
      require(
        _sig.length == 97,
        "SignatureValidator#isValidSignature: LENGTH_97_REQUIRED"
      );
      r = _sig.readBytes32(0);
      s = _sig.readBytes32(32);
      v = uint8(_sig[64]);
      recovered = ecrecover(
        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)),
        v,
        r,
        s
      );
      isValid = _signerAddress == recovered;
      return isValid;


    } else if (signatureType == SignatureType.WalletBytes) {
      isValid = ERC1271_MAGICVALUE == IERC1271Wallet(_signerAddress).isValidSignature(_data, _sig);
      return isValid;


    } else if (signatureType == SignatureType.WalletBytes32) {
      isValid = ERC1271_MAGICVALUE_BYTES32 == IERC1271Wallet(_signerAddress).isValidSignature(_hash, _sig);
      return isValid;
    }

    revert("SignatureValidator#isValidSignature: UNSUPPORTED_SIGNATURE");
  }
}


pragma solidity ^0.6.8;








contract ERC1155Meta is ERC1155, SignatureValidator {

  using LibBytes for bytes;


  struct GasReceipt {
    uint256 gasFee;           // Fixed cost for the tx
    uint256 gasLimitCallback; // Maximum amount of gas the callback in transfer functions can use
    address feeRecipient;     // Address to send payment to
    bytes feeTokenData;       // Data for token to pay for gas
  }

  enum FeeTokenType {
    ERC1155,    // 0x00, ERC-1155 token - DEFAULT
    ERC20,      // 0x01, ERC-20 token
    NTypes      // 0x02, number of signature types. Always leave at end.
  }

  mapping (address => uint256) internal nonces;



  event NonceChange(address indexed signer, uint256 newNonce);



  function metaSafeTransferFrom(
    address _from,
    address _to,
    uint256 _id,
    uint256 _amount,
    bool _isGasFee,
    bytes memory _data)
    public
  {

    require(_to != address(0), "ERC1155Meta#metaSafeTransferFrom: INVALID_RECIPIENT");

    bytes memory transferData;
    GasReceipt memory gasReceipt;

    bytes memory signedData = _signatureValidation(
      _from,
      _data,
      abi.encode(
        META_TX_TYPEHASH,
        _from, // Address as uint256
        _to,   // Address as uint256
        _id,
        _amount,
        _isGasFee ? uint256(1) : uint256(0)  // Boolean as uint256
      )
    );

    _safeTransferFrom(_from, _to, _id, _amount);

    if (_isGasFee) {
      (gasReceipt, transferData) = abi.decode(signedData, (GasReceipt, bytes));

      _callonERC1155Received(_from, _to, _id, _amount, gasReceipt.gasLimitCallback, transferData);

      _transferGasFee(_from, gasReceipt);

    } else {
      _callonERC1155Received(_from, _to, _id, _amount, gasleft(), signedData);
    }
  }

  function metaSafeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _ids,
    uint256[] memory _amounts,
    bool _isGasFee,
    bytes memory _data)
    public
  {

    require(_to != address(0), "ERC1155Meta#metaSafeBatchTransferFrom: INVALID_RECIPIENT");

    bytes memory transferData;
    GasReceipt memory gasReceipt;

    bytes memory signedData = _signatureValidation(
      _from,
      _data,
      abi.encode(
        META_BATCH_TX_TYPEHASH,
        _from, // Address as uint256
        _to,   // Address as uint256
        keccak256(abi.encodePacked(_ids)),
        keccak256(abi.encodePacked(_amounts)),
        _isGasFee ? uint256(1) : uint256(0)  // Boolean as uint256
      )
    );

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);

    if (_isGasFee) {
      (gasReceipt, transferData) = abi.decode(signedData, (GasReceipt, bytes));

      _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasReceipt.gasLimitCallback, transferData);

      _transferGasFee(_from, gasReceipt);

    } else {
      _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), signedData);
    }
  }



  function metaSetApprovalForAll(
    address _owner,
    address _operator,
    bool _approved,
    bool _isGasFee,
    bytes memory _data)
    public
  {

    bytes memory signedData = _signatureValidation(
      _owner,
      _data,
      abi.encode(
        META_APPROVAL_TYPEHASH,
        _owner,                              // Address as uint256
        _operator,                           // Address as uint256
        _approved ? uint256(1) : uint256(0), // Boolean as uint256
        _isGasFee ? uint256(1) : uint256(0)  // Boolean as uint256
      )
    );

    operators[_owner][_operator] = _approved;

    emit ApprovalForAll(_owner, _operator, _approved);

    if (_isGasFee) {
      GasReceipt memory gasReceipt = abi.decode(signedData, (GasReceipt));
      _transferGasFee(_owner, gasReceipt);
    }
  }



  bytes32 internal constant META_TX_TYPEHASH = 0xce0b514b3931bdbe4d5d44e4f035afe7113767b7db71949271f6a62d9c60f558;

  bytes32 internal constant META_BATCH_TX_TYPEHASH = 0xa3d4926e8cf8fe8e020cd29f514c256bc2eec62aa2337e415f1a33a4828af5a0;

  bytes32 internal constant META_APPROVAL_TYPEHASH = 0xf5d4c820494c8595de274c7ff619bead38aac4fbc3d143b5bf956aa4b84fa524;

  function _signatureValidation(
    address _signer,
    bytes memory _sigData,
    bytes memory _encMembers)
    internal returns (bytes memory signedData)
  {

    bytes memory sig;

    (sig, signedData) = abi.decode(_sigData, (bytes, bytes));

    uint256 currentNonce = nonces[_signer];        // Lowest valid nonce for signer
    uint256 nonce = uint256(sig.readBytes32(65));  // Nonce passed in the signature object

    require(
      (nonce >= currentNonce) && (nonce < (currentNonce + 100)),
      "ERC1155Meta#_signatureValidation: INVALID_NONCE"
    );

    bytes32 hash = hashEIP712Message(keccak256(abi.encodePacked(_encMembers, nonce, keccak256(signedData))));

    bytes memory fullData = abi.encodePacked(_encMembers, nonce, signedData);

    nonces[_signer] = nonce + 1;
    emit NonceChange(_signer, nonce + 1);

    require(isValidSignature(_signer, hash, fullData, sig), "ERC1155Meta#_signatureValidation: INVALID_SIGNATURE");
    return signedData;
  }

  function getNonce(address _signer)
    public view returns (uint256 nonce)
  {

    return nonces[_signer];
  }



  function _transferGasFee(address _from, GasReceipt memory _g)
      internal
  {

    uint8 feeTokenTypeRaw = uint8(_g.feeTokenData.popLastByte());

    require(
      feeTokenTypeRaw < uint8(FeeTokenType.NTypes),
      "ERC1155Meta#_transferGasFee: UNSUPPORTED_TOKEN"
    );

    FeeTokenType feeTokenType = FeeTokenType(feeTokenTypeRaw);

    address tokenAddress;
    address feeRecipient;
    uint256 tokenID;
    uint256 fee = _g.gasFee;

    feeRecipient = _g.feeRecipient == address(0) ? msg.sender : _g.feeRecipient;

    if (feeTokenType == FeeTokenType.ERC1155) {
      (tokenAddress, tokenID) = abi.decode(_g.feeTokenData, (address, uint256));

      if (tokenAddress == address(this)) {
        _safeTransferFrom(_from, feeRecipient, tokenID, fee);

        _callonERC1155Received(_from, feeRecipient, tokenID, gasleft(), fee, "");

      } else {
        IERC1155(tokenAddress).safeTransferFrom(_from, feeRecipient, tokenID, fee, "");
      }

    } else {
      tokenAddress = abi.decode(_g.feeTokenData, (address));
      require(
        IERC20(tokenAddress).transferFrom(_from, feeRecipient, fee),
        "ERC1155Meta#_transferGasFee: ERC20_TRANSFER_FAILED"
      );
    }
  }
}


pragma solidity ^0.6.8;



contract ERC1155MintBurn is ERC1155 {



  function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
    internal
  {

    balances[_to][_id] = balances[_to][_id].add(_amount);

    emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

    _callonERC1155Received(address(0x0), _to, _id, _amount, gasleft(), _data);
  }

  function _batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal
  {

    require(_ids.length == _amounts.length, "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH");

    uint256 nMint = _ids.length;

    for (uint256 i = 0; i < nMint; i++) {
      balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
    }

    emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

    _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, gasleft(), _data);
  }



  function _burn(address _from, uint256 _id, uint256 _amount)
    internal
  {

    balances[_from][_id] = balances[_from][_id].sub(_amount);

    emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
  }

  function _batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    uint256 nBurn = _ids.length;
    require(nBurn == _amounts.length, "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH");

    for (uint256 i = 0; i < nBurn; i++) {
      balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
    }

    emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
  }
}


pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;








contract flatMetaERC20Wrapper is ERC1155Meta, ERC1155MintBurn {


  uint256 internal nTokens = 1;                         // Number of ERC-20 tokens registered
  uint256 constant internal ETH_ID = 0x1;               // ID fo tokens representing Ether is 1
  address constant internal ETH_ADDRESS = address(0x1); // Address for tokens representing Ether is 0x00...01
  mapping (address => uint256) internal addressToID;    // Maps the ERC-20 addresses to their metaERC20 id
  mapping (uint256 => address) internal IDtoAddress;    // Maps the metaERC20 ids to their ERC-20 address



  event TokenRegistration(address token_address, uint256 token_id);


  constructor() public {
    addressToID[ETH_ADDRESS] = ETH_ID;
    IDtoAddress[ETH_ID] = ETH_ADDRESS;
  }


  receive () external payable {
    deposit(ETH_ADDRESS, msg.sender, msg.value);
  }

  function deposit(address _token, address _recipient, uint256 _value)
    public payable
  {

    require(_recipient != address(0x0), "MetaERC20Wrapper#deposit: INVALID_RECIPIENT");

    uint256 id;

    if (_token != ETH_ADDRESS) {

      require(msg.value == 0, "MetaERC20Wrapper#deposit: NON_NULL_MSG_VALUE");
      IERC20(_token).transferFrom(msg.sender, address(this), _value);
      require(checkSuccess(), "MetaERC20Wrapper#deposit: TRANSFER_FAILED");

      uint256 addressId = addressToID[_token];

      if (addressId == 0) {
        nTokens += 1;             // Increment number of tokens registered
        id = nTokens;             // id of token is the current # of tokens
        IDtoAddress[id] = _token; // Map id to token address
        addressToID[_token] = id; // Register token

        emit TokenRegistration(_token, id);

      } else {
        id = addressId;
      }

    } else {
      require(_value == msg.value, "MetaERC20Wrapper#deposit: INCORRECT_MSG_VALUE");
      id = ETH_ID;
    }

    _mint(_recipient, id, _value, "");
  }



  function withdraw(address _token, address payable _to, uint256 _value) public {

    uint256 tokenID = getTokenID(_token);
    _withdraw(msg.sender, _to, tokenID, _value);
  }

  function _withdraw(
    address _from,
    address payable _to,
    uint256 _tokenID,
    uint256 _value)
    internal
  {

    _burn(_from, _tokenID, _value);

    if (_tokenID != ETH_ID) {
      address token = IDtoAddress[_tokenID];
      IERC20(token).transfer(_to, _value);
      require(checkSuccess(), "MetaERC20Wrapper#withdraw: TRANSFER_FAILED");

    } else {
      require(_to != address(0), "MetaERC20Wrapper#withdraw: INVALID_RECIPIENT");
      (bool success, ) = _to.call{value: _value}("");
      require(success, "MetaERC20Wrapper#withdraw: TRANSFER_FAILED");
    }


  }
  function onERC1155Received(address, address payable _from, uint256 _id, uint256 _value, bytes memory)
    public returns(bytes4)
  {

    require(msg.sender == address(this), "MetaERC20Wrapper#onERC1155Received: INVALID_ERC1155_RECEIVED");
    getIdAddress(_id); // Checks if id is registered

    _withdraw(address(this), _from, _id, _value);

    return ERC1155_RECEIVED_VALUE;
  }

  function onERC1155BatchReceived(address, address payable _from, uint256[] memory _ids, uint256[] memory _values, bytes memory)
    public returns(bytes4)
  {

    require(msg.sender == address(this), "MetaERC20Wrapper#onERC1155BatchReceived: INVALID_ERC1155_RECEIVED");

    for ( uint256 i = 0; i < _ids.length; i++) {
      getIdAddress(_ids[i]);

      _withdraw(address(this), _from, _ids[i], _values[i]);
    }

    return ERC1155_BATCH_RECEIVED_VALUE;
  }

  function getTokenID(address _token) public view returns (uint256 tokenID) {

    tokenID = addressToID[_token];
    require(tokenID != 0, "MetaERC20Wrapper#getTokenID: UNREGISTERED_TOKEN");
    return tokenID;
  }

  function getIdAddress(uint256 _id) public view returns (address token) {

    token = IDtoAddress[_id];
    require(token != address(0x0), "MetaERC20Wrapper#getIdAddress: UNREGISTERED_TOKEN");
    return token;
  }

  function getNTokens() external view returns (uint256) {

    return nTokens;
  }




  function checkSuccess()
    private pure
    returns (bool)
  {

    uint256 returnValue = 0;

    assembly {
      switch returndatasize()

        case 0x0 {
          returnValue := 1
        }

        case 0x20 {
          returndatacopy(0x0, 0x0, 0x20)

          returnValue := mload(0x0)
        }

        default { }
      
    }

    return returnValue != 0;
  }

  function supportsInterface(bytes4 interfaceID) public override pure returns (bool) {

    return  interfaceID == type(IERC165).interfaceId ||
      interfaceID == type(IERC1155).interfaceId || 
      interfaceID == type(IERC1155TokenReceiver).interfaceId;        
  }

}