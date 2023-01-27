

pragma solidity 0.7.5;

interface GFarmTokenInterface{

	function balanceOf(address account) external view returns (uint256);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function burn(address from, uint256 amount) external;

    function mint(address to, uint256 amount) external;

}


pragma solidity 0.7.5;

interface GFarmNFTInterface{

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function leverageID(uint8 _leverage) external pure returns(uint8);

    function idToLeverage(uint id) external view returns(uint8);

}


pragma solidity ^0.7.0;

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


pragma solidity 0.7.5;





contract GFarmTrading{


    using SafeMath for uint;


    GFarmTokenInterface public token;
    IUniswapV2Pair public lp;
    GFarmNFTInterface public nft;

    uint constant PRECISION = 1e5;
    bool public TRADING_PAUSED;
    uint constant MAX_GAIN_P = 400; // 400% = 5x
    uint constant STOP_LOSS_P = 90; // -90%
    uint public MIN_POSITION_SIZE_ETH = 0; // 1e18
    uint public MAX_POS_GFARM_LP_P = 200000; // (2%) PRECISION
    uint public MAX_ACTIVITY_PER_BLOCK = 10;
    uint constant MAX_GFARM_POS_MUL = 2; // 2x
    uint public TOTAL_GFARM_BURNED;
    uint public TOTAL_GFARM_MINTED;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Pair constant ethPairDAI = IUniswapV2Pair(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);
    IUniswapV2Pair constant ethPairUSDT = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    IUniswapV2Pair constant ethPairUSDC = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);

    address public GOVERNANCE;
    address public immutable DEV_FUND;
    uint constant GOVERNANCE_P = 50000; // PRECISION
    uint constant DEV_FUND_P = 50000; // PRECISION

    struct Trade{
        uint openBlock;
        address initiator;
        bool buy;
        uint openPrice; // PRECISION
        uint initialPositionSizeGFARM; // 1e18
        uint positionSizeETH; // 1e18
        uint16 leverage;
    }

    struct Gains{
        uint valueGFARM; // 1e18
        uint lastTradeClosed; // block
    }

    mapping(address => Trade) public trades;
    mapping(address => Gains) public gains;
    mapping(address => uint) private addressTradeOpenID;

    mapping(uint => uint) private tradesPerBlock;
    address[] public addressesTradeOpen;

    event TradeOpened(
        address indexed a,
        uint price,
        bool buy,
        uint positionSizeETH,
        uint positionSizeGFARM,
        uint leverage
    );
    event TradeClosed(
        address indexed a,
        uint price,
        bool buy,
        uint positionSizeETH,
        uint positionSizeGFARM,
        uint leverage,
        int pnlGFARM,
        int pnlETH
    );
    event TradeLiquidated(
        address indexed liquidator,
        address indexed trader,
        uint price,
        bool buy,
        uint positionSizeETH,
        uint positionSizeGFARM,
        uint leverage,
        uint rewardGFARM,
        uint rewardETH
    );
    event GainsClaimed(
        address indexed a,
        uint amountGFARM,
        uint amountETH
    );

    constructor(address _GOV, address _DEV){
        GOVERNANCE = _GOV;
        DEV_FUND = _DEV;
    }


    modifier onlyGov(){

        require(msg.sender == GOVERNANCE, "Can only be called by governance.");
        _;
    }

    function set_GOVERNANCE(address _gov) external onlyGov{

        require(msg.sender == GOVERNANCE);
        GOVERNANCE = _gov;
    }

    function set_TOKEN(address _token) external onlyGov{

        require(token == GFarmTokenInterface(0), "Token address already set");
        token = GFarmTokenInterface(_token);
    }

    function set_LP(address _lp) external onlyGov{

        require(lp == IUniswapV2Pair(0), "LP address already set");
        lp = IUniswapV2Pair(_lp);
    }

    function set_NFT(address _nft) external onlyGov{

        require(nft == GFarmNFTInterface(0), "NFT address already set");
        nft = GFarmNFTInterface(_nft);
    }

    function set_MAX_ACTIVITY_PER_BLOCK(uint _maxTrades) external onlyGov{

        require(_maxTrades < 15);
        MAX_ACTIVITY_PER_BLOCK = _maxTrades;
    }

    function set_MIN_POSITION_SIZE_ETH(uint _minPos) external onlyGov{

        MIN_POSITION_SIZE_ETH = _minPos;
    }

    function set_MAX_POS_GFARM_LP_P(uint _maxPosLp) external onlyGov{

        MAX_POS_GFARM_LP_P = _maxPosLp;
    }

    function pause() external onlyGov{

        TRADING_PAUSED = true;
    } 

    function restart() external onlyGov{

        TRADING_PAUSED = false;
    }


    function pairInfoDAI() private view returns(uint, uint){

        (uint112 reserves0, uint112 reserves1, ) = ethPairDAI.getReserves();
        uint reserveDAI;
        uint reserveETH;
        if(WETH == ethPairDAI.token0()){
            reserveETH = reserves0;
            reserveDAI = reserves1;
        }else{
            reserveDAI = reserves0;
            reserveETH = reserves1;
        }
        return (reserveDAI.mul(PRECISION).div(reserveETH), reserveETH);
    }
    function pairInfoUSDT() private view returns(uint, uint){

        (uint112 reserves0, uint112 reserves1, ) = ethPairUSDT.getReserves();
        uint reserveUSDT;
        uint reserveETH;
        if(WETH == ethPairUSDT.token0()){
            reserveETH = reserves0;
            reserveUSDT = reserves1;
        }else{
            reserveUSDT = reserves0;
            reserveETH = reserves1;
        }
        return (reserveUSDT.mul(1e12).mul(PRECISION).div(reserveETH), reserveETH);
    }
    function pairInfoUSDC() private view returns(uint, uint){

        (uint112 reserves0, uint112 reserves1, ) = ethPairUSDC.getReserves();
        uint reserveUSDC;
        uint reserveETH;
        if(WETH == ethPairUSDC.token0()){
            reserveETH = reserves0;
            reserveUSDC = reserves1;
        }else{
            reserveUSDC = reserves0;
            reserveETH = reserves1;
        }
        return (reserveUSDC.mul(1e12).mul(PRECISION).div(reserveETH), reserveETH);
    }
    function getEthPrice() public view returns(uint){

        (uint priceEthDAI, uint reserveEthDAI) = pairInfoDAI();
        (uint priceEthUSDT, uint reserveEthUSDT) = pairInfoUSDT();
        (uint priceEthUSDC, uint reserveEthUSDC) = pairInfoUSDC();

        uint reserveEth = reserveEthDAI.add(reserveEthUSDT).add(reserveEthUSDC);

        return (
                priceEthDAI.mul(reserveEthDAI).add(
                    priceEthUSDT.mul(reserveEthUSDT)
                ).add(
                    priceEthUSDC.mul(reserveEthUSDC)
                )
            ).div(reserveEth);
    }
    function getReservesLP() private view returns(uint, uint){

        (uint112 reserves0, uint112 reserves1, ) = lp.getReserves();

        uint reserveETH;
        uint reserveGFARM;

        if(WETH == lp.token0()){
            reserveETH = reserves0;
            reserveGFARM = reserves1;
        }else{
            reserveGFARM = reserves0;
            reserveETH = reserves1;
        }

        return (reserveGFARM, reserveETH);
    }
    function getGFarmPriceEth() private view returns(uint){

        (uint reserveGFARM, uint reserveETH) = getReservesLP();
        return reserveETH.mul(PRECISION).div(reserveGFARM);
    }


    function getMinPosGFARM() public view returns(uint){

        return MIN_POSITION_SIZE_ETH.mul(PRECISION).div(getGFarmPriceEth());
    }

    function getMaxPosGFARM(uint _leverage) public view returns(uint){

        (, uint reserveEthDAI) = pairInfoDAI();
        (, uint reserveEthUSDT) = pairInfoUSDT();
        (, uint reserveEthUSDC) = pairInfoUSDC();

        uint totalReserveETH = reserveEthDAI.add(reserveEthUSDT).add(reserveEthUSDC);
        uint sqrt10 = 3162277660168379331; // 1e18 precision

        uint maxPosGFARM = (sqrt10.mul(totalReserveETH).sub(totalReserveETH.mul(1e18)))
                        .div(_leverage.mul(3000))
                        .div(1e18/PRECISION).div(getGFarmPriceEth());

        (uint reserveGFARM, ) = getReservesLP();
        uint maxPosGFARM_lpBased = reserveGFARM.mul(MAX_POS_GFARM_LP_P).div(100*PRECISION);

        if(maxPosGFARM > maxPosGFARM_lpBased){
            return maxPosGFARM_lpBased; 
        }
        
        return maxPosGFARM;
    }

    
    function percentDiff(uint a, uint b) private pure returns(int){

        return (int(b) - int(a))*100*int(PRECISION)/int(a);
    }
    function currentPercentProfit(
        uint _openPrice,
        uint _currentPrice,
        bool _buy,
        uint16 _leverage) private pure returns(int p){

        if(_buy){
            p = percentDiff(_openPrice, _currentPrice)*int(_leverage);
        }else{
            p = percentDiff(_openPrice, _currentPrice)*(-1)*int(_leverage);
        }
        int maxLossPercentage = -100 * int(PRECISION);
        int maxGainPercentage = int(MAX_GAIN_P * PRECISION);
        if(p < maxLossPercentage){
            p = maxLossPercentage;
        }else if(p > maxGainPercentage){
            p = maxGainPercentage;
        }
    }
    function canLiquidatePure(
        uint _openPrice,
        uint _currentPrice,
        bool _buy,
        uint16 _leverage) private pure returns(bool){

        if(_buy){
            return currentPercentProfit(_openPrice, _currentPrice, _buy, _leverage) 
                    <= (-1)*int(STOP_LOSS_P*PRECISION);
        }else{
            return currentPercentProfit(_openPrice, _currentPrice, _buy, _leverage)
                    <= (-1)*int(STOP_LOSS_P*PRECISION);
        }
    }
    function unregisterOpenTrade(address a) private{

        delete trades[a];
        if(addressesTradeOpen.length > 1){
            addressesTradeOpen[addressTradeOpenID[a]] = 
                addressesTradeOpen[addressesTradeOpen.length - 1];
            addressTradeOpenID[
                addressesTradeOpen[addressesTradeOpen.length - 1]
            ] = addressTradeOpenID[a];
        }
        addressesTradeOpen.pop();
        delete addressTradeOpenID[a];
    }


    function hasOpenTrade(address a) public view returns(bool){

        return trades[a].openBlock != 0;
    }
    function canLiquidate(address a) public view returns(bool){

        require(hasOpenTrade(a), "This address has no open trade.");
        Trade memory t = trades[a];
        return canLiquidatePure(t.openPrice, getEthPrice(), t.buy, t.leverage);
    }
    function positionSizeGFARM(address a) public view returns(uint posGFARM){

        Trade memory t = trades[a];

        posGFARM = t.positionSizeETH.mul(PRECISION).div(getGFarmPriceEth());

        uint doubleInitialPos = t.initialPositionSizeGFARM.mul(2);
        if(posGFARM > doubleInitialPos){
            posGFARM = doubleInitialPos;
        }
    }
    function myTokenPNL() public view returns(int){

        if(!hasOpenTrade(msg.sender)){ return 0; }
        Trade memory t = trades[msg.sender];
        return int(positionSizeGFARM(msg.sender)) 
                * currentPercentProfit(t.openPrice, getEthPrice(), t.buy, t.leverage)
                / int(100*PRECISION);
    }
    function liquidateAmountGFARM(address a) public view returns(uint){

        return positionSizeGFARM(a).mul((100 - STOP_LOSS_P)).div(100);
    }
    function myNftsCount() public view returns(uint){

        return nft.balanceOf(msg.sender);
    }

    
    function openTrade(bool _buy, uint _positionSizeGFARM, uint16 _leverage) external{

        require(tradesPerBlock[block.number] < MAX_ACTIVITY_PER_BLOCK,
            "Max trading activity per block reached.");

        require(TRADING_PAUSED == false,
            "Trading is paused, cannot open any new trade.");

        require(tx.origin == msg.sender,
            "Contracts not allowed.");

        require(!hasOpenTrade(msg.sender),
            "You can only have 1 trade open at a time.");

        require(_positionSizeGFARM > 0,
            "Opening a trade with 0 tokens.");

        uint maxPosGFARM = getMaxPosGFARM(_leverage);

        require(_positionSizeGFARM <= maxPosGFARM,
            "Your position size exceeds the max authorized position size.");

        require(_positionSizeGFARM >= getMinPosGFARM(),
            "Your position size must be bigger than the minimum position size.");

        uint ethPrice = getEthPrice();

        if(_leverage != 10){
            uint nftCount = myNftsCount();
            require(nftCount > 0, "You don't own any GFarm NFT.");

            bool hasCorrespondingNFT = false;

            for(uint i = 0; i < nftCount; i++){
                uint nftID = nft.tokenOfOwnerByIndex(msg.sender, i);
                uint correspondingLeverage = nft.idToLeverage(nftID);
                if(correspondingLeverage == _leverage){
                    hasCorrespondingNFT = true;
                    break;
                }
            }
            
            require(hasCorrespondingNFT,
                "You don't own the corresponding NFT for this leverage.");            
        }
        
        token.transferFrom(msg.sender, address(this), _positionSizeGFARM);
        token.burn(address(this), _positionSizeGFARM);
        TOTAL_GFARM_BURNED = TOTAL_GFARM_BURNED.add(_positionSizeGFARM);

        uint GOV_fee = _positionSizeGFARM.mul(GOVERNANCE_P).div(100*PRECISION);
        uint DEV_fee = _positionSizeGFARM.mul(DEV_FUND_P).div(100*PRECISION);

        uint positionSizeGFARM_minusFees = _positionSizeGFARM.sub(GOV_fee).sub(DEV_fee);
        uint positionSizeETH_minusFees = positionSizeGFARM_minusFees.mul(getGFarmPriceEth())
                                        .div(PRECISION);

        token.mint(GOVERNANCE, GOV_fee);
        token.mint(DEV_FUND, DEV_fee);

        trades[msg.sender] = Trade(
            block.number,
            msg.sender,
            _buy,
            ethPrice,
            positionSizeGFARM_minusFees,
            positionSizeETH_minusFees,
            _leverage
        );

        addressesTradeOpen.push(msg.sender);
        addressTradeOpenID[msg.sender] = addressesTradeOpen.length.sub(1);
    
        tradesPerBlock[block.number] = tradesPerBlock[block.number].add(1);

        emit TradeOpened(
            msg.sender,
            ethPrice,
            _buy,
            positionSizeETH_minusFees,
            positionSizeGFARM_minusFees,
            _leverage
        );
    }

    function closeTrade() external{

        require(tradesPerBlock[block.number] < MAX_ACTIVITY_PER_BLOCK,
            "Max trading activity per block reached.");

        require(tx.origin == msg.sender,
            "Contracts not allowed.");

        require(hasOpenTrade(msg.sender), 
            "You have no open trade.");

        Trade memory t = trades[msg.sender];

        require(block.number >= t.openBlock.add(3),
            "Trade must be open for at least 3 blocks.");

        uint posGFARM = positionSizeGFARM(msg.sender);
        int pnlGFARM;
        int pnlETH;

        if(!canLiquidate(msg.sender)){
            pnlGFARM = myTokenPNL();
            uint tokensBack = posGFARM;

            if(pnlGFARM > 0){ 
                Gains storage userGains = gains[msg.sender];
                userGains.valueGFARM = userGains.valueGFARM
                                        .add(uint(pnlGFARM));
                userGains.lastTradeClosed = block.number;
            }else if(pnlGFARM < 0){
                tokensBack = tokensBack.sub(uint(pnlGFARM*(-1)));
            }

            token.mint(msg.sender, tokensBack);
            TOTAL_GFARM_MINTED = TOTAL_GFARM_MINTED.add(tokensBack);
        }else{
            pnlGFARM = int(posGFARM) * (-1);
        }

        pnlETH = pnlGFARM * int(getGFarmPriceEth()) / int(PRECISION);

        emit TradeClosed(
            msg.sender,
            getEthPrice(),
            t.buy,
            t.positionSizeETH,
            posGFARM,
            t.leverage,
            pnlGFARM,
            pnlETH
        );

        unregisterOpenTrade(msg.sender);
        tradesPerBlock[block.number] = tradesPerBlock[block.number].add(1);
    }

    function liquidate(address a) external{

        require(tx.origin == msg.sender,
            "Contracts not allowed.");

        require(tradesPerBlock[block.number] < MAX_ACTIVITY_PER_BLOCK,
            "Max trading activity per block reached.");

        require(canLiquidate(a),
            "No trade to liquidate for this address.");

        require(myNftsCount() > 0 || msg.sender == GOVERNANCE,
            "You don't own any GFarm NFT.");

        Trade memory t = trades[a];

        uint amountGFARM = liquidateAmountGFARM(a);
        uint amountETH = amountGFARM.mul(getGFarmPriceEth()).div(PRECISION);
        uint posGFARM = positionSizeGFARM(a);

        token.mint(msg.sender, amountGFARM);
        TOTAL_GFARM_MINTED = TOTAL_GFARM_MINTED.add(amountGFARM);

        unregisterOpenTrade(a);
        tradesPerBlock[block.number] = tradesPerBlock[block.number].add(1);

        emit TradeLiquidated(
            msg.sender,
            a,
            getEthPrice(),
            t.buy,
            t.positionSizeETH,
            posGFARM,
            t.leverage,
            amountGFARM,
            amountETH
        );
    }

    function claimGains() external{

        require(tx.origin == msg.sender,
            "Contracts not allowed.");

        require(TRADING_PAUSED == false,
            "Trading is paused, cannot open any new trade.");

        Gains storage userGains = gains[msg.sender];
        require(block.number.sub(userGains.lastTradeClosed) >= 3,
            "You must wait 3 block after you close a trade.");

        uint gainsGFARM = userGains.valueGFARM;
        uint gainsETH = gainsGFARM.mul(getGFarmPriceEth()).div(PRECISION);

        token.mint(msg.sender, gainsGFARM);
        TOTAL_GFARM_MINTED = TOTAL_GFARM_MINTED.add(gainsGFARM);

        emit GainsClaimed(
            msg.sender,
            gainsGFARM,
            gainsETH
        );

        userGains.valueGFARM = 0;
    }


    function myGains() external view returns(uint){

        return gains[msg.sender].valueGFARM;
    }
    
    function canClaimGains() external view returns(bool){

        return block.number.sub(gains[msg.sender].lastTradeClosed) 
                >= 3 && gains[msg.sender].valueGFARM > 0;
    }
    
    function myPercentPNL() external view returns(int){

        if(!hasOpenTrade(msg.sender)){ return 0; }

        Trade memory t = trades[msg.sender];
        return currentPercentProfit(t.openPrice, getEthPrice(), t.buy, t.leverage);
    }
    
    function myOpenPrice() external view returns(uint){

        return trades[msg.sender].openPrice;
    }
    
    function myPositionSizeETH() external view returns(uint){

        return trades[msg.sender].positionSizeETH;
    }
    
    function myPositionSizeGFARM() external view returns(uint){

        return positionSizeGFARM(msg.sender);
    }
    
    function myDirection() external view returns(string memory){

        if(trades[msg.sender].buy){ return 'Buy'; }
        return 'Sell';
    }
    
    function myLeverage() external view returns(uint){

        return trades[msg.sender].leverage;
    }
    
    function tradeOpenSinceThreeBlocks() external view returns(bool){

        Trade memory t = trades[msg.sender];
        if(!hasOpenTrade(msg.sender) || block.number < t.openBlock){ 
            return false; 
        }
        return block.number.sub(t.openBlock) >= 3;
    }
    
    function getAddressesTradeOpen() external view returns(address[] memory){

        return addressesTradeOpen;
    }
    
    function unlockedLeverages() external view returns(uint8[5] memory leverages){

        for(uint i = 0; i < myNftsCount(); i++){
            uint8 leverage = nft.idToLeverage(
                                nft.tokenOfOwnerByIndex(msg.sender, i)
                            );
            uint8 id = nft.leverageID(leverage);
            leverages[id] = leverage;
        }
    }
}