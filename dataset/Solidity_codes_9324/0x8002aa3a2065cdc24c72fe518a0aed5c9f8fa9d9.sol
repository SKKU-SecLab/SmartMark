
pragma solidity ^0.7.1;

abstract contract Context {
    address public owner;            //Contract owner address
    bool public isContractActive;           //Make sure this contract can be used or not
    
    modifier onlyOwner{
        require(_msgSender() == owner, "Only owner can process");
        _;
    }
    
    modifier contractActive{
        require(isContractActive, "This contract is deactived");
        _;
    }

    constructor(){
       owner = _msgSender();           //Set owner address when contract is created
       isContractActive = true;        //Contract is active when it is created
    }

    function _msgSender() internal view returns(address){
        return msg.sender;
    }

    function _now() internal view returns(uint){
        return block.timestamp;
    }

    function setContractStatus(bool status) external onlyOwner{
        require(isContractActive != status,"The current contract's status is the same with updating status");
        isContractActive = status;
    }

    function setOwner(address newOwner) external onlyOwner returns(bool){
        require(newOwner != address(0), "New owner is zero address");
        require(newOwner != owner, "New owner is current owner");

        owner = newOwner;

        emit OwnerChanged(owner);
        return true;
    }

    event OwnerChanged(address newOwner);
}

abstract contract BaseContractData is Context{
    address internal _tokenSaleContractAddress;

    modifier onlyTokenSaleContract{
        require(_tokenSaleContractAddress != address(0), "Token sale contract address has not been initialized yet");
        require(_msgSender() == _tokenSaleContractAddress, "Only token sale contract can process this");
        _;
    }

    function setTokenSaleContractAddress(address contractAddress) external onlyOwner{
        _setTokenSaleContractAddress(contractAddress);
    }

    function _setTokenSaleContractAddress(address contractAddress) internal virtual{
        _tokenSaleContractAddress = contractAddress;
    }
}

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IShareTokenSaleData{

    function updatePurchaseData(address account, uint round, uint tokenAmount) external returns(bool);


    function end(uint round, uint time) external returns(bool);


    function getNextReleaseTime(uint round) external view returns(uint);


    function getReleasedCountByRound(uint round) external view returns(uint);


    function getReleasedCountByRoundAndHolder(uint round, address account) external view returns(uint);


    function getReleasedPercentByRound(uint round) external view returns(uint);


    function getTotalCanReleaseCountByRound(uint round) external view returns(uint);


    function updateReleasedData(uint round) external returns(bool);


    function updateWithdrawData(address account, uint round) external returns(bool);


    function getShareholderCanTransfer() external view returns(bool);


    function getShareholders() external view returns(address[] memory);


    function setShareholderCanTransfer(bool value) external;


    function updateShareholderTransferData(address from, address to, uint amount, uint round) external returns(bool);


    function getShareholderBalance(address account, uint round) external view returns(uint);


    function getTokenSaleEndTime(uint round)  external view returns(uint);

}

struct ShareHolderBalance{
    address account;
    uint balance;
}

contract ShareTokenSaleData is BaseContractData, IShareTokenSaleData{

    using SafeMath for uint;
    modifier canTransfer{

        require(_shareholderCanTransfer,"Can not transfer BNU now");
        _;
    }

    uint internal _tokenDecimalValue = 1000000000000000000;

    address[] internal _shareholders;

    mapping(uint => mapping(address => uint)) internal _shareholderBalances;

    mapping(uint => uint) internal _tokenSaleEndTimes;

    bool internal _shareholderCanTransfer;

    mapping(uint => uint) internal _tokenSaleStartTimes;

    mapping(uint => uint[]) internal _releaseDurations;

    mapping(uint => uint[]) internal _releasePercents;

    mapping(uint => uint) internal _releasedCounts;

    mapping(uint => mapping(address => uint)) internal _releaseHolderCounts;

    constructor(){
        _releaseDurations[0] = [180 days, 270 days, 360 days, 450 days, 540 days, 630 days, 720 days];
        _releasePercents[0] = [250, 125, 125, 125, 125, 125, 125];

        _releaseDurations[1] = [180 days, 270 days, 360 days, 450 days, 540 days, 630 days, 720 days];
        _releasePercents[1] = [250, 125, 125, 125, 125, 125, 125];

        _shareholderCanTransfer = true;
    }

    function updatePurchaseData(address account, uint round, uint tokenAmount) external override onlyTokenSaleContract returns(bool){

        require(round == 0 || round == 1, "Round is invalid");

        _increaseShareholderBalance(account, tokenAmount, round);

        require(_saveShareholder(account),"ShareTokenSaleData.updatePurchaseData: Can not create new shareholder");

        return true;
    }

    function end(uint round, uint time) external override onlyTokenSaleContract contractActive returns(bool){

        _setTokenSaleEndTime(round, time);
        return true;
    }

    function updateReleasedData(uint round) external override onlyTokenSaleContract contractActive returns(bool){

        _releasedCounts[round] = _releasedCounts[round].add(1);
        
        return true;
    }

    function updateWithdrawData(address account, uint round) external override onlyTokenSaleContract contractActive returns(bool){

        _releaseHolderCounts[round][account] = _releaseHolderCounts[round][account].add(1);
        
        return true;
    }

    function getNextReleaseTime(uint round) external override view returns(uint){

        uint tokenSaleEndTime = _tokenSaleEndTimes[round];
        require(tokenSaleEndTime > 0,"Round is not ended");

        return tokenSaleEndTime.add(_releaseDurations[round][_getReleasedCountByRound(round)]);
    }

    function getReleasedCountByRound(uint round) external override view returns(uint){

        return _getReleasedCountByRound(round);
    }

    function getReleasedCountByRoundAndHolder(uint round, address account) external override view returns(uint){

        return _releaseHolderCounts[round][account];
    }

    function getReleasedPercentByRound(uint round) external override view returns(uint){

        return _releasePercents[round][_getReleasedCountByRound(round)];
    }

    function getTotalCanReleaseCountByRound(uint round) external override view returns(uint){

        return _releaseDurations[round].length;
    }

    function getShareholderBalance(address account, uint round) external view override returns(uint){

        return _shareholderBalances[round][account];
    }

    function getShareholders() external view override returns(address[] memory){

        return _shareholders;
    }


    function getShareholderCanTransfer() external override view returns(bool){

        return _shareholderCanTransfer;
    }

    function setShareholderCanTransfer(bool value) external override onlyTokenSaleContract contractActive{

        _shareholderCanTransfer =  value;
    }

    function updateShareholderTransferData(address from, address to, uint amount, uint round) external override onlyTokenSaleContract canTransfer returns(bool){

        require(round == 0 || round == 1, "ShareTokenSaleData.addTransferHistoryAndBalance: Round is invalid");

        _decreaseShareholderBalance(from, amount, round);
        _increaseShareholderBalance(to, amount, round);

        require(_saveShareholder(to),"ShareTokenSaleData.updateShareholderTransferData: Can not save new shareholder");

        return true;
    }

    function getTokenSaleEndTime(uint round) external view override returns(uint){

        return _tokenSaleEndTimes[round];
    }

    function _increaseShareholderBalance(address account, uint amount, uint round) internal{

        _shareholderBalances[round][account] = _shareholderBalances[round][account].add(amount);
    }

    function _decreaseShareholderBalance(address account, uint amount, uint round) internal{

        _shareholderBalances[round][account] = _shareholderBalances[round][account].sub(amount);
    }

    function _getReleasedCountByRound(uint round) internal view returns(uint){

        return _releasedCounts[round];
    }

    function _saveShareholder(address account) internal returns(bool){

        require(account != address(0),"Shareholder is address zero");
        for(uint index = 0; index < _shareholders.length; index++){
            if(_shareholders[index] == account)
                return true;
        }
        _shareholders.push(account);

        return true;
    }

    function _setTokenSaleEndTime(uint round, uint time) internal returns(bool){

        _tokenSaleEndTimes[round] = time;
        return true;
    }
}

