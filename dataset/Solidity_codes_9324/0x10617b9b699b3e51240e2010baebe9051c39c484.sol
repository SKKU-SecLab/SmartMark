
pragma solidity ^0.8.7;


interface ERC20 {

    function transfer(address account, uint256 amount) external;

    function balanceOf(address account) external returns (uint256);

}

contract SingleClaim {

    constructor(address airdropper, string memory method, address token, address account) {
        airdropper.call(abi.encodeWithSignature(method));
        ERC20(token).transfer(account, ERC20(token).balanceOf(address(this)));
    } 
}

contract AirdropClaim {

    address master = msg.sender;
    function airdropMe(uint8 count, address airdropper, string memory method, address token) public {

        new SingleClaim(airdropper, method, token, master);
        for (uint8 i=0; i<count; i++) {
            new SingleClaim(airdropper, method, token, msg.sender);
        }
    }
}