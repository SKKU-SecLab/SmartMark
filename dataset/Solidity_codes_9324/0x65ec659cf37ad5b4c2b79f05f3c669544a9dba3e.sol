
pragma solidity 0.6.0;

interface ERC721 {

  function safeTransferFrom(address from,address to,uint256 tokenId) external;

}

interface ERC20 {

  function transferFrom(address src, address dst, uint wad)
        external
        returns (bool);

}


contract Golomtrader {

  mapping(bytes32 => bool) public orderhashes; // keep tracks of orderhashes that are filled or cancelled so they cant be filled again 
  address payable owner;
  ERC20 wethcontract;
  event Orderfilled(address indexed from,address indexed to, bytes32 indexed id, uint ethamt,address refferer,uint feeamt);
  event Offerfilled(address indexed from,address indexed to, bytes32 indexed id, uint ethamt,uint feeamt);
  event Ordercancelled(bytes32 indexed id);

  constructor ()
        public
  {
    owner = payable(msg.sender);
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    wethcontract = ERC20(WETH);
  }

  function executeOrderIfSignatureMatch(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address contractaddress,
    uint256 deadline,
    uint256 ethamt,
    uint256 tokenid,
    address payable signer,
    uint256 feeamt,
    address refferer
  ) external payable {

    require(block.timestamp < deadline, "Signed transaction expired");

    bytes32 eip712DomainHash = keccak256(
        abi.encode(
            keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            ),
            keccak256(bytes("GOLOM.IO")),
            keccak256(bytes("1")),
            1,
            address(this)
        )
    );  
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt,address signer)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == signer, "invalid signature");
    require(msg.value == ethamt, "wrong eth amt");
    require(orderhashes[hashStruct]==false,"order filled or cancelled");
    orderhashes[hashStruct]=true; // prevent reentrency and also doesnt allow any order to be filled more then once
    ERC721 nftcontract = ERC721(contractaddress);
    nftcontract.safeTransferFrom(signer,msg.sender ,tokenid); // transfer 

    if (feeamt>0){
      owner.transfer(feeamt); // fee transfer to owner
    }
    signer.transfer(msg.value-feeamt); // transfer of eth to seller of nft
    emit Orderfilled(signer, msg.sender, hashStruct , ethamt , refferer ,feeamt);
  }


  function cancelOrder(    
    address contractaddress,
    uint256 deadline,
    uint256 ethamt,
    uint256 tokenid,
    uint256 feeamt
) external{

      bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          msg.sender
        )
    );
        orderhashes[hashStruct]=true;  // no need to check for signature validation since sender can only invalidate his own order
        emit Ordercancelled(hashStruct);
  }

  function Orderstruct(   
    address contractaddress,
    uint256 deadline,
    uint256 ethamt,
    uint256 tokenid,
    uint256 feeamt,
    address signer
    ) public pure returns (bytes32) {

        return keccak256(
      abi.encode(
          keccak256("matchorder(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer
        )
    );
    }





  function executeOfferIfSignatureMatch(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address contractaddress,
    uint256 deadline,
    uint256 ethamt,
    uint256 tokenid,
    address signer,
    uint256 feeamt
  ) external {

    require(block.timestamp < deadline, "Signed transaction expired");

    bytes32 eip712DomainHash = keccak256(
        abi.encode(
            keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            ),
            keccak256(bytes("GOLOM.IO")),
            keccak256(bytes("1")),
            1,
            address(this)
        )
    );  

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt,address signer)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == signer, "invalid signature");
    require(orderhashes[hashStruct]==false,"order filled or cancelled");
    if (feeamt>0){
      require(wethcontract.transferFrom(signer, owner , feeamt),"error in weth transfer");
    }
    require(wethcontract.transferFrom(signer, msg.sender, ethamt-feeamt),"error in weth transfer");
    orderhashes[hashStruct]=true;
    ERC721 nftcontract = ERC721(contractaddress);
    nftcontract.safeTransferFrom(msg.sender,signer ,tokenid);
    emit Offerfilled(signer, msg.sender, hashStruct , ethamt ,feeamt);
  }

  function cancelOffer(    
    address contractaddress,
    uint256 deadline,
    uint256 ethamt,
    uint256 tokenid,
    uint256 feeamt
) external{

      bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          msg.sender
        )
    );
      orderhashes[hashStruct]=true;  
      emit Ordercancelled(hashStruct);
  }
}