
pragma solidity 0.4.24;


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

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Zero address received");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


interface IERC20 {

    function transfer(address _to, uint _value) external returns (bool success);

    function balanceOf(address _owner) external view returns (uint256 balance);

}


contract Airdrop is Ownable {

    using SafeMath for uint256;

    IERC20 public token;

    event Airdropped(address to, uint256 token);
    event TokenContractSet(IERC20 newToken);

    constructor (IERC20 _tokenAddr) public {
        require(address(_tokenAddr) != address(0), "Zero address received");
        token = _tokenAddr;
        emit TokenContractSet(_tokenAddr);
    }

    function drop(address[] beneficiaries, uint256[] values)
        external
        onlyOwner
        returns (bool)
    {

        require(beneficiaries.length == values.length, "Array lengths of parameters unequal");

        for (uint i = 0; i < beneficiaries.length; i++) {
            require(beneficiaries[i] != address(0), "Zero address received");
            require(getBalance() >= values[i], "Insufficient token balance");

            token.transfer(beneficiaries[i], values[i]);

            emit Airdropped(beneficiaries[i], values[i]);
        }

        return true;
    }

    function getBalance() public view returns (uint256 balance) {

        balance = token.balanceOf(address(this));
    }

    function setTokenAddress(IERC20 newToken) public onlyOwner {

        require(address(newToken) != address(0), "Zero address received");
        token = newToken;
        emit TokenContractSet(newToken);
    }

}