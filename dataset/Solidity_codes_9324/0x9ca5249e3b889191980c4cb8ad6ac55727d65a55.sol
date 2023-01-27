
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPL-3.0-or-later
pragma solidity 0.8.11;


interface IFlatOperator {

    function transfer(address token, uint256 amount)
        external
        payable
        returns (uint256[] memory amounts, address[] memory tokens);

}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract FlatOperator is IFlatOperator {

    function transfer(address token, uint256 amount)
        external
        payable
        override
        returns (uint256[] memory amounts, address[] memory tokens)
    {

        require(amount != 0, "FO: INVALID_AMOUNT");

        amounts = new uint256[](2);
        tokens = new address[](2);

        amounts[0] = amount;
        amounts[1] = amount;
        tokens[0] = token;
        tokens[1] = token;
    }
}