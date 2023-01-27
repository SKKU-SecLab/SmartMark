



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


pragma solidity >=0.6.0 <0.8.0;

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
}


pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


pragma solidity >=0.6.0 <0.8.0;

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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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


  function calcSingleInGivenPoolOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountOut,
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


  function isSwapsDisabled() external view returns (bool);


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


  function setSwapsDisabled(bool) external;


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


  function gulp(address) external;


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

  function initialize(
    string calldata name,
    string calldata symbol,
    uint256 minWeightPerSecond,
    uint256 maxWeightPerSecond
  ) external;


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


  function getWeightPerSecondBounds() external view returns (uint256, uint256);


  function setWeightPerSecondBounds(uint256, uint256) external;


  function setWrapper(address, bool) external;


  function getWrapperMode() external view returns (bool);

}


pragma solidity 0.6.12;

interface IPoolRestrictions {

  function getMaxTotalSupply(address _pool) external view returns (uint256);


  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view returns (bool);


  function isVotingSenderAllowed(address _votingAddress, address _sender) external view returns (bool);


  function isWithoutFee(address _addr) external view returns (bool);

}


pragma solidity 0.6.12;

contract PowerIndexAbstractController is Ownable {

  using SafeMath for uint256;

  bytes4 public constant CALL_VOTING_SIG = bytes4(keccak256(bytes("callVoting(address,bytes4,bytes,uint256)")));

  event CallPool(bool indexed success, bytes4 indexed inputSig, bytes inputData, bytes outputData);

  PowerIndexPoolInterface public immutable pool;

  constructor(address _pool) public {
    pool = PowerIndexPoolInterface(_pool);
  }

  function callPool(bytes4 signature, bytes calldata args) external onlyOwner {

    _checkSignature(signature);
    (bool success, bytes memory data) = address(pool).call(abi.encodePacked(signature, args));
    require(success, "NOT_SUCCESS");
    emit CallPool(success, signature, args, data);
  }

  function callVotingByPool(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external {

    require(_restrictions().isVotingSenderAllowed(voting, msg.sender), "SENDER_NOT_ALLOWED");
    pool.callVoting(voting, signature, args, value);
  }

  function migrateController(address newController, address[] calldata addressesToMigrate) external onlyOwner {

    uint256 len = addressesToMigrate.length;
    for (uint256 i = 0; i < len; i++) {
      PowerIndexPoolInterface(addressesToMigrate[i]).setController(newController);
    }
  }

  function _restrictions() internal view returns (IPoolRestrictions) {

    return IPoolRestrictions(pool.getRestrictions());
  }

  function _checkSignature(bytes4 signature) internal pure virtual {

    require(signature != CALL_VOTING_SIG, "SIGNATURE_NOT_ALLOWED");
  }
}


pragma solidity 0.6.12;

interface PowerIndexWrapperInterface {

  function getFinalTokens() external view returns (address[] memory tokens);


  function getCurrentTokens() external view returns (address[] memory tokens);


  function getBalance(address _token) external view returns (uint256);


  function setPiTokenForUnderlyingsMultiple(address[] calldata _underlyingTokens, address[] calldata _piTokens)
    external;


  function setPiTokenForUnderlying(address _underlyingTokens, address _piToken) external;


  function updatePiTokenEthFees(address[] calldata _underlyingTokens) external;


  function withdrawOddEthFee(address payable _recipient) external;


  function calcEthFeeForTokens(address[] memory tokens) external view returns (uint256 feeSum);


  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external payable;


  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external payable;


  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external payable returns (uint256, uint256);


  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external payable returns (uint256, uint256);


  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);


  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);


  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);


  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);

}


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface WrappedPiErc20Interface is IERC20 {

  function deposit(uint256 _amount) external payable returns (uint256);


  function withdraw(uint256 _amount) external payable returns (uint256);


  function changeRouter(address _newRouter) external;


  function setEthFee(uint256 _newEthFee) external;


  function withdrawEthFee(address payable receiver) external;


  function approveUnderlying(address _to, uint256 _amount) external;


  function callExternal(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;


  struct ExternalCallData {
    address destination;
    bytes4 signature;
    bytes args;
    uint256 value;
  }

  function callExternalMultiple(ExternalCallData[] calldata calls) external;


  function getUnderlyingBalance() external view returns (uint256);

}


pragma solidity 0.6.12;


interface WrappedPiErc20FactoryInterface {

  event NewWrappedPiErc20(address indexed token, address indexed wrappedToken, address indexed creator);

  function build(
    address _token,
    address _router,
    string calldata _name,
    string calldata _symbol
  ) external returns (WrappedPiErc20Interface);

}


pragma solidity 0.6.12;

interface IPiRouterFactory {

  function buildRouter(address _piToken, bytes calldata _args) external returns (address);

}


pragma solidity 0.6.12;

contract PowerIndexWrappedController is PowerIndexAbstractController {


  event ReplacePoolTokenWithPiToken(
    address indexed underlyingToken,
    address indexed piToken,
    uint256 balance,
    uint256 piTokenBalance,
    uint256 denormalizedWeight
  );

  event ReplacePoolTokenWithNewVersion(
    address indexed oldToken,
    address indexed newToken,
    address indexed migrator,
    uint256 balance,
    uint256 denormalizedWeight
  );

  event ReplacePoolTokenFinish();

  event SetPoolWrapper(address indexed poolWrapper);

  event CallPoolWrapper(bool indexed success, bytes4 indexed inputSig, bytes inputData, bytes outputData);

  event SetPiTokenFactory(address indexed piTokenFactory);

  event CreatePiToken(address indexed underlyingToken, address indexed piToken, address indexed router);


  PowerIndexWrapperInterface public poolWrapper;

  WrappedPiErc20FactoryInterface public piTokenFactory;

  constructor(
    address _pool,
    address _poolWrapper,
    address _piTokenFactory
  ) public PowerIndexAbstractController(_pool) {
    poolWrapper = PowerIndexWrapperInterface(_poolWrapper);
    piTokenFactory = WrappedPiErc20FactoryInterface(_piTokenFactory);
  }

  function setPoolWrapper(address _poolWrapper) external onlyOwner {

    poolWrapper = PowerIndexWrapperInterface(_poolWrapper);
    emit SetPoolWrapper(_poolWrapper);
  }

  function callPoolWrapper(bytes4 signature, bytes calldata args) external onlyOwner {

    (bool success, bytes memory data) = address(poolWrapper).call(abi.encodePacked(signature, args));
    require(success, "NOT_SUCCESS");
    emit CallPoolWrapper(success, signature, args, data);
  }

  function setPiTokenFactory(address _piTokenFactory) external onlyOwner {

    piTokenFactory = WrappedPiErc20FactoryInterface(_piTokenFactory);
    emit SetPiTokenFactory(_piTokenFactory);
  }

  function createPiToken(
    address _underlyingToken,
    address _routerFactory,
    bytes memory _routerArgs,
    string calldata _name,
    string calldata _symbol
  ) external onlyOwner {

    _createPiToken(_underlyingToken, _routerFactory, _routerArgs, _name, _symbol);
  }

  function replacePoolTokenWithNewPiToken(
    address _underlyingToken,
    address _routerFactory,
    bytes calldata _routerArgs,
    string calldata _name,
    string calldata _symbol
  ) external payable onlyOwner {

    WrappedPiErc20Interface piToken = _createPiToken(_underlyingToken, _routerFactory, _routerArgs, _name, _symbol);
    _replacePoolTokenWithPiToken(_underlyingToken, piToken);
  }

  function replacePoolTokenWithExistingPiToken(address _underlyingToken, WrappedPiErc20Interface _piToken)
    external
    payable
    onlyOwner
  {

    _replacePoolTokenWithPiToken(_underlyingToken, _piToken);
  }

  function replacePoolTokenWithNewVersion(
    address _oldToken,
    address _newToken,
    address _migrator,
    bytes calldata _migratorData
  ) external onlyOwner {

    uint256 denormalizedWeight = pool.getDenormalizedWeight(_oldToken);
    uint256 balance = pool.getBalance(_oldToken);

    pool.unbind(_oldToken);

    IERC20(_oldToken).approve(_migrator, balance);
    (bool success, ) = _migrator.call(_migratorData);
    require(success, "NOT_SUCCESS");

    require(
      IERC20(_newToken).balanceOf(address(this)) >= balance,
      "PiBPoolController:newVersion: insufficient newToken balance"
    );

    IERC20(_newToken).approve(address(pool), balance);
    _bindNewToken(_newToken, balance, denormalizedWeight);

    emit ReplacePoolTokenWithNewVersion(_oldToken, _newToken, _migrator, balance, denormalizedWeight);
  }


  function _replacePoolTokenWithPiToken(address _underlyingToken, WrappedPiErc20Interface _piToken) internal {

    uint256 denormalizedWeight = pool.getDenormalizedWeight(_underlyingToken);
    uint256 balance = pool.getBalance(_underlyingToken);

    pool.unbind(_underlyingToken);

    IERC20(_underlyingToken).approve(address(_piToken), balance);
    uint256 piTokenBalance = _piToken.deposit{ value: msg.value }(balance);

    _piToken.approve(address(pool), piTokenBalance);
    _bindNewToken(address(_piToken), piTokenBalance, denormalizedWeight);

    if (address(poolWrapper) != address(0)) {
      poolWrapper.setPiTokenForUnderlying(_underlyingToken, address(_piToken));
    }

    emit ReplacePoolTokenWithPiToken(_underlyingToken, address(_piToken), balance, piTokenBalance, denormalizedWeight);
  }

  function _bindNewToken(
    address _piToken,
    uint256 _balance,
    uint256 _denormalizedWeight
  ) internal virtual {

    pool.bind(_piToken, _balance, _denormalizedWeight);
  }

  function _createPiToken(
    address _underlyingToken,
    address _routerFactory,
    bytes memory _routerArgs,
    string calldata _name,
    string calldata _symbol
  ) internal returns (WrappedPiErc20Interface) {

    WrappedPiErc20Interface piToken = piTokenFactory.build(_underlyingToken, address(this), _name, _symbol);
    address router = IPiRouterFactory(_routerFactory).buildRouter(address(piToken), _routerArgs);
    Ownable(router).transferOwnership(msg.sender);
    piToken.changeRouter(router);

    emit CreatePiToken(_underlyingToken, address(piToken), router);
    return piToken;
  }
}


pragma solidity 0.6.12;

interface PowerIndexPoolControllerInterface {

  function rebindByStrategyAdd(
    address token,
    uint256 balance,
    uint256 denorm,
    uint256 deposit
  ) external;


  function rebindByStrategyRemove(
    address token,
    uint256 balance,
    uint256 denorm
  ) external;


  function bindByStrategy(
    address token,
    uint256 balance,
    uint256 denorm
  ) external;


  function unbindByStrategy(address token) external;

}


pragma solidity 0.6.12;

contract PowerIndexPoolController is PowerIndexPoolControllerInterface, PowerIndexWrappedController {

  using SafeERC20 for IERC20;


  bytes4 public constant BIND_SIG = bytes4(keccak256(bytes("bind(address,uint256,uint256,uint256,uint256)")));

  bytes4 public constant UNBIND_SIG = bytes4(keccak256(bytes("unbind(address)")));

  struct DynamicWeightInput {
    address token;
    uint256 targetDenorm;
    uint256 fromTimestamp;
    uint256 targetTimestamp;
  }

  event SetWeightsStrategy(address indexed weightsStrategy);

  address public weightsStrategy;

  modifier onlyWeightsStrategy() {

    require(msg.sender == weightsStrategy, "ONLY_WEIGHTS_STRATEGY");
    _;
  }

  constructor(
    address _pool,
    address _poolWrapper,
    address _wrapperFactory,
    address _weightsStrategy
  ) public PowerIndexWrappedController(_pool, _poolWrapper, _wrapperFactory) {
    weightsStrategy = _weightsStrategy;
  }


  function bind(
    address token,
    uint256 balance,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external onlyOwner {

    _validateNewTokenBind();

    IERC20(token).safeTransferFrom(msg.sender, address(this), balance);
    IERC20(token).approve(address(pool), balance);
    pool.bind(token, balance, targetDenorm, fromTimestamp, targetTimestamp);
  }

  function replaceTokenWithNew(
    address oldToken,
    address newToken,
    uint256 balance,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external onlyOwner {

    _replaceTokenWithNew(oldToken, newToken, balance, fromTimestamp, targetTimestamp);
  }

  function replaceTokenWithNewFromNow(
    address oldToken,
    address newToken,
    uint256 balance,
    uint256 durationFromNow
  ) external onlyOwner {

    uint256 now = block.timestamp.add(1);
    _replaceTokenWithNew(oldToken, newToken, balance, now, now.add(durationFromNow));
  }

  function setDynamicWeightList(DynamicWeightInput[] memory _dynamicWeights) external onlyOwner {

    uint256 len = _dynamicWeights.length;
    for (uint256 i = 0; i < len; i++) {
      pool.setDynamicWeight(
        _dynamicWeights[i].token,
        _dynamicWeights[i].targetDenorm,
        _dynamicWeights[i].fromTimestamp,
        _dynamicWeights[i].targetTimestamp
      );
    }
  }

  function setWeightsStrategy(address _weightsStrategy) external onlyOwner {

    weightsStrategy = _weightsStrategy;
    emit SetWeightsStrategy(_weightsStrategy);
  }

  function setDynamicWeightListByStrategy(DynamicWeightInput[] memory _dynamicWeights) external onlyWeightsStrategy {

    uint256 len = _dynamicWeights.length;
    for (uint256 i = 0; i < len; i++) {
      pool.setDynamicWeight(
        _dynamicWeights[i].token,
        _dynamicWeights[i].targetDenorm,
        _dynamicWeights[i].fromTimestamp,
        _dynamicWeights[i].targetTimestamp
      );
    }
  }

  function unbindNotActualToken(address _token) external {

    require(pool.getDenormalizedWeight(_token) == pool.getMinWeight(), "DENORM_MIN");
    (, uint256 targetTimestamp, , ) = pool.getDynamicWeightSettings(_token);
    require(block.timestamp > targetTimestamp, "TIMESTAMP_MORE_THEN_TARGET");

    uint256 tokenBalance = pool.getBalance(_token);

    pool.unbind(_token);
    (, , , address communityWallet) = pool.getCommunityFee();
    IERC20(_token).safeTransfer(communityWallet, tokenBalance);
  }

  function _checkSignature(bytes4 signature) internal pure override {

    require(signature != BIND_SIG && signature != UNBIND_SIG && signature != CALL_VOTING_SIG, "SIGNATURE_NOT_ALLOWED");
  }


  function _replaceTokenWithNew(
    address oldToken,
    address newToken,
    uint256 balance,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) internal {

    uint256 minWeight = pool.getMinWeight();
    (, , , uint256 targetDenorm) = pool.getDynamicWeightSettings(oldToken);

    pool.setDynamicWeight(oldToken, minWeight, fromTimestamp, targetTimestamp);

    IERC20(newToken).safeTransferFrom(msg.sender, address(this), balance);
    IERC20(newToken).approve(address(pool), balance);
    pool.bind(newToken, balance, targetDenorm.sub(minWeight), fromTimestamp, targetTimestamp);
  }

  function _validateNewTokenBind() internal {

    address[] memory tokens = pool.getCurrentTokens();
    uint256 tokensLen = tokens.length;
    uint256 minWeight = pool.getMinWeight();

    if (tokensLen == pool.getMaxBoundTokens() - 1) {
      for (uint256 i = 0; i < tokensLen; i++) {
        (, , , uint256 targetDenorm) = pool.getDynamicWeightSettings(tokens[i]);
        if (targetDenorm == minWeight) {
          return;
        }
      }
      revert("NEW_TOKEN_NOT_ALLOWED"); // If there is no tokens with target MIN_WEIGHT
    }
  }

  function rebindByStrategyAdd(
    address token,
    uint256 balance,
    uint256 denorm,
    uint256 deposit
  ) external override onlyWeightsStrategy {

    uint256 balanceBefore = IERC20(token).balanceOf(address(this));

    IERC20(token).safeTransferFrom(msg.sender, address(this), deposit);
    IERC20(token).approve(address(pool), deposit);
    pool.rebind(token, balance, denorm);

    uint256 balanceAfter = IERC20(token).balanceOf(address(this));
    IERC20(token).safeTransfer(msg.sender, balanceAfter.sub(balanceBefore));
  }

  function rebindByStrategyRemove(
    address token,
    uint256 balance,
    uint256 denorm
  ) external override onlyWeightsStrategy {

    uint256 balanceBefore = IERC20(token).balanceOf(address(this));
    pool.rebind(token, balance, denorm);
    uint256 balanceAfter = IERC20(token).balanceOf(address(this));
    IERC20(token).safeTransfer(msg.sender, balanceAfter.sub(balanceBefore));
  }

  function bindByStrategy(
    address token,
    uint256 balance,
    uint256 denorm
  ) external override onlyWeightsStrategy {

    IERC20(token).safeTransferFrom(msg.sender, address(this), balance);
    IERC20(token).approve(address(pool), balance);
    pool.bind(token, balance, denorm);
  }

  function unbindByStrategy(address token) external override onlyWeightsStrategy {

    uint256 balanceBefore = IERC20(token).balanceOf(address(this));
    pool.unbind(token);
    uint256 balanceAfter = IERC20(token).balanceOf(address(this));
    IERC20(token).safeTransfer(msg.sender, balanceAfter.sub(balanceBefore));
  }
}