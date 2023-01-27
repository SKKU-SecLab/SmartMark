
pragma solidity >=0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public{
        _setOwner(_msgSender());
    }

    function owner() public view  returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {

        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public  onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Context, ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}

contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}

contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}

contract HelloWorld is Ownable, ERC721Full {

    using SafeMath for uint256;

    struct uri{
        string url;
        bool isVaild;
    }
    mapping(string  => uint256) value_to_id;
    mapping(uint256 => string) id_to_value;
    mapping (uint256 => address) public creators;

    address public foundationAddress = 0x40E6142eB4139342847eEEE679838cC9cDD7ff6b;

    uint256 public addPay = 30000000000000000;

    uint256 public foundationPay = 10000000000000000;
    uint256 public creatorPay = 2000000000000000;
    uint256 public ownerPay = 8000000000000000;

    uint256 sizePx = 30;

    mapping(uint256 => uint256) public usageCount;
    mapping(uint256 => mapping(address => uint256)) public ownerIncome;
    mapping(address => uint256) public ownerIncomeAll;
    mapping(uint256 => uint256) public creatorIncome;
    mapping(address => uint256) public creatorIncomeAll;
    mapping(uint256 => uri) public tokenUrl;

    mapping(uint256 => uint256) public initBytesLength;




    event rgToken(uint256 indexed tokenId,address owner,string value);

    event addToken(uint256 indexed tokenAId,address tokenAOwner,string tokenAValue,uint256 indexed tokenBId,address tokenBOwner,string tokenBValue);

    constructor() ERC721Full("HelloWorld", "HelloWorld") public {
        _mint(msg.sender, 0);

        string[88] memory basic_characters = ["0","1","2","3","4","5","6","7","8","9", "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","~","!","@","#","$","%","^","*","(",")","-","+","[","]","|",":","'",",",".","/","?","_","=",";","·"," "];

        for (uint256 i = 0; i < basic_characters.length; ++i )
        {
            string memory character = basic_characters[i];
            _registerToken(character,1);
        }
    }

    function create(string calldata _value,uint256 _initBytesLength) external onlyOwner(){

        require(bytes(_value).length > 0,"_value Can not be empty");
        require(value_to_id[_value] == 0,"Already exist, please do not create again");
        _registerToken(_value,_initBytesLength);
    }

    function setFoundationAddress(address _foundationAddress) external onlyOwner(){

        foundationAddress = _foundationAddress;
    }

    function setTokenUrl(uint256 _tokenId,string calldata _tokenUrl,bool _isVaild) external onlyOwner(){

        tokenUrl[_tokenId].isVaild = _isVaild;
        tokenUrl[_tokenId].url = _tokenUrl;
    }

    function getUsageCount(uint256 tokenId) public view returns (string memory) {

        return toString(usageCount[tokenId]);
    }

    function getIncome(address _address) public view returns(uint256,uint256){

        return(ownerIncomeAll[_address],creatorIncomeAll[_address]);
    }

    function setAllocation(uint256 _addPay,uint256 _foundationPay,uint256 _creatorPay,uint256 _ownerPay) external onlyOwner(){

        addPay = _addPay;
        foundationPay = _foundationPay;
        creatorPay = _creatorPay;
        ownerPay = _ownerPay;
    }

    function setPx(uint256 _px) external onlyOwner(){

        sizePx = _px;
    }

    function _registerToken(string memory value,uint256 _initBytesLength) private {

        uint256 tokenId = totalSupply();
        require(creators[tokenId] == address(0x0), "Token is already minted");
        creators[tokenId] = msg.sender;
        id_to_value[tokenId] = value;
        value_to_id[value] = tokenId;
        if(_initBytesLength > 1){
            initBytesLength[tokenId] = _initBytesLength;
        }
        _mint(msg.sender, tokenId);
        emit rgToken(tokenId,msg.sender,value);

    }

    function add(string memory token1, string memory token2) public payable {

        require(msg.value == addPay,"INSUFFICIENT_BALANCE");
        require(bytes(token1).length > 0,"DOES NOT EXIST");
        require(bytes(token2).length > 0,"DOES NOT EXIST");

        string memory token3 = string(abi.encodePacked(token1,token2));

        uint256 tokenId1 = value_to_id[token1];
        uint256 tokenId2 = value_to_id[token2];
        uint256 tokenId3 = value_to_id[token3];

        require(tokenId1 > 0,"token1 does not exist");
        require(tokenId2 > 0,"token2 does not exist");
        require(tokenId3 == 0,"The Token that needs to be added exists and cannot be added");

        address payable owner1 = address(uint160(ownerOf(tokenId1)));
        address payable creators1 = address(uint160(creators[tokenId1]));

        address payable owner2 = address(uint160(ownerOf(tokenId2)));
        address payable creators2 = address(uint160(creators[tokenId2]));

        address payable fdAddress = address(uint160(foundationAddress));

        emit addToken(tokenId1,creators[tokenId1],token1,tokenId2,creators[tokenId2],token2);
        uint256 _initBytesLength = 1;
        if(initBytesLength[tokenId1] >= 3 && initBytesLength[tokenId2] >= 3){
            _initBytesLength = 3;
        }
        _registerToken(token3,_initBytesLength);
        owner1.transfer(ownerPay);
        creators1.transfer(creatorPay);
        owner2.transfer(ownerPay);
        creators2.transfer(creatorPay);
        fdAddress.transfer(foundationPay);
        usageCount[tokenId1] = usageCount[tokenId1].add(1);
        ownerIncome[tokenId1][ownerOf(tokenId1)] = ownerIncome[tokenId1][ownerOf(tokenId1)].add(ownerPay);
        usageCount[tokenId2] = usageCount[tokenId2].add(1);
        ownerIncome[tokenId2][ownerOf(tokenId2)] = ownerIncome[tokenId2][ownerOf(tokenId2)].add(ownerPay);
        ownerIncomeAll[ownerOf(tokenId1)]=ownerIncomeAll[ownerOf(tokenId1)].add(ownerPay);
        ownerIncomeAll[ownerOf(tokenId2)]=ownerIncomeAll[ownerOf(tokenId2)].add(ownerPay);
        creatorIncomeAll[creators[tokenId1]]=creatorIncomeAll[creators[tokenId1]].add(creatorPay);
        creatorIncomeAll[creators[tokenId2]]=creatorIncomeAll[creators[tokenId2]].add(creatorPay);
        creatorIncome[tokenId1] = creatorIncome[tokenId1].add(creatorPay);
        creatorIncome[tokenId2] = creatorIncome[tokenId2].add(creatorPay);

    }

    function isExist(string memory _tokenValue) public view returns (bool) {

        return value_to_id[_tokenValue] > 0;
    }

    function getWord(uint256 id) public view returns (string memory) {

        return id_to_value[id];
    }


    function getStyle(string memory _letter,uint256 _tokenId) private view returns(uint256){

        uint256 px = 0;
        if(initBytesLength[_tokenId] >= 3){
            px = uint256(306).div((bytes(_letter).length.div(3)));
        }else{
            px = uint256(306).div((bytes(_letter).length.div(2).add(1)));
        }

        if(px<sizePx){
            px = sizePx;
        }
        return px;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if(tokenUrl[tokenId].isVaild){
            return tokenUrl[tokenId].url;
        }
        string memory letter = id_to_value[tokenId];

        uint256 px = getStyle(letter,tokenId);
        string[13] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" version="1.1"> ';
        parts[1] = '<foreignObject x="-12" y="-12" width="534" height="500" style="background-color:black; "> ';
        parts[2] = '<defs><style>.tx{color:#f2f2f2;} ::-webkit-scrollbar {width:12px;}</style></defs> ';
        parts[3] = '<body xmlns="http://www.w3.org/1999/xhtml" > ';
        parts[4] = '<div style="display:flex;align-items:center;text-align:center;width:500px;height:500px;overflow-x:auto;"> ';
        parts[5] = '<div class="tx" style="text-align: center;font-size:';
        parts[6] = toString(px);
        parts[7] = 'px;display:table-cell;width:512px;vertical-align: middle;word-wrap:break-word;vertical-align: middle;max-height:500px">';
        parts[8] = letter;
        parts[9] = '</div></div> </body> </foreignObject> </svg>';
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8], parts[9]));
        parts[10] = '{"attributes":[{"value":"';
        parts[11] = getUsageCount(tokenId);
        parts[12] = '","trait_type":"addCount"}],';
        string memory json = Base64.encode(bytes(string(abi.encodePacked(parts[10],parts[11],parts[12],'"name": "', letter, '", "description": "',letter,'", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }




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
}


library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
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
}