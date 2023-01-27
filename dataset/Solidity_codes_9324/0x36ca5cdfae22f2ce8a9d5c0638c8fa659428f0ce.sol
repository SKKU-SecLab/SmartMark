
pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface DTokenInterface {

  event Mint(address minter, uint256 mintAmount, uint256 mintDTokens);
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemDTokens);
  event Accrue(uint256 dTokenExchangeRate, uint256 cTokenExchangeRate);
  event CollectSurplus(uint256 surplusAmount, uint256 surplusCTokens);

  struct AccrualIndex {
    uint112 dTokenExchangeRate;
    uint112 cTokenExchangeRate;
    uint32 block;
  }

  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);

  function redeem(uint256 dTokensToBurn) external returns (uint256 underlyingReceived);

  function redeemUnderlying(uint256 underelyingToReceive) external returns (uint256 dTokensBurned);

  function pullSurplus() external returns (uint256 cTokenSurplus);


  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);

  function redeemToCToken(uint256 dTokensToBurn) external returns (uint256 cTokensReceived);

  function redeemUnderlyingToCToken(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);

  function accrueInterest() external;

  function transferUnderlying(
    address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success);

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
    bytes4 functionSelector, bytes calldata arguments, uint256 expiration, bytes32 salt
  ) external view returns (bytes32 digest, bool valid);

  function totalSupplyUnderlying() external view returns (uint256);

  function balanceOfUnderlying(address account) external view returns (uint256 underlyingBalance);

  function exchangeRateCurrent() external view returns (uint256 dTokenExchangeRate);

  function supplyRatePerBlock() external view returns (uint256 dTokenInterestRate);

  function accrualBlockNumber() external view returns (uint256 blockNumber);

  function getSurplus() external view returns (uint256 cTokenSurplus);

  function getSurplusUnderlying() external view returns (uint256 underlyingSurplus);

  function getSpreadPerBlock() external view returns (uint256 rateSpread);

  function getVersion() external pure returns (uint256 version);

  function getCToken() external pure returns (address cToken);

  function getUnderlying() external pure returns (address underlying);

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


interface ERC1271Interface {

  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue);

}


interface CTokenInterface {

  function mint(uint256 mintAmount) external returns (uint256 err);

  function redeem(uint256 redeemAmount) external returns (uint256 err);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256 err);

  function accrueInterest() external returns (uint256 err);

  function transfer(address recipient, uint256 value) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 value) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);

  function balanceOfUnderlying(address account) external returns (uint256 balance);

  function exchangeRateCurrent() external returns (uint256 exchangeRate);


  function getCash() external view returns (uint256);

  function totalSupply() external view returns (uint256 supply);

  function totalBorrows() external view returns (uint256 borrows);

  function totalReserves() external view returns (uint256 reserves);

  function interestRateModel() external view returns (address model);

  function reserveFactorMantissa() external view returns (uint256 factor);

  function supplyRatePerBlock() external view returns (uint256 rate);

  function exchangeRateStored() external view returns (uint256 rate);

  function accrualBlockNumber() external view returns (uint256 blockNumber);

  function balanceOf(address account) external view returns (uint256 balance);

  function allowance(address owner, address spender) external view returns (uint256);

}


interface CDaiInterestRateModelInterface {

  function getBorrowRate(
    uint256 cash, uint256 borrows, uint256 reserves
  ) external view returns (uint256 borrowRate);


  function getSupplyRate(
    uint256 cash, uint256 borrows, uint256 reserves, uint256 reserveFactor
  ) external view returns (uint256 supplyRate);

}


interface PotInterface {

  function chi() external view returns (uint256);

  function dsr() external view returns (uint256);

  function rho() external view returns (uint256);

  function pie(address account) external view returns (uint256);

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

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract DharmaTokenOverrides {

  function _getCurrentCTokenRates() internal view returns (
    uint256 exchangeRate, uint256 supplyRate
  );


  function _getUnderlyingName() internal pure returns (string memory underlyingName);


  function _getUnderlying() internal pure returns (address underlying);


  function _getCTokenSymbol() internal pure returns (string memory cTokenSymbol);


  function _getCToken() internal pure returns (address cToken);


  function _getDTokenName() internal pure returns (string memory dTokenName);


  function _getDTokenSymbol() internal pure returns (string memory dTokenSymbol);


  function _getVault() internal pure returns (address vault);

}


contract DharmaTokenHelpers is DharmaTokenOverrides {

  using SafeMath for uint256;

  uint8 internal constant _DECIMALS = 8; // matches cToken decimals
  uint256 internal constant _SCALING_FACTOR = 1e18;
  uint256 internal constant _SCALING_FACTOR_MINUS_ONE = 999999999999999999;
  uint256 internal constant _HALF_OF_SCALING_FACTOR = 5e17;
  uint256 internal constant _COMPOUND_SUCCESS = 0;
  uint256 internal constant _MAX_UINT_112 = 5192296858534827628530496329220095;
  uint256 internal constant _MAX_UNMALLEABLE_S = (
    0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
  );

  function _checkCompoundInteraction(
    bytes4 functionSelector, bool ok, bytes memory data
  ) internal pure {

    CTokenInterface cToken;
    if (ok) {
      if (
        functionSelector == cToken.transfer.selector ||
        functionSelector == cToken.transferFrom.selector
      ) {
        require(
          abi.decode(data, (bool)), string(
            abi.encodePacked(
              "Compound ",
              _getCTokenSymbol(),
              " contract returned false on calling ",
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
                "Compound ",
                _getCTokenSymbol(),
                " contract returned error code ",
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
            "Compound ",
            _getCTokenSymbol(),
            " contract reverted while attempting to call ",
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

    CTokenInterface cToken;
    if (functionSelector == cToken.mint.selector) {
      functionName = "mint";
    } else if (functionSelector == cToken.redeem.selector) {
      functionName = "redeem";
    } else if (functionSelector == cToken.redeemUnderlying.selector) {
      functionName = "redeemUnderlying";
    } else if (functionSelector == cToken.transferFrom.selector) {
      functionName = "transferFrom";
    } else if (functionSelector == cToken.transfer.selector) {
      functionName = "transfer";
    } else if (functionSelector == cToken.accrueInterest.selector) {
      functionName = "accrueInterest";
    } else {
      functionName = "an unknown function";
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

  function _getTransferFailureMessage() internal pure returns (
    string memory message
  ) {

    message = string(
      abi.encodePacked(_getUnderlyingName(), " transfer failed.")
    );
  }

  function _safeUint112(uint256 input) internal pure returns (uint112 output) {

    require(input <= _MAX_UINT_112, "Overflow on conversion to uint112.");
    output = uint112(input);
  }

  function _fromUnderlying(
    uint256 underlying, uint256 exchangeRate, bool roundUp
  ) internal pure returns (uint256 amount) {

    if (roundUp) {
      amount = (
        (underlying.mul(_SCALING_FACTOR)).add(exchangeRate.sub(1))
      ).div(exchangeRate);
    } else {
      amount = (underlying.mul(_SCALING_FACTOR)).div(exchangeRate);
    }
  }

  function _toUnderlying(
    uint256 amount, uint256 exchangeRate, bool roundUp
  ) internal pure returns (uint256 underlying) {

    if (roundUp) {
      underlying = (
        (amount.mul(exchangeRate).add(_SCALING_FACTOR_MINUS_ONE)
      ) / _SCALING_FACTOR);
    } else {
      underlying = amount.mul(exchangeRate) / _SCALING_FACTOR;
    }
  }

  function _fromUnderlyingAndBack(
    uint256 underlying, uint256 exchangeRate, bool roundUpOne, bool roundUpTwo
  ) internal pure returns (uint256 amount, uint256 adjustedUnderlying) {

    amount = _fromUnderlying(underlying, exchangeRate, roundUpOne);
    adjustedUnderlying = _toUnderlying(amount, exchangeRate, roundUpTwo);
  }
}


contract DharmaTokenV2 is ERC20Interface, DTokenInterface, DharmaTokenHelpers {

  uint256 private constant _DTOKEN_VERSION = 2;

  ERC20Interface internal constant _COMP = ERC20Interface(
    0xc00e94Cb662C3520282E6f5717214004A7f26888 // mainnet
  );

  AccrualIndex private _accrualIndex;

  uint256 private _totalSupply;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (bytes32 => bool) private _executedMetaTxs;
  
  bool exchangeRateFrozen; // initially false

  function mint(
    uint256 underlyingToSupply
  ) external returns (uint256 dTokensMinted) {

    revert("Minting is no longer supported.");
  }

  function mintViaCToken(
    uint256 cTokensToSupply
  ) external returns (uint256 dTokensMinted) {

    revert("Minting is no longer supported.");
  }

  function redeem(
    uint256 dTokensToBurn
  ) external returns (uint256 underlyingReceived) {

    require(exchangeRateFrozen, "Call `pullSurplus()` to freeze exchange rate first.");

    ERC20Interface underlying = ERC20Interface(_getUnderlying());

    require(dTokensToBurn > 0, "No funds specified to redeem.");
    
    uint256 originalSupply = _totalSupply;
    uint256 underlyingBalance = underlying.balanceOf(address(this));
    uint256 compBalance = _COMP.balanceOf(address(this));

    underlyingReceived = underlyingBalance.mul(dTokensToBurn) / originalSupply;
    uint256 compReceived = compBalance.mul(dTokensToBurn) / originalSupply;
    require(
      underlyingReceived.add(compReceived) > 0,
      "Supplied dTokens are insufficient to redeem."
    );
    
    _burn(msg.sender, underlyingReceived, dTokensToBurn);
    
    if (underlyingReceived > 0) {
      require(
        underlying.transfer(msg.sender, underlyingReceived),
        _getTransferFailureMessage()
      );
    }

    if (compReceived > 0) {
      require(
        _COMP.transfer(msg.sender, compReceived),
        "COMP transfer out failed."
      );
    }
  }

  function redeemToCToken(
    uint256 dTokensToBurn
  ) external returns (uint256 cTokensReceived) {

    revert("Redeeming to cTokens is no longer supported.");
  }

  function redeemUnderlying(
    uint256 underlyingToReceive
  ) external returns (uint256 dTokensBurned) {

    require(exchangeRateFrozen, "Call `pullSurplus()` to freeze exchange rate first.");

    ERC20Interface underlying = ERC20Interface(_getUnderlying());

    (uint256 dTokenExchangeRate, ) = _accrue(false);

    dTokensBurned = _fromUnderlying(
      underlyingToReceive, dTokenExchangeRate, true
    );

    uint256 dTokensForCOMP = _fromUnderlying(
      underlyingToReceive, dTokenExchangeRate, false
    );
    
    uint256 originalSupply = _totalSupply;
    uint256 compBalance = _COMP.balanceOf(address(this));

    uint256 compReceived = compBalance.mul(dTokensForCOMP) / originalSupply;
    require(
      underlyingToReceive.add(compReceived) > 0,
      "Supplied amount is insufficient to redeem."
    );
    
    _burn(msg.sender, underlyingToReceive, dTokensBurned);
    
    if (underlyingToReceive > 0) {
      require(
        underlying.transfer(msg.sender, underlyingToReceive),
        _getTransferFailureMessage()
      );
    }

    if (compReceived > 0) {
      require(
        _COMP.transfer(msg.sender, compReceived),
        "COMP transfer out failed."
      );
    }
  }

  function redeemUnderlyingToCToken(
    uint256 underlyingToReceive
  ) external returns (uint256 dTokensBurned) {

    revert("Redeeming to cTokens is no longer supported.");
  }

  function pullSurplus() external returns (uint256 cTokenSurplus) {

    require(!exchangeRateFrozen, "No surplus left to pull.");

    CTokenInterface cToken = CTokenInterface(_getCToken());

    (bool ok, bytes memory data) = address(cToken).call(abi.encodeWithSelector(
      cToken.accrueInterest.selector
    ));
    _checkCompoundInteraction(cToken.accrueInterest.selector, ok, data);

    _accrue(false);

    uint256 underlyingSurplus;
    (underlyingSurplus, cTokenSurplus) = _getSurplus();

    (ok, data) = address(cToken).call(abi.encodeWithSelector(
      cToken.transfer.selector, _getVault(), cTokenSurplus
    ));
    _checkCompoundInteraction(cToken.transfer.selector, ok, data);

    emit CollectSurplus(underlyingSurplus, cTokenSurplus);
    
    exchangeRateFrozen = true;
    
    (ok, data) = address(cToken).call(abi.encodeWithSelector(
      cToken.redeem.selector, cToken.balanceOf(address(this))
    ));
    _checkCompoundInteraction(cToken.redeem.selector, ok, data);
  }

  function accrueInterest() external {

    revert("Interest accrual is longer supported.");
  }

  function transfer(
    address recipient, uint256 amount
  ) external returns (bool success) {

    _transfer(msg.sender, recipient, amount);
    success = true;
  }

  function transferUnderlying(
    address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success) {

    (uint256 dTokenExchangeRate, ) = _accrue(true);

    uint256 dTokenAmount = _fromUnderlying(
      underlyingEquivalentAmount, dTokenExchangeRate, true
    );

    _transfer(msg.sender, recipient, dTokenAmount);
    success = true;
  }

  function approve(
    address spender, uint256 value
  ) external returns (bool success) {

    _approve(msg.sender, spender, value);
    success = true;
  }

  function transferFrom(
    address sender, address recipient, uint256 amount
  ) external returns (bool success) {

    _transferFrom(sender, recipient, amount);
    success = true;
  }

  function transferUnderlyingFrom(
    address sender, address recipient, uint256 underlyingEquivalentAmount
  ) external returns (bool success) {

    (uint256 dTokenExchangeRate, ) = _accrue(true);

    uint256 dTokenAmount = _fromUnderlying(
      underlyingEquivalentAmount, dTokenExchangeRate, true
    );

    _transferFrom(sender, recipient, dTokenAmount);
    success = true;
  }

  function increaseAllowance(
    address spender, uint256 addedValue
  ) external returns (bool success) {

    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].add(addedValue)
    );
    success = true;
  }

  function decreaseAllowance(
    address spender, uint256 subtractedValue
  ) external returns (bool success) {

    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue)
    );
    success = true;
  }

  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external returns (bool success) {

    require(expiration == 0 || now <= expiration, "Meta-transaction expired.");

    bytes memory context = abi.encodePacked(
      address(this),
      this.modifyAllowanceViaMetaTransaction.selector,
      expiration,
      salt,
      abi.encode(owner, spender, value, increase)
    );
    bytes32 messageHash = keccak256(context);

    require(!_executedMetaTxs[messageHash], "Meta-transaction already used.");
    _executedMetaTxs[messageHash] = true;

    bytes32 digest = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    );

    uint256 currentAllowance = _allowances[owner][spender];
    uint256 newAllowance = (
      increase ? currentAllowance.add(value) : currentAllowance.sub(value)
    );

    if (_isContract(owner)) {
      bytes memory data = abi.encode(digest, context);
      bytes4 magic = ERC1271Interface(owner).isValidSignature(data, signatures);
      require(magic == bytes4(0x20c13b0b), "Invalid signatures.");
    } else {
      _verifyRecover(owner, digest, signatures);
    }

    _approve(owner, spender, newAllowance);
    success = true;
  }

  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 messageHash, bool valid) {

    messageHash = keccak256(
      abi.encodePacked(
        address(this), functionSelector, expiration, salt, arguments
      )
    );

    valid = (
      !_executedMetaTxs[messageHash] && (expiration == 0 || now <= expiration)
    );
  }

  function totalSupply() external view returns (uint256 dTokenTotalSupply) {

    dTokenTotalSupply = _totalSupply;
  }

  function totalSupplyUnderlying() external view returns (
    uint256 dTokenTotalSupplyInUnderlying
  ) {

    (uint256 dTokenExchangeRate, ,) = _getExchangeRates(true);

    dTokenTotalSupplyInUnderlying = _toUnderlying(
      _totalSupply, dTokenExchangeRate, false
    );
  }

  function balanceOf(address account) external view returns (uint256 dTokens) {

    dTokens = _balances[account];
  }

  function balanceOfUnderlying(
    address account
  ) external view returns (uint256 underlyingBalance) {

    (uint256 dTokenExchangeRate, ,) = _getExchangeRates(true);

    underlyingBalance = _toUnderlying(
      _balances[account], dTokenExchangeRate, false
    );
  }

  function allowance(
    address owner, address spender
  ) external view returns (uint256 dTokenAllowance) {

    dTokenAllowance = _allowances[owner][spender];
  }

  function exchangeRateCurrent() external view returns (
    uint256 dTokenExchangeRate
  ) {

    (dTokenExchangeRate, ,) = _getExchangeRates(true);
  }

  function supplyRatePerBlock() external view returns (
    uint256 dTokenInterestRate
  ) {

    (dTokenInterestRate,) = _getRatePerBlock();
  }

  function accrualBlockNumber() external view returns (uint256 blockNumber) {

    blockNumber = _accrualIndex.block;
  }

  function getSurplus() external view returns (uint256 cTokenSurplus) {

    (, cTokenSurplus) = _getSurplus();
  }

  function getSurplusUnderlying() external view returns (
    uint256 underlyingSurplus
  ) {

    (underlyingSurplus, ) = _getSurplus();
  }

  function getSpreadPerBlock() external view returns (uint256 rateSpread) {

    (
      uint256 dTokenInterestRate, uint256 cTokenInterestRate
    ) = _getRatePerBlock();
    rateSpread = cTokenInterestRate.sub(dTokenInterestRate);
  }

  function name() external pure returns (string memory dTokenName) {

    dTokenName = _getDTokenName();
  }

  function symbol() external pure returns (string memory dTokenSymbol) {

    dTokenSymbol = _getDTokenSymbol();
  }

  function decimals() external pure returns (uint8 dTokenDecimals) {

    dTokenDecimals = _DECIMALS;
  }

  function getVersion() external pure returns (uint256 version) {

    version = _DTOKEN_VERSION;
  }

  function getCToken() external pure returns (address cToken) {

    cToken = _getCToken();
  }

  function getUnderlying() external pure returns (address underlying) {

    underlying = _getUnderlying();
  }

  function _accrue(bool compute) private returns (
    uint256 dTokenExchangeRate, uint256 cTokenExchangeRate
  ) {

    bool alreadyAccrued;
    (
      dTokenExchangeRate, cTokenExchangeRate, alreadyAccrued
    ) = _getExchangeRates(compute);

    if (!alreadyAccrued) {
      AccrualIndex storage accrualIndex = _accrualIndex;
      accrualIndex.dTokenExchangeRate = _safeUint112(dTokenExchangeRate);
      accrualIndex.cTokenExchangeRate = _safeUint112(cTokenExchangeRate);
      accrualIndex.block = uint32(block.number);
      emit Accrue(dTokenExchangeRate, cTokenExchangeRate);
    }
  }

  function _burn(address account, uint256 exchanged, uint256 amount) private {

    require(
      exchanged > 0 && amount > 0, "Redeem failed: insufficient funds supplied."
    );

    uint256 balancePriorToBurn = _balances[account];
    require(
      balancePriorToBurn >= amount, "Supplied amount exceeds account balance."
    );

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = balancePriorToBurn - amount; // overflow checked above

    emit Transfer(account, address(0), amount);
    emit Redeem(account, exchanged, amount);
  }

  function _transfer(
    address sender, address recipient, uint256 amount
  ) private {

    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "Insufficient funds.");

    _balances[sender] = senderBalance - amount; // overflow checked above.
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  function _transferFrom(
    address sender, address recipient, uint256 amount
  ) private {

    _transfer(sender, recipient, amount);
    uint256 callerAllowance = _allowances[sender][msg.sender];
    if (callerAllowance != uint256(-1)) {
      require(callerAllowance >= amount, "Insufficient allowance.");
      _approve(sender, msg.sender, callerAllowance - amount); // overflow safe.
    }
  }

  function _approve(address owner, address spender, uint256 value) private {

    require(owner != address(0), "ERC20: approve for the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function _getExchangeRates(bool compute) private view returns (
    uint256 dTokenExchangeRate, uint256 cTokenExchangeRate, bool fullyAccrued
  ) {

    AccrualIndex memory accrualIndex = _accrualIndex;
    uint256 storedDTokenExchangeRate = uint256(accrualIndex.dTokenExchangeRate);
    uint256 storedCTokenExchangeRate = uint256(accrualIndex.cTokenExchangeRate);
    uint256 accrualBlock = uint256(accrualIndex.block);

    fullyAccrued = (accrualBlock == block.number);
    if (fullyAccrued) {
      dTokenExchangeRate = storedDTokenExchangeRate;
      cTokenExchangeRate = storedCTokenExchangeRate;
    } else {
      if (compute) {
        (cTokenExchangeRate,) = _getCurrentCTokenRates();
      } else {
        cTokenExchangeRate = CTokenInterface(_getCToken()).exchangeRateStored();
      }

      if (exchangeRateFrozen) {
         dTokenExchangeRate = storedDTokenExchangeRate;
      } else {
        uint256 cTokenInterest = (
          (cTokenExchangeRate.mul(_SCALING_FACTOR)).div(storedCTokenExchangeRate)
        ).sub(_SCALING_FACTOR);
    
        dTokenExchangeRate = storedDTokenExchangeRate.mul(
          _SCALING_FACTOR.add(cTokenInterest.mul(9) / 10)
        ) / _SCALING_FACTOR;          
      }
    }
  }

  function _getSurplus() private view returns (
    uint256 underlyingSurplus, uint256 cTokenSurplus
  ) {

    if (exchangeRateFrozen) {
        underlyingSurplus = 0;
        cTokenSurplus = 0;
    } else {
      CTokenInterface cToken = CTokenInterface(_getCToken());

      (
        uint256 dTokenExchangeRate, uint256 cTokenExchangeRate,
      ) = _getExchangeRates(true);

      uint256 dTokenUnderlying = _toUnderlying(
        _totalSupply, dTokenExchangeRate, true
      );

      uint256 cTokenUnderlying = _toUnderlying(
        cToken.balanceOf(address(this)), cTokenExchangeRate, false
      );

      underlyingSurplus = cTokenUnderlying > dTokenUnderlying
        ? cTokenUnderlying - dTokenUnderlying // overflow checked above
        : 0;

      cTokenSurplus = underlyingSurplus == 0
        ? 0
        : _fromUnderlying(underlyingSurplus, cTokenExchangeRate, false);
        
    }
  }

  function _getRatePerBlock() private view returns (
    uint256 dTokenSupplyRate, uint256 cTokenSupplyRate
  ) {

    (, cTokenSupplyRate) = _getCurrentCTokenRates();
    if (exchangeRateFrozen) {
      dTokenSupplyRate = 0;
    } else {
      dTokenSupplyRate = cTokenSupplyRate.mul(9) / 10;
    }
  }

  function _isContract(address account) private view returns (bool isContract) {

    uint256 size;
    assembly { size := extcodesize(account) }
    isContract = size > 0;
  }

  function _verifyRecover(
    address account, bytes32 digest, bytes memory signature
  ) private pure {

    require(
      signature.length == 65,
      "Must supply a single 65-byte signature when owner is not a contract."
    );

    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    require(
      uint256(s) <= _MAX_UNMALLEABLE_S,
      "Signature `s` value cannot be potentially malleable."
    );

    require(v == 27 || v == 28, "Signature `v` value not permitted.");

    require(account == ecrecover(digest, v, r, s), "Invalid signature.");
  }
}


contract DharmaDaiImplementationV2 is DharmaTokenV2 {

  string internal constant _NAME = "Dharma Dai";
  string internal constant _SYMBOL = "dDai";
  string internal constant _UNDERLYING_NAME = "Dai";
  string internal constant _CTOKEN_SYMBOL = "cDai";

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 // mainnet
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F // mainnet
  );

  PotInterface internal constant _POT = PotInterface(
    0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7 // mainnet
  );

  address internal constant _VAULT = 0x7e4A8391C728fEd9069B2962699AB416628B19Fa;

  function _getCurrentCTokenRates() internal view returns (
    uint256 exchangeRate, uint256 supplyRate
  ) {

    uint256 blockDelta = block.number.sub(_CDAI.accrualBlockNumber());

    if (blockDelta == 0) return (
      _CDAI.exchangeRateStored(), _CDAI.supplyRatePerBlock()
    );
    
    uint256 cash = ( // solhint-disable-next-line not-rely-on-time
      _rpow(_POT.dsr(), now.sub(_POT.rho()), 1e27).mul(_POT.chi()) / 1e27 // chi
    ).mul(_POT.pie(address(_CDAI))) / 1e27;

    CDaiInterestRateModelInterface interestRateModel = (
      CDaiInterestRateModelInterface(_CDAI.interestRateModel())
    );

    uint256 borrows = _CDAI.totalBorrows();
    uint256 reserves = _CDAI.totalReserves();
    uint256 reserveFactor = _CDAI.reserveFactorMantissa();

    uint256 interest = interestRateModel.getBorrowRate(
      cash, borrows, reserves
    ).mul(blockDelta).mul(borrows) / _SCALING_FACTOR;

    borrows = borrows.add(interest);
    reserves = reserves.add(reserveFactor.mul(interest) / _SCALING_FACTOR);

    exchangeRate = (
      ((cash.add(borrows)).sub(reserves)).mul(_SCALING_FACTOR)
    ).div(_CDAI.totalSupply());

    supplyRate = interestRateModel.getSupplyRate(
      cash, borrows, reserves, reserveFactor
    );
  }

  function _getUnderlyingName() internal pure returns (string memory underlyingName) {

    underlyingName = _UNDERLYING_NAME;
  }

  function _getUnderlying() internal pure returns (address underlying) {

    underlying = address(_DAI);
  }

  function _getCTokenSymbol() internal pure returns (string memory cTokenSymbol) {

    cTokenSymbol = _CTOKEN_SYMBOL;
  }

  function _getCToken() internal pure returns (address cToken) {

    cToken = address(_CDAI);
  }

  function _getDTokenName() internal pure returns (string memory dTokenName) {

    dTokenName = _NAME;
  }

  function _getDTokenSymbol() internal pure returns (string memory dTokenSymbol) {

    dTokenSymbol = _SYMBOL;
  }

  function _getVault() internal pure returns (address vault) {

    vault = _VAULT;
  }

  function _rpow(
    uint256 x, uint256 n, uint256 base
  ) internal pure returns (uint256 z) {

    assembly {
      switch x case 0 {switch n case 0 {z := base} default {z := 0}}
      default {
        switch mod(n, 2) case 0 { z := base } default { z := x }
        let half := div(base, 2)  // for rounding.
        for { n := div(n, 2) } n { n := div(n, 2) } {
          let xx := mul(x, x)
          if iszero(eq(div(xx, x), x)) { revert(0, 0) }
          let xxRound := add(xx, half)
          if lt(xxRound, xx) { revert(0, 0) }
          x := div(xxRound, base)
          if mod(n, 2) {
            let zx := mul(z, x)
            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0, 0) }
            let zxRound := add(zx, half)
            if lt(zxRound, zx) { revert(0, 0) }
            z := div(zxRound, base)
          }
        }
      }
    }
  }
}