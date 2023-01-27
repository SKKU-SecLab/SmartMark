

pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.16;


contract OwnableUpgradable is Initializable {

    address payable public owner;
    address payable internal newOwnerCandidate;

    function initialize() public initializer {

        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Permission denied");
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {

        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {

        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.16;




contract AdminableUpgradable is Initializable, OwnableUpgradable {

    mapping(address => bool) public admins;


    modifier onlyOwnerOrAdmin {

        require(msg.sender == owner ||
                admins[msg.sender], "Permission denied");
        _;
    }


    function initialize() public initializer {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }


    function setAdminPermission(address _admin, bool _status) public onlyOwner {

        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }


    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {

        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

}


pragma solidity ^0.5.16;





contract AffiliateProgram is Initializable, DSMath, AdminableUpgradable {


    struct LevelProgram {
        uint8 percent;
        uint80 ethAmount;
    }

    struct Partner {
        address partnerAddr;        //  address of the partner
        uint8 level;                //  Aff Program level

        uint80 profit;              //  partner's current profit
        uint80 referralsCount;      //  partner's referrals count
        uint80 referralsEthValue;   //  eth invested by partner's referrals
    }


    uint256 public constant LEVEL_COUNTER = 3;


    mapping(uint8 => LevelProgram) public levels;

    mapping(bytes32 => Partner) public codeToPartner;
    mapping(address => bytes32) public partnerToCode;

    mapping(address => bool) public permissionAddresses;

    mapping(address => address) internal referralToReferrer;



    event PartnerAdded(address indexed partner, uint8 level, bytes32 code);

    event ReferralAdded(address indexed referral, bytes32 code);

    event ProfitDistributed(bytes32 indexed code, uint256 profit);

    event ProfitWithdrawn(address indexed partner, uint256 profit);



    modifier needPermission {

        require(permissionAddresses[msg.sender], "Permission denied");
        _;
    }

    modifier RegDataValidation(address partner, bytes32 code) {

        require(partner != address(0), "Address must not be zero");
        require(code != bytes32(0), "Promocode must not be zero");
        require(codeToPartner[code].partnerAddr == address(0), "Promo code is already registered");
        require(partnerToCode[partner] == bytes32(0), "User is already registered");
        _;
    }



    function initialize() public initializer {

        AdminableUpgradable.initialize();  // Initialize Parent Contract

        levels[0] = LevelProgram(20, 0 ether);      // 20% and 0 ETH from referrals
        levels[1] = LevelProgram(35, 1000 ether);   // 35% and more 1000 ETH from referrals
        levels[2] = LevelProgram(50, 3000 ether);   // 50% and more 3000 ETH from referrals
    }



    function getPartnerByCode(bytes32 code) public view returns (address, uint8, uint256, uint256, uint256) {

        Partner memory curPartner = codeToPartner[code];

        return (
            curPartner.partnerAddr,
            curPartner.level,
            curPartner.referralsCount,
            curPartner.referralsEthValue,
            curPartner.profit
        );
    }

    function getPartnerByReferral(address referral) public view returns (address, uint8, uint256, uint256, uint256) {

        Partner memory curPartner = codeToPartner[partnerToCode[referralToReferrer[referral]]];

        return (
            curPartner.partnerAddr,
            curPartner.level,
            curPartner.referralsCount,
            curPartner.referralsEthValue,
            curPartner.profit
        );
    }

    function getProfitPercentByReferral(address referral) public view returns (uint8) {

        Partner memory curPartner = codeToPartner[partnerToCode[referralToReferrer[referral]]];

        return levels[curPartner.level].percent;
    }

    function isUserInPartnership(bytes32 code, address referral) public view returns (bool) {

        return (referralToReferrer[referral] == codeToPartner[code].partnerAddr);
    }



    function setPermissionAddress(address addr, bool status)
        public
        onlyOwnerOrAdmin
    {

        permissionAddresses[addr] = status;
    }

    function setPermissionAddresses(address[] memory addrs, bool status)
        public
        onlyOwnerOrAdmin
    {

        for (uint i = 0; i < addrs.length; i++) {
            permissionAddresses[addrs[i]] = status;
        }
    }

    function updateLevel(uint8 level, uint8 percent, uint80 ethAmount)
        public
        onlyOwnerOrAdmin
    {

        require(level < LEVEL_COUNTER, "Level is incorrect");
        require(percent <= 100, "Percent is incorrect");

        levels[level].percent = percent;
        levels[level].ethAmount = ethAmount;
    }

    function addPartnerByAdmin(address partner, uint8 level, bytes32 code)
        public
        onlyOwnerOrAdmin
        RegDataValidation(partner, code)
    {

        require(level < LEVEL_COUNTER, "Level is incorrect");

        _addPartnerHelper(partner, level, code);
    }



    function register(bytes32 code)
        public
        RegDataValidation(msg.sender, code)
    {

        _addPartnerHelper(msg.sender, 0, code);
    }

    function withdrawProfit() public {

        address payable partner = msg.sender;
        uint ethToWithdraw = codeToPartner[partnerToCode[partner]].profit;
        require(ethToWithdraw > 0, "No profit");

        codeToPartner[partnerToCode[partner]].profit = 0;
        partner.transfer(ethToWithdraw);

        emit ProfitWithdrawn(partner, ethToWithdraw);
    }



    function distributeProfit(address partner)
        public
        payable
        needPermission
    {

        _distributeProfitHelper(partnerToCode[partner]);
    }

    function distributeProfit(bytes32 code)
        public
        payable
        needPermission
    {

        _distributeProfitHelper(code);
    }

    function distributeProfitByReferral(address referral)
        public
        payable
        needPermission
    {

        _distributeProfitHelper(partnerToCode[referralToReferrer[referral]]);
    }



    function addReferral(address referral, bytes32 code, uint256 ethValue)
        public
        needPermission
        returns(uint256)    // 0 == deposit added to a new referrer
    {

        return _addReferralHelper(referral, code, ethValue);
    }

    function addReferral(address referral, address partner, uint256 ethValue)
        public
        needPermission
        returns(uint256)    // 0 == deposit added to a new referrer
    {

        return _addReferralHelper(referral, partnerToCode[partner], ethValue);
    }



    function _addPartnerHelper(address partner, uint8 level, bytes32 code)
        internal
    {

        partnerToCode[partner] = code;
        codeToPartner[code] = Partner(partner, level, 0, 0, 0);

        emit PartnerAdded(partner, level, code);
    }

    function _distributeProfitHelper(bytes32 code)
        internal
    {

        Partner memory curPartner = codeToPartner[code];
        require(curPartner.partnerAddr != address(0), "Promocode is not exists");

        uint curProfit = msg.value;
        codeToPartner[code].profit = uint80(add(curPartner.profit, curProfit));

        emit ProfitDistributed(code, curProfit);
    }

    function _addReferralHelper(address referral, bytes32 code, uint256 ethValue)
        internal
        returns(uint256)    // 0 == deposit added to a new referrer
    {

        Partner memory curPartner = codeToPartner[code];

        if (curPartner.partnerAddr == address(0)) {
            return 2;
        }

        uint80 referralsEthValue;
        codeToPartner[code].referralsEthValue = referralsEthValue = uint80(add(curPartner.referralsEthValue, ethValue));

        uint level = (referralsEthValue < levels[1].ethAmount) ? 0 : ((referralsEthValue < levels[2].ethAmount) ? 1 : 2);
        if (level > curPartner.level) {
            codeToPartner[code].level = uint8(level);
        }

        if (referralToReferrer[referral] != address(0)) {
            return 1;
        }

        codeToPartner[code].referralsCount += 1;
        referralToReferrer[referral] = curPartner.partnerAddr;

        emit ReferralAdded(referral, code);
        return 0;
    }


    uint256[50] private ______gap;
}