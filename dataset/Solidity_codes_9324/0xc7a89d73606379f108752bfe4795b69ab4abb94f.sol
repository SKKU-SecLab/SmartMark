pragma solidity >=0.4.24 <0.7.0;


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

  uint256[50] private ______gap;
}pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;



contract ERC20 is Initializable, Context, IERC20 {

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

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;


contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

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

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;



contract ERC20Burnable is Initializable, Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;



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

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;



contract Pausable is Initializable, Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

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

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;


contract ERC20Pausable is Initializable, ERC20, Pausable {

    function initialize(address sender) public initializer {

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

    uint256[50] private ______gap;
}/**
 * COPYRIGHT © 2020 RARI CAPITAL, INC. ALL RIGHTS RESERVED.
 * Anyone is free to integrate the public (i.e., non-administrative) application programming interfaces (APIs) of the official Ethereum smart contract instances deployed by Rari Capital, Inc. in any application (commercial or noncommercial and under any license), provided that the application does not abuse the APIs or act against the interests of Rari Capital, Inc.
 * Anyone is free to study, review, and analyze the source code contained in this package.
 * Reuse (including deployment of smart contracts other than private testing on a private network), modification, redistribution, or sublicensing of any source code contained in this package is not permitted without the explicit permission of David Lucid of Rari Capital, Inc.
 * No one is permitted to use the software for any purpose other than those allowed by this license.
 * This license is liable to change at any time at the sole discretion of David Lucid of Rari Capital, Inc.
 */

pragma solidity 0.5.17;


contract RariGovernanceToken is Initializable, ERC20, ERC20Detailed, ERC20Burnable, ERC20Pausable {

    function initialize(address distributor, address vesting) public initializer {

        ERC20Detailed.initialize("Rari Governance Token", "RGT", 18);
        ERC20Pausable.initialize(msg.sender);
        _mint(distributor, 8750000 * (10 ** uint256(decimals())));
        _mint(vesting, 1250000 * (10 ** uint256(decimals())));
    }
}pragma solidity ^0.5.0;



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

    uint256[50] private ______gap;
}pragma solidity >=0.5.0;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}/**
 * COPYRIGHT © 2020 RARI CAPITAL, INC. ALL RIGHTS RESERVED.
 * Anyone is free to integrate the public (i.e., non-administrative) application programming interfaces (APIs) of the official Ethereum smart contract instances deployed by Rari Capital, Inc. in any application (commercial or noncommercial and under any license), provided that the application does not abuse the APIs or act against the interests of Rari Capital, Inc.
 * Anyone is free to study, review, and analyze the source code contained in this package.
 * Reuse (including deployment of smart contracts other than private testing on a private network), modification, redistribution, or sublicensing of any source code contained in this package is not permitted without the explicit permission of David Lucid of Rari Capital, Inc.
 * No one is permitted to use the software for any purpose other than those allowed by this license.
 * This license is liable to change at any time at the sole discretion of David Lucid of Rari Capital, Inc.
 */

pragma solidity 0.5.17;


contract IRariFundToken is IERC20 {

    function burn(uint256 amount) external;


    function setGovernanceTokenDistributor(address payable newContract, bool force) external;

}/**
 * COPYRIGHT © 2020 RARI CAPITAL, INC. ALL RIGHTS RESERVED.
 * Anyone is free to integrate the public (i.e., non-administrative) application programming interfaces (APIs) of the official Ethereum smart contract instances deployed by Rari Capital, Inc. in any application (commercial or noncommercial and under any license), provided that the application does not abuse the APIs or act against the interests of Rari Capital, Inc.
 * Anyone is free to study, review, and analyze the source code contained in this package.
 * Reuse (including deployment of smart contracts other than private testing on a private network), modification, redistribution, or sublicensing of any source code contained in this package is not permitted without the explicit permission of David Lucid of Rari Capital, Inc.
 * No one is permitted to use the software for any purpose other than those allowed by this license.
 * This license is liable to change at any time at the sole discretion of David Lucid of Rari Capital, Inc.
 */

pragma solidity 0.5.17;


interface IRariFundManager {

    function rariFundToken() external returns (IRariFundToken);


    function getFundBalance() external returns (uint256);


    function deposit(string calldata currencyCode, uint256 amount) external;


    function withdraw(string calldata currencyCode, uint256 amount) external;

}/**
 * COPYRIGHT © 2020 RARI CAPITAL, INC. ALL RIGHTS RESERVED.
 * Anyone is free to integrate the public (i.e., non-administrative) application programming interfaces (APIs) of the official Ethereum smart contract instances deployed by Rari Capital, Inc. in any application (commercial or noncommercial and under any license), provided that the application does not abuse the APIs or act against the interests of Rari Capital, Inc.
 * Anyone is free to study, review, and analyze the source code contained in this package.
 * Reuse (including deployment of smart contracts other than private testing on a private network), modification, redistribution, or sublicensing of any source code contained in this package is not permitted without the explicit permission of David Lucid of Rari Capital, Inc.
 * No one is permitted to use the software for any purpose other than those allowed by this license.
 * This license is liable to change at any time at the sole discretion of David Lucid of Rari Capital, Inc.
 */

pragma solidity 0.5.17;




contract RariGovernanceTokenDistributor is Initializable, Ownable {

    using SafeMath for uint256;

    function initialize(uint256 startBlock, IRariFundManager[3] memory fundManagers, IERC20[3] memory fundTokens) public initializer {

        Ownable.initialize(msg.sender);
        require(fundManagers.length == 3 && fundTokens.length == 3, "Fund manager and fund token array lengths must be equal to 3.");
        distributionStartBlock = startBlock;
        distributionEndBlock = distributionStartBlock + DISTRIBUTION_PERIOD;
        rariFundManagers = fundManagers;
        rariFundTokens = fundTokens;
        _ethUsdPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    bool public disabled;

    event Disabled();

    event Enabled();

    function setDisabled(bool _disabled) external onlyOwner {

        require(_disabled != disabled, "No change to enabled/disabled status.");
        disabled = _disabled;
        if (_disabled) emit Disabled(); else emit Enabled();
    }

    modifier enabled() {

        require(!disabled, "This governance token distributor contract is disabled. This may be due to an upgrade.");
        _;
    }

    RariGovernanceToken rariGovernanceToken;

    function setGovernanceToken(RariGovernanceToken governanceToken) external onlyOwner {

        if (address(rariGovernanceToken) != address(0)) require(disabled, "This governance token distributor contract must be disabled before changing the governance token contract.");
        require(address(governanceToken) != address(0), "New governance token contract cannot be the zero address.");
        rariGovernanceToken = governanceToken;
    }

    enum RariPool {
        Stable,
        Yield,
        Ethereum
    }

    IRariFundManager[3] rariFundManagers;

    IERC20[3] rariFundTokens;

    function setFundManager(RariPool pool, IRariFundManager fundManager) external onlyOwner {

        require(disabled, "This governance token distributor contract must be disabled before changing fund manager contracts.");
        require(address(fundManager) != address(0), "New fund manager contract cannot be the zero address.");
        rariFundManagers[uint8(pool)] = fundManager;
    }

    function setFundToken(RariPool pool, IERC20 fundToken) external onlyOwner {

        require(disabled, "This governance token distributor contract must be disabled before changing fund token contracts.");
        require(address(fundToken) != address(0), "New fund token contract cannot be the zero address.");
        rariFundTokens[uint8(pool)] = fundToken;
    }

    uint256 public distributionStartBlock;

    uint256 public distributionEndBlock;

    uint256 public constant DISTRIBUTION_PERIOD = 390000;

    uint256 public constant FINAL_RGT_DISTRIBUTION = 8750000e18;

    function getRgtDistributed(uint256 blockNumber) public view returns (uint256) {

        if (blockNumber <= distributionStartBlock) return 0;
        if (blockNumber >= distributionEndBlock) return FINAL_RGT_DISTRIBUTION;
        uint256 blocks = blockNumber.sub(distributionStartBlock);
        if (blocks < 97500) return uint256(1e18).mul(blocks ** 2).div(2730).add(uint256(1450e18).mul(blocks).div(273));
        if (blocks < 195000) return uint256(14600e18).mul(blocks).div(273).sub(uint256(2e18).mul(blocks ** 2).div(17745)).sub(uint256(1000000e18).div(7));
        if (blocks < 292500) return uint256(1e18).mul(blocks ** 2).div(35490).add(uint256(39250000e18).div(7)).sub(uint256(950e18).mul(blocks).div(273));
        return uint256(1e18).mul(blocks ** 2).div(35490).add(uint256(34750000e18).div(7)).sub(uint256(50e18).mul(blocks).div(39));
    }

    uint256[3] _fundBalancesCache;

    uint256[3] _rgtPerRftAtLastSpeedUpdate;

    uint256 _rgtDistributedAtLastSpeedUpdate;

    mapping (address => uint256)[3] _rgtPerRftAtLastDistribution;

    modifier beforeDistributionPeriodEnded() {

        require(block.number < distributionEndBlock, "The governance token distribution period has already ended.");
        _;
    }

    function refreshDistributionSpeeds(RariPool pool, uint256 newBalance) external enabled {

        require(msg.sender == address(rariFundManagers[uint8(pool)]), "Caller is not the fund manager corresponding to this pool.");
        if (block.number >= distributionEndBlock) return;
        storeRgtDistributedPerRft();
        _fundBalancesCache[uint8(pool)] = newBalance;
    }

    function refreshDistributionSpeeds(RariPool pool) external enabled beforeDistributionPeriodEnded {

        storeRgtDistributedPerRft();
        _fundBalancesCache[uint8(pool)] = rariFundManagers[uint8(pool)].getFundBalance();
    }

    function refreshDistributionSpeeds() external enabled beforeDistributionPeriodEnded {

        storeRgtDistributedPerRft();
        for (uint256 i = 0; i < 3; i++) _fundBalancesCache[i] = rariFundManagers[i].getFundBalance();
    }
    
    AggregatorV3Interface private _ethUsdPriceFeed;

    function getEthUsdPrice() public view returns (uint256) {

        (, int256 price, , , ) = _ethUsdPriceFeed.latestRoundData();
        return price >= 0 ? uint256(price) : 0;
    }

    function storeRgtDistributedPerRft() internal {

        uint256 rgtDistributed = getRgtDistributed(block.number);
        uint256 rgtToDistribute = rgtDistributed.sub(_rgtDistributedAtLastSpeedUpdate);
        if (rgtToDistribute <= 0) return;
        uint256 ethFundBalanceUsd = _fundBalancesCache[2] > 0 ? _fundBalancesCache[2].mul(getEthUsdPrice()).div(1e8) : 0;
        uint256 fundBalanceSum = 0;
        for (uint256 i = 0; i < 3; i++) fundBalanceSum = fundBalanceSum.add(i == 2 ? ethFundBalanceUsd : _fundBalancesCache[i]);
        if (fundBalanceSum <= 0) return;
        _rgtDistributedAtLastSpeedUpdate = rgtDistributed;

        for (uint256 i = 0; i < 3; i++) {
            uint256 totalSupply = rariFundTokens[i].totalSupply();
            if (totalSupply > 0) _rgtPerRftAtLastSpeedUpdate[i] = _rgtPerRftAtLastSpeedUpdate[i].add(rgtToDistribute.mul(i == 2 ? ethFundBalanceUsd : _fundBalancesCache[i]).div(fundBalanceSum).mul(1e18).div(totalSupply));
        }
    }

    function getRgtDistributedPerRft() internal view returns (uint256[3] memory rgtPerRftByPool) {

        uint256 rgtDistributed = getRgtDistributed(block.number);
        uint256 rgtToDistribute = rgtDistributed.sub(_rgtDistributedAtLastSpeedUpdate);
        if (rgtToDistribute <= 0) return _rgtPerRftAtLastSpeedUpdate;
        uint256 ethFundBalanceUsd = _fundBalancesCache[2] > 0 ? _fundBalancesCache[2].mul(getEthUsdPrice()).div(1e8) : 0;
        uint256 fundBalanceSum = 0;
        for (uint256 i = 0; i < 3; i++) fundBalanceSum = fundBalanceSum.add(i == 2 ? ethFundBalanceUsd : _fundBalancesCache[i]);
        if (fundBalanceSum <= 0) return _rgtPerRftAtLastSpeedUpdate;

        for (uint256 i = 0; i < 3; i++) {
            uint256 totalSupply = rariFundTokens[i].totalSupply();
            rgtPerRftByPool[i] = totalSupply > 0 ? _rgtPerRftAtLastSpeedUpdate[i].add(rgtToDistribute.mul(i == 2 ? ethFundBalanceUsd : _fundBalancesCache[i]).div(fundBalanceSum).mul(1e18).div(totalSupply)) : _rgtPerRftAtLastSpeedUpdate[i];
        }
    }

    mapping (address => uint256) _rgtDistributedByHolder;

    mapping (address => uint256) _rgtClaimedByHolder;

    function distributeRgt(address holder, RariPool pool) external enabled returns (uint256) {

        uint256 rftBalance = rariFundTokens[uint8(pool)].balanceOf(holder);
        if (rftBalance <= 0) return 0;

        storeRgtDistributedPerRft();

        uint256 undistributedRgt = _rgtPerRftAtLastSpeedUpdate[uint8(pool)].sub(_rgtPerRftAtLastDistribution[uint8(pool)][holder]).mul(rftBalance).div(1e18);
        if (undistributedRgt <= 0) return 0;

        _rgtPerRftAtLastDistribution[uint8(pool)][holder] = _rgtPerRftAtLastSpeedUpdate[uint8(pool)];
        _rgtDistributedByHolder[holder] = _rgtDistributedByHolder[holder].add(undistributedRgt);
        return undistributedRgt;
    }

    function distributeRgt(address holder) internal enabled returns (uint256) {

        storeRgtDistributedPerRft();

        uint256 undistributedRgt = 0;

        for (uint256 i = 0; i < 3; i++) {
            uint256 rftBalance = rariFundTokens[i].balanceOf(holder);
            if (rftBalance <= 0) continue;

            undistributedRgt += _rgtPerRftAtLastSpeedUpdate[i].sub(_rgtPerRftAtLastDistribution[i][holder]).mul(rftBalance).div(1e18);
        }

        if (undistributedRgt <= 0) return 0;

        for (uint256 i = 0; i < 3; i++) if (rariFundTokens[i].balanceOf(holder) > 0) _rgtPerRftAtLastDistribution[i][holder] = _rgtPerRftAtLastSpeedUpdate[i];
        _rgtDistributedByHolder[holder] = _rgtDistributedByHolder[holder].add(undistributedRgt);
        return undistributedRgt;
    }

    function beforeFirstPoolTokenTransferIn(address holder, RariPool pool) external enabled {

        require(rariFundTokens[uint8(pool)].balanceOf(holder) == 0, "Pool token balance is not equal to 0.");
        storeRgtDistributedPerRft();
        _rgtPerRftAtLastDistribution[uint8(pool)][holder] = _rgtPerRftAtLastSpeedUpdate[uint8(pool)];
    }

    function getUndistributedRgt(address holder) internal view returns (uint256) {

        uint256[3] memory rgtPerRftByPool = getRgtDistributedPerRft();

        uint256 undistributedRgt = 0;

        for (uint256 i = 0; i < 3; i++) {
            uint256 rftBalance = rariFundTokens[i].balanceOf(holder);
            if (rftBalance <= 0) continue;

            undistributedRgt += rgtPerRftByPool[i].sub(_rgtPerRftAtLastDistribution[i][holder]).mul(rftBalance).div(1e18);
        }

        return undistributedRgt;
    }

    function getUnclaimedRgt(address holder) external view returns (uint256) {

        return _rgtDistributedByHolder[holder].sub(_rgtClaimedByHolder[holder]).add(getUndistributedRgt(holder));
    }

    function getPublicRgtClaimFee(uint256 blockNumber) public view returns (uint256) {

        if (blockNumber <= distributionStartBlock) return 0.33e18;
        if (blockNumber >= distributionEndBlock) return 0;
        return uint256(0.33e18).mul(distributionEndBlock.sub(blockNumber)).div(DISTRIBUTION_PERIOD);
    }

    event Claim(address holder, uint256 claimed, uint256 transferred, uint256 burned);

    function claimRgt(uint256 amount) public enabled {

        distributeRgt(msg.sender);

        uint256 unclaimedRgt = _rgtDistributedByHolder[msg.sender].sub(_rgtClaimedByHolder[msg.sender]);
        require(amount <= unclaimedRgt, "Claim amount cannot be greater than unclaimed RGT.");

        uint256 burnRgt = amount.mul(getPublicRgtClaimFee(block.number)).div(1e18);
        uint256 transferRgt = amount.sub(burnRgt);
        _rgtClaimedByHolder[msg.sender] = _rgtClaimedByHolder[msg.sender].add(amount);
        require(rariGovernanceToken.transfer(msg.sender, transferRgt), "Failed to transfer RGT from liquidity mining reserve.");
        rariGovernanceToken.burn(burnRgt);
        emit Claim(msg.sender, amount, transferRgt, burnRgt);
    }

    function claimAllRgt() public enabled returns (uint256) {

        distributeRgt(msg.sender);

        uint256 unclaimedRgt = _rgtDistributedByHolder[msg.sender].sub(_rgtClaimedByHolder[msg.sender]);
        require(unclaimedRgt > 0, "Unclaimed RGT not greater than 0.");

        uint256 burnRgt = unclaimedRgt.mul(getPublicRgtClaimFee(block.number)).div(1e18);
        uint256 transferRgt = unclaimedRgt.sub(burnRgt);
        _rgtClaimedByHolder[msg.sender] = _rgtClaimedByHolder[msg.sender].add(unclaimedRgt);
        require(rariGovernanceToken.transfer(msg.sender, transferRgt), "Failed to transfer RGT from liquidity mining reserve.");
        rariGovernanceToken.burn(burnRgt);
        emit Claim(msg.sender, unclaimedRgt, transferRgt, burnRgt);
        return unclaimedRgt;
    }

    function upgrade(address newContract) external onlyOwner {

        require(disabled, "This governance token distributor contract must be disabled before it can be upgraded.");
        rariGovernanceToken.transfer(newContract, rariGovernanceToken.balanceOf(address(this)));
    }

    function setEthUsdPriceFeed() external onlyOwner {

        _ethUsdPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }
}