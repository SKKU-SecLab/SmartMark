
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// Apache-2.0
pragma solidity ^0.8.1;


interface IEToken is IERC20 {


    function getController() external view returns (address);


    function setController(address _controller) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);


    function burn(address account, uint256 amount) external returns (bool);


    function recover(IERC20 token, uint256 amount) external returns (bool);

}// Apache-2.0
pragma solidity ^0.8.1;


interface IETokenFactory {


    function getController() external view returns (address);


    function setController(address _controller) external returns (bool);


    function createEToken(string memory name, string memory symbol) external returns (IEToken);

}// Apache-2.0
pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;



interface IEPool {

    struct Tranche {
        IEToken eToken;
        uint256 sFactorE;
        uint256 reserveA;
        uint256 reserveB;
        uint256 targetRatio;
    }

    function getController() external view returns (address);


    function setController(address _controller) external returns (bool);


    function tokenA() external view returns (IERC20);


    function tokenB() external view returns (IERC20);


    function sFactorA() external view returns (uint256);


    function sFactorB() external view returns (uint256);


    function getTranche(address eToken) external view returns (Tranche memory);


    function getTranches() external view returns(Tranche[] memory _tranches);


    function addTranche(uint256 targetRatio, string memory eTokenName, string memory eTokenSymbol) external returns (bool);


    function getAggregator() external view returns (address);


    function setAggregator(address oracle, bool inverseRate) external returns (bool);


    function rebalanceMinRDiv() external view returns (uint256);


    function rebalanceInterval() external view returns (uint256);


    function lastRebalance() external view returns (uint256);


    function feeRate() external view returns (uint256);


    function cumulativeFeeA() external view returns (uint256);


    function cumulativeFeeB() external view returns (uint256);


    function setFeeRate(uint256 _feeRate) external returns (bool);


    function transferFees() external returns (bool);


    function getRate() external view returns (uint256);


    function rebalance(uint256 fracDelta) external returns (uint256 deltaA, uint256 deltaB, uint256 rChange, uint256 rDiv);


    function issueExact(address eToken, uint256 amount) external returns (uint256 amountA, uint256 amountB);


    function redeemExact(address eToken, uint256 amount) external returns (uint256 amountA, uint256 amountB);


    function recover(IERC20 token, uint256 amount) external returns (bool);

}// Apache-2.0
pragma solidity ^0.8.1;

interface IController {


    function dao() external view returns (address);


    function guardian() external view returns (address);


    function isDaoOrGuardian(address sender) external view returns (bool);


    function setDao(address _dao) external returns (bool);


    function setGuardian(address _guardian) external returns (bool);


    function feesOwner() external view returns (address);


    function pausedIssuance() external view returns (bool);


    function setFeesOwner(address _feesOwner) external returns (bool);


    function setPausedIssuance(bool _pausedIssuance) external returns (bool);

}// Apache-2.0
pragma solidity ^0.8.1;


contract ControllerMixin {

    event SetController(address controller);

    IController internal controller;

    constructor(IController _controller) {
        controller = _controller;
    }

    modifier onlyDao(string memory revertMsg) {

        require(msg.sender == controller.dao(), revertMsg);
        _;
    }

    modifier onlyDaoOrGuardian(string memory revertMsg) {

        require(controller.isDaoOrGuardian(msg.sender), revertMsg);
        _;
    }

    modifier issuanceNotPaused(string memory revertMsg) {

        require(controller.pausedIssuance() == false, revertMsg);
        _;
    }

    function _setController(address _controller) internal {

        controller = IController(_controller);
        emit SetController(_controller);
    }
}// MIT
pragma solidity >=0.7.0;

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

}// Apache-2.0
pragma solidity ^0.8.1;


contract ChainlinkMixin {

    event SetAggregator(address aggregator, bool inverseRate);

    AggregatorV3Interface internal aggregator;
    uint256 private immutable sFactorTarget;
    uint256 private sFactorSource;
    uint256 private inverseRate; // if true return rate as inverse (1 / rate)

    constructor(address _aggregator, bool _inverseRate, uint256 _sFactorTarget) {
        sFactorTarget = _sFactorTarget;
        _setAggregator(_aggregator, _inverseRate);
    }

    function _setAggregator(address _aggregator, bool _inverseRate) internal {

        aggregator = AggregatorV3Interface(_aggregator);
        sFactorSource = 10**aggregator.decimals();
        inverseRate = (_inverseRate == false) ? 0 : 1;
        emit SetAggregator(_aggregator, _inverseRate);
    }

    function _rate() internal view returns (uint256) {

        (, int256 rate, , , ) = aggregator.latestRoundData();
        if (inverseRate == 0) return uint256(rate) * sFactorTarget / sFactorSource;
        return (sFactorTarget * sFactorTarget) / (uint256(rate) * sFactorTarget / sFactorSource);
    }
}// Apache-2.0
pragma solidity ^0.8.1;

interface IERC20Optional {


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}// Apache-2.0
pragma solidity ^0.8.1;



library TokenUtils {

    function decimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSignature("decimals()"));
        require(success, "TokenUtils: no decimals");
        uint8 _decimals = abi.decode(data, (uint8));
        return _decimals;
    }
}// GNU
pragma solidity ^0.8.1;

library Math {


    function abs(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a > b) ? a - b : b - a;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// Apache-2.0
pragma solidity ^0.8.1;



library EPoolLibrary {

    using TokenUtils for IERC20;

    uint256 internal constant sFactorI = 1e18; // internal scaling factor (18 decimals)

    function currentRatio(
        IEPool.Tranche memory t,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns(uint256) {

        if (t.reserveA == 0 || t.reserveB == 0) {
            if (t.reserveA == 0 && t.reserveB == 0) return t.targetRatio;
            if (t.reserveA == 0) return 0;
            if (t.reserveB == 0) return type(uint256).max;
        }
        return ((t.reserveA * rate / sFactorA) * sFactorI) / (t.reserveB * sFactorI / sFactorB);
    }

    function trancheDelta(
        IEPool.Tranche memory t,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns (uint256 deltaA, uint256 deltaB, uint256 rChange) {

        rChange = (currentRatio(t, rate, sFactorA, sFactorB) < t.targetRatio) ? 1 : 0;
        deltaA = (
            Math.abs(t.reserveA, tokenAForTokenB(t.reserveB, t.targetRatio, rate, sFactorA, sFactorB)) * sFactorA
        ) / (sFactorA + (t.targetRatio * sFactorA / sFactorI));
        deltaB = ((deltaA * sFactorB / sFactorA) * rate) / sFactorI;
        if (deltaA == 0 || deltaB == 0) (deltaA, deltaB, rChange) = (0, 0, 0);
    }

    function delta(
        IEPool.Tranche[] memory ts,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns (uint256 deltaA, uint256 deltaB, uint256 rChange, uint256 rDiv) {

        uint256 totalReserveA;
        int256 totalDeltaA;
        int256 totalDeltaB;
        for (uint256 i = 0; i < ts.length; i++) {
            totalReserveA += ts[i].reserveA;
            (uint256 _deltaA, uint256 _deltaB, uint256 _rChange) = trancheDelta(
                ts[i], rate, sFactorA, sFactorB
            );
            (totalDeltaA, totalDeltaB) = (_rChange == 0)
                ? (totalDeltaA - int256(_deltaA), totalDeltaB + int256(_deltaB))
                : (totalDeltaA + int256(_deltaA), totalDeltaB - int256(_deltaB));

        }
        if (totalDeltaA > 0 && totalDeltaB < 0)  {
            (deltaA, deltaB, rChange) = (uint256(totalDeltaA), uint256(-totalDeltaB), 1);
        } else if (totalDeltaA < 0 && totalDeltaB > 0) {
            (deltaA, deltaB, rChange) = (uint256(-totalDeltaA), uint256(totalDeltaB), 0);
        }
        rDiv = (totalReserveA == 0) ? 0 : deltaA * EPoolLibrary.sFactorI / totalReserveA;
    }

    function eTokenForTokenATokenB(
        IEPool.Tranche memory t,
        uint256 amountA,
        uint256 amountB,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal view returns (uint256) {

        uint256 amountsA = totalA(amountA, amountB, rate, sFactorA, sFactorB);
        if (t.reserveA + t.reserveB == 0) {
            return (Math.sqrt((amountsA * t.sFactorE / sFactorA) * t.sFactorE));
        }
        uint256 reservesA = totalA(t.reserveA, t.reserveB, rate, sFactorA, sFactorB);
        uint256 share = ((amountsA * t.sFactorE / sFactorA) * t.sFactorE) / (reservesA * t.sFactorE / sFactorA);
        return share * t.eToken.totalSupply() / t.sFactorE;
    }

    function tokenATokenBForEToken(
        IEPool.Tranche memory t,
        uint256 amount,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal view returns (uint256 amountA, uint256 amountB) {

        if (t.reserveA + t.reserveB == 0) {
            uint256 amountsA = amount * sFactorA / t.sFactorE;
            (amountA, amountB) = tokenATokenBForTokenA(
                amountsA * amountsA / sFactorA , t.targetRatio, rate, sFactorA, sFactorB
            );
        } else {
            uint256 eTokenTotalSupply = t.eToken.totalSupply();
            if (eTokenTotalSupply == 0) return(0, 0);
            uint256 share = amount * t.sFactorE / eTokenTotalSupply;
            amountA = share * t.reserveA / t.sFactorE;
            amountB = share * t.reserveB / t.sFactorE;
        }
    }

    function tokenAForTokenB(
        uint256 amountB,
        uint256 ratio,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns(uint256) {

        return (((amountB * sFactorI / sFactorB) * ratio) / rate) * sFactorA / sFactorI;
    }

    function tokenBForTokenA(
        uint256 amountA,
        uint256 ratio,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns(uint256) {

        return (((amountA * sFactorI / sFactorA) * rate) / ratio) * sFactorB / sFactorI;
    }

    function tokenATokenBForTokenA(
        uint256 _totalA,
        uint256 ratio,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns (uint256 amountA, uint256 amountB) {

        amountA = _totalA - (_totalA * sFactorI / (sFactorI + ratio));
        amountB = (((_totalA * sFactorI / sFactorA) * rate) / (sFactorI + ratio)) * sFactorB / sFactorI;
    }

    function tokenATokenBForTokenB(
        uint256 _totalB,
        uint256 ratio,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns (uint256 amountA, uint256 amountB) {

        amountA = ((((_totalB * sFactorI / sFactorB) * ratio) / (sFactorI + ratio)) * sFactorA) / rate;
        amountB = (_totalB * sFactorI) / (sFactorI + ratio);
    }

    function totalA(
        uint256 amountA,
        uint256 amountB,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns (uint256 _totalA) {

        return amountA + ((((amountB * sFactorI / sFactorB) * sFactorI) / rate) * sFactorA) / sFactorI;
    }

    function totalB(
        uint256 amountA,
        uint256 amountB,
        uint256 rate,
        uint256 sFactorA,
        uint256 sFactorB
    ) internal pure returns (uint256 _totalB) {

        return amountB + ((amountA * rate / sFactorA) * sFactorB) / sFactorI;
    }

    function feeAFeeBForTokenATokenB(
        uint256 amountA,
        uint256 amountB,
        uint256 feeRate
    ) internal pure returns (uint256 feeA, uint256 feeB) {

        feeA = amountA * feeRate / EPoolLibrary.sFactorI;
        feeB = amountB * feeRate / EPoolLibrary.sFactorI;
    }
}// Apache-2.0
pragma solidity ^0.8.1;



contract EPool is ControllerMixin, ChainlinkMixin, IEPool {

    using SafeERC20 for IERC20;
    using TokenUtils for IERC20;
    using TokenUtils for IEToken;

    uint256 public constant FEE_RATE_LIMIT = 0.5e18;
    uint256 public constant TRANCHE_LIMIT = 5;

    IETokenFactory public immutable eTokenFactory;

    IERC20 public immutable override tokenA;
    IERC20 public immutable override tokenB;
    uint256 public immutable override sFactorA;
    uint256 public immutable override sFactorB;

    mapping(address => Tranche) public tranches;
    address[] public tranchesByIndex;

    uint256 public override rebalanceMinRDiv;
    uint256 public override rebalanceInterval;
    uint256 public override lastRebalance;

    uint256 public override feeRate;
    uint256 public override cumulativeFeeA;
    uint256 public override cumulativeFeeB;

    event AddedTranche(address indexed eToken);
    event RebalancedTranches(uint256 deltaA, uint256 deltaB, uint256 rChange, uint256 rDiv);
    event IssuedEToken(address indexed eToken, uint256 amount, uint256 amountA, uint256 amountB, address user);
    event RedeemedEToken(address indexed eToken, uint256 amount, uint256 amountA, uint256 amountB, address user);
    event SetMinRDiv(uint256 minRDiv);
    event SetRebalanceInterval(uint256 interval);
    event SetFeeRate(uint256 feeRate);
    event TransferFees(address indexed feesOwner, uint256 cumulativeFeeA, uint256 cumulativeFeeB);
    event RecoveredToken(address token, uint256 amount);

    constructor(
        IController _controller,
        IETokenFactory _eTokenFactory,
        IERC20 _tokenA,
        IERC20 _tokenB,
        address _aggregator,
        bool inverseRate
    ) ControllerMixin(_controller) ChainlinkMixin(_aggregator, inverseRate, EPoolLibrary.sFactorI) {
        eTokenFactory = _eTokenFactory;
        (tokenA, tokenB) = (_tokenA, _tokenB);
        (sFactorA, sFactorB) = (10**_tokenA.decimals(), 10**_tokenB.decimals());
    }

    function getController() external view override returns (address) {

        return address(controller);
    }

    function setController(address _controller) external override onlyDao("EPool: not dao") returns (bool) {

        _setController(_controller);
        return true;
    }

    function getRate() external view override returns (uint256) {

        return _rate();
    }

    function getAggregator() external view override returns (address) {

        return address(aggregator);
    }

    function setAggregator(
        address _aggregator,
        bool inverseRate
    ) external override onlyDao("EPool: not dao") returns (bool) {

        _setAggregator(_aggregator, inverseRate);
        return true;
    }

    function setMinRDiv(
        uint256 minRDiv
    ) external onlyDao("EPool: not dao") returns (bool) {

        rebalanceMinRDiv = minRDiv;
        emit SetMinRDiv(minRDiv);
        return true;
    }

    function setRebalanceInterval(
        uint256 interval
    ) external onlyDao("EPool: not dao") returns (bool) {

        rebalanceInterval = interval;
        emit SetRebalanceInterval(interval);
        return true;
    }

    function setFeeRate(uint256 _feeRate) external override onlyDao("EPool: not dao") returns (bool) {

        require(_feeRate <= FEE_RATE_LIMIT, "EPool: above fee rate limit");
        feeRate = _feeRate;
        emit SetFeeRate(_feeRate);
        return true;
    }

    function transferFees() external override returns (bool) {

        (uint256 _cumulativeFeeA, uint256 _cumulativeFeeB) = (cumulativeFeeA, cumulativeFeeB);
        (cumulativeFeeA, cumulativeFeeB) = (0, 0);
        tokenA.safeTransfer(controller.feesOwner(), _cumulativeFeeA);
        tokenB.safeTransfer(controller.feesOwner(), _cumulativeFeeB);
        emit TransferFees(controller.feesOwner(), _cumulativeFeeA, _cumulativeFeeB);
        return true;
    }

    function getTranche(address eToken) external view override returns(Tranche memory) {

        return tranches[eToken];
    }

    function getTranches() external view override returns(Tranche[] memory _tranches) {

        _tranches = new Tranche[](tranchesByIndex.length);
        for (uint256 i = 0; i < tranchesByIndex.length; i++) {
            _tranches[i] = tranches[tranchesByIndex[i]];
        }
    }

    function addTranche(
        uint256 targetRatio,
        string memory eTokenName,
        string memory eTokenSymbol
    ) external override onlyDao("EPool: not dao") returns (bool) {

        require(tranchesByIndex.length < TRANCHE_LIMIT, "EPool: max. tranche count");
        require(targetRatio != 0, "EPool: targetRatio == 0");
        IEToken eToken = eTokenFactory.createEToken(eTokenName, eTokenSymbol);
        tranches[address(eToken)] = Tranche(eToken, 10**eToken.decimals(), 0, 0, targetRatio);
        tranchesByIndex.push(address(eToken));
        emit AddedTranche(address(eToken));
        return true;
    }

    function _trancheDelta(
        Tranche storage t, uint256 fracDelta
    ) internal view returns (uint256 deltaA, uint256 deltaB, uint256 rChange) {

        uint256 rate = _rate();
        (uint256 _deltaA, uint256 _deltaB, uint256 _rChange) = EPoolLibrary.trancheDelta(
            t, rate, sFactorA, sFactorB
        );
        (deltaA, deltaB, rChange) = (
            fracDelta * _deltaA / EPoolLibrary.sFactorI, fracDelta * _deltaB / EPoolLibrary.sFactorI, _rChange
        );
    }

    function _rebalanceTranches(
        uint256 fracDelta
    ) internal returns (uint256 deltaA, uint256 deltaB, uint256 rChange, uint256 rDiv) {

        require(fracDelta <= EPoolLibrary.sFactorI, "EPool: fracDelta > 1.0");
        uint256 totalReserveA;
        int256 totalDeltaA;
        int256 totalDeltaB;
        for (uint256 i = 0; i < tranchesByIndex.length; i++) {
            Tranche storage t = tranches[tranchesByIndex[i]];
            totalReserveA += t.reserveA;
            (uint256 _deltaA, uint256 _deltaB, uint256 _rChange) = _trancheDelta(t, fracDelta);
            if (_rChange == 0) {
                (t.reserveA, t.reserveB) = (t.reserveA - _deltaA, t.reserveB + _deltaB);
                (totalDeltaA, totalDeltaB) = (totalDeltaA - int256(_deltaA), totalDeltaB + int256(_deltaB));
            } else {
                (t.reserveA, t.reserveB) = (t.reserveA + _deltaA, t.reserveB - _deltaB);
                (totalDeltaA, totalDeltaB) = (totalDeltaA + int256(_deltaA), totalDeltaB - int256(_deltaB));
            }
        }
        if (totalDeltaA > 0 && totalDeltaB < 0)  {
            (deltaA, deltaB, rChange) = (uint256(totalDeltaA), uint256(-totalDeltaB), 1);
        } else if (totalDeltaA < 0 && totalDeltaB > 0) {
            (deltaA, deltaB, rChange) = (uint256(-totalDeltaA), uint256(totalDeltaB), 0);
        }
        rDiv = (totalReserveA == 0) ? 0 : deltaA * EPoolLibrary.sFactorI / totalReserveA;
        emit RebalancedTranches(deltaA, deltaB, rChange, rDiv);
    }

    function rebalance(
        uint256 fracDelta
    ) external virtual override returns (uint256 deltaA, uint256 deltaB, uint256 rChange, uint256 rDiv) {

        (deltaA, deltaB, rChange, rDiv) = _rebalanceTranches(fracDelta);
        require(rDiv >= rebalanceMinRDiv, "EPool: minRDiv not met");
        require(block.timestamp >= lastRebalance + rebalanceInterval, "EPool: within interval");
        lastRebalance = block.timestamp;
        if (rChange == 0) {
            tokenA.safeTransfer(msg.sender, deltaA);
            tokenB.safeTransferFrom(msg.sender, address(this), deltaB);
        } else {
            tokenA.safeTransferFrom(msg.sender, address(this), deltaA);
            tokenB.safeTransfer(msg.sender, deltaB);
        }
    }

    function issueExact(
        address eToken,
        uint256 amount
    ) external override issuanceNotPaused("EPool: issuance paused") returns (uint256 amountA, uint256 amountB) {

        Tranche storage t = tranches[eToken];
        (amountA, amountB) = EPoolLibrary.tokenATokenBForEToken(t, amount, _rate(), sFactorA, sFactorB);
        (t.reserveA, t.reserveB) = (t.reserveA + amountA, t.reserveB + amountB);
        t.eToken.mint(msg.sender, amount);
        tokenA.safeTransferFrom(msg.sender, address(this), amountA);
        tokenB.safeTransferFrom(msg.sender, address(this), amountB);
        emit IssuedEToken(eToken, amount, amountA, amountB, msg.sender);
    }

    function redeemExact(
        address eToken,
        uint256 amount
    ) external override returns (uint256 amountA, uint256 amountB) {

        Tranche storage t = tranches[eToken];
        require(t.reserveA + t.reserveB > 0, "EPool: insufficient liquidity");
        require(amount <= t.eToken.balanceOf(msg.sender), "EPool: insufficient EToken");
        (amountA, amountB) = EPoolLibrary.tokenATokenBForEToken(t, amount, 0, sFactorA, sFactorB);
        (t.reserveA, t.reserveB) = (t.reserveA - amountA, t.reserveB - amountB);
        t.eToken.burn(msg.sender, amount);
        if (feeRate != 0) {
            (uint256 feeA, uint256 feeB) = EPoolLibrary.feeAFeeBForTokenATokenB(amountA, amountB, feeRate);
            (cumulativeFeeA, cumulativeFeeB) = (cumulativeFeeA + feeA, cumulativeFeeB + feeB);
            (amountA, amountB) = (amountA - feeA, amountB - feeB);
        }
        tokenA.safeTransfer(msg.sender, amountA);
        tokenB.safeTransfer(msg.sender, amountB);
        emit RedeemedEToken(eToken, amount, amountA, amountB, msg.sender);
    }

    function recover(IERC20 token, uint256 amount) external override onlyDao("EPool: not dao") returns (bool) {

        uint256 reserved;
        if (token == tokenA) {
            for (uint256 i = 0; i < tranchesByIndex.length; i++) {
                reserved += tranches[tranchesByIndex[i]].reserveA;
            }
        } else if (token == tokenB) {
            for (uint256 i = 0; i < tranchesByIndex.length; i++) {
                reserved += tranches[tranchesByIndex[i]].reserveB;
            }
        }
        require(amount <= token.balanceOf(address(this)) - reserved, "EPool: no excess");
        token.safeTransfer(msg.sender, amount);
        emit RecoveredToken(address(token), amount);
        return true;
    }
}