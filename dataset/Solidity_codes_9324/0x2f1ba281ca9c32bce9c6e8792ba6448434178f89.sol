
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface ICauldron {

    function userCollateralShare(address account) external view returns (uint256);

}

interface IBentoBox {

    function toAmount(
        address _token,
        uint256 _share,
        bool _roundUp
    ) external view returns (uint256);

}

interface IRewardStaking {

    function stakeFor(address, uint256) external;


    function stake(uint256) external;


    function withdraw(uint256 amount, bool claim) external;


    function withdrawAndUnwrap(uint256 amount, bool claim) external;


    function earned(address account) external view returns (uint256);


    function getReward() external;


    function getReward(address _account, bool _claimExtras) external;


    function extraRewardsLength() external view returns (uint256);


    function extraRewards(uint256 _pid) external view returns (address);


    function rewardToken() external view returns (address);


    function balanceOf(address _account) external view returns (uint256);

}

interface IConvexDeposits {

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);


    function deposit(
        uint256 _amount,
        bool _lock,
        address _stakeAddress
    ) external;

}

interface ICvx {

    function reductionPerCliff() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function totalCliffs() external view returns (uint256);


    function maxSupply() external view returns (uint256);

}

library CvxMining {

    ICvx public constant cvx = ICvx(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);

    function ConvertCrvToCvx(uint256 _amount) internal view returns (uint256) {

        uint256 supply = cvx.totalSupply();
        uint256 reductionPerCliff = cvx.reductionPerCliff();
        uint256 totalCliffs = cvx.totalCliffs();
        uint256 maxSupply = cvx.maxSupply();

        uint256 cliff = supply / reductionPerCliff;
        if (cliff < totalCliffs) {
            uint256 reduction = totalCliffs - cliff;
            _amount = (_amount * reduction) / totalCliffs;

            uint256 amtTillMax = maxSupply - supply;
            if (_amount > amtTillMax) {
                _amount = amtTillMax;
            }

            return _amount;
        }
        return 0;
    }
}

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

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
}

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
}

library SafeERC20 {

    using SafeMath for uint256;
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

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) public {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

abstract contract ReentrancyGuard {

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


contract ConvexStakingWrapper is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    struct EarnedData {
        address token;
        uint256 amount;
    }

    struct RewardType {
        address reward_token;
        address reward_pool;
        uint128 reward_integral;
        uint128 reward_remaining;
        mapping(address => uint256) reward_integral_for;
        mapping(address => uint256) claimable_reward;
    }

    uint256 public cvx_reward_integral;
    uint256 public cvx_reward_remaining;
    mapping(address => uint256) public cvx_reward_integral_for;
    mapping(address => uint256) public cvx_claimable_reward;

    address public constant convexBooster = address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant cvx = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public curveToken;
    address public convexToken;
    address public convexPool;
    uint256 public convexPoolId;
    address public collateralVault;

    RewardType[] public rewards;

    bool public isShutdown;
    bool public isInit;
    address public owner;

    string internal _tokenname;
    string internal _tokensymbol;

    event Deposited(address indexed _user, address indexed _account, uint256 _amount, bool _wrapped);
    event Withdrawn(address indexed _user, uint256 _amount, bool _unwrapped);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public ERC20("StakedConvexToken", "stkCvx") {}

    function initialize(
        address _curveToken,
        address _convexToken,
        address _convexPool,
        uint256 _poolId,
        address _vault
    ) external virtual {
        require(!isInit, "already init");
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);

        _tokenname = string(abi.encodePacked("Staked ", ERC20(_convexToken).name()));
        _tokensymbol = string(abi.encodePacked("stk", ERC20(_convexToken).symbol()));
        isShutdown = false;
        isInit = true;
        curveToken = _curveToken;
        convexToken = _convexToken;
        convexPool = _convexPool;
        convexPoolId = _poolId;
        collateralVault = _vault;

        addRewards();
        setApprovals();
    }

    function name() public view override returns (string memory) {
        return _tokenname;
    }

    function symbol() public view override returns (string memory) {
        return _tokensymbol;
    }

    function decimals() public view override returns (uint8) {
        return 18;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function shutdown() external onlyOwner {
        isShutdown = true;
    }

    function setApprovals() public {
        IERC20(curveToken).safeApprove(convexBooster, 0);
        IERC20(curveToken).safeApprove(convexBooster, uint256(-1));
        IERC20(convexToken).safeApprove(convexPool, 0);
        IERC20(convexToken).safeApprove(convexPool, uint256(-1));
    }

    function addRewards() public {
        address mainPool = convexPool;

        if (rewards.length == 0) {
            rewards.push(RewardType({reward_token: crv, reward_pool: mainPool, reward_integral: 0, reward_remaining: 0}));
        }

        uint256 extraCount = IRewardStaking(mainPool).extraRewardsLength();
        uint256 startIndex = rewards.length - 1;
        for (uint256 i = startIndex; i < extraCount; i++) {
            address extraPool = IRewardStaking(mainPool).extraRewards(i);
            rewards.push(
                RewardType({
                    reward_token: IRewardStaking(extraPool).rewardToken(),
                    reward_pool: extraPool,
                    reward_integral: 0,
                    reward_remaining: 0
                })
            );
        }
    }

    function rewardLength() external view returns (uint256) {
        return rewards.length;
    }

    function _getDepositedBalance(address _account) internal view virtual returns (uint256) {
        if (_account == address(0) || _account == collateralVault) {
            return 0;
        }

        return balanceOf(_account);
    }

    function _getTotalSupply() internal view virtual returns (uint256) {

        return totalSupply();
    }

    function _calcCvxIntegral(
        address[2] memory _accounts,
        uint256[2] memory _balances,
        uint256 _supply,
        bool _isClaim
    ) internal {
        uint256 bal = IERC20(cvx).balanceOf(address(this));
        uint256 d_cvxreward = bal.sub(cvx_reward_remaining);

        if (_supply > 0 && d_cvxreward > 0) {
            cvx_reward_integral = cvx_reward_integral + d_cvxreward.mul(1e20).div(_supply);
        }

        for (uint256 u = 0; u < _accounts.length; u++) {
            if (_accounts[u] == address(0)) continue;
            if (_accounts[u] == collateralVault) continue;

            uint256 userI = cvx_reward_integral_for[_accounts[u]];
            if (_isClaim || userI < cvx_reward_integral) {
                uint256 receiveable = cvx_claimable_reward[_accounts[u]].add(_balances[u].mul(cvx_reward_integral.sub(userI)).div(1e20));
                if (_isClaim) {
                    if (receiveable > 0) {
                        cvx_claimable_reward[_accounts[u]] = 0;
                        IERC20(cvx).safeTransfer(_accounts[u], receiveable);
                        bal = bal.sub(receiveable);
                    }
                } else {
                    cvx_claimable_reward[_accounts[u]] = receiveable;
                }
                cvx_reward_integral_for[_accounts[u]] = cvx_reward_integral;
            }
        }

        if (bal != cvx_reward_remaining) {
            cvx_reward_remaining = bal;
        }
    }

    function _calcRewardIntegral(
        uint256 _index,
        address[2] memory _accounts,
        uint256[2] memory _balances,
        uint256 _supply,
        bool _isClaim
    ) internal {
        RewardType storage reward = rewards[_index];

        uint256 bal = IERC20(reward.reward_token).balanceOf(address(this));

        if (_supply > 0 && bal.sub(reward.reward_remaining) > 0) {
            reward.reward_integral = reward.reward_integral + uint128(bal.sub(reward.reward_remaining).mul(1e20).div(_supply));
        }

        for (uint256 u = 0; u < _accounts.length; u++) {
            if (_accounts[u] == address(0)) continue;
            if (_accounts[u] == collateralVault) continue;

            uint256 userI = reward.reward_integral_for[_accounts[u]];
            if (_isClaim || userI < reward.reward_integral) {
                if (_isClaim) {
                    uint256 receiveable = reward.claimable_reward[_accounts[u]].add(
                        _balances[u].mul(uint256(reward.reward_integral).sub(userI)).div(1e20)
                    );
                    if (receiveable > 0) {
                        reward.claimable_reward[_accounts[u]] = 0;
                        IERC20(reward.reward_token).safeTransfer(_accounts[u], receiveable);
                        bal = bal.sub(receiveable);
                    }
                } else {
                    reward.claimable_reward[_accounts[u]] = reward.claimable_reward[_accounts[u]].add(
                        _balances[u].mul(uint256(reward.reward_integral).sub(userI)).div(1e20)
                    );
                }
                reward.reward_integral_for[_accounts[u]] = reward.reward_integral;
            }
        }

        if (bal != reward.reward_remaining) {
            reward.reward_remaining = uint128(bal);
        }
    }

    function _checkpoint(address[2] memory _accounts) internal {
        if (isShutdown) return;

        uint256 supply = _getTotalSupply();
        uint256[2] memory depositedBalance;
        depositedBalance[0] = _getDepositedBalance(_accounts[0]);
        depositedBalance[1] = _getDepositedBalance(_accounts[1]);

        IRewardStaking(convexPool).getReward(address(this), true);

        uint256 rewardCount = rewards.length;
        for (uint256 i = 0; i < rewardCount; i++) {
            _calcRewardIntegral(i, _accounts, depositedBalance, supply, false);
        }
        _calcCvxIntegral(_accounts, depositedBalance, supply, false);
    }

    function _checkpointAndClaim(address[2] memory _accounts) internal {
        uint256 supply = _getTotalSupply();
        uint256[2] memory depositedBalance;
        depositedBalance[0] = _getDepositedBalance(_accounts[0]); //only do first slot

        IRewardStaking(convexPool).getReward(address(this), true);

        uint256 rewardCount = rewards.length;
        for (uint256 i = 0; i < rewardCount; i++) {
            _calcRewardIntegral(i, _accounts, depositedBalance, supply, true);
        }
        _calcCvxIntegral(_accounts, depositedBalance, supply, true);
    }

    function user_checkpoint(address[2] calldata _accounts) external returns (bool) {
        _checkpoint([_accounts[0], _accounts[1]]);
        return true;
    }

    function totalBalanceOf(address _account) external view returns (uint256) {
        return _getDepositedBalance(_account);
    }

    function earned(address _account) external view returns (EarnedData[] memory claimable) {
        uint256 supply = _getTotalSupply();
        uint256 rewardCount = rewards.length;
        claimable = new EarnedData[](rewardCount + 1);

        for (uint256 i = 0; i < rewardCount; i++) {
            RewardType storage reward = rewards[i];

            uint256 bal = IERC20(reward.reward_token).balanceOf(address(this));
            uint256 d_reward = bal.sub(reward.reward_remaining);
            d_reward = d_reward.add(IRewardStaking(reward.reward_pool).earned(address(this)));

            uint256 I = reward.reward_integral;
            if (supply > 0) {
                I = I + d_reward.mul(1e20).div(supply);
            }

            uint256 newlyClaimable = _getDepositedBalance(_account).mul(I.sub(reward.reward_integral_for[_account])).div(1e20);
            claimable[i].amount = reward.claimable_reward[_account].add(newlyClaimable);
            claimable[i].token = reward.reward_token;

            if (reward.reward_token == crv) {
                claimable[rewardCount].amount = cvx_claimable_reward[_account].add(CvxMining.ConvertCrvToCvx(newlyClaimable));
                claimable[rewardCount].token = cvx;
            }
        }
        return claimable;
    }

    function getReward(address _account) external {
        _checkpointAndClaim([_account, address(0)]);
    }

    function deposit(uint256 _amount, address _to) external nonReentrant {
        require(!isShutdown, "shutdown");


        if (_amount > 0) {
            _mint(_to, _amount);
            IERC20(curveToken).safeTransferFrom(msg.sender, address(this), _amount);
            IConvexDeposits(convexBooster).deposit(convexPoolId, _amount, true);
        }

        emit Deposited(msg.sender, _to, _amount, true);
    }

    function stake(uint256 _amount, address _to) external nonReentrant {
        require(!isShutdown, "shutdown");


        if (_amount > 0) {
            _mint(_to, _amount);
            IERC20(convexToken).safeTransferFrom(msg.sender, address(this), _amount);
            IRewardStaking(convexPool).stake(_amount);
        }

        emit Deposited(msg.sender, _to, _amount, false);
    }

    function withdraw(uint256 _amount) external nonReentrant {

        if (_amount > 0) {
            _burn(msg.sender, _amount);
            IRewardStaking(convexPool).withdraw(_amount, false);
            IERC20(convexToken).safeTransfer(msg.sender, _amount);
        }

        emit Withdrawn(msg.sender, _amount, false);
    }

    function withdrawAndUnwrap(uint256 _amount) external nonReentrant {

        if (_amount > 0) {
            _burn(msg.sender, _amount);
            IRewardStaking(convexPool).withdrawAndUnwrap(_amount, false);
            IERC20(curveToken).safeTransfer(msg.sender, _amount);
        }

        emit Withdrawn(msg.sender, _amount, true);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256
    ) internal override {
        _checkpoint([_from, _to]);
    }
}

contract ConvexStakingWrapperAbra is ConvexStakingWrapper {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address[] public cauldrons;

    constructor() public {}

    function initialize(
        address _curveToken,
        address _convexToken,
        address _convexPool,
        uint256 _poolId,
        address _vault
    ) external override {
        require(!isInit, "already init");
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
        _tokenname = string(abi.encodePacked("Staked ", ERC20(_convexToken).name(), " Abra"));
        _tokensymbol = string(abi.encodePacked("stk", ERC20(_convexToken).symbol(), "-abra"));
        isShutdown = false;
        isInit = true;
        curveToken = _curveToken;
        convexToken = _convexToken;
        convexPool = _convexPool;
        convexPoolId = _poolId;
        collateralVault = address(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);

        if (_vault != address(0)) {
            cauldrons.push(_vault);
        }

        addRewards();
        setApprovals();
    }

    function cauldronsLength() external view returns (uint256) {
        return cauldrons.length;
    }

    function setCauldron(address _cauldron) external onlyOwner {
        require(_cauldron != address(0), "invalid cauldron");

        for (uint256 i = 0; i < cauldrons.length; i++) {
            require(cauldrons[i] != _cauldron, "already added");
        }

        cauldrons.push(_cauldron);
    }

    function _getDepositedBalance(address _account) internal view override returns (uint256) {
        if (_account == address(0) || _account == collateralVault) {
            return 0;
        }

        if (cauldrons.length == 0) {
            return balanceOf(_account);
        }

        uint256 share;
        for (uint256 i = 0; i < cauldrons.length; i++) {
            try ICauldron(cauldrons[i]).userCollateralShare(_account) returns (uint256 _share) {
                share = share.add(_share);
            } catch {}
        }

        uint256 collateral = IBentoBox(collateralVault).toAmount(address(this), share, false);

        return balanceOf(_account).add(collateral);
    }
}