
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint);


    function balanceOf(address account) external view returns (uint);


    function transfer(address recipient, uint amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint);

}// MIT

pragma solidity ^0.8.0;

contract IERC20Ownable {

    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   constructor() {
      owner = msg.sender;
    }
    
    modifier onlyOwner() {

      require(msg.sender == owner);
      _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {

      require(newOwner != address(0));
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT


pragma solidity ^0.8.0;


library SafeMath {


    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);
        c = a / b;
    }
    
    function ceil(uint a, uint m) internal pure returns (uint) {

        uint c = add(a,m);
        uint d = sub(c,1);
        return mul(div(d, m),m);
    }
}

library ExtendedMath {

	using SafeMath for uint;
	
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {

        if(a > b) return b;
        return a;
    }
	
	function findOnePercent(uint _tokenAmount) internal pure returns (uint){

    	uint roundValue = _tokenAmount.ceil(100);
    	uint onePercent = roundValue.mul(100).div(10000);
    	return onePercent;
    }
}

abstract contract StandardToken is Context, IERC20, IERC20Metadata {
    
    using SafeMath for uint;
    using ExtendedMath for uint;
	
    uint _totalSupply;
    
	mapping(address => uint) balances;
	mapping (address => mapping (address => uint)) internal allowed;
    
    function  totalSupply() override public view returns (uint) {
        return _totalSupply;
    }
    
    function transfer(address _to, uint _value) override public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function balanceOf(address _owner) override public view returns (uint) {
        return balances[_owner];
    }
    
    function transferFrom(address _from, address _to, uint _value) override public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
    
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint _value) override public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) override public view returns (uint) {
        return allowed[_owner][_spender];
    }
    
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
	
}

contract Configurable {

    using SafeMath for uint;
	
    uint public constant cap = 100000000*10**18; 
    uint public constant basePrice = 10000000*10**18; 
	
    uint public constant minableTokenSupply = 200000000*10**18;
    uint public tokenReserve = 200000000*10**18;
	
    uint public tokensSold = 0;
    uint public remainingSellTokens = 0;
	
    uint public tokensMinted;
	uint public latestDifficultyPeriodStarted;
	
	uint public  _MINIMUM_TARGET = 2**16;
    uint public  _MAXIMUM_TARGET = 2**234;
	
    uint public _BLOCKS_BEFORE_READJUSTMENT = 1024;
	
    uint public miningTarget = _MAXIMUM_TARGET;
    bytes32 public challengeNumber;
	
    uint public epochCount;
	
    uint public rewardEra;
    uint public maxSupplyForEra;

    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;

    mapping(bytes32 => bytes32) solutionForChallenge;
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
}

abstract contract CrowdsaleToken is StandardToken, Configurable, IERC20Ownable {
    using SafeMath for uint;
    using ExtendedMath for uint;
    
    enum Stages {
        none,
        icoStart, 
        icoEnd
    }
    Stages currentStage;
  
    constructor() {
        currentStage = Stages.none;
        _totalSupply = _totalSupply.add(tokenReserve);
        remainingSellTokens = cap;
		
		rewardEra = 0;
		tokensMinted = 0;
		maxSupplyForEra = minableTokenSupply.div(2);
		latestDifficultyPeriodStarted = block.number;
		
		_startNewMiningEpoch();
    }
    
    receive () external payable {
        require(currentStage == Stages.icoStart);
        require(msg.value > 0);
        require(remainingSellTokens > 0);
        
        
        uint weiAmount = msg.value;
        uint tokens = weiAmount.mul(basePrice).div(1 ether);
        uint returnWei = 0;
        
        if(tokensSold.add(tokens) > cap){
            uint newTokens = cap.sub(tokensSold);
            uint newWei = newTokens.div(basePrice).mul(1 ether);
            returnWei = weiAmount.sub(newWei);
            weiAmount = newWei;
            tokens = newTokens;
        }
        
        tokensSold = tokensSold.add(tokens);
        remainingSellTokens = cap.sub(tokensSold);
        if(returnWei > 0){
            payable(msg.sender).transfer(returnWei);
            emit Transfer(address(this), msg.sender, returnWei);
        }
        
		uint tokensToAdd = tokens.findOnePercent();
		tokenReserve = tokenReserve.sub(tokensToAdd);
        uint tokensToTransfer = tokens.add(tokensToAdd);
        balances[msg.sender] = balances[msg.sender].add(tokensToTransfer);
        emit Transfer(address(this), msg.sender, tokensToTransfer);
		
        _totalSupply = _totalSupply.add(tokens);
        
		payable(owner).transfer(weiAmount);
    }
	
	fallback () external payable {
		revert();
	}
	
    function startIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        currentStage = Stages.icoStart;
    }
	
    function endIco() internal {
        currentStage = Stages.icoEnd;
        
        if(remainingSellTokens > 0)
            balances[owner] = balances[owner].add(remainingSellTokens);
		_totalSupply = _totalSupply.add(remainingSellTokens);
        
        payable(owner).transfer(address(this).balance); 
		
        balances[owner] = balances[owner].add(tokenReserve);
        emit Transfer(address(this), owner, tokenReserve);
    }
	
    function finalizeIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        endIco();
    }
    
	 function mint(uint256 _nonce, bytes32 _challenge_digest) public returns (bool success) {

		bytes32 digest =  keccak256(abi.encodePacked(challengeNumber, msg.sender, _nonce ));

		if (digest != _challenge_digest) revert();
		if(uint256(digest) > miningTarget) revert();

		bytes32 solution = solutionForChallenge[challengeNumber];
		solutionForChallenge[challengeNumber] = digest;
		if(solution != 0x0) revert();

		uint reward_amount = getMiningReward();
		balances[msg.sender] = balances[msg.sender].add(reward_amount);
		tokensMinted = tokensMinted.add(reward_amount);
		_totalSupply = _totalSupply.add(reward_amount);

		assert(tokensMinted <= maxSupplyForEra);

		lastRewardTo = msg.sender;
		lastRewardAmount = reward_amount;
		lastRewardEthBlockNumber = block.number;

		_startNewMiningEpoch();
		Mint(msg.sender, reward_amount, epochCount, challengeNumber );

		return true;
	}


	function _startNewMiningEpoch() internal {

	  if( tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < 39)
	  {
		rewardEra = rewardEra + 1;
	  }

	  maxSupplyForEra = minableTokenSupply - minableTokenSupply.div( 2**(rewardEra + 1));

	  epochCount = epochCount.add(1);

	  if(epochCount % _BLOCKS_BEFORE_READJUSTMENT == 0)
	  {
		_reAdjustDifficulty();
	  }

	  challengeNumber = blockhash(block.number - 1);
	}


	function _reAdjustDifficulty() internal {

		uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
		uint epochsMined = _BLOCKS_BEFORE_READJUSTMENT;
		uint targetEthBlocksPerDiffPeriod = epochsMined * 45;

		if( ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod )
		{
		  uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div( ethBlocksSinceLastDifficultyPeriod );
		  uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
		  miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra));
		}
		else
		{
		  uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(100)).div( targetEthBlocksPerDiffPeriod );
		  uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000);
		  miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra));
		}

		latestDifficultyPeriodStarted = block.number;

		if(miningTarget < _MINIMUM_TARGET)
		{
		  miningTarget = _MINIMUM_TARGET;
		}

		if(miningTarget > _MAXIMUM_TARGET)
		{
		  miningTarget = _MAXIMUM_TARGET;
		}
	}

	function getChallengeNumber() public view returns (bytes32) {
		return challengeNumber;
	}

	function getMiningDifficulty() public view returns (uint) {
		return _MAXIMUM_TARGET.div(miningTarget);
	}

	function getMiningTarget() public view returns (uint) {
	   return miningTarget;
	}

	function getMiningReward() public view returns (uint) {
		 return (100 * 10**uint(18) ).div( 2**rewardEra ) ;
	}
	
	function getMintedTokenAmount() public view returns (uint) {
		return tokensMinted;
	}
	
	function getMintableTokenAmount() public view returns (uint) {
		return minableTokenSupply.sub(tokensMinted);
	}
	
	function getMaxSupply() public view returns (uint) {
		return tokenReserve.add(minableTokenSupply).add(cap);
	}
}

contract LorCoin is CrowdsaleToken {

    string override public constant name = "LorCoin";
    string override public constant symbol = "LORY";
    uint override public constant decimals = 18;
}

