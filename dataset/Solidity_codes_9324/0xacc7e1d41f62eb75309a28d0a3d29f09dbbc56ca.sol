
pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity >=0.8.7;

interface IRentableEvents {


    event WalletCreated(address indexed user, address indexed walletAddress);

    event Deposit(
        address indexed who,
        address indexed tokenAddress,
        uint256 indexed tokenId
    );

    event Withdraw(address indexed tokenAddress, uint256 indexed tokenId);

    event UpdateRentalConditions(
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address paymentTokenAddress,
        uint256 paymentTokenId,
        uint256 minTimeDuration,
        uint256 maxTimeDuration,
        uint256 pricePerSecond,
        address privateRenter
    );

    event Rent(
        address from,
        address indexed to,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address paymentTokenAddress,
        uint256 paymentTokenId,
        uint256 expiresAt
    );

    event RentEnds(address indexed tokenAddress, uint256 indexed tokenId);
}// MIT
pragma solidity >=0.8.7;

library RentableTypes {

    struct RentalConditions {
        uint256 minTimeDuration; // min duration allowed for the rental
        uint256 maxTimeDuration; // max duration allowed for the rental
        uint256 pricePerSecond; // price per second in payment token units
        uint256 paymentTokenId; // payment token id allowed for the rental (0 for ETH and ERC20)
        address paymentTokenAddress; // payment token address allowed for the rental
        address privateRenter; // restrict rent only to this address
    }
}// MIT

pragma solidity >=0.8.7;



interface IRentable is IRentableEvents, IERC721ReceiverUpgradeable {


    function userWallet(address user) external view returns (address payable);


    function rentalConditions(address tokenAddress, uint256 tokenId)
        external
        view
        returns (RentableTypes.RentalConditions memory);


    function expiresAt(address tokenAddress, uint256 tokenId)
        external
        view
        returns (uint256);


    function isExpired(address tokenAddress, uint256 tokenId)
        external
        view
        returns (bool);



    function createWalletForUser(address user)
        external
        returns (address payable wallet);


    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4);


    function withdraw(address tokenAddress, uint256 tokenId) external;


    function createOrUpdateRentalConditions(
        address tokenAddress,
        uint256 tokenId,
        RentableTypes.RentalConditions calldata rc
    ) external;


    function deleteRentalConditions(address tokenAddress, uint256 tokenId)
        external;


    function rent(
        address tokenAddress,
        uint256 tokenId,
        uint256 duration
    ) external payable;


    function expireRental(address tokenAddress, uint256 tokenId)
        external
        returns (bool currentlyRented);

}// MIT

pragma solidity >=0.8.7;

interface IRentableAdminEvents {


    event LibraryChanged(
        address indexed tokenAddress,
        address indexed previousValue,
        address indexed newValue
    );

    event ORentableChanged(
        address indexed tokenAddress,
        address indexed previousValue,
        address indexed newValue
    );

    event WRentableChanged(
        address indexed tokenAddress,
        address indexed previousValue,
        address indexed newValue
    );

    event WalletFactoryChanged(
        address indexed previousWalletFactory,
        address indexed newWalletFactory
    );

    event FeeChanged(uint16 indexed previousFee, uint16 indexed newFee);

    event FeeCollectorChanged(
        address indexed previousFeeCollector,
        address indexed newFeeCollector
    );

    event PaymentTokenAllowListChanged(
        address indexed paymentToken,
        uint8 indexed previousStatus,
        uint8 indexed newStatus
    );

    event ProxyCallAllowListChanged(
        address indexed caller,
        bytes4 selector,
        bool previousStatus,
        bool newStatus
    );
}// MIT

pragma solidity >=0.8.7;

interface IRentableHooks {


    function proxyCall(
        address to,
        bytes4 selector,
        bytes memory data
    ) external payable returns (bytes memory);

}// MIT

pragma solidity >=0.8.7;


interface IORentableHooks is IRentableHooks {


    function afterOTokenTransfer(
        address tokenAddress,
        address from,
        address to,
        uint256 tokenId
    ) external;

}// MIT

pragma solidity >=0.8.7;


interface IWRentableHooks is IRentableHooks {


    function afterWTokenTransfer(
        address tokenAddress,
        address from,
        address to,
        uint256 tokenId
    ) external;

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
        __Context_init_unchained();
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
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

interface IERC20Upgradeable {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity >=0.8.7;





contract BaseSecurityInitializable is Initializable, PausableUpgradeable {


    using Address for address;

    using SafeERC20Upgradeable for IERC20Upgradeable;

    address private constant ETHER = address(0);

    address private _governance;
    address private _pendingGovernance;
    address private _operator;


    modifier onlyGovernance() {

        require(msg.sender == _governance, "Only Governance");
        _;
    }

    modifier onlyOperatorOrGovernance() {

        require(
            msg.sender == _operator || msg.sender == _governance,
            "Only Operator or Governance"
        );
        _;
    }


    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    event GovernanceProposed(
        address indexed currentGovernance,
        address indexed proposedGovernance
    );

    event GovernanceTransferred(
        address indexed previousGovernance,
        address indexed newGovernance
    );



    function __BaseSecurityInitializable_init(
        address governance,
        address operator
    ) internal onlyInitializing {

        __Pausable_init();

        require(governance != address(0), "Governance cannot be null");

        _governance = governance;
        _operator = operator;
    }


    function setGovernance(address proposedGovernance) external onlyGovernance {

        _pendingGovernance = proposedGovernance;

        emit GovernanceProposed(_governance, proposedGovernance);
    }

    function acceptGovernance() external {

        require(msg.sender == _pendingGovernance, "Only Proposed Governance");

        address previousGovernance = _governance;
        _governance = _pendingGovernance;
        _pendingGovernance = address(0);

        emit GovernanceTransferred(previousGovernance, _governance);
    }

    function setOperator(address newOperator) external onlyGovernance {

        address previousOperator = _operator;

        _operator = newOperator;

        emit OperatorTransferred(previousOperator, newOperator);
    }


    function getGovernance() public view returns (address) {

        return _governance;
    }

    function getPendingGovernance() public view returns (address) {

        return _pendingGovernance;
    }

    function getOperator() public view returns (address) {

        return _operator;
    }


    function SCRAM() external onlyOperatorOrGovernance {

        _pause();
    }

    function unpause() external onlyGovernance {

        _unpause();
    }

    function emergencyWithdrawERC20ETH(address assetAddress)
        external
        whenPaused
        onlyGovernance
    {

        uint256 assetBalance;
        if (assetAddress == ETHER) {
            address self = address(this);
            assetBalance = self.balance;
            payable(msg.sender).transfer(assetBalance);
        } else {
            assetBalance = IERC20Upgradeable(assetAddress).balanceOf(
                address(this)
            );
            IERC20Upgradeable(assetAddress).safeTransfer(
                msg.sender,
                assetBalance
            );
        }
    }

    function emergencyBatchWithdrawERC721(
        address assetAddress,
        uint256[] calldata tokenIds,
        bool notSafe
    ) external whenPaused onlyGovernance {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (notSafe) {
                IERC721Upgradeable(assetAddress).transferFrom(
                    address(this),
                    msg.sender,
                    tokenIds[i]
                );
            } else {
                IERC721Upgradeable(assetAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenIds[i]
                );
            }
        }
    }

    function emergencyBatchWithdrawERC1155(
        address assetAddress,
        uint256[] calldata tokenIds
    ) external whenPaused onlyGovernance {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 assetBalance = IERC1155Upgradeable(assetAddress).balanceOf(
                address(this),
                tokenIds[i]
            );

            IERC1155Upgradeable(assetAddress).safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                assetBalance,
                ""
            );
        }
    }

    function emergencyExecute(
        address to,
        uint256 value,
        bytes memory data,
        bool isDelegateCall
    )
        external
        payable
        whenPaused
        onlyGovernance
        returns (bytes memory returnData)
    {

        if (isDelegateCall) {
            returnData = to.functionDelegateCall(data, "");
        } else {
            returnData = to.functionCallWithValue(data, value, "");
        }
    }

    uint256[50] private _gap;
}// MIT

pragma solidity >=0.8.7;

interface IERC721ReadOnlyProxy {


    function getWrapped() external view returns (address);



    function mint(address to, uint256 tokenId) external;


    function burn(uint256 tokenId) external;

}// MIT

pragma solidity >=0.8.7;


contract RentableStorageV1 {


    uint8 internal constant NOT_ALLOWED_TOKEN = 0;
    uint8 internal constant ERC20_TOKEN = 1;
    uint8 internal constant ERC1155_TOKEN = 2;

    uint16 internal constant BASE_FEE = 10000;


    mapping(address => mapping(uint256 => RentableTypes.RentalConditions))
        internal _rentalConditions;

    mapping(address => mapping(uint256 => uint256)) internal _expiresAt;

    mapping(address => address) internal _orentables;
    mapping(address => address) internal _wrentables;

    mapping(address => address) internal _libraries;

    mapping(address => uint8) internal _paymentTokenAllowlist;

    mapping(address => mapping(bytes4 => bool)) internal _proxyAllowList;

    address internal _walletFactory;

    mapping(address => address payable) internal _wallets;

    uint16 internal _fee;
    address payable internal _feeCollector;
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

pragma solidity >=0.8.7;

interface IERC721ExistExtension {

    function exists(uint256 tokenId) external view returns (bool);


    function ownerOf(uint256 tokenId, bool skipExpirationCheck)
        external
        view
        returns (address);

}// MIT

pragma solidity >=0.8.7;

interface ICollectionLibrary {


    function postDeposit(
        address tokenAddress,
        uint256 tokenId,
        address user
    ) external;


    function postList(
        address tokenAddress,
        uint256 tokenId,
        address user,
        uint256 minTimeDuration,
        uint256 maxTimeDuration,
        uint256 pricePerSecond
    ) external;


    function postRent(
        address tokenAddress,
        uint256 tokenId,
        uint256 duration,
        address from,
        address to,
        address payable toWallet
    ) external payable;


    function postExpireRental(
        address tokenAddress,
        uint256 tokenId,
        address from
    ) external payable;


    function postWTokenTransfer(
        address tokenAddress,
        uint256 tokenId,
        address from,
        address to,
        address payable toWallet
    ) external;


    function postOTokenTransfer(
        address tokenAddress,
        uint256 tokenId,
        address from,
        address to,
        address payable currentRenterWallet,
        bool rented
    ) external;

}// MIT
pragma solidity >=0.8.7;

interface IWalletFactory {

    function createWallet(address owner, address user)
        external
        returns (address payable wallet);

}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal onlyInitializing {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {

    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity >=0.8.7;



contract SimpleWallet is
    Initializable,
    OwnableUpgradeable,
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable
{


    using ECDSA for bytes32;
    using Address for address;


    bytes4 private constant ERC1271_IS_VALID_SIGNATURE =
        bytes4(keccak256("isValidSignature(bytes32,bytes)"));


    address private _user;


    constructor(address owner, address user) {
        _initialize(owner, user);
    }


    function initialize(address owner, address user) external {

        _initialize(owner, user);
    }

    function _initialize(address owner, address user) internal initializer {

        require(owner != address(0), "Owner cannot be null");

        __Ownable_init();
        _transferOwnership(owner);
        __ERC721Holder_init();
        __ERC1155Holder_init();

        _setUser(user);
    }



    function _setUser(address user) internal {

        _user = user;
    }


    function setUser(address user) external onlyOwner {

        _setUser(user);
    }


    function getUser() external view returns (address user) {

        return _user;
    }

    function isValidSignature(bytes32 msgHash, bytes memory signature)
        external
        view
        returns (bytes4)
    {

        address signer = msgHash.recover(signature);
        require(_user == signer, "Invalid signer");
        return ERC1271_IS_VALID_SIGNATURE;
    }


    function execute(
        address to,
        uint256 value,
        bytes memory data,
        bool isDelegateCall
    ) external payable onlyOwner returns (bytes memory returnData) {

        if (isDelegateCall) {
            returnData = to.functionDelegateCall(data, "");
        } else {
            returnData = to.functionCallWithValue(data, value, "");
        }
    }

    function withdrawETH(uint256 amount) external onlyOwner {

        Address.sendValue(payable(msg.sender), amount);
    }

    receive() external payable {}
}// MIT
pragma solidity >=0.8.7;





contract Rentable is
    IRentable,
    IRentableAdminEvents,
    IORentableHooks,
    IWRentableHooks,
    BaseSecurityInitializable,
    ReentrancyGuardUpgradeable,
    RentableStorageV1
{


    using Address for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;


    modifier onlyOTokenOwner(address tokenAddress, uint256 tokenId) {

        _getExistingORentableCheckOwnership(tokenAddress, tokenId, msg.sender);
        _;
    }

    modifier onlyOToken(address tokenAddress) {

        require(
            msg.sender == _orentables[tokenAddress],
            "Only proper ORentables allowed"
        );
        _;
    }

    modifier onlyWToken(address tokenAddress) {

        require(
            msg.sender == _wrentables[tokenAddress],
            "Only proper WRentables allowed"
        );
        _;
    }

    modifier onlyOTokenOrWToken(address tokenAddress) {

        require(
            msg.sender == _orentables[tokenAddress] ||
                msg.sender == _wrentables[tokenAddress],
            "Only w/o tokens are authorized"
        );
        _;
    }

    modifier skipIfLibraryNotSet(address tokenAddress) {

        if (_libraries[tokenAddress] != address(0)) {
            _;
        }
    }


    constructor(address governance, address operator) {
        _initialize(governance, operator);
    }


    function initialize(address governance, address operator) external {

        _initialize(governance, operator);
    }

    function _initialize(address governance, address operator)
        internal
        initializer
    {

        __BaseSecurityInitializable_init(governance, operator);
        __ReentrancyGuard_init();
    }


    function setLibrary(address tokenAddress, address libraryAddress)
        external
        onlyGovernance
    {

        address previousValue = _libraries[tokenAddress];

        _libraries[tokenAddress] = libraryAddress;

        emit LibraryChanged(tokenAddress, previousValue, libraryAddress);
    }

    function setORentable(address tokenAddress, address oRentable)
        external
        onlyGovernance
    {

        address previousValue = _orentables[tokenAddress];

        _orentables[tokenAddress] = oRentable;

        emit ORentableChanged(tokenAddress, previousValue, oRentable);
    }

    function setWRentable(address tokenAddress, address wRentable)
        external
        onlyGovernance
    {

        address previousValue = _wrentables[tokenAddress];

        _wrentables[tokenAddress] = wRentable;

        emit WRentableChanged(tokenAddress, previousValue, wRentable);
    }

    function setWalletFactory(address walletFactory) external onlyGovernance {

        require(walletFactory != address(0), "Wallet Factory cannot be 0");

        address previousWalletFactory = walletFactory;

        _walletFactory = walletFactory;

        emit WalletFactoryChanged(previousWalletFactory, walletFactory);
    }

    function setFee(uint16 newFee) external onlyGovernance {

        require(newFee <= BASE_FEE, "Fee greater than max value");

        uint16 previousFee = _fee;

        _fee = newFee;

        emit FeeChanged(previousFee, newFee);
    }

    function setFeeCollector(address payable newFeeCollector)
        external
        onlyGovernance
    {

        require(newFeeCollector != address(0), "FeeCollector cannot be null");

        address previousFeeCollector = _feeCollector;

        _feeCollector = newFeeCollector;

        emit FeeCollectorChanged(previousFeeCollector, newFeeCollector);
    }

    function enablePaymentToken(address paymentToken) external onlyGovernance {

        uint8 previousStatus = _paymentTokenAllowlist[paymentToken];

        _paymentTokenAllowlist[paymentToken] = ERC20_TOKEN;

        emit PaymentTokenAllowListChanged(
            paymentToken,
            previousStatus,
            ERC20_TOKEN
        );
    }

    function enable1155PaymentToken(address paymentToken)
        external
        onlyGovernance
    {

        uint8 previousStatus = _paymentTokenAllowlist[paymentToken];

        _paymentTokenAllowlist[paymentToken] = ERC1155_TOKEN;

        emit PaymentTokenAllowListChanged(
            paymentToken,
            previousStatus,
            ERC1155_TOKEN
        );
    }

    function disablePaymentToken(address paymentToken) external onlyGovernance {

        uint8 previousStatus = _paymentTokenAllowlist[paymentToken];

        _paymentTokenAllowlist[paymentToken] = NOT_ALLOWED_TOKEN;

        emit PaymentTokenAllowListChanged(
            paymentToken,
            previousStatus,
            NOT_ALLOWED_TOKEN
        );
    }

    function enableProxyCall(
        address caller,
        bytes4 selector,
        bool enabled
    ) external onlyGovernance {

        bool previousStatus = _proxyAllowList[caller][selector];

        _proxyAllowList[caller][selector] = enabled;

        emit ProxyCallAllowListChanged(
            caller,
            selector,
            previousStatus,
            enabled
        );
    }



    function _getExistingORentable(address tokenAddress)
        internal
        view
        returns (address oRentable)
    {

        oRentable = _orentables[tokenAddress];
        require(oRentable != address(0), "Token currently not supported");
    }

    function _getExistingORentableCheckOwnership(
        address tokenAddress,
        uint256 tokenId,
        address user
    ) internal view returns (address oRentable) {

        oRentable = _getExistingORentable(tokenAddress);

        require(
            IERC721Upgradeable(oRentable).ownerOf(tokenId) == user,
            "The token must be yours"
        );
    }

    function _isExpired(address tokenAddress, uint256 tokenId)
        internal
        view
        returns (bool)
    {

        return block.timestamp >= (_expiresAt[tokenAddress][tokenId]);
    }


    function getLibrary(address tokenAddress) external view returns (address) {

        return _libraries[tokenAddress];
    }

    function getORentable(address tokenAddress)
        external
        view
        returns (address)
    {

        return _orentables[tokenAddress];
    }

    function getWRentable(address tokenAddress)
        external
        view
        returns (address)
    {

        return _wrentables[tokenAddress];
    }

    function getWalletFactory() external view returns (address) {

        return _walletFactory;
    }

    function getFee() external view returns (uint16) {

        return _fee;
    }

    function getFeeCollector() external view returns (address payable) {

        return _feeCollector;
    }

    function getPaymentTokenAllowlist(address paymentTokenAddress)
        external
        view
        returns (uint8)
    {

        return _paymentTokenAllowlist[paymentTokenAddress];
    }

    function isEnabledProxyCall(address caller, bytes4 selector)
        external
        view
        returns (bool)
    {

        return _proxyAllowList[caller][selector];
    }

    function userWallet(address user)
        external
        view
        override
        returns (address payable)
    {

        return _wallets[user];
    }

    function rentalConditions(address tokenAddress, uint256 tokenId)
        external
        view
        override
        returns (RentableTypes.RentalConditions memory)
    {

        return _rentalConditions[tokenAddress][tokenId];
    }

    function expiresAt(address tokenAddress, uint256 tokenId)
        external
        view
        override
        returns (uint256)
    {

        return _expiresAt[tokenAddress][tokenId];
    }

    function isExpired(address tokenAddress, uint256 tokenId)
        external
        view
        override
        returns (bool)
    {

        return _isExpired(tokenAddress, tokenId);
    }



    function _createWalletForUser(address user)
        internal
        returns (address payable wallet)
    {

        wallet = IWalletFactory(_walletFactory).createWallet(
            address(this),
            user
        );

        require(
            wallet != address(0),
            "Wallet Factory is not returning a valid wallet address"
        );

        _wallets[user] = wallet;

        emit WalletCreated(user, wallet);

        return wallet;
    }

    function _getOrCreateWalletForUser(address user)
        internal
        returns (address payable wallet)
    {

        wallet = _wallets[user];

        if (wallet == address(0)) {
            wallet = _createWalletForUser(user);
        }

        return wallet;
    }

    function _deposit(
        address tokenAddress,
        uint256 tokenId,
        address to
    ) internal {

        address oRentable = _getExistingORentable(tokenAddress);

        require(
            IERC721Upgradeable(tokenAddress).ownerOf(tokenId) == address(this),
            "Token not deposited"
        );

        IERC721ReadOnlyProxy(oRentable).mint(to, tokenId);

        _postDeposit(tokenAddress, tokenId, to);

        emit Deposit(to, tokenAddress, tokenId);
    }

    function _depositAndList(
        address tokenAddress,
        uint256 tokenId,
        address to,
        RentableTypes.RentalConditions memory rc
    ) internal {

        _deposit(tokenAddress, tokenId, to);

        _createOrUpdateRentalConditions(to, tokenAddress, tokenId, rc);
    }

    function _createOrUpdateRentalConditions(
        address user,
        address tokenAddress,
        uint256 tokenId,
        RentableTypes.RentalConditions memory rc
    ) internal {

        require(
            _paymentTokenAllowlist[rc.paymentTokenAddress] != NOT_ALLOWED_TOKEN,
            "Not supported payment token"
        );

        require(
            rc.minTimeDuration <= rc.maxTimeDuration,
            "Minimum duration cannot be greater than maximum"
        );

        _rentalConditions[tokenAddress][tokenId] = rc;

        _postList(
            tokenAddress,
            tokenId,
            user,
            rc.minTimeDuration,
            rc.maxTimeDuration,
            rc.pricePerSecond
        );

        emit UpdateRentalConditions(
            tokenAddress,
            tokenId,
            rc.paymentTokenAddress,
            rc.paymentTokenId,
            rc.minTimeDuration,
            rc.maxTimeDuration,
            rc.pricePerSecond,
            rc.privateRenter
        );
    }

    function _deleteRentalConditions(address tokenAddress, uint256 tokenId)
        internal
    {

        (_rentalConditions[tokenAddress][tokenId]).maxTimeDuration = 0;
    }

    function _expireRental(
        address currentUserHolder,
        address oTokenOwner,
        address tokenAddress,
        uint256 tokenId,
        bool skipExistCheck
    ) internal returns (bool currentlyRented) {

        if (
            skipExistCheck ||
            IERC721ExistExtension(_wrentables[tokenAddress]).exists(tokenId)
        ) {
            if (_isExpired(tokenAddress, tokenId)) {
                address currentRentee = oTokenOwner == address(0)
                    ? IERC721Upgradeable(_orentables[tokenAddress]).ownerOf(
                        tokenId
                    )
                    : oTokenOwner;

                address wRentable = _wrentables[tokenAddress];
                address renter = currentUserHolder == address(0)
                    ? IERC721ExistExtension(wRentable).ownerOf(tokenId, true)
                    : currentUserHolder;
                address payable renterWallet = _wallets[renter];
                SimpleWallet(renterWallet).execute(
                    tokenAddress,
                    0,
                    abi.encodeWithSelector(
                        IERC721Upgradeable.transferFrom.selector, // we don't want to trigger onERC721Receiver
                        renterWallet,
                        address(this),
                        tokenId
                    ),
                    false
                );

                IERC721ReadOnlyProxy(_wrentables[tokenAddress]).burn(tokenId);

                _postExpireRental(tokenAddress, tokenId, currentRentee);
                emit RentEnds(tokenAddress, tokenId);
            } else {
                currentlyRented = true;
            }
        }

        return currentlyRented;
    }

    function _postDeposit(
        address tokenAddress,
        uint256 tokenId,
        address user
    ) internal skipIfLibraryNotSet(tokenAddress) {

        _libraries[tokenAddress].functionDelegateCall(
            abi.encodeWithSelector(
                ICollectionLibrary.postDeposit.selector,
                tokenAddress,
                tokenId,
                user
            ),
            ""
        );
    }

    function _postList(
        address tokenAddress,
        uint256 tokenId,
        address user,
        uint256 minTimeDuration,
        uint256 maxTimeDuration,
        uint256 pricePerSecond
    ) internal skipIfLibraryNotSet(tokenAddress) {

        _libraries[tokenAddress].functionDelegateCall(
            abi.encodeWithSelector(
                ICollectionLibrary.postList.selector,
                tokenAddress,
                tokenId,
                user,
                minTimeDuration,
                maxTimeDuration,
                pricePerSecond
            ),
            ""
        );
    }

    function _postRent(
        address tokenAddress,
        uint256 tokenId,
        uint256 duration,
        address from,
        address to,
        address toWallet
    ) internal skipIfLibraryNotSet(tokenAddress) {

        _libraries[tokenAddress].functionDelegateCall(
            abi.encodeWithSelector(
                ICollectionLibrary.postRent.selector,
                tokenAddress,
                tokenId,
                duration,
                from,
                to,
                toWallet
            ),
            ""
        );
    }

    function _postExpireRental(
        address tokenAddress,
        uint256 tokenId,
        address from
    ) internal skipIfLibraryNotSet(tokenAddress) {

        _libraries[tokenAddress].functionDelegateCall(
            abi.encodeWithSelector(
                ICollectionLibrary.postExpireRental.selector,
                tokenAddress,
                tokenId,
                from
            ),
            ""
        );
    }


    function createWalletForUser(address user)
        external
        override
        returns (address payable wallet)
    {

        require(
            user != address(0),
            "Cannot create a smart wallet for the void"
        );

        require(_wallets[user] == address(0), "Wallet already existing");

        return _createWalletForUser(user);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override whenNotPaused nonReentrant returns (bytes4) {

        if (data.length == 0) {
            _deposit(msg.sender, tokenId, from);
        } else {
            _depositAndList(
                msg.sender,
                tokenId,
                from,
                abi.decode(data, (RentableTypes.RentalConditions))
            );
        }

        return this.onERC721Received.selector;
    }

    function withdraw(address tokenAddress, uint256 tokenId)
        external
        override
        whenNotPaused
        nonReentrant
    {

        address user = msg.sender;
        address oRentable = _getExistingORentableCheckOwnership(
            tokenAddress,
            tokenId,
            user
        );

        require(
            !_expireRental(address(0), user, tokenAddress, tokenId, false),
            "Current rent still pending"
        );

        _deleteRentalConditions(tokenAddress, tokenId);

        IERC721ReadOnlyProxy(oRentable).burn(tokenId);

        IERC721Upgradeable(tokenAddress).safeTransferFrom(
            address(this),
            user,
            tokenId
        );

        emit Withdraw(tokenAddress, tokenId);
    }

    function createOrUpdateRentalConditions(
        address tokenAddress,
        uint256 tokenId,
        RentableTypes.RentalConditions calldata rc
    ) external override whenNotPaused onlyOTokenOwner(tokenAddress, tokenId) {

        _createOrUpdateRentalConditions(msg.sender, tokenAddress, tokenId, rc);
    }

    function deleteRentalConditions(address tokenAddress, uint256 tokenId)
        external
        override
        whenNotPaused
        onlyOTokenOwner(tokenAddress, tokenId)
    {

        _deleteRentalConditions(tokenAddress, tokenId);
    }

    function rent(
        address tokenAddress,
        uint256 tokenId,
        uint256 duration
    ) external payable override whenNotPaused nonReentrant {

        address oRentable = _getExistingORentable(tokenAddress);
        address payable rentee = payable(
            IERC721Upgradeable(oRentable).ownerOf(tokenId)
        );

        RentableTypes.RentalConditions memory rcs = _rentalConditions[
            tokenAddress
        ][tokenId];
        require(rcs.maxTimeDuration > 0, "Not available");

        require(
            !_expireRental(address(0), rentee, tokenAddress, tokenId, false),
            "Current rent still pending"
        );

        require(duration > 0, "Duration cannot be zero");

        require(
            duration >= rcs.minTimeDuration,
            "Duration lower than conditions"
        );

        require(
            duration <= rcs.maxTimeDuration,
            "Duration greater than conditions"
        );

        require(
            rcs.privateRenter == address(0) || rcs.privateRenter == msg.sender,
            "Rental reserved for another user"
        );

        uint256 eta = block.timestamp + duration;
        _expiresAt[tokenAddress][tokenId] = eta;
        IERC721ReadOnlyProxy(_wrentables[tokenAddress]).mint(
            msg.sender,
            tokenId
        );

        address renterWallet = _getOrCreateWalletForUser(msg.sender);
        IERC721Upgradeable(tokenAddress).safeTransferFrom(
            address(this),
            renterWallet,
            tokenId,
            ""
        );

        uint256 paymentQty = rcs.pricePerSecond * duration;
        uint256 feesForFeeCollector = (paymentQty * _fee) / BASE_FEE;
        uint256 feesForRentee = paymentQty - feesForFeeCollector;

        if (rcs.paymentTokenAddress == address(0)) {
            require(msg.value >= paymentQty, "Not enough funds");
            if (feesForFeeCollector > 0) {
                Address.sendValue(_feeCollector, feesForFeeCollector);
            }

            Address.sendValue(rentee, feesForRentee);

            if (msg.value > paymentQty) {
                Address.sendValue(payable(msg.sender), msg.value - paymentQty);
            }
        } else if (
            _paymentTokenAllowlist[rcs.paymentTokenAddress] == ERC20_TOKEN
        ) {
            if (feesForFeeCollector > 0) {
                IERC20Upgradeable(rcs.paymentTokenAddress).safeTransferFrom(
                    msg.sender,
                    _feeCollector,
                    feesForFeeCollector
                );
            }

            IERC20Upgradeable(rcs.paymentTokenAddress).safeTransferFrom(
                msg.sender,
                rentee,
                feesForRentee
            );
        } else {
            if (feesForFeeCollector > 0) {
                IERC1155Upgradeable(rcs.paymentTokenAddress).safeTransferFrom(
                    msg.sender,
                    _feeCollector,
                    rcs.paymentTokenId,
                    feesForFeeCollector,
                    ""
                );
            }

            IERC1155Upgradeable(rcs.paymentTokenAddress).safeTransferFrom(
                msg.sender,
                rentee,
                rcs.paymentTokenId,
                feesForRentee,
                ""
            );
        }

        _postRent(
            tokenAddress,
            tokenId,
            duration,
            rentee,
            msg.sender,
            renterWallet
        );

        emit Rent(
            rentee,
            msg.sender,
            tokenAddress,
            tokenId,
            rcs.paymentTokenAddress,
            rcs.paymentTokenId,
            eta
        );
    }

    function expireRental(address tokenAddress, uint256 tokenId)
        external
        override
        whenNotPaused
        returns (bool currentlyRented)
    {

        return
            _expireRental(address(0), address(0), tokenAddress, tokenId, false);
    }

    function expireRentals(
        address[] calldata tokenAddresses,
        uint256[] calldata tokenIds
    ) external whenNotPaused {

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            _expireRental(
                address(0),
                address(0),
                tokenAddresses[i],
                tokenIds[i],
                false
            );
        }
    }


    function afterOTokenTransfer(
        address tokenAddress,
        address from,
        address to,
        uint256 tokenId
    ) external override whenNotPaused onlyOToken(tokenAddress) {

        bool rented = _expireRental(
            address(0),
            from,
            tokenAddress,
            tokenId,
            false
        );

        address lib = _libraries[tokenAddress];
        if (lib != address(0)) {
            address wRentable = _wrentables[tokenAddress];
            address currentRenterWallet = IERC721ExistExtension(wRentable)
                .exists(tokenId)
                ? _wallets[IERC721Upgradeable(wRentable).ownerOf(tokenId)]
                : address(0);
            lib.functionDelegateCall(
                abi.encodeWithSelector(
                    ICollectionLibrary.postOTokenTransfer.selector,
                    tokenAddress,
                    tokenId,
                    from,
                    to,
                    currentRenterWallet,
                    rented
                ),
                ""
            );
        }
    }

    function afterWTokenTransfer(
        address tokenAddress,
        address from,
        address to,
        uint256 tokenId
    ) external override whenNotPaused onlyWToken(tokenAddress) {


        bool currentlyRented = _expireRental(
            from,
            address(0),
            tokenAddress,
            tokenId,
            true
        );

        if (currentlyRented) {
            address payable fromWallet = _wallets[from];
            SimpleWallet(fromWallet).execute(
                tokenAddress,
                0,
                abi.encodeWithSignature(
                    "safeTransferFrom(address,address,uint256)",
                    fromWallet,
                    _getOrCreateWalletForUser(to),
                    tokenId
                ),
                false
            );

            address lib = _libraries[tokenAddress];
            if (lib != address(0)) {
                lib.functionDelegateCall(
                    abi.encodeWithSelector(
                        ICollectionLibrary.postWTokenTransfer.selector,
                        tokenAddress,
                        tokenId,
                        from,
                        to,
                        _wallets[to]
                    ),
                    ""
                );
            }
        }
    }

    function proxyCall(
        address to,
        bytes4 selector,
        bytes memory data
    )
        external
        payable
        override
        whenNotPaused
        onlyOTokenOrWToken(to) // this implicitly checks `to` is the associated wrapped token
        returns (bytes memory)
    {

        require(
            _proxyAllowList[msg.sender][selector],
            "Proxy call unauthorized"
        );

        return
            to.functionCallWithValue(
                bytes.concat(selector, data),
                msg.value,
                ""
            );
    }
}