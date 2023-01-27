pragma solidity ^0.6.9;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(),"Not Owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.6.9;

library EnumerableSet {


    struct AddressSet {
        address[] _values;

        mapping (address => uint256) _indexes;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            address lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return set._indexes[value] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return set._values.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}
pragma solidity ^0.6.9;


interface IWhitelist {

    function address_belongs(address _who) external view returns (address);

    function getUserWallets(address _which) external view returns (address[] memory);

}

interface IERC20Token {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

}

interface IGovernanceProxy {

    function trigger(address contr, bytes calldata params) external;

    function acceptGovernanceAddress() external;

}

contract Governance is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet walletsCEO;    // wallets of CEO. It should participate in votes with Absolute majority, otherwise Escrowed wallets will not be counted.
    uint256 public requiredCEO;             // number COE wallets require to participate in vote

    IGovernanceProxy public governanceProxy;
    IERC20Token[4] public tokenContract; // tokenContract[0] = MainToken, tokenContract[1] = ETN, tokenContract[2] = STOCK
    IERC20Token[4] public escrowContract; // contract that hold (lock) investor's pre-minted tokens (0-Main, 1-ETN, 2-STOCK)
    uint256[4] public circulationSupply;   // Circulation Supply of according tokens
    uint256[4] public circulationSupplyUpdated; // timestamp when Circulation Supply was updated
    IWhitelist public whitelist;    // whitelist contract
    uint256 public closeTime;   // timestamp when votes will close
    uint256 public expeditedLevel = 10; // user who has this percentage of Main token circulation supply can expedite voting
    uint256 public absoluteLevel = 90; // this percentage of participants voting power considering as Absolute Majority

    enum Vote {None, Yea, Nay}
    enum Status {New, Canceled, Approved, Rejected, Pending}

    struct Rule {
        address contr;      // contract address which have to be triggered
        uint8[4] majority;  // require more than this percentage of participants voting power (in according tokens).
        string funcAbi;     // function ABI (ex. "setGroupBonusRatio(uint256)")
    }

    Rule[] rules;

    struct Ballot {
        uint256 closeVote; // timestamp when vote will close
        uint256 ruleId; // rule which edit
        bytes args; // ABI encoded arguments for proposal which is required to call appropriate function
        Status status;
        address creator;    // wallet address of ballot creator.
        uint256[4] votesYea;  // YEA votes according communities (tokens)
        uint256[4] totalVotes;  // The total voting power od all participant according communities (tokens)
        address[] participant;  // the users who voted (primary address)
        uint256 processedParticipants; // The number of participant that was verified. Uses to split verification on many transactions
        mapping (address => Vote) votes; //Vote: Yea or Nay. If None -the user did not vote.
        mapping (address => mapping (uint256 => uint256)) power;   // Voting power. primary address => community index => voting power
        uint256 ceoParticipate; //number of ceo wallets participated at voting
    }

    Ballot[] ballots;

    uint256 public unprocessedBallot; // The start index of ballots which are unprocessed and maybe ready for vote.

    mapping (address => bool) public blockedWallets;    // The wallets which are excluded from voting
    mapping (uint256 => mapping(address => bool)) public isInEscrow;    // The wallets which may has pre-minted tokens. Token index => wallet
    mapping (uint256 => address[]) excluded; // The list of address that should be subtracted from TotalSupply to calculate Circulation Supply.

    event AddRule(address indexed contractAddress, string funcAbi, uint8[4] majorMain);
    event SetNewAddress(address indexed previousAddress, address indexed newAddress);
    event BlockWallet(address indexed walletAddress, bool isAdded);
    event AddBallot(address indexed creator, uint256 indexed ruleId, uint256 indexed ballotId);
    event ExpeditedBallot(uint256 indexed ballotId, uint256 indexed closeTime);
    event ApplyBallot(uint256 indexed ruleId, uint256 indexed ballotId);
    event NewVote(address indexed voter, address indexed primary, uint256 indexed ballotId);
    event ChangeVote(address indexed voter, address indexed primary, uint256 indexed ballotId);
    event PosableMajority(uint256 indexed ballotId);
    event CEOWallet(address indexed wallet, bool add);

    modifier onlyCEO() {

        require(walletsCEO.contains(msg.sender),"Not CEO");
        _;
    }

    constructor(address CEO_wallet) public {
        require(CEO_wallet != address(0),"Zero address not allowed");
        rules.push(Rule(address(this), [90,0,0,0], "addRule(address,uint8[4],string)"));
        walletsCEO.add(CEO_wallet);
        requiredCEO = 1;
    }


    function addCEOWallet(address CEO_wallet) external onlyCEO {

        require(CEO_wallet != address(0),"Zero address not allowed");
        walletsCEO.add(CEO_wallet);
        requiredCEO = walletsCEO.length();
        emit CEOWallet(CEO_wallet, true);
    }

    function removeCEOWallet(address CEO_wallet) external onlyCEO {

        require(CEO_wallet != address(0),"Zero address not allowed");
        require(walletsCEO.length() > 1, "Should left at least one CEO wallet");
        walletsCEO.remove(CEO_wallet);
        requiredCEO = walletsCEO.length();
        emit CEOWallet(CEO_wallet, false);
    }

    function setRequiredCEO(uint256 req) external onlyCEO {

        require(req <= walletsCEO.length(),"More then added wallets");
        requiredCEO = req;
    }

    function getWalletsCEO() external view returns(address[] memory wallets) {

        return walletsCEO._values;
    }

    function acceptGovernanceAddress() external onlyOwner {

        governanceProxy.acceptGovernanceAddress();
    }

    function getExcluded(uint256 index) external view returns(address[] memory) {

        require(index >= 0 && index < 4, "Wrong index");
        return excluded[index];
    }

    function addExcluded(uint256 index, address[] memory wallet) external onlyOwner {

        require(index >= 0 && index < 4, "Wrong index");
        for (uint i = 0; i < wallet.length; i++) {
            require(wallet[i] != address(0),"Zero address not allowed");
            excluded[index].push(wallet[i]);
        }
    }

    function removeExcluded(uint256 index, address wallet) external onlyOwner {

        require(index >= 0 && index < 4, "Wrong index");
        require(wallet != address(0),"Zero address not allowed");
        uint len = excluded[index].length;
        for (uint i = 0; i < len; i++) {
            if (excluded[index][i] == wallet) {
                excluded[index][i] = excluded[index][len-1];
                excluded[index].pop();
            }
        }
    }

    function setAbsoluteLevel(uint256 level) external onlyOwner {

        require(level > 50 && level <= 100, "Wrong level");
        absoluteLevel = level;
    }

    function setExpeditedLevel(uint256 level) external onlyOwner {

        require(level >= 1 && level <= 100, "Wrong level");
        expeditedLevel = level;
    }

    function manageBlockedWallet(address wallet, bool add) external onlyOwner {

        emit BlockWallet(wallet, add);
        blockedWallets[wallet] = add;
    }

    function setTokenContract(IERC20Token token, uint index) external onlyOwner {

        require(token != IERC20Token(0) && tokenContract[index] == IERC20Token(0),"Change address not allowed");
        tokenContract[index] = token;
    }

    function setEscrowContract(IERC20Token escrow, uint index) external onlyOwner {

        require(escrow != IERC20Token(0),"Change address not allowed");
        escrowContract[index] = escrow;
    }

    function setWhitelist(address newAddr) external onlyOwner {

        require(newAddr != address(0),"Zero address not allowed");
        emit SetNewAddress(address(whitelist), newAddr);
        whitelist = IWhitelist(newAddr);
    }

    function setGovernanceProxy(address newAddr) external onlyOwner {

        require(newAddr != address(0),"Zero address not allowed");
        emit SetNewAddress(address(governanceProxy), newAddr);
        governanceProxy = IGovernanceProxy(newAddr);
    }

    function updateCloseTime() external {

        require(closeTime < block.timestamp, "Wait for 1st day of month"); // close time is not passed
        (uint year, uint month, uint day) = timestampToDate(block.timestamp);
        day = 1;
        if (month == 12) {
            year++;
            month = 1;
        }
        else {
            month++;
        }
        closeTime = timestampFromDateTime(year, month, day, 0, 0, 0);    // 1st day of each month at 00:00:00 UTC
        uint len = ballots.length;
        for (uint i = unprocessedBallot; i < len; i++) {
            if (ballots[i].status == Status.Pending) {
                if(ballots[i].closeVote == 0)
                    ballots[i].closeVote = closeTime;
                else
                    ballots[i].closeVote += closeTime; // Expedited vote
                ballots[i].status = Status.New;
            }
        }
    }

    function addPremintedWallet(address wallet) external returns(bool){

        for (uint i = 0; i < 4; i++ ) {
            if(address(escrowContract[i]) == msg.sender) {
                isInEscrow[i][wallet] = true;
                return true;
            }
        }
        return false;
    }

    function addRule(
            address contr,
            uint8[4] memory majority,
            string memory funcAbi
        ) external onlyOwner {

        require(contr != address(0), "Zero address");
        rules.push(Rule(contr, majority, funcAbi));
        emit AddRule(contr, funcAbi, majority);
    }

    function changeRuleMajority(uint256 ruleId, uint8[4] memory majority) external onlyOwner {

        Rule storage r = rules[ruleId];
        r.majority = majority;
    }

    function changeRuleAddress(uint256 ruleId, address contr) external onlyOwner {

        require(contr != address(0), "Zero address");
        Rule storage r = rules[ruleId];
        r.contr = contr;
    }

    function getTotalRules() external view returns(uint256) {

        return rules.length;
    }

    function getRule(uint256 ruleId) external view
        returns(address contr,
        uint8[4] memory majority,
        string memory funcAbi)
    {

        Rule storage r = rules[ruleId];
        return (r.contr, r.majority, r.funcAbi);
    }

    function getTotalBallots() external view returns(uint256) {

        return ballots.length;
    }

    function getBallot(uint256 ballotId)
        external view returns(
        uint256 closeVote,
        uint256 ruleId,
        bytes memory args,
        Status status,
        address creator,
        uint256[4] memory totalVotes,
        uint256[4] memory votesYea)
    {

        Ballot storage b = ballots[ballotId];
        return (b.closeVote, b.ruleId, b.args, b.status, b.creator,b.totalVotes,b.votesYea);
    }

    function getParticipantsNumber(uint256 ballotId) external view returns(uint256) {

        return ballots[ballotId].participant.length;
    }

    function getParticipants(uint256 ballotId, uint256 start, uint256 number) external view
        returns(address[] memory participants,
        uint256[] memory mainVotes,
        uint256[] memory etnVotes,
        uint256[] memory stockVotes,
        Vote[] memory votes)
    {

        Ballot storage b = ballots[ballotId];
        participants = new address[](number);
        mainVotes = new uint256[](number);
        etnVotes = new uint256[](number);
        stockVotes = new uint256[](number);
        votes = new Vote[](number);
        uint256 len = number;
        if (start + number > b.participant.length)
            len = b.participant.length - start;
        for(uint i = 0; i < len; i++) {
            participants[i] = b.participant[start + i];
            mainVotes[i] = b.power[participants[i]][0]; // voting power in community A (Main token)
            etnVotes[i] = b.power[participants[i]][1]; // voting power in community B (ETN token)
            stockVotes[i] = b.power[participants[i]][2]; // voting power in community C (STOCK token)
            votes[i] = b.votes[participants[i]];
        }
    }

    function createBallot(uint256 ruleId, bytes memory args, bool isExpedited) external {

        require(ruleId < rules.length,"Wrong rule ID");
        Rule storage r = rules[ruleId];
        _getCirculation(r.majority);   //require update circulationSupply of Main token
        (address primary, uint256[4] memory power) = _getVotingPower(msg.sender, r.majority, false, true);
        uint256 highestPercentage;
        for (uint i = 0; i < 4; i++) {
            if (circulationSupply[i] > 0) {
                uint256 percentage = power[i] * 100 / circulationSupply[i]; // ownership percentage of token
                if (percentage > highestPercentage) highestPercentage = percentage;
            }
        }
        require(highestPercentage > 0, "Less then 1% of circulationSupply");
        uint256 ballotId = ballots.length;
        Ballot memory b;
        b.ruleId = ruleId;
        b.args = args;
        b.creator = msg.sender;
        b.votesYea = power;
        b.totalVotes = power;

        if(highestPercentage >= expeditedLevel && isExpedited && r.majority[0] < absoluteLevel) {
            b.closeVote = 24 hours;
        }

        if (block.timestamp + 24 hours <= closeTime) {
            if(b.closeVote == 0)
                b.closeVote = closeTime;
            else {
                b.closeVote += block.timestamp; // Expedited vote
                emit ExpeditedBallot(ballotId, b.closeVote);
            }
        }
        else {
            b.status = Status.Pending;
        }
        ballots.push(b);
        emit AddBallot(msg.sender, ruleId, ballotId);
        ballots[ballotId].participant.push(primary); // add creator primary address as participant
        ballots[ballotId].votes[primary] = Vote.Yea;
        for (uint i = 0; i < 4; i++) {
            if (power[i] > 0) {
                ballots[ballotId].power[primary][i] = power[i];
            }
        }
        emit NewVote(msg.sender, primary, ballotId);

        if (highestPercentage >= 50) {
            if (_checkMajority(r.majority, power, power, false) == Vote.Yea) { // check Instant execution
                ballots[ballotId].status = Status.Approved;
                _executeBallot(ballotId);
            }
        }
    }

    function cancelBallot(uint256 ballotId) external {

        require(ballotId < ballots.length,"Wrong ballot ID");
        Ballot storage b = ballots[ballotId];
        require(msg.sender == b.creator,"Only creator can cancel");
        b.closeVote = block.timestamp;
        b.status = Status.Canceled;
        if (unprocessedBallot == ballotId) unprocessedBallot++;
    }

    function vote(uint256 ballotId, Vote v) external {

        require(ballotId < ballots.length,"Wrong ballot ID");
        Ballot storage b = ballots[ballotId];
        require(v != Vote.None, "Should vote Yea or Nay");
        require(b.status == Status.New, "Voting for disallowed");
        require(b.closeVote > block.timestamp, "Ballot expired");
        (address primary, uint256[4] memory power) = _getVotingPower(msg.sender, rules[b.ruleId].majority, false, true);
        if (b.votes[primary] == Vote.None) {
            b.participant.push(primary); // add creator primary address as participant
            b.votes[primary] = v;
            for (uint i = 0; i < 4; i++) {
                if (power[i] > 0) {
                    b.power[primary][i] = power[i];  // store user's voting power
                    b.totalVotes[i] += power[i];
                    if (v == Vote.Yea)
                        b.votesYea[i] += power[i];
                }
            }
            if (rules[b.ruleId].majority[0] >= absoluteLevel && walletsCEO.contains(msg.sender)) {
                b.ceoParticipate++;
            }
            emit NewVote(msg.sender, primary, ballotId);
        }
        else if (b.votes[primary] != v) {
            b.votes[primary] = v;
            for (uint i = 0; i < 4; i++) {
                if (power[i] > 0) {
                    if (v == Vote.Yea)
                        b.votesYea[i] += power[i];
                    else
                        b.votesYea[i] -= b.power[primary][i];   // remove previous votes
                    b.totalVotes[i] = b.totalVotes[i] + power[i] - b.power[primary][i];
                    b.power[primary][i] = power[i];  // store user's voting power
                }
            }
            emit ChangeVote(msg.sender, primary, ballotId);
        }

        if (_checkMajority(rules[b.ruleId].majority, b.votesYea, b.totalVotes, false) != Vote.None) { // check Instant execution
            emit PosableMajority(ballotId);
        }
    }

    function verify(uint256 ballotId, uint part) external {

        _verify(ballotId, part);
    }

    function verifyNext(uint part) external {

        uint len = ballots.length;
        for (uint i = unprocessedBallot; i < len; i++) {
            if (ballots[i].status == Status.New) {
                _verify(i, part);
                return; // exit after verification to avoid Out of Gas error
            }
            else if (ballots[i].status != Status.Pending && unprocessedBallot == i)
                unprocessedBallot++;
        }
    }

    function getCirculation() external {

        uint8[4] memory m;
        for (uint i = 0; i < 4; i++) {
            if (tokenContract[i] != IERC20Token(0))
                m[i] = 50;
        }
        _getCirculation(m);
    }

    function _executeBallot(uint256 ballotId) internal {

        require(ballots[ballotId].status == Status.Approved,"Ballot is not Approved");
        Ballot storage b = ballots[ballotId];
        Rule storage r = rules[b.ruleId];
        bytes memory command;
        command = abi.encodePacked(bytes4(keccak256(bytes(r.funcAbi))), b.args);
        governanceProxy.trigger(r.contr, command);
        b.closeVote = block.timestamp;
        if (unprocessedBallot == ballotId) unprocessedBallot++;
        emit ApplyBallot(b.ruleId, ballotId);
    }

    function _verify(uint256 ballotId, uint part) internal {

        require(ballotId < ballots.length,"Wrong ballot ID");
        Ballot storage b = ballots[ballotId];
        Rule storage r = rules[b.ruleId];
        require(b.status == Status.New, "Can not be verified");
        uint256[4] memory totalVotes;
        uint256[4] memory totalYea;
        if (b.processedParticipants > 0) {  // continue verification
            totalVotes = b.totalVotes;
            totalYea = b.votesYea;
        }
        uint256 len = b.processedParticipants + part;
        if (len > b.participant.length || b.closeVote > block.timestamp) // if voting is not closed only etire number of participants should be count
            len = b.participant.length;
        bool acceptEscrowed = true;
        if (r.majority[0] >= absoluteLevel && b.ceoParticipate < requiredCEO)  // only for Absolute majority voting
            acceptEscrowed = false; // reject escrowed wallets if CED did not vote with required number of wallets
        for (uint i = b.processedParticipants; i < len; i++) {
            (address primary, uint256[4] memory power) = _getVotingPower(b.participant[i], r.majority, true, acceptEscrowed);
            for (uint j = 0; j < 4; j++) {
                if (power[j] > 0) {
                    totalVotes[j] += power[j];
                    if (b.votes[primary] == Vote.Yea){
                        totalYea[j] += power[j];
                    }
                }
                b.power[primary][j] = power[j]; // store user's voting power
            }
        }
        b.processedParticipants = len;
        b.votesYea = totalYea;
        b.totalVotes = totalVotes;
        Vote result;
        if (len == b.participant.length) {
            _getCirculation(r.majority);
            if (b.closeVote < block.timestamp) // if vote closed
            {
                result = _checkMajority(r.majority, totalYea, totalVotes, true);
                if (result == Vote.None) result = Vote.Nay; // if no required majority then reject proposal
            }
            else
                result = _checkMajority(r.majority, totalYea, totalVotes, false);  // Check majority for instant execution
            if (result == Vote.Yea) {
                b.status = Status.Approved;
                _executeBallot(ballotId);
            }
            else if (result == Vote.Nay) {
                b.status = Status.Rejected;
                b.closeVote = block.timestamp;
                if (unprocessedBallot == ballotId) unprocessedBallot++;
            }
            else
                b.processedParticipants = 0; //continue voting and reset counter to be able recount votes
        }
    }

    function _checkMajority(
        uint8[4] memory tokensApply,
        uint256[4] memory votesYea,
        uint256[4] memory totalVotes,
        bool isClosed)
        internal view returns(Vote result)
    {

        uint256 majorityYea;
        uint256 majorityNay;
        uint256 requireMajority;
        for (uint i = 0; i < 4; i++) {
            if (tokensApply[i] != 0) {
                requireMajority++;
                if (votesYea[i] * 2 > circulationSupply[i])
                    majorityYea++;   // the voting power is more then 50% of circulation supply
                else if ((totalVotes[i]-votesYea[i]) * 2 > circulationSupply[i])
                    majorityNay++;   // the voting power is more then 50% of circulation supply
                else if (isClosed && votesYea[i] > totalVotes[i] * tokensApply[i] / 100)
                    majorityYea++;   // the voting power is more then require of all participants total votes power
            }
        }
        if (majorityYea == requireMajority) result = Vote.Yea;
        else if (majorityNay == requireMajority) result = Vote.Nay;
    }

    function _getCirculation(uint8[4] memory tokensApply) internal {

        uint256[4] memory total;
        for (uint i = 0; i < 4; i++) {
            if (tokensApply[i] != 0 && circulationSupplyUpdated[i] != block.timestamp) {
                uint len = excluded[i].length;
                for (uint j = 0; j < len; j++) {
                    total[i] += tokenContract[i].balanceOf(excluded[i][j]);
                    if (escrowContract[i] != IERC20Token(0) && isInEscrow[i][excluded[i][j]]) {
                        total[i] += escrowContract[i].balanceOf(excluded[i][j]);
                    }
                }
                uint256 t = IERC20Token(tokenContract[i]).totalSupply();
                require(t >= total[i], "Total Supply less then accounts balance");
                circulationSupply[i] = t - total[i];
                circulationSupplyUpdated[i] = block.timestamp;  // timestamp when circulationSupply updates
            }
        }
    }

    function _getVotingPower(address voter, uint8[4] memory tokensApply, bool isPrimary, bool acceptEscrowed) internal view
        returns(address primary, uint256[4] memory votingPower)
    {

        if (isPrimary)
            primary = voter;
        else
            primary = whitelist.address_belongs(voter);
        require (!blockedWallets[primary], "Wallet is blocked for voting");
        address[] memory userWallets;
        if (primary != address(0)) {
            userWallets = whitelist.getUserWallets(primary);
        }
        else {
            primary = voter;
            userWallets = new address[](0);
        }
        bool hasPower = false;
    
        for (uint i = 0; i < 4; i++) {
            if (tokensApply[i] != 0) {
                votingPower[i] += tokenContract[i].balanceOf(primary);
                if (acceptEscrowed && escrowContract[i] != IERC20Token(0) && isInEscrow[i][primary]) {
                    votingPower[i] += escrowContract[i].balanceOf(primary);
                }
                for(uint j = 0; j < userWallets.length; j++) {
                    votingPower[i] += tokenContract[i].balanceOf(userWallets[j]);
                    if (acceptEscrowed && escrowContract[i] != IERC20Token(0) && isInEscrow[i][userWallets[j]]) {
                        votingPower[i] += escrowContract[i].balanceOf(userWallets[j]);
                    }
                }
                if (votingPower[i] > 0) hasPower = true;
            }
        }
        require(isPrimary || hasPower, "No voting power");
    }

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - 2440588;

        _days = uint(__days);
    }

    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * 86400 + hour * 3600 + minute * 60 + second;
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + 2440588;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / 86400);
    }
}
