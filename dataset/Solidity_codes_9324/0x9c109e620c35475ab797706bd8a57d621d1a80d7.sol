
pragma solidity ^0.4.16;


contract ERC20 {

    function balanceOf(address tokenOwner) public constant returns (uint256 balance);

    function transfer(address to, uint256 tokens) public returns (bool success);

}


contract owned {

    function owned() public { owner = msg.sender; }

    address owner;

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
}


contract TeamTokenLock is owned {


    address _tokenAddress = 0xAF815e887b039Fc06a8ddDcC7Ec4f57757616Cd2;
    uint256 _startTime = 1534723200;  // Aug 20, 2018
    uint256 _teamTokenAmount = 1600000000e18;  // 1.6 Billion
    uint256 _totalWithdrawAmount = 0;

    function getAllowedAmountByTeam() public constant returns (uint256 amount) {

        if (now >= _startTime + (731 days)) {
            return _teamTokenAmount;
        } else if (now >= _startTime + (700 days)) {
            return _teamTokenAmount / uint(24) * 23;
        } else if (now >= _startTime + (670 days)) {
            return _teamTokenAmount / uint(24) * 22;
        } else if (now >= _startTime + (639 days)) {
            return _teamTokenAmount / uint(24) * 21;
        } else if (now >= _startTime + (609 days)) {
            return _teamTokenAmount / uint(24) * 20;
        } else if (now >= _startTime + (578 days)) {
            return _teamTokenAmount / uint(24) * 19;
        } else if (now >= _startTime + (549 days)) {
            return _teamTokenAmount / uint(24) * 18;
        } else if (now >= _startTime + (518 days)) {
            return _teamTokenAmount / uint(24) * 17;
        } else if (now >= _startTime + (487 days)) {
            return _teamTokenAmount / uint(24) * 16;
        } else if (now >= _startTime + (457 days)) {
            return _teamTokenAmount / uint(24) * 15;
        } else if (now >= _startTime + (426 days)) {
            return _teamTokenAmount / uint(24) * 14;
        } else if (now >= _startTime + (396 days)) {
            return _teamTokenAmount / uint(24) * 13;
        } else if (now >= _startTime + (365 days)) {
            return _teamTokenAmount / uint(24) * 12;
        } else if (now >= _startTime + (334 days)) {
            return _teamTokenAmount / uint(24) * 11;
        } else if (now >= _startTime + (304 days)) {
            return _teamTokenAmount / uint(24) * 10;
        } else if (now >= _startTime + (273 days)) {
            return _teamTokenAmount / uint(24) * 9;
        } else if (now >= _startTime + (243 days)) {
            return _teamTokenAmount / uint(24) * 8;
        } else if (now >= _startTime + (212 days)) {
            return _teamTokenAmount / uint(24) * 7;
        } else if (now >= _startTime + (184 days)) {
            return _teamTokenAmount / uint(24) * 6;
        } else if (now >= _startTime + (153 days)) {
            return _teamTokenAmount / uint(24) * 5;
        } else if (now >= _startTime + (122 days)) {
            return _teamTokenAmount / uint(24) * 4;
        } else if (now >= _startTime + (92 days)) {
            return _teamTokenAmount / uint(24) * 3;
        } else if (now >= _startTime + (61 days)) {
            return _teamTokenAmount / uint(24) * 2;
        } else if (now >= _startTime + (31 days)) {
            return _teamTokenAmount / uint(24);
        } else {
            return 0;
        }
    }

    function withdrawByTeam(address toAddress, uint256 amount) public onlyOwner {

        require(now >= _startTime);

        uint256 allowedAmount = getAllowedAmountByTeam();

        require(amount + _totalWithdrawAmount <= allowedAmount);

        _totalWithdrawAmount += amount;

        ERC20(_tokenAddress).transfer(toAddress, amount);
    }

    function withdrawByFoundation(address toAddress, uint256 amount) public onlyOwner {

        require(now >= _startTime + (731 days));

        ERC20(_tokenAddress).transfer(toAddress, amount);
    }
}