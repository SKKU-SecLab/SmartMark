pragma solidity ^0.8.4;

interface IUniftyGovernanceConsumer{

    
    event Withdrawn(address indexed user, uint256 untEarned);

    function name() external view returns(string calldata);

    
    function description() external view returns(string calldata);

    
    function whitelistPeer(address _peer) external;

    
    function removePeerFromWhitelist(address _peer) external;

    
    function allocate(address _account, uint256 prevAllocation, address _peer) external returns(bool);

    
    function allocationUpdate(address _account, uint256 prevAmount, uint256 prevAllocation, address _peer) external returns(bool, uint256);

    
    function dellocate(address _account, uint256 prevAllocation, address _peer) external returns(uint256);

    
    function frozen(address _account) external view returns(bool);

    
    function peerWhitelisted(address _peer) external view returns(bool);

    
    function peerUri(address _peer) external view returns(string calldata);

    
    function timeToUnfreeze(address _account) external view returns(uint256);

    
    function apInfo(address _peer) external view returns(string memory, uint256, uint256[] memory);

    
    function withdraw() external returns(uint256);

    
    function earned(address _account) external view returns(uint256);

    
    function earnedLive(address _account) external view returns(uint256);

    
    function peerNifCap(address _peer) external view returns(uint256);

}pragma solidity ^0.8.4;

interface IERC20Simple {


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}pragma solidity ^0.8.4;

interface IERC20Mintable{


    function mint(address to, uint256 amount) external;

}pragma solidity ^0.8.4;



contract UniftyGovernance {


    
    address public nifAddress = 0x7e291890B01E5181f7ecC98D79ffBe12Ad23df9e;

    address public untAddress = 0xF8fCC10506ae0734dfd2029959b93E6ACe5b2a70;
    
    uint256 public epochDuration = 86400 * 30;

    uint256 public genesisReward = 50000000 * 10**18;
    
    uint256 public maxProposalDuration = 86400 * 7;

    uint256 public minProposalDuration = 86400 * 2;
    
    uint256 public proposalExecutionLimit = 86400 * 7;
    
    uint256 public quorum = 150000 * 10**18;
    
    uint256 public minNifStake = 10 * 10**18;

    uint256 public minNifOverallStake = 150000 * 10**18;

    uint256 public minNifConsumptionStake = 150000 * 10**18;

    uint256 public nifStakeTimelock = 86400 * 14;
    
    uint public graceTime = 60 * 15;
    
    
    mapping(address => LUniftyGovernance.NifStake) public userNifStakes;
    
    uint256 public proposalCounter;

    mapping(uint256 => LUniftyGovernance.Proposal) public proposals;

    mapping(uint256 => LUniftyGovernance.Uint256Proposal) public uint256Proposal;

    mapping(uint256 => LUniftyGovernance.AddressProposal) public addressProposal;

    mapping(uint256 => LUniftyGovernance.Vote[]) public votes;

    mapping(uint256 => uint256) public votesCounter;
    
    uint256 public allNifStakes;

    mapping(IUniftyGovernanceConsumer => mapping( address => uint256 ) ) public consumerPeerNifAllocation;
    
    mapping(IUniftyGovernanceConsumer => mapping( address => uint256 ) ) public nifAllocationLength;
    
    mapping(IUniftyGovernanceConsumer => uint256) public consumerNifAllocation;
    uint256 public nifAllocation;

    bool public pausing = false;

    uint256 public accrueStart;

    mapping(uint256 => LUniftyGovernance.Consumer) public consumers;
    
    mapping(address => bool) public peerExists;
    
    uint256 public consumerCounter = 1;

    mapping(IUniftyGovernanceConsumer => uint256) public consumerIdByType;
    
    mapping(IUniftyGovernanceConsumer => mapping( address => bool )) public consumerPeerExists;
    
    uint256 public grantedUnt;
    
    uint256 public mintedUnt;

    mapping(IUniftyGovernanceConsumer => uint256) public mintedUntConsumer;
    
    mapping(address => bool) public isExecutive;
    
    mapping(address => uint256) public credit;


    uint256 private unlocked = 1;

    modifier lock() {

        require(unlocked == 1, 'UniftyGovernance: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }


    event Allocated(address indexed user, IUniftyGovernanceConsumer consumer, address peer, uint256 untEarned);
    event Dellocated(address indexed user, IUniftyGovernanceConsumer consumer, address peer, uint256 untEarned);
    event Staked(address indexed user, uint256 stake, bool peerAccepted, uint256 untEarned);
    event Unstaked(address indexed user, uint256 unstake, bool peerAccepted, uint256 untEarned);
    event Withdrawn(address indexed user, uint256 amount);
    event Proposed(address indexed initiator, uint256 indexed proposalId, uint256 expires, uint256 actionId);
    event Voted(address indexed voter, uint256 indexed proposalId, uint256 indexed voteId, bool supporting, uint256 power);
    event Executed(address indexed executor, uint256 indexed proposalId);

    constructor(){

        accrueStart = block.timestamp;
        isExecutive[msg.sender] = true;
    }
    

    function stake(uint256 _stake) external lock returns(bool, uint256){


        require(!pausing, "stake: pausing, sorry.");
        require(_stake > 0, "stake: invalid staking amount.");

        bool accepted = true;
        uint256 untEarned = 0;

        uint256 prevAmount = userNifStakes[msg.sender].amount;
        userNifStakes[msg.sender].amount += _stake;
        userNifStakes[msg.sender].unstakableFrom = block.timestamp + nifStakeTimelock;
        
        allNifStakes += _stake;
        
        if(address(userNifStakes[msg.sender].peerConsumer) != address(0) && consumerIdByType[ userNifStakes[msg.sender].peerConsumer ] != 0){

            uint256 prevAllocation = consumerPeerNifAllocation[ userNifStakes[msg.sender].peerConsumer ][ userNifStakes[msg.sender].peer ];
            consumerPeerNifAllocation[ userNifStakes[msg.sender].peerConsumer ][ userNifStakes[msg.sender].peer ] += _stake;
            consumerNifAllocation[ userNifStakes[msg.sender].peerConsumer ] += _stake;
            nifAllocation += _stake;
            userNifStakes[msg.sender].peerAllocationTime = block.timestamp;
            
            try userNifStakes[msg.sender].peerConsumer.allocationUpdate(
                msg.sender, 
                prevAmount, 
                prevAllocation, 
                userNifStakes[msg.sender].peer
            ) 
                returns(bool _accepted, uint256 _untEarned)
            {
                
                accepted = _accepted;
                untEarned = _untEarned;
                
            } catch {}
            
            require(accepted, "stake: allocation update has been rejected.");
        }
        
        IERC20Simple(nifAddress).transferFrom(msg.sender, address(this), _stake);

        emit Staked(msg.sender, _stake, accepted, untEarned);
        
        return (accepted, untEarned);
    }
    
    function withdraw() external lock {
        
        require(pausing || block.timestamp >= userNifStakes[msg.sender].unstakableFrom + graceTime, "withdraw: nif still locked.");
        
        uint256 tmp = credit[msg.sender];
        credit[msg.sender] = 0;
        IERC20Simple(nifAddress).transfer(msg.sender, tmp);
        emit Withdrawn(msg.sender, tmp);
    }

    function unstake(uint256 _unstaking) external lock returns(bool, uint256){
        
        require(userNifStakes[msg.sender].amount > 0 && userNifStakes[msg.sender].amount >= _unstaking, "unstakeInternal: insufficient funds.");
        
        bool accepted = true;
        uint256 untEarned = 0;
        
        userNifStakes[msg.sender].unstakableFrom = block.timestamp + nifStakeTimelock;
        credit[msg.sender] += _unstaking;
        
        if(userNifStakes[msg.sender].amount - _unstaking == 0){
            
            untEarned = dellocateInternal(msg.sender);
            
            userNifStakes[msg.sender].amount -= _unstaking;
            allNifStakes -= _unstaking;
            
        }
        else if(
            userNifStakes[msg.sender].amount - _unstaking != 0 && 
            address(userNifStakes[msg.sender].peerConsumer) != address(0) && 
            consumerIdByType[ userNifStakes[msg.sender].peerConsumer ] != 0
        ) {
            
            uint256 prevAmount = userNifStakes[msg.sender].amount;
            userNifStakes[msg.sender].amount -= _unstaking;
            allNifStakes -= _unstaking;
            
            uint256 prevAllocation = consumerPeerNifAllocation[ userNifStakes[msg.sender].peerConsumer ][ userNifStakes[msg.sender].peer ];
            consumerPeerNifAllocation[ userNifStakes[msg.sender].peerConsumer ][ userNifStakes[msg.sender].peer ] -= _unstaking;
            consumerNifAllocation[ userNifStakes[msg.sender].peerConsumer ] -= _unstaking;
            nifAllocation -= _unstaking;
            
            userNifStakes[msg.sender].peerAllocationTime = block.timestamp;
            
            try userNifStakes[msg.sender].peerConsumer.allocationUpdate(
                msg.sender, 
                prevAmount, 
                prevAllocation, 
                userNifStakes[msg.sender].peer
            ) 
                returns(bool _accepted, uint256 _untEarned)
            {
                accepted = _accepted;
                untEarned = _untEarned;
                
            } catch {}
        }
        else
        {
            
            userNifStakes[msg.sender].amount -= _unstaking;
            allNifStakes -= _unstaking;
        }
        
        emit Unstaked(msg.sender, _unstaking, accepted, untEarned);
        return (accepted, untEarned);
    }
    
    function allocate(IUniftyGovernanceConsumer _consumer, address _peer) external lock returns(uint256) {
        
        require(!isPausing(), "allocate: pausing, sorry.");
        require(userNifStakes[msg.sender].amount > 0, "allocate: you must stake first.");
        require(_peer != address(0) && address(_consumer) != address(0), "allocate: peer and consumer mustn't be null." );
        require(consumerIdByType[ _consumer ] != 0, "allocate: consumer doesn't exist.");
        require(consumerPeerExists[ _consumer ][ _peer ], "allocate: peer doesn't exist.");
        require(userNifStakes[msg.sender].peer != _peer, "allocate: you are allocating to this peer already.");
        require(!frozen(msg.sender), "allocate: cannot dellocate, allocation still frozen by current consumer.");
        
        uint256 untEarned = dellocateInternal(msg.sender); 
        
        userNifStakes[msg.sender].peerConsumer = _consumer;
        userNifStakes[msg.sender].peer = _peer;
        userNifStakes[msg.sender].peerAllocationTime = block.timestamp;
        
        uint256 prevAllocation = consumerPeerNifAllocation[ _consumer ][ _peer ];
        consumerPeerNifAllocation[ _consumer ][ _peer ] += userNifStakes[msg.sender].amount;
        consumerNifAllocation[ _consumer ] += userNifStakes[msg.sender].amount;
        nifAllocation += userNifStakes[msg.sender].amount;
        nifAllocationLength[ userNifStakes[msg.sender].peerConsumer ][ userNifStakes[msg.sender].peer ] += 1;
        
        bool accepted = false;
        try _consumer.allocate(msg.sender, prevAllocation, _peer) returns(bool _accepted) { 
            accepted = _accepted;
        }
        catch{ }
        
        require(accepted, "allocate: allocation denied by consumer/peer or consumer is faulty.");
        
        emit Allocated(msg.sender, _consumer, _peer, untEarned);
        return untEarned;
    }
    
    function dellocate() external lock returns(uint256) {
        
        require(address(userNifStakes[msg.sender].peerConsumer) != address(0), "dellocatePeer: nothing to dellocate.");
        
        return dellocateInternal(msg.sender);
        
    }
    
    function dellocateInternal(address _sender) internal returns(uint256){
        
        if(address(userNifStakes[_sender].peerConsumer) == address(0)) { return 0; }
        
        require(!frozen(_sender) || pausing, "dellocateInternal: cannot dellocate, allocation still frozen by consumer.");
        
        IUniftyGovernanceConsumer tmpConsumer = userNifStakes[_sender].peerConsumer;
        address tmpPeer = userNifStakes[_sender].peer;
        uint256 untEarned = 0;
        
        uint256 prevAllocation = consumerPeerNifAllocation[ tmpConsumer ][ tmpPeer ];
        consumerPeerNifAllocation[ tmpConsumer ][ tmpPeer ] -= userNifStakes[_sender].amount;
        consumerNifAllocation[ tmpConsumer ] -= userNifStakes[_sender].amount;
        nifAllocation -= userNifStakes[_sender].amount;
        nifAllocationLength[ tmpConsumer ][ tmpPeer ] -= 1;
        
        userNifStakes[_sender].peerConsumer = IUniftyGovernanceConsumer(address(0));
        userNifStakes[_sender].peer = address(0);
        userNifStakes[_sender].peerAllocationTime = block.timestamp;
        
        if(consumerIdByType[ tmpConsumer ] != 0){
            try tmpConsumer.dellocate(_sender, prevAllocation, tmpPeer) returns(uint256 _untEarned){ 
                untEarned = _untEarned;
            }catch{ }
        }
        
        emit Dellocated(_sender, tmpConsumer, tmpPeer, untEarned);
        return untEarned;
    }
    
    function frozen(address _account) public view returns(bool){
        
        bool exists = consumerPeerExists[ userNifStakes[_account].peerConsumer ][ userNifStakes[_account].peer ];
        
        if(exists){
            
            
            bool existsInConsumer = false;
            
            try userNifStakes[_account].peerConsumer.peerWhitelisted( userNifStakes[_account].peer ) returns(bool result){
                
                existsInConsumer = result;
                
            }catch{}
            
            if(!existsInConsumer){
                
                return false;
            }
            
            
            try userNifStakes[_account].peerConsumer.frozen(_account) returns(bool result){
                
                return result;
                
            }catch{}
        }
        
        return false;
    }
    
    function accountInfo(address _account) external view returns(IUniftyGovernanceConsumer, address, uint256, uint256, uint256){
        
        bool exists = consumerPeerExists[ userNifStakes[_account].peerConsumer ][ userNifStakes[_account].peer ];
        
        IUniftyGovernanceConsumer consumer = userNifStakes[_account].peerConsumer;
        address peer = userNifStakes[_account].peer;
        uint256 allocationTime = userNifStakes[_account].peerAllocationTime;
        
        if(!exists){
            
            consumer = IUniftyGovernanceConsumer(address(0));
            peer = address(0);
            allocationTime = 0;
        }
        
        return ( 
            consumer,
            peer,  
            allocationTime,
            userNifStakes[_account].unstakableFrom,
            userNifStakes[_account].amount
        );
    }
    
    function consumerInfo(IUniftyGovernanceConsumer _consumer) external view returns(uint256, uint256, uint256, address[] memory){
        
        LUniftyGovernance.Consumer memory con = consumers[ consumerIdByType[ _consumer ] ];
        
        return ( 
            con.grantStartTime,
            con.grantRateSeconds,
            con.grantSizeUnt,
            con.peers
        );
    }


    function proposeMinNifOverallStake(uint256 _minNifOverallStake, uint256 _duration, string calldata _url) external lock{

        uint256 pid = newProposal(msg.sender, _duration, _url, 1);
        uint256Proposal[pid].value = _minNifOverallStake;
    }

    function proposeMinNifStake(uint256 _minNifStake, uint256 _duration, string calldata _url) external lock{

        uint256 pid = newProposal(msg.sender, _duration, _url, 2);
        uint256Proposal[pid].value = _minNifStake;
    }

    function proposeAddConsumer(IUniftyGovernanceConsumer _consumer, uint256 _sizeUnt, uint256 _rateSeconds, uint256 _startTime, uint256 _duration, string calldata _url) external lock{

        require(address(_consumer) != address(0), "proposeAddConsumer: consumer may not be the null address.");
        require(consumerIdByType[ _consumer ] == 0, "proposeAddConsumer: consumer exists already.");
        require(_rateSeconds != 0, "proposeAddConsumer: invalid rate");
        require(_sizeUnt != 0, "proposeAddConsumer: invalid grant size.");
      
        uint256 pid = newProposal(msg.sender, _duration, _url, 3);
        addressProposal[pid].value = address(_consumer);
        uint256Proposal[pid].value = _sizeUnt;
        uint256Proposal[pid].value3 = _rateSeconds;
        uint256Proposal[pid].value4 = _startTime;
    }

    function proposeRemoveConsumer(IUniftyGovernanceConsumer _consumer, uint256 _duration, string calldata _url) external lock{

        require(address(_consumer) != address(0), "proposeRemoveConsumer: consumer may not be the null address.");
        require(consumers[ consumerIdByType[ _consumer ] ].consumer == _consumer , "proposeRemoveConsumer: consumer not found.");
        uint256 pid = newProposal(msg.sender, _duration, _url, 4);
        addressProposal[pid].value = address(_consumer);
    }

    function proposeConsumerWhitelistPeer(IUniftyGovernanceConsumer _consumer, address _peer, uint256 _duration, string calldata _url) external lock{

        require(_peer != address(0), "proposeConsumerWhitelistPeer: peer may not be the null address.");
        require(!consumerPeerExists[ _consumer ][ _peer ], "proposeConsumerWhitelistPeer: peer exists already.");
        require(!peerExists[_peer], "proposeConsumerWhitelistPeer: peer exists already.");
        
        uint256 pid = newProposal(msg.sender, _duration, _url, 5);
        addressProposal[pid].value = _peer;
        addressProposal[pid].value3 = address(_consumer);
    }

    function proposeConsumerRemovePeerFromWhitelist(IUniftyGovernanceConsumer _consumer, address _peer, uint256 _duration, string calldata _url) external lock{

        require(address(_consumer) != address(0), "proposeConsumerRemovePeerFromWhitelist: consumer may not be the null address.");
        require(consumers[ consumerIdByType[ _consumer ] ].consumer == _consumer , "proposeConsumerRemovePeerFromWhitelist: consumer not found.");
        require(consumerPeerExists[ _consumer ][ _peer ], "proposeConsumerRemovePeerFromWhitelist: peer not found.");
        
        uint256 pid = newProposal(msg.sender, _duration, _url, 6);
        addressProposal[pid].value = _peer;
        addressProposal[pid].value2.push(address(_consumer));
    }
    
    function proposeUpdateConsumerGrant(IUniftyGovernanceConsumer _consumer, uint256 _sizeUnt, uint256 _rateSeconds, uint256 _startTime, uint256 _duration, string calldata _url) external lock{

        require(consumerIdByType[ _consumer ] != 0, "updateConsumerGrant: consumer doesn't exist.");
        require(_rateSeconds != 0, "updateConsumerGrant: invalid rate");
        require(_sizeUnt != 0, "proposeUpdateConsumerGrant: invalid grant size.");
        
        uint256 pid = newProposal(msg.sender, _duration, _url, 7);
        addressProposal[pid].value = address(_consumer);
        uint256Proposal[pid].value = _sizeUnt;
        uint256Proposal[pid].value3 = _rateSeconds;
        uint256Proposal[pid].value4 = _startTime;
    }
    
    function proposeMinNifConsumptionStake(uint256 _minNifConsumptionStake, uint256 _duration, string calldata _url) external lock{

        uint256 pid = newProposal(msg.sender, _duration, _url, 8);
        uint256Proposal[pid].value = _minNifConsumptionStake;
    }
    
    function proposeGeneral( uint256 _duration, string calldata _url) external lock{

       newProposal(msg.sender, _duration, _url, 9);
    }
    
    function proposeMaxProposalDuration( uint256 _maxProposalDuration, uint256 _duration, string calldata _url) external lock{

       uint256 pid = newProposal(msg.sender, _duration, _url, 10);
       uint256Proposal[pid].value = _maxProposalDuration;
    }
    
    function proposeMinProposalDuration( uint256 _minProposalDuration, uint256 _duration, string calldata _url) external lock{

       uint256 pid = newProposal(msg.sender, _duration, _url, 11);
       uint256Proposal[pid].value = _minProposalDuration;
    }
    
    function proposeProposalExecutionLimit(uint256 _proposalExecutionLimit, uint256 _duration, string calldata _url) external lock{

       uint256 pid = newProposal(msg.sender, _duration, _url, 12);
       uint256Proposal[pid].value = _proposalExecutionLimit;
    }
    
    function proposeQuorum(uint256 _quorum, uint256 _duration, string calldata _url) external lock{

       uint256 pid = newProposal(msg.sender, _duration, _url, 13);
       uint256Proposal[pid].value = _quorum;
    }
    
    function proposeNifStakeTimelock(uint256 _nifStakeTimelock, uint256 _duration, string calldata _url) external lock{

       uint256 pid = newProposal(msg.sender, _duration, _url, 14);
       uint256Proposal[pid].value = _nifStakeTimelock;
    }
    

    function newProposal(address _sender, uint256 _duration, string memory _url, uint256 _actionId) internal returns(uint256){

        require(!isPausing(), "newProposal: pausing, sorry.");
        require(_duration <= maxProposalDuration, "newProposal: duration too long.");
        require(_duration >= minProposalDuration, "newProposal: min. duration too short.");
        require(userNifStakes[_sender].amount >= minNifStake, "newProposal: invalid stake.");

        proposals[ proposalCounter ].initiator = _sender;
        proposals[ proposalCounter ].url = _url;
        proposals[ proposalCounter ].numVotes += 1;
        proposals[ proposalCounter ].numSupporting += userNifStakes[_sender].amount;
        proposals[ proposalCounter ].proposalId = proposalCounter;
        proposals[ proposalCounter ].voted[_sender] = true;
        proposals[ proposalCounter ].openUntil = block.timestamp + _duration;
        proposals[ proposalCounter ].actionId = _actionId;

        emit Proposed(_sender, proposalCounter, proposals[ proposalCounter ].openUntil, _actionId);

        votes[ proposalCounter ].push(LUniftyGovernance.Vote({
            voter: _sender,
            supporting: true,
            power: userNifStakes[_sender].amount,
            proposalId: proposalCounter,
            voteTime: block.timestamp
        }));
        
        emit Voted(_sender, proposalCounter, votesCounter[ proposalCounter ] + 1, true, userNifStakes[_sender].amount);

        uint256 ret = proposalCounter;


        votesCounter[ proposalCounter ] += 1;


        proposalCounter += 1;

        return ret;

    }

    function vote(uint256 _proposalId, bool _supporting) external lock {

        require(!isPausing(), "vote: pausing, sorry.");
        require(userNifStakes[msg.sender].amount >= minNifStake, "vote: invalid stake.");
        require(proposals[ _proposalId ].initiator != address(0) && block.timestamp <= proposals[ _proposalId ].openUntil, "vote: invalid or expired proposal.");
        require(!proposals[ _proposalId ].voted[msg.sender], "vote: you voted already.");

        proposals[ _proposalId ].numVotes += 1;

        if(_supporting){

            proposals[ _proposalId ].numSupporting += userNifStakes[msg.sender].amount;

        }else{

            proposals[ _proposalId ].numNotSupporting += userNifStakes[msg.sender].amount;
        }

        proposals[ _proposalId ].voted[msg.sender] = true;

        votes[ _proposalId ].push(LUniftyGovernance.Vote({
            voter: msg.sender,
            supporting: _supporting,
            power: userNifStakes[msg.sender].amount,
            proposalId: _proposalId,
            voteTime: block.timestamp
        }));

        emit Voted(msg.sender, _proposalId, votesCounter[ _proposalId ], _supporting, userNifStakes[msg.sender].amount);

        votesCounter[ _proposalId ] += 1;
    }
    
    function voted(uint256 _proposalId, address _account) external view returns(bool){
        
        return proposals[_proposalId].voted[_account];
    }
    
    function uint256ProposalInfo(uint256 _proposalId) external view returns(uint256, uint256, uint256, uint256[] memory){
      
        return (
            uint256Proposal[_proposalId].value,
            uint256Proposal[_proposalId].value3,
            uint256Proposal[_proposalId].value4,
            uint256Proposal[_proposalId].value2
        );
    }
    
    function addressProposalInfo(uint256 _proposalId) external view returns(address, address, address[] memory){
      
        return (
            addressProposal[_proposalId].value,
            addressProposal[_proposalId].value3,
            addressProposal[_proposalId].value2
        );
    }
    
    function execute(uint256 _proposalId) external lock{

        require(!isPausing(), "execute: pausing, sorry.");
        require(isExecutive[msg.sender], "execute: not an executive.");
        require(proposals[ _proposalId ].initiator != address(0), "execute: invalid proposal.");
        require(!proposals[ _proposalId ].executed, "execute: proposal has been executed already.");
        require(proposals[ _proposalId ].numSupporting + proposals[ _proposalId ].numNotSupporting >= quorum, "execute: quorum not reached.");
        require(proposals[ _proposalId ].numSupporting > proposals[ _proposalId ].numNotSupporting, "execute: not enough support.");
        require(proposals[ _proposalId ].numVotes > 1, "execute: need at least 2 votes.");
        require(block.timestamp > proposals[ _proposalId ].openUntil + graceTime, "execute: voting and grace time not yet ended.");
        require(block.timestamp < proposals[ _proposalId ].openUntil + graceTime + proposalExecutionLimit, "execute: execution window expired.");
        
        proposals[ _proposalId ].executed = true;

        if(proposals[ _proposalId ].actionId == 1){

            minNifOverallStake = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 2){

            minNifStake = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 8){

            minNifConsumptionStake = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 10){

            maxProposalDuration = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 11){

            minProposalDuration = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 12){

            proposalExecutionLimit = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 13){

            quorum = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 14){

            nifStakeTimelock = uint256Proposal[_proposalId].value;

        } else if(proposals[ _proposalId ].actionId == 3){

            require(consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value ) ] == 0, "execute: action id 3 => consumer exists already.");
            require(grantableUnt() >= uint256Proposal[_proposalId].value, "exeute: action id 3 => not enough available UNT." );
            require(uint256Proposal[_proposalId].value3 != 0, "execute: action id 3 => invalid rate");
            
            if(uint256Proposal[_proposalId].value4 < block.timestamp){
                
                uint256Proposal[_proposalId].value4 = block.timestamp;
            }

            grantedUnt += uint256Proposal[_proposalId].value;

            consumers[ consumerCounter ].consumer = IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value );
            consumers[ consumerCounter ].grantSizeUnt = uint256Proposal[_proposalId].value;
            consumers[ consumerCounter ].grantRateSeconds = uint256Proposal[_proposalId].value3;
            consumers[ consumerCounter ].grantStartTime = uint256Proposal[_proposalId].value4;
            
            consumerIdByType[ consumers[ consumerCounter ].consumer ] = consumerCounter;
            
            consumerCounter += 1;

        } else if(proposals[ _proposalId ].actionId == 4){
            
            LUniftyGovernance.Consumer memory tmp = consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value ) ] ];
            
            require( address( tmp.consumer ) != address(0), "execute: action id 4 => consumer not found." );
            
            for(uint256 i = 0; i < tmp.peers.length; i++){
                
                consumerPeerExists[ tmp.consumer ][ tmp.peers[i] ] = false;
                peerExists[ tmp.peers[i] ] = false;
            }
            
            grantedUnt -= tmp.grantSizeUnt;
            
            consumerIdByType[ consumers[ consumerCounter ].consumer ] = consumerIdByType[ tmp.consumer ];
            
            consumers[ consumerIdByType[ tmp.consumer ] ] = consumers[ consumerCounter ];
            
            consumerIdByType[ tmp.consumer ] = 0;
            
            consumers[ consumerCounter ].consumer = IUniftyGovernanceConsumer(address(0));
            consumers[ consumerCounter ].grantSizeUnt = 0;
            consumers[ consumerCounter ].grantRateSeconds = 0;
            consumers[ consumerCounter ].grantStartTime = 0;
            
            delete consumers[ consumerCounter ].peers;

            consumerCounter -= 1;
            
            for(uint256 i = 0; i < tmp.peers.length; i++){
                
                try tmp.consumer.removePeerFromWhitelist( tmp.peers[i] ){
                    
                }catch{}
            }
        
        } else if(proposals[ _proposalId ].actionId == 5){
            
            require( address( consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value3 ) ] ].consumer ) != address(0), "execute: action id 5 => consumer not found." );
            require(!consumerPeerExists[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value3 ) ][ addressProposal[ _proposalId ].value ], "execute: action id 5 => peer exists already.");
            require(!peerExists[addressProposal[ _proposalId ].value], "execute: action id 5 => peer exists already.");

            consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value3 ) ] ].peers.push( addressProposal[ _proposalId ].value );
            
            consumerPeerExists[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value3 ) ][ addressProposal[ _proposalId ].value ] = true;
            peerExists[addressProposal[ _proposalId ].value] = true;
            
            consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value3 ) ] ].consumer.whitelistPeer( addressProposal[ _proposalId ].value );
            
        } else if(proposals[ _proposalId ].actionId == 6){

            LUniftyGovernance.Consumer memory tmp = consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[_proposalId].value2[0] ) ] ];

            require( address( tmp.consumer ) != address(0), "execute: action id 6 => consumer not found." );
            require(consumerPeerExists[ tmp.consumer ][ addressProposal[ _proposalId ].value ], "execute: action id 6 => peer doesn't exist.");
            
            consumerPeerExists[ tmp.consumer ][ addressProposal[ _proposalId ].value ] = false;
            peerExists[addressProposal[ _proposalId ].value] = false;
           
            for(uint256 i = 0; i < tmp.peers.length; i++){
                
                if(addressProposal[ _proposalId ].value == tmp.peers[i]){
                    
                    consumers[ consumerIdByType[ tmp.consumer ] ].peers[i] = tmp.peers[ tmp.peers.length - 1 ];
                    
                    consumers[ consumerIdByType[ tmp.consumer ] ].peers.pop();
                   
                    try tmp.consumer.removePeerFromWhitelist( addressProposal[ _proposalId ].value ){
                        
                    }catch{}
                    
                    break;
                }
            }

        } else if(proposals[ _proposalId ].actionId == 7){
            
            require(consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value ) ] != 0, "execute: action id 7 => consumer doesn't exist.");
            
            grantedUnt -= consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value ) ] ].grantSizeUnt;
            
            require(grantableUnt() >= uint256Proposal[_proposalId].value, "exeute: action id 7 => not enough available UNT.");
            
            grantedUnt += uint256Proposal[_proposalId].value;
            
            require(uint256Proposal[_proposalId].value3 != 0, "execute: action id 7 => invalid rate");
            
            if(uint256Proposal[_proposalId].value4 < block.timestamp){
                
                uint256Proposal[_proposalId].value4 = block.timestamp;
            }
            
            consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value ) ] ].grantSizeUnt = uint256Proposal[_proposalId].value;
            consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value ) ] ].grantRateSeconds = uint256Proposal[_proposalId].value3;
            consumers[ consumerIdByType[ IUniftyGovernanceConsumer( addressProposal[ _proposalId ].value ) ] ].grantStartTime = uint256Proposal[_proposalId].value4;
            
        }

        emit Executed(msg.sender, _proposalId);

    }

    
    function epoch() public view returns(uint256){
        
        return 1 + ( ( block.timestamp - accrueStart ) / epochDuration );
    }
    
    function grantableUnt() public view returns(uint256){
        
        uint256 all = 0;
        uint256 _epoch = epoch();
        uint256 _prev = genesisReward;
        
        for(uint256 i = 0; i < _epoch; i++){
            
            all += _prev;
            _prev -= ( ( ( _prev * 10**18 ) / 100 ) * 5 ) / 10**18;
            
        }
        
        return all - grantedUnt;
    }
    
    function earnedUnt(IUniftyGovernanceConsumer _consumer) public view returns(uint256){
        
        if(consumerIdByType[ _consumer ] == 0) return 0;
        
        LUniftyGovernance.Consumer memory con = consumers[ consumerIdByType[ _consumer ] ];
        
        if(con.grantRateSeconds == 0) return 0;
        
        uint256 earned = ( ( ( ( block.timestamp - con.grantStartTime ) * 10 ** 18 ) / con.grantRateSeconds ) * con.grantSizeUnt ) / 10**18;
        
        if(earned > con.grantSizeUnt){
            
            return con.grantSizeUnt;
        }
        
        return earned;
    }
    
    function mintUnt(uint256 _amount) external {
        
        require(!isPausing(), "mintUnt: pausing, sorry.");
        require(consumerIdByType[ IUniftyGovernanceConsumer(msg.sender) ] != 0, "mintUnt: access denied.");
        require(allNifStakes >= minNifConsumptionStake, "mintUnt: not enough NIF staked in the governance yet.");
        
        uint256 mint = earnedUnt( IUniftyGovernanceConsumer(msg.sender) );
        
        require(mint != 0 && mint >= _amount, "mintUnt: nothing to mint.");
        
        consumers[ consumerIdByType[ IUniftyGovernanceConsumer(msg.sender) ] ].grantSizeUnt -= _amount;
        
        mintedUnt += _amount;
        mintedUntConsumer[IUniftyGovernanceConsumer(msg.sender)] += _amount;
        
        IERC20Mintable(untAddress).mint(msg.sender, _amount);
    }
    

    function isPausing() public view returns(bool){

        return pausing || allNifStakes < minNifOverallStake;
    }

    function setPaused(bool _pausing) external{

        require(isExecutive[msg.sender], "setPaused: not an executive.");

        pausing = _pausing;
    }

    function setExecutive(address _executive, bool _add) external{

        require(isExecutive[msg.sender], "addExecutive: not an executive.");
        
        if(_add){
            require(!isExecutive[_executive], "addExecutive: already an executive.");
        }else{
            require(msg.sender != _executive, "removeExecutive: you cannot remove yourself.");
        }
        
        isExecutive[_executive] = _add;
    }
}


library LUniftyGovernance{

    struct Proposal{
        address initiator;              // the initializing party
        bool executed;                  // yet executed or not?
        uint256 numVotes;               // overall votes
        uint256 numSupporting;          // overall votes in support
        uint256 numNotSupporting;       // overall votes not in support
        uint256 openUntil;              // when will the proposal be expired? timestamp in the future
        uint256 proposalId;             // the proposal ID, value taken from proposalCounter
        uint256 actionId;               // the action id to be executed (resolves to use the right function, e.g. 1 is MinNifOverallStakeProposal)
        string url;                     // the url that points to a json file (in opensea format), containing further information like description
        mapping(address => bool) voted; // voter => bool (voting party has voted?)
    }

    struct Vote{
        address voter;                 // the actual voting party
        bool supporting;               // support yes/no
        uint256 power;                 // the power of this vote
        uint256 proposalId;            // referring proposalId
        uint256 voteTime;              // time of the vote
    }

    struct Uint256Proposal{
        uint256 value;
        uint256 value3;
        uint256 value4;
        uint256[] value2;
    }

    struct AddressProposal{
        address value;
        address value3;
        address[] value2;
    }

    struct NifStake{

        address user;                  // the user who is staking
        IUniftyGovernanceConsumer peerConsumer; // the consumer of the peer below (optional but if, then both must be set)
        address peer;                  // the peer that this stake allocated to (optional)
        uint256 peerAllocationTime;    // the time when the allocation happened, else 0
        uint256 unstakableFrom;        // timestamp from which the user is allowed to unstake
        uint256 amount;                // the amount of nif that is being staked
    }

    struct Consumer{
 
        IUniftyGovernanceConsumer consumer;   // the consumer object
        uint256 grantStartTime;
        uint256 grantRateSeconds;
        uint256 grantSizeUnt;
        address[] peers;               // array of allowed consumer's peers to receive emissions
    }
}