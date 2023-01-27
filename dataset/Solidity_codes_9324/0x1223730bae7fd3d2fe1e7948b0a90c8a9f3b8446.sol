

pragma solidity 0.8.1;

contract BigShortBets {

    uint256 constant public minETH = 1000 ether;
    uint256 constant public noAmlMax = 9 ether;

    mapping(address => uint256) private balances;

    address constant public owner = 0x23E7f318C383a5e9af702EE11e342632006A23Cc;

    bool collectEnd = false;
    bool failed = false;

    uint256 constant public failsafe = 1629155926;

    receive() external payable {
        require(!collectEnd, "Collect ended");
        uint256 amount = msg.value + balances[msg.sender];
        require(amount <= noAmlMax, "Need KYC/AML");
        balances[msg.sender] = amount;
        if (block.timestamp > failsafe) {
            collectEnd = true;
            failed = true;
        }
    }

    function blanceOf(address user) external view returns (uint256) {

        return balances[user];
    }

    function totalCollected() public view returns (uint256) {

        return address(this).balance + address(owner).balance;
    }

    function withdraw() external {

        require(failed, "Collect not failed");
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        send(msg.sender, amount);
    }

    function end() external {

        require(!collectEnd, "Collect ended");
        collectEnd = true;
        require(msg.sender == owner, "Only for owner");
        if (totalCollected() < minETH) {
            failed = true;
        } else {
            send(owner, address(this).balance);
        }
    }

    function send(address user, uint256 amount) private {

        bool success = false;
        (success, ) = address(user).call{value: amount}("");
        require(success, "Send failed");
    }
}

