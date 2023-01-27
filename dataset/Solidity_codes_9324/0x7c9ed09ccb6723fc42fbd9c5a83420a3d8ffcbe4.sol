
pragma solidity ^0.5.1;

contract Earth {




    constructor() public {}

    event CreateID(
        bytes32 indexed name,
        address primary,
        address recovery,
        uint64 number
    );

    event SetPrimary(
        bytes32 indexed name,
        address primary
    );

    event SetRecovery(
        bytes32 indexed name,
        address recovery
    );

    event Recover(
        bytes32 indexed name,
        address primary,
        address recovery
    );

    struct ID {
        address primary;
        address recovery;
        uint64 joined;
        uint64 number;
    }


    

    mapping(address => bytes32) public associate;

    mapping(address => bytes32) public directory;

    mapping(uint64 => bytes32) public index;

    mapping(bytes32 => ID) public citizens;

    uint64 public population;




    function getPrimary(bytes32 name) public view returns (address) {

        return citizens[name].primary;
    }

    function getRecovery(bytes32 name) public view returns (address) {

        return citizens[name].recovery;
    }

    function getJoined(bytes32 name) public view returns (uint64) {

        return citizens[name].joined;
    }

    function getNumber(bytes32 name) public view returns (uint64) {

        return citizens[name].number;
    }

    function addressAvailable(address addr) public view returns (bool) {

        return associate[addr] == bytes32(0x0);
    }

    function nameAvailable(bytes32 name) public view returns (bool) {

        return getPrimary(name) == address(0x0);
    }

    function lookupNumber(uint64 number) public view returns (address, address, uint64, bytes32) {

        bytes32 name = index[number];
        ID storage id = citizens[name];
        return (id.primary, id.recovery, id.joined, name);
    }

    function authorize() public view returns (bytes32) {


        bytes32 name = directory[msg.sender];

        require(name != bytes32(0x0));

        return name;
    }


    

    function createID(bytes32 name, address recovery) public {

        
        require(name != bytes32(0x0));

        require(nameAvailable(name));

        require(addressAvailable(msg.sender));

        require(recovery != msg.sender);

        if (recovery != address(0x0)) { 
            require(addressAvailable(recovery));
            associate[recovery] = name;
        }

        associate[msg.sender] = name;
        directory[msg.sender] = name;

        population += 1;

        citizens[name] = ID({
            primary: msg.sender,
            recovery: recovery,
            joined: uint64(now),
            number: population
        });

        index[population] = name;

        emit CreateID(name, msg.sender, recovery, population);
    }

    function setPrimary(bytes32 name, address primary) public {

        
        ID storage id = citizens[name];

        require(id.primary == msg.sender);

        require(primary != address(0x0));

        require(addressAvailable(primary));

        associate[primary] = name;
        directory[primary] = name;

        directory[msg.sender] = bytes32(0x0);

        id.primary = primary;
        
        emit SetPrimary(name, primary);
    }

    function setRecovery(bytes32 name, address recovery) public {

        
        ID storage id = citizens[name];
        
        require(id.primary == msg.sender);

        require(recovery != address(0x0));
        
        require(id.recovery == address(0x0));

        require(addressAvailable(recovery));
        
        associate[recovery] = name;
        
        id.recovery = recovery;

        emit SetRecovery(name, recovery);
    }

    function recover(bytes32 name, address newRecovery) public {


        ID storage id = citizens[name];

        require(id.recovery == msg.sender);
        
        if (newRecovery != address(0x0)) {
            require(addressAvailable(newRecovery));
            associate[newRecovery] = name;
        }

        id.recovery = newRecovery;

        directory[id.primary] = bytes32(0x0);

        directory[msg.sender] = name;
        id.primary = msg.sender;

        emit Recover(name, msg.sender, newRecovery);
    }
}