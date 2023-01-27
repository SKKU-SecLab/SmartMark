


pragma solidity >=0.7.0 <0.9.0;

interface IPoS {

    function produceBlock(uint256 _index) external returns (bool);


    function getRewardManagerAddress(uint256 _index)
        external
        view
        returns (address);


    function getBlockSelectorAddress(uint256 _index)
        external
        view
        returns (address);


    function getBlockSelectorIndex(uint256 _index)
        external
        view
        returns (uint256);


    function getStakingAddress(uint256 _index) external view returns (address);


    function getState(uint256 _index, address _user)
        external
        view
        returns (
            bool,
            address,
            uint256
        );


    function terminate(uint256 _index) external;

}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0 <0.9.0;

interface IRewardManager {

    function reward(address _address, uint256 _amount) external;


    function getBalance() external view returns (uint256);


    function getCurrentReward() external view returns (uint256);

}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0 <0.9.0;

interface IStaking {

    function getStakedBalance(address _userAddress)
        external
        view
        returns (uint256);


    function getMaturingTimestamp(address _userAddress)
        external
        view
        returns (uint256);


    function getReleasingTimestamp(address _userAddress)
        external
        view
        returns (uint256);


    function getMaturingBalance(address _userAddress)
        external
        view
        returns (uint256);


    function getReleasingBalance(address _userAddress)
        external
        view
        returns (uint256);


    function stake(uint256 _amount) external;


    function unstake(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    event Stake(address indexed user, uint256 amount, uint256 maturationDate);

    event Unstake(address indexed user, uint256 amount, uint256 maturationDate);

    event Withdraw(address indexed user, uint256 amount);
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0 <0.9.0;

interface IWorkerManagerAuthManager {

    function hire(address payable workerAddress) external payable;


    function cancelHire(address workerAddress) external;


    function retire(address payable workerAddress) external;


    function authorize(address _workerAddress, address _dappAddress) external;


    function acceptJob() external;


    function rejectJob() external payable;

}pragma solidity >=0.8.4;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external virtual;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external virtual;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external virtual returns(bytes32);

    function setResolver(bytes32 node, address resolver) external virtual;

    function setOwner(bytes32 node, address owner) external virtual;

    function setTTL(bytes32 node, uint64 ttl) external virtual;

    function setApprovalForAll(address operator, bool approved) external virtual;

    function owner(bytes32 node) external virtual view returns (address);

    function resolver(bytes32 node) external virtual view returns (address);

    function ttl(bytes32 node) external virtual view returns (uint64);

    function recordExists(bytes32 node) external virtual view returns (bool);

    function isApprovedForAll(address owner, address operator) external virtual view returns (bool);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}pragma solidity ^0.8.4;


contract Controllable is Ownable {

    mapping(address => bool) public controllers;

    event ControllerChanged(address indexed controller, bool enabled);

    modifier onlyController {

        require(
            controllers[msg.sender],
            "Controllable: Caller is not a controller"
        );
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {

        controllers[controller] = enabled;
        emit ControllerChanged(controller, enabled);
    }
}pragma solidity >=0.8.4;


abstract contract NameResolver {
    function setName(bytes32 node, string memory name) public virtual;
}

bytes32 constant lookup = 0x3031323334353637383961626364656600000000000000000000000000000000;

bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;


contract ReverseRegistrar is Ownable, Controllable {

    ENS public ens;
    NameResolver public defaultResolver;

    event ReverseClaimed(address indexed addr, bytes32 indexed node);

    constructor(ENS ensAddr, NameResolver resolverAddr) {
        ens = ensAddr;
        defaultResolver = resolverAddr;

        ReverseRegistrar oldRegistrar = ReverseRegistrar(
            ens.owner(ADDR_REVERSE_NODE)
        );
        if (address(oldRegistrar) != address(0x0)) {
            oldRegistrar.claim(msg.sender);
        }
    }

    modifier authorised(address addr) {

        require(
            addr == msg.sender ||
                controllers[msg.sender] ||
                ens.isApprovedForAll(addr, msg.sender) ||
                ownsContract(addr),
            "Caller is not a controller or authorised by address or the address itself"
        );
        _;
    }

    function claim(address owner) public returns (bytes32) {

        return _claimWithResolver(msg.sender, owner, address(0x0));
    }

    function claimForAddr(address addr, address owner)
        public
        authorised(addr)
        returns (bytes32)
    {

        return _claimWithResolver(addr, owner, address(0x0));
    }

    function claimWithResolver(address owner, address resolver)
        public
        returns (bytes32)
    {

        return _claimWithResolver(msg.sender, owner, resolver);
    }

    function claimWithResolverForAddr(
        address addr,
        address owner,
        address resolver
    ) public authorised(addr) returns (bytes32) {

        return _claimWithResolver(addr, owner, resolver);
    }

    function setName(string memory name) public returns (bytes32) {

        bytes32 node = _claimWithResolver(
            msg.sender,
            address(this),
            address(defaultResolver)
        );
        defaultResolver.setName(node, name);
        return node;
    }

    function setNameForAddr(
        address addr,
        address owner,
        string memory name
    ) public authorised(addr) returns (bytes32) {

        bytes32 node = _claimWithResolver(
            addr,
            address(this),
            address(defaultResolver)
        );
        defaultResolver.setName(node, name);
        ens.setSubnodeOwner(ADDR_REVERSE_NODE, sha3HexAddress(addr), owner);
        return node;
    }

    function node(address addr) public pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr))
            );
    }

    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {

        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }


    function _claimWithResolver(
        address addr,
        address owner,
        address resolver
    ) internal returns (bytes32) {

        bytes32 label = sha3HexAddress(addr);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentResolver = ens.resolver(node);
        bool shouldUpdateResolver = (resolver != address(0x0) &&
            resolver != currentResolver);
        address newResolver = shouldUpdateResolver ? resolver : currentResolver;

        ens.setSubnodeRecord(ADDR_REVERSE_NODE, label, owner, newResolver, 0);

        emit ReverseClaimed(addr, node);

        return node;
    }

    function ownsContract(address addr) internal view returns (bool) {

        try Ownable(addr).owner() returns (address owner) {
            return owner == msg.sender;
        } catch {
            return false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;

library WadRayMath {

    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;
    uint256 internal constant RATIO = 1e9;

    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {

        return ((WAD / 2) + (a * b)) / WAD;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 halfB = b / 2;
        return (halfB + (a * WAD)) / b;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {

        return ((RAY / 2) + (a * b)) / RAY;
    }

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 halfB = b / 2;
        return (halfB + (a * RAY)) / b;
    }

    function ray2wad(uint256 a) internal pure returns (uint256) {

        uint256 halfRatio = RATIO / 2;
        return (halfRatio + a) / RATIO;
    }

    function wad2ray(uint256 a) internal pure returns (uint256) {

        return a * RATIO;
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;



contract StakingPoolData is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable
{

    using WadRayMath for uint256;
    uint256 public shares; // total number of shares
    uint256 public amount; // amount of staked tokens (no matter where it is)
    uint256 public requiredLiquidity; // amount of required tokens for withdraw requests

    IPoS public pos;

    struct UserBalance {
        uint256 balance; // amount of free tokens belonging to this user
        uint256 shares; // amount of shares belonging to this user
        uint256 depositTimestamp; // timestamp of when user deposited for the last time
    }
    mapping(address => UserBalance) public userBalance;

    function amountToShares(uint256 _amount) public view returns (uint256) {

        if (amount == 0) {
            return _amount.wad2ray();
        }
        return _amount.wmul(shares).wdiv(amount);
    }

    function sharesToAmount(uint256 _shares) public view returns (uint256) {

        if (shares == 0) {
            return _shares.ray2wad();
        }
        return _shares.rmul(amount).rdiv(shares);
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;

interface StakingPoolManagement {

    function setName(string memory name) external;


    function pause() external;


    function unpause() external;


    event StakingPoolRenamed(string name);
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;

interface StakingPoolProducer {

    function produceBlock(uint256 _index) external returns (bool);


    event BlockProduced(uint256 reward, uint256 commission);
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;

interface StakingPoolStaking {

    function rebalance() external;


    function amounts()
        external
        view
        returns (
            uint256 stake,
            uint256 unstake,
            uint256 withdraw
        );

}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;

interface StakingPoolUser {

    function deposit(uint256 amount) external;


    function stake(uint256 amount) external;


    function unstake(uint256 shares) external;


    function withdraw(uint256 amount) external;


    function getWithdrawBalance() external returns (uint256);


    event Deposit(address indexed user, uint256 amount, uint256 stakeTimestamp);

    event Stake(address indexed user, uint256 amount, uint256 shares);

    event Unstake(address indexed user, uint256 amount, uint256 shares);

    event Withdraw(address indexed user, uint256 amount);
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;

interface StakingPoolWorker {

    function selfhire() external payable;


    function hire(address payable workerAddress) external payable;


    function cancelHire(address workerAddress) external;


    function retire(address payable workerAddress) external;

}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;


interface StakingPool is
    StakingPoolManagement,
    StakingPoolProducer,
    StakingPoolStaking,
    StakingPoolUser,
    StakingPoolWorker
{

    function initialize(address fee, address _pos) external;


    function transferOwnership(address newOwner) external;


    function update() external;

}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0;

interface StakingPoolFactory {

    function createFlatRateCommission(uint256 commission)
        external
        payable
        returns (address);


    function createGasTaxCommission(uint256 gas)
        external
        payable
        returns (address);


    function getPoS() external view returns (address _pos);


    event NewFlatRateCommissionStakingPool(address indexed pool, address fee);

    event NewGasTaxCommissionStakingPool(address indexed pool, address fee);
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;



contract StakingPoolManagementImpl is StakingPoolManagement, StakingPoolData {

    bytes32 private constant ADDR_REVERSE_NODE =
        0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    ENS public immutable ens;
    StakingPoolFactory public factory;

    constructor(address _ens) initializer {
        require(_ens != address(0), "parameter can not be zero address");
        ens = ENS(_ens);

        _pause();
    }

    function __StakingPoolManagementImpl_init() internal {

        factory = StakingPoolFactory(msg.sender);
    }

    function setName(string memory name) external override onlyOwner {

        ReverseRegistrar ensReverseRegistrar = ReverseRegistrar(
            ens.owner(ADDR_REVERSE_NODE)
        );

        ensReverseRegistrar.setName(name);

        emit StakingPoolRenamed(name);
    }

    function pause() external override onlyOwner {

        _pause();
    }

    function unpause() external override onlyOwner {

        _unpause();
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity >=0.7.0 <0.9.0;

interface Fee {

    function getCommission(uint256 posIndex, uint256 rewardAmount)
        external
        view
        returns (uint256);

}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;


contract StakingPoolProducerImpl is StakingPoolProducer, StakingPoolData {

    IERC20 public immutable ctsi;
    Fee public fee;

    constructor(address _ctsi) {
        ctsi = IERC20(_ctsi);
    }

    function __StakingPoolProducer_init(address _fee, address _pos) internal {

        fee = Fee(_fee);
        pos = IPoS(_pos);
    }

    function produceBlock(uint256 _index) external override returns (bool) {

        IRewardManager rewardManager = IRewardManager(
            pos.getRewardManagerAddress(_index)
        );

        uint256 reward = rewardManager.getCurrentReward();

        require(
            pos.produceBlock(_index),
            "StakingPoolProducerImpl: failed to produce block"
        );

        uint256 commission = fee.getCommission(_index, reward);
        require(
            commission <= reward,
            "StakingPoolProducerImpl: commission is greater than block reward"
        );

        uint256 remainingReward = reward - commission; // this is a safety check

        amount += remainingReward;

        if (commission > 0) {
            require(
                ctsi.transfer(owner(), commission),
                "StakingPoolProducerImpl: failed to transfer commission"
            );
        }

        emit BlockProduced(reward, commission);

        return true;
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;


contract StakingPoolStakingImpl is StakingPoolStaking, StakingPoolData {

    IERC20 private immutable ctsi;
    IStaking private immutable staking;

    constructor(address _ctsi, address _staking) {
        ctsi = IERC20(_ctsi);
        staking = IStaking(_staking);
    }

    function __StakingPoolStaking_init() internal {

        require(
            ctsi.approve(address(staking), type(uint256).max),
            "Failed to approve CTSI for staking contract"
        );
    }

    function rebalance() external override {

        (uint256 _stake, uint256 _unstake, uint256 _withdraw) = amounts();

        if (_stake > 0) {
            staking.stake(_stake);
        }

        if (_unstake > 0) {
            staking.unstake(_unstake);
        }

        if (_withdraw > 0) {
            staking.withdraw(_withdraw);
        }
    }

    function amounts()
        public
        view
        override
        returns (
            uint256 stake,
            uint256 unstake,
            uint256 withdraw
        )
    {

        uint256 balance = ctsi.balanceOf(address(this));

        if (balance > requiredLiquidity) {
            uint256 maturing = staking.getMaturingBalance(address(this));
            if (maturing == 0) {
                stake = balance - requiredLiquidity;
            }
        } else if (requiredLiquidity > balance) {
            uint256 missingLiquidity = requiredLiquidity - balance;

            uint256 releasing = staking.getReleasingBalance(address(this));
            if (releasing > 0) {

                uint256 timestamp = staking.getReleasingTimestamp(
                    address(this)
                );
                if (timestamp < block.timestamp) {
                    withdraw = releasing;
                }

            } else {
                unstake = missingLiquidity;
            }
        } else {
        }
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;


contract StakingPoolUserImpl is StakingPoolUser, StakingPoolData {

    IERC20 private immutable ctsi;
    uint256 public immutable lockTime;

    constructor(address _ctsi, uint256 _lockTime) {
        ctsi = IERC20(_ctsi);
        lockTime = _lockTime;
    }

    function deposit(uint256 _amount) external override whenNotPaused {

        require(
            _amount > 0,
            "StakingPoolUserImpl: amount must be greater than 0"
        );

        UserBalance storage user = userBalance[msg.sender];
        user.balance += _amount;

        user.depositTimestamp = block.timestamp;

        requiredLiquidity += _amount;

        require(
            ctsi.transferFrom(msg.sender, address(this), _amount),
            "StakingPoolUserImpl: failed to transfer tokens"
        );

        emit Deposit(msg.sender, _amount, block.timestamp + lockTime);
    }

    function stake(uint256 _amount) external override whenNotPaused {

        UserBalance storage user = userBalance[msg.sender];

        require(
            _amount > 0,
            "StakingPoolUserImpl: amount must be greater than 0"
        );
        require(
            _amount <= user.balance,
            "StakingPoolUserImpl: not enough tokens available for staking"
        );

        require(
            block.timestamp >= user.depositTimestamp + lockTime,
            "StakingPoolUserImpl: not enough time has passed since last deposit"
        );

        uint256 _shares = amountToShares(_amount);

        require(
            _shares > 0,
            "StakingPoolUserImpl: stake not enough to emit 1 share"
        );

        user.shares += _shares;
        user.balance -= _amount;

        amount += _amount;
        shares += _shares;

        requiredLiquidity -= _amount;

        emit Stake(msg.sender, _amount, _shares);
    }

    function unstake(uint256 _shares) external override {

        UserBalance storage user = userBalance[msg.sender];

        require(_shares > 0, "StakingPoolUserImpl: invalid amount of shares");

        require(
            user.shares >= _shares,
            "StakingPoolUserImpl: insufficient shares"
        );

        user.shares -= _shares;

        uint256 _amount = sharesToAmount(_shares);

        shares -= _shares;
        amount -= _amount;

        user.balance += _amount;

        requiredLiquidity += _amount;

        emit Unstake(msg.sender, _amount, _shares);
    }

    function withdraw(uint256 _amount) external override {

        UserBalance storage user = userBalance[msg.sender];

        require(
            user.balance > 0,
            "StakingPoolUserImpl: no balance to withdraw"
        );

        user.balance -= _amount; // if _amount >  user.balance this will revert

        requiredLiquidity -= _amount; // if _amount >  requiredLiquidity this will revert

        require(
            ctsi.transfer(msg.sender, _amount),
            "StakingPoolUserImpl: failed to transfer tokens"
        );

        emit Withdraw(msg.sender, _amount);
    }

    function getWithdrawBalance() external view override returns (uint256) {

        UserBalance storage user = userBalance[msg.sender];

        uint256 _amount = user.balance;

        uint256 balance = ctsi.balanceOf(address(this));

        return balance >= _amount ? _amount : balance;
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;


contract StakingPoolWorkerImpl is StakingPoolWorker, StakingPoolData {

    IWorkerManagerAuthManager immutable workerManager;

    constructor(address _workerManager) {
        require(
            _workerManager != address(0),
            "parameter can not be zero address"
        );
        workerManager = IWorkerManagerAuthManager(_workerManager);
    }

    receive() external payable {}

    function __StakingPoolWorkerImpl_update(address _pos) internal {

        workerManager.authorize(address(this), _pos);
        pos = IPoS(_pos);
    }

    function selfhire() external payable override {

        workerManager.hire{value: msg.value}(payable(address(this)));
        workerManager.authorize(address(this), address(pos));
        workerManager.acceptJob();
        payable(msg.sender).transfer(msg.value);
    }

    function hire(address payable workerAddress)
        external
        payable
        override
        onlyOwner
    {

        workerManager.hire{value: msg.value}(workerAddress);
        workerManager.authorize(workerAddress, address(pos));
    }

    function cancelHire(address workerAddress) external override onlyOwner {

        workerManager.cancelHire(workerAddress);
    }

    function retire(address payable workerAddress) external override onlyOwner {

        workerManager.retire(workerAddress);
    }
}// Copyright 2021 Cartesi Pte. Ltd.



pragma solidity ^0.8.0;


contract StakingPoolImpl is
    StakingPool,
    StakingPoolData,
    StakingPoolManagementImpl,
    StakingPoolProducerImpl,
    StakingPoolStakingImpl,
    StakingPoolUserImpl,
    StakingPoolWorkerImpl
{

    constructor(
        address _ctsi,
        address _staking,
        address _workerManager,
        address _ens,
        uint256 _stakeLock
    )
        StakingPoolManagementImpl(_ens)
        StakingPoolProducerImpl(_ctsi)
        StakingPoolStakingImpl(_ctsi, _staking)
        StakingPoolUserImpl(_ctsi, _stakeLock)
        StakingPoolWorkerImpl(_workerManager)
    {}

    function initialize(address _fee, address _pos)
        external
        override
        initializer
    {

        __Pausable_init();
        __Ownable_init();
        __StakingPoolProducer_init(_fee, _pos);
        __StakingPoolStaking_init();
        __StakingPoolManagementImpl_init();
    }

    function update() external override onlyOwner {

        address _pos = factory.getPoS();
        __StakingPoolWorkerImpl_update(_pos);
    }

    function transferOwnership(address newOwner)
        public
        override(StakingPool, OwnableUpgradeable)
    {

        OwnableUpgradeable.transferOwnership(newOwner);
    }
}