
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.8.10;


interface IOwnership {

    function owner() external view returns (address);


    function futureOwner() external view returns (address);


    function commitTransferOwnership(address newOwner) external;


    function acceptTransferOwnership() external;

}pragma solidity 0.8.10;



contract InsureToken is IERC20 {

    event UpdateMiningParameters(
        uint256 time,
        uint256 rate,
        uint256 supply,
        int256 miningepoch
    );
    event SetMinter(address minter);
    event SetAdmin(address admin);
    event SetRate(uint256 rate);

    string public name;
    string public symbol;
    uint256 public constant decimals = 18;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 public total_supply;

    address public minter;
    IOwnership public immutable ownership;

    uint256 constant YEAR = 86400 * 365;


    uint256 constant INITIAL_SUPPLY = 126_000_000; //will be vested
    uint256 constant RATE_REDUCTION_TIME = YEAR;
    uint256[6] public RATES = [
        (28_000_000 * 10 ** 18) / YEAR, //epoch 0
        (22_400_000 * 10 ** 18) / YEAR, //epoch 1
        (16_800_000 * 10 ** 18) / YEAR, //epoch 2
        (11_200_000 * 10 ** 18) / YEAR, //epoch 3
        (5_600_000 * 10 ** 18) / YEAR, //epoch 4
        (2_800_000 * 10 ** 18) / YEAR //epoch 5~
    ];

    uint256 constant RATE_DENOMINATOR = 10 ** 18;
    uint256 constant INFLATION_DELAY = 86400;

    int256 public mining_epoch;
    uint256 public start_epoch_time;
    uint256 public rate;

    uint256 public start_epoch_supply;

    uint256 public emergency_minted;

    modifier onlyOwner() {

        require(
            ownership.owner() == msg.sender,
            "Caller is not allowed to operate"
        );
        _;
    }


    constructor(string memory _name, string memory _symbol, address _ownership) {
        uint256 _init_supply = INITIAL_SUPPLY * RATE_DENOMINATOR;
        name = _name;
        symbol = _symbol;
        balanceOf[msg.sender] = _init_supply;
        total_supply = _init_supply;
        ownership = IOwnership(_ownership);
        emit Transfer(address(0), msg.sender, _init_supply);

        unchecked {
            start_epoch_time =
                block.timestamp +
                INFLATION_DELAY -
                RATE_REDUCTION_TIME;
            mining_epoch = -1;
        }
        rate = 0;
        start_epoch_supply = _init_supply;
    }

    function _update_mining_parameters() internal {

        uint256 _rate = rate;
        uint256 _start_epoch_supply = start_epoch_supply;

        start_epoch_time += RATE_REDUCTION_TIME;
        unchecked {
            mining_epoch += 1;
        }

        if (mining_epoch == 0) {
            _rate = RATES[uint256(mining_epoch)];
        } else if (mining_epoch < int256(6)) {
            _start_epoch_supply += RATES[uint256(mining_epoch) - 1] * YEAR;
            start_epoch_supply = _start_epoch_supply;
            _rate = RATES[uint256(mining_epoch)];
        } else {
            _start_epoch_supply += RATES[5] * YEAR;
            start_epoch_supply = _start_epoch_supply;
            _rate = RATES[5];
        }
        rate = _rate;
        emit UpdateMiningParameters(
            block.timestamp,
            _rate,
            _start_epoch_supply,
            mining_epoch
        );
    }

    function update_mining_parameters() external {

        require(
            block.timestamp >= start_epoch_time + RATE_REDUCTION_TIME,
            "dev: too soon!"
        );
        _update_mining_parameters();
    }

    function start_epoch_time_write() external returns(uint256) {


        uint256 _start_epoch_time = start_epoch_time;
        if (block.timestamp >= _start_epoch_time + RATE_REDUCTION_TIME) {
            _update_mining_parameters();
            return start_epoch_time;
        } else {
            return _start_epoch_time;
        }
    }

    function future_epoch_time_write() external returns(uint256) {

        uint256 _start_epoch_time = start_epoch_time;
        if (block.timestamp >= _start_epoch_time + RATE_REDUCTION_TIME) {
            _update_mining_parameters();
            return start_epoch_time + RATE_REDUCTION_TIME;
        } else {
            return _start_epoch_time + RATE_REDUCTION_TIME;
        }
    }

    function _available_supply() internal view returns(uint256) {

        return
        start_epoch_supply +
            ((block.timestamp - start_epoch_time) * rate) +
            emergency_minted;
    }

    function available_supply() external view returns(uint256) {

        return _available_supply();
    }

    function mintable_in_timeframe(uint256 start, uint256 end)
    external
    view
    returns(uint256) {

        require(start <= end, "dev: start > end");
        uint256 _to_mint = 0;

        uint256 _current_epoch_time = start_epoch_time;
        uint256 _current_rate = rate;
        int256 _current_epoch = mining_epoch;

        if (end > _current_epoch_time + RATE_REDUCTION_TIME) {

            _current_epoch_time += RATE_REDUCTION_TIME;
            if (_current_epoch < 5) {
                _current_epoch += 1;
                _current_rate = RATES[uint256(_current_epoch)];
            } else {
                _current_epoch += 1;
                _current_rate = RATES[5];
            }
        }

        require(
            end <= _current_epoch_time + RATE_REDUCTION_TIME,
            "dev: too far in future"
        );

        for (uint256 i; i < 999;) {
            if (end >= _current_epoch_time) {
                uint256 current_end = end;
                if (current_end > _current_epoch_time + RATE_REDUCTION_TIME) {
                    current_end = _current_epoch_time + RATE_REDUCTION_TIME;
                }
                uint256 current_start = start;
                if (
                    current_start >= _current_epoch_time + RATE_REDUCTION_TIME
                ) {
                    break; // We should never get here but what if...
                } else if (current_start < _current_epoch_time) {
                    current_start = _current_epoch_time;
                }
                _to_mint += (_current_rate * (current_end - current_start));

                if (start >= _current_epoch_time) {
                    break;
                }
            }

            _current_epoch_time -= RATE_REDUCTION_TIME;

            if (_current_epoch == 0) {
                _current_rate = 0;
            } else {
                _current_rate = _current_epoch < 5 ? RATES[uint256(_current_epoch) - 1] : RATES[5];
            }

            _current_epoch -= 1;

            assert(_current_rate <= RATES[0]); // This should never happen
            unchecked {
                ++i;
            }
        }
        return _to_mint;
    }

    function totalSupply() external view override returns(uint256) {

        return total_supply;
    }

    function allowance(address _owner, address _spender)
    external
    view
    override
    returns(uint256) {

        return allowances[_owner][_spender];
    }

    function transfer(address _to, uint256 _value)
    external
    override
    returns(bool) {

        require(_to != address(0), "transfers to 0x0 are not allowed");
        uint256 _fromBalance = balanceOf[msg.sender];
        require(_fromBalance >= _value, "transfer amount exceeds balance");
        unchecked {
            balanceOf[msg.sender] = _fromBalance - _value;
        }
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns(bool) {

        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");

        uint256 currentAllowance = allowances[_from][msg.sender];
        require(currentAllowance >= _value, "transfer amount exceeds allow");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }

        uint256 _fromBalance = balanceOf[_from];
        require(_fromBalance >= _value, "transfer amount exceeds balance");
        unchecked {
            balanceOf[_from] -= _value;
        }
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address _spender, uint256 _value)
    external
    override
    returns(bool) {

        _approve(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 addedValue)
    external
    returns(bool) {

        _approve(
            msg.sender,
            _spender,
            allowances[msg.sender][_spender] + addedValue
        );

        return true;
    }

    function decreaseAllowance(address _spender, uint256 subtractedValue)
    external
    returns(bool) {

        uint256 currentAllowance = allowances[msg.sender][_spender];
        require(
            currentAllowance >= subtractedValue,
            "decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, _spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(address _to, uint256 _value) external returns(bool) {

        require(msg.sender == minter, "dev: minter only");
        require(_to != address(0), "dev: zero address");

        _mint(_to, _value);

        return true;
    }

    function _mint(address _to, uint256 _value) internal {

        uint256 _total_supply = total_supply + _value;

        require(
            _total_supply <= _available_supply(),
            "exceeds allowable mint amount"
        );
        if (block.timestamp >= start_epoch_time + RATE_REDUCTION_TIME) {
            _update_mining_parameters();
        }
        total_supply = _total_supply;

        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }

    function burn(uint256 _value) external returns(bool) {

        require(
            balanceOf[msg.sender] >= _value,
            "_value > balanceOf[msg.sender]"
        );

        unchecked {
            balanceOf[msg.sender] -= _value;
        }
        total_supply -= _value;

        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function set_name(string memory _name, string memory _symbol) external onlyOwner {

        name = _name;
        symbol = _symbol;
    }

    function set_minter(address _minter) external onlyOwner {

        require(
            minter == address(0),
            "can set the minter at creation"
        );
        minter = _minter;
        emit SetMinter(_minter);
    }

    function set_rate(uint256 _rate) external onlyOwner {

        require(_rate < RATES[5], "Decrease Only");

        RATES[5] = _rate;

        emit SetRate(_rate);
    }

    function emergency_mint(uint256 _amount, address _to)
    external
    returns(bool) {

        require(msg.sender == minter, "dev: minter only");
        emergency_minted += _amount;
        _mint(_to, _amount);

        return true;
    }
}