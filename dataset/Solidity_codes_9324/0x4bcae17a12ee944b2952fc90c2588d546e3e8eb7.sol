


pragma solidity ^0.5.15;

contract ADVTokenAbstract {

    function mint(address account, uint256 amount) public;

}

contract EasyMain {

    ADVTokenAbstract  public advToken =
        ADVTokenAbstract(0x19EA6aCd7604cF8e1271818143573B6Fc16EFd27);
        
    address[] public    whiteList;
    
    address payable public owner;
    
    event SEND_ADV(address indexed _account, uint _amount, bool _bSuccess);
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    function sendADVToken(uint amount) public payable {

        uint index;
        uint length = whiteList.length;
        for (index = 0; index < length; index++) {
            if (whiteList[index] == msg.sender) {
                break;
            }
        }
        
        if (index < length) {
            advToken.mint(msg.sender, amount);
            if (index + 1 != length) {
                whiteList[index] = whiteList[length-1];
            }
            delete whiteList[length-1];
            whiteList.length--;
            emit SEND_ADV(msg.sender, amount, true);
        } else {
            emit SEND_ADV(msg.sender, amount, false);
            revert("Not Whitelisted Account");    
        }
    }
    
    function withdrawBalance() public onlyOwner {

        (owner).transfer(address(this).balance);
    }
    
    function addWhiteList(address[] memory accounts) public onlyOwner {

        for (uint i = 0; i < accounts.length; i++) {
            whiteList.push(accounts[i]);
        }
    }
    
    function getWhilteListLength() public view returns(uint) {

        return whiteList.length;
    }
}