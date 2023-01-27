

pragma solidity ^0.5.0;


library SafeMathChainlink {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
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

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}

contract VRFRequestIDBase {


  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {

    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

contract VRFConsumerBase is VRFRequestIDBase {


  using SafeMathChainlink for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal;


  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
    internal returns (bytes32 requestId)
  {

    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal LINK;
  address private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {

    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

interface ILotteryDao {

    enum Era {
        EXPANSION,
        NEUTRAL,
        DEBT
    }

    function treasury() external view returns (address);

    function dollar() external view returns (address);

    function era() external view returns (Era, uint256);

    function epoch() external view returns (uint256);


    function requestDAI(address recipient, uint256 amount) external;

}

interface ILottery {

    function newGame(uint256[] calldata prizes) external;

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

contract Lottery is ILottery, VRFConsumerBase {

    using SafeMathChainlink for uint256;

    struct Purchase {
        uint256 ticketStart;
        uint256 ticketEnd;
    }

    struct Game {
        uint256 issuedTickets;
        uint256 totalPurchases;
        bool winnersExtracted;
        bool ongoing;
        address[] winners;
        uint256[] winningTickets;
        uint256[] prizes;
        bool[] rewardsRedeemed;

        mapping(address => uint256[]) players;
        mapping(uint256 => Purchase) purchases;
    }
    
    struct LinkVRF {
        bytes32 keyHash;
        uint256 fee;
    }

    ILotteryDao public dao;

    LinkVRF private link;

    uint256 public gameLength;
    mapping(uint256 => Game) public games;

    constructor()
        VRFConsumerBase(
            0xf0d54349aDdcf704F77AE15b96510dEA15cb7952, // VRF Coordinator
            0x514910771AF9Ca656af840dff83E8264EcF986CA  // LINK Token
        ) public
    {
        dao = ILotteryDao(0x0aF9087FE3e8e834F3339FE4bEE87705e84Fd488);
        link.fee = 2e18;
        link.keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
    }

    event GameStarted(uint256 indexed gameIndex, uint256[] prizes);
    event TicketsPurchase(address indexed sender, uint256 indexed purchaseId, uint256 indexed lotteryId, uint256 ticketStart, uint256 ticketEnd);
    event LotteryEnded(uint256 indexed lotteryId);
    event WinningTicketsSorted(uint256 indexed lotteryId, uint256[] winningTickets);
    event RewardRedeemed(address indexed recipient, uint256 indexed lotteryId, uint256 reward);

    modifier onlyDAO() {

        require(msg.sender == address(dao), "Lottery: sender isn't the DAO");
        _;
    }

    function gameIndex() public view returns (uint256) {

        return gameLength.sub(1);
    }

    function treasury() public view returns (address) {

        return dao.treasury();
    }

    function dollar() public view returns (IERC20) {

        return IERC20(dao.dollar());
    }

    function getWinners(uint256 gameIndex) external view returns(address[] memory) {

        return games[gameIndex].winners;
    }

    function getWinningTickets(uint256 gameIndex) external view returns(uint256[] memory) {

        return games[gameIndex].winningTickets;
    }

    function getPrizes(uint256 gameIndex) external view returns(uint256[] memory) {

        return games[gameIndex].prizes;
    }

    function getIssuedTickets(uint256 gameIndex) external view returns (uint256) {

        return games[gameIndex].issuedTickets;
    }

    function getRedeemedPrizes(uint256 gameIndex) external view returns(bool[] memory) {

        return games[gameIndex].rewardsRedeemed;
    }

    function isOngoing(uint256 gameIndex) external view returns(bool) {

        return games[gameIndex].ongoing;
    }

    function areWinnersExtracted(uint256 gameIndex) external view returns(bool) {

        return games[gameIndex].winnersExtracted;
    }

    function getTotalPurchases(uint256 gameIndex) external view returns(uint256) {

        return games[gameIndex].totalPurchases;
    }

    function getPlayerPurchaseIndexes(uint256 gameIndex, address player) external view returns(uint256[] memory) {

        return games[gameIndex].players[player];
    }

    function getPurchase(uint256 gameIndex, uint256 purchaseIndex) external view returns(uint256, uint256) {

        return (games[gameIndex].purchases[purchaseIndex].ticketStart, games[gameIndex].purchases[purchaseIndex].ticketEnd);
    }

    function newGame(uint256[] calldata prizes) external onlyDAO {   

        require(LINK.balanceOf(address(this)) >= link.fee, "Lottery: Insufficient link balance");

        if (gameLength > 0)
            require(games[gameIndex()].winnersExtracted, "Lottery: can't start a new lottery before the winner is extracted");

        games[gameLength].ongoing = true;
        games[gameLength].prizes = prizes;
        games[gameLength].winners = new address[](prizes.length);
        games[gameLength].rewardsRedeemed = new bool[](prizes.length);

        emit GameStarted(gameLength, prizes);

        gameLength++;
    }

    function changeChainlinkData(bytes32 keyHash, uint256 fee) external onlyDAO {

        link.keyHash = keyHash;
        link.fee = fee;
    }

    function purchaseTickets(uint256 amount) external {

        require(amount >= 10e18, "Lottery: Insufficient purchase amount");

        uint256 finalizedAmount = amount.sub(amount % 10e18);

        Game storage game = games[gameIndex()];

        require(game.ongoing, "Lottery: No ongoing game");

        dollar().transferFrom(msg.sender, treasury(), finalizedAmount);

        uint256 newTickets = finalizedAmount.div(10e18);

        Purchase memory purchase = Purchase(
            game.issuedTickets,
            game.issuedTickets.add(newTickets) - 1
        );

        game.players[msg.sender].push(game.totalPurchases);
        game.purchases[game.totalPurchases] = purchase;

        game.issuedTickets = game.issuedTickets.add(newTickets);

        emit TicketsPurchase(msg.sender, game.totalPurchases, gameIndex(), purchase.ticketStart, purchase.ticketEnd);

        game.totalPurchases += 1;
    }

    function extractWinner() external {

        Game storage game = games[gameIndex()];
        require(game.ongoing, "Lottery: winner already extracted");

        (ILotteryDao.Era era, uint256 start) = dao.era();
        require(era == ILotteryDao.Era.EXPANSION && dao.epoch() >= start + 3, "Lottery: Can only extract during expansion");

        game.ongoing = false;

        requestRandomness(link.keyHash, link.fee, uint256(keccak256(abi.encodePacked(block.number, block.difficulty, now))));

        emit LotteryEnded(gameIndex());
    }

    function redeemReward(uint256 gameIndex, uint256 purchaseIndex, uint256 winningTicket) external {

        Game storage game = games[gameIndex];

        require(game.winnersExtracted, "Lottery: winner hasn't been extracted yet");
        
        bool found;
        uint256 index;
        for (uint256 i = 0; i < game.winningTickets.length; i++) {
            if (winningTicket == game.winningTickets[i]) {
                found = true;
                index = i;
                break;
            }
        }

        require(found, "Lottery: winning ticket not found");
        require(!game.rewardsRedeemed[index], "Lottery: Reward already redeemed");

        game.rewardsRedeemed[index] = true;

        Purchase storage purchase = game.purchases[game.players[msg.sender][purchaseIndex]];

        require(purchase.ticketStart <= winningTicket && purchase.ticketEnd >= winningTicket, "Lottery: purchase doesn't contain the winning ticket");

        dao.requestDAI(msg.sender, game.prizes[index]);

        game.winners[index] = msg.sender;

        emit RewardRedeemed(msg.sender, gameIndex, game.prizes[index]);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal {

        Game storage game = games[gameIndex()];
        
        for (uint256 i = 0; i < game.prizes.length; i++) {
            game.winningTickets.push(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, randomness, game.prizes[i]))) % game.issuedTickets);
        }

        game.winnersExtracted = true;

        emit WinningTicketsSorted(gameIndex(), game.winningTickets);
    }

}