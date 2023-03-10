
pragma solidity ^0.4.24;


library SafeMath {


    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {

        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {

        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {

        return (mul(x,x));
    }

    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
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
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

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

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}

library ImkgKeysCalc {

    using SafeMath for *;

    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {

        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {

        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    function keys(uint256 _eth)
        internal
        pure
        returns(uint256)
    {

        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000000);
    }

    function eth(uint256 _keys)
        internal
        pure
        returns(uint256)
    {

        return ((78125000000000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

contract Imkg {

    using SafeMath for *;
    using NameFilter for string;
    using ImkgKeysCalc for uint256;


    event onNewNameEvent
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 amountPaid,
        uint256 timeStamp
    );

    event onNewTeamNameEvent
    (
        uint256 indexed teamID,
        bytes32 indexed teamName,
        uint256 indexed playerID,
        bytes32 playerName,
        uint256 amountPaid,
        uint256 timeStamp
    );

    event onTxEvent
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 teamID,
        bytes32 teamName,
        uint256 ethIn,
        uint256 keysBought
    );

    event onAffPayoutEvent
    (
        uint256 indexed affID,
        address affAddress,
        bytes32 affName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );

    event onOutEvent
    (
        uint256 deadCount,
        uint256 liveCount,
        uint256 deadKeys
    );

    event onEndRoundEvent
    (
        uint256 winnerTID,  // winner
        bytes32 winnerTName,
        uint256 playersCount,
        uint256 eth    // eth in pot
    );

    event onWithdrawEvent
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );

    event onOutInitialEvent
    (
        uint256 outTime
    );


    struct Player {
        address addr;   //  player address
        bytes32 name;
        uint256 gen;    // balance
        uint256 aff;    // balance for invite
        uint256 laff;   // the latest invitor. ID
    }

    struct PlayerRounds {
        uint256 eth;    // all eths in current round
        mapping (uint256 => uint256) plyrTmKeys;    // teamid => keys
        bool withdrawn;     // if earnings are withdrawn in current round
    }

    struct Team {
        uint256 id;     // team id
        bytes32 name;    // team name
        uint256 keys;   // key s in the team
        uint256 eth;   // eth from the team
        uint256 price;    // price of the last key (only for view)
        uint256 playersCount;   // how many team members
        uint256 leaderID;   // leader pID (leader is always the top 1 player in the team)
        address leaderAddr;  // leader address
        bool dead;  // if team is out
    }

    struct Round {
        uint256 start;  // start time
        uint256 state;  // 0:inactive,1:prepare,2:out,3:end
        uint256 eth;    // all eths
        uint256 pot;    // amount of this pot
        uint256 keys;   // all keys
        uint256 team;   // first team ID
        uint256 ethPerKey;  // how many eth per key in Winner Team. (must after the game)
        uint256 lastOutTime;   // the last out emit time
        uint256 deadRate;   // current dead rate (first team all keys * rate = dead line)
        uint256 deadKeys;   // next dead line
        uint256 liveTeams;  // alive teams
        uint256 tID_;    // how many teams in this Round
    }

    string constant public name = "I AM The King of God";
    string constant public symbol = "IMKG";
    address public owner;
    address public cooperator;
    uint256 public minTms_ = 3;    //minimum team number for active limit
    uint256 public maxTms_ = 12;    // maximum team number
    uint256 public roundGap_ = 120;    // round gap: 2 mins
    uint256 public OutGap_ = 43200;   // out gap: 12 hours
    uint256 constant private registrationFee_ = 10 finney;    // fee for register a new name

    uint256 public pID_;    // all players
    mapping (address => uint256) public pIDxAddr_;  // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;  // (name => pID) returns player id by name
    mapping (uint256 => Player) public plyr_;   // (pID => data) player data

    uint256 public rID_;    // current round ID
    mapping (uint256 => Round) public round_;   // round ID => round data

    mapping (uint256 => mapping (uint256 => PlayerRounds)) public plyrRnds_;  // player ID => round ID => player info

    mapping (uint256 => mapping (uint256 => Team)) public rndTms_;  // round ID => team ID => team info
    mapping (uint256 => mapping (bytes32 => uint256)) public rndTIDxName_;  // (rID => team name => tID) returns team id by name


    constructor() public {
        owner = msg.sender;
        cooperator = address(0x8fccb08b8c4e6f4a3500Af33c45b28BF5290CFbC);
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    modifier isActivated() {

        require(activated_ == true, "its not ready yet.");
        _;
    }

    modifier isHuman() {

        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }

    modifier isWithinLimits(uint256 _eth) {

        require(_eth >= 1000000000, "no less than 1 Gwei");
        require(_eth <= 100000000000000000000000, "no more than 100000 ether");
        _;
    }


    function()
        public
        payable
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
    {
        buy(round_[rID_].team, "imkg");
    }

    function buy(uint256 _team, bytes32 _affCode)
        public
        payable
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
    {

        require(round_[rID_].state < 3, "This round has ended.");

        if (round_[rID_].state == 0){
            require(now >= round_[rID_].start, "This round hasn't started yet.");
            round_[rID_].state = 1;
        }

        determinePID(msg.sender);
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _tID;

        uint256 _affID;
        if (_affCode == "" || _affCode == plyr_[_pID].name){
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxName_[_affCode];

            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }

        if (round_[rID_].state == 1){
            _tID = determinTID(_team, _pID);

            buyCore(_pID, _affID, _tID, msg.value);

            if (round_[rID_].tID_ >= minTms_){
                round_[rID_].state = 2;

                startOut();
            }

        } else if (round_[rID_].state == 2){
            if (round_[rID_].liveTeams == 1){
                endRound();

                refund(_pID, msg.value);

                return;
            }

            _tID = determinTID(_team, _pID);

            buyCore(_pID, _affID, _tID, msg.value);

            if (now > round_[rID_].lastOutTime.add(OutGap_)) {
                out();
            }
        }
    }

    function withdraw()
        public
        isActivated()
        isHuman()
    {

        uint256 _pID = pIDxAddr_[msg.sender];

        require(_pID != 0, "Please join the game first!");

        uint256 _eth;

        if (rID_ > 1){
            for (uint256 i = 1; i < rID_; i++) {
                if (plyrRnds_[_pID][i].withdrawn == false){
                    if (plyrRnds_[_pID][i].plyrTmKeys[round_[i].team] != 0) {
                        _eth = _eth.add(round_[i].ethPerKey.mul(plyrRnds_[_pID][i].plyrTmKeys[round_[i].team]) / 1000000000000000000);
                    }
                    plyrRnds_[_pID][i].withdrawn = true;
                }
            }
        }

        _eth = _eth.add(plyr_[_pID].gen).add(plyr_[_pID].aff);

        if (_eth > 0) {
            plyr_[_pID].addr.transfer(_eth);
        }

        plyr_[_pID].gen = 0;
        plyr_[_pID].aff = 0;

        emit onWithdrawEvent(_pID, plyr_[_pID].addr, plyr_[_pID].name, _eth, now);
    }

    function registerNameXID(string _nameString)
        public
        payable
        isHuman()
    {

        require (msg.value >= registrationFee_, "You have to pay the name fee.(10 finney)");

        bytes32 _name = NameFilter.nameFilter(_nameString);

        address _addr = msg.sender;

        bool _isNewPlayer = determinePID(_addr);

        uint256 _pID = pIDxAddr_[_addr];

        require(pIDxName_[_name] == 0, "sorry that names already taken");

        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;

        plyr_[1].gen = (msg.value).add(plyr_[1].gen);

        emit onNewNameEvent(_pID, _addr, _name, _isNewPlayer, msg.value, now);
    }

    function setTeamName(uint256 _tID, string _nameString)
        public
        payable
        isHuman()
    {

        require(_tID <= round_[rID_].tID_ && _tID != 0, "There's no this team.");

        uint256 _pID = pIDxAddr_[msg.sender];

        require(_pID == rndTms_[rID_][_tID].leaderID, "Only team leader can change team name. You can invest more money to be the team leader.");

        require (msg.value >= registrationFee_, "You have to pay the name fee.(10 finney)");

        bytes32 _name = NameFilter.nameFilter(_nameString);

        require(rndTIDxName_[rID_][_name] == 0, "sorry that names already taken");

        rndTms_[rID_][_tID].name = _name;
        rndTIDxName_[rID_][_name] = _tID;

        plyr_[1].gen = (msg.value).add(plyr_[1].gen);

        emit onNewTeamNameEvent(_tID, _name, _pID, plyr_[_pID].name, msg.value, now);
    }

    function deposit()
        public
        payable
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
    {

        determinePID(msg.sender);
        uint256 _pID = pIDxAddr_[msg.sender];

        plyr_[_pID].gen = (msg.value).add(plyr_[_pID].gen);
    }


    function checkIfNameValid(string _nameStr)
        public
        view
        returns (bool)
    {

        bytes32 _name = _nameStr.nameFilter();
        if (pIDxName_[_name] == 0)
            return (true);
        else
            return (false);
    }

    function getNextOutAfter()
        public
        view
        returns (uint256)
    {

        require(round_[rID_].state == 2, "Not in Out period.");

        uint256 _tNext = round_[rID_].lastOutTime.add(OutGap_);
        uint256 _t = _tNext > now ? _tNext.sub(now) : 0;

        return _t;
    }

    function getPlayerInfoByAddress(address _addr)
        public
        view
        returns(uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        return (
            _pID,
            _addr,
            plyr_[_pID].name,
            plyr_[_pID].gen,
            plyr_[_pID].aff,
            plyrRnds_[_pID][rID_].eth,
            getProfit(_pID),
            getPreviousProfit(_pID)
        );
    }

    function getPlayerRoundTeamBought(uint256 _pID, uint256 _roundID, uint256 _tID)
        public
        view
        returns (uint256)
    {

        uint256 _rID = _roundID == 0 ? rID_ : _roundID;
        return plyrRnds_[_pID][_rID].plyrTmKeys[_tID];
    }

    function getPlayerRoundBought(uint256 _pID, uint256 _roundID)
        public
        view
        returns (uint256[])
    {

        uint256 _rID = _roundID == 0 ? rID_ : _roundID;

        uint256 _tCount = round_[_rID].tID_;

        uint256[] memory keysList = new uint256[](_tCount);

        for (uint i = 0; i < _tCount; i++) {
            keysList[i] = plyrRnds_[_pID][_rID].plyrTmKeys[i+1];
        }

        return keysList;
    }

    function getPlayerRounds(uint256 _pID)
        public
        view
        returns (uint256[], uint256[])
    {

        uint256[] memory _ethList = new uint256[](rID_);
        uint256[] memory _winList = new uint256[](rID_);
        for (uint i=0; i < rID_; i++){
            _ethList[i] = plyrRnds_[_pID][i+1].eth;
            _winList[i] = plyrRnds_[_pID][i+1].plyrTmKeys[round_[i+1].team].mul(round_[i+1].ethPerKey) / 1000000000000000000;
        }

        return (
            _ethList,
            _winList
        );
    }

    function getLastRoundInfo()
        public
        view
        returns (uint256, uint256, uint256, uint256, bytes32, uint256, uint256)
    {

        uint256 _rID = rID_.sub(1);

        uint256 _tID = round_[_rID].team;

        return (
            _rID,
            round_[_rID].state,
            round_[_rID].pot,
            _tID,
            rndTms_[_rID][_tID].name,
            rndTms_[_rID][_tID].playersCount,
            round_[_rID].tID_
        );
    }

    function getCurrentRoundInfo()
        public
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {

        return (
            rID_,
            round_[rID_].state,
            round_[rID_].eth,
            round_[rID_].pot,
            round_[rID_].keys,
            round_[rID_].team,
            round_[rID_].ethPerKey,
            round_[rID_].lastOutTime,
            OutGap_,
            round_[rID_].deadRate,
            round_[rID_].deadKeys,
            round_[rID_].liveTeams,
            round_[rID_].tID_,
            round_[rID_].start
        );
    }

    function getTeamInfoByID(uint256 _tID)
        public
        view
        returns (uint256, bytes32, uint256, uint256, uint256, uint256, bool)
    {

        require(_tID <= round_[rID_].tID_, "There's no this team.");

        return (
            rndTms_[rID_][_tID].id,
            rndTms_[rID_][_tID].name,
            rndTms_[rID_][_tID].keys,
            rndTms_[rID_][_tID].eth,
            rndTms_[rID_][_tID].price,
            rndTms_[rID_][_tID].leaderID,
            rndTms_[rID_][_tID].dead
        );
    }

    function getTeamsInfo()
        public
        view
        returns (uint256[], bytes32[], uint256[], uint256[], uint256[], uint256[], bool[])
    {

        uint256 _tID = round_[rID_].tID_;

        uint256[] memory _idList = new uint256[](_tID);
        bytes32[] memory _nameList = new bytes32[](_tID);
        uint256[] memory _keysList = new uint256[](_tID);
        uint256[] memory _ethList = new uint256[](_tID);
        uint256[] memory _priceList = new uint256[](_tID);
        uint256[] memory _membersList = new uint256[](_tID);
        bool[] memory _deadList = new bool[](_tID);

        for (uint i = 0; i < _tID; i++) {
            _idList[i] = rndTms_[rID_][i+1].id;
            _nameList[i] = rndTms_[rID_][i+1].name;
            _keysList[i] = rndTms_[rID_][i+1].keys;
            _ethList[i] = rndTms_[rID_][i+1].eth;
            _priceList[i] = rndTms_[rID_][i+1].price;
            _membersList[i] = rndTms_[rID_][i+1].playersCount;
            _deadList[i] = rndTms_[rID_][i+1].dead;
        }

        return (
            _idList,
            _nameList,
            _keysList,
            _ethList,
            _priceList,
            _membersList,
            _deadList
        );
    }

    function getTeamLeaders()
        public
        view
        returns (uint256[], uint256[], bytes32[], address[])
    {

        uint256 _tID = round_[rID_].tID_;

        uint256[] memory _idList = new uint256[](_tID);
        uint256[] memory _leaderIDList = new uint256[](_tID);
        bytes32[] memory _leaderNameList = new bytes32[](_tID);
        address[] memory _leaderAddrList = new address[](_tID);

        for (uint i = 0; i < _tID; i++) {
            _idList[i] = rndTms_[rID_][i+1].id;
            _leaderIDList[i] = rndTms_[rID_][i+1].leaderID;
            _leaderNameList[i] = plyr_[_leaderIDList[i]].name;
            _leaderAddrList[i] = rndTms_[rID_][i+1].leaderAddr;
        }

        return (
            _idList,
            _leaderIDList,
            _leaderNameList,
            _leaderAddrList
        );
    }

    function getProfit(uint256 _pID)
        public
        view
        returns (uint256)
    {

        uint256 _tID = round_[rID_].team;

        if (plyrRnds_[_pID][rID_].plyrTmKeys[_tID] == 0){
            return 0;
        }

        uint256 _keys = plyrRnds_[_pID][rID_].plyrTmKeys[_tID];

        uint256 _ethPerKey = round_[rID_].pot.mul(1000000000000000000) / rndTms_[rID_][_tID].keys;

        uint256 _value = _keys.mul(_ethPerKey) / 1000000000000000000;

        return _value;
    }

    function getPreviousProfit(uint256 _pID)
        public
        view
        returns (uint256)
    {

        uint256 _eth;

        if (rID_ > 1){
            for (uint256 i = 1; i < rID_; i++) {
                if (plyrRnds_[_pID][i].withdrawn == false){
                    if (plyrRnds_[_pID][i].plyrTmKeys[round_[i].team] != 0) {
                        _eth = _eth.add(round_[i].ethPerKey.mul(plyrRnds_[_pID][i].plyrTmKeys[round_[i].team]) / 1000000000000000000);
                    }
                }
            }
        } else {
            _eth = 0;
        }

        return _eth;
    }

    function getNextKeyPrice(uint256 _tID)
        public
        view
        returns(uint256)
    {

        require(_tID <= round_[rID_].tID_ && _tID != 0, "No this team.");

        return ( (rndTms_[rID_][_tID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
    }

    function getEthFromKeys(uint256 _tID, uint256 _keys)
        public
        view
        returns(uint256)
    {

        if (_tID <= round_[rID_].tID_ && _tID != 0){
            return ((rndTms_[rID_][_tID].keys.add(_keys)).ethRec(_keys));
        } else {
            return ((uint256(0).add(_keys)).ethRec(_keys));
        }
    }

    function getKeysFromEth(uint256 _tID, uint256 _eth)
        public
        view
        returns (uint256)
    {

        if (_tID <= round_[rID_].tID_ && _tID != 0){
            return (rndTms_[rID_][_tID].eth).keysRec(_eth);
        } else {
            return (uint256(0).keysRec(_eth));
        }
    }


    function buyCore(uint256 _pID, uint256 _affID, uint256 _tID, uint256 _eth)
        private
    {

        uint256 _keys = (rndTms_[rID_][_tID].eth).keysRec(_eth);

        if (plyrRnds_[_pID][rID_].plyrTmKeys[_tID] == 0){
            rndTms_[rID_][_tID].playersCount++;
        }
        plyrRnds_[_pID][rID_].plyrTmKeys[_tID] = _keys.add(plyrRnds_[_pID][rID_].plyrTmKeys[_tID]);
        plyrRnds_[_pID][rID_].eth = _eth.add(plyrRnds_[_pID][rID_].eth);

        rndTms_[rID_][_tID].keys = _keys.add(rndTms_[rID_][_tID].keys);
        rndTms_[rID_][_tID].eth = _eth.add(rndTms_[rID_][_tID].eth);
        rndTms_[rID_][_tID].price = _eth.mul(1000000000000000000) / _keys;
        uint256 _teamLeaderID = rndTms_[rID_][_tID].leaderID;
        if (plyrRnds_[_pID][rID_].plyrTmKeys[_tID] > plyrRnds_[_teamLeaderID][rID_].plyrTmKeys[_tID]){
            rndTms_[rID_][_tID].leaderID = _pID;
            rndTms_[rID_][_tID].leaderAddr = msg.sender;
        }

        round_[rID_].keys = _keys.add(round_[rID_].keys);
        round_[rID_].eth = _eth.add(round_[rID_].eth);
        if (rndTms_[rID_][_tID].keys > rndTms_[rID_][round_[rID_].team].keys){
            round_[rID_].team = _tID;
        }

        distribute(rID_, _pID, _eth, _affID);

        emit onTxEvent(_pID, msg.sender, plyr_[_pID].name, _tID, rndTms_[rID_][_tID].name, _eth, _keys);
    }

    function distribute(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID)
        private
    {

        uint256 _com = (_eth.mul(3)) / 100;

        plyr_[1].gen = _com.add(plyr_[1].gen);

        uint256 _aff = _eth / 10;

        if (_affID != _pID && plyr_[_affID].name != "") {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);

            emit onAffPayoutEvent(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } else {
            _aff = 0;
        }

        uint256 _pot = _eth.sub(_aff).sub(_com);

        round_[_rID].pot = _pot.add(round_[_rID].pot);
    }

    function endRound()
        private
    {

        require(round_[rID_].state < 3, "Round only end once.");

        round_[rID_].state = 3;

        uint256 _pot = round_[rID_].pot;

        uint256 _win = (_pot.mul(85))/100;

        uint256 _com = (_pot.mul(5))/100;

        uint256 _res = (_pot.sub(_win)).sub(_com);

        uint256 _tID = round_[rID_].team;
        uint256 _epk = (_win.mul(1000000000000000000)) / (rndTms_[rID_][_tID].keys);

        uint256 _dust = _win.sub((_epk.mul(rndTms_[rID_][_tID].keys)) / 1000000000000000000);
        if (_dust > 0) {
            _win = _win.sub(_dust);
            _res = _res.add(_dust);
        }

        round_[rID_].ethPerKey = _epk;

        plyr_[1].gen = _com.add(plyr_[1].gen);

        emit onEndRoundEvent(_tID, rndTms_[rID_][_tID].name, rndTms_[rID_][_tID].playersCount, _pot);

        rID_++;
        round_[rID_].pot = _res;
        round_[rID_].start = now + roundGap_;
    }

    function refund(uint256 _pID, uint256 _value)
        private
    {

        plyr_[_pID].gen = _value.add(plyr_[_pID].gen);
    }

    function createTeam(uint256 _pID, uint256 _eth)
        private
        returns (uint256)
    {

        require(round_[rID_].tID_ < maxTms_, "The number of teams has reached the maximum limit.");

        require(_eth >= 1000000000000000000, "You need at least 1 eth to create a team, though creating a new team is free.");

        round_[rID_].tID_++;
        round_[rID_].liveTeams++;

        uint256 _tID = round_[rID_].tID_;

        rndTms_[rID_][_tID].id = _tID;
        rndTms_[rID_][_tID].leaderID = _pID;
        rndTms_[rID_][_tID].leaderAddr = plyr_[_pID].addr;
        rndTms_[rID_][_tID].dead = false;

        return _tID;
    }

    function startOut()
        private
    {

        round_[rID_].lastOutTime = now;
        round_[rID_].deadRate = 10;     // used by deadRate / 100
        round_[rID_].deadKeys = (rndTms_[rID_][round_[rID_].team].keys.mul(round_[rID_].deadRate)) / 100;
        emit onOutInitialEvent(round_[rID_].lastOutTime);
    }

    function out()
        private
    {

        uint256 _dead = 0;

        for (uint256 i = 1; i <= round_[rID_].tID_; i++) {
            if (rndTms_[rID_][i].keys < round_[rID_].deadKeys && rndTms_[rID_][i].dead == false){
                rndTms_[rID_][i].dead = true;
                round_[rID_].liveTeams--;
                _dead++;
            }
        }

        round_[rID_].lastOutTime = now;

        if (round_[rID_].liveTeams == 1 && round_[rID_].state == 2) {
            endRound();
            return;
        }

        if (round_[rID_].deadRate < 90) {
            round_[rID_].deadRate = round_[rID_].deadRate + 10;
        }

        round_[rID_].deadKeys = ((rndTms_[rID_][round_[rID_].team].keys).mul(round_[rID_].deadRate)) / 100;

        emit onOutInitialEvent(round_[rID_].lastOutTime);
        emit onOutEvent(_dead, round_[rID_].liveTeams, round_[rID_].deadKeys);
    }

    function determinePID(address _addr)
        private
        returns (bool)
    {

        if (pIDxAddr_[_addr] == 0)
        {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;

            return (true);  // new
        } else {
            return (false);
        }
    }

    function determinTID(uint256 _team, uint256 _pID)
        private
        returns (uint256)
    {

        require(rndTms_[rID_][_team].dead == false, "You can not buy a dead team!");

        if (_team <= round_[rID_].tID_ && _team > 0) {
            return _team;
        } else {
            return createTeam(_pID, msg.value);
        }
    }


    bool public activated_ = false;
    function activate()
        public
        onlyOwner()
    {

        require(activated_ == false, "it is already activated");

        activated_ = true;

        plyr_[1].addr = cooperator;
        plyr_[1].name = "imkg";
        pIDxAddr_[cooperator] = 1;
        pIDxName_["imkg"] = 1;
        pID_ = 1;

        rID_ = 1;
        round_[1].start = now;
        round_[1].state = 1;
    }


      function timeCountdown()
          public
          isActivated()
          isHuman()
          onlyOwner()
      {

          if (round_[rID_].state == 2){
              if (round_[rID_].liveTeams == 1){

                  endRound();
                  return;
              }

              if (now > round_[rID_].lastOutTime.add(OutGap_)) {
                  out();
              }
          }
      }


    function setMinTms(uint256 _tms)
        public
        onlyOwner()
    {

        minTms_ = _tms;
    }

    function setMaxTms(uint256 _tms)
        public
        onlyOwner()
    {

        maxTms_ = _tms;
    }

    function setRoundGap(uint256 _gap)
        public
        onlyOwner()
    {

        roundGap_ = _gap;
    }

    function setOutGap(uint256 _gap)
        public
        onlyOwner()
    {

        OutGap_ = _gap;
    }

}   // main contract ends here