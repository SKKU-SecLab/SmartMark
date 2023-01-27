
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
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
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
pragma solidity ^0.8.2;


interface IMintableERC20 is IERC20  {

  function mint(address _to, uint256 _amount) external;

  function burn(address _from, uint256 _amount) external;

}

contract StakingSystem is Ownable, ERC721Holder {

    using EnumerableSet for EnumerableSet.UintSet;

    IERC721 public erc721Token;
    IMintableERC20 public erc20Token;

    uint256 public epochTime = 1 weeks;

    uint256 public rowdyEpochYield = 1 ether;
    uint256 public ragingEpochYield = 3 ether;
    uint256 public royalEpochYield = 6 ether;

    bool public locked = false;

    address private rowdySigner;
    address private ragingSigner;
    address private royalSigner;

    struct Stake {
        uint8 rarity;
        uint16 tokenId;
        uint48 time;
        address owner;
    }

    mapping(uint16 => Stake) stakes;
    mapping(address => EnumerableSet.UintSet) stakers;

    event TokenStaked(uint16 tokenId, address owner);
    event TokenUnstaked(uint16 tokenId, address owner, uint256 earnings);

    constructor(address _erc721Address, address _erc20Address) {    
        erc721Token = IERC721(_erc721Address);
        erc20Token = IMintableERC20(_erc20Address);
    }

    function setERC721Contract(address _erc721Address) external onlyOwner {

        erc721Token = IERC721(_erc721Address);
    }

    function setERC20Contract(address _erc20Address) external onlyOwner {

        erc20Token = IMintableERC20(_erc20Address);
    }

    function setEpoch(uint256 _epochTime) external onlyOwner {

        require((!locked), "the staking contract is locked");
        epochTime = _epochTime;
    }

    function setYields(uint256 rowdy, uint256 raging, uint256 royal) external onlyOwner{

        require((!locked), "the staking contract is locked");
        rowdyEpochYield = rowdy * 1 ether;
        ragingEpochYield = raging * 1 ether;
        royalEpochYield = royal * 1 ether;
    }

    function setSigners(address[] calldata signers) public onlyOwner{

        rowdySigner = signers[0];
        ragingSigner = signers[1];
        royalSigner = signers[2];
    }

    function getStakedTokens(address _owner) external view returns (uint16[] memory) {

        uint256 stakedTokensLength = stakers[_owner].length();
        uint16[] memory tokenIds = new uint16[](stakedTokensLength);

        for (uint16 i = 0; i < stakedTokensLength; i++) {
            tokenIds[i] = uint16(stakers[_owner].at(i));
        }
        return tokenIds;
    }

    function getLastClaimedTime(uint16 _tokenId) external view returns(uint48) {

        return stakes[_tokenId].time;
    }

    function getTimeUntilNextReward(uint16 _tokenId) external view returns(uint256) {

        uint256 stakedSeconds = block.timestamp - stakes[_tokenId].time;
        uint256 epochsStaked = stakedSeconds / epochTime;
        return epochTime - (stakedSeconds - (epochsStaked * epochTime));
    }

    function currentRewardsOf(uint16 _tokenId) public view returns (uint256) {

        require(stakes[_tokenId].tokenId != 0, "the token id is not staked");
        uint256 stakedSeconds = block.timestamp - stakes[_tokenId].time;
        uint256 epochsStaked = stakedSeconds / epochTime;
        uint256 reward = epochsStaked;

        if(stakes[_tokenId].rarity == 0) {
            reward *= rowdyEpochYield;
        } else if(stakes[_tokenId].rarity == 1) {
            reward *= ragingEpochYield;
        } else if(stakes[_tokenId].rarity == 2) {
            reward *= royalEpochYield;
        }

        return reward;
    }

    function stakeTokens(address _owner, uint16[] calldata _tokenIds, bytes32[] memory _hashes, bytes[] memory _signatures) external {

        require((_owner == msg.sender), "only owners approved");
        
        for (uint16 i = 0; i < _tokenIds.length; i++) {
            require(erc721Token.ownerOf(_tokenIds[i]) == msg.sender, "only owners approved");
            _stake(_owner, _tokenIds[i], _hashes[i], _signatures[i]);
            erc721Token.transferFrom(msg.sender, address(this), _tokenIds[i]);
        }
    }

    function _stake(address _owner, uint16 _tokenId, bytes32 _hash, bytes memory _signature) internal {

        address signer = recoverSigner(_hash, _signature);
        uint8 rarity = 0;

        if(signer == rowdySigner){
            rarity = 0;
        } else if(signer == ragingSigner){
            rarity = 1;
        } else if(signer == royalSigner){
            rarity = 2;
        }

        stakers[_owner].add(_tokenId);
        stakes[_tokenId] = Stake(rarity, _tokenId, (uint48(block.timestamp)), _owner);
        emit TokenStaked(_tokenId, _owner);
    }

    function claimRewardsAndUnstake(uint16[] calldata _tokenIds, bool _unstake) external {

        uint256 reward;
        uint48 time = uint48(block.timestamp);

        for (uint8 i = 0; i < _tokenIds.length; i++) {
            reward += _claimRewardsAndUnstake(_tokenIds[i], _unstake, time);
        }
        if (reward != 0) {
            erc20Token.mint(msg.sender, reward);
        }
    }

    function _claimRewardsAndUnstake(uint16 _tokenId, bool _unstake, uint48 _time) internal returns (uint256 reward) {

        Stake memory stake = stakes[_tokenId];
        require(stake.owner == msg.sender, "only owners can unstake");
        reward = currentRewardsOf(_tokenId);

        if (_unstake) {
            delete stakes[_tokenId];
            stakers[msg.sender].remove(_tokenId);
            erc721Token.transferFrom(address(this), msg.sender, _tokenId);
            emit TokenUnstaked(_tokenId, msg.sender, reward);
        } 
        else {
            stakes[_tokenId].time = _time;
        }
    }

    function unstakeWithoutReward(uint16 _tokenId) external {

        Stake memory stake = stakes[_tokenId];
        require(stake.owner == msg.sender, "only owners can unstake");
        delete stakes[_tokenId];
        stakers[msg.sender].remove(_tokenId);
        erc721Token.transferFrom(address(this), msg.sender, _tokenId);
        emit TokenUnstaked(_tokenId, msg.sender, 0);
    }

    function recoverSigner(bytes32 _hash, bytes memory _signature) public pure returns (address) {

        bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
        return ECDSA.recover(messageDigest, _signature);
    }

    function lockContract() external onlyOwner {

        locked = true;
    }
}