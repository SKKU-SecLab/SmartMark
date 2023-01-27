

pragma solidity >=0.6.2;

interface IUniRouter {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}



pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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



pragma solidity ^0.8.0;

library AddressUpgradeable {

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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



pragma solidity ^0.8.0;



library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}



pragma solidity ^0.8.0;


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}



pragma solidity ^0.8.0;


abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}


pragma solidity ^0.8.0;








contract BewSwap is Initializable, ContextUpgradeable, ReentrancyGuardUpgradeable {


    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 public constant feePctScale = 1e6;
    uint256 public safeMinGas;

    uint256 private _feePct;

    address private _owner;
    address private _pendingOwner;

    address payable private _feeAccount;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);
    event FeePctUpdated(uint256 indexed previousFeePct, uint256 indexed newFeePct);
    event FeeAccountUpdated(address indexed previousFeeAccount, address indexed newFeeAccount);
    event FeeReceived(address indexed token, uint256 indexed amount);


    constructor() public {
    }



    function initialize(address owner, address payable feeAccount, uint256 feePct) external {

        __BewSwap_init(owner, feeAccount, feePct);
    }

    function __BewSwap_init(address owner, address payable feeAccount, uint256 feePct) internal initializer {

        __Context_init_unchained();
        __ReentrancyGuard_init_unchained();
        __BewSwap_init_unchained(owner, feeAccount, feePct);
    }

    function __BewSwap_init_unchained(address owner, address payable feeAccount, uint256 feePct) internal initializer {

        require(feePct <= feePctScale, "BewSwap: fee pct is larger than fee pct scale");
        require(owner != address(0), "BewSwap: owner is the zero address");
        require(feeAccount != address(0), "BewSwap: fee account is the zero address");

        _owner = owner;
        _feePct = feePct;
        _feeAccount = feeAccount;
        safeMinGas = 2300;

        emit OwnershipTransferred(address(0), owner);
        emit FeePctUpdated(0, feePct);
        emit FeeAccountUpdated(address(0), feeAccount);
    }


    fallback() external payable {}

    function owner() external view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "BewSwap: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "BewSwap: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _pendingOwner = newOwner;
    }

    function acceptOwnership() external {

        require(msg.sender == _pendingOwner, "BewSwap: invalid new owner");
        emit OwnershipAccepted(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }

    function feePct() external view returns (uint256) {

        return _feePct;
    }

    function updateFeePct(uint256 newFeePct) external onlyOwner {

        require(newFeePct != _feePct, "BewSwap: new fee pct is the same as the current fee pct");
        require(newFeePct <= feePctScale, "BewSwap: new fee pct should larger than fee pct scale");
        emit FeePctUpdated(_feePct, newFeePct);
        _feePct = newFeePct;
    }

    function feeAccount() external view returns (address) {

        return _feeAccount;
    }

    function updateSafeMinGas(uint256 _safeMinGas) external onlyOwner {

        require(2300 <= _safeMinGas, "BewSwap: 2300 <= _safeMinGas");
        safeMinGas = _safeMinGas;
    }

    function updateFeeAccount(address payable newFeeAccount) external onlyOwner {

        require(newFeeAccount != address(0), "BewSwap: new fee account is the zero address");
        require(newFeeAccount != _feeAccount, "BewSwap: new fee account is the same as current fee account");

        emit FeeAccountUpdated(_feeAccount, newFeeAccount);
        _feeAccount = newFeeAccount;
    }

    function swapExactTokensForTokens(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external nonReentrant {

        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOutMin, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        toToken.safeTransfer(to, remainAmount);
        if (feeAmount != 0) {
            toToken.safeTransfer(_feeAccount, feeAmount);
            emit FeeReceived(address(toToken), feeAmount);
        }
    }

    function swapTokensForExactTokens(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external nonReentrant {

        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountInMax);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);

        router.swapTokensForExactTokens(amountOut, amountInMax , path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOut, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        toToken.safeTransfer(to, remainAmount);
        if (feeAmount != 0) {
            toToken.safeTransfer( _feeAccount, feeAmount);
            emit FeeReceived(address(toToken), feeAmount);
        }

        uint256 fromTokenBalance = fromToken.balanceOf(address(this));
        if (fromTokenBalance != 0) {
            fromToken.safeTransfer(to, fromTokenBalance);
        }
    }

    function swapExactETHForTokens(
        IUniRouter router,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable nonReentrant {

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(amountOutMin, path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOutMin, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        toToken.safeTransfer(to, remainAmount);
        if (feeAmount != 0) {
            toToken.safeTransfer(_feeAccount, feeAmount);
            emit FeeReceived(address(toToken), feeAmount);
        }
    }

    function swapTokensForExactETH(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address payable to, uint deadline
    ) external nonReentrant {

        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountInMax);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);

        router.swapTokensForExactETH(amountOut, amountInMax, path, address(this), deadline);

        uint256 ethBalance = address(this).balance;
        require(ethBalance >= amountOut, "BewSwap: get less eth than expected");

        uint256 feeAmount = (ethBalance * _feePct) / feePctScale;
        uint256 remainAmount = ethBalance - feeAmount;

        _safeTransferETH(to, remainAmount);
        if (feeAmount != 0) {
            _safeTransferETH(_feeAccount, feeAmount);
            emit FeeReceived(address(0), feeAmount);
        }

        uint256 fromTokenBalance = fromToken.balanceOf(address(this));
        if (fromTokenBalance != 0) {
            fromToken.safeTransfer(to, fromTokenBalance);
        }
    }

    function swapExactTokensForETH(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address payable to,
        uint deadline
    ) external nonReentrant {

        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        fromToken.safeIncreaseAllowance(address(router), amountIn);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);

        uint256 ethBalance = address(this).balance;
        require(ethBalance >= amountOutMin, "BewSwap: get less eth than expected");

        uint256 feeAmount = (ethBalance * _feePct) / feePctScale;
        uint256 remainAmount = ethBalance - feeAmount;

        _safeTransferETH(to, remainAmount);
        if (feeAmount != 0) {
            _safeTransferETH(_feeAccount, feeAmount);
            emit FeeReceived(address(0), feeAmount);
        }
    }

    function swapETHForExactTokens(
        IUniRouter router,
        uint amountOut,
        address[] calldata path,
        address payable to,
        uint deadline
    ) external payable nonReentrant {

        router.swapETHForExactTokens{value: msg.value}(amountOut, path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOut, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        if (feeAmount != 0) {
            toToken.safeTransfer(_feeAccount, feeAmount);
            emit FeeReceived(address(0), feeAmount);
        }
        toToken.safeTransfer(to, remainAmount);

        uint256 ethBalance = address(this).balance;
        if (ethBalance != 0) {
            _safeTransferETH(to, ethBalance);
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{gas: safeMinGas, value: value}("");
        require(success, "BewSwap: transfer eth failed");
    }

    uint256[50] private __gap;
}