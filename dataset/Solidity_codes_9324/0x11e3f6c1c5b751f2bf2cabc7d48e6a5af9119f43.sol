



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

interface INFTXInventoryStaking {

    function nftxVaultFactory() external view returns (INFTXVaultFactory);

    function vaultXToken(uint256 vaultId) external view returns (address);

    function xTokenAddr(address baseToken) external view returns (address);

    function xTokenShareValue(uint256 vaultId) external view returns (uint256);


    function __NFTXInventoryStaking_init(address nftxFactory) external;

    
    function deployXTokenForVault(uint256 vaultId) external;

    function receiveRewards(uint256 vaultId, uint256 amount) external returns (bool);

    function timelockMintFor(uint256 vaultId, uint256 amount, address to, uint256 timelockLength) external returns (uint256);

    function deposit(uint256 vaultId, uint256 _amount) external;

    function withdraw(uint256 vaultId, uint256 _share) external;

}





pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

library Create2 {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
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



contract Create2BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor() payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(msg.sender, "");
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




contract XTokenUpgradeable is OwnableUpgradeable, ERC20Upgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 internal constant MAX_TIMELOCK = 2592000;
    IERC20Upgradeable public baseToken;

    mapping(address => uint256) internal timelock;

    event Timelocked(address user, uint256 until);

    function __XToken_init(address _baseToken, string memory name, string memory symbol) public initializer {

        __Ownable_init();
        __ERC20_init(name, symbol);
        baseToken = IERC20Upgradeable(_baseToken);
    }

    function mintXTokens(address account, uint256 _amount, uint256 timelockLength) external onlyOwner returns (uint256) {

        uint256 totalBaseToken = baseToken.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalBaseToken == 0) {
            _timelockMint(account, _amount, timelockLength);
            return _amount;
        }
        else {
            uint256 what = (_amount * totalShares) / totalBaseToken;
            _timelockMint(account, what, timelockLength);
            return what;
        }
    }

    function burnXTokens(address who, uint256 _share) external onlyOwner returns (uint256) {

        uint256 totalShares = totalSupply();
        uint256 what = (_share * baseToken.balanceOf(address(this))) / totalShares;
        _burn(who, _share);
        baseToken.safeTransfer(who, what);
        return what;
    }

    function timelockAccount(address account, uint256 timelockLength) public onlyOwner virtual {

        require(timelockLength < MAX_TIMELOCK, "Too long lock");
        uint256 timelockFinish = block.timestamp + timelockLength;
        if(timelockFinish > timelock[account]){
            timelock[account] = timelockFinish;
            emit Timelocked(account, timelockFinish);
        }
    }

    function _burn(address who, uint256 amount) internal override {

        require(block.timestamp > timelock[who], "User locked");
        super._burn(who, amount);
    }

    function timelockUntil(address account) public view returns (uint256) {

        return timelock[account];
    }

    function _timelockMint(address account, uint256 amount, uint256 timelockLength) internal virtual {

        timelockAccount(account, timelockLength);
        _mint(account, amount);
    }
    
    function _transfer(address from, address to, uint256 value) internal override {

        require(block.timestamp > timelock[from], "User locked");
        super._transfer(from, to, value);
    }
}





pragma solidity ^0.8.0;

interface ITimelockExcludeList {

    function isExcluded(address addr, uint256 vaultId) external view returns (bool);

}





pragma solidity ^0.8.0;















contract NFTXInventoryStaking is PausableUpgradeable, UpgradeableBeacon, INFTXInventoryStaking {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 internal constant DEFAULT_LOCKTIME = 2;
    bytes internal constant beaconCode = type(Create2BeaconProxy).creationCode;

    INFTXVaultFactory public override nftxVaultFactory;

    uint256 public inventoryLockTimeErc20;
    ITimelockExcludeList public timelockExcludeList;

    event XTokenCreated(uint256 vaultId, address baseToken, address xToken);
    event Deposit(uint256 vaultId, uint256 baseTokenAmount, uint256 xTokenAmount, uint256 timelockUntil, address sender);
    event Withdraw(uint256 vaultId, uint256 baseTokenAmount, uint256 xTokenAmount, address sender);
    event FeesReceived(uint256 vaultId, uint256 amount);

    function __NFTXInventoryStaking_init(address _nftxVaultFactory) external virtual override initializer {

        __Ownable_init();
        nftxVaultFactory = INFTXVaultFactory(_nftxVaultFactory);
        address xTokenImpl = address(new XTokenUpgradeable());
        __UpgradeableBeacon__init(xTokenImpl);
    }

    modifier onlyAdmin() {

        require(msg.sender == owner() || msg.sender == nftxVaultFactory.feeDistributor(), "LPStaking: Not authorized");
        _;
    }

    function setTimelockExcludeList(address addr) external onlyOwner {

        timelockExcludeList = ITimelockExcludeList(addr);
    }

    function setInventoryLockTimeErc20(uint256 time) external onlyOwner {

        require(time <= 14 days, "Lock too long");
        inventoryLockTimeErc20 = time;
    }

    function isAddressTimelockExcluded(address addr, uint256 vaultId) public view returns (bool) {

        if (address(timelockExcludeList) == address(0)) {
            return false;
        } else {
            return timelockExcludeList.isExcluded(addr, vaultId);
        }
    }

    function deployXTokenForVault(uint256 vaultId) public virtual override {

        address baseToken = nftxVaultFactory.vault(vaultId);
        address deployedXToken = xTokenAddr(address(baseToken));

        if (isContract(deployedXToken)) {
            return;
        }

        address xToken = _deployXToken(baseToken);
        emit XTokenCreated(vaultId, baseToken, xToken);
    }

    function receiveRewards(uint256 vaultId, uint256 amount) external virtual override onlyAdmin returns (bool) {

        address baseToken = nftxVaultFactory.vault(vaultId);
        address deployedXToken = xTokenAddr(address(baseToken));
        
        if (!isContract(deployedXToken) || XTokenUpgradeable(deployedXToken).totalSupply() == 0) {
            return false;
        }
        IERC20Upgradeable(baseToken).safeTransferFrom(msg.sender, deployedXToken, amount);
        emit FeesReceived(vaultId, amount);
        return true;
    }

    function deposit(uint256 vaultId, uint256 _amount) external virtual override {

        onlyOwnerIfPaused(10);

        uint256 timelockTime = isAddressTimelockExcluded(msg.sender, vaultId) ? 0 : inventoryLockTimeErc20;

        (IERC20Upgradeable baseToken, XTokenUpgradeable xToken, uint256 xTokensMinted) = _timelockMintFor(vaultId, msg.sender, _amount, timelockTime);
        baseToken.safeTransferFrom(msg.sender, address(xToken), _amount);
        emit Deposit(vaultId, _amount, xTokensMinted, timelockTime, msg.sender);
    }

    function timelockMintFor(uint256 vaultId, uint256 amount, address to, uint256 timelockLength) external virtual override returns (uint256) {

        onlyOwnerIfPaused(10);
        require(msg.sender == nftxVaultFactory.zapContract(), "Not staking zap");
        require(nftxVaultFactory.excludedFromFees(msg.sender), "Not fee excluded"); // important for math that staking zap is excluded from fees

        (, , uint256 xTokensMinted) = _timelockMintFor(vaultId, to, amount, timelockLength);
        emit Deposit(vaultId, amount, xTokensMinted, timelockLength, to);
        return xTokensMinted;
    }

    function withdraw(uint256 vaultId, uint256 _share) external virtual override {

        IERC20Upgradeable baseToken = IERC20Upgradeable(nftxVaultFactory.vault(vaultId));
        XTokenUpgradeable xToken = XTokenUpgradeable(xTokenAddr(address(baseToken)));

        uint256 baseTokensRedeemed = xToken.burnXTokens(msg.sender, _share);
        emit Withdraw(vaultId, baseTokensRedeemed, _share, msg.sender);
    }

   function xTokenShareValue(uint256 vaultId) external view virtual override returns (uint256) {

        IERC20Upgradeable baseToken = IERC20Upgradeable(nftxVaultFactory.vault(vaultId));
        XTokenUpgradeable xToken = XTokenUpgradeable(xTokenAddr(address(baseToken)));
        require(address(xToken) != address(0), "XToken not deployed");

        uint256 multiplier = 10 ** 18;
        return xToken.totalSupply() > 0 
            ? multiplier * baseToken.balanceOf(address(xToken)) / xToken.totalSupply() 
            : multiplier;
    }

    function timelockUntil(uint256 vaultId, address who) external view returns (uint256) {

        XTokenUpgradeable xToken = XTokenUpgradeable(vaultXToken(vaultId));
        return xToken.timelockUntil(who);
    }

    function balanceOf(uint256 vaultId, address who) external view returns (uint256) {

        XTokenUpgradeable xToken = XTokenUpgradeable(vaultXToken(vaultId));
        return xToken.balanceOf(who);
    }

    function xTokenAddr(address baseToken) public view virtual override returns (address) {

        bytes32 salt = keccak256(abi.encodePacked(baseToken));
        address tokenAddr = Create2.computeAddress(salt, keccak256(type(Create2BeaconProxy).creationCode));
        return tokenAddr;
    }
    
    function vaultXToken(uint256 vaultId) public view virtual override returns (address) {

        address baseToken = nftxVaultFactory.vault(vaultId);
        address xToken = xTokenAddr(baseToken);
        require(isContract(xToken), "XToken not deployed");
        return xToken;
    } 

    function _timelockMintFor(uint256 vaultId, address account, uint256 _amount, uint256 timelockLength) internal returns (IERC20Upgradeable, XTokenUpgradeable, uint256) {

        deployXTokenForVault(vaultId);
        IERC20Upgradeable baseToken = IERC20Upgradeable(nftxVaultFactory.vault(vaultId));
        XTokenUpgradeable xToken = XTokenUpgradeable((xTokenAddr(address(baseToken))));

        uint256 xTokensMinted = xToken.mintXTokens(account, _amount, timelockLength);
        return (baseToken, xToken, xTokensMinted);
    }

    function _deployXToken(address baseToken) internal returns (address) {

        string memory symbol = IERC20Metadata(baseToken).symbol();
        symbol = string(abi.encodePacked("x", symbol));
        bytes32 salt = keccak256(abi.encodePacked(baseToken));
        address deployedXToken = Create2.deploy(0, salt, beaconCode);
        XTokenUpgradeable(deployedXToken).__XToken_init(baseToken, symbol, symbol);
        return deployedXToken;
    }

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size != 0;
    }
}