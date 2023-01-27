pragma solidity 0.8.9;



interface ICurveGauge {

    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;

    function claim_rewards() external;

    function reward_tokens(uint256) external view returns(address);//v2

    function rewarded_token() external view returns(address);//v1

    function lp_token() external view returns(address);

}

interface ICurveVoteEscrow {

    function create_lock(uint256, uint256) external;

    function increase_amount(uint256) external;

    function increase_unlock_time(uint256) external;

    function withdraw() external;

    function smart_wallet_checker() external view returns (address);

}

interface IWalletChecker {

    function check(address) external view returns (bool);

}

interface IVoting {

    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided

    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory);

    function vote_for_gauge_weights(address,uint256) external;

}

interface IMinter {

    function mint(address) external;

}

interface IRegistry {

    function get_registry() external view returns(address);

    function get_address(uint256 _id) external view returns(address);

    function gauge_controller() external view returns(address);

    function get_lp_token(address) external view returns(address);

    function get_gauges(address) external view returns(address[10] memory,uint128[10] memory);

}

interface IStaker {

    function deposit(address, address) external;

    function withdraw(address) external;

    function withdraw(address, address, uint256) external;

    function withdrawAll(address, address) external;

    function createLock(uint256, uint256) external;

    function increaseAmount(uint256) external;

    function increaseTime(uint256) external;

    function release() external;

    function claimCrv(address) external returns (uint256);

    function claimRewards(address) external;

    function claimFees(address,address) external;

    function setStashAccess(address, bool) external;

    function vote(uint256,address,bool) external;

    function voteGaugeWeight(address,uint256) external;

    function balanceOfPool(address) external view returns (uint256);

    function operator() external view returns (address);

    function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);

}

interface IRewards {

    function stake(address, uint256) external;

    function stakeFor(address, uint256) external;

    function withdraw(address, uint256) external;

    function exit(address) external;

    function getReward(address) external;

    function queueNewRewards(uint256) external;

    function notifyRewardAmount(uint256) external;

    function addExtraReward(address) external;

    function stakingToken() external view returns (address);

    function rewardToken() external view returns(address);

    function earned(address account) external view returns (uint256);

}

interface IStash {

    function stashRewards() external returns (bool);

    function processStash() external returns (bool);

    function claimRewards() external returns (bool);

    function initialize(uint256 _pid, address _operator, address _staker, address _gauge, address _rewardFactory) external;

}

interface IFeeDistro {

    function claim() external;

    function token() external view returns(address);

}

interface ITokenMinter{

    function mint(address,uint256) external;

    function burn(address,uint256) external;

}

interface IDeposit {

    function isShutdown() external view returns(bool);

    function balanceOf(address _account) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function poolInfo(uint256) external view returns(address,address,address,address,address, bool);

    function rewardClaimed(uint256,address,uint256) external;

    function withdrawTo(uint256,uint256,address) external;

    function claimRewards(uint256,address) external returns(bool);

    function rewardArbitrator() external returns(address);

    function setGaugeRedirect(uint256 _pid) external returns(bool);

    function owner() external returns(address);

}

interface ICrvDeposit {

    function deposit(uint256, bool) external;

    function lockIncentive() external view returns(uint256);

}

interface IRewardFactory {

    function setAccess(address,bool) external;

    function CreateCrvRewards(uint256,address) external returns(address);

    function CreateTokenRewards(address,address,address) external returns(address);

    function CreateFeePool(address,address) external returns(address);

    function activeRewardCount(address) external view returns(uint256);

    function addActiveReward(address,uint256) external returns(bool);

    function removeActiveReward(address,uint256) external returns(bool);

}

interface IStashFactory {

    function CreateStash(uint256,address,address,uint256) external returns(address);

}

interface ITokenFactory {

    function CreateDepositToken(address) external returns(address);

}

interface IPools {

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);

    function setLiquidityLimit(uint256 _pid, uint256 _limit) external;

    function shutdownPool(uint256 _pid) external returns(bool);

    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);

    function poolLength() external view returns (uint256);

    function gaugeMap(address) external view returns(bool);

    function setPoolManager(address _poolM) external;

}

interface IVestedEscrow {

    function fund(address[] calldata _recipient, uint256[] calldata _amount) external returns(bool);

}

interface IProxyFactory {

    function clone(address _target) external returns(address);

}

interface ISmartWalletWhitelist {

    function approveWallet(address _wallet) external;

}

interface IGaugeController {

    function get_gauge_weight(address _gauge) external view returns(uint256);

    function gauge_relative_weight(address _gauge) external view returns(uint256);

    function vote_user_slopes(address,address) external view returns(uint256,uint256,uint256);//slope,power,end

}

interface IVault {

    function collaterals(address asset, address owner) external view returns(uint256);

}

interface IRewardHook {

    function onRewardClaim() external;

}

interface IBurner {

    function withdraw_admin_fees(address) external;

    function burn(address) external;

    function execute() external returns(bool);

}

interface IPreDepositChecker {

    function canDeposit(address, uint, uint) external view returns(bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.9;



contract Booster {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;

    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant registry = address(0x0000000022D53366457F9d5E68Ec105046FC4383);
    uint256 public constant distributionAddressId = 4;
    address public constant voteOwnership = address(0xE478de485ad2fe566d49342Cbd03E49ed7DB3356);
    address public constant voteParameter = address(0xBCfF8B0b9419b9A88c44546519b1e909cF330399);

    uint256 public duckStakerIncentive = 0; //incentive to native token stakers
    uint256 public earmarkIncentive = 100; //incentive to users who spend gas to make calls
    uint256 public platformFee = 0; //possible fee to build treasury
    uint256 public constant MaxFees = 2000;
    uint256 public constant FEE_DENOMINATOR = 10000;

    address public owner;
    address public feeManager;
    address public poolManager;
    address public immutable staker;
    address public rewardFactory;
    address public stashFactory;
    address public tokenFactory;
    address public rewardArbitrator;
    address public voteDelegate;
    address public treasury;
    address public stakerRewards; // CRV for DUCK
    address public lockFees; // 3CRV for uveCRV, no additional fees applied
    address public feeDistro;
    address public feeToken;

    bool public isShutdown;

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    PoolInfo[] public poolInfo;
    mapping(address => bool) public gaugeMap;

    address public preDepositChecker;

    event Deposited(address indexed user, uint256 indexed poolid, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed poolid, uint256 amount);

    constructor(address _staker) {
        isShutdown = false;
        staker = _staker;
        owner = msg.sender;
        voteDelegate = msg.sender;
        feeManager = msg.sender;
        poolManager = msg.sender;
        feeDistro = address(0); //address(0xA464e6DCda8AC41e03616F95f4BC98a13b8922Dc);
        feeToken = address(0); //address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
        treasury = address(0);
    }



    function setOwner(address _owner) external {

        require(msg.sender == owner, "!auth");
        owner = _owner;
    }

    function setFeeManager(address _feeM) external {

        require(msg.sender == feeManager, "!auth");
        feeManager = _feeM;
    }

    function setPoolManager(address _poolM) external {

        require(msg.sender == poolManager, "!auth");
        poolManager = _poolM;
    }

    function setFactories(address _rfactory, address _sfactory, address _tfactory) external {

        require(msg.sender == owner, "!auth");

        if (rewardFactory == address(0)) {
            rewardFactory = _rfactory;
            tokenFactory = _tfactory;
        }

        stashFactory = _sfactory;
    }

    function setArbitrator(address _arb) external {

        require(msg.sender == owner, "!auth");
        rewardArbitrator = _arb;
    }

    function setVoteDelegate(address _voteDelegate) external {

        require(msg.sender == voteDelegate, "!auth");
        voteDelegate = _voteDelegate;
    }

    function setRewardContract(address _stakerRewards) external {

        require(msg.sender == owner, "!auth");
        stakerRewards = _stakerRewards;
    }

    function setFeeInfo() external {

        require(msg.sender == feeManager, "!auth");

        feeDistro = IRegistry(registry).get_address(distributionAddressId);
        address _feeToken = IFeeDistro(feeDistro).token();
        if (feeToken != _feeToken) {
            lockFees = IRewardFactory(rewardFactory).CreateFeePool(_feeToken, address(this));
            feeToken = _feeToken;
        }
    }

    function setFees(uint256 _duckStakerFees, uint256 _callerFees, uint256 _platform) external {

        require(msg.sender == feeManager, "!auth");

        uint256 total = _duckStakerFees.add(_callerFees).add(_platform);
        require(total <= MaxFees, ">MaxFees");

        require(_duckStakerFees <= 1990
            && _callerFees >= 10 && _callerFees <= 100
            && _platform <= 1990, "values must be within certain ranges");

        duckStakerIncentive = _duckStakerFees;
        earmarkIncentive = _callerFees;
        platformFee = _platform;
    }

    function setTreasury(address _treasury) external {

        require(msg.sender == feeManager, "!auth");
        treasury = _treasury;
    }



    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function setPreDepositChecker(address _checker) external {

        require(msg.sender == poolManager && !isShutdown, "!add");
        preDepositChecker = _checker;
    }

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool) {

        require(msg.sender == poolManager && !isShutdown, "!add");
        require(_gauge != address(0) && _lptoken != address(0), "!param");

        uint256 pid = poolInfo.length;

        address token = ITokenFactory(tokenFactory).CreateDepositToken(_lptoken);
        address newRewardPool = IRewardFactory(rewardFactory).CreateCrvRewards(pid, token);
        address stash = IStashFactory(stashFactory).CreateStash(pid, _gauge, staker, _stashVersion);

        poolInfo.push(
            PoolInfo({
                lptoken: _lptoken,
                token: token,
                gauge: _gauge,
                crvRewards: newRewardPool,
                stash: stash,
                shutdown: false
            })
        );
        gaugeMap[_gauge] = true;
        if (stash != address(0)) {
            IStaker(staker).setStashAccess(stash, true);
            IRewardFactory(rewardFactory).setAccess(stash, true);
        }
        return true;
    }

    function shutdownPool(uint256 _pid) external returns(bool) {

        require(msg.sender == poolManager, "!auth");
        PoolInfo storage pool = poolInfo[_pid];

        try IStaker(staker).withdrawAll(pool.lptoken, pool.gauge) {
        }catch{}

        pool.shutdown = true;
        gaugeMap[pool.gauge] = false;
        return true;
    }

    function shutdownSystem() external {
        require(msg.sender == owner, "!auth");
        isShutdown = true;

        for(uint i = 0; i < poolInfo.length; i++) {
            PoolInfo storage pool = poolInfo[i];
            if (pool.shutdown) continue;

            address token = pool.lptoken;
            address gauge = pool.gauge;

            try IStaker(staker).withdrawAll(token, gauge) {
                pool.shutdown = true;
            }catch{}
        }
    }


    function deposit(uint256 _pid, uint256 _amount, bool _stake) public returns(bool) {
        require(!isShutdown, "shutdown");
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.shutdown == false, "pool is closed");

        address lptoken = pool.lptoken;
        address token = pool.token;

        if (preDepositChecker != address(0)) {
            require(IPreDepositChecker(preDepositChecker).canDeposit(msg.sender, _pid, _amount), "check failed");
        }

        IERC20(lptoken).safeTransferFrom(msg.sender, staker, _amount);

        address gauge = pool.gauge;
        require(gauge != address(0), "!gauge setting");
        IStaker(staker).deposit(lptoken, gauge);

        address stash = pool.stash;
        if (stash != address(0)) {
            IStash(stash).stashRewards();
        }

        if (_stake) {
            ITokenMinter(token).mint(address(this), _amount);
            address rewardContract = pool.crvRewards;
            IERC20(token).safeApprove(rewardContract, 0);
            IERC20(token).safeApprove(rewardContract, _amount);
            IRewards(rewardContract).stakeFor(msg.sender, _amount);
        } else {
            ITokenMinter(token).mint(msg.sender, _amount);
        }


        emit Deposited(msg.sender, _pid, _amount);
        return true;
    }

    function depositAll(uint256 _pid, bool _stake) external returns(bool) {
        address lptoken = poolInfo[_pid].lptoken;
        uint256 balance = IERC20(lptoken).balanceOf(msg.sender);
        deposit(_pid,balance,_stake);
        return true;
    }

    function _withdraw(uint256 _pid, uint256 _amount, address _from, address _to) internal {
        PoolInfo storage pool = poolInfo[_pid];
        address lptoken = pool.lptoken;
        address gauge = pool.gauge;

        address token = pool.token;
        ITokenMinter(token).burn(_from, _amount);

        if (!pool.shutdown) {
            IStaker(staker).withdraw(lptoken, gauge, _amount);
        }

        address stash = pool.stash;
        if (stash != address(0) && !isShutdown && !pool.shutdown) {
            IStash(stash).stashRewards();
        }

        IERC20(lptoken).safeTransfer(_to, _amount);

        emit Withdrawn(_to, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public returns(bool) {
        _withdraw(_pid, _amount, msg.sender, msg.sender);
        return true;
    }

    function withdrawAll(uint256 _pid) public returns(bool) {
        address token = poolInfo[_pid].token;
        uint256 userBal = IERC20(token).balanceOf(msg.sender);
        withdraw(_pid, userBal);
        return true;
    }

    function withdrawTo(uint256 _pid, uint256 _amount, address _to) external returns(bool) {
        address rewardContract = poolInfo[_pid].crvRewards;
        require(msg.sender == rewardContract, "!auth");

        _withdraw(_pid,_amount,msg.sender,_to);
        return true;
    }


    function vote(uint256 _voteId, address _votingAddress, bool _support) external returns(bool) {
        require(msg.sender == voteDelegate, "!auth");
        require(_votingAddress == voteOwnership || _votingAddress == voteParameter, "!voteAddr");

        IStaker(staker).vote(_voteId,_votingAddress,_support);
        return true;
    }

    function voteGaugeWeight(address[] calldata _gauge, uint256[] calldata _weight) external returns(bool) {
        require(msg.sender == voteDelegate, "!auth");

        for(uint256 i = 0; i < _gauge.length; i++) {
            IStaker(staker).voteGaugeWeight(_gauge[i],_weight[i]);
        }
        return true;
    }

    function claimRewards(uint256 _pid, address _gauge) external returns(bool) {
        address stash = poolInfo[_pid].stash;
        require(msg.sender == stash, "!auth");

        IStaker(staker).claimRewards(_gauge);
        return true;
    }

    function setGaugeRedirect(uint256 _pid) external returns(bool) {
        address stash = poolInfo[_pid].stash;
        require(msg.sender == stash, "!auth");
        address gauge = poolInfo[_pid].gauge;
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256("set_rewards_receiver(address)")), stash);
        IStaker(staker).execute(gauge, uint256(0), data);
        return true;
    }

    function _earmarkRewards(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.shutdown == false, "pool is closed");

        address gauge = pool.gauge;

        IStaker(staker).claimCrv(gauge);

        address stash = pool.stash;
        if (stash != address(0)) {
            IStash(stash).claimRewards();
            IStash(stash).processStash();
        }

        uint256 crvBal = IERC20(crv).balanceOf(address(this));

        if (crvBal > 0) {
            uint256 _stakerIncentive = stakerRewards == address(0) ? 0 : crvBal.mul(duckStakerIncentive).div(FEE_DENOMINATOR);
            uint256 _callIncentive = crvBal.mul(earmarkIncentive).div(FEE_DENOMINATOR);

            if (treasury != address(0) && treasury != address(this) && platformFee > 0) {
                uint256 _platform = crvBal.mul(platformFee).div(FEE_DENOMINATOR);
                crvBal = crvBal.sub(_platform);
                IERC20(crv).safeTransfer(treasury, _platform);
            }

            crvBal = crvBal.sub(_callIncentive).sub(_stakerIncentive);

            IERC20(crv).safeTransfer(msg.sender, _callIncentive);

            address rewardContract = pool.crvRewards;
            IERC20(crv).safeTransfer(rewardContract, crvBal);
            IRewards(rewardContract).queueNewRewards(crvBal);

            if (_stakerIncentive != 0) {
                IERC20(crv).safeTransfer(stakerRewards, _stakerIncentive);
            }
        }
    }

    function earmarkRewards(uint256 _pid) external returns (bool) {
        require(!isShutdown, "shutdown");
        _earmarkRewards(_pid);
        return true;
    }

    function earmarkFees() external returns(bool) {
        IStaker(staker).claimFees(feeDistro, feeToken);
        uint256 _balance = IERC20(feeToken).balanceOf(address(this));
        IERC20(feeToken).safeTransfer(lockFees, _balance);
        IRewards(lockFees).queueNewRewards(_balance);
        return true;
    }
}