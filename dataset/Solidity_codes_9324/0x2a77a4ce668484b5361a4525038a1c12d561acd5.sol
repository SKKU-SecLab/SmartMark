pragma solidity >= 0.6.4;

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function mint(address account, uint256 amount) external;

  function burn(uint256 amount) external;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity >= 0.6.6;

interface vaultInterface {

  function tokenBuy(address token, address account) external;

  function tokenSell(address token, address payable account) external;

  function addLiquidity(address account) external;

  function removeLiquidity(uint256 shares) external;

  function updatePrice() external;


  function getActive() external view returns(bool);

  function getMultiplier() external view returns(uint256);

  function getBullToken() external view returns(address);

  function getBearToken() external view returns(address);

  function getLatestRoundId() external view returns(uint256);

  function getPrice(address token) external view returns(uint256);

  function getEquity(address token) external view returns(uint256);

  function getBuyFee() external view returns(uint256);

  function getSellFee() external view returns(uint256);

  function getTotalLiqShares() external view returns(uint256);

  function getLiqFees() external view returns(uint256);

  function getBalanceEquity() external view returns(uint256);

  function getLiqTokens(address token) external view returns(uint256);

  function getLiqEquity(address token) external view returns(uint256);

  function getUserShares(address account) external view returns(uint256);


  function getTotalEquity() external view returns(uint256);

  function getTokenEquity(address token) external view returns(uint256);

  function getTotalLiqEquity() external view returns(uint256);

  function getDepositEquity() external view returns(uint256);

}

pragma solidity >= 0.6.4;


contract router {


  constructor() public { }

  modifier ensure(uint deadline) {

    require(deadline >= block.timestamp, 'SynLevRouter: EXPIRED');
    _;
  }

  receive() external payable {}

  function buyBullTokens(
    address payable vault,
    uint256 minPrice,
    uint256 maxPrice,
    uint256 deadline
  ) public payable ensure(deadline) {

    vaultInterface ivault = vaultInterface(vault);
    address token = ivault.getBullToken();
    ivault.updatePrice();
    uint256 price = ivault.getPrice(token);
    require(price >= minPrice && price <= maxPrice, 'SynLevRouter: TOKEN PRICE OUT OF RANGE');
    vault.transfer(address(this).balance);
    ivault.tokenBuy(token, msg.sender);
  }

  function sellBullTokens(
    address vault,
    uint256 amount,
    uint256 minPrice,
    uint256 maxPrice,
    uint256 deadline
  ) public ensure(deadline) {

    vaultInterface ivault = vaultInterface(vault);
    address token = ivault.getBullToken();
    ivault.updatePrice();

    IERC20 itoken = IERC20(token);
    uint256 price = ivault.getPrice(token);
    require(price >= minPrice && price <= maxPrice, 'SynLevRouter: TOKEN PRICE OUT OF RANGE');
    require(itoken.transferFrom(msg.sender, vault, amount));
    ivault.tokenSell(token, msg.sender);
  }

  function buyBearTokens(
    address payable vault,
    uint256 minPrice,
    uint256 maxPrice,
    uint256 deadline
  ) public payable ensure(deadline) {

    vaultInterface ivault = vaultInterface(vault);
    address token = ivault.getBearToken();
    ivault.updatePrice();
    uint256 price = ivault.getPrice(token);
    require(price >= minPrice && price <= maxPrice, 'SynLevRouter: TOKEN PRICE OUT OF RANGE');
    vault.transfer(address(this).balance);
    ivault.tokenBuy(token, msg.sender);
  }

  function sellBearTokens(
    address vault,
    uint256 amount,
    uint256 minPrice,
    uint256 maxPrice,
    uint256 deadline
  ) public ensure(deadline) {

    vaultInterface ivault = vaultInterface(vault);
    address token = ivault.getBearToken();
    ivault.updatePrice();
    IERC20 itoken = IERC20(token);
    uint256 price = ivault.getPrice(token);
    require(price >= minPrice && price <= maxPrice, 'SynLevRouter: TOKEN PRICE OUT OF RANGE');
    require(itoken.transferFrom(msg.sender, vault, amount));
    ivault.tokenSell(token, msg.sender);
  }



}
