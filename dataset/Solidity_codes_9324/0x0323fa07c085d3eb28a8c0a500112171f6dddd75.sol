
pragma solidity 0.5.17;

interface IERC20 { // brief interface for erc20 token tx

    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface IWETH { // brief interface for canonical ether token wrapper 

    function deposit() payable external;

    
    function transfer(address dst, uint wad) external returns (bool);

}

library Address { // helper for address type - see openzeppelin-contracts/blob/master/contracts/utils/Address.sol

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

library SafeERC20 { // wrapper around erc20 token tx for non-standard contract - see openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   function _callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returnData) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returnData.length > 0) { // return data is optional
            require(abi.decode(returnData, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

library SafeMath { // arithmetic wrapper for unit under/overflow check

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

contract ReentrancyGuard { // call wrapper for reentrancy check

    bool private _notEntered;

    function _initReentrancyGuard () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

contract Mystic is ReentrancyGuard { 

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public depositToken; // deposit token contract reference - default = wETH
    address public stakeToken; // stake token contract reference for guild voting shares 
    address public constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // canonical ether token wrapper contract reference for proposals
    
    uint256 public proposalDeposit; // default = 10 deposit token 
    uint256 public processingReward; // default = 0.1 - amount of deposit token to give to whoever processes a proposal
    uint256 public periodDuration; // default = 17280 = 4.8 hours in seconds (5 periods per day)
    uint256 public votingPeriodLength; // default = 35 periods (7 days)
    uint256 public gracePeriodLength; // default = 35 periods (7 days)
    uint256 public dilutionBound; // default = 3 - maximum multiplier a YES voter will be obligated to pay in case of mass ragequit
    uint256 public summoningTime; // needed to determine the current period
    bool private initialized; // tracks deployment status
    
    uint256 constant MAX_GUILD_BOUND = 10**36; // maximum bound for guild accounting
    uint256 constant MAX_TOKEN_WHITELIST_COUNT = 400; // maximum number of whitelisted tokens
    uint256 constant MAX_TOKEN_GUILDBANK_COUNT = 200; // maximum number of tokens with non-zero balance in guildbank

    string public constant name = "MYSTIC DAO";
    string public constant symbol = "MXDAO";
    uint8 public constant decimals = 18;

    event SubmitProposal(address indexed applicant, uint256 sharesRequested, uint256 lootRequested, uint256 tributeOffered, address tributeToken, uint256 paymentRequested, address paymentToken, bytes32 details, uint8[7] flags, bytes data, uint256 proposalId, address indexed delegateKey, address indexed memberAddress);
    event CancelProposal(uint256 indexed proposalId, address applicantAddress);
    event SponsorProposal(address indexed delegateKey, address indexed memberAddress, uint256 proposalId, uint256 proposalIndex, uint256 startingPeriod);
    event SubmitVote(uint256 proposalId, uint256 indexed proposalIndex, address indexed delegateKey, address indexed memberAddress, uint8 uintVote);
    event ProcessProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event ProcessActionProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event ProcessWhitelistProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event ProcessGuildKickProposal(uint256 indexed proposalIndex, uint256 indexed proposalId, bool didPass);
    event UpdateDelegateKey(address indexed memberAddress, address newDelegateKey);
    event Approval(address indexed owner, address indexed spender, uint256 amount); // guild token (loot) allowance tracking
    event Transfer(address indexed from, address indexed to, uint256 amount); // guild token mint, burn & (loot) transfer tracking
    event Ragequit(address indexed memberAddress, uint256 sharesToBurn, uint256 lootToBurn);
    event TokensCollected(address indexed token, uint256 amountToCollect);
    event Withdraw(address indexed memberAddress, address token, uint256 amount);
    
    address public constant GUILD = address(0xdead);
    address public constant ESCROW = address(0xdeaf);
    address public constant TOTAL = address(0xdeed);
    
    uint256 public proposalCount; // total proposals submitted
    uint256 public totalShares; // total shares across all members
    uint256 public totalLoot; // total loot across all members
    uint256 public totalGuildBankTokens; // total tokens with non-zero balance in guild bank

    mapping(uint256 => bytes) public actions; // proposalId => action data
    mapping(address => uint256) private balances; // guild token balances
    mapping(address => mapping(address => uint256)) private allowances; // guild token (loot) allowances
    mapping(address => mapping(address => uint256)) private userTokenBalances; // userTokenBalances[userAddress][tokenAddress]

    enum Vote {
        Null, // default value, counted as abstention
        Yes,
        No
    }
    
    struct Member {
        address delegateKey; // the key responsible for submitting proposals & voting - defaults to member address unless updated
        uint8 exists; // always true (1) once a member has been created
        uint256 shares; // the # of voting shares assigned to this member
        uint256 loot; // the loot amount available to this member (combined with shares on ragekick) - transferable by guild token
        uint256 highestIndexYesVote; // highest proposal index # on which the member voted YES
        uint256 jailed; // set to proposalIndex of a passing guild kick proposal for this member, prevents voting on & sponsoring proposals
    }
    
    struct Proposal {
        address applicant; // the applicant who wishes to become a member - this key will be used for withdrawals (doubles as target for alt. proposals)
        address proposer; // the account that submitted the proposal (can be non-member)
        address sponsor; // the member that sponsored the proposal (moving it into the queue)
        address tributeToken; // tribute token contract reference
        address paymentToken; // payment token contract reference
        uint8[7] flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick, action]
        uint256 sharesRequested; // the # of shares the applicant is requesting
        uint256 lootRequested; // the amount of loot the applicant is requesting
        uint256 paymentRequested; // amount of tokens requested as payment
        uint256 tributeOffered; // amount of tokens offered as tribute
        uint256 startingPeriod; // the period in which voting can start for this proposal
        uint256 yesVotes; // the total number of YES votes for this proposal
        uint256 noVotes; // the total number of NO votes for this proposal
        uint256 maxTotalSharesAndLootAtYesVote; // the maximum # of total shares encountered at a yes vote on this proposal
        bytes32 details; // proposal details to add context for members 
        mapping(address => Vote) votesByMember; // the votes on this proposal by each member
    }
    
    address[] public approvedTokens;
    mapping(address => bool) public tokenWhitelist;
    
    uint256[] public proposalQueue;
    mapping(uint256 => Proposal) public proposals;

    mapping(address => bool) public proposedToWhitelist;
    mapping(address => bool) public proposedToKick;
    
    mapping(address => Member) public members;
    mapping(address => address) public memberAddressByDelegateKey;
    
    modifier onlyDelegate {

        require(members[memberAddressByDelegateKey[msg.sender]].shares > 0, "!delegate");
        _;
    }

    function init(
        address _depositToken,
        address _stakeToken,
        address[] calldata _summoner,
        uint256[] calldata _summonerShares,
        uint256 _summonerDeposit,
        uint256 _proposalDeposit,
        uint256 _processingReward,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _dilutionBound
    ) external {

        require(!initialized, "initialized");
        require(_depositToken != _stakeToken, "depositToken == stakeToken");
        require(_summoner.length == _summonerShares.length, "summoner != summonerShares");
        require(_proposalDeposit >= _processingReward, "_processingReward > _proposalDeposit");
        
        for (uint256 i = 0; i < _summoner.length; i++) {
            registerMember(_summoner[i], _summonerShares[i]);
            mintGuildToken(_summoner[i], _summonerShares[i]);
            totalShares = totalShares.add(_summonerShares[i]);
        }
        
        require(totalShares <= MAX_GUILD_BOUND, "guild maxed");
        
        tokenWhitelist[_depositToken] = true;
        approvedTokens.push(_depositToken);
        
        if (_summonerDeposit > 0) {
            totalGuildBankTokens += 1;
            unsafeAddToBalance(GUILD, _depositToken, _summonerDeposit);
        }
        
        depositToken = _depositToken;
        stakeToken = _stakeToken;
        proposalDeposit = _proposalDeposit;
        processingReward = _processingReward;
        periodDuration = _periodDuration;
        votingPeriodLength = _votingPeriodLength;
        gracePeriodLength = _gracePeriodLength;
        dilutionBound = _dilutionBound;
        summoningTime = now;
        initialized = true;
        
        _initReentrancyGuard();
    }
    
    function submitProposal(
        address applicant,
        uint256 sharesRequested,
        uint256 lootRequested,
        uint256 tributeOffered,
        address tributeToken,
        uint256 paymentRequested,
        address paymentToken,
        bytes32 details
    ) payable external nonReentrant returns (uint256 proposalId) {

        require(sharesRequested.add(lootRequested) <= MAX_GUILD_BOUND, "guild maxed");
        require(tokenWhitelist[tributeToken], "tributeToken != whitelist");
        require(tokenWhitelist[paymentToken], "paymentToken != whitelist");
        require(applicant != GUILD && applicant != ESCROW && applicant != TOTAL, "applicant unreservable");
        require(members[applicant].jailed == 0, "applicant jailed");

        if (tributeOffered > 0 && userTokenBalances[GUILD][tributeToken] == 0) {
            require(totalGuildBankTokens < MAX_TOKEN_GUILDBANK_COUNT, "guildbank maxed");
        }
        
        if (tributeToken == wETH && msg.value > 0) {
            require(msg.value == tributeOffered, "!ETH");
            IWETH(wETH).deposit();
            (bool success, ) = wETH.call.value(msg.value)("");
            require(success, "!transfer");
            IWETH(wETH).transfer(address(this), msg.value);
        } else {
            IERC20(tributeToken).safeTransferFrom(msg.sender, address(this), tributeOffered);
        }
        
        unsafeAddToBalance(ESCROW, tributeToken, tributeOffered);

        uint8[7] memory flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick, action]

        _submitProposal(applicant, sharesRequested, lootRequested, tributeOffered, tributeToken, paymentRequested, paymentToken, details, flags, "");
        
        return proposalCount - 1; // return proposalId - contracts calling submit might want it
    }
    
    function submitActionProposal( // stages arbitrary function calls for member vote - based on Raid Guild 'Minion'
        address actionTo,
        address actionToken,
        uint256 actionTokenAmount,
        uint256 actionValue,
        bytes32 details,
        bytes calldata data
    ) external returns (uint256 proposalId) {

        
        uint8[7] memory flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick, action]
        flags[6] = 1; // guild action
        
        _submitProposal(actionTo, 0, 0, actionValue, address(0), actionTokenAmount, actionToken, details, flags, data);
        
        return proposalCount - 1;
    }
    
    function submitWhitelistProposal(address tokenToWhitelist, bytes32 details) external returns (uint256 proposalId) {

        require(tokenToWhitelist != address(0), "!token");
        require(tokenToWhitelist != stakeToken, "tokenToWhitelist == stakeToken");
        require(!tokenWhitelist[tokenToWhitelist], "whitelisted");
        require(approvedTokens.length < MAX_TOKEN_WHITELIST_COUNT, "whitelist maxed");

        uint8[7] memory flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick, action]
        flags[4] = 1; // whitelist

        _submitProposal(address(0), 0, 0, 0, tokenToWhitelist, 0, address(0), details, flags, "");
        
        return proposalCount - 1;
    }
    
    function submitGuildKickProposal(address memberToKick, bytes32 details) external returns (uint256 proposalId) {

        Member memory member = members[memberToKick];

        require(member.shares > 0 || member.loot > 0, "!share||loot");
        require(members[memberToKick].jailed == 0, "jailed");

        uint8[7] memory flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick, action]
        flags[5] = 1; // guild kick

        _submitProposal(memberToKick, 0, 0, 0, address(0), 0, address(0), details, flags, "");
        
        return proposalCount - 1;
    }
    
    function _submitProposal(
        address applicant,
        uint256 sharesRequested,
        uint256 lootRequested,
        uint256 tributeOffered,
        address tributeToken,
        uint256 paymentRequested,
        address paymentToken,
        bytes32 details,
        uint8[7] memory flags,
        bytes memory data
    ) internal {

        Proposal memory proposal = Proposal({
            applicant : applicant,
            proposer : msg.sender,
            sponsor : address(0),
            tributeToken : tributeToken,
            paymentToken : paymentToken,
            flags : flags,
            sharesRequested : sharesRequested,
            lootRequested : lootRequested,
            paymentRequested : paymentRequested,
            tributeOffered : tributeOffered,
            startingPeriod : 0,
            yesVotes : 0,
            noVotes : 0,
            maxTotalSharesAndLootAtYesVote : 0,
            details : details
        });
        
        if (proposal.flags[6] == 1) {
            actions[proposalCount] = data;
        }
        
        proposals[proposalCount] = proposal;
        address memberAddress = memberAddressByDelegateKey[msg.sender];
        emit SubmitProposal(applicant, sharesRequested, lootRequested, tributeOffered, tributeToken, paymentRequested, paymentToken, details, flags, data, proposalCount, msg.sender, memberAddress);
        
        proposalCount += 1;
    }

    function sponsorProposal(uint256 proposalId) external nonReentrant onlyDelegate {

        IERC20(depositToken).safeTransferFrom(msg.sender, address(this), proposalDeposit);
        unsafeAddToBalance(ESCROW, depositToken, proposalDeposit);

        Proposal storage proposal = proposals[proposalId];

        require(proposal.proposer != address(0), "!proposed");
        require(proposal.flags[0] == 0, "sponsored");
        require(proposal.flags[3] == 0, "cancelled");
        require(members[proposal.applicant].jailed == 0, "applicant jailed");

        if (proposal.tributeOffered > 0 && userTokenBalances[GUILD][proposal.tributeToken] == 0) {
            require(totalGuildBankTokens < MAX_TOKEN_GUILDBANK_COUNT, "guildbank maxed");
        }

        if (proposal.flags[4] == 1) {
            require(!tokenWhitelist[address(proposal.tributeToken)], "whitelisted");
            require(!proposedToWhitelist[address(proposal.tributeToken)], "whitelist proposed");
            require(approvedTokens.length < MAX_TOKEN_WHITELIST_COUNT, "whitelist maxed");
            proposedToWhitelist[address(proposal.tributeToken)] = true;

        } else if (proposal.flags[5] == 1) {
            require(!proposedToKick[proposal.applicant], "kick proposed");
            proposedToKick[proposal.applicant] = true;
        }

        uint256 startingPeriod = max(
            getCurrentPeriod(),
            proposalQueue.length == 0 ? 0 : proposals[proposalQueue[proposalQueue.length - 1]].startingPeriod
        ) + 1;

        proposal.startingPeriod = startingPeriod;

        address memberAddress = memberAddressByDelegateKey[msg.sender];
        proposal.sponsor = memberAddress;

        proposal.flags[0] = 1; // sponsored

        proposalQueue.push(proposalId);
        
        emit SponsorProposal(msg.sender, memberAddress, proposalId, proposalQueue.length - 1, startingPeriod);
    }

    function submitVote(uint256 proposalIndex, uint8 uintVote) external onlyDelegate {

        address memberAddress = memberAddressByDelegateKey[msg.sender];
        Member storage member = members[memberAddress];

        require(proposalIndex < proposalQueue.length, "!proposed");
        Proposal storage proposal = proposals[proposalQueue[proposalIndex]];

        require(uintVote < 3, "!<3");
        Vote vote = Vote(uintVote);

        require(getCurrentPeriod() >= proposal.startingPeriod, "pending");
        require(!hasVotingPeriodExpired(proposal.startingPeriod), "expired");
        require(proposal.votesByMember[memberAddress] == Vote.Null, "voted");
        require(vote == Vote.Yes || vote == Vote.No, "!Yes||No");

        proposal.votesByMember[memberAddress] = vote;

        if (vote == Vote.Yes) {
            proposal.yesVotes += member.shares;

            if (proposalIndex > member.highestIndexYesVote) {
                member.highestIndexYesVote = proposalIndex;
            }

            if (totalSupply() > proposal.maxTotalSharesAndLootAtYesVote) {
                proposal.maxTotalSharesAndLootAtYesVote = totalSupply();
            }

        } else if (vote == Vote.No) {
            proposal.noVotes += member.shares;
        }
     
        emit SubmitVote(proposalQueue[proposalIndex], proposalIndex, msg.sender, memberAddress, uintVote);
    }

    function processProposal(uint256 proposalIndex) external nonReentrant {

        _validateProposalForProcessing(proposalIndex);

        uint256 proposalId = proposalQueue[proposalIndex];
        Proposal storage proposal = proposals[proposalId];

        require(proposal.flags[4] == 0 && proposal.flags[5] == 0 && proposal.flags[6] == 0, "!standard");

        proposal.flags[1] = 1; // processed

        bool didPass = _didPass(proposalIndex);

        if (totalSupply().add(proposal.sharesRequested).add(proposal.lootRequested) > MAX_GUILD_BOUND) {
            didPass = false;
        }

        if (proposal.paymentRequested > userTokenBalances[GUILD][proposal.paymentToken]) {
            didPass = false;
        }

        if (proposal.tributeOffered > 0 && userTokenBalances[GUILD][proposal.tributeToken] == 0 && totalGuildBankTokens >= MAX_TOKEN_GUILDBANK_COUNT) {
            didPass = false;
        }

        if (didPass) {
            proposal.flags[2] = 1; // didPass

            if (members[proposal.applicant].exists == 1) {
                members[proposal.applicant].shares = members[proposal.applicant].shares.add(proposal.sharesRequested);
                members[proposal.applicant].loot = members[proposal.applicant].loot.add(proposal.lootRequested);

            } else {
                registerMember(proposal.applicant, proposal.sharesRequested);
            }

            mintGuildToken(proposal.applicant, proposal.sharesRequested.add(proposal.lootRequested));
            totalShares = totalShares.add(proposal.sharesRequested);
            totalLoot = totalLoot.add(proposal.lootRequested);

            if (userTokenBalances[GUILD][proposal.tributeToken] == 0 && proposal.tributeOffered > 0) {
                totalGuildBankTokens += 1;
            }

            unsafeInternalTransfer(ESCROW, GUILD, proposal.tributeToken, proposal.tributeOffered);
            unsafeInternalTransfer(GUILD, proposal.applicant, proposal.paymentToken, proposal.paymentRequested);

            if (userTokenBalances[GUILD][proposal.paymentToken] == 0 && proposal.paymentRequested > 0) {
                totalGuildBankTokens -= 1;
            }

        } else {
            unsafeInternalTransfer(ESCROW, proposal.proposer, proposal.tributeToken, proposal.tributeOffered);
        }

        _returnDeposit(proposal.sponsor);
        
        emit ProcessProposal(proposalIndex, proposalId, didPass);
    }
    
    function processActionProposal(uint256 proposalIndex) external nonReentrant returns (bool, bytes memory) {

        _validateProposalForProcessing(proposalIndex);
        
        uint256 proposalId = proposalQueue[proposalIndex];
        bytes storage action = actions[proposalId];
        Proposal storage proposal = proposals[proposalId];
        
        require(proposal.flags[6] == 1, "!action");

        proposal.flags[1] = 1; // processed

        bool didPass = _didPass(proposalIndex);
        
        if (proposal.paymentToken == stakeToken && proposal.paymentRequested > IERC20(stakeToken).balanceOf(address(this))) {
            didPass = false;
        }
        
        if (tokenWhitelist[proposal.paymentToken] && proposal.paymentRequested > userTokenBalances[GUILD][proposal.paymentToken]) {
            didPass = false;
        }
        
        if (proposal.tributeOffered > address(this).balance) {
            didPass = false;
        }

        if (didPass) {
            proposal.flags[2] = 1; // didPass
            (bool success, bytes memory returnData) = proposal.applicant.call.value(proposal.tributeOffered)(action);
            if (tokenWhitelist[proposal.paymentToken]) {
                unsafeSubtractFromBalance(GUILD, proposal.paymentToken, proposal.paymentRequested);
                if (userTokenBalances[GUILD][proposal.paymentToken] == 0 && proposal.paymentRequested > 0) {totalGuildBankTokens -= 1;}
            }
            return (success, returnData);
        }
        
        emit ProcessActionProposal(proposalIndex, proposalId, didPass);
    }

    function processWhitelistProposal(uint256 proposalIndex) external {

        _validateProposalForProcessing(proposalIndex);

        uint256 proposalId = proposalQueue[proposalIndex];
        Proposal storage proposal = proposals[proposalId];

        require(proposal.flags[4] == 1, "!whitelist");

        proposal.flags[1] = 1; // processed

        bool didPass = _didPass(proposalIndex);

        if (approvedTokens.length >= MAX_TOKEN_WHITELIST_COUNT) {
            didPass = false;
        }

        if (didPass) {
            proposal.flags[2] = 1; // didPass
            tokenWhitelist[address(proposal.tributeToken)] = true;
            approvedTokens.push(proposal.tributeToken);
        }

        proposedToWhitelist[address(proposal.tributeToken)] = false;

        _returnDeposit(proposal.sponsor);
        
        emit ProcessWhitelistProposal(proposalIndex, proposalId, didPass);
    }

    function processGuildKickProposal(uint256 proposalIndex) external nonReentrant {

        _validateProposalForProcessing(proposalIndex);

        uint256 proposalId = proposalQueue[proposalIndex];
        Proposal storage proposal = proposals[proposalId];

        require(proposal.flags[5] == 1, "!kick");

        proposal.flags[1] = 1; // processed

        bool didPass = _didPass(proposalIndex);

        if (didPass) {
            proposal.flags[2] = 1; // didPass
            Member storage member = members[proposal.applicant];
            member.jailed = proposalIndex;

            member.loot = member.loot.add(member.shares);
            totalShares = totalShares.sub(member.shares);
            totalLoot = totalLoot.add(member.shares);
            member.shares = 0; // revoke all shares
        }

        proposedToKick[proposal.applicant] = false;

        _returnDeposit(proposal.sponsor);
        
        emit ProcessGuildKickProposal(proposalIndex, proposalId, didPass);
    }

    function _didPass(uint256 proposalIndex) internal view returns (bool didPass) {

        Proposal memory proposal = proposals[proposalQueue[proposalIndex]];
        
        if (proposal.yesVotes > proposal.noVotes) {
            didPass = true;
        }
        
        if ((totalSupply().mul(dilutionBound)) < proposal.maxTotalSharesAndLootAtYesVote) {
            didPass = false;
        }

        if (members[proposal.applicant].jailed != 0) {
            didPass = false;
        }

        return didPass;
    }

    function _validateProposalForProcessing(uint256 proposalIndex) internal view {

        require(proposalIndex < proposalQueue.length, "!proposal");
        Proposal memory proposal = proposals[proposalQueue[proposalIndex]];

        require(getCurrentPeriod() >= proposal.startingPeriod.add(votingPeriodLength).add(gracePeriodLength), "!ready");
        require(proposal.flags[1] == 0, "processed");
        require(proposalIndex == 0 || proposals[proposalQueue[proposalIndex - 1]].flags[1] == 1, "prior !processed");
    }

    function _returnDeposit(address sponsor) internal {

        unsafeInternalTransfer(ESCROW, msg.sender, depositToken, processingReward);
        unsafeInternalTransfer(ESCROW, sponsor, depositToken, proposalDeposit - processingReward);
    }

    function ragequit(uint256 sharesToBurn, uint256 lootToBurn) external nonReentrant {

        require(members[msg.sender].exists == 1, "!member");
        
        _ragequit(msg.sender, sharesToBurn, lootToBurn);
    }

    function _ragequit(address memberAddress, uint256 sharesToBurn, uint256 lootToBurn) internal {

        uint256 initialTotalSharesAndLoot = totalSupply();

        Member storage member = members[memberAddress];

        require(member.shares >= sharesToBurn, "!shares");
        require(member.loot >= lootToBurn, "!loot");
        require(canRagequit(member.highestIndexYesVote), "!ragequit until highest index proposal member voted YES processes");

        uint256 sharesAndLootToBurn = sharesToBurn.add(lootToBurn);

        burnGuildToken(memberAddress, sharesAndLootToBurn);
        member.shares = member.shares.sub(sharesToBurn);
        member.loot = member.loot.sub(lootToBurn);
        totalShares = totalShares.sub(sharesToBurn);
        totalLoot = totalLoot.sub(lootToBurn);

        for (uint256 i = 0; i < approvedTokens.length; i++) {
            uint256 amountToRagequit = fairShare(userTokenBalances[GUILD][approvedTokens[i]], sharesAndLootToBurn, initialTotalSharesAndLoot);
            if (amountToRagequit > 0) { // gas optimization to allow a higher maximum token limit
                userTokenBalances[GUILD][approvedTokens[i]] -= amountToRagequit;
                userTokenBalances[memberAddress][approvedTokens[i]] += amountToRagequit;
            }
        }

        emit Ragequit(memberAddress, sharesToBurn, lootToBurn);
    }

    function ragekick(address memberToKick) external nonReentrant onlyDelegate {

        Member storage member = members[memberToKick];

        require(member.jailed != 0, "!jailed");
        require(member.loot > 0, "!loot"); // note - should be impossible for jailed member to have shares
        require(canRagequit(member.highestIndexYesVote), "!ragequit until highest index proposal member voted YES processes");

        _ragequit(memberToKick, 0, member.loot);
    }
    
    function withdrawBalance(address token, uint256 amount) external nonReentrant {

        _withdrawBalance(token, amount);
    }

    function withdrawBalances(address[] calldata tokens, uint256[] calldata amounts, bool max) external nonReentrant {

        require(tokens.length == amounts.length, "tokens != amounts");

        for (uint256 i=0; i < tokens.length; i++) {
            uint256 withdrawAmount = amounts[i];
            if (max) { // withdraw the maximum balance
                withdrawAmount = userTokenBalances[msg.sender][tokens[i]];
            }

            _withdrawBalance(tokens[i], withdrawAmount);
        }
    }
    
    function _withdrawBalance(address token, uint256 amount) internal {

        require(userTokenBalances[msg.sender][token] >= amount, "!balance");
        
        IERC20(token).safeTransfer(msg.sender, amount);
        unsafeSubtractFromBalance(msg.sender, token, amount);
        
        emit Withdraw(msg.sender, token, amount);
    }

    function collectTokens(address token) external nonReentrant onlyDelegate {

        uint256 amountToCollect = IERC20(token).balanceOf(address(this)).sub(userTokenBalances[TOTAL][token]);
        require(amountToCollect > 0, "!amount");
        require(tokenWhitelist[token], "!whitelisted");
        
        if (userTokenBalances[GUILD][token] == 0 && totalGuildBankTokens < MAX_TOKEN_GUILDBANK_COUNT) {totalGuildBankTokens += 1;}
        unsafeAddToBalance(GUILD, token, amountToCollect);

        emit TokensCollected(token, amountToCollect);
    }

    function cancelProposal(uint256 proposalId) external nonReentrant {

        Proposal storage proposal = proposals[proposalId];
        require(proposal.flags[0] == 0, "sponsored");
        require(proposal.flags[3] == 0, "cancelled");
        require(msg.sender == proposal.proposer, "!proposer");

        proposal.flags[3] = 1; // cancelled
        
        unsafeInternalTransfer(ESCROW, proposal.proposer, proposal.tributeToken, proposal.tributeOffered);
        
        emit CancelProposal(proposalId, msg.sender);
    }

    function updateDelegateKey(address newDelegateKey) external {

        require(members[msg.sender].shares > 0, "caller !shareholder");
        require(newDelegateKey != address(0), "newDelegateKey == 0");

        if (newDelegateKey != msg.sender) {
            require(members[newDelegateKey].exists == 0, "!overwrite members");
            require(members[memberAddressByDelegateKey[newDelegateKey]].exists == 0, "!overwrite keys");
        }

        Member storage member = members[msg.sender];
        memberAddressByDelegateKey[member.delegateKey] = address(0);
        memberAddressByDelegateKey[newDelegateKey] = msg.sender;
        member.delegateKey = newDelegateKey;

        emit UpdateDelegateKey(msg.sender, newDelegateKey);
    }
    
    function canRagequit(uint256 highestIndexYesVote) public view returns (bool) {

        require(highestIndexYesVote < proposalQueue.length, "!proposal");
        
        return proposals[proposalQueue[highestIndexYesVote]].flags[1] == 1;
    }

    function hasVotingPeriodExpired(uint256 startingPeriod) public view returns (bool) {

        return getCurrentPeriod() >= startingPeriod.add(votingPeriodLength);
    }
    
    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x >= y ? x : y;
    }
    
    function getCurrentPeriod() public view returns (uint256) {

        return now.sub(summoningTime).div(periodDuration);
    }
    
    function getMemberProposalVote(address memberAddress, uint256 proposalIndex) external view returns (Vote) {

        require(members[memberAddress].exists == 1, "!member");
        require(proposalIndex < proposalQueue.length, "!proposed");
        
        return proposals[proposalQueue[proposalIndex]].votesByMember[memberAddress];
    }

    function getProposalFlags(uint256 proposalId) external view returns (uint8[7] memory) {

        return proposals[proposalId].flags;
    }
    
    function getProposalQueueLength() external view returns (uint256) {

        return proposalQueue.length;
    }
    
    function getTokenCount() external view returns (uint256) {

        return approvedTokens.length;
    }

    function getUserTokenBalance(address user, address token) external view returns (uint256) {

        return userTokenBalances[user][token];
    }
    
    function() external payable {}
    
    function fairShare(uint256 balance, uint256 shares, uint256 totalSharesAndLoot) internal pure returns (uint256) {

        require(totalSharesAndLoot != 0);

        if (balance == 0) { return 0; }

        uint256 prod = balance * shares;

        if (prod / balance == shares) { // no overflow in multiplication above?
            return prod / totalSharesAndLoot;
        }

        return (balance / totalSharesAndLoot) * shares;
    }
    
    function registerMember(address newMember, uint256 shares) internal {

        if (members[memberAddressByDelegateKey[newMember]].exists == 1) {
            address memberToOverride = memberAddressByDelegateKey[newMember];
            memberAddressByDelegateKey[memberToOverride] = memberToOverride;
            members[memberToOverride].delegateKey = memberToOverride;
        }
        
        members[newMember] = Member({
            delegateKey : newMember,
            exists : 1, // 'true'
            shares : shares,
            loot : 0,
            highestIndexYesVote : 0,
            jailed : 0
        });

        memberAddressByDelegateKey[newMember] = newMember;
    }
    
    function unsafeAddToBalance(address user, address token, uint256 amount) internal {

        userTokenBalances[user][token] += amount;
        userTokenBalances[TOTAL][token] += amount;
    }
    
    function unsafeInternalTransfer(address from, address to, address token, uint256 amount) internal {

        unsafeSubtractFromBalance(from, token, amount);
        unsafeAddToBalance(to, token, amount);
    }

    function unsafeSubtractFromBalance(address user, address token, uint256 amount) internal {

        userTokenBalances[user][token] -= amount;
        userTokenBalances[TOTAL][token] -= amount;
    }
    
    function allowance(address owner, address spender) external view returns (uint256) { // tracks guild token (loot) allowances 

        return allowances[owner][spender];
    }
    
    function balanceOf(address account) external view returns (uint256) { 

        return balances[account];
    }
    
    function totalSupply() public view returns (uint256) { 

        return totalShares.add(totalLoot);
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {

        require(amount == 0 || allowances[msg.sender][spender] == 0);
        
        allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        
        return true;
    }
    
    function burnGuildToken(address memberAddress, uint256 amount) internal {

        balances[memberAddress] = balances[memberAddress].sub(amount);
        
        emit Transfer(memberAddress, address(0), amount);
    }
    
    function claimShares(uint256 amount) external nonReentrant {

        IERC20(stakeToken).safeTransferFrom(msg.sender, address(this), amount); // deposit stake token & claim shares (1:1)
        
        if (members[msg.sender].exists == 1) {
            members[msg.sender].shares = members[msg.sender].shares.add(amount);

        } else {
            registerMember(msg.sender, amount);
        }

        mintGuildToken(msg.sender, amount);
        totalShares = totalShares.add(amount);
            
        require(totalShares <= MAX_GUILD_BOUND, "guild maxed");
    }
    
    function convertSharesToLoot(uint256 sharesToLoot) external nonReentrant {

        members[msg.sender].shares = members[msg.sender].shares.sub(sharesToLoot);
        members[msg.sender].loot = members[msg.sender].loot.add(sharesToLoot);
        totalShares = totalShares.sub(sharesToLoot);
        totalLoot = totalLoot.add(sharesToLoot);
    }
    
    function mintGuildToken(address memberAddress, uint256 amount) internal {

        balances[memberAddress] = balances[memberAddress].add(amount);
        
        emit Transfer(address(0), memberAddress, amount);
    }

    function transfer(address receiver, uint256 lootToTransfer) external returns (bool) {

        members[msg.sender].loot = members[msg.sender].loot.sub(lootToTransfer);
        members[receiver].loot = members[receiver].loot.add(lootToTransfer);
        
        balances[msg.sender] = balances[msg.sender].sub(lootToTransfer);
        balances[receiver] = balances[receiver].add(lootToTransfer);
        
        emit Transfer(msg.sender, receiver, lootToTransfer);
        
        return true;
    }
    
    function transferFrom(address sender, address receiver, uint256 lootToTransfer) external returns (bool) {

        allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(lootToTransfer);
        
        members[sender].loot = members[sender].loot.sub(lootToTransfer);
        members[receiver].loot = members[receiver].loot.add(lootToTransfer);
        
        balances[sender] = balances[sender].sub(lootToTransfer);
        balances[receiver] = balances[receiver].add(lootToTransfer);
        
        emit Transfer(sender, receiver, lootToTransfer);
        
        return true;
    }
}