
pragma solidity ^0.4.25;


contract Multipliers {

    uint constant public TECH_PERCENT = 5;
    uint constant public PROMO_PERCENT = 5;
    uint constant public PRIZE_PERCENT = 5;
    uint constant public MAX_INVESTMENT = 10 ether;
    uint constant public MIN_INVESTMENT_FOR_PRIZE = 0.03 ether; //Increases by this value per hour since start
    uint constant public MAX_IDLE_TIME = 30 minutes; //Maximum time the deposit should remain the last to receive prize
    uint constant public MAX_SET_TIME_RANGE = 1 weeks; //Do not allow to set start time beyond week from the current time

    uint8[] MULTIPLIERS = [
        111, //For first deposit made at this stage
        113, //For second
        117, //For third
        121, //For forth
        125, //For fifth
        130, //For sixth
        135, //For seventh
        141  //For eighth and on
    ];

    struct Deposit {
        address depositor; //The depositor address
        uint128 deposit;   //The deposit amount
        uint128 expect;    //How much we should pay out (initially it is 111%-141% of deposit)
    }

    struct DepositCount {
        int128 stage;
        uint128 count;
    }

    struct LastDepositInfo {
        uint128 index;
        uint128 time;
    }

    Deposit[] private queue;  //The queue
    address private tech;
    address private promo;

    uint public currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!
    uint public currentQueueSize = 0; //The current size of queue (may be less than queue.length)
    LastDepositInfo public lastDepositInfo; //The time last deposit made at

    uint public prizeAmount = 0; //Prize amount accumulated for the last depositor
    uint public startTime = 0; //Next start time. 0 - inactive, <> 0 - next start time
    uint public maxGasPrice = 1 ether; //Unlimited or limited
    int public stage = 0; //Number of contract runs
    mapping(address => DepositCount) public depositsMade; //The number of deposits of different depositors

    constructor(address _tech, address _promo) public {
        queue.push(Deposit(address(0x1),0,1));
        tech = _tech;
        promo = _promo;
    }

    function () public payable {
        require(tx.gasprice <= maxGasPrice, "Gas price is too high! Do not cheat!");
        require(startTime > 0 && now >= startTime, "The race has not begun yet!");

        if(msg.value > 0 && lastDepositInfo.time > 0 && now > lastDepositInfo.time + MAX_IDLE_TIME){
            msg.sender.transfer(msg.value);
            withdrawPrize();
        }else if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
            require(msg.value <= MAX_INVESTMENT, "The investment is too much!"); //Do not allow too big investments to stabilize payouts

            addDeposit(msg.sender, msg.value);

            pay();
        }else if(msg.value == 0){
            withdrawPrize();
        }
    }

    function pay() private {

        uint balance = address(this).balance;
        uint money = 0;
        if(balance > prizeAmount) //The opposite is impossible, however the check will not do any harm
            money = balance - prizeAmount;

        for(uint i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i]; //get the info of the first investor

            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.send(dep.expect); //Send money to him
                money -= dep.expect;            //update money left

                delete queue[i];
            }else{
                dep.depositor.send(money); //Send to him everything we have
                dep.expect -= uint128(money);       //Update the expected amount
                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex = i; //Update the index of the current first investor
    }

    function addDeposit(address depositor, uint value) private {

        DepositCount storage c = depositsMade[depositor];
        if(c.stage != stage){
            c.stage = int128(stage);
            c.count = 0;
        }

        if(value >= getCurrentPrizeMinimalDeposit())
            lastDepositInfo = LastDepositInfo(uint128(currentQueueSize), uint128(now));

        uint multiplier = getDepositorMultiplier(depositor);
        push(depositor, value, value*multiplier/100);

        c.count++;

        prizeAmount += value*(PRIZE_PERCENT)/100;

        uint support = value*TECH_PERCENT/100;
        tech.send(support);
        uint adv = value*PROMO_PERCENT/100;
        promo.send(adv);

    }

    function proceedToNewStage(int _stage) private {

        stage = _stage;
        startTime = 0;
        currentQueueSize = 0; //Instead of deleting queue just reset its length (gas economy)
        currentReceiverIndex = 0;
        delete lastDepositInfo;
    }

    function withdrawPrize() private {

        require(lastDepositInfo.time > 0 && lastDepositInfo.time <= now - MAX_IDLE_TIME, "The last depositor is not confirmed yet");
        require(currentReceiverIndex <= lastDepositInfo.index, "The last depositor should still be in queue");

        uint balance = address(this).balance;
        uint prize = prizeAmount;
        if(balance > prize){
            pay();
        }
        if(balance > prize){
            return; //Funds are still not distributed, so exit
        }
        if(prize > balance) //Impossible but better check it
            prize = balance;

        queue[lastDepositInfo.index].depositor.send(prize);

        prizeAmount = 0;
        proceedToNewStage(stage + 1);
    }

    function push(address depositor, uint deposit, uint expect) private {

        Deposit memory dep = Deposit(depositor, uint128(deposit), uint128(expect));
        assert(currentQueueSize <= queue.length); //Assert queue size is not corrupted
        if(queue.length == currentQueueSize)
            queue.push(dep);
        else
            queue[currentQueueSize] = dep;

        currentQueueSize++;
    }

    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){

        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    function getCurrentPrizeMinimalDeposit() public view returns(uint) {

        uint st = startTime;
        if(st == 0 || now < st)
            return MIN_INVESTMENT_FOR_PRIZE;
        uint dep = MIN_INVESTMENT_FOR_PRIZE + ((now - st)/1 hours)*MIN_INVESTMENT_FOR_PRIZE;
        if(dep > MAX_INVESTMENT)
            dep = MAX_INVESTMENT;
        return dep;
    }

    function getDepositsCount(address depositor) public view returns (uint) {

        uint c = 0;
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {

        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }

    function getQueueLength() public view returns (uint) {

        return currentQueueSize - currentReceiverIndex;
    }

    function getDepositorMultiplier(address depositor) public view returns (uint) {

        DepositCount storage c = depositsMade[depositor];
        uint count = 0;
        if(c.stage == stage)
            count = c.count;
        if(count < MULTIPLIERS.length)
            return MULTIPLIERS[count];

        return MULTIPLIERS[MULTIPLIERS.length - 1];
    }

    function setStartTimeAndMaxGasPrice(uint time, uint _gasprice) public {

        require(startTime == 0, "You can set time only in stopped state");
        require(time >= now && time <= now + MAX_SET_TIME_RANGE, "Wrong start time");
        require(msg.sender == tech || msg.sender == promo, "You are not authorized to set start time");
        startTime = time;
        if(_gasprice > 0)
            maxGasPrice = _gasprice;
    }

    function getCurrentCandidateForPrize() public view returns (address addr, uint prize, uint timeMade, int timeLeft){

        if(currentReceiverIndex <= lastDepositInfo.index && lastDepositInfo.index < currentQueueSize){
            Deposit storage d = queue[lastDepositInfo.index];
            addr = d.depositor;
            prize = prizeAmount;
            timeMade = lastDepositInfo.time;
            timeLeft = int(timeMade + MAX_IDLE_TIME) - int(now);
        }
    }

}