pragma solidity >=0.4.25 <0.6.0;


library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}
pragma solidity ^0.5.2;


interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.2;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul: c / a != b");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div: b must be > 0");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "sub: b must be <= a");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "add: c must be >= a");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "mod: b == 0");
        return a % b;
    }
}
pragma solidity ^0.5.2;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}
pragma solidity ^0.5.2;


contract CereneumData is ERC20
{

	using SafeMath for uint256;

  uint256 internal m_tContractLaunchTime;

  bytes32[5] public m_hMerkleTreeRootsArray;

  uint256 public constant m_nUTXOCountAtSnapshot = 85997439;

  uint256 public constant m_nMaxRedeemable = 21275254524468718;

  uint256 public constant m_nAdjustedMaxRedeemable = 15019398043400000;

  address constant internal m_genesis = 0xb26165df612B1c9dc705B9872178B3F48151b24d;

	address payable constant internal m_EthGenesis = 0xbe9CEF4196a835F29B117108460ed6fcA299b611;

	address payable constant internal m_publicReferralAddress = 0x8eAf4Fec503da352EB66Ef1E2f75C63e5bC635e1;

  uint16[4] public m_blockchainRatios;

  enum AddressType { LegacyUncompressed, LegacyCompressed, SegwitUncompressed, SegwitCompressed }
  enum BlockchainType { Bitcoin, BitcoinCash, BitcoinSV, Ethereum, Litecoin }

  uint256 public m_nTotalRedeemed = 0;
  uint256 public m_nRedeemedCount = 0;

  mapping(uint8 => mapping(bytes32 => bool)) internal m_claimedUTXOsMap;

  uint256 internal m_nLastUpdatedDay = 14;

  struct DailyDataStuct
	{
    uint256 nPayoutAmount;
    uint256 nTotalStakeShares;
		uint256 nTotalEthStaked;
  }

  mapping(uint256 => DailyDataStuct) public m_dailyDataMap;

  struct StakeStruct
	{
    uint256 nAmountStaked;
    uint256 nSharesStaked;	//Get bonus shares for longer stake times
		uint256 nCompoundedPayoutAccumulated;
    uint256 tLockTime;
    uint256 tEndStakeCommitTime;
		uint256 tLastCompoundedUpdateTime;
    uint256 tTimeRemovedFromGlobalPool;
		uint8 nVotedOnMultiplier;
		bool bIsInGlobalPool;
    bool bIsLatePenaltyAlreadyPooled;
  }

  struct EthStakeStruct
	{
    uint256 nAmount;
    uint256 nDay;
  }

  mapping(address => StakeStruct[]) public m_staked;

	mapping(address => EthStakeStruct[]) public m_EthereumStakers;

  uint256 internal m_nEarlyAndLateUnstakePool;

  uint256 public m_nTotalStakedTokens;
  uint256 public m_nTotalStakeShares;

	uint256 public m_nTotalEthStaked = 0;

  uint8 public m_nInterestMultiplier = 1;

	mapping(uint8 => uint256) public m_votingMultiplierMap;

  uint256 internal constant m_nMaxStakingTime = 365 days * 5;	//years is deprecated because of leap years

	uint256 internal constant m_nClaimPhaseBufferDays = 14;

	uint256 public m_nLastEthWithdrawalTime = 0;

	bool internal m_bHasAirdroppedExchanges = false;

	address[12] internal m_exchangeAirdropAddresses;
	uint256[12] internal m_exchangeAirdropAmounts;
}
pragma solidity ^0.5.2;


contract CereneumImplementation is CereneumData
{

	using SafeMath for uint256;

  event ClaimEvent(
    uint256 nOriginalClaimAmount,
    uint256 nAmountGranted,
    uint256 nBonuses,
		uint256 nPenalties,
    bool bWasReferred
  );

  event StartStakeEvent(
    uint256 nAmount,
    uint256 nDays
  );

	event CompoundInterestEvent(
		uint256 nInterestCompounded
	);

  event EndStakeEvent(
    uint256 nPrincipal,
    uint256 nPayout,
    uint256 nDaysServed,
    uint256 nPenalty,
    uint256 nStakeShares,
    uint256 nDaysCommitted
  );

  event EndStakeForAFriendEvent(
    uint256 nShares,
    uint256 tStakeEndTimeCommit
  );

	event StartEthStakeEvent(
    uint256 nEthAmount
  );

	event EndEthStakeEvent(
    uint256 nPayout
  );

	function GetNumberOfStakes(
		address a_address
	)
	external view returns (uint256)
	{

		return m_staked[a_address].length;
	}

	function GetNumberOfEthPoolStakes(
		address a_address
	)
	external view returns (uint256)
	{

		return m_EthereumStakers[a_address].length;
	}

	function GetTimeUntilNextDailyUpdate() external view returns (uint256)
	{

    uint256 nDay = 1 days;
		return nDay.sub((block.timestamp.sub(m_tContractLaunchTime)).mod(1 days));
	}

  function DifferenceInDays(
    uint256 a_nStartTime,
    uint256 a_nEndTime
  ) public pure returns (uint256)
	{

    return (a_nEndTime.sub(a_nStartTime).div(1 days));
  }

  function TimestampToDaysSinceLaunch(
    uint256 a_tTimestamp
  ) public view returns (uint256)
	{

    return (a_tTimestamp.sub(m_tContractLaunchTime).div(1 days));
  }

  function DaysSinceLaunch() public view returns (uint256)
	{

    return (TimestampToDaysSinceLaunch(block.timestamp));
  }

  function IsClaimablePhase() public view returns (bool)
	{

    return (DaysSinceLaunch() < 364);
  }

	function StartEthStake() external payable
	{

		require(msg.value >= 0.01 ether, "ETH Sent not above minimum value");

		require(DaysSinceLaunch() >= m_nClaimPhaseBufferDays, "Eth Pool staking doesn't begin until after the buffer window");

		UpdateDailyData();

		m_EthereumStakers[msg.sender].push(
      EthStakeStruct(
        msg.value, // Ethereum staked
				DaysSinceLaunch()	//Day staked
      )
    );

		emit StartEthStakeEvent(
      msg.value
    );

		m_nTotalEthStaked = m_nTotalEthStaked.add(msg.value);
  }

	function() external payable
	{

  }

	function WithdrawFromEthPool(uint256 a_nIndex) external
	{

		require(m_EthereumStakers[msg.sender].length > a_nIndex, "Eth stake does not exist");

		UpdateDailyData();

		uint256 nDay = m_EthereumStakers[msg.sender][a_nIndex].nDay;

		require(nDay < DaysSinceLaunch(), "Must wait until next day to withdraw");

		uint256 nAmount = m_EthereumStakers[msg.sender][a_nIndex].nAmount;

		uint256 nPayoutAmount = m_dailyDataMap[nDay].nPayoutAmount.div(10);	//10%

		uint256 nEthPoolPayout = nPayoutAmount.mul(nAmount)
			.div(m_dailyDataMap[nDay].nTotalEthStaked);

		_mint(msg.sender, nEthPoolPayout);

		emit EndEthStakeEvent(
      nEthPoolPayout
    );

		uint256 nEndingIndex = m_EthereumStakers[msg.sender].length.sub(1);

    if(nEndingIndex != a_nIndex)
    {
      m_EthereumStakers[msg.sender][a_nIndex] = m_EthereumStakers[msg.sender][nEndingIndex];
    }

    m_EthereumStakers[msg.sender].length = nEndingIndex;
	}

	function TransferContractETH() external
  {

  	require(address(this).balance != 0, "No Eth to transfer");

		require(m_nLastEthWithdrawalTime.add(12 weeks) <= block.timestamp, "Can only withdraw once every 3 months");

    m_EthGenesis.transfer(address(this).balance);

		m_nLastEthWithdrawalTime = block.timestamp;
  }

  function UpdateDailyData() public
	{

    for(m_nLastUpdatedDay; DaysSinceLaunch() > m_nLastUpdatedDay; m_nLastUpdatedDay++)
		{
      uint256 nPayoutRound = totalSupply().div(7300);

      uint256 nUnclaimedCoins = 0;
      if(m_nLastUpdatedDay < 364)
			{
        nUnclaimedCoins = m_nMaxRedeemable.sub(m_nTotalRedeemed);
				nUnclaimedCoins = GetRobinHoodMonthlyAmount(nUnclaimedCoins, m_nLastUpdatedDay);

        nPayoutRound = nPayoutRound.add(nUnclaimedCoins);

        _mint(m_genesis, nPayoutRound.mul(m_nRedeemedCount).div(m_nUTXOCountAtSnapshot)); // Frenzy
        _mint(m_genesis, nPayoutRound.mul(m_nTotalRedeemed).div(m_nAdjustedMaxRedeemable)); // Prosperous

        nPayoutRound = nPayoutRound.add(
          nPayoutRound.mul(m_nRedeemedCount).div(m_nUTXOCountAtSnapshot)
        ).add(
          nPayoutRound.mul(m_nTotalRedeemed).div(m_nAdjustedMaxRedeemable)
        );
      }
			else
			{

				uint8 nVoteMultiplier = 1;
				uint256 nVoteCount = m_votingMultiplierMap[1];

				for(uint8 i=2; i <= 10; i++)
				{
					if(m_votingMultiplierMap[i] > nVoteCount)
					{
						nVoteCount = m_votingMultiplierMap[i];
						nVoteMultiplier = i;
					}
				}

				nPayoutRound = nPayoutRound.mul(nVoteMultiplier);

				m_nInterestMultiplier = nVoteMultiplier;
			}

			_mint(address(this), nPayoutRound.sub(nUnclaimedCoins));

			if(m_nEarlyAndLateUnstakePool != 0)
			{
      	nPayoutRound = nPayoutRound.add(m_nEarlyAndLateUnstakePool);
      	m_nEarlyAndLateUnstakePool = 0;
			}

      m_dailyDataMap[m_nLastUpdatedDay] = DailyDataStuct(
        nPayoutRound,
        m_nTotalStakeShares,
				m_nTotalEthStaked
      );

			m_nTotalEthStaked = 0;
    }
  }

  function GetCirculatingSupply() external view returns (uint256)
	{

    return totalSupply().sub(balanceOf(address(this)));
  }

  function VerifyProof(
    bytes32[] memory a_hMerkleTreeBranches,
    bytes32 a_hMerkleLeaf,
    BlockchainType a_nWhichChain
  ) public view returns (bool)
	{

    require(uint8(a_nWhichChain) >= 0 && uint8(a_nWhichChain) <= 4, "Invalid blockchain option");

    return MerkleProof.verify(a_hMerkleTreeBranches, m_hMerkleTreeRootsArray[uint8(a_nWhichChain)], a_hMerkleLeaf);
  }

  function ECDSAVerify(
    address a_addressClaiming,
    bytes32 a_publicKeyX,
    bytes32 a_publicKeyY,
    uint8 a_v,
    bytes32 a_r,
    bytes32 a_s,
    BlockchainType a_nWhichChain
  ) public pure returns (bool)
	{

    bytes memory addressAsHex = GenerateSignatureMessage(a_addressClaiming, a_nWhichChain);

    bytes32 hHash;
    if(a_nWhichChain != BlockchainType.Ethereum)  //All Bitcoin chains and Litecoin do double sha256 hash
    {
      hHash = sha256(abi.encodePacked(sha256(abi.encodePacked(addressAsHex))));
    }
    else //Otherwise ETH
    {
      hHash = keccak256(abi.encodePacked(addressAsHex));
    }

    return ValidateSignature(
      hHash,
      a_v,
      a_r,
      a_s,
      PublicKeyToEthereumAddress(a_publicKeyX, a_publicKeyY)
    );
  }

  function PublicKeyToEthereumAddress(
    bytes32 a_publicKeyX,
    bytes32 a_publicKeyY
  ) public pure returns (address)
	{

		bytes32 hash = keccak256(abi.encodePacked(a_publicKeyX, a_publicKeyY));
    return address(uint160(uint256((hash))));
  }

  function PublicKeyToBitcoinAddress(
    bytes32 a_publicKeyX,
    bytes32 a_publicKeyY,
    AddressType a_nAddressType
  ) public pure returns (bytes20)
	{

    bytes20 publicKey;
    uint8 initialByte;
    if(a_nAddressType == AddressType.LegacyCompressed || a_nAddressType == AddressType.SegwitCompressed)
		{
      initialByte = (uint256(a_publicKeyY) & 1) == 0 ? 0x02 : 0x03;
      publicKey = ripemd160(abi.encodePacked(sha256(abi.encodePacked(initialByte, a_publicKeyX))));
    }
		else
		{
      initialByte = 0x04;
      publicKey = ripemd160(abi.encodePacked(sha256(abi.encodePacked(initialByte, a_publicKeyX, a_publicKeyY))));
    }

    if(a_nAddressType == AddressType.LegacyUncompressed || a_nAddressType == AddressType.LegacyCompressed)
    {
      return publicKey;
    }
    else if(a_nAddressType == AddressType.SegwitUncompressed || a_nAddressType == AddressType.SegwitCompressed)
    {
      return ripemd160(abi.encodePacked(sha256(abi.encodePacked(hex"0014", publicKey))));
    }
  }

	function GenerateSignatureMessage(
    address a_address,
    BlockchainType a_nWhichChain
  ) public pure returns(bytes memory)
	{

		bytes16 hexDigits = "0123456789abcdef";
		bytes memory prefix;
    uint8 nPrefixLength = 0;

    if(a_nWhichChain >= BlockchainType.Bitcoin && a_nWhichChain <= BlockchainType.BitcoinSV)
    {
      nPrefixLength = 46;
      prefix = new bytes(nPrefixLength);
      prefix = "\x18Bitcoin Signed Message:\n\x3CClaim_Cereneum_to_0x";
    }
    else if(a_nWhichChain == BlockchainType.Ethereum) //Ethereum chain
    {
      nPrefixLength = 48;
      prefix = new bytes(nPrefixLength);
      prefix = "\x19Ethereum Signed Message:\n60Claim_Cereneum_to_0x";
    }
    else  //Otherwise LTC
    {
      nPrefixLength = 47;
      prefix = new bytes(nPrefixLength);
      prefix = "\x19Litecoin Signed Message:\n\x3CClaim_Cereneum_to_0x";
    }

		bytes20 addressBytes = bytes20(a_address);
		bytes memory message = new bytes(nPrefixLength + 40);
		uint256 nOffset = 0;

		for(uint i = 0; i < nPrefixLength; i++)
		{
    	message[nOffset++] = prefix[i];
    }

		for(uint i = 0; i < 20; i++)
		{
      message[nOffset++] = hexDigits[uint256(uint8(addressBytes[i] >> 4))];
      message[nOffset++] = hexDigits[uint256(uint8(addressBytes[i] & 0x0f))];
    }

		return message;
	}

  function ValidateSignature(
    bytes32 a_hash,
    uint8 a_v,
    bytes32 a_r,
    bytes32 a_s,
    address a_address
  ) public pure returns (bool)
	{

    return ecrecover(
      a_hash,
      a_v,
      a_r,
      a_s
    ) == a_address;
  }

  function CanClaimUTXOHash(
    bytes32 a_hMerkleLeafHash,
    bytes32[] memory a_hMerkleTreeBranches,
    BlockchainType a_nWhichChain
  ) public view returns (bool)
	{

    return(
			(m_claimedUTXOsMap[uint8(a_nWhichChain)][a_hMerkleLeafHash] == false) && VerifyProof(a_hMerkleTreeBranches, a_hMerkleLeafHash, a_nWhichChain)
    );
  }

  function CanClaim(
    bytes20 a_addressRedeeming,
    uint256 a_nAmount,
    bytes32[] memory a_hMerkleTreeBranches,
    BlockchainType a_nWhichChain
  ) public view returns (bool)
	{

    bytes32 hMerkleLeafHash = keccak256(
      abi.encodePacked(
        a_addressRedeeming,
        a_nAmount
      )
    );

    return CanClaimUTXOHash(hMerkleLeafHash, a_hMerkleTreeBranches, a_nWhichChain);
  }

	function GetRobinHoodMonthlyAmount(uint256 a_nAmount, uint256 a_nDaysSinceLaunch) public pure returns (uint256)
	{

		uint256 nScaledAmount = a_nAmount.mul(1000000000000);
		uint256 nScalar = 400000000000000;	// 0.25%
		if(a_nDaysSinceLaunch < 43)
		{
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 72)
		{
			nScalar = 200000000000000;	// 0.5%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 101)
		{
			nScalar = 133333333333333;	// 0.75%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 130)
		{
			nScalar = 66666666666666;	// 1.5%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 159)
		{
			nScalar = 33333333333333;	// 3%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 188)
		{
			nScalar = 16666666666666;	// 6%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 217)
		{
			nScalar = 12499999999999;	// 8%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 246)
		{
			nScalar = 10000000000000;	// 10%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 275)
		{
			nScalar = 7999999999999;	// 12.5%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 304)
		{
			nScalar = 6666666666666;	// 15%
			return nScaledAmount.div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch < 334)
		{
			nScalar = 5714285714290;	// 17.5%
			return nScaledAmount.div(nScalar.mul(30));
		}
		else if(a_nDaysSinceLaunch < 364)
		{
			nScalar = 4000000000000;	// 25%
			return nScaledAmount.div(nScalar.mul(30));
		}
	}

	function GetMonthlyLatePenalty(uint256 a_nAmount, uint256 a_nDaysSinceLaunch) public pure returns (uint256)
	{

		if(a_nDaysSinceLaunch <= m_nClaimPhaseBufferDays)
		{
			return 0;
		}

		uint256 nScaledAmount = a_nAmount.mul(1000000000000);
		uint256 nPreviousMonthPenalty = 0;
		uint256 nScalar = 400000000000000;	// 0.25%
		if(a_nDaysSinceLaunch <= 43)
		{
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(14);
			return nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
		}
		else if(a_nDaysSinceLaunch <= 72)
		{
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(43);
			nScalar = 200000000000000;	// 0.5%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 101)
		{
			nScalar = 133333333333333;	// 0.75%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(72);
			nScalar = 133333333333333;	// 0.75%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 130)
		{
			nScalar = 66666666666666;	// 1.5%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(101);
			nScalar = 66666666666666;	// 1.5%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 159)
		{
			nScalar = 33333333333333;	// 3%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(130);
			nScalar = 33333333333333;	// 3%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 188)
		{
			nScalar = 16666666666666;	// 6%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(159);
			nScalar = 16666666666666;	// 6%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 217)
		{
			nScalar = 8333333333333;	// 12%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(188);
			nScalar = 12499999999999;	// 8%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 246)
		{
			nScalar = 5000000000000;	// 20%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(217);
			nScalar = 10000000000000;	// 10%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 275)
		{
			nScalar = 3333333333333;	// 30%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(246);
			nScalar = 7999999999999;	// 12.5%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 304)
		{
			nScalar = 2352941176472;	// 42.5%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(275);
			nScalar = 6666666666666;	// 15%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(29));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch <= 334)
		{
			nScalar = 1739130434782;	// 57.5%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(304);
			nScalar = 5714285714290;	// 17.5%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(30));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else if(a_nDaysSinceLaunch < 364)
		{
			nScalar = 1333333333333;	// 75%
			nPreviousMonthPenalty = nScaledAmount.div(nScalar);
			a_nDaysSinceLaunch = a_nDaysSinceLaunch.sub(334);
			nScalar = 4000000000000;	// 25%
			nScaledAmount = nScaledAmount.mul(a_nDaysSinceLaunch).div(nScalar.mul(30));
			return nScaledAmount.add(nPreviousMonthPenalty);
		}
		else
		{
			return a_nAmount;
		}
	}

	function GetLateClaimAmount(uint256 a_nAmount) internal view returns (uint256)
	{

		uint256 nDaysSinceLaunch = DaysSinceLaunch();

		return a_nAmount.sub(GetMonthlyLatePenalty(a_nAmount, nDaysSinceLaunch));
	}

  function GetSpeedBonus(uint256 a_nAmount) internal view returns (uint256)
	{

		uint256 nDaysSinceLaunch = DaysSinceLaunch();

		if(nDaysSinceLaunch < m_nClaimPhaseBufferDays)
		{
			nDaysSinceLaunch = 0;
		}
		else
		{
			nDaysSinceLaunch = nDaysSinceLaunch.sub(m_nClaimPhaseBufferDays);
		}

    uint256 nMaxDays = 350;
    a_nAmount = a_nAmount.div(5);
    return a_nAmount.mul(nMaxDays.sub(nDaysSinceLaunch)).div(nMaxDays);
  }

	function GetRedeemRatio(uint256 a_nAmount, BlockchainType a_nWhichChain) internal view returns (uint256)
	{

		if(a_nWhichChain != BlockchainType.Bitcoin)
		{
			uint8 nWhichChain = uint8(a_nWhichChain);
			--nWhichChain;

			uint256 nScalar = 100000000000000000;

			uint256 nRatio = nScalar.div(m_blockchainRatios[nWhichChain]);

			a_nAmount = a_nAmount.mul(1000000000000).div(nRatio);
		}

		return a_nAmount;
	}

  function GetRedeemAmount(uint256 a_nAmount, BlockchainType a_nWhichChain) public view returns (uint256, uint256, uint256)
	{

    a_nAmount = GetRedeemRatio(a_nAmount, a_nWhichChain);

    uint256 nAmount = GetLateClaimAmount(a_nAmount);
    uint256 nBonus = GetSpeedBonus(a_nAmount);

    return (nAmount, nBonus, a_nAmount.sub(nAmount));
  }

  function ValidateOwnership(
    uint256 a_nAmount,
    bytes32[] memory a_hMerkleTreeBranches,
    address a_addressClaiming,
    bytes32 a_pubKeyX,
    bytes32 a_pubKeyY,
    AddressType a_nAddressType,
    uint8 a_v,
    bytes32 a_r,
    bytes32 a_s,
    BlockchainType a_nWhichChain
  ) internal
	{

    bytes32 hMerkleLeafHash;
    if(a_nWhichChain != BlockchainType.Ethereum)  //All Bitcoin chains and Litecoin have the same raw address format
    {
      hMerkleLeafHash = keccak256(abi.encodePacked(PublicKeyToBitcoinAddress(a_pubKeyX, a_pubKeyY, a_nAddressType), a_nAmount));
    }
    else //Otherwise ETH
    {
      hMerkleLeafHash = keccak256(abi.encodePacked(PublicKeyToEthereumAddress(a_pubKeyX, a_pubKeyY), a_nAmount));
    }

    require(CanClaimUTXOHash(hMerkleLeafHash, a_hMerkleTreeBranches, a_nWhichChain), "UTXO Cannot be redeemed.");

    require(
      ECDSAVerify(
        a_addressClaiming,
        a_pubKeyX,
        a_pubKeyY,
        a_v,
        a_r,
        a_s,
        a_nWhichChain
      ),
			"ECDSA verification failed."
    );

    m_claimedUTXOsMap[uint8(a_nWhichChain)][hMerkleLeafHash] = true;
  }

  function Claim(
    uint256 a_nAmount,
    bytes32[] memory a_hMerkleTreeBranches,
    address a_addressClaiming,
    bytes32 a_publicKeyX,
    bytes32 a_publicKeyY,
    AddressType a_nAddressType,
    uint8 a_v,
    bytes32 a_r,
    bytes32 a_s,
    BlockchainType a_nWhichChain,
    address a_referrer
  ) public returns (uint256)
	{

    require(IsClaimablePhase(), "Claim is outside of claims period.");

    require(uint8(a_nWhichChain) >= 0 && uint8(a_nWhichChain) <= 4, "Incorrect blockchain value.");

    require(a_v <= 30 && a_v >= 27, "V parameter is invalid.");

    ValidateOwnership(
      a_nAmount,
      a_hMerkleTreeBranches,
      a_addressClaiming,
      a_publicKeyX,
      a_publicKeyY,
      a_nAddressType,
      a_v,
      a_r,
      a_s,
      a_nWhichChain
    );

    UpdateDailyData();

    m_nTotalRedeemed = m_nTotalRedeemed.add(GetRedeemRatio(a_nAmount, a_nWhichChain));

    (uint256 nTokensRedeemed, uint256 nBonuses, uint256 nPenalties) = GetRedeemAmount(a_nAmount, a_nWhichChain);

    _transfer(address(this), a_addressClaiming, nTokensRedeemed);

    _mint(a_addressClaiming, nBonuses);
    _mint(m_genesis, nBonuses);

    m_nRedeemedCount = m_nRedeemedCount.add(1);

    if(a_referrer != address(0))
		{
			_mint(a_addressClaiming, nTokensRedeemed.div(10));
			nBonuses = nBonuses.add(nTokensRedeemed.div(10));

      _mint(a_referrer, nTokensRedeemed.div(5));

      _mint(m_genesis, nTokensRedeemed.mul(1000000000000).div(3333333333333));
    }

    emit ClaimEvent(
      a_nAmount,
      nTokensRedeemed,
      nBonuses,
			nPenalties,
      a_referrer != address(0)
    );

    return nTokensRedeemed.add(nBonuses);
  }

  function CalculatePayout(
    uint256 a_nStakeShares,
    uint256 a_tLockTime,
    uint256 a_tEndTime
  ) public view returns (uint256)
	{

		if(m_nLastUpdatedDay == 0)
			return 0;

    uint256 nPayout = 0;

		uint256 tStartDay = TimestampToDaysSinceLaunch(a_tLockTime);

    uint256 tEndDay = TimestampToDaysSinceLaunch(a_tEndTime);

    for(uint256 i = tStartDay; i < tEndDay; i++)
		{
      uint256 nDailyPayout = m_dailyDataMap[i].nPayoutAmount.mul(a_nStakeShares)
        .div(m_dailyDataMap[i].nTotalStakeShares);

      nPayout = nPayout.add(nDailyPayout);
    }

    return nPayout;
  }

  function CompoundInterest(
		uint256 a_nStakeIndex
	) external
	{

		require(m_nLastUpdatedDay != 0, "First update day has not finished.");

    StakeStruct storage rStake = m_staked[msg.sender][a_nStakeIndex];

		require(block.timestamp < rStake.tEndStakeCommitTime, "Stake has already matured.");

		UpdateDailyData();

		uint256 nInterestEarned = CalculatePayout(
			rStake.nSharesStaked,
		  rStake.tLastCompoundedUpdateTime,
			block.timestamp
		);

		if(nInterestEarned != 0)
		{
			rStake.nCompoundedPayoutAccumulated = rStake.nCompoundedPayoutAccumulated.add(nInterestEarned);
			rStake.nSharesStaked = rStake.nSharesStaked.add(nInterestEarned);

			m_votingMultiplierMap[rStake.nVotedOnMultiplier] = m_votingMultiplierMap[rStake.nVotedOnMultiplier].add(nInterestEarned);

			m_nTotalStakeShares = m_nTotalStakeShares.add(nInterestEarned);
			rStake.tLastCompoundedUpdateTime = block.timestamp;

			emit CompoundInterestEvent(
				nInterestEarned
			);
		}
  }

  function StartStake(
    uint256 a_nAmount,
    uint256 a_nDays,
		uint8 a_nInterestMultiplierVote
  ) external
	{

		require(DaysSinceLaunch() >= m_nClaimPhaseBufferDays, "Staking doesn't begin until after the buffer window");

    require(balanceOf(msg.sender) >= a_nAmount, "Not enough funds for stake.");

    require(a_nAmount > 0, "Stake amount must be greater than 0");

		require(a_nDays >= 7, "Stake is under the minimum time required.");

		require(a_nInterestMultiplierVote >= 1 && a_nInterestMultiplierVote <= 10, "Interest multiplier range is 1-10.");

    uint256 tEndStakeCommitTime = block.timestamp.add(a_nDays.mul(1 days));

    require(tEndStakeCommitTime <= block.timestamp.add(m_nMaxStakingTime), "Stake time exceeds maximum.");

    UpdateDailyData();

		uint256 nSharesModifier = 0;

		if(a_nDays >= 90)
		{
			nSharesModifier = a_nDays.mul(2000000).div(365);
		}

    uint256 nStakeShares = a_nAmount.add(a_nAmount.mul(nSharesModifier).div(10000000));

    m_staked[msg.sender].push(
      StakeStruct(
        a_nAmount, // nAmountStaked
        nStakeShares, // nSharesStaked
				0,	//Accumulated Payout from CompoundInterest
        block.timestamp, // tLockTime
        tEndStakeCommitTime, // tEndStakeCommitTime
				block.timestamp, //tLastCompoundedUpdateTime
        0, // tTimeRemovedFromGlobalPool
				a_nInterestMultiplierVote,
				true, // bIsInGlobalPool
        false // bIsLatePenaltyAlreadyPooled
      )
    );

    emit StartStakeEvent(
      a_nAmount,
      a_nDays
    );

		m_votingMultiplierMap[a_nInterestMultiplierVote] = m_votingMultiplierMap[a_nInterestMultiplierVote].add(nStakeShares);

    m_nTotalStakedTokens = m_nTotalStakedTokens.add(a_nAmount);

    m_nTotalStakeShares = m_nTotalStakeShares.add(nStakeShares);

    _transfer(msg.sender, address(this), a_nAmount);
  }

  function CalculateLatePenalty(
    uint256 a_tEndStakeCommitTime,
    uint256 a_tTimeRemovedFromGlobalPool,
    uint256 a_nInterestEarned
  ) public pure returns (uint256)
	{

    uint256 nPenalty = 0;

    if(a_tTimeRemovedFromGlobalPool > a_tEndStakeCommitTime.add(1 weeks))
		{
      uint256 nPenaltyPercent = DifferenceInDays(a_tEndStakeCommitTime.add(1 weeks), a_tTimeRemovedFromGlobalPool);

			if(nPenaltyPercent > 100)
			{
				nPenaltyPercent = 100;
			}

			nPenalty = a_nInterestEarned.mul(nPenaltyPercent).div(100);
    }

    return nPenalty;
  }

  function CalculateEarlyPenalty(
		uint256 a_tLockTime,
		uint256 a_nEndStakeCommitTime,
    uint256 a_nAmount,
		uint256 a_nInterestEarned
  ) public view returns (uint256)
	{

    uint256 nPenalty = 0;

    if(block.timestamp < a_nEndStakeCommitTime)
		{
			if(DifferenceInDays(a_tLockTime, block.timestamp) == 0)
			{
				nPenalty = a_nInterestEarned;
			}
			else
			{
				nPenalty = a_nInterestEarned.div(2);
			}

			uint256 nCommittedStakeDays = DifferenceInDays(a_tLockTime, a_nEndStakeCommitTime);

			if(nCommittedStakeDays >= 90)
			{
				nPenalty = nPenalty.add(nPenalty.mul(nCommittedStakeDays).div(3650));
			}

			uint256 nMinimumPenalty = a_nAmount.mul(nCommittedStakeDays).div(7300);

			if(nMinimumPenalty > nPenalty)
			{
				nPenalty = nMinimumPenalty;
			}
		}

    return nPenalty;
  }

  function EndStakeForAFriend(
    uint256 a_nStakeIndex,
		address a_address
  ) external
	{

		require(m_staked[a_address].length > a_nStakeIndex, "Stake does not exist");

    require(block.timestamp > m_staked[a_address][a_nStakeIndex].tEndStakeCommitTime, "Stake must be matured.");

		ProcessStakeEnding(a_nStakeIndex, a_address, true);
  }

  function EndStakeEarly(
    uint256 a_nStakeIndex
  ) external
	{

		require(m_staked[msg.sender].length > a_nStakeIndex, "Stake does not exist");

    ProcessStakeEnding(a_nStakeIndex, msg.sender, false);
  }

  function EndStakeSafely(
    uint256 a_nStakeIndex
  ) external
	{

		require(m_staked[msg.sender].length > a_nStakeIndex, "Stake does not exist");

		require(block.timestamp > m_staked[msg.sender][a_nStakeIndex].tEndStakeCommitTime, "Stake must be matured.");

    ProcessStakeEnding(a_nStakeIndex, msg.sender, false);
  }

	function ProcessStakeEnding(
    uint256 a_nStakeIndex,
		address a_address,
		bool a_bWasForAFriend
  ) internal
	{

		UpdateDailyData();

    StakeStruct storage rStake = m_staked[a_address][a_nStakeIndex];

    uint256 tEndTime = block.timestamp > rStake.tEndStakeCommitTime ?
			rStake.tEndStakeCommitTime : block.timestamp;

		uint256 nTotalPayout = CalculatePayout(
			rStake.nSharesStaked,
			rStake.tLastCompoundedUpdateTime,
			tEndTime
		);

		nTotalPayout = nTotalPayout.add(rStake.nCompoundedPayoutAccumulated);

		nTotalPayout = nTotalPayout.add(rStake.nAmountStaked);

		if(rStake.bIsInGlobalPool)
		{
			m_nTotalStakedTokens = m_nTotalStakedTokens.sub(rStake.nAmountStaked);

			m_nTotalStakeShares = m_nTotalStakeShares.sub(rStake.nSharesStaked);

			m_votingMultiplierMap[rStake.nVotedOnMultiplier] = m_votingMultiplierMap[rStake.nVotedOnMultiplier].sub(rStake.nSharesStaked);

			rStake.tTimeRemovedFromGlobalPool = block.timestamp;

			rStake.bIsInGlobalPool = false;

			if(a_bWasForAFriend)
			{
				emit EndStakeForAFriendEvent(
					rStake.nSharesStaked,
					rStake.tEndStakeCommitTime
				);
			}
		}

		uint256 nPenalty = 0;
		if(!a_bWasForAFriend)	//Can't have an early penalty if it was called by EndStakeForAFriend
 		{
			nPenalty = CalculateEarlyPenalty(
				rStake.tLockTime,
				rStake.tEndStakeCommitTime,
				rStake.nAmountStaked,
				nTotalPayout.sub(rStake.nAmountStaked)
			);
		}

		if(nPenalty == 0)
		{
			nPenalty = CalculateLatePenalty(
				rStake.tEndStakeCommitTime,
				rStake.tTimeRemovedFromGlobalPool,
				nTotalPayout.sub(rStake.nAmountStaked)
			);
		}

		if(nPenalty != 0 && !rStake.bIsLatePenaltyAlreadyPooled)
		{
			m_nEarlyAndLateUnstakePool = m_nEarlyAndLateUnstakePool.add(nPenalty.div(2));
			_transfer(address(this), m_genesis, nPenalty.div(2));
		}

		if(a_bWasForAFriend)
		{
			rStake.bIsLatePenaltyAlreadyPooled =	true;
		}
		else
		{
			nTotalPayout = nTotalPayout.sub(nPenalty);

			emit EndStakeEvent(
				rStake.nAmountStaked,
				nTotalPayout,
        block.timestamp < rStake.tEndStakeCommitTime ?
  				DifferenceInDays(rStake.tLockTime, block.timestamp) :
  				DifferenceInDays(rStake.tLockTime, rStake.tTimeRemovedFromGlobalPool),
				nPenalty,
				rStake.nSharesStaked,
				DifferenceInDays(rStake.tLockTime, rStake.tEndStakeCommitTime)
			);

			_transfer(address(this), a_address, nTotalPayout);

			RemoveStake(a_address, a_nStakeIndex);
		}
	}

  function RemoveStake(
    address a_address,
    uint256 a_nStakeIndex
  ) internal
	{

    uint256 nEndingIndex = m_staked[a_address].length.sub(1);

    if(nEndingIndex != a_nStakeIndex)
    {
      m_staked[a_address][a_nStakeIndex] = m_staked[a_address][nEndingIndex];
    }

    m_staked[a_address].length = nEndingIndex;
  }
}
pragma solidity ^0.5.2;


contract Cereneum is CereneumImplementation
{

	using SafeMath for uint256;

	constructor(
			bytes32 a_hBTCMerkleTreeRoot,
			bytes32 a_hBCHMerkleTreeRoot,
			bytes32 a_hBSVMerkleTreeRoot,
			bytes32 a_hETHMerkleTreeRoot,
			bytes32 a_hLTCMerkleTreeRoot
  )
	public
	{
    m_tContractLaunchTime = block.timestamp;
    m_hMerkleTreeRootsArray[0] = a_hBTCMerkleTreeRoot;
		m_hMerkleTreeRootsArray[1] = a_hBCHMerkleTreeRoot;
		m_hMerkleTreeRootsArray[2] = a_hBSVMerkleTreeRoot;
		m_hMerkleTreeRootsArray[3] = a_hETHMerkleTreeRoot;
		m_hMerkleTreeRootsArray[4] = a_hLTCMerkleTreeRoot;

		m_blockchainRatios[0] = 5128; //BCH
	  m_blockchainRatios[1] = 2263; //BSV
	  m_blockchainRatios[2] = 3106; //ETH
	  m_blockchainRatios[3] = 1311; //LTC

		m_exchangeAirdropAddresses[0] = 0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE;
		m_exchangeAirdropAmounts[0] = 17400347788910;

		m_exchangeAirdropAddresses[1] = 0xD551234Ae421e3BCBA99A0Da6d736074f22192FF;
		m_exchangeAirdropAmounts[1] = 6758097982665;

		m_exchangeAirdropAddresses[2] = 0x564286362092D8e7936f0549571a803B203aAceD;
		m_exchangeAirdropAmounts[2] = 5557947334680;

		m_exchangeAirdropAddresses[3] = 0x0681d8Db095565FE8A346fA0277bFfdE9C0eDBBF;
		m_exchangeAirdropAmounts[3] = 5953786344335;


		m_exchangeAirdropAddresses[4] = 0x4E9ce36E442e55EcD9025B9a6E0D88485d628A67;
		m_exchangeAirdropAmounts[4] = 779918770916450;

		m_exchangeAirdropAddresses[5] = 0xFBb1b73C4f0BDa4f67dcA266ce6Ef42f520fBB98;
		m_exchangeAirdropAmounts[5] = 84975797259280;

		m_exchangeAirdropAddresses[6] = 0x66f820a414680B5bcda5eECA5dea238543F42054;
		m_exchangeAirdropAmounts[6] = 651875804471280;

		m_exchangeAirdropAddresses[7] = 0x2B5634C42055806a59e9107ED44D43c426E58258;
		m_exchangeAirdropAmounts[7] = 6609673761160;

		m_exchangeAirdropAddresses[8] = 0x689C56AEf474Df92D44A1B70850f808488F9769C;
		m_exchangeAirdropAmounts[8] = 4378334643430;

		m_exchangeAirdropAddresses[9] = 0x7891b20C690605F4E370d6944C8A5DBfAc5a451c;
		m_exchangeAirdropAmounts[9] = 6754951284855;

		m_exchangeAirdropAddresses[10] = 0xDc76CD25977E0a5Ae17155770273aD58648900D3;
		m_exchangeAirdropAmounts[10] = 427305320984440;

		m_exchangeAirdropAddresses[11] = 0x33683b94334eeBc9BD3EA85DDBDA4a86Fb461405;
		m_exchangeAirdropAmounts[11] = 2414794474090;

    _mint(address(this), m_nMaxRedeemable);
	}

  string public constant name = "Cereneum";
  string public constant symbol = "CER";
  uint public constant decimals = 8;

	function ExchangeEthereumAirdrops() external
	{

		UpdateDailyData();

		require(m_bHasAirdroppedExchanges == false);
		m_bHasAirdroppedExchanges = true;

		uint256 nGenesisBonuses = 0;
		uint256 nPublicReferralBonuses = 0;
		uint256 nTokensRedeemed = 0;
		uint256 nBonuses = 0;
		uint256 nPenalties = 0;

		for(uint256 i=0; i < 12; ++i)
		{
			(nTokensRedeemed, nBonuses, nPenalties) = GetRedeemAmount(m_exchangeAirdropAmounts[i], BlockchainType.Ethereum);

			_transfer(address(this), m_exchangeAirdropAddresses[i], nTokensRedeemed);

			_mint(m_exchangeAirdropAddresses[i], nBonuses.add(nTokensRedeemed.div(10)));

			nGenesisBonuses = nGenesisBonuses.add(nBonuses.add(nTokensRedeemed.mul(1000000000000).div(3333333333333)));

			nPublicReferralBonuses = nPublicReferralBonuses.add(nTokensRedeemed.div(5));

			m_nTotalRedeemed = m_nTotalRedeemed.add(GetRedeemRatio(m_exchangeAirdropAmounts[i], BlockchainType.Ethereum));
			m_nRedeemedCount = m_nRedeemedCount.add(1);
		}

		_mint(m_publicReferralAddress, nPublicReferralBonuses);

		_mint(m_genesis, nGenesisBonuses);
	}
}
pragma solidity >=0.4.25 <0.6.0;

contract Migrations {

  address public owner;
  uint public last_completed_migration;

  modifier restricted() {

    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {

    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
