
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

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

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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

}// GPL-3.0


pragma solidity 0.6.12;

interface IHegicStaking is IERC20 {
    function claimProfit() external returns (uint profit);
    function buy(uint amount) external;
    function sell(uint amount) external;
    function profitOf(address account) external view returns (uint profit);
}


interface IHegicStakingETH is IHegicStaking {
    function sendProfit() external payable;
}


interface IHegicStakingERC20 is IHegicStaking {
    function sendProfit(uint amount) external;
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

pragma solidity ^0.6.0;


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
pragma solidity 0.6.12;



abstract contract HegicPooledStaking is Ownable, ERC20{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public immutable HEGIC;

    IHegicStaking public staking;

    uint public LOCK_UP_PERIOD = 24 hours;
    uint public STAKING_LOT_PRICE = 888_000e18;
    uint public ACCURACY = 1e30;
    address payable public FALLBACK_RECIPIENT;
    address payable public FEE_RECIPIENT;
    uint public FEE;

    uint public numberOfStakingLots;
    uint public totalBalance;
    uint public lockedBalance;
    uint public totalProfitPerToken;
    bool public emergencyUnlockState;
    bool public depositsAllowed;

    mapping(uint => mapping(address => uint)) stakingLotShares;
    mapping(uint => address[]) stakingLotOwners;
    mapping(uint => uint) stakingLotUnlockTime;
    mapping(uint => bool) stakingLotActive;
    mapping(uint => uint) startProfit;

    mapping(address => uint[]) ownedStakingLots; 
    mapping(address => uint) savedProfit; 
    mapping(address => uint) lastProfit; 
    mapping(address => uint) ownerPerformanceFee;

    event Deposit(address account, uint amount);
    event Withdraw(address account, uint amount);
    event AddLiquidity(address account, uint amount, uint lotId);
    event BuyLot(address account, uint lotId);
    event SellLot(address account, uint lotId);
    event PayProfit(address account, uint profit, uint fee);

    constructor(IERC20 _token, IHegicStaking _staking, string memory name, string memory symbol) public ERC20(name, symbol){
        HEGIC = _token;
        staking = _staking;
        totalBalance = 0;
        lockedBalance = 0;
        numberOfStakingLots = 0;
        totalProfitPerToken = 0;
        
        FALLBACK_RECIPIENT = msg.sender;
        FEE_RECIPIENT = msg.sender;
        FEE = 5;

        emergencyUnlockState = false;
        depositsAllowed = true;

        _token.approve(address(_staking), 888e30);
    }

    receive() external payable {}

    function emergencyUnlock(bool _unlock) external onlyOwner {
        emergencyUnlockState = _unlock;
    }

    function allowDeposits(bool _allow) external onlyOwner {
        depositsAllowed = _allow;
    }

    function changeFee(uint _fee) external onlyOwner {
        require(_fee >= 0, "Fee too low");
        require(_fee <= 8, "Fee too high");
        
        FEE = _fee;
    }

    function changeFeeRecipient(address _recipient) external onlyOwner {
        FEE_RECIPIENT = payable(_recipient);
    }

    function changeFallbackRecipient(address _recipient) external onlyOwner {
        FALLBACK_RECIPIENT = payable(_recipient);
    }

    function changeLockUpPeriod(uint _newLockUpPeriod) external onlyOwner {
        require(_newLockUpPeriod <= 2 weeks, "Lock up period too long");
        require(_newLockUpPeriod >= 24 hours, "Lock up period too short");
        LOCK_UP_PERIOD = _newLockUpPeriod;
    }

    function deposit(uint _HEGICAmount) external {
        require(_HEGICAmount > 0, "Amount too low");
        require(_HEGICAmount < STAKING_LOT_PRICE, "Amount too high, buy your own lot");
        require(depositsAllowed, "Deposits are not allowed at the moment");

        if(ownerPerformanceFee[msg.sender] > FEE || balanceOf(msg.sender) == 0) 
            ownerPerformanceFee[msg.sender] = FEE;

        depositHegic(_HEGICAmount);

        useLiquidity(_HEGICAmount, msg.sender);

        emit Deposit(msg.sender, _HEGICAmount);
    }

    function depositHegic(uint _HEGICAmount) internal {
        totalBalance = totalBalance.add(_HEGICAmount); 

        _mint(msg.sender, _HEGICAmount);

        HEGIC.safeTransferFrom(msg.sender, address(this), _HEGICAmount);
    }

    function useLiquidity(uint _HEGICAmount, address _account) internal {
        if(totalBalance.sub(lockedBalance) >= STAKING_LOT_PRICE){
            uint pendingAmount = totalBalance.sub(lockedBalance).sub(STAKING_LOT_PRICE);
            addToNextLot(_HEGICAmount.sub(pendingAmount), _account); 
            buyStakingLot();
            if(pendingAmount > 0) addToNextLot(pendingAmount, _account);
        } else {
            addToNextLot(_HEGICAmount, _account);
        }
    }

    function buyStakingLot() internal {
        lockedBalance = lockedBalance.add(STAKING_LOT_PRICE);
        staking.buy(1);
        emit BuyLot(msg.sender, numberOfStakingLots);

        startProfit[numberOfStakingLots] = totalProfitPerToken;
        stakingLotUnlockTime[numberOfStakingLots] = now + LOCK_UP_PERIOD;
        stakingLotActive[numberOfStakingLots] = true;

        numberOfStakingLots = numberOfStakingLots + 1;
    }

    function addToNextLot(uint _amount, address _account) internal {
        if(stakingLotShares[numberOfStakingLots][_account] == 0) {
            ownedStakingLots[_account].push(numberOfStakingLots); // if first contribution in this lot: add to list
            stakingLotOwners[numberOfStakingLots].push(_account);
        }

        stakingLotShares[numberOfStakingLots][_account] = stakingLotShares[numberOfStakingLots][_account].add(_amount);
        
        emit AddLiquidity(_account, _amount, numberOfStakingLots);
    }

    function exchangeStakedForReal(uint _amount) internal {
        totalBalance = totalBalance.sub(_amount);
        _burn(msg.sender, _amount);
        HEGIC.safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function exitFromStakingLot(uint _slotId) external {
        require(stakingLotShares[_slotId][msg.sender] > 0, "Not participating in this lot");
        require(_slotId <= numberOfStakingLots, "Staking lot not found");

        if(_slotId == numberOfStakingLots){
            uint shares = stakingLotShares[_slotId][msg.sender];
            stakingLotShares[_slotId][msg.sender] = 0;
            exchangeStakedForReal(shares);
        } else {
            require((stakingLotUnlockTime[_slotId] <= now) || emergencyUnlockState, "Staking Lot is still locked");
            require(stakingLotShares[numberOfStakingLots][msg.sender] == 0, "Please withdraw your non-staked liquidity first");        
            
            staking.sell(1);
            emit SellLot(msg.sender, _slotId);
            stakingLotActive[_slotId] = false;

            address[] memory slOwners = stakingLotOwners[_slotId];

            uint shares = stakingLotShares[_slotId][msg.sender]; 
            stakingLotShares[_slotId][msg.sender] = 0;
            exchangeStakedForReal(shares);
            lockedBalance -= shares;

            address owner;
            for(uint i = 0; i < slOwners.length; i++) {
                owner = slOwners[i];
                shares = stakingLotShares[_slotId][owner];
                stakingLotShares[_slotId][owner] = 0; // put back to 0 the participation in this lot

                if(owner != msg.sender) {
                    lockedBalance -= shares;
                    saveProfit(owner);
                    useLiquidity(shares, owner);
                }
            }
        }
    }

    function updateProfit() public virtual;

    function claimProfit() external {
        uint profit = saveProfit(msg.sender);
        savedProfit[msg.sender] = 0;
        _transferProfit(profit, msg.sender, ownerPerformanceFee[msg.sender]);
        emit PayProfit(msg.sender, profit, ownerPerformanceFee[msg.sender]);
    }

    function getNotPayableProfit(address _account) public view returns (uint notPayableProfit) {
        if(ownedStakingLots[_account].length > 0){
            uint lastStakingLot = ownedStakingLots[_account][ownedStakingLots[_account].length-1];
            uint accountLastProfit = lastProfit[_account];

            if(accountLastProfit <= startProfit[lastStakingLot]) {
                uint lastTakenProfit = accountLastProfit.mul(balanceOf(_account).sub(stakingLotShares[lastStakingLot][_account]));
                uint initialNotPayableProfit = startProfit[lastStakingLot].mul(stakingLotShares[lastStakingLot][_account]);
                notPayableProfit = lastTakenProfit.add(initialNotPayableProfit);
            } else {
                notPayableProfit = accountLastProfit.mul(balanceOf(_account).sub(getUnlockedTokens(_account)));
            }
        }
    }

    function getUnlockedTokens(address _account) public view returns (uint lockedTokens){
         if(ownedStakingLots[_account].length > 0) {
            uint lastStakingLot = ownedStakingLots[_account][ownedStakingLots[_account].length-1];
            if(lastStakingLot == numberOfStakingLots) lockedTokens = stakingLotShares[lastStakingLot][_account];
         }
    }

    function getUnsaved(address _account) public view returns (uint profit) {
        uint accountBalance = balanceOf(_account);
        uint unlockedTokens = getUnlockedTokens(_account);
        uint tokens = accountBalance.sub(unlockedTokens);
        profit = 0;
        if(tokens > 0) 
            profit = totalProfitPerToken.mul(tokens).sub(getNotPayableProfit(_account)).div(ACCURACY);
    }

    function getUnreceivedProfit(address _account) public view returns (uint unreceived){
        uint accountBalance = balanceOf(_account);
        uint unlockedTokens = getUnlockedTokens(_account);
        uint tokens = accountBalance.sub(unlockedTokens);
        uint profit = staking.profitOf(address(this));
        if(lockedBalance > 0)
            unreceived = profit.mul(ACCURACY).div(lockedBalance).mul(tokens).div(ACCURACY);
        else
            unreceived = 0;
    }

    function profitOf(address _account) external view returns (uint profit) {
        uint unreceived = getUnreceivedProfit(_account);
        return savedProfit[_account].add(getUnsaved(_account)).add(unreceived);
    }

    function saveProfit(address _account) internal returns (uint profit) {
        updateProfit();
        uint unsaved = getUnsaved(_account);
        lastProfit[_account] = totalProfitPerToken;
        profit = savedProfit[_account].add(unsaved);
        savedProfit[_account] = profit;
    }

    function _beforeTokenTransfer(address from, address to, uint256) internal override {
        if (from != address(0)) saveProfit(from);
        if (to != address(0)) saveProfit(to);
    }

    function _transferProfit(uint _amount, address _account, uint _fee) internal virtual;

    function getStakingLotShares(uint _slotId, address _account) view public returns (uint) {
        return stakingLotShares[_slotId][_account];
    }

    function isInLockUpPeriod(uint _slotId) view public returns (bool) {
        return !((stakingLotUnlockTime[_slotId] <= now) || emergencyUnlockState);
    }

    function isActive(uint _slotId) view public returns (bool) {
        return stakingLotActive[_slotId];
    }

    function getLotOwners(uint _slotId) view public returns (address[] memory slOwners) {
        slOwners = stakingLotOwners[_slotId];
    }

    function getOwnerPerformanceFee(address _account) view public returns (uint performanceFee) {
        performanceFee = ownerPerformanceFee[_account];
    }


}// GPL-3.0
pragma solidity 0.6.12;


contract HegicPooledStakingETH is HegicPooledStaking {

    constructor(IERC20 _token, IHegicStaking _staking) public HegicPooledStaking(_token, _staking, "ETH Staked HEGIC", "sHEGICETH") {
    }

    function _transferProfit(uint _amount, address _account, uint _fee) internal override{
        uint netProfit = _amount.mul(uint(100).sub(_fee)).div(100);
        payable(_account).transfer(netProfit);
        FEE_RECIPIENT.transfer(_amount.sub(netProfit));
    }

    function updateProfit() public override {
        uint profit = staking.profitOf(address(this));
        if(profit > 0) profit = staking.claimProfit();
        if(lockedBalance <= 0) FALLBACK_RECIPIENT.transfer(profit);
        else totalProfitPerToken = totalProfitPerToken.add(profit.mul(ACCURACY).div(lockedBalance));
    }
}// GPL-3.0
pragma solidity 0.6.12;


contract HegicPooledStakingWBTC is HegicPooledStaking {

    IERC20 public immutable underlying;

    constructor(IERC20 _token, IHegicStaking _staking, IERC20 _underlying) public 
        HegicPooledStaking(_token, _staking, "WBTC Staked HEGIC", "sHEGICWBTC") {
        underlying = _underlying;
    }

    function _transferProfit(uint _amount, address _account, uint _fee) internal override {
        uint netProfit = _amount.mul(uint(100).sub(_fee)).div(100);
        underlying.safeTransfer(_account, netProfit);
        underlying.safeTransfer(FEE_RECIPIENT, _amount.sub(netProfit));
    }

    function updateProfit() public override {
        uint profit = staking.profitOf(address(this));
        if(profit > 0){ 
            profit = staking.claimProfit();
            if(lockedBalance <= 0) underlying.safeTransfer(FALLBACK_RECIPIENT, profit);
            else totalProfitPerToken = totalProfitPerToken.add(profit.mul(ACCURACY).div(lockedBalance));
        }
    }
}// GPL-3.0

pragma solidity >=0.4.22 <0.8.0;

contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }
}// GPL-3.0

pragma solidity 0.6.12;

contract FakeHegicStakingETH is ERC20("Hegic ETH Staking Lot", "hlETH"), IHegicStakingETH {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    uint public LOT_PRICE = 888_000e18;
    IERC20 public token;

    uint public totalProfit;
    
    event Claim(address account, uint profit);

    constructor(IERC20 _token) public {
        totalProfit = 0;
        token = _token;
        _setupDecimals(0);
    }

    function sendProfit() external payable override {
        totalProfit = totalProfit.add(msg.value);
    }

    function claimProfit() external override returns (uint _profit) {
        _profit = totalProfit;
        require(_profit > 0, "Zero profit");
        emit Claim(msg.sender, _profit);   
        _transferProfit(_profit);
        totalProfit = totalProfit.sub(_profit);
    }

    function _transferProfit(uint _profit) internal {
        msg.sender.transfer(_profit);
    }

    function buy(uint _amount) external override {
        require(_amount > 0, "Amount is zero");
        _mint(msg.sender, _amount);
        token.safeTransferFrom(msg.sender, address(this), _amount.mul(LOT_PRICE));

    }

    function sell(uint _amount) external override {
        _burn(msg.sender, _amount);
        token.safeTransfer(msg.sender, _amount.mul(LOT_PRICE));
    }

    function profitOf(address) public view override returns (uint _totalProfit) {
        _totalProfit = totalProfit;
    }
}


contract FakeHegicStakingWBTC is ERC20("Hegic WBTC Staking Lot", "hlWBTC"), IHegicStakingERC20 {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint public totalProfit;
    IERC20 public immutable WBTC;
    IERC20 public token;

    uint public LOT_PRICE = 888_000e18;

    event Claim(address account, uint profit);

    constructor(IERC20 _wbtc, IERC20 _token) public {
        WBTC = _wbtc;
        token = _token;
        totalProfit = 0;
        _setupDecimals(0);

    }

    function sendProfit(uint _amount) external override {
        WBTC.safeTransferFrom(msg.sender, address(this), _amount);
        totalProfit = totalProfit.add(_amount);
    }

    function claimProfit() external override returns (uint _profit) {
        _profit = totalProfit;
        require(_profit > 0, "Zero profit");
        emit Claim(msg.sender, _profit);   
        _transferProfit(_profit);
        totalProfit = totalProfit.sub(_profit);
    }

    function _transferProfit(uint _profit) internal {
        WBTC.safeTransfer(msg.sender, _profit);
    }

    function buy(uint _amount) external override {
        require(_amount > 0, "Amount is zero");
        _mint(msg.sender, _amount);
        token.safeTransferFrom(msg.sender, address(this), _amount.mul(LOT_PRICE));
    }

    function sell(uint _amount) external override {
        _burn(msg.sender, _amount);
        token.safeTransfer(msg.sender, _amount.mul(LOT_PRICE));
    }

    function profitOf(address) public view override returns (uint _totalProfit) {
        _totalProfit = totalProfit;
    }
}

contract FakeWBTC is ERC20("FakeWBTC", "FAKE") {
    constructor() public {
        _setupDecimals(8);
    }

    function mintTo(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}


contract FakeHEGIC is ERC20("FakeHEGIC", "FAKEH") {
    using SafeERC20 for ERC20;

    function mintTo(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}