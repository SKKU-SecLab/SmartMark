
pragma solidity ^0.5.0;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


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


contract ERC20 is IERC20 {

  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  function totalSupply() public view returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];
  }

  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {

    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {

    require(value <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {

    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {

    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {

    require(account != address(0));
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _burnFrom(address account, uint256 amount) internal {

    require(amount <= _allowed[account][msg.sender]);

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
}


library SafeERC20 {

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    require(token.approve(spender, value));
  }
}

interface LockedOwner {

    function burnTokens(uint256) external;

}


contract Vesting {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(uint256 amount);
    event TokensBurned(uint256 amount);

    address private _beneficiary;
    uint256 private _released;
    address private _deployer;

    uint256 private _cliff;
    uint256 private _start;
    uint256 private _duration;

    IERC20 private _token = IERC20(0xf9FBE825BFB2bF3E387af0Dc18caC8d87F29DEa8);
    LockedOwner private _tokenOwner = LockedOwner(0xfD2b93eA4f7547eFf73D08d889beDCc5164c1175);

    constructor (address beneficiary, uint256 cliffDuration, uint256 duration) public {
        _start = block.timestamp;
        require(beneficiary != address(0), "no beneficiary");
        require(cliffDuration <= duration, "invalid cliff period");
        require(duration > 0, "invalid duration");
        require(_start.add(duration) > block.timestamp, "invalid final time");
        _beneficiary = beneficiary;
        _duration = duration;
        _cliff = _start.add(cliffDuration);
        _start = _start;
        _deployer = msg.sender;
    }

    function beneficiary() public view returns (address) {

        return _beneficiary;
    }

    function cliff() public view returns (uint256) {

        return _cliff;
    }

    function start() public view returns (uint256) {

        return _start;
    }

    function duration() public view returns (uint256) {

        return _duration;
    }

    function released() public view returns (uint256) {

        return _released;
    }

    function deployer() public view returns (address) {

      return _deployer;
    }

    function balanceInContract() public view returns (uint256) {

      return _token.balanceOf(address(this));
    }

    function release() public {

        uint256 unreleased = _releasableAmount();
        require(unreleased > 0, "No tokens TBR");
        _released = _released.add(unreleased);
        _token.safeTransfer(_beneficiary, unreleased);
        emit TokensReleased(unreleased);
    }

    function _releasableAmount() private view returns (uint256) {

        return _vestedAmount().sub(_released);
    }

    function _vestedAmount() private view returns (uint256) {

        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released);
        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }

    function burnFromVesting(uint256 _amount) external {

        require(msg.sender == _deployer, "Unauthorized");
        _tokenOwner.burnTokens(_amount);
        emit TokensBurned(_amount);
    }
}