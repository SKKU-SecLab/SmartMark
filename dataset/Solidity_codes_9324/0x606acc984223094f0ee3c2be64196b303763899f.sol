
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// GPL-3.0-or-later
pragma solidity 0.8.11;


abstract contract OwnableProxyDelegation is Context {
    address private _owner;

    bytes32 internal constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    bool public initialized;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address ownerAddr) external {
        require(ownerAddr != address(0), "OPD: INVALID_ADDRESS");
        require(!initialized, "OPD: INITIALIZED");
        require(StorageSlot.getAddressSlot(_ADMIN_SLOT).value == msg.sender, "OPD: FORBIDDEN");

        _setOwner(ownerAddr);

        initialized = true;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "OPD: NOT_OWNER");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "OPD: INVALID_ADDRESS");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


interface IOperatorResolver {

    struct Operator {
        address implementation;
        bytes4 selector;
    }

    event OperatorImported(bytes32 name, Operator destination);

    function getOperator(bytes32 name) external view returns (Operator memory);


    function requireAndGetOperator(bytes32 name, string calldata reason) external view returns (Operator memory);


    function areOperatorsImported(bytes32[] calldata names, Operator[] calldata destinations)
        external
        view
        returns (bool);


    function importOperators(
        bytes32[] calldata names,
        Operator[] calldata operatorsToImport,
        MixinOperatorResolver[] calldata destinations
    ) external;

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract OperatorResolver is IOperatorResolver, Ownable {

    mapping(bytes32 => Operator) public operators;

    function getOperator(bytes32 name) external view override returns (Operator memory) {

        return operators[name];
    }

    function requireAndGetOperator(bytes32 name, string calldata reason)
        external
        view
        override
        returns (Operator memory)
    {

        Operator memory _foundOperator = operators[name];
        require(_foundOperator.implementation != address(0), reason);
        return _foundOperator;
    }

    function areOperatorsImported(bytes32[] calldata names, Operator[] calldata destinations)
        external
        view
        override
        returns (bool)
    {

        uint256 namesLength = names.length;
        require(namesLength == destinations.length, "OR: INPUTS_LENGTH_MUST_MATCH");
        for (uint256 i = 0; i < namesLength; i++) {
            if (
                operators[names[i]].implementation != destinations[i].implementation ||
                operators[names[i]].selector != destinations[i].selector
            ) {
                return false;
            }
        }
        return true;
    }

    function importOperators(
        bytes32[] calldata names,
        Operator[] calldata operatorsToImport,
        MixinOperatorResolver[] calldata destinations
    ) external override onlyOwner {

        require(names.length == operatorsToImport.length, "OR: INPUTS_LENGTH_MUST_MATCH");
        bytes32 name;
        Operator calldata destination;
        for (uint256 i = 0; i < names.length; i++) {
            name = names[i];
            destination = operatorsToImport[i];
            operators[name] = destination;
            emit OperatorImported(name, destination);
        }

        rebuildCaches(destinations);
    }

    function rebuildCaches(MixinOperatorResolver[] calldata destinations) public onlyOwner {

        for (uint256 i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


abstract contract OwnableFactoryHandler is Ownable {
    event FactoryAdded(address newFactory);

    event FactoryRemoved(address oldFactory);

    mapping(address => bool) public supportedFactories;

    modifier onlyFactory() {
        require(supportedFactories[msg.sender], "OFH: FORBIDDEN");
        _;
    }

    function addFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "OFH: INVALID_ADDRESS");
        supportedFactories[_factory] = true;
        emit FactoryAdded(_factory);
    }

    function removeFactory(address _factory) external onlyOwner {
        require(supportedFactories[_factory], "OFH: NOT_SUPPORTED");
        supportedFactories[_factory] = false;
        emit FactoryRemoved(_factory);
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract NestedReserve is OwnableFactoryHandler {

    function transfer(
        address _recipient,
        IERC20 _token,
        uint256 _amount
    ) external onlyFactory {

        require(_recipient != address(0), "NRS: INVALID_ADDRESS");
        SafeERC20.safeTransfer(_token, _recipient, _amount);
    }

    function withdraw(IERC20 _token, uint256 _amount) external onlyFactory {

        SafeERC20.safeTransfer(_token, msg.sender, _amount);
    }
}// UNLICENSED

pragma solidity 0.8.11;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;


    function totalSupply() external view returns (uint256);


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
}// GPL-3.0-or-later
pragma solidity 0.8.11;



contract FeeSplitter is Ownable, ReentrancyGuard {


    event PaymentReleased(address to, address token, uint256 amount);

    event PaymentReceived(address from, address token, uint256 amount);

    event RoyaltiesWeightUpdated(uint256 weight);

    event ShareholdersAdded(address account, uint256 weight);

    event ShareholderUpdated(address account, uint256 weight);

    event RoyaltiesReceived(address to, address token, uint256 value);


    struct Shareholder {
        address account;
        uint96 weight;
    }

    struct TokenRecords {
        uint256 totalShares;
        uint256 totalReleased;
        mapping(address => uint256) shares;
        mapping(address => uint256) released;
    }


    mapping(address => TokenRecords) private tokenRecords;

    Shareholder[] private shareholders;

    uint256 public royaltiesWeight;

    uint256 public totalWeights;

    address public immutable weth;


    constructor(
        address[] memory _accounts,
        uint96[] memory _weights,
        uint256 _royaltiesWeight,
        address _weth
    ) {
        require(_weth != address(0), "FS: INVALID_ADDRESS");
        setShareholders(_accounts, _weights);
        setRoyaltiesWeight(_royaltiesWeight);
        weth = _weth;
    }

    receive() external payable {
        require(msg.sender == weth, "FS: ETH_SENDER_NOT_WETH");
    }


    function setRoyaltiesWeight(uint256 _weight) public onlyOwner {

        require(_weight != 0, "FS: WEIGHT_ZERO");
        totalWeights = totalWeights + _weight - royaltiesWeight;
        royaltiesWeight = _weight;
        emit RoyaltiesWeightUpdated(_weight);
    }

    function setShareholders(address[] memory _accounts, uint96[] memory _weights) public onlyOwner {

        delete shareholders;
        uint256 accountsLength = _accounts.length;
        require(accountsLength != 0, "FS: EMPTY_ARRAY");
        require(accountsLength == _weights.length, "FS: INPUTS_LENGTH_MUST_MATCH");
        totalWeights = royaltiesWeight;

        for (uint256 i = 0; i < accountsLength; i++) {
            _addShareholder(_accounts[i], _weights[i]);
        }
    }

    function updateShareholder(uint256 _accountIndex, uint96 _weight) external onlyOwner {

        require(_weight != 0, "FS: INVALID_WEIGHT");
        require(_accountIndex < shareholders.length, "FS: INVALID_ACCOUNT_INDEX");
        Shareholder storage _shareholder = shareholders[_accountIndex];
        totalWeights = totalWeights + _weight - _shareholder.weight;
        require(totalWeights != 0, "FS: TOTAL_WEIGHTS_ZERO");
        _shareholder.weight = _weight;
        emit ShareholderUpdated(_shareholder.account, _weight);
    }


    function releaseTokens(IERC20[] calldata _tokens) external nonReentrant {

        uint256 amount;
        for (uint256 i = 0; i < _tokens.length; i++) {
            amount = _releaseToken(_msgSender(), _tokens[i]);
            if (address(_tokens[i]) == weth) {
                IWETH(weth).withdraw(amount);
                (bool success, ) = _msgSender().call{ value: amount }("");
                require(success, "FS: ETH_TRANFER_ERROR");
            } else {
                SafeERC20.safeTransfer(_tokens[i], _msgSender(), amount);
            }
            emit PaymentReleased(_msgSender(), address(_tokens[i]), amount);
        }
    }

    function releaseTokensNoETH(IERC20[] calldata _tokens) external nonReentrant {

        uint256 amount;
        for (uint256 i = 0; i < _tokens.length; i++) {
            amount = _releaseToken(_msgSender(), _tokens[i]);
            SafeERC20.safeTransfer(_tokens[i], _msgSender(), amount);
            emit PaymentReleased(_msgSender(), address(_tokens[i]), amount);
        }
    }

    function sendFees(IERC20 _token, uint256 _amount) external nonReentrant {

        uint256 weights;
        unchecked {
            weights = totalWeights - royaltiesWeight;
        }

        uint256 balanceBeforeTransfer = _token.balanceOf(address(this));
        SafeERC20.safeTransferFrom(_token, _msgSender(), address(this), _amount);

        _sendFees(_token, _token.balanceOf(address(this)) - balanceBeforeTransfer, weights);
    }

    function sendFeesWithRoyalties(
        address _royaltiesTarget,
        IERC20 _token,
        uint256 _amount
    ) external nonReentrant {

        require(_royaltiesTarget != address(0), "FS: INVALID_ROYALTIES_TARGET");

        uint256 balanceBeforeTransfer = _token.balanceOf(address(this));
        SafeERC20.safeTransferFrom(_token, _msgSender(), address(this), _amount);
        uint256 amountReceived = _token.balanceOf(address(this)) - balanceBeforeTransfer;

        uint256 _totalWeights = totalWeights;
        uint256 royaltiesAmount = (amountReceived * royaltiesWeight) / _totalWeights;

        _sendFees(_token, amountReceived, _totalWeights);
        _addShares(_royaltiesTarget, royaltiesAmount, address(_token));

        emit RoyaltiesReceived(_royaltiesTarget, address(_token), royaltiesAmount);
    }


    function getAmountDue(address _account, IERC20 _token) public view returns (uint256) {

        TokenRecords storage _tokenRecords = tokenRecords[address(_token)];
        uint256 _totalShares = _tokenRecords.totalShares;
        if (_totalShares == 0) return 0;

        uint256 totalReceived = _tokenRecords.totalReleased + _token.balanceOf(address(this));
        return (totalReceived * _tokenRecords.shares[_account]) / _totalShares - _tokenRecords.released[_account];
    }

    function totalShares(address _token) external view returns (uint256) {

        return tokenRecords[_token].totalShares;
    }

    function totalReleased(address _token) external view returns (uint256) {

        return tokenRecords[_token].totalReleased;
    }

    function shares(address _account, address _token) external view returns (uint256) {

        return tokenRecords[_token].shares[_account];
    }

    function released(address _account, address _token) external view returns (uint256) {

        return tokenRecords[_token].released[_account];
    }

    function findShareholder(address _account) external view returns (uint256) {

        for (uint256 i = 0; i < shareholders.length; i++) {
            if (shareholders[i].account == _account) return i;
        }
        revert("FS: SHAREHOLDER_NOT_FOUND");
    }


    function _sendFees(
        IERC20 _token,
        uint256 _amount,
        uint256 _totalWeights
    ) private {

        Shareholder[] memory shareholdersCache = shareholders;
        for (uint256 i = 0; i < shareholdersCache.length; i++) {
            _addShares(
                shareholdersCache[i].account,
                (_amount * shareholdersCache[i].weight) / _totalWeights,
                address(_token)
            );
        }
        emit PaymentReceived(_msgSender(), address(_token), _amount);
    }

    function _addShares(
        address _account,
        uint256 _shares,
        address _token
    ) private {

        TokenRecords storage _tokenRecords = tokenRecords[_token];
        _tokenRecords.shares[_account] += _shares;
        _tokenRecords.totalShares += _shares;
    }

    function _releaseToken(address _account, IERC20 _token) private returns (uint256) {

        uint256 amountToRelease = getAmountDue(_account, _token);
        require(amountToRelease != 0, "FS: NO_PAYMENT_DUE");

        TokenRecords storage _tokenRecords = tokenRecords[address(_token)];
        _tokenRecords.released[_account] += amountToRelease;
        _tokenRecords.totalReleased += amountToRelease;

        return amountToRelease;
    }

    function _addShareholder(address _account, uint96 _weight) private {

        require(_weight != 0, "FS: ZERO_WEIGHT");
        require(_account != address(0), "FS: INVALID_ADDRESS");
        for (uint256 i = 0; i < shareholders.length; i++) {
            require(shareholders[i].account != _account, "FS: ALREADY_SHAREHOLDER");
        }

        shareholders.push(Shareholder(_account, _weight));
        totalWeights += _weight;
        emit ShareholdersAdded(_account, _weight);
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


interface INestedFactory {


    event FeeSplitterUpdated(address feeSplitter);

    event EntryFeesUpdated(uint256 entryFees);

    event ExitFeesUpdated(uint256 exitFees);

    event ReserveUpdated(address reserve);

    event NftCreated(uint256 indexed nftId, uint256 originalNftId);

    event NftUpdated(uint256 indexed nftId);

    event OperatorAdded(bytes32 newOperator);

    event OperatorRemoved(bytes32 oldOperator);

    event TokensUnlocked(address token, uint256 amount);


    struct Order {
        bytes32 operator;
        address token;
        bytes callData;
    }

    struct BatchedInputOrders {
        IERC20 inputToken;
        uint256 amount;
        Order[] orders;
        bool fromReserve;
    }

    struct BatchedOutputOrders {
        IERC20 outputToken;
        uint256[] amounts;
        Order[] orders;
        bool toReserve;
    }


    function addOperator(bytes32 operator) external;


    function removeOperator(bytes32 operator) external;


    function setFeeSplitter(FeeSplitter _feeSplitter) external;


    function setEntryFees(uint256 _entryFees) external;


    function setExitFees(uint256 _exitFees) external;


    function unlockTokens(IERC20 _token) external;



    function create(uint256 _originalTokenId, BatchedInputOrders[] calldata _batchedOrders) external payable;


    function processInputOrders(uint256 _nftId, BatchedInputOrders[] calldata _batchedOrders) external payable;


    function processOutputOrders(uint256 _nftId, BatchedOutputOrders[] calldata _batchedOrders) external;


    function processInputAndOutputOrders(
        uint256 _nftId,
        BatchedInputOrders[] calldata _batchedInputOrders,
        BatchedOutputOrders[] calldata _batchedOutputOrders
    ) external payable;


    function destroy(
        uint256 _nftId,
        IERC20 _buyToken,
        Order[] calldata _orders
    ) external;


    function withdraw(uint256 _nftId, uint256 _tokenIndex) external;


    function updateLockTimestamp(uint256 _nftId, uint256 _timestamp) external;

}// GPL-3.0-or-later
pragma solidity 0.8.11;


abstract contract MixinOperatorResolver {
    event CacheUpdated(bytes32 name, IOperatorResolver.Operator destination);

    OperatorResolver public immutable resolver;

    mapping(bytes32 => IOperatorResolver.Operator) internal operatorCache;

    constructor(address _resolver) {
        require(_resolver != address(0), "MOR: INVALID_ADDRESS");
        resolver = OperatorResolver(_resolver);
    }

    function resolverOperatorsRequired() public view virtual returns (bytes32[] memory) {}

    function rebuildCache() public {
        bytes32[] memory requiredOperators = resolverOperatorsRequired();
        bytes32 name;
        IOperatorResolver.Operator memory destination;
        for (uint256 i = 0; i < requiredOperators.length; i++) {
            name = requiredOperators[i];
            destination = resolver.getOperator(name);
            if (destination.implementation != address(0)) {
                operatorCache[name] = destination;
            } else {
                delete operatorCache[name];
            }
            emit CacheUpdated(name, destination);
        }
    }

    function isResolverCached() external view returns (bool) {
        bytes32[] memory requiredOperators = resolverOperatorsRequired();
        bytes32 name;
        IOperatorResolver.Operator memory cacheTmp;
        IOperatorResolver.Operator memory actualValue;
        for (uint256 i = 0; i < requiredOperators.length; i++) {
            name = requiredOperators[i];
            cacheTmp = operatorCache[name];
            actualValue = resolver.getOperator(name);
            if (
                actualValue.implementation != cacheTmp.implementation ||
                actualValue.selector != cacheTmp.selector ||
                cacheTmp.implementation == address(0)
            ) {
                return false;
            }
        }
        return true;
    }

    function requireAndGetAddress(bytes32 name) internal view returns (IOperatorResolver.Operator memory) {
        IOperatorResolver.Operator memory _foundAddress = operatorCache[name];
        require(_foundAddress.implementation != address(0), string(abi.encodePacked("MOR: MISSING_OPERATOR: ", name)));
        return _foundAddress;
    }

    function callOperator(
        INestedFactory.Order calldata _order,
        address _inputToken,
        address _outputToken
    ) internal returns (bool success, uint256[] memory amounts) {
        IOperatorResolver.Operator memory _operator = requireAndGetAddress(_order.operator);
        bytes memory data;
        (success, data) = _operator.implementation.delegatecall(bytes.concat(_operator.selector, _order.callData));

        if (success) {
            address[] memory tokens;
            (amounts, tokens) = abi.decode(data, (uint256[], address[]));
            require(tokens[0] == _outputToken, "MOR: INVALID_OUTPUT_TOKEN");
            require(tokens[1] == _inputToken, "MOR: INVALID_INPUT_TOKEN");
        }
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


library ExchangeHelpers {

    using SafeERC20 for IERC20;

    function fillQuote(
        IERC20 _sellToken,
        address _swapTarget,
        bytes memory _swapCallData
    ) internal returns (bool) {

        setMaxAllowance(_sellToken, _swapTarget);
        (bool success, ) = _swapTarget.call(_swapCallData);
        return success;
    }

    function setMaxAllowance(IERC20 _token, address _spender) internal {

        uint256 _currentAllowance = _token.allowance(address(this), _spender);
        if (_currentAllowance != type(uint256).max) {
            _token.safeDecreaseAllowance(_spender, _currentAllowance);
            _token.safeIncreaseAllowance(_spender, type(uint256).max);
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}// MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract NestedAsset is ERC721Enumerable, OwnableFactoryHandler {
    using Counters for Counters.Counter;


    Counters.Counter private _tokenIds;

    string public baseUri;

    string public unrevealedTokenUri;

    string public contractUri;

    mapping(uint256 => uint256) public originalAsset;

    mapping(uint256 => address) public lastOwnerBeforeBurn;

    bool public isRevealed;


    constructor() ERC721("NestedNFT", "NESTED") {}


    modifier onlyTokenOwner(address _address, uint256 _tokenId) {
        require(_address == ownerOf(_tokenId), "NA: FORBIDDEN_NOT_OWNER");
        _;
    }


    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");
        if (isRevealed) {
            return super.tokenURI(_tokenId);
        } else {
            return unrevealedTokenUri;
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function originalOwner(uint256 _tokenId) external view returns (address) {
        uint256 originalAssetId = originalAsset[_tokenId];

        if (originalAssetId != 0) {
            return _exists(originalAssetId) ? ownerOf(originalAssetId) : lastOwnerBeforeBurn[originalAssetId];
        }
        return address(0);
    }


    function mint(address _owner, uint256 _replicatedTokenId) public onlyFactory returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();
        _safeMint(_owner, tokenId);

        if (_replicatedTokenId == 0) {
            return tokenId;
        }

        require(_exists(_replicatedTokenId), "NA: NON_EXISTENT_TOKEN_ID");
        require(tokenId != _replicatedTokenId, "NA: SELF_DUPLICATION");

        uint256 originalTokenId = originalAsset[_replicatedTokenId];
        originalAsset[tokenId] = originalTokenId != 0 ? originalTokenId : _replicatedTokenId;

        return tokenId;
    }

    function burn(address _owner, uint256 _tokenId) external onlyFactory onlyTokenOwner(_owner, _tokenId) {
        lastOwnerBeforeBurn[_tokenId] = _owner;
        _burn(_tokenId);
    }


    function setIsRevealed(bool _isRevealed) external onlyOwner {
        isRevealed = _isRevealed;
    }

    function setBaseURI(string memory _baseUri) external onlyOwner {
        require(bytes(_baseUri).length != 0, "NA: EMPTY_URI");
        baseUri = _baseUri;
    }

    function setUnrevealedTokenURI(string memory _newUri) external onlyOwner {
        require(bytes(_newUri).length != 0, "NA: EMPTY_URI");
        unrevealedTokenUri = _newUri;
    }

    function setContractURI(string memory _newUri) external onlyOwner {
        contractUri = _newUri;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract NestedRecords is OwnableFactoryHandler {

    event MaxHoldingsChanges(uint256 maxHoldingsCount);

    event LockTimestampIncreased(uint256 nftId, uint256 timestamp);

    event ReserveUpdated(uint256 nftId, address newReserve);


    struct NftRecord {
        mapping(address => uint256) holdings;
        address[] tokens;
        address reserve;
        uint256 lockTimestamp;
    }


    mapping(uint256 => NftRecord) public records;

    uint256 public maxHoldingsCount;


    constructor(uint256 _maxHoldingsCount) {
        maxHoldingsCount = _maxHoldingsCount;
    }


    function setMaxHoldingsCount(uint256 _maxHoldingsCount) external onlyOwner {
        require(_maxHoldingsCount != 0, "NRC: INVALID_MAX_HOLDINGS");
        maxHoldingsCount = _maxHoldingsCount;
        emit MaxHoldingsChanges(maxHoldingsCount);
    }


    function updateHoldingAmount(
        uint256 _nftId,
        address _token,
        uint256 _amount
    ) public onlyFactory {
        if (_amount == 0) {
            uint256 tokenIndex = 0;
            address[] memory tokens = getAssetTokens(_nftId);
            while (tokenIndex < tokens.length) {
                if (tokens[tokenIndex] == _token) {
                    deleteAsset(_nftId, tokenIndex);
                    break;
                }
                tokenIndex++;
            }
        } else {
            records[_nftId].holdings[_token] = _amount;
        }
    }

    function deleteAsset(uint256 _nftId, uint256 _tokenIndex) public onlyFactory {
        address[] storage tokens = records[_nftId].tokens;
        address token = tokens[_tokenIndex];

        require(records[_nftId].holdings[token] != 0, "NRC: HOLDING_INACTIVE");

        delete records[_nftId].holdings[token];
        tokens[_tokenIndex] = tokens[tokens.length - 1];
        tokens.pop();
    }

    function freeHolding(uint256 _nftId, address _token) public onlyFactory {
        delete records[_nftId].holdings[_token];
    }

    function store(
        uint256 _nftId,
        address _token,
        uint256 _amount,
        address _reserve
    ) external onlyFactory {
        NftRecord storage _nftRecord = records[_nftId];

        uint256 amount = records[_nftId].holdings[_token];
        require(_amount != 0, "NRC: INVALID_AMOUNT");
        if (amount != 0) {
            require(_nftRecord.reserve == _reserve, "NRC: RESERVE_MISMATCH");
            updateHoldingAmount(_nftId, _token, amount + _amount);
            return;
        }
        require(_nftRecord.tokens.length < maxHoldingsCount, "NRC: TOO_MANY_TOKENS");
        require(
            _reserve != address(0) && (_reserve == _nftRecord.reserve || _nftRecord.reserve == address(0)),
            "NRC: INVALID_RESERVE"
        );

        _nftRecord.holdings[_token] = _amount;
        _nftRecord.tokens.push(_token);
        _nftRecord.reserve = _reserve;
    }

    function updateLockTimestamp(uint256 _nftId, uint256 _timestamp) external onlyFactory {
        require(_timestamp > records[_nftId].lockTimestamp, "NRC: LOCK_PERIOD_CANT_DECREASE");
        records[_nftId].lockTimestamp = _timestamp;
        emit LockTimestampIncreased(_nftId, _timestamp);
    }

    function removeNFT(uint256 _nftId) external onlyFactory {
        delete records[_nftId];
    }

    function setReserve(uint256 _nftId, address _nextReserve) external onlyFactory {
        records[_nftId].reserve = _nextReserve;
        emit ReserveUpdated(_nftId, _nextReserve);
    }


    function getAssetTokens(uint256 _nftId) public view returns (address[] memory) {
        return records[_nftId].tokens;
    }

    function getAssetReserve(uint256 _nftId) external view returns (address) {
        return records[_nftId].reserve;
    }

    function getAssetTokensLength(uint256 _nftId) external view returns (uint256) {
        return records[_nftId].tokens.length;
    }

    function getAssetHolding(uint256 _nftId, address _token) public view returns (uint256) {
        return records[_nftId].holdings[_token];
    }

    function tokenHoldings(uint256 _nftId) external view returns (address[] memory, uint256[] memory) {
        address[] memory tokens = getAssetTokens(_nftId);
        uint256 tokensCount = tokens.length;
        uint256[] memory amounts = new uint256[](tokensCount);

        for (uint256 i = 0; i < tokensCount; i++) {
            amounts[i] = getAssetHolding(_nftId, tokens[i]);
        }
        return (tokens, amounts);
    }

    function getLockTimestamp(uint256 _nftId) external view returns (uint256) {
        return records[_nftId].lockTimestamp;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.11;


contract Withdrawer is ReentrancyGuard {
    IWETH public immutable weth;

    constructor(IWETH _weth) {
        weth = _weth;
    }

    receive() external payable {
        require(msg.sender == address(weth), "WD: ETH_SENDER_NOT_WETH");
    }

    function withdraw(uint256 amount) external nonReentrant {
        weth.transferFrom(msg.sender, address(this), amount);
        weth.withdraw(amount);
        Address.sendValue(payable(msg.sender), amount);
    }
}// MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// GPL-3.0-or-later
pragma solidity 0.8.11;



contract NestedFactory is INestedFactory, ReentrancyGuard, OwnableProxyDelegation, MixinOperatorResolver {

    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    bytes32[] private operators;

    FeeSplitter public feeSplitter;

    NestedReserve public immutable reserve;

    NestedAsset public immutable nestedAsset;

    IWETH public immutable weth;

    NestedRecords public immutable nestedRecords;

    Withdrawer private immutable withdrawer;

    uint256 public entryFees;

    uint256 public exitFees;


    constructor(
        NestedAsset _nestedAsset,
        NestedRecords _nestedRecords,
        NestedReserve _reserve,
        FeeSplitter _feeSplitter,
        IWETH _weth,
        address _operatorResolver,
        Withdrawer _withdrawer
    ) MixinOperatorResolver(_operatorResolver) {
        require(
            address(_nestedAsset) != address(0) &&
                address(_nestedRecords) != address(0) &&
                address(_reserve) != address(0) &&
                address(_feeSplitter) != address(0) &&
                address(_weth) != address(0) &&
                _operatorResolver != address(0) &&
                address(_withdrawer) != address(0),
            "NF: INVALID_ADDRESS"
        );
        nestedAsset = _nestedAsset;
        nestedRecords = _nestedRecords;
        reserve = _reserve;
        feeSplitter = _feeSplitter;
        weth = _weth;
        withdrawer = _withdrawer;
    }

    receive() external payable {
        require(msg.sender == address(withdrawer), "NF: ETH_SENDER_NOT_WITHDRAWER");
    }


    modifier onlyTokenOwner(uint256 _nftId) {
        require(nestedAsset.ownerOf(_nftId) == _msgSender(), "NF: CALLER_NOT_OWNER");
        _;
    }

    modifier isUnlocked(uint256 _nftId) {
        require(block.timestamp > nestedRecords.getLockTimestamp(_nftId), "NF: LOCKED_NFT");
        _;
    }


    function resolverOperatorsRequired() public view override returns (bytes32[] memory) {
        return operators;
    }


    function addOperator(bytes32 operator) external override onlyOwner {
        require(operator != bytes32(""), "NF: INVALID_OPERATOR_NAME");
        bytes32[] memory operatorsCache = operators;
        for (uint256 i = 0; i < operatorsCache.length; i++) {
            require(operatorsCache[i] != operator, "NF: EXISTENT_OPERATOR");
        }
        operators.push(operator);
        rebuildCache();
        emit OperatorAdded(operator);
    }

    function removeOperator(bytes32 operator) external override onlyOwner {
        bytes32[] storage operatorsCache = operators;
        uint256 operatorsLength = operatorsCache.length;
        for (uint256 i = 0; i < operatorsLength; i++) {
            if (operatorsCache[i] == operator) {
                operatorsCache[i] = operators[operatorsLength - 1];
                operatorsCache.pop();
                if (operatorCache[operator].implementation != address(0)) {
                    delete operatorCache[operator]; // remove from cache
                }
                rebuildCache();
                emit OperatorRemoved(operator);
                return;
            }
        }
        revert("NF: NON_EXISTENT_OPERATOR");
    }

    function setFeeSplitter(FeeSplitter _feeSplitter) external override onlyOwner {
        require(address(_feeSplitter) != address(0), "NF: INVALID_FEE_SPLITTER_ADDRESS");
        feeSplitter = _feeSplitter;
        emit FeeSplitterUpdated(address(_feeSplitter));
    }

    function setEntryFees(uint256 _entryFees) external override onlyOwner {
        require(_entryFees != 0, "NF: ZERO_FEES");
        require(_entryFees <= 10000, "NF: FEES_OVERFLOW");
        entryFees = _entryFees;
        emit EntryFeesUpdated(_entryFees);
    }

    function setExitFees(uint256 _exitFees) external override onlyOwner {
        require(_exitFees != 0, "NF: ZERO_FEES");
        require(_exitFees <= 10000, "NF: FEES_OVERFLOW");
        exitFees = _exitFees;
        emit ExitFeesUpdated(_exitFees);
    }

    function unlockTokens(IERC20 _token) external override onlyOwner {
        uint256 amount = _token.balanceOf(address(this));
        SafeERC20.safeTransfer(_token, msg.sender, amount);
        emit TokensUnlocked(address(_token), amount);
    }


    function create(uint256 _originalTokenId, BatchedInputOrders[] calldata _batchedOrders)
        external
        payable
        override
        nonReentrant
    {
        uint256 batchedOrdersLength = _batchedOrders.length;
        require(batchedOrdersLength != 0, "NF: INVALID_MULTI_ORDERS");

        _checkMsgValue(_batchedOrders);
        uint256 nftId = nestedAsset.mint(_msgSender(), _originalTokenId);

        for (uint256 i = 0; i < batchedOrdersLength; i++) {
            (uint256 fees, IERC20 tokenSold) = _submitInOrders(nftId, _batchedOrders[i], false);
            _transferFeeWithRoyalty(fees, tokenSold, nftId);
        }

        emit NftCreated(nftId, _originalTokenId);
    }

    function processInputOrders(uint256 _nftId, BatchedInputOrders[] calldata _batchedOrders)
        external
        payable
        override
        nonReentrant
        onlyTokenOwner(_nftId)
        isUnlocked(_nftId)
    {
        _checkMsgValue(_batchedOrders);
        _processInputOrders(_nftId, _batchedOrders);
        emit NftUpdated(_nftId);
    }

    function processOutputOrders(uint256 _nftId, BatchedOutputOrders[] calldata _batchedOrders)
        external
        override
        nonReentrant
        onlyTokenOwner(_nftId)
        isUnlocked(_nftId)
    {
        _processOutputOrders(_nftId, _batchedOrders);
        emit NftUpdated(_nftId);
    }

    function processInputAndOutputOrders(
        uint256 _nftId,
        BatchedInputOrders[] calldata _batchedInputOrders,
        BatchedOutputOrders[] calldata _batchedOutputOrders
    ) external payable override nonReentrant onlyTokenOwner(_nftId) isUnlocked(_nftId) {
        _checkMsgValue(_batchedInputOrders);
        _processInputOrders(_nftId, _batchedInputOrders);
        _processOutputOrders(_nftId, _batchedOutputOrders);
        emit NftUpdated(_nftId);
    }

    function destroy(
        uint256 _nftId,
        IERC20 _buyToken,
        Order[] calldata _orders
    ) external override nonReentrant onlyTokenOwner(_nftId) isUnlocked(_nftId) {
        address[] memory tokens = nestedRecords.getAssetTokens(_nftId);
        uint256 tokensLength = tokens.length;
        require(_orders.length != 0, "NF: INVALID_ORDERS");
        require(tokensLength == _orders.length, "NF: INPUTS_LENGTH_MUST_MATCH");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        uint256 buyTokenInitialBalance = _buyToken.balanceOf(address(this));

        for (uint256 i = 0; i < tokensLength; i++) {
            address token = tokens[i];
            uint256 amount = _safeWithdraw(token, _nftId);
            _safeSubmitOrder(token, address(_buyToken), amount, _nftId, _orders[i]);
        }

        uint256 amountBought = _buyToken.balanceOf(address(this)) - buyTokenInitialBalance;
        uint256 amountFees = (amountBought * exitFees) / 10000; // Exit Fees
        unchecked {
            amountBought -= amountFees;

            _transferFeeWithRoyalty(amountFees, _buyToken, _nftId);
            _safeTransferAndUnwrap(_buyToken, amountBought, _msgSender());
        }

        nestedRecords.removeNFT(_nftId);
        nestedAsset.burn(_msgSender(), _nftId);
    }

    function withdraw(uint256 _nftId, uint256 _tokenIndex)
        external
        override
        nonReentrant
        onlyTokenOwner(_nftId)
        isUnlocked(_nftId)
    {
        uint256 assetTokensLength = nestedRecords.getAssetTokensLength(_nftId);
        require(assetTokensLength > _tokenIndex, "NF: INVALID_TOKEN_INDEX");
        require(assetTokensLength > 1, "NF: UNALLOWED_EMPTY_PORTFOLIO");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        address token = nestedRecords.getAssetTokens(_nftId)[_tokenIndex];

        uint256 amount = _safeWithdraw(token, _nftId);
        _safeTransferWithFees(IERC20(token), amount, _msgSender(), _nftId);

        nestedRecords.deleteAsset(_nftId, _tokenIndex);
        emit NftUpdated(_nftId);
    }

    function updateLockTimestamp(uint256 _nftId, uint256 _timestamp) external override onlyTokenOwner(_nftId) {
        nestedRecords.updateLockTimestamp(_nftId, _timestamp);
    }


    function _processInputOrders(uint256 _nftId, BatchedInputOrders[] calldata _batchedOrders) private {
        uint256 batchedOrdersLength = _batchedOrders.length;
        require(batchedOrdersLength != 0, "NF: INVALID_MULTI_ORDERS");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        for (uint256 i = 0; i < batchedOrdersLength; i++) {
            (uint256 fees, IERC20 tokenSold) = _submitInOrders(
                _nftId,
                _batchedOrders[i],
                _batchedOrders[i].fromReserve
            );
            _transferFeeWithRoyalty(fees, tokenSold, _nftId);
        }
    }

    function _processOutputOrders(uint256 _nftId, BatchedOutputOrders[] calldata _batchedOrders) private {
        uint256 batchedOrdersLength = _batchedOrders.length;
        require(batchedOrdersLength != 0, "NF: INVALID_MULTI_ORDERS");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        for (uint256 i = 0; i < batchedOrdersLength; i++) {
            (uint256 feesAmount, uint256 amountBought) = _submitOutOrders(
                _nftId,
                _batchedOrders[i],
                _batchedOrders[i].toReserve
            );
            _transferFeeWithRoyalty(feesAmount, _batchedOrders[i].outputToken, _nftId);
            if (!_batchedOrders[i].toReserve) {
                _safeTransferAndUnwrap(_batchedOrders[i].outputToken, amountBought - feesAmount, _msgSender());
            }
        }
    }

    function _submitInOrders(
        uint256 _nftId,
        BatchedInputOrders calldata _batchedOrders,
        bool _fromReserve
    ) private returns (uint256 feesAmount, IERC20 tokenSold) {
        uint256 batchLength = _batchedOrders.orders.length;
        require(batchLength != 0, "NF: INVALID_ORDERS");
        uint256 _inputTokenAmount;
        (tokenSold, _inputTokenAmount) = _transferInputTokens(
            _nftId,
            _batchedOrders.inputToken,
            _batchedOrders.amount,
            _fromReserve
        );

        uint256 amountSpent;
        for (uint256 i = 0; i < batchLength; i++) {
            amountSpent += _submitOrder(
                address(tokenSold),
                _batchedOrders.orders[i].token,
                _nftId,
                _batchedOrders.orders[i],
                true // always to the reserve
            );
        }
        feesAmount = (amountSpent * entryFees) / 10000; // Entry Fees
        require(amountSpent <= _inputTokenAmount - feesAmount, "NF: OVERSPENT");
        unchecked {
            uint256 underSpentAmount = _inputTokenAmount - feesAmount - amountSpent;
            if (underSpentAmount != 0) {
                SafeERC20.safeTransfer(tokenSold, _fromReserve ? address(reserve) : _msgSender(), underSpentAmount);
            }

            if (_fromReserve) {
                _decreaseHoldingAmount(_nftId, address(tokenSold), _inputTokenAmount - underSpentAmount);
            }
        }
    }

    function _submitOutOrders(
        uint256 _nftId,
        BatchedOutputOrders calldata _batchedOrders,
        bool _toReserve
    ) private returns (uint256 feesAmount, uint256 amountBought) {
        uint256 batchLength = _batchedOrders.orders.length;
        require(batchLength != 0, "NF: INVALID_ORDERS");
        require(_batchedOrders.amounts.length == batchLength, "NF: INPUTS_LENGTH_MUST_MATCH");
        amountBought = _batchedOrders.outputToken.balanceOf(address(this));

        IERC20 _inputToken;
        uint256 _inputTokenAmount;
        for (uint256 i = 0; i < batchLength; i++) {
            (_inputToken, _inputTokenAmount) = _transferInputTokens(
                _nftId,
                IERC20(_batchedOrders.orders[i].token),
                _batchedOrders.amounts[i],
                true
            );

            uint256 amountSpent = _submitOrder(
                address(_inputToken),
                address(_batchedOrders.outputToken),
                _nftId,
                _batchedOrders.orders[i],
                false
            );
            require(amountSpent <= _inputTokenAmount, "NF: OVERSPENT");

            unchecked {
                uint256 underSpentAmount = _inputTokenAmount - amountSpent;
                if (underSpentAmount != 0) {
                    SafeERC20.safeTransfer(_inputToken, address(reserve), underSpentAmount);
                }
                _decreaseHoldingAmount(_nftId, address(_inputToken), _inputTokenAmount - underSpentAmount);
            }
        }

        amountBought = _batchedOrders.outputToken.balanceOf(address(this)) - amountBought;

        unchecked {
            feesAmount = (amountBought * (_toReserve ? entryFees : exitFees)) / 10000;

            if (_toReserve) {
                _transferToReserveAndStore(_batchedOrders.outputToken, amountBought - feesAmount, _nftId);
            }
        }
    }

    function _submitOrder(
        address _inputToken,
        address _outputToken,
        uint256 _nftId,
        Order calldata _order,
        bool _toReserve
    ) private returns (uint256 amountSpent) {
        (bool success, uint256[] memory amounts) = callOperator(_order, _inputToken, _outputToken);
        require(success, "NF: OPERATOR_CALL_FAILED");

        if (_toReserve) {
            _transferToReserveAndStore(IERC20(_outputToken), amounts[0], _nftId);
        }
        amountSpent = amounts[1];
    }

    function _safeSubmitOrder(
        address _inputToken,
        address _outputToken,
        uint256 _amountToSpend,
        uint256 _nftId,
        Order calldata _order
    ) private {
        (bool success, uint256[] memory amounts) = callOperator(_order, _inputToken, _outputToken);
        if (success) {
            require(amounts[1] <= _amountToSpend, "NF: OVERSPENT");
            unchecked {
                uint256 underSpentAmount = _amountToSpend - amounts[1];
                if (underSpentAmount != 0) {
                    SafeERC20.safeTransfer(IERC20(_inputToken), _msgSender(), underSpentAmount);
                }
            }
        } else {
            _safeTransferWithFees(IERC20(_inputToken), _amountToSpend, _msgSender(), _nftId);
        }
    }

    function _transferToReserveAndStore(
        IERC20 _token,
        uint256 _amount,
        uint256 _nftId
    ) private {
        address reserveAddr = address(reserve);
        uint256 balanceReserveBefore = _token.balanceOf(reserveAddr);

        SafeERC20.safeTransfer(_token, reserveAddr, _amount);

        uint256 balanceReserveAfter = _token.balanceOf(reserveAddr);

        nestedRecords.store(_nftId, address(_token), balanceReserveAfter - balanceReserveBefore, reserveAddr);
    }

    function _transferInputTokens(
        uint256 _nftId,
        IERC20 _inputToken,
        uint256 _inputTokenAmount,
        bool _fromReserve
    ) private returns (IERC20, uint256) {
        if (address(_inputToken) == ETH) {
            require(!_fromReserve, "NF: NO_ETH_FROM_RESERVE");
            require(address(this).balance >= _inputTokenAmount, "NF: INVALID_AMOUNT_IN");
            weth.deposit{ value: _inputTokenAmount }();
            return (IERC20(address(weth)), _inputTokenAmount);
        }

        uint256 balanceBefore = _inputToken.balanceOf(address(this));
        if (_fromReserve) {
            require(
                nestedRecords.getAssetHolding(_nftId, address(_inputToken)) >= _inputTokenAmount,
                "NF: INSUFFICIENT_AMOUNT_IN"
            );
            reserve.withdraw(_inputToken, _inputTokenAmount);
        } else {
            SafeERC20.safeTransferFrom(_inputToken, _msgSender(), address(this), _inputTokenAmount);
        }
        return (_inputToken, _inputToken.balanceOf(address(this)) - balanceBefore);
    }

    function _transferFeeWithRoyalty(
        uint256 _amount,
        IERC20 _token,
        uint256 _nftId
    ) private {
        address originalOwner = nestedAsset.originalOwner(_nftId);
        ExchangeHelpers.setMaxAllowance(_token, address(feeSplitter));
        if (originalOwner != address(0)) {
            feeSplitter.sendFeesWithRoyalties(originalOwner, _token, _amount);
        } else {
            feeSplitter.sendFees(_token, _amount);
        }
    }

    function _decreaseHoldingAmount(
        uint256 _nftId,
        address _inputToken,
        uint256 _amount
    ) private {
        nestedRecords.updateHoldingAmount(
            _nftId,
            _inputToken,
            nestedRecords.getAssetHolding(_nftId, _inputToken) - _amount
        );
    }

    function _safeTransferAndUnwrap(
        IERC20 _token,
        uint256 _amount,
        address _dest
    ) private {
        if (address(_token) == address(weth)) {
            ExchangeHelpers.setMaxAllowance(IERC20(address(weth)), address(withdrawer));
            withdrawer.withdraw(_amount);
            (bool success, ) = _dest.call{ value: _amount }("");
            require(success, "NF: ETH_TRANSFER_ERROR");
        } else {
            SafeERC20.safeTransfer(_token, _dest, _amount);
        }
    }

    function _safeTransferWithFees(
        IERC20 _token,
        uint256 _amount,
        address _dest,
        uint256 _nftId
    ) private {
        uint256 feeAmount = (_amount * exitFees) / 10000; // Exit Fee
        unchecked {
            _transferFeeWithRoyalty(feeAmount, _token, _nftId);
            SafeERC20.safeTransfer(_token, _dest, _amount - feeAmount);
        }
    }

    function _safeWithdraw(address _token, uint256 _nftId) private returns (uint256) {
        uint256 holdingAmount = nestedRecords.getAssetHolding(_nftId, _token);
        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
        reserve.withdraw(IERC20(_token), holdingAmount);
        return IERC20(_token).balanceOf(address(this)) - balanceBefore;
    }

    function _checkMsgValue(BatchedInputOrders[] calldata _batchedOrders) private {
        uint256 ethNeeded;
        for (uint256 i = 0; i < _batchedOrders.length; i++) {
            if (address(_batchedOrders[i].inputToken) == ETH) {
                ethNeeded += _batchedOrders[i].amount;
            }
        }
        require(msg.value == ethNeeded, "NF: WRONG_MSG_VALUE");
    }
}