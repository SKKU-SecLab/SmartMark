



pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.6.12;

interface BMathInterface {

  function calcInGivenOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);

}


pragma solidity 0.6.12;



interface BPoolInterface is IERC20, BMathInterface {

  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);


  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);


  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function getDenormalizedWeight(address) external view returns (uint256);


  function getBalance(address) external view returns (uint256);


  function getSwapFee() external view returns (uint256);


  function getTotalDenormalizedWeight() external view returns (uint256);


  function getCommunityFee()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      address
    );


  function calcAmountWithCommunityFee(
    uint256,
    uint256,
    address
  ) external view returns (uint256, uint256);


  function getRestrictions() external view returns (address);


  function isPublicSwap() external view returns (bool);


  function isFinalized() external view returns (bool);


  function isBound(address t) external view returns (bool);


  function getCurrentTokens() external view returns (address[] memory tokens);


  function getFinalTokens() external view returns (address[] memory tokens);


  function setSwapFee(uint256) external;


  function setCommunityFeeAndReceiver(
    uint256,
    uint256,
    uint256,
    address
  ) external;


  function setController(address) external;


  function setPublicSwap(bool) external;


  function finalize() external;


  function bind(
    address,
    uint256,
    uint256
  ) external;


  function rebind(
    address,
    uint256,
    uint256
  ) external;


  function unbind(address) external;


  function callVoting(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;


  function getMinWeight() external view returns (uint256);


  function getMaxBoundTokens() external view returns (uint256);

}


pragma solidity 0.6.12;


interface PowerIndexPoolInterface is BPoolInterface {

  function bind(
    address,
    uint256,
    uint256,
    uint256,
    uint256
  ) external;


  function setDynamicWeight(
    address token,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external;


  function getDynamicWeightSettings(address token)
    external
    view
    returns (
      uint256 fromTimestamp,
      uint256 targetTimestamp,
      uint256 fromDenorm,
      uint256 targetDenorm
    );


  function getMinWeight() external view override returns (uint256);

}


pragma solidity 0.6.12;


interface PowerIndexPoolFactoryInterface {

  function newPool(
    string calldata name,
    string calldata symbol,
    uint256 minWeightPerSecond,
    uint256 maxWeightPerSecond
  ) external returns (PowerIndexPoolInterface);

}





pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




contract PowerIndexPoolActions {

  struct Args {
    uint256 minWeightPerSecond;
    uint256 maxWeightPerSecond;
    uint256 swapFee;
    uint256 communitySwapFee;
    uint256 communityJoinFee;
    uint256 communityExitFee;
    address communityFeeReceiver;
    bool finalize;
  }

  struct TokenConfig {
    address token;
    uint256 balance;
    uint256 targetDenorm;
    uint256 fromTimestamp;
    uint256 targetTimestamp;
  }

  function create(
    PowerIndexPoolFactoryInterface factory,
    string calldata name,
    string calldata symbol,
    Args calldata args,
    TokenConfig[] calldata tokens
  ) external returns (PowerIndexPoolInterface pool) {

    pool = factory.newPool(name, symbol, args.minWeightPerSecond, args.maxWeightPerSecond);
    pool.setSwapFee(args.swapFee);
    pool.setCommunityFeeAndReceiver(
      args.communitySwapFee,
      args.communityJoinFee,
      args.communityExitFee,
      args.communityFeeReceiver
    );

    for (uint256 i = 0; i < tokens.length; i++) {
      TokenConfig memory tokenConfig = tokens[i];
      IERC20 token = IERC20(tokenConfig.token);
      require(token.transferFrom(msg.sender, address(this), tokenConfig.balance), "ERR_TRANSFER_FAILED");
      if (token.allowance(address(this), address(pool)) > 0) {
        token.approve(address(pool), 0);
      }
      token.approve(address(pool), tokenConfig.balance);
      pool.bind(
        tokenConfig.token,
        tokenConfig.balance,
        tokenConfig.targetDenorm,
        tokenConfig.fromTimestamp,
        tokenConfig.targetTimestamp
      );
    }

    if (args.finalize) {
      pool.finalize();
      require(pool.transfer(msg.sender, pool.balanceOf(address(this))), "ERR_TRANSFER_FAILED");
    } else {
      pool.setPublicSwap(true);
    }

    pool.setController(msg.sender);
  }
}