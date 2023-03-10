

pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.0;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


pragma solidity ^0.5.0;

contract ILighthouse {

    event Online(address indexed provider);

    event Offline(address indexed provider);

    event Current(address indexed provider, uint256 indexed quota);

    address[] public providers;

    function providersLength() public view returns (uint256)
    { return providers.length; }


    mapping(address => uint256) public stakes;

    uint256 public minimalStake;

    uint256 public timeoutInBlocks;

    uint256 public keepAliveBlock;

    uint256 public marker;

    uint256 public quota;

    function quotaOf(address _provider) public view returns (uint256)
    { return stakes[_provider] / minimalStake; }


    function refill(uint256 _value) external returns (bool);


    function withdraw(uint256 _value) external returns (bool);


    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    ) external returns (bool);


    function finalizeLiability(
        address _liability,
        bytes calldata _result,
        bool _success,
        bytes calldata _signature
    ) external returns (bool);

}


pragma solidity ^0.5.0;

contract ILiability {

    event Finalized(bool indexed success, bytes result);

    bytes public model;

    bytes public objective;

    bytes public result;

    address public token;

    uint256 public cost;

    uint256 public lighthouseFee;

    uint256 public validatorFee;

    bytes32 public demandHash;

    bytes32 public offerHash;

    address public promisor;

    address public promisee;

    address public lighthouse;

    address public validator;

    bool public isSuccess;

    bool public isFinalized;

    function demand(
        bytes   calldata _model,
        bytes   calldata _objective,

        address _token,
        uint256 _cost,

        address _lighthouse,

        address _validator,
        uint256 _validator_fee,

        uint256 _deadline,
        address _sender,
        bytes   calldata _signature
    ) external returns (bool);


    function offer(
        bytes   calldata _model,
        bytes   calldata _objective,
        
        address _token,
        uint256 _cost,

        address _validator,

        address _lighthouse,
        uint256 _lighthouse_fee,

        uint256 _deadline,
        address _sender,
        bytes   calldata _signature
    ) external returns (bool);


    function finalize(
        bytes calldata _result,
        bool  _success,
        bytes calldata _signature
    ) external returns (bool);

}


pragma solidity ^0.5.0;



contract IFactory {

    event NewLiability(address indexed liability);

    event NewLighthouse(address indexed lighthouse, string name);

    mapping(address => bool) public isLighthouse;

    mapping(address => uint256) public nonceOf;

    uint256 public totalGasConsumed = 0;

    mapping(address => uint256) public gasConsumedOf;

    uint256 public constant gasEpoch = 347 * 10**10;

    uint256 public gasPrice = 10 * 10**9;

    function wnFromGas(uint256 _gas) public view returns (uint256);


    function createLighthouse(
        uint256 _minimalStake,
        uint256 _timeoutInBlocks,
        string calldata _name
    ) external returns (ILighthouse);


    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    ) external returns (ILiability);


    function liabilityCreated(ILiability _liability, uint256 _start_gas) external returns (bool);


    function liabilityFinalized(ILiability _liability, uint256 _start_gas) external returns (bool);

}


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;


contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }
}


pragma solidity ^0.5.0;


contract ERC20Burnable is ERC20 {

    function burn(uint256 value) public {

        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);
    }
}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity ^0.5.0;




contract XRT is ERC20Mintable, ERC20Burnable, ERC20Detailed {

    constructor(uint256 _initial_supply) public ERC20Detailed("Robonomics", "XRT", 9) {
        _mint(msg.sender, _initial_supply);
    }
}


pragma solidity ^0.5.0;





contract Lighthouse is ILighthouse {

    using SafeERC20 for XRT;

    IFactory public factory;
    XRT      public xrt;

    function setup(XRT _xrt, uint256 _minimalStake, uint256 _timeoutInBlocks) external returns (bool) {

        require(factory == IFactory(0) && _minimalStake > 0 && _timeoutInBlocks > 0);

        minimalStake    = _minimalStake;
        timeoutInBlocks = _timeoutInBlocks;
        factory         = IFactory(msg.sender);
        xrt             = _xrt;

        return true;
    }

    mapping(address => uint256) public indexOf;

    function refill(uint256 _value) external returns (bool) {

        xrt.safeTransferFrom(msg.sender, address(this), _value);

        if (stakes[msg.sender] == 0) {
            require(_value >= minimalStake);
            providers.push(msg.sender);
            indexOf[msg.sender] = providers.length;
            emit Online(msg.sender);
        }

        stakes[msg.sender] += _value;
        return true;
    }

    function withdraw(uint256 _value) external returns (bool) {

        require(stakes[msg.sender] >= _value);

        stakes[msg.sender] -= _value;
        xrt.safeTransfer(msg.sender, _value);

        if (quotaOf(msg.sender) == 0) {
            uint256 balance = stakes[msg.sender];
            stakes[msg.sender] = 0;
            xrt.safeTransfer(msg.sender, balance);
            
            uint256 senderIndex = indexOf[msg.sender] - 1;
            uint256 lastIndex = providers.length - 1;
            if (senderIndex < lastIndex)
                providers[senderIndex] = providers[lastIndex];

            providers.length -= 1;
            indexOf[msg.sender] = 0;

            emit Offline(msg.sender);
        }
        return true;
    }

    function keepAliveTransaction() internal {

        if (timeoutInBlocks < block.number - keepAliveBlock) {
            marker = indexOf[msg.sender];

            require(marker > 0 && marker <= providers.length);

            quota = quotaOf(providers[marker - 1]);

            emit Current(providers[marker - 1], quota);
        }

        keepAliveBlock = block.number;
    }

    function quotedTransaction() internal {

        require(providers.length > 0);

        require(quota > 0);

        require(msg.sender == providers[marker - 1]);

        if (quota > 1) {
            quota -= 1;
        } else {
            marker = marker % providers.length + 1;

            quota = quotaOf(providers[marker - 1]);

            emit Current(providers[marker - 1], quota);
        }
    }

    function startGas() internal view returns (uint256 gas) {

        gas = gasleft();
        gas += 21000;
        for (uint256 i = 0; i < msg.data.length; ++i)
            gas += msg.data[i] == 0 ? 4 : 68;
    }

    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    )
        external
        returns (bool)
    {

        uint256 gas = startGas() + 4887;

        keepAliveTransaction();
        quotedTransaction();

        ILiability liability = factory.createLiability(_demand, _offer);
        require(liability != ILiability(0));
        require(factory.liabilityCreated(liability, gas - gasleft()));
        return true;
    }

    function finalizeLiability(
        address _liability,
        bytes calldata _result,
        bool _success,
        bytes calldata _signature
    )
        external
        returns (bool)
    {

        uint256 gas = startGas() + 22335;

        keepAliveTransaction();
        quotedTransaction();

        ILiability liability = ILiability(_liability);
        require(factory.gasConsumedOf(_liability) > 0);
        require(liability.finalize(_result, _success, _signature));
        require(factory.liabilityFinalized(liability, gas - gasleft()));
        return true;
    }
}