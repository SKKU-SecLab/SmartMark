pragma solidity 0.6.12;


abstract contract ERC20Basic {
  function totalSupply() public virtual view returns (uint256);
  function balanceOf(address who) public virtual view returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity 0.6.12;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "Error Message - Bad Math");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    require(b != 0, "Error Message - Bad Math");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "Error Message - Bad Math");
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "Error Message - Bad Math");
    return c;
  }
}
pragma solidity 0.6.12;




contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) public balances;

  uint256 public totalSupply_;

  function totalSupply() public override view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public override returns (bool) {

    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) public override view returns (uint256 balance) {

    return balances[_owner];
  }

}

pragma solidity 0.6.12;



abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public virtual view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
  function approve(address spender, uint256 value) public virtual returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity 0.6.12;



contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool) {

    require(_to != address(0), "Error - To Address Can Not Be Equal To The Zero Address");
    require( _from != address(0), "Error - Spender Can Not Be Equal To Zero Address");

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit  Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public override returns (bool) {

    require( _spender != address(0), "Error - Spender Can Not Be Equal To Zero Address");
    allowed[msg.sender][_spender] = _value;
    emit  Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public override view returns (uint256) {

    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    require( _spender != address(0), "Error - Spender address can not equal zero address");
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    require( _spender != address(0), "Error - Spender address can not equal zero address");
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].sub(_subtractedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

pragma solidity 0.6.12;


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0), "Error - New Address Can Not Be Equal To The Zero Address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
pragma solidity 0.6.12;



contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public virtual returns (bool) {

    require( _to != address(0), "Error - To address can not equal zero address");
    
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}
pragma solidity 0.6.12;


contract MandalaToken is MintableToken {


    using SafeMath for uint256;
    string public constant name = "MANDALA EXCHANGE TOKEN";
    string public constant   symbol = "MDX";
    uint public constant   decimals = 18;
    bool public  TRANSFERS_ALLOWED = true;
    uint256 public constant MAX_TOTAL_SUPPLY = 400000000 * (10 **18);

    event Burn(address indexed burner, uint256 value);

    function burnFrom(uint256 _value, address victim) public onlyOwner canMint {

        require( victim != address(0), "Error - victim address can not equal zero address");
        balances[victim] = balances[victim].sub(_value);
        totalSupply_ = totalSupply().sub(_value);

        emit Burn(victim, _value);
    }

    function burn(uint256 _value) public onlyOwner {


        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply().sub(_value);

        emit Burn(msg.sender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

        require(TRANSFERS_ALLOWED || msg.sender == owner, "Error - Transfers Not Allowed");

        return super.transferFrom(_from, _to, _value);
    }


    function mint(address _to, uint256 _amount) onlyOwner canMint public override returns (bool) {

        require(totalSupply_.add(_amount) <= MAX_TOTAL_SUPPLY, "Error - Max Total Supply Exceeded");

        return super.mint(_to, _amount);
    }


    function transfer(address _to, uint256 _value) public override returns (bool){

        require(TRANSFERS_ALLOWED || msg.sender == owner, "Error - Transfers Not Allowed");

        return super.transfer(_to, _value);
    }

    function stopTransfers() public onlyOwner {

        TRANSFERS_ALLOWED = false;
    }

    function resumeTransfers() public onlyOwner {

        TRANSFERS_ALLOWED = true;
    }

}