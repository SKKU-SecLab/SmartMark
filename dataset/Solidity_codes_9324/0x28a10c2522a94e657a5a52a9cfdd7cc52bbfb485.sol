
pragma solidity ^0.4.24;


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

    require(b > 0); // Solidity only automatically asserts when dividing by 0
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


contract ITokenConverter {    

    using SafeMath for uint256;

    function convert(
        IERC20 _srcToken,
        IERC20 _destToken,
        uint256 _srcAmount,
        uint256 _destAmount
        ) external payable returns (uint256);


    function getExpectedRate(IERC20 _srcToken, IERC20 _destToken, uint256 _srcAmount) 
        public view returns(uint256 expectedRate, uint256 slippageRate);

}


contract IKyberNetwork {

    function trade(
        IERC20 _srcToken,
        uint _srcAmount,
        IERC20 _destToken,
        address _destAddress, 
        uint _maxDestAmount,	
        uint _minConversionRate,	
        address _walletId
        ) 
        public payable returns(uint);


    function getExpectedRate(IERC20 _srcToken, IERC20 _destToken, uint _srcAmount) 
        public view returns(uint expectedRate, uint slippageRate);

}


contract KyberConverter is ITokenConverter {

    IKyberNetwork public  kyber;
    uint256 private constant MAX_UINT = uint256(0) - 1;
    address public walletId;

    constructor (IKyberNetwork _kyber, address _walletId) public {
        kyber = _kyber;
        walletId = _walletId;
    }
    
    function convert(
        IERC20 _srcToken,
        IERC20 _destToken,
        uint256 _srcAmount,
        uint256 _destAmount
    ) 
    external payable returns (uint256)
    {

        uint256 prevSrcBalance = _srcToken.balanceOf(address(this));

        require(
            _srcToken.transferFrom(msg.sender, address(this), _srcAmount),
            "Could not transfer _srcToken to this contract"
        );

        require(
            _srcToken.approve(kyber, _srcAmount),
            "Could not approve kyber to use _srcToken on behalf of this contract"
        );

        uint256 minRate;
        (, minRate) = getExpectedRate(_srcToken, _destToken, _srcAmount);

        uint256 amount = kyber.trade(
            _srcToken,
            _srcAmount,
            _destToken,
            address(this),
            _destAmount,
            minRate,
            walletId
        );

        require(
            _srcToken.approve(kyber, 0),
            "Could not clean approval of kyber to use _srcToken on behalf of this contract"
        );

        require(amount == _destAmount, "Amount bought is not equal to dest amount");

        uint256 change = _srcToken.balanceOf(address(this)) - prevSrcBalance;
        require(
            _srcToken.transfer(msg.sender, change),
            "Could not transfer change to sender"
        );


        require(
            _destToken.transfer(msg.sender, amount),
            "Could not transfer amount of _destToken to msg.sender"
        );

        return change;
    }

    function getExpectedRate(IERC20 _srcToken, IERC20 _destToken, uint256 _srcAmount) 
    public view returns(uint256 expectedRate, uint256 slippageRate) 
    {

        (slippageRate, expectedRate) = kyber.getExpectedRate(_srcToken, _destToken, _srcAmount);
    }
}