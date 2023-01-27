
pragma solidity 0.6.0;

interface ERC721 {

  function safeTransferFrom(address from,address to,uint256 tokenId) external;

}

interface ERC20 {

  function transferFrom(address src, address dst, uint wad)
        external
        returns (bool);

}


contract GollumTrader {

  mapping(bytes32 => bool) public orderhashes; // keep tracks of orderhashes that are filled or cancelled so they cant be filled again 
  mapping(bytes32 => bool) public offerhashes; // keep tracks of offerhashes that are filled or cancelled so they cant be filled again 
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

    function _eip712DomainHash() internal view returns(bytes32 eip712DomainHash) {

        eip712DomainHash = keccak256(
        abi.encode(
            keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            ),
            keccak256(bytes("GOLLUM.XYZ")),
            keccak256(bytes("1")),
            1,
            address(this)
        )
    );  
    }

  function executeOrderIfSignatureMatch(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address contractaddress,
    uint256 tokenid,
    uint256 ethamt,
    uint256 deadline,
    uint256 feeamt,
    address payable signer,
    uint256 salt,
    address refferer
  ) external payable {

    require(block.timestamp < deadline, "Signed transaction expired");


    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt,address signer,uint salt)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer,
          salt
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
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
    uint256 tokenid,
    uint256 ethamt,
    uint256 deadline,
    uint256 feeamt,
    uint256 salt
) external{

      bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer,uint salt)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          msg.sender,
          salt
        )
    );
        orderhashes[hashStruct]=true;  // no need to check for signature validation since sender can only invalidate his own order
        emit Ordercancelled(hashStruct);
  }



  function executeOfferIfSignatureMatch(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address contractaddress,
    uint256 tokenid,
    uint256 ethamt,
    uint256 deadline,
    uint256 feeamt,
    address signer,
    uint256 salt
  ) external {

    require(block.timestamp < deadline, "Signed transaction expired");

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt,address signer,uint salt)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer,
          salt
        )
    );


    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == signer, "invalid signature");
    require(offerhashes[hashStruct]==false,"order filled or cancelled");
    offerhashes[hashStruct]=true;
    if (feeamt>0){
      require(wethcontract.transferFrom(signer, owner , feeamt),"error in weth transfer");
    }
    require(wethcontract.transferFrom(signer, msg.sender, ethamt-feeamt),"error in weth transfer");
    ERC721 nftcontract = ERC721(contractaddress);
    nftcontract.safeTransferFrom(msg.sender,signer ,tokenid);
    emit Offerfilled(signer, msg.sender, hashStruct , ethamt ,feeamt);
  }




  function cancelOffer(    
    address contractaddress,
    uint256 tokenid,
    uint256 ethamt,
    uint256 deadline,
    uint256 feeamt,
    uint256 salt

) external{

      bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer,uint salt)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          msg.sender,
          salt
        )
    );
      offerhashes[hashStruct]=true;  
      emit Ordercancelled(hashStruct);
  }


 

  function Orderstruct(   
    address contractaddress,
    uint256 tokenid,
    uint256 ethamt,
    uint256 deadline,
    uint256 feeamt,
    address signer,
    uint256 salt
    ) public pure returns (bytes32) {

        return keccak256(
      abi.encode(
          keccak256("matchorder(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer,uint salt)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer,
          salt
        )
    );
    }

  function Offerstruct(   
    address contractaddress,
    uint256 tokenid,
    uint256 ethamt,
    uint256 deadline,
    uint256 feeamt,
    address signer,
    uint256 salt
    ) public pure returns (bytes32) {

        return keccak256(
      abi.encode(
          keccak256("matchoffer(address contractaddress,uint tokenid,uint ethamt,uint deadline,uint feeamt ,address signer,uint salt)"),
          contractaddress,
          tokenid,
          ethamt,
          deadline,
          feeamt,
          signer,
          salt
        )
    );
    }
}