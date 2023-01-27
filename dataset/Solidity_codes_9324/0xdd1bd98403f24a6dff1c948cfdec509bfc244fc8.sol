
pragma solidity ^0.4.21;


contract PHXReceivingContract {

    function tokenFallback(address _from, uint _value, bytes _data) public;

}

contract PHXInterface {

    function balanceOf(address who) public view returns (uint);

    function transfer(address _to, uint _value) public returns (bool);

    function transfer(address _to, uint _value, bytes _data) public returns (bool);

}

contract usingDSSafeAddSub {

    function safeToAdd(uint a, uint b) internal pure returns (bool) {

        return (a + b >= a);
    }
    function safeAdd(uint a, uint b) internal pure returns (uint) {

        require(safeToAdd(a, b));
        return a + b;
    }

    function safeToSubtract(uint a, uint b) pure internal returns (bool) {

        return (b <= a);
    }

    function safeSub(uint a, uint b) pure internal returns (uint) {

        require(safeToSubtract(a, b));
        return a - b;
    } 

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);
    }

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }
}

contract PHXroll is PHXReceivingContract, usingDSSafeAddSub {

    
    modifier betIsValid(uint _betSize, uint _playerNumber) {      

        require(((((_betSize * (100-(safeSub(_playerNumber,1)))) / (safeSub(_playerNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize < maxProfit && _betSize > minBet && _playerNumber > minNumber && _playerNumber < maxNumber);        
		_;
    }

    modifier gameIsActive {

        require(gamePaused == false);
		_;
    }    

    modifier payoutsAreActive {

        require(payoutsPaused == false);
		_;
    }    

    modifier onlyOwner {

         require(msg.sender == owner);
         _;
    }

    modifier onlyTreasury {

         require(msg.sender == treasury);
         _;
    }    

    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;    
    uint constant public maxNumber = 99; 
    uint constant public minNumber = 2;
	bool public gamePaused;
    address public owner;
    bool public payoutsPaused; 
    address public treasury;
    uint public contractBalance;
    uint public houseEdge;     
    uint public maxProfit;   
    uint public maxProfitAsPercentOfHouse;                    
    uint public minBet; 
    int public totalBets = 0;
    uint public totalTRsWon = 0;
    uint public totalTRsWagered = 0;    

    uint public rngId;
    mapping (uint => address) playerAddress;
    mapping (uint => uint) playerBetId;
    mapping (uint => uint) playerBetValue;
    mapping (uint => uint) playerDieResult;
    mapping (uint => uint) playerNumber;
    mapping (uint => uint) playerProfit;

    event LogBet(uint indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);      
	event LogResult(uint indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint Value, int Status);   
    event LogRefund(uint indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               

    address public constant PHXTKNADDR = 0x14b759A158879B133710f4059d32565b4a66140C;
    PHXInterface public PHXTKN;

    function PHXroll() public {

        owner = msg.sender;
        treasury = msg.sender;
        PHXTKN = PHXInterface(PHXTKNADDR); 
        ownerSetHouseEdge(990);
        ownerSetMaxProfitAsPercentOfHouse(10000);
        ownerSetMinBet(100000000000000000);        
    }

    function _pRand(uint _modulo) internal view returns (uint) {

        require((1 < _modulo) && (_modulo <= 1000));
        uint seed1 = uint(block.coinbase); // Get Miner's Address
        uint seed2 = now; // Get the timestamp
        return uint(keccak256(seed1, seed2)) % _modulo;
    }

    function _playerRollDice(uint _rollUnder, TKN _tkn) private 
        gameIsActive
        betIsValid(_tkn.value, _rollUnder)
	{

    	require(_humanSender(_tkn.sender)); // Check that this is a non-contract sender
    	require(_phxToken(msg.sender)); // Check that this is a PHX Token Transfer
	    
	    rngId++;
	    
		playerBetId[rngId] = rngId;
		playerNumber[rngId] = _rollUnder;
        playerBetValue[rngId] = _tkn.value;
        playerAddress[rngId] = _tkn.sender;
        playerProfit[rngId] = 0; 
  
        emit LogBet(playerBetId[rngId], playerAddress[rngId], safeAdd(playerBetValue[rngId], playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId]);       
        
        playerDieResult[rngId] = _pRand(100) + 1;

        totalBets += 1;
        
        totalTRsWagered += playerBetValue[rngId];                                                           

        if(playerDieResult[rngId] < playerNumber[rngId]){ 
            playerProfit[rngId] = ((((_tkn.value * (100-(safeSub(_rollUnder,1)))) / (safeSub(_rollUnder,1))+_tkn.value))*houseEdge/houseEdgeDivisor)-_tkn.value;
            
            contractBalance = safeSub(contractBalance, playerProfit[rngId]); 

            totalTRsWon = safeAdd(totalTRsWon, playerProfit[rngId]);              

            emit LogResult(playerBetId[rngId], playerAddress[rngId], playerNumber[rngId], playerDieResult[rngId], playerProfit[rngId], 1);                            

            setMaxProfit();
            
            PHXTKN.transfer(playerAddress[rngId], playerProfit[rngId] + _tkn.value);
            
            return;
        } else {
            emit LogResult(playerBetId[rngId], playerAddress[rngId], playerNumber[rngId], playerDieResult[rngId], playerBetValue[rngId], 0);                                

            contractBalance = safeAdd(contractBalance, (playerBetValue[rngId]-1));                                                                         

            setMaxProfit(); 

            PHXTKN.transfer(playerAddress[rngId], 1);

            return;            
        }

    } 
    
    struct TKN { address sender; uint value; }
    function tokenFallback(address _from, uint _value, bytes _data) public {

        if(_from == treasury) {
            contractBalance = safeAdd(contractBalance, _value);        
            setMaxProfit();
            return;
        } else {
            TKN memory _tkn;
            _tkn.sender = _from;
            _tkn.value = _value;
            _playerRollDice(parseInt(string(_data)), _tkn);
        }
    }
            
    function setMaxProfit() internal {

        maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  
    } 

    function ownerUpdateContractBalance(uint newContractBalanceInTRs) public 
		onlyOwner
    {        

       contractBalance = newContractBalanceInTRs;
    }    

    function ownerSetHouseEdge(uint newHouseEdge) public 
		onlyOwner
    {

        houseEdge = newHouseEdge;
    }

    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 
		onlyOwner
    {

        require(newMaxProfitAsPercent <= 10000);
        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
        setMaxProfit();
    }

    function ownerSetMinBet(uint newMinimumBet) public 
		onlyOwner
    {

        minBet = newMinimumBet;
    }       

    function ownerTransferPHX(address sendTo, uint amount) public 
		onlyOwner
    {        

        contractBalance = safeSub(contractBalance, amount);		
        setMaxProfit();
        require(!PHXTKN.transfer(sendTo, amount));
        emit LogOwnerTransfer(sendTo, amount); 
    }

    function ownerPauseGame(bool newStatus) public 
		onlyOwner
    {

		gamePaused = newStatus;
    }

    function ownerPausePayouts(bool newPayoutStatus) public 
		onlyOwner
    {

		payoutsPaused = newPayoutStatus;
    } 

    function ownerSetTreasury(address newTreasury) public 
		onlyOwner
	{

        treasury = newTreasury;
    }         

    function ownerChangeOwner(address newOwner) public 
		onlyOwner
	{

        owner = newOwner;
    }

    function ownerkill() public 
		onlyOwner
	{

        PHXTKN.transfer(owner, contractBalance);
		selfdestruct(owner);
	}    

    function _phxToken(address _tokenContract) private pure returns (bool) {

        return _tokenContract == PHXTKNADDR; // Returns "true" of this is the PHX Token Contract
    }
    
    function _humanSender(address _from) private view returns (bool) {

      uint codeLength;
      assembly {
          codeLength := extcodesize(_from)
      }
      return (codeLength == 0); // If this is "true" sender is most likely a Wallet
    }

}