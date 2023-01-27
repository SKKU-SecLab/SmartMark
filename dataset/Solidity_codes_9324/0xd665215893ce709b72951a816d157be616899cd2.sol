


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

interface IERC165 {

	function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		return msg.data;
	}
}

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
}

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
}

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

contract WastedWorld is Ownable, ReentrancyGuard {

	uint256 public constant SECONDS_IN_DAY = 24 * 60 * 60;
	uint256 public constant ACCELERATED_YIELD_DAYS = 2;
	uint256 public constant ACCELERATED_YIELD_MULTIPLIER = 2;
	uint256 public acceleratedYield;

	address public signerAddress;
	address[] public authorisedLog;

	bool public stakingLaunched;
	bool public depositPaused;

	struct Staker {
	  uint256 currentYield;
	  uint256 accumulatedAmount;
	  uint256 lastCheckpoint;
	}

	mapping(address => bool) isWWNftContract;
	mapping(address => mapping(address => uint256[])) stakedTokensForAddress;
	mapping(address => uint256) public _baseRates;
	mapping(address => Staker) private _stakers;
	mapping(address => mapping(uint256 => address)) private _ownerOfToken;
	mapping(address => mapping(uint256 => uint256)) private _tokensMultiplier;
	mapping(address => bool) private _authorised;

	event Deposit(address indexed staker,address contractAddress,uint256 tokensAmount);
	event Withdraw(address indexed staker,address contractAddress,uint256 tokensAmount);
	event AutoDeposit(address indexed contractAddress,uint256 tokenId,address indexed owner);
	event WithdrawStuckERC721(address indexed receiver, address indexed tokenAddress, uint256 indexed tokenId);

	constructor(
	  address _pre,
	  address _signer
	) {
		_baseRates[_pre] = 4200 ether;
		isWWNftContract[_pre] = true;

		signerAddress = _signer;
	}

	modifier authorised() {

	  require(_authorised[_msgSender()], "The token contract is not authorised");
		_;
	}

	function deposit(
	  address contractAddress,
	  uint256[] memory tokenIds,
	  uint256[] memory tokenTraits,
	  bytes calldata signature
	) public nonReentrant {

	  require(!depositPaused, "Deposit paused");
	  require(stakingLaunched, "Staking is not launched yet");
	  require(
		contractAddress != address(0) &&
		isWWNftContract[contractAddress],
		"Unknown contract"
	  );

	  if (tokenTraits.length > 0) {
		require(_validateSignature(
		  signature,
		  contractAddress,
		  tokenIds,
		  tokenTraits
		), "Invalid data provided");
		_setTokensValues(contractAddress, tokenIds, tokenTraits);
	  }

	  Staker storage user = _stakers[_msgSender()];
	  uint256 newYield = user.currentYield;

	  for (uint256 i; i < tokenIds.length; i++) {
		require(IERC721(contractAddress).ownerOf(tokenIds[i]) == _msgSender(), "Not the owner");
		IERC721(contractAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i]);

		_ownerOfToken[contractAddress][tokenIds[i]] = _msgSender();

		newYield += getTokenYield(contractAddress, tokenIds[i]);
		stakedTokensForAddress[_msgSender()][contractAddress].push(tokenIds[i]);
	  }

	  accumulate(_msgSender());
	  user.currentYield = newYield;

	  emit Deposit(_msgSender(), contractAddress, tokenIds.length);
	}

	function withdraw(
	  address contractAddress,
	  uint256[] memory tokenIds
	) public nonReentrant {

	  require(
		contractAddress != address(0) &&
		isWWNftContract[contractAddress],
		"Unknown contract"
	  );
	  Staker storage user = _stakers[_msgSender()];
	  uint256 newYield = user.currentYield;

	  for (uint256 i; i < tokenIds.length; i++) {
		require(IERC721(contractAddress).ownerOf(tokenIds[i]) == address(this), "Not the owner");

		_ownerOfToken[contractAddress][tokenIds[i]] = address(0);

		if (user.currentYield != 0) {
		  uint256 tokenYield = getTokenYield(contractAddress, tokenIds[i]);
		  newYield -= tokenYield;
		}

		stakedTokensForAddress[_msgSender()][contractAddress] = _moveTokenInTheList(stakedTokensForAddress[_msgSender()][contractAddress], tokenIds[i]);
		stakedTokensForAddress[_msgSender()][contractAddress].pop();

		IERC721(contractAddress).safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
	  }

	  accumulate(_msgSender());
	  user.currentYield = newYield;

	  emit Withdraw(_msgSender(), contractAddress, tokenIds.length);
	}

	function registerDeposit(address owner, address contractAddress, uint256 tokenId) public authorised {

	  require(
		contractAddress != address(0) &&
		isWWNftContract[contractAddress],
		"Unknown contract"
	  );
	  require(IERC721(contractAddress).ownerOf(tokenId) == address(this), "!Owner");
	  require(ownerOf(contractAddress, tokenId) == address(0), "Already deposited");

	  _ownerOfToken[contractAddress][tokenId] = owner;

	  Staker storage user = _stakers[owner];
	  uint256 newYield = user.currentYield;

	  newYield += getTokenYield(contractAddress, tokenId);
	  stakedTokensForAddress[owner][contractAddress].push(tokenId);

	  accumulate(owner);
	  user.currentYield = newYield;

	  emit AutoDeposit(contractAddress, tokenId, _msgSender());
	}

	function getAccumulatedAmount(address staker) external view returns (uint256) {

	  return _stakers[staker].accumulatedAmount + getCurrentReward(staker);
	}

	function getTokenYield(address contractAddress, uint256 tokenId) public view returns (uint256) {

	  uint256 tokenYield = _tokensMultiplier[contractAddress][tokenId];
	  if (tokenYield == 0) { tokenYield = _baseRates[contractAddress]; }

	  return tokenYield;
	}

	function getStakerYield(address staker) public view returns (uint256) {

	  return _stakers[staker].currentYield;
	}

	function getStakerTokens(address staker, address contractAddress) public view returns (uint256[] memory) {

	  return (stakedTokensForAddress[staker][contractAddress]);
	}

	function isMultiplierSet(address contractAddress, uint256 tokenId) public view returns (bool) {

	  return _tokensMultiplier[contractAddress][tokenId] > 0;
	}

	function _moveTokenInTheList(uint256[] memory list, uint256 tokenId) internal pure returns (uint256[] memory) {

	  uint256 tokenIndex = 0;
	  uint256 lastTokenIndex = list.length - 1;
	  uint256 length = list.length;

	  for(uint256 i = 0; i < length; i++) {
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

	function _validateSignature(
	  bytes calldata signature,
	  address contractAddress,
	  uint256[] memory tokenIds,
	  uint256[] memory tokenTraits
	  ) internal view returns (bool) {

	  bytes32 dataHash = keccak256(abi.encodePacked(contractAddress, tokenIds, tokenTraits));
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
		if (tokenTraits[i] != 0 && tokenTraits[i] <= 8000 ether) {
		  _tokensMultiplier[contractAddress][tokenIds[i]] = tokenTraits[i];
		}
	  }
	}

	function getCurrentReward(address staker) public view returns (uint256) {

	  Staker memory user = _stakers[staker];
	  if (user.lastCheckpoint == 0) { return 0; }
	  if (user.lastCheckpoint < acceleratedYield && block.timestamp < acceleratedYield) {
		return (block.timestamp - user.lastCheckpoint) * user.currentYield / SECONDS_IN_DAY * ACCELERATED_YIELD_MULTIPLIER;
	  }
	  if (user.lastCheckpoint < acceleratedYield && block.timestamp > acceleratedYield) {
		uint256 currentReward;
		currentReward += (acceleratedYield - user.lastCheckpoint) * user.currentYield / SECONDS_IN_DAY * ACCELERATED_YIELD_MULTIPLIER;
		currentReward += (block.timestamp - acceleratedYield) * user.currentYield / SECONDS_IN_DAY;
		return currentReward;
	  }
	  return (block.timestamp - user.lastCheckpoint) * user.currentYield / SECONDS_IN_DAY;
	}

	function accumulate(address staker) internal {

	  _stakers[staker].accumulatedAmount += getCurrentReward(staker);
	  _stakers[staker].lastCheckpoint = block.timestamp;
	}

	function ownerOf(address contractAddress, uint256 tokenId) public view returns (address) {

	  return _ownerOfToken[contractAddress][tokenId];
	}

	function addNFTContract(address _contract, uint256 _baseReward) public onlyOwner {

	  _baseRates[_contract] = _baseReward;
	  isWWNftContract[_contract] = true;
	}

	function authorise(address toAuth) public onlyOwner {

	  _authorised[toAuth] = true;
	  authorisedLog.push(toAuth);
	}

	function unauthorise(address addressToUnAuth) public onlyOwner {

	  _authorised[addressToUnAuth] = false;
	}

	function emergencyWithdraw(address tokenAddress, uint256[] memory tokenIds) public onlyOwner {

	  require(tokenIds.length <= 50, "50 is max per tx");
	  pauseDeposit(true);
	  for (uint256 i; i < tokenIds.length; i++) {
		address receiver = _ownerOfToken[tokenAddress][tokenIds[i]];
		if (receiver != address(0) && IERC721(tokenAddress).ownerOf(tokenIds[i]) == address(this)) {
		  IERC721(tokenAddress).transferFrom(address(this), receiver, tokenIds[i]);
		  emit WithdrawStuckERC721(receiver, tokenAddress, tokenIds[i]);
		}
	  }
	}

	function pauseDeposit(bool _pause) public onlyOwner {

	  depositPaused = _pause;
	}

	function updateSignerAddress(address _signer) public onlyOwner {

	  signerAddress = _signer;
	}

	function launchStaking() public onlyOwner {

	  require(!stakingLaunched, "Staking has been launched already");
	  stakingLaunched = true;
	  acceleratedYield = block.timestamp + (SECONDS_IN_DAY * ACCELERATED_YIELD_DAYS);
	}

	function updateBaseYield(address _contract, uint256 _yield) public onlyOwner {

	  _baseRates[_contract] = _yield;
	}

	function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4){

	  return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}
}