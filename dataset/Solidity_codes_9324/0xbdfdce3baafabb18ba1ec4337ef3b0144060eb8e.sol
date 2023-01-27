
pragma solidity 0.8.7;
pragma abicoder v2;


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

contract ServiceRegistryConfigurableParameters is Controllable {


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
        set_price_at = block.timestamp;
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

        require(block.timestamp >= set_price_at, "An underflow in price computation");
        uint256 seconds_passed = block.timestamp - set_price_at;

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

    constructor(
        Token _token,
        uint256 _release_at,
        address _withdrawer,
        ServiceRegistryConfigurableParameters _service_registry
    ) {
        token = _token;
        release_at = _release_at;
        withdrawer = _withdrawer;
        service_registry = _service_registry;
    }


    function withdraw(address payable _to) external {

        uint256 balance = token.balanceOf(address(this));
        require(msg.sender == withdrawer, "the caller is not the withdrawer");
        require(block.timestamp >= release_at || service_registry.deprecated(), "deposit not released yet");
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
            Token _token_for_registration,
            address _controller,
            uint256 _initial_price,
            uint256 _price_bump_numerator,
            uint256 _price_bump_denominator,
            uint256 _decay_constant,
            uint256 _min_price,
            uint256 _registration_duration
    ) {
        require(address(_token_for_registration) != address(0x0), "token at address zero");
        require(contractExists(address(_token_for_registration)), "token has no code");
        require(_initial_price >= min_price, "initial price too low");
        require(_initial_price <= 2 ** 90, "intiial price too high");

        token = _token_for_registration;
        require(token.totalSupply() > 0, "total supply zero");
        controller = _controller;

        set_price = _initial_price;
        set_price_at = block.timestamp;

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
        if (valid_till < block.timestamp) { // a first time joiner or an expired service.
            valid_till = block.timestamp;
        }
        unchecked {
            require(valid_till < valid_till + registration_duration, "overflow during extending the registration");
        }
        valid_till = valid_till + registration_duration;
        assert(valid_till > service_valid_till[msg.sender]);
        service_valid_till[msg.sender] = valid_till;

        set_price = amount * price_bump_numerator / price_bump_denominator;
        if (set_price > 2 ** 90) {
            set_price = 2 ** 90; // Preventing overflows.
        }
        set_price_at = block.timestamp;

        assert(block.timestamp < valid_till);
        Deposit depo = new Deposit(token, valid_till, msg.sender, this);
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

        return block.timestamp < service_valid_till[_address];
    }
}






