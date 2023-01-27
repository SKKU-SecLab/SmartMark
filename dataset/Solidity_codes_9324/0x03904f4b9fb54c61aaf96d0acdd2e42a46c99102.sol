
pragma solidity 0.6.0;

contract Nest_3_TokenSave {

    using SafeMath for uint256;
    
    Nest_3_VoteFactory _voteFactory;                                 //  Voting contract
    mapping(address => mapping(address => uint256))  _baseMapping;   //  Ledger token=>user=>amount
    
    constructor(address voteFactory) public {
        _voteFactory = Nest_3_VoteFactory(voteFactory); 
    }
    
    function changeMapping(address voteFactory) public onlyOwner {

        _voteFactory = Nest_3_VoteFactory(voteFactory); 
    }
    
    function takeOut(uint256 num, address token, address target) public onlyContract {

        require(num <= _baseMapping[token][address(target)], "Insufficient storage balance");
        _baseMapping[token][address(target)] = _baseMapping[token][address(target)].sub(num);
        ERC20(token).transfer(address(target), num);
    }
    
    function depositIn(uint256 num, address token, address target) public onlyContract {

        require(ERC20(token).transferFrom(address(target),address(this),num), "Authorization transfer failed");  
        _baseMapping[token][address(target)] = _baseMapping[token][address(target)].add(num);
    }
    
    function checkAmount(address sender, address token) public view returns(uint256) {

        return _baseMapping[token][address(sender)];
    }
    
    modifier onlyOwner(){

        require(_voteFactory.checkOwners(address(msg.sender)), "No authority");
        _;
    }
    
    modifier onlyContract(){

        require(_voteFactory.checkAddress("nest.v3.tokenAbonus") == address(msg.sender), "No authority");
        _;
    }
}

interface ERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Nest_3_VoteFactory {

	function checkAddress(string calldata name) external view returns (address contractAddress);

	function checkOwners(address man) external view returns (bool);

}

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