pragma solidity ^0.4.24;


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

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}
pragma solidity ^0.4.24;

interface ERC20 {

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

}

contract EscrowFund {

    using SafeMath for uint256;

    uint256 USDTPercentage = 90;

    ERC20 public BCNTToken;
    ERC20 public StableToken;

    address public bincentiveHot; // i.e., Platform Owner
    address public bincentiveCold;
    address[] public investors; // implicitly first investor is the lead investor
    address public accountManager;
    address public fundManager; // i.e., Exchange Deposit and Withdraw Manager
    address[] public traders;

    uint256 public numMidwayQuitInvestors;
    uint256 public numRefundedInvestors; // i.e., number of investors that already received refund
    uint256 public numAUMDistributedInvestors; // i.e., number of investors that already received AUM

    uint256 public fundStatus;

    uint256 public currentInvestedAmount;
    uint256 public investedUSDTAmount;
    uint256 public investedBCNTAmount;
    mapping(address => uint256) public investedAmount;
    mapping(address => uint256) public depositedUSDTAmount;
    mapping(address => uint256) public depositedBCNTAmount;
    uint256 public BCNTLockAmount;
    uint256 public returnedStableTokenAmounts;
    uint256 public returnedBCNTAmounts;
    mapping(address => uint256) public traderReceiveUSDTAmounts;
    mapping(address => uint256) public traderReceiveBCNTAmounts;

    uint256 public minInvestAmount;
    uint256 public investPaymentDueTime;
    uint256 public softCap;
    uint256 public hardCap;

    event Deposit(address indexed investor, uint256 amount);
    event StartFund(uint256 num_investors, uint256 totalInvestedAmount, uint256 BCNTLockAmount);
    event AbortFund(uint256 num_investors, uint256 totalInvestedAmount);
    event MidwayQuit(address indexed investor, uint256 investAmount, uint256 BCNTWithdrawAmount);
    event DesignateFundManager(address indexed fundManager);
    event Allocate(address indexed to, uint256 amountStableTokenForInvestment, uint256 amountBCNTForInvestment);
    event ReturnAUM(uint256 amountStableToken, uint256 amountBCNT);
    event DistributeAUM(address indexed to, uint256 amountStableToken, uint256 amountBCNT);


    modifier initialized() {

        require(fundStatus == 1);
        _;
    }

    modifier fundStarted() {

        require(fundStatus == 3);
        _;
    }

    modifier running() {

        require(fundStatus == 4);
        _;
    }

    modifier stopped() {

        require(fundStatus == 5);
        _;
    }

    modifier afterStartedBeforeStopped() {

        require((fundStatus >= 3) && (fundStatus < 5));
        _;
    }

    modifier closedOrAborted() {

        require((fundStatus == 6) || (fundStatus == 2));
        _;
    }

    modifier isBincentive() {

        require(
            (msg.sender == bincentiveHot) || (msg.sender == bincentiveCold)
        );
        _;
    }

    modifier isBincentiveCold() {

        require(msg.sender == bincentiveCold);
        _;
    }

    modifier isInvestor() {

        require(msg.sender != bincentiveHot);
        require(msg.sender != bincentiveCold);
        require(investedAmount[msg.sender] > 0);
        _;
    }

    modifier isAccountManager() {

        require(msg.sender == accountManager);
        _;
    }

    modifier isFundManager() {

        require(msg.sender == fundManager);
        _;
    }



    function deposit(address investor, uint256 depositUSDTAmount, uint256 depositBCNTAmount) initialized public {

        require(now < investPaymentDueTime);
        require(currentInvestedAmount < hardCap);
        require((investor != bincentiveHot) && (investor != bincentiveCold));

        uint256 amount;
        if(depositBCNTAmount > 0) {
            require((msg.sender == bincentiveHot) || (msg.sender == bincentiveCold));

            amount = depositUSDTAmount.mul(100).div(USDTPercentage);
        }
        else {
            amount = depositUSDTAmount;
        }
        require(amount >= minInvestAmount);
        require(currentInvestedAmount.add(amount) <= hardCap);

        if((msg.sender == bincentiveHot) || (msg.sender == bincentiveCold)) {
            require(StableToken.transferFrom(bincentiveCold, address(this), depositUSDTAmount));
            if(depositBCNTAmount > 0) {
                require(BCNTToken.transferFrom(bincentiveCold, address(this), depositBCNTAmount));
                depositedBCNTAmount[investor] = depositedBCNTAmount[investor].add(depositBCNTAmount);
                investedBCNTAmount = investedBCNTAmount.add(depositBCNTAmount);
            }
        }
        else{
            require(StableToken.transferFrom(msg.sender, address(this), depositUSDTAmount));
        }
        depositedUSDTAmount[investor] = depositedUSDTAmount[investor].add(depositUSDTAmount);
        investedUSDTAmount = investedUSDTAmount.add(depositUSDTAmount);

        currentInvestedAmount = currentInvestedAmount.add(amount);
        if(investedAmount[investor] == 0) {
            investors.push(investor);
        }
        investedAmount[investor] = investedAmount[investor].add(amount);

        emit Deposit(investor, amount);
    }

    function start(uint256 _BCNTLockAmount) initialized isBincentive public {

        require(currentInvestedAmount >= softCap);

        require(BCNTToken.transferFrom(bincentiveCold, address(this), _BCNTLockAmount));
        BCNTLockAmount = _BCNTLockAmount;

        fundStatus = 3;
        emit StartFund(investors.length, currentInvestedAmount, BCNTLockAmount);
    }

    function notEnoughFund(uint256 numInvestorsToRefund) initialized isBincentive public {

        require(now >= investPaymentDueTime);
        require(currentInvestedAmount < softCap);
        require(numRefundedInvestors.add(numInvestorsToRefund) <= investors.length, "Refund to more than total number of investors");

        address investor;
        for(uint i = numRefundedInvestors; i < (numRefundedInvestors.add(numInvestorsToRefund)); i++) {
            investor = investors[i];
            if(investedAmount[investor] == 0) continue;

            require(StableToken.transfer(investor, depositedUSDTAmount[investor]));
            if(depositedBCNTAmount[investor] > 0) {
                require(BCNTToken.transfer(investor, depositedBCNTAmount[investor]));
            }
        }

        numRefundedInvestors = numRefundedInvestors.add(numInvestorsToRefund);
        if(numRefundedInvestors >= investors.length) {
            fundStatus = 2;

            emit AbortFund(investors.length, currentInvestedAmount);
        }
    }

    function midwayQuit() afterStartedBeforeStopped isInvestor public {

        uint256 investor_amount = investedAmount[msg.sender];
        investedAmount[msg.sender] = 0;

        uint256 totalAmount = currentInvestedAmount;
        currentInvestedAmount = currentInvestedAmount.sub(investor_amount);
        investedAmount[bincentiveCold] = investedAmount[bincentiveCold].add(investor_amount);

        uint256 BCNTWithdrawAmount = BCNTLockAmount.mul(investor_amount).div(totalAmount);
        BCNTLockAmount = BCNTLockAmount.sub(BCNTWithdrawAmount);
        require(BCNTToken.transfer(msg.sender, BCNTWithdrawAmount));

        numMidwayQuitInvestors = numMidwayQuitInvestors.add(1);
        if(numMidwayQuitInvestors == investors.length) {
            fundStatus = 6;
        }

        emit MidwayQuit(msg.sender, investor_amount, BCNTWithdrawAmount);
    }

    function designateFundManager(address _fundManager) fundStarted isAccountManager public {

        require(fundManager == address(0), "Fund manager is already declared.");
        fundManager = _fundManager;

        emit DesignateFundManager(_fundManager);
    }

    function allocateFund(address[] _traders, uint256[] receiveUSDTAmounts, uint256[] receiveBCNTAmounts) fundStarted isFundManager public {

        require(traders.length == 0, "Already allocated");
        require(_traders.length > 0, "Must has at least one recipient");
        require(_traders.length == receiveUSDTAmounts.length, "Input not of the same length");
        require(receiveUSDTAmounts.length == receiveBCNTAmounts.length, "Input not of the same length");

        uint256 totalAllocatedUSDTAmount;
        uint256 totalAllocatedBCNTAmount;
        address trader;
        for(uint i = 0; i < _traders.length; i++) {
            trader = _traders[i];
            traders.push(trader);
            traderReceiveUSDTAmounts[trader] = receiveUSDTAmounts[i];
            traderReceiveBCNTAmounts[trader] = receiveBCNTAmounts[i];

            emit Allocate(trader, traderReceiveUSDTAmounts[trader], traderReceiveBCNTAmounts[trader]);

            totalAllocatedUSDTAmount = totalAllocatedUSDTAmount.add(receiveUSDTAmounts[i]);
            totalAllocatedBCNTAmount = totalAllocatedBCNTAmount.add(receiveBCNTAmounts[i]);
        }

        require(totalAllocatedUSDTAmount == investedUSDTAmount, "Must allocate the full invested amount");
        require(totalAllocatedBCNTAmount == investedBCNTAmount, "Must allocate the full invested amount");
    }

    function dispenseFund() fundStarted isBincentiveCold public {

        require(traders.length > 0, "Must has at least one recipient");

        address trader;
        for(uint i = 0; i < traders.length; i++) {
            trader = traders[i];
            require(StableToken.transfer(trader, traderReceiveUSDTAmounts[trader]));
            if(traderReceiveBCNTAmounts[trader] > 0) {
                require(BCNTToken.transfer(trader, traderReceiveBCNTAmounts[trader]));
            }
        }

        fundStatus = 4;
    }

    function returnAUM(uint256 stableTokenAmount, uint256 BCNTAmount) running isBincentiveCold public {


        returnedStableTokenAmounts = stableTokenAmount;
        returnedBCNTAmounts = BCNTAmount;

        require(StableToken.transferFrom(bincentiveCold, address(this), stableTokenAmount));

        require(BCNTToken.transferFrom(bincentiveCold, address(this), BCNTAmount));

        emit ReturnAUM(stableTokenAmount, BCNTAmount);

        fundStatus = 5;
    }

    function distributeAUM(uint256 numInvestorsToDistribute) stopped isBincentive public {

        require(numAUMDistributedInvestors.add(numInvestorsToDistribute) <= investors.length, "Distributing to more than total number of investors");

        uint256 totalStableTokenReturned = returnedStableTokenAmounts;
        uint256 totalBCNTReturned = returnedBCNTAmounts;
        uint256 totalAmount = currentInvestedAmount.add(investedAmount[bincentiveCold]);

        uint256 stableTokenDistributeAmount;
        uint256 BCNTDistributeAmount;
        address investor;
        uint256 investor_amount;
        for(uint i = numAUMDistributedInvestors; i < (numAUMDistributedInvestors.add(numInvestorsToDistribute)); i++) {
            investor = investors[i];
            if(investedAmount[investor] == 0) continue;
            investor_amount = investedAmount[investor];
            investedAmount[investor] = 0;

            stableTokenDistributeAmount = totalStableTokenReturned.mul(investor_amount).div(totalAmount);
            require(StableToken.transfer(investor, stableTokenDistributeAmount));

            BCNTDistributeAmount = totalBCNTReturned.mul(investor_amount).div(totalAmount);
            require(BCNTToken.transfer(investor, BCNTDistributeAmount));

            emit DistributeAUM(investor, stableTokenDistributeAmount, BCNTDistributeAmount);
        }

        numAUMDistributedInvestors = numAUMDistributedInvestors.add(numInvestorsToDistribute);
        if(numAUMDistributedInvestors >= investors.length) {
            returnedStableTokenAmounts = 0;
            returnedBCNTAmounts = 0;
            currentInvestedAmount = 0;
            if(investedAmount[bincentiveCold] > 0) {
                investor_amount = investedAmount[bincentiveCold];
                investedAmount[bincentiveCold] = 0;
                stableTokenDistributeAmount = totalStableTokenReturned.mul(investor_amount).div(totalAmount);
                require(StableToken.transfer(bincentiveCold, stableTokenDistributeAmount));

                BCNTDistributeAmount = totalBCNTReturned.mul(investor_amount).div(totalAmount);
                require(BCNTToken.transfer(bincentiveCold, BCNTDistributeAmount));

                emit DistributeAUM(bincentiveCold, stableTokenDistributeAmount, BCNTDistributeAmount);
            }

            uint256 _BCNTLockAmount = BCNTLockAmount;
            BCNTLockAmount = 0;
            require(BCNTToken.transfer(bincentiveCold, _BCNTLockAmount));

            fundStatus = 6;
        }
    }

    function claimWronglyTransferredFund() closedOrAborted isBincentive public {

        uint256 leftOverAmount;
        leftOverAmount = StableToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            require(StableToken.transfer(bincentiveCold, leftOverAmount));
        }
        leftOverAmount = BCNTToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            require(BCNTToken.transfer(bincentiveCold, leftOverAmount));
        }
    }


    constructor(
        address _BCNTToken,
        address _StableToken,
        address _bincentiveHot,
        address _bincentiveCold,
        address _accountManager,
        uint256 _minInvestAmount,
        uint256 _investPaymentPeriod,
        uint256 _softCap,
        uint256 _hardCap) public {

        bincentiveHot = _bincentiveHot;
        bincentiveCold = _bincentiveCold;
        BCNTToken = ERC20(_BCNTToken);
        StableToken = ERC20(_StableToken);

        accountManager = _accountManager;

        minInvestAmount = _minInvestAmount;
        investPaymentDueTime = now.add(_investPaymentPeriod);
        softCap = _softCap;
        hardCap = _hardCap;

        fundStatus = 1;
    }
}