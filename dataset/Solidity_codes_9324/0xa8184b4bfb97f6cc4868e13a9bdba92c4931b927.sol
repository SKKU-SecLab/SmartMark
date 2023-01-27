
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
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


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.7;


interface ILoomi {

  function spendLoomi(address user, uint256 amount) external;

}

interface ISTAKING {

  function ownerOf(address contractAddress, uint256 tokenId) external view returns (address);

}

contract NamingConvention is ReentrancyGuardUpgradeable, OwnableUpgradeable {

    using Strings for uint256;

    ILoomi public loomi;
    IERC721 public creepz;
    ISTAKING public staking;

    uint256 public firstNamePrice;
    uint256 public secondNamePrice;
    
    uint256[] public titlePrices;
    string[] public titles;

    bool public isPaused;
    bool public creepzRestriction;

    address public signer;

    mapping (uint256 => string) private _names;
    mapping (string => bool) private _nameReserved;
    
    event Rename(address indexed userAddress, uint256 creepzId, string name);

    function initialize(address _loomi, address _signer, address _creepz, address _staking) external initializer {

      firstNamePrice = 2000 ether;
      secondNamePrice = 5000 ether;
      
      titlePrices = [0 ether, 2000 ether, 5000 ether, 10000 ether, 20000 ether, 50000 ether, 100000 ether, 100000 ether, 200000 ether, 500000 ether, 1000000 ether];
      titles = ["","The Great","Love Doctor","Lil","Lord","Infamous","King","Queen","Simp Lord","Wizard","God"];

      loomi = ILoomi(_loomi);
      signer = _signer;
      creepz = IERC721(_creepz);
      staking = ISTAKING(_staking);

      creepzRestriction = true;
      isPaused = true;

      __Ownable_init();
      __ReentrancyGuard_init();
    }

    modifier whenNotPaused {

      require(!isPaused, "Name change paused!");
      _;
    }

    function renameCreepz(
      uint256 _creepzId,
      string calldata _firstName,
      string calldata _secondName,
      uint256 _title,
      bytes calldata signature
    ) public nonReentrant whenNotPaused {

      require(_validateData(_title, _firstName, _secondName, signature), "Invalid Data Provided");
      require(_validateCreepzOwner(_creepzId, _msgSender()), "!Creepz owner");

      (string memory fullName, uint256 namePrice) = composeFullName(_firstName, _secondName, _title);

      require(sha256(bytes(fullName)) != sha256(bytes(_names[_creepzId])), "New name is same as the current one");
      require(!_isNameReserved(fullName), "Name already reserved");

      loomi.spendLoomi(_msgSender(), namePrice);

      if (bytes(_names[_creepzId]).length > 0) {
        _nameReserved[toLower(_names[_creepzId])] = false;
      }
      _nameReserved[toLower(fullName)] = true;
      _names[_creepzId] = fullName;

      emit Rename(
        _msgSender(),
        _creepzId,
        fullName
      );
    }

    function composeFullName(
      string calldata _firstName,
      string calldata _secondName,
      uint256 _title
    ) public view returns (string memory, uint256) {

      uint256 totalPrice = firstNamePrice;
      string memory fullName = _firstName;

      if (bytes(_secondName).length > 0 && _title > 0) {
        totalPrice += secondNamePrice + titlePrices[_title];
        fullName = string(abi.encodePacked(titles[_title], " ", _firstName, " ", _secondName));
      }
      if (bytes(_secondName).length > 0 && _title == 0) {
        totalPrice += secondNamePrice;
        fullName = string(abi.encodePacked(_firstName, " ", _secondName));
      }
      if (bytes(_secondName).length == 0 && _title > 0) {
        totalPrice += titlePrices[_title];
        fullName = string(abi.encodePacked(titles[_title], " ", _firstName));
      }

      return (fullName, totalPrice);
    }

    function _validateData(
      uint256 _title,
      string calldata _firstName,
      string calldata _secondName,
      bytes calldata signature
      ) internal view returns (bool) {

      bytes32 dataHash = keccak256(abi.encodePacked(_title, _firstName, _secondName));
      bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);

      address receivedAddress = ECDSA.recover(message, signature);
      return (receivedAddress != address(0) && receivedAddress == signer);
    }

    function _validateCreepzOwner(uint256 tokenId, address user) internal view returns (bool) {

      if (!creepzRestriction) return true;
      if (staking.ownerOf(address(creepz), tokenId) == user) {
        return true;
      }
      return creepz.ownerOf(tokenId) == user;
    }

    function isNameReserved(string calldata _firstName, string calldata _secondName, uint256 _title) public view returns (bool) {

      (string memory fullName, ) = composeFullName(_firstName, _secondName, _title);
      return _isNameReserved(fullName);
    }

    function creepzName(uint256 _creepzId) public view returns (string memory) {

      return _names[_creepzId];
    }

    function _isNameReserved(string memory nameString) internal view returns (bool) {

      return _nameReserved[toLower(nameString)];
    }

    function retractName(uint256 _creepzId) public onlyOwner {

      string memory currentName = _names[_creepzId];
      string memory newName = string(abi.encodePacked("Creepz #", _creepzId.toString()));

      _nameReserved[toLower(currentName)] = false;
      _nameReserved[toLower(newName)] = true;
      _names[_creepzId] = newName;

      emit Rename(_msgSender(),_creepzId,newName);
    }

    function updateFirstNamePrice(uint256 _fNamePrice) public onlyOwner {

      firstNamePrice = _fNamePrice;
    }

    function updateSecondNamePrice(uint256 _secondNamePrice) public onlyOwner {

      secondNamePrice = _secondNamePrice;
    }

    function addTitle(string calldata _title, uint256 _titlePrice) public onlyOwner {

      titles.push(_title);
      titlePrices.push(_titlePrice);
    }

    function pause(bool _pause) public onlyOwner {

      isPaused = _pause;
    }

    function updateCreepzRestriction(bool _restrict) public onlyOwner {

      creepzRestriction = _restrict;
    }

    function toLower(string memory str) public pure returns (string memory){

        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}