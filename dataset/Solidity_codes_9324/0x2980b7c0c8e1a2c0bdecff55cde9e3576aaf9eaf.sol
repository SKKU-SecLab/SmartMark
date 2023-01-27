
pragma solidity ^ 0.6.6;

contract ColorToken{


	mapping(address => uint256) public balances;
	mapping(address => uint256) public red;
	mapping(address => uint256) public green;
	mapping(address => uint256) public blue;

	uint public _totalSupply;

	mapping(address => mapping(address => uint)) approvals;

	event Transfer(
		address indexed from,
		address indexed to,
		uint256 amount,
		bytes data
	);
	
	function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

		return balances[_owner];
	}

	function addColor(address addr, uint color, uint _red, uint _green, uint _blue) internal {

		red[addr] += _red * color;
		green[addr] += _green * color;
		blue[addr] += _blue * color;
	}


  	function RGB_Ratio() public view returns(uint,uint,uint){

  		return RGB_Ratio(msg.sender);
  	}

  	function RGB_Ratio(address addr) public view returns(uint,uint,uint){

  		uint coloredWeight = balances[addr];
  		if (coloredWeight==0){
  			return (0,0,0);
  		}
  		return ( red[addr]/coloredWeight, green[addr]/coloredWeight, blue[addr]/coloredWeight);
  	}

  	function RGB_scale(address addr, uint numerator, uint denominator) internal view returns(uint,uint,uint){

		return (red[addr] * numerator / denominator, green[addr] * numerator / denominator, blue[addr] * numerator / denominator);
	}

	function transfer(address _to, uint _value, bytes memory _data) public virtual returns (bool) {

		if( isContract(_to) ){
			return transferToContract(_to, _value, _data);
		}else{
			return transferToAddress(_to, _value, _data);
		}
	}
	
	function transfer(address _to, uint _value) public virtual returns (bool) {

		bytes memory empty;
		if(isContract(_to)){
			return transferToContract(_to, _value, empty);
		}else{
			return transferToAddress(_to, _value, empty);
		}
	}


	function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool) {

		moveTokens(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool) {

		moveTokens(msg.sender, _to, _value);
		ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	function moveTokens(address _from, address _to, uint _amount) internal virtual{

		(uint red_ratio, uint green_ratio, uint blue_ratio) = RGB_scale( _from, _amount, balances[_from] );
		red[_from] -= red_ratio;
		green[_from] -= green_ratio;
		blue[_from] -= blue_ratio;
		red[_to] += red_ratio;
		green[_to] += green_ratio;
		blue[_to] += blue_ratio;

		balances[_from] -= _amount;
		balances[_to] += _amount;
	}

    function allowance(address src, address guy) public view returns (uint) {

        return approvals[src][guy];
    }
  	
    function transferFrom(address src, address dst, uint amount) public returns (bool){

    	address sender = msg.sender;
        require(approvals[src][sender] >=  amount);
        if (src != sender) {
            approvals[src][sender] -=  amount;
        }
		moveTokens(src,dst,amount);

        return true;
    }
    event Approval(address indexed src, address indexed guy, uint amount);
    function approve(address guy, uint amount) public returns (bool) {

    	address sender = msg.sender;
        approvals[sender][guy] = amount;

        emit Approval( sender, guy, amount );

        return true;
    }

    function isContract(address _addr) public view returns (bool is_contract) {

		uint length;
		assembly {
			length := extcodesize(_addr)
		}
		if(length>0) {
			return true;
		}else {
			return false;
		}
	}
}

contract PiZZa is ColorToken{

	uint256 constant scaleFactor = 0x10000000000000000;
	address payable address0 = address(0);

    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;

	string constant public name = "Pizza Token";
	string constant public symbol = "PiZZa";
	uint8 constant public decimals = 18;

	mapping(address => uint256) public average_ethSpent;
	mapping(address => uint256) public average_buyInTimeSum;
	mapping(address => uint256) public resolveWeight;

	mapping(address => int256) public payouts;

	uint256 public dissolvingResolves;

	uint public sumOfInputETH;
	uint public sumOfInputTime;
	uint public sumOfOutputETH;
	uint public sumOfOutputTime;

	int256 public earningsOffset;

	uint256 public earningsPerResolve;

	Crust public resolveToken;

	constructor() public{
		resolveToken = new Crust( address(this) );
	}

	function fluxFee(uint paidAmount) public view returns (uint fee) {

		uint totalResolveSupply = resolveToken.totalSupply() - resolveToken.balanceOf( address(0) );
		if ( dissolvingResolves == 0 )
			return 0;

		return paidAmount * ( totalResolveSupply - dissolvingResolves ) / totalResolveSupply * sumOfOutputETH / sumOfInputETH;
	}

	event Reinvest( address indexed addr, uint256 reinvested, uint256 dissolved, uint256 bonds, uint256 resolveTax);
	function reinvestEarnings(uint amountFromEarnings) public returns(uint,uint){

		address sender = msg.sender;
		uint upScaleDivs = (uint)((int256)( earningsPerResolve * resolveWeight[sender] ) - payouts[sender]);
		uint totalEarnings = upScaleDivs / scaleFactor;//resolveEarnings(sender);
		require(amountFromEarnings <= totalEarnings, "the amount exceeds total earnings");
		uint oldWeight = resolveWeight[sender];
		resolveWeight[sender] = oldWeight * (totalEarnings - amountFromEarnings) / totalEarnings;
		uint weightDiff = oldWeight - resolveWeight[sender];
		resolveToken.transfer( address0, weightDiff );
		dissolvingResolves -= weightDiff;
		
		int withdrawnEarnings = (int)(upScaleDivs * amountFromEarnings / totalEarnings) - (int)(weightDiff*earningsPerResolve);
		payouts[sender] += withdrawnEarnings;
		earningsOffset += withdrawnEarnings;

		uint value_ = (uint) (amountFromEarnings);

		if (value_ < 0.000001 ether)
			revert();

		uint fee = fluxFee(value_);

		uint numEther = value_ - fee;

		average_ethSpent[sender] += numEther;
		average_buyInTimeSum[sender] += now * scaleFactor * numEther;
		sumOfInputETH += numEther;
		sumOfInputTime += now * scaleFactor * numEther;

		uint createdBonds = ethereumToTokens_(numEther);
		uint[] memory RGB = new uint[](3);
  		(RGB[0], RGB[1], RGB[2]) = RGB_Ratio(sender);
		
		addColor(sender, createdBonds, RGB[0], RGB[1], RGB[2]);

		uint resolveFee;

		if ( dissolvingResolves > 0 ) {
			resolveFee = fee * scaleFactor;

			uint rewardPerResolve = resolveFee / dissolvingResolves;

			earningsPerResolve += rewardPerResolve;
		}

		_totalSupply += createdBonds;

		balances[sender] += createdBonds;

		emit Reinvest(sender, value_, weightDiff, createdBonds, resolveFee);
		return (createdBonds, weightDiff);
	}

	function sellAllBonds() public returns(uint returned_eth, uint returned_resolves, uint initialInput_ETH){

		return sell( balanceOf(msg.sender) );
	}

	function sellBonds(uint amount) public returns(uint returned_eth, uint returned_resolves, uint initialInput_ETH){

		uint balance = balanceOf(msg.sender);
		require(balance >= amount, "Amount is more than balance");
		( returned_eth, returned_resolves, initialInput_ETH ) = sell(amount);
		return (returned_eth, returned_resolves, initialInput_ETH);
	}

	function getMeOutOfHere() public {

		sellAllBonds();
		withdraw( resolveEarnings(msg.sender) );
	}

	function fund() payable public returns(uint createdBonds){

		uint[] memory RGB = new uint[](3);
  		(RGB[0], RGB[1], RGB[2]) = RGB_Ratio(msg.sender);
		return buy(msg.sender, RGB[0], RGB[1], RGB[2]);
  	}
 
	function resolveEarnings(address _owner) public view returns (uint256 amount) {

		return (uint256) ((int256)(earningsPerResolve * resolveWeight[_owner]) - payouts[_owner]) / scaleFactor;
	}

	event Buy( address indexed addr, uint256 spent, uint256 bonds, uint256 resolveTax);
	function buy(address addr, uint _red, uint _green, uint _blue) public payable returns(uint createdBonds){

		if(_red>1e18) _red = 1e18;
		if(_green>1e18) _green = 1e18;
		if(_blue>1e18) _blue = 1e18;
		
		if ( msg.value < 0.000001 ether )
			revert();

		uint fee = fluxFee(msg.value);

		uint numEther = msg.value - fee;

		uint currentTime = now;
		average_ethSpent[addr] += numEther;
		average_buyInTimeSum[addr] += currentTime * scaleFactor * numEther;
		sumOfInputETH += numEther;
		sumOfInputTime += currentTime * scaleFactor * numEther;

		createdBonds = ethereumToTokens_(numEther);
		addColor(addr, createdBonds, _red, _green, _blue);

		_totalSupply += createdBonds;

		balances[addr] += createdBonds;

		uint resolveFee;
		if (dissolvingResolves > 0) {
			resolveFee = fee * scaleFactor;

			uint rewardPerResolve = resolveFee/dissolvingResolves;

			earningsPerResolve += rewardPerResolve;
		}
		emit Buy( addr, msg.value, createdBonds, resolveFee);
		return createdBonds;
	}

	function avgHodl() public view returns(uint hodlTime){

		return now - (sumOfInputTime - sumOfOutputTime) / (sumOfInputETH - sumOfOutputETH) / scaleFactor;
	}

	function getReturnsForBonds(address addr, uint bondsReleased) public view returns(uint etherValue, uint mintedResolves, uint new_releaseTimeSum, uint new_releaseAmount, uint initialInput_ETH){

		uint output_ETH = tokensToEthereum_(bondsReleased);
		uint input_ETH = average_ethSpent[addr] * bondsReleased / balances[addr];
		uint buyInTime = average_buyInTimeSum[addr] / average_ethSpent[addr];
		uint cashoutTime = now * scaleFactor - buyInTime;
		uint new_sumOfOutputTime = sumOfOutputTime + average_buyInTimeSum[addr] * bondsReleased / balances[addr];
		uint new_sumOfOutputETH = sumOfOutputETH + input_ETH; //It's based on the original ETH, so that's why input_ETH is used. Not output_ETH.
		uint averageHoldingTime = now * scaleFactor - ( sumOfInputTime - sumOfOutputTime ) / ( sumOfInputETH - sumOfOutputETH );
		return (output_ETH, input_ETH * cashoutTime / averageHoldingTime * input_ETH / output_ETH, new_sumOfOutputTime, new_sumOfOutputETH, input_ETH);
	}

	event Sell( address indexed addr, uint256 bondsSold, uint256 cashout, uint256 resolves, uint256 resolveTax, uint256 initialCash);
	function sell(uint256 amount) internal returns(uint eth, uint resolves, uint initialInput){

		address payable sender = msg.sender;

		uint[] memory UINTs = new uint[](5);
		(
		UINTs[0]/*ether before fee*/,
		UINTs[1]/*minted resolves*/,
		UINTs[2]/*new_sumOfOutputTime*/,
		UINTs[3]/*new_sumOfOutputETH*/,
		UINTs[4]/*initialInput_ETH*/) = getReturnsForBonds(sender, amount);

	    uint fee = fluxFee(UINTs[0]/*ether before fee*/);

		uint[] memory RGB = new uint[](3);
  		(RGB[0], RGB[1], RGB[2]) = RGB_Ratio(sender);
		resolveToken.mint(sender, UINTs[1]/*minted resolves*/, RGB[0], RGB[1], RGB[2]);

		sumOfOutputTime = UINTs[2]/*new_sumOfOutputTime*/;
		sumOfOutputETH = UINTs[3] /*new_sumOfOutputETH*/;

		average_ethSpent[sender] = average_ethSpent[sender] * ( balances[sender] - amount) / balances[sender];
		average_buyInTimeSum[sender] = average_buyInTimeSum[sender] * (balances[sender] - amount) / balances[sender];

	    uint numEthers = UINTs[0]/*ether before fee*/ - fee;

		_totalSupply -= amount;


	    thinColor( sender, balances[sender] - amount, balances[sender]);
	    balances[sender] -= amount;

		uint resolveFee;
		if ( dissolvingResolves > 0 ){
			resolveFee = fee * scaleFactor;

			uint rewardPerResolve = resolveFee/dissolvingResolves;

			earningsPerResolve += rewardPerResolve;
		}
		
		
		(bool success, ) = sender.call{value:numEthers}("");
        require(success, "Transfer failed.");

		emit Sell( sender, amount, numEthers, UINTs[1]/*minted resolves*/, resolveFee, UINTs[4] /*initialInput_ETH*/);
		return (numEthers, UINTs[1]/*minted resolves*/, UINTs[4] /*initialInput_ETH*/);
	}

	function thinColor(address addr, uint newWeight, uint oldWeight) internal{

  		(red[addr], green[addr], blue[addr]) = RGB_scale( addr, newWeight, oldWeight);
  	}

	event StakeResolves( address indexed addr, uint256 amountStaked, bytes _data );
	function tokenFallback(address from, uint value, bytes calldata _data) external{

		if(msg.sender == address(resolveToken) ){
			resolveWeight[from] += value;
			dissolvingResolves += value;

			int payoutDiff = (int256) (earningsPerResolve * value);
			payouts[from] += payoutDiff;
			earningsOffset += payoutDiff;

			emit StakeResolves(from, value, _data);
		}else{
			revert("no want");
		}
	}

	event Withdraw( address indexed addr, uint256 earnings, uint256 dissolve );
	function withdraw(uint amount) public returns(uint){

		address payable sender = msg.sender;
		uint upScaleDivs = (uint)((int256)( earningsPerResolve * resolveWeight[sender] ) - payouts[sender]);
		uint totalEarnings = upScaleDivs / scaleFactor;
		require( amount <= totalEarnings && amount > 0 );
		uint oldWeight = resolveWeight[sender];
		resolveWeight[sender] = oldWeight * ( totalEarnings - amount ) / totalEarnings;
		uint weightDiff = oldWeight - resolveWeight[sender];
		resolveToken.transfer( address0, weightDiff);
		dissolvingResolves -= weightDiff;
		
		int withdrawnEarnings = (int)(upScaleDivs * amount / totalEarnings) - (int)(weightDiff*earningsPerResolve);
		payouts[sender] += withdrawnEarnings;
		earningsOffset += withdrawnEarnings;


		(bool success, ) = sender.call{value: amount}("");
        require(success, "Transfer failed.");

		emit Withdraw( sender, amount, weightDiff);
		return weightDiff;
	}

	event PullResolves( address indexed addr, uint256 pulledResolves, uint256 forfeiture);
	function pullResolves(uint amount) public returns (uint forfeiture){

		address sender = msg.sender;
		uint resolves = resolveWeight[ sender ];
		require(amount <= resolves && amount > 0);
		require(amount < dissolvingResolves);//"you can't forfeit the last resolve"

		uint yourTotalEarnings = (uint)((int256)(resolves * earningsPerResolve) - payouts[sender]);
		uint forfeitedEarnings = yourTotalEarnings * amount / resolves;

		payouts[sender] += (int256)(forfeitedEarnings) - (int256)(earningsPerResolve * amount);

		resolveWeight[sender] -= amount;
		dissolvingResolves -= amount;
		earningsPerResolve += forfeitedEarnings / dissolvingResolves;

		resolveToken.transfer( sender, amount );
		emit PullResolves( sender, amount, forfeitedEarnings / scaleFactor);
		return forfeitedEarnings / scaleFactor;
	}

	function moveTokens(address _from, address _to, uint _amount) internal override{

		uint totalBonds = balances[_from];
		require(_amount <= totalBonds && _amount > 0);
		uint ethSpent = average_ethSpent[_from] * _amount / totalBonds;
		uint buyInTimeSum = average_buyInTimeSum[_from] * _amount / totalBonds;
		average_ethSpent[_from] -= ethSpent;
		average_buyInTimeSum[_from] -= buyInTimeSum;
		balances[_from] -= _amount;
		average_ethSpent[_to] += ethSpent;
		average_buyInTimeSum[_to] += buyInTimeSum;
		balances[_to] += _amount;
		super.moveTokens(_from, _to, _amount);
	}

    function buyPrice()
        public 
        view 
        returns(uint256)
    {

        if(_totalSupply == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = fluxFee(_ethereum  );
            uint256 _taxedEthereum = _ethereum + _dividends;
            return _taxedEthereum;
        }
    }

    function sellPrice() 
        public 
        view 
        returns(uint256)
    {

        if(_totalSupply == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = fluxFee(_ethereum  );
            uint256 _taxedEthereum = subtract(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        view 
        returns(uint256)
    {

        uint256 _dividends = fluxFee(_ethereumToSpend);
        uint256 _taxedEthereum = subtract(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        
        return _amountOfTokens;
    }
    

    function calculateEthereumReceived(uint256 _tokensToSell) 
        public 
        view 
        returns(uint256)
    {

        require(_tokensToSell <= _totalSupply);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = fluxFee(_ethereum );
        uint256 _taxedEthereum = subtract(_ethereum, _dividends);
        return _taxedEthereum;
    }

    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {

        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = 
         (
            (
                subtract(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(_totalSupply**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*_totalSupply)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(_totalSupply)
        ;
  
        return _tokensReceived;
    }

    function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {


        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (_totalSupply + 1e18);
        uint256 _etherReceived =
        (
            subtract(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }

    function sqrt(uint x) internal pure returns (uint y) {

        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function subtract(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }
}

abstract contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external virtual;
}

contract Crust is ColorToken{


	string public name = "Color";
    string public symbol = "`c";
    uint8 constant public decimals = 18;
	address public hourglass;

	constructor(address _hourglass) public{
		hourglass = _hourglass;
	}

	modifier hourglassOnly{

	  require(msg.sender == hourglass);
	  _;
    }

	event Transfer(
		address indexed from,
		address indexed to,
		uint256 amount,
		bytes data
	);

	event Mint(
		address indexed addr,
		uint256 amount
	);

	function mint(address _address, uint _value, uint _red, uint _green, uint _blue) external hourglassOnly(){

		balances[_address] += _value;
		_totalSupply += _value;
		addColor(_address, _value, _red, _green, _blue);
		emit Mint(_address, _value);
	}
}