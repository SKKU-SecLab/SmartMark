
pragma solidity ^0.5.0;

library TellorTransfer {

    using SafeMath for uint256;

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);//ERC20 Approval event
    event Transfer(address indexed _from, address indexed _to, uint256 _value);//ERC20 Transfer Event


    function transfer(TellorStorage.TellorStorageStruct storage self, address _to, uint256 _amount) public returns (bool success) {

        doTransfer(self,msg.sender, _to, _amount);
        return true;
    }


    function transferFrom(TellorStorage.TellorStorageStruct storage self, address _from, address _to, uint256 _amount) public returns (bool success) {

        require(self.allowed[_from][msg.sender] >= _amount);
        self.allowed[_from][msg.sender] -= _amount;
        doTransfer(self,_from, _to, _amount);
        return true;
    }


    function approve(TellorStorage.TellorStorageStruct storage self, address _spender, uint _amount) public returns (bool) {

        require(_spender != address(0));
        self.allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }




    function doTransfer(TellorStorage.TellorStorageStruct storage self, address _from, address _to, uint _amount) public {

        require(_amount > 0);
        require(_to != address(0));
        require(allowedToTrade(self,_from,_amount)); //allowedToTrade checks the stakeAmount is removed from balance if the _user is staked
        uint previousBalance = balanceOfAt(self,_from, block.number);
        updateBalanceAtNow(self.balances[_from], previousBalance - _amount);
        previousBalance = balanceOfAt(self,_to, block.number);
        require(previousBalance + _amount >= previousBalance); // Check for overflow
        updateBalanceAtNow(self.balances[_to], previousBalance + _amount);
        emit Transfer(_from, _to, _amount);
    }


    function balanceOf(TellorStorage.TellorStorageStruct storage self,address _user) public view returns (uint) {

        return balanceOfAt(self,_user, block.number);
    }


    function balanceOfAt(TellorStorage.TellorStorageStruct storage self,address _user, uint _blockNumber) public view returns (uint) {

        if ((self.balances[_user].length == 0) || (self.balances[_user][0].fromBlock > _blockNumber)) {
                return 0;
        }
     else {
        return getBalanceAt(self.balances[_user], _blockNumber);
     }
    }


    function getBalanceAt(TellorStorage.Checkpoint[] storage checkpoints, uint _block) view public returns (uint) {

        if (checkpoints.length == 0) return 0;
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }


    function allowedToTrade(TellorStorage.TellorStorageStruct storage self,address _user,uint _amount) public view returns(bool) {

        if(self.stakerDetails[_user].currentStatus >0){
            if(balanceOf(self,_user).sub(self.uintVars[keccak256("stakeAmount")]).sub(_amount) >= 0){
                return true;
            }
        }
        else if(balanceOf(self,_user).sub(_amount) >= 0){
                return true;
        }
        return false;
    }


    function updateBalanceAtNow(TellorStorage.Checkpoint[] storage checkpoints, uint _value) public {

        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               TellorStorage.Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
        } else {
               TellorStorage.Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
        }
    }
}




library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256 c) {

        if (b > 0) {
            c = a + b;
            assert(c >= a);
        } else {
            c = a + b;
            assert(c <= a);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;
    }

    function max(int256 a, int256 b) internal pure returns (uint256) {

        return a > b ? uint256(a) : uint256(b);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256 c) {

        if (b > 0) {
            c = a - b;
            assert(c <= a);
        } else {
            c = a - b;
            assert(c >= a);
        }

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }
}



library TellorStorage {

    struct Details {
        uint value;
        address miner;
    }

    struct Dispute {
        bytes32 hash;//unique hash of dispute: keccak256(_miner,_requestId,_timestamp)
        int tally;//current tally of votes for - against measure
        bool executed;//is the dispute settled
        bool disputeVotePassed;//did the vote pass?
        bool isPropFork; //true for fork proposal NEW
        address reportedMiner; //miner who alledgedly submitted the 'bad value' will get disputeFee if dispute vote fails
        address reportingParty;//miner reporting the 'bad value'-pay disputeFee will get reportedMiner's stake if dispute vote passes
        address proposedForkAddress;//new fork address (if fork proposal)
        mapping(bytes32 => uint) disputeUintVars;
        mapping (address => bool) voted; //mapping of address to whether or not they voted
    }

    struct StakeInfo {
        uint currentStatus;//0-not Staked, 1=Staked, 2=LockedForWithdraw 3= OnDispute
        uint startDate; //stake start date
    }

    struct  Checkpoint {
        uint128 fromBlock;// fromBlock is the block number that the value was generated from
        uint128 value;// value is the amount of tokens at a specific block number
    }

    struct Request {
        string queryString;//id to string api
        string dataSymbol;//short name for api request
        bytes32 queryHash;//hash of api string and granularity e.g. keccak256(abi.encodePacked(_sapi,_granularity))
        uint[]  requestTimestamps; //array of all newValueTimestamps requested
        mapping(bytes32 => uint) apiUintVars;
        mapping(uint => uint) minedBlockNum;//[apiId][minedTimestamp]=>block.number
        mapping(uint => uint) finalValues;//This the time series of finalValues stored by the contract where uint UNIX timestamp is mapped to value
        mapping(uint => bool) inDispute;//checks if API id is in dispute or finalized.
        mapping(uint => address[5]) minersByValue;
        mapping(uint => uint[5])valuesByTimestamp;
    }

    struct TellorStorageStruct {
        bytes32 currentChallenge; //current challenge to be solved
        uint[51]  requestQ; //uint50 array of the top50 requests by payment amount
        uint[]  newValueTimestamps; //array of all timestamps requested
        Details[5]  currentMiners; //This struct is for organizing the five mined values to find the median
        mapping(bytes32 => address) addressVars;
        mapping(bytes32 => uint) uintVars;
        mapping(bytes32 => mapping(address=>bool)) minersByChallenge;//This is a boolean that tells you if a given challenge has been completed by a given miner
        mapping(uint => uint) requestIdByTimestamp;//minedTimestamp to apiId
        mapping(uint => uint) requestIdByRequestQIndex; //link from payoutPoolIndex (position in payout pool array) to apiId
        mapping(uint => Dispute) disputesById;//disputeId=> Dispute details
        mapping (address => Checkpoint[]) balances; //balances of a party given blocks
        mapping(address => mapping (address => uint)) allowed; //allowance for a given party and approver
        mapping(address => StakeInfo)  stakerDetails;//mapping from a persons address to their staking info
        mapping(uint => Request) requestDetails;//mapping of apiID to details
        mapping(bytes32 => uint) requestIdByQueryHash;// api bytes32 gets an id = to count of requests array
        mapping(bytes32 => uint) disputeIdByDisputeHash;//maps a hash to an ID for each dispute
    }
}


library Utilities{


    function getMax(uint[51] memory data) internal pure returns(uint256 max,uint256 maxIndex) {

        max = data[1];
        maxIndex;
        for(uint i=1;i < data.length;i++){
            if(data[i] > max){
                max = data[i];
                maxIndex = i;
                }
        }
    }

    function getMin(uint[51] memory data) internal pure returns(uint256 min,uint256 minIndex) {

        minIndex = data.length - 1;
        min = data[minIndex];
        for(uint i = data.length-1;i > 0;i--) {
            if(data[i] < min) {
                min = data[i];
                minIndex = i;
            }
        }
  }
}






library TellorGettersLibrary{

    using SafeMath for uint256;

    event NewTellorAddress(address _newTellor); //emmited when a proposed fork is voted true


    function changeDeity(TellorStorage.TellorStorageStruct storage self, address _newDeity) internal{

        require(self.addressVars[keccak256("_deity")] == msg.sender);
        self.addressVars[keccak256("_deity")] =_newDeity;
    }


    function changeTellorContract(TellorStorage.TellorStorageStruct storage self,address _tellorContract) internal{

        require(self.addressVars[keccak256("_deity")] == msg.sender);
        self.addressVars[keccak256("tellorContract")]= _tellorContract;
        emit NewTellorAddress(_tellorContract);
    }




























    function getNewValueCountbyRequestId(TellorStorage.TellorStorageStruct storage self, uint _requestId) internal view returns(uint){

        return self.requestDetails[_requestId].requestTimestamps.length;
    }






    function getRequestIdByQueryHash(TellorStorage.TellorStorageStruct storage self, bytes32 _queryHash) internal view returns(uint){

        return self.requestIdByQueryHash[_queryHash];
    }







    function getRequestVars(TellorStorage.TellorStorageStruct storage self,uint _requestId) internal view returns(string memory,string memory, bytes32,uint, uint, uint) {

        TellorStorage.Request storage _request = self.requestDetails[_requestId];
        return (_request.queryString,_request.dataSymbol,_request.queryHash, _request.apiUintVars[keccak256("granularity")],_request.apiUintVars[keccak256("requestQPosition")],_request.apiUintVars[keccak256("totalTip")]);
    }







    function getTimestampbyRequestIDandIndex(TellorStorage.TellorStorageStruct storage self,uint _requestID, uint _index) internal view returns(uint){

        return self.requestDetails[_requestID].requestTimestamps[_index];
    }





    function getVariablesOnDeck(TellorStorage.TellorStorageStruct storage self) internal view returns(uint, uint,string memory){

        uint newRequestId = getTopRequestID(self);
        return (newRequestId,self.requestDetails[newRequestId].apiUintVars[keccak256("totalTip")],self.requestDetails[newRequestId].queryString);
    }

    function getTopRequestID(TellorStorage.TellorStorageStruct storage self) internal view returns(uint _requestId){

            uint _max;
            uint _index;
            (_max,_index) = Utilities.getMax(self.requestQ);
             _requestId = self.requestIdByRequestQIndex[_index];
    }


    function isInDispute(TellorStorage.TellorStorageStruct storage self, uint _requestId, uint _timestamp) internal view returns(bool){

        return self.requestDetails[_requestId].inDispute[_timestamp];
    }


    function retrieveData(TellorStorage.TellorStorageStruct storage self, uint _requestId, uint _timestamp) internal view returns (uint) {

        return self.requestDetails[_requestId].finalValues[_timestamp];
    }



}

contract TellorGetters{

    using SafeMath for uint256;

    using TellorTransfer for TellorStorage.TellorStorageStruct;
    using TellorGettersLibrary for TellorStorage.TellorStorageStruct;

    TellorStorage.TellorStorageStruct tellor;




    function allowedToTrade(address _user,uint _amount) external view returns(bool){

        return tellor.allowedToTrade(_user,_amount);
    }

    function balanceOf(address _user) external view returns (uint) {

        return tellor.balanceOf(_user);
    }

    function balanceOfAt(address _user, uint _blockNumber) external view returns (uint) {

        return tellor.balanceOfAt(_user,_blockNumber);
    }

























    function getNewValueCountbyRequestId(uint _requestId) external view returns(uint){

        return tellor.getNewValueCountbyRequestId(_requestId);
    }





    function getRequestIdByQueryHash(bytes32 _request) external view returns(uint){

        return tellor.getRequestIdByQueryHash(_request);
    }






    function getRequestVars(uint _requestId) external view returns(string memory, string memory,bytes32,uint, uint, uint) {

        return tellor.getRequestVars(_requestId);
    }





    function getTimestampbyRequestIDandIndex(uint _requestID, uint _index) external view returns(uint){

        return tellor.getTimestampbyRequestIDandIndex(_requestID,_index);
    }




    function getVariablesOnDeck() external view returns(uint, uint,string memory){

        return tellor.getVariablesOnDeck();
    }


    function isInDispute(uint _requestId, uint _timestamp) external view returns(bool){

        return tellor.isInDispute(_requestId,_timestamp);
    }


    function retrieveData(uint _requestId, uint _timestamp) external view returns (uint) {

        return tellor.retrieveData(_requestId,_timestamp);
    }





}



contract TellorMaster is TellorGetters{


    event NewTellorAddress(address _newTellor);

    constructor (address _tellorContract)  public{
        init();
        tellor.addressVars[keccak256("_owner")] = msg.sender;
        tellor.addressVars[keccak256("_deity")] = msg.sender;
        tellor.addressVars[keccak256("tellorContract")]= _tellorContract;
        emit NewTellorAddress(_tellorContract);
    }

    function init() internal {

        require(tellor.uintVars[keccak256("decimals")] == 0);
        TellorTransfer.updateBalanceAtNow(tellor.balances[address(this)], 2**256-1 - 6000e18);

        address payable[6] memory _initalMiners = [address(0xE037EC8EC9ec423826750853899394dE7F024fee),
        address(0xcdd8FA31AF8475574B8909F135d510579a8087d3),
        address(0xb9dD5AfD86547Df817DA2d0Fb89334A6F8eDd891),
        address(0x230570cD052f40E14C14a81038c6f3aa685d712B),
        address(0x3233afA02644CCd048587F8ba6e99b3C00A34DcC),
        address(0xe010aC6e0248790e08F42d5F697160DEDf97E024)];
        for(uint i=0;i<6;i++){//6th miner to allow for dispute
            TellorTransfer.updateBalanceAtNow(tellor.balances[_initalMiners[i]],1000e18);

        }

        tellor.uintVars[keccak256("total_supply")] += 6000e18;//6th miner to allow for dispute
        tellor.uintVars[keccak256("decimals")] = 18;
        tellor.uintVars[keccak256("targetMiners")] = 200;
        tellor.uintVars[keccak256("stakeAmount")] = 1000e18;
        tellor.uintVars[keccak256("disputeFee")] = 970e18;
        tellor.uintVars[keccak256("timeTarget")]= 600;
        tellor.uintVars[keccak256("timeOfLastNewValue")] = now - now  % tellor.uintVars[keccak256("timeTarget")];
        tellor.uintVars[keccak256("difficulty")] = 1;
    }


    function changeDeity(address _newDeity) external{

        tellor.changeDeity(_newDeity);
    }


    function changeTellorContract(address _tellorContract) external{

        tellor.changeTellorContract(_tellorContract);
    }


    function () external payable {
        address addr = tellor.addressVars[keccak256("tellorContract")];
        bytes memory _calldata = msg.data;
        assembly {
            let result := delegatecall(not(0), addr, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}


contract OracleIDDescriptions {


    mapping(uint=>bytes32) tellorIDtoBytesID;
    mapping(bytes32 => uint) bytesIDtoTellorID;
    mapping(uint => uint) tellorCodeToStatusCode;
    mapping(uint => uint) statusCodeToTellorCode;
    mapping(uint => int) tellorIdtoAdjFactor;

    event TellorIdMappedToBytes(uint _requestID, bytes32 _id);
    event StatusMapped(uint _tellorStatus, uint _status);
    event AdjFactorMapped(uint _requestID, int _adjFactor);


    function defineTellorIdtoAdjFactor(uint _tellorId, int _adjFactor) external{

        require(tellorIdtoAdjFactor[_tellorId] == 0, "Already Set");
        tellorIdtoAdjFactor[_tellorId] = _adjFactor;
        emit AdjFactorMapped(_tellorId, _adjFactor);
    }

    function defineTellorCodeToStatusCode(uint _tellorStatus, uint _status) external{

        require(tellorCodeToStatusCode[_tellorStatus] == 0, "Already Set");
        tellorCodeToStatusCode[_tellorStatus] = _status;
        statusCodeToTellorCode[_status] = _tellorStatus;
        emit StatusMapped(_tellorStatus, _status);
    }

    function defineTellorIdToBytesID(uint _requestID, bytes32 _id) external{

        require(tellorIDtoBytesID[_requestID] == bytes32(0), "Already Set");
        tellorIDtoBytesID[_requestID] = _id;
        bytesIDtoTellorID[_id] = _requestID;
        emit TellorIdMappedToBytes(_requestID,_id);
    }

    function getTellorStatusFromStatus(uint _status) public view returns(uint _tellorStatus){

        return statusCodeToTellorCode[_status];
    }

    function getStatusFromTellorStatus (uint _tellorStatus) public view returns(uint _status) {
        return tellorCodeToStatusCode[_tellorStatus];
    }

    function getTellorIdFromBytes(bytes32 _id) public view  returns(uint _requestId)  {

       return bytesIDtoTellorID[_id];
    }

    function getGranularityAdjFactor(bytes32 _id) public view  returns(int adjFactor)  {

       uint requestID = bytesIDtoTellorID[_id];
       adjFactor = tellorIdtoAdjFactor[requestID];
       return adjFactor;
    }

    function getBytesFromTellorID(uint _requestId) public view returns(bytes32 _id) {

        return tellorIDtoBytesID[_requestId];
    }

}
pragma solidity >=0.5.0 <0.7.0;

interface EIP2362Interface{

    function valueFor(bytes32 _id) external view returns(int256,uint256,uint256);

}


contract UsingTellor is EIP2362Interface{

    address payable public tellorStorageAddress;
    address public oracleIDDescriptionsAddress;
    TellorMaster _tellorm;
    OracleIDDescriptions descriptions;

    event NewDescriptorSet(address _descriptorSet);

    constructor(address payable _storage) public {
        tellorStorageAddress = _storage;
        _tellorm = TellorMaster(tellorStorageAddress);
    }

    function setOracleIDDescriptors(address _oracleDescriptors) external {

        require(oracleIDDescriptionsAddress == address(0), "Already Set");
        oracleIDDescriptionsAddress = _oracleDescriptors;
        descriptions = OracleIDDescriptions(_oracleDescriptors);
        emit NewDescriptorSet(_oracleDescriptors);
    }

    function getCurrentValue(uint256 _requestId) public view returns (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) {

        return getDataBefore(_requestId,now,1,0);
    }

    function valueFor(bytes32 _bytesId) external view returns (int value, uint256 timestamp, uint status) {

        uint _id = descriptions.getTellorIdFromBytes(_bytesId);
        int n = descriptions.getGranularityAdjFactor(_bytesId);
        if (_id > 0){
            bool _didGet;
            uint256 _returnedValue;
            uint256 _timestampRetrieved;
            (_didGet,_returnedValue,_timestampRetrieved) = getDataBefore(_id,now,1,0);
            if(_didGet){
                return (int(_returnedValue)*n,_timestampRetrieved, descriptions.getStatusFromTellorStatus(1));
            }
            else{
                return (0,0,descriptions.getStatusFromTellorStatus(2));
            }
        }
        return (0, 0, descriptions.getStatusFromTellorStatus(0));
    }

    function getDataBefore(uint256 _requestId, uint256 _timestamp, uint256 _limit, uint256 _offset)
        public
        view
        returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
    {

        uint256 _count = _tellorm.getNewValueCountbyRequestId(_requestId) - _offset;
        if (_count > 0) {
            for (uint256 i = _count; i > _count - _limit; i--) {
                uint256 _time = _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1);
                if (_time > 0 && _time <= _timestamp && _tellorm.isInDispute(_requestId,_time) == false) {
                    return (true, _tellorm.retrieveData(_requestId, _time), _time);
                }
            }
        }
        return (false, 0, 0);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract BankStorage{

  struct Reserve {
    uint256 collateralBalance;
    uint256 debtBalance;
    uint256 interestRate;
    uint256 originationFee;
    uint256 collateralizationRatio;
    uint256 liquidationPenalty;
    address oracleContract;
    uint256 period;
  }

  struct Token {
    address tokenAddress;
    uint256 price;
    uint256 priceGranularity;
    uint256 tellorRequestId;
    uint256 reserveBalance;
  }

  struct Vault {
    uint256 collateralAmount;
    uint256 debtAmount;
    uint256 createdAt;
  }

  mapping (address => Vault) public vaults;
  Token debt;
  Token collateral;
  Reserve reserve;


  function getInterestRate() public view returns (uint256) {

    return reserve.interestRate;
  }

  function getOriginationFee() public view returns (uint256) {

    return reserve.originationFee;
  }

  function getCollateralizationRatio() public view returns (uint256) {

    return reserve.collateralizationRatio;
  }

  function getLiquidationPenalty() public view returns (uint256) {

    return reserve.liquidationPenalty;
  }

  function getDebtTokenAddress() public view returns (address) {

    return debt.tokenAddress;
  }

  function getDebtTokenPrice() public view returns (uint256) {

    return debt.price;
  }

  function getDebtTokenPriceGranularity() public view returns (uint256) {

    return debt.priceGranularity;
  }

  function getCollateralTokenAddress() public view returns (address) {

    return collateral.tokenAddress;
  }

  function getCollateralTokenPrice() public view returns (uint256) {

    return collateral.price;
  }

  function getCollateralTokenPriceGranularity() public view returns (uint256) {

    return collateral.priceGranularity;
  }

  function getReserveBalance() public view returns (uint256) {

    return reserve.debtBalance;
  }

  function getReserveCollateralBalance() public view returns (uint256) {

    return reserve.collateralBalance;
  }

  function getVaultCollateralAmount() public view returns (uint256) {

    return vaults[msg.sender].collateralAmount;
  }

  function getVaultDebtAmount() public view returns (uint256) {

    return vaults[msg.sender].debtAmount;
  }

  function getVaultRepayAmount() public view returns (uint256 principal) {

    principal = vaults[msg.sender].debtAmount;
    uint256 periodsPerYear = 365 days / reserve.period;
    uint256 periodsElapsed = (block.timestamp / reserve.period) - (vaults[msg.sender].createdAt / reserve.period);
    principal += principal * reserve.interestRate / 100 / periodsPerYear * periodsElapsed;
  }

  function getVaultCollateralizationRatio(address vaultOwner) public view returns (uint256) {

    if(vaults[vaultOwner].debtAmount == 0 ){
      return 0;
    } else {
      return _percent(vaults[vaultOwner].collateralAmount * collateral.price * 1000 / collateral.priceGranularity,
                      vaults[vaultOwner].debtAmount * debt.price * 1000 / debt.priceGranularity,
                      4);
    }
  }

  function _percent(uint numerator, uint denominator, uint precision) private pure returns(uint256 _quotient) {

        _quotient =  ((numerator * 10 ** (precision+1) / denominator) + 5) / 10;
  }


}


contract Bank is BankStorage, Ownable, UsingTellor {

  event ReserveDeposit(uint256 amount);
  event ReserveWithdraw(address token, uint256 amount);
  event VaultDeposit(address owner, uint256 amount);
  event VaultBorrow(address borrower, uint256 amount);
  event VaultRepay(address borrower, uint256 amount);
  event VaultWithdraw(address borrower, uint256 amount);
  event PriceUpdate(address token, uint256 price);
  event Liquidation(address borrower, uint256 debtAmount);

  constructor(
    uint256 interestRate,
    uint256 originationFee,
    uint256 collateralizationRatio,
    uint256 liquidationPenalty,
    uint256 period,
    address collateralToken,
    uint256 collateralTokenTellorRequestId,
    uint256 collateralTokenPriceGranularity,
    uint256 collateralTokenPrice,
    address debtToken,
    uint256 debtTokenTellorRequestId,
    uint256 debtTokenPriceGranularity,
    uint256 debtTokenPrice,
    address payable oracleContract ) public UsingTellor(oracleContract) {
    reserve.interestRate = interestRate;
    reserve.originationFee = originationFee;
    reserve.collateralizationRatio = collateralizationRatio;
    reserve.liquidationPenalty = liquidationPenalty;
    reserve.period = period;
    debt.tokenAddress = debtToken;
    debt.price = debtTokenPrice;
    debt.priceGranularity = debtTokenPriceGranularity;
    debt.tellorRequestId = debtTokenTellorRequestId;
    collateral.tokenAddress = collateralToken;
    collateral.price = collateralTokenPrice;
    collateral.priceGranularity = collateralTokenPriceGranularity;
    collateral.tellorRequestId = collateralTokenTellorRequestId;
    reserve.oracleContract = oracleContract;
  }

  function reserveDeposit(uint256 amount) external onlyOwner {

    require(IERC20(debt.tokenAddress).transferFrom(msg.sender, address(this), amount));
    reserve.debtBalance += amount;
    emit ReserveDeposit(amount);
  }

  function reserveWithdraw(uint256 amount) external onlyOwner {

    require(reserve.debtBalance >= amount, "NOT ENOUGH DEBT TOKENS IN RESERVE");
    require(IERC20(debt.tokenAddress).transfer(msg.sender, amount));
    reserve.debtBalance -= amount;
    emit ReserveWithdraw(debt.tokenAddress, amount);
  }

  function reserveWithdrawCollateral(uint256 amount) external onlyOwner {

    require(reserve.collateralBalance >= amount, "NOT ENOUGH COLLATERAL IN RESERVE");
    require(IERC20(collateral.tokenAddress).transfer(msg.sender, amount));
    reserve.collateralBalance -= amount;
    emit ReserveWithdraw(collateral.tokenAddress, amount);
  }

  function updateCollateralPrice() external {

    bool ifRetrieve;
    uint256 _timestampRetrieved;
    (ifRetrieve, collateral.price, _timestampRetrieved) = getCurrentValue(collateral.tellorRequestId); //,now - 1 hours);
    emit PriceUpdate(collateral.tokenAddress, collateral.price);
  }

  function updateDebtPrice() external {

    bool ifRetrieve;
    uint256 _timestampRetrieved;
    (ifRetrieve, debt.price, _timestampRetrieved) = getCurrentValue(debt.tellorRequestId); //,now - 1 hours);
    emit PriceUpdate(debt.tokenAddress, debt.price);
  }

  function liquidate(address vaultOwner) external {

    require(getVaultCollateralizationRatio(vaultOwner) < reserve.collateralizationRatio * 100, "VAULT NOT UNDERCOLLATERALIZED");
    uint256 debtOwned = vaults[vaultOwner].debtAmount + (vaults[vaultOwner].debtAmount * 100 * reserve.liquidationPenalty / 100 / 100);
    uint256 collateralToLiquidate = debtOwned * debt.price / collateral.price;

    if(collateralToLiquidate <= vaults[vaultOwner].collateralAmount) {
      reserve.collateralBalance +=  collateralToLiquidate;
      vaults[vaultOwner].collateralAmount -= collateralToLiquidate;
    } else {
      reserve.collateralBalance +=  vaults[vaultOwner].collateralAmount;
      vaults[vaultOwner].collateralAmount = 0;
    }
    reserve.debtBalance += vaults[vaultOwner].debtAmount;
    vaults[vaultOwner].debtAmount = 0;
    emit Liquidation(vaultOwner, debtOwned);
  }


  function vaultDeposit(uint256 amount) external {

    require(IERC20(collateral.tokenAddress).transferFrom(msg.sender, address(this), amount));
    vaults[msg.sender].collateralAmount += amount;
    emit VaultDeposit(msg.sender, amount);
  }

  function vaultBorrow(uint256 amount) external {

    if (vaults[msg.sender].debtAmount != 0) {
      vaults[msg.sender].debtAmount = getVaultRepayAmount();
    }
    uint256 maxBorrow = vaults[msg.sender].collateralAmount * collateral.price / debt.price / reserve.collateralizationRatio * 100;
    maxBorrow *= debt.priceGranularity;
    maxBorrow /= collateral.priceGranularity;
    maxBorrow -= vaults[msg.sender].debtAmount;
    require(amount < maxBorrow, "NOT ENOUGH COLLATERAL");
    require(amount <= reserve.debtBalance, "NOT ENOUGH RESERVES");
    vaults[msg.sender].debtAmount += amount + ((amount * reserve.originationFee) / 100);
    if (block.timestamp - vaults[msg.sender].createdAt > reserve.period) {
      vaults[msg.sender].createdAt = block.timestamp;
    }
    reserve.debtBalance -= amount;
    require(IERC20(debt.tokenAddress).transfer(msg.sender, amount));
    emit VaultBorrow(msg.sender, amount);
  }

  function vaultRepay(uint256 amount) external {

    vaults[msg.sender].debtAmount = getVaultRepayAmount();
    require(amount <= vaults[msg.sender].debtAmount, "CANNOT REPAY MORE THAN OWED");
    require(IERC20(debt.tokenAddress).transferFrom(msg.sender, address(this), amount));
    vaults[msg.sender].debtAmount -= amount;
    reserve.debtBalance += amount;
    uint256 periodsElapsed = (block.timestamp / reserve.period) - (vaults[msg.sender].createdAt / reserve.period);
    vaults[msg.sender].createdAt += periodsElapsed * reserve.period;
    emit VaultRepay(msg.sender, amount);
  }

  function vaultWithdraw(uint256 amount) external {

    uint256 maxBorrowAfterWithdraw = (vaults[msg.sender].collateralAmount - amount) * collateral.price / debt.price / reserve.collateralizationRatio * 100;
    maxBorrowAfterWithdraw *= debt.priceGranularity;
    maxBorrowAfterWithdraw /= collateral.priceGranularity;
    require(vaults[msg.sender].debtAmount <= maxBorrowAfterWithdraw, "CANNOT UNDERCOLLATERALIZE VAULT");
    require(IERC20(collateral.tokenAddress).transfer(msg.sender, amount));
    vaults[msg.sender].collateralAmount -= amount;
    reserve.collateralBalance -= amount;
    emit VaultWithdraw(msg.sender, amount);
  }

  function getDataBefore(uint256 _requestId, uint256 _timestamp)
      public
      view
      returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
  {

      uint256 _count = _tellorm.getNewValueCountbyRequestId(_requestId);
      if (_count > 0) {
          for (uint256 i = 1; i <= _count; i++) {
              uint256 _time = _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1);
              if (_time <= _timestamp && _tellorm.isInDispute(_requestId,_time) == false) {
                  _timestampRetrieved = _time;
              }
          }
          if (_timestampRetrieved > 0) {
              return (true, _tellorm.retrieveData(_requestId, _timestampRetrieved), _timestampRetrieved);
          }
      }
      return (false, 0, 0);
  }

}