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

contract RockFlameOffchainUSDT {

    using SafeMath for uint256;

    ERC20 public BCNTToken;

    address public bincentiveHot; // i.e., Platform Owner
    address public bincentiveCold;
    address[] public rockInvestors;

    uint256 public numMidwayQuitInvestors;
    uint256 public numAUMDistributedInvestors; // i.e., number of investors that already received AUM

    uint256 public fundStatus;

    uint256 public totalRockInvestedAmount;
    mapping(address => uint256) public rockInvestedAmount;

    uint256 public BCNTLockAmount;

    uint256 public returnedUSDTAmounts;

    event Deposit(address indexed investor, uint256 amount);
    event StartFund(uint256 num_investors, uint256 totalInvestedAmount, uint256 BCNTLockAmount);
    event AbortFund(uint256 num_investors, uint256 totalInvestedAmount);
    event MidwayQuit(address indexed investor, uint256 investAmount, uint256 BCNTWithdrawAmount);
    event ReturnAUM(uint256 amountUSDT);
    event DistributeAUM(address indexed to, uint256 amountUSDT);


    modifier initialized() {

        require(fundStatus == 1);
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
        require(rockInvestedAmount[msg.sender] > 0);
        _;
    }



    function deposit(address[] investors, uint256[] depositUSDTAmounts) initialized isBincentive public {

        require(investors.length > 0, "Must has at least one investor");
        require(investors.length == depositUSDTAmounts.length, "Input not of the same length");

        address investor;
        uint256 depositUSDTAmount;
        for(uint i = 0; i < investors.length; i++) {
            investor = investors[i];
            depositUSDTAmount = depositUSDTAmounts[i];

            require((investor != bincentiveHot) && (investor != bincentiveCold));

            totalRockInvestedAmount = totalRockInvestedAmount.add(depositUSDTAmount);
            if(rockInvestedAmount[investor] == 0) {
                rockInvestors.push(investor);
            }
            rockInvestedAmount[investor] = rockInvestedAmount[investor].add(depositUSDTAmount);

            emit Deposit(investor, depositUSDTAmount);
        }
    }

    function start(uint256 _BCNTLockAmount) initialized isBincentive public {

        require(BCNTToken.transferFrom(bincentiveCold, address(this), _BCNTLockAmount));
        BCNTLockAmount = _BCNTLockAmount;

        fundStatus = 4;
        emit StartFund(rockInvestors.length, totalRockInvestedAmount, BCNTLockAmount);
    }

    function notEnoughFund() initialized isBincentive public {

        fundStatus = 2;
        emit AbortFund(rockInvestors.length, totalRockInvestedAmount);
    }

    function midwayQuitByAdmin(address _investor) running isBincentive public {

        require(_investor != bincentiveHot && _investor != bincentiveCold);
        uint256 investor_amount = rockInvestedAmount[_investor];
        rockInvestedAmount[_investor] = 0;

        uint256 totalAmount = totalRockInvestedAmount;
        totalRockInvestedAmount = totalRockInvestedAmount.sub(investor_amount);
        rockInvestedAmount[bincentiveCold] = rockInvestedAmount[bincentiveCold].add(investor_amount);

        uint256 BCNTWithdrawAmount = BCNTLockAmount.mul(investor_amount).div(totalAmount);
        BCNTLockAmount = BCNTLockAmount.sub(BCNTWithdrawAmount);
        require(BCNTToken.transfer(_investor, BCNTWithdrawAmount));

        numMidwayQuitInvestors = numMidwayQuitInvestors.add(1);
        if(numMidwayQuitInvestors == rockInvestors.length) {
            fundStatus = 6;
        }

        emit MidwayQuit(_investor, investor_amount, BCNTWithdrawAmount);
    }


    function midwayQuit() running isInvestor public {

        uint256 investor_amount = rockInvestedAmount[msg.sender];
        rockInvestedAmount[msg.sender] = 0;

        uint256 totalAmount = totalRockInvestedAmount;
        totalRockInvestedAmount = totalRockInvestedAmount.sub(investor_amount);
        rockInvestedAmount[bincentiveCold] = rockInvestedAmount[bincentiveCold].add(investor_amount);

        uint256 BCNTWithdrawAmount = BCNTLockAmount.mul(investor_amount).div(totalAmount);
        BCNTLockAmount = BCNTLockAmount.sub(BCNTWithdrawAmount);
        require(BCNTToken.transfer(msg.sender, BCNTWithdrawAmount));

        numMidwayQuitInvestors = numMidwayQuitInvestors.add(1);
        if(numMidwayQuitInvestors == rockInvestors.length) {
            fundStatus = 6;
        }

        emit MidwayQuit(msg.sender, investor_amount, BCNTWithdrawAmount);
    }

    function returnAUM(uint256 USDTAmount) running isBincentiveCold public {


        returnedUSDTAmounts = USDTAmount;

        emit ReturnAUM(USDTAmount);

        fundStatus = 5;
    }

    function distributeAUM(uint256 numInvestorsToDistribute) stopped isBincentive public {

        require(numAUMDistributedInvestors.add(numInvestorsToDistribute) <= rockInvestors.length, "Distributing to more than total number of rockInvestors");

        uint256 totalUSDTReturned = returnedUSDTAmounts;
        uint256 totalAmount = totalRockInvestedAmount.add(rockInvestedAmount[bincentiveCold]);

        uint256 USDTDistributeAmount;
        address investor;
        uint256 investor_amount;
        for(uint i = numAUMDistributedInvestors; i < (numAUMDistributedInvestors.add(numInvestorsToDistribute)); i++) {
            investor = rockInvestors[i];
            if(rockInvestedAmount[investor] == 0) continue;
            investor_amount = rockInvestedAmount[investor];
            rockInvestedAmount[investor] = 0;

            USDTDistributeAmount = totalUSDTReturned.mul(investor_amount).div(totalAmount);

            emit DistributeAUM(investor, USDTDistributeAmount);
        }

        numAUMDistributedInvestors = numAUMDistributedInvestors.add(numInvestorsToDistribute);
        if(numAUMDistributedInvestors >= rockInvestors.length) {
            returnedUSDTAmounts = 0;
            totalRockInvestedAmount = 0;
            if(rockInvestedAmount[bincentiveCold] > 0) {
                investor_amount = rockInvestedAmount[bincentiveCold];
                rockInvestedAmount[bincentiveCold] = 0;

                USDTDistributeAmount = totalUSDTReturned.mul(investor_amount).div(totalAmount);

                emit DistributeAUM(bincentiveCold, USDTDistributeAmount);
            }

            uint256 _BCNTLockAmount = BCNTLockAmount;
            BCNTLockAmount = 0;
            require(BCNTToken.transfer(bincentiveCold, _BCNTLockAmount));

            fundStatus = 6;
        }
    }

    constructor(
        address _BCNTToken,
        address _bincentiveHot,
        address _bincentiveCold) public {

        BCNTToken = ERC20(_BCNTToken);
        bincentiveHot = _bincentiveHot;
        bincentiveCold = _bincentiveCold;

        fundStatus = 1;
    }
}
