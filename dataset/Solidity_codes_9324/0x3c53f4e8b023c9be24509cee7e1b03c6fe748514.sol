

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity >=0.6.0 <0.8.0;

interface IERC721  {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}


pragma solidity ^0.6.0;

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





pragma solidity ^0.6.0;

contract NFTTrade  {


    address owner;
    bool public tradeIsActive = false;
    IERC20 public saletoken;
    IERC721 public nfttoken;
    mapping(uint => uint) nftPrices;

     constructor() public {
        owner=msg.sender;
    }

     function flipTradeState() public {

        require(msg.sender==owner, "Only Owner can use this function");
        tradeIsActive = !tradeIsActive;
    }

    function transferOwnership(address newOwner) public{

        require(msg.sender==owner, "Only Owner can use this function");
        owner=newOwner;
    }

    function withdrawToken() public {

        require(msg.sender==owner, "Only Owner can use this function");
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        saletoken.transfer(msg.sender, saletoken.balanceOf(address(this)));
    }
    
    function setPurchaseToken(IERC20 token1) public {

        require(msg.sender==owner, "Only Owner can use this function");
        saletoken = token1; //purchase token
    }

    function setNFTToken(IERC721 token2) public {

        require(msg.sender==owner, "Only Owner can use this function");
        nfttoken = token2; //purchase token
    }

    function checkBalance(address user) public view returns (uint){

        return saletoken.balanceOf(user);
    }

    function checkNFTBalance(address user) public view returns (uint){

        return nfttoken.balanceOf(user);
    }
    function listNFTforSale(uint index,uint price) public {

        require(nftPrices[index]==0, "NFT already listed");
        require(tradeIsActive, "Trading is not enabled");
        require(msg.sender==nfttoken.ownerOf(index), "Only NFT Owner can list it");
        setNFTprice(index,price);
    }

    function transactNFT(address seller,address buyer,uint index)public{

        require(buyer==msg.sender, "Only buyer can make transaction");
        require(tradeIsActive, "Trading is not enabled");
        require(buyer!=seller, "Buyer and Seller cannot be same");
        require(nftPrices[index]!=0, "NFT not for sale");
        require((saletoken.allowance(buyer,address(this))>=nftPrices[index]), "Not enough allowance");
        saletoken.transferFrom(buyer,seller,nftPrices[index]);
        nfttoken.safeTransferFrom(seller,buyer,index);
        setNFTprice(index,0);
    }
    function setNFTprice(uint index,uint price)public{

        require(tradeIsActive, "Trading is not enabled");
        require(nfttoken.ownerOf(index)==msg.sender, "Only NFT Owner can set price");
         nftPrices[index]=price;
    }
    function getNFTprice(uint index) public view returns (uint){

        return nftPrices[index];
    }

}