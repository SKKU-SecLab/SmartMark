
pragma solidity 0.4.17;

contract Ownable {

    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function Ownable() {

        owner = msg.sender;
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

pragma solidity 0.4.17;

contract ERC20Basic {

    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

pragma solidity 0.4.17;

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];
    }

}

pragma solidity 0.4.17;

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.4.17;

contract StandardToken is ERC20, BasicToken {


    mapping (address => mapping (address => uint256)) internal allowed;


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

pragma solidity 0.4.17;


contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {

        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() onlyOwner public returns (bool) {

        mintingFinished = true;
        MintFinished();
        return true;
    }
}

pragma solidity 0.4.17;

library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

pragma solidity 0.4.17;

contract Crowdsale {

    using SafeMath for uint256;

    MintableToken public token;

    uint256 public startTime;
    uint256 public endTime;

    address public wallet;

    uint256 public rate;

    uint256 public weiRaised;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {

        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != address(0));

        token = createTokenContract();
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
    }

    function createTokenContract() internal returns (MintableToken) {

        return new MintableToken();
    }


    function () payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {

        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        uint256 tokens = weiAmount.mul(rate);

        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function forwardFunds() internal {

        wallet.transfer(msg.value);
    }

    function validPurchase() internal constant returns (bool) {

        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function hasEnded() public constant returns (bool) {

        return now > endTime;
    }
}

pragma solidity 0.4.17;

contract BactocoinToken is StandardToken {

    string public name = 'BactoCoin';
    uint8 public decimals = 18;
    string public symbol = 'BTNN';
    string public version = '1.0.0';
    uint256 public totalSupply = 4e24 ; // 4 mil
    address public originalTokenHolder;

    function BactocoinToken(address allTokensHolder) {

        originalTokenHolder = allTokensHolder ;
        balances[allTokensHolder] = totalSupply; // Give the creator all initial tokens
        Transfer(0x0, allTokensHolder, totalSupply);
    }

}

pragma solidity 0.4.17;

contract BactocoinCrowdsale is Ownable {

    using SafeMath for uint256;

    uint256 public constant startTime = 1513256400; // 14.12.2017 14:00:00 GMT(+1)
    uint256 public constant endTime = 1514069999; // 23.12.2017, 23:59:59 GMT(+1)
    uint256 public constant bonusTime = 6000; // in seconds, 100 minutes
    address public constant wallet = 0xf00d4ec8af332b0a5a9eb24bfce32cf158ab6a4a;
    uint256 public constant chfCentsPerToken = 2500; // CHF 25.00
    uint256 public constant chfCentsPerTokenWhileBonus = 1875; // CHF 18.75
    uint256 public chfCentsPerEth = 60000; // CHF 600,00
    uint256 public weiRaised;


    BactocoinToken public token;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function BactocoinCrowdsale() Ownable() {


        require(startTime >= now);
        require(endTime >= startTime);
        require(wallet != address(0));

        token = new BactocoinToken(this);
    }

    function convertWeiToTokens(uint256 weiAmount) view returns (uint256) {

        uint256 chfCentsAmount = weiAmount;
        chfCentsAmount *= chfCentsPerEth;
        uint256 tokensAmountSatoshi = (chfCentsAmount / (chfCentsPerToken));
        if (bonusInEffect()) {
            tokensAmountSatoshi = (chfCentsAmount / (chfCentsPerTokenWhileBonus));
        }
        return tokensAmountSatoshi;
    }


    function () payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {

        require(beneficiary != address(0));
        require(validPurchase());

        uint256 tokensAmountSatoshi = convertWeiToTokens(msg.value);

        require(tokensAmountSatoshi <= token.balanceOf(this)); // not enough tokens left ?
        token.transfer(beneficiary, tokensAmountSatoshi);
        TokenPurchase(msg.sender, beneficiary, msg.value, tokensAmountSatoshi);
        weiRaised = weiRaised.add(msg.value);

        forwardFunds();
    }

    function updateChfCentsPerEth(uint256 newCents) onlyOwner {

        chfCentsPerEth = newCents;
    }

    function allocateAllUnsoldTokens(address newOwner) onlyOwner {

        require(token.balanceOf(this) > 0);
        require(hasEnded());
        token.transfer(newOwner, token.balanceOf(this));
    }

    function giveTokens(address newOwner, uint256 amount) onlyOwner {

        require(token.balanceOf(this) >= amount);
        token.transfer(newOwner, amount);
    }

    function forwardFunds() internal {

        wallet.transfer(msg.value);
    }


    function validPurchase() internal constant returns (bool) {

        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function bonusInEffect() internal constant returns (bool) {

        bool withinPeriod = now >= startTime && now <= (startTime + bonusTime);
        return withinPeriod;
    }

    function hasEnded() public constant returns (bool) {

        return now > endTime;
    }

}