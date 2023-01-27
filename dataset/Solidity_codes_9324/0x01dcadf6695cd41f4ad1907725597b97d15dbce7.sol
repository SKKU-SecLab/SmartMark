
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


contract MASToken is ERC20, Ownable {
    using SafeMath for uint256;

    struct VestingPlan {
        uint256 vType;
        uint256 totalBalance;
        uint256 totalClaimed;
        uint256 start;
        uint256 end;
        uint256 cliff;
        uint256 releasePercentWhenStart;
        uint256 releasePercentEachMonth;
        uint256 claimedCheckPoint;
    }

    mapping (address => VestingPlan) public vestingList;

    uint256 private _totalSupply            = 1000000000 * 10**18;
        
    uint256 private MONTH                   = 30 * 24 * 60 * 60;
    uint256 private PERCENT_ACCURACY        = 1000000;

    uint256 public totalTokenForSeed        = _totalSupply.mul(6667).div(PERCENT_ACCURACY);
    uint256 public totalTokenForPrivate     = _totalSupply.mul(75000).div(PERCENT_ACCURACY);
    uint256 public totalTokenForPublic      = _totalSupply.mul(50000).div(PERCENT_ACCURACY);
    uint256 public totalTokenForAdvisor     = _totalSupply.mul(50000).div(PERCENT_ACCURACY);
    uint256 public totalTokenForTeam        = _totalSupply.mul(200000).div(PERCENT_ACCURACY);
    uint256 public totalTokenForDexCex      = _totalSupply.mul(200000).div(PERCENT_ACCURACY);
    uint256 public totalTokenForEcosystem   = _totalSupply.mul(78333).div(PERCENT_ACCURACY);
    uint256 public totalTokenForReserve     = _totalSupply.mul(90000).div(PERCENT_ACCURACY);
    uint256 public totalTokenForCommunity   = _totalSupply.mul(250000).div(PERCENT_ACCURACY);


    uint256 public totalDistributedTokenForSeed        = 0;
    uint256 public totalDistributedTokenForPrivate     = 0;
    uint256 public totalDistributedTokenForPublic      = 0;
    uint256 public totalDistributedTokenForAdvisor     = 0;
    uint256 public totalDistributedTokenForTeam        = 0;
    uint256 public totalDistributedTokenForDexCex      = 0;
    uint256 public totalDistributedTokenForEcosystem   = 0;
    uint256 public totalDistributedTokenForReserve     = 0;
    uint256 public totalDistributedTokenForCommunity   = 0;

    uint8 public VEST_TYPE_SEED     = 1;
    uint8 public VEST_TYPE_PRIVATE  = 2;
    uint8 public VEST_TYPE_PUBLIC  = 3;
    uint8 public VEST_TYPE_ADVISOR  = 4;
    uint8 public VEST_TYPE_TEAM = 5;
    uint8 public VEST_TYPE_DEXCEX = 6;
    uint8 public VEST_TYPE_ECO = 7;
    uint8 public VEST_TYPE_RESERVE = 8;
    uint8 public VEST_TYPE_COMMUNITY = 9;


    constructor () ERC20("MAS Token", "MAS") {
        _mint(owner(), totalTokenForPublic.add(totalTokenForReserve)); //Public & Reserve

        uint256 totalVestToken = totalTokenForSeed + totalTokenForPrivate + totalTokenForAdvisor + totalTokenForTeam + totalTokenForDexCex + totalTokenForEcosystem + totalTokenForCommunity;
        _mint(address(this), totalVestToken); // Total vesting token

        addingVestToken(owner(), totalTokenForDexCex, VEST_TYPE_DEXCEX);
        addingVestToken(0xd3bcd0Aa1EAF0a3A91b45F541DcaA498E8E78180, 70000000 * 10**18, VEST_TYPE_TEAM);
        addingVestToken(0x4f6166b6EA7E637D2c0273580d84DaFb574EFb7B, 130000000 * 10**18, VEST_TYPE_TEAM);
        
    }

    function addingVestToken(address account, uint256 amount, uint8 vType) public onlyOwner {
        VestingPlan storage vestPlan = vestingList[account];
        if(vType == VEST_TYPE_SEED){
            require(totalDistributedTokenForSeed.add(amount) <= totalTokenForSeed, "Exceed token for SEED");
            totalDistributedTokenForSeed = totalDistributedTokenForSeed.add(amount);
            vestPlan.cliff = 3;
            vestPlan.releasePercentWhenStart = 220000;
            vestPlan.releasePercentEachMonth = 32500;
        }else if(vType == VEST_TYPE_PRIVATE){
            require(totalDistributedTokenForPrivate.add(amount) <= totalTokenForPrivate, "Exceed token for PRIVATE");
            totalDistributedTokenForPrivate = totalDistributedTokenForPrivate.add(amount);
            vestPlan.cliff = 3;
            vestPlan.releasePercentWhenStart = 220000;
            vestPlan.releasePercentEachMonth = 32500;
        }else if(vType == VEST_TYPE_ADVISOR){
            require(totalDistributedTokenForAdvisor.add(amount) <= totalTokenForAdvisor, "Exceed token for ADVISOR");
            totalDistributedTokenForAdvisor = totalDistributedTokenForAdvisor.add(amount);
            vestPlan.cliff = 4;
            vestPlan.releasePercentWhenStart = 205000;
            vestPlan.releasePercentEachMonth = 66250;
        }else if(vType == VEST_TYPE_TEAM){
            require(totalDistributedTokenForTeam.add(amount) <= totalTokenForTeam, "Exceed token for TEAM");
            totalDistributedTokenForTeam = totalDistributedTokenForTeam.add(amount);
            vestPlan.cliff = 4;
            vestPlan.releasePercentWhenStart = 205000;
            vestPlan.releasePercentEachMonth = 66250;
        }else if(vType == VEST_TYPE_DEXCEX){
            require(totalDistributedTokenForDexCex.add(amount) <= totalTokenForDexCex, "Exceed token for DEXCEX");
            totalDistributedTokenForDexCex = totalDistributedTokenForDexCex.add(amount);
            vestPlan.cliff = 0;
            vestPlan.releasePercentWhenStart = 300000;
            vestPlan.releasePercentEachMonth = 19444;
        }else if(vType == VEST_TYPE_ECO){
            require(totalDistributedTokenForEcosystem.add(amount) <= totalTokenForEcosystem, "Exceed token for ECOSYSTEM");
            totalDistributedTokenForEcosystem = totalDistributedTokenForEcosystem.add(amount);
            vestPlan.cliff = 0;
            vestPlan.releasePercentWhenStart = 50000;
            vestPlan.releasePercentEachMonth = 26333;
        }else if(vType == VEST_TYPE_COMMUNITY){
            require(totalDistributedTokenForCommunity.add(amount) <= totalTokenForCommunity, "Exceed token for COMMUNITY");
            totalDistributedTokenForCommunity = totalDistributedTokenForCommunity.add(amount);
            vestPlan.cliff = 0;
            vestPlan.releasePercentWhenStart = 50000;
            vestPlan.releasePercentEachMonth = 26333;
        }else {
            require(false, "Wrong vesting type!");
        }
 
        vestPlan.vType = vType;
        vestPlan.totalBalance = amount;
        vestPlan.claimedCheckPoint = 0;

        if(vType == VEST_TYPE_DEXCEX || vType == VEST_TYPE_ECO ||  vType == VEST_TYPE_COMMUNITY){
            vestPlan.start = block.timestamp;
            vestPlan.end = block.timestamp + vestPlan.cliff * MONTH + ((PERCENT_ACCURACY - vestPlan.releasePercentWhenStart)/vestPlan.releasePercentEachMonth) * MONTH;
            vestPlan.totalClaimed = (vestPlan.totalBalance * vestPlan.releasePercentWhenStart)/PERCENT_ACCURACY;
            if(vestPlan.totalClaimed > 0){
                _transfer(address(this), account, vestPlan.totalClaimed);
            }
        }
    }

    uint256 public launchTime;
    function launch() public onlyOwner {
        launchTime = block.timestamp;
    }

    function getClaimableToken(address account) public view returns (uint256){
        VestingPlan memory vestPlan = vestingList[account];

        if(vestPlan.totalClaimed == vestPlan.totalBalance){
            return 0;
        }

        uint256 claimableAmount = 0;
        uint256 vestStart = vestPlan.start; 
        uint256 vestEnd = vestPlan.end; 

        if(block.timestamp > launchTime && launchTime > 0){
            if(vestStart == 0){ //In case private/seed/team/advisor, already launched, first time withdraw 
                vestStart = launchTime;
                vestEnd = vestStart + vestPlan.cliff * MONTH + ((PERCENT_ACCURACY - vestPlan.releasePercentWhenStart)/vestPlan.releasePercentEachMonth) * MONTH;
                if(vestPlan.vType == VEST_TYPE_SEED || vestPlan.vType == VEST_TYPE_PRIVATE){
                    claimableAmount = (vestPlan.totalBalance * vestPlan.releasePercentWhenStart)/PERCENT_ACCURACY;
                }

                if(vestPlan.vType == VEST_TYPE_TEAM || vestPlan.vType == VEST_TYPE_ADVISOR){
                    if(block.timestamp >= launchTime + 3*MONTH)
                        claimableAmount = (vestPlan.totalBalance * vestPlan.releasePercentWhenStart)/PERCENT_ACCURACY;
                }
            }
        }

        if(vestStart == 0 || vestEnd == 0){
            return 0;
        }

        if(block.timestamp <= vestStart + vestPlan.cliff * MONTH ){
            return claimableAmount;
        }else { 
            uint256 currentTime = block.timestamp;
            if(currentTime > vestEnd){
                currentTime = vestEnd;
            }

            uint256 currentCheckPoint = 1 + (currentTime - vestStart - vestPlan.cliff * MONTH) / MONTH;
            if(currentCheckPoint > vestPlan.claimedCheckPoint){
                uint256 claimable =  ((currentCheckPoint - vestPlan.claimedCheckPoint)* vestPlan.releasePercentEachMonth * vestPlan.totalBalance) / PERCENT_ACCURACY;
                return claimable.add(claimableAmount);
            }else {
                return claimableAmount;
            }
        }
    }

    function balanceRemainingInVesting(address account) public view returns(uint256){
        VestingPlan memory vestPlan = vestingList[account];
        return vestPlan.totalBalance -  vestPlan.totalClaimed;
    }

    function withDrawFromVesting() public{
        VestingPlan storage vestPlan = vestingList[msg.sender];

        uint256 claimableAmount = getClaimableToken(msg.sender);
        require(claimableAmount > 0, "There isn't token in vesting that claimable at the moment");
        require(vestPlan.totalClaimed.add(claimableAmount) <= vestPlan.totalBalance, "Can't claim amount that exceed totalBalance");


        if(vestPlan.start == 0){ // For team/advisor/seed/private, release token after TGE
            vestPlan.start = launchTime;
            vestPlan.end = launchTime + vestPlan.cliff * MONTH + ((PERCENT_ACCURACY - vestPlan.releasePercentWhenStart)/vestPlan.releasePercentEachMonth) * MONTH;
        }

        uint256 currentTime = block.timestamp;
        if(currentTime > vestPlan.end){
            currentTime = vestPlan.end;
        }
        
        if(currentTime >= vestPlan.start + vestPlan.cliff * MONTH) // Only update checkpoint after cliff time
            vestPlan.claimedCheckPoint = 1 + (currentTime - vestPlan.start - vestPlan.cliff * MONTH) / MONTH;

        vestPlan.totalClaimed = vestPlan.totalClaimed.add(claimableAmount);

        _transfer(address(this), msg.sender, claimableAmount);
    }
}