

pragma solidity ^0.6.0;


contract Ownable {

    
    address payable public owner;
    
    address payable public newOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    constructor() internal {
        _trasnferOwnership(msg.sender);
    }
    
    function _trasnferOwnership(address payable _whom) internal {

        emit OwnershipTransferred(owner,_whom);
        owner = _whom;
    }
    

    modifier onlyOwner() {

        require(owner == msg.sender, "ERR_AUTHORIZED_ADDRESS_ONLY");
        _;
    }

    function transferOwnership(address payable _newOwner)
        external
        virtual
        onlyOwner
    {

        require(_newOwner != address(0),"ERR_ZERO_ADDRESS");
        newOwner = _newOwner;
    }
    
    
    function acceptOwnership() external
        virtual
        returns (bool){

            require(msg.sender == newOwner,"ERR_ONLY_NEW_OWNER");
            owner = newOwner;
            emit OwnershipTransferred(owner, newOwner);
            newOwner = address(0);
            return true;
        }
    
    
}

pragma solidity ^0.6.0;


interface Oraclize{

    function oracleCallback(uint256 requsestId,uint256 balance) external returns(bool);

}

contract JointerOracle is Ownable{

    
    uint256 public requsestId;

    mapping(address => bool) public isAllowedAddress;
    mapping(uint256 => bool) public requestFullFilled;
    mapping(uint256 => address) public requestedBy;
    mapping(uint256 => address) public requestedToken;
    mapping(uint256 => address) public requestedUser;
    
    event BalanceRequested(uint256 requsestId,uint256 network,address token,address user);
    event BalanceUpdated(uint256 requsestId,address token,address user,uint256 balance);
    
    function getBalance(uint256 network,address token,address user) external returns(uint256){

        require(isAllowedAddress[msg.sender],"ERR_ALLOWED_ADDRESS_ONLY");
        requsestId +=1;
        requestedBy[requsestId] = msg.sender;
        requestedUser[requsestId] = user;
        requestedToken[requsestId] = token;
        emit BalanceRequested(requsestId,network,token,user);
        return requsestId;
    }
    
    
    
    function oracleCallback(uint256 _requsestId,uint256 _balances) external onlyOwner returns(bool){

        require(requestFullFilled[_requsestId]==false,"ERR_REQUESTED_IS_FULLFILLED");
        address _requestedBy = requestedBy[requsestId];
        Oraclize(_requestedBy).oracleCallback(requsestId,_balances);
        emit BalanceUpdated(requsestId,requestedToken[_requsestId],requestedUser[_requsestId],_balances);
        requestFullFilled[_requsestId] = true;
        return true;
    }
    
    function changeAllowedAddress(address _which,bool _bool) external onlyOwner returns(bool){

        isAllowedAddress[_which] = _bool;
        return true;
    }

}