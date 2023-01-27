

pragma solidity ^0.4.20;

contract ERC223ReceivingContract {

    function tokenFallback(address _from, uint _value, bytes _data) public;

}

contract CrowdServe {

    address constant public burnAddress = 0x0;

    uint public minPreviewInterval; // This gives contributors a guaranteed minimum time to recall their funds
    uint public minContribution; // Gas required to completely end a round increases with number of contributors;
    address public producer;

    enum State {Active, Ending, Inactive}
    State public state;

    uint public previewStageEndTime;
    uint public roundEndTime;


    mapping (address => uint) private balances;
    address[] public contributors; // used in the Ending state to reset all balances
    uint private balanceResetIterator; // only used in the Ending state

    uint public totalContributed = 0;
    uint public totalRecalled = 0;
    uint public totalSupply = 0;


    event RoundBegun(string proposalString, uint previewStageEndTime, uint roundEndTime);
    event RoundEnding();
    event RoundEnded(uint amountRecalled, uint amountWithdrawn);

    event Contribution(address contributor, uint amount);
    event FundsRecalled(address contributor, uint amountBurned, uint amountReturned, string message);

    event ContributorStatement(address contributor, uint amountBurned, string message);
    event ProducerStatement(string message);


    modifier onlyProducer() {require(msg.sender == producer); _; }

    modifier onlyContributor() {require(balances[msg.sender] > 0); _; }

    modifier inState(State s) {require(state == s); _; }

    modifier notInState(State s) {require(state != s); _; }



    function CrowdServe(address _producer, uint _minPreviewInterval, uint _minContribution)
    public {

        producer = _producer;
        minPreviewInterval = _minPreviewInterval;
        minContribution = _minContribution;

        state = State.Inactive;
    }

    function getFullState()
    public
    constant
    returns (uint, uint, address, State, bool, uint, uint, uint, uint, uint)
    {

        bool inPreview = (state == State.Active &&  now < previewStageEndTime);
        return (minPreviewInterval, minContribution, producer, state, inPreview, previewStageEndTime, roundEndTime, totalContributed, totalRecalled, totalSupply);
    }

    function burn(uint amount)
    internal {

        burnAddress.transfer(amount);
    }

    function beginProjectRound(string proposalString, uint previewStageInterval, uint roundInterval)
    external
    onlyProducer()
    inState(State.Inactive) {

        require(previewStageInterval >= minPreviewInterval);
        require(previewStageInterval < roundInterval);

        state = State.Active;

        previewStageEndTime = now + previewStageInterval;
        roundEndTime = now + roundInterval;

        RoundBegun(proposalString, previewStageEndTime, roundEndTime);
    }

    function contribute()
    external
    payable
    notInState(State.Ending) {

        require(msg.value >= minContribution);

        totalSupply += msg.value;
        totalContributed += msg.value;
        if (balances[msg.sender] == 0) {
            contributors.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
        Contribution(msg.sender, msg.value);
    }

    function recall(uint recallAmount, string message)
    external
    notInState(State.Ending) {

        require(recallAmount <= balances[msg.sender]);

        balances[msg.sender] -= recallAmount;
        totalRecalled += recallAmount;
        totalSupply -= recallAmount;

        uint burnAmount;
        if (state == State.Inactive)
            burnAmount = 0;
        else if (now < previewStageEndTime)
            burnAmount = recallAmount/10;
        else
            burnAmount = recallAmount/2;
        uint returnAmount = recallAmount - burnAmount;

        burn(burnAmount);
        msg.sender.transfer(returnAmount);

        FundsRecalled(msg.sender, burnAmount, returnAmount, message);
    }

    function contributorStatement(uint burnAmount, string message)
    external
    onlyContributor()
    notInState(State.Ending) {

        require(burnAmount <= balances[msg.sender]);

        if (burnAmount > 0) {
            totalSupply -= burnAmount;
            balances[msg.sender] -= burnAmount;

            burn(burnAmount);
        }

        ContributorStatement(msg.sender, burnAmount, message);
    }

    function producerStatement(string message)
    external
    onlyProducer() {

        ProducerStatement(message);
    }

    function tryRoundEnd(uint maxLoops)
    external
    notInState(State.Inactive) {

        if (state == State.Active) {
            require(msg.sender == producer);
            require(now >= roundEndTime);

            state = State.Ending;
            RoundEnding();

            balanceResetIterator = 0;
        }
        if (state == State.Ending) {
            uint iteratorLimit = balanceResetIterator + maxLoops;
            while (balanceResetIterator < iteratorLimit && balanceResetIterator < contributors.length) {
                totalSupply -= balances[contributors[balanceResetIterator]];
                balances[contributors[balanceResetIterator]] = 0;
                balanceResetIterator ++;
            }
            if (balanceResetIterator == contributors.length) {
                assert(totalSupply == 0);
                RoundEnded(totalRecalled, this.balance);

                delete contributors;
                producer.transfer(this.balance);

                state = State.Inactive;
                totalRecalled = 0;
                totalContributed = 0;
            }
        }
    }

    event Transfer(address indexed from, address indexed to, uint value, bytes data);

    function balanceOf(address who) constant
    external
    returns (uint) {

        if (state == State.Ending)
            return 0;
        else
            return balances[who];
    }

    function transfer(address _to, uint _value, bytes _data)
    public
    notInState(State.Ending) {

        require(_value <= balances[msg.sender]);
        balances[msg.sender] -= _value;
        if (balances[_to] == 0) {
            contributors.push(_to);
        }
        balances[_to] += _value;

        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }

        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
    }

    function transfer(address _to, uint _value)
    external
    notInState(State.Ending) {

        bytes memory empty;
        transfer(_to, _value, empty);
    }
}