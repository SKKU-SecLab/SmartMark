pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity >=0.6.0 <0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity >=0.7.0 <0.8.0;



contract CosmoCupLpMinter is Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) private _totalMintedOf;
    uint256 private _totalMinted;
    address private _cosmoCupLp;

    event Mint(address indexed to, uint256 value);

    constructor() {
        _cosmoCupLp = 0x2F77258A82F7783f6D877F9D1C255f054d2618ab;
    }


    function mint(uint256 amount) public {

        address sender = _msgSender();
        IERC20(_cosmoCupLp).transferFrom(sender, address(this), amount);

        _totalMinted = _totalMinted.add(amount);
        _totalMintedOf[sender] = _totalMintedOf[sender].add(amount);
        emit Mint(sender, amount);
    }


    function cosmoCupLp() public view returns (address) {

        return _cosmoCupLp;
    }

    function totalMinted() public view returns (uint256) {

        return _totalMinted;
    }

    function totalMintedOf(address account) public view returns (uint256) {

        return _totalMintedOf[account];
    }


    function balance(address token) public view returns (uint256) {

        return IERC20(token).balanceOf(address(this));
    }

    function withdraw(address token) public onlyOwner returns (bool) {

        require(token != _cosmoCupLp, "Use withdrawUnaccounted()");
        return IERC20(token).transfer(owner(), balance(token));
    }


    function unaccounted() public view returns (uint256) {

        return balance(_cosmoCupLp).sub(_totalMinted);
    }

    function withdrawUnaccounted() public onlyOwner returns (bool) {

        return IERC20(_cosmoCupLp).transfer(owner(), unaccounted());
    }
}
