

pragma solidity 0.7.1;

interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(address indexed from, address indexed to, uint256 value);
}




pragma solidity ^0.7.0;

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



pragma solidity 0.7.1;



interface BondTokenInterface is IERC20 {

    event LogExpire(uint128 rateNumerator, uint128 rateDenominator, bool firstTime);

    function mint(address account, uint256 amount) external returns (bool success);


    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);


    function simpleBurn(address account, uint256 amount) external returns (bool success);


    function burn(uint256 amount) external returns (bool success);


    function burnAll() external returns (uint256 amount);


    function getRate() external view returns (uint128 rateNumerator, uint128 rateDenominator);

}



pragma solidity 0.7.1;

interface LatestPriceOracleInterface {

    function isWorking() external returns (bool);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);

}



pragma solidity 0.7.1;


interface PriceOracleInterface is LatestPriceOracleInterface {

    function latestId() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);

}



pragma solidity 0.7.1;



interface BondMakerInterface {

    event LogNewBond(
        bytes32 indexed bondID,
        address indexed bondTokenAddress,
        uint256 indexed maturity,
        bytes32 fnMapID
    );

    event LogNewBondGroup(
        uint256 indexed bondGroupID,
        uint256 indexed maturity,
        uint64 indexed sbtStrikePrice,
        bytes32[] bondIDs
    );

    event LogIssueNewBonds(uint256 indexed bondGroupID, address indexed issuer, uint256 amount);

    event LogReverseBondGroupToCollateral(
        uint256 indexed bondGroupID,
        address indexed owner,
        uint256 amount
    );

    event LogExchangeEquivalentBonds(
        address indexed owner,
        uint256 indexed inputBondGroupID,
        uint256 indexed outputBondGroupID,
        uint256 amount
    );

    event LogLiquidateBond(bytes32 indexed bondID, uint128 rateNumerator, uint128 rateDenominator);

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            bytes32 fnMapID
        );


    function registerNewBondGroup(bytes32[] calldata bondIDList, uint256 maturity)
        external
        returns (uint256 bondGroupID);


    function reverseBondGroupToCollateral(uint256 bondGroupID, uint256 amount)
        external
        returns (bool success);


    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external returns (bool);


    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID)
        external
        returns (uint256 totalPayment);


    function collateralAddress() external view returns (address);


    function oracleAddress() external view returns (PriceOracleInterface);


    function feeTaker() external view returns (address);


    function decimalsOfBond() external view returns (uint8);


    function decimalsOfOraclePrice() external view returns (uint8);


    function maturityScale() external view returns (uint256);


    function nextBondGroupID() external view returns (uint256);


    function getBond(bytes32 bondID)
        external
        view
        returns (
            address bondAddress,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function getFnMap(bytes32 fnMapID) external view returns (bytes memory fnMap);


    function getBondGroup(uint256 bondGroupID)
        external
        view
        returns (bytes32[] memory bondIDs, uint256 maturity);


    function generateFnMapID(bytes calldata fnMap) external view returns (bytes32 fnMapID);


    function generateBondID(uint256 maturity, bytes calldata fnMap)
        external
        view
        returns (bytes32 bondID);

}



pragma solidity 0.7.1;


interface SimpleStrategyInterface {

    function calcNextMaturity() external view returns (uint256 nextTimeStamp);


    function calcCallStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure returns (uint256 callStrikePrice);


    function calcRoundPrice(
        uint256 price,
        uint64 priceUnit,
        uint8 divisor
    ) external pure returns (uint256 roundedPrice);


    function getTrancheBonds(
        BondMakerInterface bondMaker,
        address aggregatorAddress,
        uint256 issueBondGroupIdOrStrikePrice,
        uint256 price,
        uint256[] calldata bondGroupList,
        uint64 priceUnit,
        bool isReversedOracle
    )
        external
        view
        returns (
            uint256 issueAmount,
            uint256 ethAmount,
            uint256[2] memory IDAndAmountOfBurn
        );


    function getCurrentStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure returns (uint256);


    function getCurrentSpread(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) external view returns (int16);


    function registerCurrentFeeBase(
        int16 currentFeeBase,
        uint256 currentCollateralPerToken,
        uint256 nextCollateralPerToken,
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) external;

}



pragma experimental ABIEncoderV2;
pragma solidity 0.7.1;

interface SimpleAggregatorInterface {

    struct TotalReward {
        uint64 term;
        uint64 value;
    }

    enum AggregatorPhase {BEFORE_START, ACTIVE, COOL_TIME, AFTER_MATURITY, EXPIRED}

    function renewMaturity() external;


    function removeLiquidity(uint128 amount) external returns (bool success);


    function settleTokens() external returns (uint256 unsentETH, uint256 unsentToken);


    function changeSpread() external;


    function liquidateBonds() external;


    function trancheBonds() external;


    function claimReward() external;


    function addSuitableBondGroup() external returns (uint256 bondGroupID);


    function getCollateralAddress() external view returns (address);


    function getCollateralAmount() external view returns (uint256);


    function getCollateralDecimal() external view returns (int16);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function getExpectedBalance(address user, bool hasReservation)
        external
        view
        returns (uint256 expectedBalance);


    function getCurrentPhase() external view returns (AggregatorPhase);


    function updateStartBondGroupId() external;


    function getInfo()
        external
        view
        returns (
            address bondMaker,
            address strategy,
            address dotc,
            address bondPricerAddress,
            address oracleAddress,
            address rewardTokenAddress,
            address registratorAddress,
            address owner,
            bool reverseOracle,
            uint64 basePriceUnit,
            uint128 maxSupply
        );


    function getCurrentStatus()
        external
        view
        returns (
            uint256 term,
            int16 feeBase,
            uint32 uncheckbondGroupId,
            uint64 unit,
            uint64 trancheTime,
            bool isDanger
        );


    function getTermInfo(uint256 term)
        external
        view
        returns (
            uint64 maturity,
            uint64 solidStrikePrice,
            bytes32 SBTID
        );


    function getBondGroupIDFromTermAndPrice(uint256 term, uint256 price)
        external
        view
        returns (uint256 bondGroupID);


    function getRewardAmount(address user) external view returns (uint64);


    function getTotalRewards() external view returns (TotalReward[] memory);


    function isTotalSupplySafe() external view returns (bool);


    function getTotalUnmovedAssets() external view returns (uint256, uint256);


    function totalShareData(uint256 term)
        external
        view
        returns (uint128 totalShare, uint128 totalCollateralPerToken);


    function getCollateralPerToken(uint256 term) external view returns (uint256);


    function getBondGroupIdFromStrikePrice(uint256 term, uint256 strikePrice)
        external
        view
        returns (uint256);


    function getBalanceData(address user)
        external
        view
        returns (
            uint128 amount,
            uint64 term,
            uint64 rewardAmount
        );


    function getIssuableBondGroups() external view returns (uint256[] memory);


    function getLiquidationData(uint256 term)
        external
        view
        returns (
            bool isLiquidated,
            uint32 liquidatedBondGroupID,
            uint32 endBondGroupId
        );

}



pragma solidity 0.7.1;

interface VolatilityOracleInterface {

    function getVolatility(uint64 untilMaturity) external view returns (uint64 volatilityE8);

}



pragma solidity 0.7.1;

enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}



pragma solidity 0.7.1;


interface BondPricerInterface {

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] calldata points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) external view returns (uint256 price, uint256 leverageE8);

}




pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;

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
}




pragma solidity ^0.7.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}



pragma solidity 0.7.1;





interface ExchangeInterface {
    function changeSpread(int16 spread) external;

    function createVsBondPool(
        BondMakerInterface bondMakerForUserAddress,
        VolatilityOracleInterface volatilityOracleAddress,
        BondPricerInterface bondPricerForUserAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external returns (bytes32 poolID);

    function createVsErc20Pool(
        ERC20 swapPairAddress,
        LatestPriceOracleInterface swapPairOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4,
        bool isBondSale
    ) external returns (bytes32 poolID);

    function createVsEthPool(
        LatestPriceOracleInterface ethOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4,
        bool isBondSale
    ) external returns (bytes32 poolID);

    function updateVsBondPool(
        bytes32 poolID,
        VolatilityOracleInterface volatilityOracleAddress,
        BondPricerInterface bondPricerForUserAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external;

    function updateVsErc20Pool(
        bytes32 poolID,
        LatestPriceOracleInterface swapPairOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external;

    function updateVsEthPool(
        bytes32 poolID,
        LatestPriceOracleInterface ethOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external;

    function generateVsBondPoolID(address seller, address bondMakerForUser)
        external
        view
        returns (bytes32 poolID);

    function generateVsErc20PoolID(
        address seller,
        address swapPairAddress,
        bool isBondSale
    ) external view returns (bytes32 poolID);

    function generateVsEthPoolID(address seller, bool isBondSale)
        external
        view
        returns (bytes32 poolID);

    function withdrawEth() external;

    function depositEth() external payable;

    function ethAllowance(address owner) external view returns (uint256 amount);

    function bondMakerAddress() external view returns (BondMakerInterface);
}




pragma solidity ^0.7.0;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}




pragma solidity ^0.7.0;


library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}



pragma solidity 0.7.1;





library SafeMathDivRoundUp {
    using SafeMath for uint256;

    function divRoundUp(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        require(b > 0, errorMessage);
        return ((a - 1) / b) + 1;
    }

    function divRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return divRoundUp(a, b, "SafeMathDivRoundUp: modulo by zero");
    }
}

abstract contract UseSafeMath {
    using SafeMath for uint256;
    using SafeMathDivRoundUp for uint256;
    using SafeMath for uint64;
    using SafeMathDivRoundUp for uint64;
    using SafeMath for uint16;
    using SignedSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
}



pragma solidity 0.7.1;

abstract contract AdvancedMath {
    int256 internal constant SQRT_2PI_E8 = 250662827;
    int256 internal constant PI_E8 = 314159265;
    int256 internal constant E_E8 = 271828182;
    int256 internal constant INV_E_E8 = 36787944; // 1/e
    int256 internal constant LOG2_E8 = 30102999;
    int256 internal constant LOG3_E8 = 47712125;

    int256 internal constant p = 23164190;
    int256 internal constant b1 = 31938153;
    int256 internal constant b2 = -35656378;
    int256 internal constant b3 = 178147793;
    int256 internal constant b4 = -182125597;
    int256 internal constant b5 = 133027442;

    function _sqrt(int256 x) internal pure returns (int256 y) {
        require(x >= 0, "cannot calculate the square root of a negative number");
        int256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function _logTaylor(int256 inputE4) internal pure returns (int256 outputE4) {
        require(inputE4 > 1, "input should be positive number");
        int256 inputE8 = inputE4 * 10**4;
        while (inputE8 < INV_E_E8) {
            inputE8 = (inputE8 * E_E8) / 10**8;
            outputE4 -= 10**4;
        }
        while (inputE8 > 10**8) {
            inputE8 = (inputE8 * INV_E_E8) / 10**8;
            outputE4 += 10**4;
        }
        outputE4 += _logTaylor1(inputE8 / 10**4 - 10**4);
    }

    function _logTaylor1(int256 inputE4) internal pure returns (int256 outputE4) {
        outputE4 =
            inputE4 -
            inputE4**2 /
            (2 * 10**4) +
            inputE4**3 /
            (3 * 10**8) -
            inputE4**4 /
            (4 * 10**12) +
            inputE4**5 /
            (5 * 10**16) -
            inputE4**6 /
            (6 * 10**20) +
            inputE4**7 /
            (7 * 10**24) -
            inputE4**8 /
            (8 * 10**28);
    }

    function _calcPnorm(int256 inputE4) internal pure returns (int256 outputE8) {
        require(inputE4 < 440 * 10**4 && inputE4 > -440 * 10**4, "input is too large");
        int256 _inputE4 = inputE4 > 0 ? inputE4 : inputE4 * (-1);
        int256 t = 10**16 / (10**8 + (p * _inputE4) / 10**4);
        int256 X2 = (inputE4 * inputE4) / 2;
        int256 exp2X2 = 10**8 +
            X2 +
            (X2**2 / (2 * 10**8)) +
            (X2**3 / (6 * 10**16)) +
            (X2**4 / (24 * 10**24)) +
            (X2**5 / (120 * 10**32)) +
            (X2**6 / (720 * 10**40));
        int256 Z = (10**24 / exp2X2) / SQRT_2PI_E8;
        int256 y = (b5 * t) / 10**8;
        y = ((y + b4) * t) / 10**8;
        y = ((y + b3) * t) / 10**8;
        y = ((y + b2) * t) / 10**8;
        y = 10**8 - (Z * ((y + b1) * t)) / 10**16;
        return inputE4 > 0 ? y : 10**8 - y;
    }
}



pragma solidity 0.7.1;




contract GeneralizedPricing is AdvancedMath {
    using SafeMath for uint256;

    int256 internal constant SQRT_YEAR_E8 = 5615.69229926 * 10**8;

    int256 internal constant MIN_ND1_E8 = 0.0001 * 10**8;
    int256 internal constant MAX_ND1_E8 = 0.9999 * 10**8;
    uint256 internal constant MAX_LEVERAGE_E8 = 1000 * 10**8;

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) public pure returns (uint256 price, uint256 leverageE8) {
        if (bondType == BondType.LBT_SHAPE) {
            (price, leverageE8) = _calcLbtShapePriceAndLeverage(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.SBT_SHAPE) {
            (price, leverageE8) = _calcSbtShapePrice(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.TRIANGLE) {
            (price, leverageE8) = _calcTrianglePrice(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.PURE_SBT) {
            (price, leverageE8) = _calcPureSBTPrice(points, spotPrice, volatilityE8, untilMaturity);
        }
    }


    function _calcLbtShapePriceAndLeverage(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(points.length == 3, "3 coordinates is needed for LBT price calculation");
        uint256 inclineE8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        (uint256 callOptionPriceE8, int256 nd1E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        price = (callOptionPriceE8 * inclineE8) / 10**8;
        leverageE8 = _calcLbtLeverage(
            uint256(spotPrice),
            price,
            (nd1E8 * int256(inclineE8)) / 10**8
        );
    }

    function _calcPureSBTPrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(points.length == 1, "1 coordinate is needed for pure SBT price calculation");
        (uint256 callOptionPrice1, int256 nd1E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        price = uint256(spotPrice) > callOptionPrice1 ? (uint256(spotPrice) - callOptionPrice1) : 0;
        leverageE8 = _calcLbtLeverage(uint256(spotPrice), price, 10**8 - nd1E8);
    }

    function _calcSbtShapePrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(points.length == 3, "3 coordinates is needed for SBT price calculation");
        uint256 inclineE8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        (uint256 callOptionPrice1, int256 nd11E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice2, int256 nd12E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[1]),
            volatilityE8,
            untilMaturity
        );
        price = callOptionPrice1 > callOptionPrice2
            ? (inclineE8 * (callOptionPrice1 - callOptionPrice2)) / 10**8
            : 0;
        leverageE8 = _calcLbtLeverage(
            uint256(spotPrice),
            price,
            (int256(inclineE8) * (nd11E8 - nd12E8)) / 10**8
        );
    }

    function _calcTrianglePrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(
            points.length == 4,
            "4 coordinates is needed for triangle option price calculation"
        );
        uint256 incline1E8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        uint256 incline2E8 = (points[2].mul(10**8)).div(points[3].sub(points[1]));
        (uint256 callOptionPrice1, int256 nd11E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice2, int256 nd12E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[1]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice3, int256 nd13E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[3]),
            volatilityE8,
            untilMaturity
        );
        int256 nd1E8 = ((nd11E8 * int256(incline1E8)) +
            (nd13E8 * int256(incline2E8)) -
            (int256(incline1E8 + incline2E8) * nd12E8)) / 10**8;

        uint256 price12 = (callOptionPrice1 * incline1E8) + (callOptionPrice3 * incline2E8);
        price = price12 > (incline1E8 + incline2E8) * callOptionPrice2
            ? (price12 - ((incline1E8 + incline2E8) * callOptionPrice2)) / 10**8
            : 0;
        leverageE8 = _calcLbtLeverage(uint256(spotPrice), price, nd1E8);
    }

    function _calcLbtPrice(
        int256 spotPrice,
        int256 strikePrice,
        int256 nd1E8,
        int256 nd2E8
    ) internal pure returns (int256 lbtPrice) {
        int256 lowestPrice = (spotPrice > strikePrice) ? spotPrice - strikePrice : 0;
        lbtPrice = (spotPrice * nd1E8 - strikePrice * nd2E8) / 10**8;
        if (lbtPrice < lowestPrice) {
            lbtPrice = lowestPrice;
        }
    }

    function _calcLbtLeverage(
        uint256 spotPrice,
        uint256 lbtPrice,
        int256 nd1E8
    ) internal pure returns (uint256 lbtLeverageE8) {
        int256 modifiedNd1E8 = nd1E8 < MIN_ND1_E8 ? MIN_ND1_E8 : nd1E8 > MAX_ND1_E8
            ? MAX_ND1_E8
            : nd1E8;
        return lbtPrice != 0 ? (uint256(modifiedNd1E8) * spotPrice) / lbtPrice : MAX_LEVERAGE_E8;
    }

    function calcCallOptionPrice(
        int256 spotPrice,
        int256 strikePrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) public pure returns (uint256 price, int256 nd1E8) {
        require(spotPrice > 0 && spotPrice < 10**13, "oracle price should be between 0 and 10^13");
        require(
            volatilityE8 > 0 && volatilityE8 < 10 * 10**8,
            "oracle volatility should be between 0% and 1000%"
        );
        require(
            untilMaturity > 0 && untilMaturity < 31536000,
            "the bond should not have expired and less than 1 year"
        );
        require(
            strikePrice > 0 && strikePrice < 10**13,
            "strike price should be between 0 and 10^13"
        );

        int256 spotPerStrikeE4 = (spotPrice * 10**4) / strikePrice;
        int256 sigE8 = (volatilityE8 * (_sqrt(untilMaturity)) * (10**8)) / SQRT_YEAR_E8;

        int256 logSigE4 = _logTaylor(spotPerStrikeE4);
        int256 d1E4 = ((logSigE4 * 10**8) / sigE8) + (sigE8 / (2 * 10**4));
        nd1E8 = _calcPnorm(d1E4);

        int256 d2E4 = d1E4 - (sigE8 / 10**4);
        int256 nd2E8 = _calcPnorm(d2E4);
        price = uint256(_calcLbtPrice(spotPrice, strikePrice, nd1E8, nd2E8));
    }
}



pragma solidity 0.7.1;



abstract contract CustomGeneralizedPricing is BondPricerInterface {
    using SafeMath for uint256;

    GeneralizedPricing internal immutable _originalBondPricerAddress;

    constructor(address originalBondPricerAddress) {
        _originalBondPricerAddress = GeneralizedPricing(originalBondPricerAddress);
    }

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] calldata points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) external view override returns (uint256 price, uint256 leverageE8) {
        (price, leverageE8) = _originalBondPricerAddress.calcPriceAndLeverage(
            bondType,
            points,
            spotPrice,
            volatilityE8,
            untilMaturity
        );
        if (bondType == BondType.LBT_SHAPE) {
            require(
                _isAcceptableLbt(points, spotPrice, volatilityE8, untilMaturity, price, leverageE8),
                "the liquid bond is not acceptable"
            );
        } else if (bondType == BondType.SBT_SHAPE) {
            require(
                _isAcceptableSbt(points, spotPrice, volatilityE8, untilMaturity, price, leverageE8),
                "the solid bond is not acceptable"
            );
        } else if (bondType == BondType.TRIANGLE) {
            require(
                _isAcceptableTriangleBond(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the triangle bond is not acceptable"
            );
        } else if (bondType == BondType.PURE_SBT) {
            require(
                _isAcceptablePureSbt(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the pure solid bond is not acceptable"
            );
        } else {
            require(
                _isAcceptableOtherBond(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the bond is not acceptable"
            );
        }
    }

    function originalBondPricer() external view returns (address originalBondPricerAddress) {
        originalBondPricerAddress = address(_originalBondPricerAddress);
    }

    function _isAcceptableLbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableSbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableTriangleBond(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptablePureSbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableOtherBond(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);
}




pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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



pragma solidity 0.7.1;

abstract contract Time {
    function _getBlockTimestampSec() internal view returns (uint256 unixtimesec) {
        unixtimesec = block.timestamp; // solhint-disable-line not-rely-on-time
    }
}



pragma solidity 0.7.1;





contract BondPricerWithAcceptableMaturity is CustomGeneralizedPricing, Ownable, Time {
    using SafeMath for uint256;

    uint256 internal _acceptableMaturity;

    event LogUpdateAcceptableMaturity(uint256 acceptableMaturity);

    constructor(address originalBondPricerAddress)
        CustomGeneralizedPricing(originalBondPricerAddress)
    {
        _updateAcceptableMaturity(0);
    }

    function updateAcceptableMaturity(uint256 acceptableMaturity) external onlyOwner {
        _updateAcceptableMaturity(acceptableMaturity);
    }

    function getAcceptableMaturity() external view returns (uint256 acceptableMaturity) {
        acceptableMaturity = _acceptableMaturity;
    }

    function _updateAcceptableMaturity(uint256 acceptableMaturity) internal {
        _acceptableMaturity = acceptableMaturity;
        emit LogUpdateAcceptableMaturity(acceptableMaturity);
    }

    function _isAcceptableLbt(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptableSbt(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptableTriangleBond(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptablePureSbt(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptableOtherBond(
        uint256[] memory,
        int256,
        int256,
        int256,
        uint256,
        uint256
    ) internal pure override returns (bool) {
        revert("the bond is not pure SBT type");
    }

    function _isAcceptable(
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity
    ) internal view {
        require(
            etherPriceE8 > 0 && etherPriceE8 < 100000 * 10**8,
            "ETH price should be between $0 and $100000"
        );
        require(
            ethVolatilityE8 > 0 && ethVolatilityE8 < 10 * 10**8,
            "ETH volatility should be between 0% and 1000%"
        );
        require(untilMaturity >= 0, "the bond has been expired");
        require(untilMaturity <= 12 weeks, "the bond maturity must be less than 12 weeks");
        require(
            _getBlockTimestampSec().add(uint256(untilMaturity)) <= _acceptableMaturity,
            "the bond maturity must not exceed the current maturity of aggregator"
        );
    }
}




pragma solidity 0.7.1;


interface BondRegistratorInterface {
    struct Points {
        uint64 x1;
        uint64 y1;
        uint64 x2;
        uint64 y2;
    }

    function getFnMap(Points[] memory points)
        external
        pure
        returns (bytes memory fnMap);

    function registerSBT(
        BondMakerInterface bondMaker,
        uint64 sbtStrikePrice,
        uint64 maturity
    ) external returns (bytes32);

    function registerBondGroup(
        BondMakerInterface bondMaker,
        uint256 callStrikePrice,
        uint64 sbtStrikePrice,
        uint64 maturity,
        bytes32 SBTId
    ) external returns (uint256 bondGroupId);

    function registerBond(
        BondMakerInterface bondMaker,
        Points[] memory points,
        uint256 maturity
    ) external returns (bytes32);
}



pragma solidity 0.7.1;




contract UseVolatilityOracle {
    using SafeMath for uint256;
    using SafeCast for uint256;
    VolatilityOracleInterface volOracle;

    constructor(VolatilityOracleInterface _volOracle) {
        volOracle = _volOracle;
    }

    function _getVolatility(uint256 maturity) internal view returns (uint256) {
        return volOracle.getVolatility(maturity.sub(block.timestamp).toUint64());
    }
}




pragma solidity ^0.7.0;




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



pragma solidity 0.7.1;













abstract contract SimpleAggregator is SimpleAggregatorInterface, UseVolatilityOracle {
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeERC20 for ERC20;
    struct ReceivedCollateral {
        uint128 term;
        uint128 value;
    }
    struct UnRemovedToken {
        uint128 term;
        uint128 value;
    }
    struct LiquidationData {
        uint32 endBondGroupId;
        uint32 liquidatedBondGroupID;
        bool isLiquidated;
    }
    struct TermInfo {
        uint64 maturity;
        uint64 strikePrice;
        bytes32 SBTId;
    }
    struct ShareData {
        uint128 totalShare;
        uint128 totalCollateralPerToken;
    }
    struct BalanceData {
        uint128 balance;
        uint64 rewardAmount;
        uint64 term;
    }

    uint256 constant INFINITY = uint256(-1);
    uint256 constant COOLTIME = 1800;
    SimpleStrategyInterface internal immutable STRATEGY;
    ExchangeInterface internal immutable DOTC;
    ERC20 internal immutable REWARD_TOKEN;
    BondPricerWithAcceptableMaturity internal immutable BOND_PRICER;
    LatestPriceOracleInterface internal immutable ORACLE;
    BondMakerInterface internal immutable BONDMAKER;
    BondRegistratorInterface internal immutable BOND_REGISTRATOR;
    address internal immutable OWNER;
    bool internal immutable REVERSE_ORACLE;
    int16 internal constant MAX_SUPPLY_DENUMERATOR = 8;
    uint64 internal immutable BASE_PRICE_UNIT;

    mapping(uint256 => TermInfo) internal termInfo;

    mapping(uint256 => uint256[]) internal issuableBondGroupIds;
    mapping(uint256 => mapping(uint256 => uint256)) internal strikePriceToBondGroup;

    TotalReward[] internal totalRewards;
    mapping(uint256 => LiquidationData) internal liquidationData;
    mapping(uint256 => ShareData) internal shareData;
    uint256 internal currentTerm;
    uint64 internal priceUnit;
    uint64 internal lastTrancheTime;
    uint32 internal startBondGroupId = 1;
    int16 internal currentFeeBase;
    bool internal isTotalSupplyDanger;

    mapping(address => ReceivedCollateral) internal receivedCollaterals;
    mapping(address => UnRemovedToken) internal unremovedTokens;
    mapping(address => BalanceData) internal balance;
    mapping(address => mapping(address => uint128)) internal allowances;

    uint8 public constant override decimals = 8;
    string public constant override symbol = "LASH";
    string public constant override name = "LIEN_AGGREGATOR_SHARE";

    mapping(uint256 => uint128) internal totalReceivedCollateral;
    mapping(uint256 => uint128) internal totalUnremovedTokens;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event SetAddLiquidity(address indexed user, uint256 indexed term, uint256 collateralAmount);

    event SetRemoveLiquidity(address indexed user, uint256 indexed term, uint256 tokenAmount);

    event SettleLiquidity(
        address indexed user,
        uint256 indexed term,
        uint256 collateralAmount,
        uint256 tokenAmount
    );

    event TrancheBond(
        uint64 indexed issueBondGroupId,
        uint64 issueAmount,
        uint64 indexed burnBondGroupId,
        uint64 burnAmount
    );

    event UpdateMaturity(uint64 indexed term, int16 newFeeBase, uint64 maturity);

    event AddLiquidity(address indexed user, uint256 tokenAmount);

    modifier isActive() {
        require(block.timestamp <= termInfo[currentTerm].maturity, "Not active");
        _;
    }

    modifier endCoolTime() {
        require(block.timestamp > lastTrancheTime + COOLTIME, "Cool Time");
        _;
    }

    modifier afterMaturity() {
        require(block.timestamp > termInfo[currentTerm].maturity, "Not Matured");
        _;
    }

    modifier isRunning() {
        require(currentTerm != 0, "Not running");
        _;
    }

    modifier isSafeSupply() {
        require(!isTotalSupplyDanger, "Unsafe supply");
        _;
    }

    modifier onlyBonusProvider() {
        require(msg.sender == OWNER, "Only provider");
        _;
    }

    constructor(
        LatestPriceOracleInterface _oracle,
        BondPricerWithAcceptableMaturity _pricer,
        SimpleStrategyInterface _strategy,
        ERC20 _rewardToken,
        BondRegistratorInterface _registrator,
        ExchangeInterface _exchangeAddress,
        uint64 _priceUnit,
        uint64 _firstRewardRate,
        bool _reverseOracle,
        VolatilityOracleInterface _volOracle
    ) UseVolatilityOracle(_volOracle) {
        BONDMAKER = _exchangeAddress.bondMakerAddress();
        BOND_PRICER = _pricer;
        ORACLE = _oracle;
        BASE_PRICE_UNIT = _priceUnit;
        REVERSE_ORACLE = _reverseOracle;
        REWARD_TOKEN = _rewardToken;
        BOND_REGISTRATOR = _registrator;
        DOTC = _exchangeAddress;

        STRATEGY = _strategy;

        totalRewards.push(TotalReward(1, _firstRewardRate));
        priceUnit = _priceUnit;
        OWNER = msg.sender;
        require(
            _firstRewardRate >= 10**decimals && _firstRewardRate <= 1000000 * 10**decimals,
            "Out of range"
        );
    }

    function renewMaturity() public override {
        uint256 totalUnsentTokens;
        uint256 collateralPerTokenE8;
        uint256 _currentTerm = currentTerm;
        uint256 currentUnremoved = totalUnremovedTokens[_currentTerm];
        require(liquidationData[_currentTerm].isLiquidated || _currentTerm == 0, "Not expired yet");
        uint256 totalShare = shareData[_currentTerm].totalShare;
        if (totalShare > 0) {
            uint256 collateralAmount = getCollateralAmount();
            collateralPerTokenE8 = _applyDecimalGap(
                collateralAmount.mul(10**decimals).div(totalShare),
                true
            );
            totalUnsentTokens = _applyDecimalGap(
                uint256(totalReceivedCollateral[_currentTerm]).mul(10**decimals) /
                    collateralPerTokenE8,
                true
            );
        } else if (totalReceivedCollateral[_currentTerm] > 0) {
            totalUnsentTokens = _applyDecimalGap(totalReceivedCollateral[_currentTerm], true);
            collateralPerTokenE8 = 10**decimals;
        }

        uint256 _totalSupply = totalShare + totalUnsentTokens;
        shareData[_currentTerm + 1].totalCollateralPerToken = collateralPerTokenE8.toUint128();
        shareData[_currentTerm + 1].totalShare = uint256(totalShare)
            .add(totalUnsentTokens)
            .sub(currentUnremoved)
            .toUint128();

        if (
            shareData[_currentTerm + 1].totalShare >
            uint128(-1) / 10**uint128(MAX_SUPPLY_DENUMERATOR)
        ) {
            isTotalSupplyDanger = true;
        }

        if (_currentTerm != 0) {
            _updateFeeBase();
        }

        if (_totalSupply > 0 && currentUnremoved > 0) {
            _reserveAsset(collateralPerTokenE8);
        }
        _updateBondGroupData();

        emit UpdateMaturity(currentTerm.toUint64(), currentFeeBase, termInfo[currentTerm].maturity);
    }

    function updateTotalReward(uint64 rewardRate) public onlyBonusProvider isRunning {
        require(rewardRate >= 10**decimals && rewardRate <= 1000000 * 10**decimals, "Out of range");
        totalRewards.push(TotalReward(currentTerm.toUint64() + 1, rewardRate));
    }

    function _updateBondGroupData() internal {
        uint256 nextTimeStamp = STRATEGY.calcNextMaturity();
        uint256 currentPriceE8 = ORACLE.latestPrice();
        uint256 currentStrikePrice = STRATEGY.getCurrentStrikePrice(
            currentPriceE8,
            priceUnit,
            REVERSE_ORACLE
        );

        _updatePriceUnit(currentPriceE8);

        bytes32 SBTId = BOND_REGISTRATOR.registerSBT(
            BONDMAKER,
            currentStrikePrice.toUint64(),
            nextTimeStamp.toUint64()
        );
        (address sbtAddress, , , ) = BONDMAKER.getBond(SBTId);
        IERC20(sbtAddress).approve(address(DOTC), INFINITY);

        currentTerm += 1;
        TermInfo memory newTermInfo = TermInfo(
            nextTimeStamp.toUint64(),
            currentStrikePrice.toUint64(),
            SBTId
        );
        termInfo[currentTerm] = newTermInfo;
        BOND_PRICER.updateAcceptableMaturity(nextTimeStamp);
    }

    function _addLiquidity(uint256 amount) internal returns (bool success) {
        (, uint256 unsentToken, uint256 addLiquidityTerm) = _settleTokens();
        _updateBalanceDataForLiquidityMove(msg.sender, unsentToken, 0, addLiquidityTerm);
        uint256 _currentTerm = currentTerm;
        if (receivedCollaterals[msg.sender].value == 0) {
            receivedCollaterals[msg.sender].term = uint128(_currentTerm);
        }
        receivedCollaterals[msg.sender].value += amount.toUint128();
        totalReceivedCollateral[_currentTerm] += amount.toUint128();
        emit SetAddLiquidity(msg.sender, _currentTerm, amount);
        return true;
    }


    function removeLiquidity(uint128 amount) external override returns (bool success) {
        (, uint256 unsentToken, uint256 addLiquidityTerm) = _settleTokens();
        uint256 _currentTerm = currentTerm;
        if (unremovedTokens[msg.sender].value == 0) {
            unremovedTokens[msg.sender].term = uint128(_currentTerm);
        }
        unremovedTokens[msg.sender].value += amount;
        totalUnremovedTokens[_currentTerm] += amount;
        _updateBalanceDataForLiquidityMove(msg.sender, unsentToken, amount, addLiquidityTerm);
        emit SetRemoveLiquidity(msg.sender, _currentTerm, amount);
        return true;
    }

    function _settleTokens()
        internal
        returns (
            uint256 unsentETH,
            uint256 unsentToken,
            uint256 addLiquidityTerm
        )
    {
        uint256 _currentTerm = currentTerm;
        uint128 lastRemoveLiquidityTerm = unremovedTokens[msg.sender].term;
        uint128 lastRemoveLiquidityValue = unremovedTokens[msg.sender].value;
        uint128 lastAddLiquidityTerm = receivedCollaterals[msg.sender].term;
        uint128 lastAddLiquidityValue = receivedCollaterals[msg.sender].value;
        if (_currentTerm == 0) {
            return (0, 0, 0);
        }

        if (lastRemoveLiquidityValue != 0 && _currentTerm > lastRemoveLiquidityTerm) {
            unsentETH = _applyDecimalGap(
                uint256(lastRemoveLiquidityValue)
                    .mul(shareData[uint256(lastRemoveLiquidityTerm + 1)].totalCollateralPerToken)
                    .div(10**decimals),
                false
            );
            if (unsentETH > 0) {
                _sendTokens(msg.sender, unsentETH);
            }
            delete unremovedTokens[msg.sender];
        }

        if (lastAddLiquidityValue != 0 && _currentTerm > lastAddLiquidityTerm) {
            unsentToken = _applyDecimalGap(
                uint256(lastAddLiquidityValue).mul(10**decimals).div(
                    uint256(shareData[lastAddLiquidityTerm + 1].totalCollateralPerToken)
                ),
                true
            );
            addLiquidityTerm = lastAddLiquidityTerm;
            delete receivedCollaterals[msg.sender];
        }
        emit SettleLiquidity(msg.sender, _currentTerm, unsentETH, unsentToken);
    }

    function settleTokens() external override returns (uint256 unsentETH, uint256 unsentToken) {
        uint256 addLiquidityTerm;
        (unsentETH, unsentToken, addLiquidityTerm) = _settleTokens();
        _updateBalanceDataForLiquidityMove(msg.sender, unsentToken, 0, addLiquidityTerm);
    }

    function updateStartBondGroupId() external override isRunning {
        uint32 _startBondGroupId = startBondGroupId;
        uint64 previousMaturity = termInfo[currentTerm - 1].maturity;
        require(previousMaturity != 0, "Maturity shoudld exist");
        while (true) {
            (, uint256 maturity) = BONDMAKER.getBondGroup(_startBondGroupId);
            if (maturity >= previousMaturity) {
                startBondGroupId = _startBondGroupId;
                return;
            }
            _startBondGroupId += 1;
        }
    }

    function liquidateBonds() public override afterMaturity {
        uint256 _currentTerm = currentTerm;
        require(!liquidationData[_currentTerm].isLiquidated, "Expired");
        if (liquidationData[_currentTerm].endBondGroupId == 0) {
            liquidationData[_currentTerm].endBondGroupId = BONDMAKER.nextBondGroupID().toUint32();
        }
        uint32 endIndex;
        uint32 startIndex;
        uint32 liquidateBondNumber;
        uint64 maturity = termInfo[_currentTerm].maturity;
        uint64 previousMaturity = termInfo[_currentTerm - 1].maturity;
        {
            uint256 ethAllowance = DOTC.ethAllowance(address(this));
            if (ethAllowance > 0) {
                DOTC.withdrawEth();
            }
        }

        if (liquidationData[_currentTerm].liquidatedBondGroupID == 0) {
            startIndex = startBondGroupId;
        } else {
            startIndex = liquidationData[_currentTerm].liquidatedBondGroupID;
        }

        if (liquidationData[_currentTerm].endBondGroupId - startIndex > 50) {
            endIndex = startIndex + 50;
            liquidationData[_currentTerm].liquidatedBondGroupID = endIndex;
        } else {
            endIndex = liquidationData[_currentTerm].endBondGroupId;
        }

        for (uint256 i = startIndex; i < endIndex; i++) {
            liquidateBondNumber = _liquidateBondGroup(
                i,
                liquidateBondNumber,
                maturity,
                previousMaturity
            );

            if (liquidateBondNumber > 9) {
                if (i == endIndex - 1) {
                    liquidationData[_currentTerm].isLiquidated = true;
                } else {
                    liquidationData[_currentTerm].liquidatedBondGroupID = uint32(i + 1);
                }
                return;
            }
        }

        if (endIndex == liquidationData[_currentTerm].endBondGroupId) {
            liquidationData[_currentTerm].isLiquidated = true;
        } else {
            liquidationData[_currentTerm].liquidatedBondGroupID = endIndex;
        }
    }

    function addSuitableBondGroup() external override isActive returns (uint256 bondGroupID) {
        uint256 currentPriceE8 = ORACLE.latestPrice();
        return _addSuitableBondGroup(currentPriceE8);
    }

    function trancheBonds() external override isActive endCoolTime {
        uint256 currentPriceE8 = ORACLE.latestPrice();
        uint256 bondGroupId = _getSuitableBondGroup(currentPriceE8);
        if (bondGroupId == 0) {
            bondGroupId = _addSuitableBondGroup(currentPriceE8);
        }

        (uint256 amount, uint256 ethAmount, uint256[2] memory reverseBonds) = STRATEGY
            .getTrancheBonds(
            BONDMAKER,
            address(this),
            bondGroupId,
            currentPriceE8,
            issuableBondGroupIds[currentTerm],
            priceUnit,
            REVERSE_ORACLE
        );

        if (ethAmount > 0) {
            DOTC.depositEth{value: ethAmount}();
        }

        if (amount > 0) {
            _issueBonds(bondGroupId, amount);
        }

        if (reverseBonds[1] > 0) {
            require(
                BONDMAKER.reverseBondGroupToCollateral(reverseBonds[0], reverseBonds[1]),
                "Reverse"
            );
        }
        lastTrancheTime = block.timestamp.toUint64();
        emit TrancheBond(
            uint64(bondGroupId),
            uint64(amount),
            uint64(reverseBonds[0]),
            uint64(reverseBonds[1])
        );
    }

    function _burnBond(
        uint256 bondGroupId,
        address bondAddress,
        uint32 liquidateBondNumber,
        bool isLiquidated
    ) internal returns (uint32, bool) {
        BondTokenInterface bond = BondTokenInterface(bondAddress);
        if (bond.balanceOf(address(this)) > 0) {
            if (!isLiquidated) {
                BONDMAKER.liquidateBond(bondGroupId, 0);
                isLiquidated = true;
            }
            bond.burnAll();
            liquidateBondNumber += 1;
        }
        return (liquidateBondNumber, isLiquidated);
    }

    function _liquidateBondGroup(
        uint256 bondGroupId,
        uint32 liquidateBondNumber,
        uint64 maturity,
        uint64 previousMaturity
    ) internal returns (uint32) {
        (bytes32[] memory bondIds, uint256 _maturity) = BONDMAKER.getBondGroup(bondGroupId);
        if (_maturity > maturity || (_maturity < previousMaturity && previousMaturity != 0)) {
            return liquidateBondNumber;
        }
        bool isLiquidated;
        for (uint256 i = 0; i < bondIds.length; i++) {
            (address bondAddress, , , ) = BONDMAKER.getBond(bondIds[i]);
            (liquidateBondNumber, isLiquidated) = _burnBond(
                bondGroupId,
                bondAddress,
                liquidateBondNumber,
                isLiquidated
            );
        }
        return liquidateBondNumber;
    }

    function _getSuitableBondGroup(uint256 currentPriceE8) internal view returns (uint256) {
        uint256 roundedPrice = STRATEGY.calcRoundPrice(currentPriceE8, priceUnit, 1);


            mapping(uint256 => uint256) storage priceToGroupBondId
         = strikePriceToBondGroup[currentTerm];
        if (priceToGroupBondId[roundedPrice] != 0) {
            return priceToGroupBondId[roundedPrice];
        }
        for (uint256 i = 1; i <= 2; i++) {
            if (priceToGroupBondId[roundedPrice - priceUnit * i] != 0) {
                return priceToGroupBondId[roundedPrice - priceUnit * i];
            }

            if (priceToGroupBondId[roundedPrice + priceUnit * i] != 0) {
                return priceToGroupBondId[roundedPrice + priceUnit * i];
            }
        }
    }

    function _addSuitableBondGroup(uint256 currentPriceE8) internal returns (uint256 bondGroupID) {
        uint256 callStrikePrice = STRATEGY.calcCallStrikePrice(
            currentPriceE8,
            priceUnit,
            REVERSE_ORACLE
        );
        uint256 _currentTerm = currentTerm;
        TermInfo memory info = termInfo[_currentTerm];
        callStrikePrice = _adjustPrice(info.strikePrice, callStrikePrice);
        bondGroupID = BOND_REGISTRATOR.registerBondGroup(
            BONDMAKER,
            callStrikePrice,
            info.strikePrice,
            info.maturity,
            info.SBTId
        );
        if (REVERSE_ORACLE) {
            _addBondGroup(
                bondGroupID,
                STRATEGY.calcCallStrikePrice(currentPriceE8, priceUnit, false)
            );
        } else {
            _addBondGroup(bondGroupID, callStrikePrice);
        }
    }

    function _addBondGroup(uint256 bondGroupId, uint256 callStrikePriceInEthUSD) internal {
        issuableBondGroupIds[currentTerm].push(bondGroupId);
        strikePriceToBondGroup[currentTerm][callStrikePriceInEthUSD] = bondGroupId;

        (bytes32[] memory bondIDs, ) = BONDMAKER.getBondGroup(bondGroupId);
        (address bondType1Address, , , ) = BONDMAKER.getBond(bondIDs[1]);

        if (IERC20(bondType1Address).allowance(address(this), address(DOTC)) == 0) {
            IERC20(bondType1Address).approve(address(DOTC), INFINITY);
        }

        (address bondType2Address, , , ) = BONDMAKER.getBond(bondIDs[2]);

        if (IERC20(bondType2Address).allowance(address(this), address(DOTC)) == 0) {
            IERC20(bondType2Address).approve(address(DOTC), INFINITY);
        }
        (address bondType3Address, , , ) = BONDMAKER.getBond(bondIDs[3]);
        if (IERC20(bondType3Address).allowance(address(this), address(DOTC)) == 0) {
            IERC20(bondType3Address).approve(address(DOTC), INFINITY);
        }
    }

    function _updatePriceUnit(uint256 currentPriceE8) internal {
        uint256 multiplyer = currentPriceE8.div(50 * BASE_PRICE_UNIT);
        if (multiplyer == 0) {
            priceUnit = BASE_PRICE_UNIT;
        } else {
            priceUnit = ((25 * multiplyer * BASE_PRICE_UNIT) / 10).toUint64();
        }
    }

    function _updateFeeBase() internal {
        STRATEGY.registerCurrentFeeBase(
            currentFeeBase,
            shareData[currentTerm].totalCollateralPerToken,
            shareData[currentTerm + 1].totalCollateralPerToken,
            OWNER,
            address(ORACLE),
            REVERSE_ORACLE
        );
        changeSpread();
    }

    function _adjustPrice(uint64 sbtStrikePrice, uint256 callStrikePrice)
        internal
        pure
        returns (uint256)
    {
        return callStrikePrice.sub(callStrikePrice.sub(sbtStrikePrice) % 2);
    }

    function changeSpread() public virtual override {}

    function _sendTokens(address user, uint256 amount) internal virtual {}

    function _reserveAsset(uint256 reserveAmountRatioE8) internal virtual {}

    function _issueBonds(uint256 bondgroupID, uint256 amount) internal virtual {}

    function getCollateralAddress() external view virtual override returns (address) {}

    function _applyDecimalGap(uint256 amount, bool isDiv) internal view virtual returns (uint256) {}

    function getCollateralDecimal() external view virtual override returns (int16) {}

    function getReserveAddress() external view virtual returns (address) {}

    function getCollateralAmount() public view virtual override returns (uint256) {}

    function _updateBalanceData(address owner, int256 amount) internal {
        BalanceData memory balanceData = balance[owner];
        balanceData.rewardAmount = _calcNextReward(balanceData, currentTerm);
        balanceData.term = uint64(currentTerm);
        if (amount < 0) {
            balanceData.balance = uint256(balanceData.balance)
                .sub(uint256(amount * -1))
                .toUint128();
        } else {
            balanceData.balance = uint256(balanceData.balance).add(uint256(amount)).toUint128();
        }
        balance[owner] = balanceData;
    }

    function _updateBalanceDataForLiquidityMove(
        address owner,
        uint256 addAmount,
        uint256 removeAmount,
        uint256 term
    ) internal {
        BalanceData memory balanceData = balance[owner];
        if (addAmount != 0) {
            balanceData.rewardAmount = _calcNextReward(balanceData, term);
            balanceData.term = uint64(term);
            balanceData.balance = balanceData.balance = uint256(balanceData.balance)
                .add(uint256(addAmount))
                .toUint128();
        }
        balanceData.rewardAmount = _calcNextReward(balanceData, currentTerm);
        balanceData.term = uint64(currentTerm);
        if (removeAmount != 0) {
            balanceData.balance = uint256(balanceData.balance).sub(removeAmount).toUint128();
        }
        balance[owner] = balanceData;
    }

    function _calcNextReward(BalanceData memory balanceData, uint256 term)
        internal
        view
        returns (uint64 rewardAmount)
    {
        rewardAmount = balanceData.rewardAmount;
        if (balanceData.balance > 0 && balanceData.term < term) {
            uint64 index = uint64(totalRewards.length - 1);
            uint64 referenceTerm = totalRewards[index].term;
            uint64 rewardTotal = totalRewards[index].value;

            for (uint256 i = term; i > balanceData.term; i--) {
                if (i < referenceTerm) {
                    index -= 1;
                    rewardTotal = totalRewards[index].value;
                    referenceTerm = totalRewards[index].term;
                }
                rewardAmount = uint256(rewardAmount)
                    .add(
                    (uint256(rewardTotal).mul(balanceData.balance)).div(shareData[i].totalShare)
                )
                    .toUint64();
            }
        }
    }

    function claimReward() public override {
        BalanceData memory userData = balance[msg.sender];
        userData.rewardAmount = _calcNextReward(userData, currentTerm);
        userData.term = uint64(currentTerm);
        require(userData.rewardAmount > 0, "No Reward");
        uint256 rewardAmount = userData.rewardAmount;
        userData.rewardAmount = 0;
        balance[msg.sender] = userData;
        REWARD_TOKEN.safeTransfer(msg.sender, rewardAmount);
    }


    function approve(address spender, uint256 amount) external override returns (bool) {
        if (amount == uint256(-1)) {
            amount = uint128(-1);
        }
        allowances[msg.sender][spender] = amount.toUint128();
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferToken(msg.sender, recipient, amount.toUint128());
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint128 currentAllowance = allowances[sender][msg.sender];
        if (currentAllowance < amount) {
            return false;
        }
        if (currentAllowance != uint128(-1)) {
            allowances[sender][msg.sender] = uint256(allowances[sender][msg.sender])
                .sub(amount)
                .toUint128();
        }
        _transferToken(sender, recipient, amount.toUint128());
        return true;
    }

    function _transferToken(
        address from,
        address to,
        uint128 amount
    ) internal returns (bool) {
        if (balance[from].balance < amount) {
            return false;
        }
        _updateBalanceData(from, -1 * int256(amount));
        _updateBalanceData(to, int256(amount));
        emit Transfer(from, to, uint256(amount));
        return true;
    }

    function balanceOf(address user) public view override returns (uint256) {
        return balance[user].balance;
    }

    function totalSupply() public view override returns (uint256) {
        return uint256(shareData[currentTerm].totalShare).sub(totalUnremovedTokens[currentTerm]);
    }

    function getLiquidityReservationData(address user)
        public
        view
        returns (
            uint128 receivedCollateralTerm,
            uint128 receivedCollateralAmount,
            uint128 removeTokenTerm,
            uint128 removeTokenAmount
        )
    {
        return (
            receivedCollaterals[user].term,
            receivedCollaterals[user].value,
            unremovedTokens[user].term,
            unremovedTokens[user].value
        );
    }

    function getCurrentStatus()
        public
        view
        override
        returns (
            uint256 term,
            int16 feeBase,
            uint32 uncheckbondGroupId,
            uint64 unit,
            uint64 trancheTime,
            bool isDanger
        )
    {
        return (
            currentTerm,
            currentFeeBase,
            startBondGroupId,
            priceUnit,
            lastTrancheTime,
            isTotalSupplyDanger
        );
    }

    function getLiquidationData(uint256 term)
        public
        view
        override
        returns (
            bool isLiquidated,
            uint32 liquidatedBondGroupID,
            uint32 endBondGroupId
        )
    {
        if (term == 0) {
            term = currentTerm;
        }
        isLiquidated = liquidationData[term].isLiquidated;
        liquidatedBondGroupID = liquidationData[term].liquidatedBondGroupID;
        endBondGroupId = liquidationData[term].endBondGroupId;
    }

    function totalShareData(uint256 term)
        public
        view
        override
        returns (uint128 totalShare, uint128 totalCollateralPerToken)
    {
        if (term == 0) {
            term = currentTerm;
        }
        return (shareData[term].totalShare, shareData[term].totalCollateralPerToken);
    }

    function getBondGroupIDFromTermAndPrice(uint256 term, uint256 price)
        public
        view
        override
        returns (uint256 bondGroupID)
    {
        price = STRATEGY.calcRoundPrice(price, priceUnit, 1);

        if (term == 0) {
            term = currentTerm;
        }
        return strikePriceToBondGroup[term][price];
    }

    function getInfo()
        public
        view
        override
        returns (
            address bondMaker,
            address strategy,
            address dotc,
            address bondPricerAddress,
            address oracleAddress,
            address rewardTokenAddress,
            address registratorAddress,
            address owner,
            bool reverseOracle,
            uint64 basePriceUnit,
            uint128 maxSupply
        )
    {
        return (
            address(BONDMAKER),
            address(STRATEGY),
            address(DOTC),
            address(BOND_PRICER),
            address(ORACLE),
            address(REWARD_TOKEN),
            address(BOND_REGISTRATOR),
            OWNER,
            REVERSE_ORACLE,
            BASE_PRICE_UNIT,
            uint128(uint128(-1) / (10**uint256(MAX_SUPPLY_DENUMERATOR)))
        );
    }

    function getTermInfo(uint256 term)
        public
        view
        override
        returns (
            uint64 maturity,
            uint64 solidStrikePrice,
            bytes32 SBTID
        )
    {
        if (term == 0) {
            term = currentTerm;
        }
        return (termInfo[term].maturity, termInfo[term].strikePrice, termInfo[term].SBTId);
    }

    function getExpectedBalance(address user, bool hasReservation)
        external
        view
        override
        returns (uint256 expectedBalance)
    {
        expectedBalance = balance[user].balance;
        if (receivedCollaterals[user].value != 0) {
            hasReservation = true;
            if (currentTerm > receivedCollaterals[msg.sender].term) {
                expectedBalance += _applyDecimalGap(
                    uint256(receivedCollaterals[msg.sender].value).mul(10**decimals).div(
                        uint256(
                            shareData[receivedCollaterals[msg.sender].term + 1]
                                .totalCollateralPerToken
                        )
                    ),
                    true
                );
            }
        }
    }

    function getCurrentPhase() public view override returns (AggregatorPhase) {
        if (currentTerm == 0) {
            return AggregatorPhase.BEFORE_START;
        } else if (block.timestamp <= termInfo[currentTerm].maturity) {
            if (block.timestamp <= lastTrancheTime + COOLTIME) {
                return AggregatorPhase.COOL_TIME;
            }
            return AggregatorPhase.ACTIVE;
        } else if (
            block.timestamp > termInfo[currentTerm].maturity &&
            !liquidationData[currentTerm].isLiquidated
        ) {
            return AggregatorPhase.AFTER_MATURITY;
        }
        return AggregatorPhase.EXPIRED;
    }

    function getRewardAmount(address user) public view override returns (uint64) {
        return _calcNextReward(balance[user], currentTerm);
    }

    function getTotalRewards() public view override returns (TotalReward[] memory) {
        return totalRewards;
    }

    function isTotalSupplySafe() public view override returns (bool) {
        return !isTotalSupplyDanger;
    }

    function getTotalUnmovedAssets() public view override returns (uint256, uint256) {
        return (totalReceivedCollateral[currentTerm], totalUnremovedTokens[currentTerm]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function getCollateralPerToken(uint256 term) public view override returns (uint256) {
        return shareData[term].totalCollateralPerToken;
    }

    function getBondGroupIdFromStrikePrice(uint256 term, uint256 strikePrice)
        public
        view
        override
        returns (uint256)
    {
        return strikePriceToBondGroup[term][strikePrice];
    }

    function getBalanceData(address user)
        external
        view
        override
        returns (
            uint128 amount,
            uint64 term,
            uint64 rewardAmount
        )
    {
        return (balance[user].balance, balance[user].term, balance[user].rewardAmount);
    }

    function getIssuableBondGroups() public view override returns (uint256[] memory) {
        return issuableBondGroupIds[currentTerm];
    }
}



pragma solidity 0.7.1;


interface BondMakerCollateralizedEthInterface is BondMakerInterface {
    function issueNewBonds(uint256 bondGroupID) external payable returns (uint256 amount);
}



pragma solidity 0.7.1;


abstract contract TransferETH is TransferETHInterface {
    receive() external payable override {
        emit LogTransferETH(msg.sender, address(this), msg.value);
    }

    function _hasSufficientBalance(uint256 amount) internal view returns (bool ok) {
        address thisContract = address(this);
        return amount <= thisContract.balance;
    }

    function _transferETH(
        address payable recipient,
        uint256 amount,
        string memory errorMessage
    ) internal {
        require(_hasSufficientBalance(amount), errorMessage);
        (bool success, ) = recipient.call{value: amount}(""); // solhint-disable-line avoid-low-level-calls
        require(success, "transferring Ether failed");
        emit LogTransferETH(address(this), recipient, amount);
    }

    function _transferETH(address payable recipient, uint256 amount) internal {
        _transferETH(recipient, amount, "TransferETH: transfer amount exceeds balance");
    }
}



pragma solidity 0.7.1;


contract ReserveEth is TransferETH {
    address owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Error: Only owner can execute this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function sendAsset(address payable user, uint256 amount) public onlyOwner {
        _transferETH(user, amount);
    }
}



pragma solidity 0.7.1;






contract SimpleAggregatorCollateralizedEth is SimpleAggregator, TransferETH {
    using SafeMath for uint256;
    ReserveEth internal immutable reserveEth;
    uint16 internal constant DECIMAL_GAP = 10;

    constructor(
        LatestPriceOracleInterface _ethOracle,
        BondPricerWithAcceptableMaturity _pricer,
        SimpleStrategyInterface strategy,
        ERC20 _rewardToken,
        BondRegistratorInterface _registrator,
        ExchangeInterface exchangeAddress,
        VolatilityOracleInterface _volOracle,
        uint64 _priceUnit,
        uint64 _firstRewardRate
    )
        SimpleAggregator(
            _ethOracle,
            _pricer,
            strategy,
            _rewardToken,
            _registrator,
            exchangeAddress,
            _priceUnit,
            _firstRewardRate,
            false,
            _volOracle
        )
    {
        BondMakerInterface _bondMaker = exchangeAddress.bondMakerAddress();
        int16 feeBaseE4 = strategy.getCurrentSpread(msg.sender, address(_ethOracle), false);
        currentFeeBase = feeBaseE4;
        exchangeAddress.createVsBondPool(_bondMaker, _volOracle, _pricer, _pricer, feeBaseE4);
        exchangeAddress.createVsEthPool(_ethOracle, _pricer, feeBaseE4, true);
        exchangeAddress.createVsEthPool(_ethOracle, _pricer, feeBaseE4, false);

        reserveEth = new ReserveEth();
    }

    function changeSpread() public override {
        int16 _currentFeeBase = STRATEGY.getCurrentSpread(OWNER, address(ORACLE), false);

        require(_currentFeeBase <= 1000 && _currentFeeBase >= 5, "Invalid feebase");
        bytes32 poolIDETHSell = DOTC.generateVsEthPoolID(address(this), true);
        bytes32 poolIDETHBuy = DOTC.generateVsEthPoolID(address(this), false);

        bytes32 poolIDBond = DOTC.generateVsBondPoolID(address(this), address(BONDMAKER));

        DOTC.updateVsEthPool(poolIDETHSell, ORACLE, BOND_PRICER, _currentFeeBase);

        DOTC.updateVsEthPool(poolIDETHBuy, ORACLE, BOND_PRICER, _currentFeeBase);

        DOTC.updateVsBondPool(poolIDBond, volOracle, BOND_PRICER, BOND_PRICER, _currentFeeBase);
        currentFeeBase = _currentFeeBase;
    }

    function addLiquidity() external payable isSafeSupply returns (bool success) {
        success = _addLiquidity(msg.value);
    }

    function _sendTokens(address user, uint256 amount) internal override {
        reserveEth.sendAsset(payable(user), amount);
    }

    function _reserveAsset(uint256 collateralPerTokenE8) internal override {
        uint256 amount = _applyDecimalGap(
            uint256(totalUnremovedTokens[currentTerm]).mul(collateralPerTokenE8).div(10**decimals),
            false
        );
        _transferETH(address(reserveEth), amount);
    }

    function _issueBonds(uint256 bondgroupID, uint256 amount) internal override {
        BondMakerCollateralizedEthInterface bm = BondMakerCollateralizedEthInterface(
            address(BONDMAKER)
        );
        bm.issueNewBonds{value: amount.mul(10**DECIMAL_GAP).mul(1002).div(1000)}(bondgroupID);
    }

    function getCollateralAddress() external pure override returns (address) {
        return address(0);
    }

    function _applyDecimalGap(uint256 amount, bool isDiv) internal pure override returns (uint256) {
        if (isDiv) {
            return amount / 10**DECIMAL_GAP;
        } else {
            return amount * 10**DECIMAL_GAP;
        }
    }

    function getCollateralAmount() public view override returns (uint256) {
        return address(this).balance.sub(totalReceivedCollateral[currentTerm]);
    }

    function getCollateralDecimal() external pure override returns (int16) {
        return 18;
    }

    function getReserveAddress() external view override returns (address) {
        return address(reserveEth);
    }
}