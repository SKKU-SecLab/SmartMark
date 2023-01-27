



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
}



pragma solidity >=0.6.0 <0.8.0;



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

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity 0.6.12;

interface IHegicStaking is IERC20 {
    function classicLockupPeriod() external view returns (uint256);
    function lastBoughtTimestamp(address) external view returns (uint256);

    function claimProfits(address account) external returns (uint profit);
    function buyStakingLot(uint amount) external;
    function sellStakingLot(uint amount) external;
    function profitOf(address account) external view returns (uint profit);
}

interface IHegicStakingETH is IHegicStaking {
    function sendProfit() external payable;
}

interface IHegicStakingERC20 is IHegicStaking {
    function sendProfit(uint amount) external;
}

interface IOldStakingPool {
    function ownerPerformanceFee(address account) external view returns (uint);
    function withdraw(uint256 amount) external;
}

interface IOldPool {
    function withdraw(uint256 amount) external returns (uint);
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



pragma solidity 0.6.12;




contract HegicStakingPool is Ownable, ERC20{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public immutable HEGIC;

    mapping(Asset => IHegicStaking) public staking; 

    uint public constant STAKING_LOT_PRICE = 888_000e18;
    uint public constant ACCURACY = 1e32;

    address payable public FALLBACK_RECIPIENT;
    address payable public FEE_RECIPIENT;

    address public constant OLD_HEGIC_STAKING_POOL = address(0xf4128B00AFdA933428056d0F0D1d7652aF7e2B35);
    address public constant Z_HEGIC = address(0x837010619aeb2AE24141605aFC8f66577f6fb2e7);

    uint public performanceFee = 5000;
    uint public discountedPerformanceFee = 4000;
    bool public depositsAllowed = true;
    uint public lockUpPeriod = 15 minutes;
    bool private migrating;

    uint public totalBalance;
    uint public lockedBalance;
    uint public totalNumberOfStakingLots;

    mapping(Asset => uint) public numberOfStakingLots;
    mapping(Asset => uint) public totalProfitPerToken;
    mapping(Asset => IERC20) public token;
    enum Asset {WBTC, ETH, USDC}

    mapping(address => uint) public ownerPerformanceFee;
    mapping(address => bool) public isNotFirstTime;
    mapping(address => uint) public lastDepositTime;
    mapping(address => mapping(Asset => uint)) lastProfit;
    mapping(address => mapping(Asset => uint)) savedProfit;

    event Deposit(address account, uint amount);
    event Withdraw(address account, uint amount);
    event BuyLot(Asset asset, address account);
    event SellLot(Asset asset, address account);
    event ClaimedProfit(address account, Asset asset, uint netProfit, uint fee);

    constructor(IERC20 _HEGIC, IERC20 _WBTC, IERC20 _WETH, IERC20 _USDC, IHegicStaking _stakingWBTC, IHegicStaking _stakingETH, IHegicStaking _stakingUSDC) public ERC20("Staked HEGIC", "sHEGIC"){
        HEGIC = _HEGIC;
        staking[Asset.WBTC] = _stakingWBTC;
        staking[Asset.ETH] = _stakingETH;
        staking[Asset.USDC] = _stakingUSDC;
        token[Asset.WBTC] = _WBTC;
        token[Asset.ETH] = _WETH;
        token[Asset.USDC] = _USDC;
        FEE_RECIPIENT = msg.sender;
        FALLBACK_RECIPIENT = msg.sender;

        _HEGIC.approve(address(staking[Asset.WBTC]), type(uint256).max);
        _HEGIC.approve(address(staking[Asset.ETH]), type(uint256).max);
        _HEGIC.approve(address(staking[Asset.USDC]), type(uint256).max);
    }

    function approveContracts() external {
        require(depositsAllowed);
        HEGIC.approve(address(staking[Asset.WBTC]), type(uint256).max);
        HEGIC.approve(address(staking[Asset.ETH]), type(uint256).max);
        HEGIC.approve(address(staking[Asset.USDC]), type(uint256).max);
    }

    function allowDeposits(bool _allow) external onlyOwner {
        depositsAllowed = _allow;
    }

    function changePerformanceFee(uint _fee) external onlyOwner {
        require(_fee >= 0, "Fee too low");
        require(_fee <= 10000, "Fee too high");
        
        performanceFee = _fee;
    }

    function changeDiscountedPerformanceFee(uint _fee) external onlyOwner {
        require(_fee >= 0, "Fee too low");
        require(_fee <= 10000, "Fee too high");

        discountedPerformanceFee = _fee;
    }

    function changeFeeRecipient(address _recipient) external onlyOwner {
        FEE_RECIPIENT = payable(_recipient);
    }

    function changeFallbackRecipient(address _recipient) external onlyOwner {
        FALLBACK_RECIPIENT = payable(_recipient);
    }

    function unlockAllFunds(bool _unlock) external onlyOwner {
        if(_unlock) lockUpPeriod = 0;
        else lockUpPeriod = 15 minutes;
    }

    function migrateFromOldStakingPool(IOldStakingPool oldStakingPool) external returns (uint) {
        IERC20 sToken;
        isNotFirstTime[msg.sender] = true;
        if(address(oldStakingPool) == address(OLD_HEGIC_STAKING_POOL)) {
            sToken = IERC20(address(oldStakingPool));
            uint oldPerformanceFee = oldStakingPool.ownerPerformanceFee(msg.sender);
            uint dFee = discountedPerformanceFee;
            if(oldPerformanceFee > dFee) {
                ownerPerformanceFee[msg.sender] = dFee;
            } else {
                ownerPerformanceFee[msg.sender] = oldStakingPool.ownerPerformanceFee(msg.sender);
            }
        } else {
            sToken = IERC20(Z_HEGIC);
            ownerPerformanceFee[msg.sender] = discountedPerformanceFee;
        }
        require(sToken.balanceOf(msg.sender) > 0, "Not enough balance / not supported");
        uint256 oldBalance = sToken.balanceOf(msg.sender);
        sToken.safeTransferFrom(msg.sender, address(this), oldBalance);
        if(address(oldStakingPool) == address(OLD_HEGIC_STAKING_POOL)) {
            oldStakingPool.withdraw(oldBalance);
        } else {
            oldBalance = IOldPool(address(oldStakingPool)).withdraw(oldBalance);
        }
        migrating = true;
        deposit(oldBalance);
        return oldBalance;
    }

    function deposit(uint _amount) public {
        require(_amount > 0, "Amount too low");
        require(depositsAllowed, "Deposits are not allowed at the moment");
        if(ownerPerformanceFee[msg.sender] > performanceFee || !isNotFirstTime[msg.sender]) {
            ownerPerformanceFee[msg.sender] = performanceFee;
            isNotFirstTime[msg.sender] = true;
        }
        lastDepositTime[msg.sender] = block.timestamp;
        depositHegic(_amount);

        while(totalBalance.sub(lockedBalance) >= STAKING_LOT_PRICE){
            buyStakingLot();
        }
    }

    function withdraw(uint _amount) public {
        require(_amount <= balanceOf(msg.sender), "Not enough balance");
        require(canWithdraw(msg.sender), "You deposited less than 15 mins ago. Your funds are locked");

        while(totalBalance.sub(lockedBalance) < _amount){
            sellStakingLot();
        }

        withdrawHegic(_amount);
    }

    function claimProfitAndWithdraw() external {
        claimAllProfit();
        withdraw(balanceOf(msg.sender));
    }

    function claimAllProfit() public {
        claimProfit(Asset.WBTC);
        claimProfit(Asset.ETH);
        claimProfit(Asset.USDC);
    }

    function claimProfit(Asset _asset) public {
        uint profit = saveProfit(msg.sender, _asset);
        savedProfit[msg.sender][_asset] = 0;
        
        _transferProfit(profit, _asset, msg.sender, ownerPerformanceFee[msg.sender]);
    }

    function profitOf(address _account, Asset _asset) public view returns (uint profit) {
        return savedProfit[_account][_asset].add(getUnsaved(_account, _asset));
    }

    function getHegicStakingETH() public view returns (IHegicStaking HegicStakingETH){
        return staking[Asset.ETH];
    }

    function getHegicStakingWBTC() public view returns (IHegicStaking HegicStakingWBTC){
        return staking[Asset.WBTC];
    }

    function getHegicStakingUSDC() public view returns (IHegicStaking HegicStakingWBTC){
        return staking[Asset.USDC];
    }

    function getUnsaved(address _account, Asset _asset) public view returns (uint profit) {
        profit = totalProfitPerToken[_asset].sub(lastProfit[_account][_asset]).add(getUnreceivedProfitPerToken(_asset)).mul(balanceOf(_account)).div(ACCURACY);
    }

    function updateProfit(Asset _asset) internal {
        uint profit = staking[_asset].profitOf(address(this));
        if(profit > 0) {
            profit = staking[_asset].claimProfits(address(this));
        }

        if(totalBalance <= 0) {
            IERC20 assetToken = token[_asset];
            assetToken.safeTransfer(FALLBACK_RECIPIENT, profit);
        } else {
            totalProfitPerToken[_asset] = totalProfitPerToken[_asset].add(profit.mul(ACCURACY).div(totalBalance));
        }
    }

    function _transferProfit(uint _amount, Asset _asset, address _account, uint _fee) internal {
        uint netProfit = _amount.mul(uint(100000).sub(_fee)).div(100000);
        uint fee = _amount.sub(netProfit);

        IERC20 assetToken = token[_asset]; 
        assetToken.safeTransfer(_account, netProfit);
        assetToken.safeTransfer(FEE_RECIPIENT, fee);
        emit ClaimedProfit(_account, _asset, netProfit, fee);
    }

    function depositHegic(uint _amount) internal {
        totalBalance = totalBalance.add(_amount); 
        if(!migrating) {
            HEGIC.safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            migrating = false;
            require(totalBalance == HEGIC.balanceOf(address(this)).add(lockedBalance), "!");
        }

        _mint(msg.sender, _amount);
    }

    function withdrawHegic(uint _amount) internal {
        _burn(msg.sender, _amount);
        HEGIC.safeTransfer(msg.sender, _amount);
        totalBalance = totalBalance.sub(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function buyStakingLot() internal {
        Asset asset = Asset.USDC;
        if(numberOfStakingLots[Asset.USDC] >= numberOfStakingLots[Asset.WBTC]){
            if(numberOfStakingLots[Asset.WBTC] >= numberOfStakingLots[Asset.ETH]){
                asset = Asset.ETH;
            } else {
                asset = Asset.WBTC;
            }
        }

        lockedBalance = lockedBalance.add(STAKING_LOT_PRICE);
        staking[asset].buyStakingLot(1);
        totalNumberOfStakingLots++;
        numberOfStakingLots[asset]++;
        emit BuyLot(asset, msg.sender);
    }

    function sellStakingLot() internal {
        Asset asset = Asset.ETH;
        if(numberOfStakingLots[Asset.ETH] <= numberOfStakingLots[Asset.WBTC] || 
            staking[Asset.ETH].lastBoughtTimestamp(address(this))
                    .add(staking[Asset.ETH].classicLockupPeriod()) > block.timestamp || 
            staking[Asset.ETH].balanceOf(address(this)) == 0)
        {
            if(numberOfStakingLots[Asset.WBTC] <= numberOfStakingLots[Asset.USDC] && 
                staking[Asset.USDC].lastBoughtTimestamp(address(this))
                    .add(staking[Asset.USDC].classicLockupPeriod()) <= block.timestamp && 
                staking[Asset.USDC].balanceOf(address(this)) > 0){
                asset = Asset.USDC;
            } else if (staking[Asset.WBTC].lastBoughtTimestamp(address(this))
                    .add(staking[Asset.WBTC].classicLockupPeriod()) <= block.timestamp && 
                staking[Asset.WBTC].balanceOf(address(this)) > 0){
                asset = Asset.WBTC;
            } else {
                asset = Asset.ETH;
                require(
                    staking[asset].lastBoughtTimestamp(address(this))
                        .add(staking[asset].classicLockupPeriod()) <= block.timestamp &&
                        staking[asset].balanceOf(address(this)) > 0,
                    "Lot sale is locked by Hegic. Funds should be available in less than 24h"
                );
            }
        }

        lockedBalance = lockedBalance.sub(STAKING_LOT_PRICE);
        staking[asset].sellStakingLot(1);
        totalNumberOfStakingLots--;
        numberOfStakingLots[asset]--;
        emit SellLot(asset, msg.sender);
    }

    function getUnreceivedProfitPerToken(Asset _asset) public view returns (uint unreceivedProfitPerToken){
        uint profit = staking[_asset].profitOf(address(this));
        
        unreceivedProfitPerToken = profit.mul(ACCURACY).div(totalBalance);
    }

    function saveProfit(address _account) internal {
        saveProfit(_account, Asset.WBTC);
        saveProfit(_account, Asset.ETH);
        saveProfit(_account, Asset.USDC);
    }

    function saveProfit(address _account, Asset _asset) internal returns (uint profit) {
        updateProfit(_asset);
        uint unsaved = getUnsaved(_account, _asset);
        lastProfit[_account][_asset] = totalProfitPerToken[_asset];
        profit = savedProfit[_account][_asset].add(unsaved);
        savedProfit[_account][_asset] = profit;
    }

    function _beforeTokenTransfer(address from, address to, uint256) internal override {
        require(canWithdraw(from), "!locked funds");
        if (from != address(0)) saveProfit(from);
        if (to != address(0)) saveProfit(to);
    }

    function canWithdraw(address _account) public view returns (bool) {
        return (lastDepositTime[_account].add(lockUpPeriod) <= block.timestamp);
    }
}