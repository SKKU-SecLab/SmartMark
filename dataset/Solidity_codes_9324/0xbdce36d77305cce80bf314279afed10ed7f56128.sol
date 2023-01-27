


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






contract EventTicket is ERC721Full {

    constructor() ERC721Full("PhoenixDAO Ticket", "DDD") public {
        
    }
    
    struct Ticket {
		uint event_id;
		uint seat;
	}
	
	Ticket[] internal tickets;
	
	
	    
	        
	        
	        
	
	function tokenOwner(uint id) external view returns(address) {

	    return ownerOf(id);
	}

	function getTicket(uint _id) public view returns(uint, uint) {

		require(_id != 0, "DaoEvents:getTicket: Invalid ID");
		require(_id <= tickets.length);
		Ticket memory _ticket = tickets[_id - 1];
		return(_ticket.event_id, _ticket.seat);
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




pragma solidity ^0.5.0;


contract DaoEvents is EventTicket, Ownable {

    using SafeMath for uint256;
    
    uint256 public _eventIds;
    uint256 public _ticketIds;
    address tokenAddress;
    
    struct Event {
        string name;
        uint time;
        uint price;
        bool token;
        bool limited;
        uint seats;
        uint sold;
        string ipfs;
        string category;
        address payable owner;
    }
    mapping(address => uint256[]) private ownedEvents;
    mapping(uint256 => uint256) public eventRevenue;
    mapping(uint256 => Event) public events;
    event CreatedEvent(uint256 eventId, string name ,uint256 time, uint256 price, bool token, bool limited, uint256 seats, uint256 sold, string ipfs, string category, address indexed owner);
    event SoldTicket(address indexed buyer, uint256 indexed eventId, uint256 ticketId);
    event UpdatedEvent(uint256 eventId,uint256 time, uint256 price, uint256 seats, string ipfs, string category);
    event NewAndUpdatedEvent(uint256 eventId, string name ,uint256 time, uint256 price, bool token, bool limited, uint256 seats, uint256 sold, string ipfs, string category, address indexed owner);
    event DeletedEvent(uint256 indexed eventId);
    constructor(address _token) public {
        tokenAddress = _token;
    }
    modifier goodTime(uint256 _time) {

        require(_time > block.timestamp, "Invalid Timestamp.");
        _;
    }
    modifier eventExist(uint256 _id) {

        require(_id <= _eventIds, "Event does not exist.");
        _;
    }
    function chengeToken(address _token) public onlyOwner() {

        tokenAddress = _token;
    }
    function createEvent(
        string memory _name,
        uint256 _time,
        uint256 _price,
        bool _token,
        bool _limited,
        uint256 _seats,
        string memory _ipfs,
        string memory _category
    )
        goodTime(_time)
        public
    {

        Event memory _event;
        _event.name = _name;
        _event.time = _time;
        _event.price = _price;
        _event.token = _token;
        _event.limited = _limited;
        _event.seats = _seats;
        _event.sold = 0;
        _event.ipfs = _ipfs;
        _event.category = _category;
        _event.owner = msg.sender;
        _eventIds++;
        uint256 _eventId = _eventIds;
        events[_eventId] = _event;
        ownedEvents[msg.sender].push(_eventId);
        emit CreatedEvent(_eventId, _event.name, _event.time, _event.price, _event.token, _event.limited, _event.seats, 0, _event.ipfs, _event.category, msg.sender);
        emit NewAndUpdatedEvent(_eventId, _event.name, _event.time, _event.price, _event.token, _event.limited, _event.seats, 0, _event.ipfs, _event.category, msg.sender);
    }
    function updateEvent(
        uint256 _eventId,
        uint256 _time,
        uint256 _price,
        bool _token,
        bool _limited,
        uint256 _seats,
        string memory _ipfs,
        string memory _category
    ) 
        goodTime(_time)
        eventExist(_eventId)
        public
    {

        require(events[_eventId].owner != address(0), "Event has deleted.");
        require(events[_eventId].owner == msg.sender, "Only Event owner can access.");
        events[_eventId].time = _time;
        events[_eventId].price = _price;
        events[_eventId].token = _token;
        events[_eventId].limited = _limited;
        events[_eventId].seats = _seats;
        events[_eventId].ipfs = _ipfs;
        events[_eventId].category = _category;
        Event memory _event = events[_eventId];
        emit UpdatedEvent(_eventId, _event.time, _event.price, _event.seats, _event.ipfs, _event.category);
        
        emit NewAndUpdatedEvent(_eventId, _event.name, _event.time, _event.price, _event.token, _event.limited, _event.seats, _event.sold, _event.ipfs, _event.category, msg.sender);
    }
    function deleteEvent(uint256 _id) public eventExist(_id) {

        require(events[_id].owner != address(0), "Event has deleted.");
        require(events[_id].owner == msg.sender, "Only Event owner can delete.");
        require(events[_id].sold == 0, "Event tickets has been sold so you cannot delete this event.");
        bool found = false;
        for(uint256 i = 0; i < ownedEvents[msg.sender].length; i++) {
            if(_id == ownedEvents[msg.sender][i]) {
                delete ownedEvents[msg.sender][i];
                found = true;
            }
        }
        require(found,"_id does not exist for this user");
        events[_id].name = '';
        events[_id].time = 0;
        events[_id].price = 0;
        events[_id].token = false;
        events[_id].limited = false;
        events[_id].seats = 0;
        events[_id].sold = 0;
        events[_id].ipfs = '';
        events[_id].category = '';
        events[_id].owner = address(0);
        emit DeletedEvent(_id);
    }
    function eventsOf(address _owner) public view returns(uint256[] memory) {

        return ownedEvents[_owner];
    }
    function ticketsOf(address owner) external view returns(uint256[] memory) {

        uint256 tokenCount = balanceOf(owner);
        
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTickets = _ticketIds;
            uint256 resultIndex = 0;
            
            uint256 ticketId;
            
            for (ticketId = 1; ticketId <= totalTickets; ticketId++) {
                if (ownerOf(ticketId) == owner) {
                    result[resultIndex] = ticketId ;
                    resultIndex++;
                }
            }
            
            return result;
        }
    }
    function getEventsCount() public view returns(uint256) {

        return _eventIds;
    }
    function buyTicket(uint256 _eventId)
        public
        payable
        eventExist(_eventId)
        goodTime(events[_eventId].time)
    {

        Event memory _event = events[_eventId];
        if (_event.limited) require(_event.seats > _event.sold);
        if (!_event.token) {
            require(msg.value >= _event.price);
            _event.owner.transfer(_event.price);
            
        } else {
            require(IERC20(tokenAddress).transferFrom(msg.sender, _event.owner, _event.price),""); 
               
            
            eventRevenue[_eventId]= eventRevenue[_eventId].add(_event.price);
        }
        events[_eventId].sold = _event.sold.add(1);

        Ticket memory _ticket = Ticket({
            event_id: _eventId,
            seat: events[_eventId].sold 
        });
        _ticketIds++;
        uint _ticketId = _ticketIds;
        tickets.push(_ticket);
        _mint(msg.sender, _ticketId);
        
        emit SoldTicket(msg.sender, _eventId, _ticketId);   
        emitUpdatestEvent(_eventId);
    }
    
    function emitUpdatestEvent(uint256 _eventId) private{

         Event memory _event = events[_eventId];
         emit NewAndUpdatedEvent(_eventId, _event.name, _event.time, _event.price, _event.token, _event.limited, _event.seats, _event.sold, _event.ipfs, _event.category, _event.owner);

    }
}