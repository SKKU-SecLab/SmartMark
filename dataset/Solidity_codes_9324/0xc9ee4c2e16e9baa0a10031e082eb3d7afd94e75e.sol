

pragma solidity 0.7.4;


interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}

interface ITrollbox {

    function withdrawWinnings(uint voterId) external;

    function updateAccount(uint voterId, uint tournamentId, uint roundId) external;

    function isSynced(uint voterId, uint tournamentId, uint roundId) external view returns (bool);

    function roundAlreadyResolved(uint tournamentId, uint roundId) external view returns (bool);

    function resolveRound(uint tournamentId, uint roundId, uint winningOption) external;

    function getCurrentRoundId(uint tournamentId) external returns (uint);

}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ChainLinkOracle {


    struct Proposal {
        uint id;
        uint time;
        bool confirmed;
        uint roundId;
        uint winnerIndex;
        uint challengeWinnerIndex;
        address challenger;
    }

    mapping (bytes32 => address) public feedMap; // ticker symbol => price aggregator address
    mapping (bytes32 => int) public prices; // symbol => price
    mapping (uint => Proposal) public proposals;

    address public management;
    ITrollbox public trollbox;
    IERC20 public token;

    int constant public PRECISION = 1000000;
    uint public numProposals = 0;
    uint public challengeDeposit = 0;
    uint public challengePeriodSeconds = 60 * 60 * 24;
    uint public tournamentId = 1;

    bytes32[] public tickerSymbols;

    event FeedUpdated(bytes32 indexed key, address indexed feedAddr);
    event ManagementUpdated(address oldManagement, address newManagement);
    event DepositUpdated(uint oldDeposit, uint newDeposit);
    event ChallengePeriodUpdated(uint oldPeriod, uint newPeriod);
    event TickerSymbolsUpdated(bytes32[] oldKeys, bytes32[] newKeys);

    event WinnerProposed(uint indexed roundId, uint indexed proposalId, uint winnerIndex);
    event WinnerConfirmed(uint indexed roundId, uint indexed proposalId, int[] prices);

    event ChallengeMade(uint indexed proposalId, address indexed challenger, uint indexed claimedWinner);
    event ChallengerSlashed(uint indexed proposalId, address indexed challenger, uint indexed slashAmount);
    event ChallengerVindicated(uint indexed proposalId, address indexed challenger);

    modifier managementOnly() {

        require (msg.sender == management, 'Only management may call this');
        _;
    }

    modifier latestProposalConfirmed() {

        require (proposals[numProposals].confirmed == true || numProposals == 0, 'Unconfirmed proposal present');
        _;
    }

    constructor(address mgmt, address trollboxAddr, address tokenAddr, uint tournament, bytes32[] memory initialSymbols, int[] memory initialPrices) {
        management = mgmt;
        trollbox = ITrollbox(trollboxAddr);
        token = IERC20(tokenAddr);
        tournamentId = tournament;
        tickerSymbols = initialSymbols;
        setPricesInternal(initialPrices);
    }

    function setManagement(address newMgmt) public managementOnly {

        address oldMgmt = management;
        management =  newMgmt;
        emit ManagementUpdated(oldMgmt, newMgmt);
    }

    function setChallengeDeposit(uint newDeposit) public managementOnly latestProposalConfirmed {

        uint oldDeposit = challengeDeposit;
        challengeDeposit = newDeposit;
        emit DepositUpdated(oldDeposit, newDeposit);
    }

    function setChallengePeriod(uint newPeriod) public managementOnly latestProposalConfirmed {

        uint oldPeriod = challengePeriodSeconds;
        challengePeriodSeconds = newPeriod;
        emit ChallengePeriodUpdated(oldPeriod, newPeriod);
    }

    function setPricesInternal(int[] memory newPrices) internal {

        for (uint i = 0; i < tickerSymbols.length; i++) {
            prices[tickerSymbols[i]] = newPrices[i];
        }
    }

    function getTickerSymbols() public view returns (bytes32[] memory) {

        return tickerSymbols;
    }

    function setTickerSymbols(bytes32[] memory newKeys) public managementOnly latestProposalConfirmed {

        bytes32[] memory oldKeys = tickerSymbols;
        tickerSymbols = newKeys;
        emit TickerSymbolsUpdated(oldKeys, newKeys);
    }

    function addFeed(bytes32 key, address feedAddr) public managementOnly {

        feedMap[key] = feedAddr;
        emit FeedUpdated(key, feedAddr);
    }

    function getWinner() public view returns (int[] memory, uint) {

        int256 maxPriceDiff = -100 * PRECISION;
        uint winnerIndex = 0;
        int[] memory pricesLocal = new int[](tickerSymbols.length);
        for (uint i = 0; i < tickerSymbols.length; i++) {
            bytes32 key = tickerSymbols[i];
            int priceBefore = prices[key];
            AggregatorV3Interface chainlink = AggregatorV3Interface(feedMap[key]);
            (,int256 priceNow,,,) = chainlink.latestRoundData();
            pricesLocal[i] = priceNow;
            int256 priceDiff = ((priceNow - priceBefore) * PRECISION) / priceBefore;
            if (priceDiff > maxPriceDiff) {
                maxPriceDiff = priceDiff;
                winnerIndex = i + 1;
            }
        }
        return (pricesLocal, winnerIndex);
    }

    function proposeWinner(uint roundId) public latestProposalConfirmed {

        require(trollbox.roundAlreadyResolved(tournamentId, roundId) == false, 'Round already resolve');
        require(trollbox.getCurrentRoundId(tournamentId) > roundId + 1, 'Round not ready to resolve');
        Proposal storage proposal = proposals[++numProposals];
        proposal.id = numProposals;
        proposal.time = block.timestamp;
        proposal.roundId = roundId;
        (int[] memory newPrices, uint winnerIndex) = getWinner();
        setPricesInternal(newPrices);
        proposal.winnerIndex = winnerIndex;
        emit WinnerProposed(roundId, numProposals, proposal.winnerIndex);
    }

    function challengeWinner(uint proposalId, uint claimedWinner) public {

        token.transferFrom(msg.sender, address(this), challengeDeposit);
        Proposal storage proposal = proposals[proposalId];
        require(proposal.challenger == address(0), 'Proposal already challenged');
        require(claimedWinner != proposal.winnerIndex, 'Must claim different winner than proposed winner');
        require(block.timestamp - proposal.time < challengePeriodSeconds, 'Challenge period has passed');
        proposal.challenger = msg.sender;
        proposal.challengeWinnerIndex = claimedWinner;
        emit ChallengeMade(proposalId, msg.sender, claimedWinner);
    }

    function confirmWinnerUnchallenged(uint proposalId) public {

        Proposal memory proposal = proposals[proposalId];
        require(proposal.challenger == address(0), 'Proposal has been challenged');
        require(block.timestamp - proposal.time > challengePeriodSeconds, 'Challenge period has not passed');
        confirmWinnerInternal(proposalId);
    }

    function confirmWinnerChallenged(uint proposalId, uint chosenWinnerIndex, int[] memory localPrices) public managementOnly {

        Proposal storage proposal = proposals[proposalId];
        require(proposal.challenger != address(0), 'Proposal has not been challenged');
        require(chosenWinnerIndex <= tickerSymbols.length, 'Winner index out of range');
        require(chosenWinnerIndex > 0, 'Winner index must be positive');
        require(localPrices.length == tickerSymbols.length, 'Must specify prices for all ticker symbols');

        proposal.winnerIndex = chosenWinnerIndex;

        for (uint i = 0; i < tickerSymbols.length; i++) {
            prices[tickerSymbols[i]] = localPrices[i];
        }

        confirmWinnerInternal(proposalId);

        if (chosenWinnerIndex != proposal.challengeWinnerIndex) {
            token.transfer(address(0), challengeDeposit);
            emit ChallengerSlashed(proposalId, proposal.challenger, challengeDeposit);
        } else {
            token.transfer(proposal.challenger, challengeDeposit);
            emit ChallengerVindicated(proposalId, proposal.challenger);
        }
    }

    function confirmWinnerInternal(uint proposalId) internal {

        Proposal storage proposal = proposals[proposalId];
        require(proposal.id == proposalId, 'Invalid proposalId');
        require(proposal.confirmed == false, 'Already confirmed proposal');
        proposal.confirmed = true;
        int[] memory pricesLocal = new int[](tickerSymbols.length);
        for (uint i = 0; i < tickerSymbols.length; i++) {
            pricesLocal[i] = prices[tickerSymbols[i]];
        }
        emit WinnerConfirmed(proposal.roundId, proposalId, pricesLocal);
        trollbox.resolveRound(tournamentId, proposal.roundId, proposal.winnerIndex);
    }

}