
pragma solidity 0.5.17; // optimization runs: 200, evm version: istanbul


interface DharmaTradeReserveV17Interface {

  event Trade(
    address account,
    address suppliedAsset,
    address receivedAsset,
    address retainedAsset,
    uint256 suppliedAmount,
    uint256 recievedAmount, // note: typo
    uint256 retainedAmount
  );
  event RoleModified(Role indexed role, address account);
  event RolePaused(Role indexed role);
  event RoleUnpaused(Role indexed role);
  event EtherReceived(address sender, uint256 amount);
  event GasReserveRefilled(uint256 etherAmount);

  enum Role {            // #
    DEPOSIT_MANAGER,     // 0
    ADJUSTER,            // 1
    WITHDRAWAL_MANAGER,  // 2
    RESERVE_TRADER,      // 3
    PAUSER,              // 4
    GAS_RESERVE_REFILLER // 5
  }

  enum FeeType {    // #
    SUPPLIED_ASSET, // 0
    RECEIVED_ASSET, // 1
    ETHER           // 2
  }

  enum TradeType {
    ETH_TO_TOKEN,
    TOKEN_TO_ETH,
    TOKEN_TO_TOKEN,
    ETH_TO_TOKEN_WITH_TRANSFER_FEE,
    TOKEN_TO_ETH_WITH_TRANSFER_FEE,
    TOKEN_TO_TOKEN_WITH_TRANSFER_FEE
  }

  struct RoleStatus {
    address account;
    bool paused;
  }

  function tradeTokenForToken(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 deadline,
    bool routeThroughEther
  ) external returns (uint256 totalTokensSold);


  function tradeTokenForTokenSpecifyingFee(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external returns (uint256 totalTokensBought);


  function tradeTokenForTokenWithFeeOnTransfer(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 quotedTokenReceivedAmountAfterTransferFee,
    uint256 deadline,
    bool routeThroughEther
  ) external returns (uint256 totalTokensBought);


  function tradeTokenForTokenWithFeeOnTransferSpecifyingFee(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 quotedTokenReceivedAmountAfterTransferFee,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external returns (uint256 totalTokensBought);


  function tradeEtherForTokenUsingEtherizer(
    address token,
    uint256 etherAmount,
    uint256 quotedTokenAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherSold);


  function tradeTokenForTokenUsingReserves(
    ERC20Interface tokenProvidedFromReserves,
    address tokenReceived,
    uint256 tokenProvidedAmountFromReserves,
    uint256 quotedTokenReceivedAmount,
    uint256 deadline,
    bool routeThroughEther
  ) external returns (uint256 totalTokensSold);


  function tradeTokenForTokenUsingReservesWithFeeOnTransferSpecifyingFee(
    ERC20Interface tokenProvidedFromReserves,
    address tokenReceived,
    uint256 tokenProvidedAmountFromReserves,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external returns (uint256 totalTokensBought);


  function tradeTokenForEther(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherBought);


  function tradeTokenForEtherWithFeeOnTransfer(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherBought);


  function tradeTokenForEtherWithFeeOnTransferSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalEtherBought);


  function tradeTokenForEtherUsingReservesWithFeeOnTransferSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmountFromReserves,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalEtherBought);


  function tradeTokenForEtherSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalEtherBought);


  function tradeEtherForToken(
    address token, uint256 quotedTokenAmount, uint256 deadline
  ) external payable returns (uint256 totalEtherSold);


  function tradeEtherForTokenWithFeeOnTransfer(
    address token,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 deadline
  ) external payable returns (uint256 totalTokensBought);


  function tradeEtherForTokenSpecifyingFee(
    address token,
    uint256 quotedTokenAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external payable returns (uint256 totalTokensBought);


  function tradeEtherForTokenWithFeeOnTransferSpecifyingFee(
    address token,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external payable returns (uint256 totalTokensBought);


  function tradeTokenForTokenUsingReservesSpecifyingFee(
    ERC20Interface tokenProvidedFromReserves,
    address tokenReceived,
    uint256 tokenProvidedAmountFromReserves,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external returns (uint256 totalTokensBought);


  function tradeEtherForTokenUsingReservesWithFeeOnTransferSpecifyingFee(
    address token,
    uint256 etherAmountFromReserves,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalTokensBought);


  function tradeTokenForEtherUsingReserves(
    ERC20Interface token,
    uint256 tokenAmountFromReserves,
    uint256 quotedEtherAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherBought);


  function tradeTokenForEtherUsingReservesSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmountFromReserves,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalEtherBought);


  function tradeEtherForTokenUsingReserves(
    address token,
    uint256 etherAmountFromReserves,
    uint256 quotedTokenAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherSold);


  function tradeEtherForTokenUsingReservesSpecifyingFee(
    address token,
    uint256 etherAmountFromReserves,
    uint256 quotedTokenAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalTokensBought);


  function finalizeEtherDeposit(
    address payable smartWallet,
    address initialUserSigningKey,
    uint256 etherAmount
  ) external;


  function finalizeTokenDeposit(
    address smartWallet,
    address initialUserSigningKey,
    ERC20Interface token,
    uint256 amount
  ) external;


  function refillGasReserve(uint256 etherAmount) external;


  function withdrawUSDC(address recipient, uint256 usdcAmount) external;


  function withdrawDai(address recipient, uint256 daiAmount) external;


  function withdrawUSDCToPrimaryRecipient(uint256 usdcAmount) external;


  function withdrawDaiToPrimaryRecipient(uint256 usdcAmount) external;


  function withdrawEther(
    address payable recipient, uint256 etherAmount
  ) external;


  function withdraw(
    ERC20Interface token, address recipient, uint256 amount
  ) external returns (bool success);


  function callAny(
    address payable target, uint256 amount, bytes calldata data
  ) external returns (bool ok, bytes memory returnData);


  function setPrimaryUSDCRecipient(address recipient) external;


  function setPrimaryDaiRecipient(address recipient) external;


  function setRole(Role role, address account) external;


  function removeRole(Role role) external;


  function pause(Role role) external;


  function unpause(Role role) external;


  function isPaused(Role role) external view returns (bool paused);


  function isRole(Role role) external view returns (bool hasRole);


  function isDharmaSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) external view returns (bool dharmaSmartWallet);


  function getDepositManager() external view returns (address depositManager);


  function getReserveTrader() external view returns (address reserveTrader);


  function getWithdrawalManager() external view returns (
    address withdrawalManager
  );


  function getPauser() external view returns (address pauser);


  function getGasReserveRefiller() external view returns (
    address gasReserveRefiller
  );


  function getPrimaryUSDCRecipient() external view returns (
    address recipient
  );


  function getPrimaryDaiRecipient() external view returns (
    address recipient
  );


  function getImplementation() external view returns (address implementation);


  function getInstance() external pure returns (address instance);


  function getVersion() external view returns (uint256 version);

}


interface ERC20Interface {

  function balanceOf(address) external view returns (uint256);

  function approve(address, uint256) external returns (bool);

  function allowance(address, address) external view returns (uint256);

  function transfer(address, uint256) external returns (bool);

  function transferFrom(address, address, uint256) external returns (bool);

}


interface DTokenInterface {

  function balanceOf(address) external view returns (uint256);

  function balanceOfUnderlying(address) external view returns (uint256);

  function transfer(address, uint256) external returns (bool);

  function approve(address, uint256) external returns (bool);

  function exchangeRateCurrent() external view returns (uint256);

}


interface UniswapV2Interface {

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);


  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);


  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);


  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);


  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);


  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);


  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;


  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;


  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

}


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }
}


contract TwoStepOwnable {

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  address private _owner;

  address private _newPotentialOwner;

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


contract DharmaTradeReserveV17ImplementationStaging is DharmaTradeReserveV17Interface, TwoStepOwnable {

  using SafeMath for uint256;

  mapping(uint256 => RoleStatus) private _roles;

  address private _primaryDaiRecipient;

  address private _primaryUSDCRecipient;

  uint256 private _daiLimit; // unused

  uint256 private _etherLimit; // unused

  bool private _originatesFromReserveTrader; // unused, don't change storage layout

  uint256 private constant _VERSION = 1017;

  address private constant V16_STAGING = address(
    0xCF313bE76Ff33aaf3B69d13d6BE3A3Aeb2f6F781
  );

  ERC20Interface internal constant _USDC = ERC20Interface(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );

  ERC20Interface internal constant _DAI = ERC20Interface(
    0x6B175474E89094C44Da98b954EedeAC495271d0F // mainnet
  );

  ERC20Interface internal constant _ETHERIZER = ERC20Interface(
    0x723B51b72Ae89A3d0c2a2760f0458307a1Baa191
  );

  DTokenInterface internal constant _DDAI = DTokenInterface(
    0x00000000001876eB1444c986fD502e618c587430
  );

  UniswapV2Interface internal constant _UNISWAP_ROUTER = UniswapV2Interface(
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
  );

  address internal constant _WETH = address(
    0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
  );

  address internal constant _GAS_RESERVE = address(
    0x09cd826D4ABA4088E1381A1957962C946520952d // staging version
  );

  bytes21 internal constant _CREATE2_HEADER = bytes21(
    0xff8D1e00b000e56d5BcB006F3a008Ca6003b9F0033 // control character + factory
  );

  bytes internal constant _WALLET_CREATION_CODE_HEADER = hex"60806040526040516104423803806104428339818101604052602081101561002657600080fd5b810190808051604051939291908464010000000082111561004657600080fd5b90830190602082018581111561005b57600080fd5b825164010000000081118282018810171561007557600080fd5b82525081516020918201929091019080838360005b838110156100a257818101518382015260200161008a565b50505050905090810190601f1680156100cf5780820380516001836020036101000a031916815260200191505b5060405250505060006100e661019e60201b60201c565b6001600160a01b0316826040518082805190602001908083835b6020831061011f5780518252601f199092019160209182019101610100565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d806000811461017f576040519150601f19603f3d011682016040523d82523d6000602084013e610184565b606091505b5050905080610197573d6000803e3d6000fd5b50506102be565b60405160009081906060906eb45d6593312ac9fde193f3d06336449083818181855afa9150503d80600081146101f0576040519150601f19603f3d011682016040523d82523d6000602084013e6101f5565b606091505b509150915081819061029f576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561026457818101518382015260200161024c565b50505050905090810190601f1680156102915780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b508080602001905160208110156102b557600080fd5b50519392505050565b610175806102cd6000396000f3fe608060405261001461000f610016565b61011c565b005b60405160009081906060906eb45d6593312ac9fde193f3d06336449083818181855afa9150503d8060008114610068576040519150601f19603f3d011682016040523d82523d6000602084013e61006d565b606091505b50915091508181906100fd5760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b838110156100c25781810151838201526020016100aa565b50505050905090810190601f1680156100ef5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b5080806020019051602081101561011357600080fd5b50519392505050565b3660008037600080366000845af43d6000803e80801561013b573d6000f35b3d6000fdfea265627a7a723158203c578cc1552f1d1b48134a72934fe12fb89a29ff396bd514b9a4cebcacc5cacc64736f6c634300050b003200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000024c4d66de8000000000000000000000000";
  bytes28 internal constant _WALLET_CREATION_CODE_FOOTER = bytes28(
    0x00000000000000000000000000000000000000000000000000000000
  );

  address internal constant _TRADE_FOR_USDC_AND_RETAIN_FLAG = address(uint160(-1));

  function () external payable {
    emit EtherReceived(msg.sender, msg.value);
  }

  function tradeTokenForToken(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 deadline,
    bool routeThroughEther
  ) external returns (uint256 totalTokensSold) {

    _delegate(V16_STAGING);
  }

  function tradeTokenForTokenSpecifyingFee(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external returns (uint256 totalTokensBought) {

    _ensureNoEtherFeeTypeWhenNotRouted(routeThroughEther, feeType);

    _transferInToken(tokenProvided, msg.sender, tokenProvidedAmount);

    totalTokensBought = _tradeTokenForToken(
      msg.sender,
      tokenProvided,
      tokenReceived,
      tokenProvidedAmount,
      quotedTokenReceivedAmount,
      maximumFeeAmount,
      deadline,
      routeThroughEther,
      feeType
    );
  }

  function tradeTokenForTokenWithFeeOnTransfer(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 quotedTokenReceivedAmountAfterTransferFee,
    uint256 deadline,
    bool routeThroughEther
  ) external returns (uint256 totalTokensBought) {

    uint256 balanceBeforeTransferIn = tokenProvided.balanceOf(address(this));

    _transferInToken(tokenProvided, msg.sender, tokenProvidedAmount);

    uint256 tokenProvidedAmountAfterTransferFee = tokenProvided.balanceOf(
      address(this)
    ).sub(balanceBeforeTransferIn);

    totalTokensBought = _tradeTokenForTokenWithFeeOnTransferLegacy(
      msg.sender,
      tokenProvided,
      tokenReceived,
      tokenProvidedAmount,
      tokenProvidedAmountAfterTransferFee,
      quotedTokenReceivedAmount,
      quotedTokenReceivedAmountAfterTransferFee,
      deadline,
      routeThroughEther
    );
  }

  function tradeTokenForTokenWithFeeOnTransferSpecifyingFee(
    ERC20Interface tokenProvided,
    address tokenReceived,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 quotedTokenReceivedAmountAfterTransferFee,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external returns (uint256 totalTokensBought) {

    _ensureNoEtherFee(feeType);

    uint256 balanceBeforeTransferIn = tokenProvided.balanceOf(address(this));

    _transferInToken(tokenProvided, msg.sender, tokenProvidedAmount);

    uint256 tokenProvidedAmountAfterTransferFee = tokenProvided.balanceOf(
      address(this)
    ).sub(balanceBeforeTransferIn);

    totalTokensBought = _tradeTokenForTokenWithFeeOnTransfer(
      TradeTokenForTokenWithFeeOnTransferArgs({
        account: msg.sender,
        tokenProvided: tokenProvided,
        tokenReceivedOrUSDCFlag: tokenReceived,
        tokenProvidedAmount: tokenProvidedAmount,
        tokenProvidedAmountAfterTransferFee: tokenProvidedAmountAfterTransferFee,
        quotedTokenReceivedAmount: quotedTokenReceivedAmount,
        quotedTokenReceivedAmountAfterTransferFee: quotedTokenReceivedAmountAfterTransferFee,
        maximumFeeAmount: maximumFeeAmount,
        deadline: deadline,
        routeThroughEther: routeThroughEther,
        feeType: feeType
      })
    );
  }

  function tradeTokenForEther(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherBought) {

    _delegate(V16_STAGING);
  }

  function tradeTokenForEtherSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalEtherBought) {

    _transferInToken(token, msg.sender, tokenAmount);

    uint256 receivedEtherAmount;
    uint256 retainedAmount;
    (totalEtherBought, receivedEtherAmount, retainedAmount) = _tradeTokenForEther(
      token,
      tokenAmount,
      tokenAmount,
      quotedEtherAmount,
      deadline,
      feeType,
      maximumFeeAmount
    );

    _fireTradeEvent(
      false,
      false,
      feeType != FeeType.SUPPLIED_ASSET,
      address(token),
      tokenAmount,
      receivedEtherAmount,
      retainedAmount
    );

    _transferEther(msg.sender, receivedEtherAmount);
  }

  function tradeTokenForEtherWithFeeOnTransfer(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherBought) {

    uint256 balanceBeforeTransferIn = token.balanceOf(address(this));

    _transferInToken(token, msg.sender, tokenAmount);

    uint256 tokenAmountAfterTransferFee = token.balanceOf(address(this)).sub(
      balanceBeforeTransferIn
    );

    (totalEtherBought,,) = _tradeTokenForEther(
      token,
      tokenAmount,
      tokenAmountAfterTransferFee,
      quotedEtherAmount,
      deadline,
      FeeType.ETHER,
      uint256(-1)
    );

    _fireTradeEvent(
      false,
      false,
      true,
      address(token),
      tokenAmount,
      quotedEtherAmount,
      totalEtherBought.sub(quotedEtherAmount)
    );

    _transferEther(msg.sender, quotedEtherAmount);
  }

  function tradeTokenForEtherWithFeeOnTransferSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external returns (uint256 totalEtherBought) {

    uint256 balanceBeforeTransferIn = token.balanceOf(address(this));

    _transferInToken(token, msg.sender, tokenAmount);

    uint256 tokenAmountAfterTransferFee = token.balanceOf(address(this)).sub(
      balanceBeforeTransferIn
    );

    uint256 receivedEtherAmount;
    uint256 retainedAmount;
    (totalEtherBought, receivedEtherAmount, retainedAmount) = _tradeTokenForEther(
      token,
      tokenAmount,
      tokenAmount,
      quotedEtherAmount,
      deadline,
      feeType,
      maximumFeeAmount
    );

    _fireTradeEvent(
      false,
      false,
      feeType != FeeType.SUPPLIED_ASSET,
      address(token),
      tokenAmount,
      receivedEtherAmount,
      retainedAmount
    );

    _transferEther(msg.sender, receivedEtherAmount);
  }

  function tradeEtherForToken(
    address token, uint256 quotedTokenAmount, uint256 deadline
  ) external payable returns (uint256 totalEtherSold) {

    _delegate(V16_STAGING);
  }

  function tradeEtherForTokenSpecifyingFee(
    address token,
    uint256 quotedTokenAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external payable returns (uint256 totalTokensBought) {

    uint256 receivedTokenAmount;
    uint256 retainedAmount;
    (totalTokensBought, receivedTokenAmount, retainedAmount) = _tradeExactEtherForToken(
      token,
      msg.value,
      quotedTokenAmount,
      deadline,
      false,
      feeType,
      maximumFeeAmount
    );

    _fireTradeEvent(
      false,
      true,
      feeType != FeeType.RECEIVED_ASSET,
      token,
      msg.value,
      receivedTokenAmount,
      retainedAmount
    );
  }

  function tradeEtherForTokenWithFeeOnTransfer(
    address token,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 deadline
  ) external payable returns (uint256 totalTokensBought) {

    totalTokensBought = _tradeEtherForTokenWithFeeOnTransferLegacy(
      token,
      msg.value,
      quotedTokenAmount,
      quotedTokenAmountAfterTransferFee,
      deadline,
      false
    );
  }

  function tradeEtherForTokenWithFeeOnTransferSpecifyingFee(
    address token,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external payable returns (uint256 totalTokensBought) {

    totalTokensBought = _tradeEtherForTokenWithFeeOnTransfer(
      token,
      msg.value,
      quotedTokenAmount,
      quotedTokenAmountAfterTransferFee,
      maximumFeeAmount,
      deadline,
      false,
      feeType
    );
  }

  function tradeEtherForTokenUsingReservesWithFeeOnTransferSpecifyingFee(
    address token,
    uint256 etherAmountFromReserves,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalTokensBought) {

    totalTokensBought = _tradeEtherForTokenWithFeeOnTransfer(
      token,
      etherAmountFromReserves,
      quotedTokenAmount,
      quotedTokenAmountAfterTransferFee,
      maximumFeeAmount,
      deadline,
      true,
      feeType
    );
  }

  function tradeEtherForTokenUsingEtherizer(
    address token,
    uint256 etherAmount,
    uint256 quotedTokenAmount,
    uint256 deadline
  ) external returns (uint256 totalEtherSold) {

    _delegate(V16_STAGING);
  }

  function tradeEtherForTokenWithFeeOnTransferUsingEtherizer(
    address token,
    uint256 etherAmount,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 deadline
  ) external returns (uint256 totalTokensBought) {

    _transferInToken(_ETHERIZER, msg.sender, etherAmount);

    totalTokensBought = _tradeEtherForTokenWithFeeOnTransferLegacy(
      token,
      etherAmount,
      quotedTokenAmount,
      quotedTokenAmountAfterTransferFee,
      deadline,
      false
    );
  }

  function tradeTokenForTokenUsingReserves(
    ERC20Interface tokenProvidedFromReserves,
    address tokenReceived,
    uint256 tokenProvidedAmountFromReserves,
    uint256 quotedTokenReceivedAmount,
    uint256 deadline,
    bool routeThroughEther
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalTokensSold) {

    _delegate(V16_STAGING);
  }

  function tradeTokenForTokenUsingReservesSpecifyingFee(
    ERC20Interface tokenProvidedFromReserves,
    address tokenReceived,
    uint256 tokenProvidedAmountFromReserves,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalTokensBought) {

    _ensureNoEtherFeeTypeWhenNotRouted(routeThroughEther, feeType);

    totalTokensBought = _tradeTokenForToken(
      address(this),
      tokenProvidedFromReserves,
      tokenReceived,
      tokenProvidedAmountFromReserves,
      quotedTokenReceivedAmount,
      maximumFeeAmount,
      deadline,
      routeThroughEther,
      feeType
    );
  }

  function tradeTokenForTokenUsingReservesWithFeeOnTransferSpecifyingFee(
    ERC20Interface tokenProvidedFromReserves,
    address tokenReceived,
    uint256 tokenProvidedAmountFromReserves,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalTokensBought) {

    _ensureNoEtherFee(feeType);

    totalTokensBought = _tradeTokenForTokenWithFeeOnTransfer(
      TradeTokenForTokenWithFeeOnTransferArgs({
        account: address(this),
        tokenProvided: tokenProvidedFromReserves,
        tokenReceivedOrUSDCFlag: tokenReceived,
        tokenProvidedAmount: tokenProvidedAmountFromReserves,
        tokenProvidedAmountAfterTransferFee: tokenProvidedAmountFromReserves,
        quotedTokenReceivedAmount: quotedTokenReceivedAmount,
        quotedTokenReceivedAmountAfterTransferFee: tokenProvidedAmountFromReserves,
        maximumFeeAmount: maximumFeeAmount,
        deadline: deadline,
        routeThroughEther: routeThroughEther,
        feeType: feeType
      })
    );
  }

  function tradeTokenForEtherUsingReserves(
    ERC20Interface token,
    uint256 tokenAmountFromReserves,
    uint256 quotedEtherAmount,
    uint256 deadline
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalEtherBought) {

    _delegate(V16_STAGING);
  }

  function tradeTokenForEtherUsingReservesSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmountFromReserves,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalEtherBought) {


    uint256 receivedEtherAmount;
    uint256 retainedAmount;
    (totalEtherBought, receivedEtherAmount, retainedAmount) = _tradeTokenForEther(
      token,
      tokenAmountFromReserves,
      tokenAmountFromReserves,
      quotedEtherAmount,
      deadline,
      feeType,
      maximumFeeAmount
    );

    _fireTradeEvent(
      true,
      false,
      feeType != FeeType.SUPPLIED_ASSET,
      address(token),
      tokenAmountFromReserves,
      receivedEtherAmount,
      retainedAmount
    );
  }

  function tradeTokenForEtherUsingReservesWithFeeOnTransferSpecifyingFee(
    ERC20Interface token,
    uint256 tokenAmountFromReserves,
    uint256 quotedEtherAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalEtherBought) {

    uint256 receivedEtherAmount;
    uint256 retainedAmount;
    (totalEtherBought, receivedEtherAmount, retainedAmount) = _tradeTokenForEther(
      token,
      tokenAmountFromReserves,
      tokenAmountFromReserves,
      quotedEtherAmount,
      deadline,
      feeType,
      maximumFeeAmount
    );

    _fireTradeEvent(
      true,
      false,
      feeType != FeeType.SUPPLIED_ASSET,
      address(token),
      tokenAmountFromReserves,
      receivedEtherAmount,
      retainedAmount
    );
  }

  function tradeEtherForTokenUsingReserves(
    address token,
    uint256 etherAmountFromReserves,
    uint256 quotedTokenAmount,
    uint256 deadline
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (uint256 totalEtherSold) {

    _delegate(V16_STAGING);
  }

  function tradeEtherForTokenUsingReservesSpecifyingFee(
    address token,
    uint256 etherAmountFromReserves,
    uint256 quotedTokenAmount,
    uint256 maximumFeeAmount,
    uint256 deadline,
    FeeType feeType
  ) external onlyOwnerOr(Role.RESERVE_TRADER) returns (
    uint256 totalTokensBought
  ) {

    uint256 receivedTokenAmount;
    uint256 retainedAmount;
    (totalTokensBought, receivedTokenAmount, retainedAmount) = _tradeExactEtherForToken(
      token,
      etherAmountFromReserves,
      quotedTokenAmount,
      deadline,
      false,
      feeType,
      maximumFeeAmount
    );

    _fireTradeEvent(
      true,
      true,
      feeType != FeeType.RECEIVED_ASSET,
      token,
      etherAmountFromReserves,
      receivedTokenAmount,
      maximumFeeAmount
    );
  }

  function finalizeTokenDeposit(
    address smartWallet,
    address initialUserSigningKey,
    ERC20Interface token,
    uint256 amount
  ) external onlyOwnerOr(Role.DEPOSIT_MANAGER) {

    _ensureSmartWallet(smartWallet, initialUserSigningKey);

    _transferToken(token, smartWallet, amount);
  }

  function finalizeEtherDeposit(
    address payable smartWallet,
    address initialUserSigningKey,
    uint256 etherAmount
  ) external onlyOwnerOr(Role.DEPOSIT_MANAGER) {

    _ensureSmartWallet(smartWallet, initialUserSigningKey);

    _transferEther(smartWallet, etherAmount);
  }

  function refillGasReserve(
    uint256 etherAmount
  ) external onlyOwnerOr(Role.GAS_RESERVE_REFILLER) {

    _transferEther(_GAS_RESERVE, etherAmount);

    emit GasReserveRefilled(etherAmount);
  }

  function withdrawUSDCToPrimaryRecipient(
    uint256 usdcAmount
  ) external onlyOwnerOr(Role.WITHDRAWAL_MANAGER) {

    address primaryRecipient = _primaryUSDCRecipient;
    require(
      primaryRecipient != address(0), "No USDC primary recipient currently set."
    );

    _transferToken(_USDC, primaryRecipient, usdcAmount);
  }

  function withdrawDaiToPrimaryRecipient(
    uint256 daiAmount
  ) external onlyOwnerOr(Role.WITHDRAWAL_MANAGER) {

    address primaryRecipient = _primaryDaiRecipient;
    require(
      primaryRecipient != address(0), "No Dai primary recipient currently set."
    );

    _transferToken(_DAI, primaryRecipient, daiAmount);
  }

  function withdrawUSDC(
    address recipient, uint256 usdcAmount
  ) external onlyOwner {

    _transferToken(_USDC, recipient, usdcAmount);
  }

  function withdrawDai(
    address recipient, uint256 daiAmount
  ) external onlyOwner {

    _transferToken(_DAI, recipient, daiAmount);
  }

  function withdrawEther(
    address payable recipient, uint256 etherAmount
  ) external onlyOwner {

    _transferEther(recipient, etherAmount);
  }

  function withdraw(
    ERC20Interface token, address recipient, uint256 amount
  ) external onlyOwner returns (bool success) {

    success = token.transfer(recipient, amount);
  }

  function callAny(
    address payable target, uint256 amount, bytes calldata data
  ) external onlyOwner returns (bool ok, bytes memory returnData) {

    (ok, returnData) = target.call.value(amount)(data);
  }

  function setPrimaryUSDCRecipient(address recipient) external onlyOwner {

    _primaryUSDCRecipient = recipient;
  }

  function setPrimaryDaiRecipient(address recipient) external onlyOwner {

    _primaryDaiRecipient = recipient;
  }

  function pause(Role role) external onlyOwnerOr(Role.PAUSER) {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(!storedRoleStatus.paused, "Role in question is already paused.");
    storedRoleStatus.paused = true;
    emit RolePaused(role);
  }

  function unpause(Role role) external onlyOwner {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];
    require(storedRoleStatus.paused, "Role in question is already unpaused.");
    storedRoleStatus.paused = false;
    emit RoleUnpaused(role);
  }

  function setRole(Role role, address account) external onlyOwner {

    require(account != address(0), "Must supply an account.");
    _setRole(role, account);
  }

  function removeRole(Role role) external onlyOwner {

    _setRole(role, address(0));
  }

  function isPaused(Role role) external view returns (bool paused) {

    paused = _isPaused(role);
  }

  function isRole(Role role) external view returns (bool hasRole) {

    hasRole = _isRole(role);
  }

  function isDharmaSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) external view returns (bool dharmaSmartWallet) {

    dharmaSmartWallet = _isSmartWallet(smartWallet, initialUserSigningKey);
  }

  function getDepositManager() external view returns (address depositManager) {

    depositManager = _roles[uint256(Role.DEPOSIT_MANAGER)].account;
  }

  function getReserveTrader() external view returns (address reserveTrader) {

    reserveTrader = _roles[uint256(Role.RESERVE_TRADER)].account;
  }

  function getWithdrawalManager() external view returns (
    address withdrawalManager
  ) {

    withdrawalManager = _roles[uint256(Role.WITHDRAWAL_MANAGER)].account;
  }

  function getPauser() external view returns (address pauser) {

    pauser = _roles[uint256(Role.PAUSER)].account;
  }

  function getGasReserveRefiller() external view returns (
    address gasReserveRefiller
  ) {

    gasReserveRefiller = _roles[uint256(Role.GAS_RESERVE_REFILLER)].account;
  }

  function getPrimaryUSDCRecipient() external view returns (
    address recipient
  ) {

    recipient = _primaryUSDCRecipient;
  }

  function getPrimaryDaiRecipient() external view returns (
    address recipient
  ) {

    recipient = _primaryDaiRecipient;
  }

  function getImplementation() external view returns (
    address implementation
  ) {

    (bool ok, bytes memory returnData) = address(
      0x481B1a16E6675D33f8BBb3a6A58F5a9678649718
    ).staticcall("");
    require(ok && returnData.length == 32, "Invalid implementation.");
    implementation = abi.decode(returnData, (address));
  }

  function getInstance() external pure returns (address instance) {

    instance = address(0x09cd826D4ABA4088E1381A1957962C946520952d);
  }

  function getVersion() external view returns (uint256 version) {

    version = _VERSION;
  }

  function _grantUniswapRouterApprovalIfNecessary(
    ERC20Interface token, uint256 amount
  ) internal {

    if (token.allowance(address(this), address(_UNISWAP_ROUTER)) < amount) {
      (bool success, bytes memory data) = address(token).call(
        abi.encodeWithSelector(
          token.approve.selector, address(_UNISWAP_ROUTER), uint256(0)
        )
      );

      (success, data) = address(token).call(
        abi.encodeWithSelector(
          token.approve.selector, address(_UNISWAP_ROUTER), uint256(-1)
        )
      );

      if (!success) {
        (success, data) = address(token).call(
          abi.encodeWithSelector(
            token.approve.selector, address(_UNISWAP_ROUTER), amount
          )
        );
      }

      require(
        success && (data.length == 0 || abi.decode(data, (bool))),
        "Token approval for Uniswap router failed."
      );
    }
  }

  function _tradeEtherForTokenWithFeeOnTransfer(
    address tokenReceivedOrUSDCFlag,
    uint256 etherAmount,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 maximumFeeAmount,
    uint256 deadline,
    bool fromReserves,
    FeeType feeType
  ) internal returns (uint256 totalTokensBought) {

    ERC20Interface tokenReceived = (
      tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG
        ? _USDC
        : ERC20Interface(tokenReceivedOrUSDCFlag)
    );

    {
      uint256 priorReserveBalanceOfReceivedToken = tokenReceived.balanceOf(
        address(this)
      );

      address[] memory path = new address[](2);
      path[0] = _WETH;
      path[1] = tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG
        ? address(_USDC)
        : tokenReceivedOrUSDCFlag;

      _UNISWAP_ROUTER.swapExactETHForTokensSupportingFeeOnTransferTokens.value(
        feeType != FeeType.RECEIVED_ASSET
          ? etherAmount.sub(maximumFeeAmount)
          : etherAmount
      )(
        quotedTokenAmount,
        path,
        address(this),
        deadline
      );
      totalTokensBought = tokenReceived.balanceOf(address(this)).sub(
        priorReserveBalanceOfReceivedToken
      );
    }

    uint256 receivedTokenAmount;
    uint256 retainedAmount;
    if (feeType == FeeType.RECEIVED_ASSET) {
      retainedAmount = maximumFeeAmount.min(
        totalTokensBought.sub(quotedTokenAmount)
      );
      receivedTokenAmount = totalTokensBought.sub(retainedAmount);
    } else {
      retainedAmount = maximumFeeAmount;
      receivedTokenAmount = totalTokensBought;
    }

    if (!fromReserves) {
      uint256 priorRecipientBalanceOfReceivedToken = tokenReceived.balanceOf(
        msg.sender
      );

      _transferToken(tokenReceived, msg.sender, receivedTokenAmount);

      uint256 receivedAmountAfterTransferFee = tokenReceived.balanceOf(msg.sender).sub(
        priorRecipientBalanceOfReceivedToken
      );

      require(
        receivedAmountAfterTransferFee >= quotedTokenAmountAfterTransferFee,
        "Received token amount after transfer fee is less than quoted amount."
      );
    }

    _fireTradeEvent(
      false,
      true,
      feeType != FeeType.RECEIVED_ASSET,
      tokenReceivedOrUSDCFlag,
      etherAmount,
      receivedTokenAmount,
      retainedAmount
    );
  }

  function _tradeEtherForTokenWithFeeOnTransferLegacy(
    address tokenReceivedOrUSDCFlag,
    uint256 etherAmount,
    uint256 quotedTokenAmount,
    uint256 quotedTokenAmountAfterTransferFee,
    uint256 deadline,
    bool fromReserves
  ) internal returns (uint256 totalTokensBought) {

    uint256 retainedAmount;
    uint256 receivedAmountAfterTransferFee;

    ERC20Interface tokenReceived = (
      tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG
        ? _USDC
        : ERC20Interface(tokenReceivedOrUSDCFlag)
    );

    { // Scope to avoid stack too deep error.
      (address[] memory path, ) = _createPathAndAmounts(
        _WETH, address(tokenReceived), false
      );

      uint256 priorReserveBalanceOfReceivedToken = tokenReceived.balanceOf(
        address(this)
      );

      _UNISWAP_ROUTER.swapExactETHForTokensSupportingFeeOnTransferTokens.value(
        etherAmount
      )(
        quotedTokenAmount,
        path,
        address(this),
        deadline
      );

      totalTokensBought = tokenReceived.balanceOf(address(this)).sub(
        priorReserveBalanceOfReceivedToken
      );
      retainedAmount = totalTokensBought.sub(quotedTokenAmount);

      if (!fromReserves) {
        uint256 priorRecipientBalanceOfReceivedToken = tokenReceived.balanceOf(
          msg.sender
        );

        _transferToken(tokenReceived, msg.sender, quotedTokenAmount);

        receivedAmountAfterTransferFee = tokenReceived.balanceOf(msg.sender).sub(
          priorRecipientBalanceOfReceivedToken
        );

        require(
          receivedAmountAfterTransferFee >= quotedTokenAmountAfterTransferFee,
          "Received token amount after transfer fee is less than quoted amount."
        );
      }
    }

    _emitTrade(
      fromReserves ? address(this) : msg.sender,
      address(0),
      tokenReceivedOrUSDCFlag,
      address(tokenReceived),
      etherAmount,
      quotedTokenAmountAfterTransferFee,
      retainedAmount
    );
  }

  function _tradeExactEtherForToken(
    address tokenReceivedOrUSDCFlag,
    uint256 etherAmount,
    uint256 quotedTokenAmount,
    uint256 deadline,
    bool fromReserves,
    FeeType feeType,
    uint256 maximumFeeAmount
  ) internal returns (
    uint256 totalTokensBought,
    uint256 receivedTokenAmount,
    uint256 retainedAmount
  ) {

    address destination;
    address[] memory path = new address[](2);
    path[0] = _WETH;
    if (tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG) {
      path[1] = address(_USDC);
      destination = address(this);
    } else {
      path[1] = tokenReceivedOrUSDCFlag;
      destination = fromReserves ? address(this) : msg.sender;
    }

    uint256[] memory amounts = new uint256[](2);
    amounts = _UNISWAP_ROUTER.swapExactETHForTokens.value(
      feeType != FeeType.RECEIVED_ASSET
        ? etherAmount.sub(maximumFeeAmount)
        : etherAmount
    )(
      quotedTokenAmount,
      path,
      destination,
      deadline
    );
    totalTokensBought = amounts[1];

    if (feeType == FeeType.RECEIVED_ASSET) {
      retainedAmount = maximumFeeAmount.min(
        totalTokensBought.sub(quotedTokenAmount)
      );
      receivedTokenAmount = totalTokensBought.sub(retainedAmount);
    } else {
      retainedAmount = maximumFeeAmount;
      receivedTokenAmount = totalTokensBought;
    }
  }

  function _tradeTokenForEther(
    ERC20Interface token,
    uint256 tokenAmount,
    uint256 tokenAmountAfterTransferFee,
    uint256 quotedEtherAmount,
    uint256 deadline,
    FeeType feeType,
    uint256 maximumFeeAmount
  ) internal returns (
    uint256 totalEtherBought,
    uint256 receivedEtherAmount,
    uint256 retainedAmount
  ) {

    uint256 tradeAmount;
    if (feeType == FeeType.SUPPLIED_ASSET) {
      tradeAmount = (tokenAmount.min(tokenAmountAfterTransferFee)).sub(maximumFeeAmount);
      retainedAmount = maximumFeeAmount;
    } else {
      tradeAmount = tokenAmount.min(tokenAmountAfterTransferFee);
    }

    _grantUniswapRouterApprovalIfNecessary(token, tokenAmount);

    (address[] memory path, uint256[] memory amounts) = _createPathAndAmounts(
      address(token), _WETH, false
    );

    if (tokenAmount == tokenAmountAfterTransferFee) {
      amounts = _UNISWAP_ROUTER.swapExactTokensForETH(
        tradeAmount, quotedEtherAmount, path, address(this), deadline
      );
      totalEtherBought = amounts[1];
    } else {
      uint256 ethBalanceBeforeTrade = address(this).balance;
      _UNISWAP_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tradeAmount,
        quotedEtherAmount,
        path,
        address(this),
        deadline
      );
      totalEtherBought = address(this).balance.sub(ethBalanceBeforeTrade);
    }

    if (feeType != FeeType.SUPPLIED_ASSET) {
      retainedAmount = maximumFeeAmount.min(
        totalEtherBought.sub(quotedEtherAmount)
      );

      receivedEtherAmount = totalEtherBought.sub(retainedAmount);
    } else {
      receivedEtherAmount = totalEtherBought;
    }
  }

  function _tradeTokenForToken(
    address account,
    ERC20Interface tokenProvided,
    address tokenReceivedOrUSDCFlag,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 maximumFeeAmount, // WETH if routeThroughEther, else tokenReceived
    uint256 deadline,
    bool routeThroughEther,
    FeeType feeType
  ) internal returns (uint256 totalTokensBought) {

    uint256 retainedAmount;
    uint256 receivedAmount;
    address tokenReceived;

    _grantUniswapRouterApprovalIfNecessary(tokenProvided, tokenProvidedAmount);

    if (tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG) {
      tokenReceived = address(_USDC);
    } else {
      tokenReceived = tokenReceivedOrUSDCFlag;
    }

    if (routeThroughEther == false) {
      (address[] memory path, uint256[] memory amounts) = _createPathAndAmounts(
        address(tokenProvided), tokenReceived, false
      );

      amounts = _UNISWAP_ROUTER.swapExactTokensForTokens(
        feeType == FeeType.SUPPLIED_ASSET
          ? tokenProvidedAmount.sub(maximumFeeAmount)
          : tokenProvidedAmount,
        quotedTokenReceivedAmount,
        path,
        address(this),
        deadline
      );

      totalTokensBought = amounts[1];

      if (feeType == FeeType.RECEIVED_ASSET) {
        retainedAmount = maximumFeeAmount.min(
          totalTokensBought.sub(quotedTokenReceivedAmount)
        );
        receivedAmount = totalTokensBought.sub(retainedAmount);
      } else {
        retainedAmount = maximumFeeAmount;
        receivedAmount = totalTokensBought;
      }
    } else {
      (address[] memory path, uint256[] memory amounts) = _createPathAndAmounts(
        address(tokenProvided), _WETH, false
      );

      amounts = _UNISWAP_ROUTER.swapExactTokensForTokens(
        feeType == FeeType.SUPPLIED_ASSET
          ? tokenProvidedAmount.sub(maximumFeeAmount)
          : tokenProvidedAmount,
        feeType != FeeType.SUPPLIED_ASSET ? maximumFeeAmount : 0,
        path,
        address(this),
        deadline
      );
      retainedAmount = amounts[1];

      (path, amounts) = _createPathAndAmounts(
        _WETH, tokenReceived, false
      );

      amounts = _UNISWAP_ROUTER.swapExactTokensForTokens(
        feeType == FeeType.ETHER
          ? retainedAmount.sub(maximumFeeAmount)
          : retainedAmount,
        quotedTokenReceivedAmount,
        path,
        address(this),
        deadline
      );

      totalTokensBought = amounts[1];

      if (feeType == FeeType.RECEIVED_ASSET) {
        retainedAmount = maximumFeeAmount.min(
          totalTokensBought.sub(quotedTokenReceivedAmount)
        );
        receivedAmount = totalTokensBought.sub(retainedAmount);
      } else {
        retainedAmount = maximumFeeAmount;
        receivedAmount = totalTokensBought;
      }
    }

    _emitTrade(
      account,
      address(tokenProvided),
      tokenReceivedOrUSDCFlag,
      feeType == FeeType.ETHER
        ? _WETH
        : (feeType == FeeType.RECEIVED_ASSET
          ? tokenReceived
          : address(tokenProvided)
      ),
      tokenProvidedAmount,
      receivedAmount,
      retainedAmount
    );

    if (
      account != address(this) &&
      tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG
    ) {
      _transferToken(ERC20Interface(tokenReceived), account, receivedAmount);
    }
  }

  function _tradeTokenForTokenLegacy(
    address account,
    ERC20Interface tokenProvided,
    address tokenReceivedOrUSDCFlag,
    uint256 tokenProvidedAmount,
    uint256 quotedTokenReceivedAmount,
    uint256 deadline,
    bool routeThroughEther
  ) internal returns (uint256 totalTokensSold) {

    uint256 retainedAmount;
    address tokenReceived;
    address recipient;

    _grantUniswapRouterApprovalIfNecessary(tokenProvided, tokenProvidedAmount);

    if (tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG) {
      recipient = address(this);
      tokenReceived = address(_USDC);
    } else {
      recipient = account;
      tokenReceived = tokenReceivedOrUSDCFlag;
    }

    if (routeThroughEther == false) {
      (address[] memory path, uint256[] memory amounts) = _createPathAndAmounts(
        address(tokenProvided), tokenReceived, false
      );

      amounts = _UNISWAP_ROUTER.swapTokensForExactTokens(
        quotedTokenReceivedAmount,
        tokenProvidedAmount,
        path,
        recipient,
        deadline
      );

      totalTokensSold = amounts[0];
      retainedAmount = tokenProvidedAmount.sub(totalTokensSold);
    } else {
      (address[] memory path, uint256[] memory amounts) = _createPathAndAmounts(
        address(tokenProvided), _WETH, false
      );

      amounts = _UNISWAP_ROUTER.swapExactTokensForTokens(
        tokenProvidedAmount, 0, path, address(this), deadline
      );
      retainedAmount = amounts[1];

      (path, amounts) = _createPathAndAmounts(
        _WETH, tokenReceived, false
      );

      amounts = _UNISWAP_ROUTER.swapTokensForExactTokens(
        quotedTokenReceivedAmount, retainedAmount, path, recipient, deadline
      );

      totalTokensSold = amounts[0];
      retainedAmount = retainedAmount.sub(totalTokensSold);
    }

    _emitTrade(
      account,
      address(tokenProvided),
      tokenReceivedOrUSDCFlag,
      routeThroughEther ? _WETH : address(tokenProvided),
      tokenProvidedAmount,
      quotedTokenReceivedAmount,
      retainedAmount
    );
  }

  struct TradeTokenForTokenWithFeeOnTransferArgs {
    address account;
    ERC20Interface tokenProvided;
    address tokenReceivedOrUSDCFlag;
    uint256 tokenProvidedAmount;
    uint256 tokenProvidedAmountAfterTransferFee;
    uint256 quotedTokenReceivedAmount;
    uint256 quotedTokenReceivedAmountAfterTransferFee;
    uint256 maximumFeeAmount;
    uint256 deadline;
    bool routeThroughEther;
    FeeType feeType;
  }

  function _tradeTokenForTokenWithFeeOnTransfer(
    TradeTokenForTokenWithFeeOnTransferArgs memory args
  ) internal returns (uint256 totalTokensBought) {

    ERC20Interface tokenReceived = (
      args.tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG
        ? ERC20Interface(_USDC)
        : ERC20Interface(args.tokenReceivedOrUSDCFlag)
    );

    _grantUniswapRouterApprovalIfNecessary(
      args.tokenProvided, args.tokenProvidedAmountAfterTransferFee
    );

    { // Scope to avoid stack too deep error.
      (address[] memory path, ) = _createPathAndAmounts(
        address(args.tokenProvided), address(tokenReceived), args.routeThroughEther
      );

      uint256 priorReserveBalanceOfReceivedToken = tokenReceived.balanceOf(
        address(this)
      );

      _UNISWAP_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        args.feeType == FeeType.SUPPLIED_ASSET
          ? args.tokenProvidedAmountAfterTransferFee.sub(args.maximumFeeAmount)
          : args.tokenProvidedAmountAfterTransferFee,
        args.quotedTokenReceivedAmount,
        path,
        address(this),
        args.deadline
      );

      totalTokensBought = tokenReceived.balanceOf(address(this)).sub(
        priorReserveBalanceOfReceivedToken
      );
    }
    uint256 receivedAmountAfterTransferFee;
    if (
      args.account != address(this) &&
      args.tokenReceivedOrUSDCFlag != _TRADE_FOR_USDC_AND_RETAIN_FLAG
    ) {
      {
        uint256 priorRecipientBalanceOfReceivedToken = tokenReceived.balanceOf(
          args.account
        );

        _transferToken(
          tokenReceived,
          args.account,
          args.feeType == FeeType.RECEIVED_ASSET
            ? totalTokensBought.sub(args.maximumFeeAmount)
            : totalTokensBought
        );

        receivedAmountAfterTransferFee = tokenReceived.balanceOf(args.account).sub(
          priorRecipientBalanceOfReceivedToken
        );
      }

      require(
        receivedAmountAfterTransferFee >= args.quotedTokenReceivedAmountAfterTransferFee,
        "Received token amount after transfer fee is less than quoted amount."
      );
    } else {
      receivedAmountAfterTransferFee = args.feeType == FeeType.RECEIVED_ASSET
        ? totalTokensBought.sub(args.maximumFeeAmount)
        : totalTokensBought;
    }

    _emitTrade(
      args.account,
      address(args.tokenProvided),
      args.tokenReceivedOrUSDCFlag,
      args.feeType == FeeType.RECEIVED_ASSET
        ? address(tokenReceived)
        : address(args.tokenProvided),
      args.tokenProvidedAmount,
      receivedAmountAfterTransferFee,
      args.maximumFeeAmount
    );
  }

  function _tradeTokenForTokenWithFeeOnTransferLegacy(
    address account,
    ERC20Interface tokenProvided,
    address tokenReceivedOrUSDCFlag,
    uint256 tokenProvidedAmount,
    uint256 tokenProvidedAmountAfterTransferFee,
    uint256 quotedTokenReceivedAmount,
    uint256 quotedTokenReceivedAmountAfterTransferFee,
    uint256 deadline,
    bool routeThroughEther
  ) internal returns (uint256 totalTokensBought) {

    uint256 retainedAmount;
    uint256 receivedAmountAfterTransferFee;
    ERC20Interface tokenReceived;

    _grantUniswapRouterApprovalIfNecessary(
      tokenProvided, tokenProvidedAmountAfterTransferFee
    );

    { // Scope to avoid stack too deep error.
      address recipient;
      if (tokenReceivedOrUSDCFlag == _TRADE_FOR_USDC_AND_RETAIN_FLAG) {
        recipient = address(this);
        tokenReceived = ERC20Interface(_USDC);
      } else {
        recipient = account;
        tokenReceived = ERC20Interface(tokenReceivedOrUSDCFlag);
      }

      (address[] memory path, ) = _createPathAndAmounts(
        address(tokenProvided), address(tokenReceived), routeThroughEther
      );

      uint256 priorReserveBalanceOfReceivedToken = tokenReceived.balanceOf(
        address(this)
      );

      _UNISWAP_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        tokenProvidedAmountAfterTransferFee,
        quotedTokenReceivedAmount,
        path,
        address(this),
        deadline
      );

      totalTokensBought = tokenReceived.balanceOf(address(this)).sub(
        priorReserveBalanceOfReceivedToken
      );
      retainedAmount = totalTokensBought.sub(quotedTokenReceivedAmount);

      uint256 priorRecipientBalanceOfReceivedToken = tokenReceived.balanceOf(
        recipient
      );

      _transferToken(tokenReceived, recipient, quotedTokenReceivedAmount);

      receivedAmountAfterTransferFee = tokenReceived.balanceOf(recipient).sub(
        priorRecipientBalanceOfReceivedToken
      );

      require(
        receivedAmountAfterTransferFee >= quotedTokenReceivedAmountAfterTransferFee,
        "Received token amount after transfer fee is less than quoted amount."
      );
    }

    _emitTrade(
      account,
      address(tokenProvided),
      tokenReceivedOrUSDCFlag,
      address(tokenReceived),
      tokenProvidedAmount,
      receivedAmountAfterTransferFee,
      retainedAmount
    );
  }

  function _setRole(Role role, address account) internal {

    RoleStatus storage storedRoleStatus = _roles[uint256(role)];

    if (account != storedRoleStatus.account) {
      storedRoleStatus.account = account;
      emit RoleModified(role, account);
    }
  }

  function _emitTrade(
    address account,
    address suppliedAsset,
    address receivedAsset,
    address retainedAsset,
    uint256 suppliedAmount,
    uint256 receivedAmount,
    uint256 retainedAmount
  ) internal {

    emit Trade(
      account,
      suppliedAsset,
      receivedAsset,
      retainedAsset,
      suppliedAmount,
      receivedAmount,
      retainedAmount
    );
  }

  function _fireTradeEvent(
    bool fromReserves,
    bool supplyingEther,
    bool feeInEther,
    address token,
    uint256 suppliedAmount,
    uint256 receivedAmount,
    uint256 retainedAmount
  ) internal {

    emit Trade(
      fromReserves ? address(this) : msg.sender,
      supplyingEther ? address(0) : token,
      supplyingEther ? token : address(0),
      feeInEther
        ? address(0)
        : (token == _TRADE_FOR_USDC_AND_RETAIN_FLAG ? address(_USDC) : token),
      suppliedAmount,
      receivedAmount,
      retainedAmount
    );
  }

  function _isRole(Role role) internal view returns (bool hasRole) {

    hasRole = msg.sender == _roles[uint256(role)].account;
  }

  function _isPaused(Role role) internal view returns (bool paused) {

    paused = _roles[uint256(role)].paused;
  }

  function _isSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) internal pure returns (bool) {

    bytes32 initCodeHash = keccak256(
      abi.encodePacked(
        _WALLET_CREATION_CODE_HEADER,
        initialUserSigningKey,
        _WALLET_CREATION_CODE_FOOTER
      )
    );

    address target;
    for (uint256 nonce = 0; nonce < 10; nonce++) {
      target = address(          // derive the target deployment address.
        uint160(                 // downcast to match the address type.
          uint256(               // cast to uint to truncate upper digits.
            keccak256(           // compute CREATE2 hash using all inputs.
              abi.encodePacked(  // pack all inputs to the hash together.
                _CREATE2_HEADER, // pass in control character + factory address.
                nonce,           // pass in current nonce as the salt.
                initCodeHash     // pass in hash of contract creation code.
              )
            )
          )
        )
      );

      if (target == smartWallet) {
        return true;
      }

      nonce++;
    }

    return false;
  }

  function _transferToken(ERC20Interface token, address to, uint256 amount) internal {

    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(token.transfer.selector, to, amount)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'Transfer out failed.'
    );
  }

  function _transferEther(address recipient, uint256 etherAmount) internal {

    (bool ok, ) = recipient.call.value(etherAmount)("");
    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  function _transferInToken(ERC20Interface token, address from, uint256 amount) internal {

    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(token.transferFrom.selector, from, address(this), amount)
    );

    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'Transfer in failed.'
    );
  }

  function _delegate(address implementation) private {

    assembly {
      calldatacopy(0, 0, calldatasize)
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)
      returndatacopy(0, 0, returndatasize)
      switch result
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  function _ensureSmartWallet(
    address smartWallet, address initialUserSigningKey
  ) internal pure {

    require(
      _isSmartWallet(smartWallet, initialUserSigningKey),
      "Could not resolve smart wallet using provided signing key."
    );
  }

  function _createPathAndAmounts(
    address start, address end, bool routeThroughEther
  ) internal pure returns (address[] memory, uint256[] memory) {

    uint256 pathLength = routeThroughEther ? 3 : 2;
    address[] memory path = new address[](pathLength);
    path[0] = start;

    if (routeThroughEther) {
      path[1] = _WETH;
    }

    path[pathLength - 1] = end;

    return (path, new uint256[](pathLength));
  }

  function _ensureNoEtherFeeTypeWhenNotRouted(
    bool routeThroughEther, FeeType feeType
  ) internal pure {

    require(
      routeThroughEther || feeType != FeeType.ETHER,
      "Cannot take token-for-token fee in Ether unless routed through Ether."
    );
  }

  function _ensureNoEtherFee(FeeType feeType) internal pure {

    require(
      feeType != FeeType.ETHER,
      "Cannot take token-for-token fee in Ether with fee on transfer."
    );
  }

  modifier onlyOwnerOr(Role role) {

    if (!isOwner()) {
      require(_isRole(role), "Caller does not have a required role.");
      require(!_isPaused(role), "Role in question is currently paused.");
    }
    _;
  }
}