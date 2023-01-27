



pragma solidity ^0.8.0;

interface IBeacon {

    function childImplementation() external view returns (address);

    function upgradeChildTo(address newImplementation) external;

}





pragma solidity ^0.8.0;

interface INFTXVaultFactory is IBeacon {

  function numVaults() external view returns (uint256);

  function zapContract() external view returns (address);

  function feeDistributor() external view returns (address);

  function eligibilityManager() external view returns (address);

  function vault(uint256 vaultId) external view returns (address);

  function allVaults() external view returns (address[] memory);

  function vaultsForAsset(address asset) external view returns (address[] memory);

  function isLocked(uint256 id) external view returns (bool);

  function excludedFromFees(address addr) external view returns (bool);

  function factoryMintFee() external view returns (uint64);

  function factoryRandomRedeemFee() external view returns (uint64);

  function factoryTargetRedeemFee() external view returns (uint64);

  function factoryRandomSwapFee() external view returns (uint64);

  function factoryTargetSwapFee() external view returns (uint64);

  function vaultFees(uint256 vaultId) external view returns (uint256, uint256, uint256, uint256, uint256);


  event NewFeeDistributor(address oldDistributor, address newDistributor);
  event NewZapContract(address oldZap, address newZap);
  event FeeExclusion(address feeExcluded, bool excluded);
  event NewEligibilityManager(address oldEligManager, address newEligManager);
  event NewVault(uint256 indexed vaultId, address vaultAddress, address assetAddress);
  event UpdateVaultFees(uint256 vaultId, uint256 mintFee, uint256 randomRedeemFee, uint256 targetRedeemFee, uint256 randomSwapFee, uint256 targetSwapFee);
  event DisableVaultFees(uint256 vaultId);
  event UpdateFactoryFees(uint256 mintFee, uint256 randomRedeemFee, uint256 targetRedeemFee, uint256 randomSwapFee, uint256 targetSwapFee);

  function __NFTXVaultFactory_init(address _vaultImpl, address _feeDistributor) external;

  function createVault(
      string calldata name,
      string calldata symbol,
      address _assetAddress,
      bool is1155,
      bool allowAllItems
  ) external returns (uint256);

  function setFeeDistributor(address _feeDistributor) external;

  function setEligibilityManager(address _eligibilityManager) external;

  function setZapContract(address _zapContract) external;

  function setFeeExclusion(address _excludedAddr, bool excluded) external;


  function setFactoryFees(
    uint256 mintFee, 
    uint256 randomRedeemFee, 
    uint256 targetRedeemFee,
    uint256 randomSwapFee, 
    uint256 targetSwapFee
  ) external; 

  function setVaultFees(
      uint256 vaultId, 
      uint256 mintFee, 
      uint256 randomRedeemFee, 
      uint256 targetRedeemFee,
      uint256 randomSwapFee, 
      uint256 targetSwapFee
  ) external;

  function disableVaultFees(uint256 vaultId) external;

}





pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





pragma solidity ^0.8.0;

interface IRewardDistributionToken is IERC20Upgradeable {

  function distributeRewards(uint amount) external;

  function __RewardDistributionToken_init(IERC20Upgradeable _target, string memory _name, string memory _symbol) external;

  function mint(address account, address to, uint256 amount) external;

  function burnFrom(address account, uint256 amount) external;

  function withdrawReward(address user) external;

  function dividendOf(address _owner) external view returns(uint256);

  function withdrawnRewardOf(address _owner) external view returns(uint256);

  function accumulativeRewardOf(address _owner) external view returns(uint256);

}





pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}





pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using Address for address;

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





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
}





pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}





pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}





pragma solidity ^0.8.0;

contract PausableUpgradeable is OwnableUpgradeable {


    function __Pausable_init() internal initializer {

        __Ownable_init();
    }

    event SetPaused(uint256 lockId, bool paused);
    event SetIsGuardian(address addr, bool isGuardian);

    mapping(address => bool) public isGuardian;
    mapping(uint256 => bool) public isPaused;

    function onlyOwnerIfPaused(uint256 lockId) public view virtual {

        require(!isPaused[lockId] || msg.sender == owner(), "Paused");
    }

    function unpause(uint256 lockId)
        public
        virtual
        onlyOwner
    {

        isPaused[lockId] = false;
        emit SetPaused(lockId, false);
    }

    function pause(uint256 lockId) public virtual {

        require(isGuardian[msg.sender], "Can't pause");
        isPaused[lockId] = true;
        emit SetPaused(lockId, true);
    }

    function setIsGuardian(address addr, bool _isGuardian) public virtual onlyOwner {

        isGuardian[addr] = _isGuardian;
        emit SetIsGuardian(addr, _isGuardian);
    }
}





pragma solidity ^0.8.0;

library ClonesUpgradeable {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}





pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





pragma solidity ^0.8.0;




contract StakingTokenProvider is OwnableUpgradeable {


  address public uniLikeExchange;
  address public defaultPairedToken;
  string public defaultPrefix;
  mapping(address => address) public pairedToken;
  mapping(address => string) public pairedPrefix;

  event NewDefaultPaired(address oldPaired, address newPaired);
  event NewPairedTokenForVault(address vaultToken, address oldPairedtoken, address newPairedToken);

  function __StakingTokenProvider_init(address _uniLikeExchange, address _defaultPairedtoken, string memory _defaultPrefix) public initializer {

    __Ownable_init();
    require(_uniLikeExchange != address(0), "Cannot be address(0)");
    require(_defaultPairedtoken != address(0), "Cannot be address(0)");
    uniLikeExchange = _uniLikeExchange;
    defaultPairedToken = _defaultPairedtoken;
    defaultPrefix = _defaultPrefix;
  }

  function setPairedTokenForVaultToken(address _vaultToken, address _newPairedToken, string calldata _newPrefix) external onlyOwner {

    require(_newPairedToken != address(0), "Cannot be address(0)");
    emit NewPairedTokenForVault(_vaultToken, pairedToken[_vaultToken], _newPairedToken);
    pairedToken[_vaultToken] = _newPairedToken;
    pairedPrefix[_vaultToken] = _newPrefix;
  }

  function setDefaultPairedToken(address _newDefaultPaired, string calldata _newDefaultPrefix) external onlyOwner {

    emit NewDefaultPaired(defaultPairedToken, _newDefaultPaired);
    defaultPairedToken = _newDefaultPaired;
    defaultPrefix = _newDefaultPrefix;
  }

  function stakingTokenForVaultToken(address _vaultToken) external view returns (address) {

    address _pairedToken = pairedToken[_vaultToken];
    if (_pairedToken == address(0)) {
      _pairedToken = defaultPairedToken;
    }
    return pairFor(uniLikeExchange, _vaultToken, _pairedToken);
  }

  function nameForStakingToken(address _vaultToken) external view returns (string memory) {

    string memory _pairedPrefix = pairedPrefix[_vaultToken];
    if (bytes(_pairedPrefix).length == 0) {
      _pairedPrefix = defaultPrefix;
    }
    address _pairedToken = pairedToken[_vaultToken];
    if (_pairedToken == address(0)) {
      _pairedToken = defaultPairedToken;
    }

    string memory symbol1 = IERC20Metadata(_vaultToken).symbol();
    string memory symbol2 = IERC20Metadata(_pairedToken).symbol();
    return string(abi.encodePacked(_pairedPrefix, symbol1, symbol2));
  }

  function pairForVaultToken(address _vaultToken, address _pairedToken) external view returns (address) {

    return pairFor(uniLikeExchange, _vaultToken, _pairedToken);
  }
  
  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

      require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
      (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
      require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
  }

  function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

      (address token0, address token1) = sortTokens(tokenA, tokenB);
      pair = address(uint160(uint256(keccak256(abi.encodePacked(
              hex'ff',
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303' // init code hash
      )))));
  }
}





pragma solidity ^0.8.0;




contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
    }

    function _setMetadata(string memory name_, string memory symbol_) internal {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[45] private __gap;
}





pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
    
    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}





pragma solidity ^0.8.0;

library SafeMathInt {

  function mul(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && (b > 0));

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {

    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {

    require(a >= 0);
    return uint256(a);
  }
}




pragma solidity ^0.8.0;







contract TimelockRewardDistributionTokenImpl is OwnableUpgradeable, ERC20Upgradeable {

  using SafeMathUpgradeable for uint256;
  using SafeMathInt for int256;
  using SafeERC20Upgradeable for IERC20Upgradeable;
  
  IERC20Upgradeable public target;

  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedRewardPerShare;

  mapping(address => int256) internal magnifiedRewardCorrections;
  mapping(address => uint256) internal withdrawnRewards;

  mapping(address => uint256) internal timelock;

  event Timelocked(address user, uint256 amount, uint256 until);

  function __TimelockRewardDistributionToken_init(IERC20Upgradeable _target, string memory _name, string memory _symbol) public initializer {

    __Ownable_init();
    __ERC20_init(_name, _symbol);
    target = _target;
  }

  function transfer(address recipient, uint256 amount)
      public
      virtual
      override
      returns (bool)
  {

      _transfer(_msgSender(), recipient, amount);
      return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount)
      public
      virtual
      override
      returns (bool)
  {

      _transfer(sender, recipient, amount);
      _approve(
          sender,
          _msgSender(),
          allowance(sender, _msgSender()).sub(
              amount,
              "ERC20: transfer amount exceeds allowance"
          )
      );
      return true;
  }

  function mint(address account, uint256 amount) public onlyOwner virtual {

      _mint(account, amount);
  }

  function timelockMint(address account, uint256 amount, uint256 timelockLength) public onlyOwner virtual {

    uint256 timelockFinish = block.timestamp + timelockLength;
    timelock[account] = timelockFinish;
    emit Timelocked(account, amount, timelockFinish);
    _mint(account, amount);
  }

  function timelockUntil(address account) public view returns (uint256) {

    return timelock[account];
  }

  function burnFrom(address account, uint256 amount) public virtual onlyOwner {

      _burn(account, amount);
  }

  function distributeRewards(uint amount) external virtual onlyOwner {

    require(totalSupply() > 0, "RewardDist: 0 supply");
    require(amount > 0, "RewardDist: 0 amount");

    magnifiedRewardPerShare = magnifiedRewardPerShare.add(
      (amount).mul(magnitude) / totalSupply()
    );

    emit RewardsDistributed(msg.sender, amount);
  }

  function withdrawReward(address user) external onlyOwner {

    uint256 _withdrawableReward = withdrawableRewardOf(user);
    if (_withdrawableReward > 0) {
      withdrawnRewards[user] = withdrawnRewards[user].add(_withdrawableReward);
      target.safeTransfer(user, _withdrawableReward);
      emit RewardWithdrawn(user, _withdrawableReward);
    }
  }

  function dividendOf(address _owner) public view returns(uint256) {

    return withdrawableRewardOf(_owner);
  }

  function withdrawableRewardOf(address _owner) internal view returns(uint256) {

    return accumulativeRewardOf(_owner).sub(withdrawnRewards[_owner]);
  }

  function withdrawnRewardOf(address _owner) public view returns(uint256) {

    return withdrawnRewards[_owner];
  }


  function accumulativeRewardOf(address _owner) public view returns(uint256) {

    return magnifiedRewardPerShare.mul(balanceOf(_owner)).toInt256()
      .add(magnifiedRewardCorrections[_owner]).toUint256Safe() / magnitude;
  }

  function _transfer(address from, address to, uint256 value) internal override {

    require(block.timestamp > timelock[from], "User locked");
    super._transfer(from, to, value);

    int256 _magCorrection = magnifiedRewardPerShare.mul(value).toInt256();
    magnifiedRewardCorrections[from] = magnifiedRewardCorrections[from].add(_magCorrection);
    magnifiedRewardCorrections[to] = magnifiedRewardCorrections[to].sub(_magCorrection);
  }

  function _mint(address account, uint256 value) internal override {

    super._mint(account, value);

    magnifiedRewardCorrections[account] = magnifiedRewardCorrections[account]
      .sub( (magnifiedRewardPerShare.mul(value)).toInt256() );
  }

  function _burn(address account, uint256 value) internal override {

    require(block.timestamp > timelock[account], "User locked");
    super._burn(account, value);

    magnifiedRewardCorrections[account] = magnifiedRewardCorrections[account]
      .add( (magnifiedRewardPerShare.mul(value)).toInt256() );
  }

  event RewardsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  event RewardWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}





pragma solidity ^0.8.0;











contract NFTXLPStaking is PausableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    INFTXVaultFactory public nftxVaultFactory;
    IRewardDistributionToken public rewardDistTokenImpl;
    StakingTokenProvider public stakingTokenProvider;

    event PoolCreated(uint256 vaultId, address pool);
    event PoolUpdated(uint256 vaultId, address pool);
    event FeesReceived(uint256 vaultId, uint256 amount);

    struct StakingPool {
        address stakingToken;
        address rewardToken;
    }
    mapping(uint256 => StakingPool) public vaultStakingInfo;

    TimelockRewardDistributionTokenImpl public newTimelockRewardDistTokenImpl;

    function __NFTXLPStaking__init(address _stakingTokenProvider) external initializer {

        __Ownable_init();
        require(_stakingTokenProvider != address(0), "Provider != address(0)");
        require(address(newTimelockRewardDistTokenImpl) == address(0), "Already assigned");
        stakingTokenProvider = StakingTokenProvider(_stakingTokenProvider);
        newTimelockRewardDistTokenImpl = new TimelockRewardDistributionTokenImpl();
        newTimelockRewardDistTokenImpl.__TimelockRewardDistributionToken_init(IERC20Upgradeable(address(0)), "", "");
    }

    modifier onlyAdmin() {

        require(msg.sender == owner() || msg.sender == nftxVaultFactory.feeDistributor(), "LPStaking: Not authorized");
        _;
    }

    function setNFTXVaultFactory(address newFactory) external onlyOwner {

        require(address(nftxVaultFactory) == address(0), "nftxVaultFactory is immutable");
        nftxVaultFactory = INFTXVaultFactory(newFactory);
    }

    function setStakingTokenProvider(address newProvider) external onlyOwner {

        require(newProvider != address(0));
        stakingTokenProvider = StakingTokenProvider(newProvider);
    }

    function addPoolForVault(uint256 vaultId) external onlyAdmin {

        require(address(nftxVaultFactory) != address(0), "LPStaking: Factory not set");
        require(vaultStakingInfo[vaultId].stakingToken == address(0), "LPStaking: Pool already exists");
        address _rewardToken = nftxVaultFactory.vault(vaultId);
        address _stakingToken = stakingTokenProvider.stakingTokenForVaultToken(_rewardToken);
        StakingPool memory pool = StakingPool(_stakingToken, _rewardToken);
        vaultStakingInfo[vaultId] = pool;
        address newRewardDistToken = _deployDividendToken(pool);
        emit PoolCreated(vaultId, newRewardDistToken);
    }

    function updatePoolForVaults(uint256[] calldata vaultIds) external {

        uint256 length = vaultIds.length;
        for (uint256 i; i < length; ++i) {
            updatePoolForVault(vaultIds[i]);
        }
    }

    function updatePoolForVault(uint256 vaultId) public {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        require(pool.stakingToken != address(0), "LPStaking: Pool doesn't exist");
        address _stakingToken = stakingTokenProvider.stakingTokenForVaultToken(pool.rewardToken);
        StakingPool memory newPool = StakingPool(_stakingToken, pool.rewardToken);
        vaultStakingInfo[vaultId] = newPool;
        
        address addr = address(_rewardDistributionTokenAddr(newPool));
        if (isContract(addr)) {
            return;
        }
        address newRewardDistToken = _deployDividendToken(newPool);
        emit PoolUpdated(vaultId, newRewardDistToken);
    }

    function receiveRewards(uint256 vaultId, uint256 amount) external onlyAdmin returns (bool) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        if (pool.stakingToken == address(0)) {
            return false;
        }
        
        TimelockRewardDistributionTokenImpl rewardDistToken = _rewardDistributionTokenAddr(pool);
        if (!isContract(address(rewardDistToken)) || rewardDistToken.totalSupply() == 0) {
            return false;
        }
        IERC20Upgradeable(pool.rewardToken).safeTransferFrom(msg.sender, address(rewardDistToken), amount);
        rewardDistToken.distributeRewards(amount);
        emit FeesReceived(vaultId, amount);
        return true;
    }

    function deposit(uint256 vaultId, uint256 amount) external {

        onlyOwnerIfPaused(10);
        updatePoolForVault(vaultId);

        StakingPool memory pool = vaultStakingInfo[vaultId];
        require(pool.stakingToken != address(0), "LPStaking: Nonexistent pool");
        IERC20Upgradeable(pool.stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        TimelockRewardDistributionTokenImpl xSLPToken = _rewardDistributionTokenAddr(pool);

        uint256 currentTimelock = xSLPToken.timelockUntil(msg.sender);
        if (currentTimelock > block.timestamp) {
            xSLPToken.timelockMint(msg.sender, amount, currentTimelock-block.timestamp);
        } else {
            xSLPToken.timelockMint(msg.sender, amount, 2);
        }
    }

    function timelockDepositFor(uint256 vaultId, address account, uint256 amount, uint256 timelockLength) external {

        require(timelockLength < 2592000, "Timelock too long");
        require(nftxVaultFactory.excludedFromFees(msg.sender), "Not zap");
        onlyOwnerIfPaused(10);
        updatePoolForVault(vaultId);
        StakingPool memory pool = vaultStakingInfo[vaultId];
        require(pool.stakingToken != address(0), "LPStaking: Nonexistent pool");
        IERC20Upgradeable(pool.stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        _rewardDistributionTokenAddr(pool).timelockMint(account, amount, timelockLength);
    }

    function exit(uint256 vaultId) external {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        _claimRewards(pool, msg.sender);
        _withdraw(pool, balanceOf(vaultId, msg.sender), msg.sender);
    }

    function emergencyExitAndClaim(address _stakingToken, address _rewardToken) external {

        StakingPool memory pool = StakingPool(_stakingToken, _rewardToken);
        TimelockRewardDistributionTokenImpl dist = _rewardDistributionTokenAddr(pool);
        require(isContract(address(dist)), "Not a pool");
        _claimRewards(pool, msg.sender);
        _withdraw(pool, dist.balanceOf(msg.sender), msg.sender);
    }

    function emergencyExit(address _stakingToken, address _rewardToken) external {

        StakingPool memory pool = StakingPool(_stakingToken, _rewardToken);
        TimelockRewardDistributionTokenImpl dist = _rewardDistributionTokenAddr(pool);
        require(isContract(address(dist)), "Not a pool");
        _withdraw(pool, dist.balanceOf(msg.sender), msg.sender);
    }

    function emergencyMigrate(uint256 vaultId) external {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        IRewardDistributionToken unusedDist = _unusedRewardDistributionTokenAddr(pool);
        IRewardDistributionToken oldDist = _oldRewardDistributionTokenAddr(pool);

        uint256 unusedDistBal; 
        if (isContract(address(unusedDist))) {
            unusedDistBal = unusedDist.balanceOf(msg.sender);
            if (unusedDistBal > 0) {
                unusedDist.burnFrom(msg.sender, unusedDistBal);
            }
        }
        uint256 oldDistBal; 
        if (isContract(address(oldDist))) {
            oldDistBal = oldDist.balanceOf(msg.sender);
            if (oldDistBal > 0) {
                oldDist.withdrawReward(msg.sender); 
                oldDist.burnFrom(msg.sender, oldDistBal);
            }
        }
        
        TimelockRewardDistributionTokenImpl newDist = _rewardDistributionTokenAddr(pool);
        if (!isContract(address(newDist))) {
            address deployedDist = _deployDividendToken(pool);
            require(deployedDist == address(newDist), "Not deploying proper distro");
            emit PoolUpdated(vaultId, deployedDist);
        }
        require(unusedDistBal + oldDistBal > 0, "Nothing to migrate");
        newDist.mint(msg.sender, unusedDistBal + oldDistBal);
    }

    function withdraw(uint256 vaultId, uint256 amount) external {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        _claimRewards(pool, msg.sender);
        _withdraw(pool, amount, msg.sender);
    }

    function claimRewards(uint256 vaultId) public {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        _claimRewards(pool, msg.sender);
    }

    function claimMultipleRewards(uint256[] calldata vaultIds) external {

        uint256 length = vaultIds.length;
        for (uint256 i; i < length; ++i) {
            claimRewards(vaultIds[i]);
        }
    }

    function newRewardDistributionToken(uint256 vaultId) external view returns (TimelockRewardDistributionTokenImpl) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        if (pool.stakingToken == address(0)) {
            return TimelockRewardDistributionTokenImpl(address(0));
        }
        return _rewardDistributionTokenAddr(pool);
    }

   function rewardDistributionToken(uint256 vaultId) external view returns (IRewardDistributionToken) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        if (pool.stakingToken == address(0)) {
            return IRewardDistributionToken(address(0));
        }
        return _unusedRewardDistributionTokenAddr(pool);
    }

    function oldRewardDistributionToken(uint256 vaultId) external view returns (address) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        if (pool.stakingToken == address(0)) {
            return address(0);
        }
        return address(_oldRewardDistributionTokenAddr(pool));
    }

    function unusedRewardDistributionToken(uint256 vaultId) external view returns (address) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        if (pool.stakingToken == address(0)) {
            return address(0);
        }
        return address(_unusedRewardDistributionTokenAddr(pool));
    }

    function rewardDistributionTokenAddr(address stakedToken, address rewardToken) public view returns (address) {

        StakingPool memory pool = StakingPool(stakedToken, rewardToken);
        return address(_rewardDistributionTokenAddr(pool));
    }

    function balanceOf(uint256 vaultId, address addr) public view returns (uint256) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        TimelockRewardDistributionTokenImpl dist = _rewardDistributionTokenAddr(pool);
        require(isContract(address(dist)), "Not a pool");
        return dist.balanceOf(addr);
    }

    function oldBalanceOf(uint256 vaultId, address addr) public view returns (uint256) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        IRewardDistributionToken dist = _oldRewardDistributionTokenAddr(pool);
        require(isContract(address(dist)), "Not a pool");
        return dist.balanceOf(addr);
    }

    function unusedBalanceOf(uint256 vaultId, address addr) public view returns (uint256) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        IRewardDistributionToken dist = _unusedRewardDistributionTokenAddr(pool);
        require(isContract(address(dist)), "Not a pool");
        return dist.balanceOf(addr);
    }

    function lockedUntil(uint256 vaultId, address who) external view returns (uint256) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        TimelockRewardDistributionTokenImpl dist = _rewardDistributionTokenAddr(pool);
        return dist.timelockUntil(who);
    }

    function lockedLPBalance(uint256 vaultId, address who) external view returns (uint256) {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        TimelockRewardDistributionTokenImpl dist = _rewardDistributionTokenAddr(pool);
        if(block.timestamp > dist.timelockUntil(who)) {
            return 0;
        }
        return dist.balanceOf(who);
    }

    function _claimRewards(StakingPool memory pool, address account) internal {

        require(pool.stakingToken != address(0), "LPStaking: Nonexistent pool");
        _rewardDistributionTokenAddr(pool).withdrawReward(account);
    }

    function _withdraw(StakingPool memory pool, uint256 amount, address account) internal {

        require(pool.stakingToken != address(0), "LPStaking: Nonexistent pool");
        _rewardDistributionTokenAddr(pool).burnFrom(account, amount);
        IERC20Upgradeable(pool.stakingToken).safeTransfer(account, amount);
    }

    function _deployDividendToken(StakingPool memory pool) internal returns (address) {

        bytes32 salt = keccak256(abi.encodePacked(pool.stakingToken, pool.rewardToken, uint256(2)));
        address rewardDistToken = ClonesUpgradeable.cloneDeterministic(address(newTimelockRewardDistTokenImpl), salt);
        string memory name = stakingTokenProvider.nameForStakingToken(pool.rewardToken);
        TimelockRewardDistributionTokenImpl(rewardDistToken).__TimelockRewardDistributionToken_init(IERC20Upgradeable(pool.rewardToken), name, name);
        return rewardDistToken;
    }

    function _rewardDistributionTokenAddr(StakingPool memory pool) public view returns (TimelockRewardDistributionTokenImpl) {

        bytes32 salt = keccak256(abi.encodePacked(pool.stakingToken, pool.rewardToken, uint256(2) /* small nonce to change tokens */));
        address tokenAddr = ClonesUpgradeable.predictDeterministicAddress(address(newTimelockRewardDistTokenImpl), salt);
        return TimelockRewardDistributionTokenImpl(tokenAddr);
    }

    function _oldRewardDistributionTokenAddr(StakingPool memory pool) public view returns (IRewardDistributionToken) {

        bytes32 salt = keccak256(abi.encodePacked(pool.stakingToken, pool.rewardToken, uint256(1)));
        address tokenAddr = ClonesUpgradeable.predictDeterministicAddress(address(rewardDistTokenImpl), salt);
        return IRewardDistributionToken(tokenAddr);
    }

    function _unusedRewardDistributionTokenAddr(StakingPool memory pool) public view returns (IRewardDistributionToken) {

        bytes32 salt = keccak256(abi.encodePacked(pool.stakingToken, pool.rewardToken));
        address tokenAddr = ClonesUpgradeable.predictDeterministicAddress(address(rewardDistTokenImpl), salt);
        return IRewardDistributionToken(tokenAddr);
    }

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function retrieveTokens(uint256 vaultId, uint256 amount, address from, address to) public onlyOwner {

        StakingPool memory pool = vaultStakingInfo[vaultId];
        TimelockRewardDistributionTokenImpl xSlp = _rewardDistributionTokenAddr(pool);
        xSlp.burnFrom(from, amount);
        xSlp.mint(to, amount);
    }
}