
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.9;


interface IVoxelsNFT is IERC721 {

  function totalSupply() external view returns (uint256);


  function wires(uint256) external view returns (uint256);


  function stages(uint256) external view returns (uint256);

}

contract VoxelsStaking is
  Initializable,
  OwnableUpgradeable,
  IERC721Receiver,
  ReentrancyGuardUpgradeable,
  PausableUpgradeable
{

  using EnumerableSet for EnumerableSet.UintSet;
  using ECDSA for bytes32;

  mapping(address => bool) public admins;

  IVoxelsNFT public voxelsNFT;
  IERC20 public wireToken;

  struct RankRequest {
    uint256[] tokenIds;
    uint256[] ranks;
    string nonce;
  }

  uint256 public expiration;
  uint256 public rate;
  uint256 public multiplierRate;

  uint256 public totalStaked;
  uint256 public voxelTotalSupply; // 4242 voxels
  uint256 public genesisTotalSupply; // 1414 genesises
  bool public claimActive;

  address internal _signer;

  mapping(address => EnumerableSet.UintSet) private _deposits;
  mapping(address => mapping(uint256 => uint256)) public _depositBlocks;
  mapping(string => bool) private _nonce;
  mapping(uint256 => uint256) private lastRank;
  mapping(address => mapping(uint256 => uint256)) public cubeTypesStaked;

  modifier onlyAdmin() {

    require(admins[msg.sender], "Only Admin can execute");
    _;
  }

  function initialize(
    address _voxelsNFT,
    uint256 _rate,
    uint256 _multiplierRate,
    uint256 _expiration,
    address _wireToken
  ) external initializer {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();

    voxelsNFT = IVoxelsNFT(_voxelsNFT);
    rate = _rate;
    multiplierRate = _multiplierRate;
    expiration = block.timestamp + _expiration;
    wireToken = IERC20(_wireToken);
    _signer = 0xbd137bd879C99e5B13e1bce1C617FdB4b0478E91;
    voxelTotalSupply = 4242;
    genesisTotalSupply = 1414;
    admins[msg.sender] = true;
    pause();
  }

  function pause() public onlyAdmin {

    _pause();
  }

  function unpause() public onlyAdmin {

    _unpause();
  }

  function setRate(uint256 _rate) public onlyAdmin {

    rate = _rate;
  }

  function setMultiplierRate(uint256 _multiplierRate) public onlyAdmin {

    multiplierRate = _multiplierRate;
  }

  function setExpiration(uint256 _expiration) public onlyAdmin {

    expiration = block.timestamp + _expiration;
  }

  function setVoxelTotalSupply(uint256 _voxelTotalSupply) external onlyAdmin {

    voxelTotalSupply = _voxelTotalSupply;
  }

  function setGenesisTotalSupply(uint256 _genesisTotalSupply)
    external
    onlyAdmin
  {

    genesisTotalSupply = _genesisTotalSupply;
  }

  function depositsOf(address account) public view returns (uint256[] memory) {

    EnumerableSet.UintSet storage depositSet = _deposits[account];
    uint256[] memory tokenIds = new uint256[](depositSet.length());

    for (uint256 i; i < depositSet.length(); i++) {
      tokenIds[i] = depositSet.at(i);      
    }

    return tokenIds;
  }

  function calculateRewards(
    address account,
    uint256[] memory tokenIds,
    uint256[] memory ranks
  ) public view returns (uint256) {

    require(tokenIds.length == ranks.length, "Ranks must be matched");

    uint256 reward = 0;
    uint256 i;
    uint256 multiplerCheck;

    for (i = 0; i < tokenIds.length; i++) {
      multiplerCheck |= 1 << (2**((tokenIds[i] - 1) / 1414));
    }

    for (i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      uint16 isDeposited = _deposits[account].contains(tokenId) ? 1 : 0;

      reward +=
        _getStakingRate(
          tokenId,
          ranks[i],
          multiplerCheck == 22 ? multiplierRate : 100
        ) *
        isDeposited *
        (Math.min(block.timestamp, expiration) - _depositBlocks[account][tokenId]) * 1e18
        / 1 days;
    }

    return reward;
  }

  function claimRewards(bytes calldata requestData, bytes calldata signature)
    public
    whenNotPaused
  {

    (
      uint256[] memory tokenIds,
      uint256[] memory ranks,
    )  = _validateRequest(requestData, signature);

    uint256 reward = calculateRewards(msg.sender, tokenIds, ranks);
    uint256 blockCur = Math.min(block.timestamp, expiration);

    for (uint256 i; i < tokenIds.length; i++) {
      _depositBlocks[msg.sender][tokenIds[i]] = blockCur;
      lastRank[tokenIds[i]] = ranks[i];
    }

    if (reward > 0) {
      IERC20(wireToken).transfer(msg.sender, reward);
    }
  }

  function _validateRequest(
    bytes calldata requestData,
    bytes calldata signature
  )
    internal
    returns (
      uint256[] memory,
      uint256[] memory,
      string memory
    )
  {

    RankRequest memory request = abi.decode(requestData, (RankRequest));

    uint256[] memory tokenIds = request.tokenIds;
    uint256[] memory ranks = request.ranks;
    string memory nonce = request.nonce;
    require(!_nonce[nonce], "Already used");

    bytes32 requestHash = keccak256(
      abi.encodePacked(address(this), msg.sender, requestData)
    );

    address signerFromHash = requestHash.toEthSignedMessageHash().recover(
      signature
    );
    require(signerFromHash == _signer, "Invalid Signer");
    _nonce[nonce] = true;
    return (tokenIds, ranks, nonce);
  }

  function deposit(bytes calldata requestData, bytes calldata signature)
    external
    whenNotPaused
  {

    RankRequest memory request = abi.decode(requestData, (RankRequest));
    uint256[] memory tokenIds = request.tokenIds;    
    require(msg.sender != address(voxelsNFT), "Invalid address");
    claimRewards(requestData, signature);

    for (uint256 i; i < tokenIds.length; i++) {
      voxelsNFT.safeTransferFrom(msg.sender, address(this), tokenIds[i], "");
      _deposits[msg.sender].add(tokenIds[i]);
    }

    totalStaked += tokenIds.length;
  }

  function withdraw(bytes calldata requestData, bytes calldata signature)
    external
    whenNotPaused
    nonReentrant
  {

    RankRequest memory request = abi.decode(requestData, (RankRequest));
    uint256[] memory tokenIds = request.tokenIds;
    claimRewards(requestData, signature);

    for (uint256 i; i < tokenIds.length; i++) {
      require(
        _deposits[msg.sender].contains(tokenIds[i]),
        "Staking: token not deposited"
      );
      _deposits[msg.sender].remove(tokenIds[i]);

      voxelsNFT.safeTransferFrom(address(this), msg.sender, tokenIds[i], "");
    }

    totalStaked -= tokenIds.length;
  }

  function withdrawTokens() external onlyAdmin {

    uint256 tokenSupply = wireToken.balanceOf(address(this));
    wireToken.transfer(msg.sender, tokenSupply);
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {

    return IERC721Receiver.onERC721Received.selector;
  }

  function addAdmin(address admin_) external onlyOwner {

    admins[admin_] = true;
  }

  function removeAdmin(address admin_) external onlyOwner {

    admins[admin_] = false;
  }

  function _getWeight(
    uint256 _tokenId,
    uint256 _rank
  ) public view returns (uint256) {

    uint256 lastRankForTokenId = lastRank[_tokenId];
    uint256 rankAvgWithExponential = _rank * 10000;
    if(lastRankForTokenId > 0 && lastRankForTokenId != _rank) {
      rankAvgWithExponential = _rank + lastRankForTokenId * 10000 / 2;      
    }

    uint256 totalSupply = _tokenId <= voxelTotalSupply
      ? voxelTotalSupply
      : genesisTotalSupply;
    uint256 _totalStaked = totalStaked > 0 ? totalStaked : 1; 

    return (
      (voxelsNFT.totalSupply() * totalSupply) /
      (_totalStaked * rankAvgWithExponential)
    );
  }

  function _getStakingRate(
    uint256 _tokenId,
    uint256 _rank,
    uint256 _multiplierRate
  ) public view returns (uint256) {

    uint256 extraRate = _tokenId <= voxelTotalSupply
      ? _multiplierRate
      : (voxelsNFT.wires(_tokenId) + 2) * (voxelsNFT.stages(_tokenId) + 1) * 100;
    return rate * (1 + _getWeight(_tokenId, _rank)) * extraRate / 100;
  }

  function setSigner(address signer) external onlyAdmin {

    _signer = signer;
  }
}