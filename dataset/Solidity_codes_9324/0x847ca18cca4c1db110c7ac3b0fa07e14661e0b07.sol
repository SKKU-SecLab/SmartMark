
pragma solidity 0.5.17; // optimization runs: 200, evm version: istanbul
pragma experimental ABIEncoderV2;


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

  struct Call {
    address to;
    bytes data;
  }

  struct CallReturn {
    bool ok;
    bytes returnData;
  }

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


  function executeActionWithAtomicBatchCalls(
    Call[] calldata calls,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool[] memory ok, bytes[] memory returnData);


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


  function getNextGenericAtomicBatchActionID(
    Call[] calldata calls,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);


  function getGenericAtomicBatchActionID(
    Call[] calldata calls,
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


interface DharmaSmartWalletImplementationV7Interface {

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
    SignatureVerification,
    TradeEthForDai,
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


  function migrateSaiToDai() external;


  function migrateCSaiToDDai() external;


  function migrateCDaiToDDai() external;


  function migrateCUSDCToDUSDC() external;


  function getBalances() external view returns (
    uint256 daiBalance,
    uint256 usdcBalance,
    uint256 etherBalance,
    uint256 dDaiUnderlyingDaiBalance,
    uint256 dUsdcUnderlyingUsdcBalance,
    uint256 dEtherUnderlyingEtherBalance // always returns zero
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


interface DharmaSmartWalletImplementationV8Interface {

  function tradeEthForDaiAndMintDDai(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData);


  function getNextEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);


  function getEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID);

}


interface ERC20Interface {

  function transfer(address recipient, uint256 amount) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);


  function balanceOf(address account) external view returns (uint256);

  function allowance(
    address owner, address spender
  ) external view returns (uint256);

}


interface ERC1271Interface {

  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue);

}


interface CTokenInterface {

  function redeem(uint256 redeemAmount) external returns (uint256 err);

  function transfer(address recipient, uint256 value) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);


  function balanceOf(address account) external view returns (uint256 balance);

  function allowance(address owner, address spender) external view returns (uint256);

}


interface DTokenInterface {

  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);

  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);

  function redeemUnderlying(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);


  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);


  function balanceOfUnderlying(address account) external view returns (uint256 underlyingBalance);

}


interface USDCV1Interface {

  function isBlacklisted(address _account) external view returns (bool);

  function paused() external view returns (bool);

}


interface DharmaKeyRegistryInterface {

  function getKey() external view returns (address key);

}


interface DharmaEscapeHatchRegistryInterface {

  function setEscapeHatch(address newEscapeHatch) external;


  function removeEscapeHatch() external;


  function permanentlyDisableEscapeHatch() external;


  function getEscapeHatch() external view returns (
    bool exists, address escapeHatch
  );

}


interface SaiToDaiMigratorInterface {

  function swapSaiToDai(uint256 balance) external;

}


interface TradeHelperInterface {

  function tradeEthForDai(
    uint256 daiExpected, address target, bytes calldata data
  ) external payable returns (uint256 daiReceived);

}


interface RevertReasonHelperInterface {

  function reason(uint256 code) external pure returns (string memory);

}


interface EtherizedInterface {

  function triggerEtherTransfer(
    address payable target, uint256 value
  ) external returns (bool success);

}


library Address {

  function isContract(address account) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}


library ECDSA {

  function recover(
    bytes32 hash, bytes memory signature
  ) internal pure returns (address) {

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


contract Etherized is EtherizedInterface {

  address private constant _ETHERIZER = address(
    0x723B51b72Ae89A3d0c2a2760f0458307a1Baa191 
  );
  
  function triggerEtherTransfer(
    address payable target, uint256 amount
  ) external returns (bool success) {

    require(msg.sender == _ETHERIZER, "Etherized: only callable by Etherizer");
    (success, ) = target.call.value(amount)("");
    if (!success) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }
}


contract DharmaSmartWalletImplementationV9 is
  DharmaSmartWalletImplementationV1Interface,
  DharmaSmartWalletImplementationV3Interface,
  DharmaSmartWalletImplementationV4Interface,
  DharmaSmartWalletImplementationV7Interface,
  DharmaSmartWalletImplementationV8Interface,
  ERC1271Interface,
  Etherized {

  using Address for address;
  using ECDSA for bytes32;

  address private _userSigningKey;

  uint256 private _nonce;

  bytes4 internal _selfCallContext;


  uint256 internal constant _DHARMA_SMART_WALLET_VERSION = 9;

  DharmaKeyRegistryInterface internal constant _DHARMA_KEY_REGISTRY = (
    DharmaKeyRegistryInterface(0x000000000D38df53b45C5733c7b34000dE0BDF52)
  );

  address internal constant _ACCOUNT_RECOVERY_MANAGER = address(
    0x0000000000DfEd903aD76996FC07BF89C0127B1E
  );

  DharmaEscapeHatchRegistryInterface internal constant _ESCAPE_HATCH_REGISTRY = (
    DharmaEscapeHatchRegistryInterface(0x00000000005280B515004B998a944630B6C663f8)
  );

  DTokenInterface internal constant _DDAI = DTokenInterface(
    0x00000000001876eB1444c986fD502e618c587430 // mainnet
  );

  DTokenInterface internal constant _DUSDC = DTokenInterface(
    0x00000000008943c65cAf789FFFCF953bE156f6f8 // mainnet
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F // mainnet
  );

  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );

  ERC20Interface internal constant _SAI = ERC20Interface(
    0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359 // mainnet
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

  SaiToDaiMigratorInterface internal constant _MIGRATOR = SaiToDaiMigratorInterface(
    0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849 // mainnet
  );
  
  TradeHelperInterface internal constant _TRADE_HELPER = TradeHelperInterface(
    0x421816CDFe2073945173c0c35799ec21261fB399
  );

  RevertReasonHelperInterface internal constant _REVERT_REASON_HELPER = (
    RevertReasonHelperInterface(0x9C0ccB765D3f5035f8b5Dd30fE375d5F4997D8E4)
  );

  uint256 internal constant _COMPOUND_SUCCESS = 0;

  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);

  uint256 private constant _JUST_UNDER_ONE_1000th_DAI = 999999999999999;
  uint256 private constant _JUST_UNDER_ONE_1000th_USDC = 999;

  uint256 private constant _ETH_TRANSFER_GAS = 4999;

  function () external payable {}

  function initialize(address userSigningKey) external {

    assembly { if extcodesize(address) { revert(0, 0) } }

    _setUserSigningKey(userSigningKey);

    if (_setFullApproval(AssetType.DAI)) {
      uint256 daiBalance = _DAI.balanceOf(address(this));

      _depositDharmaToken(AssetType.DAI, daiBalance);
    }

    if (_setFullApproval(AssetType.USDC)) {
      uint256 usdcBalance = _USDC.balanceOf(address(this));

      _depositDharmaToken(AssetType.USDC, usdcBalance);
    }
  }

  function repayAndDeposit() external {

    uint256 daiBalance = _DAI.balanceOf(address(this));

    if (daiBalance > 0) {
      uint256 daiAllowance = _DAI.allowance(address(this), address(_DDAI));
      if (daiAllowance < daiBalance) {
        if (_setFullApproval(AssetType.DAI)) {
          _depositDharmaToken(AssetType.DAI, daiBalance);
        }
      } else {
        _depositDharmaToken(AssetType.DAI, daiBalance);
      }
    }

    uint256 usdcBalance = _USDC.balanceOf(address(this));

    if (usdcBalance > 0) {
      uint256 usdcAllowance = _USDC.allowance(address(this), address(_DUSDC));
      if (usdcAllowance < usdcBalance) {
        if (_setFullApproval(AssetType.USDC)) {
          _depositDharmaToken(AssetType.USDC, usdcBalance);
        }
      } else {
        _depositDharmaToken(AssetType.USDC, usdcBalance);
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

    if (amount <= _JUST_UNDER_ONE_1000th_DAI) {
      revert(_revertReason(0));
    }

    if (recipient == address(0)) {
      revert(_revertReason(1));
    }

    _selfCallContext = this.withdrawDai.selector;

    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._withdrawDaiAtomic.selector, amount, recipient
    ));

    if (!ok) {
      emit ExternalError(address(_DAI), _revertReason(2));
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
      _withdrawMaxFromDharmaToken(AssetType.DAI);

      require(_transferMax(_DAI, recipient, false));
      success = true;
    } else {
      if (_withdrawFromDharmaToken(AssetType.DAI, amount)) {
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

    if (amount <= _JUST_UNDER_ONE_1000th_USDC) {
      revert(_revertReason(3));
    }

    if (recipient == address(0)) {
      revert(_revertReason(1));
    }

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
      _withdrawMaxFromDharmaToken(AssetType.USDC);

      require(_transferMax(_USDC, recipient, false));
      success = true;
    } else {
      if (_withdrawFromDharmaToken(AssetType.USDC, amount)) {
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

    if (amount == 0) {
      revert(_revertReason(4));
    }

    if (recipient == address(0)) {
      revert(_revertReason(1));
    }

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

    if (account == address(0)) {
      revert(_revertReason(5));
    }

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

  function tradeEthForDaiAndMintDDai(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas,
    bytes calldata userSignature,
    bytes calldata dharmaSignature
  ) external returns (bool ok, bytes memory returnData) {

    _validateActionAndIncrementNonce(
      ActionType.TradeEthForDai,
      abi.encode(ethToSupply, minimumDaiReceived, target, data),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );

    if (minimumDaiReceived <= _JUST_UNDER_ONE_1000th_DAI) {
      revert(_revertReason(31));
    }

    _selfCallContext = this.tradeEthForDaiAndMintDDai.selector;

    bytes memory returnData;
    (ok, returnData) = address(this).call(abi.encodeWithSelector(
      this._tradeEthForDaiAndMintDDaiAtomic.selector,
      ethToSupply, minimumDaiReceived, target, data
    ));

    if (!ok) {
      emit ExternalError(
        address(_TRADE_HELPER), _decodeRevertReason(returnData)
      );
    }
  }
  
  function _tradeEthForDaiAndMintDDaiAtomic(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data
  ) external returns (bool ok, bytes memory returnData) {

    _enforceSelfCallFrom(this.tradeEthForDaiAndMintDDai.selector);
    
    uint256 daiReceived = _TRADE_HELPER.tradeEthForDai.value(ethToSupply)(
      minimumDaiReceived, target, data
    );
    
    if (daiReceived < minimumDaiReceived) {
      revert(_revertReason(32));
    }
    
    _depositDharmaToken(AssetType.DAI, daiReceived);
  }

  function escape() external {

    (bool exists, address escapeHatch) = _ESCAPE_HATCH_REGISTRY.getEscapeHatch();

    if (!exists) {
      revert(_revertReason(6));
    }

    if (msg.sender != escapeHatch) {
      revert(_revertReason(7));
    }

    _withdrawMaxFromDharmaToken(AssetType.DAI);

    _withdrawMaxFromDharmaToken(AssetType.USDC);

    _transferMax(_DAI, msg.sender, true);

    _transferMax(_USDC, msg.sender, true);

    _transferMax(ERC20Interface(address(_CSAI)), msg.sender, true);

    _transferMax(ERC20Interface(address(_CDAI)), msg.sender, true);

    _transferMax(ERC20Interface(address(_CUSDC)), msg.sender, true);

    _transferMax(ERC20Interface(address(_DDAI)), msg.sender, true);

    _transferMax(ERC20Interface(address(_DUSDC)), msg.sender, true);

    uint256 balance = address(this).balance;
    if (balance > 0) {
      _transferETH(msg.sender, balance);
    }

    emit Escaped();
  }

  function recover(address newUserSigningKey) external {

    if (msg.sender != _ACCOUNT_RECOVERY_MANAGER) {
      revert(_revertReason(8));
    }

    _nonce++;

    _setUserSigningKey(newUserSigningKey);
  }

  function migrateSaiToDai() external {

    _swapSaiForDai(_SAI.balanceOf(address(this)));
  }

  function migrateCSaiToDDai() external {

    revert();
  }

  function migrateCDaiToDDai() external {

     _migrateCTokenToDToken(AssetType.DAI);
  }

  function migrateCUSDCToDUSDC() external {

     _migrateCTokenToDToken(AssetType.USDC);
  }

  function getBalances() external view returns (
    uint256 daiBalance,
    uint256 usdcBalance,
    uint256 etherBalance,
    uint256 dDaiUnderlyingDaiBalance,
    uint256 dUsdcUnderlyingUsdcBalance,
    uint256 dEtherUnderlyingEtherBalance // always returns 0
  ) {

    daiBalance = _DAI.balanceOf(address(this));
    usdcBalance = _USDC.balanceOf(address(this));
    etherBalance = address(this).balance;
    dDaiUnderlyingDaiBalance = _DDAI.balanceOfUnderlying(address(this));
    dUsdcUnderlyingUsdcBalance = _DUSDC.balanceOfUnderlying(address(this));
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

  function getNextEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {

    actionID = _getActionID(
      ActionType.TradeEthForDai,
      abi.encode(ethToSupply, minimumDaiReceived, target, data),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function getEthForDaiActionID(
    uint256 ethToSupply,
    uint256 minimumDaiReceived,
    address target,
    bytes calldata data,
    uint256 nonce,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {

    actionID = _getActionID(
      ActionType.TradeEthForDai,
      abi.encode(ethToSupply, minimumDaiReceived, target, data),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function isValidSignature(
    bytes calldata data, bytes calldata signatures
  ) external view returns (bytes4 magicValue) {

    bytes32 digest;
    bytes memory context;

    if (data.length == 32) {
      digest = abi.decode(data, (bytes32));
    } else {
      if (data.length < 64) {
        revert(_revertReason(30));
      }
      (digest, context) = abi.decode(data, (bytes32, bytes));
    }

    if (signatures.length != 130) {
      revert(_revertReason(11));
    }
    bytes memory signaturesInMemory = signatures;
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signaturesInMemory, 0x20))
      s := mload(add(signaturesInMemory, 0x40))
      v := byte(0, mload(add(signaturesInMemory, 0x60)))
    }
    bytes memory dharmaSignature = abi.encodePacked(r, s, v);

    assembly {
      r := mload(add(signaturesInMemory, 0x61))
      s := mload(add(signaturesInMemory, 0x81))
      v := byte(0, mload(add(signaturesInMemory, 0xa1)))
    }
    bytes memory userSignature = abi.encodePacked(r, s, v);

    if (
      !_validateUserSignature(
        digest,
        ActionType.SignatureVerification,
        context,
        _userSigningKey,
        userSignature
      )
    ) {
      revert(_revertReason(12));
    }

    if (_getDharmaSigningKey() != digest.recover(dharmaSignature)) {
      revert(_revertReason(13));
    }

    magicValue = _ERC_1271_MAGIC_VALUE;
  }

  function getVersion() external pure returns (uint256 version) {

    version = _DHARMA_SMART_WALLET_VERSION;
  }

  function executeActionWithAtomicBatchCalls(
    Call[] memory calls,
    uint256 minimumActionGas,
    bytes memory userSignature,
    bytes memory dharmaSignature
  ) public returns (bool[] memory ok, bytes[] memory returnData) {

    for (uint256 i = 0; i < calls.length; i++) {
      _ensureValidGenericCallTarget(calls[i].to);
    }

    (bytes32 actionID, uint256 nonce) = _validateActionAndIncrementNonce(
      ActionType.GenericAtomicBatch,
      abi.encode(calls),
      minimumActionGas,
      userSignature,
      dharmaSignature
    );


    ok = new bool[](calls.length);
    returnData = new bytes[](calls.length);

    _selfCallContext = this.executeActionWithAtomicBatchCalls.selector;

    (bool externalOk, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._executeActionWithAtomicBatchCallsAtomic.selector, calls
      )
    );

    CallReturn[] memory callResults = abi.decode(rawCallResults, (CallReturn[]));
    for (uint256 i = 0; i < callResults.length; i++) {
      Call memory currentCall = calls[i];

      ok[i] = callResults[i].ok;
      returnData[i] = callResults[i].returnData;

      if (callResults[i].ok) {
        emit CallSuccess(
          actionID,
          !externalOk, // If another call failed this will have been rolled back
          nonce,
          currentCall.to,
          currentCall.data,
          callResults[i].returnData
        );
      } else {
        emit CallFailure(
          actionID,
          nonce,
          currentCall.to,
          currentCall.data,
          string(callResults[i].returnData)
        );

        break;
      }
    }
  }

  function _executeActionWithAtomicBatchCallsAtomic(
    Call[] memory calls
  ) public returns (CallReturn[] memory callResults) {

    _enforceSelfCallFrom(this.executeActionWithAtomicBatchCalls.selector);

    bool rollBack = false;
    callResults = new CallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      (bool ok, bytes memory returnData) = calls[i].to.call(calls[i].data);
      callResults[i] = CallReturn({ok: ok, returnData: returnData});
      if (!ok) {
        rollBack = true;
        break;
      }
    }

    if (rollBack) {
      bytes memory callResultsBytes = abi.encode(callResults);
      assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
    }
  }

  function getNextGenericAtomicBatchActionID(
    Call[] memory calls,
    uint256 minimumActionGas
  ) public view returns (bytes32 actionID) {

    actionID = _getActionID(
      ActionType.GenericAtomicBatch,
      abi.encode(calls),
      _nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function getGenericAtomicBatchActionID(
    Call[] memory calls,
    uint256 nonce,
    uint256 minimumActionGas
  ) public view returns (bytes32 actionID) {

    actionID = _getActionID(
      ActionType.GenericAtomicBatch,
      abi.encode(calls),
      nonce,
      minimumActionGas,
      _userSigningKey,
      _getDharmaSigningKey()
    );
  }

  function _setUserSigningKey(address userSigningKey) internal {

    if (userSigningKey == address(0)) {
      revert(_revertReason(14));
    }

    _userSigningKey = userSigningKey;
    emit NewUserSigningKey(userSigningKey);
  }

  function _swapSaiForDai(uint256 saiToSwap) internal returns (uint256 dai) {

    if (saiToSwap > 0) {
      uint256 allowance = _SAI.allowance(address(this), address(_MIGRATOR));
      
      if (saiToSwap > allowance) {
        if (!_SAI.approve(address(_MIGRATOR), uint256(-1))) {
          revert(_revertReason(15));
        }
      }

      uint256 currentDaiBalance = _DAI.balanceOf(address(this));

      _MIGRATOR.swapSaiToDai(saiToSwap);

      dai = _DAI.balanceOf(address(this)) - currentDaiBalance;

      require(dai >= saiToSwap, _revertReason(16));
      if (dai < saiToSwap) {
        revert(_revertReason(16));
      }
    } else {
      dai = 0;
    }
  }

  function _setFullApproval(AssetType asset) internal returns (bool ok) {

    address token;
    address dToken;
    if (asset == AssetType.DAI) {
      token = address(_DAI);
      dToken = address(_DDAI);
    } else {
      token = address(_USDC);
      dToken = address(_DUSDC);
    }

    (ok, ) = address(token).call(abi.encodeWithSelector(
      _DAI.approve.selector, dToken, uint256(-1)
    ));

    if (!ok) {
      if (asset == AssetType.DAI) {
        emit ExternalError(address(_DAI), _revertReason(17));
      } else {
        _diagnoseAndEmitUSDCSpecificError(_USDC.approve.selector);
      }
    }
  }

  function _depositDharmaToken(AssetType asset, uint256 balance) internal {

    if (
      asset == AssetType.DAI && balance > _JUST_UNDER_ONE_1000th_DAI ||
      asset == AssetType.USDC && balance > _JUST_UNDER_ONE_1000th_USDC
    ) {
      address dToken = asset == AssetType.DAI ? address(_DDAI) : address(_DUSDC);

      (bool ok, bytes memory data) = dToken.call(abi.encodeWithSelector(
        _DDAI.mint.selector, balance
      ));

      _checkDharmaTokenInteractionAndLogAnyErrors(
        asset, _DDAI.mint.selector, ok, data
      );
    }
  }

  function _withdrawFromDharmaToken(
    AssetType asset, uint256 balance
  ) internal returns (bool success) {

    address dToken = asset == AssetType.DAI ? address(_DDAI) : address(_DUSDC);

    (bool ok, bytes memory data) = dToken.call(abi.encodeWithSelector(
      _DDAI.redeemUnderlying.selector, balance
    ));

    success = _checkDharmaTokenInteractionAndLogAnyErrors(
      asset, _DDAI.redeemUnderlying.selector, ok, data
    );
  }

  function _withdrawMaxFromDharmaToken(AssetType asset) internal {

    address dToken = asset == AssetType.DAI ? address(_DDAI) : address(_DUSDC);

    ERC20Interface dTokenBalance;
    (bool ok, bytes memory data) = dToken.call(abi.encodeWithSelector(
      dTokenBalance.balanceOf.selector, address(this)
    ));

    uint256 redeemAmount = 0;
    if (ok && data.length == 32) {
      redeemAmount = abi.decode(data, (uint256));
    } else {
      _checkDharmaTokenInteractionAndLogAnyErrors(
        asset, dTokenBalance.balanceOf.selector, ok, data
      );
    }

    if (redeemAmount > 0) {
      (ok, data) = dToken.call(abi.encodeWithSelector(
        _DDAI.redeem.selector, redeemAmount
      ));

      _checkDharmaTokenInteractionAndLogAnyErrors(
        asset, _DDAI.redeem.selector, ok, data
      );
    }
  }

  function _transferMax(
    ERC20Interface token, address recipient, bool suppressRevert
  ) internal returns (bool success) {

    uint256 balance = 0;
    bool balanceCheckWorked = true;
    if (!suppressRevert) {
      balance = token.balanceOf(address(this));
    } else {
      (bool ok, bytes memory data) = address(token).call.gas(gasleft() / 2)(
        abi.encodeWithSelector(token.balanceOf.selector, address(this))
      );

      if (ok && data.length == 32) {
        balance = abi.decode(data, (uint256));
      } else {
        balanceCheckWorked = false;
      }
    }

    if (balance > 0) {
      if (!suppressRevert) {
        success = token.transfer(recipient, balance);
      } else {
        (success, ) = address(token).call.gas(gasleft() / 2)(
          abi.encodeWithSelector(token.transfer.selector, recipient, balance)
        );
      }
    } else {
      success = balanceCheckWorked;
    }
  }

  function _transferETH(
    address payable recipient, uint256 amount
  ) internal returns (bool success) {

    (success, ) = recipient.call.gas(_ETH_TRANSFER_GAS).value(amount)("");
    if (!success) {
      emit ExternalError(recipient, _revertReason(18));
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
      if (gasleft() < minimumActionGas) {
        revert(_revertReason(19));
      }
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
        if (
          !_validateUserSignature(
            messageHash, action, arguments, userSigningKey, userSignature
          )
        ) {
          revert(_revertReason(20));
        }
      }

      if (msg.sender != dharmaSigningKey) {
        if (dharmaSigningKey != messageHash.recover(dharmaSignature)) {
          revert(_revertReason(21));
        }
      }
    } else {
      if (msg.sender != userSigningKey && msg.sender != dharmaSigningKey) {
        if (
          dharmaSigningKey != messageHash.recover(dharmaSignature) &&
          !_validateUserSignature(
            messageHash, action, arguments, userSigningKey, userSignature
          )
        ) {
          revert(_revertReason(22));
        }
      }
    }

    _nonce++;
  }

  function _migrateCTokenToDToken(AssetType token) internal {

    CTokenInterface cToken;
    DTokenInterface dToken;

    if (token == AssetType.DAI) {
      cToken = _CDAI;
      dToken = _DDAI;
    } else {
      cToken = _CUSDC;
      dToken = _DUSDC;
    }

    uint256 balance = cToken.balanceOf(address(this));

    if (balance > 0) {    
      if (cToken.allowance(address(this), address(dToken)) < balance) {
        if (!cToken.approve(address(dToken), uint256(-1))) {
          revert(_revertReason(23));
        }
      }
      
      if (dToken.mintViaCToken(balance) == 0) {
        revert(_revertReason(24));
      }
    }
  }

  function _checkDharmaTokenInteractionAndLogAnyErrors(
    AssetType asset,
    bytes4 functionSelector,
    bool ok,
    bytes memory data
  ) internal returns (bool success) {

    if (ok) {
      if (data.length == 32) {
        uint256 amount = abi.decode(data, (uint256));
        if (amount > 0) {
          success = true;
        } else {
          (address account, string memory name, string memory functionName) = (
            _getDharmaTokenDetails(asset, functionSelector)
          );

          emit ExternalError(
            account,
            string(
              abi.encodePacked(
                name,
                " gave no tokens calling ",
                functionName,
                "."
              )
            )
          );         
        }
      } else {
        (address account, string memory name, string memory functionName) = (
          _getDharmaTokenDetails(asset, functionSelector)
        );

        emit ExternalError(
          account,
          string(
            abi.encodePacked(
              name,
              " gave bad data calling ",
              functionName,
              "."
            )
          )
        );        
      }
      
    } else {
      (address account, string memory name, string memory functionName) = (
        _getDharmaTokenDetails(asset, functionSelector)
      );

      string memory revertReason = _decodeRevertReason(data);

      emit ExternalError(
        account,
        string(
          abi.encodePacked(
            name,
            " reverted calling ",
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
    
    USDCV1Interface usdcNaughty = USDCV1Interface(address(_USDC));

    if (usdcNaughty.isBlacklisted(address(this))) {
      emit ExternalError(
        address(_USDC),
        string(
          abi.encodePacked(
            functionName, " failed - USDC has blacklisted this user."
          )
        )
      );
    } else { // Note: `else if` breaks coverage.
      if (usdcNaughty.paused()) {
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

    if (msg.sender != address(this) || _selfCallContext != selfCallContext) {
      revert(_revertReason(25));
    }

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
        ERC1271Interface(userSigningKey).isValidSignature(
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

  function _getDharmaTokenDetails(
    AssetType asset,
    bytes4 functionSelector
  ) internal pure returns (
    address account,
    string memory name,
    string memory functionName
  ) {

    if (asset == AssetType.DAI) {
      account = address(_DDAI);
      name = "Dharma Dai";
    } else {
      account = address(_DUSDC);
      name = "Dharma USD Coin";
    }

    if (functionSelector == _DDAI.mint.selector) {
      functionName = "mint";
    } else {
      if (functionSelector == ERC20Interface(account).balanceOf.selector) {
        functionName = "balanceOf";
      } else {
        functionName = string(abi.encodePacked(
          "redeem",
          functionSelector == _DDAI.redeem.selector ? "" : "Underlying"
        ));
      }
    }
  }

  function _ensureValidGenericCallTarget(address to) internal view {

    require(to.isContract(), _revertReason(26));
    if (!to.isContract()) {
      revert(_revertReason(26));
    }
    
    if (to == address(this)) {
      revert(_revertReason(27));
    }

    if (to == address(_ESCAPE_HATCH_REGISTRY)) {
      revert(_revertReason(28));
    }
  }

  function _validateCustomActionTypeAndGetArguments(
    ActionType action, uint256 amount, address recipient
  ) internal pure returns (bytes memory arguments) {

    bool validActionType = (
      action == ActionType.Cancel ||
      action == ActionType.SetUserSigningKey ||
      action == ActionType.DAIWithdrawal ||
      action == ActionType.USDCWithdrawal ||
      action == ActionType.ETHWithdrawal ||
      action == ActionType.SetEscapeHatch ||
      action == ActionType.RemoveEscapeHatch ||
      action == ActionType.DisableEscapeHatch
    );
    if (!validActionType) {
      revert(_revertReason(29));
    }

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
      revertReason = _revertReason(uint256(-1));
    }
  }

  function _revertReason(
    uint256 code
  ) internal pure returns (string memory reason) {

    reason = _REVERT_REASON_HELPER.reason(code);
  }
}