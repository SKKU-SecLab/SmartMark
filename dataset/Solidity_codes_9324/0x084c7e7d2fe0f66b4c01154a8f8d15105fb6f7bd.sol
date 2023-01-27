
pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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
pragma solidity ^0.8.9;

interface IERC2981Royalties {

    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);

}// MIT
pragma solidity ^0.8.9;

interface IRaribleSecondarySales {

    function getFeeRecipients(uint256 tokenId)
        external
        view
        returns (address payable[] memory);


    function getFeeBps(uint256 tokenId)
        external
        view
        returns (uint256[] memory);

}// MIT
pragma solidity ^0.8.9;

interface IFoundationSecondarySales {

    function getFees(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);

}// MIT
pragma solidity ^0.8.9;


interface IERC721WithRoyalties is
    IERC2981Royalties,
    IRaribleSecondarySales,
    IFoundationSecondarySales
{


}// MIT
pragma solidity ^0.8.9;

interface IERC721WithMutableURI {

    function mutableURI(uint256 tokenId) external view returns (string memory);

}//MIT
pragma solidity ^0.8.9;



interface IERC721Full is
    IERC721Upgradeable,
    IERC721WithRoyalties,
    IERC721WithMutableURI
{

    function baseURI() external view returns (string memory);


    function contractURI() external view returns (string memory);


    function withdraw(
        address token,
        uint256 amount,
        uint256 tokenId
    ) external;


    function canEdit(address account) external view returns (bool);


    function canMint(address account) external view returns (bool);


    function isEditor(address account) external view returns (bool);


    function isMinter(address account) external view returns (bool);


    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;


    function setBaseURI(string memory baseURI_) external;


    function setBaseMutableURI(string memory baseMutableURI_) external;


    function setMutableURI(uint256 tokenId, string memory mutableURI_) external;


    function addEditors(address[] memory users) external;


    function removeEditors(address[] memory users) external;


    function addMinters(address[] memory users) external;


    function removeMinters(address[] memory users) external;


    function setDefaultRoyaltiesRecipient(address recipient) external;


    function setTokenRoyaltiesRecipient(uint256 tokenId, address recipient)
        external;


    function setContractURI(string memory contractURI_) external;

}//MIT
pragma solidity ^0.8.9;


interface INiftyForge721 is IERC721Full {

    struct ModuleInit {
        address module;
        bool enabled;
        bool minter;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        ModuleInit[] memory modulesInit_,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue
    ) external;


    function version() external view returns (bytes3);


    function totalSupply() external view returns (uint256);


    function isMintingOpenToAll() external view returns (bool);


    function setMintingOpenToAll(bool isOpen) external;


    function setMaxSupply(uint256 maxSupply_) external;


    function mint(address to) external returns (uint256 tokenId);


    function mint(address to, address transferTo)
        external
        returns (uint256 tokenId);


    function mint(
        address to,
        string memory uri,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) external returns (uint256 tokenId);


    function mintBatch(
        address[] memory to,
        string[] memory uris,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) external returns (uint256 startId, uint256 endId);


    function mint(
        address to,
        string memory uri,
        uint256 tokenId_,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) external returns (uint256 tokenId);


    function mintBatch(
        address[] memory to,
        string[] memory uris,
        uint256[] memory tokenIds,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) external;


    function attachModule(
        address module,
        bool enabled,
        bool canModuleMint
    ) external;


    function enableModule(address module, bool canModuleMint) external;


    function disableModule(address module, bool keepListeners) external;


    function startAtZero() external;


    function renderTokenURI(uint256 tokenId)
        external
        view
        returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}//MIT
pragma solidity ^0.8.9;


interface INFModule is IERC165 {

    function onAttach() external returns (bool);


    function onEnable() external returns (bool);


    function onDisable() external;


    function contractURI() external view returns (string memory);

}//MIT
pragma solidity ^0.8.9;

interface INFModuleTokenURI {

    function tokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);

}//MIT
pragma solidity ^0.8.9;

interface INFModuleWithRoyalties {

    function royaltyInfo(address registry, uint256 tokenId)
        external
        view
        returns (address recipient, uint256 basisPoint);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}//MIT
pragma solidity ^0.8.9;


contract NFBaseModule is INFModule, ERC165 {

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal _attached;

    event NewContractURI(string contractURI);

    string private _contractURI;

    modifier onlyAttached(address registry) {

        require(_attached.contains(registry), '!NOT_ATTACHED!');
        _;
    }

    constructor(string memory contractURI_) {
        _setContractURI(contractURI_);
    }

    function contractURI()
        external
        view
        virtual
        override
        returns (string memory)
    {

        return _contractURI;
    }

    function onAttach() external virtual override returns (bool) {

        if (_attached.add(msg.sender)) {
            return true;
        }

        revert('!ALREADY_ATTACHED!');
    }

    function onEnable() external virtual override returns (bool) {

        return true;
    }

    function onDisable() external virtual override {}


    function _setContractURI(string memory contractURI_) internal {

        _contractURI = contractURI_;
        emit NewContractURI(contractURI_);
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
}//MIT
pragma solidity ^0.8.0;

contract GroupedURIs {

    event TokenToGroup(uint256 tokenId, uint256 groupId);

    uint256 public currentGroupId;

    mapping(uint256 => string) public groupBaseURI;

    mapping(uint256 => uint256) public tokenGroup;

    function _incrementGroup(
        string memory previousGroupBaseURI,
        string memory newGroupBaseURI
    ) internal {

        if (bytes(previousGroupBaseURI).length != 0) {
            _setGroupURI(currentGroupId, previousGroupBaseURI);
        }
        _setGroupURI(++currentGroupId, newGroupBaseURI);
    }

    function _setGroupURI(uint256 group, string memory baseURI) internal {

        groupBaseURI[group] = baseURI;
    }

    function _setTokenGroup(uint256 tokenId, uint256 groupId) internal {

        tokenGroup[tokenId] = groupId;
        emit TokenToGroup(tokenId, groupId);
    }
}//MIT
pragma solidity ^0.8.0;




interface IWETH {

    function deposit() external payable;


    function withdraw(uint256 wad) external;


    function transfer(address to, uint256 value) external returns (bool);

}

contract NFTBattles is
    Ownable,
    ReentrancyGuard,
    GroupedURIs,
    NFBaseModule,
    INFModuleTokenURI,
    INFModuleWithRoyalties
{

    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    error WETHNotSet();
    error BattleInactive();
    error WrongContender();
    error NoSelfOutbid();
    error WrongBidValue();
    error NotEnoughContenders();
    error AlreadySettled();
    error UnknownBattle();
    error BattleNotEnded();

    event BattleCreated(uint256 battleId, address[] contenders);

    event BidCreated(
        uint256 battleId,
        uint256 contender,
        address bidder,
        uint256 bid
    );

    event BattleStartChanged(uint256 battleId, uint256 newEnd);

    event BattleEndChanged(uint256 battleId, uint256 newEnd);

    event BattleSettled(uint256 battleId, uint256 bidsSum);

    event BattleContenderResult(
        uint256 battleId,
        uint256 index,
        uint256 tokenId,
        address randomBidder
    );

    event BattleCanceled(uint256 battleId);

    struct Battle {
        uint256 startsAt;
        uint256 endsAt;
        uint256 contenders;
        bool settled;
    }

    struct BattleContender {
        address artist;
        address highestBidder;
        uint256 highestBid;
        EnumerableSet.AddressSet bidders;
    }

    address public nftContract;

    uint256 public minimalBid = 0.001 ether;

    uint256 public minimalBidIncrease = 5;

    uint256 public timeBuffer = 5 minutes;

    uint256 public lastBattleId;

    address public withdrawTarget;

    mapping(uint256 => Battle) public battles;

    mapping(uint256 => mapping(uint256 => BattleContender))
        internal _battleContenders;

    address public immutable wethContract;

    mapping(uint256 => address) public tokenCreator;

    constructor(
        string memory contractURI_,
        string memory baseURI,
        address wethContract_,
        address owner_
    ) NFBaseModule(contractURI_) {
        _incrementGroup("", baseURI);

        uint256 chainId = block.chainid;
        if (chainId == 4) {
            wethContract_ = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
        } else if (chainId == 1) {
            wethContract_ = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        } else {
            if (wethContract_ == address(0)) {
                revert WETHNotSet();
            }
        }

        wethContract = wethContract_;

        if (owner_ != address(0)) {
            transferOwnership(owner_);
        }
    }


    function getBattleBids(uint256 battleId)
        external
        view
        returns (address[] memory bidders, uint256[] memory bids)
    {

        Battle memory battle = battles[battleId];

        bidders = new address[](battle.contenders);
        bids = new uint256[](battle.contenders);

        for (uint256 i; i < battle.contenders; i++) {
            bidders[i] = _battleContenders[battleId][i].highestBidder;
            bids[i] = _battleContenders[battleId][i].highestBid;
        }
    }


    function onAttach() external virtual override returns (bool) {

        if (nftContract != address(0)) {
            revert();
        }

        nftContract = msg.sender;
        return true;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {

        return
            interfaceId == type(INFModuleTokenURI).interfaceId ||
            interfaceId == type(INFModuleWithRoyalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function royaltyInfo(address, uint256 tokenId)
        public
        view
        override
        returns (address recipient, uint256 basisPoint)
    {

        recipient = tokenCreator[tokenId];
        basisPoint = 750;
    }

    function tokenURI(address registry, uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {

        string memory baseURI = groupBaseURI[tokenGroup[tokenId]];
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }


    function bid(uint256 battleId, uint256 contender)
        public
        payable
        nonReentrant
    {

        if (battleId > lastBattleId) {
            revert UnknownBattle();
        }

        Battle storage battle = battles[battleId];

        if (battle.settled) {
            revert AlreadySettled();
        }

        uint256 timestamp = block.timestamp;
        if (!(timestamp >= battle.startsAt && timestamp < battle.endsAt)) {
            revert BattleInactive();
        }

        BattleContender storage auction = _battleContenders[battleId][
            contender
        ];
        if (auction.artist == address(0)) {
            revert WrongContender();
        }

        address sender = msg.sender;

        if (auction.highestBidder == sender) {
            revert NoSelfOutbid();
        }

        uint256 currentBid = msg.value;
        if (
            currentBid <
            ((auction.highestBid * (100 + minimalBidIncrease)) / 100) ||
            currentBid < minimalBid
        ) {
            revert WrongBidValue();
        }

        auction.bidders.add(sender);

        if (auction.highestBid != 0) {
            _sendETHSafe(auction.highestBidder, auction.highestBid);
        }

        auction.highestBidder = sender;
        auction.highestBid = currentBid;

        emit BidCreated(battleId, contender, sender, currentBid);

        uint256 timeBuffer_ = timeBuffer;
        if (timestamp > battle.endsAt - timeBuffer_) {
            battle.endsAt = timestamp + timeBuffer_;
            emit BattleEndChanged(battleId, battle.endsAt);
        }
    }


    function createBattle(
        address[] calldata contenders,
        uint256 startsAt,
        uint256 duration
    ) external onlyOwner {

        uint256 length = contenders.length;
        if (length < 2) {
            revert NotEnoughContenders();
        }

        uint256 battleId = ++lastBattleId;

        Battle storage battle = battles[battleId];

        battle.startsAt = startsAt;
        battle.endsAt = startsAt + duration;
        battle.contenders = length;

        for (uint256 i; i < length; i++) {
            if (contenders[i] == address(0)) {
                revert WrongContender();
            }

            _battleContenders[battleId][i].artist = contenders[i];
        }

        emit BattleCreated(battleId, contenders);
    }

    function cancelBattle(uint256 battleId) external onlyOwner {

        if (battleId > lastBattleId) {
            revert UnknownBattle();
        }

        Battle storage battle = battles[battleId];
        battle.settled = true;

        uint256 length = battle.contenders;
        BattleContender storage contender;

        for (uint256 i; i < length; i++) {
            contender = _battleContenders[battleId][i];
            if (contender.highestBid != 0) {
                _sendETHSafe(contender.highestBidder, contender.highestBid);
            }
        }

        emit BattleCanceled(battleId);
    }

    function settleBattle(uint256 battleId) external onlyOwner {

        if (battleId > lastBattleId) {
            revert UnknownBattle();
        }

        Battle storage battle = battles[battleId];

        if (battle.settled) {
            revert AlreadySettled();
        }

        uint256 timestamp = block.timestamp;
        if (timestamp < battle.endsAt) {
            revert BattleNotEnded();
        }

        battle.settled = true;

        bytes32 seed = keccak256(
            abi.encode(
                block.timestamp,
                msg.sender,
                block.difficulty,
                blockhash(block.number - 1)
            )
        );

        uint256 cumul;
        uint256 temp;
        uint256 length = battle.contenders;

        uint256 currentGroupId_ = currentGroupId;
        address nftContract_ = nftContract;
        BattleContender storage contender;

        for (uint256 i; i < length; i++) {
            contender = _battleContenders[battleId][i];
            cumul += contender.highestBid;

            if (contender.highestBid > 0) {
                temp = INiftyForge721(nftContract_).mint(
                    contender.artist,
                    contender.highestBidder
                );

                seed = keccak256(abi.encode(seed));

                emit BattleContenderResult(
                    battleId,
                    i, // index
                    temp, // tokenId
                    contender.bidders.at(
                        uint256(seed) % contender.bidders.length()
                    )
                );
            } else {
                temp = INiftyForge721(nftContract_).mint(contender.artist);
            }

            _setTokenGroup(temp, currentGroupId_);
            tokenCreator[temp] = contender.artist;
        }

        _sendETHSafe(
            withdrawTarget != address(0) ? withdrawTarget : msg.sender,
            cumul
        );

        emit BattleSettled(battleId, cumul);
    }

    function setBattleStarts(
        uint256 battleId,
        uint256 startsAt,
        uint256 duration
    ) external onlyOwner {

        if (battleId > lastBattleId) {
            revert UnknownBattle();
        }

        Battle storage battle = battles[battleId];

        if (battle.settled) {
            revert AlreadySettled();
        }

        battle.startsAt = startsAt;
        battle.endsAt = startsAt + duration;
        emit BattleStartChanged(battleId, startsAt);
        emit BattleEndChanged(battleId, startsAt + duration);
    }

    function incrementGroup(
        string calldata previousGroupBaseURI,
        string calldata newGroupBaseURI
    ) external onlyOwner {

        _incrementGroup(previousGroupBaseURI, newGroupBaseURI);
    }

    function setGroupURI(uint256 groupId, string calldata baseURI)
        external
        onlyOwner
    {

        _setGroupURI(groupId, baseURI);
    }

    function setGroupsURI(uint256[] calldata groupIds, string calldata baseURI)
        external
        onlyOwner
    {

        for (uint256 i; i < groupIds.length; i++) {
            _setGroupURI(groupIds[i], baseURI);
        }
    }

    function setTokenGroup(uint256 tokenId, uint256 groupId)
        external
        onlyOwner
    {

        _setTokenGroup(tokenId, groupId);
    }

    function setTokensGroup(uint256[] calldata tokenIds, uint256 groupId)
        external
        onlyOwner
    {

        for (uint256 i; i < tokenIds.length; i++) {
            _setTokenGroup(tokenIds[i], groupId);
        }
    }

    function setWithdrawTarget(address newWithdrawTarget) external onlyOwner {

        withdrawTarget = newWithdrawTarget;
    }

    function setMinimals(uint256 newMinimalBid, uint256 newMinimalBidIncrease)
        external
        onlyOwner
    {

        minimalBid = newMinimalBid;
        minimalBidIncrease = newMinimalBidIncrease;
    }


    function _sendETHSafe(address recipient, uint256 value) internal {

        if (value == 0) {
            return;
        }

        (bool success, ) = recipient.call{value: value, gas: 30000}("");

        if (!success) {
            IWETH(wethContract).deposit{value: value}();
            IWETH(wethContract).transfer(recipient, value);
        }
    }
}