
pragma solidity ^0.4.25;

contract Ownable {

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Not current owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Non-zero address required");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Token {

    function approve(address spender, uint256 value) public returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool);


    function transfer(address to, uint256 value) public returns (bool);


    function balanceOf(address who) public view returns (uint256);

}

contract UniSwapV2LiteRouter {

    function WETH() external pure returns (address);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] path,
        address to,
        uint256 deadline
    ) external returns (uint256[] amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] amounts);


    function getAmountsOut(uint256 amountIn, address[] path)
        external
        view
        returns (uint256[] amounts);

}


contract BankrollNetworkMoon is Ownable {

    using SafeMath for uint256;


    modifier onlyBagholders {

        require(myTokens() > 0, "Insufficient tokens");
        _;
    }

    modifier onlyStronghands {

        require(myDividends() > 0, "Insufficient dividends");
        _;
    }


    event onLeaderBoard(
        address indexed customerAddress,
        uint256 invested,
        uint256 tokens,
        uint256 soldTokens,
        uint256 timestamp
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingeth,
        uint256 tokensMinted,
        uint256 timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethEarned,
        uint256 timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethReinvested,
        uint256 tokensMinted,
        uint256 timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethWithdrawn,
        uint256 timestamp
    );

    event onClaim(
        address indexed customerAddress,
        uint256 tokens,
        uint256 timestamp
    );

    event onTransfer(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint256 timestamp
    );

    event onUpdateIntervals(uint256 payout, uint256 fund);

    event onCollateraltoReward(
        uint256 collateralAmount,
        uint256 rewardAmount,
        uint256 timestamp
    );

    event onEthtoCollateral(
        uint256 ethAmount,
        uint256 tokenAmount,
        uint256 timestamp
    );

    event onRewardtoCollateral(
        uint256 ethAmount,
        uint256 tokenAmount,
        uint256 timestamp
    );

    event onBalance(uint256 balance, uint256 rewardBalance, uint256 timestamp);

    event onDonation(address indexed from, uint256 amount, uint256 timestamp);

    event onRouterUpdate(address oldAddress, address newAddress);

    event onFlushUpdate(uint256 oldFlushSize, uint256 newFlushSize);

    struct Stats {
        uint256 invested;
        uint256 reinvested;
        uint256 withdrawn;
        uint256 rewarded;
        uint256 contributed;
        uint256 transferredTokens;
        uint256 receivedTokens;
        uint256 xInvested;
        uint256 xReinvested;
        uint256 xRewarded;
        uint256 xContributed;
        uint256 xWithdrawn;
        uint256 xTransferredTokens;
        uint256 xReceivedTokens;
    }


    uint8 internal constant entryFee_ = 10;

    uint8 internal constant exitFee_ = 10;

    uint8 internal constant instantFee = 20;

    uint8 constant payoutRate_ = 2;

    uint256 internal constant magnitude = 2**64;


    mapping(address => uint256) private tokenBalanceLedger_;
    mapping(address => int256) private payoutsTo_;
    mapping(address => Stats) private stats;
    uint256 private tokenSupply_;
    uint256 private profitPerShare_;
    uint256 public totalDeposits;
    uint256 internal lastBalance_;

    uint256 public players;
    uint256 public totalTxs;
    uint256 public collateralBuffer_;
    uint256 public lastPayout;
    uint256 public lastFunding;
    uint256 public totalClaims;

    uint256 public balanceInterval = 6 hours;
    uint256 public payoutInterval = 2 seconds;
    uint256 public fundingInterval = 2 seconds;
    uint256 public flushSize = 0.00000000001 ether;

    address public swapAddress;
    address public rewardAddress;
    address public collateralAddress;

    Token private rewardToken;
    Token private collateralToken;
    UniSwapV2LiteRouter private swap;


    constructor(
        address _collateralAddress,
        address _rewardAddress,
        address _swapAddress
    ) public Ownable() {
        rewardAddress = _rewardAddress;
        rewardToken = Token(_rewardAddress);

        collateralAddress = _collateralAddress;
        collateralToken = Token(_collateralAddress);

        swapAddress = _swapAddress;
        swap = UniSwapV2LiteRouter(_swapAddress);

        lastPayout = now;
        lastFunding = now;
    }

    function buy() public payable returns (uint256) {

        return buyFor(msg.sender);
    }

    function buyFor(address _customerAddress) public payable returns (uint256) {

        require(msg.value > 0, "Non-zero amount required");

        uint256 _buy_amount = ethToCollateral(msg.value);

        totalDeposits += _buy_amount;
        uint256 amount = purchaseTokens(_customerAddress, _buy_amount);

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );

        distribute();

        return amount;
    }

    function() public payable {
        require(false, "This contract does not except ETH");
    }

    function reinvest() public onlyStronghands {

        uint256 _dividends = myDividends();

        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        uint256 _tokens = purchaseTokens(msg.sender, _dividends);

        emit onReinvestment(_customerAddress, _dividends, _tokens, now);

        stats[_customerAddress].reinvested = SafeMath.add(
            stats[_customerAddress].reinvested,
            _dividends
        );
        stats[_customerAddress].xReinvested += 1;

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );

        distribute();
    }

    function withdraw() public onlyStronghands {

        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends();

        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        collateralToken.transfer(_customerAddress, _dividends);

        stats[_customerAddress].withdrawn = SafeMath.add(
            stats[_customerAddress].withdrawn,
            _dividends
        );
        stats[_customerAddress].xWithdrawn += 1;
        totalTxs += 1;

        emit onWithdraw(_customerAddress, _dividends, now);

        distribute();
    }

    function sell(uint256 _amountOfTokens) public onlyBagholders {

        address _customerAddress = msg.sender;

        require(
            _amountOfTokens <= tokenBalanceLedger_[_customerAddress],
            "Amount of tokens is greater than balance"
        );

        uint256 _undividedDividends = SafeMath.mul(_amountOfTokens, exitFee_) /
            100;
        uint256 _taxedeth = SafeMath.sub(_amountOfTokens, _undividedDividends);

        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        int256 _updatedPayouts = (int256)(
            profitPerShare_ * _amountOfTokens + (_taxedeth * magnitude)
        );
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        allocateFees(_undividedDividends);

        emit onTokenSell(_customerAddress, _amountOfTokens, _taxedeth, now);

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );

        distribute();
    }

    function transfer(address _toAddress, uint256 _amountOfTokens)
        external
        onlyBagholders
        returns (bool)
    {

        address _customerAddress = msg.sender;

        require(
            _amountOfTokens <= tokenBalanceLedger_[_customerAddress],
            "Amount of tokens is greater than balance"
        );

        if (myDividends() > 0) {
            withdraw();
        }

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        tokenBalanceLedger_[_toAddress] = SafeMath.add(
            tokenBalanceLedger_[_toAddress],
            _amountOfTokens
        );

        payoutsTo_[_customerAddress] -= (int256)(
            profitPerShare_ * _amountOfTokens
        );
        payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _amountOfTokens);

        if (
            stats[_toAddress].invested == 0 &&
            stats[_toAddress].receivedTokens == 0
        ) {
            players += 1;
        }

        stats[_customerAddress].xTransferredTokens += 1;
        stats[_customerAddress].transferredTokens += _amountOfTokens;
        stats[_toAddress].receivedTokens += _amountOfTokens;
        stats[_toAddress].xReceivedTokens += 1;
        totalTxs += 1;

        emit onTransfer(_customerAddress, _toAddress, _amountOfTokens, now);

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );

        emit onLeaderBoard(
            _toAddress,
            stats[_toAddress].invested,
            tokenBalanceLedger_[_toAddress],
            stats[_toAddress].withdrawn,
            now
        );

        return true;
    }


    function totalTokenBalance() public view returns (uint256) {

        return collateralToken.balanceOf(address(this));
    }

    function totalRewardTokenBalance() public view returns (uint256) {

        return rewardToken.balanceOf(address(this));
    }

    function totalSupply() public view returns (uint256) {

        return tokenSupply_;
    }

    function myTokens() public view returns (uint256) {

        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends() public view returns (uint256) {

        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress);
    }

    function balanceOf(address _customerAddress) public view returns (uint256) {

        return tokenBalanceLedger_[_customerAddress];
    }

    function tokenBalance(address _customerAddress)
        public
        view
        returns (uint256)
    {

        return _customerAddress.balance;
    }

    function dividendsOf(address _customerAddress)
        public
        view
        returns (uint256)
    {

        return
            (uint256)(
                (int256)(
                    profitPerShare_ * tokenBalanceLedger_[_customerAddress]
                ) - payoutsTo_[_customerAddress]
            ) / magnitude;
    }

    function sellPrice() public pure returns (uint256) {

        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);

        return _taxedeth;
    }

    function buyPrice() public pure returns (uint256) {

        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, entryFee_), 100);
        uint256 _taxedeth = SafeMath.add(_eth, _dividends);

        return _taxedeth;
    }

    function calculateTokensReceived(uint256 _ethToSpend)
        public
        view
        returns (uint256)
    {

        address[] memory path = new address[](2);
        path[0] = swap.WETH();
        path[1] = collateralAddress;

        uint256[] memory amounts = swap.getAmountsOut(_ethToSpend, path);

        uint256 _dividends = SafeMath.div(
            SafeMath.mul(amounts[1], entryFee_),
            100
        );
        uint256 _taxedeth = SafeMath.sub(amounts[1], _dividends);
        uint256 _amountOfTokens = _taxedeth;

        return _amountOfTokens;
    }

    function calculateethReceived(uint256 _tokensToSell)
        public
        view
        returns (uint256)
    {

        require(
            _tokensToSell <= tokenSupply_,
            "Tokens to sell greater than supply"
        );
        uint256 _eth = _tokensToSell;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);
        return _taxedeth;
    }

    function statsOf(address _customerAddress)
        public
        view
        returns (uint256[14] memory)
    {

        Stats memory s = stats[_customerAddress];
        uint256[14] memory statArray = [
            s.invested,
            s.withdrawn,
            s.rewarded,
            s.contributed,
            s.transferredTokens,
            s.receivedTokens,
            s.xInvested,
            s.xRewarded,
            s.xContributed,
            s.xWithdrawn,
            s.xTransferredTokens,
            s.xReceivedTokens,
            s.reinvested,
            s.xReinvested
        ];
        return statArray;
    }

    function dailyEstimate(address _customerAddress)
        public
        view
        returns (uint256)
    {

        uint256 share = totalRewardTokenBalance().mul(payoutRate_).div(100);

        
        uint256 amount = (tokenSupply_ > 0)
                ? share.mul(tokenBalanceLedger_[_customerAddress]).div(
                    tokenSupply_
                )
                : 0;

        if (amount > 0){
            address[] memory path = new address[](3);
            path[0] = rewardAddress;
            path[1] = swap.WETH();
            path[2] = collateralAddress;

            
            uint256[] memory amounts = swap.getAmountsOut(amount, path);
            return amounts[2];
        }
        
        return  0;      
    }


    function allocateFees(uint256 fee) private {

        uint256 _share = fee.div(100);
        uint256 _instant = _share.mul(instantFee);
        uint256 _collateral = fee.safeSub(_instant);

        profitPerShare_ = SafeMath.add(
            profitPerShare_,
            (_instant * magnitude) / tokenSupply_
        );

        collateralBuffer_ += _collateral;
    }

    function distribute() private {

        if (now.safeSub(lastBalance_) > balanceInterval) {
            emit onBalance(totalTokenBalance(), totalRewardTokenBalance(), now);
            lastBalance_ = now;
        }

        if (now.safeSub(lastPayout) > payoutInterval && totalRewardTokenBalance() > 0) {
            uint256 share = totalRewardTokenBalance()
                .mul(payoutRate_)
                .div(100)
                .div(24 hours);
            uint256 profit = share * now.safeSub(lastPayout);

            address[] memory path = new address[](2);
            path[0] = rewardAddress;
            path[1] = swap.WETH();

            if (profit > 0){
                uint256[] memory amounts = swap.getAmountsOut(profit, path);

                if (amounts[1] > flushSize) {
                    profit = rewardToCollateral(profit);

                    totalClaims += profit;

                    profitPerShare_ = SafeMath.add(
                        profitPerShare_,
                        (profit * magnitude) / tokenSupply_
                    );

                    lastPayout = now;
                } else {
                    fundRewardPool();
                }
            } else {
                fundRewardPool();
            }
        } else {
            fundRewardPool();
        }
    }

    function fundRewardPool() private {

        if (SafeMath.safeSub(now, lastFunding) >= fundingInterval) {
            address[] memory path = new address[](2);
            path[0] = collateralAddress;
            path[1] = swap.WETH();

            if (collateralBuffer_ > 0){
                uint256[] memory amounts = swap.getAmountsOut(
                    collateralBuffer_,
                    path
                );

                if (amounts[1] >= flushSize) {
                    uint256 amount = collateralBuffer_;

                    collateralBuffer_ = 0;

                    collateralToReward(amount);

                    lastFunding = now;
                }
            }
        }
    }

    function collateralToReward(uint256 amount) private returns (uint256) {

        address[] memory path = new address[](3);
        path[0] = collateralAddress;
        path[1] = swap.WETH();
        path[2] = rewardAddress;

        require(
            collateralToken.approve(swapAddress, amount),
            "Amount approved not available"
        );

        uint256[] memory amounts = swap.swapExactTokensForTokens(
            amount,
            1,
            path,
            address(this),
            now + 24 hours
        );

        emit onCollateraltoReward(amount, amounts[2], now);

        return amounts[2];
    }

    function rewardToCollateral(uint256 amount) private returns (uint256) {

        address[] memory path = new address[](3);
        path[0] = rewardAddress;
        path[1] = swap.WETH();
        path[2] = collateralAddress;

        require(
            rewardToken.approve(swapAddress, amount),
            "Amount approved not available"
        );

        uint256[] memory amounts = swap.swapExactTokensForTokens(
            amount,
            1,
            path,
            address(this),
            now + 24 hours
        );

        emit onRewardtoCollateral(amount, amounts[2], now);

        return amounts[2];
    }

    function ethToCollateral(uint256 amount) private returns (uint256) {

        address[] memory path = new address[](2);
        path[0] = swap.WETH();
        path[1] = collateralAddress;

        uint256[] memory amounts = swap.swapExactETHForTokens.value(amount)(
            1,
            path,
            address(this),
            now + 24 hours
        );

        emit onEthtoCollateral(amount, amounts[1], now);

        return amounts[1];
    }

    function purchaseTokens(address _customerAddress, uint256 _incomingtokens)
        internal
        returns (uint256)
    {

        if (
            stats[_customerAddress].invested == 0 &&
            stats[_customerAddress].receivedTokens == 0
        ) {
            players += 1;
        }

        totalTxs += 1;

        uint256 _undividedDividends = SafeMath.mul(_incomingtokens, entryFee_) /
            100;
        uint256 _amountOfTokens = SafeMath.sub(
            _incomingtokens,
            _undividedDividends
        );

        emit onTokenPurchase(
            _customerAddress,
            _incomingtokens,
            _amountOfTokens,
            now
        );

        require(
            _amountOfTokens > 0 &&
                SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_,
            "Tokens need to be positive"
        );

        if (tokenSupply_ > 0) {
            tokenSupply_ += _amountOfTokens;
        } else {
            tokenSupply_ = _amountOfTokens;
        }

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        int256 _updatedPayouts = (int256)(profitPerShare_ * _amountOfTokens);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        allocateFees(_undividedDividends);

        stats[_customerAddress].invested += _incomingtokens;
        stats[_customerAddress].xInvested += 1;

        return _amountOfTokens;
    }


    function updateSwapRouter(address _swapAddress) public onlyOwner() {

        emit onRouterUpdate(swapAddress, _swapAddress);
        swapAddress = _swapAddress;
        swap = UniSwapV2LiteRouter(_swapAddress);
    }

    function updateFlushSize(uint256 _flushSize) public onlyOwner() {

        require(
            _flushSize >= 0.01 ether && _flushSize <= 5 ether,
            "Flush size is out of range"
        );

        emit onFlushUpdate(flushSize, _flushSize);
        flushSize = _flushSize;
    }

    function updateIntervals(uint256 _payout, uint256 _fund)
        public
        onlyOwner()
    {

        require(
            _payout >= 2 seconds && _payout <= 24 hours,
            "Interval out of range"
        );
        require(
            _fund >= 2 seconds && _fund <= 24 hours,
            "Interval out of range"
        );

        payoutInterval = _payout;
        fundingInterval = _fund;

        emit onUpdateIntervals(_payout, _fund);
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}