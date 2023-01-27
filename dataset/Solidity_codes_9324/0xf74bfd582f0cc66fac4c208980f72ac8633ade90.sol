
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity =0.6.11;



contract FoxDaoTokenReceiver is Ownable {


    using SafeMath for uint256;

    struct TransferInfo {
        uint256 index;
        address account;
        uint256 amount;
        uint256 eta;
    }

    uint256 public constant delay = 86400;

    bool public initialized = false;
    uint256 public index = 0;
    address public token;

    mapping(uint256 => TransferInfo) public queue;

    event TokenSet(address newToken);
    event QueueTransfer(uint256 index, address account, uint256 amount, uint256 eta);
    event ExecTransfer(uint256 index, address account, uint256 amount);
    event CancelTransfer(uint256 index, address account, uint256 amount);

    function initialize(address _token) external onlyOwner {

        require(!initialized, "FoxDaoTokenReceiver: Initialized");
        initialized = true;
        token = _token;
        emit TokenSet(_token);
    }

    function queueTransfer(address _account, uint256 _amount) external onlyOwner returns (uint256) {

        index = index + 1;
        require(IERC20(token).balanceOf(address(this)) >= _amount, "FoxDaoTokenReceiver: Insufficient token");

        uint256 eta = block.timestamp.add(delay);
        queue[index] = TransferInfo(
            index, _account, _amount, eta
        );
        emit QueueTransfer(index, _account, _amount, eta);
        return index;
    }

    function execTransfer(uint256 _index, address _account, uint256 _amount) external onlyOwner {

        require(_index <= index, "FoxDaoTokenReceiver: Invalid index");

        TransferInfo memory info = queue[_index];
        require(info.account != address(0), "FoxDaoTokenReceiver: Transaction has been executed or canceled");
        require(info.account == _account, "FoxDaoTokenReceiver: Invalid account");
        require(info.amount == _amount, "FoxDaoTokenReceiver: Invalid amount");
        require(block.timestamp >= info.eta, "FoxDaoTokenReceiver: Transaction hasn't surpassed time lock");

        IERC20(token).transfer(_account, _amount);
        delete queue[_index];

        emit ExecTransfer(_index, _account, _amount);
    }

    function cancelTransfer(uint256 _index, address _account, uint256 _amount) external onlyOwner {

        require(_index <= index, "FoxDaoTokenReceiver: Invalid index");

        TransferInfo memory info = queue[_index];
        require(info.account != address(0), "FoxDaoTokenReceiver: Transaction has been executed or canceled");
        require(info.account == _account, "FoxDaoTokenReceiver: Invalid account");
        require(info.amount == _amount, "FoxDaoTokenReceiver: Invalid amount");

        delete queue[_index];

        emit CancelTransfer(_index, _account, _amount);
    }
}