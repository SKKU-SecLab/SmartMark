
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

pragma solidity >=0.6.0 <0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity 0.7.6;

interface INutDistributor {

    function updateVtb(address token, address lender, uint incAmount, uint decAmount) external;

    function inNutDistribution() external view returns(bool);

}// MIT

pragma solidity 0.7.6;

interface INut {

    function mint(address receipt, uint amount) external;

    function mintSink(uint amount) external;

}// MIT

pragma solidity 0.7.6;

interface IPriceOracle {

    function getPrice(address token) external view returns (uint);

}// MIT

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity 0.7.6;

contract Governable is Initializable {

  address public governor;
  address public pendingGovernor;

  modifier onlyGov() {

    require(msg.sender == governor, 'bad gov');
    _;
  }

  function __Governable__init(address _governor) internal initializer {

    require( _governor != address(0), 'zero gov');
    governor = _governor;
  }

  function setPendingGovernor(address addr) external onlyGov {

    pendingGovernor = addr;
  }

  function acceptGovernor() external {

    require(msg.sender == pendingGovernor, 'no pend');
    pendingGovernor = address(0);
    governor = msg.sender;
  }
}// MIT

pragma solidity 0.7.6;



contract NutDistributor is Governable, INutDistributor {

    using SafeMath for uint;
    using Math for uint;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Echo {
        uint id;
        uint endBlock;
        uint amount;
    }

    address public nutmeg;
    address public nut;
    address public oracle;

    uint public constant MAX_NUM_POOLS = 256;
    uint public DIST_START_BLOCK; // starting block of echo 0
    uint public constant NUM_EPOCH = 15; // # of epochs
    uint public BLOCKS_PER_EPOCH; // # of blocks per epoch
    uint public constant DIST_START_AMOUNT = 250000 ether; // # of tokens distributed at epoch 0
    uint public constant DIST_MIN_AMOUNT = 18750 ether; // min # of tokens distributed at any epoch

    uint public CURRENT_EPOCH;
    mapping(address => bool) addedPoolMap;
    address[] public pools;
    mapping(uint => Echo) public echoMap;
    mapping(uint => bool) public distCompletionMap;

    mapping(address => uint[15]) public totalVtbMap; // pool => total vtb, i.e., valueTimesBlocks.
    mapping(address => uint[15]) public totalNutMap; // pool => total Nut awarded.
    mapping(address => mapping( address => uint[15] ) ) public vtbMap; // pool => lender => vtb.

    mapping(address => uint) public futureTotalVtbMap;
    mapping(address => mapping( address => uint) ) public futureVtbMap;
    mapping(address => uint) public futureTotalVtbEpoch;
    mapping(address => mapping( address => uint) ) public futureVtbEpoch;

    uint public constant SINK_PERCENTAGE = 20;
    bool public distStarted;

    modifier onlyNutmeg() {

        require(msg.sender == nutmeg, 'only nutmeg can call');
        _;
    }

    function setNutmegAddress(address addr) external onlyGov {

        nutmeg = addr;
    }

    function setPriceOracle(address addr) external onlyGov {

        oracle = addr;
    }

    function initialize(
        address nutAddr, address _governor,
        address oracleAddr, uint blocksPerEpoch
    ) external initializer {

        BLOCKS_PER_EPOCH = blocksPerEpoch;
        nut = nutAddr;
        oracle = oracleAddr;
        __Governable__init(_governor);

        for (uint i = 0; i < NUM_EPOCH; i++) {
            Echo storage echo =  echoMap[i];
            echo.id = i;
            echo.endBlock = BLOCKS_PER_EPOCH.mul(i.add(1));
            uint amount = DIST_START_AMOUNT.div(i.add(1));
            if (amount < DIST_MIN_AMOUNT) {
                amount = DIST_MIN_AMOUNT;
            }
            echo.amount = amount;
        }
    }

    function startDistribution() external onlyGov {

        DIST_START_BLOCK = block.number;
        distStarted = true;
    }

    function inNutDistribution() external override view returns(bool) {

        return (distStarted && block.number >= DIST_START_BLOCK && block.number < DIST_START_BLOCK.add(BLOCKS_PER_EPOCH.mul(NUM_EPOCH)));
    }

    function updateVtb(address token, address lender, uint incAmount, uint decAmount) external override onlyNutmeg {

        require(incAmount == 0 || decAmount == 0, 'updateVtb: update amount is invalid');

        uint amount = incAmount.add(decAmount);
        require(amount > 0, 'updateVtb: update amount should be positive');

        CURRENT_EPOCH = (block.number.sub(DIST_START_BLOCK)).div(BLOCKS_PER_EPOCH);
        if (CURRENT_EPOCH >= NUM_EPOCH) return;

        _fillVtbGap(token, lender);
        _fillTotalVtbGap(token);

        uint dv = echoMap[CURRENT_EPOCH].endBlock.add(DIST_START_BLOCK).sub( block.number ).mul(amount);
        uint epochDv = BLOCKS_PER_EPOCH.mul(amount);

        if (incAmount > 0) {
            vtbMap[token][lender][CURRENT_EPOCH] = vtbMap[token][lender][CURRENT_EPOCH].add(dv);
            totalVtbMap[token][CURRENT_EPOCH] = totalVtbMap[token][CURRENT_EPOCH].add(dv);
            futureVtbMap[token][lender] = futureVtbMap[token][lender].add(epochDv);
            futureTotalVtbMap[token] = futureTotalVtbMap[token].add(epochDv);
        } else {
            if (dv > vtbMap[token][lender][CURRENT_EPOCH]) {
               dv = vtbMap[token][lender][CURRENT_EPOCH];
            }
            if (epochDv > futureVtbMap[token][lender]) {
               epochDv = futureVtbMap[token][lender];
            }
            vtbMap[token][lender][CURRENT_EPOCH] = vtbMap[token][lender][CURRENT_EPOCH].sub(dv);
            totalVtbMap[token][CURRENT_EPOCH] = totalVtbMap[token][CURRENT_EPOCH].sub(dv);
            futureVtbMap[token][lender] = futureVtbMap[token][lender].sub(epochDv);
            futureTotalVtbMap[token] = futureTotalVtbMap[token].sub(epochDv);
        }

        if (!addedPoolMap[token]) {
            pools.push(token);
            require(pools.length <= MAX_NUM_POOLS, 'too many pools');
            addedPoolMap[token] = true;
        }
    }
    function _fillVtbGap(address token, address lender) internal {

        uint current_epoch =
            block.number.sub(DIST_START_BLOCK).div(BLOCKS_PER_EPOCH).min(NUM_EPOCH - 1);
        if (futureVtbEpoch[token][lender] > current_epoch) return;
        uint futureVtb = futureVtbMap[token][lender];
        for (uint i = futureVtbEpoch[token][lender]; i <= current_epoch; i++) {
            vtbMap[token][lender][i] = futureVtb;
        }
        futureVtbEpoch[token][lender] = current_epoch.add(1);
    }

    function _fillTotalVtbGap(address token) internal {

        uint current_epoch =
            block.number.sub(DIST_START_BLOCK).div(BLOCKS_PER_EPOCH).min(NUM_EPOCH - 1);
        if (futureTotalVtbEpoch[token] > current_epoch) return;
        uint futureTotalVtb = futureTotalVtbMap[token];
        for (uint i = futureTotalVtbEpoch[token]; i <= current_epoch; i++) {
            totalVtbMap[token][i] = futureTotalVtb;
        }
        futureTotalVtbEpoch[token] = current_epoch.add(1);
    }

    function distribute() external onlyGov {

        require(oracle != address(0), 'distribute: no oracle available');
        require(distStarted, 'dist not started');
        uint currEpochId = (block.number.sub(DIST_START_BLOCK)).div(BLOCKS_PER_EPOCH);
        currEpochId = currEpochId > NUM_EPOCH ? NUM_EPOCH : currEpochId;
        require(currEpochId > 0, 'distribute: nut token distribution not ready');
        require(distCompletionMap[NUM_EPOCH.sub(1)] == false, 'distribute: nut token distribution is over');

        bool tokensDistributed = false;
        for (uint i1 = 1; i1 <= currEpochId; i1++) {
            uint prevEpochId = currEpochId.sub(i1);
            if (distCompletionMap[prevEpochId]) {
                break;
            }

            uint totalAmount = echoMap[prevEpochId].amount;
            uint sinkAmount = totalAmount.mul(SINK_PERCENTAGE).div(100);
            uint amount = totalAmount.sub(sinkAmount);
            INut(nut).mintSink(sinkAmount);
            INut(nut).mint(address(this), amount);

            uint numOfPools = pools.length < MAX_NUM_POOLS ? pools.length : MAX_NUM_POOLS;
            uint sumOfDv;
            uint actualSumOfNut;
            for (uint i = 0; i < numOfPools; i++) {
                uint price = IPriceOracle(oracle).getPrice(pools[i]);
                uint dv = price.mul(getTotalVtb(pools[i],prevEpochId));
                sumOfDv = sumOfDv.add(dv);
            }

            if (sumOfDv > 0) {
                for (uint i = 0; i < numOfPools; i++) {
                    uint price = IPriceOracle(oracle).getPrice(pools[i]);
                    uint dv = price.mul(getTotalVtb(pools[i], prevEpochId));
                    uint nutAmount = dv.mul(amount).div(sumOfDv);
                    actualSumOfNut = actualSumOfNut.add(nutAmount);
                    totalNutMap[pools[i]][prevEpochId] = nutAmount;
                }
            }

            require(actualSumOfNut <= amount, "distribute: overflow");
            tokensDistributed = true;
            distCompletionMap[prevEpochId] = true;
        }
        require(tokensDistributed, 'no tokens distributed');
    }

    function collect() external  {

        require(distStarted, 'dist not started');
        uint epochId = (block.number.sub(DIST_START_BLOCK)).div(BLOCKS_PER_EPOCH);
        require(epochId > 0, 'collect: not ready');

        address lender = msg.sender;

        uint numOfPools = pools.length < MAX_NUM_POOLS ? pools.length : MAX_NUM_POOLS;
        uint totalAmount;
        for (uint i = 0; i < numOfPools; i++) {
            address pool = pools[i];
            _fillVtbGap(pool, lender);
            for (uint j = 0; j < epochId && j < NUM_EPOCH; j++) {
                if (!distCompletionMap[j]) {
                   continue;
                }
                uint vtb = getVtb(pool, lender, j);
                if (vtb > 0 && getTotalVtb(pool, j) > 0) {
                    uint amount = vtb.mul(totalNutMap[pool][j]).div(getTotalVtb(pool, j));
                    totalAmount = totalAmount.add(amount);
                    vtbMap[pool][lender][j] = 0;
                }
            }
        }

        IERC20Upgradeable(nut).safeTransfer(lender, totalAmount);
    }

    function getCollectionAmount() external view returns(uint) {

        require(distStarted, 'dist not started');
        uint epochId = (block.number.sub(DIST_START_BLOCK)).div(BLOCKS_PER_EPOCH);
        require(epochId > 0, 'getCollectionAmount: distribution is completed');

        address lender = msg.sender;

        uint numOfPools = pools.length < MAX_NUM_POOLS ? pools.length : MAX_NUM_POOLS;
        uint totalAmount;
        for (uint i = 0; i < numOfPools; i++) {
            address pool = pools[i];
            for (uint j = 0; j < epochId && j < NUM_EPOCH; j++) {
                if (!distCompletionMap[j]) {
                   continue;
                }
                uint vtb = getVtb(pool, lender, j);
                if (vtb > 0 && getTotalVtb(pool, j) > 0) {
                    uint amount = vtb.mul(totalNutMap[pool][j]).div(getTotalVtb(pool, j));
                    totalAmount = totalAmount.add(amount);
                }
            }
        }

        return totalAmount;
    }

    function getVtb(address pool, address lender, uint i) public view returns(uint) {

        require(i < NUM_EPOCH, 'vtb idx err');
        return i < futureVtbEpoch[pool][lender] ?
        vtbMap[pool][lender][i] : futureVtbMap[pool][lender];
    }
    function getTotalVtb(address pool, uint i) public view returns (uint) {

        require(i < NUM_EPOCH, 'totalVtb idx err');
        return i < futureTotalVtbEpoch[pool] ?
        totalVtbMap[pool][i] : futureTotalVtbMap[pool];
    }

    function version() public virtual pure returns (string memory) {

        return "1.0.4.2";
    }
}