pragma solidity >=0.5.16 <0.6.0;

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
pragma solidity >=0.5.16 <0.6.0;


contract Ownable is Context {

    address private _owner;

    constructor() public {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function isOwner(address _maker) public view returns (bool) {

        return owner()==_maker;
    }

    modifier onlyOwner() {

        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        _owner = newOwner;
    }
}
pragma solidity >=0.5.16 <0.6.0;


contract Admin  is Ownable{

    
    mapping (address => bool) private _admins;
    
    function isAdmin(address _maker) public view returns (bool) {

        if(owner()==_maker)
            return true;
        return _admins[_maker];
    }

    function addAdmin (address _evilUser) public onlyOwner {
        _admins[_evilUser] = true;
    }
    
    function addAdmin2 (address _evilUser, address _evilUser2) public onlyOwner {
        _admins[_evilUser] = true;
        _admins[_evilUser2] = true;
    }
    
    function addAdmin3 (address _evilUser, address _evilUser2, address _evilUser3) public onlyOwner {
        _admins[_evilUser] = true;
        _admins[_evilUser2] = true;
        _admins[_evilUser3] = true;
    }

    

    function removeAdmin (address _clearedUser) public onlyOwner {
        _admins[_clearedUser] = false;
    }
    
    modifier onlyAdmin() {

        require(isAdmin(_msgSender()), 'Admin: caller is not the admin');
        _;
    }

}
pragma solidity >=0.5.16 <0.6.0;

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
}pragma solidity >=0.5.16 <0.6.0;

library Strings {

    bytes16 private constant alphabet = '0123456789abcdef';

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return '0';
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

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++)bret[k++] = _bb[i];
        return string(ret);
    }
    
    function toString(address account) public pure returns(string memory) {

        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) public pure returns(string memory) {

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
    
}pragma solidity >=0.5.16 <0.6.0;

library Address {


    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}
pragma solidity >=0.5.16 <0.6.0;

interface IERC165 {


  function supportsInterface(bytes4 interfaceId) external view returns (bool);

}pragma solidity >=0.5.16 <0.6.0;

contract ERC165 is IERC165 {


    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() public
    {
        _registerInterface(_InterfaceId_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool)
    {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal
    {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity >=0.5.16 <0.6.0;



interface IERC2981 {


    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount);

    
}pragma solidity >=0.5.16 <0.6.0;


contract ERC2981 is IERC2981, ERC165 {


    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo internal _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) internal _tokenRoyaltyInfo;  //tokenId:royaltyInfo


    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    constructor() public
    {
        _registerInterface(_INTERFACE_ID_ERC2981);
    }
    
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256)
    {

        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();
        return (royalty.receiver, royaltyAmount);
    }

    function _feeDenominator() internal pure returns (uint96) {

        return 10000;
    }

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal {

        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    function _deleteDefaultRoyalty() internal {

        delete _defaultRoyaltyInfo;
    }

    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal {

        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    function _resetTokenRoyalty(uint256 tokenId) internal {

        delete _tokenRoyaltyInfo[tokenId];
    }

}


pragma solidity >=0.5.16 <0.6.0;


interface IERC721 {


  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) external view returns (uint256 balance);

  function ownerOf(uint256 tokenId) external view returns (address owner);


  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId) external view returns (address operator);


  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator) external view returns (bool);


  function transferFrom(address from, address to, uint256 tokenId) external;

  function safeTransferFrom(address from, address to, uint256 tokenId) external;


  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}pragma solidity >=0.5.16 <0.6.0;


interface IERC721Metadata {

    function name() external view returns (string memory _name);


    function symbol() external view returns (string memory _symbol);


    function tokenURI(uint256 _tokenId) external view returns (string memory);

}pragma solidity >=0.5.16 <0.6.0;

contract IERC721Receiver {

  function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns(bytes4);

}

pragma solidity >=0.5.16 <0.6.0;


contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool internal paused = false;


    modifier whenNotPaused() {

        require(!paused, "contract paused!");
        _;
    }

    modifier whenPaused() {

        require(paused, "contract should paused first!");
        _;
    }

    function pause() onlyOwner whenNotPaused public {

        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {

        paused = false;
        emit Unpause();
    }
}pragma solidity >=0.5.16 <0.6.0;


contract ERC721 is IERC721, IERC721Metadata, ERC2981, Pausable {


    using SafeMath for uint256;
    using Strings for uint256;
    using Strings for string;
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string internal _baseURI = "https://";

    mapping (uint256 => string) internal _tokenURIs;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
    
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
  
    modifier onlyOwnerOf(uint _tokenId) {

        require(tx.origin == _tokenOwner[_tokenId],'Token is not yours');
        _;
    }

    constructor(string memory name_, string memory symbol_) public
    {
        _name = name_;
        _symbol = symbol_;
        
        _registerInterface(_InterfaceId_ERC721);
        
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

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_tokenURI).length == 0) {
            return "";
        }
        else
        {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    function baseURI() external view returns (string memory) {

        return _baseURI;
    }
    
    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), 'ERC721: balance query for the zero address');
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');
        return owner;
    }

    function approve(address to, uint256 tokenId) public whenNotPaused {

        address owner = ownerOf(tokenId);
        require(owner != address(0) && to != owner, 'ERC721: approval to current owner');
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), 'ERC721: approve caller is not owner nor approved for all');

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), 'ERC721: approved query for nonexistent token');
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, 'ERC721: approve to caller');
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool)
    {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public whenNotPaused
    {

        require(_isApprovedOrOwner(msg.sender, tokenId), 'ERC721: transfer caller is not owner nor approved');
        require(to != address(0), 'ERC721: transfer to address invalid');

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public whenNotPaused
    {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public whenNotPaused
    {

        require(_isApprovedOrOwner(msg.sender, tokenId), 'ERC721: transfer caller is not owner nor approved');
        _safeTransfer(from, to, tokenId, _data);
        
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool)
    {

        require(_exists(tokenId), 'ERC721: operator query for nonexistent token');
        
        address owner = ownerOf(tokenId);
        return (
            spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender)
        );
    }

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, '');
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), 'ERC721: mint to the zero address');
        require(!_exists(tokenId), 'ERC721: token already minted');
        
        _beforeTokenTransfer(address(0), to, tokenId);
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {

        address owner = ownerOf(tokenId);
        _burn(owner, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        _beforeTokenTransfer(owner, address(0), tokenId);
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        delete _tokenOwner[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    function _addTokenTo(address to, uint256 tokenId) internal {

        require(_tokenOwner[tokenId] == address(0));
        _tokenOwner[tokenId] = to;
        _balances[to] = _balances[to].add(1);
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, 'ERC721: _removeTokenFrom of token that is not own');
        _balances[from] = _balances[from].sub(1);
        _tokenOwner[tokenId] = address(0);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
        require(to != address(0), 'ERC721: transfer to the zero address');

        _beforeTokenTransfer(from, to, tokenId);

        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal {

        address owner = ownerOf(tokenId);
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(address owner, uint256 tokenId) private {

        require(ownerOf(tokenId) == owner, 'ERC721: _clearApproval of token that is not own');
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}

}


pragma solidity >=0.5.16 <0.6.0;

interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}pragma solidity >=0.5.16 <0.6.0;


contract ERC721Enumerable is ERC721, IERC721Enumerable {
    
    mapping(address => mapping(uint256 => uint256)) internal _ownedTokens;

    mapping(uint256 => uint256) internal _ownedTokensIndex;

    uint256[] internal _allTokens;

    mapping(uint256 => uint256) internal _allTokensIndex;

    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory result = new uint256[](tokenCount);
        
        for (uint256 index = 0; index < tokenCount; index++) {
            uint256 id = _ownedTokens[owner][index];
            result[index] = id;
        }
        return result;
    }
    
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), 'ERC721Enumerable: owner index out of bounds');
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), 'ERC721Enumerable: global index out of bounds');
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}pragma solidity >=0.5.16 <0.6.0;


contract ERC20Token {
    function balanceOf(address account) external view returns (uint256){
        account;
    }
    
    function approve(address spender, uint256 amount) external returns (bool){
        spender;
        amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        sender;
        recipient;
        amount;
    }
}

contract UpgradeToken {

    function upTokenApprovals(address to, uint256 tokenId) public{
        to;
        tokenId;
    }

    function upRoyalty(uint256 tokenId, address receiver, uint96 royaltyFraction) public{
        tokenId;
        receiver;
        royaltyFraction;
    }
    
    function upTokenURI(uint256 tokenId, address owner, string memory uri) public{
        tokenId;
        uri;
    }
    
}

contract Thewords is Admin, ERC721Enumerable {
    
    using SafeMath for uint256;
    using Strings for uint256;

    event NewWord(uint256 id, address owner);

    mapping(uint8=>address) private tokenAddrsConfig;           //type->tokenaddr
    mapping(uint8=>uint256) private pricesConfig;               //priceType-->min

    constructor() ERC721('thewords.cc', 'WORDS') public {
        _baseURI = "https://user-nft.s3.ap-southeast-1.amazonaws.com/thewords/";
        _setDefaultRoyalty(address(this), 100);
        pricesConfig[0] = 0.1 ether;
    }
    
    function createByPay(string memory tokenURI) public payable whenNotPaused{
        uint256 price = pricesConfig[0];
        require(msg.value >= price,'No enough money');
        createNft(msg.sender, tokenURI);
    }

    function createByToken(uint8 _type, string memory tokenURI) public whenNotPaused{
        uint256 price = pricesConfig[_type];

        address moneyAddr = tokenAddrsConfig[_type];
        require(moneyAddr != address(0),'money token no exist!');
        
        ERC20Token ercToken = ERC20Token(moneyAddr);
        uint256 tokenCount = ercToken.balanceOf(msg.sender);
        require(tokenCount >= price,'No enough token');
        
        ercToken.transferFrom(msg.sender, address(this), price);

        createNft(msg.sender, tokenURI);
    }

    function createByAdmin(address creator, string memory tokenURI) public whenNotPaused onlyAdmin{
        createNft(creator, tokenURI);
    }

    function createNft(address creator, string memory tokenURI) internal{
         uint256 _id = totalSupply().add(1);
        _mint(creator, _id);
        _tokenURIs[_id] = tokenURI;

        _setTokenRoyalty(_id, creator, 500);
        emit NewWord(_id, creator);
    }


    function() external payable {
    }
    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    function withdraw(uint256 amount) external onlyOwner {
        msg.sender.transfer(amount);
    }
    function withdraw(address ercAddr, uint256 amount) external onlyOwner {
        ERC20Token ercToken = ERC20Token(ercAddr);
        ercToken.approve(address(this), amount);
        ercToken.transferFrom(address(this), msg.sender, amount);
    }

    function checkBalance() external view onlyOwner returns(uint256) {
        return address(this).balance;
    }
    function checkBalance(address ercAddr) external view onlyOwner returns(uint256) {
        ERC20Token ercToken = ERC20Token(ercAddr);
        uint256 tokenCount = ercToken.balanceOf(address(this));
        return tokenCount;
    }


    function setTokenAddrs(uint8 _type, address _value) external onlyAdmin{
        tokenAddrsConfig[_type] = _value;
    }
    function getTokenAddr(uint8 _type) external view returns(address){
        return tokenAddrsConfig[_type];
    }

    function setPrice(uint8 _type, uint256 _value) external onlyAdmin{
        pricesConfig[_type] = _value;
    }
    function getPrice(uint8 _type) external view returns(uint256){
        return pricesConfig[_type];
    }

    function setBaseURI(string memory _uri) public onlyAdmin{
        _baseURI = _uri;
    }
    function getTokenURI(uint256 _tokenId) external view returns(string memory){
        return _tokenURIs[_tokenId];
    }

    function upgrade(address newAddr) external onlyAdmin {
        
        
        UpgradeToken upgradeToken = UpgradeToken(newAddr);
        for (uint256 index = 0; index < _allTokens.length; index++) {
            uint256 tokenId = _allTokens[index];
            if(!_exists(tokenId))
                continue;
            
            address owner = ownerOf(tokenId);
            
            RoyaltyInfo memory _royalty = _tokenRoyaltyInfo[tokenId];
            if(_royalty.receiver != address(0) && _royalty.royaltyFraction>0)
            {
                upgradeToken.upRoyalty(tokenId, _royalty.receiver, _royalty.royaltyFraction);
            }
            
            address approval = getApproved(tokenId);
            if (approval != address(0))
            {
                upgradeToken.upTokenApprovals(approval, tokenId);
            }
            
            string memory uri = _tokenURIs[tokenId];
            if (bytes(uri).length > 0)
            {
                upgradeToken.upTokenURI(tokenId, owner, uri);
            }
        }
        
    }

    function upTokenApprovals(address to, uint256 tokenId) public onlyAdmin{
        _approve(to, tokenId);
    }
            
    function upRoyalty(uint256 tokenId, address receiver, uint96 royaltyFraction) public onlyAdmin{
        if(receiver != address(0) && royaltyFraction>0)
        {
            _setTokenRoyalty(tokenId, receiver, royaltyFraction);
        }
    }
    
    function upTokenURI(uint256 tokenId, address owner, string memory uri) public onlyAdmin{
        _mint(owner, tokenId);
        _tokenURIs[tokenId] = uri;
    }

}pragma solidity >=0.5.16 <0.6.0;

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