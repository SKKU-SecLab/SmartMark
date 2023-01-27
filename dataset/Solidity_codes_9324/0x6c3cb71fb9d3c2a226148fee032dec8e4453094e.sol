
pragma solidity ^0.7.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

library SafeMathUpgradeable {

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
}// MIT

pragma solidity ^0.7.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.7.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
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
}// MIT

pragma solidity ^0.7.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity 0.7.6;
pragma abicoder v2;

interface ILendingMarket {

    struct PoolInfo {
        uint256 convexPid;
    }

    struct UserLending {
        bytes32 lendingId;
        uint256 token0;
        uint256 token0Price;
        uint256 lendingAmount;
        uint256 borrowAmount;
        uint256 borrowInterest;
        uint256 supportPid;
        int128 curveCoinId;
        uint256 borrowNumbers;
    }

    function deposit(uint256 _pid, uint256 _token0) external;


    function supplyBooster() external view returns (address);


    function convexBooster() external view returns (address);


    function borrowForDeposit(
        uint256 _pid,
        uint256 _token0,
        uint256 _borrowBlock,
        uint256 _supportPid
    ) external payable returns (bytes32);


    function borrow(
        uint256 _pid,
        uint256 _token0,
        uint256 _borrowBlock,
        uint256 _supportPid
    ) external payable;


    function getUserLastLending(address _user)
        external
        view
        returns (UserLending memory);


    function repayBorrow(bytes32 _lendingId) external payable;


    function repayBorrowERC20(bytes32 _lendingId, uint256 _amount) external;


    function withdraw(uint256 _pid, uint256 _token0) external;


    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);


    function getPoolSupportPid(uint256 _pid, uint256 _supportPid)
        external
        view
        returns (uint256);


    function getPoolSupportPids(uint256 _pid)
        external
        view
        returns (uint256[] memory);


    function getCurveCoinId(uint256 _pid, uint256 _supportPid)
        external
        view
        returns (int128);

}// MIT

pragma solidity 0.7.6;

interface ISupplyBooster {

    struct PoolInfo {
        address underlyToken;
        address rewardInterestPool;
        address supplyTreasuryFund;
        address virtualBalance;
        bool isErc20;
        bool shutdown;
    }

    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);


    function getLendingUnderlyToken(bytes32 _lendingId)
        external
        view
        returns (address);

}// MIT

pragma solidity 0.7.6;

interface IConvexRewardPool {

    function earned(address account) external view returns (uint256);

    function stake(address _for) external;

    function withdraw(address _for) external;

    function getReward(address _for) external;

    function notifyRewardAmount(uint256 reward) external;

    function rewardToken() external returns(address);


    function extraRewards(uint256 _idx) external view returns (address);

    function extraRewardsLength() external view returns (uint256);

    function addExtraReward(address _reward) external returns(bool);

}// MIT

pragma solidity 0.7.6;

interface ILendFlareVault {

    enum ClaimOption {
        None,
        Claim,
        ClaimAsCvxCRV,
        ClaimAsCRV,
        ClaimAsCVX,
        ClaimAsETH
    }

    event Deposit(uint256 indexed _pid, address indexed _sender, uint256 _amount);
    event Withdraw(uint256 indexed _pid, address indexed _sender, uint256 _shares);
    event Claim(address indexed _sender, uint256 _reward, ClaimOption _option);
    event BorrowForDeposit(uint256 indexed _pid, address _sender, uint256 _token0, uint256 _borrowBlock, uint256 _supportPid);
    event RepayBorrow(address indexed _sender, bytes32 _lendingId);
    event Harvest(uint256 _rewards, uint256 _accRewardPerSharem, uint256 _totalShare);
    event UpdateZap(address indexed _swap);
    event AddPool(uint256 indexed _pid, uint256 _lendingMarketPid, uint256 _convexPid, address _lpToken);
    event PausePoolDeposit(uint256 indexed _pid, bool _status);
    event PausePoolWithdraw(uint256 indexed _pid, bool _status);
    event AddLiquidity(uint256 _pid, address _underlyToken, address _lpToken, uint256 _tokens);
}// MIT

pragma solidity 0.7.6;


interface ILendFlareCRV is IERC20Upgradeable {

  event Harvest(address indexed _caller, uint256 _amount);
  event Deposit(address indexed _sender, address indexed _recipient, uint256 _amount);
  event Withdraw(
    address indexed _sender,
    address indexed _recipient,
    uint256 _shares,
    ILendFlareCRV.WithdrawOption _option
  );

  event UpdateZap(address indexed _zap);

  enum WithdrawOption {
    Withdraw,
    WithdrawAndStake,
    WithdrawAsCRV,
    WithdrawAsCVX,
    WithdrawAsETH
  }

  function totalUnderlying() external view returns (uint256);


  function balanceOfUnderlying(address _user) external view returns (uint256);


  function deposit(address _recipient, uint256 _amount) external returns (uint256);


  function depositAll(address _recipient) external returns (uint256);


  function depositWithCRV(address _recipient, uint256 _amount) external returns (uint256);


  function depositAllWithCRV(address _recipient) external returns (uint256);


  function withdraw(
    address _recipient,
    uint256 _shares,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);


  function withdrawAll(
    address _recipient,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);


  function harvest(uint256 _minimumOut) external returns (uint256);

}// MIT

pragma solidity 0.7.6;

interface IConvexBooster {

  struct PoolInfo {
    uint256 originConvexPid;
    address curveSwapAddress; /* like 3pool https://github.com/curvefi/curve-js/blob/master/src/constants/abis/abis-ethereum.ts */
    address lpToken;
    address originCrvRewards;
    address originStash;
    address virtualBalance;
    address rewardCrvPool;
    address rewardCvxPool;
    bool shutdown;
  }

  function poolInfo(uint256 _pid) external view returns (PoolInfo memory);


  function depositAll(uint256 _pid, bool _stake) external returns (bool);


  function deposit(
    uint256 _pid,
    uint256 _amount,
    bool _stake
  ) external returns (bool);


  function getRewards(uint256 _pid) external;

}// MIT

pragma solidity 0.7.6;

interface IConvexBasicRewards {

  function stakeFor(address, uint256) external returns (bool);


  function balanceOf(address) external view returns (uint256);


  function earned(address) external view returns (uint256);


  function withdrawAll(bool) external returns (bool);


  function withdraw(uint256, bool) external returns (bool);


  function withdrawAndUnwrap(uint256, bool) external returns (bool);


  function getReward() external returns (bool);


  function stake(uint256) external returns (bool);

}// MIT

pragma solidity 0.7.6;

interface IConvexCRVDepositor {

  function deposit(
    uint256 _amount,
    bool _lock,
    address _stakeAddress
  ) external;


  function deposit(uint256 _amount, bool _lock) external;


  function lockIncentive() external view returns (uint256);

}// MIT

pragma solidity 0.7.6;

interface ICurveFactoryPool {

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function exchange(
    int128 i,
    int128 j,
    uint256 _dx,
    uint256 _min_dy,
    address _receiver
  ) external returns (uint256);


  function coins(uint256 index) external returns (address);

}// MIT

pragma solidity 0.7.6;

interface IZap {

  function zap(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);

}// MIT

pragma solidity 0.7.6;



contract LendFlareVault is OwnableUpgradeable, ReentrancyGuardUpgradeable, ILendFlareVault {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address payable;

    struct PoolInfo {
        uint256 lendingMarketPid;
        uint256 totalUnderlying;
        uint256 accRewardPerShare;
        uint256 convexPoolId;
        address lpToken;
        bool pauseDeposit;
        bool pauseWithdraw;
    }

    struct UserInfo {
        uint256 totalUnderlying;
        uint256 rewardPerSharePaid;
        uint256 rewards;
        uint256 lendingIndex;
        uint256 lendingLocked;
    }

    struct Lending {
        uint256 pid;
        uint256 lendingIndex;
        address user;
        uint256 lendingMarketPid;
        uint256 token0;
        address underlyToken;
    }

    uint256 private constant PRECISION = 1e18;
    address private constant ZERO_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address private constant CVXCRV = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant BOOSTER = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address private constant CURVE_CVXCRV_CRV_POOL = 0x9D0464996170c6B9e75eED71c68B99dDEDf279e8;
    address private constant CRV_DEPOSITOR = 0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(uint256 => mapping(address => mapping(uint256 => bytes32))) public userLendings; // pid => (user => (lendingIndex => Lending Id))
    mapping(bytes32 => Lending) public lendings;

    address public lendingMarket;
    address public lendFlareCRV;
    address public zap;

    function initialize(
        address _lendingMarket,
        address _lendFlareCRV,
        address _zap
    ) external initializer {

        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

        require(_lendFlareCRV != address(0), "LendFlareVault: zero acrv address");
        require(_zap != address(0), "LendFlareVault: zero zap address");

        lendingMarket = _lendingMarket;
        lendFlareCRV = _lendFlareCRV;
        zap = _zap;
    }


    function poolLength() public view returns (uint256 pools) {

        pools = poolInfo.length;
    }

    function pendingReward(uint256 _pid, address _account) public view returns (uint256) {

        PoolInfo storage _pool = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][_account];

        return uint256(_userInfo.rewards).add(_pool.accRewardPerShare.sub(_userInfo.rewardPerSharePaid).mul(_userInfo.totalUnderlying).div(PRECISION));
    }

    function pendingRewardAll(address _account) external view returns (uint256) {

        uint256 _pending;

        for (uint256 i = 0; i < poolInfo.length; i++) {
            _pending = _pending.add(pendingReward(i, _account));
        }

        return _pending;
    }

    function _deposit(uint256 _pid, uint256 _token0) internal returns (uint256) {

        require(_token0 > 0, "LendFlareVault: zero amount deposit");
        require(_pid < poolInfo.length, "LendFlareVault: invalid pool");

        PoolInfo storage _pool = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_pool.pauseDeposit, "LendFlareVault: pool paused");

        _updateRewards(_pid, msg.sender);

        address _lpToken = _pool.lpToken;
        {
            uint256 _before = IERC20Upgradeable(_lpToken).balanceOf(address(this));
            IERC20Upgradeable(_lpToken).safeTransferFrom(msg.sender, address(this), _token0);
            _token0 = IERC20Upgradeable(_lpToken).balanceOf(address(this)).sub(_before);
        }

        _approve(_lpToken, lendingMarket, _token0);
        ILendingMarket(lendingMarket).deposit(_pool.lendingMarketPid, _token0);

        _pool.totalUnderlying = _pool.totalUnderlying.add(_token0);
        _userInfo.totalUnderlying = _userInfo.totalUnderlying.add(_token0);

        emit Deposit(_pid, msg.sender, _token0);

        return _token0;
    }

    function deposit(uint256 _pid, uint256 _token0) public nonReentrant returns (uint256) {

        return _deposit(_pid, _token0);
    }

    function depositAll(uint256 _pid) external returns (uint256) {

        PoolInfo storage _pool = poolInfo[_pid];

        uint256 _balance = IERC20Upgradeable(_pool.lpToken).balanceOf(msg.sender);

        return deposit(_pid, _balance);
    }

    function depositAndBorrow(
        uint256 _pid,
        uint256 _token0,
        uint256 _borrowBlock,
        uint256 _supportPid,
        bool _loop
    ) public payable nonReentrant {

        require(msg.value == 0.1 ether, "!depositAndBorrow");

        _deposit(_pid, _token0);

        _borrowForDeposit(_pid, _token0, _borrowBlock, _supportPid, _loop);
    }

    function _borrowForDeposit(
        uint256 _pid,
        uint256 _token0,
        uint256 _borrowBlock,
        uint256 _supportPid,
        bool _loop
    ) internal {

        PoolInfo storage _pool = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        bytes32 lendingId = ILendingMarket(lendingMarket).borrowForDeposit{ value: msg.value }(_pool.lendingMarketPid, _token0, _borrowBlock, _supportPid);

        _userInfo.lendingIndex++;

        userLendings[_pid][msg.sender][_userInfo.lendingIndex] = lendingId;

        _userInfo.lendingLocked = _userInfo.lendingLocked.add(_token0);

        address underlyToken = ISupplyBooster(_supplyBooster()).getLendingUnderlyToken(lendingId);

        lendings[lendingId] = Lending({
            pid: _pid,
            user: msg.sender,
            lendingIndex: _userInfo.lendingIndex,
            lendingMarketPid: _pool.lendingMarketPid,
            token0: _token0,
            underlyToken: underlyToken
        });

        emit BorrowForDeposit(_pid, msg.sender, _token0, _borrowBlock, _supportPid);

        if (!_loop) {
            if (underlyToken != ZERO_ADDRESS) {
                sendToken(underlyToken, msg.sender, IERC20Upgradeable(underlyToken).balanceOf(address(this)));
            } else {
                sendToken(address(0), msg.sender, address(this).balance);
            }
        } else {
            uint256[] memory _supplyPids = ILendingMarket(lendingMarket).getPoolSupportPids(_pool.lendingMarketPid);

            ISupplyBooster.PoolInfo memory _supplyPool = ISupplyBooster(_supplyBooster()).poolInfo(_supplyPids[_supportPid]);

            uint256 _tokens = _addLiquidity(_supplyPool.underlyToken, _pool.lpToken, _supplyPool.isErc20);

            _approve(_pool.lpToken, lendingMarket, _tokens);

            _deposit(_pid, IERC20Upgradeable(_pool.lpToken).balanceOf(address(this)));

            emit AddLiquidity(_pid, _supplyPool.underlyToken, _pool.lpToken, _tokens);
        }
    }

    function borrowForDeposit(
        uint256 _pid,
        uint256 _token0,
        uint256 _borrowBlock,
        uint256 _supportPid,
        bool _loop
    ) public payable nonReentrant {

        require(msg.value == 0.1 ether, "!borrowForDeposit");

        _borrowForDeposit(_pid, _token0, _borrowBlock, _supportPid, _loop);
    }

    function _addLiquidity(
        address _from,
        address _to,
        bool _isErc20
    ) internal returns (uint256) {

        if (_isErc20) {
            uint256 bal = IERC20Upgradeable(_from).balanceOf(address(this));

            sendToken(_from, zap, bal);
            
            return IZap(zap).zap(_from, bal, _to, 0);
        } else {
            uint256 bal = address(this).balance;

            return IZap(zap).zap{ value: bal }(WETH, bal, _to, 0);

        }
    }

    function repayBorrow(bytes32 _lendingId) public payable nonReentrant {

        Lending storage _lending = lendings[_lendingId];

        require(_lending.underlyToken != address(0), "!_lendingId");

        PoolInfo storage _pool = poolInfo[_lending.pid];
        UserInfo storage _userInfo = userInfo[_lending.pid][_lending.user];

        uint256 _before = IERC20Upgradeable(_pool.lpToken).balanceOf(address(this));

        ILendingMarket(lendingMarket).repayBorrow{ value: msg.value }(_lendingId);

        _userInfo.lendingLocked = _userInfo.lendingLocked.sub(_lending.token0);

        sendToken(address(0), _lending.user, 0.1 ether);

        uint256 _amount = IERC20Upgradeable(_pool.lpToken).balanceOf(address(this)).sub(_before);

        sendToken(_pool.lpToken, _lending.user, _amount);

        emit RepayBorrow(msg.sender, _lendingId);
    }

    function repayBorrowERC20(bytes32 _lendingId, uint256 _amount) public nonReentrant {

        Lending storage _lending = lendings[_lendingId];

        require(_lending.underlyToken != address(0), "!_lendingId");

        PoolInfo storage _pool = poolInfo[_lending.pid];
        UserInfo storage _userInfo = userInfo[_lending.pid][_lending.user];

        IERC20Upgradeable(_lending.underlyToken).safeTransferFrom(msg.sender, address(this), _amount);

        _approve(_lending.underlyToken, lendingMarket, _amount);

        uint256 _before = IERC20Upgradeable(_pool.lpToken).balanceOf(address(this));

        ILendingMarket(lendingMarket).repayBorrowERC20(_lendingId, _amount);

        _userInfo.lendingLocked = _userInfo.lendingLocked.sub(_lending.token0);

        sendToken(address(0), _lending.user, 0.1 ether);

        _amount = IERC20Upgradeable(_pool.lpToken).balanceOf(address(this)).sub(_before);

        sendToken(_pool.lpToken, _lending.user, _amount);

        emit RepayBorrow(msg.sender, _lendingId);
    }

    function withdraw(
        uint256 _pid,
        uint256 _amount,
        uint256 _minOut,
        ClaimOption _option
    ) public nonReentrant returns (uint256, uint256) {

        require(_amount > 0, "LendFlareVault: zero amount withdraw");
        require(_pid < poolInfo.length, "LendFlareVault: invalid pool");

        PoolInfo storage _pool = poolInfo[_pid];
        require(!_pool.pauseWithdraw, "LendFlareVault: pool paused");
        _updateRewards(_pid, msg.sender);

        UserInfo storage _userInfo = userInfo[_pid][msg.sender];
        require(_amount <= _userInfo.totalUnderlying, "LendFlareVault: _amount not enough");

        require(_amount <= _userInfo.totalUnderlying.sub(_userInfo.lendingLocked), "!_amount");

        _pool.totalUnderlying = _pool.totalUnderlying.sub(_amount);
        _userInfo.totalUnderlying = _userInfo.totalUnderlying.sub(_amount);

        ILendingMarket(lendingMarket).withdraw(_pool.lendingMarketPid, _amount);

        sendToken(_pool.lpToken, msg.sender, _amount);

        emit Withdraw(_pid, msg.sender, _amount);

        if (_option == ClaimOption.None) {
            return (_amount, 0);
        } else {
            uint256 _rewards = _userInfo.rewards;

            _userInfo.rewards = 0;

            _rewards = _claim(_rewards, _minOut, _option);

            return (_amount, _rewards);
        }
    }

    function claim(
        uint256 _pid,
        uint256 _minOut,
        ClaimOption _option
    ) public nonReentrant returns (uint256 claimed) {

        require(_pid < poolInfo.length, "LendFlareVault: invalid pool");

        PoolInfo storage _pool = poolInfo[_pid];
        require(!_pool.pauseWithdraw, "LendFlareVault: pool paused");
        _updateRewards(_pid, msg.sender);

        UserInfo storage _userInfo = userInfo[_pid][msg.sender];
        uint256 _rewards = _userInfo.rewards;

        _userInfo.rewards = 0;

        emit Claim(msg.sender, _rewards, _option);
        _rewards = _claim(_rewards, _minOut, _option);

        return _rewards;
    }

    function harvest(uint256 _pid, uint256 _minimumOut) public nonReentrant {

        require(_pid < poolInfo.length, "LendFlareVault: invalid pool");

        PoolInfo storage _pool = poolInfo[_pid];

        IConvexBooster(_convexBooster()).getRewards(_pool.convexPoolId);

        address rewardCrvPool = IConvexBooster(_convexBooster()).poolInfo(_pool.convexPoolId).rewardCrvPool;

        uint256 _amount = address(this).balance;

        for (uint256 i = 0; i < IConvexRewardPool(rewardCrvPool).extraRewardsLength(); i++) {
            address extraRewardPool = IConvexRewardPool(rewardCrvPool).extraRewards(i);

            address rewardToken = IConvexRewardPool(extraRewardPool).rewardToken();

            if (rewardToken != CRV) {
                uint256 rewardTokenBal = IERC20Upgradeable(rewardToken).balanceOf(address(this));

                if (rewardTokenBal > 0) {
                    sendToken(rewardToken, zap, rewardTokenBal);

                    _amount = _amount.add(IZap(zap).zap(rewardToken, rewardTokenBal, WETH, 0));
                }
            }
        }

        uint256 cvxBal = IERC20Upgradeable(CVX).balanceOf(address(this));

        if (cvxBal > 0) {
            sendToken(CVX, zap, cvxBal);

            _amount = _amount.add(IZap(zap).zap(CVX, cvxBal, WETH, 0));
        }

        if (_amount > 0) {
            IZap(zap).zap{ value: _amount }(WETH, _amount, CRV, 0);
        }

        _amount = IERC20Upgradeable(CRV).balanceOf(address(this));

        uint256 _rewards;

        if (_amount > 0) {
            sendToken(CRV, zap, _amount);
            _amount = IZap(zap).zap(CRV, _amount, CVXCRV, _minimumOut);

            _approve(CVXCRV, lendFlareCRV, _amount);

            _rewards = ILendFlareCRV(lendFlareCRV).deposit(address(this), _amount);

            _pool.accRewardPerShare = _pool.accRewardPerShare.add(_rewards.mul(PRECISION).div(_pool.totalUnderlying));
        }

        emit Harvest(_rewards, _pool.accRewardPerShare, _pool.totalUnderlying);
    }

    function updateSwap(address _zap) external onlyOwner {

        require(_zap != address(0), "LendFlareVault: zero zap address");
        zap = _zap;

        emit UpdateZap(_zap);
    }

    function _convexBooster() internal view returns (address) {

        return ILendingMarket(lendingMarket).convexBooster();
    }

    function _supplyBooster() internal view returns (address) {

        return ILendingMarket(lendingMarket).supplyBooster();
    }

    function addPool(uint256 _lendingMarketPid) public onlyOwner {

        ILendingMarket.PoolInfo memory _lendingMarketPool = ILendingMarket(lendingMarket).poolInfo(_lendingMarketPid);

        for (uint256 i = 0; i < poolInfo.length; i++) {
            require(poolInfo[i].convexPoolId != _lendingMarketPool.convexPid, "LendFlareVault: duplicate pool");
        }

        IConvexBooster.PoolInfo memory _convexBoosterPool = IConvexBooster(_convexBooster()).poolInfo(_lendingMarketPool.convexPid);

        poolInfo.push(
            PoolInfo({
                lendingMarketPid: _lendingMarketPid,
                totalUnderlying: 0,
                accRewardPerShare: 0,
                convexPoolId: _lendingMarketPool.convexPid,
                lpToken: _convexBoosterPool.lpToken,
                pauseDeposit: false,
                pauseWithdraw: false
            })
        );

        emit AddPool(poolInfo.length - 1, _lendingMarketPid, _lendingMarketPool.convexPid, _convexBoosterPool.lpToken);
    }

    function addPools(uint256[] calldata _lendingMarketPids) external {

        for (uint256 i = 0; i < _lendingMarketPids.length; i++) {
            addPool(_lendingMarketPids[i]);
        }
    }

    function pausePoolWithdraw(uint256 _pid, bool _status) external onlyOwner {

        require(_pid < poolInfo.length, "LendFlareVault: invalid pool");

        poolInfo[_pid].pauseWithdraw = _status;

        emit PausePoolWithdraw(_pid, _status);
    }

    function pausePoolDeposit(uint256 _pid, bool _status) external onlyOwner {

        require(_pid < poolInfo.length, "LendFlareVault: invalid pool");

        poolInfo[_pid].pauseDeposit = _status;

        emit PausePoolDeposit(_pid, _status);
    }


    function _updateRewards(uint256 _pid, address _account) internal {

        uint256 _rewards = pendingReward(_pid, _account);
        PoolInfo storage _pool = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][_account];

        _userInfo.rewards = _rewards;
        _userInfo.rewardPerSharePaid = _pool.accRewardPerShare;
    }

    function _claim(
        uint256 _amount,
        uint256 _minOut,
        ClaimOption _option
    ) internal returns (uint256) {

        if (_amount == 0) return _amount;

        ILendFlareCRV.WithdrawOption _withdrawOption;

        if (_option == ClaimOption.Claim) {
            require(_amount >= _minOut, "LendFlareVault: insufficient output");

            sendToken(lendFlareCRV, msg.sender, _amount);

            return _amount;
        } else if (_option == ClaimOption.ClaimAsCvxCRV) {
            _withdrawOption = ILendFlareCRV.WithdrawOption.Withdraw;
        } else if (_option == ClaimOption.ClaimAsCRV) {
            _withdrawOption = ILendFlareCRV.WithdrawOption.WithdrawAsCRV;
        } else if (_option == ClaimOption.ClaimAsCVX) {
            _withdrawOption = ILendFlareCRV.WithdrawOption.WithdrawAsCVX;
        } else if (_option == ClaimOption.ClaimAsETH) {
            _withdrawOption = ILendFlareCRV.WithdrawOption.WithdrawAsETH;
        } else {
            revert("LendFlareVault: invalid claim option");
        }

        return ILendFlareCRV(lendFlareCRV).withdraw(msg.sender, _amount, _minOut, _withdrawOption);
    }

    function _approve(
        address _token,
        address _spender,
        uint256 _amount
    ) internal {

        IERC20Upgradeable(_token).safeApprove(_spender, 0);
        IERC20Upgradeable(_token).safeApprove(_spender, _amount);
    }

    function sendToken(
        address _token,
        address _receiver,
        uint256 _amount
    ) internal {

        if (_token == address(0)) {
            payable(_receiver).sendValue(_amount);
        } else {
            IERC20Upgradeable(_token).safeTransfer(_receiver, _amount);
        }
    }

    receive() external payable {}
}