pragma solidity ^0.6.0;

abstract contract GelatoCoreEnums {

    enum CanExecuteResults {
        ExecutionClaimAlreadyExecutedOrCancelled,
        ExecutionClaimNonExistant,
        ExecutionClaimExpired,
        WrongCalldata,  // also returns if a not-selected executor calls fn
        ConditionNotOk,
        UnhandledConditionError,
        Executable
    }


    enum StandardReason { Ok, NotOk, UnhandledError }
}pragma solidity ^0.6.0;

interface IGelatoAction {

    function actionSelector() external pure returns(bytes4);

    function actionGas() external pure returns(uint256);



    function actionConditionsCheck(bytes calldata _actionPayloadWithSelector)
        external
        view
        returns(string memory);


}pragma solidity ^0.6.0;


interface IGelatoUserProxy {

    function callAccount(address, bytes calldata) external payable returns(bool, bytes memory);

    function delegatecallAccount(address, bytes calldata) external payable returns(bool, bytes memory);


    function delegatecallGelatoAction(
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external
        payable;


    function user() external view returns(address);

    function gelatoCore() external view returns(address);

}pragma solidity ^0.6.0;

interface IGelatoCondition {



    function conditionSelector() external pure returns(bytes4);

    function conditionGas() external pure returns(uint256);

}pragma solidity ^0.6.0;


interface IGelatoCore {


    event LogExecutionClaimMinted(
        address indexed selectedExecutor,
        uint256 indexed executionClaimId,
        address indexed user,
        IGelatoUserProxy userProxy,
        IGelatoCondition condition,
        bytes conditionPayloadWithSelector,
        IGelatoAction action,
        bytes actionPayloadWithSelector,
        uint256[3] conditionGasActionTotalGasMinExecutionGas,
        uint256 executionClaimExpiryDate,
        uint256 mintingDeposit
    );

    event LogCanExecuteSuccess(
        address indexed executor,
        uint256 indexed executionClaimId,
        address indexed user,
        IGelatoCondition condition,
        GelatoCoreEnums.CanExecuteResults canExecuteResult,
        uint8 reason
    );

    event LogCanExecuteFailed(
        address indexed executor,
        uint256 indexed executionClaimId,
        address indexed user,
        IGelatoCondition condition,
        GelatoCoreEnums.CanExecuteResults canExecuteResult,
        uint8 reason
    );

    event LogSuccessfulExecution(
        address indexed executor,
        uint256 indexed executionClaimId,
        address indexed user,
        IGelatoCondition condition,
        IGelatoAction action,
        uint256 gasPriceUsed,
        uint256 executionCostEstimate,
        uint256 executorReward
    );

    event LogExecutionFailure(
        address indexed executor,
        uint256 indexed executionClaimId,
        address payable indexed user,
        IGelatoCondition condition,
        IGelatoAction action,
        string executionFailureReason
    );

    event LogExecutionClaimCancelled(
        uint256 indexed executionClaimId,
        address indexed user,
        address indexed cancelor,
        bool executionClaimExpired
    );

    function mintExecutionClaim(
        address _selectedExecutor,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector
    )
        external
        payable;


    function canExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionTotalGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        view
        returns (GelatoCoreEnums.CanExecuteResults, uint8 reason);



    function execute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionTotalGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external;


    function cancelExecutionClaim(
        address _selectedExecutor,
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionTotalGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external;


    function getCurrentExecutionClaimId() external view returns(uint256 currentId);


    function userProxyWithExecutionClaimId(uint256 _executionClaimId)
        external
        view
        returns(IGelatoUserProxy);


    function getUserWithExecutionClaimId(uint256 _executionClaimId)
        external
        view
        returns(address);


    function executionClaimHash(uint256 _executionClaimId)
        external
        view
        returns(bytes32);


    function gasTestConditionCheck(
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        uint256 _conditionGas
    )
        external
        view
        returns(bool executable, uint8 reason);


    function gasTestCanExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionTotalGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        view
        returns (GelatoCoreEnums.CanExecuteResults canExecuteResult, uint8 reason);


    function gasTestActionViaGasTestUserProxy(
        IGelatoUserProxy _gasTestUserProxy,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external;


    function gasTestGasTestUserProxyExecute(
        IGelatoUserProxy _userProxy,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external;


    function gasTestExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionTotalGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external;

}pragma solidity ^0.6.0;


interface IGelatoUserProxyManager {

    event LogCreateUserProxy(IGelatoUserProxy indexed userProxy, address indexed user);

    function createUserProxy() external returns(IGelatoUserProxy);


    function userCount() external view returns(uint256);

    function userByProxy(address _userProxy) external view returns(address);

    function proxyByUser(address _user) external view returns(IGelatoUserProxy);

    function isUser(address _user) external view returns(bool);

    function isUserProxy(address _userProxy) external view returns(bool);

}
pragma solidity ^0.6.0;


interface IGelatoGasTestUserProxyManager {

    function createGasTestUserProxy() external returns(address gasTestUserProxy);

    function userByGasTestProxy(address _user) external view returns(address);

    function gasTestProxyByUser(address _gasTestProxy) external view returns(address);

}pragma solidity ^0.6.0;


contract GelatoUserProxy is IGelatoUserProxy {

    address public override user;
    address public override gelatoCore;

    constructor(address _user)
        public
        noZeroAddress(_user)
    {
        user = _user;
        gelatoCore = msg.sender;
    }

    modifier onlyUser() {

        require(
            msg.sender == user,
            "GelatoUserProxy.onlyUser: failed"
        );
        _;
    }

    modifier auth() {

        require(
            msg.sender == user || msg.sender == gelatoCore,
            "GelatoUserProxy.auth: failed"
        );
        _;
    }

    modifier noZeroAddress(address _) {

        require(
            _ != address(0),
            "GelatoUserProxy.noZeroAddress"
        );
        _;
    }

    function callAccount(address _account, bytes calldata _payload)
        external
        payable
        override
        onlyUser
        noZeroAddress(_account)
        returns(bool success, bytes memory returndata)
    {

        (success, returndata) = _account.call(_payload);
        require(success, "GelatoUserProxy.call(): failed");
    }

    function delegatecallAccount(address _account, bytes calldata _payload)
        external
        payable
        override
        onlyUser
        noZeroAddress(_account)
        returns(bool success, bytes memory returndata)
    {

        (success, returndata) = _account.delegatecall(_payload);
        require(success, "GelatoUserProxy.delegatecall(): failed");
    }

    function delegatecallGelatoAction(
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external
        payable
        override
        virtual
        auth
        noZeroAddress(address(_action))
    {

        if (gasleft() < _actionGas + 21000) revert("GelatoUserProxy: ActionGasNotOk");
        (bool success,
         bytes memory revertReason) = address(_action).delegatecall.gas(_actionGas)(
             _actionPayloadWithSelector
        );
        assembly {
            revertReason := add(revertReason, 68)
        }
        if (!success) revert(string(revertReason));
    }
}pragma solidity ^0.6.0;


contract GelatoGasTestUserProxy is GelatoUserProxy {


    constructor(address _user) public GelatoUserProxy(_user) {}

    function delegatecallGelatoAction(
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external
        payable
        override
        auth
        noZeroAddress(address(_action))
    {

        uint256 startGas = gasleft();

        if (gasleft() < _actionGas + 21000)
            revert("GelatoGasTestUserProxy.delegatecallGelatoAction: actionGas failed");

        (bool success,
         bytes memory revertReason) = address(_action).delegatecall.gas(_actionGas)(
            _actionPayloadWithSelector
        );
        if (!success) {
            revertReason;  // silence compiler warning
            revert("GelatoGasTestUserProxy.delegatecallGelatoAction: unsuccessful");
        } else { // success
            revert(string(abi.encodePacked(startGas - gasleft())));
        }
    }
}pragma solidity ^0.6.0;


abstract contract GelatoGasTestUserProxyManager is IGelatoGasTestUserProxyManager {

    mapping(address => address) public override userByGasTestProxy;
    mapping(address => address) public override gasTestProxyByUser;

    modifier gasTestProxyCheck(address _) {
        require(_isGasTestProxy(_), "GelatoGasTestUserProxyManager.isGasTestProxy");
        _;
    }

    function createGasTestUserProxy()
        external
        override
        returns(address gasTestUserProxy)
    {
        gasTestUserProxy = address(new GelatoGasTestUserProxy(msg.sender));
        userByGasTestProxy[msg.sender] = gasTestUserProxy;
        gasTestProxyByUser[gasTestUserProxy] = msg.sender;
    }

    function _isGasTestProxy(address _) private view returns(bool) {
        return gasTestProxyByUser[_] != address(0);
    }
}pragma solidity ^0.6.0;


abstract contract GelatoUserProxyManager is IGelatoUserProxyManager, GelatoGasTestUserProxyManager {

    uint256 public override userCount;
    mapping(address => address) public override userByProxy;
    mapping(address => IGelatoUserProxy) public override proxyByUser;
    address[] public users;
    IGelatoUserProxy[] public userProxies;

    modifier userHasNoProxy {
        require(
            userByProxy[msg.sender] == address(0),
            "GelatoUserProxyManager: user already has a proxy"
        );
        _;
    }

    modifier userProxyCheck(IGelatoUserProxy _userProxy) {
        require(
            _isUserProxy(address(_userProxy)),
            "GelatoUserProxyManager.userProxyCheck: _userProxy not registered"
        );
        _;
    }

    function createUserProxy()
        external
        override
        userHasNoProxy
        returns(IGelatoUserProxy userProxy)
    {
        userProxy = new GelatoUserProxy(msg.sender);
        userByProxy[address(userProxy)] = msg.sender;
        proxyByUser[msg.sender] = userProxy;
        users.push(msg.sender);
        userProxies.push(userProxy);
        userCount++;
        emit LogCreateUserProxy(userProxy, msg.sender);
    }

    function isUser(address _user)
        external
        view
        override
        returns(bool)
    {
        return _isUser(_user);
    }

    function isUserProxy(address _userProxy)
        external
        view
        override
        returns(bool)
    {
        return _isUserProxy(_userProxy);
    }

    function _isUser(address _user)
        internal
        view
        returns(bool)
    {
        return proxyByUser[_user] != IGelatoUserProxy(0);
    }

    function _isUserProxy(address _userProxy)
        internal
        view
        returns(bool)
    {
        return userByProxy[_userProxy] != address(0);
    }
}
pragma solidity ^0.6.0;


interface IGelatoCoreAccounting {


    event LogRegisterExecutor(
        address payable indexed executor,
        uint256 executorPrice,
        uint256 executorClaimLifespan
    );

    event LogDeregisterExecutor(address payable indexed executor);

    event LogSetExecutorPrice(uint256 executorPrice, uint256 newExecutorPrice);

    event LogSetExecutorClaimLifespan(
        uint256 executorClaimLifespan,
        uint256 newExecutorClaimLifespan
    );

    event LogWithdrawExecutorBalance(
        address indexed executor,
        uint256 withdrawAmount
    );

    event LogSetMinExecutionClaimLifespan(
        uint256 minExecutionClaimLifespan,
        uint256 newMinExecutionClaimLifespan
    );

    event LogSetGelatoCoreExecGasOverhead(
        uint256 gelatoCoreExecGasOverhead,
        uint256 _newGasOverhead
    );

    event LogSetUserProxyExecGasOverhead(
        uint256 userProxyExecGasOverhead,
        uint256 _newGasOverhead
    );

    function registerExecutor(uint256 _executorPrice, uint256 _executorClaimLifespan) external;


    function deregisterExecutor() external;


    function setExecutorPrice(uint256 _newExecutorGasPrice) external;


    function setExecutorClaimLifespan(uint256 _newExecutorClaimLifespan) external;


    function withdrawExecutorBalance() external;


    function minExecutionClaimLifespan() external view returns(uint256);


    function executorPrice(address _executor) external view returns(uint256);


    function executorClaimLifespan(address _executor) external view returns(uint256);


    function executorBalance(address _executor) external view returns(uint256);


    function gelatoCoreExecGasOverhead() external pure returns(uint256);


    function userProxyExecGasOverhead() external pure returns(uint256);


    function totalExecutionGasOverhead() external pure returns(uint256);


    function getMintingDepositPayable(
        address _selectedExecutor,
        IGelatoCondition _condition,
        IGelatoAction _action
    )
        external
        view
        returns(uint256 mintingDepositPayable);


    function getMinExecutionGas(uint256 _conditionGas, uint256 _actionGas)
        external
        pure
        returns(uint256);

}pragma solidity ^0.6.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.6.0;

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
pragma solidity ^0.6.0;


abstract contract GelatoCoreAccounting is IGelatoCoreAccounting {

    using Address for address payable;  /// for oz's sendValue method
    using SafeMath for uint256;

    mapping(address => uint256) public override executorPrice;
    mapping(address => uint256) public override executorClaimLifespan;
    mapping(address => uint256) public override executorBalance;
    uint256 public constant override minExecutionClaimLifespan = 10 minutes;
    uint256 public constant override gelatoCoreExecGasOverhead = 80000;
    uint256 public constant override userProxyExecGasOverhead = 40000;
    uint256 public constant override totalExecutionGasOverhead = (
        gelatoCoreExecGasOverhead + userProxyExecGasOverhead
    );

    function registerExecutor(
        uint256 _executorPrice,
        uint256 _executorClaimLifespan
    )
        external
        override
    {
        require(
            _executorClaimLifespan >= minExecutionClaimLifespan,
            "GelatoCoreAccounting.registerExecutor: _executorClaimLifespan cannot be 0"
        );
        executorPrice[msg.sender] = _executorPrice;
        executorClaimLifespan[msg.sender] = _executorClaimLifespan;
        emit LogRegisterExecutor(
            msg.sender,
            _executorPrice,
            _executorClaimLifespan
        );
    }

    modifier onlyRegisteredExecutors(address _executor) {
        require(
            executorClaimLifespan[_executor] != 0,
            "GelatoCoreAccounting.onlyRegisteredExecutors: failed"
        );
        _;
    }

    function deregisterExecutor()
        external
        override
        onlyRegisteredExecutors(msg.sender)
    {
        executorPrice[msg.sender] = 0;
        executorClaimLifespan[msg.sender] = 0;
        emit LogDeregisterExecutor(msg.sender);
    }

    function setExecutorPrice(uint256 _newExecutorGasPrice)
        external
        override
    {
        emit LogSetExecutorPrice(executorPrice[msg.sender], _newExecutorGasPrice);
        executorPrice[msg.sender] = _newExecutorGasPrice;
    }

    function setExecutorClaimLifespan(uint256 _newExecutorClaimLifespan)
        external
        override
    {
        require(
            _newExecutorClaimLifespan >= minExecutionClaimLifespan,
            "GelatoCoreAccounting.setExecutorClaimLifespan: failed"
        );
        emit LogSetExecutorClaimLifespan(
            executorClaimLifespan[msg.sender],
            _newExecutorClaimLifespan
        );
        executorClaimLifespan[msg.sender] = _newExecutorClaimLifespan;
    }

    function withdrawExecutorBalance()
        external
        override
    {
        uint256 currentExecutorBalance = executorBalance[msg.sender];
        require(
            currentExecutorBalance > 0,
            "GelatoCoreAccounting.withdrawExecutorBalance: failed"
        );
        executorBalance[msg.sender] = 0;
        msg.sender.sendValue(currentExecutorBalance);
        emit LogWithdrawExecutorBalance(msg.sender, currentExecutorBalance);
    }

    function getMintingDepositPayable(
        address _selectedExecutor,
        IGelatoCondition _condition,
        IGelatoAction _action
    )
        external
        view
        override
        onlyRegisteredExecutors(_selectedExecutor)
        returns(uint256 mintingDepositPayable)
    {
        uint256 conditionGas = _condition.conditionGas();
        uint256 actionGas = _action.actionGas();
        uint256 executionMinGas = _getMinExecutionGas(conditionGas, actionGas);
        mintingDepositPayable = executionMinGas.mul(executorPrice[_selectedExecutor]);
    }

    function getMinExecutionGas(uint256 _conditionGas, uint256 _actionGas)
        external
        pure
        override
        returns(uint256)
    {
        return _getMinExecutionGas(_conditionGas, _actionGas);
    }

    function _getMinExecutionGas(uint256 _conditionGas, uint256 _actionGas)
        internal
        pure
        returns(uint256)
    {
        return totalExecutionGasOverhead.add(_conditionGas).add(_actionGas);
    }
}pragma solidity ^0.6.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}
pragma solidity ^0.6.0;


contract GelatoCore is IGelatoCore, GelatoUserProxyManager, GelatoCoreAccounting {


    using Counters for Counters.Counter;
    using Address for address payable;  /// for oz's sendValue method

    Counters.Counter private executionClaimIds;
    mapping(uint256 => IGelatoUserProxy) public override userProxyWithExecutionClaimId;
    mapping(uint256 => bytes32) public override executionClaimHash;

    function mintExecutionClaim(
        address _selectedExecutor,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector
    )
        external
        payable
        override
        onlyRegisteredExecutors(_selectedExecutor)
    {

        IGelatoUserProxy userProxy;
        if (_isUser(msg.sender)) userProxy = proxyByUser[msg.sender];
        else if (_isUserProxy(msg.sender)) userProxy = IGelatoUserProxy(msg.sender);
        else revert("GelatoCore.mintExecutionClaim: msg.sender is not proxied");
        uint256[3] memory conditionGasActionGasMinExecutionGas;
        {
            uint256 conditionGas = _condition.conditionGas();
            require(conditionGas != 0, "GelatoCore.mintExecutionClaim: 0 conditionGas");
            conditionGasActionGasMinExecutionGas[0] = conditionGas;

            uint256 actionGas = _action.actionGas();
            require(actionGas != 0, "GelatoCore.mintExecutionClaim: 0 actionGas");
            conditionGasActionGasMinExecutionGas[1] = actionGas;

            uint256 minExecutionGas = _getMinExecutionGas(conditionGas, actionGas);
            conditionGasActionGasMinExecutionGas[2] = minExecutionGas;

            require(
                msg.value == minExecutionGas.mul(executorPrice[_selectedExecutor]),
                "GelatoCore.mintExecutionClaim: msg.value failed"
            );
        }

        executionClaimIds.increment();
        uint256 executionClaimId = executionClaimIds.current();
        userProxyWithExecutionClaimId[executionClaimId] = userProxy;
        uint256 executionClaimExpiryDate = now.add(executorClaimLifespan[_selectedExecutor]);

        executionClaimHash[executionClaimId] = _computeExecutionClaimHash(
            _selectedExecutor,
            executionClaimId,
            msg.sender, // user
            userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            conditionGasActionGasMinExecutionGas,
            executionClaimExpiryDate,
            msg.value
        );

        emit LogExecutionClaimMinted(
            _selectedExecutor,
            executionClaimId,
            msg.sender,  // _user
            userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            conditionGasActionGasMinExecutionGas,
            executionClaimExpiryDate,
            msg.value
        );
    }

    function canExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        view
        override
        returns (GelatoCoreEnums.CanExecuteResults, uint8 reason)
    {

        return _canExecute(
            _executionClaimId,
            _user,
            _userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas,
            _executionClaimExpiryDate,
            _mintingDeposit
        );
    }

    function execute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        override
    {

        return _execute(
            _executionClaimId,
            _user,
            _userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas,
            _executionClaimExpiryDate,
            _mintingDeposit
        );
    }

    function cancelExecutionClaim(
        address _selectedExecutor,
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        override
    {

        bool executionClaimExpired = _executionClaimExpiryDate <= now;
        if (msg.sender != _user) {
            require(
                executionClaimExpired && msg.sender == _selectedExecutor,
                "GelatoCore.cancelExecutionClaim: msgSender problem"
            );
        }
        bytes32 computedExecutionClaimHash = _computeExecutionClaimHash(
            _selectedExecutor,
            _executionClaimId,
            _user,
            _userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas,
            _executionClaimExpiryDate,
            _mintingDeposit
        );
        require(
            computedExecutionClaimHash == executionClaimHash[_executionClaimId],
            "GelatoCore.cancelExecutionClaim: hash compare failed"
        );
        delete userProxyWithExecutionClaimId[_executionClaimId];
        delete executionClaimHash[_executionClaimId];
        emit LogExecutionClaimCancelled(
            _executionClaimId,
            _user,
            msg.sender,
            executionClaimExpired
        );
        msg.sender.sendValue(_mintingDeposit);
    }

    function getCurrentExecutionClaimId()
        external
        view
        override
        returns(uint256 currentId)
    {

        currentId = executionClaimIds.current();
    }

    function getUserWithExecutionClaimId(uint256 _executionClaimId)
        external
        view
        override
        returns(address)
    {

        IGelatoUserProxy userProxy = userProxyWithExecutionClaimId[_executionClaimId];
        return userByProxy[address(userProxy)];
    }


    function _canExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes memory _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes memory _actionPayloadWithSelector,
        uint256[3] memory _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        private
        view
        returns (GelatoCoreEnums.CanExecuteResults, uint8 reason)
    {

        if (executionClaimHash[_executionClaimId] == bytes32(0)) {
            if (_executionClaimId <= executionClaimIds.current()) {
                return (
                    GelatoCoreEnums.CanExecuteResults.ExecutionClaimAlreadyExecutedOrCancelled,
                    uint8(GelatoCoreEnums.StandardReason.NotOk)
                );
            } else {
                return (
                    GelatoCoreEnums.CanExecuteResults.ExecutionClaimNonExistant,
                    uint8(GelatoCoreEnums.StandardReason.NotOk)
                );
            }
        }

        if (_executionClaimExpiryDate < now) {
            return (
                GelatoCoreEnums.CanExecuteResults.ExecutionClaimExpired,
                uint8(GelatoCoreEnums.StandardReason.NotOk)
            );
        }

        bytes32 computedExecutionClaimHash = _computeExecutionClaimHash(
            msg.sender,  // selected? executor
            _executionClaimId,
            _user,
            _userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas,
            _executionClaimExpiryDate,
            _mintingDeposit
        );

        if (computedExecutionClaimHash != executionClaimHash[_executionClaimId]) {
            return (
                GelatoCoreEnums.CanExecuteResults.WrongCalldata,
                uint8(GelatoCoreEnums.StandardReason.NotOk)
            );
        }

        (bool success, bytes memory returndata)
            = address(_condition).staticcall.gas(_conditionGasActionGasMinExecutionGas[0])(
                _conditionPayloadWithSelector
        );

        if (!success) {
            return (
                GelatoCoreEnums.CanExecuteResults.UnhandledConditionError,
                uint8(GelatoCoreEnums.StandardReason.UnhandledError)
            );
        } else {
            bool conditionReached;
            (conditionReached, reason) = abi.decode(returndata, (bool, uint8));
            if (!conditionReached) return (GelatoCoreEnums.CanExecuteResults.ConditionNotOk, reason);
            else return (GelatoCoreEnums.CanExecuteResults.Executable, reason);
        }
    }

    function _execute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes memory _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes memory _actionPayloadWithSelector,
        uint256[3] memory _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        private
    {

        uint256 startGas = gasleft();
        require(
            startGas >= _conditionGasActionGasMinExecutionGas[2].sub(30000),
            "GelatoCore._execute: Insufficient gas sent"
        );

        {
            GelatoCoreEnums.CanExecuteResults canExecuteResult;
            uint8 canExecuteReason;
            (canExecuteResult, canExecuteReason) = _canExecute(
                _executionClaimId,
                _user,
                _userProxy,
                _condition,
                _conditionPayloadWithSelector,
                _action,
                _actionPayloadWithSelector,
                _conditionGasActionGasMinExecutionGas,
                _executionClaimExpiryDate,
                _mintingDeposit
            );

            if (canExecuteResult == GelatoCoreEnums.CanExecuteResults.Executable) {
                emit LogCanExecuteSuccess(
                    msg.sender,
                    _executionClaimId,
                    _user,
                    _condition,
                    canExecuteResult,
                    canExecuteReason
                );
            } else {
                emit LogCanExecuteFailed(
                    msg.sender,
                    _executionClaimId,
                    _user,
                    _condition,
                    canExecuteResult,
                    canExecuteReason
                );
                return;  // END OF EXECUTION
            }
        }

        delete executionClaimHash[_executionClaimId];
        delete userProxyWithExecutionClaimId[_executionClaimId];

        bool actionExecuted;
        string memory executionFailureReason;
        try _userProxy.delegatecallGelatoAction(
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas[1]
        ) {
            actionExecuted = true;
        } catch Error(string memory revertReason) {
            executionFailureReason = revertReason;
        } catch {
            executionFailureReason = "UnhandledUserProxyError";
        }

        if (actionExecuted) {
            emit LogSuccessfulExecution(
                msg.sender,  // executor
                _executionClaimId,
                _user,
                _condition,
                _action,
                tx.gasprice,
                (startGas.sub(gasleft())).mul(tx.gasprice),
                _mintingDeposit  // executorReward
            );
            executorBalance[msg.sender] = executorBalance[msg.sender].add(_mintingDeposit);
        } else {
            address payable payableUser = address(uint160(_user));
            emit LogExecutionFailure(
                msg.sender,
                _executionClaimId,
                payableUser,
                _condition,
                _action,
                executionFailureReason
            );
            payableUser.sendValue(_mintingDeposit);
        }
    }

    function _computeExecutionClaimHash(
        address _selectedExecutor,
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes memory _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes memory _actionPayloadWithSelector,
        uint256[3] memory _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        private
        pure
        returns(bytes32)
    {

        return keccak256(
            abi.encodePacked(
                _selectedExecutor,
                _executionClaimId,
                _user,
                _userProxy,
                _condition,
                _conditionPayloadWithSelector,
                _action,
                _actionPayloadWithSelector,
                _conditionGasActionGasMinExecutionGas,
                _executionClaimExpiryDate,
                _mintingDeposit
            )
        );
    }

    function gasTestConditionCheck(
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        uint256 _conditionGas
    )
        external
        view
        override
        returns(bool conditionReached, uint8 reason)
    {

        uint256 startGas = gasleft();
        (bool success,
         bytes memory returndata) = address(_condition).staticcall.gas(_conditionGas)(
            _conditionPayloadWithSelector
        );
        if (!success) revert("GelatoCore.gasTestConditionCheck: Unhandled Error/wrong Args");
        else (conditionReached, reason) = abi.decode(returndata, (bool, uint8));
        if (conditionReached) revert(string(abi.encodePacked(startGas - gasleft())));
        else revert("GelatoCore.gasTestConditionCheck: Not Executable/wrong Args");
    }

    function gasTestCanExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        view
        override
        returns (GelatoCoreEnums.CanExecuteResults canExecuteResult, uint8 reason)
    {

        uint256 startGas = gasleft();
        (canExecuteResult, reason) = _canExecute(
            _executionClaimId,
            _user,
            _userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas,
            _executionClaimExpiryDate,
            _mintingDeposit
        );
        if (canExecuteResult == GelatoCoreEnums.CanExecuteResults.Executable)
            revert(string(abi.encodePacked(startGas - gasleft())));
        revert("GelatoCore.gasTestCanExecute: Not Executable/Wrong Args");
    }

    function gasTestActionViaGasTestUserProxy(
        IGelatoUserProxy _gasTestUserProxy,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external
        override
        gasTestProxyCheck(address(_gasTestUserProxy))
    {

        _gasTestUserProxy.delegatecallGelatoAction(
            _action,
            _actionPayloadWithSelector,
            _actionGas
        );
        revert("GelatoCore.gasTestActionViaGasTestUserProxy: did not revert");
    }

    function gasTestGasTestUserProxyExecute(
        IGelatoUserProxy _userProxy,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external
        override
        userProxyCheck(_userProxy)
    {

        uint256 startGas = gasleft();
        bool actionExecuted;
        string memory executionFailureReason;
        try _userProxy.delegatecallGelatoAction(
            _action,
            _actionPayloadWithSelector,
            _actionGas
        ) {
            actionExecuted = true;
            revert(string(abi.encodePacked(startGas - gasleft())));
        } catch Error(string memory reason) {
            executionFailureReason = reason;
            revert("GelatoCore.gasTestTestUserProxyExecute: Defined Error Caught");
        } catch {
            revert("GelatoCore.gasTestTestUserProxyExecute: Undefined Error Caught");
        }
    }

    function gasTestExecute(
        uint256 _executionClaimId,
        address _user,
        IGelatoUserProxy _userProxy,
        IGelatoCondition _condition,
        bytes calldata _conditionPayloadWithSelector,
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256[3] calldata _conditionGasActionGasMinExecutionGas,
        uint256 _executionClaimExpiryDate,
        uint256 _mintingDeposit
    )
        external
        override
    {

        uint256 startGas = gasleft();
        _execute(
            _executionClaimId,
            _user,
            _userProxy,
            _condition,
            _conditionPayloadWithSelector,
            _action,
            _actionPayloadWithSelector,
            _conditionGasActionGasMinExecutionGas,
            _executionClaimExpiryDate,
            _mintingDeposit
        );
        revert(string(abi.encodePacked(startGas - gasleft())));
    }
}