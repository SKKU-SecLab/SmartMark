
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
}// MIT
pragma solidity ^0.8.0;


interface IERC20Mintable is IERC20 {

    function mint(address to, uint256 amount) external;

}

interface IBlocBurgers {

    function reservePrivate(uint256 reserveAmount, address reserveAddress) external;

    function transferOwnership(address newOwner) external;

    function ticketCounter() external view returns (uint256);

    function maxTotalSupply() external view returns (uint256);

}

contract Staking is IERC721Receiver, Ownable, ReentrancyGuard  {

    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;

    event NftsRewarded(address indexed receiver, uint256 indexed amount);

    uint256 public rewardRate;
    uint256 public rewardRateBonusMultiplier;
    uint256 public nftMintPriceStage1;
    uint256 public nftMintPriceStage2;
    uint256 public nftMintPriceStage3;
    uint256 public nftMintPriceStage4;

    uint256 public lossEventMod; // set 10 for 10%
    uint256 public mintEventMod; // set 20 for 5%

    address public acceptedNftAddress;
    address public rewardTokenAddress;
    address public vaultAddress;

    mapping(address => mapping(uint256 => uint256)) public level1Timestamps;
    mapping(address => EnumerableSet.UintSet) private level1TokenIds;

    mapping(address => mapping(uint256 => uint256)) public level2Timestamps;
    mapping(address => EnumerableSet.UintSet) private level2TokenIds;

    uint256 public lastRandomSeed;

    constructor(
        address _acceptedNftAddress,
        address _rewardTokenAddress,
        address _vaultAddress,
        uint256 _rewardRate,
        uint256 _rewardRateBonusMultiplier,
        uint256 _nftMintPriceStage1,
        uint256 _nftMintPriceStage2,
        uint256 _nftMintPriceStage3,
        uint256 _nftMintPriceStage4,
        uint256 _mintEventMod,
        uint256 _lossEventMod
    ) {
        rewardRate = _rewardRate;
        rewardRateBonusMultiplier = _rewardRateBonusMultiplier;
        acceptedNftAddress = _acceptedNftAddress;
        rewardTokenAddress = _rewardTokenAddress;
        vaultAddress = _vaultAddress;
        nftMintPriceStage1 = _nftMintPriceStage1;
        nftMintPriceStage2 = _nftMintPriceStage2;
        nftMintPriceStage3 = _nftMintPriceStage3;
        nftMintPriceStage4 = _nftMintPriceStage4;
        mintEventMod = _mintEventMod;
        lossEventMod = _lossEventMod;
    }

    function stakeToLevel1(uint256[] calldata tokenIds) external {

        for (uint256 i; i < tokenIds.length; i++) {
            IERC721(acceptedNftAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i], '');
            level1TokenIds[_msgSender()].add(tokenIds[i]);
            level1Timestamps[_msgSender()][tokenIds[i]] = block.timestamp;
        }
    }

    function unstakeFromLevel1(uint256[] calldata tokenIds) public nonReentrant {

        uint256 totalRewards = 0;

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            require(level1TokenIds[_msgSender()].contains(tokenId), 'Data contains not staked token ID');

            uint256 lastTimestampForTokenId = level1Timestamps[_msgSender()][tokenId];
            if (lastTimestampForTokenId > 0) {
                level1TokenIds[_msgSender()].remove(tokenId);
                IERC721(acceptedNftAddress).safeTransferFrom(address(this), _msgSender(), tokenId, '');

                uint256 rewardForTokenId = block.timestamp.sub(lastTimestampForTokenId).mul(rewardRate);
                totalRewards = totalRewards.add(rewardForTokenId);
                level1Timestamps[_msgSender()][tokenId] = block.timestamp;
            }
        }

        if (totalRewards > 0) IERC20Mintable(rewardTokenAddress).mint(_msgSender(), totalRewards);
    }

    function level1TokenIdsForAddress(address ownerAddress) external view returns (uint256[] memory) {

        EnumerableSet.UintSet storage addressLevel1TokenIds = level1TokenIds[ownerAddress];
        uint256[] memory tokenIds = new uint256[](addressLevel1TokenIds.length());

        for (uint256 i; i < addressLevel1TokenIds.length(); i++) {
            tokenIds[i] = addressLevel1TokenIds.at(i);
        }

        return tokenIds;
    }

    function stakeToLevel2(uint256[] calldata tokenIds) external {

        for (uint256 i; i < tokenIds.length; i++) {
            IERC721(acceptedNftAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i], '');
            level2TokenIds[_msgSender()].add(tokenIds[i]);
            level2Timestamps[_msgSender()][tokenIds[i]] = block.timestamp;
        }
    }

    function unstakeFromLevel2(uint256[] calldata tokenIds) public nonReentrant {

        uint256 totalRewards = 0;
        uint256 totalReservations = 0;

        uint256 nftsReserved = IBlocBurgers(acceptedNftAddress).ticketCounter();
        uint256 maxTotalSupply = IBlocBurgers(acceptedNftAddress).maxTotalSupply();

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            require(level2TokenIds[_msgSender()].contains(tokenId), 'Data contains not staked token ID');

            uint256 lastTimestampForTokenId = level2Timestamps[_msgSender()][tokenId];
            if (lastTimestampForTokenId > 0) {
                level2TokenIds[_msgSender()].remove(tokenId);

                address nftReceiverAddress = _msgSender();

                uint256 randomNumber = getRandomNumber(tokenId);
                if (randomNumber % lossEventMod == 0) {
                    nftReceiverAddress = vaultAddress;
                } else if (randomNumber % mintEventMod == 0) {
                    if (nftsReserved.add(totalReservations.add(1)) <= maxTotalSupply) {
                        totalReservations = totalReservations.add(1);
                    }
                }

                lastRandomSeed = randomNumber;

                IERC721(acceptedNftAddress).safeTransferFrom(address(this), nftReceiverAddress, tokenId, '');

                uint256 rewardForTokenId = block.timestamp.sub(lastTimestampForTokenId).mul(rewardRate);
                uint256 increasedRewardForTokenId = rewardForTokenId.mul(rewardRateBonusMultiplier);
                totalRewards = totalRewards.add(increasedRewardForTokenId);
                level2Timestamps[_msgSender()][tokenId] = block.timestamp;
            }
        }

        if (totalReservations > 0) {
            IBlocBurgers(acceptedNftAddress).reservePrivate(totalReservations, _msgSender());
            emit NftsRewarded(_msgSender(), totalReservations);
        }

        if (totalRewards > 0) IERC20Mintable(rewardTokenAddress).mint(_msgSender(), totalRewards);
    }

    function level2TokenIdsForAddress(address ownerAddress) external view returns (uint256[] memory) {

        EnumerableSet.UintSet storage addressLevel2TokenIds = level2TokenIds[ownerAddress];
        uint256[] memory tokenIds = new uint256[](addressLevel2TokenIds.length());

        for (uint256 i; i < addressLevel2TokenIds.length(); i++) {
            tokenIds[i] = addressLevel2TokenIds.at(i);
        }

        return tokenIds;
    }

    function claimRewards() public nonReentrant {

        uint256 level1TokenIdsSetSize = level1TokenIds[_msgSender()].length();
        uint256 level2TokenIdsSetSize = level2TokenIds[_msgSender()].length();

        require(level1TokenIdsSetSize.add(level2TokenIdsSetSize) > 0, "Nothing staked");

        uint256 totalRewards = 0;

        for (uint256 i; i < level1TokenIdsSetSize; i++) {
            uint256 tokenId = level1TokenIds[_msgSender()].at(i);
            uint256 lastTimestampForTokenId = level1Timestamps[_msgSender()][tokenId];
            if (lastTimestampForTokenId > 0) {
                uint256 rewardForTokenId = block.timestamp.sub(lastTimestampForTokenId).mul(rewardRate);
                totalRewards = totalRewards.add(rewardForTokenId);
                level1Timestamps[_msgSender()][tokenId] = block.timestamp;
            }
        }

        for (uint256 i; i < level2TokenIdsSetSize; i++) {
            uint256 tokenId = level2TokenIds[_msgSender()].at(i);
            uint256 lastTimestampForTokenId = level2Timestamps[_msgSender()][tokenId];
            if (lastTimestampForTokenId > 0) {
                uint256 rewardForTokenId = block.timestamp.sub(lastTimestampForTokenId).mul(rewardRate);
                uint256 increasedRewardForTokenId = rewardForTokenId.mul(rewardRateBonusMultiplier);
                totalRewards = totalRewards.add(increasedRewardForTokenId);
                level2Timestamps[_msgSender()][tokenId] = block.timestamp;
            }
        }

        require(totalRewards > 0, "Nothing to claim");

        IERC20Mintable(rewardTokenAddress).mint(_msgSender(), totalRewards);
    }

    function calculateLevel1Rewards(address ownerAddress) public view returns (uint256) {

        uint256 totalRewards = 0;

        for (uint256 i; i < level1TokenIds[ownerAddress].length(); i++) {
            uint256 tokenId = level1TokenIds[ownerAddress].at(i);
            uint256 lastTimestampForTokenId = level1Timestamps[ownerAddress][tokenId];
            if (lastTimestampForTokenId > 0) {
                uint256 rewardForTokenId = block.timestamp.sub(lastTimestampForTokenId).mul(rewardRate);
                totalRewards = totalRewards.add(rewardForTokenId);
            }
        }

        return totalRewards;
    }

    function calculateLevel2Rewards(address ownerAddress) public view returns (uint256) {

        uint256 totalRewards = 0;

        for (uint256 i; i < level2TokenIds[ownerAddress].length(); i++) {
            uint256 tokenId = level2TokenIds[ownerAddress].at(i);
            uint256 lastTimestampForTokenId = level2Timestamps[ownerAddress][tokenId];
            if (lastTimestampForTokenId > 0) {
                uint256 rewardForTokenId = block.timestamp.sub(lastTimestampForTokenId).mul(rewardRate);
                uint256 increasedRewardForTokenId = rewardForTokenId.mul(rewardRateBonusMultiplier);
                totalRewards = totalRewards.add(increasedRewardForTokenId);
            }
        }

        return totalRewards;
    }

    function calculateTotalRewards(address ownerAddress) public view returns (uint256) {

        return calculateLevel1Rewards(ownerAddress).add(calculateLevel2Rewards(ownerAddress));
    }

    function mintNftWithRewardTokens(uint256 amount) public nonReentrant {

        require(amount > 0, "Wrong amount");

        uint256 nftsReserved = IBlocBurgers(acceptedNftAddress).ticketCounter();
        uint256 maxTotalSupply = IBlocBurgers(acceptedNftAddress).maxTotalSupply();
        require(nftsReserved.add(amount) <= maxTotalSupply, "Exceeds max supply");

        uint256 tokenBalance = IERC20Mintable(rewardTokenAddress).balanceOf(_msgSender());

        uint256 nftMintPrice = nftMintPriceStage4;
        if (nftsReserved <= 1000) {
            nftMintPrice = nftMintPriceStage1;
        } else if (nftsReserved <= 2000) {
            nftMintPrice = nftMintPriceStage2;
        } else if (nftsReserved <= 3000) {
            nftMintPrice = nftMintPriceStage3;
        }

        uint256 payableTokenAmount = nftMintPrice.mul(amount);
        require(payableTokenAmount <= tokenBalance, "Not enough token balance");

        uint256 allowance = IERC20Mintable(rewardTokenAddress).allowance(_msgSender(), address(this));
        require(payableTokenAmount <= allowance, "Not enough token allowance");

        IERC20Mintable(rewardTokenAddress).transferFrom(_msgSender(), vaultAddress, payableTokenAmount);
        IBlocBurgers(acceptedNftAddress).reservePrivate(amount, _msgSender());
    }

    function setAcceptedNftAddress(address _acceptedNftAddress) external onlyOwner {

        acceptedNftAddress = _acceptedNftAddress;
    }

    function setRewardTokenAddress(address _rewardTokenAddress) external onlyOwner {

        rewardTokenAddress = _rewardTokenAddress;
    }

    function setVaultAddress(address _vaultAddress) external onlyOwner {

        vaultAddress = _vaultAddress;
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {

        rewardRate = _rewardRate;
    }

    function setRewardRateBonusMultiplier(uint256 _bonusMultiplier) external onlyOwner {

        rewardRateBonusMultiplier = _bonusMultiplier;
    }

    function setMintEventMod(uint256 _mintEventMod) external onlyOwner {

        mintEventMod = _mintEventMod;
    }

    function setLossEventMod(uint256 _lossEventMod) external onlyOwner {

        lossEventMod = _lossEventMod;
    }

    function setNftMintPriceStage1(uint256 _nftMintPrice) external onlyOwner {

        nftMintPriceStage1 = _nftMintPrice;
    }

    function setNftMintPriceStage2(uint256 _nftMintPrice) external onlyOwner {

        nftMintPriceStage2 = _nftMintPrice;
    }

    function setNftMintPriceStage3(uint256 _nftMintPrice) external onlyOwner {

        nftMintPriceStage3 = _nftMintPrice;
    }

    function setNftMintPriceStage4(uint256 _nftMintPrice) external onlyOwner {

        nftMintPriceStage4 = _nftMintPrice;
    }

    function setAcceptedNftContractOwnership(address _newOwner) external onlyOwner {

        IBlocBurgers(acceptedNftAddress).transferOwnership(_newOwner);
    }

    function getRandomNumber(uint256 seed) internal view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp,
            seed,
            lastRandomSeed
        ))) & 0xFFFF;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }
}