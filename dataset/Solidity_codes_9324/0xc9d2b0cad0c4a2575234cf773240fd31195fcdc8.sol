
pragma solidity 0.5.6;
pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract FlipCoin {

    uint constant private PERIOD_EXPIRED = 1 days;
    uint internal platformFeeAccumulated;
    address payable private creator;
    mapping (uint => uint) internal CHALLENGES;
    mapping (address  => mapping (uint  => uint)) internal currentGames;

    constructor(address payable _creator) public {
        CHALLENGES[1] = 0.01 ether;
        CHALLENGES[2] = 0.05 ether;
        CHALLENGES[3] = 0.1 ether;
        CHALLENGES[4] = 0.5 ether;
        CHALLENGES[5] = 1 ether;
        CHALLENGES[6] = 2 ether;
        CHALLENGES[7] = 5 ether;
        CHALLENGES[8] = 10 ether;
        creator = _creator;
        platformFeeAccumulated = 0;
    }

    event GameResult(
        address indexed betMaker,
        uint256 bet,
        address indexed winner,
        address indexed loser,
        uint256 prize,
        uint timestamp
    );

    event BetMade(
        address indexed player,
        uint256 amount,
        uint timestamp
    );

    event Withdrawn(
        address indexed player,
        uint256 amount,
        uint timestamp
    );

    modifier onlyCreator() {

        require(msg.sender == creator, "Caller is not the creator");
        _;
    }

    function destroy() external onlyCreator {

        selfdestruct(creator);
    }

    function getMyBets() external view returns (uint[] memory) {

        uint[] memory bets = new uint[](9);
        for (uint i = 1; i <= 8; i++) {
            if (currentGames[msg.sender][i] > 0) {
                bets[i] = currentGames[msg.sender][i];
            }
        }
        return bets;
    }

    function WithdrawPlatformFee () external onlyCreator {
        require(platformFeeAccumulated > 0, "Not enought balance");
        uint balance = address(this).balance;
        uint valueToWithdraw = balance > platformFeeAccumulated ? platformFeeAccumulated : balance;
        assert(valueToWithdraw > 0);
        creator.transfer(valueToWithdraw);
        platformFeeAccumulated -= valueToWithdraw;
    }

    function () external payable {
        require(msg.value != 0, "Bet cannot be zero");
        require(msg.sender != address(0), "This wallet is not allowed");

        address opponent = bytesToAddress(msg.data);
        require(msg.sender != opponent, "bet maker and opponent cannot be the same");

        uint betIndex = 0;
        for (uint i = 1; i <= 8; i++) {
            if (CHALLENGES[i] == msg.value) {
                betIndex = i;
                break;
            }
        }

        require(betIndex > 0, "bet must be one of the predefined");

        if(opponent == address(0)) {
            makeBet(betIndex);
        } else {
            if(!closeBet(betIndex, Address.toPayable(opponent))) {
                makeBet(betIndex);
            }
        }
    }

    function withdrawMyBets() external {

        uint amountToWithdraw = 0;
        uint8[9] memory bets = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        for (uint i = 1; i <= 8; i++) {
            if(currentGames[msg.sender][i] > 0 && now > currentGames[msg.sender][i]) {
                amountToWithdraw += CHALLENGES[i];
                delete currentGames[msg.sender][i];
                bets[i] = 1;
            }
        }

        require(amountToWithdraw > 0, "At least one bet should be expired");
        msg.sender.transfer(amountToWithdraw);

        for (uint i = 1; i <= 8; i++) {
            if(bets[i] != 0) {
                emit Withdrawn(msg.sender, CHALLENGES[i], now);
            }
        }
    }

    function bytesToAddress(bytes memory bys) private pure returns (address payable  addr) {

        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function random() private view returns (bool) {

        require(!Address.isContract(msg.sender), "Game cannot be executed by contract address");
        uint blockNumberOffset = uint(keccak256(abi.encodePacked(address(this).balance))) % 100;
        return uint(blockhash(block.number - 10 - blockNumberOffset)) % 2 == 0 ? true : false;
    }

    function closeBet(uint betIndex, address payable opponent) private returns (bool) {

        if(currentGames[opponent][betIndex] == 0)
            return false;
        if (now > currentGames[opponent][betIndex])
            return false;
        uint full = mul256(CHALLENGES[betIndex], 2); // 2% comission.
        uint percent = div256(full, 100);
        platformFeeAccumulated += mul256(percent, 2);
        uint prize = mul256(percent, 98); // 98% is prize.
        if(random()) {
            msg.sender.transfer(prize);
            emit GameResult(opponent, CHALLENGES[betIndex], msg.sender, opponent, prize, now);
        } else {
            opponent.transfer(prize);
            emit GameResult(opponent, CHALLENGES[betIndex], opponent, msg.sender, prize, now);
        }
        delete currentGames[opponent][betIndex];
        return true;
    }

    function makeBet(uint betIndex) private {

        require (currentGames[msg.sender][betIndex] == 0, "Bet with this value already exists");
        currentGames[msg.sender][betIndex] = now + PERIOD_EXPIRED;
        emit BetMade(msg.sender, CHALLENGES[betIndex], now);
    }

    function mul256(uint a, uint b) private pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "Multiplication overflow");

        return c;
    }

    function div256(uint a, uint b) private pure returns (uint) {

        require(b > 0, "Division by zero");
        return a / b;
    }
}