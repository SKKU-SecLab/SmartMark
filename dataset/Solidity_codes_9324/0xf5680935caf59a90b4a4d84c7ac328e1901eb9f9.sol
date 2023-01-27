
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721A is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint256 startTimestamp;
    }

    struct AddressData {
        uint128 balance;
        uint128 numberMinted;
    }

    uint256 internal currentIndex;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 internal constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 internal constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 internal constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 internal constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    bytes4 internal constant _INTERFACE_ID_EIP2981 = 0x2a55205a;
    bytes4 internal constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() public view override returns (uint256) {

        return currentIndex;
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        require(index < totalSupply(), 'ERC721A: global index out of bounds');
        return index;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        require(index < balanceOf(owner), 'ERC721A: owner index out of bounds');
        uint128 numMintedSoFar = uint128(totalSupply());
        uint128 tokenIdsIdx;
        address currOwnershipAddr;

        unchecked {
            uint128 i;
            for (i = 0; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }

        revert('ERC721A: unable to get token of owner by index');
    }

    function supportsInterface(bytes4 interfaceId) 
        public view virtual override(ERC165, IERC165) returns (bool)
    {

        return interfaceId == _INTERFACE_ID_ERC165
        || interfaceId == _INTERFACE_ID_ROYALTIES
        || interfaceId == _INTERFACE_ID_ERC721
        || interfaceId == _INTERFACE_ID_ERC721_METADATA
        || interfaceId == _INTERFACE_ID_ERC721_ENUMERABLE
        || interfaceId == _INTERFACE_ID_EIP2981
        || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), 'ERC721A: balance query for the zero address');
        return _addressData[owner].balance;
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        require(owner != address(0), 'ERC721A: number minted query for the zero address');
        return _addressData[owner].numberMinted;
    }

    function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        require(_exists(tokenId), 'ERC721A: owner query for nonexistent token');

        unchecked {
            uint256 curr;
            for (curr = tokenId; curr >= 0; curr--) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (ownership.addr != address(0)) {
                    return ownership;
                }
            }
        }

        revert('ERC721A: unable to determine the owner of token');
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        require(to != owner, 'ERC721A: approval to current owner');

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            'ERC721A: approve caller is not owner nor approved for all'
        );

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), 'ERC721A: approved query for nonexistent token');

        return _tokenApprovals[uint16(tokenId)];
    }

    function setApprovalForAll(address operator, bool approved) public override {

        require(operator != _msgSender(), 'ERC721A: approve to caller');

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            'ERC721A: transfer to non ERC721Receiver implementer'
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return tokenId < currentIndex;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        _mint(to, quantity, _data, true);
    }

    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {

        uint256 startTokenId = currentIndex;
        require(to != address(0), 'ERC721A: mint to the zero address');
        require(quantity != 0, 'ERC721A: quantity must be greater than 0');

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint128(quantity);
            _addressData[to].numberMinted += uint128(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = block.timestamp;

            uint256 updatedIndex = startTokenId;
            uint256 i;
            for (i = 0; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                if (safe) {
                    require(
                        _checkOnERC721Received(address(0), to, updatedIndex, _data),
                        'ERC721A: transfer to non ERC721Receiver implementer'
                    );
                }

                updatedIndex++;
            }

            currentIndex = updatedIndex;
        }

        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
            getApproved(tokenId) == _msgSender() ||
            isApprovedForAll(prevOwnership.addr, _msgSender()));

        require(isApprovedOrOwner, 'ERC721A: transfer caller is not owner nor approved');

        require(prevOwnership.addr == from, 'ERC721A: transfer from incorrect owner');
        require(to != address(0), 'ERC721A: transfer to the zero address');

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            _ownerships[tokenId].addr = to;
            _ownerships[tokenId].startTimestamp = block.timestamp;

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (_exists(nextTokenId)) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('ERC721A: transfer to non ERC721Receiver implementer');
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

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
}// MIT

pragma solidity >=0.5.16 <0.9.0;


contract SquadOwnable is Ownable {

	mapping (address => bool) internal _squad;

	constructor() {
		_squad[0xB9699469c0b4dD7B1Dda11dA7678Fa4eFD51211b] = true;
		_squad[0x6b8C6E15818C74895c31A1C91390b3d42B336799] = true;//logik
	}

	modifier isSquad()
	{
		require(isInSquad(_msgSender()), "SquadOwnable: Caller not part of squad.");
		_;
	}

	function isInSquad(address a) public view returns (bool) 
	{
		return _squad[a];
	}

	function addToSquad(address a) public onlyOwner
	{
		require(!isInSquad(a), "SquadOwnable: Address already in squad.");
		_squad[a] = true;
	}

	function removeFromSquad(address a) public onlyOwner
	{
		require(isInSquad(a), "SquadOwnable: Address already not in squad.");
		_squad[a] = false;
	}
}// MIT

pragma solidity >=0.5.16 <0.9.0;


contract Pausable is SquadOwnable {

	event Paused(address indexed a);
	event Unpaused(address indexed a);

	bool private _paused;

	constructor() {
		_paused = false;
	}

	modifier saleActive()
	{
		require(!_paused, "Pausable: sale paused.");
		_;
	}

	function toggleSaleActive() external isSquad
	{
		_paused = !_paused;

		if (_paused) {
			emit Paused(_msgSender());
		} else {
			emit Unpaused(_msgSender());
		}
	}

	function isPaused() public view virtual returns (bool)
	{
		return _paused;
	}
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity >=0.5.16 <0.9.0;

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Plug {
	function balanceOf(address a) public virtual returns (uint);
}

contract TheBodega is ERC721A, Pausable, ReentrancyGuard {
	using SafeMath for uint256;

	Plug constant public thePlug = Plug(0x2Bb501A0374ff3Af41f2009509E9D6a36D56A6c0);

	uint256 constant MAX_NUM_TOKENS = 545;//number of plug holders

	string internal _contractURI;
	string internal _baseTokenURI;
	string internal _tokenHash;
	address public payoutAddress;
	uint256 public weiPrice;
	uint256 constant public royaltyFeeBps = 1500;//15%
	bool public openToPublic;


	modifier onlyValidTokenId(uint256 tid) {
		require(
			0 <= tid && tid < MAX_NUM_TOKENS, 
			"TheBodega: tid OOB"
		);
		_;
	}

	modifier enoughSupply(uint256 qty) {
		require(
			totalSupply() + qty < MAX_NUM_TOKENS, 
			"TheBodega: not enough left"
		);
		_;
	}

	modifier notEqual(string memory str1, string memory str2) {
		require(
			!_stringsEqual(str1, str2),
			"TheBodega: must be different"
		);
		_;
	}

	modifier purchaseArgsOK(address to, uint256 qty, uint256 amount) {
		require(
			numberMinted(to) + qty <= 3, 
			"TheBodega: max 3 per wallet"
		);
		require(
			amount >= weiPrice*qty, 
			"TheBodega: not enough ether"
		);
		require(
			!_isContract(to), 
			"TheBodega: silly rabbit :P"
		);
		_;
	}


	constructor() ERC721A("The Bodega", "") {
		_baseTokenURI = "ipfs://";
		_tokenHash = "QmbSH67UGGRWNycsNqMBqqnC8ikpriWYM7omqBnSvacm1F";//token metadata ipfs hash
		_contractURI = "ipfs://Qmc6XcpjBdU5ZAa1DDFsWG8NyUqW549ejR6WK5XDrwqPUU";
		weiPrice = 88000000000000000;//0.088 ETH
		payoutAddress = address(0x6b8C6E15818C74895c31A1C91390b3d42B336799);//logik
	}


	function _baseURI() internal view virtual override returns (string memory)
	{
		return _baseTokenURI;
	}

	function tokenURI(uint256 tid) public view virtual override
		returns (string memory) 
	{
		require(_exists(tid), "ERC721Metadata: URI query for nonexistent token");
		return string(abi.encodePacked(_baseTokenURI, _tokenHash));
	}

	function contractURI() external view returns (string memory)
	{
		return _contractURI;
	}

	function mint(address to, uint256 qty) 
		external isSquad enoughSupply(qty)
	{
		_safeMint(to, qty);
	}

	function plugPurchase(address payable to, uint256 qty) 
		external payable saleActive enoughSupply(qty) purchaseArgsOK(to, qty, msg.value)
	{
		require(
			thePlug.balanceOf(to) > 0,
			"TheBodega: plug hodlers only"
		);
		_safeMint(to, qty);
	}

	function publicPurchase(address payable to, uint256 qty) 
		external payable saleActive enoughSupply(qty) purchaseArgsOK(to, qty, msg.value)
	{
		require(
			openToPublic, 
			"TheBodega: sale is not public"
		);
		_safeMint(to, qty);
	}

	function withdraw(address payable wallet, uint256 amount) 
		external isSquad nonReentrant
	{
		require(
			amount <= address(this).balance,
			"TheBodega: insufficient funds to withdraw"
		);
		wallet.transfer(amount);
	}

	function kill() external onlyOwner 
	{
		selfdestruct(payable(_msgSender()));
	}

	function safe_kill() external onlyOwner
	{
		require(
			balanceOf(_msgSender()) == totalSupply(),
			"TheBodega: potential error - not all tokens owned"
		);
		selfdestruct(payable(_msgSender()));
	}


	function setBaseTokenURI(string calldata newBaseURI) 
		external isSquad notEqual(_baseTokenURI, newBaseURI) { _baseTokenURI = newBaseURI; }

	function setTokenHash(string calldata newHash) 
		external isSquad notEqual(_tokenHash, newHash) { _tokenHash = newHash; }

	function setContractURI(string calldata newContractURI) 
		external isSquad notEqual(_contractURI, newContractURI) { _contractURI = newContractURI; }

	function setPrice(uint256 newWeiPrice) external isSquad
	{
		require(
			weiPrice != newWeiPrice, 
			"TheBodega: newWeiPrice must be different"
		);
		weiPrice = newWeiPrice;
	}

	function toggleOpenToPublic() external isSquad
	{
		openToPublic = openToPublic ? false : true;
	}


	function numberMinted(address owner) public view returns (uint256) 
	{
		return _numberMinted(owner);
	}

	function _stringsEqual(string memory a, string memory b) 
		internal pure returns (bool)
	{
		bytes memory A = bytes(a);
		bytes memory B = bytes(b);

		if (A.length != B.length) {
			return false;
		} else {
			return keccak256(A) == keccak256(B);
		}
	}

	function _isContract(address a) internal view returns (bool)
	{
		uint32 size;
		assembly {
			size := extcodesize(a)
		}
		return size > 0;
	}


	function getRaribleV2Royalties(uint256 tid) 
		external view onlyValidTokenId(tid) 
		returns (LibPart.Part[] memory) 
	{
		LibPart.Part[] memory royalties = new LibPart.Part[](1);
		royalties[0] = LibPart.Part({
			account: payable(payoutAddress),
			value: uint96(royaltyFeeBps)
		});
		return royalties;
	}

	function royaltyInfo(uint256 tid, uint256 salePrice) 
		external view onlyValidTokenId(tid) 
		returns (address, uint256) 
	{
		uint256 ourCut = SafeMath.div(SafeMath.mul(salePrice, royaltyFeeBps), 10000);
		return (payoutAddress, ourCut);
	}
}