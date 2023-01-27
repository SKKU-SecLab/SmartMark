
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}//MIT
pragma solidity ^0.8.4;

interface IStaking{

    function getStakedBalance(address staker) external view returns(uint256);

    function getUnlockTime(address staker) external view returns(uint256);

    function isShutdown() external view returns(bool);

    function voted(address voter, uint256 endBlock) external returns(bool);

    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function emergencyShutdown(address admin) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.4;

interface IVITA is IERC20 {

    function mint(address account, uint256 amount) external;

}// MIT
pragma solidity ^0.8.4;


contract Raphael is ERC721Holder, Ownable, ReentrancyGuard {

    enum ProposalStatus {
        VOTING_NOT_STARTED,
        VOTING,
        VOTES_FINISHED,
        RESOLVED,
        CANCELLED,
        QUORUM_FAILED
    }

    struct Proposal {
        string details;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 startBlock;
        uint256 endBlock;
        ProposalStatus status;
    }

    mapping(uint256 => Proposal) private proposals;

    mapping(uint256 => mapping(address => bool)) private voted; //global voted mapping

    uint256 public proposalCount;

    uint256 private minVotesNeeded;
    address private nativeTokenAddress;
    address private stakingContractAddress;
    address[] private nftContractAddresses;

    bool private shutdown = false;

    uint256 public CREATE_TO_VOTE_PROPOSAL_DELAY = 13091; // ~2 days
    uint256 public VOTING_DURATION = 91636; // ~14 days

    uint256 public constant MIN_DURATION = 5; // ~ 1 minute
    uint256 public constant MAX_DURATION = 200000; // ~1 month

    event VotingDelayChanged(uint256 newDuration);
    event VotingDurationChanged(uint256 newDuration);
    event NativeTokenChanged(
        address newAddress,
        address oldAddress,
        address changedBy
    );
    event StakingAddressChanged(
        address newAddress,
        address oldAddress,
        address changedBy
    );
    event NativeTokenTransferred(
        address authorizedBy,
        address to,
        uint256 amount
    );
    event NFTReceived(address nftContract, address sender, uint256 tokenId);
    event NFTTransferred(address nftContract, address to, uint256 tokenId);
    event EmergencyShutdown(address triggeredBy, uint256 currentBlock);
    event EmergencyNFTApproval(
        address triggeredBy,
        address[] nftContractAddresses,
        uint256 startIndex,
        uint256 endIndex
    );
    event EmergencyNFTApprovalFail(address nftContractAddress);

    event ProposalCreated(
        uint256 proposalId,
        string details,
        uint256 vote_start,
        uint256 vote_end
    );
    event ProposalStatusChanged(uint256 proposalId, ProposalStatus newStatus);

    event Voted(address voter, uint256 proposalId, uint256 weight, bool direction);

    modifier notShutdown() {

        require(!shutdown, "cannot be called after shutdown");
        _;
    }

    modifier onlyShutdown() {

        require(shutdown, "can only call after shutdown");
        _;
    }

    constructor() Ownable() {
        proposalCount = 0; //starts with 0 proposals
        minVotesNeeded = 965390 * 1e18; // 5% of initial distribution
    }

    function getDidVote(uint256 proposalIndex) public view returns (bool) {

        return voted[proposalIndex][_msgSender()];
    }

    function getProposalData(uint256 proposalIndex)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256,
            uint256,
            uint8
        )
    {

        require(proposalIndex <= proposalCount && proposalIndex !=0, "Proposal doesn't exist");
        return (
            proposals[proposalIndex].details,
            proposals[proposalIndex].votesFor,
            proposals[proposalIndex].votesAgainst,
            proposals[proposalIndex].startBlock,
            proposals[proposalIndex].endBlock,
            uint8(proposals[proposalIndex].status)
        );
    }

    function getProposalResult(uint256 proposalIndex)
        public
        view
        returns (bool)
    {

        require(proposalIndex <= proposalCount && proposalIndex !=0, "Proposal doesn't exist");
        require(
            proposals[proposalIndex].status == ProposalStatus.VOTES_FINISHED ||
                proposals[proposalIndex].status == ProposalStatus.RESOLVED ||
                proposals[proposalIndex].status == ProposalStatus.QUORUM_FAILED,
            "Proposal must be after voting"
        );
        bool result; // is already false, only need to cover the true case
        if (proposals[proposalIndex].votesFor >
            proposals[proposalIndex].votesAgainst && (
                proposals[proposalIndex].status == ProposalStatus.VOTES_FINISHED ||
                proposals[proposalIndex].status == ProposalStatus.RESOLVED   
            )) {
            result = true;
        }

        return result;
    }

    function getMinVotesNeeded() public view returns (uint256) {

        return minVotesNeeded;
    }

    function getNativeTokenAddress() public view returns (address) {

        return nativeTokenAddress;
    }

    function getNativeTokenBalance() public view returns (uint256) {

        IVITA nativeTokenContract = IVITA(nativeTokenAddress);
        return nativeTokenContract.balanceOf(address(this));
    }

    function getNftContractAddresses() public view returns (address[] memory) {

        return nftContractAddresses;
    }

    function getStakingAddress() public view returns (address) {

        return stakingContractAddress;
    }

    function isShutdown() public view returns (bool) {

        return shutdown;
    }



    function setVotingDelayDuration(uint256 newDuration) public onlyOwner {

        require(
            newDuration > MIN_DURATION && newDuration < MAX_DURATION,
            "duration must be >5 <190000"
        );
        CREATE_TO_VOTE_PROPOSAL_DELAY = newDuration;

        emit VotingDelayChanged(newDuration);
    }

    function setVotingDuration(uint256 newDuration) public onlyOwner {

        require(
            newDuration > MIN_DURATION && newDuration < MAX_DURATION,
            "duration must be >5 <190000"
        );
        VOTING_DURATION = newDuration;

        emit VotingDurationChanged(newDuration);
    }

    function setMinVotesNeeded(uint256 newVotesNeeded)
        public
        onlyOwner
        notShutdown
    {

        IVITA nativeTokenContract = IVITA(nativeTokenAddress);
        require(newVotesNeeded > 0, "quorum cannot be 0");
        require(
            newVotesNeeded <= nativeTokenContract.totalSupply(),
            "votes needed > token supply"
        );
        minVotesNeeded = newVotesNeeded;
    }

    function setStakingAddress(address _stakingContractAddress)
        public
        onlyOwner
        notShutdown
    {

        address oldAddress = stakingContractAddress;
        stakingContractAddress = _stakingContractAddress;
        emit StakingAddressChanged(
            stakingContractAddress,
            oldAddress,
            _msgSender()
        );
    }

    function setNativeTokenAddress(address tokenContractAddress)
        public
        onlyOwner
        notShutdown
    {

        address oldAddress = nativeTokenAddress;
        nativeTokenAddress = tokenContractAddress;
        emit NativeTokenChanged(nativeTokenAddress, oldAddress, _msgSender());
    }


    function createProposal(string memory details)
        public
        notShutdown
        nonReentrant
    {

        IStaking stakingContract = IStaking(stakingContractAddress);
        require(
            stakingContract.getStakedBalance(_msgSender()) > 0,
            "must stake to create proposal"
        );
        uint256 start_block = block.number + CREATE_TO_VOTE_PROPOSAL_DELAY;
        uint256 end_block = start_block + VOTING_DURATION;

        Proposal memory newProposal =
            Proposal(
                details,
                0, //votesFor
                0, //votesAgainst
                start_block,
                end_block,
                ProposalStatus.VOTING_NOT_STARTED
            );

        require(
            stakingContract.voted(_msgSender(), newProposal.endBlock),
            "createProposal: token lock fail"
        );
        proposalCount += 1;
        proposals[proposalCount] = newProposal;


        emit ProposalCreated(proposalCount, details, start_block, end_block);
    }

    function updateProposalStatus(uint256 proposalIndex) public notShutdown {

        require(proposalIndex <= proposalCount && proposalIndex !=0, "Proposal doesn't exist");

        Proposal storage currentProp = proposals[proposalIndex];
        require(
            currentProp.status != ProposalStatus.CANCELLED,
            "Proposal cancelled"
        );
        require(
            currentProp.status != ProposalStatus.RESOLVED,
            "Proposal already resolved"
        );
        require(
            currentProp.status != ProposalStatus.QUORUM_FAILED,
            "Proposal failed to meet quorum"
        );

        if (
            currentProp.status == ProposalStatus.VOTING_NOT_STARTED &&
            block.number < currentProp.startBlock
        ) {
            revert("Too early to move to voting");
        } else if (
            currentProp.status == ProposalStatus.VOTING &&
            block.number >= currentProp.startBlock &&
            block.number <= currentProp.endBlock
        ) {
            revert("Still in voting period");
        }

        if (
            block.number >= currentProp.startBlock &&
            block.number <= currentProp.endBlock &&
            currentProp.status != ProposalStatus.VOTING
        ) {
            currentProp.status = ProposalStatus.VOTING;
        } else if (
            block.number < currentProp.startBlock &&
            currentProp.status != ProposalStatus.VOTING_NOT_STARTED
        ) {
            currentProp.status = ProposalStatus.VOTING_NOT_STARTED;
        } else if (
            block.number > currentProp.endBlock &&
            currentProp.status != ProposalStatus.VOTES_FINISHED
        ) {
            if (
                currentProp.votesFor + currentProp.votesAgainst >=
                minVotesNeeded
            ) {
                currentProp.status = ProposalStatus.VOTES_FINISHED;
            } else {
                currentProp.status = ProposalStatus.QUORUM_FAILED;
            }
        }

        proposals[proposalIndex] = currentProp;

        emit ProposalStatusChanged(proposalIndex, currentProp.status);
    }

    function setProposalToResolved(uint256 proposalIndex)
        public
        onlyOwner
        notShutdown
    {

        require(proposalIndex <= proposalCount && proposalIndex !=0, "Proposal doesn't exist");
        require(
            proposals[proposalIndex].status == ProposalStatus.VOTES_FINISHED,
            "Proposal not in VOTES_FINISHED"
        );
        proposals[proposalIndex].status = ProposalStatus.RESOLVED;
        emit ProposalStatusChanged(proposalIndex, ProposalStatus.RESOLVED);
    }

    function setProposalToCancelled(uint256 proposalIndex)
        public
        onlyOwner
        notShutdown
    {

        require(proposalIndex <= proposalCount && proposalIndex !=0, "Proposal doesn't exist");
        require(
            proposals[proposalIndex].status != ProposalStatus.VOTES_FINISHED,
            "Can't cancel if vote finished"
        );
        require(
            proposals[proposalIndex].status != ProposalStatus.RESOLVED,
            "Proposal already resolved"
        );
        require(
            proposals[proposalIndex].status != ProposalStatus.QUORUM_FAILED,
            "Proposal already failed quorum"
        );
        require(
            proposals[proposalIndex].status != ProposalStatus.CANCELLED,
            "Proposal already cancelled"
        );

        proposals[proposalIndex].status = ProposalStatus.CANCELLED;
        emit ProposalStatusChanged(proposalIndex, ProposalStatus.CANCELLED);
    }

    function vote(uint256 proposalIndex, bool _vote) public notShutdown nonReentrant {

        require(proposalIndex <= proposalCount && proposalIndex !=0, "Proposal doesn't exist");

        IStaking stakingContract = IStaking(stakingContractAddress);
        uint256 stakedBalance = stakingContract.getStakedBalance(_msgSender());
        require(stakedBalance > 0, "must stake to vote");
        require(
            voted[proposalIndex][_msgSender()] == false,
            "Already voted from this address"
        );

        Proposal storage currentProp = proposals[proposalIndex];

        require(
            currentProp.status == ProposalStatus.VOTING &&
                block.number <= currentProp.endBlock,
            "Proposal not in voting period"
        );

        if (_vote) {
            currentProp.votesFor += stakedBalance;
        } else {
            currentProp.votesAgainst += stakedBalance;
        }

        voted[proposalIndex][_msgSender()] = true;
        require(
            stakingContract.voted(
                _msgSender(),
                proposals[proposalIndex].endBlock
            ),
            "vote: token lock fail"
        );

        proposals[proposalIndex] = currentProp;

        emit Voted(_msgSender(), proposalIndex, stakedBalance, _vote);
    }


    function mintNativeToken(uint256 _amount) public onlyOwner notShutdown {

        require(_amount > 0, "Can't mint 0 tokens");
        IVITA nativeTokenContract = IVITA(nativeTokenAddress);
        
        nativeTokenContract.mint(address(this), _amount);
    } 

    function transferNativeToken(address to, uint256 amount)
        public
        onlyOwner
        notShutdown
        returns (bool)
    {

        IVITA nativeTokenContract = IVITA(nativeTokenAddress);
        require(
            nativeTokenContract.transfer(to, amount),
            "ERC20 transfer failed"
        );

        emit NativeTokenTransferred(_msgSender(), to, amount);
        return true;
    }

    function transferNFT(
        address nftContractAddress,
        address recipient,
        uint256 tokenId
    ) public onlyOwner notShutdown returns (bool) {

        IERC721 nftContract = IERC721(nftContractAddress);
        nftContract.safeTransferFrom(
            address(this),
            recipient,
            tokenId // what if there isn't one?
        );
        require(
            nftContract.ownerOf(tokenId) == recipient,
            "NFT transfer failed"
        );

        emit NFTTransferred(nftContractAddress, recipient, tokenId);
        return true;
    }


    function emergencyProposalCancellation(uint256 startIndex, uint256 endIndex) external onlyShutdown onlyOwner {

        require(endIndex > startIndex, "end index must be > start index");
        require(startIndex > 0, "starting index must exceed 0");
        require(endIndex <= proposalCount + 1, "end index > proposal count + 1");
        for (uint256 i = startIndex; i < endIndex; i++) {
            if (
                proposals[i].status != ProposalStatus.RESOLVED &&
                proposals[i].status != ProposalStatus.QUORUM_FAILED
            ) {
                proposals[i].status = ProposalStatus.CANCELLED;
                emit ProposalStatusChanged(i, ProposalStatus.CANCELLED);
            }
        }
    }

    function emergencyNftApproval(uint256 startIndex, uint256 endIndex) external onlyOwner onlyShutdown nonReentrant {

        require(endIndex > startIndex, "end index must be > start index");
        require(endIndex <= nftContractAddresses.length, "end index > nft array len");
        for (uint256 i = startIndex; i < endIndex; i++) {
            if (nftContractAddresses[i] != address(0)) {
                IERC721 nftContract = IERC721(nftContractAddresses[i]);
                if (!nftContract.isApprovedForAll(address(this), owner())) {
                    try nftContract.setApprovalForAll(owner(), true) {
                    } catch {
                        emit EmergencyNFTApprovalFail(nftContractAddresses[i]);
                    }
                }
            }
        }

        emit EmergencyNFTApproval(_msgSender(), nftContractAddresses, startIndex, endIndex);
    }

    function emergencyShutdown() public onlyOwner notShutdown nonReentrant {  

        IStaking stakingContract = IStaking(stakingContractAddress);
        stakingContract.emergencyShutdown(_msgSender());
        shutdown = true;
        emit EmergencyShutdown(_msgSender(), block.number);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public override notShutdown returns (bytes4) {

        nftContractAddresses.push(_msgSender());

        emit NFTReceived(_msgSender(), operator, tokenId);

        return super.onERC721Received(operator, from, tokenId, data);
    }
}