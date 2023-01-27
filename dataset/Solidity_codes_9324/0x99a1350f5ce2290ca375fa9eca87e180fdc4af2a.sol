
pragma solidity >=0.6.0 <0.8.0; // use 0.6.12 to compile this file

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// UNLICENSED

pragma solidity 0.6.12;

interface ISwapPriceCalculator
{

    function calc(uint256 receivedEthAmount,
                  uint256 expectedTokensAmount,
                  uint16  slippage,
                  uint256 ethReserve,
                  uint256 tokensSold,
                  bool 	  excludeFee) external view returns (uint256 actualTokensAmount,
															 uint256 ethFeeAdd,
															 uint256 actualEthAmount);

}// UNLICENSED

pragma solidity 0.6.12;


contract Swapper
{

    using SafeMath for uint256;
    
    address private admin;
    IERC20 private token;
    ISwapPriceCalculator private priceCalculator;
    
    uint256 private ethReserve;
    uint256 private ethReserveTaken;
    uint256 private ethFee;
    uint256 private ethFeeTaken;
    uint256 private tokensSold;
    
    string private constant ERR_MSG_SENDER = "ERR_MSG_SENDER";
    string private constant ERR_AMOUNT = "ERR_AMOUNT";
    string private constant ERR_ZERO_ETH = "ERR_ZERO_ETH";
    
    event Swap(uint256 receivedEth,
               uint256 expectedTokens,
               uint16 slippage,
               uint256 ethFeeAdd,
               uint256 actualTokens,
               uint256 tokensSold);
    
    constructor(address _admin, address _token, address _priceCalculator) public
    {
        admin = _admin;
        token = IERC20(_token);
        priceCalculator = ISwapPriceCalculator(_priceCalculator);
    }
    
    function getAdmin() external view returns (address)
    {

        return admin;
    }
    
    function getToken() external view returns (address)
    {

        return address(token);
    }
    
    function getTotalEthBalance() external view returns (uint256)
    {

        return address(this).balance;
    }
    
    function sendEth(address payable _to) external returns (uint256 ethReserveTaken_, uint256 ethFeeTaken_)
    {

        require(msg.sender == admin, ERR_MSG_SENDER);
        
        _to.transfer(address(this).balance);
        
        ethReserveTaken_ = ethReserve - ethReserveTaken;
        ethFeeTaken_ = ethFee - ethFeeTaken;
        
        ethReserveTaken = ethReserve;
        ethFeeTaken = ethFee;
    }
    
    function getTotalTokensBalance() external view returns (uint256)
    {

        return token.balanceOf(address(this));
    }
    
    function sendTokens(address _to, uint256 _amount) external
    {

        require(msg.sender == admin, ERR_MSG_SENDER);
        
        if(_amount == 0)
        {
            token.transfer(_to, token.balanceOf(address(this)));
        }
        else
        {
            token.transfer(_to, _amount);
        }
    }
    
    function getPriceCalculator() external view returns (address)
    {

        return address(priceCalculator);
    }
    
    function setPriceCalculator(address _priceCalculator) external
    {

        require(msg.sender == admin, ERR_MSG_SENDER);
        
        priceCalculator = ISwapPriceCalculator(_priceCalculator);
    }
    
    function calcPrice(uint256 _ethAmount, bool _excludeFee) external view returns (uint256, uint256, uint256)
    {

        require(_ethAmount > 0, ERR_ZERO_ETH);
        
        return priceCalculator.calc(_ethAmount, 0, 0, ethReserve, tokensSold, _excludeFee);
    }
    
    function getState() external view returns (uint256 ethReserve_,
                                               uint256 ethReserveTaken_,
                                               uint256 ethFee_,
                                               uint256 ethFeeTaken_,
                                               uint256 tokensSold_)
    {

        ethReserve_ = ethReserve;
        ethReserveTaken_ = ethReserveTaken;
        ethFee_ = ethFee;
        ethFeeTaken_ = ethFeeTaken;
        tokensSold_ = tokensSold;
    }
    
    function swap(uint256 _expectedTokensAmount, uint16 _slippage, bool _excludeFee) external payable
    {

        require(msg.value > 0, ERR_ZERO_ETH);
        require(_expectedTokensAmount > 0, "ERR_ZERO_EXP_AMOUNT");
        require(_slippage <= 500, "ERR_SLIPPAGE_TOO_BIG");
        
        (uint256 actualTokensAmount, uint256 ethFeeAdd, uint256 actualEthAmount)
            = priceCalculator.calc(msg.value, _expectedTokensAmount, _slippage, ethReserve, tokensSold, _excludeFee);
            
        require(actualTokensAmount > 0, "ERR_ZERO_ACTUAL_TOKENS");
        require(msg.value == actualEthAmount, "ERR_WRONG_ETH_AMOUNT");
        
        ethFee = ethFee.add(ethFeeAdd);
        ethReserve = ethReserve.add(msg.value.sub(ethFeeAdd));
        tokensSold = tokensSold.add(actualTokensAmount);
        
        token.transfer(msg.sender, actualTokensAmount);
     
        emit Swap(msg.value, _expectedTokensAmount, _slippage, ethFeeAdd, actualTokensAmount, tokensSold);
    }
}