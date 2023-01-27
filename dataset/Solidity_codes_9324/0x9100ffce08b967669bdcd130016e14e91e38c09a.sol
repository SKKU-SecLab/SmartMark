


pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.7.0;


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


pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


pragma solidity ^0.7.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}


pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}


pragma solidity ^0.7.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}


pragma solidity ^0.7.0;

library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}


pragma solidity ^0.7.0;

library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


pragma solidity ^0.7.0;












contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}


pragma solidity 0.7.5;


contract GFarmNFT is ERC721{

	uint16[8] supply = [0, 0, 0, 0, 0, 0, 0, 0];
	mapping(uint => uint16) idToLeverage;
	address immutable public owner;

	constructor() ERC721("GFarmNFT", "GFARMNFT"){
		owner = msg.sender;
	}

	modifier correctLeverage(uint16 _leverage){
		require(_leverage >= 75 && _leverage <= 250 && _leverage % 25 == 0, "Wrong leverage value");
		_;
	}
	function leverageID(uint16 _leverage) public pure correctLeverage(_leverage) returns(uint16){
		return (_leverage-50)/25-1;
	}
	function requiredCreditsArray() public pure returns(uint24[8] memory){
		return [12800, 32000, 44800, 64000, 76800, 96000, 108800, 192000];
	}
	function maxSupplyArray() public pure returns(uint16[8] memory){
		return [1000, 500, 400, 300, 200, 150, 100, 50];
	}
	function requiredCredits(uint16 _leverage) public pure returns(uint24){
		return requiredCreditsArray()[leverageID(_leverage)];
	}
	function maxSupply(uint16 _leverage) public pure returns(uint16){
		return maxSupplyArray()[leverageID(_leverage)];
	}
	function currentSupply(uint16 _leverage) public view returns(uint16){
		return supply[leverageID(_leverage)];
	}

	function mint(uint16 _leverage, uint _userCredits, address _userAddress) external{
		require(msg.sender == owner, "Caller must be the GFarm smart contract.");
		require(_userCredits >= requiredCredits(_leverage), "Not enough NFT credits");
		require(currentSupply(_leverage) < maxSupply(_leverage), "Max supply reached for this leverage");

		uint nftID = totalSupply();
		_mint(_userAddress, nftID);

		idToLeverage[nftID] = _leverage;
		supply[leverageID(_leverage)] += 1;
	}

	function getLeverageFromID(uint id) external view returns(uint16){
		return idToLeverage[id];
	}
	function currentSupplyArray() external view returns(uint16[8] memory){
		return supply;
	}
}


pragma solidity 0.7.5;

interface GFarmTokenInterface{
	function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function burn(address from, uint256 amount) external;
    function mint(address to, uint256 amount) external;
}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


pragma solidity 0.7.5;





contract GFarm {

	using SafeMath for uint;

	GFarmTokenInterface public immutable token;
	GFarmNFT public immutable nft;
	IUniswapV2Pair public immutable lp;


	uint constant POOL1_MULTIPLIER_1 = 10;
	uint constant POOL1_MULTIPLIER_2 = 5;
	uint constant POOL1_MULTIPLIER_1_DURATION = 100000; // 2 weeks
	uint constant POOL1_MULTIPLIER_2_DURATION = 200000; // 4 weeks
	uint immutable POOL1_MULTIPLIER_1_END;
	uint immutable POOL1_MULTIPLIER_2_END;
	uint constant POOL1_REFERRAL_P = 5;
	uint constant POOL1_CREDITS_MIN_P = 1;

	uint public POOL1_lastRewardBlock;
	uint public POOL1_accTokensPerLP; // divide by 1e18 for real value


	uint public constant POOL2_DURATION = 100000; // 2 weeks
	uint public immutable POOL2_END;

	uint public POOL2_lastRewardBlock;
	uint public POOL2_accTokensPerETH; // divide by 1e18 for real value

	uint public immutable POOLS_START;
	uint public constant POOLS_TOKENS_PER_BLOCK = 1; // 1 token per block
	uint public constant POOLS_START_DELAY = 51000; // 8 days => 27th of december

	address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	IUniswapV2Pair constant ETH_USDC_PAIR = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);

    address immutable DEV_FUND;
    uint constant DEV_FUND_PERCENTAGE = 10;

	struct User {
        uint POOL1_provided;
        uint POOL1_rewardDebt;
        address POOL1_referral;
        uint POOL1_referralReward;

        uint POOL2_provided;
        uint POOL2_rewardDebt;

        uint NFT_CREDITS_amount;
        uint NFT_CREDITS_lastUpdated;
        bool NFT_CREDITS_receiving;
    }
    mapping(address => User) public users;


	constructor(
		GFarmTokenInterface _token,
        IUniswapV2Pair _lp){

		token = _token;
        lp = _lp;
		DEV_FUND = msg.sender;

		POOL1_MULTIPLIER_1_END = block.number.add(POOLS_START_DELAY).add(POOL1_MULTIPLIER_1_DURATION);
		POOL1_MULTIPLIER_2_END = block.number.add(POOLS_START_DELAY).add(POOL1_MULTIPLIER_1_DURATION).add(POOL1_MULTIPLIER_2_DURATION);
		POOL2_END = block.number.add(POOLS_START_DELAY).add(POOL2_DURATION);
		POOLS_START = block.number.add(POOLS_START_DELAY);

		nft = new GFarmNFT();

	}


    function POOL1_getReward(uint _from, uint _to) private view returns (uint){
    	uint blocksWithMultiplier;

        if(_from >= POOLS_START && _to >= POOLS_START){
        	if(_from <= POOL1_MULTIPLIER_1_END && _to <= POOL1_MULTIPLIER_1_END){
        		blocksWithMultiplier = _to.sub(_from).mul(POOL1_MULTIPLIER_1);
        	} else if(_from <= POOL1_MULTIPLIER_1_END && _to > POOL1_MULTIPLIER_1_END && _to <= POOL1_MULTIPLIER_2_END){
        		blocksWithMultiplier = POOL1_MULTIPLIER_1_END.sub(_from).mul(POOL1_MULTIPLIER_1).add(
        			_to.sub(POOL1_MULTIPLIER_1_END).mul(POOL1_MULTIPLIER_2)
        		);
        	} else if(_from <= POOL1_MULTIPLIER_1_END && _to > POOL1_MULTIPLIER_2_END){
        		blocksWithMultiplier = POOL1_MULTIPLIER_1_END.sub(_from).mul(POOL1_MULTIPLIER_1).add(
        			POOL1_MULTIPLIER_2_END.sub(POOL1_MULTIPLIER_1_END).mul(POOL1_MULTIPLIER_2).add(
        				_to.sub(POOL1_MULTIPLIER_2_END)
        			)
        		);
        	}else if(_from > POOL1_MULTIPLIER_1_END && _from <= POOL1_MULTIPLIER_2_END && _to <= POOL1_MULTIPLIER_2_END){
        		blocksWithMultiplier = _to.sub(_from).mul(POOL1_MULTIPLIER_2);
        	} else if(_from > POOL1_MULTIPLIER_1_END && _from <= POOL1_MULTIPLIER_2_END && _to > POOL1_MULTIPLIER_2_END){
        		blocksWithMultiplier = POOL1_MULTIPLIER_2_END.sub(_from).mul(POOL1_MULTIPLIER_2).add(
        			_to.sub(POOL1_MULTIPLIER_2_END)
        		);
        	}else{
        		blocksWithMultiplier = _to.sub(_from);
        	}
        }

    	return blocksWithMultiplier.mul(POOLS_TOKENS_PER_BLOCK).mul(1e18);
    }
    function POOL2_getReward(uint _from, uint _to) private view returns (uint){
    	uint blocksWithMultiplier;

        if(_from >= POOLS_START && _to >= POOLS_START){
        	if(_from <= POOL2_END && _to <= POOL2_END){
        		blocksWithMultiplier = _to.sub(_from);
        	}else if(_from <= POOL2_END && _to > POOL2_END){
        		blocksWithMultiplier = POOL2_END.sub(_from);
        	}else if(_from > POOL2_END && _to > POOL2_END){
        		blocksWithMultiplier = 0;
        	}
        }

    	return blocksWithMultiplier.mul(POOLS_TOKENS_PER_BLOCK).mul(1e18);
    }

	function POOL1_update() private {
		uint lpSupply = lp.balanceOf(address(this));

        if (POOL1_lastRewardBlock == 0 || lpSupply == 0) {
            POOL1_lastRewardBlock = block.number;
            return;
        }

		uint reward = POOL1_getReward(POOL1_lastRewardBlock, block.number);
        
    	token.mint(address(this), reward);
    	token.mint(DEV_FUND, reward.mul(DEV_FUND_PERCENTAGE).div(100));

    	POOL1_accTokensPerLP = POOL1_accTokensPerLP.add(reward.mul(1e18).div(lpSupply));
        POOL1_lastRewardBlock = block.number;
	}	
	function POOL2_update(uint ethJustStaked) private {
		uint ethSupply = address(this).balance.sub(ethJustStaked);

		if (POOL2_lastRewardBlock == 0 || ethSupply == 0) {
            POOL2_lastRewardBlock = block.number;
            return;
        }

		uint reward = POOL2_getReward(POOL2_lastRewardBlock, block.number);
        
    	token.mint(address(this), reward);
    	token.mint(DEV_FUND, reward.mul(DEV_FUND_PERCENTAGE).div(100));

    	POOL2_accTokensPerETH = POOL2_accTokensPerETH.add(reward.mul(1e18).div(ethSupply));
        POOL2_lastRewardBlock = block.number;
	}

	function POOL1_pendingReward() external view returns(uint){
		return _POOL1_pendingReward(users[msg.sender]);
	}
	function POOL2_pendingReward() external view returns(uint){
		return _POOL2_pendingReward(users[msg.sender], 0);
	}
	function _POOL1_pendingReward(User memory u) private view returns(uint){
		uint _POOL1_accTokensPerLP = POOL1_accTokensPerLP;
		uint lpSupply = lp.balanceOf(address(this));

		if (block.number > POOL1_lastRewardBlock && lpSupply != 0) {
			uint pendingReward = POOL1_getReward(POOL1_lastRewardBlock, block.number);
            _POOL1_accTokensPerLP = _POOL1_accTokensPerLP.add(pendingReward.mul(1e18).div(lpSupply));
        }

		return u.POOL1_provided.mul(_POOL1_accTokensPerLP).div(1e18).sub(u.POOL1_rewardDebt);
	}
	function _POOL2_pendingReward(User memory u, uint ethJustStaked) private view returns(uint){
		uint _POOL2_accTokensPerETH = POOL2_accTokensPerETH;
		uint ethSupply = address(this).balance.sub(ethJustStaked);

		if (block.number > POOL2_lastRewardBlock && ethSupply != 0) {
            uint pendingReward = POOL2_getReward(POOL2_lastRewardBlock, block.number);
            _POOL2_accTokensPerETH = _POOL2_accTokensPerETH.add(pendingReward.mul(1e18).div(ethSupply));
        }

		return u.POOL2_provided.mul(_POOL2_accTokensPerETH).div(1e18).sub(u.POOL2_rewardDebt);
	}

	function POOL1_harvest() external{
		_POOL1_harvest(msg.sender);
	}
	function POOL2_harvest() external{
		_POOL2_harvest(msg.sender, 0);
	}
	function _POOL1_harvest(address a) private{
		User storage u = users[a];
		uint pending = _POOL1_pendingReward(u);
		POOL1_update();

		if(pending > 0){
			if(u.POOL1_referral == address(0)){
				POOLS_safeTokenTransfer(a, pending);
				token.burn(a, pending.mul(POOL1_REFERRAL_P).div(100));
			}else{
				uint referralReward = pending.mul(POOL1_REFERRAL_P).div(100);
				uint userReward = pending.sub(referralReward);

				POOLS_safeTokenTransfer(a, userReward);
				POOLS_safeTokenTransfer(u.POOL1_referral, referralReward);

				User storage referralUser = users[u.POOL1_referral];
				referralUser.POOL1_referralReward = referralUser.POOL1_referralReward.add(referralReward);
			}
		}

		u.POOL1_rewardDebt = u.POOL1_provided.mul(POOL1_accTokensPerLP).div(1e18);
	}
	function _POOL2_harvest(address a, uint ethJustStaked) private{
		User storage u = users[a];
		uint pending = _POOL2_pendingReward(u, ethJustStaked);
		POOL2_update(ethJustStaked);

		if(pending > 0){
			POOLS_safeTokenTransfer(a, pending);
		}

		u.POOL2_rewardDebt = u.POOL2_provided.mul(POOL2_accTokensPerETH).div(1e18);
	}

	function POOL1_stake(uint amount, address referral) external{
		require(block.number >= POOLS_START, "Pool hasn't started yet.");
		require(amount > 0, "Staking 0 lp.");

        uint lpSupplyBefore = lp.balanceOf(address(this));

		_POOL1_harvest(msg.sender);
		lp.transferFrom(msg.sender, address(this), amount);

		User storage u = users[msg.sender];
		u.POOL1_provided = u.POOL1_provided.add(amount);
		u.POOL1_rewardDebt = u.POOL1_provided.mul(POOL1_accTokensPerLP).div(1e18);

		if(!u.NFT_CREDITS_receiving && u.POOL1_provided >= lpSupplyBefore.mul(POOL1_CREDITS_MIN_P).div(100)){
			u.NFT_CREDITS_receiving = true;
			u.NFT_CREDITS_lastUpdated = block.number;
		}

		if(u.POOL1_referral == address(0) && referral != address(0) && referral != msg.sender){
			u.POOL1_referral = referral;
		}
	}
	function POOL2_stake() payable external{
		require(block.number >= POOLS_START, "Pool hasn't started yet.");
		require(block.number <= POOL2_END, "Pool is finished, no more staking.");
		require(msg.value > 0, "Staking 0 ETH.");

		_POOL2_harvest(msg.sender, msg.value);

		User storage u = users[msg.sender];
		u.POOL2_provided = u.POOL2_provided.add(msg.value);
		u.POOL2_rewardDebt = u.POOL2_provided.mul(POOL2_accTokensPerETH).div(1e18);
	}

	function POOL1_unstake(uint amount) external{
		User storage u = users[msg.sender];
		require(amount > 0, "Unstaking 0 lp.");
		require(u.POOL1_provided >= amount, "Unstaking more than currently staked.");

		_POOL1_harvest(msg.sender);
		lp.transfer(msg.sender, amount);

		u.POOL1_provided = u.POOL1_provided.sub(amount);
		u.POOL1_rewardDebt = u.POOL1_provided.mul(POOL1_accTokensPerLP).div(1e18);

		uint lpSupply = lp.balanceOf(address(this));

		if(u.NFT_CREDITS_receiving && u.POOL1_provided < lpSupply.mul(POOL1_CREDITS_MIN_P).div(100) || u.NFT_CREDITS_receiving && lpSupply == 0){
			u.NFT_CREDITS_amount = NFT_CREDITS_amount();
			u.NFT_CREDITS_receiving = false;
			u.NFT_CREDITS_lastUpdated = block.number;
		}
	}
	function POOL2_unstake(uint amount) external{
		User storage u = users[msg.sender];
		require(amount > 0, "Unstaking 0 ETH.");
		require(u.POOL2_provided >= amount, "Unstaking more than currently staked.");

		_POOL2_harvest(msg.sender, 0);
		msg.sender.transfer(amount);

		u.POOL2_provided = u.POOL2_provided.sub(amount);
		u.POOL2_rewardDebt = u.POOL2_provided.mul(POOL2_accTokensPerETH).div(1e18);
	}

	function NFT_claim(uint16 _leverage) external{
		User storage u = users[msg.sender];
		nft.mint(_leverage, NFT_CREDITS_amount(), msg.sender);
		uint requiredCredits = nft.requiredCredits(_leverage);
		u.NFT_CREDITS_amount = NFT_CREDITS_amount().sub(requiredCredits);
		u.NFT_CREDITS_lastUpdated = block.number;
	}
	function NFT_CREDITS_amount() public view returns(uint){
    	User memory u = users[msg.sender];
    	if(u.NFT_CREDITS_receiving){
    		return u.NFT_CREDITS_amount.add(block.number.sub(u.NFT_CREDITS_lastUpdated));
    	}else{
    		return u.NFT_CREDITS_amount;
    	}
    }

	function POOLS_safeTokenTransfer(address _to, uint _amount) private {
        uint bal = token.balanceOf(address(this));
        if (_amount > bal) {
            token.transfer(_to, bal);
        } else {
            token.transfer(_to, _amount);
        }
    }


    function getEthPrice() private view returns(uint){
        (uint112 reserves0, uint112 reserves1, ) = ETH_USDC_PAIR.getReserves();
        uint reserveUSDC;
        uint reserveETH;

        if(WETH == ETH_USDC_PAIR.token0()){
            reserveETH = reserves0;
            reserveUSDC = reserves1;
        }else{
            reserveUSDC = reserves0;
            reserveETH = reserves1;
        }
        return reserveUSDC.mul(1e12).mul(1e5).div(reserveETH);
    }
    function getGFarmPriceEth() private view returns(uint){
        (uint112 reserves0, uint112 reserves1, ) = lp.getReserves();

        uint reserveETH;
        uint reserveGFARM;

        if(WETH == lp.token0()){
            reserveETH = reserves0;
            reserveGFARM = reserves1;
        }else{
            reserveGFARM = reserves0;
            reserveETH = reserves1;
        }

        return reserveETH.mul(1e5).div(reserveGFARM);
    }

    
    function POOLS_blocksLeftUntilStart() external view returns(uint){
    	if(block.number > POOLS_START){ return 0; }
    	return POOLS_START.sub(block.number);
    }
	function POOL1_getMultiplier() public view returns (uint) {
		if(block.number < POOLS_START){
			return 0;
		}
        if(block.number <= POOL1_MULTIPLIER_1_END){
        	return POOL1_MULTIPLIER_1;
        }else if(block.number <= POOL1_MULTIPLIER_2_END){
        	return POOL1_MULTIPLIER_2;
        }
        return 1;
    }
	function POOL2_getMultiplier() public view returns (uint) {
		if(block.number < POOLS_START || block.number > POOL2_END){
			return 0;
		}
        return 1;
    }
    function POOL1_rewardPerBlock() external view returns(uint){
    	return POOL1_getMultiplier().mul(POOLS_TOKENS_PER_BLOCK).mul(1e18);
    }
    function POOL2_rewardPerBlock() external view returns(uint){
    	return POOL2_getMultiplier().mul(POOLS_TOKENS_PER_BLOCK).mul(1e18);
    }
    function POOL1_provided() external view returns(uint){
    	return users[msg.sender].POOL1_provided;
    }
    function POOL2_provided() external view returns(uint){
    	return users[msg.sender].POOL2_provided;
    }
    function POOL1_referralReward() external view returns(uint){
    	return users[msg.sender].POOL1_referralReward;
    }
    function POOL2_blocksLeft() external view returns(uint){
    	if(block.number > POOL2_END){
    		return 0;
    	}
    	return POOL2_END.sub(block.number);
    }
    function POOL1_referral() external view returns(address){
        return users[msg.sender].POOL1_referral;
    }
    function POOL1_minLpsNftCredits() external view returns(uint){
    	return lp.balanceOf(address(this)).mul(POOL1_CREDITS_MIN_P).div(100);
    }
    function POOL1_tvl() public view returns(uint){
    	if(lp.totalSupply() == 0){ return 0; }

    	(uint112 reserves0, uint112 reserves1, ) = lp.getReserves();
    	uint reserveEth;

    	if(WETH == lp.token0()){
    		reserveEth = reserves0;
    	}else{
			reserveEth = reserves1;
    	}

    	uint lpPriceEth = reserveEth.mul(1e5).mul(2).div(lp.totalSupply());
    	uint lpPriceUsd = lpPriceEth.mul(getEthPrice()).div(1e5);

    	return lp.balanceOf(address(this)).mul(lpPriceUsd).div(1e18);
    }
    function POOL2_tvl() public view returns(uint){
    	return address(this).balance.mul(getEthPrice()).div(1e18);
    }
    function POOLS_tvl() external view returns(uint){
    	return POOL1_tvl().add(POOL2_tvl());
    }
    function POOL1_apy() external view returns(uint){
    	if(POOL1_tvl() == 0){ return 0; }
    	return POOLS_TOKENS_PER_BLOCK.mul(POOL1_getMultiplier()).mul(2336000).mul(getGFarmPriceEth()).mul(getEthPrice()).mul(100).div(POOL1_tvl());
    }
    function POOL2_apy() external view returns(uint){
    	if(POOL2_tvl() == 0){ return 0; }
    	return POOLS_TOKENS_PER_BLOCK.mul(POOL2_getMultiplier()).mul(2336000).mul(getGFarmPriceEth()).mul(getEthPrice()).mul(100).div(POOL2_tvl());
    }
    function NFT_owned() external view returns(uint[8] memory nfts){
    	for(uint i = 0; i < nft.balanceOf(msg.sender); i++){
            uint id = nft.leverageID(nft.getLeverageFromID(nft.tokenOfOwnerByIndex(msg.sender, i)));
            nfts[id] = nfts[id].add(1);
        }
    }
    function NFT_requiredCreditsArray() external view returns(uint24[8] memory){
    	return nft.requiredCreditsArray();
    }
	function NFT_maxSupplyArray() external view returns(uint16[8] memory){
		return nft.maxSupplyArray();
	}
	function NFT_currentSupplyArray() external view returns(uint16[8] memory){
		return nft.currentSupplyArray();
	}
}