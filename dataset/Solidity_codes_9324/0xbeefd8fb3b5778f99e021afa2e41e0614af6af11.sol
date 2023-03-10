
pragma solidity ^0.4.23;

contract EtherSmart {


    mapping (address => uint256) public invested;
    mapping (address => uint256) public atBlock;
    address techSupport = 0x88507e53d2D5348AbD5155E47EF694ACf4b140D0;
    uint techSupportPercent = 2;
    address advertising = 0x8464E6613F87Fa5F744Ebfc0db4B9C7Cc1f97a07;
    uint advertisingPercent = 7;
    address defaultReferrer = 0xDa35961E80f19D0e389db2674E562277CA4d31f2;
    uint refPercent = 2;
    uint refBack = 2;

    function calculateProfitPercent(uint bal) private pure returns (uint) {

        if (bal >= 1e22) { // balance >= 10000 ETH
            return 50;
        }
        if (bal >= 7e21) { // balance >= 7000 ETH
            return 47;
        }
        if (bal >= 5e21) { // balance >= 5000 ETH
            return 45;
        }
        if (bal >= 3e21) { // balance >= 3000 ETH
            return 42;
        }
        if (bal >= 1e21) { // balance >= 1000 ETH
            return 40;
        }
        if (bal >= 5e20) { // balance >= 500 ETH
            return 35;
        }
        if (bal >= 2e20) { // balance >= 200 ETH
            return 30;
        }
        if (bal >= 1e20) { // balance >= 100 ETH
            return 27;
        } else {
            return 25;
        }
    }

    function transferDefaultPercentsOfInvested(uint value) private {

        techSupport.transfer(value * techSupportPercent / 100);
        advertising.transfer(value * advertisingPercent / 100);
    }

    function bytesToAddress(bytes bys) private pure returns (address addr) {

        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function transferRefPercents(uint value, address sender) private {

        if (msg.data.length != 0) {
            address referrer = bytesToAddress(msg.data);
            if(referrer != sender) {
                sender.transfer(value * refBack / 100);
                referrer.transfer(value * refPercent / 100);
            } else {
                defaultReferrer.transfer(value * refPercent / 100);
            }
        } else {
            defaultReferrer.transfer(value * refPercent / 100);
        }
    }

    function () external payable {
        if (invested[msg.sender] != 0) {
            
            uint thisBalance = address(this).balance;
            uint amount = invested[msg.sender] * calculateProfitPercent(thisBalance) / 1000 * (block.number - atBlock[msg.sender]) / 6100;

            address sender = msg.sender;
            sender.transfer(amount);
        }
        if (msg.value > 0) {
            transferDefaultPercentsOfInvested(msg.value);
            transferRefPercents(msg.value, msg.sender);
        }
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += (msg.value);
    }
}