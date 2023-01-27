
pragma solidity =0.6.11 >=0.6.0 <0.8.0 >=0.6.2 <0.8.0;


interface IMapleGlobals {


    function pendingGovernor() external view returns (address);


    function governor() external view returns (address);


    function globalAdmin() external view returns (address);


    function mpl() external view returns (address);


    function mapleTreasury() external view returns (address);


    function isValidBalancerPool(address) external view returns (bool);


    function treasuryFee() external view returns (uint256);


    function investorFee() external view returns (uint256);


    function defaultGracePeriod() external view returns (uint256);


    function fundingPeriod() external view returns (uint256);


    function swapOutRequired() external view returns (uint256);


    function isValidLiquidityAsset(address) external view returns (bool);


    function isValidCollateralAsset(address) external view returns (bool);


    function isValidPoolDelegate(address) external view returns (bool);


    function validCalcs(address) external view returns (bool);


    function isValidCalc(address, uint8) external view returns (bool);


    function getLpCooldownParams() external view returns (uint256, uint256);


    function isValidLoanFactory(address) external view returns (bool);


    function isValidSubFactory(address, address, uint8) external view returns (bool);


    function isValidPoolFactory(address) external view returns (bool);

    
    function getLatestPrice(address) external view returns (uint256);

    
    function defaultUniswapPath(address, address) external view returns (address);


    function minLoanEquity() external view returns (uint256);

    
    function maxSwapSlippage() external view returns (uint256);


    function protocolPaused() external view returns (bool);


    function stakerCooldownPeriod() external view returns (uint256);


    function lpCooldownPeriod() external view returns (uint256);


    function stakerUnstakeWindow() external view returns (uint256);


    function lpWithdrawWindow() external view returns (uint256);


    function oracleFor(address) external view returns (address);


    function validSubFactories(address, address) external view returns (bool);


    function setStakerCooldownPeriod(uint256) external;


    function setLpCooldownPeriod(uint256) external;


    function setStakerUnstakeWindow(uint256) external;


    function setLpWithdrawWindow(uint256) external;


    function setMaxSwapSlippage(uint256) external;


    function setGlobalAdmin(address) external;


    function setValidBalancerPool(address, bool) external;


    function setProtocolPause(bool) external;


    function setValidPoolFactory(address, bool) external;


    function setValidLoanFactory(address, bool) external;


    function setValidSubFactory(address, address, bool) external;


    function setDefaultUniswapPath(address, address, address) external;


    function setPoolDelegateAllowlist(address, bool) external;


    function setCollateralAsset(address, bool) external;


    function setLiquidityAsset(address, bool) external;


    function setCalc(address, bool) external;


    function setInvestorFee(uint256) external;


    function setTreasuryFee(uint256) external;


    function setMapleTreasury(address) external;


    function setDefaultGracePeriod(uint256) external;


    function setMinLoanEquity(uint256) external;


    function setFundingPeriod(uint256) external;


    function setSwapOutRequired(uint256) external;


    function setPriceOracle(address, address) external;


    function setPendingGovernor(address) external;


    function acceptGovernor() external;


}


interface IBaseFDT {


    function withdrawableFundsOf(address owner) external view returns (uint256);


    function withdrawFunds() external;


    event FundsDistributed(address indexed by, uint256 fundsDistributed);

    event FundsWithdrawn(address indexed by, uint256 fundsWithdrawn, uint256 totalWithdrawn);

}


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




interface IBasicFDT is IBaseFDT, IERC20 {


    event PointsPerShareUpdated(uint256);

    event PointsCorrectionUpdated(address indexed, int256);

    function withdrawnFundsOf(address) external view returns (uint256);


    function accumulativeFundsOf(address) external view returns (uint256);


    function updateFundsReceived() external;


}



interface IExtendedFDT is IBasicFDT {


    event LossesPerShareUpdated(uint256);

    event LossesCorrectionUpdated(address indexed, int256);

    event LossesDistributed(address indexed, uint256);

    event LossesRecognized(address indexed, uint256, uint256);

    function lossesPerShare() external view returns (uint256);


    function recognizableLossesOf(address) external view returns (uint256);


    function recognizedLossesOf(address) external view returns (uint256);


    function accumulativeLossesOf(address) external view returns (uint256);


    function updateLossesReceived() external;


}



interface IPoolFDT is IExtendedFDT {


    function interestSum() external view returns (uint256);


    function poolLosses() external view returns (uint256);


    function interestBalance() external view returns (uint256);


    function lossesBalance() external view returns (uint256);


}



interface IPool is IPoolFDT {


    function poolDelegate() external view returns (address);


    function poolAdmins(address) external view returns (bool);


    function deposit(uint256) external;


    function increaseCustodyAllowance(address, uint256) external;


    function transferByCustodian(address, address, uint256) external;


    function poolState() external view returns (uint256);


    function deactivate() external;


    function finalize() external;


    function claim(address, address) external returns (uint256[7] memory);


    function setLockupPeriod(uint256) external;

    
    function setStakingFee(uint256) external;


    function setPoolAdmin(address, bool) external;


    function fundLoan(address, address, uint256) external;


    function withdraw(uint256) external;


    function superFactory() external view returns (address);


    function triggerDefault(address, address) external;


    function isPoolFinalized() external view returns (bool);


    function setOpenToPublic(bool) external;


    function setAllowList(address, bool) external;


    function allowedLiquidityProviders(address) external view returns (bool);


    function openToPublic() external view returns (bool);


    function intendToWithdraw() external;


    function DL_FACTORY() external view returns (uint8);


    function liquidityAsset() external view returns (address);


    function liquidityLocker() external view returns (address);


    function stakeAsset() external view returns (address);


    function stakeLocker() external view returns (address);


    function stakingFee() external view returns (uint256);


    function delegateFee() external view returns (uint256);


    function principalOut() external view returns (uint256);


    function liquidityCap() external view returns (uint256);


    function lockupPeriod() external view returns (uint256);


    function depositDate(address) external view returns (uint256);


    function debtLockers(address, address) external view returns (address);


    function withdrawCooldown(address) external view returns (uint256);


    function setLiquidityCap(uint256) external;


    function cancelWithdraw() external;


    function reclaimERC20(address) external;


    function BPTVal(address, address, address, address) external view returns (uint256);


    function isDepositAllowed(uint256) external view returns (bool);


    function getInitialStakeRequirements() external view returns (uint256, uint256, bool, uint256, uint256);


}


interface IPoolFactory {


    function LL_FACTORY() external view returns (uint8);


    function SL_FACTORY() external view returns (uint8);


    function poolsCreated() external view returns (uint256);


    function globals() external view returns (address);


    function pools(uint256) external view returns (address);


    function isPool(address) external view returns (bool);


    function poolFactoryAdmins(address) external view returns (bool);


    function setGlobals(address) external;


    function createPool(address, address, address, address, uint256, uint256, uint256) external returns (address);


    function setPoolFactoryAdmin(address, bool) external;


    function pause() external;


    function unpause() external;


}


library SafeMathInt {

    function toUint256Safe(int256 a) internal pure returns (uint256) {

        require(a >= 0, "SMI:NEG");
        return uint256(a);
    }
}


library SafeMathUint {

    function toInt256Safe(uint256 a) internal pure returns (int256 b) {

        b = int256(a);
        require(b >= 0, "SMU:OOB");
    }
}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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



abstract contract BasicFDT is IBaseFDT, ERC20 {
    using SafeMath       for uint256;
    using SafeMathUint   for uint256;
    using SignedSafeMath for  int256;
    using SafeMathInt    for  int256;

    uint256 internal constant pointsMultiplier = 2 ** 128;
    uint256 internal pointsPerShare;

    mapping(address => int256)  internal pointsCorrection;
    mapping(address => uint256) internal withdrawnFunds;

    event   PointsPerShareUpdated(uint256 pointsPerShare);
    event PointsCorrectionUpdated(address indexed account, int256 pointsCorrection);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) public { }

    function _distributeFunds(uint256 value) internal {
        require(totalSupply() > 0, "FDT:ZERO_SUPPLY");

        if (value == 0) return;

        pointsPerShare = pointsPerShare.add(value.mul(pointsMultiplier) / totalSupply());
        emit FundsDistributed(msg.sender, value);
        emit PointsPerShareUpdated(pointsPerShare);
    }

    function _prepareWithdraw() internal returns (uint256 withdrawableDividend) {
        withdrawableDividend       = withdrawableFundsOf(msg.sender);
        uint256 _withdrawnFunds    = withdrawnFunds[msg.sender].add(withdrawableDividend);
        withdrawnFunds[msg.sender] = _withdrawnFunds;

        emit FundsWithdrawn(msg.sender, withdrawableDividend, _withdrawnFunds);
    }

    function withdrawableFundsOf(address _owner) public view override returns (uint256) {
        return accumulativeFundsOf(_owner).sub(withdrawnFunds[_owner]);
    }

    function withdrawnFundsOf(address _owner) external view returns (uint256) {
        return withdrawnFunds[_owner];
    }

    function accumulativeFundsOf(address _owner) public view returns (uint256) {
        return
            pointsPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(pointsCorrection[_owner])
                .toUint256Safe() / pointsMultiplier;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        super._transfer(from, to, value);

        int256 _magCorrection       = pointsPerShare.mul(value).toInt256Safe();
        int256 pointsCorrectionFrom = pointsCorrection[from].add(_magCorrection);
        pointsCorrection[from]      = pointsCorrectionFrom;
        int256 pointsCorrectionTo   = pointsCorrection[to].sub(_magCorrection);
        pointsCorrection[to]        = pointsCorrectionTo;

        emit PointsCorrectionUpdated(from, pointsCorrectionFrom);
        emit PointsCorrectionUpdated(to,   pointsCorrectionTo);
    }

    function _mint(address account, uint256 value) internal virtual override {
        super._mint(account, value);

        int256 _pointsCorrection = pointsCorrection[account].sub(
            (pointsPerShare.mul(value)).toInt256Safe()
        );

        pointsCorrection[account] = _pointsCorrection;

        emit PointsCorrectionUpdated(account, _pointsCorrection);
    }

    function _burn(address account, uint256 value) internal virtual override {
        super._burn(account, value);

        int256 _pointsCorrection = pointsCorrection[account].add(
            (pointsPerShare.mul(value)).toInt256Safe()
        );

        pointsCorrection[account] = _pointsCorrection;

        emit PointsCorrectionUpdated(account, _pointsCorrection);
    }

    function withdrawFunds() public virtual override {}

    function _updateFundsTokenBalance() internal virtual returns (int256) {}

    function updateFundsReceived() public virtual {
        int256 newFunds = _updateFundsTokenBalance();

        if (newFunds <= 0) return;

        _distributeFunds(newFunds.toUint256Safe());
    }
}



abstract contract ExtendedFDT is BasicFDT {
    using SafeMath       for uint256;
    using SafeMathUint   for uint256;
    using SignedSafeMath for  int256;
    using SafeMathInt    for  int256;

    uint256 internal lossesPerShare;

    mapping(address => int256)  internal lossesCorrection;
    mapping(address => uint256) internal recognizedLosses;

    event   LossesPerShareUpdated(uint256 lossesPerShare);
    event LossesCorrectionUpdated(address indexed account, int256 lossesCorrection);

    event LossesDistributed(address indexed by, uint256 lossesDistributed);

    event LossesRecognized(address indexed by, uint256 lossesRecognized, uint256 totalLossesRecognized);

    constructor(string memory name, string memory symbol) BasicFDT(name, symbol) public { }

    function _distributeLosses(uint256 value) internal {
        require(totalSupply() > 0, "FDT:ZERO_SUPPLY");

        if (value == 0) return;

        uint256 _lossesPerShare = lossesPerShare.add(value.mul(pointsMultiplier) / totalSupply());
        lossesPerShare          = _lossesPerShare;

        emit LossesDistributed(msg.sender, value);
        emit LossesPerShareUpdated(_lossesPerShare);
    }

    function _prepareLossesWithdraw() internal returns (uint256 recognizableDividend) {
        recognizableDividend = recognizableLossesOf(msg.sender);

        uint256 _recognizedLosses    = recognizedLosses[msg.sender].add(recognizableDividend);
        recognizedLosses[msg.sender] = _recognizedLosses;

        emit LossesRecognized(msg.sender, recognizableDividend, _recognizedLosses);
    }

    function recognizableLossesOf(address _owner) public view returns (uint256) {
        return accumulativeLossesOf(_owner).sub(recognizedLosses[_owner]);
    }

    function recognizedLossesOf(address _owner) external view returns (uint256) {
        return recognizedLosses[_owner];
    }

    function accumulativeLossesOf(address _owner) public view returns (uint256) {
        return
            lossesPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(lossesCorrection[_owner])
                .toUint256Safe() / pointsMultiplier;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        super._transfer(from, to, value);

        int256 _lossesCorrection    = lossesPerShare.mul(value).toInt256Safe();
        int256 lossesCorrectionFrom = lossesCorrection[from].add(_lossesCorrection);
        lossesCorrection[from]      = lossesCorrectionFrom;
        int256 lossesCorrectionTo   = lossesCorrection[to].sub(_lossesCorrection);
        lossesCorrection[to]        = lossesCorrectionTo;

        emit LossesCorrectionUpdated(from, lossesCorrectionFrom);
        emit LossesCorrectionUpdated(to,   lossesCorrectionTo);
    }

    function _mint(address account, uint256 value) internal virtual override {
        super._mint(account, value);

        int256 _lossesCorrection = lossesCorrection[account].sub(
            (lossesPerShare.mul(value)).toInt256Safe()
        );

        lossesCorrection[account] = _lossesCorrection;

        emit LossesCorrectionUpdated(account, _lossesCorrection);
    }

    function _burn(address account, uint256 value) internal virtual override {
        super._burn(account, value);

        int256 _lossesCorrection = lossesCorrection[account].add(
            (lossesPerShare.mul(value)).toInt256Safe()
        );

        lossesCorrection[account] = _lossesCorrection;

        emit LossesCorrectionUpdated(account, _lossesCorrection);
    }

    function updateLossesReceived() public virtual {
        int256 newLosses = _updateLossesBalance();

        if (newLosses <= 0) return;

        _distributeLosses(newLosses.toUint256Safe());
    }

    function _recognizeLosses() internal virtual returns (uint256 losses) { }

    function _updateLossesBalance() internal virtual returns (int256) { }
}



abstract contract StakeLockerFDT is ExtendedFDT {
    using SafeMath       for uint256;
    using SafeMathUint   for uint256;
    using SignedSafeMath for  int256;
    using SafeMathInt    for  int256;

    IERC20 public immutable fundsToken;

    uint256 public bptLosses;          // Sum of all unrecognized losses.
    uint256 public lossesBalance;      // The amount of losses present and accounted for in this contract.
    uint256 public fundsTokenBalance;  // The amount of `fundsToken` (Liquidity Asset) currently present and accounted for in this contract.

    constructor(string memory name, string memory symbol, address _fundsToken) ExtendedFDT(name, symbol) public {
        fundsToken = IERC20(_fundsToken);
    }

    function _recognizeLosses() internal override returns (uint256 losses) {
        losses = _prepareLossesWithdraw();

        bptLosses = bptLosses.sub(losses);

        _updateLossesBalance();
    }

    function _updateLossesBalance() internal override returns (int256) {
        uint256 _prevLossesTokenBalance = lossesBalance;

        lossesBalance = bptLosses;

        return int256(lossesBalance).sub(int256(_prevLossesTokenBalance));
    }

    function _updateFundsTokenBalance() internal virtual override returns (int256) {
        uint256 _prevFundsTokenBalance = fundsTokenBalance;

        fundsTokenBalance = fundsToken.balanceOf(address(this));

        return int256(fundsTokenBalance).sub(int256(_prevFundsTokenBalance));
    }
}


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



abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}





contract StakeLocker is StakeLockerFDT, Pausable {

    using SafeMathInt    for int256;
    using SignedSafeMath for int256;
    using SafeERC20      for IERC20;

    uint256 constant WAD = 10 ** 18;  // Scaling factor for synthetic float division.

    IERC20  public immutable stakeAsset;  // The asset deposited by Stakers into this contract, for liquidation during defaults.

    address public immutable liquidityAsset;  // The Liquidity Asset for the Pool as well as the dividend token for StakeLockerFDT interest.
    address public immutable pool;            // The parent Pool.

    uint256 public lockupPeriod;  // Number of seconds for which unstaking is not allowed.

    mapping(address => uint256)                     public stakeDate;              // Map of account addresses to effective stake date.
    mapping(address => uint256)                     public unstakeCooldown;        // The timestamp of when a Staker called `cooldown()`.
    mapping(address => bool)                        public allowed;                // Map of addresses to allowed status.
    mapping(address => mapping(address => uint256)) public custodyAllowance;       // Amount of StakeLockerFDTs that are "locked" at a certain address.
    mapping(address => uint256)                     public totalCustodyAllowance;  // Total amount of StakeLockerFDTs that are "locked" for a given account, cannot be greater than balance.

    bool public openToPublic;  // Boolean opening StakeLocker to public for staking BPTs

    event            StakeLockerOpened();
    event               BalanceUpdated(address indexed staker, address indexed token, uint256 balance);
    event             AllowListUpdated(address indexed staker, bool status);
    event             StakeDateUpdated(address indexed staker, uint256 stakeDate);
    event          LockupPeriodUpdated(uint256 lockupPeriod);
    event                     Cooldown(address indexed staker, uint256 cooldown);
    event                        Stake(address indexed staker, uint256 amount);
    event                      Unstake(address indexed staker, uint256 amount);
    event              CustodyTransfer(address indexed custodian, address indexed from, address indexed to, uint256 amount);
    event      CustodyAllowanceChanged(address indexed staker, address indexed custodian, uint256 oldAllowance, uint256 newAllowance);
    event TotalCustodyAllowanceUpdated(address indexed staker, uint256 newTotalAllowance);

    constructor(
        address _stakeAsset,
        address _liquidityAsset,
        address _pool
    ) StakeLockerFDT("Maple StakeLocker", "MPLSTAKE", _liquidityAsset) public {
        liquidityAsset = _liquidityAsset;
        stakeAsset     = IERC20(_stakeAsset);
        pool           = _pool;
        lockupPeriod   = 180 days;
    }


    modifier canUnstake(address from) {
        IPool _pool = IPool(pool);

        require(!_pool.isPoolFinalized() || from != _pool.poolDelegate(), "SL:STAKE_LOCKED");
        _;
    }

    modifier isGovernor() {
        require(msg.sender == _globals().governor(), "SL:NOT_GOV");
        _;
    }

    modifier isPool() {
        require(msg.sender == pool, "SL:NOT_P");
        _;
    }


    function setAllowlist(address staker, bool status) public {
        _whenProtocolNotPaused();
        _isValidPoolDelegate();
        allowed[staker] = status;
        emit AllowListUpdated(staker, status);
    }

    function openStakeLockerToPublic() external {
        _whenProtocolNotPaused();
        _isValidPoolDelegate();
        openToPublic = true;
        emit StakeLockerOpened();
    }

    function setLockupPeriod(uint256 newLockupPeriod) external {
        _whenProtocolNotPaused();
        _isValidPoolDelegate();
        require(newLockupPeriod <= lockupPeriod, "SL:INVALID_VALUE");
        lockupPeriod = newLockupPeriod;
        emit LockupPeriodUpdated(newLockupPeriod);
    }

    function pull(address dst, uint256 amt) isPool external {
        stakeAsset.safeTransfer(dst, amt);
    }

    function updateLosses(uint256 bptsBurned) isPool external {
        bptLosses = bptLosses.add(bptsBurned);
        updateLossesReceived();
    }


    function stake(uint256 amt) whenNotPaused external {
        _whenProtocolNotPaused();
        _isAllowed(msg.sender);

        unstakeCooldown[msg.sender] = uint256(0);  // Reset account's unstake cooldown if Staker had previously intended to unstake.

        _updateStakeDate(msg.sender, amt);

        stakeAsset.safeTransferFrom(msg.sender, address(this), amt);
        _mint(msg.sender, amt);

        emit Stake(msg.sender, amt);
        emit Cooldown(msg.sender, uint256(0));
        emit BalanceUpdated(address(this), address(stakeAsset), stakeAsset.balanceOf(address(this)));
    }

    function _updateStakeDate(address account, uint256 amt) internal {
        uint256 prevDate = stakeDate[account];
        uint256 balance = balanceOf(account);

        uint256 newDate = (balance + amt) > 0
            ? prevDate.add(block.timestamp.sub(prevDate).mul(amt).div(balance + amt))
            : prevDate;

        stakeDate[account] = newDate;
        emit StakeDateUpdated(account, newDate);
    }

    function intendToUnstake() external {
        require(balanceOf(msg.sender) != uint256(0), "SL:ZERO_BALANCE");
        unstakeCooldown[msg.sender] = block.timestamp;
        emit Cooldown(msg.sender, block.timestamp);
    }

    function cancelUnstake() external {
        require(unstakeCooldown[msg.sender] != uint256(0), "SL:NOT_UNSTAKING");
        unstakeCooldown[msg.sender] = 0;
        emit Cooldown(msg.sender, uint256(0));
    }

    function unstake(uint256 amt) external canUnstake(msg.sender) {
        _whenProtocolNotPaused();

        require(balanceOf(msg.sender).sub(amt) >= totalCustodyAllowance[msg.sender], "SL:INSUF_UNSTAKEABLE_BAL");  // Account can only unstake tokens that aren't custodied
        require(isUnstakeAllowed(msg.sender),                                        "SL:OUTSIDE_COOLDOWN");
        require(stakeDate[msg.sender].add(lockupPeriod) <= block.timestamp,          "SL:FUNDS_LOCKED");

        updateFundsReceived();   // Account for any funds transferred into contract since last call.
        _burn(msg.sender, amt);  // Burn the corresponding StakeLockerFDTs balance.
        withdrawFunds();         // Transfer the full entitled Liquidity Asset interest.

        stakeAsset.safeTransfer(msg.sender, amt.sub(_recognizeLosses()));  // Unstake amount minus losses.

        emit Unstake(msg.sender, amt);
        emit BalanceUpdated(address(this), address(stakeAsset), stakeAsset.balanceOf(address(this)));
    }

    function withdrawFunds() public override {
        _whenProtocolNotPaused();

        uint256 withdrawableFunds = _prepareWithdraw();

        if (withdrawableFunds == uint256(0)) return;

        fundsToken.safeTransfer(msg.sender, withdrawableFunds);
        emit BalanceUpdated(address(this), address(fundsToken), fundsToken.balanceOf(address(this)));

        _updateFundsTokenBalance();
    }

    function increaseCustodyAllowance(address custodian, uint256 amount) external {
        uint256 oldAllowance      = custodyAllowance[msg.sender][custodian];
        uint256 newAllowance      = oldAllowance.add(amount);
        uint256 newTotalAllowance = totalCustodyAllowance[msg.sender].add(amount);

        require(custodian != address(0),                    "SL:INVALID_CUSTODIAN");
        require(amount    != uint256(0),                    "SL:INVALID_AMT");
        require(newTotalAllowance <= balanceOf(msg.sender), "SL:INSUF_BALANCE");

        custodyAllowance[msg.sender][custodian] = newAllowance;
        totalCustodyAllowance[msg.sender]       = newTotalAllowance;
        emit CustodyAllowanceChanged(msg.sender, custodian, oldAllowance, newAllowance);
        emit TotalCustodyAllowanceUpdated(msg.sender, newTotalAllowance);
    }

    function transferByCustodian(address from, address to, uint256 amount) external {
        uint256 oldAllowance = custodyAllowance[from][msg.sender];
        uint256 newAllowance = oldAllowance.sub(amount);

        require(to == from,             "SL:INVALID_RECEIVER");
        require(amount != uint256(0),   "SL:INVALID_AMT");

        custodyAllowance[from][msg.sender] = newAllowance;
        uint256 newTotalAllowance          = totalCustodyAllowance[from].sub(amount);
        totalCustodyAllowance[from]        = newTotalAllowance;
        emit CustodyTransfer(msg.sender, from, to, amount);
        emit CustodyAllowanceChanged(from, msg.sender, oldAllowance, newAllowance);
        emit TotalCustodyAllowanceUpdated(msg.sender, newTotalAllowance);
    }

    function _transfer(address from, address to, uint256 wad) internal override canUnstake(from) {
        _whenProtocolNotPaused();
        require(stakeDate[from].add(lockupPeriod) <= block.timestamp,    "SL:FUNDS_LOCKED");            // Restrict withdrawal during lockup period
        require(balanceOf(from).sub(wad) >= totalCustodyAllowance[from], "SL:INSUF_TRANSFERABLE_BAL");  // Account can only transfer tokens that aren't custodied
        require(isReceiveAllowed(unstakeCooldown[to]),                   "SL:RECIPIENT_NOT_ALLOWED");   // Recipient must not be currently unstaking
        require(recognizableLossesOf(from) == uint256(0),                "SL:RECOG_LOSSES");            // If a staker has unrecognized losses, they must recognize losses through unstake
        _updateStakeDate(to, wad);                                                                      // Update stake date of recipient
        super._transfer(from, to, wad);
    }


    function pause() external {
        _isValidPoolDelegateOrPoolAdmin();
        super._pause();
    }

    function unpause() external {
        _isValidPoolDelegateOrPoolAdmin();
        super._unpause();
    }


    function isUnstakeAllowed(address from) public view returns (bool) {
        IMapleGlobals globals = _globals();
        return (block.timestamp - (unstakeCooldown[from] + globals.stakerCooldownPeriod())) <= globals.stakerUnstakeWindow();
    }

    function isReceiveAllowed(uint256 _unstakeCooldown) public view returns (bool) {
        IMapleGlobals globals = _globals();
        return block.timestamp > (_unstakeCooldown + globals.stakerCooldownPeriod() + globals.stakerUnstakeWindow());
    }

    function _isValidPoolDelegateOrPoolAdmin() internal view {
        require(msg.sender == IPool(pool).poolDelegate() || IPool(pool).poolAdmins(msg.sender), "SL:NOT_DELEGATE_OR_ADMIN");
    }

    function _isValidPoolDelegate() internal view {
        require(msg.sender == IPool(pool).poolDelegate(), "SL:NOT_DELEGATE");
    }

    function _isAllowed(address account) internal view {
        require(
            openToPublic || allowed[account] || account == IPool(pool).poolDelegate(),
            "SL:NOT_ALLOWED"
        );
    }

    function _globals() internal view returns (IMapleGlobals) {
        return IMapleGlobals(IPoolFactory(IPool(pool).superFactory()).globals());
    }

    function _whenProtocolNotPaused() internal view {
        require(!_globals().protocolPaused(), "SL:PROTO_PAUSED");
    }

}



contract StakeLockerFactory {

    mapping(address => address) public owner;     // Mapping of StakeLocker addresses to their owner (i.e owner[locker] = Owner of the StakeLocker).
    mapping(address => bool)    public isLocker;  // True only if a StakeLocker was created by this factory.

    uint8 public constant factoryType = 4;  // i.e FactoryType::STAKE_LOCKER_FACTORY.

    event StakeLockerCreated(
        address indexed owner,
        address stakeLocker,
        address stakeAsset,
        address liquidityAsset,
        string name,
        string symbol
    );

    function newLocker(
        address stakeAsset,
        address liquidityAsset
    ) external returns (address stakeLocker) {
        stakeLocker           = address(new StakeLocker(stakeAsset, liquidityAsset, msg.sender));
        owner[stakeLocker]    = msg.sender;
        isLocker[stakeLocker] = true;

        emit StakeLockerCreated(
            msg.sender,
            stakeLocker,
            stakeAsset,
            liquidityAsset,
            StakeLocker(stakeLocker).name(),
            StakeLocker(stakeLocker).symbol()
        );
    }

}