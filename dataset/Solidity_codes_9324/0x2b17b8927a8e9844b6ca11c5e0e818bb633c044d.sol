
pragma solidity 0.5.9;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Admined {

    address public owner; //named owner for etherscan compatibility
    mapping(address => uint256) public level;

    constructor() public {
        owner = msg.sender;
        level[owner] = 3;
        emit OwnerSet(owner);
        emit LevelSet(owner, level[owner]);
    }

    modifier onlyAdmin(uint256 _minLvl) {

        require(level[msg.sender] >= _minLvl, 'You do not have privileges for this transaction');
        _;
    }

    function transferOwnership(address newOwner) public onlyAdmin(3) {

        require(newOwner != address(0), 'Address cannot be zero');

        owner = newOwner;
        level[owner] = 3;

        emit OwnerSet(owner);
        emit LevelSet(owner, level[owner]);

        level[msg.sender] = 0;
        emit LevelSet(msg.sender, level[msg.sender]);
    }

    function setLevel(address userAddress, uint256 lvl) public onlyAdmin(2) {

        require(userAddress != address(0), 'Address cannot be zero');
        require(lvl < level[msg.sender], 'You do not have privileges for this level assignment');
        require(level[msg.sender] > level[userAddress], 'You do not have privileges for this level change');

        level[userAddress] = lvl;
        emit LevelSet(userAddress, level[userAddress]);
    }

    event LevelSet(address indexed user, uint256 lvl);
    event OwnerSet(address indexed user);

}

contract ERC20Basic {

    uint256 public totalSupply;

    function balanceOf(address who) public view returns(uint256);


    function transfer(address to, uint256 value) public returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns(uint256);


    function transferFrom(address from, address to, uint256 value) public returns(bool);


    function approve(address spender, uint256 value) public returns(bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakerToken {

    uint256 public stakeStartTime;
    uint256 public stakeMinAge;
    uint256 public stakeMaxAge;

    function claimStake() public returns(bool);


    function coinAge() public view returns(uint256);


    function annualInterest() public view returns(uint256);

}

contract OMNIS is ERC20, StakerToken, Admined {

    using SafeMath
    for uint256;
    string public name = "OMNIS-BIT";
    string public symbol = "OMNIS";
    string public version = "v4";
    uint8 public decimals = 18;

    uint public totalSupply;
    uint public maxTotalSupply;
    uint public totalInitialSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    struct Airdrop {
        uint value;
        bool claimed;
    }

    address public airdropWallet;

    mapping(address => Airdrop) public airdrops; //One airdrop at a time allowed

    enum PaymentStatus {
        Requested,
        Rejected,
        Pending,
        Completed,
        Refunded
    }

    struct Payment {
        address provider;
        address customer;
        uint value;
        string comment;
        PaymentStatus status;
        bool refundApproved;
    }

    uint escrowCounter;
    uint public escrowFeePercent = 2; //initially set to 0.2%
    bool public escrowEnabled = true;

    modifier escrowIsEnabled() {

        require(escrowEnabled == true, 'Escrow is Disabled');
        _;
    }

    mapping(uint => Payment) public payments;
    address public collectionAddress;

    struct transferInStruct {
        uint128 amount;
        uint64 time;
    }

    uint public chainStartTime;
    uint public chainStartBlockNumber;
    uint public stakeStartTime;
    uint public stakeMinAge = 3 days;
    uint public stakeMaxAge = 90 days;

    mapping(address => bool) public userFreeze;


    mapping(address => uint) staked;
    mapping(address => transferInStruct) lastTransfer;


    modifier canPoSclaimStake() {

        require(totalSupply < maxTotalSupply, 'Max supply reached');
        _;
    }

    modifier notFrozen(address _holderWallet) {

        require(userFreeze[_holderWallet] == false, 'Balance frozen by the user');
        _;
    }

    event ClaimStake(address indexed _address, uint _reward);
    event NewCollectionWallet(address newWallet);

    event ClaimDrop(address indexed user, uint value);
    event NewAirdropWallet(address newWallet);

    event GlobalFreeze(bool status);

    event EscrowLock(bool status);
    event NewFeeRate(uint newFee);
    event PaymentCreation(
        uint indexed orderId,
        address indexed provider,
        address indexed customer,
        uint value,
        string description
    );
    event PaymentUpdate(
        uint indexed orderId,
        address indexed provider,
        address indexed customer,
        uint value,
        PaymentStatus status
    );
    event PaymentRefundApprove(
        uint indexed orderId,
        address indexed provider,
        address indexed customer,
        bool status
    );

    constructor() public {

        maxTotalSupply = 1000000000 * 10 ** 18; //MAX SUPPLY EVER
        totalInitialSupply = 820000000 * 10 ** 18; //INITIAL SUPPLY
        chainStartTime = now; //Deployment Time
        chainStartBlockNumber = block.number; //Deployment Block
        totalSupply = totalInitialSupply;
        collectionAddress = msg.sender; //Initially fees collection wallet to creator
        airdropWallet = msg.sender; //Initially airdrop wallet to creator
        balances[msg.sender] = totalInitialSupply;

        emit Transfer(address(0), msg.sender, totalInitialSupply);
    }

    function setCollectionWallet(address _newWallet) public onlyAdmin(3) {

        require(_newWallet != address(0), 'Address cannot be zero');
        collectionAddress = _newWallet;
        emit NewCollectionWallet(collectionAddress);
    }

    function setAirDropWallet(address _newWallet) public onlyAdmin(3) {

        require(_newWallet != address(0), 'Address cannot be zero');
        airdropWallet = _newWallet;
        emit NewAirdropWallet(airdropWallet);
    }

    function transfer(address _to, uint256 _value) public notFrozen(msg.sender) returns(bool) {

        require(_to != address(0), 'Address cannot be zero');
        require(_to != address(this), 'Address cannot be this contract');

        if (msg.sender == _to) return claimStake();

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);

        if (staked[msg.sender] != 0) staked[msg.sender] = 0;
        uint64 _now = uint64(now);
        lastTransfer[msg.sender] = transferInStruct(uint128(balances[msg.sender]), _now);

        if (uint(lastTransfer[_to].time) != 0) {
            uint nCoinSeconds = now.sub(uint(lastTransfer[_to].time));
            if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
            staked[_to] = staked[_to].add(uint(lastTransfer[_to].amount).mul(nCoinSeconds.div(1 days)));
        }
        lastTransfer[_to] = transferInStruct(uint128(balances[_to]), _now);

        return true;
    }

    function balanceOf(address _owner) public view returns(uint256 balance) {

        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public notFrozen(_from) returns(bool) {

        require(_to != address(0), 'Address cannot be zero');

        uint256 _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);

        if (staked[_from] != 0) staked[_from] = 0;
        uint64 _now = uint64(now);
        lastTransfer[_from] = transferInStruct(uint128(balances[_from]), _now);

        if (_from != _to) { //Prevent double stake

            if (uint(lastTransfer[_to].time) != 0) {
                uint nCoinSeconds = now.sub(uint(lastTransfer[_to].time));
                if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
                staked[_to] = staked[_to].add(uint(lastTransfer[_to].amount).mul(nCoinSeconds.div(1 days)));
            }

            lastTransfer[_to] = transferInStruct(uint128(balances[_to]), _now);
        }

        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function claimStake() public canPoSclaimStake returns(bool) {

        if (balances[msg.sender] <= 0) return false;

        uint reward = getProofOfStakeReward(msg.sender);

        if (totalSupply.add(reward) > maxTotalSupply) {
            reward = maxTotalSupply.sub(totalSupply);
        }

        if (reward <= 0) return false;

        totalSupply = totalSupply.add(reward);
        balances[msg.sender] = balances[msg.sender].add(reward);

        uint64 _now = uint64(now);
        staked[msg.sender] = 0;
        lastTransfer[msg.sender] = transferInStruct(uint128(balances[msg.sender]), _now);

        emit Transfer(address(0), msg.sender, reward);
        emit ClaimStake(msg.sender, reward);
        return true;
    }

    function getBlockNumber() public view returns(uint blockNumber) {

        blockNumber = block.number.sub(chainStartBlockNumber);
    }

    function coinAge() public view returns(uint myCoinAge) {

        myCoinAge = getCoinAge(msg.sender, now);
    }

    function annualInterest() public view returns(uint interest) {

        uint _now = now;
        interest = (1 * 1e15); //fallback interest
        if ((_now.sub(stakeStartTime)).div(365 days) == 0) {
            interest = (106 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 1) {
            interest = (49 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 2) {
            interest = (24 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 3) {
            interest = (13 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 4) {
            interest = (11 * 1e15);
        }
    }

    function getProofOfStakeReward(address _address) public view returns(uint) {

        require((now >= stakeStartTime) && (stakeStartTime > 0), 'Staking is not yet enabled');

        uint _now = now;
        uint _coinAge = getCoinAge(_address, _now);
        if (_coinAge <= 0) return 0;

        uint interest = (1 * 1e15); //fallback interest

        if ((_now.sub(stakeStartTime)).div(365 days) == 0) {
            interest = (106 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 1) {
            interest = (49 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 2) {
            interest = (24 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 3) {
            interest = (13 * 1e15);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 4) {
            interest = (11 * 1e15);
        }

        return (_coinAge * interest).div(365 * (10 ** uint256(decimals)));
    }

    function getCoinAge(address _address, uint _now) internal view returns(uint _coinAge) {

        _coinAge = staked[_address];
        if (uint(lastTransfer[_address].time) != 0) {
            uint nCoinSeconds = _now.sub(uint(lastTransfer[_address].time));
            if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
            _coinAge = _coinAge.add(uint(lastTransfer[_address].amount).mul(nCoinSeconds.div(1 days)));
        }
    }

    function setStakeStartTime(uint timestamp) public onlyAdmin(3) {

        require((stakeStartTime <= 0) && (timestamp >= chainStartTime), 'Wrong time set');
        stakeStartTime = timestamp;
    }

    function batchTransfer(
        address[] calldata _recipients,
        uint[] calldata _values
    )
    external
    onlyAdmin(1)
    returns(bool) {

        require(_recipients.length > 0 && _recipients.length == _values.length, 'Addresses and Values have wrong sizes');
        uint total = 0;
        for (uint i = 0; i < _values.length; i++) {
            total = total.add(_values[i]);
        }
        require(total <= balances[msg.sender], 'Not enough funds for the transaction');
        uint64 _now = uint64(now);
        for (uint j = 0; j < _recipients.length; j++) {
            balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);
            if (uint(lastTransfer[_recipients[j]].time) != 0) {
                uint nCoinSeconds = now.sub(uint(lastTransfer[_recipients[j]].time));
                if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
                staked[_recipients[j]] = staked[_recipients[j]].add(uint(lastTransfer[_recipients[j]].amount).mul(nCoinSeconds.div(1 days)));
            }
            lastTransfer[_recipients[j]] = transferInStruct(uint128(_values[j]), _now);
            emit Transfer(msg.sender, _recipients[j], _values[j]);
        }
        balances[msg.sender] = balances[msg.sender].sub(total);
        if (staked[msg.sender] != 0) staked[msg.sender] = 0;
        lastTransfer[msg.sender] = transferInStruct(uint128(balances[msg.sender]), _now);
        return true;
    }

    function dropSet(
        address[] calldata _recipients,
        uint[] calldata _values
    )
    external
    onlyAdmin(1)
    returns(bool) {

        require(_recipients.length > 0 && _recipients.length == _values.length, 'Addresses and Values have wrong sizes');

        for (uint j = 0; j < _recipients.length; j++) {
            airdrops[_recipients[j]].value = _values[j];
            airdrops[_recipients[j]].claimed = false;
        }

        return true;
    }

    function claimAirdrop() external returns(bool) {

        require(airdrops[msg.sender].claimed == false, 'Airdrop already claimed');
        require(airdrops[msg.sender].value != 0, 'No airdrop value to claim');

        uint _value = airdrops[msg.sender].value;

        airdrops[msg.sender].claimed = true;
        airdrops[msg.sender].value = 0;

        address _from = airdropWallet;
        address _to = msg.sender;
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        emit ClaimDrop(_to, _value);

        if (staked[_from] != 0) staked[_from] = 0;
        uint64 _now = uint64(now);
        lastTransfer[_from] = transferInStruct(uint128(balances[_from]), _now);

        if (_from != _to) { //Prevent double stake

            if (uint(lastTransfer[_to].time) != 0) {
                uint nCoinSeconds = now.sub(uint(lastTransfer[_to].time));
                if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
                staked[_to] = staked[_to].add(uint(lastTransfer[_to].amount).mul(nCoinSeconds.div(1 days)));
            }
            lastTransfer[_to] = transferInStruct(uint128(balances[_to]), _now);
        }

        return true;

    }

    function userFreezeBalance(bool _lock) public returns(bool) {

        userFreeze[msg.sender] = _lock;
        return userFreeze[msg.sender];
    }


    function createPaymentRequest(
        address _customer,
        uint _value,
        string calldata _description
    )
    external
    escrowIsEnabled()
    notFrozen(msg.sender)
    returns(uint) {


        require(_customer != address(0), 'Address cannot be zero');
        require(_value > 0, 'Value cannot be zero');

        payments[escrowCounter] = Payment(msg.sender, _customer, _value, _description, PaymentStatus.Requested, false);
        emit PaymentCreation(escrowCounter, msg.sender, _customer, _value, _description);

        escrowCounter = escrowCounter.add(1);
        return escrowCounter - 1;

    }

    function answerPaymentRequest(uint _orderId, bool _answer) external returns(bool) {

        Payment storage payment = payments[_orderId];

        require(payment.status == PaymentStatus.Requested, 'Ticket wrong status, expected "Requested"');
        require(payment.customer == msg.sender, 'You are not allowed to manage this ticket');

        if (_answer == true) {

            address _to = address(this);

            balances[payment.provider] = balances[payment.provider].sub(payment.value);
            balances[_to] = balances[_to].add(payment.value);
            emit Transfer(payment.provider, _to, payment.value);

            if (staked[payment.provider] != 0) staked[payment.provider] = 0;
            uint64 _now = uint64(now);
            lastTransfer[payment.provider] = transferInStruct(uint128(balances[payment.provider]), _now);

            payments[_orderId].status = PaymentStatus.Pending;

            emit PaymentUpdate(_orderId, payment.provider, payment.customer, payment.value, PaymentStatus.Pending);

        } else {

            payments[_orderId].status = PaymentStatus.Rejected;

            emit PaymentUpdate(_orderId, payment.provider, payment.customer, payment.value, PaymentStatus.Rejected);

        }

        return true;
    }


    function release(uint _orderId) external returns(bool) {

        Payment storage payment = payments[_orderId];
        require(payment.status == PaymentStatus.Pending, 'Ticket wrong status, expected "Pending"');
        require(level[msg.sender] >= 2 || msg.sender == payment.provider, 'You are not allowed to manage this ticket');
        address _from = address(this);
        address _to = payment.customer;
        uint _value = payment.value;
        uint _fee = _value.mul(escrowFeePercent).div(1000);
        _value = _value.sub(_fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        balances[_from] = balances[_from].sub(_fee);
        balances[collectionAddress] = balances[collectionAddress].add(_fee);
        emit Transfer(_from, collectionAddress, _fee);

        if (staked[_from] != 0) staked[_from] = 0;
        uint64 _now = uint64(now);
        lastTransfer[_from] = transferInStruct(uint128(balances[_from]), _now);

        if (_from != _to) { //Prevent double stake

            if (uint(lastTransfer[_to].time) != 0) {
                uint nCoinSeconds = now.sub(uint(lastTransfer[_to].time));
                if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
                staked[_to] = staked[_to].add(uint(lastTransfer[_to].amount).mul(nCoinSeconds.div(1 days)));
            }
            lastTransfer[_to] = transferInStruct(uint128(balances[_to]), _now);
        }

        if (uint(lastTransfer[collectionAddress].time) != 0) {
            uint nCoinSeconds = now.sub(uint(lastTransfer[collectionAddress].time));
            if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
            staked[collectionAddress] = staked[collectionAddress].add(uint(lastTransfer[collectionAddress].amount).mul(nCoinSeconds.div(1 days)));
        }
        lastTransfer[collectionAddress] = transferInStruct(uint128(_fee), _now);


        payment.status = PaymentStatus.Completed;
        emit PaymentUpdate(_orderId, payment.provider, payment.customer, payment.value, payment.status);

        return true;
    }

    function refund(uint _orderId) external returns(bool) {

        Payment storage payment = payments[_orderId];
        require(payment.status == PaymentStatus.Pending, 'Ticket wrong status, expected "Pending"');
        require(payment.refundApproved, 'Refund has not been approved yet');
        require(level[msg.sender] >= 2 || msg.sender == payment.provider, 'You are not allowed to manage this ticket');
        address _from = address(this);
        address _to = payment.provider;
        uint _value = payment.value;
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        
        if (staked[_from] != 0) staked[_from] = 0;
        uint64 _now = uint64(now);
        lastTransfer[_from] = transferInStruct(uint128(balances[_from]), _now);

        if (_from != _to) { //Prevent double stake

            if (uint(lastTransfer[_to].time) != 0) {
                uint nCoinSeconds = now.sub(uint(lastTransfer[_to].time));
                if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;
                staked[_to] = staked[_to].add(uint(lastTransfer[_to].amount).mul(nCoinSeconds.div(1 days)));
            }
            lastTransfer[_to] = transferInStruct(uint128(balances[_to]), _now);
        }
        
        payment.status = PaymentStatus.Refunded;
        emit PaymentUpdate(_orderId, payment.provider, payment.customer, payment.value, payment.status);

        return true;
    }

    function approveRefund(uint _orderId) external returns(bool) {

        Payment storage payment = payments[_orderId];
        require(payment.status == PaymentStatus.Pending, 'Ticket wrong status, expected "Pending"');
        require(level[msg.sender] >= 2 || msg.sender == payment.customer, 'You are not allowed to manage this ticket');
        payment.refundApproved = true;

        emit PaymentRefundApprove(_orderId, payment.provider, payment.customer, payment.refundApproved);

        return true;
    }

    function escrowLockSet(bool _lock) external onlyAdmin(3) returns(bool) {

        escrowEnabled = _lock;
        emit EscrowLock(escrowEnabled);
        return true;
    }

}