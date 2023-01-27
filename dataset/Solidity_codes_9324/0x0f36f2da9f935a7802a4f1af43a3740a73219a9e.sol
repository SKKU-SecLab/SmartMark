
pragma solidity 0.6.12; // optimization runs: 200, evm version: istanbul
pragma experimental ABIEncoderV2;


interface DharmaTradeBotV1Interface {

  event LimitOrderProcessed(
    address indexed account,
    address indexed suppliedAsset, // Ether = address(0)
    address indexed receivedAsset, // Ether = address(0)
    uint256 suppliedAmount,
    uint256 receivedAmount,
    bytes32 orderID
  );

  event LimitOrderCancelled(bytes32 orderID);
  event RoleModified(Role indexed role, address account);
  event RolePaused(Role indexed role);
  event RoleUnpaused(Role indexed role);

  enum Role {
    BOT_COMMANDER,
    CANCELLER,
    PAUSER
  }

  struct RoleStatus {
    address account;
    bool paused;
  }

  struct LimitOrderArguments {
    address account;
    address assetToSupply;        // Ether = address(0)
    address assetToReceive;       // Ether = address(0)
    uint256 maximumAmountToSupply;
    uint256 maximumPriceToAccept; // represented as a mantissa (n * 10^18)
    uint256 expiration;
    bytes32 salt;
  }

  struct LimitOrderExecutionArguments {
    uint256 amountToSupply; // will be lower than maximum for partial fills
    bytes signatures;
    address tradeTarget;
    bytes tradeData;
  }

  function processLimitOrder(
    LimitOrderArguments calldata args,
    LimitOrderExecutionArguments calldata executionArgs
  ) external returns (uint256 amountReceived);


  function cancelLimitOrder(LimitOrderArguments calldata args) external;


  function setRole(Role role, address account) external;


  function removeRole(Role role) external;


  function pause(Role role) external;


  function unpause(Role role) external;


  function isPaused(Role role) external view returns (bool paused);


  function isRole(Role role) external view returns (bool hasRole);

  
  function getOrderID(
    LimitOrderArguments calldata args
  ) external view returns (bytes32 orderID, bool valid);


  function getBotCommander() external view returns (address botCommander);

  
  function getCanceller() external view returns (address canceller);


  function getPauser() external view returns (address pauser);

}


interface SupportingContractInterface {

  function setApproval(address token, uint256 amount) external;

}


interface ERC1271Interface {

  function isValidSignature(
    bytes calldata data, bytes calldata signatures
  ) external view returns (bytes4 magicValue);

}


interface ERC20Interface {

  function transfer(address, uint256) external returns (bool);

  function transferFrom(address, address, uint256) external returns (bool);

  function approve(address, uint256) external returns (bool);

  function balanceOf(address) external view returns (uint256);

  function allowance(address, address) external view returns (uint256);

}



library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");

    return a - b;
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

    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }
}


contract TwoStepOwnable {

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  address private _owner;

  address private _newPotentialOwner;

  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  function transferOwnership(address newOwner) external onlyOwner {

    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  function cancelOwnershipTransfer() external onlyOwner {

    delete _newPotentialOwner;
  }

  function acceptOwnership() external {

    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }

  function owner() external view returns (address) {

    return _owner;
  }

  function isOwner() public view returns (bool) {

    return msg.sender == _owner;
  }

  modifier onlyOwner() {

    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }
}


contract DharmaTradeBotV1Staging is DharmaTradeBotV1Interface, TwoStepOwnable {

  using SafeMath for uint256;

  mapping(uint256 => RoleStatus) private _roles;

  mapping (bytes32 => bool) private _invalidMetaTxHashes;

  ERC20Interface private constant _ETHERIZER = ERC20Interface(
    0x723B51b72Ae89A3d0c2a2760f0458307a1Baa191
  );
  
  bool public constant staging = true;

  receive() external payable {}

  function processLimitOrder(
    LimitOrderArguments calldata args,
    LimitOrderExecutionArguments calldata executionArgs
  ) external override onlyOwnerOr(Role.BOT_COMMANDER) returns (
    uint256 amountReceived
  ) {

    _enforceExpiration(args.expiration);

    require(
      executionArgs.amountToSupply <= args.maximumAmountToSupply,
      "Cannot supply more than the maximum authorized amount."
    );
    
    require(
      args.assetToSupply != args.assetToReceive,
      "Asset to supply and asset to receive cannot be identical."
    );

    if (executionArgs.tradeData.length >= 4) {
      require(
        abi.decode(
          abi.encodePacked(executionArgs.tradeData[:4], bytes28(0)), (bytes4)
        ) != SupportingContractInterface.setApproval.selector,
        "Trade data has a prohibited function selector."
      );
    }

    bytes memory context = _constructLimitOrderContext(args);
    bytes32 orderID = _validateMetaTransaction(
      args.account, context, executionArgs.signatures
    );

    ERC20Interface assetToSupply;
    uint256 etherValue;
    
    if (args.assetToSupply == address(0)) {
      assetToSupply = _ETHERIZER;
      etherValue = executionArgs.amountToSupply;
    } else {
      assetToSupply = ERC20Interface(args.assetToSupply);
      etherValue = 0;

      _grantApprovalIfNecessary(
        assetToSupply, executionArgs.tradeTarget, executionArgs.amountToSupply
      );
    }

    SupportingContractInterface(args.account).setApproval(
      address(assetToSupply), executionArgs.amountToSupply
    );

    _transferInToken(
      assetToSupply, args.account, executionArgs.amountToSupply
    );

    _performCallToTradeTarget(
      executionArgs.tradeTarget, executionArgs.tradeData, etherValue
    );

    uint256 amountExpected = (
      executionArgs.amountToSupply.mul(1e18)
    ).div(
      args.maximumPriceToAccept
    );
 
    if (args.assetToReceive == address(0)) {
      amountReceived = address(this).balance;  
      
      require(
        amountReceived >= amountExpected,
        "Trade did not result in the expected amount of Ether."
      );
      
      _transferEther(args.account, amountReceived);
    } else {
      ERC20Interface assetToReceive = ERC20Interface(args.assetToReceive);

      amountReceived = assetToReceive.balanceOf(address(this));
      
      require(
        amountReceived >= amountExpected,
        "Trade did not result in the expected amount of tokens."
      );

      _transferOutToken(assetToReceive, args.account, amountReceived);
    }

    emit LimitOrderProcessed(
      args.account,
      args.assetToSupply,
      args.assetToReceive,
      executionArgs.amountToSupply,
      amountReceived,
      orderID
    );
  }

  function cancelLimitOrder(
    LimitOrderArguments calldata args
  ) external override onlyOwnerOrAccountOr(Role.CANCELLER, args.account) {

    _enforceExpiration(args.expiration);

    bytes32 orderID = keccak256(_constructLimitOrderContext(args));

    require(
      !_invalidMetaTxHashes[orderID], "Meta-transaction already invalid."
    );
    _invalidMetaTxHashes[orderID] = true;
    
    emit LimitOrderCancelled(orderID);
  }

  function pause(Role role) external override onlyOwnerOr(Role.PAUSER) {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(!storedRoleStatus.paused, "Role in question is already paused.");
    storedRoleStatus.paused = true;
    emit RolePaused(role);
  }

  function unpause(Role role) external override onlyOwner {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(storedRoleStatus.paused, "Role in question is already unpaused.");
    storedRoleStatus.paused = false;
    emit RoleUnpaused(role);
  }

  function setRole(Role role, address account) external override onlyOwner {

    require(account != address(0), "Must supply an account.");
    _setRole(role, account);
  }

  function removeRole(Role role) external override onlyOwner {

    _setRole(role, address(0));
  }

  function getOrderID(
    LimitOrderArguments calldata args
  ) external view override returns (bytes32 orderID, bool valid) {

    orderID = keccak256(_constructLimitOrderContext(args));

    valid = (
      !_invalidMetaTxHashes[orderID] && (
        args.expiration == 0 || block.timestamp <= args.expiration
      )
    );
  }

  function isPaused(Role role) external view override returns (bool paused) {

    paused = _isPaused(role);
  }

  function isRole(Role role) external view override returns (bool hasRole) {

    hasRole = _isRole(role);
  }

  function getBotCommander() external view override returns (
    address botCommander
  ) {

    botCommander = _roles[uint256(Role.BOT_COMMANDER)].account;
  }

  function getCanceller() external view override returns (
    address canceller
  ) {

    canceller = _roles[uint256(Role.CANCELLER)].account;
  }

  function getPauser() external view override returns (address pauser) {

    pauser = _roles[uint256(Role.PAUSER)].account;
  }

  function _validateMetaTransaction(
    address account, bytes memory context, bytes memory signatures
  ) private returns (bytes32 orderID) {

    orderID = keccak256(context);

    require(
      !_invalidMetaTxHashes[orderID], "Order is no longer valid."
    );
    _invalidMetaTxHashes[orderID] = true;

    bytes32 digest = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", orderID)
    );

    bytes memory data = abi.encode(digest, context);
    bytes4 magic = ERC1271Interface(account).isValidSignature(data, signatures);
    require(magic == bytes4(0x20c13b0b), "Invalid signatures.");
  }

  function _setRole(Role role, address account) private {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];

    if (account != storedRoleStatus.account) {
      storedRoleStatus.account = account;
      emit RoleModified(role, account);
    }
  }

  function _performCallToTradeTarget(
    address target, bytes memory data, uint256 etherValue
  ) private {

    (bool tradeTargetCallSuccess,) = target.call{value: etherValue}(data);

    if (!tradeTargetCallSuccess) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    } else {
      uint256 returnSize;
      assembly { returnSize := returndatasize() }
      if (returnSize == 0) {
        uint256 size;
        assembly { size := extcodesize(target) }
        require(size > 0, "Specified target does not have contract code.");
      }
    }
  }

  function _grantApprovalIfNecessary(
    ERC20Interface token, address target, uint256 amount
  ) private {

    if (token.allowance(address(this), target) < amount) {
      (bool success, bytes memory returnData) = address(token).call(
        abi.encodeWithSelector(
          token.approve.selector, target, uint256(0)
        )
      );

      (success, returnData) = address(token).call(
        abi.encodeWithSelector(
          token.approve.selector, target, type(uint256).max
        )
      );

      if (!success) {
        (success, returnData) = address(token).call(
          abi.encodeWithSelector(
            token.approve.selector, target, amount
          )
        );
      }

      require(
        success && (returnData.length == 0 || abi.decode(returnData, (bool))),
        "Token approval to trade against the target failed."
      );
    }
  }

  function _transferOutToken(ERC20Interface token, address to, uint256 amount) private {

    (bool success, bytes memory returnData) = address(token).call(
      abi.encodeWithSelector(token.transfer.selector, to, amount)
    );

    if (!success) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
    
    if (returnData.length == 0) {
      uint256 size;
      assembly { size := extcodesize(token) }
      require(size > 0, "Token specified to transfer out does not have contract code.");
    } else {
      require(abi.decode(returnData, (bool)), 'Token transfer out failed.');
    }
  }

  function _transferEther(address recipient, uint256 etherAmount) private {

    (bool ok, ) = recipient.call{value: etherAmount}("");
    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }

  function _transferInToken(ERC20Interface token, address from, uint256 amount) private {

    (bool success, bytes memory returnData) = address(token).call(
      abi.encodeWithSelector(token.transferFrom.selector, from, address(this), amount)
    );

    if (!success) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
    
    if (returnData.length == 0) {
      uint256 size;
      assembly { size := extcodesize(token) }
      require(size > 0, "Token specified to transfer in does not have contract code.");
    } else {
      require(abi.decode(returnData, (bool)), 'Token transfer in failed.');
    }
  }

  function _isRole(Role role) private view returns (bool hasRole) {

    hasRole = msg.sender == _roles[uint256(role)].account;
  }

  function _isPaused(Role role) private view returns (bool paused) {

    paused = _roles[uint256(role)].paused;
  }

  function _constructLimitOrderContext(
    LimitOrderArguments memory args
  ) private view returns (bytes memory context) {

    context = abi.encode(
      address(this),
      args.account,
      args.assetToSupply,
      args.assetToReceive,
      args.maximumAmountToSupply,
      args.maximumPriceToAccept,
      args.expiration,
      args.salt
    );
  }

  function _enforceExpiration(uint256 expiration) private view {

    require(
      expiration == 0 || block.timestamp <= expiration,
      "Order has expired."
    );
  }

  modifier onlyOwnerOr(Role role) {

    if (!isOwner()) {
      require(_isRole(role), "Caller does not have a required role.");
      require(!_isPaused(role), "Role in question is currently paused.");
    }
    _;
  }

  modifier onlyOwnerOrAccountOr(Role role, address account) {

    if (!isOwner() && !(msg.sender == account)) {
      require(_isRole(role), "Caller does not have a required role.");
      require(!_isPaused(role), "Role in question is currently paused.");
    }
    _;
  }
}