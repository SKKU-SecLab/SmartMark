pragma solidity 0.6.12;


interface IOwner {

    function setFactories(address _rfactory, address _sfactory, address _tfactory) external;

    function setArbitrator(address _arb) external;

    function setFeeInfo(address _feeToken, address _feeDistro) external;

    function updateFeeInfo(address _feeToken, bool _active) external;

    function shutdownSystem() external;

    function isShutdown() external view returns(bool);

    function poolLength() external view returns(uint256);

    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);

    function setVoteDelegate(address _voteDelegate) external;

    function setFeeManager(address _feeM) external;

    function setOwner(address _owner) external;


    function setDistribution(address _distributor, address _rewardDeposit, address _treasury) external;

    function setExtraReward(address _token, uint256 _option) external;


    function setExtraReward(address _token) external;

    function setRewardHook(address _hook) external;


    function setImplementation(address _v1, address _v2, address _v3) external;


    function revertControl() external;

}

contract BoosterOwner{


    address public immutable poolManager;
    address public immutable booster;
    address public immutable stashFactory;
    address public immutable rescueStash;
    address public owner;
    address public pendingowner;
    bool public isSealed;

    uint256 public constant FORCE_DELAY = 30 days;

    bool public isForceTimerStarted;
    uint256 public forceTimestamp;

    event ShutdownStarted(uint256 executableTimestamp);
    event ShutdownExecuted();
    event TransferOwnership(address pendingOwner);
    event AcceptedOwnership(address newOwner);
    event OwnershipSealed();

    constructor(
        address _owner,
        address _poolManager,
        address _booster,
        address _stashFactory,
        address _rescueStash,
        bool _seal
    ) public {
        owner = _owner;
        poolManager = _poolManager;
        booster = _booster;
        stashFactory = _stashFactory;
        rescueStash = _rescueStash;
        isSealed = _seal;
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "!owner");
        _;
    }

    function transferOwnership(address _owner) external onlyOwner{

        pendingowner = _owner;
        emit TransferOwnership(_owner);
    }

    function acceptOwnership() external {

        require(pendingowner == msg.sender, "!pendingowner");
        owner = pendingowner;
        pendingowner = address(0);
        emit AcceptedOwnership(owner);
    }

    function sealOwnership() external onlyOwner{

        isSealed = true;
        emit OwnershipSealed();
    }

    function setBoosterOwner() external onlyOwner{

        require(!isSealed, "ownership sealed");

        IOwner(booster).setOwner(owner);
    }

    function setFactories(address _rfactory, address _sfactory, address _tfactory) external onlyOwner{

        IOwner(booster).setFactories(_rfactory, _sfactory, _tfactory);
    }

    function setArbitrator(address _arb) external onlyOwner{

        IOwner(booster).setArbitrator(_arb);
    }

    function setFeeInfo(address _feeToken, address _feeDistro) external onlyOwner{

        IOwner(booster).setFeeInfo(_feeToken, _feeDistro);
    }

    function updateFeeInfo(address _feeToken, bool _active) external onlyOwner{

        IOwner(booster).updateFeeInfo(_feeToken, _active);
    }

    function setFeeManager(address _feeM) external onlyOwner{

        IOwner(booster).setFeeManager(_feeM);
    }

    function setVoteDelegate(address _voteDelegate) external onlyOwner{

        IOwner(booster).setVoteDelegate(_voteDelegate);
    }

    function shutdownSystem() external onlyOwner{

        require(IOwner(poolManager).isShutdown(),"!poolMgrShutdown");

        uint256 poolCount = IOwner(booster).poolLength();
        for(uint256 i = 0; i < poolCount; i++){
            (,,,,,bool isshutdown) = IOwner(booster).poolInfo(i);
            require(isshutdown, "!poolShutdown");
        }

        IOwner(booster).shutdownSystem();
        emit ShutdownExecuted();
    }


    function queueForceShutdown() external onlyOwner{

        require(IOwner(poolManager).isShutdown(),"!poolMgrShutdown");
        require(!isForceTimerStarted, "already started");
    
        isForceTimerStarted = true;
        forceTimestamp = block.timestamp + FORCE_DELAY;

        emit ShutdownStarted(forceTimestamp);
    }

    function forceShutdownSystem() external onlyOwner{

        require(isForceTimerStarted, "!timer start");
        require(block.timestamp > forceTimestamp, "!timer finish");

        IOwner(booster).shutdownSystem();
        emit ShutdownExecuted();
    }


    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {

        require(_to != booster, "!invalid target");

        (bool success, bytes memory result) = _to.call{value:_value}(_data);

        return (success, result);
    }



    function setRescueTokenDistribution(address _distributor, address _rewardDeposit, address _treasury) external onlyOwner{

        IOwner(rescueStash).setDistribution(_distributor, _rewardDeposit, _treasury);
    }

    function setRescueTokenReward(address _token, uint256 _option) external onlyOwner{

        IOwner(rescueStash).setExtraReward(_token, _option);
    }

    function setStashExtraReward(address _stash, address _token) external onlyOwner{

        IOwner(_stash).setExtraReward(_token);
    }

    function setStashRewardHook(address _stash, address _hook) external onlyOwner{

        IOwner(_stash).setRewardHook(_hook);
    }

    function setStashFactoryImplementation(address _v1, address _v2, address _v3) external onlyOwner{

        IOwner(stashFactory).setImplementation(_v1, _v2, _v3);
    }
}