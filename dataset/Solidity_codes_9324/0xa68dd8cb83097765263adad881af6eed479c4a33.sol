pragma solidity ^0.8.11;


interface PriceOracle {

	function getPrice() external view returns (uint256);

}


contract Metadata {

	
	string public name = "fees.wtf NFT";
	string public symbol = "fees.wtf";

	string constant private TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

	WTFNFT public nft;
	PriceOracle public oracle;

	constructor(WTFNFT _nft) {
		nft = _nft;
		oracle = PriceOracle(0xe89b5B2770Aa1a6BcfAc6F3517510aB8e9146651);
	}

	function setPriceOracle(PriceOracle _oracle) external {

		require(msg.sender == nft.owner());
		oracle = _oracle;
	}


	function tokenURI(uint256 _tokenId) external view returns (string memory) {

		( , , address _user, uint256[7] memory _info) = nft.getToken(_tokenId);
		return rawTokenURI(_user, _info[0], _info[1], _info[2], _info[3], _info[4], _info[5], _info[6], oracle.getPrice());
	}

	function rawTokenURI(address _user, uint256 _totalFees, uint256 _failFees, uint256 _totalGas, uint256 _avgGwei, uint256 _totalDonated, uint256 _totalTxs, uint256 _failTxs, uint256 _price) public pure returns (string memory) {

		string memory _json = string(abi.encodePacked('{"name":"', _trimAddress(_user, 6), '","description":"[fees.wtf](https://fees.wtf) snapshot at block 13916450 for [', _address2str(_user), '](https://etherscan.io/address/', _address2str(_user), ')",'));
		_json = string(abi.encodePacked(_json, '"image":"data:image/svg+xml;base64,', _encode(bytes(getRawSVG(_totalFees, _failFees, _totalGas, _avgGwei, _totalDonated, _totalTxs, _failTxs, _price))), '","attributes":['));
		if (_totalFees > 0) {
			_json = string(abi.encodePacked(_json, '{"trait_type":"Total Fees","value":', _uint2str(_totalFees, 18, 5, false, true), '}'));
			_json = string(abi.encodePacked(_json, ',{"trait_type":"Fail Fees","value":', _uint2str(_failFees, 18, 5, false, true), '}'));
			_json = string(abi.encodePacked(_json, ',{"trait_type":"Total Gas","value":', _uint2str(_totalGas, 0, 0, false, false), '}'));
			_json = string(abi.encodePacked(_json, ',{"trait_type":"Average Gwei","value":', _uint2str(_avgGwei, 9, 5, false, true), '}'));
			_json = string(abi.encodePacked(_json, ',{"trait_type":"Total Transactions","value":', _uint2str(_totalTxs, 0, 0, false, false), '}'));
			_json = string(abi.encodePacked(_json, ',{"trait_type":"Failed Transactions","value":', _uint2str(_failTxs, 0, 0, false, false), '}'));
			_json = string(abi.encodePacked(_json, ',{"display_type":"number","trait_type":"Spender Level","value":', _uint2str(_logn(_totalFees / 1e13, 2), 0, 0, false, false), '}'));
			_json = string(abi.encodePacked(_json, ',{"display_type":"number","trait_type":"Oof Level","value":', _uint2str(_logn(_failFees / 1e13, 2), 0, 0, false, false), '}'));
		}
		if (_totalDonated > 0) {
			_json = string(abi.encodePacked(_json, _totalFees > 0 ? ',' : '', '{"display_type":"number","trait_type":"Donator Level","value":', _uint2str(_logn(_totalDonated / 1e14, 10) + 1, 0, 0, false, false), '}'));
		}
		_json = string(abi.encodePacked(_json, ']}'));
		return string(abi.encodePacked("data:application/json;base64,", _encode(bytes(_json))));
	}

	function getSVG(uint256 _tokenId) public view returns (string memory) {

		uint256[7] memory _info = nft.getTokenCompressedInfo(_tokenId);
		return getRawSVG(_info[0], _info[1], _info[2], _info[3], _info[4], _info[5], _info[6], oracle.getPrice());
	}

	function getRawSVG(uint256 _totalFees, uint256 _failFees, uint256 _totalGas, uint256 _avgGwei, uint256 _totalDonated, uint256 _totalTxs, uint256 _failTxs, uint256 _price) public pure returns (string memory svg) {

		svg = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' preserveAspectRatio='xMidYMid meet' viewBox='0 0 512 512' width='100%' height='100%'>"));
		svg = string(abi.encodePacked(svg, "<defs><style type='text/css'>text{text-anchor:middle;alignment-baseline:central;}tspan>tspan{fill:#03a9f4;font-weight:700;}</style></defs>"));
		svg = string(abi.encodePacked(svg, "<rect width='100%' height='100%' fill='#222222' />"));
		svg = string(abi.encodePacked(svg, "<text x='0' y='256' transform='translate(256)' fill='#f0f8ff' font-family='Arial,sans-serif' font-weight='600' font-size='30'>"));
		if (_totalFees > 0) {
			svg = string(abi.encodePacked(svg, unicode"<tspan x='0' dy='-183'>You spent <tspan>Ξ", _uint2str(_totalFees, 18, 5, true, false), "</tspan> on gas</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'>before block 13916450.</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'>Right now, that's</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'><tspan>$", _uint2str(_totalFees * _price / 1e18, 18, 2, true, true), "</tspan>.</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='70'>You used <tspan>", _uint2str(_totalGas, 0, 0, true, false), "</tspan></tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'>gas to send <tspan>", _uint2str(_totalTxs, 0, 0, true, false), "</tspan></tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'>transaction", _totalTxs == 1 ? "" : "s", ", with an average</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'>price of <tspan>", _uint2str(_avgGwei, 9, 3, true, false), "</tspan> Gwei.</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='70'><tspan>", _uint2str(_failTxs, 0, 0, true, false), "</tspan> of them failed,</tspan>"));
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='35'>costing you <tspan>", _failFees == 0 ? "nothing" : string(abi.encodePacked(unicode"Ξ", _uint2str(_failFees, 18, 5, true, false))), "</tspan>.</tspan></text>"));
		} else {
			svg = string(abi.encodePacked(svg, "<tspan x='0' dy='8'>Did not qualify.</tspan></text>"));
		}
		if (_totalDonated > 0) {
			for (uint256 i = 0; i <= _logn(_totalDonated / 1e14, 10); i++) {
				for (uint256 j = 0; j < 4; j++) {
					string memory _prefix = string(abi.encodePacked("<text x='", j < 2 ? "16" : "496", "' y='", j % 2 == 0 ? "18" : "498", "' font-size='10' transform='translate("));
					svg = string(abi.encodePacked(svg, _prefix, j < 2 ? "" : "-", _uint2str(16 * i, 0, 0, false, false), ")'>", unicode"❤️</text>"));
					if (i > 0) {
						svg = string(abi.encodePacked(svg, _prefix, "0,", j % 2 == 0 ? "" : "-", _uint2str(16 * i, 0, 0, false, false), ")'>", unicode"❤️</text>"));
					}
				}
			}
		}
		svg = string(abi.encodePacked(svg, "<text x='0' y='500' transform='translate(256)' fill='#f0f8ff' font-family='Arial,sans-serif' font-weight='600' font-size='10'><tspan>fees<tspan>.wtf</tspan></tspan></text></svg>"));
	}


	function _logn(uint256 _num, uint256 _n) internal pure returns (uint256) {

		require(_n > 0);
		uint256 _count = 0;
		while (_num > _n - 1) {
			_num /= _n;
			_count++;
		}
		return _count;
	}
	
	function _address2str(address _address) internal pure returns (string memory str) {

		str = "0x";
		for (uint256 i; i < 40; i++) {
			uint256 _hex = (uint160(_address) >> (4 * (39 - i))) % 16;
			bytes memory _char = new bytes(1);
			_char[0] = bytes1(uint8(_hex) + (_hex > 9 ? 87 : 48));
			str = string(abi.encodePacked(str, string(_char)));
		}
	}

	function _trimAddress(address _address, uint256 _padding) internal pure returns (string memory str) {

		require(_padding < 20);
		str = "";
		bytes memory _strAddress = bytes(_address2str(_address));
		uint256 _length = 2 * _padding + 2;
		for (uint256 i = 0; i < 2 * _padding + 2; i++) {
			bytes memory _char = new bytes(1);
			_char[0] = _strAddress[i < _padding + 2 ? i : 42 + i - _length];
			str = string(abi.encodePacked(str, string(_char)));
			if (i == _padding + 1) {
				str = string(abi.encodePacked(str, unicode"…"));
			}
		}
	}
	
	function _uint2str(uint256 _value, uint256 _scale, uint256 _maxDecimals, bool _commas, bool _full) internal pure returns (string memory str) {

		uint256 _d = _scale > _maxDecimals ? _maxDecimals : _scale;
		uint256 _n = _value / 10**(_scale > _d ? _scale - _d : 0);
		if (_n == 0) {
			return "0";
		}
		uint256 _digits = 1;
		uint256 _tmp = _n;
		while (_tmp > 9) {
			_tmp /= 10;
			_digits++;
		}
		_tmp = _digits > _d ? _digits : _d + 1;
		uint256 _offset = (!_full && _tmp > _d + 1 ? _tmp - _d - 1 > _d ? _d : _tmp - _d - 1 : 0);
		for (uint256 i = 0; i < _tmp - _offset; i++) {
			uint256 _dec = i < _tmp - _digits ? 0 : (_n / (10**(_tmp - i - 1))) % 10;
			bytes memory _char = new bytes(1);
			_char[0] = bytes1(uint8(_dec) + 48);
			str = string(abi.encodePacked(str, string(_char)));
			if (i < _tmp - _d - 1) {
				if (_commas && (i + 1) % 3 == (_tmp - _d) % 3) {
					str = string(abi.encodePacked(str, ","));
				}
			} else {
				if (!_full && (_n / 10**_offset) % 10**(_tmp - _offset - i - 1) == 0) {
					break;
				} else if (i == _tmp - _d - 1) {
					str = string(abi.encodePacked(str, "."));
				}
			}
		}
	}
	
	function _encode(bytes memory _data) internal pure returns (string memory result) {

		if (_data.length == 0) return '';
		string memory _table = TABLE;
		uint256 _encodedLen = 4 * ((_data.length + 2) / 3);
		result = new string(_encodedLen + 32);

		assembly {
			mstore(result, _encodedLen)
			let tablePtr := add(_table, 1)
			let dataPtr := _data
			let endPtr := add(dataPtr, mload(_data))
			let resultPtr := add(result, 32)

			for {} lt(dataPtr, endPtr) {}
			{
				dataPtr := add(dataPtr, 3)
				let input := mload(dataPtr)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
				resultPtr := add(resultPtr, 1)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
				resultPtr := add(resultPtr, 1)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
				resultPtr := add(resultPtr, 1)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
				resultPtr := add(resultPtr, 1)
			}
			switch mod(mload(_data), 3)
			case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
			case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
		}
		return result;
	}
}// MIT
pragma solidity ^0.8.11;


interface Receiver {

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns (bytes4);

}


contract WTFNFT {


	struct User {
		uint256 balance;
		mapping(uint256 => uint256) list;
		mapping(address => bool) approved;
		mapping(uint256 => uint256) indexOf;
		uint256 tokenIndex;
	}

	struct Token {
		address user;
		address owner;
		address approved;
		uint128 totalFees;
		uint128 failFees;
		uint128 totalGas;
		uint128 avgGwei;
		uint128 totalDonated;
		uint64 totalTxs;
		uint64 failTxs;
	}

	struct Info {
		uint256 totalSupply;
		mapping(uint256 => Token) list;
		mapping(address => User) users;
		Metadata metadata;
		address wtf;
		address owner;
	}
	Info private info;

	mapping(bytes4 => bool) public supportsInterface;

	event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
	event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
	event Mint(address indexed owner, uint256 indexed tokenId, uint256 totalFees, uint256 failFees, uint256 totalGas, uint256 avgGwei, uint256 totalDonated, uint256 totalTxs, uint256 failTxs);


	modifier _onlyOwner() {

		require(msg.sender == owner());
		_;
	}


	constructor() {
		info.metadata = new Metadata(this);
		info.wtf = msg.sender;
		info.owner = 0xdEE79eD62B42e30EA7EbB6f1b7A3f04143D18b7F;
		supportsInterface[0x01ffc9a7] = true; // ERC-165
		supportsInterface[0x80ac58cd] = true; // ERC-721
		supportsInterface[0x5b5e139f] = true; // Metadata
		supportsInterface[0x780e9d63] = true; // Enumerable
	}

	function setOwner(address _owner) external _onlyOwner {

		info.owner = _owner;
	}

	function setMetadata(Metadata _metadata) external _onlyOwner {

		info.metadata = _metadata;
	}

	
	function mint(address _receiver, uint256 _totalFees, uint256 _failFees, uint256 _totalGas, uint256 _avgGwei, uint256 _totalDonated, uint256 _totalTxs, uint256 _failTxs) public {

		require(msg.sender == wtfAddress());
		uint256 _tokenId = info.totalSupply++;
		info.users[_receiver].tokenIndex = totalSupply();
		Token storage _newToken = info.list[_tokenId];
		_newToken.user = _receiver;
		_newToken.owner = _receiver;
		_newToken.totalFees = uint128(_totalFees);
		_newToken.failFees = uint128(_failFees);
		_newToken.totalGas = uint128(_totalGas);
		_newToken.avgGwei = uint128(_avgGwei);
		_newToken.totalDonated = uint128(_totalDonated);
		_newToken.totalTxs = uint64(_totalTxs);
		_newToken.failTxs = uint64(_failTxs);
		uint256 _index = info.users[_receiver].balance++;
		info.users[_receiver].indexOf[_tokenId] = _index + 1;
		info.users[_receiver].list[_index] = _tokenId;
		emit Transfer(address(0x0), _receiver, _tokenId);
		emit Mint(_receiver, _tokenId, _totalFees, _failFees, _totalGas, _avgGwei, _totalDonated, _totalTxs, _failTxs);
	}
	
	function approve(address _approved, uint256 _tokenId) external {

		require(msg.sender == ownerOf(_tokenId));
		info.list[_tokenId].approved = _approved;
		emit Approval(msg.sender, _approved, _tokenId);
	}

	function setApprovalForAll(address _operator, bool _approved) external {

		info.users[msg.sender].approved[_operator] = _approved;
		emit ApprovalForAll(msg.sender, _operator, _approved);
	}

	function transferFrom(address _from, address _to, uint256 _tokenId) external {

		_transfer(_from, _to, _tokenId);
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {

		safeTransferFrom(_from, _to, _tokenId, "");
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public {

		_transfer(_from, _to, _tokenId);
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) == 0x150b7a02);
		}
	}


	function name() external view returns (string memory) {

		return info.metadata.name();
	}

	function symbol() external view returns (string memory) {

		return info.metadata.symbol();
	}

	function tokenURI(uint256 _tokenId) external view returns (string memory) {

		return info.metadata.tokenURI(_tokenId);
	}

	function metadataAddress() public view returns (address) {

		return address(info.metadata);
	}

	function wtfAddress() public view returns (address) {

		return info.wtf;
	}

	function owner() public view returns (address) {

		return info.owner;
	}

	function totalSupply() public view returns (uint256) {

		return info.totalSupply;
	}

	function balanceOf(address _owner) public view returns (uint256) {

		return info.users[_owner].balance;
	}

	function ownerOf(uint256 _tokenId) public view returns (address) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].owner;
	}

	function getUser(uint256 _tokenId) public view returns (address) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].user;
	}

	function getApproved(uint256 _tokenId) public view returns (address) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].approved;
	}

	function getTotalFees(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].totalFees;
	}

	function getFailFees(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].failFees;
	}

	function getTotalGas(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].totalGas;
	}

	function getAvgGwei(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].avgGwei;
	}

	function getTotalDonated(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].totalDonated;
	}

	function getTotalTxs(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].totalTxs;
	}

	function getFailTxs(uint256 _tokenId) public view returns (uint256) {

		require(_tokenId < totalSupply());
		return info.list[_tokenId].failTxs;
	}

	function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

		return info.users[_owner].approved[_operator];
	}

	function tokenIdOf(address _user) public view returns (uint256) {

		uint256 _index = info.users[_user].tokenIndex;
		require(_index > 0);
		return _index - 1;
	}

	function tokenByIndex(uint256 _index) public view returns (uint256) {

		require(_index < totalSupply());
		return _index;
	}

	function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {

		require(_index < balanceOf(_owner));
		return info.users[_owner].list[_index];
	}

	function getTokenCompressedInfo(uint256 _tokenId) public view returns (uint256[7] memory compressedInfo) {

		compressedInfo[0] = getTotalFees(_tokenId);
		compressedInfo[1] = getFailFees(_tokenId);
		compressedInfo[2] = getTotalGas(_tokenId);
		compressedInfo[3] = getAvgGwei(_tokenId);
		compressedInfo[4] = getTotalDonated(_tokenId);
		compressedInfo[5] = getTotalTxs(_tokenId);
		compressedInfo[6] = getFailTxs(_tokenId);
	}

	function getToken(uint256 _tokenId) public view returns (address tokenOwner, address approved, address user, uint256[7] memory compressedInfo) {

		return (ownerOf(_tokenId), getApproved(_tokenId), getUser(_tokenId), getTokenCompressedInfo(_tokenId));
	}

	function getTokens(uint256[] memory _tokenIds) public view returns (address[] memory owners, address[] memory approveds, address[] memory users, uint256[7][] memory compressedInfos) {

		uint256 _length = _tokenIds.length;
		owners = new address[](_length);
		approveds = new address[](_length);
		users = new address[](_length);
		compressedInfos = new uint256[7][](_length);
		for (uint256 i = 0; i < _length; i++) {
			(owners[i], approveds[i], users[i], compressedInfos[i]) = getToken(_tokenIds[i]);
		}
	}

	function getTokensTable(uint256 _limit, uint256 _page, bool _isAsc) public view returns (uint256[] memory tokenIds, address[] memory owners, address[] memory approveds, address[] memory users, uint256[7][] memory compressedInfos, uint256 totalTokens, uint256 totalPages) {

		require(_limit > 0);
		totalTokens = totalSupply();

		if (totalTokens > 0) {
			totalPages = (totalTokens / _limit) + (totalTokens % _limit == 0 ? 0 : 1);
			require(_page < totalPages);

			uint256 _offset = _limit * _page;
			if (_page == totalPages - 1 && totalTokens % _limit != 0) {
				_limit = totalTokens % _limit;
			}

			tokenIds = new uint256[](_limit);
			for (uint256 i = 0; i < _limit; i++) {
				tokenIds[i] = tokenByIndex(_isAsc ? _offset + i : totalTokens - _offset - i - 1);
			}
		} else {
			totalPages = 0;
			tokenIds = new uint256[](0);
		}
		(owners, approveds, users, compressedInfos) = getTokens(tokenIds);
	}

	function getOwnerTokensTable(address _owner, uint256 _limit, uint256 _page, bool _isAsc) public view returns (uint256[] memory tokenIds, address[] memory approveds, address[] memory users, uint256[7][] memory compressedInfos, uint256 totalTokens, uint256 totalPages) {

		require(_limit > 0);
		totalTokens = balanceOf(_owner);

		if (totalTokens > 0) {
			totalPages = (totalTokens / _limit) + (totalTokens % _limit == 0 ? 0 : 1);
			require(_page < totalPages);

			uint256 _offset = _limit * _page;
			if (_page == totalPages - 1 && totalTokens % _limit != 0) {
				_limit = totalTokens % _limit;
			}

			tokenIds = new uint256[](_limit);
			for (uint256 i = 0; i < _limit; i++) {
				tokenIds[i] = tokenOfOwnerByIndex(_owner, _isAsc ? _offset + i : totalTokens - _offset - i - 1);
			}
		} else {
			totalPages = 0;
			tokenIds = new uint256[](0);
		}
		( , approveds, users, compressedInfos) = getTokens(tokenIds);
	}

	function allInfoFor(address _owner) external view returns (uint256 supply, uint256 ownerBalance) {

		return (totalSupply(), balanceOf(_owner));
	}

	
	function _transfer(address _from, address _to, uint256 _tokenId) internal {

		address _owner = ownerOf(_tokenId);
		address _approved = getApproved(_tokenId);
		require(_from == _owner);
		require(msg.sender == _owner || msg.sender == _approved || isApprovedForAll(_owner, msg.sender));

		info.list[_tokenId].owner = _to;
		if (_approved != address(0x0)) {
			info.list[_tokenId].approved = address(0x0);
			emit Approval(address(0x0), address(0x0), _tokenId);
		}

		uint256 _index = info.users[_from].indexOf[_tokenId] - 1;
		uint256 _moved = info.users[_from].list[info.users[_from].balance - 1];
		info.users[_from].list[_index] = _moved;
		info.users[_from].indexOf[_moved] = _index + 1;
		info.users[_from].balance--;
		delete info.users[_from].indexOf[_tokenId];
		uint256 _newIndex = info.users[_to].balance++;
		info.users[_to].indexOf[_tokenId] = _newIndex + 1;
		info.users[_to].list[_newIndex] = _tokenId;
		emit Transfer(_from, _to, _tokenId);
	}
}
pragma solidity ^0.8.11;

interface ERC20 {

	function allowance(address, address) external view returns (uint256);

	function balanceOf(address) external view returns (uint256);

	function transfer(address, uint256) external returns (bool);

	function transferFrom(address, address, uint256) external returns (bool);

}// Unlicense
pragma solidity >=0.8.4;

error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

error PRBMath__MulDivSignedInputTooSmall();

error PRBMath__MulDivSignedOverflow(uint256 rAbs);

error PRBMathSD59x18__AbsInputTooSmall();

error PRBMathSD59x18__CeilOverflow(int256 x);

error PRBMathSD59x18__DivInputTooSmall();

error PRBMathSD59x18__DivOverflow(uint256 rAbs);

error PRBMathSD59x18__ExpInputTooBig(int256 x);

error PRBMathSD59x18__Exp2InputTooBig(int256 x);

error PRBMathSD59x18__FloorUnderflow(int256 x);

error PRBMathSD59x18__FromIntOverflow(int256 x);

error PRBMathSD59x18__FromIntUnderflow(int256 x);

error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

error PRBMathSD59x18__LogInputTooSmall(int256 x);

error PRBMathSD59x18__MulInputTooSmall();

error PRBMathSD59x18__MulOverflow(uint256 rAbs);

error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

error PRBMathSD59x18__SqrtNegativeInput(int256 x);

error PRBMathSD59x18__SqrtOverflow(int256 x);

error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

error PRBMathUD60x18__CeilOverflow(uint256 x);

error PRBMathUD60x18__ExpInputTooBig(uint256 x);

error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

error PRBMathUD60x18__FromUintOverflow(uint256 x);

error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

error PRBMathUD60x18__LogInputTooSmall(uint256 x);

error PRBMathUD60x18__SqrtOverflow(uint256 x);

error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

library PRBMath {


	struct SD59x18 {
		int256 value;
	}

	struct UD60x18 {
		uint256 value;
	}


	uint256 internal constant SCALE = 1e18;

	uint256 internal constant SCALE_LPOTD = 262144;

	uint256 internal constant SCALE_INVERSE =
		78156646155174841979727994598816262306175212592076161876661_508869554232690281;


	function exp2(uint256 x) internal pure returns (uint256 result) {

		unchecked {
			result = 0x800000000000000000000000000000000000000000000000;

			if (x & 0x8000000000000000 > 0) {
				result = (result * 0x16A09E667F3BCC909) >> 64;
			}
			if (x & 0x4000000000000000 > 0) {
				result = (result * 0x1306FE0A31B7152DF) >> 64;
			}
			if (x & 0x2000000000000000 > 0) {
				result = (result * 0x1172B83C7D517ADCE) >> 64;
			}
			if (x & 0x1000000000000000 > 0) {
				result = (result * 0x10B5586CF9890F62A) >> 64;
			}
			if (x & 0x800000000000000 > 0) {
				result = (result * 0x1059B0D31585743AE) >> 64;
			}
			if (x & 0x400000000000000 > 0) {
				result = (result * 0x102C9A3E778060EE7) >> 64;
			}
			if (x & 0x200000000000000 > 0) {
				result = (result * 0x10163DA9FB33356D8) >> 64;
			}
			if (x & 0x100000000000000 > 0) {
				result = (result * 0x100B1AFA5ABCBED61) >> 64;
			}
			if (x & 0x80000000000000 > 0) {
				result = (result * 0x10058C86DA1C09EA2) >> 64;
			}
			if (x & 0x40000000000000 > 0) {
				result = (result * 0x1002C605E2E8CEC50) >> 64;
			}
			if (x & 0x20000000000000 > 0) {
				result = (result * 0x100162F3904051FA1) >> 64;
			}
			if (x & 0x10000000000000 > 0) {
				result = (result * 0x1000B175EFFDC76BA) >> 64;
			}
			if (x & 0x8000000000000 > 0) {
				result = (result * 0x100058BA01FB9F96D) >> 64;
			}
			if (x & 0x4000000000000 > 0) {
				result = (result * 0x10002C5CC37DA9492) >> 64;
			}
			if (x & 0x2000000000000 > 0) {
				result = (result * 0x1000162E525EE0547) >> 64;
			}
			if (x & 0x1000000000000 > 0) {
				result = (result * 0x10000B17255775C04) >> 64;
			}
			if (x & 0x800000000000 > 0) {
				result = (result * 0x1000058B91B5BC9AE) >> 64;
			}
			if (x & 0x400000000000 > 0) {
				result = (result * 0x100002C5C89D5EC6D) >> 64;
			}
			if (x & 0x200000000000 > 0) {
				result = (result * 0x10000162E43F4F831) >> 64;
			}
			if (x & 0x100000000000 > 0) {
				result = (result * 0x100000B1721BCFC9A) >> 64;
			}
			if (x & 0x80000000000 > 0) {
				result = (result * 0x10000058B90CF1E6E) >> 64;
			}
			if (x & 0x40000000000 > 0) {
				result = (result * 0x1000002C5C863B73F) >> 64;
			}
			if (x & 0x20000000000 > 0) {
				result = (result * 0x100000162E430E5A2) >> 64;
			}
			if (x & 0x10000000000 > 0) {
				result = (result * 0x1000000B172183551) >> 64;
			}
			if (x & 0x8000000000 > 0) {
				result = (result * 0x100000058B90C0B49) >> 64;
			}
			if (x & 0x4000000000 > 0) {
				result = (result * 0x10000002C5C8601CC) >> 64;
			}
			if (x & 0x2000000000 > 0) {
				result = (result * 0x1000000162E42FFF0) >> 64;
			}
			if (x & 0x1000000000 > 0) {
				result = (result * 0x10000000B17217FBB) >> 64;
			}
			if (x & 0x800000000 > 0) {
				result = (result * 0x1000000058B90BFCE) >> 64;
			}
			if (x & 0x400000000 > 0) {
				result = (result * 0x100000002C5C85FE3) >> 64;
			}
			if (x & 0x200000000 > 0) {
				result = (result * 0x10000000162E42FF1) >> 64;
			}
			if (x & 0x100000000 > 0) {
				result = (result * 0x100000000B17217F8) >> 64;
			}
			if (x & 0x80000000 > 0) {
				result = (result * 0x10000000058B90BFC) >> 64;
			}
			if (x & 0x40000000 > 0) {
				result = (result * 0x1000000002C5C85FE) >> 64;
			}
			if (x & 0x20000000 > 0) {
				result = (result * 0x100000000162E42FF) >> 64;
			}
			if (x & 0x10000000 > 0) {
				result = (result * 0x1000000000B17217F) >> 64;
			}
			if (x & 0x8000000 > 0) {
				result = (result * 0x100000000058B90C0) >> 64;
			}
			if (x & 0x4000000 > 0) {
				result = (result * 0x10000000002C5C860) >> 64;
			}
			if (x & 0x2000000 > 0) {
				result = (result * 0x1000000000162E430) >> 64;
			}
			if (x & 0x1000000 > 0) {
				result = (result * 0x10000000000B17218) >> 64;
			}
			if (x & 0x800000 > 0) {
				result = (result * 0x1000000000058B90C) >> 64;
			}
			if (x & 0x400000 > 0) {
				result = (result * 0x100000000002C5C86) >> 64;
			}
			if (x & 0x200000 > 0) {
				result = (result * 0x10000000000162E43) >> 64;
			}
			if (x & 0x100000 > 0) {
				result = (result * 0x100000000000B1721) >> 64;
			}
			if (x & 0x80000 > 0) {
				result = (result * 0x10000000000058B91) >> 64;
			}
			if (x & 0x40000 > 0) {
				result = (result * 0x1000000000002C5C8) >> 64;
			}
			if (x & 0x20000 > 0) {
				result = (result * 0x100000000000162E4) >> 64;
			}
			if (x & 0x10000 > 0) {
				result = (result * 0x1000000000000B172) >> 64;
			}
			if (x & 0x8000 > 0) {
				result = (result * 0x100000000000058B9) >> 64;
			}
			if (x & 0x4000 > 0) {
				result = (result * 0x10000000000002C5D) >> 64;
			}
			if (x & 0x2000 > 0) {
				result = (result * 0x1000000000000162E) >> 64;
			}
			if (x & 0x1000 > 0) {
				result = (result * 0x10000000000000B17) >> 64;
			}
			if (x & 0x800 > 0) {
				result = (result * 0x1000000000000058C) >> 64;
			}
			if (x & 0x400 > 0) {
				result = (result * 0x100000000000002C6) >> 64;
			}
			if (x & 0x200 > 0) {
				result = (result * 0x10000000000000163) >> 64;
			}
			if (x & 0x100 > 0) {
				result = (result * 0x100000000000000B1) >> 64;
			}
			if (x & 0x80 > 0) {
				result = (result * 0x10000000000000059) >> 64;
			}
			if (x & 0x40 > 0) {
				result = (result * 0x1000000000000002C) >> 64;
			}
			if (x & 0x20 > 0) {
				result = (result * 0x10000000000000016) >> 64;
			}
			if (x & 0x10 > 0) {
				result = (result * 0x1000000000000000B) >> 64;
			}
			if (x & 0x8 > 0) {
				result = (result * 0x10000000000000006) >> 64;
			}
			if (x & 0x4 > 0) {
				result = (result * 0x10000000000000003) >> 64;
			}
			if (x & 0x2 > 0) {
				result = (result * 0x10000000000000001) >> 64;
			}
			if (x & 0x1 > 0) {
				result = (result * 0x10000000000000001) >> 64;
			}

			result *= SCALE;
			result >>= (191 - (x >> 64));
		}
	}

	function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {

		if (x >= 2**128) {
			x >>= 128;
			msb += 128;
		}
		if (x >= 2**64) {
			x >>= 64;
			msb += 64;
		}
		if (x >= 2**32) {
			x >>= 32;
			msb += 32;
		}
		if (x >= 2**16) {
			x >>= 16;
			msb += 16;
		}
		if (x >= 2**8) {
			x >>= 8;
			msb += 8;
		}
		if (x >= 2**4) {
			x >>= 4;
			msb += 4;
		}
		if (x >= 2**2) {
			x >>= 2;
			msb += 2;
		}
		if (x >= 2**1) {
			msb += 1;
		}
	}

	function mulDiv(
		uint256 x,
		uint256 y,
		uint256 denominator
	) internal pure returns (uint256 result) {

		uint256 prod0; // Least significant 256 bits of the product
		uint256 prod1; // Most significant 256 bits of the product
		assembly {
			let mm := mulmod(x, y, not(0))
			prod0 := mul(x, y)
			prod1 := sub(sub(mm, prod0), lt(mm, prod0))
		}

		if (prod1 == 0) {
			unchecked {
				result = prod0 / denominator;
			}
			return result;
		}

		if (prod1 >= denominator) {
			revert PRBMath__MulDivOverflow(prod1, denominator);
		}


		uint256 remainder;
		assembly {
			remainder := mulmod(x, y, denominator)

			prod1 := sub(prod1, gt(remainder, prod0))
			prod0 := sub(prod0, remainder)
		}

		unchecked {
			uint256 lpotdod = denominator & (~denominator + 1);
			assembly {
				denominator := div(denominator, lpotdod)

				prod0 := div(prod0, lpotdod)

				lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
			}

			prod0 |= prod1 * lpotdod;

			uint256 inverse = (3 * denominator) ^ 2;

			inverse *= 2 - denominator * inverse; // inverse mod 2^8
			inverse *= 2 - denominator * inverse; // inverse mod 2^16
			inverse *= 2 - denominator * inverse; // inverse mod 2^32
			inverse *= 2 - denominator * inverse; // inverse mod 2^64
			inverse *= 2 - denominator * inverse; // inverse mod 2^128
			inverse *= 2 - denominator * inverse; // inverse mod 2^256

			result = prod0 * inverse;
			return result;
		}
	}

	function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {

		uint256 prod0;
		uint256 prod1;
		assembly {
			let mm := mulmod(x, y, not(0))
			prod0 := mul(x, y)
			prod1 := sub(sub(mm, prod0), lt(mm, prod0))
		}

		if (prod1 >= SCALE) {
			revert PRBMath__MulDivFixedPointOverflow(prod1);
		}

		uint256 remainder;
		uint256 roundUpUnit;
		assembly {
			remainder := mulmod(x, y, SCALE)
			roundUpUnit := gt(remainder, 499999999999999999)
		}

		if (prod1 == 0) {
			unchecked {
				result = (prod0 / SCALE) + roundUpUnit;
				return result;
			}
		}

		assembly {
			result := add(
				mul(
					or(
						div(sub(prod0, remainder), SCALE_LPOTD),
						mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
					),
					SCALE_INVERSE
				),
				roundUpUnit
			)
		}
	}

	function mulDivSigned(
		int256 x,
		int256 y,
		int256 denominator
	) internal pure returns (int256 result) {

		if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
			revert PRBMath__MulDivSignedInputTooSmall();
		}

		uint256 ax;
		uint256 ay;
		uint256 ad;
		unchecked {
			ax = x < 0 ? uint256(-x) : uint256(x);
			ay = y < 0 ? uint256(-y) : uint256(y);
			ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
		}

		uint256 rAbs = mulDiv(ax, ay, ad);
		if (rAbs > uint256(type(int256).max)) {
			revert PRBMath__MulDivSignedOverflow(rAbs);
		}

		uint256 sx;
		uint256 sy;
		uint256 sd;
		assembly {
			sx := sgt(x, sub(0, 1))
			sy := sgt(y, sub(0, 1))
			sd := sgt(denominator, sub(0, 1))
		}

		result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
	}

	function sqrt(uint256 x) internal pure returns (uint256 result) {

		if (x == 0) {
			return 0;
		}

		uint256 xAux = uint256(x);
		result = 1;
		if (xAux >= 0x100000000000000000000000000000000) {
			xAux >>= 128;
			result <<= 64;
		}
		if (xAux >= 0x10000000000000000) {
			xAux >>= 64;
			result <<= 32;
		}
		if (xAux >= 0x100000000) {
			xAux >>= 32;
			result <<= 16;
		}
		if (xAux >= 0x10000) {
			xAux >>= 16;
			result <<= 8;
		}
		if (xAux >= 0x100) {
			xAux >>= 8;
			result <<= 4;
		}
		if (xAux >= 0x10) {
			xAux >>= 4;
			result <<= 2;
		}
		if (xAux >= 0x8) {
			result <<= 1;
		}

		unchecked {
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1; // Seven iterations should be enough
			uint256 roundedDownResult = x / result;
			return result >= roundedDownResult ? roundedDownResult : result;
		}
	}
}// Unlicense
pragma solidity >=0.8.4;


library PRBMathUD60x18 {

	uint256 internal constant HALF_SCALE = 5e17;

	uint256 internal constant LOG2_E = 1_442695040888963407;

	uint256 internal constant MAX_UD60x18 =
		115792089237316195423570985008687907853269984665640564039457_584007913129639935;

	uint256 internal constant MAX_WHOLE_UD60x18 =
		115792089237316195423570985008687907853269984665640564039457_000000000000000000;

	uint256 internal constant SCALE = 1e18;

	function avg(uint256 x, uint256 y) internal pure returns (uint256 result) {

		unchecked {
			result = (x >> 1) + (y >> 1) + (x & y & 1);
		}
	}

	function ceil(uint256 x) internal pure returns (uint256 result) {

		if (x > MAX_WHOLE_UD60x18) {
			revert PRBMathUD60x18__CeilOverflow(x);
		}
		assembly {
			let remainder := mod(x, SCALE)

			let delta := sub(SCALE, remainder)

			result := add(x, mul(delta, gt(remainder, 0)))
		}
	}

	function div(uint256 x, uint256 y) internal pure returns (uint256 result) {

		result = PRBMath.mulDiv(x, SCALE, y);
	}

	function e() internal pure returns (uint256 result) {

		result = 2_718281828459045235;
	}

	function exp(uint256 x) internal pure returns (uint256 result) {

		if (x >= 133_084258667509499441) {
			revert PRBMathUD60x18__ExpInputTooBig(x);
		}

		unchecked {
			uint256 doubleScaleProduct = x * LOG2_E;
			result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
		}
	}

	function exp2(uint256 x) internal pure returns (uint256 result) {

		if (x >= 192e18) {
			revert PRBMathUD60x18__Exp2InputTooBig(x);
		}

		unchecked {
			uint256 x192x64 = (x << 64) / SCALE;

			result = PRBMath.exp2(x192x64);
		}
	}

	function floor(uint256 x) internal pure returns (uint256 result) {

		assembly {
			let remainder := mod(x, SCALE)

			result := sub(x, mul(remainder, gt(remainder, 0)))
		}
	}

	function frac(uint256 x) internal pure returns (uint256 result) {

		assembly {
			result := mod(x, SCALE)
		}
	}

	function fromUint(uint256 x) internal pure returns (uint256 result) {

		unchecked {
			if (x > MAX_UD60x18 / SCALE) {
				revert PRBMathUD60x18__FromUintOverflow(x);
			}
			result = x * SCALE;
		}
	}

	function gm(uint256 x, uint256 y) internal pure returns (uint256 result) {

		if (x == 0) {
			return 0;
		}

		unchecked {
			uint256 xy = x * y;
			if (xy / x != y) {
				revert PRBMathUD60x18__GmOverflow(x, y);
			}

			result = PRBMath.sqrt(xy);
		}
	}

	function inv(uint256 x) internal pure returns (uint256 result) {

		unchecked {
			result = 1e36 / x;
		}
	}

	function ln(uint256 x) internal pure returns (uint256 result) {

		unchecked {
			result = (log2(x) * SCALE) / LOG2_E;
		}
	}

	function log10(uint256 x) internal pure returns (uint256 result) {

		if (x < SCALE) {
			revert PRBMathUD60x18__LogInputTooSmall(x);
		}

		assembly {
			switch x
			case 1 { result := mul(SCALE, sub(0, 18)) }
			case 10 { result := mul(SCALE, sub(1, 18)) }
			case 100 { result := mul(SCALE, sub(2, 18)) }
			case 1000 { result := mul(SCALE, sub(3, 18)) }
			case 10000 { result := mul(SCALE, sub(4, 18)) }
			case 100000 { result := mul(SCALE, sub(5, 18)) }
			case 1000000 { result := mul(SCALE, sub(6, 18)) }
			case 10000000 { result := mul(SCALE, sub(7, 18)) }
			case 100000000 { result := mul(SCALE, sub(8, 18)) }
			case 1000000000 { result := mul(SCALE, sub(9, 18)) }
			case 10000000000 { result := mul(SCALE, sub(10, 18)) }
			case 100000000000 { result := mul(SCALE, sub(11, 18)) }
			case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
			case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
			case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
			case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
			case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
			case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
			case 1000000000000000000 { result := 0 }
			case 10000000000000000000 { result := SCALE }
			case 100000000000000000000 { result := mul(SCALE, 2) }
			case 1000000000000000000000 { result := mul(SCALE, 3) }
			case 10000000000000000000000 { result := mul(SCALE, 4) }
			case 100000000000000000000000 { result := mul(SCALE, 5) }
			case 1000000000000000000000000 { result := mul(SCALE, 6) }
			case 10000000000000000000000000 { result := mul(SCALE, 7) }
			case 100000000000000000000000000 { result := mul(SCALE, 8) }
			case 1000000000000000000000000000 { result := mul(SCALE, 9) }
			case 10000000000000000000000000000 { result := mul(SCALE, 10) }
			case 100000000000000000000000000000 { result := mul(SCALE, 11) }
			case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
			case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
			case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
			case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
			case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
			case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
			case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
			case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
			case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
			case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
			case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
			case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
			case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
			case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
			case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
			case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
			case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
			case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
			case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
			case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
			case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
			case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
			case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
			case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
			case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
			case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
			case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
			case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
			case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
			case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
			case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
			case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
			case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
			case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
			case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
			case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
			case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
			case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
			case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
			case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
			case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
			case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
			case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
			case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
			case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
			case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
			case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
			case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 59) }
			default {
				result := MAX_UD60x18
			}
		}

		if (result == MAX_UD60x18) {
			unchecked {
				result = (log2(x) * SCALE) / 3_321928094887362347;
			}
		}
	}

	function log2(uint256 x) internal pure returns (uint256 result) {

		if (x < SCALE) {
			revert PRBMathUD60x18__LogInputTooSmall(x);
		}
		unchecked {
			uint256 n = PRBMath.mostSignificantBit(x / SCALE);

			result = n * SCALE;

			uint256 y = x >> n;

			if (y == SCALE) {
				return result;
			}

			for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
				y = (y * y) / SCALE;

				if (y >= 2 * SCALE) {
					result += delta;

					y >>= 1;
				}
			}
		}
	}

	function mul(uint256 x, uint256 y) internal pure returns (uint256 result) {

		result = PRBMath.mulDivFixedPoint(x, y);
	}

	function pi() internal pure returns (uint256 result) {

		result = 3_141592653589793238;
	}

	function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {

		if (x == 0) {
			result = y == 0 ? SCALE : uint256(0);
		} else {
			result = exp2(mul(log2(x), y));
		}
	}

	function powu(uint256 x, uint256 y) internal pure returns (uint256 result) {

		result = y & 1 > 0 ? x : SCALE;

		for (y >>= 1; y > 0; y >>= 1) {
			x = PRBMath.mulDivFixedPoint(x, x);

			if (y & 1 > 0) {
				result = PRBMath.mulDivFixedPoint(result, x);
			}
		}
	}

	function scale() internal pure returns (uint256 result) {

		result = SCALE;
	}

	function sqrt(uint256 x) internal pure returns (uint256 result) {

		unchecked {
			if (x > MAX_UD60x18 / SCALE) {
				revert PRBMathUD60x18__SqrtOverflow(x);
			}
			result = PRBMath.sqrt(x * SCALE);
		}
	}

	function toUint(uint256 x) internal pure returns (uint256 result) {

		unchecked {
			result = x / SCALE;
		}
	}
}// MIT
pragma solidity ^0.8.11;


contract StakingRewards {


	using PRBMathUD60x18 for uint256;

	uint256 constant private FLOAT_SCALAR = 2**64;
	uint256 constant private PERCENT_FEE = 5; // only for WTF staking
	uint256 constant private X_TICK = 30 days;

	struct User {
		uint256 deposited;
		int256 scaledPayout;
	}

	struct Info {
		uint256 totalRewards;
		uint256 startTime;
		uint256 lastUpdated;
		uint256 pendingFee;
		uint256 scaledRewardsPerToken;
		uint256 totalDeposited;
		mapping(address => User) users;
		WTF wtf;
		ERC20 token;
	}
	Info private info;


	event Deposit(address indexed user, uint256 amount, uint256 fee);
	event Withdraw(address indexed user, uint256 amount, uint256 fee);
	event Claim(address indexed user, uint256 amount);
	event Reinvest(address indexed user, uint256 amount);
	event Reward(uint256 amount);


	constructor(uint256 _totalRewards, uint256 _stakingRewardsStart, ERC20 _token) {
		info.totalRewards = _totalRewards;
		info.startTime = block.timestamp < _stakingRewardsStart ? _stakingRewardsStart : block.timestamp;
		info.lastUpdated = startTime();
		info.wtf = WTF(msg.sender);
		info.token = _token;
	}

	function update() public {

		uint256 _now = block.timestamp;
		if (_now > info.lastUpdated && totalDeposited() > 0) {
			uint256 _reward = info.totalRewards.mul(_delta(_getX(info.lastUpdated), _getX(_now)));
			if (info.pendingFee > 0) {
				_reward += info.pendingFee;
				info.pendingFee = 0;
			}
			uint256 _balanceBefore = info.wtf.balanceOf(address(this));
			info.wtf.claimRewards();
			_reward += info.wtf.balanceOf(address(this)) - _balanceBefore;
			info.lastUpdated = _now;
			_disburse(_reward);
		}
	}

	function deposit(uint256 _amount) external {

		depositFor(msg.sender, _amount);
	}

	function depositFor(address _user, uint256 _amount) public {

		require(_amount > 0);
		update();
		uint256 _balanceBefore = info.token.balanceOf(address(this));
		info.token.transferFrom(msg.sender, address(this), _amount);
		uint256 _amountReceived = info.token.balanceOf(address(this)) - _balanceBefore;
		_deposit(_user, _amountReceived);
	}

	function tokenCallback(address _from, uint256 _tokens, bytes calldata) external returns (bool) {

		require(_isWTF() && msg.sender == tokenAddress());
		require(_tokens > 0);
		update();
		_deposit(_from, _tokens);
		return true;
	}

	function disburse(uint256 _amount) public {

		require(_amount > 0);
		update();
		uint256 _balanceBefore = info.wtf.balanceOf(address(this));
		info.wtf.transferFrom(msg.sender, address(this), _amount);
		uint256 _amountReceived = info.wtf.balanceOf(address(this)) - _balanceBefore;
		_processFee(_amountReceived);
	}

	function withdrawAll() public {

		uint256 _deposited = depositedOf(msg.sender);
		if (_deposited > 0) {
			withdraw(_deposited);
		}
	}

	function withdraw(uint256 _amount) public {

		require(_amount > 0 && _amount <= depositedOf(msg.sender));
		update();
		info.totalDeposited -= _amount;
		info.users[msg.sender].deposited -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount * info.scaledRewardsPerToken);
		uint256 _fee = _calculateFee(_amount);
		info.token.transfer(msg.sender, _amount - _fee);
		_processFee(_fee);
		emit Withdraw(msg.sender, _amount, _fee);
	}

	function claim() public {

		update();
		uint256 _rewards = rewardsOf(msg.sender);
		if (_rewards > 0) {
			info.users[msg.sender].scaledPayout += int256(_rewards * FLOAT_SCALAR);
			info.wtf.transfer(msg.sender, _rewards);
			emit Claim(msg.sender, _rewards);
		}
	}

	function reinvest() public {

		require(_isWTF());
		update();
		uint256 _rewards = rewardsOf(msg.sender);
		if (_rewards > 0) {
			info.users[msg.sender].scaledPayout += int256(_rewards * FLOAT_SCALAR);
			_deposit(msg.sender, _rewards);
			emit Reinvest(msg.sender, _rewards);
		}
	}

	
	function wtfAddress() public view returns (address) {

		return address(info.wtf);
	}
	
	function tokenAddress() public view returns (address) {

		return address(info.token);
	}

	function startTime() public view returns (uint256) {

		return info.startTime;
	}

	function totalDeposited() public view returns (uint256) {

		return info.totalDeposited;
	}

	function depositedOf(address _user) public view returns (uint256) {

		return info.users[_user].deposited;
	}
	
	function rewardsOf(address _user) public view returns (uint256) {

		return uint256(int256(info.scaledRewardsPerToken * depositedOf(_user)) - info.users[_user].scaledPayout) / FLOAT_SCALAR;
	}
	
	function currentRatePerDay() public view returns (uint256) {

		if (block.timestamp < startTime()) {
			return info.totalRewards.mul(_delta(_getX(startTime()), _getX(startTime() + 24 hours)));
		} else {
			return info.totalRewards.mul(_delta(_getX(block.timestamp), _getX(block.timestamp + 24 hours)));
		}
	}

	function totalDistributed() public view returns (uint256) {

		return info.totalRewards.mul(_sum(_getX(block.timestamp)));
	}

	function allInfoFor(address _user) external view returns (uint256 startingTime, uint256 totalRewardsDistributed, uint256 rewardsRatePerDay, uint256 currentFeePercent, uint256 totalTokensDeposited, uint256 virtualRewards, uint256 userWTF, uint256 userBalance, uint256 userAllowance, uint256 userDeposited, uint256 userRewards) {

		startingTime = startTime();
		totalRewardsDistributed = totalDistributed();
		rewardsRatePerDay = currentRatePerDay();
		currentFeePercent = _calculateFee(1e20);
		totalTokensDeposited = totalDeposited();
		virtualRewards = block.timestamp > info.lastUpdated ? info.totalRewards.mul(_delta(_getX(info.lastUpdated), _getX(block.timestamp))) : 0;
		userWTF = info.wtf.balanceOf(_user);
		userBalance = info.token.balanceOf(_user);
		userAllowance = info.token.allowance(_user, address(this));
		userDeposited = depositedOf(_user);
		userRewards = rewardsOf(_user);
	}

	
	function _deposit(address _user, uint256 _amount) internal {

		uint256 _fee = _calculateFee(_amount);
		uint256 _deposited = _amount - _fee;
		info.totalDeposited += _deposited;
		info.users[_user].deposited += _deposited;
		info.users[_user].scaledPayout += int256(_deposited * info.scaledRewardsPerToken);
		_processFee(_fee);
		emit Deposit(_user, _amount, _fee);
	}
	
	function _processFee(uint256 _fee) internal {

		if (_fee > 0) {
			if (block.timestamp < startTime() || totalDeposited() == 0) {
				info.pendingFee += _fee;
			} else {
				_disburse(_fee);
			}
		}
	}

	function _disburse(uint256 _amount) internal {

		info.scaledRewardsPerToken += _amount * FLOAT_SCALAR / totalDeposited();
		emit Reward(_amount);
	}


	function _isWTF() internal view returns (bool) {

		return wtfAddress() == tokenAddress();
	}

	function _calculateFee(uint256 _amount) internal view returns (uint256) {

		return _isWTF() ? (_amount * PERCENT_FEE / 100).mul(1e18 - _sum(_getX(block.timestamp))) : 0;
	}
	
	function _getX(uint256 t) internal view returns (uint256) {

		uint256 _start = startTime();
		if (t < _start) {
			return 0;
		} else {
			return ((t - _start) * 1e18).div(X_TICK * 1e18);
		}
	}

	function _sum(uint256 x) internal pure returns (uint256) {

		uint256 _e2x = x.exp2();
		return (_e2x - 1e18).div(_e2x);
	}

	function _delta(uint256 x1, uint256 x2) internal pure returns (uint256) {

		require(x2 >= x1);
		return _sum(x2) - _sum(x1);
	}
}// MIT
pragma solidity ^0.8.11;



contract FeeManager {


	WTF private wtf;

	constructor() {
		wtf = WTF(msg.sender);
	}

	function disburse() external {

		wtf.claimRewards();
		uint256 _balance = wtf.balanceOf(address(this));
		if (_balance > 0) {
			uint256 _oneFifth = _balance / 5;
			Treasury(payable(wtf.treasuryAddress())).collect();
			wtf.transfer(wtf.treasuryAddress(), _oneFifth); // 20%
			StakingRewards(wtf.stakingRewardsAddress()).disburse(_oneFifth); // 20%
			StakingRewards(wtf.lpStakingRewardsAddress()).disburse(3 * _oneFifth); // 60%
		}
	}


	function wtfAddress() external view returns (address) {

		return address(wtf);
	}
}


contract TeamReferral {

	receive() external payable {}
	function release() external {

		address _this = address(this);
		require(_this.balance > 0);
		payable(0x6129E7bCb71C0d7D4580141C4E6a995f16293F42).transfer(_this.balance / 10); // 10%
		payable(0xc9AebdD8fD0d52c35A32fD9155467Cf28Ce474c3).transfer(_this.balance / 3); // 30%
		payable(0xdEE79eD62B42e30EA7EbB6f1b7A3f04143D18b7F).transfer(_this.balance / 2); // 30%
		payable(0x575446Aa9E9647C40edB7a467e45C5916add1538).transfer(_this.balance); // 30%
	}
}


contract Treasury {


	address public owner;
	uint256 public lockedUntil;
	WTF private wtf;

	modifier _onlyOwner() {

		require(msg.sender == owner);
		_;
	}

	constructor() {
		owner = 0x65dd4990719bE9B20322e4E8D3Bd77a4401a0357;
		lockedUntil = block.timestamp + 30 days;
		wtf = WTF(msg.sender);
	}

	receive() external payable {}

	function setOwner(address _owner) external _onlyOwner {

		owner = _owner;
	}

	function transferETH(address payable _destination, uint256 _amount) external _onlyOwner {

		require(isUnlocked());
		_destination.transfer(_amount);
	}

	function transferTokens(ERC20 _token, address _destination, uint256 _amount) external _onlyOwner {

		require(isUnlocked());
		_token.transfer(_destination, _amount);
	}

	function collect() external {

		wtf.claimRewards();
	}


	function isUnlocked() public view returns (bool) {

		return block.timestamp > lockedUntil;
	}

	function wtfAddress() external view returns (address) {

		return address(wtf);
	}
}// MIT
pragma solidity ^0.8.11;


interface Callable {

	function tokenCallback(address _from, uint256 _tokens, bytes calldata _data) external returns (bool);

}

interface Router {

	function WETH() external pure returns (address);

	function factory() external pure returns (address);

}

interface Factory {

	function createPair(address, address) external returns (address);

}

interface Pair {

	function token0() external view returns (address);

	function totalSupply() external view returns (uint256);

	function balanceOf(address) external view returns (uint256);

	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}


contract WTF {


	uint256 constant private FLOAT_SCALAR = 2**64;
	uint256 constant private UINT_MAX = type(uint256).max;
	uint256 constant private TRANSFER_FEE_SCALE = 1000; // 1 = 0.1%
	uint256 constant private WTF_STAKING_SUPPLY = 2e25; // 20M WTF
	uint256 constant private LP_STAKING_SUPPLY = 4e25; // 40M WTF
	uint256 constant private TREASURY_SUPPLY = 4e25; // 40M WTF
	uint256 constant private BASE_UPGRADE_COST = 1e19; // 10 WTF
	uint256 constant private SERVICE_FEE = 0.01 ether;

	string constant public name = "fees.wtf";
	string constant public symbol = "WTF";
	uint8 constant public decimals = 18;

	struct User {
		uint256 balance;
		mapping(address => uint256) allowance;
		int256 scaledPayout;
		uint256 reflinkLevel;
		bool unlocked;
	}

	struct Info {
		bytes32 merkleRoot;
		uint256 openingTime;
		uint256 closingTime;
		uint256 totalSupply;
		uint256 scaledRewardsPerToken;
		mapping(uint256 => uint256) claimedWTFBitMap;
		mapping(uint256 => uint256) claimedNFTBitMap;
		mapping(address => User) users;
		mapping(address => bool) toWhitelist;
		mapping(address => bool) fromWhitelist;
		address owner;
		Router router;
		Pair pair;
		bool weth0;
		WTFNFT nft;
		TeamReferral team;
		Treasury treasury;
		StakingRewards stakingRewards;
		StakingRewards lpStakingRewards;
		address feeManager;
		uint256 transferFee;
		uint256 feeManagerPercent;
	}
	Info private info;


	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	event WhitelistUpdated(address indexed user, bool fromWhitelisted, bool toWhitelisted);
	event ReflinkRewards(address indexed referrer, uint256 amount);
	event ClaimRewards(address indexed user, uint256 amount);
	event Reward(uint256 amount);

	modifier _onlyOwner() {

		require(msg.sender == owner());
		_;
	}


	constructor(bytes32 _merkleRoot, uint256 _openingTime, uint256 _stakingRewardsStart) {
		info.merkleRoot = _merkleRoot;
		info.openingTime = block.timestamp < _openingTime ? _openingTime : block.timestamp;
		info.closingTime = openingTime() + 30 days;
		info.router = Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		info.pair = Pair(Factory(info.router.factory()).createPair(info.router.WETH(), address(this)));
		info.weth0 = info.pair.token0() == info.router.WETH();
		info.transferFee = 40; // 4%
		info.feeManagerPercent = 25; // 25%
		info.owner = 0x65dd4990719bE9B20322e4E8D3Bd77a4401a0357;
		info.nft = new WTFNFT();
		info.team = new TeamReferral();
		info.treasury = new Treasury();
		_mint(treasuryAddress(), TREASURY_SUPPLY);
		info.stakingRewards = new StakingRewards(WTF_STAKING_SUPPLY, _stakingRewardsStart, ERC20(address(this)));
		_mint(stakingRewardsAddress(), WTF_STAKING_SUPPLY);
		info.lpStakingRewards = new StakingRewards(LP_STAKING_SUPPLY, _stakingRewardsStart, ERC20(pairAddress()));
		_mint(lpStakingRewardsAddress(), LP_STAKING_SUPPLY);
		info.feeManager = address(new FeeManager());
		_approve(feeManagerAddress(), stakingRewardsAddress(), UINT_MAX);
		_approve(feeManagerAddress(), lpStakingRewardsAddress(), UINT_MAX);
	}

	function setOwner(address _owner) external _onlyOwner {

		info.owner = _owner;
	}

	function setFeeManager(address _feeManager) external _onlyOwner {

		info.feeManager = _feeManager;
	}

	function setClosingTime(uint256 _closingTime) external _onlyOwner {

		info.closingTime = _closingTime;
	}

	function setTransferFee(uint256 _transferFee) external _onlyOwner {

		require(_transferFee <= 100); // ≤10%
		info.transferFee = _transferFee;
	}

	function setFeeManagerPercent(uint256 _feeManagerPercent) external _onlyOwner {

		require(_feeManagerPercent <= 100);
		info.feeManagerPercent = _feeManagerPercent;
	}

	function setWhitelisted(address _address, bool _fromWhitelisted, bool _toWhitelisted) external _onlyOwner {

		info.fromWhitelist[_address] = _fromWhitelisted;
		info.toWhitelist[_address] = _toWhitelisted;
		emit WhitelistUpdated(_address, _fromWhitelisted, _toWhitelisted);
	}


	function disburse(uint256 _amount) external {

		require(_amount > 0);
		uint256 _balanceBefore = balanceOf(address(this));
		_transfer(msg.sender, address(this), _amount);
		uint256 _amountReceived = balanceOf(address(this)) - _balanceBefore;
		_disburse(_amountReceived);
	}

	function sweep() external {

		if (address(this).balance > 0) {
			teamAddress().transfer(address(this).balance);
		}
	}

	function upgradeReflink(uint256 _toLevel) external {

		uint256 _currentLevel = reflinkLevel(msg.sender);
		require(_currentLevel < _toLevel);
		uint256 _totalCost = 0;
		for (uint256 i = _currentLevel; i < _toLevel; i++) {
			_totalCost += upgradeCost(i);
		}
		burn(_totalCost);
		info.users[msg.sender].reflinkLevel = _toLevel;
	}

	function unlock(address _account, address payable _referrer) external payable {

		require(block.timestamp < closingTime());
		require(!isUnlocked(_account));
		require(msg.value == SERVICE_FEE);
		uint256 _refFee = 0;
		if (_referrer != address(0x0)) {
			_refFee = SERVICE_FEE * reflinkPercent(_referrer) / 100;
			!_referrer.send(_refFee);
			emit ReflinkRewards(_referrer, _refFee);
		}
		uint256 _remaining = SERVICE_FEE - _refFee;
		teamAddress().transfer(_remaining);
		emit ReflinkRewards(teamAddress(), _remaining);
		info.users[_account].unlocked = true;
	}
	
	function claim(address _account, uint256[9] calldata _data, bytes32[] calldata _proof) external {

		claimWTF(_account, _data, _proof);
		claimNFT(_account, _data, _proof);
	}
	
	function claimWTF(address _account, uint256[9] calldata _data, bytes32[] calldata _proof) public {

		require(isOpen());
		require(isUnlocked(_account));
		uint256 _index = _data[0];
		uint256 _amount = _data[1];
		require(!isClaimedWTF(_index));
		require(_verify(_proof, keccak256(abi.encodePacked(_account, _data))));
		uint256 _claimedWordIndex = _index / 256;
		uint256 _claimedBitIndex = _index % 256;
		info.claimedWTFBitMap[_claimedWordIndex] = info.claimedWTFBitMap[_claimedWordIndex] | (1 << _claimedBitIndex);
		_mint(_account, _amount);
	}

	function claimNFT(address _account, uint256[9] calldata _data, bytes32[] calldata _proof) public {

		require(isOpen());
		require(isUnlocked(_account));
		uint256 _index = _data[0];
		require(!isClaimedNFT(_index));
		require(_verify(_proof, keccak256(abi.encodePacked(_account, _data))));
		uint256 _claimedWordIndex = _index / 256;
		uint256 _claimedBitIndex = _index % 256;
		info.claimedNFTBitMap[_claimedWordIndex] = info.claimedNFTBitMap[_claimedWordIndex] | (1 << _claimedBitIndex);
		info.nft.mint(_account, _data[2], _data[3], _data[4], _data[5], _data[6], _data[7], _data[8]);
	}

	function claimRewards() external {

		boostRewards();
		uint256 _rewards = rewardsOf(msg.sender);
		if (_rewards > 0) {
			info.users[msg.sender].scaledPayout += int256(_rewards * FLOAT_SCALAR);
			_transfer(address(this), msg.sender, _rewards);
			emit ClaimRewards(msg.sender, _rewards);
		}
	}

	function boostRewards() public {

		address _this = address(this);
		uint256 _rewards = rewardsOf(_this);
		if (_rewards > 0) {
			info.users[_this].scaledPayout += int256(_rewards * FLOAT_SCALAR);
			_disburse(_rewards);
			emit ClaimRewards(_this, _rewards);
		}
	}

	function burn(uint256 _tokens) public {

		require(balanceOf(msg.sender) >= _tokens);
		info.totalSupply -= _tokens;
		info.users[msg.sender].balance -= _tokens;
		info.users[msg.sender].scaledPayout -= int256(_tokens * info.scaledRewardsPerToken);
		emit Transfer(msg.sender, address(0x0), _tokens);
	}

	function transfer(address _to, uint256 _tokens) external returns (bool) {

		return _transfer(msg.sender, _to, _tokens);
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {

		return _approve(msg.sender, _spender, _tokens);
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {

		uint256 _allowance = allowance(_from, msg.sender);
		require(_allowance >= _tokens);
		if (_allowance != UINT_MAX) {
			info.users[_from].allowance[msg.sender] -= _tokens;
		}
		return _transfer(_from, _to, _tokens);
	}

	function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {

		uint256 _balanceBefore = balanceOf(_to);
		_transfer(msg.sender, _to, _tokens);
		uint256 _tokensReceived = balanceOf(_to) - _balanceBefore;
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Callable(_to).tokenCallback(msg.sender, _tokensReceived, _data));
		}
		return true;
	}
	

	function pairAddress() public view returns (address) {

		return address(info.pair);
	}

	function nftAddress() external view returns (address) {

		return address(info.nft);
	}

	function teamAddress() public view returns (address payable) {

		return payable(address(info.team));
	}

	function treasuryAddress() public view returns (address) {

		return address(info.treasury);
	}

	function stakingRewardsAddress() public view returns (address) {

		return address(info.stakingRewards);
	}

	function lpStakingRewardsAddress() public view returns (address) {

		return address(info.lpStakingRewards);
	}

	function feeManagerAddress() public view returns (address) {

		return info.feeManager;
	}

	function owner() public view returns (address) {

		return info.owner;
	}

	function transferFee() public view returns (uint256) {

		return info.transferFee;
	}

	function feeManagerPercent() public view returns (uint256) {

		return info.feeManagerPercent;
	}

	function isFromWhitelisted(address _address) public view returns (bool) {

		return info.fromWhitelist[_address];
	}

	function isToWhitelisted(address _address) public view returns (bool) {

		return info.toWhitelist[_address];
	}

	function merkleRoot() public view returns (bytes32) {

		return info.merkleRoot;
	}

	function openingTime() public view returns (uint256) {

		return info.openingTime;
	}

	function closingTime() public view returns (uint256) {

		return info.closingTime;
	}

	function isOpen() public view returns (bool) {

		return block.timestamp > openingTime() && block.timestamp < closingTime();
	}

	function isUnlocked(address _user) public view returns (bool) {

		return info.users[_user].unlocked;
	}

	function isClaimedWTF(uint256 _index) public view returns (bool) {

		uint256 _claimedWordIndex = _index / 256;
		uint256 _claimedBitIndex = _index % 256;
		uint256 _claimedWord = info.claimedWTFBitMap[_claimedWordIndex];
		uint256 _mask = (1 << _claimedBitIndex);
		return _claimedWord & _mask == _mask;
	}

	function isClaimedNFT(uint256 _index) public view returns (bool) {

		uint256 _claimedWordIndex = _index / 256;
		uint256 _claimedBitIndex = _index % 256;
		uint256 _claimedWord = info.claimedNFTBitMap[_claimedWordIndex];
		uint256 _mask = (1 << _claimedBitIndex);
		return _claimedWord & _mask == _mask;
	}
	
	function totalSupply() public view returns (uint256) {

		return info.totalSupply;
	}

	function balanceOf(address _user) public view returns (uint256) {

		return info.users[_user].balance;
	}

	function rewardsOf(address _user) public view returns (uint256) {

		return uint256(int256(info.scaledRewardsPerToken * balanceOf(_user)) - info.users[_user].scaledPayout) / FLOAT_SCALAR;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {

		return info.users[_user].allowance[_spender];
	}

	function reflinkLevel(address _user) public view returns (uint256) {

		return info.users[_user].reflinkLevel;
	}

	function reflinkPercent(address _user) public view returns (uint256) {

		return 10 * (reflinkLevel(_user) + 1);
	}

	function upgradeCost(uint256 _reflinkLevel) public pure returns (uint256) {

		require(_reflinkLevel < 4);
		return BASE_UPGRADE_COST * 10**_reflinkLevel;
	}

	function reflinkInfoFor(address _user) external view returns (uint256 balance, uint256 level, uint256 percent) {

		return (balanceOf(_user), reflinkLevel(_user), reflinkPercent(_user));
	}

	function claimInfoFor(uint256 _index, address _user) external view returns (uint256 openTime, uint256 closeTime, bool unlocked, bool claimedWTF, bool claimedNFT, uint256 wethReserve, uint256 wtfReserve) {

		openTime = openingTime();
		closeTime = closingTime();
		unlocked = isUnlocked(_user);
		claimedWTF = isClaimedWTF(_index);
		claimedNFT = isClaimedNFT(_index);
		( , , wethReserve, wtfReserve, , , ) = allInfoFor(address(0x0));
	}

	function allInfoFor(address _user) public view returns (uint256 totalTokens, uint256 totalLPTokens, uint256 wethReserve, uint256 wtfReserve, uint256 userBalance, uint256 userRewards, uint256 userLPBalance) {

		totalTokens = totalSupply();
		totalLPTokens = info.pair.totalSupply();
		(uint256 _res0, uint256 _res1, ) = info.pair.getReserves();
		wethReserve = info.weth0 ? _res0 : _res1;
		wtfReserve = info.weth0 ? _res1 : _res0;
		userBalance = balanceOf(_user);
		userRewards = rewardsOf(_user);
		userLPBalance = info.pair.balanceOf(_user);
	}


	function _mint(address _account, uint256 _amount) internal {

		info.totalSupply += _amount;
		info.users[_account].balance += _amount;
		info.users[_account].scaledPayout += int256(_amount * info.scaledRewardsPerToken);
		emit Transfer(address(0x0), _account, _amount);
	}
	
	function _approve(address _owner, address _spender, uint256 _tokens) internal returns (bool) {

		info.users[_owner].allowance[_spender] = _tokens;
		emit Approval(_owner, _spender, _tokens);
		return true;
	}
	
	function _transfer(address _from, address _to, uint256 _tokens) internal returns (bool) {

		require(balanceOf(_from) >= _tokens);
		info.users[_from].balance -= _tokens;
		info.users[_from].scaledPayout -= int256(_tokens * info.scaledRewardsPerToken);
		uint256 _fee = 0;
		if (!_isExcludedFromFee(_from, _to)) {
			_fee = _tokens * transferFee() / TRANSFER_FEE_SCALE;
			address _this = address(this);
			info.users[_this].balance += _fee;
			info.users[_this].scaledPayout += int256(_fee * info.scaledRewardsPerToken);
			emit Transfer(_from, _this, _fee);
		}
		uint256 _transferred = _tokens - _fee;
		info.users[_to].balance += _transferred;
		info.users[_to].scaledPayout += int256(_transferred * info.scaledRewardsPerToken);
		emit Transfer(_from, _to, _transferred);
		if (_fee > 0) {
			uint256 _feeManagerRewards = _fee * feeManagerPercent() / 100;
			info.users[feeManagerAddress()].scaledPayout -= int256(_feeManagerRewards * FLOAT_SCALAR);
			_disburse(_fee - _feeManagerRewards);
		}
		return true;
	}

	function _disburse(uint256 _amount) internal {

		if (_amount > 0) {
			info.scaledRewardsPerToken += _amount * FLOAT_SCALAR / totalSupply();
			emit Reward(_amount);
		}
	}


	function _isExcludedFromFee(address _from, address _to) internal view returns (bool) {

		return isFromWhitelisted(_from) || isToWhitelisted(_to)
			|| _from == address(this) || _to == address(this)
			|| _from == feeManagerAddress() || _to == feeManagerAddress()
			|| _from == treasuryAddress() || _to == treasuryAddress()
			|| _from == stakingRewardsAddress() || _to == stakingRewardsAddress()
			|| _from == lpStakingRewardsAddress() || _to == lpStakingRewardsAddress();
	}
	
	function _verify(bytes32[] memory _proof, bytes32 _leaf) internal view returns (bool) {

		bytes32 _computedHash = _leaf;
		for (uint256 i = 0; i < _proof.length; i++) {
			bytes32 _proofElement = _proof[i];
			if (_computedHash <= _proofElement) {
				_computedHash = keccak256(abi.encodePacked(_computedHash, _proofElement));
			} else {
				_computedHash = keccak256(abi.encodePacked(_proofElement, _computedHash));
			}
		}
		return _computedHash == merkleRoot();
	}
}