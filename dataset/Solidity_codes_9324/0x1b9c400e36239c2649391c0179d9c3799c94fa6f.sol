
pragma solidity >0.4.13 >=0.4.23 >=0.5.12 >=0.5.0 <0.6.0 >=0.5.10 <0.6.0 >=0.5.12 <0.6.0;


interface IERC20 {

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



interface IAdapter {

    function calc(
        address gem,
        uint256 acc,
        uint256 factor
    ) external view returns (uint256);

}

interface IGemForRewardChecker {

    function check(address gem) external view returns (bool);

}





contract LibNote {

    event LogNote(
        bytes4 indexed sig,
        address indexed usr,
        bytes32 indexed arg1,
        bytes32 indexed arg2,
        bytes data
    ) anonymous;

    modifier note {

        _;
        assembly {
            let mark := msize() // end of memory ensures zero
            mstore(0x40, add(mark, 288)) // update free memory pointer
            mstore(mark, 0x20) // bytes type data offset
            mstore(add(mark, 0x20), 224) // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224) // bytes payload
            log4(
                mark,
                288, // calldata
                shl(224, shr(224, calldataload(0))), // msg.sig
                caller(), // msg.sender
                calldataload(4), // arg1
                calldataload(36) // arg2
            )
        }
    }
}

contract Auth is LibNote {

    mapping(address => uint256) public wards;
    address public deployer;

    function rely(address usr) external note auth {

        wards[usr] = 1;
    }

    function deny(address usr) external note auth {

        wards[usr] = 0;
    }

    modifier auth {

        require(wards[msg.sender] == 1 || deployer == msg.sender, "Auth/not-authorized");
        _;
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

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
}





library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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








library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}


contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    function isConstructor() private view returns (bool) {

        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract LPTokenWrapper is Initializable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PairDesc {
        address gem;
        address adapter;
        address staker;
        uint256 factor;
        bytes32 name;
    }

    mapping(address => PairDesc) public pairDescs;

    address[] private registeredGems;

    uint256 public decimals = 18;

    uint256 public prec = 1e18;

    mapping(address => uint256) private _totalSupply;

    mapping(address => mapping(address => uint256)) private _amounts;
    mapping(address => mapping(address => uint256)) private _balances;

    IGemForRewardChecker public gemForRewardChecker;

    function checkGem(address gem) internal view returns (bool) {

        return gemForRewardChecker.check(gem);
    }

    function registerGem(address gem) internal {

        for (uint256 i = 0; i < registeredGems.length; i++) {
            if (registeredGems[i] == gem) {
                return;
            }
        }
        registeredGems.push(gem);
    }

    function totalSupply() public view returns (uint256) {

        uint256 res = 0;
        for (uint256 i = 0; i < registeredGems.length; i++) {
            res = res.add(_totalSupply[registeredGems[i]]);
        }
        return res.div(prec);
    }

    function balanceOf(address account) public view returns (uint256) {

        uint256 res = 0;
        for (uint256 i = 0; i < registeredGems.length; i++) {
            res = res.add(_balances[registeredGems[i]][account]);
        }
        return res.div(prec);
    }

    function calcCheckValue(uint256 amount, address gem) public view returns (uint256) {

        require(amount > 0);
        PairDesc storage desc = pairDescs[gem];
        require(desc.adapter != address(0x0));
        assert(desc.gem == gem);
        uint256 r = IAdapter(desc.adapter).calc(gem, amount, desc.factor);
        require(r > 0);
        return r;
    }

    function stakeLp(
        uint256 amount,
        address gem,
        address usr
    ) internal {

        uint256 value = calcCheckValue(amount, gem).mul(prec);

        _balances[gem][usr] = _balances[gem][usr].add(value);
        _amounts[gem][usr] = _amounts[gem][usr].add(amount);
        _totalSupply[gem] = _totalSupply[gem].add(value);
    }

    function withdrawLp(
        uint256 amount,
        address gem,
        address usr
    ) internal {

        uint256 value = amount.mul(_balances[gem][usr]).div(_amounts[gem][usr]);

        _balances[gem][usr] = _balances[gem][usr].sub(value);
        _amounts[gem][usr] = _amounts[gem][usr].sub(amount);
        _totalSupply[gem] = _totalSupply[gem].sub(value);
    }
}






contract StakingRewards is LPTokenWrapper, Auth, ReentrancyGuard {


    address public gov;
    uint256 public duration;

    uint256 public initreward;
    uint256 public starttime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalRewards = 0;
    bool public fairDistribution = false;
    uint256 public fairDistributionMaxValue = 0;
    uint256 public fairDistributionTime = 0;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event StopRewarding();
    event Staked(address indexed user, address indexed gem, uint256 amount);
    event Withdrawn(address indexed user, address indexed gem, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    constructor() public {
        deployer = msg.sender;
    }

    function initialize(
        address _gov,
        uint256 _duration,
        uint256 _initreward,
        uint256 _starttime
    ) public initializer {

        require(deployer == msg.sender);

        require(_starttime >= block.timestamp);

        gov = _gov;

        duration = _duration;
        starttime = _starttime;
        initRewardAmount(_initreward);
    }

    function setupGemForRewardChecker(address a) public {

        require(deployer == msg.sender);
        gemForRewardChecker = IGemForRewardChecker(a);
    }

    function setupFairDistribution(
        uint256 _fairDistributionMaxValue,
        uint256 _fairDistributionTime
    ) public {

        require(deployer == msg.sender);
        require(fairDistribution == false);

        fairDistribution = true;
        fairDistributionMaxValue = _fairDistributionMaxValue * (10**decimals);
        fairDistributionTime = _fairDistributionTime;
    }

    function registerPairDesc(
        address gem,
        address adapter,
        uint256 factor,
        address staker
    ) public auth nonReentrant {

        require(gem != address(0x0), "gem is null");
        require(adapter != address(0x0), "adapter is null");

        require(checkGem(gem), "bad gem");

        registerGem(gem);

        pairDescs[gem] = PairDesc({
            gem: gem,
            adapter: adapter,
            factor: factor,
            staker: staker,
            name: "dummy"
        });
    }

    function resetDeployer() public {

        require(deployer == msg.sender);
        deployer = address(0);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18 * (10**decimals))
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18 * (10**decimals))
                .add(rewards[account]);
    }

    function testFairDistribution(
        address usr,
        address gem,
        uint256 amount
    ) public view returns (bool) {

        return testFairDistributionByValue(usr, calcCheckValue(amount, gem));
    }

    function testFairDistributionByValue(address usr, uint256 value) public view returns (bool) {

        if (fairDistribution) {
            return
                balanceOf(usr).add(value) <= fairDistributionMaxValue ||
                block.timestamp >= starttime.add(fairDistributionTime);
        }
        return true;
    }

    function checkFairDistribution(address usr) public view checkStart {

        if (fairDistribution) {
            require(
                balanceOf(usr) <= fairDistributionMaxValue ||
                    block.timestamp >= starttime.add(fairDistributionTime),
                "Fair-distribution-limit"
            );
        }
    }

    function stake(
        uint256 amount,
        address gem,
        address usr
    ) public nonReentrant updateReward(usr) checkFinish checkStart {

        require(amount > 0, "Cannot stake 0");
        require(pairDescs[gem].staker == msg.sender, "Stake from join only allowed");

        stakeLp(amount, gem, usr);
        emit Staked(usr, gem, amount);
    }

    function withdraw(
        uint256 amount,
        address gem,
        address usr
    ) public nonReentrant updateReward(usr) checkFinish checkStart {

        require(amount > 0, "Cannot withdraw 0");
        require(pairDescs[gem].staker == msg.sender, "Stake from join only allowed");

        withdrawLp(amount, gem, usr);
        emit Withdrawn(usr, gem, amount);
    }

    function getReward()
        public
        nonReentrant
        updateReward(msg.sender)
        checkFinish
        checkStart
        returns (uint256)
    {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IERC20(gov).safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
            totalRewards = totalRewards.add(reward);
            return reward;
        }
        return 0;
    }

    modifier checkFinish() {

        if (block.timestamp > periodFinish) {
            initreward = 0;
            rewardRate = 0;
            periodFinish = uint256(-1);
            emit StopRewarding();
        }
        _;
    }

    modifier checkStart() {

        require(allowToStart(), "not start");
        _;
    }

    function allowToStart() public view returns (bool) {

        return block.timestamp > starttime;
    }

    function initRewardAmount(uint256 reward) internal updateReward(address(0)) {

        require(starttime >= block.timestamp);
        rewardRate = reward.div(duration);
        initreward = reward;
        lastUpdateTime = starttime;
        periodFinish = starttime.add(duration);
        emit RewardAdded(reward);
    }
}

interface VatLike {

    function slip(
        bytes32,
        address,
        int256
    ) external;


    function move(
        address,
        address,
        uint256
    ) external;

}

contract GemJoinWithReward is LibNote {

    mapping(address => uint256) public wards;

    function rely(address usr) external note auth {

        wards[usr] = 1;
    }

    function deny(address usr) external note auth {

        wards[usr] = 0;
    }

    modifier auth {

        require(wards[msg.sender] == 1, "GemJoinWithReward/not-authorized");
        _;
    }

    event stakeError(uint256 amount, address gem, address usr);
    event withdrawError(uint256 amount, address gem, address usr);

    StakingRewards public rewarder;
    VatLike public vat; // CDP Engine
    bytes32 public ilk; // Collateral Type
    IERC20 public gem;
    uint256 public dec;
    uint256 public live; // Active Flag

    constructor(
        address vat_,
        bytes32 ilk_,
        address gem_,
        address rewarder_
    ) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = IERC20(gem_);
        rewarder = StakingRewards(rewarder_);
        dec = gem.decimals();
        require(dec >= 18, "GemJoinWithReward/decimals-18-or-higher");
    }

    function cage() external note auth {

        live = 0;
    }

    function join(address urn, uint256 wad) external note {

        require(live == 1, "GemJoinWithReward/not-live");
        require(int256(wad) >= 0, "GemJoinWithReward/overflow");
        vat.slip(ilk, urn, int256(wad));

        (bool ret, ) =
            address(rewarder).call(
                abi.encodeWithSelector(rewarder.stake.selector, wad, address(gem), msg.sender)
            );
        if (!ret) {
            emit stakeError(wad, address(gem), msg.sender);
        }

        rewarder.checkFairDistribution(msg.sender);

        require(
            gem.transferFrom(msg.sender, address(this), wad),
            "GemJoinWithReward/failed-transfer"
        );
    }

    function exit(address usr, uint256 wad) external note {

        require(wad <= 2**255, "GemJoinWithReward/overflow");
        vat.slip(ilk, msg.sender, -int256(wad));

        require(rewarder.allowToStart(), "join-not-start");

        (bool ret, ) =
            address(rewarder).call(
                abi.encodeWithSelector(rewarder.withdraw.selector, wad, address(gem), msg.sender)
            );
        if (!ret) {
            emit withdrawError(wad, address(gem), msg.sender);
        }

        require(gem.transfer(usr, wad), "GemJoinWithReward/failed-transfer");
    }
}

contract RewardProxyActions {

    function claimReward(address rewarder) public {

        uint256 reward = StakingRewards(rewarder).getReward();
        IERC20(StakingRewards(rewarder).gov()).transfer(msg.sender, reward);
    }
}