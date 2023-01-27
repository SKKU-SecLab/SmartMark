


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
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
}



pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



pragma solidity 0.6.12;


interface ISparkleTimestamp {


  function addTimestamp(address _rewardAddress)
  external
  returns(bool);


  function resetTimestamp(address _rewardAddress)
  external
  returns(bool);


  function deleteTimestamp(address _rewardAddress)
  external
  returns(bool);


  function getAddress(address _rewardAddress)
  external
  returns(address);


  function getJoinedTimestamp(address _rewardAddress)
  external
  returns(uint256);


  function getDepositTimestamp(address _rewardAddress)
  external
  returns(uint256);


  function getRewardTimestamp(address _rewardAddress)
  external
  returns(uint256);


  function hasTimestamp(address _rewardAddress)
  external
  returns(bool);


  function getTimeRemaining(address _rewardAddress)
  external
  returns(uint256, bool, uint256);


  function isRewardReady(address _rewardAddress)
  external
  returns(bool);


  function setContractAddress(address _newAddress)
  external;


  function getContractAddress()
  external
  returns(address);


  function setTimePeriod(uint256 _newTimePeriod)
  external;


  function getTimePeriod()
  external
  returns(uint256);


  event ResetTimestamp(address _rewardAddress);

	event ContractAddressChanged(address indexed _previousAddress, address indexed _newAddress);

	event TimePeriodChanged( uint256 indexed _previousTimePeriod, uint256 indexed _newTimePeriod);

	event TimestampAdded( address indexed _newTimestampAddress );

	event TimestampDeleted( address indexed _newTimestampAddress );

  event TimestampReset(address _rewardAddress);

}



pragma solidity 0.6.12;






contract SparkleTimestamp is ISparkleTimestamp, Ownable, Pausable, ReentrancyGuard {

  using SafeMath for uint256;

  struct Timestamp {
    address _address;
    uint256 _joined;
    uint256 _deposit;
    uint256 _reward;
  }

  address private contractAddress;

  uint256 private timePeriod;

  mapping(address => mapping(address => Timestamp)) private g_timestamps;

  constructor()
  public
  Ownable()
  Pausable()
  ReentrancyGuard()
  {
    contractAddress = address(0x0);
    timePeriod = 60 * 60 * 24;
  }

  function addTimestamp(address _rewardAddress)
  external
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0x0), 'Invalid {From}a');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0x0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(0x0), 'Timestamp exists');
    g_timestamps[msg.sender][_rewardAddress]._address = address(_rewardAddress);
    g_timestamps[msg.sender][_rewardAddress]._deposit = block.timestamp;
    g_timestamps[msg.sender][_rewardAddress]._joined = block.timestamp;
    g_timestamps[msg.sender][_rewardAddress]._reward = timePeriod.add(block.timestamp);
    emit TimestampAdded(_rewardAddress);
    return true;
  }

  function resetTimestamp(address _rewardAddress)
  external
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0x0), 'Invalid {from}b');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0x0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(_rewardAddress), 'Invalid timestamp');
    g_timestamps[msg.sender][_rewardAddress]._deposit = block.timestamp;
    g_timestamps[msg.sender][_rewardAddress]._reward = uint256(block.timestamp).add(timePeriod);
    return true;
  }

  function deleteTimestamp(address _rewardAddress)
  external
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0), 'Invalid {from}c');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), "Invalid reward address ");
    if(g_timestamps[msg.sender][_rewardAddress]._address != address(_rewardAddress)) {
      emit TimestampDeleted( false );
      return false;
    }

    Timestamp storage ts = g_timestamps[msg.sender][_rewardAddress];
    ts._address = address(0x0);
    ts._deposit = 0;
    ts._reward = 0;
    emit TimestampDeleted( true );
    return true;
  }

  function getAddress(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(address)
  {

    require(msg.sender != address(0), 'Invalid {from}d');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(_rewardAddress), 'No timestamp b');
    return address(g_timestamps[msg.sender][_rewardAddress]._address);
  }

  function getJoinedTimestamp(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(uint256)
  {

    require(msg.sender != address(0), 'Invalid {from}e');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(_rewardAddress), 'No timestamp c');
    return g_timestamps[msg.sender][_rewardAddress]._joined;
  }

  function getDepositTimestamp(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(uint256)
  {

    require(msg.sender != address(0), 'Invalid {from}e');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(_rewardAddress), 'No timestamp d');
    return g_timestamps[msg.sender][_rewardAddress]._deposit;
  }

  function getRewardTimestamp(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(uint256)
  {

    require(msg.sender != address(0), 'Invalid {from}f');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    return g_timestamps[msg.sender][_rewardAddress]._reward;
  }


  function hasTimestamp(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(bool)
  {

    require(msg.sender != address(0), 'Invalid {from}g');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    if(g_timestamps[msg.sender][_rewardAddress]._address != address(_rewardAddress))
    {
      emit TimestampHasTimestamp(false);
      return false;
    }

    emit TimestampHasTimestamp(true);
    return true;
  }

  function getTimeRemaining(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(uint256, bool, uint256)
  {

    require(msg.sender != address(0), 'Invalid {from}h');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(_rewardAddress), 'No timestamp f');
    if(g_timestamps[msg.sender][_rewardAddress]._reward > block.timestamp) {
      return (g_timestamps[msg.sender][_rewardAddress]._reward - block.timestamp, false, g_timestamps[msg.sender][_rewardAddress]._joined);
    }

    return (block.timestamp - g_timestamps[msg.sender][_rewardAddress]._reward, true, g_timestamps[msg.sender][_rewardAddress]._joined);
  }

  function isRewardReady(address _rewardAddress)
  external
  whenNotPaused
  override
  returns(bool)
  {

    require(msg.sender != address(0), 'Invalid {from}i');
    require(msg.sender == address(contractAddress), 'Unauthorized {From}');
    require(_rewardAddress != address(0), 'Invalid reward address');
    require(g_timestamps[msg.sender][_rewardAddress]._address == address(_rewardAddress), 'No timestamp g');
    if(g_timestamps[msg.sender][_rewardAddress]._reward > block.timestamp) {
      return false;
    }

    return true;
  }

  function setContractAddress(address _newAddress)
  external
  onlyOwner
  nonReentrant
  override
  {

    require(msg.sender != address(0), 'Invalid {from}j');
    require(_newAddress != address(0), 'Invalid contract address');
    address currentAddress = contractAddress;
    contractAddress = _newAddress;
    emit ContractAddressChanged(currentAddress, _newAddress);
  }

  function getContractAddress()
  external
  whenNotPaused
  override
  returns(address)
  {

    return address(contractAddress);
  }

  function setTimePeriod(uint256 _newTimePeriod)
  external
  onlyOwner
  nonReentrant
  override
  {

    require(msg.sender != address(0), 'Invalid {from}k');
    require(_newTimePeriod >= 60 seconds, 'Time period < 60s');
    uint256 currentTimePeriod = timePeriod;
    timePeriod = _newTimePeriod;
    emit TimePeriodChanged(currentTimePeriod, _newTimePeriod);
  }

  function getTimePeriod()
  external
  whenNotPaused
  override
  returns(uint256)
  {

    return timePeriod;
  }

  event ResetTimestamp(address _rewardAddress);

	event ContractAddressChanged(address indexed _previousAddress, address indexed _newAddress);

	event TimePeriodChanged( uint256 indexed _previousTimePeriod, uint256 indexed _newTimePeriod);

	event TimestampAdded( address indexed _newTimestampAddress );

	event TimestampDeleted( bool indexed _timestampDeleted );

  event TimestampReset(address _rewardAddress);

  event TimestampHasTimestamp(bool _hasTimestamp);

}