
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}// GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

struct Position {
    uint share;                 // decimals 18
    uint openPositionPrice;     // decimals 18
    uint leveragedPosition;     // decimals 6
    uint margin;                // decimals 6
    uint openRebaseLeft;        // decimals 18
    address account;
    uint32 currencyKeyIdx;
    uint8 direction;
}

interface IDepot {

    function initialFundingCompleted() external view returns (bool);

    function liquidityPool() external view returns (uint);

    function totalLeveragedPositions() external view returns (uint);

    function totalValue() external view returns (uint);


    function position(uint32 index) external view returns (
        address account,
        uint share,
        uint leveragedPosition,
        uint openPositionPrice,
        uint32 currencyKeyIdx,
        uint8 direction,
        uint margin,
        uint openRebaseLeft);


    function netValue(uint8 direction) external view returns (uint);

    function calMarginLoss(uint leveragedPosition, uint share, uint8 direction) external view returns (uint);

    function calNetProfit(uint32 currencyKeyIdx,
        uint leveragedPosition,
        uint openPositionPrice,
        uint8 direction) external view returns (bool, uint);


    function completeInitialFunding() external;


    function updateSubTotalState(bool isLong, uint liquidity, uint detaMargin,
        uint detaLeveraged, uint detaShare, uint rebaseLeft) external;

    function getTotalPositionState() external view returns (uint, uint, uint, uint);


    function newPosition(
        address account,
        uint openPositionPrice,
        uint margin,
        uint32 currencyKeyIdx,
        uint16 level,
        uint8 direction) external returns (uint32);


    function addDeposit(
        address account,
        uint32 positionId,
        uint margin) external;


    function liquidate(
        Position memory position,
        uint32 positionId,
        bool isProfit,
        uint fee,
        uint value,
        uint marginLoss,
        uint liqReward,
        address liquidator) external;


    function bankruptedLiquidate(
        Position memory position,
        uint32 positionId,
        uint liquidateFee,
        uint marginLoss,
        address liquidator) external;


    function closePosition(
        Position memory position,
        uint32 positionId,
        bool isProfit,
        uint value,
        uint marginLoss,
        uint fee) external;


    function addLiquidity(address account, uint value) external;

    function withdrawLiquidity(address account, uint value) external;

}// GPL-3.0
pragma solidity 0.7.6;

interface IExchangeRates {

    function addCurrencyKey(bytes32 currencyKey_, address aggregator_) external;


    function updateCurrencyKey(bytes32 currencyKey_, address aggregator_) external;


    function deleteCurrencyKey(bytes32 currencyKey) external;


    function rateForCurrency(bytes32 currencyKey) external view returns (uint32, uint);


    function rateForCurrencyByIdx(uint32 idx) external view returns (uint);


    function currencyKeyExist(bytes32 currencyKey) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// GPL-3.0
pragma solidity 0.7.6;


contract AddressResolver is Ownable {

    mapping(bytes32 => address) public repository;

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    function requireAndGetAddress(bytes32 name, string memory reason) internal view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }
}// GPL-3.0
pragma solidity 0.7.6;


library BasicMaths {

    function diff(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a >= b) {
            return a - b;
        } else {
            return b - a;
        }
    }

    function sub2Zero(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a > b) {
            return a - b;
        } else {
            return 0;
        }
    }

    function addOrSub(bool isAdd, uint256 a, uint256 b) internal pure returns (uint256) {

        if (isAdd) {
            return SafeMath.add(a, b);
        } else {
            return SafeMath.sub(a, b);
        }
    }

    function addOrSub2Zero(bool isAdd, uint256 a, uint256 b) internal pure returns (uint256) {

        if (isAdd) {
            return SafeMath.add(a, b);
        } else {
            if (a > b) {
                return a - b;
            } else {
                return 0;
            }
        }
    }
}// GPL-3.0
pragma solidity 0.7.6;




contract Depot is IDepot, AddressResolver {

    using SafeMath for uint;
    using BasicMaths for uint;
    using BasicMaths for bool;
    using SafeERC20 for IERC20;

    mapping(address => uint8) public _powers;

    bool private _initialFundingCompleted = false;

    uint32 public _positionIndex = 0;
    mapping(uint32 => Position) public _positions;

    uint private _liquidityPool = 0;                // decimals 6
    uint public _totalMarginLong = 0;               // decimals 6
    uint public _totalMarginShort = 0;              // decimals 6
    uint public _totalLeveragedPositionsLong = 0;   // decimals 6
    uint public _totalLeveragedPositionsShort = 0;  // decimals 6
    uint public _totalShareLong = 0;                // decimals 18
    uint public _totalShareShort = 0;               // decimals 18
    uint public _totalSizeLong = 0;                 // decimals 18
    uint public _totalSizeShort = 0;                // decimals 18
    uint public _rebaseLeftLong = 0;                // decimals 18
    uint public _rebaseLeftShort = 0;               // decimals 18

    uint private constant E30 = 1e18 * 1e12;
    bytes32 private constant CONTRACT_EXCHANGERATES = "ExchangeRates";
    bytes32 private constant CONTRACT_BASECURRENCY = "BaseCurrency";
    bytes32 private constant CURRENCY_KEY_ETH_USDC = "ETH-USDC";

    constructor(address[] memory powers) AddressResolver() {
        _rebaseLeftLong = 1e18;
        _rebaseLeftShort = 1e18;
        for (uint i = 0; i < powers.length; i++) {
            _powers[powers[i]] = 1;
        }
    }

    function exchangeRates() internal view returns (IExchangeRates) {

        return IExchangeRates(requireAndGetAddress(CONTRACT_EXCHANGERATES, "Missing ExchangeRates Address"));
    }

    function baseCurrency() internal view returns (IERC20) {

        return IERC20(requireAndGetAddress(CONTRACT_BASECURRENCY, "Missing BaseCurrency Address"));
    }

    function _netValue(uint8 direction) internal view returns (uint) {

        if(direction == 1) {
            if(_totalShareLong == 0) {
                return 1e6;
            } else {
                return _totalLeveragedPositionsLong.mul(1e18) / _totalShareLong;
            }
        } else {
            if(_totalShareShort == 0) {
                return 1e6;
            } else {
                return _totalLeveragedPositionsShort.mul(1e18) / _totalShareShort;
            }
        }
    }

    function netValue(uint8 direction) external override view returns (uint) {

        return _netValue(direction);
    }

    function calMarginLoss(uint leveragedPosition, uint share, uint8 direction) external override view returns (uint) {

        return leveragedPosition.sub2Zero(share.mul(_netValue(direction)) / 1e18);
    }

    function calNetProfit(
        uint32 currencyKeyIdx,
        uint leveragedPosition,
        uint openPositionPrice,
        uint8 direction) external override view returns (bool, uint) {

        uint rateForCurrency = exchangeRates().rateForCurrencyByIdx(currencyKeyIdx);
        bool isProfit = ((rateForCurrency >= openPositionPrice) && (direction == 1)) ||
             ((rateForCurrency < openPositionPrice) && (direction != 1));

        return (isProfit, leveragedPosition.mul(rateForCurrency.diff(openPositionPrice)) / openPositionPrice);
    }

    function updateSubTotalState(bool isLong, uint liquidity, uint detaMargin,
        uint detaLeveraged, uint detaShare, uint rebaseLeft) external override onlyPower {

        if (isLong) {
            _liquidityPool = liquidity;
            _totalMarginLong = _totalMarginLong.sub(detaMargin);
            _totalLeveragedPositionsLong = _totalLeveragedPositionsLong.sub(detaLeveraged);
            _totalShareLong = _totalShareLong.sub(detaShare);
            _rebaseLeftLong = _rebaseLeftLong.mul(rebaseLeft) / 1e18;
            _totalSizeLong = _totalSizeLong.mul(rebaseLeft) / 1e18;
        } else {
            _liquidityPool = liquidity;
            _totalMarginShort = _totalMarginShort.sub(detaMargin);
            _totalLeveragedPositionsShort = _totalLeveragedPositionsShort.sub(detaLeveraged);
            _totalShareShort = _totalShareShort.sub(detaShare);
            _rebaseLeftShort = _rebaseLeftShort.mul(rebaseLeft) / 1e18;
            _totalSizeShort = _totalSizeShort.mul(rebaseLeft) / 1e18;
        }
    }

    function newPosition(
        address account,
        uint openPositionPrice,
        uint margin,
        uint32 currencyKeyIdx,
        uint16 level,
        uint8 direction) external override onlyPower returns (uint32) {

        require(_initialFundingCompleted, 'Initial Funding Has Not Completed');

        IERC20 baseCurrencyContract = baseCurrency();

        require(
            baseCurrencyContract.allowance(account, address(this)) >= margin,
            "BaseCurrency Approved To Depot Is Not Enough");
        baseCurrencyContract.safeTransferFrom(account, address(this), margin);

        uint leveragedPosition = margin.mul(level);
        uint share = leveragedPosition.mul(1e18) / _netValue(direction);
        uint size = leveragedPosition.mul(1e18).mul(1e12) / openPositionPrice;
        uint openRebaseLeft;

        if (direction == 1) {
            _totalMarginLong = _totalMarginLong.add(margin);
            _totalLeveragedPositionsLong = _totalLeveragedPositionsLong.add(leveragedPosition);
            _totalShareLong = _totalShareLong.add(share);
            _totalSizeLong = _totalSizeLong.add(size);
            openRebaseLeft = _rebaseLeftLong;
        } else {
            _totalMarginShort = _totalMarginShort.add(margin);
            _totalLeveragedPositionsShort = _totalLeveragedPositionsShort.add(leveragedPosition);
            _totalShareShort = _totalShareShort.add(share);
            _totalSizeShort = _totalSizeShort.add(size);
            openRebaseLeft = _rebaseLeftShort;
        }

        _positionIndex++;
        _positions[_positionIndex] = Position(
            share,
            openPositionPrice,
            leveragedPosition,
            margin,
            openRebaseLeft,
            account,
            currencyKeyIdx,
            direction);

        return _positionIndex;
    }

    function addDeposit(
        address account,
        uint32 positionId,
        uint margin) external override onlyPower {

        Position memory p = _positions[positionId];

        require(account == p.account, "Position Not Match");

        IERC20 baseCurrencyContract = baseCurrency();

        require(
            baseCurrencyContract.allowance(account, address(this)) >= margin,
            "BaseCurrency Approved To Depot Is Not Enough");
        baseCurrencyContract.safeTransferFrom(account, address(this), margin);

        _positions[positionId].margin = p.margin.add(margin);
        if (p.direction == 1) {
            _totalMarginLong = _totalMarginLong.add(margin);
        } else {
            _totalMarginShort = _totalMarginShort.add(margin);
        }
    }

    function liquidate(
        Position memory position,
        uint32 positionId,
        bool isProfit,
        uint fee,
        uint value,
        uint marginLoss,
        uint liqReward,
        address liquidator) external override onlyPower {

        uint liquidity = (!isProfit).addOrSub2Zero(_liquidityPool.add(fee), value)
                                    .sub(marginLoss.sub2Zero(position.margin));

        uint detaLeveraged = position.share.mul(_netValue(position.direction)) / 1e18;
        uint openSize = position.leveragedPosition.mul(1e30) / position.openPositionPrice;

        if (position.direction == 1) {
            _liquidityPool = liquidity;
            _totalMarginLong = _totalMarginLong.add(marginLoss).sub(position.margin);
            _totalLeveragedPositionsLong = _totalLeveragedPositionsLong.sub(detaLeveraged);
            _totalShareLong = _totalShareLong.sub(position.share);
            _totalSizeLong = _totalSizeLong.sub(openSize.mul(_rebaseLeftLong) / position.openRebaseLeft);
        } else {
            _liquidityPool = liquidity;
            _totalMarginShort = _totalMarginShort.add(marginLoss).sub(position.margin);
            _totalLeveragedPositionsShort = _totalLeveragedPositionsShort.sub(detaLeveraged);
            _totalShareShort = _totalShareShort.sub(position.share);
            _totalSizeShort = _totalSizeShort.sub(openSize.mul(_rebaseLeftShort) / position.openRebaseLeft);
        }

        baseCurrency().safeTransfer(liquidator, liqReward);
        delete _positions[positionId];
    }

    function bankruptedLiquidate(
        Position memory position,
        uint32 positionId,
        uint liquidateFee,
        uint marginLoss,
        address liquidator) external override onlyPower {

        uint liquidity = (position.margin > marginLoss).addOrSub(
            _liquidityPool, position.margin.diff(marginLoss)).sub(liquidateFee);

        uint detaLeveraged = position.share.mul(_netValue(position.direction)) / 1e18;
        uint openSize = position.leveragedPosition.mul(1e30) / position.openPositionPrice;

        if (position.direction == 1) {
            _liquidityPool = liquidity;
            _totalMarginLong = _totalMarginLong.add(marginLoss).sub(position.margin);
            _totalLeveragedPositionsLong = _totalLeveragedPositionsLong.sub(detaLeveraged);
            _totalShareLong = _totalShareLong.sub(position.share);
            _totalSizeLong = _totalSizeLong.sub(openSize.mul(_rebaseLeftLong) / position.openRebaseLeft);
        } else {
            _liquidityPool = liquidity;
            _totalMarginShort = _totalMarginShort.add(marginLoss).sub(position.margin);
            _totalLeveragedPositionsShort = _totalLeveragedPositionsShort.sub(detaLeveraged);
            _totalShareShort = _totalShareShort.sub(position.share);
            _totalSizeShort = _totalSizeShort.sub(openSize.mul(_rebaseLeftShort) / position.openRebaseLeft);
        }

        baseCurrency().safeTransfer(liquidator, liquidateFee);

        delete _positions[positionId];
    }

    function closePosition(
        Position memory position,
        uint32 positionId,
        bool isProfit,
        uint value,
        uint marginLoss,
        uint fee) external override onlyPower {

        uint transferOutValue = isProfit.addOrSub(position.margin, value).sub(fee).sub(marginLoss);
        if ( isProfit && (_liquidityPool.add(position.margin).sub(marginLoss) <= transferOutValue) ){
            transferOutValue = _liquidityPool.add(position.margin).sub(marginLoss);
        }
        baseCurrency().safeTransfer(position.account, transferOutValue);

        uint liquidityPoolVal = (!isProfit).addOrSub2Zero(_liquidityPool.add(fee), value);
        uint detaLeveraged = position.share.mul(_netValue(position.direction)) / 1e18;
        uint openSize = position.leveragedPosition.mul(1e30) / position.openPositionPrice;

        if (position.direction == 1) {
            _liquidityPool = liquidityPoolVal;
            _totalMarginLong = _totalMarginLong.add(marginLoss).sub(position.margin);
            _totalLeveragedPositionsLong = _totalLeveragedPositionsLong.sub(detaLeveraged);
            _totalShareLong = _totalShareLong.sub(position.share);
            _totalSizeLong = _totalSizeLong.sub(openSize.mul(_rebaseLeftLong) / position.openRebaseLeft);
        } else {
            _liquidityPool = liquidityPoolVal;
            _totalMarginShort = _totalMarginShort.add(marginLoss).sub(position.margin);
            _totalLeveragedPositionsShort = _totalLeveragedPositionsShort.sub(detaLeveraged);
            _totalShareShort = _totalShareShort.sub(position.share);
            _totalSizeShort = _totalSizeShort.sub(openSize.mul(_rebaseLeftShort) / position.openRebaseLeft);
        }

        delete _positions[positionId];
    }

    function addLiquidity(address account, uint value) external override onlyPower {

        _liquidityPool = _liquidityPool.add(value);
        baseCurrency().safeTransferFrom(account, address(this), value);
    }

    function withdrawLiquidity(address account, uint value) external override onlyPower {

        _liquidityPool = _liquidityPool.sub(value);
        baseCurrency().safeTransfer(account, value);
    }

    function position(uint32 positionId) external override view returns (address account, uint share, uint leveragedPosition,
        uint openPositionPrice, uint32 currencyKeyIdx, uint8 direction, uint margin, uint openRebaseLeft) {

        Position memory p = _positions[positionId];
        return (p.account, p.share, p.leveragedPosition, p.openPositionPrice, p.currencyKeyIdx, p.direction, p.margin, p.openRebaseLeft);
    }

    function initialFundingCompleted() external override view returns (bool) {

        return _initialFundingCompleted;
    }

    function liquidityPool() external override view returns (uint) {

        return _liquidityPool;
    }

    function totalLeveragedPositions() external override view returns (uint) {

        return _totalLeveragedPositionsLong.add(_totalLeveragedPositionsShort);
    }

    function totalValue() external override view returns (uint) {

        (, uint nowPrice) = exchangeRates().rateForCurrency(CURRENCY_KEY_ETH_USDC);
        return nowPrice.mul(_totalSizeLong.add(_totalSizeShort)) / E30;
    }

    function completeInitialFunding() external override onlyPower {

        _initialFundingCompleted = true;
    }

    function getTotalPositionState() external override view returns (uint, uint, uint, uint) {

        (, uint nowPrice) = exchangeRates().rateForCurrency(CURRENCY_KEY_ETH_USDC);

        uint totalValueLong = _totalSizeLong.mul(nowPrice) / E30;
        uint totalValueShort = _totalSizeShort.mul(nowPrice) / E30;
        return (_totalMarginLong, _totalMarginShort, totalValueLong, totalValueShort);
    }

    modifier onlyPower {

        require(_powers[msg.sender] == 1, "Only the contract owner may perform this action");
        _;
    }
}