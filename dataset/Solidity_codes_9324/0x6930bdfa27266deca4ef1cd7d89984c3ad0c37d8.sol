
pragma solidity ^0.4.21;

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

contract Ownable {

  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic, Ownable {

  using SafeMath for uint256;
  
  struct Purchase {
    uint256 buyAmount;
    uint256 transferredAmount;
    uint256 purchaseBlock;
  }

  mapping(address => uint256) balances;
  mapping(address => Purchase[]) public presaleInvestors;
  mapping(address => uint256) public mainSaleInvestors;
  
  uint256 totalSupply_;
  uint256 public secondsPerBlock = 147; // change to 14
  uint256 public startLockUpSec = 3888000; // 45 days => 3888000 secs
  uint256 public secondsPerMonth = 2592000; // 30 days => 2592000 secs
  uint256 public percentagePerMonth = 10;
  
    function _checkLockUp(address senderAdr) public view returns (uint) {

        uint canTransfer = 0;
        if (presaleInvestors[senderAdr].length == 0) {
            canTransfer = 0;
        } else if (presaleInvestors[senderAdr][0].purchaseBlock > block.number.sub(startLockUpSec.div(secondsPerBlock).mul(10))) {
            canTransfer = 0;
        } else {
            for (uint i = 0; i < presaleInvestors[senderAdr].length; i++) {
                if (presaleInvestors[senderAdr][i].purchaseBlock <= (block.number).sub(startLockUpSec.div(secondsPerBlock).mul(10))) {
                    uint months = (block.number.sub(presaleInvestors[senderAdr][i].purchaseBlock)).div(secondsPerMonth);
                    if (months > 10) {
                        months = 10;
                    }
                    uint actAmount = (presaleInvestors[senderAdr][i].buyAmount).mul(months).mul(percentagePerMonth).div(100);
                    uint realAmout = actAmount.sub(presaleInvestors[senderAdr][i].transferredAmount);
                    canTransfer = canTransfer.add(realAmout);
                } else {
                    break;
                }
            }
        }
        return canTransfer.add(mainSaleInvestors[senderAdr]);
    }
    
    function cleanTokensAmount(address senderAdr, uint256 currentTokens) public returns (bool) {

        if (presaleInvestors[senderAdr].length != 0) {
            for (uint i = 0; i < presaleInvestors[senderAdr].length; i++) {
                if (presaleInvestors[senderAdr][i].transferredAmount == presaleInvestors[senderAdr][i].buyAmount) {
                    continue;
                }
                if (presaleInvestors[senderAdr][i].purchaseBlock <= (block.number).sub(startLockUpSec.div(secondsPerBlock).mul(10))) {
                    uint months = (block.number.sub(presaleInvestors[senderAdr][i].purchaseBlock)).div(secondsPerMonth);
                    if (months > 10) {
                        months = 10;
                    }
                    if ((presaleInvestors[senderAdr][i].buyAmount.div(100).mul(months).mul(percentagePerMonth) - presaleInvestors[senderAdr][i].transferredAmount) >= currentTokens) {
                        presaleInvestors[senderAdr][i].transferredAmount = presaleInvestors[senderAdr][i].transferredAmount + currentTokens;
                        currentTokens = 0;
                    } 
                    if ((presaleInvestors[senderAdr][i].buyAmount.div(100).mul(months).mul(percentagePerMonth) - presaleInvestors[senderAdr][i].transferredAmount) < currentTokens) {
                        uint remainder = currentTokens - (presaleInvestors[senderAdr][i].buyAmount.div(100).mul(months).mul(percentagePerMonth) - presaleInvestors[senderAdr][i].transferredAmount);
                        presaleInvestors[senderAdr][i].transferredAmount = presaleInvestors[senderAdr][i].buyAmount.div(100).mul(months).mul(percentagePerMonth);
                        currentTokens = remainder;
                    }
                } else {
                    continue;
                }
            }
            
            if (currentTokens <= mainSaleInvestors[senderAdr]) {
                mainSaleInvestors[senderAdr] = mainSaleInvestors[senderAdr] - currentTokens;
                currentTokens = 0;
            } else {
                revert();
            }
        } else {
            if (currentTokens <= mainSaleInvestors[senderAdr]) {
                mainSaleInvestors[senderAdr] = mainSaleInvestors[senderAdr] - currentTokens;
                currentTokens = 0;
            } else {
                revert();
            }
        }
        
        if (currentTokens != 0) {
            revert();
        }
    }

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value > 0);
    require(_value <= balances[msg.sender]);
    require(_checkLockUp(msg.sender) >= _value);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    cleanTokensAmount(msg.sender, _value);
    mainSaleInvestors[_to] = mainSaleInvestors[_to].add(_value);

    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract BurnableToken is BasicToken {


  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);
    require(_checkLockUp(_who) >= _value);

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
    cleanTokensAmount(_who, _value);
  }
}

contract StandardToken is ERC20, BurnableToken {


  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value > 0);
    require(_value <= allowed[_from][msg.sender]);
    require(_checkLockUp(_from) >= _value);


    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    cleanTokensAmount(_from, _value);
    mainSaleInvestors[_to] = mainSaleInvestors[_to].add(_value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {

    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MintableToken is StandardToken {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {

    require(msg.sender == owner);
    _;
  }

  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    mainSaleInvestors[_to] = mainSaleInvestors[_to].add(_amount);
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

contract WiredToken is MintableToken {

    
    string public constant name = "Wired Token";
    string public constant symbol = "WRD";
    uint8 public constant decimals = 8;
    uint256 public constant INITIAL_SUPPLY = 410000000000000000000; // 10^28
    
    address public agent;
    uint256 public distributeAmount = 41000000000000000000;
    uint256 public mulbonus = 1000;
    uint256 public divbonus = 10000000000;
    bool public presalePart = true;

    modifier onlyAgent() {

        require(msg.sender == owner || msg.sender == agent);
        _;
    }

    function WiredToken() public {

        totalSupply_ = INITIAL_SUPPLY;
        balances[address(this)] = INITIAL_SUPPLY;
        mainSaleInvestors[address(this)] = INITIAL_SUPPLY;
        agent = msg.sender;
    }

    function distributeAirdrop(address[] addresses, uint256 amount) external onlyAgent {

        require(amount > 0 && addresses.length > 0);

        uint256 amounts = amount.mul(100000000);
        uint256 totalAmount = amounts.mul(addresses.length);
        require(balances[address(this)] >= totalAmount);
        
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0);

            balances[addresses[i]] = balances[addresses[i]].add(amounts);
            emit Transfer(address(this), addresses[i], amounts);
            mainSaleInvestors[addresses[i]] = mainSaleInvestors[addresses[i]].add(amounts);
        }
        balances[address(this)] = balances[address(this)].sub(totalAmount);
        mainSaleInvestors[address(this)] = mainSaleInvestors[address(this)].sub(totalAmount);
    }

    function distributeAirdropMulti(address[] addresses, uint256[] amount) external onlyAgent {

        require(addresses.length > 0 && addresses.length == amount.length);
        
        uint256 totalAmount = 0;
        
        for(uint i = 0; i < addresses.length; i++) {
            require(amount[i] > 0 && addresses[i] != 0x0);
                    
            uint256 amounts = amount[i].mul(100000000);
            totalAmount = totalAmount.add(amounts);

            require(balances[address(this)] >= totalAmount);
        
            balances[addresses[i]] = balances[addresses[i]].add(amounts);
            emit Transfer(address(this), addresses[i], amounts);
            mainSaleInvestors[addresses[i]] = mainSaleInvestors[addresses[i]].add(amounts);
        }
        balances[address(this)] = balances[address(this)].sub(totalAmount);
        mainSaleInvestors[address(this)] = mainSaleInvestors[address(this)].sub(totalAmount);

    }
    
    function distributeAirdropMultiPresale(address[] addresses, uint256[] amount, uint256[] blocks) external onlyAgent {

        require(addresses.length > 0 && addresses.length == amount.length);
        
        uint256 totalAmount = 0;
        
        for(uint i = 0; i < addresses.length; i++) {
            require(amount[i] > 0 && addresses[i] != 0x0);
                    
            uint256 amounts = amount[i].mul(100000000);
            totalAmount = totalAmount.add(amounts);

            require(balances[address(this)] >= totalAmount);
        
            presaleInvestors[addresses[i]].push(Purchase(amounts, 0, blocks[i]));
            balances[addresses[i]] = balances[addresses[i]].add(amounts);
            emit Transfer(address(this), addresses[i], amounts);
        }
        balances[address(this)] = balances[address(this)].sub(totalAmount);
        mainSaleInvestors[address(this)] = mainSaleInvestors[address(this)].sub(totalAmount);

    }

    function setDistributeAmount(uint256 _unitAmount) onlyOwner external {

        distributeAmount = _unitAmount;
    }
    
    function setMulBonus(uint256 _mulbonus) onlyOwner external {

        mulbonus = _mulbonus;
    }
    
    function setDivBonus(uint256 _divbonus) onlyOwner external {

        divbonus = _divbonus;
    }

    function setNewAgent(address _agent) external onlyOwner {

        require(agent != address(0));
        agent = _agent;
    }
    
    function changeTime(uint256 _time) external onlyOwner {

        secondsPerBlock = _time;
    }
    
    function transferFund() external onlyOwner {

        owner.transfer(address(this).balance);
    }
    
    function transferTokens(uint256 amount) external onlyOwner {

        require(balances[address(this)] > 0);
        

        balances[msg.sender] = balances[msg.sender].add(amount.mul(100000000));
        balances[address(this)] = balances[address(this)].sub(amount.mul(100000000));
        emit Transfer(address(this), msg.sender, balances[address(this)]);
        mainSaleInvestors[msg.sender] = mainSaleInvestors[msg.sender].add(amount.mul(100000000));
        mainSaleInvestors[address(this)] = mainSaleInvestors[address(this)].sub(amount.mul(100000000));
    }

    function buy(address buyer) payable public {

        require(msg.value > 10000000000000 && distributeAmount > 0 && balances[address(this)] > distributeAmount);
        
        uint256 amount = msg.value.mul(mulbonus).div(divbonus);
        balances[buyer] = balances[buyer].add(amount);
        emit Transfer(address(this), buyer, amount);
        
        if (presalePart) {
            presaleInvestors[buyer].push(Purchase(amount, 0, block.number)); 
        } else {
            mainSaleInvestors[buyer] = mainSaleInvestors[buyer].add(amount);
        }

        mainSaleInvestors[address(this)] = mainSaleInvestors[address(this)].sub(amount);
        balances[address(this)] = balances[address(this)].sub(amount);
        distributeAmount = distributeAmount.sub(amount);
    }

    function() payable public {
        buy(msg.sender);
    }   
}