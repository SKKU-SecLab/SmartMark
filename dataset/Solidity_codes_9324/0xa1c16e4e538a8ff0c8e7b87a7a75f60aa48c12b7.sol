
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;


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

}pragma solidity ^0.8.0;




interface IERC20 {

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

contract Game is Ownable, IERC721Receiver, IERC1155Receiver, ReentrancyGuard {

    address payable public daves =
        payable(address(0x4B5922ABf25858d012d12bb1184e5d3d0B6D6BE4));
    address payable public dao =
        payable(address(0x6fBa46974b2b1bEfefA034e236A32e1f10C5A148));

    using EnumerableSet for EnumerableSet.UintSet;
    mapping(address => EnumerableSet.UintSet) private _player;

    uint256 public playerId = 1;
    uint256 public playersAlive = 0;

    bool public gameEnded;

    mapping(uint256 => uint256) public timeWenDed; //time player is going to die
    mapping(uint256 => uint256) public timeWenBorn; //time player is going to die

    mapping(uint256 => uint256) public attackTodDecrease; //time to decrease from current tod
    mapping(uint256 => uint256) public attackPrice;
    mapping(uint256 => uint256) public attackGives;

    mapping(address => uint256) public tokensToClaim; //keep track of how many tokens a user can claim to save gas
    mapping(address => uint256) public lastTimeClaimed; //when was last claimed

    uint256 public longestLiving;
    uint256 public longestLivingId;
    address public longestLivingOwner;

    uint256 public tokenBurnt;
    uint256 public timeStarted;

    IERC20 public TOKEN;
    IERC20 public MUSE;

    struct Player {
        address nft;
        uint256 nftId;
        address owner;
        bool isErc1155;
    }

    mapping(uint256 => Player) players;

    event ClaimedRewards(address who, uint256 amount);
    event NewPlayer(address who, uint256 id);
    event Kill(address killer, uint256 opponentId);
    event Attak(address who, uint256 opponentId, uint256 attackId);
    event BuyPowerUp(uint256 to, uint256 amount);

    constructor(address _token, address _muse) {
        TOKEN = IERC20(_token);
        MUSE = IERC20(_muse);
        gameEnded = false;
        timeStarted = block.timestamp;
    }

    modifier isOwner(uint256 _playerId) {

        Player memory player = players[_playerId];
        require(player.owner == msg.sender, "!forbidden");
        _;
    }

    function balanceOf(address _owner) public view returns (uint256) {

        return _player[_owner].length();
    }

    function playersOfAddressByIndex(address _owner, uint256 index)
        public
        view
        returns (uint256)
    {

        return _player[_owner].at(index);
    }

    function timeUntilDeath(uint256 _playerId) public view returns (uint256) {

        if (block.timestamp >= timeWenDed[_playerId]) {
            return 0;
        } else {
            return timeWenDed[_playerId] - block.timestamp;
        }
    }

    function getScore(uint256 _id) public view returns (uint256) {

        return block.timestamp - timeWenBorn[_id];
    }

    function getEarnings(address _user) public view returns (uint256) {

        uint256 amount = tokensToClaim[_user];

        uint256 amtOfPets = balanceOf(_user);

        uint256 sinceLastTimeClaimed =
            ((block.timestamp - lastTimeClaimed[_user]) / 1 minutes) *
                4791666666666667 * // 0,2875 tokens per hour. 6.9 tokens per day.
                amtOfPets;

        return amount + sinceLastTimeClaimed;
    }

    function isAlive(uint256 _playerId) public view returns (bool) {

        return timeUntilDeath(_playerId) > 0;
    }

    function getInfo(uint256 _id)
        public
        view
        returns (
            uint256 _playerId,
            bool _isAlive,
            uint256 _score,
            uint256 _expectedReward,
            uint256 _timeUntilDeath,
            uint256 _timeBorn,
            address _owner,
            address _nftOrigin,
            uint256 _nftId,
            uint256 _timeOfDeath
        )
    {

        Player memory player = players[_id];

        _playerId = _id;
        _isAlive = isAlive(_id);
        _score = getScore(_id);
        _expectedReward = getEarnings(player.owner);
        _timeUntilDeath = timeUntilDeath(_id);
        _timeBorn = timeWenBorn[_id];
        _owner = player.owner;
        _nftOrigin = player.nft;
        _nftId = player.nftId;
        _timeOfDeath = timeWenDed[_id];
    }

    function getAmountOfTOD(uint256 _tokenAmount)
        public
        view
        returns (uint256)
    {

        uint256 price_per_token =
            (10000000000) / sqrt(((tokenBurnt / (10**12)) + 800000000) / 200);
        uint256 result = (_tokenAmount * price_per_token);
        result = ((result * 1 hours) / 10**24);
        return result;
    }

    function register(
        address _nft,
        uint256 _nftId,
        bool _is1155
    ) external nonReentrant {

        require(!gameEnded, "ended");
        claimTokens(); //we claim any owned tokens before
        if (!_is1155) {
            IERC721(_nft).safeTransferFrom(msg.sender, address(this), _nftId);
        } else {
            IERC1155(_nft).safeTransferFrom(
                msg.sender,
                address(this),
                _nftId,
                1,
                "0x0"
            );
        }
        Player storage player = players[playerId];
        player.nft = _nft;
        player.owner = msg.sender;
        player.nftId = _nftId;
        player.isErc1155 = _is1155;
        _player[msg.sender].add(playerId);
        timeWenDed[playerId] = block.timestamp + 3 days;
        timeWenBorn[playerId] = block.timestamp;
        TOKEN.burnFrom(msg.sender, 90 * 1 ether); //burn 40 royal to join and get 3 days.

        emit NewPlayer(msg.sender, playerId);

        playersAlive++;
        playerId++;
    }

    function buyPowerUp(uint256 _id, uint256 _amount) public {

        require(isAlive(_id), "!alive");
        require(_amount >= 1 * 10**17); //min 0.1 token

        TOKEN.burnFrom(msg.sender, _amount);
        timeWenDed[_id] += getAmountOfTOD(_amount);
        tokenBurnt += _amount;

        emit BuyPowerUp(_id, _amount);
    }

    function attackPlayer(uint256 _opponent, uint256 _attackId)
        external
        payable
    {

        require(isAlive(_opponent), "!alive");
        require(msg.value >= attackPrice[_attackId], "!money");

        require(balanceOf(msg.sender) >= 1 || playersAlive == 1, "!pets");

        uint256 timeToDecrease = attackTodDecrease[_attackId];

        require(timeUntilDeath(_opponent) > timeToDecrease + 6 hours, "!kill");

        tokensToClaim[msg.sender] += attackGives[_attackId];

        timeWenDed[_opponent] -= timeToDecrease;

        emit Attak(msg.sender, _opponent, _attackId);
    }

    function claimTokens() public {

        if (lastTimeClaimed[msg.sender] == 0) {
            lastTimeClaimed[msg.sender] = block.timestamp;
        }

        uint256 amount = getEarnings(msg.sender);
        tokensToClaim[msg.sender] = 0;
        lastTimeClaimed[msg.sender] = block.timestamp;

        if (amount > 0) TOKEN.mint(msg.sender, amount);

        emit ClaimedRewards(msg.sender, amount);
    }

    function kill(uint256 _opponentId) public nonReentrant {

        require(balanceOf(msg.sender) >= 1 || playersAlive <= 5, "!pets");

        require(!isAlive(_opponentId), "alive");
        Player memory oppoonent = players[_opponentId];
        emit Kill(msg.sender, _opponentId);

        if (!oppoonent.isErc1155) {
            IERC721(oppoonent.nft).safeTransferFrom(
                address(this),
                oppoonent.owner,
                oppoonent.nftId
            );
        } else {
            IERC1155(oppoonent.nft).safeTransferFrom(
                address(this),
                oppoonent.owner,
                oppoonent.nftId,
                1,
                "0x0"
            );
        }

        uint256 timeLived = block.timestamp - timeWenBorn[_opponentId];

        if (timeLived > longestLiving) {
            longestLiving = timeLived;
            longestLivingId = _opponentId;
            longestLivingOwner = oppoonent.owner;
        }
        _player[oppoonent.owner].remove(_opponentId);
        delete players[_opponentId]; //we remove the player struct

        TOKEN.mint(msg.sender, 50 * 10**18);
        playersAlive--;
    }

    function rugPull() public {

        require(
            TOKEN.balanceOf(msg.sender) >= (TOKEN.totalSupply() * 69) / 100 &&
                TOKEN.totalSupply() > 100000 * 10**18 &&
                playersAlive >= 15,
            "Can't rugpull"
        );
        address payable playerAddress = payable(msg.sender);

        uint256 ethbal = address(this).balance;
        uint256 distribution = (ethbal * 10) / 100;

        if (MUSE.balanceOf(address(this)) > 0) {
            MUSE.transferFrom(
                address(this),
                msg.sender,
                MUSE.balanceOf(address(this))
            );
        }

        daves.transfer(distribution); //10% for daves
        dao.transfer(distribution); //10% for dao
        playerAddress.transfer(address(this).balance); //don't kill ocntract because players still need to withdraw nfts
    }

    function claimPrize() public {

        require(playersAlive == 0, "game is not finished"); //when no pets the game can end.

        gameEnded = true;

        address payable playerAddress = payable(longestLivingOwner);

        uint256 ethbal = address(this).balance;
        uint256 distribution = (ethbal * 10) / 100;

        if (MUSE.balanceOf(address(this)) > 0) {
            MUSE.transferFrom(
                address(this),
                longestLivingOwner,
                MUSE.balanceOf(address(this))
            );
        }

        daves.transfer(distribution); //10% for daves
        dao.transfer(distribution); //10% for dao
        selfdestruct(playerAddress); // kill contract and send all remaining balance to winner
    }

    function startGame(bool start) external onlyOwner {

        gameEnded = start;
        timeStarted = block.timestamp;
    }

    function addAttack(
        uint256 _id,
        uint256 _attack,
        uint256 _price,
        uint256 _tokensToGive
    ) external onlyOwner {

        attackTodDecrease[_id] = _attack;
        attackPrice[_id] = _price;
        attackGives[_id] = _tokensToGive;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {

        return (true);
    }
}