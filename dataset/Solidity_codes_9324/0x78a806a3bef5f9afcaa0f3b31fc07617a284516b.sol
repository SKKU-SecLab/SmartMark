
pragma solidity ^0.4.22;
contract ERC20Basic 
{

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeMath 
{

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c  / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        return a  / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
pragma solidity ^0.4.22;
contract ERC20 is ERC20Basic 
{

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Owner
{

    address internal owner;
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    function changeOwner(address newOwner) public onlyOwner returns(bool)
    {

        owner = newOwner;
        return true;
    }
}
pragma solidity ^0.4.22;
contract TkgPlus is Owner 
{

    mapping(address => uint256) internal balances;
    function parse2wei(uint _value) internal pure returns(uint)
    {

        uint decimals = 18;
        return _value * (10 ** uint256(decimals));
    }

    address public ADDR_TKG_ORG;
    address public ADDR_TKG_TECH_FUND;
    address public ADDR_TKG_ASSOCIATION;
    address public ADDR_TKG_VC;
    address public ADDR_TKG_NODE;
    address public ADDR_TKG_CHARITY;
    address public ADDR_TKG_TEAM;
    struct IcoRule
    {
        uint startTime;
        uint endTime;
        uint rate;
        uint shareRuleGroupId;
        address[] addrList;
        bool canceled;
    }
    IcoRule[] icoRuleList;
    mapping (address => uint[] ) addr2icoRuleIdList;
    event GetIcoRule(uint startTime, uint endTime, uint rate, uint shareRuleGroupId, bool canceled);
    function icoRuleAdd(uint startTime, uint endTime, uint rate, uint shareRuleGroupId) public onlyOwner returns (bool) 
    {

        address[] memory addr;
        bool canceled = false;
        IcoRule memory item = IcoRule(startTime, endTime, rate, shareRuleGroupId, addr, canceled);
        icoRuleList.push(item);
        return true;
    }
    function icoRuleUpdate(uint index, uint startTime, uint endTime, uint rate, uint shareRuleGroupId) public onlyOwner returns (bool) 
    {

        require(icoRuleList.length > index);
        if (startTime > 0) {
            icoRuleList[index].startTime = startTime;
        }
        if (endTime > 0) {
            icoRuleList[index].endTime = endTime;
        }
        if (rate > 0) {
            icoRuleList[index].rate = rate;
        }
        icoRuleList[index].shareRuleGroupId = shareRuleGroupId;
        return true;
    }
    function icoPushAddr(uint index, address addr) internal returns (bool) 
    {

        icoRuleList[index].addrList.push(addr);
        return true;
    }
    function icoRuleCancel(uint index) public onlyOwner returns (bool) 
    {

        require(icoRuleList.length > index);
        icoRuleList[index].canceled = true;
        return true;
    }
    function getIcoRuleList() public returns (uint count) 
    {

        count = icoRuleList.length;
        for (uint i = 0; i < count ; i++)
        {
            emit GetIcoRule(icoRuleList[i].startTime, icoRuleList[i].endTime, icoRuleList[i].rate, icoRuleList[i].shareRuleGroupId, 
            icoRuleList[i].canceled);
        }
    }
    function getIcoAddrCount(uint icoRuleId) public view onlyOwner returns (uint count) 
    {

        count = icoRuleList[icoRuleId - 1].addrList.length;
    }
    function getIcoAddrListByIcoRuleId(uint icoRuleId, uint index) public view onlyOwner returns (address addr) 
    {

        addr = icoRuleList[icoRuleId - 1].addrList[index];
    }
    function initIcoRule() internal returns(bool) 
    {

        icoRuleAdd(1529251201, 1530374399, 6000, 1);
        icoRuleAdd(1530547201, 1531238399, 3800, 0);
    }
    struct ShareRule {
        uint startTime;
        uint endTime;
        uint rateDenominator;
    }
    event GetShareRule(address addr, uint startTime, uint endTime, uint rateDenominator);
    mapping (uint => ShareRule[]) shareRuleGroup;
    mapping (address => uint) addr2shareRuleGroupId;
    mapping (address => uint ) sharedAmount;
    mapping (address => uint ) icoAmount;
    ShareRule[] shareRule6;
    function initShareRule6() internal returns( bool )
    {

        ShareRule memory sr = ShareRule(1533398401, 1536076799, 6);
        shareRule6.push( sr );
        sr = ShareRule(1536076801, 1538668799, 6);
        shareRule6.push( sr );
        sr = ShareRule(1538668801, 1541347199, 6);
        shareRule6.push( sr );
        sr = ShareRule(1541347201, 1543939199, 6);
        shareRule6.push( sr );
        sr = ShareRule(1543939201, 1546617599, 6);
        shareRule6.push( sr );
        sr = ShareRule(1546617601, 1549295999, 6);
        shareRule6.push( sr );
        shareRuleGroup[1] = shareRule6;
    }
    ShareRule[] srlist2;
    ShareRule[] srlist3;
    ShareRule[] srlist4;
    function initShareRule4Publicity() internal returns( bool )
    {

        ShareRule memory sr;
        sr = ShareRule(1529251201, 1560787199, 3);
        srlist2.push( sr );
        sr = ShareRule(1560787201, 1592409599, 3);
        srlist2.push( sr );
        sr = ShareRule(1592409601, 1623945599, 3);
        srlist2.push( sr );
        shareRuleGroup[2] = srlist2;
        addr2shareRuleGroupId[ADDR_TKG_NODE] = 2;
        sr = ShareRule(1529251201, 1560787199, 5);
        srlist3.push( sr );
        sr = ShareRule(1560787201, 1592409599, 5);
        srlist3.push( sr );
        sr = ShareRule(1592409601, 1623945599, 5);
        srlist3.push( sr );
        sr = ShareRule(1623945601, 1655481599, 5);
        srlist3.push( sr );
        sr = ShareRule(1655481601, 1687017599, 5);
        srlist3.push( sr );
        shareRuleGroup[3] = srlist3;
        addr2shareRuleGroupId[ADDR_TKG_CHARITY] = 3;
        sr = ShareRule(1529251201, 1560787199, 3);
        srlist4.push( sr );
        sr = ShareRule(1560787201, 1592409599, 3);
        srlist4.push( sr );
        sr = ShareRule(1592409601, 1623945599, 3);
        srlist4.push( sr );
        shareRuleGroup[4] = srlist4;
        addr2shareRuleGroupId[ADDR_TKG_TEAM] = 4;
        return true;
    }
    function initPublicityAddr() internal 
    {

        ADDR_TKG_TECH_FUND = address(0x6317D006021Fd26581deD71e547fC0B8e12876Eb);
        balances[ADDR_TKG_TECH_FUND] = parse2wei(59000000);
        ADDR_TKG_ASSOCIATION = address(0xB1A89E3ac5f90bE297853c76D8cb88259357C416);
        balances[ADDR_TKG_ASSOCIATION] = parse2wei(88500000);
        ADDR_TKG_VC = address(0xA053358bd6AC2E6eD5B13E59c20e42b66dFE6EC4);
        balances[ADDR_TKG_VC] = parse2wei(45500000);
        ADDR_TKG_NODE = address(0x21776fAcab4300437ECC0a132bEC361bA3Db7Fe7);
        balances[ADDR_TKG_NODE] = parse2wei(59000000);
        ADDR_TKG_CHARITY = address(0x4cB70266Ebc2def3B7219ef86E787b7be6139470);
        balances[ADDR_TKG_CHARITY] = parse2wei(29500000);
        ADDR_TKG_TEAM = address(0xd4076Cf846c8Dbf28e26E4863d94ddc948B9A155);
        balances[ADDR_TKG_TEAM] = parse2wei(88500000);
        initShareRule4Publicity();
    }
    function updatePublicityBalance( address addr, uint amount ) public onlyOwner returns(bool)
    {

        balances[addr] = amount;
        return true;
    }

    function updateShareRuleGroup(uint id, uint index, uint startTime, uint endTime, uint rateDenominator) public onlyOwner returns(bool)
    {

        if (startTime > 0) {
            shareRuleGroup[id][index].startTime = startTime;
        }
        if (endTime > 0) {
            shareRuleGroup[id][index].endTime = endTime;
        }
        if (rateDenominator > 0) {
            shareRuleGroup[id][index].rateDenominator = rateDenominator;
        }
        return true;
    }
    function tokenShareShow(address addr) public returns(uint shareRuleGroupId) 
    {

        shareRuleGroupId = addr2shareRuleGroupId[addr];
        if (shareRuleGroupId == 0) {
            return 0;
        }
        ShareRule[] memory shareRuleList = shareRuleGroup[shareRuleGroupId];
        uint count = shareRuleList.length;
        for (uint i = 0; i < count ; i++)
        {
            emit GetShareRule(addr, shareRuleList[i].startTime, shareRuleList[i].endTime, shareRuleList[i].rateDenominator);
        }
        return shareRuleGroupId;
    }
    function setAccountShareRuleGroupId(address addr, uint shareRuleGroupId) public onlyOwner returns(bool)
    {

        addr2shareRuleGroupId[addr] = shareRuleGroupId;
        return true;
    }
}
pragma solidity ^0.4.22;
contract BasicToken is ERC20Basic, TkgPlus 
{

    using SafeMath for uint256;
    uint256 internal totalSupply_;
    mapping (address => bool) internal locked;
    function lockAccount(address _addr) public onlyOwner returns (bool)
    {

        require(_addr != address(0));
        locked[_addr] = true;
        return true;
    }
    function unlockAccount(address _addr) public onlyOwner returns (bool)
    {

        require(_addr != address(0));
        locked[_addr] = false;
        return true;
    }
    function isLocked(address addr) public view returns(bool) 
    {

        return locked[addr];
    }
    bool internal stopped = false;
    modifier running {

        assert (!stopped);
        _;
    }
    function stop() public onlyOwner 
    {

        stopped = true;
    }
    function start() public onlyOwner 
    {

        stopped = false;
    }
    function isStopped() public view returns(bool)
    {

        return stopped;
    }
    function totalSupply() public view returns (uint256) 
    {

        return totalSupply_;
    }
    function getRemainShareAmount() public view returns(uint)
    {

        return getRemainShareAmountInternal(msg.sender);
    }
    function getRemainShareAmountInternal(address addr) internal view returns(uint)
    {

        uint canTransferAmount = 0;
        uint srgId = addr2shareRuleGroupId[addr];
        bool allowTransfer = false;
        if (srgId == 0) {
            canTransferAmount = balances[addr];
            return canTransferAmount;
        }
        else
        {
            ShareRule[] memory shareRuleList = shareRuleGroup[srgId];
            uint count = shareRuleList.length;
            for (uint i = 0; i < count ; i++)
            {
                if ( shareRuleList[i].startTime < now && now < shareRuleList[i].endTime)
                {
                    canTransferAmount = (i + 1).mul(icoAmount[addr]).div(shareRuleList[i].rateDenominator).sub( sharedAmount[addr]);
                    return canTransferAmount;
                }
            }
            if (allowTransfer == false)
            {
                bool isOverTime = true;
                for (i = 0; i < count ; i++) {
                    if ( now < shareRuleList[i].endTime) {
                        isOverTime = false;
                    }
                }
                if (isOverTime == true) {
                    allowTransfer = true;
                    canTransferAmount = balances[addr];
                    return canTransferAmount;
                }
            }
        }
    }
    function transfer(address _to, uint256 _value) public running returns (bool) 
    {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require( locked[msg.sender] != true);
        require( locked[_to] != true);
        require( getRemainShareAmount() >= _value );
        address addrA = address(0xce3c0a2012339490D2850B4Fd4cDA0B95Ac03076);
        if (msg.sender == addrA && now < 1532966399) {
            addr2shareRuleGroupId[_to] = 1;
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        sharedAmount[msg.sender] = sharedAmount[msg.sender].add( _value );
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256) 
    {

        return balances[_owner];
    }
}
pragma solidity ^0.4.22;
contract StandardToken is ERC20, BasicToken 
{

    mapping (address => mapping (address => uint256)) internal allowed;
    function transferFrom(address _from, address _to, uint256 _value) public running returns (bool) 
    {

        require(_to != address(0));
        require( locked[_from] != true && locked[_to] != true);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_value <= getRemainShareAmountInternal(_from));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public running returns (bool) 
    {

        require(getRemainShareAmountInternal(msg.sender) >= _value);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256) 
    {

        return allowed[_owner][_spender];
    }
}

contract AlanPlusToken is StandardToken
{

    function additional(uint amount) public onlyOwner running returns(bool)
    {

        totalSupply_ = totalSupply_.add(amount);
        balances[owner] = balances[owner].add(amount);
        return true;
    }
    event Burn(address indexed from, uint256 value);
    function burn(uint256 _value) public onlyOwner running returns (bool success) 
    {

        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) 
    {

        require(balances[_from] >= _value);
        if (_value <= allowed[_from][msg.sender]) {
            allowed[_from][msg.sender] -= _value;
        }
        else {
            allowed[_from][msg.sender] = 0;
        }
        balances[_from] -= _value;
        totalSupply_ -= _value;
        emit Burn(_from, _value);
        return true;
    }
}
pragma solidity ^0.4.22;
contract TKG is AlanPlusToken 
{

    string public constant name = "Token Guardian";
    string public constant symbol = "TKGN";
    uint8 public constant decimals = 18;
    uint256 private constant INITIAL_SUPPLY = 590000000 * (10 ** uint256(decimals));
    function () public payable 
    {
        uint curIcoRate = 0;
        uint icoRuleIndex = 500;
        for (uint i = 0; i < icoRuleList.length ; i++)
        {
            if ((icoRuleList[i].canceled != true) && (icoRuleList[i].startTime < now && now < icoRuleList[i].endTime)) {
                curIcoRate = icoRuleList[i].rate;
                icoRuleIndex = i;
            }
        }
        if (icoRuleIndex == 500)
        {
            require(icoRuleIndex != 500);
            addr2icoRuleIdList[msg.sender].push( 0 );
            addr2shareRuleGroupId[msg.sender] = addr2shareRuleGroupId[msg.sender] > 0 ? addr2shareRuleGroupId[msg.sender] : 0;
        }
        else
        {
            addr2shareRuleGroupId[msg.sender] = addr2shareRuleGroupId[msg.sender] > 0 ? addr2shareRuleGroupId[msg.sender] : icoRuleList[icoRuleIndex].shareRuleGroupId;
            addr2icoRuleIdList[msg.sender].push( icoRuleIndex + 1 );
            icoPushAddr(icoRuleIndex, msg.sender);
        }
        uint amountTKG = 0;
        amountTKG = msg.value.mul( curIcoRate );
        balances[msg.sender] = balances[msg.sender].add(amountTKG);
        icoAmount[msg.sender] = icoAmount[msg.sender].add(amountTKG);
        balances[owner] = balances[owner].sub(amountTKG);
        ADDR_TKG_ORG.transfer(msg.value);
    }
    constructor(uint totalSupply) public 
    {
        owner = msg.sender;
        ADDR_TKG_ORG = owner;
        totalSupply_ = totalSupply > 0 ? totalSupply : INITIAL_SUPPLY;
        uint assignedAmount = 59000000 + 88500000 + 45500000 + 59000000 + 29500000 + 88500000;
        balances[owner] = totalSupply_.sub( parse2wei(assignedAmount) );
        initIcoRule();
        initShareRule6();
        initPublicityAddr();
    }
}