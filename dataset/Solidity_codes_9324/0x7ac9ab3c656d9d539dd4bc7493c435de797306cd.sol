pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.5.0;


contract TokenVesting is Ownable {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);

    IERC20 public _token;

    address private _beneficiary;

    uint256 private _start;

    uint256 private _released = 0;
    uint256 private _amount = 0;
    uint256[] private _schedule;
    uint256[] private _percent;

    constructor (IERC20 token, address beneficiary, uint256 amount, uint256[] memory schedule,
        uint256[] memory percent) public {
        require(beneficiary != address(0), "TokenVesting: beneficiary is the zero address");

        require(schedule.length == percent.length, "TokenVesting: Incorrect release schedule");
        require(schedule.length <= 255);

        _token = token;
        _beneficiary = beneficiary;
        _amount = amount;
        _schedule = schedule;
        _percent = percent;

    }

    function beneficiary() public view returns (address) {

        return _beneficiary;
    }
    modifier onlyBeneficiary() {

        require(isBeneficiary(), "caller is not the beneficiary");
        _;
    }
    function isBeneficiary() private view returns (bool) {

        return _msgSender() == _beneficiary;
    }
    function changeTokenAddress(IERC20 newToken) public onlyBeneficiary {

	    _token = newToken;
    }
    function tokenAddress() public view returns (IERC20) {

        return _token;
    }
    function getScheduleAndPercent() public view returns (uint256[] memory, uint256[] memory) {

	return (_schedule,_percent);
    }

    function totalAmount() public view returns (uint256) {

        return _amount;
    }

    function released() public view returns (uint256) {

        return _released;
    }

    function vestedAmount(uint256 ts) public view returns (uint256) {

        int8 unreleasedIdx = _releasableIdx(ts);
        if (unreleasedIdx >= 0) {
            return _amount.mul(_percent[uint(unreleasedIdx)]).div(10000);
        } else {
            return 0;
        }

    }

    function release() public {

        int8 unreleasedIdx = _releasableIdx(block.timestamp);

        require(unreleasedIdx >= 0, "TokenVesting: no tokens are due");

        uint256 unreleasedAmount = _amount.mul(_percent[uint(unreleasedIdx)]).div(10000);

        _token.safeTransfer(_beneficiary, unreleasedAmount);

        _percent[uint(unreleasedIdx)] = 0;
        _released = _released.add(unreleasedAmount);

        emit TokensReleased(address(_token), unreleasedAmount);
    }

    function _releasableIdx(uint256 ts) private view returns (int8) {

        for (uint8 i = 0; i < _schedule.length; i++) {
            if (ts > _schedule[i] && _percent[i] > 0) {
                return int8(i);
            }
        }

        return -1;
    }

}
pragma solidity ^0.5.0;


contract contractSpawn{

	address public a;
	address[] public cont;
	function createContract(IERC20 _token, address _beneficiary, uint256 _amount, uint256[] calldata _schedule,
        uint256[] calldata _percent) external payable returns(address){

		a = address( new TokenVesting(_token, _beneficiary, _amount, _schedule, _percent));
		cont.push(a);
		return a;
	}
	function getContracts() external view returns (address[] memory) {

	address[] memory contracts = new address[](cont.length);
	for (uint i = 0; i < cont.length; i++) {
		contracts[i] = cont[i];
		}
	return (contracts);
	}
	function containsContract(address _cont) external view returns (bool) {

	for (uint i = 0; i < cont.length; i++) {
		if(_cont == cont[i]) return true;
		}
	return false;
	}
}
