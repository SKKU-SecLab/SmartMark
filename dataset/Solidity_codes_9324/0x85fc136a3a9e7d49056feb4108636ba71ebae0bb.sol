
pragma solidity ^0.8.10;





contract NounCaterpillarV3 {

    
    uint8 public openSlots;
    
    bytes32[] public addresses;

    mapping(bytes32 => bool) private addressMapping;

    address private owner = 0x3a6372B2013f9876a84761187d933DEe0653E377;
    address private donationWallet = 0x1D4f4dd22cB0AF859E33DEaF1FF55d9f6251C56B;

    modifier onlyOwner { 

        require(msg.sender == owner, "Not owner");
        _;
    }

    function addMeToAllowList() external {

        require(openSlots > 0, "Wait for spots to open up");
        bytes32 encoded = keccak256(abi.encodePacked(msg.sender));
        require(!addressMapping[encoded], "Already on list");
        addressMapping[encoded] = true;
        openSlots -= 1;
        addresses.push(encoded);
        delete encoded;
    }

    function giveTwoGetOne(address _giveTo) payable external { 

        bytes32 you = keccak256(abi.encodePacked(msg.sender));
        bytes32 yourFriend = keccak256(abi.encodePacked(_giveTo));
        require(!addressMapping[you], "You're already on list");
        require(!addressMapping[yourFriend], "They're already on list");
        require(msg.value == 0.01 ether, 'Wrong price');
        
        addressMapping[you] = true;
        addressMapping[yourFriend] = true;

        addresses.push(you);
        addresses.push(yourFriend);
        
        delete you;
        delete yourFriend;
    }

    function extendCaterpillar(uint8 _newSlots) external onlyOwner { 

        openSlots += _newSlots;
    }
    
    function withdraw() external payable onlyOwner { 

        payable(donationWallet).transfer(address(this).balance);
    }

}