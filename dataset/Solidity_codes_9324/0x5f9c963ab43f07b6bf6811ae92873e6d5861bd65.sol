

pragma solidity 0.8.2;

library RandomNumber {

    function randomNum(uint256 seed) internal returns (uint256) {

        uint256 _number =
            (uint256(
                keccak256(abi.encodePacked(blockhash(block.number - 1), seed))
            ) % 100);
        if (_number <= 0) {
            _number = 1;
        }

        return _number;
    }

    function rand1To10(uint256 seed) internal returns (uint256) {

        uint256 _number =
            (uint256(
                keccak256(abi.encodePacked(blockhash(block.number - 1), seed))
            ) % 10);
        if (_number <= 0) {
            _number = 10;
        }

        return _number;
    }

    function randDecimal(uint256 seed) internal returns (uint256) {

        return (rand1To10(seed) / 10);
    }

    function randomNumberToMax(uint256 seed, uint256 max)
        internal
        returns (uint256)
    {

        return (uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), seed))
        ) % max);
    }

    function randomNumber1ToMax(uint256 seed, uint256 max)
        internal
        returns (uint256)
    {

        uint256 _number =
            (uint256(
                keccak256(abi.encodePacked(blockhash(block.number - 1), seed))
            ) % max);
        if (_number <= 0) {
            _number = max;
        }

        return _number;
    }
}


pragma solidity 0.8.2;

contract Ownable {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


pragma solidity 0.8.2;


contract FighterConfig is Ownable {

    uint256 public currentFighterCost = 50000000000000000 wei;

    string public constant LEGENDARY = "legendary";
    string public constant EPIC = "epic";
    string public constant RARE = "rare";
    string public constant UNCOMMON = "uncommon";
    string public constant COMMON = "common";

    uint256 public maxFighters = 6561;
    uint256 public maxLegendaryFighters = 1;
    uint256 public maxEpicFighters = 5;
    uint256 public maxRareFighters = 25;
    uint256 public maxUncommonFighters = 125;
    uint256 public maxCommonFighters = 500;
    uint256 public maxFightersPerChar = 656;
    string public tokenMetadataEndpoint =
        "https://cryptobrawle.rs/api/getFighterInfo/";
    bool public isTrainingEnabled = false;

    uint256 public trainingFactor = 3;
    uint256 public trainingCost = 5000000000000000 wei; // cost of training in wei

    function setTrainingFactor(uint256 newFactor) external onlyOwner {

        trainingFactor = newFactor;
    }

    function setNewTrainingCost(uint256 newCost) external onlyOwner {

        trainingCost = newCost;
    }

    function enableTraining() external onlyOwner {

        isTrainingEnabled = true;
    }
}


pragma solidity 0.8.2;


contract FighterBase is FighterConfig {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Creation(
        address owner,
        uint256 fighterId,
        uint256 maxHealth,
        uint256 speed,
        uint256 strength,
        string rarity,
        string name,
        string imageHash,
        uint256 mintNum
    );
    event AttributeIncrease(
        address owner,
        uint256 fighterId,
        string attribute,
        uint256 increaseValue
    );
    event Healed(address owner, uint256 fighterId, uint256 maxHealth);

    struct Fighter {
        uint256 maxHealth;
        uint256 health;
        uint256 speed;
        uint256 strength;
        string name;
        string rarity;
        string image;
        uint256 mintNum;
    }


    Fighter[] fighters;
    mapping(uint256 => address) public fighterIdToOwner; // lookup for owner of a specific fighter
    mapping(uint256 => address) public fighterIdToApproved; // Shows appoved address for sending of fighters, Needed for ERC721
    mapping(address => address[]) public ownerToOperators;
    mapping(address => uint256) internal ownedFightersCount;

    string[] public availableFighterNames;
    mapping(string => uint256) public indexOfAvailableFighterName;

    mapping(string => uint256) public rarityToSkillBuff;
    mapping(string => uint256) public fighterNameToMintedCount;
    mapping(string => mapping(string => string))
        public fighterNameToRarityImageHashes;
    mapping(string => mapping(string => uint256))
        public fighterNameToRarityCounts;

    function getMintedCountForFighterRarity(
        string memory _fighterName,
        string memory _fighterRarity
    ) external view returns (uint256 mintedCount) {

        return fighterNameToRarityCounts[_fighterName][_fighterRarity];
    }

    function addFighterCharacter(
        string memory newName,
        string memory legendaryImageHash,
        string memory epicImageHash,
        string memory rareImageHash,
        string memory uncommonImageHash,
        string memory commonImageHash
    ) external onlyOwner {

        indexOfAvailableFighterName[newName] = availableFighterNames.length;
        availableFighterNames.push(newName);
        fighterNameToMintedCount[newName] = 0;

        fighterNameToRarityImageHashes[newName][LEGENDARY] = legendaryImageHash;
        fighterNameToRarityImageHashes[newName][EPIC] = epicImageHash;
        fighterNameToRarityImageHashes[newName][RARE] = rareImageHash;
        fighterNameToRarityImageHashes[newName][UNCOMMON] = uncommonImageHash;
        fighterNameToRarityImageHashes[newName][COMMON] = commonImageHash;

        fighterNameToRarityCounts[newName][LEGENDARY] = 0;
        fighterNameToRarityCounts[newName][EPIC] = 0;
        fighterNameToRarityCounts[newName][RARE] = 0;
        fighterNameToRarityCounts[newName][UNCOMMON] = 0;
        fighterNameToRarityCounts[newName][COMMON] = 0;
    }

    function _owns(address _claimant, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        return fighterIdToOwner[_tokenId] == _claimant;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _fighterId
    ) internal {

        fighterIdToOwner[_fighterId] = _to;
        ownedFightersCount[_to]++;

        if (_from != address(0)) {
            fighterIdToApproved[_fighterId] = address(0);
            ownedFightersCount[_from]--;
        }
        emit Transfer(_from, _to, _fighterId);
    }

    function _createFighter(
        uint256 _maxHealth,
        uint256 _speed,
        uint256 _strength,
        address _owner,
        string memory _rarity,
        string memory _name,
        uint256 _mintNum
    ) internal returns (uint256) {

        string memory _fighterImage =
            fighterNameToRarityImageHashes[_name][_rarity];
        Fighter memory _fighter =
            Fighter({
                maxHealth: _maxHealth,
                health: _maxHealth, // Fighters are always created with maximum health
                speed: _speed,
                strength: _strength,
                name: _name,
                rarity: _rarity,
                image: _fighterImage,
                mintNum: _mintNum
            });

        uint256 newFighterId = fighters.length;
        fighters.push(_fighter);

        emit Creation(
            _owner,
            newFighterId,
            _maxHealth,
            _speed,
            _strength,
            _rarity,
            _name,
            _fighterImage,
            _mintNum
        );

        _transfer(address(0), _owner, newFighterId);

        return newFighterId;
    }

    function _updateFighterInStorage(
        Fighter memory _updatedFighter,
        uint256 _fighterId
    ) internal {

        fighters[_fighterId] = _updatedFighter;
    }

    function _trainSpeed(
        uint256 _fighterId,
        uint256 _attributeIncrease,
        address _owner
    ) internal {

        Fighter memory _fighter = fighters[_fighterId];
        _fighter.speed += _attributeIncrease;
        _updateFighterInStorage(_fighter, _fighterId);

        emit AttributeIncrease(_owner, _fighterId, "speed", _attributeIncrease);
    }

    function _trainStrength(
        uint256 _fighterId,
        uint256 _attributeIncrease,
        address _owner
    ) internal {

        Fighter memory _fighter = fighters[_fighterId];
        _fighter.strength += _attributeIncrease;
        _updateFighterInStorage(_fighter, _fighterId);

        emit AttributeIncrease(
            _owner,
            _fighterId,
            "strength",
            _attributeIncrease
        );
    }
}


pragma solidity 0.8.2;



contract MarketplaceConfig is Ownable, FighterBase {

    uint256 public marketplaceCut = 5;
    struct Combatant {
        uint256 fighterId;
        Fighter fighter;
        uint256 damageModifier;
    }

    struct Sale {
        uint256 fighterId;
        uint256 price;
    }

    mapping(uint256 => Sale) public fighterIdToSale; // Storing of figher Ids against their sale Struct
    mapping(uint256 => uint256) public fighterIdToBrawl; // Map of fighter Ids to their max health

    event PurchaseSuccess(
        address buyer,
        uint256 price,
        uint256 fighterId,
        address seller
    );
    event FightComplete(
        address winner,
        uint256 winnerId,
        address loser,
        uint256 loserId
    );

    event MarketplaceRemoval(address owner, uint256 fighterId);
    event ArenaRemoval(address owner, uint256 fighterId);

    event MarketplaceAdd(address owner, uint256 fighterId, uint256 price);
    event ArenaAdd(address owner, uint256 fighterId);

    function setNewMarketplaceCut(uint256 _newCut) external onlyOwner {

        marketplaceCut = _newCut;
    }

    function withdrawBalance() external onlyOwner {

        payable(owner).transfer(address(this).balance);
    }

    function withdrawBalanceToAddress(address _recipient) external onlyOwner {

        payable(_recipient).transfer(address(this).balance);
    }

    function killContract() external onlyOwner {

        selfdestruct(payable(owner));
    }

    function _calculateCut(uint256 _totalPrice) internal returns (uint256) {

        return ((_totalPrice / 100) * marketplaceCut);
    }

    function _fighterIsForSale(uint256 _fighterId) internal returns (bool) {

        return (fighterIdToSale[_fighterId].price > 0);
    }

    function _fighterIsForBrawl(uint256 _fighterId) internal returns (bool) {

        return (fighterIdToBrawl[_fighterId] > 0);
    }

    function _removeFighterFromSale(uint256 _fighterId) internal {

        delete fighterIdToSale[_fighterId];
    }

    function _removeFighterFromArena(uint256 _fighterId) internal {

        delete fighterIdToBrawl[_fighterId];
    }
}


pragma solidity 0.8.2;



contract Marketplace is MarketplaceConfig {

    function getPriceForFighter(uint256 _fighterId) external returns (uint256) {

        return fighterIdToSale[_fighterId].price;
    }

    function removeFighterFromSale(uint256 _fighterId) external {

        require(_owns(msg.sender, _fighterId));
        require(_fighterIsForSale(_fighterId));

        _removeFighterFromSale(_fighterId);
        emit MarketplaceRemoval(msg.sender, _fighterId);
    }

    function removeFighterFromArena(uint256 _fighterId) external {

        require(_owns(msg.sender, _fighterId));
        require(_fighterIsForBrawl(_fighterId));

        _removeFighterFromArena(_fighterId);
        emit ArenaRemoval(msg.sender, _fighterId);
    }

    function makeFighterAvailableForSale(uint256 _fighterId, uint256 _price)
        external
    {

        require(_owns(msg.sender, _fighterId));
        require(!_fighterIsForBrawl(_fighterId));
        require(_price > 0);

        require(fighterIdToApproved[_fighterId] == address(0));

        fighterIdToSale[_fighterId] = Sale({
            fighterId: _fighterId,
            price: _price
        });
        emit MarketplaceAdd(msg.sender, _fighterId, _price);
    }

    function makeFighterAvailableForBrawl(uint256 _fighterId) external {

        require(_owns(msg.sender, _fighterId));
        require(!_fighterIsForSale(_fighterId));
        require(!_fighterIsForBrawl(_fighterId));

        require(fighterIdToApproved[_fighterId] == address(0));

        fighterIdToBrawl[_fighterId] = _fighterId;
        emit ArenaAdd(msg.sender, _fighterId);
    }

    function buyFighter(uint256 _fighterId) external payable {

        address _seller = fighterIdToOwner[_fighterId];
        _makePurchase(_fighterId, msg.value);
        _transfer(_seller, msg.sender, _fighterId);

        emit PurchaseSuccess(msg.sender, msg.value, _fighterId, _seller);
    }

    function _strike(
        uint256 _attackerId,
        uint256 _defenderId,
        uint256 _attackerStrength,
        uint256 _defenderStrength,
        uint256 _seed
    ) internal returns (bool) {

        uint256 _attackerAttackRoll =
            RandomNumber.randomNumber1ToMax(_seed, 20) + _attackerStrength;
        uint256 _defenderDefenseRoll =
            RandomNumber.randomNumber1ToMax(_seed * 3, 20) + _defenderStrength;

        if (_attackerAttackRoll >= _defenderDefenseRoll) {
            return true;
        }

        return false;
    }

    function _performFight(
        uint256 _attackerId,
        uint256 _defenderId,
        Fighter memory _attacker,
        Fighter memory _defender,
        uint256 _seed
    ) internal returns (uint256 winnerId, uint256 loserId) {

        uint256 _generatedSeed =
            RandomNumber.randomNumber1ToMax(_seed, 99999999);
        uint256 _totalSpeed = _attacker.speed + _defender.speed;
        uint256 _attackerSpeedRoll =
            RandomNumber.randomNumber1ToMax(_seed, 20) + _attacker.speed;
        uint256 _defenderSpeedRoll =
            RandomNumber.randomNumber1ToMax(_generatedSeed, 20) +
                _defender.speed;

        bool _attackerIsStrikingFirst =
            _attackerSpeedRoll >= _defenderSpeedRoll;

        if (_attackerIsStrikingFirst) {
            if (
                _strike(
                    _attackerId,
                    _defenderId,
                    _attacker.strength,
                    _defender.strength,
                    _seed * 2
                )
            ) {
                return (_attackerId, _defenderId);
            }
        } else {
            if (
                _strike(
                    _defenderId,
                    _attackerId,
                    _defender.strength,
                    _attacker.strength,
                    _generatedSeed * 2
                )
            ) {
                return (_defenderId, _attackerId);
            }
        }

        if (_attackerIsStrikingFirst) {
            if (
                _strike(
                    _defenderId,
                    _attackerId,
                    _defender.strength,
                    _attacker.strength,
                    _generatedSeed * 3
                )
            ) {
                return (_defenderId, _attackerId);
            }
        } else {
            if (
                _strike(
                    _attackerId,
                    _defenderId,
                    _attacker.strength,
                    _defender.strength,
                    _seed * 3
                )
            ) {
                return (_attackerId, _defenderId);
            }
        }

        uint256 _defenderEndCheck =
            _defender.speed +
                _defender.strength +
                RandomNumber.randomNumber1ToMax(_generatedSeed, 20);
        uint256 _attackerEndCheck =
            _attacker.speed +
                _attacker.strength +
                RandomNumber.randomNumber1ToMax(_seed, 20);

        if (_defenderEndCheck >= _attackerEndCheck) {
            return (_defenderId, _attackerId);
        }
        return (_attackerId, _defenderId);
    }

    function fight(
        uint256 _attackerId,
        uint256 _defenderId,
        uint256 _seed
    ) external {

        Fighter memory _attacker = fighters[_attackerId];
        Fighter memory _defender = fighters[_defenderId];
        require(_fighterIsForBrawl(_defenderId));
        require(_owns(msg.sender, _attackerId));
        require(!_owns(msg.sender, _defenderId));
        require(
            (_attacker.speed + _attacker.strength) <=
                (_defender.speed + _defender.strength)
        );

        (uint256 _winnerId, uint256 _loserId) =
            _performFight(
                _attackerId,
                _defenderId,
                _attacker,
                _defender,
                _seed
            );

        if (_fighterIsForBrawl(_winnerId)) {
            _removeFighterFromArena(_winnerId);
        } else {
            _removeFighterFromArena(_loserId);
        }
        address _winnerAddress = fighterIdToOwner[_winnerId];
        address _loserAddress = fighterIdToOwner[_loserId];

        _transfer(_loserAddress, _winnerAddress, _loserId);
        emit FightComplete(_winnerAddress, _winnerId, _loserAddress, _loserId);
    }

    function _makePurchase(uint256 _fighterId, uint256 _price) internal {

        require(!_owns(msg.sender, _fighterId));
        require(_fighterIsForSale(_fighterId));
        require(_price >= fighterIdToSale[_fighterId].price);

        address sellerAddress = fighterIdToOwner[_fighterId];
        _removeFighterFromSale(_fighterId);

        uint256 saleCut = _calculateCut(_price);
        uint256 totalSale = _price - saleCut;
        payable(sellerAddress).transfer(totalSale);
    }
}


pragma solidity 0.8.2;

library Integers {

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
}


pragma solidity 0.8.2;

abstract contract ERC721 {
    function totalSupply() public view virtual returns (uint256 total) {}

    function balanceOf(address _owner)
        public
        view
        virtual
        returns (uint256 balance)
    {}

    function ownerOf(uint256 _tokenId)
        external
        view
        virtual
        returns (address owner)
    {}

    function approve(address _to, uint256 _tokenId) external virtual {}

    function transfer(address _to, uint256 _tokenId) external virtual {}

    function tokenURI(uint256 _tokenId)
        external
        view
        virtual
        returns (string memory _tokenURI)
    {}

    function baseURI() external view virtual returns (string memory _baseURI) {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external virtual {}

    function getApproved(uint256 _tokenId)
        external
        virtual
        returns (address _approvedAddress)
    {}

    function setApprovalForAll(address _to, bool approved) external virtual {}

    function isApprovedForAll(address _owner, address _operator)
        external
        virtual
        returns (bool isApproved)
    {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external virtual {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external virtual {}

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function _isContract(address _addr)
        internal
        view
        returns (bool isContract)
    {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function supportsInterface(bytes4 _interfaceID)
        external
        view
        virtual
        returns (bool)
    {}

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external virtual returns (bytes4) {}
}


pragma solidity 0.8.2;

contract Priced {

    modifier costs(uint256 price) {

        if (msg.value >= price) {
            _;
        }
    }
}


pragma solidity 0.8.2;


contract Pausable is Ownable {

    bool public isPaused = false;

    modifier whenNotPaused() {

        require(!isPaused);
        _;
    }

    function pause() external onlyOwner {

        isPaused = true;
    }

    function unPause() external onlyOwner {

        isPaused = false;
    }
}


pragma solidity ^0.8.2;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}


pragma solidity 0.8.2;


contract FighterTraining is FighterBase {

    function _train(
        uint256 _fighterId,
        string memory _attribute,
        uint256 _attributeIncrease
    ) internal {

        if (
            keccak256(abi.encodePacked(_attribute)) ==
            keccak256(abi.encodePacked("strength"))
        ) {
            _trainStrength(_fighterId, _attributeIncrease, msg.sender);
        } else if (
            keccak256(abi.encodePacked(_attribute)) ==
            keccak256(abi.encodePacked("speed"))
        ) {
            _trainSpeed(_fighterId, _attributeIncrease, msg.sender);
        }
    }
}


pragma solidity 0.8.2;











contract FighterOwnership is
    FighterConfig,
    FighterBase,
    FighterTraining,
    ERC721,
    Priced,
    Pausable,
    MarketplaceConfig
{

    using Integers for uint256;
    string public constant name = "CryptoBrawlers";
    string public constant symbol = "BRAWLER";
    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    function supportsInterface(bytes4 _interfaceID)
        external
        view
        override
        returns (bool)
    {

        return ((_interfaceID == InterfaceSignature_ERC165) ||
            (_interfaceID == _INTERFACE_ID_ERC721) ||
            (_interfaceID == _INTERFACE_ID_ERC721_METADATA));
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external pure override returns (bytes4) {

        revert();
    }


    function _approvedFor(address _claimant, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        if (fighterIdToApproved[_tokenId] == _claimant) {
            return true;
        }

        bool _senderIsOperator = false;
        address _owner = fighterIdToOwner[_tokenId];
        address[] memory _validOperators = ownerToOperators[_owner];

        uint256 _operatorIndex;
        for (
            _operatorIndex = 0;
            _operatorIndex < _validOperators.length;
            _operatorIndex++
        ) {
            if (_validOperators[_operatorIndex] == _claimant) {
                _senderIsOperator = true;
                break;
            }
        }

        return _senderIsOperator;
    }

    function _approve(uint256 _tokenId, address _approved) internal {

        fighterIdToApproved[_tokenId] = _approved;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 count)
    {

        require(_owner != address(0));
        return ownedFightersCount[_owner];
    }

    function transfer(address _to, uint256 _tokenId) external override {

        require(_to != address(0));
        require(_to != address(this));
        require(_owns(msg.sender, _tokenId));
        if (_fighterIsForBrawl(_tokenId)) {
            _removeFighterFromArena(_tokenId);
            emit ArenaRemoval(msg.sender, _tokenId);
        }

        if (_fighterIsForSale(_tokenId)) {
            _removeFighterFromSale(_tokenId);
            emit MarketplaceRemoval(msg.sender, _tokenId);
        }

        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) external override {

        require(_owns(msg.sender, _tokenId));

        if (_fighterIsForBrawl(_tokenId)) {
            _removeFighterFromArena(_tokenId);
            emit ArenaRemoval(msg.sender, _tokenId);
        }

        if (_fighterIsForSale(_tokenId)) {
            _removeFighterFromSale(_tokenId);
            emit MarketplaceRemoval(msg.sender, _tokenId);
        }
        _approve(_tokenId, _to);

        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external override {

        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        if (_fighterIsForBrawl(_tokenId)) {
            _removeFighterFromArena(_tokenId);
            emit ArenaRemoval(msg.sender, _tokenId);
        }

        if (_fighterIsForSale(_tokenId)) {
            _removeFighterFromSale(_tokenId);
            emit MarketplaceRemoval(msg.sender, _tokenId);
        }

        _transfer(_from, _to, _tokenId);
        _approve(_tokenId, address(0));
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {

        if (_fighterIsForBrawl(_tokenId)) {
            _removeFighterFromArena(_tokenId);
            emit ArenaRemoval(msg.sender, _tokenId);
        }

        if (_fighterIsForSale(_tokenId)) {
            _removeFighterFromSale(_tokenId);
            emit MarketplaceRemoval(msg.sender, _tokenId);
        }

        _transfer(_from, _to, _tokenId);
        _approve(_tokenId, address(0));
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external override {

        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        _safeTransferFrom(_from, _to, _tokenId);

        if (_isContract(_to)) {
            bytes4 retval =
                IERC721Receiver(_to).onERC721Received(_from, _to, _tokenId, "");
            require(ERC721_RECEIVED == retval);
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external override {

        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        _safeTransferFrom(_from, _to, _tokenId);

        if (_isContract(_to)) {
            bytes4 retval =
                IERC721Receiver(_to).onERC721Received(
                    _from,
                    _to,
                    _tokenId,
                    _data
                );
            require(ERC721_RECEIVED == retval);
        }
    }

    function getApproved(uint256 _tokenId)
        external
        view
        override
        returns (address _approvedAddress)
    {

        return fighterIdToApproved[_tokenId];
    }

    function setApprovalForAll(address _to, bool _approved) external override {

        address[] memory _operatorsForSender = ownerToOperators[msg.sender];
        if (_approved) {
            ownerToOperators[msg.sender].push(_to);
        }

        if (!_approved) {
            if (ownerToOperators[msg.sender].length == 0) {
                emit ApprovalForAll(msg.sender, _to, false);
                return;
            }

            uint256 _operatorIndex;
            for (
                _operatorIndex = 0;
                _operatorIndex < _operatorsForSender.length;
                _operatorIndex++
            ) {
                if (ownerToOperators[msg.sender][_operatorIndex] == _to) {
                    ownerToOperators[msg.sender][
                        _operatorIndex
                    ] = ownerToOperators[msg.sender][
                        ownerToOperators[msg.sender].length - 1
                    ];
                    ownerToOperators[msg.sender].pop();
                    break;
                }
            }
        }

        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool isApproved)
    {

        address[] memory _operatorsForSender = ownerToOperators[_owner];

        if (_operatorsForSender.length == 0) {
            return false;
        }
        bool _isApproved = true;
        uint256 _operatorIndex;
        for (
            _operatorIndex = 0;
            _operatorIndex < _operatorsForSender.length;
            _operatorIndex++
        ) {
            if (_operatorsForSender[_operatorIndex] != _operator) {
                _isApproved = false;
                break;
            }
        }

        return _isApproved;
    }

    function totalSupply() public view override returns (uint256) {

        return fighters.length - 1; // -1 because of the phantom 0 index fighter that doesn't play nicely
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address owner)
    {

        owner = fighterIdToOwner[_tokenId];
        require(owner != address(0));

        return owner;
    }

    function tokenURI(uint256 _tokenId)
        external
        view
        override
        returns (string memory)
    {

        return
            string(
                abi.encodePacked(tokenMetadataEndpoint, _tokenId.toString())
            );
    }

    function baseURI() external view override returns (string memory) {

        return tokenMetadataEndpoint;
    }

    modifier currentFighterPrice() {

        require(msg.value >= currentFighterCost);
        _;
    }

    function trainFighter(
        uint256 _fighterId,
        string memory _attribute,
        uint256 _seed
    ) external payable costs(trainingCost) returns (uint256 _increaseValue) {

        require(isTrainingEnabled);
        require(_owns(msg.sender, _fighterId));
        uint256 _attributeIncrease =
            (RandomNumber.rand1To10(_seed) / trainingFactor);
        if (_attributeIncrease == 0) {
            _attributeIncrease = 1;
        }

        _train(_fighterId, _attribute, _attributeIncrease);
        return _attributeIncrease;
    }

    function _getFighterRarity(uint256 _seed, string memory _fighterName)
        internal
        returns (string memory)
    {

        uint256 _rarityRoll =
            RandomNumber.randomNumber1ToMax(_seed, maxFightersPerChar);
        uint256 _minEpicRoll =
            maxFightersPerChar - (maxEpicFighters + maxLegendaryFighters);
        uint256 _minRareRoll =
            maxFightersPerChar -
                (maxRareFighters + maxEpicFighters + maxLegendaryFighters);
        uint256 _minUncommonRoll =
            maxFightersPerChar -
                (maxUncommonFighters +
                    maxRareFighters +
                    maxEpicFighters +
                    maxLegendaryFighters);

        if (
            fighterNameToRarityCounts[_fighterName][LEGENDARY] <
            maxLegendaryFighters &&
            _rarityRoll == maxFightersPerChar
        ) {
            return LEGENDARY;
        }
        if (
            fighterNameToRarityCounts[_fighterName][EPIC] < maxEpicFighters &&
            _rarityRoll >= _minEpicRoll
        ) {
            return EPIC;
        }
        if (
            fighterNameToRarityCounts[_fighterName][RARE] < maxRareFighters &&
            _rarityRoll >= _minRareRoll
        ) {
            return RARE;
        }
        if (
            fighterNameToRarityCounts[_fighterName][UNCOMMON] <
            maxUncommonFighters &&
            _rarityRoll >= _minUncommonRoll
        ) {
            return UNCOMMON;
        }
        if (
            fighterNameToRarityCounts[_fighterName][COMMON] <
            maxCommonFighters &&
            _rarityRoll >= 1
        ) {
            return COMMON;
        }

        string[] memory _leftoverRarities;
        if (
            fighterNameToRarityCounts[_fighterName][LEGENDARY] <
            maxLegendaryFighters
        ) {
            _leftoverRarities[_leftoverRarities.length] = LEGENDARY;
        }
        if (fighterNameToRarityCounts[_fighterName][EPIC] < maxEpicFighters) {
            _leftoverRarities[_leftoverRarities.length] = EPIC;
        }
        if (fighterNameToRarityCounts[_fighterName][RARE] < maxRareFighters) {
            _leftoverRarities[_leftoverRarities.length] = RARE;
        }
        if (
            fighterNameToRarityCounts[_fighterName][UNCOMMON] <
            maxUncommonFighters
        ) {
            _leftoverRarities[_leftoverRarities.length] = UNCOMMON;
        }
        if (
            fighterNameToRarityCounts[_fighterName][COMMON] < maxCommonFighters
        ) {
            _leftoverRarities[_leftoverRarities.length] = COMMON;
        }

        if (_leftoverRarities.length == 1) {
            return _leftoverRarities[0];
        }

        uint256 _leftoverRoll =
            RandomNumber.randomNumberToMax(_seed, _leftoverRarities.length);
        return _leftoverRarities[_leftoverRoll];
    }

    function _getFighterName(uint256 _seed)
        internal
        returns (string memory _fighterName)
    {

        uint256 _nameIndex =
            RandomNumber.randomNumberToMax(_seed, availableFighterNames.length); // Use the whole array length because the random max number does not include the top end
        return availableFighterNames[_nameIndex];
    }

    function _removeNameFromAvailableNamesArray(string memory _fighterName)
        internal
    {

        uint256 _nameIndex = indexOfAvailableFighterName[_fighterName];
        require(
            keccak256(abi.encodePacked(availableFighterNames[_nameIndex])) ==
                keccak256(abi.encodePacked(_fighterName))
        ); // double check something wiggly hasn't happened

        if (availableFighterNames.length > 1) {
            availableFighterNames[_nameIndex] = availableFighterNames[
                availableFighterNames.length - 1
            ];
        }
        availableFighterNames.pop();
    }

    function searchForFighter(uint256 _seed)
        external
        payable
        currentFighterPrice
        whenNotPaused()
        returns (uint256 newFighterId)
    {

        require(fighters.length < maxFighters);
        string memory _fighterName = _getFighterName(_seed);
        string memory _fighterRarity = _getFighterRarity(_seed, _fighterName);
        uint256 _speed =
            RandomNumber.rand1To10(_seed) + rarityToSkillBuff[_fighterRarity];
        uint256 _strength =
            RandomNumber.rand1To10(_speed + _seed) +
                rarityToSkillBuff[_fighterRarity];

        fighterNameToMintedCount[_fighterName] += 1;
        fighterNameToRarityCounts[_fighterName][_fighterRarity] += 1;

        uint256 _fighterId =
            _createFighter(
                10,
                _speed,
                _strength,
                msg.sender,
                _fighterRarity,
                _fighterName,
                fighterNameToRarityCounts[_fighterName][_fighterRarity]
            );

        if (fighterNameToMintedCount[_fighterName] >= maxFightersPerChar) {
            _removeNameFromAvailableNamesArray(_fighterName);
        }

        uint256 _fighterCost = _getFighterCost();
        if (_fighterCost > currentFighterCost) {
            currentFighterCost = _fighterCost;
        }

        return _fighterId;
    }

    function _getFighterCost() internal returns (uint256 _cost) {

        uint256 currentTotalFighters = fighters.length - 1;

        if (currentTotalFighters < 500) {
            return 50000000000000000 wei;
        }
        if (currentTotalFighters >= 500 && currentTotalFighters < 1000) {
            return 100000000000000000 wei;
        }
        if (currentTotalFighters >= 1000 && currentTotalFighters < 1500) {
            return 150000000000000000 wei;
        }
        if (currentTotalFighters >= 1500 && currentTotalFighters < 2000) {
            return 200000000000000000 wei;
        }
        if (currentTotalFighters >= 2000 && currentTotalFighters < 2500) {
            return 250000000000000000 wei;
        }
        if (currentTotalFighters >= 2500 && currentTotalFighters < 3000) {
            return 300000000000000000 wei;
        }
        if (currentTotalFighters >= 3000 && currentTotalFighters < 3500) {
            return 350000000000000000 wei;
        }
        if (currentTotalFighters >= 3500 && currentTotalFighters < 4000) {
            return 400000000000000000 wei;
        }
        if (currentTotalFighters >= 4000 && currentTotalFighters < 4500) {
            return 450000000000000000 wei;
        }
        if (currentTotalFighters >= 4500 && currentTotalFighters < 5000) {
            return 500000000000000000 wei;
        }
        if (currentTotalFighters >= 5000 && currentTotalFighters < 5500) {
            return 550000000000000000 wei;
        }
        if (currentTotalFighters >= 5500 && currentTotalFighters < 6000) {
            return 600000000000000000 wei;
        }
        if (currentTotalFighters >= 6000) {
            return 650000000000000000 wei;
        }
        return 650000000000000000 wei;
    }
}


pragma solidity 0.8.2;



contract CryptoBrawlers is Marketplace, FighterOwnership {

    constructor() {
        rarityToSkillBuff[LEGENDARY] = 10;
        rarityToSkillBuff[EPIC] = 5;
        rarityToSkillBuff[RARE] = 3;
        rarityToSkillBuff[UNCOMMON] = 1;
        rarityToSkillBuff[COMMON] = 0;

        fighters.push(); // phantom 0 index element in the fighters array to begin
    }

    function getInfoForFighter(uint256 _fighterId)
        external
        returns (
            uint256 health,
            uint256 speed,
            uint256 strength,
            string memory fighterName,
            string memory image,
            string memory rarity,
            uint256 mintNum
        )
    {

        Fighter memory _fighter = fighters[_fighterId];
        return (
            _fighter.health,
            _fighter.speed,
            _fighter.strength,
            _fighter.name,
            _fighter.image,
            _fighter.rarity,
            _fighter.mintNum
        );
    }
}