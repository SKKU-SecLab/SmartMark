
pragma solidity ^0.5.7;


contract Freebies
{


    address owner;
    address payable public masterAddress;

    uint public deadline;
    mapping(address => bool) gotFreebie;
    mapping(address => bool) isMakerWithFreebiePermission;
    mapping(address => address) makersDerivative;
    uint public freebie;
    uint8 public maxNumberOfFreebies;
    uint8 public numberOfGivenFreebies;

    modifier onlyByOwner() {

        require(msg.sender ==  owner);
        _;
    }

    modifier deadlineExceeded() {

        require(now > deadline);
        _;
    }

    constructor (address payable _masterAddress, uint8 _maxNumberOfFreebies, uint _deadline)
        payable
        public
    {
        owner = msg.sender;
        maxNumberOfFreebies = _maxNumberOfFreebies;
        freebie = msg.value / maxNumberOfFreebies;
        numberOfGivenFreebies = 0;
        deadline = _deadline;
        masterAddress = _masterAddress;
    }

    function createContractWithFreebie (
        bool long,
        uint256 dueDate,
        uint256 strikePrice
    )
        payable
        public
    {
        require(now < deadline);

        require(!isMakerWithFreebiePermission[msg.sender]);
        isMakerWithFreebiePermission[msg.sender] = true;

        numberOfGivenFreebies += 1;
        require(numberOfGivenFreebies <= maxNumberOfFreebies);

        Master master = Master(masterAddress);

        address newConditionalPayment = master.createConditionalPayment.value(msg.value)
        (
            msg.sender,
            long,
            dueDate,
            strikePrice
        );

        makersDerivative[msg.sender] = newConditionalPayment;
    }

    function withdrawFreebie ()
        public
    {
        require(isMakerWithFreebiePermission[msg.sender]);

        require(!gotFreebie[msg.sender]);
        gotFreebie[msg.sender] = true;

        ConditionalPayment conditionalPayment = ConditionalPayment(makersDerivative[msg.sender]);

        require(conditionalPayment.countCounterparties() > 0);

        msg.sender.transfer(freebie);
    }

    function kick (address unsuccessfulMaker)
        public
        onlyByOwner
        deadlineExceeded
    {
        ConditionalPayment conditionalPayment = ConditionalPayment(makersDerivative[unsuccessfulMaker]);

        require(conditionalPayment.countCounterparties() == 0);

        isMakerWithFreebiePermission[unsuccessfulMaker] = false;

        require(numberOfGivenFreebies > 0);
        numberOfGivenFreebies -= 1;
    }

    function withdrawUnusedFreebies ()
        public
        onlyByOwner
        deadlineExceeded
    {
        msg.sender.transfer((maxNumberOfFreebies - numberOfGivenFreebies)*freebie);
    }

}


interface Master {


  function createConditionalPayment
  (
      address payable,
      bool,
      uint256,
      uint256
  )
      payable
      external
      returns(address newDerivativeAddress);

}

interface ConditionalPayment {


  function countCounterparties() external returns(uint8);


}