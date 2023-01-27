
pragma solidity 0.8.7;


abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
    function decimals() external view virtual returns (uint8);



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

contract ERC721 {

    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    
    address        implementation_;
    address public admin; //Lame requirement from opensea
    

    uint256 public totalSupply;
    uint256 public oldSupply;
    uint256 public minted;
    
    mapping(address => uint256) public balanceOf;
    
    mapping(uint256 => address) public ownerOf;
        
    mapping(uint256 => address) public getApproved;
 
    mapping(address => mapping(address => bool)) public isApprovedForAll;


    function owner() external view returns (address) {

        return admin;
    }
    
    
    function transfer(address to, uint256 tokenId) external {

        require(msg.sender == ownerOf[tokenId], "NOT_OWNER");
        
        _transfer(msg.sender, to, tokenId);
        
    }
    
    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool supported) {

        supported = interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }
    
    function approve(address spender, uint256 tokenId) external {

        address owner_ = ownerOf[tokenId];
        
        require(msg.sender == owner_ || isApprovedForAll[owner_][msg.sender], "NOT_APPROVED");
        
        getApproved[tokenId] = spender;
        
        emit Approval(owner_, spender, tokenId); 
    }
    
    function setApprovalForAll(address operator, bool approved) external {

        isApprovedForAll[msg.sender][operator] = approved;
        
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(
            msg.sender == from 
            || msg.sender == getApproved[tokenId]
            || isApprovedForAll[from][msg.sender], 
            "NOT_APPROVED"
        );
        
        _transfer(from, to, tokenId);
        
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external {

        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {

        transferFrom(from, to, tokenId); 
        
        if (to.code.length != 0) {
            (, bytes memory returned) = to.staticcall(abi.encodeWithSelector(0x150b7a02,
                msg.sender, from, tokenId, data));
                
            bytes4 selector = abi.decode(returned, (bytes4));
            
            require(selector == 0x150b7a02, "NOT_ERC721_RECEIVER");
        }
    }
    

    function _transfer(address from, address to, uint256 tokenId) internal {

        require(ownerOf[tokenId] == from, "not owner");

        balanceOf[from]--; 
        balanceOf[to]++;
        
        delete getApproved[tokenId];
        
        ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId); 

    }

    function _mint(address to, uint256 tokenId) internal { 

        require(ownerOf[tokenId] == address(0), "ALREADY_MINTED");

        totalSupply++;

        unchecked {
            balanceOf[to]++;
        }
        
        ownerOf[tokenId] = to;
                
        emit Transfer(address(0), to, tokenId); 
    }
    
    function _burn(uint256 tokenId) internal { 

        address owner_ = ownerOf[tokenId];
        
        require(ownerOf[tokenId] != address(0), "NOT_MINTED");
        
        totalSupply--;
        balanceOf[owner_]--;
        
        delete ownerOf[tokenId];
                
        emit Transfer(owner_, address(0), tokenId); 
    }
}

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface IDogewood {

    struct Doge {
        uint8 head;
        uint8 breed;
        uint8 color;
        uint8 class;
        uint8 armor;
        uint8 offhand;
        uint8 mainhand;
        uint16 level;
    }

    function getTokenTraits(uint256 tokenId) external view returns (Doge memory);

    function getGenesisSupply() external view returns (uint256);

    function pull(address owner, uint256[] calldata ids) external;

    function manuallyAdjustDoge(uint256 id, uint8 head, uint8 breed, uint8 color, uint8 class, uint8 armor, uint8 offhand, uint8 mainhand, uint16 level) external;

    function transfer(address to, uint256 tokenId) external;

}

interface PortalLike {

    function sendMessage(bytes calldata message_) external;

}

interface CastleLike {

    function pullCallback(address owner, uint256[] calldata ids) external;

}

interface ERC20Like {

    function balanceOf(address from) external view returns(uint256 balance);

    function burn(address from, uint256 amount) external;

    function mint(address from, uint256 amount) external;

    function transfer(address to, uint256 amount) external;

}

interface ERC1155Like {

    function mint(address to, uint256 id, uint256 amount) external;

    function burn(address from, uint256 id, uint256 amount) external;

}

interface ERC721Like {

    function transferFrom(address from, address to, uint256 id) external;   

    function transfer(address to, uint256 id) external;

    function ownerOf(uint256 id) external returns (address owner);

    function mint(address to, uint256 tokenid) external;

}

contract Dogewood is ERC721 {

    uint256 public constant MAX_SUPPLY = 5000;
    uint256 public constant GENESIS_SUPPLY = 2500;
    uint256 public constant mintCooldown = 12 hours;

    uint256 constant tenPct = (type(uint16).max / 100) * 10;
    uint256 constant fifteenPct = (type(uint16).max / 100) * 15;
    uint256 constant fiftyPct = (type(uint16).max / 100) * 50;

    bool public presaleActive;
    bool public saleActive;
    mapping (address => uint8) public whitelist;
    mapping (address => uint8) public ogWhitelist;

    uint256 public mintPriceEth;
    uint256 public mintPriceZug;
    uint16 public constant MAX_ZUG_MINT = 200;
    uint16 public zugMintCount;

    uint8[][7] public rarities;
    uint8[][7] public aliases;
    mapping(uint256 => uint256) public existingCombinations;

    bool public rerollTreatOnly;
    uint256 public rerollPriceEth;
    uint256 public rerollPriceZug;
    uint256[] public rerollPrice;

    uint256[] public upgradeLevelPrice;

    bytes32 internal entropySauce;

    ERC20 public treat;
    ERC20 public zug;

    mapping(address => bool) public auth;
    mapping(uint256 => Doge) internal doges;
    mapping(uint256 => Action) public activities;
    mapping(uint256 => Log) public mintLogs;
    mapping(RerollTypes => mapping(uint256 => uint256)) public rerollCountHistory; // rerollType => tokenId => rerollCount

    ITraits public traits;

    mapping(uint256 => uint256) public rerollBlocks;

    mapping(bytes4 => address) implementer;

    address constant impl = 0x7ef61741D9a2b483E75D8AA0876Ce864d98cE331;

    address public castle;


    function setImplementer(bytes4[] calldata funcs, address source) external onlyOwner {

        for (uint256 index = 0; index < funcs.length; index++) {
            implementer[funcs[index]] = source; 
        }
    }

    function setAddresses(
        address _traits,
        address _treat,
        address _zug,
        address _castle
    ) external onlyOwner {

        traits = ITraits(_traits);
        treat = ERC20(_treat);
        zug = ERC20(_zug);
        castle = _castle;
    }

    function setTreat(address t_) external {

        require(msg.sender == admin);
        treat = ERC20(t_);
    }

    function setZug(address z_) external {

        require(msg.sender == admin);
        zug = ERC20(z_);
    }

    function setCastle(address c_) external {

        require(msg.sender == admin);
        castle = c_;
    }

    function setTraits(address t_) external {

        require(msg.sender == admin);
        traits = ITraits(t_);
    }

    function setAuth(address add, bool isAuth) external onlyOwner {

        auth[add] = isAuth;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        admin = newOwner;
    }

    function setPresaleStatus(bool _status) external onlyOwner {

        presaleActive = _status;
    }

    function setSaleStatus(bool _status) external onlyOwner {

        saleActive = _status;
    }

    function setMintPrice(uint256 _mintPriceEth, uint256 _mintPriceZug)
        external
        onlyOwner
    {

        mintPriceEth = _mintPriceEth;
        mintPriceZug = _mintPriceZug;
    }

    function setRerollTreatOnly(bool _rerollTreatOnly) external onlyOwner {

        rerollTreatOnly = _rerollTreatOnly;
    }

    function setRerollPrice(
        uint256 _rerollPriceEth,
        uint256 _rerollPriceZug,
        uint256[] calldata _rerollPriceTreat
    ) external onlyOwner {

        rerollPriceEth = _rerollPriceEth;
        rerollPriceZug = _rerollPriceZug;
        rerollPrice = _rerollPriceTreat;
    }

    function setUpgradeLevelPrice(uint256[] calldata _upgradeLevelPrice) external onlyOwner {

        upgradeLevelPrice = _upgradeLevelPrice;
    }

    function editWhitelist(address[] calldata wlAddresses) external onlyOwner {

        for(uint256 i; i < wlAddresses.length; i++){
            whitelist[wlAddresses[i]] = 2;
        }
    }

    function editOGWhitelist(address[] calldata wlAddresses) external onlyOwner {

        for(uint256 i; i < wlAddresses.length; i++){
            ogWhitelist[wlAddresses[i]] = 1;
        }
    }


    function tokenURI(uint256 tokenId) public view returns (string memory) {

        require(rerollBlocks[tokenId] != block.number, "ERC721Metadata: URI query for nonexistent token");
        return traits.tokenURI(tokenId);
    }

    event ActionMade(
        address owner,
        uint256 id,
        uint256 timestamp,
        uint8 activity
    );


    struct Doge {
        uint8 head;
        uint8 breed;
        uint8 color;
        uint8 class;
        uint8 armor;
        uint8 offhand;
        uint8 mainhand;
        uint16 level;
    }

    enum Actions {
        UNSTAKED,
        FARMING
    }
    struct Action {
        address owner;
        uint88 timestamp;
        Actions action;
    }
    struct Log {
        address owner;
        uint88 timestamp;
    }
    enum RerollTypes {
        BREED,
        CLASS
    }

    function initialize() public onlyOwner {

        admin = msg.sender;
        auth[msg.sender] = true;

        presaleActive = false;
        saleActive = false;
        mintPriceEth = 0.065 ether;
        mintPriceZug = 300 ether;

        rarities[0] = [173, 155, 255, 206, 206, 206, 114, 114, 114];
        aliases[0] = [2, 2, 8, 0, 0, 0, 0, 1, 1];
        rarities[1] = [255, 255, 255, 255, 255, 255, 255, 255];
        aliases[1] = [7, 7, 7, 7, 7, 7, 7, 7];
        rarities[2] = [255, 188, 255, 229, 153, 76];
        aliases[2] = [2, 2, 5, 0, 0, 1];
        rarities[3] = [229, 127, 178, 255, 204, 204, 204, 102];
        aliases[3] = [2, 2, 3, 7, 0, 0, 1, 1];
        rarities[4] = [255];
        aliases[4] = [0];
        rarities[5] = [255];
        aliases[5] = [0];
        rarities[6] = [255];
        aliases[6] = [0];

        rerollTreatOnly = false;
        rerollPriceEth = 0.01 ether;
        rerollPriceZug = 50 ether;
        rerollPrice = [
            6 ether,
            12 ether,
            24 ether,
            48 ether,
            96 ether
        ];

        upgradeLevelPrice = [
            0 ether,
            12 ether,
            16 ether,
            20 ether,
            24 ether,
            30 ether,
            36 ether,
            42 ether,
            48 ether,
            54 ether,
            62 ether,
            70 ether,
            78 ether,
            86 ether,
            96 ether,
            106 ether,
            116 ether,
            126 ether,
            138 ether,
            150 ether
        ];
    }


    modifier noCheaters() {

        uint256 size = 0;
        address acc = msg.sender;
        assembly {
            size := extcodesize(acc)
        }

        require(
            auth[msg.sender] || (msg.sender == tx.origin && size == 0),
            "you're trying to cheat!"
        );
        _;

        entropySauce = keccak256(abi.encodePacked(acc, block.coinbase, entropySauce));
    }

    modifier mintCoolDownPassed(uint256 id) {

        Log memory log_ = mintLogs[id];
        require(
            block.timestamp >= log_.timestamp + mintCooldown,
            "still in cool down"
        );
        _;
    }

    modifier isOwnerOfDoge(uint256 id) {

        require(
            ownerOf[id] == msg.sender || activities[id].owner == msg.sender,
            "not your doge"
        );
        _;
    }

    modifier ownerOfDoge(uint256 id, address who_) { 

        require(ownerOf[id] == who_ || activities[id].owner == who_, "not your doge");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == admin);
        _;
    }

    modifier genesisMinting(uint8 amount) {

        require(totalSupply + amount <= GENESIS_SUPPLY, "genesis all minted");
        _;
    }


    function mintReserved(address to, uint8 amount) public genesisMinting(amount) onlyOwner {

        for (uint256 i = 0; i < amount; i++) {
            _mintDoge(to);
        }
    }

    function mintOG(address to, uint8 amount) public genesisMinting(amount) noCheaters {

        require(amount <= ogWhitelist[msg.sender], "Exceeds amount");

        ogWhitelist[msg.sender] = ogWhitelist[msg.sender] - amount;

        for (uint256 i = 0; i < amount; i++) {
            _mintDoge(to);
        }
    }

    function presaleMintWithEth(uint8 amount) public payable genesisMinting(amount) noCheaters {

        require(presaleActive, "Presale must be active to mint");
        require(amount <= whitelist[msg.sender], "Exceeds max amount");
        require(msg.value >= mintPriceEth * amount, "Value below price");

        whitelist[msg.sender] = whitelist[msg.sender] - amount;

        for (uint256 i = 0; i < amount; i++) {
            _mintDoge(msg.sender);
        }
    }

    function presaleMintWithZug(uint8 amount) public genesisMinting(amount) noCheaters {

        require(presaleActive, "Presale must be active to mint");
        require(whitelist[msg.sender] > 0, "No tokens reserved for this address");
        require(amount <= whitelist[msg.sender], "Exceeds max amount");
        require(zugMintCount+amount <= MAX_ZUG_MINT, "Exceeds max zug mint");

        whitelist[msg.sender] = whitelist[msg.sender] - amount;

        zug.transferFrom(msg.sender, address(this), mintPriceZug * amount);
        zugMintCount = zugMintCount + amount;
        for (uint256 i = 0; i < amount; i++) {
            _mintDoge(msg.sender);
        }
    }

    function mintWithEth(uint8 amount) public payable genesisMinting(amount) noCheaters {

        require(saleActive, "Sale must be active to mint");
        require(amount <= 2, "Exceeds max amount");
        require(msg.value >= mintPriceEth * amount, "Value below price");

        for (uint256 i = 0; i < amount; i++) {
            _mintDoge(msg.sender);
        }
    }

    function mintWithZug(uint8 amount) public genesisMinting(amount) noCheaters {

        require(saleActive, "Sale must be active to mint");
        require(amount <= 2, "Exceeds max amount");
        require(zugMintCount+amount <= MAX_ZUG_MINT, "Exceeds max zug mint");
        zug.transferFrom(msg.sender, address(this), mintPriceZug * amount);
        zugMintCount = zugMintCount + amount;
        for (uint256 i = 0; i < amount; i++) {
            _mintDoge(msg.sender);
        }
    }

    function recruit(uint256 id) public ownerOfDoge(id, msg.sender) mintCoolDownPassed(id) noCheaters {

        require(totalSupply <= MAX_SUPPLY, "all supply minted");
        uint256 cost = _getMintingPrice();
        if (cost > 0) treat.burn(msg.sender, cost);
        mintLogs[id].timestamp = uint88(block.timestamp);
        _mintDoge(msg.sender);
    }

    function upgradeLevelWithTreat(uint256 id)
        public
        ownerOfDoge(id, msg.sender)
        mintCoolDownPassed(id)
        noCheaters
    {

        _claim(id); // Need to claim to not have equipment reatroactively multiplying

        uint16 curVal = doges[id].level;
        require(curVal < 20, "already max level");
        treat.burn(msg.sender, upgradeLevelPrice[curVal]);
        doges[id].level = curVal + 1;
    }

    function upgradeMultipleLevelWithTreat(uint256 id, uint16 toLevel)
        public
        ownerOfDoge(id, msg.sender)
        mintCoolDownPassed(id)
        noCheaters
    {

        uint16 curVal = doges[id].level;
        require(curVal < toLevel, "invalid level");
        require(toLevel <= 20, "exceeds max level");
        _claim(id); // Need to claim to not have equipment reatroactively multiplying

        treat.burn(msg.sender, getUpgradeLevelPrice(curVal, toLevel));
        doges[id].level = toLevel;
    }

    function getUpgradeLevelPrice(uint16 curLevel, uint16 toLevel) public view returns(uint256) {

        uint256 _price = 0;
        for (uint16 i = curLevel; i < toLevel; i++) {
            _price += upgradeLevelPrice[i];
        }
        return _price;
    }

    function rerollWithEth(uint256 id, RerollTypes rerollType)
        public
        payable
        ownerOfDoge(id, msg.sender)
        mintCoolDownPassed(id)
        noCheaters
    {

        require(!rerollTreatOnly, "Only TREAT for reroll");
        require(msg.value >= rerollPriceEth, "Value below price");

        _reroll(id, rerollType);
    }

    function rerollWithZug(uint256 id, RerollTypes rerollType)
        public
        ownerOfDoge(id, msg.sender)
        mintCoolDownPassed(id)
        noCheaters
    {

        require(!rerollTreatOnly, "Only TREAT for reroll");
        zug.transferFrom(msg.sender, address(this), rerollPriceZug);
        _reroll(id, rerollType);
    }

    function rerollWithTreat(uint256 id, RerollTypes rerollType)
        public
        ownerOfDoge(id, msg.sender)
        mintCoolDownPassed(id)
        noCheaters
    {

        uint256 price_ = rerollPrice[
            rerollCountHistory[rerollType][id] < 5
                ? rerollCountHistory[rerollType][id]
                : 5
        ];
        treat.burn(msg.sender, price_);
        _reroll(id, rerollType);
    }

    function _reroll(
        uint256 id,
        RerollTypes rerollType
    ) internal {

        rerollBlocks[id] = block.number;
        uint256 rand_ = _rand();

        if (rerollType == RerollTypes.BREED) {
            doges[id].breed = uint8(_randomize(rand_, "BREED", id)) % uint8(rarities[1].length);
        } else if (rerollType == RerollTypes.CLASS) {
            uint16 randClass = uint16(_randomize(rand_, "CLASS", id));
            doges[id].class = selectTrait(randClass, 3);
        }
        rerollCountHistory[rerollType][id]++;
    }

    function withdraw() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);
        zug.transfer(msg.sender, zug.balanceOf(address(this)));
    }

    function doAction(uint256 id, Actions action_)
        public
        ownerOfDoge(id, msg.sender)
        noCheaters
    {

        _doAction(id, msg.sender, action_, msg.sender);
    }

    function _doAction(
        uint256 id,
        address dogeOwner,
        Actions action_,
        address who_
    ) internal ownerOfDoge(id, who_) {

        Action memory action = activities[id];
        require(action.action != action_, "already doing that");

        uint88 timestamp = uint88(
            block.timestamp > action.timestamp
                ? block.timestamp
                : action.timestamp
        );

        if (action.action == Actions.UNSTAKED) _transfer(dogeOwner, address(this), id);
        else {
            if (block.timestamp > action.timestamp) _claim(id);
            timestamp = timestamp > action.timestamp ? timestamp : action.timestamp;
        }

        address owner_ = action_ == Actions.UNSTAKED ? address(0) : dogeOwner;
        if (action_ == Actions.UNSTAKED) _transfer(address(this), dogeOwner, id);

        activities[id] = Action({
            owner: owner_,
            timestamp: timestamp,
            action: action_
        });
        emit ActionMade(dogeOwner, id, block.timestamp, uint8(action_));
    }

    function doActionWithManyDoges(uint256[] calldata ids, Actions action_)
        external
    {

        for (uint256 index = 0; index < ids.length; index++) {
            require(
                ownerOf[ids[index]] == msg.sender || activities[ids[index]].owner == msg.sender,
                "not your doge"
            );
            _doAction(ids[index], msg.sender, action_, msg.sender);
        }
    }

    function claim(uint256[] calldata ids) external {

        for (uint256 index = 0; index < ids.length; index++) {
            _claim(ids[index]);
        }
    }

    function _claim(uint256 id) internal noCheaters {

        Action memory action = activities[id];

        if (block.timestamp <= action.timestamp) return;

        uint256 timeDiff = uint256(block.timestamp - action.timestamp);

        if (action.action == Actions.FARMING)
            treat.mint(
                action.owner,
                claimableTreat(timeDiff, id, action.owner)
            );

        activities[id].timestamp = uint88(block.timestamp);
    }

    function pull(address owner_, uint256[] calldata ids) external {

        require (msg.sender == castle, "not castle");
        for (uint256 index = 0; index < ids.length; index++) {
            if (activities[ids[index]].action != Actions.UNSTAKED) _doAction(ids[index], owner_, Actions.UNSTAKED, owner_);
            _transfer(owner_, msg.sender, ids[index]);
        }
        CastleLike(msg.sender).pullCallback(owner_, ids);
    }

    function manuallyAdjustDoge(uint256 id, uint8 head, uint8 breed, uint8 color, uint8 class, uint8 armor, uint8 offhand, uint8 mainhand, uint16 level) external {

        require(msg.sender == admin || auth[msg.sender], "not authorized");
        doges[id].head = head;
        doges[id].breed = breed;
        doges[id].color = color;
        doges[id].class = class;
        doges[id].armor = armor;
        doges[id].offhand = offhand;
        doges[id].mainhand = mainhand;
        doges[id].level = level;
    }


    function getTokenTraits(uint256 tokenId) external view returns (Doge memory) {

        if (rerollBlocks[tokenId] == block.number) return doges[0];
        return doges[tokenId];
    }

    function claimable(uint256 id) external view returns (uint256) {

        if (activities[id].action == Actions.FARMING) {
            uint256 timeDiff = block.timestamp > activities[id].timestamp
                ? uint256(block.timestamp - activities[id].timestamp)
                : 0;
            return claimableTreat(timeDiff, id, activities[id].owner);
        }
        return 0;
    }

    function getGenesisSupply() external pure returns (uint256) {

        return GENESIS_SUPPLY;
    }

    function name() external pure returns (string memory) {

        return "Doges";
    }

    function symbol() external pure returns (string memory) {

        return "Doges";
    }


    function _mintDoge(address to) internal {

        uint16 id = uint16(totalSupply + 1);
        rerollBlocks[id] = block.number;
        uint256 seed = random(id);
        generate(id, seed);
        _mint(to, id);
        mintLogs[id] = Log({
            owner: to,
            timestamp: uint88(block.timestamp)
        });
    }


    function claimableTreat(uint256 timeDiff, uint256 id, address owner_)
        internal
        view
        returns (uint256)
    {

        Doge memory doge = doges[id];
        uint256 rand_ = _rand();

        uint256 treatAmount = (timeDiff * 1 ether) / 1 days;
        if (doge.class == 0) { // Warrior
            uint16 randPlus = uint16(_randomize(rand_, "Warrior1", id));
            if (randPlus < fifteenPct) return treatAmount * 115 / 100;

            randPlus = uint16(_randomize(rand_, "Warrior2", id));
            if (randPlus < fifteenPct) return treatAmount * 85 / 100;
            return treatAmount;
        } else if(doge.class == 1) { // Rogue
            uint16 randPlus = uint16(_randomize(rand_, "Rogue", id));
            if (randPlus < tenPct) return treatAmount * 3;
            return treatAmount;
        } else if(doge.class == 2) { // Mage
            uint16 randPlus = uint16(_randomize(rand_, "Mage", id));
            if (randPlus < fiftyPct) return treatAmount * 5 / 10;
            return treatAmount * 2;
        } else if(doge.class == 3) { // Hunter
            return treatAmount * 125 / 100;
        } else if(doge.class == 4) { // Cleric
            return treatAmount;
        } else if(doge.class == 5) { // Bard
            uint256 balance = balanceOf[owner_];
            uint256 boost = 10 + (balance > 10 ? 10 : balance);
            return treatAmount * boost / 10;
        } else if(doge.class == 6) { // Merchant
            return treatAmount * (8 + (rand_ % 6)) / 10;
        } else if(doge.class == 7) { // Forager
            return treatAmount * (3 + doge.level) / 3;
        }
        
        return treatAmount;
    }

    function generate(uint256 tokenId, uint256 seed) internal returns (Doge memory t) {

        t = selectTraits(seed);
        doges[tokenId] = t;
        return t;

    }

    function selectTrait(uint16 seed, uint8 traitType) internal view returns (uint8) {

        uint8 trait = uint8(seed) % uint8(rarities[traitType].length);
        if (seed >> 8 < rarities[traitType][trait]) return trait;
        return aliases[traitType][trait];
    }

    function selectTraits(uint256 seed) internal view returns (Doge memory t) {    

        t.head = selectTrait(uint16(seed & 0xFFFF), 0);
        seed >>= 16;
        t.breed = selectTrait(uint16(seed & 0xFFFF), 1);
        seed >>= 16;
        t.color = selectTrait(uint16(seed & 0xFFFF), 2);
        seed >>= 16;
        t.class = selectTrait(uint16(seed & 0xFFFF), 3);
        seed >>= 16;
        t.armor = selectTrait(uint16(seed & 0xFFFF), 4);
        seed >>= 16;
        t.offhand = selectTrait(uint16(seed & 0xFFFF), 5);
        seed >>= 16;
        t.mainhand = selectTrait(uint16(seed & 0xFFFF), 6);
        t.level = 1;
    }

    function structToHash(Doge memory s) internal pure returns (uint256) {

        return uint256(bytes32(
        abi.encodePacked(
            s.head,
            s.breed,
            s.color,
            s.class,
            s.armor,
            s.offhand,
            s.mainhand,
            s.level
        )
        ));
    }

    function _randomize(
        uint256 rand,
        string memory val,
        uint256 spicy
    ) internal pure returns (uint256) {

        return uint256(keccak256(abi.encode(rand, val, spicy)));
    }

    function _rand() internal view returns (uint256) {

        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        entropySauce
                    )
                )
            );
    }

    function random(uint256 seed) internal view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp,
            seed
        )));
    }

    function _getMintingPrice() internal view returns (uint256) {

        uint256 supply = totalSupply;
        if (supply < 2500) return 0;
        if (supply < 3000) return 4 ether;
        if (supply < 4600) return 25 ether;
        if (supply < 5000) return 85 ether;
        return 85 ether;
    }




    function _delegate(address implementation) internal virtual {

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    

    fallback() external {
        if(implementer[msg.sig] == address(0)) {
            _delegate(impl);
        } else {
            _delegate(implementer[msg.sig]);
        }
    }
}