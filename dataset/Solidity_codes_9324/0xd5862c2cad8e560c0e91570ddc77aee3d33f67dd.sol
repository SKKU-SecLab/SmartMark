
pragma solidity ^0.4.24;

interface ITetherERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint _value) public;

    function transferFrom(address _from, address _to, uint _value) public;

    function approve(address _spender, uint _value) public;

    function allowance(address _owner, address _spender) public view returns (uint remaining);

    function decimals() public view returns(uint8 digits);

    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances; // Storage slot 0

  uint256 totalSupply_; // Storage slot 1

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) internal allowed; // Storage slot 2

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {

        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {

        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract StandardTokenMintableBurnable is StandardToken {

  using SafeMath for uint256;

  function _mint(address account, uint256 amount) internal {

    require(account != address(0), "ERC20: mint to the zero address");
    totalSupply_ = totalSupply_.add(amount);
    balances[account] = balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) public {

    _burn(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal {

    require(account != address(0), "ERC20: burn from the zero address");
    totalSupply_ = totalSupply_.sub(amount);
    balances[account] = balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }
}

contract WhiteListToken is StandardTokenMintableBurnable{

  address public whiteListAdmin;
  bool public isTransferRestricted;
  bool public isReceiveRestricted;
  mapping(address => bool) public transferWhiteList;
  mapping(address => bool) public receiveWhiteList;


  constructor(address _admin) public {
    whiteListAdmin = _admin;
    isReceiveRestricted = true;
  }

  modifier isWhiteListAdmin() {

      require(msg.sender == whiteListAdmin);
      _;
  }

  function transfer(address _to, uint256 _value) public returns (bool){

    if (isTransferRestricted) {
      require(transferWhiteList[msg.sender], "only whitelist senders can transfer tokens");
    }
    if (isReceiveRestricted) {
      require(receiveWhiteList[_to], "only whiteList receivers can receive tokens");
    }
    return super.transfer(_to, _value);
  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){

    if (isTransferRestricted) {
      require(transferWhiteList[_from], "only whiteList senders can transfer tokens");
    }
    if (isReceiveRestricted) {
      require(receiveWhiteList[_to], "only whiteList receivers can receive tokens");
    }
    return super.transferFrom(_from, _to, _value);
  }

  function enableTransfer() isWhiteListAdmin public {

    require(isTransferRestricted);
    isTransferRestricted = false;
  }

  function restrictTransfer() isWhiteListAdmin public {

    require(isTransferRestricted == false);
    isTransferRestricted = true;
  }

  function enableReceive() isWhiteListAdmin public {

    require(isReceiveRestricted);
    isReceiveRestricted = false;
  }

  function restrictReceive() isWhiteListAdmin public {

    require(isReceiveRestricted == false);
    isReceiveRestricted = true;
  }


  function removeTransferWhiteListAddress(address _whiteListAddress) public isWhiteListAdmin returns(bool) {

    require(transferWhiteList[_whiteListAddress]);
    transferWhiteList[_whiteListAddress] = false;
    return true;
  }

  function addTransferWhiteListAddress(address _whiteListAddress) public isWhiteListAdmin returns(bool) {

    require(transferWhiteList[_whiteListAddress] == false);
    transferWhiteList[_whiteListAddress] = true;
    return true;
  }

  function removeReceiveWhiteListAddress(address _whiteListAddress) public isWhiteListAdmin returns(bool) {

    require(receiveWhiteList[_whiteListAddress]);
    receiveWhiteList[_whiteListAddress] = false;
    return true;
  }

  function addReceiveWhiteListAddress(address _whiteListAddress) public isWhiteListAdmin returns(bool) {

    require(receiveWhiteList[_whiteListAddress] == false);
    receiveWhiteList[_whiteListAddress] = true;
    return true;
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

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract SimpleOracleAccruedRatioUSD {

    using SafeMath for uint256;
    address public admin;
    address public superAdmin;
    uint256 public accruedRatioUSD;
    uint256 public lastUpdateTime;
    uint256 public MAXIMUM_CHANGE_PCT = 3;

    constructor(uint256 _accruedRatioUSD, address _admin, address _superAdmin) public {
        admin = _admin;
        superAdmin = _superAdmin;
        accruedRatioUSD = _accruedRatioUSD;
    }

    modifier onlyAdmin {

        require(msg.sender == admin || msg.sender == superAdmin);
        _;
    }

    modifier onlySuperAdmin {

        require(msg.sender == superAdmin);
        _;
    }

    function isValidRatio(uint256 _accruedRatioUSD) view internal {

      require(_accruedRatioUSD >= accruedRatioUSD, "ratio should be monotonically increased");
      uint256 maximumChange = accruedRatioUSD.mul(MAXIMUM_CHANGE_PCT).div(100);
      require(_accruedRatioUSD.sub(accruedRatioUSD) < maximumChange, "exceeds maximum chagne");
    }

    function checkTimeStamp() view internal {

      require(block.timestamp.sub(lastUpdateTime) > 82800, "oracle are not allowed to update two times within 23 hours");
    }

    function set(uint256 _accruedRatioUSD) onlyAdmin public{

        if(msg.sender != superAdmin) {
          isValidRatio(_accruedRatioUSD);
          checkTimeStamp();
        }
        lastUpdateTime = block.timestamp;
        accruedRatioUSD = _accruedRatioUSD;
    }

    function query() external view returns(uint256)  {

        return accruedRatioUSD;
    }
}

interface CERC20 {

    function mint(uint mintAmount) returns (uint);

    function redeem(uint redeemTokens) returns (uint);

    function supplyRatePerBlock() returns (uint);

    function exchangeRateCurrent() returns (uint);

    function balanceOf(address _owner) public view returns (uint balance);

    function balanceOfUnderlying(address account) returns (uint);

}

interface CEther {

    function mint() payable;

    function redeem(uint redeemTokens) returns (uint);

    function supplyRatePerBlock() returns (uint);

    function balanceOf(address _owner) public view returns (uint balance);

    function balanceOfUnderlying(address account) returns (uint);

}

contract CoolBitETFUSDTAndCompound is WhiteListToken{

    using SafeMath for uint256;

    uint256 public baseRatio;
    string public name = "X-Saving Certificate";
    string public constant symbol = "XSCert";
    uint8 public decimals;

    ITetherERC20 public StableToken;
    SimpleOracleAccruedRatioUSD public oracle;
    CERC20 public cToken;

    address public bincentiveHot; // i.e., Platform Owner
    address public bincentiveCold;
    address[] public investors;
    mapping(address => bool) public isInInvestorList;

    uint256 public numAUMDistributedInvestors; // i.e., number of investors that already received AUM

    uint256 public fundStatus;

    mapping(address => uint256) public investorDepositUSDTAmount;  // denominated in stable token
    uint256 public currentInvestedAmount;  // denominated in stable token

    uint256 public investPaymentDueTime;  // deadline for deposit which comes in before fund starts running
    uint256 public percentageOffchainFund;  // percentage of fund that will be transfered off-chain
    uint256 public percentageMinimumFund;  // minimum percentage of fund required to keep the fund functioning
    uint256 public minimumFund;  // minimum amounf required to keep the fund functioning
    uint256 public minPenalty;  // a minimum 100 USDT penalty

    event Deposit(address indexed investor, uint256 investAmount, uint256 mintedAmount);
    event UserInfo(bytes32 indexed uuid, string referralCode);
    event StartFund(uint256 timeStamp, uint256 num_investors, uint256 totalInvestedAmount, uint256 totalMintedTokenAmount);
    event Withdraw(address indexed investor, uint256 tokenAmount, uint256 USDTAmount, uint256 ToBincentiveColdUSDTAmount);
    event MidwayQuit(address indexed investor, uint256 tokenAmount, uint256 USDTAmount);
    event ReturnAUM(uint256 StableTokenAmount);
    event DistributeAUM(address indexed to, uint256 tokenAmount, uint256 StableTokenAmount);
    event NewBincentiveCold(address newBincentiveCold);
    event MintcUSDT(uint USDTAmount);
    event RedeemcUSDT(uint RedeemcUSDTAmount);

    modifier initialized() {

        require(fundStatus == 1);
        _;
    }


    modifier running() {

        require(fundStatus == 4);
        _;
    }

    modifier runningOrSuspended() {

        require((fundStatus == 4) || (fundStatus == 7));
        _;
    }

    modifier stoppedOrSuspended() {

        require((fundStatus == 5) || (fundStatus == 7));
        _;
    }

    modifier runningOrStoppedOrSuspended() {

        require((fundStatus == 4) || (fundStatus == 5) || (fundStatus == 7));
        _;
    }

    modifier closedOrAbortedOrSuspended() {

        require((fundStatus == 6) || (fundStatus == 2) || (fundStatus == 7));
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
        require(balances[msg.sender] > 0);
        _;
    }


    function checkBalanceTransfer(address to, uint256 amount) internal {

        uint256 balanceBeforeTransfer = StableToken.balanceOf(to);
        uint256 balanceAfterTransfer;
        StableToken.transfer(to, amount);
        balanceAfterTransfer = StableToken.balanceOf(to);
        require(balanceAfterTransfer == balanceBeforeTransfer.add(amount));
    }

    function checkBalanceTransferFrom(address from, address to, uint256 amount) internal {

        uint256 balanceBeforeTransfer = StableToken.balanceOf(to);
        uint256 balanceAfterTransfer;
        StableToken.transferFrom(from, to, amount);
        balanceAfterTransfer = StableToken.balanceOf(to);
        require(balanceAfterTransfer == balanceBeforeTransfer.add(amount));
    }



    function getBalanceValue(address investor) public view returns(uint256) {

        uint256 accruedRatioUSDT = oracle.query();
        return balances[investor].mul(accruedRatioUSDT).div(baseRatio);
    }


    function querycUSDTAmount() internal returns(uint256) {

        return cToken.balanceOf(address(this));
    }

    function querycExgRate() internal returns(uint256) {

        return cToken.exchangeRateCurrent();
    }

    function mintcUSDT(uint USDTAmount) public isBincentive {


        StableToken.approve(address(cToken), USDTAmount); // approve the transfer
        assert(cToken.mint(USDTAmount) == 0);

        emit MintcUSDT(USDTAmount);
    }

    function redeemcUSDT(uint RedeemcUSDTAmount) public isBincentive {


        require(cToken.redeem(RedeemcUSDTAmount) == 0, "something went wrong");

        emit RedeemcUSDT(RedeemcUSDTAmount);
    }


    function deposit(address investor, uint256 depositUSDTAmount, bytes32 uuid, string referralCode) initialized public {

        require(now < investPaymentDueTime, "Deposit too late");
        require((investor != bincentiveHot) && (investor != bincentiveCold), "Investor can not be bincentive accounts");
        require(depositUSDTAmount > 0, "Deposited stable token amount should be greater than zero");

        checkBalanceTransferFrom(msg.sender, address(this), depositUSDTAmount);

        if(isInInvestorList[investor] == false) {
            investors.push(investor);
            isInInvestorList[investor] = true;
        }
        currentInvestedAmount = currentInvestedAmount.add(depositUSDTAmount);
        investorDepositUSDTAmount[investor] = investorDepositUSDTAmount[investor].add(depositUSDTAmount);

        uint256 accruedRatioUSDT = oracle.query();
        uint256 mintedTokenAmount;
        mintedTokenAmount = depositUSDTAmount.mul(baseRatio).div(accruedRatioUSDT);
        _mint(investor, mintedTokenAmount);

        emit Deposit(investor, depositUSDTAmount, mintedTokenAmount);
        emit UserInfo(uuid, referralCode);
    }

    function start() initialized isBincentive public {

        uint256 amountSentOffline = currentInvestedAmount.mul(percentageOffchainFund).div(100);
        checkBalanceTransfer(bincentiveCold, amountSentOffline);

        minimumFund = totalSupply().mul(percentageMinimumFund).div(100);
        fundStatus = 4;
        emit StartFund(now, investors.length, currentInvestedAmount, totalSupply());
    }

    function amountWithdrawable() public view returns(uint256) {

        return totalSupply().sub(minimumFund);
    }

    function isAmountWithdrawable(address investor, uint256 tokenAmount) public view returns(bool) {

        require(tokenAmount > 0, "Withdrawn amount must be greater than zero");
        require(balances[investor] >= tokenAmount, "Not enough token to be withdrawn");
        require(totalSupply().sub(tokenAmount) >= minimumFund, "Amount of fund left would be less than minimum fund threshold after withdrawal");

        return true;
    }

    function withdraw(address investor, uint256 tokenAmount) running isBincentive public {

        require(tokenAmount > 0, "Withdrawn amount must be greater than zero");
        require(balances[investor] >= tokenAmount, "Not enough token to be withdrawn");
        require(totalSupply().sub(tokenAmount) >= minimumFund, "Amount of fund left would be less than minimum fund threshold after withdrawal");

        uint256 investorBalanceBeforeWithdraw = balances[investor];
        _burn(investor, tokenAmount);

        uint256 depositUSDTAmount = investorDepositUSDTAmount[investor];

        uint256 accruedRatioUSDT = oracle.query();
        uint256 principle;
        uint256 interest;
        uint256 amountUSDTToWithdraw;
        uint256 amountUSDTForInvestor;
        uint256 amountUSDTToBincentiveCold;

        amountUSDTToWithdraw = tokenAmount.mul(accruedRatioUSDT).div(baseRatio);
        principle = depositUSDTAmount.mul(tokenAmount).div(investorBalanceBeforeWithdraw);
        interest = amountUSDTToWithdraw.sub(principle);
        amountUSDTForInvestor = principle.mul(99).div(100).add(interest.div(2));
        amountUSDTToBincentiveCold = amountUSDTToWithdraw.sub(amountUSDTForInvestor);

        if (amountUSDTToBincentiveCold < minPenalty) {
            uint256 dif = minPenalty.sub(amountUSDTToBincentiveCold);
            require(dif <= amountUSDTForInvestor, "Withdraw amount is not enough to cover minimum penalty");
            amountUSDTForInvestor = amountUSDTForInvestor.sub(dif);
            amountUSDTToBincentiveCold = minPenalty;
        }

        investorDepositUSDTAmount[investor] = investorDepositUSDTAmount[investor].sub(principle);

        checkBalanceTransfer(investor, amountUSDTForInvestor);
        checkBalanceTransfer(bincentiveCold, amountUSDTToBincentiveCold);

        emit Withdraw(investor, tokenAmount, amountUSDTForInvestor, amountUSDTToBincentiveCold);

        if(totalSupply() == minimumFund) {
            fundStatus = 7;
        }
    }

    function returnAUM(uint256 stableTokenAmount) runningOrSuspended isBincentiveCold public {

        checkBalanceTransferFrom(bincentiveCold, address(this), stableTokenAmount);

        emit ReturnAUM(stableTokenAmount);

        if(fundStatus == 4) fundStatus = 5;
    }

    function transfer(address _to, uint256 _value) public returns (bool){

        uint256 tokenBalanceBeforeTransfer = balances[msg.sender];
        bool success = super.transfer(_to, _value);

        if(success == true) {
            if(isInInvestorList[_to] == false) {
                investors.push(_to);
                isInInvestorList[_to] = true;
            }
            uint256 USDTAmountToTransfer = investorDepositUSDTAmount[msg.sender].mul(_value).div(tokenBalanceBeforeTransfer);
            investorDepositUSDTAmount[msg.sender] = investorDepositUSDTAmount[msg.sender].sub(USDTAmountToTransfer);
            investorDepositUSDTAmount[_to] = investorDepositUSDTAmount[_to].add(USDTAmountToTransfer);
        }
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){

        uint256 tokenBalanceBeforeTransfer = balances[_from];
        bool success = super.transferFrom(_from, _to, _value);

        if(success == true) {
            if(isInInvestorList[_to] == false) {
                investors.push(_to);
                isInInvestorList[_to] = true;
            }
            uint256 USDTAmountToTransfer = investorDepositUSDTAmount[_from].mul(_value).div(tokenBalanceBeforeTransfer);
            investorDepositUSDTAmount[_from] = investorDepositUSDTAmount[_from].sub(USDTAmountToTransfer);
            investorDepositUSDTAmount[_to] = investorDepositUSDTAmount[_to].add(USDTAmountToTransfer);
        }
        return success;
    }

    function update_investor(address _old_address, address _new_address) public isBincentive {

        require((_new_address != bincentiveHot) && (_new_address != bincentiveCold), "Investor can not be bincentive accounts");
        require(isInInvestorList[_old_address] == true, "Investor does not exist");

        uint256 balance = balances[_old_address];
        balances[_old_address] = balances[_old_address].sub(balance);
        balances[_new_address] = balances[_new_address].add(balance);
        emit Transfer(_old_address, _new_address, balance);
        if(isInInvestorList[_new_address] == false) {
            investors.push(_new_address);
            isInInvestorList[_new_address] = true;
        }
        uint256 USDTAmountToTransfer = investorDepositUSDTAmount[_old_address];
        investorDepositUSDTAmount[_old_address] = investorDepositUSDTAmount[_old_address].sub(USDTAmountToTransfer);
        investorDepositUSDTAmount[_new_address] = investorDepositUSDTAmount[_new_address].add(USDTAmountToTransfer);
    }

    function distributeAUM(uint256 numInvestorsToDistribute) stoppedOrSuspended isBincentive public {

        require(numAUMDistributedInvestors.add(numInvestorsToDistribute) <= investors.length, "Distributing to more than total number of investors");

        uint256 accruedRatioUSDT = oracle.query();

        uint256 stableTokenDistributeAmount;
        address investor;
        uint256 investor_amount;
        for(uint i = numAUMDistributedInvestors; i < (numAUMDistributedInvestors.add(numInvestorsToDistribute)); i++) {
            investor = investors[i];
            investor_amount = balances[investor];
            if(investor_amount == 0) continue;
            _burn(investor, investor_amount);

            stableTokenDistributeAmount = investor_amount.mul(accruedRatioUSDT).div(baseRatio);
            checkBalanceTransfer(investor, stableTokenDistributeAmount);

            emit DistributeAUM(investor, investor_amount, stableTokenDistributeAmount);
        }

        numAUMDistributedInvestors = numAUMDistributedInvestors.add(numInvestorsToDistribute);
        if(numAUMDistributedInvestors >= investors.length) {
            currentInvestedAmount = 0;
            if(fundStatus == 5) fundStatus = 6;
        }
    }

    function claimWronglyTransferredFund() closedOrAbortedOrSuspended isBincentive public {

        uint256 totalcUSDTAmount;
        totalcUSDTAmount = querycUSDTAmount();
        redeemcUSDT(totalcUSDTAmount);

        uint256 leftOverAmount = StableToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            checkBalanceTransfer(bincentiveCold, leftOverAmount);
        }
    }

    function updateBincentiveColdAddress(address _newBincentiveCold) public isBincentiveCold {

        require(_newBincentiveCold != address(0), "New BincentiveCold address can not be zero");

        bincentiveCold = _newBincentiveCold;
        emit NewBincentiveCold(_newBincentiveCold);
    }

    constructor(
        address _oracle,
        address _StableToken,
        address _cToken,
        address _bincentiveHot,
        address _bincentiveCold,
        uint256 _investPaymentPeriod,
        uint256 _percentageOffchainFund,
        uint256 _percentageMinimumFund) WhiteListToken(_bincentiveCold) public {

        oracle = SimpleOracleAccruedRatioUSD(_oracle);
        bincentiveHot = _bincentiveHot;
        bincentiveCold = _bincentiveCold;
        StableToken = ITetherERC20(_StableToken);
        cToken = CERC20(_cToken);

        decimals = StableToken.decimals();
        minPenalty = 100 * (10 ** uint256(decimals));  // a minimum 100 USDT penalty
        baseRatio = oracle.query();
        require(baseRatio > 0, "baseRatio should always greater than zero");

        investPaymentDueTime = now.add(_investPaymentPeriod);
        percentageOffchainFund = _percentageOffchainFund;
        percentageMinimumFund = _percentageMinimumFund;

        fundStatus = 1;
    }
}