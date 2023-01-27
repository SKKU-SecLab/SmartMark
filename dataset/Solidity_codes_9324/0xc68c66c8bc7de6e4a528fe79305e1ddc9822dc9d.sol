
pragma solidity 0.4.25;


library Math {

  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {

    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}


interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



contract SGAToSGRTokenExchange {

    string public constant VERSION = "1.0.0";

    using Math for uint256;
    address public constant SGA_TARGET_ADDRESS = address(1);

    IERC20 public sgaToken;
    IERC20 public sgrToken;

    event ExchangeSgaForSgrCompleted(address indexed _sgaHolder, uint256 _exchangedAmount);

    constructor(address _sgaTokenAddress, address _sgrTokenAddress) public {
        require(_sgaTokenAddress != address(0), "SGA token address is illegal");
        require(_sgrTokenAddress != address(0), "SGR token address is illegal");

        sgaToken = IERC20(_sgaTokenAddress);
        sgrToken = IERC20(_sgrTokenAddress);
    }


    function exchangeSGAtoSGR() external {

        handleExchangeSGAtoSGRFor(msg.sender);
    }

    function exchangeSGAtoSGRFor(address _sgaHolder) external {

        require(_sgaHolder != address(0), "SGA holder address is illegal");
        handleExchangeSGAtoSGRFor(_sgaHolder);
    }

    function handleExchangeSGAtoSGRFor(address _sgaHolder) internal {

        uint256 allowance = sgaToken.allowance(_sgaHolder, address(this));
        require(allowance > 0, "SGA allowance must be greater than zero");
        uint256 balance = sgaToken.balanceOf(_sgaHolder);
        require(balance > 0, "SGA balance must be greater than zero");
        uint256 amountToExchange = allowance.min(balance);

        sgaToken.transferFrom(_sgaHolder, SGA_TARGET_ADDRESS, amountToExchange);
        sgrToken.transfer(_sgaHolder, amountToExchange);
        emit ExchangeSgaForSgrCompleted(_sgaHolder, amountToExchange);
    }
}