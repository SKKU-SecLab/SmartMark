
pragma solidity 0.4.11;

contract SafeMath {


  function safeMul(uint a, uint b) internal returns (uint) {

    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function safeSub(uint a, uint b) internal returns (uint) {

    assert(b <= a);
    return a - b;
  }
  function safeAdd(uint a, uint b) internal returns (uint) {

    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  modifier onlyPayloadSize(uint numWords) {

     assert(msg.data.length >= numWords * 32 + 4);
     _;
  }

}


contract Token { // ERC20 standard


    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract StandardToken is Token, SafeMath {


    uint256 public totalSupply;

    function transfer(address _to, uint256 _value) onlyPayloadSize(2) returns (bool success) {

        require(_to != address(0));
        require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) returns (bool success) {

        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);

        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) onlyPayloadSize(2) returns (bool success) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        return true;
    }

    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) onlyPayloadSize(3) returns (bool success) {

        require(allowed[msg.sender][_spender] == _oldValue);
        allowed[msg.sender][_spender] = _newValue;
        Approval(msg.sender, _spender, _newValue);

        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

}


contract C20 is StandardToken {



    string public name = "Crypto20";
    string public symbol = "C20";
    uint256 public decimals = 18;
    string public version = "9.0";

    uint256 public tokenCap = 86206896 * 10**18;

    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;

    address public vestingContract;
    bool private vestingSet = false;

    address public fundWallet;
    address public controlWallet;
    uint256 public waitTime = 5 hours;

    bool public halted = false;
    bool public tradeable = false;


    uint256 public previousUpdateTime = 0;
    Price public currentPrice;
    uint256 public minAmount = 0.04 ether;

    mapping (address => Withdrawal) public withdrawals;
    mapping (uint256 => Price) public prices;
    mapping (address => bool) public whitelist;


    struct Price { // tokensPerEth
        uint256 numerator;
        uint256 denominator;
    }

    struct Withdrawal {
        uint256 tokens;
        uint256 time; // time for each withdrawal is set to the previousUpdateTime
    }


    event Buy(address indexed participant, address indexed beneficiary, uint256 ethValue, uint256 amountTokens);
    event AllocatePresale(address indexed participant, uint256 amountTokens);
    event Whitelist(address indexed participant);
    event PriceUpdate(uint256 numerator, uint256 denominator);
    event AddLiquidity(uint256 ethAmount);
    event RemoveLiquidity(uint256 ethAmount);
    event WithdrawRequest(address indexed participant, uint256 amountTokens);
    event Withdraw(address indexed participant, uint256 amountTokens, uint256 etherAmount);


    modifier isTradeable { // exempt vestingContract and fundWallet to allow dev allocations

        require(tradeable || msg.sender == fundWallet || msg.sender == vestingContract);
        _;
    }

    modifier onlyWhitelist {

        require(whitelist[msg.sender]);
        _;
    }

    modifier onlyFundWallet {

        require(msg.sender == fundWallet);
        _;
    }

    modifier onlyManagingWallets {

        require(msg.sender == controlWallet || msg.sender == fundWallet);
        _;
    }

    modifier only_if_controlWallet {

        if (msg.sender == controlWallet) _;
    }
    modifier require_waited {

        require(safeSub(now, waitTime) >= previousUpdateTime);
        _;
    }
    modifier only_if_increase (uint256 newNumerator) {

        if (newNumerator > currentPrice.numerator) _;
    }


    function C20(address controlWalletInput, uint256 priceNumeratorInput, uint256 startBlockInput, uint256 endBlockInput) {

        require(controlWalletInput != address(0));
        require(priceNumeratorInput > 0);
        require(endBlockInput > startBlockInput);
        fundWallet = msg.sender;
        controlWallet = controlWalletInput;
        whitelist[fundWallet] = true;
        whitelist[controlWallet] = true;
        currentPrice = Price(priceNumeratorInput, 1000); // 1 token = 1 usd at ICO start
        fundingStartBlock = startBlockInput;
        fundingEndBlock = endBlockInput;
        previousUpdateTime = now;
    }


    function setVestingContract(address vestingContractInput) external onlyFundWallet {

        require(vestingContractInput != address(0));
        vestingContract = vestingContractInput;
        whitelist[vestingContract] = true;
        vestingSet = true;
    }

    function updatePrice(uint256 newNumerator) external onlyManagingWallets {

        require(newNumerator > 0);
        require_limited_change(newNumerator);
        currentPrice.numerator = newNumerator;
        prices[previousUpdateTime] = currentPrice;
        previousUpdateTime = now;
        PriceUpdate(newNumerator, currentPrice.denominator);
    }

    function require_limited_change (uint256 newNumerator)
        private
        only_if_controlWallet
        require_waited
        only_if_increase(newNumerator)
    {
        uint256 percentage_diff = 0;
        percentage_diff = safeMul(newNumerator, 100) / currentPrice.numerator;
        percentage_diff = safeSub(percentage_diff, 100);
        require(percentage_diff <= 20);
    }

    function updatePriceDenominator(uint256 newDenominator) external onlyFundWallet {

        require(block.number > fundingEndBlock);
        require(newDenominator > 0);
        currentPrice.denominator = newDenominator;
        prices[previousUpdateTime] = currentPrice;
        previousUpdateTime = now;
        PriceUpdate(currentPrice.numerator, newDenominator);
    }

    function allocateTokens(address participant, uint256 amountTokens) private {

        require(vestingSet);
        uint256 developmentAllocation = safeMul(amountTokens, 14942528735632185) / 100000000000000000;
        uint256 newTokens = safeAdd(amountTokens, developmentAllocation);
        require(safeAdd(totalSupply, newTokens) <= tokenCap);
        totalSupply = safeAdd(totalSupply, newTokens);
        balances[participant] = safeAdd(balances[participant], amountTokens);
        balances[vestingContract] = safeAdd(balances[vestingContract], developmentAllocation);
    }

    function allocatePresaleTokens(address participant, uint amountTokens) external onlyFundWallet {

        require(block.number < fundingEndBlock);
        require(participant != address(0));
        whitelist[participant] = true; // automatically whitelist accepted presale
        allocateTokens(participant, amountTokens);
        Whitelist(participant);
        AllocatePresale(participant, amountTokens);
    }

    function verifyParticipant(address participant) external onlyManagingWallets {

        whitelist[participant] = true;
        Whitelist(participant);
    }

    function buy() external payable {

        buyTo(msg.sender);
    }

    function buyTo(address participant) public payable onlyWhitelist {

        require(!halted);
        require(participant != address(0));
        require(msg.value >= minAmount);
        require(block.number >= fundingStartBlock && block.number < fundingEndBlock);
        uint256 icoDenominator = icoDenominatorPrice();
        uint256 tokensToBuy = safeMul(msg.value, currentPrice.numerator) / icoDenominator;
        allocateTokens(participant, tokensToBuy);
        fundWallet.transfer(msg.value);
        Buy(msg.sender, participant, msg.value, tokensToBuy);
    }

    function icoDenominatorPrice() public constant returns (uint256) {

        uint256 icoDuration = safeSub(block.number, fundingStartBlock);
        uint256 denominator;
        if (icoDuration < 2880) { // #blocks = 24*60*60/30 = 2880
            return currentPrice.denominator;
        } else if (icoDuration < 80640 ) { // #blocks = 4*7*24*60*60/30 = 80640
            denominator = safeMul(currentPrice.denominator, 105) / 100;
            return denominator;
        } else {
            denominator = safeMul(currentPrice.denominator, 110) / 100;
            return denominator;
        }
    }

    function requestWithdrawal(uint256 amountTokensToWithdraw) external isTradeable onlyWhitelist {

        require(block.number > fundingEndBlock);
        require(amountTokensToWithdraw > 0);
        address participant = msg.sender;
        require(balanceOf(participant) >= amountTokensToWithdraw);
        require(withdrawals[participant].tokens == 0); // participant cannot have outstanding withdrawals
        balances[participant] = safeSub(balances[participant], amountTokensToWithdraw);
        withdrawals[participant] = Withdrawal({tokens: amountTokensToWithdraw, time: previousUpdateTime});
        WithdrawRequest(participant, amountTokensToWithdraw);
    }

    function withdraw() external {

        address participant = msg.sender;
        uint256 tokens = withdrawals[participant].tokens;
        require(tokens > 0); // participant must have requested a withdrawal
        uint256 requestTime = withdrawals[participant].time;
        Price price = prices[requestTime];
        require(price.numerator > 0); // price must have been set
        uint256 withdrawValue = safeMul(tokens, price.denominator) / price.numerator;
        withdrawals[participant].tokens = 0;
        if (this.balance >= withdrawValue)
            enact_withdrawal_greater_equal(participant, withdrawValue, tokens);
        else
            enact_withdrawal_less(participant, withdrawValue, tokens);
    }

    function enact_withdrawal_greater_equal(address participant, uint256 withdrawValue, uint256 tokens)
        private
    {

        assert(this.balance >= withdrawValue);
        balances[fundWallet] = safeAdd(balances[fundWallet], tokens);
        participant.transfer(withdrawValue);
        Withdraw(participant, tokens, withdrawValue);
    }
    function enact_withdrawal_less(address participant, uint256 withdrawValue, uint256 tokens)
        private
    {

        assert(this.balance < withdrawValue);
        balances[participant] = safeAdd(balances[participant], tokens);
        Withdraw(participant, tokens, 0); // indicate a failed withdrawal
    }


    function checkWithdrawValue(uint256 amountTokensToWithdraw) constant returns (uint256 etherValue) {

        require(amountTokensToWithdraw > 0);
        require(balanceOf(msg.sender) >= amountTokensToWithdraw);
        uint256 withdrawValue = safeMul(amountTokensToWithdraw, currentPrice.denominator) / currentPrice.numerator;
        require(this.balance >= withdrawValue);
        return withdrawValue;
    }

    function addLiquidity() external onlyManagingWallets payable {

        require(msg.value > 0);
        AddLiquidity(msg.value);
    }

    function removeLiquidity(uint256 amount) external onlyManagingWallets {

        require(amount <= this.balance);
        fundWallet.transfer(amount);
        RemoveLiquidity(amount);
    }

    function changeFundWallet(address newFundWallet) external onlyFundWallet {

        require(newFundWallet != address(0));
        fundWallet = newFundWallet;
    }

    function changeControlWallet(address newControlWallet) external onlyFundWallet {

        require(newControlWallet != address(0));
        controlWallet = newControlWallet;
    }

    function changeWaitTime(uint256 newWaitTime) external onlyFundWallet {

        waitTime = newWaitTime;
    }

    function updateFundingStartBlock(uint256 newFundingStartBlock) external onlyFundWallet {

        require(block.number < fundingStartBlock);
        require(block.number < newFundingStartBlock);
        fundingStartBlock = newFundingStartBlock;
    }

    function updateFundingEndBlock(uint256 newFundingEndBlock) external onlyFundWallet {

        require(block.number < fundingEndBlock);
        require(block.number < newFundingEndBlock);
        fundingEndBlock = newFundingEndBlock;
    }

    function halt() external onlyFundWallet {

        halted = true;
    }
    function unhalt() external onlyFundWallet {

        halted = false;
    }

    function enableTrading() external onlyFundWallet {

        require(block.number > fundingEndBlock);
        tradeable = true;
    }

    function() payable {
        require(tx.origin == msg.sender);
        buyTo(msg.sender);
    }

    function claimTokens(address _token) external onlyFundWallet {

        require(_token != address(0));
        Token token = Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(fundWallet, balance);
     }

    function transfer(address _to, uint256 _value) isTradeable returns (bool success) {

        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) isTradeable returns (bool success) {

        return super.transferFrom(_from, _to, _value);
    }

}