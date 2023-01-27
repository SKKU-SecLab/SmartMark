
pragma solidity ^0.8.13;


error Address_InsufficientBalance(uint256 balance, uint256 amount);
error Address_UnableToSendValue(address recipient, uint256 amount);
error Address_CallToNonContract(address target);
error Address_StaticCallToNonContract(address target);

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        if (address(this).balance < amount) revert Address_InsufficientBalance(address(this).balance, amount);

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert Address_UnableToSendValue(recipient, amount);
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

        if (address(this).balance < value) revert Address_InsufficientBalance(address(this).balance, value);
        if (!isContract(target)) revert Address_CallToNonContract(target);

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

        if (!isContract(target)) revert Address_StaticCallToNonContract(target);

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

pragma solidity ^0.8.13;



error Initializable_AlreadyInitialized();
error Initializable_NotInitializing();

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        if(_initializing ? !_isConstructor() : _initialized) revert Initializable_AlreadyInitialized();

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
        if (!_initializing) revert Initializable_NotInitializing();
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.13;

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

pragma solidity ^0.8.13;



error Ownable_CallerNotOwner(address caller, address owner);
error Ownable_NewOwnerZeroAddress();

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
        if (owner() != _msgSender()) revert Ownable_CallerNotOwner(_msgSender(), owner());
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert Ownable_NewOwnerZeroAddress();
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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

library Base64Upgradeable {

    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return "";

        string memory table = _TABLE;

        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            let tablePtr := add(table, 1)

            let resultPtr := add(result, 32)

            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)


                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}// MIT
pragma solidity ^0.8.13;

interface ILabGame {

	function getToken(uint256 _tokenId) external view returns (uint256);

	function balanceOf(address _account) external view returns (uint256);

	function tokenOfOwnerByIndex(address _account, uint256 _index) external view returns (uint256);

	function ownerOf(uint256 _tokenId) external view returns (address);

}// MIT
pragma solidity ^0.8.13;



contract Metadata is OwnableUpgradeable {

	using StringsUpgradeable for uint256;
	using Base64Upgradeable for bytes;

	uint256 constant MAX_TRAITS = 16;
	uint256 constant TYPE_OFFSET = 9;

	string constant TYPE0_NAME = "Scientist";
	string constant TYPE1_NAME = "Mutant";
	string constant DESCRIPTION = "5,000 Scientists and Mutants walking around The Laboratory, producing and stealing the ultimate prize, $SERUM.";
	string constant IMAGE_WIDTH = "50";
	string constant IMAGE_HEIGHT = "50";

	struct Trait {
		string name;
		string image;
	}
	mapping(uint256 => mapping(uint256 => Trait)) traits;

	ILabGame labGame;

	function initialize() public initializer {

		__Ownable_init();
	}


	function tokenURI(uint256 _tokenId) external view returns (string memory) {

		uint256 token = labGame.getToken(_tokenId);
		return string(abi.encodePacked(
			'data:application/json;base64,',
			abi.encodePacked(
				'{"name":"', (token & 128 != 0) ? TYPE1_NAME : TYPE0_NAME, ' #', _tokenId.toString(),
				'","description":"', DESCRIPTION,
				'","image":"data:image/svg+xml;base64,', _image(token).encode(),
				'","attributes":', _attributes(token),
				'}'
			).encode()
		));
	}


	function _image(uint256 _token) internal view returns (bytes memory) {

		(uint256 start, uint256 count) = (_token & 128 != 0) ? (TYPE_OFFSET, MAX_TRAITS - TYPE_OFFSET) : (0, TYPE_OFFSET);
		bytes memory images;
		for (uint256 i; i < count; i++) {
			images = abi.encodePacked(
				images,
				'<image x="0" y="0" width="', IMAGE_WIDTH, '" height="', IMAGE_HEIGHT, '" image-rendering="pixelated" preserveAspectRatio="xMidYMid" href="data:image/png;base64,',
				traits[start + i][(_token >> (8 * i + 8)) & 0xFF].image,
				'"/>'
			);
		}
		return abi.encodePacked(
			'<svg id="LabGame-', _token.toString(), '" width="100%" height="100%" viewBox="0 0 ', IMAGE_WIDTH, ' ', IMAGE_HEIGHT, '" xmlns="http://www.w3.org/2000/svg">',
			images,
			'</svg>'
		);
	}

	function _attributes(uint256 _token) internal view returns (bytes memory) {

		string[MAX_TRAITS] memory TRAIT_NAMES = [
			"Background",
			"Skin",
			"Pants",
			"Shirt",
			"Lab Coat",
			"Shoes",
			"Hair",
			"Eyes",
			"Mouth",
			"Background",
			"Body",
			"Pants",
			"Mutated Body",
			"Eyes",
			"Mouth",
			"Shoes"
		];

		(uint256 start, uint256 count) = (_token & 128 != 0) ? (TYPE_OFFSET, MAX_TRAITS - TYPE_OFFSET) : (0, TYPE_OFFSET);
		bytes memory attributes;
		for (uint256 i; i < count; i++) {
			attributes = abi.encodePacked(
				attributes,
				'{"trait_type":"',
				TRAIT_NAMES[start + i],
				'","value":"',
				traits[start + i][(_token >> (8 * i + 8)) & 0xFF].name,
				'"},'
			);
		}
		return abi.encodePacked(
			'[', attributes,
			'{"trait_type":"Generation", "value":"', (_token & 3).toString(), '"},',
			'{"trait_type":"Type","value":"', (_token & 128 != 0) ? TYPE1_NAME : TYPE0_NAME, '"}]'
		);
	}

	
	function setTraits(uint256 _layer, Trait[] calldata _traits) external onlyOwner {

		for (uint256 i; i < _traits.length; i++)
			traits[_layer][i] = _traits[i];
	}
	
	function setTrait(uint256 _layer, uint256 _trait, Trait calldata _data) external onlyOwner {

		traits[_layer][_trait] = _data;
	}

	function setLabGame(address _labGame) external onlyOwner {

		labGame = ILabGame(_labGame);
	}
}