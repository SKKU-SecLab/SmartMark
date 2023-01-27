pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
pragma solidity ^0.5.0;


contract SnakesAndLadders {

    using SafeMath for uint;
    using SafeMath for uint8;  // 0-255

    mapping(address => uint) public balances;
    uint public totalBalance;

    address private payout1;
    address private payout2;

    uint8 constant private tiles = 100;
    mapping(uint8 => uint8) private boardElements;

    event LogGame(address sender, bool result, int balancediff, uint seed);
    event LogAddPlayerFunds(address sender, uint amount);
    event LogWithdrawPlayerFunds(address sender, uint amount);
    event LogAddFunds(address sender, uint amount);
    event LogPayout(address sender, uint amount);

    constructor(address _payout1, address _payout2) public {
        boardElements[4] = 14;
        boardElements[8] = 32;
        boardElements[20] = 38;
        boardElements[28] = 84;
        boardElements[40] = 59;
        boardElements[58] = 83;
        boardElements[72] = 93;
        boardElements[15] = 3;
        boardElements[31] = 9;
        boardElements[44] = 26;
        boardElements[62] = 19;
        boardElements[74] = 70;
        boardElements[85] = 33;
        boardElements[91] = 71;
        boardElements[98] = 80;
        payout1 = _payout1;
        payout2 = _payout2;
    }

    function () external payable {
        revert("Use addPlayerFunds to send money.");
    }

    function play(uint amount) public {

        require(amount > 0, "You must send something to bet");
        require(amount <= balances[msg.sender], "You don't have enough balance to play");
        require(amount*5 < address(this).balance - totalBalance, "You cannot bet more than 1/5 of this contract free balance");
        require(amount <= 1 ether, "Maximum bet amount is 1 ether");
        require(tx.origin == msg.sender, "Contracts cannot play the game");
        uint seed = random();
        uint turn = 0;
        bool player = false;  // true if next move is for player, false if for computer
        uint8 move = randomDice(seed, turn);  // move 0 decides who starts
        if (move == 1 || move == 2) {
            player = true;
        }
        uint8 playerUser = 0;
        uint8 playerAI = 0;
        uint8 boardElement;
        while (playerUser != tiles && playerAI != tiles) {
            turn++;
            move = randomDice(seed, turn);
            if (player) {
                playerUser = playerUser + move;
                if (playerUser > tiles) {
                    playerUser = tiles - (playerUser - tiles);
                }
                boardElement = boardElements[playerUser];
                if (boardElement != 0) {
                    playerUser = boardElement;
                }
            } else {
                playerAI = playerAI + move;
                if (playerAI > tiles) {
                    playerAI = tiles - (playerAI - tiles);
                }
                boardElement = boardElements[playerAI];
                if (boardElement != 0) {
                    playerAI = boardElement;
                }
            }
            if (move != 6) {
                player = !player;
            }
        }
        if (playerUser == tiles) {
            balances[msg.sender] += amount;
            totalBalance += amount;
            emit LogGame(msg.sender, true, int(amount), seed);
        } else {
            balances[msg.sender] -= amount;
            totalBalance -= amount;
            emit LogGame(msg.sender, false, -int(amount), seed);
        }

        if (address(this).balance - totalBalance >= 2 ether) {
            emit LogPayout(msg.sender, 0.4 ether);
            balances[payout1] += 0.2 ether;
            balances[payout2] += 0.2 ether;
            totalBalance += 0.4 ether;
        }
    }

    function random() public view returns(uint) {

        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }

    function randomDice(uint randomString, uint turn) public pure returns(uint8) {

        return uint8(randomString/2**(turn%256))%6 + 1;
    }

    function addPlayerFunds() public payable {

        require(msg.value > 0, "You must send something to add into balance");
        emit LogAddPlayerFunds(msg.sender, msg.value);
        balances[msg.sender] += msg.value;
        totalBalance += msg.value;
    }

    function withdrawPlayerFunds() public {

        uint toWithdraw = balances[msg.sender];
        require(toWithdraw > 0, "There is no balance to withdraw");
        require(toWithdraw <= totalBalance, "There are not enough funds in the contract to withdraw");
        require(tx.origin == msg.sender, "Contracts cannot withdraw funds");
        emit LogWithdrawPlayerFunds(msg.sender, toWithdraw);
        balances[msg.sender] = 0;
        totalBalance -= toWithdraw;
        msg.sender.transfer(toWithdraw);
    }

    function addFunds() public payable {

        require(msg.value > 0, "You must send something when calling this function");
        emit LogAddFunds(msg.sender, msg.value);
    }

    function payout(uint amount) public {

        require(msg.sender == payout1 || msg.sender == payout2, "You must be one a payout address");
        require(amount > 0, "The balance that you want to withdraw must be more than 0");
        require(amount%2 == 0, "Amount to withdraw must be pair");
        require(address(this).balance - totalBalance >= amount, "There is not enough free balance to withdraw");
        emit LogPayout(msg.sender, amount);
        uint half = amount/2;
        balances[payout1] += half;
        balances[payout2] += half;
        totalBalance += amount;
    }
}
