
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
}// None


pragma solidity ^0.8.0;


contract OwnerOrAuthorized is Ownable {

    mapping(address => bool) private _authorized;

    event AuthorizationAdded(address indexed addressAdded);
    event AuthorizationRemoved(address addressRemoved);

    constructor() Ownable() {
        _authorized[msg.sender] = true;
    }

    modifier onlyAuthorized() {

        require(
            checkAuthorization(_msgSender()),
            "OwnOwnerOrAuthorized: caller is not authorized"
        );
        _;
    }

    function addAuthorization(address _address) public onlyOwner {

        _authorized[_address] = true;
        emit AuthorizationAdded(_address);
    }

    function removeAuthorization(address _address) public {

        require(
            owner() == _msgSender() || _authorized[_address] == true,
            "OwnOwnerOrAuthorized: caller is not authorized"
        );
        delete _authorized[_address];
        emit AuthorizationRemoved(_address);
    }

    function checkAuthorization(address _address) public view returns (bool) {

        return owner() == _address || _authorized[_address] == true;
    }
}// None


pragma solidity ^0.8.0;


uint256 constant MODIFIER_CARD = 0x40;
uint256 constant HAND_CARD = 0x20;
uint256 constant BITOFFSET_SUIT = 8;
uint256 constant BITOFFSET_BACKGROUND = 16;
uint256 constant BITOFFSET_FOREGROUND = 48;
uint256 constant BITOFFSET_COLOR = 80;
uint256 constant BITOFFSET_SYMBOL = 112;
uint256 constant BITOFFSET_FLAGS = 144;
uint256 constant DEFAULT_BACKGROUND = 0xff00a300;
uint256 constant DEFAULT_MODIFIER_BACKGROUND = 0xff1a1a1a;
uint256 constant DEFAULT_FOREGROUND = 0xff000000;
uint256 constant DEFAULT_COLOR = 0xffffffff;
uint256 constant FLAGS_SET_BACKGROUND = 1;
uint256 constant FLAGS_SET_FOREGROUND = 2;
uint256 constant FLAGS_SET_COLOR = 4;
uint256 constant FLAGS_DATA_APPEND = 8;
bytes constant PRE_SHUFFLED_DECK = hex"190E0F1E2722111D02040B2E13331209150100240A180D16321B25260C312A07282C1C0820142B101A17293006052F2D23211F03";

struct Card {
    uint256 attributes;
    uint256 modifiers;
}

struct ModifierCard {
    address creator;
    uint256 usageCount;
    string name;
    bytes data; // Seems to be a 256 byte limit??
}

struct Reward {
    uint256 timestamp;
    uint256 modifierCardId;
    uint256 symbolId;
    int256 value;
}

contract CryptoCardsStorage is OwnerOrAuthorized {

    bytes private preShuffledDeck = PRE_SHUFFLED_DECK;
    string public baseURI;
    string public baseExtension;
    string public permanentStorageBaseURI;
    string public permanentStorageExtension;
    uint256 public cardCost = 0.1 ether;
    uint256 public handCost = 1 ether;
    uint256 public deckCost = 10 ether;
    uint256 public modifierCost = 2 ether;
    uint256 private deckMintUnlocking = 100;
    uint256 public defaultDeckMintUnlocking = 200;
    uint32 public maxCardsPerDeck = 1000;
    uint32 public maxModifierUsage = 100;
    uint32 public maxSupply = 65535; // Hard limit due to 16 bit numbers use to store modifier ids on cards

    uint32 public maxMintAmount = 10;
    uint32 public rewardPercentage = 50;
    Card[] public cards;
    uint256[] public symbols;
    uint256[] public modifiers;
    address[] public creators;

    mapping(uint256 => address) public handOwners;

    mapping(uint256 => uint256[5]) private handCards;

    mapping(uint256 => uint256) public deckCardCounts;

    mapping(uint256 => ModifierCard) public modifierCards;

    mapping(string => uint256) public modifierCardNames;

    mapping(uint256 => bool) private symbolInUse;

    mapping(uint256 => address) private symbolCreators;

    mapping(address => Reward[]) private creatorRewards;

    mapping(address => uint256) private creatorRewardsBalance;

    mapping(address => bool) private knownCreators;

    mapping(uint256 => bytes) private shuffledDecks;

    mapping(uint256 => bool) public usePermanentStorage;

    constructor(string memory _initBaseURI, string memory _initExtension)
        OwnerOrAuthorized()
    {
        baseURI = _initBaseURI;
        baseExtension = _initExtension;
        permanentStorageBaseURI = _initBaseURI;
        permanentStorageExtension = _initExtension;
    }

    function addCard(Card memory _card)
        external
        onlyAuthorized
        returns (uint256)
    {

        cards.push(_card);
        uint256 symbol = (_card.attributes >> BITOFFSET_SYMBOL) & 0xFFFFFFFF;
        deckCardCounts[symbol]++;
        return cards.length - 1;
    }

    function addSymbol(address _creator, uint256 _symbol)
        external
        onlyAuthorized
    {

        if (!symbolInUse[_symbol]) {
            symbolInUse[_symbol] = true;
            symbolCreators[_symbol] = _creator;
            symbols.push(_symbol);
        }
    }

    function addModifierCard(
        uint256 _cardId,
        address _creator,
        string calldata _name,
        bytes calldata _data
    ) external onlyAuthorized {

        modifierCards[_cardId] = ModifierCard(_creator, 0, _name, _data);
        modifierCardNames[_name] = _cardId;
        modifiers.push(_cardId);
    }

    function addCreatorRewardTransaction(
        address _creator,
        uint256 _modifierCard,
        uint256 _symbol,
        uint256 _amountIn,
        uint256 _amountOut
    ) external onlyAuthorized {

        Reward[] storage rewards = creatorRewards[_creator];
        rewards.push(
            Reward(
                block.timestamp,
                _modifierCard,
                _symbol,
                int256(_amountIn) - int256(_amountOut)
            )
        );
        creatorRewardsBalance[_creator] += _amountIn;
        creatorRewardsBalance[_creator] -= _amountOut;
        if (knownCreators[_creator] == false) {
            knownCreators[_creator] = true;
            creators.push(_creator);
        }
    }

    function decrementDeckMintUnlocking() external onlyAuthorized {

        if (deckMintUnlocking > 0) {
            deckMintUnlocking--;
        }
    }

    function getCard(uint256 _cardId) external view returns (Card memory) {

        return cards[_cardId];
    }

    function getCreators() external view returns (address[] memory) {

        return creators;
    }

    function getCreatorRewards(address _creator)
        external
        view
        onlyAuthorized
        returns (Reward[] memory)
    {

        return creatorRewards[_creator];
    }

    function getCreatorRewardsBalance(address _creator)
        external
        view
        onlyAuthorized
        returns (uint256)
    {

        return creatorRewardsBalance[_creator];
    }

    function getDeckCardCount(uint256 _deckId) external view returns (uint256) {

        return deckCardCounts[_deckId];
    }

    function getDeckMintUnlocking()
        external
        view
        onlyAuthorized
        returns (uint256)
    {

        return deckMintUnlocking;
    }

    function getHandOwner(uint256 _handId) external view returns (address) {

        return handOwners[_handId];
    }

    function getHandCards(uint256 _handId)
        external
        view
        returns (uint256[5] memory)
    {

        return handCards[_handId];
    }

    function getModifierCardCreator(uint256 _cardId)
        external
        view
        returns (address)
    {

        return modifierCards[_cardId].creator;
    }

    function getModifierCardData(uint256 _cardId)
        external
        view
        returns (bytes memory)
    {

        return modifierCards[_cardId].data;
    }

    function getModifierCardIdByName(string calldata _name)
        external
        view
        returns (uint256)
    {

        return modifierCardNames[_name];
    }

    function getModifierCardInUse(uint256 _cardId)
        external
        view
        returns (bool)
    {

        return modifierCards[_cardId].creator != address(0);
    }

    function getModifierCardName(uint256 _cardId)
        external
        view
        returns (string memory)
    {

        return modifierCards[_cardId].name;
    }

    function getModifierCardUsageCount(uint256 _cardId)
        external
        view
        returns (uint256)
    {

        return modifierCards[_cardId].usageCount;
    }

    function getModifiers() external view returns (uint256[] memory) {

        return modifiers;
    }

    function getPreshuffledDeck()
        external
        view
        onlyAuthorized
        returns (bytes memory)
    {

        return preShuffledDeck;
    }

    function getShuffledDeck(uint256 _symbol)
        external
        view
        onlyAuthorized
        returns (bytes memory)
    {

        return shuffledDecks[_symbol];
    }

    function getSymbolInUse(uint256 _symbol) external view returns (bool) {

        return symbolInUse[_symbol];
    }

    function getSymbolCreator(uint256 _symbol) external view returns (address) {

        return symbolCreators[_symbol];
    }

    function getSymbols() external view returns (uint256[] memory) {

        return symbols;
    }

    function getTotalActiveModifiers() external view returns (uint256) {

        uint256 result;
        for (uint256 i; i < modifiers.length; i++) {
            if (modifierCards[i].usageCount < maxModifierUsage) {
                result++;
            }
        }
        return result;
    }

    function getTotalCards() external view returns (uint256) {

        return cards.length;
    }

    function getTotalModifiers() external view returns (uint256) {

        return modifiers.length;
    }

    function getTotalSymbols() external view returns (uint256) {

        return symbols.length;
    }

    function getTotalRewardsBalance() external view returns (uint256) {

        uint256 result;
        for (uint256 i; i < creators.length; i++) {
            if (creators[i] != address(0)) {
                result += creatorRewardsBalance[creators[i]];
            }
        }
        return result;
    }

    function getUsePermanentStorage(uint256 _tokenId)
        external
        view
        returns (bool)
    {

        return usePermanentStorage[_tokenId];
    }

    function incrementModifierCardUsageCount(uint256 _cardId)
        external
        onlyAuthorized
    {

        modifierCards[_cardId].usageCount++;
    }

    function resetDeckMintUnlocking() external onlyAuthorized {

        deckMintUnlocking = defaultDeckMintUnlocking;
    }

    function setDeckMintUnlocking(uint256 _value) external onlyAuthorized {

        deckMintUnlocking = _value;
    }

    function setDefaultDeckMintUnlocking(uint256 _value)
        external
        onlyAuthorized
    {

        defaultDeckMintUnlocking = _value;
    }

    function setBaseURIAndExtension(
        string memory _newBaseURI,
        string memory _newBaseExtension
    ) external onlyAuthorized {

        baseURI = _newBaseURI;
        baseExtension = bytes(_newBaseExtension).length <= 1
            ? ""
            : _newBaseExtension;
    }

    function setPermanentStorageBaseURIAndExtension(
        string memory _newBaseURI,
        string memory _newExtension
    ) external onlyAuthorized {

        permanentStorageBaseURI = _newBaseURI;
        permanentStorageExtension = bytes(_newExtension).length <= 1
            ? ""
            : _newExtension;
    }

    function setCard(uint256 _cardId, Card calldata _value)
        external
        onlyAuthorized
    {

        cards[_cardId] = _value;
    }

    function setCosts(
        uint256 _cardCost,
        uint256 _handCost,
        uint256 _deckCost,
        uint256 _modifierCost
    ) external onlyAuthorized {

        cardCost = _cardCost;
        handCost = _handCost;
        deckCost = _deckCost;
        modifierCost = _modifierCost;
    }

    function setHandCards(uint256 _handId, uint256[5] calldata _cards)
        external
        onlyAuthorized
    {

        handCards[_handId] = _cards;
    }

    function setHandOwner(uint256 _handId, address _owner)
        external
        onlyAuthorized
    {

        handOwners[_handId] = _owner;
    }

    function setLimits(
        uint32 _maxMintAmount,
        uint32 _maxModifierUsage,
        uint32 _maxCardsPerDeck,
        uint32 _maxSupply
    ) external onlyAuthorized {

        if (_maxMintAmount > 0) maxMintAmount = _maxMintAmount;
        if (_maxModifierUsage > 0) maxModifierUsage = _maxModifierUsage;
        if (_maxCardsPerDeck > 0) maxCardsPerDeck = _maxCardsPerDeck;
        if (_maxSupply > 0) maxSupply = _maxSupply > 65535 ? 65535 : _maxSupply;
    }

    function setPreshuffledDeck(bytes memory _value) external onlyAuthorized {

        preShuffledDeck = _value;
    }

    function setRewardPercentage(uint32 _value) external onlyAuthorized {

        if (_value > 0 && _value <= 100) {
            rewardPercentage = _value;
        }
    }

    function setShuffledDeck(uint256 _symbol, bytes memory _value)
        external
        onlyAuthorized
    {

        shuffledDecks[_symbol] = _value;
    }

    function setUsePermanentStorage(uint256 _tokenId, bool _value)
        external
        onlyAuthorized
    {

        usePermanentStorage[_tokenId] = _value;
    }
}