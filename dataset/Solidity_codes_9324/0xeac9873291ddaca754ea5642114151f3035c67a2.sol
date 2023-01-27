
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


pragma solidity ^0.8.8;


interface IDecubateVesting {

  event AddToken(address indexed token);

  event Claim(
    address indexed token,
    uint256 amount,
    uint256 indexed option,
    uint256 time
  );

  event AddWhitelist(address indexed wallet);

  event Revoked(address indexed wallet);

  event StatusChanged(address indexed wallet, bool status);

  struct VestingInfo {
    string name;
    uint256 cliff;
    uint256 start;
    uint256 duration;
    uint256 initialUnlockPercent;
    bool revocable;
  }

  struct VestingPool {
    string name;
    uint256 cliff;
    uint256 start;
    uint256 duration;
    uint256 initialUnlockPercent;
    WhitelistInfo[] whitelistPool;
    mapping(address => HasWhitelist) hasWhitelist;
    bool revocable;
  }

  struct MaxTokenTransferValue {
    uint256 amount;
    bool active;
  }

  struct WhitelistInfo {
    address wallet;
    uint256 dcbAmount;
    uint256 distributedAmount;
    uint256 joinDate;
    bool revoke;
    bool disabled;
  }

  struct HasWhitelist {
    uint256 arrIdx;
    bool active;
  }


  function getVestAmount(uint256 _option, address _wallet)
    external
    view
    returns (uint256);


  function getReleasableAmount(uint256 _option, address _wallet)
    external
    view
    returns (uint256);


  function getVestingInfo(uint256 _strategy)
    external
    view
    returns (VestingInfo memory);


  function addVestingStrategy(
    string memory _name,
    uint256 _cliff,
    uint256 _start,
    uint256 _duration,
    uint256 _initialUnlockPercent,
    bool _revocable
  ) external returns (bool);


  function setVestingStrategy(
    uint256 _strategy,
    string memory _name,
    uint256 _cliff,
    uint256 _start,
    uint256 _duration,
    uint256 _initialUnlockPercent,
    bool _revocable
  ) external returns (bool);


  function addWhitelist(
    address _wallet,
    uint256 _dcbAmount,
    uint256 _option
  ) external returns (bool);


  function getWhitelist(uint256 _option, address _wallet)
    external
    view
    returns (WhitelistInfo memory);


  function setWhitelist(
    address _wallet,
    uint256 _dcbAmount,
    uint256 _option
  ) external returns (bool);


  function setToken(address _addr) external returns (bool);


  function getToken() external view returns (address);


  function claimDistribution(uint256 _option, address _wallet)
    external
    returns (bool);


  function getWhitelistPool(uint256 _option)
    external
    view
    returns (WhitelistInfo[] memory);

}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT


pragma solidity ^0.8.8;


contract DecubateVesting is IDecubateVesting, Ownable, ReentrancyGuard {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;


  MaxTokenTransferValue public maxTokenTransfer;
  VestingPool[] public vestingPools;

  IERC20 private _token;

  constructor(address token) {
    _token = IERC20(token);
  }

  modifier optionExists(uint256 _option) {

    require(_option < vestingPools.length, "Vesting option does not exist");
    _;
  }

  modifier userInWhitelist(uint256 _option, address _wallet) {

    require(_option < vestingPools.length, "Vesting option does not exist");
    require(
      vestingPools[_option].hasWhitelist[_wallet].active,
      "User is not in whitelist"
    );
    _;
  }

  function addVestingStrategy(
    string memory _name,
    uint256 _cliff,
    uint256 _start,
    uint256 _duration,
    uint256 _initialUnlockPercent,
    bool _revocable
  ) external override onlyOwner returns (bool) {

    VestingPool storage newStrategy = vestingPools.push();

    newStrategy.cliff = _start.add(_cliff);
    newStrategy.name = _name;
    newStrategy.start = _start;
    newStrategy.duration = _duration;
    newStrategy.initialUnlockPercent = _initialUnlockPercent;
    newStrategy.revocable = _revocable;

    return true;
  }

  function setVestingStrategy(
    uint256 _strategy,
    string memory _name,
    uint256 _cliff,
    uint256 _start,
    uint256 _duration,
    uint256 _initialUnlockPercent,
    bool _revocable
  ) external override onlyOwner returns (bool) {

    require(_strategy < vestingPools.length, "Strategy does not exist");

    VestingPool storage vest = vestingPools[_strategy];

    vest.cliff = _start.add(_cliff);
    vest.name = _name;
    vest.start = _start;
    vest.duration = _duration;
    vest.initialUnlockPercent = _initialUnlockPercent;
    vest.revocable = _revocable;

    return true;
  }

  function setMaxTokenTransfer(uint256 _amount, bool _active)
    external
    onlyOwner
    returns (bool)
  {

    maxTokenTransfer.amount = _amount;
    maxTokenTransfer.active = _active;
    return true;
  }

  function getAllVestingPools() external view returns (VestingInfo[] memory) {

    VestingInfo[] memory infoArr = new VestingInfo[](vestingPools.length);

    for (uint256 i = 0; i < vestingPools.length; i++) {
      infoArr[i] = getVestingInfo(i);
    }

    return infoArr;
  }

  function getVestingInfo(uint256 _strategy)
    public
    view
    optionExists(_strategy)
    returns (VestingInfo memory)
  {

    return
      VestingInfo({
        name: vestingPools[_strategy].name,
        cliff: vestingPools[_strategy].cliff,
        start: vestingPools[_strategy].start,
        duration: vestingPools[_strategy].duration,
        initialUnlockPercent: vestingPools[_strategy].initialUnlockPercent,
        revocable: vestingPools[_strategy].revocable
      });
  }

  function addWhitelist(
    address _wallet,
    uint256 _dcbAmount,
    uint256 _option
  ) public override onlyOwner optionExists(_option) returns (bool) {

    HasWhitelist storage whitelist = vestingPools[_option].hasWhitelist[
      _wallet
    ];
    require(!whitelist.active, "Whitelist already available");

    WhitelistInfo[] storage pool = vestingPools[_option].whitelistPool;

    whitelist.active = true;
    whitelist.arrIdx = pool.length;

    pool.push(
      WhitelistInfo({
        wallet: _wallet,
        dcbAmount: _dcbAmount,
        distributedAmount: 0,
        joinDate: block.timestamp,
        revoke: false,
        disabled: false
      })
    );

    emit AddWhitelist(_wallet);

    return true;
  }

  function batchAddWhitelist(
    address[] memory wallets,
    uint256[] memory amounts,
    uint256 option
  ) external onlyOwner returns (bool) {

    require(wallets.length == amounts.length, "Sizes of inputs do not match");

    for (uint256 i = 0; i < wallets.length; i++) {
      addWhitelist(wallets[i], amounts[i], option);
    }

    return true;
  }

  function setWhitelist(
    address _wallet,
    uint256 _dcbAmount,
    uint256 _option
  )
    external
    override
    onlyOwner
    userInWhitelist(_option, _wallet)
    returns (bool)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage info = vestingPools[_option].whitelistPool[idx];
    info.dcbAmount = _dcbAmount;

    return true;
  }

  function getWhitelist(uint256 _option, address _wallet)
    external
    view
    userInWhitelist(_option, _wallet)
    returns (WhitelistInfo memory)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    return vestingPools[_option].whitelistPool[idx];
  }

  function setToken(address _addr) external override onlyOwner returns (bool) {

    _token = IERC20(_addr);
    return true;
  }

  function getToken() external view override returns (address) {

    return address(_token);
  }

  function calculateVestAmount(uint256 _option, address _wallet)
    internal
    view
    userInWhitelist(_option, _wallet)
    returns (uint256)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo memory whitelist = vestingPools[_option].whitelistPool[idx];
    VestingPool storage vest = vestingPools[_option];

      uint256 initial = whitelist.dcbAmount.mul(vest.initialUnlockPercent).div(
        1000
      );

    if(whitelist.revoke) {
      return whitelist.dcbAmount;
    }
    if (block.timestamp < vest.start) {
      return 0;
    } 
    else if(block.timestamp >= vest.start && block.timestamp < vest.cliff) {
      return initial;
    } 
    else if(block.timestamp >= vest.cliff && block.timestamp < vest.cliff.add(vest.duration)) {
      uint256 remaining = whitelist.dcbAmount.sub(initial); //More accurate

      return
        initial +
        remaining.mul(block.timestamp.sub(vest.cliff)).div(vest.duration);
    } 
    else {
      return whitelist.dcbAmount;
    }
  }

  function calculateReleasableAmount(uint256 _option, address _wallet)
    internal
    view
    userInWhitelist(_option, _wallet)
    returns (uint256)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    return
      calculateVestAmount(_option, _wallet).sub(
        vestingPools[_option].whitelistPool[idx].distributedAmount
      );
  }

  function claimDistribution(uint256 _option, address _wallet)
    external
    override
    nonReentrant
    returns (bool)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

    require(!whitelist.disabled, "User is disabled from claiming token");

    uint256 releaseAmount = calculateReleasableAmount(_option, _wallet);

    require(releaseAmount > 0, "Zero amount to claim");

    if (maxTokenTransfer.active && releaseAmount > maxTokenTransfer.amount) {
      releaseAmount = maxTokenTransfer.amount;
    }

    whitelist.distributedAmount = whitelist.distributedAmount.add(
      releaseAmount
    );

    _token.transfer(_wallet, releaseAmount);

    emit Claim(_wallet, releaseAmount, _option, block.timestamp);

    return true;
  }

  function revoke(uint256 _option, address _wallet)
    public
    onlyOwner
    userInWhitelist(_option, _wallet)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

    require(vestingPools[_option].revocable, "Strategy is not revocable");
    require(!whitelist.revoke, "already revoked");

    whitelist.revoke = true;

    emit Revoked(_wallet);
  }

  function setVesting(uint256 _option, address _wallet, bool _status)
    public
    onlyOwner
    userInWhitelist(_option, _wallet)
  {

    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

    whitelist.disabled = _status;

    emit StatusChanged(_wallet,_status);
  }

  function transferToken(address _addr, uint256 _amount)
    external
    onlyOwner
    returns (bool)
  {

    IERC20 token = IERC20(_addr);
    bool success = token.transfer(address(owner()), _amount);
    return success;
  }

  function getTotalToken(address _addr) external view returns (uint256) {

    IERC20 token = IERC20(_addr);
    return token.balanceOf(address(this));
  }

  function hasWhitelist(uint256 _option, address _wallet)
    external
    view
    returns (bool)
  {

    return vestingPools[_option].hasWhitelist[_wallet].active;
  }

  function getVestAmount(uint256 _option, address _wallet)
    external
    view
    override
    returns (uint256)
  {

    return calculateVestAmount(_option, _wallet);
  }

  function getReleasableAmount(uint256 _option, address _wallet)
    external
    view
    override
    returns (uint256)
  {

    return calculateReleasableAmount(_option, _wallet);
  }

  function getWhitelistPool(uint256 _option)
    external
    view
    optionExists(_option)
    returns (WhitelistInfo[] memory)
  {

    return vestingPools[_option].whitelistPool;
  }
}