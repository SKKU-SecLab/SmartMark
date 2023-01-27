
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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}// AGPL-3.0
pragma solidity 0.8.3;


interface IWETH is IERC20 {

  function deposit() external payable;


  function withdraw(uint256 wad) external;

}// AGPL-3.0
pragma solidity 0.8.3;


interface IRegistry is IAccessControl {

  function paused() external view returns (bool);


  function pause() external;


  function unpause() external;


  function enableFeatureFlag(bytes32 _featureFlag) external;


  function disableFeatureFlag(bytes32 _featureFlag) external;


  function getFeatureFlag(bytes32 _featureFlag) external view returns (bool);


  function denominator() external view returns (uint256);


  function weth() external view returns (IWETH);


  function authorized(bytes32 _role, address _account)
    external
    view
    returns (bool);

}// MIT

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
}// MIT

pragma solidity ^0.8.0;


library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}// AGPL-3.0
pragma solidity 0.8.3;


library OLib {

  using Arrays for uint256[];

  enum State {Inactive, Deposit, Live, Withdraw}

  enum Tranche {Senior, Junior}

  struct VaultParams {
    address seniorAsset;
    address juniorAsset;
    address strategist;
    address strategy;
    uint256 hurdleRate;
    uint256 startTime;
    uint256 enrollment;
    uint256 duration;
    string seniorName;
    string seniorSym;
    string juniorName;
    string juniorSym;
    uint256 seniorTrancheCap;
    uint256 seniorUserCap;
    uint256 juniorTrancheCap;
    uint256 juniorUserCap;
  }

  struct RolloverParams {
    address strategist;
    string seniorName;
    string seniorSym;
    string juniorName;
    string juniorSym;
  }

  bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
  bytes32 public constant PANIC_ROLE = keccak256("PANIC_ROLE");
  bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
  bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
  bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
  bytes32 public constant STRATEGIST_ROLE = keccak256("STRATEGIST_ROLE");
  bytes32 public constant VAULT_ROLE = keccak256("VAULT_ROLE");
  bytes32 public constant ROLLOVER_ROLE = keccak256("ROLLOVER_ROLE");
  bytes32 public constant STRATEGY_ROLE = keccak256("STRATEGY_ROLE");


  struct Investor {
    uint256[] userSums;
    uint256[] prefixSums;
    bool claimed;
    bool withdrawn;
  }

  function getInvestedAndExcess(Investor storage investor, uint256 invested)
    internal
    view
    returns (uint256 userInvested, uint256 excess)
  {

    uint256[] storage prefixSums_ = investor.prefixSums;
    uint256 length = prefixSums_.length;
    if (length == 0) {
      return (userInvested, excess);
    }
    uint256 leastUpperBound = prefixSums_.findUpperBound(invested);
    if (length == leastUpperBound) {
      userInvested = investor.userSums[length - 1];
      return (userInvested, excess);
    }
    uint256 prefixSum = prefixSums_[leastUpperBound];
    if (prefixSum == invested) {
      userInvested = investor.userSums[leastUpperBound];
      excess = investor.userSums[length - 1] - userInvested;
    } else {
      userInvested = leastUpperBound > 0
        ? investor.userSums[leastUpperBound - 1]
        : 0;
      uint256 depositAmount = investor.userSums[leastUpperBound] - userInvested;
      if (prefixSum - depositAmount < invested) {
        userInvested += (depositAmount + invested - prefixSum);
        excess = investor.userSums[length - 1] - userInvested;
      } else {
        excess = investor.userSums[length - 1] - userInvested;
      }
    }
  }

  function safeMulDiv(
    uint256 x,
    uint256 y,
    uint256 denominator
  ) internal pure returns (uint256 result) {

    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly {
      let mm := mulmod(x, y, not(0))
      prod0 := mul(x, y)
      prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }
    if (prod1 == 0) {
      unchecked {
        result = prod0 / denominator;
      }
      return result;
    }
    if (prod1 >= denominator) {
      revert("OLib__MulDivOverflow(prod1, denominator)");
    }
    uint256 remainder;
    assembly {
      remainder := mulmod(x, y, denominator)
      prod1 := sub(prod1, gt(remainder, prod0))
      prod0 := sub(prod0, remainder)
    }
    unchecked {
      uint256 lpotdod = denominator & (~denominator + 1);
      assembly {
        denominator := div(denominator, lpotdod)
        prod0 := div(prod0, lpotdod)
        lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
      }
      prod0 |= prod1 * lpotdod;
      uint256 inverse = (3 * denominator) ^ 2;
      inverse *= 2 - denominator * inverse; // inverse mod 2^8
      inverse *= 2 - denominator * inverse; // inverse mod 2^16
      inverse *= 2 - denominator * inverse; // inverse mod 2^32
      inverse *= 2 - denominator * inverse; // inverse mod 2^64
      inverse *= 2 - denominator * inverse; // inverse mod 2^128
      inverse *= 2 - denominator * inverse; // inverse mod 2^256
      result = prod0 * inverse;
      return result;
    }
  }
}

library OndoSaferERC20 {

  using SafeERC20 for IERC20;

  function ondoSafeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) + value;
    token.safeApprove(spender, 0);
    token.safeApprove(spender, newAllowance);
  }
}// AGPL-3.0
pragma solidity 0.8.3;


abstract contract OndoRegistryClientInitializable is
  Initializable,
  ReentrancyGuard,
  Pausable
{
  using SafeERC20 for IERC20;

  IRegistry public registry;
  uint256 public denominator;

  function __OndoRegistryClient__initialize(address _registry)
    internal
    initializer
  {
    require(_registry != address(0), "Invalid registry address");
    registry = IRegistry(_registry);
    denominator = registry.denominator();
  }

  modifier isAuthorized(bytes32 _role) {
    require(registry.authorized(_role, msg.sender), "Unauthorized");
    _;
  }

  function paused() public view virtual override returns (bool) {
    return registry.paused() || super.paused();
  }

  function pause() external virtual isAuthorized(OLib.PANIC_ROLE) {
    super._pause();
  }

  function unpause() external virtual isAuthorized(OLib.GUARDIAN_ROLE) {
    super._unpause();
  }

  function _rescueTokens(address[] calldata _tokens, uint256[] memory _amounts)
    internal
    virtual
  {
    for (uint256 i = 0; i < _tokens.length; i++) {
      uint256 amount = _amounts[i];
      if (amount == 0) {
        amount = IERC20(_tokens[i]).balanceOf(address(this));
      }
      IERC20(_tokens[i]).safeTransfer(msg.sender, amount);
    }
  }

  function rescueTokens(address[] calldata _tokens, uint256[] memory _amounts)
    public
    whenPaused
    isAuthorized(OLib.GUARDIAN_ROLE)
  {
    require(_tokens.length == _amounts.length, "Invalid array sizes");
    _rescueTokens(_tokens, _amounts);
  }
}// AGPL-3.0
pragma solidity 0.8.3;


abstract contract OndoRegistryClient is OndoRegistryClientInitializable {
  constructor(address _registry) {
    __OndoRegistryClient__initialize(_registry);
  }
}/**AGPL-3.0

          ▄▄█████████▄                                                                  
       ╓██▀└ ,╓▄▄▄, '▀██▄                                                               
      ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,         
     ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,     
    ██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌    
    ██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██    
    ╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀    
     ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`     
      ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬         
       ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀                                                               
          ╙▀▀██████R⌐                                                                   

 */
pragma solidity 0.8.3;

interface IMulticall {

  struct ExCallData {
    address target; // The target contract called from the current contract
    bytes data; // The encoded function data
    uint256 value; // The ether to be transfered to the target contract
  }

  function multiexcall(ExCallData[] calldata exdata)
    external
    payable
    returns (bytes[] memory results);

}/**AGPL-3.0

          ▄▄█████████▄                                                                  
       ╓██▀└ ,╓▄▄▄, '▀██▄                                                               
      ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,         
     ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,     
    ██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌    
    ██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██    
    ╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀    
     ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`     
      ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬         
       ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀                                                               
          ╙▀▀██████R⌐                                                                   

 */
pragma solidity 0.8.3;


abstract contract Multicall is IMulticall, OndoRegistryClient {
  using Address for address;

  function multiexcall(ExCallData[] calldata exCallData)
    external
    payable
    override
    isAuthorized(OLib.GUARDIAN_ROLE)
    returns (bytes[] memory results)
  {
    results = new bytes[](exCallData.length);
    for (uint256 i = 0; i < exCallData.length; i++) {
      results[i] = exCallData[i].target.functionCallWithValue(
        exCallData[i].data,
        exCallData[i].value,
        "Multicall: multiexcall failed"
      );
    }
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0
pragma solidity 0.8.3;


interface ITrancheToken is IERC20Upgradeable {

  function mint(address _account, uint256 _amount) external;


  function burn(address _account, uint256 _amount) external;

}// AGPL-3.0
pragma solidity 0.8.3;


interface IStrategy {

  struct Vault {
    IPairVault origin; // who created this Vault
    IERC20 pool; // the DEX pool
    IERC20 senior; // senior asset in pool
    IERC20 junior; // junior asset in pool
    uint256 shares; // number of shares for ETF-style mid-duration entry/exit
    uint256 seniorExcess; // unused senior deposits
    uint256 juniorExcess; // unused junior deposits
  }

  function vaults(uint256 vaultId)
    external
    view
    returns (
      IPairVault origin,
      IERC20 pool,
      IERC20 senior,
      IERC20 junior,
      uint256 shares,
      uint256 seniorExcess,
      uint256 juniorExcess
    );


  function addVault(
    uint256 _vaultId,
    IERC20 _senior,
    IERC20 _junior
  ) external;


  function addLp(uint256 _vaultId, uint256 _lpTokens) external;


  function removeLp(
    uint256 _vaultId,
    uint256 _shares,
    address to
  ) external;


  function getVaultInfo(uint256 _vaultId)
    external
    view
    returns (IERC20, uint256);


  function invest(
    uint256 _vaultId,
    uint256 _totalSenior,
    uint256 _totalJunior,
    uint256 _extraSenior,
    uint256 _extraJunior,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256 seniorInvested, uint256 juniorInvested);


  function sharesFromLp(uint256 vaultId, uint256 lpTokens)
    external
    view
    returns (
      uint256 shares,
      uint256 vaultShares,
      IERC20 pool
    );


  function lpFromShares(uint256 vaultId, uint256 shares)
    external
    view
    returns (uint256 lpTokens, uint256 vaultShares);


  function redeem(
    uint256 _vaultId,
    uint256 _seniorExpected,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256, uint256);


  function withdrawExcess(
    uint256 _vaultId,
    OLib.Tranche tranche,
    address to,
    uint256 amount
  ) external;

}// AGPL-3.0
pragma solidity 0.8.3;


interface IPairVault {

  struct VaultView {
    uint256 id;
    Asset[] assets;
    IStrategy strategy; // Shared contract that interacts with AMMs
    address creator; // Account that calls createVault
    address strategist; // Has the right to call invest() and redeem(), and harvest() if strategy supports it
    address rollover;
    uint256 hurdleRate; // Return offered to senior tranche
    OLib.State state; // Current state of Vault
    uint256 startAt; // Time when the Vault is unpaused to begin accepting deposits
    uint256 investAt; // Time when investors can't move funds, strategist can invest
    uint256 redeemAt; // Time when strategist can redeem LP tokens, investors can withdraw
  }

  struct Asset {
    IERC20 token;
    ITrancheToken trancheToken;
    uint256 trancheCap;
    uint256 userCap;
    uint256 deposited;
    uint256 originalInvested;
    uint256 totalInvested; // not literal 1:1, originalInvested + proportional lp from mid-term
    uint256 received;
    uint256 rolloverDeposited;
  }

  function getState(uint256 _vaultId) external view returns (OLib.State);


  function createVault(OLib.VaultParams calldata _params)
    external
    returns (uint256 vaultId);


  function deposit(
    uint256 _vaultId,
    OLib.Tranche _tranche,
    uint256 _amount
  ) external;


  function depositETH(uint256 _vaultId, OLib.Tranche _tranche) external payable;


  function depositLp(uint256 _vaultId, uint256 _amount)
    external
    returns (uint256 seniorTokensOwed, uint256 juniorTokensOwed);


  function invest(
    uint256 _vaultId,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256, uint256);


  function redeem(
    uint256 _vaultId,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256, uint256);


  function withdraw(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256);


  function withdrawETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256);


  function withdrawLp(uint256 _vaultId, uint256 _amount)
    external
    returns (uint256, uint256);


  function claim(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256, uint256);


  function claimETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256, uint256);


  function depositFromRollover(
    uint256 _vaultId,
    uint256 _rolloverId,
    uint256 _seniorAmount,
    uint256 _juniorAmount
  ) external;


  function rolloverClaim(uint256 _vaultId, uint256 _rolloverId)
    external
    returns (uint256, uint256);


  function setRollover(
    uint256 _vaultId,
    address _rollover,
    uint256 _rolloverId
  ) external;


  function canDeposit(uint256 _vaultId) external view returns (bool);


  function getVaultById(uint256 _vaultId)
    external
    view
    returns (VaultView memory);


  function vaultInvestor(uint256 _vaultId, OLib.Tranche _tranche)
    external
    view
    returns (
      uint256 position,
      uint256 claimableBalance,
      uint256 withdrawableExcess,
      uint256 withdrawableBalance
    );


  function seniorExpected(uint256 _vaultId) external view returns (uint256);

}// AGPL-3.0
pragma solidity 0.8.3;



interface IRollover {


  event CreatedRollover(
    uint256 indexed rolloverId,
    address indexed creator,
    address indexed strategist,
    address seniorAsset,
    address juniorAsset,
    address seniorToken,
    address juniorToken
  );

  event AddedVault(uint256 indexed rolloverId, uint256 indexed vaultId);

  event MigratedRollover(
    uint256 indexed rolloverId,
    uint256 indexed newVault,
    uint256 seniorDeposited,
    uint256 juniorDeposited
  );

  event Withdrew(
    address indexed user,
    uint256 indexed rolloverId,
    uint256 indexed trancheId,
    uint256 equivalentInvested,
    uint256 withdrawnShares,
    uint256 totalShares,
    uint256 excess
  );

  event Deposited(
    address indexed user,
    uint256 indexed rolloverId,
    uint256 indexed trancheId,
    uint256 depositAmount,
    uint256 excess,
    uint256 sharesMinted
  );

  event Claimed(
    address indexed user,
    uint256 indexed rolloverId,
    uint256 indexed trancheId,
    uint256 tokens,
    uint256 excess
  );
  event DepositedLP(
    address indexed depositor,
    uint256 indexed vaultId,
    uint256 amount,
    uint256 seniorTrancheMintedAmount,
    uint256 juniorTrancheMintedAmount
  );

  event WithdrewLP(
    address indexed depositor,
    uint256 indexed vaultId,
    uint256 amount,
    uint256 seniorTrancheBurnedAmount,
    uint256 juniorTrancheBurnedAmount
  );

  struct TrancheRoundView {
    uint256 deposited;
    uint256 invested; // Total, if any, actually invested
    uint256 redeemed; // After Vault is done, total tokens redeemed for LP
    uint256 shares;
    uint256 newDeposited;
    uint256 newInvested;
  }

  struct RoundView {
    uint256 vaultId;
    TrancheRoundView[] tranches;
  }

  struct RolloverView {
    address creator;
    address strategist;
    IERC20[] assets;
    ITrancheToken[] rolloverTokens;
    uint256 thisRound;
  }

  struct TrancheRound {
    uint256 deposited;
    uint256 invested; // Total, if any, actually invested
    uint256 redeemed; // After Vault is done, total tokens redeemed for LP
    uint256 shares;
    uint256 newDeposited;
    uint256 newInvested;
    mapping(address => OLib.Investor) investors;
  }

  struct Round {
    uint256 vaultId;
    mapping(OLib.Tranche => TrancheRound) tranches;
  }

  struct Rollover {
    address creator;
    address strategist;
    mapping(uint256 => Round) rounds;
    mapping(OLib.Tranche => IERC20) assets;
    mapping(OLib.Tranche => ITrancheToken) rolloverTokens;
    mapping(OLib.Tranche => mapping(address => uint256)) investorLastUpdates;
    uint256 thisRound;
    bool dead;
  }

  struct SlippageSettings {
    uint256 seniorMinInvest;
    uint256 seniorMinRedeem;
    uint256 juniorMinInvest;
    uint256 juniorMinRedeem;
  }


  function getRollover(uint256 rolloverId)
    external
    view
    returns (RolloverView memory);


  function getRound(uint256 _rolloverId, uint256 _roundIndex)
    external
    view
    returns (RoundView memory);


  function getNextVault(uint256 rolloverId) external view returns (uint256);


  function deposit(
    uint256 _rolloverId,
    OLib.Tranche _tranche,
    uint256 _amount
  ) external;


  function withdraw(
    uint256 _rolloverId,
    OLib.Tranche _tranche,
    uint256 shares
  ) external;

}// AGPL-3.0
pragma solidity 0.8.3;



interface ISingleAssetVault {

  event Deposit(address indexed user, uint256 amount, uint256 investFromIndex);
  event Withdraw(
    address indexed user,
    uint256 amount,
    address indexed recipient
  );
  event MassUpdateUserBalance(address indexed user);
  event Invest(
    uint256 indexed poolId,
    address indexed strategist,
    address indexed strategy,
    uint256 amount,
    bytes data
  );
  event Redeem(
    uint256 indexed poolId,
    address indexed redeemer,
    uint256 amount,
    bytes data
  );

  enum ActionType {Invest, Redeem}

  struct PoolData {
    bool isPassive;
    uint256 investAmount;
    address strategy;
    address strategist;
    uint256 depositMultiplier;
    uint256 redemptionMultiplier;
    bool redeemed;
  }
  struct Action {
    ActionType actionType;
    uint256 poolId;
  }
  struct UserDeposit {
    uint256 amount;
    uint256 firstActionId;
  }


  function asset() external view returns (IERC20);

}// AGPL-3.0
pragma solidity 0.8.3;

interface ISAStrategy {

  function invest(
    uint256 poolId,
    uint256 amount,
    bytes memory data
  ) external;


  function redeem(uint256 poolId, bytes memory data)
    external
    returns (bool pendingAdditionalWithdraw, uint256 amount);

}// AGPL-3.0
pragma solidity 0.8.3;



contract SingleAssetVault is Multicall, ISingleAssetVault {

  using SafeERC20 for IERC20;

  uint256 public constant MULTIPLIER_DENOMINATOR = 2**100;

  IERC20 public immutable override asset;

  mapping(address => bool) public isStrategy;

  uint256 public totalFundAmount;
  uint256 public totalActivePoolAmount;
  uint256 public totalPassivePoolAmount;

  PoolData[] public pools;
  Action[] public actions; // calculate token balance based on this action order

  mapping(address => UserDeposit[]) internal userDeposits;
  mapping(address => uint256) internal fromDepositIndex; // calculate token balance from this deposit index

  bool public withdrawEnabled;

  constructor(address _asset, address _registry) OndoRegistryClient(_registry) {
    require(_asset != address(0), "Invalid asset");
    asset = IERC20(_asset);
  }

  function setStrategy(address _strategy, bool _flag)
    external
    isAuthorized(OLib.GUARDIAN_ROLE)
    nonReentrant
  {

    isStrategy[_strategy] = _flag;
  }

  function setWithdrawEnabled(bool _withdrawEnabled)
    external
    isAuthorized(OLib.GUARDIAN_ROLE)
  {

    withdrawEnabled = _withdrawEnabled;
  }

  function deposit(uint256 _amount) external nonReentrant {

    require(_amount > 0, "zero amount");
    asset.safeTransferFrom(msg.sender, address(this), _amount);

    totalFundAmount += _amount;
    userDeposits[msg.sender].push(
      UserDeposit({amount: _amount, firstActionId: actions.length})
    );

    emit Deposit(msg.sender, _amount, pools.length);
  }

  function withdraw(uint256 _amount, address _to)
    external
    whenNotPaused
    nonReentrant
  {

    require(_amount > 0, "zero amount");
    require(withdrawEnabled, "withdraw disabled");
    (
      uint256 activeInvestAmount,
      uint256 passiveInvestAmount,
      uint256 remainAmount
    ) = tokenBalances(msg.sender);
    require(activeInvestAmount + passiveInvestAmount == 0, "invested!");
    require(remainAmount >= _amount, "insufficient balance");

    fromDepositIndex[msg.sender] = userDeposits[msg.sender].length;
    if (remainAmount > _amount) {
      userDeposits[msg.sender].push(
        UserDeposit({
          amount: remainAmount - _amount,
          firstActionId: actions.length
        })
      );
    }

    totalFundAmount -= _amount;
    asset.safeTransfer(_to, _amount);

    emit Withdraw(msg.sender, _amount, _to);
  }

  function massUpdateUserBalance(address _user) external {

    (
      uint256 activeInvestAmount,
      uint256 passiveInvestAmount,
      uint256 remainAmount
    ) = tokenBalances(msg.sender);
    require(activeInvestAmount + passiveInvestAmount == 0, "invested!");

    fromDepositIndex[msg.sender] = userDeposits[msg.sender].length;
    if (remainAmount > 0) {
      userDeposits[msg.sender].push(
        UserDeposit({amount: remainAmount, firstActionId: actions.length})
      );
    }

    emit MassUpdateUserBalance(_user);
  }

  function invest(
    address _strategy,
    uint256 _amount,
    bool _isPassive,
    bytes memory _data
  ) external whenNotPaused isAuthorized(OLib.STRATEGIST_ROLE) nonReentrant {

    require(isStrategy[_strategy], "invalid strategy");

    if (_isPassive) {
      pools.push(
        PoolData({
          isPassive: true,
          investAmount: _amount,
          strategy: _strategy,
          strategist: msg.sender,
          depositMultiplier: 0,
          redemptionMultiplier: 0,
          redeemed: false
        })
      );
      totalPassivePoolAmount += _amount;
    } else {
      pools.push(
        PoolData({
          isPassive: false,
          investAmount: _amount,
          strategy: _strategy,
          strategist: msg.sender,
          depositMultiplier: OLib.safeMulDiv(
            _amount,
            MULTIPLIER_DENOMINATOR,
            (totalFundAmount + totalPassivePoolAmount)
          ),
          redemptionMultiplier: MULTIPLIER_DENOMINATOR,
          redeemed: false
        })
      );
      actions.push(
        Action({actionType: ActionType.Invest, poolId: pools.length - 1})
      );
      totalActivePoolAmount += _amount;
    }

    totalFundAmount -= _amount;

    uint256 poolId = pools.length - 1;
    asset.safeApprove(_strategy, _amount);
    ISAStrategy(_strategy).invest(poolId, _amount, _data);

    emit Invest(poolId, msg.sender, _strategy, _amount, _data);
  }

  function redeem(uint256 _poolId, bytes memory _data)
    external
    whenNotPaused
    nonReentrant
  {

    PoolData storage pool = pools[_poolId];
    require(
      msg.sender == pool.strategist ||
        registry.authorized(OLib.GUARDIAN_ROLE, msg.sender),
      "Unauthorized"
    );
    require(!pool.redeemed, "Already redeemed");

    (bool pendingAdditionalWithdraw, uint256 redeemAmount) =
      ISAStrategy(pool.strategy).redeem(_poolId, _data);

    if (pendingAdditionalWithdraw) {
      return;
    }

    pool.redeemed = true;
    pool.redemptionMultiplier = OLib.safeMulDiv(
      redeemAmount,
      MULTIPLIER_DENOMINATOR,
      pool.investAmount
    );

    if (pool.isPassive) {
      pool.depositMultiplier = OLib.safeMulDiv(
        pool.investAmount,
        MULTIPLIER_DENOMINATOR,
        (totalFundAmount + totalPassivePoolAmount)
      );

      actions.push(Action({actionType: ActionType.Invest, poolId: _poolId}));
      totalPassivePoolAmount -= pool.investAmount;
    } else {
      totalActivePoolAmount -= pool.investAmount;
    }

    actions.push(Action({actionType: ActionType.Redeem, poolId: _poolId}));
    totalFundAmount += redeemAmount;

    emit Redeem(_poolId, msg.sender, redeemAmount, _data);
  }

  function tokenBalance(address _user) external view returns (uint256 amount) {

    (
      uint256 activeInvestAmount,
      uint256 passiveInvestAmount,
      uint256 remainAmount
    ) = tokenBalances(_user);

    return activeInvestAmount + passiveInvestAmount + remainAmount;
  }

  function tokenBalances(address _user)
    public
    view
    returns (
      uint256 activeInvestAmount,
      uint256 passiveInvestAmount,
      uint256 remainAmount
    )
  {

    uint256 depositLength = userDeposits[_user].length;
    uint256 depositIndex = fromDepositIndex[_user];
    if (depositLength == depositIndex) {
      return (0, 0, 0);
    }

    UserDeposit[] storage deposits = userDeposits[_user];

    uint256 currentActionId = deposits[depositIndex].firstActionId;
    uint256[] memory userPoolDeposits = new uint256[](pools.length); // this is to reduce the memory size
    while (depositIndex < depositLength || currentActionId < actions.length) {
      if (
        depositIndex < depositLength &&
        currentActionId == deposits[depositIndex].firstActionId
      ) {
        remainAmount += deposits[depositIndex].amount;
        depositIndex++;
        continue;
      }

      Action memory action = actions[currentActionId];
      PoolData memory pool = pools[action.poolId];
      if (action.actionType == ActionType.Invest) {
        userPoolDeposits[action.poolId] = OLib.safeMulDiv(
          remainAmount,
          pool.depositMultiplier,
          MULTIPLIER_DENOMINATOR
        );
        remainAmount -= userPoolDeposits[action.poolId];
        activeInvestAmount += userPoolDeposits[action.poolId];
      } else if (userPoolDeposits[action.poolId] > 0) {
        uint256 redeemAmount =
          OLib.safeMulDiv(
            userPoolDeposits[action.poolId],
            pool.redemptionMultiplier,
            MULTIPLIER_DENOMINATOR
          );
        remainAmount += redeemAmount;
        activeInvestAmount -= userPoolDeposits[action.poolId];
      }
      currentActionId++;
    }

    if (totalPassivePoolAmount != 0) {
      passiveInvestAmount = OLib.safeMulDiv(
        remainAmount,
        totalPassivePoolAmount,
        (totalFundAmount + totalPassivePoolAmount)
      );
      remainAmount -= passiveInvestAmount;
    }
  }
}