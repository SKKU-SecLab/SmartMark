
pragma solidity >=0.8.0;

interface IShaman {

    function memberAction(address member, uint96 loot, uint96 shares) external payable returns (uint96 lootOut, uint96 sharesOut);

}

contract Baal {

    bool public lootPaused; /*tracks transferability of `loot` economic weight - amendable through 'period'[2] proposal*/
    bool public sharesPaused; /*tracks transferability of erc20 `shares` - amendable through 'period'[2] proposal*/
    bool singleSummoner; /*internal flag to gauge speedy proposal processing*/
    
    uint8  constant public decimals = 18; /*unit scaling factor in erc20 `shares` accounting - '18' is default to match ETH & common erc20s*/
    uint16 constant MAX_GUILD_TOKEN_COUNT = 400; /*maximum number of whitelistable tokens subject to {ragequit}*/
    
    uint96 public totalLoot; /*counter for total `loot` economic weight held by `members`*/  
    uint96 public totalSupply; /*counter for total `members` voting `shares` with erc20 accounting*/
    
    uint32 public flashFeeNumerator; /*tracks 'fee' numerator for {flashLoan} in {flashFee} - e.g., '1 = 0.0001%'*/
    uint32 public gracePeriod; /*time delay after proposal voting period for processing*/
    uint32 public minVotingPeriod; /*minimum period for voting in seconds - amendable through 'period'[2] proposal*/
    uint32 public maxVotingPeriod; /*maximum period for voting in seconds - amendable through 'period'[2] proposal*/
    uint public proposalCount; /*counter for total `proposals` submitted*/
    uint status; /*internal reentrancy check tracking value*/
    
    string public name; /*'name' for erc20 `shares` accounting*/
    string public symbol; /*'symbol' for erc20 `shares` accounting*/
    
    bytes32 constant DOMAIN_TYPEHASH = keccak256('EIP712Domain(string name,uint chainId,address verifyingContract)'); /*EIP-712 typehash for Baal domain*/
    bytes32 constant DELEGATION_TYPEHASH = keccak256('Delegation(address delegatee,uint nonce,uint expiry)'); /*EIP-712 typehash for Baal delegation*/
    bytes32 constant PERMIT_TYPEHASH = keccak256('Permit(address owner,address spender,uint value,uint nonce,uint deadline)'); /*EIP-712 typehash for EIP-2612 {permit}*/
    bytes32 constant VOTE_TYPEHASH = keccak256('Vote(uint proposalId,bool support)'); /*EIP-712 typehash for Baal proposal vote*/
    
    address[] guildTokens; /*array list of erc20 tokens approved on summoning or by 'whitelist'[3] `proposals` for {ragequit} claims*/
    
    mapping(address => mapping(address => uint))    public allowance; /*maps approved pulls of `shares` with erc20 accounting*/
    mapping(address => uint)                        public balanceOf; /*maps `members` accounts to `shares` with erc20 accounting*/
    mapping(address => mapping(uint => Checkpoint)) public checkpoints; /*maps record of vote `checkpoints` for each account by index*/
    mapping(address => uint)                        public numCheckpoints; /*maps number of `checkpoints` for each account*/
    mapping(address => address)                     public delegates; /*maps record of each account's `shares` delegate*/
    mapping(address => uint)                        public nonces; /*maps record of states for signing & validating signatures*/
    
    mapping(address => Member) public members; /*maps `members` accounts to struct details*/
    mapping(uint => Proposal)  public proposals; /*maps `proposalCount` to struct details*/
    mapping(uint => bool)      public proposalsPassed; /*maps `proposalCount` to approval status - separated out as struct is deleted, and this value can be used by minion-like contracts*/
    mapping(address => bool)   public shamans; /*maps contracts approved in 'whitelist'[3] proposals for {memberAction} that mint or burn `shares`*/
    
    event SummonComplete(bool lootPaused, bool sharesPaused, uint gracePeriod, uint minVotingPeriod, uint maxVotingPeriod, string name, string symbol, address[] guildTokens, address[] shamans, address[] summoners, uint96[] loot, uint96[] shares); /*emits after Baal summoning*/
    event SubmitProposal(uint8 indexed flag, uint indexed proposal, uint indexed votingPeriod, address[] to, uint96[] value, bytes[] data, string details); /*emits after proposal is submitted*/
    event SponsorProposal(address indexed member, uint indexed proposal, uint indexed votingStarts); /*emits after member has sponsored proposal*/
    event SubmitVote(address indexed member, uint balance, uint indexed proposal, bool indexed approved); /*emits after vote is submitted on proposal*/
    event ProcessProposal(uint indexed proposal); /*emits when proposal is processed & executed*/
    event Ragequit(address indexed member, address to, uint96 indexed lootToBurn, uint96 indexed sharesToBurn); /*emits when users burn Baal `shares` and/or `loot` for given `to` account*/
    event Approval(address indexed owner, address indexed spender, uint amount); /*emits when Baal `shares` are approved for pulls with erc20 accounting*/
    event Transfer(address indexed from, address indexed to, uint amount); /*emits when Baal `shares` are minted, burned or transferred with erc20 accounting*/
    event TransferLoot(address indexed from, address indexed to, uint96 amount); /*emits when Baal `loot` is minted, burned or transferred*/
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate); /*emits when an account changes its voting delegate*/
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance); /*emits when a delegate account's voting balance changes*/
    
    modifier nonReentrant() { /*reentrancy guard*/

        require(status == 1,'reentrant'); 
        status = 2; 
        _;
        status = 1;
    }
    
    struct Checkpoint { /*Baal checkpoint for marking number of delegated votes*/
        uint32 fromTimeStamp; /*unix time for referencing voting balance*/
        uint96 votes; /*votes at given unix time*/
    }
 
    struct Member { /*Baal membership details*/
        uint96 loot; /*economic weight held by `members` - can be set on summoning & adjusted via {memberAction}*/
        uint highestIndexYesVote; /*highest proposal index on which a member `approved`*/
        mapping(uint => bool) voted; /*maps voting decisions on proposals by `members` account*/
    }
    
    struct Proposal { /*Baal proposal details*/
        uint32 votingPeriod; /*time for voting in seconds*/
        uint32 votingStarts; /*starting time for proposal in seconds since unix epoch*/
        uint32 votingEnds; /*termination time for proposal in seconds since unix epoch - derived from `votingPeriod` set on proposal*/
        uint96 yesVotes; /*counter for `members` `approved` 'votes' to calculate approval on processing*/
        uint96 noVotes; /*counter for `members` 'dis-approved' 'votes' to calculate approval on processing*/
        bool[4] flags; /*flags for proposal type & status - [action, member, period, whitelist]*/
        address[] to; /*account(s) that receive(s) Baal state updates*/
        uint96[] value; /*value(s) associated with Baal state updates (also used to toggle)*/
        bytes[] data; /*raw data associated with Baal state updates (also used to toggle)*/
        string details; /*human-readable context for proposal*/
    }

    constructor(
        bool             _sharesPaused,
        uint32           _gracePeriod,
        uint32           _minVotingPeriod, 
        uint32           _maxVotingPeriod,
        string    memory _name, 
        string    memory _symbol,
        address[] memory _guildTokens,
        address[] memory _shamans, 
        address[] memory _summoners, 
        uint96[]  memory _loot, 
        uint96[]  memory _shares
    ) {
        require(_minVotingPeriod != 0,'0_min'); /*check min. period isn't null*/
        require(_minVotingPeriod <= _maxVotingPeriod,'min>max'); /*check minimum period doesn't exceed max*/
        require(_guildTokens.length != 0,'0_tokens'); /*check approved tokens are not null*/
        require(_summoners.length != 0,'0_summoners'); /*check that there is at least 1 summoner*/
        require(_summoners.length == _loot.length && _loot.length == _shares.length,'!member array parity'); /*check `members`-related array lengths match*/
        
        unchecked {
            for (uint i; i < _shamans.length; i++) shamans[_shamans[i]] = true; /*update mapping of approved `shamans` in Baal*/
            for (uint i; i < _guildTokens.length; i++) guildTokens.push(_guildTokens[i]); /*update array of `guildTokens` approved for {ragequit}*/
            for (uint i; i < _summoners.length; i++) {
                _mintLoot(_summoners[i], _loot[i]); /*mint Baal `loot` to `summoners`*/
                _mintShares(_summoners[i], _shares[i]); /*mint Baal `shares` to `summoners`*/ 
                _delegate(_summoners[i], _summoners[i]); /*delegate `summoners` voting weights to themselves - this saves a step before voting*/
                if (_summoners.length == 1) singleSummoner = true; /*flag if Baal summoned singly for speedy processing*/
            }
        }
        
        gracePeriod = _gracePeriod; /*sets delay for processing proposal*/
        minVotingPeriod = _minVotingPeriod; /*set minimum voting period - adjustable via 'period'[2] proposal*/
        maxVotingPeriod = _maxVotingPeriod; /*set maximum voting period - adjustable via 'period'[2] proposal*/
        if (_sharesPaused) lootPaused = true; /*set initial transferability for `loot` - if `sharesPaused`, transfers are blocked*/
        sharesPaused = _sharesPaused; /*set initial transferability for `shares` tokens - if 'true', transfers are blocked*/
        name = _name; /*initialize Baal `name` with erc20 accounting*/
        symbol = _symbol; /*initialize Baal `symbol` with erc20 accounting*/
        status = 1; /*initialize 'reentrancy guard' status*/
        
        emit SummonComplete(lootPaused, _sharesPaused, _gracePeriod, _minVotingPeriod, _maxVotingPeriod, _name, _symbol, _guildTokens, _shamans, _summoners, _loot, _shares); /*emit event reflecting Baal summoning completed*/
    }

    function memberAction(
        address shaman, 
        uint96 loot, 
        uint96 shares, 
        bool mint
    ) external nonReentrant payable returns (uint96 lootOut, uint96 sharesOut) {

        require(shamans[shaman],'!shaman'); /*check `shaman` is approved*/
        
        (lootOut, sharesOut) = IShaman(shaman).memberAction{value: msg.value}(msg.sender, loot, shares); /*fetch 'reaction' per inputs*/
        
        if (mint) { /*execute `mint` actions*/
            if (lootOut != 0) _mintLoot(msg.sender, lootOut); /*add `loot` to user account & Baal total*/
            if (sharesOut != 0) _mintShares(msg.sender, sharesOut); /*add `shares` to user account & Baal total with erc20 accounting*/
        } else { /*otherwise, execute `burn` actions*/
            if (lootOut != 0) _burnLoot(msg.sender, lootOut); /*subtract `loot` from user account & Baal total*/
            if (sharesOut != 0) _burnShares(msg.sender, sharesOut); /*subtract `shares` from user account & Baal total with erc20 accounting*/
        }
    }
    
    function submitProposal(
        uint8 flag, 
        uint32 votingPeriod, 
        address[] calldata to, 
        uint96[] calldata value, 
        bytes[] calldata data, 
        string calldata details
    ) external nonReentrant returns (uint proposal) {

        require(minVotingPeriod <= votingPeriod && votingPeriod <= maxVotingPeriod,'!votingPeriod'); /*check voting period is within Baal bounds*/
        require(to.length <= 10,'array max'); /*limit executable actions to help avoid block gas limit errors on processing*/
        require(flag <= 3,'!flag'); /*check 'flag' is in bounds*/
        
        bool[4] memory flags; /*plant `flags` - [action, member, period, whitelist]*/
        flags[flag] = true; /*flag proposal type for struct storage*/ 
        
        if (flag == 2) {
            if (value.length == 1) {
                require(value[0] <= maxVotingPeriod,'over max');
            } else if (value.length == 2) {
                require(value[1] >= minVotingPeriod,'under min');
            }
        } else {
            require(to.length == value.length && value.length == data.length,'!array parity'); /*check array lengths match*/
        }
        
        bool selfSponsor; /*plant sponsor flag*/
        if (balanceOf[msg.sender] != 0) selfSponsor = true; /*if a member, self-sponsor*/

        unchecked {
            proposalCount++; /*increment proposal counter*/
            proposals[proposalCount] = Proposal( /*push params into proposal struct - start voting period timer if member submission*/
                votingPeriod,
                selfSponsor ? uint32(block.timestamp) : 0, 
                selfSponsor ? uint32(block.timestamp) + votingPeriod : 0, 
                0, 0, flags, to, value, data, details
            );
        }
        
        emit SubmitProposal(flag, proposal, votingPeriod, to, value, data, details); /*emit event reflecting proposal submission*/
    }
    
    function sponsorProposal(uint proposal) external nonReentrant {

        Proposal storage prop = proposals[proposal]; /*alias proposal storage pointers*/
        
        require(balanceOf[msg.sender] != 0,'!member'); /*check 'membership' - required to sponsor proposal*/
        require(prop.votingPeriod != 0,'!exist'); /*check proposal existence*/
        require(prop.votingStarts == 0,'sponsored'); /*check proposal not already sponsored*/
        
        prop.votingStarts = uint32(block.timestamp);
        
        unchecked {
            prop.votingEnds = uint32(block.timestamp) + prop.votingPeriod;
        }

        emit SponsorProposal(msg.sender, proposal, block.timestamp);
    }

    function submitVote(uint proposal, bool approved) external nonReentrant {

        Proposal storage prop = proposals[proposal]; /*alias proposal storage pointers*/
        
        uint96 balance = getPriorVotes(msg.sender, prop.votingStarts); /*fetch & gas-optimize voting weight at proposal creation time*/
        
        require(prop.votingEnds >= block.timestamp,'ended'); /*check voting period has not ended*/
        require(!members[msg.sender].voted[proposal],'voted'); /*check vote not already cast*/
        
        unchecked {
            if (approved) { /*if `approved`, cast delegated balance `yesVotes` to proposal*/
                prop.yesVotes += balance; 
                members[msg.sender].highestIndexYesVote = proposal;
            } else { /*otherwise, cast delegated balance `noVotes` to proposal*/
                prop.noVotes += balance;
            }
        }
        
        members[msg.sender].voted[proposal] = true; /*record voting action to `members` struct per user account*/

        emit SubmitVote(msg.sender, balance, proposal, approved); /*emit event reflecting vote*/
    }
    
    function submitVoteWithSig(
        uint proposal, 
        bool approved, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {

        Proposal storage prop = proposals[proposal]; /*alias proposal storage pointers*/
        
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), block.chainid, address(this))); /*calculate EIP-712 domain hash*/
        bytes32 structHash = keccak256(abi.encode(VOTE_TYPEHASH, proposal, approved)); /*calculate EIP-712 struct hash*/
        bytes32 digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash)); /*calculate EIP-712 digest for signature*/
        address signatory = ecrecover(digest, v, r, s); /*recover signer from hash data*/
        
        require(signatory != address(0),'!signatory'); /*check signer is not null*/
        
        uint96 balance = getPriorVotes(signatory, prop.votingStarts); /*fetch & gas-optimize voting weight at proposal creation time*/
        
        require(prop.votingEnds >= block.timestamp,'ended'); /*check voting period has not ended*/
        require(!members[signatory].voted[proposal],'voted'); /*check vote not already cast*/
        
        unchecked {
            if (approved) { /*if `approved`, cast delegated balance `yesVotes` to proposal*/
                prop.yesVotes += balance; members[signatory].highestIndexYesVote = proposal;
            } else { /*otherwise, cast delegated balance `noVotes` to proposal*/
                prop.noVotes += balance;
            }
        }
        
        members[signatory].voted[proposal] = true; /*record voting action to `members` struct per user account*/
        
        emit SubmitVote(signatory, balance, proposal, approved); /*emit event reflecting vote*/
    }
        
    function processProposal(uint proposal) external nonReentrant {

        Proposal storage prop = proposals[proposal]; /*alias `proposal` storage pointers*/
        
        _processingReady(proposal, prop); /*validate `proposal` processing requirements*/
        
        if (prop.yesVotes > prop.noVotes) /*check if `proposal` approved by simple majority of members*/
            proposalsPassed[proposal] = true; /*flag that proposal passed - allows minion-like extensions*/
            if (prop.flags[0]) processActionProposal(prop); /*check `flag`, execute 'action'*/
            else if (prop.flags[1]) processMemberProposal(prop); /*check `flag`, execute 'member'*/
            else if (prop.flags[2]) processPeriodProposal(prop); /*check `flag`, execute 'period'*/
            else processWhitelistProposal(prop); /*otherwise, execute 'whitelist'*/
            
        delete proposals[proposal]; /*delete given proposal struct details for gas refund & the commons*/
        
        emit ProcessProposal(proposal); /*emit event reflecting that given proposal processed*/
    }
    
    function processActionProposal(Proposal memory prop) private {

        unchecked {
            for (uint i; i < prop.to.length; i++) 
                prop.to[i].call{value:prop.value[i]} /*pass ETH value(s), if any*/
                (prop.data[i]); /*execute low-level call(s)*/
        }
    }
    
    function processMemberProposal(Proposal memory prop) private {

        unchecked {
            for (uint i; i < prop.to.length; i++) {
                if (prop.data[i].length == 0) {
                    _mintShares(prop.to[i], prop.value[i]); /*grant `to` `value` `shares`*/
                } else {
                    uint96 removedBalance = uint96(balanceOf[prop.to[i]]); /*gas-optimize variable*/
                    _burnShares(prop.to[i], removedBalance); /*burn all of `to` `shares` & convert into `loot`*/
                    _mintLoot(prop.to[i], removedBalance); /*mint equivalent `loot`*/
                }
            }
        }
    }
    
    function processPeriodProposal(Proposal memory prop) private {

        uint length = prop.value.length;
        
        if (length == 1) {
            if (prop.value[0] != 0) minVotingPeriod = uint32(prop.value[0]); /*if positive, reset min. voting period to first `value`*/ 
        } else if (length == 2) {
            if (prop.value[1] != 0) maxVotingPeriod = uint32(prop.value[1]); /*if positive, reset max. voting period to second `value`*/
        } else if (length == 3) {
            if (prop.value[2] != 0) gracePeriod = uint32(prop.value[2]); /*if positive, reset grace period to third `value`*/
        } else if (length == 4) {
            if (prop.value[3] != 0) flashFeeNumerator = uint32(prop.value[3]); /*if positive, reset grace period to fourth `value`*/
        } else if (length == 5) {
            prop.value[4] == 0 ? lootPaused = false : lootPaused = true; /*if positive, pause `loot` transfers on fifth `value`*/
        } else if (length == 6) {
            prop.value[5] == 0 ? sharesPaused = false : sharesPaused = true; /*if positive, pause `shares` transfers on sixth `value`*/
        }
    }  
        
    function processWhitelistProposal(Proposal memory prop) private {

        unchecked {
            for (uint i; i < prop.to.length; i++) {
                if (prop.value[i] == 0 && prop.data[i].length == 0) { /*if `value` & `data` are null, approve `shamans`*/
                    shamans[prop.to[i]] = true; /*add account(s) to `shamans` extensions*/
                } else if (prop.value[i] == 0 && prop.data[i].length != 0) { /*if `value` is null & `data` is populated, remove `shamans`*/
                    shamans[prop.to[i]] = false; /*remove account(s) from `shamans` extensions*/
                } else if (prop.value[i] != 0 && prop.data[i].length == 0) { /*if `value` is positive & `data` is null, add `guildTokens`*/
                    if (guildTokens.length != MAX_GUILD_TOKEN_COUNT) guildTokens.push(prop.to[i]); /*push account to `guildTokens` array if within 'MAX'*/
                }
            }
        }
    }
    
    function approve(address to, uint amount) external returns (bool success) {

        allowance[msg.sender][to] = amount; /*adjust `allowance`*/
        
        emit Approval(msg.sender, to, amount); /*emit event reflecting approval*/
        
        success = true; /*confirm approval with ERC-20 accounting*/
    }
    
    function delegate(address delegatee) external {

        _delegate(msg.sender, delegatee);
    }
    
    function delegateBySig(
        address delegatee, 
        uint nonce, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), block.chainid, address(this))); /*calculate EIP-712 domain hash*/
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, deadline)); /*calculate EIP-712 struct hash*/
        bytes32 digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash)); /*calculate EIP-712 digest for signature*/
        address signatory = ecrecover(digest, v, r, s); /*recover signer from hash data*/
            
        require(signatory != address(0),'!signatory'); /*check signer is not null*/
        unchecked {
            require(nonce == nonces[signatory]++,'!nonce'); /*check given `nonce` is next in `nonces`*/
        }
        require(block.timestamp <= deadline,'expired'); /*check signature is not expired*/
            
        _delegate(signatory, delegatee); /*execute delegation*/
    }

    function permit(
        address owner, 
        address spender, 
        uint96 amount, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), block.chainid, address(this))); /*calculate EIP-712 domain hash*/
        
        unchecked {
            bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline)); /*calculate EIP-712 struct hash*/
            bytes32 digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash)); /*calculate EIP-712 digest for signature*/
            address signatory = ecrecover(digest, v, r, s); /*recover signer from hash data*/
            require(signatory != address(0),'!signatory'); /*check signer is not null*/
            require(signatory == owner,'!authorized'); /*check signer is `owner`*/
        }
        
        require(block.timestamp <= deadline,'expired'); /*check signature is not expired*/
        
        allowance[owner][spender] = amount; /*adjust `allowance`*/
        
        emit Approval(owner, spender, amount); /*emit event reflecting approval*/
    }
    
    function transfer(address to, uint96 amount) external returns (bool success) {

        require(!sharesPaused,'!transferable');
        
        balanceOf[msg.sender] -= amount;
        
        unchecked {
            balanceOf[to] += amount;
        }
        
        _moveDelegates(delegates[msg.sender], delegates[to], amount);
        
        emit Transfer(msg.sender, to, amount);
        
        success = true;
    }
        
    function transferFrom(address from, address to, uint96 amount) external returns (bool success) {

        require(!sharesPaused,'!transferable');
        
        if (allowance[from][msg.sender] != type(uint).max) {
            allowance[from][msg.sender] -= amount;
        }
        
        balanceOf[from] -= amount;
        
        unchecked {
            balanceOf[to] += amount;
        }
        
        _moveDelegates(delegates[from], delegates[to], amount);
        
        emit Transfer(from, to, amount);
        
        success = true;
    }
    
    function transferLoot(address to, uint96 amount) external {

        require(!lootPaused,'!transferable');
        
        members[msg.sender].loot -= amount;
        
        unchecked {
            members[to].loot += amount;
        }
        
        emit TransferLoot(msg.sender, to, amount);
    }
    
    function flashLoan(
        address receiver,
        address token,
        uint amount,
        bytes calldata data
    ) external returns (bool success) {

        uint fee = flashFee(token, amount);
        require(fee != 0,'uninitialized');
        
        _safeTransfer(token, receiver, amount);
        
        (,bytes memory _flashData) = receiver.call(abi.encodeWithSelector(0x23e30c8b, msg.sender, token, amount, fee, data)); /*'onFlashLoan(address,address,uint,uint,bytes)'*/
        bytes32 flashData = abi.decode(_flashData, (bytes32));
        require(flashData == keccak256('ERC3156FlashBorrower.onFlashLoan'),'Callback failed'); /*checks flash loan success*/
        
        _safeTransferFrom(token, receiver, address(this), amount + fee);
        
        success = true;
    }

    function ragequit(address to, uint96 lootToBurn, uint96 sharesToBurn) external nonReentrant {

        require(proposals[members[msg.sender].highestIndexYesVote].votingEnds == 0,'processed'); /*check highest index proposal member approved has processed*/
        
        for (uint i; i < guildTokens.length; i++) {
            (,bytes memory balanceData) = guildTokens[i].staticcall(abi.encodeWithSelector(0x70a08231, address(this))); /*get Baal token balances - 'balanceOf(address)'*/
            uint balance = abi.decode(balanceData, (uint)); /*decode Baal token balances for calculation*/
            
            uint amountToRagequit = ((lootToBurn + sharesToBurn) * balance) / (totalSupply + totalLoot); /*calculate 'fair shair' claims*/
            
            if (amountToRagequit != 0) { /*gas optimization to allow higher maximum token limit*/
                _safeTransfer(guildTokens[i], to, amountToRagequit); /*execute 'safe' token transfer*/
            }
        }
        
        if (lootToBurn != 0) { /*gas optimization*/ 
            _burnLoot(msg.sender, lootToBurn); /*subtract `loot` from user account & Baal totals*/
        }
        
        if (sharesToBurn != 0) { /*gas optimization*/ 
            _burnShares(msg.sender, sharesToBurn);  /*subtract `shares` from user account & Baal totals with erc20 accounting*/
        }
        
        emit Ragequit(msg.sender, to, lootToBurn, sharesToBurn); /*event reflects claims made against Baal*/
    }

    function getCurrentVotes(address account) external view returns (uint96 votes) {

        uint nCheckpoints = numCheckpoints[account];
        unchecked { votes = nCheckpoints != 0 ? checkpoints[account][nCheckpoints - 1].votes : 0; }
    }
    
    function getPriorVotes(address account, uint timeStamp) public view returns (uint96 votes) {

        require(timeStamp < block.timestamp,'!determined');
        
        uint nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) return 0;
        
        unchecked {
            if (checkpoints[account][nCheckpoints - 1].fromTimeStamp <= timeStamp)
                return checkpoints[account][nCheckpoints - 1].votes; 
            if (checkpoints[account][0].fromTimeStamp > timeStamp) return 0;
            uint lower = 0; 
            uint upper = nCheckpoints - 1;
            while (upper > lower) {
                uint center = upper - (upper - lower) / 2;
                Checkpoint memory cp = checkpoints[account][center];
                if (cp.fromTimeStamp == timeStamp) return cp.votes; 
                else if (cp.fromTimeStamp < timeStamp) lower = center; 
                else upper = center - 1;
            }
            votes = checkpoints[account][lower].votes;
        }
    }
    
    function getGuildTokens() external view returns (address[] memory tokens) {

        tokens = guildTokens;
    }
    
    function getProposalFlags(uint proposal) external view returns (bool[4] memory flags) {

        flags = proposals[proposal].flags;
    }

    function flashFee(address, uint amount) public view returns (uint fee) {

        fee = amount * flashFeeNumerator / 10000; /*Calculate `fee` - precision factor '10000' derived from ERC-3156 'Flash Loan Reference'*/
    }
    
    function maxFlashLoan(address token) external view returns (uint max) {

        (,bytes memory balanceData) = token.staticcall(abi.encodeWithSelector(0x70a08231, address(this))); /*get Baal token balance - 'balanceOf(address)'*/
        max = abi.decode(balanceData, (uint)); /*decode Baal token balance for calculation*/
    }

    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {

        results = new bytes[](data.length);
        unchecked {
            for (uint256 i = 0; i < data.length; i++) {
                (bool success, bytes memory result) = address(this).delegatecall(data[i]);
                if (!success) {
                    if (result.length < 68) revert();
                    assembly { result := add(result, 0x04) }
                    revert(abi.decode(result, (string)));
                }
                results[i] = result;
            }
        }
    }

    function onERC721Received(address, address, uint, bytes calldata) external pure returns (bytes4 sig) {

        sig = 0x150b7a02; /*'onERC721Received(address,address,uint,bytes)'*/
    }
    
    function onERC1155Received(address, address, uint, uint, bytes calldata) external pure returns (bytes4 sig) {

        sig = 0xf23a6e61; /*'onERC1155Received(address,address,uint,uint,bytes)'*/
    }
    
    function onERC1155BatchReceived(address, address, uint[] calldata, uint[] calldata, bytes calldata) external pure returns (bytes4 sig) {

        sig = 0xbc197c81; /*'onERC1155BatchReceived(address,address,uint[],uint[],bytes)'*/
    }
    
    receive() external payable {}

    function _delegate(address delegator, address delegatee) private {

        address currentDelegate = delegates[delegator];
        
        delegates[delegator] = delegatee;
        
        _moveDelegates(currentDelegate, delegatee, uint96(balanceOf[delegator]));
        
        emit DelegateChanged(delegator, currentDelegate, delegatee);
    }
    
    function _moveDelegates(address srcRep, address dstRep, uint96 amount) private {

        unchecked {
            if (srcRep != dstRep && amount != 0) {
                if (srcRep != address(0)) {
                    uint srcRepNum = numCheckpoints[srcRep];
                    uint96 srcRepOld = srcRepNum != 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                    uint96 srcRepNew = srcRepOld - amount;
                    _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
                }
            
                if (dstRep != address(0)) {
                    uint dstRepNum = numCheckpoints[dstRep];
                    uint96 dstRepOld = dstRepNum != 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                    uint96 dstRepNew = dstRepOld + amount;
                    _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
                }
            }
        }
    }
    
    function _writeCheckpoint(address delegatee, uint nCheckpoints, uint96 oldVotes, uint96 newVotes) private {

        uint32 timeStamp = uint32(block.timestamp);
        
        unchecked {
            if (nCheckpoints != 0 && checkpoints[delegatee][nCheckpoints - 1].fromTimeStamp == timeStamp) {
                checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
            } else {
                checkpoints[delegatee][nCheckpoints] = Checkpoint(timeStamp, newVotes);
                numCheckpoints[delegatee] = nCheckpoints + 1;
            }
        }
        
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
    
    function _burnLoot(address from, uint96 loot) private {

        members[from].loot -= loot; /*subtract `loot` for `from` account*/
        
        unchecked {
            totalLoot -= loot; /*subtract from total Baal `loot`*/
        }
        
        emit TransferLoot(from, address(0), loot); /*emit event reflecting burn of `loot`*/
    }
    
    function _burnShares(address from, uint96 shares) private {

        balanceOf[from] -= shares; /*subtract `shares` for `from` account*/
        
        unchecked {
            totalSupply -= shares; /*subtract from total Baal `shares`*/
        }
        
        _moveDelegates(delegates[from], address(0), shares); /*update delegation*/
        
        emit Transfer(from, address(0), shares); /*emit event reflecting burn of `shares` with erc20 accounting*/
    }
    
    function _mintLoot(address to, uint96 loot) private {

        unchecked {
            if (totalSupply + loot <= type(uint96).max / 2) {
                members[to].loot += loot; /*add `loot` for `to` account*/
        
                totalLoot += loot; /*add to total Baal `loot`*/
            
                emit TransferLoot(address(0), to, loot); /*emit event reflecting mint of `loot`*/
            }
        }
    }
    
    function _mintShares(address to, uint96 shares) private {

        unchecked {
            if (totalSupply + shares <= type(uint96).max / 2) {
                balanceOf[to] += shares; /*add `shares` for `to` account*/
        
                totalSupply += shares; /*add to total Baal `shares`*/
            
                _moveDelegates(address(0), delegates[to], shares); /*update delegation*/
        
                emit Transfer(address(0), to, shares); /*emit event reflecting mint of `shares` with erc20 accounting*/
            }
        }
    }
 
    function _processingReady(uint proposal, Proposal memory prop) private view returns (bool ready) {

        unchecked {
            require(proposal <= proposalCount,'!exist'); /*check proposal exists*/
            require(proposals[proposal - 1].votingEnds == 0,'prev!processed'); /*check previous proposal has processed by deletion*/
            require(proposals[proposal].votingEnds != 0,'processed'); /*check given proposal has been sponsored & not yet processed by deletion*/
            if (singleSummoner) return true; /*if single member, process early*/
            if (prop.yesVotes > totalSupply / 2) return true; /*process early if majority member support*/
            require(prop.votingEnds + gracePeriod <= block.timestamp,'!ended'); /*check voting period has ended*/
            ready = true; /*otherwise, process if voting period done*/
        }
    }
    
    function _safeTransfer(address token, address to, uint amount) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, amount)); /*'transfer(address,uint)'*/
        require(success && (data.length == 0 || abi.decode(data, (bool))),'transfer failed'); /*checks success & allows non-conforming transfers*/
    }
    
    function _safeTransferFrom(address token, address from, address to, uint amount) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, amount)); /*'transferFrom(address,address,uint)'*/
        require(success && (data.length == 0 || abi.decode(data, (bool))),'transferFrom failed'); /*checks success & allows non-conforming transfers*/
    }
}