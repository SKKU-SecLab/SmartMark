



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
}




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



pragma solidity >=0.7.0;

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}



pragma solidity >=0.7.0;
pragma abicoder v2;

interface IUniswapV3SwapRouter is IUniswapV3SwapCallback {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


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

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}



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
}

library Path {

    using BytesLib for bytes;

    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant FEE_SIZE = 3;

    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    function hasMultiplePools(bytes memory path) internal pure returns (bool) {

        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    function numPools(bytes memory path) internal pure returns (uint256) {

        return ((path.length - ADDR_SIZE) / NEXT_OFFSET);
    }

    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {

        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    function skipToken(bytes memory path) internal pure returns (bytes memory) {

        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}




pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}




pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}




pragma solidity ^0.8.2;



abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}




pragma solidity ^0.8.0;

abstract contract UUPSUpgradeable is ERC1967Upgrade {
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}



pragma solidity >=0.5.0 <0.9.0;

interface IPancakePair {

    function token0() external returns (address);

    function token1() external returns (address);

}



pragma solidity >=0.5.0 <0.9.0;

interface IPancakeRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

}



pragma solidity ^0.8.0;





contract Owned {

    using SafeERC20 for IERC20;

    address public owner;
    address public nominatedOwner;

    function initializeOwner(address _owner) internal {

        require(owner == address(0), "Already initialized");
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

contract Converter is Owned, UUPSUpgradeable {

    using SafeERC20 for IERC20;

    address public NATIVE_TOKEN;
    string public name;
    IPancakeRouter public router;

    function implementation() external view returns (address) {

        return _getImplementation();
    }

    function initialize(address _NATIVE_TOKEN, string memory _name, address _owner, IPancakeRouter _router) virtual external {

        require(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("")), "Already initialized");
        super.initializeOwner(_owner);

        NATIVE_TOKEN = _NATIVE_TOKEN;
        name = _name;
        router = _router;
    }

    function _swap(uint256 _swapAmount, uint256 _minReceiveAmount, address _in, address _out, address _recipient) internal returns (uint256) {

        if (_swapAmount == 0) return 0;

        IERC20(_in).safeApprove(address(router), _swapAmount);

        address[] memory path;
        if (_in == NATIVE_TOKEN || _out == NATIVE_TOKEN) {
            path = new address[](2);
            path[0] = _in;
            path[1] = _out;
        } else {
            path = new address[](3);
            path[0] = _in;
            path[1] = NATIVE_TOKEN;
            path[2] = _out;
        }
        uint256[] memory amounts = router.swapExactTokensForTokens(
            _swapAmount,
            _minReceiveAmount,
            path,
            _recipient,
            block.timestamp + 60
        );

        if (_in == NATIVE_TOKEN || _out == NATIVE_TOKEN) {
            return amounts[1]; // swapped amount
        } else {
            return amounts[2];
        }
    }

    function convert(address _inTokenAddress, uint256 _amount, uint256 _convertPercentage, address _outTokenAddress, uint256 _minReceiveAmount, address _recipient) external {

        require((0 <= _convertPercentage) && (_convertPercentage <= 100), "Invalid convert percentage");

        IERC20 tokenIn = IERC20(_inTokenAddress);

        tokenIn.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 swapAmount = _amount * _convertPercentage / 100;
        _swap(swapAmount, _minReceiveAmount, _inTokenAddress, _outTokenAddress, _recipient);

        tokenIn.safeTransfer(_recipient, (_amount - swapAmount));
    }

    function _addLiquidity(
        IERC20 tokenIn,
        uint256 _amountADesired,
        uint256 _amountAMin,
        IERC20 tokenOut,
        uint256 _amountBDesired,
        uint256 _amountBMin,
        address _to
    ) internal {

        tokenIn.safeApprove(address(router), _amountADesired);
        tokenOut.safeApprove(address(router), _amountBDesired);

        router.addLiquidity(
            address(tokenIn),
            address(tokenOut),
            _amountADesired,
            _amountBDesired,
            _amountAMin, // _amountAMin
            _amountBMin, // _amountBMin
            _to,
            block.timestamp + 60
        );

        tokenIn.safeApprove(address(router), 0);
        tokenOut.safeApprove(address(router), 0);
    }

    function convertAndAddLiquidity(
        address _inTokenAddress,
        uint256 _amount,
        address _outTokenAddress,
        uint256 _minReceiveAmountSwap,
        uint256 _minInTokenAmountAddLiq,
        uint256 _minOutTokenAmountAddLiq,
        address _recipient
    ) external {

        IERC20 tokenIn = IERC20(_inTokenAddress);
        IERC20 tokenOut = IERC20(_outTokenAddress);

        tokenIn.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 swapAmount = _amount / 2;
        uint256 swappedAmount = _swap(swapAmount, _minReceiveAmountSwap, _inTokenAddress, _outTokenAddress, address(this));

        _addLiquidity(
            tokenIn,
            (_amount - swapAmount),
            _minInTokenAmountAddLiq,
            tokenOut,
            swappedAmount,
            _minOutTokenAmountAddLiq,
            _recipient
        );

        uint256 remainInBalance = tokenIn.balanceOf(address(this));
        if (remainInBalance > 0) tokenIn.safeTransfer(msg.sender, remainInBalance);
        uint256 remainOutBalance = tokenOut.balanceOf(address(this));
        if (remainOutBalance > 0) tokenOut.safeTransfer(msg.sender, remainOutBalance);
    }

    function _removeLiquidity(
        IERC20 _lp,
        IERC20 _token0,
        IERC20 _token1,
        uint256 _lpAmount,
        uint256 _minToken0Amount,
        uint256 _minToken1Amount,
        address _to
    ) internal returns (uint256, uint256) {

        _lp.safeApprove(address(router), _lpAmount);

        (uint256 amountToken0, uint256 amountToken1) = router.removeLiquidity(
            address(_token0),
            address(_token1),
            _lpAmount,
            _minToken0Amount, // _amountAMin
            _minToken1Amount, // _amountBMin
            _to,
            block.timestamp + 60
        );

        return (amountToken0, amountToken1);
    }

    function removeLiquidityAndConvert(
        IPancakePair _lp,
        uint256 _lpAmount,
        uint256 _minToken0Amount,
        uint256 _minToken1Amount,
        uint256 _token0Percentage,
        address _recipient
    ) external {

        require((0 <= _token0Percentage) && (_token0Percentage <= 100), "Invalid token0 percentage");

        IERC20 lp = IERC20(address(_lp));
        IERC20 token0 = IERC20(_lp.token0());
        IERC20 token1 = IERC20(_lp.token1());

        lp.safeTransferFrom(msg.sender, address(this), _lpAmount);
        (uint256 amountToken0, uint256 amountToken1) = _removeLiquidity(
            lp,
            token0,
            token1,
            _lpAmount,
            _minToken0Amount,
            _minToken1Amount,
            address(this)
        );

        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        if (_token0Percentage <= 50) {
            tokenIn = address(token0);
            tokenOut = address(token1);
            swapAmount = amountToken0 * (50 - _token0Percentage) / 50;
        } else {
            tokenIn = address(token1);
            tokenOut = address(token0);
            swapAmount = amountToken1 * (_token0Percentage - 50) / 50;
        }
        if (swapAmount > 0) {
            _swap(swapAmount, 0, tokenIn, tokenOut, _recipient);
        }

        uint256 remainInBalance = token0.balanceOf(address(this));
        if (remainInBalance > 0) token0.safeTransfer(_recipient, remainInBalance);
        uint256 remainOutBalance = token1.balanceOf(address(this));
        if (remainOutBalance > 0) token1.safeTransfer(_recipient, remainOutBalance);
    }


    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {}

}



pragma solidity ^0.8.0;





contract ConverterUniV3 is Converter {
    using SafeERC20 for IERC20;
    using Path for bytes;

    IUniswapV3SwapRouter public routerUniV3;

    function initialize(address _NATIVE_TOKEN, string memory _name, address _owner, IPancakeRouter _router) override external {
        revert("Not supported");
    }

    function initialize(
        address _NATIVE_TOKEN,
        string memory _name,
        address _owner,
        IPancakeRouter _router,
        IUniswapV3SwapRouter _routerUniV3
    ) external {
        require(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("")), "Already initialized");
        super.initializeOwner(_owner);

        NATIVE_TOKEN = _NATIVE_TOKEN;
        name = _name;
        router = _router;
        routerUniV3 = _routerUniV3;
    }

    function convertUniV3(
        address _inTokenAddress,
        uint256 _amount,
        uint256 _convertPercentage,
        address _outTokenAddress,
        uint256 _minReceiveAmount,
        address _recipient,
        bytes memory _path
    ) external {
        require((0 <= _convertPercentage) && (_convertPercentage <= 100), "Invalid convert percentage");

        IERC20 tokenIn = IERC20(_inTokenAddress);

        tokenIn.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 swapAmount = _amount * _convertPercentage / 100;
        uint256 swappedAmount = _convertUniV3ExactInput(
            _inTokenAddress,
            _outTokenAddress,
            _path,
            _recipient,
            swapAmount,
            _minReceiveAmount
        );

        tokenIn.safeTransfer(_recipient, (_amount - swapAmount));

        emit ConvertedUniV3(
             _inTokenAddress,
            _outTokenAddress,
            _path,
            _amount,
            swapAmount,
            swappedAmount,
            _recipient
        );
    }

    function _convertUniV3ExactInput(
        address tokenIn,
        address tokenOut,
        bytes memory path,
        address recipient,
        uint256 amountIn,
        uint256 amountOutMinimum
    ) internal returns (uint256 amount) {
        _validatePath(path, tokenIn, tokenOut);
        IERC20(tokenIn).safeApprove(address(routerUniV3), amountIn);
        return
            routerUniV3.exactInput(
                IUniswapV3SwapRouter.ExactInputParams({
                    path: path,
                    recipient: recipient,
                    deadline: block.timestamp + 60,
                    amountIn: amountIn,
                    amountOutMinimum: amountOutMinimum
                })
            );
    }

    function _validatePath(
        bytes memory _path,
        address _tokenIn,
        address _tokenOut
    ) internal pure {
        (address tokenA, address tokenB, ) = _path.decodeFirstPool();

        if (_path.hasMultiplePools()) {
            _path = _path.skipToken();
            while (_path.hasMultiplePools()) {
                _path = _path.skipToken();
            }
            (, tokenB, ) = _path.decodeFirstPool();
        }

        require(tokenA == _tokenIn, "UniswapV3: first element of path must match token in");
        require(tokenB == _tokenOut, "UniswapV3: last element of path must match token out");
    }


    event ConvertedUniV3(address tokenIn, address tokenOut, bytes path, uint256 initAmount, uint256 amountIn, uint256 amountOut, address recipient);
}