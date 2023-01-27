

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


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
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


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}


pragma solidity 0.5.17;



contract XDEX is ERC20, ERC20Detailed {

    address public core;

    event SET_CORE(address indexed core, address indexed _core);

    constructor() public ERC20Detailed("XDEFI Governance Token", "XDEX", 18) {
        core = msg.sender;
    }

    modifier onlyCore() {

        require(msg.sender == core, "Not Authorized");
        _;
    }

    function setCore(address _core) public onlyCore {

        emit SET_CORE(core, _core);
        core = _core;
    }

    function mint(address account, uint256 amount) public onlyCore {

        _mint(account, amount);
    }

    function burnForSelf(uint256 amount) external {

        _burn(msg.sender, amount);
    }
}


pragma solidity 0.5.17;

interface IXHalfLife {

    function createStream(
        address token,
        address recipient,
        uint256 depositAmount,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    ) external returns (uint256);


    function createEtherStream(
        address recipient,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    ) external payable returns (uint256);


    function hasStream(uint256 streamId) external view returns (bool);


    function getStream(uint256 streamId)
        external
        view
        returns (
            address sender,
            address recipient,
            address token,
            uint256 depositAmount,
            uint256 startBlock,
            uint256 kBlock,
            uint256 remaining,
            uint256 withdrawable,
            uint256 unlockRatio,
            uint256 lastRewardBlock,
            bool cancelable
        );


    function balanceOf(uint256 streamId)
        external
        view
        returns (uint256 withdrawable, uint256 remaining);


    function withdrawFromStream(uint256 streamId, uint256 amount)
        external
        returns (bool);


    function cancelStream(uint256 streamId) external returns (bool);


    function singleFundStream(uint256 streamId, uint256 amount)
        external
        payable
        returns (bool);


    function lazyFundStream(
        uint256 streamId,
        uint256 amount,
        uint256 blockHeightDiff
    ) external payable returns (bool);


    function getVersion() external pure returns (bytes32);

}


pragma solidity 0.5.17;




contract XdexStream is ReentrancyGuard {

    uint256 constant ONE = 10**18;

    address public xdex;
    address public xdexFarmMaster;

    IXHalfLife public halflife;

    struct LockStream {
        address depositor;
        bool isEntity;
        uint256 streamId;
    }

    uint256 private constant unlockRatio = 1;

    uint256 private constant unlockKBlocksV = 540;
    mapping(address => LockStream) private votingStreams;

    uint256 private constant unlockKBlocksN = 60;
    mapping(address => LockStream) private normalStreams;

    bool private constant cancelable = false;

    modifier lockStreamExists(address who, uint256 streamType) {

        bool found = false;
        if (streamType == 0) {
            found = votingStreams[who].isEntity;
        } else if (streamType == 1) {
            found = normalStreams[who].isEntity;
        }

        require(found, "the lock stream does not exist");
        _;
    }

    modifier validStreamType(uint256 streamType) {

        require(
            streamType == 0 || streamType == 1,
            "invalid stream type: 0 or 1"
        );
        _;
    }

    constructor(
        address _xdex,
        address _halfLife,
        address _farmMaster
    ) public {
        xdex = _xdex;
        halflife = IXHalfLife(_halfLife);
        xdexFarmMaster = _farmMaster;
    }

    function hasStream(address who)
        public
        view
        returns (bool hasVotingStream, bool hasNormalStream)
    {

        hasVotingStream = votingStreams[who].isEntity;
        hasNormalStream = normalStreams[who].isEntity;
    }

    function getStreamId(address who, uint256 streamType)
        public
        view
        lockStreamExists(who, streamType)
        returns (uint256 streamId)
    {

        if (streamType == 0) {
            return votingStreams[who].streamId;
        } else if (streamType == 1) {
            return normalStreams[who].streamId;
        }
    }

    function createStream(
        address recipient,
        uint256 depositAmount,
        uint256 streamType,
        uint256 startBlock
    )
        external
        nonReentrant
        validStreamType(streamType)
        returns (uint256 streamId)
    {

        require(msg.sender == xdexFarmMaster, "only farmMaster could create");
        require(recipient != address(0), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(depositAmount > 0, "depositAmount is zero");
        require(startBlock >= block.number, "start block before block.number");

        if (streamType == 0) {
            require(
                !(votingStreams[recipient].isEntity),
                "voting stream exists"
            );
        }
        if (streamType == 1) {
            require(
                !(normalStreams[recipient].isEntity),
                "normal stream exists"
            );
        }

        uint256 unlockKBlocks = unlockKBlocksN;
        if (streamType == 0) {
            unlockKBlocks = unlockKBlocksV;
        }

        IERC20(xdex).approve(address(halflife), depositAmount);

        IERC20(xdex).transferFrom(msg.sender, address(this), depositAmount);

        streamId = halflife.createStream(
            xdex,
            recipient,
            depositAmount,
            startBlock,
            unlockKBlocks,
            unlockRatio,
            cancelable
        );

        if (streamType == 0) {
            votingStreams[recipient] = LockStream({
                depositor: msg.sender,
                isEntity: true,
                streamId: streamId
            });
        } else if (streamType == 1) {
            normalStreams[recipient] = LockStream({
                depositor: msg.sender,
                isEntity: true,
                streamId: streamId
            });
        }
    }

    function fundsToStream(
        uint256 streamId,
        uint256 amount,
        uint256 blockHeightDiff
    ) public returns (bool result) {

        require(amount > 0, "amount is zero");

        IERC20(xdex).approve(address(halflife), amount);

        IERC20(xdex).transferFrom(msg.sender, address(this), amount);

        result = halflife.lazyFundStream(streamId, amount, blockHeightDiff);
    }
}


pragma solidity 0.5.17;







contract FarmMaster is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant ONE = 10**18;
    uint256 private constant StreamTypeVoting = 0;
    uint256 private constant StreamTypeNormal = 1;

    uint256 private constant LpTokenMinCount = 1;
    uint256 private constant LpTokenMaxCount = 8;

    uint256 private constant LpRewardFixDec = 1e12;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
    }

    struct LpTokenInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lpTokenType;
        uint256 lpFactor;
        uint256 lpAccPerShare; // Accumulated XDEX per share, times 1e12. See below.
        mapping(address => UserInfo) userInfo; // Info of each user that stakes LP tokens.
    }

    struct PoolInfo {
        LpTokenInfo[] LpTokenInfos;
        uint256 poolFactor; // How many allocation factor assigned to this pool. XDEX to distribute per block.
        uint256 lastRewardBlock; // Last block number that XDEX distribution occurs.
    }

    mapping(bytes32 => uint256) private lpIndexInPool;

    uint256[4] public bonusEndBlocks = [60000, 180000, 420000, 900000];

    uint256[5] public tokensPerBlock = [
        uint256(160 * ONE),
        uint256(80 * ONE),
        uint256(40 * ONE),
        uint256(20 * ONE),
        uint256(8 * ONE)
    ];

    uint256 public constant bonusFirstDeposit = 10 * ONE;

    address public core;
    XDEX public xdex;

    address public safu;

    mapping(address => bool) public claimableTokens;

    XdexStream public stream;

    uint256 public votingPoolId;

    uint256 public startBlock;

    PoolInfo[] public poolInfo;

    uint256 public totalXFactor = 0;

    event AddPool(
        uint256 indexed pid,
        address indexed lpToken,
        uint256 indexed lpType,
        uint256 lpFactor
    );

    event AddLP(
        uint256 indexed pid,
        address indexed lpToken,
        uint256 indexed lpType,
        uint256 lpFactor
    );

    event UpdateFactor(
        uint256 indexed pid,
        address indexed lpToken,
        uint256 lpFactor
    );

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        address indexed lpToken,
        uint256 amount
    );

    event Withdraw(
        address indexed user,
        uint256 indexed pid,
        address indexed lpToken,
        uint256 amount
    );

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        address indexed lpToken,
        uint256 amount
    );

    event Claim(
        address indexed to,
        address indexed token,
        uint256 indexed amount
    );

    event SetCore(address indexed _core, address indexed _coreNew);
    event SetStream(address indexed _stream, address indexed _streamNew);
    event SetVotingPool(uint256 indexed _pid);
    event SetSafu(address indexed safu, address indexed _safu);

    modifier onlyCore() {

        require(msg.sender == core, "Not authorized");
        _;
    }

    modifier poolExists(uint256 _pid) {

        require(_pid < poolInfo.length, "pool not exist");
        _;
    }

    constructor(
        XDEX _xdex,
        uint256 _startBlock,
        address _safu
    ) public {
        require(_safu != address(0), "ERR_ZERO_ADDRESS");

        xdex = _xdex;
        startBlock = _startBlock;
        core = msg.sender;
        safu = _safu;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function setVotingPool(uint256 _pid) external onlyCore {

        votingPoolId = _pid;
        emit SetVotingPool(_pid);
    }

    function setStream(address _stream) external onlyCore {

        require(_stream != address(0), "ERR_ZERO_ADDRESS");
        emit SetStream(address(stream), _stream);
        stream = XdexStream(_stream);
    }

    function setCore(address _core) external onlyCore {

        require(_core != address(0), "ERR_ZERO_ADDRESS");
        emit SetCore(core, _core);
        core = _core;
    }

    function setSafu(address _safu) external onlyCore {

        require(_safu != address(0), "ERR_ZERO_ADDRESS");
        emit SetSafu(safu, _safu);
        safu = _safu;
    }

    function addPool(
        IERC20 _lpToken,
        uint256 _lpTokenType,
        uint256 _lpFactor,
        bool _withUpdate
    ) external onlyCore {

        require(_lpFactor > 0, "Lp Token Factor is zero");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 _lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;

        totalXFactor = totalXFactor.add(_lpFactor);

        uint256 poolinfos_id = poolInfo.length++;
        poolInfo[poolinfos_id].poolFactor = _lpFactor;
        poolInfo[poolinfos_id].lastRewardBlock = _lastRewardBlock;
        poolInfo[poolinfos_id].LpTokenInfos.push(
            LpTokenInfo({
                lpToken: _lpToken,
                lpTokenType: _lpTokenType,
                lpFactor: _lpFactor,
                lpAccPerShare: 0
            })
        );
        lpIndexInPool[keccak256(abi.encodePacked(poolinfos_id, _lpToken))] = 1;
        emit AddPool(poolinfos_id, address(_lpToken), _lpTokenType, _lpFactor);
    }

    function addLpTokenToPool(
        uint256 _pid,
        IERC20 _lpToken,
        uint256 _lpTokenType,
        uint256 _lpFactor
    ) public onlyCore poolExists(_pid) {

        require(_lpFactor > 0, "Lp Token Factor is zero");

        massUpdatePools();

        PoolInfo memory pool = poolInfo[_pid];
        require(
            lpIndexInPool[keccak256(abi.encodePacked(_pid, _lpToken))] == 0,
            "lp token already added"
        );

        uint256 count = pool.LpTokenInfos.length;
        require(
            count >= LpTokenMinCount && count < LpTokenMaxCount,
            "pool lpToken length is bad"
        );

        totalXFactor = totalXFactor.add(_lpFactor);

        LpTokenInfo memory lpTokenInfo =
            LpTokenInfo({
                lpToken: _lpToken,
                lpTokenType: _lpTokenType,
                lpFactor: _lpFactor,
                lpAccPerShare: 0
            });
        poolInfo[_pid].poolFactor = pool.poolFactor.add(_lpFactor);
        poolInfo[_pid].LpTokenInfos.push(lpTokenInfo);

        lpIndexInPool[keccak256(abi.encodePacked(_pid, _lpToken))] = count + 1;

        emit AddLP(_pid, address(_lpToken), _lpTokenType, _lpFactor);
    }

    function getLpTokenInfosByPoolId(uint256 _pid)
        external
        view
        poolExists(_pid)
        returns (
            address[] memory lpTokens,
            uint256[] memory lpTokenTypes,
            uint256[] memory lpFactors,
            uint256[] memory lpAccPerShares
        )
    {

        PoolInfo memory pool = poolInfo[_pid];
        uint256 length = pool.LpTokenInfos.length;
        lpTokens = new address[](length);
        lpTokenTypes = new uint256[](length);
        lpFactors = new uint256[](length);
        lpAccPerShares = new uint256[](length);
        for (uint8 i = 0; i < length; i++) {
            lpTokens[i] = address(pool.LpTokenInfos[i].lpToken);
            lpTokenTypes[i] = pool.LpTokenInfos[i].lpTokenType;
            lpFactors[i] = pool.LpTokenInfos[i].lpFactor;
            lpAccPerShares[i] = pool.LpTokenInfos[i].lpAccPerShare;
        }
    }

    function setLpFactor(
        uint256 _pid,
        IERC20 _lpToken,
        uint256 _lpFactor,
        bool _withUpdate
    ) public onlyCore poolExists(_pid) {

        if (_withUpdate) {
            massUpdatePools();
        }

        PoolInfo storage pool = poolInfo[_pid];
        uint256 index = _getLpIndexInPool(_pid, _lpToken);
        uint256 poolFactorNew =
            pool.poolFactor.sub(pool.LpTokenInfos[index].lpFactor).add(
                _lpFactor
            );
        pool.LpTokenInfos[index].lpFactor = _lpFactor;

        totalXFactor = totalXFactor.sub(poolInfo[_pid].poolFactor).add(
            poolFactorNew
        );
        poolInfo[_pid].poolFactor = poolFactorNew;

        emit UpdateFactor(_pid, address(_lpToken), _lpFactor);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint8 pid = 0; pid < length; ++pid) {
            if (poolInfo[pid].poolFactor > 0) {
                updatePool(pid);
            }
        }
    }

    function updatePool(uint256 _pid) public poolExists(_pid) {

        if (block.number <= poolInfo[_pid].lastRewardBlock) {
            return;
        }

        if (poolInfo[_pid].poolFactor == 0 || totalXFactor == 0) {
            return;
        }

        PoolInfo storage pool = poolInfo[_pid];
        (uint256 poolReward, , ) =
            getXCountToReward(pool.lastRewardBlock, block.number);
        poolReward = poolReward.mul(pool.poolFactor).div(totalXFactor);

        uint256 totalLpSupply = 0;
        for (uint8 i = 0; i < pool.LpTokenInfos.length; i++) {
            LpTokenInfo memory lpInfo = pool.LpTokenInfos[i];
            uint256 lpSupply = lpInfo.lpToken.balanceOf(address(this));
            if (lpSupply == 0) {
                continue;
            }
            totalLpSupply = totalLpSupply.add(lpSupply);
            uint256 lpReward =
                poolReward.mul(lpInfo.lpFactor).div(pool.poolFactor);
            pool.LpTokenInfos[i].lpAccPerShare = lpInfo.lpAccPerShare.add(
                lpReward.mul(LpRewardFixDec).div(lpSupply)
            );
        }

        if (totalLpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        xdex.mint(address(this), poolReward);
        pool.lastRewardBlock = block.number;
    }

    function pendingXDEX(uint256 _pid, address _user)
        external
        view
        poolExists(_pid)
        returns (uint256)
    {

        PoolInfo memory pool = poolInfo[_pid];

        uint256 totalPending = 0;
        if (totalXFactor == 0 || pool.poolFactor == 0) {
            for (uint8 i = 0; i < pool.LpTokenInfos.length; i++) {
                UserInfo memory user =
                    poolInfo[_pid].LpTokenInfos[i].userInfo[_user];
                totalPending = totalPending.add(
                    user
                        .amount
                        .mul(pool.LpTokenInfos[i].lpAccPerShare)
                        .div(LpRewardFixDec)
                        .sub(user.rewardDebt)
                );
            }

            return totalPending;
        }

        (uint256 xdexReward, , ) =
            getXCountToReward(pool.lastRewardBlock, block.number);

        uint256 poolReward = xdexReward.mul(pool.poolFactor).div(totalXFactor);

        for (uint8 i = 0; i < pool.LpTokenInfos.length; i++) {
            LpTokenInfo memory lpInfo = pool.LpTokenInfos[i];
            uint256 lpSupply = lpInfo.lpToken.balanceOf(address(this));
            if (lpSupply == 0) {
                continue;
            }
            if (block.number > pool.lastRewardBlock) {
                uint256 lpReward =
                    poolReward.mul(lpInfo.lpFactor).div(pool.poolFactor);
                lpInfo.lpAccPerShare = lpInfo.lpAccPerShare.add(
                    lpReward.mul(LpRewardFixDec).div(lpSupply)
                );
            }
            UserInfo memory user =
                poolInfo[_pid].LpTokenInfos[i].userInfo[_user];
            totalPending = totalPending.add(
                user.amount.mul(lpInfo.lpAccPerShare).div(LpRewardFixDec).sub(
                    user.rewardDebt
                )
            );
        }

        return totalPending;
    }

    function deposit(
        uint256 _pid,
        IERC20 _lpToken,
        uint256 _amount
    ) external poolExists(_pid) {

        require(_amount > 0, "not valid amount");

        PoolInfo storage pool = poolInfo[_pid];
        uint256 index = _getLpIndexInPool(_pid, _lpToken);
        uint256 blockHeightDiff = block.number.sub(pool.lastRewardBlock);

        require(index < poolInfo[_pid].LpTokenInfos.length, "not valid index");

        updatePool(_pid);

        UserInfo storage user =
            poolInfo[_pid].LpTokenInfos[index].userInfo[msg.sender];

        if (user.amount > 0) {
            uint256 pending =
                user
                    .amount
                    .mul(pool.LpTokenInfos[index].lpAccPerShare)
                    .div(LpRewardFixDec)
                    .sub(user.rewardDebt);

            if (pending > 0) {
                (bool hasVotingStream, bool hasNormalStream) =
                    stream.hasStream(msg.sender);

                if (_pid == votingPoolId) {
                    if (hasVotingStream) {
                        uint256 streamId =
                            stream.getStreamId(msg.sender, StreamTypeVoting);
                        require(streamId > 0, "not valid stream id");

                        xdex.approve(address(stream), pending);
                        stream.fundsToStream(
                            streamId,
                            pending,
                            blockHeightDiff
                        );
                    }
                } else {
                    if (hasNormalStream) {
                        uint256 streamId =
                            stream.getStreamId(msg.sender, StreamTypeNormal);
                        require(streamId > 0, "not valid stream id");

                        xdex.approve(address(stream), pending);
                        stream.fundsToStream(
                            streamId,
                            pending,
                            blockHeightDiff
                        );
                    }
                }
            }
        } else {
            uint256 streamStart = block.number + 1;
            if (block.number < startBlock) {
                streamStart = startBlock;
            }

            (bool hasVotingStream, bool hasNormalStream) =
                stream.hasStream(msg.sender);

            if (_pid == votingPoolId) {
                if (!hasVotingStream) {
                    xdex.mint(address(this), bonusFirstDeposit);
                    xdex.approve(address(stream), bonusFirstDeposit);
                    stream.createStream(
                        msg.sender,
                        bonusFirstDeposit,
                        StreamTypeVoting,
                        streamStart
                    );
                }
            } else {
                if (!hasNormalStream) {
                    xdex.mint(address(this), bonusFirstDeposit);
                    xdex.approve(address(stream), bonusFirstDeposit);
                    stream.createStream(
                        msg.sender,
                        bonusFirstDeposit,
                        StreamTypeNormal,
                        streamStart
                    );
                }
            }
        }

        pool.LpTokenInfos[index].lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);

        user.rewardDebt = user
            .amount
            .mul(pool.LpTokenInfos[index].lpAccPerShare)
            .div(LpRewardFixDec);

        emit Deposit(msg.sender, _pid, address(_lpToken), _amount);
    }

    function withdraw(
        uint256 _pid,
        IERC20 _lpToken,
        uint256 _amount
    ) public poolExists(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 index = _getLpIndexInPool(_pid, _lpToken);
        require(index < poolInfo[_pid].LpTokenInfos.length, "not valid index");
        uint256 blockHeightDiff = block.number.sub(pool.lastRewardBlock);

        updatePool(_pid);

        UserInfo storage user =
            poolInfo[_pid].LpTokenInfos[index].userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: _amount not good");

        uint256 pending =
            user
                .amount
                .mul(pool.LpTokenInfos[index].lpAccPerShare)
                .div(LpRewardFixDec)
                .sub(user.rewardDebt);

        if (pending > 0) {
            (bool hasVotingStream, bool hasNormalStream) =
                stream.hasStream(msg.sender);

            xdex.approve(address(stream), pending);

            if (_pid == votingPoolId) {
                if (hasVotingStream) {
                    uint256 streamId =
                        stream.getStreamId(msg.sender, StreamTypeVoting);
                    require(streamId > 0, "not valid stream id");

                    xdex.approve(address(stream), pending);
                    stream.fundsToStream(streamId, pending, blockHeightDiff);
                }
            } else {
                if (hasNormalStream) {
                    uint256 streamId =
                        stream.getStreamId(msg.sender, StreamTypeNormal);
                    require(streamId > 0, "not valid stream id");

                    xdex.approve(address(stream), pending);
                    stream.fundsToStream(streamId, pending, blockHeightDiff);
                }
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.LpTokenInfos[index].lpToken.safeTransfer(
                address(msg.sender),
                _amount
            );
        }
        user.rewardDebt = user
            .amount
            .mul(pool.LpTokenInfos[index].lpAccPerShare)
            .div(LpRewardFixDec);

        emit Withdraw(msg.sender, _pid, address(_lpToken), _amount);
    }

    function emergencyWithdraw(uint256 _pid)
        external
        nonReentrant
        poolExists(_pid)
    {

        PoolInfo storage pool = poolInfo[_pid];

        for (uint8 i = 0; i < pool.LpTokenInfos.length; i++) {
            LpTokenInfo storage lpInfo = pool.LpTokenInfos[i];
            UserInfo storage user = lpInfo.userInfo[msg.sender];

            if (user.amount > 0) {
                lpInfo.lpToken.safeTransfer(address(msg.sender), user.amount);

                emit EmergencyWithdraw(
                    msg.sender,
                    _pid,
                    address(lpInfo.lpToken),
                    user.amount
                );
                user.amount = 0;
                user.rewardDebt = 0;
            }
        }
    }

    function batchCollectReward(uint256 _pid) external poolExists(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 length = pool.LpTokenInfos.length;

        for (uint8 i = 0; i < length; i++) {
            IERC20 lpToken = pool.LpTokenInfos[i].lpToken;
            UserInfo storage user = pool.LpTokenInfos[i].userInfo[msg.sender];
            if (user.amount > 0) {
                withdraw(_pid, lpToken, 0);
            }
        }
    }

    function getUserLpAmounts(uint256 _pid, address _user)
        external
        view
        poolExists(_pid)
        returns (address[] memory lpTokens, uint256[] memory amounts)
    {

        PoolInfo memory pool = poolInfo[_pid];
        uint256 length = pool.LpTokenInfos.length;
        lpTokens = new address[](length);
        amounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            lpTokens[i] = address(pool.LpTokenInfos[i].lpToken);
            UserInfo memory user =
                poolInfo[_pid].LpTokenInfos[i].userInfo[_user];
            amounts[i] = user.amount;
        }
    }

    function getXCountToReward(uint256 _from, uint256 _to)
        public
        view
        returns (
            uint256 _totalReward,
            uint256 _stageFrom,
            uint256 _stageTo
        )
    {

        require(_from <= _to, "_from must <= _to");

        uint256 stageFrom = 0;
        uint256 stageTo = 0;

        if (_to < startBlock) {
            return (0, stageFrom, stageTo);
        }

        if (
            _from >= startBlock.add(bonusEndBlocks[bonusEndBlocks.length - 1])
        ) {
            return (
                _to.sub(_from).mul(tokensPerBlock[tokensPerBlock.length - 1]),
                bonusEndBlocks.length + 1,
                bonusEndBlocks.length + 1
            );
        }

        uint256 total = 0;

        for (uint256 i = 0; i < bonusEndBlocks.length; i++) {
            uint256 actualEndBlock = startBlock.add(bonusEndBlocks[i]);
            if (_from > actualEndBlock) {
                stageFrom = stageFrom.add(1);
            }
            if (_to > actualEndBlock) {
                stageTo = stageTo.add(1);
            }
        }

        uint256 tStageFrom = stageFrom;
        while (_from < _to) {
            if (_from < startBlock) {
                _from = startBlock;
            }
            uint256 indexDiff = stageTo.sub(tStageFrom);
            if (indexDiff == 0) {
                total += (_to - _from) * tokensPerBlock[tStageFrom];
                _from = _to;
                break;
            } else if (indexDiff > 0) {
                uint256 actualRes = startBlock.add(bonusEndBlocks[tStageFrom]);
                total += (actualRes - _from) * tokensPerBlock[tStageFrom];
                _from = actualRes;
                tStageFrom = tStageFrom.add(1);
            } else {
                break;
            }
        }

        return (total, stageFrom, stageTo);
    }

    function getCurRewardPerBlock() external view returns (uint256) {

        uint256 bnum = block.number;
        if (bnum < startBlock) {
            return 0;
        }
        if (bnum >= startBlock.add(bonusEndBlocks[bonusEndBlocks.length - 1])) {
            return tokensPerBlock[tokensPerBlock.length - 1];
        }
        uint256 stage = 0;
        for (uint256 i = 0; i < bonusEndBlocks.length; i++) {
            uint256 actualEndBlock = startBlock.add(bonusEndBlocks[i]);
            if (bnum >= actualEndBlock) {
                stage = stage.add(1);
            }
        }

        require(
            stage >= 0 && stage < tokensPerBlock.length,
            "tokensPerBlock length not good"
        );
        return tokensPerBlock[stage];
    }

    function claimRewards(address token, uint256 amount) external onlyCore {

        require(claimableTokens[token], "not claimable token");

        IERC20(token).safeTransfer(safu, amount);
        emit Claim(core, token, amount);
    }

    function updateClaimableTokens(address token, bool claimable)
        external
        onlyCore
    {

        claimableTokens[token] = claimable;
    }

    function _getLpIndexInPool(uint256 _pid, IERC20 _lpToken)
        internal
        view
        returns (uint256)
    {

        uint256 index =
            lpIndexInPool[keccak256(abi.encodePacked(_pid, _lpToken))];
        require(index > 0, "deposit the lp token which not exist");
        return --index;
    }
}