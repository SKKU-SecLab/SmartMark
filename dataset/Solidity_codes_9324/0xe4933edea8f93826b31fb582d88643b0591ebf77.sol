



pragma solidity ^0.4.24;

interface BuccV2 {

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

}

contract BuccaneerVIPLOCK {

    
    
    BuccV2 private buccInstance;
    
    address private v2Address = address(0xd5a7d515fb8b3337acb9b053743e0bc18f50c855);
    
    uint256 private initialLock = 84 days;
    uint256 private timeBump = 28 days;
    uint256 private timeofCreation = now;
    
    address private userWithdrawlAddress = address(0x0aD7A09575e3eC4C109c4FaA3BE7cdafc5a4aDBa);
    
    uint256 private depositSlip;
    
    bool private withdrawl1 = false;
    bool private withdrawl2 = false;
    bool private withdrawl3 = false;
    bool private withdrawl4 = false;
    
    
    bool private payment1 = false;
    bool private payment2 = false;
    bool private payment3 = false;
    bool private payment4 = false;


    function displayBalanceToShow() public view returns (uint256) {

        return depositSlip / 10000000000; 
    }
    
    
    function depositToLOCK(uint256 amountToDeposit) public returns (bool) {

        buccInstance = BuccV2(v2Address);
        depositSlip += amountToDeposit;
        return buccInstance.transferFrom(msg.sender, address(this), amountToDeposit);
    }
    
    
    function returnTimeofCreation() public view returns (uint256) {

        return timeofCreation;
    }
    
    
    function returnTimeNow() public view returns (uint256) {

        return now;
    }
    
    
    function lookUpPaymentBool(uint256 lookupPayment) public view returns (bool) {

        if (lookupPayment == 1) {
            return payment1;
        } else if (lookupPayment == 2) {
            return payment2;
        } else if (lookupPayment == 3) {
            return payment3;
        } else if (lookupPayment == 4) {
            return payment4;
        }
    }
    
    
    function VIEWisUnlocked(uint256 lookupPayment) public view returns (bool) {

        uint256 calculate = timeofCreation;
        if ((lookupPayment == 1) && (now > (calculate += initialLock))) {
            return true;
        }
        
        if ((lookupPayment == 2) && (now > (calculate += initialLock + timeBump))) {
            return true;
        }
        
        if ((lookupPayment == 3) && (now > (calculate += initialLock + (timeBump * 2)))) {
            return true;
        } 
        
        if ((lookupPayment == 4) && (now > (calculate += initialLock + (timeBump * 3)))) {
            return true;
        }
        return false;
    }
    
    
    
    
    function () payable external {
    if (msg.value > 0) {
        revert();
    }
    
    if (msg.sender == userWithdrawlAddress) {
        sendOut();
    } else {
        revert();
    }
    }
    
    
    
    function isUnlocked() internal {

        uint256 calculate = timeofCreation;
        if (!withdrawl1 && (now > (calculate += initialLock))) {
            withdrawl1 = true;
        }
        
        if (!withdrawl2 && (now > (calculate += initialLock + timeBump))) {
            withdrawl2 = true;
        }
        
        if (!withdrawl3 && (now > (calculate += initialLock + (timeBump * 2)))) {
            withdrawl3 = true;
        } 
        
        if (!withdrawl4 && (now > (calculate += initialLock + (timeBump * 3)))) {
            withdrawl4 = true;
        }
    }
    
    
    
    function sendOut() public returns (bool) {

        isUnlocked();
        
        require (userWithdrawlAddress == msg.sender);
        
        uint256 baseAmount = 1000000000000000;
        uint256 toSendtoVIP = 0;
        
        if ((withdrawl1) && (!payment1)) {
            toSendtoVIP += baseAmount;
            payment1 = true;
        }
        
        if ((withdrawl2) && (!payment2)) {
            toSendtoVIP += baseAmount;
            payment2 = true;
        }
        
        if ((withdrawl3) && (!payment3)) {
            toSendtoVIP += baseAmount;
            payment3 = true;
        }
        
        if ((withdrawl4) && (!payment4)) {
            toSendtoVIP += baseAmount;
            payment4 = true;
        }
        
        buccInstance = BuccV2(v2Address);
        depositSlip -= toSendtoVIP;
        if (depositSlip == 0) {
            buccInstance.transfer(userWithdrawlAddress, toSendtoVIP);
            selfdestruct(this);
            return true;
        } else {
            return buccInstance.transfer(userWithdrawlAddress, toSendtoVIP);
        }
    }
}



                                                                                                                                                                                               
