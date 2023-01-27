
pragma solidity 0.5.8;

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeERC20 {

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require(token.approve(spender, value));
    }
}


contract Ownable {

    address payable public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }


    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == owner;
    }

    function transferOwnership(address payable newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract sellTokens is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;


    uint256 public rate;


    constructor(uint256 _rate, address _token) public {
        require(_token != address(0) );

        token = IERC20(_token);
        rate = _rate;
    }


    function() payable external {
        buyTokens();
    }


    function buyTokens() payable public {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(msg.sender, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        if (tokens > token.balanceOf(address(this))) {
            tokens = token.balanceOf(address(this));

            uint price = tokens.div(rate);

            uint _diff =  weiAmount.sub(price);

            if (_diff > 0) {
                msg.sender.transfer(_diff);
            }
        }

        _processPurchase(msg.sender, tokens);
    }


    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {

        require(token.balanceOf(address(this)) > 0);
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }


    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {

        return _weiAmount.mul(rate);
    }


    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

        token.safeTransfer(_beneficiary, _tokenAmount);
    }


    function setRate(uint256 _rate) onlyOwner external {

        rate = _rate;
    }


    function withdrawETH() onlyOwner external{

        owner.transfer(address(this).balance);
    }

    
    function withdrawTokens(address _t) onlyOwner external {

        IERC20 _token = IERC20(_t);
        uint balance = _token.balanceOf(address(this));
        _token.safeTransfer(owner, balance);
    }

}


contract ReentrancyGuard {


    uint256 private _guardCounter;

    constructor() internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }

}


contract buyTokens is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 public rate;

    constructor(uint256 _rate, address _token) public {
        require(_token != address(0) );

        token = IERC20(_token);
        rate = _rate;
    }


    function() external payable{
    }


    function sellToken(uint _amount) public {

        _sellTokens(msg.sender, _amount);
    }


    function _sellTokens(address payable _from, uint256 _amount) nonReentrant  internal {

        require(_amount > 0);
        token.safeTransferFrom(_from, address(this), _amount);

        uint256 tokensAmount = _amount;

        uint weiAmount = tokensAmount.div(rate);

        if (weiAmount > address(this).balance) {
            tokensAmount = address(this).balance.mul(rate);
            weiAmount = address(this).balance;

            uint _diff =  _amount.sub(tokensAmount);

            if (_diff > 0) {
                token.safeTransfer(_from, _diff);
            }
        }

        _from.transfer(weiAmount);
    }


    function receiveApproval(address payable _from, uint256 _value, address _token, bytes memory _extraData) public {

        require(_token == address(token));
        require(msg.sender == address(token));

        _extraData;
        _sellTokens(_from, _value);
    }


    function setRate(uint256 _rate) onlyOwner external {

        rate = _rate;
    }


    function withdrawETH() onlyOwner external{

        owner.transfer(address(this).balance);
    }


    function withdrawTokens(address _t) onlyOwner external {

        IERC20 _token = IERC20(_t);
        uint balance = _token.balanceOf(address(this));
        _token.safeTransfer(owner, balance);
    }

}