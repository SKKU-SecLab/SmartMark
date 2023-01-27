

pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;



contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.15;






contract GenesisSC is Ownable {


    using SafeMath for uint256;
    using Math for uint256;
    using Address for address;

    enum States{Initializing, Staking, Validating, Finalized, Retired}

    event StakeDeposited(address indexed account, uint256 amount);
    event StakeWithdrawn(address indexed account, uint256 amount);
    event StateChanged(States fromState, States toState);

    struct StakingNode {
        bytes32 blsKeyHash;
        bytes32 elrondAddressHash;
        bool approved;
        bool exists;
    }

    struct WhitelistedAccount {
        uint256 numberOfNodes;
        uint256 amountStaked;
        StakingNode[] stakingNodes;
        bool exists;
        mapping(bytes32 => uint256) blsKeyHashToStakingNodeIndex;
    }

    struct DelegationDeposit {
        uint256 amount;
        bytes32 elrondAddressHash;
        bool exists;
    }

    uint256 public nodePrice;
    uint256 public delegationNodesLimit;
    uint256 public delegationAmountLimit;
    uint256 public currentTotalDelegated;
    address[] private _whitelistedAccountAddresses;

    ERC20Burnable public token;
    States public contractState = States.Initializing;

    mapping(address => WhitelistedAccount) private _whitelistedAccounts;
    mapping(address => DelegationDeposit) private _delegationDeposits;
    mapping (bytes32 => bool) private _approvedBlsKeyHashes;

    modifier onlyContract(address account)
    {

        require(account.isContract(), "[Validation] The address does not contain a contract");
        _;
    }

    modifier guardMaxDelegationLimit(uint256 amount)
    {

        require(amount <= (delegationAmountLimit - currentTotalDelegated), "[DepositDelegateStake] Your deposit would exceed the delegation limit");
        _;
    }

    modifier onlyWhitelistedAccounts(address who)
    {

        WhitelistedAccount memory account = _whitelistedAccounts[who];
        require(account.exists, "[Validation] The provided address is not whitelisted");
        _;
    }

    modifier onlyAccountsWithNodes()
    {

        require(_whitelistedAccounts[msg.sender].stakingNodes.length > 0, "[Validation] Your account has 0 nodes submitted");
        _;
    }

    modifier onlyNotWhitelistedAccounts(address who)
    {

        WhitelistedAccount memory account = _whitelistedAccounts[who];
        require(!account.exists, "[Validation] Address is already whitelisted");
        _;
    }

    modifier whenStaking()
    {

        require(contractState == States.Staking, "[Validation] This function can be called only when contract is in staking phase");
        _;
    }

    modifier whenInitializedAndNotValidating()
    {

        require(contractState != States.Initializing, "[Validation] This function cannot be called in the initialization phase");
        require(contractState != States.Validating, "[Validation] This function cannot be called while your submitted nodes are in the validation process");
        _;
    }

    modifier whenFinalized()
    {

        require(contractState == States.Finalized, "[Validation] This function can be called only when the contract is finalized");
        _;
    }

    modifier whenNotFinalized()
    {

        require(contractState != States.Finalized, "[Validation] This function cannot be called when the contract is finalized");
        _;
    }

    modifier whenNotRetired()
    {

        require(contractState != States.Retired, "[Validation] This function cannot be called when the contract is retired");
        _;
    }

    modifier whenRetired()
    {

        require(contractState == States.Retired, "[Validation] This function can be called only when the contract is retired");
        _;
    }

    constructor(ERC20Burnable _token, uint256 _nodePrice, uint256 _delegationNodesLimit)
    public
    {
        require(_nodePrice > 0, "[Validation] Node price must be greater than 0");

        token = _token;
        nodePrice = _nodePrice;
        delegationNodesLimit = _delegationNodesLimit;
        delegationAmountLimit = _delegationNodesLimit.mul(_nodePrice);
    }

    function submitStake(bytes32[] calldata blsKeyHashes, bytes32 elrondAddressHash)
    external
    whenStaking
    onlyWhitelistedAccounts(msg.sender)
    {

        require(elrondAddressHash != 0, "[Validation] Elrond address hash should not be 0");

        WhitelistedAccount storage whitelistedAccount = _whitelistedAccounts[msg.sender];
        _validateStakeParameters(whitelistedAccount, blsKeyHashes);
        _addStakingNodes(whitelistedAccount, blsKeyHashes, elrondAddressHash);

        uint256 transferAmount = nodePrice.mul(blsKeyHashes.length);
        require(token.transferFrom(msg.sender, address(this), transferAmount));

        whitelistedAccount.amountStaked = whitelistedAccount.amountStaked.add(transferAmount);

        emit StakeDeposited(msg.sender, transferAmount);
    }

    function withdraw()
    external
    whenInitializedAndNotValidating
    onlyWhitelistedAccounts(msg.sender)
    onlyAccountsWithNodes
    {

        uint256 totalSumToWithdraw;
        WhitelistedAccount storage account = _whitelistedAccounts[msg.sender];

        uint256 length = account.stakingNodes.length - 1;
        for (uint256 i = length; i <= length; i--) {
            StakingNode storage stakingNode = account.stakingNodes[i];
            if ((!stakingNode.exists) || (stakingNode.approved)) {
                continue;
            }

            totalSumToWithdraw = totalSumToWithdraw.add(nodePrice);

            _removeStakingNode(account, stakingNode.blsKeyHash);
        }

        if (totalSumToWithdraw == 0) {
            emit StakeWithdrawn(msg.sender, 0);
            return;
        }

        account.amountStaked = account.amountStaked.sub(totalSumToWithdraw);

        require(token.transfer(msg.sender, totalSumToWithdraw));

        emit StakeWithdrawn(msg.sender, totalSumToWithdraw);
    }

    function withdrawPerNodes(bytes32[] calldata blsKeyHashes)
    external
    whenInitializedAndNotValidating
    onlyWhitelistedAccounts(msg.sender)
    onlyAccountsWithNodes
    {

        require(blsKeyHashes.length > 0, "[Validation] You must provide at least one BLS key");

        WhitelistedAccount storage account = _whitelistedAccounts[msg.sender];
        for (uint256 i; i < blsKeyHashes.length; i++) {
            _validateBlsKeyHashForWithdrawal(account, blsKeyHashes[i]);
            _removeStakingNode(account, blsKeyHashes[i]);
        }

        uint256 totalSumToWithdraw = nodePrice.mul(blsKeyHashes.length);
        account.amountStaked = account.amountStaked.sub(totalSumToWithdraw);

        require(token.transfer(msg.sender, totalSumToWithdraw));

        emit StakeWithdrawn(msg.sender, totalSumToWithdraw);
    }

    function depositDelegateStake(uint256 amount, bytes32 elrondAddressHash)
    external
    whenStaking
    guardMaxDelegationLimit(amount)
    {

        require(amount > 0, "[Validation] The stake amount has to be larger than 0");
        require(!_delegationDeposits[msg.sender].exists, "[Validation] You already delegated a stake");

        _delegationDeposits[msg.sender] = DelegationDeposit(amount, elrondAddressHash, true);

        currentTotalDelegated = currentTotalDelegated.add(amount);

        require(token.transferFrom(msg.sender, address(this), amount));

        emit StakeDeposited(msg.sender, amount);
    }

    function increaseDelegatedAmount(uint256 amount)
    external
    whenStaking
    guardMaxDelegationLimit(amount)
    {

        require(amount > 0, "[Validation] The amount has to be larger than 0");

        DelegationDeposit storage deposit = _delegationDeposits[msg.sender];
        require(deposit.exists, "[Validation] You don't have a delegated stake");

        deposit.amount = deposit.amount.add(amount);
        currentTotalDelegated = currentTotalDelegated.add(amount);

        require(token.transferFrom(msg.sender, address(this), amount));

        emit StakeDeposited(msg.sender, amount);
    }

    function withdrawDelegatedStake(uint256 amount)
    external
    whenStaking
    {

        require(amount > 0, "[Validation] The withdraw amount has to be larger than 0");

        DelegationDeposit storage deposit = _delegationDeposits[msg.sender];
        require(deposit.exists, "[Validation] You don't have a delegated stake");
        require(amount <= deposit.amount, "[Validation] Not enough stake deposit to withdraw");

        deposit.amount = deposit.amount.sub(amount);
        currentTotalDelegated = currentTotalDelegated.sub(amount);
        require(token.transfer(msg.sender, amount));

        emit StakeWithdrawn(msg.sender, amount);
    }


    function changeStateToStaking()
    external
    onlyOwner
    whenNotRetired
    {

        emit StateChanged(contractState, States.Staking);
        contractState = States.Staking;
    }

    function changeStateToValidating()
    external
    onlyOwner
    whenStaking
    {

        emit StateChanged(contractState, States.Validating);
        contractState = States.Validating;
    }

    function changeStateToFinalized()
    external
    onlyOwner
    whenNotRetired
    {

        emit StateChanged(contractState, States.Finalized);
        contractState = States.Finalized;
    }

    function changeStateToRetired()
    external
    onlyOwner
    whenFinalized
    {

        emit StateChanged(contractState, States.Retired);
        contractState = States.Retired;
    }

    function whitelistAccount(address who, uint256 numberOfNodes)
    external
    onlyOwner
    whenNotFinalized
    whenNotRetired
    onlyNotWhitelistedAccounts(who)
    {

        WhitelistedAccount storage whitelistedAccount = _whitelistedAccounts[who];
        whitelistedAccount.numberOfNodes = numberOfNodes;
        whitelistedAccount.exists = true;

        _whitelistedAccountAddresses.push(who);
    }

    function approveBlsKeyHashes(address who, bytes32[] calldata blsHashes)
    external
    onlyOwner
    whenNotFinalized
    whenNotRetired
    onlyWhitelistedAccounts(who)
    {

        WhitelistedAccount storage whitelistedAccount = _whitelistedAccounts[who];

        for (uint256 i = 0; i < blsHashes.length; i++) {
            require(_accountHasNode(whitelistedAccount, blsHashes[i]), "[Validation] BLS key does not exist for this account");
            require(!_approvedBlsKeyHashes[blsHashes[i]], "[Validation] Provided BLS key was already approved");

            uint256 accountIndex = whitelistedAccount.blsKeyHashToStakingNodeIndex[blsHashes[i]];
            StakingNode storage stakingNode = whitelistedAccount.stakingNodes[accountIndex];
            require(stakingNode.exists, '[Validation] Bls key does not exist for this account');
            stakingNode.approved = true;
            _approvedBlsKeyHashes[blsHashes[i]] = true;
        }
    }

    function unapproveBlsKeyHashes(address who, bytes32[] calldata blsHashes)
    external
    onlyOwner
    whenNotFinalized
    whenNotRetired
    onlyWhitelistedAccounts(who)
    {

        WhitelistedAccount storage whitelistedAccount = _whitelistedAccounts[who];

        for (uint256 i = 0; i < blsHashes.length; i++) {
            require(_accountHasNode(whitelistedAccount, blsHashes[i]), "[Validation] BLS key does not exist for this account");
            require(_approvedBlsKeyHashes[blsHashes[i]], "[Validation] Provided BLS key was not previously approved");

            uint256 accountIndex = whitelistedAccount.blsKeyHashToStakingNodeIndex[blsHashes[i]];
            StakingNode storage stakingNode = whitelistedAccount.stakingNodes[accountIndex];
            require(stakingNode.exists, '[Validation] Bls key does not exist for this account');
            stakingNode.approved = false;
            _approvedBlsKeyHashes[blsHashes[i]] = false;
        }
    }

    function editWhitelistedAccountNumberOfNodes(address who, uint256 numberOfNodes)
    external
    onlyOwner
    whenNotFinalized
    whenNotRetired
    onlyWhitelistedAccounts(who)
    {

        WhitelistedAccount storage whitelistedAccount = _whitelistedAccounts[who];
        require(numberOfNodes >= whitelistedAccount.stakingNodes.length, "[Validation] Whitelisted account already submitted more nodes than you wish to allow");

        whitelistedAccount.numberOfNodes = numberOfNodes;
    }

    function burnCommittedFunds()
    external
    onlyOwner
    whenRetired
    {

        uint256 totalToBurn = currentTotalDelegated;
        for(uint256 i; i < _whitelistedAccountAddresses.length; i++) {
            WhitelistedAccount memory account = _whitelistedAccounts[_whitelistedAccountAddresses[i]];
            if (!account.exists) {
                continue;
            }

            uint256 approvedNodes = _approvedNodesCount(account);
            totalToBurn = totalToBurn.add(nodePrice.mul(approvedNodes));
        }

        token.burn(totalToBurn);
    }

    function recoverLostFunds(address who, uint256 amount)
    external
    onlyOwner
    {

        uint256 currentBalance = token.balanceOf(address(this));
        require(amount <= currentBalance, "[Validation] Recover amount exceeds contract balance");

        uint256 correctDepositAmount = _correctDepositAmount();
        uint256 lostFundsAmount = currentBalance.sub(correctDepositAmount);
        require(amount <= lostFundsAmount, "[Validation] Recover amount exceeds lost funds amount");

        token.transfer(who, amount);
    }

    function whitelistedAccountAddresses()
    external
    view
    returns (address[] memory, uint256[] memory)
    {

        address[] memory whitelistedAddresses = new address[](_whitelistedAccountAddresses.length);
        uint256[] memory whitelistedAddressesNodes = new uint256[](_whitelistedAccountAddresses.length);

        for (uint256 i = 0; i < _whitelistedAccountAddresses.length; i++) {
            whitelistedAddresses[i] = _whitelistedAccountAddresses[i];
            WhitelistedAccount storage whitelistedAccount = _whitelistedAccounts[_whitelistedAccountAddresses[i]];
            whitelistedAddressesNodes[i] = whitelistedAccount.numberOfNodes;

        }

        return (whitelistedAddresses, whitelistedAddressesNodes);
    }

    function whitelistedAccount(address who)
    external
    view
    returns (uint256 maxNumberOfNodes, uint256 amountStaked)
    {

        require(_whitelistedAccounts[who].exists, "[WhitelistedAddress] Address is not whitelisted");

        return (_whitelistedAccounts[who].numberOfNodes, _whitelistedAccounts[who].amountStaked);
    }

    function stakingNodesHashes(address who)
    external
    view
    returns (bytes32[] memory, bool[] memory, bytes32[] memory)
    {

        require(_whitelistedAccounts[who].exists, "[StakingNodesHashes] Address is not whitelisted");

        StakingNode[] memory stakingNodes = _whitelistedAccounts[who].stakingNodes;
        bytes32[] memory blsKeyHashes = new bytes32[](stakingNodes.length);
        bool[] memory blsKeyHashesStatus = new bool[](stakingNodes.length);
        bytes32[] memory rewardAddresses = new bytes32[](stakingNodes.length);

        for (uint256 i = 0; i < stakingNodes.length; i++) {
            blsKeyHashes[i] = stakingNodes[i].blsKeyHash;
            blsKeyHashesStatus[i] = stakingNodes[i].approved;
            rewardAddresses[i] = stakingNodes[i].elrondAddressHash;
        }

        return (blsKeyHashes, blsKeyHashesStatus, rewardAddresses);
    }

    function stakingNodeInfo(address who, bytes32 blsKeyHash)
    external
    view
    returns(bytes32, bool)
    {

        require(_whitelistedAccounts[who].exists, "[StakingNodeInfo] Address is not whitelisted");
        require(_accountHasNode(_whitelistedAccounts[who], blsKeyHash), "[StakingNodeInfo] Address does not have the provided node");

        WhitelistedAccount storage account = _whitelistedAccounts[who];
        uint256 nodeIndex = account.blsKeyHashToStakingNodeIndex[blsKeyHash];
        return (account.stakingNodes[nodeIndex].elrondAddressHash, account.stakingNodes[nodeIndex].approved);
    }

    function delegationDeposit(address who)
    external
    view
    returns (uint256, bytes32)
    {

        return (_delegationDeposits[who].amount, _delegationDeposits[who].elrondAddressHash);
    }

    function lostFundsAmount()
    external
    view
    returns (uint256)
    {

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 correctDepositAmount = _correctDepositAmount();

        return currentBalance.sub(correctDepositAmount);
    }

    function _addStakingNodes(WhitelistedAccount storage account, bytes32[] memory blsKeyHashes, bytes32 elrondAddressHash)
    internal
    {

        for (uint256 i = 0; i < blsKeyHashes.length; i++) {
            _insertStakingNode(account, blsKeyHashes[i], elrondAddressHash);
        }
    }

    function _validateStakeParameters(WhitelistedAccount memory account, bytes32[] memory blsKeyHashes)
    internal
    pure
    {

        require(
            account.numberOfNodes >= account.stakingNodes.length + blsKeyHashes.length,
            "[Validation] Adding this many nodes would exceed the maximum number of allowed nodes per this account"
        );
    }

    function _correctDepositAmount()
    internal
    view
    returns (uint256)
    {

        uint256 correctDepositAmount = currentTotalDelegated;
        for(uint256 i; i < _whitelistedAccountAddresses.length; i++) {
            WhitelistedAccount memory account = _whitelistedAccounts[_whitelistedAccountAddresses[i]];
            if (!account.exists) {
                continue;
            }

            correctDepositAmount = correctDepositAmount.add(nodePrice.mul(account.stakingNodes.length));
        }

        return correctDepositAmount;
    }

    function _accountHasNode(WhitelistedAccount storage account, bytes32 blsKeyHash)
    internal
    view
    returns (bool)
    {

        if (account.stakingNodes.length == 0) {
            return false;
        }

        uint256 nodeIndex = account.blsKeyHashToStakingNodeIndex[blsKeyHash];

        return (account.stakingNodes[nodeIndex].blsKeyHash == blsKeyHash) && account.stakingNodes[nodeIndex].exists;
    }

    function _approvedNodesCount(WhitelistedAccount memory account)
    internal
    pure
    returns(uint256)
    {

        uint256 nodesCount = 0;

        for(uint256 i = 0; i < account.stakingNodes.length; i++) {
            if (account.stakingNodes[i].exists && account.stakingNodes[i].approved) {
                nodesCount++;
            }
        }

        return nodesCount;
    }

    function _insertStakingNode(WhitelistedAccount storage account, bytes32 blsKeyHash, bytes32 elrondAddressHash)
    internal
    {

        require(blsKeyHash != 0, "[Validation] BLS key hash should not be 0");
        require(!_accountHasNode(account, blsKeyHash), "[Validation] BLS key was already added for this account");

        account.blsKeyHashToStakingNodeIndex[blsKeyHash] = account.stakingNodes.length;
        StakingNode memory newNode = StakingNode(blsKeyHash, elrondAddressHash, false, true);
        account.stakingNodes.push(newNode);
    }

    function _removeStakingNode(WhitelistedAccount storage account, bytes32 blsKeyHash)
    internal
    {

        uint256 nodeIndex = account.blsKeyHashToStakingNodeIndex[blsKeyHash];
        uint256 lastNodeIndex = account.stakingNodes.length - 1;

        bool stakingNodeIsApproved = account.stakingNodes[nodeIndex].approved;

        if (nodeIndex != lastNodeIndex) {
            bytes32 lastHash = account.stakingNodes[lastNodeIndex].blsKeyHash;
            account.blsKeyHashToStakingNodeIndex[lastHash] = nodeIndex;
            account.stakingNodes[nodeIndex] = account.stakingNodes[lastNodeIndex];
        }

        if (stakingNodeIsApproved) {
            delete _approvedBlsKeyHashes[blsKeyHash];
        }

        account.stakingNodes.pop();
        delete account.blsKeyHashToStakingNodeIndex[blsKeyHash];
    }

    function _validateBlsKeyHashForWithdrawal(WhitelistedAccount storage account, bytes32 blsKeyHash)
    internal
    view
    {

        require(_accountHasNode(account, blsKeyHash), "[Validation] BLS key does not exist for this account");
        if (contractState == States.Finalized || contractState == States.Retired) {
            require(
                !account.stakingNodes[account.blsKeyHashToStakingNodeIndex[blsKeyHash]].approved,
                "[Validation] BLS key was already approved, you cannot withdraw the associated amount"
            );
        }
    }
}