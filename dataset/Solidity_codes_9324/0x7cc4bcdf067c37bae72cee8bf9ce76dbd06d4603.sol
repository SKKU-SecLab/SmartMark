

pragma solidity 0.4.24;

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}


pragma solidity 0.4.24;


contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {

        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {

        return boolStorage[INITIALIZED];
    }
}


pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {

    function upgradeabilityOwner() external view returns (address);

}


pragma solidity 0.4.24;



contract Ownable is EternalStorage {

    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    modifier onlyRelevantSender() {

        require(
            !address(this).call(abi.encodeWithSelector(UPGRADEABILITY_OWNER)) || // covers usage without calling through storage proxy
                msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner() || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    function owner() public view returns (address) {

        return addressStorage[OWNER];
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0));
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}


pragma solidity ^0.4.24;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.4.24;



contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity 0.4.24;


contract ERC677 is ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(address, uint256, bytes) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);

}

contract LegacyERC20 {

    function transfer(address _spender, uint256 _value) public; // returns (bool);

    function transferFrom(address _owner, address _spender, uint256 _value) public; // returns (bool);

}


pragma solidity 0.4.24;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(address _token, address _to, uint256 _value) internal {

        LegacyERC20(_token).transfer(_to, _value);
        assembly {
            if returndatasize {
                returndatacopy(0, 0, 32)
                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
        }
    }

    function safeTransferFrom(address _token, address _from, uint256 _value) internal {

        LegacyERC20(_token).transferFrom(_from, address(this), _value);
        assembly {
            if returndatasize {
                returndatacopy(0, 0, 32)
                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
        }
    }
}


pragma solidity 0.4.24;

contract Sacrifice {

    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}


pragma solidity 0.4.24;


library Address {

    function safeSendValue(address _receiver, uint256 _value) internal {

        if (!_receiver.send(_value)) {
            (new Sacrifice).value(_value)(_receiver);
        }
    }
}


pragma solidity ^0.4.24;


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


pragma solidity 0.4.24;






contract Blocklist is Initializable, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for ERC677;
    using AddressUtils for address;

    address public constant F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    uint256 internal constant MAX_BRIDGEMEDIATORS = 20;
    bytes32 internal constant BRIDGEMEDIATOR_COUNT = 0xb7fa4d5bbcd3a784aacd24904ed0ffd56beb9bc5524e6264358cca799576a4dc; // keccak256(abi.encodePacked("bridgeMediatroCount"))

    event AccountBlockStatusChanged(address account, bool block);
    event Blocked(address token, address account, uint256 value, bytes32 messageId);
    event BridgeMediatorAdded(address mediator);
    event BridgeMediatorRemoved(address mediator);

    modifier onlyBridgeMediator() {

        require(isBridgeMediator(msg.sender), "onlyBridgeMediator");
        _;
    }

    function initialize(
        address _owner,
        address _bridgeMediator
    ) external onlyRelevantSender returns (bool) {

        require(!isInitialized());
        require(_owner != address(0));
        require(_bridgeMediator != address(0) && _bridgeMediator != F_ADDR);
        require(!isBridgeMediator(_bridgeMediator));

        setOwner(_owner);
        setNextBridgeMediator(F_ADDR, _bridgeMediator);
        setNextBridgeMediator(_bridgeMediator, F_ADDR);
        emit BridgeMediatorAdded(_bridgeMediator);

        setBridgeMediatorCount(1);

        setInitialize();

        return isInitialized();
    }

    function addBridgeMediator(address _mediator) external onlyOwner {

        _addBridgeMediator(_mediator);
        emit BridgeMediatorAdded(_mediator);
    }

    function removeBridgeMediator(address _mediator) external onlyOwner {

        _removeBridgeMediator(_mediator);
        emit BridgeMediatorRemoved(_mediator);
    }

    function setBlock(address _account, bool _block) external onlyOwner {

        require(_account != address(0), "Blocklist: invalid parameter");
        boolStorage[keccak256(abi.encodePacked("blocklist", _account))] = _block;
        emit AccountBlockStatusChanged(_account, _block);
    }

    function isBlocked(address _account) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("blocklist", _account))];
    }

    function setBlockedMessageAccount(bytes32 _messageId, address _account) internal {

        addressStorage[keccak256(abi.encodePacked("blockedAccount", _messageId))] = _account;
    }

    function blockedMessageAccount(bytes32 _messageId) external view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("blockedAccount", _messageId))];
    }

    function setBlockedMessageToken(bytes32 _messageId, address _token) internal {

        addressStorage[keccak256(abi.encodePacked("blockedToken", _messageId))] = _token;
    }

    function blockedMessageToken(bytes32 _messageId) external view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("blockedToken", _messageId))];
    }

    function setBlockedMessageValue(bytes32 _messageId, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("blockedValue", _messageId))] = _value;
    }

    function blockedMessageValue(bytes32 _messageId) external view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("blockedValue", _messageId))];
    }

    function blockERC20(address _token, address _account, uint256 _value, bytes32 _messageId) public onlyBridgeMediator {

        ERC677(_token).safeTransferFrom(msg.sender, _value);

        if (_messageId == 0) {
            _messageId = keccak256(abi.encodePacked(_account, _token, _value, block.number));
        }
        setBlockedMessageAccount(_messageId, _account);
        setBlockedMessageToken(_messageId, _token);
        setBlockedMessageValue(_messageId, _value);

        emit Blocked(_token, _account, _value, _messageId);
    }

    function blockNative(address _account, bytes32 _messageId) public payable onlyBridgeMediator {

        if (_messageId == 0) {
            _messageId = keccak256(abi.encodePacked(_account, address(0), msg.value, block.number));
        }
        setBlockedMessageAccount(_messageId, _account);
        setBlockedMessageValue(_messageId, msg.value);

        emit Blocked(address(0), _account, msg.value, _messageId);
    }

    function checkAndBlockERC20(address _from, address _recipient,
            address _token, uint256 _value, bytes32 _messageId) public onlyBridgeMediator returns (bool blocked) {


        if (_from != address(0) && isBlocked(_from)) {
            blockERC20(_token, _from, _value, _messageId);
            blocked = true;
            return;
        }

        if (_recipient != address(0) && isBlocked(_recipient)) {
            blockERC20(_token, _recipient, _value, _messageId);
            blocked = true;
        }
    }

    function withdraw(address _token, address _to, uint256 _amount) external onlyOwner {

        uint256 balance = ERC677(_token).balanceOf(address(this));
        ERC677(_token).safeTransfer(_to, _amount > balance ? balance : _amount);
    }

    function withdraw(address _to, uint256 _amount) external onlyOwner {

        Address.safeSendValue(_to, _amount > address(this).balance ? address(this).balance : _amount);
    }

    function bridgeMediatorList() external view returns (address[]) {

        address[] memory list = new address[](bridgeMediatorCount());
        uint256 counter = 0;
        address nextMediator = getNextBridgeMediator(F_ADDR);
        require(nextMediator != address(0));

        while (nextMediator != F_ADDR) {
            list[counter] = nextMediator;
            nextMediator = getNextBridgeMediator(nextMediator);
            counter++;

            require(nextMediator != address(0));
        }

        return list;
    }

    function _addBridgeMediator(address _bridgeMediator) internal {

        require(_bridgeMediator != address(0) && _bridgeMediator != F_ADDR);
        require(!isBridgeMediator(_bridgeMediator));

        address firstMediator = getNextBridgeMediator(F_ADDR);
        require(firstMediator != address(0));
        setNextBridgeMediator(_bridgeMediator, firstMediator);
        setNextBridgeMediator(F_ADDR, _bridgeMediator);
        setBridgeMediatorCount(bridgeMediatorCount().add(1));
    }

    function _removeBridgeMediator(address _bridgeMediator) internal {

        require(isBridgeMediator(_bridgeMediator));
        address mediatorsNext = getNextBridgeMediator(_bridgeMediator);
        address index = F_ADDR;
        address next = getNextBridgeMediator(index);
        require(next != address(0));

        while (next != _bridgeMediator) {
            index = next;
            next = getNextBridgeMediator(index);

            require(next != F_ADDR && next != address(0));
        }

        setNextBridgeMediator(index, mediatorsNext);
        deleteItemFromAddressStorage("bridgeMediatorsList", _bridgeMediator);
        setBridgeMediatorCount(bridgeMediatorCount().sub(1));
    }

    function bridgeMediatorCount() public view returns (uint256) {

        return uintStorage[BRIDGEMEDIATOR_COUNT];
    }

    function isBridgeMediator(address _bridgeMediator) public view returns (bool) {

        return _bridgeMediator != F_ADDR && getNextBridgeMediator(_bridgeMediator) != address(0);
    }

    function getNextBridgeMediator(address _address) public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeMediatorsList", _address))];
    }

    function deleteItemFromAddressStorage(string _mapName, address _address) internal {

        delete addressStorage[keccak256(abi.encodePacked(_mapName, _address))];
    }

    function setBridgeMediatorCount(uint256 _bridgeMediatorCount) internal {

        require(_bridgeMediatorCount <= MAX_BRIDGEMEDIATORS);
        uintStorage[BRIDGEMEDIATOR_COUNT] = _bridgeMediatorCount;
    }

    function setNextBridgeMediator(address _prevMediator, address _bridgeMediator) internal {

        addressStorage[keccak256(abi.encodePacked("bridgeMediatorsList", _prevMediator))] = _bridgeMediator;
    }
}