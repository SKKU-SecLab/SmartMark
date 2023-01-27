
pragma solidity ^0.4.24;

contract vault3 {

    address public account1;
    address public account2;
    address public account3;

    modifier onlyGod() {

        require(msg.sender == account1, "You are not God");
        _;
    }

    modifier onlyOwners () {

        require((msg.sender == account1) || (msg.sender == account2) || (msg.sender == account2), "You are not 1 of the owners");
        _;
    }

    constructor (address _acct1, address _acct2, address _acct3) public {
        require((_acct1 != _acct2) && (_acct1 != _acct3) && (_acct2 != _acct3), "Accounts must be distinct");
        account1 = _acct1;
        account2 = _acct2;
        account3 = _acct3;
    }

    function deposit() public payable {


    }

    function changeAcct2(address _newAcct) onlyGod public {

        require((_newAcct != account1) && (_newAcct != account3), "Accounts must be distinct");
        withdraw();
        account2 = _newAcct;
    }

    function changeAcct3(address _newAcct) onlyGod public {

        require((_newAcct != account1) && (_newAcct != account2), "Accounts must be distinct");
        withdraw();
        account3 = _newAcct;
    }

    function withdraw() public onlyOwners {

        uint256 contractBalance = address(this).balance;
        uint256 share = contractBalance / 3;

        account1.transfer(share);
        account2.transfer(share);
        account3.transfer(share);
    }

    function withdrawAndKill() onlyOwners public {

        withdraw();
        selfdestruct(0);
    }
}