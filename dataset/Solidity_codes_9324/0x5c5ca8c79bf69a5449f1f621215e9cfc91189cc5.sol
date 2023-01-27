
pragma solidity ^0.5.16;







library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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


contract ECRecovery {


  function recover(bytes32 hash, bytes memory sig) internal  pure returns (address) {

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

}




contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



contract RelayAuthorityInterface {

    function getRelayAuthority() public returns (address);

}

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;

}






contract LavaWallet is ECRecovery{


  using SafeMath for uint;

   mapping(bytes32 => uint256) burnedSignatures;



  struct LavaPacket {
    string methodName;
    address relayAuthority; //either a contract or an account
    address from;
    address to;
    address wallet;  //this contract address
    address token;
    uint256 tokens;
    uint256 relayerRewardTokens;
    uint256 expires;
    uint256 nonce;
  }


    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
          "EIP712Domain(string contractName,string version,uint256 chainId,address verifyingContract)"
      );

   function getLavaDomainTypehash() public pure returns (bytes32) {

      return EIP712DOMAIN_TYPEHASH;
   }

    function getEIP712DomainHash(string memory contractName, string memory version, uint256 chainId, address verifyingContract) public pure returns (bytes32) {


      return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(contractName)),
            keccak256(bytes(version)),
            chainId,
            verifyingContract
        ));
    }




  bytes32 constant LAVAPACKET_TYPEHASH = keccak256(
      "LavaPacket(string methodName,address relayAuthority,address from,address to,address wallet,address token,uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce)"
  );



    function getLavaPacketTypehash()  public pure returns (bytes32) {

      return LAVAPACKET_TYPEHASH;
  }



   function getLavaPacketHash(string memory methodName, address relayAuthority,address from,address to, address wallet, address token, uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce) public pure returns (bytes32) {

          return keccak256(abi.encode(
              LAVAPACKET_TYPEHASH,
              keccak256(bytes(methodName)),
              relayAuthority,
              from,
              to,
              wallet,
              token,
              tokens,
              relayerRewardTokens,
              expires,
              nonce
          ));
      }


   constructor(  ) public {


  }


  function() external payable {
      revert();
  }



      function getLavaTypedDataHash(string memory methodName, address relayAuthority,address from,address to, address wallet,address token,uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce) public view returns (bytes32) {



              bytes32 digest = keccak256(abi.encodePacked(
                  "\x19\x01",
                  getEIP712DomainHash('Lava Wallet','1',1,address(this)),
                  getLavaPacketHash(methodName,relayAuthority,from,to,wallet,token,tokens,relayerRewardTokens,expires,nonce)
              ));
              return digest;
          }




   function _validatePacketSignature(  string memory methodName, address relayAuthority,address from,address to, address token,uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce,  bytes memory signature) internal returns (bool success)
   {

       address wallet = address(this);




       require( relayAuthority == address(0x0)
         || (!addressContainsContract(relayAuthority) && msg.sender == relayAuthority)
         || (addressContainsContract(relayAuthority) && msg.sender == RelayAuthorityInterface(relayAuthority).getRelayAuthority())  );


         bytes32 sigHash = getLavaTypedDataHash(methodName,relayAuthority,from,to,wallet,token,tokens,relayerRewardTokens,expires,nonce);


         address recoveredSignatureSigner = recover(sigHash,signature);


          require(from == recoveredSignatureSigner);


          require(block.number < expires || expires == 0);

          uint burnedSignature = burnedSignatures[sigHash];
          burnedSignatures[sigHash] = 0x1; //spent
          require(burnedSignature == 0x0 );


         require( ERC20Interface(token).transferFrom(from, msg.sender, relayerRewardTokens )  );



       return true;
   }

   function _transferTokens(address to, address token, uint tokens) internal returns (bool success) {

         ERC20Interface(token).transfer(to, tokens );

         return true;
    }


   function _transferTokensFrom( address from, address to,address token,  uint tokens) internal returns (bool success) {

        ERC20Interface(token).transferFrom(from, to, tokens );  //??

       return true;
   }




    function approveAndCallWithSignature( string memory methodName, address relayAuthority,address from,address to,   address token, uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce, bytes memory signature ) public returns (bool success)   {


       require(!bytesEqual('transfer',bytes(methodName)));


       require(_validatePacketSignature(methodName,relayAuthority,from,to, token,tokens,relayerRewardTokens,expires,nonce, signature));

       bytes memory method = bytes(methodName);

       _sendApproveAndCall(from,to,token,tokens,method);

        return true;
    }

    function _sendApproveAndCall(address from, address to, address token, uint tokens, bytes memory methodName) internal
    {

        ApproveAndCallFallBack(to).receiveApproval(from, tokens, token, bytes(methodName));
    }



   function transferTokensWithSignature(string memory methodName, address relayAuthority, address from, address to, address token, uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce, bytes memory signature) public returns (bool success)
 {


     require(bytesEqual('transfer',bytes(methodName)));


     require(_validatePacketSignature(methodName,relayAuthority,from,to, token,tokens,relayerRewardTokens,expires,nonce, signature));

     require( ERC20Interface(token).transferFrom(from,  to, tokens )  );


     return true;

 }

 function burnSignature(string memory methodName, address relayAuthority, address from, address to, address wallet,address token,uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce,  bytes memory signature) public returns (bool success)
      {



         bytes32 sigHash = getLavaTypedDataHash(methodName,relayAuthority,from,to,wallet,token, tokens,relayerRewardTokens,expires,nonce);

          address recoveredSignatureSigner = recover(sigHash,signature);

          require(recoveredSignatureSigner == from);

          require(from == msg.sender);

          uint burnedSignature = burnedSignatures[sigHash];
          burnedSignatures[sigHash] = 0x2; //invalidated
          require(burnedSignature == 0x0);

          return true;
      }



     function signatureBurnStatus(bytes32 digest) public view returns (uint)
     {

       return (burnedSignatures[digest]);
     }

     function signatureIsValid(string memory methodName, address relayAuthority,address from,address to, address wallet,address token, uint256 tokens,uint256 relayerRewardTokens,uint256 expires,uint256 nonce, bytes memory signature) public view returns (bool success)
   {


       bytes32 sigHash = getLavaTypedDataHash(methodName,relayAuthority,from,to,wallet,token, tokens,relayerRewardTokens,expires,nonce);


       address recoveredSignatureSigner = recover(sigHash,signature);


       return  (from == recoveredSignatureSigner) ;

   }


 


     function addressContainsContract(address _to) view internal returns (bool)
     {

       uint codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }

         return (codeLength>0);
     }


     function bytesEqual(bytes memory b1,bytes memory b2) pure internal returns (bool)
        {

          if(b1.length != b2.length) return false;

          for (uint i=0; i<b1.length; i++) {
            if(b1[i] != b2[i]) return false;
          }

          return true;
        }


}