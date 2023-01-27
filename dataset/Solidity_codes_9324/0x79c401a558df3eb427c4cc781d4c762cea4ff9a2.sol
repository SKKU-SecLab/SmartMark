pragma solidity 0.5.0;

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
pragma solidity 0.5.0;

contract Ownable {

   address payable public owner;

   event OwnershipTransferred(address indexed _from, address indexed _to);

   constructor() public {
       owner = msg.sender;
   }

   modifier onlyOwner {

       require(msg.sender == owner);
       _;
   }

   function transferOwnership(address payable _newOwner) public onlyOwner {

       owner = _newOwner;
   }
}
pragma solidity 0.5.0;


contract Token is Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    
    address public tokenSaleAddress;
    
    string private _name = " Bank Of Cyber Space";
    string private _symbol = "BCS";
    uint8 private _decimals= 10;


    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    modifier onlyTokenSaleAndOwner {

        require(msg.sender == tokenSaleAddress || msg.sender == owner);
        _;
    }
    
    function setTokenSaleAddress(address _tokenSaleAddress) public onlyOwner {

        tokenSaleAddress = _tokenSaleAddress;
    }
    
    function mint(address account, uint256 amount) public onlyTokenSaleAndOwner {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

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
    
  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {

    require(receivers.length == amounts.length);
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
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


pragma solidity 0.5.0;



contract TokenSale is Ownable {

    using SafeMath for uint256;
    Token public token;
    address payable public wallet;
    uint256 public _weiRaised;
    
    uint256 public tokenPrice = 1400000000000000;
    uint256 public decimals = 10000000000;
    
     constructor ( address payable _wallet, Token _token) public {
        require(_wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(_token) != address(0), "Crowdsale: token is the zero address");
        wallet = _wallet;
        token = _token;
    }
    

function setTokenPrice (uint256 price) public onlyOwner{
    tokenPrice = price;
}

  function getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.div(tokenPrice);
     }

  
    function buyToken(address beneficiary) public payable {

        uint256 weiAmount = msg.value;
        uint256 tokenToTransfer = getTokenAmount(weiAmount);
        
            
         _deliverTokens(beneficiary, tokenToTransfer * decimals);
         wallet.transfer(weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        
    }
    
    function setWallet(address payable _wallet) public onlyOwner {

        wallet = _wallet;
    }
    
    
    function withdrawFunds() external onlyOwner {

        wallet.transfer(address(this).balance);
    }
    
    function _preValidatePurchase(uint256 weiAmount) internal  {

        require(weiAmount != 0, "Crowdsale: weiAmount is 0");

    }
    
    function _deliverTokens(address beneficiary, uint256 _amount) internal {

        token.mint(beneficiary, _amount);
    }
}

