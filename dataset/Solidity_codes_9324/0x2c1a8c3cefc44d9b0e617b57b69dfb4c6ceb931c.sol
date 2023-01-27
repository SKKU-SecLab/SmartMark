
pragma solidity 0.6.8; // optimization runs: 200, evm version: istanbul
pragma experimental ABIEncoderV2;


interface BotCommanderV1Interface {

  event DaiToEthLimitOrderProcessed(
    address indexed smartWallet, uint256 daiGiven, uint256 etherReceived
  );
  event EthToDaiLimitOrderProcessed(
    address indexed smartWallet, uint256 etherGiven, uint256 daiReceived
  );
  event RoleModified(Role indexed role, address account);
  event RolePaused(Role indexed role);
  event RoleUnpaused(Role indexed role);

  enum Role {
    BOT_COMMANDER,
    PAUSER
  }

  struct RoleStatus {
    address account;
    bool paused;
  }

  struct DaiToEthArguments {
    address payable smartWallet;
    uint256 dDaiAmountToApprove;
    uint256 daiUnderlyingAmountToGive; // lower than maximum for partial fills
    uint256 maximumDaiUnderlyingAmountToGive;
    uint256 maximumEthPriceToAccept; // represented as a mantissa (n * 10^18)
    uint256 expiration;
    bytes32 salt;
    bytes approvalSignatures;
    bytes executionSignatures;
    address tradeTarget;
    bytes tradeData;
  }

  function redeemDDaiAndProcessDaiToEthLimitOrder(
    DaiToEthArguments calldata args
  ) external returns (uint256 etherReceived);


  struct EthToDaiArguments {
    address smartWallet;
    uint256 etherAmountToGive; // will be lower than maximum for partial fills
    uint256 maximumEtherAmountToGive;
    uint256 minimumEtherPriceToAccept; // represented as a mantissa (n * 10^18)
    uint256 expiration;
    bytes32 salt;
    bytes approvalSignatures;
    bytes executionSignatures;
    address tradeTarget;
    bytes tradeData;
  }

  function processEthToDaiLimitOrderAndMintDDai(
    EthToDaiArguments calldata args
  ) external returns (uint256 tokensReceived);


  function cancelDaiToEthLimitOrder(
    address smartWallet,
    uint256 maximumDaiUnderlyingAmountToGive,
    uint256 maximumEthPriceToAccept, // represented as a mantissa (n * 10^18)
    uint256 expiration,
    bytes32 salt
  ) external returns (bool success);


  function cancelEthToDaiLimitOrder(
    address smartWallet,
    uint256 maximumEtherAmountToGive,
    uint256 minimumEtherPriceToAccept, // represented as a mantissa (n * 10^18)
    uint256 expiration,
    bytes32 salt
  ) external returns (bool success);


  function setRole(Role role, address account) external;


  function removeRole(Role role) external;


  function pause(Role role) external;


  function unpause(Role role) external;


  function isPaused(Role role) external view returns (bool paused);


  function isRole(Role role) external view returns (bool hasRole);


  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 messageHash, bool valid);


  function getBotCommander() external view returns (address botCommander);


  function getPauser() external view returns (address pauser);

}


interface ERC1271Interface {

  function isValidSignature(
    bytes calldata data, bytes calldata signatures
  ) external view returns (bytes4 magicValue);

}


interface ERC20Interface {

  function transfer(address, uint256) external returns (bool);

  function approve(address, uint256) external returns (bool);

  function balanceOf(address) external view returns (uint256);

  function allowance(address, address) external view returns (uint256);

}


interface DTokenInterface {

  function mint(
    uint256 underlyingToSupply
  ) external returns (uint256 dTokensMinted);

  function redeemUnderlying(
    uint256 underlyingToReceive
  ) external returns (uint256 dTokensBurned);

  function transfer(address, uint256) external returns (bool);

  function transferUnderlyingFrom(
    address sender, address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success);

  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external returns (bool success);


  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 digest, bool valid);

  function allowance(address, address) external view returns (uint256);

}


interface EtherizerV2Interface {

  function transferFrom(
    address from, address to, uint256 value
  ) external returns (bool);

  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external returns (bool success);


  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 digest, bool valid);

  function allowance(
    address owner, address spender
  ) external view returns (uint256 amount);

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


contract BotCommanderV1 is BotCommanderV1Interface, TwoStepOwnable {

  using SafeMath for uint256;

  mapping(uint256 => RoleStatus) private _roles;

  mapping (bytes32 => bool) private _invalidMetaTxHashes;

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F
  );

  DTokenInterface internal constant _DDAI = DTokenInterface(
    0x00000000001876eB1444c986fD502e618c587430
  );

  EtherizerV2Interface internal constant _ETH = EtherizerV2Interface(
    0x723B51b72Ae89A3d0c2a2760f0458307a1Baa191
  );

  constructor() public {
    _DAI.approve(address(_DDAI), type(uint256).max);
  }

  receive() external payable {}

  function redeemDDaiAndProcessDaiToEthLimitOrder(
    DaiToEthArguments calldata args
  ) external override onlyOwnerOr(Role.BOT_COMMANDER) returns (
    uint256 etherReceived
  ) {

    _enforceExpiration(args.expiration);

    bytes memory context = _constructContext(
      this.redeemDDaiAndProcessDaiToEthLimitOrder.selector,
      args.expiration,
      args.salt,
      abi.encode(
        args.smartWallet,
        args.maximumDaiUnderlyingAmountToGive,
        args.maximumEthPriceToAccept
      )
    );
    _validateMetaTransaction(
      args.smartWallet, context, args.executionSignatures
    );

    _tryApprovalViaMetaTransaction(
      address(_DDAI),
      args.smartWallet,
      args.dDaiAmountToApprove,
      args.expiration,
      args.salt,
      args.approvalSignatures
    );

    bool ok = _DDAI.transferUnderlyingFrom(
      args.smartWallet, address(this), args.daiUnderlyingAmountToGive
    );
    require(ok, "Dharma Dai transfer in failed.");

    _DDAI.redeemUnderlying(args.daiUnderlyingAmountToGive);

    if (_DAI.allowance(address(this), args.tradeTarget) != type(uint256).max) {
      _DAI.approve(args.tradeTarget, type(uint256).max);
    }

    (ok,) = args.tradeTarget.call(args.tradeData);

    _revertOnFailure(ok);

    etherReceived = address(this).balance;

    uint256 etherExpected = (args.daiUnderlyingAmountToGive.mul(1e18)).div(
      args.maximumEthPriceToAccept
    );

    require(
      etherReceived >= etherExpected,
      "Trade did not result in the expected amount of Ether."
    );

    (ok, ) = args.smartWallet.call{value: etherReceived}("");

    _revertOnFailure(ok);

    emit DaiToEthLimitOrderProcessed(
      args.smartWallet, args.daiUnderlyingAmountToGive, etherReceived
    );
  }

  function processEthToDaiLimitOrderAndMintDDai(
    EthToDaiArguments calldata args
  ) external override onlyOwnerOr(Role.BOT_COMMANDER) returns (
    uint256 daiReceived
  ) {

    _enforceExpiration(args.expiration);

    bytes memory context = _constructContext(
      this.redeemDDaiAndProcessDaiToEthLimitOrder.selector,
      args.expiration,
      args.salt,
      abi.encode(
        args.smartWallet,
        args.maximumEtherAmountToGive,
        args.minimumEtherPriceToAccept
      )
    );
    _validateMetaTransaction(
      args.smartWallet, context, args.executionSignatures
    );

    _tryApprovalViaMetaTransaction(
      address(_ETH),
      args.smartWallet,
      args.maximumEtherAmountToGive,
      args.expiration,
      args.salt,
      args.approvalSignatures
    );

    bool ok = _ETH.transferFrom(
        args.smartWallet, address(this), args.etherAmountToGive
    );
    require(ok, "Ether transfer in failed.");

    (ok,) = args.tradeTarget.call{value: address(this).balance}(args.tradeData);

    _revertOnFailure(ok);

    daiReceived = _DAI.balanceOf(address(this));

    uint256 daiExpected = args.etherAmountToGive.mul(
      args.minimumEtherPriceToAccept
    ) / 1e18;

    require(
      daiReceived >= daiExpected,
      "Trade did not result in the expected amount of Dai."
    );

    uint256 dDaiReceived = _DDAI.mint(daiReceived);

    ok = (_DDAI.transfer(msg.sender, dDaiReceived));
    require(ok, "Dharma Dai transfer out failed.");

    emit EthToDaiLimitOrderProcessed(
      args.smartWallet, args.etherAmountToGive, daiReceived
    );
  }

  function cancelDaiToEthLimitOrder(
    address smartWallet,
    uint256 maximumDaiUnderlyingAmountToGive,
    uint256 maximumEthPriceToAccept, // represented as a mantissa (n * 10^18)
    uint256 expiration,
    bytes32 salt
  ) external override returns (bool success) {

    _enforceExpiration(expiration);
    _enforceValidCanceller(smartWallet);

    bytes memory context = _constructContext(
      this.redeemDDaiAndProcessDaiToEthLimitOrder.selector,
      expiration,
      salt,
      abi.encode(
        smartWallet, maximumDaiUnderlyingAmountToGive, maximumEthPriceToAccept
      )
    );

    bytes32 messageHash = keccak256(context);

    require(
      !_invalidMetaTxHashes[messageHash], "Meta-transaction already invalid."
    );
    _invalidMetaTxHashes[messageHash] = true;

    success = true;
  }

  function cancelEthToDaiLimitOrder(
    address smartWallet,
    uint256 maximumEtherAmountToGive,
    uint256 minimumEtherPriceToAccept, // represented as a mantissa (n * 10^18)
    uint256 expiration,
    bytes32 salt
  ) external override returns (bool success) {

    _enforceExpiration(expiration);

    _enforceValidCanceller(smartWallet);

    bytes memory context = _constructContext(
      this.redeemDDaiAndProcessDaiToEthLimitOrder.selector,
      expiration,
      salt,
      abi.encode(
        smartWallet, maximumEtherAmountToGive, minimumEtherPriceToAccept
      )
    );

    bytes32 messageHash = keccak256(context);

    require(
      !_invalidMetaTxHashes[messageHash], "Meta-transaction already invalid."
    );
    _invalidMetaTxHashes[messageHash] = true;

    success = true;
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

  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view override returns (bytes32 messageHash, bool valid) {

    messageHash = keccak256(
      abi.encodePacked(
        address(this), functionSelector, expiration, salt, arguments
      )
    );

    valid = (
      !_invalidMetaTxHashes[messageHash] && (
        expiration == 0 || now <= expiration
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

  function getPauser() external view override returns (address pauser) {

    pauser = _roles[uint256(Role.PAUSER)].account;
  }

  function _validateMetaTransaction(
    address owner, bytes memory context, bytes memory signatures
  ) private {

    bytes32 messageHash = keccak256(context);

    require(
      !_invalidMetaTxHashes[messageHash], "Meta-transaction no longer valid."
    );
    _invalidMetaTxHashes[messageHash] = true;

    bytes32 digest = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    );

    bytes memory data = abi.encode(digest, context);
    bytes4 magic = ERC1271Interface(owner).isValidSignature(data, signatures);
    require(magic == bytes4(0x20c13b0b), "Invalid signatures.");
  }

  function _tryApprovalViaMetaTransaction(
    address approver,
    address ownerSmartWallet,
    uint256 value,
    uint256 expiration,
    bytes32 salt,
    bytes memory signatures
  ) private {

    (bool ok, bytes memory returnData) = approver.call(
      abi.encodeWithSelector(
        _DDAI.modifyAllowanceViaMetaTransaction.selector,
        ownerSmartWallet,
        address(this),
        value,
        true, // increase
        expiration,
        salt,
        signatures
      )
    );

    if (!ok) {
      DTokenInterface approverContract = DTokenInterface(approver);
      (, bool valid) = approverContract.getMetaTransactionMessageHash(
        _DDAI.modifyAllowanceViaMetaTransaction.selector,
        abi.encode(ownerSmartWallet, address(this), value, true),
        expiration,
        salt
      );

      if (valid) {
        assembly { revert(add(32, returnData), mload(returnData)) }
      }

      uint256 allowance = approverContract.allowance(
        ownerSmartWallet, address(this)
      );

      if (allowance < value) {
        assembly { revert(add(32, returnData), mload(returnData)) }
      }
    }
  }

  function _setRole(Role role, address account) private {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];

    if (account != storedRoleStatus.account) {
      storedRoleStatus.account = account;
      emit RoleModified(role, account);
    }
  }

  function _isRole(Role role) private view returns (bool hasRole) {

    hasRole = msg.sender == _roles[uint256(role)].account;
  }

  function _isPaused(Role role) private view returns (bool paused) {

    paused = _roles[uint256(role)].paused;
  }

  function _constructContext(
    bytes4 functionSelector,
    uint256 expiration,
    bytes32 salt,
    bytes memory arguments
  ) private view returns (bytes memory context) {

    context = abi.encodePacked(
      address(this), functionSelector, expiration, salt, arguments
    );
  }

  function _enforceExpiration(uint256 expiration) private view {

    require(
      expiration == 0 || now <= expiration,
      "Execution meta-transaction expired."
    );
  }

  function _enforceValidCanceller(address smartWallet) private view {

    require(
      msg.sender == smartWallet || msg.sender == _roles[uint256(
        Role.BOT_COMMANDER
      )].account,
      "Only wallet in question or bot commander role may cancel."
    );
  }

  function _revertOnFailure(bool ok) private pure {

    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }

  modifier onlyOwnerOr(Role role) {

    if (!isOwner()) {
      require(_isRole(role), "Caller does not have a required role.");
      require(!_isPaused(role), "Role in question is currently paused.");
    }
    _;
  }
}