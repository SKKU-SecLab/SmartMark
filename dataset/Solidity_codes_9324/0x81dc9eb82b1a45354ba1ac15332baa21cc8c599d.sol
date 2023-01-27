
pragma solidity 0.6.4;


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

contract OneToN is Utils {

    UserDeposit public deposit_contract;
    ServiceRegistry public service_registry_contract;

    uint256 public chain_id;

    mapping (bytes32 => uint256) public settled_sessions;


    event Claimed(
        address sender,
        address indexed receiver,
        uint256 expiration_block,
        uint256 transferred
    );


    constructor(
        address _deposit_contract,
        uint256 _chain_id,
        address _service_registry_contract
    )
        public
    {
        deposit_contract = UserDeposit(_deposit_contract);
        chain_id = _chain_id;
        service_registry_contract = ServiceRegistry(_service_registry_contract);
    }

    function claim(
        address sender,
        address receiver,
        uint256 amount,
        uint256 expiration_block,
        address one_to_n_address,
        bytes memory signature
    )
        public
        returns (uint)
    {

        require(service_registry_contract.hasValidRegistration(receiver), "receiver not registered");
        require(block.number <= expiration_block, "IOU expired");

        address addressFromSignature = recoverAddressFromSignature(
            sender,
            receiver,
            amount,
            expiration_block,
            chain_id,
            signature
        );
        require(addressFromSignature == sender, "Signature mismatch");

        bytes32 _key = keccak256(abi.encodePacked(receiver, sender, expiration_block));
        require(settled_sessions[_key] == 0, "Already settled session");

        uint256 transferable = min(amount, deposit_contract.balances(sender));
        if (transferable > 0) {
            settled_sessions[_key] = expiration_block;
            assert(expiration_block > 0);
            emit Claimed(sender, receiver, expiration_block, transferable);

            require(deposit_contract.transfer(sender, receiver, transferable), "deposit did not transfer");
        }
        return transferable;
    }

    function bulkClaim(
        address[] calldata senders,
        address[] calldata receivers,
        uint256[] calldata amounts,
        uint256[] calldata expiration_blocks,
        address one_to_n_address,
        bytes calldata signatures
    )
        external
        returns (uint)
    {

        uint256 transferable = 0;
        require(
            senders.length == receivers.length &&
            senders.length == amounts.length &&
            senders.length == expiration_blocks.length,
            "Same number of elements required for all input parameters"
        );
        require(
            signatures.length == senders.length * 65,
            "`signatures` should contain 65 bytes per IOU"
        );
        for (uint256 i = 0; i < senders.length; i++) {
            transferable += claim(
                senders[i],
                receivers[i],
                amounts[i],
                expiration_blocks[i],
                one_to_n_address,
                getSingleSignature(signatures, i)
            );
        }
        return transferable;
    }


    function getSingleSignature(
        bytes memory signatures,
        uint256 i
    )
        internal
        pure
        returns (bytes memory)
    {

        assert(i < signatures.length);
        uint256 offset = i * 65;
        bytes memory signature = new bytes(96);
        assembly { // solium-disable-line security/no-inline-assembly
            mstore(add(signature, 32), mload(add(add(signatures, 32), offset)))
            mstore(add(signature, 64), mload(add(add(signatures, 64), offset)))
            mstore(add(signature, 96), mload(add(add(signatures, 96), offset)))

            mstore(signature, 65)
        }
        return signature;
    }

    function recoverAddressFromSignature(
        address sender,
        address receiver,
        uint256 amount,
        uint256 expiration_block,
        uint256 chain_id,
        bytes memory signature
    )
        internal
        view
        returns (address signature_address)
    {

        bytes32 message_hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n188",
            address(this),
            chain_id,
            uint256(MessageTypeId.IOU),
            sender,
            receiver,
            amount,
            expiration_block
        ));
        return ECVerify.ecverify(message_hash, signature);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256)
    {

        return a > b ? b : a;
    }

}






