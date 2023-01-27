



pragma solidity ^0.6.0;

contract DeFiat_Gov{

    address public mastermind;
    mapping (address => uint256) private actorLevel; //governance = multi-tier level
    
    mapping (address => uint256) private override _balances; 
     mapping (address => uint256) private override _allowances; 
     
    uint256 private burnRate; // %rate of burn at each transaction
    uint256 private feeRate;  // %rate of fee taken at each transaction
    address private feeDestination; //target address for fees (to support staking contracts)

    event stdEvent(address _txOrigin, uint256 _number, bytes32 _signature, string _desc);

constructor() public {
    mastermind = msg.sender;
    actorLevel[mastermind] = 3;
    feeDestination = mastermind;
    emit stdEvent(msg.sender, 3, sha256(abi.encodePacked(mastermind)), "constructor");
}

    modifier onlyMastermind {

    require(msg.sender == mastermind, " only Mastermind");
    _;
    }
    modifier onlyGovernor {

    require(actorLevel[msg.sender] >= 2,"only Governors");
    _;
    }
    modifier onlyPartner {

    require(actorLevel[msg.sender] >= 1,"only Partners");
    _;
    }  //future use
    
    function viewActorLevelOf(address _address) public view returns (uint256) {

        return actorLevel[_address]; //address lvl (3, 2, 1 or 0)
    }  
    function viewBurnRate() public view returns (uint256)  {

        return burnRate;
    }
    function viewFeeRate() public view returns (uint256)  {

        return feeRate;
    }
    function viewFeeDestination() public view returns (address)  {

        return feeDestination;
    }
    

    function setActorLevel(address _address, uint256 _newLevel) public {

      require(_newLevel < actorLevel[msg.sender], "Can only give rights below you");
      actorLevel[_address] = _newLevel; //updates level -> adds or removes rights
      emit stdEvent(_address, _newLevel, sha256(abi.encodePacked(msg.sender, _newLevel)), "Level changed");
    }
    
    function removeAllRights(address _address) public onlyMastermind {

      require(_address != mastermind);
      actorLevel[_address] = 0; //removes all rights
      emit stdEvent(address(_address), 0, sha256(abi.encodePacked(_address)), "Rights Revoked");
    }
    function killContract() public onlyMastermind {

        selfdestruct(msg.sender); //destroys the contract if replacement needed
    } //only Mastermind can kill contract
    function setMastermind(address _mastermind) public onlyMastermind {

      mastermind = _mastermind;     //Only one mastermind
      actorLevel[_mastermind] = 3; 
      actorLevel[msg.sender] = 2;  //new level for previous mastermind
      emit stdEvent(tx.origin, 0, sha256(abi.encodePacked(_mastermind, mastermind)), "MasterMind Changed");
    }     //only Mastermind can transfer his own rights
     
    function changeBurnRate(uint _burnRate) public onlyGovernor {

      require(_burnRate <=200, "20% limit"); //cannot burn more than 20%/tx
      burnRate = _burnRate; 
      emit stdEvent(address(msg.sender), _burnRate, sha256(abi.encodePacked(msg.sender, _burnRate)), "BurnRate Changed");
    }     //only governors can change burnRate/tx
    function changeFeeRate(uint _feeRate) public onlyGovernor {

      require(_feeRate <=200, "20% limit"); //cannot take more than 20% fees/tx
      feeRate = _feeRate;
      emit stdEvent(address(msg.sender), _feeRate, sha256(abi.encodePacked(msg.sender, _feeRate)), "FeeRate Changed");
    }    //only governors can change feeRate/tx
    function setFeeDestination(address _nextDest) public onlyGovernor {

         feeDestination = _nextDest;
    }

}