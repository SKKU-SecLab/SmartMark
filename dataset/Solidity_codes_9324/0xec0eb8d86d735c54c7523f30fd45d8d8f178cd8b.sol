

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;


abstract contract Context {

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

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

contract CoreUniLotterySettings {

    uint32 public constant PERCENT = 10 ** 6;
    uint32 constant BASIS_POINT = PERCENT / 100;

    uint32 constant _100PERCENT = 100 * PERCENT;



    address payable public constant OWNER_ADDRESS =
        address( uint160( 0x1Ae51bec001a4fA4E3b06A5AF2e0df33A79c01e2 ) );


    uint32 constant MAX_OWNER_LOTTERY_FEE = 1 * PERCENT;

    uint32 constant MIN_WINNER_PROFIT_SHARE = 40 * PERCENT;

    uint32 constant MIN_OWNER_PROFITS = 3 * PERCENT;
    uint32 constant MAX_OWNER_PROFITS = 10 * PERCENT;

    uint32 constant MIN_POOL_PROFITS = 10 * PERCENT;
    uint32 constant MAX_POOL_PROFITS = 60 * PERCENT;

    uint32 constant MAX_LOTTERY_LIFETIME = 4 weeks;

    uint32 constant LOTTERY_RAND_CALLBACK_GAS = 200000;
    uint32 constant AUTO_MODE_SCHEDULED_CALLBACK_GAS = 3800431;
}

interface IUniswapRouter {

    function factory()  external pure returns (address);

    function WETH()     external pure returns (address);


    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline )                 
                                        external 
                                        payable 
        returns (
            uint amountToken, 
            uint amountETH, 
            uint liquidity 
        );


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline ) 
                                        external
        returns (
            uint amountETH
        );


    function getAmountsOut(
        uint amountIn, 
        address[] memory path ) 
                                        external view 
        returns (
            uint[] memory amounts
        );


    function getAmountsIn(
        uint amountOut, 
        address[] memory path )
                                        external view
        returns (
            uint[] memory amounts
        );

}

interface IUniswapFactory {

    function getPair(
        address tokenA, 
        address tokenB )
                                        external view 
    returns ( address pair );

}

interface IUniswapPair is IERC20
{

    function token0() external view returns (address);

    function token1() external view returns (address);


    function getReserves() 
                                        external view 
    returns (
        uint112 reserve0, 
        uint112 reserve1,
        uint32 blockTimestampLast
    );

}

interface IUniLotteryPool {

    function lotteryFinish( uint totalReturn, uint profitAmount )
    external payable;

}

interface IRandomnessProvider {

    function requestRandomSeedForLotteryFinish()    external;

}

contract Lottery is ERC20, CoreUniLotterySettings
{


    event LotteryInitialized();

    event LotteryEnd(
        uint128 totalReturn,
        uint128 profitAmount
    );

    event RandomnessProviderCalled();

    event FinishingStageStarted();

    event FinishingStageStopped();

    event ReferralIDGenerated(
        address referrer,
        uint256 id
    );

    event ReferralRegistered(
        address referree,
        address referrer,
        uint256 id
    );

    event FallbackEtherReceiver(
        address sender,
        uint value
    );



    enum STAGE
    {
        INITIAL,

        ACTIVE,

        FINISHING,

        ENDING_MINING,

        COMPLETION,

        DISABLED
    }


    enum EndingAlgoType
    {
        MinedWinnerSelection,

        WinnerSelfValidation,

        RolledRandomness
    }


    struct LotteryConfig
    {


        uint initialFunds;



        uint128 fundRequirement_denySells;

        uint128 finishCriteria_minFunds;



        uint32 maxLifetime;

        uint32 prizeClaimTime;

        uint32 burn_buyerRate;
        uint32 burn_defaultRate;

        uint32 maxAmountForWallet_percentageOfSupply;

        uint32 REQUIRED_TIME_WAITING_FOR_RANDOM_SEED;
        
        


        uint32 poolProfitShare;
        uint32 ownerProfitShare;


        uint32 minerProfitShare;
        
        



        uint32 finishCriteria_minNumberOfHolders;

        uint32 finishCriteria_minTimeActive;

        uint32 finish_initialProbability;

        uint32 finish_probabilityIncreaseStep_transaction;
        uint32 finish_probabilityIncreaseStep_holder;



        int16 maxPlayerScore_etherContributed;
        int16 maxPlayerScore_tokenHoldingAmount;
        int16 maxPlayerScore_timeFactor;
        int16 maxPlayerScore_refferalBonus;


        uint16 randRatio_scorePart;
        uint16 randRatio_randPart;

        uint16 timeFactorDivisor;

        int16 playerScore_referralRegisteringBonus;


        bool finish_resetProbabilityOnStop;





        uint32 prizeSequenceFactor;

        
        uint16 prizeSequence_winnerCount;

        uint16 prizeSequence_sequencedWinnerCount;

        uint48 initialTokenSupply;

        uint8 endingAlgoType;



        uint32[] winnerProfitShares;

    }





    uint32 constant MIN_MINER_PROFITS = 1 * PERCENT;
    uint32 constant MAX_MINER_PROFITS = 10 * PERCENT;


    IUniswapRouter constant uniswapRouter = IUniswapRouter(
        address( 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ) );


    string constant public name = "UniLottery Token";
    string constant public symbol = "ULT";
    uint256 constant public decimals = 18;




    LotteryConfig internal cfg;


    LotteryStorage public lotStorage;


    address payable public poolAddress;

    
    address public randomnessProvider;


    address public exchangeAddress;

    uint32 public startDate;

    uint32 public completionDate;
    
    uint32 finish_timeRandomSeedRequested;


    address WETHaddress;

    bool uniswap_ethFirst;

    uint32 finishProbablity;
    
    bool reEntrancyMutexLocked;
    
    uint8 public lotteryStage;
    
    bool fundGainRequirementReached;
    
    uint16 miningStep;

    bool specialTransferModeEnabled;


    
    uint256 transferHashValue;


    uint128 public ending_totalReturn;
    uint128 public ending_profitAmount;


    mapping( address => bool ) public prizeClaimersAddresses;




    modifier poolOnly {

        require( msg.sender == poolAddress/*,
                 "Function can be called only by the pool!" */);
        _;
    }

    modifier randomnessProviderOnly {

        require( msg.sender == randomnessProvider/*,
                 "Function can be called only by the UniLottery"
                 " Randomness Provider!" */);
        _;
    }

    modifier onlyOnStage( STAGE _stage ) 
    {

        require( lotteryStage == uint8( _stage )/*,
                 "Function cannot be called on current stage!" */);
        _;
    }

    modifier mutexLOCKED
    {

        require( ! reEntrancyMutexLocked/*, 
                    "Re-Entrant Calls are NOT ALLOWED!" */);

        reEntrancyMutexLocked = true;
        _;
        reEntrancyMutexLocked = false;
    }


    function onStage( STAGE _stage )
                                                internal view
    returns( bool )
    {

        return ( lotteryStage == uint8( _stage ) );
    }


    function transferExceedsMaxBalance( 
            address holder, uint amount )
                                                internal view
    returns( bool )
    {

        uint maxAllowedBalance = 
            ( totalSupply() * cfg.maxAmountForWallet_percentageOfSupply ) /
            ( _100PERCENT );

        return ( ( balanceOf( holder ) + amount ) > maxAllowedBalance );
    }


    function updateHolderData_preTransfer(
            address sender,
            address receiver,
            uint256 amountSent,
            uint256 amountReceived )
                                                internal
    returns( bool holderCountChanged )
    {

        holderCountChanged = false;

        if( balanceOf( sender ) == amountSent ) 
        {
            lotStorage.removeHolder( sender );
            holderCountChanged = true;
        }

        if( balanceOf( receiver ) == 0 && amountReceived > 0 )
        {
            lotStorage.addHolder( receiver );
            holderCountChanged = true;
        }



        int buySellValue;

        if( sender == exchangeAddress && receiver != exchangeAddress ) 
        {
            address[] memory path = new address[]( 2 );
            path[ 0 ] = WETHaddress;
            path[ 1 ] = address(this);

            uint[] memory ethAmountIn = uniswapRouter.getAmountsIn(
                amountSent,     // uint amountOut, 
                path            // address[] path
            );

            buySellValue = int( ethAmountIn[ 0 ] );
            
            int timeFactorValue = ( buySellValue / (1 ether / 100) ) * 
                int( (block.timestamp - startDate) / cfg.timeFactorDivisor );

            if( timeFactorValue == 0 )
                timeFactorValue = 1;

            lotStorage.updateAndPropagateScoreChanges(
                    receiver,
                    int80( buySellValue ),
                    int80( timeFactorValue ),
                    int80( amountReceived ) );
        }

        else if( sender != exchangeAddress && receiver == exchangeAddress )
        {
            address[] memory path = new address[]( 2 );
            path[ 0 ] = address(this);
            path[ 1 ] = WETHaddress;

            uint[] memory ethAmountOut = uniswapRouter.getAmountsOut(
                amountReceived,     // uint amountIn
                path                // address[] path
            );

            buySellValue = int( -1 ) * int( ethAmountOut[ 1 ] );
            
            int timeFactorValue = ( buySellValue / (1 ether / 100) ) * 
                int( (block.timestamp - startDate) / cfg.timeFactorDivisor );

            if( timeFactorValue == 0 )
                timeFactorValue = -1;

            lotStorage.updateAndPropagateScoreChanges(
                    sender,
                    int80( buySellValue ),
                    int80( timeFactorValue ),
                    -1 * int80( amountSent ) );
        }

        else {
            buySellValue = 0;

            lotStorage.updateAndPropagateScoreChanges( sender, 0, 0, 
                                            -1 * int80( amountSent ) );

            lotStorage.updateAndPropagateScoreChanges( receiver, 0, 0, 
                                            int80( amountReceived ) );
        }

        uint ethFunds = getCurrentEthFunds();

        if( !fundGainRequirementReached &&
            ethFunds >= cfg.fundRequirement_denySells )
        {
            fundGainRequirementReached = true;
        }


        if( fundGainRequirementReached &&
            buySellValue < 0 &&
            ( uint( -1 * buySellValue ) >= ethFunds ||
              ethFunds - uint( -1 * buySellValue ) < 
                cfg.fundRequirement_denySells ) )
        {
            require( false/*, "This sell would drop the lottery ETH funds"
                            "below the minimum requirement threshold!" */);
        }
    }
    
    
    function checkFinishingStageConditions()
                                                    internal
    {

        if( (block.timestamp - startDate) > cfg.maxLifetime ) 
        {
            lotteryStage = uint8( STAGE.FINISHING );
            return;
        }



        if( lotStorage.getHolderCount() >= cfg.finishCriteria_minNumberOfHolders
            &&
            getCurrentEthFunds() >= cfg.finishCriteria_minFunds
            &&
            (block.timestamp - startDate) >= cfg.finishCriteria_minTimeActive )
        {
            if( onStage( STAGE.ACTIVE ) )
            {
                lotteryStage = uint8( STAGE.FINISHING );

                emit FinishingStageStarted();
            }
        }

        else if( onStage( STAGE.FINISHING ) )
        {

            lotteryStage = uint8( STAGE.ACTIVE );

            if( cfg.finish_resetProbabilityOnStop )
                finishProbablity = cfg.finish_initialProbability;

            emit FinishingStageStopped();
        }
    }


    function checkForEnding( bool holderCountChanged )
                                                            internal
    {

        if( (block.timestamp - startDate) > cfg.maxLifetime )
        {
            startEndingStage();
            return;
        }

        uint prec = 10000;
        uint modAmount = (prec * _100PERCENT) / finishProbablity;

        if( ( transferHashValue % modAmount ) <= prec )
        {
            startEndingStage();
            return;
        }



        finishProbablity += cfg.finish_probabilityIncreaseStep_transaction;

        if( holderCountChanged )
            finishProbablity += cfg.finish_probabilityIncreaseStep_holder;
    }


    function startEndingStage()
                                                internal
    {

        lotteryStage = uint8( STAGE.ENDING_MINING );
    }


    function mine_requestRandomSeed()
                                                internal
    {


        IRandomnessProvider( randomnessProvider )
            .requestRandomSeedForLotteryFinish();

        finish_timeRandomSeedRequested = uint32( block.timestamp );

        emit RandomnessProviderCalled();
    }


    function mine_removeUniswapLiquidityAndTransferProfits()
                                                                internal
                                                                mutexLOCKED
    {

        ERC20( exchangeAddress ).approve( address(uniswapRouter), uint(-1) );

        specialTransferModeEnabled = true;

        uint amountETH = uniswapRouter
            .removeLiquidityETHSupportingFeeOnTransferTokens(
                address(this),          // address token,
                ERC20( exchangeAddress ).balanceOf( address(this) ),
                0,                      // uint amountTokenMin,
                0,                      // uint amountETHMin,
                address(this),          // address to,
                (block.timestamp + 10000000)        // uint deadline
            );

        specialTransferModeEnabled = false;

        require( address(this).balance >= amountETH &&
                 address(this).balance >= cfg.initialFunds/*,
                 "Incorrect amount of ETH received from Uniswap!" */);


        ending_totalReturn = uint128( address(this).balance );
        ending_profitAmount = ending_totalReturn - uint128( cfg.initialFunds );


        uint poolShare = ( ending_profitAmount * cfg.poolProfitShare ) /
                         ( _100PERCENT );

        uint ownerShare = ( ending_profitAmount * cfg.ownerProfitShare ) /
                          ( _100PERCENT );

        IUniLotteryPool( poolAddress ).lotteryFinish
            { value: poolShare + cfg.initialFunds }
            ( ending_totalReturn, ending_profitAmount );

        OWNER_ADDRESS.transfer( ownerShare );

        emit LotteryEnd( ending_totalReturn, ending_profitAmount );
    }


    function mine_executeEndingAlgorithmStep()
                                                            internal
    {

        lotStorage.executeWinnerSelectionAlgorithm();
    }





    constructor()
    {
        lotteryStage = uint8( STAGE.DISABLED );
    }


    function construct( 
            LotteryConfig memory config,
            address payable _poolAddress,
            address _randomProviderAddress,
            address _storageAddress )
                                                        external
    {

        require( poolAddress == address( 0 )/*,
                 "Contract is already constructed!" */);

        poolAddress = _poolAddress;

        randomnessProvider = _randomProviderAddress;



        require( config.maxLifetime <= MAX_LOTTERY_LIFETIME/*,
                 "Lottery maximum lifetime is too high!" */);

        require( config.poolProfitShare >= MIN_POOL_PROFITS &&
                 config.poolProfitShare <= MAX_POOL_PROFITS/*,
                 "Pool profit share is invalid!" */);

        require( config.ownerProfitShare >= MIN_OWNER_PROFITS &&
                 config.ownerProfitShare <= MAX_OWNER_PROFITS/*,
                 "Owner profit share is invalid!" */);

        require( config.minerProfitShare >= MIN_MINER_PROFITS &&
                 config.minerProfitShare <= MAX_MINER_PROFITS/*,
                 "Miner profit share is invalid!" */);

        require( config.timeFactorDivisor >= 2 minutes /*,
                 "Time factor divisor is lower than 2 minutes!"*/ );

        uint32 totalWinnerShare = 
            (_100PERCENT) - config.poolProfitShare
                            - config.ownerProfitShare
                            - config.minerProfitShare;

        require( totalWinnerShare >= MIN_WINNER_PROFIT_SHARE/*,
                 "Winner profit share is too low!" */);

        require( config.randRatio_scorePart != 0    &&
                 config.randRatio_randPart  != 0    &&
                 ( config.randRatio_scorePart + 
                   config.randRatio_randPart    ) < 10000/*,
                 "Random Ratio params are invalid!" */);

        require( config.endingAlgoType == 
                    uint8( EndingAlgoType.MinedWinnerSelection ) ||
                 config.endingAlgoType == 
                    uint8( EndingAlgoType.WinnerSelfValidation ) ||
                 config.endingAlgoType == 
                    uint8( EndingAlgoType.RolledRandomness )/*,
                 "Wrong Ending Algorithm Type!" */);

        if( config.prizeSequence_winnerCount == 0 &&
            config.winnerProfitShares.length != 0 )
            config.prizeSequence_winnerCount = 
                uint16( config.winnerProfitShares.length );



        LotteryStorage _lotStorage = LotteryStorage( _storageAddress );

        LotteryStorage.WinnerAlgorithmConfig memory winnerConfig;

        winnerConfig.endingAlgoType = config.endingAlgoType;

        winnerConfig.maxPlayerScore_etherContributed =
            config.maxPlayerScore_etherContributed;

        winnerConfig.maxPlayerScore_tokenHoldingAmount =
            config.maxPlayerScore_tokenHoldingAmount;

        winnerConfig.maxPlayerScore_timeFactor =
            config.maxPlayerScore_timeFactor;

        winnerConfig.maxPlayerScore_refferalBonus =
            config.maxPlayerScore_refferalBonus;

        winnerConfig.randRatio_scorePart = config.randRatio_scorePart;
        winnerConfig.randRatio_randPart = config.randRatio_randPart;

        winnerConfig.winnerCount = config.prizeSequence_winnerCount;


        _lotStorage.initialize( winnerConfig );

        lotStorage = _lotStorage;


        cfg = config;

        WETHaddress = uniswapRouter.WETH();
    }


    receive()       external payable
    {
        emit FallbackEtherReceiver( msg.sender, msg.value );
    }



    function initialize()   
                                        external
                                        payable
                                        poolOnly
                                        mutexLOCKED
                                        onlyOnStage( STAGE.INITIAL )
    {

        require( address( this ).balance == cfg.initialFunds/*,
                 "Invalid amount of funds transfered!" */);

        startDate = uint32( block.timestamp );

        transferHashValue = uint( keccak256( 
                abi.encodePacked( msg.sender, block.timestamp ) ) );

        finishProbablity = cfg.finish_initialProbability;
        
        

        _mint( address(this), 
               uint( cfg.initialTokenSupply ) * (10 ** decimals) );

        
        _approve( address(this), address( uniswapRouter ), uint(-1) );

        
        uniswapRouter.addLiquidityETH 
        { value: address(this).balance }
        (
            address(this),          // address token,
            totalSupply(),          // uint amountTokenDesired,
            totalSupply(),          // uint amountTokenMin,
            address(this).balance,  // uint amountETHMin,
            address(this),          // address to,
            (block.timestamp + 1000)            // uint deadline
        );

        exchangeAddress = IUniswapFactory( uniswapRouter.factory() )
            .getPair( WETHaddress, address(this) );


        if( IUniswapPair( exchangeAddress ).token0() == WETHaddress )
            uniswap_ethFirst = true;
        else
            uniswap_ethFirst = false;


        lotteryStage = uint8( STAGE.ACTIVE );

        emit LotteryInitialized();
    }


    function getInitialFunds()          external view
    returns( uint )
    {

        return cfg.initialFunds;
    }

    function getActiveInitialFunds()    external view
    returns( uint )
    {

        if( onStage( STAGE.ACTIVE ) )
            return cfg.initialFunds;
        return 0;
    }


    function getReserves() 
                                                        external view
    returns( uint _ethReserve, uint _tokenReserve )
    {

        ( uint112 res0, uint112 res1, ) = 
            IUniswapPair( exchangeAddress ).getReserves();

        if( uniswap_ethFirst )
            return ( res0, res1 );
        else
            return ( res1, res0 );
    }


    function getCurrentEthFunds()
                                                        public view
    returns( uint ethAmount )
    {

        IUniswapPair pair = IUniswapPair( exchangeAddress );
        
        ( uint112 res0, uint112 res1, ) = pair.getReserves();
        uint resEth = uint( uniswap_ethFirst ? res0 : res1 );

        uint liqTokenPercentage = 
            ( pair.balanceOf( address(this) ) * (_100PERCENT) ) /
            ( pair.totalSupply() );

        return ( resEth * liqTokenPercentage ) / (_100PERCENT);
    }


    function getFinishProbability()
                                                        external view
    returns( uint32 )
    {

        if( onStage( STAGE.FINISHING ) )
            return finishProbablity;
        return 0;
    }


    
    function generateReferralID()
                                        external
                                        onlyOnStage( STAGE.ACTIVE )
    {

        uint256 refID = lotStorage.generateReferralID( msg.sender );

        emit ReferralIDGenerated( msg.sender, refID );
    }


    function registerReferral( 
            uint256 referralID )
                                        external
                                        onlyOnStage( STAGE.ACTIVE )
    {

        address referrer = lotStorage.registerReferral( 
                msg.sender,
                cfg.playerScore_referralRegisteringBonus,
                referralID );

        emit ReferralRegistered( msg.sender, referrer, referralID );
    }


    function _transfer( address sender,
                        address receiver,
                        uint256 amount )
                                            internal
                                            override
    {


        if( !onStage( STAGE.ACTIVE )    &&
            !onStage( STAGE.FINISHING ) &&
            ( sender == address(this) || receiver == address(this) ||
              specialTransferModeEnabled ) )
        {
            super._transfer( sender, receiver, amount );
            return;
        }

        require( ( onStage( STAGE.ACTIVE ) || 
                   onStage( STAGE.FINISHING ) )/*,
                 "Token transfers are only allowed on ACTIVE stage!" */);
                 
        require( amount != 0 && sender != address(0)/*,
                 "Amount is zero, or transfering from zero address." */);


        uint burnAmount;

        if( sender == exchangeAddress )
            burnAmount = ( amount * cfg.burn_buyerRate ) / (_100PERCENT);
        else
            burnAmount = ( amount * cfg.burn_defaultRate ) / (_100PERCENT);
        
        uint finalAmount = amount - burnAmount;

        if( receiver != exchangeAddress )
        {
            require( !transferExceedsMaxBalance( receiver, finalAmount )/*,
                "Receiver's balance would exceed maximum after transfer!"*/);
        }

        bool holderCountChanged = updateHolderData_preTransfer( 
                sender, 
                receiver, 
                amount,             // Amount Sent (Pre-Fees)
                finalAmount         // Amount Received (Post-Fees).
        );


        super._burn( sender, burnAmount );

        super._transfer( sender, receiver, finalAmount );



        transferHashValue = uint( keccak256( abi.encodePacked(
            transferHashValue, msg.sender, sender, receiver, amount ) ) );


        checkFinishingStageConditions();

        if( onStage( STAGE.FINISHING ) )
            checkForEnding( holderCountChanged );
    }


    function finish_randomnessProviderCallback(
            uint256 randomSeed,
            uint256 /*callID*/ )
                                                external
                                                randomnessProviderOnly
    {

        lotStorage.setRandomSeed( randomSeed );

        if( cfg.endingAlgoType != uint8(EndingAlgoType.MinedWinnerSelection) )
        {
            lotteryStage = uint8( STAGE.COMPLETION );
            completionDate = uint32( block.timestamp );
        }
    }


    function alternativeSeedGenerationPossible()
                                                        internal view
    returns( bool )
    {

        return ( onStage( STAGE.ENDING_MINING ) &&
                 ( (block.timestamp - finish_timeRandomSeedRequested) >
                   cfg.REQUIRED_TIME_WAITING_FOR_RANDOM_SEED ) );
    }




    function isMiningAvailable()
                                                    external view
    returns( bool )
    {

        return onStage( STAGE.ENDING_MINING ) && 
               ( miningStep == 0 || 
                 ( miningStep == 1 && 
                   ( lotStorage.getRandomSeed() != 0 ||
                     alternativeSeedGenerationPossible() )
                 ) );
    }


    function mine()
                                external
                                onlyOnStage( STAGE.ENDING_MINING )
    {

        uint currentStepReward;


        if( miningStep == 0 )
        {
            mine_requestRandomSeed();
            mine_removeUniswapLiquidityAndTransferProfits();

            uint totalMinerRewards = 
                ( ending_profitAmount * cfg.minerProfitShare ) / 
                ( _100PERCENT );

            if( cfg.endingAlgoType == uint8(EndingAlgoType.MinedWinnerSelection) )
            {
                currentStepReward = ( totalMinerRewards * (10 * PERCENT) ) /
                                    ( _100PERCENT );
            }
            else
            {
                currentStepReward = ( totalMinerRewards * (80 * PERCENT) ) /
                                    ( _100PERCENT );
            }

            require( currentStepReward <= totalMinerRewards/*, "BUG 1694" */);
        }

        else
        {
            if( cfg.endingAlgoType != uint8(EndingAlgoType.MinedWinnerSelection) )
            {
                require( lotStorage.getRandomSeed() == 0 &&
                         alternativeSeedGenerationPossible()/*,
                         "Second Mining Step is not available for "
                         "current Algo-Type on these conditions!" */);
            }

            uint totalMinerRewards = 
                ( ending_profitAmount * cfg.minerProfitShare ) / 
                ( _100PERCENT );

            if( lotStorage.getRandomSeed() == 0 )
            {
                if( alternativeSeedGenerationPossible() )
                {
                    lotStorage.setRandomSeed( transferHashValue );

                    if( cfg.endingAlgoType != 
                        uint8(EndingAlgoType.MinedWinnerSelection) )
                    {
                        currentStepReward = 
                            ( totalMinerRewards * (20 * PERCENT) ) /
                            ( _100PERCENT );
                    }
                }
                else
                {
                    require( false/*, "Mining not yet available!" */);
                }
            }

            if( cfg.endingAlgoType == uint8(EndingAlgoType.MinedWinnerSelection) )
            {
                mine_executeEndingAlgorithmStep();

                currentStepReward = ( totalMinerRewards * (90 * PERCENT) ) /
                                    ( _100PERCENT );
            }


            lotteryStage = uint8( STAGE.COMPLETION );
            completionDate = uint32( block.timestamp );

            require( currentStepReward <= totalMinerRewards/*, "BUG 2007" */);
        }


        miningStep++;

        require( ! reEntrancyMutexLocked/*, "Re-Entrant call detected!" */);
        reEntrancyMutexLocked = true;

        msg.sender.transfer( currentStepReward );

        reEntrancyMutexLocked = false;
    }


    function getWinnerPrizeAmount(
            uint rankingPosition )
                                                        public view
    returns( uint finalPrizeAmount )
    {

        uint winnerProfitPercentage = 
            (_100PERCENT) - cfg.poolProfitShare - 
            cfg.ownerProfitShare - cfg.minerProfitShare;

        uint totalPrizeAmount =
            ( ending_profitAmount * winnerProfitPercentage ) /
            ( _100PERCENT );


        if( cfg.endingAlgoType == uint8(EndingAlgoType.RolledRandomness) )
        {

            uint singleWinnerShare = totalPrizeAmount / 
                                     cfg.prizeSequence_winnerCount;

            return totalPrizeAmount - rankingPosition * singleWinnerShare;
        }


        if( cfg.prizeSequenceFactor != 0 )
        {
            require( rankingPosition < cfg.prizeSequence_winnerCount/*,
                     "Invalid ranking position!" */);

            uint leftoverPercentage = 
                (_100PERCENT) - cfg.prizeSequenceFactor;

            uint loopCount = ( 
                rankingPosition >= cfg.prizeSequence_sequencedWinnerCount ?
                cfg.prizeSequence_sequencedWinnerCount :
                rankingPosition
            );

            for( uint i = 0; i < loopCount; i++ )
            {
                totalPrizeAmount = 
                    ( totalPrizeAmount * leftoverPercentage ) /
                    ( _100PERCENT );
            }

            if( loopCount == cfg.prizeSequence_sequencedWinnerCount &&
                cfg.prizeSequence_winnerCount > 
                cfg.prizeSequence_sequencedWinnerCount )
            {
                finalPrizeAmount = 
                    ( totalPrizeAmount ) /
                    ( cfg.prizeSequence_winnerCount -
                      cfg.prizeSequence_sequencedWinnerCount );
            }
            else
            {
                finalPrizeAmount = 
                    ( totalPrizeAmount * cfg.prizeSequenceFactor ) /
                    ( _100PERCENT );
            }
        }

        else
        {
            require( rankingPosition < cfg.winnerProfitShares.length );

            finalPrizeAmount = 
                ( totalPrizeAmount *
                  cfg.winnerProfitShares[ rankingPosition ] ) /
                ( _100PERCENT );
        }
    }


    function getWinnerStatus( address addr )
                                                        external view
    returns( bool isWinner, uint32 rankingPosition, 
             uint prizeAmount )
    {

        if( !onStage( STAGE.COMPLETION ) || balanceOf( addr ) == 0 )
            return (false , 0, 0);

        ( isWinner, rankingPosition ) =
            lotStorage.getWinnerStatus( addr );

        if( isWinner )
        {
            prizeAmount = getWinnerPrizeAmount( rankingPosition );
            if( prizeAmount > address(this).balance )
                prizeAmount = address(this).balance;
        }
    }


    function getPlayerIntermediateScore( address addr )
                                                        external view
    returns( uint )
    {

        return lotStorage.getPlayerActiveStageScore( addr );
    }


    function claimWinnerPrize(
            uint32 rankingPosition )
                                    external
                                    onlyOnStage( STAGE.COMPLETION )
                                    mutexLOCKED
    {

        require( ! prizeClaimersAddresses[ msg.sender ]/*,
                 "msg.sender has already claimed his prize!" */);

        require( balanceOf( msg.sender ) != 0/*,
                 "msg.sender's token balance can't be zero!" */);

        require( address(this).balance != 0/*,
                 "All prize funds have already been claimed!" */);

        if( cfg.endingAlgoType == uint8(EndingAlgoType.MinedWinnerSelection) )
        {
            require( lotStorage.minedSelection_isAddressOnWinnerPosition(
                            msg.sender, rankingPosition )/*,
                     "msg.sender is not on specified winner position!" */);
        }
        else
        {
            bool isWinner;
            ( isWinner, rankingPosition ) =
                lotStorage.getWinnerStatus( msg.sender );

            require( isWinner/*, "msg.sender is not a winner!" */);
        }

        uint finalPrizeAmount = getWinnerPrizeAmount( rankingPosition ); 

        if( finalPrizeAmount > address(this).balance )
            finalPrizeAmount = address(this).balance;


        msg.sender.transfer( finalPrizeAmount );


        prizeClaimersAddresses[ msg.sender ] = true;
    }


    function getUnclaimedPrizes()
                                        external
                                        poolOnly
                                        onlyOnStage( STAGE.COMPLETION )
                                        mutexLOCKED
    {

        require( completionDate != 0 &&
                 ( block.timestamp - completionDate ) > cfg.prizeClaimTime/*,
                 "Prize claim deadline not reached yet!" */);

        poolAddress.transfer( address(this).balance );
    }

}

contract LotteryStorage is CoreUniLotterySettings
{


    struct HolderData 
    {

        address referrer;

        int16 bonusScore;

        uint16 referreeCount;



        uint256 referralID;



        int40 etherContributed;

        int40 timeFactors;

        int40 tokenBalance;

        int40 referree_etherContributed;
        int40 referree_timeFactors;
        int40 referree_tokenBalance;
    }


    struct FinalScore 
    {
        address addr;           // 20 bytes \
        uint16 holderIndex;     // 2 bytes  | = 30 bytes => 1 slot.
        uint64 score;           // 8 bytes  /
    }


    struct WinnerIndexStruct
    {
        uint16[ 16 ] indexes;
    }


    struct WinnerAlgorithmConfig
    {

        int16 maxPlayerScore_etherContributed;
        int16 maxPlayerScore_tokenHoldingAmount;
        int16 maxPlayerScore_timeFactor;
        int16 maxPlayerScore_refferalBonus;

        uint16 winnerCount;

        uint16 randRatio_scorePart;
        uint16 randRatio_randPart;

        uint8 endingAlgoType;
    }


    struct MinMaxHolderScores
    {

        int40 holderScore_etherContributed_min;
        int40 holderScore_etherContributed_max;

        int40 holderScore_timeFactors_min;
        int40 holderScore_timeFactors_max;

        int40 holderScore_tokenBalance_min;
        int40 holderScore_tokenBalance_max;
    }

    struct MinMaxReferralScores
    {

        int40 referralScore_etherContributed_min;
        int40 referralScore_etherContributed_max;

        int40 referralScore_timeFactors_min;
        int40 referralScore_timeFactors_max;

        int40 referralScore_tokenBalance_min;
        int40 referralScore_tokenBalance_max;
    }

    address constant ROOT_REFERRER = address( 1 );

    uint constant MAX_REFERRAL_DEPTH = 10;

    int constant PRECISION = 10000;

    uint constant RANDOM_MODULO = (10 ** 9);

    uint constant MINEDSELECTION_MAX_NUMBER_OF_HOLDERS = 300;

    uint constant SELFVALIDATION_MAX_NUMBER_OF_HOLDERS = 1200;




    address lottery;

    uint64 randomSeed;

    uint16 numberOfWinners;

    bool algorithmCompleted;



    WinnerAlgorithmConfig algConfig;


    MinMaxHolderScores public minMaxScores;
    MinMaxReferralScores public minMaxReferralScores;


    address[] public holders;


    mapping( address => uint ) holderIndexes;


    mapping( address => HolderData ) public holderData;


    mapping( uint256 => address ) referrers;


    WinnerIndexStruct[] sortedWinnerIndexes;




    modifier lotteryOnly
    {

        require( msg.sender == address( lottery )/*,
                 "Function can only be called by Lottery that this"
                 "Storage Contract belongs to!" */);
        _;
    }




    function QSort_swap( FinalScore[] memory list, 
                         uint a, uint b )               
                                                        internal pure
    {

        FinalScore memory tmp = list[ a ];
        list[ a ] = list[ b ];
        list[ b ] = tmp;
    }

    function QSort_partition( 
            FinalScore[] memory list, 
            int lo, int hi )
                                                        internal pure
    returns( int newPivotIndex )
    {

        uint64 pivot = list[ uint( hi + lo ) / 2 ].score;
        int i = lo - 1;
        int j = hi + 1;

        while( true ) 
        {
            do {
                i++;
            } while( list[ uint( i ) ].score > pivot ) ;

            do {
                j--;
            } while( list[ uint( j ) ].score < pivot ) ;

            if( i >= j )
                return j;

            QSort_swap( list, uint( i ), uint( j ) );
        }
    }

    function QSort_LomutoPartition(
            FinalScore[] memory list,
            uint left, uint right, uint pivotIndex )
                                                        internal pure
    returns( uint newPivotIndex )
    {

        uint pivotValue = list[ pivotIndex ].score;
        QSort_swap( list, pivotIndex, right );  // Move pivot to end
        uint storeIndex = left;
        
        for( uint i = left; i < right; i++ )
        {
            if( list[ i ].score > pivotValue ) {
                QSort_swap( list, storeIndex, i );
                storeIndex++;
            }
        }

        QSort_swap( list, right, storeIndex );
        return storeIndex;
    }

    function QSort_QuickSelect(
            FinalScore[] memory list,
            int left, int right, int k )
                                                        internal pure
    returns( int indexOfK )
    {

        while( true ) {
            if( left == right )
                return left;

            int pivotIndex = int( QSort_LomutoPartition( list, 
                    uint(left), uint(right), uint(right) ) );

            if( k == pivotIndex )
                return k;
            else if( k < pivotIndex )
                right = pivotIndex - 1;
            else
                left = pivotIndex + 1;
        }
    }

    function QSort_QuickSort(
            FinalScore[] memory list,
            int lo, int hi )
                                                        internal pure
    {

        if( lo < hi ) {
            int p = QSort_partition( list, lo, hi );
            QSort_QuickSort( list, lo, p );
            QSort_QuickSort( list, p + 1, hi );
        }
    }



    function computeHolderIndividualScores( 
            WinnerAlgorithmConfig memory cfg,
            MinMaxHolderScores memory minMax,
            HolderData memory hdata )
                                                        internal pure
    returns( int individualScore )
    {


        int score_etherContributed = ( (
            ( int( hdata.etherContributed -                      // e
                   minMax.holderScore_etherContributed_min )     // eMin
              * PRECISION * cfg.maxPlayerScore_etherContributed )// P * MS
            / int( minMax.holderScore_etherContributed_max -     // eMax
                   minMax.holderScore_etherContributed_min )     // eMin
        ) + (PRECISION / 2) ) / PRECISION;

        int score_timeFactors = ( (
            ( int( hdata.timeFactors -                          // e
                   minMax.holderScore_timeFactors_min )         // eMin
              * PRECISION * cfg.maxPlayerScore_timeFactor )     // P * MS
            / int( minMax.holderScore_timeFactors_max -         // eMax
                   minMax.holderScore_timeFactors_min )         // eMin
        ) + (PRECISION / 2) ) / PRECISION;

        int score_tokenBalance = ( (
            ( int( hdata.tokenBalance -                         // e
                   minMax.holderScore_tokenBalance_min )        // eMin
              * PRECISION * cfg.maxPlayerScore_tokenHoldingAmount )
            / int( minMax.holderScore_tokenBalance_max -        // eMax
                   minMax.holderScore_tokenBalance_min )        // eMin
        ) + (PRECISION / 2) ) / PRECISION;

        return score_etherContributed + score_timeFactors +
               score_tokenBalance;
    }


    function computeReferreeScoresForHolder( 
            int individualToReferralRatio,
            WinnerAlgorithmConfig memory cfg,
            MinMaxReferralScores memory minMax,
            HolderData memory hdata )
                                                        internal pure
    returns( int unifiedReferreeScore )
    {

        if( hdata.referreeCount == 0 )
            return 0;


        int referreeScore_etherContributed = ( (
            ( int( hdata.referree_etherContributed -
                   minMax.referralScore_etherContributed_min )
              * PRECISION * cfg.maxPlayerScore_etherContributed )
            / int( minMax.referralScore_etherContributed_max -
                   minMax.referralScore_etherContributed_min )
        ) );

        int referreeScore_timeFactors = ( (
            ( int( hdata.referree_timeFactors -
                   minMax.referralScore_timeFactors_min )
              * PRECISION * cfg.maxPlayerScore_timeFactor )
            / int( minMax.referralScore_timeFactors_max -
                   minMax.referralScore_timeFactors_min )
        ) );

        int referreeScore_tokenBalance = ( (
            ( int( hdata.referree_tokenBalance -
                   minMax.referralScore_tokenBalance_min )
              * PRECISION * cfg.maxPlayerScore_tokenHoldingAmount )
            / int( minMax.referralScore_tokenBalance_max -
                   minMax.referralScore_tokenBalance_min )
        ) );


        unifiedReferreeScore = int( ( (
                ( ( referreeScore_etherContributed +
                    referreeScore_timeFactors +
                    referreeScore_tokenBalance ) + (PRECISION / 2)
                ) / PRECISION
            ) * individualToReferralRatio
        ) / PRECISION );
    }


    function priv_updateMinMaxScores_individual(
            MinMaxHolderScores memory minMax,
            int40 _etherContributed,
            int40 _timeFactors,
            int40 _tokenBalance )
                                                    internal
                                                    pure
    {

        if( _etherContributed > 
            minMax.holderScore_etherContributed_max )
            minMax.holderScore_etherContributed_max = 
                _etherContributed;

        if( _etherContributed <
            minMax.holderScore_etherContributed_min )
            minMax.holderScore_etherContributed_min = 
                _etherContributed;

        if( _timeFactors > 
            minMax.holderScore_timeFactors_max )
            minMax.holderScore_timeFactors_max = 
                _timeFactors;

        if( _timeFactors <
            minMax.holderScore_timeFactors_min )
            minMax.holderScore_timeFactors_min = 
                _timeFactors;

        if( _tokenBalance > 
            minMax.holderScore_tokenBalance_max )
            minMax.holderScore_tokenBalance_max = 
                _tokenBalance;

        if( _tokenBalance <
            minMax.holderScore_tokenBalance_min )
            minMax.holderScore_tokenBalance_min = 
                _tokenBalance;
    }


    function priv_updateMinMaxScores_referral(
            MinMaxReferralScores memory minMax,
            int40 _etherContributed,
            int40 _timeFactors,
            int40 _tokenBalance )
                                                    internal
                                                    pure
    {

        if( _etherContributed > 
            minMax.referralScore_etherContributed_max )
            minMax.referralScore_etherContributed_max = 
                _etherContributed;

        if( _etherContributed <
            minMax.referralScore_etherContributed_min )
            minMax.referralScore_etherContributed_min = 
                _etherContributed;

        if( _timeFactors > 
            minMax.referralScore_timeFactors_max )
            minMax.referralScore_timeFactors_max = 
                _timeFactors;

        if( _timeFactors <
            minMax.referralScore_timeFactors_min )
            minMax.referralScore_timeFactors_min = 
                _timeFactors;

        if( _tokenBalance > 
            minMax.referralScore_tokenBalance_max )
            minMax.referralScore_tokenBalance_max = 
                _tokenBalance;

        if( _tokenBalance <
            minMax.referralScore_tokenBalance_min )
            minMax.referralScore_tokenBalance_min = 
                _tokenBalance;
    }




    function updateAndPropagateScoreChanges(
            address holder,
            int __etherContributed_change,
            int __timeFactors_change,
            int __tokenBalance_change )
                                                        public
                                                        lotteryOnly
    {

        int40 timeFactors_change = int40( __timeFactors_change );

        int40 etherContributed_change = int40(
            __etherContributed_change / int(1 ether / 10000) );
 
        int40 tokenBalance_change = int40(
            __tokenBalance_change / int(1 ether) );

        holderData[ holder ].etherContributed += etherContributed_change;
        holderData[ holder ].timeFactors += timeFactors_change;
        holderData[ holder ].tokenBalance += tokenBalance_change;

        MinMaxHolderScores memory minMaxCpy = minMaxScores;
        MinMaxReferralScores memory minMaxRefCpy = minMaxReferralScores;

        priv_updateMinMaxScores_individual(
            minMaxCpy,
            holderData[ holder ].etherContributed,
            holderData[ holder ].timeFactors,
            holderData[ holder ].tokenBalance
        );

        uint depth = 0;
        address referrerAddr = holderData[ holder ].referrer;

        while( referrerAddr != ROOT_REFERRER && 
               referrerAddr != address( 0 )  &&
               depth < MAX_REFERRAL_DEPTH )
        {
            holderData[ referrerAddr ].referree_etherContributed +=
                etherContributed_change;

            holderData[ referrerAddr ].referree_timeFactors +=
                timeFactors_change;

            holderData[ referrerAddr ].referree_tokenBalance +=
                tokenBalance_change;

            priv_updateMinMaxScores_referral(
                minMaxRefCpy,
                holderData[ referrerAddr ].referree_etherContributed,
                holderData[ referrerAddr ].referree_timeFactors,
                holderData[ referrerAddr ].referree_tokenBalance
            );

            referrerAddr = holderData[ referrerAddr ].referrer;
            depth++;
        }

        if( keccak256( abi.encode( minMaxCpy ) ) != 
            keccak256( abi.encode( minMaxScores ) ) )
            minMaxScores = minMaxCpy;

        if( keccak256( abi.encode( minMaxRefCpy ) ) != 
            keccak256( abi.encode( minMaxReferralScores ) ) )
            minMaxReferralScores = minMaxRefCpy;
    }


    function priv_fixMinMaxIfEqual(
            MinMaxHolderScores memory minMaxCpy,
            MinMaxReferralScores memory minMaxRefCpy )
                                                            internal
                                                            pure
    {

        if( minMaxCpy.holderScore_etherContributed_min ==
            minMaxCpy.holderScore_etherContributed_max )
            minMaxCpy.holderScore_etherContributed_max =
            minMaxCpy.holderScore_etherContributed_min + 1;

        if( minMaxCpy.holderScore_timeFactors_min ==
            minMaxCpy.holderScore_timeFactors_max )
            minMaxCpy.holderScore_timeFactors_max =
            minMaxCpy.holderScore_timeFactors_min + 1;

        if( minMaxCpy.holderScore_tokenBalance_min ==
            minMaxCpy.holderScore_tokenBalance_max )
            minMaxCpy.holderScore_tokenBalance_max =
            minMaxCpy.holderScore_tokenBalance_min + 1;

        if( minMaxRefCpy.referralScore_etherContributed_min ==
            minMaxRefCpy.referralScore_etherContributed_max )
            minMaxRefCpy.referralScore_etherContributed_max =
            minMaxRefCpy.referralScore_etherContributed_min + 1;

        if( minMaxRefCpy.referralScore_timeFactors_min ==
            minMaxRefCpy.referralScore_timeFactors_max )
            minMaxRefCpy.referralScore_timeFactors_max =
            minMaxRefCpy.referralScore_timeFactors_min + 1;

        if( minMaxRefCpy.referralScore_tokenBalance_min ==
            minMaxRefCpy.referralScore_tokenBalance_max )
            minMaxRefCpy.referralScore_tokenBalance_max =
            minMaxRefCpy.referralScore_tokenBalance_min + 1;
    }


    function executeWinnerSelectionAlgorithm()
                                                        public
                                                        lotteryOnly
    {

        WinnerAlgorithmConfig memory cfg = algConfig;

        require( cfg.endingAlgoType ==
                 uint8(Lottery.EndingAlgoType.MinedWinnerSelection)/*,
                 "Algorithm cannot be performed on current Algo-Type!" */);


        uint ARRLEN = 
            ( holders.length > MINEDSELECTION_MAX_NUMBER_OF_HOLDERS ?
              MINEDSELECTION_MAX_NUMBER_OF_HOLDERS : holders.length );

        FinalScore[] memory finalScores = new FinalScore[] ( ARRLEN );


        int individualToReferralRatio = 
            ( PRECISION * cfg.maxPlayerScore_refferalBonus ) /
            ( int( cfg.maxPlayerScore_etherContributed ) + 
              int( cfg.maxPlayerScore_timeFactor ) +
              int( cfg.maxPlayerScore_tokenHoldingAmount ) );

        int maxAvailablePlayerScore = int(
                cfg.maxPlayerScore_etherContributed + 
                cfg.maxPlayerScore_timeFactor +
                cfg.maxPlayerScore_tokenHoldingAmount +
                cfg.maxPlayerScore_refferalBonus );



        int SCORE_RAND_FACT =
            ( PRECISION * int(RANDOM_MODULO * cfg.randRatio_scorePart) ) /
            ( int(cfg.randRatio_randPart) * maxAvailablePlayerScore );


        MinMaxHolderScores memory minMaxCpy = minMaxScores;
        MinMaxReferralScores memory minMaxRefCpy = minMaxReferralScores;

        priv_fixMinMaxIfEqual( minMaxCpy, minMaxRefCpy );

        for( uint i = 0; i < ARRLEN; i++ )
        {
            HolderData memory hdata;

            hdata.etherContributed =
                holderData[ holders[ i ] ].etherContributed;
            hdata.timeFactors =
                holderData[ holders[ i ] ].timeFactors;
            hdata.tokenBalance =
                holderData[ holders[ i ] ].tokenBalance;
            hdata.referreeCount =
                holderData[ holders[ i ] ].referreeCount;

            hdata.referree_etherContributed =
                holderData[ holders[ i ] ].referree_etherContributed;
            hdata.referree_timeFactors =
                holderData[ holders[ i ] ].referree_timeFactors;
            hdata.referree_tokenBalance =
                holderData[ holders[ i ] ].referree_tokenBalance;
            hdata.bonusScore =
                holderData[ holders[ i ] ].bonusScore;


            int totalPlayerScore = 
                    hdata.bonusScore
                    +
                    computeHolderIndividualScores(
                        cfg, minMaxCpy, hdata )
                    +
                    computeReferreeScoresForHolder( 
                        individualToReferralRatio, cfg, 
                        minMaxRefCpy, hdata );


            if( totalPlayerScore <= 0 )
                totalPlayerScore = 1;

            if( totalPlayerScore > maxAvailablePlayerScore )
                totalPlayerScore = maxAvailablePlayerScore;


            totalPlayerScore =  ( totalPlayerScore * SCORE_RAND_FACT ) /
                                ( PRECISION );


            uint modulizedRandomNumber = uint(
                keccak256( abi.encodePacked( randomSeed, holders[ i ] ) )
            ) % RANDOM_MODULO;


            uint endScore = uint( totalPlayerScore ) + modulizedRandomNumber;

            finalScores[ i ].addr = holders[ i ];
            finalScores[ i ].holderIndex = uint16( i );
            finalScores[ i ].score = uint64( endScore );
        }



        require( finalScores.length > 0 );

        uint K = cfg.winnerCount - 1;
        if( K > finalScores.length-1 )
            K = finalScores.length-1;   // Must be THE LAST ELEMENT's INDEX.

        QSort_QuickSelect( finalScores, 0, 
            int( finalScores.length - 1 ), int( K ) );

        QSort_QuickSort( finalScores, 0, int( K ) );


        numberOfWinners = uint16( K + 1 );

        for( uint offset = 0; offset < numberOfWinners; offset += 16 )
        {
            WinnerIndexStruct memory windStruct;
            uint loopStop = ( offset + 16 > numberOfWinners ?
                              numberOfWinners : offset + 16 );

            for( uint i = offset; i < loopStop; i++ )
            {
                windStruct.indexes[ i - offset ] =finalScores[ i ].holderIndex;
            }

            sortedWinnerIndexes.push( windStruct );
        }

        algorithmCompleted = true;
    }


    function addHolder( address holder )
                                                        public
                                                        lotteryOnly
    {

        holders.push( holder );
        holderIndexes[ holder ] = holders.length - 1;
    }

    function removeHolder( address sender )
                                                        public
                                                        lotteryOnly
    {

        uint index = holderIndexes[ sender ];

        holders[ index ] = holders[ holders.length - 1 ];

        holders.pop();

        delete holderIndexes[ sender ];
        holderIndexes[ holders[ index ] ] = index;
    }


    function getHolderCount()
                                                    public view
    returns( uint )
    {

        return holders.length;
    }


    function generateReferralID( address holder )
                                                            public
                                                            lotteryOnly
    returns( uint256 referralID )
    {

        require( holderData[ holder ].tokenBalance != 0/*,
                 "holder doesn't have any lottery tokens!" */);

        require( holderData[ holder ].referralID == 0/*,
                 "Holder already has a referral ID!" */);

        uint256 refID = uint256( keccak256( abi.encodePacked( 
                holder, holderData[ holder ].tokenBalance, block.timestamp ) ) );

        holderData[ holder ].referralID = refID;

        if( holderData[ holder ].referrer == address( 0 ) )
            holderData[ holder ].referrer = ROOT_REFERRER;

        referrers[ refID ] = holder;
        
        return refID;
    }


    function registerReferral(
            address holder,
            int16 referralRegisteringBonus,
            uint256 referralID )
                                                            public
                                                            lotteryOnly
    returns( address _referrerAddress )
    {

        require( holderData[ holder ].tokenBalance != 0/*,
                 "holder doesn't have any lottery tokens!" */);

        require( holderData[ holder ].referrer == address( 0 )/*,
                 "holder already has registered a referral!" */);

        MinMaxReferralScores memory minMaxRefCpy = minMaxReferralScores;

        holderData[ holder ].referrer = referrers[ referralID ];

        holderData[ holder ].bonusScore = referralRegisteringBonus;

        address referrerAddr = holderData[ holder ].referrer;

        _referrerAddress = referrerAddr;

        while( referrerAddr != ROOT_REFERRER && 
               referrerAddr != address( 0 ) )
        {
            holderData[ referrerAddr ].referreeCount++;

            holderData[ referrerAddr ].referree_etherContributed +=
                holderData[ holder ].etherContributed;

            holderData[ referrerAddr ].referree_timeFactors +=
                holderData[ holder ].timeFactors;

            holderData[ referrerAddr ].referree_tokenBalance +=
                holderData[ holder ].tokenBalance;

            priv_updateMinMaxScores_referral(
                minMaxRefCpy,
                holderData[ referrerAddr ].referree_etherContributed,
                holderData[ referrerAddr ].referree_timeFactors,
                holderData[ referrerAddr ].referree_tokenBalance
            );

            referrerAddr = holderData[ referrerAddr ].referrer;
        }

        if( keccak256( abi.encode( minMaxRefCpy ) ) != 
            keccak256( abi.encode( minMaxReferralScores ) ) )
            minMaxReferralScores = minMaxRefCpy;

        return _referrerAddress;
    }


    function setRandomSeed( uint _seed )
                                                    external
                                                    lotteryOnly
    {

        randomSeed = uint64( _seed );
    }


    function initialize(
            WinnerAlgorithmConfig memory _wcfg )
                                                        public
    {

        require( address( lottery ) == address( 0 )/*,
                 "Storage is already initialized!" */);

        lottery = msg.sender;

        algConfig = _wcfg;

    }




    function getRandomSeed()
                                                    external view
    returns( uint )
    {

        return randomSeed;
    }


    function minedSelection_algorithmAlreadyExecuted()
                                                        external view
    returns( bool )
    {

        return algorithmCompleted;
    }

    function minedSelection_getWinnerStatus(
            address addr )
                                                        public view
    returns( bool isWinner, 
             uint32 rankingPosition )
    {

        for( uint16 i = 0; i < numberOfWinners; i++ )
        {
            uint pos = sortedWinnerIndexes[ i / 16 ].indexes[ i % 16 ];

            if( holders[ pos ] == addr )
            {
                return ( true, i );
            }
        }

        return ( false, 0 );
    }

    function minedSelection_isAddressOnWinnerPosition( 
            address addr,
            uint32  rankingPosition )
                                                    external view
    returns( bool )
    {

        if( rankingPosition >= numberOfWinners )
            return false;

        uint pos = sortedWinnerIndexes[ rankingPosition / 16 ]
                    .indexes[ rankingPosition % 16 ];

        return ( holders[ pos ] == addr );
    }


    function minedSelection_getAllWinners()
                                                    external view
    returns( address[] memory )
    {

        address[] memory winners = new address[] ( numberOfWinners );

        for( uint i = 0; i < numberOfWinners; i++ )
        {
            uint pos = sortedWinnerIndexes[ i / 16 ].indexes[ i % 16 ];
            winners[ i ] = holders[ pos ];
        }

        return winners;
    }


    function getPlayerActiveStageScore( address holderAddr )
                                                            external view
    returns( uint playerScore )
    {

        WinnerAlgorithmConfig memory cfg = algConfig;

        if( holders[ holderIndexes[ holderAddr ] ] != holderAddr )
            return 0;


        int individualToReferralRatio = 
            ( PRECISION * cfg.maxPlayerScore_refferalBonus ) /
            ( int( cfg.maxPlayerScore_etherContributed ) + 
              int( cfg.maxPlayerScore_timeFactor ) +
              int( cfg.maxPlayerScore_tokenHoldingAmount ) );

        int maxAvailablePlayerScore = int(
                cfg.maxPlayerScore_etherContributed + 
                cfg.maxPlayerScore_timeFactor +
                cfg.maxPlayerScore_tokenHoldingAmount +
                cfg.maxPlayerScore_refferalBonus );

        MinMaxHolderScores memory minMaxCpy = minMaxScores;
        MinMaxReferralScores memory minMaxRefCpy = minMaxReferralScores;

        priv_fixMinMaxIfEqual( minMaxCpy, minMaxRefCpy );

        int totalPlayerScore = 
                holderData[ holderAddr ].bonusScore
                +
                computeHolderIndividualScores(
                    cfg, minMaxCpy, holderData[ holderAddr ] )
                +
                computeReferreeScoresForHolder( 
                    individualToReferralRatio, cfg, 
                    minMaxRefCpy, holderData[ holderAddr ] );


        if( totalPlayerScore <= 0 )
            totalPlayerScore = 1;

        if( totalPlayerScore > maxAvailablePlayerScore )
            totalPlayerScore = maxAvailablePlayerScore;

        return uint( totalPlayerScore );
    }



    function priv_getSingleHolderScore(
            address hold3r,
            int individualToReferralRatio,
            int maxAvailablePlayerScore,
            int SCORE_RAND_FACT,
            WinnerAlgorithmConfig memory cfg,
            MinMaxHolderScores memory minMaxCpy,
            MinMaxReferralScores memory minMaxRefCpy )
                                                        internal view
    returns( uint endScore )
    {

        HolderData memory hdata;

        hdata.etherContributed =
            holderData[ hold3r ].etherContributed;
        hdata.timeFactors =
            holderData[ hold3r ].timeFactors;
        hdata.tokenBalance =
            holderData[ hold3r ].tokenBalance;
        hdata.referreeCount =
            holderData[ hold3r ].referreeCount;

        hdata.referree_etherContributed =
            holderData[ hold3r ].referree_etherContributed;
        hdata.referree_timeFactors =
            holderData[ hold3r ].referree_timeFactors;
        hdata.referree_tokenBalance =
            holderData[ hold3r ].referree_tokenBalance;
        hdata.bonusScore =
            holderData[ hold3r ].bonusScore;


        int totalPlayerScore = 
                hdata.bonusScore
                +
                computeHolderIndividualScores(
                    cfg, minMaxCpy, hdata )
                +
                computeReferreeScoresForHolder( 
                    individualToReferralRatio, cfg, 
                    minMaxRefCpy, hdata );


        if( totalPlayerScore <= 0 )
            totalPlayerScore = 1;

        if( totalPlayerScore > maxAvailablePlayerScore )
            totalPlayerScore = maxAvailablePlayerScore;


        totalPlayerScore =  ( totalPlayerScore * SCORE_RAND_FACT ) /
                            ( PRECISION );


        uint modulizedRandomNumber = uint(
            keccak256( abi.encodePacked( randomSeed, hold3r ) )
        ) % RANDOM_MODULO;


        return uint( totalPlayerScore ) + modulizedRandomNumber;
    }


    function winnerSelfValidation_getWinnerStatus(
            address holderAddr )
                                                        internal view
    returns( bool isWinner, uint rankingPosition )
    {

        WinnerAlgorithmConfig memory cfg = algConfig;

        require( cfg.endingAlgoType ==
                 uint8(Lottery.EndingAlgoType.WinnerSelfValidation)/*,
                 "Algorithm cannot be performed on current Algo-Type!" */);

        require( holders[ holderIndexes[ holderAddr ] ] == holderAddr/*,
                 "holderAddr is not a lottery token holder!" */);



        int individualToReferralRatio = 
            ( PRECISION * cfg.maxPlayerScore_refferalBonus ) /
            ( int( cfg.maxPlayerScore_etherContributed ) + 
              int( cfg.maxPlayerScore_timeFactor ) +
              int( cfg.maxPlayerScore_tokenHoldingAmount ) );

        int maxAvailablePlayerScore = int(
                cfg.maxPlayerScore_etherContributed + 
                cfg.maxPlayerScore_timeFactor +
                cfg.maxPlayerScore_tokenHoldingAmount +
                cfg.maxPlayerScore_refferalBonus );



        int SCORE_RAND_FACT =
            ( PRECISION * int(RANDOM_MODULO * cfg.randRatio_scorePart) ) /
            ( int(cfg.randRatio_randPart) * maxAvailablePlayerScore );


        MinMaxHolderScores memory minMaxCpy = minMaxScores;
        MinMaxReferralScores memory minMaxRefCpy = minMaxReferralScores;

        priv_fixMinMaxIfEqual( minMaxCpy, minMaxRefCpy );

        uint numOfHoldersHigherThan = 0;

        uint holderAddrsFinalScore = priv_getSingleHolderScore(
            holderAddr,
            individualToReferralRatio,
            maxAvailablePlayerScore,
            SCORE_RAND_FACT,
            cfg, minMaxCpy, minMaxRefCpy );

        uint holderAddrIndex = holderIndexes[ holderAddr ];


        for( uint i = 0; 
             i < ( holders.length < SELFVALIDATION_MAX_NUMBER_OF_HOLDERS ? 
                   holders.length : SELFVALIDATION_MAX_NUMBER_OF_HOLDERS );
             i++ )
        {
            if( i == holderAddrIndex )
                continue;

            uint endScore = priv_getSingleHolderScore(
                holders[ i ],
                individualToReferralRatio,
                maxAvailablePlayerScore,
                SCORE_RAND_FACT,
                cfg, minMaxCpy, minMaxRefCpy );

            if( endScore > holderAddrsFinalScore )
                numOfHoldersHigherThan++;
        }


        isWinner = ( numOfHoldersHigherThan < cfg.winnerCount ); 
        rankingPosition = numOfHoldersHigherThan;
    }



    function rolledRandomness_getWinnerStatus(
            address holderAddr )
                                                        internal view
    returns( bool isWinner, uint rankingPosition )
    {

        WinnerAlgorithmConfig memory cfg = algConfig;

        require( cfg.endingAlgoType ==
                 uint8(Lottery.EndingAlgoType.RolledRandomness)/*,
                 "Algorithm cannot be performed on current Algo-Type!" */);

        require( holders[ holderIndexes[ holderAddr ] ] == holderAddr/*,
                 "holderAddr is not a lottery token holder!" */);



        int individualToReferralRatio = 
            ( PRECISION * cfg.maxPlayerScore_refferalBonus ) /
            ( int( cfg.maxPlayerScore_etherContributed ) + 
              int( cfg.maxPlayerScore_timeFactor ) +
              int( cfg.maxPlayerScore_tokenHoldingAmount ) );

        int maxAvailablePlayerScore = int(
                cfg.maxPlayerScore_etherContributed + 
                cfg.maxPlayerScore_timeFactor +
                cfg.maxPlayerScore_tokenHoldingAmount +
                cfg.maxPlayerScore_refferalBonus );



        int SCORE_RAND_FACT =
            ( PRECISION * int(RANDOM_MODULO * cfg.randRatio_scorePart) ) /
            ( int(cfg.randRatio_randPart) * maxAvailablePlayerScore );


        MinMaxHolderScores memory minMaxCpy = minMaxScores;
        MinMaxReferralScores memory minMaxRefCpy = minMaxReferralScores;

        priv_fixMinMaxIfEqual( minMaxCpy, minMaxRefCpy );

        uint holderAddrsFinalScore = priv_getSingleHolderScore(
            holderAddr,
            individualToReferralRatio,
            maxAvailablePlayerScore,
            SCORE_RAND_FACT,
            cfg, minMaxCpy, minMaxRefCpy );


        int maxRandomPart      = int( RANDOM_MODULO - 1 );
        int maxPlayerScorePart = ( SCORE_RAND_FACT * maxAvailablePlayerScore )
                                 / PRECISION;

        uint maxFinalScore = uint( maxRandomPart + maxPlayerScorePart );

        uint singleHolderPart = maxFinalScore / holders.length;

        uint holderAddrScorePartCount = holderAddrsFinalScore /
                                        singleHolderPart;

        rankingPosition = (
            holderAddrScorePartCount < holders.length ?
            holders.length - holderAddrScorePartCount : 0
        );

        isWinner = ( rankingPosition < cfg.winnerCount );
    }


    function getWinnerStatus(
            address addr )
                                                        external view
    returns( bool isWinner, uint32 rankingPosition )
    {

        bool _isW;
        uint _rp;

        if( algConfig.endingAlgoType == 
            uint8(Lottery.EndingAlgoType.RolledRandomness) )
        {
            (_isW, _rp) = rolledRandomness_getWinnerStatus( addr );
            return ( _isW, uint32( _rp ) );
        }

        if( algConfig.endingAlgoType ==
            uint8(Lottery.EndingAlgoType.WinnerSelfValidation) )
        {
            (_isW, _rp) = winnerSelfValidation_getWinnerStatus( addr );
            return ( _isW, uint32( _rp ) );
        }

        if( algConfig.endingAlgoType ==
            uint8(Lottery.EndingAlgoType.MinedWinnerSelection) )
        {
            (_isW, _rp) = minedSelection_getWinnerStatus( addr );
            return ( _isW, uint32( _rp ) );
        }
    }

}

// Incompatible compiler version - please select a compiler within the stated pragma range, or use a different version of the provableAPI!
abstract contract solcChecker {
}

interface ProvableI {


    function cbAddress() external returns (address _cbAddress);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function getPrice(string calldata _datasource) external returns (uint _dsprice);

    function randomDS_getSessionPubKeyHash() external view returns (bytes32 _sessionKeyHash);

    function getPrice(string calldata _datasource, uint _gasLimit)  external returns (uint _dsprice);

    function queryN(uint _timestamp, string calldata _datasource, bytes calldata _argN) external payable returns (bytes32 _id);

    function query(uint _timestamp, string calldata _datasource, string calldata _arg) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string calldata _datasource, string calldata _arg1, string calldata _arg2) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string calldata _datasource, string calldata _arg, uint _gasLimit) external payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string calldata _datasource, bytes calldata _argN, uint _gasLimit) external payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string calldata _datasource, string calldata _arg1, string calldata _arg2, uint _gasLimit) external payable returns (bytes32 _id);

}

interface OracleAddrResolverI {

    function getAddress() external returns (address _address);

}

library Buffer {


    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory _buf, uint _capacity) internal pure {

        uint capacity = _capacity;
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        _buf.capacity = capacity; // Allocate space for the buffer data
        assembly {
            let ptr := mload(0x40)
            mstore(_buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(ptr, capacity))
        }
    }

    function resize(buffer memory _buf, uint _capacity) private pure {

        bytes memory oldbuf = _buf.buf;
        init(_buf, _capacity);
        append(_buf, oldbuf);
    }

    function max(uint _a, uint _b) private pure returns (uint _max) {

        if (_a > _b) {
            return _a;
        }
        return _b;
    }
    function append(buffer memory _buf, bytes memory _data) internal pure returns (buffer memory _buffer) {

        if (_data.length + _buf.buf.length > _buf.capacity) {
            resize(_buf, max(_buf.capacity, _data.length) * 2);
        }
        uint dest;
        uint src;
        uint len = _data.length;
        assembly {
            let bufptr := mload(_buf) // Memory address of the buffer data
            let buflen := mload(bufptr) // Length of existing buffer data
            dest := add(add(bufptr, buflen), 32) // Start address = buffer address + buffer length + sizeof(buffer length)
            mstore(bufptr, add(buflen, mload(_data))) // Update buffer length
            src := add(_data, 32)
        }
        for(; len >= 32; len -= 32) { // Copy word-length chunks while possible
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint mask = 256 ** (32 - len) - 1; // Copy remaining bytes
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
        return _buf;
    }
    function append(buffer memory _buf, uint8 _data) internal pure {

        if (_buf.buf.length + 1 > _buf.capacity) {
            resize(_buf, _buf.capacity * 2);
        }
        assembly {
            let bufptr := mload(_buf) // Memory address of the buffer data
            let buflen := mload(bufptr) // Length of existing buffer data
            let dest := add(add(bufptr, buflen), 32) // Address = buffer address + buffer length + sizeof(buffer length)
            mstore8(dest, _data)
            mstore(bufptr, add(buflen, 1)) // Update buffer length
        }
    }
    function appendInt(buffer memory _buf, uint _data, uint _len) internal pure returns (buffer memory _buffer) {

        if (_len + _buf.buf.length > _buf.capacity) {
            resize(_buf, max(_buf.capacity, _len) * 2);
        }
        uint mask = 256 ** _len - 1;
        assembly {
            let bufptr := mload(_buf) // Memory address of the buffer data
            let buflen := mload(bufptr) // Length of existing buffer data
            let dest := add(add(bufptr, buflen), _len) // Address = buffer address + buffer length + sizeof(buffer length) + len
            mstore(dest, or(and(mload(dest), not(mask)), _data))
            mstore(bufptr, add(buflen, _len)) // Update buffer length
        }
        return _buf;
    }
}

library CBOR {


    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    function encodeType(Buffer.buffer memory _buf, uint8 _major, uint _value) private pure {

        if (_value <= 23) {
            _buf.append(uint8((_major << 5) | _value));
        } else if (_value <= 0xFF) {
            _buf.append(uint8((_major << 5) | 24));
            _buf.appendInt(_value, 1);
        } else if (_value <= 0xFFFF) {
            _buf.append(uint8((_major << 5) | 25));
            _buf.appendInt(_value, 2);
        } else if (_value <= 0xFFFFFFFF) {
            _buf.append(uint8((_major << 5) | 26));
            _buf.appendInt(_value, 4);
        } else if (_value <= 0xFFFFFFFFFFFFFFFF) {
            _buf.append(uint8((_major << 5) | 27));
            _buf.appendInt(_value, 8);
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory _buf, uint8 _major) private pure {

        _buf.append(uint8((_major << 5) | 31));
    }

    function encodeUInt(Buffer.buffer memory _buf, uint _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_INT, _value);
    }

    function encodeInt(Buffer.buffer memory _buf, int _value) internal pure {

        if (_value >= 0) {
            encodeType(_buf, MAJOR_TYPE_INT, uint(_value));
        } else {
            encodeType(_buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - _value));
        }
    }

    function encodeBytes(Buffer.buffer memory _buf, bytes memory _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_BYTES, _value.length);
        _buf.append(_value);
    }

    function encodeString(Buffer.buffer memory _buf, string memory _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_STRING, bytes(_value).length);
        _buf.append(bytes(_value));
    }

    function startArray(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_ARRAY);
    }

    function startMap(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_MAP);
    }

    function endSequence(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_CONTENT_FREE);
    }
}

contract usingProvable {


    using CBOR for Buffer.buffer;

    ProvableI provable;
    OracleAddrResolverI OAR;

    uint constant day = 60 * 60 * 24;
    uint constant week = 60 * 60 * 24 * 7;
    uint constant month = 60 * 60 * 24 * 30;

    byte constant proofType_NONE = 0x00;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    byte constant proofType_Android = 0x40;
    byte constant proofType_TLSNotary = 0x10;

    string provable_network_name;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_consensys = 161;

    mapping(bytes32 => bytes32) provable_randomDS_args;
    mapping(bytes32 => bool) provable_randomDS_sessionKeysHashVerified;

    modifier provableAPI {

        if ((address(OAR) == address(0)) || (getCodeSize(address(OAR)) == 0)) {
            provable_setNetwork(networkID_auto);
        }
        if (address(provable) != OAR.getAddress()) {
            provable = ProvableI(OAR.getAddress());
        }
        _;
    }

    modifier provable_randomDS_proofVerify(bytes32 _queryId, string memory _result, bytes memory _proof) {

        require((_proof[0] == "L") && (_proof[1] == "P") && (uint8(_proof[2]) == uint8(1)));
        bool proofVerified = provable_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), provable_getNetworkName());
        require(proofVerified);
        _;
    }

    function provable_setNetwork(uint8 _networkID) internal returns (bool _networkSet) {

      _networkID; // NOTE: Silence the warning and remain backwards compatible
      return provable_setNetwork();
    }

    function provable_setNetworkName(string memory _network_name) internal {

        provable_network_name = _network_name;
    }

    function provable_getNetworkName() internal view returns (string memory _networkName) {

        return provable_network_name;
    }

    function provable_setNetwork() internal returns (bool _networkSet) {

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed) > 0) { //mainnet
            OAR = OracleAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            provable_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1) > 0) { //ropsten testnet
            OAR = OracleAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            provable_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e) > 0) { //kovan testnet
            OAR = OracleAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            provable_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48) > 0) { //rinkeby testnet
            OAR = OracleAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            provable_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0xa2998EFD205FB9D4B4963aFb70778D6354ad3A41) > 0) { //goerli testnet
            OAR = OracleAddrResolverI(0xa2998EFD205FB9D4B4963aFb70778D6354ad3A41);
            provable_setNetworkName("eth_goerli");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475) > 0) { //ethereum-bridge
            OAR = OracleAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF) > 0) { //ether.camp ide
            OAR = OracleAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA) > 0) { //browser-solidity
            OAR = OracleAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }
    function __callback(bytes32 _myid, string memory _result) virtual public {

        __callback(_myid, _result, new bytes(0));
    }

    function __callback(bytes32 _myid, string memory _result, bytes memory _proof) virtual public {

      _myid; _result; _proof;
      provable_randomDS_args[bytes32(0)] = bytes32(0);
    }

    function provable_getPrice(string memory _datasource) provableAPI internal returns (uint _queryPrice) {

        return provable.getPrice(_datasource);
    }

    function provable_getPrice(string memory _datasource, uint _gasLimit) provableAPI internal returns (uint _queryPrice) {

        return provable.getPrice(_datasource, _gasLimit);
    }

    function provable_query(string memory _datasource, string memory _arg) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query{value: price}(0, _datasource, _arg);
    }

    function provable_query(uint _timestamp, string memory _datasource, string memory _arg) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query{value: price}(_timestamp, _datasource, _arg);
    }

    function provable_query(uint _timestamp, string memory _datasource, string memory _arg, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource,_gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return provable.query_withGasLimit{value: price}(_timestamp, _datasource, _arg, _gasLimit);
    }

    function provable_query(string memory _datasource, string memory _arg, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
           return 0; // Unexpectedly high price
        }
        return provable.query_withGasLimit{value: price}(0, _datasource, _arg, _gasLimit);
    }

    function provable_query(string memory _datasource, string memory _arg1, string memory _arg2) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query2{value: price}(0, _datasource, _arg1, _arg2);
    }

    function provable_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query2{value: price}(_timestamp, _datasource, _arg1, _arg2);
    }

    function provable_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return provable.query2_withGasLimit{value: price}(_timestamp, _datasource, _arg1, _arg2, _gasLimit);
    }

    function provable_query(string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return provable.query2_withGasLimit{value: price}(0, _datasource, _arg1, _arg2, _gasLimit);
    }

    function provable_query(string memory _datasource, string[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return provable.queryN{value: price}(0, _datasource, args);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return provable.queryN{value: price}(_timestamp, _datasource, args);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return provable.queryN_withGasLimit{value: price}(_timestamp, _datasource, args, _gasLimit);
    }

    function provable_query(string memory _datasource, string[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return provable.queryN_withGasLimit{value: price}(0, _datasource, args, _gasLimit);
    }

    function provable_query(string memory _datasource, string[1] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[1] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[2] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[2] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[3] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[3] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[4] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[4] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[5] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[5] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, string[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return provable.queryN{value: price}(0, _datasource, args);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return provable.queryN{value: price}(_timestamp, _datasource, args);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return provable.queryN_withGasLimit{value: price}(_timestamp, _datasource, args, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return provable.queryN_withGasLimit{value: price}(0, _datasource, args, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[1] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[1] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[2] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[2] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[3] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[3] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[4] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[4] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[5] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[5] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(uint _timestamp, string memory _datasource, bytes[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_setProof(byte _proofP) provableAPI internal {

        return provable.setProofType(_proofP);
    }


    function provable_cbAddress() provableAPI internal returns (address _callbackAddress) {

        return provable.cbAddress();
    }

    function getCodeSize(address _addr) view internal returns (uint _size) {

        assembly {
            _size := extcodesize(_addr)
        }
    }

    function provable_setCustomGasPrice(uint _gasPrice) provableAPI internal {

        return provable.setCustomGasPrice(_gasPrice);
    }

    function provable_randomDS_getSessionPubKeyHash() provableAPI internal returns (bytes32 _sessionKeyHash) {

        return provable.randomDS_getSessionPubKeyHash();
    }

    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {

        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function strCompare(string memory _a, string memory _b) internal pure returns (int _returnCode) {

        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) {
            minLength = b.length;
        }
        for (uint i = 0; i < minLength; i ++) {
            if (a[i] < b[i]) {
                return -1;
            } else if (a[i] > b[i]) {
                return 1;
            }
        }
        if (a.length < b.length) {
            return -1;
        } else if (a.length > b.length) {
            return 1;
        } else {
            return 0;
        }
    }

    function indexOf(string memory _haystack, string memory _needle) internal pure returns (int _returnCode) {

        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if (h.length < 1 || n.length < 1 || (n.length > h.length)) {
            return -1;
        } else if (h.length > (2 ** 128 - 1)) {
            return -1;
        } else {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i++) {
                if (h[i] == n[0]) {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) {
                        subindex++;
                    }
                    if (subindex == n.length) {
                        return int(i);
                    }
                }
            }
            return -1;
        }
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function safeParseInt(string memory _a) internal pure returns (uint _parsedInt) {

        return safeParseInt(_a, 0);
    }

    function safeParseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {
                if (decimals) {
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(uint8(bresult[i])) - 48;
            } else if (uint(uint8(bresult[i])) == 46) {
                require(!decimals, 'More than one decimal encountered in string!');
                decimals = true;
            } else {
                revert("Non-numeral character encountered in string!");
            }
        }
        if (_b > 0) {
            mint *= 10 ** _b;
        }
        return mint;
    }

    function parseInt(string memory _a) internal pure returns (uint _parsedInt) {

        return parseInt(_a, 0);
    }

    function parseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {
                if (decimals) {
                   if (_b == 0) {
                       break;
                   } else {
                       _b--;
                   }
                }
                mint *= 10;
                mint += uint(uint8(bresult[i])) - 48;
            } else if (uint(uint8(bresult[i])) == 46) {
                decimals = true;
            }
        }
        if (_b > 0) {
            mint *= 10 ** _b;
        }
        return mint;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] memory _arr) internal pure returns (bytes memory _cborEncoding) {

        safeMemoryCleaner();
        Buffer.buffer memory buf;
        Buffer.init(buf, 1024);
        buf.startArray();
        for (uint i = 0; i < _arr.length; i++) {
            buf.encodeString(_arr[i]);
        }
        buf.endSequence();
        return buf.buf;
    }

    function ba2cbor(bytes[] memory _arr) internal pure returns (bytes memory _cborEncoding) {

        safeMemoryCleaner();
        Buffer.buffer memory buf;
        Buffer.init(buf, 1024);
        buf.startArray();
        for (uint i = 0; i < _arr.length; i++) {
            buf.encodeBytes(_arr[i]);
        }
        buf.endSequence();
        return buf.buf;
    }

    function provable_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32 _queryId) {

        require((_nbytes > 0) && (_nbytes <= 32));
        _delay *= 10; // Convert from seconds to ledger timer ticks
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(uint8(_nbytes));
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = provable_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number(), 1)), xor(coinbase(), timestamp())))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly {
            mstore(add(delay, 0x20), _delay)
        }
        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);
        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = provable_query("random", args, _customGasLimit);
        bytes memory delay_bytes8_left = new bytes(8);
        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))
        }
        provable_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));
        return queryId;
    }

    function provable_randomDS_setCommitment(bytes32 _queryId, bytes32 _commitment) internal {

        provable_randomDS_args[_queryId] = _commitment;
    }

    function verifySig(bytes32 _tosignh, bytes memory _dersig, bytes memory _pubkey) internal returns (bool _sigVerified) {

        bool sigok;
        address signer;
        bytes32 sigr;
        bytes32 sigs;
        bytes memory sigr_ = new bytes(32);
        uint offset = 4 + (uint(uint8(_dersig[3])) - 0x20);
        sigr_ = copyBytes(_dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(_dersig, offset + (uint(uint8(_dersig[offset - 1])) - 0x20), 32, sigs_, 0);
        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }
        (sigok, signer) = safer_ecrecover(_tosignh, 27, sigr, sigs);
        if (address(uint160(uint256(keccak256(_pubkey)))) == signer) {
            return true;
        } else {
            (sigok, signer) = safer_ecrecover(_tosignh, 28, sigr, sigs);
            return (address(uint160(uint256(keccak256(_pubkey)))) == signer);
        }
    }

    function provable_randomDS_proofVerify__sessionKeyValidity(bytes memory _proof, uint _sig2offset) internal returns (bool _proofVerified) {

        bool sigok;
        bytes memory sig2 = new bytes(uint(uint8(_proof[_sig2offset + 1])) + 2);
        copyBytes(_proof, _sig2offset, sig2.length, sig2, 0);
        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(_proof, 3 + 1, 64, appkey1_pubkey, 0);
        bytes memory tosign2 = new bytes(1 + 65 + 32);
        tosign2[0] = byte(uint8(1)); //role
        copyBytes(_proof, _sig2offset - 65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1 + 65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);
        if (!sigok) {
            return false;
        }
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";
        bytes memory tosign3 = new bytes(1 + 65);
        tosign3[0] = 0xFE;
        copyBytes(_proof, 3, 65, tosign3, 1);
        bytes memory sig3 = new bytes(uint(uint8(_proof[3 + 65 + 1])) + 2);
        copyBytes(_proof, 3 + 65, sig3.length, sig3, 0);
        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);
        return sigok;
    }

    function provable_randomDS_proofVerify__returnCode(bytes32 _queryId, string memory _result, bytes memory _proof) internal returns (uint8 _returnCode) {

        if ((_proof[0] != "L") || (_proof[1] != "P") || (uint8(_proof[2]) != uint8(1))) {
            return 1;
        }
        bool proofVerified = provable_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), provable_getNetworkName());
        if (!proofVerified) {
            return 2;
        }
        return 0;
    }

    function matchBytes32Prefix(bytes32 _content, bytes memory _prefix, uint _nRandomBytes) internal pure returns (bool _matchesPrefix) {

        bool match_ = true;
        require(_prefix.length == _nRandomBytes);
        for (uint256 i = 0; i< _nRandomBytes; i++) {
            if (_content[i] != _prefix[i]) {
                match_ = false;
            }
        }
        return match_;
    }

    function provable_randomDS_proofVerify__main(bytes memory _proof, bytes32 _queryId, bytes memory _result, string memory _contextName) internal returns (bool _proofVerified) {

        uint ledgerProofLength = 3 + 65 + (uint(uint8(_proof[3 + 65 + 1])) + 2) + 32;
        bytes memory keyhash = new bytes(32);
        copyBytes(_proof, ledgerProofLength, 32, keyhash, 0);
        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(_contextName, _queryId)))))) {
            return false;
        }
        bytes memory sig1 = new bytes(uint(uint8(_proof[ledgerProofLength + (32 + 8 + 1 + 32) + 1])) + 2);
        copyBytes(_proof, ledgerProofLength + (32 + 8 + 1 + 32), sig1.length, sig1, 0);
        if (!matchBytes32Prefix(sha256(sig1), _result, uint(uint8(_proof[ledgerProofLength + 32 + 8])))) {
            return false;
        }
        bytes memory commitmentSlice1 = new bytes(8 + 1 + 32);
        copyBytes(_proof, ledgerProofLength + 32, 8 + 1 + 32, commitmentSlice1, 0);
        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength + 32 + (8 + 1 + 32) + sig1.length + 65;
        copyBytes(_proof, sig2offset - 64, 64, sessionPubkey, 0);
        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (provable_randomDS_args[_queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))) { //unonce, nbytes and sessionKeyHash match
            delete provable_randomDS_args[_queryId];
        } else return false;
        bytes memory tosign1 = new bytes(32 + 8 + 1 + 32);
        copyBytes(_proof, ledgerProofLength, 32 + 8 + 1 + 32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) {
            return false;
        }
        if (!provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash]) {
            provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = provable_randomDS_proofVerify__sessionKeyValidity(_proof, sig2offset);
        }
        return provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }
    function copyBytes(bytes memory _from, uint _fromOffset, uint _length, bytes memory _to, uint _toOffset) internal pure returns (bytes memory _copiedBytes) {

        uint minLength = _length + _toOffset;
        require(_to.length >= minLength); // Buffer too small. Should be a better way?
        uint i = 32 + _fromOffset; // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint j = 32 + _toOffset;
        while (i < (32 + _fromOffset + _length)) {
            assembly {
                let tmp := mload(add(_from, i))
                mstore(add(_to, j), tmp)
            }
            i += 32;
            j += 32;
        }
        return _to;
    }
    function safer_ecrecover(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal returns (bool _success, address _recoveredAddress) {

        bool ret;
        address addr;
        assembly {
            let size := mload(0x40)
            mstore(size, _hash)
            mstore(add(size, 32), _v)
            mstore(add(size, 64), _r)
            mstore(add(size, 96), _s)
            ret := call(3000, 1, 0, size, 128, size, 32) // NOTE: we can reuse the request memory because we deal with the return code.
            addr := mload(size)
        }
        return (ret, addr);
    }
    function ecrecovery(bytes32 _hash, bytes memory _sig) internal returns (bool _success, address _recoveredAddress) {

        bytes32 r;
        bytes32 s;
        uint8 v;
        if (_sig.length != 65) {
            return (false, address(0));
        }
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return (false, address(0));
        }
        return safer_ecrecover(_hash, v, r, s);
    }

    function safeMemoryCleaner() internal pure {

    }
}


interface IMainUniLotteryPool {

    function isLotteryOngoing( address lotAddr ) 
        external view returns( bool );


    function scheduledCallback( uint256 requestID ) 
        external;


    function onLotteryCallbackPriceExceedingGivenFunds(
                address lottery, uint currentRequestPrice,
                uint poolGivenPastRequestPrice )
        external returns( bool );

}

interface ILottery {

    function finish_randomnessProviderCallback( 
            uint256 randomSeed, uint256 requestID ) external;

}

contract UniLotteryRandomnessProvider is usingProvable
{


    event LotteryRandomSeedRequested(
        uint id,
        address lotteryAddress,
        uint gasLimit,
        uint totalEtherGiven
    );

    event LotteryRandomSeedCallbackCompleted(
        uint id
    );

    event PoolCallbackScheduled(
        uint id,
        address poolAddress,
        uint timeout,
        uint gasLimit,
        uint totalEtherGiven
    );

    event PoolCallbackCompleted(
        uint id
    );

    event EtherTransfered(
        address sender,
        uint value
    );



    enum RequestType {
        LOTTERY_RANDOM_SEED,
        POOL_SCHEDULED_CALLBACK
    }

    struct CallRequestData
    {

        uint256 requestID;


        address requesterAddress;

        RequestType reqType;
    }

    struct LotteryGasConfig
    {

        uint160 etherFundsTransferedForGas;

        uint64 gasLimit;
    }




    mapping( uint256 => CallRequestData ) pendingRequests;


    mapping( address => LotteryGasConfig ) lotteryGasConfigs;


    address payable poolAddress;



    modifier poolOnly 
    {

        require( msg.sender == poolAddress/*,
                 "Function can only be called by the Main Pool!" */);
        _;
    }

    modifier ongoingLotteryOnly
    {

        require( IMainUniLotteryPool( poolAddress )
                 .isLotteryOngoing( msg.sender )/*,
                 "Function can be called only by ongoing lotteries!" */);
        _;
    }


    constructor()
    {
        provable_setProof( proofType_Ledger );
    }

    function initialize()       external
    {

        require( poolAddress == address( 0 )/*,
                 "Contract is already initialized!" */);

        poolAddress = msg.sender;
    }


    receive ()    external payable
    {
        emit EtherTransfered( msg.sender, msg.value );
    }


    function getPriceForRandomnessCallback( uint gasLimit )
                                                                external
    returns( uint totalEtherPrice )
    {

        return provable_getPrice( "random", gasLimit );
    }

    function getPriceForScheduledCallback( uint gasLimit )
                                                                external
    returns( uint totalEtherPrice )
    {

        return provable_getPrice( "URL", gasLimit );
    }


    function setLotteryCallbackGas(
            address lotteryAddr,
            uint64 callbackGasLimit,
            uint160 totalEtherTransferedForThisOne )
                                                        external
                                                        poolOnly
    {

        LotteryGasConfig memory gasConfig;

        gasConfig.gasLimit = callbackGasLimit;
        gasConfig.etherFundsTransferedForGas = totalEtherTransferedForThisOne;

        lotteryGasConfigs[ lotteryAddr ] = gasConfig;
    }


    function __callback(
            bytes32 _queryId,
            string memory _result,
            bytes memory _proof )
                                            public
                                            override
    {

        require( msg.sender == provable_cbAddress() );

        CallRequestData storage reqData = 
            pendingRequests[ uint256( _queryId ) ];

        require( reqData.requestID != 0/*,
                 "Invalid Request Data structure (Response is Invalid)!" */);


        if( reqData.reqType == RequestType.LOTTERY_RANDOM_SEED )
        {
            require( provable_randomDS_proofVerify__returnCode(
                        _queryId, _result, _proof ) == 0/*,
                     "Random Datasource Proof Verification has FAILED!" */);
                
            uint256 randomNumber = uint256( 
                    keccak256( abi.encodePacked( _result ) ) );

            ILottery( reqData.requesterAddress )
                    .finish_randomnessProviderCallback( 
                            randomNumber, uint( _queryId ) );

            emit LotteryRandomSeedCallbackCompleted( uint( _queryId ) );
        }

        else if( reqData.reqType == RequestType.POOL_SCHEDULED_CALLBACK )
        {
            IMainUniLotteryPool( poolAddress )
                    .scheduledCallback( uint( _queryId ) );

            emit PoolCallbackCompleted( uint( _queryId ) );
        }

        delete pendingRequests[ uint256( _queryId ) ];
    }


    function requestRandomSeedForLotteryFinish()
                                                    external
                                                    ongoingLotteryOnly
    returns( uint256 requestId )
    {

        require( lotteryGasConfigs[ msg.sender ].gasLimit != 0/*,
                 "Gas limit for this lottery was not set!" */);

        uint transactionPrice = provable_getPrice( "random", 
                    lotteryGasConfigs[ msg.sender ].gasLimit );

        if( transactionPrice >
            lotteryGasConfigs[ msg.sender ].etherFundsTransferedForGas )
        {
            if( address(this).balance >= transactionPrice )
            {
                bool response = IMainUniLotteryPool( poolAddress )
                .onLotteryCallbackPriceExceedingGivenFunds(
                    msg.sender, 
                    transactionPrice,
                    lotteryGasConfigs[msg.sender].etherFundsTransferedForGas
                );

                require( response/*, "Pool has denied the request!" */);
            }
            else {
                require( false/*, "Request price exceeds contract's balance!" */);
            }
        }

        uint256 QUERY_EXECUTION_DELAY = 0;

        uint256 GAS_FOR_CALLBACK = lotteryGasConfigs[ msg.sender ].gasLimit;

        uint256 NUM_RANDOM_BYTES_REQUESTED = 8;

        uint256 queryId = uint256( provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        ) );

        CallRequestData memory requestData;

        requestData.requestID = queryId;
        requestData.reqType = RequestType.LOTTERY_RANDOM_SEED;
        requestData.requesterAddress = msg.sender;

        pendingRequests[ queryId ] = requestData;

        emit LotteryRandomSeedRequested( 
            queryId, msg.sender, 
            lotteryGasConfigs[ msg.sender ].gasLimit,
            lotteryGasConfigs[ msg.sender ].etherFundsTransferedForGas
        );

        delete lotteryGasConfigs[ msg.sender ];

        return queryId;
    }


    function schedulePoolCallback( 
                uint timeout, 
                uint gasLimit,
                uint etherFundsTransferedForGas )
                                                    external
                                                    poolOnly
    returns( uint256 requestId )
    {


        uint queryId = uint( 
                provable_query( timeout, "URL", "", gasLimit ) 
        );

        CallRequestData memory requestData;

        requestData.requestID = queryId;
        requestData.reqType = RequestType.POOL_SCHEDULED_CALLBACK;
        requestData.requesterAddress = msg.sender;

        pendingRequests[ queryId ] = requestData;

        emit PoolCallbackScheduled( queryId, poolAddress, timeout, gasLimit,
                                    etherFundsTransferedForGas );

        return queryId;
    }


    function sendFundsToPool( uint etherAmount )
                                                        external
                                                        poolOnly
    {

        poolAddress.transfer( etherAmount );
    }


    function setGasPrice( uint _gasPrice )
                                                        external
                                                        poolOnly
    {

        require( _gasPrice <= 600 * (10 ** 9)/*,
                 "Specified gas price is higher than 600 GWei !" */);

        provable_setCustomGasPrice( _gasPrice );
    }

}

contract LotteryStub {



    mapping (address => uint256) private _balances;


    mapping (address => mapping (address => uint256)) private _allowances;


    uint256 private _totalSupply;




    Lottery.LotteryConfig internal cfg;


    LotteryStorage /*public*/ lotStorage;


    address payable /*public*/ poolAddress;

    
    address /*public*/ randomnessProvider;


    address /*public*/ exchangeAddress;

    uint32 /*public*/ startDate;

    uint32 /*public*/ completionDate;
    
    uint32 finish_timeRandomSeedRequested;


    address WETHaddress;

    bool uniswap_ethFirst;

    uint32 finishProbablity;
    
    bool reEntrancyMutexLocked;
    
    uint8 /*public*/ lotteryStage;
    
    bool fundGainRequirementReached;
    
    uint16 miningStep;

    bool specialTransferModeEnabled;


    
    uint256 transferHashValue;


    uint128 /*public*/ ending_totalReturn;
    uint128 /*public*/ ending_profitAmount;


    mapping( address => bool ) /*public*/ prizeClaimersAddresses;




    address payable public __delegateContract;



    function stub_construct( address payable _delegateAddr )
                                                                external
    {

        require( __delegateContract == address(0) );
        __delegateContract = _delegateAddr;
    }

    fallback()
                external payable 
    {
        ( bool success, bytes memory data ) =
            __delegateContract.delegatecall( msg.data );

        assembly
        {
            switch success
                case 0  { revert( add( data, 32 ), returndatasize() ) }
                default { return( add( data, 32 ), returndatasize() ) }
        }
    }

    receive()   external payable
    { }

}

contract LotteryStorageStub {



    address lottery;

    uint64 randomSeed;

    uint16 numberOfWinners;

    bool algorithmCompleted;



    LotteryStorage.WinnerAlgorithmConfig algConfig;


    LotteryStorage.MinMaxHolderScores minMaxScores;


    address[] /*public*/ holders;


    mapping( address => uint ) holderIndexes;


    mapping( address => LotteryStorage.HolderData ) /*public*/ holderData;


    mapping( uint256 => address ) referrers;


    LotteryStorage.WinnerIndexStruct[] sortedWinnerIndexes;



    address public __delegateContract;




    function stub_construct( address _delegateAddr )
                                                                external
    {

        require( __delegateContract == address(0) );
        __delegateContract = _delegateAddr;
    }


    fallback()
                external
    {
        ( bool success, bytes memory data ) =
            __delegateContract.delegatecall( msg.data );

        assembly
        {
            switch success
                case 0  { revert( add( data, 32 ), returndatasize() ) }
                default { return( add( data, 32 ), returndatasize() ) }
        }
    }
}

contract UniLotteryStorageFactory {

    address payable poolAddress;

    address immutable public delegateContract;

    modifier poolOnly 
    {

        require( msg.sender == poolAddress/*,
                 "Function can only be called by the Main Pool!" */);
        _;
    }

    constructor()
    {
        delegateContract = address( new LotteryStorage() );
    }

    function initialize()
                                                            external
    {

        require( poolAddress == address( 0 )/*,
                 "Initialization has already finished!" */);

        poolAddress = msg.sender;
    }

    function createNewStorage()
                                                            public
                                                            poolOnly
    returns( address newStorage )
    {

        LotteryStorageStub stub = new LotteryStorageStub();
        stub.stub_construct( delegateContract );
        return address( stub );
    }
}

contract UniLotteryConfigGenerator {

    function getConfig()
                                                    external pure
    returns( Lottery.LotteryConfig memory cfg )
    {

        cfg.initialFunds = 10 ether;
    }
}

contract UniLotteryLotteryFactory {


    address payable immutable public delegateContract;

    address payable poolAddress;

    UniLotteryStorageFactory lotteryStorageFactory;


    modifier poolOnly 
    {

        require( msg.sender == poolAddress/*,
                 "Function can only be called by the Main Pool!" */);
        _;
    }

    constructor( /*address payable _uniRouter*/ )
    {
        delegateContract = address( uint160( address( new Lottery() ) ) );
    }

    function initialize( address _storageFactoryAddress )
                                                            external
    {

        require( poolAddress == address( 0 )/*,
                 "Initialization has already finished!" */);

        poolAddress = msg.sender;

        lotteryStorageFactory = 
            UniLotteryStorageFactory( _storageFactoryAddress );

        lotteryStorageFactory.initialize();
    }

    function createNewLottery( 
            Lottery.LotteryConfig memory config,
            address randomnessProvider )
                                                            public
                                                            poolOnly
    returns( address payable newLottery )
    {

        LotteryStub stub = new LotteryStub();
        stub.stub_construct( delegateContract );

        Lottery( address( stub ) ).construct(
                config, poolAddress, randomnessProvider,
                lotteryStorageFactory.createNewStorage() );

        return address( stub );
    }

}

contract UniLotteryPool is ERC20, CoreUniLotterySettings
{


    enum LotteryRunMode {
        MANUAL,
        AUTO,
        MANUAL_AVERAGE_CONFIG,
        AUTO_AVERAGE_CONFIG
    }



    event PoolStats(
        uint32 indexed lotteriesPerformed,
        uint indexed totalPoolFunds,
        uint indexed currentPoolBalance
    );

    event NewPoolholderJoin(
        address indexed poolholder,
        uint256 initialAmount
    );

    event PoolholderWithdraw(
        address indexed poolholder
    );

    event AddedLiquidity(
        address indexed poolholder,
        uint256 indexed amount
    );

    event RemovedLiquidity(
        address indexed poolholder,
        uint256 indexed amount
    );

    
    event LotteryRunModeChanged(
        LotteryRunMode previousMode,
        LotteryRunMode newMode
    );


    event NewConfigProposed(
        address indexed initiator,
        Lottery.LotteryConfig cfg,
        uint configIndex
    );

    event LotteryStarted(
        address indexed lottery,
        uint256 indexed fundsUsed,
        uint256 indexed poolPercentageUsed,
        Lottery.LotteryConfig config
    );

    event LotteryFinished(
        address indexed lottery,
        uint256 indexed totalReturn,
        uint256 indexed profitAmount
    );

    event EtherReceived(
        address indexed sender,
        uint256 indexed value
    );




    string constant public name = "UniLottery Main Pool";
    string constant public symbol = "ULPT";
    uint256 constant public decimals = 18;




    uint80 randomnessProviderDebt;
    
    uint32 public autoMode_nextLotteryDelay  = 1 days;
    uint16 public autoMode_maxNumberOfRuns   = 50;

    uint32 public autoMode_lastLotteryStarted;
    
    uint32 public autoMode_lastLotteryFinished;

    uint32 public autoMode_timeCallbackScheduled;

    uint16 autoMode_currentCycleIterations = 0;

    bool public autoMode_isLotteryCurrentlyOngoing = false;

    bool reEntrancyLock_Locked;



    uint currentLotteryFunds;



    Lottery public mostRecentLottery;

    LotteryRunMode public lotteryRunMode = LotteryRunMode.MANUAL;

    uint32 lastTimeRandomFundsSend;



    address gasOracleAddress;


    Lottery[] public allLotteriesPerformed;


    mapping( address => bool ) ongoingLotteries;


    mapping( address => bool ) public ownerApprovedAddresses;


    Lottery.LotteryConfig internal nextLotteryConfig;


    UniLotteryRandomnessProvider immutable public randomnessProvider;


    UniLotteryLotteryFactory immutable public lotteryFactory;


    address immutable public storageFactory;

    




    modifier ownerOnly
    {

        require( msg.sender == OWNER_ADDRESS/*, "Function is Owner-Only!" */);
        _;
    }

    modifier ownerApprovedAddressOnly 
    {

        require( ownerApprovedAddresses[ msg.sender ]/*,
                 "Function can be called only by Owner-Approved addresses!"*/);
        _;
    }

    modifier gasOracleAndOwnerApproved 
    {

        require( ownerApprovedAddresses[ msg.sender ] ||
                 msg.sender == gasOracleAddress/*,
                 "Function can only be called by Owner-Approved addrs, "
                 "and by the Gas Oracle!" */);
        _;
    }


    modifier randomnessProviderOnly
    {

        require( msg.sender == address( randomnessProvider )/*,
                 "Function can be called only by the Randomness Provider!" */);
        _;
    }

    modifier calledByOngoingLotteryOnly 
    {

        require( ongoingLotteries[ msg.sender ]/*,
                 "Function can be called only by ongoing lotteries!"*/);
        _;
    }


    modifier mutexLOCKED
    {

        require( ! reEntrancyLock_Locked/*, "Re-Entrant Call Detected!" */);

        reEntrancyLock_Locked = true;
        _;
        reEntrancyLock_Locked = false;
    }



    function emitPoolStats() 
                                                private 
    {

        (uint32 a, uint b, uint c) = getPoolStats();
        emit PoolStats( a, b, c );
    }


    function launchLottery( 
            Lottery.LotteryConfig memory cfg ) 
                                                        private
                                                        mutexLOCKED
    returns( Lottery newlyLaunchedLottery )
    {


        uint callbackPrice = randomnessProvider
            .getPriceForRandomnessCallback( LOTTERY_RAND_CALLBACK_GAS );



        uint totalCost = cfg.initialFunds + callbackPrice +
                         randomnessProviderDebt;

        require( totalCost <= address( this ).balance/*,
                 "Insufficient funds for this lottery start!" */);

        Lottery lottery = Lottery( lotteryFactory.createNewLottery( 
                cfg, address( randomnessProvider ) ) );

        require( lottery.poolAddress() == address( this ) &&
                 lottery.OWNER_ADDRESS() == OWNER_ADDRESS/*,
                 "Lottery's pool or owner addresses are invalid!" */);

        address( randomnessProvider ).transfer( 
                    callbackPrice + randomnessProviderDebt );

        randomnessProviderDebt = 0;

        randomnessProvider.setLotteryCallbackGas( 
                address( lottery ), 
                LOTTERY_RAND_CALLBACK_GAS,
                uint160( callbackPrice )
        );

        lottery.initialize{ value: cfg.initialFunds }();


        ongoingLotteries[ address(lottery) ] = true;
        allLotteriesPerformed.push( lottery );

        mostRecentLottery = lottery;

        currentLotteryFunds += cfg.initialFunds;

        emit LotteryStarted( 
            address( lottery ), 
            cfg.initialFunds,
            ( (_100PERCENT) * totalCost ) / totalPoolFunds(),
            cfg
        );

        return lottery;
    }


    function scheduleAutoModeCallback()
                                            private
                                            mutexLOCKED
    returns( bool success )
    {

        if( lotteryRunMode != LotteryRunMode.AUTO ) {
            autoMode_currentCycleIterations = 0;
            return false;
        }


        uint callbackPrice = randomnessProvider
            .getPriceForScheduledCallback( AUTO_MODE_SCHEDULED_CALLBACK_GAS );

        uint totalPrice = callbackPrice + randomnessProviderDebt;
        
        if( totalPrice > address(this).balance ) {
            return false;
        }

        if( ! address( randomnessProvider ).send( totalPrice ) ) {
            return false;
        }

        randomnessProviderDebt = 0;

        randomnessProvider.schedulePoolCallback(
            autoMode_nextLotteryDelay,
            AUTO_MODE_SCHEDULED_CALLBACK_GAS,
            callbackPrice
        );

        autoMode_timeCallbackScheduled = uint32( block.timestamp );

        return true;
    }



    constructor( address _lotteryFactoryAddr,
                 address _storageFactoryAddr,
                 address payable _randProvAddr ) 
    {
        UniLotteryRandomnessProvider( _randProvAddr ).initialize();
        randomnessProvider = UniLotteryRandomnessProvider( _randProvAddr );

        UniLotteryLotteryFactory _lotteryFactory = 
            UniLotteryLotteryFactory( _lotteryFactoryAddr );

        _lotteryFactory.initialize( _storageFactoryAddr );

        storageFactory = _storageFactoryAddr;
        lotteryFactory = _lotteryFactory;

        ownerApprovedAddresses[ OWNER_ADDRESS ] = true;
    }


    receive()   external payable
    {
        emit EtherReceived( msg.sender, msg.value );
    }



    function totalPoolFunds()                   public view
    returns( uint256 ) 
    {


        return address(this).balance + currentLotteryFunds;
    }

    function getPoolStats()
                                                public view
    returns( 
        uint32 _numberOfLotteriesPerformed,
        uint _totalPoolFunds,
        uint _currentPoolBalance )
    {

        _numberOfLotteriesPerformed = uint32( allLotteriesPerformed.length );
        _totalPoolFunds     = totalPoolFunds();
        _currentPoolBalance = address( this ).balance;
    }



    function provideLiquidity() 
                                    external 
                                    payable 
                                    ownerApprovedAddressOnly
                                    mutexLOCKED
    {



        uint percentage =   ( (_100PERCENT) * msg.value ) / 
                            ( totalPoolFunds() );


        if( balanceOf( msg.sender ) == 0 )
            emit NewPoolholderJoin( msg.sender, msg.value );


        if( percentage < (_100PERCENT) &&
            totalSupply() != 0 )
        {
            uint256 amountToMint = 
                ( percentage * totalSupply() ) /
                (       (_100PERCENT) - percentage        );

            _mint( msg.sender, amountToMint );
        }

        else
        {
            _mint( msg.sender, ( 100 * (uint( 10 ) ** decimals) ) );
        }


        emit AddedLiquidity( msg.sender, msg.value );
        emitPoolStats();
    }


    function getPoolSharePercentage( address holder ) 
                                                        public view
    returns ( uint percentage ) 
    {

        return  ( (_100PERCENT) * balanceOf( holder ) )
                / totalSupply();
    }


    function removeLiquidity(
            uint256 ulptAmount ) 
                                                external
                                                ownerApprovedAddressOnly
                                                mutexLOCKED
    {

        address payable liquidityOwner = OWNER_ADDRESS;


        require( balanceOf( liquidityOwner ) > 1 &&
                 ulptAmount != 0 &&
                 ulptAmount <= balanceOf( liquidityOwner )/*,
                 "Specified ULPT token amount is invalid!" */);

        uint256 percentage = ( (_100PERCENT) * ulptAmount ) / 
                             totalSupply();

        uint256 shareAmount = ( totalPoolFunds() * percentage ) /
                              (_100PERCENT);

        require( shareAmount <= address( this ).balance/*, 
                 "Insufficient pool contract balance!" */);

        _burn( liquidityOwner, ulptAmount );


        liquidityOwner.transfer( shareAmount );


        if( balanceOf( liquidityOwner ) == 0 )
            emit PoolholderWithdraw( liquidityOwner );

        emit RemovedLiquidity( liquidityOwner, shareAmount );
        emitPoolStats();
    }



    function isLotteryOngoing( address lotAddr ) 
                                                    external view
    returns( bool ) {

        return ongoingLotteries[ lotAddr ];
    }


    function allLotteriesPerformed_length()
                                                    external view
    returns( uint )
    {

        return allLotteriesPerformed.length;
    }


    function lotteryFinish( 
                uint totalReturn, 
                uint profitAmount )
                                            external
                                            payable
                                            calledByOngoingLotteryOnly
    {

        delete ongoingLotteries[ msg.sender ];  // implies "false"


        uint lotFunds = Lottery( msg.sender ).getInitialFunds();
        if( lotFunds < currentLotteryFunds )
            currentLotteryFunds -= lotFunds;
        else
            currentLotteryFunds = 0;

        emit LotteryFinished( msg.sender, totalReturn, profitAmount );


        if( lotteryRunMode == LotteryRunMode.AUTO )
        {
            autoMode_isLotteryCurrentlyOngoing = false;
            autoMode_lastLotteryFinished = uint32( block.timestamp );

            scheduleAutoModeCallback();
        }
    }


    function scheduledCallback( uint256 /*requestID*/ ) 
                                                                public
    {

        if( lotteryRunMode != LotteryRunMode.AUTO )
            return;

        if( autoMode_currentCycleIterations >= autoMode_maxNumberOfRuns )
        {
            autoMode_currentCycleIterations = 0;
            return;
        }


        launchLottery( nextLotteryConfig );

        autoMode_isLotteryCurrentlyOngoing = true;
        autoMode_lastLotteryStarted = uint32( block.timestamp );
        autoMode_currentCycleIterations++;
    }


    function onLotteryCallbackPriceExceedingGivenFunds(
            address /*lottery*/, 
            uint currentRequestPrice,
            uint poolGivenExpectedRequestPrice )
                                                    external 
                                                    randomnessProviderOnly
    returns( bool callbackExecutionPermitted )
    {

        require( currentRequestPrice > poolGivenExpectedRequestPrice );
        uint difference = currentRequestPrice - poolGivenExpectedRequestPrice;

        if( difference <= ( poolGivenExpectedRequestPrice / 2 ) &&
            ( randomnessProviderDebt + difference ) < ( (1 ether) / 2 ) )
        {
            randomnessProviderDebt += uint80( difference );

            return true;
        }

        return false;
    }



    function setNextLotteryConfig(
            Lottery.LotteryConfig memory cfg )
                                                    public
                                                    ownerApprovedAddressOnly
    {

        nextLotteryConfig = cfg;

        emit NewConfigProposed( msg.sender, cfg, 0 );
    }

    function setRunMode(
            LotteryRunMode runMode )
                                                    external
                                                    ownerApprovedAddressOnly
    {

        require( runMode == LotteryRunMode.AUTO ||
                 runMode == LotteryRunMode.MANUAL/*,
                 "This Run Mode is not allowed in current state!" */);

        emit LotteryRunModeChanged( lotteryRunMode, runMode );

        lotteryRunMode = runMode;

    }

    function startManualModeLottery()
                                                    external
                                                    ownerApprovedAddressOnly
    {

        require( nextLotteryConfig.initialFunds != 0/*,
                 "Currently set next-lottery-config is invalid!" */);

        launchLottery( nextLotteryConfig );

        emitPoolStats();
    }


    function setAutoModeParameters(
            uint32 nextLotteryDelay,
            uint16 maxNumberOfRuns )
                                                    external
                                                    ownerApprovedAddressOnly
    {

        autoMode_nextLotteryDelay = nextLotteryDelay;
        autoMode_maxNumberOfRuns = maxNumberOfRuns;

    }

    function startAutoModeCycle()
                                                    external
                                                    ownerApprovedAddressOnly
    {

        require( lotteryRunMode == LotteryRunMode.AUTO/*,
                 "Current Run Mode is not AUTO!" */);

        require( autoMode_maxNumberOfRuns != 0/*,
                 "Invalid Auto-Mode params set!" */);

        autoMode_currentCycleIterations = 0;

        scheduledCallback( 0 );

    }

    function owner_setOwnerApprovedAddress( address addr )
                                                                external
                                                                ownerOnly
    {

        ownerApprovedAddresses[ addr ] = true;
    }

    function owner_removeOwnerApprovedAddress( address addr )
                                                                external
                                                                ownerOnly
    {

        delete ownerApprovedAddresses[ addr ];
    }


    function getNextLotteryConfig()
                                                                external 
                                                                view
    returns( Lottery.LotteryConfig memory )
    {

        return nextLotteryConfig;
    }

    function retrieveUnclaimedLotteryPrizes(
            address payable lottery )
                                                    external
                                                    ownerApprovedAddressOnly
                                                    mutexLOCKED
    {

        Lottery( lottery ).getUnclaimedPrizes();
    }


    function retrieveRandomnessProviderFunds(
            uint etherAmount )
                                                    external
                                                    ownerApprovedAddressOnly
                                                    mutexLOCKED
    {

        randomnessProvider.sendFundsToPool( etherAmount );
    }

    function provideRandomnessProviderFunds(
            uint etherAmount )
                                                    external
                                                    ownerApprovedAddressOnly
                                                    mutexLOCKED
    {

        require( ( etherAmount <= 6 ether ) &&
                 ( block.timestamp - lastTimeRandomFundsSend > 12 hours )/*,
                 "Random Fund Provide Conditions are not satisfied!" */);

        lastTimeRandomFundsSend = uint32( block.timestamp );

        address( randomnessProvider ).transfer( etherAmount );
    }


    function setGasPriceOfRandomnessProvider(
            uint gasPrice )
                                                external
                                                gasOracleAndOwnerApproved
    {

        randomnessProvider.setGasPrice( gasPrice );
    }


    function setGasOracleAddress( address addr )
                                                    external
                                                    ownerApprovedAddressOnly
    {

        gasOracleAddress = addr;
    }

}