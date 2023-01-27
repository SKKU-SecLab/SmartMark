
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity >=0.6.0;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
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

interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.7.6;
pragma abicoder v2;

interface IOpenOracleFramework {

    function initialize(
        address[] memory signers_,
        uint256 signerThreshold_,
        address payable payoutAddress_,
        uint256 subscriptionPassPrice_,
        address factoryContract_
    ) external;


    function getHistoricalFeeds(uint256[] memory feedIDs, uint256[] memory timestamps) external view returns (uint256[] memory);


    function getFeeds(uint256[] memory feedIDs) external view returns (uint256[] memory, uint256[] memory, uint256[] memory);


    function getFeed(uint256 feedID) external view returns (uint256, uint256, uint256);


    function getFeedList(uint256[] memory feedIDs) external view returns(string[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory);


    function withdrawFunds() external;


    function createNewFeeds(string[] memory names, string[] memory descriptions, uint256[] memory decimals, uint256[] memory timeslots, uint256[] memory feedCosts, uint256[] memory revenueModes) external;


    function submitFeed(uint256[] memory feedIDs, uint256[] memory values) external;


    function signProposal(uint256 proposalId) external;


    function createProposal(uint256 uintValue, address addressValue, uint256 proposalType, uint256 feedId) external;


    function subscribeToFeed(uint256[] memory feedIDs, uint256[] memory durations, address buyer) payable external;


    function buyPass(address buyer, uint256 duration) payable external;


    function supportFeeds(uint256[] memory feedIds, uint256[] memory values) payable external;

}// GPL-3.0
pragma solidity 0.7.6;



library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

        uint z;
        require(
            y == 0 || (z = uint(self._x) * y) / y == uint(self._x),
            "FixedPoint: MULTIPLICATION_OVERFLOW"
        );
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x != 0, "FixedPoint: ZERO_RECIPROCAL");
        return uq112x112(uint224(Q224 / self._x));
    }
}// MIT
pragma solidity 0.7.6;

interface IEtherCollateral {


    function setAssetClosed(bool) external;


    function getAssetClosed() external view returns (bool);

}// MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


contract Conjure is IERC20, ReentrancyGuard {


    using SafeMath for uint256;
    using Address for address;
    using FixedPoint for FixedPoint.uq112x112;
    using FixedPoint for FixedPoint.uq144x112;

    uint256 internal _totalSupply;

    string internal _name;

    string internal _symbol;

    uint8 internal constant DECIMALS = 18;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public _owner;

    uint256 public _assetType;

    address public _factoryContract;

    address public _collateralContract;

    struct _oracleStruct {
        address oracleaddress;
        address tokenaddress;
        uint256 oracleType;
        string signature;
        bytes calldatas;
        uint256 weight;
        uint256 decimals;
        uint256 values;
    }

    _oracleStruct[] public _oracleData;

    uint256 public _numoracles;

    uint256 internal _latestobservedprice;

    uint256 internal _latestobservedtime;

    uint256 public _indexdivisor;

    bool public _inverse;

    bool public _inited;

    uint256 public _deploymentPrice;

    uint256 private constant MAXIMUM_DECIMALS = 18;

    uint256 private constant UNIT = 10**18;

    address public ethUsdOracle;

    uint256 public inverseLowerCap;

    event NewOwner(address newOwner);
    event Issued(address indexed account, uint256 value);
    event Burned(address indexed account, uint256 value);
    event AssetTypeSet(uint256 value);
    event IndexDivisorSet(uint256 value);
    event PriceUpdated(uint256 value);
    event InverseSet(bool value);
    event NumOraclesSet(uint256 value);

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == _owner, "Only the contract owner may perform this action");
    }

    constructor() {
        _factoryContract = address(1);
    }

    function initialize(
        string[2] memory nameSymbol,
        address[] memory conjureAddresses,
        address factoryAddress_,
        address collateralContract
    ) external
    {

        require(_factoryContract == address(0), "already initialized");
        require(factoryAddress_ != address(0), "factory can not be null");
        require(collateralContract != address(0), "collateralContract can not be null");

        _owner = payable(conjureAddresses[0]);
        _name = nameSymbol[0];
        _symbol = nameSymbol[1];

        ethUsdOracle = conjureAddresses[1];
        _factoryContract = factoryAddress_;

        _collateralContract = collateralContract;

        emit NewOwner(_owner);
    }

    function init(
        bool inverse_,
        uint256[2] memory divisorAssetType,
        address[][2] memory oracleAddresses_,
        uint256[][4] memory oracleTypesValuesWeightsDecimals,
        string[] memory signatures_,
        bytes[] memory callData_
    ) external {

        require(msg.sender == _factoryContract, "can only be called by factory contract");
        require(!_inited, "Contract already inited");
        require(divisorAssetType[0] != 0, "Divisor should not be 0");

        _assetType = divisorAssetType[1];
        _numoracles = oracleAddresses_[0].length;
        _indexdivisor = divisorAssetType[0];
        _inverse = inverse_;
        
        emit AssetTypeSet(_assetType);
        emit IndexDivisorSet(_indexdivisor);
        emit InverseSet(_inverse);
        emit NumOraclesSet(_numoracles);

        uint256 weightCheck;

        for (uint i = 0; i < oracleAddresses_[0].length; i++) {
            require(oracleTypesValuesWeightsDecimals[3][i] <= 18, "Decimals too high");
            _oracleData.push(_oracleStruct({
                oracleaddress: oracleAddresses_[0][i],
                tokenaddress: oracleAddresses_[1][i],
                oracleType: oracleTypesValuesWeightsDecimals[0][i],
                signature: signatures_[i],
                calldatas: callData_[i],
                weight: oracleTypesValuesWeightsDecimals[2][i],
                values: oracleTypesValuesWeightsDecimals[1][i],
                decimals: oracleTypesValuesWeightsDecimals[3][i]
            }));

            weightCheck += oracleTypesValuesWeightsDecimals[2][i];
        }

        if (_assetType == 1) {
            require(weightCheck == 100, "Weights not 100");
        }

        updatePrice();
        _deploymentPrice = getLatestPrice();

        if (_inverse) {
            inverseLowerCap = _deploymentPrice.div(10);
        }

        _inited = true;
    }

    function burn(address account, uint amount) external {

        require(msg.sender == _collateralContract, "Only Collateral Contract");
        _internalBurn(account, amount);
    }

    function mint(address account, uint amount) external {

        require(msg.sender == _collateralContract, "Only Collateral Contract");
        _internalIssue(account, amount);
    }

    function _internalIssue(address account, uint amount) internal {

        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);

        emit Transfer(address(0), account, amount);
        emit Issued(account, amount);
    }

    function _internalBurn(address account, uint amount) internal {

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);
        emit Burned(account, amount);
    }

    function changeOwner(address payable _newOwner) external onlyOwner {

        require(_newOwner != address(0), "_newOwner can not be null");
    
        _owner = _newOwner;
        emit NewOwner(_newOwner);
    }

    function collectFees() external onlyOwner {

        _owner.transfer(address(this).balance);
    }

    function getLatestPrice(AggregatorV3Interface priceFeed) internal view returns (uint) {

        (
        ,
        int price,
        ,
        ,
        ) = priceFeed.latestRoundData();

        return uint(price);
    }

    function getLatestETHUSDPrice() public view returns (uint) {

        (
        uint price,
        ,
        ) = IOpenOracleFramework(ethUsdOracle).getFeed(0);

        return price;
    }

    function quickSort(uint[] memory arr, int left, int right) internal pure {

        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    function getAverage(uint[] memory arr) internal view returns (uint) {

        uint sum = 0;

        for (uint i = 0; i < arr.length; i++) {
            sum += arr[i];
        }
        if (_assetType == 0) {
            return (sum / arr.length);
        }
        if ((_assetType == 2) || (_assetType == 3)) {
            return sum / _indexdivisor;
        }
        return ((sum / 100) / _indexdivisor);
    }

    function sort(uint[] memory data) internal pure returns (uint[] memory) {

        quickSort(data, int(0), int(data.length - 1));
        return data;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = (y + 1) / 2;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        else {
            z = 0;
        }
    }

    function getLatestPrice() public view returns (uint) {

        return _latestobservedprice;
    }

    function getLatestPriceTime() external view returns (uint) {

        return _latestobservedtime;
    }

    function updatePrice() public {

        uint256 returnPrice = updateInternalPrice();
        bool priceLimited;

        if (_inverse && _inited) {
            if (_deploymentPrice.mul(2) <= returnPrice) {
                returnPrice = 0;
            } else {
                returnPrice = _deploymentPrice.mul(2).sub(returnPrice);

                if (returnPrice <= inverseLowerCap) {
                    priceLimited = true;
                }
            }
        }

        _latestobservedprice = returnPrice;
        _latestobservedtime = block.timestamp;

        emit PriceUpdated(_latestobservedprice);

        if ((returnPrice <= 0) || (priceLimited)) {
            IEtherCollateral(_collateralContract).setAssetClosed(true);
        } else {
            if (IEtherCollateral(_collateralContract).getAssetClosed()) {
                IEtherCollateral(_collateralContract).setAssetClosed(false);
            }
        }
    }

    function updateInternalPrice() internal returns (uint) {

        require(_oracleData.length > 0, "No oracle feeds supplied");
        uint[] memory prices = new uint[](_oracleData.length);

        for (uint i = 0; i < _oracleData.length; i++) {

            if (_oracleData[i].oracleType == 0) {
                AggregatorV3Interface priceFeed = AggregatorV3Interface(_oracleData[i].oracleaddress);
                prices[i] = getLatestPrice(priceFeed);

                if (MAXIMUM_DECIMALS != _oracleData[i].decimals) {
                    prices[i] = prices[i] * 10 ** (MAXIMUM_DECIMALS - _oracleData[i].decimals);
                }
            }

            else {
                string memory signature = _oracleData[i].signature;
                bytes memory callDatas = _oracleData[i].calldatas;

                bytes memory callData;

                if (bytes(signature).length == 0) {
                    callData = callDatas;
                } else {
                    callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), callDatas);
                }

                (bool success, bytes memory data) = _oracleData[i].oracleaddress.call{value:_oracleData[i].values}(callData);
                require(success, "Call unsuccessful");

                if (_oracleData[i].oracleType == 1) {
                    FixedPoint.uq112x112 memory price = abi.decode(data, (FixedPoint.uq112x112));

                    prices[i] = price.mul(getLatestETHUSDPrice()).decode144();
                }
                else {
                    prices[i] = abi.decode(data, (uint));

                    if (MAXIMUM_DECIMALS != _oracleData[i].decimals) {
                        prices[i] = prices[i] * 10 ** (MAXIMUM_DECIMALS - _oracleData[i].decimals);
                    }
                }
            }

            if (_assetType == 2 || _assetType == 3) {
                uint tokenTotalSupply = IERC20(_oracleData[i].tokenaddress).totalSupply();
                uint tokenDecimals = IERC20(_oracleData[i].tokenaddress).decimals();

                if (MAXIMUM_DECIMALS != tokenDecimals) {
                    require(tokenDecimals <= 18, "Decimals too high");
                    tokenTotalSupply = tokenTotalSupply * 10 ** (MAXIMUM_DECIMALS - tokenDecimals);
                }

                if (_assetType == 2) {
                    prices[i] = (prices[i].mul(tokenTotalSupply) / UNIT);
                }

                if (_assetType == 3) {
                    prices[i] =prices[i].mul(tokenTotalSupply) / UNIT;
                    prices[i] = sqrt(prices[i]);
                }
            }

            if (_assetType == 1) {
                prices[i] = prices[i] * _oracleData[i].weight;
            }
        }

        uint[] memory sorted = sort(prices);

        if (_assetType == 0) {

            if (sorted.length % 2 == 1) {
                uint sizer = (sorted.length + 1) / 2;

                return sorted[sizer-1];
            } else {
                uint size1 = (sorted.length) / 2;
                uint[] memory sortedMin = new uint[](2);

                sortedMin[0] = sorted[size1-1];
                sortedMin[1] = sorted[size1];

                return getAverage(sortedMin);
            }
        }

        return getAverage(sorted);
    }


    receive() external payable {}

    function name() external override view returns (string memory) {

        return _name;
    }

    function symbol() external override view returns (string memory) {

        return _symbol;
    }

    function decimals() external override pure returns (uint8) {

        return DECIMALS;
    }

    function totalSupply() external override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address dst, uint256 rawAmount) external override returns (bool) {

        uint256 amount = rawAmount;
        _transfer(msg.sender, dst, amount);
        return true;
    }

    function allowance(address owner, address spender)
    external
    override
    view
    returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 rawAmount) external override returns (bool) {

        address spender = msg.sender;
        uint256 spenderAllowance = _allowances[src][spender];
        uint256 amount = rawAmount;

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = spenderAllowance.sub(
                amount,
                    "CONJURE::transferFrom: transfer amount exceeds spender allowance"
            );

            _allowances[src][spender] = newAllowance;
        }

        _transfer(src, dst, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    )
        internal
    {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        internal
    {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}