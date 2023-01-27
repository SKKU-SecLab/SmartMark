
  
  
  


pragma solidity ^0.6.0;
interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}




contract Crowdsale {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;

    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;
    
    address owner;

    event TokensPurchased(address indexed purchaser, uint256 value, uint256 amount);

    constructor (IERC20 token) public {
        _rate = 1000;
        _wallet = 0x246e6fd15EbB6db65FFD4Fe01A4CdE10801b5e9A;
        _token = token;
        owner = msg.sender;
    }
modifier onlyOwner(){

    require(msg.sender == owner);
    _;
}
    receive() external payable {
        buyTokens();
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function wallet() public view returns (address) {

        return _wallet;
    }

    function rate() public view returns (uint256) {

        return _rate;
    }
    function remainingTokens() public view returns (uint256) {

        return _token.balanceOf(address(this));
    }

    function weiRaised() public view returns (uint256) {

        return _weiRaised;
    }
    function changeRate(uint256 price) public onlyOwner() returns(bool success) {

        _rate = price;
        return success;
    }
    function buyTokens() public payable {

        
        uint256 weiAmount = msg.value;
        
        uint256 tokens = _getTokenAmount(weiAmount);
        require(_token.balanceOf(msg.sender).add(tokens) > 10000);
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase( tokens);
        emit TokensPurchased(msg.sender, weiAmount, tokens);

        _forwardFunds();
    }

    function _deliverTokens( uint256 tokenAmount) internal {

        _token.safeTransfer(msg.sender, tokenAmount);
    }

    function _processPurchase(uint256 tokenAmount) internal {

        _deliverTokens(tokenAmount);
    }
    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.mul(_rate);
    }
    
    function _forwardFunds() internal {

        _wallet.transfer(msg.value);
    }
    
    function endIco(address _address) onlyOwner() public{

        _token.transfer(_address, remainingTokens());
    }
}