pragma solidity >=0.4.23 <0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity >=0.4.23 <0.7.0;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {

    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

pragma solidity >=0.4.23 <0.7.0;



contract Distribute is IERC20 {

    using SafeMath for uint256;

    event Stake(address indexed user);
    event Purchase(address indexed user, uint256 amount);
    event Withdraw(address indexed user);

    string public name = "ANALYSX";
    string public symbol = "XYS";
    uint256 public decimals = 6;

    uint256 private _totalSupply = 40000000 * (10 ** decimals);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) public _staked;

    mapping (address => uint256) private _earned;

    mapping (address => bool) public _isStaked;

    address[100] private _stakeList;

    uint256 public _initialFee = 100000 * (10 ** decimals);

    uint256 public _stakeFee;

    uint256 public _totalStaked;

    uint256 public _lastStakerTime;

    address payable _owner;


    constructor(address payable owner) public {

        _mint(owner, _totalSupply);

        _owner = owner;  

        _stakeFee = _initialFee;

        _lastStakerTime = block.timestamp;

        for (uint i = 0; i <= 99; i++) {
            _stakeList[i] = _owner;
        }

    }


    function totalSupply() override public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) override public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) override public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) override public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) override public returns (bool) {

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


    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    } 

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function changeOwner(address payable newOwner) public onlyOwner {

        _owner = newOwner;
    }

    function checkReward() public view returns (uint256) {

        return _earned[msg.sender];
    }

    function showStakers() public view returns (address[100] memory) {

        return _stakeList;
    }

    function stake() public {

        require(msg.sender != _owner, "Owner cannot stake");
        require(_balances[msg.sender] >= _stakeFee, "Insufficient Tokens");
        require(_isStaked[msg.sender] == false, "You are already staking");
        require(_staked[msg.sender] == 0, "You have stake"); // Maybe redundant?

        _balances[msg.sender] = _balances[msg.sender].sub(_stakeFee);
        _staked[msg.sender] = _stakeFee;
        _totalStaked = _totalStaked.add(_stakeFee);

        uint256 stakeIncrease = _stakeFee.div(100);
        _stakeFee = _stakeFee.add(stakeIncrease);
        _lastStakerTime = block.timestamp;

        updateStaking();

        emit Stake(msg.sender);

    }
    
    function exitStake() public returns(bool) {

        require(msg.sender != _owner, "owner cannot exit");
        require(_isStaked[msg.sender] == true, "You are not staking");
        require(_staked[msg.sender] != 0, "You don't have stake"); // Maybe redundant?
        
        for (uint i = 0; i < 99; i++) {
            if (_stakeList[i] == msg.sender) {
                _balances[msg.sender] = _balances[msg.sender].add(_earned[msg.sender]).add(_staked[msg.sender]);
                _staked[msg.sender] = 0;
                _earned[msg.sender] = 0;
                _stakeList[i] = _owner;
                _isStaked[msg.sender] = false;
                return true;
            }
        }
        return false;
    }

    function updateStaking() internal {


        address lastUser = _stakeList[99];
        _balances[lastUser] = _balances[lastUser].add(_staked[lastUser]);
        _staked[lastUser] = 0;
        _isStaked[lastUser] = false;
        
        _balances[lastUser] = _balances[lastUser].add(_earned[lastUser]);
        _earned[lastUser] = 0;

        for (uint i = 99; i > 0; i--) {
            uint previous = i.sub(1);
            address previousUser = _stakeList[previous];
            _stakeList[i] = previousUser;
        }

        _stakeList[0] = msg.sender;
        _isStaked[msg.sender] = true;
    }

    function purchaseService(uint256 price, address purchaser) public {

        
        require (_balances[purchaser] >= price, "Insufficient funds");
        
        require (price > 1000, "Value too Small");

        uint256 ownerShare = price.div(10);
        uint256 toSplit = price.sub(ownerShare);
        uint256 stakeShare = toSplit.div(100);
        _earned[_owner] = _earned[_owner].add(ownerShare);

        for (uint i = 0; i < 99; i++) {
            
            _earned[_stakeList[i]] = _earned[_stakeList[i]].add(stakeShare);
            
            toSplit = toSplit.sub(stakeShare);
        }
        
        _earned[_stakeList[99]] = _earned[_stakeList[99]].add(toSplit);
        
        _balances[purchaser] = _balances[purchaser].sub(price);

        emit Purchase(purchaser, price);
    }

    function withdraw() public {

        require(_earned[msg.sender] > 0, "Stake some more");
        _balances[msg.sender] = _balances[msg.sender].add(_earned[msg.sender]);
        _earned[msg.sender] = 0;

        emit Withdraw(msg.sender);
    }

    function stakeReset() public  onlyOwner {

        require(block.timestamp.sub(_lastStakerTime) >= 2592000, "not enough time has passed");
        _stakeFee = _initialFee;
    }
}//"UNLICENSED
pragma solidity ^0.6.0;
abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}// UNLICENSED
pragma solidity ^0.6.0;


contract XYSPurchasePortal{

    
    using SafeMath for uint256;
    
    Distribute dst = Distribute(0x88277055dF2EE38dA159863dA2F56ee0A6909D62);
    
    struct Asset{
        bool isAccepted;
        uint256 rate;
        string name;
        string symbol;
        uint256 decimal;
    }
    mapping(address => Asset) paymentAssets;
    
    address constant private ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    
    address constant private DAI_ADDRESS = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    
    address payable constant private FUNDS_RECEIVING_WALLET = 0x794Ce138d9dECf241d0b197deCcCb02f37291DD2;
    
    uint256 public rateIncrementCount = 0;
    uint256 public soldTokens = 0;
    
    event TOKENSPURCHASED(address _purchaser, uint256 _tokens);
    event PAYMENTRECEIVED(address _purchaser, uint256 _amount, address _assetAddress);
    
    constructor() public {
        paymentAssets[DAI_ADDRESS].isAccepted = true;
        paymentAssets[DAI_ADDRESS].rate = 50; // per DAI part
        paymentAssets[DAI_ADDRESS].name = "DAI Stable coin";
        paymentAssets[DAI_ADDRESS].symbol = "DAI"; // per DAI part
        paymentAssets[DAI_ADDRESS].decimal = 18; // decimals
        
        paymentAssets[ETH_ADDRESS].isAccepted = true;
        paymentAssets[ETH_ADDRESS].rate = 11905;
        paymentAssets[ETH_ADDRESS].name = "Ethers";
        paymentAssets[ETH_ADDRESS].symbol = "ETH";
        paymentAssets[ETH_ADDRESS].decimal = 18; // decimals
    }
    
    function purchase(address assetAddress, uint256 amountAsset) public payable{

        require(paymentAssets[assetAddress].isAccepted, "NOT ACCEPTED: Unaccepted payment asset provided");
        require(dst.balanceOf(address(this)) >= getTokenAmount(assetAddress, amountAsset), "XYS Balance: Insufficient liquidity");
        _purchase(assetAddress, amountAsset);
    }
    
    fallback() external payable{
        require(dst.balanceOf(address(this)) >= getTokenAmount(ETH_ADDRESS, msg.value), "XYS Balance: Insufficient liquidity");
        _purchase(ETH_ADDRESS, msg.value);
    }
    
    receive() external payable{
        require(dst.balanceOf(address(this)) >= getTokenAmount(ETH_ADDRESS, msg.value), "XYS Balance: Insufficient liquidity");
        _purchase(ETH_ADDRESS, msg.value);
    }
    
    function _purchase(address assetAddress, uint256 assetAmount) internal{

        if(assetAddress ==  ETH_ADDRESS){
            FUNDS_RECEIVING_WALLET.transfer(assetAmount);
            require(assetAmount >= 0.5 ether, "ETHERS: minimum purchase allowed is 0.5 ethers");
        }
        else{
            require(assetAmount >= 120 * 10 ** (paymentAssets[assetAddress].decimal), "DAI: minimum purchase allowed is 120 DAI");
            ERC20Interface(assetAddress).transferFrom(msg.sender, FUNDS_RECEIVING_WALLET, assetAmount);
        }
        uint256 tokens = getTokenAmount(assetAddress, assetAmount);
        dst.transfer(msg.sender, tokens);
        
        soldTokens += tokens;
        
        if(soldTokens/1000000000000 > 0)
            rateIncrementCount = soldTokens /1000000000000 ;
        
        emit TOKENSPURCHASED(msg.sender, tokens);
        emit PAYMENTRECEIVED(msg.sender, assetAmount, assetAddress);
    }
    
    function getTokenAmount(address assetAddress, uint256 assetAmount) public view returns(uint256){

        uint256 tokens = (paymentAssets[assetAddress].rate * assetAmount / 10 ** (paymentAssets[assetAddress].decimal - dst.decimals()));
        return  tokens - onePercent(tokens) * (5 * rateIncrementCount); 
    }
    
    function onePercent(uint256 _amount) internal pure returns (uint256){

        uint roundValue = _amount.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
}