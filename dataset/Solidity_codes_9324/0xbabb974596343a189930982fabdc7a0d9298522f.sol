
pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

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
        return !Address.isContract(address(this));
    }
}// UNLICENSED

pragma solidity =0.6.12;

interface IVirtualBalanceWrapperFactory {

    function createWrapper(address _op) external returns (address);

}

interface IVirtualBalanceWrapper {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function withdrawFor(address _for, uint256 amount) external returns (bool);

}// UNLICENSED

pragma solidity =0.6.12;

interface IBaseReward {

    function earned(address account) external view returns (uint256);

    function stake(address _for) external;

    function withdraw(address _for) external;

    function getReward(address _for) external;

    function notifyRewardAmount(uint256 reward) external;

    function addOwner(address _newOwner) external;

    function addOwners(address[] calldata _newOwners) external;

    function removeOwner(address _owner) external;

    function isOwner(address _owner) external view returns (bool);

}// UNLICENSED

pragma solidity =0.6.12;

interface ISupplyBooster {

    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address underlyToken,
            address rewardInterestPool,
            address supplyTreasuryFund,
            address virtualBalance,
            bool isErc20,
            bool shutdown
        );


    function liquidate(bytes32 _lendingId, uint256 _lendingInterest)
        external
        payable
        returns (address);


    function getLendingUnderlyToken(bytes32 _lendingId)
        external
        view
        returns (address);


    function borrow(
        uint256 _pid,
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest,
        uint256 _borrowNumbers
    ) external;


    function repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingInterest
    ) external payable;


    function repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest
    ) external;


    function addSupplyPool(address _underlyToken, address _supplyTreasuryFund)
        external
        returns (bool);


    function getBorrowRatePerBlock(uint256 _pid)
        external
        view
        returns (uint256);


    function getUtilizationRate(uint256 _pid) external view returns (uint256);

}// UNLICENSED

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;


interface ISupplyPoolExtraReward {

    function addExtraReward( uint256 _pid, address _lpToken, address _virtualBalance, bool _isErc20) external;

    function toggleShutdownPool(uint256 _pid, bool _state) external;

    function getRewards(uint256 _pid,address _for) external;

    function beforeStake(uint256 _pid, address _for) external;

    function afterStake(uint256 _pid, address _for) external;

    function beforeWithdraw(uint256 _pid, address _for) external;

    function afterWithdraw(uint256 _pid, address _for) external;

    function notifyRewardAmount( uint256 _pid, address _underlyToken, uint256 _amount) external payable;

}

interface ISupplyTreasuryFund {

    function initialize(address _virtualBalance, address _underlyToken, bool _isErc20) external;

    function depositFor(address _for) external payable;

    function depositFor(address _for, uint256 _amount) external;

    function withdrawFor(address _to, uint256 _amount) external  returns (uint256);

    function borrow(address _to, uint256 _lendingAmount,uint256 _lendingInterest) external returns (uint256);

    function repayBorrow() external payable;

    function repayBorrow(uint256 _lendingAmount) external;

    function claimComp(address _comp, address _comptroller, address _to) external returns (uint256, bool);

    function getBalance() external view returns (uint256);

    function getBorrowRatePerBlock() external view returns (uint256);

    function claim() external returns(uint256);

    function migrate(address _newTreasuryFund, bool _setReward) external returns(uint256);

    function getReward(address _for) external;

}

interface ISupplyRewardFactory {

    function createReward(
        address _rewardToken,
        address _virtualBalance,
        address _owner
    ) external returns (address);

}// UNLICENSED
pragma solidity 0.6.12;


contract SupplyBooster is Initializable, ReentrancyGuard, ISupplyBooster {

    using Address for address payable;
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public supplyRewardFactory;
    address public virtualBalanceWrapperFactory;
    address public extraReward;
    uint256 public launchTime;
    uint256 public version;

    address payable public teamFeeAddress;
    address public lendingMarket;

    address public owner;
    address public governance;

    struct PoolInfo {
        address underlyToken;
        address rewardInterestPool;
        address supplyTreasuryFund;
        address virtualBalance;
        bool isErc20;
        bool shutdown;
    }

    enum LendingInfoState {
        NONE,
        LOCK,
        UNLOCK,
        LIQUIDATE
    }

    struct LendingInfo {
        uint256 pid;
        address user;
        address underlyToken;
        uint256 lendingAmount;
        uint256 borrowNumbers;
        uint256 startedBlock;
        LendingInfoState state;
    }

    address public constant ZERO_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 public constant MIN_INTEREST_PERCENT = 0;
    uint256 public constant MAX_INTEREST_PERCENT = 100;
    uint256 public constant FEE_PERCENT = 10;
    uint256 public constant PERCENT_DENOMINATOR = 100;

    PoolInfo[] public override poolInfo;

    uint256 public interestPercent;

    mapping(uint256 => uint256) public frozenTokens; /* pool id => amount */
    mapping(bytes32 => LendingInfo) public lendingInfos;
    mapping(uint256 => uint256) public interestTotal;

    event Deposited(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed pid, uint256 amount);

    event Borrow(
        address indexed user,
        uint256 indexed pid,
        bytes32 indexed lendingId,
        uint256 lendingAmount,
        uint256 lendingInterest,
        uint256 borrowNumbers
    );
    event RepayBorrow(
        bytes32 indexed lendingId,
        address indexed user,
        uint256 lendingAmount,
        uint256 lendingInterest,
        bool isErc20
    );
    event Liquidate(
        bytes32 indexed lendingId,
        uint256 lendingAmount,
        uint256 lendingInterest
    );
    event Initialized(address indexed thisAddress);
    event ToggleShutdownPool(uint256 pid, bool shutdown);
    event SetOwner(address owner);
    event SetGovernance(address governance);

    modifier onlyOwner() {

        require(owner == msg.sender, "SupplyBooster: caller is not the owner");
        _;
    }

    modifier onlyGovernance() {

        require(
            governance == msg.sender,
            "SupplyBooster: caller is not the governance"
        );
        _;
    }

    modifier onlyLendingMarket() {

        require(
            lendingMarket == msg.sender,
            " SupplyBooster: caller is not the lendingMarket"
        );

        _;
    }

    function setOwner(address _owner) public onlyOwner {

        owner = _owner;

        emit SetOwner(_owner);
    }

    function setGovernance(address _governance) public onlyOwner {

        governance = _governance;

        emit SetGovernance(_governance);
    }

    function setLendingMarket(address _v) public onlyOwner {

        require(_v != address(0), "!_v");

        lendingMarket = _v;
    }

    function setExtraReward(address _v) public onlyOwner {

        require(_v != address(0), "!_v");

        extraReward = _v;
    }

    function initialize(
        address _owner,
        address _virtualBalanceWrapperFactory,
        address _supplyRewardFactory,
        address payable _teamFeeAddress
    ) public initializer {

        owner = _owner;
        governance = _owner;
        virtualBalanceWrapperFactory = _virtualBalanceWrapperFactory;
        supplyRewardFactory = _supplyRewardFactory;
        teamFeeAddress = _teamFeeAddress;
        launchTime = block.timestamp;
        version = 1;
        interestPercent = 50;

        emit Initialized(address(this));
    }

    function addSupplyPool(address _underlyToken, address _supplyTreasuryFund)
        public
        override
        onlyGovernance
        returns (bool)
    {

        bool isErc20 = _underlyToken == ZERO_ADDRESS ? false : true;
        address virtualBalance = IVirtualBalanceWrapperFactory(
            virtualBalanceWrapperFactory
        ).createWrapper(address(this));

        ISupplyTreasuryFund(_supplyTreasuryFund).initialize(
            virtualBalance,
            _underlyToken,
            isErc20
        );

        address rewardInterestPool;

        if (isErc20) {
            rewardInterestPool = ISupplyRewardFactory(supplyRewardFactory)
                .createReward(_underlyToken, virtualBalance, address(this));
        } else {
            rewardInterestPool = ISupplyRewardFactory(supplyRewardFactory)
                .createReward(address(0), virtualBalance, address(this));
        }

        if (extraReward != address(0)) {
            ISupplyPoolExtraReward(extraReward).addExtraReward(
                poolInfo.length,
                _underlyToken,
                virtualBalance,
                isErc20
            );
        }

        poolInfo.push(
            PoolInfo({
                underlyToken: _underlyToken,
                rewardInterestPool: rewardInterestPool,
                supplyTreasuryFund: _supplyTreasuryFund,
                virtualBalance: virtualBalance,
                isErc20: isErc20,
                shutdown: false
            })
        );

        return true;
    }

    function updateSupplyTreasuryFund(
        uint256 _pid,
        address _supplyTreasuryFund,
        bool _setReward
    ) public onlyOwner nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 bal = ISupplyTreasuryFund(pool.supplyTreasuryFund).migrate(
            _supplyTreasuryFund,
            _setReward
        );

        ISupplyTreasuryFund(_supplyTreasuryFund).initialize(
            pool.virtualBalance,
            pool.underlyToken,
            pool.isErc20
        );

        pool.supplyTreasuryFund = _supplyTreasuryFund;

        if (pool.isErc20) {
            sendToken(pool.underlyToken, pool.supplyTreasuryFund, bal);

            ISupplyTreasuryFund(pool.supplyTreasuryFund).depositFor(
                address(0),
                bal
            );
        } else {
            ISupplyTreasuryFund(pool.supplyTreasuryFund).depositFor{value: bal}(
                address(0)
            );
        }
    }

    function toggleShutdownPool(uint256 _pid) public onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];

        pool.shutdown = !pool.shutdown;

        if (extraReward != address(0)) {
            ISupplyPoolExtraReward(extraReward).toggleShutdownPool(
                _pid,
                pool.shutdown
            );
        }

        emit ToggleShutdownPool(_pid, pool.shutdown);
    }

    function _deposit(uint256 _pid, uint256 _amount) internal nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];

        require(!pool.shutdown, "SupplyBooster: !shutdown");
        require(_amount > 0, "SupplyBooster: !_amount");

        if (!pool.isErc20) {
            require(
                msg.value == _amount,
                "SupplyBooster: !msg.value == _amount"
            );
        }

        if (pool.isErc20) {
            IERC20(pool.underlyToken).safeTransferFrom(
                msg.sender,
                pool.supplyTreasuryFund,
                _amount
            );

            ISupplyTreasuryFund(pool.supplyTreasuryFund).depositFor(
                msg.sender,
                _amount
            );
        } else {
            ISupplyTreasuryFund(pool.supplyTreasuryFund).depositFor{
                value: _amount
            }(msg.sender);
        }

        IBaseReward(pool.rewardInterestPool).stake(msg.sender);

        if (extraReward != address(0)) {
            ISupplyPoolExtraReward(extraReward).beforeStake(_pid, msg.sender);
        }

        IVirtualBalanceWrapper(pool.virtualBalance).stakeFor(
            msg.sender,
            _amount
        );

        if (extraReward != address(0)) {
            ISupplyPoolExtraReward(extraReward).afterStake(_pid, msg.sender);
        }

        emit Deposited(msg.sender, _pid, _amount);
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        _deposit(_pid, _amount);
    }

    function deposit(uint256 _pid) public payable {

        _deposit(_pid, msg.value);
    }

    function withdraw(uint256 _pid, uint256 _amount)
        public
        nonReentrant
        returns (bool)
    {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 depositAmount = IVirtualBalanceWrapper(pool.virtualBalance)
            .balanceOf(msg.sender);

        require(_amount <= depositAmount, "SupplyBooster: !depositAmount");

        IBaseReward(pool.rewardInterestPool).withdraw(msg.sender);

        ISupplyTreasuryFund(pool.supplyTreasuryFund).withdrawFor(
            msg.sender,
            _amount
        );

        if (extraReward != address(0)) {
            ISupplyPoolExtraReward(extraReward).beforeWithdraw(
                _pid,
                msg.sender
            );
        }

        IVirtualBalanceWrapper(pool.virtualBalance).withdrawFor(
            msg.sender,
            _amount
        );

        if (extraReward != address(0)) {
            ISupplyPoolExtraReward(extraReward).afterWithdraw(_pid, msg.sender);
        }

        emit Withdrawn(msg.sender, _pid, _amount);

        return true;
    }

    receive() external payable {}

    function claimTreasuryFunds() public nonReentrant {

        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (poolInfo[i].shutdown) {
                continue;
            }

            uint256 interest = ISupplyTreasuryFund(
                poolInfo[i].supplyTreasuryFund
            ).claim();

            if (interest > 0) {
                if (poolInfo[i].isErc20) {
                    sendToken(
                        poolInfo[i].underlyToken,
                        poolInfo[i].rewardInterestPool,
                        interest
                    );
                } else {
                    sendToken(
                        address(0),
                        poolInfo[i].rewardInterestPool,
                        interest
                    );
                }

                IBaseReward(poolInfo[i].rewardInterestPool).notifyRewardAmount(
                    interest
                );
            }
        }
    }

    function getRewards(uint256[] memory _pids) public nonReentrant {

        for (uint256 i = 0; i < _pids.length; i++) {
            PoolInfo storage pool = poolInfo[_pids[i]];

            if (pool.shutdown) continue;

            ISupplyTreasuryFund(pool.supplyTreasuryFund).getReward(msg.sender);

            if (IBaseReward(pool.rewardInterestPool).earned(msg.sender) > 0) {
                IBaseReward(pool.rewardInterestPool).getReward(msg.sender);
            }

            if (extraReward != address(0)) {
                ISupplyPoolExtraReward(extraReward).getRewards(
                    _pids[i],
                    msg.sender
                );
            }
        }
    }

    function setInterestPercent(uint256 _v) public onlyGovernance {

        require(
            _v >= MIN_INTEREST_PERCENT && _v <= MAX_INTEREST_PERCENT,
            "!_v"
        );

        interestPercent = _v;
    }

    function setTeamFeeAddress(address _v) public {

        require(msg.sender == teamFeeAddress, "!teamAddress");
        require(_v != address(0), "!_v");

        teamFeeAddress = payable(_v);
    }

    function calculateAmount(
        uint256 _bal,
        bool _fee,
        bool _interest,
        bool _extra
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 fee = _fee ? _bal.mul(FEE_PERCENT).div(PERCENT_DENOMINATOR) : 0;
        uint256 interest = _bal.sub(fee).mul(interestPercent).div(
            PERCENT_DENOMINATOR
        );
        uint256 extra = _bal.sub(fee).sub(interest);

        if (!_extra) extra = 0;
        if (!_interest) interest = 0;

        return (fee, interest, extra);
    }

    function sendToken(
        address _token,
        address _receiver,
        uint256 _amount
    ) internal {

        if (_token == address(0) || _token == ZERO_ADDRESS) {
            payable(_receiver).sendValue(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function sendBalanceEther(
        uint256 _pid,
        uint256 _bal,
        bool _fee,
        bool _interest,
        bool _extra
    ) internal {

        if (_bal == 0) return;

        PoolInfo storage pool = poolInfo[_pid];

        (uint256 fee, uint256 interest, uint256 extra) = calculateAmount(
            _bal,
            _fee,
            _interest,
            _extra
        );

        if (fee > 0) {
            sendToken(pool.underlyToken, teamFeeAddress, fee);
        }

        if (extraReward == address(0)) {
            interest = interest.add(extra);
        } else {
            ISupplyPoolExtraReward(extraReward).notifyRewardAmount{
                value: extra
            }(_pid, address(0), extra);
        }

        if (interest > 0) {
            sendToken(pool.underlyToken, pool.rewardInterestPool, interest);

            IBaseReward(pool.rewardInterestPool).notifyRewardAmount(interest);
        }
    }

    function sendBalanceErc20(
        uint256 _pid,
        uint256 _bal,
        bool _fee,
        bool _interest,
        bool _extra
    ) internal {

        if (_bal == 0) return;

        PoolInfo storage pool = poolInfo[_pid];

        (uint256 fee, uint256 interest, uint256 extra) = calculateAmount(
            _bal,
            _fee,
            _interest,
            _extra
        );

        if (fee > 0) {
            sendToken(pool.underlyToken, teamFeeAddress, fee);
        }

        if (extraReward == address(0)) {
            interest = interest.add(extra);
        } else {
            sendToken(pool.underlyToken, extraReward, extra);

            ISupplyPoolExtraReward(extraReward).notifyRewardAmount(
                _pid,
                pool.underlyToken,
                extra
            );
        }

        if (interest > 0) {
            sendToken(pool.underlyToken, pool.rewardInterestPool, interest);

            IBaseReward(pool.rewardInterestPool).notifyRewardAmount(interest);
        }
    }

    function borrow(
        uint256 _pid,
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest,
        uint256 _borrowNumbers
    ) public override onlyLendingMarket nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];

        require(!pool.shutdown, "SupplyBooster: !shutdown");

        ISupplyTreasuryFund(pool.supplyTreasuryFund).borrow(
            _user,
            _lendingAmount,
            _lendingInterest
        );

        frozenTokens[_pid] = frozenTokens[_pid].add(_lendingAmount);
        interestTotal[_pid] = interestTotal[_pid].add(_lendingInterest);

        LendingInfo memory lendingInfo;

        lendingInfo.pid = _pid;
        lendingInfo.user = _user;
        lendingInfo.underlyToken = pool.underlyToken;
        lendingInfo.lendingAmount = _lendingAmount;
        lendingInfo.borrowNumbers = _borrowNumbers;
        lendingInfo.startedBlock = block.number;
        lendingInfo.state = LendingInfoState.LOCK;

        lendingInfos[_lendingId] = lendingInfo;

        if (pool.isErc20) {
            sendBalanceErc20(
                lendingInfo.pid,
                _lendingInterest,
                true,
                true,
                true
            );
        } else {
            sendBalanceEther(
                lendingInfo.pid,
                _lendingInterest,
                true,
                true,
                true
            );
        }

        emit Borrow(
            _user,
            _pid,
            _lendingId,
            _lendingAmount,
            _lendingInterest,
            _borrowNumbers
        );
    }

    function _repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest
    ) internal nonReentrant {

        LendingInfo storage lendingInfo = lendingInfos[_lendingId];
        PoolInfo storage pool = poolInfo[lendingInfo.pid];

        require(
            lendingInfo.state == LendingInfoState.LOCK,
            "SupplyBooster: !LOCK"
        );
        require(
            _lendingAmount >= lendingInfo.lendingAmount,
            "SupplyBooster: !_lendingAmount"
        );

        frozenTokens[lendingInfo.pid] = frozenTokens[lendingInfo.pid].sub(
            lendingInfo.lendingAmount
        );
        interestTotal[lendingInfo.pid] = interestTotal[lendingInfo.pid].sub(
            _lendingInterest
        );

        if (pool.isErc20) {
            sendToken(
                pool.underlyToken,
                pool.supplyTreasuryFund,
                lendingInfo.lendingAmount
            );

            ISupplyTreasuryFund(pool.supplyTreasuryFund).repayBorrow(
                lendingInfo.lendingAmount
            );
        } else {
            ISupplyTreasuryFund(pool.supplyTreasuryFund).repayBorrow{
                value: lendingInfo.lendingAmount
            }();
        }

        lendingInfo.state = LendingInfoState.UNLOCK;

        emit RepayBorrow(
            _lendingId,
            _user,
            _lendingAmount,
            _lendingInterest,
            pool.isErc20
        );
    }

    function repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingInterest
    ) external payable override onlyLendingMarket {

        _repayBorrow(_lendingId, _user, msg.value, _lendingInterest);
    }

    function repayBorrow(
        bytes32 _lendingId,
        address _user,
        uint256 _lendingAmount,
        uint256 _lendingInterest
    ) external override onlyLendingMarket {

        _repayBorrow(_lendingId, _user, _lendingAmount, _lendingInterest);
    }

    function liquidate(bytes32 _lendingId, uint256 _lendingInterest)
        public
        payable
        override
        onlyLendingMarket
        nonReentrant
        returns (address)
    {

        LendingInfo storage lendingInfo = lendingInfos[_lendingId];
        PoolInfo storage pool = poolInfo[lendingInfo.pid];

        if (!pool.isErc20) {
            require(
                msg.value > 0,
                "SupplyBooster: msg.value must be greater than 0"
            );
        }

        require(
            lendingInfo.state == LendingInfoState.LOCK,
            "SupplyBooster: !LOCK"
        );

        frozenTokens[lendingInfo.pid] = frozenTokens[lendingInfo.pid].sub(
            lendingInfo.lendingAmount
        );
        interestTotal[lendingInfo.pid] = interestTotal[lendingInfo.pid].sub(
            _lendingInterest
        );

        if (pool.isErc20) {
            sendToken(
                pool.underlyToken,
                pool.supplyTreasuryFund,
                lendingInfo.lendingAmount
            );

            ISupplyTreasuryFund(pool.supplyTreasuryFund).repayBorrow(
                lendingInfo.lendingAmount
            );

            uint256 bal = IERC20(pool.underlyToken).balanceOf(address(this));

            sendBalanceErc20(lendingInfo.pid, bal, true, true, true);
        } else {
            ISupplyTreasuryFund(pool.supplyTreasuryFund).repayBorrow{
                value: lendingInfo.lendingAmount
            }();

            uint256 bal = address(this).balance;

            sendBalanceEther(lendingInfo.pid, bal, true, true, true);
        }

        lendingInfo.state = LendingInfoState.LIQUIDATE;

        emit Liquidate(_lendingId, lendingInfo.lendingAmount, _lendingInterest);
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function getUtilizationRate(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 currentBal = ISupplyTreasuryFund(pool.supplyTreasuryFund)
            .getBalance();

        if (currentBal.add(frozenTokens[_pid]) == 0) {
            return 0;
        }

        return
            frozenTokens[_pid].mul(1e18).div(
                currentBal.add(frozenTokens[_pid])
            );
    }

    function getBorrowRatePerBlock(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];

        return
            ISupplyTreasuryFund(pool.supplyTreasuryFund)
                .getBorrowRatePerBlock();
    }

    function getLendingUnderlyToken(bytes32 _lendingId)
        public
        view
        override
        returns (address)
    {

        LendingInfo storage lendingInfo = lendingInfos[_lendingId];

        return (lendingInfo.underlyToken);
    }
}