
pragma solidity ^0.4.24;

contract PedigreeFactory {


    address public owner;
    
    mapping (address => address[]) list;
    
    constructor() public{
        owner = msg.sender;
    }

    function createPedigreeWithParent(address _father, address _mother, string _name, bool _gender, string _birthday, string _ipfs) public returns ( Pedigree ) {

        Pedigree newPedigree = new Pedigree(msg.sender, _father, _mother, _name, _gender, _birthday, _ipfs);
        list[msg.sender].push(newPedigree);
        return newPedigree;
    }

    function getList() public view returns(address[]){

        return list[msg.sender];
    }
    
    function () public payable{
    }
    
    function widthdraw() external payable{

        require( msg.sender == owner );
        msg.sender.transfer(address(this).balance);
    }
    
    function getContractBalance() external view returns(uint) {

        return address(this).balance;
    }
}

contract Pedigree {


    address public owner;

    address public father;

    address public mother;
    
    string public name;

    bool public gender;

    string public birthday;

    address public spouse;

    address[] childs;

    string public dateOfDead;

    string public ipfs;

    modifier onlyOwner(){

        require( msg.sender == owner );
        _;
    }

    constructor(address _owner, address _father, address _mother, string _name, bool _gender, string _birthday, string _ipfs) public {
        owner = _owner;
        father = _father;
        mother = _mother;
        name = _name;
        gender = _gender;
        birthday = _birthday;
        ipfs = _ipfs;
    }

    function addChild(address _childAddr) external {

        childs.push(_childAddr);
    }

    function getChilds() public view returns (address[]) {

        return childs;
    }

    function setSpouse(address _spouseAddr) external onlyOwner {

        spouse = _spouseAddr;
    }

    function getContractBalance() public view returns ( uint ) {

        return address(this).balance;
    }

    function setDateOfDead(string _date) external onlyOwner {

        dateOfDead = _date;
    }
    
    function setIPFS(string _ipfs) external onlyOwner {

        ipfs = _ipfs;
    }
    
}