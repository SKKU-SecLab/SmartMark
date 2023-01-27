
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

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
}// MIT
pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT
pragma solidity >=0.5.0;

interface IMaidCoin {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function INITIAL_SUPPLY() external pure returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;

}// MIT
pragma solidity >=0.5.0;

interface IRewardCalculator {

    function rewardPerBlock() external view returns (uint256);

}// MIT
pragma solidity >=0.5.0;

interface ISupportable {

    event SupportTo(address indexed supporter, uint256 indexed to);
    event ChangeSupportingRoute(uint256 indexed from, uint256 indexed to);
    event ChangeSupportedPower(uint256 indexed id, int256 power);
    event TransferSupportingRewards(address indexed supporter, uint256 indexed id, uint256 amounts);

    function supportingRoute(uint256 id) external view returns (uint256);


    function supportingTo(address supporter) external view returns (uint256);


    function supportedPower(uint256 id) external view returns (uint256);


    function totalRewardsFromSupporters(uint256 id) external view returns (uint256);


    function setSupportingTo(
        address supporter,
        uint256 to,
        uint256 amounts
    ) external;


    function checkSupportingRoute(address supporter) external returns (address, uint256);


    function changeSupportedPower(address supporter, int256 power) external;


    function shareRewards(
        uint256 pending,
        address supporter,
        uint8 supportingRatio
    ) external returns (address nurseOwner, uint256 amountToNurseOwner);

}// MIT
pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IMasterChef {

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHI to distribute per block.
        uint256 lastRewardBlock; // Last block number that SUSHI distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHI per share, times 1e12. See below.
    }

    function poolInfo(uint256 pid) external view returns (IMasterChef.PoolInfo memory);


    function userInfo(uint256 pid, address user) external view returns (IMasterChef.UserInfo memory);


    function pendingSushi(uint256 _pid, address _user) external view returns (uint256);


    function deposit(uint256 _pid, uint256 _amount) external;


    function withdraw(uint256 _pid, uint256 _amount) external;

}// MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}// MIT
pragma solidity >=0.5.0;


interface IMasterChefModule {

    function lpToken() external view returns (IUniswapV2Pair);


    function sushi() external view returns (IERC20);


    function sushiMasterChef() external view returns (IMasterChef);


    function masterChefPid() external view returns (uint256);


    function sushiLastRewardBlock() external view returns (uint256);


    function accSushiPerShare() external view returns (uint256);

}// MIT
pragma solidity >=0.5.0;


interface ITheMaster is IMasterChefModule {

    event ChangeRewardCalculator(address addr);

    event Add(
        uint256 indexed pid,
        address addr,
        bool indexed delegate,
        bool indexed mintable,
        address supportable,
        uint8 supportingRatio,
        uint256 allocPoint
    );

    event Set(uint256 indexed pid, uint256 allocPoint);
    event Deposit(uint256 indexed userId, uint256 indexed pid, uint256 amount);
    event Withdraw(uint256 indexed userId, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event Support(address indexed supporter, uint256 indexed pid, uint256 amount);
    event Desupport(address indexed supporter, uint256 indexed pid, uint256 amount);
    event EmergencyDesupport(address indexed user, uint256 indexed pid, uint256 amount);

    event SetIsSupporterPool(uint256 indexed pid, bool indexed status);

    function initialRewardPerBlock() external view returns (uint256);


    function decreasingInterval() external view returns (uint256);


    function startBlock() external view returns (uint256);


    function maidCoin() external view returns (IMaidCoin);


    function rewardCalculator() external view returns (IRewardCalculator);


    function poolInfo(uint256 pid)
        external
        view
        returns (
            address addr,
            bool delegate,
            ISupportable supportable,
            uint8 supportingRatio,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accRewardPerShare,
            uint256 supply
        );


    function poolCount() external view returns (uint256);


    function userInfo(uint256 pid, uint256 user) external view returns (uint256 amount, uint256 rewardDebt);


    function mintableByAddr(address addr) external view returns (bool);


    function totalAllocPoint() external view returns (uint256);


    function pendingReward(uint256 pid, uint256 userId) external view returns (uint256);


    function rewardPerBlock() external view returns (uint256);


    function changeRewardCalculator(address addr) external;


    function add(
        address addr,
        bool delegate,
        bool mintable,
        address supportable,
        uint8 supportingRatio,
        uint256 allocPoint
    ) external;


    function set(uint256[] calldata pid, uint256[] calldata allocPoint) external;


    function deposit(
        uint256 pid,
        uint256 amount,
        uint256 userId
    ) external;


    function depositWithPermit(
        uint256 pid,
        uint256 amount,
        uint256 userId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function depositWithPermitMax(
        uint256 pid,
        uint256 amount,
        uint256 userId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function withdraw(
        uint256 pid,
        uint256 amount,
        uint256 userId
    ) external;


    function emergencyWithdraw(uint256 pid) external;


    function support(
        uint256 pid,
        uint256 amount,
        uint256 supportTo
    ) external;


    function supportWithPermit(
        uint256 pid,
        uint256 amount,
        uint256 supportTo,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function supportWithPermitMax(
        uint256 pid,
        uint256 amount,
        uint256 supportTo,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function desupport(uint256 pid, uint256 amount) external;


    function emergencyDesupport(uint256 pid) external;


    function mint(address to, uint256 amount) external;


    function claimSushiReward(uint256 id) external;


    function pendingSushiReward(uint256 id) external view returns (uint256);

}// MIT
pragma solidity ^0.8.5;


abstract contract MasterChefModule is Ownable, IMasterChefModule {
    IUniswapV2Pair public immutable override lpToken;

    IERC20 public immutable override sushi;
    IMasterChef public override sushiMasterChef;
    uint256 public override masterChefPid;
    uint256 public override sushiLastRewardBlock;
    uint256 public override accSushiPerShare;
    bool private initialDeposited;

    constructor(IUniswapV2Pair _lpToken, IERC20 _sushi) {
        lpToken = _lpToken;
        sushi = _sushi;
    }

    function _depositModule(
        uint256 _pid,
        uint256 depositAmount,
        uint256 supportedLPTokenAmount,
        uint256 sushiRewardDebt
    ) internal returns (uint256 newRewardDebt) {
        uint256 _totalSupportedLPTokenAmount = sushiMasterChef.userInfo(_pid, address(this)).amount;
        uint256 _accSushiPerShare = _depositToSushiMasterChef(_pid, depositAmount, _totalSupportedLPTokenAmount);
        uint256 pending = (supportedLPTokenAmount * _accSushiPerShare) / 1e18 - sushiRewardDebt;
        if (pending > 0) safeSushiTransfer(msg.sender, pending);
        return ((supportedLPTokenAmount + depositAmount) * _accSushiPerShare) / 1e18;
    }

    function _withdrawModule(
        uint256 _pid,
        uint256 withdrawalAmount,
        uint256 supportedLPTokenAmount,
        uint256 sushiRewardDebt
    ) internal returns (uint256 newRewardDebt) {
        uint256 _totalSupportedLPTokenAmount = sushiMasterChef.userInfo(_pid, address(this)).amount;
        uint256 _accSushiPerShare = _withdrawFromSushiMasterChef(_pid, withdrawalAmount, _totalSupportedLPTokenAmount);
        uint256 pending = (supportedLPTokenAmount * _accSushiPerShare) / 1e18 - sushiRewardDebt;
        if (pending > 0) safeSushiTransfer(msg.sender, pending);
        return ((supportedLPTokenAmount - withdrawalAmount) * _accSushiPerShare) / 1e18;
    }

    function _claimSushiReward(uint256 supportedLPTokenAmount, uint256 sushiRewardDebt)
        internal
        returns (uint256 newRewardDebt)
    {
        uint256 _pid = masterChefPid;
        require(_pid > 0, "MasterChefModule: Unclaimable");

        uint256 _totalSupportedLPTokenAmount = sushiMasterChef.userInfo(_pid, address(this)).amount;
        uint256 _accSushiPerShare = _depositToSushiMasterChef(_pid, 0, _totalSupportedLPTokenAmount);
        uint256 pending = (supportedLPTokenAmount * _accSushiPerShare) / 1e18 - sushiRewardDebt;
        require(pending > 0, "MasterChefModule: Nothing can be claimed");
        safeSushiTransfer(msg.sender, pending);
        return (supportedLPTokenAmount * _accSushiPerShare) / 1e18;
    }

    function _pendingSushiReward(uint256 supportedLPTokenAmount, uint256 sushiRewardDebt)
        internal
        view
        returns (uint256)
    {
        uint256 _pid = masterChefPid;
        if (_pid == 0) return 0;
        uint256 _totalSupportedLPTokenAmount = sushiMasterChef.userInfo(_pid, address(this)).amount;

        uint256 _accSushiPerShare = accSushiPerShare;
        if (block.number > sushiLastRewardBlock && _totalSupportedLPTokenAmount != 0) {
            uint256 reward = sushiMasterChef.pendingSushi(masterChefPid, address(this));
            _accSushiPerShare += ((reward * 1e18) / _totalSupportedLPTokenAmount);
        }

        return (supportedLPTokenAmount * _accSushiPerShare) / 1e18 - sushiRewardDebt;
    }

    function setSushiMasterChef(IMasterChef _masterChef, uint256 _pid) external onlyOwner {
        require(address(_masterChef.poolInfo(_pid).lpToken) == address(lpToken), "MasterChefModule: Invalid pid");
        if (!initialDeposited) {
            initialDeposited = true;
            lpToken.approve(address(_masterChef), type(uint256).max);

            sushiMasterChef = _masterChef;
            masterChefPid = _pid;
            _depositToSushiMasterChef(_pid, lpToken.balanceOf(address(this)), 0);
        } else {
            IMasterChef oldChef = sushiMasterChef;
            uint256 oldpid = masterChefPid;
            _withdrawFromSushiMasterChef(oldpid, oldChef.userInfo(oldpid, address(this)).amount, 0);
            if (_masterChef != oldChef) {
                lpToken.approve(address(oldChef), 0);
                lpToken.approve(address(_masterChef), type(uint256).max);
            }

            sushiMasterChef = _masterChef;
            masterChefPid = _pid;
            _depositToSushiMasterChef(_pid, lpToken.balanceOf(address(this)), 0);
        }
    }

    function _depositToSushiMasterChef(
        uint256 _pid,
        uint256 _amount,
        uint256 _totalSupportedLPTokenAmount
    ) internal returns (uint256 _accSushiPerShare) {
        return _toSushiMasterChef(true, _pid, _amount, _totalSupportedLPTokenAmount);
    }

    function _withdrawFromSushiMasterChef(
        uint256 _pid,
        uint256 _amount,
        uint256 _totalSupportedLPTokenAmount
    ) internal returns (uint256 _accSushiPerShare) {
        return _toSushiMasterChef(false, _pid, _amount, _totalSupportedLPTokenAmount);
    }

    function _toSushiMasterChef(
        bool deposit,
        uint256 _pid,
        uint256 _amount,
        uint256 _totalSupportedLPTokenAmount
    ) internal returns (uint256) {
        uint256 reward;
        if (block.number <= sushiLastRewardBlock) {
            if (deposit) sushiMasterChef.deposit(_pid, _amount);
            else sushiMasterChef.withdraw(_pid, _amount);
            return accSushiPerShare;
        } else {
            uint256 balance0 = sushi.balanceOf(address(this));
            if (deposit) sushiMasterChef.deposit(_pid, _amount);
            else sushiMasterChef.withdraw(_pid, _amount);
            uint256 balance1 = sushi.balanceOf(address(this));
            reward = balance1 - balance0;
        }
        sushiLastRewardBlock = block.number;
        if (_totalSupportedLPTokenAmount > 0 && reward > 0) {
            uint256 _accSushiPerShare = accSushiPerShare + ((reward * 1e18) / _totalSupportedLPTokenAmount);
            accSushiPerShare = _accSushiPerShare;
            return _accSushiPerShare;
        } else {
            return accSushiPerShare;
        }
    }

    function safeSushiTransfer(address _to, uint256 _amount) internal {
        uint256 sushiBal = sushi.balanceOf(address(this));
        if (_amount > sushiBal) {
            sushi.transfer(_to, sushiBal);
        } else {
            sushi.transfer(_to, _amount);
        }
    }
}// MIT
pragma solidity ^0.8.5;


contract TheMaster is Ownable, MasterChefModule, ITheMaster {

    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address addr;
        bool delegate;
        ISupportable supportable;
        uint8 supportingRatio; //out of 100
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
        uint256 supply;
    }

    uint256 private constant PRECISION = 1e20;

    uint256 public immutable override initialRewardPerBlock;
    uint256 public immutable override decreasingInterval;
    uint256 public immutable override startBlock;

    IMaidCoin public immutable override maidCoin;
    IRewardCalculator public override rewardCalculator;

    PoolInfo[] public override poolInfo;
    mapping(uint256 => mapping(uint256 => UserInfo)) public override userInfo;
    mapping(uint256 => mapping(address => uint256)) private sushiRewardDebt;
    mapping(address => bool) public override mintableByAddr;
    uint256 public override totalAllocPoint;

    constructor(
        uint256 _initialRewardPerBlock,
        uint256 _decreasingInterval,
        uint256 _startBlock,
        IMaidCoin _maidCoin,
        IUniswapV2Pair _lpToken,
        IERC20 _sushi
    ) MasterChefModule(_lpToken, _sushi) {
        initialRewardPerBlock = _initialRewardPerBlock;
        decreasingInterval = _decreasingInterval;
        startBlock = _startBlock;
        maidCoin = _maidCoin;
    }

    function poolCount() external view override returns (uint256) {

        return poolInfo.length;
    }

    function pendingReward(uint256 pid, uint256 userId) external view override returns (uint256) {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][userId];
        (uint256 accRewardPerShare, uint256 supply) = (pool.accRewardPerShare, pool.supply);
        uint256 _lastRewardBlock = pool.lastRewardBlock;
        if (block.number > _lastRewardBlock && supply != 0) {
            uint256 reward = ((block.number - _lastRewardBlock) * rewardPerBlock() * pool.allocPoint) / totalAllocPoint;
            accRewardPerShare = accRewardPerShare + (reward * PRECISION) / supply;
        }
        uint256 pending = ((user.amount * accRewardPerShare) / PRECISION) - user.rewardDebt;
        uint256 _supportingRatio = pool.supportingRatio;
        if (_supportingRatio == 0) {
            return pending;
        } else {
            return pending - ((pending * _supportingRatio) / 100);
        }
    }

    function rewardPerBlock() public view override returns (uint256) {

        if (address(rewardCalculator) != address(0)) {
            return rewardCalculator.rewardPerBlock();
        }
        uint256 era = (block.number - startBlock) / decreasingInterval;
        return initialRewardPerBlock / (era + 1);
    }

    function changeRewardCalculator(address addr) external override onlyOwner {

        rewardCalculator = IRewardCalculator(addr);
        emit ChangeRewardCalculator(addr);
    }

    function add(
        address addr,
        bool delegate,
        bool mintable,
        address supportable,
        uint8 supportingRatio,
        uint256 allocPoint
    ) external override onlyOwner {

        if (supportable != address(0)) {
            require(supportingRatio > 0 && supportingRatio <= 80, "TheMaster: Outranged supportingRatio");
        } else {
            require(supportingRatio == 0, "TheMaster: Not supportable pool");
        }
        massUpdatePools();
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint += allocPoint;
        uint256 pid = poolInfo.length;
        poolInfo.push(
            PoolInfo(addr, delegate, ISupportable(supportable), supportingRatio, allocPoint, lastRewardBlock, 0, 0)
        );
        if (mintable) {
            mintableByAddr[addr] = true;
        }
        emit Add(pid, addr, delegate, mintableByAddr[addr], supportable, supportingRatio, allocPoint);
    }

    function set(uint256[] calldata pids, uint256[] calldata allocPoints) external override onlyOwner {

        massUpdatePools();
        for (uint256 i = 0; i < pids.length; i += 1) {
            totalAllocPoint = totalAllocPoint - poolInfo[pids[i]].allocPoint + allocPoints[i];
            poolInfo[pids[i]].allocPoint = allocPoints[i];
            emit Set(pids[i], allocPoints[i]);
        }
    }

    function updatePool(PoolInfo storage pool) internal {

        uint256 _lastRewardBlock = pool.lastRewardBlock;
        if (block.number <= _lastRewardBlock) {
            return;
        }
        uint256 supply = pool.supply;
        if (supply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 reward = ((block.number - _lastRewardBlock) * rewardPerBlock() * pool.allocPoint) / totalAllocPoint;
        maidCoin.mint(address(this), reward);
        pool.accRewardPerShare = pool.accRewardPerShare + (reward * PRECISION) / supply;
        pool.lastRewardBlock = block.number;
    }

    function massUpdatePools() internal {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(poolInfo[pid]);
        }
    }

    function deposit(
        uint256 pid,
        uint256 amount,
        uint256 userId
    ) public override {

        PoolInfo storage pool = poolInfo[pid];
        require(address(pool.supportable) == address(0), "TheMaster: Use support func");
        UserInfo storage user = userInfo[pid][userId];
        if (pool.delegate) {
            require(pool.addr == msg.sender, "TheMaster: Not called by delegate");
            _deposit(pid, pool, user, amount, false);
        } else {
            require(address(uint160(userId)) == msg.sender, "TheMaster: Deposit to your address");
            _deposit(pid, pool, user, amount, true);
        }
        emit Deposit(userId, pid, amount);
    }

    function _deposit(
        uint256 pid,
        PoolInfo storage pool,
        UserInfo storage user,
        uint256 amount,
        bool tokenTransfer
    ) internal {

        updatePool(pool);
        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 _amount = user.amount;
        if (_amount > 0) {
            uint256 pending = ((_amount * _accRewardPerShare) / PRECISION) - user.rewardDebt;
            if (pending > 0) safeRewardTransfer(msg.sender, pending);
        }
        if (amount > 0) {
            if (tokenTransfer) {
                IERC20(pool.addr).safeTransferFrom(msg.sender, address(this), amount);
                uint256 _mcPid = masterChefPid;
                if (_mcPid > 0 && pool.addr == address(lpToken)) {
                    sushiRewardDebt[pid][msg.sender] = _depositModule(
                        _mcPid,
                        amount,
                        _amount,
                        sushiRewardDebt[pid][msg.sender]
                    );
                }
            }
            pool.supply += amount;
            _amount += amount;
            user.amount = _amount;
        }
        user.rewardDebt = (_amount * _accRewardPerShare) / PRECISION;
    }

    function depositWithPermit(
        uint256 pid,
        uint256 amount,
        uint256 userId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        IUniswapV2ERC20(poolInfo[pid].addr).permit(msg.sender, address(this), amount, deadline, v, r, s);
        deposit(pid, amount, userId);
    }

    function depositWithPermitMax(
        uint256 pid,
        uint256 amount,
        uint256 userId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        IUniswapV2ERC20(poolInfo[pid].addr).permit(msg.sender, address(this), type(uint256).max, deadline, v, r, s);
        deposit(pid, amount, userId);
    }

    function withdraw(
        uint256 pid,
        uint256 amount,
        uint256 userId
    ) public override {

        PoolInfo storage pool = poolInfo[pid];
        require(address(pool.supportable) == address(0), "TheMaster: Use desupport func");
        UserInfo storage user = userInfo[pid][userId];
        if (pool.delegate) {
            require(pool.addr == msg.sender, "TheMaster: Not called by delegate");
            _withdraw(pid, pool, user, amount, false);
        } else {
            require(address(uint160(userId)) == msg.sender, "TheMaster: Not called by user");
            _withdraw(pid, pool, user, amount, true);
        }
        emit Withdraw(userId, pid, amount);
    }

    function _withdraw(
        uint256 pid,
        PoolInfo storage pool,
        UserInfo storage user,
        uint256 amount,
        bool tokenTransfer
    ) internal {

        uint256 _amount = user.amount;
        require(_amount >= amount, "TheMaster: Insufficient amount");
        updatePool(pool);
        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 pending = ((_amount * _accRewardPerShare) / PRECISION) - user.rewardDebt;
        if (pending > 0) safeRewardTransfer(msg.sender, pending);
        if (amount > 0) {
            pool.supply -= amount;
            _amount -= amount;
            user.amount = _amount;
            if (tokenTransfer) {
                uint256 _mcPid = masterChefPid;
                if (_mcPid > 0 && pool.addr == address(lpToken)) {
                    sushiRewardDebt[pid][msg.sender] = _withdrawModule(
                        _mcPid,
                        amount,
                        _amount + amount,
                        sushiRewardDebt[pid][msg.sender]
                    );
                }

                IERC20(pool.addr).safeTransfer(msg.sender, amount);
            }
        }
        user.rewardDebt = (_amount * _accRewardPerShare) / PRECISION;
    }

    function emergencyWithdraw(uint256 pid) external override {

        PoolInfo storage pool = poolInfo[pid];
        require(address(pool.supportable) == address(0), "TheMaster: Use desupport func");
        require(!pool.delegate, "TheMaster: Pool should be non-delegate");
        UserInfo storage user = userInfo[pid][uint256(uint160(msg.sender))];
        uint256 amounts = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.supply -= amounts;

        uint256 _mcPid = masterChefPid;
        if (_mcPid > 0 && pool.addr == address(lpToken)) {
            sushiRewardDebt[pid][msg.sender] = _withdrawModule(
                _mcPid,
                amounts,
                amounts,
                sushiRewardDebt[pid][msg.sender]
            );
        }

        IERC20(pool.addr).safeTransfer(msg.sender, amounts);
        emit EmergencyWithdraw(msg.sender, pid, amounts);
    }

    function support(
        uint256 pid,
        uint256 amount,
        uint256 supportTo
    ) public override {

        PoolInfo storage pool = poolInfo[pid];
        ISupportable supportable = pool.supportable;
        require(address(supportable) != address(0), "TheMaster: Use deposit func");
        UserInfo storage user = userInfo[pid][uint256(uint160(msg.sender))];
        updatePool(pool);
        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 _amount = user.amount;
        if (_amount > 0) {
            uint256 pending = ((_amount * _accRewardPerShare) / PRECISION) - user.rewardDebt;
            if (pending > 0) {
                (address to, uint256 amounts) = supportable.shareRewards(pending, msg.sender, pool.supportingRatio);
                if (amounts > 0) safeRewardTransfer(to, amounts);
                safeRewardTransfer(msg.sender, pending - amounts);
            }
        }
        if (amount > 0) {
            if (_amount == 0) {
                supportable.setSupportingTo(msg.sender, supportTo, amount);
            } else {
                supportable.changeSupportedPower(msg.sender, int256(amount));
            }
            IERC20(pool.addr).safeTransferFrom(msg.sender, address(this), amount);

            uint256 _mcPid = masterChefPid;
            if (_mcPid > 0 && pool.addr == address(lpToken)) {
                sushiRewardDebt[pid][msg.sender] = _depositModule(
                    _mcPid,
                    amount,
                    _amount,
                    sushiRewardDebt[pid][msg.sender]
                );
            }

            pool.supply += amount;
            _amount += amount;
            user.amount = _amount;
        }
        user.rewardDebt = (_amount * _accRewardPerShare) / PRECISION;
        emit Support(msg.sender, pid, amount);
    }

    function supportWithPermit(
        uint256 pid,
        uint256 amount,
        uint256 supportTo,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        IUniswapV2ERC20(poolInfo[pid].addr).permit(msg.sender, address(this), amount, deadline, v, r, s);
        support(pid, amount, supportTo);
    }

    function supportWithPermitMax(
        uint256 pid,
        uint256 amount,
        uint256 supportTo,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        IUniswapV2ERC20(poolInfo[pid].addr).permit(msg.sender, address(this), type(uint256).max, deadline, v, r, s);
        support(pid, amount, supportTo);
    }

    function desupport(uint256 pid, uint256 amount) external override {

        PoolInfo storage pool = poolInfo[pid];
        ISupportable supportable = pool.supportable;
        require(address(supportable) != address(0), "TheMaster: Use withdraw func");
        UserInfo storage user = userInfo[pid][uint256(uint160(msg.sender))];
        uint256 _amount = user.amount;
        require(_amount >= amount, "TheMaster: Insufficient amount");
        updatePool(pool);
        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 pending = ((_amount * _accRewardPerShare) / PRECISION) - user.rewardDebt;
        if (pending > 0) {
            (address to, uint256 amounts) = supportable.shareRewards(pending, msg.sender, pool.supportingRatio);
            if (amounts > 0) safeRewardTransfer(to, amounts);
            safeRewardTransfer(msg.sender, pending - amounts);
        }
        if (amount > 0) {
            supportable.changeSupportedPower(msg.sender, -int256(amount));

            uint256 _mcPid = masterChefPid;
            if (_mcPid > 0 && pool.addr == address(lpToken)) {
                sushiRewardDebt[pid][msg.sender] = _withdrawModule(
                    _mcPid,
                    amount,
                    _amount,
                    sushiRewardDebt[pid][msg.sender]
                );
            }

            pool.supply -= amount;
            _amount -= amount;
            user.amount = _amount;
            IERC20(pool.addr).safeTransfer(msg.sender, amount);
        }
        user.rewardDebt = (_amount * _accRewardPerShare) / PRECISION;
        emit Desupport(msg.sender, pid, amount);
    }

    function emergencyDesupport(uint256 pid) external override {

        PoolInfo storage pool = poolInfo[pid];
        ISupportable supportable = pool.supportable;
        require(address(supportable) != address(0), "TheMaster: Use emergencyWithdraw func");
        UserInfo storage user = userInfo[pid][uint256(uint160(msg.sender))];
        uint256 amounts = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.supply -= amounts;
        supportable.changeSupportedPower(msg.sender, -int256(amounts));

        uint256 _mcPid = masterChefPid;
        if (_mcPid > 0 && pool.addr == address(lpToken)) {
            sushiRewardDebt[pid][msg.sender] = _withdrawModule(
                _mcPid,
                amounts,
                amounts,
                sushiRewardDebt[pid][msg.sender]
            );
        }

        IERC20(pool.addr).safeTransfer(msg.sender, amounts);
        emit EmergencyDesupport(msg.sender, pid, amounts);
    }

    function mint(address to, uint256 amount) external override {

        require(mintableByAddr[msg.sender], "TheMaster: Called from un-mintable");
        maidCoin.mint(to, amount);
    }

    function safeRewardTransfer(address to, uint256 amount) internal {

        uint256 balance = maidCoin.balanceOf(address(this));
        if (amount > balance) {
            maidCoin.transfer(to, balance);
        } else {
            maidCoin.transfer(to, amount);
        }
    }

    function pendingSushiReward(uint256 pid) external view override returns (uint256) {

        return
            _pendingSushiReward(userInfo[pid][uint256(uint160(msg.sender))].amount, sushiRewardDebt[pid][msg.sender]);
    }

    function claimSushiReward(uint256 pid) public override {

        PoolInfo storage pool = poolInfo[pid];
        require(pool.addr == address(lpToken) && !pool.delegate, "TheMaster: Invalid pid");

        sushiRewardDebt[pid][msg.sender] = _claimSushiReward(
            userInfo[pid][uint256(uint160(msg.sender))].amount,
            sushiRewardDebt[pid][msg.sender]
        );
    }

    function claimAllReward(uint256 pid) public {

        PoolInfo storage pool = poolInfo[pid];
        require(pool.addr == address(lpToken) && !pool.delegate, "TheMaster: Invalid pid");

        UserInfo storage user = userInfo[pid][uint256(uint160(msg.sender))];
        uint256 amount = user.amount;
        require(amount > 0, "TheMaster: Nothing can be claimed");
        sushiRewardDebt[pid][msg.sender] = _claimSushiReward(amount, sushiRewardDebt[pid][msg.sender]);

        updatePool(pool);
        ISupportable supportable = pool.supportable;

        if (address(supportable) == address(0)) {
            uint256 _accRewardPerShare = pool.accRewardPerShare;
            uint256 pending = ((amount * _accRewardPerShare) / PRECISION) - user.rewardDebt;
            if (pending > 0) safeRewardTransfer(msg.sender, pending);
            user.rewardDebt = (amount * _accRewardPerShare) / PRECISION;
        } else {
            uint256 _accRewardPerShare = pool.accRewardPerShare;
            uint256 pending = ((amount * _accRewardPerShare) / PRECISION) - user.rewardDebt;
            if (pending > 0) {
                (address to, uint256 amounts) = supportable.shareRewards(pending, msg.sender, pool.supportingRatio);
                if (amounts > 0) safeRewardTransfer(to, amounts);
                safeRewardTransfer(msg.sender, pending - amounts);
            }
            user.rewardDebt = (amount * _accRewardPerShare) / PRECISION;
        }
    }
}