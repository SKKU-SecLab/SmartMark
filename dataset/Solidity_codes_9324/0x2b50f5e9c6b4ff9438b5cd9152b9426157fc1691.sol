
pragma solidity ^0.7.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;


    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;


}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


contract UseAccessControl {

  IAccessControl public accessControl;

  constructor(address _accessControl) {
    accessControl = IAccessControl(_accessControl);
  }

  modifier onlyRole(bytes32 role) {

      _checkRole(role, msg.sender);
      _;
  }

  function _checkRole(bytes32 role, address account) internal view {

    if (!accessControl.hasRole(role, account)) {
        revert(
            string(
                abi.encodePacked(
                    "AccessControl: account ",
                    Strings.toHexString(uint160(account), 20),
                    " is missing role ",
                    Strings.toHexString(uint256(role), 32)
                )
            )
        );
    }
  }
}// MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _txOrigin() internal view virtual returns (address) {
        return tx.origin;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT
pragma solidity ^0.7.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.7.0;

library LibString {

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {

      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function uint2hexstr(uint i) internal pure returns (string memory) {

        if (i == 0) {
            return "0";
        }
        uint j = i;
        uint len;
        while (j != 0) {
            len++;
            j = j >> 4;
        }
        uint mask = 15;
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            uint curr = (i & mask);
            bstr[k--] = curr > 9 ? byte(uint8(55 + curr)) : byte(uint8(48 + curr));
            i = i >> 4;
        }
        return string(bstr);
    }
}// MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface IMetadataRegistry {

  struct Document {
		address writer;
		string text;
		uint256 creationTime;
	}

  function tokenIdToDocument(uint256 tokenId, string memory key) external view returns (Document memory);

}pragma solidity ^0.7.0;


contract DerivedMetadataRegistry is Ownable, IMetadataRegistry {

  IMetadataRegistry public immutable sourceRegistry;

  mapping(uint256 => mapping(string => IMetadataRegistry.Document)) public tokenIdToDocumentMap;
  mapping(address => bool) public permissedWriters;

  constructor(address sourceRegistry_) {
    sourceRegistry = IMetadataRegistry(sourceRegistry_);
  }

  event UpdatedDocument(
      uint256 indexed tokenId,
      address indexed writer,
      string indexed key,
      string text
  );

  function updatePermissedWriterStatus(address _writer, bool status) public onlyOwner {

    permissedWriters[_writer] = status;
  }

  modifier onlyIfPermissed(address writer) {

    require(permissedWriters[writer] == true, "writer can't write to registry");
    _;
  }

  function writeDocuments(uint256 tokenId, string[] memory keys, string[] memory texts, address[] memory writers) public onlyIfPermissed(msg.sender) {

    require(keys.length == texts.length, "keys and txHashes size mismatch");
    require(writers.length == texts.length, "writers and texts size mismatch");
    for (uint256 i = 0; i < keys.length; ++i) {
      string memory key = keys[i];
      string memory text = texts[i];
      address writer = writers[i];
      tokenIdToDocumentMap[tokenId][key] = IMetadataRegistry.Document(writer, text, block.timestamp);
      emit UpdatedDocument(tokenId, writer, key, text); 
    }
  }

  function tokenIdToDocument(uint256 tokenId, string memory key) override external view returns (IMetadataRegistry.Document memory) {

    IMetadataRegistry.Document memory sourceDoc = sourceRegistry.tokenIdToDocument(tokenId, key);
    if (bytes(sourceDoc.text).length == 0) {
      return IMetadataRegistry.Document(address(0), "", 0);
    }
    IMetadataRegistry.Document memory doc = tokenIdToDocumentMap[tokenId][sourceDoc.text];
    return doc; 
  }
}pragma solidity ^0.7.0;


contract MixinSignature {

  function splitSignature(bytes memory sig)
      public pure returns (bytes32 r, bytes32 s, uint8 v)
  {

      require(sig.length == 65, "invalid signature length");

      assembly {
          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
      }

      if (v < 27) v += 27;
  }

  function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {

      return _isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s);
  }

  function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
      internal pure returns (bool)
  {

      return ecrecover(messageHash, v, r, s) == _address;
  }

  function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
      internal pure returns (bool)
  {

      bytes memory prefix = "\x19Ethereum Signed Message:\n32";
      return _isSigned(_address, keccak256(abi.encodePacked(prefix, messageHash)), v, r, s);
  }
  
}// MIT

pragma solidity ^0.7.0;


abstract contract MixinPausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.7.0;


contract AffirmationWriter is Ownable, MixinSignature, MixinPausable, UseAccessControl {


  DerivedMetadataRegistry public derivedMetadataRegistry;

  bytes32 public immutable organizerRole;
  bytes32 public immutable historianRole;

  IERC20 public immutable tipToken;

  uint256 public minimumQuorumAffirmations;
  
  uint256 public constant VERSION = 2;

  address payable public historianTipJar;

  mapping(bytes32 => bool) public affirmationHashRegistry;
  mapping(bytes32 => bool) public tipHashRegistry;
  

  constructor(
    address _accessControl,
    address _derivedMetadataRegistry,
    address payable _historianTipJar,
    address _tipToken,
    bytes32 _organizerRole,
    bytes32 _historianRole
  ) UseAccessControl(_accessControl) {
    derivedMetadataRegistry = DerivedMetadataRegistry(_derivedMetadataRegistry);
    organizerRole = _organizerRole;
    historianRole = _historianRole;
    historianTipJar = _historianTipJar;
    tipToken = IERC20(_tipToken);
  }

	struct Affirmation {
		uint256 salt;
    address signer;
    bytes signature;
	}

	struct Tip {
    uint256 version;
		bytes32 writeHash;
    address tipper;
    uint256 value;
    bytes signature;
	}

	struct Write {
    uint256 tokenId;
    string key;
		string text;
    uint256 salt;
	}

  event Affirmed(
      uint256 indexed tokenId,
      address indexed signer,
      string indexed key,
      bytes32 affirmationHash,
      uint256 salt,
      bytes signature
  );

  event Tipped(
      bytes32 indexed writeHash,
      address indexed tipper,
      uint256 value,
      bytes signature
  );

  function getWriteHash(Write calldata _write) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(_write.tokenId, _write.key, _write.text, _write.salt));
  }

  function getAffirmationHash(bytes32 _writeHash, Affirmation calldata _affirmation) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(_writeHash, _affirmation.signer, _affirmation.salt));
  }

  function getTipHash(Tip calldata _tip) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(_tip.version, _tip.writeHash, _tip.tipper, _tip.value));
  }

  function verifyAffirmation(
    bytes32 writeHash, Affirmation calldata _affirmation 
  ) public pure returns (bool) {

    bytes32 signedHash = getAffirmationHash(writeHash, _affirmation);
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_affirmation.signature);
    return isSigned(_affirmation.signer, signedHash, v, r, s);
  }

  function verifyTip(
    Tip calldata _tip 
  ) public pure returns (bool) {

    bytes32 signedHash = getTipHash(_tip);
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_tip.signature);
    return _tip.version == VERSION && isSigned(_tip.tipper, signedHash, v, r, s);
  }

  function updateMinimumQuorumAffirmations(uint256 _minimumQuorumAffirmations) public onlyRole(organizerRole) {

    minimumQuorumAffirmations = _minimumQuorumAffirmations;
  }

  function updateHistorianTipJar(address payable _historianTipJar) public onlyRole(organizerRole) {

    historianTipJar = _historianTipJar;
  }

  function pause() public onlyRole(organizerRole) {

    _pause();
  }

  function unpause() public onlyRole(organizerRole) {

    _unpause();
  } 

  function write(Write calldata _write, Affirmation[] calldata _affirmations, Tip calldata _tip) public whenNotPaused {

    bytes32 writeHash = getWriteHash(_write);

    uint256 numValidAffirmations = 0;
    for (uint256 i = 0; i < _affirmations.length; ++i) {
      Affirmation calldata affirmation = _affirmations[i];
      bytes32 affirmationHash = getAffirmationHash(writeHash, affirmation);
      require(affirmationHashRegistry[affirmationHash] == false, "Affirmation has already been received");
      affirmationHashRegistry[affirmationHash] = true;
      require(verifyAffirmation(writeHash, affirmation) == true, "Affirmation doesn't have valid signature");
      _checkRole(historianRole, affirmation.signer);
      numValidAffirmations++;
      emit Affirmed(_write.tokenId, affirmation.signer, _write.key, affirmationHash, affirmation.salt, affirmation.signature ); 
    }

    require(numValidAffirmations >= minimumQuorumAffirmations, "Minimum affirmations not met");
    _writeDocument(_write);
    _settleTip(writeHash, _tip);
  }

  function _writeDocument(Write calldata _write) internal {

    string[] memory keys = new string[](1);
    string[] memory texts = new string[](1);
    address[] memory writers = new address[](1);
    keys[0] = _write.key;
    texts[0] = _write.text;
    writers[0] = address(this);
    derivedMetadataRegistry.writeDocuments(_write.tokenId, keys, texts, writers); 
  }

  function settleTip(bytes32 writeHash, Tip calldata _tip) public onlyRole(historianRole) {

    _settleTip(writeHash, _tip);
  }

  function _settleTip(bytes32 writeHash, Tip calldata _tip) internal {

    if (_tip.value != 0) {
      require (writeHash == _tip.writeHash, 'Tip is not for write');
      bytes32 tipHash = getTipHash(_tip);
      require(tipHashRegistry[tipHash] == false, "Tip has already been used");
      tipHashRegistry[tipHash] = true;
      require(verifyTip(_tip) == true, "Tip doesn't have valid signature");
      tipToken.transferFrom(_tip.tipper, historianTipJar, _tip.value);
      emit Tipped(_tip.writeHash, _tip.tipper, _tip.value, _tip.signature);
    }
  }

}