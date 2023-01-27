
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

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
}

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
}

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
}

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


pragma solidity 0.8.13;


contract NFTStaking is Ownable, ReentrancyGuard {

  struct Staker {
    uint256 claimedRewards;
    uint256 lastCheckpoint;
    uint256[] stakedToken1;
    uint256[] stakedToken2;
    uint256[] stakedBoosters;
  }
  enum ContractTypes {
    Token1,
    Token2,
    Booster
  }
  uint256 public constant SECONDS_IN_DAY = 24 * 60 * 60;
  bool public stakingLaunched;
  bool public depositPaused;
  address[3] public tokenAddresses;
  bool[3] public tokenTypeSeeded;
  uint256 private constant TOKEN1 = 0;
  uint256 private constant TOKEN2 = 1;
  uint256 private constant BOOSTER = 2;
  uint256 constant private NUMBER_OF_TOKEN_TYPES = 3;
  uint256 constant private MAX_NUMBER_OF_CATEGORIES_PER_TOKEN_TYPE = 5;
  uint256[NUMBER_OF_TOKEN_TYPES] public numberOfCategoryPerType = [5, 5, 3];
  uint256[MAX_NUMBER_OF_CATEGORIES_PER_TOKEN_TYPE][NUMBER_OF_TOKEN_TYPES] public yieldsPerCategoryPerTokenType;
  bytes private _token1Categories;
  bytes private _token2Categories;
  bytes private _boosterCategories;
  mapping(address => Staker) public stakers;
  mapping(uint256 => mapping(uint256 => address)) private _ownerOfToken;
  event Deposit(address indexed staker, address nftContract, uint256 tokensAmount);
  event Withdraw(address indexed staker, address nftContract, uint256 tokensAmount);
  event WithdrawStuckERC721(address indexed receiver, address indexed tokenAddress, uint256 indexed tokenId);

  constructor(
    address _token1
  ) {
    tokenAddresses[TOKEN1] = _token1;
    yieldsPerCategoryPerTokenType[0][0] = 100 ether;
    yieldsPerCategoryPerTokenType[0][1] = 120 ether;
    yieldsPerCategoryPerTokenType[0][2] = 140 ether;
    yieldsPerCategoryPerTokenType[0][3] = 150 ether;
    yieldsPerCategoryPerTokenType[0][4] = 200 ether;
  }

  function setTokenAddresses(address token1, address token2, address booster) external onlyOwner {

    tokenAddresses[TOKEN1] = token1;
    tokenAddresses[TOKEN2] = token2;
    tokenAddresses[BOOSTER] = booster;
  }

  function setCategoriesBatch(ContractTypes contractType, bytes calldata categoryInBytes) external onlyOwner {

    tokenTypeSeeded[uint(contractType)] = true;
    if (contractType == ContractTypes.Token1) {
      _token1Categories = categoryInBytes;
    } else if (contractType == ContractTypes.Token2) {
      _token2Categories = categoryInBytes;
    } else if (contractType == ContractTypes.Booster) {
      _boosterCategories = categoryInBytes;
    }
  }

  function setCategoryYield(
    ContractTypes contractType,
    uint8 category,
    uint256 yield
  ) external onlyOwner {

    require(category <= numberOfCategoryPerType[uint(contractType)], "Invalid category number");
    yieldsPerCategoryPerTokenType[uint(contractType)][category] = yield;
  }

  function setCategoryYieldsBatch(ContractTypes contractType, uint256[] memory yields) external onlyOwner {

    require(yields.length == numberOfCategoryPerType[uint(contractType)], "Length not match");
    for (uint256 i; i < yields.length; i++) {
      yieldsPerCategoryPerTokenType[uint(contractType)][i] = yields[i];
    }
  }
  
  function getCategoriesOfTokens(ContractTypes contractType, uint256[] memory tokenIds) external view returns (uint8[] memory) {

    uint8[] memory categories = new uint8[](tokenIds.length);
    for (uint256 i; i < tokenIds.length; i++) {
      categories[i] = getCategoryOfToken(contractType, tokenIds[i]);
    }
    return categories;
  }

  function deposit(ContractTypes contractType, uint256[] memory tokenIds) external nonReentrant {

    require(uint(contractType) < tokenAddresses.length, "Not a valid contract");
    require(!depositPaused, "Deposit paused");
    require(stakingLaunched, "Staking is disabled");
    require(tokenIds.length > 0, "No token Ids specified");
    address tokenAddress = tokenAddresses[uint(contractType)];

    _claimRewards(_msgSender());

    Staker storage user = stakers[_msgSender()];

    if (contractType == ContractTypes.Booster) {
      require(user.stakedBoosters.length + tokenIds.length <= user.stakedToken1.length * 2, "Maximum num of boosters reached");
    }

    for (uint256 i; i < tokenIds.length; i++) {
      require(IERC721(tokenAddress).ownerOf(tokenIds[i]) == _msgSender(), "Not the owner");
      IERC721(tokenAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i]);
      _ownerOfToken[uint(contractType)][tokenIds[i]] = _msgSender();

      if (contractType == ContractTypes.Token1) {
        user.stakedToken1.push(tokenIds[i]);
      } else if (contractType == ContractTypes.Token2) {
        user.stakedToken2.push(tokenIds[i]);
      } else if (contractType == ContractTypes.Booster) {
        user.stakedBoosters.push(tokenIds[i]);
      }
    }
    emit Deposit(_msgSender(), tokenAddress, tokenIds.length);
  }

  function withdraw(ContractTypes contractType, uint256[] memory tokenIds) external nonReentrant {

    require(uint(contractType) < tokenAddresses.length, "Not a valid contract");
    require(tokenIds.length > 0, "No token Ids specified");
    address tokenAddress = tokenAddresses[uint(contractType)];

    _claimRewards(_msgSender());

    Staker storage user = stakers[_msgSender()];

    for (uint256 i; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      require(IERC721(tokenAddress).ownerOf(tokenId) == address(this), "Invalid tokenIds provided");
      require(_ownerOfToken[uint(contractType)][tokenId] == _msgSender(), "Not token owner");
      _ownerOfToken[uint(contractType)][tokenId] = address(0);

      if (contractType == ContractTypes.Token1) {
        user.stakedToken1 = _moveTokenToLast(user.stakedToken1, tokenId);
        user.stakedToken1.pop();
      } else if (contractType == ContractTypes.Token2) {
        user.stakedToken2 = _moveTokenToLast(user.stakedToken2, tokenId);
        user.stakedToken2.pop();
      } else if (contractType == ContractTypes.Booster) {
        user.stakedBoosters = _moveTokenToLast(user.stakedBoosters, tokenId);
        user.stakedBoosters.pop();
      }

      IERC721(tokenAddress).safeTransferFrom(address(this), _msgSender(), tokenId);
    }

    emit Withdraw(_msgSender(), tokenAddress, tokenIds.length);
  }

  function getTotalRewards(address staker) external view returns (uint256) {

    return stakers[staker].claimedRewards + getUnclaimedRewards(staker);
  }

  function getYieldsForTokens(ContractTypes contractType, uint256[] memory tokenIds) external view returns (uint256[] memory) {

    uint256[] memory yields = new uint256[](tokenIds.length);
    for (uint256 i; i < tokenIds.length; i++) {
      yields[i] = getTokenYield(contractType, tokenIds[i]);
    }
    return yields;
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {

    return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }

  function pauseDeposit(bool _pause) public onlyOwner {

    depositPaused = _pause;
  }

  function launchStaking() public onlyOwner {

    require(!stakingLaunched, "Staking was enabled");
    stakingLaunched = true;
  }

  function emergencyWithdraw(ContractTypes contractType, uint256[] memory tokenIds) public onlyOwner {

    require(tokenIds.length <= 50, "50 is max per tx");
    require(uint(contractType) < tokenAddresses.length, "Not a valid contract");
    address tokenAddress = tokenAddresses[uint(contractType)];
    pauseDeposit(true);
    for (uint256 i; i < tokenIds.length; i++) {
      address receiver = _ownerOfToken[uint(contractType)][tokenIds[i]];
      if (receiver != address(0) && IERC721(tokenAddress).ownerOf(tokenIds[i]) == address(this)) {
        IERC721(tokenAddress).transferFrom(address(this), receiver, tokenIds[i]);
        emit WithdrawStuckERC721(receiver, tokenAddress, tokenIds[i]);
      }
    }
  }

  function getCategoryOfToken(ContractTypes contractType, uint256 tokenId) public view returns (uint8) {

    if (tokenTypeSeeded[uint(contractType)] == false) {
      return 0;
    }
    if (contractType == ContractTypes.Token1) {
      return uint8(_token1Categories[tokenId]);
    } else if (contractType == ContractTypes.Token2) {
      return uint8(_token2Categories[tokenId]);
    } else if (contractType == ContractTypes.Booster) {
      return uint8(_boosterCategories[tokenId]);
    }
    return 0;
  }

  function getTokenYield(ContractTypes contractType, uint256 tokenId) public view returns (uint256) {

    uint8 category = getCategoryOfToken(contractType, tokenId);
    return yieldsPerCategoryPerTokenType[uint(contractType)][category];
  }

  function calculateBoostersYield(address userAddress) public view returns (uint256) {

    uint256 numberToken1Staked = stakers[userAddress].stakedToken1.length;
    uint256[] memory boosters = stakers[userAddress].stakedBoosters;

    uint256 maximumApplicableBoosters = numberToken1Staked * 2;
    uint256 applicableBoosters = boosters.length < maximumApplicableBoosters ? boosters.length : maximumApplicableBoosters;

    uint256 totalBoosterYield;
    for (uint256 i; i < applicableBoosters; i++) {
      uint256 tokenId = boosters[i];
      totalBoosterYield += getTokenYield(ContractTypes.Booster, tokenId);
    }

    return totalBoosterYield;
  }

  function getCurrentYield(address userAddress) public view returns (uint256) {

    uint256 numberToken1Staked = stakers[userAddress].stakedToken1.length;
    uint256 numberToken2Staked = stakers[userAddress].stakedToken2.length;
    uint currentYield = 0;
    for (uint256 i; i < numberToken1Staked; i++) {
      currentYield += getTokenYield(ContractTypes.Token1, stakers[userAddress].stakedToken1[i]);
    }
    for (uint256 i; i < numberToken2Staked; i++) {
      currentYield += getTokenYield(ContractTypes.Token2, stakers[userAddress].stakedToken2[i]);
    }
    currentYield += calculateBoostersYield(userAddress);
    return currentYield;
  }

  function getUnclaimedRewards(address staker) public view returns (uint256) {

    if (stakers[staker].lastCheckpoint == 0) {
      return 0;
    }
    return ((block.timestamp - stakers[staker].lastCheckpoint) * getCurrentYield(staker)) / SECONDS_IN_DAY;
  }

  function getStakerTokens(ContractTypes contractType, address staker) public view returns (uint256[] memory) {

    uint256[] memory tokens;
    if (contractType == ContractTypes.Token1) {
      tokens = stakers[staker].stakedToken1;
    } else if (contractType == ContractTypes.Token2) {
      tokens = stakers[staker].stakedToken2;
    } else if (contractType == ContractTypes.Booster) {
      tokens = stakers[staker].stakedBoosters;
    }
    return tokens;
  }

  function ownerOf(ContractTypes contractType, uint256 tokenId) public view returns (address) {

    return _ownerOfToken[uint(contractType)][tokenId];
  }

  function _moveTokenToLast(uint256[] memory list, uint256 tokenId) internal pure returns (uint256[] memory) {

    uint256 tokenIndex = 0;
    uint256 lastTokenIndex = list.length - 1;
    uint256 length = list.length;

    for (uint256 i = 0; i < length; i++) {
      if (list[i] == tokenId) {
        tokenIndex = i + 1;
        break;
      }
    }
    require(tokenIndex != 0, "msg.sender is not the owner");

    tokenIndex -= 1;

    if (tokenIndex != lastTokenIndex) {
      list[tokenIndex] = list[lastTokenIndex];
      list[lastTokenIndex] = tokenId;
    }

    return list;
  }

  function _claimRewards(address staker) internal {

    stakers[staker].claimedRewards += getUnclaimedRewards(staker);
    stakers[staker].lastCheckpoint = block.timestamp;
  }
}
