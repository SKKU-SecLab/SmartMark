
pragma solidity ^0.8.0;

library EnumerableSet {


    struct AddressSet {
        address[] _values;

        mapping (address => uint256) _indexes;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            address lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return set._indexes[value] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return set._values.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize() external {
        require(_owner == address(0), "Already initialized");
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {

    function mint(address to, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

}

interface IUniswapV2Pair {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);

}
contract TokenVault {

    
    address public owner;
    address public reimbursementToken;
    address public factory;
    
    
    constructor(address _owner,address _token) {
        owner = _owner;
        reimbursementToken = _token;
        factory = msg.sender;
    }
    
    function transferToken(address to, uint256 amount) external {

        require(msg.sender == factory,"caller should be factory");
        safeTransfer(reimbursementToken, to, amount);
    }

    function withdrawTokens(uint256 amount) external {

        require(msg.sender == owner, "caller should be owner");
        uint256 available = Reimbursement(factory).getAvailableTokens(address(this));
        require(available >= amount, "not enough available tokens");
        safeTransfer(reimbursementToken, msg.sender, amount);
    }

    function rescueTokens(address someToken) external {

        require(msg.sender == owner, "caller should be owner");
        require(someToken != reimbursementToken, "Only third-party token");
        uint256 available = IBEP20(someToken).balanceOf(address(this));
        safeTransfer(someToken, msg.sender, available);
    }
    
    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

}

contract Reimbursement is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct Stake {
        uint256 startTime;  // stake start at timestamp
        uint256 amount;     // staked tokens amount
    }

    struct Setting {
        address token;  // reimbursement token
        bool isMintable; // token can be minted by this contract
        address owner;  // owner of reimbursement vault
        uint64 period;  // staking period in seconds (365 days)
        uint32 reimbursementRatio;     // the ratio of deposited amount to reimbursement amount (with 2 decimals)
        IUniswapV2Pair swapPair;   // uniswap compatible pair for token and native coin (ETH, BNB)
        bool isReversOrder; // if `true` then `token1 = token` otherwise `token0 = token`
    }

    mapping(address => Setting) public settings; // vault address (licensee address) => setting
    mapping(address => uint256) public totalReserved;    // vault address (licensee address) => total amount used for reimbursement
    mapping(address => mapping(address => uint256)) public balances;    // vault address => user address => eligible reimbursement balance
    mapping(address => mapping(address => Stake)) public staking;    // vault address => user address => Stake
    mapping(address => EnumerableSet.AddressSet) vaults;   // user address => licensee address list that user mat get reimbursement
    mapping(address => mapping(address => uint256)) licenseeFees;    // vault => contract => fee (with 2 decimals). I.e. 30 means 0.3%
    mapping(address => EnumerableSet.AddressSet) licenseeVaults;    // licensee address => list of vaults

    event StakeToken(address indexed vault, address indexed user, uint256 date, uint256 amount);
    event UnstakeToken(address indexed vault, address indexed user, uint256 date, uint256 amount);
    event SetLicenseeFee(address indexed vault, address indexed projectContract, uint256 fee);
    event VaultCreated(address indexed vault, address indexed owner, address indexed token);
    event SetVaultOwner(address indexed vault, address indexed oldOwner, address indexed newOwner);

    function setLicenseeFee(address vault, address projectContract, uint256 fee) external {

        require(settings[vault].owner == msg.sender, "Only vault owner");
        licenseeFees[vault][projectContract] = fee;
        emit SetLicenseeFee(vault, projectContract, fee);
    }

    function getLicenseeFee(address vault, address projectContract) external view returns(uint256 fee) {

        return licenseeFees[vault][projectContract];
    }

    function getLicenseeVaults(address licensee) external view returns(address[] memory vault) {

        return licenseeVaults[licensee]._values;
    }

    function getVaults(address user) external view returns(address[] memory vault) {

        return vaults[user]._values;
    }

    function getVaultsLength(address user) external view returns(uint256) {

        return vaults[user].length();
    }

    function getVault(address user, uint256 index) external view returns(address) {

        return vaults[user].at(index);
    }

    function getVaultOwner(address vault) external view returns(address) {

        return settings[vault].owner;
    }

    function setVaultOwner(address vault, address newOwner) external {

        require(msg.sender == settings[vault].owner, "caller should be owner");
        require(newOwner != address(0), "Wrong new owner address");
        emit SetVaultOwner(vault, settings[vault].owner, newOwner);
        settings[vault].owner = newOwner;
    }

    function getVaultsBalance(address user) external view returns(address[] memory vault, uint256[] memory balance) {

        vault = vaults[user]._values;
        balance = new uint256[](vault.length);
        for (uint i = 0; i < vault.length; i++) {
            balance[i] = balances[vault[i]][user];
        }
    }

    function getAvailableTokens(address vault) public view returns(uint256 available) {

        available = IBEP20(settings[vault].token).balanceOf(vault) - totalReserved[vault];
    }

    function withdrawTokens(address vault, uint256 amount) external {

        require(msg.sender == settings[vault].owner, "caller should be owner");
        uint256 available = getAvailableTokens(vault);
        require(available >= amount, "not enough available tokens");
        TokenVault(vault).transferToken(msg.sender, amount);
    }

    function stake(address vault, uint256 amount) external {

        uint256 balance = balances[vault][msg.sender];
        require(balance != 0, "No tokens for reimbursement");
        Stake storage s = staking[vault][msg.sender];
        uint256 currentStake = s.amount;
        safeTransferFrom(settings[vault].token, msg.sender, vault, amount);
        totalReserved[vault] += amount;
        if (currentStake != 0) {
            uint256 interval = block.timestamp - s.startTime;
            interval = interval * currentStake / (currentStake + amount);
            s.startTime = block.timestamp - interval;
            s.amount = currentStake + amount;
        } else {
            s.startTime = block.timestamp;
            s.amount = amount;
        }
        emit StakeToken(vault, msg.sender, block.timestamp, amount);
    }

    function unstake(address vault) external {

        Stake memory s = staking[vault][msg.sender];
        Setting memory set = settings[vault];
        uint256 amount;
        uint256 balance = balances[vault][msg.sender];
        if (set.period == 0) {
            require(balance != 0, "No reimbursement");
            amount = balance;
        } else {
            require(s.amount != 0, "No stake");
            uint256 interval = block.timestamp - s.startTime;
            amount = s.amount * 100 * interval / (set.period * set.reimbursementRatio);
        }
        delete staking[vault][msg.sender];   // remove staking record.
        if (amount > balance) amount = balance;
        balance -= amount;
        balances[vault][msg.sender] = balance;
        if (balance == 0) {
            vaults[msg.sender].remove(vault); // remove vault from vaults list where user has reimbursement tokens
        }
        if (set.isMintable) {
            totalReserved[vault] -= s.amount;
            TokenVault(vault).transferToken(msg.sender, s.amount); // withdraw staked amount
            IBEP20(set.token).mint(msg.sender, amount); // mint reimbursement token
            amount += s.amount; // total amount: rewards + staking
        } else {
            amount += s.amount; // total amount: rewards + staking
            totalReserved[vault] -= amount;
            TokenVault(vault).transferToken(msg.sender, amount); // withdraw staked amount + rewards
        }
        emit UnstakeToken(vault, msg.sender, block.timestamp, amount);
    }

    function requestReimbursement(address user, uint256 feeAmount, address vault) external returns(address licenseeAddress){

        uint256 licenseeFee = licenseeFees[vault][msg.sender];
        if (licenseeFee == 0) return address(0); // project contract not added to reimbursement
        Setting memory set = settings[vault];
        (uint256 reserve0, uint256 reserve1,) = set.swapPair.getReserves();
        if (set.isReversOrder) (reserve0, reserve1) = (reserve1, reserve0);
        uint256 amount = reserve0 * feeAmount / reserve1;

        if (!set.isMintable) {
            uint256 reserve = totalReserved[vault];
            uint256 available = IBEP20(set.token).balanceOf(vault) - reserve;
            if (available < amount) return address(0);  // not enough reimbursement tokens
            totalReserved[vault] = reserve + amount;
        }

        uint256 balance = balances[vault][user];
        if (balance == 0) vaults[user].add(vault);
        balances[vault][user] = balance + amount;
        return set.owner;
    }

    function newVault(
        address token,              // reimbursement token
        bool isMintable,            // token can be minted by this contract
        uint64 period,              // staking period in seconds (365 days)
        uint32 reimbursementRatio,   // the ratio of deposited amount to reimbursement amount (with 2 decimals). 
        address swapPair,           // uniswap compatible pair for token and native coin (ETH, BNB)
        uint32[] memory licenseeFee,         // percentage of Licensee fee (with 2 decimals). I.e. 30 means 0.3%
        address[] memory projectContract     // contract that has right to request reimbursement
    ) 
        external 
        returns(address vault) // vault - is the vault contract address where project has to transfer tokens. A licensee has to use it as Licensee ID.
    {

        if (isMintable) {
            require(msg.sender == owner(), "Only owner may add mintable token");
        }
        bool isReversOrder;
        if (IUniswapV2Pair(swapPair).token1() == token) {
            isReversOrder == true;
        } else {
            require(IUniswapV2Pair(swapPair).token0() == token, "Wrong swap pair");
        }
        vault = address(new TokenVault(msg.sender, token));
        licenseeVaults[msg.sender].add(vault);
        settings[vault] = Setting(token, isMintable, msg.sender, period, reimbursementRatio, IUniswapV2Pair(swapPair), isReversOrder);
        require(licenseeFee.length == projectContract.length, "Wrong length");
        for (uint i = 0; i < projectContract.length; i++) {
            require(licenseeFee[i] <= 10000, "Wrong fee");
            licenseeFees[vault][projectContract[i]] = licenseeFee[i];
            emit SetLicenseeFee(vault, projectContract[i], licenseeFee[i]);
        }
        emit VaultCreated(vault, msg.sender, token);
    }

    function rescueTokens(address someToken) external onlyOwner {

        uint256 available = IBEP20(someToken).balanceOf(address(this));
        safeTransfer(someToken, msg.sender, available);
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

}