
pragma solidity ^0.4.21;

library SafeMath {

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {

		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}
	
	function div(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a / b;
		return c;
	}
	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {

		assert(b <= a);
		return a - b;
	}
	
	function add(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}


contract Ownable {

	address public owner;
	
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
	function Ownable() public {

		owner = msg.sender;
	}
	
	modifier onlyOwner() {

		require(msg.sender == owner);
		_;
	}
	
	function transferOwnership(address _newOwner) public onlyOwner {

		require(_newOwner != address(0));
		emit OwnershipTransferred(owner, _newOwner);
		owner = _newOwner;
	}
}

contract Destroyable is Ownable {

	function destroy() public onlyOwner {

		selfdestruct(owner);
	}
}

interface Token {

	function balanceOf(address who) view external returns (uint256);

	
	function transfer(address _to, uint256 _value) external returns (bool);

}

contract BrokerBank is Ownable, Destroyable {

	using SafeMath for uint256;
	
	Token public token;
	uint256 public commission;
	address public broker;
	address public beneficiary;
	
	event CommissionChanged(uint256 _previousCommission, uint256 _commision);
	event BrokerChanged(address _previousBroker, address _broker);
	event BeneficiaryChanged(address _previousBeneficiary, address _beneficiary);
	event Withdrawn(uint256 _balance);
	
	function BrokerBank (address _token, uint256 _commission, address _broker, address _beneficiary) public {
		require(_token != address(0));
		token = Token(_token);
		commission = _commission;
		broker = _broker;
		beneficiary = _beneficiary;
	}
	
	function Balance() view public returns (uint256 _balance) {

		return token.balanceOf(address(this));
	}
	
	function destroy() public onlyOwner {

		token.transfer(owner, token.balanceOf(address(this)));
		selfdestruct(owner);
	}
	
	function withdraw() public onlyOwner {

		uint256 balance = token.balanceOf(address(this));
		uint256 hundred = 100;
		uint256 brokerWithdraw = (balance.div(hundred)).mul(commission);
		uint256 beneficiaryWithdraw = balance.sub(brokerWithdraw);
		token.transfer(beneficiary, beneficiaryWithdraw);
		token.transfer(broker, brokerWithdraw);
		emit Withdrawn(balance);
	}
	
	function changeCommission(uint256 _commission) public onlyOwner {

		emit CommissionChanged(commission, _commission);
		commission = _commission;
	}
	
	function changeBroker(address _broker) public onlyOwner {

		emit BrokerChanged(broker, _broker);
		broker = _broker;
	}
	
	function changeBeneficiary(address _beneficiary) public onlyOwner {

		emit BeneficiaryChanged(beneficiary, _beneficiary);
		beneficiary = _beneficiary;
	}
}