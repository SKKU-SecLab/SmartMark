
pragma solidity ^0.6.0;


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

    function ceil(uint256 a, uint256 m) internal pure returns (uint256 r) {

        return (a + m - 1) / m * m;
    }
}

contract Owned {

    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Only allowed by owner");
        _;
    }

    function transferOwnership(address payable _newOwner) external onlyOwner {

        require(_newOwner != address(0),"Invalid address passed");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}

contract PreSale is Owned {

    using SafeMath for uint256;
    
    address public tokenAddress;
    uint256 public constant startSale = 1613502000; // 16 Feb 2021, 7pm GMT
    uint256 public constant endSale =   1614106800; // 23 Feb 2021, 7pm GMT
    uint256 public constant claimDate = 1614110400; // 23 Feb 2021, 8pm GMT
    uint256 public purchasedTokens;
        
    mapping(address => uint256) public investor;
    
    constructor() public {
        owner = 0xa97F07bc8155f729bfF5B5312cf42b6bA7c4fCB9;
    }
    
    function SetTokenAddress(address _tokenAddress) external onlyOwner {

        tokenAddress = _tokenAddress;
    }
    
    receive() external payable{
        Invest();
    }
    
    function Invest() public payable{

        require( now > startSale && now < endSale , "Sale is closed");
        uint256 tokens = getTokenAmount(msg.value);
        investor[msg.sender] += tokens;
        purchasedTokens = purchasedTokens + tokens;
        owner.transfer(msg.value);
    }

    function getTokenAmount(uint256 amount) internal view returns(uint256){

        uint256 _tokens = 0;
        if (now <= startSale + 3 days){
            _tokens = amount * 100;
        }
        if (now > startSale + 3 days){
            _tokens = amount * 80;
        }
        return _tokens;
    }

    function ClaimTokens() external returns(bool){

        require(now >= claimDate, "Token claim date not reached");
        require(investor[msg.sender] > 0, "Not an investor");
        uint256 tokens = investor[msg.sender];
        investor[msg.sender] = 0;
        require(IERC20(tokenAddress).transfer(msg.sender, tokens));
        return true;
    }
    
    function getUnSoldTokens() onlyOwner external{

        require(block.timestamp > endSale, "sale is not closed");
        uint256 tokensInContract = IERC20(tokenAddress).balanceOf(address(this));
        require(tokensInContract > 0, "no unsold tokens in contract");
        require(IERC20(tokenAddress).transfer(owner, tokensInContract), "transfer of token failed");
    }
}