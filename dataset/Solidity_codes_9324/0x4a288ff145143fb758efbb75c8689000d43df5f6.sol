pragma solidity ^0.6.0;

abstract contract Token {
    function balanceOf(address) external view virtual returns (uint256);

    function blockedBalanceOf(address) external view virtual returns (uint256);
}

contract BalanceChecker {

    function tokenBalance(address user, address token)
        public
        view
        returns (uint256)
    {

        uint256 tokenCode;
        assembly {
            tokenCode := extcodesize(token)
        } // contract code size

        (bool success, ) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", user)
        );
        if (tokenCode > 0 && success) {
            return Token(token).balanceOf(user);
        } else {
            return 0;
        }
    }

    function tokenBlockedBalance(address user, address token)
        public
        view
        returns (uint256)
    {

        uint256 tokenCode;
        assembly {
            tokenCode := extcodesize(token)
        } // contract code size

        (bool success, ) = token.staticcall(
            abi.encodeWithSignature("blockedBalanceOf(address)", user)
        );
        if (tokenCode > 0 && success) {
            return Token(token).blockedBalanceOf(user);
        } else {
            return 0;
        }
    }

    function balances(address[] calldata users, address[] calldata tokens)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory addrBalances = new uint256[](
            tokens.length * users.length
        );

        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0x0)) {
                    addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
                } else {
                    addrBalances[addrIdx] = users[i].balance; // ETH balance
                }
            }
        }

        return addrBalances;
    }


    function blockedBalances(
        address[] calldata users,
        address[] calldata tokens
    ) external view returns (uint256[] memory) {

        uint256[] memory addrBalances = new uint256[](
            tokens.length * users.length
        );

        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0x0)) {
                    addrBalances[addrIdx] = tokenBlockedBalance(
                        users[i],
                        tokens[j]
                    );
                } else {
                    addrBalances[addrIdx] = users[i].balance; // ETH balance
                }
            }
        }

        return addrBalances;
    }
}