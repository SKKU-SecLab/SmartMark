

contract IStateSender {

  function syncState(address receiver, bytes calldata data) external;

  function register(address sender, address receiver) public;

}


pragma solidity 0.5.16;

interface ITellor {


    function beginDispute(uint256 _requestId, uint256 _timestamp, uint256 _minerIndex) external;

   
    function vote(uint256 _disputeId, bool _supportsDispute) external;


    function tallyVotes(uint256 _disputeId) external;


    function proposeFork(address _propNewTellorAddress) external;


    function addTip(uint256 _requestId, uint256 _tip) external;


    function submitMiningSolution(string calldata _nonce, uint256 _requestId, uint256 _value) external;


    function submitMiningSolution(string calldata _nonce,uint256[5] calldata _requestId, uint256[5] calldata _value) external;


    function proposeOwnership(address payable _pendingOwner) external;


    function claimOwnership() external;


    function depositStake() external;


    function requestStakingWithdraw() external;


    function withdrawStake() external;


    function approve(address _spender, uint256 _amount) external returns (bool);


    function transfer(address _to, uint256 _amount) external returns (bool);


    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);


    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function getNewCurrentVariables() external view returns(bytes32 _challenge,uint[5] memory _requestIds,uint256 _difficutly, uint256 _tip);


    function getTopRequestIDs() external view returns(uint256[5] memory _requestIds);


    function getNewVariablesOnDeck() external view returns (uint256[5] memory idsOnDeck, uint256[5] memory tipsOnDeck);


     function updateTellor(uint _disputeId) external;


    function unlockDisputeFee (uint _disputeId) external;
   
    function allowance(address _user, address _spender) external view returns (uint256);


    function allowedToTrade(address _user, uint256 _amount) external view returns (bool);


    function balanceOf(address _user) external view returns (uint256);


    function balanceOfAt(address _user, uint256 _blockNumber) external view returns (uint256);


    function didMine(bytes32 _challenge, address _miner) external view returns (bool);

   
    function didVote(uint256 _disputeId, address _address) external view returns (bool);

   
    function getAddressVars(bytes32 _data) external view returns (address);


    function getAllDisputeVars(uint256 _disputeId)
        external
        view
        returns (bytes32, bool, bool, bool, address, address, address, uint256[9] memory, int256);

   
    function getCurrentVariables() external view returns (bytes32, uint256, uint256, string memory, uint256, uint256);

   
    function getDisputeIdByDisputeHash(bytes32 _hash) external view returns (uint256);

   
    function getDisputeUintVars(uint256 _disputeId, bytes32 _data) external view returns (uint256);


    function getLastNewValue() external view returns (uint256, bool);


    function getLastNewValueById(uint256 _requestId) external view returns (uint256, bool);


    function getMinedBlockNum(uint256 _requestId, uint256 _timestamp) external view returns (uint256);


    function getMinersByRequestIdAndTimestamp(uint256 _requestId, uint256 _timestamp) external view returns (address[5] memory);


    function getNewValueCountbyRequestId(uint256 _requestId) external view returns (uint256);


    function getRequestIdByRequestQIndex(uint256 _index) external view returns (uint256);


    function getRequestIdByTimestamp(uint256 _timestamp) external view returns (uint256);


    function getRequestIdByQueryHash(bytes32 _request) external view returns (uint256);


    function getRequestQ() external view returns (uint256[51] memory);


    function getRequestUintVars(uint256 _requestId, bytes32 _data) external view returns (uint256);


    function getRequestVars(uint256 _requestId) external view returns (string memory, string memory, bytes32, uint256, uint256, uint256);


    function getStakerInfo(address _staker) external view returns (uint256, uint256);


    function getSubmissionsByTimestamp(uint256 _requestId, uint256 _timestamp) external view returns (uint256[5] memory);


    function getTimestampbyRequestIDandIndex(uint256 _requestID, uint256 _index) external view returns (uint256);


    function getUintVar(bytes32 _data) external view returns (uint256);


    function getVariablesOnDeck() external view returns (uint256, uint256, string memory);


    function isInDispute(uint256 _requestId, uint256 _timestamp) external view returns (bool);


    function retrieveData(uint256 _requestId, uint256 _timestamp) external view returns (uint256);


    function totalSupply() external view returns (uint256);

}




contract UsingTellor{

    ITellor tellor;
    constructor(address payable _tellor) public {
        tellor = ITellor(_tellor);
    }

    function retrieveData(uint256 _requestId, uint256 _timestamp) public view returns(uint256){

        return tellor.retrieveData(_requestId,_timestamp);
    }

    function isInDispute(uint256 _requestId, uint256 _timestamp) public view returns(bool){

        return tellor.isInDispute(_requestId, _timestamp);
    }

    function getNewValueCountbyRequestId(uint256 _requestId) public view returns(uint) {

        return tellor.getNewValueCountbyRequestId(_requestId);
    }

    function getTimestampbyRequestIDandIndex(uint256 _requestId, uint256 _index) public view returns(uint256) {

        return tellor.getTimestampbyRequestIDandIndex( _requestId,_index);
    }

    function getCurrentValue(uint256 _requestId) public view returns (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) {

        uint256 _count = tellor.getNewValueCountbyRequestId(_requestId);
        uint _time = tellor.getTimestampbyRequestIDandIndex(_requestId, _count - 1);
        uint _value = tellor.retrieveData(_requestId, _time);
        if(_value > 0) return (true, _value, _time);
        return (false, 0 , _time);
    }
   
    function getIndexForDataBefore(uint _requestId, uint256 _timestamp) public view returns (bool found, uint256 index){

        uint256 _count = tellor.getNewValueCountbyRequestId(_requestId);  
        if (_count > 0) {
            uint middle;
            uint start = 0;
            uint end = _count - 1;
            uint _time;

            _time = tellor.getTimestampbyRequestIDandIndex(_requestId, start);
            if(_time >= _timestamp) return (false, 0);
            _time = tellor.getTimestampbyRequestIDandIndex(_requestId, end);
            if(_time < _timestamp) return (true, end);

            while(true) {
                middle = (end - start) / 2 + 1 + start;
                _time = tellor.getTimestampbyRequestIDandIndex(_requestId, middle);
                if(_time < _timestamp){
                    uint _nextTime = tellor.getTimestampbyRequestIDandIndex(_requestId, middle + 1);
                    if(_nextTime >= _timestamp){
                        return (true, middle);
                    } else  {
                        start = middle + 1;
                    }
                } else {
                    uint _prevTime = tellor.getTimestampbyRequestIDandIndex(_requestId, middle - 1);
                    if(_prevTime < _timestamp){
                        return(true, middle - 1);
                    } else {
                        end = middle -1;
                    }
                }
            }
        }
        return (false, 0);
    }


    function getDataBefore(uint256 _requestId, uint256 _timestamp)
        public
        returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
    {

       
        (bool _found, uint _index) = getIndexForDataBefore(_requestId,_timestamp);
        if(!_found) return (false, 0, 0);
        uint256 _time = tellor.getTimestampbyRequestIDandIndex(_requestId, _index);
        _value = tellor.retrieveData(_requestId, _time);
        if (_value > 0) return (true, _value, _time);
        return (false, 0, 0);
    }
}



pragma solidity ^0.5.11;




contract TellorSender is UsingTellor {

    IStateSender public stateSender;
    event DataSent(uint _requestId, uint _timestamp, uint _value, address _sender);    
    address public receiver;

    constructor(address payable _tellorAddress, address _stateSender, address _receiver) UsingTellor(_tellorAddress) public {
      stateSender = IStateSender(_stateSender);
      receiver = _receiver;
    }

    function retrieveDataAndSend(uint256 _requestId, uint256 _timestamp) public {

        uint256 value = retrieveData(_requestId, _timestamp);
        require(value > 0);
        stateSender.syncState(receiver, abi.encode(_requestId, _timestamp, value, msg.sender));
        emit DataSent(_requestId, _timestamp, value, msg.sender);
    }

    function getCurrentValueAndSend(uint256 _requestId) public {

      (bool ifRetrieve, uint256 value, uint256 timestamp) = getCurrentValue(_requestId);
      require(ifRetrieve);
      stateSender.syncState(receiver, abi.encode(_requestId, timestamp, value, msg.sender));
      emit DataSent(_requestId, timestamp, value, msg.sender);
    }
}