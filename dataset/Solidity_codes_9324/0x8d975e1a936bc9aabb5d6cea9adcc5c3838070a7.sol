

pragma solidity ^0.5.9;

contract IToken {

    function balanceOf(address _owner) public view returns (uint);


    function allowance(address _owner, address _spender) public view returns (uint);

}

contract BalanceChecker {

    function() external payable {
      revert("BalanceChecker does not accept payments");
    }

    function tokenBalance(address user, address token) public view returns (uint) {

        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) } // contract code size

        if (tokenCode > 0) {  
            return IToken(token).balanceOf(user);
        } else {
            return 0;
        }
    }

    function balances(address[] calldata users, address[] calldata tokens) external view returns (uint[] memory) {

        require(users.length == tokens.length, "users array is a different length than the tokens array");

        uint[] memory addrBalances = new uint[](users.length);

        for(uint i = 0; i < users.length; i++) {
            if (tokens[i] != address(0x0)) {
                addrBalances[i] = tokenBalance(users[i], tokens[i]);
            } else {
                addrBalances[i] = users[i].balance; // ETH balance
            }
        }

        return addrBalances;
    }

    function allowance(address owner, address spender, address token) public view returns (uint) {

        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) } // contract code size

        if (tokenCode > 0) {  
            return IToken(token).allowance(owner, spender);
        } else {
            return 0;
        }
    }

    function allowances(address[] calldata owners, address[] calldata spenders, address[] calldata tokens) external view returns (uint[] memory) {

        require(owners.length == spenders.length, "all arrays must be of equal length");
        require(owners.length == tokens.length, "all arrays must be of equal length");

        uint[] memory addrAllowances = new uint[](owners.length);

        for(uint i = 0; i < owners.length; i++) {
            if (tokens[i] != address(0x0)) {
                addrAllowances[i] = allowance(owners[i], spenders[i], tokens[i]);
            } else {
                addrAllowances[i] = 0;
            }
        }

        return addrAllowances;
    }


}