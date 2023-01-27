pragma solidity ^0.8.4;

interface ERC165 {

	function supportsInterface(bytes4 interfaceID) external view returns (bool);

}// MIT
pragma solidity ^0.8.4;


interface ERC721 is ERC165 {

	event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

	event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

	event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

	function balanceOf(address _owner) external view returns (uint256);


	function ownerOf(uint256 _tokenId) external view returns (address);


	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external /*payable*/;


	function safeTransferFrom(address _from, address _to, uint256 _tokenId) external /*payable*/;


	function transferFrom(address _from, address _to, uint256 _tokenId) external /*payable*/;


	function approve(address _approved, uint256 _tokenId) external /*payable*/;


	function setApprovalForAll(address _operator, bool _approved) external;


	function getApproved(uint256 _tokenId) external view returns (address);


	function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

interface ERC721TokenReceiver {

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}

interface ERC721Metadata is ERC721 {

	function name() external view returns (string memory _name);


	function symbol() external view returns (string memory _symbol);


	function tokenURI(uint256 _tokenId) external view returns (string memory);

}

interface ERC721Enumerable is ERC721 {

	function totalSupply() external view returns (uint256);


	function tokenByIndex(uint256 _index) external view returns (uint256);


	function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

}// MIT
pragma solidity ^0.8.4;

interface ERC20 {

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);




	function totalSupply() external view returns (uint256);


	function balanceOf(address _owner) external view returns (uint256 balance);


	function transfer(address _to, uint256 _value) external returns (bool success);


	function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


	function approve(address _spender, uint256 _value) external returns (bool success);


	function allowance(address _owner, address _spender) external view returns (uint256 remaining);

}// MIT
pragma solidity ^0.8.4;

library StringUtils {

	function atoi(string memory a, uint8 base) internal pure returns (uint256 i) {

		require(base == 2 || base == 8 || base == 10 || base == 16);

		bytes memory buf = bytes(a);

		for(uint256 p = 0; p < buf.length; p++) {
			uint8 digit = uint8(buf[p]) - 0x30;

			if(digit > 10) {
				digit -= 7;
			}

			require(digit < base);

			i *= base;

			i += digit;
		}

		return i;
	}

	function itoa(uint256 i, uint8 base) internal pure returns (string memory a) {

		require(base == 2 || base == 8 || base == 10 || base == 16);

		if(i == 0) {
			return "0";
		}

		bytes memory buf = new bytes(256);

		uint256 p = 0;

		while(i > 0) {
			uint8 digit = uint8(i % base);

			uint8 ascii = digit + 0x30;

			if(digit >= 10) {
				ascii += 7;
			}

			buf[p++] = bytes1(ascii);

			i /= base;
		}

		bytes memory result = new bytes(p);

		for(p = 0; p < result.length; p++) {
			result[result.length - p - 1] = buf[p];
		}

		return string(result);
	}

	function concat(string memory s1, string memory s2) internal pure returns (string memory s) {


		return string(abi.encodePacked(s1, s2));
	}
}// MIT
pragma solidity ^0.8.4;

contract AccessControl {

	uint256 public constant ROLE_ACCESS_MANAGER = 0x8000000000000000000000000000000000000000000000000000000000000000;

	uint256 private constant FULL_PRIVILEGES_MASK = type(uint256).max; // before 0.8.0: uint256(-1) overflows to 0xFFFF...

	mapping(address => uint256) public userRoles;

	event RoleUpdated(address indexed _by, address indexed _to, uint256 _requested, uint256 _actual);

	constructor() {
		userRoles[msg.sender] = FULL_PRIVILEGES_MASK;
	}

	function features() public view returns(uint256) {

		return userRoles[address(this)];
	}

	function updateFeatures(uint256 _mask) public {

		updateRole(address(this), _mask);
	}

	function updateRole(address operator, uint256 role) public {

		require(isSenderInRole(ROLE_ACCESS_MANAGER), "access denied");

		userRoles[operator] = evaluateBy(msg.sender, userRoles[operator], role);

		emit RoleUpdated(msg.sender, operator, role, userRoles[operator]);
	}

	function evaluateBy(address operator, uint256 target, uint256 desired) public view returns(uint256) {

		uint256 p = userRoles[operator];

		target |= p & desired;
		target &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ desired));

		return target;
	}

	function isFeatureEnabled(uint256 required) public view returns(bool) {

		return __hasRole(features(), required);
	}

	function isSenderInRole(uint256 required) public view returns(bool) {

		return isOperatorInRole(msg.sender, required);
	}

	function isOperatorInRole(address operator, uint256 required) public view returns(bool) {

		return __hasRole(userRoles[operator], required);
	}

	function __hasRole(uint256 actual, uint256 required) internal pure returns(bool) {

		return actual & required == required;
	}
}// MIT
pragma solidity ^0.8.4;


interface IntelligentNFTv2Spec {

	function name() external view returns (string memory);


	function symbol() external view returns (string memory);


	function tokenURI(uint256 recordId) external view returns (string memory);


	function totalSupply() external view returns (uint256);


	function exists(uint256 recordId) external view returns (bool);


	function ownerOf(uint256 recordId) external view returns (address);

}

contract IntelligentNFTv2 is IntelligentNFTv2Spec, AccessControl, ERC165 {

	string public override name = "Intelligent NFT";

	string public override symbol = "iNFT";

	struct IntelliBinding {
		address personalityContract;

		uint96 personalityId;

		uint96 aliValue;

		address targetContract;

		uint256 targetId;
	}

	mapping(uint256 => IntelliBinding) public bindings;

	mapping(address => mapping(uint256 => uint256)) public reverseBindings;

	mapping(address => mapping(uint256 => uint256)) public personalityBindings;

	uint256 public override totalSupply;

	address public immutable aliContract;

	uint256 public aliBalance;

	string public baseURI = "";

	mapping(uint256 => string) internal _tokenURIs;

	uint32 public constant ROLE_MINTER = 0x0001_0000;

	uint32 public constant ROLE_BURNER = 0x0002_0000;

	uint32 public constant ROLE_EDITOR = 0x0004_0000;

	uint32 public constant ROLE_URI_MANAGER = 0x0010_0000;

	event BaseURIUpdated(address indexed _by, string _oldVal, string _newVal);

	event TokenURIUpdated(address indexed _by, uint256 indexed _tokenId, string _oldVal, string _newVal);

	event Minted(
		address indexed _by,
		address indexed _owner,
		uint256 indexed _recordId,
		uint96 _aliValue,
		address _personalityContract,
		uint96 _personalityId,
		address _targetContract,
		uint256 _targetId
	);

	event Updated(
		address indexed _by,
		address indexed _owner,
		uint256 indexed _recordId,
		uint96 _oldAliValue,
		uint96 _newAliValue
	);

	event Burnt(
		address indexed _by,
		uint256 indexed _recordId,
		address indexed _recipient,
		uint96 _aliValue,
		address _personalityContract,
		uint96 _personalityId,
		address _targetContract,
		uint256 _targetId
	);

	constructor(address _ali) {
		require(_ali != address(0), "ALI Token addr is not set");

		require(ERC165(_ali).supportsInterface(type(ERC20).interfaceId), "unexpected ALI Token type");

		aliContract = _ali;
	}

	function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {

		return interfaceId == type(IntelligentNFTv2Spec).interfaceId;
	}

	function setBaseURI(string memory _baseURI) public virtual {

		require(isSenderInRole(ROLE_URI_MANAGER), "access denied");

		emit BaseURIUpdated(msg.sender, baseURI, _baseURI);

		baseURI = _baseURI;
	}

	function tokenURI(uint256 _recordId) public view override returns (string memory) {

		require(exists(_recordId), "iNFT doesn't exist");

		string memory _tokenURI = _tokenURIs[_recordId];

		if(bytes(_tokenURI).length > 0) {
			return _tokenURI;
		}

		if(bytes(baseURI).length == 0) {
			return "";
		}

		return StringUtils.concat(baseURI, StringUtils.itoa(_recordId, 10));
	}

	function setTokenURI(uint256 _tokenId, string memory _tokenURI) public virtual {

		require(isSenderInRole(ROLE_URI_MANAGER), "access denied");


		emit TokenURIUpdated(msg.sender, _tokenId, _tokenURIs[_tokenId], _tokenURI);

		_tokenURIs[_tokenId] = _tokenURI;
	}

	function exists(uint256 recordId) public view override returns (bool) {

		return bindings[recordId].targetContract != address(0);
	}

	function ownerOf(uint256 recordId) public view override returns (address) {

		IntelliBinding storage binding = bindings[recordId];

		require(binding.targetContract != address(0), "iNFT doesn't exist");

		return ERC721(binding.targetContract).ownerOf(binding.targetId);
	}

	function mint(
		uint256 recordId,
		uint96 aliValue,
		address personalityContract,
		uint96 personalityId,
		address targetContract,
		uint256 targetId
	) public {

		require(isSenderInRole(ROLE_MINTER), "access denied");

		require(ERC165(personalityContract).supportsInterface(type(ERC721).interfaceId), "personality is not ERC721");

		require(ERC165(targetContract).supportsInterface(type(ERC721).interfaceId), "target NFT is not ERC721");

		require(!exists(recordId), "iNFT already exists");

		require(reverseBindings[targetContract][targetId] == 0, "NFT is already bound");

		require(personalityBindings[personalityContract][personalityId] == 0, "personality already linked");

		require(ERC721(personalityContract).ownerOf(personalityId) == address(this), "personality is not yet transferred");

		address owner = ERC721(targetContract).ownerOf(targetId);
		require(owner != address(0), "target NFT doesn't exist");

		if(aliValue > 0) {
			require(aliBalance + aliValue <= ERC20(aliContract).balanceOf(address(this)), "ALI tokens not yet transferred");

			aliBalance += aliValue;
		}

		bindings[recordId] = IntelliBinding({
			personalityContract : personalityContract,
			personalityId : personalityId,
			aliValue : aliValue,
			targetContract : targetContract,
			targetId : targetId
		});

		reverseBindings[targetContract][targetId] = recordId;

		personalityBindings[personalityContract][personalityId] = recordId;

		totalSupply++;

		emit Minted(
			msg.sender,
			owner,
			recordId,
			aliValue,
			personalityContract,
			personalityId,
			targetContract,
			targetId
		);
	}

	function mintBatch(
		uint256 recordId,
		uint96 aliValue,
		address personalityContract,
		uint96 personalityId,
		address targetContract,
		uint256 targetId,
		uint96 n
	) public {

		require(isSenderInRole(ROLE_MINTER), "access denied");

		require(n > 1, "n is too small");

		require(ERC165(personalityContract).supportsInterface(type(ERC721).interfaceId), "personality is not ERC721");

		require(ERC165(targetContract).supportsInterface(type(ERC721).interfaceId), "target NFT is not ERC721");

		for(uint96 i = 0; i < n; i++) {
			require(!exists(recordId + i), "iNFT already exists");

			require(personalityBindings[personalityContract][personalityId + i] == 0, "personality already linked");

			require(ERC721(personalityContract).ownerOf(personalityId + i) == address(this), "personality is not yet transferred");

			address owner = ERC721(targetContract).ownerOf(targetId + i);
			require(owner != address(0), "target NFT doesn't exist");

			emit Minted(
				msg.sender,
				owner,
				recordId + i,
				aliValue,
				personalityContract,
				personalityId + i,
				targetContract,
				targetId + i
			);
		}

		uint256 _aliValue = uint256(aliValue) * n;

		if(_aliValue > 0) {
			require(aliBalance + _aliValue <= ERC20(aliContract).balanceOf(address(this)), "ALI tokens not yet transferred");
			aliBalance += _aliValue;
		}

		for(uint96 i = 0; i < n; i++) {
			bindings[recordId + i] = IntelliBinding({
				personalityContract : personalityContract,
				personalityId : personalityId + i,
				aliValue : aliValue,
				targetContract : targetContract,
				targetId : targetId + i
			});

			personalityBindings[personalityContract][personalityId + i] = recordId + i;

			reverseBindings[targetContract][targetId + i] = recordId + i;
		}

		totalSupply += n;
	}

	function burn(uint256 recordId) public {

		require(isSenderInRole(ROLE_BURNER), "access denied");

		totalSupply--;

		IntelliBinding memory binding = bindings[recordId];

		require(binding.targetContract != address(0), "not bound");

		delete bindings[recordId];

		delete reverseBindings[binding.targetContract][binding.targetId];

		delete personalityBindings[binding.personalityContract][binding.personalityId];

		address owner = ERC721(binding.targetContract).ownerOf(binding.targetId);

		require(owner != address(0), "no such NFT");

		ERC721(binding.personalityContract).safeTransferFrom(address(this), owner, binding.personalityId);

		if(binding.aliValue > 0) {
			aliBalance -= binding.aliValue;

			ERC20(aliContract).transfer(owner, binding.aliValue);
		}

		emit Burnt(
			msg.sender,
			recordId,
			owner,
			binding.aliValue,
			binding.personalityContract,
			binding.personalityId,
			binding.targetContract,
			binding.targetId
		);
	}

	function increaseAli(uint256 recordId, uint96 aliDelta) public {

		require(isSenderInRole(ROLE_EDITOR), "access denied");

		require(aliDelta != 0, "zero value");

		address owner = ownerOf(recordId);

		uint96 aliValue = bindings[recordId].aliValue;

		require(aliBalance + aliDelta <= ERC20(aliContract).balanceOf(address(this)), "ALI tokens not yet transferred");

		aliBalance += aliDelta;

		bindings[recordId].aliValue = aliValue + aliDelta;

		emit Updated(msg.sender, owner, recordId, aliValue, aliValue + aliDelta);
	}

	function decreaseAli(uint256 recordId, uint96 aliDelta, address recipient) public {

		require(isSenderInRole(ROLE_EDITOR), "access denied");

		require(aliDelta != 0, "zero value");
		require(recipient != address(0), "zero address");

		address owner = ownerOf(recordId);

		uint96 aliValue = bindings[recordId].aliValue;

		require(aliValue >= aliDelta, "not enough ALI");

		aliBalance -= aliDelta;

		bindings[recordId].aliValue = aliValue - aliDelta;

		ERC20(aliContract).transfer(recipient, aliDelta);

		emit Updated(msg.sender, owner, recordId, aliValue, aliValue - aliDelta);
	}

	function lockedValue(uint256 recordId) public view returns(uint96) {

		require(exists(recordId), "iNFT doesn't exist");

		return bindings[recordId].aliValue;
	}
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library StorageSlotUpgradeable {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
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

pragma solidity ^0.8.2;


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}// MIT
pragma solidity ^0.8.4;


abstract contract UpgradeableAccessControl is UUPSUpgradeable {
	mapping(address => uint256) public userRoles;

	uint256[49] private __gap;

	uint256 public constant ROLE_ACCESS_MANAGER = 0x8000000000000000000000000000000000000000000000000000000000000000;

	uint256 public constant ROLE_UPGRADE_MANAGER = 0x4000000000000000000000000000000000000000000000000000000000000000;

	uint256 private constant FULL_PRIVILEGES_MASK = type(uint256).max; // before 0.8.0: uint256(-1) overflows to 0xFFFF...

	event RoleUpdated(address indexed _by, address indexed _to, uint256 _requested, uint256 _actual);

	function _postConstruct(address _owner) internal virtual initializer {
		require(!AddressUpgradeable.isContract(address(this)), "invalid context");

		userRoles[_owner] = FULL_PRIVILEGES_MASK;

		emit RoleUpdated(msg.sender, _owner, FULL_PRIVILEGES_MASK, FULL_PRIVILEGES_MASK);
	}

	function getImplementation() public view virtual returns (address) {
		return _getImplementation();
	}

	function features() public view returns (uint256) {
		return userRoles[address(this)];
	}

	function updateFeatures(uint256 _mask) public {
		updateRole(address(this), _mask);
	}

	function updateRole(address operator, uint256 role) public {
		require(isSenderInRole(ROLE_ACCESS_MANAGER), "access denied");

		userRoles[operator] = evaluateBy(msg.sender, userRoles[operator], role);

		emit RoleUpdated(msg.sender, operator, role, userRoles[operator]);
	}

	function evaluateBy(address operator, uint256 target, uint256 desired) public view returns (uint256) {
		uint256 p = userRoles[operator];

		target |= p & desired;
		target &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ desired));

		return target;
	}

	function isFeatureEnabled(uint256 required) public view returns (bool) {
		return __hasRole(features(), required);
	}

	function isSenderInRole(uint256 required) public view returns (bool) {
		return isOperatorInRole(msg.sender, required);
	}

	function isOperatorInRole(address operator, uint256 required) public view returns (bool) {
		return __hasRole(userRoles[operator], required);
	}

	function __hasRole(uint256 actual, uint256 required) internal pure returns (bool) {
		return actual & required == required;
	}

	function _authorizeUpgrade(address) internal virtual override {
		require(isSenderInRole(ROLE_UPGRADE_MANAGER), "access denied");
	}
}// MIT
pragma solidity ^0.8.4;


contract IntelliLinkerV2 is UpgradeableAccessControl {

	address public aliContract;

	address public personalityContract;

	address public iNftContract;

	uint96 public linkPrice;

	uint96 public linkFee;

	address public feeDestination;

	uint256 public nextId;

	mapping(address => uint8) public whitelistedTargetContracts;

	uint32 public constant FEATURE_LINKING = 0x0000_0001;

	uint32 public constant FEATURE_UNLINKING = 0x0000_0002;

	uint32 public constant FEATURE_ALLOW_ANY_NFT_CONTRACT = 0x0000_0004;

	uint32 public constant FEATURE_DEPOSITS = 0x0000_0008;

	uint32 public constant FEATURE_WITHDRAWALS = 0x0000_0010;

	uint32 public constant ROLE_LINK_PRICE_MANAGER = 0x0001_0000;

	uint32 public constant ROLE_NEXT_ID_MANAGER = 0x0002_0000;

	uint32 public constant ROLE_WHITELIST_MANAGER = 0x0004_0000;

	event Linked(
		address indexed _by,
		uint256 _iNftId,
		uint96 _linkPrice,
		uint96 _linkFee,
		address indexed _personalityContract,
		uint96 indexed _personalityId,
		address _targetContract,
		uint256 _targetId
	);

	event Unlinked(address indexed _by, uint256 indexed _iNftId);

	event LinkUpdated(address indexed _by, uint256 indexed _iNftId, int128 _aliDelta, uint96 _feeValue);

	event LinkPriceChanged(address indexed _by, uint96 _linkPrice, uint96 _linkFee, address indexed _feeDestination);

	event NextIdChanged(address indexed _by, uint256 _oldVal, uint256 _newVal);

	event TargetContractWhitelisted(address indexed _by, address indexed _targetContract, uint8 _oldVal, uint8 _newVal);

	function postConstruct(address _ali, address _personality, address _iNft) public virtual initializer {

		require(_ali != address(0), "ALI Token addr is not set");
		require(_personality != address(0), "AI Personality addr is not set");
		require(_iNft != address(0), "iNFT addr is not set");

		require(ERC165(_ali).supportsInterface(type(ERC20).interfaceId), "unexpected ALI Token type");
		require(ERC165(_personality).supportsInterface(type(ERC721).interfaceId), "unexpected AI Personality type");
		require(ERC165(_iNft).supportsInterface(type(IntelligentNFTv2Spec).interfaceId), "unexpected iNFT type");

		aliContract = _ali;
		personalityContract = _personality;
		iNftContract = _iNft;

		nextId = 0x2_0000_0000;

		UpgradeableAccessControl._postConstruct(msg.sender);
	}

	function link(uint96 personalityId, address targetContract, uint256 targetId) public virtual {

		require(isFeatureEnabled(FEATURE_LINKING), "linking is disabled");

		require(ERC721(personalityContract).ownerOf(personalityId) == msg.sender, "access denied");
		require(
			isAllowedForLinking(targetContract) || isFeatureEnabled(FEATURE_ALLOW_ANY_NFT_CONTRACT),
			"not a whitelisted NFT contract"
		);

		if(linkFee > 0) {
			ERC20(aliContract).transferFrom(msg.sender, feeDestination, linkFee);
		}

		if(linkPrice > 0) {
			ERC20(aliContract).transferFrom(msg.sender, iNftContract, linkPrice - linkFee);
		}

		ERC721(personalityContract).transferFrom(msg.sender, iNftContract, personalityId);

		IntelligentNFTv2(iNftContract).mint(nextId++, linkPrice - linkFee, personalityContract, personalityId, targetContract, targetId);

		emit Linked(msg.sender, nextId - 1, linkPrice, linkFee, personalityContract, personalityId, targetContract, targetId);
	}

	function unlink(uint256 iNftId) public virtual {

		require(isFeatureEnabled(FEATURE_UNLINKING), "unlinking is disabled");

		IntelligentNFTv2 iNFT = IntelligentNFTv2(iNftContract);

		(,,,address targetContract,) = iNFT.bindings(iNftId);
		require(
			isAllowedForUnlinking(targetContract) || isFeatureEnabled(FEATURE_ALLOW_ANY_NFT_CONTRACT),
			"not a whitelisted NFT contract"
		);

		require(iNFT.ownerOf(iNftId) == msg.sender, "not an iNFT owner");

		iNFT.burn(iNftId);

		emit Unlinked(msg.sender, iNftId);
	}

	function unlinkNFT(address nftContract, uint256 nftId) public virtual {

		require(isFeatureEnabled(FEATURE_UNLINKING), "unlinking is disabled");

		IntelligentNFTv2 iNFT = IntelligentNFTv2(iNftContract);

		require(ERC721(nftContract).ownerOf(nftId) == msg.sender, "not an NFT owner");

		uint256 iNftId = iNFT.reverseBindings(nftContract, nftId);

		require(
			isAllowedForUnlinking(nftContract) || isFeatureEnabled(FEATURE_ALLOW_ANY_NFT_CONTRACT),
			"not a whitelisted NFT contract"
		);

		iNFT.burn(iNftId);

		emit Unlinked(msg.sender, iNftId);
	}

	function deposit(uint256 iNftId, uint96 aliValue) public virtual {

		require(isFeatureEnabled(FEATURE_DEPOSITS), "deposits are disabled");

		IntelligentNFTv2 iNFT = IntelligentNFTv2(iNftContract);

		require(iNFT.ownerOf(iNftId) == msg.sender, "not an iNFT owner");

		uint96 _linkFee = 0;
		uint96 _aliValue = aliValue;
		if(linkPrice != 0 && linkFee != 0) {
			_linkFee = uint96(uint256(_aliValue) * linkFee / linkPrice);

			_aliValue = aliValue - _linkFee;

			ERC20(aliContract).transferFrom(msg.sender, feeDestination, _linkFee);
		}

		ERC20(aliContract).transferFrom(msg.sender, iNftContract, _aliValue);

		iNFT.increaseAli(iNftId, _aliValue);

		emit LinkUpdated(msg.sender, iNftId, int128(uint128(_aliValue)), _linkFee);
	}

	function withdraw(uint256 iNftId, uint96 aliValue) public virtual {

		require(isFeatureEnabled(FEATURE_WITHDRAWALS), "withdrawals are disabled");

		IntelligentNFTv2 iNFT = IntelligentNFTv2(iNftContract);

		require(iNFT.ownerOf(iNftId) == msg.sender, "not an iNFT owner");

		require(iNFT.lockedValue(iNftId) >= aliValue + linkPrice, "deposit too low");

		iNFT.decreaseAli(iNftId, aliValue, msg.sender);

		emit LinkUpdated(msg.sender, iNftId, -int128(uint128(aliValue)), 0);
	}

	function updateLinkPrice(uint96 _linkPrice, uint96 _linkFee, address _feeDestination) public virtual {

		require(isSenderInRole(ROLE_LINK_PRICE_MANAGER), "access denied");

		require(_linkPrice == 0 || _linkPrice >= 1e12, "invalid price");

		require(_linkFee == 0 && _feeDestination == address(0) || _linkFee >= 1e12 && _feeDestination != address(0), "invalid linking fee/treasury");
		require(_linkFee <= _linkPrice, "linking fee exceeds linking price");

		linkPrice = _linkPrice;
		linkFee = _linkFee;
		feeDestination = _feeDestination;

		emit LinkPriceChanged(msg.sender, _linkPrice, _linkFee, _feeDestination);
	}

	function updateNextId(uint256 _nextId) public virtual {

		require(isSenderInRole(ROLE_NEXT_ID_MANAGER), "access denied");

		require(_nextId > 0xFFFF_FFFF, "value too low");

		emit NextIdChanged(msg.sender, nextId, _nextId);

		nextId = _nextId;
	}

	function whitelistTargetContract(
		address targetContract,
		bool allowedForLinking,
		bool allowedForUnlinking
	) public virtual {

		require(isSenderInRole(ROLE_WHITELIST_MANAGER), "access denied");

		require(targetContract != address(0), "zero address");

		if(allowedForLinking) {
			require(ERC165(targetContract).supportsInterface(type(ERC721).interfaceId), "target NFT is not ERC721");
		}

		uint8 newVal = (allowedForLinking? 0x1: 0x0) | (allowedForUnlinking? 0x2: 0x0);

		emit TargetContractWhitelisted(msg.sender, targetContract, whitelistedTargetContracts[targetContract], newVal);

		whitelistedTargetContracts[targetContract] = newVal;
	}

	function isAllowedForLinking(address targetContract) public view virtual returns (bool) {

		return whitelistedTargetContracts[targetContract] & 0x1 == 0x1;
	}

	function isAllowedForUnlinking(address targetContract) public view virtual returns (bool) {

		return whitelistedTargetContracts[targetContract] & 0x2 == 0x2;
	}
}