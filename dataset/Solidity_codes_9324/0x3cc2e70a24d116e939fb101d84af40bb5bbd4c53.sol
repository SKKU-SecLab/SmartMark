pragma solidity ^0.8.7;


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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
}


interface IMyobu is IERC20 {

    event DAOChanged(address newDAOContract);
    event MyobuSwapChanged(address newMyobuSwap);

    function DAO() external view returns (address); // solhint-disable-line


    function myobuSwap() external view returns (address);


    event TaxAddressChanged(address newTaxAddress);
    event TaxedTransferAddedFor(address[] addresses);
    event TaxedTransferRemovedFor(address[] addresses);

    event FeesTaken(uint256 teamFee);
    event FeesChanged(Fees newFees);

    struct Fees {
        uint256 impact;
        uint256 buyFee;
        uint256 sellFee;
        uint256 transferFee;
    }

    function currentFees() external view returns (Fees memory);


    struct LiquidityETHParams {
        address pair;
        address to;
        uint256 amountTokenOrLP;
        uint256 amountTokenMin;
        uint256 amountETHMin;
        uint256 deadline;
    }

    event LiquidityAddedETH(
        address pair,
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function noFeeAddLiquidityETH(LiquidityETHParams calldata params)
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );



    function taxedPair(address pair) external view returns (bool);

} 
interface IRewardToken is IERC20 {


function mint(uint256 amount) external returns(bool);


}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;


}

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


  
contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}

interface INFT is IERC721 {

	function getMultiplierForTokenID(uint256 _tokenID) external view returns (uint256);

}
interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract MyobuChef is Ownable, ReentrancyGuard, ERC721Holder {

    using SafeERC20 for IERC20;
	
    struct UserInfo {
        uint16 boostPointsBP;	    // The NFT multiplier. 
        uint16 lockTimeBoost;          // the lock time boost, max is x3
        uint32 lockedUntil;         // lock end in UNIX seconds, used to compute the lockTimeBoost
        uint96 claimableRWT;
		uint96 claimableETH;
        uint112 amount;             // How many LP tokens the user has provided.
        uint112 weightedBalance;    // amount * boostPointsBP * lockTimeBoost
        uint112 rewardDebt;		    // Reward debt. See explanation below.
		uint112 ETHrewardDebt;
        address[] NFTContracts;         // Trackers for NFT tokens staked 
        uint[] NFTTokenIDs;              
    }
    struct PoolInfo {
        IERC20 lpToken;             // Address of LP token contract.
        uint64 allocPoint;          // How many allocation points assigned to this pool. EGGs to distribute per block.
        uint64 lastRewardBlock;     // Last block number that rewards distribution occurs.
        uint112 accRwtPerShare;     // Accumulated RWTs per share, times 1e12.
        uint112 accETHPerShare;     // Accumulated ETH rewards  per share, times 1e12. 
		uint112 weightedBalance;    // The total of all weightedBalances from users. 
    }

  
    IMyobu public Myobu;
	IRewardToken public rwt;
	address public router;
	address public WETH;
	address public ETHBank;
	mapping (address => bool) public isNFTContract;
    uint256 public rwtPerBlock;
	uint256 public ETHPerBlock;
	uint256 public ETHLeftUnshared;
	uint256 public ETHLeftUnclaimed;
    uint256 public numdays;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;
    uint256 public startBlock;
	bool public tokenReleased;
	bool public isEmergency;
	event RewardTokenSet(address indexed tokenAddress, uint256 indexed rwtPerBlock, uint256 timestamp);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdateEmissionRate(address indexed user, uint256 rwtPerBlock);
	event NFTStaked(address indexed user, address indexed NFTContract, uint256 tokenID);
	event NFTWithdrawn(address indexed user, address indexed NFTContract, uint256 tokenID);
	event TokensLocked(address indexed user, uint256 timestamp, uint256 lockTime);
	event Emergency(uint256 timestamp, bool ifEmergency);
    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {

        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }
    
    modifier onlyEmergency {

        require(isEmergency == true, "onlyEmergency: Emergency use only!");
        _;
    }
    mapping(address => bool) public authorized;
    modifier onlyAuthorized {

        require(authorized[msg.sender] == true, "onlyAuthorized: address not authorized");
        _;
    }
    constructor(
        IMyobu _myo,
		address _router
    ) {
        Myobu = _myo;
        router = _router;
		WETH = IUniswapV2Router02(router).WETH();
		startBlock = type(uint256).max;
        numdays = 1;
    }

	function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {

        return (_to - _from);
    }

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256, uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 userWeightedAmount = user.weightedBalance;
        uint256 accRwtPerShare = pool.accRwtPerShare;
        uint256 accETHPerShare = pool.accETHPerShare;
        uint256 weightedBalance = pool.weightedBalance;
        uint256 PendingRWT;
        uint256 PendingETH;
        if (block.number > pool.lastRewardBlock && weightedBalance != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 rwtReward = multiplier * rwtPerBlock * pool.allocPoint / totalAllocPoint;
            accRwtPerShare = accRwtPerShare + rwtReward * 1e12 / weightedBalance;
            uint256 ETHReward = multiplier * ETHPerBlock * pool.allocPoint / totalAllocPoint;
            accETHPerShare = accETHPerShare + ETHReward * 1e12 / weightedBalance;
            PendingRWT = (userWeightedAmount * accRwtPerShare / 1e12) - user.rewardDebt + user.claimableRWT;
            PendingETH = (userWeightedAmount * accETHPerShare / 1e12) - user.ETHrewardDebt + user.claimableETH;
        }
        return(PendingRWT, PendingETH);
    }


    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    
    fallback() external payable {
        ETHLeftUnshared += msg.value;
        updateETHRewards();
    }
    receive() external payable {
        require(msg.sender != ETHBank);
    }
    
    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.weightedBalance;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = uint64(block.number);
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if(tokenReleased) {
            uint256 rwtReward = multiplier * rwtPerBlock * pool.allocPoint / totalAllocPoint;
            pool.accRwtPerShare = uint112(pool.accRwtPerShare + rwtReward * 1e12 / lpSupply);
        }
        uint256 ETHReward = multiplier * ETHPerBlock * pool.allocPoint / totalAllocPoint;
        ETHLeftUnclaimed = ETHLeftUnclaimed + ETHReward;
        ETHLeftUnshared = ETHLeftUnshared - ETHReward;
        pool.accETHPerShare = uint112(pool.accETHPerShare + ETHReward * 1e12 / lpSupply);
        pool.lastRewardBlock = uint64(block.number);
    }

    function deposit(uint256 _pid, uint256 _amount, uint256 lockTime) public nonReentrant {

        _deposit(msg.sender, _pid, _amount, lockTime);
    }
    function withdraw(uint32 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.lockedUntil < block.timestamp, "withdraw: Tokens locked, if you're trying to claim your rewards use the deposit function");
        require(user.amount >= _amount && _amount > 0, "withdraw: not good");
        updatePool(_pid);
        if (user.weightedBalance > 0){
            _addToClaimable(_pid, msg.sender);
            if(tokenReleased) {
                if (user.claimableRWT > 0) {
                    safeRWTTransfer(msg.sender, user.claimableRWT);
                    user.claimableRWT = 0;
                }
            }
            if (user.claimableETH > 0) { 
                safeETHTransfer(msg.sender, user.claimableETH);
                user.claimableETH = 0;
            }
        }
        user.amount = uint112(user.amount - _amount);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        updateUserWeightedBalance(_pid, msg.sender);

        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function emergencyWithdraw(uint256 _pid) public nonReentrant onlyEmergency {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        pool.weightedBalance -= user.weightedBalance;
        user.amount = 0;
        user.weightedBalance = 0;
        user.ETHrewardDebt = 0;
        user.rewardDebt = 0;
        user.claimableETH = 0;
        user.claimableRWT = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }
	
	
    
    function addLiquidityNoFeeAndStake(uint256 amountTokensIn, uint256 amountETHMin, uint256 amountTokenMin, uint256 lockTime) public payable nonReentrant {

        IMyobu.LiquidityETHParams memory params;
        UserInfo storage user = userInfo[0][msg.sender];
        require(msg.value > 0);
        require((lockTime >= 604800 && lockTime <= 31449600 && user.lockedUntil <= lockTime + block.timestamp) || (lockTime == 0 && user.lockedUntil >= block.timestamp), "addLiquidityNoFeeAndStake : Can't lock tokens for less than 1 week");
        updatePool(0);
        if (user.weightedBalance > 0) {
            _addToClaimable(0, msg.sender);
        }
        Myobu.transferFrom(msg.sender, address(this), amountTokensIn);
        params.pair = address(poolInfo[0].lpToken);
        params.to = address(this);
        params.amountTokenMin = amountTokenMin;
        params.amountETHMin = amountETHMin;
        params.amountTokenOrLP = amountTokensIn;
        params.deadline = block.timestamp;
        (,uint256 ETHUsed ,uint256 numLiquidityAdded) = Myobu.noFeeAddLiquidityETH{value: msg.value}(params);
        payable(msg.sender).transfer(msg.value - ETHUsed);
        user.amount += uint112(numLiquidityAdded);
        if (lockTime > 0) {
            lockTokens(msg.sender, 0, lockTime);
        }
        else {
            updateUserWeightedBalance(0, msg.sender);
        }
		emit Deposit(msg.sender, 0, numLiquidityAdded);
    }
    
    function reinvestETHRewards(uint256 amountOutMin) public nonReentrant {

            UserInfo storage user = userInfo[1][msg.sender];
            require(user.lockedUntil >= block.timestamp);
            updatePool(1);
            uint256 ETHPending = (user.weightedBalance * poolInfo[1].accETHPerShare / 1e12) - user.ETHrewardDebt + user.claimableETH;
            require(ETHPending > 0);
            address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = address(Myobu);
            if(ETHPending > ETHLeftUnclaimed) {
                ETHPending = ETHLeftUnclaimed;
            }
            uint256 balanceBefore = Myobu.balanceOf(address(this));
            IUniswapV2Router02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ETHPending}(
            amountOutMin,
            path,
            address(this),
            block.timestamp
            );
            uint256 amountSwapped = Myobu.balanceOf(address(this)) - balanceBefore;
            user.amount += uint112(amountSwapped);
            user.claimableETH = 0;
            updateUserWeightedBalance(1, msg.sender);
            emit Deposit(msg.sender, 1, amountSwapped);
    }
    
    function buyAndStakeETH(uint256 amountOutMin, uint256 lockTime) public payable nonReentrant{

        UserInfo storage user = userInfo[1][msg.sender];
        require(msg.value > 0);
        require((lockTime >= 604800 && lockTime <= 31449600 && user.lockedUntil <= lockTime + block.timestamp) || (lockTime == 0 && user.lockedUntil >= block.timestamp), "buyAndStakeETH : Can't lock tokens for less than 1 week");
        updatePool(1);
        if (user.weightedBalance > 0) {
            _addToClaimable(1, msg.sender);
        }
        uint256 balanceBefore = Myobu.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(Myobu);
        IUniswapV2Router02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            block.timestamp
        );
        uint256 _amount = Myobu.balanceOf(address(this)) - balanceBefore;
        user.amount = uint112(user.amount + _amount);
        if (lockTime > 0){
            lockTokens(msg.sender, 1, lockTime);
        }
        else {
            updateUserWeightedBalance(1, msg.sender);
        }
        emit Deposit(msg.sender, 1, _amount);
    }

	function withdrawNFT(uint256 _pid, address NFTContract, uint tokenID) public nonReentrant {

        address sender = msg.sender;
		uint256 NFTIndex;
        bool tokenFound;
        uint length = userInfo[_pid][sender].NFTContracts.length;
        updatePool(_pid);
        _addToClaimable(_pid, sender);
        for (uint i; i < userInfo[_pid][sender].NFTContracts.length; i++) {
            if (userInfo[_pid][sender].NFTContracts[i] == NFTContract) {
                if(userInfo[_pid][sender].NFTTokenIDs[i] == tokenID) {
                tokenFound = true;
                NFTIndex = i;
				break;
				}
            }
		}
        require(tokenFound == true, "withdrawNFT, token not found");
		userInfo[_pid][sender].boostPointsBP -= uint16(INFT(NFTContract).getMultiplierForTokenID(tokenID));
		userInfo[_pid][sender].NFTContracts[NFTIndex] = userInfo[_pid][sender].NFTContracts[length -1];
		userInfo[_pid][sender].NFTContracts.pop();
		userInfo[_pid][sender].NFTTokenIDs[NFTIndex] = userInfo[_pid][sender].NFTTokenIDs[length -1];
		userInfo[_pid][sender].NFTTokenIDs.pop();
		updateUserWeightedBalance(_pid, sender);
		INFT(NFTContract).safeTransferFrom(address(this), sender, tokenID);
			emit NFTWithdrawn(sender, NFTContract, tokenID);
    }

    function boostWithNFT(uint256 _pid, address NFTContract, uint tokenID) public nonReentrant {

        require(msg.sender == tx.origin, "boostWithNFT : no contracts"); 
        require(isNFTContract[NFTContract], "boostWithNFT: incorrect contract address");
        require(userInfo[_pid][msg.sender].lockedUntil >= block.timestamp);
        updatePool(_pid);
        _addToClaimable(_pid, msg.sender);
        INFT(NFTContract).safeTransferFrom(msg.sender, address(this), tokenID);
        userInfo[_pid][msg.sender].NFTContracts.push(NFTContract);
		userInfo[_pid][msg.sender].NFTTokenIDs.push(tokenID);
        userInfo[_pid][msg.sender].boostPointsBP += uint16(INFT(NFTContract).getMultiplierForTokenID(tokenID));
        updateUserWeightedBalance(_pid, msg.sender);
		emit NFTWithdrawn(msg.sender, NFTContract, tokenID);
    }
    
    function addToClaimable(uint256 _pid, address sender) public nonReentrant {

        require(userInfo[_pid][sender].lockedUntil >= block.timestamp);
        updatePool(_pid);
        _addToClaimable(_pid, sender);
    }


    function depositFor(address sender, uint256 _pid, uint256 amount, uint256 lockTime) public onlyAuthorized {

        _deposit(sender, _pid, amount, lockTime);
    }
    function add(uint64 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner nonDuplicated(_lpToken) {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint64 lastRewardBlock = uint64(block.number > startBlock ? block.number : startBlock);
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
        lpToken : _lpToken,
        allocPoint : _allocPoint,
        lastRewardBlock : lastRewardBlock,
        accRwtPerShare : 0,
        accETHPerShare : 0,
        weightedBalance : 0
        }));
    }
	function addNFTContract(address NFTcontract) public onlyOwner {

		isNFTContract[NFTcontract] = true;
	}
	
	function setETHBank(address _ETHBank) public onlyOwner {

	    ETHBank = _ETHBank;
	}

    function setRouter(address _router) public onlyOwner {

        router = _router;
    }
	
    function rescueToken(address tokenAddress) public onlyOwner {

        require((tokenAddress != address(rwt)) && !poolExistence[IERC20(tokenAddress)], "rescueToken : wrong token address");
        uint256 bal = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, bal);
    }

    function set(uint256 _pid, uint64 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint ;
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    function startRewards() public onlyOwner {

        require(startBlock > block.number, "startRewards: rewards already started");
        startBlock = block.number;
        for (uint i; i < poolInfo.length; i++) {
            poolInfo[i].lastRewardBlock = uint64(block.number);            
        }
    }
    function updateEmissionRate(uint256 _rwtPerBlock) public onlyOwner {

        require(tokenReleased == true, "updateEmissionRate: Reward token not set");
		massUpdatePools();
        rwtPerBlock = _rwtPerBlock;
        emit UpdateEmissionRate(msg.sender, _rwtPerBlock);
    }
    function setRewardToken(address _RWT, uint _rwtPerBlock) public onlyOwner {

        require(tokenReleased == false, "Reward token already set");
        rwt = IRewardToken(_RWT);
        rwtPerBlock = _rwtPerBlock;
		tokenReleased = true;
        emit RewardTokenSet(_RWT, _rwtPerBlock, block.timestamp);
    }
    
    function emergency(bool _isEmergency) public onlyOwner {

        isEmergency = _isEmergency;
        emit Emergency(block.timestamp, _isEmergency);
    }
    function authorize(address _address) public onlyOwner {

        authorized[_address] = true;
    }
    function unauthorize(address _address) public onlyOwner {

        authorized[_address] = false;
    }
    function setnumdays(uint256 _days) public onlyOwner {

        require(_days > 0 && _days < 14);
        numdays = _days;
    }
    

    function _deposit(address sender, uint256 _pid, uint256 _amount, uint256 lockTime) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][sender];
        updatePool(_pid);
        if (user.weightedBalance > 0) {
            if (_amount == 0 && lockTime == 0) {
                if(tokenReleased) {
                    uint256 pending = (user.weightedBalance * pool.accRwtPerShare / 1e12) - user.rewardDebt + user.claimableRWT;
                    if (pending > 0) {
                        safeRWTTransfer(sender, pending);
                    }
                    user.rewardDebt = user.weightedBalance * pool.accRwtPerShare / 1e12;
                }
                uint256 ETHPending = (user.weightedBalance * pool.accETHPerShare / 1e12) - user.ETHrewardDebt + user.claimableETH;
                if (ETHPending > 0) { 
                    safeETHTransfer(sender, ETHPending);
                    user.ETHrewardDebt = user.weightedBalance * pool.accETHPerShare / 1e12;

                }
                user.claimableRWT = 0;
                user.claimableETH = 0;
            }
            else {
                _addToClaimable(_pid, sender);
            }
        }
        if (_amount > 0) {
            require((lockTime >= 604800 && lockTime <= 31449600 && user.lockedUntil <= lockTime + block.timestamp) || (lockTime == 0 && user.lockedUntil >= block.timestamp), "deposit : Can't lock tokens for less than 1 week");
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = uint112(user.amount + _amount);
            if (lockTime == 0) {
                updateUserWeightedBalance(_pid, sender);
            }
        }
		if (lockTime > 0) {
		    lockTokens(sender, _pid, lockTime);
		}
		if (user.lockedUntil < block.timestamp) {
		    updateUserWeightedBalance(_pid, sender);
		}
        emit Deposit(sender, _pid, _amount);
    }
    
    function lockTokens(address sender, uint256 _pid, uint256 lockTime) internal {

        UserInfo storage user = userInfo[_pid][sender]; 
        require(user.amount > 0, "lockTokens: No tokens to lock"); 
        require(user.lockedUntil <= block.timestamp + lockTime, "lockTokens: Tokens already locked");
        require(lockTime >= 604800, "lockTokens: Lock time too short");
        require(lockTime <= 31449600, "lockTokens: Lock time too long");
        user.lockedUntil = uint32(block.timestamp + lockTime);
        user.lockTimeBoost = uint16(2 * 1000 * (lockTime-604800) / 30844800); // 0 - 2000 
        updateUserWeightedBalance(_pid, sender);
		emit TokensLocked(sender, block.timestamp, lockTime);
    }
    
	function updateUserWeightedBalance(uint256 _pid, address _user) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
		uint256 poolBalance = pool.weightedBalance - user.weightedBalance;
		if (user.lockedUntil < block.timestamp) {
		    user.weightedBalance = 0;
		    user.lockTimeBoost = 0;
		}
		else {
            user.weightedBalance = user.amount * (1000 + user.lockTimeBoost) * (1000 + user.boostPointsBP) / 1000000;
        }
        pool.weightedBalance = uint112(poolBalance + user.weightedBalance);
		user.rewardDebt = user.weightedBalance * pool.accRwtPerShare / 1e12;
		user.ETHrewardDebt = user.weightedBalance * pool.accETHPerShare / 1e12;
    }
    
    function updateETHRewards() internal {

        ETHPerBlock = ETHLeftUnshared / (6400 * numdays);
        massUpdatePools();
    }
    
    function _addToClaimable(uint256 _pid, address sender) internal {

        UserInfo storage user = userInfo[_pid][sender];
        PoolInfo storage pool = poolInfo[_pid];
        if(tokenReleased) {
                uint256 pending = (user.weightedBalance * pool.accRwtPerShare / 1e12) - user.rewardDebt;
                if (pending > 0) {
                    user.claimableRWT += uint96(pending);
                    user.rewardDebt = user.weightedBalance * pool.accRwtPerShare / 1e12;
                }
            }
            uint256 ETHPending = (user.weightedBalance * pool.accETHPerShare / 1e12) - user.ETHrewardDebt;
            if (ETHPending > 0) { 
                user.claimableETH += uint96(ETHPending);
                user.ETHrewardDebt = user.weightedBalance * pool.accETHPerShare / 1e12;
            }
    }

    function safeRWTTransfer(address _to, uint256 _amount) internal {

        uint256 rwtBal = rwt.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > rwtBal) {
            transferSuccess = rwt.transfer(_to, rwtBal);
        } else {
            transferSuccess = rwt.transfer(_to, _amount);
        }
        require(transferSuccess, "safeRWTTransfer: transfer failed");
    }
    function safeETHTransfer(address _to, uint256 _amount) internal {

        if (_amount > ETHLeftUnclaimed) {
            _amount = ETHLeftUnclaimed;
        }
            payable(_to).transfer(_amount);
            ETHLeftUnclaimed-= _amount;
    }
}