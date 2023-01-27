pragma solidity ^0.5.0;

contract EIP20 {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


    function approve(address _spender, uint256 _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}pragma solidity ^0.5.0;


contract RHC is EIP20 {


  uint256 public pendingGrants;

  event Issuance(address indexed _beneficiary, uint256 _amount);

  struct Grant {
    uint256 amount;
    uint vestTime;
    bool isCancelled;
    bool isClaimed;
  }

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => Grant[]) private _grants;

  address private _owner;
  mapping (address => bool) private _admins;

  constructor(address admin) public {
    _owner = admin;
  }

  function name() public pure returns (string memory) {

    return "Robinhood";
  }

  function symbol() public pure returns (string memory) {

    return "RHC";
  }

  function decimals() public pure returns (uint8) {

    return 0;
  }

  modifier onlyAdmins() {

    require(msg.sender == _owner || _admins[msg.sender] == true, "only admins can invoke this function");
    _;
  }

  function addAdmin(address admin) public onlyAdmins() {

    _admins[admin] = true;
  }

  function removeAdmin(address admin) public onlyAdmins() {

    require(admin != _owner, "owner can't be removed");
    delete _admins[admin];
  }

  function balanceOf(address owner) public view returns (uint256) {

      return _balances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {

      return _allowances[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool success) {

    require(to != address(0), "Can't transfer tokens to address 0");
    require(balanceOf(msg.sender) >= value, "You don't have sufficient balance to move tokens");

    _move(msg.sender, to, value);

    return true;
  }

  function approve(address spender, uint256 value) public returns (bool success) {

    require(spender != address(0), "Can't set allowance for address 0");
    require(spender != msg.sender, "Use transfer to move your own funds");

    _allowances[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {

    require(to != address(0), "Can't transfer funds to address 0");

    require(allowance(from, msg.sender) >= value, "You're not authorized to transfer funds from this account");
    require(balanceOf(from) >= value, "Owner of funds does not have sufficient balance");

    _allowances[from][msg.sender] -= value;

    _move(from, to, value);

    return true;
  }

  function cancelGrants(address beneficiary) public onlyAdmins() {

    Grant[] storage userGrants = _grants[beneficiary];
    for (uint i = 0; i < userGrants.length; i++) {
      Grant storage grant = userGrants[i];
      if (!grant.isCancelled && !grant.isClaimed) {
        grant.isCancelled = true;

        pendingGrants -= grant.amount;
      }
    }
  }

  function claimGrant() public {

    Grant[] storage userGrants = _grants[msg.sender];
    for (uint i = 0; i < userGrants.length; i++) {
      Grant storage grant = userGrants[i];
      if (!grant.isCancelled && !grant.isClaimed && now >= grant.vestTime) {
        grant.isClaimed = true;

        pendingGrants -= grant.amount;

        _issue(msg.sender, grant.amount);
      }
    }
  }

  function getGrant(address beneficiary, uint grantIndex) public view returns (uint, uint, bool, bool) {

    Grant[] storage grants = _grants[beneficiary];
    if (grantIndex < grants.length) {
      Grant storage grant = grants[grantIndex];
      return (grant.amount, grant.vestTime, grant.isCancelled, grant.isClaimed);
    } else {
      revert("grantIndex must be smaller than length of grants");
    }
  }

  function getGrantCount(address beneficiary) public view returns (uint) {

    return _grants[beneficiary].length;
  }

  function issue(address account, uint256 amount) public onlyAdmins() {

    require(account != address(0), "can't mint to address 0");
    require(amount > 0, "must issue a positive amount of tokens");
    _issue(account, amount);
  }

  function grant(address account, uint256 amount, uint vestTime) public onlyAdmins() {

    require(account != address(0), "grant to the zero address is not allowed");
    require(vestTime > now, "vest schedule must be in the future");

    pendingGrants += amount;
    _grants[account].push(Grant(amount, vestTime, false, false));
  }

  function _move(address from, address to, uint256 value) private {

    _balances[from] -= value;
    _balances[to] += value;
    emit Transfer(from, to, value);
  }

  function _issue(address account, uint256 amount) private {

    totalSupply += amount;
    _balances[account] += amount;
    emit Issuance(account, amount);
  }
}pragma solidity ^0.5.0;


contract Crowdsale {


  struct Round {
    uint tokenPrice;
    uint capacityLeft;
  }
  
  event Sale(uint amountSent, uint amountReturned, uint tokensSold, address buyer);

  event SaleCompleted();

  event RoundChanged(uint oldTokenPrice, uint newTokenPrice);

  Round[] private _rounds;
  uint8 private _currentRound;

  address payable private wallet;

  RHC public token;

  bool public isSaleOpen;

  uint public weiRaised;

  uint public tokensSold;

  constructor(address payable targetWallet, uint[] memory roundPrices, uint[] memory roundCapacities,
              address advisors, address founders, address legal, address developers, address reserve) public {
    require(roundPrices.length == roundCapacities.length, "Equal number of round parameters must be specified");
    require(roundPrices.length >= 1, "Crowdsale must have at least one round");
    require(roundPrices.length < 10, "Rounds are limited to 10 at most");

    _currentRound = 0;
    for (uint i = 0; i < roundPrices.length; i++) {
      _rounds.push(Round(roundPrices[i], roundCapacities[i]));
    }

    wallet = targetWallet;
    isSaleOpen = true;
    weiRaised = 0;
    tokensSold = 0;

    token = new RHC(address(this));

    token.addAdmin(wallet);

    uint in12Months = block.timestamp + (1000 * 60 * 60 * 24 * 365);
    token.grant(developers, 21500000, in12Months);
    token.grant(advisors, 5000000, in12Months);
    token.grant(founders, 14000000, in12Months);
    token.grant(reserve, 7000000, in12Months);
    token.grant(legal, 8500000, in12Months);
  }

  function() external payable {
    uint amount = msg.value;
    address payable buyer = msg.sender;
    require(amount > 0, "must send money to get tokens");
    require(buyer != address(0), "can't send from address 0");
    require(isSaleOpen, "sale must be open in order to purchase tokens");

    (uint tokenCount, uint change) = calculateTokenCount(amount);

    if (tokenCount == 0) {
      buyer.transfer(change);
      return;
    }

    uint acceptedFunds = amount - change;

    wallet.transfer(acceptedFunds);

    buyer.transfer(change);

    token.issue(buyer, tokenCount);

    weiRaised += acceptedFunds;
    tokensSold += tokenCount;

    updateRounds(tokenCount);

    emit Sale(amount, change, tokenCount, buyer);
  }

  function calculateTokenCount(uint money) public view returns (uint count, uint change) {

    require(isSaleOpen, "sale is no longer open and tokens can't be purchased");

    uint price = _rounds[_currentRound].tokenPrice;
    uint capacityLeft = _rounds[_currentRound].capacityLeft;

    if (money < price) {
      return (0, money);
    }

    count = money / price;
    change = money % price;

    if (count > capacityLeft) {
      change += price * (count - capacityLeft);
      count = capacityLeft;
    }

    return (count, change);
  }

  function updateRounds(uint tokens) private {

    Round storage currentRound = _rounds[_currentRound];
    currentRound.capacityLeft -= tokens;

    if (currentRound.capacityLeft <= 0) {
      if (_currentRound == _rounds.length - 1) {
        isSaleOpen = false;
        emit SaleCompleted();
      } else {
        _currentRound++;
        emit RoundChanged(currentRound.tokenPrice, _rounds[_currentRound].tokenPrice);
      }
    }
  }
}