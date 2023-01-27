
pragma solidity ^0.6.2;

contract MincedMeat{


    using SafeMath for uint256;
    mapping(address => bool) public owners;        // 管理员
    mapping(address => bool) public allowCallers;  // 允许调用transactionChannel的合约地址
    mapping(address => uint256) public serviceCharges;  // 手续费设置
    string public prefix = "\x19Ethereum Signed Message:\n32";
    ERC20 erc20;

    constructor() public{
        owners[msg.sender] = true;
    }

    function transactionChannel(address[] memory _from,address[] memory _to,uint256[] memory _value,bytes32[] memory _r,bytes32[] memory _s,uint8[] memory _v,address _contractAddress) public onlyAllowCallers{

        erc20 = ERC20(_contractAddress);
        uint256 serviceCharge = serviceCharges[_contractAddress];
        if(serviceCharges[_contractAddress] == 0){
            for(uint256 i=0; i<_from.length; i++){
                _sendTransaction(_from[i],_to[i],_value[i],_r[i],_s[i],_v[i],_contractAddress);
            }
        }else{
            for(uint256 i=0; i<_from.length; i++){
                if(erc20.balanceOf(_from[i]) >= _value[i] && getVerifySignatureResult(_from[i],_to[i],_value[i],_r[i],_s[i],_v[i],_contractAddress) == _from[i]){
                    erc20.transferFrom(_from[i],tx.origin,serviceCharge);
                    erc20.transferFrom(_from[i],_to[i],_value[i].sub(serviceCharge));
                }
            }
        }
    }

    function _sendTransaction(address _from,address _to,uint256 _value,bytes32 _r,bytes32 _s,uint8 _v,address _contractAddress) private{

        if(getVerifySignatureResult(_from,_to,_value, _r, _s, _v,_contractAddress) == _from){
            erc20.transferFrom(_from,_to,_value);
        }
    }

    function getVerifySignatureResult(address _from,address _to,uint256 _value,bytes32 _r,bytes32 _s,uint8 _v,address _contractAddress) public view returns(address){

        return ecrecover(getSha3Result(_from,_to,_value,_contractAddress), _v, _r, _s);
    }

    function getVerifySignatureByRandom(bytes memory _random,bytes32 _r,bytes32 _s,uint8 _v) public view returns(address){

        return ecrecover(keccak256(abi.encodePacked(prefix,keccak256(abi.encodePacked(_random)))),_v,_r,_s);
    }

    function getSha3Result(address _from,address _to,uint256 _value,address _contractAddress) public view returns(bytes32){

        return keccak256(abi.encodePacked(prefix,keccak256(abi.encodePacked(_from,_to,_value,_contractAddress))));
    }

    function addServiceCharge(address _contractAddress,uint256 _serviceCharge) public onlyOwner{

        serviceCharges[_contractAddress] = _serviceCharge;
    }

    function addCaller(address _caller) public onlyOwner{

        allowCallers[_caller] = true;
    }

    function removeCaller(address _caller) public onlyOwner{

        allowCallers[_caller] = false;
    }

    function addOwner(address _owner) public onlyOwner{

        owners[_owner] = true;
    }

    function removeOwner(address _owner) public onlyOwner{

        owners[_owner] = false;
    }

    modifier onlyOwner(){

        require(owners[msg.sender], 'No authority');
        _;
    }

    modifier onlyAllowCallers(){

        require(allowCallers[msg.sender],'No call permission');
        _;
    }
}

interface ERC20{

    function transferFrom(address _from, address _to, uint256 _value) external;

    function balanceOf(address) external returns(uint256);

}
library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a,"When sub, a must be greater than b");
        uint256 c = a - b;
        return c;
    }
}