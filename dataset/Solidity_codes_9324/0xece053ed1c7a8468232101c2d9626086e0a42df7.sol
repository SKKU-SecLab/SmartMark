



pragma solidity ^0.8.0;

interface INFTXLPStaking {

    function nftxVaultFactory() external view returns (address);

    function rewardDistTokenImpl() external view returns (address);

    function stakingTokenProvider() external view returns (address);

    function vaultToken(address _stakingToken) external view returns (address);

    function stakingToken(address _vaultToken) external view returns (address);

    function rewardDistributionToken(uint256 vaultId) external view returns (address);


    function __NFTXLPStaking__init(address _stakingTokenProvider) external;

    function setNFTXVaultFactory(address newFactory) external;

    function setStakingTokenProvider(address newProvider) external;

    function addPoolForVault(uint256 vaultId) external;

    function receiveRewards(uint256 vaultId, uint256 amount) external returns (bool);

    function deposit(uint256 vaultId, uint256 amount) external;

    function exit(uint256 vaultId, uint256 amount) external;

    function rescue(uint256 vaultId) external;

    function withdraw(uint256 vaultId, uint256 amount) external;

    function claimRewards(uint256 vaultId) external;

}





pragma solidity ^0.8.0;

interface INFTXFeeDistributor {

  
  struct FeeReceiver {
    uint256 allocPoint;
    address receiver;
    bool isContract;
  }

  function nftxVaultFactory() external returns (address);

  function lpStaking() external returns (address);

  function treasury() external returns (address);

  function defaultTreasuryAlloc() external returns (uint256);

  function defaultLPAlloc() external returns (uint256);

  function allocTotal(uint256 vaultId) external returns (uint256);

  function specificTreasuryAlloc(uint256 vaultId) external returns (uint256);


  function __FeeDistributor__init__(address _lpStaking, address _treasury) external;

  function rescueTokens(address token) external;

  function distribute(uint256 vaultId) external;

  function addReceiver(uint256 _vaultId, uint256 _allocPoint, address _receiver, bool _isContract) external;

  function initializeVaultReceivers(uint256 _vaultId) external;

  function changeMultipleReceiverAlloc(
    uint256[] memory _vaultIds, 
    uint256[] memory _receiverIdxs, 
    uint256[] memory allocPoints
  ) external;


  function changeMultipleReceiverAddress(
    uint256[] memory _vaultIds, 
    uint256[] memory _receiverIdxs, 
    address[] memory addresses, 
    bool[] memory isContracts
  ) external;

  function changeReceiverAlloc(uint256 _vaultId, uint256 _idx, uint256 _allocPoint) external;

  function changeReceiverAddress(uint256 _vaultId, uint256 _idx, address _address, bool _isContract) external;

  function removeReceiver(uint256 _vaultId, uint256 _receiverIdx) external;


  function setTreasuryAddress(address _treasury) external;

  function setDefaultTreasuryAlloc(uint256 _allocPoint) external;

  function setSpecificTreasuryAlloc(uint256 _vaultId, uint256 _allocPoint) external;

  function setLPStakingAddress(address _lpStaking) external;

  function setNFTXVaultFactory(address _factory) external;

  function setDefaultLPAlloc(uint256 _allocPoint) external;

}





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

  function vaultsForAsset(address asset) external view returns (address[] memory);

  function isLocked(uint256 id) external view returns (bool);


  event NewFeeDistributor(address oldDistributor, address newDistributor);
  event NewZapContract(address oldZap, address newZap);
  event NewEligibilityManager(address oldEligManager, address newEligManager);
  event NewVault(uint256 indexed vaultId, address vaultAddress, address assetAddress);

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
}





pragma solidity ^0.8.0;








contract NFTXFeeDistributor is INFTXFeeDistributor, ReentrancyGuardUpgradeable, PausableUpgradeable {

  using SafeERC20Upgradeable for IERC20Upgradeable;

  bool public distributionPaused;

  address public override nftxVaultFactory;
  address public override lpStaking;
  address public override treasury;
  uint256 private constant threshold = 10**9;
  uint256 public override defaultTreasuryAlloc;
  uint256 public override defaultLPAlloc;

  mapping(uint256 => uint256) public override allocTotal;
  mapping(uint256 => uint256) public override specificTreasuryAlloc;
  mapping(uint256 => FeeReceiver[]) feeReceivers;

  event UpdateDefaultLPAlloc(uint256 newLPAlloc);
  event UpdateDefaultTreasuryAlloc(uint256 newTreasuryAlloc);
  event UpdateSpecificTreasuryAlloc(uint256 vaultId, uint256 newSpecificAlloc);

  event UpdateTreasuryAddress(address newTreasury);
  event UpdateLPStakingAddress(address newLPStaking);
  event UpdateNFTXVaultFactory(address factory);
  event PauseDistribution(bool paused); 

  event AddFeeReceiver(uint256 vaultId, address receiver, uint256 allocPoint);
  event UpdateFeeReceiverAlloc(uint256 vaultId, address receiver, uint256 allocPoint);
  event UpdateFeeReceiverAddress(uint256 vaultId, address oldReceiver, address newReceiver);
  event RemoveFeeReceiver(uint256 vaultId, address receiver);
  
  function __FeeDistributor__init__(address _lpStaking, address _treasury) public override initializer {

    __Pausable_init();
    setTreasuryAddress(_treasury);
    setDefaultTreasuryAlloc(0);
    setLPStakingAddress(_lpStaking);
    setDefaultLPAlloc(0.5 ether);
  }

  function distribute(uint256 vaultId) external override virtual nonReentrant {

    require(nftxVaultFactory != address(0));
    address _vault = INFTXVaultFactory(nftxVaultFactory).vault(vaultId);

    uint256 tokenBalance = IERC20Upgradeable(_vault).balanceOf(address(this));

    if (distributionPaused) {
      IERC20Upgradeable(_vault).safeTransfer(treasury, tokenBalance);
      return;
    } 

    if (tokenBalance <= threshold) {
      return;
    }
    tokenBalance -= 1000;
    
    uint256 _treasuryAlloc = specificTreasuryAlloc[vaultId];
    if (_treasuryAlloc == 0) {
      _treasuryAlloc = defaultTreasuryAlloc;
    }

    uint256 _allocTotal = allocTotal[vaultId] + _treasuryAlloc;
    uint256 amountToSend = tokenBalance * _treasuryAlloc / _allocTotal;
    amountToSend = amountToSend > tokenBalance ? tokenBalance : amountToSend;
    IERC20Upgradeable(_vault).safeTransfer(treasury, amountToSend);

    FeeReceiver[] memory _feeReceivers = feeReceivers[vaultId];
    for (uint256 i = 0; i < _feeReceivers.length; i++) {
      _sendForReceiver(_feeReceivers[i], vaultId, _vault, tokenBalance, _allocTotal);
    } 
  }

  function addReceiver(uint256 _vaultId, uint256 _allocPoint, address _receiver, bool _isContract) external override virtual onlyOwner  {

    _addReceiver(_vaultId, _allocPoint, _receiver, _isContract);
  }

  function initializeVaultReceivers(uint256 _vaultId) external override {

    require(msg.sender == nftxVaultFactory, "FeeReceiver: not factory");
    _addReceiver(_vaultId, defaultLPAlloc, lpStaking, true);
    INFTXLPStaking(lpStaking).addPoolForVault(_vaultId);
  }

  function changeMultipleReceiverAlloc(
    uint256[] memory _vaultIds, 
    uint256[] memory _receiverIdxs, 
    uint256[] memory allocPoints
  ) public override virtual onlyOwner {

    require(_vaultIds.length == _receiverIdxs.length, "Lengths not equal");
    require(allocPoints.length == _receiverIdxs.length, "Lengths not equal");
    for (uint256 i = 0; i < _vaultIds.length; i++) {
      changeReceiverAlloc(_vaultIds[i], _receiverIdxs[i], allocPoints[i]);
    }
  }

  function changeReceiverAlloc(uint256 _vaultId, uint256 _receiverIdx, uint256 _allocPoint) public override virtual onlyOwner {

    FeeReceiver storage feeReceiver = feeReceivers[_vaultId][_receiverIdx];
    allocTotal[_vaultId] -= feeReceiver.allocPoint;
    feeReceiver.allocPoint = _allocPoint;
    allocTotal[_vaultId] += _allocPoint;
    emit UpdateFeeReceiverAlloc(_vaultId, feeReceiver.receiver, _allocPoint);
  }

  function changeMultipleReceiverAddress(
    uint256[] memory _vaultIds, 
    uint256[] memory _receiverIdxs, 
    address[] memory addresses, 
    bool[] memory isContracts
  ) public override virtual onlyOwner {

    require(_vaultIds.length == _receiverIdxs.length, "Lengths not equal");
    require(addresses.length == _receiverIdxs.length, "Lengths not equal");
    require(addresses.length == isContracts.length, "Lengths not equal");
    for (uint256 i = 0; i < _vaultIds.length; i++) {
      changeReceiverAddress(_vaultIds[i], _receiverIdxs[i], addresses[i], isContracts[i]);
    }
  }

  function changeReceiverAddress(uint256 _vaultId, uint256 _receiverIdx, address _address, bool _isContract) public override virtual onlyOwner {

    FeeReceiver storage feeReceiver = feeReceivers[_vaultId][_receiverIdx];
    address oldReceiver = feeReceiver.receiver;
    feeReceiver.receiver = _address;
    feeReceiver.isContract = _isContract;
    emit UpdateFeeReceiverAddress(_vaultId, oldReceiver, _address);
  }

  function removeReceiver(uint256 _vaultId, uint256 _receiverIdx) external override virtual onlyOwner {

    FeeReceiver[] storage feeReceiversForVault = feeReceivers[_vaultId];
    uint256 arrLength = feeReceiversForVault.length;
    require(_receiverIdx < arrLength, "FeeDistributor: Out of bounds");
    emit RemoveFeeReceiver(_vaultId, feeReceiversForVault[_receiverIdx].receiver);
    allocTotal[_vaultId] -= feeReceiversForVault[_receiverIdx].allocPoint;
    feeReceiversForVault[_receiverIdx] = feeReceiversForVault[arrLength-1];
    feeReceiversForVault.pop();
  }

  function setTreasuryAddress(address _treasury) public override onlyOwner {

    require(_treasury != address(0), "Treasury != address(0)");
    treasury = _treasury;
    emit UpdateTreasuryAddress(_treasury);
  }

  function setDefaultTreasuryAlloc(uint256 _allocPoint) public override onlyOwner {

    defaultTreasuryAlloc = _allocPoint;
    emit UpdateDefaultTreasuryAlloc(_allocPoint);
  }

  function setSpecificTreasuryAlloc(uint256 vaultId, uint256 _allocPoint) external override onlyOwner {

    specificTreasuryAlloc[vaultId] = _allocPoint;
    emit UpdateSpecificTreasuryAlloc(vaultId, _allocPoint);
  }

  function setLPStakingAddress(address _lpStaking) public override onlyOwner {

    require(_lpStaking != address(0), "LPStaking != address(0)");
    lpStaking = _lpStaking;
    emit UpdateLPStakingAddress(_lpStaking);
  }

  function setDefaultLPAlloc(uint256 _allocPoint) public override onlyOwner {

    defaultLPAlloc = _allocPoint;
    emit UpdateDefaultLPAlloc(_allocPoint);
  }

  function setNFTXVaultFactory(address _factory) external override onlyOwner {

    nftxVaultFactory = _factory;
    emit UpdateNFTXVaultFactory(_factory);
  }

  function pauseFeeDistribution(bool pause) external onlyOwner {

    distributionPaused = pause;
    emit PauseDistribution(pause);
  }

  function rescueTokens(address _address) external override onlyOwner {

    uint256 balance = IERC20Upgradeable(_address).balanceOf(address(this));
    IERC20Upgradeable(_address).safeTransfer(msg.sender, balance);
  }

  function _addReceiver(uint256 _vaultId, uint256 _allocPoint, address _receiver, bool _isContract) internal virtual {

    allocTotal[_vaultId] += _allocPoint;
    FeeReceiver memory _feeReceiver = FeeReceiver(_allocPoint, _receiver, _isContract);
    feeReceivers[_vaultId].push(_feeReceiver);
    emit AddFeeReceiver(_vaultId, _receiver, _allocPoint);
  }

  function _sendForReceiver(FeeReceiver memory _receiver, uint256 _vaultId, address _vault, uint256 _tokenBalance, uint256 _allocTotal) internal virtual {

    uint256 amountToSend = _tokenBalance * _receiver.allocPoint / _allocTotal;
    uint256 balance = IERC20Upgradeable(_vault).balanceOf(address(this)) - 1000;
    amountToSend = amountToSend > balance ? balance : amountToSend;

    if (_receiver.isContract) {
      IERC20Upgradeable(_vault).approve(_receiver.receiver, amountToSend);
       
      bytes memory payload = abi.encodeWithSelector(INFTXLPStaking.receiveRewards.selector, _vaultId, amountToSend);
      (bool success, ) = address(_receiver.receiver).call(payload);

      if (!success || IERC20Upgradeable(_vault).allowance(address(this), _receiver.receiver) > 0) {
        IERC20Upgradeable(_vault).safeTransfer(treasury, amountToSend);
        IERC20Upgradeable(_vault).approve(_receiver.receiver, 0);
      }
    } else {
      IERC20Upgradeable(_vault).safeTransfer(_receiver.receiver, amountToSend);
    }
  }
}