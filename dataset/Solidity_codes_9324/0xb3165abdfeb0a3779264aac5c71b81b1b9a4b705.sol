
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
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IPirateGames {}// MIT LICENSE


pragma solidity ^0.8.0;

interface IPytheas {

    function addColonistToPytheas(address account, uint16[] calldata tokenIds)
        external;


    function claimColonistFromPytheas(address account, uint16[] calldata tokenIds, bool unstake)
        external;


    function getColonistMined(address account, uint16 tokenId)
        external
        returns (uint256);


    function handleJoinPirates(address addr, uint16 tokenId) external;


    function payUp(
        uint16 tokenId,
        uint256 amtMined,
        address addr
    ) external;

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IOrbitalBlockade {

    function addPiratesToCrew(address account, uint16[] calldata tokenIds)
        external;

    
    function claimPiratesFromCrew(address account, uint16[] calldata tokenIds, bool unstake)
        external;


    function payPirateTax(uint256 amount) external;


    function randomPirateOwner(uint256 seed) external view returns (address);

}// MIT LICENSE
pragma solidity ^0.8.0;

interface ITPirates {

    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT LICENSE
pragma solidity ^0.8.0;

interface IRAW {


    function getBalance(
        address account,
        uint256 id
    ) external returns(uint256);


    function mint(
        uint256 typeId,
        uint256 qty,
        address recipient
    ) external;


    function burn(
        uint256 typeId,
        uint256 qty,
        address burnFrom
    ) external;


    function updateMintBurns(
        uint256 typeId,
        uint256 mintQty,
        uint256 burnQty
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;


}// MIT
pragma solidity ^0.8.0;

interface IEON {

    function mint(address to, uint256 amount) external;


    function burn(address from, uint256 amount) external;


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IPirates {

    struct Pirate {
        bool isPirate;
        uint8 sky;
        uint8 cockpit;
        uint8 base;
        uint8 engine;
        uint8 nose;
        uint8 wing;
        uint8 weapon1;
        uint8 weapon2;
        uint8 rank;
    }

    struct HPirates {
        uint8 Legendary;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;


    function minted() external returns (uint16);


    function piratesMinted() external returns (uint16);


    function isOwner(uint256 tokenId)
        external
        view
        returns (address);


    function _mintPirate(address recipient, uint256 seed) external;


    function burn(uint256 tokenId) external;


    function getTokenTraitsPirate(uint256 tokenId)
        external
        view
        returns (Pirate memory);


    function getTokenTraitsHonors(uint256 tokenId)
        external
        view
        returns (HPirates memory);


    function tokenNameByIndex(uint256 index)
        external
        view
        returns (string memory);

    
    function isHonors(uint256 tokenId)
        external
        view
        returns (bool);


    function hasBeenNamed(uint256 tokenId) external view returns (bool);


    function namePirate(uint256 tokenId, string memory newName) external;

}// MIT LICENSE
pragma solidity ^0.8.0;

interface IColonist {

    struct Colonist {
        bool isColonist;
        uint8 background;
        uint8 body;
        uint8 shirt;
        uint8 jacket;
        uint8 jaw;
        uint8 eyes;
        uint8 hair;
        uint8 held;
        uint8 gen;
    }

    struct HColonist {
        uint8 Legendary;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function isOwner(uint256 tokenId)
        external
        view
        returns (address);


    function minted() external returns (uint16);


    function totalCir() external returns (uint256);


    function _mintColonist(address recipient, uint256 seed) external;


    function _mintToHonors(address recipient, uint256 seed) external;


    function _mintHonors(address recipient, uint8 id) external;


    function burn(uint256 tokenId) external;


    function getMaxTokens() external view returns (uint256);


    function getPaidTokens() external view returns (uint256);


    function getTokenTraitsColonist(uint256 tokenId)
        external
        view
        returns (Colonist memory);


    function getTokenTraitsHonors(uint256 tokenId)
        external
        view
        returns (HColonist memory);


    function tokenNameByIndex(uint256 index)
        external
        view
        returns (string memory);


    function hasBeenNamed(uint256 tokenId) external view returns (bool);


    function nameColonist(uint256 tokenId, string memory newName) external;

}// MIT LICENSE
pragma solidity ^0.8.0;

interface IImperialGuild {


    function getBalance(
        address account,
        uint256 id
    ) external returns(uint256);


    function mint(
        uint256 typeId,
        uint256 paymentId,
        uint16 qty,
        address recipient
    ) external;


    function burn(
        uint256 typeId,
        uint16 qty,
        address burnFrom
    ) external;


    function handlePayment(uint256 amount) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IRandomizer {

    function random(uint256) external returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


contract PirateGames is IPirateGames, Pausable {

    uint8[][6] public rarities;
    uint8[][6] public aliases;

    uint256 public OnosiaLiquorId;

    uint256 private maxRawEonCost;

    uint256 public eonMintCost;

    uint256 public imperialFee;

    mapping(address => bool) private admins;

    bool public eonMintsEnabled;

    address public auth;

    IPytheas public pytheas;
    IOrbitalBlockade public orbital;
    IRAW public raw;
    IEON public eon;
    IPirates public pirateNFT;
    IColonist public colonistNFT;
    IImperialGuild public imperialGuild;
    IRandomizer private randomizer;


    constructor() {
        auth = msg.sender;
        admins[msg.sender] = true;

        rarities[0] = [230, 27];
        aliases[0] = [1, 0];
        rarities[1] = [204, 51];
        aliases[1] = [1, 0];
        rarities[2] = [175, 90];
        aliases[2] = [1, 0];
        rarities[3] = [132, 155];
        aliases[3] = [1, 0];
        rarities[4] = [60, 200];
        aliases[4] = [1, 0];
        rarities[5] = [255];
        aliases[5] = [0];
    }

    modifier noCheaters() {

        uint256 size = 0;
        address acc = msg.sender;
        assembly {
            size := extcodesize(acc)
        }

        require(
            admins[msg.sender] || (msg.sender == tx.origin && size == 0),
            "you're trying to cheat!"
        );
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == auth);
        _;
    }

    modifier requireContractsSet() {

        require(
            address(raw) != address(0) &&
                address(eon) != address(0) &&
                address(pirateNFT) != address(0) &&
                address(colonistNFT) != address(0) &&
                address(pytheas) != address(0) &&
                address(orbital) != address(0) &&
                address(imperialGuild) != address(0) &&
                address(randomizer) != address(0),
            "Contracts not set"
        );
        _;
    }

    function setContracts(
        address _rEON,
        address _eon,
        address _pirateNFT,
        address _colonistNFT,
        address _pytheas,
        address _orbital,
        address _imperialGuild,
        address _randomizer
    ) external onlyOwner {

        raw = IRAW(_rEON);
        eon = IEON(_eon);
        pirateNFT = IPirates(_pirateNFT);
        colonistNFT = IColonist(_colonistNFT);
        pytheas = IPytheas(_pytheas);
        orbital = IOrbitalBlockade(_orbital);
        imperialGuild = IImperialGuild(_imperialGuild);
        randomizer = IRandomizer(_randomizer);
    }

    function pirateAttempt(uint16 tokenId, bool stake) external noCheaters {

        require(eonMintsEnabled == false, "Eon Mints Only");
        uint16 piratesMinted = pirateNFT.piratesMinted();
        uint256 totalCir = colonistNFT.totalCir();
        uint256 minted = colonistNFT.minted();
        uint256 seed = random(minted);
        uint256 maxTokens = colonistNFT.getMaxTokens();
        uint256 rawCost = rawMintCost(minted, maxTokens);
        require(minted >= 10000, "Pirates available starting Colonist Gen 1");
        uint256 mined = pytheas.getColonistMined(msg.sender, tokenId);
        require(
            mined >= rawCost,
            "You have not mined enough to attempt this action"
        );
        uint8 chanceTable = getRatioChance(piratesMinted, totalCir);
        uint8 yayNay = getPirateResults(seed, chanceTable);
        if (yayNay == 0) {
            pytheas.payUp(tokenId, mined, msg.sender);
        } else {
            pytheas.handleJoinPirates(msg.sender, tokenId);
            uint256 outStanding = mined - rawCost;
            raw.updateMintBurns(1, mined, rawCost);
            raw.mint(1, outStanding, msg.sender);
            uint16[] memory pirateId = new uint16[](1);
            for (uint256 i = 0; i < 1; i++) {
                piratesMinted++;
                address recipient = selectRecipient(seed);
                if (
                    recipient != msg.sender &&
                    imperialGuild.getBalance(msg.sender, OnosiaLiquorId) > 0
                ) {
                    if (seed & 1 == 1) {
                        imperialGuild.safeTransferFrom(
                            msg.sender,
                            recipient,
                            OnosiaLiquorId,
                            1,
                            ""
                        );
                        recipient = msg.sender;
                    }
                }
                pirateId[i] = piratesMinted;
                if (!stake || recipient != msg.sender) {
                    pirateNFT._mintPirate(recipient, seed);
                } else {
                    pirateNFT._mintPirate(address(orbital), seed);
                    pirateId[i] = piratesMinted;
                }
            }
            if (stake) {
                orbital.addPiratesToCrew(msg.sender, pirateId);
            }
        }
    }

    function pirateAttemptEon(uint256 tokenId, bool stake) external noCheaters {

        require(eonMintsEnabled == true, "Raw Eon attempts only");
        uint16 piratesMinted = pirateNFT.piratesMinted();
        uint256 totalCir = colonistNFT.totalCir();
        uint256 seed = random(totalCir);
        uint8 chanceTable = getRatioChance(piratesMinted, totalCir);
        uint8 yayNay = getPirateResults(seed, chanceTable);
        if (yayNay == 0) {
            imperialGuild.handlePayment(imperialFee);
        } else {
            colonistNFT.burn(tokenId);
            imperialGuild.handlePayment(eonMintCost);
            uint16[] memory pirateId = new uint16[](1);
            for (uint256 i = 0; i < 1; i++) {
                piratesMinted++;
                address recipient = selectRecipient(seed);
                if (
                    recipient != msg.sender &&
                    imperialGuild.getBalance(msg.sender, OnosiaLiquorId) > 0
                ) {
                    if (seed & 1 == 1) {
                        imperialGuild.safeTransferFrom(
                            msg.sender,
                            recipient,
                            OnosiaLiquorId,
                            1,
                            ""
                        );
                        recipient = msg.sender;
                    }
                }
                pirateId[i] = piratesMinted;
                if (!stake || recipient != msg.sender) {
                    pirateNFT._mintPirate(recipient, seed);
                } else {
                    pirateNFT._mintPirate(address(orbital), seed);
                    pirateId[i] = piratesMinted;
                }
            }
            if (stake) {
                orbital.addPiratesToCrew(msg.sender, pirateId);
            }
        }
    }

    function rawMintCost(uint256 tokenId, uint256 maxTokens)
        public
        view
        returns (uint256)
    {

        if (tokenId <= (maxTokens * 8) / 24) return 4000; //10k-20k
        if (tokenId <= (maxTokens * 12) / 24) return 16000; //20k-30k
        if (tokenId <= (maxTokens * 16) / 24) return 48000; //30k-40k
        if (tokenId <= (maxTokens * 20) / 24) return 122500; //40k-50k
        if (tokenId <= (maxTokens * 22) / 24) return 250000; //50k-55k
        return maxRawEonCost;
    }

    function getRatioChance(uint256 pirates, uint256 circulation)
        public
        pure
        returns (uint8)
    {

        uint256 ratio = (pirates * 10000) / circulation;

        if (ratio <= 100) {
            return 0;
        } else if (ratio <= 300 && ratio >= 100) {
            return 1;
        } else if (ratio <= 500 && ratio >= 300) {
            return 2;
        } else if (ratio <= 800 && ratio >= 500) {
            return 3;
        } else if (ratio <= 999 && ratio >= 800) {
            return 4;
        } else {
            return 5;
        }
    }


    function getPirateResults(uint256 seed, uint8 chanceTable)
        internal
        view
        returns (uint8)
    {

        seed >>= 16;
        uint8 yayNay = getResult(uint16(seed & 0xFFFF), chanceTable);
        return yayNay;
    }

    function getResult(uint256 seed, uint8 chanceTable)
        internal
        view
        returns (uint8)
    {

        uint8 result = uint8(seed) % uint8(rarities[chanceTable].length);
        if (seed >> 8 < rarities[chanceTable][result]) return result;
        return aliases[chanceTable][result];
    }


    function selectRecipient(uint256 seed) internal view returns (address) {

        if (((seed >> 245) % 10) != 0) return msg.sender; // top 10 bits
        address thief = orbital.randomPirateOwner(seed >> 144); // 144 bits reserved for trait selection
        if (thief == address(0x0)) return msg.sender;
        return thief;
    }

    function setPaused(bool _paused) external requireContractsSet onlyOwner {

        if (_paused) _pause();
        else _unpause();
    }

    function activateEonMints(bool _eonMintsEnabled) external onlyOwner {

        eonMintsEnabled = _eonMintsEnabled;
    }

    function setEonMintCost(uint256 _eonMintCost, uint256 _imperialFee)
        external
        onlyOwner
    {

        eonMintCost = _eonMintCost;
        imperialFee = _imperialFee;
    }

    function setOnosiaLiquorId(uint256 typeId) external onlyOwner {

        OnosiaLiquorId = typeId;
    }

    function addAdmin(address addr) external onlyOwner {

        admins[addr] = true;
    }

    function removeAdmin(address addr) external onlyOwner {

        admins[addr] = false;
    }

    function random(uint256 seed) internal view returns (uint256) {

        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }
}