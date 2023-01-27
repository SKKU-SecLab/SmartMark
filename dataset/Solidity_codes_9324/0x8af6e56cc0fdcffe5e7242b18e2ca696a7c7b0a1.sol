

pragma solidity 0.5.2;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap; // solium-disable-line mixedcase
}


contract Adminable is Initializable {


  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  modifier ifAdmin() {

    require(msg.sender == _admin(), "sender not admin");
    _;
  }

  function admin() external view returns (address) {

    return _admin();
  }

  function implementation() external view returns (address impl) {

    bytes32 slot = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;
    assembly {
      impl := sload(slot)
    }
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }
}


contract Bridge is Adminable {



  struct Period {
    uint32 height;            // the height of last block in period
    uint32 timestamp;         // the block.timestamp at submission of period
    uint32 parentBlockNumber; // the block.number at submission of period
    bytes32 parentBlockHash;  // the blockhash(block.number -1) at submission of period
  }

  address public operator; // the operator contract

  mapping(bytes32 => Period) public periods;

}

contract Vault {



  function getTokenAddr(uint16 _color) public view returns (address) {

  }


}



contract SwapExchange {


  address factory;
  address token;
  address nativeToken;
  bytes32 public name;
  bytes32 public symbol;
  uint256 public decimals;

  function setup(address _nativeToken, address _tokenAddr) public {

    require(factory == address(0) && token == address(0), "setup can only be executed once");
    require(_nativeToken != address(0), "tokenAddr not valid");
    require(_tokenAddr != address(0), "tokenAddr not valid");
    factory = msg.sender;
    token = _tokenAddr;
    nativeToken = _nativeToken;
    name = 0x4c65617020537761702056310000000000000000000000000000000000000000;   // Leap Swap V1
    symbol = 0x4c4541502d563100000000000000000000000000000000000000000000000000; // LEAP-V1
    decimals = 18;
  }


}

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

contract ERC20Mintable is ERC20, MinterRole {

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }
}


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

contract SwapRegistryMigration is Adminable {

  using SafeMath for uint256;

  Bridge bridge;
  Vault vault;
  uint256 constant maxTax = 1000; // 100%
  uint256 taxRate; // as perMil (1000 == 100%, 1 == 0.1%)
  uint256 constant inflationFactor = 10 ** 15;
  uint256 constant maxInflation = 2637549827; // the x from (1 + x*10^-18)^(30 * 24 * 363) = 2
  uint256 inflationRate; // between 0 and maxInflation/inflationFactor
  uint256 constant poaSupplyTarget = 7000000 * 10 ** 18;
  uint256 poaReward;
  mapping(uint256 => uint256) public slotToHeight;

  function initialize(
    address _bridge,
    address _vault,
    uint256 _poaReward
  ) public initializer {

    require(_bridge != address(0), "invalid bridge address");
    bridge = Bridge(_bridge);
    require(_bridge != address(0), "invalid vault address");
    vault = Vault(_vault);
    taxRate = maxTax;
    inflationRate = maxInflation;
    poaReward = _poaReward;
  }

  function claim(
    uint256 _slotId,
    bytes32[] memory _consensusRoots,
    bytes32[] memory _cas,
    bytes32[] memory _validatorData,
    bytes32[] memory _rest
  ) public {

    uint256 maxHeight = slotToHeight[_slotId];
    uint32 claimCount = 0;
    for (uint256 i = 0; i < _consensusRoots.length; i += 1) {
      require(_slotId == uint256(_validatorData[i] >> 160), "unexpected slotId");
      require(msg.sender == address(uint160(uint256(_validatorData[i]))), "unexpected claimant");
      uint256 height;
      bytes32 left = _validatorData[i];
      bytes32 right = _rest[i];
      assembly {
        mstore(0, left)
        mstore(0x20, right)
        right := keccak256(0, 0x40)
      }
      left = _cas[i];
      assembly {
        mstore(0, left)
        mstore(0x20, right)
        right := keccak256(0, 0x40)
      }
      left = _consensusRoots[i];
      assembly {
        mstore(0, left)
        mstore(0x20, right)
        right := keccak256(0, 0x40)
      }
      (height ,,,) = bridge.periods(right);
      require(height > maxHeight, "unorderly claim");
      maxHeight = height;
      claimCount += 1;
    }
    slotToHeight[_slotId] = maxHeight;
    ERC20Mintable token = ERC20Mintable(vault.getTokenAddr(0));
    uint256 total = token.totalSupply();
    uint256 staked = token.balanceOf(bridge.operator());

    uint256 reward = total.mul(inflationRate).div(inflationFactor);
    if (staked > total.div(2)) {
      reward = reward.mul(total.sub(staked).mul(staked).mul(4)).div(total);
    }
    if (total < poaSupplyTarget) {
      reward = poaReward;
    }
    reward = reward.mul(claimCount);
    uint256 tax = reward.mul(taxRate).div(maxTax);  // taxRate perMil (1000 == 100%, 1 == 0.1%)
    token.mint(msg.sender, reward.sub(tax));
    token.mint(bridge.admin(), tax);
  }


  function getTaxRate() public view returns(uint256) {

    return taxRate;
  }

  function setTaxRate(uint256 _taxRate) public ifAdmin {

    require(_taxRate <= maxTax, "tax rate can not be more than 100%");
    taxRate = _taxRate;
  }

  function getInflationRate() public view returns(uint256) {

    return inflationRate;
  }

  function setInflationRate(uint256 _inflationRate) public ifAdmin {

    require(_inflationRate < maxInflation, "inflation too high");
    inflationRate = _inflationRate;
  }


  event NewExchange(address indexed token, address indexed exchange);
  mapping(address => address) tokenToExchange;
  mapping(address => address) exchangeToToken;
  address exchangeCodeAddr;

  function createExchange(address _token) public returns (address) {

    require(_token != address(0), "invalid token address");
    address nativeToken = vault.getTokenAddr(0);
    require(_token != nativeToken, "token can not be nativeToken");
    require(tokenToExchange[_token] == address(0), "exchange already created");
    address exchange = createClone(exchangeCodeAddr);
    SwapExchange(exchange).setup(nativeToken, _token);
    tokenToExchange[_token] = exchange;
    exchangeToToken[exchange] = _token;
    emit NewExchange(_token, exchange);
    return exchange;
  }

  function getExchangeCodeAddr() public view returns(address) {

    return exchangeCodeAddr;
  }

  function setExchangeCodeAddr(address _exchangeCodeAddr) public ifAdmin {

    exchangeCodeAddr = _exchangeCodeAddr;
  }

  function getExchange(address _token) public view returns(address) {

    return tokenToExchange[_token];
  }

  function getToken(address _exchange) public view returns(address) {

    return exchangeToToken[_exchange];
  }

  function createClone(address target) internal returns (address result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  modifier onlyMultisig() {

    require(msg.sender == 0xC5cDcD5470AEf35fC33BDDff3f8eCeC027F95B1d, "msg.sender not multisig");
    _;
  }

  function transferMinter() public onlyMultisig {

    ERC20Mintable token = ERC20Mintable(vault.getTokenAddr(0));
    token.addMinter(msg.sender);
    token.renounceMinter();
  }

}