pragma solidity ^0.7.1;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Apache-2.0
pragma solidity ^0.7.1;



contract Forwarder {


    address public parentAddress;
    event ForwarderDeposited(address from, address indexed to, uint value);

    event TokensFlushed(
        address tokenContractAddress, // The contract address of the token
        address to, // the contract - multisig - to which erc20 tokens were forwarded
        uint value // Amount of token sent
    );

    constructor (address multisigWallet) {
        parentAddress = multisigWallet;
    }


    function forwardERC20(address tokenAddress) public returns (bool){

        IERC20 token = IERC20(tokenAddress);
        uint value = token.balanceOf(address (this));
        if (value > 0 ) {
            if (token.transfer(parentAddress, value)) {
                emit TokensFlushed(tokenAddress, parentAddress, value);
                return true;
            }
        }
        return false;
    }


    function forward() payable public {


        (bool success, ) = parentAddress.call{value: address(this).balance}("");
        require(success, 'Deposit failed');
        emit ForwarderDeposited(msg.sender, parentAddress, msg.value);
    }

    receive () payable external {
        forward();
    }

}