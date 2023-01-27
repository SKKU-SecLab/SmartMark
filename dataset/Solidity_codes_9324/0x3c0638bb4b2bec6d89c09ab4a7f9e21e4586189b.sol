pragma solidity 0.6.10;

interface CalleeInterface {

    function callFunction(address payable _sender, bytes memory _data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20PermitUpgradeable {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}/**
 * UNLICENSED
 */
pragma solidity =0.6.10;

pragma experimental ABIEncoderV2;


contract PermitCallee is CalleeInterface {

    function callFunction(address payable _sender, bytes memory _data) external override {

        (
            address token,
            address owner,
            address spender,
            uint256 amount,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = abi.decode(_data, (address, address, address, uint256, uint256, uint8, bytes32, bytes32));

        IERC20PermitUpgradeable(token).permit(owner, spender, amount, deadline, v, r, s);
    }
}