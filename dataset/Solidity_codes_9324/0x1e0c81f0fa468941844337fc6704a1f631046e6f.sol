
pragma solidity ^0.4.24;


contract F3Devents {

    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 amountPaid,
        uint256 timeStamp
    );
    
    event onEndTx
    (
        uint256 compressedData,     
        uint256 compressedIDs,      
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 devAmount,
        uint256 genAmount,
        uint256 potAmount
    );
    
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
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
        uint256 amountWon,
        uint256 devAmount,
        uint256 genAmount
    );
    
    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 devAmount,
        uint256 genAmount
    );
    
    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 devAmount,
        uint256 genAmount
    );
}


contract modularLong is F3Devents {}


contract F3Dx is modularLong {

    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;

    address constant private AwardPool = 0xb14D7b0ec631Daf0cF02d69860974df04987a9f8;
    address constant private DeveloperRewards = 0xb14D7b0ec631Daf0cF02d69860974df04987a9f8;
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xdAc532cA5598Ee19a2dfC1244c7608C766c6C415);
    string constant public name = "FoMo3D X";
    string constant public symbol = "F3Dx";
    uint256 constant private rndInit_ = 1 hours;                // round timer starts at this
    uint256 constant private rndInc_ = 30 seconds;              // every full key purchased adds this much to the timer
    uint256 constant private rndMax_ = 8 hours;                // max length a round timer can be
    uint256 public rID_;    // round id number / total rounds that have happened
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => F3Ddatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amongst any name you own)
    mapping (uint256 => F3Ddatasets.Round) public round_;   // (rID => data) round data
    F3Ddatasets.KeyFee public fees_;          // fee distribution by holder
    F3Ddatasets.PotSplit public potSplit_;     // fees pot split distribution
    constructor()
        public
    {

        fees_ = F3Ddatasets.KeyFee(50,10);   //40% to pot, 50% to key holder, 10% to dev reward
        
        potSplit_ = F3Ddatasets.PotSplit(40,10);  //40% to offcial then transfer to winner, 10% to dev reward, 50% to official
    }
    modifier isActivated() {

        require(activated_ == true, "its not ready yet."); 
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
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;    
    }
    
    function()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
            
        uint256 _pID = pIDxAddr_[msg.sender];
        
        buyCore(_pID, _eventData_);
    }
    
    function buyXid()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {

        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        buyCore(_pID, _eventData_);
    }
    
    function buyXaddr()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {

        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        buyCore(_pID, _eventData_);
    }
    
    function buyXname()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {

        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        buyCore(_pID, _eventData_);
    }
    
    function reLoadXid(uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {

        F3Ddatasets.EventReturns memory _eventData_;
        
        uint256 _pID = pIDxAddr_[msg.sender];

        reLoadCore(_pID, _eth, _eventData_);
    }
    
    function reLoadXaddr(uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {

        F3Ddatasets.EventReturns memory _eventData_;
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        reLoadCore(_pID, _eth, _eventData_);
    }
    
    function reLoadXname(uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {

        F3Ddatasets.EventReturns memory _eventData_;
        
        uint256 _pID = pIDxAddr_[msg.sender];
    
        reLoadCore(_pID, _eth, _eventData_);
    }

    function withdraw()
        isActivated()
        isHuman()
        public
    {

        uint256 _rID = rID_;
        
        uint256 _now = now;
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        uint256 _eth;
        
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            F3Ddatasets.EventReturns memory _eventData_;
            
	        round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            
            _eth = withdrawEarnings(_pID);
            
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);    
            
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            
            emit F3Devents.onWithdrawAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eth, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.devAmount, 
                _eventData_.genAmount
            );
            
        } else {
            _eth = withdrawEarnings(_pID);
            
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
            
            emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }
    
    function registerNameXID(string _nameString, bool _all)
        isHuman()
        public
        payable
    {

        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        bool _isNewPlayer = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _all);
        
        uint256 _pID = pIDxAddr_[_addr];
        
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _paid, now);
    }
    
    function registerNameXaddr(string _nameString, bool _all)
        isHuman()
        public
        payable
    {

        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        bool _isNewPlayer = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _all);
        
        uint256 _pID = pIDxAddr_[_addr];
        
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _paid, now);
    }
    
    function registerNameXname(string _nameString, bool _all)
        isHuman()
        public
        payable
    {

        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        bool _isNewPlayer = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _all);
        
        uint256 _pID = pIDxAddr_[_addr];
        
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _paid, now);
    }
    function getBuyPrice()
        public 
        view 
        returns(uint256)
    {  

        uint256 _rID = rID_;
        
        uint256 _now = now;
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else // rounds over.  need price for new round
            return ( 75000000000000 ); // init
    }
    
    function getTimeLeft()
        public
        view
        returns(uint256)
    {

        uint256 _rID = rID_;
        
        uint256 _now = now;
        
        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt).sub(_now) );
        else
            return(0);
    }
    
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256)
    {

        uint256 _rID = rID_;
        
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  )
            );
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd))
            );
        }
    }
    
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
        private
        view
        returns(uint256)
    {

        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(50)).div(100)).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }
    
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32)
    {

        uint256 _rID = rID_;
        
        return
        (
            round_[_rID].ico,               //0
            _rID,                           //1
            round_[_rID].keys,              //2
            round_[_rID].end,               //3
            round_[_rID].strt,              //4
            round_[_rID].pot,               //5
            (round_[_rID].plyr * 10),     //6
            plyr_[round_[_rID].plyr].addr,  //7
            plyr_[round_[_rID].plyr].name  //8
        );
    }

    function getPlayerInfoByAddress(address _addr)
        public 
        view 
        returns(uint256, bytes32, uint256, uint256, uint256, uint256)
    {

        uint256 _rID = rID_;
        
        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        
        return
        (
            _pID,                               //0
            plyr_[_pID].name,                   //1
            plyrRnds_[_pID][_rID].keys,         //2
            plyr_[_pID].win,                    //3
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       //4
            plyrRnds_[_pID][_rID].eth           //5
        );
    }

    function buyCore(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
        private
    {

        uint256 _rID = rID_;
        
        uint256 _now = now;
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            core(_rID, _pID, msg.value, _eventData_);
        
        } else {
            if (_now > round_[_rID].end && round_[_rID].ended == false) 
            {
			    round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);
                
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
                
                emit F3Devents.onBuyAndDistribute
                (
                    msg.sender, 
                    plyr_[_pID].name, 
                    msg.value, 
                    _eventData_.compressedData, 
                    _eventData_.compressedIDs, 
                    _eventData_.winnerAddr, 
                    _eventData_.winnerName, 
                    _eventData_.amountWon, 
                    _eventData_.devAmount, 
                    _eventData_.genAmount
                );
            }
            
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }
    
    function reLoadCore(uint256 _pID, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
        private
    {

        uint256 _rID = rID_;
        
        uint256 _now = now;
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            
            core(_rID, _pID, _eth, _eventData_);
        
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
                
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
                
            emit F3Devents.onReLoadAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.devAmount, 
                _eventData_.genAmount
            );
        }
    }
    
    function core(uint256 _rID, uint256 _pID, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
        private
    {

        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);
        
        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
        {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }
        
        if (_eth > 1000000000) 
        {
            
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);
            
            if (_keys >= 1000000000000000000)
            {
            updateTimer(_keys, _rID);

            if (round_[_rID].plyr != _pID)
                round_[_rID].plyr = _pID;
            
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }
            
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
            
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
    
            _eventData_ = distributeExternal(_eth, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _keys, _eventData_);
            
		    endTx(_pID, _eth, _keys, _eventData_);
        }
    }
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {   

        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }
    
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {

        uint256 _now = now;
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else // rounds over.  need keys for new round
            return ( (_eth).keys() );
    }
    
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {

        uint256 _rID = rID_;
        
        uint256 _now = now;
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else // rounds over.  need price for new round
            return ( (_keys).eth() );
    }
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name)
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
        
    function determinePID(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {

        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
            
            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }
            
            _eventData_.compressedData = _eventData_.compressedData + 1;
        } 
        return (_eventData_);
    }
    
    function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {

        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);
            
        plyr_[_pID].lrnd = rID_;
            
        _eventData_.compressedData = _eventData_.compressedData + 10;
        
        return(_eventData_);
    }
    
    function endRound(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {

        uint256 _rID = rID_;
        
        uint256 _winPID = round_[_rID].plyr;
        
        uint256 _pot = round_[_rID].pot;
        
        uint256 _win = (_pot.mul(potSplit_.win)).div(100); // 40% to winner
        uint256 _dev = (_pot.mul(potSplit_.dev)).div(100); // 10% to dev rewards
        _pot = (_pot.sub(_win)).sub(_dev); // calc remaining amount to pot

        AwardPool.transfer(_win);

        DeveloperRewards.transfer(_dev);

        AwardPool.transfer(_pot);

        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.potAmount = _pot;
        _eventData_.devAmount = _dev;
        
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_);
        
        return(_eventData_);
    }
    
    function updateGenVault(uint256 _pID, uint256 _rIDlast)
        private 
    {

        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }
    
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {

        uint256 _now = now;
        
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

    function distributeExternal(uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {

        uint256 _dev = (_eth.mul(fees_.dev)).div(100);
        
        DeveloperRewards.transfer(_dev);

        _eventData_.devAmount = _dev.add(_eventData_.devAmount);
        
        return(_eventData_);
    }
    
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {

        uint256 _gen = (_eth.mul(fees_.gen)).div(100);
        
        _eth = _eth.sub((_eth.mul(fees_.dev)).div(100));
        
        uint256 _pot = _eth.sub(_gen);
        
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        
        return(_eventData_);
    }

    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {


        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
            
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }
    
    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {

        updateGenVault(_pID, plyr_[_pID].lrnd);
        
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
        }

        return(_earnings);
    }
    
    function endTx(uint256 _pID, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
    {

        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
        
        emit F3Devents.onEndTx
        (
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.devAmount,
            _eventData_.genAmount,
            _eventData_.potAmount
        );
    }
    bool public activated_ = false;
    function activate()
        public
    {

        require(msg.sender == 0x4a1061afb0af7d9f6c2d545ada068da68052c060, "only team can activate");
        
        require(activated_ == false, "fomo3dx already activated");
        
        activated_ = true;
        
		rID_ = 1;
        round_[1].strt = now;
        round_[1].end = now + rndInit_;
    }
}

library F3Ddatasets {

    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // winner address
        bytes32 winnerName;         // winner name
        uint256 amountWon;          // amount won
        uint256 devAmount;          // amount distributed to dev
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
    }
    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 lrnd;   // last round played
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 mask;   // player mask 
        uint256 ico;    // ICO phase investment
    }
    struct Round {
        uint256 plyr;   // pID of player in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
        uint256 ico;    // total eth sent in during ICO phase
        uint256 icoGen; // total eth for gen during ICO phase
        uint256 icoAvg; // average key price for ICO phase
    }
    struct KeyFee {
        uint256 gen;    // % of buy in thats paid to key holders of current round
        uint256 dev;    // % of buy in thats paid to develper
    }
    struct PotSplit {
        uint256 win;    // % of pot thats paid to winner of current round
        uint256 dev;    // % of pot thats paid to developer
    }
}

library F3DKeysCalcLong {

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

        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }
    
    function eth(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {

        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

interface PlayerBookInterface {

    function getPlayerID(address _addr) external returns (uint256);

    function getPlayerName(uint256 _pID) external view returns (bytes32);

    function getPlayerAddr(uint256 _pID) external view returns (address);

    function getNameFee() external view returns (uint256);

    function registerNameXIDFromDapp(address _addr, bytes32 _name, bool _all) external payable returns(bool);

    function registerNameXaddrFromDapp(address _addr, bytes32 _name, bool _all) external payable returns(bool);

    function registerNameXnameFromDapp(address _addr, bytes32 _name, bool _all) external payable returns(bool);

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}