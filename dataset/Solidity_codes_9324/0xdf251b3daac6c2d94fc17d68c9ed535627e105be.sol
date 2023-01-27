

pragma solidity ^0.6.0;
contract addressController {

    address public owner;
    address public manager;

    mapping(string => address) public addrList;
    mapping(address => bool) public ManagerList;
    mapping(address => bool) public MarketList;

    constructor(address _owner) public{
        owner = _owner;
    }

    function isManager(address _mAddr) external view returns(bool){

        return ManagerList[_mAddr];
    }

    function isMarket(address _mAddr) external view returns(bool){

        return MarketList[_mAddr];
    }
    function getAddr(string calldata _name) external view returns(address){

        return addrList[_name];
    }

    function addContract(string memory _name,address _contractAddr) public onlyOwner{

        require(Address.isContract(_contractAddr),"not contract Addr");
        addrList[_name] = _contractAddr;
    }

    function delContract(string memory _name) public onlyOwner{

        addrList[_name] = address(0);
    }

    function addManager(address _addrM) public onlyOwner{

        ManagerList[_addrM] = true;
    }

    function delManager(address _addrM) public onlyOwner{

        ManagerList[_addrM] = false;
    }

    function addMarket(address _addrM) public onlyOwner{

        MarketList[_addrM] = true;
    }

    function delMarket(address _addrM) public onlyOwner{

        MarketList[_addrM] = false;
    }

    function addAddress(string memory _name,address _cAddr) public onlyOwner{

        addrList[_name] = _cAddr;
    }



    function changeOwner(address _owner) public onlyOwner{

        owner = _owner;
    }

    modifier onlyOwner(){

        require(msg.sender == owner,"not setter");
        _;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

}