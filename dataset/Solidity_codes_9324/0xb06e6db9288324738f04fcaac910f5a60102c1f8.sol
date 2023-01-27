pragma solidity ^0.8.13;

contract ECRecovery {


    function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }
}pragma solidity ^0.8.13;

struct EIP712Domain {
  string name;
  string version;
  uint256 chainId;
  address verifyingContract;
}

bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

struct Invocation {
  Transaction transaction;
  SignedDelegation[] authority;
}

bytes32 constant INVOCATION_TYPEHASH = keccak256("Invocation(Transaction transaction,SignedDelegation[] authority)Caveat(address enforcer,bytes terms)Delegation(address delegate,bytes32 authority,Caveat[] caveats)SignedDelegation(Delegation delegation,bytes signature)Transaction(address to,uint256 gasLimit,bytes data)");

struct Invocations {
  Invocation[] batch;
  ReplayProtection replayProtection;
}

bytes32 constant INVOCATIONS_TYPEHASH = keccak256("Invocations(Invocation[] batch,ReplayProtection replayProtection)Caveat(address enforcer,bytes terms)Delegation(address delegate,bytes32 authority,Caveat[] caveats)Invocation(Transaction transaction,SignedDelegation[] authority)ReplayProtection(uint nonce,uint queue)SignedDelegation(Delegation delegation,bytes signature)Transaction(address to,uint256 gasLimit,bytes data)");

struct SignedInvocation {
  Invocations invocations;
  bytes signature;
}

bytes32 constant SIGNEDINVOCATION_TYPEHASH = keccak256("SignedInvocation(Invocations invocations,bytes signature)Caveat(address enforcer,bytes terms)Delegation(address delegate,bytes32 authority,Caveat[] caveats)Invocation(Transaction transaction,SignedDelegation[] authority)Invocations(Invocation[] batch,ReplayProtection replayProtection)ReplayProtection(uint nonce,uint queue)SignedDelegation(Delegation delegation,bytes signature)Transaction(address to,uint256 gasLimit,bytes data)");

struct Transaction {
  address to;
  uint256 gasLimit;
  bytes data;
}

bytes32 constant TRANSACTION_TYPEHASH = keccak256("Transaction(address to,uint256 gasLimit,bytes data)");

struct ReplayProtection {
  uint nonce;
  uint queue;
}

bytes32 constant REPLAYPROTECTION_TYPEHASH = keccak256("ReplayProtection(uint nonce,uint queue)");

struct Delegation {
  address delegate;
  bytes32 authority;
  Caveat[] caveats;
}

bytes32 constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegate,bytes32 authority,Caveat[] caveats)Caveat(address enforcer,bytes terms)");

struct Caveat {
  address enforcer;
  bytes terms;
}

bytes32 constant CAVEAT_TYPEHASH = keccak256("Caveat(address enforcer,bytes terms)");

struct SignedDelegation {
  Delegation delegation;
  bytes signature;
}

bytes32 constant SIGNEDDELEGATION_TYPEHASH = keccak256("SignedDelegation(Delegation delegation,bytes signature)Caveat(address enforcer,bytes terms)Delegation(address delegate,bytes32 authority,Caveat[] caveats)");

struct IntentionToRevoke {
  bytes32 delegationHash;
}

bytes32 constant INTENTIONTOREVOKE_TYPEHASH = keccak256("IntentionToRevoke(bytes32 delegationHash)");

struct SignedIntentionToRevoke {
  bytes signature;
  IntentionToRevoke intentionToRevoke;
}

bytes32 constant SIGNEDINTENTIONTOREVOKE_TYPEHASH = keccak256("SignedIntentionToRevoke(bytes signature,IntentionToRevoke intentionToRevoke)IntentionToRevoke(bytes32 delegationHash)");


contract EIP712Decoder is ECRecovery {



  function GET_EIP712DOMAIN_PACKETHASH (EIP712Domain memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      EIP712DOMAIN_TYPEHASH,
      _input.name,
      _input.version,
      _input.chainId,
      _input.verifyingContract
    );
    
    return keccak256(encoded);
  }

  function GET_INVOCATION_PACKETHASH (Invocation memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      INVOCATION_TYPEHASH,
      GET_TRANSACTION_PACKETHASH(_input.transaction),
      GET_SIGNEDDELEGATION_ARRAY_PACKETHASH(_input.authority)
    );
    
    return keccak256(encoded);
  }

  function GET_SIGNEDDELEGATION_ARRAY_PACKETHASH (SignedDelegation[] memory _input) public pure returns (bytes32) {
    bytes memory encoded;
    for (uint i = 0; i < _input.length; i++) {
      encoded = bytes.concat(
        encoded,
        GET_SIGNEDDELEGATION_PACKETHASH(_input[i])
      );
    }
    
    bytes32 hash = keccak256(encoded);
    return hash;
  }

  function GET_INVOCATIONS_PACKETHASH (Invocations memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      INVOCATIONS_TYPEHASH,
      GET_INVOCATION_ARRAY_PACKETHASH(_input.batch),
      GET_REPLAYPROTECTION_PACKETHASH(_input.replayProtection)
    );
    
    return keccak256(encoded);
  }

  function GET_INVOCATION_ARRAY_PACKETHASH (Invocation[] memory _input) public pure returns (bytes32) {
    bytes memory encoded;
    for (uint i = 0; i < _input.length; i++) {
      encoded = bytes.concat(
        encoded,
        GET_INVOCATION_PACKETHASH(_input[i])
      );
    }
    
    bytes32 hash = keccak256(encoded);
    return hash;
  }

  function GET_SIGNEDINVOCATION_PACKETHASH (SignedInvocation memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      SIGNEDINVOCATION_TYPEHASH,
      GET_INVOCATIONS_PACKETHASH(_input.invocations),
      keccak256(_input.signature)
    );
    
    return keccak256(encoded);
  }

  function GET_TRANSACTION_PACKETHASH (Transaction memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      TRANSACTION_TYPEHASH,
      _input.to,
      _input.gasLimit,
      keccak256(_input.data)
    );
    
    return keccak256(encoded);
  }

  function GET_REPLAYPROTECTION_PACKETHASH (ReplayProtection memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      REPLAYPROTECTION_TYPEHASH,
      _input.nonce,
      _input.queue
    );
    
    return keccak256(encoded);
  }

  function GET_DELEGATION_PACKETHASH (Delegation memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      DELEGATION_TYPEHASH,
      _input.delegate,
      _input.authority,
      GET_CAVEAT_ARRAY_PACKETHASH(_input.caveats)
    );
    
    return keccak256(encoded);
  }

  function GET_CAVEAT_ARRAY_PACKETHASH (Caveat[] memory _input) public pure returns (bytes32) {
    bytes memory encoded;
    for (uint i = 0; i < _input.length; i++) {
      encoded = bytes.concat(
        encoded,
        GET_CAVEAT_PACKETHASH(_input[i])
      );
    }
    
    bytes32 hash = keccak256(encoded);
    return hash;
  }

  function GET_CAVEAT_PACKETHASH (Caveat memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      CAVEAT_TYPEHASH,
      _input.enforcer,
      keccak256(_input.terms)
    );
    
    return keccak256(encoded);
  }

  function GET_SIGNEDDELEGATION_PACKETHASH (SignedDelegation memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      SIGNEDDELEGATION_TYPEHASH,
      GET_DELEGATION_PACKETHASH(_input.delegation),
      keccak256(_input.signature)
    );
    
    return keccak256(encoded);
  }

  function GET_INTENTIONTOREVOKE_PACKETHASH (IntentionToRevoke memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      INTENTIONTOREVOKE_TYPEHASH,
      _input.delegationHash
    );
    
    return keccak256(encoded);
  }

  function GET_SIGNEDINTENTIONTOREVOKE_PACKETHASH (SignedIntentionToRevoke memory _input) public pure returns (bytes32) {
    
    bytes memory encoded = abi.encode(
      SIGNEDINTENTIONTOREVOKE_TYPEHASH,
      keccak256(_input.signature),
      GET_INTENTIONTOREVOKE_PACKETHASH(_input.intentionToRevoke)
    );
    
    return keccak256(encoded);
  }

}pragma solidity ^0.8.13;


abstract contract CaveatEnforcer {
  function enforceCaveat (bytes calldata terms, Transaction calldata tx, bytes32 delegationHash) virtual public returns (bool);
}pragma solidity ^0.8.13;


abstract contract Delegatable is EIP712Decoder {
  event DelegationTriggered(address principal, address indexed agent);

  bytes32 public immutable domainHash;
  constructor (string memory contractName, string memory version) {
    domainHash = getEIP712DomainHash(contractName,version,block.chainid,address(this));
  }  

  function invoke (SignedInvocation[] calldata signedInvocations) public returns (bool success) {
    for (uint i = 0; i < signedInvocations.length; i++) {
      SignedInvocation calldata signedInvocation = signedInvocations[i];
      address invocationSigner = verifyInvocationSignature(signedInvocation);
      enforceReplayProtection(invocationSigner, signedInvocations[i].invocations.replayProtection);
      _invoke(signedInvocation.invocations.batch, invocationSigner);
    }
  }

  function contractInvoke (Invocation[] calldata batch) public returns (bool) {
    return _invoke(batch, msg.sender);
  }

  function _invoke (Invocation[] calldata batch, address sender) private returns (bool success) {
    for (uint x = 0; x < batch.length; x++) {
      Invocation memory invocation = batch[x];
      address intendedSender;
      address canGrant;

      if (invocation.authority.length == 0) {
        intendedSender = sender;
        canGrant = intendedSender;
      }

      bytes32 authHash = 0x0;

      for (uint d = 0; d < invocation.authority.length; d++) {
        SignedDelegation memory signedDelegation = invocation.authority[d];
        address delegationSigner = verifyDelegationSignature(signedDelegation);

        if (d == 0) {
          intendedSender = delegationSigner;
          canGrant = intendedSender;
        }

        require(delegationSigner == canGrant, "Delegation signer does not match required signer");

        Delegation memory delegation = signedDelegation.delegation;
        require(delegation.authority == authHash, "Delegation authority does not match previous delegation");

        bytes32 delegationHash = GET_SIGNEDDELEGATION_PACKETHASH(signedDelegation);

        for (uint16 y = 0; y < delegation.caveats.length; y++) {
          CaveatEnforcer enforcer = CaveatEnforcer(delegation.caveats[y].enforcer);
          bool caveatSuccess = enforcer.enforceCaveat(delegation.caveats[y].terms, invocation.transaction, delegationHash);
          require(caveatSuccess, "Caveat rejected");
        }

        authHash = delegationHash;
        canGrant = delegation.delegate;
      }

      Transaction memory transaction = invocation.transaction;

      require(transaction.to == address(this), "Invocation target does not match");
      emit DelegationTriggered(intendedSender, sender);
      success = execute(
        transaction.to,
        transaction.data,
        transaction.gasLimit,
        intendedSender
      );
      require(success, "Delegator execution failed");
    }
  }

  mapping(address => mapping(uint => uint)) public multiNonce;
  function enforceReplayProtection (address intendedSender, ReplayProtection memory protection) private {
    uint queue = protection.queue;
    uint nonce = protection.nonce;
    require(nonce == (multiNonce[intendedSender][queue]+1), "One-at-a-time order enforced. Nonce2 is too small");
    multiNonce[intendedSender][queue] = nonce;
  }

  function execute(
      address to,
      bytes memory data,
      uint256 gasLimit,
      address sender
  ) internal returns (bool success) {
    bytes memory full = abi.encodePacked(data, sender);
    assembly {
      success := call(gasLimit, to, 0, add(full, 0x20), mload(full), 0, 0)
    }
  }

  function verifyInvocationSignature (SignedInvocation memory signedInvocation) public view returns (address) {
    bytes32 sigHash = getInvocationsTypedDataHash(signedInvocation.invocations);
    address recoveredSignatureSigner = recover(sigHash, signedInvocation.signature);
    return recoveredSignatureSigner;
  } 

  function verifyDelegationSignature (SignedDelegation memory signedDelegation) public view returns (address) {
    Delegation memory delegation = signedDelegation.delegation;
    bytes32 sigHash = getDelegationTypedDataHash(delegation);
    address recoveredSignatureSigner = recover(sigHash, signedDelegation.signature);
    return recoveredSignatureSigner;
  }

  function getDelegationTypedDataHash(Delegation memory delegation) public view returns (bytes32) {
    bytes32 digest = keccak256(abi.encodePacked(
      "\x19\x01",
      domainHash,
      GET_DELEGATION_PACKETHASH(delegation)
    ));
    return digest;
  }

  function getInvocationsTypedDataHash (Invocations memory invocations) public view returns (bytes32) {
    bytes32 digest = keccak256(abi.encodePacked(
      "\x19\x01",
      domainHash,
      GET_INVOCATIONS_PACKETHASH(invocations)
    ));
    return digest;
  }

  function getEIP712DomainHash(string memory contractName, string memory version, uint256 chainId, address verifyingContract) public pure returns (bytes32) {
    bytes memory encoded = abi.encode(
      EIP712DOMAIN_TYPEHASH,
      keccak256(bytes(contractName)),
      keccak256(bytes(version)),
      chainId,
      verifyingContract
    );
    return keccak256(encoded);
  }


  function _msgSender () internal view virtual returns (address sender) {
    if(msg.sender == address(this)) {
      bytes memory array = msg.data;
      uint256 index = msg.data.length;
      assembly {
        sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
      }
    } else {
      sender = msg.sender;
    }
    return sender;
  }

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}pragma solidity ^0.8.13;


abstract contract RevokableOwnableDelegatable is Ownable, CaveatEnforcer, Delegatable {

  constructor(string memory name) Delegatable(name, "1") {}

  mapping(bytes32 => bool) isRevoked;
  function enforceCaveat(
    bytes calldata terms,
    Transaction calldata transaction,
    bytes32 delegationHash
  ) public view override returns (bool) {
    require(!isRevoked[delegationHash], "Delegation has been revoked");

    bytes4 targetSig = bytes4(transaction.data[0:4]);

    require(targetSig != 0xf2fde38b, "transferOwnership is not delegatable");

    require(targetSig != 0x79ba79d8, "renounceOwnership is not delegatable");

    return true;
  }

function revokeDelegation(
    SignedDelegation calldata signedDelegation,
    SignedIntentionToRevoke calldata signedIntentionToRevoke
  ) public {
    address signer = verifyDelegationSignature(signedDelegation);
    address revocationSigner = verifyIntentionToRevokeSignature(signedIntentionToRevoke);
    require(signer == revocationSigner, "Only the signer can revoke a delegation");

    bytes32 delegationHash = GET_SIGNEDDELEGATION_PACKETHASH(signedDelegation);
    isRevoked[delegationHash] = true;
  }

  function verifyIntentionToRevokeSignature(
    SignedIntentionToRevoke memory signedIntentionToRevoke
  ) public view returns (address) {
    IntentionToRevoke memory intentionToRevoke = signedIntentionToRevoke.intentionToRevoke;
    bytes32 sigHash = getIntentionToRevokeTypedDataHash(intentionToRevoke);
    address recoveredSignatureSigner = recover(sigHash, signedIntentionToRevoke.signature);
    return recoveredSignatureSigner;
  }

  function getIntentionToRevokeTypedDataHash(
    IntentionToRevoke memory intentionToRevoke
  ) public view returns (bytes32) {
    bytes32 digest = keccak256(abi.encodePacked(
      "\x19\x01",
      domainHash,
      GET_INTENTIONTOREVOKE_PACKETHASH(intentionToRevoke)
    ));
    return digest;
  }

  function _msgSender () internal view override(Delegatable, Context) returns (address sender) {
    if(msg.sender == address(this)) {
      bytes memory array = msg.data;
      uint256 index = msg.data.length;
      assembly {
        sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
      }
    } else {
      sender = msg.sender;
    }
    return sender;
  }

}pragma solidity ^0.8.13;


contract PhisherRegistry is RevokableOwnableDelegatable {


  constructor(string memory name) RevokableOwnableDelegatable(name) {}

  mapping (string => bool) public isPhisher;
  event PhisherStatusUpdated(string indexed entity, bool isPhisher);
  function claimIfPhisher (string calldata identifier, bool isAccused) onlyOwner public {
    isPhisher[identifier] = isAccused;
    emit PhisherStatusUpdated(identifier, isAccused);
  }

  mapping (string => bool) public isMember;
  event MemberStatusUpdated(string indexed entity, bool isMember);
  function claimIfMember (string calldata identifier, bool isNominated) onlyOwner public {
    isMember[identifier] = isNominated;
    emit MemberStatusUpdated(identifier, isNominated);
  }

}