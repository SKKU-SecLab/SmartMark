



pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function roundDownDecimal(uint x, uint d) internal pure returns (uint) {

        return x.div(10**d).mul(10**d);
    }

    function roundUpDecimal(uint x, uint d) internal pure returns (uint) {

        uint _decimal = 10**d;

        if (x % _decimal > 0) {
            x = x.add(10**d);
        }

        return x.div(_decimal).mul(_decimal);
    }
}


contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
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




contract State is Owned {

    address public associatedContract;

    constructor(address _associatedContract) internal {
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    function setAssociatedContract(address _associatedContract) external onlyOwner {

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    modifier onlyAssociatedContract {

        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }


    event AssociatedContractUpdated(address associatedContract);
}


contract BridgeState is Owned, State {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct Outbounding {
        address account;
        uint amount;
        uint destChainId;
        uint periodId;
    }

    struct Inbounding {
        address account;
        uint amount;
        uint srcChainId;
        uint srcOutboundingId;
        bool claimed;
    }

    struct OutboundPeriod {
        uint periodId;
        uint startTime;
        uint[] outboundingIds;
        bool processed;
    }

    mapping(bytes32 => mapping(address => bool)) public roles;
    mapping(uint => bool) public networkOpened;
    mapping(address => mapping(uint => uint[])) public accountOutboundings;
    mapping(address => uint[]) public accountInboundings;
    mapping(uint => mapping(uint => bool)) public srcOutboundingIdRegistered;
    mapping(uint => OutboundPeriod) public outboundPeriods;

    uint[] public outboundPeriodIdsToProcess;

    Inbounding[] public inboundings;
    Outbounding[] public outboundings;

    bytes32 private constant ROLE_VALIDATOR = "Validator";

    uint public numberOfOutboundPerPeriod = 10;
    uint public periodDuration = 300;

    uint public currentOutboundPeriodId;

    event SetRole(bytes32 role, address target, bool set);
    event OutboundingAppended(address indexed from, uint amount, uint destChainId, uint outboundId, uint periodId);
    event InboundingAppended(address indexed from, uint amount, uint srcChainId, uint srcOutboundingId, uint inboundId);
    event InboundingClaimed(uint inboundId);
    event PeriodProcessed(uint periodId);
    event NetworkStatusChanged(uint chainId, bool changedTo);
    event PeriodClosed(uint periodId);

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {
        outboundPeriods[0] = OutboundPeriod(0, now, new uint[](0), false);
    }


    function isOnRole(bytes32 _roleKey, address _account) external view returns (bool) {

        return roles[_roleKey][_account];
    }

    function outboundingsLength() external view returns (uint) {

        return outboundings.length;
    }

    function inboundingsLength() external view returns (uint) {

        return inboundings.length;
    }

    function outboundIdsInPeriod(uint _outboundPeriodId) external view returns (uint[] memory) {

        return outboundPeriods[_outboundPeriodId].outboundingIds;
    }

    function accountOutboundingsInPeriod(address _account, uint _period) external view returns (uint[] memory) {

        return accountOutboundings[_account][_period];
    }

    function applicableInboundIds(address _account) external view returns (uint[] memory) {

        return accountInboundings[_account];
    }

    function outboundRequestIdsInPeriod(address _account, uint _periodId) external view returns (uint[] memory) {

        return accountOutboundings[_account][_periodId];
    }

    function periodIdsToProcess() external view returns (uint[] memory) {

        return outboundPeriodIdsToProcess;
    }


    function appendOutboundingRequest(
        address _account,
        uint _amount,
        uint _destChainIds
    ) external onlyAssociatedContract {

        _appendOutboundingRequest(_account, _amount, _destChainIds);
    }

    function appendMultipleInboundingRequests(
        address[] calldata _accounts,
        uint[] calldata _amounts,
        uint[] calldata _srcChainIds,
        uint[] calldata _srcOutboundingIds
    ) external onlyValidator {

        uint length = _accounts.length;
        require(length > 0, "Input length is invalid");
        require(
            _amounts.length == length && _srcChainIds.length == length && _srcOutboundingIds.length == length,
            "Input length is not matched"
        );

        for (uint i = 0; i < _amounts.length; i++) {
            _appendInboundingRequest(_accounts[i], _amounts[i], _srcChainIds[i], _srcOutboundingIds[i]);
        }
    }

    function appendInboundingRequest(
        address _account,
        uint _amount,
        uint _srcChainId,
        uint _srcOutboundingId
    ) external onlyValidator {

        require(_appendInboundingRequest(_account, _amount, _srcChainId, _srcOutboundingId), "Append inbounding failed");
    }

    function claimInbound(uint _index) external onlyAssociatedContract {

        Inbounding storage _inbounding = inboundings[_index];

        require(!_inbounding.claimed, "This inbounding has already been claimed");

        _inbounding.claimed = true;

        emit InboundingClaimed(_index);

        uint[] storage ids = accountInboundings[_inbounding.account];
        uint _accountIndex;
        for (uint i = 0; i < ids.length; i++) {
            if (ids[i] == _index) {
                _accountIndex = i;

                break;
            }
        }

        if (_accountIndex < ids.length - 1) {
            for (uint i = _accountIndex; i < ids.length - 1; i++) {
                ids[i] = ids[i + 1];
            }
        }

        delete ids[ids.length - 1];
        ids.length--;
    }

    function closeOutboundPeriod() external onlyValidator {

        require(outboundPeriods[currentOutboundPeriodId].outboundingIds.length > 0, "No outbounding request is in period");

        _closeAndOpenOutboundPeriod();
    }

    function processOutboundPeriod(uint _outboundPeriodId) external onlyValidator {

        require(outboundPeriods[_outboundPeriodId].startTime > 0, "This period id is not started yet");
        require(_isPeriodOnTheProcessList(_outboundPeriodId), "Period is not on the process list");
        require(!outboundPeriods[_outboundPeriodId].processed, "Period has already been processed");

        uint[] storage ids = outboundPeriodIdsToProcess;
        uint _index;
        for (uint i = 0; i < ids.length; i++) {
            if (ids[i] == _outboundPeriodId) {
                _index = i;

                break;
            }
        }

        if (_index < ids.length - 1) {
            for (uint i = _index; i < ids.length - 1; i++) {
                ids[i] = ids[i + 1];
            }
        }

        delete ids[ids.length - 1];
        ids.length--;

        outboundPeriods[_outboundPeriodId].processed = true;

        emit PeriodProcessed(_outboundPeriodId);
    }


    function _appendOutboundingRequest(
        address _account,
        uint _amount,
        uint _destChainId
    ) internal {

        require(networkOpened[_destChainId], "Invalid target network");

        uint nextOutboundingId = outboundings.length;

        accountOutboundings[_account][currentOutboundPeriodId].push(nextOutboundingId);

        outboundings.push(Outbounding(_account, _amount, _destChainId, currentOutboundPeriodId));

        if (outboundPeriods[currentOutboundPeriodId].outboundingIds.length == 0) {
            outboundPeriods[currentOutboundPeriodId].startTime = now;
        }
        outboundPeriods[currentOutboundPeriodId].outboundingIds.push(nextOutboundingId);

        emit OutboundingAppended(_account, _amount, _destChainId, nextOutboundingId, currentOutboundPeriodId);

        _periodRefresher();
    }

    function _appendInboundingRequest(
        address _account,
        uint _amount,
        uint _srcChainId,
        uint _srcOutboundingId
    ) internal returns (bool) {

        require(!srcOutboundingIdRegistered[_srcChainId][_srcOutboundingId], "Request id is already registered to inbound");

        srcOutboundingIdRegistered[_srcChainId][_srcOutboundingId] = true;

        uint nextInboundingId = inboundings.length;
        inboundings.push(Inbounding(_account, _amount, _srcChainId, _srcOutboundingId, false));
        accountInboundings[_account].push(nextInboundingId);

        emit InboundingAppended(_account, _amount, _srcChainId, _srcOutboundingId, nextInboundingId);

        return true;
    }

    function _periodRefresher() internal {

        if (_periodIsStaled()) {
            _closeAndOpenOutboundPeriod();
        }
    }

    function _periodIsStaled() internal view returns (bool) {

        uint periodStartTime = outboundPeriods[currentOutboundPeriodId].startTime;
        if (outboundPeriods[currentOutboundPeriodId].outboundingIds.length >= numberOfOutboundPerPeriod) return true;
        if (now.sub(periodStartTime) > periodDuration) return true;

        return false;
    }

    function _closeAndOpenOutboundPeriod() internal {

        outboundPeriodIdsToProcess.push(currentOutboundPeriodId);

        emit PeriodClosed(currentOutboundPeriodId);

        currentOutboundPeriodId = currentOutboundPeriodId.add(1);

        outboundPeriods[currentOutboundPeriodId] = OutboundPeriod(currentOutboundPeriodId, now, new uint[](0), false);
    }

    function _isPeriodOnTheProcessList(uint _outboundPeriodId) internal view returns (bool) {

        for (uint i = 0; i < outboundPeriodIdsToProcess.length; i++) {
            if (outboundPeriodIdsToProcess[i] == _outboundPeriodId) {
                return true;
            }
        }

        return false;
    }


    function setRole(
        bytes32 _roleKey,
        address _target,
        bool _set
    ) external onlyOwner {

        roles[_roleKey][_target] = _set;

        emit SetRole(_roleKey, _target, _set);
    }

    function setNumberOfOutboundPerPeriod(uint _number) external onlyOwner {

        require(_number > 0, "Number should larger than zero");

        numberOfOutboundPerPeriod = _number;
    }

    function setPeriodDuration(uint _time) external onlyOwner {

        require(_time > 0, "Time cannot be zero");

        periodDuration = _time;
    }

    function setNetworkStatus(uint _chainId, bool _setTo) external onlyOwner {

        networkOpened[_chainId] = _setTo;

        emit NetworkStatusChanged(_chainId, _setTo);
    }

    modifier onlyValidator() {

        require(roles[ROLE_VALIDATOR][msg.sender], "Caller is not validator");
        _;
    }
}