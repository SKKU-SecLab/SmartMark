


pragma solidity 0.6.12;

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


pragma solidity 0.6.12;


contract MuteSwap {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    address public owner;
    address public muteContract;
    uint256 public amountSetToClaim;
    uint256 public amountClaimed;

    modifier onlyOwner() {

      require(msg.sender == owner, "MuteSwap::OnlyOwner: Not the owner");
      _;
    }

    constructor(address _muteContract) public {
        owner = msg.sender;
        muteContract = _muteContract;
    }

    function addSwapInfo(address[] memory _addresses, uint256[] memory _values) external onlyOwner {

        for (uint256 index = 0; index < _addresses.length; index++) {
            _balances[_addresses[index]] = _balances[_addresses[index]].add(_values[index]);
            amountSetToClaim = amountSetToClaim.add(_values[index]);
        }
    }

    function claimSwap() external {

        require(_balances[msg.sender] > 0, "MuteSwap::claimSwap: must have a balance greater than 0");
        require(IMute(muteContract).Mint(msg.sender, _balances[msg.sender]) == true);

        amountClaimed = amountClaimed.add(_balances[msg.sender]);
        _balances[msg.sender] = 0;
    }

    function claimBalance() external view returns (uint256) {

        return _balances[msg.sender];
    }
}

interface IMute {

    function Mint(address account, uint256 amount) external returns (bool);

}