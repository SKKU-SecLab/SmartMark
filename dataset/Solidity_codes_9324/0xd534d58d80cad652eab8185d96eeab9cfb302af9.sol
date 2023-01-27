
pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

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

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

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

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
        return !AddressUpgradeable.isContract(address(this));
    }
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

pragma solidity 0.6.12;


interface IAddressRegistry {

    function xyz() external view returns (address);


    function bundleMarketplace() external view returns (address);


    function factory() external view returns (address);


    function privateFactory() external view returns (address);


    function artFactory() external view returns (address);


    function privateArtFactory() external view returns (address);


    function tokenRegistry() external view returns (address);


    function priceFeed() external view returns (address);

}

interface IBundleMarketplace {

    function validateItemSold(
        address,
        uint256,
        uint256
    ) external;

}

interface INFTFactory {

    function exists(address) external view returns (bool);

}

interface ITokenRegistry {

    function enabled(address) external view returns (bool);

}

interface IPriceFeed {

    function wFTM() external view returns (address);


    function getPrice(address) external view returns (int256, uint8);

}

interface IMarketplaceFeeEngine {

    function getMarketplaceFee(
        bytes32,
        address,
        uint256
    ) external view returns (address payable[] memory, uint256[] memory);

}

contract Marketplace is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeMath for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20 for IERC20;

    event ItemListed(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem,
        uint256 startingTime,
        uint256 deadline
    );
    event ItemSold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        int256 unitPrice,
        uint256 pricePerItem,
        bytes32 sourceId
    );
    event ItemUpdated(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        address payToken,
        uint256 newPrice,
        uint256 newDeadline
    );
    event ItemCanceled(
        address indexed owner,
        address indexed nft,
        uint256 tokenId
    );
    event OfferCreated(
        address indexed creator,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem,
        uint256 deadline
    );
    event OfferCanceled(
        address indexed creator,
        address indexed nft,
        uint256 tokenId
    );

    struct Listing {
        uint256 quantity;
        address payToken;
        uint256 pricePerItem;
        uint256 startingTime;
        uint256 deadline;
        bytes32 source;
    }

    struct Offer {
        IERC20 payToken;
        uint256 quantity;
        uint256 pricePerItem;
        uint256 deadline;
    }

    struct CollectionRoyalty {
        uint16 royalty;
        address creator;
        address feeRecipient;
    }

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;

    mapping(address => mapping(uint256 => address)) public minters;

    mapping(address => mapping(uint256 => uint16)) public royalties;

    mapping(address => mapping(uint256 => mapping(address => Listing)))
        public listings;

    mapping(address => mapping(uint256 => mapping(address => Offer)))
        public offers;

    uint16 public platformFee;

    address payable public feeReceipient;

    mapping(address => CollectionRoyalty) public collectionRoyalties;

    IAddressRegistry public addressRegistry;

    IMarketplaceFeeEngine public marketplaceFeeEngine;

    modifier onlyMarketplace() {

        require(
            address(addressRegistry.bundleMarketplace()) == _msgSender(),
            "sender must be bundle marketplace"
        );
        _;
    }

    modifier isListed(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) {

        Listing memory listing = listings[_nftAddress][_tokenId][_owner];
        require(listing.quantity > 0 && (listing.deadline == 0 || listing.deadline > _getNow()), "not listed item");
        _;
    }

    modifier notListed(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) {

        Listing memory listing = listings[_nftAddress][_tokenId][_owner];
        require(listing.quantity == 0 || (listing.deadline != 0 && listing.deadline <= _getNow()), "already listed");
        _;
    }

    modifier validListing(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) {

        Listing memory listedItem = listings[_nftAddress][_tokenId][_owner];

        _validOwner(_nftAddress, _tokenId, _owner, listedItem.quantity);

        require(_getNow() >= listedItem.startingTime, "item not buyable");
        _;
    }

    modifier offerExists(
        address _nftAddress,
        uint256 _tokenId,
        address _creator
    ) {

        Offer memory offer = offers[_nftAddress][_tokenId][_creator];
        require(
            offer.quantity > 0 && offer.deadline > _getNow(),
            "offer not exists or expired"
        );
        _;
    }

    modifier offerNotExists(
        address _nftAddress,
        uint256 _tokenId,
        address _creator
    ) {

        Offer memory offer = offers[_nftAddress][_tokenId][_creator];
        require(
            offer.quantity == 0 || offer.deadline <= _getNow(),
            "offer already created"
        );
        _;
    }

    function initialize(address payable _feeRecipient, uint16 _platformFee)
        external
        initializer
    {

        platformFee = _platformFee;
        feeReceipient = _feeRecipient;

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function listItem(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        address _payToken,
        uint256 _pricePerItem,
        uint256 _startingTime,
        uint256 _deadline,
        string calldata _source
    ) external notListed(_nftAddress, _tokenId, _msgSender()) {

        _listItem(
            _nftAddress,
            _tokenId,
            _quantity,
            _payToken,
            _pricePerItem,
            _startingTime,
            _deadline,
            _source
        );
    }

    function listItem(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        address _payToken,
        uint256 _pricePerItem,
        uint256 _startingTime,
        uint256 _deadline
    ) external notListed(_nftAddress, _tokenId, _msgSender()) {

        _listItem(_nftAddress, _tokenId, _quantity, _payToken, _pricePerItem, _startingTime, _deadline, "");
    }

    function listItem(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        address _payToken,
        uint256 _pricePerItem,
        uint256 _startingTime
    ) external notListed(_nftAddress, _tokenId, _msgSender()) {

        _listItem(_nftAddress, _tokenId, _quantity, _payToken, _pricePerItem, _startingTime, 0, "");
    }

    function _listItem(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        address _payToken,
        uint256 _pricePerItem,
        uint256 _startingTime,
        uint256 _deadline,
        string memory _source
    ) private {

        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721 nft = IERC721(_nftAddress);
            require(nft.ownerOf(_tokenId) == _msgSender(), "not owning item");
            require(
                nft.isApprovedForAll(_msgSender(), address(this)),
                "item not approved"
            );
        } else if (
            IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            IERC1155 nft = IERC1155(_nftAddress);
            require(
                nft.balanceOf(_msgSender(), _tokenId) >= _quantity,
                "must hold enough nfts"
            );
            require(
                nft.isApprovedForAll(_msgSender(), address(this)),
                "item not approved"
            );
        } else {
            revert("invalid nft address");
        }

        _validPayToken(_payToken);

        bytes32 sourceId = keccak256(abi.encodePacked(_source));
        listings[_nftAddress][_tokenId][_msgSender()] = Listing(
            _quantity,
            _payToken,
            _pricePerItem,
            _startingTime,
            _deadline,
            sourceId
        );
        emit ItemListed(
            _msgSender(),
            _nftAddress,
            _tokenId,
            _quantity,
            _payToken,
            _pricePerItem,
            _startingTime,
            _deadline
        );
    }

    function cancelListing(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
        isListed(_nftAddress, _tokenId, _msgSender())
    {

        _cancelListing(_nftAddress, _tokenId, _msgSender());
    }

    function updateListing(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _newPrice,
        uint256 _newDeadline
    ) external nonReentrant isListed(_nftAddress, _tokenId, _msgSender()) {

        _updateListing(_nftAddress, _tokenId, _payToken, _newPrice, _newDeadline);
    }

    function updateListing(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _newPrice
    ) external nonReentrant isListed(_nftAddress, _tokenId, _msgSender()) {

        _updateListing(_nftAddress, _tokenId, _payToken, _newPrice, 0);
    }

    function _updateListing(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _newPrice,
        uint256 _newDeadline
    ) private {

        Listing storage listedItem = listings[_nftAddress][_tokenId][
            _msgSender()
        ];

        _validOwner(_nftAddress, _tokenId, _msgSender(), listedItem.quantity);

        _validPayToken(_payToken);

        listedItem.payToken = _payToken;
        listedItem.pricePerItem = _newPrice;
        listedItem.deadline = _newDeadline;
        emit ItemUpdated(
            _msgSender(),
            _nftAddress,
            _tokenId,
            _payToken,
            _newPrice,
            _newDeadline
        );
    }

    function buyItem(
        address _nftAddress,
        uint256 _tokenId,
        address payable _owner
    )
        external
        payable
        nonReentrant
        isListed(_nftAddress, _tokenId, _owner)
        validListing(_nftAddress, _tokenId, _owner)
    {

        Listing memory listedItem = listings[_nftAddress][_tokenId][_owner];
        require(listedItem.payToken == address(0), "invalid pay token");
        require(
            msg.value >= listedItem.pricePerItem.mul(listedItem.quantity),
            "insufficient balance to buy"
        );

        _buyItem(_nftAddress, _tokenId, address(0), _owner);
    }

    function buyItem(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        address _owner
    )
        external
        nonReentrant
        isListed(_nftAddress, _tokenId, _owner)
        validListing(_nftAddress, _tokenId, _owner)
    {

        Listing memory listedItem = listings[_nftAddress][_tokenId][_owner];
        require(listedItem.payToken == _payToken, "invalid pay token");

        _buyItem(_nftAddress, _tokenId, _payToken, _owner);
    }

    function _buyItem(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        address _owner
    ) private {

        Listing memory listedItem = listings[_nftAddress][_tokenId][_owner];

        uint256 price = listedItem.pricePerItem.mul(listedItem.quantity);
        uint256 feeAmount = _distributeMarketplaceFee(
            listedItem.source,
            _nftAddress,
            price,
            _payToken
        );

        address minter = minters[_nftAddress][_tokenId];
        uint16 royalty = royalties[_nftAddress][_tokenId];
        if (minter != address(0) && royalty != 0) {
            uint256 royaltyFee = price.mul(royalty).div(10000);
            if (_payToken == address(0)) {
                (bool royaltyTransferSuccess, ) = payable(minter).call{
                    value: royaltyFee
                }("");
                require(royaltyTransferSuccess, "royalty fee transfer failed");
            } else {
                IERC20(_payToken).safeTransferFrom(
                    _msgSender(),
                    minter,
                    royaltyFee
                );
            }
            feeAmount = feeAmount.add(royaltyFee);
        } else {
            minter = collectionRoyalties[_nftAddress].feeRecipient;
            royalty = collectionRoyalties[_nftAddress].royalty;
            if (minter != address(0) && royalty != 0) {
                uint256 royaltyFee = price.mul(royalty).div(
                    10000
                );
                if (_payToken == address(0)) {
                    (bool royaltyTransferSuccess, ) = payable(minter).call{
                        value: royaltyFee
                    }("");
                    require(
                        royaltyTransferSuccess,
                        "royalty fee transfer failed"
                    );
                } else {
                    IERC20(_payToken).safeTransferFrom(
                        _msgSender(),
                        minter,
                        royaltyFee
                    );
                }
                feeAmount = feeAmount.add(royaltyFee);
            }
        }
        if (_payToken == address(0)) {
            (bool ownerTransferSuccess, ) = _owner.call{
                value: price.sub(feeAmount)
            }("");
            require(ownerTransferSuccess, "owner transfer failed");
        } else {
            IERC20(_payToken).safeTransferFrom(
                _msgSender(),
                _owner,
                price.sub(feeAmount)
            );
        }

        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721(_nftAddress).safeTransferFrom(
                _owner,
                _msgSender(),
                _tokenId
            );
        } else {
            IERC1155(_nftAddress).safeTransferFrom(
                _owner,
                _msgSender(),
                _tokenId,
                listedItem.quantity,
                bytes("")
            );
        }
        IBundleMarketplace(addressRegistry.bundleMarketplace())
            .validateItemSold(_nftAddress, _tokenId, listedItem.quantity);

        emit ItemSold(
            _owner,
            _msgSender(),
            _nftAddress,
            _tokenId,
            listedItem.quantity,
            _payToken,
            getPrice(_payToken),
            price.div(listedItem.quantity),
            listedItem.source
        );
        delete (listings[_nftAddress][_tokenId][_owner]);
    }

    function createOffer(
        address _nftAddress,
        uint256 _tokenId,
        IERC20 _payToken,
        uint256 _quantity,
        uint256 _pricePerItem,
        uint256 _deadline
    ) external offerNotExists(_nftAddress, _tokenId, _msgSender()) {

        require(
            IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721) ||
                IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155),
            "invalid nft address"
        );
        require(_deadline > _getNow(), "invalid expiration");

        _validPayToken(address(_payToken));

        offers[_nftAddress][_tokenId][_msgSender()] = Offer(
            _payToken,
            _quantity,
            _pricePerItem,
            _deadline
        );

        emit OfferCreated(
            _msgSender(),
            _nftAddress,
            _tokenId,
            _quantity,
            address(_payToken),
            _pricePerItem,
            _deadline
        );
    }

    function cancelOffer(address _nftAddress, uint256 _tokenId)
        external
        offerExists(_nftAddress, _tokenId, _msgSender())
    {

        delete (offers[_nftAddress][_tokenId][_msgSender()]);
        emit OfferCanceled(_msgSender(), _nftAddress, _tokenId);
    }

    function acceptOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _creator,
        string memory _source
    ) external nonReentrant offerExists(_nftAddress, _tokenId, _creator) {

        _acceptOffer(_nftAddress, _tokenId, _creator, _source);
    }

    function acceptOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _creator
    ) external nonReentrant offerExists(_nftAddress, _tokenId, _creator) {

        _acceptOffer(_nftAddress, _tokenId, _creator, "");
    }

    function _acceptOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _creator,
        string memory _source
    ) private {

        Offer memory offer = offers[_nftAddress][_tokenId][_creator];

        _validOwner(_nftAddress, _tokenId, _msgSender(), offer.quantity);

        uint256 price = offer.pricePerItem.mul(offer.quantity);
        uint256 feeAmount = _distributeMarketplaceFeeByName(
            _source,
            _nftAddress,
            price,
            address(offer.payToken)
        );
        uint256 royaltyFee;

        address minter = minters[_nftAddress][_tokenId];
        uint16 royalty = royalties[_nftAddress][_tokenId];
        if (minter != address(0) && royalty != 0) {
            royaltyFee = price.mul(royalty).div(10000);
            offer.payToken.safeTransferFrom(_creator, minter, royaltyFee);
            feeAmount = feeAmount.add(royaltyFee);
        } else {
            minter = collectionRoyalties[_nftAddress].feeRecipient;
            royalty = collectionRoyalties[_nftAddress].royalty;
            if (minter != address(0) && royalty != 0) {
                royaltyFee = price.mul(royalty).div(10000);
                offer.payToken.safeTransferFrom(_creator, minter, royaltyFee);
                feeAmount = feeAmount.add(royaltyFee);
            }
        }
        offer.payToken.safeTransferFrom(
            _creator,
            _msgSender(),
            price.sub(feeAmount)
        );

        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721(_nftAddress).safeTransferFrom(
                _msgSender(),
                _creator,
                _tokenId
            );
        } else {
            IERC1155(_nftAddress).safeTransferFrom(
                _msgSender(),
                _creator,
                _tokenId,
                offer.quantity,
                bytes("")
            );
        }
        IBundleMarketplace(addressRegistry.bundleMarketplace())
            .validateItemSold(_nftAddress, _tokenId, offer.quantity);
        delete (listings[_nftAddress][_tokenId][_msgSender()]);
        delete (offers[_nftAddress][_tokenId][_creator]);

        emit ItemSold(
            _msgSender(),
            _creator,
            _nftAddress,
            _tokenId,
            offer.quantity,
            address(offer.payToken),
            getPrice(address(offer.payToken)),
            offer.pricePerItem,
            keccak256(abi.encodePacked(_source))
        );
        emit OfferCanceled(_creator, _nftAddress, _tokenId);
    }

    function registerRoyalty(
        address _nftAddress,
        uint256 _tokenId,
        uint16 _royalty
    ) external {

        require(_royalty <= 10000, "invalid royalty");
        require(_isNFT(_nftAddress), "invalid nft address");

        _validOwner(_nftAddress, _tokenId, _msgSender(), 1);

        require(
            minters[_nftAddress][_tokenId] == address(0),
            "royalty already set"
        );
        minters[_nftAddress][_tokenId] = _msgSender();
        royalties[_nftAddress][_tokenId] = _royalty;
    }

    function registerCollectionRoyalty(
        address _nftAddress,
        address _creator,
        uint16 _royalty,
        address _feeRecipient
    ) external onlyOwner {

        require(_creator != address(0), "invalid creator address");
        require(_royalty <= 10000, "invalid royalty");
        require(
            _royalty == 0 || _feeRecipient != address(0),
            "invalid fee recipient address"
        );
        require(!_isNFT(_nftAddress), "invalid nft address");
        require(
            collectionRoyalties[_nftAddress].creator == address(0),
            "royalty already set"
        );
        collectionRoyalties[_nftAddress] = CollectionRoyalty(
            _royalty,
            _creator,
            _feeRecipient
        );
    }

    function initializeMarketplaceFeeEngine(address _marketplaceFeeEngine) external {

        require(address(marketplaceFeeEngine) == address(0x0), "non zero");
        marketplaceFeeEngine = IMarketplaceFeeEngine(_marketplaceFeeEngine);
    }

    function setMarketplaceFeeEngine(address _marketplaceFeeEngine)
        external
        onlyOwner
    {

        marketplaceFeeEngine = IMarketplaceFeeEngine(_marketplaceFeeEngine);
    }

    function _isNFT(address _nftAddress) internal view returns (bool) {

        return
            addressRegistry.xyz() == _nftAddress ||
            INFTFactory(addressRegistry.factory()).exists(_nftAddress) ||
            INFTFactory(addressRegistry.privateFactory()).exists(
                _nftAddress
            ) ||
            INFTFactory(addressRegistry.artFactory()).exists(
                _nftAddress
            ) ||
            INFTFactory(addressRegistry.privateArtFactory()).exists(
                _nftAddress
            );
    }

    function getPrice(address _payToken) public view returns (int256) {

        int256 unitPrice;
        uint8 decimals;
        if (_payToken == address(0)) {
            IPriceFeed priceFeed = IPriceFeed(
                addressRegistry.priceFeed()
            );
            (unitPrice, decimals) = priceFeed.getPrice(priceFeed.wFTM());
        } else {
            (unitPrice, decimals) = IPriceFeed(
                addressRegistry.priceFeed()
            ).getPrice(_payToken);
        }
        if (decimals < 18) {
            unitPrice = unitPrice * (int256(10)**(18 - decimals));
        } else {
            unitPrice = unitPrice / (int256(10)**(decimals - 18));
        }

        return unitPrice;
    }

    function updateAddressRegistry(address _registry) external onlyOwner {

        addressRegistry = IAddressRegistry(_registry);
    }

    function validateItemSold(
        address _nftAddress,
        uint256 _tokenId,
        address _seller,
        address _buyer
    ) external onlyMarketplace {

        Listing memory item = listings[_nftAddress][_tokenId][_seller];
        if (item.quantity > 0) {
            _cancelListing(_nftAddress, _tokenId, _seller);
        }
        delete (offers[_nftAddress][_tokenId][_buyer]);
        emit OfferCanceled(_buyer, _nftAddress, _tokenId);
    }


    function _getNow() internal view virtual returns (uint256) {

        return block.timestamp;
    }

    function _validPayToken(address _payToken) internal {

        require(
            _payToken == address(0) ||
                (addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(addressRegistry.tokenRegistry())
                        .enabled(_payToken)),
            "invalid pay token"
        );
    }

    function _validOwner(
      address _nftAddress,
      uint256 _tokenId,
      address _owner,
      uint256 quantity
    ) internal {

        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721 nft = IERC721(_nftAddress);
            require(nft.ownerOf(_tokenId) == _owner, "not owning item");
        } else if (
            IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            IERC1155 nft = IERC1155(_nftAddress);
            require(
                nft.balanceOf(_owner, _tokenId) >= quantity,
                "not owning item"
            );
        } else {
            revert("invalid nft address");
        }
    }

    function _cancelListing(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) private {

        Listing memory listedItem = listings[_nftAddress][_tokenId][_owner];

        _validOwner(_nftAddress, _tokenId, _owner, listedItem.quantity);

        delete (listings[_nftAddress][_tokenId][_owner]);
        emit ItemCanceled(_owner, _nftAddress, _tokenId);
    }

    function _distributeMarketplaceFeeByName(
        string memory _source,
        address _collection,
        uint256 _value,
        address _payToken
    ) private returns (uint256) {

        bytes32 id = keccak256(abi.encodePacked(_source));
        return _distributeMarketplaceFee(id, _collection, _value, _payToken);
    }

    function _distributeMarketplaceFee(
        bytes32 _source,
        address _collection,
        uint256 _value,
        address _payToken
    ) private returns (uint256) {

        (
            address payable[] memory recipients,
            uint256[] memory fees
        ) = marketplaceFeeEngine.getMarketplaceFee(
                _source,
                _collection,
                _value
            );
        uint256 feeAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            if (fees[i] == 0) {
                continue;
            }
            if (_payToken == address(0)) {
                (bool feeTransferSuccess, ) = recipients[i].call{
                    value: fees[i]
                }("");
                require(feeTransferSuccess, "fee transfer failed");
            } else {
                IERC20(_payToken).safeTransferFrom(
                    _msgSender(),
                    recipients[i],
                    fees[i]
                );
            }
            feeAmount = feeAmount.add(fees[i]);
        }
        return feeAmount;
    }
}