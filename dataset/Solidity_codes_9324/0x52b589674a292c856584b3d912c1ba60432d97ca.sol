



pragma solidity ^0.8.0;


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




pragma solidity ^0.8.0;

interface BSIERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


pragma solidity ^0.8.7;


contract BSERC20 is Context, BSIERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }



    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}





pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}




pragma solidity ^0.8.0;




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




pragma solidity ^0.8.7;





contract Bollystake is BSERC20("sBOLLY Staked Bollycoin", "sBOLLY"),Ownable{
    using SafeMath for uint256;

    IERC20 public immutable BOLLY;
    constructor(IERC20 _BOLLY) {
        require(address(_BOLLY) != address(0), "_BOLLY is a zero address");
        BOLLY = _BOLLY;
    }
    uint256 private constant _TIMELOCK_30 = 30 days;
    uint256 private constant _TIMELOCK_60 = 60 days;
    uint256 private constant _TIMELOCK_90 = 90 days;
    uint256 private constant _TIMELOCK_180 = 180 days;
    uint256 private constant _TIMELOCK_365 = 365 days;
    uint256 private constant _TIMELOCK_540 = 540 days;
    uint256 private constant _TIMELOCK_730 = 730 days;

     
     struct Locked{
        uint256 expire;
        uint256 locked_amount;
     }
     mapping(address => Locked[7]) user_stake;
      address[] internal stakeholders;
   function isStakeholder(address _address)
       public
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }

   function addStakeholder(address _stakeholder)
       private
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }

   function removeStakeholder(address _stakeholder)
       private
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if(_isStakeholder){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }

   mapping(address => uint256) internal stakes;

   function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
   }

   function totalStakes()
       external
       view 
       returns(uint256)
   {
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
       }
       return _totalStakes;
   }
   function totalEligibleStakes()
       public
       view
       returns(uint256)
   {
       uint256 _totaleligibleStakes = 0;
       uint256 _usereligiblestakes = 0;
       uint256 _expired_stakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _expired_stakes = expiredStakes(stakeholders[s]);
           _usereligiblestakes = stakes[stakeholders[s]].sub(_expired_stakes);
           _totaleligibleStakes = _totaleligibleStakes.add(_usereligiblestakes);
       }
       return _totaleligibleStakes;
   }

   function eligibleStakes() external view returns (address [] memory,uint256 [] memory)
   {
       uint256 [] memory eligible_stakes = new uint256[](stakeholders.length);
       address [] memory user_address = new address[](stakeholders.length);
       uint256 _expired_stakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _expired_stakes = expiredStakes(stakeholders[s]);
           eligible_stakes[s] = stakes[stakeholders[s]].sub(_expired_stakes);
           user_address[s]= stakeholders[s];
       }
      return (user_address,eligible_stakes);
   }
   function userEligibleStakes(address _stakeholder) external view returns(uint256)
   {
       uint256 _expired_stakes = 0;
       uint256 eligible_stakes = 0;
           _expired_stakes = expiredStakes(_stakeholder);
           eligible_stakes = stakes[_stakeholder].sub(_expired_stakes);
      return (eligible_stakes);
   }
   

    function getAllUserStakes() external view returns (address [] memory, uint256 [7][] memory,uint256 [7][] memory)
   {
       uint256[7][] memory all_user_stakes = new uint256[7][](stakeholders.length);
       uint256[7][] memory all_user_eligible_stakes = new uint256[7][](stakeholders.length);
       address [] memory user_address = new address[](stakeholders.length);
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           all_user_stakes[s] = [user_stake[stakeholders[s]][0].locked_amount,user_stake[stakeholders[s]][1].locked_amount,user_stake[stakeholders[s]][2].locked_amount,user_stake[stakeholders[s]][3].locked_amount,user_stake[stakeholders[s]][4].locked_amount,user_stake[stakeholders[s]][5].locked_amount,user_stake[stakeholders[s]][6].locked_amount];
           user_address[s]= stakeholders[s];
           for(uint k=0;k<7;k+=1){
               if(user_stake[stakeholders[s]][k].expire > block.timestamp ) {
                 all_user_eligible_stakes[s][k]=user_stake[stakeholders[s]][k].locked_amount;
               } else {
                 all_user_eligible_stakes[s][k]=0;  
               }
           }
       }
      return (user_address,all_user_stakes,all_user_eligible_stakes);
   }
   
   function expiredStakes (address _stakeholder) public view returns(uint256)
   {
       Locked[7] storage user_stake_info = user_stake[_stakeholder];
        uint256 expired_amount=0;
        for (uint256 s = 0; s < 7; s += 1){
             if (user_stake_info[s].expire < block.timestamp) {
                 expired_amount = expired_amount.add(user_stake_info[s].locked_amount);
             }
        }
        return expired_amount;
   }    

    function enterStake(uint256 _amount ,uint256 _days) external {
        require(_days ==30||_days==60||_days==90||_days==180||_days==365||_days==540||_days==730,"number of days should be among 30,60,90,180,365,540,730");
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
       stakes[msg.sender] = stakes[msg.sender].add(_amount);
        Locked[7] storage user_stake_info = user_stake[msg.sender];
        if (_days ==30) {
        user_stake_info[0].expire = block.timestamp + _TIMELOCK_30;
        user_stake_info[0].locked_amount = user_stake_info[0].locked_amount.add(_amount);
        } else if (_days ==60) {
        user_stake_info[1].expire = block.timestamp + _TIMELOCK_60;
        user_stake_info[1].locked_amount = user_stake_info[1].locked_amount.add(_amount);
        } else if (_days ==90) {
        user_stake_info[2].expire = block.timestamp + _TIMELOCK_90;
        user_stake_info[2].locked_amount = user_stake_info[2].locked_amount.add(_amount);
        } else if (_days ==180) {
        user_stake_info[3].expire = block.timestamp + _TIMELOCK_180;
        user_stake_info[3].locked_amount = user_stake_info[3].locked_amount.add(_amount);
        } else if (_days ==365) {
        user_stake_info[4].expire = block.timestamp + _TIMELOCK_365;
        user_stake_info[4].locked_amount = user_stake_info[4].locked_amount.add(_amount);
        } else if (_days ==540) {
        user_stake_info[5].expire = block.timestamp + _TIMELOCK_540;
        user_stake_info[5].locked_amount = user_stake_info[5].locked_amount.add(_amount);
        } else if (_days ==730) {
        user_stake_info[6].expire = block.timestamp + _TIMELOCK_730;
        user_stake_info[6].locked_amount = user_stake_info[6].locked_amount.add(_amount);
        }
        bool transfer_from_done = BOLLY.transferFrom(msg.sender, address(this), _amount);
        require(transfer_from_done,"BOLLY transfer failed");
        _mint(msg.sender, _amount);
        emit EnterStake(_amount,msg.sender,_days);
    }
    function relockStake(uint256 _days) external {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        uint256 expired_amount = expiredStakes(msg.sender);
        require(_isStakeholder, "only current stakeholders can relock stake");
        require(expired_amount>0 ,"no expired stakes to relock");
        require(_days ==30||_days==60||_days==90||_days==180||_days==365||_days==540||_days==730,"number of days should be among 30,60,90,180,365,540,730");
        Locked[7] storage user_stake_info = user_stake[msg.sender];
        for (uint256 s = 0; s < 7; s += 1){
             if (user_stake_info[s].expire < block.timestamp) {
                 user_stake_info[s].locked_amount = 0;
             }
        }    
        if (_days ==30) {    
        user_stake_info[0].expire = block.timestamp + _TIMELOCK_30;
        user_stake_info[0].locked_amount = expired_amount;
        } else if (_days ==60) {
        user_stake_info[1].expire = block.timestamp + _TIMELOCK_60;
        user_stake_info[1].locked_amount = expired_amount;
        } else if (_days ==90) {
        user_stake_info[2].expire = block.timestamp + _TIMELOCK_90;
        user_stake_info[2].locked_amount = expired_amount;
        } else if (_days ==180) {
        user_stake_info[3].expire = block.timestamp + _TIMELOCK_180;
        user_stake_info[3].locked_amount = expired_amount;
        } else if (_days ==365) {
        user_stake_info[4].expire = block.timestamp + _TIMELOCK_365;
        user_stake_info[4].locked_amount = expired_amount;
        } else if (_days ==540) {
        user_stake_info[5].expire = block.timestamp + _TIMELOCK_540;
        user_stake_info[5].locked_amount = expired_amount;
        } else if (_days ==730) {
        user_stake_info[6].expire = block.timestamp + _TIMELOCK_730;
        user_stake_info[6].locked_amount = expired_amount;
        }
        emit RelockStake(msg.sender,_days,expired_amount);
    }

     
    function removeStake() external {
        Locked[7] storage user_stake_info = user_stake[msg.sender];
        uint256 expired_amount = expiredStakes(msg.sender);
        require( (expired_amount>0) ,"Please wait until some stakes are expired");
        _burn(msg.sender,expired_amount );
         for (uint256 s = 0; s < 7; s += 1){
             if (user_stake_info[s].expire < block.timestamp) {
                 user_stake_info[s].locked_amount = 0;
             }
        }
         stakes[msg.sender] = stakes[msg.sender].sub(expired_amount);
       if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        bool transfer_done = BOLLY.transfer(msg.sender, expired_amount);
        require(transfer_done,"BOLLY transfer failed");
        emit RemoveStake(expired_amount,msg.sender);
    }

    function emergency_remove_stake(address _user) external onlyOwner{
        Locked[7] storage user_stake_info = user_stake[_user];
        uint256 locked_amount = stakeOf(_user);
        require( (locked_amount>0) ,"Please wait until some stakes are expired");
        _burn(_user,locked_amount);
         for (uint256 s = 0; s < 7; s += 1){
                 user_stake_info[s].locked_amount = 0;
        }
         stakes[_user] = stakes[_user].sub(locked_amount);
       if(stakes[_user] == 0) removeStakeholder(_user);
        bool transfer_done = BOLLY.transfer(_user, locked_amount);
        require(transfer_done,"BOLLY transfer failed");
        emit RemoveStake(locked_amount,_user);
    }
    
    event SetOwner(address _owner, address _from) ;    
    event EnterStake(uint256 _amount, address _stake_from, uint256 _days);
    event RelockStake(address stake_from,uint256 _days, uint256 _expired_amount);
    event RemoveStake(uint256 _amount,address _stake_to); 
}