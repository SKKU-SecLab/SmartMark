
pragma solidity 0.4.24;

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

contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  constructor() public {
    setOwner(msg.sender);
  }

  function setOwner(address newOwner) internal {

    owner = newOwner;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    setOwner(newOwner);
  }
}

contract ERC820Registry {

    function getManager(address addr) public view returns(address);

    function setManager(address addr, address newManager) public;

    function getInterfaceImplementer(address addr, bytes32 iHash) public constant returns (address);

    function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public;

}

contract ERC820Implementer {

    ERC820Registry erc820Registry = ERC820Registry(0x991a1bcb077599290d7305493c9A630c20f8b798);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {

        bytes32 ifaceHash = keccak256(ifaceLabel);
        erc820Registry.setInterfaceImplementer(this, ifaceHash, impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {

        bytes32 ifaceHash = keccak256(ifaceLabel);
        return erc820Registry.getInterfaceImplementer(addr, ifaceHash);
    }

    function delegateManagement(address newManager) internal {

        erc820Registry.setManager(this, newManager);
    }
}

interface ERC777TokensSender {

    function tokensToSend(address operator, address from, address to, uint amount, bytes userData,bytes operatorData) external;

}


interface ERC777TokensRecipient {

    function tokensReceived(address operator, address from, address to, uint amount, bytes userData, bytes operatorData) external;

}

contract JaroCoinToken is Ownable, ERC820Implementer {

    using SafeMath for uint256;

    string public constant name = "JaroCoin";
    string public constant symbol = "JARO";
    uint8 public constant decimals = 18;
    uint256 public constant granularity = 1e10;   // Token has 8 digits after comma

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => bool)) public isOperatorFor;
    mapping (address => mapping (uint256 => bool)) private usedNonces;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Sent(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes userData, bytes operatorData);
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes userData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply = 0;
    uint256 public constant maxSupply = 21000000e18;



    function send(address _to, uint256 _amount, bytes _userData) public {

        doSend(msg.sender, _to, _amount, _userData, msg.sender, "", true);
    }

    function sendByCheque(address _to, uint256 _amount, bytes _userData, uint256 _nonce, uint8 v, bytes32 r, bytes32 s) public {

        require(_to != address(this));

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(prefix, keccak256(_to, _amount, _userData, _nonce));

        address signer = ecrecover(hash, v, r, s);
        require (signer != 0);
        require (!usedNonces[signer][_nonce]);
        usedNonces[signer][_nonce] = true;

        doSend(signer, _to, _amount, _userData, signer, "", true);
    }

    function authorizeOperator(address _operator) public {

        require(_operator != msg.sender);
        isOperatorFor[_operator][msg.sender] = true;
        emit AuthorizedOperator(_operator, msg.sender);
    }

    function revokeOperator(address _operator) public {

        require(_operator != msg.sender);
        isOperatorFor[_operator][msg.sender] = false;
        emit RevokedOperator(_operator, msg.sender);
    }

    function operatorSend(address _from, address _to, uint256 _amount, bytes _userData, bytes _operatorData) public {

        require(isOperatorFor[msg.sender][_from]);
        doSend(_from, _to, _amount, _userData, msg.sender, _operatorData, true);
    }

    function requireMultiple(uint256 _amount) internal pure {

        require(_amount.div(granularity).mul(granularity) == _amount);
    }

    function isRegularAddress(address _addr) internal constant returns(bool) {

        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) } // solhint-disable-line no-inline-assembly
        return size == 0;
    }

    function callSender(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData
    ) private {

        address senderImplementation = interfaceAddr(_from, "ERC777TokensSender");
        if (senderImplementation != 0) {
            ERC777TokensSender(senderImplementation).tokensToSend(
                _operator, _from, _to, _amount, _userData, _operatorData);
        }
    }

    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData,
        bool _preventLocking
    ) private {

        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");
        if (recipientImplementation != 0) {
            ERC777TokensRecipient(recipientImplementation).tokensReceived(
                _operator, _from, _to, _amount, _userData, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to));
        }
    }

    function doSend(
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        address _operator,
        bytes _operatorData,
        bool _preventLocking
    )
        private
    {

        requireMultiple(_amount);

        callSender(_operator, _from, _to, _amount, _userData, _operatorData);

        require(_to != 0x0);                  // forbid sending to 0x0 (=burning)
        require(balanceOf[_from] >= _amount); // ensure enough funds

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        callRecipient(_operator, _from, _to, _amount, _userData, _operatorData, _preventLocking);

        emit Sent(_operator, _from, _to, _amount, _userData, _operatorData);
        emit Transfer(_from, _to, _amount);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {

        doSend(msg.sender, _to, _value, "", msg.sender, "", false);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(isOperatorFor[msg.sender][_from]);
        doSend(_from, _to, _value, "", msg.sender, "", true);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {

        if (isOperatorFor[_spender][_owner]) {
            return balanceOf[_owner];
        } else {
            return 0;
        }
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        require(_spender != msg.sender);

        if (_value > 0) {
            isOperatorFor[_spender][msg.sender] = true;
            emit AuthorizedOperator(_spender, msg.sender);
        } else {
            isOperatorFor[_spender][msg.sender] = false;
            emit RevokedOperator(_spender, msg.sender);
        }

        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function mint(address _to, uint256 _amount, bytes _operatorData) public onlyOwner {

        require (totalSupply.add(_amount) <= maxSupply);
        requireMultiple(_amount);

        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        callRecipient(msg.sender, 0x0, _to, _amount, "", _operatorData, true);

        emit Minted(msg.sender, _to, _amount, _operatorData);
        emit Transfer(0x0, _to, _amount);
    }

    function burn(uint256 _amount, bytes _userData) public {

        require (_amount > 0);
        require (balanceOf[msg.sender] >= _amount);
        requireMultiple(_amount);

        callSender(msg.sender, msg.sender, 0x0, _amount, _userData, "");

        totalSupply = totalSupply.sub(_amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);

        emit Burned(msg.sender, msg.sender, _amount, _userData, "");
        emit Transfer(msg.sender, 0x0, _amount);
    }
}

contract JaroSleep is ERC820Implementer, ERC777TokensRecipient {

    using SafeMath for uint256;

    uint256 public lastBurn;                         // Time of last sleep token burn
    uint256 public dailyTime;                        // Tokens to burn per day
    JaroCoinToken public token;

    event ReceivedTokens(address operator, address from, address to, uint amount, bytes userData, bytes operatorData);

    constructor(address _token, uint256 _dailyTime) public {
        setInterfaceImplementation("ERC777TokensRecipient", this);
        token = JaroCoinToken(_token);
        lastBurn = getNow();
        dailyTime = _dailyTime;
    }

    function () external payable {
        revert();
    }

    function burnTokens() public returns (uint256) {

        uint256 sec = getNow().sub(lastBurn);
        uint256 tokensToBurn = 0;

        if (sec >= 1 days) {
            uint256 d =  sec.div(86400);
            tokensToBurn = d.mul(dailyTime);
            token.burn(tokensToBurn, "");
            lastBurn = lastBurn.add(d.mul(86400));
        }

        return tokensToBurn;
    }

    function getNow() internal view returns (uint256) {

        return now;
    }

    function tokensReceived(address operator, address from, address to, uint amount, bytes userData, bytes operatorData) external {

        emit ReceivedTokens(operator, from, to, amount, userData, operatorData);
    }
}

contract PersonalTime is Ownable, ERC820Implementer, ERC777TokensRecipient {

    using SafeMath for uint256;

    uint256 public lastBurn;                         // Time of last sleep token burn
    uint256 public dailyTime;                        // Tokens to burn per day
    uint256 public debt = 0;                         // Debt which will be not minted during next sale period
    uint256 public protect = 0;                      // Tokens which were transfered in favor of future days
    JaroCoinToken public token;

    event ReceivedTokens(address operator, address from, address to, uint amount, bytes userData, bytes operatorData);

    constructor(address _token, uint256 _dailyTime) public {
        setInterfaceImplementation("ERC777TokensRecipient", this);
        token = JaroCoinToken(_token);
        lastBurn = getNow();
        dailyTime = _dailyTime;
    }

    function () external payable {
        revert();
    }

    function burnTokens() public returns (uint256) {

        uint256 sec = getNow().sub(lastBurn);
        uint256 tokensToBurn = 0;

        if (sec >= 1 days) {
            uint256 d =  sec.div(86400);
            tokensToBurn = d.mul(dailyTime);

            if (protect >= tokensToBurn) {
                protect = protect.sub(tokensToBurn);
            } else {
                token.burn(tokensToBurn.sub(protect), "");
                protect = 0;
            }

            lastBurn = lastBurn.add(d.mul(86400));
        }

        return tokensToBurn;
    }

    function transfer(address _to, uint256 _amount) public onlyOwner {

        protect = protect.add(_amount);
        debt = debt.add(_amount);
        token.transfer(_to, _amount);
    }

    function getNow() internal view returns (uint256) {

        return now;
    }

    function tokensReceived(address operator, address from, address to, uint amount, bytes userData, bytes operatorData) external {

        require(msg.sender == address(token));
        debt = (debt >= amount ? debt.sub(amount) : 0);
        emit ReceivedTokens(operator, from, to, amount, userData, operatorData);
    }
}


contract JaroCoinCrowdsale is Ownable {

    using SafeMath for uint256;

    address public constant WALLET = 0xefF42c79c0aBea9958432DC82FebC4d65f3d24A3;

    uint8 public constant EXCHANGE_RATE_DECIMALS = 8;

    uint256 public constant MAX_AMOUNT = 21000000e18; // 21 000 000

    uint256 public satoshiRaised;                     // Amount of raised funds in satoshi
    uint256 public rate;                              // number of tokens buyer gets per satoshi
    uint256 public conversionRate;                    // 17e10 wei per satoshi => 0.056 ETH/BTC

    JaroCoinToken public token;
    JaroSleep public sleepContract;
    PersonalTime public familyContract;
    PersonalTime public personalContract;

    uint256 public tokensToMint;                      // Amount of tokens left to mint in this sale
    uint256 public saleStartTime;                     // Start time of recent token sale

    bool public isActive = false;
    bool internal initialized = false;

    address public exchangeRateOracle;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event SaleActivated(uint256 startTime, uint256 amount);
    event SaleClosed();

    modifier canMint() {

        require (isActive);
        require (getNow() > saleStartTime);
        _;
    }

    function initialize(address _owner, address _token, address _familyOwner, address _personalOwner) public {

        require (!initialized);

        token = JaroCoinToken(_token);

        sleepContract = createJaroSleep(_token, 34560e18);       // 9.6 hours per day
        familyContract = createPersonalTime(_token, 21600e18);   // 6 hours per day
        personalContract = createPersonalTime(_token, 12960e18); // 3.6 hours per day

        familyContract.transferOwnership(_familyOwner);
        personalContract.transferOwnership(_personalOwner);

        rate = 100000e10;
        conversionRate = 17e10;
        satoshiRaised = 0;

        setOwner(_owner);
        initialized = true;
    }

    function () external canMint payable {
        _buyTokens(msg.sender, msg.value, 0);
    }

    function coupon(uint256 _timeStamp, uint16 _bonus, uint8 v, bytes32 r, bytes32 s) external canMint payable {

        require(_timeStamp >= getNow());

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(prefix, keccak256(_timeStamp, _bonus));

        address signer = ecrecover(hash, v, r, s);
        require(signer == owner);

        _buyTokens(msg.sender, msg.value, _bonus);
    }

    function buyTokens(address _beneficiary) public canMint payable {

        _buyTokens(_beneficiary, msg.value, 0);
    }

    function _buyTokens(address _beneficiary, uint256 _value, uint16 _bonus) internal {

        require (_beneficiary != address(0));
        require (_value > 0);

        uint256 weiAmount = _value;
        uint256 satoshiAmount = weiAmount.div(conversionRate);
        uint256 tokens = satoshiAmount.mul(rate).mul(_bonus + 100).div(100);

        uint256 excess = appendContribution(_beneficiary, tokens);
        uint256 refund = (excess > 0 ? excess.mul(100).div(100+_bonus).mul(conversionRate).div(rate) : 0);
        weiAmount = weiAmount.sub(refund);
        satoshiRaised = satoshiRaised.add(satoshiAmount);

        if (refund > 0) {
            msg.sender.transfer(refund);
        }

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens.sub(excess));

        WALLET.transfer(weiAmount);
    }

    function appendContribution(address _beneficiary, uint256 _tokens) internal returns (uint256) {

        if (_tokens >= tokensToMint) {
            mint(_beneficiary, tokensToMint);
            uint256 excededTokens = _tokens.sub(tokensToMint);
            _closeSale(); // Last tokens minted, lets close token sale
            return excededTokens;
        }

        tokensToMint = tokensToMint.sub(_tokens);
        mint(_beneficiary, _tokens);
        return 0;
    }

    function startSale(uint256 _startTime) public onlyOwner {

        require (!isActive);
        require (_startTime > getNow());
        require (saleStartTime == 0 || _startTime.sub(saleStartTime) > 30 days);   // Minimum one month between token sales

        sleepContract.burnTokens();
        uint256 sleepTokens = token.balanceOf(address(sleepContract));

        familyContract.burnTokens();
        uint256 familyTokens = token.balanceOf(familyContract).add(familyContract.debt());

        personalContract.burnTokens();
        uint256 personalTokens = token.balanceOf(personalContract).add(personalContract.debt());

        uint256 missingSleep = MAX_AMOUNT.div(100).mul(40).sub(sleepTokens);       // sleep and stuff takes 40% of Jaro time
        uint256 missingFamily = MAX_AMOUNT.div(100).mul(25).sub(familyTokens);     // 25% for family
        uint256 missingPersonal = MAX_AMOUNT.div(100).mul(15).sub(personalTokens); // 15% is Jaro personal time

        mint(address(sleepContract), missingSleep);
        mint(address(familyContract), missingFamily);
        mint(address(personalContract), missingPersonal);

        tokensToMint = MAX_AMOUNT.sub(token.totalSupply());
        saleStartTime = _startTime;
        isActive = true;
        emit SaleActivated(_startTime, tokensToMint);
    }

    function _closeSale() internal {

        tokensToMint = 0;
        isActive = false;
        emit SaleClosed();
    }

    function closeSale() public onlyOwner {

        _closeSale();
    }

    function setExchangeRateOracle(address _exchangeRateOracle) public onlyOwner {

        require(_exchangeRateOracle != address(0));
        exchangeRateOracle = _exchangeRateOracle;
    }

    function setExchangeRate(uint256 _exchangeRate) public {

        require(msg.sender == exchangeRateOracle || msg.sender == owner);
        require(_exchangeRate > 0);
        uint256 one = 1e18;
        conversionRate = one.div(_exchangeRate);
    }

    function mint(address _beneficiary, uint256 _amount) internal {

        if (_amount > 0) {
            token.mint(_beneficiary, _amount, "");
        }
    }

    function createJaroSleep(address _token, uint256 _dailyTime) internal returns (JaroSleep) {

        return new JaroSleep(_token, _dailyTime);
    }

    function createPersonalTime(address _token, uint256 _dailyTime) internal returns (PersonalTime) {

        return new PersonalTime(_token, _dailyTime);
    }

    function getNow() internal view returns (uint256) {

        return now;
    }
}