
pragma solidity 0.8.0;

interface ERC721 {

  function safeTransferFrom(address from,address to,uint256 tokenId) external;

}

interface ERC20 {

  function transferFrom(address src, address dst, uint wad)
        external
        returns (bool);

}


contract GolomTrader {

  mapping(bytes32 => bool) public orderhashes; // keep tracks of orderhashes that are filled or cancelled so they cant be filled again 
  mapping(bytes32 => bool) public offerhashes; // keep tracks of offerhashes that are filled or cancelled so they cant be filled again 
  address payable owner;
  ERC20 wethcontract;

  event Orderfilled(address indexed from,address indexed to, bytes32 indexed id, uint amt,address referrer,uint feeAmt,uint royaltyAmt,address royaltyAddress,address buyerAddress);
  event Offerfilled(address indexed from,address indexed to, bytes32 indexed id, uint amt,uint feeAmt,uint royaltyAmt,address royaltyAddress,uint isany);
  event Ordercancelled(bytes32 indexed id);
  event Offercancelled(bytes32 indexed id);

  constructor ()
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
            keccak256(bytes("GOLOM.IO")),
            keccak256(bytes("1")),
            1,
            address(this)
        )
    );  
    }


  function matchOrder(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[5] calldata _addressArgs,
    uint[6] calldata _uintArgs
  ) external payable {

    require(block.timestamp < _uintArgs[2], "Signed transaction expired");

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,uint royaltyAmt,address royaltyAddress,address signer,address buyerAddress,uint deadline,uint salt)"),
          _uintArgs[0],
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[3],
          _uintArgs[5],
          _addressArgs[2],
          _addressArgs[1],
          _addressArgs[4],
          _uintArgs[2],
          _uintArgs[4]
        )
    );

    require(uint256(s) <= uint256(0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0),"found malleable signature, please insert a low-s signature");
    require(v == 27 || v == 28, "Signature: Invalid v parameter");
    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == _addressArgs[1], "invalid signature");
    if (_addressArgs[4]!=address(0)){
        require(msg.sender==_addressArgs[4],"not fillable by this address");
    }
    require(msg.value == _uintArgs[1], "wrong eth amt");
    require(orderhashes[hashStruct]==false,"order filled or cancelled");
    orderhashes[hashStruct]=true; // prevent reentrency and also doesnt allow any order to be filled more then once
    ERC721 nftcontract = ERC721(_addressArgs[0]);
    nftcontract.safeTransferFrom(_addressArgs[1],msg.sender ,_uintArgs[0]); // transfer 

    if (_uintArgs[3]>0){
      owner.transfer(_uintArgs[3]); // fee transfer to owner
    }

    if (_uintArgs[5]>0){ // if royalty has to be paid
     payable(_addressArgs[2]).transfer(_uintArgs[5]); // royalty transfer to royaltyaddress
    }
    payable(_addressArgs[1]).transfer(msg.value-_uintArgs[3]-_uintArgs[5]); // transfer of eth to seller of nft
    emit Orderfilled(_addressArgs[1], msg.sender, hashStruct , _uintArgs[1] , _addressArgs[3] ,_uintArgs[3],_uintArgs[5],_addressArgs[2],_addressArgs[4]);
  }

  function cancelOrder(    
    address[5] calldata _addressArgs,
    uint[6] calldata _uintArgs
) external{

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,uint royaltyAmt,address royaltyAddress,address signer,address buyerAddress,uint deadline,uint salt)"),
          _uintArgs[0],
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[3],
          _uintArgs[5],
          _addressArgs[2],
          msg.sender,
          _addressArgs[4],
          _uintArgs[2],
          _uintArgs[4]
        )
    );        
      orderhashes[hashStruct]=true;  // no need to check for signature validation since sender can only invalidate his own order
      emit Ordercancelled(hashStruct);
  }


  function matchOffer(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[3] calldata _addressArgs,
    uint[7] calldata _uintArgs
  ) external {

    require(block.timestamp < _uintArgs[2], "Signed transaction expired");

    bytes32 hashStruct;
    if (_uintArgs[6]==1){
        hashStruct = keccak256(
        abi.encode(
            keccak256("matchoffer(uint anyToken,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[6],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            _addressArgs[1],
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }else{
        hashStruct = keccak256(
        abi.encode(
            keccak256("matchoffer(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[0],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            _addressArgs[1],
            _uintArgs[2],
            _uintArgs[4]
            )
        );

    }
    require(uint256(s) <= uint256(0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0),"found malleable signature, please insert a low-s signature");
    require(v == 27 || v == 28, "Signature: Invalid v parameter");
    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == _addressArgs[1], "invalid signature");
    require(offerhashes[hashStruct]==false,"order filled or cancelled");
    offerhashes[hashStruct]=true;
    if (_uintArgs[3]>0){
      require(wethcontract.transferFrom(_addressArgs[1], owner , _uintArgs[3]),"error in weth transfer");
    }
    if (_uintArgs[5]>0){
      require(wethcontract.transferFrom(_addressArgs[1], _addressArgs[2] , _uintArgs[5]),"error in weth transfer");
    }

    require(wethcontract.transferFrom(_addressArgs[1], msg.sender, _uintArgs[1]-_uintArgs[5]-_uintArgs[3]),"error in weth transfer");

    ERC721 nftcontract = ERC721(_addressArgs[0]);
    nftcontract.safeTransferFrom(msg.sender,_addressArgs[1] ,_uintArgs[0]);
    emit Offerfilled(_addressArgs[1], msg.sender, hashStruct , _uintArgs[1] ,_uintArgs[3],_uintArgs[5],_addressArgs[2],0);
  }


  function cancelOffer(    
    address[3] calldata _addressArgs,
    uint[7] calldata _uintArgs
) external{

    bytes32 hashStruct;
    if (_uintArgs[6]==1){
        hashStruct = keccak256(
        abi.encode(
            keccak256("matchoffer(uint anyToken,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[6],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            msg.sender,
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }else{
        hashStruct = keccak256(
        abi.encode(
            keccak256("matchoffer(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[0],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            msg.sender,
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }
      offerhashes[hashStruct]=true;  
      emit Offercancelled(hashStruct);
  }


  function orderHash(   
    address[5] calldata _addressArgs,
    uint[6] calldata _uintArgs
    ) public pure returns (bytes32) {

        return keccak256(
      abi.encode(
          keccak256("matchorder(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,uint royaltyAmt,address royaltyAddress,address signer,address buyerAddress,uint deadline,uint salt)"),
          _uintArgs[0],
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[3],
          _uintArgs[5],
          _addressArgs[2],
          _addressArgs[1],
          _addressArgs[4],
          _uintArgs[2],
          _uintArgs[4]
        )
    );
    }

  function offerHash(   
    address[3] memory _addressArgs,
    uint[7] memory _uintArgs
    ) public pure returns (bytes32) {


    if (_uintArgs[6]==1){
        return keccak256(
        abi.encode(
            keccak256("matchoffer(uint anyToken,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[6],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            _addressArgs[1],
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }else{
        return keccak256(
        abi.encode(
            keccak256("matchoffer(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[0],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            _addressArgs[1],
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }
    }



  function orderStatus(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[5] calldata _addressArgs,
    uint[6] calldata _uintArgs
  ) public view returns (uint256) {

    if (block.timestamp > _uintArgs[2]){
      return 2;
    }

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,uint royaltyAmt,address royaltyAddress,address signer,address buyerAddress,uint deadline,uint salt)"),
          _uintArgs[0],
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[3],
          _uintArgs[5],
          _addressArgs[2],
          _addressArgs[1],
          _addressArgs[4],
          _uintArgs[2],
          _uintArgs[4]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);

    if (signaturesigner != _addressArgs[1]){
      return 0;
    }
    if (orderhashes[hashStruct]==true){
      return 1;
    }

    return 3;

  }




  function offerStatus(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[3] memory _addressArgs,
    uint[7] memory _uintArgs
  ) public view returns (uint256) {

    if (block.timestamp > _uintArgs[2]){
      return 2;
    }

    bytes32 hashStruct;
    if (_uintArgs[6]==1){
        hashStruct = keccak256(
        abi.encode(
            keccak256("matchoffer(uint anyToken,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[6],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            _addressArgs[1],
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }else{
        
        hashStruct = keccak256(
        abi.encode(
            keccak256("matchoffer(uint tokenId,address tokenAddress,uint totalAmt,uint feeAmt,address signer,uint deadline,uint salt)"),
            _uintArgs[0],
            _addressArgs[0],
            _uintArgs[1],
            _uintArgs[3],
            _addressArgs[1],
            _uintArgs[2],
            _uintArgs[4]
            )
        );
    }

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);

    if (signaturesigner != _addressArgs[1]){
      return 0;
    }
    if (offerhashes[hashStruct]==true){
      return 1;
    }
    return 3;

  }
}