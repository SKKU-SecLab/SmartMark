
pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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
}// MIT
pragma solidity 0.6.12;


library SafeRatioMath {

    using SafeMathUpgradeable for uint256;

    uint256 private constant BASE = 10**18;

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(BASE).div(b);
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(b).div(BASE);
    }

    function rdivup(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(BASE).add(b.sub(1)).div(b);
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.6.12;


interface IStakedDF is IERC20Upgradeable {

    function stake(address _recipient, uint256 _rawUnderlyingAmount)
        external
        returns (uint256 _tokenAmount);


    function unstake(address _recipient, uint256 _rawTokenAmount)
        external
        returns (uint256 _tokenAmount);


    function getCurrentExchangeRate()
        external
        view
        returns (uint256 _exchangeRate);


    function DF() external view returns (address);

}// MIT
pragma solidity 0.6.12;

contract Ownable {

    address payable public owner;

    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    modifier onlyOwner() {

        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {

        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {

        require(
            newPendingOwner != address(0) && newPendingOwner != pendingOwner,
            "_setPendingOwner: New owenr can not be zero address and owner has been set!"
        );

        address oldPendingOwner = pendingOwner;

        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    function _acceptOwner() external {

        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        owner = pendingOwner;

        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }

    uint256[50] private __gap;
}// MIT
pragma solidity 0.6.12;


abstract contract ERC20Permit {
    using SafeMathUpgradeable for uint256;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x576144ed657c8304561e56ca632e17751956250114636e8c01f64a7f2c6d98cf;
    mapping(address => uint256) public erc20Nonces;

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external virtual {
        require(_deadline >= block.timestamp, "permit: EXPIRED!");
        uint256 _currentNonce = erc20Nonces[_owner];

        bytes32 _digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            _owner,
                            _spender,
                            _getChainId(),
                            _value,
                            _currentNonce,
                            _deadline
                        )
                    )
                )
            );
        address _recoveredAddress = ecrecover(_digest, _v, _r, _s);
        require(
            _recoveredAddress != address(0) && _recoveredAddress == _owner,
            "permit: INVALID_SIGNATURE!"
        );
        erc20Nonces[_owner] = _currentNonce.add(1);
        _approveERC20(_owner, _spender, _value);
    }

    function _getChainId() internal pure virtual returns (uint256) {
        uint256 _chainId;
        assembly {
            _chainId := chainid()
        }
        return _chainId;
    }

    function _approveERC20(address _owner, address _spender, uint256 _amount) internal virtual;
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.6.12;


contract StakedDF is Ownable, ReentrancyGuardUpgradeable, ERC20Upgradeable, ERC20Permit {

    using SafeRatioMath for uint256;
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 internal constant MAX_REWARD_RATE = 4122 * 10**18;
    uint256 internal constant BASE = 10**18;
    IERC20Upgradeable public DF;
    address public rewardDistributor;
    uint256 public rewardRate;
    uint256 public startBlock;
    uint256 public totalDistributedAmount;
    uint256 public totalExecutedAmount;
    uint256 public blockPerYear;

    event Stake(
        address spender,
        address recipient,
        uint256 underlyingAmount,
        uint256 tokenAmount
    );
    event Unstake(
        address from,
        address recipient,
        uint256 underlyingAmount,
        uint256 tokenAmount
    );
    event NewRewardRate(
        uint256 startBlock,
        uint256 oldRewardRate,
        uint256 newRewardRate
    );
    event NewRewardDistributor(address oldVault, address newVault);
    event RewardExecuted(uint256 rewardExecutedAmount);

    constructor(
        address _rewardDistributor,
        IERC20Upgradeable _DF,
        uint256 _blockPerYear
    ) public {
        initialize(_rewardDistributor, _DF, _blockPerYear);
    }

    function initialize(
        address _rewardDistributor,
        IERC20Upgradeable _DF,
        uint256 _blockPerYear
    ) public initializer {

        require(
            _rewardDistributor != address(0),
            "sDF: Invalid reward contract address!"
        );
        require(
            address(_DF) != address(0),
            "sDF: Invalid DF contract address!"
        );

        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC20_init("Staked DF", "sDF");

        rewardDistributor = _rewardDistributor;
        DF = _DF;
        blockPerYear = _blockPerYear;
        startBlock = block.number + 1;
        totalDistributedAmount = 0;
        totalExecutedAmount = 0;

        emit NewRewardDistributor(address(0), _rewardDistributor);
    }

    modifier onlyRewardDistributor() {

        require(
            rewardDistributor == msg.sender,
            "sDF: caller is not the rewardDistributor"
        );
        _;
    }


    function issDF() external pure returns (bool) {

        return true;
    }

    function _calculateExchange()
        internal
        view
        returns (uint256 _exchangeRate)
    {

        uint256 _totalSupply = totalSupply();
        if (_totalSupply != 0) {
            uint256 _availableDFAmount = getCurrentUnderlyingAndRewards();
            _exchangeRate = _availableDFAmount.rdiv(_totalSupply);
        } else {
            _exchangeRate = BASE;
        }
    }

    function getCurrentExchangeRate()
        public
        view
        returns (uint256 _exchangeRate)
    {

        _exchangeRate = _calculateExchange();
    }

    function setRewardRate(uint256 _newRawRewardRate)
        external
        onlyRewardDistributor
    {

        require(
            _newRawRewardRate <= MAX_REWARD_RATE,
            "setRewardRate: New reward rate too large to set!"
        );
        uint256 _oldRewardRate = rewardRate;
        require(
            _newRawRewardRate != _oldRewardRate,
            "setRewardRate: Can not set the same reward rate!"
        );
        rewardRate = _newRawRewardRate;

        if (block.number > startBlock) {
            uint256 _blockDelta = block.number.sub(startBlock);
            uint256 _accruedRewards = _blockDelta.mul(_oldRewardRate);
            totalDistributedAmount = totalDistributedAmount.add(
                _accruedRewards
            );
            startBlock = block.number;
        }

        emit NewRewardRate(startBlock, _oldRewardRate, _newRawRewardRate);
    }

    function setNewVault(address _newVault) external onlyOwner {

        address _oldVault = rewardDistributor;
        require(
            _newVault != address(0),
            "setNewVault: Vault contract can not be zero address!"
        );
        require(
            _newVault != _oldVault,
            "setNewVault: Same reward vault contract address!"
        );

        rewardDistributor = _newVault;

        emit NewRewardDistributor(_oldVault, _newVault);
    }

    function stake(address _recipient, uint256 _rawUnderlyingAmount)
        external
        nonReentrant
        returns (uint256 _tokenAmount)
    {

        require(_recipient != address(0), "stake: Mint to the zero address!");
        require(
            _rawUnderlyingAmount != 0,
            "stake: Stake amount can not be zero!"
        );

        uint256 _exchangeRate = _calculateExchange();
        _tokenAmount = _rawUnderlyingAmount.rdiv(_exchangeRate);

        _mint(_recipient, _tokenAmount);
        DF.safeTransferFrom(msg.sender, address(this), _rawUnderlyingAmount);

        emit Stake(msg.sender, _recipient, _rawUnderlyingAmount, _tokenAmount);
    }

    function getTokenFromVault(uint256 _toWithdrawAmount) internal {

        uint256 _currentUnderlyingBalance = _getUnderlyingTotalAmount();
        if (_toWithdrawAmount > _currentUnderlyingBalance) {
            uint256 _insufficientAmount = _toWithdrawAmount.sub(
                _currentUnderlyingBalance
            );
            DF.safeTransferFrom(
                rewardDistributor,
                address(this),
                _insufficientAmount
            );
            totalExecutedAmount = totalExecutedAmount.add(_insufficientAmount);

            emit RewardExecuted(_insufficientAmount);
        }
    }

    function _approveERC20(address _owner, address _spender, uint256 _amount) internal override {

        _approve(_owner, _spender, _amount);
    }

    function _burnFrom(
        address _from,
        address _caller,
        uint256 _amount
    ) internal {

        if (_caller != _from) {
            uint256 _spenderAllowance = allowance(_from, _caller);

            uint256 _newAllowance = _spenderAllowance.sub(
                _amount,
                "_burnFrom: Burn amount exceeds spender allowance!"
            );
            _approve(_from, _caller, _newAllowance);
        }

        _burn(_from, _amount);
    }

    function unstake(address _from, uint256 _rawTokenAmount)
        external
        nonReentrant
        returns (uint256 _underlyingAmount)
    {

        require(
            _rawTokenAmount != 0,
            "unstake: Unstake amount can not be zero!"
        );

        uint256 _exchangeRate = _calculateExchange();
        _underlyingAmount = _rawTokenAmount.rmul(_exchangeRate);

        address _caller = msg.sender;

        _burnFrom(_from, _caller, _rawTokenAmount);

        getTokenFromVault(_underlyingAmount);
        DF.safeTransfer(_caller, _underlyingAmount);

        emit Unstake(_from, _caller, _underlyingAmount, _rawTokenAmount);
    }

    function unstakeUnderlying(address _from, uint256 _underlyingAmount)
        external
        nonReentrant
    {

        require(
            _underlyingAmount != 0,
            "unstakeUnderlying: Unstake underlying amount can not be zero!"
        );

        uint256 _exchangeRate = _calculateExchange();
        uint256 _tokenAmount = _underlyingAmount.rdivup(_exchangeRate);

        address _caller = msg.sender;

        _burnFrom(_from, _caller, _tokenAmount);

        getTokenFromVault(_underlyingAmount);
        DF.safeTransfer(_caller, _underlyingAmount);

        emit Unstake(_from, _caller, _underlyingAmount, _tokenAmount);
    }

    function _getUnderlyingTotalAmount() internal view returns (uint256) {

        return DF.balanceOf(address(this));
    }

    function getCurrentUnderlyingAndRewards() public view returns (uint256) {

        uint256 _periodRewards;
        uint256 _underlyingTokenAmount = _getUnderlyingTotalAmount();
        uint256 _currentBlock = block.number;
        if (_currentBlock < startBlock) {
            _periodRewards = 0;
        } else {
            uint256 _blockDelta = _currentBlock.sub(startBlock);
            _periodRewards = _blockDelta.mul(rewardRate);
        }

        return
            _underlyingTokenAmount
                .add(totalDistributedAmount)
                .add(_periodRewards)
                .sub(totalExecutedAmount);
    }

    function getAnnualInterestRate() external view returns (uint256) {

        if (totalSupply() == 0) return 0;
        return
            rewardRate.mul(blockPerYear).rdiv(totalSupply()).rdiv(
                _calculateExchange()
            );
    }
}