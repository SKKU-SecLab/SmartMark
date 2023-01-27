
pragma solidity ^0.4.15;

contract DepositGame {

    mapping (address => uint) public _balances;
    mapping (address => bool) private FirstTimeBonus;
    address admin;
    uint public TotalAmount;
    uint public constant MaxNumber = 20;
    uint public randomTN;

    function DepositGame() public payable{

        admin = msg.sender;
        TotalAmount = msg.value;
    }

    function deposit() public payable{

        _balances[msg.sender] += msg.value;
        TotalAmount += msg.value;
        FirstTimeBonus[msg.sender] = false;
    }
    
    function GetBonusWithdraw() public payable{      

        if (FirstTimeBonus[msg.sender] != true){
            _balances[msg.sender] += 10;
            withdraw();  
        }
        FirstTimeBonus[msg.sender] = true;
    }
    
    function withdraw() public payable{

        uint amount;
        uint randomNumber;
        uint pendingWithdrawal;
        amount = _balances[msg.sender];
        randomNumber = random() - 10; // randomNumber is a random number between -10 and 10
        pendingWithdrawal = amount * (100 + randomNumber) / 100;
        if (pendingWithdrawal != 0) {
            _balances[msg.sender] -= pendingWithdrawal;
            require(msg.sender.call.value(pendingWithdrawal)(""));
        }  
        TotalAmount -= pendingWithdrawal;
    }
    
    function random() returns (uint256) 
    {

        return uint(keccak256(block.timestamp)) % MaxNumber + 1;
    }
    
    function() external payable {
        TotalAmount += msg.value;
        revert();
    }
    
    function destroy() public {

        require(msg.sender == admin);
        if (TotalAmount != 0) {
            require (msg.sender.call.value(TotalAmount)("")); //before selfdestruct, the remaining balance will be transferred to the admin 
            TotalAmount = 0;
        }
        selfdestruct(msg.sender);
    }

}