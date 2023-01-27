
pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// give the contract some SVG Code

pragma solidity ^0.8.6;

contract AccessControlUpgradeable is OwnableUpgradeable {

	mapping(address => bool) private _admins;

	event AdminAccessSet(address indexed admin, bool enabled);

	function _setAdmin(address _admin, bool enabled) internal {

		_admins[_admin] = enabled;
		emit AdminAccessSet(_admin, enabled);
	}

	function setAdmin(address[] memory __admins, bool enabled)
		external
		onlyOwner
	{

		for (uint256 index = 0; index < __admins.length; index++) {
			_setAdmin(__admins[index], enabled);
		}
	}

	function isAdmin(address _admin) public view returns (bool) {

		return _admins[_admin];
	}

	modifier onlyAdmin() {

		require(
			isAdmin(_msgSender()) || _msgSender() == owner(),
			'Caller does not have admin access'
		);
		_;
	}
}// MIT
pragma solidity ^0.8.6;


contract AccessControlWithUpdater is AccessControlUpgradeable {

	mapping(address => bool) private _updateAdmins;

	event UpdateAccessSet(address indexed updateAdmin, bool enabled);

	function setUpdateAccess(address _updateAdmin, bool enabled)
		external
		onlyOwner
	{

		_updateAdmins[_updateAdmin] = enabled;
		emit AdminAccessSet(_updateAdmin, enabled);
	}

	function isUpdateAdmin(address _admin) public view returns (bool) {

		return _updateAdmins[_admin];
	}

	modifier onlyUpdateAdmin() {

		require(
			isUpdateAdmin(_msgSender()) ||
				isAdmin(_msgSender()) ||
				_msgSender() == owner(),
			'Caller does not have admin access'
		);
		_;
	}
}// MIT
pragma solidity ^0.8.6;

abstract contract IBaseNFT {
	struct Metadata {
		string name;
		string description;
	}

	function setTokenDescriptor(address __tokenDescriptor) public virtual;

	function setDefaults(
		string memory _defaultName,
		string memory _defaultDescription
	) public virtual;

	function setNumFeatures(uint256 _numFeatures) external virtual;

	function setFeatureNameBatch(
		uint256[] memory indices,
		string[] memory _featureNames
	) external virtual;

	function setTokenIndices(uint256 tokenId, uint256[2] memory indices)
		public
		virtual;

	function metadata(uint256 tokenId)
		public
		view
		virtual
		returns (Metadata memory m);

	function getAttributes(uint256 tokenId)
		public
		view
		virtual
		returns (string[] memory featureNamesArr, uint256[] memory valuesArr);

	function setMetadata(Metadata memory m, uint256 tokenId) public virtual;

	function updateFeatureValueBatch(
		uint256[] memory _tokenIds,
		string[] memory _featureNames,
		uint256[] memory _newValues
	) public virtual;

	function exists(uint256 tokenId) public view virtual returns (bool);

	uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.6;

abstract contract BaseNFT is AccessControlWithUpdater, IBaseNFT {
	using CountersUpgradeable for CountersUpgradeable.Counter;

	CountersUpgradeable.Counter public tokenIds;

	uint256 public numFeatures;

	uint256[2] public defaultIndices;

	mapping(uint256 => string) public featureNames;
	mapping(uint256 => mapping(string => uint256)) public values;

	uint256 public defaultValue;

	mapping(uint256 => Metadata) internal _metadata;

	mapping(uint256 => uint256[2]) internal _tokenIndices;

	address public tokenDescriptor;

	string public defaultName;

	string public defaultDescription;

	event SetNumFeatures(uint256 numFeatures);
	event UpdateFeatures(
		uint256 indexed tokenId,
		string featureName,
		uint256 oldValue,
		uint256 newValue
	);
	event SetTokenDescriptor(address tokenDescriptor);
	event SetFeatureName(uint256 index, bytes32 name);
	event SetTokenIndices(uint256 indexed tokenId, uint256 start, uint256 end);

	function setTokenDescriptor(address __tokenDescriptor)
		public
		override
		onlyAdmin
	{
		tokenDescriptor = __tokenDescriptor;
		emit SetTokenDescriptor(tokenDescriptor);
	}

	function setDefaults(
		string memory _defaultName,
		string memory _defaultDescription
	) public override onlyAdmin {
		defaultName = _defaultName;
		defaultDescription = _defaultDescription;
	}

	function setNumFeatures(uint256 _numFeatures) external override onlyAdmin {
		numFeatures = _numFeatures;
		emit SetNumFeatures(numFeatures);
	}

	function setFeatureNameBatch(
		uint256[] memory indices,
		string[] memory _featureNames
	) external override onlyAdmin {
		require(indices.length == _featureNames.length, 'Length mismatch');
		for (uint256 index = 0; index < _featureNames.length; index++) {
			require(
				indices[index] < numFeatures,
				'Index should be less than numFeatures'
			);
			featureNames[indices[index]] = _featureNames[index];
			emit SetFeatureName(
				indices[index],
				keccak256(bytes(_featureNames[index]))
			);
		}
	}

	function setTokenIndices(uint256 tokenId, uint256[2] memory indices)
		public
		override
		onlyUpdateAdmin
	{
		require(exists(tokenId), 'Query for non-existent token');
		_tokenIndices[tokenId] = indices;
		emit SetTokenIndices(tokenId, indices[0], indices[1]);
	}

	function metadata(uint256 tokenId)
		public
		view
		virtual
		override
		returns (Metadata memory m)
	{
		require(exists(tokenId), 'Query for non-existent token');
		m = _metadata[tokenId];
		if (bytes(m.name).length > 0) {
			return m;
		} else {
			return Metadata(defaultName, defaultDescription);
		}
	}

	function totalSupply() public view returns (uint256) {
		return tokenIds.current();
	}

	function getAttributes(uint256 tokenId)
		public
		view
		virtual
		override
		returns (string[] memory featureNamesArr, uint256[] memory valuesArr)
	{
		require(exists(tokenId), 'Query for non-existent token');
		featureNamesArr = new string[](numFeatures);
		valuesArr = new uint256[](numFeatures);

		for (uint256 i = 0; i < numFeatures; i++) {
			featureNamesArr[i] = featureNames[i];
			valuesArr[i] = values[tokenId][featureNamesArr[i]];
			if (valuesArr[i] == 0) {
				valuesArr[i] = defaultValue;
			}
		}
	}

	function setMetadata(Metadata memory m, uint256 tokenId)
		public
		virtual
		override
		onlyAdmin
	{
		require(exists(tokenId), 'Query for non-existent token');
		_metadata[tokenId] = m;
	}

	function updateFeatureValueBatch(
		uint256[] memory _tokenIds,
		string[] memory _featureNames,
		uint256[] memory _newValues
	) public virtual override onlyUpdateAdmin {
		for (uint256 index = 0; index < _tokenIds.length; index++) {
			require(exists(_tokenIds[index]), 'Query for non-existent token');
			uint256 oldValue = values[_tokenIds[index]][_featureNames[index]];

			values[_tokenIds[index]][_featureNames[index]] = _newValues[index];

			emit UpdateFeatures(
				_tokenIds[index],
				_featureNames[index],
				oldValue,
				_newValues[index]
			);
		}
	}

	function feature(uint256 tokenId, string memory featureName)
		external
		view
		returns (uint256)
	{
		require(exists(tokenId), 'Query for non-existent token');
		if (values[tokenId][featureName] == 0) {
			return defaultValue;
		}
		return values[tokenId][featureName];
	}

	function setDefaultIndices(uint256[2] memory _indices) external onlyAdmin {
		defaultIndices[0] = _indices[0];
		defaultIndices[1] = _indices[1];
	}

	function setDefaultValuesForFeatures(uint256 _value) public onlyAdmin {
		defaultValue = _value;
	}

	function exists(uint256 tokenId)
		public
		view
		virtual
		override
		returns (bool);

	uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.6;


interface ISVG721 {

	function updateFeatureValueBatch(
		uint256[] memory tokenId,
		string[] memory featureName,
		uint256[] memory newValue
	) external;


	function metadata(uint256 tokenId)
		external
		view
		returns (IBaseNFT.Metadata memory m);


	function getAttributes(uint256 tokenId)
		external
		view
		returns (string[] memory featureNames, uint256[] memory values);


	function exists(uint256 tokenId) external view returns (bool);


	function setMetadata(IBaseNFT.Metadata memory m, uint256 tokenId) external;


	function mint(address to) external returns (uint256);

}// MIT
pragma solidity ^0.8.6;

interface ITokenDescriptor {

	function tokenURI(uint256 tokenId, uint256[2] memory indices)
		external
		view
		returns (string memory);

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
pragma solidity ^0.8.6;



contract TokenDescriptor is ITokenDescriptor, AccessControlUpgradeable {

	using Strings for uint256;

	ISVG721 public SVG721;
	event SVG721Set(address indexed _SVG721);

	mapping(uint256 => string) public svgSprites;
	uint256 public numberOfSprites;

	function initialize() public initializer {

		__Ownable_init();
	}

	function setSVG721(address _SVG721) external onlyOwner {

		SVG721 = ISVG721(_SVG721);
		emit SVG721Set(_SVG721);
	}

	function setSVGSprites(uint256 _numberOfSprites) external onlyAdmin {

		numberOfSprites = _numberOfSprites;
	}

	function setSVGSprite(uint256 _index, string memory _sprite)
		external
		onlyAdmin
	{

		svgSprites[_index] = _sprite;
	}

	function tokenURI(uint256 tokenId, uint256[2] memory indices)
		external
		view
		override
		returns (string memory)
	{

		IBaseNFT.Metadata memory m = SVG721.metadata(tokenId);
		string memory baseURL = 'data:application/json;base64,';
		return
			string(
				abi.encodePacked(
					baseURL,
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "',
								m.name,
								' #',
								tokenId.toString(),
								'",',
								'"description": "',
								m.description,
								'",',
								'"attributes": ',
								attributes(tokenId),
								',',
								'"image": "',
								imageURI(tokenId, indices),
								'"}'
							)
						)
					)
				)
			);
	}

	function imageURI(uint256, uint256[2] memory indices)
		public
		view
		virtual
		returns (string memory image)
	{

		bytes memory b;
		for (uint256 i = indices[0]; i < indices[1]; i++) {
			b = abi.encodePacked(b, svgSprites[i]);
		}
		if (b.length > 0) b = abi.encodePacked(b, '</svg>');
		return
			string(
				abi.encodePacked('data:image/svg+xml;base64,', Base64.encode(b))
			);
	}

	function attributes(uint256 tokenId)
		public
		view
		returns (string memory returnAttributes)
	{

		bytes memory b = abi.encodePacked('[');
		(string[] memory featureNames, uint256[] memory values) = SVG721
			.getAttributes(tokenId);
		for (uint256 index = 0; index < featureNames.length; index++) {
			b = abi.encodePacked(
				b,
				'{"trait_type": "',
				featureNames[index],
				'",',
				'"value": "',
				values[index].toString(),
				'","display_type": "number"}'
			);
			if (index != featureNames.length - 1) {
				b = abi.encodePacked(b, ',');
			}
		}
		b = abi.encodePacked(b, ']');
		returnAttributes = string(b);
	}
}