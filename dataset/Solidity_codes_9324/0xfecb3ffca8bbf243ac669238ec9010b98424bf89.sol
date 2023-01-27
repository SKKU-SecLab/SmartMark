
pragma solidity ^0.7.4;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

}// None

pragma solidity ^0.7.5;


interface IBPool is IERC20 {

    function getFinalTokens() external view returns(address[] memory);

    function getDenormalizedWeight(address token) external view returns (uint256);

    function setSwapFee(uint256 swapFee) external;

    function setController(address controller) external;

    function finalize() external;

    function bind(address token, uint256 balance, uint256 denorm) external;

    function getBalance(address token) external view returns (uint);

    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

}// None

pragma solidity ^0.7.5;


interface IBFactory {

  function newBPool() external returns (IBPool);

}// None

pragma solidity ^0.7.5;


interface ICoverERC20 is IERC20 {

  function owner() external view returns (address);

}// No License

pragma solidity ^0.7.3;


interface ICover {

  function owner() external view returns (address);

  function expirationTimestamp() external view returns (uint48);

  function collateral() external view returns (address);

  function claimCovToken() external view returns (ICoverERC20);

  function noclaimCovToken() external view returns (ICoverERC20);

  function claimNonce() external view returns (uint256);


  function redeemClaim() external;

  function redeemNoclaim() external;

  function redeemCollateral(uint256 _amount) external;

}// No License

pragma solidity ^0.7.3;

interface IProtocol {

  function owner() external view returns (address);

  function active() external view returns (bool);

  function name() external view returns (bytes32);

  function claimNonce() external view returns (uint256);

  function claimRedeemDelay() external view returns (uint256);

  function noclaimRedeemDelay() external view returns (uint256);

  function activeCovers(uint256 _index) external view returns (address);

  function claimDetails(uint256 _claimNonce) external view returns (uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint48 _timestamp);

  function collateralStatusMap(address _collateral) external view returns (uint8 _status);

  function expirationTimestampMap(uint48 _expirationTimestamp) external view returns (bytes32 _name, uint8 _status);

  function coverMap(address _collateral, uint48 _expirationTimestamp) external view returns (address);


  function collaterals(uint256 _index) external view returns (address);

  function collateralsLength() external view returns (uint256);

  function expirationTimestamps(uint256 _index) external view returns (uint48);

  function expirationTimestampsLength() external view returns (uint256);

  function activeCoversLength() external view returns (uint256);

  function claimsLength() external view returns (uint256);

  function addCover(address _collateral, uint48 _timestamp, uint256 _amount)
    external returns (bool);

}// None
pragma solidity ^0.7.5;


interface ICoverRouter {

  event PoolUpdate(address indexed covtoken, address indexed pairedToken, address indexed poolAddr);
  event AddLiquidity(address indexed account, address indexed poolAddr);
  event RemoveLiquidity(address indexed account, address indexed poolAddr);

  function poolForPair(address _covToken, address _pairedToken) external view returns (address);


  function createNewPool(ICoverERC20 _covToken, uint256 _covAmount, IERC20 _pairedToken, uint256 _pairedAmount) external returns (address);

  function addLiquidity(ICoverERC20 _covToken,uint256 _covTokenAmount, IERC20 _pairedToken, uint256 _pairedTokenAmount, bool _addBuffer) external;

  function removeLiquidity(ICoverERC20 _covToken, IERC20 _pairedToken, uint256 _btpAmount) external;


  function addCoverAndAddLiquidity(
    IProtocol _protocol,
    IERC20 _collateral,
    uint48 _timestamp,
    uint256 _amount,
    IERC20 _pairedToken,
    uint256 _claimPairedTokenAmount,
    uint256 _noclaimPairedTokenAmount,
    bool _addBuffer
  ) external;

  function rolloverAndAddLiquidity(
    ICover _cover,
    uint48 _newTimestamp,
    IERC20 _pairedToken,
    uint256 _claimPairedTokenAmount,
    uint256 _noclaimPairedTokenAmount,
    bool _addBuffer
  ) external;

  function rolloverAndAddLiquidityForAccount(
    address _account,
    ICover _cover,
    uint48 _newTimestamp,
    IERC20 _pairedToken,
    uint256 _claimPairedTokenAmount,
    uint256 _noclaimPairedTokenAmount,
    bool _addBuffer
  ) external;

  function addCoverAndCreatePools(
    IProtocol _protocol,
    IERC20 _collateral,
    uint48 _timestamp,
    uint256 _amount,
    IERC20 _pairedToken,
    uint256 _claimPairedTokenAmount,
    uint256 _noclaimPairedTokenAmount
  ) external;


  function setPoolForPair(address _covToken, address _pairedToken, address _newPool) external;

  function setPoolsForPairs(address[] memory _covTokens, address[] memory _pairedTokens, address[] memory _newPools) external;

  function setCovTokenWeights(uint256 _claimCovTokenWeight, uint256 _noclaimCovTokenWeight) external;

  function setSwapFee(uint256 _claimSwapFees, uint256 _noclaimSwapFees) external;

}// None

pragma solidity ^0.7.4;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// None

pragma solidity ^0.7.4;

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
}// MIT

pragma solidity ^0.7.4;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}// MIT

pragma solidity ^0.7.5;


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
}// None
pragma solidity ^0.7.5;

interface IRollover {

  event RolloverCover(address indexed _account, address _protocol);

  function rollover(address _cover, uint48 _newTimestamp) external;

  function rolloverAccount(address _account, address _cover, uint48 _newTimestamp) external;

}// None
pragma solidity ^0.7.5;


contract Rollover is IRollover {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  function rollover(address _cover, uint48 _newTimestamp) external override {

    _rolloverAccount(msg.sender, _cover, _newTimestamp, true);
  }

  function rolloverAccount(address _account, address _cover, uint48 _newTimestamp) public override {

    _rolloverAccount(_account, _cover, _newTimestamp, true);
  }

  function _rolloverAccount(
    address _account,
    address _cover,
    uint48 _newTimestamp,
    bool _isLastStep
  ) internal {

    ICover cover = ICover(_cover);
    uint48 expirationTimestamp = cover.expirationTimestamp();
    require(expirationTimestamp != _newTimestamp && block.timestamp < _newTimestamp, "Rollover: invalid expiry");

    IProtocol protocol = IProtocol(cover.owner());
    bool acceptedClaim = cover.claimNonce() != protocol.claimNonce();
    require(!acceptedClaim, "Rollover: there is an accepted claim");

    (, uint8 expirationStatus) = protocol.expirationTimestampMap(_newTimestamp);
    require(expirationStatus == 1, "Rollover: new timestamp is not active");

    if (block.timestamp < expirationTimestamp) {
      _redeemCollateral(cover, _account);
    } else {
      require(block.timestamp >= uint256(expirationTimestamp).add(protocol.noclaimRedeemDelay()), "Rollover: not ready");
      _redeemNoclaim(cover, _account);
    }
    IERC20 collateral = IERC20(cover.collateral());
    uint256 redeemedAmount = collateral.balanceOf(address(this));

    _addCover(protocol, address(collateral), _newTimestamp, redeemedAmount);
    emit RolloverCover(_account, address(protocol));
    if (_isLastStep) {
      _sendCovTokensToAccount(protocol, address(collateral), _newTimestamp, _account);
    }
  }

  function _approve(IERC20 _token, address _spender, uint256 _amount) internal {

    if (_token.allowance(address(this), _spender) < _amount) {
      _token.approve(_spender, uint256(-1));
    }
  }

  function _addCover(
    IProtocol _protocol,
    address _collateral,
    uint48 _timestamp,
    uint256 _amount
  ) internal {

    _approve(IERC20(_collateral), address(_protocol), _amount);
    _protocol.addCover(address(_collateral), _timestamp, _amount);
  }

  function _sendCovTokensToAccount(
    IProtocol protocol,
    address _collateral,
    uint48 _timestamp,
    address _account
  ) private {

    ICover newCover = ICover(protocol.coverMap(_collateral, _timestamp));

    IERC20 newClaimCovToken = newCover.claimCovToken();
    IERC20 newNoclaimCovToken = newCover.noclaimCovToken();

    newClaimCovToken.safeTransfer(_account, newClaimCovToken.balanceOf(address(this)));
    newNoclaimCovToken.safeTransfer(_account, newNoclaimCovToken.balanceOf(address(this)));
  }

  function _redeemCollateral(ICover cover, address _account) private {

    IERC20 claimCovToken = cover.claimCovToken();
    IERC20 noclaimCovToken = cover.noclaimCovToken();
    uint256 claimCovTokenBal = claimCovToken.balanceOf(_account);
    uint256 noclaimCovTokenBal = noclaimCovToken.balanceOf(_account);
    uint256 amount = (claimCovTokenBal > noclaimCovTokenBal) ? noclaimCovTokenBal : claimCovTokenBal;
    require(amount > 0, "Rollover: insufficient covTokens");

    claimCovToken.safeTransferFrom(_account, address(this), amount);
    noclaimCovToken.safeTransferFrom(_account, address(this), amount);

    cover.redeemCollateral(amount);
  }

  function _redeemNoclaim(ICover cover, address _account) private {

    IERC20 noclaimCovToken = cover.noclaimCovToken();
    uint256 amount = noclaimCovToken.balanceOf(_account);
    require(amount > 0, "Rollover: insufficient NOCLAIM covTokens");
    noclaimCovToken.safeTransferFrom(_account, address(this), amount);

    cover.redeemNoclaim();
  }
}// None
pragma solidity ^0.7.5;


contract CoverRouter is ICoverRouter, Ownable, Rollover {

  using SafeERC20 for IBPool;
  using SafeERC20 for ICoverERC20;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  address public protocolFactory;
  IBFactory public bFactory;
  uint256 public constant TOTAL_WEIGHT = 50 ether;
  uint256 public claimCovTokenWeight = 40 ether;
  uint256 public noclaimCovTokenWeight = 49 ether;
  uint256 public claimSwapFee = 0.02 ether;
  uint256 public noclaimSwapFee = 0.01 ether;
  mapping(bytes32 => address) private pools;

  constructor(address _protocolFactory, IBFactory _bFactory) {
    protocolFactory = _protocolFactory;
    bFactory = _bFactory;
  }

  function poolForPair(address _covToken, address _pairedToken) external override view returns (address) {

    bytes32 pairKey = _pairKeyForPair(_covToken, _pairedToken);
    return pools[pairKey];
  }

  function addCoverAndAddLiquidity(
    IProtocol _protocol,
    IERC20 _collateral,
    uint48 _timestamp,
    uint256 _amount,
    IERC20 _pairedToken,
    uint256 _claimPTAmt,
    uint256 _noclaimPTAmt,
    bool _addBuffer
  ) external override {

    require(_amount > 0 && _claimPTAmt > 0 && _noclaimPTAmt > 0, "CoverRouter: amount is 0");
    _collateral.safeTransferFrom(msg.sender, address(this), _amount);
    _addCover(_protocol, address(_collateral), _timestamp, _collateral.balanceOf(address(this)));

    ICover cover = ICover(_protocol.coverMap(address(_collateral), _timestamp));
    _addLiquidityForCover(msg.sender, cover, _pairedToken, _claimPTAmt, _noclaimPTAmt, _addBuffer);
  }

  function rolloverAndAddLiquidityForAccount(
    address _account,
    ICover _cover,
    uint48 _newTimestamp,
    IERC20 _pairedToken,
    uint256 _claimPTAmt,
    uint256 _noclaimPTAmt,
    bool _addBuffer
  ) public override {

    _rolloverAccount(_account, address(_cover), _newTimestamp, false);

    IProtocol protocol = IProtocol(_cover.owner());
    ICover newCover = ICover(protocol.coverMap(_cover.collateral(), _newTimestamp));
    _addLiquidityForCover(_account, newCover, _pairedToken, _claimPTAmt, _noclaimPTAmt, _addBuffer);
  }

  function rolloverAndAddLiquidity(
    ICover _cover,
    uint48 _newTimestamp,
    IERC20 _pairedToken,
    uint256 _claimPTAmt,
    uint256 _noclaimPTAmt,
    bool _addBuffer
  ) external override {

    rolloverAndAddLiquidityForAccount(msg.sender, _cover, _newTimestamp, _pairedToken, _claimPTAmt, _noclaimPTAmt, _addBuffer);
  }

  function removeLiquidity(ICoverERC20 _covToken, IERC20 _pairedToken, uint256 _bptAmount) external override {

    require(_bptAmount > 0, "CoverRouter: insufficient covToken");
    bytes32 pairKey = _pairKeyForPair(address(_covToken), address(_pairedToken));
    IBPool pool = IBPool(pools[pairKey]);
    require(pool.balanceOf(msg.sender) >= _bptAmount, "CoverRouter: insufficient BPT");

    uint256[] memory minAmountsOut = new uint256[](2);
    minAmountsOut[0] = 0;
    minAmountsOut[1] = 0;

    pool.safeTransferFrom(msg.sender, address(this), _bptAmount);
    pool.exitPool(pool.balanceOf(address(this)), minAmountsOut);

    _covToken.safeTransfer(msg.sender, _covToken.balanceOf(address(this)));
    _pairedToken.safeTransfer(msg.sender, _pairedToken.balanceOf(address(this)));
    emit RemoveLiquidity(msg.sender, address(pool));
  }

  function addLiquidity(
    ICoverERC20 _covToken,
    uint256 _covTokenAmount,
    IERC20 _pairedToken,
    uint256 _pairedTokenAmount,
    bool _addBuffer
  ) external override {

    require(_covToken.balanceOf(msg.sender) >= _covTokenAmount, "CoverRouter: insufficient covToken");
    require(_pairedToken.balanceOf(msg.sender) >= _pairedTokenAmount, "CoverRouter: insufficient pairedToken");

    _covToken.safeTransferFrom(msg.sender, address(this), _covTokenAmount);
    _pairedToken.safeTransferFrom(msg.sender, address(this), _pairedTokenAmount);
    _joinPool(msg.sender, _covToken, _pairedToken, _pairedToken.balanceOf(address(this)), _addBuffer);
    _transferRem(msg.sender, _pairedToken);
  }

  function addCoverAndCreatePools(
    IProtocol _protocol,
    IERC20 _collateral,
    uint48 _timestamp,
    uint256 _amount,
    IERC20 _pairedToken,
    uint256 _claimPTAmt,
    uint256 _noclaimPTAmt
  ) external override {

    require(_amount > 0 && _claimPTAmt > 0 && _noclaimPTAmt > 0, "CoverRouter: amount is 0");
    require(_collateral.balanceOf(msg.sender) > _amount, "CoverRouter: insufficient amount");
    _collateral.safeTransferFrom(msg.sender, address(this), _amount);
    _addCover(_protocol, address(_collateral), _timestamp, _collateral.balanceOf(address(this)));

    ICover cover = ICover(_protocol.coverMap(address(_collateral), _timestamp));
    ICoverERC20 claimCovToken = cover.claimCovToken();
    ICoverERC20 noclaimCovToken = cover.noclaimCovToken();

    (uint256 claimPTAmt, uint256 noclaimPTAmt) =  _receivePairdTokens(msg.sender, _pairedToken, _claimPTAmt, _noclaimPTAmt);
    bytes32 claimPairKey = _pairKeyForPair(address(claimCovToken), address(_pairedToken));
    if (pools[claimPairKey] == address(0)) {
      pools[claimPairKey] = _createBalPoolAndTransferBpt(msg.sender, claimCovToken, _pairedToken, claimPTAmt, true);
    }
    bytes32 noclaimPairKey = _pairKeyForPair(address(noclaimCovToken), address(_pairedToken));
    if (pools[noclaimPairKey] == address(0)) {
      pools[noclaimPairKey] = _createBalPoolAndTransferBpt(msg.sender, noclaimCovToken, _pairedToken, noclaimPTAmt, false);
    }
    _transferRem(msg.sender, _pairedToken);
  }

  function createNewPool(
    ICoverERC20 _covToken,
    uint256 _covTokenAmount,
    IERC20 _pairedToken,
    uint256 _pairedTokenAmount
  ) external override returns (address pool) {

    require(address(_pairedToken) != address(_covToken), "CoverRouter: same token");
    bytes32 pairKey = _pairKeyForPair(address(_covToken), address(_pairedToken));
    require(pools[pairKey] == address(0), "CoverRouter: pool already exists");
    _validCovToken(address(_covToken));

    ICover cover = ICover(ICoverERC20(_covToken).owner());
    bool isClaimPair = cover.claimCovToken() == _covToken;

    _covToken.safeTransferFrom(msg.sender, address(this), _covTokenAmount);
    _pairedToken.safeTransferFrom(msg.sender, address(this), _pairedTokenAmount);
    pool = _createBalPoolAndTransferBpt(msg.sender, _covToken, _pairedToken, _pairedToken.balanceOf(address(this)), isClaimPair);
    pools[pairKey] = pool;
  }

  function setSwapFee(uint256 _claimSwapFees, uint256 _noclaimSwapFees) external override onlyOwner {

    require(_claimSwapFees > 0 && _noclaimSwapFees > 0, "CoverRouter: invalid fees");
    claimSwapFee = _claimSwapFees;
    noclaimSwapFee = _noclaimSwapFees;
  }

  function setCovTokenWeights(uint256 _claimCovTokenWeight, uint256 _noclaimCovTokenWeight) external override onlyOwner {

    require(_claimCovTokenWeight < TOTAL_WEIGHT, "CoverRouter: invalid claim weight");
    require(_noclaimCovTokenWeight < TOTAL_WEIGHT, "CoverRouter: invalid noclaim weight");
    claimCovTokenWeight = _claimCovTokenWeight;
    noclaimCovTokenWeight = _noclaimCovTokenWeight;
  }

  function setPoolForPair(address _covToken, address _pairedToken, address _newPool) public override onlyOwner {

    _validCovToken(_covToken);
    _validBalPoolTokens(_covToken, _pairedToken, IBPool(_newPool));

    bytes32 pairKey = _pairKeyForPair(_covToken, _pairedToken);
    pools[pairKey] = _newPool;
    emit PoolUpdate(_covToken, _pairedToken, _newPool);
  }

  function setPoolsForPairs(address[] memory _covTokens, address[] memory _pairedTokens, address[] memory _newPools) external override onlyOwner {

    require(_covTokens.length == _pairedTokens.length, "CoverRouter: Paired tokens length not equal");
    require(_covTokens.length == _newPools.length, "CoverRouter: Pools length not equal");

    for (uint256 i = 0; i < _covTokens.length; i++) {
      setPoolForPair(_covTokens[i], _pairedTokens[i], _newPools[i]);
    }
  }

  function _pairKeyForPair(address _covToken, address _pairedToken) internal view returns (bytes32 pairKey) {

    (address token0, address token1) = _covToken < _pairedToken ? (_covToken, _pairedToken) : (_pairedToken, _covToken);
    pairKey = keccak256(abi.encodePacked(
      protocolFactory,
      token0,
      token1
    ));
  }

  function _getBptAmountOut(
    IBPool pool,
    address _covToken,
    uint256 _covTokenAmount,
    address _pairedToken,
    uint256 _pairedTokenAmount,
    bool _addBuffer
  ) internal view returns (uint256 bptAmountOut, uint256[] memory maxAmountsIn) {

    uint256 poolAmountOutInCov = _covTokenAmount.mul(pool.totalSupply()).div(pool.getBalance(_covToken));
    uint256 poolAmountOutInPaired = _pairedTokenAmount.mul(pool.totalSupply()).div(pool.getBalance(_pairedToken));
    bptAmountOut = poolAmountOutInCov > poolAmountOutInPaired ? poolAmountOutInPaired : poolAmountOutInCov;
    bptAmountOut = _addBuffer ? bptAmountOut.mul(99).div(100) : bptAmountOut;

    address[] memory tokens = pool.getFinalTokens();
    maxAmountsIn = new uint256[](2);
    maxAmountsIn[0] =  _covTokenAmount;
    maxAmountsIn[1] = _pairedTokenAmount;
    if (tokens[1] == _covToken) {
      maxAmountsIn[0] =  _pairedTokenAmount;
      maxAmountsIn[1] = _covTokenAmount;
    }
  }

  function _validCovToken(address _covToken) private view {

    require(_covToken != address(0), "CoverRouter: covToken is 0 address");

    ICover cover = ICover(ICoverERC20(_covToken).owner());
    address tokenProtocolFactory = IProtocol(cover.owner()).owner();
    require(tokenProtocolFactory == protocolFactory, "CoverRouter: wrong factory");
  }

  function _validBalPoolTokens(address _covToken, address _pairedToken, IBPool _pool) private view {

    require(_pairedToken != _covToken, "CoverRouter: same token");
    address[] memory tokens = _pool.getFinalTokens();
    require(tokens.length == 2, "CoverRouter: Too many tokens in pool");
    require((_covToken == tokens[0] && _pairedToken == tokens[1]) || (_pairedToken == tokens[0] && _covToken == tokens[1]), "CoverRouter: tokens don't match");
  }

  function _joinPool(
    address _account,
    IERC20 _covToken,
    IERC20 _pairedToken,
    uint256 _pairedTokenAmount,
    bool _addBuffer
  ) internal {

    address poolAddr = pools[_pairKeyForPair(address(_covToken), address(_pairedToken))];
    require(poolAddr != address(0), "CoverRouter: pool not found");

    IBPool pool = IBPool(poolAddr);
    uint256 covTokenAmount = _covToken.balanceOf(address(this));
    (uint256 bptAmountOut, uint256[] memory maxAmountsIn) = _getBptAmountOut(pool, address(_covToken), covTokenAmount, address(_pairedToken), _pairedTokenAmount, _addBuffer);
    _approve(_covToken, poolAddr, covTokenAmount);
    _approve(_pairedToken, poolAddr, _pairedTokenAmount);
    pool.joinPool(bptAmountOut, maxAmountsIn);

    pool.safeTransfer(_account, pool.balanceOf(address(this)));
    _transferRem(_account, _covToken);
    emit AddLiquidity(_account, poolAddr);
  }

  function _transferRem(address _account, IERC20 token) internal {

    uint256 rem = token.balanceOf(address(this));
    if (rem > 0) {
      token.safeTransfer(_account, rem);
    }
  }

  function _receivePairdTokens(
    address _account,
    IERC20 _pairedToken,
    uint256 _claimPTAmt,
    uint256 _noclaimPTAmt
  ) internal returns (uint256 receivedClaimPTAmt, uint256 receivedNoclaimPTAmt) {

    uint256 total = _claimPTAmt.add(_noclaimPTAmt);
    _pairedToken.safeTransferFrom(_account, address(this), total);
    uint256 bal = _pairedToken.balanceOf(address(this));
    receivedClaimPTAmt = bal.mul(_claimPTAmt).div(total);
    receivedNoclaimPTAmt = bal.mul(_noclaimPTAmt).div(total);
  }

  function _addLiquidityForCover(
    address _account,
    ICover _cover,
    IERC20 _pairedToken,
    uint256 _claimPTAmt,
    uint256 _noclaimPTAmt,
    bool _addBuffer
  ) private {

    IERC20 claimCovToken = _cover.claimCovToken();
    IERC20 noclaimCovToken = _cover.noclaimCovToken();
    (uint256 claimPTAmt, uint256 noclaimPTAmt) =  _receivePairdTokens(_account, _pairedToken, _claimPTAmt, _noclaimPTAmt);

    _joinPool(_account, claimCovToken, _pairedToken, claimPTAmt, _addBuffer);
    _joinPool(_account, noclaimCovToken, _pairedToken, noclaimPTAmt, _addBuffer);
    _transferRem(_account, _pairedToken);
  }

  function _createBalPoolAndTransferBpt(
    address _account,
    IERC20 _covToken,
    IERC20 _pairedToken,
    uint256 _pairedTokenAmount,
    bool _isClaimPair
  ) private returns (address poolAddr) {

    IBPool pool = bFactory.newBPool();
    poolAddr = address(pool);

    uint256 _covTokenSwapFee = claimSwapFee;
    uint256 _covTokenWeight = claimCovTokenWeight;
    if (!_isClaimPair) {
      _covTokenSwapFee = noclaimSwapFee;
      _covTokenWeight = noclaimCovTokenWeight;
    }
    pool.setSwapFee(_covTokenSwapFee);
    uint256 covTokenAmount = _covToken.balanceOf(address(this));
    _approve(_covToken, poolAddr, covTokenAmount);
    pool.bind(address(_covToken), covTokenAmount, _covTokenWeight);
    _approve(_pairedToken, poolAddr, _pairedTokenAmount);
    pool.bind(address(_pairedToken), _pairedTokenAmount, TOTAL_WEIGHT.sub(_covTokenWeight));

    pool.finalize();
    emit PoolUpdate(address(_covToken), address(_pairedToken), poolAddr);
    pool.safeTransfer(_account, pool.balanceOf(address(this)));
  }
}