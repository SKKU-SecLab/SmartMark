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

contract Context {

    constructor () internal { }

    function _msgSender() internal view  returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view  returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view  returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public   returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view   returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public   returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public   returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal  {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal  {

        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal  {

        require(account != address(0), "ERC20: burn from the zero address");


        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal  {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
}

contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

contract RakeToken is  ERC20Burnable {


    string public constant name = "Rake Finance";
    string public constant symbol = "RAK";
    uint8 public constant decimals = 18;  
    
    using SafeMath for uint256;

   constructor(address owner) public {  
    
      uint256 allocatedForCrowdsale = 5000;
      uint256 ownerFunds = 2500;
      
      _mint(owner, ownerFunds.mul(1e18));  //2500 RAK Token to Owner
      _mint(msg.sender, allocatedForCrowdsale.mul(1e18)); //5000 RAK Token to Crowdsale contract
    }
}pragma solidity ^0.5.0;


contract RakeFinanceTokenCrowdsale {

     using SafeMath for uint256;
    
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

   bool public isEnded = false;

   event Ended(uint256 totalWeiRaisedInCrowdsale,uint256 unsoldTokensTransferredToOwner);
   
   uint256 public rate;     //Tokens per wei 
   address payable public ethBeneficiaryAccount;
   ERC20Burnable public RakeFinanceToken;
   
  enum CrowdsaleStage { PreICO, ICO }
  CrowdsaleStage public stage;      //0 for PreICO & 1 for ICO Stage

  uint256 public totalTokensForSale = 5000*(1e18); // 5000 RAK will be sold during hole Crowdsale
  uint256 public totalTokensForSaleDuringPreICO = 2500*(1e18); // 2500 RAK will be sold during PreICO
  uint256 public totalTokensForSaleDuringICO = 2500*(1e18); // 2500 RAK will be sold during ICO

  uint256 public totalWeiRaisedDuringPreICO;
  uint256 public totalWeiRaisedDuringICO;

  uint256 public tokenRemainingForSaleInPreICO = 2500*(1e18);
  uint256 public tokenRemainingForSaleInICO = 2500*(1e18);


  event EthTransferred(string text);
  
    address public owner;    
    modifier onlyOwner() {

        require (msg.sender == owner);
        _;
    }

  constructor(uint256 initialRate,address payable wallet) public
  {   
      ethBeneficiaryAccount = wallet;
      setCurrentRate(initialRate);
      owner = msg.sender;
      stage = CrowdsaleStage.PreICO; // By default it's PreICO
      RakeFinanceToken = new RakeToken(owner); // RakeFinanceToken Deployment
  }


  function switchToICOStage() public onlyOwner {

      require(stage == CrowdsaleStage.PreICO);
      stage = CrowdsaleStage.ICO;
      setCurrentRate(5);
  }

  function setCurrentRate(uint256 _rate) private {

      rate = _rate;                     
  }

  
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal pure
  {

    require(_beneficiary != address(0));
    require(_weiAmount >= 1e17 wei,"Minimum amount to invest: 0.1 ETH");
  }

  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {

    RakeFinanceToken.transfer(_beneficiary, _tokenAmount);
  }

  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {

    _deliverTokens(_beneficiary, _tokenAmount);
  }

  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {

    return _weiAmount.mul(rate);
  }

  function _forwardFunds() internal {

    ethBeneficiaryAccount.transfer(msg.value);
    emit EthTransferred("Forwarding funds to ETH Beneficiary Account");
  }
  
  function() external payable{
      if(isEnded){
          revert(); //Block Incoming ETH Deposits if Crowdsale has ended
      }
      buyRAKToken(msg.sender);
  }
  
  function buyRAKToken(address _beneficiary) public payable {

      uint256 weiAmount = msg.value;
      if(isEnded){
        revert();
      }
      _preValidatePurchase(_beneficiary, weiAmount);
      uint256 tokensToBePurchased = weiAmount.mul(rate);
      if ((stage == CrowdsaleStage.PreICO) && (tokensToBePurchased > tokenRemainingForSaleInPreICO)) {
         revert();  //Block Incoming ETH Deposits for PreICO stage if tokens to be purchased, exceeds remaining tokens for sale in Pre ICO
      }
      
      else if ((stage == CrowdsaleStage.ICO) && (tokensToBePurchased > tokenRemainingForSaleInICO)) {
        revert();  //Block Incoming ETH Deposits for ICO stage if tokens to be purchased, exceeds remaining tokens for sale in ICO
      }
      
       uint256 tokens = _getTokenAmount(weiAmount);
        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
          msg.sender,
          _beneficiary,
          weiAmount,
          tokens
        );
        
      _forwardFunds();
      
      if (stage == CrowdsaleStage.PreICO) {
          totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(weiAmount);
          tokenRemainingForSaleInPreICO = tokenRemainingForSaleInPreICO.sub(tokensToBePurchased);
          if(tokenRemainingForSaleInPreICO == 0){       // Switch to ICO Stage when all tokens allocated for PreICO stage are being sold out
              switchToICOStage();
          }
      }
      else if (stage == CrowdsaleStage.ICO) {
          totalWeiRaisedDuringICO = totalWeiRaisedDuringICO.add(weiAmount);
          tokenRemainingForSaleInICO = tokenRemainingForSaleInICO.sub(tokensToBePurchased);
          if(tokenRemainingForSaleInICO == 0 && tokenRemainingForSaleInPreICO == 0){       // End Crowdsale when all tokens allocated for For Sale are being sold out
              endCrowdsale();
          }
      }
  }
  

  function endCrowdsale() public onlyOwner {

      require(!isEnded && stage == CrowdsaleStage.ICO,"Should be at ICO Stage to Finalize the Crowdsale");
      uint256 unsoldTokens = tokenRemainingForSaleInPreICO.add(tokenRemainingForSaleInICO);
      if (unsoldTokens > 0) {
          tokenRemainingForSaleInICO = 0;
          tokenRemainingForSaleInPreICO = 0;
          RakeFinanceToken.transfer(owner,unsoldTokens);
      }
      emit Ended(totalWeiRaised(),unsoldTokens);
      isEnded = true;
  }
    
    function balanceOf(address tokenHolder) external view returns(uint256 balance){

        return RakeFinanceToken.balanceOf(tokenHolder);
    }
    
    function totalWeiRaised() public view returns(uint256){

        return totalWeiRaisedDuringPreICO.add(totalWeiRaisedDuringICO);
    }
    
}