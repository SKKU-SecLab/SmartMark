
pragma solidity ^0.6.0;

contract BrandContest {


    mapping(uint256 => uint256) private _allowedVotingAmounts;

    mapping(address => bool) private _allowedTokenAddresses;

    mapping(address => mapping(uint256 => uint256)) private _votes;

    mapping(address => mapping(uint256 => uint256)) private _ethers;

    mapping(address => uint256) private _rewards;
    mapping(address => bool) private _redeemed;

    uint256 private _surveyEndBlock;

    event FirstVote(address indexed tokenAddress, uint256 indexed tokenId);

    event Vote(address indexed voter, address indexed tokenAddress, uint256 indexed tokenId, address creator, uint256 votes, uint256 amount);

    constructor(address[] memory allowedTokenAddresses, uint256 surveyEndBlock) public {
        for(uint256 i = 0; i < allowedTokenAddresses.length; i++) {
            _allowedTokenAddresses[allowedTokenAddresses[i]] = true;
        }
        _surveyEndBlock = surveyEndBlock;
        _allowedVotingAmounts[4000000000000000] = 1;
        _allowedVotingAmounts[30000000000000000] = 5;
        _allowedVotingAmounts[100000000000000000] = 10;
        _allowedVotingAmounts[300000000000000000] = 20;
    }

    function vote(address tokenAddress, uint256 tokenId, address payable creator) public payable {


        require(block.number < _surveyEndBlock, "Survey ended!");

        require(_allowedVotingAmounts[msg.value] > 0, "Vote must be 0.004, 0.03, 0.1 or 0.3 ethers");

        require(_allowedTokenAddresses[tokenAddress], "Unallowed Token Address!");

        require(IERC721(tokenAddress).ownerOf(tokenId) != address(0), "Owner is nobody, maybe wrong tokenId?");

        if(_votes[tokenAddress][tokenId] == 0) {
            emit FirstVote(tokenAddress, tokenId);
        }

        _votes[tokenAddress][tokenId] = _votes[tokenAddress][tokenId] + _allowedVotingAmounts[msg.value];
        _ethers[tokenAddress][tokenId] = _ethers[tokenAddress][tokenId] + msg.value;

        _rewards[creator] = msg.value + _rewards[creator];

        emit Vote(msg.sender, tokenAddress, tokenId, creator, _allowedVotingAmounts[msg.value], msg.value);
    }

    function getSurveyEndBlock() public view returns(uint256) {

        return _surveyEndBlock;
    }

    function redeemRewards() public {

        require(block.number >= _surveyEndBlock, "Survey is still running!");
        require(_rewards[msg.sender] > 0 && !_redeemed[msg.sender], "No rewards for you or already redeemed!");
        payable(msg.sender).transfer(_rewards[msg.sender]);
        _redeemed[msg.sender] = true;
    }
}

interface IERC721 {

    function ownerOf(uint256 _tokenId) external view returns (address);

}