
pragma solidity ^0.4.23;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


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

        return (_admin == owner || hasAttribute(_admin, keccak256(WRITE_PERMISSION ^ _attribute)));
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

    function syncAttribute(bytes32 _attribute, uint256 _startIndex, address[] _addresses) external {

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

    function reclaimEther(address _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(ERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(this);
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


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

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


contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {

    pendingOwner = newOwner;
  }

  function claimOwnership() onlyPendingOwner public {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


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
}


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


contract TrueCoinReceiver {

    function tokenFallback( address from, uint256 value ) external;

}


contract ReclaimerToken is HasOwner {

    function reclaimEther(address _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(ERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(this);
        token.transfer(_to, balance);
    }

    function reclaimContract(Ownable _ownable) external onlyOwner {

        _ownable.transferOwnership(owner);
    }

}


contract ModularBasicToken is HasOwner {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() public view returns (uint256) {

        return totalSupply_;
    }

    function balanceOf(address _who) public view returns (uint256) {

        return _getBalance(_who);
    }
    function _getBalance(address _who) internal view returns (uint256 outBalance) {

        bytes32 storageLocation = keccak256(_who);
        assembly {
            outBalance := sload(storageLocation)
        }
    }
    function _addBalance(address _who, uint256 _value) internal returns (uint256 priorBalance) {

        bytes32 storageLocation = keccak256(_who);
        assembly {
            priorBalance := sload(storageLocation)
        }
        uint256 result = priorBalance.add(_value);
        assembly {
            sstore(storageLocation, result)
        }
    }
    function _subBalance(address _who, uint256 _value) internal returns (uint256 result) {

        bytes32 storageLocation = keccak256(_who);
        uint256 priorBalance;
        assembly {
            priorBalance := sload(storageLocation)
        }
        result = priorBalance.sub(_value);
        assembly {
            sstore(storageLocation, result)
        }
    }
    function _setBalance(address _who, uint256 _value) internal {

        bytes32 storageLocation = keccak256(_who);
        assembly {
            sstore(storageLocation, _value)
        }
    }
}


contract ModularStandardToken is ModularBasicToken {

    using SafeMath for uint256;
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function approve(address _spender, uint256 _value) public returns (bool) {

        _approveAllArgs(_spender, _value, msg.sender);
        return true;
    }

    function _approveAllArgs(address _spender, uint256 _value, address _tokenHolder) internal {

        _setAllowance(_tokenHolder, _spender, _value);
        emit Approval(_tokenHolder, _spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        _increaseApprovalAllArgs(_spender, _addedValue, msg.sender);
        return true;
    }

    function _increaseApprovalAllArgs(address _spender, uint256 _addedValue, address _tokenHolder) internal {

        _addAllowance(_tokenHolder, _spender, _addedValue);
        emit Approval(_tokenHolder, _spender, _getAllowance(_tokenHolder, _spender));
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        _decreaseApprovalAllArgs(_spender, _subtractedValue, msg.sender);
        return true;
    }

    function _decreaseApprovalAllArgs(address _spender, uint256 _subtractedValue, address _tokenHolder) internal {

        uint256 oldValue = _getAllowance(_tokenHolder, _spender);
        uint256 newValue;
        if (_subtractedValue > oldValue) {
            newValue = 0;
        } else {
            newValue = oldValue - _subtractedValue;
        }
        _setAllowance(_tokenHolder, _spender, newValue);
        emit Approval(_tokenHolder,_spender, newValue);
    }

    function allowance(address _who, address _spender) public view returns (uint256) {

        return _getAllowance(_who, _spender);
    }

    function _getAllowance(address _who, address _spender) internal view returns (uint256 value) {

        bytes32 storageLocation = keccak256(_who, _spender);
        assembly {
            value := sload(storageLocation)
        }
    }
    function _addAllowance(address _who, address _spender, uint256 _value) internal {

        bytes32 storageLocation = keccak256(_who, _spender);
        uint256 value;
        assembly {
            value := sload(storageLocation)
        }
        value = value.add(_value);
        assembly {
            sstore(storageLocation, value)
        }
    }
    function _subAllowance(address _who, address _spender, uint256 _value) internal returns (bool allowanceZero){

        bytes32 storageLocation = keccak256(_who, _spender);
        uint256 value;
        assembly {
            value := sload(storageLocation)
        }
        value = value.sub(_value);
        assembly {
            sstore(storageLocation, value)
        }
        allowanceZero = value == 0;
    }
    function _setAllowance(address _who, address _spender, uint256 _value) internal {

        bytes32 storageLocation = keccak256(_who, _spender);
        assembly {
            sstore(storageLocation, _value)
        }
    }
}


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


contract GasRefundToken is ProxyStorage {



    function sponsorGas2() external {

        assembly {
            mstore(0, or(0x601f8060093d393df33d33730000000000000000000000000000000000000000, address))
            mstore(32,   0x14601d5780fd5bff000000000000000000000000000000000000000000000000)
            let sheep := create(0, 0, 0x28)
            let offset := sload(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            let location := sub(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe, offset)
            sstore(location, sheep)
            sheep := create(0, 0, 0x28)
            sstore(sub(location, 1), sheep)
            sheep := create(0, 0, 0x28)
            sstore(sub(location, 2), sheep)
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


contract CompliantDepositTokenWithHook is ReclaimerToken, RegistryClone, BurnableTokenWithBounds, GasRefundToken {


    bytes32 constant IS_REGISTERED_CONTRACT = "isRegisteredContract";
    bytes32 constant IS_DEPOSIT_ADDRESS = "isDepositAddress";
    uint256 constant REDEMPTION_ADDRESS_COUNT = 0x100000;
    bytes32 constant IS_BLACKLISTED = "isBlacklisted";

    function canBurn() internal pure returns (bytes32);


    function transfer(address _to, uint256 _value) public returns (bool) {

        address _from = msg.sender;
        if (uint256(_to) < REDEMPTION_ADDRESS_COUNT) {
            _value -= _value % CENT;
            _burnFromAllArgs(_from, _to, _value);
        } else {
            _transferAllArgs(_from, _to, _value);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        if (uint256(_to) < REDEMPTION_ADDRESS_COUNT) {
            _value -= _value % CENT;
            _burnFromAllowanceAllArgs(_from, _to, _value);
        } else {
            _transferFromAllArgs(_from, _to, _value, msg.sender);
        }
        return true;
    }

    function _burnFromAllowanceAllArgs(address _from, address _to, uint256 _value) internal {

        _requireCanTransferFrom(msg.sender, _from, _to);
        _requireOnlyCanBurn(_to);
        require(_value >= burnMin, "below min burn bound");
        require(_value <= burnMax, "exceeds max burn bound");
        if (0 == _subBalance(_from, _value)) {
            if (_subAllowance(_from, msg.sender, _value)) {
            } else {
                gasRefund15();
            }
        } else {
            if (_subAllowance(_from, msg.sender, _value)) {
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

    function _transferFromAllArgs(address _from, address _to, uint256 _value, address _sender) internal {

        bool hasHook;
        address originalTo = _to;
        (_to, hasHook) = _requireCanTransferFrom(_sender, _from, _to);
        if (0 == _addBalance(_to, _value)) {
            if (_subAllowance(_from, _sender, _value)) {
                if (0 == _subBalance(_from, _value)) {
                } else {
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
            if (_subAllowance(_from, _sender, _value)) {
                if (0 == _subBalance(_from, _value)) {
                } else {
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

    function _transferAllArgs(address _from, address _to, uint256 _value) internal {

        bool hasHook;
        address finalTo;
        (finalTo, hasHook) = _requireCanTransfer(_from, _to);
        if (0 == _subBalance(_from, _value)) {
            if (0 == _addBalance(finalTo, _value)) {
                gasRefund30();
            } else {
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
        emit SetRegistry(registry);
    }

    modifier onlyRegistry {

      require(msg.sender == address(registry));
      _;
    }

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) public onlyRegistry {

        bytes32 storageLocation = keccak256(_who, _attribute);
        assembly {
            sstore(storageLocation, _value)
        }
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

        bytes32 storageLocation = keccak256(_account, IS_BLACKLISTED);
        assembly {
            blacklisted := sload(storageLocation)
        }
    }

    function _requireCanTransfer(address _from, address _to) internal view returns (address, bool) {

        uint256 depositAddressValue;
        bytes32 storageLocation = keccak256(address(uint256(_to) >> 20),IS_DEPOSIT_ADDRESS);
        assembly {
            depositAddressValue := sload(storageLocation)
        }
        if (depositAddressValue != 0) {
            _to = address(depositAddressValue);
        }
        uint256 flag;
        storageLocation = keccak256(_to, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(_from, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(_to, IS_REGISTERED_CONTRACT);
        assembly {
            flag := sload(storageLocation)
        }
        return (_to, flag != 0);
    }

    function _requireCanTransferFrom(address _sender, address _from, address _to) internal view returns (address, bool) {

        uint256 flag;
        bytes32 storageLocation = keccak256(_sender, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(address(uint256(_to) >> 20),IS_DEPOSIT_ADDRESS);
        assembly {
            flag := sload(storageLocation)
        }
        if (flag != 0) {
            _to = address(flag);
        }
        storageLocation = keccak256(_to, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(_from, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(_to, IS_REGISTERED_CONTRACT);
        assembly {
            flag := sload(storageLocation)
        }
        return (_to, flag != 0);
    }

    function _requireCanMint(address _to) internal view returns (address, bool) {

        uint256 flag;
        bytes32 storageLocation = keccak256(_to, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(address(uint256(_to) >> 20), IS_DEPOSIT_ADDRESS);
        assembly {
            flag := sload(storageLocation)
        }
        if (flag != 0) {
            _to = address(flag);
        }
        storageLocation = keccak256(_to, IS_REGISTERED_CONTRACT);
        assembly {
            flag := sload(storageLocation)
        }
        return (_to, flag != 0);
    }

    function _requireOnlyCanBurn(address _from) internal view {

        bytes32 storageLocation = keccak256(_from, canBurn());
        uint256 flag;
        assembly {
            flag := sload(storageLocation)
        }
        require (flag != 0, "cannot burn from this address");
    }

    function _requireCanBurn(address _from) internal view {

        uint256 flag;
        bytes32 storageLocation = keccak256(_from, IS_BLACKLISTED);
        assembly {
            flag := sload(storageLocation)
        }
        require (flag == 0, "blacklisted");
        storageLocation = keccak256(_from, canBurn());
        assembly {
            flag := sload(storageLocation)
        }
        require (flag != 0, "cannot burn from this address");
    }

    function paused() public pure returns (bool) {

        return false;
    }
}


contract Proxy {

    
    function implementation() public view returns (address);


    function() external payable {
        address _impl = implementation();
        
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}


contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant implementationPosition = 0xdc8e328a3c0acffa7969856957539d0f8c2deaa0d39abaf20397a9fa3b45bf17; //keccak256("trueGBP.proxy.implementation");

    function implementation() public view returns (address impl) {

        bytes32 position = implementationPosition;
        assembly {
          impl := sload(position)
        }
    }

    function _setImplementation(address newImplementation) internal {

        bytes32 position = implementationPosition;
        assembly {
          sstore(position, newImplementation)
        }
    }

    function _upgradeTo(address newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != newImplementation);
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
}


contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event NewPendingOwner(address currentOwner, address pendingOwner);
    
    bytes32 private constant proxyOwnerPosition = 0x58709042d6c9a2b64c8e7802bfedabdcd2eaecc68e15ef2e896a5970c608cd16;//keccak256("trueGBP.proxy.owner");
    bytes32 private constant pendingProxyOwnerPosition = 0xa6933dbb41d1bc3d681619c11234027db3b75954220aa88dfdc74750053ed30c;//keccak256("trueGBP.pending.proxy.owner");

    constructor() public {
        _setUpgradeabilityOwner(msg.sender);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner(), "only Proxy Owner");
        _;
    }

    modifier onlyPendingProxyOwner() {

        require(msg.sender == pendingProxyOwner(), "only pending Proxy Owner");
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = proxyOwnerPosition;
        assembly {
            owner := sload(position)
        }
    }

    function pendingProxyOwner() public view returns (address pendingOwner) {

        bytes32 position = pendingProxyOwnerPosition;
        assembly {
            pendingOwner := sload(position)
        }
    }

    function _setUpgradeabilityOwner(address newProxyOwner) internal {

        bytes32 position = proxyOwnerPosition;
        assembly {
            sstore(position, newProxyOwner)
        }
    }

    function _setPendingUpgradeabilityOwner(address newPendingProxyOwner) internal {

        bytes32 position = pendingProxyOwnerPosition;
        assembly {
            sstore(position, newPendingProxyOwner)
        }
    }

    function transferProxyOwnership(address newOwner) external onlyProxyOwner {

        require(newOwner != address(0));
        _setPendingUpgradeabilityOwner(newOwner);
        emit NewPendingOwner(proxyOwner(), newOwner);
    }

    function claimProxyOwnership() external onlyPendingProxyOwner {

        emit ProxyOwnershipTransferred(proxyOwner(), pendingProxyOwner());
        _setUpgradeabilityOwner(pendingProxyOwner());
        _setPendingUpgradeabilityOwner(address(0));
    }

    function upgradeTo(address implementation) external onlyProxyOwner {

        _upgradeTo(implementation);
    }
}



contract TokenController {

    using SafeMath for uint256;

    struct MintOperation {
        address to;
        uint256 value;
        uint256 requestedBlock;
        uint256 numberOfApproval;
        bool paused;
        mapping(address => bool) approved; 
    }

    address public owner;
    address public pendingOwner;

    bool public initialized;

    uint256 public instantMintThreshold;
    uint256 public ratifiedMintThreshold;
    uint256 public multiSigMintThreshold;


    uint256 public instantMintLimit; 
    uint256 public ratifiedMintLimit; 
    uint256 public multiSigMintLimit;

    uint256 public instantMintPool; 
    uint256 public ratifiedMintPool; 
    uint256 public multiSigMintPool;
    address[2] public ratifiedPoolRefillApprovals;

    uint8 constant public RATIFY_MINT_SIGS = 1; //number of approvals needed to finalize a Ratified Mint
    uint8 constant public MULTISIG_MINT_SIGS = 3; //number of approvals needed to finalize a MultiSig Mint

    bool public mintPaused;
    uint256 public mintReqInvalidBeforeThisBlock; //all mint request before this block are invalid
    address public mintKey;
    MintOperation[] public mintOperations; //list of a mint requests
    
    CompliantDepositTokenWithHook public token;
    Registry public registry;
    address public fastPause;

    bytes32 constant public IS_MINT_PAUSER = "isTUSDMintPausers";
    bytes32 constant public IS_MINT_RATIFIER = "isTUSDMintRatifier";
    bytes32 constant public IS_REDEMPTION_ADMIN = "isTUSDRedemptionAdmin";

    address constant public PAUSED_IMPLEMENTATION = address(1); // ***To be changed the paused version of TrueUSD in Production

    modifier onlyFastPauseOrOwner() {

        require(msg.sender == fastPause || msg.sender == owner, "must be pauser or owner");
        _;
    }

    modifier onlyMintKeyOrOwner() {

        require(msg.sender == mintKey || msg.sender == owner, "must be mintKey or owner");
        _;
    }

    modifier onlyMintPauserOrOwner() {

        require(registry.hasAttribute(msg.sender, IS_MINT_PAUSER) || msg.sender == owner, "must be pauser or owner");
        _;
    }

    modifier onlyMintRatifierOrOwner() {

        require(registry.hasAttribute(msg.sender, IS_MINT_RATIFIER) || msg.sender == owner, "must be ratifier or owner");
        _;
    }

    modifier onlyOwnerOrRedemptionAdmin() {

        require(registry.hasAttribute(msg.sender, IS_REDEMPTION_ADMIN) || msg.sender == owner, "must be Redemption admin or owner");
        _;
    }

    modifier mintNotPaused() {

        if (msg.sender != owner) {
            require(!mintPaused, "minting is paused");
        }
        _;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event NewOwnerPending(address indexed currentOwner, address indexed pendingOwner);
    event SetRegistry(address indexed registry);
    event TransferChild(address indexed child, address indexed newOwner);
    event RequestReclaimContract(address indexed other);
    event SetToken(CompliantDepositTokenWithHook newContract);
    
    event RequestMint(address indexed to, uint256 indexed value, uint256 opIndex, address mintKey);
    event FinalizeMint(address indexed to, uint256 indexed value, uint256 opIndex, address mintKey);
    event InstantMint(address indexed to, uint256 indexed value, address indexed mintKey);
    
    event TransferMintKey(address indexed previousMintKey, address indexed newMintKey);
    event MintRatified(uint256 indexed opIndex, address indexed ratifier);
    event RevokeMint(uint256 opIndex);
    event AllMintsPaused(bool status);
    event MintPaused(uint opIndex, bool status);
    event MintApproved(address approver, uint opIndex);
    event FastPauseSet(address _newFastPause);

    event MintThresholdChanged(uint instant, uint ratified, uint multiSig);
    event MintLimitsChanged(uint instant, uint ratified, uint multiSig);
    event InstantPoolRefilled();
    event RatifyPoolRefilled();
    event MultiSigPoolRefilled();


    function initialize() external {

        require(!initialized, "already initialized");
        owner = msg.sender;
        initialized = true;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "only Owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        pendingOwner = newOwner;
        emit NewOwnerPending(owner, pendingOwner);
    }

    function claimOwnership() external onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
    

    function transferTusdProxyOwnership(address _newOwner) external onlyOwner {

        OwnedUpgradeabilityProxy(token).transferProxyOwnership(_newOwner);
    }

    function claimTusdProxyOwnership() external onlyOwner {

        OwnedUpgradeabilityProxy(token).claimProxyOwnership();
    }

    function upgradeTusdProxyImplTo(address _implementation) external onlyOwner {

        OwnedUpgradeabilityProxy(token).upgradeTo(_implementation);
    }


    function setMintThresholds(uint256 _instant, uint256 _ratified, uint256 _multiSig) external onlyOwner {

        require(_instant <= _ratified && _ratified <= _multiSig);
        instantMintThreshold = _instant;
        ratifiedMintThreshold = _ratified;
        multiSigMintThreshold = _multiSig;
        emit MintThresholdChanged(_instant, _ratified, _multiSig);
    }


    function setMintLimits(uint256 _instant, uint256 _ratified, uint256 _multiSig) external onlyOwner {

        require(_instant <= _ratified && _ratified <= _multiSig);
        instantMintLimit = _instant;
        if (instantMintPool > instantMintLimit) {
            instantMintPool = instantMintLimit;
        }
        ratifiedMintLimit = _ratified;
        if (ratifiedMintPool > ratifiedMintLimit) {
            ratifiedMintPool = ratifiedMintLimit;
        }
        multiSigMintLimit = _multiSig;
        if (multiSigMintPool > multiSigMintLimit) {
            multiSigMintPool = multiSigMintLimit;
        }
        emit MintLimitsChanged(_instant, _ratified, _multiSig);
    }

    function refillInstantMintPool() external onlyMintRatifierOrOwner {

        ratifiedMintPool = ratifiedMintPool.sub(instantMintLimit.sub(instantMintPool));
        instantMintPool = instantMintLimit;
        emit InstantPoolRefilled();
    }

    function refillRatifiedMintPool() external onlyMintRatifierOrOwner {

        if (msg.sender != owner) {
            address[2] memory refillApprovals = ratifiedPoolRefillApprovals;
            require(msg.sender != refillApprovals[0] && msg.sender != refillApprovals[1]);
            if (refillApprovals[0] == address(0)) {
                ratifiedPoolRefillApprovals[0] = msg.sender;
                return;
            } 
            if (refillApprovals[1] == address(0)) {
                ratifiedPoolRefillApprovals[1] = msg.sender;
                return;
            } 
        }
        delete ratifiedPoolRefillApprovals; // clears the whole array
        multiSigMintPool = multiSigMintPool.sub(ratifiedMintLimit.sub(ratifiedMintPool));
        ratifiedMintPool = ratifiedMintLimit;
        emit RatifyPoolRefilled();
    }

    function refillMultiSigMintPool() external onlyOwner {

        multiSigMintPool = multiSigMintLimit;
        emit MultiSigPoolRefilled();
    }

    function requestMint(address _to, uint256 _value) external mintNotPaused onlyMintKeyOrOwner {

        MintOperation memory op = MintOperation(_to, _value, block.number, 0, false);
        emit RequestMint(_to, _value, mintOperations.length, msg.sender);
        mintOperations.push(op);
    }


    function instantMint(address _to, uint256 _value) external mintNotPaused onlyMintKeyOrOwner {

        require(_value <= instantMintThreshold, "over the instant mint threshold");
        require(_value <= instantMintPool, "instant mint pool is dry");
        instantMintPool = instantMintPool.sub(_value);
        emit InstantMint(_to, _value, msg.sender);
        token.mint(_to, _value);
    }


    function ratifyMint(uint256 _index, address _to, uint256 _value) external mintNotPaused onlyMintRatifierOrOwner {

        MintOperation memory op = mintOperations[_index];
        require(op.to == _to, "to address does not match");
        require(op.value == _value, "amount does not match");
        require(!mintOperations[_index].approved[msg.sender], "already approved");
        mintOperations[_index].approved[msg.sender] = true;
        mintOperations[_index].numberOfApproval = mintOperations[_index].numberOfApproval.add(1);
        emit MintRatified(_index, msg.sender);
        if (hasEnoughApproval(mintOperations[_index].numberOfApproval, _value)){
            finalizeMint(_index);
        }
    }

    function finalizeMint(uint256 _index) public mintNotPaused {

        MintOperation memory op = mintOperations[_index];
        address to = op.to;
        uint256 value = op.value;
        if (msg.sender != owner) {
            require(canFinalize(_index));
            _subtractFromMintPool(value);
        }
        delete mintOperations[_index];
        token.mint(to, value);
        emit FinalizeMint(to, value, _index, msg.sender);
    }

    function _subtractFromMintPool(uint256 _value) internal {

        if (_value <= ratifiedMintPool && _value <= ratifiedMintThreshold) {
            ratifiedMintPool = ratifiedMintPool.sub(_value);
        } else {
            multiSigMintPool = multiSigMintPool.sub(_value);
        }
    }

    function hasEnoughApproval(uint256 _numberOfApproval, uint256 _value) public view returns (bool) {

        if (_value <= ratifiedMintPool && _value <= ratifiedMintThreshold) {
            if (_numberOfApproval >= RATIFY_MINT_SIGS){
                return true;
            }
        }
        if (_value <= multiSigMintPool && _value <= multiSigMintThreshold) {
            if (_numberOfApproval >= MULTISIG_MINT_SIGS){
                return true;
            }
        }
        if (msg.sender == owner) {
            return true;
        }
        return false;
    }

    function canFinalize(uint256 _index) public view returns(bool) {

        MintOperation memory op = mintOperations[_index];
        require(op.requestedBlock > mintReqInvalidBeforeThisBlock, "this mint is invalid"); //also checks if request still exists
        require(!op.paused, "this mint is paused");
        require(hasEnoughApproval(op.numberOfApproval, op.value), "not enough approvals");
        return true;
    }

    function revokeMint(uint256 _index) external onlyMintKeyOrOwner {

        delete mintOperations[_index];
        emit RevokeMint(_index);
    }

    function mintOperationCount() public view returns (uint256) {

        return mintOperations.length;
    }


    function transferMintKey(address _newMintKey) external onlyOwner {

        require(_newMintKey != address(0), "new mint key cannot be 0x0");
        emit TransferMintKey(mintKey, _newMintKey);
        mintKey = _newMintKey;
    }
 

    function invalidateAllPendingMints() external onlyOwner {

        mintReqInvalidBeforeThisBlock = block.number;
    }

    function pauseMints() external onlyMintPauserOrOwner {

        mintPaused = true;
        emit AllMintsPaused(true);
    }

    function unpauseMints() external onlyOwner {

        mintPaused = false;
        emit AllMintsPaused(false);
    }

    function pauseMint(uint _opIndex) external onlyMintPauserOrOwner {

        mintOperations[_opIndex].paused = true;
        emit MintPaused(_opIndex, true);
    }

    function unpauseMint(uint _opIndex) external onlyOwner {

        mintOperations[_opIndex].paused = false;
        emit MintPaused(_opIndex, false);
    }



    function setToken(CompliantDepositTokenWithHook _newContract) external onlyOwner {

        token = _newContract;
        emit SetToken(_newContract);
    }

    function setRegistry(Registry _registry) external onlyOwner {

        registry = _registry;
        emit SetRegistry(registry);
    }

    function setTokenRegistry(Registry _registry) external onlyOwner {

        token.setRegistry(_registry);
    }

    function issueClaimOwnership(address _other) public onlyOwner {

        HasOwner other = HasOwner(_other);
        other.claimOwnership();
    }

    function transferChild(HasOwner _child, address _newOwner) external onlyOwner {

        _child.transferOwnership(_newOwner);
        emit TransferChild(_child, _newOwner);
    }

    function requestReclaimContract(Ownable _other) public onlyOwner {

        token.reclaimContract(_other);
        emit RequestReclaimContract(_other);
    }

    function requestReclaimEther() external onlyOwner {

        token.reclaimEther(owner);
    }

    function requestReclaimToken(ERC20 _token) external onlyOwner {

        token.reclaimToken(_token, owner);
    }

    function setFastPause(address _newFastPause) external onlyOwner {

        fastPause = _newFastPause;
        emit FastPauseSet(_newFastPause);
    }

    function pauseToken() external onlyFastPauseOrOwner {

        OwnedUpgradeabilityProxy(token).upgradeTo(PAUSED_IMPLEMENTATION);
    }
    
    function wipeBlackListedTrueUSD(address _blacklistedAddress) external onlyOwner {

        token.wipeBlacklistedAccount(_blacklistedAddress);
    }

    function setBurnBounds(uint256 _min, uint256 _max) external onlyOwner {

        token.setBurnBounds(_min, _max);
    }

    function reclaimEther(address _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(ERC20 _token, address _to) external onlyOwner {

        uint256 balance = _token.balanceOf(this);
        _token.transfer(_to, balance);
    }
}


contract TokenControllerMock is TokenController {

    address public pausedImplementation;
    
    function setPausedImplementation(address _pausedToken) external {

        pausedImplementation = _pausedToken;
    }

    function pauseToken() external onlyFastPauseOrOwner {

        OwnedUpgradeabilityProxy(token).upgradeTo(pausedImplementation);
    }

}