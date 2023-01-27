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

	function onERC721Received(
		address _operator,
		address _from,
		uint256 _tokenId,
		bytes calldata _data
	) external returns (bytes4);

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

interface MintableERC721 {

	function exists(uint256 _tokenId) external view returns (bool);


	function mint(address _to, uint256 _tokenId) external;


	function safeMint(address _to, uint256 _tokenId) external;


	function safeMint(address _to, uint256 _tokenId, bytes memory _data) external;


}

interface BatchMintable {

	function mintBatch(address _to, uint256 _tokenId, uint256 n) external;


	function safeMintBatch(address _to, uint256 _tokenId, uint256 n) external;


	function safeMintBatch(address _to, uint256 _tokenId, uint256 n, bytes memory _data) external;

}

interface BurnableERC721 {

	function burn(uint256 _tokenId) external;

}// MIT
pragma solidity ^0.8.4;

library LandLib {

	struct Site {
		uint8 typeId;

		uint16 x;

		uint16 y;
	}

	struct PlotView {
		uint8 regionId;

		uint16 x;

		uint16 y;

		uint8 tierId;

		uint16 size;

		uint8 landmarkTypeId;

		uint8 elementSites;

		uint8 fuelSites;

		Site[] sites;
	}

	struct PlotStore {
		uint8 version;

		uint8 regionId;

		uint16 x;

		uint16 y;

		uint8 tierId;

		uint16 size;

		uint8 landmarkTypeId;

		uint8 elementSites;

		uint8 fuelSites;

		uint160 seed;
	}

	function pack(PlotStore memory store) internal pure returns (uint256 packed) {

		return uint256(store.version) << 248
			| uint248(store.regionId) << 240
			| uint240(store.x) << 224
			| uint224(store.y) << 208
			| uint208(store.tierId) << 200
			| uint200(store.size) << 184
			| uint184(store.landmarkTypeId) << 176
			| uint176(store.elementSites) << 168
			| uint168(store.fuelSites) << 160
			| uint160(store.seed);
	}

	function unpack(uint256 packed) internal pure returns (PlotStore memory store) {

		return PlotStore({
			version:        uint8(packed >> 248),
			regionId:       uint8(packed >> 240),
			x:              uint16(packed >> 224),
			y:              uint16(packed >> 208),
			tierId:         uint8(packed >> 200),
			size:           uint16(packed >> 184),
			landmarkTypeId: uint8(packed >> 176),
			elementSites:   uint8(packed >> 168),
			fuelSites:      uint8(packed >> 160),
			seed:           uint160(packed)
		});
	}

	function plotView(PlotStore memory store) internal pure returns (PlotView memory) {

		return PlotView({
			regionId:       store.regionId,
			x:              store.x,
			y:              store.y,
			tierId:         store.tierId,
			size:           store.size,
			landmarkTypeId: store.landmarkTypeId,
			elementSites:   store.elementSites,
			fuelSites:      store.fuelSites,
			sites:          getResourceSites(store.seed, store.elementSites, store.fuelSites, store.size, 2)
		});
	}

	function getResourceSites(
		uint256 seed,
		uint8 elementSites,
		uint8 fuelSites,
		uint16 gridSize,
		uint8 siteSize
	) internal pure returns (Site[] memory sites) {

		uint8 totalSites = elementSites + fuelSites;


		uint16 normalizedSize = gridSize / siteSize;

		normalizedSize = (normalizedSize - 2) / 2 * 2;

		uint16[] memory coords;
		(seed, coords) = getCoords(seed, totalSites, normalizedSize * (1 + normalizedSize / 2) - 4);

		sites = new Site[](totalSites);

		uint16 typeId;
		uint16 x;
		uint16 y;

		for(uint8 i = 0; i < totalSites; i++) {
			(seed, typeId) = nextRndUint16(seed, i < elementSites? 1: 4, 3);

			x = coords[i] % normalizedSize;
			y = coords[i] / normalizedSize;

			if(2 * (1 + x + y) < normalizedSize) {
				x += normalizedSize / 2;
				y += 1 + normalizedSize / 2;
			}
			else if(2 * x > normalizedSize && 2 * x > 2 * y + normalizedSize) {
				x -= normalizedSize / 2;
				y += 1 + normalizedSize / 2;
			}

			if(x >= normalizedSize / 2 - 1 && x <= normalizedSize / 2
			&& y >= normalizedSize / 2 - 1 && y <= normalizedSize / 2) {
				x += 5 * normalizedSize / 2 - 2 * (x + y) - 4;
				y = normalizedSize / 2;
			}

			uint16 offset = gridSize / siteSize % 2 + gridSize % siteSize;

			sites[i] = Site({
				typeId: uint8(typeId),
				x: (1 + x) * siteSize + offset,
				y: (1 + y) * siteSize + offset
			});
		}

		return sites;
	}

	function getLandmark(uint256 seed, uint8 tierId) internal pure returns (uint8 landmarkTypeId) {

		if(tierId == 3) {
			return uint8(1 + seed % 3);
		}
		if(tierId == 4) {
			return uint8(4 + seed % 3);
		}
		if(tierId == 5) {
			return 7;
		}

		return 0;
	}

	function getCoords(
		uint256 seed,
		uint8 length,
		uint16 size
	) internal pure returns (uint256 nextSeed, uint16[] memory coords) {

		coords = new uint16[](length);

		for(uint8 i = 0; i < coords.length; i++) {
			(seed, coords[i]) = nextRndUint16(seed, 0, size);
		}

		sort(coords);

		for(int256 i = findDup(coords); i >= 0; i = findDup(coords)) {
			(seed, coords[uint256(i)]) = nextRndUint16(seed, 0, size);
			sort(coords);
		}

		seed = shuffle(seed, coords);

		return (seed, coords);
	}

	function nextRndUint16(
		uint256 seed,
		uint16 offset,
		uint16 options
	) internal pure returns (
		uint256 nextSeed,
		uint16 rndVal
	) {

		nextSeed = uint256(keccak256(abi.encodePacked(seed)));

		rndVal = offset + uint16(nextSeed % options);

		return (nextSeed, rndVal);
	}


	function loc(PlotStore memory plot) internal pure returns (uint40) {

		return uint40(plot.regionId) << 32 | uint32(plot.y) << 16 | plot.x;
	}


	function findDup(uint16[] memory arr) internal pure returns (int256 index) {

		for(uint256 i = 1; i < arr.length; i++) {
			if(arr[i - 1] >= arr[i]) {
				return int256(i - 1);
			}
		}

		return -1;
	}

	function shuffle(uint256 seed, uint16[] memory arr) internal pure returns(uint256 nextSeed) {

		uint16 j;

		for(uint16 i = 0; i < arr.length; i++) {
			(seed, j) = nextRndUint16(seed, 0, uint16(arr.length));

			(arr[i], arr[j]) = (arr[j], arr[i]);
		}

		return seed;
	}

	function sort(uint16[] memory arr) internal pure {

		quickSort(arr, 0, int256(arr.length) - 1);
	}

	function quickSort(uint16[] memory arr, int256 left, int256 right) private pure {

		int256 i = left;
		int256 j = right;
		if(i >= j) {
			return;
		}
		uint16 pivot = arr[uint256(left + (right - left) / 2)];
		while(i <= j) {
			while(arr[uint256(i)] < pivot) {
				i++;
			}
			while(pivot < arr[uint256(j)]) {
				j--;
			}
			if(i <= j) {
				(arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)], arr[uint256(i)]);
				i++;
				j--;
			}
		}
		if(left < j) {
			quickSort(arr, left, j);
		}
		if(i < right) {
			quickSort(arr, i, right);
		}
	}
}// MIT
pragma solidity ^0.8.4;


interface LandERC721Metadata {

	function viewMetadata(uint256 _tokenId) external view returns (LandLib.PlotView memory);


	function getMetadata(uint256 _tokenId) external view returns (LandLib.PlotStore memory);


	function hasMetadata(uint256 _tokenId) external view returns (bool);


	function setMetadata(uint256 _tokenId, LandLib.PlotStore memory _plot) external;


	function removeMetadata(uint256 _tokenId) external;


	function mintWithMetadata(address _to, uint256 _tokenId, LandLib.PlotStore memory _plot) external;

}

interface LandDescriptor {

	function tokenURI(uint256 _tokenId) external view returns (string memory);

}// MIT
pragma solidity ^0.8.4;

interface IdentifiableToken {

	function TOKEN_UID() external view returns (uint256);

}// MIT
pragma solidity ^0.8.4;

interface PairOracle {

	function update() external;


	function consult(address token, uint256 amountIn) external view returns (uint256 amountOut);

}

interface PriceOracleRegistry {

	function getPriceOracle(address tokenA, address tokenB) external view returns (address pairOracle);

}

interface LandSalePriceOracle {

	function ethToIlv(uint256 ethOut) external returns (uint256 ilvIn);

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
pragma solidity ^0.8.4;


library SafeERC20 {

	using Address for address;

	function safeTransfer(ERC20 token, address to, uint256 value) internal {

		_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

	function _callOptionalReturn(ERC20 token, bytes memory data) private {


		bytes memory retData = address(token).functionCall(data, "ERC20 low-level call failed");
		if(retData.length > 0) {
			require(abi.decode(retData, (bool)), "ERC20 transfer failed");
		}
	}
}// MIT

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

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

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT
pragma solidity ^0.8.4;


contract LandSale is UpgradeableAccessControl {

	using SafeERC20 for ERC20;
	using MerkleProof for bytes32[];
	using LandLib for LandLib.PlotStore;

	struct PlotData {
		uint32 tokenId;
		uint32 sequenceId;
		uint8 regionId;
		uint16 x;
		uint16 y;
		uint8 tierId;
		uint16 size;
	}

	address public targetNftContract;

	address public sIlvContract;

	address public priceOracle;

	bytes32 public root;

	uint32 public saleStart;

	uint32 public saleEnd;

	uint32 public halvingTime;

	uint32 public timeFlowQuantum;

	uint32 public seqDuration;

	uint32 public seqOffset;

	uint32 public pausedAt;

	uint32 public pauseDuration;

	uint96[] public startPrices;

	address payable public beneficiary;

	mapping(uint256 => uint256) public mintedTokens;

	uint32 public constant FEATURE_L1_SALE_ACTIVE = 0x0000_0001;

	uint32 public constant FEATURE_L2_SALE_ACTIVE = 0x0000_0002;

	uint32 public constant ROLE_PAUSE_MANAGER = 0x0001_0000;

	uint32 public constant ROLE_DATA_MANAGER = 0x0002_0000;

	uint32 public constant ROLE_SALE_MANAGER = 0x0004_0000;

	uint32 public constant ROLE_RESCUE_MANAGER = 0x0008_0000;

	uint32 public constant ROLE_WITHDRAWAL_MANAGER = 0x0010_0000;

	event RootChanged(address indexed _by, bytes32 _root);

	event Initialized(
		address indexed _by,
		uint32 _saleStart,
		uint32 _saleEnd,
		uint32 _halvingTime,
		uint32 _timeFlowQuantum,
		uint32 _seqDuration,
		uint32 _seqOffset,
		uint96[] _startPrices
	);

	event Paused(address indexed _by, uint32 _pausedAt);

	event Resumed(address indexed _by, uint32 _pausedAt, uint32 _resumedAt, uint32 _pauseDuration);

	event BeneficiaryUpdated(address indexed _by, address indexed _beneficiary);

	event Withdrawn(address indexed _by, address indexed _to, uint256 _eth, uint256 _sIlv);

	event PlotBoughtL1(
		address indexed _by,
		uint32 indexed _tokenId,
		uint32 indexed _sequenceId,
		LandLib.PlotStore _plot,
		uint256 _eth,
		uint256 _sIlv
	);

	event PlotBoughtL2(
		address indexed _by,
		uint32 indexed _tokenId,
		uint32 indexed _sequenceId,
		LandLib.PlotStore _plot,
		uint256 _plotPacked,
		uint256 _eth,
		uint256 _sIlv
	);

	function postConstruct(address _nft, address _sIlv, address _oracle) public virtual initializer {

		require(_nft != address(0), "target contract is not set");
		require(_sIlv != address(0), "sILV contract is not set");
		require(_oracle != address(0), "oracle address is not set");

		require(
			ERC165(_nft).supportsInterface(type(ERC721).interfaceId)
			&& ERC165(_nft).supportsInterface(type(MintableERC721).interfaceId)
			&& ERC165(_nft).supportsInterface(type(LandERC721Metadata).interfaceId),
			"unexpected target type"
		);
		require(ERC165(_oracle).supportsInterface(type(LandSalePriceOracle).interfaceId), "unexpected oracle type");
		require(ERC20(_sIlv).balanceOf(address(this)) < type(uint256).max, "sILV.balanceOf failure");
		require(ERC20(_sIlv).transfer(address(0x1), 0), "sILV.transfer failure");
		require(ERC20(_sIlv).transferFrom(address(this), address(0x1), 0), "sILV.transferFrom failure");

		targetNftContract = _nft;
		sIlvContract = _sIlv;
		priceOracle = _oracle;

		UpgradeableAccessControl._postConstruct(msg.sender);
	}

	function getStartPrices() public view virtual returns (uint96[] memory) {

		return startPrices;
	}

	function setInputDataRoot(bytes32 _root) public virtual {

		require(isSenderInRole(ROLE_DATA_MANAGER), "access denied");

		root = _root;

		emit RootChanged(msg.sender, _root);
	}

	function isPlotValid(PlotData memory plotData, bytes32[] memory proof) public view virtual returns (bool) {

		bytes32 leaf = keccak256(abi.encodePacked(
				plotData.tokenId,
				plotData.sequenceId,
				plotData.regionId,
				plotData.x,
				plotData.y,
				plotData.tierId,
				plotData.size
			));

		return proof.verify(root, leaf);
	}

	function initialize(
		uint32 _saleStart,           // <<<--- keep type in sync with the body type(uint32).max !!!
		uint32 _saleEnd,             // <<<--- keep type in sync with the body type(uint32).max !!!
		uint32 _halvingTime,         // <<<--- keep type in sync with the body type(uint32).max !!!
		uint32 _timeFlowQuantum,     // <<<--- keep type in sync with the body type(uint32).max !!!
		uint32 _seqDuration,         // <<<--- keep type in sync with the body type(uint32).max !!!
		uint32 _seqOffset,           // <<<--- keep type in sync with the body type(uint32).max !!!
		uint96[] memory _startPrices // <<<--- keep type in sync with the body type(uint96).max !!!
	) public virtual {

		require(isSenderInRole(ROLE_SALE_MANAGER), "access denied");


		if(_saleStart != type(uint32).max) {
			saleStart = _saleStart;

			if(pausedAt != 0) {
				emit Resumed(msg.sender, pausedAt, now32(), pauseDuration + now32() - pausedAt);

				pausedAt = 0;
			}

			pauseDuration = 0;
		}
		if(_saleEnd != type(uint32).max) {
			saleEnd = _saleEnd;
		}
		if(_halvingTime != type(uint32).max) {
			halvingTime = _halvingTime;
		}
		if(_timeFlowQuantum != type(uint32).max) {
			timeFlowQuantum = _timeFlowQuantum;
		}
		if(_seqDuration != type(uint32).max) {
			seqDuration = _seqDuration;
		}
		if(_seqOffset != type(uint32).max) {
			seqOffset = _seqOffset;
		}
		if(_startPrices.length != 1 || _startPrices[0] != type(uint96).max) {
			startPrices = _startPrices;
		}

		emit Initialized(msg.sender, saleStart, saleEnd, halvingTime, timeFlowQuantum, seqDuration, seqOffset, startPrices);
	}

	function isActive() public view virtual returns (bool) {

		return pausedAt == 0
			&& saleStart <= ownTime()
			&& ownTime() < saleEnd
			&& halvingTime > 0
			&& timeFlowQuantum > 0
			&& seqDuration > 0
			&& startPrices.length > 0;
	}

	function pause() public virtual {

		require(isSenderInRole(ROLE_PAUSE_MANAGER), "access denied");

		require(pausedAt == 0, "already paused");

		pausedAt = now32();

		emit Paused(msg.sender, now32());
	}

	function resume() public virtual {

		require(isSenderInRole(ROLE_PAUSE_MANAGER), "access denied");

		require(pausedAt != 0, "already running");

		if(now32() > saleStart) {
			pauseDuration += now32() - (pausedAt < saleStart? saleStart: pausedAt);
		}

		emit Resumed(msg.sender, pausedAt, now32(), pauseDuration);

		pausedAt = 0;
	}

	function setBeneficiary(address payable _beneficiary) public virtual {

		require(isSenderInRole(ROLE_WITHDRAWAL_MANAGER), "access denied");

		beneficiary = _beneficiary;

		emit BeneficiaryUpdated(msg.sender, _beneficiary);
	}

	function withdraw(bool _ethOnly) public virtual {

		withdrawTo(payable(msg.sender), _ethOnly);
	}

	function withdrawTo(address payable _to, bool _ethOnly) public virtual {

		require(isSenderInRole(ROLE_WITHDRAWAL_MANAGER), "access denied");

		require(_to != address(0), "recipient not set");

		uint256 ethBalance = address(this).balance;

		uint256 sIlvBalance = _ethOnly? 0: ERC20(sIlvContract).balanceOf(address(this));

		require(ethBalance > 0 || sIlvBalance > 0, "zero balance");

		if(ethBalance > 0) {
			_to.transfer(ethBalance);
		}

		if(sIlvBalance > 0) {
			ERC20(sIlvContract).transfer(_to, sIlvBalance);
		}

		emit Withdrawn(msg.sender, _to, ethBalance, sIlvBalance);
	}

	function rescueErc20(address _contract, address _to, uint256 _value) public virtual {

		require(isSenderInRole(ROLE_RESCUE_MANAGER), "access denied");

		require(_contract != sIlvContract, "sILV access denied");

		ERC20(_contract).safeTransfer(_to, _value);
	}

	function tokenPriceNow(uint32 sequenceId, uint16 tierId) public view virtual returns (uint256) {

		return tokenPriceAt(sequenceId, tierId, ownTime());
	}

	function tokenPriceAt(uint32 sequenceId, uint16 tierId, uint32 t) public view virtual returns (uint256) {

		uint32 seqStart = saleStart + sequenceId * seqOffset;
		uint32 seqEnd = seqStart + seqDuration;

		require(saleStart <= t && t < saleEnd, "invalid time");

		require(seqStart <= t && t < seqEnd, "invalid sequence");

		require(startPrices.length > tierId, "invalid tier");

		t -= seqStart;

		t /= timeFlowQuantum;
		t *= timeFlowQuantum;

		return price(startPrices[tierId], halvingTime, t);
	}

	function price(uint256 p0, uint256 t0, uint256 t) public pure virtual returns (uint256) {

		uint256 p = p0 >> t / t0;


		uint56[8] memory sqrNominator = [
			1_414213562373095, // 2 ^ (1/2)
			1_189207115002721, // 2 ^ (1/4)
			1_090507732665257, // 2 ^ (1/8) *
			1_044273782427413, // 2 ^ (1/16) *
			1_021897148654116, // 2 ^ (1/32) *
			1_010889286051700, // 2 ^ (1/64)
			1_005429901112802, // 2 ^ (1/128) *
			1_002711275050202  // 2 ^ (1/256)
		];
		uint56 sqrDenominator =
			1_000000000000000;

		for(uint8 i = 0; i < sqrNominator.length && t > 0 && t0 > 1; i++) {
			t %= t0;
			t0 /= 2;
			if(t >= t0) {
				p = p * sqrDenominator / sqrNominator[i];
			}
			if(t >= 2 * t0) {
				p = p * sqrDenominator / sqrNominator[i];
			}
		}

		return p;
	}

	function buyL1(PlotData memory plotData, bytes32[] memory proof) public virtual payable {

		require(isFeatureEnabled(FEATURE_L1_SALE_ACTIVE), "L1 sale disabled");

		(LandLib.PlotStore memory plot, uint256 pEth, uint256 pIlv) = _buy(plotData, proof);

		LandERC721Metadata(targetNftContract).mintWithMetadata(msg.sender, plotData.tokenId, plot);

		emit PlotBoughtL1(msg.sender, plotData.tokenId, plotData.sequenceId, plot, pEth, pIlv);
	}

	function buyL2(PlotData memory plotData, bytes32[] memory proof) public virtual payable {

		require(isFeatureEnabled(FEATURE_L2_SALE_ACTIVE), "L2 sale disabled");

		require(msg.sender == tx.origin, "L2 sale requires EOA");

		(LandLib.PlotStore memory plot, uint256 pEth, uint256 pIlv) = _buy(plotData, proof);


		emit PlotBoughtL2(msg.sender, plotData.tokenId, plotData.sequenceId, plot, plot.pack(), pEth, pIlv);
	}

	function _buy(
		PlotData memory plotData,
		bytes32[] memory proof
	) internal virtual returns (
		LandLib.PlotStore memory plot,
		uint256 pEth,
		uint256 pIlv
	) {

		require(isActive(), "inactive sale");

		require(root != 0x00, "empty sale");

		require(isPlotValid(plotData, proof), "invalid plot");

		_markAsMinted(plotData.tokenId);

		(pEth, pIlv) = _processPayment(plotData.sequenceId, plotData.tierId);

		uint256 seed = uint256(keccak256(abi.encodePacked(plotData.tokenId, now32(), msg.sender)));

		plot = LandLib.PlotStore({
			version: 1,
			regionId: plotData.regionId,
			x: plotData.x,
			y: plotData.y,
			tierId: plotData.tierId,
			size: plotData.size,
			landmarkTypeId: LandLib.getLandmark(seed, plotData.tierId),
			elementSites: 3 * plotData.tierId,
			fuelSites: plotData.tierId < 2? plotData.tierId: 3 * (plotData.tierId - 1),
			seed: uint160(seed)
		});

		return (plot, pEth, pIlv);
	}

	function _markAsMinted(uint256 tokenId) internal virtual {

		uint256 i = tokenId / 256;
		uint256 j = tokenId % 256;

		require(mintedTokens[i] >> j & 0x1 == 0, "already minted");
		mintedTokens[i] |= 0x1 << j;
	}

	function exists(uint256 tokenId) public view returns(bool) {


		return mintedTokens[tokenId / 256] >> tokenId % 256 & 0x1 == 1;
	}

	function _processPayment(uint32 sequenceId, uint16 tierId) internal virtual returns (uint256 pEth, uint256 pIlv) {

		pEth = tokenPriceNow(sequenceId, tierId);

		require(pEth != 0, "unsupported tier");

		if(msg.value == 0) {
			pIlv = LandSalePriceOracle(priceOracle).ethToIlv(pEth);

			require(pIlv > 1_000, "price conversion error");

			require(ERC20(sIlvContract).balanceOf(msg.sender) >= pIlv, "not enough funds available");
			require(ERC20(sIlvContract).allowance(msg.sender, address(this)) >= pIlv, "not enough funds supplied");

			require(
				ERC20(sIlvContract).transferFrom(msg.sender, beneficiary != address(0)? beneficiary: address(this), pIlv),
				"ERC20 transfer failed"
			);


			return (pEth, pIlv);
		}


		require(msg.value >= pEth, "not enough ETH");

		if(beneficiary != address(0)) {
			beneficiary.transfer(pEth);
		}

		if(msg.value > pEth) {
			payable(msg.sender).transfer(msg.value - pEth);
		}

		return (pEth, 0);
	}

	function ownTime() public view virtual returns (uint32) {

		return now32() - pauseDuration;
	}

	function now32() public view virtual returns (uint32) {

		return uint32(block.timestamp);
	}
}