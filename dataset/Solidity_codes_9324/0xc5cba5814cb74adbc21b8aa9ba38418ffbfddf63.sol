
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// UNLICENSED
pragma solidity ^0.8.14;


interface ILockERC721 is IERC721 {

    function lockId(uint256 _id) external;


    function unlockId(uint256 _id) external;


    function freeId(uint256 _id, address _contract) external;

}// UNLICENSED
pragma solidity ^0.8.14;



contract GuardianLite is Initializable {

    ILockERC721 public LOCKABLE;

    mapping(address => address) public pendingGuardians;
    mapping(address => address) public guardians;

    event GuardianSet(address indexed guardian, address indexed user);
    event GuardianRenounce(address indexed guardian, address indexed user);
    event PendingGuardianSet(address indexed pendingGuardian, address indexed user);

    function initialize(address _lockable) public initializer {

        LOCKABLE = ILockERC721(_lockable);
    }

	function proposeGuardian(address _guardian) external {

		require(guardians[msg.sender] == address(0), "Guardian set");
		require(msg.sender != _guardian, "Guardian must be a different wallet");

		pendingGuardians[msg.sender] = _guardian;
		emit PendingGuardianSet(_guardian, msg.sender);
	}

	function acceptGuardianship(address _protege) external {

		require(pendingGuardians[_protege] == msg.sender, "Not the pending guardian");

		pendingGuardians[_protege] = address(0);
		guardians[_protege] = msg.sender;
		emit GuardianSet(msg.sender, _protege);
	}

    function renounce(address _tokenOwner) external {

        require(guardians[_tokenOwner] == msg.sender, "!guardian");
        guardians[_tokenOwner] = address(0);
        emit GuardianRenounce(msg.sender, _tokenOwner);
    }

    function lockMany(uint256[] calldata _tokenIds) external {

        address owner = LOCKABLE.ownerOf(_tokenIds[0]);
        require(guardians[owner] == msg.sender, "!guardian");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(LOCKABLE.ownerOf(_tokenIds[i]) == owner, "!owner");
            LOCKABLE.lockId(_tokenIds[i]);
        }
    }

    function unlockMany(uint256[] calldata _tokenIds) external {

        address owner = LOCKABLE.ownerOf(_tokenIds[0]);
        require(guardians[owner] == msg.sender, "!guardian");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(LOCKABLE.ownerOf(_tokenIds[i]) == owner, "!owner");
            LOCKABLE.unlockId(_tokenIds[i]);
        }
    }

    function unlockManyAndTransfer(
        uint256[] calldata _tokenIds,
        address _recipient
    ) external {

        address owner = LOCKABLE.ownerOf(_tokenIds[0]);
        require(guardians[owner] == msg.sender, "!guardian");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(LOCKABLE.ownerOf(_tokenIds[i]) == owner, "!owner");
            LOCKABLE.unlockId(_tokenIds[i]);
            LOCKABLE.safeTransferFrom(owner, _recipient, _tokenIds[i]);
        }
    }
}