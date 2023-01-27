
pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface DTokenInterface {

  event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);

  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);

  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);

  function redeemToCToken(uint256 dTokensToBurn) external returns (uint256 cTokensReceived);

  function redeemUnderlying(uint256 underelyingToReceive) external returns (uint256 dTokensBurned);

  function redeemUnderlyingToCToken(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);

  function transferUnderlying(address recipient, uint256 amount) external returns (bool);

  function transferUnderlyingFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function pullSurplus() external returns (uint256 cTokenSurplus);

  function accrueInterest() external;


  function totalSupplyUnderlying() external view returns (uint256);

  function balanceOfUnderlying(address account) external view returns (uint256 underlyingBalance);

  function getSurplus() external view returns (uint256 cTokenSurplus);

  function getSurplusUnderlying() external view returns (uint256 underlyingSurplus);

  function exchangeRateCurrent() external view returns (uint256 dTokenExchangeRate);

  function supplyRatePerBlock() external view returns (uint256 dTokenInterestRate);

  function getSpreadPerBlock() external view returns (uint256 rateSpread);

  function getVersion() external pure returns (uint256 version);

}


interface CTokenInterface {

  function mint(uint256 mintAmount) external returns (uint256 err);

  function redeem(uint256 redeemAmount) external returns (uint256 err);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);

  function balanceOf(address account) external view returns (uint256 balance);

  function balanceOfUnderlying(address account) external returns (uint256 balance);

  function exchangeRateCurrent() external returns (uint256 exchangeRate);

  function transfer(address recipient, uint256 value) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 value) external returns (bool);

  
  function supplyRatePerBlock() external view returns (uint256 rate);

  function exchangeRateStored() external view returns (uint256 rate);

  function accrualBlockNumber() external view returns (uint256 blockNumber);

}


interface ERC20Interface {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

}


interface SpreadRegistryInterface {

  function getDaiSpreadPerBlock() external view returns (uint256 daiSpreadPerBlock);

}


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
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

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }
}


contract DharmaDaiPrototype1 is ERC20Interface, DTokenInterface {

  using SafeMath for uint256;

  uint256 internal constant _DHARMA_DAI_VERSION = 0;

  string internal constant _NAME = "Dharma Dai (Prototype 1)";
  string internal constant _SYMBOL = "dDai-p1";
  uint8 internal constant _DECIMALS = 8; // to match cDai

  uint256 internal constant _SCALING_FACTOR = 1e18;
  uint256 internal constant _HALF_OF_SCALING_FACTOR = 5e17;
  uint256 internal constant _COMPOUND_SUCCESS = 0;

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 // mainnet
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F // mainnet
  );

  SpreadRegistryInterface internal constant _SPREAD = SpreadRegistryInterface(
    0xA143fD004B3c26f8FAeDeb9224eC03585e63d041
  );

  address internal constant _VAULT = 0x7e4A8391C728fEd9069B2962699AB416628B19Fa;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;

  uint256 private _blockLastUpdated;
  uint256 private _dDaiExchangeRate;
  uint256 private _cDaiExchangeRate;

  constructor() public {
    require(_DAI.approve(address(_CDAI), uint256(-1)));

    _blockLastUpdated = block.number;
    _dDaiExchangeRate = 1e28; // 1 Dai == 1 dDai to start
    _cDaiExchangeRate = _CDAI.exchangeRateCurrent();
  }

  function mint(
    uint256 daiToSupply
  ) external accrues returns (uint256 dDaiMinted) {

    require(
      _DAI.transferFrom(msg.sender, address(this), daiToSupply),
      "Dai transfer failed."
    );

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.mint.selector, daiToSupply
    ));

    _checkCompoundInteraction(_CDAI.mint.selector, ok, data);

    dDaiMinted = (daiToSupply.mul(_SCALING_FACTOR)).div(_dDaiExchangeRate);

    _mint(msg.sender, daiToSupply, dDaiMinted);
  }

  function mintViaCToken(
    uint256 cDaiToSupply
  ) external accrues returns (uint256 dDaiMinted) {

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.transferFrom.selector, msg.sender, address(this), cDaiToSupply
    ));

    _checkCompoundInteraction(_CDAI.transferFrom.selector, ok, data);

    uint256 daiEquivalent = cDaiToSupply.mul(_cDaiExchangeRate) / _SCALING_FACTOR;

    dDaiMinted = (daiEquivalent.mul(_SCALING_FACTOR)).div(_dDaiExchangeRate);

    _mint(msg.sender, daiEquivalent, dDaiMinted);
  }

  function redeem(
    uint256 dDaiToBurn
  ) external accrues returns (uint256 daiReceived) {

    daiReceived = dDaiToBurn.mul(_dDaiExchangeRate) / _SCALING_FACTOR;

    _burn(msg.sender, daiReceived, dDaiToBurn);

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.redeemUnderlying.selector, daiReceived
    ));

    _checkCompoundInteraction(_CDAI.redeemUnderlying.selector, ok, data);

    require(_DAI.transfer(msg.sender, daiReceived), "Dai transfer failed.");
  }

  function redeemToCToken(
    uint256 dDaiToBurn
  ) external accrues returns (uint256 cDaiReceived) {

    uint256 daiEquivalent = dDaiToBurn.mul(_dDaiExchangeRate) / _SCALING_FACTOR;

    cDaiReceived = (daiEquivalent.mul(_SCALING_FACTOR)).div(_cDaiExchangeRate);

    _burn(msg.sender, daiEquivalent, dDaiToBurn);

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.transfer.selector, msg.sender, cDaiReceived
    ));

    _checkCompoundInteraction(_CDAI.transfer.selector, ok, data);
  }

  function redeemUnderlying(
    uint256 daiToReceive
  ) external accrues returns (uint256 dDaiBurned) {

    dDaiBurned = (daiToReceive.mul(_SCALING_FACTOR)).div(_dDaiExchangeRate);

    _burn(msg.sender, daiToReceive, dDaiBurned);

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.redeemUnderlying.selector, daiToReceive
    ));

    _checkCompoundInteraction(_CDAI.redeemUnderlying.selector, ok, data);

    require(_DAI.transfer(msg.sender, daiToReceive), "Dai transfer failed.");
  }

  function redeemUnderlyingToCToken(
    uint256 daiToReceive
  ) external accrues returns (uint256 dDaiBurned) {

    dDaiBurned = (daiToReceive.mul(_SCALING_FACTOR)).div(_dDaiExchangeRate);

    _burn(msg.sender, daiToReceive, dDaiBurned);

    uint256 cDaiToReceive = daiToReceive.mul(_SCALING_FACTOR).div(_cDaiExchangeRate);

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.transfer.selector, msg.sender, cDaiToReceive
    ));

    _checkCompoundInteraction(_CDAI.transfer.selector, ok, data);
  }

  function pullSurplus() external accrues returns (uint256 cDaiSurplus) {

    (, cDaiSurplus) = _getSurplus();

    (bool ok, bytes memory data) = address(_CDAI).call(abi.encodeWithSelector(
      _CDAI.transfer.selector, _VAULT, cDaiSurplus
    ));

    _checkCompoundInteraction(_CDAI.transfer.selector, ok, data);
  }

  function accrueInterest() external accrues {

  }

  function transfer(address recipient, uint256 amount) external returns (bool) {

    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function transferUnderlying(
    address recipient, uint256 amount
  ) external accrues returns (bool) {

    uint256 dDaiAmount = (amount.mul(_SCALING_FACTOR)).div(_dDaiExchangeRate);

    _transfer(msg.sender, recipient, dDaiAmount);
    return true;
  }

  function approve(address spender, uint256 value) external returns (bool) {

    _approve(msg.sender, spender, value);
    return true;
  }

  function transferFrom(
    address sender, address recipient, uint256 amount
  ) external returns (bool) {

    _transfer(sender, recipient, amount);
    uint256 allowance = _allowances[sender][msg.sender];
    if (allowance != uint256(-1)) {
      _approve(sender, msg.sender, allowance.sub(amount));
    }
    return true;
  }

  function transferUnderlyingFrom(
    address sender, address recipient, uint256 amount
  ) external accrues returns (bool) {

    uint256 dDaiAmount = (amount.mul(_SCALING_FACTOR)).div(_dDaiExchangeRate);

    _transfer(sender, recipient, dDaiAmount);
    uint256 allowance = _allowances[sender][msg.sender];
    if (allowance != uint256(-1)) {
      _approve(sender, msg.sender, allowance.sub(dDaiAmount));
    }
    return true;
  }

  function increaseAllowance(
    address spender, uint256 addedValue
  ) external returns (bool) {

    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(
    address spender, uint256 subtractedValue
  ) external returns (bool) {

    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue)
    );
    return true;
  }

  function getSurplus() external view returns (uint256 cDaiSurplus) {

    (, cDaiSurplus) = _getSurplus();
  }

  function getSurplusUnderlying() external view returns (uint256 daiSurplus) {

    (daiSurplus, ) = _getSurplus();
  }

  function accrualBlockNumber() external view returns (uint256 blockNumber) {

    blockNumber = _blockLastUpdated;
  }

  function exchangeRateCurrent() external view returns (uint256 dDaiExchangeRate) {

    (dDaiExchangeRate,,) = _getAccruedInterest();
  }

  function supplyRatePerBlock() external view returns (uint256 dDaiInterestRate) {

    (dDaiInterestRate,) = _getRatePerBlock();
  }

  function getSpreadPerBlock() external view returns (uint256 rateSpread) {

    (uint256 dDaiInterestRate, uint256 cDaiInterestRate) = _getRatePerBlock();
    rateSpread = cDaiInterestRate - dDaiInterestRate;
  }

  function totalSupply() external view returns (uint256) {

    return _totalSupply;
  }

  function totalSupplyUnderlying() external view returns (uint256) {

    (uint256 dDaiExchangeRate,,) = _getAccruedInterest();

    return _totalSupply.mul(dDaiExchangeRate) / _SCALING_FACTOR;
  }

  function balanceOf(address account) external view returns (uint256 dDai) {

    dDai = _balances[account];
  }

  function balanceOfUnderlying(
    address account
  ) external view returns (uint256 daiBalance) {

    (uint256 dDaiExchangeRate,,) = _getAccruedInterest();

    daiBalance = _balances[account].mul(dDaiExchangeRate) / _SCALING_FACTOR;
  }

  function allowance(address owner, address spender) external view returns (uint256) {

    return _allowances[owner][spender];
  }

  function name() external pure returns (string memory) {

    return _NAME;
  }

  function symbol() external pure returns (string memory) {

    return _SYMBOL;
  }

  function decimals() external pure returns (uint8) {

    return _DECIMALS;
  }

  function getVersion() external pure returns (uint256 version) {

    version = _DHARMA_DAI_VERSION;
  }

  function _mint(address account, uint256 exchanged, uint256 amount) internal {

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);

    emit Mint(account, exchanged, amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 exchanged, uint256 amount) internal {

    uint256 balancePriorToBurn = _balances[account];
    require(
      balancePriorToBurn >= amount, "Supplied amount exceeds account balance."
    );

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = balancePriorToBurn - amount; // overflow checked above

    emit Transfer(account, address(0), amount);
    emit Redeem(account, exchanged, amount);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {

    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 value) internal {

    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function _getAccruedInterest() internal view returns (
    uint256 dDaiExchangeRate, uint256 cDaiExchangeRate, bool fullyAccrued
  ) {

    uint256 blockDelta = block.number - _blockLastUpdated;
    fullyAccrued = (blockDelta == 0);

    if (fullyAccrued) {
      dDaiExchangeRate = _dDaiExchangeRate;
      cDaiExchangeRate = _cDaiExchangeRate;
    } else {
      cDaiExchangeRate = _getCurrentExchangeRate();
      uint256 cDaiInterestRate = (
        (cDaiExchangeRate.mul(_SCALING_FACTOR)).div(_cDaiExchangeRate)
      );

      uint256 spreadInterestRate = _pow(
        _SPREAD.getDaiSpreadPerBlock().add(_SCALING_FACTOR), blockDelta
      );

      dDaiExchangeRate = spreadInterestRate >= cDaiInterestRate
        ? _dDaiExchangeRate
        : _dDaiExchangeRate.mul(
          _SCALING_FACTOR.add(cDaiInterestRate - spreadInterestRate)
        ) / _SCALING_FACTOR;
    }
  }

  function _getCurrentExchangeRate() internal view returns (uint256 exchangeRate) {

    uint256 storedExchangeRate = _CDAI.exchangeRateStored();
    uint256 blockDelta = block.number.sub(_CDAI.accrualBlockNumber());

    if (blockDelta == 0) return storedExchangeRate;

    exchangeRate = blockDelta == 0 ? storedExchangeRate : storedExchangeRate.add(
      storedExchangeRate.mul(
        _CDAI.supplyRatePerBlock().mul(blockDelta)
      ) / _SCALING_FACTOR
    );
  }

  function _getSurplus() internal view returns (
    uint256 daiSurplus, uint256 cDaiSurplus
  ) {

    (uint256 dDaiExchangeRate, uint256 cDaiExchangeRate,) = _getAccruedInterest();

    uint256 dDaiUnderlying = (
      _totalSupply.mul(dDaiExchangeRate) / _SCALING_FACTOR
    ).add(1);

    daiSurplus = (
      _CDAI.balanceOf(address(this)).mul(cDaiExchangeRate) / _SCALING_FACTOR
    ).sub(dDaiUnderlying);

    cDaiSurplus = (daiSurplus.mul(_SCALING_FACTOR)).div(cDaiExchangeRate);
  }

  function _getRatePerBlock() internal view returns (
    uint256 dDaiSupplyRate, uint256 cDaiSupplyRate
  ) {

    uint256 spread = _SPREAD.getDaiSpreadPerBlock();
    cDaiSupplyRate = _CDAI.supplyRatePerBlock();
    dDaiSupplyRate = (spread < cDaiSupplyRate ? cDaiSupplyRate - spread : 0);
  }

  function _pow(uint256 floatIn, uint256 power) internal pure returns (uint256 floatOut) {

    floatOut = power % 2 != 0 ? floatIn : _SCALING_FACTOR;

    for (power /= 2; power != 0; power /= 2) {
      floatIn = (floatIn.mul(floatIn)).add(_HALF_OF_SCALING_FACTOR) / _SCALING_FACTOR;

      if (power % 2 != 0) {
        floatOut = (floatIn.mul(floatOut)).add(_HALF_OF_SCALING_FACTOR) / _SCALING_FACTOR;
      }
    }
  }

  function _checkCompoundInteraction(
    bytes4 functionSelector, bool ok, bytes memory data
  ) internal pure {

    if (ok) {
      if (
        functionSelector == _CDAI.transfer.selector ||
        functionSelector == _CDAI.transferFrom.selector
      ) {
        require(
          abi.decode(data, (bool)),
          string(
            abi.encodePacked(
              "Compound cDai contract returned false on calling ",
              _getFunctionName(functionSelector),
              "."
            )
          )
        );
      } else {
        uint256 compoundError = abi.decode(data, (uint256)); // throw on no data
        if (compoundError != _COMPOUND_SUCCESS) {
          revert(
            string(
              abi.encodePacked(
                "Compound cDai contract returned error code ",
                uint8((compoundError / 10) + 48),
                uint8((compoundError % 10) + 48),
                " on calling ",
                _getFunctionName(functionSelector),
                "."
              )
            )
          );
        }
      }
    } else {
      revert(
        string(
          abi.encodePacked(
            "Compound cDai contract reverted while attempting to call ",
            _getFunctionName(functionSelector),
            ": ",
            _decodeRevertReason(data)
          )
        )
      );
    }
  }

  function _getFunctionName(
    bytes4 functionSelector
  ) internal pure returns (string memory functionName) {

    if (functionSelector == _CDAI.mint.selector) {
      functionName = 'mint';
    } else if (functionSelector == _CDAI.redeemUnderlying.selector) {
      functionName = 'redeemUnderlying';
    } else if (functionSelector == _CDAI.transferFrom.selector) {
      functionName = 'transferFrom';
    } else if (functionSelector == _CDAI.transfer.selector) {
      functionName = 'transfer';
    } else {
      functionName = 'an unknown function';
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

  modifier accrues() {

    (
      uint256 dDaiExchangeRate, uint256 cDaiExchangeRate, bool fullyAccrued
    ) = _getAccruedInterest();

    if (!fullyAccrued) {
      _blockLastUpdated = block.number;
      _dDaiExchangeRate = dDaiExchangeRate;
      _cDaiExchangeRate = cDaiExchangeRate;
    }

    _;
  }
}