
pragma solidity ^0.8.2;





library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ThePixelStudio {

    
    using SafeMath for uint256;
    
    enum CommissionStatus { queued, accepted, removed  }
    
    struct Commission {
        address payable recipient;
        uint bid;
        CommissionStatus status;
    }


    uint MAX_INT = uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);


    address payable public admin;
    
    mapping (uint => Commission) public commissions;
    
    uint public minBid; // the number of wei required to create a commission
    uint public newCommissionIndex; // the index of the next commission which should be created in the mapping
    bool public callStarted; // ensures no re-entrancy can occur

    modifier callNotStarted () {

      require(!callStarted);
      callStarted = true;
      _;
      callStarted = false;
    }
    
    modifier onlyAdmin {

        require(msg.sender == admin, "not an admin");
        _;
    }
    
    constructor(address payable _admin, uint _minBid) {
        admin = _admin;
        minBid = _minBid;
        newCommissionIndex = 1;
    }
    
     
    function updateAdmin (address payable _newAdmin)
    public
    callNotStarted
    onlyAdmin
    {
        admin = _newAdmin;
        emit AdminUpdated(_newAdmin);
    }
    
    function updateMinBid (uint _newMinBid)
    public
    callNotStarted
    onlyAdmin
    {
        minBid = _newMinBid;
        emit MinBidUpdated(_newMinBid);
    }
   
    function commission (string memory _id) 
    public
    callNotStarted
    payable
    {
        require(msg.value >= minBid, "bid below minimum"); // must send the proper amount of into the bid
        
        Commission storage newCommission = commissions[newCommissionIndex];
        newCommission.recipient = payable(msg.sender);
        newCommission.bid = msg.value;
        newCommission.status = CommissionStatus.queued;
              
        emit NewCommission(newCommissionIndex, _id, msg.value, msg.sender);
        
        newCommissionIndex++; // for the subsequent commission to be added into the next slot 
    }
    
    function batchCommission (string[] memory _ids, uint[] memory _bids ) 
    public
    callNotStarted
    payable
    {
        require(_ids.length == _bids.length, "arrays unequal length");
        uint sum = 0;
        
        for (uint i = 0; i < _ids.length; i++){
          require(_bids[i] >= minBid, "bid below minimum"); // must send the proper amount of into the bid
          Commission storage newCommission = commissions[newCommissionIndex];
          newCommission.recipient = payable(msg.sender);
          newCommission.bid = _bids[i];
          newCommission.status = CommissionStatus.queued;
                
          emit NewCommission(newCommissionIndex, _ids[i], _bids[i], msg.sender);
          
          newCommissionIndex++; // for the subsequent commission to be added into the next slot 
          sum += _bids[i];
        }
        
        require(msg.value == sum, "insufficient funds"); // must send the proper amount of into the bid
    }
    
    function rescindCommission (uint _commissionIndex) 
    public
    callNotStarted
    {
        require(_commissionIndex < newCommissionIndex, "commission not valid"); // must be a valid previously instantiated commission
        Commission storage selectedCommission = commissions[_commissionIndex];
        require(msg.sender == selectedCommission.recipient, "commission not yours"); // may only be performed by the person who commissioned it
        require(selectedCommission.status == CommissionStatus.queued, "commission not in queue"); // the commission must still be queued
      
        selectedCommission.status = CommissionStatus.removed;
        selectedCommission.recipient.transfer(selectedCommission.bid);
        
        emit CommissionRescinded(_commissionIndex);
    }
    
    function increaseCommissionBid (uint _commissionIndex)
    public
    payable
    callNotStarted
    {
        require(_commissionIndex < newCommissionIndex, "commission not valid"); // must be a valid previously instantiated commission
        Commission storage selectedCommission = commissions[_commissionIndex];
        require(msg.sender == selectedCommission.recipient, "commission not yours"); // may only be performed by the person who commissioned it
        require(selectedCommission.status == CommissionStatus.queued, "commission not in queue"); // the commission must still be queued

        selectedCommission.bid = msg.value + selectedCommission.bid;
        
        emit CommissionBidUpdated(_commissionIndex, selectedCommission.bid);
    }
    
    function processCommissions(uint[] memory _commissionIndexes)
    public
    onlyAdmin
    callNotStarted
    {

        for (uint i = 0; i < _commissionIndexes.length; i++){
            Commission storage selectedCommission = commissions[_commissionIndexes[i]];
            
            require(selectedCommission.status == CommissionStatus.queued, "commission not in the queue"); // the queue my not be empty when processing more commissions 
            
            selectedCommission.status = CommissionStatus.accepted; // first, we change the status of the commission to accepted
            admin.transfer(selectedCommission.bid); // next we accept the payment for the commission
            
            emit CommissionProcessed(_commissionIndexes[i], selectedCommission.status);
        }
    }
    
    event AdminUpdated(address _newAdmin);
    event MinBidUpdated(uint _newMinBid);
    event NewCommission(uint _commissionIndex, string _id, uint _bid, address _recipient);
    event CommissionBidUpdated(uint _commissionIndex, uint _newBid);
    event CommissionRescinded(uint _commissionIndex);
    event CommissionProcessed(uint _commissionIndex, CommissionStatus _status);
}