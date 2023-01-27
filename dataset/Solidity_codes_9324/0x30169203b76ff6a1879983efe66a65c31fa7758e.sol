
pragma solidity ^0.4.25;



contract EternalMultiplier {


    struct Deposit {
        address depositor; // The depositor address
        uint deposit;   // The deposit amount
        uint payout; // Amount already paid
    }

    uint public roundDuration = 256;
    
    mapping (uint => Deposit[]) public queue;  // The queue
    mapping (uint => mapping (address => uint)) public depositNumber; // investor deposit index
    mapping (uint => uint) public currentReceiverIndex; // The index of the depositor in the queue
    mapping (uint => uint) public totalInvested; // Total invested amount

    address public support = msg.sender;
    mapping (uint => uint) public amountForSupport;

    function () public payable {
        require(block.number >= 6617925);
        require(block.number % roundDuration < roundDuration - 20);
        uint stage = block.number / roundDuration;

        if(msg.value > 0){

            require(gasleft() >= 250000); // We need gas to process queue
            require(msg.value >= 0.1 ether && msg.value <= calcMaxDeposit(stage)); // Too small and too big deposits are not accepted
            require(depositNumber[stage][msg.sender] == 0); // Investor should not already be in the queue

            queue[stage].push( Deposit(msg.sender, msg.value, 0) );
            depositNumber[stage][msg.sender] = queue[stage].length;

            totalInvested[stage] += msg.value;

            if (amountForSupport[stage] < 5 ether) {
                uint fee = msg.value / 5;
                amountForSupport[stage] += fee;
                support.transfer(fee);
            }

            pay(stage);

        }
    }

    function pay(uint stage) internal {


        uint money = address(this).balance;
        uint multiplier = calcMultiplier(stage);

        for (uint i = 0; i < queue[stage].length; i++){

            uint idx = currentReceiverIndex[stage] + i;  //get the index of the currently first investor

            Deposit storage dep = queue[stage][idx]; // get the info of the first investor

            uint totalPayout = dep.deposit * multiplier / 100;
            uint leftPayout;

            if (totalPayout > dep.payout) {
                leftPayout = totalPayout - dep.payout;
            }

            if (money >= leftPayout) { //If we have enough money on the contract to fully pay to investor

                if (leftPayout > 0) {
                    dep.depositor.send(leftPayout); // Send money to him
                    money -= leftPayout;
                }

                depositNumber[stage][dep.depositor] = 0;
                delete queue[stage][idx];

            } else{

                dep.depositor.send(money); // Send to him everything we have
                dep.payout += money;       // Update the payout amount
                break;                     // Exit cycle

            }

            if (gasleft() <= 55000) {         // Check the gas left. If it is low, exit the cycle
                break;                       // The next investor will process the line further
            }
        }

        currentReceiverIndex[stage] += i; //Update the index of the current first investor
    }

    function getQueueLength() public view returns (uint) {

        uint stage = block.number / roundDuration;
        return queue[stage].length - currentReceiverIndex[stage];
    }

    function calcMaxDeposit(uint stage) public view returns (uint) {


        if (totalInvested[stage] <= 20 ether) {
            return 0.5 ether;
        } else if (totalInvested[stage] <= 50 ether) {
            return 0.7 ether;
        } else if (totalInvested[stage] <= 100 ether) {
            return 1 ether;
        } else if (totalInvested[stage] <= 200 ether) {
            return 1.5 ether;
        } else {
            return 2 ether;
        }

    }

    function calcMultiplier(uint stage) public view returns (uint) {


        if (totalInvested[stage] <= 20 ether) {
            return 130;
        } else if (totalInvested[stage] <= 50 ether) {
            return 120;
        } else if (totalInvested[stage] <= 100 ether) {
            return 115;
        } else if (totalInvested[stage] <= 200 ether) {
            return 112;
        } else {
            return 110;
        }

    }

}