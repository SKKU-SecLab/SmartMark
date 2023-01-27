pragma solidity ^0.8.10;


interface SmartWalletChecker {

    function check(address) external view returns (bool);

}// MIT
pragma solidity ^0.8.10;



contract SmartWalletWhitelist {

    mapping(address => bool) public wallets;
    address public admin;
    address public future_admin;
    address public checker;
    address public future_checker;

    event ApproveWallet(address indexed _wallet);
    event RevokeWallet(address indexed _wallet);

    constructor(address _admin) {
        require(_admin != address(0), "0");
        admin = _admin;
    }

    function commitAdmin(address _admin) external {

        require(msg.sender == admin, "!admin");
        future_admin = _admin;
    }

    function applyAdmin() external {

        require(msg.sender == admin, "!admin");
        require(future_admin != address(0), "admin not set");
        admin = future_admin;
    }

    function commitSetChecker(address _checker) external {

        require(msg.sender == admin, "!admin");
        future_checker = _checker;
    }

    function applySetChecker() external {

        require(msg.sender == admin, "!admin");
        checker = future_checker;
    }

    function approveWallet(address _wallet) public {

        require(msg.sender == admin, "!admin");
        wallets[_wallet] = true;

        emit ApproveWallet(_wallet);
    }

    function revokeWallet(address _wallet) external {

        require(msg.sender == admin, "!admin");
        wallets[_wallet] = false;

        emit RevokeWallet(_wallet);
    }

    function check(address _wallet) external view returns (bool) {

        bool _check = wallets[_wallet];
        if (_check) {
            return _check;
        } else {
            if (checker != address(0)) {
                return SmartWalletChecker(checker).check(_wallet);
            }
        }
        return false;
    }
}