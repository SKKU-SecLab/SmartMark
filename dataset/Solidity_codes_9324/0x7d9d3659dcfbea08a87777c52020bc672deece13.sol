pragma solidity 0.8.7;


contract ERC20 {


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    string public constant name     = "ZUG";
    string public constant symbol   = "ZUG";
    uint8  public constant decimals = 18;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public isMinter;

    address public ruler;


    constructor() { ruler = msg.sender;}

    function approve(address spender, uint256 value) external returns (bool) {

        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {

        balanceOf[msg.sender] -= value;

        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {

        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }

        balanceOf[from] -= value;

        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(from, to, value);

        return true;
    }


    function mint(address to, uint256 value) external {

        require(isMinter[msg.sender], "FORBIDDEN TO MINT");
        _mint(to, value);
    }

    function burn(address from, uint256 value) external {

        require(isMinter[msg.sender], "FORBIDDEN TO BURN");
        _burn(from, value);
    }


    function setMinter(address minter, bool status) external {

        require(msg.sender == ruler, "NOT ALLOWED TO RULE");

        isMinter[minter] = status;
    }

    function setRuler(address ruler_) external {

        require(msg.sender == ruler ||ruler == address(0), "NOT ALLOWED TO RULE");

        ruler = ruler_;
    }



    function _mint(address to, uint256 value) internal {

        totalSupply += value;

        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {

        balanceOf[from] -= value;

        unchecked {
            totalSupply -= value;
        }

        emit Transfer(from, address(0), value);
    }
}
pragma solidity 0.8.7;


contract ERC721 {

    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    
    string public name;
    
    string public symbol;
    
    
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    
    mapping(uint256 => address) public ownerOf;
        
    mapping(uint256 => address) public getApproved;
 
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    constructor(
        string memory _name,
        string memory _symbol
    ) {
        name = _name;
        symbol = _symbol;
    }
    
    
    function transfer(address to, uint256 tokenId) external {

        require(msg.sender == ownerOf[tokenId], "NOT_OWNER");
        
        _transfer(msg.sender, to, tokenId);
        
    }
    
    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool supported) {

        supported = interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }
    
    function approve(address spender, uint256 tokenId) external {

        address owner = ownerOf[tokenId];
        
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_APPROVED");
        
        getApproved[tokenId] = spender;
        
        emit Approval(owner, spender, tokenId); 
    }
    
    function setApprovalForAll(address operator, bool approved) external {

        isApprovedForAll[msg.sender][operator] = approved;
        
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address, address to, uint256 tokenId) public {

        address owner = ownerOf[tokenId];
        
        require(
            msg.sender == owner 
            || msg.sender == getApproved[tokenId]
            || isApprovedForAll[owner][msg.sender], 
            "NOT_APPROVED"
        );
        
        _transfer(owner, to, tokenId);
        
    }
    
    function safeTransferFrom(address, address to, uint256 tokenId) external {

        safeTransferFrom(address(0), to, tokenId, "");
    }
    
    function safeTransferFrom(address, address to, uint256 tokenId, bytes memory data) public {

        transferFrom(address(0), to, tokenId); 
        
        if (to.code.length != 0) {
            (, bytes memory returned) = to.staticcall(abi.encodeWithSelector(0x150b7a02,
                msg.sender, address(0), tokenId, data));
                
            bytes4 selector = abi.decode(returned, (bytes4));
            
            require(selector == 0x150b7a02, "NOT_ERC721_RECEIVER");
        }
    }
    
    

    function _transfer(address from, address to, uint256 tokenId) internal {

        balanceOf[from]--; 
        balanceOf[to]++;
        
        delete getApproved[tokenId];
        
        ownerOf[tokenId] = to;
        emit Transfer(msg.sender, to, tokenId); 

    }

    function _mint(address to, uint256 tokenId) internal { 

        require(ownerOf[tokenId] == address(0), "ALREADY_MINTED");

        uint maxSupply = 5050;
        require(totalSupply++ <= maxSupply, "MAX SUPPLY REACHED");
                
        unchecked {
            balanceOf[to]++;
        }
        
        ownerOf[tokenId] = to;
                
        emit Transfer(address(0), to, tokenId); 
    }
    
    function _burn(uint256 tokenId) internal { 

        address owner = ownerOf[tokenId];
        
        require(ownerOf[tokenId] != address(0), "NOT_MINTED");
        
        totalSupply--;
        balanceOf[owner]--;
        
        delete ownerOf[tokenId];
                
        emit Transfer(owner, address(0), tokenId); 
    }
}
pragma solidity 0.8.7;



interface MetadataHandlerLike {

    function getTokenURI(uint16 id, uint8 body, uint8 helm, uint8 mainhand, uint8 offhand, uint16 level, uint16 zugModifier) external view returns (string memory);

}

interface ListLike {

    function register(address buyer) external;

}

contract EtherOrcs is ERC721 {



    uint256 public constant  cooldown = 10 minutes;
    uint256 public immutable startingTime;
    uint256 public immutable mintingTime;
    address public           owner; //Lame requirement from opensea

    bytes32 internal entropySauce;

    ERC20 public zug;

    mapping (uint256 => Orc)      public orcs;
    mapping (uint256 => Action)   public activities;
    mapping (Places  => LootPool) public lootPools;

    MetadataHandlerLike metadaHandler;
    ListLike            list;

    function setAddresses(address meta, address list_) external {

        require(msg.sender == owner, "not allowed");
        list          = ListLike(list_);
        metadaHandler = MetadataHandlerLike(meta);
    }

    function transferOwnership(address newOwner) external {

        require(msg.sender == owner, "not allowed");
        owner = newOwner;
    }

    function tokenURI(uint256 id) external view returns(string memory) {

        Orc memory orc = orcs[id];
        return metadaHandler.getTokenURI(uint16(id), orc.body, orc.helm, orc.mainhand, orc.offhand, orc.level, orc.zugModifier);
    }

    event ActionMade(address owner, uint256 id, uint256 timestamp, uint8 activity);



    struct LootPool { 
        uint8  minLevel; uint8  minLootTier; uint16  cost;   uint16 total;
        uint16 tier_1;   uint16 tier_2;      uint16 tier_3; uint16 tier_4;
    }

    struct Orc { uint8 body; uint8 helm; uint8 mainhand; uint8 offhand; uint16 level; uint16 zugModifier; uint32 lvlProgress; }

    enum   Actions { UNSTAKED, FARMING, TRAINING }
    struct Action  { address owner; uint88 timestamp; Actions action; }

    enum Places { 
        TOWN, DUNGEON, CRYPT, CASTLE, DRAGONS_LAIR, THE_ETHER, 
        TAINTED_KINGDOM, OOZING_DEN, ANCIENT_CHAMBER, ORC_GODS 
    }   

    constructor( ) ERC721("Ether Orcs", "ORC") {

        LootPool memory town           = LootPool({ minLevel: 1,  minLootTier:  1, cost:   0, total: 1000, tier_1: 800,  tier_2: 150,  tier_3: 50,  tier_4:   0 });
        LootPool memory dungeon        = LootPool({ minLevel: 3,  minLootTier:  2, cost:   0, total: 1000, tier_1: 800,  tier_2: 150,  tier_3: 50,  tier_4:   0 });
        LootPool memory crypt          = LootPool({ minLevel: 6,  minLootTier:  3, cost:   0, total: 9000, tier_1: 4950, tier_2: 3600, tier_3: 450, tier_4:   0 }); 
        LootPool memory castle         = LootPool({ minLevel: 15, minLootTier:  4, cost:   0, total: 6000, tier_1: 3300, tier_2: 2400, tier_3: 300, tier_4:   0 });
        LootPool memory dragonsLair    = LootPool({ minLevel: 25, minLootTier:  5, cost:   0, total: 6000, tier_1: 3300, tier_2: 2400, tier_3: 300, tier_4:   0 });
        LootPool memory theEther       = LootPool({ minLevel: 36, minLootTier:  6, cost:   0, total: 3000, tier_1: 1200, tier_2: 1500, tier_3: 300, tier_4:   0 });
        LootPool memory taintedKingdom = LootPool({ minLevel: 15, minLootTier:  4, cost:  50, total:  600, tier_1:  150, tier_2:  150, tier_3: 150, tier_4: 150 });
        LootPool memory oozingDen      = LootPool({ minLevel: 25, minLootTier:  5, cost:  50, total:  600, tier_1:  150, tier_2:  150, tier_3: 150, tier_4: 150 });
        LootPool memory ancientChamber = LootPool({ minLevel: 45, minLootTier:  9, cost: 125, total:  225, tier_1:  225, tier_2:    0, tier_3:   0, tier_4:   0 });
        LootPool memory orcGods        = LootPool({ minLevel: 52, minLootTier: 10, cost: 300, total:   12, tier_1:    0, tier_2:    0, tier_3:   0, tier_4:   0 });

        lootPools[Places.TOWN]            = town;
        lootPools[Places.DUNGEON]         = dungeon;
        lootPools[Places.CRYPT]           = crypt;
        lootPools[Places.CASTLE]          = castle;
        lootPools[Places.DRAGONS_LAIR]    = dragonsLair;
        lootPools[Places.THE_ETHER]       = theEther;
        lootPools[Places.TAINTED_KINGDOM] = taintedKingdom;
        lootPools[Places.OOZING_DEN]      = oozingDen;
        lootPools[Places.ANCIENT_CHAMBER] = ancientChamber;
        lootPools[Places.ORC_GODS]        = orcGods;

        mintingTime  = 1633951800;
        startingTime = 1633951800 + 4.5 hours;

        zug = new ERC20();
        zug.setMinter(address(this), true);
        zug.setRuler(address(msg.sender));

        owner = msg.sender;
    }


    modifier noCheaters() {

        uint256 size = 0;
        address acc = msg.sender;
        assembly { size := extcodesize(acc)}

        require(msg.sender == tx.origin , "you're trying to cheat!");
        require(size == 0,                "you're trying to cheat!");
        _;

        entropySauce = keccak256(abi.encodePacked(acc, block.coinbase));
    }

    modifier ownerOfOrc(uint256 id) { 

        require(ownerOf[id] == msg.sender || activities[id].owner == msg.sender, "not your orc");
        _;
    }



    function mint() public noCheaters returns (uint256 id) {

        require(block.timestamp >= mintingTime, "not open");

        uint256 cost = _getMintingPrice();
        uint256 rand = _rand();

        if (block.timestamp < startingTime) list.register(msg.sender);
        if (cost > 0) zug.burn(msg.sender, cost);

        return _mintOrc(rand);
    }

    function doAction(uint256 id, Actions action_) public ownerOfOrc(id) noCheaters {

        Action memory action = activities[id];
        require(action.action != action_, "already doing that");

        uint88 timestamp = uint88(startingTime > (block.timestamp > action.timestamp ? block.timestamp : action.timestamp) ?
                                  startingTime : (block.timestamp > action.timestamp ? block.timestamp : action.timestamp));

        if (action.action == Actions.UNSTAKED)  _transfer(msg.sender, address(this), id);
     
        else {
            if (block.timestamp > action.timestamp) _claim(id);
            timestamp = timestamp > action.timestamp ? timestamp : action.timestamp;
        }

        if (action_ == Actions.UNSTAKED) _transfer(address(this), activities[id].owner, id);

        activities[id] = Action({owner: msg.sender, action: action_,timestamp: timestamp});
        emit ActionMade(msg.sender, id, block.timestamp, uint8(action_));
    }

    function doActionWithManyOrcs(uint256[] calldata ids, Actions action_) external {

        for (uint256 index = 0; index < ids.length; index++) {
            doAction(ids[index], action_);
        }
    }

    function claim(uint256[] calldata ids) external {

        for (uint256 index = 0; index < ids.length; index++) {
            _claim(ids[index]);
        }
    }

    function _claim(uint256 id) internal noCheaters {

        Orc    memory orc    = orcs[id];
        Action memory action = activities[id];

        if(block.timestamp <= action.timestamp) return;

        uint256 timeDiff = uint256(block.timestamp - action.timestamp);

        if (action.action == Actions.FARMING) zug.mint(action.owner, claimableZug(timeDiff, orc.zugModifier));
       
        if (action.action == Actions.TRAINING) {
            orcs[id].lvlProgress += uint16(timeDiff * 3000 / 1 days);
            orcs[id].level        = uint16(orcs[id].lvlProgress / 1000);
        }

        activities[id].timestamp = uint88(block.timestamp);
    }

    function pillage(uint256 id, Places place, bool tryHelm, bool tryMainhand, bool tryOffhand) public ownerOfOrc(id) noCheaters {

        require(block.timestamp >= uint256(activities[id].timestamp), "on cooldown");
        require(place != Places.ORC_GODS,  "You can't pillage the Orc God");

        if(activities[id].timestamp < block.timestamp) _claim(id); // Need to claim to not have equipment reatroactively multiplying

        uint256 rand_ = _rand();
  
        LootPool memory pool = lootPools[place];
        require(orcs[id].level >= uint16(pool.minLevel), "below minimum level");

        if (pool.cost > 0) {
            require(block.timestamp - startingTime > 14 days);
            zug.burn(msg.sender, uint256(pool.cost) * 1 ether);
        } 

        uint8 item;
        if (tryHelm) {
            ( pool, item ) = _getItemFromPool(pool, _randomize(rand_,"HELM", id));
            if (item != 0 ) orcs[id].helm = item;
        }
        if (tryMainhand) {
            ( pool, item ) = _getItemFromPool(pool, _randomize(rand_,"MAINHAND", id));
            if (item != 0 ) orcs[id].mainhand = item;
        }
        if (tryOffhand) {
            ( pool, item ) = _getItemFromPool(pool, _randomize(rand_,"OFFHAND", id));
            if (item != 0 ) orcs[id].offhand = item;
        }

        if (uint(place) > 1) lootPools[place] = pool;

        Orc memory orc = orcs[id];
        uint16 zugModifier_ = _tier(orc.helm) + _tier(orc.mainhand) + _tier(orc.offhand);

        orcs[id].zugModifier = zugModifier_;

        activities[id].timestamp = uint88(block.timestamp + cooldown);
    } 

    function update(uint256 id) public ownerOfOrc(id) noCheaters {

        require(_tier(orcs[id].mainhand) < 10);
        require(block.timestamp - startingTime >= 14 days);
        require(orcs[id].level >= 32);
        
        LootPool memory pool = lootPools[Places.ORC_GODS];

        zug.burn(msg.sender, uint256(pool.cost) * 1 ether);

        _claim(id); // Need to claim to not have equipment reatroactively multiplying

        uint8 item = uint8(lootPools[Places.ORC_GODS].total--);
        orcs[id].zugModifier = 30;
        orcs[id].body = orcs[id].helm = orcs[id].mainhand = orcs[id].offhand = item + 40;
    }


    function claimable(uint256 id) external view returns (uint256 amount) {

        uint256 timeDiff = uint256(block.timestamp - activities[id].timestamp);
        amount = activities[id].action == Actions.FARMING ? claimableZug(timeDiff, orcs[id].zugModifier) : timeDiff * 2000 / 1 days;
    }


    function _mintOrc(uint256 rand) internal returns (uint16 id) {

        (uint8 body,uint8 helm,uint8 mainhand,uint8 offhand) = (0,0,0,0);

        {
            uint256 sevenOnePct   = type(uint16).max / 100 * 75;
            uint256 eightyPct     = type(uint16).max / 100 * 80;
            uint256 nineFivePct   = type(uint16).max / 100 * 95;
            uint256 nineNinePct   = type(uint16).max / 100 * 99;
    
            id = uint16(totalSupply + 1);
    
            uint16 randBody = uint16(_randomize(rand, "BODY", id));
                   body     = uint8(randBody > nineNinePct ? randBody % 3 + 25 : 
                              randBody > sevenOnePct  ? randBody % 12 + 13 : randBody % 13 + 1 );
    
            uint16 randHelm = uint16(_randomize(rand, "HELM", id));
                   helm     = uint8(randHelm < eightyPct ? 0 : randHelm % 4 + 5);
    
            uint16 randOffhand = uint16(_randomize(rand, "OFFHAND", id));
                   offhand     = uint8(randOffhand < eightyPct ? 0 : randOffhand % 4 + 5);
    
            uint16 randMainhand = uint16(_randomize(rand, "MAINHAND", id));
                   mainhand     = uint8(randMainhand < nineFivePct ? randMainhand % 4 + 1: randMainhand % 4 + 5);
        }

        _mint(msg.sender, id);

        uint16 zugModifier = _tier(helm) + _tier(mainhand) + _tier(offhand);
        orcs[uint256(id)] = Orc({body: body, helm: helm, mainhand: mainhand, offhand: offhand, level: 0, lvlProgress: 0, zugModifier:zugModifier});
    }


    function _getItemFromPool(LootPool memory pool, uint256 rand) internal pure returns (LootPool memory, uint8 item) {

        uint draw = rand % pool.total--; 

        if (draw > pool.tier_1 + pool.tier_2 + pool.tier_3 && pool.tier_4 > 0) {
            item = uint8((pool.tier_4-- % 4 + 1) + (pool.minLootTier + 3) * 4);     
            return (pool, item);
        }

        if (draw > pool.tier_1 + pool.tier_2 && pool.tier_3 > 0) {
            item = uint8((pool.tier_3-- % 4 + 1) + (pool.minLootTier + 2) * 4);
            return (pool, item);
        }

        if (draw > pool.tier_1 && pool.tier_2 > 0) {
            item = uint8((pool.tier_2-- % 4 + 1) + (pool.minLootTier + 1) * 4);
            return (pool, item);
        }

        if (pool.tier_1 > 0) {
            item = uint8((pool.tier_1-- % 4 + 1) + pool.minLootTier * 4);
            return (pool, item);
        }
    }

    function claimableZug(uint256 timeDiff, uint16 zugModifier) internal pure returns (uint256 zugAmount) {

        zugAmount = timeDiff * (4 + zugModifier) * 1 ether / 1 days;
    }

    function _tier(uint16 id) internal pure returns (uint16) {

        if (id == 0) return 0;
        return ((id - 1) / 4 );
    }

    function _randomize(uint256 rand, string memory val, uint256 spicy) internal pure returns (uint256) {

        return uint256(keccak256(abi.encode(rand, val, spicy)));
    }

    function _rand() internal view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.basefee, block.timestamp, entropySauce)));
    }

    function _getMintingPrice() internal view returns (uint256) {

        if (totalSupply < 1550) return   0;
        if (totalSupply < 2050) return   4 ether;
        if (totalSupply < 2550) return   8 ether;
        if (totalSupply < 3050) return  12 ether;
        if (totalSupply < 3550) return  24 ether;
        if (totalSupply < 4050) return  40 ether;
        if (totalSupply < 4550) return  60 ether;
        if (totalSupply < 5050) return 130 ether;
    }
}
