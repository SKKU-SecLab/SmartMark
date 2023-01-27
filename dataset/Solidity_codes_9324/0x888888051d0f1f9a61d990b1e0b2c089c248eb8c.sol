
pragma solidity ^0.4.24;



interface OldCitizenInterface {

    function getTotalChild(address _address) public view returns(uint256);

    function getAddressById(uint256 _id) public view returns (address);

    function getAddressByUserName(string _username) public view returns (address);

    function exist(string _username) public view returns (bool);

    function getId(address _address) public view returns (uint256);

    function getUsername(address _address) public view returns (string);

    function getUintUsername(address _address) public view returns (uint256);

    function getRef(address _address) public view returns (address);

    function getRefTo(address _address) public view returns (address[]);

    function getRefToById(address _address, uint256 _id) public view returns (address, string memory, uint256, uint256, uint256, uint256);

    function getRefToLength(address _address) public view returns (uint256);

    function getLevelCitizenLength(uint256 _level) public view returns (uint256);

    function getLevelCitizenById(uint256 _level, uint256 _id) public view returns (address);

    function getCitizenLevel(address _address) public view returns (uint256);

    function getLastLevel() public view returns(uint256);

}

contract Citizen {

    using SafeMath for uint256;

    event Register(address indexed _member, address indexed _ref);

    modifier withdrawRight(){

        require((msg.sender == address(bankContract)), "Bank only");
        _;
    }

    modifier onlyAdmin() {

        require(msg.sender == devTeam, "admin required");
        _;
    }

    modifier notRegistered(){

        require(!isCitizen[msg.sender], "already exist");
        _;
    }

    modifier registered(){

        require(isCitizen[msg.sender], "must be a citizen");
        _;
    }

    struct Profile{
        uint256 id;
        uint256 username;
        uint256 refWallet;
        address ref;
        address[] refTo;
        uint256 totalChild;
        uint256 donated;
        uint256 treeLevel;
        uint256 totalSale;
        uint256 allRoundRefIncome;
        mapping(uint256 => uint256) roundRefIncome;
        mapping(uint256 => uint256) roundRefWallet;
    }

    mapping (address => Profile) public citizen;
    mapping (address => bool) public isCitizen;
    mapping (uint256 => address) public idAddress;
    mapping (uint256 => address) public usernameAddress;

    mapping (uint256 => address[]) levelCitizen;

    BankInterface public bankContract;
    LotteryInterface public lotteryContract;
    F2mInterface public f2mContract;
    OldCitizenInterface public oldCitizenContract;
    address public devTeam;
    address public oldDevTeam;

    uint256 citizenNr;
    uint256 lastLevel;

    mapping(uint256 => uint256) public totalRefByRound;
    uint256 public totalRefAllround;

    constructor (address _devTeam)
        public
    {
        DevTeamInterface(_devTeam).setCitizenAddress(address(this));
        devTeam = _devTeam;

        oldDevTeam = 0x96504e1f83e380984b1d4eccc0e8b9f0559b2ad2;
        oldCitizenContract = OldCitizenInterface(0xd7657bdf782f43ba7f5f5e8456b481616e636ae9);
    }

    function joinNetwork(address[6] _contract)
        public
    {

        require(address(lotteryContract) == 0,"already setup");
        f2mContract = F2mInterface(_contract[0]);
        bankContract = BankInterface(_contract[1]);
        lotteryContract = LotteryInterface(_contract[3]);
    }


    function pushRefIncome(address _sender)
        public
        payable
    {

        uint256 curRoundId = lotteryContract.getCurRoundId();
        uint256 _amount = msg.value;
        address sender = _sender;
        address ref = getRef(sender);
        citizen[sender].totalSale += _amount;
        totalRefAllround += _amount;
        totalRefByRound[curRoundId] += _amount;
        while (sender != devTeam) {
            _amount = _amount / 2;
            citizen[ref].refWallet = _amount.add(citizen[ref].refWallet);
            citizen[ref].roundRefIncome[curRoundId] += _amount;
            citizen[ref].allRoundRefIncome += _amount;
            sender = ref;
            ref = getRef(sender);
        }
        citizen[sender].refWallet = _amount.add(citizen[ref].refWallet);
        citizen[sender].roundRefIncome[curRoundId] += _amount;
        citizen[sender].allRoundRefIncome += _amount;
    }

    function withdrawFor(address sender) 
        public
        withdrawRight()
        returns(uint256)
    {

        uint256 amount = citizen[sender].refWallet;
        if (amount == 0) return 0;
        citizen[sender].refWallet = 0;
        bankContract.pushToBank.value(amount)(sender);
        return amount;
    }

    function devTeamWithdraw()
        public
        onlyAdmin()
    {

        uint256 _amount = citizen[devTeam].refWallet;
        if (_amount == 0) return;
        devTeam.transfer(_amount);
        citizen[devTeam].refWallet = 0;
    }

    function devTeamReinvest()
        public
        returns(uint256)
    {

        address sender = msg.sender;
        require(sender == address(f2mContract), "only f2m contract");
        uint256 _amount = citizen[devTeam].refWallet;
        citizen[devTeam].refWallet = 0;
        address(f2mContract).transfer(_amount);
        return _amount;
    }

    function sleep()
        public
        onlyAdmin()
    {

        bool _isLastRound = lotteryContract.isLastRound();
        require(_isLastRound, "too early");
        uint256 _ethAmount = address(this).balance;
        devTeam.transfer(_ethAmount);
    }


    function getTotalChild(address _address)
        public
        view
        returns(uint256)
    {

        return _address == devTeam ? oldCitizenContract.getTotalChild(oldDevTeam) : oldCitizenContract.getTotalChild(_address);
    }

    function getAllRoundRefIncome(address _address)
        public
        view
        returns(uint256)
    {

        return citizen[_address].allRoundRefIncome;
    }

    function getRoundRefIncome(address _address, uint256 _rId)
        public
        view
        returns(uint256)
    {

        return citizen[_address].roundRefIncome[_rId];
    }

    function getRefWallet(address _address)
        public
        view
        returns(uint256)
    {

        return citizen[_address].refWallet;
    }

    function getAddressById(uint256 _id)
        public
        view
        returns (address)
    {

        return oldCitizenContract.getAddressById(_id);
    }

    function getAddressByUserName(string _username)
        public
        view
        returns (address)
    {

        return oldCitizenContract.getAddressByUserName(_username);
    }

    function exist(string _username)
        public
        view
        returns (bool)
    {

        return oldCitizenContract.exist(_username);
    }

    function getId(address _address)
        public
        view
        returns (uint256)
    {

        return oldCitizenContract.getId(_address);
    }

    function getUsername(address _address)
        public
        view
        returns (string)
    {

        return oldCitizenContract.getUsername(_address);
    }

    function getRef(address _address)
        public
        view
        returns (address)
    {

        address _ref = oldCitizenContract.getRef(_address);
        return _ref == oldDevTeam ? devTeam : _ref;
    }

    function getRefTo(address _address)
        public
        view
        returns (address[])
    {

        return oldCitizenContract.getRefTo(_address);
    }

    function getRefToById(address _address, uint256 _id)
        public
        view
        returns (address, string, uint256, uint256, uint256, uint256)
    {

        address _refTo;
        string memory _username;
        uint256 _treeLevel;
        uint256 _refToLength;
        uint256 _refWallet;
        uint256 _totalSale;
        (_refTo, _username, _treeLevel, _refToLength, _refWallet, _totalSale) = oldCitizenContract.getRefToById(_address, _id);
        return (
            _refTo,
            _username,
            _treeLevel,
            _refToLength,
            citizen[_refTo].refWallet,
            citizen[_refTo].totalSale
            );
    }

    function getRefToLength(address _address)
        public
        view
        returns (uint256)
    {

        return oldCitizenContract.getRefToLength(_address);
    }

    function getLevelCitizenLength(uint256 _level)
        public
        view
        returns (uint256)
    {

        return oldCitizenContract.getLevelCitizenLength(_level);
    }

    function getLevelCitizenById(uint256 _level, uint256 _id)
        public
        view
        returns (address)
    {

        return oldCitizenContract.getLevelCitizenById(_level, _id);
    }

    function getCitizenLevel(address _address)
        public
        view
        returns (uint256)
    {

        return oldCitizenContract.getCitizenLevel(_address);
    }

    function getLastLevel()
        public
        view
        returns(uint256)
    {

        return oldCitizenContract.getLastLevel();
    }
}

library Helper {

    using SafeMath for uint256;

    uint256 constant public ZOOM = 1000;
    uint256 constant public SDIVIDER = 3450000;
    uint256 constant public PDIVIDER = 3450000;
    uint256 constant public RDIVIDER = 1580000;
    uint256 constant public SLP = 0.002 ether;
    uint256 constant public SAT = 30; // seconds
    uint256 constant public PN = 777;
    uint256 constant public PBASE = 13;
    uint256 constant public PMULTI = 26;
    uint256 constant public LBase = 1;

    uint256 constant public ONE_HOUR = 3600;
    uint256 constant public ONE_DAY = 24 * ONE_HOUR;
    uint256 constant public TIMEOUT1 = 12 * ONE_HOUR;
    uint256 constant public TIMEOUT2 = 7 * ONE_DAY;
    
    function bytes32ToString (bytes32 data)
        public
        pure
        returns (string) 
    {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }
    
    function uintToBytes32(uint256 n)
        public
        pure
        returns (bytes32) 
    {

        return bytes32(n);
    }
    
    function bytes32ToUint(bytes32 n) 
        public
        pure
        returns (uint256) 
    {

        return uint256(n);
    }
    
    function stringToBytes32(string memory source) 
        public
        pure
        returns (bytes32 result) 
    {

        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function stringToUint(string memory source) 
        public
        pure
        returns (uint256)
    {

        return bytes32ToUint(stringToBytes32(source));
    }
    
    function uintToString(uint256 _uint) 
        public
        pure
        returns (string)
    {

        return bytes32ToString(uintToBytes32(_uint));
    }

    function validUsername(string _username)
        public
        pure
        returns(bool)
    {

        uint256 len = bytes(_username).length;
        if ((len < 4) || (len > 18)) return false;
        if (bytes(_username)[len-1] == 32) return false;
        return uint256(bytes(_username)[0]) != 48;
    }


    function getAddedTime(uint256 _rTicketSum, uint256 _tAmount)
        public
        pure
        returns (uint256)
    {

        uint256 base = (_rTicketSum + 1).mul(10000) / SDIVIDER;
        uint256 expo = base;
        expo = expo.mul(expo).mul(expo); // ^3
        expo = expo.mul(expo); // ^6
        expo = expo / (10**24);

        if (expo > SAT) return 0;
        return (SAT - expo).mul(_tAmount);
    }

    function getNewEndTime(uint256 toAddTime, uint256 slideEndTime, uint256 fixedEndTime)
        public
        view
        returns(uint256)
    {

        uint256 _slideEndTime = (slideEndTime).add(toAddTime);
        uint256 timeout = _slideEndTime.sub(block.timestamp);
        if (timeout > TIMEOUT1) timeout = TIMEOUT1;
        _slideEndTime = (block.timestamp).add(timeout);
        if (_slideEndTime > fixedEndTime)  return fixedEndTime;
        return _slideEndTime;
    }

    function getRandom(uint256 _seed, uint256 _range)
        public
        pure
        returns(uint256)
    {

        if (_range == 0) return _seed;
        return (_seed % _range) + 1;
    }


    function getEarlyIncomeMul(uint256 _ticketSum)
        public
        pure
        returns(uint256)
    {

        uint256 base = _ticketSum * ZOOM / RDIVIDER;
        uint256 expo = base.mul(base).mul(base); //^3
        expo = expo.mul(expo) / (ZOOM**6); //^6
        return (1 + PBASE / (1 + expo.mul(PMULTI)));
    }

    function getTAmount(uint256 _ethAmount, uint256 _ticketSum) 
        public
        pure
        returns(uint256)
    {

        uint256 _tPrice = getTPrice(_ticketSum);
        return _ethAmount.div(_tPrice);
    }

    function isGoldenMin(
        uint256 _slideEndTime
        )
        public
        view
        returns(bool)
    {

        uint256 _restTime1 = _slideEndTime.sub(block.timestamp);
        if (_restTime1 > 6 hours) return false;
        uint256 _min = (block.timestamp / 60) % 60;
        return _min == 8;
    }

    function getTMul(
        uint256 _initGrandPot,
        uint256 _grandPot, 
        uint256 _slideEndTime, 
        uint256 _fixedEndTime
        )
        public
        view
        returns(uint256)
    {

        uint256 _pZoom = 100;
        uint256 base = _initGrandPot != 0 ?_pZoom.mul(_grandPot) / _initGrandPot : _pZoom;
        uint256 expo = base.mul(base);
        uint256 _timer1 = _slideEndTime.sub(block.timestamp) / 1 hours; // 0.. 11
        uint256 _timer2 = _fixedEndTime.sub(block.timestamp) / 1 days; // 0 .. 6
        uint256 x = (_pZoom * (11 - _timer1) / 4) + _pZoom; // [1, 3.75]
        uint256 y = (_pZoom * (6 - _timer2) / 3) + _pZoom; // [1, 3]
        uint256 z = isGoldenMin(_slideEndTime) ? 4 : 1;
        uint256 res = expo.mul(x).mul(y).mul(z) / (_pZoom ** 3); // ~ [1, 90]
        return res;
    }

    function getTPrice(uint256 _ticketSum)
        public
        pure
        returns(uint256)
    {

        uint256 base = (_ticketSum + 1).mul(ZOOM) / PDIVIDER;
        uint256 expo = base;
        expo = expo.mul(expo).mul(expo); // ^3
        expo = expo.mul(expo); // ^6
        uint256 tPrice = SLP + expo / PN;
        return tPrice;
    }

    function getWeightRange(uint256 initGrandPot)
        public
        pure
        returns(uint256)
    {

        uint256 avgMul = 30;
        return ((initGrandPot * 2 * 100 / 68) * avgMul / SLP) + 1000;
    }

    function isJackpot(
        uint256 _seed,
        uint256 _RATE,
        uint256 _MIN,
        uint256 _ethAmount
        )
        public
        pure
        returns(bool)
    {

        uint256 k = _ethAmount / _MIN;
        if (k == 0) return false;
        uint256 _loseCap = _RATE / 2;
        if (_RATE > k + _loseCap) _loseCap = _RATE - k;

        bool _lose = (_seed % _RATE) < _loseCap;
        return !_lose;
    }
}

interface DevTeamInterface {

    function setF2mAddress(address _address) public;

    function setLotteryAddress(address _address) public;

    function setCitizenAddress(address _address) public;

    function setBankAddress(address _address) public;

    function setRewardAddress(address _address) public;

    function setWhitelistAddress(address _address) public;


    function setupNetwork() public;

}

interface BankInterface {

    function joinNetwork(address[6] _contract) public;

    function pushToBank(address _player) public payable;

}

interface LotteryInterface {

    function joinNetwork(address[6] _contract) public;

    function activeFirstRound() public;

    function pushToPot() public payable;

    function finalizeable() public view returns(bool);

    function finalize() public;

    function buy(string _sSalt) public payable;

    function buyFor(string _sSalt, address _sender) public payable;

    function withdrawFor(address _sender) public returns(uint256);


    function getRewardBalance(address _buyer) public view returns(uint256);

    function getTotalPot() public view returns(uint256);

    function getEarlyIncomeByAddress(address _buyer) public view returns(uint256);

    function getCurEarlyIncomeByAddress(address _buyer) public view returns(uint256);

    function getCurRoundId() public view returns(uint256);

    function setLastRound(uint256 _lastRoundId) public;

    function getPInvestedSumByRound(uint256 _rId, address _buyer) public view returns(uint256);

    function cashoutable(address _address) public view returns(bool);

    function isLastRound() public view returns(bool);

    function sBountyClaim(address _sBountyHunter) public returns(uint256);

}

interface F2mInterface {

    function joinNetwork(address[6] _contract) public;

    function activeBuy() public;

    function pushDividends() public payable;

    function buyFor(address _buyer) public payable;

    function sell(uint256 _tokenAmount) public;

    function exit() public;

    function devTeamWithdraw() public returns(uint256);

    function withdrawFor(address sender) public returns(uint256);

    function transfer(address _to, uint256 _tokenAmount) public returns(bool);

    function setAutoBuy() public;

    function ethBalance(address _address) public view returns(uint256);

    function myBalance() public view returns(uint256);

    function myEthBalance() public view returns(uint256);


    function swapToken() public;

    function setNewToken(address _newTokenAddress) public;

}

library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}