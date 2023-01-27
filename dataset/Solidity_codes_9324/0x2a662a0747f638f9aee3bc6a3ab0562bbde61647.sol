
pragma solidity 0.5.3; // optimization disabled, evm version: constantinople


interface DharmaSmartWalletImplementationV0Interface {

  event NewUserSigningKey(address userSigningKey);

  event ExternalError(address indexed source, string revertReason);

  enum AssetType {
    DAI,
    USDC,
    ETH
  }

  enum ActionType {
    Cancel,
    SetUserSigningKey,
    Generic,
    GenericAtomicBatch,
    DAIWithdrawal,
    USDCWithdrawal,
    ETHWithdrawal,
    SetEscapeHatch,
    RemoveEscapeHatch,
    DisableEscapeHatch,
    DAIBorrow,
    USDCBorrow
  }

  function initialize(address userSigningKey) external;


  function repayAndDeposit() external;


  function withdrawDai(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok);


  function withdrawUSDC(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok);


  function cancel(
    uint256 minimumActionGas,
    bytes calldata signature
  ) external;


  function setUserSigningKey(
    address userSigningKey,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;


  function getBalances() external returns (
    uint256 daiBalance,
    uint256 usdcBalance,
    uint256 etherBalance,
    uint256 cDaiUnderlyingDaiBalance,
    uint256 cUsdcUnderlyingUsdcBalance,
    uint256 cEtherUnderlyingEtherBalance
  );


  function getUserSigningKey() external view returns (address userSigningKey);


  function getNonce() external view returns (uint256 nonce);


  function getNextCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);


  function getCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);


  function getVersion() external pure returns (uint256 version);

}


interface DharmaSmartWalletImplementationV1Interface {

  event CallSuccess(
    bytes32 actionID,
    bool rolledBack,
    uint256 nonce,
    address to,
    bytes data,
    bytes returnData
  );
  
  event CallFailure(
    bytes32 actionID,
    uint256 nonce,
    address to,
    bytes data,
    string revertReason
  );

  function withdrawEther(
    uint256 amount,
    address payable recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok);


  function executeAction(
    address to,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData);


  function recover(address newUserSigningKey) external;


  function getNextGenericActionID(
    address to,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);


  function getGenericActionID(
    address to,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

}


interface DharmaSmartWalletImplementationV3Interface {

  event Cancel(uint256 cancelledNonce);
  event EthWithdrawal(uint256 amount, address recipient);
}


interface CTokenInterface {

  function mint(uint256 mintAmount) external returns (uint256 err);


  function redeem(uint256 redeemAmount) external returns (uint256 err);

  
  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);


  function balanceOfUnderlying(address account) external returns (uint256 balance);

}


interface USDCV1Interface {

  function isBlacklisted(address _account) external view returns (bool);

  
  function paused() external view returns (bool);

}


interface ComptrollerInterface {}



interface DharmaKeyRegistryInterface {

  function getKey() external view returns (address key);

}


interface IERC20 {

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

}


interface ERC1271 {

  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue);

}


library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


library ECDSA {

  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

    if (signature.length != 65) {
      return (address(0));
    }

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return address(0);
    }

    if (v != 27 && v != 28) {
      return address(0);
    }

    return ecrecover(hash, v, r, s);
  }

  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}


contract DharmaSmartWalletImplementationV3 is
  DharmaSmartWalletImplementationV0Interface,
  DharmaSmartWalletImplementationV1Interface,
  DharmaSmartWalletImplementationV3Interface {

  using Address for address;
  using ECDSA for bytes32;

  address private _userSigningKey;

  uint256 private _nonce;

  bytes4 internal _selfCallContext;


  uint256 internal constant _DHARMA_SMART_WALLET_VERSION = 1003;

  DharmaKeyRegistryInterface internal constant _DHARMA_KEY_REGISTRY = (
    DharmaKeyRegistryInterface(0x000000000D38df53b45C5733c7b34000dE0BDF52)
  );

  address internal constant _ACCOUNT_RECOVERY_MANAGER = address(
    0x00000000004cDa75701EeA02D1F2F9BDcE54C10D
  );

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0xF5DCe57282A584D2746FaF1593d3121Fcac444dC // mainnet
  );

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 // mainnet
  );

  IERC20 internal constant _DAI = IERC20(
    0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359 // mainnet
  );

  IERC20 internal constant _USDC = IERC20(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );

  USDCV1Interface internal constant _USDC_NAUGHTY = USDCV1Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );

  ComptrollerInterface internal constant _COMPTROLLER = ComptrollerInterface(
    0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B // mainnet
  );

  uint256 internal constant _COMPOUND_SUCCESS = 0;

  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);

  uint256 private constant _JUST_UNDER_ONE_1000th_DAI = 999999999999999;
  uint256 private constant _JUST_UNDER_ONE_1000th_USDC = 999;

  function initialize(address userSigningKey) external {

    assembly { if extcodesize(address) { revert(0, 0) } }

    _setUserSigningKey(userSigningKey);

    if (_setFullApproval(AssetType.DAI)) {
      uint256 daiBalance = _DAI.balanceOf(address(this));

      _depositOnCompound(AssetType.DAI, daiBalance);
    }

    if (_setFullApproval(AssetType.USDC)) {
      uint256 usdcBalance = _USDC.balanceOf(address(this));

      _depositOnCompound(AssetType.USDC, usdcBalance);
    }
  }

  function repayAndDeposit() external {

    uint256 daiBalance = _DAI.balanceOf(address(this));

    _depositOnCompound(AssetType.DAI, daiBalance);

    uint256 usdcBalance = _USDC.balanceOf(address(this));

    if (usdcBalance > 0) {
      uint256 usdcAllowance = _USDC.allowance(address(this), address(_CUSDC));
      if (usdcAllowance < usdcBalance) {
        if (_setFullApproval(AssetType.USDC)) {
          _depositOnCompound(AssetType.USDC, usdcBalance);
        }
      } else {
        _depositOnCompound(AssetType.USDC, usdcBalance);
      }
    }
  }

  function withdrawDai(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok) {

    _validateActionAndIncrementNonce(
      ActionType.DAIWithdrawal,
      abi.encode(amount, recipient),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    require(amount > _JUST_UNDER_ONE_1000th_DAI, "Insufficient Dai supplied.");

    require(recipient != address(0), "No recipient supplied.");

    _selfCallContext = this.withdrawDai.selector;

    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._withdrawDaiAtomic.selector, amount, recipient
    ));

    if (!ok) {
      emit ExternalError(address(_DAI), "DAI contract reverted on transfer.");
    } else {
      ok = abi.decode(returnData, (bool));
    }
  }

  function _withdrawDaiAtomic(
    uint256 amount,
    address recipient
  ) external returns (bool success) {

    _enforceSelfCallFrom(this.withdrawDai.selector);

    bool maxWithdraw = (amount == uint256(-1));
    if (maxWithdraw) {
      if (_withdrawMaxFromCompound(AssetType.DAI)) {
        require(_DAI.transfer(recipient, _DAI.balanceOf(address(this))));
        success = true;
      }
    } else {
      if (_withdrawFromCompound(AssetType.DAI, amount)) {
        require(_DAI.transfer(recipient, amount));
        success = true;
      }
    }
  }

  function withdrawUSDC(
    uint256 amount,
    address recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok) {

    _validateActionAndIncrementNonce(
      ActionType.USDCWithdrawal,
      abi.encode(amount, recipient),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    require(amount > _JUST_UNDER_ONE_1000th_USDC, "Insufficient USDC supplied.");

    require(recipient != address(0), "No recipient supplied.");

    _selfCallContext = this.withdrawUSDC.selector;

    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._withdrawUSDCAtomic.selector, amount, recipient
    ));
    if (!ok) {
      _diagnoseAndEmitUSDCSpecificError(_USDC.transfer.selector);
    } else {
      ok = abi.decode(returnData, (bool));
    }
  }

  function _withdrawUSDCAtomic(
    uint256 amount,
    address recipient
  ) external returns (bool success) {

    _enforceSelfCallFrom(this.withdrawUSDC.selector);

    bool maxWithdraw = (amount == uint256(-1));
    if (maxWithdraw) {
      if (_withdrawMaxFromCompound(AssetType.USDC)) {
        require(_USDC.transfer(recipient, _USDC.balanceOf(address(this))));
        success = true;
      }
    } else {
      if (_withdrawFromCompound(AssetType.USDC, amount)) {
        require(_USDC.transfer(recipient, amount));
        success = true;
      }
    }
  }

  function withdrawEther(
    uint256 amount,
    address payable recipient,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok) {

    _validateActionAndIncrementNonce(
      ActionType.ETHWithdrawal,
      abi.encode(amount, recipient),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    (ok, ) = recipient.call.gas(2300).value(amount)("");
    if (!ok) {
      emit ExternalError(recipient, "Recipient rejected ether transfer.");
    } else {
      emit EthWithdrawal(amount, recipient);
    }
  }

  function cancel(
    uint256 minimumActionGas,
    bytes calldata signature
  ) external {

    uint256 nonceToCancel = _nonce;

    _validateActionAndIncrementNonce(
      ActionType.Cancel,
      abi.encode(),
      minimumActionGas,
      signature,
      signature
    );

    emit Cancel(nonceToCancel);
  }

  function executeAction(
    address to,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData) {

    _ensureValidGenericCallTarget(to);

    (bytes32 actionID, uint256 nonce) = _validateActionAndIncrementNonce(
      ActionType.Generic,
      abi.encode(to, data),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );


    (ok, returnData) = to.call(data);

    if (ok) {
      emit CallSuccess(actionID, false, nonce, to, data, returnData);
    } else {
      emit CallFailure(actionID, nonce, to, data, string(returnData));
    }
  }

  function setUserSigningKey(
    address userSigningKey,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {

    _validateActionAndIncrementNonce(
      ActionType.SetUserSigningKey,
      abi.encode(userSigningKey),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    _setUserSigningKey(userSigningKey);
  }

  function recover(address newUserSigningKey) external {

    require(
      msg.sender == _ACCOUNT_RECOVERY_MANAGER,
      "Only the account recovery manager may call this function."
    );

    _nonce++;

    _setUserSigningKey(newUserSigningKey);
  }

  function getBalances() external returns (
    uint256 daiBalance,
    uint256 usdcBalance,
    uint256 etherBalance, // always returns 0
    uint256 cDaiUnderlyingDaiBalance,
    uint256 cUsdcUnderlyingUsdcBalance,
    uint256 cEtherUnderlyingEtherBalance // always returns 0
  ) {

    daiBalance = _DAI.balanceOf(address(this));
    usdcBalance = _USDC.balanceOf(address(this));
    cDaiUnderlyingDaiBalance = _CDAI.balanceOfUnderlying(address(this));
    cUsdcUnderlyingUsdcBalance = _CUSDC.balanceOfUnderlying(address(this));
  }

  function getUserSigningKey() external view returns (address userSigningKey) {

    userSigningKey = _userSigningKey;
  }

  function getNonce() external view returns (uint256 nonce) {

    nonce = _nonce;
  }

  function getNextCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {

    actionID = _getActionID(
      action,
      _validateCustomActionTypeAndGetArguments(action, amount, recipient),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function getCustomActionID(
    ActionType action,
    uint256 amount,
    address recipient,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {

    actionID = _getActionID(
      action,
      _validateCustomActionTypeAndGetArguments(action, amount, recipient),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function getNextGenericActionID(
    address to,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {

    actionID = _getActionID(
      ActionType.Generic,
      abi.encode(to, data),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function getGenericActionID(
    address to,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {

    actionID = _getActionID(
      ActionType.Generic,
      abi.encode(to, data),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function getVersion() external pure returns (uint256 version) {

    version = _DHARMA_SMART_WALLET_VERSION;
  }

  function _setUserSigningKey(address userSigningKey) internal {

    require(userSigningKey != address(0), "No user signing key provided.");
    
    _userSigningKey = userSigningKey;
    emit NewUserSigningKey(userSigningKey);
  }

  function _setFullApproval(AssetType asset) internal returns (bool ok) {

    address token;
    address cToken;
    if (asset == AssetType.DAI) {
      token = address(_DAI);
      cToken = address(_CDAI);
    } else {
      token = address(_USDC);
      cToken = address(_CUSDC);
    }

    (ok, ) = token.call(abi.encodeWithSelector(
      _DAI.approve.selector, cToken, uint256(-1)
    ));

    if (!ok) {
      if (asset == AssetType.DAI) {
        emit ExternalError(address(_DAI), "DAI contract reverted on approval.");
      } else {
        _diagnoseAndEmitUSDCSpecificError(_USDC.approve.selector);
      }
    }
  }

  function _depositOnCompound(AssetType asset, uint256 balance) internal {

    if (
      asset == AssetType.DAI && balance > _JUST_UNDER_ONE_1000th_DAI ||
      asset == AssetType.USDC && balance > _JUST_UNDER_ONE_1000th_USDC
    ) {
      address cToken = asset == AssetType.DAI ? address(_CDAI) : address(_CUSDC);

      (bool ok, bytes memory data) = cToken.call(abi.encodeWithSelector(
        _CDAI.mint.selector, balance
      ));

      _checkCompoundInteractionAndLogAnyErrors(
        asset, _CDAI.mint.selector, ok, data
      );
    }
  }

  function _withdrawFromCompound(
    AssetType asset,
    uint256 balance
  ) internal returns (bool success) {

    address cToken = asset == AssetType.DAI ? address(_CDAI) : address(_CUSDC);

    (bool ok, bytes memory data) = cToken.call(abi.encodeWithSelector(
      _CDAI.redeemUnderlying.selector, balance
    ));

    success = _checkCompoundInteractionAndLogAnyErrors(
      asset, _CDAI.redeemUnderlying.selector, ok, data
    );
  }

  function _withdrawMaxFromCompound(
    AssetType asset
  ) internal returns (bool success) {

    address cToken = asset == AssetType.DAI ? address(_CDAI) : address(_CUSDC);

    uint256 redeemAmount = IERC20(cToken).balanceOf(address(this));

    (bool ok, bytes memory data) = cToken.call(abi.encodeWithSelector(
      _CDAI.redeem.selector, redeemAmount
    ));

    success = _checkCompoundInteractionAndLogAnyErrors(
      asset, _CDAI.redeem.selector, ok, data
    );
  }

  function _validateActionAndIncrementNonce(
    ActionType action,
    bytes memory arguments,
    uint256 minimumActionGas,
    bytes memory userSignature,
    bytes memory dharmaSignature
  ) internal returns (bytes32 actionID, uint256 actionNonce) {

    if (minimumActionGas != 0) {
      require(
        gasleft() >= minimumActionGas,
        "Invalid action - insufficient gas supplied by transaction submitter."
      );
    }

    actionNonce = _nonce;

    address userSigningKey = _userSigningKey;

    address dharmaSigningKey = _getDharmaSigningKey();

    actionID = _getActionID(
      action,
      arguments,
      actionNonce,
      minimumActionGas,
      userSigningKey,
      dharmaSigningKey
    );

    bytes32 messageHash = actionID.toEthSignedMessageHash();

    if (action != ActionType.Cancel) {
      if (msg.sender != userSigningKey) {
        require(
          _validateUserSignature(
            messageHash, action, arguments, userSigningKey, userSignature
          ),
          "Invalid action - invalid user signature."
        );
      }

      if (msg.sender != dharmaSigningKey) {
        require(
          dharmaSigningKey == messageHash.recover(dharmaSignature),
          "Invalid action - invalid Dharma signature."
        );
      }
    } else {
      if (msg.sender != userSigningKey && msg.sender != dharmaSigningKey) {
        require(
          dharmaSigningKey == messageHash.recover(dharmaSignature) ||
          _validateUserSignature(
            messageHash, action, arguments, userSigningKey, userSignature
          ),
          "Invalid action - invalid signature."
        );
      }
    }

    _nonce++;
  }

  function _checkCompoundInteractionAndLogAnyErrors(
    AssetType asset,
    bytes4 functionSelector,
    bool ok,
    bytes memory data
  ) internal returns (bool success) {

    if (ok) {
      uint256 compoundError = abi.decode(data, (uint256));
      if (compoundError != _COMPOUND_SUCCESS) {
        (address account, string memory name, string memory functionName) = (
          _getCTokenDetails(asset, functionSelector)
        );

        emit ExternalError(
          account,
          string(
            abi.encodePacked(
              "Compound ",
              name,
              " contract returned error code ",
              uint8((compoundError / 10) + 48),
              uint8((compoundError % 10) + 48),
              " while attempting to call ",
              functionName,
              "."
            )
          )
        );
      } else {
        success = true;
      }
    } else {
      (address account, string memory name, string memory functionName) = (
        _getCTokenDetails(asset, functionSelector)
      );

      string memory revertReason = _decodeRevertReason(data);

      emit ExternalError(
        account,
        string(
          abi.encodePacked(
            "Compound ",
            name,
            " contract reverted while attempting to call ",
            functionName,
            ": ",
            revertReason
          )
        )
      );
    }
  }

  function _diagnoseAndEmitUSDCSpecificError(bytes4 functionSelector) internal {

    string memory functionName;
    if (functionSelector == _USDC.transfer.selector) {
      functionName = "transfer";
    } else {
      functionName = "approve";
    }

    if (_USDC_NAUGHTY.isBlacklisted(address(this))) {
      emit ExternalError(
        address(_USDC),
        string(
          abi.encodePacked(
            functionName, " failed - USDC has blacklisted this user."
          )
        )
      );
    } else { // Note: `else if` breaks coverage.
      if (_USDC_NAUGHTY.paused()) {
        emit ExternalError(
          address(_USDC),
          string(
            abi.encodePacked(
              functionName, " failed - USDC contract is currently paused."
            )
          )
        );
      } else {
        emit ExternalError(
          address(_USDC),
          string(
            abi.encodePacked(
              "USDC contract reverted on ", functionName, "."
            )
          )
        );
      }
    }
  }

  function _enforceSelfCallFrom(bytes4 selfCallContext) internal {

    require(
      msg.sender == address(this) &&
      _selfCallContext == selfCallContext,
      "External accounts or unapproved internal functions cannot call this."
    );

    delete _selfCallContext;
  }

  function _validateUserSignature(
    bytes32 messageHash,
    ActionType action,
    bytes memory arguments,
    address userSigningKey,
    bytes memory userSignature
  ) internal view returns (bool valid) {

    if (!userSigningKey.isContract()) {
      valid = userSigningKey == messageHash.recover(userSignature);
    } else {
      bytes memory data = abi.encode(messageHash, action, arguments);
      valid = (
        ERC1271(userSigningKey).isValidSignature(
          data, userSignature
        ) == _ERC_1271_MAGIC_VALUE
      );
    }
  }

  function _getDharmaSigningKey() internal view returns (
    address dharmaSigningKey
  ) {

    dharmaSigningKey = _DHARMA_KEY_REGISTRY.getKey();
  }

  function _getActionID(
    ActionType action,
    bytes memory arguments,
    uint256 nonce,
    uint256 minimumActionGas,
    address userSigningKey,
    address dharmaSigningKey
  ) internal view returns (bytes32 actionID) {

    actionID = keccak256(
      abi.encodePacked(
        address(this),
        _DHARMA_SMART_WALLET_VERSION,
        userSigningKey,
        dharmaSigningKey,
        nonce,
        minimumActionGas,
        action,
        arguments
      )
    );
  }

  function _getCTokenDetails(
    AssetType asset,
    bytes4 functionSelector
  ) internal pure returns (
    address account,
    string memory name,
    string memory functionName
  ) {

    if (asset == AssetType.DAI) {
      account = address(_CDAI);
      name = "cDAI";
    } else {
      account = address(_CUSDC);
      name = "cUSDC";
    }

    if (functionSelector == _CDAI.mint.selector) {
      functionName = "mint";
    } else {
      functionName = string(abi.encodePacked(
        "redeem",
        functionSelector == _CDAI.redeemUnderlying.selector ? "Underlying" : ""
      ));
    }
  }

  function _ensureValidGenericCallTarget(address to) internal view {

    require(
      to.isContract(),
      "Invalid `to` parameter - must supply a contract address containing code."
    );

    require(
      to != address(this),
      "Invalid `to` parameter - cannot supply the address of this contract."
    );
  }

  function _validateCustomActionTypeAndGetArguments(
    ActionType action, uint256 amount, address recipient
  ) internal pure returns (bytes memory arguments) {

    require(
      action == ActionType.Cancel ||
      action == ActionType.SetUserSigningKey ||
      action == ActionType.DAIWithdrawal ||
      action == ActionType.USDCWithdrawal ||
      action == ActionType.ETHWithdrawal,
      "Invalid custom action type."
    );

    if (action == ActionType.Cancel) {
      arguments = abi.encode();
    } else if (action == ActionType.SetUserSigningKey) {
      arguments = abi.encode(recipient);
    } else {
      arguments = abi.encode(amount, recipient);
    }
  }

  function _decodeRevertReason(
    bytes memory revertData
  ) internal pure returns (string memory revertReason) {

    if (
      revertData.length > 68 && // prefix (4) + position (32) + length (32)
      revertData[0] == byte(0x08) &&
      revertData[1] == byte(0xc3) &&
      revertData[2] == byte(0x79) &&
      revertData[3] == byte(0xa0)
    ) {
      bytes memory revertReasonBytes = new bytes(revertData.length - 4);
      for (uint256 i = 4; i < revertData.length; i++) {
        revertReasonBytes[i - 4] = revertData[i];
      }

      revertReason = abi.decode(revertReasonBytes, (string));
    } else {
      revertReason = "(no revert reason)";
    }
  }
}