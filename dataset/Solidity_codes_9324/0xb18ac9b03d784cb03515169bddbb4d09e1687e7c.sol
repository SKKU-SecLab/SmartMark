
pragma solidity ^0.4.24;

interface PlayerBookInterface {

    function getPlayerID(address _addr) external returns (uint256);

    function getPlayerName(uint256 _pID) external view returns (bytes32);

    function getPlayerLAff(uint256 _pID) external view returns (uint256);

    function getPlayerAddr(uint256 _pID) external view returns (address);

    function getNameFee() external view returns (uint256);

    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);

    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);

    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);

}

interface FoMo3DLongInterface {

    function buyXid(uint256 _affCode, uint256 _eth, bytes32 _keyType) public returns(uint256);

    function buyXaddr(address _affCode, uint256 _eth, bytes32 _keyType) public returns(uint256);

    function buyXname(bytes32 _affCode, uint256 _eth, bytes32 _keyType) public returns(uint256);


    function registerNameXid(string memory _nameString, uint256 _affCode, bool _all) public;

    function registerNameXaddr(string memory _nameString, address _affCode, bool _all) public;

    function registerNameXname(string memory _nameString, bytes32 _affCode, bool _all) public;

    
    function getBuyPrice() public returns(uint256);

    function getTimeLeft() public returns(uint256);


    function getCurrentRoundInfo() public returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);

    function getPlayerInfoByAddress(address _addr) public view returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);

    function getPlayerRoundInfoByID(uint256 _pID, uint256 _rID) public view returns(uint256, uint256, bool, uint256, uint256, uint256, uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256);

    function getCurrentRoundTeamCos() public view returns(uint256,uint256,uint256,uint256);

    
    function sellKeys(uint256 _pID_, uint256 _keys_, bytes32 _keyType) public returns(uint256);

    function playGame(uint256 _pID, uint256 _keys, uint256 _team, bytes32 _keyType) public returns(bool,bool);

    function buyProp(uint256 _pID, uint256 _eth, uint256 _propID) public returns(uint256,uint256);

    function buyLeader(uint256 _pID, uint256 _eth) public returns(uint256,uint256);

    function iWantXKeys(uint256 _keys) public returns(uint256);

    
    function withdrawHoldVault(uint256 _pID) public returns(bool);

    function withdrawAffVault(uint256 _pID) public returns(bool);

    function withdrawWonCosFromGame(uint256 _pID, uint256 _affID, uint256 _rID) public returns(bool);

    function transferToAnotherAddr(address _to, uint256 _keys, bytes32 _keyType) public returns(bool);

    function activate() public;

}

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

    function div(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256 c) 
    {

        require(b > 0);
        c = a / b;
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


    function nameFilter(string memory _input)
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


contract Ownable {

    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract F3Devents {


    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );

    event onWithdrawAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon
    );

    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 pCosd,
        uint256 pCosc,
        uint256 comCosd,
        uint256 comCosc,
        uint256 affVltCosd,
        uint256 affVltCosc,
        uint256 keyNums
    );

    event onRecHldVltCosd
    (
        address playerAddress,
        bytes32 playerName, 
        uint256 hldVltCosd
    );

    event onSellAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 pCosd,
        uint256 pCosc,
        uint256 keyNums
    );

    event onGameCore
    (
        address playerAddress,
        bytes32 playerName,
        uint256 pCosd,
        uint256 pCosc,
        uint256 plyrRnds_cosd,
        uint256 plyrRnds_cosc,
        bool plyrRnds_first,
        uint256 plyrRnds_redtPRFirst,
        uint256 plyrRnds_firstCosd,
        uint256 plyrRnds_firstCosc,
        uint256 round_cosd,
        uint256 round_cosc,
        uint256 plyrRnds_team
    );

    event onEndRoundProssRate
    (
        address playerAddress,
        bytes32 playerName,
        uint256 plyrRnds_cosd,
        uint256 plyrRnds_cosc,
        uint256 plyr_rounds,
        uint256 plyr_redt1,
        uint256 plyr_redt3
    );

    event onWin
    (
        address playerAddress,
        bytes32 playerName,
        uint256 plyrRnds_wonCosd,
        uint256 plyrRnds_wonCosc,
        uint256 plyr_lrnd
    );

    event onLoss
    (
        address playerAddress,
        bytes32 playerName,
        uint256 plyrRnds_wonCosd,
        uint256 plyrRnds_wonCosc,
        uint256 plyr_lrnd
    );
    event onEndRound
    (
        uint256 rID,
        uint256 round_strt,
        uint256 round_end,
        bool    round_ended
    );

    event onBuyProp
    (
        address playerAddress,
        bytes32 playerName,
        uint256 plyrRnds_predtPRProp,
        uint256 plyrRnds_pincrPRProp,
        uint256 plyr_predtProp,
        bool    plyrRnds_phadProp,
        uint256 plyrRnds_ppropID,
        uint256 plyrRnds_oredtPRProp,
        uint256 plyrRnds_oincrPRProp,
        uint256 plyr_oredtProp,
        bool    plyrRnds_ohadProp,
        uint256 plyrRnds_opropID,
        uint256 rndProp_oID
    );

    event onBuyLeader
    (
        address playerAddress,
        uint256 rndLd_price,
        uint256 round_plyr,
        uint256 round_team,
        uint256 rndTmEth_winRate1,
        uint256 rndTmEth_winRate2
    );
   
    event onWithdrawHoldVault
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 plyr_cosd,
        uint256 plyr_hldVltCosd
    );
    
    event onWithdrawAffVault
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 plyr_cosd,
        uint256 plyr_cosc,
        uint256 plyr_affVltCosd,
        uint256 plyr_affVltCosc
    );
    
    event onWithdrawWonCosFromGame
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 plyr_cosd,
        uint256 plyr_cosc,
        uint256 plyr_affVltCosd
    );
}

contract modularLong is F3Devents {}


contract FoMo3DLong is modularLong, Ownable, FoMo3DLongInterface {

    using SafeMath for *;
    using NameFilter for *;
    using F3DKeysCalcLong for *;

    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xdDc312cc5675fc3e36C33A6bAfd1aDC089E3ED46);

    string constant public name = "FoMo3D World";
    string constant public symbol = "F3DW";
    uint256 constant public rndGap_ = 0; // 120 seconds;         // length of ICO phase.
    uint256 constant public rndInit_ = 4 hours;                // round timer starts at this

    uint256 constant public rndFirst_ = 1 hours;                // a round fist step timer can be

    uint256 constant public threshould_ = 3;//超过XXX个cos

    uint256 public rID_;    // round id number / total rounds that have happened
    uint256 public plyNum_ = 2;
    uint256 public keyNum_ = 0;

    uint256 constant public pIDCom_ = 1;
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => F3Ddatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amongst any name you own)
    mapping (uint256 => F3Ddatasets.Round) public round_;   // (rID => data) round data
    mapping (uint256 => mapping(uint256 => F3Ddatasets.Team)) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id
    mapping (uint256 => mapping(uint256 => F3Ddatasets.Prop)) public rndProp_;      // (rID => propID => data) eth in per team, by round id and team id
    mapping (uint256 => F3Ddatasets.Leader) public rndLd_;      // (rID => data) eth in per team, by round id and team id
    

    mapping (uint256 => F3Ddatasets.Fee) public fees_;          // (teamID => team)
    

    constructor()
    public
    {
        fees_[0] = F3Ddatasets.Fee(5,2,3);    //cosdBuyFee
        fees_[1] = F3Ddatasets.Fee(0,0,20);  //cosdSellFee
        fees_[2] = F3Ddatasets.Fee(4,1,0);    //coscBuyFee
        fees_[3] = F3Ddatasets.Fee(0,0,0);   //coscSellFee
    }

    modifier isActivated() {

        require(activated_ == true, "its not ready yet.  check ?eta in discord");
        _;
    }

    modifier isHuman() {

        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier isWithinLimits(uint256 _eth) {

        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        _;
    }

    function buyXid(uint256 _affCode, uint256 _eth, bytes32 _keyType)
    isActivated()
    isHuman()
    public
    returns(uint256)
    {

        determinePID();

        uint256 _pID = pIDxAddr_[msg.sender];

        if (_affCode == 0 || _affCode == _pID)
        {
            _affCode = plyr_[_pID].laff;

        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }


        return buyCore(_pID, _affCode,_eth, _keyType);
    }

    function buyXaddr(address _affCode, uint256 _eth, bytes32 _keyType)
    isActivated()
    isHuman()
    public
    returns(uint256)
    {

        determinePID();

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            _affID = plyr_[_pID].laff;

        } else {
            _affID = pIDxAddr_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }


        return buyCore(_pID, _affID, _eth, _keyType);
    }








    function registerNameXid(string memory _nameString, uint256 _affCode, bool _all)
    isHuman()
    public
    {

        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXaddr(string   memory  _nameString, address _affCode, bool _all)
    isHuman()
    public
    {

        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }



    function getBuyPrice()
    public
    returns(uint256)
    {


        uint256 _price = 10**16;
        uint256 _keyNum = keyNum_;
            while(_keyNum > 0){
                _price = _price + _price*3/10000;
                _keyNum--;
            }
            return _price;
    }

    function getTimeLeft()
    public
    returns(uint256)
    {

        uint256 _rID = rID_;

        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt + rndGap_)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt + rndGap_).sub(_now) );
        else
            return(0);
    }

  
    
    function getCurrentRoundInfo()
    public
    returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {

        uint256 _rID = rID_;

        return
        (
            _rID,                           
            round_[_rID].plyr,
            round_[_rID].team,
            round_[_rID].cosd,              
            round_[_rID].cosc,              
            round_[_rID].strt,              
            round_[_rID].end,                                                
            round_[_rID].winTeam           
        );
    }


    function getPlayerInfoByAddress(address _addr)
    public
    view
    returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {


        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        return
        (
            _pID,                              
            plyr_[_pID].name,                  
            plyr_[_pID].cosd,       
            plyr_[_pID].cosc,
            plyr_[_pID].lrnd,                  
            plyr_[_pID].laff,
            plyr_[_pID].rounds,
            plyr_[_pID].redtProp,
            plyr_[_pID].redt1,
            plyr_[_pID].redt3,
            plyr_[_pID].affVltCosd,
            plyr_[_pID].affVltCosc,
            plyr_[_pID].hldVltCosd
        );
    }

   
    function getPlayerRoundInfoByID(uint256 _pID, uint256 _rID)
    public
    view
    returns(uint256, uint256, bool, uint256, uint256, uint256, uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256)
    {

        uint256 _rID_ = _rID;
        uint256 _pID_ = _pID;

        return
        (              
            plyrRnds_[_pID_][_rID_].cosd,       
            plyrRnds_[_pID_][_rID_].cosc,
            plyrRnds_[_pID_][_rID_].hadProp,                  
            plyrRnds_[_pID_][_rID_].propID,
            plyrRnds_[_pID_][_rID_].redtPRProp,
            plyrRnds_[_pID_][_rID_].incrPRProp,
            plyrRnds_[_pID_][_rID_].team,
            plyrRnds_[_pID_][_rID_].first,
            plyrRnds_[_pID_][_rID_].firstCosd,
            plyrRnds_[_pID_][_rID_].firstCosc,
            plyrRnds_[_pID_][_rID_].wonCosd,
            plyrRnds_[_pID_][_rID_].wonCosc,
            plyrRnds_[_pID_][_rID_].wonCosdRcd,
            plyrRnds_[_pID_][_rID_].wonCoscRcd        
        );
    }

    function getCurrentRoundTeamCos()
    public
    view
    returns(uint256, uint256, uint256, uint256)
    {

        uint256 _rID = rID_;

        return
        (              
              rndTmEth_[_rID][1].cosd,
              rndTmEth_[_rID][1].cosc,
              rndTmEth_[_rID][2].cosd,
              rndTmEth_[_rID][2].cosc
        );
    }

   
    function buyCore(uint256 _pID, uint256 _affID, uint256 _eth, bytes32 _keyType)
    private
    returns(uint256)
    {

        uint256 _keys;
        if (_eth > 1000000000)
        {
            _keys = _eth.keysRec(getBuyPrice());
            uint256 _aff;
            uint256 _com;
            uint256 _holders;
            uint256 _self;

            if (_keyType == "cosd") {
                _aff        = _keys.mul(fees_[0].aff)/100;
                _com        = _keys.mul(fees_[0].com)/100;
                _holders    = _keys.mul(fees_[0].holders)/100;
                _self       = _keys.sub(_aff).sub(_com).sub(_holders);
            }else{
                _aff        = _keys.mul(fees_[2].aff)/100;
                _com        = _keys.mul(fees_[2].com)/100;
                _holders    = _keys.mul(fees_[2].holders)/100;
                _self       = _keys.sub(_aff).sub(_com).sub(_holders);
            }

            if(_keyType == "cosd"){

                uint256 _hldCosd;
                for (uint256 i = 1; i <= plyNum_; i++) {
                    if(i!=_pID && plyr_[i].cosd>0) _hldCosd = _hldCosd.add(plyr_[i].cosd);
                }

                plyr_[_pID].cosd = plyr_[_pID].cosd + _self;
                plyr_[pIDCom_].cosd = plyr_[pIDCom_].cosd.add(_com);
                plyr_[_affID].affVltCosd = plyr_[_affID].affVltCosd.add(_aff);

                for (uint256 j = 1; j <= plyNum_; j++) {
                    if(j!=_pID && plyr_[j].cosd>0) {
                        plyr_[j].hldVltCosd = plyr_[j].hldVltCosd.add(_holders.mul(plyr_[j].cosd).div(_hldCosd));
                        emit F3Devents.onRecHldVltCosd
                        (
                            msg.sender,
                            plyr_[j].name,
                            plyr_[j].hldVltCosd
                        );
                    }
                }
            }
            else{//cosc
                plyr_[_pID].cosc = plyr_[_pID].cosc + _self;
                plyr_[pIDCom_].cosc = plyr_[0].cosc.add(_com);
                plyr_[_affID].affVltCosc = plyr_[_affID].affVltCosc.add(_aff);
            }

            keyNum_ = keyNum_.add(_keys);//update




        }

        return _keys;
    }  


   
    function sellKeys(uint256 _pID_, uint256 _keys_, bytes32 _keyType)
    isActivated()
    isHuman()
    public
    returns(uint256)
    {

        uint256 _pID = _pID_;
        uint256 _keys = _keys_;
        require(_keys>0);
        uint256 _eth;

        uint256 _holders;
        uint256 _self;
        if (_keyType == "cosd") {
                _holders    = _keys.mul(fees_[1].holders)/100;
                _self       = _self.sub(_holders);
        }else{
                _holders    = _keys.mul(fees_[3].holders)/100;
                _self       = _self.sub(_holders);
        }
       if(_keyType == "cosd"){
            require(plyr_[_pID].cosd >= _keys,"Do not have cosd!");

            uint256 _hldCosd;
                for (uint256 i = 1; i <= plyNum_; i++) {
                    if(i!=_pID && plyr_[i].cosd>0) _hldCosd = _hldCosd.add(plyr_[i].cosd);
                }

                plyr_[_pID].cosd = plyr_[_pID].cosd.sub(_self);

                for (uint256 j = 1; j <= plyNum_; j++) {
                    if(j!=_pID && plyr_[j].cosd>0) {                    
                        plyr_[j].hldVltCosd = plyr_[j].hldVltCosd.add(_holders.mul(plyr_[j].cosd).div(_hldCosd));
                        emit F3Devents.onRecHldVltCosd
                        (
                            msg.sender,
                            plyr_[j].name,
                            plyr_[j].hldVltCosd
                        );
                    }
                }
       }
       else{
            require(plyr_[_pID].cosc >= _keys,"Do not have cosc!");           

            plyr_[_pID].cosc = plyr_[_pID].cosc.sub(_self);
       }

       keyNum_ = keyNum_.sub(_keys);//update
       _eth = _keys.ethRec(getBuyPrice());

       emit F3Devents.onSellAndDistribute
                (
                    msg.sender,
                    plyr_[_pID].name,
                    plyr_[_pID].cosd,
                    plyr_[_pID].cosc,
                    keyNum_
                );

       return _eth;
    }


    function playGame(uint256 _pID, uint256 _keys, uint256 _team, bytes32 _keyType)
    isActivated()
    isHuman()
    public
    returns(bool, bool)
    {

        uint256 _rID = rID_;

        uint256 _now = now;
        bool _game;
        bool _end;

        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {   //uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, bytes32 _keyType, bytes32 F3Ddatasets.EventReturns memory _eventData_
            _game = gameCore(_pID, _keys, _team, _keyType);

        } else {
            if (_now > round_[_rID].end && round_[_rID].ended == false)
            {
                round_[_rID].ended = true;
                uint256 _winTeam;

                _winTeam =  endRound();
                _end = true;


                emit F3Devents.onEndRound
                (
                    rID_,
                    round_[_rID].strt,
                    round_[_rID].end,
                    round_[_rID].ended
                );
            }

        }
        return (_game, _end);
    }
  
    function gameCore(uint256 _pID, uint256 _keys, uint256 _team, bytes32 _keyType)
    private
    returns(bool)
    {

            uint256 _rID = rID_;
            uint256 _now = now;

            if(_keyType == "cosd"){
                require(plyr_[_pID].cosd >= _keys);
                plyrRnds_[_pID][_rID].cosd   = plyrRnds_[_pID][_rID].cosd.add(_keys);
                plyr_[_pID].cosd = plyr_[_pID].cosd.sub(_keys);
                rndTmEth_[_rID][_team].cosd = _keys.add(rndTmEth_[_rID][_team].cosd);

                if (_now > round_[_rID].strt + rndGap_ && _now <= round_[_rID].strt + rndGap_ + rndFirst_) { //first step
                    plyrRnds_[_pID][_rID].first = true;
                    plyrRnds_[_pID][_rID].redtPRFirst = 80;
                    plyrRnds_[_pID][_rID].firstCosd = plyrRnds_[_pID][_rID].firstCosd.add(_keys);
                }
            }
            else{//cosc
                require(plyr_[_pID].cosc >= _keys);
                plyrRnds_[_pID][_rID].cosc   = plyrRnds_[_pID][_rID].cosc.add(_keys);
                plyr_[_pID].cosc = plyr_[_pID].cosc.sub(_keys);
  
                rndTmEth_[_rID][_team].cosc = _keys.add(rndTmEth_[_rID][_team].cosc);

                if (_now > round_[_rID].strt + rndGap_ && _now <= round_[_rID].strt + rndGap_ + rndFirst_) { //first step
                    plyrRnds_[_pID][_rID].first = true;
                    plyrRnds_[_pID][_rID].redtPRFirst = 80;
                    plyrRnds_[_pID][_rID].firstCosc = plyrRnds_[_pID][_rID].firstCosc.add(_keys);
                }
            }

            if(_keyType == "cosd")
                round_[_rID].cosd = _keys.add(round_[_rID].cosd);
            else
                round_[_rID].cosc = _keys.add(round_[_rID].cosc);

            plyrRnds_[_pID][_rID].team = _team;

        
            return true;
    }  

    function buyProp(uint256 _pID, uint256 _eth, uint256 _propID)
    isActivated()
    isHuman()
    public
    returns(uint256,uint256) //pID,eth
    {

        uint256 _rID = rID_;
        uint256 _rstETH = 0;
        uint256 _oID = rndProp_[_rID][_propID].oID;

      if(_pID >= 1 && _pID <= 6){

        if (_propID == 1) {
            require(_eth >= 3 * 10**18 && plyrRnds_[_pID][_rID].hadProp == false && _oID != _pID);
            if(plyrRnds_[_pID][_rID].team == 1)
                rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 5;
            else rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 10;

            if(plyrRnds_[_pID][_rID].redtPRProp == 0) plyrRnds_[_pID][_rID].redtPRProp = 80;
            else    plyrRnds_[_pID][_rID].redtPRProp = plyrRnds_[_pID][_rID].redtPRProp*80/100;

            if(plyrRnds_[_pID][_rID].incrPRProp == 0) plyrRnds_[_pID][_rID].incrPRProp = 120;
            else    plyrRnds_[_pID][_rID].incrPRProp = plyrRnds_[_pID][_rID].incrPRProp*120/100;

            if(plyr_[_pID].redtProp == 0) plyr_[_pID].redtProp = 97;
            else plyr_[_pID].redtProp = plyr_[_pID].redtProp*97/100;
            if (_oID != 0) {

                if(plyrRnds_[_oID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 5;
                else rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 10;

                plyrRnds_[_oID][_rID].redtPRProp = plyrRnds_[_oID][_rID].redtPRProp*120/100;

                plyrRnds_[_oID][_rID].incrPRProp = plyrRnds_[_oID][_rID].incrPRProp*80/100;
                plyr_[_oID].redtProp = plyr_[_oID].redtProp*103/100;

                plyrRnds_[_oID][_rID].hadProp = false;
                plyrRnds_[_oID][_rID].propID = 0;
            }

            rndProp_[_rID][_propID].oID = _pID;
            plyrRnds_[_pID][_rID].hadProp = true;
            plyrRnds_[_pID][_rID].propID = _propID;
            if (_oID == 0) {
                rndProp_[_rID][_propID].price = 3 * 10**18;
                _rstETH = 0;
            }else{
                _rstETH = rndProp_[_rID][_propID].price*150/100;
                rndProp_[_rID][_propID].price = rndProp_[_rID][_propID].price*200/100;
            }
        }
        else if (_propID == 2) {
            require(_eth >= 1 * 10**18 && plyrRnds_[_pID][_rID].hadProp == false && _oID != _pID);
            if(plyrRnds_[_pID][_rID].team == 1)
                rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 2;
            else rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 4;

            if(plyrRnds_[_pID][_rID].redtPRProp == 0) plyrRnds_[_pID][_rID].redtPRProp = 90;
            else    plyrRnds_[_pID][_rID].redtPRProp = plyrRnds_[_pID][_rID].redtPRProp*90/100;
            if(plyr_[_pID].redtProp == 0) plyr_[_pID].redtProp = 99;
            else plyr_[_pID].redtProp = plyr_[_pID].redtProp*99/100;
            if (_oID != 0) {

                if(plyrRnds_[_oID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 2;
                else rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 4;

                plyrRnds_[_oID][_rID].redtPRProp = plyrRnds_[_oID][_rID].redtPRProp*110/100;
                plyr_[_oID].redtProp = plyr_[_oID].redtProp*101/100;

                plyrRnds_[_oID][_rID].hadProp = false;
                plyrRnds_[_oID][_rID].propID = 0;
            }

            rndProp_[_rID][_propID].oID = _pID;
            plyrRnds_[_pID][_rID].hadProp = true;
            plyrRnds_[_pID][_rID].propID = _propID;
            if (_oID == 0) {
                rndProp_[_rID][_propID].price = 1 * 10**18;
                _rstETH = 0;
            }else{
                _rstETH = rndProp_[_rID][_propID].price*200/100;
                rndProp_[_rID][_propID].price = rndProp_[_rID][_propID].price*300/100;
            }
        }
        else if (_propID == 3) {
            require(_eth >= 1 * 10**18 && plyrRnds_[_pID][_rID].hadProp == false && _oID != _pID);
            if(plyrRnds_[_pID][_rID].team == 1)
                rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 2;
            else rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 4;

            if(plyrRnds_[_pID][_rID].incrPRProp == 0) plyrRnds_[_pID][_rID].incrPRProp = 110;
            else    plyrRnds_[_pID][_rID].incrPRProp = plyrRnds_[_pID][_rID].incrPRProp*110/100;
            if(plyr_[_pID].redtProp == 0) plyr_[_pID].redtProp = 99;
            else plyr_[_pID].redtProp = plyr_[_pID].redtProp*99/100;
            if (_oID != 0) {

                if(plyrRnds_[_oID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 2;
                else rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 4;

                plyrRnds_[_oID][_rID].incrPRProp = plyrRnds_[_oID][_rID].incrPRProp*90/100;
                plyr_[_oID].redtProp = plyr_[_oID].redtProp*101/100;

                plyrRnds_[_oID][_rID].hadProp = false;
                plyrRnds_[_oID][_rID].propID = 0;
            }

            rndProp_[_rID][_propID].oID = _pID;
            plyrRnds_[_pID][_rID].hadProp = true;
            plyrRnds_[_pID][_rID].propID = _propID;
            if (_oID == 0) {
                rndProp_[_rID][_propID].price = 1 * 10**18;
                _rstETH = 0;
            }else{
                _rstETH = rndProp_[_rID][_propID].price*200/100;
                rndProp_[_rID][_propID].price = rndProp_[_rID][_propID].price*300/100;
            }
        }
        else if (_propID == 4) {
            require(_eth >= 5 * 10**17 && plyrRnds_[_pID][_rID].hadProp == false && _oID != _pID);
            if(plyrRnds_[_pID][_rID].team == 1)
                rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 1;
            else rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 2;

            if(plyrRnds_[_pID][_rID].redtPRProp == 0) plyrRnds_[_pID][_rID].redtPRProp = 90;
            else    plyrRnds_[_pID][_rID].redtPRProp = plyrRnds_[_pID][_rID].redtPRProp*90/100;

            if(plyr_[_pID].redtProp == 0) plyr_[_pID].redtProp = 99;
            else plyr_[_pID].redtProp = plyr_[_pID].redtProp*995/1000;
            if (_oID != 0) {

                if(plyrRnds_[_oID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 1;
                else rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 2;

                plyrRnds_[_oID][_rID].redtPRProp = plyrRnds_[_oID][_rID].redtPRProp*110/100;
                plyr_[_oID].redtProp = plyr_[_oID].redtProp*1005/1000;

                plyrRnds_[_oID][_rID].hadProp = false;
                plyrRnds_[_oID][_rID].propID = 0;
            }

            rndProp_[_rID][_propID].oID = _pID;
            plyrRnds_[_pID][_rID].hadProp = true;
            plyrRnds_[_pID][_rID].propID = _propID;
            if (_oID == 0) {
                rndProp_[_rID][_propID].price = 5 * 10**17;
                _rstETH = 0;
            }else{
                _rstETH = rndProp_[_rID][_propID].price*250/100;
                rndProp_[_rID][_propID].price = rndProp_[_rID][_propID].price*400/100;
            }
        }
        else if (_propID == 5) {
            require(_eth >= 5 * 10**17 && plyrRnds_[_pID][_rID].hadProp == false && _oID != _pID);
            if(plyrRnds_[_pID][_rID].team == 1)
                rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 1;
            else rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 2;

            if(plyrRnds_[_pID][_rID].incrPRProp == 0) plyrRnds_[_pID][_rID].incrPRProp = 110;
            else    plyrRnds_[_pID][_rID].incrPRProp = plyrRnds_[_pID][_rID].incrPRProp*110/100;
            if(plyr_[_pID].redtProp == 0) plyr_[_pID].redtProp = 99;
            else plyr_[_pID].redtProp = plyr_[_pID].redtProp*995/1000;
            if (_oID != 0) {

                if(plyrRnds_[_oID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 1;
                else rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 2;

                plyrRnds_[_oID][_rID].incrPRProp = plyrRnds_[_oID][_rID].incrPRProp*90/100;
                plyr_[_oID].redtProp = plyr_[_oID].redtProp*1005/1000;

                plyrRnds_[_oID][_rID].hadProp = false;
                plyrRnds_[_oID][_rID].propID = 0;
            }

            rndProp_[_rID][_propID].oID = _pID;
            plyrRnds_[_pID][_rID].hadProp = true;
            plyrRnds_[_pID][_rID].propID = _propID;
            if (_oID == 0) {
                rndProp_[_rID][_propID].price = 5 * 10**17;
                _rstETH = 0;
            }else{
                _rstETH = rndProp_[_rID][_propID].price*250/100;
                rndProp_[_rID][_propID].price = rndProp_[_rID][_propID].price*400/100;
            }
        }
        if(plyrRnds_[_pID][_rID].redtPRProp < 80) plyrRnds_[_pID][_rID].redtPRProp = 80;
        if(plyrRnds_[_pID][_rID].incrPRProp > 120) plyrRnds_[_pID][_rID].incrPRProp = 120;
        if(plyr_[_pID].redtProp < 90) plyr_[_pID].redtProp = 90;

        if(plyrRnds_[_oID][_rID].redtPRProp < 80) plyrRnds_[_oID][_rID].redtPRProp = 80;
        if(plyrRnds_[_oID][_rID].incrPRProp > 120) plyrRnds_[_oID][_rID].incrPRProp = 120;
        if(plyr_[_oID].redtProp < 90) plyr_[_oID].redtProp = 90;
 
      }

      return (_oID,_rstETH);
    }

    function buyLeader(uint256 _pID, uint256 _eth)
    isActivated()
    isHuman()
    public
    returns(uint256,uint256)
    {

        uint256 _rID = rID_;
        uint256 _oID = rndLd_[_rID].oID;
        uint256 _rstETH = 0;

        require(_eth >= 1 * 10**18 && _oID != _pID);
        
        if (_oID == 0) {
            _rstETH = 0;
            rndLd_[_rID].price = 1 * 10**18;
        }
        else{//clean
            if(plyrRnds_[_oID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 4;
            else    rndTmEth_[_rID][plyrRnds_[_oID][_rID].team].winRate -= 8;

            _rstETH = rndLd_[_rID].price*110/100;
            rndLd_[_rID].price = rndLd_[_rID].price*120/100;
        }

        if(plyrRnds_[_pID][_rID].team == 1)
                    rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 4;
        else        rndTmEth_[_rID][plyrRnds_[_pID][_rID].team].winRate += 8;
        round_[_rID].plyr = _pID;
        round_[_rID].team = plyrRnds_[_pID][_rID].team;
        uint256 _team = plyrRnds_[_pID][_rID].team;

        emit F3Devents.onBuyLeader
        (
            msg.sender,
            rndLd_[_rID].price,
            round_[_rID].plyr,
            round_[_rID].team,
            rndTmEth_[_rID][_team].winRate,
            rndTmEth_[_rID][_team].winRate
        );

        return(_oID,_rstETH);
    }
   
    function iWantXKeys(uint256 _keys)
    public
    returns(uint256)
    {



            return ( _keys.ethRec(getBuyPrice()) );
    }
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
    external
    {

        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
        if (plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    function receivePlayerNameList(uint256 _pID, bytes32 _name)
    external
    {

        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    function determinePID()
    private
    {

        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);

            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }

            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;

            plyNum_++;
        }
    }

    function verifyTeam(uint256 _team)
    private
    pure
    returns (uint256)
    {

        if (_team < 1 || _team > 2)
            return(1);
        else
            return(_team);
    }




    
    function endRound()
    private
    returns (uint256)
    {

        uint256 _rID = rID_;

        uint256 _ramNum = F3DKeysCalcLong.random();
        uint256 _winTeam;
        uint256 i;

        for ( i = 1; i <= plyNum_; i++) {

            if (plyrRnds_[i][_rID].incrPRProp > 0) {
                plyrRnds_[i][_rID].cosd = plyrRnds_[i][_rID].cosd.mul(plyrRnds_[i][_rID].incrPRProp).div(100);
                plyrRnds_[i][_rID].cosc = plyrRnds_[i][_rID].cosc.mul(plyrRnds_[i][_rID].incrPRProp).div(100);
            }

            if (plyrRnds_[i][_rID].cosd.add(plyrRnds_[i][_rID].cosc) > threshould_) {
                plyr_[i].rounds++;
                if(plyr_[i].redt1 == 0) plyr_[i].redt1 = 99;
                else plyr_[i].redt1 = plyr_[i].redt1 * 995 / 1000;

                if (plyr_[i].rounds % 4 == 0) {
                    if(plyr_[i].redt3 == 0) plyr_[i].redt3 = 90;
                    else plyr_[i].redt3 = plyr_[i].redt3 * 90 / 100;
                }
                if(plyr_[i].redt1 < 90) plyr_[i].redt1 = 90;
                if(plyr_[i].redt3 < 90) plyr_[i].redt3 = 90;
            }

            emit F3Devents.onEndRoundProssRate
                (
                    msg.sender,
                    plyr_[i].name,
                    plyrRnds_[i][_rID].cosd,
                    plyrRnds_[i][_rID].cosc,
                    plyr_[i].rounds,
                    plyr_[i].redt1,
                    plyr_[i].redt3
                );

        }


        if ( _ramNum <= (rndTmEth_[_rID][1].winRate + 70) )
            _winTeam = 1;
    
        else _winTeam = 2;
        

        prossWinOrLoss(_winTeam);

        round_[_rID].winTeam = _winTeam;

        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);

        return (_winTeam);
    }
 
    function prossWinOrLoss(uint256 _winTeam)
    private
    returns(bool){

        uint256 i;
        uint256 _ttlCosd;
        uint256 _ttlCosc;
        uint256 _rID = rID_;
        uint256 _lossCosd;
        uint256 _lossCosc;

        uint256    _potCosd = rndTmEth_[_rID][1].cosd.add(rndTmEth_[_rID][2].cosd);
        uint256    _potCosc = rndTmEth_[_rID][1].cosc.add(rndTmEth_[_rID][2].cosc);

            plyr_[pIDCom_].cosd = plyr_[pIDCom_].cosd.add(_potCosd * 3 / 100);
            plyr_[pIDCom_].cosc = plyr_[pIDCom_].cosc.add(_potCosc * 3 / 100);

            _potCosd = _potCosd.sub(_potCosd * 97 / 100);
            _potCosc = _potCosc.sub(_potCosd * 97 / 100);

            for ( i = 1; i <= plyNum_; i++) {
                if (i != 0 && plyrRnds_[i][_rID].team == _winTeam) {//赢的队伍
                    _ttlCosd = _ttlCosd.add(plyrRnds_[i][_rID].cosd);
                    _ttlCosc = _ttlCosc.add(plyrRnds_[i][_rID].cosc);
                }
            }

            for ( i=1 ; i <= plyNum_; i++) {
                if (i != 0 && plyrRnds_[i][_rID].team != _winTeam) {//输的
                    _lossCosd = plyrRnds_[i][_rID].cosd;
                    _lossCosc = plyrRnds_[i][_rID].cosc;

                    if (plyrRnds_[i][_rID].redtPRProp > 0) {
                        _lossCosd = _lossCosd*plyrRnds_[i][_rID].redtPRProp/100;
                        _lossCosc = _lossCosc*plyrRnds_[i][_rID].redtPRProp/100;
                    }
                    if (plyr_[i].redt1 > 0) {
                        _lossCosd = _lossCosd*plyr_[i].redt1/100;
                        _lossCosc = _lossCosc*plyr_[i].redt1/100;
                    }
                    if (plyr_[i].redt3 > 0) {
                        _lossCosd = _lossCosd*plyr_[i].redt3/100;
                        _lossCosc = _lossCosc*plyr_[i].redt3/100;
                    }
                    if (plyrRnds_[i][_rID].redtPRFirst > 0) {
                        _lossCosd = _lossCosd.add(plyrRnds_[i][_rID].firstCosd * plyrRnds_[i][_rID].redtPRFirst / 100);
                        _lossCosc = _lossCosc.add(plyrRnds_[i][_rID].firstCosc * plyrRnds_[i][_rID].redtPRFirst / 100);
                    }
                    plyrRnds_[i][_rID].wonCosd = plyrRnds_[i][_rID].cosd.sub(_lossCosd);
                    plyrRnds_[i][_rID].wonCosc = plyrRnds_[i][_rID].cosc.sub(_lossCosc);

                    _potCosd = _potCosd - plyrRnds_[i][_rID].wonCosd;
                    _potCosc = _potCosc - plyrRnds_[i][_rID].wonCosc;

                    plyr_[i].lrnd = _rID;

                    emit F3Devents.onLoss
                    (
                        msg.sender,
                        plyr_[i].name,
                        plyrRnds_[i][_rID].wonCosd,
                        plyrRnds_[i][_rID].wonCosc,
                        plyr_[i].lrnd
                    );
                }
            }

            for ( i=1 ; i <= plyNum_; i++) {
                if (plyrRnds_[i][_rID].team == _winTeam) {//赢的队伍
                    plyrRnds_[i][_rID].wonCosd = plyrRnds_[i][_rID].wonCosd.add(_potCosd.mul(plyrRnds_[i][_rID].cosd).div(_ttlCosd));
                    plyrRnds_[i][_rID].wonCosc = plyrRnds_[i][_rID].wonCosc.add(_potCosc.mul(plyrRnds_[i][_rID].cosc).div(_ttlCosc));
                    plyr_[i].lrnd = _rID;

                    emit F3Devents.onWin
                    (
                        msg.sender,
                        plyr_[i].name,
                        plyrRnds_[i][_rID].wonCosd,
                        plyrRnds_[i][_rID].wonCosc,
                        plyr_[i].lrnd
                    );
                }
            }

            return true;
    }

    function withdrawHoldVault(uint256 _pID)
    public
    returns(bool){

        if (plyr_[_pID].hldVltCosd>0) {
            plyr_[_pID].cosd = plyr_[_pID].cosd.add(plyr_[_pID].hldVltCosd);
            plyr_[_pID].hldVltCosd = 0;
        }

        emit F3Devents.onWithdrawHoldVault
                    (
                        _pID,
                        msg.sender,
                        plyr_[_pID].name,
                        plyr_[_pID].cosd,
                        plyr_[_pID].hldVltCosd
                    );

        return true;
    }

    function withdrawAffVault(uint256 _pID)
    public
    returns(bool){

        if (plyr_[_pID].affVltCosd>0) {
            plyr_[_pID].cosd = plyr_[_pID].cosd.add(plyr_[_pID].affVltCosd);
            plyr_[_pID].affVltCosd = 0;
        }
        if (plyr_[_pID].affVltCosc>0) {
            plyr_[_pID].cosc = plyr_[_pID].cosc.add(plyr_[_pID].affVltCosc);
            plyr_[_pID].affVltCosc = 0;
        }

                emit F3Devents.onWithdrawAffVault
                    (
                        _pID,
                        msg.sender,
                        plyr_[_pID].name,
                        plyr_[_pID].cosd,
                        plyr_[_pID].cosc,
                        plyr_[_pID].affVltCosd,
                        plyr_[_pID].affVltCosc
                    );

        return true;
    }

    function withdrawWonCosFromGame(uint256 _pID, uint256 _affID, uint256 _rID)//一轮只能提取一次
    public
    returns(bool){

        uint256 _aff;
        uint256 _holders;
        uint256 _self;
    
        if (plyrRnds_[_pID][_rID].wonCosd > 0) {

                uint256 _hldCosd;
                for (uint256 i = 1; i <= plyNum_; i++) {
                    if(i!=_pID && plyr_[i].cosd>0) _hldCosd = _hldCosd.add(plyr_[i].cosd);
                }

                _holders = plyrRnds_[_pID][_rID].wonCosd * 5/100;
                _aff =     plyrRnds_[_pID][_rID].wonCosd * 1/100;
                _self = plyrRnds_[_pID][_rID].wonCosd.sub(_holders).sub(_aff);

                plyr_[_pID].cosd = plyr_[_pID].cosd.add(_self);
                plyr_[_affID].affVltCosd = plyr_[_affID].affVltCosd.add(_aff);

                for (uint256 j = 1; j <= plyNum_; j++) {
                    if(j!=_pID && plyr_[j].cosd>0) plyr_[j].hldVltCosd = plyr_[j].hldVltCosd.add(_holders.mul(plyr_[j].cosd).div(_hldCosd));
                }

                plyrRnds_[_pID][_rID].wonCosdRcd = plyrRnds_[_pID][_rID].wonCosd;
                plyrRnds_[_pID][_rID].wonCosd = 0;
        }

        if (plyrRnds_[_pID][_rID].wonCosc > 0) {
            plyr_[_pID].cosc = plyr_[_pID].cosc.add(plyrRnds_[_pID][_rID].wonCosc);

            plyrRnds_[_pID][_rID].wonCoscRcd = plyrRnds_[_pID][_rID].wonCosc;
            plyrRnds_[_pID][_rID].wonCosc = 0;
        }


        return true;
    }

    function transferToAnotherAddr(address _to, uint256 _keys, bytes32 _keyType)
    public
    returns(bool){

        uint256 _holders;
        uint256 _self;
        uint256 i;

        determinePID();
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _tID = pIDxAddr_[_to];

        require(_tID > 0);
    
        if (_keyType == "cosd") {

                require(plyr_[_pID].cosd >= _keys);

                uint256 _hldCosd;
                for ( i = 1; i <= plyNum_; i++) {
                    if(i!=_pID && plyr_[i].cosd>0) _hldCosd = _hldCosd.add(plyr_[i].cosd);
                }

                _holders = _keys * 20/100;
                _self = plyr_[_pID].cosd.sub(_holders);

                plyr_[_tID].cosd = plyr_[_tID].cosd.add(_self);
                plyr_[_pID].cosd = plyr_[_pID].cosd.sub(_self);

                for ( i = 1; i <= plyNum_; i++) {
                    if(i!=_pID && plyr_[i].cosd>0) plyr_[i].hldVltCosd = plyr_[i].hldVltCosd.add(_holders.mul(plyr_[i].cosd).div(_hldCosd));
                }
        }

        else{
            require(plyr_[_pID].cosc >= _keys);

            plyr_[_tID].cosc = plyr_[_tID].cosc.add(_keys);
            plyr_[_pID].cosc = plyr_[_pID].cosc.sub(_keys);
        }


        return true;
    }
    
    bool public activated_ = false;
    function activate()
    public onlyOwner {


        require(activated_ == false, "fomo3d already activated");

        activated_ = true;

        rID_ = 1;
        round_[1].strt = now;
        round_[1].end = now + rndInit_;
    }
}

library F3Ddatasets {

    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 cosd;    // winnings vault
        uint256 cosc;    // winnings vault
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
        uint256 rounds; //超过xxxcosd的轮数累计
        uint256 redtProp; //买道具赠送的累计亏损减少率
        uint256 redt1;
        uint256 redt3;
        uint256 affVltCosd;
        uint256 affVltCosc;
        uint256 hldVltCosd;
    }
    struct PlayerRounds {
        uint256 cosd;   // keys
        uint256 cosc;   // keys
        bool hadProp;
        uint256 propID;
        uint256 redtPRProp; //lossReductionRate，玩家当前回合道具总亏损减少率
        uint256 incrPRProp; //Income increase rate收入增加率
        uint256 team;
        bool first;
        uint256 firstCosd;//第一阶段投入的COS资金，可减少20% 亏损率
        uint256 firstCosc;//第一阶段投入的COS资金，可减少20% 亏损率
        uint256 redtPRFirst;
        uint256 wonCosd;
        uint256 wonCosc;
        uint256 wonCosdRcd;
        uint256 wonCoscRcd;
    }
    struct Round {
        uint256 plyr;   // pID of player in lead
        uint256 team;   // tID of team in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 cosd;   // keys
        uint256 cosc;   // keys
        uint256 winTeam;
    }     
    struct Team {
        uint256 teamID;        
        uint256 winRate;    // 胜率
        uint256 eth;
        uint256 cosd;
        uint256 cosc;
    }
    struct Prop {           //道具
        uint256 propID;         
        uint256 price;
        uint256 oID;
    }
    struct Leader {           //道具       
        uint256 price;
        uint256 oID;
    }
    struct Fee {
        uint256 aff;          // % of buy in thats paid to referrer  of current round推荐人分配比例
        uint256 com;    // % of buy in thats paid for comnunity
        uint256 holders; //key holders
    }
}

library F3DKeysCalcLong {

    using SafeMath for *;

    function keysRec(uint256 _newEth, uint256 _price)
    internal
    pure
    returns (uint256)
    {

        return( keys(_newEth, _price) );
    }

    function ethRec(uint256 _sellKeys, uint256 _price)
    internal
    pure
    returns (uint256)
    {

        return ( eth(_sellKeys, _price) );
    }

    function keys(uint256 _eth, uint256 _price)
    internal
    pure
    returns(uint256)
    {

        uint256 _rstAmount;

        while(_eth >= _price){
            _eth = _eth - _price;
            _price = _price + _price*3/10000;
            _rstAmount++;
        }

        return _rstAmount;
    }

    function eth(uint256 _keys, uint256 _price)
    internal
    pure
    returns(uint256)
    {

        uint256 _eth = 0;

        while(_keys > 0){
            _eth = _eth + _price;
            _price = _price - _price*3/10000;
            _keys--;
        }

        return _eth;
    }

    function random() internal pure returns (uint256) {

       uint ranNum = uint(keccak256(msg.data)) % 100;
       return ranNum;
   }
}

contract FoMo3DProxy {

    FoMo3DLongInterface  private foMo3DLong = FoMo3DLongInterface(this);

    string constant public name = "FoMo3D Proxy";
    string constant public symbol = "F3DP";

    constructor()
    public
    {

    }

    function _buyXid(uint256 _affCode, uint256 _eth, bytes32 _keyType) public returns(uint256){

        return foMo3DLong.buyXid(_affCode, _eth, _keyType);
    }
    function _buyXaddr(address _affCode, uint256 _eth, bytes32 _keyType) public returns(uint256){

        return foMo3DLong.buyXaddr(_affCode,  _eth, _keyType);
    }


    function _registerNameXid(string memory _nameString, uint256 _affCode, bool _all) public{

        foMo3DLong.registerNameXid(_nameString, _affCode, _all);
    }
    function _registerNameXaddr(string memory _nameString, address _affCode, bool _all) public{

        foMo3DLong.registerNameXaddr(_nameString, _affCode, _all);
    }

    
    function _getBuyPrice() public returns(uint256){

        return foMo3DLong.getBuyPrice();
    }
    function _getTimeLeft() public returns(uint256){

        return foMo3DLong.getTimeLeft();
    }

    function _getCurrentRoundInfo() public returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){

        return foMo3DLong.getCurrentRoundInfo();
    }
    function _getPlayerInfoByAddress(address _addr) public returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){

        return foMo3DLong.getPlayerInfoByAddress(_addr);
    }
    function _getCurrentRoundTeamCos() public view returns(uint256,uint256,uint256,uint256){

        return foMo3DLong.getCurrentRoundTeamCos();
    }
    
    function _sellKeys(uint256 _pID_, uint256 _keys_, bytes32 _keyType) public returns(uint256){

        return foMo3DLong.sellKeys(_pID_, _keys_, _keyType);
    }
    function _playGame(uint256 _pID, uint256 _keys, uint256 _team, bytes32 _keyType) public returns(bool,bool){

        return foMo3DLong.playGame(_pID, _keys, _team, _keyType);
    }

    function _buyProp(uint256 _pID, uint256 _eth, uint256 _propID) public returns(uint256,uint256){

        return foMo3DLong.buyProp(_pID, _eth,_propID);
    }
    function _buyLeader(uint256 _pID, uint256 _eth) public returns(uint256,uint256){

        return foMo3DLong.buyLeader(_pID, _eth);
    }
    function _iWantXKeys(uint256 _keys) public returns(uint256){

        return foMo3DLong.iWantXKeys(_keys);
    }
    
    function _withdrawHoldVault(uint256 _pID) public returns(bool){

        return foMo3DLong.withdrawHoldVault(_pID);
    }
    function _withdrawAffVault(uint256 _pID) public returns(bool){

        return foMo3DLong.withdrawAffVault(_pID);
    }

    function _withdrawWonCosFromGame(uint256 _pID, uint256 _affID, uint256 _rID) public returns(bool){

        return foMo3DLong.withdrawWonCosFromGame(_pID, _affID, _rID);
    }

    function _transferToAnotherAddr(address _to, uint256 _keys, bytes32 _keyType) public returns(bool){

        return foMo3DLong.transferToAnotherAddr(_to, _keys, _keyType);
    }

    function _activate() public{

        foMo3DLong.activate();
    }

}