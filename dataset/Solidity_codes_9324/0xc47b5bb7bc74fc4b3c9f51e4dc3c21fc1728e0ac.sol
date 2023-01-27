
pragma solidity ^0.7.0;

interface KeeperRegistryBaseInterface {

  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (
      uint256 id
    );

  function performUpkeep(
    uint256 id,
    bytes calldata performData
  ) external returns (
      bool success
    );

  function cancelUpkeep(
    uint256 id
  ) external;

  function addFunds(
    uint256 id,
    uint96 amount
  ) external;


  function getUpkeep(uint256 id)
    external view returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint96 balance,
      address lastKeeper,
      address admin,
      uint64 maxValidBlocknumber
    );

  function getUpkeepCount()
    external view returns (uint256);

  function getCanceledUpkeepList()
    external view returns (uint256[] memory);

  function getKeeperList()
    external view returns (address[] memory);

  function getKeeperInfo(address query)
    external view returns (
      address payee,
      bool active,
      uint96 balance
    );

  function getConfig()
    external view returns (
      uint32 paymentPremiumPPB,
      uint24 checkFrequencyBlocks,
      uint32 checkGasLimit,
      uint24 stalenessSeconds,
      uint16 gasCeilingMultiplier,
      uint256 fallbackGasPrice,
      uint256 fallbackLinkPrice
    );

}

interface KeeperRegistryInterface is KeeperRegistryBaseInterface {

  function checkUpkeep(
    uint256 upkeepId,
    address from
  )
    external
    view
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei,
      int256 linkEth
    );

}

interface KeeperRegistryExecutableInterface is KeeperRegistryBaseInterface {

  function checkUpkeep(
    uint256 upkeepId,
    address from
  )
    external
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      uint256 adjustedGasWei,
      uint256 linkEth
    );

}// MIT
pragma solidity ^0.7.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.7.5;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity >=0.7.5;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.7.0;

interface KeeperCompatibleInterface {


  function checkUpkeep(
    bytes calldata checkData
  )
    external
    returns (
      bool upkeepNeeded,
      bytes memory performData
    );

  function performUpkeep(
    bytes calldata performData
  ) external;

}// MIT
pragma solidity ^0.7.0;

contract KeeperBase {


  function preventExecution()
    internal
    view
  {

    require(tx.origin == address(0), "only for simulated backend");
  }

  modifier cannotExecute()
  {

    preventExecution();
    _;
  }

}// MIT

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
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}// GPL-3.0-or-later

pragma solidity 0.7.6;

interface IOrderMonitor {


    function startMonitor(uint256 _tokenId) external;


    function stopMonitor(uint256 _tokenId) external;


    function getTokenIdsLength() external view returns (uint256);


    function monitorSize() external view returns (uint256);


}// GPL-3.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

interface IOrderManager {


    struct LimitOrderParams {
        address _token0; 
        address _token1; 
        uint24 _fee;
        uint160 _sqrtPriceX96;
        uint128 _amount0;
        uint128 _amount1;
        uint256 _amount0Min;
        uint256 _amount1Min;
    }

    function placeLimitOrder(LimitOrderParams calldata params) external payable returns (uint256 tokenId);


    function processLimitOrder(
        uint256 _tokenId, uint256 _serviceFee, uint256 _monitorFee
    ) external returns (uint128, uint128);


    function canProcess(uint256 _tokenId, uint256 gasPrice) external returns (bool, uint256, uint256);


    function quoteKROM(uint256 weiAmount) external returns (uint256 quote);


    function funding(address owner) external view returns (uint256 balance);


    function feeAddress() external view returns (address);

}// GPL-3.0-or-later

pragma solidity 0.7.6;





contract LimitOrderMonitor is
    Initializable,
    IOrderMonitor,
    KeeperCompatibleInterface,
    KeeperBase {


    using SafeMath for uint256;

    uint256 private constant MAX_INT = 2**256 - 1;
    uint256 private constant MAX_BATCH_SIZE = 100;
    uint256 private constant MAX_MONITOR_SIZE = 10000;

    event BatchProcessed(uint256 batchSize, uint256 gasUsed,
        uint256 paymentPaid, bytes data);

    event BatchSizeChanged(address from, uint256 newValue);

    event MonitorSizeChanged(address from, uint256 newValue);

    event UpkeepIntervalChanged(address from, uint256 newValue);

    event ControllerChanged(address from, address newValue);

    event KeeperChanged(address from, address newValue);

    event MonitorStarted(uint256 tokenId);

    event MonitorStopped(uint256 tokenId);

    mapping (uint256 => uint256) public tokenIndexPerTokenId;

    uint256[] public tokenIds;

    address public controller;

    address public keeper;

    IOrderManager public orderManager;

    IUniswapV3Factory public factory;

    IERC20 public KROM;

    uint256 public lastUpkeep;

    uint256 public batchSize;

    uint256 public override monitorSize;

    uint256 public upkeepInterval;

    constructor () initializer {}

    function initialize (IOrderManager _orderManager,
        IUniswapV3Factory _factory,
        IERC20 _KROM,
        address _keeper,
        uint256 _batchSize,
        uint256 _monitorSize,
        uint256 _upkeepInterval) public initializer {

        require(_batchSize <= MAX_BATCH_SIZE, "INVALID_BATCH_SIZE");
        require(_monitorSize <= MAX_MONITOR_SIZE, "INVALID_MONITOR_SIZE");
        require(_batchSize <= _monitorSize, "SIZE_MISMATCH");

        orderManager = _orderManager;
        factory = _factory;
        KROM = _KROM;

        batchSize = _batchSize;
        monitorSize = _monitorSize;
        upkeepInterval = _upkeepInterval;

        controller = msg.sender;
        keeper = _keeper;

        require(KROM.approve(address(orderManager), MAX_INT));
    }
    
    function startMonitor(uint256 _tokenId) external override {


        isAuthorizedTradeManager(); 
        require(tokenIds.length < monitorSize, "MONITOR_FULL");
        tokenIds.push(_tokenId);
        tokenIndexPerTokenId[_tokenId] = tokenIds.length;

        emit MonitorStarted(_tokenId);
    }

    function stopMonitor(uint256 _tokenId) external override {

        
        isAuthorizedTradeManager();
        _stopMonitor(_tokenId);
        emit MonitorStopped(_tokenId);
    }

    function checkUpkeep(
        bytes calldata
    )
    external override cannotExecute
    returns (
        bool upkeepNeeded,
        bytes memory performData
    ) {


        if (upkeepNeeded = (_getBlockNumber() - lastUpkeep) > upkeepInterval) {
            uint256 _tokenId;
            uint256[] memory batchTokenIds = new uint256[](batchSize);
            uint256 count;

            for (uint256 i = 0; i < tokenIds.length; i++) {
                _tokenId = tokenIds[i];
                (upkeepNeeded,,) = orderManager.canProcess(
                    _tokenId,
                    _getGasPrice(tx.gasprice)
                );
                if (upkeepNeeded) {
                    batchTokenIds[count] = _tokenId;
                    count++;
                }
                if (count >= batchSize) {
                    break;
                }
            }

            upkeepNeeded = count > 0;
            if (upkeepNeeded) {
                performData = abi.encode(batchTokenIds, count);
            }
        }
    }

    function performUpkeep(
        bytes calldata performData
    ) external override {


        uint256 _gasUsed = gasleft();

        (uint256[] memory _tokenIds, uint256 _count) = abi.decode(
            performData, (uint256[], uint256)
        );

        uint256 serviceFeePaid;
        uint256 monitorFeePaid;
        uint256 validCount;

        {
            bool validTrade;
            uint256 _serviceFee;
            uint256 _monitorFee;
            uint256 _tokenId;

            require(_count <= _tokenIds.length, "LOC_CL");
            require(_count <= batchSize, "LOC_BS");
            for (uint256 i = 0; i < _count; i++) {
                _tokenId = _tokenIds[i];
                (validTrade, _serviceFee, _monitorFee) = orderManager.canProcess(_tokenId, _getGasPrice(tx.gasprice));
                if (validTrade) {
                    validCount++;
                    _stopMonitor(_tokenId);
                    orderManager.processLimitOrder(
                        _tokenId, _serviceFee, _monitorFee
                    );
                    serviceFeePaid = serviceFeePaid.add(_serviceFee);
                    monitorFeePaid = monitorFeePaid.add(_monitorFee);
                }
            }
        }

        require(validCount > 0, "LOC_VC");

        _gasUsed = _gasUsed - gasleft();
        lastUpkeep = _getBlockNumber();

        _transferFees(monitorFeePaid, keeper);
        _transferFees(serviceFeePaid.sub(monitorFeePaid), orderManager.feeAddress());

        emit BatchProcessed(
            validCount,
            _gasUsed,
            serviceFeePaid,
            performData
        );
    }

    function setBatchSize(uint256 _batchSize) external {


        isAuthorizedController();
        require(_batchSize <= MAX_BATCH_SIZE, "INVALID_BATCH_SIZE");
        require(_batchSize <= monitorSize, "SIZE_MISMATCH");

        batchSize = _batchSize;
        emit BatchSizeChanged(msg.sender, _batchSize);
    }

    function setMonitorSize(uint256 _monitorSize) external {


        isAuthorizedController();
        require(_monitorSize <= MAX_MONITOR_SIZE, "INVALID_MONITOR_SIZE");
        require(_monitorSize >= batchSize, "SIZE_MISMATCH");

        monitorSize = _monitorSize;
        emit MonitorSizeChanged(msg.sender, _monitorSize);
    }

    function setUpkeepInterval(uint256 _upkeepInterval) external  {


        isAuthorizedController();
        upkeepInterval = _upkeepInterval;
        emit UpkeepIntervalChanged(msg.sender, _upkeepInterval);
    }

    function changeController(address _controller) external {

        
        isAuthorizedController();
        controller = _controller;
        emit ControllerChanged(msg.sender, _controller);
    }

    function changeKeeper(address _keeper) external {


        isAuthorizedController();
        keeper = _keeper;
        emit KeeperChanged(msg.sender, _keeper);
    }

    function _stopMonitor(uint256 _tokenId) internal {


        uint256 tokenIndexToRemove = tokenIndexPerTokenId[_tokenId] - 1;
        uint256 lastTokenId = tokenIds[tokenIds.length - 1];

        removeElementFromArray(tokenIndexToRemove, tokenIds);

        if (tokenIds.length == 0) {
            delete tokenIndexPerTokenId[lastTokenId];
        } else if (tokenIndexToRemove != tokenIds.length) {
            tokenIndexPerTokenId[lastTokenId] = tokenIndexToRemove + 1;
            delete tokenIndexPerTokenId[_tokenId];
        }
    }

    function _getGasPrice(uint256 _txnGasPrice) internal virtual view
    returns (uint256 gasPrice) {

        gasPrice = _txnGasPrice > 0 ? _txnGasPrice : 0;
    }

    function _getBlockNumber() internal virtual view
    returns (uint256 blockNumber) {

        blockNumber = block.number;
    }

    function _transferFees(uint256 _amount, address _owner) internal virtual {

        if (_amount > 0) {
            TransferHelper.safeTransfer(address(KROM), _owner, _amount);
        }
    }

    function getTokenIdsLength() external view override returns (uint256) {

        return tokenIds.length;
    }

    function isAuthorizedController() internal view {

        require(msg.sender == controller, "LOC_AC");
    }

    function isAuthorizedTradeManager() internal view {

        require(msg.sender == address(orderManager), "LOC_ATM");
    }

    function removeElementFromArray(uint256 index, uint256[] storage array) private {

        if (index == array.length - 1) {
            array.pop();
        } else {
            array[index] = array[array.length - 1];
            array.pop();
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.7.6;



contract LimitOrderMonitorChainlinkV2 is LimitOrderMonitor {


    AggregatorV3Interface public FAST_GAS_FEED;

    function initialize(IOrderManager _orderManager,
        IUniswapV3Factory _factory,
        IERC20 _KROM,
        address _keeper,
        uint256 _batchSize,
        uint256 _monitorSize,
        uint256 _upkeepInterval,
        AggregatorV3Interface fastGasFeed) public initializer {


        super.initialize(
            _orderManager, _factory, _KROM, _keeper,
                _batchSize, _monitorSize, _upkeepInterval
        );

        FAST_GAS_FEED = fastGasFeed;
    }

    function _getGasPrice(uint256 _txnGasPrice) internal view virtual override
    returns (uint256 gasPrice) {


        if (_txnGasPrice > 0) {
            return _txnGasPrice;
        }

        uint256 timestamp;
        int256 feedValue;
        (,feedValue,,timestamp,) = FAST_GAS_FEED.latestRoundData();
        gasPrice = uint256(feedValue);
    }
}