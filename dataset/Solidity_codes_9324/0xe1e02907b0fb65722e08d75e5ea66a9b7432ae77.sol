

pragma solidity 0.5.13;

contract TrueCoinReceiver {

    function tokenFallback( address from, uint256 value ) external;

}


pragma solidity 0.5.13;

interface FinancialOpportunity {


    function totalSupply() external view returns (uint);


    function tokenValue() external view returns(uint);


    function deposit(address from, uint amount) external returns(uint);


    function redeem(address to, uint amount) external returns(uint);

}


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


pragma solidity ^0.5.13;


interface RegistryClone {

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) external;

}

contract Registry {

    struct AttributeData {
        uint256 value;
        bytes32 notes;
        address adminAddr;
        uint256 timestamp;
    }
    
    address public owner;
    address public pendingOwner;
    bool initialized;

    mapping(address => mapping(bytes32 => AttributeData)) attributes;
    bytes32 constant WRITE_PERMISSION = keccak256("canWriteTo-");
    mapping(bytes32 => RegistryClone[]) subscribers;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SetAttribute(address indexed who, bytes32 attribute, uint256 value, bytes32 notes, address indexed adminAddr);
    event SetManager(address indexed oldManager, address indexed newManager);
    event StartSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);
    event StopSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);

    function confirmWrite(bytes32 _attribute, address _admin) internal view returns (bool) {

        return (_admin == owner || hasAttribute(_admin, keccak256(abi.encodePacked(WRITE_PERMISSION ^ _attribute))));
    }

    function setAttribute(address _who, bytes32 _attribute, uint256 _value, bytes32 _notes) public {

        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, _notes, msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, _notes, msg.sender);

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function subscribe(bytes32 _attribute, RegistryClone _syncer) external onlyOwner {

        subscribers[_attribute].push(_syncer);
        emit StartSubscription(_attribute, _syncer);
    }

    function unsubscribe(bytes32 _attribute, uint256 _index) external onlyOwner {

        uint256 length = subscribers[_attribute].length;
        require(_index < length);
        emit StopSubscription(_attribute, subscribers[_attribute][_index]);
        subscribers[_attribute][_index] = subscribers[_attribute][length - 1];
        subscribers[_attribute].length = length - 1;
    }

    function subscriberCount(bytes32 _attribute) public view returns (uint256) {

        return subscribers[_attribute].length;
    }

    function setAttributeValue(address _who, bytes32 _attribute, uint256 _value) public {

        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, "", msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, "", msg.sender);
        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function hasAttribute(address _who, bytes32 _attribute) public view returns (bool) {

        return attributes[_who][_attribute].value != 0;
    }


    function getAttribute(address _who, bytes32 _attribute) public view returns (uint256, bytes32, address, uint256) {

        AttributeData memory data = attributes[_who][_attribute];
        return (data.value, data.notes, data.adminAddr, data.timestamp);
    }

    function getAttributeValue(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].value;
    }

    function getAttributeAdminAddr(address _who, bytes32 _attribute) public view returns (address) {

        return attributes[_who][_attribute].adminAddr;
    }

    function getAttributeTimestamp(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].timestamp;
    }

    function syncAttribute(bytes32 _attribute, uint256 _startIndex, address[] calldata _addresses) external {

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> _startIndex) {
            RegistryClone target = targets[index];
            for (uint256 i = _addresses.length; i --> 0; ) {
                address who = _addresses[i];
                target.syncAttributeValue(who, _attribute, attributes[who][_attribute].value);
            }
        }
    }

    function reclaimEther(address payable _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(IERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "only Owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


pragma solidity 0.5.13;


contract InstantiatableOwnable {

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


pragma solidity 0.5.13;



contract Claimable is InstantiatableOwnable {

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
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


pragma solidity 0.5.13;



contract BalanceSheet is Claimable {

    using SafeMath for uint256;

    mapping (address => uint256) public balanceOf;

    function addBalance(address _addr, uint256 _value) public onlyOwner {

        balanceOf[_addr] = balanceOf[_addr].add(_value);
    }

    function subBalance(address _addr, uint256 _value) public onlyOwner {

        balanceOf[_addr] = balanceOf[_addr].sub(_value);
    }

    function setBalance(address _addr, uint256 _value) public onlyOwner {

        balanceOf[_addr] = _value;
    }
}


pragma solidity 0.5.13;



contract AllowanceSheet is Claimable {

    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) public allowanceOf;

    function addAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].add(_value);
    }

    function subAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].sub(_value);
    }

    function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = _value;
    }
}


pragma solidity 0.5.13;





contract ProxyStorage {

    address public owner;
    address public pendingOwner;

    bool initialized;

    BalanceSheet balances_Deprecated;
    AllowanceSheet allowances_Deprecated;

    uint256 totalSupply_;

    bool private paused_Deprecated = false;
    address private globalPause_Deprecated;

    uint256 public burnMin = 0;
    uint256 public burnMax = 0;

    Registry public registry;

    string name_Deprecated;
    string symbol_Deprecated;

    uint[] gasRefundPool_Deprecated;
    uint256 private redemptionAddressCount_Deprecated;
    uint256 public minimumGasPriceForFutureRefunds;

    mapping (address => uint256) _balanceOf;
    mapping (address => mapping (address => uint256)) _allowance;
    mapping (bytes32 => mapping (address => uint256)) attributes;

    mapping(address => FinancialOpportunity) finOps;
    mapping(address => mapping(address => uint256)) finOpBalances;
    mapping(address => uint256) finOpSupply;

    struct RewardAllocation { uint proportion; address finOp; }
    mapping(address => RewardAllocation[]) _rewardDistribution;
    uint256 maxRewardProportion = 1000;

}


pragma solidity 0.5.13;


contract HasOwner is ProxyStorage {


    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "only Owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


pragma solidity 0.5.13;


contract ReclaimerToken is HasOwner {

    function reclaimEther(address payable _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(IERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }

    function reclaimContract(InstantiatableOwnable _ownable) external onlyOwner {

        _ownable.transferOwnership(owner);
    }
}


pragma solidity 0.5.13;


contract InitializableOwnable {

    address public owner;
    bool configured = false;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _configure() internal {

        require(!configured);
        owner = msg.sender;
        configured = true;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


pragma solidity 0.5.13;



contract InitializableClaimable is InitializableOwnable {

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


pragma solidity 0.5.13;





contract ModularBasicToken is HasOwner {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() public view returns (uint256) {

        return totalSupply_;
    }

    function balanceOf(address _who) public view returns (uint256) {

        return _getBalance(_who);
    }

    function _getBalance(address _who) internal view returns (uint256) {

        return _balanceOf[_who];
    }

    function _addBalance(address _who, uint256 _value) internal returns (uint256 priorBalance) {

        priorBalance = _balanceOf[_who];
        _balanceOf[_who] = priorBalance.add(_value);
    }

    function _subBalance(address _who, uint256 _value) internal returns (uint256 result) {

        result = _balanceOf[_who].sub(_value);
        _balanceOf[_who] = result;
    }

    function _setBalance(address _who, uint256 _value) internal {

        _balanceOf[_who] = _value;
    }
}


pragma solidity 0.5.13;




contract ModularStandardToken is ModularBasicToken {

    using SafeMath for uint256;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    uint256 constant INFINITE_ALLOWANCE = 0xfe00000000000000000000000000000000000000000000000000000000000000;

    function approve(address _spender, uint256 _value) public returns (bool) {

        _approveAllArgs(_spender, _value, msg.sender);
        return true;
    }

    function _approveAllArgs(
        address _spender,
        uint256 _value,
        address _tokenHolder
    ) internal {

        _setAllowance(_tokenHolder, _spender, _value);
        emit Approval(_tokenHolder, _spender, _value);
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {

        _increaseAllowanceAllArgs(_spender, _addedValue, msg.sender);
        return true;
    }

    function _increaseAllowanceAllArgs(
        address _spender,
        uint256 _addedValue,
        address _tokenHolder
    ) internal {

        _addAllowance(_tokenHolder, _spender, _addedValue);
        emit Approval(
            _tokenHolder,
            _spender,
            _getAllowance(_tokenHolder, _spender)
        );
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {

        _decreaseAllowanceAllArgs(_spender, _subtractedValue, msg.sender);
        return true;
    }

    function _decreaseAllowanceAllArgs(
        address _spender,
        uint256 _subtractedValue,
        address _tokenHolder
    ) internal {

        uint256 oldValue = _getAllowance(_tokenHolder, _spender);
        uint256 newValue;
        if (_subtractedValue > oldValue) {
            newValue = 0;
        } else {
            newValue = oldValue - _subtractedValue;
        }
        _setAllowance(_tokenHolder, _spender, newValue);
        emit Approval(_tokenHolder, _spender, newValue);
    }

    function allowance(address _who, address _spender)
        public
        view
        returns (uint256)
    {

        return _getAllowance(_who, _spender);
    }

    function _getAllowance(address _who, address _spender)
        internal
        view
        returns (uint256 value)
    {

        return _allowance[_who][_spender];
    }

    function _addAllowance(address _who, address _spender, uint256 _value)
        internal
    {

        _allowance[_who][_spender] = _allowance[_who][_spender].add(_value);
    }

    function _subAllowance(address _who, address _spender, uint256 _value)
        internal
        returns (uint256 newAllowance)
    {

        newAllowance = _allowance[_who][_spender].sub(_value);
        if (newAllowance < INFINITE_ALLOWANCE) {
            _allowance[_who][_spender] = newAllowance;
        }
    }

    function _setAllowance(address _who, address _spender, uint256 _value)
        internal
    {

        _allowance[_who][_spender] = _value;
    }
}


pragma solidity 0.5.13;


contract ModularBurnableToken is ModularStandardToken {

    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 value);
    uint256 constant CENT = 10 ** 16;

    function burn(uint256 _value) external {

        _burnAllArgs(msg.sender, _value - _value % CENT);
    }

    function _burnAllArgs(address _from, uint256 _value) internal {

        _subBalance(_from, _value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
    }
}


pragma solidity 0.5.13;


contract BurnableTokenWithBounds is ModularBurnableToken {


    event SetBurnBounds(uint256 newMin, uint256 newMax);

    function _burnAllArgs(address _burner, uint256 _value) internal {

        require(_value >= burnMin, "below min burn bound");
        require(_value <= burnMax, "exceeds max burn bound");
        super._burnAllArgs(_burner, _value);
    }

    function setBurnBounds(uint256 _min, uint256 _max) external onlyOwner {

        require(_min <= _max, "min > max");
        burnMin = _min;
        burnMax = _max;
        emit SetBurnBounds(_min, _max);
    }
}


pragma solidity 0.5.13;


contract GasRefundToken is ProxyStorage {



    function sponsorGas2() external {

        assembly {
            mstore(0, or(0x601b8060093d393df33d33730000000000000000000000000000000000000000, address))
            mstore(32,   0x185857ff00000000000000000000000000000000000000000000000000000000)
            let offset := sload(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            let location := sub(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe, offset)
            sstore(location, create(0, 0, 0x24))
            location := sub(location, 1)
            sstore(location, create(0, 0, 0x24))
            location := sub(location, 1)
            sstore(location, create(0, 0, 0x24))
            sstore(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, add(offset, 3))
        }
    }

    function gasRefund39() internal {

        assembly {
            let offset := sload(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            if gt(offset, 0) {
              let location := sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,offset)
              sstore(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, sub(offset, 1))
              let sheep := sload(location)
              pop(call(gas, sheep, 0, 0, 0, 0, 0))
              sstore(location, 0)
            }
        }
    }

    function sponsorGas() external {

        uint256 refundPrice = minimumGasPriceForFutureRefunds;
        require(refundPrice > 0);
        assembly {
            let offset := sload(0xfffff)
            let result := add(offset, 9)
            sstore(0xfffff, result)
            let position := add(offset, 0x100000)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
            position := add(position, 1)
            sstore(position, refundPrice)
        }
    }

    function minimumGasPriceForRefund() public view returns (uint256 result) {

        assembly {
            let offset := sload(0xfffff)
            let location := add(offset, 0xfffff)
            result := add(sload(location), 1)
        }
    }

    function gasRefund30() internal {

        assembly {
            let offset := sload(0xfffff)
            if gt(offset, 1) {
                let location := add(offset, 0xfffff)
                if gt(gasprice,sload(location)) {
                    sstore(location, 0)
                    location := sub(location, 1)
                    sstore(location, 0)
                    sstore(0xfffff, sub(offset, 2))
                }
            }
        }
    }

    function gasRefund15() internal {

        assembly {
            let offset := sload(0xfffff)
            if gt(offset, 1) {
                let location := add(offset, 0xfffff)
                if gt(gasprice,sload(location)) {
                    sstore(location, 0)
                    sstore(0xfffff, sub(offset, 1))
                }
            }
        }
    }

    function remainingGasRefundPool() public view returns (uint length) {

        assembly {
            length := sload(0xfffff)
        }
    }

    function gasRefundPool(uint256 _index) public view returns (uint256 gasPrice) {

        assembly {
            gasPrice := sload(add(0x100000, _index))
        }
    }

    bytes32 constant CAN_SET_FUTURE_REFUND_MIN_GAS_PRICE = "canSetFutureRefundMinGasPrice";

    function setMinimumGasPriceForFutureRefunds(uint256 _minimumGasPriceForFutureRefunds) public {

        require(registry.hasAttribute(msg.sender, CAN_SET_FUTURE_REFUND_MIN_GAS_PRICE));
        minimumGasPriceForFutureRefunds = _minimumGasPriceForFutureRefunds;
    }
}


pragma solidity 0.5.13;







contract CompliantDepositTokenWithHook is ReclaimerToken, RegistryClone, BurnableTokenWithBounds, GasRefundToken {


    bytes32 constant IS_REGISTERED_CONTRACT = "isRegisteredContract";
    bytes32 constant IS_DEPOSIT_ADDRESS = "isDepositAddress";
    uint256 constant REDEMPTION_ADDRESS_COUNT = 0x100000;
    bytes32 constant IS_BLACKLISTED = "isBlacklisted";

    function canBurn() internal pure returns (bytes32);


    function transfer(address _to, uint256 _value) public returns (bool) {

        _transferAllArgs(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        _transferFromAllArgs(_from, _to, _value, msg.sender);
        return true;
    }

    function _burnFromAllowanceAllArgs(address _from, address _to, uint256 _value, address _spender) internal {

        _requireCanTransferFrom(_spender, _from, _to);
        _requireOnlyCanBurn(_to);
        require(_value >= burnMin, "below min burn bound");
        require(_value <= burnMax, "exceeds max burn bound");
        if (0 == _subBalance(_from, _value)) {
            if (0 != _subAllowance(_from, _spender, _value)) {
                gasRefund15();
            }
        } else {
            if (0 == _subAllowance(_from, _spender, _value)) {
                gasRefund15();
            } else {
                gasRefund39();
            }
        }
        emit Transfer(_from, _to, _value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_to, _value);
        emit Transfer(_to, address(0), _value);
    }

    function _burnFromAllArgs(address _from, address _to, uint256 _value) internal {

        _requireCanTransfer(_from, _to);
        _requireOnlyCanBurn(_to);
        require(_value >= burnMin, "below min burn bound");
        require(_value <= burnMax, "exceeds max burn bound");
        if (0 == _subBalance(_from, _value)) {
            gasRefund15();
        } else {
            gasRefund30();
        }
        emit Transfer(_from, _to, _value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_to, _value);
        emit Transfer(_to, address(0), _value);
    }

    function _transferFromAllArgs(address _from, address _to, uint256 _value, address _spender) internal {

        if (uint256(_to) < REDEMPTION_ADDRESS_COUNT) {
            _value -= _value % CENT;
            _burnFromAllowanceAllArgs(_from, _to, _value, _spender);
        } else {
            bool hasHook;
            address originalTo = _to;
            (_to, hasHook) = _requireCanTransferFrom(_spender, _from, _to);
            if (0 == _addBalance(_to, _value)) {
                if (0 == _subAllowance(_from, _spender, _value)) {
                    if (0 != _subBalance(_from, _value)) {
                        gasRefund30();
                    }
                } else {
                    if (0 == _subBalance(_from, _value)) {
                        gasRefund30();
                    } else {
                        gasRefund39();
                    }
                }
            } else {
                if (0 == _subAllowance(_from, _spender, _value)) {
                    if (0 != _subBalance(_from, _value)) {
                        gasRefund15();
                    }
                } else {
                    if (0 == _subBalance(_from, _value)) {
                        gasRefund15();
                    } else {
                        gasRefund39();
                    }
                }

            }
            emit Transfer(_from, originalTo, _value);
            if (originalTo != _to) {
                emit Transfer(originalTo, _to, _value);
                if (hasHook) {
                    TrueCoinReceiver(_to).tokenFallback(originalTo, _value);
                }
            } else {
                if (hasHook) {
                    TrueCoinReceiver(_to).tokenFallback(_from, _value);
                }
            }
        }
    }

    function _transferAllArgs(address _from, address _to, uint256 _value) internal {

        if (uint256(_to) < REDEMPTION_ADDRESS_COUNT) {
            _value -= _value % CENT;
            _burnFromAllArgs(_from, _to, _value);
        } else {
            bool hasHook;
            address finalTo;
            (finalTo, hasHook) = _requireCanTransfer(_from, _to);
            if (0 == _subBalance(_from, _value)) {
                if (0 == _addBalance(finalTo, _value)) {
                    gasRefund30();
                }
            } else {
                if (0 == _addBalance(finalTo, _value)) {
                    gasRefund39();
                } else {
                    gasRefund30();
                }
            }
            emit Transfer(_from, _to, _value);
            if (finalTo != _to) {
                emit Transfer(_to, finalTo, _value);
                if (hasHook) {
                    TrueCoinReceiver(finalTo).tokenFallback(_to, _value);
                }
            } else {
                if (hasHook) {
                    TrueCoinReceiver(finalTo).tokenFallback(_from, _value);
                }
            }
        }
    }

    function mint(address _to, uint256 _value) public onlyOwner {

        require(_to != address(0), "to address cannot be zero");
        bool hasHook;
        address originalTo = _to;
        (_to, hasHook) = _requireCanMint(_to);
        totalSupply_ = totalSupply_.add(_value);
        emit Mint(originalTo, _value);
        emit Transfer(address(0), originalTo, _value);
        if (_to != originalTo) {
            emit Transfer(originalTo, _to, _value);
        }
        _addBalance(_to, _value);
        if (hasHook) {
            if (_to != originalTo) {
                TrueCoinReceiver(_to).tokenFallback(originalTo, _value);
            } else {
                TrueCoinReceiver(_to).tokenFallback(address(0), _value);
            }
        }
    }

    event WipeBlacklistedAccount(address indexed account, uint256 balance);
    event SetRegistry(address indexed registry);

    function setRegistry(Registry _registry) public onlyOwner {

        registry = _registry;
        emit SetRegistry(address(registry));
    }

    modifier onlyRegistry {

        require(msg.sender == address(registry));
        _;
    }

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) public onlyRegistry {

        attributes[_attribute][_who] = _value;
    }

    function _burnAllArgs(address _from, uint256 _value) internal {

        _requireCanBurn(_from);
        super._burnAllArgs(_from, _value);
    }

    function wipeBlacklistedAccount(address _account) public onlyOwner {

        require(_isBlacklisted(_account), "_account is not blacklisted");
        uint256 oldValue = _getBalance(_account);
        _setBalance(_account, 0);
        totalSupply_ = totalSupply_.sub(oldValue);
        emit WipeBlacklistedAccount(_account, oldValue);
        emit Transfer(_account, address(0), oldValue);
    }

    function _isBlacklisted(address _account) internal view returns (bool blacklisted) {

        return attributes[IS_BLACKLISTED][_account] != 0;
    }

    function _requireCanTransfer(address _from, address _to) internal view returns (address, bool) {

        uint256 depositAddressValue = attributes[IS_DEPOSIT_ADDRESS][address(uint256(_to) >> 20)];
        if (depositAddressValue != 0) {
            _to = address(depositAddressValue);
        }
        require (attributes[IS_BLACKLISTED][_to] == 0, "blacklisted");
        require (attributes[IS_BLACKLISTED][_from] == 0, "blacklisted");
        return (_to, attributes[IS_REGISTERED_CONTRACT][_to] != 0);
    }

    function _requireCanTransferFrom(address _spender, address _from, address _to) internal view returns (address, bool) {

        require (attributes[IS_BLACKLISTED][_spender] == 0, "blacklisted");
        uint256 depositAddressValue = attributes[IS_DEPOSIT_ADDRESS][address(uint256(_to) >> 20)];
        if (depositAddressValue != 0) {
            _to = address(depositAddressValue);
        }
        require (attributes[IS_BLACKLISTED][_to] == 0, "blacklisted");
        require (attributes[IS_BLACKLISTED][_from] == 0, "blacklisted");
        return (_to, attributes[IS_REGISTERED_CONTRACT][_to] != 0);
    }

    function _requireCanMint(address _to) internal view returns (address, bool) {

        uint256 depositAddressValue = attributes[IS_DEPOSIT_ADDRESS][address(uint256(_to) >> 20)];
        if (depositAddressValue != 0) {
            _to = address(depositAddressValue);
        }
        require (attributes[IS_BLACKLISTED][_to] == 0, "blacklisted");
        return (_to, attributes[IS_REGISTERED_CONTRACT][_to] != 0);
    }

    function _requireOnlyCanBurn(address _from) internal view {

        require (attributes[canBurn()][_from] != 0, "cannot burn from this address");
    }

    function _requireCanBurn(address _from) internal view {

        require (attributes[IS_BLACKLISTED][_from] == 0, "blacklisted");
        require (attributes[canBurn()][_from] != 0, "cannot burn from this address");
    }

    function paused() public pure returns (bool) {

        return false;
    }
}


pragma solidity 0.5.13;



contract RewardToken is CompliantDepositTokenWithHook {



    event MintRewardToken(address account, uint256 amount, address finOp);
    event RedeemRewardToken(address account, uint256 amount, address finOp);
    event BurnRewardToken(address account, uint256 amount, address finOp);

    modifier validFinOp(address finOp) {

        require(finOp != address(0), "invalid opportunity");
        _;
    }

    function rewardTokenSupply(
        address finOp
    ) public view validFinOp(finOp) returns (uint256) {

        return finOpSupply[finOp];
    }

    function rewardTokenBalance(
        address account,
        address finOp
    ) public view validFinOp(finOp) returns (uint256) {

        return finOpBalances[finOp][account];
    }

    function mintRewardToken(
        address account,
        uint256 amount,
        address finOp
    ) internal validFinOp(finOp) returns (uint256) {

        require(super.balanceOf(account) >= amount, "insufficient token balance");

        _setAllowance(account, finOp, amount);

        uint256 rewardAmount = _getFinOp(finOp).deposit(account, amount);

        finOpSupply[finOp] = finOpSupply[finOp].add(rewardAmount);

        _addRewardBalance(account, rewardAmount, finOp);

        emit MintRewardToken(account, amount, finOp);

        return rewardAmount;
    }

    function redeemRewardToken(
        address account,
        uint256 amount,
        address finOp
    ) internal validFinOp(finOp) returns (uint256) {

        require(rewardTokenBalance(account, finOp) >= amount, "insufficient reward balance");

        uint256 tokenAmount = _getFinOp(finOp).redeem(account, amount);

        finOpSupply[finOp] = finOpSupply[finOp].sub(amount);

        _subRewardBalance(account, amount, finOp);

        emit RedeemRewardToken(account, tokenAmount, finOp);

        return tokenAmount;
    }

    function burnRewardToken(
        address account,
        uint256 amount,
        address finOp
    )
        internal
        validFinOp(finOp)
    {

        require(msg.sender == account);

        require(rewardTokenBalance(account, finOp) >= amount);

        _subRewardBalance(account, amount, finOp);

        finOpSupply[finOp].sub(amount);

        emit BurnRewardToken(account, amount, finOp);
    }

    function _addRewardBalance(address account, uint256 amount, address finOp) internal {

        finOpBalances[finOp][account] = finOpBalances[finOp][account].add(amount);
    }

    function _subRewardBalance(address account, uint256 amount, address finOp) internal {

        finOpBalances[finOp][account] = finOpBalances[finOp][account].sub(amount);
    }

    function _toRewardToken(uint256 amount, address finOp) internal view returns (uint256) {

        uint256 ratio = _getFinOp(finOp).tokenValue();
        return amount.mul(10 ** 18).div(ratio);
    }

    function _toToken(uint amount, address finOp) internal view returns (uint256) {

        uint256 ratio = _getFinOp(finOp).tokenValue();
        return ratio.mul(amount).div(10 ** 18);
    }

    function _getFinOp(address finOp) internal view returns (FinancialOpportunity) {

        return FinancialOpportunity(finOp);
    }
}


pragma solidity 0.5.13;


contract RewardTokenWithReserve is RewardToken {


    address public constant RESERVE = 0xf000000000000000000000000000000000000000;

    event SwapRewardForToken(address account, address receiver, uint256 amount, address finOp);
    event SwapTokenForReward(address account, address receiver, uint256 amount, address finOp);

    function reserveBalance() public view returns (uint256) {

        return super.balanceOf(RESERVE);
    }

    function reserveRewardBalance(address finOp) public view returns (uint) {

        return rewardTokenBalance(RESERVE, finOp);
    }

    function reserveWithdraw(address to, uint256 value) external onlyOwner {

        _transferAllArgs(RESERVE, to, value);
    }

    function reserveRedeem(uint256 amount, address finOp) internal {

        redeemRewardToken(RESERVE, amount, finOp);
    }

    function reserveMint(uint256 amount, address finOp) internal {

        mintRewardToken(RESERVE, amount, finOp);
    }

    function swapTokenForReward(
        address sender,
        address receiver,
        uint256 amount,
        address finOp
    ) internal validFinOp(finOp) {

        require(balanceOf(sender) >= amount, "insufficient balance");

        uint256 rewardAmount = _toRewardToken(amount, finOp);

        require(rewardTokenBalance(RESERVE, finOp) >= rewardAmount, "not enough rewardToken in reserve");

        _subBalance(sender, amount);
        _addBalance(RESERVE, amount);

        _subRewardBalance(RESERVE, rewardAmount, finOp);
        _addRewardBalance(receiver, rewardAmount, finOp);

        emit SwapTokenForReward(sender, receiver, amount, finOp);
    }

    function swapRewardForToken(
        address sender,
        address receiver,
        uint256 tokenAmount,
        address finOp
    ) internal validFinOp(finOp) {

        require(balanceOf(RESERVE) >= tokenAmount, "not enough depositToken in reserve");

        uint256 rewardAmount = _toRewardToken(tokenAmount, finOp);

        require (rewardTokenBalance(sender, finOp) >= rewardAmount, "insufficient rewardToken balance");

        _subRewardBalance(sender, rewardAmount, finOp);
        _addRewardBalance(RESERVE, rewardAmount, finOp);

        _subBalance(RESERVE, tokenAmount);
        _addBalance(receiver, tokenAmount);

        emit SwapRewardForToken(sender, receiver, rewardAmount, finOp);
    }
}


pragma solidity 0.5.13;




contract TrueRewardBackedToken is RewardTokenWithReserve {



    bytes32 constant IS_TRUEREWARDS_WHITELISTED = "isTrueRewardsWhitelisted";

    address public opportunity_;

    event TrueRewardEnabled(address _account);
    event TrueRewardDisabled(address _account);

    function trueRewardEnabled(address _address) public view returns (bool) {

        return _rewardDistribution[_address].length != 0;
    }

    function totalSupply() public view returns (uint256) {

        if (opportunityRewardSupply() != 0) {
            return totalSupply_.add(opportunityTotalSupply());
        }
        return totalSupply_;
    }

    function depositBackedSupply() public view returns (uint256) {

        return totalSupply_;
    }

    function debtBackedSupply() public view returns (uint256) {

        return totalSupply() - totalSupply_;
    }

    function balanceOf(address _who) public view returns (uint256) {

        if (trueRewardEnabled(_who)) {
            return _toToken(rewardTokenBalance(_who, opportunity()), opportunity());
        }
        return super.balanceOf(_who);
    }

    function enableTrueReward() external {

        require(registry.hasAttribute(msg.sender, IS_TRUEREWARDS_WHITELISTED), "must be whitelisted to enable TrueRewards");
        require(!trueRewardEnabled(msg.sender), "TrueReward already enabled");

        uint balance = _getBalance(msg.sender);

        if (balance != 0) {
            mintRewardToken(msg.sender, balance, opportunity());
        }

        _setDistribution(maxRewardProportion, opportunity());

        emit TrueRewardEnabled(msg.sender);
    }

    function disableTrueReward() external {

        require(trueRewardEnabled(msg.sender), "TrueReward already disabled");
        uint rewardBalance = rewardTokenBalance(msg.sender, opportunity());

        _removeDistribution(opportunity());

        if (rewardBalance > 0) {
            redeemRewardToken(msg.sender, rewardBalance, opportunity());
        }

        emit TrueRewardDisabled(msg.sender);
    }

    function mint(address _to, uint256 _value) public onlyOwner {

        bool toEnabled = trueRewardEnabled(_to);

        if (toEnabled) {
            super.mint(address(this), _value);
            _transferAllArgs(address(this), _to, _value);
        }
        else {
            super.mint(_to, _value);
        }
    }

    function opportunityReserveRedeem(uint256 _value) external onlyOwner {

        reserveRedeem(_value, opportunity());
    }

    function opportunityReserveMint(uint256 _value) external onlyOwner {

        reserveMint(_value, opportunity());
    }

    function setOpportunityAddress(address _opportunity) external onlyOwner {

        opportunity_ = _opportunity;
    }

    function opportunity() public view returns (address) {

        return opportunity_;
    }

    function opportunityRewardSupply() internal view returns (uint256) {

        return rewardTokenSupply(opportunity());
    }

    function opportunityTotalSupply() internal view returns (uint256) {

        return _toToken(opportunityRewardSupply(), opportunity());
    }

    function _transferWithRewards(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (uint256) {

        bool fromEnabled = trueRewardEnabled(_from);
        bool toEnabled = trueRewardEnabled(_to);

        address finOp = opportunity();

        uint rewardAmount = _toRewardToken(_value, finOp);

        if (fromEnabled && !toEnabled && _value <= reserveBalance()) {
            swapRewardForToken(_from, _to, _value, finOp);
        }
        else if (!fromEnabled && toEnabled && rewardAmount <= rewardTokenBalance(RESERVE, finOp)) {
            swapTokenForReward(_from, _to, _value, finOp);
        }
        else if (fromEnabled && toEnabled) {
            _subRewardBalance(_from, rewardAmount, finOp);
            _addRewardBalance(_to, rewardAmount, finOp);
        }
        else if (fromEnabled && !toEnabled) {
            _getFinOp(finOp).redeem(_to, rewardAmount);

            finOpSupply[finOp] = finOpSupply[finOp].sub(rewardAmount);

            _subRewardBalance(_from, rewardAmount, finOp);
        }
        else if (!fromEnabled && toEnabled) {
            _approveAllArgs(finOp, _value, _from);
            uint256 depositedAmount = _getFinOp(finOp).deposit(_from, _value);

            finOpSupply[finOp] = finOpSupply[finOp].add(depositedAmount);

            _addRewardBalance(_to, depositedAmount, finOp);
        }
        return _value;
    }

    function _transferAllArgs(address _from, address _to, uint256 _value) internal {

        if (!trueRewardEnabled(_from) && !trueRewardEnabled(_to)) {
            super._transferAllArgs(_from, _to, _value);
            return;
        }
        require(balanceOf(_from) >= _value, "not enough balance");

        (address finalTo, bool hasHook) = _requireCanTransfer(_from, _to);

        _value = _transferWithRewards(_from, finalTo, _value);

        emit Transfer(_from, _to, _value);
        if (finalTo != _to) {
            emit Transfer(_to, finalTo, _value);
            if (hasHook) {
                TrueCoinReceiver(finalTo).tokenFallback(_to, _value);
            }
        } else {
            if (hasHook) {
                TrueCoinReceiver(finalTo).tokenFallback(_from, _value);
            }
        }
    }

    function _transferFromAllArgs(
        address _from,
        address _to,
        uint256 _value,
        address _spender
    ) internal {

        if (!trueRewardEnabled(_from) && !trueRewardEnabled(_to)) {
            super._transferFromAllArgs(_from, _to, _value, _spender);
            return;
        }

        require(balanceOf(_from) >= _value, "not enough balance");

        (address finalTo, bool hasHook) = _requireCanTransferFrom(_spender, _from, _to);

        _value = _transferWithRewards(_from, finalTo, _value);

        _subAllowance(_from, _spender, _value);

        emit Transfer(_from, _to, _value);
        if (finalTo != _to) {
            emit Transfer(_to, finalTo, _value);
            if (hasHook) {
                TrueCoinReceiver(finalTo).tokenFallback(_to, _value);
            }
        } else {
            if (hasHook) {
                TrueCoinReceiver(finalTo).tokenFallback(_from, _value);
            }
        }
    }

    function _setDistribution(uint256 proportion, address finOp) internal {

        require(proportion <= maxRewardProportion, "exceeds maximum proportion");
        require(_rewardDistribution[msg.sender].length == 0, "already enabled");
        _rewardDistribution[msg.sender].push(
            RewardAllocation(proportion, finOp));
    }

    function _removeDistribution(address finOp) internal {

        delete _rewardDistribution[msg.sender][0];
        _rewardDistribution[msg.sender].length--;
    }
}


pragma solidity 0.5.13;


contract DelegateERC20 is CompliantDepositTokenWithHook {


    address constant DELEGATE_FROM = 0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;

    modifier onlyDelegateFrom() {

        require(msg.sender == DELEGATE_FROM);
        _;
    }

    function delegateTotalSupply() public view returns (uint256) {

        return totalSupply();
    }

    function delegateBalanceOf(address who) public view returns (uint256) {

        return _getBalance(who);
    }

    function delegateTransfer(address to, uint256 value, address origSender) public onlyDelegateFrom returns (bool) {

        _transferAllArgs(origSender, to, value);
        return true;
    }

    function delegateAllowance(address owner, address spender) public view returns (uint256) {

        return _getAllowance(owner, spender);
    }

    function delegateTransferFrom(address from, address to, uint256 value, address origSender) public onlyDelegateFrom returns (bool) {

        _transferFromAllArgs(from, to, value, origSender);
        return true;
    }

    function delegateApprove(address spender, uint256 value, address origSender) public onlyDelegateFrom returns (bool) {

        _approveAllArgs(spender, value, origSender);
        return true;
    }

    function delegateIncreaseApproval(address spender, uint addedValue, address origSender) public onlyDelegateFrom returns (bool) {

        _increaseAllowanceAllArgs(spender, addedValue, origSender);
        return true;
    }

    function delegateDecreaseApproval(address spender, uint subtractedValue, address origSender) public onlyDelegateFrom returns (bool) {

        _decreaseAllowanceAllArgs(spender, subtractedValue, origSender);
        return true;
    }
}


pragma solidity 0.5.13;





contract TrueUSD is TrueRewardBackedToken, DelegateERC20 {

    uint8 constant DECIMALS = 18;
    uint8 constant ROUNDING = 2;

    function decimals() public pure returns (uint8) {

        return DECIMALS;
    }

    function rounding() public pure returns (uint8) {

        return ROUNDING;
    }

    function name() public pure returns (string memory) {

        return "TrueUSD";
    }

    function symbol() public pure returns (string memory) {

        return "TUSD";
    }

    function canBurn() internal pure returns (bytes32) {

        return "canBurn";
    }

    function initialize() external {

        require(!initialized, "already initialized");
        initialized = true;
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }
}