
pragma solidity ^0.4.24;


interface IZCDistribution {


    function getSentAmount() external pure returns (uint256);

}


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ZCVesting {


    using SafeMath for uint256;

    uint256 public releasedAmount = 0;
    ERC20Basic public token;
    IZCDistribution public dist;
    address public releaseAddress;

    uint256 internal constant STEP_DIST_TOKENS = 15000000 * (10**18);
    uint256 internal constant MAX_DIST_TOKENS = 150000000 * (10**18);

    constructor(ERC20Basic _tokenAddr, IZCDistribution _distAddr, address _releaseAddr) public {
        assert(_tokenAddr != address(0));
        assert(_distAddr != address(0));
        assert(_releaseAddr != address(0));
        token = _tokenAddr;
        dist = _distAddr;
        releaseAddress = _releaseAddr;
    }

    event TokenReleased(uint256 releaseAmount);


    function release() public  returns (uint256) {

        
        uint256 distAmount = dist.getSentAmount();
        if (distAmount < STEP_DIST_TOKENS) 
            return 0;

        uint256 currBalance = token.balanceOf(address(this));

        if (distAmount >= MAX_DIST_TOKENS) {
            assert(token.transfer(releaseAddress, currBalance));
            releasedAmount = releasedAmount.add(currBalance);
            return currBalance;
        }

        uint256 releaseAllowed = currBalance.add(releasedAmount).div(10).mul(distAmount.div(STEP_DIST_TOKENS));

        if (releaseAllowed <= releasedAmount)
            return 0;

        uint256 releaseAmount = releaseAllowed.sub(releasedAmount);
        releasedAmount = releasedAmount.add(releaseAmount);
        assert(token.transfer(releaseAddress, releaseAmount));
        emit TokenReleased(releaseAmount);
        return releaseAmount;
    }

    function currentBalance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }
}