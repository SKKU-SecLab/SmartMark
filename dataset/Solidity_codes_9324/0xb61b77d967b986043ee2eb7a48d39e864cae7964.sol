
pragma solidity 0.7.3;

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
}// MIT

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
}// MIT

pragma solidity 0.7.3;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.7.3;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity 0.7.3;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity 0.7.3;


contract TOKENBridge is ReentrancyGuard, Context, Ownable {

  using SafeMath for uint256;

  mapping (address => bool) private validators;

  address payable private feeAddress;
  uint256 private feeRate = 0;
  bool private isFrozen = false;
  uint256 private maxTransactionWSG = 30000000000000000000;  // 30
  uint256 private maxTransactionGASPAY = 75000000000000000000;  // 75
  uint256 private maxTransactionGASG = 150000000000000000000;  // 150

  IERC20 private WSG_TOKEN;
  IERC20 private GASPAY_TOKEN;
  IERC20 private GASG_TOKEN;

  constructor(address _WSGToken, address _GASPAYToken, address _GASGToken) {
    WSG_TOKEN = IERC20(_WSGToken);
    GASPAY_TOKEN = IERC20(_GASPAYToken);
    GASG_TOKEN = IERC20(_GASGToken);
  }

  event Exchange(address indexed user, uint256 amount, uint256 fee, string project);

  function isValidator(address _addr) external view returns (bool) {

      return validators[_addr];
  }

  function addValidator(address _addr) external onlyOwner nonReentrant {

      validators[_addr] = true;        
  }

  function removeValidator(address _addr) external onlyOwner nonReentrant {

      if (validators[_addr]) {
          delete validators[_addr];
      }
  }

  function getFeeAddress() external view returns (address) {

    return feeAddress;
  }

  function setFeeAddress(address payable _feeAddress) external onlyOwner nonReentrant {

    require(_feeAddress != address(0), "Bad address");
    feeAddress = _feeAddress;
  }

  function getFeeRate() external view returns (uint256) {

    return feeRate;
  }

  function setFeeRate(uint256 _feeRate) external onlyOwner nonReentrant {

    feeRate = _feeRate;
  }

  function getMaxTransaction() external view returns (uint256 wsg, uint256 gaspay, uint256 gasg) {

    wsg = maxTransactionWSG;
    gaspay = maxTransactionGASPAY;
    gasg = maxTransactionGASG;
  }

  function setMaxTransactionWSG(uint256 _maxTransaction) external onlyOwner nonReentrant {

    require(_maxTransaction > 0, "Max transaction must be greater than 0");
    maxTransactionWSG = _maxTransaction;
  }

  function setMaxTransactionGASPAY(uint256 _maxTransaction) external onlyOwner nonReentrant {

    require(_maxTransaction > 0, "Max transaction must be greater than 0");
    maxTransactionGASPAY = _maxTransaction;
  }

  function setMaxTransactionGASG(uint256 _maxTransaction) external onlyOwner nonReentrant {

    require(_maxTransaction > 0, "Max transaction must be greater than 0");
    maxTransactionGASG = _maxTransaction;
  }

  function getFrozen() external view returns (bool) {

    return isFrozen;
  }

  function setFrozen(bool _isFrozen) external onlyOwner nonReentrant {

    isFrozen = _isFrozen;
  }

  function getTokenBalance() external view returns (uint256 wsg, uint256 gaspay, uint256 gasg) {

    wsg = WSG_TOKEN.balanceOf(address(this));
    gaspay = GASPAY_TOKEN.balanceOf(address(this));
    gasg = GASG_TOKEN.balanceOf(address(this));
  }

  function sweepWSGTokenBalance() external payable onlyOwner {

    uint256 amount2Pay = WSG_TOKEN.balanceOf(address(this));
    require(WSG_TOKEN.transfer(msg.sender, amount2Pay), "Unable to transfer funds");
  }

  function sweepGASPAYTokenBalance() external payable onlyOwner {

    uint256 amount2Pay = GASPAY_TOKEN.balanceOf(address(this));
    require(GASPAY_TOKEN.transfer(msg.sender, amount2Pay), "Unable to transfer funds");
  }

  function sweepGASGTokenBalance() external payable onlyOwner {

    uint256 amount2Pay = GASG_TOKEN.balanceOf(address(this));
    require(GASG_TOKEN.transfer(msg.sender, amount2Pay), "Unable to transfer funds");
  }

  function exchangeWSGToken(uint256 _amt) external payable nonReentrant {

    require(!isFrozen, "Contract is frozen");
    require(msg.value >= feeRate, "Fee not met");
    require(_amt > 0, "Amount must be greater than 0");
    require(WSG_TOKEN.allowance(msg.sender, address(this)) >= _amt, "Not enough allowance");
    feeAddress.transfer(msg.value);
    if(_amt > maxTransactionWSG) {
      require(WSG_TOKEN.transferFrom(msg.sender, address(this), maxTransactionWSG), "Unable to transfer funds");
      emit Exchange(msg.sender, maxTransactionWSG, msg.value, 'WSG');
    } else {
      require(WSG_TOKEN.transferFrom(msg.sender, address(this), _amt), "Unable to transfer funds");
      emit Exchange(msg.sender, _amt, msg.value, 'WSG');
    }
  }

  function exchangeGASPAYToken(uint256 _amt) external payable nonReentrant {

    require(!isFrozen, "Contract is frozen");
    require(msg.value >= feeRate, "Fee not met");
    require(_amt > 0, "Amount must be greater than 0");
    require(GASPAY_TOKEN.allowance(msg.sender, address(this)) >= _amt, "Not enough allowance");
    feeAddress.transfer(msg.value);
    if(_amt > maxTransactionGASPAY) {
      require(GASPAY_TOKEN.transferFrom(msg.sender, address(this), maxTransactionGASPAY), "Unable to transfer funds");
      emit Exchange(msg.sender, maxTransactionGASPAY, msg.value, 'GASPAY');
    } else {
      require(GASPAY_TOKEN.transferFrom(msg.sender, address(this), _amt), "Unable to transfer funds");
      emit Exchange(msg.sender, _amt, msg.value, 'GASPAY');
    }
  }

  function exchangeGASGToken(uint256 _amt) external payable nonReentrant {

    require(!isFrozen, "Contract is frozen");
    require(msg.value >= feeRate, "Fee not met");
    require(_amt > 0, "Amount must be greater than 0");
    require(GASG_TOKEN.allowance(msg.sender, address(this)) >= _amt, "Not enough allowance");
    feeAddress.transfer(msg.value);
    if(_amt > maxTransactionGASG) {
      require(GASG_TOKEN.transferFrom(msg.sender, address(this), maxTransactionGASG), "Unable to transfer funds");
      emit Exchange(msg.sender, maxTransactionGASG, msg.value, 'GASG');
    } else {
      require(GASG_TOKEN.transferFrom(msg.sender, address(this), _amt), "Unable to transfer funds");
      emit Exchange(msg.sender, _amt, msg.value, 'GASG');
    }
  }

}