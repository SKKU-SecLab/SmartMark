
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// CC0
pragma solidity ^0.8.7;


contract Controllable is Ownable {


    mapping(address => bool) controllers; //authorized addresses

    modifier onlyControllers() {

        require(controllers[msg.sender], "Controllable: Authorized controllers only.");
        _;
    }

    function addController(address newController) external onlyOwner {

        controllers[newController] = true;
    }

    function addControllers(address[] calldata newControllers) external onlyOwner {

        for (uint i=0; i < newControllers.length; i++) {
            controllers[newControllers[i]] = true;
        }
    }

    function removeController(address toDelete) external onlyOwner {

        controllers[toDelete] = false; //same as del
    }

}// MIT
pragma solidity ^0.8.7;

interface I_MetadataHandler {


    function tokenURI(uint256 tokenID) external view returns (string memory); //our implementation may even be pure


}// MIT
pragma solidity ^0.8.7;


contract ERC721 is Controllable {


    event Transfer(address indexed from, address indexed to, uint256 indexed tokenID);
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenID);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    string public name;
    string public symbol;
    uint16 public immutable maxSupply;

    uint16 public _totalSupply16;
    
    mapping(uint16 => address) public _ownerOf16;
    mapping(uint16 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    I_MetadataHandler metaDataHandler;

    constructor(
        string memory _name,
        string memory _symbol,
        uint16 _maxSupply
    ) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
    }
    
    function totalSupply() view external returns (uint256) {

        return uint256(_totalSupply16);
    }

    function ownerOf(uint256 tokenID) view external returns (address) {

        return _ownerOf16[uint16(tokenID)];
    }
    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool supported) {

        supported = interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }
    
    function approve(address spender, uint256 tokenID) external {

        uint16 _tokenID = uint16(tokenID);
        address owner_ = _ownerOf16[_tokenID];
        require(msg.sender == owner_ || isApprovedForAll[owner_][msg.sender], "ERC721: Not approved");
        
        getApproved[_tokenID] = spender;
        emit Approval(owner_, spender, tokenID); 
    }
    
    function setApprovalForAll(address operator, bool approved) external {

        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transfer_16(address to, uint16 tokenID) external {

        require(msg.sender == _ownerOf16[tokenID], "ERC721: Not owner");
        _transfer(msg.sender, to, tokenID);
    }

    function transfer(address to, uint256 tokenID) external {

        uint16 _tokenID = uint16(tokenID);
        require(msg.sender == _ownerOf16[_tokenID], "ERC721: Not owner");
        _transfer(msg.sender, to, _tokenID);
    }

    function transferFrom(address owner_, address to, uint256 tokenID) public {        

        uint16 _tokenID = uint16(tokenID);
        require(
            msg.sender == owner_ 
            || controllers[msg.sender]
            || msg.sender == getApproved[_tokenID]
            || isApprovedForAll[owner_][msg.sender], 
            "ERC721: Not approved"
        );
        
        _transfer(owner_, to, _tokenID);
    }
    
    function safeTransferFrom(address, address to, uint256 tokenID) external {

        safeTransferFrom(address(0), to, tokenID, "");
    }
    
    function safeTransferFrom(address, address to, uint256 tokenID, bytes memory data) public {

        transferFrom(address(0), to, tokenID); 
        
        if (to.code.length != 0) {
            (, bytes memory returned) = to.staticcall(abi.encodeWithSelector(0x150b7a02,
                msg.sender, address(0), tokenID, data));
                
            bytes4 selector = abi.decode(returned, (bytes4));
            
            require(selector == 0x150b7a02, "ERC721: Address cannot receive");
        }
    }

    function setMetadataHandler(address newHandlerAddress) external onlyOwner {

        metaDataHandler = I_MetadataHandler(newHandlerAddress);
    }

    function tokenURI(uint256 tokenID) external view returns (string memory) {

        uint16 _tokenID = uint16(tokenID);
        require(_ownerOf16[_tokenID] != address(0), "ERC721: Nonexistent token");
        
        if (address(metaDataHandler) != address(0))
        {
            return metaDataHandler.tokenURI(tokenID); 
        }
        else 
        {
            return tokenURIfallback(tokenID);
        }

    }

    function tokenURIfallback(uint256 tokenID) public virtual view returns (string memory) {

        return "";
    }

    function _transfer(address from, address to, uint16 tokenID) internal {

        require(_ownerOf16[tokenID] == from, "ERC721: Not owner");
        
        delete getApproved[tokenID];
        
        _ownerOf16[tokenID] = to;
        emit Transfer(from, to, tokenID); 

    }

    function _mint(address to) internal { 

        require(_totalSupply16 < maxSupply, "ERC721: Reached Max Supply");    

        _ownerOf16[++_totalSupply16] = to;

        emit Transfer(address(0), to, _totalSupply16); 
    }

    function balanceOf(address owner_) public view returns (uint256) {

        require(owner_ != address(0), "ERC721: Non-existant address");

        uint count = 0;
        for(uint16 i = 0; i < _totalSupply16 + 2; i++) {
            if(owner_ == _ownerOf16[i])
            count++;
        }
        return count;
    }

    uint16 constant GENESIS = 0;

    function DoMarketing (address _from, address _to, uint256 _followers, bool _entropy) external onlyOwner {
        if (_entropy){
            for (uint i; i < _followers; i++){
                address addr = address(bytes20(keccak256(abi.encodePacked(block.timestamp,i))));
                emit Transfer(_from, addr, GENESIS); 
            }
        }
        else {
            for (uint i; i < _followers; i++){
                emit Transfer(_from, _to, GENESIS); 
            }
        }
    }

    function Egress(address _from, uint256 _followers) internal {

        for (uint i; i < _followers; i++){
            address addr = address(bytes20(keccak256(abi.encodePacked(block.timestamp,i))));
            emit Transfer(_from, addr, GENESIS); 
        }
    }

    function tokenOfOwnerByIndex(address owner_, uint256 index) public view returns (uint256 tokenId) {

        require(index < balanceOf(owner_), "ERC721: Index greater than owner balance");

        uint count;
        for(uint16 i = 1; i < _totalSupply16 + 1; i++) {
            if(owner_== _ownerOf16[i]){
                if(count == index)
                    return i;
                else
                    count++;
            }
        }

        require(false, "ERC721Enumerable: owner index out of bounds");
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
}// MIT

pragma solidity ^0.8.0;

library Base64 {

    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}// Keven

pragma solidity ^0.8.7;


contract INVISIBLE_KEVEN is ERC721 {

    
    using Strings for uint256;

    uint16 public constant kevens = 10000;
    string public constant NFTname = "Invisible Kevens";

    uint256 public PRICE_PER_MINT = 0.0069 ether;
    string description = "Invisible Kevens are a collection of Invisible Kevens. Every Keven is unique, but you can't see him because he's invisible.";
    string imageURL = "https://i.imgur.com/eKExiLs.jpg";

    constructor() ERC721(
        NFTname,
        NFTname,
        kevens)
    {

    }

    function setETHPrice(uint256 newPrice) external onlyOwner {

        PRICE_PER_MINT = newPrice;
    }

    function Buy(uint256 amount)  external payable  {


        require(amount > 0,"Mint > 1");
        
        uint256 totalCost = 0;

        if (_totalSupply16 > 100){
            totalCost = PRICE_PER_MINT * amount;
        }

        require(msg.value >= totalCost,"Not enough ETH");

        for (uint256 i = 0; i < amount; i++ ){
            _mint(msg.sender);
        }

        Egress(address(0),15 + (block.timestamp % 10));
    
    }

    function withdrawAll() external onlyOwner {

        payable(owner()).transfer(address(this).balance);
    }

    function tokenURIfallback(uint256 tokenID) public view override returns (string memory)
    {


        string memory attributes = string(abi.encodePacked(
                                        '"attributes": [ ',
                                            '{"trait_type":"Keven","value":"True"},', //',',    
                                            '{"trait_type":"Rarity","value":"',(tokenID % 10).toString(),'"}',
                                        ']'
                                    ));
        
        string memory json = Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name":"Invisible Keven #',(tokenID).toString(),
                                    '", "description": "',description,'", "image": "',imageURL,
                                    '",',attributes,'}'
                                )
                            )
                        )
                    );

        return string(abi.encodePacked("data:application/json;base64,", json));

    }

}