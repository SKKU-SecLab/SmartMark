pragma solidity >=0.7.0;

contract Authorizable {


    address public owner;
    mapping(address => bool) public authorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    function isAuthorized(address who) public view returns (bool) {

        return authorized[who];
    }

    function authorize(address who) external onlyOwner() {

        _authorize(who);
    }

    function deauthorize(address who) external onlyOwner() {

        authorized[who] = false;
    }

    function setOwner(address who) public onlyOwner() {

        owner = who;
    }

    function _authorize(address who) internal {

        authorized[who] = true;
    }
}// Apache-2.0
pragma solidity ^0.8.3;

interface IERC20 {

    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


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
}// Apache-2.0
pragma solidity ^0.8.3;



contract Spender is Authorizable {

    mapping(uint256 => uint256) public blockExpenditure;
    uint256 public smallSpendLimit;
    uint256 public mediumSpendLimit;
    uint256 public highSpendLimit;
    IERC20 public immutable token;

    constructor(
        address _owner,
        address _spender,
        IERC20 _token,
        uint256 _smallSpendLimit,
        uint256 _mediumSpendLimit,
        uint256 _highSpendLimit
    ) {
        _authorize(_spender);
        setOwner(_owner);
        token = _token;
        smallSpendLimit = _smallSpendLimit;
        mediumSpendLimit = _mediumSpendLimit;
        highSpendLimit = _highSpendLimit;
    }

    function smallSpend(uint256 amount, address destination)
        external
        onlyAuthorized
    {

        _spend(amount, destination, smallSpendLimit);
    }

    function mediumSpend(uint256 amount, address destination)
        external
        onlyAuthorized
    {

        _spend(amount, destination, mediumSpendLimit);
    }

    function highSpend(uint256 amount, address destination)
        external
        onlyAuthorized
    {

        _spend(amount, destination, highSpendLimit);
    }

    function _spend(
        uint256 amount,
        address destination,
        uint256 limit
    ) internal {

        uint256 spentThisBlock = blockExpenditure[block.number];
        require(amount + spentThisBlock <= limit, "Spend Limit Exceeded");
        blockExpenditure[block.number] = amount + spentThisBlock;
        token.transfer(destination, amount);
    }

    function setLimits(uint256[] memory limits) external onlyOwner {

        smallSpendLimit = limits[0];
        mediumSpendLimit = limits[1];
        highSpendLimit = limits[2];
    }

    function removeToken(uint256 amount, address destination)
        external
        onlyOwner
    {

        if (amount == type(uint256).max) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(destination, amount);
    }
}