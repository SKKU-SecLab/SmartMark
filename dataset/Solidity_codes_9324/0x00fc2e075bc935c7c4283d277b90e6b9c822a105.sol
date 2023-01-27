
pragma solidity ^0.4.16;

contract SmartPool {


    uint currAmount;    //Current amount in the pool (=balance)
    uint ticketPrice;   //Price of one ticket
    uint startDate;		//The date of opening
	uint endDate;		//The date of closing (or 0 if still open)
	
	uint startBlock;
	uint endBlock;
	
	uint duration;		//The pool ends when the duration expire
    uint ticketCount;	//Or when the reserve of tickets has been sold
    bool ended;			//Current state (can't buy tickets when ended)
	bool terminated;	//true if a winner has been picked
	bool moneySent;		//true if the winner has picked his money
    
	uint constant blockDuration = 15; // we use 15 sec for the block duration
	uint constant minWaitDuration = 240; // (= 3600 / blockDuration => 60 minutes waiting between 'ended' and 'terminated')
	
    address[] players;	//List of tickets owners, each ticket gives an entry in the array
	
    address winner;		//The final winner (only available when terminated == true)
     
    address poolManager;
    
    function SmartPool(uint _ticketPrice, uint _ticketCount, uint _duration) public
    {

        require(_ticketPrice > 0 && (_ticketCount > 0 || _duration > blockDuration));
		
		require(now + _duration >= now);
		
		if (_ticketCount == 0)
		{
			_ticketCount = (2 ** 256 - 1) / _ticketPrice;
		}
		
		require(_ticketCount * _ticketPrice >= _ticketPrice);
		
		poolManager = msg.sender;
		
        currAmount = 0;
		startDate = now;
		endDate = 0;
		startBlock = block.number;
		endBlock = 0;
        ticketPrice = _ticketPrice;
        ticketCount = _ticketCount;
		duration = _duration / blockDuration; // compute duration in blocks
        ended = false;
		terminated = false;
		moneySent = false;
		winner = 0x0000000000000000000000000000000000000000;
    }

	
	function getPlayers() public constant returns (address[])
    {

    	return players;
    }
	
	function getStartDate() public constant returns (uint)
    {

    	return startDate;
    }
	
	function getStartBlock() public constant returns (uint)
    {

    	return startBlock;
    }
	
    function getCurrAmount() public constant returns (uint)
    {

    	return currAmount;
    }
	
	function getTicketPrice() public constant returns (uint)
	{

		return ticketPrice;
	}
	
	function getTicketCount() public constant returns (uint)
	{

		return ticketCount;
	}
	
	function getBoughtTicketCount() public constant returns (uint)
	{

		return players.length;
	}
	
	function getAvailableTicketCount() public constant returns (uint)
	{

		return ticketCount - players.length;
	}
	
	function getEndDate() public constant returns (uint)
	{

		return endDate;
	}
	
	function getEndBlock() public constant returns (uint)
    {

    	return endBlock;
    }
	
	function getDuration() public constant returns (uint)
	{

		return duration; // duration in blocks
	}
	
	function getDurationS() public constant returns (uint)
	{

		return duration * blockDuration; // duration in seconds
	}
		
	function isEnded() public constant returns (bool)
	{

		return ended;
	}

	function isTerminated() public constant returns (bool)
	{

		return terminated;
	}
	
	function isMoneySent() public constant returns (bool)
	{

		return moneySent;
	}
	
	function getWinner() public constant returns (address)
	{

		return winner;
	}

	function checkEnd() public
	{

		if ( (duration > 0 && block.number >= startBlock + duration) || (players.length >= ticketCount) )
        {
			ended = true;
			endDate = now;
			endBlock = block.number;
        }
	}
	
    function addPlayer(address player, uint ticketBoughtCount, uint amount) public  
	{

		require(msg.sender == poolManager);
		
        require (!ended);
		
        currAmount += amount; // amount has been checked by the manager
        
		for (uint i = 0; i < ticketBoughtCount; i++)
			players.push(player);
        
		checkEnd();
    }
	
	function canTerminate() public constant returns(bool)
	{

		return ended && !terminated && block.number - endBlock >= minWaitDuration;
	}

    function terminate(uint randSeed) public 
	{		

		require(msg.sender == poolManager);
		
        require(ended && !terminated);
		
		require(block.number - endBlock >= minWaitDuration);
		
        terminated = true;

		if (players.length > 0)
			winner = players[randSeed % players.length];
    }
	
	function onMoneySent() public
	{

		require(msg.sender == poolManager);
		
		require(terminated);
		
		require(!moneySent);
		moneySent = true;
	}
}

       
contract WalletContract
{

	function payMe() public payable;

}
	   
	   
contract PoolManager {


    address owner;
	
	address wallet;
	
	mapping(address => uint) fees;
		
	uint constant feeDivider = 100; //(1/100 of the amount)

    uint constant ticketPriceMultiple = 10205000000000000; //(multiple of 0.010205 ether for ticketPrice)

	SmartPool[] pools;
	
	SmartPool[] poolsDone;
	
	SmartPool[] poolsHistory;
	
	uint randSeed;

	function PoolManager(address wal) public
	{

		owner = msg.sender;
		wallet = wal;

		randSeed = 0;
	}
	
	function updateSeed() private
	{

		randSeed += (uint(block.blockhash(block.number - 1)));
	}
	
	function addPool(uint ticketPrice, uint ticketCount, uint duration) public
	{

		require(msg.sender == owner);
		require(ticketPrice >= ticketPriceMultiple && ticketPrice % ticketPriceMultiple == 0);
		
		pools.push(new SmartPool(ticketPrice, ticketCount, duration));
	}
	
	
	function getPoolCount() public constant returns(uint)
	{

		return pools.length;
	}
	function getPool(uint index) public constant returns(address)
	{

		require(index < pools.length);
		return pools[index];
	}
	
	function getPoolDoneCount() public constant returns(uint)
	{

		return poolsDone.length;
	}
	function getPoolDone(uint index) public constant returns(address)
	{

		require(index < poolsDone.length);
		return poolsDone[index];
	}

	function getPoolHistoryCount() public constant returns(uint)
	{

		return poolsHistory.length;
	}
	function getPoolHistory(uint index) public constant returns(address)
	{

		require(index < poolsHistory.length);
		return poolsHistory[index];
	}
		
	function buyTicket(uint poolIndex, uint ticketCount, address websiteFeeAddr) public payable
	{

		require(poolIndex < pools.length);
		require(ticketCount > 0);
		
		SmartPool pool = pools[poolIndex];
		pool.checkEnd();
		require (!pool.isEnded());
		
		uint availableCount = pool.getAvailableTicketCount();
		if (ticketCount > availableCount)
			ticketCount = availableCount;
		
		uint amountRequired = ticketCount * pool.getTicketPrice();
		require(msg.value >= amountRequired);
		
		uint amountLeft = msg.value - amountRequired;
		
		if (websiteFeeAddr == address(0))
			websiteFeeAddr = wallet;
		
		uint feeAmount = amountRequired / feeDivider;
		
		addFee(websiteFeeAddr, feeAmount);
		addFee(wallet, feeAmount);
		
		pool.addPlayer(msg.sender, ticketCount, amountRequired - 2 * feeAmount);
		
		if (amountLeft > 0 && !msg.sender.send(amountLeft))
		{
			addFee(wallet, amountLeft); // if it fails, we take it as a fee..
		}
		
		updateSeed();
	}

	function checkPoolsEnd() public 
	{

		for (uint i = 0; i < pools.length; i++)
		{
			checkPoolEnd(i);
		}
	}
	
	function checkPoolEnd(uint i) public 
	{

		require(i < pools.length);
		
		SmartPool pool = pools[i];
		if (!pool.isEnded())
			pool.checkEnd();
			
		if (!pool.isEnded())
		{
			return; // not ended yet
		}
		
		updateSeed();
		
		poolsDone.push(pool);
		pools[i] = new SmartPool(pool.getTicketPrice(), pool.getTicketCount(), pool.getDurationS());
	}
	
	function checkPoolsDone() public 
	{

		for (uint i = 0; i < poolsDone.length; i++)
		{
			checkPoolDone(i);
		}
	}
	
	function checkPoolDone(uint i) public
	{

		require(i < poolsDone.length);
		
		SmartPool pool = poolsDone[i];
		if (pool.isTerminated())
			return; // already terminated
			
		if (!pool.canTerminate())
			return; // we need to wait a bit more before random occurs, so the seed has changed enough (60 minutes before ended and terminated states)
			
		updateSeed();
		
		pool.terminate(randSeed);
	}

	function sendPoolMoney(uint i) public
	{

		require(i < poolsDone.length);
		
		SmartPool pool = poolsDone[i];
		require (pool.isTerminated()); // we need a winner picked
		
		require(!pool.isMoneySent()); // money not sent
		
		uint amount = pool.getCurrAmount();
		address winner = pool.getWinner();
		pool.onMoneySent();
		if (amount > 0 && !winner.send(amount)) // the winner can't get his money (should not happen)
		{
			addFee(wallet, amount);
		}
		
		poolsHistory.push(pool);
	}
		
	function clearPoolsDone() public
	{

		for (uint i = 0; i < poolsDone.length; i++)
		{
			if (!poolsDone[i].isMoneySent())
				return;
		}
		
		poolsDone.length = 0;
	}
	
	function getFeeValue(address a) public constant returns (uint)
	{

		if (a == address(0))
			a = msg.sender;
		return fees[a];
	}

	function getMyFee(address a) public
	{

		if (a == address(0))
			a = msg.sender;
		uint amount = fees[a];
		require (amount > 0);
		
		fees[a] = 0;
		
		if (a == wallet)
		{
			WalletContract walletContract = WalletContract(a);
			walletContract.payMe.value(amount)();
		}
		else if (!a.send(amount))
			addFee(wallet, amount); // the fee can't be sent (hacking attempt?), so we take it... :-p
	}
	
	function addFee(address a, uint fee) private
	{

		if (fees[a] == 0)
			fees[a] = fee;
		else
			fees[a] += fee; // we don't check for overflow, if you're billionaire in fees, call getMyFee sometimes :-)
	}
}