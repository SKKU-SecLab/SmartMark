
pragma solidity 0.6.2;// MIT



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BatchTransfer {


     function sendTokens(address deployedTokenAddress, address[] calldata addresses, uint256[] calldata balances) external {

            require(addresses.length == balances.length, "The two arrays must be with the same length");
            IERC20 token = IERC20(deployedTokenAddress);
            for(uint i = 0; i < addresses.length; i++) { 
                require(balances[i] <= token.balanceOf(msg.sender), "Not enough balance");
                bool result = token.transferFrom(msg.sender, addresses[i], balances[i]);
                require(result, "The transfer was not successful");
            }
    }
}