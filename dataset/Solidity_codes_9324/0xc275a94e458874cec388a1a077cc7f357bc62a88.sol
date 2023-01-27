

pragma solidity 0.5.15;



interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



interface IShardGovernor {

	function claimInitialShotgun(
		address payable initialClaimantAddress,
		uint initialClaimantBalance
	) external payable returns (bool);


	function transferShards(
		address recipient,
		uint amount
	) external;


	function enactShotgun() external;

	function offererAddress() external view returns (address);

	function checkLock() external view returns (bool);

	function checkShotgunState() external view returns (bool);

	function getNftRegistryAddress() external view returns (address);

	function getNftTokenIds() external view returns (uint256[] memory);

	function getOwner() external view returns (address);

}



interface IShardRegistry {

	function mint(address, uint256) external returns (bool);

	function pause() external;

	function unpause() external;

	function burn(uint256) external;

	function transfer(address, uint256) external returns (bool);

	function cap() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function totalSupply() external view returns (uint256);

}


contract ShotgunClause {


	using SafeMath for uint256;

	IShardGovernor private _shardGovernor;
	IShardRegistry private _shardRegistry;

	enum ClaimWinner { None, Claimant, Counterclaimant }
	ClaimWinner private _claimWinner = ClaimWinner.None;

	uint private _deadlineTimestamp;
	uint private _initialOfferInWei;
	uint private _pricePerShardInWei;
	address payable private _initialClaimantAddress;
	uint private _initialClaimantBalance;
	bool private _shotgunEnacted = false;
	uint private _counterWeiContributed;
	address[] private _counterclaimants;
	mapping(address => uint) private _counterclaimContribs;

	event Countercommit(address indexed committer, uint indexed weiAmount);
	event EtherCollected(address indexed collector, uint indexed weiAmount);

	constructor(
		address payable initialClaimantAddress,
		uint initialClaimantBalance,
		address shardRegistryAddress
	) public payable {
		_shardGovernor = IShardGovernor(msg.sender);
		_shardRegistry = IShardRegistry(shardRegistryAddress);
		_deadlineTimestamp = now.add(1 * 14 days);
		_initialClaimantAddress = initialClaimantAddress;
		_initialClaimantBalance = initialClaimantBalance;
		_initialOfferInWei = msg.value;
		_pricePerShardInWei = (_initialOfferInWei.mul(10**18)).div(_shardRegistry.cap().sub(_initialClaimantBalance));
		_claimWinner = ClaimWinner.Claimant;
	}

	function counterCommitEther() external payable {

		require(
			_shardRegistry.balanceOf(msg.sender) > 0,
			"[counterCommitEther] Account does not own Shards"
		);
		require(
			msg.value > 0,
			"[counterCommitEther] Ether is required"
		);
		require(
			_initialClaimantAddress != address(0),
			"[counterCommitEther] Initial claimant does not exist"
		);
		require(
			msg.sender != _initialClaimantAddress,
			"[counterCommitEther] Initial claimant cannot countercommit"
		);
		require(
			!_shotgunEnacted,
			"[counterCommitEther] Shotgun already enacted"
		);
		require(
			now < _deadlineTimestamp,
			"[counterCommitEther] Deadline has expired"
		);
		require(
			msg.value + _counterWeiContributed <= getRequiredWeiForCounterclaim(),
			"[counterCommitEther] Ether exceeds goal"
		);
		if (_counterclaimContribs[msg.sender] == 0) {
			_counterclaimants.push(msg.sender);
		}
		_counterclaimContribs[msg.sender] = _counterclaimContribs[msg.sender].add(msg.value);
		_counterWeiContributed = _counterWeiContributed.add(msg.value);
		emit Countercommit(msg.sender, msg.value);
		if (_counterWeiContributed == getRequiredWeiForCounterclaim()) {
			_claimWinner = ClaimWinner.Counterclaimant;
			enactShotgun();
		}
	}

	function collectEtherProceeds(uint balance, address payable caller) external {

		require(
			msg.sender == address(_shardRegistry),
			"[collectEtherProceeds] Caller not authorized"
		);
		if (_claimWinner == ClaimWinner.Claimant && caller != _initialClaimantAddress) {
			uint weiProceeds = (_pricePerShardInWei.mul(balance)).div(10**18);
			weiProceeds = weiProceeds.add(_counterclaimContribs[caller]);
			_counterclaimContribs[caller] = 0;
			(bool success, ) = address(caller).call.value(weiProceeds)("");
			require(success, "[collectEtherProceeds] Transfer failed.");
			emit EtherCollected(caller, weiProceeds);
		} else if (_claimWinner == ClaimWinner.Counterclaimant && caller == _initialClaimantAddress) {
			uint amount = (_pricePerShardInWei.mul(_initialClaimantBalance)).div(10**18);
			amount = amount.add(_initialOfferInWei);
			_initialClaimantBalance = 0;
			(bool success, ) = address(caller).call.value(amount)("");
			require(success, "[collectEtherProceeds] Transfer failed.");
			emit EtherCollected(caller, amount);
		}
	}

	function collectShardProceeds() external {

		require(
			_shotgunEnacted && _claimWinner == ClaimWinner.Counterclaimant,
			"[collectShardProceeds] Shotgun has not been enacted or invalid winner"
		);
		require(
			_counterclaimContribs[msg.sender] != 0,
			"[collectShardProceeds] Account has not participated in counterclaim"
		);
		uint proportionContributed = (_counterclaimContribs[msg.sender].mul(10**18)).div(_counterWeiContributed);
		_counterclaimContribs[msg.sender] = 0;
		uint shardsToReceive = (proportionContributed.mul(_initialClaimantBalance)).div(10**18);
		_shardGovernor.transferShards(msg.sender, shardsToReceive);
	}

	function deadlineTimestamp() external view returns (uint256) {

		return _deadlineTimestamp;
	}

	function shotgunEnacted() external view returns (bool) {

		return _shotgunEnacted;
	}

	function initialClaimantAddress() external view returns (address) {

		return _initialClaimantAddress;
	}

	function initialClaimantBalance() external view returns (uint) {

		return _initialClaimantBalance;
	}

	function initialOfferInWei() external view returns (uint256) {

		return _initialOfferInWei;
	}

	function pricePerShardInWei() external view returns (uint256) {

		return _pricePerShardInWei;
	}

	function claimWinner() external view returns (ClaimWinner) {

		return _claimWinner;
	}

	function counterclaimants() external view returns (address[] memory) {

		return _counterclaimants;
	}

	function getCounterclaimantContribution(address counterclaimant) external view returns (uint) {

		return _counterclaimContribs[counterclaimant];
	}

	function counterWeiContributed() external view returns (uint) {

		return _counterWeiContributed;
	}

	function getContractBalance() external view returns (uint) {

		return address(this).balance;
	}

	function shardGovernor() external view returns (address) {

		return address(_shardGovernor);
	}

	function getRequiredWeiForCounterclaim() public view returns (uint) {

		return (_pricePerShardInWei.mul(_initialClaimantBalance)).div(10**18);
	}

	function enactShotgun() public {

		require(
			!_shotgunEnacted,
			"[enactShotgun] Shotgun already enacted"
		);
		require(
			_claimWinner == ClaimWinner.Counterclaimant ||
			(_claimWinner == ClaimWinner.Claimant && now > _deadlineTimestamp),
			"[enactShotgun] Conditions not met to enact Shotgun Clause"
		);
		_shotgunEnacted = true;
		_shardGovernor.enactShotgun();
	}
}



interface IShardOffering {

	function claimShards(address) external;

	function wrapUpOffering() external;

	function hasClaimedShards(address) external view returns (bool);

	function offeringCompleted() external view returns (bool);

	function offeringDeadline() external view returns (uint);

	function getSubEther(address) external view returns (uint);

	function getSubShards(address) external view returns (uint);

	function offererShardAmount() external view returns (uint);

	function totalShardsClaimed() external view returns (uint);

	function liqProviderCutInShards() external view returns (uint);

	function artistCutInShards() external view returns (uint);

}




interface IFactory {


	function newSet(
		uint liqProviderCutInShards,
		uint artistCutInShards,
		uint pricePerShardInWei,
		uint shardAmountOffered,
		uint offeringDeadline,
		uint256 cap,
		string calldata name,
		string calldata symbol,
		bool shotgunDisabled
	) external returns (IShardRegistry, IShardOffering);

}


interface IUniswapExchange {

	function removeLiquidity(
		uint256 uniTokenAmount,
		uint256 minEth,
		uint256 minTokens,
		uint256 deadline
	) external returns(
		uint256, uint256
	);


	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns (bool);

}


contract ShardGovernor is IERC721Receiver {


  using SafeMath for uint256;

	bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

	IShardRegistry private _shardRegistry;
	IShardOffering private _shardOffering;
	ShotgunClause private _currentShotgunClause;
	address payable private _offererAddress;
	address[] private _nftRegistryAddresses;
	address payable private _niftexWalletAddress;
	address payable private _artistWalletAddress;
	uint256[] private _tokenIds;

	enum ClaimWinner { None, Claimant, Counterclaimant }
	address[] private _shotgunAddressArray;
	mapping(address => uint) private _shotgunMapping;
	uint private _shotgunCounter;

	event NewShotgun(address indexed shotgun);
	event ShardsClaimed(address indexed claimant, uint indexed shardAmount);
	event NftRedeemed(address indexed redeemer);
	event ShotgunEnacted(address indexed enactor);
	event ShardsCollected(address indexed collector, uint indexed shardAmount, address indexed shotgun);

  constructor(
  	address[] memory nftRegistryAddresses,
  	address payable offererAddress,
  	uint256[] memory tokenIds,
  	address payable niftexWalletAddress,
  	address payable artistWalletAddress
	) public {
		for (uint x = 0; x < tokenIds.length; x++) {
			require(
				IERC721(nftRegistryAddresses[x]).ownerOf(tokenIds[x]) == offererAddress,
				"Offerer is not owner of tokenId"
			);
		}

		_nftRegistryAddresses = nftRegistryAddresses;
		_niftexWalletAddress = niftexWalletAddress;
		_artistWalletAddress = artistWalletAddress;
		_tokenIds = tokenIds;
		_offererAddress = offererAddress;
	}

	function() external payable { }

	function deploySubcontracts(
		uint liqProviderCutInShards,
		uint artistCutInShards,
		uint pricePerShardInWei,
		uint shardAmountOffered,
		uint offeringDeadline,
		uint256 cap,
		string calldata name,
		string calldata symbol,
		bool shotgunDisabled,
		address factoryAddress
	) external {

		require(
			msg.sender == _niftexWalletAddress,
			"[deploySubcontracts] Unauthorized call"
		);

		require(
			address(_shardRegistry) == address(0) && address(_shardOffering) == address(0),
			"[deploySubcontracts] Contract(s) exist"
		);

		IFactory factory = IFactory(factoryAddress);
		(_shardRegistry, _shardOffering) = factory.newSet(
			liqProviderCutInShards,
			artistCutInShards,
			pricePerShardInWei,
			shardAmountOffered,
			offeringDeadline,
			cap,
			name,
			symbol,
			shotgunDisabled
		);
	}

	function checkOfferingAndIssue() external {

		require(
			_shardRegistry.totalSupply() != _shardRegistry.cap(),
			"[checkOfferingAndIssue] Shards have already been issued"
		);
		require(
			!_shardOffering.hasClaimedShards(msg.sender),
			"[checkOfferingAndIssue] You have already claimed your Shards"
		);
		require(
			_shardOffering.offeringCompleted() ||
			(now > _shardOffering.offeringDeadline() && !_shardOffering.offeringCompleted()),
			"Offering not completed or deadline not expired"
		);
		if (_shardOffering.offeringCompleted()) {
			if (_shardOffering.getSubEther(msg.sender) != 0) {
				_shardOffering.claimShards(msg.sender);
				uint subShards = _shardOffering.getSubShards(msg.sender);
				bool success = _shardRegistry.mint(msg.sender, subShards);
				require(success, "[checkOfferingAndIssue] Mint failed");
				emit ShardsClaimed(msg.sender, subShards);
			} else if (msg.sender == _offererAddress) {
				_shardOffering.claimShards(msg.sender);
				uint offShards = _shardOffering.offererShardAmount();
				bool success = _shardRegistry.mint(msg.sender, offShards);
				require(success, "[checkOfferingAndIssue] Mint failed");
				emit ShardsClaimed(msg.sender, offShards);
			}
		} else {
			_shardOffering.wrapUpOffering();
			uint remainingShards = _shardRegistry.cap().sub(_shardOffering.totalShardsClaimed());
			remainingShards = remainingShards
				.sub(_shardOffering.liqProviderCutInShards())
				.sub(_shardOffering.artistCutInShards());
			bool success = _shardRegistry.mint(_offererAddress, remainingShards);
			require(success, "[checkOfferingAndIssue] Mint failed");
			emit ShardsClaimed(msg.sender, remainingShards);
		}
	}


	function mintReservedShards(address _beneficiary) external {

		bool niftex;
		if (_beneficiary == _niftexWalletAddress) niftex = true;
		require(
			niftex ||
			_beneficiary == _artistWalletAddress,
			"[mintReservedShards] Unauthorized beneficiary"
		);
		require(
			!_shardOffering.hasClaimedShards(_beneficiary),
			"[mintReservedShards] Shards already claimed"
		);
		_shardOffering.claimShards(_beneficiary);
		uint cut;
		if (niftex) {
			cut = _shardOffering.liqProviderCutInShards();
		} else {
			cut = _shardOffering.artistCutInShards();
		}
		bool success = _shardRegistry.mint(_beneficiary, cut);
		require(success, "[mintReservedShards] Mint failed");
		emit ShardsClaimed(_beneficiary, cut);
	}

	function redeem() external {

		require(
			_shardRegistry.balanceOf(msg.sender) == _shardRegistry.cap(),
			"[redeem] Account does not own total amount of Shards outstanding"
		);
		require(
			msg.sender == tx.origin,
			"[redeem] Caller must be wallet"
		);
		for (uint x = 0; x < _tokenIds.length; x++) {
			IERC721(_nftRegistryAddresses[x]).safeTransferFrom(address(this), msg.sender, _tokenIds[x]);
		}
		emit NftRedeemed(msg.sender);
	}

	function claimInitialShotgun(
		address payable initialClaimantAddress,
		uint initialClaimantBalance
	) external payable returns (bool) {

		require(
			msg.sender == address(_shardRegistry),
			"[claimInitialShotgun] Caller not authorized"
		);
		_currentShotgunClause = (new ShotgunClause).value(msg.value)(
			initialClaimantAddress,
			initialClaimantBalance,
			address(_shardRegistry)
		);
		emit NewShotgun(address(_currentShotgunClause));
		_shardRegistry.pause();
		_shotgunAddressArray.push(address(_currentShotgunClause));
		_shotgunCounter++;
		_shotgunMapping[address(_currentShotgunClause)] = _shotgunCounter;
		return true;
	}

	function enactShotgun() external {

		require(
			_shotgunMapping[msg.sender] != 0,
			"[enactShotgun] Invalid Shotgun Clause"
		);
		ShotgunClause _shotgunClause = ShotgunClause(msg.sender);
		address initialClaimantAddress = _shotgunClause.initialClaimantAddress();
		if (uint(_shotgunClause.claimWinner()) == uint(ClaimWinner.Claimant)) {
			_shardRegistry.burn(_shardRegistry.balanceOf(initialClaimantAddress));
			for (uint x = 0; x < _tokenIds.length; x++) {
				IERC721(_nftRegistryAddresses[x]).safeTransferFrom(address(this), initialClaimantAddress, _tokenIds[x]);
			}
			_shardRegistry.unpause();
			emit ShotgunEnacted(address(_shotgunClause));
		} else if (uint(_shotgunClause.claimWinner()) == uint(ClaimWinner.Counterclaimant)) {
			_shardRegistry.unpause();
			emit ShotgunEnacted(address(_shotgunClause));
		}
	}

	function transferShards(address recipient, uint amount) external {

		require(
			_shotgunMapping[msg.sender] != 0,
			"[transferShards] Unauthorized caller"
		);
		bool success = _shardRegistry.transfer(recipient, amount);
		require(success, "[transferShards] Transfer failed");
		emit ShardsCollected(recipient, amount, msg.sender);
	}

	function pullLiquidity(
		address exchangeAddress,
		address liqProvAddress,
		uint256 uniTokenAmount,
		uint256 minEth,
		uint256 minTokens,
		uint256 deadline
	) public {

		require(msg.sender == _niftexWalletAddress, "[pullLiquidity] Unauthorized call");
		IUniswapExchange uniExchange = IUniswapExchange(exchangeAddress);
		uniExchange.transferFrom(liqProvAddress, address(this), uniTokenAmount);
		_shardRegistry.unpause();
		(uint ethAmount, uint tokenAmount) = uniExchange.removeLiquidity(uniTokenAmount, minEth, minTokens, deadline);
		(bool ethSuccess, ) = liqProvAddress.call.value(ethAmount)("");
		require(ethSuccess, "[pullLiquidity] ETH transfer failed.");
		bool tokenSuccess = _shardRegistry.transfer(liqProvAddress, tokenAmount);
		require(tokenSuccess, "[pullLiquidity] Token transfer failed");
		_shardRegistry.pause();
	}

	function checkShotgunState() external view returns (bool) {

		if (_shotgunCounter == 0) {
			return true;
		} else {
			ShotgunClause _shotgunClause = ShotgunClause(_shotgunAddressArray[_shotgunCounter - 1]);
			if (_shotgunClause.shotgunEnacted()) {
				return true;
			} else {
				return false;
			}
		}
	}

	function currentShotgunClause() external view returns (address) {

		return address(_currentShotgunClause);
	}

	function shardRegistryAddress() external view returns (address) {

		return address(_shardRegistry);
	}

	function shardOfferingAddress() external view returns (address) {

		return address(_shardOffering);
	}

	function getContractBalance() external view returns (uint) {

		return address(this).balance;
	}

	function offererAddress() external view returns (address payable) {

		return _offererAddress;
	}

	function shotgunCounter() external view returns (uint) {

		return _shotgunCounter;
	}

	function shotgunAddressArray() external view returns (address[] memory) {

		return _shotgunAddressArray;
	}

	function getNftRegistryAddresses() external view returns (address[] memory) {

		return _nftRegistryAddresses;
	}

	function getNftTokenIds() external view returns (uint256[] memory) {

		return _tokenIds;
	}

	function getOwner() external view returns (address) {

		return _niftexWalletAddress;
	}

	function checkLock() external view returns (bool) {

		if (address(_shardOffering) == address(0) || address(_shardRegistry) == address(0)) return false;

		for (uint x = 0; x < _tokenIds.length; x++) {
			address owner = IERC721(_nftRegistryAddresses[x]).ownerOf(_tokenIds[x]);
			if (owner != address(this)) {
				return false;
			}
		}

		return true;
	}

	function onERC721Received(address, address, uint256, bytes memory) public returns(bytes4) {

		return _ERC721_RECEIVED;
	}
}