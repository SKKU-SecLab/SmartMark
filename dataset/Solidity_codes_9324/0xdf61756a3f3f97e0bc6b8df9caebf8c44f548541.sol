pragma solidity ^0.5.0;


contract EthexJackpot {

    mapping(uint256 => address payable) public tickets;
    uint256 public numberEnd;
    uint256 public firstNumber;
    uint256 public dailyAmount;
    uint256 public weeklyAmount;
    uint256 public monthlyAmount;
    uint256 public seasonalAmount;
    bool public dailyProcessed;
    bool public weeklyProcessed;
    bool public monthlyProcessed;
    bool public seasonalProcessed;
    address payable private owner;
    address public lotoAddress;
    address payable public newVersionAddress;
    EthexJackpot previousContract;
    uint256 public dailyNumberStartPrev;
    uint256 public weeklyNumberStartPrev;
    uint256 public monthlyNumberStartPrev;
    uint256 public seasonalNumberStartPrev;
    uint256 public dailyStart;
    uint256 public weeklyStart;
    uint256 public monthlyStart;
    uint256 public seasonalStart;
    uint256 public dailyEnd;
    uint256 public weeklyEnd;
    uint256 public monthlyEnd;
    uint256 public seasonalEnd;
    uint256 public dailyNumberStart;
    uint256 public weeklyNumberStart;
    uint256 public monthlyNumberStart;
    uint256 public seasonalNumberStart;
    uint256 public dailyNumberEndPrev;
    uint256 public weeklyNumberEndPrev;
    uint256 public monthlyNumberEndPrev;
    uint256 public seasonalNumberEndPrev;
    
    event Jackpot (
        uint256 number,
        uint256 count,
        uint256 amount,
        byte jackpotType
    );
    
    event Ticket (
        bytes16 indexed id,
        uint256 number
    );
    
    event SuperPrize (
        uint256 amount,
        address winner
    );
    
    uint256 constant DAILY = 5000;
    uint256 constant WEEKLY = 35000;
    uint256 constant MONTHLY = 150000;
    uint256 constant SEASONAL = 450000;
    uint256 constant PRECISION = 1 ether;
    uint256 constant DAILY_PART = 84;
    uint256 constant WEEKLY_PART = 12;
    uint256 constant MONTHLY_PART = 3;
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    function() external payable { }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    modifier onlyOwnerOrNewVersion {

        require(msg.sender == owner || msg.sender == newVersionAddress);
        _;
    }
    
    modifier onlyLoto {

        require(msg.sender == lotoAddress, "Loto only");
        _;
    }
    
    function migrate() external onlyOwnerOrNewVersion {

        newVersionAddress.transfer(address(this).balance);
    }

    function registerTicket(bytes16 id, address payable gamer) external onlyLoto {

        uint256 number = numberEnd + 1;
        if (block.number >= dailyEnd) {
            setDaily();
            dailyNumberStart = number;
        }
        else
            if (dailyNumberStart == dailyNumberStartPrev)
                dailyNumberStart = number;
        if (block.number >= weeklyEnd) {
            setWeekly();
            weeklyNumberStart = number;
        }
        else
            if (weeklyNumberStart == weeklyNumberStartPrev)
                weeklyNumberStart = number;
        if (block.number >= monthlyEnd) {
            setMonthly();
            monthlyNumberStart = number;
        }
        else
            if (monthlyNumberStart == monthlyNumberStartPrev)
                monthlyNumberStart = number;
        if (block.number >= seasonalEnd) {
            setSeasonal();
            seasonalNumberStart = number;
        }
        else
            if (seasonalNumberStart == seasonalNumberStartPrev)
                seasonalNumberStart = number;
        numberEnd = number;
        tickets[number] = gamer;
        emit Ticket(id, number);
    }
    
    function setLoto(address loto) external onlyOwner {

        lotoAddress = loto;
    }
    
    function setNewVersion(address payable newVersion) external onlyOwner {

        newVersionAddress = newVersion;
    }
    
    function payIn() external payable {

        uint256 distributedAmount = dailyAmount + weeklyAmount + monthlyAmount + seasonalAmount;
        if (distributedAmount < address(this).balance) {
            uint256 amount = (address(this).balance - distributedAmount) / 4;
            dailyAmount += amount;
            weeklyAmount += amount;
            monthlyAmount += amount;
            seasonalAmount += amount;
        }
    }
    
    function settleJackpot() external {

        if (block.number >= dailyEnd)
            setDaily();
        if (block.number >= weeklyEnd)
            setWeekly();
        if (block.number >= monthlyEnd)
            setMonthly();
        if (block.number >= seasonalEnd)
            setSeasonal();
        
        if (block.number == dailyStart || (dailyStart < block.number - 256))
            return;
        
        uint48 modulo = uint48(bytes6(blockhash(dailyStart) << 29));
        
        uint256 dailyPayAmount;
        uint256 weeklyPayAmount;
        uint256 monthlyPayAmount;
        uint256 seasonalPayAmount;
        uint256 dailyWin;
        uint256 weeklyWin;
        uint256 monthlyWin;
        uint256 seasonalWin;
        if (dailyProcessed == false) {
            dailyPayAmount = dailyAmount * PRECISION / DAILY_PART / PRECISION;
            dailyAmount -= dailyPayAmount;
            dailyProcessed = true;
            dailyWin = getNumber(dailyNumberStartPrev, dailyNumberEndPrev, modulo);
            emit Jackpot(dailyWin, dailyNumberEndPrev - dailyNumberStartPrev + 1, dailyPayAmount, 0x01);
        }
        if (weeklyProcessed == false) {
            weeklyPayAmount = weeklyAmount * PRECISION / WEEKLY_PART / PRECISION;
            weeklyAmount -= weeklyPayAmount;
            weeklyProcessed = true;
            weeklyWin = getNumber(weeklyNumberStartPrev, weeklyNumberEndPrev, modulo);
            emit Jackpot(weeklyWin, weeklyNumberEndPrev - weeklyNumberStartPrev + 1, weeklyPayAmount, 0x02);
        }
        if (monthlyProcessed == false) {
            monthlyPayAmount = monthlyAmount * PRECISION / MONTHLY_PART / PRECISION;
            monthlyAmount -= monthlyPayAmount;
            monthlyProcessed = true;
            monthlyWin = getNumber(monthlyNumberStartPrev, monthlyNumberEndPrev, modulo);
            emit Jackpot(monthlyWin, monthlyNumberEndPrev - monthlyNumberStartPrev + 1, monthlyPayAmount, 0x04);
        }
        if (seasonalProcessed == false) {
            seasonalPayAmount = seasonalAmount;
            seasonalAmount -= seasonalPayAmount;
            seasonalProcessed = true;
            seasonalWin = getNumber(seasonalNumberStartPrev, seasonalNumberEndPrev, modulo);
            emit Jackpot(seasonalWin, seasonalNumberEndPrev - seasonalNumberStartPrev + 1, seasonalPayAmount, 0x08);
        }
        if (dailyPayAmount > 0)
            getAddress(dailyWin).transfer(dailyPayAmount);
        if (weeklyPayAmount > 0)
            getAddress(weeklyWin).transfer(weeklyPayAmount);
        if (monthlyPayAmount > 0)
            getAddress(monthlyWin).transfer(monthlyPayAmount);
        if (seasonalPayAmount > 0)
            getAddress(seasonalWin).transfer(seasonalPayAmount);
    }

    function paySuperPrize(address payable winner) external onlyLoto {

        uint256 superPrizeAmount = dailyAmount + weeklyAmount + monthlyAmount + seasonalAmount;
        dailyAmount = 0;
        weeklyAmount = 0;
        monthlyAmount = 0;
        seasonalAmount = 0;
        emit SuperPrize(superPrizeAmount, winner);
        winner.transfer(superPrizeAmount);
    }
    
    function setOldVersion(address payable oldAddress) external onlyOwner {

        previousContract = EthexJackpot(oldAddress);
        dailyStart = previousContract.dailyStart();
        dailyEnd = previousContract.dailyEnd();
        dailyProcessed = previousContract.dailyProcessed();
        weeklyStart = previousContract.weeklyStart();
        weeklyEnd = previousContract.weeklyEnd();
        weeklyProcessed = previousContract.weeklyProcessed();
        monthlyStart = previousContract.monthlyStart();
        monthlyEnd = previousContract.monthlyEnd();
        monthlyProcessed = previousContract.monthlyProcessed();
        seasonalStart = previousContract.seasonalStart();
        seasonalEnd = previousContract.seasonalEnd();
        seasonalProcessed = previousContract.seasonalProcessed();
        dailyNumberStartPrev = previousContract.dailyNumberStartPrev();
        weeklyNumberStartPrev = previousContract.weeklyNumberStartPrev();
        monthlyNumberStartPrev = previousContract.monthlyNumberStartPrev();
        seasonalNumberStartPrev = previousContract.seasonalNumberStartPrev();
        dailyNumberStart = previousContract.dailyNumberStart();
        weeklyNumberStart = previousContract.weeklyNumberStart();
        monthlyNumberStart = previousContract.monthlyNumberStart();
        seasonalNumberStart = previousContract.seasonalNumberStart();
        dailyNumberEndPrev = previousContract.dailyNumberEndPrev();
        weeklyNumberEndPrev = previousContract.weeklyNumberEndPrev();
        monthlyNumberEndPrev = previousContract.monthlyNumberEndPrev();
        seasonalNumberEndPrev = previousContract.seasonalNumberEndPrev();
        numberEnd = previousContract.numberEnd();
        dailyAmount = previousContract.dailyAmount();
        weeklyAmount = previousContract.weeklyAmount();
        monthlyAmount = previousContract.monthlyAmount();
        seasonalAmount = previousContract.seasonalAmount();
        firstNumber = weeklyNumberStart;
        for (uint256 i = firstNumber; i <= numberEnd; i++)
            tickets[i] = previousContract.getAddress(i);
        previousContract.migrate();
    }
    
    function getAddress(uint256 number) public returns (address payable) {

        if (number <= firstNumber)
            return previousContract.getAddress(number);
        return tickets[number];
    }
    
    function setDaily() private {

        dailyProcessed = dailyNumberEndPrev == numberEnd;
        dailyStart = dailyEnd;
        dailyEnd = dailyStart + DAILY;
        dailyNumberStartPrev = dailyNumberStart;
        dailyNumberEndPrev = numberEnd;
    }
    
    function setWeekly() private {

        weeklyProcessed = weeklyNumberEndPrev == numberEnd;
        weeklyStart = weeklyEnd;
        weeklyEnd = weeklyStart + WEEKLY;
        weeklyNumberStartPrev = weeklyNumberStart;
        weeklyNumberEndPrev = numberEnd;
    }
    
    function setMonthly() private {

        monthlyProcessed = monthlyNumberEndPrev == numberEnd;
        monthlyStart = monthlyEnd;
        monthlyEnd = monthlyStart + MONTHLY;
        monthlyNumberStartPrev = monthlyNumberStart;
        monthlyNumberEndPrev = numberEnd;
    }
    
    function setSeasonal() private {

        seasonalProcessed = seasonalNumberEndPrev == numberEnd;
        seasonalStart = seasonalEnd;
        seasonalEnd = seasonalStart + SEASONAL;
        seasonalNumberStartPrev = seasonalNumberStart;
        seasonalNumberEndPrev = numberEnd;
    }
    
    function getNumber(uint256 startNumber, uint256 endNumber, uint48 modulo) pure private returns (uint256) {

        return startNumber + modulo % (endNumber - startNumber + 1);
    }
}pragma solidity ^0.5.0;

 
 contract EthexHouse {

     address payable private owner;
     
     constructor() public {
         owner = msg.sender;
     }
     
     modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    function payIn() external payable {

    }
    
    function withdraw() external onlyOwner {

        owner.transfer(address(this).balance);
    }
 }pragma solidity ^0.5.0;



contract EthexLoto {

    struct Bet {
        uint256 blockNumber;
        uint256 amount;
        bytes16 id;
        bytes6 bet;
        address payable gamer;
    }
    
    struct Payout {
        uint256 amount;
        bytes32 blockHash;
        bytes16 id;
        address payable gamer;
    }
    
    struct Refund {
        uint256 amount;
        bytes16 id;
        address payable gamer;
    }
    
    Bet[] betArray;
    
    address payable public jackpotAddress;
    address payable public houseAddress;
    address payable private owner;

    event Result (
        uint256 amount,
        bytes32 blockHash,
        bytes16 indexed id,
        address indexed gamer
    );
    
    event RefundBet (
        uint256 amount,
        bytes16 indexed id,
        address indexed gamer
    );
    
    uint8 constant N = 16;
    uint256 constant MIN_BET = 0.01 ether;
    uint256 constant PRECISION = 1 ether;
    uint256 constant JACKPOT_PERCENT = 10;
    uint256 constant HOUSE_EDGE = 10;
    
    constructor(address payable jackpot, address payable house) public payable {
        owner = msg.sender;
        jackpotAddress = jackpot;
        houseAddress = house;
    }
    
    function() external payable { }
    
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    function placeBet(bytes22 params) external payable {

        require(msg.value >= MIN_BET, "Bet amount should be greater or equal than minimal amount");
        require(bytes16(params) != 0, "Id should not be 0");
        
        bytes16 id = bytes16(params);
        bytes6 bet = bytes6(params << 128);
        
        uint8 markedCount = 0;
        uint256 coefficient = 0;
        for (uint8 i = 0; i < bet.length; i++) {
            if (bet[i] > 0x13)
                continue;
            markedCount++;
            if (bet[i] < 0x10) {
                coefficient += 300;
                continue;
            }
            if (bet[i] == 0x10) {
                coefficient += 50;
                continue;
            }
            if (bet[i] == 0x11) {
                coefficient += 30;
                continue;
            }
            if (bet[i] == 0x12) {
                coefficient += 60;
                continue;
            }
            if (bet[i] == 0x13) {
                coefficient += 60;
                continue;
            }
        }
        
        require(msg.value <= 180000 ether * markedCount / ((coefficient * N - 300 * markedCount) * (100 - JACKPOT_PERCENT - HOUSE_EDGE)));
        
        uint256 jackpotFee = msg.value * JACKPOT_PERCENT * PRECISION / 100 / PRECISION;
        uint256 houseEdgeFee = msg.value * HOUSE_EDGE * PRECISION / 100 / PRECISION;
        betArray.push(Bet(block.number, msg.value - jackpotFee - houseEdgeFee, id, bet, msg.sender));
        
        if (markedCount > 1)
            EthexJackpot(jackpotAddress).registerTicket(id, msg.sender);
        
        EthexJackpot(jackpotAddress).payIn.value(jackpotFee)();
        EthexHouse(houseAddress).payIn.value(houseEdgeFee)();
    }
    
    function settleBets() external {

        if (betArray.length == 0)
            return;

        Payout[] memory payouts = new Payout[](betArray.length);
        Bet[] memory missedBets = new Bet[](betArray.length);
        Refund[] memory refundedBets = new Refund[](betArray.length);
        address payable[] memory superPrizes = new address payable[](betArray.length);
        uint256 totalPayout;
        uint i = betArray.length;
        do {
            i--;
            if(betArray[i].blockNumber < block.number - 256)
                refundedBets[i] = Refund(betArray[i].amount, betArray[i].id, betArray[i].gamer);
            else {
                if(betArray[i].blockNumber >= block.number)
                    missedBets[i] = betArray[i];
                else {
                    bytes32 blockHash = blockhash(betArray[i].blockNumber);
                    uint256 coefficient = 0;
                    uint8 markedCount;
                    uint8 matchesCount;
                    bool isSuperPrize = true;
                    for (uint8 j = 0; j < betArray[i].bet.length; j++) {
                        if (betArray[i].bet[j] > 0x13) {
                            isSuperPrize = false;
                            continue;
                        }
                        markedCount++;
                        byte field;
                        if (j % 2 == 0)
                            field = blockHash[29 + j / 2] >> 4;
                        else
                            field = blockHash[29 + j / 2] & 0x0F;
                        if (betArray[i].bet[j] < 0x10) {
                            if (field == betArray[i].bet[j]) {
                                matchesCount++;
                                coefficient += 300;
                            }
                            else
                                isSuperPrize = false;
                            continue;
                        }
                        else
                            isSuperPrize = false;
                        if (betArray[i].bet[j] == 0x10) {
                            if (field > 0x09 && field < 0x10) {
                                matchesCount++;
                                coefficient += 50;
                            }
                            continue;
                        }
                        if (betArray[i].bet[j] == 0x11) {
                            if (field < 0x0A) {
                                matchesCount++;
                                coefficient += 30;
                            }
                            continue;
                        }
                        if (betArray[i].bet[j] == 0x12) {
                            if (field < 0x0A && field & 0x01 == 0x01) {
                                matchesCount++;
                                coefficient += 60;
                            }
                            continue;
                        }
                        if (betArray[i].bet[j] == 0x13) {
                            if (field < 0x0A && field & 0x01 == 0x0) {
                                matchesCount++;
                                coefficient += 60;
                            }
                            continue;
                        }
                    }
                
                    if (matchesCount == 0) 
                        coefficient = 0;
                    else                    
                        coefficient *= PRECISION * N;
                    
                    uint payoutAmount = betArray[i].amount * coefficient / (PRECISION * 300 * markedCount);
                    if (payoutAmount == 0 && matchesCount > 0)
                        payoutAmount = matchesCount;
                    payouts[i] = Payout(payoutAmount, blockHash, betArray[i].id, betArray[i].gamer);
                    totalPayout += payoutAmount;
                    if (isSuperPrize == true)
                        superPrizes[i] = betArray[i].gamer;
                }
            }
            betArray.pop();
        } while (i > 0);
        
        i = missedBets.length;
        do {
            i--;
            if (missedBets[i].id != 0)
                betArray.push(missedBets[i]);
        } while (i > 0);
        
        uint balance = address(this).balance;
        for (i = 0; i < refundedBets.length; i++)
            if (refundedBets[i].amount > 0) {
                emit RefundBet(refundedBets[i].amount, refundedBets[i].id, refundedBets[i].gamer);
                balance -= refundedBets[i].amount;
            }
        for (i = 0; i < payouts.length; i++)
            if (payouts[i].id > 0) {
                if (totalPayout > balance)
                    emit Result(balance * payouts[i].amount * PRECISION / totalPayout / PRECISION, payouts[i].blockHash, payouts[i].id, payouts[i].gamer);
                else
                    emit Result(payouts[i].amount, payouts[i].blockHash, payouts[i].id, payouts[i].gamer);
            }
        for (i = 0; i < refundedBets.length; i++)
            if (refundedBets[i].amount > 0)
                refundedBets[i].gamer.transfer(refundedBets[i].amount);
        for (i = 0; i < payouts.length; i++)
            if (payouts[i].amount > 0) {
                if (totalPayout > balance)
                    payouts[i].gamer.transfer(balance * payouts[i].amount * PRECISION / totalPayout / PRECISION);
                else
                    payouts[i].gamer.transfer(payouts[i].amount);
            }
        for (i = 0; i < superPrizes.length; i++)
            if (superPrizes[i] != address(0))
                EthexJackpot(jackpotAddress).paySuperPrize(superPrizes[i]);
    }
    
    function migrate(address payable newContract) external onlyOwner {

        newContract.transfer(address(this).balance);
    }

    function setJackpot(address payable jackpot) external onlyOwner {

        jackpotAddress = jackpot;
    }
}
