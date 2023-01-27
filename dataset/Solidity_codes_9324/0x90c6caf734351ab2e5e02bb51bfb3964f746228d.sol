
pragma solidity ^0.4.25;



contract SmartEthRocket {


    uint public prizeFee = 7;
    uint public prize;
    address public lastInvestor;
    uint public lastInvestedAt;

    struct Deposit {
        address depositor; // The depositor address
        uint deposit;   // The deposit amount
        uint payout; // Amount already paid
    }

    Deposit[] public queue;  // The queue
    mapping (address => uint) public depositNumber; // investor deposit index
    uint public currentReceiverIndex; // The index of the depositor in the queue
    uint public totalInvested; // Total invested amount

    address public support = msg.sender;
    uint public amountForSupport;

    function () public payable {
        require(block.number >= 6648870);

        if(msg.value > 0){

            require(gasleft() >= 250000); // We need gas to process queue
            require(msg.value >= 0.01 ether && msg.value <= calcMaxDeposit()); // Too small and too big deposits are not accepted
            
            if (depositNumber[msg.sender] == 0) {
                queue.push( Deposit(msg.sender, msg.value, 0) );
                depositNumber[msg.sender] = queue.length;
            } else {
                queue[depositNumber[msg.sender] - 1].deposit += msg.value;
            }

            totalInvested += msg.value;

            if (amountForSupport < 5 ether) {
                uint fee = msg.value / 20;
                amountForSupport += fee;
                support.transfer(fee);
            }
            
            prize += msg.value * prizeFee / 100;
            lastInvestor = msg.sender;
            lastInvestedAt = block.number;

            pay();

        } else if (lastInvestor == msg.sender && block.number >= lastInvestedAt + 126) {
            lastInvestor.transfer(prize);
            delete prize;
            delete lastInvestor;
        } else {
            revert();
        }
    }

    function pay() internal {


        uint money = address(this).balance - prize;
        uint multiplier = calcMultiplier();

        for (uint i = 0; i < queue.length; i++){

            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor

            Deposit storage dep = queue[idx]; // get the info of the first investor

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

                depositNumber[dep.depositor] = 0;
                delete queue[idx];

            } else{

                dep.depositor.send(money); // Send to him everything we have
                dep.payout += money;       // Update the payout amount
                break;                     // Exit cycle

            }

            if (gasleft() <= 55000) {         // Check the gas left. If it is low, exit the cycle
                break;                       // The next investor will process the line further
            }
        }

        currentReceiverIndex += i; //Update the index of the current first investor
    }

    function getQueueLength() public view returns (uint) {

        return queue.length - currentReceiverIndex;
    }

    function calcMaxDeposit() public view returns (uint) {


        if (totalInvested <= 20 ether) {
            return 1 ether;
        } else if (totalInvested <= 50 ether) {
            return 1.2 ether;
        } else if (totalInvested <= 100 ether) {
            return 1.4 ether;
        } else if (totalInvested <= 200 ether) {
            return 1.7 ether;
        } else {
            return 2 ether;
        }

    }

    function calcMultiplier() public view returns (uint) {


        if (totalInvested <= 20 ether) {
            return 135;
        } else if (totalInvested <= 50 ether) {
            return 120;
        } else if (totalInvested <= 100 ether) {
            return 115;
        } else if (totalInvested <= 200 ether) {
            return 112;
        } else {
            return 110;
        }

    }

}