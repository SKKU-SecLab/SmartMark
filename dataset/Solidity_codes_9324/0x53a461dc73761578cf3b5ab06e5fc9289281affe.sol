
pragma solidity ^0.7.0;

contract QuickscopeVote {

    uint256 private _startBlock;
    uint256 private _endBlock;

    address[] private _votingTokens;

    mapping(address => mapping(address => mapping(bool => uint256))) private _votes;
    mapping(address => bool) private _redeemed;

    uint256 private _accepts;
    uint256 private _refuses;

    event Vote(address indexed voter, address indexed votingToken, bool indexed accept, uint256 votingTokenPosition, uint256 amount);

    constructor(
        uint256 startBlock,
        uint256 endBlock,
        address[] memory votingTokens
    ) {
        _startBlock = startBlock;
        _endBlock = endBlock;
        _votingTokens = votingTokens;
    }

    function startBlock() public view returns (uint256) {

        return _startBlock;
    }

    function endBlock() public view returns (uint256) {

        return _endBlock;
    }

    function votingTokens() public view returns (address[] memory) {

        return _votingTokens;
    }

    function votes() public view returns (uint256 accepts, uint256 refuses) {

        return (_accepts, _refuses);
    }

    function votes(address voter) public view returns (uint256[] memory addressAccepts, uint256[] memory addressRefuses) {

        addressAccepts = new uint256[](_votingTokens.length);
        addressRefuses = new uint256[](_votingTokens.length);
        for(uint256 i = 0; i < _votingTokens.length; i++) {
            addressAccepts[i] = _votes[voter][_votingTokens[i]][true];
            addressRefuses[i] = _votes[voter][_votingTokens[i]][false];
        }
    }

    function redeemed(address voter) public view returns (bool) {

        return _redeemed[voter];
    }

    function vote(bool accept, uint256 votingTokenPosition, uint256 amount) public {

        require(block.number >= _startBlock, "Survey not yet started");
        require(block.number < _endBlock, "Survey has ended");

        address votingTokenAddress = _votingTokens[votingTokenPosition];

        IERC20(votingTokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        _votes[msg.sender][votingTokenAddress][accept] = _votes[msg.sender][votingTokenAddress][accept] + amount;
        if(accept) {
            _accepts += amount;
        } else {
            _refuses += amount;
        }
        emit Vote(msg.sender, votingTokenAddress, accept, votingTokenPosition, amount);
    }

    function redeemVotingTokens(address voter) public {

        require(block.number >= _startBlock, "Survey not yet started");
        require(block.number >= _endBlock, "Survey is still running");
        require(!_redeemed[voter], "This voter already redeemed his stake");
        (uint256[] memory voterAccepts, uint256[] memory voterRefuses) = votes(voter);
        for(uint256 i = 0; i < _votingTokens.length; i++) {
            uint256 totalVotesByToken = voterAccepts[i] + voterRefuses[i];
            if(totalVotesByToken > 0) {
                IERC20(_votingTokens[i]).transfer(voter, totalVotesByToken);
            }
        }
        _redeemed[voter] = true;
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function burn(uint256 amount) external;

}