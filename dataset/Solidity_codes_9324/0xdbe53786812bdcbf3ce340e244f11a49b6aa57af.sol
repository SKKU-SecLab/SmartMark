
pragma solidity 0.8.1;

contract Context {

    function _msgSender() internal view returns (address payable) {

        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface ISHP {

  function balanceOfAt(address owner, uint256 blockNumber) external pure returns (uint256);

  function totalSupplyAt(uint256 blockNumber) external pure returns (uint256);

}

interface IVegaVesting {

  function tranche_count() external view returns(uint8);

  function withdraw_from_tranche(uint8 tranche_id) external;

  function get_vested_for_tranche(address user, uint8 tranche_id) external view returns(uint256);

  function user_total_all_tranches(address user) external view returns(uint256);

}

contract VEGA_Pool is Ownable {


  uint256 public constant EXEPECTED_VEGA = 422000 ether;
  uint256 public constant EQUITY_RATIO = 2500;

  uint256 public assignSharesCutoff;
  uint256 public equityTokens;
  uint256 public equityTokensRedeemed;
  uint256 public preferentialTokens;
  uint256 public preferentialTokensRedeemed;

  address public preferentialAddress;

  bool public initialized = false;

  ISHP public shp;
  IERC20 public vega;
  IVegaVesting public vegaVesting;

  uint256 public referenceBlock;

  bool public voteComplete = false;
  bool public approveDistribution = false;

  mapping(address => uint256) public equityShares;
  mapping(address => bool) public permittedEquityHolders;
  mapping(uint256 => address) public equityHolders;
  mapping(address => int8) public distributionVotes;
  mapping(address => bool) public shpTokensRedeemed;

  uint256 public totalEquityHolders;
  uint256 public totalShares;
  uint256 public totalVotes;
  int256 public voteOutcome;
  uint256 public shpRedemptionCount;

  event VoteCast(int8 vote, address shareholder);
  event TokensClaimed(uint256 amount, address recipient);
  event ERC20TokenWithdrawn(uint256 amount, address tokenAddress);
  event EtherWithdrawn(uint256 amount);
  event EquityIssued(address holder, uint256 amount,
    uint256 totalEquityHolders, uint256 totalShares);
  event PreferentialTokensRedeemed(uint256 amount);
  event EquityTokensRedeemed(address recipient, uint256 amount);
  event ExcessTokensRedeemed(uint256 amount);
  event PermittedEquityHolderAdded(address holder);
  event VegaPoolInitialized(address vegaAddress, address vestingAddress,
    address preferentialAddress, uint256 assignSharesCutoff,
    uint256 referenceBlock, address shpTokenAddress);

  modifier requireInitialized() {

     require(initialized, "Contract is not initialized.");
     _;
  }

  modifier notInitialized() {

     require(!initialized, "Contract has been initialized.");
     _;
  }

  receive() external payable { }

  function castVote(int8 _vote) requireInitialized public {

    require(block.timestamp > assignSharesCutoff,
      "Cannot vote whilst shares can still be assigned.");
    require(distributionVotes[msg.sender] == 0,
      "You have already cast your vote.");
    require(_vote == 1 || _vote == -1,
      "Vote must be 1 or -1");
    require(voteComplete == false,
      "Voting has already concluded.");
    require(equityShares[msg.sender] > 0,
      "You cannot vote without equity shares.");
    int256 weight = int256(getUserEquity(msg.sender));
    distributionVotes[msg.sender] = _vote;
    totalVotes += 1;
    voteOutcome += (_vote * weight);
    if(totalVotes == totalEquityHolders) {
      voteComplete = true;
      approveDistribution = voteOutcome > 0;
    }
    emit VoteCast(_vote, msg.sender);
  }

  function syncTokens() requireInitialized internal {

    withdrawVestedTokens();
    if(preferentialTokens > preferentialTokensRedeemed) {
      redeemPreferentialTokens();
    }
  }

  function claimTokens() requireInitialized public {

    require(approveDistribution, "Distribution is not approved");
    syncTokens();
    require(preferentialTokens == preferentialTokensRedeemed,
      "Cannot claim until preferential tokens are redeemed.");
    uint256 shpBalance = shp.balanceOfAt(msg.sender, referenceBlock);
    require(shpTokensRedeemed[msg.sender] == false,
      "SHP holder already claimed tokens.");
    uint256 vegaBalance = vega.balanceOf(address(this));
    require(shpRedemptionCount > 0 || vegaBalance >= equityTokens,
      "Cannot claim until all equity tokens are fully vested.");
    uint256 shpSupply = shp.totalSupplyAt(referenceBlock);
    uint256 mod = 1000000000000;
    uint256 tokenAmount = (((shpBalance * mod) / shpSupply) *
      equityTokens) / mod;
    vega.transfer(msg.sender, tokenAmount);
    equityTokensRedeemed += tokenAmount;
    shpTokensRedeemed[msg.sender] = true;
    shpRedemptionCount += 1;
    emit TokensClaimed(tokenAmount, msg.sender);
  }

  function withdrawArbitraryTokens(
    address _tokenAddress
  ) requireInitialized onlyOwner public {

    require(_tokenAddress != address(vega),
      "VEGA cannot be withdrawn at-will.");
    IERC20 token = IERC20(_tokenAddress);
    uint256 amount = token.balanceOf(address(this));
    token.transfer(owner(), amount);
    emit ERC20TokenWithdrawn(amount, _tokenAddress);
  }

  function withdrawEther() requireInitialized onlyOwner public {

    uint256 amount = address(this).balance;
    payable(owner()).transfer(amount);
    emit EtherWithdrawn(amount);
  }

  function withdrawVestedTokens() requireInitialized internal {

    for(uint8 i = 1; i < vegaVesting.tranche_count(); i++) {
      if(vegaVesting.get_vested_for_tranche(address(this), i) > 0) {
        vegaVesting.withdraw_from_tranche(i);
      }
    }
  }

  function issueEquity(
    address _holder,
    uint256 _amount
  ) requireInitialized onlyOwner public {

    require(permittedEquityHolders[_holder],
      "The holder must be permitted to own equity.");
    require(assignSharesCutoff > block.timestamp,
      "The cutoff has passed for assigning shares.");
    if(equityShares[_holder] == 0) {
      equityHolders[totalEquityHolders] = _holder;
      totalEquityHolders += 1;
    }
    totalShares += _amount;
    equityShares[_holder] += _amount;
    emit EquityIssued(_holder, _amount, totalEquityHolders, totalShares);
  }

  function redeemPreferentialTokens() requireInitialized public {

    require(preferentialTokens > preferentialTokensRedeemed,
      "All preferntial tokens have been redeemed.");
    withdrawVestedTokens();
    uint256 availableTokens = preferentialTokens - preferentialTokensRedeemed;
    uint256 vegaBalance = vega.balanceOf(address(this));
    if(availableTokens > vegaBalance) {
      availableTokens = vegaBalance;
    }
    vega.transfer(preferentialAddress, availableTokens);
    preferentialTokensRedeemed += availableTokens;
    emit PreferentialTokensRedeemed(availableTokens);
  }

  function redeemTokensViaEquity() requireInitialized public {

    require(totalShares > 0, "There are are no equity holders");
    require(assignSharesCutoff < block.timestamp,
      "Tokens cannot be redeemed whilst equity can still be assigned.");
    syncTokens();
    require(preferentialTokens == preferentialTokensRedeemed,
      "Cannot redeem via equity until all preferential tokens are collected.");
    require(voteComplete, "Cannot redeem via equity until vote is completed.");
    require(approveDistribution == false,
      "Tokens can only be redeemed by SHP holders.");
    uint256 availableTokens = equityTokens - equityTokensRedeemed;
    uint256 vegaBalance = vega.balanceOf(address(this));
    if(availableTokens > vegaBalance) {
      availableTokens = vegaBalance;
    }
    for(uint256 i = 0; i < totalEquityHolders; i++) {
      uint256 tokensToRedeem = (availableTokens *
        getUserEquity(equityHolders[i])) / 10000;
      vega.transfer(equityHolders[i], tokensToRedeem);
      equityTokensRedeemed += tokensToRedeem;
      emit EquityTokensRedeemed(equityHolders[i], tokensToRedeem);
    }
  }

  function redeemExcessTokens() requireInitialized public {

    if(totalEquityHolders > 0) {
      require(equityTokens == equityTokensRedeemed,
        "Cannot redeem excess tokens until equity tokens are collected.");
    }
    require(preferentialTokens == preferentialTokensRedeemed,
      "Cannot redeem excess tokens until preferential tokens are collected.");
    withdrawVestedTokens();
    uint256 amount = vega.balanceOf(address(this));
    emit ExcessTokensRedeemed(amount);
    vega.transfer(owner(), amount);
  }

  function getUserEquity(
    address _holder
  ) public view returns(uint256) {

    return (equityShares[_holder] * 10000) / totalShares;
  }

  function initialize(
    address _vegaAddress,
    address _vegaVestingAddress,
    address _preferentialAddress,
    address[] memory _holders,
    uint256 _assignSharesCutoff,
    uint256 _referenceBlock,
    address _shpTokenAddress
  ) public onlyOwner notInitialized {

    vega = IERC20(_vegaAddress);
    shp = ISHP(_shpTokenAddress);
    vegaVesting = IVegaVesting(_vegaVestingAddress);
    uint256 totalTokens = vegaVesting.user_total_all_tranches(address(this));
    preferentialAddress = _preferentialAddress;
    assignSharesCutoff = _assignSharesCutoff;
    referenceBlock = _referenceBlock;
    require(totalTokens >= EXEPECTED_VEGA,
      "The balance at the vesting contract is too low.");
    for(uint8 x = 0; x < _holders.length; x++) {
      permittedEquityHolders[_holders[x]] = true;
      emit PermittedEquityHolderAdded(_holders[x]);
    }
    equityTokens = (totalTokens * EQUITY_RATIO) / 10000;
    preferentialTokens = totalTokens - equityTokens;
    initialized = true;
    emit VegaPoolInitialized(_vegaAddress, _vegaVestingAddress,
      _preferentialAddress, _assignSharesCutoff,
      _referenceBlock, _shpTokenAddress);
  }
}