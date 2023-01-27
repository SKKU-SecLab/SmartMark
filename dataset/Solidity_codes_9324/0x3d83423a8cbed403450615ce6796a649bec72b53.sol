
pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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


library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract IRewardDistributionRecipient is Ownable {

    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward, uint256 _duration) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {

        rewardDistribution = _rewardDistribution;
    }
}

contract BettingV2 is IRewardDistributionRecipient{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping (string => BetNChoices) bets;
    string[] betIds;

    address payable uniswapAddress;
    address payable yieldwarsAddress;

    struct BetChoice {
        uint32 choiceId;
        uint256 value;
        bool isClaimed;
        uint256 ethEarnings;
        uint256 timestamp;
    }

    struct BetNChoices {
        string  id;
        uint256  endTime;
        uint256  lastClaimTime;
        string desc;

        bool  isPaused;
        bool  isCanceled;
        bool  isFinal;
        bool  isFeesClaimed;

        uint32  winner;

        mapping(address => BetChoice)  bets;
        address[] betters;
        mapping(uint32 => uint256)  pots;

        mapping(string => uint32)  stringChoiceToId;
        mapping(uint32 => string)  choiceIdToString;

        uint256 totalPot;
        string[] possibleChoices;
    }

    struct BetCreationRequest {
        string id;
        string desc;
        uint256 endTime;
        uint256 lastClaimTime;

        string[] choices;
    }

    event ETHBetChoice(address indexed user, uint256 amount, string betId, string choice);
    event EarningsPaid(string betId, address indexed user, uint256 ethEarnings);

    modifier checkStatus(BetNChoices memory bet) {

        require(!bet.isFinal, "battle is decided");
        require(!bet.isCanceled, "battle is canceled, claim your bet");
        require(!bet.isPaused, "betting not started");
        require(block.timestamp < bet.endTime, "betting has ended");
        _;
    }

    constructor(address _rewardDistribution, address payable _uniswapAddress, address payable _yieldwarsAddress) public {
        require(_uniswapAddress != address(0));
        require(_yieldwarsAddress != address(0));
        uniswapAddress = _uniswapAddress;
        yieldwarsAddress = _yieldwarsAddress;

        rewardDistribution = _rewardDistribution;    
    }


    function createBet(string calldata _id, string calldata _desc, uint256 _endTime, uint256 _lastClaimTime, string calldata choice1, string calldata choice2) external onlyRewardDistribution {


        string[] memory choices = new string[](2);
        choices[0] = choice1;
        choices[1] = choice2;

        BetCreationRequest memory req = BetCreationRequest({
            id: _id,
            endTime: _endTime,
            lastClaimTime: _lastClaimTime,
            choices: choices,
            desc: _desc
        });

        _createBet(req);
    }

    function _createBet(BetCreationRequest memory req) internal {

        BetNChoices storage bet = bets[req.id];
        require(keccak256(bytes(bet.id)) == keccak256(bytes("")), "Bet already exists");
        require(req.lastClaimTime > req.endTime, "lastClaimTime must be greater than endTime");

        bet.id = req.id;
        bet.endTime = req.endTime;
        bet.lastClaimTime = req.lastClaimTime;
        bet.desc = req.desc;
        for (uint32 i = 1; i <= req.choices.length; i++) {
            bet.stringChoiceToId[req.choices[i-1]] = i;
            bet.choiceIdToString[i] = req.choices[i-1];
        }
        bet.possibleChoices = req.choices;
        betIds.push(bet.id);
    }


    function ETHBet(string memory betId, string memory choice) public payable {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        ETHBetOnBet(bet, choice);
    }

    function pauseBetting(string calldata betId) external onlyRewardDistribution {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        bet.isPaused = true;
    }

    function unpauseBetting(string calldata betId) external onlyRewardDistribution {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        bet.isPaused = false;
    }

    function cancelBet(string calldata betId) external onlyRewardDistribution {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(!bet.isFinal, "battle is decided");
        bets[betId].isCanceled = true;
    }

    function finalizeBet(string calldata betId, string calldata choice) external onlyRewardDistribution {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");

        uint32 choiceId = bet.stringChoiceToId[choice];
        require(choiceId != 0, "Invalid choice");

        require(!bet.isFinal, "battle is decided");
        require(!bet.isCanceled, "battle is canceled");

        bet.winner = choiceId;
        bet.isFinal = true;
    }

    function transferFees(string calldata betId) external onlyRewardDistribution {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(bet.isFinal, "bet is not final");
        require(!bet.isFeesClaimed, "fees claimed");

        bet.isFeesClaimed = true;

        uint256 pot = bet.totalPot.sub(bet.pots[bet.winner]);
        uint256 ethFees = pot.mul(1e19).div(1e20).div(2);

        if (ethFees != 0) {
            _safeTransfer(uniswapAddress, ethFees);
            _safeTransfer(yieldwarsAddress, ethFees);
        }
    }

    function updateAddresses(address payable _uniswapAddress, address payable _yieldwarsAddress) external onlyRewardDistribution {

        require(_uniswapAddress != address(0));
        require(_yieldwarsAddress != address(0));
        uniswapAddress = _uniswapAddress;
        yieldwarsAddress = _yieldwarsAddress;
    }

    function _safeTransfer(address payable to, uint256 amount) internal {

        uint256 balance;
        balance = address(this).balance;
        if (amount > balance) {
            amount = balance;
        }
        Address.sendValue(to, amount);
    }

    function ETHBetOnBet(BetNChoices storage bet, string memory choice) private checkStatus(bet) {

        require(msg.value != 0, "no ether sent");

        uint32 choiceId = bet.stringChoiceToId[choice];
        require(choiceId != 0, "invalid choice string");

        BetChoice storage currentBet = bet.bets[msg.sender];
        if (currentBet.choiceId == 0) {
            currentBet.choiceId = choiceId;
        } else {
            require(currentBet.choiceId == choiceId, "Sorry. You already bet on the other side with ETH");
        }
        if (currentBet.value == 0) {
            bet.betters.push(msg.sender);
        }
        currentBet.value += msg.value;
        currentBet.timestamp = block.timestamp;
        bet.pots[choiceId] += msg.value;
        bet.totalPot += msg.value;
        emit ETHBetChoice(msg.sender, msg.value, bet.id, choice);
    }

    function computeEarned(BetNChoices storage bet, BetChoice memory accountBet) private view returns (uint256 ethEarnings) {

        uint256 winningPot = bet.pots[bet.winner];
        uint256 totalWinnings = bet.totalPot.sub(winningPot);
        if (bet.isCanceled) {
            ethEarnings = accountBet.value;
        } else if (accountBet.choiceId != bet.winner || accountBet.value == 0) {
            ethEarnings = 0;
        } else if (!bet.isFinal){
            ethEarnings = 0;
        } else {
            uint256 winnings = totalWinnings.mul(accountBet.value).div(winningPot);
            uint256 fee = winnings.mul(1e19).div(1e20);
            ethEarnings = winnings.sub(fee);
            ethEarnings = ethEarnings.add(accountBet.value);
        }
    }

    function earned(string memory betId, address account) public view returns (uint256 ) {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(bet.isFinal || bet.isCanceled, "Bet is not finished");
        BetChoice memory accountBet = bet.bets[account];
        return computeEarned(bet, accountBet);
    }

    function getRewards(string memory betId) public {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(bet.isFinal || bet.isCanceled, "battle not decided");

        BetChoice storage accountBet = bet.bets[msg.sender];

        uint256 ethEarnings = earned(betId, msg.sender);
        if (ethEarnings != 0) {
            require(!accountBet.isClaimed, "Rewards already claimed");
            accountBet.isClaimed = true;
            accountBet.ethEarnings = ethEarnings;
            _safeTransfer(msg.sender, ethEarnings);
        }
        emit EarningsPaid(betId, msg.sender, ethEarnings);
    }

    struct OutstandingReward {
        string betId;
        uint256 value;
    }

    function listOutstandingRewards(address account) public view returns (OutstandingReward[] memory) {

        uint rewardCount = 0;
        for (uint i; i < betIds.length; i++) {
            BetNChoices memory bet = bets[betIds[i]];
            if (bet.isFinal) {
                uint256 reward = earned(bet.id, account);
                if (reward > 0) {
                    rewardCount++;
                }
            }
        }
        OutstandingReward[] memory rewards = new OutstandingReward[](rewardCount);
        uint r = 0;
        for (uint i; i < betIds.length; i++) {
            BetNChoices memory bet = bets[betIds[i]];
            if (bet.isFinal) {
                uint256 reward = earned(bet.id, account);
                if (reward > 0) {
                    rewards[r] = OutstandingReward(bet.id, reward);
                    r++;
                }
            }
        }

        return rewards;
    }

    function rescueFunds() external onlyRewardDistribution {

        require(betIds.length > 0, "sanity check with betIds.length");
        for (uint i = 0; i < betIds.length; i ++) {
            BetNChoices storage bet = bets[betIds[i]];
            require(block.timestamp >= bet.lastClaimTime, "not allowed yet");
        }

        Address.sendValue(msg.sender, address(this).balance);
    }
    
    struct GetBetChoiceResponse {
        address account;
        string choiceId;
        uint256 value;
        bool isClaimed;
        uint256 ethEarnings;
        bool won;
        uint256 timestamp;
    }

    struct GetBetPotResponse {
        string choice;
        uint256 value;
    }

    struct GetBetResponse {
        string  id;
        uint256  endTime;
        uint256  lastClaimTime;
        string desc;

        bool  isPaused;
        bool  isCanceled;
        bool  isFinal;
        bool  isFeesClaimed;

        string  winner;
        uint256 totalPot;

        string[] possibleChoices;
        GetBetChoiceResponse[] bets;
        GetBetPotResponse[] pots;
    }

    function getBet(string memory betId) public view returns (GetBetResponse memory response) {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");

        response.id = bet.id;
        response.endTime = bet.endTime;
        response.lastClaimTime = bet.lastClaimTime;
        response.isPaused = bet.isPaused;
        response.isCanceled = bet.isCanceled;
        response.isFinal = bet.isFinal;
        response.isFeesClaimed = bet.isFeesClaimed;

        if (bet.winner != 0) {
            response.winner = bet.choiceIdToString[bet.winner];
        }
        response.totalPot = bet.totalPot;
        response.possibleChoices = bet.possibleChoices;

        GetBetChoiceResponse[] memory betsResponse = new GetBetChoiceResponse[](bet.betters.length);

        for (uint i = 0; i < bet.betters.length; i++) {
            address account = bet.betters[i];
            BetChoice memory accountBet = bet.bets[account];

            betsResponse[i] = serializeBetChoice(bet, accountBet, account);
        }
        response.bets = betsResponse;

        GetBetPotResponse[] memory potsResponse = new GetBetPotResponse[](bet.possibleChoices.length);

        for (uint32 i = 0; i < bet.possibleChoices.length; i++ ) {
            uint32 choiceId = i + 1;
            string memory choiceStr = bet.choiceIdToString[choiceId];
            potsResponse[i] = GetBetPotResponse({
                choice: choiceStr,
                value: bet.pots[choiceId]
            });
        }

        response.pots = potsResponse;
    }
    struct BetHistoryResponse {
        string betId;
        GetBetChoiceResponse data;
    }

    function getBetHistory(address account) public view returns (BetHistoryResponse[] memory) {

        uint resultSize = 0;
        for (uint betId = 0; betId < betIds.length; betId++) {
            BetNChoices storage bet = bets[betIds[betId]];
            BetChoice memory accountBet = bet.bets[account];
            if ((bet.isFinal || bet.isCanceled) && accountBet.choiceId != 0 && accountBet.value != 0) {
                resultSize ++;
            }
        }
        
        BetHistoryResponse[] memory response = new BetHistoryResponse[](resultSize);
        uint i = 0;
        for (uint betId = 0; betId < betIds.length; betId++) {
            BetNChoices storage bet = bets[betIds[betId]];
            BetChoice memory accountBet = bet.bets[account];
            if ((bet.isFinal || bet.isCanceled) && accountBet.choiceId != 0 && accountBet.value != 0) {
                response[i].betId = bet.id;
                response[i].data = serializeBetChoice(bet, accountBet, account);
                i++;
            }
        }
        return response;
    }

    function serializeBetChoice(BetNChoices storage bet, BetChoice memory accountBet, address account) internal view returns (GetBetChoiceResponse memory) {

        bool won = false;

        if (bet.isFinal && !bet.isCanceled && accountBet.choiceId == bet.winner) {
            won = true;
        }

       return GetBetChoiceResponse({
            account: account,
            choiceId: bet.choiceIdToString[accountBet.choiceId],
            value: accountBet.value,
            isClaimed: accountBet.isClaimed,
            ethEarnings: computeEarned(bet, accountBet),
            won: won,
            timestamp: accountBet.timestamp
        });
    }

    function getCurrentBet(string memory betId, address accountAddress) public view returns (GetBetChoiceResponse memory) {

        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        BetChoice memory accountBet = bet.bets[accountAddress];
        require (accountBet.choiceId != 0 && accountBet.value != 0, "not found");

        return serializeBetChoice(bet, accountBet, accountAddress);
    }

    function getPots(string memory betId) public view returns (GetBetPotResponse[] memory) {

         BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");

        GetBetPotResponse[] memory potsResponse = new GetBetPotResponse[](bet.possibleChoices.length);

        for (uint32 i = 0; i < bet.possibleChoices.length; i++ ) {
            uint32 choiceId = i + 1;
            string memory choiceStr = bet.choiceIdToString[choiceId];
            potsResponse[i] = GetBetPotResponse({
                choice: choiceStr,
                value: bet.pots[choiceId]
            });
        }

        return potsResponse;
    }

    function notifyRewardAmount(uint256 reward, uint256 _duration) external { return; }


}