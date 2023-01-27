
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

interface IShatteredEON {}// MIT LICENSE

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


}// MIT LICENSE

pragma solidity ^0.8.0;

interface IRandomizer {

    function random(uint256) external returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


contract Pytheas is IPytheas, IERC721TokenReceiver, Pausable {

    struct Stake {
        uint16 tokenId;
        uint80 value;
        address sOwner;
    }

    event ColonistStaked(
        address indexed sOwner,
        uint256 indexed tokenId,
        uint256 value
    );
    event ColonistClaimed(
        uint256 indexed tokenId,
        bool indexed unstaked,
        uint256 earned
    );

    event Metamorphosis(address indexed addr, uint256 indexed tokenId);

    IColonist public colonistNFT;
    IShatteredEON public shattered;
    IMasterStaker public masterStaker;
    IOrbitalBlockade public orbital;
    IRAW public raw;
    IRandomizer public randomizer;

    mapping(uint256 => Stake) private pytheas;

    mapping(address => bool) private admins;

    uint256 public constant DAILY_rEON_RATE = 2700;
    uint256 public constant MINIMUM_TO_EXIT = 2 days;
    uint256 public constant rEON_CLAIM_TAX_PERCENTAGE = 20;
    uint256 public constant MAXIMUM_GLOBAL_rEON = 3125000000;
    uint256 public numColonistStaked;
    uint256 public totalRawEonEarned;
    uint256 private lastClaimTimestamp;
    address public auth;

    bool public rescueEnabled;

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
            address(colonistNFT) != address(0) &&
                address(raw) != address(0) &&
                address(orbital) != address(0) &&
                address(shattered) != address(0) &&
                address(masterStaker) != address(0) &&
                address(randomizer) != address(0),
            "Contracts not set"
        );
        _;
    }

    function setContracts(
        address _colonistNFT,
        address _raw,
        address _orbital,
        address _shattered,
        address _masterStaker,
        address _rand
    ) external onlyOwner {

        colonistNFT = IColonist(_colonistNFT);
        raw = IRAW(_raw);
        orbital = IOrbitalBlockade(_orbital);
        shattered = IShatteredEON(_shattered);
        masterStaker = IMasterStaker(_masterStaker);
        randomizer = IRandomizer(_rand);
    }


    function addColonistToPytheas(address account, uint16[] calldata tokenIds)
        external
        override
        whenNotPaused
        noCheaters
    {

        require(account == tx.origin);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (msg.sender == address(masterStaker)) {
                require(
                    colonistNFT.isOwner(tokenIds[i]) == account,
                    "Not Colonist Owner"
                );
                colonistNFT.transferFrom(account, address(this), tokenIds[i]);
            } else if (msg.sender != address(shattered)) {
                require(
                    colonistNFT.isOwner(tokenIds[i]) == msg.sender,
                    "Not Colonist Owner"
                );
                colonistNFT.transferFrom(
                    msg.sender,
                    address(this),
                    tokenIds[i]
                );
            } else if (tokenIds[i] == 0) {
                continue; // there may be gaps in the array for stolen tokens
            }
            _addColonistToPytheas(account, tokenIds[i]);
        }
    }

    function _addColonistToPytheas(address account, uint256 tokenId)
        internal
        _updateEarnings
    {

        pytheas[tokenId] = Stake({
            sOwner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        });
        numColonistStaked += 1;
        emit ColonistStaked(account, tokenId, block.timestamp);
    }


    function claimColonistFromPytheas(
        address account,
        uint16[] calldata tokenIds,
        bool unstake
    ) external whenNotPaused _updateEarnings noCheaters {

        uint256 owed = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            owed += _claimColonistFromPytheas(account, tokenIds[i], unstake);
        }
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

        Stake memory stake = pytheas[tokenId];
        if (totalRawEonEarned < MAXIMUM_GLOBAL_rEON) {
            owed = ((block.timestamp - stake.value) * DAILY_rEON_RATE) / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0; // $rEON production stopped already
        } else {
            owed =
                ((lastClaimTimestamp - stake.value) * DAILY_rEON_RATE) /
                1 days; // stop earning additional $rEON if it's all been earned
        }
    }

    function _claimColonistFromPytheas(
        address account,
        uint256 tokenId,
        bool unstake
    ) internal returns (uint256 owed) {

        Stake memory stake = pytheas[tokenId];
        require(stake.sOwner == account, "Not Owner");
        require(
            !(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT),
            "Your shift isn't over!"
        );
        if (totalRawEonEarned < MAXIMUM_GLOBAL_rEON) {
            owed = ((block.timestamp - stake.value) * DAILY_rEON_RATE) / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0; // $rEON production stopped already
        } else {
            owed =
                ((lastClaimTimestamp - stake.value) * DAILY_rEON_RATE) /
                1 days; // stop earning additional $rEON if it's all been earned
        }
        if (unstake) {
            if (randomizer.random(tokenId) & 1 == 1) {
                orbital.payPirateTax(owed);
                owed = 0;
            }
            delete pytheas[tokenId];
            numColonistStaked -= 1;
            colonistNFT.safeTransferFrom(address(this), account, tokenId, ""); // send back colonist
        } else {
            orbital.payPirateTax((owed * rEON_CLAIM_TAX_PERCENTAGE) / 100); // percentage tax to staked pirates
            owed = (owed * (100 - rEON_CLAIM_TAX_PERCENTAGE)) / 100; // remainder goes to Colonist sOwner
            pytheas[tokenId] = Stake({
                sOwner: account,
                tokenId: uint16(tokenId),
                value: uint80(block.timestamp)
            }); // reset stake
        }
        emit ColonistClaimed(tokenId, unstake, owed);
    }

    function handleJoinPirates(address addr, uint16 tokenId)
        external
        override
        noCheaters
    {

        require(admins[msg.sender]);
        Stake memory stake = pytheas[tokenId];
        require(stake.sOwner == addr, "Pytheas: Not Owner");
        delete pytheas[tokenId];
        colonistNFT.burn(tokenId);

        emit Metamorphosis(addr, tokenId);
    }

    function payUp(
        uint16 tokenId,
        uint256 amtMined,
        address addr
    ) external override _updateEarnings {

        require(admins[msg.sender]);
        uint256 minusTax = 0;
        minusTax += _piratesLife(tokenId, amtMined, addr);
        if (minusTax == 0) {
            return;
        }
        raw.mint(1, minusTax, addr);
    }

    function getColonistMined(address account, uint16 tokenId)
        external
        view
        override
        returns (uint256 minedAmt)
    {

        require(admins[msg.sender]);
        uint256 mined = 0;
        mined += colonistDues(account, tokenId);
        return mined;
    }

    function colonistDues(address addr, uint16 tokenId)
        internal
        view
        returns (uint256 mined)
    {

        Stake memory stake = pytheas[tokenId];
        require(stake.sOwner == addr, "Not Owner");
        if (totalRawEonEarned < MAXIMUM_GLOBAL_rEON) {
            mined =
                ((block.timestamp - stake.value) * DAILY_rEON_RATE) /
                1 days;
        } else if (stake.value > lastClaimTimestamp) {
            mined = 0; // $rEON production stopped already
        } else {
            mined =
                ((lastClaimTimestamp - stake.value) * DAILY_rEON_RATE) /
                1 days; // stop earning additional $rEON if it's all been earned
        }
    }

    function _piratesLife(
        uint16 tokenId,
        uint256 amtMined,
        address addr
    ) internal returns (uint256 owed) {

        Stake memory stake = pytheas[tokenId];
        require(stake.sOwner == addr, "Pytheas: Not Owner");
        uint256 pirateTax = (amtMined * rEON_CLAIM_TAX_PERCENTAGE) / 100;
        orbital.payPirateTax(pirateTax);
        owed = (amtMined - pirateTax);
        pytheas[tokenId] = Stake({
            sOwner: addr,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        });
        emit ColonistClaimed(tokenId, false, owed);
    }

    function rescue(uint256[] calldata tokenIds) external noCheaters {

        require(rescueEnabled, "Rescue Not Enabled");
        uint256 tokenId;
        Stake memory stake;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            stake = pytheas[tokenId];
            require(stake.sOwner == msg.sender, "Not Owner");
            delete pytheas[tokenId];
            numColonistStaked -= 1;
            colonistNFT.safeTransferFrom(
                address(this),
                msg.sender,
                tokenId,
                ""
            ); // send back Colonist
            emit ColonistClaimed(tokenId, true, 0);
        }
    }


    modifier _updateEarnings() {

        if (totalRawEonEarned < MAXIMUM_GLOBAL_rEON) {
            totalRawEonEarned +=
                ((block.timestamp - lastClaimTimestamp) *
                    numColonistStaked *
                    DAILY_rEON_RATE) /
                1 days;
            lastClaimTimestamp = block.timestamp;
        }
        _;
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