
pragma solidity ^0.5.0;


contract IRelayRecipient {


    function getHubAddr() public view returns (address);


    function getRecipientBalance() public view returns (uint256);


     function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
    external
    view
    returns (uint256, bytes memory);


    modifier relayHubOnly() {

        require(msg.sender == getHubAddr(),"Function can only be called by RelayHub");
        _;
    }

    function preRelayedCall(bytes calldata context) external returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint actualCharge, bytes32 preRetVal) external;


}

contract IRelayHub {


    function stake(address relayaddr, uint256 unstakeDelay) external payable;


    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    function registerRelay(uint256 transactionFee, string memory url) public;


    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    function removeRelayByOwner(address relay) public;


    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    function unstake(address relay) public;


    event Unstaked(address indexed relay, uint256 stake);

    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);



    function depositFor(address target) public payable;


    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    function balanceOf(address target) external view returns (uint256);


    function withdraw(uint256 amount, address payable dest) public;


    event Withdrawn(address indexed account, address indexed dest, uint256 amount);


    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256 status, bytes memory recipientContext);


    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    function relayCall(
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;


    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    function requiredGas(uint256 relayedCallStipend) public view returns (uint256);


    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) public view returns (uint256);



    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;


    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;


    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) view external returns (uint256);

}

library LibBytes {


    using LibBytes for bytes;

    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }
    
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {

        if (length < 32) {
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            if (source == dest) {
                return;
            }

            if (source > dest) {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let last := mload(sEnd)

                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }
                    
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let first := mload(source)

                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }
                    
                    mstore(dest, first)
                }
            }
        }
    }

    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }
    
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        result = b[b.length - 1];

        assembly {
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        result = readAddress(b, b.length - 20);

        assembly {
            let newLen := sub(mload(b), 20)
            mstore(b, newLen)
        }
        return result;
    }

    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        index += 20;

        assembly {
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        index += 20;

        assembly {

            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            mstore(add(b, index), xor(input, neighbors))
        }
    }

    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        index += 32;

        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        index += 32;

        assembly {
            mstore(add(b, index), input)
        }
    }

    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        assembly {
            result := add(b, index)
        }
        return result;
    }

    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}

contract RelayRecipient is IRelayRecipient {


    IRelayHub private relayHub; // The IRelayHub singleton which is allowed to call us

    function getHubAddr() public view returns (address) {

        return address(relayHub);
    }

    function setRelayHub(IRelayHub _rhub) internal {

        relayHub = _rhub;
    }

    function getRelayHub() internal view returns (IRelayHub) {

        return relayHub;
    }

    function getRecipientBalance() public view returns (uint) {

        return getRelayHub().balanceOf(address(this));
    }

    function getSenderFromData(address origSender, bytes memory msgData) public view returns (address) {

        address sender = origSender;
        if (origSender == getHubAddr()) {
            sender = LibBytes.readAddress(msgData, msgData.length - 20);
        }
        return sender;
    }

    function getSender() public view returns (address) {

        return getSenderFromData(msg.sender, msg.data);
    }

    function getMessageData() public view returns (bytes memory) {

        bytes memory origMsgData = msg.data;
        if (msg.sender == getHubAddr()) {
            origMsgData = new bytes(msg.data.length - 20);
            for (uint256 i = 0; i < origMsgData.length; i++)
            {
                origMsgData[i] = msg.data[i];
            }
        }
        return origMsgData;
    }
}

contract Etheradz is RelayRecipient {

        using SafeMath for *;

        address public owner;
        address public masterAccount;
        uint256 private houseFee = 4;
        uint256 private poolTime = 24 hours;
        uint256 private dailyWinPool = 5;
        uint256 private whalepoolPercentage = 25;
        uint256 private incomeTimes = 30;
        uint256 private incomeDivide = 10;
        uint256 public total_withdraw;
        uint256 public roundID;
        uint256 public currUserID;
        uint256[4] private awardPercentage;

        struct Leaderboard {
            uint256 amt;
            address addr;
        }

        Leaderboard[4] public topSponsors;

        Leaderboard[4] public lastTopSponsors;
        uint256[4] public lastTopSponsorsWinningAmount;

        address[] public etherwhales;


        mapping (uint => uint) public CYCLE_LIMIT;
        mapping (address => bool) public isEtherWhale;
        mapping (uint => address) public userList;
        mapping (uint256 => DataStructs.DailyRound) public round;
        mapping (address => DataStructs.User) public player;
        mapping (address => uint256) public playerTotEarnings;
        mapping (address => mapping (uint256 => DataStructs.PlayerDailyRounds)) public plyrRnds_;


        event registerUserEvent(address indexed _playerAddress, address indexed _referrer);
        event investmentEvent(address indexed _playerAddress, uint256 indexed _amount);
        event premiumInvestmentEvent(address indexed _playerAddress, uint256 indexed _amount, uint256 _investedAmount);
        event referralCommissionEvent(address indexed _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 _type);
        event withdrawEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
        event roundAwardsEvent(address indexed _playerAddress, uint256 indexed _amount);
        event etherWhaleAwardEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
        event premiumReferralCommissionEvent(address indexed _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 timeStamp);


        constructor (
          address _owner,
          address _masterAccount,
          IRelayHub _gsnRelayHub
        )
        public {
             owner = _owner;
             masterAccount = _masterAccount;
             setRelayHub(_gsnRelayHub);
             roundID = 1;
             round[1].startTime = now;
             round[1].endTime = now + poolTime;
             awardPercentage[0] = 40;
             awardPercentage[1] = 30;
             awardPercentage[2] = 20;
             awardPercentage[3] = 10;
             currUserID = 0;

             CYCLE_LIMIT[1]=10 ether;
             CYCLE_LIMIT[2]=25 ether;
             CYCLE_LIMIT[3]=100 ether;
             CYCLE_LIMIT[4]=250 ether;

             currUserID++;
             player[masterAccount].id = currUserID;
             userList[currUserID] = masterAccount;

        }

        function changeHub(IRelayHub _hubAddr)
        public
        onlyOwner {

            setRelayHub(_hubAddr);
        }

        function acceptRelayedCall(
            address relay,
            address from,
            bytes calldata encodedFunction,
            uint256 transactionFee,
            uint256 gasPrice,
            uint256 gasLimit,
            uint256 nonce,
            bytes calldata approvalData,
            uint256 maxPossibleCharge
        )
        external
        view
        returns (uint256, bytes memory) {

          if ( isUser(from) ) return (0, '');

          return (10, '');
        }

        function preRelayedCall(bytes calldata context) external returns (bytes32){

    		return '';
        }

        function postRelayedCall(bytes calldata context, bool success, uint actualCharge, bytes32 preRetVal) external {

        }

        function isUser(address _addr)
        public view returns (bool) {

            return player[_addr].id > 0;
        }



        modifier isMinimumAmount(uint256 _eth) {

            require(_eth >= 100000000000000000, "Minimum contribution amount is 0.1 ETH");
            _;
        }

        modifier isallowedValue(uint256 _eth) {

            require(_eth % 100000000000000000 == 0, "multiples of 0.1 ETH please");
            _;
        }

        modifier onlyOwner() {

            require(getSender() == owner, "only Owner");
            _;
        }

        modifier requireUser() { require(isUser(getSender())); _; }




        function registerUser(uint256 _referrerID)
        public
        isMinimumAmount(msg.value)
        isallowedValue(msg.value)
        payable {


            require(_referrerID > 0 && _referrerID <= currUserID, "Incorrect Referrer ID");
            address _referrer = userList[_referrerID];

            uint256 amount = msg.value;
            if (player[getSender()].id <= 0) { //if player is a new joinee
            require(amount <= CYCLE_LIMIT[1], "Can't send more than the limit");

                currUserID++;
                player[getSender()].id = currUserID;
                player[getSender()].depositTime = now;
                player[getSender()].currInvestment = amount;
                player[getSender()].incomeLimitLeft = amount.mul(incomeTimes).div(incomeDivide);
                player[getSender()].totalInvestment = amount;
                player[getSender()].referrer = _referrer;
                player[getSender()].cycle = 1;
                userList[currUserID] = getSender();

                player[_referrer].referralCount = player[_referrer].referralCount.add(1);

                plyrRnds_[_referrer][roundID].ethVolume = plyrRnds_[_referrer][roundID].ethVolume.add(amount);
                addSponsorToPool(_referrer);
                directsReferralBonus(getSender(), amount);


                  emit registerUserEvent(getSender(), _referrer);
            }
            else {

                player[getSender()].cycle = player[getSender()].cycle.add(1);

                require(player[getSender()].incomeLimitLeft == 0, "limit is still remaining");

                require(amount >= (player[getSender()].currInvestment.mul(2) >= 250 ether ? 250 ether : player[getSender()].currInvestment.mul(2)));
                require(amount <= CYCLE_LIMIT[player[getSender()].cycle > 4 ? 4 : player[getSender()].cycle], "Please send correct amount");

                _referrer = player[getSender()].referrer;

                if(amount == 250 ether) {
                    if(isEtherWhale[getSender()] == false){
                        isEtherWhale[getSender()] == true;
                        etherwhales.push(getSender());
                    }
                    player[getSender()].incomeLimitLeft = amount.mul(20).div(incomeDivide);
                }
                else {
                    player[getSender()].incomeLimitLeft = amount.mul(incomeTimes).div(incomeDivide);
                }

                player[getSender()].depositTime = now;
                player[getSender()].dailyIncome = 0;
                player[getSender()].currInvestment = amount;
                player[getSender()].totalInvestment = player[getSender()].totalInvestment.add(amount);

                plyrRnds_[_referrer][roundID].ethVolume = plyrRnds_[_referrer][roundID].ethVolume.add(amount);
                addSponsorToPool(_referrer);
                directsReferralBonus(getSender(), amount);

            }

                round[roundID].pool = round[roundID].pool.add(amount.mul(dailyWinPool).div(100));
                round[roundID].whalepool = round[roundID].whalepool.add(amount.mul(whalepoolPercentage).div(incomeDivide).div(100));

                address payable ownerAddr = address(uint160(owner));
                ownerAddr.transfer(amount.mul(houseFee).div(100));

                if (now > round[roundID].endTime && round[roundID].ended == false) {
                    startNextRound();
                }

                emit investmentEvent (getSender(), amount);
        }


        function directsReferralBonus(address _playerAddress, uint256 amount)
        private
        {

            address _nextReferrer = player[_playerAddress].referrer;
            uint i;

            for(i=0; i < 5; i++) {

                if (_nextReferrer != address(0x0)) {
                    if(i == 0) {
                            player[_nextReferrer].directsIncome = player[_nextReferrer].directsIncome.add(amount.mul(10).div(100));
                            emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(10).div(100), 1);
                        }
                    else if(i == 1 ) {
                        if(player[_nextReferrer].referralCount >= 2) {
                            player[_nextReferrer].directsIncome = player[_nextReferrer].directsIncome.add(amount.mul(2).div(100));
                            emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(2).div(100), 1);
                        }
                    }
                    else {
                        if(player[_nextReferrer].referralCount >= i+1) {
                           player[_nextReferrer].directsIncome = player[_nextReferrer].directsIncome.add(amount.mul(1).div(100));
                           emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(1).div(100), 1);
                        }
                    }
                }
                else {
                    break;
                }
                _nextReferrer = player[_nextReferrer].referrer;
            }
        }


        function roiReferralBonus(address _playerAddress, uint256 amount)
        private
        {

            address _nextReferrer = player[_playerAddress].referrer;
            uint i;

            for(i=0; i < 20; i++) {

                if (_nextReferrer != address(0x0)) {
                    if(i == 0) {
                       player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(30).div(100));
                       emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(30).div(100), 2);
                    }
                    else if(i > 0 && i < 5) {
                        if(player[_nextReferrer].referralCount >= i+1) {
                            player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(10).div(100));
                            emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(10).div(100), 2);
                        }
                    }
                    else if(i > 4 && i < 10) {
                        if(player[_nextReferrer].referralCount >= i+1) {
                            player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(8).div(100));
                            emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(8).div(100), 2);
                        }
                    }
                    else if(i > 9 && i < 15) {
                        if(player[_nextReferrer].referralCount >= i+1) {
                            player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(5).div(100));
                            emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(5).div(100), 2);
                        }
                    }
                    else { // for users 16-20
                        if(player[_nextReferrer].referralCount >= i+1) {
                            player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(1).div(100));
                            emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(1).div(100), 2);
                        }
                    }
                }
                else {
                        break;
                    }
                _nextReferrer = player[_nextReferrer].referrer;
            }
        }



        function withdrawEarnings()
        requireUser
        public {

            (uint256 to_payout) = this.payoutOf(getSender());

            require(player[getSender()].incomeLimitLeft > 0, "Limit not available");

            if(to_payout > 0) {
                if(to_payout > player[getSender()].incomeLimitLeft) {
                    to_payout = player[getSender()].incomeLimitLeft;
                }

                player[getSender()].dailyIncome += to_payout;
                player[getSender()].incomeLimitLeft -= to_payout;

                roiReferralBonus(getSender(), to_payout);
            }

            if(player[getSender()].incomeLimitLeft > 0 && player[getSender()].directsIncome > 0) {
                uint256 direct_bonus = player[getSender()].directsIncome;

                if(direct_bonus > player[getSender()].incomeLimitLeft) {
                    direct_bonus = player[getSender()].incomeLimitLeft;
                }

                player[getSender()].directsIncome -= direct_bonus;
                player[getSender()].incomeLimitLeft -= direct_bonus;
                to_payout += direct_bonus;
            }

            if(player[getSender()].incomeLimitLeft > 0 && player[getSender()].sponsorPoolIncome > 0) {
                uint256 pool_bonus = player[getSender()].sponsorPoolIncome;

                if(pool_bonus > player[getSender()].incomeLimitLeft) {
                    pool_bonus = player[getSender()].incomeLimitLeft;
                }

                player[getSender()].sponsorPoolIncome -= pool_bonus;
                player[getSender()].incomeLimitLeft -= pool_bonus;
                to_payout += pool_bonus;
            }

            if(player[getSender()].incomeLimitLeft > 0  && player[getSender()].roiReferralIncome > 0) {
                uint256 match_bonus = player[getSender()].roiReferralIncome;

                if(match_bonus > player[getSender()].incomeLimitLeft) {
                    match_bonus = player[getSender()].incomeLimitLeft;
                }

                player[getSender()].roiReferralIncome -= match_bonus;
                player[getSender()].incomeLimitLeft -= match_bonus;
                to_payout += match_bonus;
            }

            if(player[getSender()].incomeLimitLeft > 0  && player[getSender()].whalepoolAward > 0) {
                uint256 whale_bonus = player[getSender()].whalepoolAward;

                if(whale_bonus > player[getSender()].incomeLimitLeft) {
                    whale_bonus = player[getSender()].incomeLimitLeft;
                }

                player[getSender()].whalepoolAward -= whale_bonus;
                player[getSender()].incomeLimitLeft -= whale_bonus;
                to_payout += whale_bonus;
            }

            if(player[getSender()].incomeLimitLeft > 0  && player[getSender()].premiumReferralIncome > 0) {
                uint256 premium_bonus = player[getSender()].premiumReferralIncome;

                if(premium_bonus > player[getSender()].incomeLimitLeft) {
                    premium_bonus = player[getSender()].incomeLimitLeft;
                }

                player[getSender()].premiumReferralIncome -= premium_bonus;
                player[getSender()].incomeLimitLeft -= premium_bonus;
                to_payout += premium_bonus;
            }

            require(to_payout > 0, "Zero payout");

            playerTotEarnings[getSender()] += to_payout;
            total_withdraw += to_payout;

            address payable senderAddr = address(uint160(getSender()));
            senderAddr.transfer(to_payout);

             emit withdrawEvent(getSender(), to_payout, now);

        }

        function payoutOf(address _addr) view external returns(uint256 payout) {

            uint256  earningsLimitLeft = player[_addr].incomeLimitLeft;

            if(player[_addr].incomeLimitLeft > 0 ) {
                payout = (player[_addr].currInvestment * ((block.timestamp - player[_addr].depositTime) / 1 days) / 100) - player[_addr].dailyIncome;

                if(player[_addr].dailyIncome + payout > earningsLimitLeft) {
                    payout = earningsLimitLeft;
                }
            }
        }


        function startNextRound()
        private
         {


            uint256 _roundID = roundID;

            uint256 _poolAmount = round[roundID].pool;

                if (_poolAmount >= 10 ether) {
                    round[_roundID].ended = true;
                    uint256 distributedSponsorAwards = awardTopPromoters();
                    

                    if(etherwhales.length > 0)
                        awardEtherwhales();
                        
                    uint256 _whalePoolAmount = round[roundID].whalepool;

                    _roundID++;
                    roundID++;
                    round[_roundID].startTime = now;
                    round[_roundID].endTime = now.add(poolTime);
                    round[_roundID].pool = _poolAmount.sub(distributedSponsorAwards);
                    round[_roundID].whalepool = _whalePoolAmount;
                }
                else {
                    round[_roundID].startTime = now;
                    round[_roundID].endTime = now.add(poolTime);
                    round[_roundID].pool = _poolAmount;
                }
        }


        function addSponsorToPool(address _add)
            private
            returns (bool)
        {

            if (_add == address(0x0)){
                return false;
            }

            uint256 _amt = plyrRnds_[_add][roundID].ethVolume;
            if (topSponsors[3].amt >= _amt){
                return false;
            }

            address firstAddr = topSponsors[0].addr;
            uint256 firstAmt = topSponsors[0].amt;

            address secondAddr = topSponsors[1].addr;
            uint256 secondAmt = topSponsors[1].amt;

            address thirdAddr = topSponsors[2].addr;
            uint256 thirdAmt = topSponsors[2].amt;



            if (_amt > topSponsors[0].amt){

                if (topSponsors[0].addr == _add){
                    topSponsors[0].amt = _amt;
                    return true;
                }
                else if (topSponsors[1].addr == _add){

                    topSponsors[0].addr = _add;
                    topSponsors[0].amt = _amt;
                    topSponsors[1].addr = firstAddr;
                    topSponsors[1].amt = firstAmt;
                    return true;
                }
                else if (topSponsors[2].addr == _add) {
                    topSponsors[0].addr = _add;
                    topSponsors[0].amt = _amt;
                    topSponsors[1].addr = firstAddr;
                    topSponsors[1].amt = firstAmt;
                    topSponsors[2].addr = secondAddr;
                    topSponsors[2].amt = secondAmt;
                    return true;
                }
                else{

                    topSponsors[0].addr = _add;
                    topSponsors[0].amt = _amt;
                    topSponsors[1].addr = firstAddr;
                    topSponsors[1].amt = firstAmt;
                    topSponsors[2].addr = secondAddr;
                    topSponsors[2].amt = secondAmt;
                    topSponsors[3].addr = thirdAddr;
                    topSponsors[3].amt = thirdAmt;
                    return true;
                }
            }
            else if (_amt > topSponsors[1].amt){

                if (topSponsors[1].addr == _add){
                    topSponsors[1].amt = _amt;
                    return true;
                }
                else if(topSponsors[2].addr == _add) {
                    topSponsors[1].addr = _add;
                    topSponsors[1].amt = _amt;
                    topSponsors[2].addr = secondAddr;
                    topSponsors[2].amt = secondAmt;
                    return true;
                }
                else{
                    topSponsors[1].addr = _add;
                    topSponsors[1].amt = _amt;
                    topSponsors[2].addr = secondAddr;
                    topSponsors[2].amt = secondAmt;
                    topSponsors[3].addr = thirdAddr;
                    topSponsors[3].amt = thirdAmt;
                    return true;
                }
            }
            else if(_amt > topSponsors[2].amt){
                if(topSponsors[2].addr == _add) {
                    topSponsors[2].amt = _amt;
                    return true;
                }
                else {
                    topSponsors[2].addr = _add;
                    topSponsors[2].amt = _amt;
                    topSponsors[3].addr = thirdAddr;
                    topSponsors[3].amt = thirdAmt;
                }
            }
            else if (_amt > topSponsors[3].amt){

                 if (topSponsors[3].addr == _add){
                    topSponsors[3].amt = _amt;
                    return true;
                }

                else{
                    topSponsors[3].addr = _add;
                    topSponsors[3].amt = _amt;
                    return true;
                }
            }
        }

        function awardTopPromoters()
            private
            returns (uint256)
            {

                uint256 totAmt = round[roundID].pool.mul(10).div(100);
                uint256 distributedAmount;
                uint256 i;


                for (i = 0; i< 4; i++) {
                    if (topSponsors[i].addr != address(0x0)) {
                        player[topSponsors[i].addr].sponsorPoolIncome = player[topSponsors[i].addr].sponsorPoolIncome.add(totAmt.mul(awardPercentage[i]).div(100));
                        distributedAmount = distributedAmount.add(totAmt.mul(awardPercentage[i]).div(100));
                        emit roundAwardsEvent(topSponsors[i].addr, totAmt.mul(awardPercentage[i]).div(100));

                        lastTopSponsors[i].addr = topSponsors[i].addr;
                        lastTopSponsors[i].amt = topSponsors[i].amt;
                        lastTopSponsorsWinningAmount[i] = totAmt.mul(awardPercentage[i]).div(100);
                        topSponsors[i].addr = address(0x0);
                        topSponsors[i].amt = 0;
                    }
                    else {
                        break;
                    }
                }

                return distributedAmount;
            }

        function awardEtherwhales()
        private
        {

            uint256 totalWhales = etherwhales.length;

            uint256 toPayout = round[roundID].whalepool.div(totalWhales);
            for(uint256 i = 0; i < totalWhales; i++) {
                player[etherwhales[i]].whalepoolAward = player[etherwhales[i]].whalepoolAward.add(toPayout);
                emit etherWhaleAwardEvent(etherwhales[i], toPayout, now);
            }
            round[roundID].whalepool = 0;
        }

        function premiumInvestment()
        public
        payable {


            uint256 amount = msg.value;

            premiumReferralIncomeDistribution(getSender(), amount);

            address payable ownerAddr = address(uint160(owner));
            ownerAddr.transfer(amount.mul(5).div(100));
            emit premiumInvestmentEvent(getSender(), amount, player[getSender()].currInvestment);
        }

        function premiumReferralIncomeDistribution(address _playerAddress, uint256 amount)
        private {

            address _nextReferrer = player[_playerAddress].referrer;
            uint i;

            for(i=0; i < 5; i++) {

                if (_nextReferrer != address(0x0)) {
                    if(i == 0) {
                        player[_nextReferrer].premiumReferralIncome = player[_nextReferrer].premiumReferralIncome.add(amount.mul(20).div(100));
                        emit premiumReferralCommissionEvent(_playerAddress, _nextReferrer, amount.mul(20).div(100), now);
                    }

                    else if(i == 1 ) {
                        if(player[_nextReferrer].referralCount >= 2) {
                            player[_nextReferrer].premiumReferralIncome = player[_nextReferrer].premiumReferralIncome.add(amount.mul(10).div(100));
                            emit premiumReferralCommissionEvent(_playerAddress, _nextReferrer, amount.mul(10).div(100), now);
                        }
                    }

                    else {
                        if(player[_nextReferrer].referralCount >= i+1) {
                            player[_nextReferrer].premiumReferralIncome = player[_nextReferrer].premiumReferralIncome.add(amount.mul(5).div(100));
                            emit premiumReferralCommissionEvent(_playerAddress, _nextReferrer, amount.mul(5).div(100), now);
                        }
                    }
                }
                else {
                    break;
                }
                _nextReferrer = player[_nextReferrer].referrer;
            }
        }


        function drawPool() external onlyOwner {

            startNextRound();
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
    }

library DataStructs {


            struct DailyRound {
                uint256 startTime;
                uint256 endTime;
                bool ended; //has daily round ended
                uint256 pool; //amount in the pool
                uint256 whalepool; //deposits for whalepool
            }

            struct User {
                uint256 id;
                uint256 totalInvestment;
                uint256 directsIncome;
                uint256 roiReferralIncome;
                uint256 currInvestment;
                uint256 dailyIncome;
                uint256 depositTime;
                uint256 incomeLimitLeft;
                uint256 sponsorPoolIncome;
                uint256 referralCount;
                address referrer;
                uint256 cycle;
                uint256 whalepoolAward;
                uint256 premiumReferralIncome;
            }

            struct PlayerDailyRounds {
                uint256 ethVolume;
            }
    }