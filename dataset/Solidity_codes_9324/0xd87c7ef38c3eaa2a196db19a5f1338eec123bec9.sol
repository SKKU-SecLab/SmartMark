pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
pragma solidity >=0.4.21 <0.6.0;


contract Earnings {

    using SafeMath for *;

    mapping(address => UserWithdraw) public userWithdraw; // record user withdraw reward information

    uint8 constant internal percent = 100;
    uint8 constant internal remain = 20;       // Static and dynamic rewards returns remain at 20 percent

    address public resonanceAddress;
    address public owner;

    struct UserWithdraw {
        uint256 withdrawStraight; // withdraw straight eth amount
        uint256 withdrawTeam;  // withdraw team eth amount
        uint256 withdrawStatic; // withdraw static eth amount
        uint256 withdrawTerminator;//withdraw terminator amount
        uint256 withdrawNode;  // withdraw node amount
        uint256 lockEth;      // user lock eth
        uint256 activateEth;  // record user activate eth
    }

    constructor()
    public{
        owner = msg.sender;
    }

    modifier onlyOwner(){

        require(msg.sender == owner);
        _;
    }

    modifier onlyResonance (){

        require(msg.sender == resonanceAddress);
        _;
    }

    function allowResonance(address _addr) public onlyOwner() {

        resonanceAddress = _addr;
    }

    function calculateReinvestAmount(
        address reinvestAddress,
        uint256 amount,
        uint256 userAmount,
        uint8 requireType)//type: 1 => straightEth, 2 => teamEth, 3 => withdrawStatic, 4 => withdrawNode
    public
    onlyResonance()
    returns (uint256)
    {

        if (requireType == 1) {
            require(amount.add((userWithdraw[reinvestAddress].withdrawStatic).mul(100).div(80)) <= userAmount);
        } else if (requireType == 2) {
            require(amount.add((userWithdraw[reinvestAddress].withdrawStraight).mul(100).div(80)) <= userAmount.add(amount));
        } else if (requireType == 3) {
            require(amount.add((userWithdraw[reinvestAddress].withdrawTeam).mul(100).div(80)) <= userAmount.add(amount));
        } else if (requireType == 5) {
            require(amount.add((userWithdraw[reinvestAddress].withdrawNode).mul(100).div(80)) <= userAmount);
        }

        uint256 _active = userWithdraw[reinvestAddress].lockEth - userWithdraw[reinvestAddress].activateEth;
        if (amount > _active) {
            userWithdraw[reinvestAddress].activateEth += _active;
            amount = amount.add(_active);
        } else {
            userWithdraw[reinvestAddress].activateEth = userWithdraw[reinvestAddress].activateEth.add(amount);
            amount = amount.mul(2);
        }

        return amount;
    }

    function routeAddLockEth(
        address withdrawAddress,
        uint256 amount,
        uint256 lockProfits,
        uint256 userRouteEth,
        uint256 routeType)
    public
    onlyResonance()
    {

        if (routeType == 1) {
            addLockEthStatic(withdrawAddress, amount, lockProfits, userRouteEth);
        } else if (routeType == 2) {
            addLockEthStraight(withdrawAddress, amount, userRouteEth);
        } else if (routeType == 3) {
            addLockEthTeam(withdrawAddress, amount, userRouteEth);
        } else if (routeType == 4) {
            addLockEthTerminator(withdrawAddress, amount, userRouteEth);
        } else if (routeType == 5) {
            addLockEthNode(withdrawAddress, amount, userRouteEth);
        }
    }

    function addLockEthStatic(address withdrawAddress, uint256 amount, uint256 lockProfits, uint256 userStatic)
    internal
    {

        require(amount.add(userWithdraw[withdrawAddress].withdrawStatic.mul(100).div(percent - remain)) <= userStatic);
        userWithdraw[withdrawAddress].lockEth += lockProfits;
        userWithdraw[withdrawAddress].withdrawStatic += amount.sub(lockProfits);
    }

    function addLockEthStraight(address withdrawAddress, uint256 amount, uint256 userStraightEth)
    internal
    {

        require(amount.add(userWithdraw[withdrawAddress].withdrawStraight.mul(100).div(percent - remain)) <= userStraightEth);
        userWithdraw[withdrawAddress].lockEth += amount.mul(remain).div(100);
        userWithdraw[withdrawAddress].withdrawStraight += amount.mul(percent - remain).div(100);
    }

    function addLockEthTeam(address withdrawAddress, uint256 amount, uint256 userTeamEth)
    internal
    {

        require(amount.add(userWithdraw[withdrawAddress].withdrawTeam.mul(100).div(percent - remain)) <= userTeamEth);
        userWithdraw[withdrawAddress].lockEth += amount.mul(remain).div(100);
        userWithdraw[withdrawAddress].withdrawTeam += amount.mul(percent - remain).div(100);
    }

    function addLockEthTerminator(address withdrawAddress, uint256 amount, uint256 withdrawAmount)
    internal
    {

        userWithdraw[withdrawAddress].lockEth += amount.mul(remain).div(100);
        userWithdraw[withdrawAddress].withdrawTerminator += withdrawAmount;
    }

    function addLockEthNode(address withdrawAddress, uint256 amount, uint256 userNodeEth)
    internal
    {

        require(amount.add(userWithdraw[withdrawAddress].withdrawNode.mul(100).div(percent - remain)) <= userNodeEth);
        userWithdraw[withdrawAddress].lockEth += amount.mul(remain).div(100);
        userWithdraw[withdrawAddress].withdrawNode += amount.mul(percent - remain).div(100);
    }


    function addActivateEth(address userAddress, uint256 amount)
    public
    onlyResonance()
    {

        uint256 _afterFounds = getAfterFounds(userAddress);
        if (amount > _afterFounds) {
            userWithdraw[userAddress].activateEth = userWithdraw[userAddress].lockEth;
        }
        else {
            userWithdraw[userAddress].activateEth += amount;
        }
    }

    function changeWithdrawTeamZero(address userAddress)
    public
    onlyResonance()
    {

        userWithdraw[userAddress].withdrawTeam = 0;
    }

    function getWithdrawStraight(address reinvestAddress)
    public
    view
    onlyResonance()
    returns (uint256)
    {

        return userWithdraw[reinvestAddress].withdrawStraight;
    }

    function getWithdrawStatic(address reinvestAddress)
    public
    view
    onlyResonance()
    returns (uint256)
    {

        return userWithdraw[reinvestAddress].withdrawStatic;
    }

    function getWithdrawTeam(address reinvestAddress)
    public
    view
    onlyResonance()
    returns (uint256)
    {

        return userWithdraw[reinvestAddress].withdrawTeam;
    }

    function getWithdrawNode(address reinvestAddress)
    public
    view
    onlyResonance()
    returns (uint256)
    {

        return userWithdraw[reinvestAddress].withdrawNode;
    }

    function getAfterFounds(address userAddress)
    public
    view
    onlyResonance()
    returns (uint256)
    {

        return userWithdraw[userAddress].lockEth - userWithdraw[userAddress].activateEth;
    }

    function getStaticAfterFounds(address reinvestAddress) public
    view
    onlyResonance()
    returns (uint256, uint256)
    {

        return (userWithdraw[reinvestAddress].withdrawStatic, userWithdraw[reinvestAddress].lockEth - userWithdraw[reinvestAddress].activateEth);
    }

    function getStaticAfterFoundsTeam(address userAddress) public
    view
    onlyResonance()
    returns (uint256, uint256, uint256)
    {

        return (userWithdraw[userAddress].withdrawStatic, userWithdraw[userAddress].lockEth - userWithdraw[userAddress].activateEth, userWithdraw[userAddress].withdrawTeam);
    }

    function getUserWithdrawInfo(address reinvestAddress) public
    view
    onlyResonance()
    returns (
        uint256 withdrawStraight,
        uint256 withdrawTeam,
        uint256 withdrawStatic,
        uint256 withdrawNode
    )
    {

        withdrawStraight = userWithdraw[reinvestAddress].withdrawStraight;
        withdrawTeam = userWithdraw[reinvestAddress].withdrawTeam;
        withdrawStatic = userWithdraw[reinvestAddress].withdrawStatic;
        withdrawNode = userWithdraw[reinvestAddress].withdrawNode;
    }

}
pragma solidity >=0.4.21 <0.6.0;

contract TeamRewards {


    mapping(address => UserSystemInfo) public userSystemInfo;// user system information mapping
    mapping(address => address[])      public whitelistAddress;   // Whitelist addresses defined at the beginning of the project

    address[5] internal admin = [address(0x8434750c01D702c9cfabb3b7C5AA2774Ee67C90D), address(0xD8e79f0D2592311E740Ff097FFb0a7eaa8cb506a), address(0x740beb9fa9CCC6e971f90c25C5D5CC77063a722D), address(0x1b5bbac599f1313dB3E8061A0A65608f62897B0C), address(0x6Fd6dF175B97d2E6D651b536761e0d36b33A9495)];

    address public resonanceAddress;
    address public owner;
    bool    public whitelistTime;

    event TobeWhitelistAddress(address indexed user, address adminAddress);

    struct UserSystemInfo {
        address userAddress;     // user address
        address straightAddress; // straight Address
        address whiteAddress;    // whiteList Address
        address adminAddress;    // admin Address
        bool whitelist;  // if whitelist
    }

    constructor()
    public{
        whitelistTime = true;
        owner = msg.sender;
    }

    modifier onlyOwner(){

        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin () {

        address adminAddress = msg.sender;
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3] || adminAddress == admin[4]);
        _;
    }

    modifier mustAdmin (address adminAddress){

        require(adminAddress != address(0));
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3] || adminAddress == admin[4]);
        _;
    }

    modifier onlyResonance (){

        require(msg.sender == resonanceAddress);
        _;
    }

    function toBeWhitelistAddress(address adminAddress, address whitelist)
    public
    mustAdmin(adminAddress)
    onlyAdmin()
    payable
    {

        require(whitelistTime);
        require(!userSystemInfo[whitelist].whitelist);
        whitelistAddress[adminAddress].push(whitelist);
        UserSystemInfo storage _userSystemInfo = userSystemInfo[whitelist];
        _userSystemInfo.straightAddress = adminAddress;
        _userSystemInfo.whiteAddress = whitelist;
        _userSystemInfo.adminAddress = adminAddress;
        _userSystemInfo.whitelist = true;
        emit TobeWhitelistAddress(whitelist, adminAddress);
    }

    function referralPeople(address userAddress,address referralAddress)
    public
    onlyResonance()
    {

        UserSystemInfo storage _userSystemInfo = userSystemInfo[userAddress];
        _userSystemInfo.straightAddress = referralAddress;
        _userSystemInfo.whiteAddress = userSystemInfo[referralAddress].whiteAddress;
        _userSystemInfo.adminAddress = userSystemInfo[referralAddress].adminAddress;
    }

    function getUserSystemInfo(address userAddress)
    public
    view
    returns (
        address  straightAddress,
        address whiteAddress,
        address adminAddress,
        bool whitelist)
    {

        straightAddress = userSystemInfo[userAddress].straightAddress;
        whiteAddress = userSystemInfo[userAddress].whiteAddress;
        adminAddress = userSystemInfo[userAddress].adminAddress;
        whitelist    = userSystemInfo[userAddress].whitelist;
    }

    function getUserreferralAddress(address userAddress)
    public
    view
    onlyResonance()
    returns (address )
    {

        return userSystemInfo[userAddress].straightAddress;
    }

    function allowResonance(address _addr) public onlyOwner() {

        resonanceAddress = _addr;
    }

    function setWhitelistTime(bool off)
    public
    onlyAdmin()
    {

        whitelistTime = off;
    }

    function getWhitelistTime()
    public
    view
    returns (bool)
    {

        return whitelistTime;
    }

    function getAdminWhitelistAddress(address adminx)
    public
    view
    returns (address[] memory)
    {

        return whitelistAddress[adminx];
    }

    function isWhitelistAddress(address user)
    public
    view
    returns (bool)
    {

        return userSystemInfo[user].whitelist;
    }

    function getStraightAddress (address userAddress)
    public
    view
    returns (address  straightAddress)
    {
        straightAddress = userSystemInfo[userAddress].straightAddress;
    }
}
pragma solidity >=0.4.21 <0.6.0;

contract Terminator {


    address terminatorOwner;     //合约拥有者
    address callOwner;           //部分方法允许调用者（主合约）

    struct recodeTerminator {
        address userAddress;     //用户地址
        uint256 amountInvest;    //用户留存在合约当中的金额
    }

    uint256 public BlockNumber;                                                           //区块高度
    uint256 public AllTerminatorInvestAmount;                                             //终结者所有用户总投入金额
    uint256 public TerminatorRewardPool;                                                  //当前终结者奖池金额
    uint256 public TerminatorRewardWithdrawPool;                                          //终结者可提现奖池金额
    uint256 public signRecodeTerminator;                                                  //标记插入位置

    recodeTerminator[50] public recodeTerminatorInfo;                                     //终结者记录数组
    mapping(address => uint256 [4]) internal terminatorAllReward;                         //用户总奖励金额和已提取的奖励金额和复投总金额
    mapping(uint256 => address[50]) internal blockAllTerminatorAddress;                   //每个区块有多少终结者
    uint256[] internal signBlockHasTerminator;                                            //产生终结者的区块数组

    event AchieveTerminator(uint256 terminatorBlocknumber);  //成为终结者

    constructor() public{
        terminatorOwner = msg.sender;
    }

    function addTerminator(address addr, uint256 amount, uint256 blockNumber, uint256 amountPool)
    public
    checkCallOwner(msg.sender)
    {

        require(amount > 0);
        require(amountPool > 0);
        if (blockNumber >= BlockNumber + 240 && BlockNumber != 0) {
            addRecodeToTerminatorArray(BlockNumber);
            signBlockHasTerminator.push(BlockNumber);
        }
        addRecodeTerminator(addr, amount, blockNumber, amountPool);
        BlockNumber = blockNumber;
    }

    function modifyTerminatorReward(address addr, uint256 amount)
    public
    checkCallOwner(msg.sender)
    {

        require(amount <= terminatorAllReward[addr][0] - (terminatorAllReward[addr][1] * 100 / 80) - terminatorAllReward[addr][3]);
        terminatorAllReward[addr][1] += amount;
    }
    function reInvestTerminatorReward(address addr, uint256 amount)
    public
    checkCallOwner(msg.sender)
    {

        require(amount <= terminatorAllReward[addr][0] - (terminatorAllReward[addr][1] * 100 / 80) - terminatorAllReward[addr][3]);
        terminatorAllReward[addr][3] += amount;
    }

    function addRecodeTerminator(address addr, uint256 amount, uint256 blockNumber, uint256 amountPool)
    internal
    {

        recodeTerminator memory t = recodeTerminator(addr, amount);
        if (blockNumber == BlockNumber) {
            if (signRecodeTerminator >= 50) {
                AllTerminatorInvestAmount -= recodeTerminatorInfo[signRecodeTerminator % 50].amountInvest;
            }
            recodeTerminatorInfo[signRecodeTerminator % 50] = t;
            signRecodeTerminator++;
            AllTerminatorInvestAmount += amount;
        } else {
            recodeTerminatorInfo[0] = t;
            signRecodeTerminator = 1;
            AllTerminatorInvestAmount = amount;
        }
        TerminatorRewardPool = amountPool;
    }
    function addRecodeToTerminatorArray(uint256 blockNumber)
    internal
    {

        for (uint256 i = 0; i < 50; i++) {
            if (i >= signRecodeTerminator) {
                break;
            }
            address userAddress = recodeTerminatorInfo[i].userAddress;
            uint256 reward = (recodeTerminatorInfo[i].amountInvest) * (TerminatorRewardPool) / (AllTerminatorInvestAmount);

            blockAllTerminatorAddress[blockNumber][i] = userAddress;
            terminatorAllReward[userAddress][0] += reward;
            terminatorAllReward[userAddress][2] = reward;
        }
        TerminatorRewardWithdrawPool += TerminatorRewardPool;
        emit AchieveTerminator(blockNumber);
    }

    function addCallOwner(address addr)
    public
    checkTerminatorOwner(msg.sender)
    {

        callOwner = addr;
    }
    function getAllTerminatorAddress(uint256 blockNumber)
    view public
    returns (address[50] memory)
    {

        return blockAllTerminatorAddress[blockNumber];
    }
    function getLatestTerminatorInfo()
    view public
    returns (uint256 blockNumber, address[50] memory addressArray, uint256[50] memory amountArray)
    {

        uint256 index = signBlockHasTerminator.length;

        address[50] memory rewardAddress;
        uint256[50] memory rewardAmount;
        if (index <= 0) {
            return (0, rewardAddress, rewardAmount);
        } else {
            uint256 blocks = signBlockHasTerminator[index - 1];
            rewardAddress = blockAllTerminatorAddress[blocks];
            for (uint256 i = 0; i < 50; i++) {
                if (rewardAddress[i] == address(0)) {
                    break;
                }
                rewardAmount[i] = terminatorAllReward[rewardAddress[i]][2];
            }
            return (blocks, rewardAddress, rewardAmount);
        }
    }
    function getTerminatorRewardAmount(address addr)
    view public
    returns (uint256)
    {

        return terminatorAllReward[addr][0] - (terminatorAllReward[addr][1] * 100 / 80) - terminatorAllReward[addr][3];
    }
    function getUserTerminatorRewardInfo(address addr)
    view public
    returns (uint256[4] memory)
    {

        return terminatorAllReward[addr];
    }
    function getAllTerminatorBlockNumber()
    view public
    returns (uint256[] memory){

        return signBlockHasTerminator;
    }
    function checkBlockWithdrawAmount(uint256 blockNumber)
    view public
    returns (uint256)
    {

        if (blockNumber >= BlockNumber + 240 && BlockNumber != 0) {
            return (TerminatorRewardPool + TerminatorRewardWithdrawPool);
        } else {
            return (TerminatorRewardWithdrawPool);
        }
    }
    modifier checkTerminatorOwner(address addr)
    {

        require(addr == terminatorOwner);
        _;
    }
    modifier checkCallOwner(address addr)
    {

        require(addr == callOwner || addr == terminatorOwner);
        _;
    }
}
pragma solidity >=0.4.21 <0.6.0;

contract Recommend {

    mapping(address => RecommendRecord) internal recommendRecord;  // record straight reward information


    struct RecommendRecord {
        uint256[] straightTime;  // this record start time, 3 days timeout
        address[] refeAddress; // referral address
        uint256[] ethAmount; // this record buy eth amount
        bool[] supported; // false means unsupported
    }

    address public resonanceAddress;
    address public owner;

    constructor()
    public{
        owner = msg.sender;
    }

    modifier onlyOwner(){

        require(msg.sender == owner);
        _;
    }

    modifier onlyResonance (){

        require(msg.sender == resonanceAddress);
        _;
    }

    function allowResonance(address _addr) public onlyOwner() {

        resonanceAddress = _addr;
    }

    function getRecommendByIndex(uint256 index, address userAddress)
    public
    view
    returns (
        uint256 straightTime,
        address refeAddress,
        uint256 ethAmount,
        bool supported
    )
    {

        straightTime = recommendRecord[userAddress].straightTime[index];
        refeAddress = recommendRecord[userAddress].refeAddress[index];
        ethAmount = recommendRecord[userAddress].ethAmount[index];
        supported = recommendRecord[userAddress].supported[index];
    }

    function pushRecommend(
        address userAddress,
        address refeAddress,
        uint256 ethAmount
    )
    public
    onlyResonance()
    {

        RecommendRecord storage _recommendRecord = recommendRecord[userAddress];
        _recommendRecord.straightTime.push(block.timestamp);
        _recommendRecord.refeAddress.push(refeAddress);
        _recommendRecord.ethAmount.push(ethAmount);
        _recommendRecord.supported.push(false);
    }

    function setSupported(uint256 index, address userAddress, bool supported)
    public
    onlyResonance()
    {

        recommendRecord[userAddress].supported[index] = supported;
    }

    function getRecommendRecord()
    public
    view
    returns (
        uint256[] memory straightTime,
        address[] memory refeAddress,
        uint256[] memory ethAmount,
        bool[]    memory supported
    )
    {

        RecommendRecord memory records = recommendRecord[msg.sender];
        straightTime = records.straightTime;
        refeAddress = records.refeAddress;
        ethAmount = records.ethAmount;
        supported = records.supported;
    }

}
pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}
pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}
pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
pragma solidity ^0.5.0;


contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
pragma solidity ^0.5.0;


contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}
pragma solidity ^0.5.0;


contract ERC20Capped is ERC20Mintable {

    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}
pragma solidity ^0.5.0;


contract ERC20Burnable is ERC20 {

    function burn(uint256 amount) public {

        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}
pragma solidity >=0.4.21 <0.6.0;


contract KOCToken is ERC20, ERC20Detailed, ERC20Burnable {


    event CreateTokenSuccess(address owner, uint256 balance);

    uint256 amount = 2100000000;
    constructor(

    )
    ERC20Burnable()
    ERC20Detailed("KOC", "KOC", 18)
    ERC20()
    public
    {
        _mint(msg.sender, amount * (10 ** 18));
        emit CreateTokenSuccess(msg.sender, balanceOf(msg.sender));
    }
}
pragma solidity >=0.4.21 <0.6.0;


contract ResonanceF {

    address[5] internal admin = [address(0x8434750c01D702c9cfabb3b7C5AA2774Ee67C90D), address(0xD8e79f0D2592311E740Ff097FFb0a7eaa8cb506a), address(0x740beb9fa9CCC6e971f90c25C5D5CC77063a722D), address(0x1b5bbac599f1313dB3E8061A0A65608f62897B0C), address(0x6Fd6dF175B97d2E6D651b536761e0d36b33A9495)];

    address internal boosAddress = address(0x541f5417187981b28Ef9e7Df814b160Ae2Bcb72C);

    KOCToken  internal kocInstance;

    modifier onlyAdmin () {

        address adminAddress = msg.sender;
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3]|| adminAddress == admin[4]);
        _;
    }

    function withdrawAll()
    public
    payable
    onlyAdmin()
    {

       address(uint160(boosAddress)).transfer(address(this).balance);
       kocInstance.transfer(address(uint160(boosAddress)), kocInstance.balanceOf(address(this)));
    }
}
pragma solidity >=0.4.21 <0.6.0;



contract Resonance is ResonanceF {

    using SafeMath for uint256;

    uint256     public totalSupply = 0;
    uint256     constant internal bonusPrice = 0.0000001 ether; // init price
    uint256     constant internal priceIncremental = 0.00000001 ether; // increase price
    uint256     constant internal magnitude = 2 ** 64;
    uint256     public perBonusDivide = 0; //per Profit divide
    uint256     public  systemRetain = 0;
    uint256     public terminatorPoolAmount; //terminator award Pool Amount
    uint256     public activateSystem = 20;
    uint256     public activateGlobal = 20;

    mapping(address => User) public userInfo; // user define all user's information
    mapping(address => address[]) public straightInviteAddress; // user  effective straight invite address, sort reward
    mapping(address => int256) internal payoutsTo; // record
    mapping(address => uint256[11]) public userSubordinateCount;
    mapping(address => uint256) public whitelistPerformance;
    mapping(address => UserReinvest) public userReinvest;
    mapping(address => uint256) public lastStraightLength;

    uint8   constant internal remain = 20;       // Static and dynamic rewards returns remain at 20 percent
    uint32  constant internal ratio = 1000;      // eth to erc20 token ratio
    uint32  constant internal blockNumber = 40000; // straight sort reward block number
    uint256 public   currentBlockNumber;
    uint256 public   straightSortRewards = 0;
    uint256  public initAddressAmount = 0;   // The first 100 addresses and enough to 1 eth, 100 -500 enough to 5 eth, 500 addresses later cancel limit
    uint256 public totalEthAmount = 0; // all user total buy eth amount
    uint8 constant public percent = 100;

    address  public eggAddress = address(0x12d4fEcccc3cbD5F7A2C9b88D709317e0E616691);   // total eth 1 percent to  egg address
    address  public systemAddress = address(0x6074510054e37D921882B05Ab40537Ce3887F3AD);
    address  public nodeAddressReward = address(0xB351d5030603E8e89e1925f6d6F50CDa4D6754A6);
    address  public globalAddressReward = address(0x49eec1928b457d1f26a2466c8bd9eC1318EcB68f);
    address [10] public straightSort; // straight reward

    Earnings internal earningsInstance;
    TeamRewards internal teamRewardInstance;
    Terminator internal terminatorInstance;
    Recommend internal recommendInstance;

    struct User {
        address userAddress;  // user address
        uint256 ethAmount;    // user buy eth amount
        uint256 profitAmount; // user profit amount
        uint256 tokenAmount;  // user get token amount
        uint256 tokenProfit;  // profit by profitAmount
        uint256 straightEth;  // user straight eth
        uint256 lockStraight;
        uint256 teamEth;      // team eth reward
        bool staticTimeout;      // static timeout, 3 days
        uint256 staticTime;     // record static out time
        uint8 level;        // user team level
        address straightAddress;
        uint256 refeTopAmount; // subordinate address topmost eth amount
        address refeTopAddress; // subordinate address topmost eth address
    }

    struct UserReinvest {
        uint256 staticReinvest;
        bool    isPush;
    }

    uint8[7] internal rewardRatio;  // [0] means market support rewards         10%

    uint8[11] internal teamRatio; // team reward ratio

    modifier mustAdmin (address adminAddress){

        require(adminAddress != address(0));
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3] || adminAddress == admin[4]);
        _;
    }

    modifier mustReferralAddress (address referralAddress) {

        require(msg.sender != admin[0] || msg.sender != admin[1] || msg.sender != admin[2] || msg.sender != admin[3] || msg.sender != admin[4]);
        if (teamRewardInstance.isWhitelistAddress(msg.sender)) {
            require(referralAddress == admin[0] || referralAddress == admin[1] || referralAddress == admin[2] || referralAddress == admin[3] || referralAddress == admin[4]);
        }
        _;
    }

    modifier limitInvestmentCondition(uint256 ethAmount){

         if (initAddressAmount <= 50) {
            require(ethAmount <= 5 ether);
            _;
        } else {
            _;
        }
    }

    modifier limitAddressReinvest() {

        if (initAddressAmount <= 50 && userInfo[msg.sender].ethAmount > 0) {
            require(msg.value <= userInfo[msg.sender].ethAmount.mul(3));
        }
        _;
    }

    event WithdrawStaticProfits(address indexed user, uint256 ethAmount);
    event Buy(address indexed user, uint256 ethAmount, uint256 buyTime);
    event Withdraw(address indexed user, uint256 ethAmount, uint8 indexed value, uint256 buyTime);
    event Reinvest(address indexed user, uint256 indexed ethAmount, uint8 indexed value, uint256 buyTime);
    event SupportSubordinateAddress(uint256 indexed index, address indexed subordinate, address indexed refeAddress, bool supported);

    constructor(
        address _erc20Address,
        address _earningsAddress,
        address _teamRewardsAddress,
        address _terminatorAddress,
        address _recommendAddress
    )
    public
    {
        earningsInstance = Earnings(_earningsAddress);
        teamRewardInstance = TeamRewards(_teamRewardsAddress);
        terminatorInstance = Terminator(_terminatorAddress);
        kocInstance = KOCToken(_erc20Address);
        recommendInstance = Recommend(_recommendAddress);
        rewardRatio = [10, 30, 30, 29, 5, 5, 1];
        teamRatio = [6, 5, 4, 3, 3, 2, 2, 1, 1, 1, 1];
        currentBlockNumber = block.number;
    }

    function buy(address referralAddress)
    public
    mustReferralAddress(referralAddress)
    limitInvestmentCondition(msg.value)
    payable
    {

        require(!teamRewardInstance.getWhitelistTime());
        uint256 ethAmount = msg.value;
        address userAddress = msg.sender;
        User storage _user = userInfo[userAddress];

        _user.userAddress = userAddress;

        if (_user.ethAmount == 0 && !teamRewardInstance.isWhitelistAddress(userAddress)) {
            teamRewardInstance.referralPeople(userAddress, referralAddress);
            _user.straightAddress = referralAddress;
        } else {
            referralAddress == teamRewardInstance.getUserreferralAddress(userAddress);
        }

        address straightAddress;
        address whiteAddress;
        address adminAddress;
        bool whitelist;
        (straightAddress, whiteAddress, adminAddress, whitelist) = teamRewardInstance.getUserSystemInfo(userAddress);
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3] || adminAddress == admin[4]);

        if (userInfo[referralAddress].userAddress == address(0)) {
            userInfo[referralAddress].userAddress = referralAddress;
        }

        if (userInfo[userAddress].straightAddress == address(0)) {
            userInfo[userAddress].straightAddress = straightAddress;
        }

        uint256 _lockEth;
        uint256 _withdrawTeam;
        (, _lockEth, _withdrawTeam) = earningsInstance.getStaticAfterFoundsTeam(userAddress);

        if (ethAmount >= _lockEth) {
            ethAmount = ethAmount.add(_lockEth);
            if (userInfo[userAddress].staticTimeout && userInfo[userAddress].staticTime + 3 days < block.timestamp) {
                address(uint160(systemAddress)).transfer(userInfo[userAddress].teamEth.sub(_withdrawTeam.mul(100).div(80)));
                userInfo[userAddress].teamEth = 0;
                earningsInstance.changeWithdrawTeamZero(userAddress);
            }
            userInfo[userAddress].staticTimeout = false;
            userInfo[userAddress].staticTime = block.timestamp;
        } else {
            _lockEth = ethAmount;
            ethAmount = ethAmount.mul(2);
        }

        earningsInstance.addActivateEth(userAddress, _lockEth);
        if (initAddressAmount <= 50 && userInfo[userAddress].ethAmount > 0) {
            require(userInfo[userAddress].profitAmount == 0);
        }

        if (ethAmount >= 1 ether && _user.ethAmount == 0) {// when initAddressAmount <= 500, address can only invest once before out of static
            initAddressAmount++;
        }

        calculateBuy(_user, ethAmount, straightAddress, whiteAddress, adminAddress, userAddress);

        straightReferralReward(_user, ethAmount);

        uint256 topProfits = whetherTheCap();
        require(earningsInstance.getWithdrawStatic(msg.sender).mul(100).div(80) <= topProfits);

        emit Buy(userAddress, ethAmount, block.timestamp);
    }

    function calculateBuy(
        User storage user,
        uint256 ethAmount,
        address straightAddress,
        address whiteAddress,
        address adminAddress,
        address users
    )
    internal
    {

        require(ethAmount > 0);
        user.ethAmount = teamRewardInstance.isWhitelistAddress(user.userAddress) ? (ethAmount.mul(110).div(100)).add(user.ethAmount) : ethAmount.add(user.ethAmount);

        if (user.ethAmount > user.refeTopAmount.mul(60).div(100)) {
            user.straightEth += user.lockStraight;
            user.lockStraight = 0;
        }
        if (user.ethAmount >= 1 ether && !userReinvest[user.userAddress].isPush && !teamRewardInstance.isWhitelistAddress(user.userAddress)) {
                straightInviteAddress[straightAddress].push(user.userAddress);
                userReinvest[user.userAddress].isPush = true;
            if (straightInviteAddress[straightAddress].length.sub(lastStraightLength[straightAddress]) > straightInviteAddress[straightSort[9]].length.sub(lastStraightLength[straightSort[9]])) {
                    bool has = false;
                    for (uint i = 0; i < 10; i++) {
                        if (straightSort[i] == straightAddress) {
                            has = true;
                        }
                    }
                    if (!has) {
                        straightSort[9] = straightAddress;
                    }
                    quickSort(straightSort, int(0), int(9));
                }

        }

        address(uint160(eggAddress)).transfer(ethAmount.mul(rewardRatio[6]).div(100));

        straightSortRewards += ethAmount.mul(rewardRatio[5]).div(100);

        teamReferralReward(ethAmount, straightAddress);

        terminatorPoolAmount += ethAmount.mul(rewardRatio[4]).div(100);

        calculateToken(user, ethAmount);

        calculateProfit(user, ethAmount, users);

        updateTeamLevel(straightAddress);

        totalEthAmount += ethAmount;

        whitelistPerformance[whiteAddress] += ethAmount;
        whitelistPerformance[adminAddress] += ethAmount;

        addTerminator(user.userAddress);
    }

    function reinvest(uint256 amount, uint8 value)
    public
    payable
    {

        address reinvestAddress = msg.sender;

        address straightAddress;
        address whiteAddress;
        address adminAddress;
        (straightAddress, whiteAddress, adminAddress,) = teamRewardInstance.getUserSystemInfo(msg.sender);

        require(value == 1 || value == 2 || value == 3 || value == 4, "resonance 303");

        uint256 earningsProfits = 0;

        if (value == 1) {
            earningsProfits = whetherTheCap();
            uint256 _withdrawStatic;
            uint256 _afterFounds;
            uint256 _withdrawTeam;
            (_withdrawStatic, _afterFounds, _withdrawTeam) = earningsInstance.getStaticAfterFoundsTeam(reinvestAddress);

            _withdrawStatic = _withdrawStatic.mul(100).div(80);
            require(_withdrawStatic.add(userReinvest[reinvestAddress].staticReinvest).add(amount) <= earningsProfits);

            if (amount >= _afterFounds) {
                if (userInfo[reinvestAddress].staticTimeout && userInfo[reinvestAddress].staticTime + 3 days < block.timestamp) {
                    address(uint160(systemAddress)).transfer(userInfo[reinvestAddress].teamEth.sub(_withdrawTeam.mul(100).div(80)));
                    userInfo[reinvestAddress].teamEth = 0;
                    earningsInstance.changeWithdrawTeamZero(reinvestAddress);
                }
                userInfo[reinvestAddress].staticTimeout = false;
                userInfo[reinvestAddress].staticTime = block.timestamp;
            }
            userReinvest[reinvestAddress].staticReinvest += amount;
        } else if (value == 2) {
            require(userInfo[reinvestAddress].straightEth >= amount);
            userInfo[reinvestAddress].straightEth = userInfo[reinvestAddress].straightEth.sub(amount);

            earningsProfits = userInfo[reinvestAddress].straightEth;
        } else if (value == 3) {
            require(userInfo[reinvestAddress].teamEth >= amount);
            userInfo[reinvestAddress].teamEth = userInfo[reinvestAddress].teamEth.sub(amount);

            earningsProfits = userInfo[reinvestAddress].teamEth;
        } else if (value == 4) {
            terminatorInstance.reInvestTerminatorReward(reinvestAddress, amount);
        }

        amount = earningsInstance.calculateReinvestAmount(msg.sender, amount, earningsProfits, value);

        calculateBuy(userInfo[reinvestAddress], amount, straightAddress, whiteAddress, adminAddress, reinvestAddress);

        straightReferralReward(userInfo[reinvestAddress], amount);

        emit Reinvest(reinvestAddress, amount, value, block.timestamp);
    }

    function withdraw(uint256 amount, uint8 value)
    public
    {

        address withdrawAddress = msg.sender;
        require(value == 1 || value == 2 || value == 3 || value == 4);

        uint256 _lockProfits = 0;
        uint256 _userRouteEth = 0;
        uint256 transValue = amount.mul(80).div(100);

        if (value == 1) {
            _userRouteEth = whetherTheCap();
            _lockProfits = SafeMath.mul(amount, remain).div(100);
        } else if (value == 2) {
            _userRouteEth = userInfo[withdrawAddress].straightEth;
        } else if (value == 3) {
            if (userInfo[withdrawAddress].staticTimeout) {
                require(userInfo[withdrawAddress].staticTime + 3 days >= block.timestamp);
            }
            _userRouteEth = userInfo[withdrawAddress].teamEth;
        } else if (value == 4) {
            _userRouteEth = amount.mul(80).div(100);
            terminatorInstance.modifyTerminatorReward(withdrawAddress, _userRouteEth);
        }

        earningsInstance.routeAddLockEth(withdrawAddress, amount, _lockProfits, _userRouteEth, value);

        address(uint160(withdrawAddress)).transfer(transValue);

        emit Withdraw(withdrawAddress, amount, value, block.timestamp);
    }

    function supportSubordinateAddress(uint256 index, address subordinate)
    public
    payable
    {

        User storage _user = userInfo[msg.sender];

        require(_user.ethAmount.sub(_user.tokenProfit.mul(100).div(120)) >= _user.refeTopAmount.mul(60).div(100));

        uint256 straightTime;
        address refeAddress;
        uint256 ethAmount;
        bool supported;
        (straightTime, refeAddress, ethAmount, supported) = recommendInstance.getRecommendByIndex(index, _user.userAddress);
        require(!supported);

        require(straightTime.add(3 days) >= block.timestamp && refeAddress == subordinate && msg.value >= ethAmount.div(10));

        if (_user.ethAmount.add(msg.value) >= _user.refeTopAmount.mul(60).div(100)) {
            _user.straightEth += ethAmount.mul(rewardRatio[2]).div(100);
        } else {
            _user.lockStraight += ethAmount.mul(rewardRatio[2]).div(100);
        }

        address straightAddress;
        address whiteAddress;
        address adminAddress;
        (straightAddress, whiteAddress, adminAddress,) = teamRewardInstance.getUserSystemInfo(subordinate);
        calculateBuy(userInfo[subordinate], msg.value, straightAddress, whiteAddress, adminAddress, subordinate);

        recommendInstance.setSupported(index, _user.userAddress, true);

        emit SupportSubordinateAddress(index, subordinate, refeAddress, supported);
    }

    function teamReferralReward(uint256 ethAmount, address referralStraightAddress)
    internal
    {

        if (teamRewardInstance.isWhitelistAddress(msg.sender)) {
            uint256 _systemRetain = ethAmount.mul(rewardRatio[3]).div(100);
            uint256 _nodeReward = _systemRetain.mul(activateSystem).div(100);
            systemRetain += _nodeReward;
            address(uint160(nodeAddressReward)).transfer(_nodeReward.mul(100 - activateGlobal).div(100));
            address(uint160(globalAddressReward)).transfer(_nodeReward.mul(activateGlobal).div(100));
            address(uint160(systemAddress)).transfer(_systemRetain.mul(100 - activateSystem).div(100));
        } else {
            uint256 _refeReward = ethAmount.mul(rewardRatio[3]).div(100);

            uint256 residueAmount = _refeReward;

            User memory currentUser = userInfo[referralStraightAddress];

            for (uint8 i = 2; i <= 12; i++) {//i start at 2, end at 12
                address straightAddress = currentUser.straightAddress;

                User storage currentUserStraight = userInfo[straightAddress];
                if (currentUserStraight.level >= i) {
                    uint256 currentReward = _refeReward.mul(teamRatio[i - 2]).div(29);
                    currentUserStraight.teamEth = currentUserStraight.teamEth.add(currentReward);
                    residueAmount = residueAmount.sub(currentReward);
                }

                currentUser = userInfo[straightAddress];
            }

            uint256 _nodeReward = residueAmount.mul(activateSystem).div(100);
            systemRetain = systemRetain.add(_nodeReward);
            address(uint160(systemAddress)).transfer(residueAmount.mul(100 - activateSystem).div(100));

            address(uint160(nodeAddressReward)).transfer(_nodeReward.mul(100 - activateGlobal).div(100));
            address(uint160(globalAddressReward)).transfer(_nodeReward.mul(activateGlobal).div(100));
        }
    }

    function updateTeamLevel(address refferAddress)
    internal
    {

        User memory currentUserStraight = userInfo[refferAddress];

        uint8 levelUpCount = 0;

        uint256 currentInviteCount = straightInviteAddress[refferAddress].length;
        if (currentInviteCount >= 2) {
            levelUpCount = 2;
        }

        if (currentInviteCount > 12) {
            currentInviteCount = 12;
        }

        uint256 lackCount = 0;
        for (uint8 j = 2; j < currentInviteCount; j++) {
            if (userSubordinateCount[refferAddress][j - 1] >= 1 + lackCount) {
                levelUpCount = j + 1;
                lackCount = 0;
            } else {
                lackCount++;
            }
        }

        if (levelUpCount > currentUserStraight.level) {
            uint8 oldLevel = userInfo[refferAddress].level;
            userInfo[refferAddress].level = levelUpCount;

            if (currentUserStraight.straightAddress != address(0)) {
                if (oldLevel > 0) {
                    if (userSubordinateCount[currentUserStraight.straightAddress][oldLevel - 1] > 0) {
                        userSubordinateCount[currentUserStraight.straightAddress][oldLevel - 1] = userSubordinateCount[currentUserStraight.straightAddress][oldLevel - 1] - 1;
                    }
                }

                userSubordinateCount[currentUserStraight.straightAddress][levelUpCount - 1] = userSubordinateCount[currentUserStraight.straightAddress][levelUpCount - 1] + 1;
                updateTeamLevel(currentUserStraight.straightAddress);
            }
        }
    }

    function calculateProfit(User storage user, uint256 ethAmount, address users)
    internal
    {

        if (teamRewardInstance.isWhitelistAddress(user.userAddress)) {
            ethAmount = ethAmount.mul(110).div(100);
        }

        uint256 userBonus = ethToBonus(ethAmount);
        require(userBonus >= 0 && SafeMath.add(userBonus, totalSupply) >= totalSupply);
        totalSupply += userBonus;
        uint256 tokenDivided = SafeMath.mul(ethAmount, rewardRatio[1]).div(100);
        getPerBonusDivide(tokenDivided, userBonus, users);
        user.profitAmount += userBonus;
    }

    function getPerBonusDivide(uint256 tokenDivided, uint256 userBonus, address users)
    public
    {

        uint256 fee = tokenDivided * magnitude;
        perBonusDivide += SafeMath.div(SafeMath.mul(tokenDivided, magnitude), totalSupply);
        fee = fee - (fee - (userBonus * (tokenDivided * magnitude / (totalSupply))));

        int256 updatedPayouts = (int256) ((perBonusDivide * userBonus) - fee);

        payoutsTo[users] += updatedPayouts;
    }

    function calculateToken(User storage user, uint256 ethAmount)
    internal
    {

        kocInstance.transfer(user.userAddress, ethAmount.mul(ratio));
        user.tokenAmount += ethAmount.mul(ratio);
    }

    function straightReferralReward(User memory user, uint256 ethAmount)
    internal
    {

        address _referralAddresses = user.straightAddress;
        userInfo[_referralAddresses].refeTopAmount = (userInfo[_referralAddresses].refeTopAmount > user.ethAmount) ? userInfo[_referralAddresses].refeTopAmount : user.ethAmount;
        userInfo[_referralAddresses].refeTopAddress = (userInfo[_referralAddresses].refeTopAmount > user.ethAmount) ? userInfo[_referralAddresses].refeTopAddress : user.userAddress;

        recommendInstance.pushRecommend(_referralAddresses, user.userAddress, ethAmount);

        if (teamRewardInstance.isWhitelistAddress(user.userAddress)) {
            uint256 _systemRetain = ethAmount.mul(rewardRatio[2]).div(100);

            uint256 _nodeReward = _systemRetain.mul(activateSystem).div(100);
            systemRetain += _nodeReward;
            address(uint160(systemAddress)).transfer(_systemRetain.mul(100 - activateSystem).div(100));

            address(uint160(globalAddressReward)).transfer(_nodeReward.mul(activateGlobal).div(100));
            address(uint160(nodeAddressReward)).transfer(_nodeReward.mul(100 - activateGlobal).div(100));
        }
    }

    function straightSortAddress(address referralAddress)
    internal
    {

        for (uint8 i = 0; i < 10; i++) {
            if (straightInviteAddress[straightSort[i]].length.sub(lastStraightLength[straightSort[i]]) < straightInviteAddress[referralAddress].length.sub(lastStraightLength[referralAddress])) {
                address  [] memory temp;
                for (uint j = i; j < 10; j++) {
                    temp[j] = straightSort[j];
                }
                straightSort[i] = referralAddress;
                for (uint k = i; k < 9; k++) {
                    straightSort[k + 1] = temp[k];
                }
            }
        }
    }

    function quickSort(address  [10] storage arr, int left, int right) internal {

        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = straightInviteAddress[arr[uint(left + (right - left) / 2)]].length.sub(lastStraightLength[arr[uint(left + (right - left) / 2)]]);
        while (i <= j) {
            while (straightInviteAddress[arr[uint(i)]].length.sub(lastStraightLength[arr[uint(i)]]) > pivot) i++;
            while (pivot > straightInviteAddress[arr[uint(j)]].length.sub(lastStraightLength[arr[uint(j)]])) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    function settleStraightRewards()
    internal
    {

        uint256 addressAmount;
        for (uint8 i = 0; i < 10; i++) {
            addressAmount += straightInviteAddress[straightSort[i]].length - lastStraightLength[straightSort[i]];
        }

        uint256 _straightSortRewards = SafeMath.div(straightSortRewards, 2);
        uint256 perAddressReward = SafeMath.div(_straightSortRewards, addressAmount);
        for (uint8 j = 0; j < 10; j++) {
            address(uint160(straightSort[j])).transfer(SafeMath.mul(straightInviteAddress[straightSort[j]].length.sub(lastStraightLength[straightSort[j]]), perAddressReward));
            straightSortRewards = SafeMath.sub(straightSortRewards, SafeMath.mul(straightInviteAddress[straightSort[j]].length.sub(lastStraightLength[straightSort[j]]), perAddressReward));
            lastStraightLength[straightSort[j]] = straightInviteAddress[straightSort[j]].length;
        }
        delete (straightSort);
        currentBlockNumber = block.number;
    }

    function ethToBonus(uint256 ethereum)
    internal
    view
    returns (uint256)
    {

        uint256 _price = bonusPrice * 1e18;
        uint256 _tokensReceived =
        (
        (
        SafeMath.sub(
            (sqrt
        (
            (_price ** 2)
            +
            (2 * (priceIncremental * 1e18) * (ethereum * 1e18))
            +
            (((priceIncremental) ** 2) * (totalSupply ** 2))
            +
            (2 * (priceIncremental) * _price * totalSupply)
        )
            ), _price
        )
        ) / (priceIncremental)
        ) - (totalSupply);

        return _tokensReceived;
    }

    function sqrt(uint x) internal pure returns (uint y) {

        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function myBonusProfits(address user)
    view
    public
    returns (uint256)
    {

        return (uint256) ((int256)(perBonusDivide.mul(userInfo[user].profitAmount)) - payoutsTo[user]).div(magnitude);
    }

    function whetherTheCap()
    internal
    returns (uint256)
    {

        require(userInfo[msg.sender].ethAmount.mul(120).div(100) >= userInfo[msg.sender].tokenProfit);
        uint256 _currentAmount = userInfo[msg.sender].ethAmount.sub(userInfo[msg.sender].tokenProfit.mul(100).div(120));
        uint256 topProfits = _currentAmount.mul(remain + 100).div(100);
        uint256 userProfits = myBonusProfits(msg.sender);

        if (userProfits > topProfits) {
            userInfo[msg.sender].profitAmount = 0;
            payoutsTo[msg.sender] = 0;
            userInfo[msg.sender].tokenProfit += topProfits;
            userInfo[msg.sender].staticTime = block.timestamp;
            userInfo[msg.sender].staticTimeout = true;
        }

        if (topProfits == 0) {
            topProfits = userInfo[msg.sender].tokenProfit;
        } else {
            topProfits = (userProfits >= topProfits) ? topProfits : userProfits.add(userInfo[msg.sender].tokenProfit); // not add again
        }

        return topProfits;
    }

    function setStraightSortRewards()
    public
    onlyAdmin()
    returns (bool)
    {

        require(currentBlockNumber + blockNumber < block.number);
        settleStraightRewards();
        return true;
    }

    function getStraightSortList()
    public
    view
    returns (address[10] memory)
    {

        return straightSort;
    }

    function getStraightInviteAddress()
    public
    view
    returns (address[] memory)
    {

        return straightInviteAddress[msg.sender];
    }

    function getcurrentBlockNumber()
    public
    view
    returns (uint256){

        return currentBlockNumber;
    }

    function getPurchaseTasksInfo()
    public
    view
    returns (
        uint256 ethAmount,
        uint256 refeTopAmount,
        address refeTopAddress,
        uint256 lockStraight
    )
    {

        User memory getUser = userInfo[msg.sender];
        ethAmount = getUser.ethAmount.sub(getUser.tokenProfit.mul(100).div(120));
        refeTopAmount = getUser.refeTopAmount;
        refeTopAddress = getUser.refeTopAddress;
        lockStraight = getUser.lockStraight;
    }

    function getPersonalStatistics()
    public
    view
    returns (
        uint256 holdings,
        uint256 dividends,
        uint256 invites,
        uint8 level,
        uint256 afterFounds,
        uint256 referralRewards,
        uint256 teamRewards,
        uint256 nodeRewards
    )
    {

        User memory getUser = userInfo[msg.sender];

        uint256 _withdrawStatic;
        (_withdrawStatic, afterFounds) = earningsInstance.getStaticAfterFounds(getUser.userAddress);

        holdings = getUser.ethAmount.sub(getUser.tokenProfit.mul(100).div(120));
        dividends = (myBonusProfits(msg.sender) >= holdings.mul(120).div(100)) ? holdings.mul(120).div(100) : myBonusProfits(msg.sender);
        invites = straightInviteAddress[msg.sender].length;
        level = getUser.level;
        referralRewards = getUser.straightEth;
        teamRewards = getUser.teamEth;
        uint256 _nodeRewards = (totalEthAmount == 0) ? 0 : whitelistPerformance[msg.sender].mul(systemRetain).div(totalEthAmount);
        nodeRewards = (whitelistPerformance[msg.sender] < 500 ether) ? 0 : _nodeRewards;
    }

    function getUserBalance()
    public
    view
    returns (
        uint256 staticBalance,
        uint256 recommendBalance,
        uint256 teamBalance,
        uint256 terminatorBalance,
        uint256 nodeBalance,
        uint256 totalInvest,
        uint256 totalDivided,
        uint256 withdrawDivided
    )
    {

        User memory getUser = userInfo[msg.sender];
        uint256 _currentEth = getUser.ethAmount.sub(getUser.tokenProfit.mul(100).div(120));

        uint256 withdrawStraight;
        uint256 withdrawTeam;
        uint256 withdrawStatic;
        uint256 withdrawNode;
        (withdrawStraight, withdrawTeam, withdrawStatic, withdrawNode) = earningsInstance.getUserWithdrawInfo(getUser.userAddress);

        uint256 _staticReward = (getUser.ethAmount.mul(120).div(100) > withdrawStatic.mul(100).div(80)) ? getUser.ethAmount.mul(120).div(100).sub(withdrawStatic.mul(100).div(80)) : 0;

        uint256 _staticBonus = (withdrawStatic.mul(100).div(80) < myBonusProfits(msg.sender).add(getUser.tokenProfit)) ? myBonusProfits(msg.sender).add(getUser.tokenProfit).sub(withdrawStatic.mul(100).div(80)) : 0;

        staticBalance = (myBonusProfits(getUser.userAddress) >= _currentEth.mul(remain + 100).div(100)) ? _staticReward.sub(userReinvest[getUser.userAddress].staticReinvest) : _staticBonus.sub(userReinvest[getUser.userAddress].staticReinvest);

        recommendBalance = getUser.straightEth.sub(withdrawStraight.mul(100).div(80));
        teamBalance = getUser.teamEth.sub(withdrawTeam.mul(100).div(80));
        terminatorBalance = terminatorInstance.getTerminatorRewardAmount(getUser.userAddress);
        nodeBalance = 0;
        totalInvest = getUser.ethAmount;
        totalDivided = getUser.tokenProfit.add(myBonusProfits(getUser.userAddress));
        withdrawDivided = earningsInstance.getWithdrawStatic(getUser.userAddress).mul(100).div(80);
    }

    function contractStatistics()
    public
    view
    returns (
        uint256 recommendRankPool,
        uint256 terminatorPool
    )
    {

        recommendRankPool = straightSortRewards;
        terminatorPool = getCurrentTerminatorAmountPool();
    }

    function listNodeBonus(address node)
    public
    view
    returns (
        address nodeAddress,
        uint256 performance
    )
    {

        nodeAddress = node;
        performance = whitelistPerformance[node];
    }

    function listRankOfRecommend()
    public
    view
    returns (
        address[10] memory _straightSort,
        uint256[10] memory _inviteNumber
    )
    {

        for (uint8 i = 0; i < 10; i++) {
            if (straightSort[i] == address(0)){
                break;
            }
            _inviteNumber[i] = straightInviteAddress[straightSort[i]].length.sub(lastStraightLength[straightSort[i]]);
        }
        _straightSort = straightSort;
    }

    function getCurrentEffectiveUser()
    public
    view
    returns (uint256)
    {

        return initAddressAmount;
    }
    function addTerminator(address addr)
    internal
    {

        uint256 allInvestAmount = userInfo[addr].ethAmount.sub(userInfo[addr].tokenProfit.mul(100).div(120));
        uint256 withdrawAmount = terminatorInstance.checkBlockWithdrawAmount(block.number);
        terminatorInstance.addTerminator(addr, allInvestAmount, block.number, (terminatorPoolAmount - withdrawAmount).div(2));
    }

    function isLockWithdraw()
    public
    view
    returns (
        bool isLock,
        uint256 lockTime
    )
    {

        isLock = userInfo[msg.sender].staticTimeout;
        lockTime = userInfo[msg.sender].staticTime;
    }

    function modifyActivateSystem(uint256 value)
    mustAdmin(msg.sender)
    public
    {

        activateSystem = value;
    }

    function modifyActivateGlobal(uint256 value)
    mustAdmin(msg.sender)
    public
    {

        activateGlobal = value;
    }

    function getCurrentTerminatorAmountPool()
    view public
    returns(uint256 amount)
    {

        return terminatorPoolAmount-terminatorInstance.checkBlockWithdrawAmount(block.number);
    }
}
