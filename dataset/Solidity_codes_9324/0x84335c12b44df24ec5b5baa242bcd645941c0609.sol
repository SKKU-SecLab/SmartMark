
pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
 }

contract ERC20 {

	function totalSupply() external view returns (uint);

	function balanceOf(address tokenlender) external view returns (uint balance);

	function allowance(address tokenlender, address spender) external view returns (uint remaining);

	function transfer(address to, uint tokens) external returns (bool success);

	function approve(address spender, uint tokens) external returns (bool success);

	function transferFrom(address from, address to, uint tokens) public returns (bool success);


	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenlender, address indexed spender, uint tokens);
}

contract ApprovalHolder {


	using SafeMath for uint256;

    address payable public owner;
    address public admin;
    address public taxRecipient;
    uint256 public taxFee;
    ERC20 public token;
    mapping(address => bool) public isInvoker;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdminTransferred(address indexed previousOwner, address indexed newOwner);
    event InvokerAdded(address indexed newInvoker);
    event InvokerRemoved(address indexed previousInvoker);
    event RecipientChanged(address indexed previousRecipient, address indexed newRecipient);
    event TaxFeeChanged(uint256 indexed previousFee, uint256 indexed newFee);
    event TransferOnBehalf(address indexed from, address indexed to, uint256 value, uint256 tax, address taxRecipient, address tokenAddress);
    event TokenTransferred(address indexed to, uint256 amount);  
    event EtherTransferred(address indexed to, uint256 amount);  

    constructor(address _admin, address _taxRecipient, uint256 _taxFee, address _tokenAddress) public {
        owner = msg.sender;
        admin = _admin;
        taxRecipient = _taxRecipient; 	
        taxFee = _taxFee;
        token = ERC20(_tokenAddress);
    }

    function selfDestruct() public {

        require(msg.sender == owner, "not owner");
        selfdestruct(owner);
    }

    function transferOwnership(address payable _newOwner) public {

        require(msg.sender == owner, "not owner");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, owner);
    }

    function transferAdmin(address _newAdmin) public {

        require(msg.sender == admin, "not admin");
        admin = _newAdmin;
        emit AdminTransferred(msg.sender, admin);
    }

    function addInvoker(address _newInvoker) public {

        require(msg.sender == admin, "not admin");
        isInvoker[_newInvoker] = true;
        emit InvokerAdded(_newInvoker);
    }

    function removeInvoker(address _previousInvoker) public {

        require(msg.sender == admin, "not admin");
        require(isInvoker[_previousInvoker] == true, "address is not an invoker");
        isInvoker[_previousInvoker] = false;
        emit InvokerRemoved(_previousInvoker);
    }

    function changeRecipient(address _newRecipient) public {

        require(msg.sender == admin, "not admin");
        address _previousRecipient = taxRecipient;
        taxRecipient = _newRecipient;
        emit RecipientChanged(_previousRecipient, _newRecipient);
    }

    function changeTaxFee(uint256 _newFee) public {

        require(msg.sender == admin, "not admin");
        uint256 _previousFee = taxFee;
        taxFee = _newFee;
        emit TaxFeeChanged(_previousFee, _newFee);
    }

    function transferToken(address _tokenRecipient, uint256 _amount) public {

        require(msg.sender == admin, "not admin");
        require(token.transfer(_tokenRecipient, _amount));
        emit TokenTransferred(_tokenRecipient, _amount);
    }

    function transferEther(address payable _etherRecipient, uint256 _amount) public {

        require(msg.sender == admin, "not admin");
        _etherRecipient.transfer(_amount);
        emit EtherTransferred(_etherRecipient, _amount);
    }

    function transferOnBehalf(address from, address to, uint256 amount) public {

        require(isInvoker[msg.sender] == true, "not invoker");
        if(taxFee == 0) {
            require(token.transferFrom(from, to, amount));
        } else {
            require(token.transferFrom(from, to, amount));
            require(token.transferFrom(from, taxRecipient, taxFee));
        }
        emit TransferOnBehalf(from, to, amount, taxFee, taxRecipient, address(token));
    }
}