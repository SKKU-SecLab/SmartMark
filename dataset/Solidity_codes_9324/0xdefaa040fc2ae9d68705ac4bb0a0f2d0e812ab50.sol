
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


interface IEggs is IERC721 {

    function mint(address to, uint256 tokenId) external;

    function burn(uint256 tokenId) external;

    function getUsersTokens(address _owner) external view returns (uint256[] memory);

}

interface ICreatures is IERC721 {

    function mint(
        address to, 
        uint256 tokenId, 
        uint8 _animalType,
        uint8 _rarity,
        uint32 index
        ) external;


    function getTypeAndRarity(uint256 _tokenId) external view returns(uint8, uint8);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

}

interface ILand is IERC721 {

    function mint(
        address to, 
        uint256 tokenId,
        uint randomSeed
    ) external;

    function burn(uint256 tokenId) external;

}

interface IDung is IERC20 {

    function mint(
        address to, 
        uint256 amount 
    ) external;

}

interface IInventory is IERC1155 {

     function getToolBoost(uint8 _item) external view returns (uint16);

}

interface IAmuletPriceProvider {

     function getLastPrice(address _amulet) external view returns (uint256);

}

interface IOperatorManage {

    function addOperator(address _newOperator) external;    

    function removeOperator(address _oldOperator) external;

    function withdrawERC20(IERC20 _tokenContract, address _admin) external;

    function setSigner(address _newSigner) external;

}

abstract contract DegenFarmBase is ERC1155Receiver, Ownable {
    enum AnimalType {
        Cow, Horse, Rabbit, Chicken, Pig, Cat, Dog, Goose, Goat, Sheep,
        Snake, Fish, Frog, Worm, Lama, Mouse, Camel, Donkey, Bee, Duck,
        GenesisEgg // 20
    }
    enum Rarity {
        Normie, // 0
        Chad,   // 1
        Degen,  // 2
        Unique // 3
    }
    enum   Result     {Fail,   Dung,  Chad, Degen}
    
    struct AddressRegistry {
        address land;
        address creatures;
        address inventory;
        address bagstoken;
        address dungtoken;
    }

    struct CreaturesCount {
        uint16 totalNormie;
        uint16 leftNormie;
        uint16 totalChad;
        uint16 leftChadToDiscover;
        uint16 totalDegen;
        uint16 leftDegenToDiscover;
        uint16 chadFarmAttempts;
        uint16 degenFarmAttempts;
    }

    struct LandCount {
        uint16 total;
        uint16 left;
    }
 
    struct FarmRecord {
        uint256   creatureId;
        uint256   landId;
        uint256   harvestTime;
        uint256   amuletsPrice1;
        uint256   amuletsPrice2;
        Result    harvest;
        uint256   harvestId; // new NFT tokenId
        bool[COMMON_AMULET_COUNT]   commonAmuletInitialHold;
    }

    struct Bonus {
        uint256 commonAmuletHold;  // common amulet hold
        uint256 creatureAmuletBullTrend;
        uint256 inventoryHold;
        uint256 creatureAmuletBalance;
    }

    uint8   constant public CREATURE_TYPE_COUNT_MAX = 20;  //how much creatures types may be used

    uint32  constant public CREATURE_P_MULT = 230;
    uint16  public MAX_ALL_NORMIES    = getCreatureTypeCount() * getNormieCountInType();
    uint256 constant public NFT_ID_MULTIPLIER  = 10000;     //must be set more then all Normies count
    uint256 constant public FARM_DUNG_AMOUNT   = 250e33;      //per one harvest
    uint256 constant public BONUS_POINTS_AMULET_HOLD       = 10;
    uint256 constant public COMMON_AMULET_COUNT       = 2;
    uint256 constant public TOOL_TYPE_COUNT = 6;

    address[COMMON_AMULET_COUNT] public COMMON_AMULETS = [
        0x126c121f99e1E211dF2e5f8De2d96Fa36647c855, // $DEGEN token
        0xa0246c9032bC3A600820415aE600c6388619A14D  // $FARM token
    ];

    bool    public REVEAL_ENABLED  = false;
    bool    public FARMING_ENABLED = false;
    address public priceProvider;
    IEggs   public eggs;
    
    address[CREATURE_TYPE_COUNT_MAX] public amulets; // amulets by creature type
    AddressRegistry                  public farm;
    LandCount                        public landCount;

    mapping(address => uint256) public maxAmuletBalances;

    mapping(address => uint256[TOOL_TYPE_COUNT]) public userStakedTools;


    uint16 public allNormiesesLeft;
    CreaturesCount[CREATURE_TYPE_COUNT_MAX] public creaturesBorn;
    FarmRecord[] public farming;
    mapping(uint => uint) public parents;

    event Reveal(address _farmer, uint256 indexed _tokenId, bool _isCreature, uint8 _animalType);
    event Harvest(
        uint256 indexed _eggId, 
        address farmer, 
        uint8   result,
        uint256 baseChance,
        uint256 commonAmuletHold,
        uint256 amuletBullTrend,
        uint256 inventoryHold,
        uint256 amuletMaxBalance,
        uint256 resultChance
    );
    event Stake(address owner, uint8 innventory);
    event UnStake(address owner, uint8 innventory);
    
    constructor (
        address _land, 
        address _creatures,
        address _inventory,
        address _bagstoken,
        address _dungtoken,
        IEggs _eggs
    )
    {
        farm.land      = _land;
        farm.creatures = _creatures;
        farm.inventory = _inventory;
        farm.bagstoken = _bagstoken;
        farm.dungtoken = _dungtoken;
        
        for (uint i = 0; i < getCreatureTypeCount(); i++) {
            creaturesBorn[i] = CreaturesCount(
                getNormieCountInType(), // totalNormie;
                getNormieCountInType(), // leftNormie;
                getChadCountInType(),   // totalChad;
                getChadCountInType(),   // leftChadToDiscover;
                1,                      // totalDegen;
                1,                      // leftDegenToDiscover;
                0, // chadFarmAttempts;
                0);  // degenFarmAttempts;
        }

        landCount        = LandCount(getMaxLands(), getMaxLands());
        allNormiesesLeft = MAX_ALL_NORMIES;
        eggs = _eggs;
    }

    function reveal(uint count) external {
        require(_isRevelEnabled(), "Please wait for reveal enabled.");
        require(count > 0, "Count must be positive");
        require(count <= 8, "Count must less than 9"); // random limit
        require(
            IERC20(farm.bagstoken).allowance(msg.sender, address(this)) >= count*1,
            "Please approve your BAGS token to this contract."
        );
        require(
            IERC20(farm.bagstoken).transferFrom(msg.sender, address(this), count*1)
        );
        uint randomSeed = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        for (uint i = 0; i < count; i++) {
            _reveal(randomSeed);
            randomSeed = randomSeed / 0x100000000; // shift right 32 bits
        }
    }

    function farmDeploy(uint256 _creatureId, uint256 _landId) external {
        require(FARMING_ENABLED == true, "Chief Farmer not enable yet");
        require(ICreatures(farm.creatures).ownerOf(_creatureId) == msg.sender, 
            "Need to be Creature Owner"
        );
        require(ILand(farm.land).ownerOf(_landId) == msg.sender,
            "Need to be Land Owner"
        );
        (uint8 crType, uint8 crRarity) = ICreatures(farm.creatures).getTypeAndRarity(_creatureId);
        require((DegenFarmBase.Rarity)(crRarity) == Rarity.Normie ||
            (DegenFarmBase.Rarity)(crRarity) == Rarity.Chad,
            "Can farm only Normie and Chad");
        if (crRarity == 0) {
            require(creaturesBorn[crType].leftChadToDiscover > 0, "No more chads left");
        } else {
            require(creaturesBorn[crType].leftDegenToDiscover > 0, "No more Degen left");
        }

        farming.push(
            FarmRecord({
                creatureId:    _creatureId,
                landId:        _landId,
                harvestTime:   block.timestamp + getFarmingDuration(),
                amuletsPrice1: _getExistingAmuletsPrices(amulets[crType]),
                amuletsPrice2: 0,
                harvest:       Result.Fail,
                harvestId:     0, 
                commonAmuletInitialHold: _getCommonAmuletsHoldState(msg.sender) //save initial hold state
            })
        );

        eggs.mint(
            msg.sender,         // farmer
            farming.length - 1  // tokenId
        );
        ILand(farm.land).transferFrom(msg.sender, address(this), _landId);
        ICreatures(farm.creatures).transferFrom(msg.sender, address(this), _creatureId);
    }

    function harvest(uint256 _deployId) external {

        require(eggs.ownerOf(_deployId) == msg.sender, "This is NOT YOUR EGG");
        
        FarmRecord storage f = farming[_deployId];
        require(f.harvestTime <= block.timestamp, "To early for harvest");
        Result farmingResult;
        Bonus memory bonus;
        (uint8 crType, uint8 crRarity) = ICreatures(farm.creatures).getTypeAndRarity(
            f.creatureId
        );
        uint256 baseChance;
        if (crRarity == 0) {
            if (creaturesBorn[crType].leftChadToDiscover == 0) {
                _endFarming(_deployId, Result.Fail);
                return;
            }
            baseChance = 100 * creaturesBorn[crType].totalChad / creaturesBorn[crType].totalNormie; // by default 20%
            creaturesBorn[crType].chadFarmAttempts += 1;
        } else {
            if (creaturesBorn[crType].leftDegenToDiscover == 0) {
                _endFarming(_deployId, Result.Fail);
                return;
            }
            baseChance = 100 * creaturesBorn[crType].totalDegen / creaturesBorn[crType].totalChad; // by default 5%
            creaturesBorn[crType].degenFarmAttempts += 1;
        }
  
        for (uint8 i = 0; i < COMMON_AMULETS.length; i ++){
            if (f.commonAmuletInitialHold[i] &&  _getCommonAmuletsHoldState(msg.sender)[i]) {
                bonus.commonAmuletHold = BONUS_POINTS_AMULET_HOLD;
            }
        }
        uint256 prices2 = 0;
        prices2 = _getExistingAmuletsPrices(amulets[crType]);
        if (f.amuletsPrice1 > 0 && prices2 > 0 && prices2 > f.amuletsPrice1){
            bonus.creatureAmuletBullTrend =
                (prices2 - f.amuletsPrice1) * 100 / f.amuletsPrice1;
        }
        _checkAndSaveMaxAmuletPrice(amulets[crType]);
        if (maxAmuletBalances[amulets[crType]] > 0) {
            bonus.creatureAmuletBalance =
                IERC20(amulets[crType]).balanceOf(msg.sender) * 100 //100 used for scale
                / maxAmuletBalances[amulets[crType]] * BONUS_POINTS_AMULET_HOLD /100;
        }
        f.amuletsPrice2 = prices2;    

        bonus.inventoryHold = 0;
        if (userStakedTools[msg.sender].length > 0) { 
           for (uint8 i=0; i < userStakedTools[msg.sender].length; i++) {
               if (userStakedTools[msg.sender][i] > 0) {
                   bonus.inventoryHold = bonus.inventoryHold + IInventory(farm.inventory).getToolBoost(i);
               }
           }
        }  

        uint256 allBonus = bonus.commonAmuletHold 
            + bonus.creatureAmuletBullTrend 
            + bonus.creatureAmuletBalance
            + bonus.inventoryHold;

        if (allBonus > 100) {
            allBonus = 100; // limit bonus to 100%
        }

        uint32[] memory choiceWeight = new uint32[](2);
        choiceWeight[0] = uint32(baseChance * (100 + allBonus)); // chance of born new chad/degen
        choiceWeight[1] = uint32(10000 - choiceWeight[0]); // receive DUNG

        if (_getWeightedChoice(choiceWeight) == 0) {
            f.harvestId = (crRarity + 1) * NFT_ID_MULTIPLIER + _deployId;

            uint32 index;
            if (crRarity + 1 == uint8(Rarity.Chad)) {
                index = creaturesBorn[crType].totalChad - creaturesBorn[crType].leftChadToDiscover + 1;
                creaturesBorn[crType].leftChadToDiscover -= 1;
                farmingResult = Result.Chad;
            } else if (crRarity + 1 == uint8(Rarity.Degen)) {
                index = creaturesBorn[crType].totalDegen - creaturesBorn[crType].leftDegenToDiscover + 1;
                creaturesBorn[crType].leftDegenToDiscover -= 1;
                farmingResult = Result.Degen;
            }

            uint newCreatureId = (crRarity + 1) * NFT_ID_MULTIPLIER + _deployId;
            ICreatures(farm.creatures).mint(
                msg.sender,
                newCreatureId, // new iD
                crType, // AnimalType
                crRarity + 1,
                index // index
            );
            parents[newCreatureId] = f.creatureId;
        } else {
            IDung(farm.dungtoken).mint(msg.sender, FARM_DUNG_AMOUNT);
            farmingResult = Result.Dung;
        }
        
        ILand(farm.land).burn(f.landId);
        _endFarming(_deployId, farmingResult);
        emit Harvest(
            _deployId, 
            msg.sender, 
            uint8(farmingResult),
            baseChance,
            bonus.commonAmuletHold,
            bonus.creatureAmuletBullTrend,
            bonus.inventoryHold,
            bonus.creatureAmuletBalance,
            choiceWeight[0]
        );
    }

    function stakeOneTool(uint8 _itemId) external {
        _stakeOneTool(_itemId);
         emit Stake(msg.sender, _itemId);
    }

    function unstakeOneTool(uint8 _itemId) external {
        _unstakeOneTool(_itemId);
        emit UnStake(msg.sender, _itemId);
    }

    function setOneCommonAmulet(uint8 _index, address _token) external onlyOwner {
        COMMON_AMULETS[_index] = _token;
    }

    function setAmuletForOneCreature(uint8 _index, address _token) external onlyOwner {
        amulets[_index] = _token;
    }

    function setAmulets(address[] calldata _tokens) external onlyOwner {
        for (uint i = 0; i < _tokens.length; i++) {
            amulets[i] = _tokens[i];
        }
    }

    function setPriceProvider(address _priceProvider) external onlyOwner {
        priceProvider = _priceProvider;
    }

    function enableReveal(bool _isEnabled) external onlyOwner {
        REVEAL_ENABLED = _isEnabled;
    }

    function enableFarming(bool _isEnabled) external onlyOwner {
        FARMING_ENABLED = _isEnabled;
    }

    function addOperator(address _contract, address newOperator) external onlyOwner {
        IOperatorManage(_contract).addOperator(newOperator);
    }

    function removeOperator(address _contract, address oldOperator) external onlyOwner {
        IOperatorManage(_contract).removeOperator(oldOperator);
    }
 
    function reclaimToken(address _contract, IERC20 anyTokens, address _admin) external onlyOwner {
        IOperatorManage(_contract).withdrawERC20(anyTokens, _admin);
    }

    function setSigner(address _contract, address _newSigner) external onlyOwner {
        IOperatorManage(_contract).setSigner(_newSigner);
    }


    function getCreatureAmulets(uint8 _creatureType) external view returns (address) {
        return _getCreatureAmulets(_creatureType);
    }

    function _getCreatureAmulets(uint8 _creatureType) internal view returns (address) {
        return amulets[_creatureType];
    } 

    function getCreatureStat(uint8 _creatureType) 
        external 
        view 
        returns (
            uint16, 
            uint16, 
            uint16, 
            uint16, 
            uint16, 
            uint16,
            uint16,
            uint16 
        )
    {
        CreaturesCount storage stat = creaturesBorn[_creatureType];
        return (
            stat.totalNormie, 
            stat.leftNormie, 
            stat.totalChad, 
            stat.leftChadToDiscover, 
            stat.totalDegen, 
            stat.leftDegenToDiscover,
            stat.chadFarmAttempts,
            stat.degenFarmAttempts
        );
    }

    function getWeightedChoice(uint32[] memory _weights) external view returns (uint8){
        return _getWeightedChoice(_weights);
    }

    function _getWeightedChoice(uint32[] memory _weights) internal view returns (uint8){
        uint randomSeed = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        return _getWeightedChoice2(_weights, randomSeed);
    }

    function getFarmingById(uint256 _farmingId) external view returns (FarmRecord memory) {
        return farming[_farmingId];
    }

    function getOneAmuletPrice(address _token) external view returns (uint256) {
        return _getOneAmuletPrice(_token);
    }

    
    function _endFarming(uint256 _deployId, Result  _res) internal {
        FarmRecord storage f = farming[_deployId];
        f.harvest = _res;
        ICreatures(farm.creatures).transferFrom(address(this), msg.sender, f.creatureId);
        eggs.burn(_deployId); // Burn EGG

        if (_res ==  Result.Fail) {
            if (ILand(farm.land).ownerOf(f.landId) == address(this)){
               ILand(farm.land).transferFrom(address(this), msg.sender, f.landId);
            }
            emit Harvest(
                _deployId, 
                msg.sender, 
                uint8(_res),
                0, //baseChance
                0, //bonus.commonAmuletHold
                0, //bonus.creatureAmuletBullTrend,
                0, //bonus.inventoryHold 
                0,  // bonus.creatureAmuletBalance
                0
            );   
        }
    }

    function _stakeOneTool(uint8 _itemId) internal {
        require(IInventory(farm.inventory).balanceOf(msg.sender, _itemId) >= 1,
            "You must own this tool for stake!"
        );
        require(userStakedTools[msg.sender][_itemId] == 0, "Tool is already staked");

        IInventory(farm.inventory).safeTransferFrom(
            msg.sender, 
            address(this), 
            _itemId, 
            1, 
            bytes('0')
        );
        userStakedTools[msg.sender][_itemId] = block.timestamp;
    }

    function _unstakeOneTool(uint8 _itemId) internal {
        require(userStakedTools[msg.sender][_itemId] > 0, "This tool is not staked yet");
        require(block.timestamp - userStakedTools[msg.sender][_itemId] >= getToolUnstakeDelay(),
            "Cant unstake earlier than a week"
        );
        userStakedTools[msg.sender][_itemId] = 0;
        IInventory(farm.inventory).safeTransferFrom(
            address(this), 
            msg.sender, 
            _itemId, 
            1, 
            bytes('0')
        );

    }

    function _checkAndSaveMaxAmuletPrice(address _amulet) internal {
        if (IERC20(_amulet).balanceOf(msg.sender)
                > maxAmuletBalances[_amulet]
            ) 
            {
              maxAmuletBalances[_amulet] 
              = IERC20(_amulet).balanceOf(msg.sender);
            }
    }

    function _getCommonAmuletsHoldState(address _farmer) internal view returns (bool[COMMON_AMULET_COUNT] memory) {
        
        bool[COMMON_AMULET_COUNT] memory res;
        for (uint8 i = 0; i < COMMON_AMULETS.length; i++){
            if (IERC20(COMMON_AMULETS[i]).balanceOf(_farmer) > 0){
                res[i] = true;    
            } else {
                res[i] = false;
            }
        }
        return res;
    }

    function _getExistingAmuletsPrices(address _token) 
        internal 
        view 
        returns (uint256) 
    {
        if (IERC20(_token).balanceOf(msg.sender) > 0){
            return _getOneAmuletPrice(_token);    
        } else {
            return 0;
        }    
    }

    function _getOneAmuletPrice(address _token) internal view returns (uint256) {
        return IAmuletPriceProvider(priceProvider).getLastPrice(_token);
    }

    function _isRevelEnabled() internal view returns (bool) {
        return REVEAL_ENABLED;
    }

    function _reveal(uint randomSeed) internal {
        require ((landCount.left + allNormiesesLeft) > 0, "Sorry, no more reveal!");
        uint32[] memory choiceWeight = new uint32[](2);
        choiceWeight[0] = uint32(allNormiesesLeft) * CREATURE_P_MULT;
        choiceWeight[1] = uint32(landCount.left) * 100;
        uint8 choice = uint8(_getWeightedChoice2(choiceWeight, randomSeed));
        randomSeed /= 0x10000; // shift right 16 bits
        if (choice != 0 && landCount.left == 0) {
            choice = 0;
        }

        if (choice == 0) { // create creature
            uint32[] memory choiceWeight0 = new uint32[](getCreatureTypeCount());
            for (uint8 i = 0; i < getCreatureTypeCount(); i ++) {
                choiceWeight0[i] = uint32(creaturesBorn[i].leftNormie);
            }
            choice = uint8(_getWeightedChoice2(choiceWeight0, randomSeed));
            ICreatures(farm.creatures).mint(
                msg.sender, 
                MAX_ALL_NORMIES - allNormiesesLeft,
                choice, //AnimalType
                0,
                creaturesBorn[choice].totalNormie - creaturesBorn[choice].leftNormie + 1 // index
            );
            emit Reveal(msg.sender, MAX_ALL_NORMIES - allNormiesesLeft, true, choice);
            allNormiesesLeft -= 1;
            creaturesBorn[choice].leftNormie -= 1;
        } else { // create land
            ILand(farm.land).mint(
                msg.sender, 
                getMaxLands() - landCount.left,
                randomSeed
            );
            emit Reveal(msg.sender, getMaxLands() - landCount.left , false, 0);
            landCount.left -= 1; 
        }
    }

    function _getWeightedChoice2(uint32[] memory _weights, uint randomSeed) internal view returns (uint8){
        uint256 sum_of_weights = 0;
        for (uint8 index = 0; index < _weights.length; index++) {
            sum_of_weights += _weights[index];
        }
        uint256 rnd = randomSeed % sum_of_weights;
        for (uint8 kindex = 0; kindex < _weights.length; kindex++) {
            if (rnd < _weights[kindex]) {
                return kindex;
            }
            rnd -= _weights[kindex];
        }
        return 0;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));  
    }    

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256,uint256,bytes)"));  
    }

    function getCreatureTypeCount() virtual internal view returns (uint16);

    function getFarmingDuration() virtual internal view returns (uint);

    function getToolUnstakeDelay() virtual internal view returns (uint);

    function getNormieCountInType() virtual internal view returns (uint16);

    function getChadCountInType() virtual internal view returns (uint16);

    function getMaxLands() virtual internal view returns (uint16);

    function getUsersTokens(address _owner) external view returns (uint256[] memory) {
        return eggs.getUsersTokens(_owner);
    }

    function getFarmingAllowedCreatures(address _owner) external view returns (uint256[] memory) {
        uint256 n = ICreatures(farm.creatures).balanceOf(_owner);

        uint256[] memory result = new uint256[](n);
        uint256 count = 0;

        for (uint16 i = 0; i < n; i++) {
            uint creatureId = ICreatures(farm.creatures).tokenOfOwnerByIndex(_owner, i);
            if (isFarmingAllowedForCreature(creatureId)) {
                result[count] = creatureId;
                count++;
            }
        }
        uint256[] memory result2 = new uint256[](count);
        for (uint16 i = 0; i < count; i++) {
            result2[i] = result[i];
        }
        return result2;
    }

    function getFarmingAllowedCreaturesWithRarity(address _owner, uint8 wantRarity) external view returns (uint256[] memory) {
        uint256 n = ICreatures(farm.creatures).balanceOf(_owner);

        uint256[] memory result = new uint256[](n);
        uint256 count = 0;

        for (uint16 i = 0; i < n; i++) {
            uint creatureId = ICreatures(farm.creatures).tokenOfOwnerByIndex(_owner, i);
            (uint8 _, uint8 rarity) = ICreatures(farm.creatures).getTypeAndRarity(creatureId);
            if (rarity == wantRarity && isFarmingAllowedForCreature(creatureId)) {
                result[count] = creatureId;
                count++;
            }
        }
        uint256[] memory result2 = new uint256[](count);
        for (uint16 i = 0; i < count; i++) {
            result2[i] = result[i];
        }
        return result2;
    }

    function isFarmingAllowedForCreature(uint creatureId) public view returns (bool) {
        (uint8 _type, uint8 rarity) = ICreatures(farm.creatures).getTypeAndRarity(creatureId);

        if ((DegenFarmBase.Rarity)(rarity) == Rarity.Normie) {
            return creaturesBorn[_type].leftChadToDiscover > 0;
        }
        if ((DegenFarmBase.Rarity)(rarity) == Rarity.Chad) {
            return creaturesBorn[_type].leftDegenToDiscover > 0;
        }
        return false;
    }
}
pragma solidity ^0.7.4;


contract DegenFarm is DegenFarmBase {


    uint8   constant public CREATURE_TYPE_COUNT= 20;  // how much creatures types may be used
    uint256 constant public FARMING_DURATION   = 168 hours;
    uint256 constant public TOOL_UNSTAKE_DELAY = 1 weeks;
    uint16  constant public NORMIE_COUNT_IN_TYPE = 100;
    uint16  constant public CHAD_COUNT_IN_TYPE = 20;
    uint16  constant public MAX_LANDS = 2500;

    constructor (
        address _land,
        address _creatures,
        address _inventory,
        address _bagstoken,
        address _dungtoken,
        IEggs _eggs
    )
        DegenFarmBase(_land, _creatures, _inventory, _bagstoken, _dungtoken, _eggs)
    {
        require(CREATURE_TYPE_COUNT <= CREATURE_TYPE_COUNT_MAX, "CREATURE_TYPE_COUNT is greater than CREATURE_TYPE_COUNT_MAX");

        amulets[0]  = 0xD533a949740bb3306d119CC777fa900bA034cd52; // Cow    $CRV
        amulets[1]  = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; // Horse  $UNI
        amulets[2]  = 0xfA5047c9c78B8877af97BDcb85Db743fD7313d4a; // Rabbit $ROOK
        amulets[3]  = 0xDADA00A9C23390112D08a1377cc59f7d03D9df55; // Chicken $DUNG
        amulets[4]  = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2; // Pig    $SUSHI
        amulets[5]  = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF; // Cat    $BAT
        amulets[6]  = 0x3472A5A71965499acd81997a54BBA8D852C6E53d; // Dog	$BADGER
        amulets[7]  = 0x0d438F3b5175Bebc262bF23753C1E53d03432bDE; // Goose	$WNXM
        amulets[8]  = 0x3155BA85D5F96b2d030a4966AF206230e46849cb; // Goat	$RUNE
        amulets[9]  = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9; // Sheep	$AAVE
        amulets[10] = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F; // Snake	$SNX
        amulets[11] = 0x967da4048cD07aB37855c090aAF366e4ce1b9F48; // Fish	$OCEAN
        amulets[12] = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942; // Frog	$MANA
        amulets[13] = 0x514910771AF9Ca656af840dff83E8264EcF986CA; // Worm	$LINK
        amulets[14] = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32; // Lama	$LDO
        amulets[15] = 0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C; // Mouse	$BNT
        amulets[16] = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2; // Camel	$MKR
        amulets[17] = 0x111111111117dC0aa78b770fA6A738034120C302; // Donkey	$1INCH
        amulets[18] = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e; // Bee	$YFI
        amulets[19] = 0xc00e94Cb662C3520282E6f5717214004A7f26888; // Duck	$COMP
    }

    function getCreatureTypeCount() override internal view returns (uint16) {

        return CREATURE_TYPE_COUNT;
    }

    function getFarmingDuration() override internal view returns (uint) {

        return FARMING_DURATION;
    }

    function getNormieCountInType() override internal view returns (uint16) {

        return NORMIE_COUNT_IN_TYPE;
    }

    function getChadCountInType() override internal view returns (uint16) {

        return CHAD_COUNT_IN_TYPE;
    }

    function getMaxLands() override internal view returns (uint16) {

        return MAX_LANDS;
    }

    function getToolUnstakeDelay() override internal view returns (uint) {

        return TOOL_UNSTAKE_DELAY;
    }

}

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}

pragma solidity >=0.6.0 <0.8.0;

library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

pragma solidity >=0.6.0 <0.8.0;

library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

pragma solidity >=0.6.0 <0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}
pragma solidity ^0.7.4;


contract Operators is Ownable
{
    mapping (address=>bool) operatorAddress;

    modifier onlyOperator() {
        require(isOperator(msg.sender), "Access denied");
        _;
    }

    function isOwner(address _addr) public view returns (bool) {
        return owner() == _addr;
    }

    function isOperator(address _addr) public view returns (bool) {
        return operatorAddress[_addr] || isOwner(_addr);
    }

    function addOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0), "New operator is empty");

        operatorAddress[_newOperator] = true;
    }

    function removeOperator(address _oldOperator) external onlyOwner {
        delete(operatorAddress[_oldOperator]);
    }

    function withdrawERC20(IERC20 _tokenContract, address _admin) external onlyOwner
    {
        uint256 balance = _tokenContract.balanceOf(address(this));
        _tokenContract.transfer(_admin, balance);
    }
}
pragma solidity ^0.7.4;


abstract contract ERC721URIStorage is ERC721, Operators {
    using Strings for uint256;

    mapping (uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual override {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function setURI(uint256 tokenId, string calldata _tokenURI) external onlyOperator {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setURIBatch(uint256[] calldata tokenId, string[] calldata _tokenURI) external onlyOperator {
        require(tokenId.length == _tokenURI.length, "tokenId length is not equal to _tokenURI length");
        for (uint i = 0; i < tokenId.length; i++) {
            _setTokenURI(tokenId[i], _tokenURI[i]);
        }
    }

    address public signerAddress;

    function setSigner(address _newSigner) external onlyOwner {
        signerAddress = _newSigner;
    }

    function hashArguments(uint256 tokenId, string calldata _tokenURI)
        public pure returns (bytes32 msgHash)
    {
        msgHash = keccak256(abi.encode(tokenId, _tokenURI));
    }

    function getSigner(uint256 tokenId, string calldata _tokenURI, uint8 _v, bytes32 _r, bytes32 _s)
        public
        pure
        returns (address)
    {
        bytes32 msgHash = hashArguments(tokenId, _tokenURI);
        return ecrecover(msgHash, _v, _r, _s);
    }

    function isValidSignature(uint256 tokenId, string calldata _tokenURI, uint8 _v, bytes32 _r, bytes32 _s)
        public
        view
        returns (bool)
    {
        return getSigner(tokenId, _tokenURI, _v, _r, _s) == signerAddress;
    }

    function setURISigned(uint256 tokenId, string calldata _tokenURI, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(isValidSignature(tokenId, _tokenURI, _v, _r, _s), "Invalid signature");
        _setTokenURI(tokenId, _tokenURI);
    }

}
