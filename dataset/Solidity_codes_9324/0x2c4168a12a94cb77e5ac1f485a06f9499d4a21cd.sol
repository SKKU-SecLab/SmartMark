pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.16;


contract UniverseChart is Ownable {

    struct Account {
        uint128 id;
        uint128 referrerId;
    }

    uint128 public lastId = 1;
    mapping(address => Account) public accounts;
    mapping(uint128 => address) public accountIds;

    event Register(uint128 id, address user, address referrer);

    constructor(address _company) public {
        setCompany(_company);
    }

    function register(address _referrer) external {

        require(
            accounts[_referrer].id != 0 || _referrer == accountIds[0],
            "Invalid referrer address"
        );
        require(accounts[msg.sender].id == 0, "Account has been registered");

        Account memory account =
            Account({id: lastId, referrerId: accounts[_referrer].id});

        accounts[msg.sender] = account;
        accountIds[lastId] = msg.sender;

        emit Register(lastId++, msg.sender, _referrer);
    }

    function setCompany(address _company) public onlyOwner {

        require(
            _company != accountIds[0],
            "You entered the same company address"
        );
        require(
            accounts[_company].id == 0,
            "Company was registered on the chart"
        );
        Account memory account = Account({id: 0, referrerId: 0});
        accounts[_company] = account;
        accountIds[0] = _company;
    }
}