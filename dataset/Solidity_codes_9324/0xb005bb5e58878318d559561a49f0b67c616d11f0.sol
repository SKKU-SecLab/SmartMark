
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}//AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IERC20Basic {

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);
}//AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IUniswapV2 {

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}

interface IUniswapV3 {

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}//AGPL-3.0-or-later
pragma solidity ^0.8.0;

library BytesLib {

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {

        require(_start + 3 >= _start, "toUint24_overflow");
        require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}//AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;


contract Payroll is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using BytesLib for bytes;
    address public swapRouter;
    address public feeAddress;
    uint256 public fee;
    uint256 public constant MANTISSA = 1e18;
    uint256 public version;

    bool public isSwapV2;

    struct Payment {
        address token;
        address[] receivers;
        uint256[] amountsToTransfer;
    }

    struct SwapV2 {
        uint256 amountOut;
        uint256 amountInMax;
        address[] path;
    }

    struct SwapV3 {
        uint256 amountOut;
        uint256 amountInMax;
        bytes path;
    }

    event SwapRouterChanged(address _swapRouter, bool _isSwapV2);
    event FeeChanged(uint256 _fee);
    event UpdatedVersion(uint256 _version);
    event FeeCharged(address _erc20TokenAddress, address _feeAddress, uint256 _fees);
    event FeeAddressChanged(address _feeAddress);
    event BatchPaymentFinished(address _erc20TokenAddress, address[] _receivers, uint256[] _amountsToTransfer);
    event SwapFinished(address _tokenIn, address _tokenOut, uint256 _amountReceived);

    function initialize(
        address _swapRouter,
        bool _isSwapV2,
        address _feeAddress,
        uint256 _fee
    ) public initializer {

        __ReentrancyGuard_init();
        __Ownable_init();
        _setSwapRouter(_swapRouter, _isSwapV2);
        _setFeeAddress(_feeAddress);
        _setFee(_fee);
        _setVersion(1);
    }

    function setFee(uint256 _fee) external onlyOwner {

        _setFee(_fee);
    }

    function setVersion(uint256 _version) external onlyOwner {

        _setVersion(_version);
    }

    function _setVersion(uint256 _version) internal {

        require(_version > 0, "Payroll: Version can't be 0");
        version = _version;
        emit UpdatedVersion(_version);
    }

    function _setFee(uint256 _fee) internal {

        require(_fee < 3e16, "Payroll: Fee should be less than 3%");
        fee = _fee;
        emit FeeChanged(_fee);
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {

        _setFeeAddress(_feeAddress);
    }

    function _setFeeAddress(address _feeAddress) internal {

        require(_feeAddress != address(0), "Payroll: Fee address can't be 0");
        feeAddress = _feeAddress;
        emit FeeAddressChanged(_feeAddress);
    }

    function setSwapRouter(address _swapRouter, bool _isSwapV2) external onlyOwner {

        _setSwapRouter(_swapRouter, _isSwapV2);
    }

    function _setSwapRouter(address _swapRouter, bool _isSwapV2) internal {

        require(_swapRouter != address(0), "Payroll: Cannot set a 0 address as swapRouter");
        isSwapV2 = _isSwapV2;
        swapRouter = _swapRouter;
        emit SwapRouterChanged(_swapRouter, _isSwapV2);
    }

    function approveTokens(address[] calldata _erc20TokenOrigin) external nonReentrant {

        for (uint256 i = 0; i < _erc20TokenOrigin.length; i++) {
            TransferHelper.safeApprove(_erc20TokenOrigin[i], address(swapRouter), type(uint256).max);
        }
    }

    function performSwapV3AndPayment(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSwap,
        uint32 _deadline,
        SwapV3[] calldata _swaps,
        Payment[] calldata _payments
    ) external nonReentrant {

        require(!isSwapV2, "Payroll: Not uniswapV3");
        if (_swaps.length > 0) {
            _performSwapV3(_erc20TokenOrigin, _totalAmountToSwap, _deadline, _swaps);
        }

        _performMultiPayment(_payments);
    }

    function performSwapV3(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSwap,
        uint32 _deadline,
        SwapV3[] calldata _swaps
    ) external nonReentrant returns (uint256) {

        require(!isSwapV2, "Payroll: Not uniswapV3");
        require(_swaps.length > 0, "Payroll: Empty swaps");
        return _performSwapV3(_erc20TokenOrigin, _totalAmountToSwap, _deadline, _swaps);
    }

    function _performSwapV3(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSwap,
        uint32 _deadline,
        SwapV3[] calldata _swaps
    ) internal returns (uint256) {

        TransferHelper.safeTransferFrom(_erc20TokenOrigin, msg.sender, address(this), _totalAmountToSwap);

        uint256 totalAmountIn = 0;
        for (uint256 i = 0; i < _swaps.length; i++) {
            require(_swaps[i].path.length > 0, "Payroll: Empty path");
            uint256 amountIn = IUniswapV3(swapRouter).exactOutput(
                IUniswapV3.ExactOutputParams({
                    path: _swaps[i].path,
                    recipient: msg.sender,
                    deadline: _deadline,
                    amountOut: _swaps[i].amountOut,
                    amountInMaximum: _swaps[i].amountInMax
                })
            );
            totalAmountIn = totalAmountIn + amountIn;
            emit SwapFinished(_erc20TokenOrigin, _swaps[i].path.toAddress(0), amountIn);
        }

        uint256 leftOver = IERC20Basic(_erc20TokenOrigin).balanceOf(address(this));
        if (leftOver > 0) {
            TransferHelper.safeTransfer(_erc20TokenOrigin, msg.sender, leftOver);
        }
        return totalAmountIn;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function performSwapV2AndPayment(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSwap,
        uint32 _deadline,
        SwapV2[] calldata _swaps,
        Payment[] calldata _payments
    ) external nonReentrant {

        require(isSwapV2, "Payroll: Not uniswapV2");
        if (_swaps.length > 0) {
            _performSwapV2(_erc20TokenOrigin, _totalAmountToSwap, _deadline, _swaps);
        }

        _performMultiPayment(_payments);
    }

    function performSwapV2(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSwap,
        uint32 _deadline,
        SwapV2[] calldata _swaps
    ) external nonReentrant returns (uint256) {

        require(isSwapV2, "Payroll: Not uniswapV2");
        require(_swaps.length > 0, "Payroll: Empty swaps");
        return _performSwapV2(_erc20TokenOrigin, _totalAmountToSwap, _deadline, _swaps);
    }

    function _performSwapV2(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSwap,
        uint32 _deadline,
        SwapV2[] calldata _swaps
    ) internal returns (uint256) {

        TransferHelper.safeTransferFrom(_erc20TokenOrigin, msg.sender, address(this), _totalAmountToSwap);

        uint256 totalAmountIn = 0;
        for (uint256 i = 0; i < _swaps.length; i++) {
            require(_swaps[i].path.length > 0, "Payroll: Empty path");
            require(_swaps[i].path[0] == _erc20TokenOrigin, "Payroll: Swap not token origin");
            uint256 amountIn = IUniswapV2(swapRouter).swapTokensForExactTokens(
                _swaps[i].amountOut,
                _swaps[i].amountInMax,
                _swaps[i].path,
                msg.sender,
                _deadline
            )[0];
            totalAmountIn = totalAmountIn + amountIn;
            emit SwapFinished(_erc20TokenOrigin, _swaps[i].path[_swaps.length - 1], amountIn);
        }

        uint256 leftOver = IERC20Basic(_erc20TokenOrigin).balanceOf(address(this));
        if (leftOver > 0) {
            TransferHelper.safeTransfer(_erc20TokenOrigin, msg.sender, leftOver);
        }
        return totalAmountIn;
    }

    function performMultiPayment(Payment[] calldata _payments) external nonReentrant {

        _performMultiPayment(_payments);
    }

    function _performMultiPayment(Payment[] calldata _payments) internal {

        for (uint256 i = 0; i < _payments.length; i++) {
            _performPayment(_payments[i].token, _payments[i].receivers, _payments[i].amountsToTransfer);
        }
    }

    function _performPayment(
        address _erc20TokenAddress,
        address[] calldata _receivers,
        uint256[] calldata _amountsToTransfer
    ) internal {

        require(_erc20TokenAddress != address(0), "Payroll: Token is 0 address");
        require(_amountsToTransfer.length > 0, "Payroll: No amounts to transfer");
        require(_amountsToTransfer.length == _receivers.length, "Payroll: Arrays must have same length");

        uint256 acumulatedFee = 0;
        for (uint256 i = 0; i < _receivers.length; i++) {
            require(_receivers[i] != address(0), "Payroll: Cannot send to a 0 address");
            acumulatedFee = acumulatedFee + (_amountsToTransfer[i] * fee) / MANTISSA;
            TransferHelper.safeTransferFrom(_erc20TokenAddress, msg.sender, _receivers[i], _amountsToTransfer[i]);
        }
        emit BatchPaymentFinished(_erc20TokenAddress, _receivers, _amountsToTransfer);
        if (acumulatedFee > 0) {
            TransferHelper.safeTransferFrom(_erc20TokenAddress, msg.sender, feeAddress, acumulatedFee);
        }
        emit FeeCharged(_erc20TokenAddress, feeAddress, acumulatedFee);
    }
}