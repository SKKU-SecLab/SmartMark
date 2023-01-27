

pragma solidity 0.4.25;

contract Ownable {


    address public owner;

    address public newOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {

        require(msg.sender == owner, "Restricted to owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0x0), "New owner is zero");

        newOwner = _newOwner;
    }

    function transferOwnershipUnsafe(address _newOwner) public onlyOwner {

        require(_newOwner != address(0x0), "New owner is zero");

        _transferOwnership(_newOwner);
    }

    function claimOwnership() public {

        require(msg.sender == newOwner, "Restricted to new owner");

        _transferOwnership(msg.sender);
    }

    function _transferOwnership(address _newOwner) private {

        if (_newOwner != owner) {
            emit OwnershipTransferred(owner, _newOwner);

            owner = _newOwner;
        }
    }

}


pragma solidity 0.4.25;



contract Whitelist is Ownable {


    mapping(address => bool) public admins;

    mapping(address => bool) public isWhitelisted;

    event AdminAdded(address indexed admin);

    event AdminRemoved(address indexed admin);

    event InvestorAdded(address indexed admin, address indexed investor);

    event InvestorRemoved(address indexed admin, address indexed investor);

    modifier onlyAdmin() {

        require(admins[msg.sender], "Restricted to whitelist admin");
        _;
    }

    function addAdmin(address _admin) public onlyOwner {

        require(_admin != address(0x0), "Whitelist admin is zero");

        if (!admins[_admin]) {
            admins[_admin] = true;

            emit AdminAdded(_admin);
        }
    }

    function removeAdmin(address _admin) public onlyOwner {

        require(_admin != address(0x0), "Whitelist admin is zero");  // Necessary?

        if (admins[_admin]) {
            admins[_admin] = false;

            emit AdminRemoved(_admin);
        }
    }

    function addToWhitelist(address[] _investors) external onlyAdmin {

        for (uint256 i = 0; i < _investors.length; i++) {
            if (!isWhitelisted[_investors[i]]) {
                isWhitelisted[_investors[i]] = true;

                emit InvestorAdded(msg.sender, _investors[i]);
            }
        }
    }

    function removeFromWhitelist(address[] _investors) external onlyAdmin {

        for (uint256 i = 0; i < _investors.length; i++) {
            if (isWhitelisted[_investors[i]]) {
                isWhitelisted[_investors[i]] = false;

                emit InvestorRemoved(msg.sender, _investors[i]);
            }
        }
    }

}