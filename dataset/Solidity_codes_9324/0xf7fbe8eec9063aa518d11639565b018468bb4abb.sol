
pragma solidity >=0.8.4;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external ;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external ;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external  returns(bytes32);

    function setResolver(bytes32 node, address resolver) external ;

    function setOwner(bytes32 node, address owner) external ;

    function setTTL(bytes32 node, uint64 ttl) external ;

    function setApprovalForAll(address operator, bool approved) external ;

    function owner(bytes32 node) external  view returns (address);

    function resolver(bytes32 node) external  view returns (address);

    function ttl(bytes32 node) external  view returns (uint64);

    function recordExists(bytes32 node) external  view returns (bool);

    function isApprovedForAll(address owner, address operator) external  view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}/*
*/

pragma solidity ^0.8.2;


interface IERC20 {

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

}

contract KoteEnsMapper is Ownable {


    using Strings for uint256;

    ENS private ens;    
    IERC721Enumerable public nft;
    bytes32 public domainHash;
    mapping(bytes32 => mapping(string => string)) public texts;
   
    mapping(address => uint256) public nextRegisterTimestamp;

    string public domainLabel = "kote";
    string public nftImageBaseUri = "https://ipfs.io/ipfs/QmbQTvwHbZjciMHLpPFYb8NFBzAjEftdAm3i9PBjwZ7NzN/";
    bool public useEIP155 = true;
    
    mapping(bytes32 => uint256) public hashToIdMap;
    mapping(uint256 => bytes32) public tokenHashmap;
    mapping(bytes32 => string) public hashToDomainMap;

    uint256 public reset_period = 7257600; //12 weeks

    bool public publicClaimOpen = false;
    mapping(address => bool) public address_whitelist;

    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);
    event RegisterSubdomain(address indexed registrar, uint256 indexed token_id, string indexed label);

    constructor(){
        ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        nft = IERC721Enumerable(0x32A322C7C77840c383961B8aB503c9f45440c81f);
        domainHash = getDomainHash();
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {

        return interfaceID == 0x3b3b57de //addr
        || interfaceID == 0x59d1d43c //text
        || interfaceID == 0x691f3431 //name
        || interfaceID == 0x01ffc9a7; //supportsInterface << [inception]
    }

    function text(bytes32 node, string calldata key) external view returns (string memory) {

        uint256 token_id = hashToIdMap[node];
        require(token_id > 0 && tokenHashmap[token_id] != 0x0, "Invalid address");
        if(keccak256(abi.encodePacked(key)) == keccak256("avatar")){
            return useEIP155 ? string(abi.encodePacked("eip155:1/erc721:", addressToString(address(nft)), "/", token_id.toString()))
                             : string(abi.encodePacked(nftImageBaseUri, token_id.toString(),".png"));            
        }
        else{
            return texts[node][key];
        }
    }

    function addr(bytes32 nodeID) public view returns (address) {

        uint256 token_id = hashToIdMap[nodeID];
        require(token_id > 0 && tokenHashmap[token_id] != 0x0, "Invalid address");
        return nft.ownerOf(token_id);
    }  

    function name(bytes32 node) view public returns (string memory){

        return (hashToIdMap[node] == 0) 
        ? "" 
        : string(abi.encodePacked(hashToDomainMap[node], ".", domainLabel, ".eth"));
    }


    function domainMap(string calldata label) public view returns(bytes32){

        bytes32 encoded_label = keccak256(abi.encodePacked(label));
        bytes32 big_hash = keccak256(abi.encodePacked(domainHash, encoded_label));
        return hashToIdMap[big_hash] > 0 ? big_hash : bytes32(0x0);
    }

    function getClaimableIdsForAddress(address addy) public view returns(uint256[] memory){

        if(((address_whitelist[addy] || publicClaimOpen) 
        && block.timestamp > nextRegisterTimestamp[addy]) 
        || owner() == addy){
            return getAllIds(addy);
        }
        else{
            return new uint256[](0);
        }
    }

    function getAllIds(address addy) private view returns(uint256[] memory){

        uint256 balance = nft.balanceOf(addy);
        uint256[] memory ids = new uint256[](balance);
        uint256 count;
        for(uint256 i; i < balance; i++){
            uint256 id = nft.tokenOfOwnerByIndex(addy, i);
            if(tokenHashmap[id] == 0x0){
                ids[count++] = id;
            }
        }

        uint256[] memory trim_ids = new uint256[](count);
        for(uint256 i; i < count; i++){
            trim_ids[i] = ids[i];
        }

        return trim_ids;
    }

   function getTokenDomain(uint256 token_id) private view returns(string memory uri){

        require(tokenHashmap[token_id] != 0x0, "Token does not have an ENS register");
        uri = string(abi.encodePacked(hashToDomainMap[tokenHashmap[token_id]] ,"." ,domainLabel, ".eth"));
    }

    function getTokensDomains(uint256[] memory token_ids) public view returns(string[] memory){

        string[] memory uris = new string[](token_ids.length);
        for(uint256 i; i < token_ids.length; i++){
           uris[i] = getTokenDomain(token_ids[i]);
        }
        return uris;
    }

    function getAllCatsWithDomains(address addy) public view returns(uint256[] memory){

        uint256 balance = nft.balanceOf(addy);
        uint256[] memory ids = new uint256[](balance);
        uint256 count;
        for(uint256 i; i < balance; i++){
            uint256 id = nft.tokenOfOwnerByIndex(addy, i);
            if(tokenHashmap[id] != 0x0){
                ids[count++] = id;
            }
        }

        uint256[] memory trim_ids = new uint256[](count);
        for(uint256 i; i < count; i++){
            trim_ids[i] = ids[i];
        }

        return trim_ids;
    }


    function addressToString(address _addr) private pure returns(string memory) {

    bytes32 value = bytes32(uint256(uint160(_addr)));
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(51);
    str[0] = "0";
    str[1] = "x";
    for (uint i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
        str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
    return string(str);
    }

    function getDomainHash() private view returns (bytes32 namehash) {

            namehash = 0x0;
            namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked('eth'))));
            namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked(domainLabel))));
    }


    function setDomain(string calldata label, uint256 token_id) public isAuthorised(token_id) {     

        require(tokenHashmap[token_id] == 0x0, "Token has already been set");
        require(address_whitelist[msg.sender] || publicClaimOpen || owner() == msg.sender, "Not authorised");
        require(block.timestamp > nextRegisterTimestamp[msg.sender], "Wallet must wait more time to register");
           
        bytes32 encoded_label = keccak256(abi.encodePacked(label));
        bytes32 big_hash = keccak256(abi.encodePacked(domainHash, encoded_label));

        require(!ens.recordExists(big_hash) || msg.sender == owner(), "sub-domain already exists");
        
        ens.setSubnodeRecord(domainHash, encoded_label, owner(), address(this), 0);

        hashToIdMap[big_hash] = token_id;        
        tokenHashmap[token_id] = big_hash;
        hashToDomainMap[big_hash] = label;

        if (owner() != msg.sender){                 
            nextRegisterTimestamp[msg.sender] = block.timestamp + reset_period;

            if (address_whitelist[msg.sender]){
                address_whitelist[msg.sender] = false;
            }
        }

        emit RegisterSubdomain(nft.ownerOf(token_id), token_id, label);     
    }

    function setText(bytes32 node, string calldata key, string calldata value) external isAuthorised(hashToIdMap[node]) {

        uint256 token_id = hashToIdMap[node];
        require(token_id > 0 && tokenHashmap[token_id] != 0x0, "Invalid address");
        require(keccak256(abi.encodePacked(key)) != keccak256("avatar"), "cannot set avatar");

        texts[node][key] = value;
        emit TextChanged(node, key, key);
    }
        
    function resetHash(uint256 token_id) public isAuthorised(token_id) {

        
        bytes32 domain = tokenHashmap[token_id];
        require(ens.recordExists(domain), "Sub-domain does not exist");
        
        hashToDomainMap[domain] = "";      
        hashToIdMap[domain] = 0;
        tokenHashmap[token_id] = 0x0;

        if(nextRegisterTimestamp[msg.sender] > block.timestamp && msg.sender != owner()){
            nextRegisterTimestamp[msg.sender] = block.timestamp + (60 * 30); //30 minute cooldown
        }
        
    }


    function addAddressWhitelist(address[] calldata addresses) public onlyOwner {

        for(uint256 i; i < addresses.length; i++){
           address_whitelist[addresses[i]] = true;     
        }
    }

    function setDomainLabel(string calldata label) public onlyOwner {

        domainLabel = label;
        domainHash = getDomainHash();
    }

    function setNftAddress(address addy) public onlyOwner{

        nft = IERC721Enumerable(addy);
    }

    function toggleNftImageLink() public onlyOwner{

        useEIP155 = !useEIP155;
    }

    function setNftImageBaseUri(string memory _uri) public onlyOwner{

        nftImageBaseUri = _uri;
    }

    function setEnsAddress(address addy) public onlyOwner {

        ens = ENS(addy);
    }

    function resetAddressForClaim(address addy) public onlyOwner {

        nextRegisterTimestamp[addy] = 0;
    }

    function togglePublicClaim() public onlyOwner {

        publicClaimOpen = !publicClaimOpen;
    }

    function updateResetPeriod(uint256 time) public onlyOwner {

        reset_period = time;
    }

    function renounceOwnership() public override onlyOwner {

        require(false, "ENS is responsibility. You cannot renounce ownership.");
        super.renounceOwnership();
    }

	function withdraw() public onlyOwner {

		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

	function withdrawTokens(IERC20 token) public onlyOwner {

		require(address(token) != address(0));
		uint256 balance = token.balanceOf(address(this));
		token.transfer(msg.sender, balance);
	}


    modifier isAuthorised(uint256 tokenId) {

        require(owner() == msg.sender || nft.ownerOf(tokenId) == msg.sender, "Not authorised");
        _;
    }
}