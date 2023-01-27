

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
}


pragma solidity >=0.4.24 <0.7.0;



contract InitializableV2 is Initializable {

    bool private isInitialized;

    string private constant ERROR_NOT_INITIALIZED = "InitializableV2: Not initialized";

    function initialize() public initializer {

        isInitialized = true;
    }

    function _requireIsInitialized() internal view {

        require(isInitialized == true, ERROR_NOT_INITIALIZED);
    }

    function _isInitialized() internal view returns (bool) {

        return isInitialized;
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


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;





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
}


pragma solidity ^0.5.0;




contract ERC20Burnable is Initializable, Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.8;


library Checkpointing {

    uint256 private constant MAX_UINT192 = uint256(uint192(-1));

    string private constant ERROR_VALUE_TOO_BIG = "CHECKPOINT_VALUE_TOO_BIG";
    string private constant ERROR_CANNOT_ADD_PAST_VALUE = "CHECKPOINT_CANNOT_ADD_PAST_VALUE";

    struct Checkpoint {
        uint64 time;
        uint192 value;
    }

    struct History {
        Checkpoint[] history;
    }

    function add(History storage self, uint64 _time, uint256 _value) internal {

        require(_value <= MAX_UINT192, ERROR_VALUE_TOO_BIG);
        _add192(self, _time, uint192(_value));
    }

    function getLast(History storage self) internal view returns (uint256) {

        uint256 length = self.history.length;
        if (length > 0) {
            return uint256(self.history[length - 1].value);
        }

        return 0;
    }

    function get(History storage self, uint64 _time) internal view returns (uint256) {

        return _binarySearch(self, _time);
    }

    function getRecent(History storage self, uint64 _time) internal view returns (uint256) {

        return _backwardsLinearSearch(self, _time);
    }

    function _add192(History storage self, uint64 _time, uint192 _value) private {

        uint256 length = self.history.length;
        if (length == 0 || self.history[self.history.length - 1].time < _time) {
            self.history.push(Checkpoint(_time, _value));
        } else {
            Checkpoint storage currentCheckpoint = self.history[length - 1];
            require(_time == currentCheckpoint.time, ERROR_CANNOT_ADD_PAST_VALUE);
            currentCheckpoint.value = _value;
        }
    }

    function _backwardsLinearSearch(History storage self, uint64 _time) private view returns (uint256) {

        uint256 length = self.history.length;
        if (length == 0) {
            return 0;
        }

        uint256 index = length - 1;
        Checkpoint storage checkpoint = self.history[index];
        while (index > 0 && checkpoint.time > _time) {
            index--;
            checkpoint = self.history[index];
        }

        return checkpoint.time > _time ? 0 : uint256(checkpoint.value);
    }

    function _binarySearch(History storage self, uint64 _time) private view returns (uint256) {

        uint256 length = self.history.length;
        if (length == 0) {
            return 0;
        }

        uint256 lastIndex = length - 1;
        if (_time >= self.history[lastIndex].time) {
            return uint256(self.history[lastIndex].value);
        }

        if (_time < self.history[0].time) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = lastIndex;

        while (high > low) {
            uint256 mid = (high + low + 1) / 2;
            Checkpoint storage checkpoint = self.history[mid];
            uint64 midTime = checkpoint.time;

            if (_time > midTime) {
                low = mid;
            } else if (_time < midTime) {
                high = mid - 1;
            } else {
                return uint256(checkpoint.value);
            }
        }

        return uint256(self.history[low].value);
    }
}


// Adapted to use pragma ^0.5.8 and satisfy our linter rules

pragma solidity ^0.5.8;


library Uint256Helpers {

    uint256 private constant MAX_UINT8 = uint8(-1);
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_UINT8_NUMBER_TOO_BIG = "UINT8_NUMBER_TOO_BIG";
    string private constant ERROR_UINT64_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint8(uint256 a) internal pure returns (uint8) {

        require(a <= MAX_UINT8, ERROR_UINT8_NUMBER_TOO_BIG);
        return uint8(a);
    }

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_UINT64_NUMBER_TOO_BIG);
        return uint64(a);
    }
}


pragma solidity ^0.5.0;









contract Staking is InitializableV2 {

    using SafeMath for uint256;
    using Uint256Helpers for uint256;
    using Checkpointing for Checkpointing.History;
    using SafeERC20 for ERC20;

    string private constant ERROR_TOKEN_NOT_CONTRACT = "Staking: Staking token is not a contract";
    string private constant ERROR_AMOUNT_ZERO = "Staking: Zero amount not allowed";
    string private constant ERROR_ONLY_GOVERNANCE = "Staking: Only governance";
    string private constant ERROR_ONLY_DELEGATE_MANAGER = (
      "Staking: Only callable from DelegateManager"
    );
    string private constant ERROR_ONLY_SERVICE_PROVIDER_FACTORY = (
      "Staking: Only callable from ServiceProviderFactory"
    );

    address private governanceAddress;
    address private claimsManagerAddress;
    address private delegateManagerAddress;
    address private serviceProviderFactoryAddress;

    struct Account {
        Checkpointing.History stakedHistory;
        Checkpointing.History claimHistory;
    }

    ERC20 internal stakingToken;

    mapping (address => Account) internal accounts;

    Checkpointing.History internal totalStakedHistory;

    event Staked(address indexed user, uint256 amount, uint256 total);
    event Unstaked(address indexed user, uint256 amount, uint256 total);
    event Slashed(address indexed user, uint256 amount, uint256 total);

    function initialize(
        address _tokenAddress,
        address _governanceAddress
    ) public initializer
    {

        require(Address.isContract(_tokenAddress), ERROR_TOKEN_NOT_CONTRACT);
        stakingToken = ERC20(_tokenAddress);
        _updateGovernanceAddress(_governanceAddress);
        InitializableV2.initialize();
    }

    function setGovernanceAddress(address _governanceAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        _updateGovernanceAddress(_governanceAddress);
    }

    function setClaimsManagerAddress(address _claimsManager) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        claimsManagerAddress = _claimsManager;
    }

    function setServiceProviderFactoryAddress(address _spFactory) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        serviceProviderFactoryAddress = _spFactory;
    }

    function setDelegateManagerAddress(address _delegateManager) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        delegateManagerAddress = _delegateManager;
    }


    function stakeRewards(uint256 _amount, address _stakerAccount) external {

        _requireIsInitialized();
        _requireClaimsManagerAddressIsSet();

        require(
            msg.sender == claimsManagerAddress,
            "Staking: Only callable from ClaimsManager"
        );
        _stakeFor(_stakerAccount, msg.sender, _amount);

        this.updateClaimHistory(_amount, _stakerAccount);
    }

    function updateClaimHistory(uint256 _amount, address _stakerAccount) external {

        _requireIsInitialized();
        _requireClaimsManagerAddressIsSet();

        require(
            msg.sender == claimsManagerAddress || msg.sender == address(this),
            "Staking: Only callable from ClaimsManager or Staking.sol"
        );

        accounts[_stakerAccount].claimHistory.add(block.number.toUint64(), _amount);
    }

    function slash(
        uint256 _amount,
        address _slashAddress
    ) external
    {

        _requireIsInitialized();
        _requireDelegateManagerAddressIsSet();

        require(
            msg.sender == delegateManagerAddress,
            ERROR_ONLY_DELEGATE_MANAGER
        );

        _burnFor(_slashAddress, _amount);

        emit Slashed(
            _slashAddress,
            _amount,
            totalStakedFor(_slashAddress)
        );
    }

    function stakeFor(
        address _accountAddress,
        uint256 _amount
    ) external
    {

        _requireIsInitialized();
        _requireServiceProviderFactoryAddressIsSet();

        require(
            msg.sender == serviceProviderFactoryAddress,
            ERROR_ONLY_SERVICE_PROVIDER_FACTORY
        );
        _stakeFor(
            _accountAddress,
            _accountAddress,
            _amount
        );
    }

    function unstakeFor(
        address _accountAddress,
        uint256 _amount
    ) external
    {

        _requireIsInitialized();
        _requireServiceProviderFactoryAddressIsSet();

        require(
            msg.sender == serviceProviderFactoryAddress,
            ERROR_ONLY_SERVICE_PROVIDER_FACTORY
        );
        _unstakeFor(
            _accountAddress,
            _accountAddress,
            _amount
        );
    }

    function delegateStakeFor(
        address _accountAddress,
        address _delegatorAddress,
        uint256 _amount
    ) external {

        _requireIsInitialized();
        _requireDelegateManagerAddressIsSet();

        require(
            msg.sender == delegateManagerAddress,
            ERROR_ONLY_DELEGATE_MANAGER
        );
        _stakeFor(
            _accountAddress,
            _delegatorAddress,
            _amount);
    }

    function undelegateStakeFor(
        address _accountAddress,
        address _delegatorAddress,
        uint256 _amount
    ) external {

        _requireIsInitialized();
        _requireDelegateManagerAddressIsSet();

        require(
            msg.sender == delegateManagerAddress,
            ERROR_ONLY_DELEGATE_MANAGER
        );
        _unstakeFor(
            _accountAddress,
            _delegatorAddress,
            _amount);
    }

    function token() external view returns (address) {

        _requireIsInitialized();

        return address(stakingToken);
    }

    function supportsHistory() external view returns (bool) {

        _requireIsInitialized();

        return true;
    }

    function lastStakedFor(address _accountAddress) external view returns (uint256) {

        _requireIsInitialized();

        uint256 length = accounts[_accountAddress].stakedHistory.history.length;
        if (length > 0) {
            return uint256(accounts[_accountAddress].stakedHistory.history[length - 1].time);
        }
        return 0;
    }

    function lastClaimedFor(address _accountAddress) external view returns (uint256) {

        _requireIsInitialized();

        uint256 length = accounts[_accountAddress].claimHistory.history.length;
        if (length > 0) {
            return uint256(accounts[_accountAddress].claimHistory.history[length - 1].time);
        }
        return 0;
    }

    function totalStakedForAt(
        address _accountAddress,
        uint256 _blockNumber
    ) external view returns (uint256) {

        _requireIsInitialized();

        return accounts[_accountAddress].stakedHistory.get(_blockNumber.toUint64());
    }

    function totalStakedAt(uint256 _blockNumber) external view returns (uint256) {

        _requireIsInitialized();

        return totalStakedHistory.get(_blockNumber.toUint64());
    }

    function getGovernanceAddress() external view returns (address) {

        _requireIsInitialized();

        return governanceAddress;
    }

    function getClaimsManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return claimsManagerAddress;
    }

    function getServiceProviderFactoryAddress() external view returns (address) {

        _requireIsInitialized();

        return serviceProviderFactoryAddress;
    }

    function getDelegateManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return delegateManagerAddress;
    }

    function isStaker(address _accountAddress) external view returns (bool) {

        _requireIsInitialized();

        return totalStakedFor(_accountAddress) > 0;
    }


    function totalStakedFor(address _accountAddress) public view returns (uint256) {

        _requireIsInitialized();

        return accounts[_accountAddress].stakedHistory.getLast();
    }

    function totalStaked() public view returns (uint256) {

        _requireIsInitialized();

        return totalStakedHistory.getLast();
    }


    function _stakeFor(
        address _stakeAccount,
        address _transferAccount,
        uint256 _amount
    ) internal
    {

        require(_amount > 0, ERROR_AMOUNT_ZERO);

        _modifyStakeBalance(_stakeAccount, _amount, true);

        _modifyTotalStaked(_amount, true);

        stakingToken.safeTransferFrom(_transferAccount, address(this), _amount);

        emit Staked(
            _stakeAccount,
            _amount,
            totalStakedFor(_stakeAccount));
    }

    function _unstakeFor(
        address _stakeAccount,
        address _transferAccount,
        uint256 _amount
    ) internal
    {

        require(_amount > 0, ERROR_AMOUNT_ZERO);

        _modifyStakeBalance(_stakeAccount, _amount, false);

        _modifyTotalStaked(_amount, false);

        stakingToken.safeTransfer(_transferAccount, _amount);

        emit Unstaked(
            _stakeAccount,
            _amount,
            totalStakedFor(_stakeAccount)
        );
    }

    function _burnFor(address _stakeAccount, uint256 _amount) internal {

        require(_amount > 0, ERROR_AMOUNT_ZERO);

        _modifyStakeBalance(_stakeAccount, _amount, false);

        _modifyTotalStaked(_amount, false);

        ERC20Burnable(address(stakingToken)).burn(_amount);

    }

    function _modifyStakeBalance(address _accountAddress, uint256 _by, bool _increase) internal {

        uint256 currentInternalStake = accounts[_accountAddress].stakedHistory.getLast();

        uint256 newStake;
        if (_increase) {
            newStake = currentInternalStake.add(_by);
        } else {
            require(
                currentInternalStake >= _by,
                "Staking: Cannot decrease greater than current balance");
            newStake = currentInternalStake.sub(_by);
        }

        accounts[_accountAddress].stakedHistory.add(block.number.toUint64(), newStake);
    }

    function _modifyTotalStaked(uint256 _by, bool _increase) internal {

        uint256 currentStake = totalStaked();

        uint256 newStake;
        if (_increase) {
            newStake = currentStake.add(_by);
        } else {
            newStake = currentStake.sub(_by);
        }

        totalStakedHistory.add(block.number.toUint64(), newStake);
    }

    function _updateGovernanceAddress(address _governanceAddress) internal {

        require(
            Governance(_governanceAddress).isGovernanceAddress() == true,
            "Staking: _governanceAddress is not a valid governance contract"
        );
        governanceAddress = _governanceAddress;
    }


    function _requireClaimsManagerAddressIsSet() private view {

        require(claimsManagerAddress != address(0x00), "Staking: claimsManagerAddress is not set");
    }

    function _requireDelegateManagerAddressIsSet() private view {

        require(
            delegateManagerAddress != address(0x00),
            "Staking: delegateManagerAddress is not set"
        );
    }

    function _requireServiceProviderFactoryAddressIsSet() private view {

        require(
            serviceProviderFactoryAddress != address(0x00),
            "Staking: serviceProviderFactoryAddress is not set"
        );
    }

}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract MinterRole is Initializable, Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {

        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract ERC20Mintable is Initializable, ERC20, MinterRole {

    function initialize(address sender) public initializer {

        MinterRole.initialize(sender);
    }

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;



contract ClaimsManager is InitializableV2 {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    string private constant ERROR_ONLY_GOVERNANCE = (
        "ClaimsManager: Only callable by Governance contract"
    );

    address private governanceAddress;
    address private stakingAddress;
    address private serviceProviderFactoryAddress;
    address private delegateManagerAddress;

    uint256 private fundingRoundBlockDiff;

    uint256 private fundingAmount;

    uint256 private roundNumber;

    ERC20Mintable private audiusToken;

    address private communityPoolAddress;

    uint256 private recurringCommunityFundingAmount;

    struct Round {
        uint256 fundedBlock;
        uint256 fundedAmount;
        uint256 totalClaimedInRound;
    }

    Round private currentRound;

    event RoundInitiated(
      uint256 indexed _blockNumber,
      uint256 indexed _roundNumber,
      uint256 indexed _fundAmount
    );

    event ClaimProcessed(
      address indexed _claimer,
      uint256 indexed _rewards,
      uint256 _oldTotal,
      uint256 indexed _newTotal
    );

    event CommunityRewardsTransferred(
      address indexed _transferAddress,
      uint256 indexed _amount
    );

    event FundingAmountUpdated(uint256 indexed _amount);
    event FundingRoundBlockDiffUpdated(uint256 indexed _blockDifference);
    event GovernanceAddressUpdated(address indexed _newGovernanceAddress);
    event StakingAddressUpdated(address indexed _newStakingAddress);
    event ServiceProviderFactoryAddressUpdated(address indexed _newServiceProviderFactoryAddress);
    event DelegateManagerAddressUpdated(address indexed _newDelegateManagerAddress);
    event RecurringCommunityFundingAmountUpdated(uint256 indexed _amount);
    event CommunityPoolAddressUpdated(address indexed _newCommunityPoolAddress);

    function initialize(
        address _tokenAddress,
        address _governanceAddress
    ) public initializer
    {

        _updateGovernanceAddress(_governanceAddress);

        audiusToken = ERC20Mintable(_tokenAddress);

        fundingRoundBlockDiff = 46523;
        fundingAmount = 1342465753420000000000000; // 1342465.75342 AUDS
        roundNumber = 0;

        currentRound = Round({
            fundedBlock: 0,
            fundedAmount: 0,
            totalClaimedInRound: 0
        });

        recurringCommunityFundingAmount = 0;
        communityPoolAddress = address(0x0);

        InitializableV2.initialize();
    }

    function getFundingRoundBlockDiff() external view returns (uint256)
    {

        _requireIsInitialized();

        return fundingRoundBlockDiff;
    }

    function getLastFundedBlock() external view returns (uint256)
    {

        _requireIsInitialized();

        return currentRound.fundedBlock;
    }

    function getFundsPerRound() external view returns (uint256)
    {

        _requireIsInitialized();

        return fundingAmount;
    }

    function getTotalClaimedInRound() external view returns (uint256)
    {

        _requireIsInitialized();

        return currentRound.totalClaimedInRound;
    }

    function getGovernanceAddress() external view returns (address) {

        _requireIsInitialized();

        return governanceAddress;
    }

    function getServiceProviderFactoryAddress() external view returns (address) {

        _requireIsInitialized();

        return serviceProviderFactoryAddress;
    }

    function getDelegateManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return delegateManagerAddress;
    }

    function getStakingAddress() external view returns (address)
    {

        _requireIsInitialized();

        return stakingAddress;
    }

    function getCommunityPoolAddress() external view returns (address)
    {

        _requireIsInitialized();

        return communityPoolAddress;
    }

    function getRecurringCommunityFundingAmount() external view returns (uint256)
    {

        _requireIsInitialized();

        return recurringCommunityFundingAmount;
    }

    function setGovernanceAddress(address _governanceAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        _updateGovernanceAddress(_governanceAddress);
        emit GovernanceAddressUpdated(_governanceAddress);
    }

    function setStakingAddress(address _stakingAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        stakingAddress = _stakingAddress;
        emit StakingAddressUpdated(_stakingAddress);
    }

    function setServiceProviderFactoryAddress(address _serviceProviderFactoryAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        serviceProviderFactoryAddress = _serviceProviderFactoryAddress;
        emit ServiceProviderFactoryAddressUpdated(_serviceProviderFactoryAddress);
    }

    function setDelegateManagerAddress(address _delegateManagerAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        delegateManagerAddress = _delegateManagerAddress;
        emit DelegateManagerAddressUpdated(_delegateManagerAddress);
    }

    function initiateRound() external {

        _requireIsInitialized();
        _requireStakingAddressIsSet();

        require(
            block.number.sub(currentRound.fundedBlock) > fundingRoundBlockDiff,
            "ClaimsManager: Required block difference not met"
        );

        currentRound = Round({
            fundedBlock: block.number,
            fundedAmount: fundingAmount,
            totalClaimedInRound: 0
        });

        roundNumber = roundNumber.add(1);

        if (recurringCommunityFundingAmount > 0 && communityPoolAddress != address(0x0)) {
            audiusToken.mint(address(this), recurringCommunityFundingAmount);

            audiusToken.approve(communityPoolAddress, recurringCommunityFundingAmount);

            ERC20(address(audiusToken)).safeTransfer(communityPoolAddress, recurringCommunityFundingAmount);

            emit CommunityRewardsTransferred(communityPoolAddress, recurringCommunityFundingAmount);
        }

        emit RoundInitiated(
            currentRound.fundedBlock,
            roundNumber,
            currentRound.fundedAmount
        );
    }

    function processClaim(
        address _claimer,
        uint256 _totalLockedForSP
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireDelegateManagerAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();

        require(
            msg.sender == delegateManagerAddress,
            "ClaimsManager: ProcessClaim only accessible to DelegateManager"
        );

        Staking stakingContract = Staking(stakingAddress);
        uint256 lastUserClaimBlock = stakingContract.lastClaimedFor(_claimer);
        require(
            lastUserClaimBlock <= currentRound.fundedBlock,
            "ClaimsManager: Claim already processed for user"
        );
        uint256 totalStakedAtFundBlockForClaimer = stakingContract.totalStakedForAt(
            _claimer,
            currentRound.fundedBlock);

        (,,bool withinBounds,,,) = (
            ServiceProviderFactory(serviceProviderFactoryAddress).getServiceProviderDetails(_claimer)
        );

        uint256 totalActiveClaimerStake = totalStakedAtFundBlockForClaimer.sub(_totalLockedForSP);
        uint256 totalStakedAtFundBlock = stakingContract.totalStakedAt(currentRound.fundedBlock);

        uint256 rewardsForClaimer = (
          totalActiveClaimerStake.mul(fundingAmount)
        ).div(totalStakedAtFundBlock);

        if (!withinBounds || rewardsForClaimer == 0) {
            stakingContract.updateClaimHistory(0, _claimer);
            emit ClaimProcessed(
                _claimer,
                0,
                totalStakedAtFundBlockForClaimer,
                totalActiveClaimerStake
            );
            return 0;
        }

        audiusToken.mint(address(this), rewardsForClaimer);

        audiusToken.approve(stakingAddress, rewardsForClaimer);

        stakingContract.stakeRewards(rewardsForClaimer, _claimer);

        currentRound.totalClaimedInRound = currentRound.totalClaimedInRound.add(rewardsForClaimer);

        uint256 newTotal = stakingContract.totalStakedFor(_claimer);

        emit ClaimProcessed(
            _claimer,
            rewardsForClaimer,
            totalStakedAtFundBlockForClaimer,
            newTotal
        );

        return rewardsForClaimer;
    }

    function updateFundingAmount(uint256 _newAmount) external
    {

        _requireIsInitialized();
        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        fundingAmount = _newAmount;
        emit FundingAmountUpdated(_newAmount);
    }

    function claimPending(address _sp) external view returns (bool) {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();

        uint256 lastClaimedForSP = Staking(stakingAddress).lastClaimedFor(_sp);
        (,,,uint256 numEndpoints,,) = (
            ServiceProviderFactory(serviceProviderFactoryAddress).getServiceProviderDetails(_sp)
        );
        return (lastClaimedForSP < currentRound.fundedBlock && numEndpoints > 0);
    }

    function updateFundingRoundBlockDiff(uint256 _newFundingRoundBlockDiff) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        emit FundingRoundBlockDiffUpdated(_newFundingRoundBlockDiff);
        fundingRoundBlockDiff = _newFundingRoundBlockDiff;
    }

    function updateRecurringCommunityFundingAmount(
        uint256 _newRecurringCommunityFundingAmount
    ) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        recurringCommunityFundingAmount = _newRecurringCommunityFundingAmount;
        emit RecurringCommunityFundingAmountUpdated(_newRecurringCommunityFundingAmount);
    }

    function updateCommunityPoolAddress(address _newCommunityPoolAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        communityPoolAddress = _newCommunityPoolAddress;
        emit CommunityPoolAddressUpdated(_newCommunityPoolAddress);
    }


    function _updateGovernanceAddress(address _governanceAddress) private {

        require(
            Governance(_governanceAddress).isGovernanceAddress() == true,
            "ClaimsManager: _governanceAddress is not a valid governance contract"
        );
        governanceAddress = _governanceAddress;
    }

    function _requireStakingAddressIsSet() private view {

        require(stakingAddress != address(0x00), "ClaimsManager: stakingAddress is not set");
    }

    function _requireDelegateManagerAddressIsSet() private view {

        require(
            delegateManagerAddress != address(0x00),
            "ClaimsManager: delegateManagerAddress is not set"
        );
    }

    function _requireServiceProviderFactoryAddressIsSet() private view {

        require(
            serviceProviderFactoryAddress != address(0x00),
            "ClaimsManager: serviceProviderFactoryAddress is not set"
        );
    }
}


pragma solidity ^0.5.0;




contract ServiceProviderFactory is InitializableV2 {

    using SafeMath for uint256;

    uint256 private constant DEPLOYER_CUT_BASE = 100;

    string private constant ERROR_ONLY_GOVERNANCE = (
        "ServiceProviderFactory: Only callable by Governance contract"
    );
    string private constant ERROR_ONLY_SP_GOVERNANCE = (
        "ServiceProviderFactory: Only callable by Service Provider or Governance"
    );

    address private stakingAddress;
    address private delegateManagerAddress;
    address private governanceAddress;
    address private serviceTypeManagerAddress;
    address private claimsManagerAddress;

    uint256 private decreaseStakeLockupDuration;

    uint256 private deployerCutLockupDuration;

    struct ServiceProviderDetails {
        uint256 deployerStake;
        uint256 deployerCut;
        bool validBounds;
        uint256 numberOfEndpoints;
        uint256 minAccountStake;
        uint256 maxAccountStake;
    }

    struct DecreaseStakeRequest {
        uint256 decreaseAmount;
        uint256 lockupExpiryBlock;
    }

    struct UpdateDeployerCutRequest {
        uint256 newDeployerCut;
        uint256 lockupExpiryBlock;
    }

    struct ServiceEndpoint {
        address owner;
        string endpoint;
        uint256 blocknumber;
        address delegateOwnerWallet;
    }

    mapping(address => ServiceProviderDetails) private spDetails;

    mapping(bytes32 => uint256) private serviceProviderTypeIDs;

    mapping(bytes32 => mapping(uint256 => ServiceEndpoint)) private serviceProviderInfo;

    mapping(bytes32 => uint256) private serviceProviderEndpointToId;

    mapping(address => mapping(bytes32 => uint256[])) private serviceProviderAddressToId;

    mapping(address => DecreaseStakeRequest) private decreaseStakeRequests;

    mapping(address => UpdateDeployerCutRequest) private updateDeployerCutRequests;

    event RegisteredServiceProvider(
      uint256 indexed _spID,
      bytes32 indexed _serviceType,
      address indexed _owner,
      string _endpoint,
      uint256 _stakeAmount
    );

    event DeregisteredServiceProvider(
      uint256 indexed _spID,
      bytes32 indexed _serviceType,
      address indexed _owner,
      string _endpoint,
      uint256 _unstakeAmount
    );

    event IncreasedStake(
      address indexed _owner,
      uint256 indexed _increaseAmount,
      uint256 indexed _newStakeAmount
    );

    event DecreaseStakeRequested(
      address indexed _owner,
      uint256 indexed _decreaseAmount,
      uint256 indexed _lockupExpiryBlock
    );

    event DecreaseStakeRequestCancelled(
      address indexed _owner,
      uint256 indexed _decreaseAmount,
      uint256 indexed _lockupExpiryBlock
    );

    event DecreaseStakeRequestEvaluated(
      address indexed _owner,
      uint256 indexed _decreaseAmount,
      uint256 indexed _newStakeAmount
    );

    event EndpointUpdated(
      bytes32 indexed _serviceType,
      address indexed _owner,
      string _oldEndpoint,
      string _newEndpoint,
      uint256 indexed _spID
    );

    event DelegateOwnerWalletUpdated(
      address indexed _owner,
      bytes32 indexed _serviceType,
      uint256 indexed _spID,
      address _updatedWallet
    );

    event DeployerCutUpdateRequested(
      address indexed _owner,
      uint256 indexed _updatedCut,
      uint256 indexed _lockupExpiryBlock
    );

    event DeployerCutUpdateRequestCancelled(
      address indexed _owner,
      uint256 indexed _requestedCut,
      uint256 indexed _finalCut
    );

    event DeployerCutUpdateRequestEvaluated(
      address indexed _owner,
      uint256 indexed _updatedCut
    );

    event DecreaseStakeLockupDurationUpdated(uint256 indexed _lockupDuration);
    event UpdateDeployerCutLockupDurationUpdated(uint256 indexed _lockupDuration);
    event GovernanceAddressUpdated(address indexed _newGovernanceAddress);
    event StakingAddressUpdated(address indexed _newStakingAddress);
    event ClaimsManagerAddressUpdated(address indexed _newClaimsManagerAddress);
    event DelegateManagerAddressUpdated(address indexed _newDelegateManagerAddress);
    event ServiceTypeManagerAddressUpdated(address indexed _newServiceTypeManagerAddress);

    function initialize (
        address _governanceAddress,
        address _claimsManagerAddress,
        uint256 _decreaseStakeLockupDuration,
        uint256 _deployerCutLockupDuration
    ) public initializer
    {
        _updateGovernanceAddress(_governanceAddress);
        claimsManagerAddress = _claimsManagerAddress;
        _updateDecreaseStakeLockupDuration(_decreaseStakeLockupDuration);
        _updateDeployerCutLockupDuration(_deployerCutLockupDuration);
        InitializableV2.initialize();
    }

    function register(
        bytes32 _serviceType,
        string calldata _endpoint,
        uint256 _stakeAmount,
        address _delegateOwnerWallet
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceTypeManagerAddressIsSet();
        _requireClaimsManagerAddressIsSet();

        require(
            ServiceTypeManager(serviceTypeManagerAddress).serviceTypeIsValid(_serviceType),
            "ServiceProviderFactory: Valid service type required");

        if (_stakeAmount > 0) {
            require(
                !_claimPending(msg.sender),
                "ServiceProviderFactory: No pending claim expected"
            );
            Staking(stakingAddress).stakeFor(msg.sender, _stakeAmount);
        }

        require (
            serviceProviderEndpointToId[keccak256(bytes(_endpoint))] == 0,
            "ServiceProviderFactory: Endpoint already registered");

        uint256 newServiceProviderID = serviceProviderTypeIDs[_serviceType].add(1);
        serviceProviderTypeIDs[_serviceType] = newServiceProviderID;

        serviceProviderInfo[_serviceType][newServiceProviderID] = ServiceEndpoint({
            owner: msg.sender,
            endpoint: _endpoint,
            blocknumber: block.number,
            delegateOwnerWallet: _delegateOwnerWallet
        });

        serviceProviderEndpointToId[keccak256(bytes(_endpoint))] = newServiceProviderID;

        serviceProviderAddressToId[msg.sender][_serviceType].push(newServiceProviderID);

        spDetails[msg.sender].numberOfEndpoints = spDetails[msg.sender].numberOfEndpoints.add(1);

        spDetails[msg.sender].deployerStake = (
            spDetails[msg.sender].deployerStake.add(_stakeAmount)
        );

        (, uint256 typeMin, uint256 typeMax) = ServiceTypeManager(
            serviceTypeManagerAddress
        ).getServiceTypeInfo(_serviceType);
        spDetails[msg.sender].minAccountStake = spDetails[msg.sender].minAccountStake.add(typeMin);
        spDetails[msg.sender].maxAccountStake = spDetails[msg.sender].maxAccountStake.add(typeMax);

        this.validateAccountStakeBalance(msg.sender);
        uint256 currentlyStakedForOwner = Staking(stakingAddress).totalStakedFor(msg.sender);


        spDetails[msg.sender].validBounds = true;

        emit RegisteredServiceProvider(
            newServiceProviderID,
            _serviceType,
            msg.sender,
            _endpoint,
            currentlyStakedForOwner
        );

        return newServiceProviderID;
    }

    function deregister(
        bytes32 _serviceType,
        string calldata _endpoint
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceTypeManagerAddressIsSet();

        uint256 unstakeAmount = 0;
        bool unstaked = false;
        if (spDetails[msg.sender].numberOfEndpoints == 1) {
            unstakeAmount = spDetails[msg.sender].deployerStake;

            decreaseStakeRequests[msg.sender] = DecreaseStakeRequest({
                decreaseAmount: unstakeAmount,
                lockupExpiryBlock: block.number.add(decreaseStakeLockupDuration)
            });

            unstaked = true;
        }

        require (
            serviceProviderEndpointToId[keccak256(bytes(_endpoint))] != 0,
            "ServiceProviderFactory: Endpoint not registered");

        uint256 deregisteredID = serviceProviderEndpointToId[keccak256(bytes(_endpoint))];

        serviceProviderEndpointToId[keccak256(bytes(_endpoint))] = 0;

        require(
            keccak256(bytes(serviceProviderInfo[_serviceType][deregisteredID].endpoint)) == keccak256(bytes(_endpoint)),
            "ServiceProviderFactory: Invalid endpoint for service type");

        require (
            serviceProviderInfo[_serviceType][deregisteredID].owner == msg.sender,
            "ServiceProviderFactory: Only callable by endpoint owner");

        delete serviceProviderInfo[_serviceType][deregisteredID];
        uint256 spTypeLength = serviceProviderAddressToId[msg.sender][_serviceType].length;
        for (uint256 i = 0; i < spTypeLength; i ++) {
            if (serviceProviderAddressToId[msg.sender][_serviceType][i] == deregisteredID) {
                serviceProviderAddressToId[msg.sender][_serviceType][i] = serviceProviderAddressToId[msg.sender][_serviceType][spTypeLength - 1];
                serviceProviderAddressToId[msg.sender][_serviceType].length--;
                break;
            }
        }

        spDetails[msg.sender].numberOfEndpoints -= 1;

        (, uint256 typeMin, uint256 typeMax) = ServiceTypeManager(
            serviceTypeManagerAddress
        ).getServiceTypeInfo(_serviceType);
        spDetails[msg.sender].minAccountStake = spDetails[msg.sender].minAccountStake.sub(typeMin);
        spDetails[msg.sender].maxAccountStake = spDetails[msg.sender].maxAccountStake.sub(typeMax);

        emit DeregisteredServiceProvider(
            deregisteredID,
            _serviceType,
            msg.sender,
            _endpoint,
            unstakeAmount);

        if (!unstaked) {
            this.validateAccountStakeBalance(msg.sender);
            spDetails[msg.sender].validBounds = true;
        }

        return deregisteredID;
    }

    function increaseStake(
        uint256 _increaseStakeAmount
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireClaimsManagerAddressIsSet();

        require(
            spDetails[msg.sender].numberOfEndpoints > 0,
            "ServiceProviderFactory: Registered endpoint required to increase stake"
        );
        require(
            !_claimPending(msg.sender),
            "ServiceProviderFactory: No claim expected to be pending prior to stake transfer"
        );

        Staking stakingContract = Staking(
            stakingAddress
        );

        stakingContract.stakeFor(msg.sender, _increaseStakeAmount);

        uint256 newStakeAmount = stakingContract.totalStakedFor(msg.sender);

        spDetails[msg.sender].deployerStake = (
            spDetails[msg.sender].deployerStake.add(_increaseStakeAmount)
        );

        this.validateAccountStakeBalance(msg.sender);

        spDetails[msg.sender].validBounds = true;

        emit IncreasedStake(
            msg.sender,
            _increaseStakeAmount,
            newStakeAmount
        );

        return newStakeAmount;
    }

    function requestDecreaseStake(uint256 _decreaseStakeAmount)
    external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireClaimsManagerAddressIsSet();

        require(
            _decreaseStakeAmount > 0,
            "ServiceProviderFactory: Requested stake decrease amount must be greater than zero"
        );
        require(
            !_claimPending(msg.sender),
            "ServiceProviderFactory: No claim expected to be pending prior to stake transfer"
        );

        Staking stakingContract = Staking(
            stakingAddress
        );

        uint256 currentStakeAmount = stakingContract.totalStakedFor(msg.sender);

        _validateBalanceInternal(msg.sender, (currentStakeAmount.sub(_decreaseStakeAmount)));

        uint256 expiryBlock = block.number.add(decreaseStakeLockupDuration);
        decreaseStakeRequests[msg.sender] = DecreaseStakeRequest({
            decreaseAmount: _decreaseStakeAmount,
            lockupExpiryBlock: expiryBlock
        });

        emit DecreaseStakeRequested(msg.sender, _decreaseStakeAmount, expiryBlock);
        return currentStakeAmount.sub(_decreaseStakeAmount);
    }

    function cancelDecreaseStakeRequest(address _account) external
    {

        _requireIsInitialized();
        _requireDelegateManagerAddressIsSet();

        require(
            msg.sender == _account || msg.sender == delegateManagerAddress,
            "ServiceProviderFactory: Only owner or DelegateManager"
        );
        require(
            _decreaseRequestIsPending(_account),
            "ServiceProviderFactory: Decrease stake request must be pending"
        );

        DecreaseStakeRequest memory cancelledRequest = decreaseStakeRequests[_account];

        decreaseStakeRequests[_account] = DecreaseStakeRequest({
            decreaseAmount: 0,
            lockupExpiryBlock: 0
        });

        emit DecreaseStakeRequestCancelled(
            _account,
            cancelledRequest.decreaseAmount,
            cancelledRequest.lockupExpiryBlock
        );
    }

    function decreaseStake() external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();

        require(
            _decreaseRequestIsPending(msg.sender),
            "ServiceProviderFactory: Decrease stake request must be pending"
        );
        require(
            decreaseStakeRequests[msg.sender].lockupExpiryBlock <= block.number,
            "ServiceProviderFactory: Lockup must be expired"
        );

        Staking stakingContract = Staking(
            stakingAddress
        );

        uint256 decreaseAmount = decreaseStakeRequests[msg.sender].decreaseAmount;
        stakingContract.unstakeFor(msg.sender, decreaseAmount);

        uint256 newStakeAmount = stakingContract.totalStakedFor(msg.sender);

        spDetails[msg.sender].deployerStake = (
            spDetails[msg.sender].deployerStake.sub(decreaseAmount)
        );

        if (spDetails[msg.sender].numberOfEndpoints > 0) {
            this.validateAccountStakeBalance(msg.sender);
        }

        spDetails[msg.sender].validBounds = true;

        delete decreaseStakeRequests[msg.sender];

        emit DecreaseStakeRequestEvaluated(msg.sender, decreaseAmount, newStakeAmount);
        return newStakeAmount;
    }

    function updateDelegateOwnerWallet(
        bytes32 _serviceType,
        string calldata _endpoint,
        address _updatedDelegateOwnerWallet
    ) external
    {

        _requireIsInitialized();

        uint256 spID = this.getServiceProviderIdFromEndpoint(_endpoint);

        require(
            serviceProviderInfo[_serviceType][spID].owner == msg.sender,
            "ServiceProviderFactory: Invalid update operation, wrong owner"
        );

        serviceProviderInfo[_serviceType][spID].delegateOwnerWallet = _updatedDelegateOwnerWallet;
        emit DelegateOwnerWalletUpdated(
            msg.sender,
            _serviceType,
            spID,
            _updatedDelegateOwnerWallet
        );
    }

    function updateEndpoint(
        bytes32 _serviceType,
        string calldata _oldEndpoint,
        string calldata _newEndpoint
    ) external returns (uint256)
    {

        _requireIsInitialized();

        uint256 spId = this.getServiceProviderIdFromEndpoint(_oldEndpoint);
        require (
            spId != 0,
            "ServiceProviderFactory: Could not find service provider with that endpoint"
        );

        ServiceEndpoint memory serviceEndpoint = serviceProviderInfo[_serviceType][spId];

        require(
            serviceEndpoint.owner == msg.sender,
            "ServiceProviderFactory: Invalid update endpoint operation, wrong owner"
        );
        require(
            keccak256(bytes(serviceEndpoint.endpoint)) == keccak256(bytes(_oldEndpoint)),
            "ServiceProviderFactory: Old endpoint doesn't match what's registered for the service provider"
        );

        serviceProviderEndpointToId[keccak256(bytes(serviceEndpoint.endpoint))] = 0;

        serviceEndpoint.endpoint = _newEndpoint;
        serviceProviderInfo[_serviceType][spId] = serviceEndpoint;
        serviceProviderEndpointToId[keccak256(bytes(_newEndpoint))] = spId;

        emit EndpointUpdated(_serviceType, msg.sender, _oldEndpoint, _newEndpoint, spId);
        return spId;
    }

    function requestUpdateDeployerCut(address _serviceProvider, uint256 _cut) external
    {

        _requireIsInitialized();

        require(
            msg.sender == _serviceProvider || msg.sender == governanceAddress,
            ERROR_ONLY_SP_GOVERNANCE
        );

        require(
            (updateDeployerCutRequests[_serviceProvider].lockupExpiryBlock == 0) &&
            (updateDeployerCutRequests[_serviceProvider].newDeployerCut == 0),
            "ServiceProviderFactory: Update deployer cut operation pending"
        );

        require(
            _cut <= DEPLOYER_CUT_BASE,
            "ServiceProviderFactory: Service Provider cut cannot exceed base value"
        );

        uint256 expiryBlock = block.number + deployerCutLockupDuration;
        updateDeployerCutRequests[_serviceProvider] = UpdateDeployerCutRequest({
            lockupExpiryBlock: expiryBlock,
            newDeployerCut: _cut
        });

        emit DeployerCutUpdateRequested(_serviceProvider, _cut, expiryBlock);
    }

    function cancelUpdateDeployerCut(address _serviceProvider) external
    {

        _requireIsInitialized();
        _requirePendingDeployerCutOperation(_serviceProvider);

        require(
            msg.sender == _serviceProvider || msg.sender == governanceAddress,
            ERROR_ONLY_SP_GOVERNANCE
        );

        UpdateDeployerCutRequest memory cancelledRequest = (
            updateDeployerCutRequests[_serviceProvider]
        );

        delete updateDeployerCutRequests[_serviceProvider];
        emit DeployerCutUpdateRequestCancelled(
            _serviceProvider,
            cancelledRequest.newDeployerCut,
            spDetails[_serviceProvider].deployerCut
        );
    }

    function updateDeployerCut(address _serviceProvider) external
    {

        _requireIsInitialized();
        _requirePendingDeployerCutOperation(_serviceProvider);

        require(
            msg.sender == _serviceProvider || msg.sender == governanceAddress,
            ERROR_ONLY_SP_GOVERNANCE
        );

        require(
            updateDeployerCutRequests[_serviceProvider].lockupExpiryBlock <= block.number,
            "ServiceProviderFactory: Lockup must be expired"
        );

        spDetails[_serviceProvider].deployerCut = (
            updateDeployerCutRequests[_serviceProvider].newDeployerCut
        );

        delete updateDeployerCutRequests[_serviceProvider];

        emit DeployerCutUpdateRequestEvaluated(
            _serviceProvider,
            spDetails[_serviceProvider].deployerCut
        );
    }

    function updateServiceProviderStake(
        address _serviceProvider,
        uint256 _amount
     ) external
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireDelegateManagerAddressIsSet();

        require(
            msg.sender == delegateManagerAddress,
            "ServiceProviderFactory: only callable by DelegateManager"
        );
        spDetails[_serviceProvider].deployerStake = _amount;
        _updateServiceProviderBoundStatus(_serviceProvider);
    }

    function updateDecreaseStakeLockupDuration(uint256 _duration) external {

        _requireIsInitialized();

        require(
            msg.sender == governanceAddress,
            ERROR_ONLY_GOVERNANCE
        );

        _updateDecreaseStakeLockupDuration(_duration);
        emit DecreaseStakeLockupDurationUpdated(_duration);
    }

    function updateDeployerCutLockupDuration(uint256 _duration) external {

        _requireIsInitialized();

        require(
            msg.sender == governanceAddress,
            ERROR_ONLY_GOVERNANCE
        );

        _updateDeployerCutLockupDuration(_duration);
        emit UpdateDeployerCutLockupDurationUpdated(_duration);
    }

    function getServiceProviderDeployerCutBase()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return DEPLOYER_CUT_BASE;
    }

    function getDeployerCutLockupDuration()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return deployerCutLockupDuration;
    }

    function getTotalServiceTypeProviders(bytes32 _serviceType)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return serviceProviderTypeIDs[_serviceType];
    }

    function getServiceProviderIdFromEndpoint(string calldata _endpoint)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return serviceProviderEndpointToId[keccak256(bytes(_endpoint))];
    }

    function getServiceProviderIdsFromAddress(address _ownerAddress, bytes32 _serviceType)
    external view returns (uint256[] memory)
    {

        _requireIsInitialized();

        return serviceProviderAddressToId[_ownerAddress][_serviceType];
    }

    function getServiceEndpointInfo(bytes32 _serviceType, uint256 _serviceId)
    external view returns (address owner, string memory endpoint, uint256 blockNumber, address delegateOwnerWallet)
    {

        _requireIsInitialized();

        ServiceEndpoint memory serviceEndpoint = serviceProviderInfo[_serviceType][_serviceId];
        return (
            serviceEndpoint.owner,
            serviceEndpoint.endpoint,
            serviceEndpoint.blocknumber,
            serviceEndpoint.delegateOwnerWallet
        );
    }

    function getServiceProviderDetails(address _serviceProvider)
    external view returns (
        uint256 deployerStake,
        uint256 deployerCut,
        bool validBounds,
        uint256 numberOfEndpoints,
        uint256 minAccountStake,
        uint256 maxAccountStake)
    {

        _requireIsInitialized();

        return (
            spDetails[_serviceProvider].deployerStake,
            spDetails[_serviceProvider].deployerCut,
            spDetails[_serviceProvider].validBounds,
            spDetails[_serviceProvider].numberOfEndpoints,
            spDetails[_serviceProvider].minAccountStake,
            spDetails[_serviceProvider].maxAccountStake
        );
    }

    function getPendingDecreaseStakeRequest(address _serviceProvider)
    external view returns (uint256 amount, uint256 lockupExpiryBlock)
    {

        _requireIsInitialized();

        return (
            decreaseStakeRequests[_serviceProvider].decreaseAmount,
            decreaseStakeRequests[_serviceProvider].lockupExpiryBlock
        );
    }

    function getPendingUpdateDeployerCutRequest(address _serviceProvider)
    external view returns (uint256 newDeployerCut, uint256 lockupExpiryBlock)
    {

        _requireIsInitialized();

        return (
            updateDeployerCutRequests[_serviceProvider].newDeployerCut,
            updateDeployerCutRequests[_serviceProvider].lockupExpiryBlock
        );
    }

    function getDecreaseStakeLockupDuration()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return decreaseStakeLockupDuration;
    }

    function validateAccountStakeBalance(address _serviceProvider)
    external view
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();

        _validateBalanceInternal(
            _serviceProvider,
            Staking(stakingAddress).totalStakedFor(_serviceProvider)
        );
    }

    function getGovernanceAddress() external view returns (address) {

        _requireIsInitialized();

        return governanceAddress;
    }

    function getStakingAddress() external view returns (address) {

        _requireIsInitialized();

        return stakingAddress;
    }

    function getDelegateManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return delegateManagerAddress;
    }

    function getServiceTypeManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return serviceTypeManagerAddress;
    }

    function getClaimsManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return claimsManagerAddress;
    }

    function setGovernanceAddress(address _governanceAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        _updateGovernanceAddress(_governanceAddress);
        emit GovernanceAddressUpdated(_governanceAddress);
    }

    function setStakingAddress(address _address) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        stakingAddress = _address;
        emit StakingAddressUpdated(_address);
    }

    function setDelegateManagerAddress(address _address) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        delegateManagerAddress = _address;
        emit DelegateManagerAddressUpdated(_address);
    }

    function setServiceTypeManagerAddress(address _address) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        serviceTypeManagerAddress = _address;
        emit ServiceTypeManagerAddressUpdated(_address);
    }

    function setClaimsManagerAddress(address _address) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        claimsManagerAddress = _address;
        emit ClaimsManagerAddressUpdated(_address);
    }


    function _updateServiceProviderBoundStatus(address _serviceProvider) internal {

        uint256 totalSPStake = Staking(stakingAddress).totalStakedFor(_serviceProvider);
        if (totalSPStake < spDetails[_serviceProvider].minAccountStake ||
            totalSPStake > spDetails[_serviceProvider].maxAccountStake) {
            spDetails[_serviceProvider].validBounds = false;
        } else {
            spDetails[_serviceProvider].validBounds = true;
        }
    }

    function _updateGovernanceAddress(address _governanceAddress) internal {

        require(
            Governance(_governanceAddress).isGovernanceAddress() == true,
            "ServiceProviderFactory: _governanceAddress is not a valid governance contract"
        );
        governanceAddress = _governanceAddress;
    }

    function _updateDeployerCutLockupDuration(uint256 _duration) internal
    {

        require(
            ClaimsManager(claimsManagerAddress).getFundingRoundBlockDiff() < _duration,
            "ServiceProviderFactory: Incoming duration must be greater than funding round block diff"
        );
        deployerCutLockupDuration = _duration;
    }

    function _updateDecreaseStakeLockupDuration(uint256 _duration) internal
    {

        Governance governance = Governance(governanceAddress);
        require(
            _duration > governance.getVotingPeriod() + governance.getExecutionDelay(),
            "ServiceProviderFactory: decreaseStakeLockupDuration duration must be greater than governance votingPeriod + executionDelay"
        );
        decreaseStakeLockupDuration = _duration;
    }

    function _validateBalanceInternal(address _serviceProvider, uint256 _amount) internal view
    {

        require(
            _amount <= spDetails[_serviceProvider].maxAccountStake,
            "ServiceProviderFactory: Maximum stake amount exceeded"
        );
        require(
            spDetails[_serviceProvider].deployerStake >= spDetails[_serviceProvider].minAccountStake,
            "ServiceProviderFactory: Minimum stake requirement not met"
        );
    }

    function _decreaseRequestIsPending(address _serviceProvider)
    internal view returns (bool)
    {

        return (
            (decreaseStakeRequests[_serviceProvider].lockupExpiryBlock > 0) &&
            (decreaseStakeRequests[_serviceProvider].decreaseAmount > 0)
        );
    }

    function _claimPending(address _serviceProvider) internal view returns (bool) {

        return ClaimsManager(claimsManagerAddress).claimPending(_serviceProvider);
    }

    function _requirePendingDeployerCutOperation (address _serviceProvider) private view {
        require(
            (updateDeployerCutRequests[_serviceProvider].lockupExpiryBlock != 0),
            "ServiceProviderFactory: No update deployer cut operation pending"
        );
    }

    function _requireStakingAddressIsSet() private view {

        require(
            stakingAddress != address(0x00),
            "ServiceProviderFactory: stakingAddress is not set"
        );
    }

    function _requireDelegateManagerAddressIsSet() private view {

        require(
            delegateManagerAddress != address(0x00),
            "ServiceProviderFactory: delegateManagerAddress is not set"
        );
    }

    function _requireServiceTypeManagerAddressIsSet() private view {

        require(
            serviceTypeManagerAddress != address(0x00),
            "ServiceProviderFactory: serviceTypeManagerAddress is not set"
        );
    }

    function _requireClaimsManagerAddressIsSet() private view {

        require(
            claimsManagerAddress != address(0x00),
            "ServiceProviderFactory: claimsManagerAddress is not set"
        );
    }
}


pragma solidity ^0.5.0;





contract DelegateManager is InitializableV2 {

    using SafeMath for uint256;

    string private constant ERROR_ONLY_GOVERNANCE = (
        "DelegateManager: Only callable by Governance contract"
    );
    string private constant ERROR_MINIMUM_DELEGATION = (
        "DelegateManager: Minimum delegation amount required"
    );
    string private constant ERROR_ONLY_SP_GOVERNANCE = (
        "DelegateManager: Only callable by target SP or governance"
    );
    string private constant ERROR_DELEGATOR_STAKE = (
        "DelegateManager: Delegator must be staked for SP"
    );

    address private governanceAddress;
    address private stakingAddress;
    address private serviceProviderFactoryAddress;
    address private claimsManagerAddress;

    uint256 private undelegateLockupDuration;

    uint256 private maxDelegators;

    uint256 private minDelegationAmount;

    uint256 private removeDelegatorLockupDuration;

    uint256 private removeDelegatorEvalDuration;

    ERC20Mintable private audiusToken;

    struct ServiceProviderDelegateInfo {
        uint256 totalDelegatedStake;
        uint256 totalLockedUpStake;
        address[] delegators;
    }

    struct UndelegateStakeRequest {
        address serviceProvider;
        uint256 amount;
        uint256 lockupExpiryBlock;
    }

    mapping (address => ServiceProviderDelegateInfo) private spDelegateInfo;

    mapping (address => mapping(address => uint256)) private delegateInfo;

    mapping (address => uint256) private delegatorTotalStake;

    mapping (address => UndelegateStakeRequest) private undelegateRequests;

    mapping (address => mapping (address => uint256)) private removeDelegatorRequests;

    event IncreaseDelegatedStake(
        address indexed _delegator,
        address indexed _serviceProvider,
        uint256 indexed _increaseAmount
    );

    event UndelegateStakeRequested(
        address indexed _delegator,
        address indexed _serviceProvider,
        uint256 indexed _amount,
        uint256 _lockupExpiryBlock
    );

    event UndelegateStakeRequestCancelled(
        address indexed _delegator,
        address indexed _serviceProvider,
        uint256 indexed _amount
    );

    event UndelegateStakeRequestEvaluated(
        address indexed _delegator,
        address indexed _serviceProvider,
        uint256 indexed _amount
    );

    event Claim(
        address indexed _claimer,
        uint256 indexed _rewards,
        uint256 indexed _newTotal
    );

    event Slash(
        address indexed _target,
        uint256 indexed _amount,
        uint256 indexed _newTotal
    );

    event RemoveDelegatorRequested(
        address indexed _serviceProvider,
        address indexed _delegator,
        uint256 indexed _lockupExpiryBlock
    );

    event RemoveDelegatorRequestCancelled(
        address indexed _serviceProvider,
        address indexed _delegator
    );

    event RemoveDelegatorRequestEvaluated(
        address indexed _serviceProvider,
        address indexed _delegator,
        uint256 indexed _unstakedAmount
    );

    event MaxDelegatorsUpdated(uint256 indexed _maxDelegators);
    event MinDelegationUpdated(uint256 indexed _minDelegationAmount);
    event UndelegateLockupDurationUpdated(uint256 indexed _undelegateLockupDuration);
    event GovernanceAddressUpdated(address indexed _newGovernanceAddress);
    event StakingAddressUpdated(address indexed _newStakingAddress);
    event ServiceProviderFactoryAddressUpdated(address indexed _newServiceProviderFactoryAddress);
    event ClaimsManagerAddressUpdated(address indexed _newClaimsManagerAddress);
    event RemoveDelegatorLockupDurationUpdated(uint256 indexed _removeDelegatorLockupDuration);
    event RemoveDelegatorEvalDurationUpdated(uint256 indexed _removeDelegatorEvalDuration);

    function initialize (
        address _tokenAddress,
        address _governanceAddress,
        uint256 _undelegateLockupDuration
    ) public initializer
    {
        _updateGovernanceAddress(_governanceAddress);
        audiusToken = ERC20Mintable(_tokenAddress);
        maxDelegators = 175;
        minDelegationAmount = 100 * 10**uint256(18);
        InitializableV2.initialize();

        _updateUndelegateLockupDuration(_undelegateLockupDuration);

        _updateRemoveDelegatorLockupDuration(46523);

        removeDelegatorEvalDuration = 6646;
    }

    function delegateStake(
        address _targetSP,
        uint256 _amount
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireClaimsManagerAddressIsSet();

        require(
            !_claimPending(_targetSP),
            "DelegateManager: Delegation not permitted for SP pending claim"
        );
        address delegator = msg.sender;
        Staking stakingContract = Staking(stakingAddress);

        stakingContract.delegateStakeFor(
            _targetSP,
            delegator,
            _amount
        );

        if (!_delegatorExistsForSP(delegator, _targetSP)) {
            spDelegateInfo[_targetSP].delegators.push(delegator);
            require(
                spDelegateInfo[_targetSP].delegators.length <= maxDelegators,
                "DelegateManager: Maximum delegators exceeded"
            );
        }

        _updateDelegatorStake(
            delegator,
            _targetSP,
            spDelegateInfo[_targetSP].totalDelegatedStake.add(_amount),
            delegateInfo[delegator][_targetSP].add(_amount),
            delegatorTotalStake[delegator].add(_amount)
        );

        require(
            delegateInfo[delegator][_targetSP] >= minDelegationAmount,
            ERROR_MINIMUM_DELEGATION
        );

        ServiceProviderFactory(
            serviceProviderFactoryAddress
        ).validateAccountStakeBalance(_targetSP);

        emit IncreaseDelegatedStake(
            delegator,
            _targetSP,
            _amount
        );

        return delegateInfo[delegator][_targetSP];
    }

    function requestUndelegateStake(
        address _target,
        uint256 _amount
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireClaimsManagerAddressIsSet();

        require(
            _amount > 0,
            "DelegateManager: Requested undelegate stake amount must be greater than zero"
        );
        require(
            !_claimPending(_target),
            "DelegateManager: Undelegate request not permitted for SP pending claim"
        );
        address delegator = msg.sender;
        require(
            _delegatorExistsForSP(delegator, _target),
            ERROR_DELEGATOR_STAKE
        );

        require(
            !_undelegateRequestIsPending(delegator),
            "DelegateManager: No pending lockup expected"
        );

        uint256 currentlyDelegatedToSP = delegateInfo[delegator][_target];
        require(
            _amount <= currentlyDelegatedToSP,
            "DelegateManager: Cannot decrease greater than currently staked for this ServiceProvider"
        );

        uint256 lockupExpiryBlock = block.number.add(undelegateLockupDuration);
        _updateUndelegateStakeRequest(
            delegator,
            _target,
            _amount,
            lockupExpiryBlock
        );
        _updateServiceProviderLockupAmount(
            _target,
            spDelegateInfo[_target].totalLockedUpStake.add(_amount)
        );

        emit UndelegateStakeRequested(delegator, _target, _amount, lockupExpiryBlock);
        return delegateInfo[delegator][_target].sub(_amount);
    }

    function cancelUndelegateStakeRequest() external {

        _requireIsInitialized();

        address delegator = msg.sender;
        require(
            _undelegateRequestIsPending(delegator),
            "DelegateManager: Pending lockup expected"
        );
        uint256 unstakeAmount = undelegateRequests[delegator].amount;
        address unlockFundsSP = undelegateRequests[delegator].serviceProvider;
        _updateServiceProviderLockupAmount(
            unlockFundsSP,
            spDelegateInfo[unlockFundsSP].totalLockedUpStake.sub(unstakeAmount)
        );
        _resetUndelegateStakeRequest(delegator);
        emit UndelegateStakeRequestCancelled(delegator, unlockFundsSP, unstakeAmount);
    }

    function undelegateStake() external returns (uint256) {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireClaimsManagerAddressIsSet();

        address delegator = msg.sender;

        require(
            _undelegateRequestIsPending(delegator),
            "DelegateManager: Pending lockup expected"
        );

        require(
            undelegateRequests[delegator].lockupExpiryBlock <= block.number,
            "DelegateManager: Lockup must be expired"
        );

        require(
            !_claimPending(undelegateRequests[delegator].serviceProvider),
            "DelegateManager: Undelegate not permitted for SP pending claim"
        );

        address serviceProvider = undelegateRequests[delegator].serviceProvider;
        uint256 unstakeAmount = undelegateRequests[delegator].amount;

        Staking(stakingAddress).undelegateStakeFor(
            serviceProvider,
            delegator,
            unstakeAmount
        );

        _updateDelegatorStake(
            delegator,
            serviceProvider,
            spDelegateInfo[serviceProvider].totalDelegatedStake.sub(unstakeAmount),
            delegateInfo[delegator][serviceProvider].sub(unstakeAmount),
            delegatorTotalStake[delegator].sub(unstakeAmount)
        );

        require(
            (delegateInfo[delegator][serviceProvider] >= minDelegationAmount ||
             delegateInfo[delegator][serviceProvider] == 0),
            ERROR_MINIMUM_DELEGATION
        );

        if (delegateInfo[delegator][serviceProvider] == 0) {
            _removeFromDelegatorsList(serviceProvider, delegator);
        }

        _updateServiceProviderLockupAmount(
            serviceProvider,
            spDelegateInfo[serviceProvider].totalLockedUpStake.sub(unstakeAmount)
        );
        _resetUndelegateStakeRequest(delegator);

        emit UndelegateStakeRequestEvaluated(
            delegator,
            serviceProvider,
            unstakeAmount
        );

        return delegateInfo[delegator][serviceProvider];
    }

    function claimRewards(address _serviceProvider) external {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireClaimsManagerAddressIsSet();

        ServiceProviderFactory spFactory = ServiceProviderFactory(serviceProviderFactoryAddress);

        (
            uint256 totalBalanceInStaking,
            uint256 totalBalanceInSPFactory,
            uint256 totalActiveFunds,
            uint256 totalRewards,
            uint256 deployerCut
        ) = _validateClaimRewards(spFactory, _serviceProvider);

        if (totalRewards == 0) {
            return;
        }

        uint256 totalDelegatedStakeIncrease = _distributeDelegateRewards(
            _serviceProvider,
            totalActiveFunds,
            totalRewards,
            deployerCut,
            spFactory.getServiceProviderDeployerCutBase()
        );

        spDelegateInfo[_serviceProvider].totalDelegatedStake = (
            spDelegateInfo[_serviceProvider].totalDelegatedStake.add(totalDelegatedStakeIncrease)
        );

        uint256 spRewardShare = totalRewards.sub(totalDelegatedStakeIncrease);

        uint256 newSPFactoryBalance = totalBalanceInSPFactory.add(spRewardShare);

        require(
            totalBalanceInStaking == newSPFactoryBalance.add(spDelegateInfo[_serviceProvider].totalDelegatedStake),
            "DelegateManager: claimRewards amount mismatch"
        );

        spFactory.updateServiceProviderStake(
            _serviceProvider,
            newSPFactoryBalance
        );
    }

    function slash(uint256 _amount, address _slashAddress)
    external
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        Staking stakingContract = Staking(stakingAddress);
        ServiceProviderFactory spFactory = ServiceProviderFactory(serviceProviderFactoryAddress);

        uint256 totalBalanceInStakingPreSlash = stakingContract.totalStakedFor(_slashAddress);
        require(
            (totalBalanceInStakingPreSlash >= _amount),
            "DelegateManager: Cannot slash more than total currently staked"
        );

        (uint256 spLockedStake,) = spFactory.getPendingDecreaseStakeRequest(_slashAddress);
        if (spLockedStake > 0) {
            spFactory.cancelDecreaseStakeRequest(_slashAddress);
        }

        (uint256 totalBalanceInSPFactory,,,,,) = (
            spFactory.getServiceProviderDetails(_slashAddress)
        );
        require(
            totalBalanceInSPFactory > 0,
            "DelegateManager: Service Provider stake required"
        );

        stakingContract.slash(_amount, _slashAddress);
        uint256 totalBalanceInStakingAfterSlash = stakingContract.totalStakedFor(_slashAddress);

        emit Slash(_slashAddress, _amount, totalBalanceInStakingAfterSlash);

        uint256 totalDelegatedStakeDecrease = 0;
        for (uint256 i = 0; i < spDelegateInfo[_slashAddress].delegators.length; i++) {
            address delegator = spDelegateInfo[_slashAddress].delegators[i];
            uint256 preSlashDelegateStake = delegateInfo[delegator][_slashAddress];
            uint256 newDelegateStake = (
             totalBalanceInStakingAfterSlash.mul(preSlashDelegateStake)
            ).div(totalBalanceInStakingPreSlash);
            delegateInfo[delegator][_slashAddress] = (
                delegateInfo[delegator][_slashAddress].sub(preSlashDelegateStake.sub(newDelegateStake))
            );
            _updateDelegatorTotalStake(
                delegator,
                delegatorTotalStake[delegator].sub(preSlashDelegateStake.sub(newDelegateStake))
            );
            totalDelegatedStakeDecrease = (
                totalDelegatedStakeDecrease.add(preSlashDelegateStake.sub(newDelegateStake))
            );
            if (undelegateRequests[delegator].amount != 0) {
                address unstakeSP = undelegateRequests[delegator].serviceProvider;
                uint256 unstakeAmount = undelegateRequests[delegator].amount;
                _updateServiceProviderLockupAmount(
                    unstakeSP,
                    spDelegateInfo[unstakeSP].totalLockedUpStake.sub(unstakeAmount)
                );
                _resetUndelegateStakeRequest(delegator);
            }
        }

        spDelegateInfo[_slashAddress].totalDelegatedStake = (
            spDelegateInfo[_slashAddress].totalDelegatedStake.sub(totalDelegatedStakeDecrease)
        );

        uint256 totalStakeDecrease = (
            totalBalanceInStakingPreSlash.sub(totalBalanceInStakingAfterSlash)
        );
        uint256 totalSPFactoryBalanceDecrease = (
            totalStakeDecrease.sub(totalDelegatedStakeDecrease)
        );
        spFactory.updateServiceProviderStake(
            _slashAddress,
            totalBalanceInSPFactory.sub(totalSPFactoryBalanceDecrease)
        );
    }

    function requestRemoveDelegator(address _serviceProvider, address _delegator) external {

        _requireIsInitialized();

        require(
            msg.sender == _serviceProvider || msg.sender == governanceAddress,
            ERROR_ONLY_SP_GOVERNANCE
        );

        require(
            removeDelegatorRequests[_serviceProvider][_delegator] == 0,
            "DelegateManager: Pending remove delegator request"
        );

        require(
            _delegatorExistsForSP(_delegator, _serviceProvider),
            ERROR_DELEGATOR_STAKE
        );

        removeDelegatorRequests[_serviceProvider][_delegator] = (
            block.number + removeDelegatorLockupDuration
        );

        emit RemoveDelegatorRequested(
            _serviceProvider,
            _delegator,
            removeDelegatorRequests[_serviceProvider][_delegator]
        );
    }

    function cancelRemoveDelegatorRequest(address _serviceProvider, address _delegator) external {

        require(
            msg.sender == _serviceProvider || msg.sender == governanceAddress,
            ERROR_ONLY_SP_GOVERNANCE
        );
        require(
            removeDelegatorRequests[_serviceProvider][_delegator] != 0,
            "DelegateManager: No pending request"
        );
        removeDelegatorRequests[_serviceProvider][_delegator] = 0;
        emit RemoveDelegatorRequestCancelled(_serviceProvider, _delegator);
    }

    function removeDelegator(address _serviceProvider, address _delegator) external {

        _requireIsInitialized();
        _requireStakingAddressIsSet();

        require(
            msg.sender == _serviceProvider || msg.sender == governanceAddress,
            ERROR_ONLY_SP_GOVERNANCE
        );

        require(
            removeDelegatorRequests[_serviceProvider][_delegator] != 0,
            "DelegateManager: No pending request"
        );

        require(
            block.number >= removeDelegatorRequests[_serviceProvider][_delegator],
            "DelegateManager: Lockup must be expired"
        );

        require(
            block.number < removeDelegatorRequests[_serviceProvider][_delegator] + removeDelegatorEvalDuration,
            "DelegateManager: RemoveDelegator evaluation window expired"
        );

        uint256 unstakeAmount = delegateInfo[_delegator][_serviceProvider];
        Staking(stakingAddress).undelegateStakeFor(
            _serviceProvider,
            _delegator,
            unstakeAmount
        );
        _updateDelegatorStake(
            _delegator,
            _serviceProvider,
            spDelegateInfo[_serviceProvider].totalDelegatedStake.sub(unstakeAmount),
            delegateInfo[_delegator][_serviceProvider].sub(unstakeAmount),
            delegatorTotalStake[_delegator].sub(unstakeAmount)
        );

        if (
            _undelegateRequestIsPending(_delegator) &&
            undelegateRequests[_delegator].serviceProvider == _serviceProvider
        ) {
            _updateServiceProviderLockupAmount(
                _serviceProvider,
                spDelegateInfo[_serviceProvider].totalLockedUpStake.sub(undelegateRequests[_delegator].amount)
            );
            _resetUndelegateStakeRequest(_delegator);
        }

        _removeFromDelegatorsList(_serviceProvider, _delegator);

        removeDelegatorRequests[_serviceProvider][_delegator] = 0;
        emit RemoveDelegatorRequestEvaluated(_serviceProvider, _delegator, unstakeAmount);
    }

    function updateUndelegateLockupDuration(uint256 _duration) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        _updateUndelegateLockupDuration(_duration);
        emit UndelegateLockupDurationUpdated(_duration);
    }

    function updateMaxDelegators(uint256 _maxDelegators) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        maxDelegators = _maxDelegators;
        emit MaxDelegatorsUpdated(_maxDelegators);
    }

    function updateMinDelegationAmount(uint256 _minDelegationAmount) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        minDelegationAmount = _minDelegationAmount;
        emit MinDelegationUpdated(_minDelegationAmount);
    }

    function updateRemoveDelegatorLockupDuration(uint256 _duration) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        _updateRemoveDelegatorLockupDuration(_duration);
        emit RemoveDelegatorLockupDurationUpdated(_duration);
    }

    function updateRemoveDelegatorEvalDuration(uint256 _duration) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        removeDelegatorEvalDuration = _duration;
        emit RemoveDelegatorEvalDurationUpdated(_duration);
    }

    function setGovernanceAddress(address _governanceAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        _updateGovernanceAddress(_governanceAddress);
        governanceAddress = _governanceAddress;
        emit GovernanceAddressUpdated(_governanceAddress);
    }

    function setStakingAddress(address _stakingAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        stakingAddress = _stakingAddress;
        emit StakingAddressUpdated(_stakingAddress);
    }

    function setServiceProviderFactoryAddress(address _spFactory) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        serviceProviderFactoryAddress = _spFactory;
        emit ServiceProviderFactoryAddressUpdated(_spFactory);
    }

    function setClaimsManagerAddress(address _claimsManagerAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        claimsManagerAddress = _claimsManagerAddress;
        emit ClaimsManagerAddressUpdated(_claimsManagerAddress);
    }


    function getDelegatorsList(address _sp)
    external view returns (address[] memory)
    {

        _requireIsInitialized();

        return spDelegateInfo[_sp].delegators;
    }

    function getTotalDelegatorStake(address _delegator)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return delegatorTotalStake[_delegator];
    }

    function getTotalDelegatedToServiceProvider(address _sp)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return spDelegateInfo[_sp].totalDelegatedStake;
    }

    function getTotalLockedDelegationForServiceProvider(address _sp)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return spDelegateInfo[_sp].totalLockedUpStake;
    }

    function getDelegatorStakeForServiceProvider(address _delegator, address _serviceProvider)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return delegateInfo[_delegator][_serviceProvider];
    }

    function getPendingUndelegateRequest(address _delegator)
    external view returns (address target, uint256 amount, uint256 lockupExpiryBlock)
    {

        _requireIsInitialized();

        UndelegateStakeRequest memory req = undelegateRequests[_delegator];
        return (req.serviceProvider, req.amount, req.lockupExpiryBlock);
    }

    function getPendingRemoveDelegatorRequest(
        address _serviceProvider,
        address _delegator
    ) external view returns (uint256)
    {

        _requireIsInitialized();

        return removeDelegatorRequests[_serviceProvider][_delegator];
    }

    function getUndelegateLockupDuration()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return undelegateLockupDuration;
    }

    function getMaxDelegators()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return maxDelegators;
    }

    function getMinDelegationAmount()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return minDelegationAmount;
    }

    function getRemoveDelegatorLockupDuration()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return removeDelegatorLockupDuration;
    }

    function getRemoveDelegatorEvalDuration()
    external view returns (uint256)
    {

        _requireIsInitialized();

        return removeDelegatorEvalDuration;
    }

    function getGovernanceAddress() external view returns (address) {

        _requireIsInitialized();

        return governanceAddress;
    }

    function getServiceProviderFactoryAddress() external view returns (address) {

        _requireIsInitialized();

        return serviceProviderFactoryAddress;
    }

    function getClaimsManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return claimsManagerAddress;
    }

    function getStakingAddress() external view returns (address)
    {

        _requireIsInitialized();

        return stakingAddress;
    }


    function _validateClaimRewards(ServiceProviderFactory spFactory, address _serviceProvider)
    internal returns (
        uint256 totalBalanceInStaking,
        uint256 totalBalanceInSPFactory,
        uint256 totalActiveFunds,
        uint256 totalRewards,
        uint256 deployerCut
    )
    {

        (uint256 spLockedStake,) = spFactory.getPendingDecreaseStakeRequest(_serviceProvider);
        uint256 totalLockedUpStake = (
            spDelegateInfo[_serviceProvider].totalLockedUpStake.add(spLockedStake)
        );

        uint256 mintedRewards = ClaimsManager(claimsManagerAddress).processClaim(
            _serviceProvider,
            totalLockedUpStake
        );

        totalBalanceInStaking = Staking(stakingAddress).totalStakedFor(_serviceProvider);

        (
            totalBalanceInSPFactory,
            deployerCut,
            ,,,
        ) = spFactory.getServiceProviderDetails(_serviceProvider);

        uint256 totalBalanceOutsideStaking = (
            totalBalanceInSPFactory.add(spDelegateInfo[_serviceProvider].totalDelegatedStake)
        );

        totalActiveFunds = totalBalanceOutsideStaking.sub(totalLockedUpStake);

        require(
            mintedRewards == totalBalanceInStaking.sub(totalBalanceOutsideStaking),
            "DelegateManager: Reward amount mismatch"
        );

        emit Claim(_serviceProvider, totalRewards, totalBalanceInStaking);

        return (
            totalBalanceInStaking,
            totalBalanceInSPFactory,
            totalActiveFunds,
            mintedRewards,
            deployerCut
        );
    }

    function _updateDelegatorStake(
        address _delegator,
        address _serviceProvider,
        uint256 _totalServiceProviderDelegatedStake,
        uint256 _totalStakedForSpFromDelegator,
        uint256 _totalDelegatorStake
    ) internal
    {

        spDelegateInfo[_serviceProvider].totalDelegatedStake = _totalServiceProviderDelegatedStake;

        delegateInfo[_delegator][_serviceProvider] = _totalStakedForSpFromDelegator;

        _updateDelegatorTotalStake(_delegator, _totalDelegatorStake);
    }

    function _resetUndelegateStakeRequest(address _delegator) internal
    {

        _updateUndelegateStakeRequest(_delegator, address(0), 0, 0);
    }

    function _updateUndelegateStakeRequest(
        address _delegator,
        address _serviceProvider,
        uint256 _amount,
        uint256 _lockupExpiryBlock
    ) internal
    {

        undelegateRequests[_delegator] = UndelegateStakeRequest({
            lockupExpiryBlock: _lockupExpiryBlock,
            amount: _amount,
            serviceProvider: _serviceProvider
        });
    }

    function _updateDelegatorTotalStake(address _delegator, uint256 _amount) internal
    {

        delegatorTotalStake[_delegator] = _amount;
    }

    function _updateServiceProviderLockupAmount(
        address _serviceProvider,
        uint256 _updatedLockupAmount
    ) internal
    {

        spDelegateInfo[_serviceProvider].totalLockedUpStake = _updatedLockupAmount;
    }

    function _removeFromDelegatorsList(address _serviceProvider, address _delegator) internal
    {

        for (uint256 i = 0; i < spDelegateInfo[_serviceProvider].delegators.length; i++) {
            if (spDelegateInfo[_serviceProvider].delegators[i] == _delegator) {
                spDelegateInfo[_serviceProvider].delegators[i] = spDelegateInfo[_serviceProvider].delegators[spDelegateInfo[_serviceProvider].delegators.length - 1];
                spDelegateInfo[_serviceProvider].delegators.length--;
                break;
            }
        }
    }

    function _distributeDelegateRewards(
        address _sp,
        uint256 _totalActiveFunds,
        uint256 _totalRewards,
        uint256 _deployerCut,
        uint256 _deployerCutBase
    )
    internal returns (uint256 totalDelegatedStakeIncrease)
    {

        for (uint256 i = 0; i < spDelegateInfo[_sp].delegators.length; i++) {
            address delegator = spDelegateInfo[_sp].delegators[i];
            uint256 delegateStakeToSP = delegateInfo[delegator][_sp];

            if (undelegateRequests[delegator].serviceProvider == _sp) {
                delegateStakeToSP = delegateStakeToSP.sub(undelegateRequests[delegator].amount);
            }

            uint256 rewardsPriorToSPCut = (
              delegateStakeToSP.mul(_totalRewards)
            ).div(_totalActiveFunds);

            uint256 spDeployerCut = (
                (delegateStakeToSP.mul(_totalRewards)).mul(_deployerCut)
            ).div(
                _totalActiveFunds.mul(_deployerCutBase)
            );
            delegateInfo[delegator][_sp] = (
                delegateInfo[delegator][_sp].add(rewardsPriorToSPCut.sub(spDeployerCut))
            );

            _updateDelegatorTotalStake(
                delegator,
                delegatorTotalStake[delegator].add(rewardsPriorToSPCut.sub(spDeployerCut))
            );

            totalDelegatedStakeIncrease = (
                totalDelegatedStakeIncrease.add(rewardsPriorToSPCut.sub(spDeployerCut))
            );
        }

        return (totalDelegatedStakeIncrease);
    }

    function _updateGovernanceAddress(address _governanceAddress) internal {

        require(
            Governance(_governanceAddress).isGovernanceAddress() == true,
            "DelegateManager: _governanceAddress is not a valid governance contract"
        );
        governanceAddress = _governanceAddress;
    }

    function _updateRemoveDelegatorLockupDuration(uint256 _duration) internal {

        Governance governance = Governance(governanceAddress);
        require(
            _duration > governance.getVotingPeriod() + governance.getExecutionDelay(),
            "DelegateManager: removeDelegatorLockupDuration duration must be greater than governance votingPeriod + executionDelay"
        );
        removeDelegatorLockupDuration = _duration;
    }

    function _updateUndelegateLockupDuration(uint256 _duration) internal {

        Governance governance = Governance(governanceAddress);
        require(
            _duration > governance.getVotingPeriod() + governance.getExecutionDelay(),
            "DelegateManager: undelegateLockupDuration duration must be greater than governance votingPeriod + executionDelay"
        );
        undelegateLockupDuration = _duration;
    }

    function _delegatorExistsForSP(
        address _delegator,
        address _serviceProvider
    ) internal view returns (bool)
    {

        for (uint256 i = 0; i < spDelegateInfo[_serviceProvider].delegators.length; i++) {
            if (spDelegateInfo[_serviceProvider].delegators[i] == _delegator) {
                return true;
            }
        }
        return false;
    }

    function _claimPending(address _sp) internal view returns (bool) {

        ClaimsManager claimsManager = ClaimsManager(claimsManagerAddress);
        return claimsManager.claimPending(_sp);
    }

    function _undelegateRequestIsPending(address _delegator) internal view returns (bool)
    {

        return (
            (undelegateRequests[_delegator].lockupExpiryBlock != 0) &&
            (undelegateRequests[_delegator].amount != 0) &&
            (undelegateRequests[_delegator].serviceProvider != address(0))
        );
    }


    function _requireStakingAddressIsSet() private view {

        require(
            stakingAddress != address(0x00),
            "DelegateManager: stakingAddress is not set"
        );
    }

    function _requireServiceProviderFactoryAddressIsSet() private view {

        require(
            serviceProviderFactoryAddress != address(0x00),
            "DelegateManager: serviceProviderFactoryAddress is not set"
        );
    }

    function _requireClaimsManagerAddressIsSet() private view {

        require(
            claimsManagerAddress != address(0x00),
            "DelegateManager: claimsManagerAddress is not set"
        );
    }
}


pragma solidity ^0.5.0;



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
}


pragma solidity ^0.5.0;





contract Registry is InitializableV2, Ownable {

    using SafeMath for uint256;

    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => address[]) private addressStorageHistory;

    event ContractAdded(
        bytes32 indexed _name,
        address indexed _address
    );

    event ContractRemoved(
        bytes32 indexed _name,
        address indexed _address
    );

    event ContractUpgraded(
        bytes32 indexed _name,
        address indexed _oldAddress,
        address indexed _newAddress
    );

    function initialize() public initializer {

        Ownable.initialize(msg.sender);
        InitializableV2.initialize();
    }


    function addContract(bytes32 _name, address _address) external onlyOwner {

        _requireIsInitialized();

        require(
            addressStorage[_name] == address(0x00),
            "Registry: Contract already registered with given name."
        );
        require(
            _address != address(0x00),
            "Registry: Cannot register zero address."
        );

        setAddress(_name, _address);

        emit ContractAdded(_name, _address);
    }

    function removeContract(bytes32 _name) external onlyOwner {

        _requireIsInitialized();

        address contractAddress = addressStorage[_name];
        require(
            contractAddress != address(0x00),
            "Registry: Cannot remove - no contract registered with given _name."
        );

        setAddress(_name, address(0x00));

        emit ContractRemoved(_name, contractAddress);
    }

    function upgradeContract(bytes32 _name, address _newAddress) external onlyOwner {

        _requireIsInitialized();

        address oldAddress = addressStorage[_name];
        require(
            oldAddress != address(0x00),
            "Registry: Cannot upgrade - no contract registered with given _name."
        );
        require(
            _newAddress != address(0x00),
            "Registry: Cannot upgrade - cannot register zero address."
        );

        setAddress(_name, _newAddress);

        emit ContractUpgraded(_name, oldAddress, _newAddress);
    }


    function getContract(bytes32 _name) external view returns (address contractAddr) {

        _requireIsInitialized();

        return addressStorage[_name];
    }

    function getContract(bytes32 _name, uint256 _version) external view
    returns (address contractAddr)
    {

        _requireIsInitialized();

        require(
            _version <= addressStorageHistory[_name].length,
            "Registry: Index out of range _version."
        );
        return addressStorageHistory[_name][_version.sub(1)];
    }

    function getContractVersionCount(bytes32 _name) external view returns (uint256) {

        _requireIsInitialized();

        return addressStorageHistory[_name].length;
    }


    function setAddress(bytes32 _key, address _value) private {

        addressStorage[_key] = _value;
        addressStorageHistory[_key].push(_value);
    }

}


pragma solidity ^0.5.0;







contract Governance is InitializableV2 {

    using SafeMath for uint256;

    string private constant ERROR_ONLY_GOVERNANCE = (
        "Governance: Only callable by self"
    );
    string private constant ERROR_INVALID_VOTING_PERIOD = (
        "Governance: Requires non-zero _votingPeriod"
    );
    string private constant ERROR_INVALID_REGISTRY = (
        "Governance: Requires non-zero _registryAddress"
    );
    string private constant ERROR_INVALID_VOTING_QUORUM = (
        "Governance: Requires _votingQuorumPercent between 1 & 100"
    );

    Registry private registry;

    address private stakingAddress;

    address private serviceProviderFactoryAddress;

    address private delegateManagerAddress;

    uint256 private votingPeriod;

    uint256 private executionDelay;

    uint256 private votingQuorumPercent;

    uint16 private maxInProgressProposals;

    address private guardianAddress;


    enum Outcome {
        InProgress,
        Rejected,
        ApprovedExecuted,
        QuorumNotMet,
        ApprovedExecutionFailed,
        Evaluating,
        Vetoed,
        TargetContractAddressChanged,
        TargetContractCodeHashChanged
    }

    enum Vote {None, No, Yes}

    struct Proposal {
        uint256 proposalId;
        address proposer;
        uint256 submissionBlockNumber;
        bytes32 targetContractRegistryKey;
        address targetContractAddress;
        uint256 callValue;
        string functionSignature;
        bytes callData;
        Outcome outcome;
        uint256 voteMagnitudeYes;
        uint256 voteMagnitudeNo;
        uint256 numVotes;
        mapping(address => Vote) votes;
        mapping(address => uint256) voteMagnitudes;
        bytes32 contractHash;
    }


    uint256 lastProposalId = 0;

    mapping(uint256 => Proposal) proposals;

    uint256[] inProgressProposals;


    event ProposalSubmitted(
        uint256 indexed _proposalId,
        address indexed _proposer,
        string _name,
        string _description
    );
    event ProposalVoteSubmitted(
        uint256 indexed _proposalId,
        address indexed _voter,
        Vote indexed _vote,
        uint256 _voterStake
    );
    event ProposalVoteUpdated(
        uint256 indexed _proposalId,
        address indexed _voter,
        Vote indexed _vote,
        uint256 _voterStake,
        Vote _previousVote
    );
    event ProposalOutcomeEvaluated(
        uint256 indexed _proposalId,
        Outcome indexed _outcome,
        uint256 _voteMagnitudeYes,
        uint256 _voteMagnitudeNo,
        uint256 _numVotes
    );
    event ProposalTransactionExecuted(
        uint256 indexed _proposalId,
        bool indexed _success,
        bytes _returnData
    );
    event GuardianTransactionExecuted(
        address indexed _targetContractAddress,
        uint256 _callValue,
        string indexed _functionSignature,
        bytes indexed _callData,
        bytes _returnData
    );
    event ProposalVetoed(uint256 indexed _proposalId);
    event RegistryAddressUpdated(address indexed _newRegistryAddress);
    event GuardianshipTransferred(address indexed _newGuardianAddress);
    event VotingPeriodUpdated(uint256 indexed _newVotingPeriod);
    event ExecutionDelayUpdated(uint256 indexed _newExecutionDelay);
    event VotingQuorumPercentUpdated(uint256 indexed _newVotingQuorumPercent);
    event MaxInProgressProposalsUpdated(uint256 indexed _newMaxInProgressProposals);

    function initialize(
        address _registryAddress,
        uint256 _votingPeriod,
        uint256 _executionDelay,
        uint256 _votingQuorumPercent,
        uint16 _maxInProgressProposals,
        address _guardianAddress
    ) public initializer {

        require(_registryAddress != address(0x00), ERROR_INVALID_REGISTRY);
        registry = Registry(_registryAddress);

        require(_votingPeriod > 0, ERROR_INVALID_VOTING_PERIOD);
        votingPeriod = _votingPeriod;

        executionDelay = _executionDelay;

        require(
            _maxInProgressProposals > 0,
            "Governance: Requires non-zero _maxInProgressProposals"
        );
        maxInProgressProposals = _maxInProgressProposals;

        require(
            _votingQuorumPercent > 0 && _votingQuorumPercent <= 100,
            ERROR_INVALID_VOTING_QUORUM
        );
        votingQuorumPercent = _votingQuorumPercent;

        require(
            _guardianAddress != address(0x00),
            "Governance: Requires non-zero _guardianAddress"
        );
        guardianAddress = _guardianAddress;  //Guardian address becomes the only party

        InitializableV2.initialize();
    }


    function submitProposal(
        bytes32 _targetContractRegistryKey,
        uint256 _callValue,
        string calldata _functionSignature,
        bytes calldata _callData,
        string calldata _name,
        string calldata _description
    ) external returns (uint256)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireDelegateManagerAddressIsSet();

        address proposer = msg.sender;

        require(
            this.inProgressProposalsAreUpToDate(),
            "Governance: Cannot submit new proposal until all evaluatable InProgress proposals are evaluated."
        );

        require(
            inProgressProposals.length < maxInProgressProposals,
            "Governance: Number of InProgress proposals already at max. Please evaluate if possible, or wait for current proposals' votingPeriods to expire."
        );

        require(
            _calculateAddressActiveStake(proposer) > 0 || proposer == guardianAddress,
            "Governance: Proposer must be address with non-zero total active stake or be guardianAddress."
        );

        address targetContractAddress = registry.getContract(_targetContractRegistryKey);
        require(
            targetContractAddress != address(0x00),
            "Governance: _targetContractRegistryKey must point to valid registered contract"
        );

        require(
            bytes(_functionSignature).length != 0,
            "Governance: _functionSignature cannot be empty."
        );

        require(bytes(_description).length > 0, "Governance: _description length must be > 0");

        require(bytes(_name).length > 0, "Governance: _name length must be > 0");

        uint256 newProposalId = lastProposalId.add(1);

        proposals[newProposalId] = Proposal({
            proposalId: newProposalId,
            proposer: proposer,
            submissionBlockNumber: block.number,
            targetContractRegistryKey: _targetContractRegistryKey,
            targetContractAddress: targetContractAddress,
            callValue: _callValue,
            functionSignature: _functionSignature,
            callData: _callData,
            outcome: Outcome.InProgress,
            voteMagnitudeYes: 0,
            voteMagnitudeNo: 0,
            numVotes: 0,
            contractHash: _getCodeHash(targetContractAddress)
        });

        inProgressProposals.push(newProposalId);

        emit ProposalSubmitted(
            newProposalId,
            proposer,
            _name,
            _description
        );

        lastProposalId = newProposalId;

        return newProposalId;
    }

    function submitVote(uint256 _proposalId, Vote _vote) external {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireDelegateManagerAddressIsSet();
        _requireValidProposalId(_proposalId);

        address voter = msg.sender;

        uint256 submissionBlockNumber = proposals[_proposalId].submissionBlockNumber;
        uint256 endBlockNumber = submissionBlockNumber.add(votingPeriod);
        require(
            block.number > submissionBlockNumber && block.number <= endBlockNumber,
            "Governance: Proposal votingPeriod has ended"
        );

        uint256 voterActiveStake = _calculateAddressActiveStake(voter);
        require(
            voterActiveStake > 0,
            "Governance: Voter must be address with non-zero total active stake."
        );

        require(
            proposals[_proposalId].votes[voter] == Vote.None,
            "Governance: To update previous vote, call updateVote()"
        );

        require(
            _vote == Vote.Yes || _vote == Vote.No,
            "Governance: Can only submit a Yes or No vote"
        );

        proposals[_proposalId].votes[voter] = _vote;

        proposals[_proposalId].voteMagnitudes[voter] = voterActiveStake;

        if (_vote == Vote.Yes) {
            _increaseVoteMagnitudeYes(_proposalId, voterActiveStake);
        } else {
            _increaseVoteMagnitudeNo(_proposalId, voterActiveStake);
        }

        proposals[_proposalId].numVotes = proposals[_proposalId].numVotes.add(1);

        emit ProposalVoteSubmitted(
            _proposalId,
            voter,
            _vote,
            voterActiveStake
        );
    }

    function updateVote(uint256 _proposalId, Vote _vote) external {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireDelegateManagerAddressIsSet();
        _requireValidProposalId(_proposalId);

        address voter = msg.sender;

        uint256 submissionBlockNumber = proposals[_proposalId].submissionBlockNumber;
        uint256 endBlockNumber = submissionBlockNumber.add(votingPeriod);
        require(
            block.number > submissionBlockNumber && block.number <= endBlockNumber,
            "Governance: Proposal votingPeriod has ended"
        );

        Vote previousVote = proposals[_proposalId].votes[voter];

        require(
            previousVote != Vote.None,
            "Governance: To submit new vote, call submitVote()"
        );

        require(
            _vote == Vote.Yes || _vote == Vote.No,
            "Governance: Can only submit a Yes or No vote"
        );

        proposals[_proposalId].votes[voter] = _vote;

        uint256 voteMagnitude = proposals[_proposalId].voteMagnitudes[voter];
        if (previousVote == Vote.Yes && _vote == Vote.No) {
            _decreaseVoteMagnitudeYes(_proposalId, voteMagnitude);
            _increaseVoteMagnitudeNo(_proposalId, voteMagnitude);
        } else if (previousVote == Vote.No && _vote == Vote.Yes) {
            _decreaseVoteMagnitudeNo(_proposalId, voteMagnitude);
            _increaseVoteMagnitudeYes(_proposalId, voteMagnitude);
        }


        emit ProposalVoteUpdated(
            _proposalId,
            voter,
            _vote,
            voteMagnitude,
            previousVote
        );
    }

    function evaluateProposalOutcome(uint256 _proposalId)
    external returns (Outcome)
    {

        _requireIsInitialized();
        _requireStakingAddressIsSet();
        _requireServiceProviderFactoryAddressIsSet();
        _requireDelegateManagerAddressIsSet();
        _requireValidProposalId(_proposalId);

        require(
            proposals[_proposalId].outcome == Outcome.InProgress,
            "Governance: Can only evaluate InProgress proposal."
        );

        proposals[_proposalId].outcome = Outcome.Evaluating;

        uint256 submissionBlockNumber = proposals[_proposalId].submissionBlockNumber;
        uint256 endBlockNumber = submissionBlockNumber.add(votingPeriod).add(executionDelay);
        require(
            block.number > endBlockNumber,
            "Governance: Proposal votingPeriod & executionDelay must end before evaluation."
        );

        address targetContractAddress = registry.getContract(
            proposals[_proposalId].targetContractRegistryKey
        );

        Outcome outcome;

        if (targetContractAddress != proposals[_proposalId].targetContractAddress) {
            outcome = Outcome.TargetContractAddressChanged;
        }
        else if (_getCodeHash(targetContractAddress) != proposals[_proposalId].contractHash) {
            outcome = Outcome.TargetContractCodeHashChanged;
        }
        else if (_quorumMet(proposals[_proposalId], Staking(stakingAddress)) == false) {
            outcome = Outcome.QuorumNotMet;
        }
        else if (
            proposals[_proposalId].voteMagnitudeYes > proposals[_proposalId].voteMagnitudeNo
        ) {
            (bool success, bytes memory returnData) = _executeTransaction(
                targetContractAddress,
                proposals[_proposalId].callValue,
                proposals[_proposalId].functionSignature,
                proposals[_proposalId].callData
            );

            emit ProposalTransactionExecuted(
                _proposalId,
                success,
                returnData
            );

            if (success) {
                outcome = Outcome.ApprovedExecuted;
            } else {
                outcome = Outcome.ApprovedExecutionFailed;
            }
        }
        else {
            outcome = Outcome.Rejected;
        }

        proposals[_proposalId].outcome = outcome;

        _removeFromInProgressProposals(_proposalId);

        emit ProposalOutcomeEvaluated(
            _proposalId,
            outcome,
            proposals[_proposalId].voteMagnitudeYes,
            proposals[_proposalId].voteMagnitudeNo,
            proposals[_proposalId].numVotes
        );

        return outcome;
    }

    function vetoProposal(uint256 _proposalId) external {

        _requireIsInitialized();
        _requireValidProposalId(_proposalId);

        require(
            msg.sender == guardianAddress,
            "Governance: Only guardian can veto proposals."
        );

        require(
            proposals[_proposalId].outcome == Outcome.InProgress,
            "Governance: Cannot veto inactive proposal."
        );

        proposals[_proposalId].outcome = Outcome.Vetoed;

        _removeFromInProgressProposals(_proposalId);

        emit ProposalVetoed(_proposalId);
    }


    function setStakingAddress(address _stakingAddress) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(_stakingAddress != address(0x00), "Governance: Requires non-zero _stakingAddress");
        stakingAddress = _stakingAddress;
    }

    function setServiceProviderFactoryAddress(address _serviceProviderFactoryAddress) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(
            _serviceProviderFactoryAddress != address(0x00),
            "Governance: Requires non-zero _serviceProviderFactoryAddress"
        );
        serviceProviderFactoryAddress = _serviceProviderFactoryAddress;
    }

    function setDelegateManagerAddress(address _delegateManagerAddress) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(
            _delegateManagerAddress != address(0x00),
            "Governance: Requires non-zero _delegateManagerAddress"
        );
        delegateManagerAddress = _delegateManagerAddress;
    }

    function setVotingPeriod(uint256 _votingPeriod) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(_votingPeriod > 0, ERROR_INVALID_VOTING_PERIOD);
        votingPeriod = _votingPeriod;
        emit VotingPeriodUpdated(_votingPeriod);
    }

    function setVotingQuorumPercent(uint256 _votingQuorumPercent) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(
            _votingQuorumPercent > 0 && _votingQuorumPercent <= 100,
            ERROR_INVALID_VOTING_QUORUM
        );
        votingQuorumPercent = _votingQuorumPercent;
        emit VotingQuorumPercentUpdated(_votingQuorumPercent);
    }

    function setRegistryAddress(address _registryAddress) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(_registryAddress != address(0x00), ERROR_INVALID_REGISTRY);

        registry = Registry(_registryAddress);

        emit RegistryAddressUpdated(_registryAddress);
    }

    function setMaxInProgressProposals(uint16 _newMaxInProgressProposals) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        require(
            _newMaxInProgressProposals > 0,
            "Governance: Requires non-zero _newMaxInProgressProposals"
        );
        maxInProgressProposals = _newMaxInProgressProposals;
        emit MaxInProgressProposalsUpdated(_newMaxInProgressProposals);
    }

    function setExecutionDelay(uint256 _newExecutionDelay) external {

        _requireIsInitialized();

        require(msg.sender == address(this), ERROR_ONLY_GOVERNANCE);
        executionDelay = _newExecutionDelay;
        emit ExecutionDelayUpdated(_newExecutionDelay);
    }


    function guardianExecuteTransaction(
        bytes32 _targetContractRegistryKey,
        uint256 _callValue,
        string calldata _functionSignature,
        bytes calldata _callData
    ) external
    {

        _requireIsInitialized();

        require(
            msg.sender == guardianAddress,
            "Governance: Only guardian."
        );

        address targetContractAddress = registry.getContract(_targetContractRegistryKey);
        require(
            targetContractAddress != address(0x00),
            "Governance: _targetContractRegistryKey must point to valid registered contract"
        );

        require(
            bytes(_functionSignature).length != 0,
            "Governance: _functionSignature cannot be empty."
        );

        (bool success, bytes memory returnData) = _executeTransaction(
            targetContractAddress,
            _callValue,
            _functionSignature,
            _callData
        );

        require(success, "Governance: Transaction failed.");

        emit GuardianTransactionExecuted(
            targetContractAddress,
            _callValue,
            _functionSignature,
            _callData,
            returnData
        );
    }

    function transferGuardianship(address _newGuardianAddress) external {

        _requireIsInitialized();

        require(
            msg.sender == guardianAddress,
            "Governance: Only guardian."
        );

        guardianAddress = _newGuardianAddress;

        emit GuardianshipTransferred(_newGuardianAddress);
    }


    function getProposalById(uint256 _proposalId)
    external view returns (
        uint256 proposalId,
        address proposer,
        uint256 submissionBlockNumber,
        bytes32 targetContractRegistryKey,
        address targetContractAddress,
        uint256 callValue,
        string memory functionSignature,
        bytes memory callData,
        Outcome outcome,
        uint256 voteMagnitudeYes,
        uint256 voteMagnitudeNo,
        uint256 numVotes
    )
    {

        _requireIsInitialized();
        _requireValidProposalId(_proposalId);

        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.proposalId,
            proposal.proposer,
            proposal.submissionBlockNumber,
            proposal.targetContractRegistryKey,
            proposal.targetContractAddress,
            proposal.callValue,
            proposal.functionSignature,
            proposal.callData,
            proposal.outcome,
            proposal.voteMagnitudeYes,
            proposal.voteMagnitudeNo,
            proposal.numVotes
        );
    }

    function getProposalTargetContractHash(uint256 _proposalId)
    external view returns (bytes32)
    {

        _requireIsInitialized();
        _requireValidProposalId(_proposalId);

        return (proposals[_proposalId].contractHash);
    }

    function getVoteInfoByProposalAndVoter(uint256 _proposalId, address _voter)
    external view returns (Vote vote, uint256 voteMagnitude)
    {

        _requireIsInitialized();
        _requireValidProposalId(_proposalId);

        return (
            proposals[_proposalId].votes[_voter],
            proposals[_proposalId].voteMagnitudes[_voter]
        );
    }

    function getGuardianAddress() external view returns (address) {

        _requireIsInitialized();

        return guardianAddress;
    }

    function getStakingAddress() external view returns (address) {

        _requireIsInitialized();

        return stakingAddress;
    }

    function getServiceProviderFactoryAddress() external view returns (address) {

        _requireIsInitialized();

        return serviceProviderFactoryAddress;
    }

    function getDelegateManagerAddress() external view returns (address) {

        _requireIsInitialized();

        return delegateManagerAddress;
    }

    function getVotingPeriod() external view returns (uint256) {

        _requireIsInitialized();

        return votingPeriod;
    }

    function getVotingQuorumPercent() external view returns (uint256) {

        _requireIsInitialized();

        return votingQuorumPercent;
    }

    function getRegistryAddress() external view returns (address) {

        _requireIsInitialized();

        return address(registry);
    }

    function isGovernanceAddress() external pure returns (bool) {

        return true;
    }

    function getMaxInProgressProposals() external view returns (uint16) {

        _requireIsInitialized();

        return maxInProgressProposals;
    }

    function getExecutionDelay() external view returns (uint256) {

        _requireIsInitialized();

        return executionDelay;
    }

    function getInProgressProposals() external view returns (uint256[] memory) {

        _requireIsInitialized();

        return inProgressProposals;
    }

    function inProgressProposalsAreUpToDate() external view returns (bool) {

        _requireIsInitialized();

        for (uint256 i = 0; i < inProgressProposals.length; i++) {
            if (
                block.number >
                (proposals[inProgressProposals[i]].submissionBlockNumber).add(votingPeriod).add(executionDelay)
            ) {
                return false;
            }
        }

        return true;
    }


    function _executeTransaction(
        address _targetContractAddress,
        uint256 _callValue,
        string memory _functionSignature,
        bytes memory _callData
    ) internal returns (bool success, bytes memory returnData)
    {

        bytes memory encodedCallData = abi.encodePacked(
            bytes4(keccak256(bytes(_functionSignature))),
            _callData
        );
        (success, returnData) = (
            _targetContractAddress.call.value(_callValue)(encodedCallData)
        );

        return (success, returnData);
    }

    function _increaseVoteMagnitudeYes(uint256 _proposalId, uint256 _voterStake) internal {

        proposals[_proposalId].voteMagnitudeYes = (
            proposals[_proposalId].voteMagnitudeYes.add(_voterStake)
        );
    }

    function _increaseVoteMagnitudeNo(uint256 _proposalId, uint256 _voterStake) internal {

        proposals[_proposalId].voteMagnitudeNo = (
            proposals[_proposalId].voteMagnitudeNo.add(_voterStake)
        );
    }

    function _decreaseVoteMagnitudeYes(uint256 _proposalId, uint256 _voterStake) internal {

        proposals[_proposalId].voteMagnitudeYes = (
            proposals[_proposalId].voteMagnitudeYes.sub(_voterStake)
        );
    }

    function _decreaseVoteMagnitudeNo(uint256 _proposalId, uint256 _voterStake) internal {

        proposals[_proposalId].voteMagnitudeNo = (
            proposals[_proposalId].voteMagnitudeNo.sub(_voterStake)
        );
    }

    function _removeFromInProgressProposals(uint256 _proposalId) internal {

        uint256 index = 0;
        for (uint256 i = 0; i < inProgressProposals.length; i++) {
            if (inProgressProposals[i] == _proposalId) {
                index = i;
                break;
            }
        }

        inProgressProposals[index] = inProgressProposals[inProgressProposals.length - 1];
        inProgressProposals.pop();
    }

    function _quorumMet(Proposal memory proposal, Staking stakingContract)
    internal view returns (bool)
    {

        uint256 participation = (
            (proposal.voteMagnitudeYes + proposal.voteMagnitudeNo)
            .mul(100)
            .div(stakingContract.totalStakedAt(proposal.submissionBlockNumber))
        );
        return participation >= votingQuorumPercent;
    }


    function _requireStakingAddressIsSet() private view {

        require(
            stakingAddress != address(0x00),
            "Governance: stakingAddress is not set"
        );
    }

    function _requireServiceProviderFactoryAddressIsSet() private view {

        require(
            serviceProviderFactoryAddress != address(0x00),
            "Governance: serviceProviderFactoryAddress is not set"
        );
    }

    function _requireDelegateManagerAddressIsSet() private view {

        require(
            delegateManagerAddress != address(0x00),
            "Governance: delegateManagerAddress is not set"
        );
    }

    function _requireValidProposalId(uint256 _proposalId) private view {

        require(
            _proposalId <= lastProposalId && _proposalId > 0,
            "Governance: Must provide valid non-zero _proposalId"
        );
    }

    function _calculateAddressActiveStake(address _address) private view returns (uint256) {

        ServiceProviderFactory spFactory = ServiceProviderFactory(serviceProviderFactoryAddress);
        DelegateManager delegateManager = DelegateManager(delegateManagerAddress);

        (uint256 directDeployerStake,,,,,) = spFactory.getServiceProviderDetails(_address);
        (uint256 lockedDeployerStake,) = spFactory.getPendingDecreaseStakeRequest(_address);
        uint256 activeDeployerStake = directDeployerStake.sub(lockedDeployerStake);

        uint256 totalDelegatorStake = delegateManager.getTotalDelegatorStake(_address);
        (,uint256 lockedDelegatorStake, ) = delegateManager.getPendingUndelegateRequest(_address);
        uint256 activeDelegatorStake = totalDelegatorStake.sub(lockedDelegatorStake);

        uint256 activeStake = activeDeployerStake.add(activeDelegatorStake);

        return activeStake;
    }

    function _getCodeHash(address _contract) private view returns (bytes32) {

        bytes32 contractHash;
        assembly {
          contractHash := extcodehash(_contract)
        }
        return contractHash;
    }
}


pragma solidity ^0.5.0;




contract ServiceTypeManager is InitializableV2 {

    address governanceAddress;

    string private constant ERROR_ONLY_GOVERNANCE = (
        "ServiceTypeManager: Only callable by Governance contract"
    );

    mapping(bytes32 => bytes32[]) private serviceTypeVersions;

    mapping(bytes32 => mapping(bytes32 => bool)) private serviceTypeVersionInfo;

    bytes32[] private validServiceTypes;

    struct ServiceTypeInfo {
        bool isValid;
        uint256 minStake;
        uint256 maxStake;
    }

    mapping(bytes32 => ServiceTypeInfo) private serviceTypeInfo;

    event SetServiceVersion(
        bytes32 indexed _serviceType,
        bytes32 indexed _serviceVersion
    );

    event ServiceTypeAdded(
        bytes32 indexed _serviceType,
        uint256 indexed _serviceTypeMin,
        uint256 indexed _serviceTypeMax
    );

    event ServiceTypeRemoved(bytes32 indexed _serviceType);

    function initialize(address _governanceAddress) public initializer
    {

        _updateGovernanceAddress(_governanceAddress);
        InitializableV2.initialize();
    }

    function getGovernanceAddress() external view returns (address) {

        _requireIsInitialized();

        return governanceAddress;
    }

    function setGovernanceAddress(address _governanceAddress) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        _updateGovernanceAddress(_governanceAddress);
    }


    function addServiceType(
        bytes32 _serviceType,
        uint256 _serviceTypeMin,
        uint256 _serviceTypeMax
    ) external
    {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        require(
            !this.serviceTypeIsValid(_serviceType),
            "ServiceTypeManager: Already known service type"
        );
        require(
            _serviceTypeMax > _serviceTypeMin,
            "ServiceTypeManager: Max stake must be non-zero and greater than min stake"
        );

        require(
            serviceTypeInfo[_serviceType].maxStake == 0,
            "ServiceTypeManager: Cannot re-add serviceType after it was removed."
        );

        validServiceTypes.push(_serviceType);
        serviceTypeInfo[_serviceType] = ServiceTypeInfo({
            isValid: true,
            minStake: _serviceTypeMin,
            maxStake: _serviceTypeMax
        });

        emit ServiceTypeAdded(_serviceType, _serviceTypeMin, _serviceTypeMax);
    }

    function removeServiceType(bytes32 _serviceType) external {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);

        uint256 serviceIndex = 0;
        bool foundService = false;
        for (uint256 i = 0; i < validServiceTypes.length; i ++) {
            if (validServiceTypes[i] == _serviceType) {
                serviceIndex = i;
                foundService = true;
                break;
            }
        }
        require(foundService == true, "ServiceTypeManager: Invalid service type, not found");
        uint256 lastIndex = validServiceTypes.length - 1;
        validServiceTypes[serviceIndex] = validServiceTypes[lastIndex];
        validServiceTypes.length--;

        serviceTypeInfo[_serviceType].isValid = false;
        emit ServiceTypeRemoved(_serviceType);
    }

    function getServiceTypeInfo(bytes32 _serviceType)
    external view returns (bool isValid, uint256 minStake, uint256 maxStake)
    {

        _requireIsInitialized();

        return (
            serviceTypeInfo[_serviceType].isValid,
            serviceTypeInfo[_serviceType].minStake,
            serviceTypeInfo[_serviceType].maxStake
        );
    }

    function getValidServiceTypes()
    external view returns (bytes32[] memory)
    {

        _requireIsInitialized();

        return validServiceTypes;
    }

    function serviceTypeIsValid(bytes32 _serviceType)
    external view returns (bool)
    {

        _requireIsInitialized();

        return serviceTypeInfo[_serviceType].isValid;
    }


    function setServiceVersion(
        bytes32 _serviceType,
        bytes32 _serviceVersion
    ) external
    {

        _requireIsInitialized();

        require(msg.sender == governanceAddress, ERROR_ONLY_GOVERNANCE);
        require(this.serviceTypeIsValid(_serviceType), "ServiceTypeManager: Invalid service type");
        require(
            serviceTypeVersionInfo[_serviceType][_serviceVersion] == false,
            "ServiceTypeManager: Already registered"
        );

        serviceTypeVersions[_serviceType].push(_serviceVersion);

        serviceTypeVersionInfo[_serviceType][_serviceVersion] = true;

        emit SetServiceVersion(_serviceType, _serviceVersion);
    }

    function getVersion(bytes32 _serviceType, uint256 _versionIndex)
    external view returns (bytes32)
    {

        _requireIsInitialized();

        require(
            serviceTypeVersions[_serviceType].length > _versionIndex,
            "ServiceTypeManager: No registered version of serviceType"
        );
        return (serviceTypeVersions[_serviceType][_versionIndex]);
    }

    function getCurrentVersion(bytes32 _serviceType)
    external view returns (bytes32)
    {

        _requireIsInitialized();

        require(
            serviceTypeVersions[_serviceType].length >= 1,
            "ServiceTypeManager: No registered version of serviceType"
        );
        uint256 latestVersionIndex = serviceTypeVersions[_serviceType].length - 1;
        return (serviceTypeVersions[_serviceType][latestVersionIndex]);
    }

    function getNumberOfVersions(bytes32 _serviceType)
    external view returns (uint256)
    {

        _requireIsInitialized();

        return serviceTypeVersions[_serviceType].length;
    }

    function serviceVersionIsValid(bytes32 _serviceType, bytes32 _serviceVersion)
    external view returns (bool)
    {

        _requireIsInitialized();

        return serviceTypeVersionInfo[_serviceType][_serviceVersion];
    }

    function _updateGovernanceAddress(address _governanceAddress) internal {

        require(
            Governance(_governanceAddress).isGovernanceAddress() == true,
            "ServiceTypeManager: _governanceAddress is not a valid governance contract"
        );
        governanceAddress = _governanceAddress;
    }
}