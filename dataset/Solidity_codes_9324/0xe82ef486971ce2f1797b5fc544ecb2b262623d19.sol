
pragma solidity 0.5.2;


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

interface IERC20 {

    function transferFrom(address from, address to, uint256 value) external returns (bool);

}



contract PaymentSplitter {

  using SafeMath for uint256;

  function split(
    address payable[] memory _recipients,
    uint256[] memory _splits
  ) public payable {

    require(_recipients.length > 0, "no data for split");
    require(_recipients.length == _splits.length, "splits and recipients should be of the same length");

    uint256 sumShares = 0;
    for (uint i = 0; i < _recipients.length; i++) {
      sumShares = sumShares.add(_splits[i]);
    }

    for (uint i = 0; i < _recipients.length - 1; i++) {
      _recipients[i].transfer(msg.value.mul(_splits[i]).div(sumShares));
    }
    _recipients[_recipients.length - 1].transfer(address(this).balance);
  }


  function splitERC20(
    address[] memory _recipients,
    uint256[] memory _splits,
    address _tokenAddr
  ) public {

    require(_recipients.length == _splits.length, "splits and recipients should be of the same length");
    IERC20 token = IERC20(_tokenAddr);
    for (uint i = 0; i < _recipients.length; i++) {
      token.transferFrom(msg.sender, _recipients[i], _splits[i]);
    }
  }

}