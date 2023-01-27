
pragma solidity ^0.7.3;
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}
contract sender721B {


    address  _owner;
    mapping(address=>mapping(address => bool)) public access;

    event Permission(address owner, address operator,bool permission);

    modifier onlyAllowed(address owner) {

        require(access[owner][msg.sender],"Unauthorised");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _owner,"Unauthorised");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function sendManyToMany(
        IERC721 token, 
        address owner, 
        address [] memory to, 
        uint256 [] memory tokenIds
        ) public  onlyAllowed(owner) {

        require(token.isApprovedForAll(owner,address(this)),"You have not set ApproveForAll");
        for (uint256 j = 0; j < to.length; j++) {
            token.transferFrom(msg.sender,to[j],tokenIds[j]);
        }
    }

   function sendManyToOne(
       IERC721 token, 
       address owner, 
       address to, 
       uint256[] memory tokenIds
       ) public onlyAllowed(owner) {

        require(token.isApprovedForAll(owner,address(this)),"You have not set ApproveForAll");
        for (uint256 j = 0; j < tokenIds.length; j++) {
            token.transferFrom(msg.sender,to,tokenIds[j]);
        }
    }

   function sendManyToManyFor(
       IERC721 token,
       address owner, 
       address [] memory to, 
       uint256 [] memory tokenIds
       ) public onlyAllowed(owner) {

        
        require(token.isApprovedForAll(owner,address(this)),"Owner has not set ApproveForAll");
        for (uint256 j = 0; j < to.length; j++) {
            token.transferFrom(owner,to[j],tokenIds[j]);
        }
    }

   function sendManyToOneFor(
       IERC721 token, 
       address owner,
       address to, 
       uint256[] memory tokenIds
       ) public onlyAllowed(owner) {

        require(token.isApprovedForAll(owner,address(this)),"Owner has not set ApproveForAll");
        for (uint256 j = 0; j < tokenIds.length; j++) {
            token.transferFrom(owner,to,tokenIds[j]);
        }
    }

    function permitAccess(address token,address operator, bool permission) external onlyOwner {

        access[token][operator] = permission;
        emit Permission(msg.sender,operator,permission);
    }
}