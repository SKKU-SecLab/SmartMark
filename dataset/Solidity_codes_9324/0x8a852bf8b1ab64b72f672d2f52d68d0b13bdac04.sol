
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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

interface ILove is IERC20 {

  function burn(uint256) external;

  function burnFrom(address, uint256) external;

  function mint(address, uint256) external;

}

pragma solidity ^0.8.7;

contract LovelessCityStaking is ReentrancyGuardUpgradeable, OwnableUpgradeable {

    uint256 public constant SECONDS_IN_DAY = 24 * 60 * 60;
    uint256 public constant DIVIDER = 1000;

    uint256 public baseYield;
    uint256 public rerollStep;
    uint256 public rerollPrice;
    uint256 public upgradePrice;
    uint256 public rerollOdds;

    address public signerAddress;
    IERC721 public metroPass;
    ILove public love;

    bool public paused;

    struct Staker {
      uint256 currentMultiplier;
      uint256 accumulatedAmount;
      uint256 lastCheckpoint;
    }

    enum MetropassTypes {
      EggLine,
      CloudLine,
      DeltaLine,
      SkullLine,
      DiamondLine,
      CrownLine,
      HeartLine,
      TeeveeLine,
      ArcadeLine,
      CreepX,
      GutterX,
      ApeX,
      TenSCX
    }

    mapping(address => Staker) public _stakers;
    mapping(address => mapping(uint256 => address)) private _ownerOfToken;
    mapping(uint256 => MetropassTypes) private _metropassType;
    mapping(address => mapping(uint256 => uint256)) private _tokensMultiplier;
    mapping(address => bool) private _tokenAddressExist;
    mapping(address => bool) private _authorised;
    mapping(MetropassTypes => uint16[][]) private metroPassLevels;
    mapping(address => uint256) private _initClaimAmount;
    mapping(address => mapping(uint256 => bool)) private _initClaimed;

    event Deposit(address indexed staker,address contractAddress,uint256[] tokenIds);
    event Withdraw(address indexed staker,address contractAddress,uint256[] tokenIds);
    event Claim(address indexed staker,uint256 tokensAmount);
    event WithdrawStuckERC721(address indexed receiver, address indexed tokenAddress, uint256 indexed tokenId);
    event AddCollection(address indexed collectionAddress);
    event Authorise(address indexed addressToAuth, bool isAuthorised);
    event Reroll(uint256 indexed tokenId, bool success);
    event Upgrade(uint256 indexed tokenId);
    
    function initialize(
      address _metroPass,
      address _love,
      address _signer
    ) external initializer {

        __Ownable_init();
        __ReentrancyGuard_init();

        metroPass = IERC721(_metroPass);
        love = ILove(_love);
        
        addCollection(_metroPass, 5500 ether);
        
        baseYield = 100 ether;
        rerollPrice = 500 ether;
        upgradePrice = 1500 ether;
        rerollStep = 50;
        rerollOdds = 30;

        signerAddress = _signer;

        paused = true;

        metroPassLevels[MetropassTypes.EggLine] = [[1250, 1380], [1880, 2070], [2190, 2420], [2500, 2760], [3130, 3450]];
        metroPassLevels[MetropassTypes.CloudLine] = [[1380, 1500], [2070, 2250], [2420, 2630], [2760, 3000], [3450, 3750]];
        metroPassLevels[MetropassTypes.DeltaLine] = [[1630, 1750], [2450, 2630], [2850, 3060], [3260, 3500], [4080, 4380]];
        metroPassLevels[MetropassTypes.SkullLine] = [[1750, 1880], [2630, 2820], [3060, 3290], [3500, 3760], [4380, 4700]];
        metroPassLevels[MetropassTypes.DiamondLine] = [[1880, 2000], [2820, 3000], [3290, 3500], [3760, 4000], [4700, 5000]];
        metroPassLevels[MetropassTypes.CrownLine] = [[2000, 2130], [3000, 3200], [3500, 3730], [4000, 4260], [5000, 5330]];
        metroPassLevels[MetropassTypes.HeartLine] = [[2130, 2250], [3200, 3380], [3730, 3940], [4260, 4500], [5330, 5630]];
        metroPassLevels[MetropassTypes.TeeveeLine] = [[2380, 2500], [3570, 3750], [4170, 4380], [4760, 5000], [5950, 6250]];
        metroPassLevels[MetropassTypes.ArcadeLine] = [[2500, 2630], [3750, 3950], [4380, 4600], [5000, 5260], [6250, 6580]];
        metroPassLevels[MetropassTypes.CreepX] = [[2880, 3000], [4320, 4500], [5040, 5250], [5760, 6000], [7200, 7500]];
        metroPassLevels[MetropassTypes.GutterX] = [[3000, 3130], [4500, 4700], [5250, 5480], [6000, 6260], [7500, 7830]];
        metroPassLevels[MetropassTypes.ApeX] = [[3130, 3250], [4700, 4880], [5480, 5690], [6260, 6500], [7830, 8130]];
        metroPassLevels[MetropassTypes.TenSCX] = [[3250, 3380], [4880, 5070], [5690, 5920], [6500, 6760], [8130, 8450]];
    }

    modifier authorised() {

      require(_authorised[_msgSender()], "Address is not authorised");
      _;
    }

    modifier whenNotPaused() {

      require(!paused, "The contract is currently paused");
      _;
    }

    function deposit(
      address _nftAddress,
      uint256[] memory tokenIds,
      uint256[] memory tokenMultipliers,
      uint256[] memory tokenTypes,
      bytes calldata signature
    ) public nonReentrant whenNotPaused {

      require(_tokenAddressExist[_nftAddress], "Unknown contract");

      if (tokenMultipliers.length > 0 || tokenTypes.length > 0) {
        require(_validateSignature(
          signature,
          _nftAddress,
          tokenIds,
          tokenMultipliers,
          tokenTypes
        ), "Invalid data provided");
        _setTokensValues(_nftAddress, tokenIds, tokenMultipliers);

        if (_nftAddress == address(metroPass)) {
          _setTokensTypes(tokenIds, tokenTypes);
        }
      }

      Staker storage user = _stakers[_msgSender()];
      uint256 newMultiplier = user.currentMultiplier;

      for (uint256 i; i < tokenIds.length; i++) {
        require(IERC721(_nftAddress).ownerOf(tokenIds[i]) == _msgSender(), "Not the owner");
        IERC721(_nftAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i]);

        if (!_initClaimed[_nftAddress][tokenIds[i]]) {
          _initClaimed[_nftAddress][tokenIds[i]] = true;
          user.accumulatedAmount += _initClaimAmount[_nftAddress] * _tokensMultiplier[_nftAddress][tokenIds[i]] / DIVIDER;
        }

        _ownerOfToken[_nftAddress][tokenIds[i]] = _msgSender();

        newMultiplier += getTokenMultiplier(_nftAddress, tokenIds[i]);
      }

      accumulate(_msgSender());
      user.currentMultiplier = newMultiplier;

      emit Deposit(_msgSender(), _nftAddress, tokenIds);
    }

    function withdraw(
      address _nftAddress,
      uint256[] memory tokenIds
    ) public nonReentrant whenNotPaused {

      require(_tokenAddressExist[_nftAddress], "Unknown contract");

      Staker storage user = _stakers[_msgSender()];
      uint256 newMultiplier = user.currentMultiplier;

      for (uint256 i; i < tokenIds.length; i++) {
        require(IERC721(_nftAddress).ownerOf(tokenIds[i]) == address(this), "Token not staked");
        require(_ownerOfToken[_nftAddress][tokenIds[i]] == _msgSender(), "Not the owner");

        _ownerOfToken[_nftAddress][tokenIds[i]] = address(0);

        newMultiplier -= getTokenMultiplier(_nftAddress, tokenIds[i]);

        IERC721(_nftAddress).safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
      }

      accumulate(_msgSender());
      user.currentMultiplier = newMultiplier;

      emit Withdraw(_msgSender(), _nftAddress, tokenIds);
    }

    function reroll(uint256 tokenId, bool redeem) public  nonReentrant whenNotPaused {

      require(metroPass.ownerOf(tokenId) == address(this), "Token not staked");

      if (redeem) {
        require(_redeemLove(_msgSender(), rerollPrice), "Insufficient funds");
      } else {
        love.burnFrom(_msgSender(), rerollPrice);
      }

      uint256 currentMultiplier = getTokenMultiplier(address(metroPass), tokenId);
      uint16[][] memory levelsByTypes = metroPassLevels[_metropassType[tokenId]];
      bool canReroll;
      uint256 newRerollValue;

      for (uint256 i; i < levelsByTypes.length; i++) {
        if (currentMultiplier >= levelsByTypes[i][0] && currentMultiplier < levelsByTypes[i][1]) {
          if (currentMultiplier + rerollStep >= levelsByTypes[i][1]) {
            canReroll = true;
            newRerollValue = levelsByTypes[i][1];
          } else {
            canReroll = true;
            newRerollValue = currentMultiplier + rerollStep;
          }
        }
      }

      require(canReroll, "Cannot reroll");

      bool success = random(currentMultiplier) % 100 <= rerollOdds;

      if (success) {
        uint256 multiplierDiff = newRerollValue - _tokensMultiplier[address(metroPass)][tokenId];
        _tokensMultiplier[address(metroPass)][tokenId] = newRerollValue;
        _stakers[_msgSender()].currentMultiplier += multiplierDiff;
      }

      emit Reroll(tokenId, success);
    }
    
    function upgrade(uint256 tokenId, bool redeem) public nonReentrant whenNotPaused {

      require(metroPass.ownerOf(tokenId) == address(this), "Token not staked");

      if (redeem) {
        require(_redeemLove(_msgSender(), upgradePrice), "Insufficient funds");
      } else {
        love.burnFrom(_msgSender(), upgradePrice);
      }

      uint256 currentMultiplier = getTokenMultiplier(address(metroPass), tokenId);
      uint16[][] memory levelsByTypes = metroPassLevels[_metropassType[tokenId]];
      bool canUpgrade;
      uint256 newLevelIndex;

      for (uint256 i; i < levelsByTypes.length; i++) {
        if (currentMultiplier == levelsByTypes[i][1]) {
          canUpgrade = true;
          newLevelIndex = i + 1;
        }
      }

      require(canUpgrade, "Cannot upgrade");

      uint256 multiplierDiff = levelsByTypes[newLevelIndex][0] - _tokensMultiplier[address(metroPass)][tokenId];
      _tokensMultiplier[address(metroPass)][tokenId] = levelsByTypes[newLevelIndex][0];
      _stakers[_msgSender()].currentMultiplier += multiplierDiff;

      emit Upgrade(tokenId);
    }

    function redeemLove(address user, uint256 amount) public nonReentrant whenNotPaused authorised {

      require(_redeemLove(user, amount), "Insufficient funds");
    }
    
    function random(uint256 seedNumber) private view returns (uint) {

      return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, seedNumber)));
    }

    function claim() public nonReentrant whenNotPaused {

      Staker storage user = _stakers[_msgSender()];
      accumulate(_msgSender());

      require(user.accumulatedAmount > 0, "Nothing to claim");
      
      uint256 amountToMint = user.accumulatedAmount;
      love.mint(_msgSender(), amountToMint);

      user.accumulatedAmount = 0;

      emit Claim(_msgSender(), amountToMint);
    }

    function getAccumulatedAmount(address staker) external view returns (uint256) {

      return _stakers[staker].accumulatedAmount + getCurrentReward(staker);
    }

    function getTokenMultiplier(address contractAddress, uint256 tokenId) public view returns (uint256) {

      uint256 tokenMultiplier = _tokensMultiplier[contractAddress][tokenId];
      require (tokenMultiplier != 0, "Initial multiplier is not set for the token");

      return tokenMultiplier;
    }

    function getStakerYield(address staker) public view returns (uint256) {

      return _stakers[staker].currentMultiplier * baseYield / DIVIDER;
    }

    function isMultiplierSet(address contractAddress, uint256 tokenId) public view returns (bool) {

      return _tokensMultiplier[contractAddress][tokenId] > 0;
    }

    function _validateSignature(
      bytes calldata signature,
      address contractAddress,
      uint256[] memory tokenIds,
      uint256[] memory tokenMultipliers,
      uint256[] memory tokenTypes
      ) internal view returns (bool) {

      bytes32 dataHash = keccak256(abi.encodePacked(contractAddress, tokenIds, tokenMultipliers, tokenTypes));
      bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);

      address receivedAddress = ECDSA.recover(message, signature);
      return (receivedAddress != address(0) && receivedAddress == signerAddress);
    }

    function _setTokensValues(
      address contractAddress,
      uint256[] memory tokenIds,
      uint256[] memory tokenTraits
    ) internal {

      require(tokenIds.length == tokenTraits.length, "Wrong arrays provided");
      for (uint256 i; i < tokenIds.length; i++) {
        if (
          tokenTraits[i] != 0 
          && tokenTraits[i] <= 3000 ether
          && _tokensMultiplier[contractAddress][tokenIds[i]] == 0
        ) {
          _tokensMultiplier[contractAddress][tokenIds[i]] = tokenTraits[i];
        }
      }
    }

    function _setTokensTypes(
      uint256[] memory tokenIds,
      uint256[] memory tokenTypes
    ) internal {

      require(tokenIds.length == tokenTypes.length, "Wrong arrays provided");
      for (uint256 i; i < tokenIds.length; i++) {
        if (tokenTypes[i] <= 12) {
          _metropassType[tokenIds[i]] = MetropassTypes(tokenTypes[i]);
        }
      }
    }

    function _redeemLove(address _user, uint256 amount) internal returns (bool) {

      Staker storage user = _stakers[_user];
      accumulate(_user);

      if (user.accumulatedAmount < amount) return false;

      user.accumulatedAmount -= amount;
      return true;
    }

    function getCurrentReward(address staker) public view returns (uint256) {

      Staker memory user = _stakers[staker];
      if (user.lastCheckpoint == 0) { return 0; }

      uint256 userYield = user.currentMultiplier * baseYield / DIVIDER;
      return (block.timestamp - user.lastCheckpoint) * userYield / SECONDS_IN_DAY;
    }

    function getMetroPassType(uint256 tokenId) public view returns (uint256) {

      return uint256(_metropassType[tokenId]);
    }

    function accumulate(address staker) internal {

      _stakers[staker].accumulatedAmount += getCurrentReward(staker);
      _stakers[staker].lastCheckpoint = block.timestamp;
    }

    function ownerOf(address contractAddress, uint256 tokenId) public view returns (address) {

      return _ownerOfToken[contractAddress][tokenId];
    }

    function addCollection(address _collectionAddress, uint256 _initAmount) public onlyOwner {

      require(!_tokenAddressExist[_collectionAddress], "Collection already exist");
      _tokenAddressExist[_collectionAddress] = true;
      _initClaimAmount[_collectionAddress] = _initAmount;
      emit AddCollection(_collectionAddress);
    }



    function authorise(address _addressToAuth, bool _isAuthorised) public onlyOwner {

      _authorised[_addressToAuth] = _isAuthorised;
      emit Authorise(_addressToAuth, _isAuthorised);
    }

    function emergencyWithdraw(address tokenAddress, uint256[] memory tokenIds) public onlyOwner {

      require(tokenIds.length <= 50, "50 is max per tx");
      for (uint256 i; i < tokenIds.length; i++) {
        address receiver = _ownerOfToken[tokenAddress][tokenIds[i]];
        if (receiver != address(0) && IERC721(tokenAddress).ownerOf(tokenIds[i]) == address(this)) {
          IERC721(tokenAddress).transferFrom(address(this), receiver, tokenIds[i]);
          emit WithdrawStuckERC721(receiver, tokenAddress, tokenIds[i]);
        }
      }
    }

    function pause(bool _pause) public onlyOwner {

      paused = _pause;
    }

    function updateRerollPrice(uint256 _rerollPrice) public onlyOwner {

      rerollPrice = _rerollPrice;
    }

    function updateUpgradePrice(uint256 _upgradePrice) public onlyOwner {

      upgradePrice = _upgradePrice;
    }

    function updateRerollStep(uint256 _rerollStep) public onlyOwner {

      rerollStep = _rerollStep;
    }

    function updateRerolOdds(uint256 _rerollOdds) public onlyOwner {

      rerollOdds = _rerollOdds;
    }

    function updateSignerAddress(address _signer) public onlyOwner {

      signerAddress = _signer;
    }

    function updateBaseYield(uint256 _yield) public onlyOwner {

      baseYield = _yield;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4){

      return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}