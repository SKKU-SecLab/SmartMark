
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract Presale is Ownable, ReentrancyGuard {

    address constant TOKEN_ADDRESS = 0x22c88A2824625Dc5829bDBb50F95329183a1aDC3;
    address payable constant DEV_ADDRESS = payable(0x9230c72Af8B625f66f31D0C1c1DF0917348A6d74);
    uint256 constant MIN_VALUE = 20000000000000000; // 0.02 ETH, minimum purchase (13,000 DFFX)
    bool open = true;
    receive() external payable nonReentrant {
        require(open && msg.value >= MIN_VALUE);
        uint256 amount = calculateAmount(msg.value);
		IERC20 token = IERC20(TOKEN_ADDRESS);
		bool success = token.transfer(msg.sender, amount);
		require(success);
	}

    function calculateAmount(uint256 ethSent) internal pure returns (uint256) {


        if (ethSent >= 100000000000000000) { 
            if (ethSent >= 1000000000000000000) {
                return ethSent * 1012500;
            }
            else if (ethSent >= 500000000000000000) {
               return ethSent * 877500;
            }
            else if (ethSent >= 250000000000000000) {
                return ethSent * 810000;
            }
            else { // Greater than or 0.1 ETH. 15% bonus (776,250 DFFX per ETH)
                return ethSent * 776250;
            }
        }

        return ethSent * 675000; // 675,000 DFFX Per ETH
    }

    function withdrawETH(uint256 amount) public {

        DEV_ADDRESS.transfer(amount);
    }

    function openCloseSale() public onlyOwner {

        open = !open;
    }
}