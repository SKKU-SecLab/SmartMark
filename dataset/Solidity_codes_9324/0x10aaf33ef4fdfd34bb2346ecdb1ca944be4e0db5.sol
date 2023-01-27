
pragma solidity 0.6.0;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0);
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}

interface ERC20 {

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint value) external  returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}

contract YFMSTokenLocks {

  using SafeMath for uint256;

  uint256 public endDateRewards;
  uint256 public YFMSLockedRewards;
  address public owner;
  ERC20 public YFMSToken;

  constructor(address _wallet) public {
    owner = msg.sender; 
    YFMSToken = ERC20(_wallet);
  }

  function lockRewardsTokens (address _from, uint256 _amount) public {
    require(_from == owner);
    require(YFMSToken.balanceOf(_from) >= _amount);
    YFMSLockedRewards = _amount;
    endDateRewards = now.add(7 days);
    YFMSToken.transferFrom(_from, address(this), _amount);
  }

  function withdrawRewardsTokens(address _to, uint256 _amount) public {

    require(msg.sender == owner);
    require(_amount <= YFMSLockedRewards);
    require(now >= endDateRewards);
    YFMSLockedRewards = YFMSLockedRewards.sub(_amount);
    YFMSToken.transfer(_to, _amount);
  }

  function incrementTimelockOneDay() public {

    require(msg.sender == owner);
    endDateRewards = endDateRewards.add(2 days); 
  }

  function balanceOf() public view returns (uint256) {

    return YFMSLockedRewards;
  }
}