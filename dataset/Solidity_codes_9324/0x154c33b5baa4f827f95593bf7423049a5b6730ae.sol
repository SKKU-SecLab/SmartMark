
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}// MIT

pragma solidity ^0.8.1;

library Address {

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
}// UNLICENSED
pragma solidity 0.8.13;

library RangoCBridgeModels {

    struct RangoCBridgeInterChainMessage {
        uint64 dstChainId;
        bool bridgeNativeOut;
        address dexAddress;
        address fromToken;
        address toToken;
        uint amountOutMin;
        address[] path;
        uint deadline;
        bool nativeOut;
        address originalSender;
        address recipient;

        bytes dAppMessage;
        address dAppSourceContract;
        address dAppDestContract;
    }
}// UNLICENSED
pragma solidity 0.8.13;

library RangoMultichainModels {

    enum MultichainBridgeType { OUT, OUT_UNDERLYING, OUT_NATIVE }
}// GPL-3.0-only

pragma solidity 0.8.13;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;

}// MIT
pragma solidity 0.8.13;

interface IThorchainRouter {

    function depositWithExpiry(
        address payable vault,
        address asset,
        uint amount,
        string calldata memo,
        uint expiration
    ) external payable;

}// UNLICENSED
pragma solidity 0.8.13;


contract BaseProxyContract is PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    address payable constant NULL_ADDRESS = payable(0x0000000000000000000000000000000000000000);
    uint constant MAX_FEE_PERCENT_x_10000 = 300;
    uint constant MAX_AFFILIATE_PERCENT_x_10000 = 300;

    using SafeMath for uint;

    bytes32 internal constant BASE_PROXY_CONTRACT_NAMESPACE = hex"c23df90b6466cfd0cbf4f6a578f167d2f60ed56371b4746a3c5973c8543f4fd9";

    struct BaseProxyStorage {
        address payable feeContractAddress;
        address nativeWrappedAddress;
        mapping (address => bool) whitelistContracts;
    }

    event FeeReward(address token, address wallet, uint amount);
    event AffiliateReward(address token, address wallet, uint amount);
    event CallResult(address target, bool success, bytes returnData);
    event DexOutput(address _token, uint amount);
    event SendToken(address _token, uint256 _amount, address _receiver, bool _nativeOut, bool _withdraw);

    struct Call { address payable target; bytes callData; }
    struct Result { bool success; bytes returnData; }
    struct SwapRequest {
        address fromToken;
        address toToken;
        uint amountIn;
        uint feeIn;
        uint affiliateIn;
        address payable affiliatorAddress;
    }

    function addWhitelist(address _factory) external onlyOwner {

        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        baseProxyStorage.whitelistContracts[_factory] = true;
    }

    function removeWhitelist(address _factory) external onlyOwner {

        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        require(baseProxyStorage.whitelistContracts[_factory], 'Factory not found');
        delete baseProxyStorage.whitelistContracts[_factory];
    }

    function updateFeeContractAddress(address payable _address) external onlyOwner {

        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        baseProxyStorage.feeContractAddress = _address;
    }

    function refund(address _tokenAddress, uint256 _amount) external onlyOwner {

        IERC20 ercToken = IERC20(_tokenAddress);
        uint balance = ercToken.balanceOf(address(this));
        require(balance >= _amount, 'Insufficient balance');

        SafeERC20.safeTransfer(IERC20(_tokenAddress), msg.sender, _amount);
    }

    function refundNative(uint256 _amount) external onlyOwner {

        uint balance = address(this).balance;
        require(balance >= _amount, 'Insufficient balance');

        _sendToken(NULL_ADDRESS, _amount, msg.sender, true, false);
    }

    function onChainSwaps(
        SwapRequest memory request,
        Call[] calldata calls,
        bool nativeOut
    ) external payable whenNotPaused nonReentrant returns (bytes[] memory) {

        (bytes[] memory result, uint outputAmount) = onChainSwapsInternal(request, calls);

        _sendToken(request.toToken, outputAmount, msg.sender, nativeOut, false);
        return result;
    }

    function onChainSwapsInternal(SwapRequest memory request, Call[] calldata calls) internal returns (bytes[] memory, uint) {


        IERC20 ercToken = IERC20(request.toToken);
        uint balanceBefore = request.toToken == NULL_ADDRESS
            ? address(this).balance
            : ercToken.balanceOf(address(this));

        bytes[] memory result = callSwapsAndFees(request, calls);

        uint balanceAfter = request.toToken == NULL_ADDRESS
            ? address(this).balance
            : ercToken.balanceOf(address(this));

        uint secondaryBalance;
        if (calls.length > 0) {
            require(balanceAfter - balanceBefore > 0, "No balance found after swaps");

            secondaryBalance = balanceAfter - balanceBefore;
            emit DexOutput(request.toToken, secondaryBalance);
        } else {
            secondaryBalance = balanceAfter > balanceBefore ? balanceAfter - balanceBefore : request.amountIn;
        }

        return (result, secondaryBalance);
    }

    function callSwapsAndFees(SwapRequest memory request, Call[] calldata calls) private returns (bytes[] memory) {

        bool isSourceNative = request.fromToken == NULL_ADDRESS;
        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        
        require(baseProxyStorage.feeContractAddress != NULL_ADDRESS, "Fee contract address not set");

        for(uint256 i = 0; i < calls.length; i++) {
            require(baseProxyStorage.whitelistContracts[calls[i].target], "Contact not whitelisted");
        }

        uint totalInputAmount = request.feeIn + request.affiliateIn + request.amountIn;
        if (isSourceNative)
            require(msg.value >= totalInputAmount, "Not enough ETH provided to contract");

        uint maxFee = totalInputAmount * MAX_FEE_PERCENT_x_10000 / 10000;
        uint maxAffiliate = totalInputAmount * MAX_AFFILIATE_PERCENT_x_10000 / 10000;
        require(request.feeIn <= maxFee, 'Requested fee exceeded max threshold');
        require(request.affiliateIn <= maxAffiliate, 'Requested affiliate reward exceeded max threshold');

        if (!isSourceNative) {
            for(uint256 i = 0; i < calls.length; i++) {
                approve(request.fromToken, calls[i].target, totalInputAmount);
            }
            SafeERC20.safeTransferFrom(IERC20(request.fromToken), msg.sender, address(this), totalInputAmount);
        }

        if (request.feeIn > 0) {
            _sendToken(request.fromToken, request.feeIn, baseProxyStorage.feeContractAddress, isSourceNative, false);
            emit FeeReward(request.fromToken, baseProxyStorage.feeContractAddress, request.feeIn);
        }

        if (request.affiliateIn > 0) {
            require(request.affiliatorAddress != NULL_ADDRESS, "Invalid affiliatorAddress");
            _sendToken(request.fromToken, request.affiliateIn, request.affiliatorAddress, isSourceNative, false);
            emit AffiliateReward(request.fromToken, request.affiliatorAddress, request.affiliateIn);
        }

        bytes[] memory returnData = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = isSourceNative
                ? calls[i].target.call{value: request.amountIn}(calls[i].callData)
                : calls[i].target.call(calls[i].callData);

            emit CallResult(calls[i].target, success, ret);
            require(success, string(abi.encodePacked("Call failed, index:", i)));
            returnData[i] = ret;
        }

        return returnData;
    }

    function approve(address token, address to, uint value) internal {

        SafeERC20.safeApprove(IERC20(token), to, 0);
        SafeERC20.safeIncreaseAllowance(IERC20(token), to, value);
    }

    function _sendToken(
        address _token,
        uint256 _amount,
        address _receiver,
        bool _nativeOut,
        bool _withdraw
    ) internal {

        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        emit SendToken(_token, _amount, _receiver, _nativeOut, _withdraw);

        if (_nativeOut) {
            if (_withdraw) {
                require(_token == baseProxyStorage.nativeWrappedAddress, "token mismatch");
                IWETH(baseProxyStorage.nativeWrappedAddress).withdraw(_amount);
            }
            _sendNative(_receiver, _amount);
        } else {
            SafeERC20.safeTransfer(IERC20(_token), _receiver, _amount);
        }
    }

    function _sendNative(address _receiver, uint _amount) internal {

        (bool sent, ) = _receiver.call{value: _amount}("");
        require(sent, "failed to send native");
    }


    function getBaseProxyContractStorage() internal pure returns (BaseProxyStorage storage s) {

        bytes32 namespace = BASE_PROXY_CONTRACT_NAMESPACE;
        assembly {
            s.slot := namespace
        }
    }
}// UNLICENSED
pragma solidity 0.8.13;


interface IRangoCBridge {

    function cBridgeIM(
        address _fromToken,
        uint _inputAmount,
        address _receiverContract, // The receiver app contract address, not recipient
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        uint _sgnFee,

        RangoCBridgeModels.RangoCBridgeInterChainMessage memory imMessage
    ) external payable;


    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;


}// UNLICENSED
pragma solidity 0.8.13;


contract RangoCBridgeProxy is BaseProxyContract {


    bytes32 internal constant RANGO_CBRIDGE_PROXY_NAMESPACE = hex"e9cf4febccbfad5ef15964f91cb6c48fe594747e386f28fc2b067ddf16f1ed5d";

    struct CBridgeProxyStorage {
        address rangoCBridgeAddress;
    }

    function updateRangoCBridgeAddress(address _address) external onlyOwner {

        CBridgeProxyStorage storage cbridgeProxyStorage = getCBridgeProxyStorage();
        cbridgeProxyStorage.rangoCBridgeAddress = _address;
    }

    function cBridgeSend(
        SwapRequest memory request,
        Call[] calldata calls,

        address _receiver,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external payable whenNotPaused nonReentrant {

        CBridgeProxyStorage storage cbridgeProxyStorage = getCBridgeProxyStorage();
        require(cbridgeProxyStorage.rangoCBridgeAddress != NULL_ADDRESS, 'cBridge address in Rango contract not set');

        bool isNative = request.fromToken == NULL_ADDRESS;
        uint minimumRequiredValue = isNative ? request.feeIn + request.affiliateIn + request.amountIn : 0;
        require(msg.value >= minimumRequiredValue, 'Send more ETH to cover sgnFee + input amount');

        (, uint out) = onChainSwapsInternal(request, calls);
        approve(request.toToken, cbridgeProxyStorage.rangoCBridgeAddress, out);

        IRangoCBridge(cbridgeProxyStorage.rangoCBridgeAddress)
            .send(_receiver, request.toToken, out, _dstChainId, _nonce, _maxSlippage);
    }

    function cBridgeIM(
        SwapRequest memory request,
        Call[] calldata calls,

        address _receiverContract, // The receiver app contract address, not recipient
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        uint _sgnFee,

        RangoCBridgeModels.RangoCBridgeInterChainMessage memory imMessage
    ) external payable whenNotPaused nonReentrant {

        CBridgeProxyStorage storage cbridgeProxyStorage = getCBridgeProxyStorage();
        require(cbridgeProxyStorage.rangoCBridgeAddress != NULL_ADDRESS, 'cBridge address in Rango contract not set');

        bool isNative = request.fromToken == NULL_ADDRESS;
        uint minimumRequiredValue = (isNative ? request.feeIn + request.affiliateIn + request.amountIn : 0) + _sgnFee;
        require(msg.value >= minimumRequiredValue, 'Send more ETH to cover sgnFee + input amount');

        (, uint out) = onChainSwapsInternal(request, calls);
        approve(request.toToken, cbridgeProxyStorage.rangoCBridgeAddress, out);

        IRangoCBridge(cbridgeProxyStorage.rangoCBridgeAddress).cBridgeIM{value: _sgnFee}(
            request.toToken,
            out,
            _receiverContract,
            _dstChainId,
            _nonce,
            _maxSlippage,
            _sgnFee,
            imMessage
        );
    }

    function getCBridgeProxyStorage() internal pure returns (CBridgeProxyStorage storage s) {

        bytes32 namespace = RANGO_CBRIDGE_PROXY_NAMESPACE;
        assembly {
            s.slot := namespace
        }
    }
}// UNLICENSED
pragma solidity 0.8.13;

interface IRangoThorchain {


    function swapInToThorchain(
        address token,
        uint amount,
        address tcRouter,
        address tcVault,
        string calldata thorchainMemo,
        uint expiration
    ) external payable;


}// UNLICENSED
pragma solidity 0.8.13;


contract RangoThorchainProxy is BaseProxyContract {


    bytes32 internal constant RANGO_THORCHAIN_PROXY_NAMESPACE = hex"2d408556142e9c30601bb067c0631f1a23ffac1d1598afa3da595c26103e4966";

    struct ThorchainProxyStorage {
        address rangoThorchainAddress;
    }

    function updateRangoThorchainAddress(address _address) external onlyOwner {

        ThorchainProxyStorage storage thorchainProxyStorage = getThorchainProxyStorage();
        thorchainProxyStorage.rangoThorchainAddress = _address;
    }

    function swapInToThorchain(
        SwapRequest memory request,
        Call[] calldata calls,

        address tcRouter,
        address tcVault,
        string calldata thorchainMemo,
        uint expiration
    ) external payable whenNotPaused nonReentrant {

        ThorchainProxyStorage storage thorchainProxyStorage = getThorchainProxyStorage();
        require(thorchainProxyStorage.rangoThorchainAddress != NULL_ADDRESS, 'Thorchain wrapper address in Rango contract not set');

        (, uint out) = onChainSwapsInternal(request, calls);
        uint value = 0;
        if (request.toToken != NULL_ADDRESS) {
            approve(request.toToken, thorchainProxyStorage.rangoThorchainAddress, out);
        } else {
            value = out;
        }

        IRangoThorchain(thorchainProxyStorage.rangoThorchainAddress).swapInToThorchain{value : value}(
            request.toToken,
            out,
            tcRouter,
            tcVault,
            thorchainMemo,
            expiration
        );
    }

    function getThorchainProxyStorage() internal pure returns (ThorchainProxyStorage storage s) {

        bytes32 namespace = RANGO_THORCHAIN_PROXY_NAMESPACE;
        assembly {
            s.slot := namespace
        }
    }
}// UNLICENSED
pragma solidity 0.8.13;


interface IRangoMultichain {

    function multichainBridge(
        RangoMultichainModels.MultichainBridgeType _actionType,
        address _fromToken,
        address _underlyingToken,
        uint _inputAmount,
        address multichainRouter,
        address _receiverAddress,
        uint _receiverChainID
    ) external payable;


}// UNLICENSED
pragma solidity 0.8.13;


contract RangoMultichainProxy is BaseProxyContract {


    bytes32 internal constant RANGO_MULTICHAIN_PROXY_NAMESPACE = hex"ed7d91da7fb046892c2413e11ecc409c17b784b916ff0fd3fa2d512c567da864";

    struct MultichainProxyStorage {
        address rangoMultichainAddress;
    }
    
    struct MultichainBridgeRequest {
        RangoMultichainModels.MultichainBridgeType _actionType;
        address _underlyingToken;
        address _multichainRouter;
        address _receiverAddress;
        uint _receiverChainID;
    }

    function updateRangoMultichainAddress(address _address) external onlyOwner {

        MultichainProxyStorage storage multichainProxyStorage = getMultichainProxyStorage();
        multichainProxyStorage.rangoMultichainAddress = _address;
    }

    function multichainBridge(
        SwapRequest memory request,
        Call[] calldata calls,
        MultichainBridgeRequest memory bridgeRequest
    ) external payable whenNotPaused nonReentrant {

        MultichainProxyStorage storage multichainProxyStorage = getMultichainProxyStorage();
        require(multichainProxyStorage.rangoMultichainAddress != NULL_ADDRESS, 'Multichain address in Rango contract not set');

        bool isNative = request.fromToken == NULL_ADDRESS;
        uint minimumRequiredValue = isNative ? request.feeIn + request.affiliateIn + request.amountIn : 0;
        require(msg.value >= minimumRequiredValue, 'Send more ETH to cover input amount + fee');

        (, uint out) = onChainSwapsInternal(request, calls);
        if (request.toToken != NULL_ADDRESS)
            approve(request.toToken, multichainProxyStorage.rangoMultichainAddress, out);

        uint value = request.toToken == NULL_ADDRESS ? (out > 0 ? out : request.amountIn) : 0;

        IRangoMultichain(multichainProxyStorage.rangoMultichainAddress).multichainBridge{value: value}(
            bridgeRequest._actionType,
            request.toToken,
            bridgeRequest._underlyingToken,
            out,
            bridgeRequest._multichainRouter,
            bridgeRequest._receiverAddress,
            bridgeRequest._receiverChainID
        );
    }

    function getMultichainProxyStorage() internal pure returns (MultichainProxyStorage storage s) {

        bytes32 namespace = RANGO_MULTICHAIN_PROXY_NAMESPACE;
        assembly {
            s.slot := namespace
        }
    }
}// UNLICENSED
pragma solidity 0.8.13;


contract RangoV1 is BaseProxyContract, RangoCBridgeProxy, RangoThorchainProxy, RangoMultichainProxy {


    function initialize(address _nativeWrappedAddress) public initializer {

        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        CBridgeProxyStorage storage cbridgeProxyStorage = getCBridgeProxyStorage();
        ThorchainProxyStorage storage thorchainProxyStorage = getThorchainProxyStorage();
        MultichainProxyStorage storage multichainProxyStorage = getMultichainProxyStorage();
        baseProxyStorage.nativeWrappedAddress = _nativeWrappedAddress;
        baseProxyStorage.feeContractAddress = NULL_ADDRESS;
        cbridgeProxyStorage.rangoCBridgeAddress = NULL_ADDRESS;
        thorchainProxyStorage.rangoThorchainAddress = NULL_ADDRESS;
        multichainProxyStorage.rangoMultichainAddress = NULL_ADDRESS;
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable { }
}