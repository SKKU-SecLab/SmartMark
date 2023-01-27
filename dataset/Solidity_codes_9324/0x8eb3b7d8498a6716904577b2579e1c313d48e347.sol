


pragma solidity ^0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity 0.7.5;

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
}


pragma solidity 0.7.5;


contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {

        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {

        return boolStorage[INITIALIZED];
    }
}


pragma solidity 0.7.5;

interface IUpgradeabilityOwnerStorage {

    function upgradeabilityOwner() external view returns (address);

}


pragma solidity 0.7.5;


contract Upgradeable {

    modifier onlyIfUpgradeabilityOwner() {

        _onlyIfUpgradeabilityOwner();
        _;
    }

    function _onlyIfUpgradeabilityOwner() internal view {

        require(msg.sender == IUpgradeabilityOwnerStorage(address(this)).upgradeabilityOwner());
    }
}



pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.7.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.7.5;

contract Sacrifice {

    constructor(address payable _recipient) payable {
        selfdestruct(_recipient);
    }
}


pragma solidity 0.7.5;


library AddressHelper {

    function safeSendValue(address payable _receiver, uint256 _value) internal {

        if (!(_receiver).send(_value)) {
            new Sacrifice{ value: _value }(_receiver);
        }
    }
}


pragma solidity 0.7.5;



contract Claimable {

    using SafeERC20 for IERC20;

    modifier validAddress(address _to) {

        require(_to != address(0));
        _;
    }

    function claimValues(address _token, address _to) internal validAddress(_to) {

        if (_token == address(0)) {
            claimNativeCoins(_to);
        } else {
            claimErc20Tokens(_token, _to);
        }
    }

    function claimNativeCoins(address _to) internal {

        uint256 value = address(this).balance;
        AddressHelper.safeSendValue(payable(_to), value);
    }

    function claimErc20Tokens(address _token, address _to) internal {

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(_to, balance);
    }
}


pragma solidity 0.7.5;


contract BridgedTokensRegistry is EternalStorage {

    event NewTokenRegistered(address indexed nativeToken, address indexed bridgedToken);

    function bridgedTokenAddress(address _nativeToken) public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _nativeToken))];
    }

    function nativeTokenAddress(address _bridgedToken) public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _bridgedToken))];
    }

    function _setTokenAddressPair(address _nativeToken, address _bridgedToken) internal {

        addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _nativeToken))] = _bridgedToken;
        addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _bridgedToken))] = _nativeToken;

        emit NewTokenRegistered(_nativeToken, _bridgedToken);
    }
}


pragma solidity 0.7.5;


contract NativeTokensRegistry is EternalStorage {

    function isBridgedTokenDeployAcknowledged(address _token) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("ackDeploy", _token))];
    }

    function _ackBridgedTokenDeploy(address _token) internal {

        if (!boolStorage[keccak256(abi.encodePacked("ackDeploy", _token))]) {
            boolStorage[keccak256(abi.encodePacked("ackDeploy", _token))] = true;
        }
    }
}


pragma solidity 0.7.5;



contract MediatorBalanceStorage is EternalStorage {

    function mediatorBalance(address _token) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("mediatorBalance", _token))];
    }

    function _setMediatorBalance(address _token, uint256 _balance) internal {

        uintStorage[keccak256(abi.encodePacked("mediatorBalance", _token))] = _balance;
    }
}


pragma solidity 0.7.5;


interface IERC677 is IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}


pragma solidity 0.7.5;

library Bytes {

    function bytesToAddress(bytes memory _bytes) internal pure returns (address addr) {

        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}


pragma solidity 0.7.5;

contract ReentrancyGuard {

    function lock() internal view returns (bool res) {

        assembly {
            res := sload(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92) // keccak256(abi.encodePacked("lock"))
        }
    }

    function setLock(bool _lock) internal {

        assembly {
            sstore(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92, _lock) // keccak256(abi.encodePacked("lock"))
        }
    }
}


pragma solidity 0.7.5;



contract Ownable is EternalStorage {

    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {

        require(msg.sender == owner());
    }

    modifier onlyRelevantSender() {

        (bool isProxy, bytes memory returnData) =
            address(this).staticcall(abi.encodeWithSelector(UPGRADEABILITY_OWNER));
        require(
            !isProxy || // covers usage without calling through storage proxy
                (returnData.length == 32 && msg.sender == abi.decode(returnData, (address))) || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    function owner() public view returns (address) {

        return addressStorage[OWNER];
    }

    function transferOwnership(address newOwner) external onlyOwner {

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}


pragma solidity 0.7.5;

interface IAMB {

    event UserRequestForAffirmation(bytes32 indexed messageId, bytes encodedData);
    event UserRequestForSignature(bytes32 indexed messageId, bytes encodedData);
    event AffirmationCompleted(
        address indexed sender,
        address indexed executor,
        bytes32 indexed messageId,
        bool status
    );
    event RelayedMessage(address indexed sender, address indexed executor, bytes32 indexed messageId, bool status);

    function messageSender() external view returns (address);


    function maxGasPerTx() external view returns (uint256);


    function transactionHash() external view returns (bytes32);


    function messageId() external view returns (bytes32);


    function messageSourceChainId() external view returns (bytes32);


    function messageCallStatus(bytes32 _messageId) external view returns (bool);


    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32);


    function failedMessageReceiver(bytes32 _messageId) external view returns (address);


    function failedMessageSender(bytes32 _messageId) external view returns (address);


    function requireToPassMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);


    function requireToConfirmMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);


    function sourceChainId() external view returns (uint256);


    function destinationChainId() external view returns (uint256);

}


pragma solidity 0.7.5;




abstract contract BasicAMBMediator is Ownable {
    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; // keccak256(abi.encodePacked("bridgeContract"))
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; // keccak256(abi.encodePacked("mediatorContract"))

    modifier onlyMediator {
        _onlyMediator();
        _;
    }

    function _onlyMediator() internal view {
        IAMB bridge = bridgeContract();
        require(msg.sender == address(bridge));
        require(bridge.messageSender() == mediatorContractOnOtherSide());
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        _setBridgeContract(_bridgeContract);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function bridgeContract() public view returns (IAMB) {
        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    function mediatorContractOnOtherSide() public view virtual returns (address) {
        return addressStorage[MEDIATOR_CONTRACT];
    }

    function _setBridgeContract(address _bridgeContract) internal {
        require(Address.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    function messageId() internal view returns (bytes32) {
        return bridgeContract().messageId();
    }

    function maxGasPerTx() internal view returns (uint256) {
        return bridgeContract().maxGasPerTx();
    }

    function _passMessage(bytes memory _data, bool _useOracleLane) internal virtual returns (bytes32);
}


pragma solidity 0.7.5;







abstract contract TokensRelayer is BasicAMBMediator, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC677;

    function onTokenTransfer(
        address _from,
        uint256 _value,
        bytes memory _data
    ) external returns (bool) {
        if (!lock()) {
            bytes memory data = new bytes(0);
            address receiver = _from;
            if (_data.length >= 20) {
                receiver = Bytes.bytesToAddress(_data);
                if (_data.length > 20) {
                    assembly {
                        let size := sub(mload(_data), 20)
                        data := add(_data, 20)
                        mstore(data, size)
                    }
                }
            }
            bridgeSpecificActionsOnTokenTransfer(msg.sender, _from, receiver, _value, data);
        }
        return true;
    }

    function relayTokens(
        IERC677 token,
        address _receiver,
        uint256 _value
    ) external {
        _relayTokens(token, _receiver, _value, new bytes(0));
    }

    function relayTokens(IERC677 token, uint256 _value) external {
        _relayTokens(token, msg.sender, _value, new bytes(0));
    }

    function relayTokensAndCall(
        IERC677 token,
        address _receiver,
        uint256 _value,
        bytes memory _data
    ) external {
        _relayTokens(token, _receiver, _value, _data);
    }

    function _relayTokens(
        IERC677 token,
        address _receiver,
        uint256 _value,
        bytes memory _data
    ) internal {
        require(!lock());

        uint256 balanceBefore = token.balanceOf(address(this));
        setLock(true);
        token.safeTransferFrom(msg.sender, address(this), _value);
        setLock(false);
        uint256 balanceDiff = token.balanceOf(address(this)).sub(balanceBefore);
        require(balanceDiff <= _value);
        bridgeSpecificActionsOnTokenTransfer(address(token), msg.sender, _receiver, balanceDiff, _data);
    }

    function bridgeSpecificActionsOnTokenTransfer(
        address _token,
        address _from,
        address _receiver,
        uint256 _value,
        bytes memory _data
    ) internal virtual;
}


pragma solidity 0.7.5;

interface VersionableBridge {

    function getBridgeInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        );


    function getBridgeMode() external pure returns (bytes4);

}


pragma solidity 0.7.5;


contract OmnibridgeInfo is VersionableBridge {

    event TokensBridgingInitiated(
        address indexed token,
        address indexed sender,
        uint256 value,
        bytes32 indexed messageId
    );
    event TokensBridged(address indexed token, address indexed recipient, uint256 value, bytes32 indexed messageId);

    function getBridgeInterfacesVersion()
        external
        pure
        override
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {

        return (3, 3, 1);
    }

    function getBridgeMode() external pure override returns (bytes4 _data) {

        return 0xb1516c26; // bytes4(keccak256(abi.encodePacked("multi-erc-to-erc-amb")))
    }
}


pragma solidity 0.7.5;




contract TokensBridgeLimits is EternalStorage, Ownable {

    using SafeMath for uint256;

    event DailyLimitChanged(address indexed token, uint256 newLimit);
    event ExecutionDailyLimitChanged(address indexed token, uint256 newLimit);

    function isTokenRegistered(address _token) public view returns (bool) {

        return minPerTx(_token) > 0;
    }

    function totalSpentPerDay(address _token, uint256 _day) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _token, _day))];
    }

    function totalExecutedPerDay(address _token, uint256 _day) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _token, _day))];
    }

    function dailyLimit(address _token) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))];
    }

    function executionDailyLimit(address _token) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))];
    }

    function maxPerTx(address _token) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("maxPerTx", _token))];
    }

    function executionMaxPerTx(address _token) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", _token))];
    }

    function minPerTx(address _token) public view returns (uint256) {

        uint256 limit = uintStorage[keccak256(abi.encodePacked("minPerTx", _token))];
        if (_token == address(0)) {
            return limit;
        }
        return limit > 0 ? 1 : 0;
    }

    function withinLimit(address _token, uint256 _amount) public view returns (bool) {

        uint256 nextLimit = totalSpentPerDay(_token, getCurrentDay()).add(_amount);
        return
            dailyLimit(address(0)) > 0 &&
            dailyLimit(_token) >= nextLimit &&
            _amount <= maxPerTx(_token) &&
            _amount >= minPerTx(_token);
    }

    function withinExecutionLimit(address _token, uint256 _amount) public view returns (bool) {

        uint256 nextLimit = totalExecutedPerDay(_token, getCurrentDay()).add(_amount);
        return
            executionDailyLimit(address(0)) > 0 &&
            executionDailyLimit(_token) >= nextLimit &&
            _amount <= executionMaxPerTx(_token);
    }

    function getCurrentDay() public view returns (uint256) {

        return block.timestamp / 1 days;
    }

    function setDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {

        require(isTokenRegistered(_token));
        require(_dailyLimit > maxPerTx(_token) || _dailyLimit == 0);
        uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))] = _dailyLimit;
        emit DailyLimitChanged(_token, _dailyLimit);
    }

    function setExecutionDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {

        require(isTokenRegistered(_token));
        require(_dailyLimit > executionMaxPerTx(_token) || _dailyLimit == 0);
        uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))] = _dailyLimit;
        emit ExecutionDailyLimitChanged(_token, _dailyLimit);
    }

    function setExecutionMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {

        require(isTokenRegistered(_token));
        require(_maxPerTx == 0 || (_maxPerTx > 0 && _maxPerTx < executionDailyLimit(_token)));
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", _token))] = _maxPerTx;
    }

    function setMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {

        require(isTokenRegistered(_token));
        require(_maxPerTx == 0 || (_maxPerTx > minPerTx(_token) && _maxPerTx < dailyLimit(_token)));
        uintStorage[keccak256(abi.encodePacked("maxPerTx", _token))] = _maxPerTx;
    }

    function setMinPerTx(address _token, uint256 _minPerTx) external onlyOwner {

        require(isTokenRegistered(_token));
        require(_minPerTx > 0 && _minPerTx < dailyLimit(_token) && _minPerTx < maxPerTx(_token));
        uintStorage[keccak256(abi.encodePacked("minPerTx", _token))] = _minPerTx;
    }

    function maxAvailablePerTx(address _token) public view returns (uint256) {

        uint256 _maxPerTx = maxPerTx(_token);
        uint256 _dailyLimit = dailyLimit(_token);
        uint256 _spent = totalSpentPerDay(_token, getCurrentDay());
        uint256 _remainingOutOfDaily = _dailyLimit > _spent ? _dailyLimit - _spent : 0;
        return _maxPerTx < _remainingOutOfDaily ? _maxPerTx : _remainingOutOfDaily;
    }

    function addTotalSpentPerDay(
        address _token,
        uint256 _day,
        uint256 _value
    ) internal {

        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _token, _day))] = totalSpentPerDay(_token, _day).add(
            _value
        );
    }

    function addTotalExecutedPerDay(
        address _token,
        uint256 _day,
        uint256 _value
    ) internal {

        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _token, _day))] = totalExecutedPerDay(
            _token,
            _day
        )
            .add(_value);
    }

    function _setLimits(address _token, uint256[3] memory _limits) internal {

        require(
            _limits[2] > 0 && // minPerTx > 0
                _limits[1] > _limits[2] && // maxPerTx > minPerTx
                _limits[0] > _limits[1] // dailyLimit > maxPerTx
        );

        uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))] = _limits[0];
        uintStorage[keccak256(abi.encodePacked("maxPerTx", _token))] = _limits[1];
        uintStorage[keccak256(abi.encodePacked("minPerTx", _token))] = _limits[2];

        emit DailyLimitChanged(_token, _limits[0]);
    }

    function _setExecutionLimits(address _token, uint256[2] memory _limits) internal {

        require(_limits[1] < _limits[0]); // foreignMaxPerTx < foreignDailyLimit

        uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))] = _limits[0];
        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx", _token))] = _limits[1];

        emit ExecutionDailyLimitChanged(_token, _limits[0]);
    }

    function _initializeTokenBridgeLimits(address _token, uint256 _decimals) internal {

        uint256 factor;
        if (_decimals < 18) {
            factor = 10**(18 - _decimals);

            uint256 _minPerTx = minPerTx(address(0)).div(factor);
            uint256 _maxPerTx = maxPerTx(address(0)).div(factor);
            uint256 _dailyLimit = dailyLimit(address(0)).div(factor);
            uint256 _executionMaxPerTx = executionMaxPerTx(address(0)).div(factor);
            uint256 _executionDailyLimit = executionDailyLimit(address(0)).div(factor);

            if (_minPerTx == 0) {
                _minPerTx = 1;
                if (_maxPerTx <= _minPerTx) {
                    _maxPerTx = 100;
                    _executionMaxPerTx = 100;
                    if (_dailyLimit <= _maxPerTx || _executionDailyLimit <= _executionMaxPerTx) {
                        _dailyLimit = 10000;
                        _executionDailyLimit = 10000;
                    }
                }
            }
            _setLimits(_token, [_dailyLimit, _maxPerTx, _minPerTx]);
            _setExecutionLimits(_token, [_executionDailyLimit, _executionMaxPerTx]);
        } else {
            factor = 10**(_decimals - 18);
            _setLimits(
                _token,
                [dailyLimit(address(0)).mul(factor), maxPerTx(address(0)).mul(factor), minPerTx(address(0)).mul(factor)]
            );
            _setExecutionLimits(
                _token,
                [executionDailyLimit(address(0)).mul(factor), executionMaxPerTx(address(0)).mul(factor)]
            );
        }
    }
}


pragma solidity 0.7.5;


abstract contract BridgeOperationsStorage is EternalStorage {
    function setMessageToken(bytes32 _messageId, address _token) internal {
        addressStorage[keccak256(abi.encodePacked("messageToken", _messageId))] = _token;
    }

    function messageToken(bytes32 _messageId) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageToken", _messageId))];
    }

    function setMessageValue(bytes32 _messageId, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))] = _value;
    }

    function messageValue(bytes32 _messageId) internal view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))];
    }

    function setMessageRecipient(bytes32 _messageId, address _recipient) internal {
        addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))] = _recipient;
    }

    function messageRecipient(bytes32 _messageId) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))];
    }
}


pragma solidity 0.7.5;



abstract contract FailedMessagesProcessor is BasicAMBMediator, BridgeOperationsStorage {
    event FailedMessageFixed(bytes32 indexed messageId, address token, address recipient, uint256 value);

    function requestFailedMessageFix(bytes32 _messageId) external {
        IAMB bridge = bridgeContract();
        require(!bridge.messageCallStatus(_messageId));
        require(bridge.failedMessageReceiver(_messageId) == address(this));
        require(bridge.failedMessageSender(_messageId) == mediatorContractOnOtherSide());

        bytes4 methodSelector = this.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _messageId);
        _passMessage(data, true);
    }

    function fixFailedMessage(bytes32 _messageId) public onlyMediator {
        require(!messageFixed(_messageId));

        address token = messageToken(_messageId);
        address recipient = messageRecipient(_messageId);
        uint256 value = messageValue(_messageId);
        setMessageFixed(_messageId);
        executeActionOnFixedTokens(token, recipient, value);
        emit FailedMessageFixed(_messageId, token, recipient, value);
    }

    function messageFixed(bytes32 _messageId) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))];
    }

    function setMessageFixed(bytes32 _messageId) internal {
        boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))] = true;
    }

    function executeActionOnFixedTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) internal virtual;
}


pragma solidity 0.7.5;

abstract contract Proxy {
    function implementation() public view virtual returns (address);

    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            mstore(0x40, add(ptr, returndatasize()))
            returndatacopy(ptr, 0, returndatasize())

            switch result
                case 0 {
                    revert(ptr, returndatasize())
                }
                default {
                    return(ptr, returndatasize())
                }
        }
    }
}


pragma solidity 0.7.5;


interface IPermittableTokenVersion {

    function version() external pure returns (string memory);

}

contract TokenProxy is Proxy {

    string internal name;
    string internal symbol;
    uint8 internal decimals;
    mapping(address => uint256) internal balances;
    uint256 internal totalSupply;
    mapping(address => mapping(address => uint256)) internal allowed;
    address internal owner;
    bool internal mintingFinished;
    address internal bridgeContractAddr;
    bytes32 internal DOMAIN_SEPARATOR;
    mapping(address => uint256) internal nonces;
    mapping(address => mapping(address => uint256)) internal expirations;

    constructor(
        address _tokenImage,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _chainId,
        address _owner
    ) {
        string memory version = IPermittableTokenVersion(_tokenImage).version();

        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _tokenImage)
        }
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = _owner; // _owner == HomeOmnibridge/ForeignOmnibridge mediator
        bridgeContractAddr = _owner;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
    }

    function implementation() public view override returns (address impl) {

        assembly {
            impl := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
    }

    function getTokenProxyInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {

        return (1, 0, 0);
    }
}


pragma solidity 0.7.5;


contract OwnableModule {

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        owner = _newOwner;
    }
}


pragma solidity 0.7.5;



contract TokenFactory is OwnableModule {

    address public tokenImage;

    constructor(address _owner, address _tokenImage) OwnableModule(_owner) {
        tokenImage = _tokenImage;
    }

    function getModuleInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {

        return (1, 0, 0);
    }

    function setTokenImage(address _tokenImage) external onlyOwner {

        require(Address.isContract(_tokenImage));
        tokenImage = _tokenImage;
    }

    function deploy(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _chainId
    ) external returns (address) {

        return address(new TokenProxy(tokenImage, _name, _symbol, _decimals, _chainId, msg.sender));
    }
}


pragma solidity 0.7.5;




contract TokenFactoryConnector is Ownable {

    bytes32 internal constant TOKEN_FACTORY_CONTRACT =
        0x269c5905f777ee6391c7a361d17039a7d62f52ba9fffeb98c5ade342705731a3; // keccak256(abi.encodePacked("tokenFactoryContract"))

    function setTokenFactory(address _tokenFactory) external onlyOwner {

        _setTokenFactory(_tokenFactory);
    }

    function tokenFactory() public view returns (TokenFactory) {

        return TokenFactory(addressStorage[TOKEN_FACTORY_CONTRACT]);
    }

    function _setTokenFactory(address _tokenFactory) internal {

        require(Address.isContract(_tokenFactory));
        addressStorage[TOKEN_FACTORY_CONTRACT] = _tokenFactory;
    }
}


pragma solidity 0.7.5;


interface IBurnableMintableERC677Token is IERC677 {

    function mint(address _to, uint256 _amount) external returns (bool);


    function burn(uint256 _value) external;


    function claimTokens(address _token, address _to) external;

}


pragma solidity 0.7.5;

interface IERC20Metadata {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity 0.7.5;

interface IERC20Receiver {

    function onTokenBridged(
        address token,
        uint256 value,
        bytes calldata data
    ) external;

}


pragma solidity 0.7.5;

interface ITokenDetails {

    function name() external view;

    function NAME() external view;

    function symbol() external view;

    function SYMBOL() external view;

    function decimals() external view;

    function DECIMALS() external view;

}

library TokenReader {

    function readName(address _token) internal view returns (string memory) {

        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(ITokenDetails.name.selector));
        if (!status) {
            (status, data) = _token.staticcall(abi.encodeWithSelector(ITokenDetails.NAME.selector));
            if (!status) {
                return "";
            }
        }
        return _convertToString(data);
    }

    function readSymbol(address _token) internal view returns (string memory) {

        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(ITokenDetails.symbol.selector));
        if (!status) {
            (status, data) = _token.staticcall(abi.encodeWithSelector(ITokenDetails.SYMBOL.selector));
            if (!status) {
                return "";
            }
        }
        return _convertToString(data);
    }

    function readDecimals(address _token) internal view returns (uint8) {

        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(ITokenDetails.decimals.selector));
        if (!status) {
            (status, data) = _token.staticcall(abi.encodeWithSelector(ITokenDetails.DECIMALS.selector));
            if (!status) {
                return 0;
            }
        }
        return abi.decode(data, (uint8));
    }

    function _convertToString(bytes memory returnData) private pure returns (string memory) {

        if (returnData.length > 32) {
            return abi.decode(returnData, (string));
        } else if (returnData.length == 32) {
            bytes32 data = abi.decode(returnData, (bytes32));
            string memory res = new string(32);
            assembly {
                let len := 0
                mstore(add(res, 32), data) // save value in result string

                for { } gt(data, 0) { len := add(len, 1) } { // until string is empty
                    data := shl(8, data) // shift left by one symbol
                }
                mstore(res, len) // save result string length
            }
            return res;
        } else {
            return "";
        }
    }
}


pragma solidity 0.7.5;


library SafeMint {

    function safeMint(
        IBurnableMintableERC677Token _token,
        address _to,
        uint256 _value
    ) internal {

        require(_token.mint(_to, _value));
    }
}


pragma solidity 0.7.5;


















abstract contract BasicOmnibridge is
    Initializable,
    Upgradeable,
    Claimable,
    OmnibridgeInfo,
    TokensRelayer,
    FailedMessagesProcessor,
    BridgedTokensRegistry,
    NativeTokensRegistry,
    MediatorBalanceStorage,
    TokenFactoryConnector,
    TokensBridgeLimits
{
    using SafeERC20 for IERC677;
    using SafeMint for IBurnableMintableERC677Token;
    using SafeMath for uint256;

    uint256 private immutable SUFFIX_SIZE;
    bytes32 private immutable SUFFIX;

    constructor(string memory _suffix) {
        require(bytes(_suffix).length <= 32);
        bytes32 suffix;
        assembly {
            suffix := mload(add(_suffix, 32))
        }
        SUFFIX = suffix;
        SUFFIX_SIZE = bytes(_suffix).length;
    }

    function deployAndHandleBridgedTokens(
        address _token,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        address _recipient,
        uint256 _value
    ) external onlyMediator {
        address bridgedToken = _getBridgedTokenOrDeploy(_token, _name, _symbol, _decimals);

        _handleTokens(bridgedToken, false, _recipient, _value);
    }

    function deployAndHandleBridgedTokensAndCall(
        address _token,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        address _recipient,
        uint256 _value,
        bytes calldata _data
    ) external onlyMediator {
        address bridgedToken = _getBridgedTokenOrDeploy(_token, _name, _symbol, _decimals);

        _handleTokens(bridgedToken, false, _recipient, _value);

        _receiverCallback(_recipient, bridgedToken, _value, _data);
    }

    function handleBridgedTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) external onlyMediator {
        address token = bridgedTokenAddress(_token);

        require(isTokenRegistered(token));

        _handleTokens(token, false, _recipient, _value);
    }

    function handleBridgedTokensAndCall(
        address _token,
        address _recipient,
        uint256 _value,
        bytes memory _data
    ) external onlyMediator {
        address token = bridgedTokenAddress(_token);

        require(isTokenRegistered(token));

        _handleTokens(token, false, _recipient, _value);

        _receiverCallback(_recipient, token, _value, _data);
    }

    function handleNativeTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) external onlyMediator {
        _ackBridgedTokenDeploy(_token);

        _handleTokens(_token, true, _recipient, _value);
    }

    function handleNativeTokensAndCall(
        address _token,
        address _recipient,
        uint256 _value,
        bytes memory _data
    ) external onlyMediator {
        _ackBridgedTokenDeploy(_token);

        _handleTokens(_token, true, _recipient, _value);

        _receiverCallback(_recipient, _token, _value, _data);
    }

    function isRegisteredAsNativeToken(address _token) public view returns (bool) {
        return isTokenRegistered(_token) && nativeTokenAddress(_token) == address(0);
    }

    function executeActionOnFixedTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) internal override {
        _releaseTokens(nativeTokenAddress(_token) == address(0), _token, _recipient, _value, _value);
    }

    function setCustomTokenAddressPair(address _nativeToken, address _bridgedToken) external onlyOwner {
        require(!isTokenRegistered(_bridgedToken));
        require(nativeTokenAddress(_bridgedToken) == address(0));
        require(bridgedTokenAddress(_nativeToken) == address(0));

        IBurnableMintableERC677Token(_bridgedToken).safeMint(address(this), 1);
        IBurnableMintableERC677Token(_bridgedToken).burn(1);

        _setTokenAddressPair(_nativeToken, _bridgedToken);
    }

    function fixMediatorBalance(address _token, address _receiver)
        external
        onlyIfUpgradeabilityOwner
        validAddress(_receiver)
    {
        require(isRegisteredAsNativeToken(_token));

        uint256 diff = _unaccountedBalance(_token);
        require(diff > 0);
        uint256 available = maxAvailablePerTx(_token);
        require(available > 0);
        if (diff > available) {
            diff = available;
        }
        addTotalSpentPerDay(_token, getCurrentDay(), diff);

        bytes memory data = _prepareMessage(address(0), _token, _receiver, diff, new bytes(0));
        bytes32 _messageId = _passMessage(data, true);
        _recordBridgeOperation(_messageId, _token, _receiver, diff);
    }

    function claimTokens(address _token, address _to) external onlyIfUpgradeabilityOwner {
        require(_token == address(0) || !isTokenRegistered(_token));
        claimValues(_token, _to);
    }

    function claimTokensFromTokenContract(
        address _bridgedToken,
        address _token,
        address _to
    ) external onlyIfUpgradeabilityOwner {
        IBurnableMintableERC677Token(_bridgedToken).claimTokens(_token, _to);
    }

    function _recordBridgeOperation(
        bytes32 _messageId,
        address _token,
        address _sender,
        uint256 _value
    ) internal {
        setMessageToken(_messageId, _token);
        setMessageRecipient(_messageId, _sender);
        setMessageValue(_messageId, _value);

        emit TokensBridgingInitiated(_token, _sender, _value, _messageId);
    }

    function _prepareMessage(
        address _nativeToken,
        address _token,
        address _receiver,
        uint256 _value,
        bytes memory _data
    ) internal returns (bytes memory) {
        bool withData = _data.length > 0 || msg.sig == this.relayTokensAndCall.selector;

        if (_nativeToken == address(0)) {
            _setMediatorBalance(_token, mediatorBalance(_token).add(_value));

            if (isBridgedTokenDeployAcknowledged(_token)) {
                return
                    withData
                        ? abi.encodeWithSelector(
                            this.handleBridgedTokensAndCall.selector,
                            _token,
                            _receiver,
                            _value,
                            _data
                        )
                        : abi.encodeWithSelector(this.handleBridgedTokens.selector, _token, _receiver, _value);
            }

            uint8 decimals = TokenReader.readDecimals(_token);
            string memory name = TokenReader.readName(_token);
            string memory symbol = TokenReader.readSymbol(_token);

            require(bytes(name).length > 0 || bytes(symbol).length > 0);

            return
                withData
                    ? abi.encodeWithSelector(
                        this.deployAndHandleBridgedTokensAndCall.selector,
                        _token,
                        name,
                        symbol,
                        decimals,
                        _receiver,
                        _value,
                        _data
                    )
                    : abi.encodeWithSelector(
                        this.deployAndHandleBridgedTokens.selector,
                        _token,
                        name,
                        symbol,
                        decimals,
                        _receiver,
                        _value
                    );
        }

        IBurnableMintableERC677Token(_token).burn(_value);
        return
            withData
                ? abi.encodeWithSelector(
                    this.handleNativeTokensAndCall.selector,
                    _nativeToken,
                    _receiver,
                    _value,
                    _data
                )
                : abi.encodeWithSelector(this.handleNativeTokens.selector, _nativeToken, _receiver, _value);
    }

    function _getMinterFor(address _token) internal pure virtual returns (IBurnableMintableERC677Token) {
        return IBurnableMintableERC677Token(_token);
    }

    function _releaseTokens(
        bool _isNative,
        address _token,
        address _recipient,
        uint256 _value,
        uint256 _balanceChange
    ) internal virtual {
        if (_isNative) {
            IERC677(_token).safeTransfer(_recipient, _value);
            _setMediatorBalance(_token, mediatorBalance(_token).sub(_balanceChange));
        } else {
            _getMinterFor(_token).safeMint(_recipient, _value);
        }
    }

    function _getBridgedTokenOrDeploy(
        address _token,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals
    ) internal returns (address) {
        address bridgedToken = bridgedTokenAddress(_token);
        if (bridgedToken == address(0)) {
            string memory name = _name;
            string memory symbol = _symbol;
            require(bytes(name).length > 0 || bytes(symbol).length > 0);
            if (bytes(name).length == 0) {
                name = symbol;
            } else if (bytes(symbol).length == 0) {
                symbol = name;
            }
            name = _transformName(name);
            bridgedToken = tokenFactory().deploy(name, symbol, _decimals, bridgeContract().sourceChainId());
            _setTokenAddressPair(_token, bridgedToken);
            _initializeTokenBridgeLimits(bridgedToken, _decimals);
        } else if (!isTokenRegistered(bridgedToken)) {
            require(IERC20Metadata(bridgedToken).decimals() == _decimals);
            _initializeTokenBridgeLimits(bridgedToken, _decimals);
        }
        return bridgedToken;
    }

    function _receiverCallback(
        address _recipient,
        address _token,
        uint256 _value,
        bytes memory _data
    ) internal {
        if (Address.isContract(_recipient)) {
            _recipient.call(abi.encodeWithSelector(IERC20Receiver.onTokenBridged.selector, _token, _value, _data));
        }
    }

    function _transformName(string memory _name) internal view returns (string memory) {
        string memory result = string(abi.encodePacked(_name, SUFFIX));
        uint256 size = SUFFIX_SIZE;
        assembly {
            mstore(result, add(mload(_name), size))
        }
        return result;
    }

    function _unaccountedBalance(address _token) internal view virtual returns (uint256) {
        return IERC677(_token).balanceOf(address(this)).sub(mediatorBalance(_token));
    }

    function _handleTokens(
        address _token,
        bool _isNative,
        address _recipient,
        uint256 _value
    ) internal virtual;
}


pragma solidity 0.7.5;


abstract contract GasLimitManager is BasicAMBMediator {
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; // keccak256(abi.encodePacked("requestGasLimit"))

    function setRequestGasLimit(uint256 _gasLimit) external onlyOwner {
        _setRequestGasLimit(_gasLimit);
    }

    function requestGasLimit() public view returns (uint256) {
        return uintStorage[REQUEST_GAS_LIMIT];
    }

    function _setRequestGasLimit(uint256 _gasLimit) internal {
        require(_gasLimit <= maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _gasLimit;
    }
}


pragma solidity 0.7.5;

interface IInterestReceiver {

    function onInterestReceived(address _token) external;

}


pragma solidity 0.7.5;


interface IInterestImplementation {

    event InterestEnabled(address indexed token, address xToken);
    event InterestDustUpdated(address indexed token, uint96 dust);
    event InterestReceiverUpdated(address indexed token, address receiver);
    event MinInterestPaidUpdated(address indexed token, uint256 amount);
    event PaidInterest(address indexed token, address to, uint256 value);
    event ForceDisable(address indexed token, uint256 tokensAmount, uint256 xTokensAmount, uint256 investedAmount);

    function isInterestSupported(address _token) external view returns (bool);


    function invest(address _token, uint256 _amount) external;


    function withdraw(address _token, uint256 _amount) external;


    function investedAmount(address _token) external view returns (uint256);

}


pragma solidity 0.7.5;








contract InterestConnector is Ownable, MediatorBalanceStorage {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function interestImplementation(address _token) public view returns (IInterestImplementation) {

        return IInterestImplementation(addressStorage[keccak256(abi.encodePacked("interestImpl", _token))]);
    }

    function initializeInterest(
        address _token,
        address _impl,
        uint256 _minCashThreshold
    ) external onlyOwner {

        require(address(interestImplementation(_token)) == address(0));
        _setInterestImplementation(_token, _impl);
        _setMinCashThreshold(_token, _minCashThreshold);
    }

    function setMinCashThreshold(address _token, uint256 _minCashThreshold) external onlyOwner {

        _setMinCashThreshold(_token, _minCashThreshold);
    }

    function minCashThreshold(address _token) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("minCashThreshold", _token))];
    }

    function disableInterest(address _token) external onlyOwner {

        interestImplementation(_token).withdraw(_token, uint256(-1));
        _setInterestImplementation(_token, address(0));
    }

    function invest(address _token) external {

        IInterestImplementation impl = interestImplementation(_token);
        uint256 balance = mediatorBalance(_token).sub(impl.investedAmount(_token));
        uint256 minCash = minCashThreshold(_token);

        require(balance > minCash);
        uint256 amount = balance - minCash;

        IERC20(_token).safeTransfer(address(impl), amount);
        impl.invest(_token, amount);
    }

    function _setInterestImplementation(address _token, address _impl) internal {

        require(_impl == address(0) || IInterestImplementation(_impl).isInterestSupported(_token));
        addressStorage[keccak256(abi.encodePacked("interestImpl", _token))] = _impl;
    }

    function _setMinCashThreshold(address _token, uint256 _minCashThreshold) internal {

        uintStorage[keccak256(abi.encodePacked("minCashThreshold", _token))] = _minCashThreshold;
    }
}


pragma solidity 0.7.5;





contract ForeignOmnibridge is BasicOmnibridge, GasLimitManager, InterestConnector {

    using SafeERC20 for IERC20;
    using SafeERC20 for IERC677;
    using SafeMint for IBurnableMintableERC677Token;
    using SafeMath for uint256;

    constructor(string memory _suffix) BasicOmnibridge(_suffix) {}

    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        uint256[3] calldata _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
        uint256[2] calldata _executionDailyLimitExecutionMaxPerTxArray, // [ 0 = _executionDailyLimit, 1 = _executionMaxPerTx ]
        uint256 _requestGasLimit,
        address _owner,
        address _tokenFactory
    ) external onlyRelevantSender returns (bool) {

        require(!isInitialized());

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        _setLimits(address(0), _dailyLimitMaxPerTxMinPerTxArray);
        _setExecutionLimits(address(0), _executionDailyLimitExecutionMaxPerTxArray);
        _setRequestGasLimit(_requestGasLimit);
        _setOwner(_owner);
        _setTokenFactory(_tokenFactory);

        setInitialize();

        return isInitialized();
    }

    function migrateTo_3_3_0(address _tokenFactory, address _interestImplementation) external {

        bytes32 upgradeStorage = 0xd814b1d787b8a2d93a1c320d66800a58a03ed3bf12b285ec5ec1e0e26d6550cc; // keccak256(abi.encodePacked('migrateTo_3_3_0(address,address)'))
        require(!boolStorage[upgradeStorage]);

        _setTokenFactory(_tokenFactory);

        _setRequestGasLimit(2000000);

        address token = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        uint256 minCash = 2500000 * 1000000; // 2'500'000 USDC
        _setInterestImplementation(token, _interestImplementation);
        _setMinCashThreshold(token, minCash);

        uint256 balance = mediatorBalance(token);
        require(balance > minCash);
        uint256 amount = balance - minCash;

        IERC20(token).safeTransfer(_interestImplementation, amount);
        IInterestImplementation(_interestImplementation).invest(token, amount);

        token = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        minCash = 750000  * 1000000; // 750'000 USDT
        _setInterestImplementation(token, _interestImplementation);
        _setMinCashThreshold(token, minCash);

        balance = mediatorBalance(token);
        require(balance > minCash);
        amount = balance - minCash;

        IERC20(token).safeTransfer(_interestImplementation, amount);
        IInterestImplementation(_interestImplementation).invest(token, amount);

        boolStorage[upgradeStorage] = true;
    }

    function _handleTokens(
        address _token,
        bool _isNative,
        address _recipient,
        uint256 _value
    ) internal override {

        require(!lock());

        require(withinExecutionLimit(_token, _value));
        addTotalExecutedPerDay(_token, getCurrentDay(), _value);

        _releaseTokens(_isNative, _token, _recipient, _value, _value);

        emit TokensBridged(_token, _recipient, _value, messageId());
    }

    function bridgeSpecificActionsOnTokenTransfer(
        address _token,
        address _from,
        address _receiver,
        uint256 _value,
        bytes memory _data
    ) internal virtual override {

        require(_receiver != address(0) && _receiver != mediatorContractOnOtherSide());

        if (!isTokenRegistered(_token)) {
            uint8 decimals = TokenReader.readDecimals(_token);
            _initializeTokenBridgeLimits(_token, decimals);
        }

        require(withinLimit(_token, _value));
        addTotalSpentPerDay(_token, getCurrentDay(), _value);

        bytes memory data = _prepareMessage(nativeTokenAddress(_token), _token, _receiver, _value, _data);
        bytes32 _messageId = _passMessage(data, true);
        _recordBridgeOperation(_messageId, _token, _from, _value);
    }

    function _releaseTokens(
        bool _isNative,
        address _token,
        address _recipient,
        uint256 _value,
        uint256 _balanceChange
    ) internal override {

        if (_isNative) {

            uint256 balance = mediatorBalance(_token);
            if (_token == address(0x0Ae055097C6d159879521C384F1D2123D1f195e6) && balance < _value) {
                IBurnableMintableERC677Token(_token).safeMint(address(this), _value - balance);
                balance = _value;
            }

            IInterestImplementation impl = interestImplementation(_token);
            if (address(impl) != address(0)) {
                uint256 availableBalance = balance.sub(impl.investedAmount(_token));
                if (_value > availableBalance) {
                    impl.withdraw(_token, (_value - availableBalance).add(minCashThreshold(_token)));
                }
            }

            _setMediatorBalance(_token, balance.sub(_balanceChange));
            IERC677(_token).safeTransfer(_recipient, _value);
        } else {
            _getMinterFor(_token).safeMint(_recipient, _value);
        }
    }

    function _passMessage(bytes memory _data, bool _useOracleLane) internal override returns (bytes32) {

        (_useOracleLane);

        return bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), _data, requestGasLimit());
    }

    function _unaccountedBalance(address _token) internal view override returns (uint256) {

        IInterestImplementation impl = interestImplementation(_token);
        uint256 invested = Address.isContract(address(impl)) ? impl.investedAmount(_token) : 0;
        return IERC677(_token).balanceOf(address(this)).sub(mediatorBalance(_token).sub(invested));
    }
}