

pragma solidity ^ 0.8.7;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

abstract contract ERC20Basic {
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address who) public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view override returns(uint256) {

        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public override returns(bool) {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view override returns(uint256) {

        return balances[_owner];
    }
}

abstract contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view  virtual returns (uint256);
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
    function approve(address spender, uint256 value) public virtual returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256) {

        return allowed[_owner][_spender];
    }

    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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

library SafeERC20 {

    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

        assert(token.transfer(to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {

        assert(token.transferFrom(from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {

        assert(token.approve(spender, value));
    }
}

contract Owned {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
}

contract TokenVesting is Owned {

    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    event Released(uint256 amount);
    event Revoked();

    address public beneficiary;

    uint256 public cliff;
    uint256 public start;
    uint256 public duration;

    bool public revocable;

    mapping (address => uint256) public released;
    mapping (address => bool) public revoked;

    address internal ownerShip;

    constructor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        bool _revocable,
        address _realOwner
    )

    {
        require(_beneficiary != address(0));
        require(_cliff <= _duration);

        beneficiary = _beneficiary;
        revocable = _revocable;
        duration = _duration;
        cliff = _start.add(_cliff);
        start = _start;
        ownerShip = _realOwner;
    }

    function release(ERC20Basic token) public {

        uint256 unreleased = releasableAmount(token);

        require(unreleased > 0);

        released[address(this)] = released[address(this)].add(unreleased);

        token.safeTransfer(beneficiary, unreleased);

        emit Released(unreleased);
    }

    function revoke(ERC20Basic token) public onlyOwner {

        require(revocable);
        require(!revoked[address(token)]);

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        revoked[address(token)] = true;

        token.safeTransfer(ownerShip, refund);

        emit Revoked();
    }

    function releasableAmount(ERC20Basic token) public view returns (uint256) {

        return vestedAmount(token).sub(released[address(token)]);
    }

    function vestedAmount(ERC20Basic token) public view returns (uint256) {

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released[address(token)]);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}

contract TokenVault {

    using SafeERC20 for ERC20;

    ERC20 public token;

    constructor(ERC20 _token) {
        token = _token;
    }

    function fillUpAllowance() public {

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0);

        token.approve(address(token), amount);
    }
}

contract BurnableToken is StandardToken {

    using SafeMath for uint256;
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value > 0);
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
    }
}

contract OndaToken is BurnableToken, Owned {

    using SafeMath for uint256;

    string public constant name = "ONDA TOKEN";
    string public constant symbol = "ONDA";
    uint8 public constant decimals = 18;
 
    uint256 public constant HARD_CAP = 1000000000 * 10**uint256(decimals);

    address public saleTokensAddress;

    TokenVault public reserveTokensVault;

    uint64 internal daySecond     = 86400;
    uint64 internal lock90Days    = 90;
    uint64 internal unlock100Days = 100;
    uint64 internal lock365Days   = 365;

    mapping(address => address) public vestingOf;

    constructor(address _saleTokensAddress) {
        require(_saleTokensAddress != address(0));

        saleTokensAddress = _saleTokensAddress;

        createTokensInt(369000000, saleTokensAddress);

        require(totalSupply_ <= HARD_CAP);
    }

    function createReserveTokensVault() external onlyOwner {

        require(address(reserveTokensVault) == address(0));

        reserveTokensVault = createTokenVaultInt(631000000);

        require(totalSupply_ <= HARD_CAP);
    }

    function createTokenVaultInt(uint256 tokens) internal onlyOwner returns (TokenVault) {

        TokenVault tokenVault = new TokenVault(ERC20(this));
        createTokensInt(tokens, address(tokenVault));
        tokenVault.fillUpAllowance();
        return tokenVault;
    }

    function createTokensInt(uint256 _tokens, address _destination) internal onlyOwner {

        uint256 tokens = _tokens * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(tokens);
        balances[_destination] = balances[_destination].add(tokens);
        emit Transfer(address(0), _destination, tokens);

        require(totalSupply_ <= HARD_CAP);
    }

    function vestTokensDetailInt(
                        address _beneficiary,
                        uint256 _startS,
                        uint256 _cliffS,
                        uint256 _durationS,
                        bool _revocable,
                        uint256 _tokensAmountInt) external onlyOwner {

        require(_beneficiary != address(0));

        uint256 tokensAmount = _tokensAmountInt * 10**uint256(decimals);

        if(vestingOf[_beneficiary] == address(0)) {
            TokenVesting vesting = new TokenVesting(_beneficiary, _startS, _cliffS, _durationS, _revocable, owner);
            vestingOf[_beneficiary] = address(vesting);
        }

        require(this.transferFrom(address(reserveTokensVault), vestingOf[_beneficiary], tokensAmount));
    }

    function vestTokensStartAtInt(
                            address _beneficiary, 
                            uint256 _tokensAmountInt,
                            uint256 _startS,
                            uint256 _afterDay,
                            uint256 _cliffDay,
                            uint256 _durationDay ) public onlyOwner {

        require(_beneficiary != address(0));

        uint256 tokensAmount = _tokensAmountInt * 10**uint256(decimals);
        uint256 afterSec = _afterDay * daySecond;
        uint256 cliffSec = _cliffDay * daySecond;
        uint256 durationSec = _durationDay * daySecond;

        if(vestingOf[_beneficiary] == address(0)) {
            TokenVesting vesting = new TokenVesting(_beneficiary, _startS + afterSec, cliffSec, durationSec, true, owner);
            vestingOf[_beneficiary] = address(vesting);
        }

        require(this.transferFrom(address(reserveTokensVault), vestingOf[_beneficiary], tokensAmount));
    }

    function vestTokensFromNowInt(address _beneficiary, uint256 _tokensAmountInt, uint256 _afterDay, uint256 _cliffDay, uint256 _durationDay ) public onlyOwner {

        vestTokensStartAtInt(_beneficiary, _tokensAmountInt, block.timestamp, _afterDay, _cliffDay, _durationDay);
    }

    function vestCmdNow1PercentInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {

        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, 0, 0, unlock100Days);
    }
    function vestCmd3Month1PercentInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {

        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, lock90Days, 0, unlock100Days);
    }

    function vestCmd1YearInstantInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {

        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, 0, lock365Days, lock365Days);
    }

    function releaseVestedTokens() external {

        releaseVestedTokensFor(msg.sender);
    }

    function releaseVestedTokensFor(address _owner) public {

        TokenVesting(vestingOf[_owner]).release(this);
    }

    function lockedBalanceOf(address _owner) public view returns (uint256) {

        return balances[vestingOf[_owner]];
    }

    function releaseableBalanceOf(address _owner) public view returns (uint256) {

        if (vestingOf[_owner] == address(0) ) {
            return 0;
        } else {
            return TokenVesting(vestingOf[_owner]).releasableAmount(this);
        }
    }

    function revokeVestedTokensFor(address _owner) public onlyOwner {

        TokenVesting(vestingOf[_owner]).revoke(this);
    }

    function makeReserveToVault() external onlyOwner {

        require(address(reserveTokensVault) != address(0));
        reserveTokensVault.fillUpAllowance();
    }

}