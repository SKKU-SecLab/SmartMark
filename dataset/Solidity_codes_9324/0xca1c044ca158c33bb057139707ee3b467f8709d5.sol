pragma solidity ^0.8.0;

contract OpCommon {

    mapping(address => bool) internal _auth;
    address internal accountCenter;

    receive() external payable {}

    modifier onlyAuth() {

        require(_auth[msg.sender], "CHFRY: Permission Denied");
        _;
    }
}