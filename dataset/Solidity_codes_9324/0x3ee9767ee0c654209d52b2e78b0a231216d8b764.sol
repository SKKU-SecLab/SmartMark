


pragma solidity >= 0.8.0;


contract OpenLuckyCryptoSimple {

    bool private dbg;               // Debug flag
    bool private locked;            // Flag used to avoid array collisions
    uint private max_int;           // Used to avoid uint overflows
    bool private disabled;          // Flag used to suspend the game, is necessary for any reason
    uint private game_interval;     // Seconds between each game round
    uint private recursionDepth;    // Controls the depth of the arbitraryNumber() function
    uint private last_game_time;    // Time mark to compute the next game round
    uint8 constant postions = 30;   // Lastest bets from the bets array to generate the arbitrary numbers
    uint private bet_mininum_value; // Ammount of wei necessary to register a Bet
    address private owner;          // Address of the contract ownerOnly
    address payable private wallet; // Address to store the funds for this project

    address[] private bets;

    modifier ownerOnly() {

        require(msg.sender == owner, "Your are not allowed");
        _;
    }

    constructor() {
        locked = false;
        owner = msg.sender;
        wallet = payable(owner);
        max_int = type(uint).max;
        disableSystem(false);
        setRecursionDepth(3);
        setGameInterval(86400); // 1 day by default
        setBetMinimumValue(500000 gwei); // 0.0005 ETH by default
        setLastGameTime(block.timestamp); // Time mark to compute the next game time
    }

    function setDebug(bool _debug) public ownerOnly {

        dbg = _debug;
    }


    event log(string text);
    event log(string text, uint value);

    function debug(string memory text) private {

        if (dbg)
            emit log(text);
    }

    function debug(string memory text, uint value) private {

        if (dbg)
            emit log(text, value);
    }
    

    function setLastGameTime(uint _last_game_time) private {

        last_game_time = _last_game_time;
    }

    function getLastGameTime() private view returns (uint) {

        return last_game_time;
    }

    event evDisableSystem(bool disabled);
    function disableSystem(bool _disabled) public ownerOnly {

        emit evDisableSystem(_disabled);
        disabled = _disabled;
    }

    event evSetBetMinimumValue(uint min_value);
    function setBetMinimumValue(uint _min_value) public ownerOnly {

        emit evSetBetMinimumValue(_min_value);
        bet_mininum_value = _min_value;
    }

    event evSetRecursionDepth(uint8 recursionDepth);
    function setRecursionDepth(uint8 _recursionDepth) public ownerOnly {

        emit evSetBetMinimumValue(_recursionDepth);
        recursionDepth = _recursionDepth;
    }

    function getBetMinimumValue() public view returns (uint) {

        return bet_mininum_value;
    }

    event evSetOwner(address newOwner);
    function setOwner(address _newOwner) public ownerOnly {

        emit evSetOwner(_newOwner);
        owner = _newOwner;
    }

    event evSetGameInterval(uint interval);
    function setGameInterval(uint interval) public ownerOnly {

        require(interval >= 10, "Minimum interval is 10s");
        emit evSetGameInterval(interval);
        game_interval = interval;
    }

    function nextGameTime(uint lastTime) private returns (uint) {

        return lastTime + getGameInterval();
    }

    function getGameInterval() public view returns (uint) {

        return game_interval;
    }

    receive() external payable {
        registerBet();
    }

    fallback() external payable {}

    function resetBets() private returns(bool) {

        debug("Deleting all the previous bets");
        delete bets;
        return true;
    }

    function arbitraryNumber(uint depth) private returns(uint) {

        bytes32 stream;
        uint n = numberOfBets();
        if (n > postions) {
            address[postions] memory payload;
            uint start = n - 1 - postions;
            for (uint c = 0; c < postions; c++) {
                payload[c] = bets[start + c];
            }
            stream = keccak256(abi.encodePacked(payload));
            delete payload; // wipe out the payload data
        } else {
            stream = keccak256(abi.encode(bets));
        }

        bytes memory liveData = abi.encodePacked(
            (block.timestamp - getLastGameTime() + 1) * address(this).balance,
            stream
        );
        return _arbitraryNumber(liveData, n, depth);
    }


    function _arbitraryNumber(bytes memory liveData, uint seed, uint depth) private returns(uint) {

        if (depth > 0) {
            depth--;
            seed = _arbitraryNumber(liveData, seed, depth);
        }

        return uint(
            keccak256(
                abi.encodePacked(
                    liveData,
                    seed
                )
            )
        );
    }


    function calcFund() private returns(uint) {

        debug("calcFund 1");
        return address(this).balance / 10 * 2;
    }

    function calcReserve() private returns (uint) {

        debug("calcReserve 1");
        return address(this).balance / 100 * 5;
    }

    function calcPrize() private returns (uint) {

        debug("calcPrize 1");
        
        uint reserve = calcReserve();
        debug("calcPrize 2");

        uint fund = calcFund();
        debug("calcPrize 3");

        return address(this).balance - reserve - fund;
    }

    function getBalance() public view ownerOnly returns (uint) {

        return address(this).balance;
    }

    function storeFund(uint _fund) private returns (bool) {

        debug("Storing funds");
        wallet.transfer(_fund);
        return true;
    }

    modifier checkGameTime () {

        debug("checkGameTime 1");
        require(!disabled, "The system is desabled. Please, try again later");
        require(!locked, "We are closed to bets right now. Please, try again later"); // Avoid array collisions
        debug("checkGameTime 2");

        if(block.timestamp >= nextGameTime(getLastGameTime())){
            debug("checkGameTime 3");
            locked = true;
            sharePrize();
            setNewGame();
            locked = false;
        }
        _;
    }

    function forceUnlock() public ownerOnly {

        debug("Forced unlock");
        locked = false;
    }
    
    function numberOfBets() public view returns (uint) {

        return bets.length;
    }

    function setNewGame() private returns (bool) {

        debug("Setting up a new game round");
        uint fund = calcFund();
        storeFund(fund);
        resetBets();
        setLastGameTime(block.timestamp);
        return true;
    }

    function registerBet() public payable checkGameTime {

        debug("registerBet 1");
        require(
            uint(msg.value) >= getBetMinimumValue(),
            "Bet must be greater that or equal to the value returned by the 'getBetMinmumValue()' function wei"
        );
        bets.push(msg.sender);
    }

    event evSharePrize(uint _prizeAmount);
    function sharePrize() private returns (bool) {


        uint n_bets = numberOfBets();
        debug("sharePrize 1 - bets", n_bets);

        if(n_bets == 0)
            return(false);
        debug("sharePrize 2 - bets > 0");

        uint n_1 = n_bets >= 100 ? n_bets / 100 : 1;
        debug("sharePrize 3 - no math problems");

        uint n_2;
        if (n_bets > max_int / 3) { // Avoid uint overflow
            n_2 = n_bets / 100 * 3; // Divide first to avoid overflow
        } else {
            n_2 = n_bets > 33 ?
                n_bets * 3 / 100:   // Multiply first to avoid decimal precision cuts
                1;                  // Garantee minimal of one winner in this range
        }
        debug("sharePrize 4 - no math problems");

        uint n_3;
        if (n_bets > max_int / 6) { // Avoid uint overflow
            n_3 = n_bets / 100 * 6; // Divide first to avoid overflow
        } else {
            n_3 = n_bets > 16 ?
                n_bets * 6 / 100:   // Multiply first to avoid decimal precision cuts
                1;                  // Garantee minimal of one winner in this range
        }
        debug("sharePrize 5 - no math problems");


        uint prize = calcPrize();
        debug("sharePrize 6 - total prize", prize);

        uint p_1 = prize / 10 * 8 / n_1;
        emit log("1st range winners quantity", n_1);
        emit log("1st range total prize", p_1);

        if (p_1 == 0) {
            emit log("No prize left");
            return(false);
        }

        uint p_2 = prize / 100 * 15 / n_2;
        emit log("2nd range winners quantity", n_2);
        emit log("2nd range total prize", p_2);

        uint p_3 = prize / 100 * 5 / n_3;
        emit log("3rd range winners quantity", n_3);
        emit log("3rd range total prize", p_3);

        uint r = arbitraryNumber(recursionDepth);
        debug("sharePrize 7 - arbitrary number", r);

        uint win_mark = r > n_bets ? r % n_bets : n_bets % r;
        debug("sharePrize 8 - winner position", win_mark);

        if(win_mark >= n_bets)
            win_mark = 0;

        debug("sharePrize 9 - 1st range initial position", win_mark);
        uint nextRange = givePrizes(n_1, win_mark, p_1) + 1;

        debug("sharePrize 10 - 2nd range initial position", nextRange);
        if (p_2 > 0)
            nextRange = givePrizes(n_2, nextRange, p_2) + 1;

        debug("sharePrize 11 - 3rd range initial position", nextRange);
        if (p_3 > 0)
            givePrizes(n_3, nextRange, p_3);

        debug("sharePrize 12 - finish");
        return(true);
    }

    event evGivePrizeError(address indexed player, uint prize, uint indexed time, bytes indexed message);
    function givePrizes(uint n, uint position, uint prize) private returns (uint) {

        if (prize == 0) {
            emit evGivePrizeError(address(0), prize, block.timestamp, "Not enough prize");
            return position;
        }

        if (n == 0) {
            emit evGivePrizeError(address(0), prize, block.timestamp, "No winners for this range");
            return position;
        }

        uint p;
        uint n_bets = numberOfBets();
        for(uint c = 0; c < n; c++) {
            p = position + c;

            if(p >= n_bets) {
                n -= c;
                position = 0;
                p = 0;
                c = 0;
            }
            

            bool status = _givePrize(p, prize); // send() is less expensive than transfer()
            if(status != true) {
                emit evGivePrizeError(bets[p], prize, block.timestamp, "Failed transferring the prize");
            }
        }
        

        return p;
    }

    event evChangeWallet(address indexed _owner, address indexed _oldWallet, address indexed _newWallet, uint time);
    function changeWallet(address newWallet) public ownerOnly returns(address) {

        emit evChangeWallet(owner, wallet, newWallet, block.timestamp);
        wallet = payable(newWallet);
        return wallet;
    }

    event evGameOver(address indexed _owner, address indexed _wallet, uint _balance, uint timestamp, string comment);
    function gameOver() public ownerOnly {

        disableSystem(true);
        uint n_bets = numberOfBets();
        if (n_bets > 0) {
            uint prize = calcPrize();
            uint prize_per_bet = prize / n_bets;

            for (uint c = 0; c < n_bets; c++) {
                emit evGameOver(owner, bets[c], address(this).balance, block.timestamp, "Returning prize...");
                if (_givePrize(c, prize_per_bet) == false) {
                    emit evGameOver(owner, bets[c], address(this).balance, block.timestamp, "Failed to return the prize.");
                }
            }
        }

        emit evGameOver(owner, wallet, address(this).balance, block.timestamp, "OpenLuckyCryptoSimple is dead.");
        selfdestruct(wallet);
    }

    function _givePrize(uint bet, uint prize) private returns(bool) {

        return(payable(bets[bet]).send(prize));
    }
}