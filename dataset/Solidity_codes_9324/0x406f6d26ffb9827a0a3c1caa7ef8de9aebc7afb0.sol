pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}pragma solidity ^0.6.0;

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.
Copyright (c) 2020 Base Protocol, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity 0.6.12;


library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a)
        internal
        pure
        returns (int256)
    {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.2;

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
}pragma solidity 0.6.12;


contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    uint256[44] private __gap;
}pragma solidity 0.6.12;


abstract contract ERC677 {
    function transfer(address to, uint256 value) public virtual returns (bool);
    function transferAndCall(address to, uint value, bytes memory data) public virtual returns (bool success);
}pragma solidity 0.6.12;


abstract contract ERC677Receiver {
    function onTokenTransfer(address _sender, uint _value, bytes memory _data) virtual public;
}pragma solidity 0.6.12;



abstract contract ERC677Token is ERC677 {
    function transferAndCall(address _to, uint _value, bytes memory _data)
        public
        override
        returns (bool success)
    {
        transfer(_to, _value);
        if (isContract(_to)) {
            contractFallback(_to, _value, _data);
        }
        return true;
    }

    function contractFallback(address _to, uint _value, bytes memory _data)
        private
    {
        ERC677Receiver receiver = ERC677Receiver(_to);
        receiver.onTokenTransfer(msg.sender, _value, _data);
    }

    function isContract(address _addr)
        private
        view
        returns (bool hasCode)
    {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}pragma solidity 0.6.12;



interface ISync {

    function sync() external;

}

interface IGulp {

    function gulp(address token) external;

}

contract BaseToken is ERC20UpgradeSafe, ERC677Token, OwnableUpgradeSafe {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);
    event AdminRescueTokens(address token, address recipient, uint256 amount);

    address public monetaryPolicy;

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_SUPPLY = 8795645 * 10**DECIMALS;
    uint256 private constant INITIAL_SHARES = (MAX_UINT256 / (10 ** 36)) - ((MAX_UINT256 / (10 ** 36)) % INITIAL_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private _totalShares;
    uint256 private _totalSupply;
    uint256 private _sharesPerBASE;
    mapping(address => uint256) private _shareBalances;

    mapping(address => bool) public bannedUsers; // Deprecated

    mapping (address => mapping (address => uint256)) private _allowedBASE;

    bool private transfersPaused;
    bool public rebasesPaused;

    mapping(address => bool) private transferPauseExemptList;

    function setRebasesPaused(bool _rebasesPaused)
        public
        onlyOwner
    {

        rebasesPaused = _rebasesPaused;
    }

    function setMonetaryPolicy(address monetaryPolicy_)
        external
        onlyOwner
    {

        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    function adminRescueTokens(address token, address recipient) external onlyOwner {

        require(token != address(0x0), "zero address");
        require(recipient != address(0x0), "bad recipient");

        uint256 amount = IERC20(token).balanceOf(address(this));
        bool ok = IERC20(token).transfer(recipient, amount);
        require(ok, "transfer");

        emit AdminRescueTokens(token, recipient, amount);
    }

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (uint256)
    {

        require(msg.sender == monetaryPolicy, "only monetary policy");
        require(!rebasesPaused, "rebases paused");

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _sharesPerBASE = _totalShares.div(_totalSupply);


        emit LogRebase(epoch, _totalSupply);

        ISync(0xdE5b7Ff5b10CC5F8c95A2e2B643e3aBf5179C987).sync();              // Uniswap BASE/ETH
        ISync(0xD8B8B575c943f3d63638c9563B464D204ED8B710).sync();              // Sushiswap BASE/ETH
        IGulp(0x19B770c8F9d5439C419864d8458255791f7e736C).gulp(address(this)); // Value BASE/USDC #1
        ISync(0x90A6DBC347CA01b2077f6e6729Cd6e16c5E669Bc).sync();              // Value BASE/USDC #2

        return _totalSupply;
    }

    function totalShares()
        public
        view
        returns (uint256)
    {

        return _totalShares;
    }

    function sharesOf(address user)
        public
        view
        returns (uint256)
    {

        return _shareBalances[user];
    }

    function initialize()
        public
        initializer
    {

        __ERC20_init("Base Protocol", "BASE");
        _setupDecimals(uint8(DECIMALS));
        __Ownable_init();

        _totalShares = INITIAL_SHARES;
        _totalSupply = INITIAL_SUPPLY;
        _shareBalances[owner()] = _totalShares;
        _sharesPerBASE = _totalShares.div(_totalSupply);

        emit Transfer(address(0x0), owner(), _totalSupply);
    }

    function totalSupply()
        public
        override
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address who)
        public
        override
        view
        returns (uint256)
    {

        return _shareBalances[who].div(_sharesPerBASE);
    }

    function transfer(address to, uint256 value)
        public
        override(ERC20UpgradeSafe, ERC677)
        validRecipient(to)
        returns (bool)
    {

        uint256 shareValue = value.mul(_sharesPerBASE);
        _shareBalances[msg.sender] = _shareBalances[msg.sender].sub(shareValue);
        _shareBalances[to] = _shareBalances[to].add(shareValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        public
        override
        view
        returns (uint256)
    {

        return _allowedBASE[owner_][spender];
    }

    function transferFrom(address from, address to, uint256 value)
        public
        override
        validRecipient(to)
        returns (bool)
    {

        _allowedBASE[from][msg.sender] = _allowedBASE[from][msg.sender].sub(value);

        uint256 shareValue = value.mul(_sharesPerBASE);
        _shareBalances[from] = _shareBalances[from].sub(shareValue);
        _shareBalances[to] = _shareBalances[to].add(shareValue);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {

        _allowedBASE[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {

        _allowedBASE[msg.sender][spender] = _allowedBASE[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedBASE[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {

        uint256 oldValue = _allowedBASE[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedBASE[msg.sender][spender] = 0;
        } else {
            _allowedBASE[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedBASE[msg.sender][spender]);
        return true;
    }
}pragma solidity 0.6.12;


interface ICascadeV1 {

    function depositInfo(address user) external view
        returns (
            uint256 _lpTokensDeposited,
            uint256 _depositTimestamp,
            uint8   _multiplierLevel,
            uint256 _mostRecentBASEWithdrawal,
            uint256 _userDepositSeconds,
            uint256 _totalDepositSeconds
        );

}

contract CascadeV2 is OwnableUpgradeSafe {

    using SafeMath for uint256;

    mapping(address => uint256)   public userDepositsNumDeposits;
    mapping(address => uint256[]) public userDepositsNumLPTokens;
    mapping(address => uint256[]) public userDepositsDepositTimestamp;
    mapping(address => uint8[])   public userDepositsMultiplierLevel;
    mapping(address => uint256)   public userTotalLPTokensLevel1;
    mapping(address => uint256)   public userTotalLPTokensLevel2;
    mapping(address => uint256)   public userTotalLPTokensLevel3;
    mapping(address => uint256)   public userDepositSeconds;
    mapping(address => uint256)   public userLastAccountingUpdateTimestamp;

    uint256 public totalDepositedLevel1;
    uint256 public totalDepositedLevel2;
    uint256 public totalDepositedLevel3;
    uint256 public totalDepositSeconds;
    uint256 public lastAccountingUpdateTimestamp;

    uint256[] public rewardsNumShares;
    uint256[] public rewardsVestingStart;
    uint256[] public rewardsVestingDuration;
    uint256[] public rewardsSharesWithdrawn;

    IERC20 public lpToken;
    BaseToken public BASE;
    ICascadeV1 public cascadeV1;

    event Deposit(address indexed user, uint256 tokens, uint256 timestamp);
    event Withdraw(address indexed user, uint256 withdrawnLPTokens, uint256 withdrawnBASETokens, uint256 timestamp);
    event UpgradeMultiplierLevel(address indexed user, uint256 depositIndex, uint256 oldLevel, uint256 newLevel, uint256 timestamp);
    event Migrate(address indexed user, uint256 lpTokens, uint256 rewardTokens);
    event AddRewards(uint256 tokens, uint256 shares, uint256 vestingStart, uint256 vestingDuration, uint256 totalTranches);
    event SetBASEToken(address token);
    event SetLPToken(address token);
    event SetCascadeV1(address cascadeV1);
    event UpdateDepositSeconds(address user, uint256 totalDepositSeconds, uint256 userDepositSeconds);
    event AdminRescueTokens(address token, address recipient, uint256 amount);

    function initialize() external initializer {

        __Ownable_init();

        rewardsNumShares.push(0);
        rewardsVestingStart.push(1606763901);
        rewardsVestingDuration.push(7776000);
        rewardsSharesWithdrawn.push(0);
    }


    function setLPToken(address _lpToken) external onlyOwner {

        require(_lpToken != address(0x0), "zero address");
        lpToken = IERC20(_lpToken);
        emit SetLPToken(_lpToken);
    }

    function setBASEToken(address _baseToken) external onlyOwner {

        require(_baseToken != address(0x0), "zero address");
        BASE = BaseToken(_baseToken);
        emit SetBASEToken(_baseToken);
    }

    function setCascadeV1(address _cascadeV1) external onlyOwner {

        require(address(_cascadeV1) != address(0x0), "zero address");
        cascadeV1 = ICascadeV1(_cascadeV1);
        emit SetCascadeV1(_cascadeV1);
    }

    function adminRescueTokens(address token, address recipient, uint256 amount) external onlyOwner {

        require(token != address(0x0), "zero address");
        require(recipient != address(0x0), "bad recipient");
        require(amount > 0, "zero amount");

        bool ok = IERC20(token).transfer(recipient, amount);
        require(ok, "transfer");

        emit AdminRescueTokens(token, recipient, amount);
    }

    function addRewards(uint256 numTokens, uint256 vestingStart, uint256 vestingDuration) external onlyOwner {

        require(numTokens > 0, "zero amount");
        require(vestingStart > 0, "zero vesting start");

        uint256 numShares = tokensToShares(numTokens);
        rewardsNumShares.push(numShares);
        rewardsVestingStart.push(vestingStart);
        rewardsVestingDuration.push(vestingDuration);
        rewardsSharesWithdrawn.push(0);

        bool ok = BASE.transferFrom(msg.sender, address(this), numTokens);
        require(ok, "transfer");

        emit AddRewards(numTokens, numShares, vestingStart, vestingDuration, rewardsNumShares.length);
    }

    function setRewardsTrancheTiming(uint256 tranche, uint256 vestingStart, uint256 vestingDuration) external onlyOwner {

        rewardsVestingStart[tranche] = vestingStart;
        rewardsVestingDuration[tranche] = vestingDuration;
    }


    function deposit(uint256 amount) external {

        require(amount > 0, "zero amount");

        uint256 allowance = lpToken.allowance(msg.sender, address(this));
        require(amount <= allowance, "allowance");

        updateDepositSeconds(msg.sender);

        totalDepositedLevel1 = totalDepositedLevel1.add(amount);
        userDepositsNumDeposits[msg.sender] = userDepositsNumDeposits[msg.sender].add(1);
        userTotalLPTokensLevel1[msg.sender] = userTotalLPTokensLevel1[msg.sender].add(amount);
        userDepositsNumLPTokens[msg.sender].push(amount);
        userDepositsDepositTimestamp[msg.sender].push(now);
        userDepositsMultiplierLevel[msg.sender].push(1);

        bool ok = lpToken.transferFrom(msg.sender, address(this), amount);
        require(ok, "transferFrom");

        emit Deposit(msg.sender, amount, now);
    }

    function withdrawLPTokens(uint256 numLPTokens) external {

        require(numLPTokens > 0, "zero tokens");

        updateDepositSeconds(msg.sender);

        (
            uint256 totalAmountToWithdraw,
            uint256 totalDepositSecondsToBurn,
            uint256 amountToWithdrawLevel1,
            uint256 amountToWithdrawLevel2,
            uint256 amountToWithdrawLevel3
        ) = removeDepositSeconds(numLPTokens);

        uint256 totalRewardShares = unlockedRewardsPoolShares().mul(totalDepositSecondsToBurn).div(totalDepositSeconds);
        removeRewardShares(totalRewardShares);

        totalDepositedLevel1 = totalDepositedLevel1.sub(amountToWithdrawLevel1);
        totalDepositedLevel2 = totalDepositedLevel2.sub(amountToWithdrawLevel2);
        totalDepositedLevel3 = totalDepositedLevel3.sub(amountToWithdrawLevel3);

        userDepositSeconds[msg.sender] = userDepositSeconds[msg.sender].sub(totalDepositSecondsToBurn);
        totalDepositSeconds = totalDepositSeconds.sub(totalDepositSecondsToBurn);

        uint256 rewardTokens = sharesToTokens(totalRewardShares);

        bool ok = lpToken.transfer(msg.sender, totalAmountToWithdraw);
        require(ok, "transfer deposit");
        ok = BASE.transfer(msg.sender, rewardTokens);
        require(ok, "transfer rewards");

        emit Withdraw(msg.sender, totalAmountToWithdraw, rewardTokens, block.timestamp);
    }

    function removeDepositSeconds(uint256 numLPTokens) private
        returns (
            uint256 totalAmountToWithdraw,
            uint256 totalDepositSecondsToBurn,
            uint256 amountToWithdrawLevel1,
            uint256 amountToWithdrawLevel2,
            uint256 amountToWithdrawLevel3
        )
    {

        for (uint256 i = userDepositsNumLPTokens[msg.sender].length; i > 0; i--) {
            uint256 lpTokensToRemove;
            uint256 age = now.sub(userDepositsDepositTimestamp[msg.sender][i-1]);
            uint8   multiplier = userDepositsMultiplierLevel[msg.sender][i-1];

            if (totalAmountToWithdraw.add(userDepositsNumLPTokens[msg.sender][i-1]) <= numLPTokens) {
                lpTokensToRemove = userDepositsNumLPTokens[msg.sender][i-1];
                userDepositsNumDeposits[msg.sender] = userDepositsNumDeposits[msg.sender].sub(1);
                userDepositsNumLPTokens[msg.sender].pop();
                userDepositsDepositTimestamp[msg.sender].pop();
                userDepositsMultiplierLevel[msg.sender].pop();
            } else {
                lpTokensToRemove = numLPTokens.sub(totalAmountToWithdraw);
                userDepositsNumLPTokens[msg.sender][i-1] = userDepositsNumLPTokens[msg.sender][i-1].sub(lpTokensToRemove);
            }

            if (multiplier == 1) {
                userTotalLPTokensLevel1[msg.sender] = userTotalLPTokensLevel1[msg.sender].sub(lpTokensToRemove);
                amountToWithdrawLevel1 = amountToWithdrawLevel1.add(lpTokensToRemove);
                totalDepositSecondsToBurn = totalDepositSecondsToBurn.add(age.mul(lpTokensToRemove));
            } else if (multiplier == 2) {
                userTotalLPTokensLevel2[msg.sender] = userTotalLPTokensLevel2[msg.sender].sub(lpTokensToRemove);
                amountToWithdrawLevel2 = amountToWithdrawLevel2.add(lpTokensToRemove);
                totalDepositSecondsToBurn = totalDepositSecondsToBurn.add(lpTokensToRemove.mul(30 days + (age - 30 days).mul(2)));
            } else if (multiplier == 3) {
                userTotalLPTokensLevel3[msg.sender] = userTotalLPTokensLevel3[msg.sender].sub(lpTokensToRemove);
                amountToWithdrawLevel3 = amountToWithdrawLevel3.add(lpTokensToRemove);
                totalDepositSecondsToBurn = totalDepositSecondsToBurn.add(lpTokensToRemove.mul(30 days + uint256(30 days).mul(2) + (age - 60 days).mul(3)));
            }
            totalAmountToWithdraw = totalAmountToWithdraw.add(lpTokensToRemove);

            if (totalAmountToWithdraw >= numLPTokens) {
                break;
            }
        }
        return (
            totalAmountToWithdraw,
            totalDepositSecondsToBurn,
            amountToWithdrawLevel1,
            amountToWithdrawLevel2,
            amountToWithdrawLevel3
        );
    }

    function removeRewardShares(uint256 totalSharesToRemove) private {

        uint256 totalSharesRemovedSoFar;

        for (uint256 i = rewardsNumShares.length; i > 0; i--) {
            uint256 sharesAvailable = unlockedRewardSharesInTranche(i-1);
            if (sharesAvailable == 0) {
                continue;
            }

            uint256 sharesStillNeeded = totalSharesToRemove.sub(totalSharesRemovedSoFar);
            if (sharesAvailable > sharesStillNeeded) {
                rewardsSharesWithdrawn[i-1] = rewardsSharesWithdrawn[i-1].add(sharesStillNeeded);
                return;
            }

            rewardsSharesWithdrawn[i-1] = rewardsSharesWithdrawn[i-1].add(sharesAvailable);
            totalSharesRemovedSoFar = totalSharesRemovedSoFar.add(sharesAvailable);
            if (rewardsNumShares[i-1].sub(rewardsSharesWithdrawn[i-1]) == 0) {
                rewardsNumShares.pop();
                rewardsVestingStart.pop();
                rewardsVestingDuration.pop();
                rewardsSharesWithdrawn.pop();
            }
        }
    }

    function upgradeMultiplierLevel(uint256[] memory deposits) external {

        require(deposits.length > 0, "no deposits");

        updateDepositSeconds(msg.sender);

        for (uint256 i = 0; i < deposits.length; i++) {
            uint256 idx = deposits[i];
            uint256 age = now.sub(userDepositsDepositTimestamp[msg.sender][idx]);

            if (age <= 30 days || userDepositsMultiplierLevel[msg.sender][idx] == 3) {
                continue;
            }

            uint8 oldLevel = userDepositsMultiplierLevel[msg.sender][idx];
            uint256 tokensDeposited = userDepositsNumLPTokens[msg.sender][idx];

            if (age > 30 days && userDepositsMultiplierLevel[msg.sender][idx] == 1) {
                uint256 secondsSinceLevel2 = age - 30 days;
                uint256 extraDepositSeconds = tokensDeposited.mul(secondsSinceLevel2);
                totalDepositedLevel1 = totalDepositedLevel1.sub(tokensDeposited);
                totalDepositedLevel2 = totalDepositedLevel2.add(tokensDeposited);
                totalDepositSeconds  = totalDepositSeconds.add(extraDepositSeconds);

                userTotalLPTokensLevel1[msg.sender] = userTotalLPTokensLevel1[msg.sender].sub(tokensDeposited);
                userTotalLPTokensLevel2[msg.sender] = userTotalLPTokensLevel2[msg.sender].add(tokensDeposited);
                userDepositSeconds[msg.sender] = userDepositSeconds[msg.sender].add(extraDepositSeconds);
                userDepositsMultiplierLevel[msg.sender][idx] = 2;
            }

            if (age > 60 days && userDepositsMultiplierLevel[msg.sender][idx] == 2) {
                uint256 secondsSinceLevel3 = age - 60 days;
                uint256 extraDepositSeconds = tokensDeposited.mul(secondsSinceLevel3);
                totalDepositedLevel2 = totalDepositedLevel2.sub(tokensDeposited);
                totalDepositedLevel3 = totalDepositedLevel3.add(tokensDeposited);
                totalDepositSeconds  = totalDepositSeconds.add(extraDepositSeconds);

                userTotalLPTokensLevel2[msg.sender] = userTotalLPTokensLevel2[msg.sender].sub(tokensDeposited);
                userTotalLPTokensLevel3[msg.sender] = userTotalLPTokensLevel3[msg.sender].add(tokensDeposited);
                userDepositSeconds[msg.sender] = userDepositSeconds[msg.sender].add(extraDepositSeconds);
                userDepositsMultiplierLevel[msg.sender][idx] = 3;
            }
            emit UpgradeMultiplierLevel(msg.sender, idx, oldLevel, userDepositsMultiplierLevel[msg.sender][idx], block.timestamp);
        }
    }

    function migrate(address user) external {

        require(msg.sender == address(cascadeV1), "only cascade v1");
        require(user != address(0x0), "zero address");

        (
            uint256 numLPTokens,
            uint256 depositTimestamp,
            uint8   multiplier,
            ,
            uint256 userDS,
            uint256 totalDS
        ) = cascadeV1.depositInfo(user);
        uint256 numRewardShares = BASE.sharesOf(address(cascadeV1)).mul(userDS).div(totalDS);

        require(numLPTokens > 0, "no stake");
        require(multiplier > 0, "zero multiplier");
        require(depositTimestamp > 0, "zero timestamp");
        require(userDS > 0, "zero seconds");

        updateDepositSeconds(user);

        userDepositsNumDeposits[user] = userDepositsNumDeposits[user].add(1);
        userDepositsNumLPTokens[user].push(numLPTokens);
        userDepositsMultiplierLevel[user].push(multiplier);
        userDepositsDepositTimestamp[user].push(depositTimestamp);
        userDepositSeconds[user] = userDS;
        userLastAccountingUpdateTimestamp[user] = now;
        totalDepositSeconds = totalDepositSeconds.add(userDS);

        rewardsNumShares[0] = rewardsNumShares[0].add(numRewardShares);

        if (multiplier == 1) {
            totalDepositedLevel1 = totalDepositedLevel1.add(numLPTokens);
            userTotalLPTokensLevel1[user] = userTotalLPTokensLevel1[user].add(numLPTokens);
        } else if (multiplier == 2) {
            totalDepositedLevel2 = totalDepositedLevel2.add(numLPTokens);
            userTotalLPTokensLevel2[user] = userTotalLPTokensLevel2[user].add(numLPTokens);
        } else if (multiplier == 3) {
            totalDepositedLevel3 = totalDepositedLevel3.add(numLPTokens);
            userTotalLPTokensLevel3[user] = userTotalLPTokensLevel3[user].add(numLPTokens);
        }

        emit Migrate(user, numLPTokens, sharesToTokens(numRewardShares));
    }

    function updateDepositSeconds(address user) public {

        (totalDepositSeconds, userDepositSeconds[user]) = getUpdatedDepositSeconds(user);
        lastAccountingUpdateTimestamp = now;
        userLastAccountingUpdateTimestamp[user] = now;
        emit UpdateDepositSeconds(user, totalDepositSeconds, userDepositSeconds[user]);
    }


    function getUpdatedDepositSeconds(address user) public view returns (uint256 _totalDepositSeconds, uint256 _userDepositSeconds) {

        uint256 delta = now.sub(lastAccountingUpdateTimestamp);
        _totalDepositSeconds = totalDepositSeconds.add(delta.mul(totalDepositedLevel1
                                                                       .add( totalDepositedLevel2.mul(2) )
                                                                       .add( totalDepositedLevel3.mul(3) ) ));

        delta = now.sub(userLastAccountingUpdateTimestamp[user]);
        _userDepositSeconds  = userDepositSeconds[user].add(delta.mul(userTotalLPTokensLevel1[user]
                                                                       .add( userTotalLPTokensLevel2[user].mul(2) )
                                                                       .add( userTotalLPTokensLevel3[user].mul(3) ) ));
        return (_totalDepositSeconds, _userDepositSeconds);
    }

    function owedTo(address user) public view returns (uint256) {

        require(user != address(0x0), "zero address");

        (uint256 totalDS, uint256 userDS) = getUpdatedDepositSeconds(user);
        if (totalDS == 0) {
            return 0;
        }
        return sharesToTokens(unlockedRewardsPoolShares().mul(userDS).div(totalDS));
    }

    function unlockedRewardsPoolTokens() public view returns (uint256) {

        return sharesToTokens(unlockedRewardsPoolShares());
    }

    function unlockedRewardsPoolShares() private view returns (uint256) {

        uint256 totalShares;
        for (uint256 i = 0; i < rewardsNumShares.length; i++) {
            totalShares = totalShares.add(unlockedRewardSharesInTranche(i));
        }
        return totalShares;
    }

    function unlockedRewardSharesInTranche(uint256 rewardsIdx) private view returns (uint256) {

        if (rewardsVestingStart[rewardsIdx] >= now || rewardsNumShares[rewardsIdx].sub(rewardsSharesWithdrawn[rewardsIdx]) == 0) {
            return 0;
        }
        uint256 secondsIntoVesting = now.sub(rewardsVestingStart[rewardsIdx]);
        if (secondsIntoVesting > rewardsVestingDuration[rewardsIdx]) {
            return rewardsNumShares[rewardsIdx].sub(rewardsSharesWithdrawn[rewardsIdx]);
        } else {
            return rewardsNumShares[rewardsIdx].mul( secondsIntoVesting )
                                               .div( rewardsVestingDuration[rewardsIdx] == 0 ? 1 : rewardsVestingDuration[rewardsIdx] )
                                               .sub( rewardsSharesWithdrawn[rewardsIdx] );
        }
    }

    function sharesToTokens(uint256 shares) private view returns (uint256) {

        return shares.mul(BASE.totalSupply()).div(BASE.totalShares());
    }

     function tokensToShares(uint256 tokens) private view returns (uint256) {

        return tokens.mul(BASE.totalShares().div(BASE.totalSupply()));
    }

    function depositInfo(address user, uint256 depositIdx) public view
        returns (
            uint256 _numLPTokens,
            uint256 _depositTimestamp,
            uint8   _multiplierLevel,
            uint256 _userDepositSeconds,
            uint256 _totalDepositSeconds,
            uint256 _owed
        )
    {

        require(user != address(0x0), "zero address");

        (_totalDepositSeconds, _userDepositSeconds) = getUpdatedDepositSeconds(user);
        return (
            userDepositsNumLPTokens[user][depositIdx],
            userDepositsDepositTimestamp[user][depositIdx],
            userDepositsMultiplierLevel[user][depositIdx],
            _userDepositSeconds,
            _totalDepositSeconds,
            owedTo(user)
        );
    }
}