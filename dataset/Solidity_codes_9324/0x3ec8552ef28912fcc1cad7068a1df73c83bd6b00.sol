
pragma solidity >=0.6.0;

interface IPoolFactory {

    function createNewPool(
        address _rewardToken,
        address _rover,
        uint256 _duration,
        address _distributor
    ) external returns (address);

}



pragma solidity >=0.6.0;

interface IBasedGod {

    function getSellingSchedule() external view returns (uint256);

    function weth() external view returns (address);

    function susd() external view returns (address);

    function based() external view returns (address);

    function uniswapRouter() external view returns (address);

    function moonbase() external view returns (address);

    function deployer() external view returns (address);

    function getRovers() external view returns (address[] memory);

    function getTokenRovers(address token) external view returns (address[] memory);

}




pragma solidity ^0.6.0;

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




pragma solidity ^0.6.0;

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




pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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




pragma solidity ^0.6.0;




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




pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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



pragma solidity >=0.6.2;

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



pragma solidity >=0.6.2;


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



pragma solidity >=0.6.0;

interface ISwapModule {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapReward(uint256 amountIn, address receiver, address[] calldata path) external returns (uint256);

}



pragma solidity >=0.6.0;








contract Rover is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant vestingTime = 365*24*60*60; // 1 year

    uint256 public roverStart;
    uint256 public latestBalance;
    uint256 public totalTokensReceived;
    uint256 public totalTokensWithdrawn;
    address[] public path;

    address public marsColony;
    bool public migrationCompleted;

    IBasedGod public basedGod;
    IERC20 public immutable based;
    IERC20 public immutable rewardToken;
    address public immutable swapModule;


    modifier updateBalance() {

        sync();
        _;
        latestBalance = rewardToken.balanceOf(address(this));
    }

    modifier onlyBasedDeployer() {

        require(msg.sender == basedGod.deployer(), "Not a deployer");
        _;
    }

    modifier onlyMarsColony() {

        require(msg.sender == marsColony, "Not a new moonbase");
        _;
    }

    constructor (
        address _rewardToken,
        string memory _pair,
        address _swapModule
    )
        public
    {
        basedGod = IBasedGod(msg.sender);
        rewardToken = IERC20(_rewardToken);
        based = IERC20(basedGod.based());
        swapModule = _swapModule;

        address[] memory _path = new address[](3);
        _path[0] = _rewardToken;
        _path[2] = basedGod.based();

        if (keccak256(abi.encodePacked(_pair)) == keccak256(abi.encodePacked("WETH"))) {
            _path[1] = basedGod.weth();
        } else if (keccak256(abi.encodePacked(_pair)) == keccak256(abi.encodePacked("sUSD"))) {
            _path[1] = basedGod.susd();
        } else {
            revert("must use a CERTIFIED OFFICIAL $BASED™ pair");
        }

        uint[] memory amountsOut = ISwapModule(_swapModule).getAmountsOut(10**10, _path);
        require(amountsOut[amountsOut.length - 1] >= 1, "Path does not exist");

        path = _path;
    }

    function balance() public view returns (uint256) {

        return rewardToken.balanceOf(address(this));
    }

    function calculateReward() public view returns (uint256) {

        uint256 timeElapsed = block.timestamp.sub(roverStart);
        if (timeElapsed > vestingTime) timeElapsed = vestingTime;
        uint256 maxClaimable = totalTokensReceived.mul(timeElapsed).div(vestingTime);
        return maxClaimable.sub(totalTokensWithdrawn);
    }

    function rugPull() public virtual updateBalance {

        require(roverStart != 0, "Rover is not initialized");

        uint256 availableReward = calculateReward();

        totalTokensWithdrawn = totalTokensWithdrawn.add(availableReward);
        (bool success, bytes memory result) = swapModule.delegatecall(
            abi.encodeWithSignature(
                "swapReward(uint256,address,address[])",
                availableReward,
                address(this),
                path
            )
        );
        require(success, "SwapModule: Swap failed");
        uint256 basedReward = abi.decode(result, (uint256));

        uint256 callerReward = basedReward.div(100);
        uint256 moonbaseReward = basedReward.sub(callerReward);

        based.transfer(msg.sender, callerReward);
        based.transfer(basedGod.moonbase(), moonbaseReward);
    }

    function setMarsColony(address _marsColony) public onlyBasedDeployer {

        marsColony = _marsColony;
    }

    function migrateRoverBalanceToMarsColonyV1_69() external onlyMarsColony updateBalance {

        require(migrationCompleted == false, "Migration completed");

        IERC20 moonbase = IERC20(basedGod.moonbase());
        uint256 marsColonyShare = moonbase.balanceOf(msg.sender);
        uint256 totalSupply = moonbase.totalSupply();
        uint256 amountToMigrate =
            rewardToken.balanceOf(address(this)).mul(marsColonyShare).div(totalSupply);

        rewardToken.transfer(msg.sender, amountToMigrate);
        migrationCompleted = true;

        totalTokensReceived = totalTokensReceived.sub(amountToMigrate);
    }

    function init() internal updateBalance {

        require(roverStart == 0, "Already initialized");
        roverStart = block.timestamp;
        renounceOwnership();
    }

    function sync() internal {

        uint256 currentBalance = rewardToken.balanceOf(address(this));
        if (currentBalance > latestBalance) {
            uint diff = currentBalance.sub(latestBalance);
            totalTokensReceived = totalTokensReceived.add(diff);
        }
    }
}



pragma solidity >=0.6.0;


contract RoverVault is Rover {

    constructor(address _rewardToken, string memory _pair, address _swapModule)
        public
        Rover(_rewardToken, _pair, _swapModule)
    {}

    function startRover() public onlyOwner {

        init();
    }
}




pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.6.0;

contract ReentrancyGuard {

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
}



pragma solidity >=0.6.0;

interface IPool {
    function getReward() external;
    function stake(uint256 amount) external;
    function earned(address account) external view returns (uint256);
}



pragma solidity >=0.6.0;





contract FarmingRover is Rover, ERC20, ReentrancyGuard {
    IPool public rewardPool;

    constructor (
        address _rewardToken,
        string memory _pair,
        address _swapModule
    )
        public
        Rover(_rewardToken, _pair, _swapModule)
        ERC20(
            string(abi.encodePacked("Rover ", ERC20(_rewardToken).name())),
            string(abi.encodePacked("r", ERC20(_rewardToken).symbol()))
        )
    {
        _mint(address(this), 1);
    }

    function earned() public view returns (uint256){
        return rewardPool.earned(address(this));
    }

    function startRover(address _rewardPool)
        public
        onlyOwner
    {
        init();

        this.approve(_rewardPool, 1);
        rewardPool = IPool(_rewardPool);
        rewardPool.stake(1);
    }

    function rugPull() public override nonReentrant {
        claimReward();

        super.rugPull();
    }

    function claimReward() internal {
        (bool success,) = address(rewardPool).call(abi.encodeWithSignature("getReward()"));
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(balanceOf(address(this)) == 1, "NOT BASED: only one transfer allowed.");
        require(recipient == address(rewardPool),
            "NOT BASED: Recipient address must be equal to rewardPool address.");
        super._transfer(sender, recipient, amount);
    }
}



pragma solidity >=0.6.0;





contract BasedGod {
    address[] public rovers;
    mapping(address => address[]) public tokenRover;
    address public immutable moonbase;
    address public immutable based;
    address public immutable susd;
    address public immutable weth;
    address public immutable uniswapRouter;
    address public immutable poolFactory;
    address public immutable basedGodV1;
    address public immutable deployer;

    constructor (
        address _based,
        address _moonbase,
        address _susd,
        address _weth,
        address _uniswapRouter,
        address _poolFactory,
        address _basedGodV1
    ) public {
        susd = _susd;
        based = _based;
        moonbase = _moonbase;
        weth = _weth;
        uniswapRouter = _uniswapRouter;
        poolFactory = _poolFactory;
        basedGodV1 = _basedGodV1;
        deployer = msg.sender;
    }

    function getRovers() public view returns (address[] memory) {
        address[] memory legacyRovers = IBasedGod(basedGodV1).getRovers();
        return legacyRovers.length == 0 ? rovers : concatArrays(legacyRovers, rovers);
    }

    function getTokenRovers(address token) public view returns (address[] memory) {
        address[] memory legacyRovers = IBasedGod(basedGodV1).getTokenRovers(token);
        return legacyRovers.length == 0 ? tokenRover[token] : concatArrays(legacyRovers, tokenRover[token]);
    }

    function createNewRoverVault(address _rewardToken, string calldata _pair, address _swapModule) external returns (RoverVault rover) {
        rover = new RoverVault(_rewardToken, _pair, _swapModule);
        rover.transferOwnership(msg.sender);
        _saveRover(_rewardToken, address(rover));
    }

    function createNewFarmingRover(address _rewardToken, string calldata _pair, address _swapModule) external returns (FarmingRover rover) {
        rover = new FarmingRover(_rewardToken, _pair, _swapModule);
        rover.transferOwnership(msg.sender);
        _saveRover(_rewardToken, address(rover));
    }

    function createNewFarmingRoverAndPool(
        address _rewardToken,
        address _distributor,
        string calldata _pair,
        address _swapModule,
        uint256 _duration
    ) external returns (FarmingRover rover, address rewardsPool) {
        require(_distributor != address(0), "someone has to notify of rewards and it ain't us");

        rover = new FarmingRover(_rewardToken, _pair, _swapModule);
        _saveRover(_rewardToken, address(rover));

        rewardsPool = IPoolFactory(poolFactory).createNewPool(
            _rewardToken,
            address(rover),
            _duration,
            _distributor
        );

        rover.startRover(rewardsPool);
    }

    function _saveRover(address _rewardToken, address _rover) internal {
        rovers.push(address(_rover));
        tokenRover[_rewardToken].push(address(_rover));
    }

    function concatArrays(address[] memory arr1, address[] memory arr2) internal pure returns (address[] memory) {
        address[] memory resultArray = new address[](arr1.length + arr2.length);
        uint i=0;
        for (; i < arr1.length; i++) {
            resultArray[i] = arr1[i];
        }

        uint j=0;
        while (j < arr2.length) {
            resultArray[i++] = arr2[j++];
        }
        return resultArray;
    }
}




pragma solidity ^0.6.0;

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




pragma solidity >=0.6.6;




contract ERC20Migrator {
    using SafeMath for uint256;

    IERC20 public legacyToken;
    IERC20 public newToken;

    uint256 public totalMigrated;

    constructor (address _legacyToken, address _newToken) public {
        require(_legacyToken != address(0), "legacyToken address is required");
        require(_newToken != address(0), "_newToken address is required");

        legacyToken = IERC20(_legacyToken);
        newToken = IERC20(_newToken);
    }

    function migrate(address account, uint256 amount) internal {
        legacyToken.transferFrom(account, address(this), amount);
        newToken.transfer(account, amount);
        totalMigrated = totalMigrated.add(amount);
    }

    function migrateAll() public {
        address account = msg.sender;
        uint256 balance = legacyToken.balanceOf(account);
        uint256 allowance = legacyToken.allowance(account, address(this));
        uint256 amount = Math.min(balance, allowance);
        require(amount > 0, "ERC20Migrator::migrateAll: Approval and balance must be > 0");
        migrate(account, amount);
    }
}





pragma solidity ^0.6.0;







abstract contract IRewardDistributionRecipient is Ownable {
    address rewardDistribution;

    constructor(address _rewardDistribution) public {
        rewardDistribution = _rewardDistribution;
    }

    function notifyRewardAmount(uint256 reward) virtual external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}


contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable lpToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(address _lpToken) public {
        lpToken = IERC20(_lpToken);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
    }
}


contract NoMintRewardPool is LPTokenWrapper, IRewardDistributionRecipient {
    IERC20 public immutable rewardToken;
    uint256 public immutable duration; // making it not a constant is less gas efficient, but portable

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
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

    constructor(address _rewardToken,
        address _lpToken,
        uint256 _duration,
        address _rewardDistribution) public
    LPTokenWrapper(_lpToken)
    IRewardDistributionRecipient(_rewardDistribution)
    {
        rewardToken = IERC20(_rewardToken);
        duration = _duration;
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
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) override {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) override {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        override
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(duration);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }
}



pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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



pragma solidity >=0.4.0;

library FixedPoint {
    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}



pragma solidity >=0.5.0;



library UniswapV2OracleLibrary {
    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}




pragma solidity >=0.5.0;



library UniswapV2Library {
    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}




pragma solidity >=0.6.6;







interface IOracle {
    function getData() external returns (uint256, bool);
}

contract ExampleOracleSimple {
    using FixedPoint for *;

    uint public PERIOD = 24 hours;

    IUniswapV2Pair immutable pair;
    address public immutable token0;
    address public immutable token1;

    uint    public price0CumulativeLast;
    uint    public price1CumulativeLast;
    uint32  public blockTimestampLast;
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    constructor(address factory, address tokenA, address tokenB) public {
        IUniswapV2Pair _pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();
        price0CumulativeLast = _pair.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = _pair.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = _pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'ExampleOracleSimple: NO_RESERVES');
    }

    function update() internal {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        require(timeElapsed >= PERIOD, 'ExampleOracleSimple: PERIOD_NOT_ELAPSED');

        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
        price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    function consult(address token, uint amountIn) internal view returns (uint amountOut) {
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        } else {
            require(token == token1, 'ExampleOracleSimple: INVALID_TOKEN');
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }
}

interface UFragmentsI {
    function monetaryPolicy() external view returns (address);
}


contract BASEDOracle is Ownable, ExampleOracleSimple, IOracle {

    uint256 constant SCALE = 10 ** 18;
    address based;
    address constant uniFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    constructor(address based_, address susd_) public ExampleOracleSimple(uniFactory, based_, susd_) {
        PERIOD = 23 hours; // ensure that rebase can always call update
        based = based_;
    }

    function updateBeforeRebase() public onlyOwner {
        update();
    }

    function getData() override external returns (uint256, bool) {
        require(msg.sender == UFragmentsI(based).monetaryPolicy());
        update();
        uint256 price = consult(based, SCALE); // will return 1 BASED in sUSD

        if (price == 0) {
            return (0, false);
        }

        return (price, true);
    }
}



pragma solidity >=0.6.0;


contract PoolFactory {
    function createNewPool(
        address _rewardToken,
        address _rover,
        uint256 _duration,
        address _distributor
    ) external returns (address) {
        _distributor = (_distributor != address(0)) ? _distributor : msg.sender;

        NoMintRewardPool rewardsPool = new NoMintRewardPool(
            _rewardToken,
            _rover,
            _duration,
            _distributor  // who can notify of rewards
        );

        return address(rewardsPool);
    }
}



pragma solidity >=0.6.2;

interface ISakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB
        );

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountETH
        );

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB
        );

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountETH
        );

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external;
}



pragma solidity >=0.6.0;





contract SakeSwapModule {
    using SafeERC20 for IERC20;

    address public immutable sakeSwapRouter;
    address public immutable uniswapRouter;

    constructor (address _uniswapRouter, address _sakeSwapRouter) public {
        uniswapRouter = _uniswapRouter;
        sakeSwapRouter = _sakeSwapRouter;
    }

    function getPaths(address[] memory path) public pure returns (address[] memory, address[] memory) {
        address[] memory sakePath = new address[](2);
        address[] memory uniswapPath = new address[](2);
        sakePath[0] = path[0];
        sakePath[1] = path[1];
        uniswapPath[0] = path[1];
        uniswapPath[1] = path[2];
        return (sakePath, uniswapPath);
    }

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint256[] memory) {
        (address[] memory sakePath, address[] memory uniswapPath) = getPaths(path);
        uint256[] memory amounts = new uint256[](2);
        uint256[] memory sakeAmounts = ISakeSwapRouter(sakeSwapRouter).getAmountsOut(amountIn, sakePath);
        amounts[0] = sakeAmounts[sakeAmounts.length - 1];
        uint256[] memory uniswapAmounts = IUniswapV2Router02(uniswapRouter).getAmountsOut(amounts[0], uniswapPath);
        amounts[1] = uniswapAmounts[uniswapAmounts.length - 1];
        return amounts;
    }

    function swapReward(uint256 amountIn, address receiver, address[] memory path) public returns (uint256){
        (address[] memory sakePath, address[] memory uniswapPath) = getPaths(path);

        IERC20(path[0]).safeApprove(sakeSwapRouter, 0);
        IERC20(path[0]).safeApprove(sakeSwapRouter, amountIn);
        uint256 amountOutMin = 1;
        uint256[] memory amounts =
            ISakeSwapRouter(sakeSwapRouter).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                sakePath,
                receiver,
                block.timestamp,
                false
            );
        amountIn = amounts[amounts.length - 1];

        IERC20(path[1]).safeApprove(uniswapRouter, 0);
        IERC20(path[1]).safeApprove(uniswapRouter, amountIn);
        amounts =
            IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                uniswapPath,
                receiver,
                block.timestamp
            );
        return amounts[amounts.length - 1];
    }
}



pragma solidity >=0.6.0;




contract UniswapModule {
    using SafeERC20 for IERC20;

    address public immutable uniswapRouter;

    constructor (address _uniswapRouter) public {
        uniswapRouter = _uniswapRouter;
    }
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory) {
        return IUniswapV2Router02(uniswapRouter).getAmountsOut(amountIn, path);
    }

    function swapReward(uint256 amountIn, address receiver, address[] memory path) public returns (uint256){
        IERC20(path[0]).safeApprove(uniswapRouter, 0);
        IERC20(path[0]).safeApprove(uniswapRouter, amountIn);
        uint256 amountOutMin = 1;
        uint256[] memory amounts =
            IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                receiver,
                block.timestamp
            );
        return amounts[amounts.length - 1];
    }
}



pragma solidity >=0.6.0;

interface IMoonBase {
    function notifyRewardAmount(uint256 reward) external;
}



pragma solidity >=0.6.0;

interface IRover {
    function transferOwnership(address newOwner) external;
}



pragma solidity >=0.6.0;

interface IScheduleProvider {
    function getSchedule() external view returns (uint256);
}