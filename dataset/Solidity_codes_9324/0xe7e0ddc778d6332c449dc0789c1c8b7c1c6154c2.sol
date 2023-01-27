
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketStorageInterface {


    function getDeployedStatus() external view returns (bool);


    function getGuardian() external view returns(address);

    function setGuardian(address _newAddress) external;

    function confirmGuardian() external;


    function getAddress(bytes32 _key) external view returns (address);

    function getUint(bytes32 _key) external view returns (uint);

    function getString(bytes32 _key) external view returns (string memory);

    function getBytes(bytes32 _key) external view returns (bytes memory);

    function getBool(bytes32 _key) external view returns (bool);

    function getInt(bytes32 _key) external view returns (int);

    function getBytes32(bytes32 _key) external view returns (bytes32);


    function setAddress(bytes32 _key, address _value) external;

    function setUint(bytes32 _key, uint _value) external;

    function setString(bytes32 _key, string calldata _value) external;

    function setBytes(bytes32 _key, bytes calldata _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setInt(bytes32 _key, int _value) external;

    function setBytes32(bytes32 _key, bytes32 _value) external;


    function deleteAddress(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;

    function deleteBytes32(bytes32 _key) external;


    function addUint(bytes32 _key, uint256 _amount) external;

    function subUint(bytes32 _key, uint256 _amount) external;


    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);

    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);

    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;

    function confirmWithdrawalAddress(address _nodeAddress) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



enum MinipoolDeposit {
    None,    // Marks an invalid deposit type
    Full,    // The minipool requires 32 ETH from the node operator, 16 ETH of which will be refinanced from user deposits
    Half,    // The minipool required 16 ETH from the node operator to be matched with 16 ETH from user deposits
    Empty    // The minipool requires 0 ETH from the node operator to be matched with 32 ETH from user deposits (trusted nodes only)
}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



enum MinipoolStatus {
    Initialised,    // The minipool has been initialised and is awaiting a deposit of user ETH
    Prelaunch,      // The minipool has enough ETH to begin staking and is awaiting launch by the node operator
    Staking,        // The minipool is currently staking
    Withdrawable,   // The minipool has become withdrawable on the beacon chain and can be withdrawn from by the node operator
    Dissolved       // The minipool has been dissolved and its user deposited ETH has been returned to the deposit pool
}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;





abstract contract RocketMinipoolStorageLayout {
    enum StorageState {
        Undefined,
        Uninitialised,
        Initialised
    }

    RocketStorageInterface internal rocketStorage = RocketStorageInterface(0);

    MinipoolStatus internal status;
    uint256 internal statusBlock;
    uint256 internal statusTime;
    uint256 internal withdrawalBlock;

    MinipoolDeposit internal depositType;

    address internal nodeAddress;
    uint256 internal nodeFee;
    uint256 internal nodeDepositBalance;
    bool internal nodeDepositAssigned;
    uint256 internal nodeRefundBalance;
    uint256 internal nodeSlashBalance;

    uint256 internal userDepositBalance;
    uint256 internal userDepositAssignedTime;

    bool internal useLatestDelegate = false;
    address internal rocketMinipoolDelegate;
    address internal rocketMinipoolDelegatePrev;

    address internal rocketTokenRETH;

    address internal rocketMinipoolPenalty;

    StorageState storageState = StorageState.Undefined;

    bool internal finalised;

    mapping(address => bool) memberScrubVotes;
    uint256 totalScrubVotes;
}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface DepositInterface {

    function deposit(bytes calldata _pubkey, bytes calldata _withdrawalCredentials, bytes calldata _signature, bytes32 _depositDataRoot) external payable;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketDepositPoolInterface {

    function getBalance() external view returns (uint256);

    function getExcessBalance() external view returns (uint256);

    function deposit() external payable;

    function recycleDissolvedDeposit() external payable;

    function recycleExcessCollateral() external payable;

    function recycleLiquidatedStake() external payable;

    function assignDeposits() external;

    function withdrawExcessBalance(uint256 _amount) external;

    function getUserLastDepositBlock(address _address) external view returns (uint256);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



interface RocketMinipoolInterface {

    function initialise(address _nodeAddress, MinipoolDeposit _depositType) external;

    function getStatus() external view returns (MinipoolStatus);

    function getFinalised() external view returns (bool);

    function getStatusBlock() external view returns (uint256);

    function getStatusTime() external view returns (uint256);

    function getScrubVoted(address _member) external view returns (bool);

    function getDepositType() external view returns (MinipoolDeposit);

    function getNodeAddress() external view returns (address);

    function getNodeFee() external view returns (uint256);

    function getNodeDepositBalance() external view returns (uint256);

    function getNodeRefundBalance() external view returns (uint256);

    function getNodeDepositAssigned() external view returns (bool);

    function getUserDepositBalance() external view returns (uint256);

    function getUserDepositAssigned() external view returns (bool);

    function getUserDepositAssignedTime() external view returns (uint256);

    function getTotalScrubVotes() external view returns (uint256);

    function calculateNodeShare(uint256 _balance) external view returns (uint256);

    function calculateUserShare(uint256 _balance) external view returns (uint256);

    function nodeDeposit(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot) external payable;

    function userDeposit() external payable;

    function distributeBalance() external;

    function distributeBalanceAndFinalise() external;

    function refund() external;

    function slash() external;

    function finalise() external;

    function canStake() external view returns (bool);

    function stake(bytes calldata _validatorSignature, bytes32 _depositDataRoot) external;

    function setWithdrawable() external;

    function dissolve() external;

    function close() external;

    function voteScrub() external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



interface RocketMinipoolManagerInterface {

    function getMinipoolCount() external view returns (uint256);

    function getStakingMinipoolCount() external view returns (uint256);

    function getFinalisedMinipoolCount() external view returns (uint256);

    function getActiveMinipoolCount() external view returns (uint256);

    function getMinipoolCountPerStatus(uint256 offset, uint256 limit) external view returns (uint256, uint256, uint256, uint256, uint256);

    function getPrelaunchMinipools(uint256 offset, uint256 limit) external view returns (address[] memory);

    function getMinipoolAt(uint256 _index) external view returns (address);

    function getNodeMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeActiveMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeFinalisedMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeStakingMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeMinipoolAt(address _nodeAddress, uint256 _index) external view returns (address);

    function getNodeValidatingMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeValidatingMinipoolAt(address _nodeAddress, uint256 _index) external view returns (address);

    function getMinipoolByPubkey(bytes calldata _pubkey) external view returns (address);

    function getMinipoolExists(address _minipoolAddress) external view returns (bool);

    function getMinipoolDestroyed(address _minipoolAddress) external view returns (bool);

    function getMinipoolPubkey(address _minipoolAddress) external view returns (bytes memory);

    function getMinipoolWithdrawalCredentials(address _minipoolAddress) external pure returns (bytes memory);

    function createMinipool(address _nodeAddress, MinipoolDeposit _depositType, uint256 _salt) external returns (RocketMinipoolInterface);

    function destroyMinipool() external;

    function incrementNodeStakingMinipoolCount(address _nodeAddress) external;

    function decrementNodeStakingMinipoolCount(address _nodeAddress) external;

    function incrementNodeFinalisedMinipoolCount(address _nodeAddress) external;

    function setMinipoolPubkey(bytes calldata _pubkey) external;

    function getMinipoolBytecode() external pure returns (bytes memory);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



interface RocketMinipoolQueueInterface {

    function getTotalLength() external view returns (uint256);

    function getLength(MinipoolDeposit _depositType) external view returns (uint256);

    function getTotalCapacity() external view returns (uint256);

    function getEffectiveCapacity() external view returns (uint256);

    function getNextCapacity() external view returns (uint256);

    function getNextDeposit() external view returns (MinipoolDeposit, uint256);

    function enqueueMinipool(MinipoolDeposit _depositType, address _minipool) external;

    function dequeueMinipool() external returns (address minipoolAddress);

    function dequeueMinipoolByDeposit(MinipoolDeposit _depositType) external returns (address minipoolAddress);

    function removeMinipool(MinipoolDeposit _depositType) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketMinipoolPenaltyInterface {

    function setMaxPenaltyRate(uint256 _rate) external;

    function getMaxPenaltyRate() external view returns (uint256);


    function setPenaltyRate(address _minipoolAddress, uint256 _rate) external;

    function getPenaltyRate(address _minipoolAddress) external view returns(uint256);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketNetworkPricesInterface {

    function getPricesBlock() external view returns (uint256);

    function getRPLPrice() external view returns (uint256);

    function getEffectiveRPLStake() external view returns (uint256);

    function getEffectiveRPLStakeUpdatedBlock() external view returns (uint256);

    function getLatestReportableBlock() external view returns (uint256);

    function inConsensus() external view returns (bool);

    function submitPrices(uint256 _block, uint256 _rplPrice, uint256 _effectiveRplStake) external;

    function executeUpdatePrices(uint256 _block, uint256 _rplPrice, uint256 _effectiveRplStake) external;

    function increaseEffectiveRPLStake(uint256 _amount) external;

    function decreaseEffectiveRPLStake(uint256 _amount) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;
pragma abicoder v2;


interface RocketNodeManagerInterface {


    struct TimezoneCount {
        string timezone;
        uint256 count;
    }

    function getNodeCount() external view returns (uint256);

    function getNodeCountPerTimezone(uint256 offset, uint256 limit) external view returns (TimezoneCount[] memory);

    function getNodeAt(uint256 _index) external view returns (address);

    function getNodeExists(address _nodeAddress) external view returns (bool);

    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);

    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);

    function getNodeTimezoneLocation(address _nodeAddress) external view returns (string memory);

    function registerNode(string calldata _timezoneLocation) external;

    function setTimezoneLocation(string calldata _timezoneLocation) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketNodeStakingInterface {

    function getTotalRPLStake() external view returns (uint256);

    function getNodeRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeRPLStakedTime(address _nodeAddress) external view returns (uint256);

    function getTotalEffectiveRPLStake() external view returns (uint256);

    function calculateTotalEffectiveRPLStake(uint256 offset, uint256 limit, uint256 rplPrice) external view returns (uint256);

    function getNodeEffectiveRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeMinimumRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeMaximumRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeMinipoolLimit(address _nodeAddress) external view returns (uint256);

    function stakeRPL(uint256 _amount) external;

    function withdrawRPL(uint256 _amount) external;

    function slashRPL(address _nodeAddress, uint256 _ethSlashAmount) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



interface RocketDAOProtocolSettingsMinipoolInterface {

    function getLaunchBalance() external view returns (uint256);

    function getDepositNodeAmount(MinipoolDeposit _depositType) external view returns (uint256);

    function getFullDepositNodeAmount() external view returns (uint256);

    function getHalfDepositNodeAmount() external view returns (uint256);

    function getEmptyDepositNodeAmount() external view returns (uint256);

    function getDepositUserAmount(MinipoolDeposit _depositType) external view returns (uint256);

    function getFullDepositUserAmount() external view returns (uint256);

    function getHalfDepositUserAmount() external view returns (uint256);

    function getEmptyDepositUserAmount() external view returns (uint256);

    function getSubmitWithdrawableEnabled() external view returns (bool);

    function getLaunchTimeout() external view returns (uint256);

    function getMaximumCount() external view returns (uint256);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketDAONodeTrustedSettingsMinipoolInterface {

    function getScrubPeriod() external view returns(uint256);

    function getScrubQuorum() external view returns(uint256);

    function getScrubPenaltyEnabled() external view returns(bool);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketDAOProtocolSettingsNodeInterface {

    function getRegistrationEnabled() external view returns (bool);

    function getDepositEnabled() external view returns (bool);

    function getMinimumPerMinipoolStake() external view returns (uint256);

    function getMaximumPerMinipoolStake() external view returns (uint256);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketDAONodeTrustedInterface {

    function getBootstrapModeDisabled() external view returns (bool);

    function getMemberQuorumVotesRequired() external view returns (uint256);

    function getMemberAt(uint256 _index) external view returns (address);

    function getMemberCount() external view returns (uint256);

    function getMemberMinRequired() external view returns (uint256);

    function getMemberIsValid(address _nodeAddress) external view returns (bool);

    function getMemberLastProposalTime(address _nodeAddress) external view returns (uint256);

    function getMemberID(address _nodeAddress) external view returns (string memory);

    function getMemberUrl(address _nodeAddress) external view returns (string memory);

    function getMemberJoinedTime(address _nodeAddress) external view returns (uint256);

    function getMemberProposalExecutedTime(string memory _proposalType, address _nodeAddress) external view returns (uint256);

    function getMemberRPLBondAmount(address _nodeAddress) external view returns (uint256);

    function getMemberIsChallenged(address _nodeAddress) external view returns (bool);

    function getMemberUnbondedValidatorCount(address _nodeAddress) external view returns (uint256);

    function incrementMemberUnbondedValidatorCount(address _nodeAddress) external;

    function decrementMemberUnbondedValidatorCount(address _nodeAddress) external;

    function bootstrapMember(string memory _id, string memory _url, address _nodeAddress) external;

    function bootstrapSettingUint(string memory _settingContractName, string memory _settingPath, uint256 _value) external;

    function bootstrapSettingBool(string memory _settingContractName, string memory _settingPath, bool _value) external;

    function bootstrapUpgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) external;

    function bootstrapDisable(bool _confirmDisableBootstrapMode) external;

    function memberJoinRequired(string memory _id, string memory _url) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketNetworkFeesInterface {

    function getNodeDemand() external view returns (int256);

    function getNodeFee() external view returns (uint256);

    function getNodeFeeByDemand(int256 _nodeDemand) external view returns (uint256);

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;



interface RocketTokenRETHInterface is IERC20 {

    function getEthValue(uint256 _rethAmount) external view returns (uint256);

    function getRethValue(uint256 _ethAmount) external view returns (uint256);

    function getExchangeRate() external view returns (uint256);

    function getTotalCollateral() external view returns (uint256);

    function getCollateralRate() external view returns (uint256);

    function depositExcess() external payable;

    function depositExcessCollateral() external;

    function mint(uint256 _ethAmount, address _to) external;

    function burn(uint256 _rethAmount) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;





contract RocketMinipoolDelegate is RocketMinipoolStorageLayout, RocketMinipoolInterface {


    uint8 public constant version = 2;                            // Used to identify which delegate contract each minipool is using
    uint256 constant calcBase = 1 ether;
    uint256 constant prelaunchAmount = 16 ether;                  // The amount of ETH initially deposited when minipool is created
    uint256 constant distributionCooldown = 100;                  // Number of blocks that must pass between calls to distributeBalance

    using SafeMath for uint;

    event StatusUpdated(uint8 indexed status, uint256 time);
    event ScrubVoted(address indexed member, uint256 time);
    event MinipoolScrubbed(uint256 time);
    event MinipoolPrestaked(bytes validatorPubkey, bytes validatorSignature, bytes32 depositDataRoot, uint256 amount, bytes withdrawalCredentials, uint256 time);
    event EtherDeposited(address indexed from, uint256 amount, uint256 time);
    event EtherWithdrawn(address indexed to, uint256 amount, uint256 time);
    event EtherWithdrawalProcessed(address indexed executed, uint256 nodeAmount, uint256 userAmount, uint256 totalBalance, uint256 time);

    function getStatus() override external view returns (MinipoolStatus) { return status; }

    function getFinalised() override external view returns (bool) { return finalised; }

    function getStatusBlock() override external view returns (uint256) { return statusBlock; }

    function getStatusTime() override external view returns (uint256) { return statusTime; }

    function getScrubVoted(address _member) override external view returns (bool) { return memberScrubVotes[_member]; }


    function getDepositType() override external view returns (MinipoolDeposit) { return depositType; }


    function getNodeAddress() override external view returns (address) { return nodeAddress; }

    function getNodeFee() override external view returns (uint256) { return nodeFee; }

    function getNodeDepositBalance() override external view returns (uint256) { return nodeDepositBalance; }

    function getNodeRefundBalance() override external view returns (uint256) { return nodeRefundBalance; }

    function getNodeDepositAssigned() override external view returns (bool) { return nodeDepositAssigned; }


    function getUserDepositBalance() override external view returns (uint256) { return userDepositBalance; }

    function getUserDepositAssigned() override external view returns (bool) { return userDepositAssignedTime != 0; }

    function getUserDepositAssignedTime() override external view returns (uint256) { return userDepositAssignedTime; }

    function getTotalScrubVotes() override external view returns (uint256) { return totalScrubVotes; }


    modifier onlyInitialised() {

        require(storageState == StorageState.Initialised, "Storage state not initialised");
        _;
    }

    modifier onlyUninitialised() {

        require(storageState == StorageState.Uninitialised, "Storage state already initialised");
        _;
    }

    modifier onlyMinipoolOwner(address _nodeAddress) {

        require(_nodeAddress == nodeAddress, "Invalid minipool owner");
        _;
    }

    modifier onlyMinipoolOwnerOrWithdrawalAddress(address _nodeAddress) {

        require(_nodeAddress == nodeAddress || _nodeAddress == rocketStorage.getNodeWithdrawalAddress(nodeAddress), "Invalid minipool owner");
        _;
    }

    modifier onlyLatestContract(string memory _contractName, address _contractAddress) {

        require(_contractAddress == getContractAddress(_contractName), "Invalid or outdated contract");
        _;
    }

    function getContractAddress(string memory _contractName) private view returns (address) {

        address contractAddress = rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        require(contractAddress != address(0x0), "Contract not found");
        return contractAddress;
    }

    function initialise(address _nodeAddress, MinipoolDeposit _depositType) override external onlyUninitialised {

        require(_nodeAddress != address(0x0), "Invalid node address");
        require(_depositType != MinipoolDeposit.None, "Invalid deposit type");
        RocketNetworkFeesInterface rocketNetworkFees = RocketNetworkFeesInterface(getContractAddress("rocketNetworkFees"));
        status = MinipoolStatus.Initialised;
        statusBlock = block.number;
        statusTime = block.timestamp;
        depositType = _depositType;
        nodeAddress = _nodeAddress;
        nodeFee = rocketNetworkFees.getNodeFee();
        rocketTokenRETH = getContractAddress("rocketTokenRETH");
        rocketMinipoolPenalty = getContractAddress("rocketMinipoolPenalty");
        storageState = StorageState.Initialised;
    }

    function nodeDeposit(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot) override external payable onlyLatestContract("rocketNodeDeposit", msg.sender) onlyInitialised {

        require(status == MinipoolStatus.Initialised, "The node deposit can only be assigned while initialised");
        require(!nodeDepositAssigned, "The node deposit has already been assigned");
        if (depositType == MinipoolDeposit.Full) { setStatus(MinipoolStatus.Prelaunch); }
        nodeDepositBalance = msg.value;
        nodeDepositAssigned = true;
        emit EtherDeposited(msg.sender, msg.value, block.timestamp);
        preStake(_validatorPubkey, _validatorSignature, _depositDataRoot);
    }

    function userDeposit() override external payable onlyLatestContract("rocketDepositPool", msg.sender) onlyInitialised {

        require(status >= MinipoolStatus.Initialised && status <= MinipoolStatus.Staking, "The user deposit can only be assigned while initialised, in prelaunch, or staking");
        require(userDepositAssignedTime == 0, "The user deposit has already been assigned");
        if (status == MinipoolStatus.Initialised) { setStatus(MinipoolStatus.Prelaunch); }
        userDepositBalance = msg.value;
        userDepositAssignedTime = block.timestamp;
        if (depositType == MinipoolDeposit.Full) {
            nodeDepositBalance = nodeDepositBalance.sub(msg.value);
            nodeRefundBalance = nodeRefundBalance.add(msg.value);
        }
        emit EtherDeposited(msg.sender, msg.value, block.timestamp);
    }

    function refund() override external onlyMinipoolOwnerOrWithdrawalAddress(msg.sender) onlyInitialised {

        require(nodeRefundBalance > 0, "No amount of the node deposit is available for refund");
        _refund();
    }

    function slash() external override onlyInitialised {

        require(nodeSlashBalance > 0, "No balance to slash");
        _slash();
    }

    function finalise() external override onlyInitialised onlyMinipoolOwnerOrWithdrawalAddress(msg.sender) {

        require(status == MinipoolStatus.Withdrawable, "Minipool must be withdrawable");
        require(withdrawalBlock > 0, "Minipool balance must have been distributed at least once");
        _finalise();
    }

    function canStake() override external view onlyInitialised returns (bool) {

        if (status != MinipoolStatus.Prelaunch) {
            return false;
        }
        RocketDAONodeTrustedSettingsMinipoolInterface rocketDAONodeTrustedSettingsMinipool = RocketDAONodeTrustedSettingsMinipoolInterface(getContractAddress("rocketDAONodeTrustedSettingsMinipool"));
        uint256 scrubPeriod = rocketDAONodeTrustedSettingsMinipool.getScrubPeriod();
        return block.timestamp > statusTime + scrubPeriod;
    }

    function stake(bytes calldata _validatorSignature, bytes32 _depositDataRoot) override external onlyMinipoolOwner(msg.sender) onlyInitialised {

        RocketDAONodeTrustedSettingsMinipoolInterface rocketDAONodeTrustedSettingsMinipool = RocketDAONodeTrustedSettingsMinipoolInterface(getContractAddress("rocketDAONodeTrustedSettingsMinipool"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        uint256 scrubPeriod = rocketDAONodeTrustedSettingsMinipool.getScrubPeriod();
        require(status == MinipoolStatus.Prelaunch, "The minipool can only begin staking while in prelaunch");
        require(block.timestamp > statusTime + scrubPeriod, "Not enough time has passed to stake");
        setStatus(MinipoolStatus.Staking);
        DepositInterface casperDeposit = DepositInterface(getContractAddress("casperDeposit"));
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        uint256 launchAmount = rocketDAOProtocolSettingsMinipool.getLaunchBalance().sub(prelaunchAmount);
        require(address(this).balance >= launchAmount, "Insufficient balance to begin staking");
        bytes memory validatorPubkey = rocketMinipoolManager.getMinipoolPubkey(address(this));
        casperDeposit.deposit{value : launchAmount}(validatorPubkey, rocketMinipoolManager.getMinipoolWithdrawalCredentials(address(this)), _validatorSignature, _depositDataRoot);
        rocketMinipoolManager.incrementNodeStakingMinipoolCount(nodeAddress);
    }

    function preStake(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot) internal {

        DepositInterface casperDeposit = DepositInterface(getContractAddress("casperDeposit"));
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        require(address(this).balance >= prelaunchAmount, "Insufficient balance to pre-stake");
        require(rocketMinipoolManager.getMinipoolByPubkey(_validatorPubkey) == address(0x0), "Validator pubkey is in use");
        rocketMinipoolManager.setMinipoolPubkey(_validatorPubkey);
        bytes memory withdrawalCredentials = rocketMinipoolManager.getMinipoolWithdrawalCredentials(address(this));
        casperDeposit.deposit{value : prelaunchAmount}(_validatorPubkey, withdrawalCredentials, _validatorSignature, _depositDataRoot);
        emit MinipoolPrestaked(_validatorPubkey, _validatorSignature, _depositDataRoot, prelaunchAmount, withdrawalCredentials, block.timestamp);
    }

    function setWithdrawable() override external onlyLatestContract("rocketMinipoolStatus", msg.sender) onlyInitialised {

        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        require(status == MinipoolStatus.Staking, "The minipool can only become withdrawable while staking");
        setStatus(MinipoolStatus.Withdrawable);
        if (userDepositAssignedTime == 0) {
            RocketMinipoolQueueInterface rocketMinipoolQueue = RocketMinipoolQueueInterface(getContractAddress("rocketMinipoolQueue"));
            rocketMinipoolQueue.removeMinipool(depositType);
        }
        rocketMinipoolManager.decrementNodeStakingMinipoolCount(nodeAddress);
    }

    function distributeBalanceAndFinalise() override external onlyInitialised onlyMinipoolOwnerOrWithdrawalAddress(msg.sender) {

        require(status == MinipoolStatus.Withdrawable, "Minipool must be withdrawable");
        uint256 totalBalance = address(this).balance.sub(nodeRefundBalance);
        _distributeBalance(totalBalance);
        _finalise();
    }

    function distributeBalance() override external onlyInitialised {

        require(status == MinipoolStatus.Staking || status == MinipoolStatus.Withdrawable, "Minipool must be staking or withdrawable");
        uint256 totalBalance = address(this).balance.sub(nodeRefundBalance);
        address nodeWithdrawalAddress = rocketStorage.getNodeWithdrawalAddress(nodeAddress);
        if (msg.sender != nodeAddress && msg.sender != nodeWithdrawalAddress) {
            if (status == MinipoolStatus.Staking) {
                require(totalBalance >= 16 ether, "Balance must be greater than 16 ETH");
            } else {
                require(block.timestamp > statusTime.add(14 days), "Non-owner must wait 14 days after withdrawal to distribute balance");
                require(address(this).balance >= 4 ether, "Balance must be greater than 4 ETH");
            }
        }
        _distributeBalance(totalBalance);
    }

    function _finalise() private {

        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        require(!finalised, "Minipool has already been finalised");
        if (nodeSlashBalance > 0) {
            _slash();
        }
        if (nodeRefundBalance > 0) {
            _refund();
        }
        if (address(this).balance > 0) {
            payable(rocketTokenRETH).transfer(address(this).balance);
        }
        RocketTokenRETHInterface(rocketTokenRETH).depositExcessCollateral();
        rocketMinipoolManager.incrementNodeFinalisedMinipoolCount(nodeAddress);
        if (depositType == MinipoolDeposit.Empty) {
            RocketDAONodeTrustedInterface rocketDAONodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
            rocketDAONodeTrusted.decrementMemberUnbondedValidatorCount(nodeAddress);
        }
        finalised = true;
    }

    function _distributeBalance(uint256 _balance) private {

        require(block.number > withdrawalBlock + distributionCooldown, "Distribution of this minipool's balance is on cooldown");
        uint256 nodeAmount = 0;
        if (_balance < userDepositBalance) {
            if (withdrawalBlock == 0) {
                nodeSlashBalance = userDepositBalance.sub(_balance);
            }
        } else {
            nodeAmount = calculateNodeShare(_balance);
        }
        uint256 userAmount = _balance.sub(nodeAmount);
        nodeRefundBalance = nodeRefundBalance.add(nodeAmount);
        if (userAmount > 0) {
            payable(rocketTokenRETH).transfer(userAmount);
        }
        withdrawalBlock = block.number;
        emit EtherWithdrawalProcessed(msg.sender, nodeAmount, userAmount, _balance, block.timestamp);
    }

    function calculateNodeShare(uint256 _balance) override public view returns (uint256) {

        uint256 stakingDepositTotal = 32 ether;
        uint256 userAmount = userDepositBalance;
        if (userAmount > _balance) {
            return 0;
        }
        if (_balance > stakingDepositTotal) {
            uint256 totalRewards = _balance.sub(stakingDepositTotal);
            uint256 halfRewards = totalRewards.div(2);
            uint256 nodeCommissionFee = halfRewards.mul(nodeFee).div(1 ether);
            if (depositType == MinipoolDeposit.Empty) {
                userAmount = userAmount.add(totalRewards.sub(nodeCommissionFee));
            } else {
                userAmount = userAmount.add(halfRewards.sub(nodeCommissionFee));
            }
        }
        uint256 nodeAmount = _balance.sub(userAmount);
        uint256 penaltyRate = RocketMinipoolPenaltyInterface(rocketMinipoolPenalty).getPenaltyRate(address(this));
        if (penaltyRate > 0) {
            uint256 penaltyAmount = nodeAmount.mul(penaltyRate).div(calcBase);
            if (penaltyAmount > nodeAmount) {
                penaltyAmount = nodeAmount;
            }
            nodeAmount = nodeAmount.sub(penaltyAmount);
        }
        return nodeAmount;
    }

    function calculateUserShare(uint256 _balance) override external view returns (uint256) {

        return _balance.sub(calculateNodeShare(_balance));
    }

    function dissolve() override external onlyInitialised {

        require(status == MinipoolStatus.Initialised || status == MinipoolStatus.Prelaunch, "The minipool can only be dissolved while initialised or in prelaunch");
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        require(
            (status == MinipoolStatus.Prelaunch && block.timestamp.sub(statusTime) >= rocketDAOProtocolSettingsMinipool.getLaunchTimeout()),
            "The minipool can only be dissolved once it has timed out"
        );
        _dissolve();
    }

    function close() override external onlyMinipoolOwner(msg.sender) onlyInitialised {

        require(status == MinipoolStatus.Dissolved, "The minipool can only be closed while dissolved");
        uint256 nodeBalance = nodeDepositBalance.add(nodeRefundBalance);
        if (nodeBalance > 0) {
            nodeDepositBalance = 0;
            nodeRefundBalance = 0;
            address nodeWithdrawalAddress = rocketStorage.getNodeWithdrawalAddress(nodeAddress);
            (bool success,) = nodeWithdrawalAddress.call{value : nodeBalance}("");
            require(success, "Node ETH balance was not successfully transferred to node operator");
            emit EtherWithdrawn(nodeWithdrawalAddress, nodeBalance, block.timestamp);
        }
        if (depositType == MinipoolDeposit.Empty) {
            RocketDAONodeTrustedInterface rocketDAONodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
            rocketDAONodeTrusted.decrementMemberUnbondedValidatorCount(nodeAddress);
        }
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        rocketMinipoolManager.destroyMinipool();
        selfdestruct(payable(rocketTokenRETH));
    }

    function voteScrub() override external onlyInitialised {

        require(status == MinipoolStatus.Prelaunch, "The minipool can only be scrubbed while in prelaunch");
        RocketDAONodeTrustedInterface rocketDAONode = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
        RocketDAONodeTrustedSettingsMinipoolInterface rocketDAONodeTrustedSettingsMinipool = RocketDAONodeTrustedSettingsMinipoolInterface(getContractAddress("rocketDAONodeTrustedSettingsMinipool"));
        require(rocketDAONode.getMemberIsValid(msg.sender), "Not a trusted member");
        require(!memberScrubVotes[msg.sender], "Member has already voted to scrub");
        memberScrubVotes[msg.sender] = true;
        emit ScrubVoted(msg.sender, block.timestamp);
        uint256 quorum = rocketDAONode.getMemberCount().mul(rocketDAONodeTrustedSettingsMinipool.getScrubQuorum()).div(calcBase);
        if (totalScrubVotes.add(1) > quorum) {
            _dissolve();
            if (rocketDAONodeTrustedSettingsMinipool.getScrubPenaltyEnabled()){
                RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(getContractAddress("rocketNodeStaking"));
                RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
                RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
                rocketNodeStaking.slashRPL(nodeAddress, rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
                .mul(rocketDAOProtocolSettingsNode.getMinimumPerMinipoolStake())
                .div(calcBase)
                );
            }
            emit MinipoolScrubbed(block.timestamp);
        } else {
            totalScrubVotes = totalScrubVotes.add(1);
        }
    }

    function setStatus(MinipoolStatus _status) private {

        status = _status;
        statusBlock = block.number;
        statusTime = block.timestamp;
        emit StatusUpdated(uint8(_status), block.timestamp);
    }

    function _refund() private {

        uint256 refundAmount = nodeRefundBalance;
        nodeRefundBalance = 0;
        address nodeWithdrawalAddress = rocketStorage.getNodeWithdrawalAddress(nodeAddress);
        (bool success,) = nodeWithdrawalAddress.call{value : refundAmount}("");
        require(success, "ETH refund amount was not successfully transferred to node operator");
        emit EtherWithdrawn(nodeWithdrawalAddress, refundAmount, block.timestamp);
    }

    function _slash() private {

        RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(getContractAddress("rocketNodeStaking"));
        uint256 slashAmount = nodeSlashBalance;
        nodeSlashBalance = 0;
        rocketNodeStaking.slashRPL(nodeAddress, slashAmount);
    }

    function _dissolve() private {

        RocketDepositPoolInterface rocketDepositPool = RocketDepositPoolInterface(getContractAddress("rocketDepositPool"));
        RocketMinipoolQueueInterface rocketMinipoolQueue = RocketMinipoolQueueInterface(getContractAddress("rocketMinipoolQueue"));
        setStatus(MinipoolStatus.Dissolved);
        if (userDepositBalance > 0) {
            uint256 recycleAmount = userDepositBalance;
            userDepositBalance = 0;
            userDepositAssignedTime = 0;
            rocketDepositPool.recycleDissolvedDeposit{value : recycleAmount}();
            emit EtherWithdrawn(address(rocketDepositPool), recycleAmount, block.timestamp);
        } else {
            rocketMinipoolQueue.removeMinipool(depositType);
        }
    }
}