
pragma solidity 0.5.4;


library ECVerify {


    function ecverify(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address signature_address)
    {

        require(signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))

            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28);

        signature_address = ecrecover(hash, v, r, s);

        require(signature_address != address(0x0));

        return signature_address;
    }
}

interface Token {


    function totalSupply() external view returns (uint256 supply);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function decimals() external view returns (uint8 decimals);

}

contract Utils {

    enum MessageTypeId {
        None,
        BalanceProof,
        BalanceProofUpdate,
        Withdraw,
        CooperativeSettle,
        IOU,
        MSReward
    }

    function contractExists(address contract_address) public view returns (bool) {

        uint size;

        assembly {
            size := extcodesize(contract_address)
        }

        return size > 0;
    }
}


contract SecretRegistry {

    mapping(bytes32 => uint256) private secrethash_to_block;

    event SecretRevealed(bytes32 indexed secrethash, bytes32 secret);

    function registerSecret(bytes32 secret) public returns (bool) {

        bytes32 secrethash = sha256(abi.encodePacked(secret));
        if (secrethash_to_block[secrethash] > 0) {
            return false;
        }
        secrethash_to_block[secrethash] = block.number;
        emit SecretRevealed(secrethash, secret);
        return true;
    }

    function registerSecretBatch(bytes32[] memory secrets) public returns (bool) {

        bool completeSuccess = true;
        for(uint i = 0; i < secrets.length; i++) {
            if(!registerSecret(secrets[i])) {
                completeSuccess = false;
            }
        }
        return completeSuccess;
    }

    function getSecretRevealBlockHeight(bytes32 secrethash) public view returns (uint256) {

        return secrethash_to_block[secrethash];
    }
}






contract TokenNetwork is Utils {

    Token public token;

    SecretRegistry public secret_registry;

    uint256 public chain_id;

    uint256 public settlement_timeout_min;
    uint256 public settlement_timeout_max;

    uint256 constant public MAX_SAFE_UINT256 = (
        115792089237316195423570985008687907853269984665640564039457584007913129639935
    );

    uint256 public channel_participant_deposit_limit;
    uint256 public token_network_deposit_limit;

    uint256 public channel_counter;

    string public constant signature_prefix = '\x19Ethereum Signed Message:\n';

    address public deprecation_executor;
    bool public safety_deprecation_switch = false;

    mapping (uint256 => Channel) public channels;

    mapping (bytes32 => uint256) public participants_hash_to_channel_identifier;

    mapping(bytes32 => UnlockData) private unlock_identifier_to_unlock_data;

    struct Participant {
        uint256 deposit;

        uint256 withdrawn_amount;

        bool is_the_closer;

        bytes32 balance_hash;

        uint256 nonce;
    }

    enum ChannelState {
        NonExistent, // 0
        Opened,      // 1
        Closed,      // 2
        Settled,     // 3; Note: The channel has at least one pending unlock
        Removed      // 4; Note: Channel data is removed, there are no pending unlocks
    }

    struct Channel {
        uint256 settle_block_number;

        ChannelState state;

        mapping(address => Participant) participants;
    }

    struct SettlementData {
        uint256 deposit;
        uint256 withdrawn;
        uint256 transferred;
        uint256 locked;
    }

    struct UnlockData {
        bytes32 locksroot;
        uint256 locked_amount;
    }

    event ChannelOpened(
        uint256 indexed channel_identifier,
        address indexed participant1,
        address indexed participant2,
        uint256 settle_timeout
    );

    event ChannelNewDeposit(
        uint256 indexed channel_identifier,
        address indexed participant,
        uint256 total_deposit
    );

    event DeprecationSwitch(bool new_value);

    event ChannelWithdraw(
        uint256 indexed channel_identifier,
        address indexed participant,
        uint256 total_withdraw
    );

    event ChannelClosed(
        uint256 indexed channel_identifier,
        address indexed closing_participant,
        uint256 indexed nonce,
        bytes32 balance_hash
    );

    event ChannelUnlocked(
        uint256 indexed channel_identifier,
        address indexed receiver,
        address indexed sender,
        bytes32 locksroot,
        uint256 unlocked_amount,
        uint256 returned_tokens
    );

    event NonClosingBalanceProofUpdated(
        uint256 indexed channel_identifier,
        address indexed closing_participant,
        uint256 indexed nonce,
        bytes32 balance_hash
    );

    event ChannelSettled(
        uint256 indexed channel_identifier,
        uint256 participant1_amount,
        bytes32 participant1_locksroot,
        uint256 participant2_amount,
        bytes32 participant2_locksroot
    );

    modifier onlyDeprecationExecutor() {

        require(msg.sender == deprecation_executor);
        _;
    }

    modifier isSafe() {

        require(safety_deprecation_switch == false);
        _;
    }

    modifier isOpen(uint256 channel_identifier) {

        require(channels[channel_identifier].state == ChannelState.Opened);
        _;
    }

    modifier settleTimeoutValid(uint256 timeout) {

        require(timeout >= settlement_timeout_min);
        require(timeout <= settlement_timeout_max);
        _;
    }

    constructor(
        address _token_address,
        address _secret_registry,
        uint256 _chain_id,
        uint256 _settlement_timeout_min,
        uint256 _settlement_timeout_max,
        address _deprecation_executor,
        uint256 _channel_participant_deposit_limit,
        uint256 _token_network_deposit_limit
    )
        public
    {
        require(_token_address != address(0x0));
        require(_secret_registry != address(0x0));
        require(_deprecation_executor != address(0x0));
        require(_chain_id > 0);
        require(_settlement_timeout_min > 0);
        require(_settlement_timeout_max > _settlement_timeout_min);
        require(contractExists(_token_address));
        require(contractExists(_secret_registry));
        require(_channel_participant_deposit_limit > 0);
        require(_token_network_deposit_limit > 0);
        require(_token_network_deposit_limit >= _channel_participant_deposit_limit);

        token = Token(_token_address);

        secret_registry = SecretRegistry(_secret_registry);
        chain_id = _chain_id;
        settlement_timeout_min = _settlement_timeout_min;
        settlement_timeout_max = _settlement_timeout_max;

        require(token.totalSupply() > 0);

        deprecation_executor = _deprecation_executor;
        channel_participant_deposit_limit = _channel_participant_deposit_limit;
        token_network_deposit_limit = _token_network_deposit_limit;
    }

    function deprecate() public isSafe onlyDeprecationExecutor {

        safety_deprecation_switch = true;
        emit DeprecationSwitch(safety_deprecation_switch);
    }

    function openChannel(address participant1, address participant2, uint256 settle_timeout)
        public
        isSafe
        settleTimeoutValid(settle_timeout)
        returns (uint256)
    {

        bytes32 pair_hash;
        uint256 channel_identifier;

        require(token.balanceOf(address(this)) < token_network_deposit_limit);

        channel_counter += 1;
        channel_identifier = channel_counter;

        pair_hash = getParticipantsHash(participant1, participant2);

        require(participants_hash_to_channel_identifier[pair_hash] == 0);
        participants_hash_to_channel_identifier[pair_hash] = channel_identifier;

        Channel storage channel = channels[channel_identifier];

        assert(channel.settle_block_number == 0);
        assert(channel.state == ChannelState.NonExistent);

        channel.settle_block_number = settle_timeout;
        channel.state = ChannelState.Opened;

        emit ChannelOpened(
            channel_identifier,
            participant1,
            participant2,
            settle_timeout
        );

        return channel_identifier;
    }

    function setTotalDeposit(
        uint256 channel_identifier,
        address participant,
        uint256 total_deposit,
        address partner
    )
        public
        isSafe
        isOpen(channel_identifier)
    {

        require(channel_identifier == getChannelIdentifier(participant, partner));
        require(total_deposit > 0);
        require(total_deposit <= channel_participant_deposit_limit);

        uint256 added_deposit;
        uint256 channel_deposit;

        Channel storage channel = channels[channel_identifier];
        Participant storage participant_state = channel.participants[participant];
        Participant storage partner_state = channel.participants[partner];

        added_deposit = total_deposit - participant_state.deposit;

        require(added_deposit > 0);


        require(added_deposit <= total_deposit);

        assert(participant_state.deposit + added_deposit == total_deposit);

        require(token.balanceOf(address(this)) + added_deposit <= token_network_deposit_limit);

        participant_state.deposit = total_deposit;

        channel_deposit = participant_state.deposit + partner_state.deposit;
        require(channel_deposit >= participant_state.deposit);

        emit ChannelNewDeposit(
            channel_identifier,
            participant,
            participant_state.deposit
        );

        require(token.transferFrom(msg.sender, address(this), added_deposit));
    }

    function setTotalWithdraw(
        uint256 channel_identifier,
        address participant,
        uint256 total_withdraw,
        uint256 expiration_block,
        bytes calldata participant_signature,
        bytes calldata partner_signature
    )
        external
        isOpen(channel_identifier)
    {

        uint256 total_deposit;
        uint256 current_withdraw;
        address partner;

        require(total_withdraw > 0);
        require(block.number < expiration_block);

        require(participant == recoverAddressFromWithdrawMessage(
            channel_identifier,
            participant,
            total_withdraw,
            expiration_block,
            participant_signature
        ));
        partner = recoverAddressFromWithdrawMessage(
            channel_identifier,
            participant,
            total_withdraw,
            expiration_block,
            partner_signature
        );

        require(channel_identifier == getChannelIdentifier(participant, partner));

        Channel storage channel = channels[channel_identifier];
        Participant storage participant_state = channel.participants[participant];
        Participant storage partner_state = channel.participants[partner];

        total_deposit = participant_state.deposit + partner_state.deposit;

        require((total_withdraw + partner_state.withdrawn_amount) <= total_deposit);
        require(total_withdraw <= (total_withdraw + partner_state.withdrawn_amount));

        current_withdraw = total_withdraw - participant_state.withdrawn_amount;
        require(current_withdraw <= total_withdraw);

        require(current_withdraw > 0);

        assert(participant_state.withdrawn_amount + current_withdraw == total_withdraw);

        emit ChannelWithdraw(
            channel_identifier,
            participant,
            total_withdraw
        );

        participant_state.withdrawn_amount = total_withdraw;
        require(token.transfer(participant, current_withdraw));

        assert(total_deposit >= participant_state.deposit);
        assert(total_deposit >= partner_state.deposit);

        assert(participant_state.nonce == 0);
        assert(partner_state.nonce == 0);

    }

    function closeChannel(
        uint256 channel_identifier,
        address non_closing_participant,
        address closing_participant,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes memory non_closing_signature,
        bytes memory closing_signature
    )
        public
        isOpen(channel_identifier)
    {

        require(channel_identifier == getChannelIdentifier(closing_participant, non_closing_participant));

        address recovered_non_closing_participant_address;

        Channel storage channel = channels[channel_identifier];

        channel.state = ChannelState.Closed;
        channel.participants[closing_participant].is_the_closer = true;

        channel.settle_block_number += uint256(block.number);

        address recovered_closing_participant_address = recoverAddressFromBalanceProofCounterSignature(
            MessageTypeId.BalanceProof,
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            non_closing_signature,
            closing_signature
        );
        require(closing_participant == recovered_closing_participant_address);

        if (nonce > 0) {
            recovered_non_closing_participant_address = recoverAddressFromBalanceProof(
                channel_identifier,
                balance_hash,
                nonce,
                additional_hash,
                non_closing_signature
            );
            require(non_closing_participant == recovered_non_closing_participant_address);

            updateBalanceProofData(
                channel,
                recovered_non_closing_participant_address,
                nonce,
                balance_hash
            );
        }

        emit ChannelClosed(channel_identifier, closing_participant, nonce, balance_hash);
    }

    function updateNonClosingBalanceProof(
        uint256 channel_identifier,
        address closing_participant,
        address non_closing_participant,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes calldata closing_signature,
        bytes calldata non_closing_signature
    )
        external
    {

        require(channel_identifier == getChannelIdentifier(
            closing_participant,
            non_closing_participant
        ));
        require(balance_hash != bytes32(0x0));
        require(nonce > 0);

        address recovered_non_closing_participant;
        address recovered_closing_participant;

        Channel storage channel = channels[channel_identifier];

        require(channel.state == ChannelState.Closed);

        require(channel.settle_block_number >= block.number);

        recovered_non_closing_participant = recoverAddressFromBalanceProofCounterSignature(
            MessageTypeId.BalanceProofUpdate,
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature,
            non_closing_signature
        );
        require(non_closing_participant == recovered_non_closing_participant);

        recovered_closing_participant = recoverAddressFromBalanceProof(
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature
        );
        require(closing_participant == recovered_closing_participant);

        Participant storage closing_participant_state = channel.participants[closing_participant];
        require(closing_participant_state.is_the_closer);

        updateBalanceProofData(channel, closing_participant, nonce, balance_hash);

        emit NonClosingBalanceProofUpdated(
            channel_identifier,
            closing_participant,
            nonce,
            balance_hash
        );
    }

    function settleChannel(
        uint256 channel_identifier,
        address participant1,
        uint256 participant1_transferred_amount,
        uint256 participant1_locked_amount,
        bytes32 participant1_locksroot,
        address participant2,
        uint256 participant2_transferred_amount,
        uint256 participant2_locked_amount,
        bytes32 participant2_locksroot
    )
        public
    {


        require(channel_identifier == getChannelIdentifier(participant1, participant2));

        bytes32 pair_hash;

        pair_hash = getParticipantsHash(participant1, participant2);
        Channel storage channel = channels[channel_identifier];

        require(channel.state == ChannelState.Closed);

        require(channel.settle_block_number < block.number);

        Participant storage participant1_state = channel.participants[participant1];
        Participant storage participant2_state = channel.participants[participant2];

        require(verifyBalanceHashData(
            participant1_state,
            participant1_transferred_amount,
            participant1_locked_amount,
            participant1_locksroot
        ));

        require(verifyBalanceHashData(
            participant2_state,
            participant2_transferred_amount,
            participant2_locked_amount,
            participant2_locksroot
        ));

        (
            participant1_transferred_amount,
            participant2_transferred_amount,
            participant1_locked_amount,
            participant2_locked_amount
        ) = getSettleTransferAmounts(
            participant1_state,
            participant1_transferred_amount,
            participant1_locked_amount,
            participant2_state,
            participant2_transferred_amount,
            participant2_locked_amount
        );

        delete channel.participants[participant1];
        delete channel.participants[participant2];
        delete channels[channel_identifier];

        delete participants_hash_to_channel_identifier[pair_hash];

        storeUnlockData(
            channel_identifier,
            participant1,
            participant2,
            participant1_locked_amount,
            participant1_locksroot
        );
        storeUnlockData(
            channel_identifier,
            participant2,
            participant1,
            participant2_locked_amount,
            participant2_locksroot
        );

        emit ChannelSettled(
            channel_identifier,
            participant1_transferred_amount,
            participant1_locksroot,
            participant2_transferred_amount,
            participant2_locksroot
        );

        if (participant1_transferred_amount > 0) {
            require(token.transfer(participant1, participant1_transferred_amount));
        }

        if (participant2_transferred_amount > 0) {
            require(token.transfer(participant2, participant2_transferred_amount));
        }
    }

    function unlock(
        uint256 channel_identifier,
        address receiver,
        address sender,
        bytes memory locks
    )
        public
    {

        require(channel_identifier != getChannelIdentifier(receiver, sender));

        require(channels[channel_identifier].state == ChannelState.NonExistent);

        bytes32 unlock_key;
        bytes32 computed_locksroot;
        uint256 unlocked_amount;
        uint256 locked_amount;
        uint256 returned_tokens;

        (computed_locksroot, unlocked_amount) = getHashAndUnlockedAmount(
            locks
        );

        unlock_key = getUnlockIdentifier(channel_identifier, sender, receiver);
        UnlockData storage unlock_data = unlock_identifier_to_unlock_data[unlock_key];
        locked_amount = unlock_data.locked_amount;

        require(unlock_data.locksroot == computed_locksroot);

        require(locked_amount > 0);

        unlocked_amount = min(unlocked_amount, locked_amount);

        returned_tokens = locked_amount - unlocked_amount;

        delete unlock_identifier_to_unlock_data[unlock_key];

        emit ChannelUnlocked(
            channel_identifier,
            receiver,
            sender,
            computed_locksroot,
            unlocked_amount,
            returned_tokens
        );

        if (unlocked_amount > 0) {
            require(token.transfer(receiver, unlocked_amount));
        }

        if (returned_tokens > 0) {
            require(token.transfer(sender, returned_tokens));
        }

        assert(locked_amount >= returned_tokens);
        assert(locked_amount >= unlocked_amount);
    }


    function getChannelIdentifier(address participant, address partner)
        public
        view
        returns (uint256)
    {

        require(participant != address(0x0));
        require(partner != address(0x0));
        require(participant != partner);

        bytes32 pair_hash = getParticipantsHash(participant, partner);
        return participants_hash_to_channel_identifier[pair_hash];
    }

    function getChannelInfo(
        uint256 channel_identifier,
        address participant1,
        address participant2
    )
        external
        view
        returns (uint256, ChannelState)
    {

        bytes32 unlock_key1;
        bytes32 unlock_key2;

        Channel storage channel = channels[channel_identifier];
        ChannelState state = channel.state;  // This must **not** update the storage

        if (state == ChannelState.NonExistent &&
            channel_identifier > 0 &&
            channel_identifier <= channel_counter
        ) {
            state = ChannelState.Settled;

            unlock_key1 = getUnlockIdentifier(channel_identifier, participant1, participant2);
            UnlockData storage unlock_data1 = unlock_identifier_to_unlock_data[unlock_key1];

            unlock_key2 = getUnlockIdentifier(channel_identifier, participant2, participant1);
            UnlockData storage unlock_data2 = unlock_identifier_to_unlock_data[unlock_key2];

            if (unlock_data1.locked_amount == 0 && unlock_data2.locked_amount == 0) {
                state = ChannelState.Removed;
            }
        }

        return (
            channel.settle_block_number,
            state
        );
    }

    function getChannelParticipantInfo(
            uint256 channel_identifier,
            address participant,
            address partner
    )
        external
        view
        returns (uint256, uint256, bool, bytes32, uint256, bytes32, uint256)
    {

        bytes32 unlock_key;

        Participant storage participant_state = channels[channel_identifier].participants[
            participant
        ];
        unlock_key = getUnlockIdentifier(channel_identifier, participant, partner);
        UnlockData storage unlock_data = unlock_identifier_to_unlock_data[unlock_key];

        return (
            participant_state.deposit,
            participant_state.withdrawn_amount,
            participant_state.is_the_closer,
            participant_state.balance_hash,
            participant_state.nonce,
            unlock_data.locksroot,
            unlock_data.locked_amount
        );
    }

    function getParticipantsHash(address participant, address partner)
        public
        pure
        returns (bytes32)
    {

        require(participant != address(0x0));
        require(partner != address(0x0));
        require(participant != partner);

        if (participant < partner) {
            return keccak256(abi.encodePacked(participant, partner));
        } else {
            return keccak256(abi.encodePacked(partner, participant));
        }
    }

    function getUnlockIdentifier(
        uint256 channel_identifier,
        address sender,
        address receiver
    )
        public
        pure
        returns (bytes32)
    {

        require(sender != receiver);
        return keccak256(abi.encodePacked(channel_identifier, sender, receiver));
    }

    function updateBalanceProofData(
        Channel storage channel,
        address participant,
        uint256 nonce,
        bytes32 balance_hash
    )
        internal
    {

        Participant storage participant_state = channel.participants[participant];

        require(nonce > participant_state.nonce);

        participant_state.nonce = nonce;
        participant_state.balance_hash = balance_hash;
    }

    function storeUnlockData(
        uint256 channel_identifier,
        address sender,
        address receiver,
        uint256 locked_amount,
        bytes32 locksroot
    )
        internal
    {

        if (locked_amount == 0) {
            return;
        }

        bytes32 key = getUnlockIdentifier(channel_identifier, sender, receiver);
        UnlockData storage unlock_data = unlock_identifier_to_unlock_data[key];
        unlock_data.locksroot = locksroot;
        unlock_data.locked_amount = locked_amount;
    }

    function getChannelAvailableDeposit(
        Participant storage participant1_state,
        Participant storage participant2_state
    )
        internal
        view
        returns (uint256 total_available_deposit)
    {

        total_available_deposit = (
            participant1_state.deposit +
            participant2_state.deposit -
            participant1_state.withdrawn_amount -
            participant2_state.withdrawn_amount
        );
    }

    function getSettleTransferAmounts(
        Participant storage participant1_state,
        uint256 participant1_transferred_amount,
        uint256 participant1_locked_amount,
        Participant storage participant2_state,
        uint256 participant2_transferred_amount,
        uint256 participant2_locked_amount
    )
        private
        view
        returns (uint256, uint256, uint256, uint256)
    {











        uint256 participant1_amount;
        uint256 participant2_amount;
        uint256 total_available_deposit;

        SettlementData memory participant1_settlement;
        SettlementData memory participant2_settlement;

        participant1_settlement.deposit = participant1_state.deposit;
        participant1_settlement.withdrawn = participant1_state.withdrawn_amount;
        participant1_settlement.transferred = participant1_transferred_amount;
        participant1_settlement.locked = participant1_locked_amount;

        participant2_settlement.deposit = participant2_state.deposit;
        participant2_settlement.withdrawn = participant2_state.withdrawn_amount;
        participant2_settlement.transferred = participant2_transferred_amount;
        participant2_settlement.locked = participant2_locked_amount;

        total_available_deposit = getChannelAvailableDeposit(
            participant1_state,
            participant2_state
        );

        participant1_amount = getMaxPossibleReceivableAmount(
            participant1_settlement,
            participant2_settlement
        );

        participant1_amount = min(participant1_amount, total_available_deposit);

        participant2_amount = total_available_deposit - participant1_amount;

        (participant1_amount, participant2_locked_amount) = failsafe_subtract(
            participant1_amount,
            participant2_locked_amount
        );

        (participant2_amount, participant1_locked_amount) = failsafe_subtract(
            participant2_amount,
            participant1_locked_amount
        );

        assert(participant1_amount <= total_available_deposit);
        assert(participant2_amount <= total_available_deposit);
        assert(total_available_deposit == (
            participant1_amount +
            participant2_amount +
            participant1_locked_amount +
            participant2_locked_amount
        ));

        return (
            participant1_amount,
            participant2_amount,
            participant1_locked_amount,
            participant2_locked_amount
        );
    }

    function getMaxPossibleReceivableAmount(
        SettlementData memory participant1_settlement,
        SettlementData memory participant2_settlement
    )
        internal
        pure
        returns (uint256)
    {

        uint256 participant1_max_transferred;
        uint256 participant2_max_transferred;
        uint256 participant1_net_max_received;
        uint256 participant1_max_amount;

        participant1_max_transferred = failsafe_addition(
            participant1_settlement.transferred,
            participant1_settlement.locked
        );

        participant2_max_transferred = failsafe_addition(
            participant2_settlement.transferred,
            participant2_settlement.locked
        );

        require(participant2_max_transferred >= participant1_max_transferred);

        assert(participant1_max_transferred >= participant1_settlement.transferred);
        assert(participant2_max_transferred >= participant2_settlement.transferred);

        participant1_net_max_received = (
            participant2_max_transferred -
            participant1_max_transferred
        );

        participant1_max_amount = failsafe_addition(
            participant1_net_max_received,
            participant1_settlement.deposit
        );

        (participant1_max_amount, ) = failsafe_subtract(
            participant1_max_amount,
            participant1_settlement.withdrawn
        );
        return participant1_max_amount;
    }

    function verifyBalanceHashData(
        Participant storage participant,
        uint256 transferred_amount,
        uint256 locked_amount,
        bytes32 locksroot
    )
        internal
        view
        returns (bool)
    {

        if (participant.balance_hash == 0 &&
            transferred_amount == 0 &&
            locked_amount == 0
        ) {
            return true;
        }

        return participant.balance_hash == keccak256(abi.encodePacked(
            transferred_amount,
            locked_amount,
            locksroot
        ));
    }

    function recoverAddressFromBalanceProof(
        uint256 channel_identifier,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes memory signature
    )
        internal
        view
        returns (address signature_address)
    {

        string memory message_length = '212';

        bytes32 message_hash = keccak256(abi.encodePacked(
            signature_prefix,
            message_length,
            address(this),
            chain_id,
            uint256(MessageTypeId.BalanceProof),
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function recoverAddressFromBalanceProofCounterSignature(
        MessageTypeId message_type_id,
        uint256 channel_identifier,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes memory closing_signature,
        bytes memory non_closing_signature
    )
        internal
        view
        returns (address signature_address)
    {

        string memory message_length = '277';

        bytes32 message_hash = keccak256(abi.encodePacked(
            signature_prefix,
            message_length,
            address(this),
            chain_id,
            uint256(message_type_id),
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature
        ));

        signature_address = ECVerify.ecverify(message_hash, non_closing_signature);
    }


    function recoverAddressFromWithdrawMessage(
        uint256 channel_identifier,
        address participant,
        uint256 total_withdraw,
        uint256 expiration_block,
        bytes memory signature
    )
        internal
        view
        returns (address signature_address)
    {

        string memory message_length = '200';

        bytes32 message_hash = keccak256(abi.encodePacked(
            signature_prefix,
            message_length,
            address(this),
            chain_id,
            uint256(MessageTypeId.Withdraw),
            channel_identifier,
            participant,
            total_withdraw,
            expiration_block
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function getHashAndUnlockedAmount(bytes memory locks)
        internal
        view
        returns (bytes32, uint256)
    {

        uint256 length = locks.length;

        require(length % 96 == 0);

        uint256 i;
        uint256 total_unlocked_amount;
        uint256 unlocked_amount;
        bytes32 lockhash;
        bytes32 total_hash;

        for (i = 32; i < length; i += 96) {
            unlocked_amount = getLockedAmountFromLock(locks, i);
            total_unlocked_amount += unlocked_amount;
        }

        total_hash = keccak256(locks);

        return (total_hash, total_unlocked_amount);
    }

    function getLockedAmountFromLock(bytes memory locks, uint256 offset)
        internal
        view
        returns (uint256)
    {

        uint256 expiration_block;
        uint256 locked_amount;
        uint256 reveal_block;
        bytes32 secrethash;

        if (locks.length <= offset) {
            return 0;
        }

        assembly {
            expiration_block := mload(add(locks, offset))
            locked_amount := mload(add(locks, add(offset, 32)))
            secrethash := mload(add(locks, add(offset, 64)))
        }

        reveal_block = secret_registry.getSecretRevealBlockHeight(secrethash);
        if (reveal_block == 0 || expiration_block <= reveal_block) {
            locked_amount = 0;
        }

        return locked_amount;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256)
    {

        return a > b ? b : a;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256)
    {

        return a > b ? a : b;
    }

    function failsafe_subtract(uint256 a, uint256 b)
        internal
        pure
        returns (uint256, uint256)
    {

        return a > b ? (a - b, b) : (0, a);
    }

    function failsafe_addition(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 sum = a + b;
        return sum >= a ? sum : MAX_SAFE_UINT256;
    }
}



contract TokenNetworkRegistry is Utils {

    address public secret_registry_address;
    uint256 public chain_id;
    uint256 public settlement_timeout_min;
    uint256 public settlement_timeout_max;
    uint256 public max_token_networks;

    address public deprecation_executor;
    uint256 public token_network_created = 0;

    mapping(address => address) public token_to_token_networks;

    event TokenNetworkCreated(address indexed token_address, address indexed token_network_address);

    modifier canCreateTokenNetwork() {

        require(token_network_created < max_token_networks, "registry full");
        _;
    }

    constructor(
        address _secret_registry_address,
        uint256 _chain_id,
        uint256 _settlement_timeout_min,
        uint256 _settlement_timeout_max,
        uint256 _max_token_networks
    )
        public
    {
        require(_chain_id > 0);
        require(_settlement_timeout_min > 0);
        require(_settlement_timeout_max > 0);
        require(_settlement_timeout_max > _settlement_timeout_min);
        require(_secret_registry_address != address(0x0));
        require(contractExists(_secret_registry_address));
        require(_max_token_networks > 0);
        secret_registry_address = _secret_registry_address;
        chain_id = _chain_id;
        settlement_timeout_min = _settlement_timeout_min;
        settlement_timeout_max = _settlement_timeout_max;
        max_token_networks = _max_token_networks;

        deprecation_executor = msg.sender;
    }

    function createERC20TokenNetwork(
        address _token_address,
        uint256 _channel_participant_deposit_limit,
        uint256 _token_network_deposit_limit
    )
        external
        canCreateTokenNetwork
        returns (address token_network_address)
    {

        require(token_to_token_networks[_token_address] == address(0x0));

        token_network_created = token_network_created + 1;

        TokenNetwork token_network;

        token_network = new TokenNetwork(
            _token_address,
            secret_registry_address,
            chain_id,
            settlement_timeout_min,
            settlement_timeout_max,
            deprecation_executor,
            _channel_participant_deposit_limit,
            _token_network_deposit_limit
        );

        token_network_address = address(token_network);

        token_to_token_networks[_token_address] = token_network_address;
        emit TokenNetworkCreated(_token_address, token_network_address);

        return token_network_address;
    }
}







contract ServiceRegistryConfigurableParameters {

    address public controller;

    modifier onlyController() {

        require(msg.sender == controller, "caller is not the controller");
        _;
    }

    uint256 public set_price;
    uint256 public set_price_at;

    uint256 public decay_constant = 200 days;

    uint256 public min_price = 1000;

    uint256 public price_bump_numerator = 1;
    uint256 public price_bump_denominator = 1;

    uint256 public registration_duration = 180 days;

    bool public deprecated = false;

    function setDeprecationSwitch() public onlyController returns (bool _success) {

        deprecated = true;
        return true;
    }

    function changeParameters(
            uint256 _price_bump_numerator,
            uint256 _price_bump_denominator,
            uint256 _decay_constant,
            uint256 _min_price,
            uint256 _registration_duration
    ) public onlyController returns (bool _success) {

        changeParametersInternal(
            _price_bump_numerator,
            _price_bump_denominator,
            _decay_constant,
            _min_price,
            _registration_duration
        );
        return true;
    }

    function changeParametersInternal(
            uint256 _price_bump_numerator,
            uint256 _price_bump_denominator,
            uint256 _decay_constant,
            uint256 _min_price,
            uint256 _registration_duration
    ) internal {

        refreshPrice();
        setPriceBumpParameters(_price_bump_numerator, _price_bump_denominator);
        setMinPrice(_min_price);
        setDecayConstant(_decay_constant);
        setRegistrationDuration(_registration_duration);
    }

    function refreshPrice() private {

        set_price = currentPrice();
        set_price_at = now;
    }

    function setPriceBumpParameters(
            uint256 _price_bump_numerator,
            uint256 _price_bump_denominator
    ) private {

        require(_price_bump_denominator > 0, "divide by zero");
        require(_price_bump_numerator >= _price_bump_denominator, "price dump instead of bump");
        require(_price_bump_numerator < 2 ** 40, "price dump numerator is too big");
        price_bump_numerator = _price_bump_numerator;
        price_bump_denominator = _price_bump_denominator;
    }

    function setMinPrice(uint256 _min_price) private {

        min_price = _min_price;
    }

    function setDecayConstant(uint256 _decay_constant) private {

        require(_decay_constant > 0, "attempt to set zero decay constant");
        require(_decay_constant < 2 ** 40, "too big decay constant");
        decay_constant = _decay_constant;
    }

    function setRegistrationDuration(uint256 _registration_duration) private {

        registration_duration = _registration_duration;
    }


    function currentPrice() public view returns (uint256) {

        require(now >= set_price_at, "An underflow in price computation");
        uint256 seconds_passed = now - set_price_at;

        return decayedPrice(set_price, seconds_passed);
    }


    function decayedPrice(uint256 _set_price, uint256 _seconds_passed) public
        view returns (uint256) {



        uint256 X = _seconds_passed;

        if (X >= 2 ** 40) { // The computation below overflows.
            return min_price;
        }

        uint256 A = decay_constant;

        uint256 P = 24 * (A ** 4);
        uint256 Q = P + 24*(A**3)*X + 12*(A**2)*(X**2) + 4*A*(X**3) + X**4;

        uint256 price = _set_price * P / Q;

        if (price < min_price) {
            price = min_price;
        }
        return price;
    }
}


contract Deposit {


    Token public token;

    ServiceRegistryConfigurableParameters service_registry;

    address public withdrawer;

    uint256 public release_at;

    constructor(address _token, uint256 _release_at, address _withdrawer, address _service_registry) public {
        token = Token(_token);
        release_at = _release_at;
        withdrawer = _withdrawer;
        service_registry = ServiceRegistryConfigurableParameters(_service_registry);
    }


    function withdraw(address payable _to) external {

        uint256 balance = token.balanceOf(address(this));
        require(msg.sender == withdrawer, "the caller is not the withdrawer");
        require(now >= release_at || service_registry.deprecated(), "deposit not released yet");
        require(balance > 0, "nothing to withdraw");
        require(token.transfer(_to, balance), "token didn't transfer");
        selfdestruct(_to); // The contract can disappear.
    }
}


contract ServiceRegistry is Utils, ServiceRegistryConfigurableParameters {

    Token public token;

    mapping(address => uint256) public service_valid_till;
    mapping(address => string) public urls;  // URLs of services for HTTP access

    address[] public ever_made_deposits;

    event RegisteredService(address indexed service, uint256 valid_till, uint256 deposit_amount, Deposit deposit_contract);

    constructor(
            address _token_for_registration,
            address _controller,
            uint256 _initial_price,
            uint256 _price_bump_numerator,
            uint256 _price_bump_denominator,
            uint256 _decay_constant,
            uint256 _min_price,
            uint256 _registration_duration
    ) public {
        require(_token_for_registration != address(0x0), "token at address zero");
        require(contractExists(_token_for_registration), "token has no code");
        require(_initial_price >= min_price, "initial price too low");
        require(_initial_price <= 2 ** 90, "intiial price too high");

        token = Token(_token_for_registration);
        require(token.totalSupply() > 0, "total supply zero");
        controller = _controller;

        set_price = _initial_price;
        set_price_at = now;

        changeParametersInternal(_price_bump_numerator, _price_bump_denominator, _decay_constant, _min_price, _registration_duration);
    }

    function deposit(uint _limit_amount) public returns (bool _success) {

        require(! deprecated, "this contract was deprecated");

        uint256 amount = currentPrice();
        require(_limit_amount >= amount, "not enough limit");

        uint256 valid_till = service_valid_till[msg.sender];
        if (valid_till == 0) { // a first time joiner
            ever_made_deposits.push(msg.sender);
        }
        if (valid_till < now) { // a first time joiner or an expired service.
            valid_till = now;
        }
        require(valid_till < valid_till + registration_duration, "overflow during extending the registration");
        valid_till = valid_till + registration_duration;
        assert(valid_till > service_valid_till[msg.sender]);
        service_valid_till[msg.sender] = valid_till;

        set_price = amount * price_bump_numerator / price_bump_denominator;
        if (set_price > 2 ** 90) {
            set_price = 2 ** 90; // Preventing overflows.
        }
        set_price_at = now;

        assert(now < valid_till);
        Deposit depo = new Deposit(address(token), valid_till, msg.sender, address(this));
        require(token.transferFrom(msg.sender, address(depo), amount), "Token transfer for deposit failed");

        emit RegisteredService(msg.sender, valid_till, amount, depo);

        return true;
    }

    function setURL(string memory new_url) public returns (bool _success) {

        require(hasValidRegistration(msg.sender), "registration expired");
        require(bytes(new_url).length != 0, "new url is empty string");
        urls[msg.sender] = new_url;
        return true;
    }

    function everMadeDepositsLen() public view returns (uint256 _len) {

        return ever_made_deposits.length;
    }

    function hasValidRegistration(address _address) public view returns (bool _has_registration) {

        return now < service_valid_till[_address];
    }
}








contract UserDeposit is Utils {

    uint constant public withdraw_delay = 100;  // time before withdraw is allowed in blocks

    Token public token;

    address public msc_address;
    address public one_to_n_address;

    mapping(address => uint256) public total_deposit;
    mapping(address => uint256) public balances;
    mapping(address => WithdrawPlan) public withdraw_plans;

    uint256 public whole_balance = 0;
    uint256 public whole_balance_limit;

    struct WithdrawPlan {
        uint256 amount;
        uint256 withdraw_block;  // earliest block at which withdraw is allowed
    }


    event BalanceReduced(address indexed owner, uint newBalance);
    event WithdrawPlanned(address indexed withdrawer, uint plannedBalance);


    modifier canTransfer() {

        require(msg.sender == msc_address || msg.sender == one_to_n_address, "unknown caller");
        _;
    }


    constructor(address _token_address, uint256 _whole_balance_limit)
        public
    {
        require(_token_address != address(0x0), "token at address zero");
        require(contractExists(_token_address), "token has no code");
        token = Token(_token_address);
        require(token.totalSupply() > 0, "token has no total supply"); // Check if the contract is indeed a token contract
        require(_whole_balance_limit > 0, "whole balance limit is zero");
        whole_balance_limit = _whole_balance_limit;
    }

    function init(address _msc_address, address _one_to_n_address)
        external
    {

        require(msc_address == address(0x0) && one_to_n_address == address(0x0), "already initialized");

        require(_msc_address != address(0x0), "MS contract at address zero");
        require(contractExists(_msc_address), "MS contract has no code");
        msc_address = _msc_address;

        require(_one_to_n_address != address(0x0), "OneToN at address zero");
        require(contractExists(_one_to_n_address), "OneToN has no code");
        one_to_n_address = _one_to_n_address;
    }

    function deposit(address beneficiary, uint256 new_total_deposit)
        external
    {

        require(new_total_deposit > total_deposit[beneficiary], "deposit not increasing");

        uint256 added_deposit = new_total_deposit - total_deposit[beneficiary];

        balances[beneficiary] += added_deposit;
        total_deposit[beneficiary] += added_deposit;

        require(whole_balance + added_deposit >= whole_balance, "overflowing deposit");
        whole_balance += added_deposit;

        require(whole_balance <= whole_balance_limit, "too much deposit");

        require(token.transferFrom(msg.sender, address(this), added_deposit), "tokens didn't transfer");
    }

    function transfer(
        address sender,
        address receiver,
        uint256 amount
    )
        canTransfer()
        external
        returns (bool success)
    {

        require(sender != receiver, "sender == receiver");
        if (balances[sender] >= amount && amount > 0) {
            balances[sender] -= amount;
            balances[receiver] += amount;
            emit BalanceReduced(sender, balances[sender]);
            return true;
        } else {
            return false;
        }
    }

    function planWithdraw(uint256 amount)
        external
    {

        require(amount > 0, "withdrawing zero");
        require(balances[msg.sender] >= amount, "withdrawing too much");

        withdraw_plans[msg.sender] = WithdrawPlan({
            amount: amount,
            withdraw_block: block.number + withdraw_delay
        });
        emit WithdrawPlanned(msg.sender, balances[msg.sender] - amount);
    }

    function withdraw(uint256 amount)
        external
    {

        WithdrawPlan storage withdraw_plan = withdraw_plans[msg.sender];
        require(amount <= withdraw_plan.amount, "withdrawing more than planned");
        require(withdraw_plan.withdraw_block <= block.number, "withdrawing too early");
        uint256 withdrawable = min(amount, balances[msg.sender]);
        balances[msg.sender] -= withdrawable;

        require(whole_balance - withdrawable <= whole_balance, "underflow in whole_balance");
        whole_balance -= withdrawable;

        emit BalanceReduced(msg.sender, balances[msg.sender]);
        delete withdraw_plans[msg.sender];

        require(token.transfer(msg.sender, withdrawable), "tokens didn't transfer");
    }

    function effectiveBalance(address owner)
        external
        view
        returns (uint256 remaining_balance)
    {

        WithdrawPlan storage withdraw_plan = withdraw_plans[owner];
        if (withdraw_plan.amount > balances[owner]) {
            return 0;
        }
        return balances[owner] - withdraw_plan.amount;
    }

    function min(uint256 a, uint256 b) pure internal returns (uint256)
    {

        return a > b ? b : a;
    }
}







contract MonitoringService is Utils {

    Token public token;

    ServiceRegistry public service_registry;
    UserDeposit public user_deposit;
    TokenNetworkRegistry public token_network_registry;

    mapping(bytes32 => Reward) internal rewards;

    struct Reward{
        uint256 reward_amount;

        uint256 nonce;

        address reward_sender_address;

        address monitoring_service_address;
    }


    event NewBalanceProofReceived(
        address token_network_address,
        uint256 channel_identifier,
        uint256 reward_amount,
        uint256 indexed nonce,
        address indexed ms_address,
        address indexed raiden_node_address
    );
    event RewardClaimed(address indexed ms_address, uint amount, bytes32 indexed reward_identifier);


    constructor(
        address _token_address,
        address _service_registry_address,
        address _udc_address,
        address _token_network_registry_address
    )
        public
    {
        require(_token_address != address(0x0), "Token at address zero");
        require(_service_registry_address != address(0x0), "ServiceRegistry at address zero");
        require(_udc_address != address(0x0), "UDC at address zero");
        require(contractExists(_token_address), "token has no code");
        require(contractExists(_service_registry_address), "ServiceRegistry has no code");
        require(contractExists(_udc_address), "UDC has no code");
        require(contractExists(_token_network_registry_address), "TokenNetworkRegistry has no code");

        token = Token(_token_address);
        service_registry = ServiceRegistry(_service_registry_address);
        user_deposit = UserDeposit(_udc_address);
        token_network_registry = TokenNetworkRegistry(_token_network_registry_address);
        require(token.totalSupply() > 0, "Token with zero total supply");
    }

    function updateReward(
        address token_network_address,
        address closing_participant,
        address non_closing_participant,
        uint256 reward_amount,
        uint256 nonce,
        address monitoring_service_address,
        bytes memory non_closing_signature,
        bytes memory reward_proof_signature
    )
        internal
    {

        TokenNetwork token_network = TokenNetwork(token_network_address);
        address token_network_token = address(token_network.token());
        require(
            token_network_registry.token_to_token_networks(token_network_token) ==
            address(token_network),
            "Unknown TokenNetwork"
        );
        uint256 channel_identifier = token_network.getChannelIdentifier(
            closing_participant, non_closing_participant
        );

        address raiden_node_address = recoverAddressFromRewardProof(
            token_network.chain_id(),
            token_network_address,
            non_closing_participant,
            non_closing_signature,
            reward_amount,
            reward_proof_signature
        );
        require(raiden_node_address == non_closing_participant, "Bad reward proof");

        bytes32 reward_identifier = keccak256(abi.encodePacked(
            channel_identifier,
            token_network_address
        ));

        Reward storage reward = rewards[reward_identifier];

        require(reward.nonce < nonce, "stale nonce");

        rewards[reward_identifier] = Reward({
            reward_amount: reward_amount,
            nonce: nonce,
            reward_sender_address: non_closing_participant,
            monitoring_service_address: monitoring_service_address
        });
    }

    function monitor(
        address closing_participant,
        address non_closing_participant,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes memory closing_signature,
        bytes memory non_closing_signature,
        uint256 reward_amount,
        address token_network_address,
        bytes memory reward_proof_signature
    )
        public
    {

        updateReward(
            token_network_address,
            closing_participant,
            non_closing_participant,
            reward_amount,
            nonce,
            msg.sender,
            non_closing_signature,
            reward_proof_signature
        );

        TokenNetwork token_network = TokenNetwork(token_network_address);
        uint256 channel_identifier = token_network.getChannelIdentifier(
            closing_participant, non_closing_participant
        );
        require(isAllowedToMonitor(
            token_network, channel_identifier,
            closing_participant, non_closing_participant, msg.sender
        ), "not allowed to monitor");

        token_network.updateNonClosingBalanceProof(
            channel_identifier,
            closing_participant,
            non_closing_participant,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature,
            non_closing_signature
        );

        emit NewBalanceProofReceived(
            token_network_address,
            channel_identifier,
            reward_amount,
            nonce,
            msg.sender,
            non_closing_participant
        );
    }

    function isAllowedToMonitor(
        TokenNetwork token_network,
        uint256 channel_identifier,
        address closing_participant,
        address non_closing_participant,
        address monitoring_service_address
    )
        internal
        returns (bool)
    {

        require(service_registry.hasValidRegistration(monitoring_service_address), "service not registered");

        TokenNetwork.ChannelState channel_state;
        uint256 settle_block_number;
        (settle_block_number, channel_state) = token_network.getChannelInfo(
            channel_identifier, closing_participant, non_closing_participant
        );
        require(channel_state == TokenNetwork.ChannelState.Closed, "channel not closed");

        uint256 assumed_settle_timeout = token_network.settlement_timeout_min();
        require(settle_block_number >= assumed_settle_timeout, "too low settle block number");
        uint256 assumed_close_block = settle_block_number - assumed_settle_timeout;

        return block.number >= firstBlockAllowedToMonitor(
            assumed_close_block,
            assumed_settle_timeout,
            closing_participant,
            non_closing_participant,
            monitoring_service_address
        );
    }

    function firstBlockAllowedToMonitor(
        uint256 closed_at_block,
        uint256 settle_timeout,
        address participant1,
        address participant2,
        address monitoring_service_address
    )
        public pure
        returns (uint256)
    {

        require(settle_timeout < uint256(2**256 - 1) / 100, "maliciously big settle timeout");
        require(closed_at_block < uint256(2**256 - 1) / 100, "maliciously big closed_at_block");

        uint256 BEST_CASE = 30;
        uint256 WORST_CASE = 80;

        uint256 best_case_block = closed_at_block + BEST_CASE * settle_timeout / 100;
        uint256 range_length = (WORST_CASE - BEST_CASE) * settle_timeout / 100;

        uint256 ms_offset = (
            uint256(participant1)
            + uint256(participant2)
            + uint256(monitoring_service_address)
        ) % range_length;

        return best_case_block + ms_offset;
    }

    function claimReward(
        uint256 channel_identifier,
        address token_network_address,
        address closing_participant,
        address non_closing_participant
    )
        public
        returns (bool)
    {

        TokenNetwork token_network = TokenNetwork(token_network_address);
        bytes32 reward_identifier = keccak256(abi.encodePacked(
            channel_identifier,
            token_network_address
        ));

        TokenNetwork.ChannelState channel_state;
        uint256 settle_block_number;
        (settle_block_number, channel_state) = token_network.getChannelInfo(
            channel_identifier,
            closing_participant,
            non_closing_participant
        );
        require(channel_state == TokenNetwork.ChannelState.Closed ||
            channel_state == TokenNetwork.ChannelState.Settled ||
            channel_state == TokenNetwork.ChannelState.Removed, "too early channel state");
        require(settle_block_number < block.number, "channel not settled yet");

        Reward storage reward = rewards[reward_identifier];

        require(reward.reward_sender_address != address(0x0), "reward_sender is zero");

        require(user_deposit.transfer(
            reward.reward_sender_address,
            reward.monitoring_service_address,
            reward.reward_amount
        ), "UDC did not transfer");

        emit RewardClaimed(
            reward.monitoring_service_address,
            reward.reward_amount,
            reward_identifier
        );

        delete rewards[reward_identifier];

        return true;
    }

    function recoverAddressFromRewardProof(
        uint256 chain_id,
        address token_network_address,
        address non_closing_participant,
        bytes memory non_closing_signature,
        uint256 reward_amount,
        bytes memory signature
    )
        internal
        view
        returns (address signature_address)
    {

        bytes32 message_hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n221",  // 20 + 32 + 32 + 20 + 20 + 65 + 32
            address(this),
            chain_id,
            uint256(MessageTypeId.MSReward),
            token_network_address,
            non_closing_participant,
            non_closing_signature,
            reward_amount
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
        require(signature_address == non_closing_participant, "Reward proof with wrong non_closing_participant");
    }
}






