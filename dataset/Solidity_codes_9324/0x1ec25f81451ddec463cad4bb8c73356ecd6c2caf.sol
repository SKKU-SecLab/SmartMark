
pragma solidity >=0.5.0 <0.6.0 ;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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




library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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



contract ERC721 is ERC165, IERC721 {

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

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
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

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
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

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
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




contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

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



contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

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



library Strings {

      
      function Concatenate(string memory a, string memory b) internal pure returns (string memory concatenatedString) {

        bytes memory bytesA = bytes(a);
        bytes memory bytesB = bytes(b);
        string memory concatenatedAB = new string(bytesA.length + bytesB.length);
        bytes memory bytesAB = bytes(concatenatedAB);
        uint concatendatedIndex = 0;
        uint index = 0;
        for (index = 0; index < bytesA.length; index++) {
          bytesAB[concatendatedIndex++] = bytesA[index];
        }
        for (index = 0; index < bytesB.length; index++) {
          bytesAB[concatendatedIndex++] = bytesB[index];
        }
          
        return string(bytesAB);
      }
    
      function UintToString(uint value) internal pure returns (string memory uintAsString) {

        uint tempValue = value;
        
        if (tempValue == 0) {
          return "0";
        }
        uint j = tempValue;
        uint length;
        while (j != 0) {
          length++;
          j /= 10;
        }
        bytes memory byteString = new bytes(length);
        uint index = length - 1;
        while (tempValue != 0) {
          byteString[index--] = byte(uint8(48 + tempValue % 10));
          tempValue /= 10;
        }
        return string(byteString);
      }
}

library SafeMath8 {


  function mul(uint8 a, uint8 b) internal pure returns (uint8) {

    if (a == 0) {
      return 0;
    }
    uint8 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint8 a, uint8 b) internal pure returns (uint8) {

    uint8 c = a / b;
    return c;
  }

  function sub(uint8 a, uint8 b) internal pure returns (uint8) {

    assert(b <= a);
    return a - b;
  }

  function add(uint8 a, uint8 b) internal pure returns (uint8) {

    uint8 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract OwnableDelegateProxy { }


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}



contract dNumber is Ownable, ERC721Full {

    
    
    event NewDecPlace(uint id, uint8 digit, uint8 level, address owner);
    event LevelUp(uint id, uint8 digit, uint8 level);

	using SafeMath for uint256;
	using SafeMath8 for uint8;
	using Strings for string;

	uint public levelUpFee = 0.001 ether;
	uint public newDecPlaceFee = 0.001 ether;
    address proxyRegistryAddress; //for opensea
    string baseURI = "https://dnum.xyz/d/";

	struct DecPlace {
		uint8 digit;
		uint8 level;
	}

	DecPlace[] public decPlaces;

	modifier onlyOwnerOf(uint _decPlaceId) {

		require(msg.sender == ownerOf(_decPlaceId));
		_;
	}

	constructor(address _proxyRegistryAddress) 
        
        ERC721Full("d??  Number","DNUM") public {

        proxyRegistryAddress = _proxyRegistryAddress;

	}
	
	
	
	function _newDecPlace(uint8 _digit) internal {

		uint id = decPlaces.push(DecPlace(_digit, 1)) - 1;
		_mint(msg.sender, id);
		emit NewDecPlace(id, _digit, 1, msg.sender);
	}
	
	function _giftDecPlace(uint8 _digit, address _address) internal {

		uint id = decPlaces.push(DecPlace(_digit, 1)) - 1;
		_mint(_address, id);
		emit NewDecPlace(id, _digit, 1, _address);
	}
	
	
	function newDecPlace(uint8 _digit) external payable {

        require(msg.value==newDecPlaceFee);
		require(_digit <= 9);
		_newDecPlace(_digit);
	}
	
	function newMultiDecPlaces(uint8[] calldata _digitarray) external payable {

        uint _fee = ((_digitarray.length * (_digitarray.length + 1)) / 2 ) * newDecPlaceFee;
        require(msg.value==_fee);
        for (uint i=0; i<_digitarray.length; i++) {
            require(_digitarray[i] <= 9);
            _newDecPlace(_digitarray[i]);
        }
	}
	
	function giftnewDecPlace(uint8 _digit, address _address) external payable {

        require(msg.value==newDecPlaceFee);
		require(_digit <= 9);
		_giftDecPlace(_digit, _address);
	}
	
	function giftMultiDecPlaces(uint8[] calldata _digitarray, address _address) external payable {

        uint _fee = ((_digitarray.length * (_digitarray.length + 1)) / 2 ) * newDecPlaceFee;
        require(msg.value==_fee);
        for (uint i=0; i<_digitarray.length; i++) {
            require(_digitarray[i] <= 9);
            _giftDecPlace(_digitarray[i], _address);
        }
	}
	
	
    
	
	function levelUp(uint _decPlaceId, uint8 _digit) external payable onlyOwnerOf(_decPlaceId){

		require(msg.value==decPlaces[_decPlaceId].level * levelUpFee);
		require(_digit <= 9);
		decPlaces[_decPlaceId].digit = _digit;
		decPlaces[_decPlaceId].level = decPlaces[_decPlaceId].level.add(1);
		emit LevelUp(_decPlaceId, decPlaces[_decPlaceId].digit, decPlaces[_decPlaceId].level);
	}
	
	function multiLevelUp(uint _decPlaceId, uint8[] calldata _digitarray) external payable onlyOwnerOf(_decPlaceId){

		uint _fee = ((_digitarray.length * (_digitarray.length + 1)) / 2 ) * newDecPlaceFee;
        require(msg.value==_fee);
        for (uint i=0; i<_digitarray.length; i++) {
		require(_digitarray[i] <= 9);
		    decPlaces[_decPlaceId].digit = _digitarray[i];
		    decPlaces[_decPlaceId].level = decPlaces[_decPlaceId].level.add(1);
		    emit LevelUp(_decPlaceId, decPlaces[_decPlaceId].digit, decPlaces[_decPlaceId].level);
        }
	}
	
    
    
    function newDecPlaceBerk(uint8 _digit) external onlyOwner {

        _newDecPlace(_digit);
	}
    
	function newDecPlacesBerk(uint8[] calldata _digitarray) external onlyOwner {

        for (uint i=0; i<_digitarray.length; i++) {
            _newDecPlace(_digitarray[i]);
        }
	}
	
	function giftnewDecPlacesBerk(uint8[] calldata _digitarray, address _address) external onlyOwner {

		for (uint i=0; i<_digitarray.length; i++) {
            _giftDecPlace(_digitarray[i], _address);
        }
		
	}
	
	function levelUpBerk(uint _decPlaceId, uint8 _digit) external onlyOwner {

	    decPlaces[_decPlaceId].digit = _digit;
	    decPlaces[_decPlaceId].level = decPlaces[_decPlaceId].level.add(1);
	    emit LevelUp(_decPlaceId, decPlaces[_decPlaceId].digit, decPlaces[_decPlaceId].level);
	}
	
	function multiLevelUpBerk(uint _decPlaceId, uint8[] calldata _digitarray) external onlyOwner {

	    for (uint i=0; i<_digitarray.length; i++) {
		    decPlaces[_decPlaceId].digit = _digitarray[i];
		    decPlaces[_decPlaceId].level = decPlaces[_decPlaceId].level.add(1);
		    emit LevelUp(_decPlaceId, decPlaces[_decPlaceId].digit, decPlaces[_decPlaceId].level);
        }
	}

	
	function setLevelUpFee(uint _fee) external onlyOwner {

		levelUpFee = _fee;
	}
	
	function setNewDecPlaceFee(uint _fee) external onlyOwner {

		newDecPlaceFee = _fee;
	}

    function setNewBaseURI(string calldata _uri) external onlyOwner{

        baseURI = _uri;
    }
	
	function withdraw() external onlyOwner {

        address _ownerAddress = owner();
        address payable _owner = address(uint160(_ownerAddress)); // converting non payable addr to payable
        _owner.transfer(address(this).balance);
    }
    
    function tokensOfOwner(address owner) public view returns (uint256[] memory) {

        return super._tokensOfOwner(owner);
    }


    
	
    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "Token does not exist");
        return Strings.Concatenate(
        baseTokenURI(),
        Strings.UintToString(tokenId)
        );
    }
        
    function baseTokenURI() public view returns (string memory) {

        return baseURI;
    }

    function isApprovedForAll(
        address owner,
        address operator
    )
        public
        view
        returns (bool)
    {

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }


}