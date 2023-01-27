

pragma solidity 0.8.2;

abstract contract IERC20 {
    function balanceOf(address _owner)
        external
        virtual
        returns (uint256 balance);

    function transfer(address _to, uint256 _value) external virtual;
}

contract UniqlyPresale4 {

    uint256 public immutable presaleLimit;

    uint256 public immutable minPerUser;

    uint256 public immutable maxPerUser;

    uint256 public immutable presaleEnd;

    uint256 constant failSafeTime = 2 weeks;

    address public owner;

    constructor(
        uint256 _presaleLimit, //maximum amount to be collected
        uint256 _minPerUser, //minimum buy-in per user
        uint256 _maxPerUser, //maximum buy-in per user
        uint256 _presaleEnd, //unix timestamp of presale round end
        address _owner //privileged address
    ) {
        presaleLimit = _presaleLimit;
        minPerUser = _minPerUser;
        maxPerUser = _maxPerUser;
        presaleEnd = _presaleEnd;
        owner = _owner;
    }

    bool presaleEnded;
    bool presaleFailed;
    bool presaleStarted;

    mapping(address => uint256) private balances;

    receive() external payable {
        require(presaleStarted, "Presale not started");
        require(!presaleEnded, "Presale ended");
        require(block.timestamp < presaleEnd, "Presale time's up");

        uint256 amount = msg.value + balances[msg.sender];
        require(amount >= minPerUser, "Below buy-in");
        require(amount <= maxPerUser, "Over buy-in");
        balances[msg.sender] = amount;

        if (collected() >= presaleLimit) {
            presaleEnded = true;
        }
    }

    function start() external {

        require(msg.sender == owner, "Only for Owner");
        presaleStarted = true;
    }

    function balanceOf(address user) external view returns (uint256) {

        return balances[user];
    }

    function balanceOf() external view returns (uint256) {

        return balances[msg.sender];
    }

    function collected() public view returns (uint256) {

        return address(this).balance;
    }

    function withdraw() external returns (bool) {

        if (!presaleEnded) {
            if (block.timestamp > presaleEnd + failSafeTime) {
                presaleEnded = true;
                presaleFailed = true;
            }
        }
        else if (msg.sender == owner && !presaleFailed) {
            send(owner, address(this).balance);
            return true;
        }

        if (presaleFailed) {
            uint256 amount = balances[msg.sender];
            balances[msg.sender] = 0;
            send(msg.sender, amount);
            return true;
        }

        return false;
    }

    function send(address user, uint256 amount) private {

        bool success = false;
        (success, ) = address(user).call{value: amount}("");
        require(success, "ETH send failed");
    }

    function withdrawAnyERC20(IERC20 token) external {

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "No tokens to withdraw");
        token.transfer(owner, amount);
    }

    address public newOwner;

    function giveOwnership(address _newOwner) external {

        require(msg.sender == owner, "Only for Owner");
        newOwner = _newOwner;
    }

    function acceptOwnership() external {

        require(msg.sender == newOwner, "Ure not New Owner");
        newOwner = address(0x0);
        owner = msg.sender;
    }
}