
pragma solidity ^0.5.0;

contract SafeMath {

    function Sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function Add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function Mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
    function Mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Token {

    function totalSupply() public view returns (uint256 supply);


    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value)
        public
        returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success);


    function approve(address _spender, uint256 _value)
        public
        returns (bool success);


    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract KAIstarterOWMN is SafeMath {

    constructor(uint256 _lockDays, uint256 _lockStartTime) public {
        owner = msg.sender;
        lockDays = _lockDays;
        lockStartTime = _lockStartTime;
        isEnded = false;
    }

    address constant public KAI_ADDRESS = 0xD9Ec3ff1f8be459Bb9369b4E79e9Ebcf7141C093;
    uint256 constant public HARD_CAP = 10000000000000000000000000; // 10 000 000 KAI
    uint256 constant public MAX_DEPOSIT = 500000000000000000000000; //500 000 KAI
    uint256 constant public AMOUNT_MULTIPLES = 1000000000000000000000; // 1000 KAI
    
    address public owner;
    uint256 public totalViews;
    uint256 public bonus;
    uint256 public lockDays;
    uint256 public currentCap;
    uint256 public lockStartTime;
    uint8 public depositorCount ;
    bool public isEnded;

    mapping(address => uint256) public addrBalance;

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function depositBonus(uint256 _amount) public onlyOwner {

        require(Token(KAI_ADDRESS).transferFrom(msg.sender, address(this), _amount));
        
        bonus = Add(_amount, bonus);
    }

    function withdrawBonus(uint256 _amount) public onlyOwner {

        require(Token(KAI_ADDRESS).transfer(msg.sender, _amount));
        
        bonus = Sub(bonus, _amount);
    }
    
    function setTotalViews(uint256 _totalViews) public onlyOwner {

        totalViews = _totalViews;
    }

    function depositToken(uint256 _amount) public {

        require(isEnded != true, "Deposit ended");
        require(lockStartTime < now, 'Event has not been started yet');
        require(Add(addrBalance[msg.sender], _amount) <= MAX_DEPOSIT, "Exceed limit personal cap");
        require(Add(currentCap, _amount) <= HARD_CAP, 'Exceed limit total cap');
        require(Mod(_amount, AMOUNT_MULTIPLES) == 0, "Amount must be in multiples of 1,000 KAI");
        require(Token(KAI_ADDRESS).transferFrom(msg.sender, address(this), _amount));
        
        if (addrBalance[msg.sender] == 0) {
            depositorCount += 1;
        }
        
        currentCap = Add(currentCap, _amount);
        addrBalance[msg.sender] = Add(addrBalance[msg.sender], _amount);
    }

    function withdrawToken() public {

        require(lockStartTime + lockDays * 1 days < now, "Locking period");
        uint256 amount = addrBalance[msg.sender];
        require(amount > 0, "withdraw only once");
        
        uint256 interest = Mul(amount, totalViews) / 600000000;

        bonus = Sub(bonus, interest);
        amount = Add(amount, interest);
        require(Token(KAI_ADDRESS).transfer(msg.sender, amount));
        addrBalance[msg.sender] = 0;
    }
    
    function setEndedDeposit() public onlyOwner {

        isEnded = true;
    }


    function emergencyWithdrawalETH(uint256 _amount) public onlyOwner {

        require(msg.sender.send(_amount));
    }
    
    function emergencyWithdrawalToken(uint256 _amount) public onlyOwner {

        Token(KAI_ADDRESS).transfer(msg.sender, _amount);
    }
    
    function getMyBalance() public view returns (uint256) {

        return addrBalance[msg.sender];
    }
    
    function getBalanceContract() public view returns (uint256) {

        return Token(KAI_ADDRESS).balanceOf(address(this));
    }
    
    function getTimestamp() public view returns (uint256) {

        return now;
    }
    
    function () external payable {}
}