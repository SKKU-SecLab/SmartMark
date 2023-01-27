


pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}

pragma solidity 0.6.12;

contract HashBet is Ownable, ReentrancyGuard {

    uint constant MAX_MODULO = 100;

    uint constant MAX_MASK_MODULO = 40;
    
    uint constant BET_EXPIRATION_BLOCKS = 250;

    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;

    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    uint public cumulativeDeposit;
    uint public cumulativeWithdrawal;

    uint public wealthTaxIncrementThreshold = 3000 ether;
    uint public wealthTaxIncrementPercent = 1;

    uint public minBetAmount = 0.01 ether;
    uint public maxBetAmount = 10000 ether;

    uint public maxProfit = 300000 ether;

    uint public lockedInBets;

    struct Bet {
        uint amount;
        uint8 modulo;
        uint8 rollEdge;
        uint40 mask;
        uint placeBlockNumber;
        address payable gambler;
        bool isSettled;
        uint outcome;
        uint winAmount;
        uint randomNumber;
        uint commit;
        bool method;
    }
    
    uint public houseEdgePercent = 2;

    mapping (uint => Bet) public bets;

    event BetPlaced(address indexed gambler, uint amount, uint8 indexed modulo, uint8 rollEdge, uint40 mask, uint commit, bool method);
    event BetSettled(address indexed gambler, uint amount, uint8 indexed modulo, uint8 rollEdge, uint40 mask, uint outcome, uint winAmount);
    event BetRefunded(address indexed gambler, uint amount);

    fallback() external payable {
        cumulativeDeposit += msg.value;
    }
    receive() external payable {
        cumulativeDeposit += msg.value;
    }

    function balance() external view returns (uint) {

        return address(this).balance;
    }
    
    function setHouseEdgePercent(uint _houseEdgePercent) external onlyOwner {

        require ( _houseEdgePercent >= 1 && _houseEdgePercent <= 100, "houseEdgePercent must be a sane number");
        houseEdgePercent = _houseEdgePercent;
    }

    function setMinBetAmount(uint _minBetAmount) external onlyOwner {

        minBetAmount = _minBetAmount * 1 gwei;
    }

    function setMaxBetAmount(uint _maxBetAmount) external onlyOwner {

        require (_maxBetAmount < 5000000 ether, "maxBetAmount must be a sane number");
        maxBetAmount = _maxBetAmount;
    }

    function setMaxProfit(uint _maxProfit) external onlyOwner {

        require (_maxProfit < 50000000 ether, "maxProfit must be a sane number");
        maxProfit = _maxProfit;
    }

    function setWealthTaxIncrementPercent(uint _wealthTaxIncrementPercent) external onlyOwner {

        wealthTaxIncrementPercent = _wealthTaxIncrementPercent;
    }

    function setWealthTaxIncrementThreshold(uint _wealthTaxIncrementThreshold) external onlyOwner {

        wealthTaxIncrementThreshold = _wealthTaxIncrementThreshold;
    }

    function withdrawFunds(address payable beneficiary, uint withdrawAmount) external onlyOwner {

        require (withdrawAmount <= address(this).balance, "Withdrawal amount larger than balance.");
        require (withdrawAmount <= address(this).balance - lockedInBets, "Withdrawal amount larger than balance minus lockedInBets");
        beneficiary.transfer(withdrawAmount);
        cumulativeWithdrawal += withdrawAmount;
    }

    function emitBetPlacedEvent(address gambler, uint amount, uint8 modulo, uint8 rollEdge, uint40 mask, uint commit, bool method) private
    {

        emit BetPlaced(gambler, amount, uint8(modulo), uint8(rollEdge), uint40(mask), commit, method);
    }

    function placeBet(uint betMask, uint modulo, uint commitLastBlock, uint commit, bool method, bytes32 r, bytes32 s) external payable nonReentrant {


        Bet storage bet = bets[commit];
        require (bet.gambler == address(0), "Bet should be in a 'clean' state.");
        uint amount = msg.value;
        require (modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require (amount >= minBetAmount && amount <= maxBetAmount, "Bet amount should be within range.");
        require (betMask > 0 && betMask < MAX_BET_MASK, "Mask should be within range.");
        
        require (block.number <= commitLastBlock, "Commit has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked(uint40(commitLastBlock), commit));
        require (owner() == ecrecover(signatureHash, 27, r, s), "ECDSA signature is not valid.");

        uint rollEdge;
        uint mask;

        if (modulo <= MAX_MASK_MODULO) {
            rollEdge = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
            mask = betMask;
        } else {
            require (betMask > 0 && betMask <= modulo, "High modulo range, betMask larger than modulo.");
            rollEdge = betMask;
        }

        uint possibleWinAmount = getDiceWinAmount(amount, modulo, rollEdge, method);

        require (possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

        require (lockedInBets + possibleWinAmount <= address(this).balance, "Unable to accept bet due to insufficient funds");

        lockedInBets += possibleWinAmount;

        bet.amount=amount;
        bet.modulo=uint8(modulo);
        bet.rollEdge=uint8(rollEdge);
        bet.mask=uint40(mask);
        bet.placeBlockNumber=block.number;
        bet.gambler=payable(msg.sender);
        bet.isSettled=false;
        bet.outcome=0;
        bet.winAmount=0;
        bet.randomNumber=0;
        bet.commit=commit;
        bet.method=method;

        emitBetPlacedEvent(bet.gambler, amount, uint8(modulo), uint8(rollEdge), uint40(mask), commit, method);
    }

    function getDiceWinAmount(uint amount, uint modulo, uint rollEdge, bool method) private view returns (uint winAmount) {

        require (0 < rollEdge && rollEdge <= modulo, "Win probability out of range.");
        uint houseEdge = amount * (houseEdgePercent + getWealthTax(amount)) / 100;
        uint realRollEdge = rollEdge;
        if (modulo == MAX_MODULO && method) {
            realRollEdge = MAX_MODULO - rollEdge;
        }
        winAmount = (amount - houseEdge) * modulo / realRollEdge;
    }

    function getWealthTax(uint amount) private view returns (uint wealthTax) {

        wealthTax = amount / wealthTaxIncrementThreshold * wealthTaxIncrementPercent;
    }
    
    function settleBet(uint reveal, bytes32 transactionHash) external onlyOwner {

        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        require (block.number >= placeBlockNumber, "settleBet before placeBet");

        settleBetCommon(bet, reveal, transactionHash);
    }

    function settleBetUncleMerkleProof(uint reveal, uint40 canonicalBlockNumber) external onlyOwner {

        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];

        require (block.number <= canonicalBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        requireCorrectReceipt(4 + 32 + 32 + 4);

        bytes32 canonicalHash;
        bytes32 uncleHash;
        (canonicalHash, uncleHash) = verifyMerkleProof(commit, 4 + 32 + 32);
        require (blockhash(canonicalBlockNumber) == canonicalHash);

        settleBetCommon(bet, reveal, uncleHash);
    }

    function settleBetCommon(Bet storage bet, uint reveal, bytes32 entropyBlockHash) private {

        uint amount = bet.amount;
        
        require (amount > 0, "Bet does not exist."); // Check that bet exists
        require(bet.isSettled == false, "Bet is settled already"); // Check that bet is not settled yet

        uint modulo = bet.modulo;
        uint rollEdge = bet.rollEdge;
        address payable gambler = bet.gambler;
        bool method = bet.method;
        
        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        uint outcome = uint(entropy) % modulo;

        uint possibleWinAmount = getDiceWinAmount(amount, modulo, rollEdge, method);

        uint winAmount = 0;

        if (modulo <= MAX_MASK_MODULO) {
            if ((2 ** outcome) & bet.mask != 0) {
                winAmount = possibleWinAmount;
            }
        } else {
            if (method){
                if (outcome > rollEdge) {
                    winAmount = possibleWinAmount;
                }
            }
            else{
                if (outcome < rollEdge) {
                    winAmount = possibleWinAmount;
                }
            }
            
        }
        
        emitSettledEvent(bet, outcome, winAmount);

        lockedInBets -= possibleWinAmount;

        bet.isSettled = true;
        bet.winAmount = winAmount;
        bet.randomNumber = uint(entropy);
        bet.outcome = outcome;

        if (winAmount > 0) {
            gambler.transfer(winAmount);
        }
    }

    function emitSettledEvent(Bet storage bet, uint outcome, uint winAmount) private
    {

        uint amount = bet.amount;
        uint modulo = bet.modulo;
        uint rollEdge = bet.rollEdge;
        address payable gambler = bet.gambler;
        emit BetSettled(gambler, amount, uint8(modulo), uint8(rollEdge), bet.mask, outcome, winAmount);
    }

    function refundBet(uint commit) external nonReentrant payable {

        
        Bet storage bet = bets[commit];
        uint amount = bet.amount;
        bool method = bet.method;

        require (amount > 0, "Bet does not exist."); // Check that bet exists
        require (bet.isSettled == false, "Bet is settled already."); // Check that bet is still open
        require (block.number > bet.placeBlockNumber + 43200, "Wait after placing bet before requesting refund.");

        uint possibleWinAmount = getDiceWinAmount(amount, bet.modulo, bet.rollEdge, method);

        lockedInBets -= possibleWinAmount;

        bet.isSettled = true;
        bet.winAmount = amount;

        bet.gambler.transfer(amount);

        emit BetRefunded(bet.gambler, amount);
    }


    function verifyMerkleProof(uint seedHash, uint offset) pure private returns (bytes32 blockHash, bytes32 uncleHash) {

        uint scratchBuf1;  assembly { scratchBuf1 := mload(0x40) }

        uint uncleHeaderLength; uint blobLength; uint shift; uint hashSlot;

        for (;; offset += blobLength) {
            assembly { blobLength := and(calldataload(sub(offset, 30)), 0xffff) }
            if (blobLength == 0) {
                break;
            }

            assembly { shift := and(calldataload(sub(offset, 28)), 0xffff) }
            require (shift + 32 <= blobLength, "Shift bounds check.");

            offset += 4;
            assembly { hashSlot := calldataload(add(offset, shift)) }
            require (hashSlot == 0, "Non-empty hash slot.");

            assembly {
                calldatacopy(scratchBuf1, offset, blobLength)
                mstore(add(scratchBuf1, shift), seedHash)
                seedHash := keccak256(scratchBuf1, blobLength)
                uncleHeaderLength := blobLength
            }
        }

        uncleHash = bytes32(seedHash);

        uint scratchBuf2 = scratchBuf1 + uncleHeaderLength;
        uint unclesLength; assembly { unclesLength := and(calldataload(sub(offset, 28)), 0xffff) }
        uint unclesShift;  assembly { unclesShift := and(calldataload(sub(offset, 26)), 0xffff) }
        require (unclesShift + uncleHeaderLength <= unclesLength, "Shift bounds check.");

        offset += 6;
        assembly { calldatacopy(scratchBuf2, offset, unclesLength) }
        memcpy(scratchBuf2 + unclesShift, scratchBuf1, uncleHeaderLength);

        assembly { seedHash := keccak256(scratchBuf2, unclesLength) }

        offset += unclesLength;

        assembly {
            blobLength := and(calldataload(sub(offset, 30)), 0xffff)
            shift := and(calldataload(sub(offset, 28)), 0xffff)
        }
        require (shift + 32 <= blobLength, "Shift bounds check.");

        offset += 4;
        assembly { hashSlot := calldataload(add(offset, shift)) }
        require (hashSlot == 0, "Non-empty hash slot.");

        assembly {
            calldatacopy(scratchBuf1, offset, blobLength)
            mstore(add(scratchBuf1, shift), seedHash)

            blockHash := keccak256(scratchBuf1, blobLength)
        }
    }


    function requireCorrectReceipt(uint offset) view private {

        uint leafHeaderByte; assembly { leafHeaderByte := byte(0, calldataload(offset)) }

        require (leafHeaderByte >= 0xf7, "Receipt leaf longer than 55 bytes.");
        offset += leafHeaderByte - 0xf6;

        uint pathHeaderByte; assembly { pathHeaderByte := byte(0, calldataload(offset)) }

        if (pathHeaderByte <= 0x7f) {
            offset += 1;

        } else {
            require (pathHeaderByte >= 0x80 && pathHeaderByte <= 0xb7, "Path is an RLP string.");
            offset += pathHeaderByte - 0x7f;
        }

        uint receiptStringHeaderByte; assembly { receiptStringHeaderByte := byte(0, calldataload(offset)) }
        require (receiptStringHeaderByte == 0xb9, "Receipt string is always at least 256 bytes long, but less than 64k.");
        offset += 3;

        uint receiptHeaderByte; assembly { receiptHeaderByte := byte(0, calldataload(offset)) }
        require (receiptHeaderByte == 0xf9, "Receipt is always at least 256 bytes long, but less than 64k.");
        offset += 3;

        uint statusByte; assembly { statusByte := byte(0, calldataload(offset)) }
        require (statusByte == 0x1, "Status should be success.");
        offset += 1;

        uint cumGasHeaderByte; assembly { cumGasHeaderByte := byte(0, calldataload(offset)) }
        if (cumGasHeaderByte <= 0x7f) {
            offset += 1;

        } else {
            require (cumGasHeaderByte >= 0x80 && cumGasHeaderByte <= 0xb7, "Cumulative gas is an RLP string.");
            offset += cumGasHeaderByte - 0x7f;
        }

        uint bloomHeaderByte; assembly { bloomHeaderByte := byte(0, calldataload(offset)) }
        require (bloomHeaderByte == 0xb9, "Bloom filter is always 256 bytes long.");
        offset += 256 + 3;

        uint logsListHeaderByte; assembly { logsListHeaderByte := byte(0, calldataload(offset)) }
        require (logsListHeaderByte == 0xf8, "Logs list is less than 256 bytes long.");
        offset += 2;

        uint logEntryHeaderByte; assembly { logEntryHeaderByte := byte(0, calldataload(offset)) }
        require (logEntryHeaderByte == 0xf8, "Log entry is less than 256 bytes long.");
        offset += 2;

        uint addressHeaderByte; assembly { addressHeaderByte := byte(0, calldataload(offset)) }
        require (addressHeaderByte == 0x94, "Address is 20 bytes long.");

        uint logAddress; assembly { logAddress := and(calldataload(sub(offset, 11)), 0xffffffffffffffffffffffffffffffffffffffff) }
        require (logAddress == uint(address(this)));
    }

    function memcpy(uint dest, uint src, uint len) pure private {

        for(; len >= 32; len -= 32) {
            assembly { mstore(dest, mload(src)) }
            dest += 32; src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function kill() external onlyOwner {

        require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(payable(owner()));
    }
}