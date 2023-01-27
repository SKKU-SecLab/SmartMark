

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
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

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;







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


pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.5.0;




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









contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract KryptonStarCard is ERC721 ,ERC721Metadata("KryptonStarCard","KPSC") ,Ownable{

  using SafeMath for uint256;

  event Birth(uint256 indexed cardIdx,address originOwner,string name,string meta,uint256 price,uint32 cooldownSecs,uint256 factor,uint256 originOwnerCut,uint256 birthAt);
  event ForceBuy(address indexed buyer, address indexed lastOwner, uint256 indexed cardIdx ,uint256 buyPrice,uint256 curPrice,uint256 transferAt,string meta);



  ERC20Interface kgcInstance;
  Card[] private cards;
  uint256 TotalCardNum; // for ERC721

  uint256 platformFee  = 150; //base 10000 %1.5
  uint256 feeBalance = 0;

  constructor(address kgcAddress) public {
    kgcInstance = ERC20Interface(kgcAddress);
  }


  struct Card {
    address OriginOwner;   // who create this card
    string Name;       // this card name
    string Meta;       //Meta info abount this card
    uint256 Price;     // price which can be set by owner
    uint256 LastTransferAt;//Last transfer at
    uint32 CooldownSecs ;//Cool down hours
    uint256 Factor;    // after Forcebuy, price will be (Price + (10000 + Factor) / 10000)
    uint256 OriginOwnerCut ; // 0 - 10000
  }


  modifier ensureMyCard(uint256 cardIdx) {

      require(
          msg.sender == this.ownerOf(cardIdx)
      );
      _;
  }

  function getCard(uint cardIdx) public view returns (
      address originOwner,
      string memory name,
      string memory meta,
      uint256 price,
      uint256 factor,
      uint32 cooldown,
      uint256 lastTransferAt,
      uint256 originOwnerCut
  ) {

      require(cardIdx < TotalCardNum);
      Card storage card = cards[cardIdx];
      originOwner = card.OriginOwner;
      name = card.Name;
      meta = card.Meta;
      price = card.Price;
      factor = card.Factor;
      lastTransferAt = card.LastTransferAt;
      originOwnerCut = card.OriginOwnerCut;
      cooldown = card.CooldownSecs;
  }



  function getPlantformFeeBalance() public view returns (uint256 ){

    return  feeBalance;
  }

  function withDrawPlatformFee() public onlyOwner {

    require(kgcInstance.transfer(this.owner(),feeBalance));
    feeBalance = 0;

  }

  function batchCreateCard(address[] memory _originOwner, address[] memory currentOwner, string[] memory _name,string[] memory _meta, uint256[] memory _price,uint256[] memory _factor,uint256[] memory _originOwnerCut,uint32[] memory _cooldown) onlyOwner public {

    for( uint i = 0; i < _originOwner.length;++i) {
      _createCard(_originOwner[i],currentOwner[i],_name[i],_meta[i],_price[i],_factor[i],_originOwnerCut[i],_cooldown[i]);
    }
  }

  function createCard(address _originOwner, address currentOwner, string memory _name,string memory _meta, uint256 _price,uint256 _factor,uint256 _originOwnerCut,uint32 _cooldown) onlyOwner public {

    _createCard(_originOwner,currentOwner,_name,_meta,_price,_factor,_originOwnerCut,_cooldown);
  }


  function forceBuy(uint256 cardIdx,string memory meta) public {

      _forceBuy(cardIdx,meta);
  }

  function _createCard(address _originOwner, address currentOwner, string memory _name,string memory _meta, uint256 _price,uint256 _factor,uint256 _originOwnerCut,uint32 _cooldown) internal {

      require(bytes(_name).length <= 40);
      require(_price >= 1 ether);
      require( _factor >= 500 && _factor <= 10000 );   //[1.05 , 2]
      require( _originOwnerCut <= 2000 );   // 0.05

      Card memory newCard = Card({
          OriginOwner : _originOwner,
          Name: _name,
          Meta : _meta,
          Price: _price,
          Factor: _factor,
          OriginOwnerCut : _originOwnerCut,
          CooldownSecs : _cooldown,
          LastTransferAt :0
      });
      uint256 newCardId = cards.push(newCard).sub(1);
      TotalCardNum = TotalCardNum.add(1);

      emit Birth(newCardId,_originOwner,_name,_meta,_price, _cooldown, _factor,_originOwnerCut,now);
      _mint(currentOwner,newCardId);
  }

  function _forceBuy(uint256 cardIdx,string memory meta) internal  {

      Card storage _card = cards[cardIdx];
      require(msg.sender != this.ownerOf(cardIdx));
      require(_card.Price != 0);
      require(now >= _card.LastTransferAt + _card.CooldownSecs );

      require(kgcInstance.transferFrom(msg.sender,address(this),_card.Price));

      uint256 oldPrice =  _card.Price;

      uint256 originOwnerGotFee = _computeCut(oldPrice, _card.OriginOwnerCut);
      uint256 platformGotFee = _computeCut(oldPrice, platformFee); //%1.5

      uint256 leftValue = oldPrice.sub(originOwnerGotFee).sub(platformGotFee);

      uint256 nextPrice = _card.Factor.add(10000).mul(_card.Price).div(10000);
      _card.Price = nextPrice;
      _card.LastTransferAt = now;
      _card.Meta = meta;

      address old_owner = this.ownerOf(cardIdx);

      _transferFrom(old_owner,msg.sender,cardIdx);
      require(kgcInstance.transfer(old_owner, leftValue));
      require(kgcInstance.transfer(_card.OriginOwner, originOwnerGotFee));

      feeBalance += platformGotFee;

      emit ForceBuy(msg.sender, old_owner,cardIdx,oldPrice,_card.Price ,now,meta);
  }


  function _computeCut(uint256 price, uint256 cut) private returns (uint256){

      return price.mul(cut).div(10000);
  }

}