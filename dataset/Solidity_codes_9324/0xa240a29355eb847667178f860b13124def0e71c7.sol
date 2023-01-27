


pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


pragma solidity ^0.8.0;



interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


pragma solidity ^0.8.0;

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


pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}


pragma solidity ^0.8.0;



library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.8.3;







contract RainiStakingPool is AccessControl, ReentrancyGuard {

  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  using SafeMath for uint256;
  using SafeERC20 for IERC20;
 
  uint256 public rewardRate;
  uint256 public minRewardStake;
  uint256 public rewardDecimals = 1000000;

  uint256 public maxBonus;
  uint256 public bonusDuration;
  uint256 public bonusRate;
  uint256 public bonusDecimals = 1000000000;

  uint256 public rainbowToEth;
  uint256 public totalSupply;

  IERC20 public rainiToken;

  mapping(address => uint256) internal staked;
  mapping(address => uint256) internal balances;
  mapping(address => uint256) internal lastBonus;
  mapping(address => uint256) internal lastUpdated;

  event EthWithdrawn(uint256 amount);

  event RewardSet(uint256 rewardRate, uint256 minRewardStake);
  event BonusesSet(uint256 maxBonus, uint256 bonusDuration);
  event RainiTokenSet(address token);
  event RainbowToEthSet(uint256 rainbowToEth);

  event TokensStaked(address payer, uint256 amount, uint256 timestamp);
  event TokensWithdrawn(address owner, uint256 amount, uint256 timestamp);

  event RainbowPointsBurned(address owner, uint256 amount);
  event RainbowPointsMinted(address owner, uint256 amount);
  event RainbowPointsBought(address owner, uint256 amount);

  constructor(address _rainiToken) {
    require(_rainiToken != address(0), "RainiStakingPool: _rainiToken is zero address");
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    rainiToken = IERC20(_rainiToken);
  }

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "RainiStakingPool: caller is not an owner");
    _;
  }

  modifier onlyBurner() {

    require(hasRole(BURNER_ROLE, _msgSender()), "RainiStakingPool: caller is not a burner");
    _;
  }

  modifier onlyMinter() {

    require(hasRole(MINTER_ROLE, _msgSender()), "RainiStakingPool: caller is not a minter");
    _;
  }
  
  modifier balanceUpdate(address _owner) {

    uint256 duration = block.timestamp.sub(lastUpdated[_owner]);
    uint256 reward = calculateReward(_owner, staked[_owner], duration);
    
    balances[_owner] = balances[_owner].add(reward);
    lastUpdated[_owner] = block.timestamp;
    lastBonus[_owner] = Math.min(maxBonus, lastBonus[_owner].add(bonusRate.mul(duration)));
    _;
  }

  function getRewardByDuration(address _owner, uint256 _amount, uint256 _duration) 
    public view returns(uint256) {

      return calculateReward(_owner, _amount, _duration);
  }

  function getStaked(address _owner) 
    public view returns(uint256) {

      return staked[_owner];
  }
  
  function balanceOf(address _owner)
    public view returns(uint256) {

      uint256 reward = calculateReward(_owner, staked[_owner], block.timestamp.sub(lastUpdated[_owner]));
      return balances[_owner].add(reward);
  }

  function getCurrentBonus(address _owner) 
    public view returns(uint256) {

      if(staked[_owner] == 0) {
        return 0;
      } 
      uint256 duration = block.timestamp.sub(lastUpdated[_owner]);
      return Math.min(maxBonus, lastBonus[_owner].add(bonusRate.mul(duration)));
  }

  function getCurrentAvgBonus(address _owner, uint256 _duration)
    public view returns(uint256) {

      if(staked[_owner] == 0) {
        return 0;
      } 
      uint256 avgBonus;
      if(lastBonus[_owner] < maxBonus) {
        uint256 durationTillMax = maxBonus.sub(lastBonus[_owner]).div(bonusRate);
        if(_duration > durationTillMax) {
          uint256 avgWeightedBonusTillMax = lastBonus[_owner].add(maxBonus).div(2).mul(durationTillMax);
          uint256 weightedMaxBonus = maxBonus.mul(_duration.sub(durationTillMax));

          avgBonus = avgWeightedBonusTillMax.add(weightedMaxBonus).div(_duration);
        } else {
          avgBonus = lastBonus[_owner].add(bonusRate.mul(_duration)).add(lastBonus[_owner]).div(2);
        }
      } else {
        avgBonus = maxBonus;
      }
      return avgBonus;
  }

  function setReward(uint256 _rewardRate, uint256 _minRewardStake)
    external onlyOwner {

      rewardRate = _rewardRate;
      minRewardStake = _minRewardStake;

      emit RewardSet(rewardRate, minRewardStake);
  }

  function setRainbowToEth(uint256 _rainbowToEth)
    external onlyOwner {

      rainbowToEth = _rainbowToEth;
      
      emit RainbowToEthSet(_rainbowToEth);
  }

  function setBonus(uint256 _maxBonus, uint256 _bonusDuration)
    external onlyOwner {

      maxBonus = _maxBonus.mul(bonusDecimals);
      bonusDuration = _bonusDuration;
      bonusRate = maxBonus.div(_bonusDuration);

      emit BonusesSet(_maxBonus, _bonusDuration);
  }
  
  function stake(uint256 _amount)
    external nonReentrant balanceUpdate(_msgSender()) {

      require(_amount > 0, "RainiStakingPool: _amount is 0");

      rainiToken.safeTransferFrom(_msgSender(), address(this), _amount);

      totalSupply = totalSupply.add(_amount);      
      uint256 currentStake = staked[_msgSender()];
      staked[_msgSender()] = staked[_msgSender()].add(_amount);
      lastBonus[_msgSender()] = lastBonus[_msgSender()].mul(currentStake).div(staked[_msgSender()]);

      emit TokensStaked(_msgSender(), _amount, block.timestamp);
  }
  
  function withdraw(uint256 _amount)
    external nonReentrant balanceUpdate(_msgSender()) {

      staked[_msgSender()] = staked[_msgSender()].sub(_amount);
      totalSupply = totalSupply.sub(_amount);

      rainiToken.safeTransfer(_msgSender(), _amount);
      
      emit TokensWithdrawn(_msgSender(), _amount, block.timestamp);
  }

  function withdrawEth(uint256 _amount)
    external onlyOwner {

      require(_amount <= address(this).balance, "RainiStakingPool: not enough balance");
      (bool success, ) = _msgSender().call{ value: _amount }("");
      require(success, "RainiStakingPool: transfer failed");
      emit EthWithdrawn(_amount);
  }
  
  function mint(address[] calldata _addresses, uint256[] calldata _points) 
    external onlyMinter {

      require(_addresses.length == _points.length, "RainiStakingPool: Arrays not equal");
      
      for (uint256 i = 0; i < _addresses.length; i++) {
        balances[_addresses[i]] = balances[_addresses[i]].add(_points[i]);
        
        emit RainbowPointsMinted(_addresses[i], _points[i]);
      }
  }
  
  function buyRainbow(uint256 _amount) 
    external payable {

      require(_amount > 0, "RainiStakingPool: _amount is zero");
      require(msg.value.mul(rainbowToEth) >= _amount, "RainiStakingPool: not enougth eth");

      balances[_msgSender()] = balances[_msgSender()].add(_amount);

      uint256 refund = msg.value.sub(_amount.div(rainbowToEth));
      if(refund > 0) {
        (bool success, ) = _msgSender().call{ value: refund }("");
        require(success, "RainiStakingPool: transfer failed");
      }
      
      emit RainbowPointsBought(_msgSender(), _amount);
  }
  
  function burn(address _owner, uint256 _amount) 
    external nonReentrant onlyBurner balanceUpdate(_owner) {

      balances[_owner] = balances[_owner].sub(_amount);
      
      emit RainbowPointsBurned(_owner, _amount);
  }
  
  function calculateReward(address _owner, uint256 _amount, uint256 _duration) 
    private view returns(uint256) {

      uint256 reward = _duration.mul(rewardRate)
        .mul(_amount)
        .div(rewardDecimals)
        .div(minRewardStake);

      return calculateBonus(_owner, reward, _duration);
  }

  function calculateBonus(address _owner, uint256 _amount, uint256 _duration)
    private view returns(uint256) {

      uint256 avgBonus = getCurrentAvgBonus(_owner, _duration);
      return _amount.add(_amount.mul(avgBonus).div(bonusDecimals).div(100));
  }
}