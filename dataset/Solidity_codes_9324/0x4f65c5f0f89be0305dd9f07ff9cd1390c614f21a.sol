

pragma solidity 0.5.0;

contract CommonConstants {


    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
}


pragma solidity 0.5.0;

interface IEnjinERC1155 {

  function acceptAssignment ( uint256 _id ) external;
  function assign ( uint256 _id, address _creator ) external;
  function balanceOf ( address _owner, uint256 _id ) external view returns ( uint256 );
  function balanceOfBatch ( address[] calldata _owners, uint256[] calldata _ids ) external view returns ( uint256[] memory);
  function create ( string calldata _name, uint256 _totalSupply, uint256 _initialReserve, address _supplyModel, uint256 _meltValue, uint16 _meltFeeRatio, uint8 _transferable, uint256[3] calldata _transferFeeSettings, bool _nonFungible ) external;
  function isApprovedForAll ( address _owner, address _operator ) external view returns ( bool );
  function melt ( uint256[] calldata _ids, uint256[] calldata _values ) external;
  function mintFungibles ( uint256 _id, address[] calldata _to, uint256[] calldata _values ) external;
  function mintNonFungibles ( uint256 _id, address[] calldata _to ) external;
  function safeBatchTransferFrom ( address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data ) external;
  function safeTransferFrom ( address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data ) external;
  function setApprovalForAll ( address _operator, bool _approved ) external;
  function setURI ( uint256 _id, string calldata _uri ) external;
  function supportsInterface ( bytes4 _interfaceID ) external pure returns ( bool );
  function uri ( uint256 _id ) external view returns ( string memory );
}


pragma solidity 0.5.0;

interface ERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);

}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.0;





contract ForgeERC1155Operations is ERC1155TokenReceiver, CommonConstants {


    IEnjinERC1155 public enjinContract;

    IERC20 public enjinCoinContract;

    function safeTransferFungibleItemWithOptionalMelt(uint256 tokenId, address recipient, bool melt) internal {

      bytes memory extraData = new bytes(0); 
      enjinContract.safeTransferFrom(msg.sender, melt ? address(this) : recipient, tokenId, 1, extraData);

      if(melt) {
        uint256 startingEnjinCoinBalance = enjinCoinContract.balanceOf(address(this));
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = tokenId;
        values[0] = 1;
        enjinContract.melt(ids, values);
        uint256 endingEnjinCoinBalance = enjinCoinContract.balanceOf(address(this));
        uint256 changeInEnjinCoinBalance = endingEnjinCoinBalance - startingEnjinCoinBalance;

        if(changeInEnjinCoinBalance > 0) {
          enjinCoinContract.transfer(msg.sender, changeInEnjinCoinBalance);
        }
      }
    }    

    function safeTransferNonFungibleItemWithOptionalMelt(uint256 tokenId, uint256 NFTIndex, address recipient, bool melt) internal {

      uint256[] memory nftIds = new uint256[](1);
      uint256[] memory values = new uint256[](1);
      nftIds[0] = tokenId | NFTIndex;
      values[0] = 1;

      bytes memory extraData = new bytes(0);
      enjinContract.safeBatchTransferFrom(msg.sender, melt ? address(this) : recipient, nftIds, values, extraData);

      if(melt) {
        uint256 startingEnjinCoinBalance = enjinCoinContract.balanceOf(address(this));
        enjinContract.melt(nftIds, values);
        uint256 endingEnjinCoinBalance = enjinCoinContract.balanceOf(address(this));
        uint256 changeInEnjinCoinBalance = endingEnjinCoinBalance - startingEnjinCoinBalance;

        if(changeInEnjinCoinBalance > 0) {
          enjinCoinContract.transfer(msg.sender, changeInEnjinCoinBalance);
        }        
      }      
    }        

    function onERC1155Received(address /*_operator*/, address /*_from*/, uint256 /*_id*/, uint256 /*_value*/, bytes calldata /*_data*/) external returns(bytes4) {

      return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(address /*_operator*/, address /*_from*/, uint256[] calldata /*_ids*/, uint256[] calldata /*_values*/, bytes calldata /*_data*/) external returns(bytes4) {        

      return ERC1155_BATCH_ACCEPTED;        
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return  interfaceID == 0x01ffc9a7 ||    // ERC165
                interfaceID == 0x4e2312e0;      // ERC1155_ACCEPTED ^ ERC1155_BATCH_ACCEPTED;
    }
}


pragma solidity 0.5.0;

interface IForgePathCatalogCombined {        

    function getNumberOfPathDefinitions() external view returns (uint256);

    function getForgePathNameAtIndex(uint256 index) external view returns (string memory);

    function getForgePathIdAtIndex(uint256 index) external view returns (uint256);


    function getForgeType(uint256 pathId) external view returns (uint8);

    function getForgePathDetailsCommon(uint256 pathId) external view returns (uint256, uint256, uint256);

    function getForgePathDetailsTwoGen1Tokens(uint256 pathId) external view returns (uint256, uint256, bool, bool);

    function getForgePathDetailsTwoERC721Addresses(uint256 pathId) external view returns (address, address);

    function getForgePathDetailsERC721AddressWithGen1Token(uint256 pathId) external view returns (address, uint256, bool);

    function getForgePathDetailsTwoERC1155Tokens(uint256 pathId) external view returns (uint256, uint256, bool, bool, bool, bool);

    function getForgePathDetailsERC1155WithGen1Token(uint256 pathId) external view returns (uint256, uint256, bool, bool, bool);

    function getForgePathDetailsERC1155WithERC721Address(uint256 pathId) external view returns (uint256, address, bool, bool);

}


pragma solidity 0.5.0;

interface IBurnableEtherLegendsToken {        

    function burn(uint256 tokenId) external;

}


pragma solidity 0.5.0;

interface IMintableEtherLegendsToken {        

    function mintTokenOfType(address to, uint256 idOfTokenType) external;

}


pragma solidity 0.5.0;

interface ITokenDefinitionManager {        

    function getNumberOfTokenDefinitions() external view returns (uint256);

    function hasTokenDefinition(uint256 tokenTypeId) external view returns (bool);

    function getTokenTypeNameAtIndex(uint256 index) external view returns (string memory);

    function getTokenTypeName(uint256 tokenTypeId) external view returns (string memory);

    function getTokenTypeId(string calldata name) external view returns (uint256);

    function getCap(uint256 tokenTypeId) external view returns (uint256);

    function getAbbreviation(uint256 tokenTypeId) external view returns (string memory);

}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.5.0;




contract IERC721Full is IERC721, IERC721Enumerable, IERC721Metadata {

}


pragma solidity 0.5.0;





contract IEtherLegendsToken is IERC721Full, IMintableEtherLegendsToken, IBurnableEtherLegendsToken, ITokenDefinitionManager {

    function totalSupplyOfType(uint256 tokenTypeId) external view returns (uint256);

    function getTypeIdOfToken(uint256 tokenId) external view returns (uint256);

}


pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


pragma solidity 0.5.0;









contract ForgeCombined is ForgeERC1155Operations, Ownable, ReentrancyGuard {    


    address public payee;    

    address public lootWallet;    

    IForgePathCatalogCombined public catalogContract;    

    IERC20 public elementeumContract;

    IEtherLegendsToken public etherLegendsGen1;    

    constructor() public 
      Ownable()
      ReentrancyGuard()
    {
      
    }    

    function() external payable {
        revert("Fallback function not permitted.");
    }

    function destroyContract() external {

      _requireOnlyOwner();
      address payable payableOwner = address(uint160(owner()));
      selfdestruct(payableOwner);
    }

    function setPayee(address addr) external {

      _requireOnlyOwner();
      payee = addr;
    }

    function setLootWallet(address addr) external {

      _requireOnlyOwner();
      lootWallet = addr;
    }

    function setCatalogContractAddress(address addr) external {

      _requireOnlyOwner();
      catalogContract = IForgePathCatalogCombined(addr);
    }

    function setElementeumERC20ContractAddress(address addr) external {

      _requireOnlyOwner();
      elementeumContract = IERC20(addr);
    }    

    function setEtherLegendsGen1(address addr) external {

      _requireOnlyOwner();
      etherLegendsGen1 = IEtherLegendsToken(addr);
    }  

    function setEnjinERC1155ContractAddress(address addr) external {

      _requireOnlyOwner();
      enjinContract = IEnjinERC1155(addr);
    }

    function setEnjinERC20ContractAddress(address addr) external {

      _requireOnlyOwner();
      enjinCoinContract = IERC20(addr);
    }

    function forge(uint256 pathId, uint256 material1TokenId, uint256 material2TokenId) external payable nonReentrant {

      _requireOnlyHuman();      

      uint8 forgeType = catalogContract.getForgeType(pathId);
      (uint256 weiCost, uint256 elementeumCost, uint256 forgedItem) = catalogContract.getForgePathDetailsCommon(pathId);

      require(msg.value >= weiCost, "Insufficient ETH");

      if(forgeType == 1) {
        require(material1TokenId != material2TokenId, "NFT ids must be unique");  
        (uint256 material1, 
         uint256 material2, 
         bool burnMaterial1, 
         bool burnMaterial2) = catalogContract.getForgePathDetailsTwoGen1Tokens(pathId);
         _forgeGen1Token(material1, material1TokenId, burnMaterial1);
         _forgeGen1Token(material2, material2TokenId, burnMaterial2);
      } else if(forgeType == 2) {
        (address material1, address material2) = catalogContract.getForgePathDetailsTwoERC721Addresses(pathId);
        if(material1 == material2) {
          require(material1TokenId != material2TokenId, "NFT ids must be unique");
        }
        _forgeERC721Token(material1, material1TokenId);
        _forgeERC721Token(material2, material2TokenId);
      } else if(forgeType == 3) {
        (address material1, 
         uint256 material2, 
         bool burnMaterial2) = catalogContract.getForgePathDetailsERC721AddressWithGen1Token(pathId);
         _forgeERC721Token(material1, material1TokenId);
         _forgeGen1Token(material2, material2TokenId, burnMaterial2);
      } else if(forgeType == 4) {
        (uint256 material1,
         uint256 material2,
         bool meltMaterial1,
         bool meltMaterial2,
         bool material1IsNonFungible,
         bool material2IsNonFungible) = catalogContract.getForgePathDetailsTwoERC1155Tokens(pathId);
        if(material1 == material2 && material1IsNonFungible && material2IsNonFungible) {
          require(material1TokenId != material2TokenId, "NFT ids must be unique");
        }
        _forgeERC1155Token(material1, material1TokenId, meltMaterial1, material1IsNonFungible);
        _forgeERC1155Token(material2, material2TokenId, meltMaterial2, material2IsNonFungible);
      } else if(forgeType == 5) {
        (uint256 material1,
         uint256 material2,
         bool meltMaterial1,
         bool burnMaterial2,
         bool material1IsNonFungible) = catalogContract.getForgePathDetailsERC1155WithGen1Token(pathId);
         _forgeERC1155Token(material1, material1TokenId, meltMaterial1, material1IsNonFungible);
         _forgeGen1Token(material2, material2TokenId, burnMaterial2);
      } else if(forgeType == 6) {
        (uint256 material1,
         address material2,
         bool meltMaterial1,
         bool material1IsNonFungible) = catalogContract.getForgePathDetailsERC1155WithERC721Address(pathId);
         _forgeERC1155Token(material1, material1TokenId, meltMaterial1, material1IsNonFungible);
         _forgeERC721Token(material2, material2TokenId);
      } else {
        revert("Non-existent forge type");
      }

      if(elementeumCost > 0) {
        elementeumContract.transferFrom(msg.sender, payee, elementeumCost);      
      }                    

      if(msg.value > 0) {                
        address payable payableWallet = address(uint160(payee));
        payableWallet.transfer(weiCost);

        uint256 change = msg.value - weiCost;
        if(change > 0) {
          msg.sender.transfer(change);
        }
      }

      etherLegendsGen1.mintTokenOfType(msg.sender, forgedItem);            
    }

    function _forgeGen1Token(uint256 material, uint256 tokenId, bool burnMaterial) internal {

      _verifyOwnershipAndApprovalERC721(address(etherLegendsGen1), tokenId);
      require(material == etherLegendsGen1.getTypeIdOfToken(tokenId), "Incorrect material type");
      burnMaterial ? etherLegendsGen1.burn(tokenId) : _safeTransferERC721(address(etherLegendsGen1), tokenId);
    } 

    function _forgeERC721Token(address material, uint256 tokenId) internal {

      _verifyOwnershipAndApprovalERC721(material, tokenId);
      _safeTransferERC721(material, tokenId);
    }       

    function _forgeERC1155Token(uint256 material, uint256 materialNFTIndex, bool meltMaterial, bool materialIsNonFungible) internal {

      require(enjinContract.isApprovedForAll(msg.sender, address(this)), "Not approved to spend user's ERC1155 tokens");      
      require(enjinContract.balanceOf(msg.sender, materialIsNonFungible ? ( material | materialNFTIndex ) : material) > 0, "Insufficient material balance");  
      materialIsNonFungible ? 
      safeTransferNonFungibleItemWithOptionalMelt(material, materialNFTIndex, lootWallet, meltMaterial) :
      safeTransferFungibleItemWithOptionalMelt(material, lootWallet, meltMaterial);
    }                 

    function _verifyOwnershipAndApprovalERC721(address tokenAddress, uint256 tokenId) internal view {

      IERC721Full tokenContract = IERC721Full(tokenAddress);
      require(tokenContract.ownerOf(tokenId) == msg.sender, "Token not owned by user");
      require(tokenContract.getApproved(tokenId) == address(this) || tokenContract.isApprovedForAll(msg.sender, address(this)), "Token not approved");      
    }    

    function _safeTransferERC721(address tokenAddress, uint256 tokenId) internal {

      IERC721Full tokenContract = IERC721Full(tokenAddress);
      tokenContract.safeTransferFrom(msg.sender, lootWallet, tokenId);
    }    

    function _requireOnlyOwner() internal view {

      require(isOwner(), "Ownable: caller is not the owner");
    }

    function _requireOnlyHuman() internal view {

      require(msg.sender == tx.origin, "Caller must be human user");
    }
}