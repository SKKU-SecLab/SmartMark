



pragma solidity <=0.7.5;



pragma solidity ^0.5.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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


contract TokenMintERC20Token is ERC20 {


    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint8 private _platform_fees = 1;
    address private _platform_fees_receiver;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, address payable feeReceiver, address tokenOwnerAddress) public payable {
      _name = name;
      _symbol = symbol;
      _decimals = decimals;
     _platform_fees_receiver = feeReceiver;
      _mint(tokenOwnerAddress, totalSupply);

      feeReceiver.transfer(msg.value);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        
      uint256 fees = amount.mul(_platform_fees).div(100);
      uint256 amountAfterDeductingFees = amount.sub(fees);

      _transfer(msg.sender, recipient, amountAfterDeductingFees);
      _transfer(msg.sender, _platform_fees_receiver, fees);
      
      return true;
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

contract DeganDarkBundles is ReentrancyGuard {

    
    uint256 public bundleId = 1;
    address public owner;
    
    
    TokenMintERC20Token public bundle_address;
    
    
    uint256 public fee_collected;       
    
    
    uint256 public lastcreated;
    uint256 lastbundlecreated;

    struct UserBets{
        uint256 bundles;
        uint256 amounts;
        uint256 prices;
        bool betted;
        uint256 balance;
        uint256 totalbet;
        bool claimed;
        uint256 index;
    }
    
    struct User{
        uint256[] bundles;
        uint256 balance;
        uint256 freebal;
    }
    
    struct Data{
        address[] user;
    }
    
    struct Bundle{
        uint256[20] prices;
        uint256 startime;
        uint256 stakingends;
        uint256 endtime;
    }
    
    mapping(address => mapping(uint256 => UserBets)) bets;
    mapping(uint256 => Bundle) bundle;
    mapping(address => User) user;
    mapping(uint256 => Data) data;
    
    constructor(address _bundle_address) public{
        owner = msg.sender;
        bundle_address = TokenMintERC20Token(_bundle_address);
        lastcreated = block.timestamp;
    }
    
    
    
    
    function PlaceBet(uint256 index,uint256 _prices,uint256 _percent,uint256 _bundleId,uint256 _amount) public returns(bool){

        require(_bundleId <= bundleId,'Invalid Bundle');
        require(bundle_address.allowance(msg.sender,address(this))>=_amount,'Approval failed');
        Bundle storage b = bundle[_bundleId];
        Data storage d = data[_bundleId];
        require(b.stakingends >= block.timestamp,'Ended');
        User storage us = user[msg.sender];
        UserBets storage u = bets[msg.sender][_bundleId];
        require(u.bundles == 0,'Already Betted');
        if(u.betted == false){
            u.balance = bundle_address.balanceOf(msg.sender);
            u.betted = true;
        }
        else{
            require(SafeMath.add(u.totalbet,_amount) <= u.balance,'Threshold Reached');
        }
        us.bundles.push(_bundleId);
        us.balance = SafeMath.add(us.balance,_amount);
        u.bundles = _percent; 
        u.prices = _prices; 
        u.amounts = _amount;
        u.index = index;
        u.totalbet = u.totalbet + _amount;
        d.user.push(msg.sender);
        bundle_address.transferFrom(msg.sender,address(this),_amount);
        return true;
    }
    
    function updatebal(address _user,uint256 _bundleId,uint256 _reward,bool _isPositive) public returns(bool){

        require(msg.sender == owner,'Not Owner');
        require(_reward <= 50000000,'Invalid Reward Percent');
        User storage us = user[_user];
        UserBets storage u = bets[_user][_bundleId];
        require(u.claimed == false,'Already Claimed');
        if(_isPositive == true){
            updateFee(_reward,u.totalbet);
            uint256 temp = SafeMath.mul(_reward,90);
            uint256 reward = SafeMath.div(temp,100);
            uint256 a = SafeMath.mul(u.totalbet,reward);
            uint256 b = SafeMath.div(a,10**8);
            uint256 c = SafeMath.add(u.totalbet,b);
            u.claimed = true;
            us.freebal = SafeMath.add(c,us.freebal);
            us.balance = SafeMath.sub(us.balance,u.totalbet);
        }
        else{
            uint256 a = SafeMath.mul(u.totalbet,_reward);
            uint256 b = SafeMath.div(a,10**8);
            uint256 c = SafeMath.sub(u.totalbet,b);
            u.claimed = true;
            us.freebal = SafeMath.add(c,us.freebal);
            us.balance = SafeMath.sub(us.balance,u.totalbet);
        }
        return true;
    }
    
    
    function updateFee(uint256 r,uint256 amt) internal{

        uint256 temp = SafeMath.mul(r,10);
        uint256 reward = SafeMath.div(temp,100);
        uint256 a = SafeMath.mul(amt,reward);
        uint256 b = SafeMath.div(a,10**8);
        fee_collected = SafeMath.add(fee_collected,b);
    }
    
    
    function createBundle(uint256[20] memory _prices) public returns(bool){

        require(msg.sender == owner,'Not Owner');
        require( block.timestamp > lastbundlecreated +  1 days,'Cannot Create');
        Bundle storage b = bundle[bundleId];
        b.prices = _prices;
        b.startime = block.timestamp;
        lastbundlecreated = block.timestamp;
        lastcreated = block.timestamp;
        b.endtime = SafeMath.add(block.timestamp,1 days);
        b.stakingends = SafeMath.add(block.timestamp,12 hours);
        bundleId = SafeMath.add(bundleId,1);
        return true;
    }
    
    
    function updateowner(address new_owner) public returns(bool){

        require(msg.sender == owner,'Not an Owner');
        owner = new_owner;
        return true;
    }
    
    
    function updatetime(uint256 _timestamp) public returns(bool){

        require(msg.sender == owner,'Not an owner');
        lastcreated =  _timestamp;
    }
    
    
    function withdraw() public nonReentrant returns(bool){

       User storage us = user[msg.sender];
       require(us.freebal > 0,'No bal');
       bundle_address.transfer(msg.sender,us.freebal);
       us.freebal = 0;
       return true;
    }
    
     
    function fetchUser(address _user) public view returns(uint256[] memory _bundles,uint256 claimable,uint256 staked_balance){

        User storage us = user[_user];
        return(us.bundles,us.freebal,us.balance);
    }
    
    
    function fetchBundle(uint256 _bundleId) public view returns(uint256[20] memory _prices,uint256 _start,uint256 _end,uint256 _staking_ends){

        Bundle storage b = bundle[_bundleId];
        return(b.prices,b.startime,b.endtime,b.stakingends);
    }
    
    
    function fetchUserBets(address _user, uint256 _bundleId) public view returns(uint256 _bundles,uint256 _prices,uint256 _amounts,uint256 balance,uint256 totalbet,uint256 index){

        UserBets storage u = bets[_user][_bundleId];
        return (u.bundles,u.prices,u.amounts,u.balance,u.totalbet,u.index);
    }
    
    
    function fetchUserInBundle(uint256 _bundleId) public view returns(address[] memory _betters){

        Data storage d = data[_bundleId];
        return d.user;
    }
    
    
    function collectdeveloperfee() public nonReentrant returns(bool){

        require(msg.sender == owner,'To Be Claimed By Developer');
        bundle_address.transfer(msg.sender,fee_collected);
        fee_collected = 0;
        return true;
    }
    
}