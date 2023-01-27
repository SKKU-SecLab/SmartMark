
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
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




abstract contract RocketBase {

    uint256 constant calcBase = 1 ether;

    uint8 public version;

    RocketStorageInterface rocketStorage = RocketStorageInterface(0);



    modifier onlyLatestNetworkContract() {
        require(getBool(keccak256(abi.encodePacked("contract.exists", msg.sender))), "Invalid or outdated network contract");
        _;
    }

    modifier onlyLatestContract(string memory _contractName, address _contractAddress) {
        require(_contractAddress == getAddress(keccak256(abi.encodePacked("contract.address", _contractName))), "Invalid or outdated contract");
        _;
    }

    modifier onlyRegisteredNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("node.exists", _nodeAddress))), "Invalid node");
        _;
    }

    modifier onlyTrustedNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("dao.trustednodes.", "member", _nodeAddress))), "Invalid trusted node");
        _;
    }

    modifier onlyRegisteredMinipool(address _minipoolAddress) {
        require(getBool(keccak256(abi.encodePacked("minipool.exists", _minipoolAddress))), "Invalid minipool");
        _;
    }
    

    modifier onlyGuardian() {
        require(msg.sender == rocketStorage.getGuardian(), "Account is not a temporary guardian");
        _;
    }





    constructor(RocketStorageInterface _rocketStorageAddress) {
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
    }


    function getContractAddress(string memory _contractName) internal view returns (address) {
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        require(contractAddress != address(0x0), "Contract not found");
        return contractAddress;
    }


    function getContractAddressUnsafe(string memory _contractName) internal view returns (address) {
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        return contractAddress;
    }


    function getContractName(address _contractAddress) internal view returns (string memory) {
        string memory contractName = getString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
        require(bytes(contractName).length > 0, "Contract not found");
        return contractName;
    }

    function getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }





    function getAddress(bytes32 _key) internal view returns (address) { return rocketStorage.getAddress(_key); }
    function getUint(bytes32 _key) internal view returns (uint) { return rocketStorage.getUint(_key); }
    function getString(bytes32 _key) internal view returns (string memory) { return rocketStorage.getString(_key); }
    function getBytes(bytes32 _key) internal view returns (bytes memory) { return rocketStorage.getBytes(_key); }
    function getBool(bytes32 _key) internal view returns (bool) { return rocketStorage.getBool(_key); }
    function getInt(bytes32 _key) internal view returns (int) { return rocketStorage.getInt(_key); }
    function getBytes32(bytes32 _key) internal view returns (bytes32) { return rocketStorage.getBytes32(_key); }

    function setAddress(bytes32 _key, address _value) internal { rocketStorage.setAddress(_key, _value); }
    function setUint(bytes32 _key, uint _value) internal { rocketStorage.setUint(_key, _value); }
    function setString(bytes32 _key, string memory _value) internal { rocketStorage.setString(_key, _value); }
    function setBytes(bytes32 _key, bytes memory _value) internal { rocketStorage.setBytes(_key, _value); }
    function setBool(bytes32 _key, bool _value) internal { rocketStorage.setBool(_key, _value); }
    function setInt(bytes32 _key, int _value) internal { rocketStorage.setInt(_key, _value); }
    function setBytes32(bytes32 _key, bytes32 _value) internal { rocketStorage.setBytes32(_key, _value); }

    function deleteAddress(bytes32 _key) internal { rocketStorage.deleteAddress(_key); }
    function deleteUint(bytes32 _key) internal { rocketStorage.deleteUint(_key); }
    function deleteString(bytes32 _key) internal { rocketStorage.deleteString(_key); }
    function deleteBytes(bytes32 _key) internal { rocketStorage.deleteBytes(_key); }
    function deleteBool(bytes32 _key) internal { rocketStorage.deleteBool(_key); }
    function deleteInt(bytes32 _key) internal { rocketStorage.deleteInt(_key); }
    function deleteBytes32(bytes32 _key) internal { rocketStorage.deleteBytes32(_key); }

    function addUint(bytes32 _key, uint256 _amount) internal { rocketStorage.addUint(_key, _amount); }
    function subUint(bytes32 _key, uint256 _amount) internal { rocketStorage.subUint(_key, _amount); }
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


interface RocketDAOProtocolSettingsRewardsInterface {
    function setSettingRewardsClaimer(string memory _contractName, uint256 _perc) external;
    function getRewardsClaimerPerc(string memory _contractName) external view returns (uint256);
    function getRewardsClaimerPercTimeUpdated(string memory _contractName) external view returns (uint256);
    function getRewardsClaimersPercTotal() external view returns (uint256);
    function getRewardsClaimIntervalTime() external view returns (uint256);
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


interface RocketVaultInterface {
    function balanceOf(string memory _networkContractName) external view returns (uint256);
    function depositEther() external payable;
    function withdrawEther(uint256 _amount) external;
    function depositToken(string memory _networkContractName, IERC20 _tokenAddress, uint256 _amount) external;
    function withdrawToken(address _withdrawalAddress, IERC20 _tokenAddress, uint256 _amount) external;
    function balanceOfToken(string memory _networkContractName, IERC20 _tokenAddress) external view returns (uint256);
    function transferToken(string memory _networkContractName, IERC20 _tokenAddress, uint256 _amount) external;
    function burnToken(ERC20Burnable _tokenAddress, uint256 _amount) external;
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


interface AddressSetStorageInterface {
    function getCount(bytes32 _key) external view returns (uint);
    function getItem(bytes32 _key, uint _index) external view returns (address);
    function getIndexOf(bytes32 _key, address _value) external view returns (int);
    function addItem(bytes32 _key, address _value) external;
    function removeItem(bytes32 _key, address _value) external;
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





contract RocketNodeStaking is RocketBase, RocketNodeStakingInterface {

    using SafeMath for uint;

    event RPLStaked(address indexed from, uint256 amount, uint256 time);
    event RPLWithdrawn(address indexed to, uint256 amount, uint256 time);
    event RPLSlashed(address indexed node, uint256 amount, uint256 ethValue, uint256 time);

    constructor(RocketStorageInterface _rocketStorageAddress) RocketBase(_rocketStorageAddress) {
        version = 1;
    }

    function getTotalRPLStake() override external view returns (uint256) {
        return getUint(keccak256("rpl.staked.total.amount"));
    }
    function increaseTotalRPLStake(uint256 _amount) private {
        addUint(keccak256("rpl.staked.total.amount"), _amount);
    }
    function decreaseTotalRPLStake(uint256 _amount) private {
        subUint(keccak256("rpl.staked.total.amount"), _amount);
    }

    function getNodeRPLStake(address _nodeAddress) override public view returns (uint256) {
        return getUint(keccak256(abi.encodePacked("rpl.staked.node.amount", _nodeAddress)));
    }
    function increaseNodeRPLStake(address _nodeAddress, uint256 _amount) private {
        addUint(keccak256(abi.encodePacked("rpl.staked.node.amount", _nodeAddress)), _amount);
    }
    function decreaseNodeRPLStake(address _nodeAddress, uint256 _amount) private {
        subUint(keccak256(abi.encodePacked("rpl.staked.node.amount", _nodeAddress)), _amount);
    }

    function getNodeRPLStakedTime(address _nodeAddress) override public view returns (uint256) {
        return getUint(keccak256(abi.encodePacked("rpl.staked.node.time", _nodeAddress)));
    }
    function setNodeRPLStakedTime(address _nodeAddress, uint256 _time) private {
        setUint(keccak256(abi.encodePacked("rpl.staked.node.time", _nodeAddress)), _time);
    }

    function getTotalEffectiveRPLStake() override external view returns (uint256) {
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        return rocketNetworkPrices.getEffectiveRPLStake();
    }

    function calculateTotalEffectiveRPLStake(uint256 offset, uint256 limit, uint256 rplPrice) override external view returns (uint256) {
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        uint256 maxRplStakePerMinipool = rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
            .mul(rocketDAOProtocolSettingsNode.getMaximumPerMinipoolStake());
        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        bytes32 key = keccak256("nodes.index");
        uint256 totalNodes = addressSetStorage.getCount(key);
        uint256 max = offset.add(limit);
        if (max > totalNodes || limit == 0) { max = totalNodes; }
        uint256 total = 0;
        for (uint i = offset; i < max; i++){
            address nodeAddress = addressSetStorage.getItem(key, i);
            uint256 rplStake = getNodeRPLStake(nodeAddress);
            uint256 maxRplStake = maxRplStakePerMinipool.mul(rocketMinipoolManager.getNodeStakingMinipoolCount(nodeAddress)).div(rplPrice);
            if (rplStake < maxRplStake) { total = total.add(rplStake); }
            else { total = total.add(maxRplStake); }
        }
        return total;
    }

    function getNodeEffectiveRPLStake(address _nodeAddress) override external view returns (uint256) {
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        uint256 rplStake = getNodeRPLStake(_nodeAddress);
        uint256 maxRplStake = rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
            .mul(rocketDAOProtocolSettingsNode.getMaximumPerMinipoolStake())
            .mul(rocketMinipoolManager.getNodeStakingMinipoolCount(_nodeAddress))
            .div(rocketNetworkPrices.getRPLPrice());
        if (rplStake < maxRplStake) { return rplStake; }
        else { return maxRplStake; }
    }

    function getNodeMinimumRPLStake(address _nodeAddress) override external view returns (uint256) {
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        return rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
            .mul(rocketDAOProtocolSettingsNode.getMinimumPerMinipoolStake())
            .mul(rocketMinipoolManager.getNodeActiveMinipoolCount(_nodeAddress))
            .div(rocketNetworkPrices.getRPLPrice());
    }

    function getNodeMaximumRPLStake(address _nodeAddress) override public view returns (uint256) {
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        return rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
            .mul(rocketDAOProtocolSettingsNode.getMaximumPerMinipoolStake())
            .mul(rocketMinipoolManager.getNodeActiveMinipoolCount(_nodeAddress))
            .div(rocketNetworkPrices.getRPLPrice());
    }

    function getNodeMinipoolLimit(address _nodeAddress) override external view returns (uint256) {
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        return getNodeRPLStake(_nodeAddress)
            .mul(rocketNetworkPrices.getRPLPrice())
            .div(
                rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
                .mul(rocketDAOProtocolSettingsNode.getMinimumPerMinipoolStake())
            );
    }

    function stakeRPL(uint256 _amount) override external onlyLatestContract("rocketNodeStaking", address(this)) onlyRegisteredNode(msg.sender) {
        address rplTokenAddress = getContractAddress("rocketTokenRPL");
        address rocketVaultAddress = getContractAddress("rocketVault");
        IERC20 rplToken = IERC20(rplTokenAddress);
        RocketVaultInterface rocketVault = RocketVaultInterface(rocketVaultAddress);
        require(rplToken.transferFrom(msg.sender, address(this), _amount), "Could not transfer RPL to staking contract");
        require(rplToken.approve(rocketVaultAddress, _amount), "Could not approve vault RPL deposit");
        rocketVault.depositToken("rocketNodeStaking", rplToken, _amount);
        uint256 rplStake = getNodeRPLStake(msg.sender);
        increaseTotalRPLStake(_amount);
        increaseNodeRPLStake(msg.sender, _amount);
        updateTotalEffectiveRPLStake(msg.sender, rplStake, rplStake.add(_amount));
        setNodeRPLStakedTime(msg.sender, block.timestamp);
        emit RPLStaked(msg.sender, _amount, block.timestamp);
    }

    function withdrawRPL(uint256 _amount) override external onlyLatestContract("rocketNodeStaking", address(this)) onlyRegisteredNode(msg.sender) {
        RocketDAOProtocolSettingsRewardsInterface rocketDAOProtocolSettingsRewards = RocketDAOProtocolSettingsRewardsInterface(getContractAddress("rocketDAOProtocolSettingsRewards"));
        RocketVaultInterface rocketVault = RocketVaultInterface(getContractAddress("rocketVault"));
        require(block.timestamp.sub(getNodeRPLStakedTime(msg.sender)) >= rocketDAOProtocolSettingsRewards.getRewardsClaimIntervalTime(), "The withdrawal cooldown period has not passed");
        uint256 rplStake = getNodeRPLStake(msg.sender);
        require(rplStake >= _amount, "Withdrawal amount exceeds node's staked RPL balance");
        require(rplStake.sub(_amount) >= getNodeMaximumRPLStake(msg.sender), "Node's staked RPL balance after withdrawal is less than required balance");
        decreaseTotalRPLStake(_amount);
        decreaseNodeRPLStake(msg.sender, _amount);
        updateTotalEffectiveRPLStake(msg.sender, rplStake, rplStake.sub(_amount));
        rocketVault.withdrawToken(rocketStorage.getNodeWithdrawalAddress(msg.sender), IERC20(getContractAddress("rocketTokenRPL")), _amount);
        emit RPLWithdrawn(msg.sender, _amount, block.timestamp);
    }

    function updateTotalEffectiveRPLStake(address _nodeAddress, uint256 _oldStake, uint256 _newStake) private {
        RocketMinipoolManagerInterface rocketMinipoolManager = RocketMinipoolManagerInterface(getContractAddress("rocketMinipoolManager"));
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        require(rocketNetworkPrices.inConsensus(), "Network is not in consensus");
        uint256 maxRplStake = rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
            .mul(rocketDAOProtocolSettingsNode.getMaximumPerMinipoolStake())
            .mul(rocketMinipoolManager.getNodeStakingMinipoolCount(_nodeAddress))
            .div(rocketNetworkPrices.getRPLPrice());
        if (_oldStake >= maxRplStake && _newStake >= maxRplStake) {
            return;
        }
        if (_oldStake > _newStake) {
            uint256 decrease = _oldStake.sub(_newStake);
            uint256 delta = maxRplStake.sub(_newStake);
            if (decrease < delta) { delta = decrease; }
            rocketNetworkPrices.decreaseEffectiveRPLStake(delta);
            return;
        }
        if (_newStake > _oldStake) {
            uint256 increase = _newStake.sub(_oldStake);
            uint256 delta = maxRplStake.sub(_oldStake);
            if (delta > increase) { delta = increase; }
            rocketNetworkPrices.increaseEffectiveRPLStake(delta);
        }
    }

    function slashRPL(address _nodeAddress, uint256 _ethSlashAmount) override external onlyLatestContract("rocketNodeStaking", address(this)) onlyRegisteredMinipool(msg.sender) {
        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketVaultInterface rocketVault = RocketVaultInterface(getContractAddress("rocketVault"));
        uint256 rplSlashAmount = calcBase.mul(_ethSlashAmount).div(rocketNetworkPrices.getRPLPrice());
        uint256 rplStake = getNodeRPLStake(_nodeAddress);
        if (rplSlashAmount > rplStake) { rplSlashAmount = rplStake; }
        if(rplSlashAmount > 0) rocketVault.transferToken("rocketAuctionManager", IERC20(getContractAddress("rocketTokenRPL")), rplSlashAmount);
        decreaseTotalRPLStake(rplSlashAmount);
        decreaseNodeRPLStake(_nodeAddress, rplSlashAmount);
        updateTotalEffectiveRPLStake(_nodeAddress, rplStake, rplStake.sub(rplSlashAmount));
        emit RPLSlashed(_nodeAddress, rplSlashAmount, _ethSlashAmount, block.timestamp);
    }

}