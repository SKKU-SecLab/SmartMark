
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
pragma solidity ^0.8.11;

interface IERC721TokenReceiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);

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

interface IPirateGames {}// MIT LICENSE


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


    function updateOriginAccess(uint16[] memory tokenIds) external;


    function getTokenWriteBlock(uint256 tokenId) 
    external 
    view  
    returns(uint64);


    function hasBeenNamed(uint256 tokenId) external view returns (bool);


    function namePirate(uint256 tokenId, string memory newName) external;

}// MIT LICENSE
pragma solidity ^0.8.0;

interface IRAW {


    function updateOriginAccess(address user) external;



    function balanceOf(
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


}// MIT LICENSE
pragma solidity ^0.8.0;

interface IMasterStaker {


 function masterStake(
        uint16[] calldata colonistTokenIds,
        uint16[] calldata pirateTokenIds
    ) external;


 function masterUnstake(
        uint16[] calldata colonistTokenIds,
        uint16[] calldata pirateTokenIds
    ) external;


 function masterClaim(
        uint16[] calldata colonistTokenIds,
        uint16[] calldata pirateTokenIds
    ) external;

}// MIT LICENSE

pragma solidity ^0.8.0;


contract OrbitalBlockade is IOrbitalBlockade, IERC721TokenReceiver, Pausable {

    uint8 public constant MAX_RANK = 8;

    struct Stake {
        uint16 tokenId;
        uint80 value;
        address sOwner;
    }

    event PirateStaked(
        address indexed sOwner,
        uint256 indexed tokenId,
        uint256 value
    );

    event PirateClaimed(
        uint256 indexed tokenId,
        bool indexed unstaked,
        uint256 earned
    );

    IPirates public pirateNFT;
    IPirateGames public pirGames;
    IRAW public raw;
    IMasterStaker public masterStaker;

    mapping(uint256 => Stake) private orbital;
    mapping(uint256 => Stake[]) private crew;
    mapping(uint256 => uint256) private crewIndices;
    mapping(address => bool) private admins;

    uint256 public rawEonPerRank = 0;

    uint256 private totalRankStaked;

    uint256 public piratesStaked;

    uint256 private unaccountedRewards = 0;

    address public auth;

    bool rescueEnabled;

    constructor() {
        _pause();
        auth = msg.sender;
        admins[msg.sender] = true;
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
            address(pirateNFT) != address(0) &&
                address(raw) != address(0) &&
                address(pirGames) != address(0) &&
                address(masterStaker) != address(0),
            "Contracts not set"
        );
        _;
    }

    function setContracts(
        address _pirateNFT,
        address _raw,
        address _pirGames,
        address _masterStaker
    ) external onlyOwner {

        pirateNFT = IPirates(_pirateNFT);
        raw = IRAW(_raw);
        pirGames = IPirateGames(_pirGames);
        masterStaker = IMasterStaker(_masterStaker);
    }


    function addPiratesToCrew(address account, uint16[] calldata tokenIds)
        external
        override
        whenNotPaused
        noCheaters
    {

        require(account == tx.origin);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (msg.sender == address(masterStaker)) {
                require(
                    pirateNFT.isOwner(tokenIds[i]) == account,
                    "Not Pirate Owner"
                );
                pirateNFT.transferFrom(account, address(this), tokenIds[i]);
            } else if (msg.sender != address(pirGames) && msg.sender != address (pirateNFT)) {
                require(
                    pirateNFT.isOwner(tokenIds[i]) == msg.sender,
                    "Not Pirate Owner"
                );
                pirateNFT.transferFrom(msg.sender, address(this), tokenIds[i]);
            }
            _addPirateToCrew(account, tokenIds[i]);
        }
    }

    function _addPirateToCrew(address account, uint256 tokenId)
        internal
        whenNotPaused
    {

        uint8 rank = _rankForPirate(tokenId);
        totalRankStaked += rank; // Portion of earnings ranges from 8 to 5
        crewIndices[tokenId] = crew[rank].length; // Store the location of the Pirate in the Crew
        crew[rank].push(
            Stake({
                sOwner: account,
                tokenId: uint16(tokenId),
                value: uint80(rawEonPerRank)
            })
        ); // Add the Pirate to the Crew
        piratesStaked += 1;
        emit PirateStaked(account, tokenId, rawEonPerRank);
    }



    function claimPiratesFromCrew(
        address account,
        uint16[] calldata tokenIds,
        bool unstake
    ) external whenNotPaused noCheaters {

        uint256 owed = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            owed += _claimPiratesFromCrew(account, tokenIds[i], unstake);
        }
        raw.updateOriginAccess(account);
        if (owed == 0) {
            return;
        }
        raw.mint(1, owed, account);
    }

    function calculateRewards(uint256 tokenId)
        external
        view
        returns (uint256 owed)
    {

        Stake memory stake = orbital[tokenId];
        uint8 rank = _rankForPirate(tokenId);
        owed = (rank) * (rawEonPerRank - stake.value); // Calculate portion of tokens based on Rank
    }

    function _claimPiratesFromCrew(
        address account,
        uint256 tokenId,
        bool unstake
    ) internal returns (uint256 owed) {

        uint8 rank = _rankForPirate(tokenId);
        Stake memory stake = crew[rank][crewIndices[tokenId]];
        require(stake.sOwner == account, "Not pirate Owner");
        owed = (rank) * (rawEonPerRank - stake.value); // Calculate portion of tokens based on Rank
        if (unstake) {
            totalRankStaked -= rank; // Remove rank from total staked
            piratesStaked -= 1;
            Stake memory lastStake = crew[rank][crew[rank].length - 1];
            crew[rank][crewIndices[tokenId]] = lastStake; // Shuffle last Pirate to current position
            crewIndices[lastStake.tokenId] = crewIndices[tokenId];
            crew[rank].pop(); // Remove duplicate
            delete crewIndices[tokenId]; // Delete old mapping
            pirateNFT.safeTransferFrom(address(this), account, tokenId, ""); // Send back Pirate
        } else {
            crew[rank][crewIndices[tokenId]] = Stake({
                sOwner: account,
                tokenId: uint16(tokenId),
                value: uint80(rawEonPerRank)
            }); // reset stake
        }
        emit PirateClaimed(tokenId, unstake, owed);
    }


    function rescue(uint256[] calldata tokenIds) external noCheaters {

        require(rescueEnabled, "Rescue Not Enabled");
        uint256 tokenId;
        Stake memory stake;
        Stake memory lastStake;
        uint8 rank;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            rank = _rankForPirate(tokenId);
            stake = crew[rank][crewIndices[tokenId]];
            require(stake.sOwner == msg.sender, "Not Owner");
            totalRankStaked -= rank; // Remove Rank from total staked
            lastStake = crew[rank][crew[rank].length - 1];
            crew[rank][crewIndices[tokenId]] = lastStake; // Shuffle last Pirate to current position
            crewIndices[lastStake.tokenId] = crewIndices[tokenId];
            crew[rank].pop(); // Remove duplicate
            delete crewIndices[tokenId]; // Delete old mapping
            pirateNFT.safeTransferFrom(address(this), msg.sender, tokenId, ""); // Send back Pirate
            emit PirateClaimed(tokenId, true, 0);
        }
    }

    function payPirateTax(uint256 amount) external override {

        require(admins[msg.sender], "Only admins");
        if (totalRankStaked == 0) {
            unaccountedRewards += amount; // keep track of $rEON due to pirates
            return;
        }
        rawEonPerRank += (amount + unaccountedRewards) / totalRankStaked;
        unaccountedRewards = 0;
    }

    function setRescueEnabled(bool _enabled) external onlyOwner {

        rescueEnabled = _enabled;
    }

    function setPaused(bool _paused) external requireContractsSet onlyOwner {

        if (_paused) _pause();
        else _unpause();
    }

    function addAdmin(address addr) external onlyOwner {

        admins[addr] = true;
    }

    function removeAdmin(address addr) external onlyOwner {

        admins[addr] = false;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        auth = newOwner;
    }

    function _rankForPirate(uint256 tokenId) internal view returns (uint8) {

        if (pirateNFT.isHonors(tokenId)) {
            return 8;
        } else {
            IPirates.Pirate memory q = pirateNFT.getTokenTraitsPirate(tokenId);
            return MAX_RANK - q.rank; // rank index is 0-3
        }
    }

    function randomPirateOwner(uint256 seed)
        external
        view
        override
        returns (address)
    {

        if (totalRankStaked == 0) {
            return address(0x0);
        }
        uint256 bucket = (seed & 0xFFFFFFFF) % totalRankStaked; // choose a value from 0 to total rank staked
        uint256 cumulative;
        seed >>= 32;
        for (uint256 i = MAX_RANK - 3; i <= MAX_RANK; i++) {
            cumulative += crew[i].length * i;
            if (bucket >= cumulative) continue;
            return crew[i][seed % crew[i].length].sOwner;
        }
        return address(0x0);
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        require(from == address(0x0), "Only EOA");
        return IERC721TokenReceiver.onERC721Received.selector;
    }
}