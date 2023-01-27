
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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
}// GPL-3.0-only

pragma solidity 0.8.13;

library MsgDataTypes {

    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    enum TransferType {
        Null,
        LqRelay, // relay through liquidity bridge
        LqWithdraw, // withdraw from liquidity bridge
        PegMint, // mint through pegged token bridge
        PegWithdraw, // withdraw from original token vault
        PegV2Mint, // mint through pegged token bridge v2
        PegV2Withdraw // withdraw from original token vault v2
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending // transient state within a transaction
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq; // only needed for LqWithdraw (refund)
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct RouteInfo {
        address sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct MsgWithTransferExecutionParams {
        bytes message;
        TransferInfo transfer;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }

    struct BridgeTransferParams {
        bytes request;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }
}// GPL-3.0-only

pragma solidity 0.8.13;

interface IBridge {

    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;


    function relay(
        bytes calldata _relayRequest,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function transfers(bytes32 transferId) external view returns (bool);


    function withdraws(bytes32 withdrawId) external view returns (bool);


    function withdraw(
        bytes calldata _wdmsg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function verifySigs(
        bytes memory _msg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external view;

}// GPL-3.0-only

pragma solidity 0.8.13;

interface IOriginalTokenVault {

    function deposit(
        address _token,
        uint256 _amount,
        uint64 _mintChainId,
        address _mintAccount,
        uint64 _nonce
    ) external;


    function withdraw(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function records(bytes32 recordId) external view returns (bool);

}// GPL-3.0-only

pragma solidity 0.8.13;

interface IOriginalTokenVaultV2 {

    function deposit(
        address _token,
        uint256 _amount,
        uint64 _mintChainId,
        address _mintAccount,
        uint64 _nonce
    ) external returns (bytes32);


    function withdraw(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external returns (bytes32);


    function records(bytes32 recordId) external view returns (bool);

}// GPL-3.0-only

pragma solidity 0.8.13;

interface IPeggedTokenBridge {

    function burn(
        address _token,
        uint256 _amount,
        address _withdrawAccount,
        uint64 _nonce
    ) external;


    function mint(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function records(bytes32 recordId) external view returns (bool);

}// GPL-3.0-only

pragma solidity 0.8.13;

interface IPeggedTokenBridgeV2 {

    function burn(
        address _token,
        uint256 _amount,
        uint64 _toChainId,
        address _toAccount,
        uint64 _nonce
    ) external returns (bytes32);


    function burnFrom(
        address _token,
        uint256 _amount,
        uint64 _toChainId,
        address _toAccount,
        uint64 _nonce
    ) external returns (bytes32);


    function mint(
        bytes calldata _request,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external returns (bytes32);


    function records(bytes32 recordId) external view returns (bool);

}// GPL-3.0-only

pragma solidity 0.8.13;


interface IMessageBus {

    function liquidityBridge() external view returns (address);


    function pegBridge() external view returns (address);


    function pegBridgeV2() external view returns (address);


    function pegVault() external view returns (address);


    function pegVaultV2() external view returns (address);


    function calcFee(bytes calldata _message) external view returns (uint256);


    function sendMessage(
        address _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;


    function sendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable;


    function withdrawFee(
        address _account,
        uint256 _cumulativeFee,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function executeMessageWithTransfer(
        bytes calldata _message,
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;


    function executeMessageWithTransferRefund(
        bytes calldata _message, // the same message associated with the original transfer
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;


    function executeMessage(
        bytes calldata _message,
        MsgDataTypes.RouteInfo calldata _route,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

}// GPL-3.0-only

pragma solidity 0.8.13;


library MessageSenderLib {

    using SafeERC20 for IERC20;


    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal {

        IMessageBus(_messageBus).sendMessage{value: _fee}(_receiver, _dstChainId, _message);
    }

    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {

        if (_bridgeSendType == MsgDataTypes.BridgeSendType.Liquidity) {
            return
                sendMessageWithLiquidityBridgeTransfer(
                    _receiver,
                    _token,
                    _amount,
                    _dstChainId,
                    _nonce,
                    _maxSlippage,
                    _message,
                    _messageBus,
                    _fee
                );
        } else if (
            _bridgeSendType == MsgDataTypes.BridgeSendType.PegDeposit ||
            _bridgeSendType == MsgDataTypes.BridgeSendType.PegV2Deposit
        ) {
            return
                sendMessageWithPegVaultDeposit(
                    _bridgeSendType,
                    _receiver,
                    _token,
                    _amount,
                    _dstChainId,
                    _nonce,
                    _message,
                    _messageBus,
                    _fee
                );
        } else if (
            _bridgeSendType == MsgDataTypes.BridgeSendType.PegBurn ||
            _bridgeSendType == MsgDataTypes.BridgeSendType.PegV2Burn ||
            _bridgeSendType == MsgDataTypes.BridgeSendType.PegV2BurnFrom
        ) {
            return
                sendMessageWithPegBridgeBurn(
                    _bridgeSendType,
                    _receiver,
                    _token,
                    _amount,
                    _dstChainId,
                    _nonce,
                    _message,
                    _messageBus,
                    _fee
                );
        } else {
            revert("bridge type not supported");
        }
    }

    function sendMessageWithLiquidityBridgeTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {

        address bridge = IMessageBus(_messageBus).liquidityBridge();
        IERC20(_token).safeIncreaseAllowance(bridge, _amount);
        IBridge(bridge).send(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
        bytes32 transferId = keccak256(
            abi.encodePacked(address(this), _receiver, _token, _amount, _dstChainId, _nonce, uint64(block.chainid))
        );
        if (_message.length > 0) {
            IMessageBus(_messageBus).sendMessageWithTransfer{value: _fee}(
                _receiver,
                _dstChainId,
                bridge,
                transferId,
                _message
            );
        }
        return transferId;
    }

    function sendMessageWithPegVaultDeposit(
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {

        address pegVault;
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegDeposit) {
            pegVault = IMessageBus(_messageBus).pegVault();
        } else {
            pegVault = IMessageBus(_messageBus).pegVaultV2();
        }
        IERC20(_token).safeIncreaseAllowance(pegVault, _amount);
        bytes32 transferId;
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegDeposit) {
            IOriginalTokenVault(pegVault).deposit(_token, _amount, _dstChainId, _receiver, _nonce);
            transferId = keccak256(
                abi.encodePacked(address(this), _token, _amount, _dstChainId, _receiver, _nonce, uint64(block.chainid))
            );
        } else {
            transferId = IOriginalTokenVaultV2(pegVault).deposit(_token, _amount, _dstChainId, _receiver, _nonce);
        }
        if (_message.length > 0) {
            IMessageBus(_messageBus).sendMessageWithTransfer{value: _fee}(
                _receiver,
                _dstChainId,
                pegVault,
                transferId,
                _message
            );
        }
        return transferId;
    }

    function sendMessageWithPegBridgeBurn(
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {

        address pegBridge;
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegBurn) {
            pegBridge = IMessageBus(_messageBus).pegBridge();
        } else {
            pegBridge = IMessageBus(_messageBus).pegBridgeV2();
        }
        IERC20(_token).safeIncreaseAllowance(pegBridge, _amount);
        bytes32 transferId;
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegBurn) {
            IPeggedTokenBridge(pegBridge).burn(_token, _amount, _receiver, _nonce);
            transferId = keccak256(
                abi.encodePacked(address(this), _token, _amount, _receiver, _nonce, uint64(block.chainid))
            );
        } else if (_bridgeSendType == MsgDataTypes.BridgeSendType.PegV2Burn) {
            transferId = IPeggedTokenBridgeV2(pegBridge).burn(_token, _amount, _dstChainId, _receiver, _nonce);
        } else {
            transferId = IPeggedTokenBridgeV2(pegBridge).burnFrom(_token, _amount, _dstChainId, _receiver, _nonce);
        }
        IERC20(_token).safeApprove(pegBridge, 0);
        if (_message.length > 0) {
            IMessageBus(_messageBus).sendMessageWithTransfer{value: _fee}(
                _receiver,
                _dstChainId,
                pegBridge,
                transferId,
                _message
            );
        }
        return transferId;
    }
}// GPL-3.0-only

pragma solidity 0.8.13;


abstract contract MessageBusAddress is Ownable {
    event MessageBusUpdated(address messageBus);

    address public messageBus;

    function setMessageBus(address _messageBus) public onlyOwner {
        messageBus = _messageBus;
        emit MessageBusUpdated(messageBus);
    }
}// GPL-3.0-only

pragma solidity 0.8.13;



abstract contract MessageSenderApp is MessageBusAddress {
    using SafeERC20 for IERC20;


    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        uint256 _fee
    ) internal {
        MessageSenderLib.sendMessage(_receiver, _dstChainId, _message, messageBus, _fee);
    }

    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        uint256 _fee
    ) internal returns (bytes32) {
        return
            MessageSenderLib.sendMessageWithTransfer(
                _receiver,
                _token,
                _amount,
                _dstChainId,
                _nonce,
                _maxSlippage,
                _message,
                _bridgeSendType,
                messageBus,
                _fee
            );
    }

    function sendTokenTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        MsgDataTypes.BridgeSendType _bridgeSendType
    ) internal returns (bytes32) {
        return
            MessageSenderLib.sendMessageWithTransfer(
                _receiver,
                _token,
                _amount,
                _dstChainId,
                _nonce,
                _maxSlippage,
                "", // empty message, which will not trigger sendMessage
                _bridgeSendType,
                messageBus,
                0
            );
    }
}// GPL-3.0-only

pragma solidity 0.8.13;

interface IMessageReceiverApp {

    enum ExecutionStatus {
        Fail, // execution failed, finalized
        Success, // execution succeeded, finalized
        Retry // execution rejected, can retry later
    }

    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);


    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);


    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);


    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

}// GPL-3.0-only

pragma solidity 0.8.13;


abstract contract MessageReceiverApp is IMessageReceiverApp, MessageBusAddress {
    modifier onlyMessageBus() {
        require(msg.sender == messageBus, "caller is not message bus");
        _;
    }

    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}
}// GPL-3.0-only

pragma solidity 0.8.13;

interface IUniswapV2 {

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}// GPL-3.0-only

pragma solidity 0.8.13;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;

}// UNLICENSED
pragma solidity 0.8.13;

interface IMessageBusSender {

    function calcFee(bytes calldata _message) external view returns (uint256);

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

interface IRangoMessageReceiver {

    enum ProcessStatus { SUCCESS, REFUND_IN_SOURCE, REFUND_IN_DESTINATION }

    function handleRangoMessage(
        address _token,
        uint _amount,
        ProcessStatus _status,
        bytes memory _message
    ) external;

}// UNLICENSED
pragma solidity 0.8.13;



contract BaseContract is Pausable, Ownable, ReentrancyGuard {

    address payable constant NULL_ADDRESS = payable(0x0000000000000000000000000000000000000000);

    using SafeMath for uint;

    bytes32 internal constant BASE_CONTRACT_NAMESPACE = hex"4c641b369cb23edb735ebedf93a426da9d88d71734c5e7d6076697dcf08d6878";

    struct BaseContractStorage {
        address nativeWrappedAddress;
        mapping (address => bool) whitelistContracts;
        mapping (address => bool) whitelistMessagingContracts;
    }

    event SendToken(address _token, uint256 _amount, address _receiver, bool _nativeOut, bool _withdraw);
    event CrossChainMessageCalled(
        address _receiverContract,
        address _token,
        uint _amount,
        IRangoMessageReceiver.ProcessStatus _status,
        bytes _appMessage,
        bool success,
        string failReason
    );

    function addWhitelist(address _factory, bool isMessagingDApp) external onlyOwner {

        BaseContractStorage storage baseStorage = getBaseContractStorage();
        if (isMessagingDApp)
            baseStorage.whitelistMessagingContracts[_factory] = true;
        else
            baseStorage.whitelistContracts[_factory] = true;
    }

    function removeWhitelist(address _factory, bool isMessagingDApp) external onlyOwner {

        BaseContractStorage storage baseStorage = getBaseContractStorage();

        if (isMessagingDApp) {
            require(baseStorage.whitelistMessagingContracts[_factory], 'Factory not found');
            delete baseStorage.whitelistMessagingContracts[_factory];
        } else {
            require(baseStorage.whitelistContracts[_factory], 'Factory not found');
            delete baseStorage.whitelistContracts[_factory];
        }
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

        _sendToken(
            NULL_ADDRESS,
            _amount,
            msg.sender,
            true,
            false,
            new bytes(0),
            NULL_ADDRESS,
            IRangoMessageReceiver.ProcessStatus.SUCCESS
        );
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
        bool _withdraw,
        bytes memory _dAppMessage,
        address _dAppReceiverContract,
        IRangoMessageReceiver.ProcessStatus processStatus
    ) internal {

        bool thereIsAMessage = _dAppReceiverContract != NULL_ADDRESS;
        address immediateReceiver = thereIsAMessage ? _dAppReceiverContract : _receiver;
        BaseContractStorage storage baseStorage = getBaseContractStorage();
        emit SendToken(_token, _amount, immediateReceiver, _nativeOut, _withdraw);

        if (_nativeOut) {
            if (_withdraw) {
                require(_token == baseStorage.nativeWrappedAddress, "token mismatch");
                IWETH(baseStorage.nativeWrappedAddress).withdraw(_amount);
            }
            _sendNative(immediateReceiver, _amount);
        } else {
            SafeERC20.safeTransfer(IERC20(_token), immediateReceiver, _amount);
        }

        if (thereIsAMessage) {
            require(
                baseStorage.whitelistMessagingContracts[_dAppReceiverContract],
                "Third-party message handler contract not whitelisted"
            );

            address receivedToken = _nativeOut ? NULL_ADDRESS : _token;
            try IRangoMessageReceiver(_dAppReceiverContract)
                .handleRangoMessage(receivedToken, _amount, processStatus, _dAppMessage)
            {
                emit CrossChainMessageCalled(_dAppReceiverContract, receivedToken, _amount, processStatus, _dAppMessage, true, "");
            } catch Error(string memory reason) {
                emit CrossChainMessageCalled(_dAppReceiverContract, receivedToken, _amount, processStatus, _dAppMessage, false, reason);
            } catch (bytes memory lowLevelData) {
                emit CrossChainMessageCalled(_dAppReceiverContract, receivedToken, _amount, processStatus, _dAppMessage, false, _getRevertMsg(lowLevelData));
            }
        }
    }

    function _sendNative(address _receiver, uint _amount) internal {

        (bool sent, ) = _receiver.call{value: _amount}("");
        require(sent, "failed to send native");
    }

    function getBaseContractStorage() internal pure returns (BaseContractStorage storage s) {

        bytes32 namespace = BASE_CONTRACT_NAMESPACE;
        assembly {
            s.slot := namespace
        }
    }

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return 'Transaction reverted silently';

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}// UNLICENSED
pragma solidity 0.8.13;


contract RangoCBridge is IRangoCBridge, MessageSenderApp, MessageReceiverApp, BaseContract {


    address cBridgeAddress;

    constructor(address _nativeWrappedAddress) {
        BaseContractStorage storage baseStorage = getBaseContractStorage();
        baseStorage.nativeWrappedAddress = _nativeWrappedAddress;
        cBridgeAddress = NULL_ADDRESS;
        messageBus = NULL_ADDRESS;
    }

    receive() external payable { }

    event CBridgeIMStatusUpdated(bytes32 id, address token, uint256 outputAmount, OperationStatus status, address _destination);
    event CBridgeSend(address _receiver, address _token, uint256 _amount, uint64 _dstChainId, uint64 _nonce, uint32 _maxSlippage);

    enum OperationStatus {
        Created,
        Succeeded,
        RefundInSource,
        RefundInDestination,
        SwapFailedInDestination
    }

    function updateCBridgeAddress(address _address) external onlyOwner {

        cBridgeAddress = _address;
    }

    function updateCBridgeMessageBusSenderAddress(address _address) external onlyOwner {

        setMessageBus(_address);
    }

    function computeCBridgeSgnFee(RangoCBridgeModels.RangoCBridgeInterChainMessage memory imMessage) external view returns(uint) {

        bytes memory msgBytes = abi.encode(imMessage);
        return IMessageBus(messageBus).calcFee(msgBytes);
    }

    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external override whenNotPaused nonReentrant {

        require(cBridgeAddress != NULL_ADDRESS, 'cBridge address not set');
        SafeERC20.safeTransferFrom(IERC20(_token), msg.sender, address(this), _amount);
        approve(_token, cBridgeAddress, _amount);
        IBridge(cBridgeAddress).send(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
        emit CBridgeSend(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
    }

    function cBridgeIM(
        address _fromToken,
        uint _inputAmount,
        address _receiverContract, // The receiver app contract address, not recipient
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        uint _sgnFee,

        RangoCBridgeModels.RangoCBridgeInterChainMessage memory imMessage
    ) external override payable whenNotPaused nonReentrant {

        require(msg.value >= _sgnFee, 'sgnFee is bigger than the input');

        require(messageBus != NULL_ADDRESS, 'cBridge message-bus address not set');
        require(cBridgeAddress != NULL_ADDRESS, 'cBridge address not set');
        require(imMessage.dstChainId == _dstChainId, '_dstChainId and imMessage.dstChainId do not match');

        SafeERC20.safeTransferFrom(IERC20(_fromToken), msg.sender, address(this), _inputAmount);
        approve(_fromToken, cBridgeAddress, _inputAmount);

        bytes memory message = abi.encode(imMessage);

        sendMessageWithTransfer(
            _receiverContract,
            _fromToken,
            _inputAmount,
            _dstChainId,
            _nonce,
            _maxSlippage,
            message,
            MsgDataTypes.BridgeSendType.Liquidity,
            _sgnFee
        );

        bytes32 id = _computeSwapRequestId(imMessage.originalSender, uint64(block.chainid), _dstChainId, message);
        emit CBridgeIMStatusUpdated(id, _fromToken, _inputAmount, OperationStatus.Created, NULL_ADDRESS);
    }

    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {

        RangoCBridgeModels.RangoCBridgeInterChainMessage memory m = abi.decode((_message), (RangoCBridgeModels.RangoCBridgeInterChainMessage));
        if (m.bridgeNativeOut) {
            _sendToken(
                NULL_ADDRESS,
                _amount,
                m.originalSender,
                true,
                false,
                m.dAppMessage,
                m.dAppSourceContract,
                IRangoMessageReceiver.ProcessStatus.REFUND_IN_SOURCE
            );
        } else {
            _sendToken(
                _token,
                _amount,
                m.originalSender,
                false,
                false,
                m.dAppMessage,
                m.dAppSourceContract,
                IRangoMessageReceiver.ProcessStatus.REFUND_IN_SOURCE
            );
        }

        bytes32 id = _computeSwapRequestId(m.originalSender, uint64(block.chainid), m.dstChainId, _message);
        emit CBridgeIMStatusUpdated(id, _token, _amount, OperationStatus.RefundInSource, m.originalSender);

        return ExecutionStatus.Success;
    }

    function executeMessageWithTransfer(
        address, // _sender
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes memory _message,
        address // executor
    ) external payable override onlyMessageBus whenNotPaused nonReentrant returns (ExecutionStatus) {

        RangoCBridgeModels.RangoCBridgeInterChainMessage memory m = abi.decode((_message), (RangoCBridgeModels.RangoCBridgeInterChainMessage));
        BaseContractStorage storage baseStorage = getBaseContractStorage();
        require(_token == m.path[0], "bridged token must be the same as the first token in destination swap path");
        require(_token == m.fromToken, "bridged token must be the same as the requested swap token");
        if (m.bridgeNativeOut) {
            require(_token == baseStorage.nativeWrappedAddress, "_token must be WETH address");
        }

        bytes32 id = _computeSwapRequestId(m.originalSender, _srcChainId, uint64(block.chainid), _message);
        uint256 dstAmount;
        OperationStatus status = OperationStatus.Succeeded;
        address receivedToken = _token;

        if (m.path.length > 1) {
            if (m.bridgeNativeOut) {
                IWETH(baseStorage.nativeWrappedAddress).deposit{value: _amount}();
            }
            bool ok = true;
            (ok, dstAmount) = _trySwap(m, _amount);
            if (ok) {
                _sendToken(
                    m.toToken,
                    dstAmount,
                    m.recipient,
                    m.nativeOut,
                    true,
                    m.dAppMessage,
                    m.dAppDestContract,
                    IRangoMessageReceiver.ProcessStatus.SUCCESS
                );

                status = OperationStatus.Succeeded;
                receivedToken = m.nativeOut ? NULL_ADDRESS : m.toToken;
            } else {
                _sendToken(
                    _token,
                    _amount,
                    m.recipient,
                    false,
                    false,
                    m.dAppMessage,
                    m.dAppDestContract,
                    IRangoMessageReceiver.ProcessStatus.REFUND_IN_DESTINATION
                );

                dstAmount = _amount;
                status = OperationStatus.SwapFailedInDestination;
                receivedToken = _token;
            }
        } else {
            if (m.bridgeNativeOut) {
                require(m.nativeOut, "You should enable native out when m.bridgeNativeOut is true");
            }
            address sourceToken = m.bridgeNativeOut ? NULL_ADDRESS: _token;
            bool withdraw = m.bridgeNativeOut ? false : true;
            _sendToken(
                sourceToken,
                _amount,
                m.recipient,
                m.nativeOut,
                withdraw,
                m.dAppMessage,
                m.dAppDestContract,
                IRangoMessageReceiver.ProcessStatus.SUCCESS
            );
            dstAmount = _amount;
            status = OperationStatus.Succeeded;
            receivedToken = m.nativeOut ? NULL_ADDRESS : m.path[0];
        }
        emit CBridgeIMStatusUpdated(id, receivedToken, dstAmount, status, m.recipient);
        return ExecutionStatus.Success;
    }

    function executeMessageWithTransferFallback(
        address, // _sender
        address _token, // _token
        uint256 _amount, // _amount
        uint64 _srcChainId,
        bytes memory _message,
        address // executor
    ) external payable override onlyMessageBus whenNotPaused nonReentrant returns (ExecutionStatus) {

        RangoCBridgeModels.RangoCBridgeInterChainMessage memory m = abi.decode((_message), (RangoCBridgeModels.RangoCBridgeInterChainMessage));
        bytes32 id = _computeSwapRequestId(m.originalSender, _srcChainId, uint64(block.chainid), _message);
        SafeERC20.safeTransfer(IERC20(_token), m.originalSender, _amount);

        emit CBridgeIMStatusUpdated(id, _token, _amount, OperationStatus.RefundInDestination, m.originalSender);
        return ExecutionStatus.Fail;
    }

    function _computeSwapRequestId(
        address _sender,
        uint64 _srcChainId,
        uint64 _dstChainId,
        bytes memory _message
    ) private pure returns (bytes32) {

        return keccak256(abi.encodePacked(_sender, _srcChainId, _dstChainId, _message));
    }

    function _trySwap(
        RangoCBridgeModels.RangoCBridgeInterChainMessage memory _swap,
        uint256 _amount
    ) private returns (bool ok, uint256 amountOut) {

        BaseContractStorage storage baseStorage = getBaseContractStorage();
        require(baseStorage.whitelistContracts[_swap.dexAddress] == true, "Dex address is not whitelisted");
        uint256 zero;
        approve(_swap.fromToken, _swap.dexAddress, _amount);

        try
            IUniswapV2(_swap.dexAddress).swapExactTokensForTokens(
                _amount,
                _swap.amountOutMin,
                _swap.path,
                address(this),
                _swap.deadline
            )
        returns (uint256[] memory amounts) {
            return (true, amounts[amounts.length - 1]);
        } catch {
            return (false, zero);
        }
    }
}