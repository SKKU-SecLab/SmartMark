
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity =0.8.9;

interface IAccessControlPolicy {

  function hasAccess(address _user, address _vault) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT
pragma solidity =0.8.9;


interface IGovernable {

  function proposeGovernance(address _pendingGovernance) external;


  function acceptGovernance() external;

}

abstract contract GovernableInternal {
  event GovenanceUpdated(address _govenance);
  event GovenanceProposed(address _pendingGovenance);

  address public governance;
  address public pendingGovernance;

  modifier onlyGovernance() {
    require(_getMsgSender() == governance, "governance only");
    _;
  }

  modifier onlyPendingGovernance() {
    require(_getMsgSender() == pendingGovernance, "pending governance only");
    _;
  }

  function __Governable_init_unchained(address _governance) internal {
    require(_getMsgSender() != _governance, "invalid address");
    _updateGovernance(_governance);
  }

  function proposeGovernance(address _pendingGovernance) external onlyGovernance {
    require(_pendingGovernance != address(0), "invalid address");
    require(_pendingGovernance != governance, "already the governance");
    pendingGovernance = _pendingGovernance;
    emit GovenanceProposed(_pendingGovernance);
  }

  function acceptGovernance() external onlyPendingGovernance {
    _updateGovernance(pendingGovernance);
  }

  function _updateGovernance(address _pendingGovernance) internal {
    governance = _pendingGovernance;
    emit GovenanceUpdated(governance);
  }

  function _onlyGovernance() internal view {
    require(_getMsgSender() == governance, "governance only");
  }

  function _getMsgSender() internal view virtual returns (address);
}

contract Governable is Context, GovernableInternal {

  constructor(address _governance) GovernableInternal() {
    __Governable_init_unchained(_governance);
  }

  function _getMsgSender() internal view override returns (address) {

    return _msgSender();
  }
}

abstract contract GovernableUpgradeable is ContextUpgradeable, GovernableInternal {
  constructor() {}

  function __Governable_init(address _governance) internal {
    __Context_init();
    __Governable_init_unchained(_governance);
  }

  function _getMsgSender() internal view override returns (address) {
    return _msgSender();
  }
}// MIT
pragma solidity =0.8.9;

interface IGatekeeperable {

  function gatekeeper() external view returns (address);

}// MIT
pragma solidity =0.8.9;


contract PerVaultGatekeeper is Governable {

  constructor(address _governance) Governable(_governance) {}

  function _onlyGovernanceOrGatekeeper(address _pool) internal view {

    require(_pool != address(0), "!address");
    address gatekeeper = IGatekeeperable(_pool).gatekeeper();
    require(_msgSender() == governance || (gatekeeper != address(0) && _msgSender() == gatekeeper), "not authorised");
  }
}// MIT
pragma solidity =0.8.9;


contract AllowlistAccessControl is IAccessControlPolicy, PerVaultGatekeeper {

  mapping(address => bool) public globalAccessMap;
  mapping(address => mapping(address => bool)) public vaultAccessMap;

  event GlobalAccessGranted(address indexed _user);
  event GlobalAccessRemoved(address indexed _user);
  event VaultAccessGranted(address indexed _user, address indexed _vault);
  event VaultAccessRemoved(address indexed _user, address indexed _vault);

  constructor(address _governance) PerVaultGatekeeper(_governance) {}

  function allowGlobalAccess(address[] calldata _users) external onlyGovernance {

    _updateGlobalAccess(_users, true);
  }

  function removeGlobalAccess(address[] calldata _users) external onlyGovernance {

    _updateGlobalAccess(_users, false);
  }

  function allowVaultAccess(address[] calldata _users, address _vault) external {

    _onlyGovernanceOrGatekeeper(_vault);
    _updateAllowVaultAccess(_users, _vault, true);
  }

  function removeVaultAccess(address[] calldata _users, address _vault) external {

    _onlyGovernanceOrGatekeeper(_vault);
    _updateAllowVaultAccess(_users, _vault, false);
  }

  function _hasAccess(address _user, address _vault) internal view returns (bool) {

    require(_user != address(0), "invalid user address");
    require(_vault != address(0), "invalid vault address");
    return globalAccessMap[_user] || vaultAccessMap[_user][_vault];
  }

  function hasAccess(address _user, address _vault) external view returns (bool) {

    return _hasAccess(_user, _vault);
  }

  function _updateGlobalAccess(address[] calldata _users, bool _permission) internal {

    for (uint256 i = 0; i < _users.length; i++) {
      require(_users[i] != address(0), "invalid address");
      if (globalAccessMap[_users[i]] != _permission) {
        globalAccessMap[_users[i]] = _permission;
        if (_permission) {
          emit GlobalAccessGranted(_users[i]);
        } else {
          emit GlobalAccessRemoved(_users[i]);
        }
      }
    }
  }

  function _updateAllowVaultAccess(
    address[] calldata _users,
    address _vault,
    bool _permission
  ) internal {

    for (uint256 i = 0; i < _users.length; i++) {
      require(_users[i] != address(0), "invalid user address");
      if (vaultAccessMap[_users[i]][_vault] != _permission) {
        vaultAccessMap[_users[i]][_vault] = _permission;
        if (_permission) {
          emit VaultAccessGranted(_users[i], _vault);
        } else {
          emit VaultAccessRemoved(_users[i], _vault);
        }
      }
    }
  }
}