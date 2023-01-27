



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

interface INFTXLPStaking {

    function nftxVaultFactory() external view returns (address);

    function rewardDistTokenImpl() external view returns (address);

    function stakingTokenProvider() external view returns (address);

    function vaultToken(address _stakingToken) external view returns (address);

    function stakingToken(address _vaultToken) external view returns (address);

    function rewardDistributionToken(uint256 vaultId) external view returns (address);

    function newRewardDistributionToken(uint256 vaultId) external view returns (address);

    function oldRewardDistributionToken(uint256 vaultId) external view returns (address);

    function unusedRewardDistributionToken(uint256 vaultId) external view returns (address);

    function rewardDistributionTokenAddr(address stakingToken, address rewardToken) external view returns (address);

    
    function __NFTXLPStaking__init(address _stakingTokenProvider) external;

    function setNFTXVaultFactory(address newFactory) external;

    function setStakingTokenProvider(address newProvider) external;

    function addPoolForVault(uint256 vaultId) external;

    function updatePoolForVault(uint256 vaultId) external;

    function updatePoolForVaults(uint256[] calldata vaultId) external;

    function receiveRewards(uint256 vaultId, uint256 amount) external returns (bool);

    function deposit(uint256 vaultId, uint256 amount) external;

    function timelockDepositFor(uint256 vaultId, address account, uint256 amount, uint256 timelockLength) external;

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

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
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



contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_beacon()).childImplementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).childImplementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
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



contract UpgradeableBeacon is IBeacon, OwnableUpgradeable {

    address private _childImplementation;

    event Upgraded(address indexed childImplementation);

    function __UpgradeableBeacon__init(address childImplementation_) public initializer {

        _setChildImplementation(childImplementation_);
    }

    function childImplementation() public view virtual override returns (address) {

        return _childImplementation;
    }

    function upgradeChildTo(address newChildImplementation) public virtual override onlyOwner {

        _setChildImplementation(newChildImplementation);
    }

    function _setChildImplementation(address newChildImplementation) private {

        require(Address.isContract(newChildImplementation), "UpgradeableBeacon: child implementation is not a contract");
        _childImplementation = newChildImplementation;
        emit Upgraded(newChildImplementation);
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

interface INFTXEligibility {

    function name() external pure returns (string memory);

    function finalized() external view returns (bool);

    function targetAsset() external pure returns (address);

    function checkAllEligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

    function checkEligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool[] memory);

    function checkAllIneligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

    function checkIsEligible(uint256 tokenId) external view returns (bool);


    function __NFTXEligibility_init_bytes(bytes calldata configData) external;

    function beforeMintHook(uint256[] calldata tokenIds) external;

    function afterMintHook(uint256[] calldata tokenIds) external;

    function beforeRedeemHook(uint256[] calldata tokenIds) external;

    function afterRedeemHook(uint256[] calldata tokenIds) external;

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



interface INFTXVault is IERC20Upgradeable {

    function manager() external view returns (address);

    function assetAddress() external view returns (address);

    function vaultFactory() external view returns (INFTXVaultFactory);

    function eligibilityStorage() external view returns (INFTXEligibility);


    function is1155() external view returns (bool);

    function allowAllItems() external view returns (bool);

    function enableMint() external view returns (bool);

    function enableRandomRedeem() external view returns (bool);

    function enableTargetRedeem() external view returns (bool);

    function enableRandomSwap() external view returns (bool);

    function enableTargetSwap() external view returns (bool);


    function vaultId() external view returns (uint256);

    function nftIdAt(uint256 holdingsIndex) external view returns (uint256);

    function allHoldings() external view returns (uint256[] memory);

    function totalHoldings() external view returns (uint256);

    function mintFee() external view returns (uint256);

    function randomRedeemFee() external view returns (uint256);

    function targetRedeemFee() external view returns (uint256);

    function randomSwapFee() external view returns (uint256);

    function targetSwapFee() external view returns (uint256);

    function vaultFees() external view returns (uint256, uint256, uint256, uint256, uint256);


    event VaultInit(
        uint256 indexed vaultId,
        address assetAddress,
        bool is1155,
        bool allowAllItems
    );

    event ManagerSet(address manager);
    event EligibilityDeployed(uint256 moduleIndex, address eligibilityAddr);

    event EnableMintUpdated(bool enabled);
    event EnableRandomRedeemUpdated(bool enabled);
    event EnableTargetRedeemUpdated(bool enabled);
    event EnableRandomSwapUpdated(bool enabled);
    event EnableTargetSwapUpdated(bool enabled);

    event Minted(uint256[] nftIds, uint256[] amounts, address to);
    event Redeemed(uint256[] nftIds, uint256[] specificIds, address to);
    event Swapped(
        uint256[] nftIds,
        uint256[] amounts,
        uint256[] specificIds,
        uint256[] redeemedIds,
        address to
    );

    function __NFTXVault_init(
        string calldata _name,
        string calldata _symbol,
        address _assetAddress,
        bool _is1155,
        bool _allowAllItems
    ) external;


    function finalizeVault() external;


    function setVaultMetadata(
        string memory name_, 
        string memory symbol_
    ) external;


    function setVaultFeatures(
        bool _enableMint,
        bool _enableRandomRedeem,
        bool _enableTargetRedeem,
        bool _enableRandomSwap,
        bool _enableTargetSwap
    ) external;


    function setFees(
        uint256 _mintFee,
        uint256 _randomRedeemFee,
        uint256 _targetRedeemFee,
        uint256 _randomSwapFee,
        uint256 _targetSwapFee
    ) external;

    function disableVaultFees() external;


    function deployEligibilityStorage(
        uint256 moduleIndex,
        bytes calldata initData
    ) external returns (address);


    function setManager(address _manager) external;


    function mint(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts /* ignored for ERC721 vaults */
    ) external returns (uint256);


    function mintTo(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts, /* ignored for ERC721 vaults */
        address to
    ) external returns (uint256);


    function redeem(uint256 amount, uint256[] calldata specificIds)
        external
        returns (uint256[] calldata);


    function redeemTo(
        uint256 amount,
        uint256[] calldata specificIds,
        address to
    ) external returns (uint256[] calldata);


    function swap(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts, /* ignored for ERC721 vaults */
        uint256[] calldata specificIds
    ) external returns (uint256[] calldata);


    function swapTo(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts, /* ignored for ERC721 vaults */
        uint256[] calldata specificIds,
        address to
    ) external returns (uint256[] calldata);


    function allValidNFTs(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

}





pragma solidity ^0.8.0;

interface INFTXEligibilityManager {

    function nftxVaultFactory() external returns (address);

    function eligibilityImpl() external returns (address);


    function deployEligibility(uint256 vaultId, bytes calldata initData)
        external
        returns (address);

}





pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity ^0.8.0;

interface IERC3156FlashBorrowerUpgradeable {

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}

interface IERC3156FlashLenderUpgradeable {

    function maxFlashLoan(
        address token
    ) external view returns (uint256);


    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);


    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

 }





pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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



abstract contract ERC20FlashMintUpgradeable is Initializable, ERC20Upgradeable, IERC3156FlashLenderUpgradeable {
    function __ERC20FlashMint_init() internal initializer {
        __Context_init_unchained();
        __ERC20FlashMint_init_unchained();
    }

    function __ERC20FlashMint_init_unchained() internal initializer {
    }
    bytes32 constant private RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");

    function maxFlashLoan(address token) public view override returns (uint256) {
        return token == address(this) ? type(uint256).max - totalSupply() : 0;
    }

    function flashFee(address token, uint256 amount) public view virtual override returns (uint256) {
        require(token == address(this), "ERC20FlashMint: wrong token");
        amount;
        return 0;
    }

    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes memory data
    )
        public virtual override returns (bool)
    {
        uint256 fee = flashFee(token, amount);
        _mint(address(receiver), amount);
        require(receiver.onFlashLoan(msg.sender, token, amount, fee, data) == RETURN_VALUE, "ERC20FlashMint: invalid return value");
        uint256 currentAllowance = allowance(address(receiver), address(this));
        require(currentAllowance >= amount + fee, "ERC20FlashMint: allowance does not allow refund");
        _approve(address(receiver), address(this), currentAllowance - amount - fee);
        _burn(address(receiver), amount + fee);
        return true;
    }
    uint256[50] private __gap;
}





pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}





pragma solidity ^0.8.0;

contract ERC721SafeHolderUpgradeable is IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}





pragma solidity ^0.8.0;

interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}





pragma solidity ^0.8.0;

abstract contract ERC165Upgradeable is IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
}





pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }
}





pragma solidity ^0.8.0;

abstract contract ERC1155SafeHolderUpgradeable is ERC1155ReceiverUpgradeable {
    function onERC1155Received(address operator, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address operator, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}





pragma solidity ^0.8.0;

interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}





pragma solidity ^0.8.0;

interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

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

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}





pragma solidity ^0.8.0;
















contract NFTXVaultUpgradeable is
    OwnableUpgradeable,
    ERC20FlashMintUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721SafeHolderUpgradeable,
    ERC1155SafeHolderUpgradeable,
    INFTXVault
{

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    uint256 constant base = 10**18;

    uint256 public override vaultId;
    address public override manager;
    address public override assetAddress;
    INFTXVaultFactory public override vaultFactory;
    INFTXEligibility public override eligibilityStorage;

    uint256 randNonce;
    uint256 private UNUSED_FEE1;
    uint256 private UNUSED_FEE2;
    uint256 private UNUSED_FEE3;

    bool public override is1155;
    bool public override allowAllItems;
    bool public override enableMint;
    bool public override enableRandomRedeem;
    bool public override enableTargetRedeem;

    EnumerableSetUpgradeable.UintSet holdings;
    mapping(uint256 => uint256) quantity1155;

    bool public override enableRandomSwap;
    bool public override enableTargetSwap;

    function __NFTXVault_init(
        string memory _name,
        string memory _symbol,
        address _assetAddress,
        bool _is1155,
        bool _allowAllItems
    ) public override virtual initializer {

        __Ownable_init();
        __ERC20_init(_name, _symbol);
        require(_assetAddress != address(0), "Asset != address(0)");
        assetAddress = _assetAddress;
        vaultFactory = INFTXVaultFactory(msg.sender);
        vaultId = vaultFactory.numVaults();
        is1155 = _is1155;
        allowAllItems = _allowAllItems;
        emit VaultInit(vaultId, _assetAddress, _is1155, _allowAllItems);
        setVaultFeatures(true /*enableMint*/, true /*enableRandomRedeem*/, true /*enableTargetRedeem*/, true /*enableRandomSwap*/, true /*enableTargetSwap*/);
    }

    function finalizeVault() external override virtual {

        setManager(address(0));
    }

    function setVaultMetadata(
        string memory name_, 
        string memory symbol_
    ) public override virtual {

        onlyPrivileged();
        _setMetadata(name_, symbol_);
    }

    function setVaultFeatures(
        bool _enableMint,
        bool _enableRandomRedeem,
        bool _enableTargetRedeem,
        bool _enableRandomSwap,
        bool _enableTargetSwap
    ) public override virtual {

        onlyPrivileged();
        enableMint = _enableMint;
        enableRandomRedeem = _enableRandomRedeem;
        enableTargetRedeem = _enableTargetRedeem;
        enableRandomSwap = _enableRandomSwap;
        enableTargetSwap = _enableTargetSwap;

        emit EnableMintUpdated(_enableMint);
        emit EnableRandomRedeemUpdated(_enableRandomRedeem);
        emit EnableTargetRedeemUpdated(_enableTargetRedeem);
        emit EnableRandomSwapUpdated(_enableRandomSwap);
        emit EnableTargetSwapUpdated(_enableTargetSwap);
    }

    function assignDefaultFeatures() external {

        require(msg.sender == 0xDEA9196Dcdd2173D6E369c2AcC0faCc83fD9346a, "Not dev");
        enableRandomSwap = enableRandomRedeem;
        enableTargetSwap = enableTargetRedeem;
        emit EnableRandomSwapUpdated(enableRandomSwap);
        emit EnableTargetSwapUpdated(enableTargetSwap);
    }

    function setFees(
        uint256 _mintFee,
        uint256 _randomRedeemFee,
        uint256 _targetRedeemFee,
        uint256 _randomSwapFee,
        uint256 _targetSwapFee
    ) public override virtual {

        onlyPrivileged();
        vaultFactory.setVaultFees(vaultId, _mintFee, _randomRedeemFee, _targetRedeemFee, _randomSwapFee, _targetSwapFee);
    }

    function disableVaultFees() public override virtual {

        onlyPrivileged();
        vaultFactory.disableVaultFees(vaultId);
    }

    function deployEligibilityStorage(
        uint256 moduleIndex,
        bytes calldata initData
    ) external override virtual returns (address) {

        onlyPrivileged();
        require(
            address(eligibilityStorage) == address(0),
            "NFTXVault: eligibility already set"
        );
        INFTXEligibilityManager eligManager = INFTXEligibilityManager(
            vaultFactory.eligibilityManager()
        );
        address _eligibility = eligManager.deployEligibility(
            moduleIndex,
            initData
        );
        eligibilityStorage = INFTXEligibility(_eligibility);
        allowAllItems = false;
        emit EligibilityDeployed(moduleIndex, _eligibility);
        return _eligibility;
    }


    function setManager(address _manager) public override virtual {

        onlyPrivileged();
        manager = _manager;
        emit ManagerSet(_manager);
    }

    function mint(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts /* ignored for ERC721 vaults */
    ) external override virtual returns (uint256) {

        return mintTo(tokenIds, amounts, msg.sender);
    }

    function mintTo(
        uint256[] memory tokenIds,
        uint256[] memory amounts, /* ignored for ERC721 vaults */
        address to
    ) public override virtual nonReentrant returns (uint256) {

        onlyOwnerIfPaused(1);
        require(enableMint, "Minting not enabled");
        uint256 count = receiveNFTs(tokenIds, amounts);

        _mint(to, base * count);
        uint256 totalFee = mintFee() * count;
        _chargeAndDistributeFees(to, totalFee);

        emit Minted(tokenIds, amounts, to);
        return count;
    }

    function redeem(uint256 amount, uint256[] calldata specificIds)
        external
        override
        virtual
        returns (uint256[] memory)
    {

        return redeemTo(amount, specificIds, msg.sender);
    }

    function redeemTo(uint256 amount, uint256[] memory specificIds, address to)
        public
        override
        virtual
        nonReentrant
        returns (uint256[] memory)
    {

        onlyOwnerIfPaused(2);
        require(
            amount == specificIds.length || enableRandomRedeem,
            "NFTXVault: Random redeem not enabled"
        );
        require(
            specificIds.length == 0 || enableTargetRedeem,
            "NFTXVault: Target redeem not enabled"
        );
        
        _burn(msg.sender, base * amount);

        uint256 totalFee = (targetRedeemFee() * specificIds.length) + (
            randomRedeemFee() * (amount - specificIds.length)
        );
        _chargeAndDistributeFees(msg.sender, totalFee);

        uint256[] memory redeemedIds = withdrawNFTsTo(amount, specificIds, to);
        emit Redeemed(redeemedIds, specificIds, to);
        return redeemedIds;
    }
    
    function swap(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts, /* ignored for ERC721 vaults */
        uint256[] calldata specificIds
    ) external override virtual returns (uint256[] memory) {

        return swapTo(tokenIds, amounts, specificIds, msg.sender);
    }

    function swapTo(
        uint256[] memory tokenIds,
        uint256[] memory amounts, /* ignored for ERC721 vaults */
        uint256[] memory specificIds,
        address to
    ) public override virtual nonReentrant returns (uint256[] memory) {

        onlyOwnerIfPaused(3);
        uint256 count;
        if (is1155) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 amount = amounts[i];
                require(amount > 0, "NFTXVault: transferring < 1");
                count += amount;
            }
        } else {
            count = tokenIds.length;
        }

        require(
            count == specificIds.length || enableRandomSwap,
            "NFTXVault: Random swap disabled"
        );
        require(
            specificIds.length == 0 || enableTargetSwap,
            "NFTXVault: Target swap disabled"
        );

        uint256 totalFee = (targetSwapFee() * specificIds.length) + (
            randomSwapFee() * (count - specificIds.length)
        );
        _chargeAndDistributeFees(msg.sender, totalFee);
        
        uint256[] memory ids = withdrawNFTsTo(count, specificIds, to);

        receiveNFTs(tokenIds, amounts);

        emit Swapped(tokenIds, amounts, specificIds, ids, to);
        return ids;
    }

    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes memory data
    ) public override virtual returns (bool) {

        onlyOwnerIfPaused(4);
        return super.flashLoan(receiver, token, amount, data);
    }

    function mintFee() public view override virtual returns (uint256) {

        (uint256 _mintFee, , , ,) = vaultFactory.vaultFees(vaultId);
        return _mintFee;
    }

    function randomRedeemFee() public view override virtual returns (uint256) {

        (, uint256 _randomRedeemFee, , ,) = vaultFactory.vaultFees(vaultId);
        return _randomRedeemFee;
    }

    function targetRedeemFee() public view override virtual returns (uint256) {

        (, , uint256 _targetRedeemFee, ,) = vaultFactory.vaultFees(vaultId);
        return _targetRedeemFee;
    }

    function randomSwapFee() public view override virtual returns (uint256) {

        (, , , uint256 _randomSwapFee, ) = vaultFactory.vaultFees(vaultId);
        return _randomSwapFee;
    }

    function targetSwapFee() public view override virtual returns (uint256) {

        (, , , ,uint256 _targetSwapFee) = vaultFactory.vaultFees(vaultId);
        return _targetSwapFee;
    }

    function vaultFees() public view override virtual returns (uint256, uint256, uint256, uint256, uint256) {

        return vaultFactory.vaultFees(vaultId);
    }

    function allValidNFTs(uint256[] memory tokenIds)
        public
        view
        override
        virtual
        returns (bool)
    {

        if (allowAllItems) {
            return true;
        }

        INFTXEligibility _eligibilityStorage = eligibilityStorage;
        if (address(_eligibilityStorage) == address(0)) {
            return false;
        }
        return _eligibilityStorage.checkAllEligible(tokenIds);
    }

    function nftIdAt(uint256 holdingsIndex) external view override virtual returns (uint256) {

        return holdings.at(holdingsIndex);
    }

    function allHoldings() external view override virtual returns (uint256[] memory) {

        uint256 len = holdings.length();
        uint256[] memory idArray = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            idArray[i] = holdings.at(i);
        }
        return idArray;
    }

    function totalHoldings() external view override virtual returns (uint256) {

        return holdings.length();
    }

    function version() external pure returns (string memory) {

        return "v1.0.5";
    } 

    function afterRedeemHook(uint256[] memory tokenIds) internal virtual {

        INFTXEligibility _eligibilityStorage = eligibilityStorage;
        if (address(_eligibilityStorage) == address(0)) {
            return;
        }
        _eligibilityStorage.afterRedeemHook(tokenIds);
    }

    function receiveNFTs(uint256[] memory tokenIds, uint256[] memory amounts)
        internal
        virtual
        returns (uint256)
    {

        require(allValidNFTs(tokenIds), "NFTXVault: not eligible");
        if (is1155) {
            IERC1155Upgradeable(assetAddress).safeBatchTransferFrom(
                msg.sender,
                address(this),
                tokenIds,
                amounts,
                ""
            );

            uint256 count;
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenId = tokenIds[i];
                uint256 amount = amounts[i];
                require(amount > 0, "NFTXVault: transferring < 1");
                if (quantity1155[tokenId] == 0) {
                    holdings.add(tokenId);
                }
                quantity1155[tokenId] += amount;
                count += amount;
            }
            return count;
        } else {
            address _assetAddress = assetAddress;
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenId = tokenIds[i];
                transferFromERC721(_assetAddress, tokenId);
                holdings.add(tokenId);
            }
            return tokenIds.length;
        }
    }

    function withdrawNFTsTo(
        uint256 amount,
        uint256[] memory specificIds,
        address to
    ) internal virtual returns (uint256[] memory) {

        bool _is1155 = is1155;
        address _assetAddress = assetAddress;
        uint256[] memory redeemedIds = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = i < specificIds.length ? 
                specificIds[i] : getRandomTokenIdFromVault();
            redeemedIds[i] = tokenId;

            if (_is1155) {
                quantity1155[tokenId] -= 1;
                if (quantity1155[tokenId] == 0) {
                    holdings.remove(tokenId);
                }

                IERC1155Upgradeable(_assetAddress).safeTransferFrom(
                    address(this),
                    to,
                    tokenId,
                    1,
                    ""
                );
            } else {
                holdings.remove(tokenId);
                transferERC721(_assetAddress, to, tokenId);
            }
        }
        afterRedeemHook(redeemedIds);
        return redeemedIds;
    }

    function _chargeAndDistributeFees(address user, uint256 amount) internal virtual {

        if (vaultFactory.excludedFromFees(msg.sender)) {
            return;
        }
        
        if (amount > 0) {
            address feeDistributor = vaultFactory.feeDistributor();
            _transfer(user, feeDistributor, amount);
            INFTXFeeDistributor(feeDistributor).distribute(vaultId);
        }
    }

    function transferERC721(address assetAddr, address to, uint256 tokenId) internal virtual {

        address kitties = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
        address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
        bytes memory data;
        if (assetAddr == kitties) {
            data = abi.encodeWithSignature("transfer(address,uint256)", to, tokenId);
        } else if (assetAddr == punks) {
            data = abi.encodeWithSignature("transferPunk(address,uint256)", to, tokenId);
        } else {
            data = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", address(this), to, tokenId);
        }
        (bool success,) = address(assetAddr).call(data);
        require(success);
    }

    function transferFromERC721(address assetAddr, uint256 tokenId) internal virtual {

        address kitties = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
        address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
        bytes memory data;
        if (assetAddr == kitties) {
            data = abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), tokenId);
        } else if (assetAddr == punks) {
            bytes memory punkIndexToAddress = abi.encodeWithSignature("punkIndexToAddress(uint256)", tokenId);
            (bool checkSuccess, bytes memory result) = address(assetAddr).staticcall(punkIndexToAddress);
            (address owner) = abi.decode(result, (address));
            require(checkSuccess && owner == msg.sender, "Not the owner");
            data = abi.encodeWithSignature("buyPunk(uint256)", tokenId);
        } else {
            if (IERC721Upgradeable(assetAddress).ownerOf(tokenId) == address(this)) {
                require(!holdings.contains(tokenId), "Trying to use an owned NFT");
                return;
            } else {
                data = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", msg.sender, address(this), tokenId);
            }
        }
        (bool success, bytes memory resultData) = address(assetAddr).call(data);
        require(success, string(resultData));
    }

    function getRandomTokenIdFromVault() internal virtual returns (uint256) {

        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1), 
                    randNonce,
                    block.coinbase,
                    block.difficulty,
                    block.timestamp
                )
            )
        ) % holdings.length();
        randNonce += 1;
        return holdings.at(randomIndex);
    }

    function onlyPrivileged() internal view {

        if (manager == address(0)) {
            require(msg.sender == owner(), "Not owner");
        } else {
            require(msg.sender == manager, "Not manager");
        }
    }

    function onlyOwnerIfPaused(uint256 lockId) internal view {

        require(!vaultFactory.isLocked(lockId) || msg.sender == owner(), "Paused");
    }
}





pragma solidity ^0.8.0;









contract NFTXVaultFactoryUpgradeable is
    PausableUpgradeable,
    UpgradeableBeacon,
    INFTXVaultFactory
{

    uint256 private NOT_USED1; // Removed, no longer needed.
    address public override zapContract;
    address public override feeDistributor;
    address public override eligibilityManager;

    mapping(uint256 => address) private NOT_USED2; // Removed, no longer needed.
    mapping(address => address[]) _vaultsForAsset;
    
    address[] internal vaults;

    mapping(address => bool) public override excludedFromFees;

    struct VaultFees {
        bool active;
        uint64 mintFee;
        uint64 randomRedeemFee;
        uint64 targetRedeemFee;
        uint64 randomSwapFee;
        uint64 targetSwapFee;
    }
    mapping(uint256 => VaultFees) private _vaultFees;
    uint64 public override factoryMintFee;
    uint64 public override factoryRandomRedeemFee;
    uint64 public override factoryTargetRedeemFee;
    uint64 public override factoryRandomSwapFee;
    uint64 public override factoryTargetSwapFee;

    function __NFTXVaultFactory_init(address _vaultImpl, address _feeDistributor) public override initializer {

        __Pausable_init();
        __UpgradeableBeacon__init(_vaultImpl);
        setFeeDistributor(_feeDistributor);
        setFactoryFees(0.1 ether, 0.05 ether, 0.1 ether, 0.05 ether, 0.1 ether);
    }

    function assignFees() public {

        require(factoryMintFee == 0 && factoryTargetRedeemFee == 0, "Assigned");
        factoryMintFee = uint64(0.1 ether);
        factoryRandomRedeemFee = uint64(0.05 ether);
        factoryTargetRedeemFee = uint64(0.1 ether);
        factoryRandomSwapFee = uint64(0.05 ether);
        factoryTargetSwapFee = uint64(0.1 ether);

        emit UpdateFactoryFees(0.1 ether, 0.05 ether, 0.1 ether, 0.05 ether, 0.1 ether);
    }

    function createVault(
        string memory name,
        string memory symbol,
        address _assetAddress,
        bool is1155,
        bool allowAllItems
    ) external virtual override returns (uint256) {

        onlyOwnerIfPaused(0);
        require(feeDistributor != address(0), "NFTX: Fee receiver unset");
        require(childImplementation() != address(0), "NFTX: Vault implementation unset");
        address vaultAddr = deployVault(name, symbol, _assetAddress, is1155, allowAllItems);
        uint256 _vaultId = vaults.length;
        _vaultsForAsset[_assetAddress].push(vaultAddr);
        vaults.push(vaultAddr);
        INFTXFeeDistributor(feeDistributor).initializeVaultReceivers(_vaultId);
        emit NewVault(_vaultId, vaultAddr, _assetAddress);
        return _vaultId;
    }

    function setFactoryFees(
        uint256 mintFee, 
        uint256 randomRedeemFee, 
        uint256 targetRedeemFee,
        uint256 randomSwapFee, 
        uint256 targetSwapFee
    ) public onlyOwner virtual override {

        require(mintFee <= 1 ether, "Cannot > 1 ether");
        require(randomRedeemFee <= 1 ether, "Cannot > 1 ether");
        require(targetRedeemFee <= 1 ether, "Cannot > 1 ether");
        require(randomSwapFee <= 1 ether, "Cannot > 1 ether");
        require(targetSwapFee <= 1 ether, "Cannot > 1 ether");

        factoryMintFee = uint64(mintFee);
        factoryRandomRedeemFee = uint64(randomRedeemFee);
        factoryTargetRedeemFee = uint64(targetRedeemFee);
        factoryRandomSwapFee = uint64(randomSwapFee);
        factoryTargetSwapFee = uint64(targetSwapFee);

        emit UpdateFactoryFees(mintFee, randomRedeemFee, targetRedeemFee, randomSwapFee, targetSwapFee);
    }

    function setVaultFees(
        uint256 vaultId, 
        uint256 mintFee, 
        uint256 randomRedeemFee, 
        uint256 targetRedeemFee,
        uint256 randomSwapFee, 
        uint256 targetSwapFee
    ) public virtual override {

        if (msg.sender != owner()) {
            address vaultAddr = vaults[vaultId];
            require(msg.sender == vaultAddr, "Not from vault");
        }
        require(mintFee <= 1 ether, "Cannot > 1 ether");
        require(randomRedeemFee <= 1 ether, "Cannot > 1 ether");
        require(targetRedeemFee <= 1 ether, "Cannot > 1 ether");
        require(randomSwapFee <= 1 ether, "Cannot > 1 ether");
        require(targetSwapFee <= 1 ether, "Cannot > 1 ether");

        _vaultFees[vaultId] = VaultFees(
            true, 
            uint64(mintFee),
            uint64(randomRedeemFee),
            uint64(targetRedeemFee),
            uint64(randomSwapFee), 
            uint64(targetSwapFee)
        );
        emit UpdateVaultFees(vaultId, mintFee, randomRedeemFee, targetRedeemFee, randomSwapFee, targetSwapFee);
    }

    function disableVaultFees(uint256 vaultId) public virtual override {

        if (msg.sender != owner()) {
            address vaultAddr = vaults[vaultId];
            require(msg.sender == vaultAddr, "Not vault");
        }
        delete _vaultFees[vaultId];
        emit DisableVaultFees(vaultId);
    }

    function setFeeDistributor(address _feeDistributor) public onlyOwner virtual override {

        require(_feeDistributor != address(0));
        emit NewFeeDistributor(feeDistributor, _feeDistributor);
        feeDistributor = _feeDistributor;
    }

    function setZapContract(address _zapContract) public onlyOwner virtual override {

        emit NewZapContract(zapContract, _zapContract);
        zapContract = _zapContract;
    }

    function setFeeExclusion(address _excludedAddr, bool excluded) public onlyOwner virtual override {

        emit FeeExclusion(_excludedAddr, excluded);
        excludedFromFees[_excludedAddr] = excluded;
    }

    function setEligibilityManager(address _eligibilityManager) external onlyOwner virtual override {

        emit NewEligibilityManager(eligibilityManager, _eligibilityManager);
        eligibilityManager = _eligibilityManager;
    }

    function vaultFees(uint256 vaultId) external view virtual override returns (uint256, uint256, uint256, uint256, uint256) {

        VaultFees memory fees = _vaultFees[vaultId];
        if (fees.active) {
            return (
                uint256(fees.mintFee), 
                uint256(fees.randomRedeemFee), 
                uint256(fees.targetRedeemFee), 
                uint256(fees.randomSwapFee), 
                uint256(fees.targetSwapFee)
            );
        }
        
        return (uint256(factoryMintFee), uint256(factoryRandomRedeemFee), uint256(factoryTargetRedeemFee), uint256(factoryRandomSwapFee), uint256(factoryTargetSwapFee));
    }

    function isLocked(uint256 lockId) external view override virtual returns (bool) {

        return isPaused[lockId];
    }

    function vaultsForAsset(address assetAddress) external view override virtual returns (address[] memory) {

        return _vaultsForAsset[assetAddress];
    }

    function vault(uint256 vaultId) external view override virtual returns (address) {

        return vaults[vaultId];
    }

    function allVaults() external view override virtual returns (address[] memory) {

        return vaults;
    }

    function numVaults() external view override virtual returns (uint256) {

        return vaults.length;
    }
    
    function deployVault(
        string memory name,
        string memory symbol,
        address _assetAddress,
        bool is1155,
        bool allowAllItems
    ) internal returns (address) {

        address newBeaconProxy = address(new BeaconProxy(address(this), ""));
        NFTXVaultUpgradeable(newBeaconProxy).__NFTXVault_init(name, symbol, _assetAddress, is1155, allowAllItems);
        NFTXVaultUpgradeable(newBeaconProxy).setManager(msg.sender);
        NFTXVaultUpgradeable(newBeaconProxy).transferOwnership(owner());
        return newBeaconProxy;
    }
}