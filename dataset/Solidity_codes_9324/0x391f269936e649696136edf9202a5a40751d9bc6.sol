

pragma solidity ^0.5.2;


interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function okToTransferTokens(address _holder, uint256 _amountToAdd) external view returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IFactory {

    function changeATFactoryAddress(address) external;

    function changeTDeployerAddress(address) external;

    function changeFPDeployerAddress(address) external;

    function changeDeployFees (uint256) external;
    function changeFeesCollector (address) external;
    function deployPanelContracts(string calldata, string calldata, string calldata, bytes32, uint8, uint8, uint8, uint256) external;

    function getTotalDeployFees() external view returns (uint256);

    function isFactoryDeployer(address) external view returns(bool);

    function isFactoryATGenerated(address) external view returns(bool);

    function isFactoryTGenerated(address) external view returns(bool);

    function isFactoryFPGenerated(address) external view returns(bool);

    function getTotalDeployer() external view returns(uint256);

    function getTotalATContracts() external view returns(uint256);

    function getTotalTContracts() external view returns(uint256);

    function getTotalFPContracts() external view returns(uint256);

    function getContractsByIndex(uint256) external view returns (address, address, address, address);

    function getDeployerAddressByIndex(uint256) external view returns (address);

    function getATAddressByIndex(uint256) external view returns (address);

    function getTAddressByIndex(uint256) external view returns (address);

    function getFPAddressByIndex(uint256) external view returns (address);

    function withdraw(address) external;

}


contract SeedDex {


  using SafeMath for uint;

  address public seedToken; // the seed token
  address public factoryAddress; // Address of the factory
  address private ethAddress = address(0);

  bool private depositingTokenFlag;

  mapping (address => mapping (address => uint)) private tokens;

  mapping (address => mapping (bytes32 => bool)) private orders;

  mapping (address => mapping (bytes32 => uint)) private orderFills;

  event Order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user);
  event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give);
  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);

  constructor(address _seedToken, address _factoryAddress)  public {
    seedToken = _seedToken;
    factoryAddress = _factoryAddress;
    depositingTokenFlag = false;
  }

  function() external {
    revert("ETH not accepted!");
  }



  function deposit() public payable {

    tokens[ethAddress][msg.sender] = tokens[ethAddress][msg.sender].add(msg.value);
    emit Deposit(ethAddress, msg.sender, msg.value, tokens[ethAddress][msg.sender]);
  }

  function withdraw(uint amount) public {

    require(tokens[ethAddress][msg.sender] >= amount, "Not enough balance");
    tokens[ethAddress][msg.sender] = tokens[ethAddress][msg.sender].sub(amount);
    msg.sender.transfer(amount);
    emit Withdraw(ethAddress, msg.sender, amount, tokens[ethAddress][msg.sender]);
  }
  
  function depositToken(address token, uint amount) public {

    require(token != ethAddress, "Seed: expecting the zero address to be ERC20");
    require(IFactory(factoryAddress).isFactoryTGenerated(token) || token == seedToken, "Seed: deposit allowed only for known tokens");

    depositingTokenFlag = true;
    IERC20(token).transferFrom(msg.sender, address(this), amount);
    depositingTokenFlag = false;
    tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);
    emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }


  
  function withdrawToken(address token, uint amount) public {

    require(token != ethAddress, "Seed: expecting the zero address to be ERC20");
    require(tokens[token][msg.sender] >= amount, "Not enough balance");

    tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
    require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    emit Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function balanceOf(address token, address user) public view returns (uint) {

    return tokens[token][user];
  }


  function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public {

    require(isValidPair(tokenGet, tokenGive), "Not a valid pair");
    require(canBeTransferred(tokenGet, msg.sender, amountGet), "Token quota exceeded");
    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
    orders[msg.sender][hash] = true;
    emit Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender);
  }

  function trade(
        address  tokenGet,
        uint     amountGet,
        address  tokenGive,
        uint     amountGive,
        uint     expires,
        uint     nonce,
        address  user,
        uint8    v,
        bytes32  r,
        bytes32  s,
        uint     amount) public {

    require(isValidPair(tokenGet, tokenGive), "Not a valid pair");
    require(canBeTransferred(tokenGet, msg.sender, amountGet), "Token quota exceeded");
    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
    bytes32 m = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    require(orders[user][hash] || ecrecover(m, v, r, s) == user, "Order does not exist");
    require(block.number <= expires, "Order Expired");
    require(orderFills[user][hash].add(amount) <= amountGet, "Order amount exceeds maximum availability");
    tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);
    orderFills[user][hash] = orderFills[user][hash].add(amount);
    uint amt = amountGive.mul(amount) / amountGet;
    emit Trade(tokenGet, amount, tokenGive, amt, user, msg.sender);
  }

  function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private {

    tokens[tokenGet][msg.sender] = tokens[tokenGet][msg.sender].sub(amount);
    tokens[tokenGet][user] = tokens[tokenGet][user].add(amount);
    tokens[tokenGive][user] = tokens[tokenGive][user].sub(amountGive.mul(amount).div(amountGet));
    tokens[tokenGive][msg.sender] = tokens[tokenGive][msg.sender].add(amountGive.mul(amount).div(amountGet));
  }

  function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) public view returns(bool) {

    if (tokens[tokenGet][sender] < amount) return false;
    if (availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) < amount) return false;
    if (!canBeTransferred(tokenGet, msg.sender, amountGet)) return false;

    return true;
  }

  function canBeTransferred(address token, address user, uint newAmt) private view returns(bool) {

    return (token == seedToken || IERC20(token).okToTransferTokens(user, newAmt + tokens[token][user]) ) ;
  }

  function availableVolume(
          address tokenGet,
          uint amountGet,
          address tokenGive,
          uint amountGive,
          uint expires,
          uint nonce,
          address user,
          uint8 v,
          bytes32 r,
          bytes32 s
  ) public view returns(uint) {


    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));

    if ( (orders[user][hash] || ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s) == user) || block.number <= expires ) {
      return 0;
    }

    uint[2] memory available;
    available[0] = amountGet.sub(orderFills[user][hash]);

    available[1] = tokens[tokenGive][user].mul(amountGet) / amountGive;

    if (available[0] < available[1]) {
      return available[0];
    } else {
      return available[1];
    }

  }

  function amountFilled(
          address tokenGet,
          uint amountGet,
          address tokenGive,
          uint amountGive,
          uint expires,
          uint nonce,
          address user/*,
          uint8 v,
          bytes32 r,
          bytes32 s*/
  ) public view returns(uint) {

    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
    return orderFills[user][hash];
  }

  function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {

    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
    bytes32 m = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    require(orders[msg.sender][hash] || ecrecover(m, v, r, s) == msg.sender, "Order does not exist");
    orderFills[msg.sender][hash] = amountGet;
    emit Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
  }
                                                
  function isValidPair(address tokenGet, address tokenGive) private view returns(bool) {

     if( isEthSeedPair(tokenGet, tokenGive) ) return true;
     return isSeedPair(tokenGet, tokenGive);
  }

  function isEthSeedPair(address tokenGet, address tokenGive) private view returns(bool) {

      if (tokenGet == ethAddress && tokenGive == seedToken) return true;
      if (tokenGet == seedToken && tokenGive == ethAddress) return true;
      return false;
  }

  function isSeedPair(address tokenGet, address tokenGive) private view returns(bool) {

      if (tokenGet == tokenGive) return false;
      if (tokenGet == seedToken) return true;
      if (tokenGive == seedToken) return true;
      return false;
  }
}