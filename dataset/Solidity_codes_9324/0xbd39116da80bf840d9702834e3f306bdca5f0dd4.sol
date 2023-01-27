
pragma solidity 0.8.7;
pragma abicoder v2;


contract Utils {


    uint256 constant MAX_SAFE_UINT256 = 2**256 - 1;

    function contractExists(address contract_address) public view returns (bool) {

        uint size;

        assembly { // solium-disable-line security/no-inline-assembly
            size := extcodesize(contract_address)
        }

        return size > 0;
    }

    string public constant signature_prefix = "\x19Ethereum Signed Message:\n";

    function min(uint256 a, uint256 b) public pure returns (uint256)
    {

        return a > b ? b : a;
    }

    function max(uint256 a, uint256 b) public pure returns (uint256)
    {

        return a > b ? a : b;
    }

    function failsafe_subtract(uint256 a, uint256 b)
        public
        pure
        returns (uint256, uint256)
    {

        unchecked {
            return a > b ? (a - b, b) : (0, a);
        }
    }

    function failsafe_addition(uint256 a, uint256 b)
        public
        pure
        returns (uint256)
    {

        unchecked {
            uint256 sum = a + b;
            return sum >= a ? sum : MAX_SAFE_UINT256;
        }
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

        assembly { // solium-disable-line security/no-inline-assembly
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

library MessageType {


    enum MessageTypeId {
        None,
        BalanceProof,
        BalanceProofUpdate,
        Withdraw,
        CooperativeSettle,
        IOU,
        MSReward
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






contract Controllable {


    address public controller;

    modifier onlyController() {

        require(msg.sender == controller, "Can only be called by controller");
        _;
    }

    function changeController(address new_controller)
        external
        onlyController
    {

        controller = new_controller;
    }
}

contract TokenNetwork is Utils, Controllable {

    Token public token;

    SecretRegistry public secret_registry;

    uint256 public settlement_timeout_min;
    uint256 public settlement_timeout_max;

    uint256 public channel_participant_deposit_limit;
    uint256 public token_network_deposit_limit;

    uint256 public channel_counter;

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

    struct WithdrawInput {
        address participant;
        uint256 total_withdraw;
        uint256 expiration_block;
        bytes participant_signature;
        bytes partner_signature;
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

    struct SettleInput {
        address participant;
        uint256 transferred_amount;
        uint256 locked_amount;
        bytes32 locksroot;
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
        address participant1,
        uint256 participant1_amount,
        bytes32 participant1_locksroot,
        address participant2,
        uint256 participant2_amount,
        bytes32 participant2_locksroot
    );

    modifier isSafe() {

        require(safety_deprecation_switch == false, "TN: network is deprecated");
        _;
    }

    modifier isOpen(uint256 channel_identifier) {

        require(channels[channel_identifier].state == ChannelState.Opened, "TN: channel not open");
        _;
    }

    modifier settleTimeoutValid(uint256 timeout) {

        require(timeout >= settlement_timeout_min, "TN: settle timeout < min");
        require(timeout <= settlement_timeout_max, "TN: settle timeout > max");
        _;
    }

    constructor(
        address _token_address,
        address _secret_registry,
        uint256 _settlement_timeout_min,
        uint256 _settlement_timeout_max,
        address _controller,
        uint256 _channel_participant_deposit_limit,
        uint256 _token_network_deposit_limit
    ) {
        require(_token_address != address(0x0), "TN: invalid token address");
        require(_secret_registry != address(0x0), "TN: invalid SR address");
        require(_controller != address(0x0), "TN: invalid controller address");
        require(_settlement_timeout_min > 0, "TN: invalid settle timeout min");
        require(_settlement_timeout_max > _settlement_timeout_min, "TN: invalid settle timeouts");
        require(contractExists(_token_address), "TN: invalid token contract");
        require(contractExists(_secret_registry), "TN: invalid SR contract");
        require(_channel_participant_deposit_limit > 0, "TN: invalid participant limit");
        require(_token_network_deposit_limit > 0, "TN: invalid network deposit limit");
        require(_token_network_deposit_limit >= _channel_participant_deposit_limit, "TN: invalid deposit limits");

        token = Token(_token_address);

        secret_registry = SecretRegistry(_secret_registry);
        settlement_timeout_min = _settlement_timeout_min;
        settlement_timeout_max = _settlement_timeout_max;

        require(token.totalSupply() > 0, "TN: no supply for token");

        controller = _controller;
        channel_participant_deposit_limit = _channel_participant_deposit_limit;
        token_network_deposit_limit = _token_network_deposit_limit;
    }

    function deprecate() public isSafe onlyController {

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

        require(token.balanceOf(address(this)) < token_network_deposit_limit, "TN/open: network deposit limit reached");

        channel_counter += 1;
        channel_identifier = channel_counter;

        pair_hash = getParticipantsHash(participant1, participant2);

        require(participants_hash_to_channel_identifier[pair_hash] == 0, "TN/open: channel exists for participants");
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

    function openChannelWithDeposit(
        address participant1,
        address participant2,
        uint256 settle_timeout,
        uint256 participant1_total_deposit
    )
        public
        isSafe
        settleTimeoutValid(settle_timeout)
        returns (uint256)
    {

        uint256 channel_identifier;

        channel_identifier = openChannel(participant1, participant2, settle_timeout);
        setTotalDepositFor(
            channel_identifier,
            participant1,
            participant1_total_deposit,
            participant2,
            msg.sender
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

        setTotalDepositFor(
            channel_identifier,
            participant,
            total_deposit,
            partner,
            msg.sender
        );
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

        this.setTotalWithdraw2(
            channel_identifier,
            WithdrawInput({
                participant: participant,
                total_withdraw: total_withdraw,
                expiration_block: expiration_block,
                participant_signature: participant_signature,
                partner_signature: partner_signature
            })
        );
    }

    function setTotalWithdraw2(
        uint256 channel_identifier,
        WithdrawInput memory withdraw_data
    )
        external
        isOpen(channel_identifier)
    {

        uint256 total_deposit;
        uint256 current_withdraw;
        address partner;

        require(withdraw_data.total_withdraw > 0, "TN/withdraw: total withdraw is zero");
        require(block.number < withdraw_data.expiration_block, "TN/withdraw: expired");

        require(withdraw_data.participant == recoverAddressFromWithdrawMessage(
            channel_identifier,
            withdraw_data.participant,
            withdraw_data.total_withdraw,
            withdraw_data.expiration_block,
            withdraw_data.participant_signature
        ), "TN/withdraw: invalid participant sig");
        partner = recoverAddressFromWithdrawMessage(
            channel_identifier,
            withdraw_data.participant,
            withdraw_data.total_withdraw,
            withdraw_data.expiration_block,
            withdraw_data.partner_signature
        );

        require(
            channel_identifier == getChannelIdentifier(withdraw_data.participant, partner),
            "TN/withdraw: channel id mismatch"
        );

        Channel storage channel = channels[channel_identifier];
        Participant storage participant_state = channel.participants[withdraw_data.participant];
        Participant storage partner_state = channel.participants[partner];

        total_deposit = participant_state.deposit + partner_state.deposit;

        require(
            (withdraw_data.total_withdraw + partner_state.withdrawn_amount) <= total_deposit,
            "TN/withdraw: withdraw > deposit"
        );
        require(
            withdraw_data.total_withdraw <= (withdraw_data.total_withdraw + partner_state.withdrawn_amount),
            "TN/withdraw: overflow"
        );

        current_withdraw = withdraw_data.total_withdraw - participant_state.withdrawn_amount;
        require(current_withdraw <= withdraw_data.total_withdraw, "TN/withdraw: underflow");

        require(current_withdraw > 0, "TN/withdraw: amount is zero");

        assert(participant_state.withdrawn_amount + current_withdraw == withdraw_data.total_withdraw);

        emit ChannelWithdraw(
            channel_identifier,
            withdraw_data.participant,
            withdraw_data.total_withdraw
        );

        participant_state.withdrawn_amount = withdraw_data.total_withdraw;
        require(token.transfer(withdraw_data.participant, current_withdraw), "TN/withdraw: transfer failed");

        assert(total_deposit >= participant_state.deposit);
        assert(total_deposit >= partner_state.deposit);

        assert(participant_state.nonce == 0);
        assert(partner_state.nonce == 0);
    }

    function cooperativeSettle(
        uint256 channel_identifier,
        WithdrawInput memory data1,
        WithdrawInput memory data2
    )
        external
        isOpen(channel_identifier)
    {

        uint256 total_deposit;

        require(
            channel_identifier == getChannelIdentifier(data1.participant, data2.participant),
            "TN/coopSettle: channel id mismatch"
        );
        Channel storage channel = channels[channel_identifier];

        Participant storage participant1_state = channel.participants[data1.participant];
        Participant storage participant2_state = channel.participants[data2.participant];
        total_deposit = participant1_state.deposit + participant2_state.deposit;

        require((data1.total_withdraw + data2.total_withdraw) == total_deposit, "TN/coopSettle: incomplete amounts");
        require(data1.total_withdraw <= data1.total_withdraw + data2.total_withdraw, "TN/coopSettle: overflow");

        if (data1.total_withdraw > 0) {
            this.setTotalWithdraw2(
                channel_identifier,
                data1
            );
        }
        if (data2.total_withdraw > 0) {
            this.setTotalWithdraw2(
                channel_identifier,
                data2
            );
        }
        removeChannelData(channel, channel_identifier, data1.participant, data2.participant);

        emit ChannelSettled(
            channel_identifier,
            data1.participant,
            data1.total_withdraw,
            0,
            data2.participant,
            data2.total_withdraw,
            0
        );
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

        require(
            channel_identifier == getChannelIdentifier(closing_participant, non_closing_participant),
            "TN/close: channel id mismatch"
        );

        address recovered_non_closing_participant_address;

        Channel storage channel = channels[channel_identifier];

        channel.state = ChannelState.Closed;
        channel.participants[closing_participant].is_the_closer = true;

        channel.settle_block_number += uint256(block.number);

        address recovered_closing_participant_address = recoverAddressFromBalanceProofCounterSignature(
            MessageType.MessageTypeId.BalanceProof,
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            non_closing_signature,
            closing_signature
        );
        require(closing_participant == recovered_closing_participant_address, "TN/close: invalid closing sig");

        if (nonce > 0) {
            recovered_non_closing_participant_address = recoverAddressFromBalanceProof(
                channel_identifier,
                balance_hash,
                nonce,
                additional_hash,
                non_closing_signature
            );
            require(
                non_closing_participant == recovered_non_closing_participant_address,
                "TN/close: invalid non-closing sig"
            );

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

        require(
            channel_identifier == getChannelIdentifier(closing_participant,non_closing_participant),
             "TN/update: channel id mismatch"
        );
        require(balance_hash != bytes32(0x0), "TN/update: balance hash is zero");
        require(nonce > 0, "TN/update: nonce is zero");

        address recovered_non_closing_participant;
        address recovered_closing_participant;

        Channel storage channel = channels[channel_identifier];

        require(channel.state == ChannelState.Closed, "TN/update: channel not closed");

        recovered_non_closing_participant = recoverAddressFromBalanceProofCounterSignature(
            MessageType.MessageTypeId.BalanceProofUpdate,
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature,
            non_closing_signature
        );
        require(non_closing_participant == recovered_non_closing_participant, "TN/update: invalid non-closing sig");

        recovered_closing_participant = recoverAddressFromBalanceProof(
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature
        );
        require(closing_participant == recovered_closing_participant, "TN/update: invalid closing sig");

        Participant storage closing_participant_state = channel.participants[closing_participant];
        require(closing_participant_state.is_the_closer, "TN/update: incorrect signature order");

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

        settleChannel2(
            channel_identifier,
            SettleInput({
                participant: participant1,
                transferred_amount: participant1_transferred_amount,
                locked_amount: participant1_locked_amount,
                locksroot: participant1_locksroot
            }),
            SettleInput({
                participant: participant2,
                transferred_amount: participant2_transferred_amount,
                locked_amount: participant2_locked_amount,
                locksroot: participant2_locksroot
            })
        );
    }

    function settleChannel2(
        uint256 channel_identifier,
        SettleInput memory participant1_settlement,
        SettleInput memory participant2_settlement
    )
        public
    {


        address participant1 = participant1_settlement.participant;
        address participant2 = participant2_settlement.participant;
        require(
            channel_identifier == getChannelIdentifier(participant1, participant2),
            "TN/settle: channel id mismatch"
        );

        Channel storage channel = channels[channel_identifier];

        require(channel.state == ChannelState.Closed, "TN/settle: channel not closed");

        require(channel.settle_block_number < block.number, "TN/settle: settlement timeout");

        Participant storage participant1_state = channel.participants[participant1];
        Participant storage participant2_state = channel.participants[participant2];

        require(
            verifyBalanceHashData(participant1_state, participant1_settlement),
            "TN/settle: invalid data for participant 1"
        );

        require(
            verifyBalanceHashData(participant2_state, participant2_settlement),
            "TN/settle: invalid data for participant 2"
        );

        (
            participant1_settlement.transferred_amount,
            participant2_settlement.transferred_amount,
            participant1_settlement.locked_amount,
            participant2_settlement.locked_amount
        ) = getSettleTransferAmounts(
            participant1_state,
            participant1_settlement.transferred_amount,
            participant1_settlement.locked_amount,
            participant2_state,
            participant2_settlement.transferred_amount,
            participant2_settlement.locked_amount
        );

        removeChannelData(channel, channel_identifier, participant1, participant2);

        storeUnlockData(
            channel_identifier,
            participant1_settlement,
            participant2
        );
        storeUnlockData(
            channel_identifier,
            participant2_settlement,
            participant1
        );

        emit ChannelSettled(
            channel_identifier,
            participant1,
            participant1_settlement.transferred_amount,
            participant1_settlement.locksroot,
            participant2,
            participant2_settlement.transferred_amount,
            participant2_settlement.locksroot
        );

        if (participant1_settlement.transferred_amount > 0) {
            require(
                token.transfer(participant1, participant1_settlement.transferred_amount),
                "TN/settle: transfer for participant 1 failed"
            );
        }

        if (participant2_settlement.transferred_amount > 0) {
            require(
                token.transfer(participant2, participant2_settlement.transferred_amount),
                "TN/settle: transfer for participant 2 failed"
            );
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

        require(
            channel_identifier != getChannelIdentifier(receiver, sender),
            "TN/unlock: channel id still exists"
        );

        require(
            channels[channel_identifier].state == ChannelState.NonExistent,
            "TN/unlock: channel not settled"
        );

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

        require(unlock_data.locksroot == computed_locksroot, "TN/unlock: locksroot mismatch");

        require(locked_amount > 0, "TN/unlock: zero locked amount");

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
            require(token.transfer(receiver, unlocked_amount), "TN/unlock: unlocked transfer failed");
        }

        if (returned_tokens > 0) {
            require(token.transfer(sender, returned_tokens), "TN/unlock: returned transfer failed");
        }

        assert(locked_amount >= returned_tokens);
        assert(locked_amount >= unlocked_amount);
    }

    function getChannelIdentifier(address participant, address partner)
        public
        view
        returns (uint256)
    {

        require(participant != address(0x0), "TN: participant address zero");
        require(partner != address(0x0), "TN: partner address zero");
        require(participant != partner, "TN: identical addresses");

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

        require(participant != address(0x0), "TN: participant address zero");
        require(partner != address(0x0), "TN: partner address zero");
        require(participant != partner, "TN: identical addresses");

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

        require(sender != receiver, "TN: sender/receiver mismatch");
        return keccak256(abi.encodePacked(channel_identifier, sender, receiver));
    }

    function setTotalDepositFor(
        uint256 channel_identifier,
        address participant,
        uint256 total_deposit,
        address partner,
        address token_owner
    )
        internal
    {

        require(channel_identifier == getChannelIdentifier(participant, partner), "TN/deposit: channel id mismatch");
        require(total_deposit > 0, "TN/deposit: total_deposit is zero");
        require(total_deposit <= channel_participant_deposit_limit, "TN/deposit: deposit limit reached");

        uint256 added_deposit;
        uint256 channel_deposit;

        Channel storage channel = channels[channel_identifier];
        Participant storage participant_state = channel.participants[participant];
        Participant storage partner_state = channel.participants[partner];

        unchecked {
            added_deposit = total_deposit - participant_state.deposit;

            require(added_deposit > 0, "TN/deposit: no deposit added");

            require(added_deposit <= total_deposit, "TN/deposit: deposit underflow");

            assert(participant_state.deposit + added_deposit == total_deposit);

            require(
                token.balanceOf(address(this)) + added_deposit <= token_network_deposit_limit,
                "TN/deposit: network limit reached"
            );

            participant_state.deposit = total_deposit;

            channel_deposit = participant_state.deposit + partner_state.deposit;
            require(channel_deposit >= participant_state.deposit, "TN/deposit: deposit overflow");
        }

        emit ChannelNewDeposit(
            channel_identifier,
            participant,
            participant_state.deposit
        );

        require(token.transferFrom(token_owner, address(this), added_deposit), "TN/deposit: transfer failed");
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

        require(nonce > participant_state.nonce, "TN: nonce reused");

        participant_state.nonce = nonce;
        participant_state.balance_hash = balance_hash;
    }

    function storeUnlockData(
        uint256 channel_identifier,
        SettleInput memory settle_input,
        address receiver
    )
        internal
    {

        if (settle_input.locked_amount == 0) {
            return;
        }

        bytes32 key = getUnlockIdentifier(channel_identifier, settle_input.participant, receiver);
        UnlockData storage unlock_data = unlock_identifier_to_unlock_data[key];
        unlock_data.locksroot = settle_input.locksroot;
        unlock_data.locked_amount = settle_input.locked_amount;
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
            participant1_settlement.deposit,
            participant1_settlement.withdrawn,
            participant1_settlement.transferred,
            participant1_settlement.locked,
            participant2_settlement.transferred,
            participant2_settlement.locked
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

    function verifyBalanceHashData(
        Participant storage participant,
        SettleInput memory settle_input
    )
        internal
        view
        returns (bool)
    {

        if (participant.balance_hash == 0 &&
            settle_input.transferred_amount == 0 &&
            settle_input.locked_amount == 0
        ) {
            return true;
        }

        return participant.balance_hash == keccak256(abi.encodePacked(
            settle_input.transferred_amount,
            settle_input.locked_amount,
            settle_input.locksroot
        ));
    }

    function getHashAndUnlockedAmount(bytes memory locks)
        internal
        view
        returns (bytes32, uint256)
    {

        uint256 length = locks.length;

        require(length % 96 == 0, "TN: invalid locks size");

        uint256 i;
        uint256 total_unlocked_amount;
        uint256 unlocked_amount;
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

        assembly { // solium-disable-line security/no-inline-assembly
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

    function removeChannelData(Channel storage channel, uint256 channel_identifier, address participant1, address participant2)
        internal
    {

        bytes32 pair_hash;

        delete channel.participants[participant1];
        delete channel.participants[participant2];
        delete channels[channel_identifier];

        pair_hash = getParticipantsHash(participant1, participant2);
        delete participants_hash_to_channel_identifier[pair_hash];
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

        string memory message_length = "212";

        bytes32 message_hash = keccak256(abi.encodePacked(
            signature_prefix,
            message_length,
            address(this),
            block.chainid,
            uint256(MessageType.MessageTypeId.BalanceProof),
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function recoverAddressFromBalanceProofCounterSignature(
        MessageType.MessageTypeId message_type_id,
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

        string memory message_prefix = "\x19Ethereum Signed Message:\n277";

        bytes32 message_hash = keccak256(abi.encodePacked(
            message_prefix,
            address(this),
            block.chainid,
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

        string memory message_length = "200";

        bytes32 message_hash = keccak256(abi.encodePacked(
            signature_prefix,
            message_length,
            address(this),
            block.chainid,
            uint256(MessageType.MessageTypeId.Withdraw),
            channel_identifier,
            participant,
            total_withdraw,
            expiration_block
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function getMaxPossibleReceivableAmount(
        uint256 participant1_deposit,
        uint256 participant1_withdrawn,
        uint256 participant1_transferred,
        uint256 participant1_locked,
        uint256 participant2_transferred,
        uint256 participant2_locked
    )
        public
        pure
        returns (uint256)
    {

        uint256 participant1_max_transferred;
        uint256 participant2_max_transferred;
        uint256 participant1_net_max_received;
        uint256 participant1_max_amount;

        participant1_max_transferred = failsafe_addition(
            participant1_transferred,
            participant1_locked
        );

        participant2_max_transferred = failsafe_addition(
            participant2_transferred,
            participant2_locked
        );

        require(participant2_max_transferred >= participant1_max_transferred, "TN: transfers not ordered");

        assert(participant1_max_transferred >= participant1_transferred);
        assert(participant2_max_transferred >= participant2_transferred);

        participant1_net_max_received = (
            participant2_max_transferred -
            participant1_max_transferred
        );

        participant1_max_amount = failsafe_addition(
            participant1_net_max_received,
            participant1_deposit
        );

        (participant1_max_amount, ) = failsafe_subtract(
            participant1_max_amount,
            participant1_withdrawn
        );
        return participant1_max_amount;
    }

    function removeLimits()
        external
        onlyController
    {

        channel_participant_deposit_limit = MAX_SAFE_UINT256;
        token_network_deposit_limit = MAX_SAFE_UINT256;
    }

    function chain_id()
        external
        returns (uint256)
    {

        return block.chainid;
    }
}

contract TokenNetworkRegistry is Utils, Controllable {

    address public secret_registry_address;
    uint256 public settlement_timeout_min;
    uint256 public settlement_timeout_max;
    uint256 public max_token_networks;

    uint256 public token_network_created = 0;

    mapping(address => address) public token_to_token_networks;

    event TokenNetworkCreated(address indexed token_address, address indexed token_network_address);

    modifier canCreateTokenNetwork() {

        require(token_network_created < max_token_networks, "TNR: registry full");
        _;
    }

    constructor(
        address _secret_registry_address,
        uint256 _settlement_timeout_min,
        uint256 _settlement_timeout_max,
        uint256 _max_token_networks
    ) {
        require(_settlement_timeout_min > 0, "TNR: invalid settle timeout min");
        require(_settlement_timeout_max > 0, "TNR: invalid settle timeout max");
        require(_settlement_timeout_max > _settlement_timeout_min, "TNR: invalid settle timeouts");
        require(_secret_registry_address != address(0x0), "TNR: invalid SR address");
        require(contractExists(_secret_registry_address), "TNR: invalid SR");
        require(_max_token_networks > 0, "TNR: invalid TN limit");
        secret_registry_address = _secret_registry_address;
        settlement_timeout_min = _settlement_timeout_min;
        settlement_timeout_max = _settlement_timeout_max;
        max_token_networks = _max_token_networks;

        controller = msg.sender;
    }

    function createERC20TokenNetwork(
        address _token_address,
        uint256 _channel_participant_deposit_limit,
        uint256 _token_network_deposit_limit
    )
        public
        canCreateTokenNetwork
        returns (address token_network_address)
    {

        if (max_token_networks == MAX_SAFE_UINT256) {
            require(_channel_participant_deposit_limit == MAX_SAFE_UINT256, "TNR: limits must be set to MAX_INT");
            require(_token_network_deposit_limit == MAX_SAFE_UINT256, "TNR: limits must be set to MAX_INT");
        }

        require(token_to_token_networks[_token_address] == address(0x0), "TNR: token already registered");

        token_network_created = token_network_created + 1;

        TokenNetwork token_network;

        token_network = new TokenNetwork(
            _token_address,
            secret_registry_address,
            settlement_timeout_min,
            settlement_timeout_max,
            controller,
            _channel_participant_deposit_limit,
            _token_network_deposit_limit
        );

        token_network_address = address(token_network);

        token_to_token_networks[_token_address] = token_network_address;
        emit TokenNetworkCreated(_token_address, token_network_address);

        return token_network_address;
    }

    function createERC20TokenNetworkWithoutLimits(
        address _token_address
    )
        external
        returns (address token_network_address)
    {

        return createERC20TokenNetwork(_token_address, MAX_SAFE_UINT256, MAX_SAFE_UINT256);
    }

    function removeLimits()
        external
        onlyController
    {

        max_token_networks = MAX_SAFE_UINT256;
    }
}





