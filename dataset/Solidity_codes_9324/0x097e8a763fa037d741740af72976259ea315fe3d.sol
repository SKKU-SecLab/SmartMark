
pragma solidity 0.5.3; // optimization runs: 200


interface DharmaSmartWalletImplementationV0Interface {

  event NewUserSigningKey(address userSigningKey);

  event ExternalError(address indexed source, string revertReason);

  enum AssetType {
    DAI,
    USDC,
    ETH,
    SAI
  }

  enum ActionType {
    Cancel,
    SetUserSigningKey,
    Generic,
    GenericAtomicBatch,
    SAIWithdrawal,
    USDCWithdrawal,
    ETHWithdrawal,
    SetEscapeHatch,
    RemoveEscapeHatch,
    DisableEscapeHatch,
    DAIWithdrawal,
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
    uint256 cUSDCUnderlyingUSDCBalance,
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


interface DharmaSmartWalletImplementationV4Interface {

  event Escaped();

  function setEscapeHatch(
    address account,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;


  function removeEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;


  function permanentlyDisableEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external;


  function escape() external;

}


interface DharmaSmartWalletImplementationV6Interface {

  function migrateSaiToDai() external;

  function migrateCSaiToCDai() external;

}


interface CTokenInterface {

  function mint(uint256 mintAmount) external returns (uint256 err);

  function redeem(uint256 redeemAmount) external returns (uint256 err);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);

  function balanceOf(address account) external returns (uint256 balance);

  function balanceOfUnderlying(address account) external returns (uint256 balance);

}


interface USDCV1Interface {

  function isBlacklisted(address _account) external view returns (bool);

  function paused() external view returns (bool);

}


interface DharmaKeyRegistryInterface {

  event NewGlobalKey(address oldGlobalKey, address newGlobalKey);
  event NewSpecificKey(
    address indexed account, address oldSpecificKey, address newSpecificKey
  );

  function setGlobalKey(address globalKey, bytes calldata signature) external;

  function setSpecificKey(address account, address specificKey) external;

  function getKey() external view returns (address key);

  function getKeyForUser(address account) external view returns (address key);

  function getGlobalKey() external view returns (address globalKey);

  function getSpecificKey(address account) external view returns (address specificKey);

}


interface DharmaEscapeHatchRegistryInterface {

  event EscapeHatchModified(
    address indexed smartWallet, address oldEscapeHatch, address newEscapeHatch
  );

  event EscapeHatchDisabled(address smartWallet);

  struct EscapeHatch {
    address escapeHatch;
    bool disabled;
  }

  function setEscapeHatch(address newEscapeHatch) external;


  function removeEscapeHatch() external;


  function permanentlyDisableEscapeHatch() external;


  function getEscapeHatch() external view returns (
    bool exists, address escapeHatch
  );


  function getEscapeHatchForSmartWallet(
    address smartWallet
  ) external view returns (bool exists, address escapeHatch);


  function hasDisabledEscapeHatchForSmartWallet(
    address smartWallet
  ) external view returns (bool disabled);

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


interface SaiToDaiMigratorInterface {

  function swapSaiToDai(uint256 balance) external;

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


contract DharmaSmartWalletImplementationV6 is
  DharmaSmartWalletImplementationV0Interface,
  DharmaSmartWalletImplementationV1Interface,
  DharmaSmartWalletImplementationV3Interface,
  DharmaSmartWalletImplementationV4Interface,
  DharmaSmartWalletImplementationV6Interface {

  using Address for address;
  using ECDSA for bytes32;

  address private _userSigningKey;

  uint256 private _nonce;

  bytes4 internal _selfCallContext;


  uint256 internal constant _DHARMA_SMART_WALLET_VERSION = 1006;

  DharmaKeyRegistryInterface internal constant _DHARMA_KEY_REGISTRY = (
    DharmaKeyRegistryInterface(0x000000000D38df53b45C5733c7b34000dE0BDF52)
  );

  address internal constant _ACCOUNT_RECOVERY_MANAGER = address(
    0x0000000000DfEd903aD76996FC07BF89C0127B1E
  );

  DharmaEscapeHatchRegistryInterface internal constant _ESCAPE_HATCH_REGISTRY = (
    DharmaEscapeHatchRegistryInterface(0x00000000005280B515004B998a944630B6C663f8)
  );

  CTokenInterface internal constant _CSAI = CTokenInterface(
    0xF5DCe57282A584D2746FaF1593d3121Fcac444dC // mainnet
  );

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 // mainnet
  );

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 // mainnet
  );

  IERC20 internal constant _SAI = IERC20(
    0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359 // mainnet
  );

  IERC20 internal constant _DAI = IERC20(
    0x6B175474E89094C44Da98b954EedeAC495271d0F // mainnet
  );

  IERC20 internal constant _USDC = IERC20(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );

  SaiToDaiMigratorInterface internal constant _MIGRATOR = SaiToDaiMigratorInterface(
    0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849 // mainnet
  );

  USDCV1Interface internal constant _USDC_NAUGHTY = USDCV1Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );

  uint256 internal constant _COMPOUND_SUCCESS = 0;

  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);

  uint256 private constant _JUST_UNDER_ONE_1000th_DAI = 999999999999999;
  uint256 private constant _JUST_UNDER_ONE_1000th_USDC = 999;

  uint256 private constant _ETH_TRANSFER_GAS = 4999;

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

    if (daiBalance > 0) {
      uint256 daiAllowance = _DAI.allowance(address(this), address(_CDAI));
      if (daiAllowance < daiBalance) {
        if (_setFullApproval(AssetType.DAI)) {
          _depositOnCompound(AssetType.DAI, daiBalance);
        }
      } else {
        _depositOnCompound(AssetType.DAI, daiBalance);
      }
    }

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
      emit ExternalError(address(_DAI), "Could not transfer Dai.");
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
      _withdrawMaxFromCompound(AssetType.DAI);

      require(_transferMax(_DAI, recipient, false));
      success = true;
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
      _withdrawMaxFromCompound(AssetType.USDC);

      require(_transferMax(_USDC, recipient, false));
      success = true;
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

    require(amount > 0, "Must supply a non-zero amount of Ether.");

    require(recipient != address(0), "No recipient supplied.");

    ok = _transferETH(recipient, amount);
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

  function setEscapeHatch(
    address account,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {

    _validateActionAndIncrementNonce(
      ActionType.SetEscapeHatch,
      abi.encode(account),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    require(account != address(0), "Must supply an escape hatch account.");

    _ESCAPE_HATCH_REGISTRY.setEscapeHatch(account);
  }

  function removeEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {

    _validateActionAndIncrementNonce(
      ActionType.RemoveEscapeHatch,
      abi.encode(),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    _ESCAPE_HATCH_REGISTRY.removeEscapeHatch();
  }

  function permanentlyDisableEscapeHatch(
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external {

    _validateActionAndIncrementNonce(
      ActionType.DisableEscapeHatch,
      abi.encode(),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    _ESCAPE_HATCH_REGISTRY.permanentlyDisableEscapeHatch();
  }

  function escape() external {

    (bool exists, address escapeHatch) = _ESCAPE_HATCH_REGISTRY.getEscapeHatch();

    require(exists, "No escape hatch is currently set for this smart wallet.");

    require(
      msg.sender == escapeHatch,
      "Only the escape hatch account may call this function."
    );

    _withdrawMaxFromCompound(AssetType.SAI);

    _withdrawMaxFromCompound(AssetType.DAI);

    _withdrawMaxFromCompound(AssetType.USDC);

    _transferMax(_SAI, msg.sender, true);

    _transferMax(_DAI, msg.sender, true);

    _transferMax(_USDC, msg.sender, true);

    _transferMax(IERC20(address(_CSAI)), msg.sender, true);

    _transferMax(IERC20(address(_CDAI)), msg.sender, true);

    _transferMax(IERC20(address(_CUSDC)), msg.sender, true);

    uint256 balance = address(this).balance;
    if (balance > 0) {
      _transferETH(msg.sender, balance);
    }

    emit Escaped();
  }

  function recover(address newUserSigningKey) external {

    require(
      msg.sender == _ACCOUNT_RECOVERY_MANAGER,
      "Only the account recovery manager may call this function."
    );

    _nonce++;

    _setUserSigningKey(newUserSigningKey);
  }

  function migrateSaiToDai() external {

    _swapSaiForDai(_SAI.balanceOf(address(this)));
  }

  function migrateCSaiToCDai() external {

    uint256 redeemAmount = _CSAI.balanceOf(address(this));

    if (redeemAmount > 0) {
      uint256 currentSaiBalance = _SAI.balanceOf(address(this));

      require(
        _CSAI.redeem(redeemAmount) == _COMPOUND_SUCCESS, "cSai redeem failed."
      );

      uint256 saiBalance = _SAI.balanceOf(address(this)) - currentSaiBalance;

      uint256 daiBalance = _swapSaiForDai(saiBalance);
      
      if (_DAI.allowance(address(this), address(_CDAI)) < daiBalance) {
        require(
          _DAI.approve(address(_CDAI), uint256(-1)), "Dai approval failed."
        );
      }
      
      require(_CDAI.mint(daiBalance) == _COMPOUND_SUCCESS, "cDai mint failed.");
    }
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

  function _swapSaiForDai(uint256 saiToSwap) internal returns (uint256 dai) {

    if (saiToSwap > 0) {
      uint256 allowance = _SAI.allowance(address(this), address(_MIGRATOR));
      
      if (saiToSwap > allowance) {
        require(
          _SAI.approve(address(_MIGRATOR), uint256(-1)), "Sai approval failed."
        );
      }

      uint256 currentDaiBalance = _DAI.balanceOf(address(this));

      _MIGRATOR.swapSaiToDai(saiToSwap);

      dai = _DAI.balanceOf(address(this)) - currentDaiBalance;

      require(dai >= saiToSwap, "Exchange rate cannot be below 1:1.");
    } else {
      dai = 0;
    }
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

    (ok, ) = address(token).call(abi.encodeWithSelector(
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

  function _withdrawMaxFromCompound(AssetType asset) internal {

    address cToken = (
      asset == AssetType.DAI ? address(_CDAI) : (
        asset == AssetType.USDC ? address(_CUSDC) : address(_CSAI)
      )
    );

    uint256 redeemAmount = IERC20(cToken).balanceOf(address(this));

    if (redeemAmount > 0) {
      (bool ok, bytes memory data) = cToken.call(abi.encodeWithSelector(
        _CDAI.redeem.selector, redeemAmount
      ));

      _checkCompoundInteractionAndLogAnyErrors(
        asset, _CDAI.redeem.selector, ok, data
      );
    }
  }

  function _transferMax(
    IERC20 token, address recipient, bool suppressRevert
  ) internal returns (bool success) {

    uint256 transferAmount = token.balanceOf(address(this));

    if (transferAmount > 0) {
      if (!suppressRevert) {
        success = token.transfer(recipient, transferAmount);
      } else {
        (success, ) = address(token).call.gas(gasleft() / 2)(
          abi.encodeWithSelector(
            token.transfer.selector, recipient, transferAmount
          )
        );
      }
    } else {
      success = true;
    }
  }

  function _transferETH(
    address payable recipient, uint256 amount
  ) internal returns (bool success) {

    (success, ) = recipient.call.gas(_ETH_TRANSFER_GAS).value(amount)("");
    if (!success) {
      emit ExternalError(recipient, "Recipient rejected ether transfer.");
    } else {
      emit EthWithdrawal(amount, recipient);
    }
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

    require(
      to != address(_ESCAPE_HATCH_REGISTRY),
      "Invalid `to` parameter - cannot supply the Dharma Escape Hatch Registry."
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
      action == ActionType.ETHWithdrawal ||
      action == ActionType.SetEscapeHatch ||
      action == ActionType.RemoveEscapeHatch ||
      action == ActionType.DisableEscapeHatch,
      "Invalid custom action type."
    );

    if (
      action == ActionType.Cancel ||
      action == ActionType.RemoveEscapeHatch ||
      action == ActionType.DisableEscapeHatch
    ) {
      arguments = abi.encode();
    } else if (
      action == ActionType.SetUserSigningKey ||
      action == ActionType.SetEscapeHatch
    ) {
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