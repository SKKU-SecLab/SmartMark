
pragma solidity 0.6.12;


interface IController {

    function vaults(address) external view returns (address);


    function rewards() external view returns (address);


    function devfund() external view returns (address);


    function treasury() external view returns (address);


    function balanceOf(address) external view returns (uint256);


    function withdraw(address, uint256) external;

    function withdraw(address, uint256, address) external;


    function earn(address, uint256) external;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

interface IERC2612 {
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function nonces(address owner) external view returns (uint256);
}

abstract contract ERC20Permit is ERC20, IERC2612 {
    mapping (address => uint256) public override nonces;

    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public immutable DOMAIN_SEPARATOR;
    constructor(string memory name_, string memory symbol_) internal ERC20(name_, symbol_) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(deadline >= block.timestamp, "ERC20Permit: expired deadline");

        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                amount,
                nonces[owner]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                hashStruct
            )
        );

        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == owner,
            "ERC20Permit: invalid signature"
        );

        _approve(owner, spender, amount);
    }

}

contract ReentrancyGuard {

    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    uint256 _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IChiToken {
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IMasterchef {
    function BONUS_MULTIPLIER() external view returns (uint256);

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external;

    function bonusEndBlock() external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function dev(address _devaddr) external;

    function devFundDivRate() external view returns (uint256);

    function devaddr() external view returns (address);

    function emergencyWithdraw(uint256 _pid) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function massUpdatePools() external;

    function owner() external view returns (address);

    function pendingMM(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function mm() external view returns (address);

    function mmPerBlock() external view returns (uint256);

    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accMMPerShare
        );

    function poolLength() external view returns (uint256);

    function renounceOwnership() external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function setBonusEndBlock(uint256 _bonusEndBlock) external;

    function setDevFundDivRate(uint256 _devFundDivRate) external;

    function setMMPerBlock(uint256 _mmPerBlock) external;

    function startBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function updatePool(uint256 _pid) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function withdraw(uint256 _pid, uint256 _amount) external;

    function notifyBuybackReward(uint256 _amount) external;
}

interface IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
    function maxFlashLoan(
        address token
    ) external view returns (uint256);

    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);

    
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract MMVault is ReentrancyGuard, ERC20Permit, IERC3156FlashLender  {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public immutable token;

    IChiToken public constant chi = IChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    uint256 public min = 9900;
    uint256 public constant max = 10000;

    uint256 public loanFee = 1;
    uint256 public constant loanFeeMax = 10000;
    bool public loanEnabled = false;

    address public governance;
    address public timelock;
    address public controller;

    mapping(address => bool) public keepers;
    mapping(address => bool) public reentrancyWhitelist;

    uint256 public constant DAY_SECONDS = 86400;
    uint256 public constant lockWindowBuffer = DAY_SECONDS/4;

    uint256 public lockStartTime;
    uint256 public lockWindow;
    uint256 public withdrawWindow;
    uint256 public earnedTimestamp;
    bool public lockEnabled = false;
    bool public earnOnceEnabled = false;

    event FlashLoan(address _initiator, address _token, address _receiver, uint256 _amount, uint256 _loanFee);

    modifier discountCHI() {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;

        if(chi.balanceOf(msg.sender) > 0) {
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
        }
    }

    modifier onlyKeepers {
        require(
            keepers[msg.sender] ||
            msg.sender == governance,
            "!keepers"
        );
        _;
    }

    modifier onlyGovernance(){
        require(msg.sender == governance, "!governance");
        _;
    }

    modifier canEarn {
        if(lockEnabled){
            require(
                block.timestamp > lockStartTime,
                "!earnTime"
            );
            if(earnOnceEnabled){
                require(
                    block.timestamp.sub(earnedTimestamp) > lockWindow,
                     "!earnTwice");
                if(earnedTimestamp != 0){
                    lockStartTime = getLockCycleEndTime();
                }
                earnedTimestamp = block.timestamp;
            }
        }
        _;
    }

    modifier canWithdraw(uint256 _shares) {
        if(lockEnabled){
            if(!withdrawableWithoutLock(_shares)){
                uint256 withdrawStartTimestamp = lockStartTime.add(lockWindow);
                require(
                    block.timestamp > withdrawStartTimestamp &&
                    block.timestamp < withdrawStartTimestamp.add(withdrawWindow),
                    "!withdrawTime"
                );
            }
        }
        _;
    }
	
    modifier nonReentrantWithWhitelist() {
        if (!reentrancyWhitelist[msg.sender]){
            require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
            _status = _ENTERED;
        }

        _;	
        
        if (!reentrancyWhitelist[msg.sender]){
            _status = _NOT_ENTERED;	
        }
    }

    constructor(address _token, address _governance, address _timelock, address _controller)
        public
        ERC20Permit(
            string(abi.encodePacked("mushrooming ", ERC20(_token).name())),
            string(abi.encodePacked("m", ERC20(_token).symbol()))
        )
    {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
        governance = _governance;
        timelock = _timelock;
        controller = _controller;

        lockWindow = (14 * DAY_SECONDS) + lockWindowBuffer;
        withdrawWindow = DAY_SECONDS/2;
        lockStartTime = block.timestamp.add(withdrawWindow);
    }

    function getName() public pure returns(string memory){
        return "mmVaultV2.1";
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this)).add(IController(controller).balanceOf(address(token)));
    }

    function setMin(uint256 _min) external onlyGovernance{
        min = _min;
    }

    function setGovernance(address _governance) public onlyGovernance{
        governance = _governance;
    }

    function setTimelock(address _timelock) public {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) public {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function setLoanFee(uint256 _loanFee) public onlyGovernance{
        loanFee = _loanFee;
    }

    function setLoanEnabled(bool _loanEnabled) public onlyGovernance{
        loanEnabled = _loanEnabled;
    }

    function addKeeper(address _keeper) public onlyGovernance{
        keepers[_keeper] = true;
    }

    function removeKeeper(address _keeper) public onlyGovernance{
        keepers[_keeper] = false;
    }

    function addReentrancyWhitelist(address _whitelist) public onlyGovernance{
        reentrancyWhitelist[_whitelist] = true;
    }

    function removeReentrancyWhitelist(address _whitelist) public onlyGovernance{
        reentrancyWhitelist[_whitelist] = false;
    }

    function setLockWindow(uint256 _lockWindow) public onlyGovernance {
        lockWindow = _lockWindow.add(lockWindowBuffer);
    }

    function setWithdrawWindow(uint256 _withdrawWindow) public onlyGovernance {
        withdrawWindow = _withdrawWindow;
    }

    function setLockEnabled(bool _enabled) public onlyGovernance {
        lockEnabled = _enabled;
    }

    function setEarnOnceEnabled(bool _earnOnce) public onlyGovernance {
        earnOnceEnabled = _earnOnce;
    }

    function resetLockStartTime(uint256 _lockStartTime) public onlyGovernance{
        require(lockEnabled, "!lockEnabled");

        uint256 withdrawEndTime = getLockCycleEndTime();
        require(block.timestamp >= withdrawEndTime, "Last lock cycle not end");
        require(_lockStartTime > block.timestamp, "!_lockStartTime");
        lockStartTime = _lockStartTime;
    }

    function getLockCycleEndTime() public view returns (uint256){
        return lockStartTime.add(lockWindow).add(withdrawWindow);
    }

    function withdrawableWithoutLock(uint256 _shares) public view returns(bool){
        uint256 _withdrawAmount = (balance().mul(_shares)).div(totalSupply());
        return _withdrawAmount <= token.balanceOf(address(this));
    }

    function available() public view returns (uint256) {
        return token.balanceOf(address(this)).mul(min).div(max);
    }

    function earn() public nonReentrant onlyKeepers canEarn {
        uint256 _bal = available();
        token.safeTransfer(controller, _bal);
        IController(controller).earn(address(token), _bal);
    }

    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint256 _approveAmount, uint256 _amount, uint256 _deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(_approveAmount >= _amount, "!_approveAmount");
        IERC2612(address(token)).permit(msg.sender, address(this), _approveAmount, _deadline, v, r, s);
        deposit(_amount);
    }

    function deposit(uint256 _amount) public nonReentrant {
        uint256 _pool = balance();
        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);
    }

    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }

    function harvest(address reserve, uint256 amount)  external nonReentrant {
        require(msg.sender == controller, "!controller");
        require(reserve != address(token), "token");
        IERC20(reserve).safeTransfer(controller, amount);
    }

    function withdraw(uint256 _shares) public nonReentrant canWithdraw(_shares) {
        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint256 b = token.balanceOf(address(this));
        if (b < r) {
            uint256 _withdraw = r.sub(b);
            IController(controller).withdraw(address(token), _withdraw);
            uint256 _after = token.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }

        token.safeTransfer(msg.sender, r);
    }

    function getRatio() public view returns (uint256) {
        return balance().mul(1e18).div(totalSupply());
    }

    function maxFlashLoan(
        address _token
    ) external override view returns (uint256){
        require(address(_token) == address(token), "!_token");
        return token.balanceOf(address(this));
    }

    function flashFee(
        address _token,
        uint256 amount
    ) external override view returns (uint256){
        require(address(_token) == address(token), "!_token");
        return loanFee.mul(amount).div(loanFeeMax);
    }

    function flashLoan(IERC3156FlashBorrower _receiver, address _token, uint256 _amount, bytes memory _data) public override nonReentrantWithWhitelist discountCHI returns (bool){
        require(loanEnabled == true, "!loanEnabled");
        require(_amount > 0, "amount too small!");
        require(address(_token) == address(token), "!_token");
        uint256 beforeBalance = token.balanceOf(address(this));
        require(beforeBalance > _amount, "balance not enough!");
        
        uint256 _totalBalBefore = balance();

        uint256 _fee = _amount.mul(loanFee).div(loanFeeMax);

        require(_fee > 0, "fee too small");

        token.safeTransfer(address(_receiver), _amount);

        IERC3156FlashBorrower(_receiver).onFlashLoan(address(msg.sender), address(token), _amount, _fee, _data);

        uint256 _totalDue = _amount.add(_fee);
        token.safeTransferFrom(address(_receiver), address(this), _totalDue);
		
        uint256 _totalBalAfter = balance();
        require(_totalBalAfter == _totalBalBefore.add(_fee), "payback amount incorrect!");

        emit FlashLoan(address(msg.sender), address(token), address(_receiver), _amount, _fee);
        return true;
    }

}