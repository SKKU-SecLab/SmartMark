
pragma solidity 0.4.25;

contract IERC20 {

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

}

library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0);
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

contract ARXExchange {

    using SafeMath for uint256;

    IERC20 public token;

    address private _owner;

    uint256 private _priceETH;

    event Exchanged(address indexed addr, uint256 tokens, uint256 value);
    event ChangePriceETH(uint256 oldValue, uint256 newValue);

    modifier onlyOwner() {

        require(msg.sender == _owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0));

        _owner = newOwner;
    }

    constructor(uint256 priceETH, address ARXToken) public {
        _owner = msg.sender;
        token = IERC20(ARXToken);
        setPriceETH(priceETH);
    }

    function setPriceETH(uint256 newPriceETH) public onlyOwner {

        require(newPriceETH != 0);
        emit ChangePriceETH(_priceETH, newPriceETH);
        _priceETH = newPriceETH;
    }

    function withdrawCoinBalance(address recipient) external onlyOwner {

        uint256 balanceARX = token.balanceOf(address(this));
        token.transfer(recipient, balanceARX);
    }

    function getInfo(address addr) external view returns(uint256, uint256, uint256, uint256) {

        return(_priceETH, token.balanceOf(addr), token.allowance(addr, address(this)), token.allowance(addr, address(this)) * _priceETH);
    }

    function amIReadyToExchange(address addr) public view returns(bool) {

        uint256 approved = token.allowance(addr, address(this));
        if (approved > 0) {
            return true;
        } else {
            return false;
        }
    }

    function() external payable {
        if (amIReadyToExchange(msg.sender)) {
            toETH();
        }
    }

    function toETH() public {

        uint256 amount = token.allowance(msg.sender, address(this));
        require(amount > 0);
        token.transferFrom(msg.sender, address(this), amount);
        msg.sender.transfer(amount.mul(_priceETH));
        emit Exchanged(msg.sender, amount, amount.mul(_priceETH));
    }
}