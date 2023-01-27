



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

interface INFTXSimpleFeeDistributor {

  
  struct FeeReceiver {
    uint256 allocPoint;
    address receiver;
    bool isContract;
  }

  function nftxVaultFactory() external view returns (address);

  function lpStaking() external view returns (address);

  function inventoryStaking() external view returns (address);

  function treasury() external view returns (address);

  function allocTotal() external view returns (uint256);


  function __SimpleFeeDistributor__init__(address _lpStaking, address _treasury) external;

  function rescueTokens(address token) external;

  function distribute(uint256 vaultId) external;

  function addReceiver(uint256 _allocPoint, address _receiver, bool _isContract) external;

  function initializeVaultReceivers(uint256 _vaultId) external;


  function changeReceiverAlloc(uint256 _idx, uint256 _allocPoint) external;

  function changeReceiverAddress(uint256 _idx, address _address, bool _isContract) external;

  function removeReceiver(uint256 _receiverIdx) external;


  function setTreasuryAddress(address _treasury) external;

  function setLPStakingAddress(address _lpStaking) external;

  function setInventoryStakingAddress(address _inventoryStaking) external;

  function setNFTXVaultFactory(address _factory) external;

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

    function rewardDistributionTokenAddr(address stakedToken, address rewardToken) external view returns (address);

    
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

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB)
        external
        pure
        returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}





pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity ^0.8.0;

interface IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}





pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}





pragma solidity ^0.8.0;

contract ERC721HolderUpgradeable is IERC721ReceiverUpgradeable {

    function onERC721Received(
        address,
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

abstract contract ERC1155HolderUpgradeable is ERC1155ReceiverUpgradeable {
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
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

interface ITimelockExcludeList {

    function isExcluded(address addr, uint256 vaultId) external view returns (bool);

}





pragma solidity ^0.8.0;















interface IWETH {

  function deposit() external payable;

  function transfer(address to, uint value) external returns (bool);

  function withdraw(uint) external;

}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract NFTXStakingZap is Ownable, ReentrancyGuard, ERC721HolderUpgradeable, ERC1155HolderUpgradeable {

  using SafeERC20Upgradeable for IERC20Upgradeable;

  IWETH public immutable WETH; 
  INFTXLPStaking public lpStaking;
  INFTXInventoryStaking public inventoryStaking;
  INFTXVaultFactory public immutable nftxFactory;
  IUniswapV2Router01 public immutable sushiRouter;
  ITimelockExcludeList public timelockExcludeList;

  uint256 public lpLockTime = 48 hours; 
  uint256 public inventoryLockTime = 7 days; 
  uint256 constant BASE = 1e18;

  event UserStaked(uint256 vaultId, uint256 count, uint256 lpBalance, uint256 timelockUntil, address sender);

  constructor(address _nftxFactory, address _sushiRouter) Ownable() ReentrancyGuard() {
    nftxFactory = INFTXVaultFactory(_nftxFactory);
    sushiRouter = IUniswapV2Router01(_sushiRouter);
    WETH = IWETH(IUniswapV2Router01(_sushiRouter).WETH());
    IERC20Upgradeable(address(IUniswapV2Router01(_sushiRouter).WETH())).safeApprove(_sushiRouter, type(uint256).max);
  }

  function assignStakingContracts() public {

    require(address(lpStaking) == address(0) || address(inventoryStaking) == address(0), "not zero");
    lpStaking = INFTXLPStaking(INFTXSimpleFeeDistributor(INFTXVaultFactory(nftxFactory).feeDistributor()).lpStaking());
    inventoryStaking = INFTXInventoryStaking(INFTXSimpleFeeDistributor(INFTXVaultFactory(nftxFactory).feeDistributor()).inventoryStaking());
  }

  function setTimelockExcludeList(address addr) external onlyOwner {

    timelockExcludeList = ITimelockExcludeList(addr);
  }

  function setLPLockTime(uint256 newLPLockTime) external onlyOwner {

    require(newLPLockTime <= 7 days, "Lock too long");
    lpLockTime = newLPLockTime;
  } 

  function setInventoryLockTime(uint256 newInventoryLockTime) external onlyOwner {

    require(newInventoryLockTime <= 14 days, "Lock too long");
    inventoryLockTime = newInventoryLockTime;
  }

  function isAddressTimelockExcluded(address addr, uint256 vaultId) public view returns (bool) {

        if (address(timelockExcludeList) == address(0)) {
            return false;
        } else {
            return timelockExcludeList.isExcluded(addr, vaultId);
        }
    }

  function provideInventory721(uint256 vaultId, uint256[] calldata tokenIds) external {

    uint256 count = tokenIds.length;
    INFTXVault vault = INFTXVault(nftxFactory.vault(vaultId));
    uint256 timelockTime = isAddressTimelockExcluded(msg.sender, vaultId) ? 0 : inventoryLockTime;
    inventoryStaking.timelockMintFor(vaultId, count*BASE, msg.sender, timelockTime);
    address xToken = inventoryStaking.vaultXToken(vaultId);
    uint256 oldBal = IERC20Upgradeable(vault).balanceOf(xToken);
    uint256[] memory amounts = new uint256[](0);
    address assetAddress = vault.assetAddress();
    uint256 length = tokenIds.length;
    for (uint256 i; i < length; ++i) {
      transferFromERC721(assetAddress, tokenIds[i], address(vault));
      approveERC721(assetAddress, address(vault), tokenIds[i]);
    }
    vault.mintTo(tokenIds, amounts, address(xToken));
    uint256 newBal = IERC20Upgradeable(vault).balanceOf(xToken);
    require(newBal == oldBal + count*BASE, "Incorrect vtokens minted");
    uint256 lockEndTime = block.timestamp + timelockTime;
    emit UserStaked(vaultId, tokenIds.length, 0, lockEndTime, msg.sender);
  }

  function provideInventory1155(uint256 vaultId, uint256[] calldata tokenIds, uint256[] calldata amounts) external {

    uint256 length = tokenIds.length;
    require(length == amounts.length, "Not equal length");
    uint256 count;
    for (uint256 i; i < length; ++i) {
      count += amounts[i];
    }
    INFTXVault vault = INFTXVault(nftxFactory.vault(vaultId));
    uint256 timelockTime = isAddressTimelockExcluded(msg.sender, vaultId) ? 0 : inventoryLockTime;
    inventoryStaking.timelockMintFor(vaultId, count*BASE, msg.sender, timelockTime);
    address xToken = inventoryStaking.vaultXToken(vaultId);
    uint256 oldBal = IERC20Upgradeable(vault).balanceOf(address(xToken));
    IERC1155Upgradeable nft = IERC1155Upgradeable(vault.assetAddress());
    nft.safeBatchTransferFrom(msg.sender, address(this), tokenIds, amounts, "");
    nft.setApprovalForAll(address(vault), true);
    vault.mintTo(tokenIds, amounts, address(xToken));
    uint256 newBal = IERC20Upgradeable(vault).balanceOf(address(xToken));
    require(newBal == oldBal + count*BASE, "Incorrect vtokens minted");
    uint256 lockEndTime = block.timestamp + timelockTime;
    emit UserStaked(vaultId, tokenIds.length, 0, lockEndTime, msg.sender);
  }

  function addLiquidity721ETH(
    uint256 vaultId, 
    uint256[] calldata ids, 
    uint256 minWethIn
  ) external payable returns (uint256) {

    return addLiquidity721ETHTo(vaultId, ids, minWethIn, msg.sender);
  }

  function addLiquidity721ETHTo(
    uint256 vaultId, 
    uint256[] memory ids, 
    uint256 minWethIn,
    address to
  ) public payable nonReentrant returns (uint256) {

    require(to != address(0) && to != address(this));
    WETH.deposit{value: msg.value}();
    (, uint256 amountEth, uint256 liquidity) = _addLiquidity721WETH(vaultId, ids, minWethIn, msg.value, to);

    uint256 remaining = msg.value-amountEth;
    if (remaining != 0) {
      WETH.withdraw(remaining);
      (bool success, ) = payable(to).call{value: remaining}("");
      require(success, "Address: unable to send value, recipient may have reverted");
    }

    return liquidity;
  }

  function addLiquidity1155ETH(
    uint256 vaultId, 
    uint256[] calldata ids, 
    uint256[] calldata amounts,
    uint256 minEthIn
  ) external payable returns (uint256) {

    return addLiquidity1155ETHTo(vaultId, ids, amounts, minEthIn, msg.sender);
  }

  function addLiquidity1155ETHTo(
    uint256 vaultId, 
    uint256[] memory ids, 
    uint256[] memory amounts,
    uint256 minEthIn,
    address to
  ) public payable nonReentrant returns (uint256) {

    require(to != address(0) && to != address(this));
    WETH.deposit{value: msg.value}();
    (, uint256 amountEth, uint256 liquidity) = _addLiquidity1155WETH(vaultId, ids, amounts, minEthIn, msg.value, to);

    uint256 remaining = msg.value-amountEth;
    if (remaining != 0) {
      WETH.withdraw(remaining);
      (bool success, ) = payable(to).call{value: remaining}("");
      require(success, "Address: unable to send value, recipient may have reverted");
    }

    return liquidity;
  }

  function addLiquidity721(
    uint256 vaultId, 
    uint256[] calldata ids, 
    uint256 minWethIn,
    uint256 wethIn
  ) external returns (uint256) {

    return addLiquidity721To(vaultId, ids, minWethIn, wethIn, msg.sender);
  }

  function addLiquidity721To(
    uint256 vaultId, 
    uint256[] memory ids, 
    uint256 minWethIn,
    uint256 wethIn,
    address to
  ) public nonReentrant returns (uint256) {

    require(to != address(0) && to != address(this));
    IERC20Upgradeable(address(WETH)).safeTransferFrom(msg.sender, address(this), wethIn);
    (, uint256 amountEth, uint256 liquidity) = _addLiquidity721WETH(vaultId, ids, minWethIn, wethIn, to);

    uint256 remaining = wethIn-amountEth;
    if (remaining != 0) {
      WETH.transfer(to, remaining);
    }

    return liquidity;
  }

  function addLiquidity1155(
    uint256 vaultId, 
    uint256[] memory ids,
    uint256[] memory amounts,
    uint256 minWethIn,
    uint256 wethIn
  ) public returns (uint256) {

    return addLiquidity1155To(vaultId, ids, amounts, minWethIn, wethIn, msg.sender);
  }

  function addLiquidity1155To(
    uint256 vaultId, 
    uint256[] memory ids,
    uint256[] memory amounts,
    uint256 minWethIn,
    uint256 wethIn,
    address to
  ) public nonReentrant returns (uint256) {

    require(to != address(0) && to != address(this));
    IERC20Upgradeable(address(WETH)).safeTransferFrom(msg.sender, address(this), wethIn);
    (, uint256 amountEth, uint256 liquidity) = _addLiquidity1155WETH(vaultId, ids, amounts, minWethIn, wethIn, to);

    uint256 remaining = wethIn-amountEth; 
    if (remaining != 0) {
      WETH.transfer(to, remaining);
    }

    return liquidity;
  }

  function _addLiquidity721WETH(
    uint256 vaultId, 
    uint256[] memory ids, 
    uint256 minWethIn,
    uint256 wethIn,
    address to
  ) internal returns (uint256, uint256, uint256) {

    require(nftxFactory.excludedFromFees(address(this)));
    address vault = nftxFactory.vault(vaultId);

    address assetAddress = INFTXVault(vault).assetAddress();
    uint256 length = ids.length;
    for (uint256 i; i < length; i++) {
      transferFromERC721(assetAddress, ids[i], vault);
      approveERC721(assetAddress, vault, ids[i]);
    }
    uint256[] memory emptyIds;
    INFTXVault(vault).mint(ids, emptyIds);
    uint256 balance = length * BASE; // We should not be experiencing fees.
    
    return _addLiquidityAndLock(vaultId, vault, balance, minWethIn, wethIn, to);
  }

  function _addLiquidity1155WETH(
    uint256 vaultId, 
    uint256[] memory ids,
    uint256[] memory amounts,
    uint256 minWethIn,
    uint256 wethIn,
    address to
  ) internal returns (uint256, uint256, uint256) {

    require(nftxFactory.excludedFromFees(address(this)));
    address vault = nftxFactory.vault(vaultId);

    address assetAddress = INFTXVault(vault).assetAddress();
    IERC1155Upgradeable(assetAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    IERC1155Upgradeable(assetAddress).setApprovalForAll(vault, true);
    
    uint256 count = INFTXVault(vault).mint(ids, amounts);
    uint256 balance = (count * BASE); // We should not be experiencing fees.
    
    return _addLiquidityAndLock(vaultId, vault, balance, minWethIn, wethIn, to);
  }

  function _addLiquidityAndLock(
    uint256 vaultId, 
    address vault, 
    uint256 minTokenIn, 
    uint256 minWethIn, 
    uint256 wethIn,
    address to
  ) internal returns (uint256, uint256, uint256) {

    IERC20Upgradeable(vault).safeApprove(address(sushiRouter), minTokenIn);
    (uint256 amountToken, uint256 amountEth, uint256 liquidity) = sushiRouter.addLiquidity(
      address(vault),
      address(WETH),
      minTokenIn,
      wethIn,
      minTokenIn,
      minWethIn,
      address(this),
      block.timestamp
    );

    IERC20Upgradeable(pairFor(vault, address(WETH))).safeApprove(address(lpStaking), liquidity);
    uint256 timelockTime = isAddressTimelockExcluded(msg.sender, vaultId) ? 0 : lpLockTime;
    lpStaking.timelockDepositFor(vaultId, to, liquidity, timelockTime);
    
    uint256 remaining = minTokenIn-amountToken;
    if (remaining != 0) {
      IERC20Upgradeable(vault).safeTransfer(to, remaining);
    }

    uint256 lockEndTime = block.timestamp + timelockTime;
    emit UserStaked(vaultId, minTokenIn, liquidity, lockEndTime, to);
    return (amountToken, amountEth, liquidity);
  }

  function transferFromERC721(address assetAddr, uint256 tokenId, address to) internal virtual {

    address kitties = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    bytes memory data;
    if (assetAddr == kitties) {
        data = abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, to, tokenId);
    } else if (assetAddr == punks) {
        bytes memory punkIndexToAddress = abi.encodeWithSignature("punkIndexToAddress(uint256)", tokenId);
        (bool checkSuccess, bytes memory result) = address(assetAddr).staticcall(punkIndexToAddress);
        (address nftOwner) = abi.decode(result, (address));
        require(checkSuccess && nftOwner == msg.sender, "Not the NFT owner");
        data = abi.encodeWithSignature("buyPunk(uint256)", tokenId);
    } else {
        data = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", msg.sender, to, tokenId);
    }
    (bool success, bytes memory resultData) = address(assetAddr).call(data);
    require(success, string(resultData));
  }

  function approveERC721(address assetAddr, address to, uint256 tokenId) internal virtual {

    address kitties = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    bytes memory data;
    if (assetAddr == kitties) {
        return;
    } else if (assetAddr == punks) {
        data = abi.encodeWithSignature("offerPunkForSaleToAddress(uint256,uint256,address)", tokenId, 0, to);
    } else {
      return;
    }
    (bool success, bytes memory resultData) = address(assetAddr).call(data);
    require(success, string(resultData));
  }

  function pairFor(address tokenA, address tokenB) internal view returns (address pair) {

    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = address(uint160(uint256(keccak256(abi.encodePacked(
      hex'ff',
      sushiRouter.factory(),
      keccak256(abi.encodePacked(token0, token1)),
      hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303' // init code hash
    )))));
  }

  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

      require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
      (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
      require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
  }

  receive() external payable {
    require(msg.sender == address(WETH), "Only WETH");
  }

  function rescue(address token) external onlyOwner {

    if (token == address(0)) {
      (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
      require(success, "Address: unable to send value, recipient may have reverted");
    } else {
      IERC20Upgradeable(token).safeTransfer(msg.sender, IERC20Upgradeable(token).balanceOf(address(this)));
    }
  }
}