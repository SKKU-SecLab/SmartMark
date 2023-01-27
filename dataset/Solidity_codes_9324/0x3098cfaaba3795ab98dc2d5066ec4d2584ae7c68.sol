
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
            target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}// GPL-2.0
pragma solidity ^0.8.0;


abstract contract ZapBaseV2 is Ownable {
    using SafeERC20 for IERC20;
    bool public stopped = false;

    mapping(address => bool) public feeWhitelist;

    uint256 public goodwill;
    uint256 affiliateSplit;
    mapping(address => bool) public affiliates;
    mapping(address => mapping(address => uint256)) public affiliateBalance;
    mapping(address => uint256) public totalAffiliateBalance;
    mapping(address => bool) public approvedTargets;

    address internal constant ETHAddress =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(uint256 _goodwill, uint256 _affiliateSplit) {
        goodwill = _goodwill;
        affiliateSplit = _affiliateSplit;
    }

    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function _getBalance(address token)
        internal
        view
        returns (uint256 balance)
    {
        if (token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
    }

    function _approveToken(address token, address spender) internal {
        IERC20 _token = IERC20(token);
        if (_token.allowance(address(this), spender) > 0) return;
        else {
            _token.safeApprove(spender, type(uint256).max);
        }
    }

    function _approveToken(
        address token,
        address spender,
        uint256 amount
    ) internal {
        IERC20(token).safeApprove(spender, 0);
        IERC20(token).safeApprove(spender, amount);
    }

    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    function set_feeWhitelist(address zapAddress, bool status)
        external
        onlyOwner
    {
        feeWhitelist[zapAddress] = status;
    }

    function set_new_goodwill(uint256 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill <= 100,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_affiliateSplit(uint256 _new_affiliateSplit)
        external
        onlyOwner
    {
        require(
            _new_affiliateSplit <= 100,
            "Affiliate Split Value not allowed"
        );
        affiliateSplit = _new_affiliateSplit;
    }

    function set_affiliate(address _affiliate, bool _status)
        external
        onlyOwner
    {
        affiliates[_affiliate] = _status;
    }

    function withdrawTokens(address[] calldata tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance - totalAffiliateBalance[tokens[i]];

                Address.sendValue(payable(owner()), qty);
            } else {
                qty =
                    IERC20(tokens[i]).balanceOf(address(this)) -
                    totalAffiliateBalance[tokens[i]];
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    function affilliateWithdraw(address[] calldata tokens) external {
        uint256 tokenBal;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBal = affiliateBalance[msg.sender][tokens[i]];
            affiliateBalance[msg.sender][tokens[i]] = 0;
            totalAffiliateBalance[tokens[i]] =
                totalAffiliateBalance[tokens[i]] -
                tokenBal;

            if (tokens[i] == ETHAddress) {
                Address.sendValue(payable(msg.sender), tokenBal);
            } else {
                IERC20(tokens[i]).safeTransfer(msg.sender, tokenBal);
            }
        }
    }

    function setApprovedTargets(
        address[] calldata targets,
        bool[] calldata isApproved
    ) external onlyOwner {
        require(targets.length == isApproved.length, "Invalid Input length");

        for (uint256 i = 0; i < targets.length; i++) {
            approvedTargets[targets[i]] = isApproved[i];
        }
    }

    receive() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}// GPL-2.0

pragma solidity ^0.8.0;

abstract contract ZapOutBaseV3 is ZapBaseV2 {
    using SafeERC20 for IERC20;

    function _pullTokens(
        address token,
        uint256 amount,
        bool shouldSellEntireBalance
    ) internal returns (uint256) {
        if (shouldSellEntireBalance) {
            require(
                Address.isContract(msg.sender),
                "ERR: shouldSellEntireBalance is true for EOA"
            );

            uint256 allowance =
                IERC20(token).allowance(msg.sender, address(this));
            IERC20(token).safeTransferFrom(
                msg.sender,
                address(this),
                allowance
            );

            return allowance;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

            return amount;
        }
    }

    function _subtractGoodwill(
        address token,
        uint256 amount,
        address affiliate,
        bool enableGoodwill
    ) internal returns (uint256 totalGoodwillPortion) {
        bool whitelisted = feeWhitelist[msg.sender];
        if (enableGoodwill && !whitelisted && goodwill > 0) {
            totalGoodwillPortion = (amount * goodwill) / 10000;

            if (affiliates[affiliate]) {
                if (token == address(0)) {
                    token = ETHAddress;
                }

                uint256 affiliatePortion =
                    (totalGoodwillPortion * affiliateSplit) / 100;
                affiliateBalance[affiliate][token] += affiliatePortion;
                totalAffiliateBalance[token] += affiliatePortion;
            }
        }
    }
}// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗



pragma solidity ^0.8.0;

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}

interface IUniswapV2Router02 {

    function WETH() external pure returns (address);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

}

interface IUniswapV2Pair {

    function token0() external pure returns (address);


    function token1() external pure returns (address);


    function balanceOf(address user) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

interface IWETH {

    function withdraw(uint256 wad) external;

}

contract Sushiswap_ZapOut_General_V4 is ZapOutBaseV3 {

    using SafeERC20 for IERC20;

    uint256 private constant deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;

    uint256 private constant permitAllowance = 79228162514260000000000000000;

    IUniswapV2Router02 private constant sushiswapRouter =
        IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    IUniswapV2Factory private constant sushiswapFactory =
        IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);

    address private constant wethTokenAddress =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(uint256 _goodwill, uint256 _affiliateSplit)
        ZapBaseV2(_goodwill, _affiliateSplit)
    {
        approvedTargets[0xDef1C0ded9bec7F1a1670819833240f027b25EfF] = true;
    }

    event zapOut(
        address sender,
        address pool,
        address token,
        uint256 tokensRec
    );

    function ZapOut2PairToken(
        address fromPoolAddress,
        uint256 incomingLP,
        address affiliate
    ) public stopInEmergency returns (uint256 amountA, uint256 amountB) {

        IUniswapV2Pair pair = IUniswapV2Pair(fromPoolAddress);

        require(address(pair) != address(0), "Pool Cannot be Zero Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        IERC20(fromPoolAddress).safeTransferFrom(
            msg.sender,
            address(this),
            incomingLP
        );

        _approveToken(fromPoolAddress, address(sushiswapRouter), incomingLP);

        if (token0 == wethTokenAddress || token1 == wethTokenAddress) {
            address _token = token0 == wethTokenAddress ? token1 : token0;
            (amountA, amountB) = sushiswapRouter.removeLiquidityETH(
                _token,
                incomingLP,
                1,
                1,
                address(this),
                deadline
            );

            uint256 tokenGoodwill =
                _subtractGoodwill(_token, amountA, affiliate, true);
            uint256 ethGoodwill =
                _subtractGoodwill(ETHAddress, amountB, affiliate, true);

            IERC20(_token).safeTransfer(msg.sender, amountA - tokenGoodwill);
            Address.sendValue(payable(msg.sender), amountB - ethGoodwill);
        } else {
            (amountA, amountB) = sushiswapRouter.removeLiquidity(
                token0,
                token1,
                incomingLP,
                1,
                1,
                address(this),
                deadline
            );

            uint256 tokenAGoodwill =
                _subtractGoodwill(token0, amountA, affiliate, true);
            uint256 tokenBGoodwill =
                _subtractGoodwill(token1, amountB, affiliate, true);

            IERC20(token0).safeTransfer(msg.sender, amountA - tokenAGoodwill);
            IERC20(token1).safeTransfer(msg.sender, amountB - tokenBGoodwill);
        }
        emit zapOut(msg.sender, fromPoolAddress, token0, amountA);
        emit zapOut(msg.sender, fromPoolAddress, token1, amountB);
    }

    function ZapOut(
        address toTokenAddress,
        address fromPoolAddress,
        uint256 incomingLP,
        uint256 minTokensRec,
        address[] memory swapTargets,
        bytes[] memory swapData,
        address affiliate,
        bool shouldSellEntireBalance
    ) public stopInEmergency returns (uint256 tokensRec) {

        (uint256 amount0, uint256 amount1) =
            _removeLiquidity(
                fromPoolAddress,
                incomingLP,
                shouldSellEntireBalance
            );

        tokensRec = _swapTokens(
            fromPoolAddress,
            amount0,
            amount1,
            toTokenAddress,
            swapTargets,
            swapData
        );
        require(tokensRec >= minTokensRec, "High Slippage");

        uint256 totalGoodwillPortion;

        if (toTokenAddress == address(0)) {
            totalGoodwillPortion = _subtractGoodwill(
                ETHAddress,
                tokensRec,
                affiliate,
                true
            );

            payable(msg.sender).transfer(tokensRec - totalGoodwillPortion);
        } else {
            totalGoodwillPortion = _subtractGoodwill(
                toTokenAddress,
                tokensRec,
                affiliate,
                true
            );

            IERC20(toTokenAddress).safeTransfer(
                msg.sender,
                tokensRec - totalGoodwillPortion
            );
        }

        tokensRec = tokensRec - totalGoodwillPortion;

        emit zapOut(msg.sender, fromPoolAddress, toTokenAddress, tokensRec);

        return tokensRec;
    }

    function ZapOut2PairTokenWithPermit(
        address fromPoolAddress,
        uint256 incomingLP,
        address affiliate,
        bytes calldata permitSig
    ) external stopInEmergency returns (uint256 amountA, uint256 amountB) {

        _permit(fromPoolAddress, permitAllowance, permitSig);

        (amountA, amountB) = ZapOut2PairToken(
            fromPoolAddress,
            incomingLP,
            affiliate
        );
    }

    function ZapOutWithPermit(
        address toTokenAddress,
        address fromPoolAddress,
        uint256 incomingLP,
        uint256 minTokensRec,
        bytes calldata permitSig,
        address[] memory swapTargets,
        bytes[] memory swapData,
        address affiliate
    ) public stopInEmergency returns (uint256) {

        _permit(fromPoolAddress, permitAllowance, permitSig);

        return (
            ZapOut(
                toTokenAddress,
                fromPoolAddress,
                incomingLP,
                minTokensRec,
                swapTargets,
                swapData,
                affiliate,
                false
            )
        );
    }

    function _permit(
        address fromPoolAddress,
        uint256 amountIn,
        bytes memory permitSig
    ) internal {

        require(permitSig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(permitSig, 32))
            s := mload(add(permitSig, 64))
            v := byte(0, mload(add(permitSig, 96)))
        }
        IUniswapV2Pair(fromPoolAddress).permit(
            msg.sender,
            address(this),
            amountIn,
            deadline,
            v,
            r,
            s
        );
    }

    function _removeLiquidity(
        address fromPoolAddress,
        uint256 incomingLP,
        bool shouldSellEntireBalance
    ) internal returns (uint256 amount0, uint256 amount1) {

        IUniswapV2Pair pair = IUniswapV2Pair(fromPoolAddress);

        require(address(pair) != address(0), "Pool Cannot be Zero Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        _pullTokens(fromPoolAddress, incomingLP, shouldSellEntireBalance);

        _approveToken(fromPoolAddress, address(sushiswapRouter), incomingLP);

        (amount0, amount1) = sushiswapRouter.removeLiquidity(
            token0,
            token1,
            incomingLP,
            1,
            1,
            address(this),
            deadline
        );
        require(amount0 > 0 && amount1 > 0, "Removed Insufficient Liquidity");
    }

    function _swapTokens(
        address fromPoolAddress,
        uint256 amount0,
        uint256 amount1,
        address toToken,
        address[] memory swapTargets,
        bytes[] memory swapData
    ) internal returns (uint256 tokensBought) {

        address token0 = IUniswapV2Pair(fromPoolAddress).token0();
        address token1 = IUniswapV2Pair(fromPoolAddress).token1();

        if (token0 == toToken) {
            tokensBought = tokensBought + amount0;
        } else {
            tokensBought =
                tokensBought +
                _fillQuote(
                    token0,
                    toToken,
                    amount0,
                    swapTargets[0],
                    swapData[0]
                );
        }

        if (token1 == toToken) {
            tokensBought = tokensBought + amount1;
        } else {
            tokensBought =
                tokensBought +
                _fillQuote(
                    token1,
                    toToken,
                    amount1,
                    swapTargets[1],
                    swapData[1]
                );
        }
    }

    function _fillQuote(
        address fromTokenAddress,
        address toToken,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) internal returns (uint256) {

        if (fromTokenAddress == wethTokenAddress && toToken == address(0)) {
            IWETH(wethTokenAddress).withdraw(amount);
            return amount;
        }

        uint256 valueToSend;
        if (fromTokenAddress == address(0)) {
            valueToSend = amount;
        } else {
            _approveToken(fromTokenAddress, swapTarget, amount);
        }

        uint256 initialBalance = _getBalance(toToken);

        require(approvedTargets[swapTarget], "Target not Authorized");
        (bool success, ) = swapTarget.call{ value: valueToSend }(swapData);
        require(success, "Error Swapping Tokens");

        uint256 finalBalance = _getBalance(toToken) - initialBalance;

        require(finalBalance > 0, "Swapped to Invalid Intermediate");

        return finalBalance;
    }

    function removeLiquidityReturn(address fromPoolAddress, uint256 liquidity)
        external
        view
        returns (
            uint256 amountA,
            uint256 amountB,
            address token0,
            address token1
        )
    {

        IUniswapV2Pair pair = IUniswapV2Pair(fromPoolAddress);
        token0 = pair.token0();
        token1 = pair.token1();

        uint256 balance0 = IERC20(token0).balanceOf(fromPoolAddress);
        uint256 balance1 = IERC20(token1).balanceOf(fromPoolAddress);

        uint256 _totalSupply = pair.totalSupply();

        amountA = (liquidity * balance0) / _totalSupply;
        amountB = (liquidity * balance1) / _totalSupply;
    }
}