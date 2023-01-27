
pragma solidity 0.4.25;

pragma solidity ^ 0.4 .24;

library SafeMath {


  function mul(uint256 a, uint256 b)
  internal
  pure
  returns(uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns(uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b)
  internal
  pure
  returns(uint256) {

    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

  function add(uint256 a, uint256 b)
  internal
  pure
  returns(uint256 c) {

    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }

  function sqrt(uint256 x)
  internal
  pure
  returns(uint256 y) {

    uint256 z = ((add(x, 1)) / 2);
    y = x;
    while (z < y) {
      y = z;
      z = ((add((x / z), z)) / 2);
    }
  }

  function sq(uint256 x)
  internal
  pure
  returns(uint256) {

    return (mul(x, x));
  }

  function pwr(uint256 x, uint256 y)
  internal
  pure
  returns(uint256) {

    if (x == 0)
      return (0);
    else if (y == 0)
      return (1);
    else {
      uint256 z = x;
      for (uint256 i = 1; i < y; i++)
        z = mul(z, x);
      return (z);
    }
  }
}


contract TokenRun {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public supplied;
    uint256 public surplusSupply;
    uint256 riseTimes = 0;
    uint256 public sellingPrice = 10**14;
    address owner;
    address exAddr;
    address runAddr;
    address lotteryAddr;
    address foundationAddr;
    bool active = false;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        address _foundationAddr,
        address _owner
    ) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10**uint256(decimals));
        owner = _owner;
        foundationAddr = _foundationAddr;
        surplusSupply = totalSupply;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function activation(
        address eAddr,
        address rAddr,
        address lAddr
    ) external {

        require(active == false, "activated");
        require(owner == msg.sender, "Insufficient permissions");
        exAddr = eAddr;
        runAddr = rAddr;
        lotteryAddr = lAddr;
        uint256 value = 1000 * 10**4 * 10**8;
        balanceOf[foundationAddr] = SafeMath.add(
            balanceOf[foundationAddr],
            value
        );
        surplusSupply = SafeMath.sub(surplusSupply, value);
        active = true;
        emit Transfer(this, foundationAddr, value);
    }

    function riseSellingPrice(uint256 index, uint256 count)
        private
        returns (uint256)
    {

        if (count > index) {
            for (uint256 i = index; i < count; i++) {
                sellingPrice = SafeMath.add(
                    sellingPrice,
                    SafeMath.div(sellingPrice, 100)
                );
            }
        }
        return count;
    }

    function transfer(address to, uint256 value) public {

        require(value >= 0, "Incorrect transfer amount");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(balanceOf[to] + value >= balanceOf[to], "Transfer failed");

        balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], value);
        balanceOf[to] = SafeMath.add(balanceOf[to], value);

        emit Transfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 value) public {

        require(
            (value == 0) || (allowance[msg.sender][spender] == 0),
            "Authorized tokens are not used up"
        );
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public {

        require(value >= 0, "Incorrect transfer amount");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(balanceOf[to] + value >= balanceOf[to], "Transfer failed");
        require(
            value <= allowance[from][msg.sender],
            "The transfer amount is higher than the available amount"
        );

        balanceOf[from] = SafeMath.sub(balanceOf[from], value);
        balanceOf[to] = SafeMath.add(balanceOf[to], value);
        allowance[from][msg.sender] = SafeMath.sub(
            allowance[from][msg.sender],
            value
        );

        emit Transfer(from, to, value);
    }

    function calcTokenReceived(uint256 _eth) external view returns (uint256) {

        return SafeMath.div(_eth * 10**8, sellingPrice);
    }

    function calcTokenRequired(uint256 _eth) external view returns (uint256) {

        return SafeMath.div(this.calcTokenReceived(_eth), 10);
    }

    function calcTokenValue(uint256 tokenNumber)
        external
        view
        returns (uint256)
    {

        return SafeMath.mul(SafeMath.div(tokenNumber, 10**8), sellingPrice);
    }

    function getToken(uint256 value) external {

        require(
            msg.sender == exAddr || msg.sender == lotteryAddr,
            "Insufficient permissions"
        );
        require(
            value <= surplusSupply,
            "require remaining supply are larger than the tokens"
        );
        surplusSupply = SafeMath.sub(surplusSupply, value);
        supplied = SafeMath.add(supplied, value);
        uint256 count = SafeMath.div(supplied, 10**8 * 100000);
        riseTimes = riseSellingPrice(riseTimes, count);
        balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], value);
    }

    function advancedTransfer(address addr, uint256 value) external {

        require(msg.sender == exAddr, "Insufficient permissions");
        require(balanceOf[addr] >= value, "Insufficient tokens required");
        balanceOf[addr] = SafeMath.sub(balanceOf[addr], value);
        balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], value);
        emit Transfer(addr, msg.sender, value);
    }

    function burn(address addr, uint256 value) public {

        require(
            msg.sender == runAddr || msg.sender == lotteryAddr,
            "Insufficient permissions"
        );
        require(balanceOf[addr] >= value, "Insufficient tokens required");
        balanceOf[addr] = SafeMath.sub(balanceOf[addr], value);
        balanceOf[address(0x0)] = SafeMath.add(balanceOf[address(0x0)], value);

        emit Transfer(addr, address(0x0), value);
    }

    function aaa(uint256 a, uint256 b) external pure returns (uint256) {

        return a + b;
    }

    function bbb(uint256 a, uint256 b) external pure returns (uint256) {

        return a - b;
    }
}