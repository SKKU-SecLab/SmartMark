
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}//MIT
pragma solidity ^0.8.0;


interface IExtensibleERC721Enumerable is IERC721Enumerable {

    function isAdmin(address addr) external view returns (bool);


    function addAdmin(address addr) external;


    function removeAdmin(address addr) external;


    function canAccessToken(address addr, uint tokenId) external view returns (bool);


    function adminBurn(uint tokenId) external;


    function adminTransfer(address from, address to, uint tokenId) external;

}//MIT
pragma solidity ^0.8.0;

enum Accessory {
    GOLD_EARRINGS,
    SCARS,
    GOLDEN_CHAIN,
    AMULET,
    CUBAN_LINK_GOLD_CHAIN,
    FANNY_PACK,
    NONE
}

enum BackAccessory {
    NETRUNNER,
    MERCENARY,
    RONIN,
    ENCHANTER,
    VANGUARD,
    MINER,
    PATHFINDER,
    SCOUT
}

enum Background {
    STARRY_PINK,
    STARRY_YELLOW,
    STARRY_PURPLE,
    STARRY_GREEN,
    NEBULA,
    STARRY_RED,
    STARRY_BLUE,
    SUNSET,
    MORNING,
    INDIGO,
    CITY__PURPLE,
    CONTROL_ROOM,
    LAB,
    GREEN,
    ORANGE,
    PURPLE,
    CITY__GREEN,
    CITY__RED,
    STATION,
    BOUNTY,
    BLUE_SKY,
    RED_SKY,
    GREEN_SKY
}

enum Clothing {
    MARTIAL_SUIT,
    AMETHYST_ARMOR,
    SHIRT_AND_TIE,
    THUNDERDOME_ARMOR,
    FLEET_UNIFORM__BLUE,
    BANANITE_SHIRT,
    EXPLORER,
    COSMIC_GHILLIE_SUIT__BLUE,
    COSMIC_GHILLIE_SUIT__GOLD,
    CYBER_JUMPSUIT,
    ENCHANTER_ROBES,
    HOODIE,
    SPACESUIT,
    MECHA_ARMOR,
    LAB_COAT,
    FLEET_UNIFORM__RED,
    GOLD_ARMOR,
    ENERGY_ARMOR__BLUE,
    ENERGY_ARMOR__RED,
    MISSION_SUIT__BLACK,
    MISSION_SUIT__PURPLE,
    COWBOY,
    GLITCH_ARMOR,
    NONE
}

enum Eyes {
    SPACE_VISOR,
    ADORABLE,
    VETERAN,
    SUNGLASSES,
    WHITE_SUNGLASSES,
    RED_EYES,
    WINK,
    CASUAL,
    CLOSED,
    DOWNCAST,
    HAPPY,
    BLUE_EYES,
    HUD_GLASSES,
    DARK_SUNGLASSES,
    NIGHT_VISION_GOGGLES,
    BIONIC,
    HIVE_GOGGLES,
    MATRIX_GLASSES,
    GREEN_GLOW,
    ORANGE_GLOW,
    RED_GLOW,
    PURPLE_GLOW,
    BLUE_GLOW,
    SKY_GLOW,
    RED_LASER,
    BLUE_LASER,
    GOLDEN_SHADES,
    HIPSTER_GLASSES,
    PINCENEZ,
    BLUE_SHADES,
    BLIT_GLASSES,
    NOUNS_GLASSES
}

enum Fur {
    MAGENTA,
    BLUE,
    GREEN,
    RED,
    BLACK,
    BROWN,
    SILVER,
    PURPLE,
    PINK,
    SEANCE,
    TURQUOISE,
    CRIMSON,
    GREENYELLOW,
    GOLD,
    DIAMOND,
    METALLIC
}

enum Head {
    HALO,
    ENERGY_FIELD,
    BLUE_TOP_HAT,
    RED_TOP_HAT,
    ENERGY_CRYSTAL,
    CROWN,
    BANDANA,
    BUCKET_HAT,
    HOMBURG_HAT,
    PROPELLER_HAT,
    HEADBAND,
    DORAG,
    PURPLE_COWBOY_HAT,
    SPACESUIT_HELMET,
    PARTY_HAT,
    CAP,
    LEATHER_COWBOY_HAT,
    CYBER_HELMET__BLUE,
    CYBER_HELMET__RED,
    SAMURAI_HAT,
    NONE
}

enum Mouth {
    SMIRK,
    SURPRISED,
    SMILE,
    PIPE,
    OPEN_SMILE,
    NEUTRAL,
    MASK,
    TONGUE_OUT,
    GOLD_GRILL,
    DIAMOND_GRILL,
    NAVY_RESPIRATOR,
    RED_RESPIRATOR,
    MAGENTA_RESPIRATOR,
    GREEN_RESPIRATOR,
    MEMPO,
    VAPE,
    PILOT_OXYGEN_MASK,
    CIGAR,
    BANANA,
    CHROME_RESPIRATOR,
    STOIC
}

library Enums {

    function toString(Accessory v) external pure returns (string memory) {

        if (v == Accessory.GOLD_EARRINGS) {
            return "Gold Earrings";
        }

        if (v == Accessory.SCARS) {
            return "Scars";
        }

        if (v == Accessory.GOLDEN_CHAIN) {
            return "Golden Chain";
        }

        if (v == Accessory.AMULET) {
            return "Amulet";
        }

        if (v == Accessory.CUBAN_LINK_GOLD_CHAIN) {
            return "Cuban Link Gold Chain";
        }

        if (v == Accessory.FANNY_PACK) {
            return "Fanny Pack";
        }

        if (v == Accessory.NONE) {
            return "None";
        }
        revert("invalid accessory");
    }

    function toString(BackAccessory v) external pure returns (string memory) {

        if (v == BackAccessory.NETRUNNER) {
            return "Netrunner";
        }

        if (v == BackAccessory.MERCENARY) {
            return "Mercenary";
        }

        if (v == BackAccessory.RONIN) {
            return "Ronin";
        }

        if (v == BackAccessory.ENCHANTER) {
            return "Enchanter";
        }

        if (v == BackAccessory.VANGUARD) {
            return "Vanguard";
        }

        if (v == BackAccessory.MINER) {
            return "Miner";
        }

        if (v == BackAccessory.PATHFINDER) {
            return "Pathfinder";
        }

        if (v == BackAccessory.SCOUT) {
            return "Scout";
        }
        revert("invalid back accessory");
    }

    function toString(Background v) external pure returns (string memory) {

        if (v == Background.STARRY_PINK) {
            return "Starry Pink";
        }

        if (v == Background.STARRY_YELLOW) {
            return "Starry Yellow";
        }

        if (v == Background.STARRY_PURPLE) {
            return "Starry Purple";
        }

        if (v == Background.STARRY_GREEN) {
            return "Starry Green";
        }

        if (v == Background.NEBULA) {
            return "Nebula";
        }

        if (v == Background.STARRY_RED) {
            return "Starry Red";
        }

        if (v == Background.STARRY_BLUE) {
            return "Starry Blue";
        }

        if (v == Background.SUNSET) {
            return "Sunset";
        }

        if (v == Background.MORNING) {
            return "Morning";
        }

        if (v == Background.INDIGO) {
            return "Indigo";
        }

        if (v == Background.CITY__PURPLE) {
            return "City - Purple";
        }

        if (v == Background.CONTROL_ROOM) {
            return "Control Room";
        }

        if (v == Background.LAB) {
            return "Lab";
        }

        if (v == Background.GREEN) {
            return "Green";
        }

        if (v == Background.ORANGE) {
            return "Orange";
        }

        if (v == Background.PURPLE) {
            return "Purple";
        }

        if (v == Background.CITY__GREEN) {
            return "City - Green";
        }

        if (v == Background.CITY__RED) {
            return "City - Red";
        }

        if (v == Background.STATION) {
            return "Station";
        }

        if (v == Background.BOUNTY) {
            return "Bounty";
        }

        if (v == Background.BLUE_SKY) {
            return "Blue Sky";
        }

        if (v == Background.RED_SKY) {
            return "Red Sky";
        }

        if (v == Background.GREEN_SKY) {
            return "Green Sky";
        }
        revert("invalid background");
    }

    function toString(Clothing v) external pure returns (string memory) {

        if (v == Clothing.MARTIAL_SUIT) {
            return "Martial Suit";
        }

        if (v == Clothing.AMETHYST_ARMOR) {
            return "Amethyst Armor";
        }

        if (v == Clothing.SHIRT_AND_TIE) {
            return "Shirt and Tie";
        }

        if (v == Clothing.THUNDERDOME_ARMOR) {
            return "Thunderdome Armor";
        }

        if (v == Clothing.FLEET_UNIFORM__BLUE) {
            return "Fleet Uniform - Blue";
        }

        if (v == Clothing.BANANITE_SHIRT) {
            return "Bananite Shirt";
        }

        if (v == Clothing.EXPLORER) {
            return "Explorer";
        }

        if (v == Clothing.COSMIC_GHILLIE_SUIT__BLUE) {
            return "Cosmic Ghillie Suit - Blue";
        }

        if (v == Clothing.COSMIC_GHILLIE_SUIT__GOLD) {
            return "Cosmic Ghillie Suit - Gold";
        }

        if (v == Clothing.CYBER_JUMPSUIT) {
            return "Cyber Jumpsuit";
        }

        if (v == Clothing.ENCHANTER_ROBES) {
            return "Enchanter Robes";
        }

        if (v == Clothing.HOODIE) {
            return "Hoodie";
        }

        if (v == Clothing.SPACESUIT) {
            return "Spacesuit";
        }

        if (v == Clothing.MECHA_ARMOR) {
            return "Mecha Armor";
        }

        if (v == Clothing.LAB_COAT) {
            return "Lab Coat";
        }

        if (v == Clothing.FLEET_UNIFORM__RED) {
            return "Fleet Uniform - Red";
        }

        if (v == Clothing.GOLD_ARMOR) {
            return "Gold Armor";
        }

        if (v == Clothing.ENERGY_ARMOR__BLUE) {
            return "Energy Armor - Blue";
        }

        if (v == Clothing.ENERGY_ARMOR__RED) {
            return "Energy Armor - Red";
        }

        if (v == Clothing.MISSION_SUIT__BLACK) {
            return "Mission Suit - Black";
        }

        if (v == Clothing.MISSION_SUIT__PURPLE) {
            return "Mission Suit - Purple";
        }

        if (v == Clothing.COWBOY) {
            return "Cowboy";
        }

        if (v == Clothing.GLITCH_ARMOR) {
            return "Glitch Armor";
        }

        if (v == Clothing.NONE) {
            return "None";
        }
        revert("invalid clothing");
    }

    function toString(Eyes v) external pure returns (string memory) {

        if (v == Eyes.SPACE_VISOR) {
            return "Space Visor";
        }

        if (v == Eyes.ADORABLE) {
            return "Adorable";
        }

        if (v == Eyes.VETERAN) {
            return "Veteran";
        }

        if (v == Eyes.SUNGLASSES) {
            return "Sunglasses";
        }

        if (v == Eyes.WHITE_SUNGLASSES) {
            return "White Sunglasses";
        }

        if (v == Eyes.RED_EYES) {
            return "Red Eyes";
        }

        if (v == Eyes.WINK) {
            return "Wink";
        }

        if (v == Eyes.CASUAL) {
            return "Casual";
        }

        if (v == Eyes.CLOSED) {
            return "Closed";
        }

        if (v == Eyes.DOWNCAST) {
            return "Downcast";
        }

        if (v == Eyes.HAPPY) {
            return "Happy";
        }

        if (v == Eyes.BLUE_EYES) {
            return "Blue Eyes";
        }

        if (v == Eyes.HUD_GLASSES) {
            return "HUD Glasses";
        }

        if (v == Eyes.DARK_SUNGLASSES) {
            return "Dark Sunglasses";
        }

        if (v == Eyes.NIGHT_VISION_GOGGLES) {
            return "Night Vision Goggles";
        }

        if (v == Eyes.BIONIC) {
            return "Bionic";
        }

        if (v == Eyes.HIVE_GOGGLES) {
            return "Hive Goggles";
        }

        if (v == Eyes.MATRIX_GLASSES) {
            return "Matrix Glasses";
        }

        if (v == Eyes.GREEN_GLOW) {
            return "Green Glow";
        }

        if (v == Eyes.ORANGE_GLOW) {
            return "Orange Glow";
        }

        if (v == Eyes.RED_GLOW) {
            return "Red Glow";
        }

        if (v == Eyes.PURPLE_GLOW) {
            return "Purple Glow";
        }

        if (v == Eyes.BLUE_GLOW) {
            return "Blue Glow";
        }

        if (v == Eyes.SKY_GLOW) {
            return "Sky Glow";
        }

        if (v == Eyes.RED_LASER) {
            return "Red Laser";
        }

        if (v == Eyes.BLUE_LASER) {
            return "Blue Laser";
        }

        if (v == Eyes.GOLDEN_SHADES) {
            return "Golden Shades";
        }

        if (v == Eyes.HIPSTER_GLASSES) {
            return "Hipster Glasses";
        }

        if (v == Eyes.PINCENEZ) {
            return "Pince-nez";
        }

        if (v == Eyes.BLUE_SHADES) {
            return "Blue Shades";
        }

        if (v == Eyes.BLIT_GLASSES) {
            return "Blit GLasses";
        }

        if (v == Eyes.NOUNS_GLASSES) {
            return "Nouns Glasses";
        }
        revert("invalid eyes");
    }

    function toString(Fur v) external pure returns (string memory) {

        if (v == Fur.MAGENTA) {
            return "Magenta";
        }

        if (v == Fur.BLUE) {
            return "Blue";
        }

        if (v == Fur.GREEN) {
            return "Green";
        }

        if (v == Fur.RED) {
            return "Red";
        }

        if (v == Fur.BLACK) {
            return "Black";
        }

        if (v == Fur.BROWN) {
            return "Brown";
        }

        if (v == Fur.SILVER) {
            return "Silver";
        }

        if (v == Fur.PURPLE) {
            return "Purple";
        }

        if (v == Fur.PINK) {
            return "Pink";
        }

        if (v == Fur.SEANCE) {
            return "Seance";
        }

        if (v == Fur.TURQUOISE) {
            return "Turquoise";
        }

        if (v == Fur.CRIMSON) {
            return "Crimson";
        }

        if (v == Fur.GREENYELLOW) {
            return "Green-Yellow";
        }

        if (v == Fur.GOLD) {
            return "Gold";
        }

        if (v == Fur.DIAMOND) {
            return "Diamond";
        }

        if (v == Fur.METALLIC) {
            return "Metallic";
        }
        revert("invalid fur");
    }

    function toString(Head v) external pure returns (string memory) {

        if (v == Head.HALO) {
            return "Halo";
        }

        if (v == Head.ENERGY_FIELD) {
            return "Energy Field";
        }

        if (v == Head.BLUE_TOP_HAT) {
            return "Blue Top Hat";
        }

        if (v == Head.RED_TOP_HAT) {
            return "Red Top Hat";
        }

        if (v == Head.ENERGY_CRYSTAL) {
            return "Energy Crystal";
        }

        if (v == Head.CROWN) {
            return "Crown";
        }

        if (v == Head.BANDANA) {
            return "Bandana";
        }

        if (v == Head.BUCKET_HAT) {
            return "Bucket Hat";
        }

        if (v == Head.HOMBURG_HAT) {
            return "Homburg Hat";
        }

        if (v == Head.PROPELLER_HAT) {
            return "Propeller Hat";
        }

        if (v == Head.HEADBAND) {
            return "Headband";
        }

        if (v == Head.DORAG) {
            return "Do-rag";
        }

        if (v == Head.PURPLE_COWBOY_HAT) {
            return "Purple Cowboy Hat";
        }

        if (v == Head.SPACESUIT_HELMET) {
            return "Spacesuit Helmet";
        }

        if (v == Head.PARTY_HAT) {
            return "Party Hat";
        }

        if (v == Head.CAP) {
            return "Cap";
        }

        if (v == Head.LEATHER_COWBOY_HAT) {
            return "Leather Cowboy Hat";
        }

        if (v == Head.CYBER_HELMET__BLUE) {
            return "Cyber Helmet - Blue";
        }

        if (v == Head.CYBER_HELMET__RED) {
            return "Cyber Helmet - Red";
        }

        if (v == Head.SAMURAI_HAT) {
            return "Samurai Hat";
        }

        if (v == Head.NONE) {
            return "None";
        }
        revert("invalid head");
    }

    function toString(Mouth v) external pure returns (string memory) {

        if (v == Mouth.SMIRK) {
            return "Smirk";
        }

        if (v == Mouth.SURPRISED) {
            return "Surprised";
        }

        if (v == Mouth.SMILE) {
            return "Smile";
        }

        if (v == Mouth.PIPE) {
            return "Pipe";
        }

        if (v == Mouth.OPEN_SMILE) {
            return "Open Smile";
        }

        if (v == Mouth.NEUTRAL) {
            return "Neutral";
        }

        if (v == Mouth.MASK) {
            return "Mask";
        }

        if (v == Mouth.TONGUE_OUT) {
            return "Tongue Out";
        }

        if (v == Mouth.GOLD_GRILL) {
            return "Gold Grill";
        }

        if (v == Mouth.DIAMOND_GRILL) {
            return "Diamond Grill";
        }

        if (v == Mouth.NAVY_RESPIRATOR) {
            return "Navy Respirator";
        }

        if (v == Mouth.RED_RESPIRATOR) {
            return "Red Respirator";
        }

        if (v == Mouth.MAGENTA_RESPIRATOR) {
            return "Magenta Respirator";
        }

        if (v == Mouth.GREEN_RESPIRATOR) {
            return "Green Respirator";
        }

        if (v == Mouth.MEMPO) {
            return "Mempo";
        }

        if (v == Mouth.VAPE) {
            return "Vape";
        }

        if (v == Mouth.PILOT_OXYGEN_MASK) {
            return "Pilot Oxygen Mask";
        }

        if (v == Mouth.CIGAR) {
            return "Cigar";
        }

        if (v == Mouth.BANANA) {
            return "Banana";
        }

        if (v == Mouth.CHROME_RESPIRATOR) {
            return "Chrome Respirator";
        }

        if (v == Mouth.STOIC) {
            return "Stoic";
        }
        revert("invalid mouth");
    }
}//MIT
pragma solidity ^0.8.0;


struct KeyValuePair {
    string key;
    string value;
}

struct ChainScoutMetadata {
    Accessory accessory;
    BackAccessory backaccessory;
    Background background;
    Clothing clothing;
    Eyes eyes;
    Fur fur;
    Head head;
    Mouth mouth;
    uint24 attack;
    uint24 defense;
    uint24 luck;
    uint24 speed;
    uint24 strength;
    uint24 intelligence;
    uint16 level;
}//MIT
pragma solidity ^0.8.0;


interface IChainScouts is IExtensibleERC721Enumerable {

    function adminCreateChainScout(
        ChainScoutMetadata calldata tbd,
        address owner
    ) external;


    function adminRemoveExtension(string calldata key) external;


    function adminSetExtension(
        string calldata key,
        ChainScoutsExtension extension
    ) external;


    function adminSetChainScoutMetadata(
        uint256 tokenId,
        ChainScoutMetadata calldata tbd
    ) external;


    function getChainScoutMetadata(uint256 tokenId)
        external
        view
        returns (ChainScoutMetadata memory);

}//MIT
pragma solidity ^0.8.0;


abstract contract ChainScoutsExtension {
    IChainScouts internal chainScouts;
    bool public enabled = true;

    modifier canAccessToken(uint tokenId) {
        require(chainScouts.canAccessToken(msg.sender, tokenId), "ChainScoutsExtension: you don't own the token");
        _;
    }

    modifier onlyAdmin() {
        require(chainScouts.isAdmin(msg.sender), "ChainScoutsExtension: admins only");
        _;
    }

    modifier whenEnabled() {
        require(enabled, "ChainScoutsExtension: currently disabled");
        _;
    }

    function adminSetEnabled(bool e) external onlyAdmin {
        enabled = e;
    }

    function extensionKey() public virtual view returns (string memory);

    function setChainScouts(IChainScouts _contract) external {
        require(address(0) == address(chainScouts) || chainScouts.isAdmin(msg.sender), "ChainScoutsExtension: The Chain Scouts contract must not be set or you must be an admin");
        chainScouts = _contract;
        chainScouts.adminSetExtension(extensionKey(), this);
    }
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
}//MIT
pragma solidity ^0.8.0;


interface IUtilityERC20 is IERC20 {

    function adminMint(address owner, uint amountWei) external;


    function adminSetTokenTimestamp(uint tokenId, uint timestamp) external;


    function burn(address owner, uint amountWei) external;


    function claimRewards() external;


    function stake(uint[] calldata tokenId) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}//MIT
pragma solidity ^0.8.0;

struct Rng {
    bytes32 state;
}

library RngLibrary {
    function newRng() internal view returns (Rng memory) {
        return Rng(getEntropy());
    }

    function getEntropy() internal view returns (bytes32) {
        return keccak256(abi.encodePacked(block.coinbase, msg.sender));
    }

    function generate(Rng memory self) internal view returns (uint256) {
        self.state = keccak256(abi.encodePacked(getEntropy(), self.state));
        return uint256(self.state);
    }

    function generate(Rng memory self, uint min, uint max) internal view returns (uint256) {
        require(min <= max, "min > max");

        uint delta = max - min;

        if (delta == 0) {
            return min;
        }

        return generate(self) % (delta + 1) + min;
    }
}//MIT
pragma solidity ^0.8.0;


abstract contract StakingERC20 is
    ChainScoutsExtension,
    IUtilityERC20,
    ERC20Burnable
{
    Rng internal rng = RngLibrary.newRng();

    mapping(uint256 => uint256) public lastClaimTime;
    mapping(uint256 => address) public tokenIdOwners;
    mapping(address => mapping(uint256 => uint256)) public ownerTokenIds;
    mapping(address => uint256) public numberTokensStaked;

    function adminMint(address owner, uint256 amountWei)
        external
        override
        onlyAdmin
    {
        super._mint(owner, amountWei);
    }

    function adminSetTokenTimestamp(uint256 tokenId, uint256 timestamp)
        external
        override
        onlyAdmin
    {
        lastClaimTime[tokenId] = timestamp;
    }

    function burn(address owner, uint256 amountWei) external override {
        require(
            chainScouts.isAdmin(msg.sender) || msg.sender == owner,
            "must be admin or owner"
        );
        super._burn(owner, amountWei);
    }

    function calculateTokenRewards(Rng memory rn, uint256 tokenId)
        public
        view
        returns (uint256 rewards)
    {
        rewards = calculateTokenRewardsOverTime(
            rn,
            tokenId,
            block.timestamp > lastClaimTime[tokenId] &&
                lastClaimTime[tokenId] > 0
                ? block.timestamp - lastClaimTime[tokenId]
                : 0
        );
    }

    function calculateTokenRewardsOverTime(
        Rng memory,
        uint256,
        uint256 secondsElapsedSinceLastClaim
    ) public view virtual returns (uint256) {
        return (secondsElapsedSinceLastClaim * 1 ether) / 1 days;
    }

    function claimRewards() external virtual override whenEnabled {
        Rng memory rn = rng;
        uint count = 0;

        for (uint256 i = 0; i < numberTokensStaked[msg.sender]; ++i) {
            uint256 tid = ownerTokenIds[msg.sender][i];
            count += calculateTokenRewards(rn, tid);
            lastClaimTime[tid] = block.timestamp;
        }

        if (count > 0) {
            super._mint(msg.sender, count);
        }

        rng = rn;
    }

    function stake(uint256[] calldata tokenIds) public virtual override whenEnabled {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 tokenId = tokenIds[i];
            require(
                chainScouts.canAccessToken(msg.sender, tokenId),
                "ChainScoutsExtension: you don't own the token"
            );
            require(
                tokenIdOwners[tokenId] == address(0),
                "StakingERC20: This token is already staked"
            );

            address owner = chainScouts.ownerOf(tokenId);

            lastClaimTime[tokenId] = block.timestamp;
            tokenIdOwners[tokenId] = owner;
            ownerTokenIds[owner][numberTokensStaked[owner]] = tokenId;
            numberTokensStaked[owner]++;
            chainScouts.adminTransfer(owner, address(this), tokenId);
        }
    }

    function unstake(uint256[] calldata tokenIds) public virtual whenEnabled {
        Rng memory rn = rng;

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint tokenId = tokenIds[i];
            require(
                tokenIdOwners[tokenId] == msg.sender,
                "StakingERC20: You don't own this token"
            );

            uint256 rewards = calculateTokenRewards(rn, tokenId);
            if (rewards > 0) {
                super._mint(msg.sender, rewards);
            }

            tokenIdOwners[tokenId] = address(0);
            for (uint256 j = 0; j < numberTokensStaked[msg.sender]; ++j) {
                if (ownerTokenIds[msg.sender][j] == tokenId) {
                    uint256 lastIndex = numberTokensStaked[msg.sender] - 1;
                    ownerTokenIds[msg.sender][j] = ownerTokenIds[msg.sender][
                        lastIndex
                    ];
                    delete ownerTokenIds[msg.sender][lastIndex];
                    break;
                }
            }
            numberTokensStaked[msg.sender]--;
            chainScouts.adminTransfer(address(this), msg.sender, tokenId);
        }

        rng = rn;
    }
}//MIT
pragma solidity ^0.8.0;


contract Bananite is StakingERC20 {
    using RngLibrary for Rng;

    mapping(address => uint256) public scoutCounts;

    constructor() ERC20("Bananite", "BANANITE") {}

    function extensionKey() public pure override returns (string memory) {
        return "token";
    }

    function calculateTokenRewardsOverTime(
        Rng memory rn,
        uint256 tokenId,
        uint256 secs
    ) public view override returns (uint256) {
        ChainScoutMetadata memory sm = chainScouts.getChainScoutMetadata(tokenId);
        BackAccessory c = sm.backaccessory;
        secs *= 1 ether;

        if (c == BackAccessory.SCOUT) {
            uint256 scoutNumerator = scoutCounts[tokenIdOwners[tokenId]] >= 5
                ? 8
                : 7;
            secs = secs * scoutNumerator / 2;
        } else if (c == BackAccessory.MERCENARY) {
            uint256 r = rn.generate(1, 10);
            if (r <= 2) {
                secs = (secs * 119) / 40;
            } else if (r >= 9) {
                secs = (secs * 21) / 5;
            } else {
                secs = (secs * 7) / 2;
            }
        } else if (c == BackAccessory.VANGUARD) {
            uint256 n = rn.generate(140, 210);
            secs = (secs * n) / 50;
        } else if (c == BackAccessory.RONIN) {
            uint256 r = rn.generate(1, 20);
            if (r == 1) {
                secs = secs * 3;
            } else {
                secs = secs * 6;
            }
        } else if (c == BackAccessory.MINER) {
            uint256 r = rn.generate(1, 10);
            if (r == 1) {
                secs = secs * 15;
            } else {
                secs = (secs * 15) / 2;
            }
        } else if (c == BackAccessory.PATHFINDER) {
            uint256 r = rn.generate(390, 975);
            secs = (secs * r) / 100;
        } else if (c == BackAccessory.ENCHANTER) {
            uint256 r = rn.generate(90, 140);
            secs = (secs * r) / 20;
        } else {
            uint256 r = rn.generate(1, 10);
            if (r == 1) {
                secs = secs * 2;
            } else {
                secs = secs * 10;
            }
        }

        return secs / 1 days;
    }

    function stake(uint256[] calldata tokenIds) public override {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            ChainScoutMetadata memory md = chainScouts.getChainScoutMetadata(
                tokenIds[i]
            );
            if (md.backaccessory == BackAccessory.SCOUT) {
                scoutCounts[chainScouts.ownerOf(tokenIds[i])]++;
            }
        }
        super.stake(tokenIds);
    }

    function unstake(uint256[] calldata tokenIds) public override {
        super.unstake(tokenIds);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            ChainScoutMetadata memory md = chainScouts.getChainScoutMetadata(
                tokenIds[i]
            );
            if (md.backaccessory == BackAccessory.SCOUT) {
                scoutCounts[chainScouts.ownerOf(tokenIds[i])]--;
            }
        }
    }
}