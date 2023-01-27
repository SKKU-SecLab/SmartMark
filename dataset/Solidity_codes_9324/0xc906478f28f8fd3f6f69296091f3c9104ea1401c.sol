
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity 0.7.6;

interface ICERC20 {

    function mint(uint) external returns (uint);

    function redeem(uint) external returns (uint);

    function transfer(address dst, uint amount) external returns (bool);

    function balanceOf(address) external view returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function supplyRatePerBlock() external returns (uint);

    function approve(address spender, uint amount) external returns (bool);

}// MIT

pragma solidity 0.7.6;

interface IAdapter {

    function openPosition( address baseToken, address collToken, uint collAmount, uint borrowAmount ) external;

    function closePosition() external returns (uint);

    function liquidate() external;

    function settleCreditEvent(
        address baseToken, uint collateralLoss, uint poolLoss) external;


    event openPositionEvent(uint positionId, address caller, uint baseAmt, uint borrowAmount);
    event closePositionEvent(uint positionId, address caller, uint amount);
    event liquidateEvent(uint positionId, address caller);
    event creditEvent(address token, uint collateralLoss, uint poolLoss);
}// MIT

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface INutmeg {

    enum Tranche {AA, A, BBB}
    enum StakeStatus {Uninitialized, Open, Closed}
    enum PositionStatus {Uninitialized, Open, Closed, Liquidated}

    struct Pool {
        bool isExists;
        address baseToken; // base token of this pool, e.g., WETH, DAI.
        uint[3] interestRates; // interest rate per block of each tranche. supposed to be updated everyday.
        uint[3] principals; // principals of each tranche, from lenders
        uint[3] loans; // loans of each tranche, from borrowers.
        uint[3] interests; // interests accrued from loans for each tranche.

        uint totalCollateral; // total collaterals in base token from borrowers.
        uint latestAccruedBlock; // the block number of the latest interest accrual action.
        uint sumRtb; // sum of interest rate per block (after adjustment) times # of blocks
        uint irAdjustPct; // interest rate adjustment in percentage, e.g., 1, 99.
        bool isIrAdjustPctNegative; // whether interestRateAdjustPct is negative
        uint[3] sumIpp; // sum of interest per principal.
        uint[3] lossMultiplier;
        uint[3] lossZeroCounter;
    }

    struct Stake {
        uint id;
        StakeStatus status;
        address owner;
        address pool;
        uint tranche; // tranche of the pool, 0 - AA, 1 - A, 2 - BBB.
        uint principal;
        uint sumIppStart;
        uint earnedInterest;
        uint lossMultiplierBase;
        uint lossZeroCounterBase;
    }

    struct Position {
        uint id; // id of the position.
        PositionStatus status; // status of the position, Open, Close, and Liquidated.
        address owner; // borrower's address
        address adapter; // adapter's address
        address baseToken; // base token that the borrower borrows from the pool
        address collToken; // collateral token that the borrower got from 3rd party pool.
        uint[3] loans; // loans of all tranches
        uint baseAmt; // amount of the base token the borrower put into pool as the collateral.
        uint collAmt; // amount of collateral token the borrower got from 3rd party pool.
        uint borrowAmt; // amount of base tokens borrowed from the pool.
        uint sumRtbStart; // rate times block when the position is created.
        uint repayDeficit; // repay pool loss
    }

    struct NutDist {
        uint endBlock;
        uint amount;
    }

    function getStakeIds(address lender) external view returns (uint[] memory);


    function getPositionIds(address borrower) external view returns (uint[] memory);


    function getMaxBorrowAmount(address token, uint collAmount) external view returns(uint);


    function getCurrPositionId() external view returns (uint);


    function getNextPositionId() external view returns (uint);


    function getCurrSender() external view returns (address);


    function getPosition(uint id) external view returns (Position memory);


    function getPositionInterest(address token, uint positionId) external view returns(uint);


    function getPoolInfo(address token) external view returns(uint, uint, uint);


    function addCollToken(uint posId, uint collAmt) external;


    function borrow(address token, address collAddr, uint baseAmount, uint borrowAmount) external;


    function repay(address token, uint repayAmount) external;


    function liquidate(address token, uint repayAmount) external;


    function distributeCreditLosses( address baseToken, uint collateralLoss, uint poolLoss) external;

    event addPoolEvent(address bank, uint interestRateA);
    event stakeEvent(address bank, address owner, uint tranche, uint amount, uint depId);
    event unstakeEvent(address bank, address owner, uint tranche, uint amount, uint depId);
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


library Math {

    using SafeMath for uint;

    function sumOf3UintArray(uint[3] memory data) internal pure returns(uint) {

        return data[0].add(data[1]).add(data[2]);
    }
}// MIT

pragma solidity 0.7.6;


contract CompoundAdapter is Governable, IAdapter {

    using SafeMath for uint;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct PosInfo {
        uint posId;
        uint collAmt;
        uint sumIpcStart;
    }

    address public nutmeg;

    uint private constant MULTIPLIER = 10**18;

    address[] public baseTokens; // array of base tokens
    mapping(address => bool) public baseTokenMap; // e.g., Dai
    mapping(address => address) public tokenPairs; // Dai -> cDai or cDai -> Dai;
    mapping(address => uint) public totalMintAmt;
    mapping(address => uint) public sumIpcMap;
    mapping(uint => PosInfo) public posInfoMap;

    mapping(address => uint) public totalLoan;
    mapping(address => uint) public totalCollateral;
    mapping(address => uint) public totalLoss;

    function initialize(address nutmegAddr, address governorAddr) external initializer {

        nutmeg = nutmegAddr;
        __Governable__init(governorAddr);
    }


    modifier onlyNutmeg() {

        require(msg.sender == nutmeg, 'only nutmeg can call');
        _;
    }

    function addTokenPair(address baseToken, address collToken) external onlyGov {

        baseTokenMap[baseToken] = true;
        tokenPairs[baseToken] = collToken;
        baseTokens.push(baseToken);
    }

    function removeTokenPair(address baseToken) external onlyGov {

        baseTokenMap[baseToken] = false;
        tokenPairs[baseToken] = address(0);
    }

    function openPosition(address baseToken, address collToken, uint baseAmt, uint borrowAmt)
        external onlyNutmeg override {

        require(baseAmt > 0, 'openPosition: invalid base amount');
        require(baseTokenMap[baseToken], 'openPosition: invalid baseToken address');
        require(tokenPairs[baseToken] == collToken, 'openPosition: invalid cToken address');

        uint posId = INutmeg(nutmeg).getCurrPositionId();
        INutmeg.Position memory pos = INutmeg(nutmeg).getPosition(posId);
        require(IERC20Upgradeable(baseToken).balanceOf(pos.owner) >= baseAmt, 'openPosition: insufficient balance');

        INutmeg(nutmeg).borrow(baseToken, collToken, baseAmt, borrowAmt);

        _increaseDebtAndCollateral(baseToken, posId);

        pos = INutmeg(nutmeg).getPosition(posId);
        uint mintAmt = _doMint(pos, borrowAmt);
        uint currSumIpc = _calcLatestSumIpc(collToken);
        totalMintAmt[collToken] = totalMintAmt[collToken].add(mintAmt);
        PosInfo storage posInfo = posInfoMap[posId];
        posInfo.sumIpcStart = currSumIpc;
        posInfo.collAmt = mintAmt;

        INutmeg(nutmeg).addCollToken(posId, mintAmt);
        emit openPositionEvent(posId, INutmeg(nutmeg).getCurrSender(), baseAmt, borrowAmt);
    }

    function closePosition() external onlyNutmeg override returns (uint) {

        uint posId = INutmeg(nutmeg).getCurrPositionId();
        INutmeg.Position memory pos = INutmeg(nutmeg).getPosition(posId);
        require(pos.owner == INutmeg(nutmeg).getCurrSender(), 'closePosition: original caller is not the owner');

        uint collAmt = _getCollTokenAmount(pos);
        uint redeemAmt = _doRedeem(pos, collAmt);

        IERC20Upgradeable(pos.baseToken).safeApprove(nutmeg, 0);
        IERC20Upgradeable(pos.baseToken).safeApprove(nutmeg, redeemAmt);

        _decreaseDebtAndCollateral(pos.baseToken, pos.id, redeemAmt);
        INutmeg(nutmeg).repay(pos.baseToken, redeemAmt);
        pos = INutmeg(nutmeg).getPosition(posId);
        totalLoss[pos.baseToken] =
            totalLoss[pos.baseToken].add(pos.repayDeficit);
        totalMintAmt[pos.collToken] = totalMintAmt[pos.collToken].sub(pos.collAmt);
        emit closePositionEvent(posId, INutmeg(nutmeg).getCurrSender(), redeemAmt);
        return redeemAmt;
    }

    function liquidate() external override onlyNutmeg  {

        uint posId = INutmeg(nutmeg).getCurrPositionId();
        INutmeg.Position memory pos = INutmeg(nutmeg).getPosition(posId);
        require(_okToLiquidate(pos), 'liquidate: position is not ready for liquidation yet.');

        uint amount = _getCollTokenAmount(pos);
        uint redeemAmt = _doRedeem(pos, amount);
        IERC20Upgradeable(pos.baseToken).safeApprove(nutmeg, 0);
        IERC20Upgradeable(pos.baseToken).safeApprove(nutmeg, redeemAmt);

        _decreaseDebtAndCollateral(pos.baseToken, posId, redeemAmt);
        INutmeg(nutmeg).liquidate(pos.baseToken, redeemAmt);
        pos = INutmeg(nutmeg).getPosition(posId);
        totalLoss[pos.baseToken] = totalLoss[pos.baseToken].add(pos.repayDeficit);
        totalMintAmt[pos.collToken] = totalMintAmt[pos.collToken].sub(pos.collAmt);
        emit liquidateEvent(posId, INutmeg(nutmeg).getCurrSender());
    }
    function creditTokenValue(address baseToken) public returns (uint) {

        address collToken = tokenPairs[baseToken];
        require(collToken != address(0), "settleCreditEvent: invalid collateral token" );
        uint collTokenBal = ICERC20(collToken).balanceOf(address(this));
        return collTokenBal.mul(ICERC20(collToken).exchangeRateCurrent());
    }

    function settleCreditEvent( address baseToken, uint collateralLoss, uint poolLoss) external override onlyNutmeg {

        require(baseTokenMap[baseToken] , "settleCreditEvent: invalid base token" );
        require(collateralLoss <= totalCollateral[baseToken], "settleCreditEvent: invalid collateral" );
        require(poolLoss <= totalLoan[baseToken], "settleCreditEvent: invalid poolLoss" );

        INutmeg(nutmeg).distributeCreditLosses(baseToken, collateralLoss, poolLoss);

        emit creditEvent(baseToken, collateralLoss, poolLoss);
        totalLoss[baseToken] = 0;
        totalLoan[baseToken] = totalLoan[baseToken].sub(poolLoss);
        totalCollateral[baseToken] = totalCollateral[baseToken].sub(collateralLoss);
    }

    function _increaseDebtAndCollateral(address token, uint posId) internal {

        INutmeg.Position memory pos = INutmeg(nutmeg).getPosition(posId);
        for (uint i = 0; i < 3; i++) {
            totalLoan[token] = totalLoan[token].add(pos.loans[i]);
        }
        totalCollateral[token] = totalCollateral[token].add(pos.baseAmt);
    }

    function _decreaseDebtAndCollateral(address token, uint posId, uint redeemAmt) internal {

        INutmeg.Position memory pos = INutmeg(nutmeg).getPosition(posId);
        uint totalLoans = Math.sumOf3UintArray(pos.loans);
        if (redeemAmt >= totalLoans) {
            totalLoan[token] = totalLoan[token].sub(totalLoans);
        } else {
            totalLoan[token] = totalLoan[token].sub(redeemAmt);
        }
        totalCollateral[token] = totalCollateral[token].sub(pos.baseAmt);
    }

    function _doMint(INutmeg.Position memory pos, uint amount) internal returns(uint) {

        uint balBefore = ICERC20(pos.collToken).balanceOf(address(this));
        IERC20Upgradeable(pos.baseToken).safeApprove(pos.collToken, 0);
        IERC20Upgradeable(pos.baseToken).safeApprove(pos.collToken, amount);
        uint result = ICERC20(pos.collToken).mint(amount);
        require(result == 0, '_doMint mint error');
        uint balAfter = ICERC20(pos.collToken).balanceOf(address(this));
        uint mintAmount = balAfter.sub(balBefore);
        require(mintAmount > 0, 'opnPos: zero mnt');
        return mintAmount;
    }

    function _doRedeem(INutmeg.Position memory pos, uint amount) internal returns(uint) {

        uint balBefore = IERC20Upgradeable(pos.baseToken).balanceOf(address(this));
        uint result = ICERC20(pos.collToken).redeem(amount);
        require(result == 0, 'rdm fail');
        uint balAfter = IERC20Upgradeable(pos.baseToken).balanceOf(address(this));
        uint redeemAmt = balAfter.sub(balBefore);
        return redeemAmt;
    }

    function _getCollTokenAmount(INutmeg.Position memory pos) internal returns(uint) {

        uint currSumIpc = _calcLatestSumIpc(pos.collToken);
        PosInfo storage posInfo = posInfoMap[pos.id];
        uint interest = posInfo.collAmt.mul(currSumIpc.sub(posInfo.sumIpcStart)).div(MULTIPLIER);
        return posInfo.collAmt.add(interest);
    }

    function _calcLatestSumIpc(address collToken) internal returns(uint) {

        uint balance = ICERC20(collToken).balanceOf(address(this));
        uint mintBalance = totalMintAmt[collToken];
        uint interest = mintBalance > balance ? mintBalance.sub(balance) : 0;
        uint currIpc = (mintBalance == 0) ? 0 : (interest.mul(MULTIPLIER)).div(mintBalance);
        if (currIpc > 0){
            sumIpcMap[collToken] = sumIpcMap[collToken].add(currIpc);
        }
        return sumIpcMap[collToken];
    }

    function _okToLiquidate(INutmeg.Position memory pos) internal view returns(bool) {

        uint interest = INutmeg(nutmeg).getPositionInterest(pos.baseToken, pos.id);
        return (interest.mul(2) >= pos.baseAmt);
    }

    function version() public virtual pure returns (string memory) {

        return "1.0.0";
    }
}