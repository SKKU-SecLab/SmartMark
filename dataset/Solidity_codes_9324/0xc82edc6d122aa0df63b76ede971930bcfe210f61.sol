
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

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

library DateTimeUtility {

    
    function toGMT(uint256 _unixtime) 
        pure 
        internal 
        returns(uint32, uint8, uint8, uint8, uint8, uint8)
    {

        uint256 secs = _unixtime % 86400;
        
        _unixtime /= 86400;
        uint256 e = (_unixtime * 4 + 102032) / 146097 + 15;
        e = _unixtime + 2442113 + e - (e / 4);
        uint256 c = (e * 20 - 2442) / 7305;
        uint256 d = e - 365 * c - c / 4;
        e = d * 1000 / 30601;
        
        if (e < 14) {
            return (uint32(c - 4716)
                , uint8(e - 1)
                , uint8(d - e * 30 - e * 601 / 1000)
                , uint8(secs / 3600)
                , uint8(secs / 60 % 60)
                , uint8(secs % 60));
        } else {
            return (uint32(c - 4715)
                , uint8(e - 13)
                , uint8(d - e * 30 - e * 601 / 1000)
                , uint8(secs / 3600)
                , uint8(secs / 60 % 60)
                , uint8(secs % 60));
        }
    } 
    
    function toUnixtime(uint32 _year, uint8 _month, uint8 _mday, uint8 _hour, uint8 _minute, uint8 _second) 
        pure 
        internal 
        returns (uint256)
    {

        
        uint256 m = uint256(_month);
        uint256 y = uint256(_year);
        if (m <= 2) {
            y -= 1;
            m += 12;
        }
        
        return (365 * y + y / 4 -  y/ 100 + y / 400 + 3 * (m + 1) / 5 + 30 * m + uint256(_mday) - 719561) * 86400 
            + 3600 * uint256(_hour) + 60 * uint256(_minute) + uint256(_second);
    }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    require(token.approve(spender, value));
  }
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

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

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


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

contract BurnableToken is BasicToken {


  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract StrayToken is StandardToken, BurnableToken, Ownable {

	using SafeERC20 for ERC20;
	
	uint256 public INITIAL_SUPPLY = 1000000000;
	
	string public name = "Stray";
	string public symbol = "ST";
	uint8 public decimals = 18;

	address public companyWallet;
	address public privateWallet;
	address public fund;
	
	constructor(address _companyWallet, address _privateWallet) public {
		require(_companyWallet != address(0));
		require(_privateWallet != address(0));
		
		totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
		companyWallet = _companyWallet;
		privateWallet = _privateWallet;
		
		_preSale(companyWallet, totalSupply_.mul(15).div(100));
		
		_preSale(privateWallet, totalSupply_.mul(25).div(100));
		
		uint256 sold = balances[companyWallet].add(balances[privateWallet]);
	    balances[msg.sender] = balances[msg.sender].add(totalSupply_.sub(sold));
	    emit Transfer(address(0), msg.sender, balances[msg.sender]);
	}
	
	function setFundContract(address _fund) onlyOwner public {

	    require(_fund != address(0));
	    require(_fund != address(this));
	    
	    fund = _fund;
	}
	
	function burnAll(address _from) public {

	    require(fund == msg.sender);
	    require(0 != balances[_from]);
	    
	    _burn(_from, balances[_from]);
	}
	
	function _preSale(address _to, uint256 _value) internal onlyOwner {

		balances[_to] = _value;
		emit Transfer(address(0), _to, _value);
	}
	
}

contract StrayFund is Ownable {

	using SafeMath for uint256;
	using DateTimeUtility for uint256;
	
	enum State {
	    NotReady       // The fund is not ready for any operations.
	    , TeamWithdraw // The fund can be withdrawn and voting proposals.
	    , Refunding    // The fund only can be refund..
	    , Closed       // The fund is closed.
	}
	

	enum ProposalType { 
	    Tap          // Tap proposal sponsored by token holder out of company.
	    , OfficalTap // Tap proposal sponsored by company.
	    , Refund     // Refund proposal.
	}
	
	uint256 NON_UINT256 = (2 ** 256) - 1;
	
	struct Vote {
		address tokeHolder; // Voter address.
		bool inSupport;     // Support or not.
	}
	
	struct Proposal {              
	    ProposalType proposalType; // Proposal type.
	    address sponsor;           // Who proposed this vote.
	    uint256 openingTime;       // Opening time of the voting.
	    uint256 closingTime;       // Closing time of the voting.
	    Vote[] votes;              // All votes.
		mapping (address => bool) voted; // Prevent duplicate vote.
		bool isPassed;             // Final result.
		bool isFinialized;         // Proposal state.
		uint256 targetWei;         // Tap proposal target.
	}
	
	struct BudgetPlan {
	    uint256 proposalId;       // The tap proposal id.
	    uint256 budgetInWei;      // Budget in wei.
	    uint256 withdrawnWei;     // Withdrawn wei.
	    uint256 startTime;        // Start time of this budget plan. 
	    uint256 endTime;          // End time of this budget plan.
	    uint256 officalVotingTime; // The offical tap voting time in this period.
	}
	
	address public teamWallet;
	
	State public state;
	
	StrayToken public token;
	
	Proposal[] public proposals;
	
	BudgetPlan[] public budgetPlans;
	
	uint256 currentBudgetPlanId;
	
	uint256 public MIN_WITHDRAW_WEI = 1 ether;
	
	uint256 public FIRST_WITHDRAW_RATE = 20;
	
	uint256 public VOTING_DURATION = 1 weeks;
	
	uint8 public OFFICAL_VOTING_DAY_OF_MONTH = 23;
	
	uint256 public REFUND_LOCK_DURATION = 30 days;
	
	uint256 public refundLockDate = 0;
	
	event TeamWithdrawEnabled();
	event RefundsEnabled();
	event Closed();
	
	event TapVoted(address indexed voter, bool isSupported);
	event TapProposalAdded(uint256 openingTime, uint256 closingTime, uint256 targetWei);
	event TapProposalClosed(uint256 closingTime, uint256 targetWei, bool isPassed);
	
	event RefundVoted(address indexed voter, bool isSupported);
	event RefundProposalAdded(uint256 openingTime, uint256 closingTime);
	event RefundProposalClosed(uint256 closingTime, bool isPassed);
	
	event Withdrew(uint256 weiAmount);
	event Refund(address indexed holder, uint256 amount);
	
	modifier onlyTokenHolders {

		require(token.balanceOf(msg.sender) != 0);
		_;
	}
	
	modifier inWithdrawState {

	    require(state == State.TeamWithdraw);
	    _;
	}
	
    constructor(address _teamWallet, address _token) public {
		require(_teamWallet != address(0));
		require(_token != address(0));
		
		teamWallet = _teamWallet;
		state = State.NotReady;
		token = StrayToken(_token);
	}
	
	function enableTeamWithdraw() onlyOwner public {

		require(state == State.NotReady);
		state = State.TeamWithdraw;
		emit TeamWithdrawEnabled();
		
		budgetPlans.length++;
		BudgetPlan storage plan = budgetPlans[0];
		
	    plan.proposalId = NON_UINT256;
	    plan.budgetInWei = address(this).balance.mul(FIRST_WITHDRAW_RATE).div(100);
	    plan.withdrawnWei = 0;
	    plan.startTime = now;
	    (plan.endTime, plan.officalVotingTime) = _budgetEndAndOfficalVotingTime(now);
	    
	    currentBudgetPlanId = 0;
	}
	
	function close() onlyOwner inWithdrawState public {

	    require(address(this).balance < MIN_WITHDRAW_WEI);
	    
		state = State.Closed;
		emit Closed();
		
		teamWallet.transfer(address(this).balance);
	}
	
	function isThereAnOnGoingProposal() public view returns (bool) {

	    if (proposals.length == 0 || state != State.TeamWithdraw) {
	        return false;
	    } else {
	        Proposal storage p = proposals[proposals.length - 1];
	        return now < p.closingTime;
	    }
	}
	
	function isNextBudgetPlanMade() public view returns (bool) {

	    if (state != State.TeamWithdraw) {
	        return false;
	    } else {
	        return currentBudgetPlanId != budgetPlans.length - 1;
	    }
	}
	
	function numberOfProposals() public view returns (uint256) {

	    return proposals.length;
	}
	
	function numberOfBudgetPlan() public view returns (uint256) {

	    return budgetPlans.length;
	}
	
	function tryFinializeLastProposal() inWithdrawState public {

	    if (proposals.length == 0) {
	        return;
	    }
	    
	    uint256 id = proposals.length - 1;
	    Proposal storage p = proposals[id];
	    if (now > p.closingTime && !p.isFinialized) {
	        _countVotes(p);
	        if (p.isPassed) {
	            if (p.proposalType == ProposalType.Refund) {
	                _enableRefunds();
	            } else {
	                _makeBudgetPlan(p, id);
	            }
	        }
	    }
	}
	
	function newTapProposalFromTokenHolders(uint256 _targetWei)
	    onlyTokenHolders 
	    inWithdrawState 
	    public
	{

	    require(msg.sender != owner);
	    require(msg.sender != teamWallet);
	    
	    tryFinializeLastProposal();
	    require(state == State.TeamWithdraw);
	    
	    require(!isNextBudgetPlanMade());
	    
	    require(!isThereAnOnGoingProposal());
	    
	    BudgetPlan storage b = budgetPlans[currentBudgetPlanId];
		require(now <= b.officalVotingTime && now >= b.startTime);
		
		require(!_hasProposed(msg.sender, ProposalType.Tap));
		
		_newTapProposal(ProposalType.Tap, _targetWei);
	}
	
	function newTapProposalFromCompany(uint256 _targetWei)
	    onlyOwner 
	    inWithdrawState 
	    public
	{

	    tryFinializeLastProposal();
	    require(state == State.TeamWithdraw);
	    
	    require(!isNextBudgetPlanMade());
	    
	    require(!isThereAnOnGoingProposal());
	    
	    BudgetPlan storage b = budgetPlans[currentBudgetPlanId];
		require(now >= b.officalVotingTime);
		
		_newTapProposal(ProposalType.OfficalTap, _targetWei);
	}
	
	function newRefundProposal() onlyTokenHolders inWithdrawState public {

	    tryFinializeLastProposal();
	    require(state == State.TeamWithdraw);
	    
	    require(!isThereAnOnGoingProposal());
	    
	    require(!_hasProposed(msg.sender, ProposalType.Refund));
	    
		uint256 id = proposals.length++;
		Proposal storage p = proposals[id];
		p.proposalType = ProposalType.Refund;
		p.sponsor = msg.sender;
		p.openingTime = now;
		p.closingTime = now + VOTING_DURATION;
		p.isPassed = false;
		p.isFinialized = false;
		
		emit RefundProposalAdded(p.openingTime, p.closingTime);
	}
	
	function voteForTap(bool _supportsProposal)
	    onlyTokenHolders
	    inWithdrawState
	    public
	{

	    tryFinializeLastProposal();
		require(isThereAnOnGoingProposal());
		
		Proposal storage p = proposals[proposals.length - 1];
		require(p.proposalType != ProposalType.Refund);
		require(true != p.voted[msg.sender]);
		
		uint256 voteId = p.votes.length++;
		p.votes[voteId].tokeHolder = msg.sender;
		p.votes[voteId].inSupport = _supportsProposal;
		p.voted[msg.sender] = true;
		
		emit TapVoted(msg.sender, _supportsProposal);
	}
	
	function voteForRefund(bool _supportsProposal)
	    onlyTokenHolders
	    inWithdrawState
	    public
	{

	    tryFinializeLastProposal();
		require(isThereAnOnGoingProposal());
		
		Proposal storage p = proposals[proposals.length - 1];
		require(p.proposalType == ProposalType.Refund);
		require(true != p.voted[msg.sender]);
		
		uint256 voteId = p.votes.length++;
		p.votes[voteId].tokeHolder = msg.sender;
		p.votes[voteId].inSupport = _supportsProposal;
		p.voted[msg.sender] = true;
		
		emit RefundVoted(msg.sender, _supportsProposal);
	}
	
	function withdraw(uint256 _amount) onlyOwner inWithdrawState public {

	    tryFinializeLastProposal();
	    require(state == State.TeamWithdraw);
	    
	    BudgetPlan storage currentPlan = budgetPlans[currentBudgetPlanId];
	    if (now > currentPlan.endTime) {
	        require(isNextBudgetPlanMade());
	        ++currentBudgetPlanId;
	    }
	    
	    _withdraw(_amount);
	}
	
	function withdrawOnNoAvailablePlan() onlyOwner inWithdrawState public {

	    require(address(this).balance >= MIN_WITHDRAW_WEI);
	    
	    tryFinializeLastProposal();
	    require(state == State.TeamWithdraw);
	    
	    require(!_isThereAnOnGoingTapProposal());
	    
	    require(!isNextBudgetPlanMade());
	    
	    BudgetPlan storage currentPlan = budgetPlans[currentBudgetPlanId];
	    require(now > currentPlan.endTime);
	    
	    uint256 planId = budgetPlans.length++;
	    BudgetPlan storage plan = budgetPlans[planId];
	    plan.proposalId = NON_UINT256;
	    plan.budgetInWei = MIN_WITHDRAW_WEI;
	    plan.withdrawnWei = 0;
	    plan.startTime = now;
	    (plan.endTime, plan.officalVotingTime) = _budgetEndAndOfficalVotingTime(now);
	    
	    ++currentBudgetPlanId;
	    
	    _withdraw(MIN_WITHDRAW_WEI);
	}
	
	function claimRefund() onlyTokenHolders public {

		require(state == State.Refunding);
		
		require(now > refundLockDate + REFUND_LOCK_DURATION);
		
		uint256 amount = address(this).balance.mul(token.balanceOf(msg.sender)).div(token.totalSupply());
		token.burnAll(msg.sender);
		
		msg.sender.transfer(amount);
	}
	
	 function isRefundLocked() public view returns (bool) {

	     return state == State.Refunding && now < refundLockDate + REFUND_LOCK_DURATION;
	 }
	
	 function remainingFunds() public view returns (uint256) {

	     return address(this).balance;
	 }
	
	function receiveInitialFunds() payable public {

	    require(state == State.NotReady);
	}
	
	function () payable public {
	    receiveInitialFunds();
	}
	
	function _withdraw(uint256 _amount) internal {

	    BudgetPlan storage plan = budgetPlans[currentBudgetPlanId];
	    
	    require(now <= plan.endTime);
	    
	    require(_amount + plan.withdrawnWei <= plan.budgetInWei);
	       
	    plan.withdrawnWei += _amount;
	    teamWallet.transfer(_amount);
	    
	    emit Withdrew(_amount);
	}
	
	function _countVotes(Proposal storage p)
	    internal 
	    returns (bool)
	{

	    require(!p.isFinialized);
	    require(now > p.closingTime);
	    
		uint256 yes = 0;
		uint256 no = 0;
		
		for (uint256 i = 0; i < p.votes.length; ++i) {
			Vote storage v = p.votes[i];
			uint256 voteWeight = token.balanceOf(v.tokeHolder);
			if (v.inSupport) {
				yes += voteWeight;
			} else {
				no += voteWeight;
			}
		}
		
		p.isPassed = (yes >= no);
		p.isFinialized = true;
		
		emit TapProposalClosed(p.closingTime
			, p.targetWei
			, p.isPassed);
		
		return p.isPassed;
	}
	
	function _enableRefunds() inWithdrawState internal {

	    state = State.Refunding;
		emit RefundsEnabled();
		
		refundLockDate = now;
	}
	
	function _makeBudgetPlan(Proposal storage p, uint256 proposalId) 
	    internal
	{

	    require(p.proposalType != ProposalType.Refund);
	    require(p.isFinialized);
	    require(p.isPassed);
	    require(!isNextBudgetPlanMade());
	    
	    uint256 planId = budgetPlans.length++;
	    BudgetPlan storage plan = budgetPlans[planId];
	    plan.proposalId = proposalId;
	    plan.budgetInWei = p.targetWei;
	    plan.withdrawnWei = 0;
	    
	    if (now > budgetPlans[currentBudgetPlanId].endTime) {
	        plan.startTime = now;
	        (plan.endTime, plan.officalVotingTime) = _budgetEndAndOfficalVotingTime(now);
	        ++currentBudgetPlanId;
	    } else {
	        (plan.startTime, plan.endTime, plan.officalVotingTime) = _nextBudgetStartAndEndAndOfficalVotingTime();
	    }
	}
	
	function _newTapProposal(ProposalType _proposalType, uint256 _targetWei) internal {

		require(_targetWei >= MIN_WITHDRAW_WEI && _targetWei <= address(this).balance);
	    
	    uint256 id = proposals.length++;
        Proposal storage p = proposals[id];
        p.proposalType = _proposalType;
		p.sponsor = msg.sender;
		p.openingTime = now;
		p.closingTime = now + VOTING_DURATION;
		p.isPassed = false;
		p.isFinialized = false;
		p.targetWei = _targetWei;
		
		emit TapProposalAdded(p.openingTime
			, p.closingTime
			, p.targetWei);
	}
	
	function _isThereAnOnGoingTapProposal() internal view returns (bool) {

	    if (proposals.length == 0) {
	        return false;
	    } else {
	        Proposal storage p = proposals[proposals.length - 1];
	        return p.proposalType != ProposalType.Refund  && now < p.closingTime;
	    }
	}
	
	function _budgetEndAndOfficalVotingTime(uint256 _startTime)
	    view
	    internal
	    returns (uint256, uint256)
	{

        uint32 year;
        uint8 month;
        uint8 mday;
        uint8 hour;
        uint8 minute;
        uint8 second;
        (year, month, mday, hour, minute, second) = _startTime.toGMT();
        
        month = ((month - 1) / 3 + 1) * 3 + 1;
        if (month > 12) {
            month -= 12;
            year += 1;
        }
        
        mday = 1;
        hour = 0;
        minute = 0;
        second = 0;
        
        uint256 end = DateTimeUtility.toUnixtime(year, month, mday, hour, minute, second) - 1;
     
        mday = OFFICAL_VOTING_DAY_OF_MONTH;
        hour = 0;
        minute = 0;
        second = 0;
        
        uint256 votingTime = DateTimeUtility.toUnixtime(year, month, mday, hour, minute, second);
        
        return (end, votingTime);
	}
    
    function _nextBudgetStartAndEndAndOfficalVotingTime() 
        view 
        internal 
        returns (uint256, uint256, uint256)
    {

        uint32 year;
        uint8 month;
        uint8 mday;
        uint8 hour;
        uint8 minute;
        uint8 second;
        (year, month, mday, hour, minute, second) = now.toGMT();
        
        month = ((month - 1) / 3 + 1) * 3 + 1;
        if (month > 12) {
            month -= 12;
            year += 1;
        }
        
        mday = 1;
        hour = 0;
        minute = 0;
        second = 0;
        
        uint256 start = DateTimeUtility.toUnixtime(year, month, mday, hour, minute, second);
        
        month = ((month - 1) / 3 + 1) * 3 + 1;
        if (month > 12) {
            month -= 12;
            year += 1;
        }
        
        uint256 end = DateTimeUtility.toUnixtime(year, month, mday, hour, minute, second) - 1;
        
        mday = OFFICAL_VOTING_DAY_OF_MONTH;
        hour = 0;
        minute = 0;
        second = 0;
        
        uint256 votingTime = DateTimeUtility.toUnixtime(year, month, mday, hour, minute, second);
        
        return (start, end, votingTime);
    } 
    
    function _hasProposed(address _sponsor, ProposalType proposalType)
        internal
        view
        returns (bool)
    {

        if (proposals.length == 0) {
            return false;
        } else {
            BudgetPlan storage b = budgetPlans[currentBudgetPlanId];
            for (uint256 i = proposals.length - 1;; --i) {
                Proposal storage p = proposals[i];
                if (p.openingTime < b.startTime) {
                    return false;
                } else if (p.openingTime <= b.endTime 
                            && p.sponsor == _sponsor 
                            && p.proposalType == proposalType
                            && !p.isPassed) {
                    return true;
                }
                
                if (i == 0)
                    break;
            }
            return false;
        }
    }
}