
pragma solidity 0.4.25;


contract Ownable {

    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != owner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library NameFilter {

    function nameFilter(string _input)
    internal
    pure
    returns(bytes32)
    {

        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");

        bool _hasNonNumber;

        for (uint256 i = 0; i < _length; i++)
        {
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                _temp[i] = byte(uint(_temp[i]) + 32);

                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    _temp[i] == 0x20 ||
                (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

contract CelebrityGame is Ownable {

    using SafeMath for *;
    using NameFilter for string;

    string constant public gameName = "Celebrity Game";

    event LogNewCard(string name, uint256 id);
    event LogNewPlayer(string name, uint256 id);

    bool private isStart = false;
    uint256 private roundId = 0;

    struct Card {
        bytes32 name;           // card owner name
        uint256 fame;           // The number of times CARDS were liked
        uint256 fameValue;      // The charge for the current card to be liked once
        uint256 notorious;      // The number of times CARDS were disliked
        uint256 notoriousValue; // The charge for the current card to be disliked once
    }

    struct CardForPlayer {
        uint256 likeCount;      // The number of times the player likes it
        uint256 dislikeCount;   // The number of times the player disliked it
    }

    struct CardWinner {
        bytes32  likeWinner;
        bytes32  dislikeWinner;
    }

    Card[] public cards;
    bytes32[] public players;

    mapping (uint256 => mapping (uint256 => mapping ( uint256 => CardForPlayer))) public playerCard;      // returns cards of this player like or dislike by playerId and roundId and cardId
    mapping (uint256 => mapping (uint256 => CardWinner)) public cardWinnerMap; // (roundId => (cardId => winner)) returns winner by roundId and cardId
    mapping (uint256 => Card[]) public rounCardMap;                            // returns Card info by roundId

    mapping (bytes32 => uint256) private plyNameXId;                           // (playerName => Id) returns playerId by playerName
    mapping (bytes32 => uint256) private cardNameXId;                          // (cardName => Id) returns cardId by cardName
    mapping (bytes32 => bool) private cardIsReg;                               // (cardName => cardCount) returns cardCount by cardName，just for createCard function
    mapping (bytes32 => bool) private playerIsReg;                             // (playerName => isRegister) returns registerInfo by playerName, just for registerPlayer funciton
    mapping (uint256 => bool) private cardIdIsReg;                             // (cardId => card info) returns card info by cardId
    mapping (uint256 => bool) private playerIdIsReg;                           // (playerId => id) returns player index of players by playerId
    mapping (uint256 => uint256) private cardIdXSeq;
    mapping (uint256 => uint256) private playerIdXSeq;

    modifier isStartEnable {

        require(isStart == true);
        _;
    }
    constructor() public {
        string[8]  memory names= ["SatoshiNakamoto","CZ","HeYi","LiXiaolai","GuoHongcai","VitalikButerin","StarXu","ByteMaster"];
        uint256[8] memory _ids = [uint256(183946248739),536269148721,762415028463,432184367532,398234673241,264398721023,464325189620,217546321806];
        for (uint i = 0; i < 8; i++){
             string  memory _nameString = names[i];
             uint256 _id = _ids[i];
             bytes32 _name = _nameString.nameFilter();
             require(cardIsReg[_name] == false);
             uint256 _seq = cards.push(Card(_name, 1, 1000, 1, 1000)) - 1;
             cardIdXSeq[_id] = _seq;
             cardNameXId[_name] = _id;
             cardIsReg[_name] = true;
            cardIdIsReg[_id] = true;
        }

    }
    function createCard(string _nameString, uint256 _id) public onlyOwner() {

        require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked("")));

        bytes32 _name = _nameString.nameFilter();
        require(cardIsReg[_name] == false);
        uint256 _seq = cards.push(Card(_name, 1, 1000, 1, 1000)) - 1;
        cardIdXSeq[_id] = _seq;
        cardNameXId[_name] = _id;
        cardIsReg[_name] = true;
        cardIdIsReg[_id] = true;
        emit LogNewCard(_nameString, _id);
    }

    function registerPlayer(string _nameString, uint256 _id)  external {

        require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked("")));

        bytes32 _name = _nameString.nameFilter();
        require(playerIsReg[_name] == false);
        uint256 _seq = players.push(_name) - 1;
        playerIdXSeq[_id] = _seq;
        plyNameXId[_name] = _id;
        playerIsReg[_name] = true;
        playerIdIsReg[_id] = true;

        emit LogNewPlayer(_nameString, _id);
    }

    function likeCelebrity(uint256 _cardId, uint256 _playerId) external isStartEnable {

        require(cardIdIsReg[_cardId] == true, "sorry create this card first");
        require(playerIdIsReg[_playerId] == true, "sorry register the player name first");

        Card storage queryCard = cards[cardIdXSeq[_cardId]];
        queryCard.fame = queryCard.fame.add(1);
        queryCard.fameValue = queryCard.fameValue.add(queryCard.fameValue / 100*1000);

        playerCard[_playerId][roundId][_cardId].likeCount == (playerCard[_playerId][roundId][_cardId].likeCount).add(1);
        cardWinnerMap[roundId][_cardId].likeWinner = players[playerIdXSeq[_playerId]];
    }

    function dislikeCelebrity(uint256 _cardId, uint256 _playerId) external isStartEnable {

        require(cardIdIsReg[_cardId] == true, "sorry create this card first");
        require(playerIdIsReg[_playerId] == true, "sorry register the player name first");

        Card storage queryCard = cards[cardIdXSeq[_cardId]];
        queryCard.notorious = queryCard.notorious.add(1);
        queryCard.notoriousValue = queryCard.notoriousValue.add(queryCard.notoriousValue / 100*1000);

        playerCard[_playerId][roundId][_cardId].dislikeCount == (playerCard[_playerId][roundId][_cardId].dislikeCount).add(1);
        cardWinnerMap[roundId][_cardId].dislikeWinner = players[playerIdXSeq[_playerId]];
    }

    function reset(uint256 _id) external onlyOwner() {

        require(isStart == false);

        Card storage queryCard = cards[cardIdXSeq[_id]];
        queryCard.fame = 1;
        queryCard.fameValue = 1000;
        queryCard.notorious = 1;
        queryCard.notoriousValue = 1000;
    }

    function gameStart() external onlyOwner() {

        isStart = true;
        roundId = roundId.add(1);
    }

    function gameEnd() external onlyOwner() {

        isStart = false;
        rounCardMap[roundId] = cards;
    }

    function getCardsCount() public view returns(uint256) {

        return cards.length;
    }

    function getCardId(string _nameString) public view returns(uint256) {

        bytes32 _name = _nameString.nameFilter();
        require(cardIsReg[_name] == true, "sorry create this card first");
        return cardNameXId[_name];
    }

    function getPlayerId(string _nameString) public view returns(uint256) {

        bytes32 _name = _nameString.nameFilter();
        require(playerIsReg[_name] == true, "sorry register the player name first");
        return plyNameXId[_name];
    }

    function getPlayerBetCount(string _playerName, uint256 _roundId, string _cardName) public view returns(uint256 likeCount, uint256 dislikeCount) {

        bytes32 _cardNameByte = _cardName.nameFilter();
        require(cardIsReg[_cardNameByte] == false);

        bytes32 _playerNameByte = _playerName.nameFilter();
        require(playerIsReg[_playerNameByte] == false);
        return (playerCard[plyNameXId[_playerNameByte]][_roundId][cardNameXId[_cardNameByte]].likeCount, playerCard[plyNameXId[_playerNameByte]][_roundId][cardNameXId[_cardNameByte]].dislikeCount);
    }
}