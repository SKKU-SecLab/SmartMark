


pragma solidity ^0.5.12;

interface IGoddessFragments {

    function summon(uint256 goddessID) external;


    function fusion(uint256 goddessID) external;


    function collectFragments(address user, uint256 amount) external;

}


pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;



contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}



pragma solidity ^0.5.12;

interface IReferral {

    function setReferrer(address farmer, address referrer) external;


    function getReferrer(address farmer) external view returns (address);

}


pragma solidity ^0.5.12;

interface IGovernance {

    function getStableToken() external view returns (address);

}



pragma solidity ^0.5.12;

interface IUniswapRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function WETH() external pure returns (address);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}



pragma solidity ^0.5.12;

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address => bool) internal operators;
    address[] internal operatorsGroup;
    uint256 internal constant MAX_GROUP_SIZE = 50;

    constructor(address _admin) public {
        require(_admin != address(0), "Admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyOperator() {

        require(operators[msg.sender], "Only operator");
        _;
    }

    function getOperators() external view returns (address[] memory) {

        return operatorsGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    function transferAdmin(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "New admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "Admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed(address newAdmin, address previousAdmin);

    function claimAdmin() public {

        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {

        require(!operators[newOperator], "Operator exists"); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE, "Max operators");

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator(address operator) public onlyAdmin {

        require(operators[operator], "Not operator");
        operators[operator] = false;

        for (uint256 i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.pop();
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }
}



pragma solidity ^0.5.12;



contract Withdrawable is PermissionGroups {

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    mapping(address => bool) internal blacklist;

    event TokenWithdraw(address token, uint256 amount, address sendTo);

    event EtherWithdraw(uint256 amount, address sendTo);

    constructor(address _admin) public PermissionGroups(_admin) {}

    function withdrawToken(
        address token,
        uint256 amount,
        address sendTo
    ) external onlyAdmin {

        require(!blacklist[address(token)], "forbid to withdraw that token");
        _safeTransfer(token, sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    function withdrawEther(uint256 amount, address payable sendTo) external onlyAdmin {

        (bool success, ) = sendTo.call.value(amount)("");
        require(success);
        emit EtherWithdraw(amount, sendTo);
    }

    function setBlackList(address token) internal {

        blacklist[token] = true;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.5.12;




contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakeToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(IERC20 _stakeToken) public {
        stakeToken = _stakeToken;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) internal {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
    }

    function withdraw(uint256 amount) public {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
    }
}



pragma solidity ^0.5.12;







contract SeedPool is LPTokenWrapper, Withdrawable {

    IERC20 public goddessToken;
    uint256 public tokenCapAmount;
    uint256 public starttime;
    uint256 public duration;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    IReferral public referral;

    uint256 internal totalStakingBalance;
    mapping(address => uint256) internal stakeBalance;
    uint256 internal constant PRECISION = 1e18;
    uint256 public constant REFERRAL_COMMISSION_PERCENT = 1;
    uint256 private constant ONE_WEEK = 604800;

    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);

    modifier checkStart() {

        require(block.timestamp >= starttime, "not start");
        _;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    constructor(
        uint256 _tokenCapAmount,
        IERC20 _stakeToken,
        IERC20 _goddessToken,
        uint256 _starttime,
        uint256 _duration
    ) public LPTokenWrapper(_stakeToken) Withdrawable(msg.sender) {
        tokenCapAmount = _tokenCapAmount;
        goddessToken = _goddessToken;
        starttime = _starttime;
        duration = _duration;
        Withdrawable.setBlackList(address(_goddessToken));
        Withdrawable.setBlackList(address(_stakeToken));
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalStakingBalance == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(
                    totalStakingBalance
                )
            );
    }

    function earned(address account) public view returns (uint256) {

        return totalEarned(account).mul(100 - REFERRAL_COMMISSION_PERCENT).div(100);
    }

    function totalEarned(address account) internal view returns (uint256) {

        return
            stakeBalance[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 amount, address referrer) public updateReward(msg.sender) checkStart {

        checkCap(amount, msg.sender);
        _stake(amount, referrer);
    }

    function _stake(uint256 amount, address referrer) internal {

        require(amount > 0, "Cannot stake 0");
        super.stake(amount);

        updateStakeBalanceAndSupply(msg.sender);

        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        if (address(referral) != address(0) && referrer != address(0)) {
            referral.setReferrer(msg.sender, referrer);
        }
    }

    function checkCap(uint256 amount, address user) private view {

        require(
            balanceOf(user).add(amount) <= tokenCapAmount ||
                block.timestamp >= starttime.add(ONE_WEEK),
            "token cap exceeded"
        );
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart {

        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);

        updateStakeBalanceAndSupply(msg.sender);

        stakeToken.safeTransfer(msg.sender, amount);
        getReward();
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {

        uint256 reward = totalEarned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 actualRewards = reward.mul(100 - REFERRAL_COMMISSION_PERCENT).div(100); // 99%
            uint256 commission = reward.sub(actualRewards); // 1%
            goddessToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
            address referrer = address(0);
            if (address(referral) != address(0)) {
                referrer = referral.getReferrer(msg.sender);
            }
            if (referrer != address(0)) {
                goddessToken.safeTransfer(referrer, commission);
            } else {
                ERC20Burnable burnableGoddessToken = ERC20Burnable(address(goddessToken));
                burnableGoddessToken.burn(commission);
            }
        }
    }

    function notifyRewardAmount(uint256 reward) external onlyAdmin updateReward(address(0)) {

        rewardRate = reward.div(duration);
        lastUpdateTime = starttime;
        periodFinish = starttime.add(duration);
        emit RewardAdded(reward);
    }

    function updateStakeBalanceAndSupply(address user) private {

        totalStakingBalance = totalStakingBalance.sub(stakeBalance[user]);
        uint256 newStakeBalance = balanceOf(user);
        stakeBalance[user] = newStakeBalance;
        totalStakingBalance = totalStakingBalance.add(newStakeBalance);
    }

    function setReferral(IReferral _referral) external onlyAdmin {

        referral = _referral;
    }
}



pragma solidity ^0.5.12;










contract RewardsPool is SeedPool {

    address public governance;
    IUniswapRouter public uniswapRouter;
    address public stablecoin;

    uint256 public lastBlessingTime; // timestamp of lastBlessingTime
    mapping(address => uint256) public numBlessing; // each blessing = 5% increase in stake amt
    mapping(address => uint256) public nextBlessingTime; // timestamp for which user is eligible to purchase another blessing
    uint256 public globalBlessPrice = 10**18;
    uint256 public blessThreshold = 10;
    uint256 public blessScaleFactor = 20;
    uint256 public scaleFactor = 320;

    constructor(
        uint256 _tokenCapAmount,
        IERC20 _stakeToken,
        IERC20 _goddessToken,
        IUniswapRouter _uniswapRouter,
        uint256 _starttime,
        uint256 _duration
    ) public SeedPool(_tokenCapAmount, _stakeToken, _goddessToken, _starttime, _duration) {
        uniswapRouter = _uniswapRouter;
        goddessToken.safeApprove(address(_uniswapRouter), 2**256 - 1);
    }

    function setScaleFactorsAndThreshold(
        uint256 _blessThreshold,
        uint256 _blessScaleFactor,
        uint256 _scaleFactor
    ) external onlyAdmin {

        blessThreshold = _blessThreshold;
        blessScaleFactor = _blessScaleFactor;
        scaleFactor = _scaleFactor;
    }

    function bless(uint256 _maxGdsUse) external updateReward(msg.sender) checkStart {

        require(block.timestamp > nextBlessingTime[msg.sender], "early bless request");
        require(numBlessing[msg.sender] < blessThreshold, "bless reach limit");
        (uint256 blessPrice, uint256 newBlessingBalance) = getBlessingPrice(msg.sender);
        require(_maxGdsUse > blessPrice, "price over maxGDS");
        applyBlessing(msg.sender, newBlessingBalance);

        goddessToken.safeTransferFrom(msg.sender, address(this), blessPrice);

        ERC20Burnable burnableGoddessToken = ERC20Burnable(address(goddessToken));

        uint256 burnAmount = blessPrice.div(2);
        burnableGoddessToken.burn(burnAmount);
        blessPrice = blessPrice.sub(burnAmount);

        address[] memory routeDetails = new address[](3);
        routeDetails[0] = address(goddessToken);
        routeDetails[1] = uniswapRouter.WETH();
        routeDetails[2] = address(stablecoin);
        uniswapRouter.swapExactTokensForTokens(
            blessPrice,
            0,
            routeDetails,
            governance,
            block.timestamp + 100
        );
    }

    function setGovernance(address _governance) external onlyAdmin {

        governance = _governance;
        stablecoin = IGovernance(governance).getStableToken();
    }

    function setUniswapRouter(IUniswapRouter _uniswapRouter) external onlyAdmin {

        uniswapRouter = _uniswapRouter;
        goddessToken.safeApprove(address(_uniswapRouter), 2**256 - 1);
    }

    function stake(uint256 amount, address referrer) public updateReward(msg.sender) checkStart {

        _stake(amount, referrer);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart {

        require(amount > 0, "Cannot withdraw 0");
        LPTokenWrapper.withdraw(amount);

        numBlessing[msg.sender] = 0;
        updateStakeBalanceAndSupply(msg.sender, 0);

        stakeToken.safeTransfer(msg.sender, amount);
        getReward();
    }

    function getBlessingPrice(address user)
        public
        view
        returns (uint256 blessingPrice, uint256 newBlessingBalance)
    {

        if (totalStakingBalance == 0) return (0, 0);

        uint256 blessedTime = numBlessing[user];
        blessingPrice = globalBlessPrice.mul(blessedTime.mul(5).add(100)).div(100);

        blessedTime = blessedTime.add(1);

        if (blessedTime >= blessThreshold) {
            return (0, balanceOf(user));
        }

        newBlessingBalance = balanceOf(user).mul(blessedTime.mul(5).add(100)).div(100);
        uint256 blessBalanceIncrease = newBlessingBalance.sub(stakeBalance[user]);
        blessingPrice = blessingPrice.mul(blessBalanceIncrease).mul(scaleFactor).div(
            totalStakingBalance
        );
    }

    function applyBlessing(address user, uint256 newBlessingBalance) internal {

        numBlessing[user] = numBlessing[user].add(1);

        updateStakeBalanceAndSupply(user, newBlessingBalance);

        nextBlessingTime[user] = block.timestamp.add(3600);

        globalBlessPrice = globalBlessPrice.mul(101).div(100);

        lastBlessingTime = block.timestamp;
    }

    function updateGoddessBalanceAndSupply(address user) internal {

        totalStakingBalance = totalStakingBalance.sub(stakeBalance[user]);
        uint256 newGoddessBalance = balanceOf(user).mul(numBlessing[user].mul(5).add(100)).div(
            100
        );
        stakeBalance[user] = newGoddessBalance;
        totalStakingBalance = totalStakingBalance.add(newGoddessBalance);
    }

    function updateStakeBalanceAndSupply(address user, uint256 newBlessingBalance) private {

        totalStakingBalance = totalStakingBalance.sub(stakeBalance[user]);

        if (newBlessingBalance == 0) {
            newBlessingBalance = balanceOf(user);
        }

        stakeBalance[user] = newBlessingBalance;

        totalStakingBalance = totalStakingBalance.add(newBlessingBalance);
    }
}



pragma solidity ^0.5.12;



contract FragmentsPool is RewardsPool {

    IGoddessFragments public goddessFragments;
    uint256 public fragmentsPerWeek; // per max cap
    uint256 public fragmentsPerTokenStored;
    mapping(address => uint256) public fragments;
    mapping(address => uint256) public userFragmentsPerTokenPaid;
    uint256 public fragmentsLastUpdateTime;

    constructor(
        uint256 _tokenCapAmount,
        IERC20 _stakeToken,
        IERC20 _goddessToken,
        IUniswapRouter _uniswapRouter,
        uint256 _starttime,
        uint256 _duration,
        IGoddessFragments _goddessFragments
    )
        public
        RewardsPool(
            _tokenCapAmount,
            _stakeToken,
            _goddessToken,
            _uniswapRouter,
            _starttime,
            _duration
        )
    {
        goddessFragments = _goddessFragments;
    }

    modifier updateFragments(address account) {

        fragmentsPerTokenStored = fragmentsPerToken();
        fragmentsLastUpdateTime = block.timestamp;
        if (account != address(0)) {
            fragments[account] = fragmentsEarned(account);
            userFragmentsPerTokenPaid[account] = fragmentsPerTokenStored;
        }
        _;
    }

    function fragmentsPerToken() public view returns (uint256) {

        if (totalStakingBalance == 0) {
            return fragmentsPerTokenStored;
        }
        return
            fragmentsPerTokenStored.add(
                block
                    .timestamp
                    .sub(fragmentsLastUpdateTime)
                    .mul(fragmentsPerWeek)
                    .mul(1e18)
                    .div(604800)
                    .div(totalStakingBalance)
            );
    }

    function fragmentsEarned(address account) public view returns (uint256) {

        return
            stakeBalance[account]
                .mul(fragmentsPerToken().sub(userFragmentsPerTokenPaid[account]))
                .div(1e18)
                .add(fragments[account]);
    }

    function stake(uint256 amount, address referrer) public updateFragments(msg.sender) {

        super.stake(amount, referrer);
    }

    function withdraw(uint256 amount) public updateFragments(msg.sender) {

        super.withdraw(amount);
    }

    function getReward() public updateFragments(msg.sender) {

        super.getReward();
        uint256 reward = fragmentsEarned(msg.sender);
        if (reward > 0) {
            goddessFragments.collectFragments(msg.sender, reward);
            fragments[msg.sender] = 0;
        }
    }

    function setFragmentsPerWeek(uint256 _fragmentsPerWeek)
        public
        updateFragments(address(0))
        onlyAdmin
    {

        fragmentsPerWeek = _fragmentsPerWeek;
    }

    function setGoddessFragments(address _goddessFragments) public onlyAdmin {

        goddessFragments = IGoddessFragments(_goddessFragments);
    }
}