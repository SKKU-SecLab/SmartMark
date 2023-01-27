
pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.6.0;


contract FattTimelock is Ownable {



    IERC20 private _token;

	
	uint256 private _released;
	uint256 private _startTime;


    constructor (IERC20 token, address beneficiary) public {
        _token = token;
		transferOwnership(beneficiary);
		_startTime = block.timestamp;
    }

    function token() public view returns (IERC20) {

        return _token;
    }

	function released() public view returns (uint256) {

		return _released;
	}
	
	function tokenBalance() public view returns (uint256) {

		return _token.balanceOf(address(this));
	}
	
	function releasable() public view returns (uint256) {

		uint16[37] memory locked = [0,1500,1792,2084,2376,2668,2960,3252,3544,3836,4128,4420,4712,6042,7084,8126,9168,10210,11252,12294,13336,14378,15420,16462,17504,18546,19588,20630,21672,22714,23756,24798,25840,26882,27924,28966,30000];
		uint256 month = (block.timestamp - _startTime) / 30 days;
		if (month > 36) month = 36;
		uint256 releasableAmount = uint256(locked[month]) * 10 ** 23;
		return (releasableAmount);
	}
	
    function release() public virtual onlyOwner {

	
		uint256 releasableAmount = releasable();

		if (releasableAmount > _released) {
		
			uint256 releaseAmount = releasableAmount - _released;
			require(releaseAmount <= _token.balanceOf(address(this)), "TokenTimelock: no tokens to release");
			_released = _released + releaseAmount;
			_token.transfer(owner(), releaseAmount);
		}
    }
}
