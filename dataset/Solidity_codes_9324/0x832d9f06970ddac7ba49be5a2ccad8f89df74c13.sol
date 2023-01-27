


pragma solidity ^0.7.0;

interface WorkerAuthManager {

    function authorize(address _workerAddress, address _dappAddress) external;


    function deauthorize(address _workerAddress, address _dappAddresses)
        external;


    function isAuthorized(address _workerAddress, address _dappAddress)
        external
        view
        returns (bool);


    function getOwner(address workerAddress) external view returns (address);


    event Authorization(
        address indexed user,
        address indexed worker,
        address indexed dapp
    );

    event Deauthorization(
        address indexed user,
        address indexed worker,
        address indexed dapp
    );
}// Copyright 2010 Cartesi Pte. Ltd.



pragma solidity ^0.7.0;

interface WorkerManager {

    function isAvailable(address workerAddress) external view returns (bool);


    function isPending(address workerAddress) external view returns (bool);


    function getOwner(address workerAddress) external view returns (address);


    function getUser(address workerAddress) external view returns (address);


    function isOwned(address workerAddress) external view returns (bool);


    function hire(address payable workerAddress) external payable;


    function acceptJob() external;


    function rejectJob() external payable;


    function cancelHire(address workerAddress) external;


    function retire(address payable workerAddress) external;


    function isRetired(address workerAddress) external view returns (bool);


    event JobOffer(address indexed worker, address indexed user);
    event JobAccepted(address indexed worker, address indexed user);
    event JobRejected(address indexed worker, address indexed user);
    event Retired(address indexed worker, address indexed user);
}// Copyright 2020 Cartesi Pte. Ltd.



pragma solidity ^0.7.0;


contract WorkerManagerAuthManagerImpl is WorkerManager, WorkerAuthManager {

    uint256 constant MINIMUM_FUNDING = 0.001 ether;

    uint256 constant MAXIMUM_FUNDING = 3 ether;

    enum WorkerState {Available, Pending, Owned, Retired}

    mapping(address => address payable) private userOf;

    mapping(address => WorkerState) private stateOf;

    mapping(bytes32 => bool) private permissions;

    function isAvailable(address workerAddress)
        public
        override
        view
        returns (bool)
    {

        return stateOf[workerAddress] == WorkerState.Available;
    }

    function isPending(address workerAddress)
        public
        override
        view
        returns (bool)
    {

        return stateOf[workerAddress] == WorkerState.Pending;
    }

    function getOwner(address _workerAddress)
        public
        override(WorkerManager, WorkerAuthManager)
        view
        returns (address)
    {

        return
            stateOf[_workerAddress] == WorkerState.Owned
                ? userOf[_workerAddress]
                : address(0);
    }

    function getUser(address _workerAddress)
        public
        override
        view
        returns (address)
    {

        return userOf[_workerAddress];
    }

    function isOwned(address _workerAddress)
        public
        override
        view
        returns (bool)
    {

        return stateOf[_workerAddress] == WorkerState.Owned;
    }

    function hire(address payable _workerAddress) public override payable {

        require(isAvailable(_workerAddress), "worker is not available");
        require(_workerAddress != address(0), "worker address can not be 0x0");
        require(msg.value >= MINIMUM_FUNDING, "funding below minimum");
        require(msg.value <= MAXIMUM_FUNDING, "funding above maximum");

        userOf[_workerAddress] = msg.sender;

        stateOf[_workerAddress] = WorkerState.Pending;

        _workerAddress.transfer(msg.value);

        emit JobOffer(_workerAddress, msg.sender);
    }

    function acceptJob() public override {

        require(
            stateOf[msg.sender] == WorkerState.Pending,
            "worker not is not in pending state"
        );

        stateOf[msg.sender] = WorkerState.Owned;

        emit JobAccepted(msg.sender, userOf[msg.sender]);
    }

    function rejectJob() public override payable {

        require(
            userOf[msg.sender] != address(0),
            "worker does not have a job offer"
        );

        address payable owner = userOf[msg.sender];

        userOf[msg.sender] = address(0);

        stateOf[msg.sender] = WorkerState.Available;

        owner.transfer(msg.value);

        emit JobRejected(msg.sender, userOf[msg.sender]);
    }

    function cancelHire(address _workerAddress) public override {

        require(
            userOf[_workerAddress] == msg.sender,
            "only hirer can cancel the offer"
        );

        stateOf[_workerAddress] = WorkerState.Retired;

        emit JobRejected(_workerAddress, msg.sender);
    }

    function retire(address payable _workerAddress) public override {

        require(
            stateOf[_workerAddress] == WorkerState.Owned,
            "worker not owned"
        );
        require(
            userOf[_workerAddress] == msg.sender,
            "only owner can retire worker"
        );

        stateOf[_workerAddress] = WorkerState.Retired;

        emit Retired(_workerAddress, msg.sender);
    }

    function isRetired(address _workerAddress)
        public
        override
        view
        returns (bool)
    {

        return stateOf[_workerAddress] == WorkerState.Retired;
    }

    modifier onlyByUser(address _workerAddress) {

        require(
            getUser(_workerAddress) == msg.sender,
            "worker not hired by sender"
        );
        _;
    }

    function getAuthorizationKey(
        address _user,
        address _worker,
        address _dapp
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_user, _worker, _dapp));
    }

    function authorize(address _workerAddress, address _dappAddress)
        public
        override
        onlyByUser(_workerAddress)
    {

        bytes32 key = getAuthorizationKey(
            msg.sender,
            _workerAddress,
            _dappAddress
        );
        require(permissions[key] == false, "dapp already authorized");

        permissions[key] = true;

        emit Authorization(msg.sender, _workerAddress, _dappAddress);
    }

    function deauthorize(address _workerAddress, address _dappAddress)
        public
        override
        onlyByUser(_workerAddress)
    {

        bytes32 key = getAuthorizationKey(
            msg.sender,
            _workerAddress,
            _dappAddress
        );
        require(permissions[key] == true, "dapp not authorized");

        permissions[key] = false;

        emit Deauthorization(msg.sender, _workerAddress, _dappAddress);
    }

    function isAuthorized(address _workerAddress, address _dappAddress)
        public
        override
        view
        returns (bool)
    {

        return
            permissions[getAuthorizationKey(
                getOwner(_workerAddress),
                _workerAddress,
                _dappAddress
            )];
    }

    function hireAndAuthorize(
        address payable _workerAddress,
        address _dappAddress
    ) public payable {

        hire(_workerAddress);
        authorize(_workerAddress, _dappAddress);
    }
}