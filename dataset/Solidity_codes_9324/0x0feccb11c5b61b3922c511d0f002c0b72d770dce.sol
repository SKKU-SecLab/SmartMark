

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract DelegationStorage {

    address public implementation;
}

abstract contract DelegatorInterface is DelegationStorage {
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public virtual;
}

abstract contract DelegateInterface is DelegationStorage {
    function _becomeImplementation(bytes memory data) public virtual;

    function _resignImplementation() public virtual;
}



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
}




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
}




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
}




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
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}



pragma solidity 0.6.12;



contract ActivityBase is Ownable{

    using SafeMath for uint256;

    address public admin;
    
    address public marketingFund;
    address public WETHToken;
    uint256 public constant INVITEE_WEIGHT = 20; 
    uint256 public constant INVITOR_WEIGHT = 10;

    uint256 public startBlock;

    uint256 public userDividendWeight;
    uint256 public devDividendWeight;
    address public developerDAOFund;

    uint256 public amountFeeRateNumerator;
    uint256 public amountfeeRateDenominator;

    uint256 public contractFeeRateNumerator;
    uint256 public contractFeeRateDenominator;

    mapping (uint256 => mapping (address => bool)) public isUserContractSender;
    mapping (uint256 => uint256) public poolTokenAmountLimit;

    function setDividendWeight(uint256 _userDividendWeight, uint256 _devDividendWeight) public virtual{

        checkAdmin();
        require(
            _userDividendWeight != 0 && _devDividendWeight != 0,
            "invalid input"
        );
        userDividendWeight = _userDividendWeight;
        devDividendWeight = _devDividendWeight;
    }

    function setDeveloperDAOFund(address _developerDAOFund) public virtual onlyOwner {

        developerDAOFund = _developerDAOFund;
    }

    function setTokenAmountLimit(uint256 _pid, uint256 _tokenAmountLimit) public virtual {

        checkAdmin();
        poolTokenAmountLimit[_pid] = _tokenAmountLimit;
    }

    function setTokenAmountLimitFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) public virtual {

        checkAdmin();
        require(
            _feeRateDenominator >= _feeRateNumerator, "invalid input"
        );
        amountFeeRateNumerator = _feeRateNumerator;
        amountfeeRateDenominator = _feeRateDenominator;
    }

    function setContracSenderFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) public virtual {

        checkAdmin();
        require(
            _feeRateDenominator >= _feeRateNumerator, "invalid input"
        );
        contractFeeRateNumerator = _feeRateNumerator;
        contractFeeRateDenominator = _feeRateDenominator;
    }

    function setStartBlock(uint256 _startBlock) public virtual onlyOwner { 

        require(startBlock > block.number, "invalid start block");
        startBlock = _startBlock;
        updateAfterModifyStartBlock(_startBlock);
    }

    function transferAdmin(address _admin) public virtual {

        checkAdmin();
        admin = _admin;
    }

    function setMarketingFund(address _marketingFund) public virtual onlyOwner {

        marketingFund = _marketingFund;
    }

    function updateAfterModifyStartBlock(uint256 _newStartBlock) internal virtual{

    }

    function calculateDividend(uint256 _pending, uint256 _pid, uint256 _userAmount, bool _isContractSender) internal view returns (uint256 _marketingFundDividend, uint256 _devDividend, uint256 _userDividend){

        uint256 fee = 0;
        if(_isContractSender && contractFeeRateDenominator > 0){
            fee = _pending.mul(contractFeeRateNumerator).div(contractFeeRateDenominator);
            _marketingFundDividend = _marketingFundDividend.add(fee);
            _pending = _pending.sub(fee);
        }
        if(poolTokenAmountLimit[_pid] > 0 && amountfeeRateDenominator > 0 && _userAmount >= poolTokenAmountLimit[_pid]){
            fee = _pending.mul(amountFeeRateNumerator).div(amountfeeRateDenominator);
            _marketingFundDividend =_marketingFundDividend.add(fee);
            _pending = _pending.sub(fee);
        }
        if(devDividendWeight > 0){
            fee = _pending.mul(devDividendWeight).div(devDividendWeight.add(userDividendWeight));
            _devDividend = _devDividend.add(fee);
            _pending = _pending.sub(fee);
        }
        _userDividend = _pending;
    }

    function judgeContractSender(uint256 _pid) internal {

        if(msg.sender != tx.origin){
            isUserContractSender[_pid][msg.sender] = true;
        }
    }

    function checkAdmin() internal view {

        require(admin == msg.sender, "invalid authorized");
    }
}


pragma solidity 0.6.12;

interface IInvitation{


    function acceptInvitation(address _invitor) external;


    function getInvitation(address _sender) external view returns(address _invitor, address[] memory _invitees, bool _isWithdrawn);

    
}



pragma solidity 0.6.12;








contract MarketingMining is ActivityBase{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How much token the user has provided.
        uint256 originWeight; //initial weight
        uint256 modifiedWeight; //take the invitation relationship into consideration.
        uint256 revenue;
        uint256 userDividend;
        uint256 devDividend;
        uint256 marketingFundDividend;
        uint256 rewardDebt; // Reward debt. See explanation below.
        bool withdrawnState;
        bool isUsed;
    }

    struct PoolInfo {
        uint256 tokenAmount;  // lock amount
        IERC20 token;   // uniswapPair contract
        uint256 allocPoint;
        uint256 accumulativeDividend;
        uint256 lastDividendHeight;  // last dividend block height
        uint256 accShardPerWeight;
        uint256 totalWeight;
    }

    uint256 public constant BONUS_MULTIPLIER = 10;
    IERC20 public SHARD;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (uint256 => mapping (address => uint256)) public userInviteeTotalAmount; // total invitee weight
    PoolInfo[] public poolInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public SHDPerBlock = 1045 * (1e16);

    IInvitation public invitation;

    uint256 public bonusEndBlock;
    uint256 public totalAvailableDividend;
    
    bool public isInitialized;
    bool public isDepositAvailable;
    bool public isRevenueWithdrawable;

    event AddPool(uint256 indexed pid, address tokenAddress);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 weight);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    function initialize(
        IERC20 _SHARD,
        IInvitation _invitation,
        uint256 _bonusEndBlock,
        uint256 _startBlock, 
        uint256 _SHDPerBlock,
        address _developerDAOFund,
        address _marketingFund,
        address _weth
    ) public virtual onlyOwner{

        require(!isInitialized, "contract has been initialized");
        invitation = _invitation;
        bonusEndBlock = _bonusEndBlock;
        if (_startBlock < block.number) {
            startBlock = block.number;
        } else {
            startBlock = _startBlock;
        }
        SHARD = _SHARD;
        developerDAOFund = _developerDAOFund;
        marketingFund = _marketingFund;
        WETHToken = _weth;
        if(_SHDPerBlock > 0){
            SHDPerBlock = _SHDPerBlock;
        }
        userDividendWeight = 4;
        devDividendWeight = 1;

        amountFeeRateNumerator = 1;
        amountfeeRateDenominator = 5;

        contractFeeRateNumerator = 1;
        contractFeeRateDenominator = 5;
        isDepositAvailable = true;
        isRevenueWithdrawable = false;
        isInitialized = true;
    }

    function add(uint256 _allocPoint, IERC20 _tokenAddress, bool _withUpdate) public virtual {

        checkAdmin();
        if(_withUpdate){
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        PoolInfo memory newpool = PoolInfo({
            token: _tokenAddress, 
            tokenAmount: 0,
            allocPoint: _allocPoint,
            lastDividendHeight: lastRewardBlock,
            accumulativeDividend: 0,
            accShardPerWeight: 0,
            totalWeight: 0
        });
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(newpool);
        emit AddPool(poolInfo.length.sub(1), address(_tokenAddress));
    }

    function setAllocationPoint(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public virtual {

        checkAdmin();
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setSHDPerBlock(uint256 _SHDPerBlock, bool _withUpdate) public virtual {

        checkAdmin();
        if (_withUpdate) {
            massUpdatePools();
        }
        SHDPerBlock = _SHDPerBlock;
    }

    function setIsDepositAvailable(bool _isDepositAvailable) public virtual onlyOwner {

        isDepositAvailable = _isDepositAvailable;
    }

    function setIsRevenueWithdrawable(bool _isRevenueWithdrawable) public virtual onlyOwner {

        isRevenueWithdrawable = _isRevenueWithdrawable;
    }

    function massUpdatePools() public virtual {

        uint256 poolCount = poolInfo.length;
        for(uint256 i = 0; i < poolCount; i ++){
            updatePoolDividend(i);
        }
    }

    function addAvailableDividend(uint256 _amount, bool _withUpdate) public virtual {

        if(_withUpdate){
            massUpdatePools();
        }
        SHARD.safeTransferFrom(address(msg.sender), address(this), _amount);
        totalAvailableDividend = totalAvailableDividend.add(_amount);
    }

    function updatePoolDividend(uint256 _pid) public virtual {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastDividendHeight) {
            return;
        }
        if (pool.tokenAmount == 0) {
            pool.lastDividendHeight = block.number;
            return;
        }
        uint256 availableDividend = totalAvailableDividend;
        uint256 multiplier = getMultiplier(pool.lastDividendHeight, block.number);
        uint256 producedToken = multiplier.mul(SHDPerBlock);
        producedToken = availableDividend > producedToken? producedToken: availableDividend;
        if(totalAllocPoint > 0){
            uint256 poolDevidend = producedToken.mul(pool.allocPoint).div(totalAllocPoint);
            if(poolDevidend > 0){
                totalAvailableDividend = totalAvailableDividend.sub(poolDevidend);
                pool.accumulativeDividend = pool.accumulativeDividend.add(poolDevidend);
                pool.accShardPerWeight = pool.accShardPerWeight.add(poolDevidend.mul(1e12).div(pool.totalWeight));
            } 
        }
        pool.lastDividendHeight = block.number;
    }

    function depositETH(uint256 _pid) external payable virtual {

        require(address(poolInfo[_pid].token) == WETHToken, "invalid token");
        updateAfterDeposit(_pid, msg.value);
    }

    function withdrawETH(uint256 _pid, uint256 _amount) external virtual {

        require(address(poolInfo[_pid].token) == WETHToken, "invalid token");
        updateAfterwithdraw(_pid, _amount);
        if(_amount > 0){
            (bool success, ) = msg.sender.call{value: _amount}(new bytes(0));
            require(success, "Transfer: ETH_TRANSFER_FAILED");
        }
    }

    function updateAfterDeposit(uint256 _pid, uint256 _amount) internal{

        require(isDepositAvailable, "new invest is forbidden");
        require(_amount > 0, "invalid amount");
        (address invitor, , bool isWithdrawn) = invitation.getInvitation(msg.sender);
        require(invitor != address(0), "should be accept invitation firstly");
        updatePoolDividend(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        UserInfo storage userInvitor = userInfo[_pid][invitor];
        uint256 existedAmount = user.amount;
        bool withdrawnState = user.withdrawnState;
        if(!user.isUsed){
            user.isUsed = true;
            judgeContractSender(_pid);
            withdrawnState = isWithdrawn;
        }
        if(!withdrawnState && userInvitor.amount > 0){
            updateUserRevenue(userInvitor, pool);
        }
        if(!withdrawnState){
            updateInvitorWeight(msg.sender, invitor, _pid, true, _amount, isWithdrawn, withdrawnState);
        }

        if(existedAmount > 0){ 
            updateUserRevenue(user, pool);
        }

        updateUserWeight(msg.sender, _pid, true, _amount, isWithdrawn);
        if(!withdrawnState && userInvitor.amount > 0){
            userInvitor.rewardDebt = userInvitor.modifiedWeight.mul(pool.accShardPerWeight).div(1e12);
        }  
        if(!withdrawnState){
            user.withdrawnState = isWithdrawn;
        }
        user.amount = existedAmount.add(_amount);
        user.rewardDebt = user.modifiedWeight.mul(pool.accShardPerWeight).div(1e12);
        pool.tokenAmount = pool.tokenAmount.add(_amount);
        emit Deposit(msg.sender, _pid, _amount, user.modifiedWeight);
    }

    function deposit(uint256 _pid, uint256 _amount) public virtual {

        require(address(poolInfo[_pid].token) != WETHToken, "invalid pid");
        IERC20(poolInfo[_pid].token).safeTransferFrom(address(msg.sender), address(this), _amount);
        updateAfterDeposit(_pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public virtual {

        require(address(poolInfo[_pid].token) != WETHToken, "invalid pid");
        IERC20(poolInfo[_pid].token).safeTransfer(address(msg.sender), _amount);
        updateAfterwithdraw(_pid, _amount);
    }

    function updateAfterwithdraw(uint256 _pid, uint256 _amount) internal {

        (address invitor, , bool isWithdrawn) = invitation.getInvitation(msg.sender);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        bool withdrawnState = user.withdrawnState;
        uint256 existedAmount = user.amount;
        require(existedAmount >= _amount, "withdraw: not good");
        updatePoolDividend(_pid);
        uint256 pending = updateUserRevenue(user, pool);
        UserInfo storage userInvitor = userInfo[_pid][invitor];
        if(!withdrawnState && userInvitor.amount > 0){
            updateUserRevenue(userInvitor, pool);
        }
        if(!withdrawnState){
            updateInvitorWeight(msg.sender, invitor, _pid, false, _amount, isWithdrawn, withdrawnState);
        }
        updateUserWeight(msg.sender, _pid, false, _amount, isWithdrawn);
        user.amount = existedAmount.sub(_amount);
        user.rewardDebt = user.modifiedWeight.mul(pool.accShardPerWeight).div(1e12);
        user.withdrawnState = isWithdrawn;
        if(!withdrawnState && userInvitor.amount > 0){
            userInvitor.rewardDebt = userInvitor.modifiedWeight.mul(pool.accShardPerWeight).div(1e12);
        }
        pool.tokenAmount = pool.tokenAmount.sub(_amount);
        user.revenue = 0;
        bool isContractSender = isUserContractSender[_pid][msg.sender];
        (uint256 marketingFundDividend, uint256 devDividend, uint256 userDividend) = calculateDividend(pending, _pid, existedAmount, isContractSender);
        user.userDividend = user.userDividend.add(userDividend);
        user.devDividend = user.devDividend.add(devDividend);
        if(marketingFundDividend > 0){
            user.marketingFundDividend = user.marketingFundDividend.add(marketingFundDividend);
        }
        if(isRevenueWithdrawable){
            devDividend = user.devDividend;
            userDividend = user.userDividend;
            marketingFundDividend = user.marketingFundDividend;
            if(devDividend > 0){
                safeSHARDTransfer(developerDAOFund, devDividend);
            }
            if(userDividend > 0){
                safeSHARDTransfer(msg.sender, userDividend);
            }
            if(marketingFundDividend > 0){
                safeSHARDTransfer(marketingFund, marketingFundDividend);
            }
            user.devDividend = 0;
            user.userDividend = 0;
            user.marketingFundDividend = 0;
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function safeSHARDTransfer(address _to, uint256 _amount) internal {

        uint256 SHARDBal = SHARD.balanceOf(address(this));
        if (_amount > SHARDBal) {
            SHARD.transfer(_to, SHARDBal);
        } else {
            SHARD.transfer(_to, _amount);
        }
    }

    function getMultiplier(uint256 _from, uint256 _to) public view virtual returns (uint256) {

        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    function pendingSHARD(uint256 _pid, address _user) external view virtual 
    returns (uint256 _pending, uint256 _potential, uint256 _blockNumber) {

        _blockNumber = block.number;
        (_pending, _potential) = calculatePendingSHARD(_pid, _user);
    }

    function pendingSHARDByPids(uint256[] memory _pids, address _user) external view virtual
    returns (uint256[] memory _pending, uint256[] memory _potential, uint256 _blockNumber){

        uint256 poolCount = _pids.length;
        _pending = new uint256[](poolCount);
        _potential = new uint256[](poolCount);
        _blockNumber = block.number;
        for(uint i = 0; i < poolCount; i ++){
            (_pending[i], _potential[i]) = calculatePendingSHARD(_pids[i], _user);
        }
    } 

    function calculatePendingSHARD(uint256 _pid, address _user) private view returns (uint256 _pending, uint256 _potential) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accShardPerWeight = pool.accShardPerWeight;
        _pending = user.modifiedWeight.mul(accShardPerWeight).div(1e12).sub(user.rewardDebt).add(user.revenue);
        bool isContractSender = isUserContractSender[_pid][_user];
        _potential = _pending;
        (,,_pending) = calculateDividend(_pending, _pid, user.amount, isContractSender);
        _pending = _pending.add(user.userDividend);
        uint256 lpSupply = pool.tokenAmount;
        if (block.number > pool.lastDividendHeight && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastDividendHeight, block.number);
            uint256 totalUnupdateToken = multiplier.mul(SHDPerBlock);
            totalUnupdateToken = totalAvailableDividend > totalUnupdateToken? totalUnupdateToken: totalAvailableDividend;
            uint256 shardReward = totalUnupdateToken.mul(pool.allocPoint).div(totalAllocPoint);
            accShardPerWeight = accShardPerWeight.add(shardReward.mul(1e12).div(pool.totalWeight));
        }
        _potential = user.modifiedWeight.mul(accShardPerWeight).div(1e12).sub(user.rewardDebt).add(user.revenue).sub(_potential);
        (,,_potential) = calculateDividend(_potential, _pid, user.amount, isContractSender);
    }

    function getDepositWeight(uint256 _amount) public pure returns(uint256 weight){

        return _amount;
    }

    function getPoolLength() public view virtual returns(uint256){

        return poolInfo.length;
    }

    function getPoolInfo(uint256 _pid) public view virtual returns(uint256 _allocPoint, uint256 _accumulativeDividend, uint256 _usersTotalWeight, uint256 _tokenAmount, address _tokenAddress, uint256 _accs){

        PoolInfo storage pool = poolInfo[_pid];
        _allocPoint = pool.allocPoint;
        _accumulativeDividend = pool.accumulativeDividend;
        _usersTotalWeight = pool.totalWeight;
        _tokenAmount = pool.tokenAmount;
        _tokenAddress = address(pool.token);
        _accs = pool.accShardPerWeight;
    }

    function getPagePoolInfo(uint256 _fromIndex, uint256 _toIndex) public view virtual
    returns(uint256[] memory _allocPoint, uint256[] memory _accumulativeDividend, uint256[] memory _usersTotalWeight, uint256[] memory _tokenAmount, 
    address[] memory _tokenAddress, uint256[] memory _accs){

        uint256 poolCount = _toIndex.sub(_fromIndex).add(1);
        _allocPoint = new uint256[](poolCount);
        _accumulativeDividend = new uint256[](poolCount);
        _usersTotalWeight = new uint256[](poolCount);
        _tokenAmount = new uint256[](poolCount);
        _tokenAddress = new address[](poolCount);
        _accs = new uint256[](poolCount);
        uint256 startIndex = 0;
        for(uint i = _fromIndex; i <= _toIndex; i ++){
            PoolInfo storage pool = poolInfo[i];
            _allocPoint[startIndex] = pool.allocPoint;
            _accumulativeDividend[startIndex] = pool.accumulativeDividend;
            _usersTotalWeight[startIndex] = pool.totalWeight;
            _tokenAmount[startIndex] = pool.tokenAmount;
            _tokenAddress[startIndex] = address(pool.token);
            _accs[startIndex] = pool.accShardPerWeight;
            startIndex ++;
        }
    }

    function getUserInfoByPids(uint256[] memory _pids, address _user) public virtual view 
    returns(uint256[] memory _amount, uint256[] memory _modifiedWeight, uint256[] memory _revenue, uint256[] memory _userDividend, uint256[] memory _rewardDebt) {

        uint256 poolCount = _pids.length;
        _amount = new uint256[](poolCount);
        _modifiedWeight = new uint256[](poolCount);
        _revenue = new uint256[](poolCount);
        _userDividend = new uint256[](poolCount);
        _rewardDebt = new uint256[](poolCount);
        for(uint i = 0; i < poolCount; i ++){
            UserInfo storage user = userInfo[_pids[i]][_user];
            _amount[i] = user.amount;
            _modifiedWeight[i] = user.modifiedWeight;
            _revenue[i] = user.revenue;
            _userDividend[i] = user.userDividend;
            _rewardDebt[i] = user.rewardDebt;
        }
    }

    function updateUserRevenue(UserInfo storage _user, PoolInfo storage _pool) private returns (uint256){

        uint256 pending = _user.modifiedWeight.mul(_pool.accShardPerWeight).div(1e12).sub(_user.rewardDebt);
        _user.revenue = _user.revenue.add(pending);
        _pool.accumulativeDividend = _pool.accumulativeDividend.sub(pending);
        return _user.revenue;
    }

    function updateInvitorWeight(address _sender, address _invitor, uint256 _pid, bool _isAddAmount, uint256 _amount, bool _isWithdrawn, bool _withdrawnState) private {

        UserInfo storage user = userInfo[_pid][_sender];
        uint256 subInviteeAmount = 0;
        uint256 addInviteeAmount = 0;
        if(user.amount > 0  && !_withdrawnState){
            subInviteeAmount = user.originWeight;
        }
        if(!_isWithdrawn){
            if(_isAddAmount){
                addInviteeAmount = getDepositWeight(user.amount.add(_amount));
            }
            else{ 
                addInviteeAmount = getDepositWeight(user.amount.sub(_amount));
            }
        }

        UserInfo storage invitor = userInfo[_pid][_invitor];
        PoolInfo storage pool = poolInfo[_pid];
        uint256 inviteeAmountOfUserInvitor = userInviteeTotalAmount[_pid][_invitor];
        uint256 newInviteeAmountOfUserInvitor = inviteeAmountOfUserInvitor.add(addInviteeAmount).sub(subInviteeAmount);
        userInviteeTotalAmount[_pid][_invitor] = newInviteeAmountOfUserInvitor;
        if(invitor.amount > 0){
            invitor.modifiedWeight = invitor.modifiedWeight.add(newInviteeAmountOfUserInvitor.div(INVITEE_WEIGHT))
                                                                   .sub(inviteeAmountOfUserInvitor.div(INVITEE_WEIGHT));
            pool.totalWeight = pool.totalWeight.add(newInviteeAmountOfUserInvitor.div(INVITEE_WEIGHT))
                                               .sub(inviteeAmountOfUserInvitor.div(INVITEE_WEIGHT));                              
        }
    }

    function updateUserWeight(address _user, uint256 _pid, bool _isAddAmount, uint256 _amount, bool _isWithdrawn) private {

        UserInfo storage user = userInfo[_pid][_user];
        uint256 userOriginModifiedWeight = user.modifiedWeight;
        uint256 userNewModifiedWeight;
        if(_isAddAmount){
            userNewModifiedWeight = getDepositWeight(_amount.add(user.amount));
        }
        else{
            userNewModifiedWeight = getDepositWeight(user.amount.sub(_amount));
        }
        user.originWeight = userNewModifiedWeight;
        if(!_isWithdrawn){
            userNewModifiedWeight = userNewModifiedWeight.add(userNewModifiedWeight.div(INVITOR_WEIGHT));
        }
        uint256 inviteeAmountOfUser = userInviteeTotalAmount[_pid][msg.sender];
        userNewModifiedWeight = userNewModifiedWeight.add(inviteeAmountOfUser.div(INVITEE_WEIGHT));
        user.modifiedWeight = userNewModifiedWeight;
        PoolInfo storage pool = poolInfo[_pid];
        pool.totalWeight = pool.totalWeight.add(userNewModifiedWeight).sub(userOriginModifiedWeight);
    }

    function updateAfterModifyStartBlock(uint256 _newStartBlock) internal override{

        uint256 poolLenght = poolInfo.length;
        for(uint256 i = 0; i < poolLenght; i++){
            PoolInfo storage info = poolInfo[i];
            info.lastDividendHeight = _newStartBlock;
        }
    }
}



pragma solidity 0.6.12;




contract MarketingMiningDelegator is DelegatorInterface, MarketingMining {

    constructor(
        address _SHARD,
        address _invitation,
        uint256 _bonusEndBlock,
        uint256 _startBlock,
        uint256 _shardPerBlock,
        address _developerDAOFund,
        address _marketingFund,
        address _weth,
        address implementation_,
        bytes memory becomeImplementationData
    ) public {
        delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,address,uint256,uint256,uint256,address,address,address)",
                _SHARD,
                _invitation,
                _bonusEndBlock,
                _startBlock,
                _shardPerBlock,
                _developerDAOFund,
                _marketingFund,
                _weth
            )
        );
        admin = msg.sender;
        _setImplementation(implementation_, false, becomeImplementationData);
    }

    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public override {

        checkAdmin();
        if (allowResign) {
            delegateToImplementation(
                abi.encodeWithSignature("_resignImplementation()")
            );
        }

        address oldImplementation = implementation;
        implementation = implementation_;

        delegateToImplementation(
            abi.encodeWithSignature(
                "_becomeImplementation(bytes)",
                becomeImplementationData
            )
        );

        emit NewImplementation(oldImplementation, implementation);
    }

    function delegateTo(address callee, bytes memory data)
        internal
        returns (bytes memory)
    {

        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return returnData;
    }

    function delegateToImplementation(bytes memory data)
        public
        returns (bytes memory)
    {

        return delegateTo(implementation, data);
    }

    function delegateToViewImplementation(bytes memory data)
        public
        view
        returns (bytes memory)
    {

        (bool success, bytes memory returnData) =
            address(this).staticcall(
                abi.encodeWithSignature("delegateToImplementation(bytes)", data)
            );
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return abi.decode(returnData, (bytes));
    }

    fallback() external payable {
        if (msg.value > 0) return;
        (bool success, ) = implementation.delegatecall(msg.data);
        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())
            switch success
                case 0 {
                    revert(free_mem_ptr, returndatasize())
                }
                default {
                    return(free_mem_ptr, returndatasize())
                }
        }
    }

    
    function add(
        uint256 _allocPoint,
        IERC20 _tokenAddress,
        bool _isUpdate
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "add(uint256,address,bool)",
                _allocPoint,
                _tokenAddress,
                _isUpdate
            )
        );
    }

    function setAllocationPoint(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setAllocationPoint(uint256,uint256,bool)",
                _pid,
                _allocPoint,
                _withUpdate
            )
        );
    }

    function setSHDPerBlock(uint256 _shardPerBlock, bool _withUpdate) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setSHDPerBlock(uint256,bool)",
                _shardPerBlock,
                _withUpdate
            )
        );
    }

    function setIsDepositAvailable(bool _isDepositAvailable) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setIsDepositAvailable(bool)",
                _isDepositAvailable
            )
        );
    }

    function setIsRevenueWithdrawable(bool _isRevenueWithdrawable) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setIsRevenueWithdrawable(bool)",
                _isRevenueWithdrawable
            )
        );
    }

    function setStartBlock(
        uint256 _startBlock
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setStartBlock(uint256)",
                _startBlock
            )
        );
    }

    function massUpdatePools() public override {

        delegateToImplementation(abi.encodeWithSignature("massUpdatePools()"));
    }

    function addAvailableDividend(uint256 _amount, bool _isUpdate) public override {

        delegateToImplementation(
            abi.encodeWithSignature("addAvailableDividend(uint256,bool)", _amount, _isUpdate)
        );
    }

    function updatePoolDividend(uint256 _pid) public override {

        delegateToImplementation(
            abi.encodeWithSignature("updatePoolDividend(uint256)", _pid)
        );
    }

    function depositETH(
        uint256 _pid
    ) external payable override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "depositETH(uint256)",
                _pid
            )
        );
    }

    function deposit(
        uint256 _pid,
        uint256 _amount
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "deposit(uint256,uint256)",
                _pid,
                _amount
            )
        );
    }

    function withdraw(uint256 _pid, uint256 _amount) public override {

        delegateToImplementation(
            abi.encodeWithSignature("withdraw(uint256,uint256)", _pid, _amount)
        );
    }

    function withdrawETH(uint256 _pid, uint256 _amount) external override {

        delegateToImplementation(
            abi.encodeWithSignature("withdrawETH(uint256,uint256)", _pid, _amount)
        );
    }

    function setDeveloperDAOFund(
    address _developer
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setDeveloperDAOFund(address)",
                _developer
            )
        );
    }

    function setDividendWeight(
        uint256 _userDividendWeight,
        uint256 _devDividendWeight
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setDividendWeight(uint256,uint256)",
                _userDividendWeight,
                _devDividendWeight
            )
        );
    }

    function setTokenAmountLimit(
        uint256 _pid, 
        uint256 _tokenAmountLimit
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setTokenAmountLimit(uint256,uint256)",
                _pid,
                _tokenAmountLimit
            )
        );
    }


    function setTokenAmountLimitFeeRate(
        uint256 _feeRateNumerator,
        uint256 _feeRateDenominator
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setTokenAmountLimitFeeRate(uint256,uint256)",
                _feeRateNumerator,
                _feeRateDenominator
            )
        );
    }

    function setContracSenderFeeRate(
        uint256 _feeRateNumerator,
        uint256 _feeRateDenominator
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setContracSenderFeeRate(uint256,uint256)",
                _feeRateNumerator,
                _feeRateDenominator
            )
        );
    }

    function transferAdmin(
        address _admin
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "transferAdmin(address)",
                _admin
            )
        );
    }

    function setMarketingFund(
        address _marketingFund
    ) public override {

        delegateToImplementation(
            abi.encodeWithSignature(
                "setMarketingFund(address)",
                _marketingFund
            )
        );
    }

    function pendingSHARD(uint256 _pid, address _user)
        external
        view
        override
        returns (uint256, uint256, uint256)
    {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "pendingSHARD(uint256,address)",
                    _pid,
                    _user
                )
            );
        return abi.decode(data, (uint256, uint256, uint256));
    }

    function pendingSHARDByPids(uint256[] memory _pids, address _user)
        external
        view
        override
        returns (uint256[] memory _pending, uint256[] memory _potential, uint256 _blockNumber)
    {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "pendingSHARDByPids(uint256[],address)",
                    _pids,
                    _user
                )
            );
        return abi.decode(data, (uint256[], uint256[], uint256));
    }

    function getPoolLength() public view override returns (uint256) {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getPoolLength()")
            );
        return abi.decode(data, (uint256));
    }

    function getMultiplier(uint256 _from, uint256 _to) public view override returns (uint256) {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature("getMultiplier(uint256,uint256)", _from, _to)
            );
        return abi.decode(data, (uint256));
    }

    function getPoolInfo(uint256 _pid) 
        public 
        view 
        override
        returns(
            uint256 _allocPoint,
            uint256 _accumulativeDividend, 
            uint256 _usersTotalWeight, 
            uint256 _tokenAmount, 
            address _tokenAddress, 
            uint256 _accs)
    {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "getPoolInfo(uint256)",
                    _pid
                )
            );
            return
            abi.decode(
                data,
                (
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    address,
                    uint256
                )
            );
    }

    function getPagePoolInfo(uint256 _fromIndex, uint256 _toIndex)
        public
        view
        override
        returns (
            uint256[] memory _allocPoint,
            uint256[] memory _accumulativeDividend, 
            uint256[] memory _usersTotalWeight, 
            uint256[] memory _tokenAmount, 
            address[] memory _tokenAddress, 
            uint256[] memory _accs
        )
    {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "getPagePoolInfo(uint256,uint256)",
                    _fromIndex,
                    _toIndex
                )
            );
        return
            abi.decode(
                data,
                (
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[],
                    address[],
                    uint256[]
                )
            );
    }

    function getUserInfoByPids(uint256[] memory _pids,  address _user)
        public
        view
        override
        returns (
            uint256[] memory _amount,
            uint256[] memory _modifiedWeight, 
            uint256[] memory _revenue, 
            uint256[] memory _userDividend, 
            uint256[] memory _rewardDebt
        )
    {

        bytes memory data =
            delegateToViewImplementation(
                abi.encodeWithSignature(
                    "getUserInfoByPids(uint256[],address)",
                    _pids,
                    _user
                )
            );
        return
            abi.decode(
                data,
                (
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[],
                    uint256[]
                )
            );
    }
}