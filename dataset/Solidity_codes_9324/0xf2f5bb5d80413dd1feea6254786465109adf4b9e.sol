
pragma solidity ^0.6.10;

interface IEndaomentAdmin {

  event RoleModified(Role indexed role, address account);
  event RolePaused(Role indexed role);
  event RoleUnpaused(Role indexed role);

  enum Role {
    EMPTY,
    PAUSER,
    ACCOUNTANT,
    REVIEWER,
    FUND_FACTORY,
    ORG_FACTORY,
    ADMIN
  }

  struct RoleStatus {
    address account;
    bool paused;
  }

  function setRole(Role role, address account) external;


  function removeRole(Role role) external;


  function pause(Role role) external;


  function unpause(Role role) external;


  function isPaused(Role role) external view returns (bool);


  function isRole(Role role) external view returns (bool);


  function getRoleAddress(Role role) external view returns (address);

}// BSD 3-Clause

pragma solidity ^0.6.10;


contract TwoStepOwnable {

  address private _owner;
  address private _newPotentialOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  event TransferInitiated(address indexed newOwner);

  event TransferCancelled(address indexed newPotentialOwner);

  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  function getOwner() external view returns (address) {

    return _owner;
  }

  function getNewPotentialOwner() external view returns (address) {

    return _newPotentialOwner;
  }

  modifier onlyOwner() {

    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  function isOwner() public view returns (bool) {

    return msg.sender == _owner;
  }

  function transferOwnership(address newPotentialOwner) public onlyOwner {

    require(
      newPotentialOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newPotentialOwner;
    emit TransferInitiated(address(newPotentialOwner));
  }

  function cancelOwnershipTransfer() public onlyOwner {

    emit TransferCancelled(address(_newPotentialOwner));
    delete _newPotentialOwner;
  }

  function acceptOwnership() public {

    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}

contract EndaomentAdmin is IEndaomentAdmin, TwoStepOwnable {

  mapping(uint256 => RoleStatus) private _roles;

  function setRole(Role role, address account) public override onlyOwner {

    require(account != address(0), "EndaomentAdmin: Must supply an account.");
    _setRole(role, account);
  }

  function removeRole(Role role) public override onlyOwner {

    _setRole(role, address(0));
  }

  function pause(Role role) public override onlyAdminOr(Role.PAUSER) {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(!storedRoleStatus.paused, "EndaomentAdmin: Role in question is already paused.");
    storedRoleStatus.paused = true;
    emit RolePaused(role);
  }

  function unpause(Role role) public override onlyOwner {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(storedRoleStatus.paused, "EndaomentAdmin: Role in question is already unpaused.");
    storedRoleStatus.paused = false;
    emit RoleUnpaused(role);
  }

  function isPaused(Role role) external override view returns (bool) {

    return _isPaused(role);
  }

  function isRole(Role role) external override view returns (bool) {

    return _isRole(role);
  }

  function getRoleAddress(Role role) external override view returns (address) {

    require(
      _roles[uint256(role)].account != address(0),
      "EndaomentAdmin: Role bearer is null address."
    );
    return _roles[uint256(role)].account;
  }

  function _setRole(Role role, address account) private {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];

    if (account != storedRoleStatus.account) {
      storedRoleStatus.account = account;
      emit RoleModified(role, account);
    }
  }

  function _isRole(Role role) private view returns (bool) {

    return msg.sender == _roles[uint256(role)].account;
  }

  function _isPaused(Role role) private view returns (bool) {

    return _roles[uint256(role)].paused;
  }

  modifier onlyAdminOr(Role role) {

    if (!isOwner()) {
      require(_isRole(role), "EndaomentAdmin: Caller does not have a required role.");
      require(!_isPaused(role), "EndaomentAdmin: Role in question is currently paused.");
    }
    _;
  }
}// BSD 3-Clause

pragma solidity ^0.6.10;


contract Administratable {

  modifier onlyAdmin(address adminContractAddress) {

    require(
      adminContractAddress != address(0),
      "Administratable: Admin must not be the zero address"
    );
    EndaomentAdmin endaomentAdmin = EndaomentAdmin(adminContractAddress);

    require(
      msg.sender == endaomentAdmin.getRoleAddress(IEndaomentAdmin.Role.ADMIN),
      "Administratable: only ADMIN can access."
    );
    _;
  }

  modifier onlyAdminOrRole(address adminContractAddress, IEndaomentAdmin.Role role) {

    _onlyAdminOrRole(adminContractAddress, role);
    _;
  }

  function _onlyAdminOrRole(address adminContractAddress, IEndaomentAdmin.Role role) private view {

    require(
      adminContractAddress != address(0),
      "Administratable: Admin must not be the zero address"
    );
    EndaomentAdmin endaomentAdmin = EndaomentAdmin(adminContractAddress);
    bool isAdmin = (msg.sender == endaomentAdmin.getRoleAddress(IEndaomentAdmin.Role.ADMIN));

    if (!isAdmin) {
      if (endaomentAdmin.isPaused(role)) {
        revert("Administratable: requested role is paused");
      }

      if (role == IEndaomentAdmin.Role.ACCOUNTANT) {
        require(
          msg.sender == endaomentAdmin.getRoleAddress(IEndaomentAdmin.Role.ACCOUNTANT),
          "Administratable: only ACCOUNTANT can access"
        );
      }
      if (role == IEndaomentAdmin.Role.REVIEWER) {
        require(
          msg.sender == endaomentAdmin.getRoleAddress(IEndaomentAdmin.Role.REVIEWER),
          "Administratable: only REVIEWER can access"
        );
      }
      if (role == IEndaomentAdmin.Role.FUND_FACTORY) {
        require(
          msg.sender == endaomentAdmin.getRoleAddress(IEndaomentAdmin.Role.FUND_FACTORY),
          "Administratable: only FUND_FACTORY can access"
        );
      }
      if (role == IEndaomentAdmin.Role.ORG_FACTORY) {
        require(
          msg.sender == endaomentAdmin.getRoleAddress(IEndaomentAdmin.Role.ORG_FACTORY),
          "Administratable: only ORG_FACTORY can access"
        );
      }
    }
  }

  modifier onlyAddressOrAdminOrRole(
    address allowedAddress,
    address adminContractAddress,
    IEndaomentAdmin.Role role
  ) {

    require(
      allowedAddress != address(0),
      "Administratable: Allowed address must not be the zero address"
    );

    bool isAllowed = (msg.sender == allowedAddress);

    if (!isAllowed) {
      _onlyAdminOrRole(adminContractAddress, role);
    }
    _;
  }

  function isEqual(string memory s1, string memory s2) internal pure returns (bool) {

    return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
  }
}// BSD 3-Clause

pragma solidity ^0.6.10;


contract EndaomentAdminStorage is Administratable {

  address public endaomentAdmin;
  event EndaomentAdminChanged(address indexed oldAddress, address indexed newAddress);

  function updateEndaomentAdmin(address newAdmin) public onlyAdmin(endaomentAdmin) {

    require(newAdmin != address(0), "EndaomentAdminStorage: New admin cannot be the zero address");
    EndaomentAdmin endaomentAdminContract = EndaomentAdmin(newAdmin);

    address admin = endaomentAdminContract.getRoleAddress(IEndaomentAdmin.Role.ADMIN);
    require(admin != address(0), "EndaomentAdminStorage: Admin cannot be the zero address");

    emit EndaomentAdminChanged(endaomentAdmin, newAdmin);
    endaomentAdmin = newAdmin;
  }
}// BSD 3-Clause

pragma solidity ^0.6.10;

interface IFactory {

  function endaomentAdmin() external view returns (address);

}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}// MIT

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}// BSD 3-Clause

pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;


contract Org is Initializable, Administratable {

  using SafeERC20 for IERC20;


  struct Claim {
    string firstName;
    string lastName;
    string eMail;
    address desiredWallet;
  }
  event CashOutComplete(uint256 cashOutAmount);
  event ClaimCreated(string claimId, Claim claim);
  event ClaimApproved(string claimId, Claim claim);
  event ClaimRejected(string claimId, Claim claim);


  IFactory public orgFactoryContract;
  uint256 public taxId;
  mapping(string => Claim) public pendingClaims; // claim UUID to Claim
  Claim public activeClaim;


  function initializeOrg(uint256 ein, address orgFactory) public initializer {

    require(orgFactory != address(0), "Org: Factory cannot be null address.");
    taxId = ein;
    orgFactoryContract = IFactory(orgFactory);
  }


  function claimRequest(
    string calldata claimId,
    string calldata fName,
    string calldata lName,
    string calldata eMail,
    address orgAdminWalletAddress
  ) public {

    require(!isEqual(claimId, ""), "Org: Must provide claimId");
    require(!isEqual(fName, ""), "Org: Must provide the first name of the administrator");
    require(!isEqual(lName, ""), "Org: Must provide the last name of the administrator");
    require(!isEqual(eMail, ""), "Org: Must provide the email address of the administrator");
    require(orgAdminWalletAddress != address(0), "Org: Wallet address cannot be the zero address");
    require(
      pendingClaims[claimId].desiredWallet == address(0),
      "Org: Pending Claim with Id already exists"
    );

    Claim memory newClaim = Claim({
      firstName: fName,
      lastName: lName,
      eMail: eMail,
      desiredWallet: orgAdminWalletAddress
    });

    emit ClaimCreated(claimId, newClaim);
    pendingClaims[claimId] = newClaim;
  }

  function approveClaim(string calldata claimId)
    public
    onlyAdminOrRole(orgFactoryContract.endaomentAdmin(), IEndaomentAdmin.Role.REVIEWER)
  {

    require(!isEqual(claimId, ""), "Fund: Must provide a claimId");
    Claim storage claim = pendingClaims[claimId];
    require(claim.desiredWallet != address(0), "Org: claim does not exist");
    emit ClaimApproved(claimId, claim);
    activeClaim = claim;
    delete pendingClaims[claimId];
  }

  function rejectClaim(string calldata claimId)
    public
    onlyAdminOrRole(orgFactoryContract.endaomentAdmin(), IEndaomentAdmin.Role.REVIEWER)
  {

    require(!isEqual(claimId, ""), "Fund: Must provide a claimId");
    Claim storage claim = pendingClaims[claimId];
    require(claim.desiredWallet != address(0), "Org: claim does not exist");

    emit ClaimRejected(claimId, claim);

    delete pendingClaims[claimId];
  }

  function cashOutOrg(address tokenAddress)
    public
    onlyAdminOrRole(orgFactoryContract.endaomentAdmin(), IEndaomentAdmin.Role.ACCOUNTANT)
  {

    require(tokenAddress != address(0), "Org: Token address cannot be the zero address");
    address payoutAddr = orgWallet();
    require(payoutAddr != address(0), "Org: Cannot cashout unclaimed Org");

    IERC20 tokenContract = IERC20(tokenAddress);
    uint256 cashOutAmount = tokenContract.balanceOf(address(this));

    tokenContract.safeTransfer(orgWallet(), cashOutAmount);
    emit CashOutComplete(cashOutAmount);
  }

  function getTokenBalance(address tokenAddress) external view returns (uint256) {

    IERC20 tokenContract = IERC20(tokenAddress);
    uint256 balance = tokenContract.balanceOf(address(this));

    return balance;
  }

  function orgWallet() public view returns (address) {

    return activeClaim.desiredWallet;
  }
}// MIT
pragma solidity ^0.6.7;

contract ProxyFactory {

  function deployMinimal(address _logic, bytes memory _data) public returns (address proxy) {

    bytes20 targetBytes = bytes20(_logic);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      proxy := create(0, clone, 0x37)
    }

    if (_data.length > 0) {
      (bool success, ) = proxy.call(_data);
      require(success, "ProxyFactory: Initialization of proxy failed");
    }
  }
}// BSD 3-Clause

pragma solidity ^0.6.10;


contract OrgFactory is ProxyFactory, EndaomentAdminStorage {


  event OrgCreated(address indexed newAddress);
  event OrgStatusChanged(address indexed orgAddress, bool indexed isAllowed);
  event OrgLogicDeployed(address logicAddress);


  mapping(address => bool) public allowedOrgs;
  address public immutable orgLogic; // logic template for all Org contracts

  constructor(address adminContractAddress) public {
    require(adminContractAddress != address(0), "OrgFactory: Admin cannot be the zero address");
    endaomentAdmin = adminContractAddress;
    emit EndaomentAdminChanged(address(0), adminContractAddress);

    Org orgLogicContract = new Org();
    orgLogicContract.initializeOrg(999999999, address(this));

    orgLogic = address(orgLogicContract);
    emit OrgLogicDeployed(address(orgLogicContract));
  }

  function createOrg(uint256 ein)
    public
    onlyAdminOrRole(endaomentAdmin, IEndaomentAdmin.Role.ACCOUNTANT)
  {

    require(ein >= 10000000 && ein <= 999999999, "Org: Must provide a valid EIN");
    bytes memory payload = abi.encodeWithSignature(
      "initializeOrg(uint256,address)",
      ein,
      address(this)
    );
    address newOrg = deployMinimal(orgLogic, payload);

    allowedOrgs[newOrg] = true;
    emit OrgCreated(newOrg);
  }

  function toggleOrg(address orgAddress)
    public
    onlyAdminOrRole(endaomentAdmin, IEndaomentAdmin.Role.REVIEWER)
  {

    require(Org(orgAddress).taxId() != 0, "OrgFactory: Not a valid org.");
    allowedOrgs[orgAddress] = !allowedOrgs[orgAddress];
    emit OrgStatusChanged(orgAddress, allowedOrgs[orgAddress]);
  }
}