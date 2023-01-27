
pragma solidity ^0.6.0;

interface ERC20Basic {

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {

    address owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0), "transferring to a zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}

contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
        emit Unpause();
    }
}


contract PausableToken is ERC20Basic, Pausable {

    using SafeMath for uint256;

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256  internal totalSupply_;

    function totalSupply() public override view returns (uint256) {

        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public override virtual returns (bool) {

        require(_to != address(0), "trasferring to zero address");
        require(_value <= balances[msg.sender], "transfer amount exceeds available balance");
        require(!paused, "token transfer while paused");
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256) {

        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public override virtual returns (bool) {

        require(_from != address(0), "from must not be zero address"); 
        require(_to != address(0), "to must not be zero address"); 
        require(!paused, "token transfer while paused");
        require(_value <= allowed[_from][msg.sender], "tranfer amount exceeds allowance");
        require(_value <= balances[_from], "transfer amount exceeds available balance");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {

        require(_spender != address(0), "approving to a zero address");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256) {

        return allowed[_owner][_spender];
    }

    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public 
        returns (bool)
    {

        require(_spender != address(0), "approving to zero address");
        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool)
    {

        require(_spender != address(0), "spender must not be a zero address");
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract MintableToken is PausableToken {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool private mintingFinished = false;

    modifier canMint() {

        require(!mintingFinished, "minting is finished");
        _;
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool)
    {

        require(_to != address(0), "minting to zero address");
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() public onlyOwner canMint returns (bool) {

        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}


contract FreezableMintableToken is MintableToken {


    mapping (address => bool) private frozenAccounts;

    mapping (address => uint256) private frozenBalance;

    event FrozenAccount(address target, bool frozen);
    event TokensFrozen(address indexed account, uint amount);
    event TokensUnfrozen(address indexed account, uint amount);

    function freezeAccount(address target, bool freeze) public onlyOwner {

        frozenAccounts[target] = freeze;
        emit FrozenAccount(target, freeze);
    }

    function frozenBalanceOf(address _owner) public view returns (uint256 balance) {

        return frozenBalance[_owner];
    }

    function usableBalanceOf(address _owner) public view returns (uint256 balance) {

        return (balances[_owner].sub(frozenBalance[_owner]));
    }

    function freezeTo(address _to, uint _amount) public onlyOwner {

        require(_to != address(0), "freezing a zero address");
        require(_amount <= balances[msg.sender], "amount exceeds balance");

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        frozenBalance[_to] = frozenBalance[_to].add(_amount);

        emit Transfer(msg.sender, _to, _amount);
        emit TokensFrozen(_to, _amount);
    }

    function unfreezeFrom(address _from, uint _amount) public onlyOwner {

        require(_from != address(0), "unfreezing from zero address");
        require(_amount <= frozenBalance[_from], "amount exceeds frozen balance");

        frozenBalance[_from] = frozenBalance[_from].sub(_amount);
        emit TokensUnfrozen(_from, _amount);
    }


    function mintAndFreeze(address _to, uint _amount) public onlyOwner canMint returns (bool) {

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        frozenBalance[_to] = frozenBalance[_to].add(_amount);

        emit Mint(_to, _amount);
        emit TokensFrozen(_to, _amount);  
        emit Transfer(address(0), _to, _amount);
        return true;
    }  
    
    function transfer(address _to, uint256 _value) public override virtual returns (bool) {

        require(!frozenAccounts[msg.sender], "account is frozen");
        require(_value <= (balances[msg.sender].sub(frozenBalance[msg.sender])), 
            "amount exceeds usable balance");
        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override virtual returns (bool) {

        require(!frozenAccounts[msg.sender], "account is frozen");
        require(_value <= (balances[_from].sub(frozenBalance[_from])), 
            "amount to transfer exceeds usable balance");
        super.transferFrom(_from, _to, _value);
    }

}

contract BurnableFreezableMintableToken is FreezableMintableToken {

    mapping (address => bool) private blocklistedAccounts;

    event Burn(address indexed owner, uint256 value);

    event AccountBlocked(address user);
    event AccountUnblocked(address user);
    event BlockedFundsDestroyed(address blockedListedUser, uint destroyedAmount);

    function transfer(address _to, uint256 _value) public override returns (bool) {

        require(!blocklistedAccounts[msg.sender], "account is blocklisted");
        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

        require(!blocklistedAccounts[_from], "account is blocklisted");
        super.transferFrom(_from, _to, _value);
    }
    
    function isBlocklisted(address _maker) public view returns (bool) {

        return blocklistedAccounts[_maker];
    } 
    
    function blockAccount(address _evilUser) public onlyOwner returns (bool) {

        require(_evilUser != address(0), "address to block must not be zero address");
        blocklistedAccounts[_evilUser] = true;
        emit AccountBlocked(_evilUser);
        return true;
    }

    function unblockAccount(address _clearedUser) public onlyOwner returns (bool) {

        blocklistedAccounts[_clearedUser] = false;
        emit AccountUnblocked(_clearedUser);
        return true;
    }

    function destroyBlockedFunds(address _blockListedUser) public onlyOwner returns (bool) {

        require(blocklistedAccounts[_blockListedUser], "account must be blocklisted");
        uint dirtyFunds = balanceOf(_blockListedUser);
        _burn(_blockListedUser, dirtyFunds);
        emit BlockedFundsDestroyed(_blockListedUser, dirtyFunds);
        return true;
    }

    function burn(address _owner, uint256 _value) public onlyOwner {

        _burn(_owner, _value);
    }
  
    function _burn(address _who, uint256 _value) internal {

        require(_who != address(0));
        require(_value <= balances[_who]);
        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}

contract MainToken is BurnableFreezableMintableToken {


    uint8 constant private DECIMALS = 18;
    uint constant private INITIAL_SUPPLY = 98000000000 * (10 ** uint(DECIMALS));
    string constant private NAME = "AllmediCoin";
    string constant private SYMBOL = "AMDC";

    constructor() public {
        address mintAddress = msg.sender;
        mint(mintAddress, INITIAL_SUPPLY);
    }
  
    function name() public view returns (string memory _name) {

        return NAME;
    }

    function symbol() public view returns (string memory _symbol) {

        return SYMBOL;
    }

    function decimals() public view returns (uint8 _decimals) {

        return DECIMALS;
    }
    
}