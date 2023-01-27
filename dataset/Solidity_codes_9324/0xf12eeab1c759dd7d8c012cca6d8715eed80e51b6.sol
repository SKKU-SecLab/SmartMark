

pragma solidity 0.8.6;




library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


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
}


interface Registry {

    function get_pool_from_lp_token(address lp) external view returns (address);


    function get_lp_token(address pool) external view returns (address);


    function get_n_coins(address) external view returns (uint256[2] memory);


    function get_coins(address) external view returns (address[8] memory);

}


interface StableSwap {

    function remove_liquidity_one_coin(
        uint256 amount,
        int128 i,
        uint256 min_amount
    ) external;


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external;


    function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount)
        external;


    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount)
        external;


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);


    function calc_token_amount(uint256[2] calldata amounts, bool is_deposit)
        external
        view
        returns (uint256);


    function calc_token_amount(uint256[3] calldata amounts, bool is_deposit)
        external
        view
        returns (uint256);


    function calc_token_amount(uint256[4] calldata amounts, bool is_deposit)
        external
        view
        returns (uint256);

}


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


interface Vault is IERC20 {

    function decimals() external view returns (uint256);


    function deposit() external returns (uint256);


    function deposit(uint256 amount) external returns (uint256);


    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);


    function withdraw() external returns (uint256);


    function withdraw(uint256 maxShares) external returns (uint256);


    function withdraw(uint256 maxShares, address recipient)
        external
        returns (uint256);


    function token() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function totalAssets() external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool);

}


contract VaultSwapper {

    Registry constant registry = Registry(0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5);
    uint256 constant MIN_AMOUNT_OUT = 1;

    struct Swap {
        bool deposit;
        address pool;
        uint128 n;
    }


    function metapool_swap_with_signature(
        address from_vault,
        address to_vault,
        uint256 amount,
        uint256 min_amount_out,
        uint256 expiry,
        bytes calldata signature 
    ) public {

        assert(Vault(from_vault).permit(msg.sender, address(this), amount, expiry, signature));
        metapool_swap(from_vault, to_vault, amount, min_amount_out);
    }

    function metapool_swap(
        address from_vault,
        address to_vault,
        uint256 amount,
        uint256 min_amount_out
    ) public {

        address underlying = Vault(from_vault).token();
        address target = Vault(to_vault).token();

        address underlying_pool = registry.get_pool_from_lp_token(underlying);
        address target_pool = registry.get_pool_from_lp_token(target);

        Vault(from_vault).transferFrom(msg.sender, address(this), amount);
        uint256 underlying_amount = Vault(from_vault).withdraw(
            amount,
            address(this)
        );
        StableSwap(underlying_pool).remove_liquidity_one_coin(
            underlying_amount,
            1,
            1
        );

        IERC20 underlying_coin = IERC20(registry.get_coins(underlying_pool)[1]);
        uint256 liquidity_amount = underlying_coin.balanceOf(address(this));

        underlying_coin.approve(target_pool, liquidity_amount);

        StableSwap(target_pool).add_liquidity([0, liquidity_amount], MIN_AMOUNT_OUT);

        uint256 target_amount = IERC20(target).balanceOf(address(this));
        approve(target, to_vault, target_amount);

        uint256 out = Vault(to_vault).deposit(target_amount, msg.sender);
        require(out >= min_amount_out, "out too low");
    }

    function metapool_estimate_out(
        address from_vault,
        address to_vault,
        uint256 amount
    ) public view returns (uint256) {

        address underlying = Vault(from_vault).token();
        address target = Vault(to_vault).token();

        address underlying_pool = registry.get_pool_from_lp_token(underlying);
        address target_pool = registry.get_pool_from_lp_token(target);

        uint256 pricePerShareFrom = Vault(from_vault).pricePerShare();
        uint256 pricePerShareTo = Vault(to_vault).pricePerShare();

        uint256 amount_out = (pricePerShareFrom * amount) /
            (10**Vault(from_vault).decimals());
        amount_out = StableSwap(underlying_pool).calc_withdraw_one_coin(
            amount_out,
            1
        );
        amount_out = StableSwap(target_pool).calc_token_amount(
            [0, amount_out],
            true
        );

        return
            (amount_out * (10**Vault(to_vault).decimals())) / pricePerShareTo;
    }

    function swap_with_signature(
        address from_vault,
        address to_vault,
        uint256 amount,
        uint256 min_amount_out,
        Swap[] calldata instructions,
        uint256 expiry,
        bytes calldata signature 
    ) public {

        assert(Vault(from_vault).permit(msg.sender, address(this), amount, expiry, signature));
        swap(from_vault, to_vault, amount, min_amount_out, instructions);
    }

    function swap(
        address from_vault,
        address to_vault,
        uint256 amount,
        uint256 min_amount_out,
        Swap[] calldata instructions
    ) public {

        address token = Vault(from_vault).token();
        address target = Vault(to_vault).token();

        Vault(from_vault).transferFrom(msg.sender, address(this), amount);

        amount = Vault(from_vault).withdraw(amount, address(this));
        uint256 n_coins;
        for (uint256 i = 0; i < instructions.length; i++) {
            if (instructions[i].deposit) {
                n_coins = registry.get_n_coins(instructions[i].pool)[0];
                uint256[] memory list = new uint256[](n_coins);
                list[instructions[i].n] = amount;
                approve(token, instructions[i].pool, amount);

                if (n_coins == 2) {
                    StableSwap(instructions[i].pool).add_liquidity(
                        [list[0], list[1]],
                        1
                    );
                } else if (n_coins == 3) {
                    StableSwap(instructions[i].pool).add_liquidity(
                        [list[0], list[1], list[2]],
                        1
                    );
                } else if (n_coins == 4) {
                    StableSwap(instructions[i].pool).add_liquidity(
                        [list[0], list[1], list[2], list[3]],
                        1
                    );
                }

                token = registry.get_lp_token(instructions[i].pool);
                amount = IERC20(token).balanceOf(address(this));
            } else {
                token = registry.get_coins(instructions[i].pool)[
                    instructions[i].n
                ];
                amount = remove_liquidity_one_coin(
                    token,
                    instructions[i].pool,
                    amount,
                    instructions[i].n
                );
            }
        }

        require(target == token, "!path");

        approve(target, to_vault, amount);

        uint256 out = Vault(to_vault).deposit(amount, msg.sender);
        require(out >= min_amount_out, "out too low");
    }

    function remove_liquidity_one_coin(
        address token,
        address pool,
        uint256 amount,
        uint128 n
    ) internal returns (uint256) {

        uint256 amountBefore = IERC20(token).balanceOf(address(this));
        pool.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,int128,uint256)",
                amount,
                int128(n),
                1
            )
        );

        uint256 newAmount = IERC20(token).balanceOf(address(this));

        if (newAmount > amountBefore) {
            return newAmount;
        }

        pool.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,uint256,uint256)",
                amount,
                uint256(n),
                1
            )
        );
        return IERC20(token).balanceOf(address(this));
    }

    function estimate_out(
        address from_vault,
        address to_vault,
        uint256 amount,
        Swap[] calldata instructions
    ) public view returns (uint256) {

        uint256 pricePerShareFrom = Vault(from_vault).pricePerShare();
        uint256 pricePerShareTo = Vault(to_vault).pricePerShare();
        amount =
            (amount * pricePerShareFrom) /
            (10**Vault(from_vault).decimals());
        for (uint256 i = 0; i < instructions.length; i++) {
            uint256 n_coins = registry.get_n_coins(instructions[i].pool)[0];
            if (instructions[i].deposit) {
                n_coins = registry.get_n_coins(instructions[i].pool)[0];
                uint256[] memory list = new uint256[](n_coins);
                list[instructions[i].n] = amount;

                if (n_coins == 2) {
                    amount = StableSwap(instructions[i].pool).calc_token_amount(
                            [list[0], list[1]],
                            true
                        );
                } else if (n_coins == 3) {
                    amount = StableSwap(instructions[i].pool).calc_token_amount(
                            [list[0], list[1], list[2]],
                            true
                        );
                } else if (n_coins == 4) {
                    amount = StableSwap(instructions[i].pool).calc_token_amount(
                            [list[0], list[1], list[2], list[3]],
                            true
                        );
                }
            } else {
                amount = calc_withdraw_one_coin(
                    instructions[i].pool,
                    amount,
                    instructions[i].n
                );
            }
        }
        return (amount * (10**Vault(to_vault).decimals())) / pricePerShareTo;
    }

    function approve(
        address target,
        address to_vault,
        uint256 amount
    ) internal {

        if (IERC20(target).allowance(address(this), to_vault) < amount) {
            SafeERC20.safeApprove(IERC20(target), to_vault, 0);
            SafeERC20.safeApprove(IERC20(target), to_vault, type(uint256).max);
        }
    }

    function calc_withdraw_one_coin(
        address pool,
        uint256 amount,
        uint128 n
    ) internal view returns (uint256) {

        (bool success, bytes memory returnData) = pool.staticcall(
            abi.encodeWithSignature(
                "calc_withdraw_one_coin(uint256,uint256)",
                amount,
                uint256(n)
            )
        );
        if (success) {
            return abi.decode(returnData, (uint256));
        }
        (success, returnData) = pool.staticcall(
            abi.encodeWithSignature(
                "calc_withdraw_one_coin(uint256,int128)",
                amount,
                int128(n)
            )
        );

        require(success, "!success");

        return abi.decode(returnData, (uint256));
    }
}