
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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


    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.12;


contract SettAccessControl is Initializable {

    address public governance;
    address public strategist;
    address public keeper;

    function _onlyGovernance() internal view {

        require(msg.sender == governance, "onlyGovernance");
    }

    function _onlyGovernanceOrStrategist() internal view {

        require(
            msg.sender == strategist || msg.sender == governance,
            "onlyGovernanceOrStrategist"
        );
    }

    function _onlyAuthorizedActors() internal view {

        require(
            msg.sender == keeper || msg.sender == governance,
            "onlyAuthorizedActors"
        );
    }


    function setStrategist(address _strategist) external {

        _onlyGovernance();
        strategist = _strategist;
    }

    function setKeeper(address _keeper) external {

        _onlyGovernance();
        keeper = _keeper;
    }

    function setGovernance(address _governance) public {

        _onlyGovernance();
        governance = _governance;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity >=0.5.0 <=0.9.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// MIT

pragma solidity >=0.5.0 <=0.9.0;


interface IVault is IERC20 {

    function token() external view returns (address);


    function rewards() external view returns (address);


    function reportHarvest(uint256 _harvestedAmount) external;


    function reportAdditionalToken(address _token) external;


    function performanceFeeGovernance() external view returns (uint256);


    function performanceFeeStrategist() external view returns (uint256);


    function withdrawalFee() external view returns (uint256);


    function managementFee() external view returns (uint256);


    function governance() external view returns (address);


    function keeper() external view returns (address);


    function guardian() external view returns (address);


    function strategist() external view returns (address);


    function deposit(uint256 _amount) external;


    function depositFor(address _recipient, uint256 _amount) external;


    function getPricePerFullShare() external view returns (uint256);

}// MIT
pragma solidity >=0.5.0 <=0.9.0;

interface IVesting {

    function setupVesting(
        address recipient,
        uint256 _amount,
        uint256 _unlockBegin
    ) external;

}// MIT

pragma solidity >=0.5.0 <=0.9.0;

interface IStrategy {

    struct TokenAmount {
        address token;
        uint256 amount;
    }

    function balanceOf() external view returns (uint256 balance);


    function balanceOfPool() external view returns (uint256 balance);


    function balanceOfWant() external view returns (uint256 balance);


    function earn() external;


    function withdraw(uint256 amount) external;


    function withdrawToVault() external;


    function withdrawOther(address _asset) external;


    function harvest() external returns (TokenAmount[] memory harvested);


    function tend() external returns (TokenAmount[] memory tended);


    function balanceOfRewards()
        external
        view
        returns (TokenAmount[] memory rewards);


    function emitNonProtectedToken(address _token) external;

}// MIT
pragma solidity >=0.5.0 <=0.9.0;

interface IBadgerGuestlist {

    function authorized(
        address guest,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external view returns (bool);


    function setGuests(address[] calldata _guests, bool[] calldata _invited)
        external;

}// MIT
pragma solidity 0.8.12;





contract StakedCitadel is
    ERC20Upgradeable,
    SettAccessControl,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;

    uint256 constant ONE_ETH = 1e18;


    IERC20Upgradeable public token; // Token used for deposits
    IBadgerGuestlist public guestList; // guestlist when vault is in experiment/ guarded state

    bool public pausedDeposit; // false by default Allows to only block deposits, use pause for the normal pause state

    address public strategy; // address of the strategy connected to the vault
    address public guardian; // guardian of vault and strategy
    address public treasury; // set by governance ... any fees go there

    address public badgerTree; // Address we send tokens too via reportAdditionalTokens
    address public vesting; // Address of the vesting contract where after withdrawal we send CTDL to vest for 21 days

    string internal constant _defaultNamePrefix = "Staked ";
    string internal constant _symbolSymbolPrefix = "x";

    uint256 public lifeTimeEarned; // keeps track of total earnings
    uint256 public lastHarvestedAt; // timestamp of the last harvest
    uint256 public lastHarvestAmount; // amount harvested during last harvest
    uint256 public assetsAtLastHarvest; // assets for which the harvest took place.

    mapping(address => uint256) public additionalTokensEarned;
    mapping(address => uint256) public lastAdditionalTokenAmount;

    uint256 public performanceFeeGovernance; // Perf fee sent to `treasury`
    uint256 public performanceFeeStrategist; // Perf fee sent to `strategist`
    uint256 public withdrawalFee; // fee issued to `treasury` on withdrawal
    uint256 public managementFee; // fee issued to `treasury` on report (typically on harvest, but only if strat is autocompounding)

    uint256 public maxPerformanceFee; // maximum allowed performance fees
    uint256 public maxWithdrawalFee; // maximum allowed withdrawal fees
    uint256 public maxManagementFee; // maximum allowed management fees

    uint256 public toEarnBps; // NOTE: in BPS, minimum amount of token to deposit into strategy when earn is called


    uint256 public constant MAX_BPS = 10_000;
    uint256 public constant SECS_PER_YEAR = 31_556_952; // 365.2425 days

    uint256 public constant WITHDRAWAL_FEE_HARD_CAP = 200; // Never higher than 2%
    uint256 public constant PERFORMANCE_FEE_HARD_CAP = 3_000; // Never higher than 30% // 30% maximum performance fee // We usually do 20, so this is insanely high already
    uint256 public constant MANAGEMENT_FEE_HARD_CAP = 200; // Never higher than 2%


    event TreeDistribution(
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );

    event Harvested(
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );

    event SetTreasury(address indexed newTreasury);
    event SetStrategy(address indexed newStrategy);
    event SetToEarnBps(uint256 newEarnToBps);
    event SetMaxWithdrawalFee(uint256 newMaxWithdrawalFee);
    event SetMaxPerformanceFee(uint256 newMaxPerformanceFee);
    event SetMaxManagementFee(uint256 newMaxManagementFee);
    event SetGuardian(address indexed newGuardian);
    event SetVesting(address indexed newVesting);
    event SetGuestList(address indexed newGuestList);
    event SetWithdrawalFee(uint256 newWithdrawalFee);
    event SetPerformanceFeeStrategist(uint256 newPerformanceFeeStrategist);
    event SetPerformanceFeeGovernance(uint256 newPerformanceFeeGovernance);
    event SetManagementFee(uint256 newManagementFee);

    event PauseDeposits(address indexed pausedBy);
    event UnpauseDeposits(address indexed pausedBy);

    function initialize(
        address _token,
        address _governance,
        address _keeper,
        address _guardian,
        address _treasury,
        address _strategist,
        address _badgerTree,
        address _vesting,
        string memory _name,
        string memory _symbol,
        uint256[4] memory _feeConfig
    ) public initializer whenNotPaused {

        require(_token != address(0)); // dev: _token address should not be zero
        require(_governance != address(0)); // dev: _governance address should not be zero
        require(_keeper != address(0)); // dev: _keeper address should not be zero
        require(_guardian != address(0)); // dev: _guardian address should not be zero
        require(_treasury != address(0)); // dev: _treasury address should not be zero
        require(_strategist != address(0)); // dev: _strategist address should not be zero
        require(_badgerTree != address(0)); // dev: _badgerTree address should not be zero
        require(_vesting != address(0)); // dev: _vesting address should not be zero

        require(
            _feeConfig[0] <= PERFORMANCE_FEE_HARD_CAP,
            "performanceFeeGovernance too high"
        );
        require(
            _feeConfig[1] <= PERFORMANCE_FEE_HARD_CAP,
            "performanceFeeStrategist too high"
        );
        require(
            _feeConfig[2] <= WITHDRAWAL_FEE_HARD_CAP,
            "withdrawalFee too high"
        );
        require(
            _feeConfig[3] <= MANAGEMENT_FEE_HARD_CAP,
            "managementFee too high"
        );

        string memory name;
        string memory symbol;

        IERC20 namedToken = IERC20(_token);

        if (keccak256(abi.encodePacked(_name)) != keccak256("")) {
            name = _name;
        } else {
            name = string(
                abi.encodePacked(_defaultNamePrefix, namedToken.name())
            );
        }

        if (keccak256(abi.encodePacked(_symbol)) != keccak256("")) {
            symbol = _symbol;
        } else {
            symbol = string(
                abi.encodePacked(_symbolSymbolPrefix, namedToken.symbol())
            );
        }

        __ERC20_init(name, symbol);
        __Pausable_init();
        __ReentrancyGuard_init();

        token = IERC20Upgradeable(_token);
        governance = _governance;
        treasury = _treasury;
        strategist = _strategist;
        keeper = _keeper;
        guardian = _guardian;
        badgerTree = _badgerTree;
        vesting = _vesting;

        lastHarvestedAt = block.timestamp; // setting initial value to the time when the vault was deployed

        performanceFeeGovernance = _feeConfig[0];
        performanceFeeStrategist = _feeConfig[1];
        withdrawalFee = _feeConfig[2];
        managementFee = _feeConfig[3];
        maxPerformanceFee = PERFORMANCE_FEE_HARD_CAP; // 30% max performance fee
        maxWithdrawalFee = WITHDRAWAL_FEE_HARD_CAP; // 2% maximum withdrawal fee
        maxManagementFee = MANAGEMENT_FEE_HARD_CAP; // 2% maximum management fee

        toEarnBps = 9_500; // initial value of toEarnBps // 95% is invested to the strategy, 5% for cheap withdrawals
    }


    function _onlyAuthorizedPausers() internal view {

        require(
            msg.sender == guardian || msg.sender == governance,
            "onlyPausers"
        );
    }

    function _onlyStrategy() internal view {

        require(msg.sender == strategy, "onlyStrategy");
    }


    function version() external pure returns (string memory) {

        return "1.5";
    }

    function getPricePerFullShare() public view returns (uint256) {

        if (totalSupply() == 0) {
            return ONE_ETH;
        }
        return (balance() * ONE_ETH) / totalSupply();
    }

    function balance() public view returns (uint256) {

        return token.balanceOf(address(this)) + IStrategy(strategy).balanceOf();
    }

    function available() public view returns (uint256) {

        return (token.balanceOf(address(this)) * toEarnBps) / MAX_BPS;
    }


    function deposit(uint256 _amount) external whenNotPaused {

        _depositWithAuthorization(_amount, new bytes32[](0));
    }

    function deposit(uint256 _amount, bytes32[] memory proof)
        external
        whenNotPaused
    {

        _depositWithAuthorization(_amount, proof);
    }

    function depositAll() external whenNotPaused {

        _depositWithAuthorization(
            token.balanceOf(msg.sender),
            new bytes32[](0)
        );
    }

    function depositAll(bytes32[] memory proof) external whenNotPaused {

        _depositWithAuthorization(token.balanceOf(msg.sender), proof);
    }

    function depositFor(address _recipient, uint256 _amount)
        external
        whenNotPaused
    {

        _depositForWithAuthorization(_recipient, _amount, new bytes32[](0));
    }

    function depositFor(
        address _recipient,
        uint256 _amount,
        bytes32[] memory proof
    ) external whenNotPaused {

        _depositForWithAuthorization(_recipient, _amount, proof);
    }

    function withdraw(uint256 _shares) external whenNotPaused {

        _withdraw(_shares);
    }

    function withdrawAll() external whenNotPaused {

        _withdraw(balanceOf(msg.sender));
    }


    function reportHarvest(uint256 _harvestedAmount) external nonReentrant {

        _onlyStrategy();

        uint256 harvestTime = block.timestamp;
        uint256 assetsAtHarvest = balance() - _harvestedAmount; // Must be less than or equal or revert

        _handleFees(_harvestedAmount, harvestTime);

        lastHarvestAmount = _harvestedAmount;

        if (assetsAtHarvest != 0) {
            assetsAtLastHarvest = assetsAtHarvest;
        } else if (_harvestedAmount == 0) {
            assetsAtLastHarvest = 0;
        }

        lifeTimeEarned = lifeTimeEarned + _harvestedAmount;
        lastHarvestedAt = harvestTime;

        emit Harvested(
            address(token),
            _harvestedAmount,
            block.number,
            block.timestamp
        );
    }

    function reportAdditionalToken(address _token) external nonReentrant {

        _onlyStrategy();
        require(address(token) != _token, "No want");
        uint256 tokenBalance = IERC20Upgradeable(_token).balanceOf(
            address(this)
        );

        additionalTokensEarned[_token] =
            additionalTokensEarned[_token] +
            tokenBalance;
        lastAdditionalTokenAmount[_token] = tokenBalance;

        uint256 governanceRewardsFee = _calculateFee(
            tokenBalance,
            performanceFeeGovernance
        );
        uint256 strategistRewardsFee = _calculateFee(
            tokenBalance,
            performanceFeeStrategist
        );

        if (governanceRewardsFee != 0) {
            IERC20Upgradeable(_token).safeTransfer(
                treasury,
                governanceRewardsFee
            );
        }
        if (strategistRewardsFee != 0) {
            IERC20Upgradeable(_token).safeTransfer(
                strategist,
                strategistRewardsFee
            );
        }

        uint256 newBalance = IERC20Upgradeable(_token).balanceOf(address(this));
        IERC20Upgradeable(_token).safeTransfer(badgerTree, newBalance);
        emit TreeDistribution(
            _token,
            newBalance,
            block.number,
            block.timestamp
        );
    }


    function setTreasury(address _treasury) external whenNotPaused {

        _onlyGovernance();
        require(_treasury != address(0), "Address 0");

        treasury = _treasury;
        emit SetTreasury(_treasury);
    }

    function setStrategy(address _strategy) external whenNotPaused {

        _onlyGovernance();
        require(_strategy != address(0), "Address 0");

        if (strategy != address(0)) {
            require(
                IStrategy(strategy).balanceOf() == 0,
                "Please withdrawToVault before changing strat"
            );
        }
        strategy = _strategy;
        emit SetStrategy(_strategy);
    }


    function setMaxWithdrawalFee(uint256 _fees) external {

        _onlyGovernance();
        require(_fees <= WITHDRAWAL_FEE_HARD_CAP, "withdrawalFee too high");

        maxWithdrawalFee = _fees;
        emit SetMaxWithdrawalFee(_fees);
    }

    function setMaxPerformanceFee(uint256 _fees) external {

        _onlyGovernance();
        require(
            _fees <= PERFORMANCE_FEE_HARD_CAP,
            "performanceFeeStrategist too high"
        );

        maxPerformanceFee = _fees;
        emit SetMaxPerformanceFee(_fees);
    }

    function setMaxManagementFee(uint256 _fees) external {

        _onlyGovernance();
        require(_fees <= MANAGEMENT_FEE_HARD_CAP, "managementFee too high");

        maxManagementFee = _fees;
        emit SetMaxManagementFee(_fees);
    }

    function setGuardian(address _guardian) external {

        _onlyGovernance();
        require(_guardian != address(0), "Address cannot be 0x0");

        guardian = _guardian;
        emit SetGuardian(_guardian);
    }

    function setVesting(address _vesting) external {

        _onlyGovernance();
        require(_vesting != address(0), "Address cannot be 0x0");

        vesting = _vesting;
        emit SetVesting(_vesting);
    }


    function setToEarnBps(uint256 _newToEarnBps) external whenNotPaused {

        _onlyGovernanceOrStrategist();
        require(_newToEarnBps <= MAX_BPS, "toEarnBps should be <= MAX_BPS");

        toEarnBps = _newToEarnBps;
        emit SetToEarnBps(_newToEarnBps);
    }

    function setGuestList(address _guestList) external whenNotPaused {

        _onlyGovernanceOrStrategist();
        guestList = IBadgerGuestlist(_guestList);
        emit SetGuestList(_guestList);
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external whenNotPaused {

        _onlyGovernanceOrStrategist();
        require(_withdrawalFee <= maxWithdrawalFee, "Excessive withdrawal fee");
        withdrawalFee = _withdrawalFee;
        emit SetWithdrawalFee(_withdrawalFee);
    }

    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist)
        external
        whenNotPaused
    {

        _onlyGovernanceOrStrategist();
        require(
            _performanceFeeStrategist <= maxPerformanceFee,
            "Excessive strategist performance fee"
        );
        performanceFeeStrategist = _performanceFeeStrategist;
        emit SetPerformanceFeeStrategist(_performanceFeeStrategist);
    }

    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance)
        external
        whenNotPaused
    {

        _onlyGovernanceOrStrategist();
        require(
            _performanceFeeGovernance <= maxPerformanceFee,
            "Excessive governance performance fee"
        );
        performanceFeeGovernance = _performanceFeeGovernance;
        emit SetPerformanceFeeGovernance(_performanceFeeGovernance);
    }

    function setManagementFee(uint256 _fees) external whenNotPaused {

        _onlyGovernanceOrStrategist();
        require(_fees <= maxManagementFee, "Excessive management fee");
        managementFee = _fees;
        emit SetManagementFee(_fees);
    }


    function withdrawToVault() external {

        _onlyGovernanceOrStrategist();
        IStrategy(strategy).withdrawToVault();
    }

    function emitNonProtectedToken(address _token) external {

        _onlyGovernanceOrStrategist();

        IStrategy(strategy).emitNonProtectedToken(_token);
    }

    function sweepExtraToken(address _token) external {

        _onlyGovernanceOrStrategist();
        require(address(token) != _token, "No want");

        IStrategy(strategy).withdrawOther(_token);
        IERC20Upgradeable(_token).safeTransfer(
            governance,
            IERC20Upgradeable(_token).balanceOf(address(this))
        );
    }

    function earn() external {

        require(!pausedDeposit, "pausedDeposit"); // dev: deposits are paused, we don't earn as well
        _onlyAuthorizedActors();

        uint256 _bal = available();
        token.safeTransfer(strategy, _bal);
        IStrategy(strategy).earn();
    }

    function pauseDeposits() external {

        _onlyAuthorizedPausers();
        pausedDeposit = true;
        emit PauseDeposits(msg.sender);
    }

    function unpauseDeposits() external {

        _onlyGovernance();
        pausedDeposit = false;
        emit UnpauseDeposits(msg.sender);
    }

    function pause() external {

        _onlyAuthorizedPausers();
        _pause();
    }

    function unpause() external {

        _onlyGovernance();
        _unpause();
    }


    function _depositFor(address _recipient, uint256 _amount)
        internal
        nonReentrant
    {

        require(_recipient != address(0), "Address 0");
        require(_amount != 0, "Amount 0");
        require(!pausedDeposit, "pausedDeposit"); // dev: deposits are paused

        uint256 _pool = balance();
        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _mintSharesFor(_recipient, _after - _before, _pool);
    }

    function _depositWithAuthorization(uint256 _amount, bytes32[] memory proof)
        internal
    {

        _depositForWithAuthorization(msg.sender, _amount, proof);
    }

    function _depositForWithAuthorization(
        address _recipient,
        uint256 _amount,
        bytes32[] memory proof
    ) internal {

        if (address(guestList) != address(0)) {
            require(
                guestList.authorized(_recipient, _amount, proof),
                "GuestList: Not Authorized"
            );
        }
        _depositFor(_recipient, _amount);
    }

    function _withdraw(uint256 _shares) internal nonReentrant {

        require(_shares != 0, "0 Shares");

        uint256 r = (balance() * _shares) / totalSupply();
        _burn(msg.sender, _shares);

        uint256 b = token.balanceOf(address(this));
        if (b < r) {
            uint256 _toWithdraw = r - b;
            IStrategy(strategy).withdraw(_toWithdraw);
            uint256 _after = token.balanceOf(address(this));
            uint256 _diff = _after - b;
            if (_diff < _toWithdraw) {
                r = b + _diff;
            }
        }

        uint256 _fee = _calculateFee(r, withdrawalFee);
        uint256 _amount = r - _fee;

        IVesting(vesting).setupVesting(msg.sender, _amount, block.timestamp);
        token.safeTransfer(vesting, _amount);

        if (_fee > 0) {
            _mintSharesFor(treasury, _fee, balance() - _fee);
        }
    }

    function _calculateFee(uint256 amount, uint256 feeBps)
        internal
        pure
        returns (uint256)
    {

        if (feeBps == 0) {
            return 0;
        }
        uint256 fee = (amount * feeBps) / MAX_BPS;
        return fee;
    }

    function _calculatePerformanceFee(uint256 _amount)
        internal
        view
        returns (uint256, uint256)
    {

        uint256 governancePerformanceFee = _calculateFee(
            _amount,
            performanceFeeGovernance
        );

        uint256 strategistPerformanceFee = _calculateFee(
            _amount,
            performanceFeeStrategist
        );

        return (governancePerformanceFee, strategistPerformanceFee);
    }

    function _mintSharesFor(
        address recipient,
        uint256 _amount,
        uint256 _pool
    ) internal {

        uint256 shares;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply()) / _pool;
        }
        if (shares != 0) {
            _mint(recipient, shares);
        }
    }

    function _handleFees(uint256 _harvestedAmount, uint256 harvestTime)
        internal
    {

        (
            uint256 feeGovernance,
            uint256 feeStrategist
        ) = _calculatePerformanceFee(_harvestedAmount);
        uint256 duration = harvestTime - lastHarvestedAt;

        uint256 management_fee = managementFee > 0
            ? (managementFee * (balance() - _harvestedAmount) * duration) /
                SECS_PER_YEAR /
                MAX_BPS
            : 0;
        uint256 totalGovernanceFee = feeGovernance + management_fee;

        uint256 _pool = balance() - totalGovernanceFee - feeStrategist;

        if (totalGovernanceFee != 0) {
            _mintSharesFor(treasury, totalGovernanceFee, _pool);
        }

        if (feeStrategist != 0 && strategist != address(0)) {
            _mintSharesFor(
                strategist,
                feeStrategist,
                _pool + totalGovernanceFee
            );
        }
    }
}