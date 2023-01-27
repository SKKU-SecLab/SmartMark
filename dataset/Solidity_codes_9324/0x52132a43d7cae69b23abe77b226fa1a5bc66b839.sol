
pragma solidity 0.5.16;


contract Owned {


    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed _to);

    constructor(address _owner) public {
        owner = _owner;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        newOwner = _newOwner;
    }
    function acceptOwnership() external {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Owned {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {

      require(!paused);
      _;
    }

    modifier whenPaused() {

      require(paused);
      _;
    }

    function pause() onlyOwner whenNotPaused external {

      paused = true;
      emit Pause();
    }

    function unpause() onlyOwner whenPaused external {

      paused = false;
      emit Unpause();
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


}

library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}




contract ERC20 is IERC20, Pausable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }


    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
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

    function _transferFrom(address sender, address recipient, uint256 amount) internal whenNotPaused returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }


    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}



contract Truample is ERC20 {


    using SafeMath for uint256;
    using SafeMathInt for int256;

    string public constant name = "Truample";
    string public constant symbol = "TMPL";
    uint8  public constant decimals = 9;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event RebaseContractInitialized(address reBaseAdress);

    address public reBaseContractAddress; 
    modifier validRecipient(address to) {


        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 3000000*(10**uint256(decimals));
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0); 

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    uint256 public otcTokenSent;
    uint256 public teamTokensSent;
    uint256 public uniSwapLiquiditySent;
    uint256 public futureDevelopment;
    uint256 public ecoSystemTokens;

    mapping(address => bool) public teamTokenHolder;
    mapping(address => uint256) public teamTokensReleased;
    mapping(address => uint256) public teamTokensInitially;
    mapping (address => uint256) public lockingTime;

    function sendTokens(address _userAddress, uint256 _value, uint256 _typeOfUser) external whenNotPaused onlyOwner returns (bool) {


     if(_typeOfUser == 1)
     {
         otcTokenSent = otcTokenSent.add(_value);
         Ttransfer(msg.sender,_userAddress,_value);

     }else if (_typeOfUser == 2)
     {
         uniSwapLiquiditySent = uniSwapLiquiditySent.add(_value);
         Ttransfer(msg.sender,_userAddress,_value);

     }else if (_typeOfUser == 3){
         
        futureDevelopment = futureDevelopment.add(_value);
         Ttransfer(msg.sender,_userAddress,_value);
        
     } else if (_typeOfUser == 4){

        ecoSystemTokens = ecoSystemTokens.add(_value);
         Ttransfer(msg.sender,_userAddress,_value);

     }else {

         revert();

     }

   }

    function sendteamTokens(address _userAddress, uint256 _value) external whenNotPaused onlyOwner returns (bool) {


     teamTokenHolder[_userAddress] = true;
     teamTokensInitially[_userAddress] = teamTokensInitially[_userAddress].add(_value);
     lockingTime[_userAddress] = now;
     teamTokensSent = teamTokensSent.add(_value);
     Ttransfer(msg.sender,_userAddress,_value);
        return true;

   }

    function getCycle(address _userAddress) public view returns (uint256){

     
     require(teamTokenHolder[_userAddress]);
     uint256 cycle = now.sub(lockingTime[_userAddress]);
    
     if(cycle <= 1296000)
     {
         return 0;
     }
     else if (cycle > 1296000 && cycle <= 42768000)
     {     
    
      uint256 secondsToHours = cycle.div(1296000);
      return secondsToHours;

     }

    else if (cycle > 42768000)
    {
        return 34;
    }
    
    }
    
    function setRebaseContractAddress(address _reBaseAddress) public onlyOwner returns (address){

        
        reBaseContractAddress = _reBaseAddress;
        emit RebaseContractInitialized(reBaseContractAddress);
        return (reBaseContractAddress);
    } 

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (bool)
    {

        require(reBaseContractAddress != address(0x0), "rebase address not set yet");
        require (msg.sender == reBaseContractAddress,"Not called by rebase contract");

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return true;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);


        emit LogRebase(epoch, _totalSupply);
        return true;
    }

    constructor(address owner_) public Owned(owner_) {

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner_] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }


    function balanceOf(address who) public view returns (uint256) {

        return _gonBalances[who].div(_gonsPerFragment);
    }

    function Ttransfer(
        address from,
        address to,
        uint256 value
    ) internal validRecipient(to) returns (bool) {

        uint256 gonValue = value.mul(_gonsPerFragment);

        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(from, to, value);
        return true;
    }


    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }


    function TtransferFrom(
        address from,
        address to,
        uint256 value
    ) internal validRecipient(to) returns (bool) {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg
            .sender]
            .sub(value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(from, to, value);

        return true;
    }


    function approve(address spender, uint256 value) public returns (bool) {

        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] = _allowedFragments[msg
            .sender][spender]
            .add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function transfer(address recipient, uint256 amount) public
        whenNotPaused
        returns (bool)
    {


        if(teamTokenHolder[msg.sender]){


           if(teamTokensReleased[msg.sender] == teamTokensInitially[msg.sender]){
               
            Ttransfer(msg.sender, recipient, amount);
            return true;
               
           } else {

            require(now >= lockingTime[msg.sender].add(1296000),'Zero cycle is running');

            uint256 preSaleCycle = getCycle(msg.sender);
            uint256 threePercentOfInitialFund = (teamTokensInitially[msg.sender].mul(3)).div(100);
            
            require(teamTokensReleased[msg.sender] != teamTokensInitially[msg.sender], 'all tokens released');
            require(teamTokensReleased[msg.sender] != threePercentOfInitialFund.mul(preSaleCycle),'this cycle all tokens released');            
            
            if(teamTokensReleased[msg.sender] < threePercentOfInitialFund.mul(preSaleCycle))
            {
            uint256 tokenToSend = amount;
            teamTokensReleased[msg.sender] = tokenToSend.add(teamTokensReleased[msg.sender]);
            require(teamTokensReleased[msg.sender] <= teamTokensInitially[msg.sender],'tokens released are greater then inital tokens');

            Ttransfer(msg.sender, recipient, amount);
            return true;
            }
           }

            
            
        }else{

            Ttransfer(msg.sender, recipient, amount);
            return true;
        } 

    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public whenNotPaused returns (bool) {



        if(teamTokenHolder[sender]){

           if(teamTokensReleased[sender] == teamTokensInitially[sender]){
               
            TtransferFrom(sender, recipient, amount);
            return true;
               
           }else 
{            require(now >= lockingTime[sender].add(1296000),"zero cycle is running");

            uint256 preSaleCycle = getCycle(sender);
            uint256 threePercentOfInitialFund = (teamTokensInitially[sender].mul(3)).div(100);
            
            require(teamTokensReleased[sender] != teamTokensInitially[sender]);
            require(teamTokensReleased[sender] != threePercentOfInitialFund.mul(preSaleCycle));            
            
            if(teamTokensReleased[sender] < threePercentOfInitialFund.mul(preSaleCycle))

            {
            
            uint256 tokenToSend = amount;
            teamTokensReleased[sender] = tokenToSend.add(teamTokensReleased[sender]);
            require(teamTokensReleased[sender] <= teamTokensInitially[sender]);

            TtransferFrom(sender, recipient, amount);
            return true;
                    
            }
}            
            
        }else{

            TtransferFrom(sender, recipient, amount);
            return true;
            
        } 

    }

}