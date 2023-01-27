
pragma solidity ^0.6.0;

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

        require(isOwner(),"Not Owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Oraclize{

    function oracleCallback(uint256 requestId,uint256 balance) external returns(bool);

    function oraclePriceAndBalanceCallback(uint256 requestId,uint256 priceA,uint256 priceB,uint256[] calldata balances) external returns(bool);

}

contract Oracle is Ownable{

    
    uint256 public requestIdCounter;

    mapping(address => bool) public isAllowedAddress;
    mapping(address => bool) public isSystemAddress;
    mapping(uint256 => bool) public requestFullFilled;
    mapping(uint256 => address) public requestedBy;

    
    event BalanceRequested(uint256 indexed requestId,uint256 network,address token,address user);
    event PriceAndBalanceRequested(uint256 indexed requestId,address tokenA,address tokenB,uint256 network,address token,address[] user);
    event BalanceUpdated(uint256 indexed requestId,uint256 balance);
    event PriceAndBalanceUpdated(uint256 indexed requestId,uint256 priceA,uint256 priceB,uint256[] balances);
    event SetSystem(address system, bool isActive);

    modifier onlySystem() {

        require(isSystemAddress[msg.sender],"Not System");
        _;
    }

    function setSystem(address system, bool isActive) external onlyOwner {

        isSystemAddress[system] = isActive;
        emit SetSystem(system, isActive);
    }

    function changeAllowedAddress(address _which,bool _bool) external onlyOwner returns(bool){

        isAllowedAddress[_which] = _bool;
        return true;
    }

    function getBalance(uint256 network,address token,address user) external returns(uint256){

        require(isAllowedAddress[msg.sender],"ERR_ALLOWED_ADDRESS_ONLY");
        requestIdCounter +=1;
        requestedBy[requestIdCounter] = msg.sender;
        emit BalanceRequested(requestIdCounter,network,token,user);
        return requestIdCounter;
    }
    
    function getPriceAndBalance(address tokenA,address tokenB,uint256 network,address token,address[] calldata user) external returns(uint256){

        require(isAllowedAddress[msg.sender],"ERR_ALLOWED_ADDRESS_ONLY");
        requestIdCounter +=1;
        requestedBy[requestIdCounter] = msg.sender;
        emit PriceAndBalanceRequested(requestIdCounter,tokenA,tokenB,network,token,user);
        return requestIdCounter;
    }
    
    function oracleCallback(uint256 _requestId,uint256 _balance) external onlySystem returns(bool){

        require(requestFullFilled[_requestId]==false,"ERR_REQUESTED_IS_FULFILLED");
        address _requestedBy = requestedBy[_requestId];
        Oraclize(_requestedBy).oracleCallback(_requestId,_balance);
        emit BalanceUpdated(_requestId,_balance);
        requestFullFilled[_requestId] = true;
        return true;
    }
    
    
    function oraclePriceAndBalanceCallback(uint256 _requestId,uint256 _priceA,uint256 _priceB,uint256[] calldata _balances) external onlySystem returns(bool){

        require(requestFullFilled[_requestId]==false,"ERR_REQUESTED_IS_FULFILLED");
        address _requestedBy = requestedBy[_requestId];
        Oraclize(_requestedBy).oraclePriceAndBalanceCallback(_requestId,_priceA,_priceB,_balances);
        emit PriceAndBalanceUpdated(_requestId,_priceA,_priceB,_balances);
        requestFullFilled[_requestId] = true;
        return true;
    }
}