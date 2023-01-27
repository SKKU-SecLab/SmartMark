


pragma solidity 0.6.9;


interface IDODOAdapter {

    
    function sellBase(address to, address pool, bytes memory data) external;


    function sellQuote(address to, address pool, bytes memory data) external;

}




interface ICurve {

    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns(uint256 dy);


    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256 dy);


    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 minDy) external;


    function exchange(int128 i, int128 j, uint256 dx, uint256 minDy) external;


    function underlying_coins(int128 arg0) external view returns(address out);

    function coins(int128 arg0) external view returns(address out);


}




interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}







library SafeERC20 {

    using SafeMath for uint256;

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

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}







library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address payable to,
        uint256 amount
    ) internal {

        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function universalApproveMax(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        uint256 allowance = token.allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, uint256(-1));
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {

        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function tokenBalanceOf(IERC20 token, address who) internal view returns (uint256) {

        return token.balanceOf(who);
    }

    function isETH(IERC20 token) internal pure returns (bool) {

        return token == ETH_ADDRESS;
    }
}










contract CurveAdapter is IDODOAdapter {

    using SafeMath for uint;

    function _curveSwap(address to, address pool, bytes memory moreInfo) internal {

        (address fromToken, address toToken, int128 i, int128 j) = abi.decode(moreInfo, (address, address, int128, int128));
        require(fromToken == ICurve(pool).coins(i), 'CurveAdapter: WRONG_TOKEN');
        require(toToken == ICurve(pool).coins(j), 'CurveAdapter: WRONG_TOKEN');
        uint256 sellAmount = IERC20(fromToken).balanceOf(address(this));

        IERC20(fromToken).approve(pool, sellAmount);
        ICurve(pool).exchange(i, j, sellAmount, 0);
        if(to != address(this)) {
            SafeERC20.safeTransfer(IERC20(toToken), to, IERC20(toToken).balanceOf(address(this)));
        }
    }

    function sellBase(address to, address pool, bytes memory moreInfo) external override {

        _curveSwap(to, pool, moreInfo);
    }

    function sellQuote(address to, address pool, bytes memory moreInfo) external override {

        _curveSwap(to, pool, moreInfo);
    }
}