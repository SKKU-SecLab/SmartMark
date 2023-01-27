



pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;

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



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



interface IPool {


  function stake(uint256 amount) external;


  function withdraw(uint256 amount) external;


  function exit() external;


  function getReward() external;


}



interface IBasisApeFactory {


  function pool() external returns (address);


  function asset() external returns (address);


  function bac() external returns (address);


}



contract BasisApe is Ownable {

  address public factory;
  address public beneficiary;

  event Deposit(uint256 amount);
  event Withdraw(address recipient, uint256 amount);
  event EmergencyExit(address recipient);
  event EmergencyWithdraw(address recipient, uint256 amount);

  constructor(address _beneficiary) Ownable() public {
    factory = msg.sender;
    beneficiary = _beneficiary;
  }

  function deposit(uint256 amount) external onlyOwner {

    address pool = IBasisApeFactory(factory).pool();
    address asset = IBasisApeFactory(factory).asset();
    IERC20(asset).approve(pool, amount);
    IPool(pool).stake(amount);
    emit Deposit(amount);
  }

  function withdraw(address recipient, uint256 amount) external onlyOwner {

    address pool = IBasisApeFactory(factory).pool();
    address asset = IBasisApeFactory(factory).asset();
    address bac = IBasisApeFactory(factory).bac();
    IPool(pool).withdraw(amount);
    IPool(pool).getReward();
    IERC20(asset).transfer(msg.sender, amount);
    IERC20(bac).transfer(recipient, IERC20(bac).balanceOf(address(this)));
    emit Withdraw(recipient, amount);
  }

  function emergencyExit(address recipient) external {

    require(msg.sender == beneficiary, "BasisApe: Must be called by beneficiary");
    address pool = IBasisApeFactory(factory).pool();
    address asset = IBasisApeFactory(factory).asset();
    address bac = IBasisApeFactory(factory).bac();
    IPool(pool).exit();
    IERC20(asset).transfer(recipient, IERC20(asset).balanceOf(address(this)));
    IERC20(bac).transfer(recipient, IERC20(bac).balanceOf(address(this)));
    emit EmergencyExit(recipient);
  }

  function emergencyWithdraw(address recipient, uint256 amount) external {

    require(msg.sender == beneficiary, "BasisApe: Must be called by beneficiary");
    address pool = IBasisApeFactory(factory).pool();
    address asset = IBasisApeFactory(factory).asset();
    IPool(pool).withdraw(amount);
    IERC20(asset).transfer(recipient, amount);
    emit EmergencyWithdraw(recipient, amount);
  }
}





contract BasisApeFactory {

  using SafeMath for uint256;

  address public pool;
  address public asset;
  address public bac;
  address public developer;
  uint256 public batchSize;
  mapping(address => address[]) public cups;
  mapping(address => uint256) public balances;

  uint256 constant FEE = 50; // .5% (10000 denominated)

  event Deposit(address account, uint256 amount);
  event Withdraw(address account, uint256 amount);
  event UpdateDeveloper(address newDeveloper);
  event DeveloperFeePaid(address developer, uint256 amount);

  constructor(address _pool, address _asset, address _bac, address _developer, uint256 _batchSize) public {
    pool = _pool;
    asset = _asset;
    bac = _bac;
    developer = _developer;
    batchSize = _batchSize;
  }

  function deposit(uint256 amount) external {

    uint256 remainder = balances[msg.sender] % batchSize;
    uint256 currentCup = balances[msg.sender].div(batchSize);
    uint256 remainingAmount = amount;

    if (remainder > 0) {
      address cup = cups[msg.sender][currentCup];
      if (remainder.add(amount) <= batchSize) {
        IERC20(asset).transferFrom(msg.sender, cup, amount); // Transferring directly to cup saves some gas
        BasisApe(cup).deposit(amount);
        remainder = remainder.add(amount) % batchSize; // Mod because when remainder is batchSize, we want it to be 0
        balances[msg.sender] = balances[msg.sender].add(amount);
        return;
      } else {
        uint256 amountToFillCup = batchSize.sub(remainder);
        IERC20(asset).transferFrom(msg.sender, cup, amountToFillCup); // Transferring directly to cup saves some gas
        BasisApe(cup).deposit(amountToFillCup);
        remainingAmount = remainingAmount.sub(amountToFillCup);
        currentCup = currentCup.add(1);
      }
    }

    while (remainingAmount >= batchSize) {
      address cup;
      if (cups[msg.sender].length <= currentCup) {
        cup = address(new BasisApe(msg.sender));
        cups[msg.sender].push(cup);
      } else {
        cup = cups[msg.sender][currentCup];
      }
      IERC20(asset).transferFrom(msg.sender, cup, batchSize);
      BasisApe(cup).deposit(batchSize);
      remainingAmount = remainingAmount.sub(batchSize);
      currentCup = currentCup.add(1);
    }

    if (remainingAmount > 0) {
      address cup;
      if (cups[msg.sender].length <= currentCup) {
        cup = address(new BasisApe(msg.sender));
        cups[msg.sender].push(cup);
      } else {
        cup = cups[msg.sender][currentCup];
      }
      IERC20(asset).transferFrom(msg.sender, cup, remainingAmount);
      BasisApe(cup).deposit(remainingAmount);
    }

    balances[msg.sender] = balances[msg.sender].add(amount);
    emit Deposit(msg.sender, amount);
  }

  function withdraw(address recipient, uint256 amount) external {

    require(amount <= balances[msg.sender], "BasisApeFactory: Must have sufficient balance");

    uint256 remainder = balances[msg.sender] % batchSize;
    uint256 currentCup = balances[msg.sender].div(batchSize);
    uint256 remainingAmount = amount;

    if (remainder > 0) {
      address cup = cups[msg.sender][currentCup];
      if (amount <= remainder) {
        BasisApe(cup).withdraw(recipient, amount);
        balances[msg.sender] = balances[msg.sender].sub(amount, "BasisApeFactory: Must have sufficient balance");
        uint256 fee = amount.mul(FEE).div(10000);
        IERC20(asset).transfer(developer, fee);
        IERC20(asset).transfer(recipient, amount.sub(fee));
        emit DeveloperFeePaid(developer, fee);
        emit Withdraw(msg.sender, amount);
        return;
      } else {
        BasisApe(cup).withdraw(recipient, remainder);
        remainingAmount = remainingAmount.sub(remainder);
      }
    }

    while (remainingAmount >= batchSize) {
      currentCup = currentCup.sub(1);
      address cup = cups[msg.sender][currentCup];
      BasisApe(cup).withdraw(recipient, batchSize);
      remainingAmount = remainingAmount.sub(batchSize);
    }

    if (remainingAmount > 0) {
      currentCup = currentCup.sub(1);
      address cup = cups[msg.sender][currentCup];
      BasisApe(cup).withdraw(recipient, remainingAmount);
    }

    balances[msg.sender] = balances[msg.sender].sub(amount, "BasisApeFactory: Must have sufficient balance");
    uint256 fee = amount.mul(FEE).div(10000);
    IERC20(asset).transfer(developer, fee);
    IERC20(asset).transfer(recipient, amount.sub(fee));
    emit DeveloperFeePaid(developer, fee);
    emit Withdraw(msg.sender, amount);
  }

  function setDeveloper(address _developer) external {

    require(msg.sender == developer, "BasisApeFactory: Must be called by developer");
    developer = _developer;
    emit UpdateDeveloper(_developer);
  }

  function numCups(address account) external view returns (uint256) {

    return cups[account].length;
  }

  function balanceOf(address account) external view returns (uint256) {

    return balances[account];
  }
}