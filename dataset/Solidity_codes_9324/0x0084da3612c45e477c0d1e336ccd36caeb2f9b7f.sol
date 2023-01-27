
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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity >=0.8.0 <0.9.0;


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

    function changeOwner(address newOwner) public onlyOwner returns (bool) {
        _owner = newOwner;
        return true;
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

pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;


abstract contract OwnableProxied is Ownable {
    address public target;
    mapping(address => bool) public initialized;

    event EventUpgrade(
        address indexed newTarget,
        address indexed oldTarget,
        address indexed admin
    );
    event EventInitialized(address indexed target);

    function upgradeTo(address _target) public virtual;
}// MIT

pragma solidity >=0.8.0 <0.9.0;


contract OwnableUpgradeable is OwnableProxied {

    address payable public proxy;
    modifier initializeOnceOnly() {

         if(!initialized[target]) {
             initialized[target] = true;
             emit EventInitialized(target);
             _;
         } else revert();
     }

    modifier onlyProxy() {

        require(msg.sender == proxy);
        _;
    }

    function upgradeTo(address) public pure override {

        assert(false);
    }


    function setProxy(address payable theAddress) public onlyOwner {

        proxy = theAddress;
    }
}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface ILPERC20 {

    function token0() external view returns (address);

    function token1() external view returns (address);

}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface ISushiV2 {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface ISushiSwapFactory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}// MIT
pragma solidity >=0.8.0 <0.9.0;


contract WrapAndUnWrapSushi is OwnableUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public WETH_TOKEN_ADDRESS; // Contract address for WETH tokens
    bool public changeRecpientIsOwner;
    address private sushiAddress;
    address private sushiFactoryAddress;
    uint256 public fee;
    uint256 public maxfee;
    mapping(address => address[]) public lpTokenAddressToPairs;
    mapping(string => address) public stablecoins;
    mapping(address => mapping(address => address[])) public presetPaths;
    event WrapSushi(address lpTokenPairAddress, uint256 amount);
    event UnWrapSushi(uint256 amount);
    event RemixUnwrap(uint256 amount);
    event RemixWrap(address lpTokenPairAddress, uint256 amount);
    ISushiV2 private sushiExchange;
    ISushiSwapFactory private factory;

    constructor() payable {}

    function initialize(
        address _weth,
        address _sushiAddress,
        address _sushiFactoryAddress
    )
        public
        initializeOnceOnly
    {

        WETH_TOKEN_ADDRESS = _weth;
        sushiAddress = _sushiAddress;
        sushiExchange = ISushiV2(sushiAddress);
        sushiFactoryAddress = _sushiFactoryAddress;
        factory = ISushiSwapFactory(sushiFactoryAddress);
        fee = 0;
        maxfee = 0;
        changeRecpientIsOwner = false;
    }

    modifier nonZeroAmount(uint256 amount) {

        require(amount > 0, "Amount specified is zero");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    function updateChangeRecipientBool(bool changeRecpientIsOwnerBool)
        external
        onlyOwner
        returns (bool)
    {

        changeRecpientIsOwner = changeRecpientIsOwnerBool;
        return true;
    }

    function updateSushiExchange(address newAddress)
        external
        onlyOwner
        returns (bool)
    {

        sushiExchange = ISushiV2(newAddress);
        sushiAddress = newAddress;
        return true;
    }

    function updateSushiSwapFactory(address newAddress)
        external
        onlyOwner
        returns (bool)
    {

        factory = ISushiSwapFactory(newAddress);
        sushiFactoryAddress = newAddress;
        return true;
    }

    function getLPTokenByPair(
        address token1,
        address token2
    )
        external
        view
        returns (address lpAddr)
    {

        address thisPairAddress = factory.getPair(token1, token2);
        return thisPairAddress;
    }

    function getUserTokenBalance(
        address userAddress,
        address tokenAddress
    )
        external
        view
        returns (uint256)
    {

        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(userAddress);
    }

    function adminEmergencyWithdrawTokens(
        address token,
        uint256 amount,
        address payable destination
    )
        public
        onlyOwner
        returns (bool)
    {

        if (address(token) == address(0x0)) {
            destination.transfer(amount);
        } else {
            IERC20 token_ = IERC20(token);
            token_.safeTransfer(destination, amount);
        }
        return true;
    }

    function setFee(uint256 newFee) public onlyOwner returns (bool) {

        require(
            newFee <= maxfee,
            "Admin cannot set the fee higher than the current maxfee"
        );
        fee = newFee;
        return true;
    }

    function setMaxFee(uint256 newMax) public onlyOwner returns (bool) {

        require(maxfee == 0, "Admin can only set max fee once and it is perm");
        maxfee = newMax;
        return true;
    }

    function swap(
        address sourceToken,
        address destinationToken,
        address[] memory path,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline
    ) private returns (uint256) {

        if (sourceToken != address(0x0)) {
            IERC20(sourceToken).safeTransferFrom(msg.sender, address(this), amount);
        }
        conductSushiSwap(sourceToken, destinationToken, path, amount, userSlippageTolerance, deadline);
        uint256 thisBalance = IERC20(destinationToken).balanceOf(address(this));
        IERC20(destinationToken).safeTransfer(msg.sender, thisBalance);
        return thisBalance;
    }

    function createWrap(
        address sourceToken,
        address[] memory destinationTokens,
        address[][] memory paths,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline,
        bool remixing
    ) private returns (address, uint256) {

        if (sourceToken == address(0x0)) {
            IWETH(WETH_TOKEN_ADDRESS).deposit{value: msg.value}();
            amount = msg.value;
        } else {
            if(!remixing) { // only transfer when not remixing
                IERC20(sourceToken).safeTransferFrom(msg.sender, address(this), amount);
            }
            
        }

        if (destinationTokens[0] == address(0x0)) {
            destinationTokens[0] = WETH_TOKEN_ADDRESS;
        }
        if (destinationTokens[1] == address(0x0)) {
            destinationTokens[1] = WETH_TOKEN_ADDRESS;
        }

        if (sourceToken != destinationTokens[0]) {
            conductSushiSwap(
                sourceToken,
                destinationTokens[0],
                paths[0],
                amount.div(2),
                userSlippageTolerance,
                deadline
            );
        }
        if (sourceToken != destinationTokens[1]) {
             conductSushiSwap(
                sourceToken,
                destinationTokens[1],
                paths[1],
                amount.div(2),
                userSlippageTolerance,
                deadline
            );
        }

        IERC20 dToken1 = IERC20(destinationTokens[0]);
        IERC20 dToken2 = IERC20(destinationTokens[1]);
        uint256 dTokenBalance1 = dToken1.balanceOf(address(this));
        uint256 dTokenBalance2 = dToken2.balanceOf(address(this));

        if (dToken1.allowance(address(this), sushiAddress) < dTokenBalance1.mul(2)) {
            dToken1.safeIncreaseAllowance(sushiAddress, dTokenBalance1.mul(3));
        }

        if (dToken2.allowance(address(this), sushiAddress) < dTokenBalance2.mul(2)) {
            dToken2.safeIncreaseAllowance(sushiAddress, dTokenBalance2.mul(3));
        }

        sushiExchange.addLiquidity(
            destinationTokens[0],
            destinationTokens[1],
            dTokenBalance1,
            dTokenBalance2,
            1,
            1,
            address(this),
            1000000000000000000000000000
        );

        address thisPairAddress =
            factory.getPair(destinationTokens[0], destinationTokens[1]);
        IERC20 lpToken = IERC20(thisPairAddress);
        uint256 thisBalance = lpToken.balanceOf(address(this));

        if (fee > 0) {
            uint256 totalFee = (thisBalance.mul(fee)).div(10000);
            if (totalFee > 0) {
                lpToken.safeTransfer(owner(), totalFee);
            }
            thisBalance = lpToken.balanceOf(address(this));
            lpToken.safeTransfer(msg.sender, thisBalance);
        } else {
            lpToken.safeTransfer(msg.sender, thisBalance);
        }

        address changeRecipient = msg.sender;
        if (changeRecpientIsOwner == true) {
            changeRecipient = owner();
        }
        if (dToken1.balanceOf(address(this)) > 0) {
            dToken1.safeTransfer(changeRecipient, dToken1.balanceOf(address(this)));
        }
        if (dToken2.balanceOf(address(this)) > 0) {
            dToken2.safeTransfer(changeRecipient, dToken2.balanceOf(address(this)));
        }
        return (thisPairAddress, thisBalance);
    }

    function wrap(
        address sourceToken,
        address[] memory destinationTokens,
        address[][] memory paths,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline
    )
        public
        payable
        returns (address, uint256)
    {

        if (destinationTokens.length == 1) {
            uint256 swapAmount = swap(sourceToken, destinationTokens[0], paths[0], amount, userSlippageTolerance, deadline);
            return (destinationTokens[0], swapAmount);
        } else {
            bool remixing = false;
            (address lpTokenPairAddress, uint256 lpTokenAmount) = createWrap(sourceToken, destinationTokens, paths, amount, userSlippageTolerance, deadline, remixing);
            emit WrapSushi(lpTokenPairAddress, lpTokenAmount);
            return (lpTokenPairAddress, lpTokenAmount);
        }
    }

    function removeWrap(
        address sourceToken,
        address destinationToken,
        address[][] memory paths,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline,
        bool remixing
    )
        private
        returns (uint256)
    {

        address originalDestinationToken = destinationToken;
      
        IERC20 sToken = IERC20(sourceToken);
        if (destinationToken == address(0x0)) {
            destinationToken = WETH_TOKEN_ADDRESS;
        }

        if (sourceToken != address(0x0)) {
            sToken.safeTransferFrom(msg.sender, address(this), amount);
        }

        ILPERC20 thisLpInfo = ILPERC20(sourceToken);
        address token0 = thisLpInfo.token0();
        address token1 = thisLpInfo.token1();

        if (sToken.allowance(address(this), sushiAddress) < amount.mul(2)) {
            sToken.safeIncreaseAllowance(sushiAddress, amount.mul(3));
        }

        sushiExchange.removeLiquidity(
            token0,
            token1,
            amount,
            0,
            0,
            address(this),
            1000000000000000000000000000
        );

        uint256 pTokenBalance = IERC20(token0).balanceOf(address(this));
        uint256 pTokenBalance2 = IERC20(token1).balanceOf(address(this));

        if (token0 != destinationToken) {
            conductSushiSwap(
                token0,
                destinationToken,
                paths[0],
                pTokenBalance,
                userSlippageTolerance,
                deadline
            );
        }

        if (token1 != destinationToken) {
            conductSushiSwap(
                token1,
                destinationToken,
                paths[1],
                pTokenBalance2,
                userSlippageTolerance,
                deadline
            );
        }

        IERC20 dToken = IERC20(destinationToken);
        uint256 destinationTokenBalance = dToken.balanceOf(address(this));
    
        if (remixing) {
            
            emit RemixUnwrap(destinationTokenBalance);
        }
        else { // we only transfer the tokens to the user when not remixing
            if (originalDestinationToken == address(0x0)) {
                IWETH(WETH_TOKEN_ADDRESS).withdraw(destinationTokenBalance);
                if (fee > 0) {
                    uint256 totalFee = (address(this).balance.mul(fee)).div(10000);
                    if (totalFee > 0) {
                        payable(owner()).transfer(totalFee);
                    }
                        payable(msg.sender).transfer(address(this).balance);
                } else {
                    payable(msg.sender).transfer(address(this).balance);
                }
            } else {
                if (fee > 0) {
                    uint256 totalFee = (destinationTokenBalance.mul(fee)).div(10000);
                    if (totalFee > 0) {
                        dToken.safeTransfer(owner(), totalFee);
                    }
                    destinationTokenBalance = dToken.balanceOf(address(this));
                    dToken.safeTransfer(msg.sender, destinationTokenBalance);
                } else {
                    dToken.safeTransfer(msg.sender, destinationTokenBalance);
                }
            }

        }
       
        return destinationTokenBalance;
    }

    function unwrap(
        address sourceToken,
        address destinationToken,
        address lpTokenPairAddress,
        address[][] calldata paths,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline
    )
        public
        payable
        returns (uint256)
    {


        if (lpTokenPairAddress == address(0x0)) {
            return swap(sourceToken, destinationToken, paths[0], amount, userSlippageTolerance, deadline);
        } else {
            bool remixing = false; //flag indicates whether we're remixing or not
            uint256 destAmount = removeWrap(lpTokenPairAddress, destinationToken, paths, amount, userSlippageTolerance, deadline, remixing);
            emit UnWrapSushi(destAmount);
            return destAmount;
        }
    }

    function remix(
        address lpTokenPairAddress,
        address unwrapOutputToken,
        address[] memory destinationTokens,
        address[][] calldata unwrapPaths,
        address[][] calldata wrapPaths,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline
    )
        public
        payable
        returns (uint256)
    {

        bool remixing = true; //flag indicates whether we're remixing or not
        uint256 destAmount = removeWrap(lpTokenPairAddress, unwrapOutputToken, unwrapPaths, amount, userSlippageTolerance, deadline, remixing);

        IERC20 dToken = IERC20(unwrapOutputToken);
        uint256 destinationTokenBalance = dToken.balanceOf(address(this));

        require(destAmount == destinationTokenBalance, "Error: Remix output balance not correct");
       
        address outputToken = unwrapOutputToken;
        address [] memory dTokens = destinationTokens;
        address [][] calldata paths = wrapPaths;
        uint256 slippageTolerance = userSlippageTolerance;
        uint256 timeout = deadline;
        bool remixingToken = true; //flag indicates whether we're remixing or not

        (address remixedLpTokenPairAddress, uint256 lpTokenAmount) = createWrap(outputToken, dTokens, paths, destinationTokenBalance, slippageTolerance, timeout, remixingToken);
                                                                
        emit RemixWrap(remixedLpTokenPairAddress, lpTokenAmount);
        return lpTokenAmount;
        
    }


    function getPriceFromSushiswap(
        address[] memory theAddresses,
        uint256 amount
    )
        public
        view
        returns (uint256[] memory amounts1)
    {

        try sushiExchange.getAmountsOut(
            amount,
            theAddresses
        ) returns (uint256[] memory amounts) {
            return amounts;
        } catch {
            uint256[] memory amounts2 = new uint256[](2);
            amounts2[0] = 0;
            amounts2[1] = 0;
            return amounts2;
        }
    }

    function getAmountOutMin(
        address[] memory theAddresses,
        uint256 amount,
        uint256 userSlippageTolerance
    )
        public
        view
        returns (uint256)
    {

        uint256[] memory assetAmounts = getPriceFromSushiswap(
            theAddresses,
            amount
        );
        require(
            userSlippageTolerance <= 100,
            "userSlippageTolerance can not be larger than 100"
        );

        uint outputTokenIndex = assetAmounts.length - 1;
        return
            SafeMath.div(
                SafeMath.mul(assetAmounts[outputTokenIndex], (100 - userSlippageTolerance)),
                100
            );
    }

    function conductSushiSwap(
        address sellToken,
        address buyToken,
        address[] memory path,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline
    )
        internal
        returns (uint256 amounts1)
    {

        if (sellToken == address(0x0) && buyToken == WETH_TOKEN_ADDRESS) {
            IWETH(buyToken).deposit{value: msg.value}();
            return amount;
        }

        if (sellToken == address(0x0)) {
            uint256 amountOutMin = getAmountOutMin(path, amount, userSlippageTolerance);
            sushiExchange.swapExactETHForTokens{value: msg.value}(
                amountOutMin,
                path,
                address(this),
                deadline
            );
        } else {
            IERC20 sToken = IERC20(sellToken);
            if (sToken.allowance(address(this), sushiAddress) < amount.mul(2)) {
                sToken.safeIncreaseAllowance(sushiAddress, amount.mul(3));
            }

            uint256[] memory amounts = conductSushiSwapT4T(
                path,
                amount,
                userSlippageTolerance,
                deadline
            );
            uint256 resultingTokens = amounts[amounts.length - 1];
            return resultingTokens;
        }
    }

    function conductSushiSwapT4T(
        address[] memory theAddresses,
        uint256 amount,
        uint256 userSlippageTolerance,
        uint256 deadline
    )
        internal
        returns (uint256[] memory amounts1)
    {

        uint256 amountOutMin = getAmountOutMin(
            theAddresses,
            amount,
            userSlippageTolerance
        );
        uint256[] memory amounts = sushiExchange.swapExactTokensForTokens(
            amount,
            amountOutMin,
            theAddresses,
            address(this),
            deadline
        );
        return amounts;
    }
}