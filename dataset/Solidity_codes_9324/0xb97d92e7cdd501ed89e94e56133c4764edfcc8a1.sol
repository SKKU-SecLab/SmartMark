

pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

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



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
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

    uint256[50] private ______gap;
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



contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

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

    uint256[50] private ______gap;
}


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.5;



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

    function getReserves(address pair, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
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

    function getAmountsOut(address pair, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(pair, path[i], path[i + 1]);
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


pragma solidity ^0.5.5;


interface IVolcieToken {

    function totalSupply() external view returns (uint256 total);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) external view returns (address owner);

    function allTokenOf(address holder) external view returns(uint256[] memory);

    function approve(address _to, uint256 _tokenId) external;

    function transfer(address _to, uint256 _tokenId) external;

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function burn(uint256 tokenId) external;

    function mint(address to, address lpToken, uint256 lpAmount)  external returns (uint256);


    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);


    function supportsInterface(bytes4 _interfaceID) external view returns (bool);


}


pragma solidity ^0.5.5;








contract YieldFarming is Ownable {

    using SafeMath for uint256;


    IVolcieToken public volcie;                          // VolcieToken contract
    IERC20 public kittieFightToken;                      // KittieFightToken contract variable
    IERC20 public superDaoToken;                         // SuperDaoToken contract variable
    YieldFarmingHelper public yieldFarmingHelper;        // YieldFarmingHelper contract variable
    YieldsCalculator public yieldsCalculator;            // YieldFarmingHelper contract variable

    uint256 constant internal base18 = 1000000000000000000;
    uint256 constant internal base6 = 1000000;

    uint256 constant public MONTH = 30 days;// 30 * 24 * 60 * 60;  // MONTH duration is 30 days, to keep things standard
    uint256 constant public DAY = 1 days;// 24 * 60 * 60;

    uint256 public totalNumberOfPairPools;              // Total number of Uniswap V2 pair pools associated with YieldFarming

    uint256 public EARLY_MINING_BONUS;
    uint256 public adjustedTotalLockedLPinEarlyMining;

    uint256 public totalLockedLP;                       // Total Uniswap Liquidity tokens locked
    uint256 public totalRewardsKTY;                     // Total KittieFightToken rewards
    uint256 public totalRewardsSDAO;                    // Total SuperDaoToken rewards
    uint256 public totalRewardsKTYclaimed;              // KittieFightToken rewards already claimed
    uint256 public totalRewardsSDAOclaimed;             // SuperDaoToken rewards already claimed

    uint256 public programDuration;                     // Total time duration for Yield Farming Program
    uint256 public programStartAt;                      // Start Time of Yield Farming Program 
    uint256 public programEndAt;                        // End Time of Yield Farming Program 
    uint256[6] public monthsStartAt;                    // an array of the start time of each month.
  
    uint256[6] public KTYunlockRates;                   // Reward Unlock Rates of KittieFightToken for eahc of the 6 months for the entire program duration
    uint256[6] public SDAOunlockRates;                  // Reward Unlock Rates of KittieFightToken for eahc of the 6 months for the entire program duration

    struct Staker {
        uint256[2][] totalDeposits;                      // A 2d array of total deposits [[pairCode, batchNumber], [[pairCode, batchNumber], ...]]
        uint256[][200] batchLockedLPamount;              // A 2d array showing the locked amount of Liquidity tokens in each batch of each Pair Pool
        uint256[][200] adjustedBatchLockedLPamount;      // A 2d array showing the locked amount of Liquidity tokens in each batch of each Pair Pool, adjusted to LP bubbling factor
        uint256[][200] adjustedStartingLPamount;
        uint256[][200] factor;                           // A 2d array showing the LP bubbling factor in each batch of each Pair Pool
        uint256[][200] batchLockedAt;                    // A 2d array showing the locked time of each batch in each Pair Pool
        uint256[200] totalLPlockedbyPairCode;            // Total amount of Liquidity tokens locked by this stader from all pair pools
        uint256[] depositNumberForEarlyBonus;            // An array of all the deposit number eligible for early bonus for this staker
    }

    struct VolcieToken {
        address originalOwner;   // the owner of this token at the time of minting
        uint256 generation;      // the generation of this token, between number 0 and 5
        uint256 depositNumber;   // the deposit number associated with this token and the original owner
        uint256 LP;              // the original LP locked in this volcie token
        uint256 pairCode;        // the pair code of the uniswap pair pool from which the LP come from
        uint256 lockedAt;        // the unix time at which this funds is locked
        bool tokenBurnt;         // true if this token has been burnt
        uint256 tokenBurntAt;    // the time when this token was burnt, 0 if token is not burnt
        address tokenBurntBy;    // who burnt this token (if this token was burnt)
        uint256 ktyRewards;      // KTY rewards distributed upon burning this token
        uint256 sdaoRewards;     // SDAO rewards distributed upon burning this token
    }

    mapping(address => Staker) internal stakers;

    mapping(uint256 => address) internal pairPoolsInfo;

    mapping(uint256 => VolcieToken) internal volcieTokens;

    mapping(uint256 => uint256) public adjustedMonthlyDeposits;

    mapping(address => uint256[2]) internal rewardsClaimed;

    mapping(uint256 => uint256) internal totalDepositedLPbyPairCode;

    uint256 private unlocked;

    uint256 public calculated;
    uint256 public calculated1;

    modifier lock() {

        require(unlocked == 1, 'Locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }          

    function initialize
    (
        address[] calldata _pairPoolAddr,
        IVolcieToken _volcie,
        IERC20 _kittieFightToken,
        IERC20 _superDaoToken,
        YieldFarmingHelper _yieldFarmingHelper,
        YieldsCalculator _yieldsCalculator,
        uint256[6] calldata _ktyUnlockRates,
        uint256[6] calldata _sdaoUnlockRates,
        uint256 _programStartTime
    )
        external initializer
    {
        Ownable.initialize(_msgSender());
        setVolcieToken(_volcie);
        setRewardsToken(_kittieFightToken, true);
        setRewardsToken(_superDaoToken, false);

        for (uint256 i = 0; i < _pairPoolAddr.length; i++) {
            addNewPairPool(_pairPoolAddr[i]);
        }

        setYieldFarmingHelper(_yieldFarmingHelper);
        setYieldsCalculator(_yieldsCalculator);

        totalRewardsKTY = 7000000 * base18; // 7000000 * base18;
        totalRewardsSDAO = 7000000 * base18; //7000000 * base18;

        EARLY_MINING_BONUS = 700000 * base18; //700000 * base18;

        for (uint256 j = 0; j < 6; j++) {
            setRewardUnlockRate(j, _ktyUnlockRates[j], true);
            setRewardUnlockRate(j, _sdaoUnlockRates[j], false);
        }

        setProgramDuration(6, _programStartTime);

        unlocked = 1;
    }

    event Deposited(
        address indexed sender,
        uint256 indexed volcieTokenID,
        uint256 depositNumber,
        uint256 indexed pairCode,
        uint256 lockedLP,
        uint256 depositTime
    );

    event VolcieTokenBurnt(
        address indexed burner,
        address originalOwner,
        uint256 indexed volcieTokenID,
        uint256 indexed depositNumber,
        uint256 pairCode,
        uint256 batchNumber,
        uint256 KTYamount,
        uint256 SDAOamount,
        uint256 LPamount,
        uint256 withdrawTime
    );



    function deposit(uint256 _amountLP, uint256 _pairCode) external lock returns (bool) {

        require(block.timestamp >= programStartAt && block.timestamp <= programEndAt, "Program is not active");
        
        require(_amountLP > 0, "Cannot deposit 0 tokens");

        require(IUniswapV2Pair(pairPoolsInfo[_pairCode]).transferFrom(msg.sender, address(this), _amountLP), "Fail to deposit liquidity tokens");

        uint256 _depositNumber = stakers[msg.sender].totalDeposits.length;

        _addDeposit(msg.sender, _depositNumber, _pairCode, _amountLP, block.timestamp);

        (,address _LPaddress,) = getPairPool(_pairCode);

        uint256 _volcieTokenID = _mint(msg.sender, _LPaddress, _amountLP);

        _updateMint(msg.sender, _depositNumber, _amountLP, _pairCode, _volcieTokenID);

        emit Deposited(msg.sender, _volcieTokenID, _depositNumber, _pairCode, _amountLP, block.timestamp);

        return true;
    }

    function withdrawByVolcieID(uint256 _volcieID) external lock returns (bool) {

        (bool _isPayDay,) = yieldFarmingHelper.isPayDay();
        require(_isPayDay, "Can only withdraw on pay day");

        address currentOwner = volcie.ownerOf(_volcieID);
        require(currentOwner == msg.sender, "Only the owner of this token can burn it");

        require(volcieTokens[_volcieID].tokenBurnt == false, "This Volcie Token has already been burnt");

        address _originalOwner = volcieTokens[_volcieID].originalOwner;
        uint256 _depositNumber = volcieTokens[_volcieID].depositNumber;

        uint256 _pairCode = stakers[_originalOwner].totalDeposits[_depositNumber][0];
        uint256 _batchNumber = stakers[_originalOwner].totalDeposits[_depositNumber][1];

        uint256 _amountLP = stakers[_originalOwner].batchLockedLPamount[_pairCode][_batchNumber];
        require(_amountLP > 0, "No locked tokens in this deposit");

        uint256 _lockDuration = block.timestamp.sub(volcieTokens[_volcieID].lockedAt);
        require(_lockDuration > MONTH, "Need to stake at least 30 days");

        volcie.burn(_volcieID);

        (uint256 _KTY, uint256 _SDAO) = yieldsCalculator.calculateRewardsByBatchNumber(_originalOwner, _batchNumber, _pairCode);

        _updateWithdrawByBatchNumber(_originalOwner, _pairCode, _batchNumber, _amountLP, _KTY, _SDAO);

        _updateBurn(msg.sender, _volcieID, _KTY, _SDAO);

        _transferTokens(msg.sender, _pairCode, _amountLP, _KTY, _SDAO);

        emit VolcieTokenBurnt(
            msg.sender, _originalOwner, _volcieID, _depositNumber, _pairCode,
            _batchNumber, _KTY, _SDAO, _amountLP, block.timestamp
        );

        return true;
    }

    function addNewPairPool(address _pairPoolAddr) public onlyOwner {

        uint256 _pairCode = totalNumberOfPairPools;

        IUniswapV2Pair pair = IUniswapV2Pair(_pairPoolAddr);
        address token0 = pair.token0();
        address token1 = pair.token1();
        require(token0 == address(kittieFightToken) || token1 == address(kittieFightToken), "Pair should contain KTY");

        pairPoolsInfo[_pairCode] = _pairPoolAddr;

        totalNumberOfPairPools = totalNumberOfPairPools.add(1);
    }

    function setVolcieToken(IVolcieToken _volcie) public onlyOwner {

        volcie = _volcie;
    }

    function setRewardsToken(IERC20 _rewardsToken, bool forKTY) public onlyOwner {

        if (forKTY) {
            kittieFightToken = _rewardsToken;
        } else {
            superDaoToken = _rewardsToken;
        }   
    }

    function setYieldFarmingHelper(YieldFarmingHelper _yieldFarmingHelper) public onlyOwner {

        yieldFarmingHelper = _yieldFarmingHelper;
    }

    function setYieldsCalculator(YieldsCalculator _yieldsCalculator) public onlyOwner {

        yieldsCalculator = _yieldsCalculator;
    }

    function returnTokens(address _token, uint256 _amount, address _newAddress) external onlyOwner {

        require(block.timestamp > programEndAt.add(MONTH.mul(2)), "Owner can only return tokens after two months after program ends");
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(_amount <= balance, "Exceeds balance");
        require(IERC20(_token).transfer(_newAddress, _amount), "Fail to transfer tokens");
    }

    function setRewardUnlockRate(uint256 _month, uint256 _rate, bool forKTY) public onlyOwner {

        if (forKTY) {
            KTYunlockRates[_month] = _rate;
        } else {
            SDAOunlockRates[_month] = _rate;
        }
    }

    function setProgramDuration(uint256 _totalNumberOfMonths, uint256 _programStartAt) public onlyOwner {

        programDuration = _totalNumberOfMonths.mul(MONTH);
        programStartAt = _programStartAt;
        programEndAt = programStartAt.add(MONTH.mul(6));

        monthsStartAt[0] = _programStartAt;
        for (uint256 i = 1; i < _totalNumberOfMonths; i++) {
            monthsStartAt[i] = monthsStartAt[i.sub(1)].add(MONTH); 
        }
    }

    function setTotalRewards(uint256 _rewardsKTY, uint256 _rewardsSDAO) public onlyOwner {

        totalRewardsKTY = _rewardsKTY;
        totalRewardsSDAO = _rewardsSDAO;
    }

    
    function getPairPool(uint256 _pairCode)
        public view
        returns (string memory, address, address)
    {

        IUniswapV2Pair pair = IUniswapV2Pair(pairPoolsInfo[_pairCode]);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address otherToken = (token0 == address(kittieFightToken))?token1:token0;
        string memory pairName = string(abi.encodePacked(ERC20Detailed(address(kittieFightToken)).symbol(),"-",ERC20Detailed(address(otherToken)).symbol()));
        return (pairName, pairPoolsInfo[_pairCode], otherToken);
    }

    function getVolcieToken(uint256 _volcieTokenID) public view
        returns (
            address originalOwner, uint256 depositNumber, uint256 generation,
            uint256 LP, uint256 pairCode, uint256 lockTime, bool tokenBurnt,
            address tokenBurntBy, uint256 ktyRewardsDistributed, uint256 sdaoRewardsDistributed
        )
    {

        originalOwner = volcieTokens[_volcieTokenID].originalOwner;
        depositNumber = volcieTokens[_volcieTokenID].depositNumber;
        generation = volcieTokens[_volcieTokenID].generation;
        LP = volcieTokens[_volcieTokenID].LP;
        pairCode = volcieTokens[_volcieTokenID].pairCode;
        lockTime = volcieTokens[_volcieTokenID].lockedAt;
        tokenBurnt = volcieTokens[_volcieTokenID].tokenBurnt;
        tokenBurntBy = volcieTokens[_volcieTokenID].tokenBurntBy;
        ktyRewardsDistributed = volcieTokens[_volcieTokenID].ktyRewards;
        sdaoRewardsDistributed = volcieTokens[_volcieTokenID].sdaoRewards;

    }

    function getAllDeposits(address _staker)
        external view returns (uint256[2][] memory)
    {

        return stakers[_staker].totalDeposits;
    }

    function getNumberOfDeposits(address _staker)
        external view returns (uint256)
    {

        return stakers[_staker].totalDeposits.length;
    }


    function getBatchNumberAndPairCode(address _staker, uint256 _depositNumber)
        public view returns (uint256, uint256)
    {

        uint256 _pairCode = stakers[_staker].totalDeposits[_depositNumber][0];
        uint256 _batchNumber = stakers[_staker].totalDeposits[_depositNumber][1];
        return (_pairCode, _batchNumber);
    }

    function getAllBatchesPerPairPool(address _staker, uint256 _pairCode)
        external view returns (uint256[] memory)
    {

        return stakers[_staker].batchLockedLPamount[_pairCode];
    }


    function getLPinBatch(address _staker, uint256 _pairCode, uint256 _batchNumber)
        external view returns (uint256, uint256, uint256, uint256)
    {

        uint256 _LP = stakers[_staker].batchLockedLPamount[_pairCode][_batchNumber];
        uint256 _adjustedLP = stakers[_staker].adjustedBatchLockedLPamount[_pairCode][_batchNumber];
        uint256 _adjustedStartingLP = stakers[_staker].adjustedStartingLPamount[_pairCode][_batchNumber];        
        uint256 _lockTime = stakers[_staker].batchLockedAt[_pairCode][_batchNumber];
        
        return (_LP, _adjustedLP, _adjustedStartingLP, _lockTime);
    }

    function getFactorInBatch(address _staker, uint256 _pairCode, uint256 _batchNumber)
        external view returns (uint256)
    {

        return stakers[_staker].factor[_pairCode][_batchNumber];
    }

    function getLockedLPbyPairCode(address _staker, uint256 _pairCode)
        external view returns (uint256)
    {

        return stakers[_staker].totalLPlockedbyPairCode[_pairCode];
    }

    function getDepositsForEarlyBonus(address _staker) external view returns(uint256[] memory) {

        return stakers[_staker].depositNumberForEarlyBonus;
    }

    function isBatchEligibleForEarlyBonus(address _staker, uint256 _batchNumber, uint256 _pairCode)
        public view returns (bool)
    {

        uint256 lockedAt = stakers[_staker].batchLockedAt[_pairCode][_batchNumber];
        if (lockedAt > 0 && lockedAt <= programStartAt.add(DAY.mul(21))) {
            return true;
        }
        return false;
    }

    function getTotalRewardsClaimedByStaker(address _staker) external view returns (uint256[2] memory) {

        return rewardsClaimed[_staker];
    }

    function getAdjustedTotalMonthlyDeposits(uint256 _month) external view returns (uint256) {

        return adjustedMonthlyDeposits[_month];
    }

    function getCurrentMonth() public view returns (uint256) {

        uint256 currentMonth;
        for (uint256 i = 5; i >= 0; i--) {
            if (block.timestamp >= monthsStartAt[i]) {
                currentMonth = i;
                break;
            }
        }
        return currentMonth;
    }

    function getRewardUnlockRateByMonth(uint256 _month) external view returns (uint256, uint256) {

        uint256 _KTYunlockRate = KTYunlockRates[_month];
        uint256 _SDAOunlockRate = SDAOunlockRates[_month];
        return (_KTYunlockRate, _SDAOunlockRate);
    }


    function getMonthStartAt(uint256 month) external view returns (uint256) {

        return monthsStartAt[month];
    }

    function getTotalDepositsPerPairCode(uint256 _pairCode) external view returns (uint256) {

        return totalDepositedLPbyPairCode[_pairCode];
    }

    function getAPY(address _pair_KTY_SDAO) external view returns (uint256) {

        if(totalLockedLP == 0)
            return 0;
        uint256 rateKTYSDAO = getExpectedPrice_KTY_SDAO(_pair_KTY_SDAO);

        uint256 totalRewardsInKTY = totalRewardsKTY.add(totalRewardsSDAO.mul(rateKTYSDAO).div(base18));

        uint256 lockedKTYs;

        for(uint256 i = 0; i < totalNumberOfPairPools; i++) {
            if(totalDepositedLPbyPairCode[i] == 0)
                continue;
            uint256 balance = kittieFightToken.balanceOf(pairPoolsInfo[i]);
            uint256 supply = IERC20(pairPoolsInfo[i]).totalSupply();
            uint256 KTYs = balance.mul(totalDepositedLPbyPairCode[i]).mul(2).div(supply);
            lockedKTYs = lockedKTYs.add(KTYs);
        }

        return base18.mul(200).mul(lockedKTYs.add(totalRewardsInKTY)).div(lockedKTYs);
    }

    function getExpectedPrice_KTY_SDAO(address _pair_KTY_SDAO) public view returns (uint256) {


        uint256 _amountSDAO = 1e18;  // 1 SDAO
        (uint256 _reserveKTY, uint256 _reserveSDAO) = yieldFarmingHelper.getReserve(
            address(kittieFightToken), address(superDaoToken), _pair_KTY_SDAO
            );
        return UniswapV2Library.getAmountIn(_amountSDAO, _reserveKTY, _reserveSDAO);
    }


    function _addDeposit
    (
        address _sender, uint256 _depositNumber, uint256 _pairCode, uint256 _amount, uint256 _lockedAt
    ) private {
        uint256 _batchNumber = stakers[_sender].batchLockedLPamount[_pairCode].length;
        uint256 _currentMonth = getCurrentMonth();
        uint256 _factor = yieldFarmingHelper.bubbleFactor(_pairCode);
        uint256 _adjustedAmount = _amount.mul(base6).div(_factor);

        stakers[_sender].totalDeposits.push([_pairCode, _batchNumber]);
        stakers[_sender].batchLockedLPamount[_pairCode].push(_amount);
        stakers[_sender].adjustedBatchLockedLPamount[_pairCode].push(_adjustedAmount);
        stakers[_sender].factor[_pairCode].push(_factor);
        stakers[_sender].batchLockedAt[_pairCode].push(_lockedAt);
        stakers[_sender].totalLPlockedbyPairCode[_pairCode] = stakers[_sender].totalLPlockedbyPairCode[_pairCode].add(_amount);

        uint256 _currentDay = yieldsCalculator.getCurrentDay();

        if (yieldsCalculator.getElapsedDaysInMonth(_currentDay, _currentMonth) > 0) {
            uint256 currentDepositedAmount = yieldsCalculator.getFirstMonthAmount(
                _currentDay,
                _currentMonth,
                adjustedMonthlyDeposits[_currentMonth],
                _adjustedAmount
            );

            stakers[_sender].adjustedStartingLPamount[_pairCode].push(currentDepositedAmount);
            adjustedMonthlyDeposits[_currentMonth] = adjustedMonthlyDeposits[_currentMonth].add(currentDepositedAmount);
        } else {
            stakers[_sender].adjustedStartingLPamount[_pairCode].push(_adjustedAmount);
            adjustedMonthlyDeposits[_currentMonth] = adjustedMonthlyDeposits[_currentMonth]
                                                     .add(_adjustedAmount);
        }

        if (_currentMonth < 5) {
            for (uint256 i = _currentMonth.add(1); i < 6; i++) {
                adjustedMonthlyDeposits[i] = adjustedMonthlyDeposits[i]
                                             .add(_adjustedAmount);
            }
        }

        totalDepositedLPbyPairCode[_pairCode] = totalDepositedLPbyPairCode[_pairCode].add(_amount);
        totalLockedLP = totalLockedLP.add(_amount);

        if (block.timestamp <= programStartAt.add(DAY.mul(21))) {
            adjustedTotalLockedLPinEarlyMining = adjustedTotalLockedLPinEarlyMining.add(_adjustedAmount);
            stakers[_sender].depositNumberForEarlyBonus.push(_depositNumber);
        }
    }

    function _updateMint
    (
        address _originalOwner,
        uint256 _depositNumber,
        uint256 _LP,
        uint256 _pairCode,
        uint256 _volcieTokenID
    )
        internal
    {
        volcieTokens[_volcieTokenID].generation = getCurrentMonth();
        volcieTokens[_volcieTokenID].depositNumber = _depositNumber;
        volcieTokens[_volcieTokenID].LP = _LP;
        volcieTokens[_volcieTokenID].pairCode = _pairCode;
        volcieTokens[_volcieTokenID].lockedAt = now;
        volcieTokens[_volcieTokenID].originalOwner = _originalOwner;
    }

    function _updateWithdrawByBatchNumber
    (
        address _sender, uint256 _pairCode, uint256 _batchNumber,
        uint256 _LP, uint256 _KTY, uint256 _SDAO
    ) 
        private
    {
        uint256 adjustedLP = stakers[_sender].adjustedBatchLockedLPamount[_pairCode][_batchNumber];
        stakers[_sender].batchLockedLPamount[_pairCode][_batchNumber] = 0;
        stakers[_sender].adjustedBatchLockedLPamount[_pairCode][_batchNumber] = 0;
        stakers[_sender].adjustedStartingLPamount[_pairCode][_batchNumber] = 0;
        stakers[_sender].batchLockedAt[_pairCode][_batchNumber] = 0;

        stakers[_sender].totalLPlockedbyPairCode[_pairCode] = stakers[_sender].totalLPlockedbyPairCode[_pairCode].sub(_LP);

        totalRewardsKTYclaimed = totalRewardsKTYclaimed.add(_KTY);
        totalRewardsSDAOclaimed = totalRewardsSDAOclaimed.add(_SDAO);
        totalLockedLP = totalLockedLP.sub(_LP);

        uint256 _currentMonth = getCurrentMonth();

        if (_currentMonth < 5) {
            for (uint i = _currentMonth; i < 6; i++) {
                adjustedMonthlyDeposits[i] = adjustedMonthlyDeposits[i]
                                             .sub(adjustedLP);
            }
        }

        if (block.timestamp < programEndAt && isBatchEligibleForEarlyBonus(_sender, _batchNumber, _pairCode)) {
            adjustedTotalLockedLPinEarlyMining = adjustedTotalLockedLPinEarlyMining.sub(adjustedLP);
        }
    }

    function _updateBurn
    (
        address _burner,
        uint256 _volcieTokenID,
        uint256 _ktyRewards,
        uint256 _sdaoRewards
    )
        internal
    {
        volcieTokens[_volcieTokenID].LP = 0;
        volcieTokens[_volcieTokenID].lockedAt = 0;
        volcieTokens[_volcieTokenID].tokenBurnt = true;
        volcieTokens[_volcieTokenID].tokenBurntAt = now;
        volcieTokens[_volcieTokenID].tokenBurntBy = _burner;
        volcieTokens[_volcieTokenID].ktyRewards = _ktyRewards;
        volcieTokens[_volcieTokenID].sdaoRewards = _sdaoRewards;

        rewardsClaimed[_burner][0] = rewardsClaimed[_burner][0].add(_ktyRewards);
        rewardsClaimed[_burner][1] = rewardsClaimed[_burner][1].add(_sdaoRewards);
    }

    function _transferTokens(address _user, uint256 _pairCode, uint256 _amountLP, uint256 _amountKTY, uint256 _amountSDAO)
        private
    {

        require(IUniswapV2Pair(pairPoolsInfo[_pairCode]).transfer(_user, _amountLP), "Fail to transfer liquidity token");

        require(kittieFightToken.transfer(_user, _amountKTY), "Fail to transfer KTY");
        require(superDaoToken.transfer(_user, _amountSDAO), "Fail to transfer SDAO");
    }

    function _mint
    (
        address _to,
        address _LPaddress,
        uint256 _LPamount
    )
        private
        returns (uint256)
    {
        return volcie.mint(_to, _LPaddress, _LPamount);
    }
}

contract YieldFarmingHelper is Ownable {

    using SafeMath for uint256;


    YieldFarming public yieldFarming;
    YieldsCalculator public yieldsCalculator;

    address public ktyWethPair;
    address public daiWethPair;

    address public kittieFightTokenAddr;
    address public superDaoTokenAddr;
    address public wethAddr;
    address public daiAddr;

    uint256 constant public base18 = 1000000000000000000;
    uint256 constant public base6 = 1000000;

    uint256 constant public MONTH = 30 days;// 30 * 24 * 60 * 60;  // MONTH duration is 30 days, to keep things standard
    uint256 constant public DAY = 1 days;// 24 * 60 * 60;


    function initialize
    (
        YieldFarming _yieldFarming,
        YieldsCalculator _yieldsCalculator,
        address _ktyWethPair,
        address _daiWethPair,
        address _kittieFightToken,
        address _superDaoToken,
        address _weth,
        address _dai
    ) 
        public initializer
    {
        Ownable.initialize(_msgSender());
        setYieldFarming(_yieldFarming);
        setYieldsCalculator(_yieldsCalculator);
        setKtyWethPair(_ktyWethPair);
        setDaiWethPair(_daiWethPair);
        setRwardsTokenAddress(_kittieFightToken, true);
        setRwardsTokenAddress(_superDaoToken, false);
        setWethAddress(_weth);
        setDaiAddress(_dai);
    }


    function setYieldFarming(YieldFarming _yieldFarming) public onlyOwner {

        yieldFarming = _yieldFarming;
    }

    function setYieldsCalculator(YieldsCalculator _yieldsCalculator) public onlyOwner {

        yieldsCalculator= _yieldsCalculator;
    }

    function setKtyWethPair(address _ktyWethPair) public onlyOwner {

        ktyWethPair = _ktyWethPair;
    }

    function setDaiWethPair(address _daiWethPair) public onlyOwner {

        daiWethPair = _daiWethPair;
    }

    function setRwardsTokenAddress(address _rewardToken, bool forKTY) public onlyOwner {

        if (forKTY) {
            kittieFightTokenAddr = _rewardToken;
        } else {
            superDaoTokenAddr = _rewardToken;
        }        
    }

    function setWethAddress(address _weth) public onlyOwner {

        wethAddr = _weth;
    }

    function setDaiAddress(address _dai) public onlyOwner {

        daiAddr = _dai;
    }



    function getLPinfo(uint256 _pairCode)
        public view returns (uint256 reserveKTY, uint256 totalSupplyLP) 
    {

        (,address pairPoolAddress, address _tokenAddr) = yieldFarming.getPairPool(_pairCode);
        (reserveKTY,) = getReserve(kittieFightTokenAddr, _tokenAddr, pairPoolAddress);
        totalSupplyLP = IUniswapV2Pair(pairPoolAddress).totalSupply();
    }

    function bubbleFactor(uint256 _pairCode) external view returns (uint256)
    {

        (uint256 reserveKTY, uint256 totalSupply) = getLPinfo(0);
        (uint256 reserveKTY_1, uint256 totalSupply_1) = getLPinfo(_pairCode);

        uint256 factor = totalSupply_1.mul(reserveKTY).mul(base6).div(totalSupply.mul(reserveKTY_1));
        return factor;
    }

    function isPayDay()
        public view
        returns (bool, uint256)
    {

        uint256 month1StartTime = yieldFarming.getMonthStartAt(1);
        if (block.timestamp < month1StartTime) {
            return (false, month1StartTime.sub(block.timestamp));
        }
        if (block.timestamp >= yieldFarming.programEndAt()) {
            return (true, 0);
        }
        uint256 currentMonth = yieldFarming.getCurrentMonth();
        if (block.timestamp >= yieldFarming.getMonthStartAt(currentMonth)
            && block.timestamp <= yieldFarming.getMonthStartAt(currentMonth).add(DAY)) {
            return (true, 0);
        }
        if (block.timestamp > yieldFarming.getMonthStartAt(currentMonth).add(DAY)) {
            uint256 nextPayDay = yieldFarming.getMonthStartAt(currentMonth.add(1));
            return (false, nextPayDay.sub(block.timestamp));
        }
    }

    function getTotalLiquidityTokenLocked() external view returns (uint256) {

        return yieldFarming.totalLockedLP();
    }

    function totalLockedLPinDAI() external view returns (uint256) {

        uint256 _totalLockedLPinDAI = 0;
        uint256 _LPinDai;
        uint256 totalNumberOfPairPools = yieldFarming.totalNumberOfPairPools();
        for (uint256 i = 0; i < totalNumberOfPairPools; i++) {
            _LPinDai = getTotalLiquidityTokenLockedInDAI(i);
            _totalLockedLPinDAI = _totalLockedLPinDAI.add(_LPinDai);
        }

        return _totalLockedLPinDAI;
    }

    function getDepositNumber(address _staker, uint256 _pairCode, uint256 _batchNumber)
        external view returns (bool, uint256)
    {

        uint256 _pair;
        uint256 _batch;

        uint256 _totalDeposits = yieldFarming.getNumberOfDeposits(_staker);
        if (_totalDeposits == 0) {
            return (false, 0);
        }
        for (uint256 i = 0; i < _totalDeposits; i++) {
            (_pair, _batch) = yieldFarming.getBatchNumberAndPairCode(_staker, i);
            if (_pair == _pairCode && _batch == _batchNumber) {
                return (true, i);
            }
        }
    }

    function totalLPforEarlyBonusPerPairCode(address _staker, uint256 _pairCode)
        public view returns (uint256, uint256) {

        uint256[] memory depositsEarlyBonus = yieldFarming.getDepositsForEarlyBonus(_staker);
        uint256 totalLPEarlyBonus = 0;
        uint256 adjustedTotalLPEarlyBonus = 0;
        uint256 depositNum;
        uint256 batchNum;
        uint256 pairCode;
        uint256 lockTime;
        uint256 lockedLP;
        uint256 adjustedLockedLP;
        for (uint256 i = 0; i < depositsEarlyBonus.length; i++) {
            depositNum = depositsEarlyBonus[i];
            (pairCode, batchNum) = yieldFarming.getBatchNumberAndPairCode(_staker, depositNum);
            (lockedLP,adjustedLockedLP,, lockTime) = yieldFarming.getLPinBatch(_staker, pairCode, batchNum);
            if (pairCode == _pairCode && lockTime > 0 && lockedLP > 0) {
                totalLPEarlyBonus = totalLPEarlyBonus.add(lockedLP);
                adjustedTotalLPEarlyBonus = adjustedTotalLPEarlyBonus.add(adjustedLockedLP);
            }
        }

        return (totalLPEarlyBonus, adjustedTotalLPEarlyBonus);
    }

    function totalLPforEarlyBonus(address _staker) public view returns (uint256, uint256) {

        uint256[] memory _depositsEarlyBonus = yieldFarming.getDepositsForEarlyBonus(_staker);
        if (_depositsEarlyBonus.length == 0) {
            return (0, 0);
        }
        uint256 _totalLPEarlyBonus = 0;
        uint256 _adjustedTotalLPEarlyBonus = 0;
        uint256 _depositNum;
        uint256 _batchNum;
        uint256 _pair;
        uint256 lockTime;
        uint256 lockedLP;
        uint256 adjustedLockedLP;
        for (uint256 i = 0; i < _depositsEarlyBonus.length; i++) {
            _depositNum = _depositsEarlyBonus[i];
            (_pair, _batchNum) = yieldFarming.getBatchNumberAndPairCode(_staker, _depositNum);
            (lockedLP,adjustedLockedLP,, lockTime) = yieldFarming.getLPinBatch(_staker, _pair, _batchNum);
            if (lockTime > 0 && lockedLP > 0) {
                _totalLPEarlyBonus = _totalLPEarlyBonus.add(lockedLP);
                _adjustedTotalLPEarlyBonus = _adjustedTotalLPEarlyBonus.add(adjustedLockedLP);
            }
        }

        return (_totalLPEarlyBonus, _adjustedTotalLPEarlyBonus);
    }

    function getTotalEarlyBonus(address _staker) external view returns (uint256, uint256) {

        (, uint256 totalEarlyLP) = totalLPforEarlyBonus(_staker);
        uint256 earlyBonus = yieldsCalculator.getEarlyBonus(totalEarlyLP);
        return (earlyBonus, earlyBonus);
    }

    function getTotalRewardsClaimed() external view returns (uint256, uint256) {

        uint256 totalKTYclaimed = yieldFarming.totalRewardsKTYclaimed();
        uint256 totalSDAOclaimed = yieldFarming.totalRewardsSDAOclaimed();
        return (totalKTYclaimed, totalSDAOclaimed);
    }

    function getTotalRewards() public view returns (uint256, uint256) {

        uint256 rewardsKTY = yieldFarming.totalRewardsKTY();
        uint256 rewardsSDAO = yieldFarming.totalRewardsSDAO();
        return (rewardsKTY, rewardsSDAO);
    }

    function getTotalDeposits() public view returns (uint256) {

        uint256 totalPools = yieldFarming.totalNumberOfPairPools();
        uint256 totalDeposits = 0;
        uint256 deposits;
        for (uint256 i = 0; i < totalPools; i++) {
            deposits = yieldFarming.getTotalDepositsPerPairCode(i);
            totalDeposits = totalDeposits.add(deposits);
        }
        return totalDeposits;
    }

    function getTotalDepositsInDai() external view returns (uint256) {

        uint256 totalPools = yieldFarming.totalNumberOfPairPools();
        uint256 totalDepositsInDai = 0;
        uint256 deposits;
        uint256 depositsInDai;
        for (uint256 i = 0; i < totalPools; i++) {
            deposits = yieldFarming.getTotalDepositsPerPairCode(i);
            depositsInDai = deposits > 0 ? getLPvalueInDai(i, deposits) : 0;
            totalDepositsInDai = totalDepositsInDai.add(depositsInDai);
        }
        return totalDepositsInDai;
    }

    function getLockedRewards() public view returns (uint256, uint256) {

        (uint256 totalRewardsKTY, uint256 totalRewardsSDAO) = getTotalRewards();
        (uint256 unlockedKTY, uint256 unlockedSDAO) = getUnlockedRewards();
        uint256 lockedKTY = totalRewardsKTY.sub(unlockedKTY);
        uint256 lockedSDAO = totalRewardsSDAO.sub(unlockedSDAO);
        return (lockedKTY, lockedSDAO);
    }

    function getUnlockedRewards() public view returns (uint256, uint256) {

        uint256 unlockedKTY = IERC20(kittieFightTokenAddr).balanceOf(address(yieldFarming));
        uint256 unlockedSDAO = IERC20(superDaoTokenAddr).balanceOf(address(yieldFarming));
        return (unlockedKTY, unlockedSDAO);
    }

    function getProgramDuration() external view 
    returns
    (
        uint256 entireProgramDuration,
        uint256 monthDuration,
        uint256 startMonth,
        uint256 endMonth,
        uint256 currentMonth,
        uint256 daysLeft,
        uint256 elapsedMonths
    ) 
    {

        uint256 currentDay = yieldsCalculator.getCurrentDay();
        entireProgramDuration = yieldFarming.programDuration();
        monthDuration = yieldFarming.MONTH();
        startMonth = 0;
        endMonth = 5;
        currentMonth = yieldFarming.getCurrentMonth();
        daysLeft = currentDay >= 180 ? 0 : 180 - currentDay;
        elapsedMonths = currentMonth == 0 ? 0 : currentMonth;
    }

    function getTotalEarlyMiningBonus() external view returns (uint256, uint256) {

        return (yieldFarming.EARLY_MINING_BONUS(), yieldFarming.EARLY_MINING_BONUS());
    }

    function getLockedLPinDeposit(address _staker, uint256 _depositNumber)
        external view returns (uint256, uint256, uint256)
    {

        (uint256 _pairCode, uint256 _batchNumber) = yieldFarming.getBatchNumberAndPairCode(_staker, _depositNumber); 
        (uint256 _LP, uint256 _adjustedLP,, uint256 _lockTime) = yieldFarming.getLPinBatch(_staker, _pairCode, _batchNumber);
        return (_LP, _adjustedLP, _lockTime);
    }

    function isBatchValid(address _staker, uint256 _pairCode, uint256 _batchNumber)
        public view returns (bool)
    {

        (uint256 _LP,,,) = yieldFarming.getLPinBatch(_staker, _pairCode, _batchNumber);
        return _LP > 0;
    }

    function getTotalLiquidityTokenLockedInDAI(uint256 _pairCode) public view returns (uint256) {

        (,address pairPoolAddress,) = yieldFarming.getPairPool(_pairCode);
        uint256 balance = IUniswapV2Pair(pairPoolAddress).balanceOf(address(yieldFarming));
        uint256 totalSupply = IUniswapV2Pair(pairPoolAddress).totalSupply();
        uint256 percentLPinYieldFarm = balance.mul(base18).div(totalSupply);
        
        uint256 totalKtyInPairPool = IERC20(kittieFightTokenAddr).balanceOf(pairPoolAddress);

        return totalKtyInPairPool.mul(2).mul(percentLPinYieldFarm).mul(KTY_DAI_price())
               .div(base18).div(base18);
    }

    function getLPvalueInDai(uint256 _pairCode, uint256 _LP) public view returns (uint256) {

        (,address pairPoolAddress,) = yieldFarming.getPairPool(_pairCode);
    
        uint256 totalSupply = IUniswapV2Pair(pairPoolAddress).totalSupply();
        uint256 percentLPinYieldFarm = _LP.mul(base18).div(totalSupply);
        
        uint256 totalKtyInPairPool = IERC20(kittieFightTokenAddr).balanceOf(pairPoolAddress);

        return totalKtyInPairPool.mul(2).mul(percentLPinYieldFarm).mul(KTY_DAI_price())
               .div(base18).div(base18);
    }

    function getWalletBalance(address _staker, uint256 _pairCode) external view returns (uint256) {

        (,address pairPoolAddress,) = yieldFarming.getPairPool(_pairCode);
        return IUniswapV2Pair(pairPoolAddress).balanceOf(_staker);
    }

    function isProgramActive() external view returns (bool) {

        return block.timestamp >= yieldFarming.programStartAt() && block.timestamp <= yieldFarming.programEndAt();
    }


    function getReserve(address _tokenA, address _tokenB, address _pairPool)
        public view returns (uint256 reserveA, uint256 reserveB)
    {

        IUniswapV2Pair pair = IUniswapV2Pair(_pairPool);
        address token0 = pair.token0();
        if (token0 == _tokenA) {
            (reserveA,,) = pair.getReserves();
            (,reserveB,) = pair.getReserves();
        } else if (token0 == _tokenB) {
            (,reserveA,) = pair.getReserves();
            (reserveB,,) = pair.getReserves();
        }
    }

    function KTY_ETH_price() public view returns (uint256) {

        uint256 _amountKTY = 1e18;  // 1 KTY
        (uint256 _reserveKTY, uint256 _reserveETH) = getReserve(kittieFightTokenAddr, wethAddr, ktyWethPair);
        return UniswapV2Library.getAmountIn(_amountKTY, _reserveETH, _reserveKTY);
    } 

    function ETH_KTY_price() public view returns (uint256) {

        uint256 _amountETH = 1e18;  // 1 KTY
        (uint256 _reserveKTY, uint256 _reserveETH) = getReserve(kittieFightTokenAddr, wethAddr, ktyWethPair);
        return UniswapV2Library.getAmountIn(_amountETH, _reserveKTY, _reserveETH);
    }

    function DAI_ETH_price() public view returns (uint256) {

        uint256 _amountDAI = 1e18;  // 1 KTY
        (uint256 _reserveDAI, uint256 _reserveETH) = getReserve(daiAddr, wethAddr, daiWethPair);
        return UniswapV2Library.getAmountIn(_amountDAI, _reserveETH, _reserveDAI);
    }

    function ETH_DAI_price() public view returns (uint256) {

        uint256 _amountETH = 1e18;  // 1 KTY
        (uint256 _reserveDAI, uint256 _reserveETH) = getReserve(daiAddr, wethAddr, daiWethPair);
        return UniswapV2Library.getAmountIn(_amountETH, _reserveDAI, _reserveETH);
    }

    function KTY_DAI_price() public view returns (uint256) {

        uint256 etherPerKTY = KTY_ETH_price();
        uint256 daiPerEther = ETH_DAI_price();
        uint256 daiPerKTY = etherPerKTY.mul(daiPerEther).div(base18);
        return daiPerKTY;
    }

    function DAI_KTY_price() public view returns (uint256) {

        uint256 etherPerDAI = DAI_ETH_price();
        uint256 ktyPerEther = ETH_KTY_price();
        uint256 ktyPerDAI = etherPerDAI.mul(ktyPerEther).div(base18);
        return ktyPerDAI;
    }
   
}
contract YieldsCalculator is Ownable {

    using SafeMath for uint256;


    YieldFarming public yieldFarming;
    YieldFarmingHelper public yieldFarmingHelper;
    IVolcieToken public volcie;                                           // VolcieToken contract

    uint256 constant public base18 = 1000000000000000000;
    uint256 constant public base6 = 1000000;

    uint256 constant public MONTH = 30 days;// 30 * 24 * 60 * 60;  // MONTH duration is 30 days, to keep things standard
    uint256 constant public DAY = 1 days;// 24 * 60 * 60;
    uint256 constant DAILY_PORTION_IN_MONTH = 33333;

    uint256 constant public monthDays = MONTH / DAY;

    uint256 internal tokensSold;


    function initialize
    (
        uint256 _tokensSold,
        YieldFarming _yieldFarming,
        YieldFarmingHelper _yieldFarmingHelper,
        IVolcieToken _volcie
    ) 
        public initializer
    {
        Ownable.initialize(_msgSender());
        tokensSold = _tokensSold;
        setYieldFarming(_yieldFarming);
        setYieldFarmingHelper(_yieldFarmingHelper);
        setVolcieToken(_volcie);
    }


    function setYieldFarming(YieldFarming _yieldFarming) public onlyOwner {

        yieldFarming = _yieldFarming;
    }

    function setYieldFarmingHelper(YieldFarmingHelper _yieldFarmingHelper) public onlyOwner {

        yieldFarmingHelper = _yieldFarmingHelper;
    }

    function setVolcieToken(IVolcieToken _volcie) public onlyOwner {

        volcie = _volcie;
    }

    function setTokensSold(uint256 _tokensSold) public onlyOwner {

        tokensSold = _tokensSold;
    }


    function getMonth(uint256 _time) public view returns (uint256) {

        uint256 month;
        uint256 monthStartTime;

        for (uint256 i = 5; i >= 0; i--) {
            monthStartTime = yieldFarming.getMonthStartAt(i);
            if (_time >= monthStartTime) {
                month = i;
                break;
            }
        }
        return month;
    }

    function getDay(uint256 _time) public view returns (uint256) {

        uint256 _programStartAt = yieldFarming.programStartAt();
        if (_time <= _programStartAt) {
            return 0;
        }
        uint256 elapsedTime = _time.sub(_programStartAt);
        return elapsedTime.div(DAY);
    }

    function getLockedPeriod(address _staker, uint256 _batchNumber, uint256 _pairCode)
        public view
        returns (
            uint256 _startingMonth,
            uint256 _endingMonth,
            uint256 _daysInStartMonth
        )
    {

        uint256 _currentMonth = yieldFarming.getCurrentMonth();
        (,,,uint256 _lockedAt) = yieldFarming.getLPinBatch(_staker, _pairCode, _batchNumber);
        uint256 _startingDay = getDay(_lockedAt);
        uint256 _programEndAt = yieldFarming.programEndAt();

        _startingMonth = getMonth(_lockedAt); 
        _endingMonth = _currentMonth == 0 ? 0 : block.timestamp > _programEndAt ? 5 : _currentMonth.sub(1);
        _daysInStartMonth = 30 - getElapsedDaysInMonth(_startingDay, _startingMonth);
    }

    function getCurrentDay() public view returns (uint256) {

        uint256 programStartTime = yieldFarming.programStartAt();
        if (block.timestamp <= programStartTime) {
            return 0;
        }
        uint256 elapsedTime = block.timestamp.sub(programStartTime);
        uint256 currentDay = elapsedTime.div(DAY);
        return currentDay;
    }

    function getElapsedDaysInMonth(uint256 _days, uint256 _month) public view returns (uint256) {

        if (_month == 0) {
            return _days;
        }

        uint256 month0StartTime = yieldFarming.getMonthStartAt(0);
        uint256 dayInUnix = _days.mul(DAY).add(month0StartTime);
        uint256 monthStartTime = yieldFarming.getMonthStartAt(_month);
        if (dayInUnix <= monthStartTime) {
            return 0;
        }
        uint256 timeElapsed = dayInUnix.sub(monthStartTime);
        return timeElapsed.div(DAY);
    }

    function timeUntilCurrentMonthEnd() public view returns (uint) {

        uint256 nextMonth = yieldFarming.getCurrentMonth().add(1);
        if (nextMonth > 5) {
            if (block.timestamp >= yieldFarming.getMonthStartAt(5).add(MONTH)) {
                return 0;
            }
            return MONTH.sub(block.timestamp.sub(yieldFarming.getMonthStartAt(5)));
        }
        return yieldFarming.getMonthStartAt(nextMonth).sub(block.timestamp);
    }

    function calculateYields2(address _staker, uint256 _pairCode, uint256 startBatchNumber, uint256 lockedLP, uint256 startingLP)
        internal view
        returns (uint256 yieldsKTY, uint256 yieldsSDAO) {

        (uint256 _startingMonth, uint256 _endingMonth,) = getLockedPeriod(_staker, startBatchNumber, _pairCode);
        return calculateYields(_startingMonth, _endingMonth, lockedLP, startingLP);
    }

    function calculateYields(uint256 startMonth, uint256 endMonth, uint256 lockedLP, uint256 startingLP)
        internal view
        returns (uint256 yieldsKTY, uint256 yieldsSDAO)
    {

        (uint256 yields_part_1_KTY, uint256 yields_part_1_SDAO) = calculateYields_part_1(startMonth, startingLP);
        uint256 yields_part_2_KTY;
        uint256 yields_part_2_SDAO;
        if (endMonth > startMonth) {
            (yields_part_2_KTY, yields_part_2_SDAO) = calculateYields_part_2(startMonth, endMonth, lockedLP);
        }        
        return (yields_part_1_KTY.add(yields_part_2_KTY), yields_part_1_SDAO.add(yields_part_2_SDAO));
    }

    function calculateYields_part_1(uint256 startMonth, uint256 startingLP)
        internal view
        returns (uint256 yields_part_1_KTY, uint256 yields_part_1_SDAO)
    {

        uint256 rewardsKTYstartMonth = getTotalKTYRewardsByMonth(startMonth);
        uint256 rewardsSDAOstartMonth = getTotalSDAORewardsByMonth(startMonth);
        uint256 adjustedMonthlyDeposit = yieldFarming.getAdjustedTotalMonthlyDeposits(startMonth);

        yields_part_1_KTY = rewardsKTYstartMonth.mul(startingLP).div(adjustedMonthlyDeposit);
        yields_part_1_SDAO = rewardsSDAOstartMonth.mul(startingLP).div(adjustedMonthlyDeposit);
    }

    function calculateYields_part_2(uint256 startMonth, uint256 endMonth, uint256 lockedLP)
        internal view
        returns (uint256 yields_part_2_KTY, uint256 yields_part_2_SDAO)
    {

        uint256 adjustedMonthlyDeposit;
        for (uint256 i = startMonth.add(1); i <= endMonth; i++) {
            uint256 monthlyRewardsKTY = getTotalKTYRewardsByMonth(i);
            uint256 monthlyRewardsSDAO = getTotalSDAORewardsByMonth(i);
            adjustedMonthlyDeposit = yieldFarming.getAdjustedTotalMonthlyDeposits(i);
            yields_part_2_KTY = yields_part_2_KTY.add(monthlyRewardsKTY.mul(lockedLP).div(adjustedMonthlyDeposit));
            yields_part_2_SDAO = yields_part_2_SDAO.add(monthlyRewardsSDAO.mul(lockedLP).div(adjustedMonthlyDeposit));
        }
         
    }

    function calculateRewardsByBatchNumber(address _staker, uint256 _batchNumber, uint256 _pairCode)
        public view
        returns (uint256, uint256)
    {

        uint256 rewardKTY;
        uint256 rewardSDAO;

        if (!isBatchEligibleForRewards(_staker, _batchNumber, _pairCode)) {
            return(0, 0);
        }

        (,uint256 adjustedLockedLP, uint256 adjustedStartingLP,) = yieldFarming.getLPinBatch(_staker, _pairCode, _batchNumber);

        (rewardKTY, rewardSDAO) = calculateYields2(_staker, _pairCode, _batchNumber, adjustedLockedLP, adjustedStartingLP);

        if (block.timestamp >= yieldFarming.programEndAt()) {
            if (yieldFarming.isBatchEligibleForEarlyBonus(_staker, _batchNumber, _pairCode)) {
                uint256 _earlyBonus = getEarlyBonus(adjustedLockedLP);
                rewardKTY = rewardKTY.add(_earlyBonus);
                rewardSDAO = rewardSDAO.add(_earlyBonus);
            }
        }

        return (rewardKTY, rewardSDAO);
    }

    function isBatchEligibleForRewards(address _staker, uint256 _batchNumber, uint256 _pairCode)
        public view returns (bool)
    {

        (,,,uint256 lockedAt) = yieldFarming.getLPinBatch(_staker, _pairCode, _batchNumber);
      
        if (lockedAt == 0) {
            return false;
        }
        uint256 lockedPeriod = block.timestamp.sub(lockedAt);
        if (lockedPeriod >= MONTH) {
            return true;
        }
        return false;
    }

    function isDepositEligibleForEarlyBonus(address _staker, uint256 _depositNumber)
        public view returns (bool)
    {

        (uint256 _pairCode, uint256 _batchNumber) = yieldFarming.getBatchNumberAndPairCode(_staker, _depositNumber); 
        return yieldFarming.isBatchEligibleForEarlyBonus(_staker, _batchNumber, _pairCode);
    }

    function isVolcieEligibleForEarlyBonus(uint256 _volcieID)
        external view returns (bool)
    {

         (address _originalOwner, uint256 _depositNumber,,,,,,,,) = yieldFarming.getVolcieToken(_volcieID);
         return isDepositEligibleForEarlyBonus(_originalOwner, _depositNumber);
    }

    function getTotalRewards()
        external view
       returns (uint256[6] memory ktyRewards, uint256[6] memory sdaoRewards)
    {

        uint256 _ktyReward;
        uint256 _sdaoReward;
        for (uint256 i = 0; i < 6; i++) {
            _ktyReward = getTotalKTYRewardsByMonth(i);
            _sdaoReward = getTotalSDAORewardsByMonth(i);
            ktyRewards[i] = _ktyReward;
            sdaoRewards[i] = _sdaoReward;
        }
    }

    function getTotalKTYRewardsByMonth(uint256 _month)
        public view 
        returns (uint256)
    {

        uint256 _totalRewardsKTY = yieldFarming.totalRewardsKTY();
        (uint256 _KTYunlockRate,) = yieldFarming.getRewardUnlockRateByMonth(_month);
        uint256 _earlyBonus = yieldFarming.EARLY_MINING_BONUS();
        return (_totalRewardsKTY.sub(_earlyBonus)).mul(_KTYunlockRate).div(base6);
    }

    function getTotalSDAORewardsByMonth(uint256 _month)
        public view 
        returns (uint256)
    {

        uint256 _totalRewardsSDAO = yieldFarming.totalRewardsSDAO();
        (,uint256 _SDAOunlockRate) = yieldFarming.getRewardUnlockRateByMonth(_month);
        uint256 _earlyBonus = yieldFarming.EARLY_MINING_BONUS();
        return (_totalRewardsSDAO.sub(_earlyBonus)).mul(_SDAOunlockRate).div(base6);
    }

    function getEarlyBonus(uint256 _amountLP)
        public view returns (uint256)
    {

        uint256 _earlyBonus = yieldFarming.EARLY_MINING_BONUS();
        uint256 _adjustedTotalLockedLPinEarlyMining = yieldFarming.adjustedTotalLockedLPinEarlyMining();
    
        return _amountLP.mul(_earlyBonus).div(_adjustedTotalLockedLPinEarlyMining);
    }

    function getEarlyBonusForVolcie(uint256 _volcieID) external view returns (uint256) {

        (,,,uint256 _LP,,,,,,) = yieldFarming.getVolcieToken(_volcieID);
        return getEarlyBonus(_LP);
    }

    function calculateRewardsByDepositNumber(address _staker, uint256 _depositNumber)
        public view
        returns (uint256, uint256)
    {

        (uint256 _pairCode, uint256 _batchNumber) = yieldFarming.getBatchNumberAndPairCode(_staker, _depositNumber); 
        (uint256 _rewardKTY, uint256 _rewardSDAO) = calculateRewardsByBatchNumber(_staker, _batchNumber, _pairCode);
        return (_rewardKTY, _rewardSDAO);
    }

    function getTotalLPsLocked(address _staker) public view returns (uint256) {

        uint256 _totalPools = yieldFarming.totalNumberOfPairPools();
        uint256 _totalLPs;
        uint256 _LP;
        for (uint256 i = 0; i < _totalPools; i++) {
            _LP = yieldFarming.getLockedLPbyPairCode(_staker, i);
            _totalLPs = _totalLPs.add(_LP);
        }
        return _totalLPs;
    }

    function getRewardMultipliers(address _staker) external view returns (uint256, uint256) {

        uint256 totalLPs = getTotalLPsLocked(_staker);
        if (totalLPs == 0) {
            return (0, 0);
        }
        uint256 totalRewards = yieldFarming.totalRewardsKTY();
        (uint256 rewardsKTY, uint256 rewardsSDAO) = getRewardsToClaim(_staker);
        uint256 rewardMultiplierKTY = rewardsKTY.mul(base6).mul(totalRewards).div(tokensSold).div(totalLPs);
        uint256 rewardMultiplierSDAO = rewardsSDAO.mul(base6).mul(totalRewards).div(tokensSold).div(totalLPs);
        return (rewardMultiplierKTY, rewardMultiplierSDAO);
    }

    function getAccruedRewards(address _staker) public view returns (uint256, uint256) {

        uint256[2] memory rewardsClaimed = yieldFarming.getTotalRewardsClaimedByStaker(_staker);
        uint256 _claimedKTY = rewardsClaimed[0];
        uint256 _claimedSDAO = rewardsClaimed[1];

        (uint256 _KTYtoClaim, uint256 _SDAOtoClaim) = getRewardsToClaim(_staker);

        return (_claimedKTY.add(_KTYtoClaim), _claimedSDAO.add(_SDAOtoClaim));  
    }

    function getRewardsToClaim(address _staker) internal view returns (uint256, uint256) {

        uint256 _KTY = 0;
        uint256 _SDAO = 0;
        uint256 _ktyRewards;
        uint256 _sdaoRewards;
       
        uint256[] memory allVolcies = volcie.allTokenOf(_staker);
        for (uint256 i = 0; i < allVolcies.length; i++) {
            (,, _ktyRewards, _sdaoRewards) = getVolcieValues(allVolcies[i]);
            _KTY = _KTY.add(_ktyRewards);
            _SDAO = _SDAO.add(_sdaoRewards);
        }

        return (_KTY, _SDAO);  
    }

    function getFirstMonthAmount(
        uint256 startDay,
        uint256 startMonth,
        uint256 adjustedMonthlyDeposit,
        uint256 _LP
    )
    public view returns(uint256)
    {        

        uint256 monthlyProportion = getElapsedDaysInMonth(startDay, startMonth);
        return adjustedMonthlyDeposit
            .mul(_LP.mul(monthDays.sub(monthlyProportion)))
            .div(adjustedMonthlyDeposit.add(monthlyProportion.mul(_LP).div(monthDays)))
            .div(monthDays);
    }

    function estimateRewards(uint256 _LP, uint256 _pairCode) external view returns (uint256, uint256) {

        uint256 startMonth = yieldFarming.getCurrentMonth();
        uint256 startDay = getCurrentDay();
        uint256 factor = yieldFarmingHelper.bubbleFactor(_pairCode);
        uint256 adjustedLP = _LP.mul(base6).div(factor);
        
        uint256 adjustedMonthlyDeposit = yieldFarming.getAdjustedTotalMonthlyDeposits(startMonth);

        adjustedMonthlyDeposit = adjustedMonthlyDeposit.add(adjustedLP);

        uint256 currentDepositedAmount = getFirstMonthAmount(startDay, startMonth, adjustedMonthlyDeposit, adjustedLP);

        (uint256 _KTY, uint256 _SDAO) = estimateYields(startMonth, 5, adjustedLP, currentDepositedAmount, adjustedMonthlyDeposit);

        uint256 startTime = yieldFarming.programStartAt();
        if (block.timestamp <= startTime.add(DAY.mul(21))){
            uint256 _earlyBonus = _estimateEarlyBonus(adjustedLP);
            _KTY = _KTY.add(_earlyBonus);
            _SDAO = _SDAO.add(_earlyBonus);
        }

        return (_KTY, _SDAO);
    }

    function estimateYields(uint256 startMonth, uint256 endMonth, uint256 lockedLP, uint256 startingLP, uint256 adjustedMonthlyDeposit)
        internal view
        returns (uint256, uint256)
    {

        (uint256 yields_part_1_KTY, uint256 yields_part_1_SDAO)= estimateYields_part_1(startMonth, startingLP, adjustedMonthlyDeposit);
        uint256 yields_part_2_KTY;
        uint256 yields_part_2_SDAO;
        if (endMonth > startMonth) {
            (yields_part_2_KTY, yields_part_2_SDAO) = estimateYields_part_2(startMonth, endMonth, lockedLP, adjustedMonthlyDeposit);
        }
        return (yields_part_1_KTY.add(yields_part_2_KTY), yields_part_1_SDAO.add(yields_part_2_SDAO));
    }

    function estimateYields_part_1(uint256 startMonth, uint256 startingLP, uint256 adjustedMonthlyDeposit)
        internal view
        returns (uint256 yieldsKTY_part_1, uint256 yieldsSDAO_part_1)
    {

        uint256 rewardsKTYstartMonth = getTotalKTYRewardsByMonth(startMonth);
        uint256 rewardsSDAOstartMonth = getTotalSDAORewardsByMonth(startMonth);

        yieldsKTY_part_1 = rewardsKTYstartMonth.mul(startingLP).div(adjustedMonthlyDeposit);
        yieldsSDAO_part_1 = rewardsSDAOstartMonth.mul(startingLP).div(adjustedMonthlyDeposit);
    }

    function estimateYields_part_2(uint256 startMonth, uint256 endMonth, uint256 lockedLP, uint256 adjustedMonthlyDeposit)
        internal view
        returns (uint256 yieldsKTY_part_2, uint256 yieldsSDAO_part_2)
    {

        for (uint256 i = startMonth.add(1); i <= endMonth; i++) {
            uint256 monthlyRewardsKTY = getTotalKTYRewardsByMonth(i);
            uint256 monthlyRewardsSDAO = getTotalSDAORewardsByMonth(i);

            yieldsKTY_part_2 = yieldsKTY_part_2
                .add(monthlyRewardsKTY.mul(lockedLP).div(adjustedMonthlyDeposit));
            yieldsSDAO_part_2 = yieldsSDAO_part_2
                .add(monthlyRewardsSDAO.mul(lockedLP).div(adjustedMonthlyDeposit));
        }
         
    }

    function estimateEarlyBonus(uint256 _LP, uint256 _pairCode)
        public view returns (uint256)
    {

        uint256 factor = yieldFarmingHelper.bubbleFactor(_pairCode);
        uint256 adjustedLP = _LP.mul(base6).div(factor);
        return _estimateEarlyBonus(adjustedLP);
    }

    function _estimateEarlyBonus(uint256 adjustedLP)
        internal view returns (uint256)
    {

        uint256 _earlyBonus = yieldFarming.EARLY_MINING_BONUS();
        uint256 _adjustedTotalLockedLPinEarlyMining = yieldFarming.adjustedTotalLockedLPinEarlyMining();
        _adjustedTotalLockedLPinEarlyMining = _adjustedTotalLockedLPinEarlyMining.add(adjustedLP);
        return adjustedLP.mul(_earlyBonus).div(_adjustedTotalLockedLPinEarlyMining);
    }

    function getVolcieValues(uint256 _volcieID)
        public view returns (uint256, uint256, uint256, uint256)
    {

        (address _originalOwner, uint256 _depositNumber,,uint256 _LP,uint256 _pairCode,,,,,) = yieldFarming.getVolcieToken(_volcieID);
        uint256 _LPvalueInDai = yieldFarmingHelper.getLPvalueInDai(_pairCode, _LP);
        (uint256 _KTY, uint256 _SDAO) = calculateRewardsByDepositNumber(_originalOwner, _depositNumber);
        return (_LP, _LPvalueInDai, _KTY, _SDAO);
    }

}