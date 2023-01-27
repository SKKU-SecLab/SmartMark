

pragma solidity ^0.5.16;

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


pragma solidity ^0.5.16;

contract GCCOracleInterface {


    function testConnection() public pure returns (bool);


    function getAddress() public view returns (address);


    function getFilterLength() public view returns (uint256);


    function getFilter(uint256 index) public view returns (string memory, string memory, string memory, uint256);


    function nowFilter() public view returns (string memory, string memory, string memory, uint256);


    function addProof(address addr, bytes32 txid, uint64 coin) public returns (bool);


    function addProofs(address[] memory addrList, bytes32[] memory txidList, uint64[] memory coinList) public returns (bool);


    function getProof(address addr, bytes32 txid) public view returns (address, bytes32, uint64);


    function getProofs(address addr) public view returns (address[] memory, bytes32[] memory, uint64[] memory);


    function getProofs(address addr, uint cursor, uint limit) public view returns (address[] memory, bytes32[] memory, uint64[] memory);

}


pragma solidity ^0.5.16;

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

}


pragma solidity ^0.5.16;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.16;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
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


pragma solidity ^0.5.16;



contract GCCOracleReader is Ownable {


    address internal oracleAddr = address(0);
    GCCOracleInterface internal oracle = GCCOracleInterface(oracleAddr);

    function initialize(address sender) public initializer {

        Ownable.initialize(sender);
    }

    function setOracleAddress(address _oracleAddress) public onlyOwner returns (bool) {

        oracleAddr = _oracleAddress;
        oracle = GCCOracleInterface(oracleAddr);
        return oracle.testConnection();
    }

    function getOracleAddress() public view returns (address) {

        return oracleAddr;
    }

    function testOracleConnection() public view returns (bool) {

        return oracle.testConnection();
    }

    function getFilterLength() public view returns (uint256) {

        return oracle.getFilterLength();
    }

    function getFilter(uint256 index) public view returns (string memory, string memory, string memory, uint256) {

        return oracle.getFilter(index);
    }

    function nowFilter() public view returns (string memory, string memory, string memory, uint256) {

        return oracle.nowFilter();
    }

    function getProof(address addr, bytes32 txid) public view returns (address, bytes32, uint64) {

        return oracle.getProof(addr, txid);
    }

    function getProofs(address addr) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {

        return oracle.getProofs(addr);
    }

    function getProofs(address addr, uint cursor, uint limit) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {

        return oracle.getProofs(addr, cursor, limit);
    }
}


pragma solidity ^0.5.16;



contract GCCOracleProofConsumer is GCCOracleReader {

    using SafeMath for uint256;

    uint256 internal _fullAmount;
    uint256 internal _usedAmount;
    mapping(address => uint256) internal _consumedProofs;

    function initialize(address sender, uint256 maxAmount) public initializer {

        _fullAmount = maxAmount;
        GCCOracleReader.initialize(sender);
    }

    function consumeProofs(address addr) public returns (bool) {

        _consumeProofs(addr, 1000);
        return true;
    }

    function consumeLimitedProofs(address addr, uint256 limit) public returns (bool) {

        _consumeProofs(addr, limit);
        return true;
    }

    function getConsumableFullAmount() public view returns (uint256) {

        return _fullAmount;
    }

    function getConsumableUsedAmount() public view returns (uint256) {

        return _usedAmount;
    }

    function getConsumedProofs(address addr) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {

        uint256 consumedLimit = _consumedProofs[addr];
        return oracle.getProofs(addr, 0, consumedLimit);
    }

    function fewConsumedProofs(address addr, uint cursor, uint limit) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {

        uint256 consumedLimit = _consumedProofs[addr].sub(cursor) < limit ? _consumedProofs[addr].sub(cursor) : limit;
        return oracle.getProofs(addr, cursor, consumedLimit);
    }

    function _consumeProofs(address addr, uint256 limit) internal {

        require(getOracleAddress() != address(0), "GCCOracleProofConsumer: Cannot provably mint tokens while there is no oracle!");

        uint256 prevCursor = _consumedProofs[addr];

        address[] memory addrList;
        bytes32[] memory txidList;
        uint64 [] memory coinList;

        (addrList, txidList, coinList) = getProofs(addr, prevCursor, limit);
        uint256 size = addrList.length;
        if (size == 0) return;

        uint256 nextCursor = prevCursor.add(size);
        uint256 mintAmount = 0;

        for (uint256 i=0; i<size; i++) {
            mintAmount = mintAmount.add(coinList[i]);
        }

        uint256 freeAmount = _fullAmount.sub(_usedAmount);
        require(mintAmount <= freeAmount, "GCCOracleProofConsumer: Cannot mint more tokens, limit exhausted!");

        _usedAmount = _usedAmount.add(mintAmount);
        _consumedProofs[addr] = nextCursor;
        _afterConsumeProofs(addr, mintAmount);
    }

    function _afterConsumeProofs(address account, uint256 amount) internal {

    }
}


pragma solidity ^0.5.16;

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


pragma solidity ^0.5.16;





contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {

    }

}


pragma solidity ^0.5.16;


contract ERC20Detailed is ERC20 {


    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

}


pragma solidity ^0.5.16;


contract ERC20Burnable is ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

}


pragma solidity ^0.5.16;



contract ERC20StakableDiscreetly is ERC20, Ownable {


    uint256 internal _minTotalSupply;
    uint256 internal _maxTotalSupply;

    uint256 internal _stakeStartCheck; //stake start time
    uint256 internal _stakeMinAge; // (3 days) minimum age for coin age: 3D
    uint256 internal _stakeMaxAge; // (90 days) stake age of full weight: 90D
    uint256 internal _stakeMinAmount; // (10**18) 1 token
    uint8 internal _stakePrecision; // (10**18)

    uint256 internal _stakeCheckpoint; // current checkpoint
    uint256 internal _stakeInterval; // interval between checkpoints

    struct stakeStruct {
        uint256 amount; // staked amount
        uint256 minCheckpoint; // timestamp of min checkpoint stakes qualifies for
        uint256 maxCheckpoint; // timestamp of max checkpoint stakes qualifies for
    }

    uint256 internal _stakeSumReward;
    uint256[] internal _stakeRewardAmountVals;
    uint256[] internal _stakeRewardTimestamps;

    mapping(address => stakeStruct) internal _stakes; // stakes
    mapping(uint256 => mapping(uint256 => uint256)) internal _history; // historical stakes per checkpoint

    uint256[] internal _tierThresholds; // thresholds between tiers
    uint256[] internal _tierShares; // shares of reward per tier

    event Stake(address indexed from, address indexed to, uint256 value);
    event Checkpoint(uint256 timestamp, uint256 minted);

    modifier activeStake() {

        require(_stakeStartCheck > 0, "ERC20: Staking has not started yet!");
        _tick();
        _;
    }

    function initialize(
        address sender, uint256 minTotalSupply, uint256 maxTotalSupply, uint8 stakePrecision
    ) public initializer
    {

        Ownable.initialize(sender);

        _minTotalSupply = minTotalSupply;
        _maxTotalSupply = maxTotalSupply;
        _mint(sender, minTotalSupply);

        _stakePrecision = stakePrecision;
        _stakeMinAmount = 10**(uint256(_stakePrecision)); // def is 1

        _tierThresholds.push(10**(uint256(_stakePrecision)+6));
        _tierThresholds.push(0);

        _tierShares.push(20); // 20%
        _tierShares.push(80); // 80%
    }

    function open(
        uint256 stakeMinAmount, uint64 stakeMinAge, uint64 stakeMaxAge, uint64 stakeStart, uint64 stakeInterval
    ) public onlyOwner returns (bool) {

        require(_stakeStartCheck == 0, "ERC20: Contract has been already opened!");
        _stakeInterval = uint256(stakeInterval);
        _stakeStartCheck = uint256(stakeStart);
        _stakeCheckpoint = uint256(stakeStart);
        _stakeMinAge = uint256(stakeMinAge);
        _stakeMaxAge = uint256(stakeMaxAge);
        _stakeMinAmount = stakeMinAmount;
        return true;
    }

    function setReward(uint256 timestamp, uint256 amount) public onlyOwner returns (bool) {

        _setReward(timestamp, amount);
        return true;
    }

    function getReward(uint256 timestamp) public view returns (uint256) {

        return _getReward(timestamp);
    }

    function stakeOf(address account) public view returns (uint256) {

        return _stakeOf(account);
    }

    function activeStakeOf(address account) public view returns (uint256) {

        return _stakeOf(account, _nextCheckpoint());
    }

    function restake() public activeStake returns (bool) {

        _restake(_msgSender(), _nextCheckpoint());
        return true;
    }

    function stake(uint256 amount) public activeStake returns (bool) {

        _stake(_msgSender(), amount, _nextCheckpoint());
        return true;
    }

    function stakeAll() public activeStake returns (bool) {

        _stake(_msgSender(), balanceOf(_msgSender()),  _nextCheckpoint());
        return true;
    }

    function unstake(uint256 amount) public activeStake returns (bool) {

        _unstake(_msgSender(), amount, _nextCheckpoint());
        return true;
    }

    function unstakeAll() public activeStake returns (bool) {

        _unstake(_msgSender(), stakeOf(_msgSender()), _nextCheckpoint());
        return true;
    }

    function withdrawReward() public activeStake returns (bool) {

        _mintReward(_msgSender(), _nextCheckpoint());
        return true;
    }

    function estimateReward() public view returns (uint256) {

        return _calcReward(_msgSender(), _nextCheckpoint());
    }

    function nextCheckpoint() public view returns (uint256) {

        return _nextCheckpoint();
    }

    function lastCheckpoint() public view returns (uint256) {

        return _lastCheckpoint();
    }

    function tick(uint256 repeats) public onlyOwner returns (bool) {

        _tick(repeats);
        return true;
    }

    function tickNext() public onlyOwner returns (bool) {

        return _tickNext();
    }

    function rewardStaker(address account) public onlyOwner activeStake returns (bool) {

        _mintReward(account, _nextCheckpoint());
        return true;
    }

    function _stakeOf(address account) internal view returns (uint256) {

        return _stakes[account].amount;
    }

    function _stakeOf(address account, uint256 checkpoint) internal view returns (uint256) {

        if (_stakes[account].minCheckpoint <= checkpoint && _stakes[account].maxCheckpoint > checkpoint) {
            return _stakes[account].amount;
        }
        return 0;
    }

    function _nextCheckpoint() internal view returns (uint256) {

        return _stakeCheckpoint;
    }

    function _lastCheckpoint() internal view returns (uint256) {

        return _stakeCheckpoint.sub(_stakeInterval);
    }

    function _restake(address _sender, uint256 _nxtCheckpoint) internal {

        _unstake(_sender, stakeOf(_sender), _nxtCheckpoint);
        _stake(_sender, balanceOf(_sender), _nxtCheckpoint);
    }

    function _stake(address _sender, uint256 _amount, uint256 _nxtCheckpoint) internal {

        require(_sender != address(0), "ERC20Stakable: stake from the zero address!");
        require(_amount >= _stakeMinAmount, "ERC20Stakable: stake amount is too low!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        stakeStruct memory prevStake = _stakes[_sender];
        uint256 _prevAmount = prevStake.amount;
        uint256 _nextAmount = _prevAmount.add(_amount);
        if (_nextAmount == 0) return;

        _unstake(_sender, _prevAmount, _nxtCheckpoint);

        uint256 _minCheckpoint = _nxtCheckpoint.add(_stakeMinAge).sub(_stakeInterval);
        uint256 _maxCheckpoint = _minCheckpoint.add(_stakeMaxAge);

        uint256 _tierNext = _tierOf(_nextAmount);

        uint256 _tmpCheckpoint = _minCheckpoint;
        uint size = _maxCheckpoint.sub(_minCheckpoint).div(_stakeInterval);

        for (uint i = 0; i < size; i++) {
            _history[_tmpCheckpoint][_tierNext] = _history[_tmpCheckpoint][_tierNext].add(_nextAmount);
            _tmpCheckpoint = _tmpCheckpoint.add(_stakeInterval);
        }

        stakeStruct memory nextStake = stakeStruct(_nextAmount, _minCheckpoint, _maxCheckpoint);

        _decreaseBalance(_sender, _nextAmount);
        _stakes[_sender] = nextStake;

        emit Stake(address(0), _sender, _nextAmount);
    }

    function _unstake(address _sender, uint256 _amount, uint256 _nxtCheckpoint) internal {

        require(_sender != address(0), "ERC20Stakable: unstake from the zero address!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        _mintReward(_sender, _nxtCheckpoint);

        stakeStruct memory prevStake = _stakes[_sender];
        uint256 _prevAmount = prevStake.amount;
        if (_prevAmount == 0) return;
        uint256 _nextAmount = _prevAmount.sub(_amount);

        uint256 _minCheckpoint = _nxtCheckpoint > prevStake.minCheckpoint ? _nxtCheckpoint : prevStake.minCheckpoint;
        uint256 _maxCheckpoint = prevStake.maxCheckpoint;
        if (_minCheckpoint > _maxCheckpoint) _minCheckpoint = _maxCheckpoint;

        uint256 _tierPrev = _tierOf(_prevAmount);
        uint256 _tierNext = _tierOf(_nextAmount);

        uint256 _tmpCheckpoint = _minCheckpoint;
        uint size = _maxCheckpoint.sub(_minCheckpoint).div(_stakeInterval);

        for (uint i = 0; i < size; i++) {
            _history[_tmpCheckpoint][_tierPrev] = _history[_tmpCheckpoint][_tierPrev].sub(_prevAmount);
            _history[_tmpCheckpoint][_tierNext] = _history[_tmpCheckpoint][_tierNext].add(_nextAmount);
            _tmpCheckpoint = _tmpCheckpoint.add(_stakeInterval);
        }

        stakeStruct memory nextStake = stakeStruct(_nextAmount, prevStake.minCheckpoint, prevStake.maxCheckpoint);

        _stakes[_sender] = nextStake;
        _increaseBalance(_sender, _amount);

        emit Stake(_sender, address(0), _amount);
    }

    function _mintReward(address _address, uint256 _nxtCheckpoint) internal {

        require(_address != address(0), "ERC20Stakable: withdraw from the zero address!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        stakeStruct memory prevStake = _stakes[_address];
        uint256 _prevAmount = prevStake.amount;
        if (_prevAmount == 0) return;

        uint256 _minCheckpoint = prevStake.minCheckpoint;
        uint256 _maxCheckpoint = _nxtCheckpoint < prevStake.maxCheckpoint ? _nxtCheckpoint : prevStake.maxCheckpoint;
        if (_minCheckpoint >= _maxCheckpoint) return;

        uint256 rewardAmount = _getProofOfStakeReward(_address, _minCheckpoint, _maxCheckpoint);
        uint256 remainAmount = _maxTotalSupply.sub(_jointSupply());
        if (rewardAmount > remainAmount) {
            rewardAmount = remainAmount;
        }

        stakeStruct memory nextStake = stakeStruct(_prevAmount, _maxCheckpoint, prevStake.maxCheckpoint);

        _stakes[_address] = nextStake;
        _mint(_address, rewardAmount);
    }

    function _calcReward(address _address, uint256 _nxtCheckpoint) internal view returns (uint256) {

        require(_address != address(0), "ERC20Stakable: calculate reward from the zero address!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        stakeStruct memory prevStake = _stakes[_address];
        uint256 _minCheckpoint = prevStake.minCheckpoint;
        uint256 _maxCheckpoint = _nxtCheckpoint < prevStake.maxCheckpoint ? _nxtCheckpoint : prevStake.maxCheckpoint;
        if (_minCheckpoint >= _maxCheckpoint) return 0;
        return _getProofOfStakeReward(_address, _minCheckpoint, _maxCheckpoint);
    }

    function _getProofOfStakeReward(address _address, uint256 _minCheckpoint, uint256 _maxCheckpoint) internal view returns (uint256) {

        if (_minCheckpoint == 0 || _maxCheckpoint == 0) return 0;
        uint256 _curReward = 0;
        uint256 _tmpCheckpoint = _minCheckpoint;
        uint size = _maxCheckpoint.sub(_minCheckpoint).div(_stakeInterval);

        for (uint i = 0; i < size; i++) {
            _curReward = _curReward.add(_getCheckpointReward(_address, _tmpCheckpoint));
            _tmpCheckpoint = _tmpCheckpoint.add(_stakeInterval);
        }
        return _curReward;
    }

    function _getCheckpointReward(address _address, uint256 _checkpoint) internal view returns (uint256) {

        if (_checkpoint < _stakeStartCheck || _stakeStartCheck <= 0) return 0;
        uint256 maxReward = _getReward(_checkpoint);
        uint256 userStake = _stakeOf(_address);
        uint256 tier = _tierOf(userStake);
        uint256 tierStake = _history[_checkpoint][tier];
        if (tierStake == 0) return 0;
        return maxReward.mul(_tierShares[tier]).div(100).mul(userStake).div(tierStake);
    }

    function _increaseBalance(address account, uint256 amount) internal {

        require(account != address(0), "ERC20Stakable: balance increase from the zero address!");
        _balances[account] = _balances[account].add(amount);
    }

    function _decreaseBalance(address account, uint256 amount) internal {

        require(account != address(0), "ERC20Stakable: balance decrease from the zero address!");
        _balances[account] = _balances[account].sub(amount, "ERC20Stakable: balance decrease amount exceeds balance!");
    }

    function _jointSupply() internal view returns (uint256) {

        return _minTotalSupply.add(_stakeSumReward);
    }

    function _tick() internal {

        while (_tickNext()) {}
    }

    function _tick(uint256 limit) internal {

        for (uint256 max = limit; _tickNext() && max > 0; max--) {}
    }

    function _tickNext() internal returns (bool) {

        uint256 _now = uint256(now);
        if (_now >= _stakeCheckpoint && _stakeCheckpoint > 0) {
            _tickCheckpoint(_stakeCheckpoint, _stakeCheckpoint.add(_stakeInterval));
            return true;
        }
        return false;
    }

    function _tickCheckpoint(uint256 _prvCheckpoint, uint256 _newCheckpoint) internal {

        uint256 _maxReward = (_prvCheckpoint == _stakeStartCheck) ? 0 :_getReward(_prvCheckpoint);

        _stakeCheckpoint = _newCheckpoint;
        _stakeSumReward = _stakeSumReward.add(_maxReward);

        emit Checkpoint(_prvCheckpoint, _maxReward);
    }

    function _tierOf(uint256 _amount) internal view returns (uint256) {

        uint256 tier = 0;
        uint256 tlen = _tierThresholds.length;
        for (uint i = 0; i < tlen; i++) {
            if (tier == i && _tierThresholds[i] != 0 && _tierThresholds[i] <= _amount) tier++;
        }
        return tier;
    }

    function _setReward(uint256 timestamp, uint256 amount) internal {

        uint256 _newestLen = _stakeRewardTimestamps.length;
        uint256 _newestTimestamp = _newestLen == 0 ? 0 : _stakeRewardTimestamps[_newestLen-1];
        require(amount >= 0, "ERC20Stakable: future reward set too low");
        require(timestamp >= _newestTimestamp, "ERC20Stakable: future timestamp cannot be set before current timestamp");
        _stakeRewardTimestamps.push(timestamp);
        _stakeRewardAmountVals.push(amount);
    }

    function _getReward(uint256 timestamp) internal view returns (uint256) {

        uint256 _currentTimestamp = 0;
        uint256 _currentRewardVal = 0;
        uint256 _rewardLen = _stakeRewardTimestamps.length;
        for (uint256 i=0; i<_rewardLen; i++) {
            if (timestamp >= _stakeRewardTimestamps[i]) {
                _currentTimestamp = _stakeRewardTimestamps[i];
                _currentRewardVal = _stakeRewardAmountVals[i];
            }
        }
        return _currentRewardVal;
    }

}


pragma solidity ^0.5.16;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.16;




contract PauserRole is Initializable, Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {

        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }

}


pragma solidity ^0.5.16;


contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool internal _paused;

    function initialize(address sender) public initializer {

        PauserRole.initialize(sender);

        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

}


pragma solidity ^0.5.16;







contract GCCDiscreteToken is GCCOracleProofConsumer, ERC20Detailed, ERC20Burnable, ERC20StakableDiscreetly, Pausable {


    function initialize(
        address sender, string memory name, string memory symbol, uint8 decimals, uint256 minTotalSupply, uint256 maxTotalSupply,
        uint256 provableSupply
    ) public initializer {

        GCCOracleProofConsumer.initialize(sender, provableSupply);
        ERC20Detailed.initialize(name, symbol, decimals);
        ERC20StakableDiscreetly.initialize(sender, minTotalSupply, maxTotalSupply, decimals);
        Pausable.initialize(sender);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    function restake() public whenNotPaused returns (bool) {

        return super.restake();
    }

    function stake(uint256 amount) public whenNotPaused returns (bool) {

        return super.stake(amount);
    }

    function stakeAll() public whenNotPaused returns (bool) {

        return super.stakeAll();
    }

    function unstake(uint256 amount) public whenNotPaused returns (bool) {

        return super.unstake(amount);
    }

    function unstakeAll() public whenNotPaused returns (bool) {

        return super.unstakeAll();
    }

    function withdrawReward() public whenNotPaused returns (bool) {

        return super.withdrawReward();
    }

    function estimateReward() public view whenNotPaused returns (uint256) {

        return super.estimateReward();
    }

    function _afterConsumeProofs(address account, uint256 amount) internal {

        _mint(account, amount);
    }

}


pragma solidity ^0.5.16;


contract GCCDiscrete is GCCDiscreteToken {


    constructor(
        string memory name, string memory symbol, uint8 decimals, uint256 minTotalSupply, uint256 maxTotalSupply,
        uint256 provableSupply
    ) public {
        GCCDiscreteToken.initialize(_msgSender(), name, symbol, decimals, minTotalSupply, maxTotalSupply, provableSupply);
    }
}