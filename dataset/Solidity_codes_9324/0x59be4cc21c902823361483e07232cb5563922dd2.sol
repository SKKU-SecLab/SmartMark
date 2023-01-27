

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
}

contract VestingContract is Ownable {


	using SafeMath for uint256;

	IERC20 tokenContract = IERC20(0x03042482d64577A7bdb282260e2eA4c8a89C064B);

	uint256[] vestingSchedule;
	address public receivingAddress;
	uint256 public vestingStartTime;
	uint256 constant public releaseInterval = 30 days;

	uint256 index = 0;

	constructor(address _address) public {
        receivingAddress = _address;
    }

	function updateVestingSchedule(uint256[] memory _vestingSchedule) public onlyOwner {

		require(vestingStartTime == 0);

		vestingSchedule = _vestingSchedule;
	}

	function updateReceivingAddress(address _address) public onlyOwner {

		receivingAddress = _address;
	}

	function releaseToken() public {

		require(vestingSchedule.length > 0);
		require(msg.sender == owner() || msg.sender == receivingAddress);

		if (vestingStartTime == 0) {
			require(msg.sender == owner());
			vestingStartTime = block.timestamp;
		}


		for (uint256 i = index; i < vestingSchedule.length; i++) {
			if (block.timestamp >= vestingStartTime + (index * releaseInterval)) {
				tokenContract.transfer(receivingAddress, (vestingSchedule[i] * 1 ether));

				index = index.add(1);
			} else {
				break;
			}
		}
	}

	function getVestingSchedule() public view returns (uint256[] memory) {

        return vestingSchedule;
    }
}

contract VestingContractCaller is Ownable {


	using SafeMath for uint256;

	address[] vestingContracts;

	function addVestingContract(address _address) public onlyOwner {

		vestingContracts.push(_address);
	}

	function removeVestingContract(address _address) public onlyOwner {

		for (uint256 i = 0; i < vestingContracts.length; i++) {
			if (vestingContracts[i] == _address) {
				vestingContracts[i] = vestingContracts[vestingContracts.length -1];
				vestingContracts.pop();
				break;
			}
		}
	}

	function batchReleaseTokens() public onlyOwner {

		for (uint256 i = 0; i < vestingContracts.length; i++) {
			VestingContract vContract = VestingContract(vestingContracts[i]);
			vContract.releaseToken();
		}
	}

	function transferVestingContractOwnership(address _contractAddress, address _newOwner) public onlyOwner {

    	for (uint256 i = 0; i < vestingContracts.length; i++) {
    		if (vestingContracts[i] == _contractAddress) {
    			VestingContract vContract = VestingContract(vestingContracts[i]);
    			vContract.transferOwnership(_newOwner);
    			break;
    		}
    	}
    }

	function getVestingContracts() public view returns (address[] memory) {

        return vestingContracts;
    }

}