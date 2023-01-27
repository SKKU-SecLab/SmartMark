pragma solidity ^0.5.0;

contract Ownable {

    address public owner;
    address public newOwner;

    address[] internal controllers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }
   
    modifier onlyController() {

        require(isController(msg.sender), "only Controller");
        _;
    }

    modifier onlyOwnerOrController() {

        require(msg.sender == owner || isController(msg.sender), "only Owner Or Controller");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "sender address must be the owner's address");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        require(address(0) != _newOwner, "new owner address must not be the owner's address");
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner, "sender address must not be the new owner's address");
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
        newOwner = address(0);
    }

    function isController(address _controller) internal view returns(bool) {

        for (uint8 index = 0; index < controllers.length; index++) {
            if (controllers[index] == _controller) {
                return true;
            }
        }
        return false;
    }

    function getControllers() public onlyOwner view returns(address[] memory) {

        return controllers;
    }

    function addController(address _controller) public onlyOwner {

        require(address(0) != _controller, "controller address must not be 0");
        require(_controller != owner, "controller address must not be the owner's address");
        for (uint8 index = 0; index < controllers.length; index++) {
            if (controllers[index] == _controller) {
                return;
            }
        }
        controllers.push(_controller);
    }

    function removeController(address _controller) public onlyOwner {

        require(address(0) != _controller, "controller address must not be 0");
        for (uint8 index = 0; index < controllers.length; index++) {
            if (controllers[index] == _controller) {
                delete controllers[index];
            }
        }
    }
}pragma solidity ^0.5.0;

contract CGCrate is  Ownable {


  address payable public officialSite;

  uint256 public startTime;

  uint256 public bountyRatio = 10 finney;

  uint256[9] public cratePrice = [20 ether, 13 ether, 6 ether, 4 ether, 3 ether, 250 finney, 50 finney, 500 finney, 50 finney ];

  uint[7] public crateSales = [12, 27, 52, 97, 25, 500, 2500];

  mapping(address => uint256) remains;

  event CrateOpen(address indexed user, uint crateType, uint256 bounty);

  constructor(address payable _officialSite, uint256 _startTime) public {
    officialSite = _officialSite;
    startTime = _startTime;
    owner = msg.sender;
  }

  function updateOfficialSite(address payable _officialSite) public onlyOwnerOrController {

    require(_officialSite != address(0));
    officialSite = _officialSite;
  }

  function updateBountyRatio(uint256 _bountyRatio) public onlyOwnerOrController {

    require(_bountyRatio != 0);
    bountyRatio = _bountyRatio;
  }

  function getCratePrices() public view returns(uint[9] memory) {

    return cratePrice;
  }

  function updateCratePrice(uint256 _type, uint256 _price) public onlyOwnerOrController {

    require(_type < 9);
    cratePrice[_type] = _price;
  }

  function getCrateSales() public view returns(uint[7] memory) {

    return crateSales;
  }

  function updateCrateSale(uint256 _type, uint256 _count) public onlyOwnerOrController {

    require(_type < 7);
    crateSales[_type] = _count;
  }

  function updateStartTime(uint256 _startTime) public onlyOwnerOrController {

    startTime = _startTime;
  }

  function openCrate(uint crateType) public payable {

    require(crateType < 9);
    require(cratePrice[crateType] == msg.value);
    require(now >= startTime);

    if(crateType< 7 && crateSales[crateType] == 0)
      revert();

    officialSite.transfer(msg.value);
    uint total = remains[msg.sender] + msg.value;
    uint bounty = total / bountyRatio;
    remains[msg.sender] = total % bountyRatio;

    if(crateType < 7)
      crateSales[crateType] --;

    emit CrateOpen(msg.sender, crateType, bounty);
  }
}