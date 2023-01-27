



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




pragma solidity ^0.8.0;

interface ERC721TokenReceiver {

	function onERC721Received(
		address operator,
		address from,
		uint256 id,
		bytes calldata data
	) external returns (bytes4);

}



pragma solidity ^0.8.0;


abstract contract ERC721 {

	event Transfer(address indexed from, address indexed to, uint256 indexed id);

	event Approval(address indexed owner, address indexed spender, uint256 indexed id);

	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


	string private _name;

	string private _symbol;


	mapping(uint256 => address) internal _tokenApprovals;

	mapping(address => mapping(address => bool)) internal _operatorApprovals;


	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}


	function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
		return
			interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
			interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
			interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
			interfaceId == 0x780e9d63; // ERC165 Interface ID for ERC721Enumerable
	}


	function name() public view virtual returns (string memory) {
		return _name;
	}

	function symbol() public view virtual returns (string memory) {
		return _symbol;
	}

	function tokenURI(uint256 id) public view virtual returns (string memory);


	function totalSupply() public view virtual returns (uint256);

	function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256);

	function tokenByIndex(uint256 index) public view virtual returns (uint256);


	function getApproved(uint256 id) public virtual returns (address) {
		require(_exists(id), "NONEXISTENT_TOKEN");
		return _tokenApprovals[id];
	}

	function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
		return _operatorApprovals[owner][operator];
	}

	function approve(address spender, uint256 id) public virtual {
		address owner = ownerOf(id);

		require(isApprovedForAll(owner, msg.sender) || msg.sender == owner, "NOT_AUTHORIZED");

		_tokenApprovals[id] = spender;

		emit Approval(owner, spender, id);
	}

	function setApprovalForAll(address operator, bool approved) public virtual {
		_operatorApprovals[msg.sender][operator] = approved;

		emit ApprovalForAll(msg.sender, operator, approved);
	}

	function transferFrom(
		address from,
		address to,
		uint256 id
	) public virtual {
		_transfer(from, to, id);
	}

	function safeTransferFrom(
		address from,
		address to,
		uint256 id
	) public virtual {
		_transfer(from, to, id);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	function safeTransferFrom(
		address from,
		address to,
		uint256 id,
		bytes memory data
	) public virtual {
		_transfer(from, to, id);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	function balanceOf(address owner) public view virtual returns (uint256);

	function ownerOf(uint256 id) public view virtual returns (address);


	function _exists(uint256 id) internal view virtual returns (bool);

	function _transfer(
		address from,
		address to,
		uint256 id
	) internal virtual;

	function _mint(address to, uint256 amount) internal virtual;

	function _safeMint(address to, uint256 amount) internal virtual {
		_mint(to, amount);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(address(0), to, totalSupply() - amount + 1, "") == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	function _safeMint(
		address to,
		uint256 amount,
		bytes memory data
	) internal virtual {
		_mint(to, amount);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(address(0), to, totalSupply() - amount + 1, data) == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}


	function toString(uint256 value) internal pure virtual returns (string memory) {

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



pragma solidity ^0.8.0;


interface IProxyRegistry {

	function proxies(address) external view returns (address);

}

abstract contract ERC721Tradable is ERC721 {

	address public immutable openSeaProxyRegistry;

	address public immutable looksRareTransferManager;


	bool public marketPlaceApprovalForAll = true;


	constructor(address _openSeaProxyRegistry, address _looksRareTransferManager) {
		require(_openSeaProxyRegistry != address(0) && _looksRareTransferManager != address(0), "INVALID_ADDRESS");
		openSeaProxyRegistry = _openSeaProxyRegistry;
		looksRareTransferManager = _looksRareTransferManager;
	}


	function setMarketplaceApprovalForAll(bool approved) public virtual;

	function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
		if (marketPlaceApprovalForAll && (operator == IProxyRegistry(openSeaProxyRegistry).proxies(owner) || operator == looksRareTransferManager)) return true;
		return super.isApprovedForAll(owner, operator);
	}
}



pragma solidity ^0.8.0;


abstract contract ERC721M is ERC721 {

	address[] internal _owners;


	constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
		_owners.push();
	}


	function totalSupply() public view override returns (uint256) {
		unchecked {
			return _owners.length - 1;
		}
	}

	function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
		require(index < balanceOf(owner), "INVALID_INDEX");

		unchecked {
			uint256 count;
			uint256 _currentIndex = _owners.length; // == totalSupply() + 1 == _owners.length - 1 + 1
			for (uint256 i; i < _currentIndex; i++) {
				if (owner == ownerOf(i)) {
					if (count == index) return i;
					else count++;
				}
			}
		}

		revert("NOT_FOUND");
	}

	function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
		require(_exists(index), "INVALID_INDEX");
		return index;
	}


	function balanceOf(address owner) public view virtual override returns (uint256 balance) {
		require(owner != address(0), "INVALID_OWNER");

		unchecked {
			uint256 _currentIndex = _owners.length; // == totalSupply() + 1 == _owners.length - 1 + 1
			for (uint256 i = 1; i < _currentIndex; i++) {
				if (owner == ownerOf(i)) {
					balance++;
				}
			}
		}
	}

	function ownerOf(uint256 id) public view virtual override returns (address owner) {
		require(_exists(id), "NONEXISTENT_TOKEN");

		for (uint256 i = id; ; i++) {
			owner = _owners[i];
			if (owner != address(0)) {
				return owner;
			}
		}
	}


	function _mint(address to, uint256 amount) internal virtual override {
		require(to != address(0), "INVALID_RECIPIENT");
		require(amount != 0, "INVALID_AMOUNT");

		unchecked {
			uint256 _currentIndex = _owners.length; // == totalSupply() + 1 == _owners.length - 1 + 1

			for (uint256 i; i < amount - 1; i++) {
				_owners.push();
				emit Transfer(address(0), to, _currentIndex + i);
			}

			_owners.push(to);
			emit Transfer(address(0), to, _currentIndex + (amount - 1));
		}
	}

	function _exists(uint256 id) internal view virtual override returns (bool) {
		return id != 0 && id < _owners.length;
	}

	function _transfer(
		address from,
		address to,
		uint256 id
	) internal virtual override {
		require(ownerOf(id) == from, "WRONG_FROM");
		require(to != address(0), "INVALID_RECIPIENT");
		require(msg.sender == from || getApproved(id) == msg.sender || isApprovedForAll(from, msg.sender), "NOT_AUTHORIZED");

		delete _tokenApprovals[id];

		_owners[id] = to;

		unchecked {
			uint256 prevId = id - 1;
			if (_owners[prevId] == address(0)) {
				_owners[prevId] = from;
			}
		}

		emit Transfer(from, to, id);
	}
}



pragma solidity ^0.8.0;





contract Bendys is ERC721M, ERC721Tradable, Ownable {

	uint256 public constant PRICE = 0.02 ether;

	uint256 public constant MAX_SUPPLY = 2222;
	uint256 public constant MAX_RESERVE = 22;
	uint256 public constant MAX_PUBLIC = 2200; // MAX_SUPPLY - MAX_RESERVE
	uint256 public constant MAX_FREE = 150;

	uint256 public constant MAX_TX = 20;

	uint256 public reservesMinted;

	string public baseURI;

	bool public isSaleActive;

	mapping (address => bool) public hasClaimed;


	constructor(
		address _openSeaProxyRegistry,
		address _looksRareTransferManager,
		string memory _baseURI
	) payable ERC721M("Bendys", "BENDYS") ERC721Tradable(_openSeaProxyRegistry, _looksRareTransferManager) {
		baseURI = _baseURI;
	}


	function publicMint(uint256 amount) external payable {

		require(isSaleActive, "Sale is not active");
		require(msg.sender == tx.origin, "No contracts allowed");

		uint256 _totalSupply = totalSupply();
		if (_totalSupply < MAX_FREE) {
			require(!hasClaimed[msg.sender], "Already claimed");
			hasClaimed[msg.sender] = true;
			
			_mint(msg.sender, 1);
			
			return;
		}
			
		require(msg.value == PRICE * amount, "Wrong ether amount");
		require(amount <= MAX_TX, "Amount exceeds tx limit");
		require(_totalSupply + amount <= MAX_PUBLIC, "Max public supply reached");

		_mint(msg.sender, amount);
	}


	function setIsSaleActive(bool _isSaleActive) external onlyOwner {

		isSaleActive = _isSaleActive;
	}

	function reserveMint(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {

		unchecked {
			uint256 sum;
			uint256 length = recipients.length;
			for (uint256 i; i < length; i++) {
				address to = recipients[i];
				require(to != address(0), "Invalid recipient");
				uint256 amount = amounts[i];

				_mint(to, amount);
				sum += amount;
			}

			uint256 totalReserves = reservesMinted + sum;

			require(totalSupply() <= MAX_SUPPLY, "Max supply reached");
			require(totalReserves <= MAX_RESERVE, "Amount exceeds reserve limit");

			reservesMinted = totalReserves;
		}
	}

	function setBaseURI(string calldata _baseURI) external onlyOwner {

		baseURI = _baseURI;
	}

	function withdrawETH() external onlyOwner {

		_transferETH(msg.sender, address(this).balance);
	}

	function setMarketplaceApprovalForAll(bool approved) public override onlyOwner {

		marketPlaceApprovalForAll = approved;
	}


	function tokenURI(uint256 id) public view override returns (string memory) {

		require(_exists(id), "NONEXISTENT_TOKEN");
		string memory _baseURI = baseURI;
		return bytes(_baseURI).length == 0 ? "" : string(abi.encodePacked(_baseURI, toString(id)));
	}

	function isApprovedForAll(address owner, address operator) public view override(ERC721, ERC721Tradable) returns (bool) {

		return ERC721Tradable.isApprovedForAll(owner, operator);
	}


	function _transferETH(address to, uint256 value) internal {

		(bool success, ) = to.call{ value: value }("");
		require(success, "ETH transfer failed");
	}
}