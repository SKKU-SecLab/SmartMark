
pragma solidity 0.5.15;

contract Lock {

    constructor (address owner, uint256 unlockTime) public payable {
        assembly {
            sstore(0x00, owner)
            sstore(0x01, unlockTime)
        }
    }

    function () external payable {
        assembly {
            switch gt(timestamp, sload(0x01))
            case 0 { revert(0, 0) }
            case 1 {
                switch call(gas, sload(0x00), balance(address), 0, 0, 0, 0)
                case 0 { revert(0, 0) }
            }
        }
    }
}

contract Lockdrop {

    uint256 constant public LOCK_DROP_PERIOD = 30 days;
    uint256 public LOCK_START_TIME;
    uint256 public LOCK_END_TIME;

    event Locked(uint256 indexed eth, uint256 indexed duration, address lock, address introducer);

    constructor(uint startTime) public {
        LOCK_START_TIME = startTime;
        LOCK_END_TIME = startTime + LOCK_DROP_PERIOD;
    }

    function lock(uint256 _days, address _introducer)
        external
        payable
        didStart
        didNotEnd
    {

        require(msg.sender == tx.origin);

        require(_days == 30 || _days == 100 || _days == 300 || _days == 1000); 
        uint256 unlockTime = now + _days * 1 days;

        require(msg.value > 0);
        uint256 eth = msg.value;

        Lock lockAddr = (new Lock).value(eth)(msg.sender, unlockTime);

        assert(address(lockAddr).balance >= eth);

        emit Locked(eth, _days, address(lockAddr), _introducer);
    }

    modifier didStart() {

        require(now >= LOCK_START_TIME);
        _;
    }

    modifier didNotEnd() {

        require(now <= LOCK_END_TIME);
        _;
    }
}