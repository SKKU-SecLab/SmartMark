
pragma solidity ^0.4.23;

contract BEP20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address who) public view returns (uint256);


    function transfer(address to, uint256 value) public returns (bool);


    function allowance(address owner, address spender) public view returns (uint256);


    function transferFrom(address from, address to, uint256 value) public returns (bool);


    function approve(address spender, uint256 value) public returns (bool);

}


contract AlbertToolsV1 {


    function batchTransferETH(uint256 eachAmount, address[] tos) payable public returns (bool){

        uint256 addressCount = tos.length;
        require(msg.value == eachAmount * addressCount, "amount not match");

        for (uint256 i = 0; i < addressCount; i++) {
            address(tos[i]).transfer(eachAmount);
        }
        return true;
    }

    function batchTransferERC20(address bep20Contract, uint256 eachAmount, address[] tos) public returns (bool){

        BEP20 bep20 = BEP20(bep20Contract);
        uint256 addressCount = tos.length;

        for (uint256 i = 0; i < addressCount; i++) {
            bep20.transferFrom(msg.sender, tos[i], eachAmount);
        }
        return true;
    }
}