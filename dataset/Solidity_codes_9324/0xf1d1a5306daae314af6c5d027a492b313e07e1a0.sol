

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract EnvoyToken is ERC20 {

  using SafeMath for uint256;


  uint256 private _deployTime = 1635429600; 
  uint256 private _startTime = 1635933600; 

  address public _ownerWallet;

  address public _publicSaleWallet;
  address public _teamWallet;
  address public _ecosystemWallet;
  address public _reservesWallet;
  address public _dexWallet;
  address public _liqWallet;

  mapping(address => uint256) public _buyerTokens;

  uint256 public _totalBuyerTokens;

  mapping(string => mapping(address => uint256)) public _walletTokensWithdrawn;



  constructor (string memory name, string memory symbol) public ERC20(name, symbol) {

    _ownerWallet = _msgSender();

    _mint(address(this), 100000000000000000000000000);
  }


  function updateOwner(address owner) external {
    require(_msgSender() == _ownerWallet, "Only owner can update wallets");

    _ownerWallet = owner; 
  }

  function updateWallets(address publicSale, address team, address ecosystem, address reserves, address dex, address liq) external {
    require(_msgSender() == _ownerWallet, "Only owner can update wallets");

    require(publicSale != address(0), "Should not set zero address");
    require(team != address(0), "Should not set zero address");
    require(ecosystem != address(0), "Should not set zero address");
    require(reserves != address(0), "Should not set zero address");
    require(dex != address(0), "Should not set zero address");
    require(liq != address(0), "Should not set zero address");

    _walletTokensWithdrawn["publicsale"][publicSale] = _walletTokensWithdrawn["publicsale"][_publicSaleWallet];
    _walletTokensWithdrawn["team"][team] = _walletTokensWithdrawn["team"][_teamWallet];
    _walletTokensWithdrawn["ecosystem"][ecosystem] = _walletTokensWithdrawn["ecosystem"][_ecosystemWallet];
    _walletTokensWithdrawn["reserve"][reserves] = _walletTokensWithdrawn["reserve"][_reservesWallet];
    _walletTokensWithdrawn["dex"][dex] = _walletTokensWithdrawn["dex"][_dexWallet];
    _walletTokensWithdrawn["liq"][liq] = _walletTokensWithdrawn["liq"][_liqWallet];

    _publicSaleWallet = publicSale; 
    _teamWallet = team;
    _ecosystemWallet = ecosystem;
    _reservesWallet = reserves;
    _dexWallet = dex;
    _liqWallet = liq;
  }

  function setBuyerTokens(address buyer, uint256 tokenAmount) external {
    require(_msgSender() == _ownerWallet, "Only owner can set buyer tokens");

    _totalBuyerTokens -= _buyerTokens[buyer];
    _totalBuyerTokens += tokenAmount;

    require(_totalBuyerTokens <= 25000000000000000000000000, "Max amount reached");

    _buyerTokens[buyer] = tokenAmount;
  }


  function publicSaleWithdraw(uint256 tokenAmount) external {
    require(_msgSender() == _publicSaleWallet, "Unauthorized public sale wallet");

    uint256 hasWithdrawn = _walletTokensWithdrawn["publicsale"][_msgSender()];

    uint256 canWithdraw = 1000000000000000000000000 - hasWithdrawn;

    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["publicsale"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);    
  }

  function liqWithdraw(uint256 tokenAmount) external {
    require(_msgSender() == _liqWallet, "Unauthorized liquidity incentives wallet");

    uint256 canWithdraw = walletCanWithdraw(_msgSender(), "liq", 40, 43800, 262800, 7000000000000000000000000, _deployTime);
    
    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["liq"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);  
  
  }

  function teamWithdraw(uint256 tokenAmount) external {
    require(_msgSender() == _teamWallet, "Unauthorized team wallet");

    uint256 canWithdraw = walletCanWithdraw(_msgSender(), "team", 0, 262800, 876001, 20000000000000000000000000, _deployTime);
    
    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["team"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);  
  }

  function ecosystemWithdraw(uint256 tokenAmount) external {
    require(_msgSender() == _ecosystemWallet, "Unauthorized ecosystem wallet");

    uint256 canWithdraw = walletCanWithdraw(_msgSender(), "ecosystem", 5, 43800, 832201, 25000000000000000000000000, _deployTime);
    
    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["ecosystem"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);  
  }

  function reservesWithdraw(uint256 tokenAmount) external {
    require(_msgSender() == _reservesWallet, "Unauthorized reserves wallet");

    uint256 canWithdraw = walletCanWithdraw(_msgSender(), "reserve", 0, 262800, 876001, 20000000000000000000000000, _deployTime);
    
    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["reserve"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);  
  }

  function dexWithdraw(uint256 tokenAmount) external {
    require(_msgSender() == _dexWallet, "Unauthorized dex wallet");

    uint256 hasWithdrawn = _walletTokensWithdrawn["dex"][_msgSender()];

    uint256 canWithdraw = 2000000000000000000000000 - hasWithdrawn;

    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["dex"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);    
  }

  function buyerWithdraw(uint256 tokenAmount) external {
    
    uint256 canWithdraw = walletCanWithdraw(_msgSender(), "privatesale", 10, 175200, 788401, _buyerTokens[_msgSender()], _startTime);
    
    require(tokenAmount <= canWithdraw, "Withdraw amount too high");

    _walletTokensWithdrawn["privatesale"][_msgSender()] += tokenAmount;

    _transfer(address(this), _msgSender(), tokenAmount);    
  }


  function walletCanWithdraw(address wallet, string memory walletType, uint256 initialPercentage, uint256 cliffMinutes, uint256 vestingMinutes, uint256 totalTokens, uint256 startTime) public view returns(uint256) {
    
    uint256 minutesDiff = (block.timestamp - startTime).div(60);

    uint256 withdrawnTokens = _walletTokensWithdrawn[walletType][wallet];

    uint256 initialTokens = 0;
    if (initialPercentage != 0) {
      initialTokens = totalTokens.mul(initialPercentage).div(100);
    }

    if (minutesDiff < uint256(cliffMinutes)) {
      return initialTokens - withdrawnTokens;
    }

    uint256 buyerTokensPerMinute = totalTokens.sub(initialTokens).div(vestingMinutes); 

    uint256 unlockedMinutes = minutesDiff - uint256(cliffMinutes); 

    uint256 unlockedTokens = unlockedMinutes.mul(buyerTokensPerMinute).add(initialTokens); 
    
    if (unlockedTokens <= withdrawnTokens) {
      return 0;
    }

    if (unlockedTokens > totalTokens) {
      return totalTokens - withdrawnTokens;
    }

    return unlockedTokens - withdrawnTokens;
  }

}