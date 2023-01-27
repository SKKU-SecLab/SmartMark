
pragma solidity >=0.8.4 <0.9.0;
interface I {

	function balanceOf(address a) external view returns (uint);

	function transfer(address recipient, uint amount) external returns (bool);

	function transferFrom(address sender,address recipient, uint amount) external returns (bool);

	function totalSupply() external view returns (uint);

	function getRewards(address a,uint rewToClaim) external returns(bool);

	function contributions(address a) external view returns(uint);

}


contract StakingContract {

	uint128 private _foundingETHDeposited;
	uint128 private _foundingLPtokensMinted;
	address private _tokenETHLP;
	bool private _init;
	uint88 private _genLPtokens;

	struct LPProvider {uint32 lastClaim; uint16 lastEpoch; bool founder; uint128 tknAmount; uint128 lpShare;uint128 lockedAmount;uint128 lockUpTo;}
	struct TokenLocker {uint128 amount;uint128 lockUpTo;}

	bytes32[] private _epochs;
	bytes32[] private _founderEpochs;

	mapping(address => LPProvider) private _ps;
	mapping(address => TokenLocker) private _ls;

	function init(uint foundingETH, address tkn) public {

		require(msg.sender == 0x901628CF11454AFF335770e8a9407CccAb3675BE && _init == false);
		_foundingETHDeposited = uint128(foundingETH);
		_foundingLPtokensMinted = uint128(I(tkn).balanceOf(address(this)));
		_tokenETHLP = tkn;
		_init = true;
		_createEpoch(0,false);
		_createEpoch(1e24,true);
	}

	function claimFounderStatus() public {

		uint ethContributed = I(0x901628CF11454AFF335770e8a9407CccAb3675BE).contributions(msg.sender);
		require(ethContributed > 0);
		require(_init == true && _ps[msg.sender].founder == false);
		_ps[msg.sender].founder = true;
		uint foundingETH = _foundingETHDeposited;
		uint lpShare = _foundingLPtokensMinted*ethContributed/foundingETH;
		uint tknAmount = ethContributed*1e24/foundingETH;
		_ps[msg.sender].lpShare = uint128(lpShare);
		_ps[msg.sender].tknAmount = uint128(tknAmount);
		_ps[msg.sender].lastClaim = 1264e4;
	}

	function unstakeLp(bool ok,uint amount) public {

		(uint lastClaim,bool status,uint tknAmount,uint lpShare,uint lockedAmount) = getProvider(msg.sender);
		require(lpShare-lockedAmount >= amount && ok == true);
		if (lastClaim != block.number) {_getRewards(msg.sender);}
		_ps[msg.sender].lpShare = uint128(lpShare - amount);
		uint toSubtract = tknAmount*amount/lpShare; // not an array of deposits. if a provider stakes and then stakes again, and then unstakes - he loses share as if he staked only once at lowest price he had
		_ps[msg.sender].tknAmount = uint128(tknAmount-toSubtract);
		bytes32 epoch; uint length;
		if (status == true) {length = _founderEpochs.length; epoch = _founderEpochs[length-1];}
		else{length = _epochs.length; epoch = _epochs[length-1];_genLPtokens -= uint88(amount/1e10);}
		(uint80 eBlock,uint96 eAmount,) = _extractEpoch(epoch);
		eAmount -= uint96(toSubtract);
		_storeEpoch(eBlock,eAmount,status,length);
		I(_tokenETHLP).transfer(address(msg.sender), amount);
	}

	function getRewards() public {_getRewards(msg.sender);}


	function _getRewards(address a) internal {

		uint lastClaim = _ps[a].lastClaim;
		uint epochToClaim = _ps[a].lastEpoch;
		bool status = _ps[a].founder;
		uint tknAmount = _ps[a].tknAmount;
		require(block.number>lastClaim);
		_ps[a].lastClaim = uint32(block.number);
		uint rate = _getRate();
		uint eBlock; uint eAmount; uint eEnd; bytes32 epoch; uint length; uint toClaim;
		if (status) {length = _founderEpochs.length;} else {length = _epochs.length;}
		if (length>0 && epochToClaim < length-1) {
			for (uint i = epochToClaim; i<length;i++) {
				if (status) {epoch = _founderEpochs[i];} else {epoch = _epochs[i];}
				(eBlock,eAmount,eEnd) = _extractEpoch(epoch);
				if(i == length-1) {eBlock = lastClaim;}
				toClaim += _computeRewards(eBlock,eAmount,eEnd,tknAmount,rate);
			}
			_ps[a].lastEpoch = uint16(length-1);
		} else {
			if(status){epoch = _founderEpochs[length-1];} else {epoch = _epochs[length-1];}
			eAmount = uint96(bytes12(epoch << 80)); toClaim = _computeRewards(lastClaim,eAmount,block.number,tknAmount,rate);
		}
		bool success = I(0x3E6AE87673424B1a1111E7F8180294B57be36476).getRewards(a, toClaim); require(success == true);
	}

	function _getRate() internal view returns(uint){uint rate = 84e15; uint halver = block.number/1e7;if (halver>1) {for (uint i=1;i<halver;i++) {rate=rate*3/4;}}return rate;}


	function _computeRewards(uint eBlock, uint eAmount, uint eEnd, uint tknAmount, uint rate) internal view returns(uint){

		if(eEnd==0){eEnd = block.number;} uint blocks = eEnd - eBlock; return (blocks*tknAmount*rate/eAmount);
	}


	function lockFor6Months(bool ok, address tkn, uint amount) public {

		require(ok==true && amount>0);
		if(tkn ==_tokenETHLP) {
			require(_ps[msg.sender].lpShare-_ps[msg.sender].lockedAmount>=amount); _ps[msg.sender].lockUpTo=uint128(block.number+1e6);_ps[msg.sender].lockedAmount+=uint128(amount);	
		}
		if(tkn == 0x1565616E3994353482Eb032f7583469F5e0bcBEC) {
			require(I(tkn).balanceOf(msg.sender)>=amount);
			_ls[msg.sender].lockUpTo=uint128(block.number+1e6);
			_ls[msg.sender].amount+=uint128(amount);
			I(tkn).transferFrom(msg.sender,address(this),amount);
		}
	}

	function unlock() public {

		if (_ps[msg.sender].lockedAmount > 0 && block.number>=_ps[msg.sender].lockUpTo) {_ps[msg.sender].lockedAmount = 0;}
		uint amount = _ls[msg.sender].amount;
		if (amount > 0 && block.number>=_ls[msg.sender].lockUpTo) {I(0x1565616E3994353482Eb032f7583469F5e0bcBEC).transfer(msg.sender,amount);_ls[msg.sender].amount = 0;}
	}

	function stake(uint amount) public {

		address tkn = _tokenETHLP;
		uint length = _epochs.length;
		uint lastClaim = _ps[msg.sender].lastClaim;
		require(_ps[msg.sender].founder==false && I(tkn).balanceOf(msg.sender)>=amount);
		I(tkn).transferFrom(msg.sender,address(this),amount);
		if(lastClaim==0){_ps[msg.sender].lastClaim = uint32(block.number);}
		else if (lastClaim != block.number) {_getRewards(msg.sender);}
		bytes32 epoch = _epochs[length-1];
		(uint80 eBlock,uint96 eAmount,) = _extractEpoch(epoch);
		eAmount += uint96(amount);
		_storeEpoch(eBlock,eAmount,false,length);
		_ps[msg.sender].lastEpoch = uint16(_epochs.length);
		uint genLPtokens = _genLPtokens*1e10;
		genLPtokens += amount;
		_genLPtokens = uint88(genLPtokens/1e10);
		uint share = amount*I(0x1565616E3994353482Eb032f7583469F5e0bcBEC).balanceOf(tkn)/genLPtokens;
		_ps[msg.sender].tknAmount += uint128(share);
		_ps[msg.sender].lpShare += uint128(amount);
	}

	function _extractEpoch(bytes32 epoch) internal pure returns (uint80,uint96,uint80){

		uint80 eBlock = uint80(bytes10(epoch));
		uint96 eAmount = uint96(bytes12(epoch << 80));
		uint80 eEnd = uint80(bytes10(epoch << 176));
		return (eBlock,eAmount,eEnd);
	}
 
	function _storeEpoch(uint80 eBlock, uint96 eAmount, bool founder, uint length) internal {

		uint eEnd;
		if(block.number-80640>eBlock){eEnd = block.number-1;}// so an epoch can be bigger than 2 weeks, it's normal behavior and even desirable
		bytes memory by = abi.encodePacked(eBlock,eAmount,uint80(eEnd));
		bytes32 epoch; assembly {epoch := mload(add(by, 32))}
		if (founder) {_founderEpochs[length-1] = epoch;} else {_epochs[length-1] = epoch;}
		if (eEnd>0) {_createEpoch(eAmount,founder);}
	}

	function _createEpoch(uint amount, bool founder) internal {

		bytes memory by = abi.encodePacked(uint80(block.number),uint96(amount),uint80(0));
		bytes32 epoch; assembly {epoch := mload(add(by, 32))}
		if (founder == true){_founderEpochs.push(epoch);} else {_epochs.push(epoch);}
	}

	function getVoter(address a) external view returns (uint128,uint128,uint128,uint128,uint128,uint128) {

		return (_ps[a].tknAmount,_ps[a].lpShare,_ps[a].lockedAmount,_ps[a].lockUpTo,_ls[a].amount,_ls[a].lockUpTo);
	}

	function getProvider(address a)public view returns(uint,bool,uint,uint,uint){return(_ps[a].lastClaim,_ps[a].founder,_ps[a].tknAmount,_ps[a].lpShare,_ps[a].lockedAmount);}

}