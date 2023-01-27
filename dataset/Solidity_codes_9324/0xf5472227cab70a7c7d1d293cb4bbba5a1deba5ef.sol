
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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

    function whitelist_mint(address account, uint256 amount) external;

}

contract NftStaking is IERC721Receiver, Ownable, Pausable {

    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public erc20 = IERC20(0xc3D6F4b97292f8d48344B36268BDd7400180667E);

    uint256 public pidsLen;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) depositBlocks;
    mapping(uint256 => mapping(address => EnumerableSet.UintSet)) _deposits;
    mapping(uint256 => mapping(uint256 => uint256)) tokenRarity;
    mapping(uint256 => uint256) EXPIRATION; // explain it
    mapping(uint256 => IERC721) depositToken;
    mapping(uint256 => uint256[7]) rewardRate;

    constructor() {
        addPoolToken(IERC721(0x350b4CdD07CC5836e30086b993D27983465Ec014)); // penguin nft
        addPoolToken(IERC721(0x48E2CC829BfC611E822134a42D4F7646Ae51b2da)); // sardine nft
    }

    function addPoolToken(IERC721 _depositToken) public onlyOwner {

        EXPIRATION[pidsLen] = 1000 ether;
        depositToken[pidsLen] = _depositToken;
        rewardRate[pidsLen++] = [10, 30, 40, 50, 60, 120, 0];
    }

    function getPidOfToken(IERC721 token) external view returns (uint256) {

        for (uint256 i = 0; i < pidsLen; i++)
            if (depositToken[i] == token) return i;

        return type(uint256).max;
    }

    function setRate(
        uint256 pid,
        uint256 _rarity,
        uint256 _rate
    ) public onlyOwner {

        require(pid < pidsLen, "invalid pid");

        rewardRate[pid][_rarity] = _rate;
    }

    function setRarity(
        uint256 pid,
        uint256 _tokenId,
        uint256 _rarity
    ) public onlyOwner {

        require(pid < pidsLen, "invalid pid");

        tokenRarity[pid][_tokenId] = _rarity;
    }

    function setBatchRarity(
        uint256 pid,
        uint256[] memory _tokenIds,
        uint256 _rarity
    ) public onlyOwner {

        require(pid < pidsLen, "invalid pid");

        for (uint256 i; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            tokenRarity[pid][tokenId] = _rarity;
        }
    }

    function setExpiration(uint256 pid, uint256 _expiration) public onlyOwner {

        EXPIRATION[pid] = _expiration;
    }

    function setRewardTokenAddress(IERC20 _erc20) public onlyOwner {

        erc20 = _erc20;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }

    function depositsOf(uint256 pid, address account)
        external
        view
        returns (uint256[] memory)
    {

        EnumerableSet.UintSet storage depositSet = _deposits[pid][account];
        uint256[] memory tokenIds = new uint256[](depositSet.length());

        for (uint256 i; i < depositSet.length(); i++)
            tokenIds[i] = depositSet.at(i);

        return tokenIds;
    }

    function GetNFTsForAddress(
        address _owner,
        address _nftAddress,
        uint256 _tokenIdFrom,
        uint256 _tokenIdTo,
        uint256 _maxNfts
    ) external view returns (uint256[] memory) {

        uint256 selectedTokenIds = 0;
        uint256[] memory selectedTokenIdsList = new uint256[](_maxNfts);

        IERC721 nft = IERC721(_nftAddress);

        for (uint256 i = _tokenIdFrom; i <= _tokenIdTo; i++) {
            try nft.ownerOf(i) returns (address owner) {
                if (owner == _owner) {
                    selectedTokenIdsList[selectedTokenIds] = i;
                    selectedTokenIds++;
                    if (selectedTokenIds >= _maxNfts) break;
                }
            } catch {}
        }

        return selectedTokenIdsList;
    }

    function GetNFTsForAddress(
        address _owner,
        address _nftAddress,
        uint256[] memory _tokenIds,
        uint256 _maxNfts
    ) external view returns (uint256[] memory) {
        uint256 selectedTokenIds = 0;
        uint256[] memory selectedTokenIdsList = new uint256[](_maxNfts);

        IERC721 nft = IERC721(_nftAddress);

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            try nft.ownerOf(_tokenIds[i]) returns (address owner) {
                if (owner == _owner) {
                    selectedTokenIdsList[selectedTokenIds] = _tokenIds[i];
                    selectedTokenIds++;
                    if (selectedTokenIds >= _maxNfts) break;
                }
            } catch {}
        }

        return selectedTokenIdsList;
    }

    function findRate(uint256 pid, uint256 tokenId)
        public
        view
        returns (uint256 rate)
    {
        uint256 rarity = tokenRarity[pid][tokenId];
        uint256 perDay = rewardRate[pid][rarity];


        rate = (perDay * 1e18) / 6000;
        return rate;
    }

    function pendingRewardToken(
        uint256 pid,
        address account,
        uint256[] memory tokenIds
    ) public view returns (uint256[] memory rewards) {
        rewards = new uint256[](tokenIds.length);

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 rate = findRate(pid, tokenId);
            rewards[i] =
                rate *
                (_deposits[pid][account].contains(tokenId) ? 1 : 0) *
                (Math.min(block.number, EXPIRATION[pid]) -
                    depositBlocks[pid][account][tokenId]);
        }
    }

    function claimRewards(uint256 pid, uint256[] calldata tokenIds)
        public
        whenNotPaused
    {
        require(pid < pidsLen, "invalid pid");
        uint256 reward;
        uint256 curblock = Math.min(block.number, EXPIRATION[pid]);

        uint256[] memory rewards = pendingRewardToken(
            pid,
            msg.sender,
            tokenIds
        );

        for (uint256 i; i < tokenIds.length; i++) {
            reward += rewards[i];
            depositBlocks[pid][msg.sender][tokenIds[i]] = curblock;
        }

        if (reward > 0) erc20.whitelist_mint(msg.sender, reward);
    }

    struct Box {
        uint256 pid;
        uint256[] tokenIds;
    }

    function depositInManyPids(Box[] calldata __) external whenNotPaused {
        for (uint256 i = 0; i < __.length; i++)
            depositMany(__[i].pid, __[i].tokenIds);
    }

    function withdrawInManyPids(Box[] calldata __) external whenNotPaused {
        for (uint256 i = 0; i < __.length; i++)
            withdrawMany(__[i].pid, __[i].tokenIds);
    }

    struct RewardBox {
        uint256[] rewards;
    }

    function pendingRewardTokenInManyPids(address account, Box[] calldata __)
        public
        view
        returns (RewardBox[] memory)
    {
        RewardBox[] memory rewardBoxList = new RewardBox[](__.length);

        for (uint256 i = 0; i < __.length; i++)
            rewardBoxList[i].rewards = pendingRewardToken(
                __[i].pid,
                account,
                __[i].tokenIds
            );

        return rewardBoxList;
    }

    function depositMany(uint256 pid, uint256[] calldata tokenIds)
        public
        whenNotPaused
    {
        require(pid < pidsLen, "invalid pid");

        claimRewards(pid, tokenIds);

        for (uint256 i; i < tokenIds.length; i++) {
            depositToken[pid].safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                ""
            );
            _deposits[pid][msg.sender].add(tokenIds[i]);
        }
    }

    function withdrawMany(uint256 pid, uint256[] calldata tokenIds)
        public
        whenNotPaused
    {
        require(pid < pidsLen, "invalid pid");
        claimRewards(pid, tokenIds);

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _deposits[pid][msg.sender].contains(tokenIds[i]),
                "Token not deposited"
            );

            _deposits[pid][msg.sender].remove(tokenIds[i]);

            depositToken[pid].safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                ""
            );
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function paused() public view override returns (bool) {
        if (msg.sender == owner()) return false;

        return super.paused();
    }
}