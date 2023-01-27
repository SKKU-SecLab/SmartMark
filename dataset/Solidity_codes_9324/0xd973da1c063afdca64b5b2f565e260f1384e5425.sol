
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

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

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal initializer {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal initializer {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}//UNLICENSED

pragma solidity ^0.8.0;



interface IToken {

    function totalSupply() external view returns (uint256);


    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);


    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);


    function transfer(address to, uint256 tokens)
        external
        returns (bool success);


    function approve(address spender, uint256 tokens)
        external
        returns (bool success);


    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}

contract CudlFinanceV5 is
    Initializable,
    ERC721HolderUpgradeable,
    OwnableUpgradeable
{

    address public mooncats;
    address public PONDERWARE;
    address public MUSE_DAO;
    address public MUSE_DEVS;

    uint256 public gas; // if gas higher then this you can't kill
    uint256 public lastGas; //here we record last gas paid, to keep track of chain gas. If gas is high, no pets can die.

    IToken public token;

    struct Pet {
        address nft;
        uint256 id;
    }

    mapping(address => bool) public supportedNfts;
    mapping(uint256 => Pet) public petDetails;

    mapping(uint256 => uint256) public lastTimeMined;

    mapping(uint256 => uint256) public timeUntilStarving;
    mapping(uint256 => uint256) public petScore;
    mapping(uint256 => bool) public petDead;
    mapping(uint256 => uint256) public timePetBorn;

    mapping(uint256 => uint256) public itemPrice;
    mapping(uint256 => uint256) public itemPoints;
    mapping(uint256 => string) public itemName;
    mapping(uint256 => uint256) public itemTimeExtension;

    mapping(uint256 => mapping(address => address)) public careTaker;

    mapping(address => mapping(uint256 => bool)) public isNftInTheGame; //keeps track if nft already played
    mapping(address => mapping(uint256 => uint256)) public nftToId; //keeps track if nft already played

    uint256 public feesEarned;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;
    CountersUpgradeable.Counter private _itemIds;

    event Mined(uint256 nftId, uint256 reward, address recipient);
    event BuyAccessory(
        uint256 nftId,
        uint256 itemId,
        uint256 amount,
        uint256 itemTimeExtension,
        address buyer
    );
    event Fatalize(uint256 opponentId, uint256 nftId, address killer);
    event NewPlayer(
        address nftAddress,
        uint256 nftId,
        uint256 playerId,
        address owner
    );
    event Bonk(
        uint256 attacker,
        uint256 victim,
        uint256 winner,
        uint256 reward
    );


    uint256 public la;
    uint256 public lb;
    uint256 public ra;
    uint256 public rb;

    address public lastBonker;


    mapping(uint256 => uint256) public spent;
    mapping(address => uint256) public balance;
    mapping(address => bool) public isOperator;

    constructor() {}

    modifier isAllowed(uint256 _id) {

        Pet memory _pet = petDetails[_id];
        address ownerOf = IERC721Upgradeable(_pet.nft).ownerOf(_pet.id);
        require(
            ownerOf == msg.sender || careTaker[_id][ownerOf] == msg.sender,
            "!owner"
        );
        _;
    }

    modifier onlyOperator() {

        require(
            isOperator[msg.sender],
            "Roles: caller does not have the OPERATOR role"
        );
        _;
    }


    function depositCudl(uint256 amount) external {

        balance[msg.sender] += amount;
        token.burnFrom(msg.sender, amount);
    }

    function claimRewards(uint256[] memory petIds) public onlyOwner {

        lastGas = tx.gasprice;
        uint256 amount;
        for (uint256 i = 0; i < petIds.length; i++) {
            require(isPetOwner(petIds[i], msg.sender), "!owner");
            require(
                isPetSafe(petIds[i]),
                "Your pet is starving, you can't mine"
            );

            uint256 earning = getEarnings(petIds[i]);

            if (earning > 0) {
                if (lastTimeMined[petIds[i]] == 0) {
                    lastTimeMined[petIds[i]] = block.timestamp;
                }

                amount += earning;

                lastTimeMined[petIds[i]] = block.timestamp;
                emit Mined(petIds[i], earning, msg.sender);
            }
        }

        amount += balance[msg.sender];
        balance[msg.sender] = 0;

        if (amount > 0) token.mint(msg.sender, amount);
    }

    function buyAccesory(uint256 nftId, uint256 itemId)
        public
        isAllowed(nftId)
    {

        require(!petDead[nftId], "ded pet");

        uint256 amount = itemPrice[itemId];
        require(amount > 0, "item does not exist");

        timeUntilStarving[nftId] = block.timestamp + itemTimeExtension[itemId];
        petScore[nftId] += itemPoints[itemId];

        if (getEarnings(nftId) >= amount) {
            spent[nftId] += amount;
        } else if (balance[msg.sender] >= amount) {
            balance[msg.sender] -= amount;
        } else {
            revert("bal");
        }

        feesEarned += amount / 10;

        emit BuyAccessory(
            nftId,
            itemId,
            amount,
            itemTimeExtension[itemId],
            msg.sender
        );
    }

    function feedMultiple(uint256[] calldata ids, uint256[] calldata itemIds)
        external
    {

        for (uint256 i = 0; i < ids.length; i++) {
            buyAccesory(ids[i], itemIds[i]);
        }
    }

    function fatality(uint256 _deadId, uint256 _tokenId) external {

        require(
            !isPetSafe(_deadId) &&
                tx.gasprice <= gas && //inspired by NFT GAS by 0Xmons
                petDead[_deadId] == false,
            "The PET has to be starved or gas below ${gas} to claim his points"
        );

        petScore[_tokenId] =
            petScore[_tokenId] +
            (((petScore[_deadId] * (20)) / (100)));

        petScore[_deadId] = 0;

        petDead[_deadId] = true;
        emit Fatalize(_deadId, _tokenId, msg.sender);
    }

    function getCareTaker(uint256 _tokenId, address _owner)
        public
        view
        returns (address)
    {

        return (careTaker[_tokenId][_owner]);
    }

    function setCareTaker(
        uint256 _tokenId,
        address _careTaker,
        bool clearCareTaker
    ) external isAllowed(_tokenId) {

        if (clearCareTaker) {
            delete careTaker[_tokenId][msg.sender];
        } else {
            careTaker[_tokenId][msg.sender] = _careTaker;
        }
    }

    function giveLife(address nft, uint256 _id) external {

        require(IERC721Upgradeable(nft).ownerOf(_id) == msg.sender, "!OWNER");
        require(
            !isNftInTheGame[nft][_id],
            "this nft was already registered can't again"
        );
        require(supportedNfts[nft], "!forbidden");

        token.burnFrom(msg.sender, 100 * 1 ether);

        uint256 newId = _tokenIds.current();
        petDetails[newId] = Pet(nft, _id);

        nftToId[nft][_id] = newId;

        isNftInTheGame[nft][_id] = true;

        timeUntilStarving[newId] = block.timestamp + 3 days; //start with 3 days of life.
        timePetBorn[newId] = block.timestamp;

        lastTimeMined[newId] = block.timestamp - 1 days;

        emit NewPlayer(nft, _id, newId, msg.sender);

        _tokenIds.increment();
    }


    function burnScore(uint256 petId, uint256 amount) external onlyOperator {

        require(!petDead[petId]);

        petScore[petId] -= amount;
    }

    function addScore(uint256 petId, uint256 amount) external onlyOperator {

        require(!petDead[petId]);
        petScore[petId] += amount;
    }

    function spend(uint256 petId, uint256 amount) external onlyOperator {

        spent[petId] -= amount;
    }

    function gibCudl(uint256 petId, uint256 amount) external onlyOperator {

        spent[petId] += amount;
    }

    function addTOD(uint256 petId, uint256 duration) external onlyOperator {

        require(!petDead[petId]);
        timeUntilStarving[petId] = block.timestamp + duration;
    }

    function isPetOwner(uint256 petId, address user)
        public
        view
        returns (bool)
    {

        Pet memory _pet = petDetails[petId];
        address ownerOf = IERC721Upgradeable(_pet.nft).ownerOf(_pet.id);
        return (ownerOf == user || careTaker[petId][ownerOf] == user);
    }


    function getEarnings(uint256 petId) public view returns (uint256) {

        uint256 amount = (((block.timestamp - lastTimeMined[petId]) / 1 days) *
            getRewards(petId));

        if (amount <= spent[petId]) {
            return 0;
        } else {
            return amount - spent[petId];
        }
    }

    function getPendingBalance(uint256[] memory petIds, address user)
        public
        view
        returns (uint256)
    {

        uint256 total;
        for (uint256 i = 0; i < petIds.length; i++) {
            total += getEarnings(petIds[i]);
        }

        return total + balance[user];
    }

    function isPetSafe(uint256 _nftId) public view returns (bool) {

        uint256 _timeUntilStarving = timeUntilStarving[_nftId];
        if (
            (_timeUntilStarving != 0 &&
                _timeUntilStarving >= block.timestamp) || lastGas >= gas
        ) {
            return true;
        } else {
            return false;
        }
    }

    function getPetInfo(uint256 _nftId)
        public
        view
        returns (
            uint256 _pet,
            bool _isStarving,
            uint256 _score,
            uint256 _level,
            uint256 _expectedReward,
            uint256 _timeUntilStarving,
            uint256 _lastTimeMined,
            uint256 _timepetBorn,
            address _owner,
            address _token,
            uint256 _tokenId,
            bool _isAlive
        )
    {

        Pet memory thisPet = petDetails[_nftId];

        _pet = _nftId;
        _isStarving = !this.isPetSafe(_nftId);
        _score = petScore[_nftId];
        _level = level(_nftId);
        _expectedReward = getRewards(_nftId);
        _timeUntilStarving = timeUntilStarving[_nftId];
        _lastTimeMined = lastTimeMined[_nftId];
        _timepetBorn = timePetBorn[_nftId];
        _owner = IERC721Upgradeable(thisPet.nft).ownerOf(thisPet.id);
        _token = petDetails[_nftId].nft;
        _tokenId = petDetails[_nftId].id;
        _isAlive = !petDead[_nftId];
    }

    function getRewards(uint256 tokenId) public view returns (uint256) {

        uint256 _level = level(tokenId);
        if (_level == 1) {
            return 6 ether;
        }
        _level = (_level * 1 ether * ra) / rb;
        return (_level + 5 ether);
    }

    function level(uint256 tokenId) public view returns (uint256) {

        uint256 _score = petScore[tokenId] / 100;
        if (_score == 0) {
            return 1;
        }
        uint256 _level = sqrtu(_score * la);
        return (_level * lb);
    }


    function editCurves(
        uint256 _la,
        uint256 _lb,
        uint256 _ra,
        uint256 _rb
    ) external onlyOwner {

        la = _la;
        lb = _lb;
        ra = _ra;
        rb = _rb;
    }

    function editItem(
        uint256 _id,
        uint256 _price,
        uint256 _points,
        string calldata _name,
        uint256 _timeExtension
    ) external onlyOwner {

        itemPrice[_id] = _price;
        itemPoints[_id] = _points;
        itemName[_id] = _name;
        itemTimeExtension[_id] = _timeExtension;
    }

    function setSupported(address _nft, bool isSupported) public onlyOwner {

        supportedNfts[_nft] = isSupported;
    }

    function setGas(uint256 _gas) public onlyOwner {

        gas = _gas;
    }

    function addOperator(address _address, bool _isAllowed) public onlyOwner {

        isOperator[_address] = _isAllowed;
    }

    function createItem(
        string calldata name,
        uint256 price,
        uint256 points,
        uint256 timeExtension
    ) external onlyOwner {

        _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        itemName[newItemId] = name;
        itemPrice[newItemId] = price;
        itemPoints[newItemId] = points;
        itemTimeExtension[newItemId] = timeExtension;
    }

    function changeEarners(address _newAddress) public {

        require(
            msg.sender == MUSE_DEVS || msg.sender == PONDERWARE,
            "!forbidden"
        );
        if (msg.sender == MUSE_DEVS) {
            MUSE_DEVS = _newAddress;
        } else if (msg.sender == PONDERWARE) {
            PONDERWARE = _newAddress;
        }
    }

    function claimEarnings() public {

        token.mint(address(this), feesEarned);
        feesEarned = 0;

        uint256 bal = token.balanceOf(address(this));
        token.transfer(PONDERWARE, bal / 3);
        token.transfer(MUSE_DAO, bal / 3);
        token.transfer(MUSE_DEVS, bal / 3);
    }

    function randomNumber(uint256 seed, uint256 max)
        public
        view
        returns (uint256 _randomNumber)
    {

        uint256 n = 0;
        unchecked {
            for (uint256 i = 0; i < 5; i++) {
                n += uint256(
                    keccak256(
                        abi.encodePacked(blockhash(block.number - i - 1), seed)
                    )
                );
            }
        }
        return (n) % max;
    }

    function sqrtu(uint256 x) private pure returns (uint128) {

        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) {
                xx >>= 128;
                r <<= 64;
            }
            if (xx >= 0x10000000000000000) {
                xx >>= 64;
                r <<= 32;
            }
            if (xx >= 0x100000000) {
                xx >>= 32;
                r <<= 16;
            }
            if (xx >= 0x10000) {
                xx >>= 16;
                r <<= 8;
            }
            if (xx >= 0x100) {
                xx >>= 8;
                r <<= 4;
            }
            if (xx >= 0x10) {
                xx >>= 4;
                r <<= 2;
            }
            if (xx >= 0x8) {
                r <<= 1;
            }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint128(r < r1 ? r : r1);
        }
    }
}