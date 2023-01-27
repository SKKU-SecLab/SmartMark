

pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.16;



contract MultiOwnable is
    Initializable
{


    struct VoteInfo {
        uint16 votesCounter;
        uint64 curVote;
        mapping(uint => mapping (address => bool)) isVoted; // [curVote][owner]
    }


    uint public constant MIN_VOTES = 2;

    mapping(bytes => VoteInfo) public votes;
    mapping(address => bool) public  multiOwners;

    uint public multiOwnersCounter;


    event VoteForCalldata(address _owner, bytes _data);


    modifier onlyMultiOwners {

        require(multiOwners[msg.sender], "Permission denied");

        uint curVote = votes[msg.data].curVote;

        if (!votes[msg.data].isVoted[curVote][msg.sender]) {
            votes[msg.data].isVoted[curVote][msg.sender] = true;
            votes[msg.data].votesCounter++;
        }

        if (votes[msg.data].votesCounter >= MIN_VOTES ||
            votes[msg.data].votesCounter >= multiOwnersCounter
        ){
            votes[msg.data].votesCounter = 0;
            votes[msg.data].curVote++;
            _;
        } else {
            emit VoteForCalldata(msg.sender, msg.data);
        }

    }



    function initialize() public initializer {

        _addOwner(msg.sender);
    }

    function initialize(address[] memory _newOwners) public initializer {

        require(_newOwners.length > 0, "Array lengths have to be greater than zero");

        for (uint i = 0; i < _newOwners.length; i++) {
            _addOwner(_newOwners[i]);
        }
    }




    function addOwner(address _newOwner) public onlyMultiOwners {

        _addOwner(_newOwner);
    }


    function addOwners(address[] memory _newOwners) public onlyMultiOwners {

        require(_newOwners.length > 0, "Array lengths have to be greater than zero");

        for (uint i = 0; i < _newOwners.length; i++) {
            _addOwner(_newOwners[i]);
        }
    }

    function removeOwner(address _exOwner) public onlyMultiOwners {

        _removeOwner(_exOwner);
    }

    function removeOwners(address[] memory _exOwners) public onlyMultiOwners {

        require(_exOwners.length > 0, "Array lengths have to be greater than zero");

        for (uint i = 0; i < _exOwners.length; i++) {
            _removeOwner(_exOwners[i]);
        }
    }



    function _addOwner(address _newOwner) internal {

        require(!multiOwners[_newOwner], "The owner has already been added");

        multiOwners[_newOwner] = true;
        multiOwnersCounter++;
    }

    function _removeOwner(address _exOwner) internal {

        require(multiOwners[_exOwner], "This address is not the owner");
        require(multiOwnersCounter > 1, "At least one owner required");

        multiOwners[_exOwner] = false;
        multiOwnersCounter--;   // safe
    }

}


pragma solidity ^0.5.16;


interface IAdminUpgradeabilityProxy {

    function changeAdmin(address newAdmin) external;

    function upgradeTo(address newImplementation) external;

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

}


pragma solidity ^0.5.16;





contract ProxyAdminMultisig is MultiOwnable {


    constructor() public {
        address[] memory newOwners = new address[](2);
        newOwners[0] = 0xdAE0aca4B9B38199408ffaB32562Bf7B3B0495fE;
        newOwners[1] = 0xBE1A1E7304E397A765aB0837ea2f5Cb7b4ca125C;
        initialize(newOwners);
    }
    function getProxyImplementation(IAdminUpgradeabilityProxy proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(IAdminUpgradeabilityProxy proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(IAdminUpgradeabilityProxy proxy, address newAdmin) public onlyMultiOwners {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(IAdminUpgradeabilityProxy proxy, address implementation) public onlyMultiOwners {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(IAdminUpgradeabilityProxy proxy, address implementation, bytes memory data) public payable onlyMultiOwners {

        proxy.upgradeToAndCall.value(msg.value)(implementation, data);
    }
}