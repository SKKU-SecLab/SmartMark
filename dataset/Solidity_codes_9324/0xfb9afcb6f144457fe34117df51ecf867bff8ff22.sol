
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// Unlicense
pragma solidity 0.8.6;

interface IVotingEscrow {
    function create_lock(uint256, uint256) external;
    function increase_amount(uint256) external;
    function increase_unlock_time(uint256) external;
    function withdraw() external;
    function token() external view returns (address);
    function locked() external view returns (uint256);
    function locked__end(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}// Unlicense
pragma solidity ^0.8.0;

interface IDillGauge {
    function deposit(uint256) external;
    function depositFor(uint256, address) external;
    function depositAll() external;
    function withdraw(uint256) external;
    function withdrawAll() external;
    function exit() external;
    function getReward() external;
    function balanceOf(address) external view returns (uint256);
}// Unlicense
pragma solidity ^0.8.0;

interface IGaugeProxy {
    function collect() external;
    function deposit() external;
    function distribute() external;
    function vote(address[] memory, uint256[] memory) external;
}// Unlicense
pragma solidity 0.8.6;

interface IMinter {
    function mint(address) external;
    function mint_for(address, address) external;
}/// Unlicense
pragma solidity 0.8.6;

interface IFeeDistributor {
    function claim() external;
    function tokens() external view returns (address[] memory);
}// Unlicense
pragma solidity 0.8.6;

interface IFeeHandler {
    function handleFees(uint256[] memory) external;
}// Unlicense
pragma solidity ^0.8.0;

interface IUpgradeSource {
  function finalizeUpgrade() external;
  function shouldUpgrade() external view returns (bool, address);
}// Unlicense
pragma solidity ^0.8.0;

interface IVault {
    function underlyingBalanceInVault() external view returns (uint256);
    function underlyingBalanceWithInvestment() external view returns (uint256);

    function underlying() external view returns (address);
    function strategy() external view returns (address);

    function setStrategy(address) external;
    function setVaultFractionToInvest(uint256) external;

    function deposit(uint256) external;
    function depositFor(address, uint256) external;

    function withdrawAll() external;
    function withdraw(uint256) external;

    function getReward() external;
    function getRewardByToken(address) external;
    function notifyRewardAmount(address, uint256) external;

    function underlyingUnit() external view returns (uint256);
    function getPricePerFullShare() external view returns (uint256);
    function underlyingBalanceWithInvestmentForHolder(address) external view returns (uint256);

    function doHardWork() external;
    function rebalance() external;
}// UNLICENSED
pragma solidity ^0.8.0;


contract EternalStorage {
    mapping(bytes32 => uint256) private uint256Storage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bool) private boolStorage;

    function _setUint256(string memory _key, uint256 _value) internal {
        uint256Storage[keccak256(abi.encodePacked(_key))] = _value;
    }

    function _setAddress(string memory _key, address _value) internal {
        addressStorage[keccak256(abi.encodePacked(_key))] = _value;
    }

    function _setBool(string memory _key, bool _value) internal {
        boolStorage[keccak256(abi.encodePacked(_key))] = _value;
    }

    function _getUint256(string memory _key) internal view returns (uint256) {
        return uint256Storage[keccak256(abi.encodePacked(_key))];
    }

    function _getAddress(string memory _key) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked(_key))];
    }

    function _getBool(string memory _key) internal view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked(_key))];
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library SafeTransferLib {
    event Debug(bool one, bool two, uint256 retsize);


    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
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

contract Storage {

  address public governance;
  address public controller;

  constructor() {
    governance = msg.sender;
  }

  modifier onlyGovernance() {
    require(isGovernance(msg.sender), "Storage: Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {
    require(_governance != address(0), "Storage: New governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {
    require(_controller != address(0), "Storage: New controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {
    return account == governance;
  }

  function isController(address account) public view returns (bool) {
    return account == controller;
  }
}// Unlicense
pragma solidity ^0.8.0;



contract GovernableInit is Initializable {

  bytes32 internal constant _STORAGE_SLOT = 0xa7ec62784904ff31cbcc32d09932a58e7f1e4476e1d041995b37c917990b16dc;

  modifier onlyGovernance() {
    require(Storage(_storage()).isGovernance(msg.sender), "Governable: Not governance");
    _;
  }

  constructor() {
    assert(_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.governableInit.storage")) - 1));
  }

  function __Governable_init_(address _store) public initializer {
    _setStorage(_store);
  }

  function _setStorage(address newStorage) private {
    bytes32 slot = _STORAGE_SLOT;
    assembly {
      sstore(slot, newStorage)
    }
  }

  function setStorage(address _store) public onlyGovernance {
    require(_store != address(0), "Governable: New storage shouldn't be empty");
    _setStorage(_store);
  }

  function _storage() internal view returns (address str) {
    bytes32 slot = _STORAGE_SLOT;
    assembly {
      str := sload(slot)
    }
  }

  function governance() public view returns (address) {
    return Storage(_storage()).governance();
  }
}// UNLICENSED
pragma solidity 0.8.6;



contract VeManagerDillLike is GovernableInit, IUpgradeSource, EternalStorage {
    using SafeTransferLib for IERC20;

    struct GaugeInfo {
        uint16 lockNumerator;  // Percentage of rewards on this gauge to lock.
        uint16 kickbackNumerator;    // Percentage of rewards to distribute to the kickback pool.
        address strategy;   // Permitted strategy contract for using this gauge.
        address gauge;      // Gauge contract of the token.
    }

    mapping(address => GaugeInfo) public gaugeInfo;

    mapping(address => bool) public governors;

    mapping(address => bool) private infoExistsForGauge;

    event UpgradeAnnounced(address newImplementation);

    modifier onlyGovernors {
        _require(
            msg.sender == governance()
            || governors[msg.sender],
            Errors.GOVERNORS_ONLY
        );
        _;
    }

    function __Manager_init(
        address _store,
        uint256 _MAX_LOCK_TIME,
        address _escrow,
        address _controller
    ) external initializer {
        __Governable_init_(_store);

        _setMaxLockTime(_MAX_LOCK_TIME);

        _setVotingEscrow(_escrow);
        _setRewardToken(IVotingEscrow(_escrow).token());
        _setGaugeController(_controller);
        _setUpgradeTimelock(12 hours);
    }

    function lockTokens(uint256 _amount) external onlyGovernors {
        _lockRewards(_amount);
    }

    function lockAllTokens() external onlyGovernors {
        _lockRewards(rewardToken().balanceOf(address(this)));
    }

    function withdrawLock() external onlyGovernors {
        votingEscrow().withdraw();
        _setVeTokenLockActive(false);
    }

    function voteForGauge(address[] calldata _gauges, uint256[] calldata _weights) external onlyGovernors {
        gaugeController().vote(_gauges, _weights);
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyGovernance returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value: _value}(_data);

        return (success, result);
    }

    function depositGaugeTokens(address _token, uint256 _amount) external {
        GaugeInfo memory gaugeParams = gaugeInfo[_token];

        _require(msg.sender == gaugeParams.strategy, Errors.CALLER_NOT_STRATEGY);

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(_token).safeApprove(gaugeParams.gauge, 0);
        IERC20(_token).safeApprove(gaugeParams.gauge, _amount);

        IDillGauge(gaugeParams.gauge).deposit(_amount);
    }

    function withdrawGaugeTokens(address _token, uint256 _amount) external {
        GaugeInfo memory gaugeParams = gaugeInfo[_token];

        _require(msg.sender == gaugeParams.strategy, Errors.CALLER_NOT_STRATEGY);

        IDillGauge(gaugeParams.gauge).withdraw(_amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function divestAllGaugeTokens(address _token) external {
        GaugeInfo memory gaugeParams = gaugeInfo[_token];

        _require(msg.sender == gaugeParams.strategy, Errors.CALLER_NOT_STRATEGY);

        IDillGauge(gaugeParams.gauge).exit();
        IERC20(_token).safeTransfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function claimGaugeRewards(address _token) external {
        GaugeInfo memory gaugeParams = gaugeInfo[_token];
        IERC20 _rewardToken = rewardToken();

        _require(msg.sender == gaugeParams.strategy, Errors.CALLER_NOT_STRATEGY);

        IDillGauge(gaugeParams.gauge).getReward();

        uint256 gaugeEarnings = _rewardToken.balanceOf(address(this));
        if(gaugeEarnings > 0) {
            uint256 toLock = 0;
            uint256 kickback = 0;
            if(gaugeParams.lockNumerator > 0) {
                toLock = (gaugeEarnings * gaugeParams.lockNumerator) / 10000;
                _lockRewards(toLock);
            }

            if(gaugeParams.kickbackNumerator > 0) {
                IVault _kickbackPool = kickbackPool();
                kickback = (gaugeEarnings * gaugeParams.kickbackNumerator) / 10000;
                _rewardToken.safeTransfer(address(_kickbackPool), kickback);
                _kickbackPool.notifyRewardAmount(address(_rewardToken), kickback);
            }

            _rewardToken.safeTransfer(msg.sender, (gaugeEarnings - (toLock + kickback)));
        }
    }

    function claimEarnedFees() external {
        IFeeDistributor _feeDistributor = feeDistributor();
        address handlerAddress = address(feeHandler());
        address[] memory rewardTokens = _feeDistributor.tokens();
        uint256[] memory rewardBalances = new uint256[](rewardTokens.length);

        _feeDistributor.claim();

        if(handlerAddress != address(0)) {
            for(uint256 i = 0; i < rewardTokens.length; i++) {
                address reward = rewardTokens[i];
                uint256 rewardBalance = IERC20(rewardTokens[i]).balanceOf(address(this));
                rewardBalances[i] = rewardBalance;

                IERC20(reward).safeTransfer(handlerAddress, rewardBalance);
            }
            IFeeHandler(handlerAddress).handleFees(rewardBalances);
        }
    }

    function finalizeUpgrade() external override onlyGovernance {
        _setNextImplementation(address(0));
        _setNextImplementationTimestamp(0);
    }

    function shouldUpgrade() external view override returns (bool, address) {
        return (
            nextImplementationTimestamp() != 0
                && block.timestamp > nextImplementationTimestamp()
                && nextImplementation() != address(0),
            nextImplementation()
        );
    }

    function totalStakeForGauge(address _token) external view returns (uint256) {
        return IDillGauge(gaugeInfo[_token].gauge).balanceOf(address(this));
    }

    function scheduleUpgrade(address _impl) public onlyGovernance {
        _setNextImplementation(_impl);
        _setNextImplementationTimestamp(block.timestamp + upgradeTimelock());
        emit UpgradeAnnounced(_impl);
    }

    function recoverToken(
        address _token, 
        uint256 _amount
    ) public onlyGovernance {
        IERC20(_token).safeTransfer(governance(), _amount);
    }

    function addGauge(
        address _token,
        address _strategy,
        address _gauge,
        uint16 _lockNumerator,
        uint16 _kickbackNumerator
    ) public onlyGovernors {
        _require(!infoExistsForGauge[_token], Errors.GAUGE_INFO_ALREADY_EXISTS);
        GaugeInfo memory gaugeParams;
        gaugeParams.gauge = _gauge;
        gaugeParams.strategy = _strategy;
        gaugeParams.lockNumerator = _lockNumerator;
        gaugeParams.kickbackNumerator = _kickbackNumerator;

        gaugeInfo[_token] = gaugeParams;
        infoExistsForGauge[_token] = true;
    }

    function increaseLockTime(
        uint256 _increaseBy
    ) public onlyGovernors {
        IVotingEscrow _votingEscrow = votingEscrow();

        uint256 lockEnd = _votingEscrow.locked__end(address(this));
        _votingEscrow.increase_unlock_time((lockEnd + _increaseBy));
    }

    function setGaugeStrategy(
        address _token,
        address _newStrategy
    ) public onlyGovernors {
        _require(infoExistsForGauge[_token], Errors.GAUGE_NON_EXISTENT);

        GaugeInfo storage gaugeParams = gaugeInfo[_token];
        gaugeParams.strategy = _newStrategy;
    }

    function setGaugeLockNumerator(
        address _token,
        uint16 _newLockNumerator
    ) public onlyGovernors {
        _require(infoExistsForGauge[_token], Errors.GAUGE_NON_EXISTENT);

        GaugeInfo storage gaugeParams = gaugeInfo[_token];
        gaugeParams.lockNumerator = _newLockNumerator;
    }

    function setGaugeKickbackNumerator(
        address _token,
        uint16 _newKickbackNumerator
    ) public onlyGovernors {
        _require(infoExistsForGauge[_token], Errors.GAUGE_NON_EXISTENT);

        GaugeInfo storage gaugeParams = gaugeInfo[_token];
        gaugeParams.kickbackNumerator = _newKickbackNumerator;
    }

    function setFeeDistributor(
        address _feeDistributor
    ) public onlyGovernors {
        _setFeeDistributor(_feeDistributor);
    }

    function setFeeHandler(
        address _feeHandler
    ) public onlyGovernors {
        _setFeeHandler(_feeHandler);
    }

    function setKickbackPool(
        address _kickbackPool
    ) public onlyGovernors {
        _setKickbackPool(_kickbackPool);
    }

    function addGovernor(
        address _governor
    ) public onlyGovernance {
        governors[_governor] = true;
    }

    function removeGovernor(
        address _governor
    ) public onlyGovernance {
        governors[_governor] = false;
    }

    function netVeAssets() public view returns (uint256) {
        return IERC20(address(votingEscrow())).balanceOf(address(this));
    }

    function lockExpiration() public view returns (uint256) {
        return votingEscrow().locked__end(address(this));
    }

    function nextImplementation() public view returns (address) {
        return _getAddress("nextImplementation");
    }

    function nextImplementationTimestamp() public view returns (uint256) {
        return _getUint256("nextImplementationTimestamp");
    }

    function upgradeTimelock() public view returns (uint256) {
        return _getUint256("upgradeTimelock");
    }

    function maxLockTime() public view returns (uint256) {
        return _getUint256("maxLockTime");
    }

    function votingEscrow() public view returns (IVotingEscrow) {
        return IVotingEscrow(_getAddress("votingEscrow"));
    }

    function rewardToken() public view returns (IERC20) {
        return IERC20(_getAddress("rewardToken"));
    }

    function gaugeController() public view returns (IGaugeProxy) {
        return IGaugeProxy(_getAddress("gaugeController"));
    }

    function feeDistributor() public view returns (IFeeDistributor) {
        return IFeeDistributor(_getAddress("feeDistributor"));
    }

    function feeHandler() public view returns (IFeeHandler) {
        return IFeeHandler(_getAddress("feeHandler"));
    }

    function veTokenLockActive() public view returns (bool) {
        return _getBool("veTokenLockActive");
    }

    function kickbackPool() public view returns (IVault) {
        return IVault(_getAddress("kickbackPool"));
    }

    function _lockRewards(uint256 _amountToLock) internal {
        IERC20 _rewardToken = rewardToken();
        address escrowAddress = address(votingEscrow());

        _rewardToken.safeApprove(escrowAddress, 0);
        _rewardToken.safeApprove(escrowAddress, _amountToLock);

        if(veTokenLockActive()) {
            IVotingEscrow(escrowAddress).increase_amount(_amountToLock);
        } else {
            IVotingEscrow(escrowAddress).create_lock(_amountToLock, (block.timestamp + maxLockTime()));
            _setVeTokenLockActive(true);
        }
    }

    function _setNextImplementation(address _address) internal {
        _setAddress("nextImplementation", _address);
    }

    function _setNextImplementationTimestamp(uint256 _value) internal {
        _setUint256("nextImplementationTimestamp", _value);
    }

    function _setUpgradeTimelock(uint256 _value) internal {
        _setUint256("upgradeTimelock", _value);
    }

    function _setMaxLockTime(uint256 _value) internal {
        _setUint256("maxLockTime", _value);
    }

    function _setVotingEscrow(address _value) internal {
        _setAddress("votingEscrow", _value);
    }

    function _setRewardToken(address _value) internal {
        _setAddress("rewardToken", _value);
    }

    function _setGaugeController(address _value) internal {
        _setAddress("gaugeController", _value);
    }

    function _setRewardMinter(address _value) internal {
        _setAddress("rewardMinter", _value);
    }

    function _setFeeDistributor(address _value) internal {
        _setAddress("feeDistributor", _value);
    }

    function _setFeeHandler(address _value) internal {
        _setAddress("feeHandler", _value);
    }

    function _setVeTokenLockActive(bool _value) internal {
        _setBool("veTokenLockActive", _value);
    }

    function _setKickbackPool(address _value) internal {
        _setAddress("kickbackPool", _value);
    }

    function findArrayItem(address[] memory _array, address _item) private pure returns (uint256) {
        for(uint256 i = 0; i < _array.length; i++) {
            if(_array[i] == _item) {
                return i;
            }
        }
        return type(uint256).max;
    }
}// GPL-3.0-or-later

pragma solidity ^0.8.0;


function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

function _revert(uint256 errorCode) pure {
    assembly {

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)


        let revertReason := shl(200, add(0x42454C23000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))


        mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
        mstore(0x24, 7)
        mstore(0x44, revertReason)

        revert(0, 100)
    }
}



library Errors {
    uint256 internal constant NUMERATOR_ABOVE_MAX_BUFFER = 0;
    uint256 internal constant UNDEFINED_STRATEGY = 1;
    uint256 internal constant CALLER_NOT_WHITELISTED = 2;
    uint256 internal constant VAULT_HAS_NO_SHARES = 3;
    uint256 internal constant SHARES_MUST_NOT_BE_ZERO = 4;
    uint256 internal constant LOSSES_ON_DOHARDWORK = 5;
    uint256 internal constant CANNOT_UPDATE_STRATEGY = 6;
    uint256 internal constant NEW_STRATEGY_CANNOT_BE_EMPTY = 7;
    uint256 internal constant VAULT_AND_STRATEGY_UNDERLYING_MUST_MATCH = 8;
    uint256 internal constant STRATEGY_DOES_NOT_BELONG_TO_VAULT = 9;
    uint256 internal constant CALLER_NOT_GOV_OR_REWARD_DIST = 10;
    uint256 internal constant NOTIF_AMOUNT_INVOKES_OVERFLOW = 11;
    uint256 internal constant REWARD_INDICE_NOT_FOUND = 12;
    uint256 internal constant REWARD_TOKEN_ALREADY_EXIST = 13;
    uint256 internal constant DURATION_CANNOT_BE_ZERO = 14;
    uint256 internal constant REWARD_TOKEN_DOES_NOT_EXIST = 15;
    uint256 internal constant REWARD_PERIOD_HAS_NOT_ENDED = 16;
    uint256 internal constant CANNOT_REMOVE_LAST_REWARD_TOKEN = 17;
    uint256 internal constant DENOMINATOR_MUST_BE_GTE_NUMERATOR = 18;
    uint256 internal constant CANNOT_UPDATE_EXIT_FEE = 19;
    uint256 internal constant CANNOT_TRANSFER_IMMATURE_TOKENS = 20;
    uint256 internal constant CANNOT_DEPOSIT_ZERO = 21;
    uint256 internal constant HOLDER_MUST_BE_DEFINED = 22;

    uint256 internal constant GOVERNORS_ONLY = 23;
    uint256 internal constant CALLER_NOT_STRATEGY = 24;
    uint256 internal constant GAUGE_INFO_ALREADY_EXISTS = 25;
    uint256 internal constant GAUGE_NON_EXISTENT = 26;

    uint256 internal constant CALL_RESTRICTED = 27;
    uint256 internal constant STRATEGY_IN_EMERGENCY_STATE = 28;
    uint256 internal constant REWARD_POOL_UNDERLYING_MISMATCH = 29;
    uint256 internal constant UNSALVAGABLE_TOKEN = 30;

    uint256 internal constant ARRAY_LENGTHS_DO_NOT_MATCH = 31;
    uint256 internal constant WEIGHTS_DO_NOT_ADD_UP = 32;
    uint256 internal constant REBALANCE_REQUIRED = 33;
    uint256 internal constant INDICE_DOES_NOT_EXIST = 34;

    uint256 internal constant WITHDRAWAL_WINDOW_NOT_ACTIVE = 35;

    uint256 internal constant CANNOT_WITHDRAW_MORE_THAN_STAKE = 36;

    uint256 internal constant TX_ORIGIN_NOT_PERMITTED = 37;
}