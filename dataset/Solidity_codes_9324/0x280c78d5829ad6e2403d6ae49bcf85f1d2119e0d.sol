
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}//MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface ITokensApprover {

    struct ApproveConfig {
        string name;
        string version;
        string domainType;
        string primaryType;
        string noncesMethod;
        string permitMethod;
        bytes4 permitMethodSelector;
    }

    event TokensApproverConfigAdded(uint256 indexed id);
    event TokensApproverConfigUpdated(uint256 indexed id);
    event TokensApproverTokenAdded(address indexed token, uint256 id);
    event TokensApproverTokenRemoved(address indexed token);

    function addConfig(ApproveConfig calldata config) external returns (uint256);


    function updateConfig(uint256 id, ApproveConfig calldata config) external returns (uint256);


    function setToken(uint256 id, address token) external;


    function removeToken(address token) external;


    function getConfig(address token) view external returns (ApproveConfig memory);


    function getConfigById(uint256 id) view external returns (ApproveConfig memory);


    function configsLength() view external returns (uint256);


    function hasConfigured(address token) view external returns (bool);


    function callPermit(address token, bytes calldata permitCallData) external returns (bool, bytes memory);

}//BUSL
pragma solidity 0.8.10;


abstract contract FeePayerGuard {

    event FeePayerAdded(address payer);
    event FeePayerRemoved(address payer);

    mapping(address => bool) private feePayers;

    modifier onlyFeePayer() {
        require(feePayers[msg.sender], "Unknown fee payer address");
        require(msg.sender == tx.origin, "Fee payer must be sender of transaction");
        _;
    }

    function hasFeePayer(address _feePayer) external view returns (bool) {
        return feePayers[_feePayer];
    }

    function _addFeePayer(address _feePayer) internal {
        require(_feePayer != address(0), "Invalid fee payer address");
        require(!feePayers[_feePayer], "Already fee payer");
        feePayers[_feePayer] = true;
        emit FeePayerAdded(_feePayer);
    }

    function _removeFeePayer(address _feePayer) internal {
        require(feePayers[_feePayer], "Not fee payer");
        feePayers[_feePayer] = false;
        emit FeePayerRemoved(_feePayer);
    }
}// MIT
pragma solidity 0.8.10;

abstract contract EIP712Library {
    string public constant name = 'Plasma Gas Station';
    string public constant version = '1';
    mapping(address => uint256) public nonces;

    bytes32 immutable public DOMAIN_SEPARATOR;

    bytes32 immutable public TX_REQUEST_TYPEHASH;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );

        TX_REQUEST_TYPEHASH = keccak256("TxRequest(address from,address to,uint256 gas,uint256 nonce,uint256 deadline,bytes data)");
    }

    function getNonce(address from) external view returns (uint256) {
        return nonces[from];
    }

    function _getSigner(address from, address to, uint256 gas, uint256 nonce, bytes calldata data, uint256 deadline, bytes calldata sign) internal view returns (address) {
        bytes32 digest = keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encodePacked(
                    TX_REQUEST_TYPEHASH,
                    uint256(uint160(from)),
                    uint256(uint160(to)),
                    gas,
                    nonce,
                    deadline,
                    keccak256(data)
                ))
            ));

        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(sign);
        return ecrecover(digest, v, r, s);
    }

    function _splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65, "Signature invalid length");

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := and(mload(add(signature, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Signature invalid v byte");
    }
}//BUSL
pragma solidity 0.8.10;


interface IExchange {

    function getEstimatedTokensForETH(IERC20 _token, uint256 _ethAmount) external returns (uint256);


    function swapTokensToETH(IERC20 _token, uint256 _receiveEthAmount, uint256 _tokensMaxSpendAmount, address _ethReceiver, address _tokensReceiver) external returns (uint256);

}//BUSL
pragma solidity 0.8.10;


contract GasStation is Ownable, FeePayerGuard, EIP712Library {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IExchange public exchange;
    ITokensApprover public approver;

    EnumerableSet.AddressSet private _feeTokensStore;
    uint256 public txRelayFeePercent;
    uint256 public maxPostCallGasUsage = 350000;
    mapping(address => uint256) public postCallGasUsage;
    struct TxRequest {
        address from;
        address to;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 deadline;
    }
    struct TxFee {
        address token;
        bytes approvalData;
        uint256 feePerGas;
    }

    event GasStationTxExecuted(address indexed from, address to, address feeToken, uint256 totalFeeInTokens, uint256 txRelayFeeInEth);
    event GasStationExchangeUpdated(address indexed newExchange);
    event GasStationFeeTokensStoreUpdated(address indexed newFeeTokensStore);
    event GasStationApproverUpdated(address indexed newApprover);
    event GasStationTxRelayFeePercentUpdated(uint256 newTxRelayFeePercent);
    event GasStationMaxPostCallGasUsageUpdated(uint256 newMaxPostCallGasUsage);
    event GasStationFeeTokenAdded(address feeToken);
    event GasStationFeeTokenRemoved(address feeToken);

    constructor(address _exchange, address _approver, address _feePayer, uint256 _txRelayFeePercent, address[] memory _feeTokens)  {
        _setExchange(_exchange);
        _setApprover(_approver);
        _addFeePayer(_feePayer);
        _setTxRelayFeePercent(_txRelayFeePercent);

        for (uint256 i = 0; i < _feeTokens.length; i++) {
            _addFeeToken(_feeTokens[i]);
        }
    }

    function setExchange(address _exchange) external onlyOwner {

        _setExchange(_exchange);
    }

    function setApprover(address _approver) external onlyOwner {

        require(_approver != address(0), "Invalid approver address");
        approver = ITokensApprover(_approver);
        emit GasStationApproverUpdated(address(_approver));
    }

    function addFeeToken(address _feeToken) external onlyOwner {

        _addFeeToken(_feeToken);
    }

    function removeFeeToken(address _feePayer) external onlyOwner {

        _removeFeeToken(_feePayer);
    }

    function addFeePayer(address _feePayer) external onlyOwner {

        _addFeePayer(_feePayer);
    }

    function removeFeePayer(address _feePayer) external onlyOwner {

        _removeFeePayer(_feePayer);
    }

    function setTxRelayFeePercent(uint256 _txRelayFeePercent) external onlyOwner {

        _setTxRelayFeePercent(_txRelayFeePercent);
    }

    function setMaxPostCallGasUsage(uint256 _maxPostCallGasUsage) external onlyOwner {

        maxPostCallGasUsage = _maxPostCallGasUsage;
        emit GasStationMaxPostCallGasUsageUpdated(_maxPostCallGasUsage);
    }

    function getEstimatedPostCallGas(address _token) external view returns (uint256) {

        require(_feeTokensStore.contains(_token), "Fee token not supported");
        return _getEstimatedPostCallGas(_token);
    }

    function feeTokens() external view returns (address[] memory) {

        return _feeTokensStore.values();
    }

    function sendTransaction(TxRequest calldata _tx, TxFee calldata _fee, bytes calldata _sign) external onlyFeePayer {

        uint256 initialGas = gasleft();
        address txSender = _tx.from;
        IERC20 token = IERC20(_fee.token);

        _verify(_tx, _sign);
        require(_feeTokensStore.contains(address(token)), "Fee token not supported");

        _call(txSender, _tx.to, _tx.data);

        uint256 callGasUsed = initialGas - gasleft();
        uint256 estimatedGasUsed = callGasUsed + _getEstimatedPostCallGas(address(token));
        require(estimatedGasUsed < _tx.gas, "Not enough gas");

        _permit(_fee.token, _fee.approvalData);

        (uint256 maxFeeInEth,) = _calculateCharge(_tx.gas, _fee.feePerGas);
        uint256 maxFeeInTokens = exchange.getEstimatedTokensForETH(token, maxFeeInEth);
        token.safeTransferFrom(txSender, address(exchange), maxFeeInTokens);

        (uint256 totalFeeInEth, uint256 txRelayFeeInEth) = _calculateCharge(estimatedGasUsed, _fee.feePerGas);
        uint256 spentTokens = exchange.swapTokensToETH(token, totalFeeInEth, maxFeeInTokens, msg.sender, txSender);
        emit GasStationTxExecuted(txSender, _tx.to, _fee.token, spentTokens, txRelayFeeInEth);

        _setUpEstimatedPostCallGas(_fee.token, initialGas - gasleft() - callGasUsed);
    }

    function execute(address from, address to, bytes calldata data) external onlyFeePayer {

        _call(from, to, data);
    }

    function _setExchange(address _exchange) internal {

        require(_exchange != address(0), "Invalid exchange address");
        exchange = IExchange(_exchange);
        emit GasStationExchangeUpdated(_exchange);
    }

    function _setApprover(address _approver) internal {

        require(_approver != address(0), "Invalid approver address");
        approver = ITokensApprover(_approver);
        emit GasStationApproverUpdated(address(_approver));
    }

    function _addFeeToken(address _token) internal {

        require(_token != address(0), "Invalid token address");
        require(!_feeTokensStore.contains(_token), "Already fee token");
        _feeTokensStore.add(_token);
        emit GasStationFeeTokenAdded(_token);
    }

    function _removeFeeToken(address _token) internal {

        require(_feeTokensStore.contains(_token), "not fee token");
        _feeTokensStore.remove(_token);
        emit GasStationFeeTokenRemoved(_token);
    }

    function _setTxRelayFeePercent(uint256 _txRelayFeePercent) internal {

        txRelayFeePercent = _txRelayFeePercent;
        emit GasStationTxRelayFeePercentUpdated(_txRelayFeePercent);
    }

    function _permit(address token, bytes calldata approvalData) internal {

        if (approvalData.length > 0 && approver.hasConfigured(token)) {
            (bool success,) = approver.callPermit(token, approvalData);
            require(success, "Permit Method Call Error");
        }
    }

    function _call(address from, address to, bytes calldata data) internal {

        bytes memory callData = abi.encodePacked(data, from);
        (bool success,) = to.call(callData);

        require(success, "Transaction Call Error");
    }

    function _verify(TxRequest calldata _tx, bytes calldata _sign) internal {

        require(_tx.deadline > block.timestamp, "Transaction expired");
        require(nonces[_tx.from]++ == _tx.nonce, "Nonce mismatch");

        address signer = _getSigner(_tx.from, _tx.to, _tx.gas, _tx.nonce, _tx.data, _tx.deadline, _sign);

        require(signer != address(0) && signer == _tx.from, 'Invalid signature');
    }

    function _getEstimatedPostCallGas(address _token) internal view returns (uint256) {

        return postCallGasUsage[_token] > 0 ? postCallGasUsage[_token] : maxPostCallGasUsage;
    }

    function _setUpEstimatedPostCallGas(address _token, uint256 _postCallGasUsed) internal {

        require(_postCallGasUsed < maxPostCallGasUsage, "Post call gas overspending");
        postCallGasUsage[_token] = Math.max(postCallGasUsage[_token], _postCallGasUsed);
    }

    function _calculateCharge(uint256 _gasUsed, uint256 _feePerGas) internal view returns (uint256, uint256) {

        uint256 feeForAllGas = _gasUsed * _feePerGas;
        uint256 totalFee = feeForAllGas * (txRelayFeePercent + 100) / 100;
        uint256 txRelayFee = totalFee - feeForAllGas;

        return (totalFee, txRelayFee);
    }
}