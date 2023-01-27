

pragma solidity >=0.8.0 <0.9.0;

contract HamsterTigerHype {


    struct User {
        uint256 deposit;
        uint256 time;
        uint256 timeDeposit;
        uint256 round;
        uint idx;
    }

    mapping(address => User) users;
    address payable[] investors = new address payable[](5);
    address payable lastInvestor;
    address payable advertising;
    uint256 totalBalance;
    uint256 advertisingLast;
    uint256 lastInvest;
    uint256 withdrawSum;
    uint256 withdrawTime = 1 days;
    uint256 advertisingTime = 1 days;
    uint256 tigerGameTime = 1 hours;
    uint256 minValueInvest = 0.05 ether;
    uint256 round = 1;
    enum GameType {Hamster, Tiger}
    GameType game = GameType.Hamster;
    uint index = 0;
    uint8 investedCount = 0;
    event StartHamsterGame();
    event StartTigerGame();

    constructor() {
        advertising = payable(msg.sender);
        advertisingLast = block.timestamp;
        lastInvest = block.timestamp;
    }

    receive() external payable {
        withdrawDividends();
        if (msg.value > 0) {
            invest();
        } else {
            withdraw();
        }
    }

    function withdraw() internal {

        User storage user = users[msg.sender];
        if (user.round != round) {
            user.round = round;
            user.deposit = 0;
            user.timeDeposit = 0;
            user.time = 0;
        }
        uint256 payout = user.deposit / 5;
        uint256 period = block.timestamp - user.time;
        require(game == GameType.Hamster, "Invest only in Tiger Game");
        require(period > withdrawTime, "Very early to withdraw");
        require(payout > 0, "The deposit is empty");
        if (payable(msg.sender).send(payout)) {
            user.time = block.timestamp;
        }
        if (withdrawSum > address(this).balance && investedCount >= 5) {
            game = GameType.Tiger;
            emit StartTigerGame();
            lastInvest = block.timestamp;
        }
    }

    function invest() internal {

        uint balance = address(this).balance;
        investmentOperations();
        if (game == GameType.Hamster) { // Режим Хомяков
            if (withdrawSum > balance && investedCount >= 5) {
                game = GameType.Tiger;
                emit StartTigerGame();
            }
        } else { // Режим Тигров
            if ((withdrawSum * 2) < balance) {
                game = GameType.Hamster;
                emit StartHamsterGame();
            } else {
                if (msg.value >= minValueInvest && block.timestamp - lastInvest > tigerGameTime) {
                    multiplier();
                    game = GameType.Hamster;
                    emit StartHamsterGame();
                }
            }
        }
        if(msg.value >= minValueInvest){
            lastInvest = block.timestamp;
        }
    }

    function investmentOperations() internal {

        User storage user = users[msg.sender];
        if (user.round != round) {
            user.round = round;
            user.deposit = 0;
            user.timeDeposit = 0;
            user.time = 0;
        }
        if (lastInvestor != msg.sender) {
            if (msg.value >= minValueInvest) {
                if (investors[user.idx] != msg.sender) {
                    investedCount++;
                    uint idx = addInvestor(payable(msg.sender));
                    user.idx = idx;
                }
                lastInvestor = payable(msg.sender);
            }
        }
        user.deposit += msg.value;
        user.timeDeposit = block.timestamp;
        if(user.time == 0){
            user.time = block.timestamp;
        }

        totalBalance += msg.value / 10;
        withdrawSum += msg.value / 5;
    }

    function getIndex(uint num) internal view returns (uint){

        return (index + num) % 5;
    }

    function addInvestor(address payable investor) internal returns (uint) {

        index = getIndex(1);
        investors[index] = investor;
        return index;
    }

    function multiplier() internal {

        uint256 one = address(this).balance / 100;
        uint256 fifty = one * 50;
        uint256 seven = one * 7;
        address payable[] memory sorted = sort();
        for (uint256 i = 0; i < 5; i++) {
            address payable to = sorted[i];
            if (i == 0) {
                to.transfer(fifty);
            } else if (i >= 1 && i <= 4) {
                to.transfer(seven);
            }
        }
        advertising.transfer(one * 22);
        investors = new address payable[](5);
        lastInvestor = payable(this);
        withdrawSum = 0;
        totalBalance = 0;
        investedCount = 0;
        round++;
    }

    function withdrawDividends() internal {

        if (totalBalance > 0 && address(this).balance > totalBalance && block.timestamp - advertisingLast > advertisingTime) {
            advertising.transfer(totalBalance);
            totalBalance = 0;
            advertisingLast = block.timestamp;
        }
    }

    function sort() internal view returns (address payable[] memory) {

        address payable[] memory sorting = investors;
        uint256 l = 5;
        for(uint i = 0; i < l; i++) {
            for(uint j = i+1; j < l ;j++) {
                uint us1 = 0;
                uint us2 = 0;
                if(investors[i] != address(0)){
                    us1 = users[sorting[i]].timeDeposit;
                }
                if(investors[j] != address(0)){
                    us2 = users[sorting[j]].timeDeposit;
                }
                if(us1 < us2) {
                    address payable temp = sorting[i];
                    sorting[i] = sorting[j];
                    sorting[j] = temp;
                }
            }
        }
        return sorting;
    }

    function getInvestors() public view returns (address payable [] memory) {

        return investors;
    }

    function getDeposit(address _address) public view returns (uint256) {

        return users[_address].round != round ? 0 : users[_address].deposit;
    }

    function getWithdrawSum() public view returns (uint256) {

        return withdrawSum;
    }

    function getRound() public view returns (uint256) {

        return round;
    }

    function getLastInvestor() public view returns (address payable) {

        return lastInvestor;
    }

    function getBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function getGame() public view returns (GameType) {

        return game;
    }
}
