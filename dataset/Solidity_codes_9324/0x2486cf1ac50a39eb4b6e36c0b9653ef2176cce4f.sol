


pragma solidity ^0.5.0;

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




pragma solidity 0.5.12;

contract ITraderOperators {

    function isTrader(address _account) external view returns (bool);


    function addTrader(address _account) external;


    function removeTrader(address _account) external;

}




pragma solidity 0.5.12;

interface IBaseOperators {

    function isOperator(address _account) external view returns (bool);


    function isAdmin(address _account) external view returns (bool);


    function isSystem(address _account) external view returns (bool);


    function isRelay(address _account) external view returns (bool);


    function isMultisig(address _contract) external view returns (bool);


    function confirmFor(address _address) external;


    function addOperator(address _account) external;


    function removeOperator(address _account) external;


    function addAdmin(address _account) external;


    function removeAdmin(address _account) external;


    function addSystem(address _account) external;


    function removeSystem(address _account) external;


    function addRelay(address _account) external;


    function removeRelay(address _account) external;


    function addOperatorAndAdmin(address _account) external;


    function removeOperatorAndAdmin(address _account) external;

}



pragma solidity 0.5.12;

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Initializable: Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    function isInitialized() public view returns (bool) {

        return initialized;
    }

    uint256[50] private ______gap;
}




pragma solidity 0.5.12;


contract Operatorable is Initializable {

    IBaseOperators internal operatorsInst;
    address private operatorsPending;

    event OperatorsContractChanged(address indexed caller, address indexed operatorsAddress);
    event OperatorsContractPending(address indexed caller, address indexed operatorsAddress);

    modifier onlyOperator() {

        require(isOperator(msg.sender), "Operatorable: caller does not have the operator role");
        _;
    }

    modifier onlyAdmin() {

        require(isAdmin(msg.sender), "Operatorable: caller does not have the admin role");
        _;
    }

    modifier onlySystem() {

        require(isSystem(msg.sender), "Operatorable: caller does not have the system role");
        _;
    }

    modifier onlyMultisig() {

        require(isMultisig(msg.sender), "Operatorable: caller does not have multisig role");
        _;
    }

    modifier onlyAdminOrSystem() {

        require(isAdminOrSystem(msg.sender), "Operatorable: caller does not have the admin role nor system");
        _;
    }

    modifier onlyOperatorOrSystem() {

        require(isOperatorOrSystem(msg.sender), "Operatorable: caller does not have the operator role nor system");
        _;
    }

    modifier onlyRelay() {

        require(isRelay(msg.sender), "Operatorable: caller does not have relay role associated");
        _;
    }

    modifier onlyOperatorOrRelay() {

        require(
            isOperator(msg.sender) || isRelay(msg.sender),
            "Operatorable: caller does not have the operator role nor relay"
        );
        _;
    }

    modifier onlyAdminOrRelay() {

        require(
            isAdmin(msg.sender) || isRelay(msg.sender),
            "Operatorable: caller does not have the admin role nor relay"
        );
        _;
    }

    modifier onlyOperatorOrSystemOrRelay() {

        require(
            isOperator(msg.sender) || isSystem(msg.sender) || isRelay(msg.sender),
            "Operatorable: caller does not have the operator role nor system nor relay"
        );
        _;
    }

    function initialize(address _baseOperators) public initializer {

        _setOperatorsContract(_baseOperators);
    }

    function setOperatorsContract(address _baseOperators) public onlyAdmin {

        require(_baseOperators != address(0), "Operatorable: address of new operators contract can not be zero");
        operatorsPending = _baseOperators;
        emit OperatorsContractPending(msg.sender, _baseOperators);
    }

    function confirmOperatorsContract() public {

        require(operatorsPending != address(0), "Operatorable: address of new operators contract can not be zero");
        require(msg.sender == operatorsPending, "Operatorable: should be called from new operators contract");
        _setOperatorsContract(operatorsPending);
    }

    function getOperatorsContract() public view returns (address) {

        return address(operatorsInst);
    }

    function getOperatorsPending() public view returns (address) {

        return operatorsPending;
    }

    function isOperator(address _account) public view returns (bool) {

        return operatorsInst.isOperator(_account);
    }

    function isAdmin(address _account) public view returns (bool) {

        return operatorsInst.isAdmin(_account);
    }

    function isSystem(address _account) public view returns (bool) {

        return operatorsInst.isSystem(_account);
    }

    function isRelay(address _account) public view returns (bool) {

        return operatorsInst.isRelay(_account);
    }

    function isMultisig(address _contract) public view returns (bool) {

        return operatorsInst.isMultisig(_contract);
    }

    function isAdminOrSystem(address _account) public view returns (bool) {

        return (operatorsInst.isAdmin(_account) || operatorsInst.isSystem(_account));
    }

    function isOperatorOrSystem(address _account) public view returns (bool) {

        return (operatorsInst.isOperator(_account) || operatorsInst.isSystem(_account));
    }

    function _setOperatorsContract(address _baseOperators) internal {

        require(_baseOperators != address(0), "Operatorable: address of new operators contract cannot be zero");
        operatorsInst = IBaseOperators(_baseOperators);
        emit OperatorsContractChanged(msg.sender, _baseOperators);
    }
}




pragma solidity 0.5.12;



contract TraderOperatorable is Operatorable {

    ITraderOperators internal traderOperatorsInst;
    address private traderOperatorsPending;

    event TraderOperatorsContractChanged(address indexed caller, address indexed traderOperatorsAddress);
    event TraderOperatorsContractPending(address indexed caller, address indexed traderOperatorsAddress);

    modifier onlyTrader() {

        require(isTrader(msg.sender), "TraderOperatorable: caller is not trader");
        _;
    }

    modifier onlyOperatorOrTraderOrSystem() {

        require(
            isOperator(msg.sender) || isTrader(msg.sender) || isSystem(msg.sender),
            "TraderOperatorable: caller is not trader or operator or system"
        );
        _;
    }

    function initialize(address _baseOperators, address _traderOperators) public initializer {

        super.initialize(_baseOperators);
        _setTraderOperatorsContract(_traderOperators);
    }

    function setTraderOperatorsContract(address _traderOperators) public onlyAdmin {

        require(
            _traderOperators != address(0),
            "TraderOperatorable: address of new traderOperators contract can not be zero"
        );
        traderOperatorsPending = _traderOperators;
        emit TraderOperatorsContractPending(msg.sender, _traderOperators);
    }

    function confirmTraderOperatorsContract() public {

        require(
            traderOperatorsPending != address(0),
            "TraderOperatorable: address of pending traderOperators contract can not be zero"
        );
        require(
            msg.sender == traderOperatorsPending,
            "TraderOperatorable: should be called from new traderOperators contract"
        );
        _setTraderOperatorsContract(traderOperatorsPending);
    }

    function getTraderOperatorsContract() public view returns (address) {

        return address(traderOperatorsInst);
    }

    function getTraderOperatorsPending() public view returns (address) {

        return traderOperatorsPending;
    }

    function isTrader(address _account) public view returns (bool) {

        return traderOperatorsInst.isTrader(_account);
    }

    function _setTraderOperatorsContract(address _traderOperators) internal {

        require(
            _traderOperators != address(0),
            "TraderOperatorable: address of new traderOperators contract can not be zero"
        );
        traderOperatorsInst = ITraderOperators(_traderOperators);
        emit TraderOperatorsContractChanged(msg.sender, _traderOperators);
    }
}



pragma solidity 0.5.12;

contract Pausable is TraderOperatorable {

    event Paused(address indexed account);
    event Unpaused(address indexed account);

    bool internal _paused;

    constructor() internal {
        _paused = false;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyOperatorOrTraderOrSystem whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOperatorOrTraderOrSystem whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function isPaused() public view returns (bool) {

        return _paused;
    }

    function isNotPaused() public view returns (bool) {

        return !_paused;
    }
}




pragma solidity 0.5.12;

contract IRaiseOperators {

    function isInvestor(address _account) external view returns (bool);


    function isIssuer(address _account) external view returns (bool);


    function addInvestor(address _account) external;


    function removeInvestor(address _account) external;


    function addIssuer(address _account) external;


    function removeIssuer(address _account) external;

}




pragma solidity 0.5.12;



contract RaiseOperatorable is Operatorable {

    IRaiseOperators internal raiseOperatorsInst;
    address private raiseOperatorsPending;

    event RaiseOperatorsContractChanged(address indexed caller, address indexed raiseOperatorsAddress);
    event RaiseOperatorsContractPending(address indexed caller, address indexed raiseOperatorsAddress);

    modifier onlyInvestor() {

        require(isInvestor(msg.sender), "RaiseOperatorable: caller is not investor");
        _;
    }

    modifier onlyIssuer() {

        require(isIssuer(msg.sender), "RaiseOperatorable: caller is not issuer");
        _;
    }

    function initialize(address _baseOperators, address _raiseOperators) public initializer {

        super.initialize(_baseOperators);
        _setRaiseOperatorsContract(_raiseOperators);
    }

    function setRaiseOperatorsContract(address _raiseOperators) public onlyAdmin {

        require(
            _raiseOperators != address(0),
            "RaiseOperatorable: address of new raiseOperators contract can not be zero"
        );
        raiseOperatorsPending = _raiseOperators;
        emit RaiseOperatorsContractPending(msg.sender, _raiseOperators);
    }

    function confirmRaiseOperatorsContract() public {

        require(
            raiseOperatorsPending != address(0),
            "RaiseOperatorable: address of pending raiseOperators contract can not be zero"
        );
        require(
            msg.sender == raiseOperatorsPending,
            "RaiseOperatorable: should be called from new raiseOperators contract"
        );
        _setRaiseOperatorsContract(raiseOperatorsPending);
    }

    function getRaiseOperatorsContract() public view returns (address) {

        return address(raiseOperatorsInst);
    }

    function getRaiseOperatorsPending() public view returns (address) {

        return raiseOperatorsPending;
    }

    function isInvestor(address _account) public view returns (bool) {

        return raiseOperatorsInst.isInvestor(_account);
    }

    function isIssuer(address _account) public view returns (bool) {

        return raiseOperatorsInst.isIssuer(_account);
    }

    function _setRaiseOperatorsContract(address _raiseOperators) internal {

        require(
            _raiseOperators != address(0),
            "RaiseOperatorable: address of new raiseOperators contract can not be zero"
        );
        raiseOperatorsInst = IRaiseOperators(_raiseOperators);
        emit RaiseOperatorsContractChanged(msg.sender, _raiseOperators);
    }
}



pragma solidity ^0.5.0;

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




pragma solidity 0.5.12;

contract CappedRaise {

    using SafeMath for uint256;

    uint256 private minCap;
    uint256 private maxCap;
    uint256 private sold;
    address[] private receivers;

    mapping(address => uint256) private shares;

    function _setCap(uint256 _minCap, uint256 _maxCap) internal {

        require(_minCap > 0, "CappedRaise: minimum cap must exceed zero");
        require(_maxCap > _minCap, "CappedRaise: maximum cap must exceed minimum cap");
        minCap = _minCap;
        maxCap = _maxCap;
    }

    function _updateSold(address _receiver, uint256 _shares) internal {

        shares[_receiver] = shares[_receiver].add(_shares);
        sold = sold.add(_shares);

        receivers.push(_receiver);
    }

    function getMaxCap() public view returns (uint256) {

        return maxCap;
    }

    function getMinCap() public view returns (uint256) {

        return minCap;
    }

    function getSold() public view returns (uint256) {

        return sold;
    }

    function getReceiversLength() public view returns (uint256) {

        return receivers.length;
    }

    function getReceiver(uint256 _index) public view returns (address) {

        return receivers[_index];
    }

    function getReceiversBatch(uint256 _start, uint256 _end) public view returns (address[] memory) {

        require(_start < _end, "CappedRaise: Wrong receivers array indices");
        require(_end.sub(_start) <= 256, "CappedRaise: Greater than block limit");
        address[] memory _receivers = new address[](_end.sub(_start));
        for (uint256 _i = 0; _i < _end.sub(_start); _i++) {
            _receivers[_i] = _i.add(_start) < receivers.length ? receivers[_i.add(_start)] : address(0);
        }
        return _receivers;
    }

    function getAvailableShares() public view returns (uint256) {

        return maxCap.sub(sold);
    }

    function getShares(address _receiver) public view returns (uint256) {

        return shares[_receiver];
    }

    function maxCapReached() public view returns (bool) {

        return sold >= maxCap;
    }

    function maxCapWouldBeReached(uint256 _newInvestment) public view returns (bool) {

        return sold.add(_newInvestment) > maxCap;
    }

    function minCapReached() public view returns (bool) {

        return sold >= minCap;
    }
}




pragma solidity 0.5.12;

contract TimedRaise {

    using SafeMath for uint256;

    uint256 private openingTime;
    uint256 private closingTime;

    modifier onlyWhileOpen {

        require(isOpen(), "TimedRaise: not open");
        _;
    }

    modifier onlyWhenClosed {

        require(hasClosed(), "TimedRaise: not closed");
        _;
    }

    function _setTime(uint256 _openingTime, uint256 _closingTime) internal {

        require(_openingTime >= block.timestamp, "TimedRaise: opening time is before current time");
        require(_closingTime > _openingTime, "TimedRaise: opening time is not before closing time");

        openingTime = _openingTime;
        closingTime = _closingTime;
    }

    function getOpening() public view returns (uint256) {

        return openingTime;
    }

    function getClosing() public view returns (uint256) {

        return closingTime;
    }

    function isOpen() public view returns (bool) {

        return now >= openingTime && now <= closingTime;
    }

    function hasClosed() public view returns (bool) {

        return now > closingTime;
    }
}



pragma solidity 0.5.12;


library Bytes32Set {

    struct Set {
        mapping(bytes32 => uint256) keyPointers;
        bytes32[] keyList;
    }

    function insert(Set storage self, bytes32 key) internal {

        require(!exists(self, key), "Bytes32Set: key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    function remove(Set storage self, bytes32 key) internal {

        require(exists(self, key), "Bytes32Set: key does not exist in the set.");
        uint256 last = count(self) - 1;
        uint256 rowToReplace = self.keyPointers[key];
        if (rowToReplace != last) {
            bytes32 keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    function count(Set storage self) internal view returns (uint256) {

        return (self.keyList.length);
    }

    function exists(Set storage self, bytes32 key) internal view returns (bool) {

        if (self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint256 index) internal view returns (bytes32) {

        return self.keyList[index];
    }
}




pragma solidity 0.5.12;





contract Raise is RaiseOperatorable, CappedRaise, TimedRaise, Pausable {

    using SafeMath for uint256;
    using Bytes32Set for Bytes32Set.Set;

    IERC20 public dchf;
    address public issuer;
    uint256 public price;
    uint256 public minSubscription;
    uint256 public totalPendingDeposits;
    uint256 public totalDeclinedDeposits;
    uint256 public totalAcceptedDeposits;
    uint256 public decimals;
    bool public issuerPaid;

    mapping(bytes32 => Subscription) public subscription;
    mapping(bool => Bytes32Set.Set) internal subscriptions;
    mapping(address => mapping(bool => Bytes32Set.Set)) internal investor;

    Stage public stage;
    enum Stage {Created, RepayAll, IssuerAccepted, OperatorAccepted, Closed}

    struct Subscription {
        address investor;
        uint256 shares;
        uint256 cost;
    }

    uint16 internal constant BATCH_LIMIT = 256;

    event SubscriptionProposal(address indexed issuer, address indexed investor, bytes32 subID);
    event SubscriptionAccepted(address indexed payee, bytes32 subID, uint256 shares, uint256 cost);
    event SubscriptionDeclined(address indexed payee, bytes32 subID, uint256 cost);
    event RaiseClosed(address indexed issuer, bool accepted);
    event OperatorRaiseFinalization(address indexed issuer, bool accepted);
    event IssuerPaid(address indexed issuer, uint256 amount);
    event OperatorClosed(address indexed operator);
    event UnsuccessfulRaise(address indexed issuer);
    event ReleasedPending(address indexed investor, uint256 amount);
    event ReleasedEmergency(address indexed investor, uint256 amount);

    modifier onlyIssuer() {

        require(msg.sender == issuer, "Raise: caller not issuer");
        _;
    }

    modifier onlyAtStage(Stage _stage) {

        require(stage == _stage, "Raise: not at correct stage");
        _;
    }

    function initialize(
        IERC20 _dchf,
        address _issuer,
        uint256 _min,
        uint256 _max,
        uint256 _price,
        uint256 _minSubscription,
        uint256 _decimals,
        uint256 _open,
        uint256 _close,
        address _baseOperators,
        address _raiseOperators
    ) public initializer {

        dchf = _dchf;
        price = _price;
        issuer = _issuer;
        _setCap(_min, _max);
        _setTime(_open, _close);
        minSubscription = _minSubscription;
        RaiseOperatorable.initialize(_baseOperators, _raiseOperators);
        decimals = _decimals;
    }

    function subscribe(bytes32 _subID, uint256 _shares)
        public
        whenNotPaused
        onlyInvestor
        onlyAtStage(Stage.Created)
        onlyWhileOpen
    {

        require(_shares <= getAvailableShares(), "Raise: above available");

        uint256 cost = _shares.mul(price);

        require(cost >= minSubscription, "Raise: below minimum subscription");
        require(cost <= dchf.allowance(msg.sender, address(this)), "Raise: above allowance");

        dchf.transferFrom(msg.sender, address(this), cost);
        totalPendingDeposits = totalPendingDeposits.add(cost);

        investor[msg.sender][false].insert(_subID);
        subscriptions[false].insert(_subID);
        subscription[_subID] = Subscription({investor: msg.sender, shares: _shares, cost: cost});

        emit SubscriptionProposal(issuer, msg.sender, _subID);
    }

    function issuerSubscription(bytes32 _subID, bool _accept)
        public
        whenNotPaused
        onlyIssuer
        onlyAtStage(Stage.Created)
    {

        require(subscriptions[false].exists(_subID), "Raise: subscription does not exist");
        require(!maxCapReached(), "Raise: max sold already met");

        Subscription memory sub = subscription[_subID];
        require(!maxCapWouldBeReached(sub.shares) || !_accept, "Raise: subscription would exceed max sold");
        totalPendingDeposits = totalPendingDeposits.sub(sub.cost);

        if (!_accept || getAvailableShares() < sub.shares) {
            subscriptions[false].remove(_subID);
            investor[sub.investor][false].remove(_subID);
            totalDeclinedDeposits = totalDeclinedDeposits.add(sub.cost);
            delete subscription[_subID];
            dchf.transfer(sub.investor, sub.cost);
            emit SubscriptionDeclined(sub.investor, _subID, sub.cost);
            return;
        }

        subscriptions[false].remove(_subID);
        subscriptions[true].insert(_subID);
        investor[sub.investor][false].remove(_subID);
        investor[sub.investor][true].insert(_subID);
        _updateSold(sub.investor, sub.shares);
        totalAcceptedDeposits = totalAcceptedDeposits.add(sub.cost);
        emit SubscriptionAccepted(sub.investor, _subID, sub.shares, sub.cost);
    }

    function issuerClose(bool _accept) public whenNotPaused onlyIssuer onlyAtStage(Stage.Created) {

        if (!minCapReached() && hasClosed()) {
            stage = Stage.RepayAll;
            emit UnsuccessfulRaise(msg.sender);
        } else if ((minCapReached() && hasClosed()) || maxCapReached()) {
            stage = _accept ? Stage.IssuerAccepted : Stage.RepayAll;
            emit RaiseClosed(msg.sender, _accept);
        }
    }

    function operatorFinalize(bool _accept) public whenNotPaused onlyOperator {

        if (_accept) {
            require(stage == Stage.IssuerAccepted, "Raise: incorrect stage");
            stage = Stage.OperatorAccepted;
        } else {
            require(stage != Stage.OperatorAccepted && stage != Stage.Closed, "Raise: incorrect stage");
            stage = Stage.RepayAll;
        }
        emit OperatorRaiseFinalization(msg.sender, _accept);
    }

    function releaseToIssuer() public whenNotPaused onlyOperatorOrSystem onlyAtStage(Stage.OperatorAccepted) {

        require(!issuerPaid, "Raise: issuer already paid");
        issuerPaid = true;

        dchf.transfer(issuer, totalAcceptedDeposits);

        emit IssuerPaid(issuer, totalAcceptedDeposits);
    }

    function batchReleasePending(address[] memory _investors) public whenNotPaused onlyOperatorOrSystem {

        require(_investors.length <= BATCH_LIMIT, "Raise: batch count is greater than BATCH_LIMIT");
        require(stage != Stage.Created, "Raise: not at correct stage");
        for (uint256 i = 0; i < _investors.length; i++) {
            address user = _investors[i];
            uint256 amount = _clearInvestorFunds(user, false);
            dchf.transfer(user, amount);
            emit ReleasedPending(user, amount);
        }
    }

    function close() public whenNotPaused onlyOperatorOrSystem onlyWhenClosed {

        require(stage == Stage.OperatorAccepted || stage == Stage.RepayAll, "Raise: not at correct stage");
        require(subscriptions[false].count() == 0, "Raise: pending not emptied");

        if (stage == Stage.OperatorAccepted) require(issuerPaid, "Raise: issuer not been paid");

        if (stage == Stage.RepayAll) require(subscriptions[true].count() == 0, "Raise: not emptied");

        stage = Stage.Closed;
        emit OperatorClosed(msg.sender);
    }

    function releaseAllFunds(address[] memory _investors) public onlyOperatorOrSystem {

        require(Pausable.isPaused() || stage == Stage.RepayAll, "Raise: not at correct stage");

        for (uint256 i = 0; i < _investors.length; i++) {
            address user = _investors[i];
            uint256 amount = _clearInvestorFunds(user, false).add(_clearInvestorFunds(user, true));
            if (amount > 0) {
                dchf.transfer(user, amount);
                emit ReleasedEmergency(user, amount);
            }
        }
    }

    function getSubscriptionTypeLength(bool _accept) public view returns (uint256) {

        return (subscriptions[_accept].count());
    }

    function getSubIDs(address _investor, bool _accept) public view returns (bytes32[] memory) {

        bytes32[] memory subIDs = new bytes32[](investor[_investor][_accept].count());
        for (uint256 i = 0; i < investor[_investor][_accept].count(); i++) {
            subIDs[i] = investor[_investor][_accept].keyAtIndex(i);
        }
        return subIDs;
    }

    function getDeposits(address _investor, bool _accept) public view returns (uint256 deposit) {

        bytes32[] memory subIDs = getSubIDs(_investor, _accept);

        for (uint256 i = 0; i < subIDs.length; i++) {
            bytes32 subID = subIDs[i];

            deposit = deposit.add(subscription[subID].cost);
        }
        return deposit;
    }

    function _clearInvestorFunds(address _user, bool _approved) internal returns (uint256) {

        uint256 amount;
        while (investor[_user][_approved].count() != 0) {
            bytes32 subID = investor[_user][_approved].keyAtIndex(0);
            Subscription memory sub = subscription[subID];
            amount = amount.add(sub.cost);
            subscriptions[_approved].remove(subID);
            investor[_user][_approved].remove(subID);
            delete subscription[subID];
        }
        return amount;
    }
}