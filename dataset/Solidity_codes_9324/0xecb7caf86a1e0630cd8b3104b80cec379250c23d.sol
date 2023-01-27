
pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

contract Context {

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function ownableConstructor () internal {
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

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function pausableConstructor () internal {
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

    function _pause() internal whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

contract DailyLimit {


    event DailyLimitChange(address token, uint dailyLimit);

    mapping(address => uint) public dailyLimit;
    mapping(address => uint) public lastDay;
    mapping(address => uint) public spentToday;


    function _setDailyLimit(address _token, uint _dailyLimit)
        internal
    {

        dailyLimit[_token] = _dailyLimit;
    }

    function _changeDailyLimit(address _token, uint _dailyLimit)
        internal
    {

        dailyLimit[_token] = _dailyLimit;
        emit DailyLimitChange(_token, _dailyLimit);
    }

    function expendDailyLimit(address token, uint amount)
        internal
    {

        require(isUnderDailyLimit(token, amount), "DailyLimit:: expendDailyLimit: Out ot daily limit.");
        spentToday[token] += amount;
    }

    function isUnderDailyLimit(address token, uint amount)
        internal
        returns (bool)
    {

        if (now > lastDay[token] + 24 hours) {
            lastDay[token] = now;
            spentToday[token] = 0;
        }

        if (spentToday[token] + amount > dailyLimit[token] || spentToday[token] + amount < spentToday[token]) {
          return false;
        }
            
        return true;
    }


    function calcMaxWithdraw(address token)
        public
        view
        returns (uint)
    {

        if (now > lastDay[token] + 24 hours) {
          return dailyLimit[token];
        }

        if (dailyLimit[token] < spentToday[token]) {
          return 0;
        }

        return dailyLimit[token] - spentToday[token];
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

pragma experimental ABIEncoderV2;

interface IRelay {

      function verifyRootAndDecodeReceipt(
        bytes32 root,
        uint32 MMRIndex,
        uint32 blockNumber,
        bytes calldata blockHeader,
        bytes32[] calldata peaks,
        bytes32[] calldata siblings,
        bytes calldata proofstr,
        bytes calldata key
    ) external view returns (bytes memory);


     function appendRoot(
        bytes calldata message,
        bytes[] calldata signatures
    ) external;


    function getMMRRoot(uint32 index) external view returns (bytes32);

}// MIT

pragma solidity >=0.6.0 <0.7.0;

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function mint(address _to, uint256 _value) external;

  event Transfer(address indexed from, address indexed to, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.7.0;

interface ISettingsRegistry {

    function addressOf(bytes32 _propertyName) external view returns (address);

    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}