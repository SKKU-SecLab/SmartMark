


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


interface ISparkleRewardTiers {


  function addTier(uint256 _index, uint256 _rate, uint256 _price, bool _enabled)
  external
  returns(bool);


  function updateTier(uint256 _index, uint256 _rate, uint256 _price, bool _enabled)
  external
  returns(bool);


  function deleteTier(uint256 _index)
  external
  returns(bool);


  function getRate(uint256 _index)
  external
  returns(uint256);


  function getPrice(uint256 _index)
  external
  returns(uint256);


  function getEnabled(uint256 _index)
  external
  returns(bool);


  function withdrawEth()
  external
  returns(bool);


  event TierDeleted(uint256 _index);

  event TierUpdated(uint256 _index, uint256 _rate, uint256 _price, bool _enabled);

  event TierAdded(uint256 _index, uint256 _rate, uint256 _price, bool _enabled);

}


pragma solidity 0.6.12;






contract SparkleRewardTiers is ISparkleRewardTiers, Ownable, Pausable, ReentrancyGuard {


  using SafeMath for uint256;

  struct Tier {
    uint256 _rate;
    uint256 _price;
    bool _enabled;
  }

  mapping(uint256 => Tier) private g_tiers;

  constructor()
  public
  Ownable()
  Pausable()
  ReentrancyGuard()
  {
    Tier memory tier0;
    tier0._rate = uint256(1.00000000 * 10e7);
    tier0._price = 0 ether;
    tier0._enabled = true;
    g_tiers[0] = tier0;

    Tier memory tier1;
    tier1._rate = uint256(1.10000000 * 10e7);
    tier1._price = 0.10 ether;
    tier1._enabled = true;
    g_tiers[1] = tier1;

    Tier memory tier2;
    tier2._rate = uint256(1.20000000 * 10e7);
    tier2._price = 0.20 ether;
    tier2._enabled = true;
    g_tiers[2] = tier2;

    Tier memory tier3;
    tier3._rate = uint256(1.30000000 * 10e7);
    tier3._price = 0.30 ether;
    tier3._enabled = true;
    g_tiers[3] = tier3;
  }

  function addTier(uint256 _index, uint256 _rate, uint256 _price, bool _enabled)
  public
  onlyOwner
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0x0), 'Invalid {From}');
    require(g_tiers[_index]._enabled == false, 'Tier exists');
    Tier memory newTier;
    newTier._rate = _rate;
    newTier._price = _price;
    newTier._enabled = _enabled;
    g_tiers[_index] = newTier;
    emit TierAdded(_index, _rate, _price, _enabled);
    return true;
  }

  function updateTier(uint256 _index, uint256 _rate, uint256 _price, bool _enabled)
  public
  onlyOwner
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0x0), 'Invalid {From}');
    require(g_tiers[_index]._rate > 0, 'Invalid tier');
    require(_rate > 0, 'Invalid rate');
    require(_price > 0, 'Invalid Price');
    g_tiers[_index]._rate = _rate;
    g_tiers[_index]._price = _price;
    g_tiers[_index]._enabled = _enabled;
    emit TierUpdated(_index, _rate, _price, _enabled);
    return true;
  }

  function deleteTier(uint256 _index)
  public
  onlyOwner
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0x0), 'Invalid {From}');
    require(_index >= 4, 'Invalid request');
    delete g_tiers[_index];
    emit TierDeleted(_index);
    return true;
  }

  function getRate(uint256 _index)
  public
  whenNotPaused
  override
  returns(uint256)
  {

    return g_tiers[_index]._rate;
  }

  function getPrice(uint256 _index)
  public
  whenNotPaused
  override
  returns(uint256)
  {

    return g_tiers[_index]._price;
  }

  function getEnabled(uint256 _index)
  public
  whenNotPaused
  override
  returns(bool)
  {

    return g_tiers[_index]._enabled;
  }

  function withdrawEth()
  public
  onlyOwner
  whenNotPaused
  nonReentrant
  override
  returns(bool)
  {

    require(msg.sender != address(0x0), 'Invalid {From}');
    require(address(this).balance >= 0, 'No ether');
    msg.sender.transfer(address(this).balance);
    return true;
  }

  event TierDeleted(uint256 _index);

  event TierUpdated(uint256 _index, uint256 _rate, uint256 _price, bool _enabled);

  event TierAdded(uint256 _index, uint256 _rate, uint256 _price, bool _enabled);

}