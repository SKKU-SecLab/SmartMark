
pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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

library Address {

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT OR Apache-2.0
pragma solidity 0.8.12;




contract Marketplace is ReentrancyGuard, Ownable, Pausable {

    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 price;
    }

    event MarketItemCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address seller, address owner, uint256 price);
    event MarketSaleCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address seller, address owner, uint256 price);
    event MarketItemCancelled(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address seller);
    event SetSaleEnabled(bool saleEnabled);
    event SetNftPerAddressLimit(uint256 limit);
    event SetOnlyWhitelisted(bool onlyWhitelisted);
    event DisburseFee(address indexed feeCollector, uint256 amount);
    event SetFeeCollector(address indexed feeCollector);
    event WhitelistUsers();
    event DeleteWhitelistUsers();
    event ResetAddressMintedBalance(address indexed user);
    event SafePullETH(address indexed user, uint256 balance);
    event SafePullERC20(address indexed user, uint256 balance);
    event Pause();
    event Unpause();

    Counters.Counter private itemIds;
    Counters.Counter private itemsSold;

    address[] public whitelistedAddresses;

    uint256 public nftPerAddressLimit = 2;
    address payable feeCollector;
    bool public onlyWhitelisted = true;
    bool public saleEnabled = true;

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(address => uint256) public addressMintedBalance;


    constructor(address payable _feeCollector) {
        feeCollector = _feeCollector;
    }

    function toUint48(uint256 value) internal pure returns (uint48) {

        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    function getFeeCollector() external view returns (address) {

        return feeCollector;
    }

    function setSaleEnabled(bool _state) public onlyOwner {

        saleEnabled = _state;
        emit SetSaleEnabled(_state);
    }

    function getSaleState() external view returns (bool) {

        return saleEnabled;
    }

    function getItemIds() external view returns (uint48) {

        return toUint48(itemIds.current());
    }

    function getItemsForSaleAmount() external view returns (uint48) {

        return toUint48(itemIds.current() - itemsSold.current());
    }

    function setNftPerAddressLimit(uint256 _limit) public onlyOwner {

        nftPerAddressLimit = _limit;
        emit SetNftPerAddressLimit(_limit);
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {

        onlyWhitelisted = _state;
        emit SetOnlyWhitelisted(_state);
    }

    function getWhitelistState() external view returns (bool) {

        return onlyWhitelisted;
    }

    function getWhitelist() external view returns (address[] memory) {

        return whitelistedAddresses;
    }

    function isWhiteListed(address _user) public view returns (bool) {

        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function whitelistUsers(address[] calldata _users) public onlyOwner {

        delete whitelistedAddresses;
        whitelistedAddresses = _users;
        emit WhitelistUsers();
    }

    function deleteWhitelistUsers() public onlyOwner {

        delete whitelistedAddresses;
        emit DeleteWhitelistUsers();
    }

    function resetAddressMintedBalance(address _user) external onlyOwner {

        delete addressMintedBalance[_user];
        emit ResetAddressMintedBalance(_user);
    }

    function getMarketItem(uint256 marketItemId) external view returns (MarketItem memory) {

        return idToMarketItem[marketItemId];
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant whenNotPaused {

        require(price > 0, "Price must be at least 1 wei");

        uint256 itemId = itemIds.current();
        idToMarketItem[itemId] = MarketItem(itemId, nftContract, tokenId, payable(msg.sender), price);

        itemIds.increment();
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price);
    }

    function cancelMarketItem(uint256 itemId) external nonReentrant whenNotPaused {

        MarketItem memory item = idToMarketItem[itemId];
        require(item.seller != address(0), "market listing does not exist");
        require(item.seller == address(msg.sender), "not seller of this item");
        delete (idToMarketItem[itemId]);
        itemIds.decrement();
        IERC721(item.nftContract).safeTransferFrom(address(this), msg.sender, item.tokenId);
        emit MarketItemCancelled(itemId, item.nftContract, item.tokenId, msg.sender);
    }

    function createMarketSale(
        address nftContract,
        uint256 itemId,
        address to
    ) external payable nonReentrant whenNotPaused {

        require(saleEnabled, "sale is currently disabled");

        if (onlyWhitelisted) {
            require(isWhiteListed(msg.sender), "user is not whitelisted");
            require(addressMintedBalance[msg.sender] < nftPerAddressLimit, "max NFT per address exceeded");
            addressMintedBalance[msg.sender]++;
        }

        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Value sent does not match price");

        (bool sent, ) = idToMarketItem[itemId].seller.call{value: msg.value}("");
        require(sent, "Failed to send Ether"); // TODO : ignore failure to prevent DDOS attack ??? (MRM-01)

        idToMarketItem[itemId].seller = payable(address(0));
        itemsSold.increment();
        IERC721(nftContract).safeTransferFrom(address(this), to, tokenId);
        emit MarketItemCreated(itemId, nftContract, tokenId, idToMarketItem[itemId].seller, to, price);
    }

    function disburseFee(uint256 amount) external onlyOwner whenNotPaused {

        require(feeCollector != address(0), "No fee collector");
        require(amount <= address(this).balance, "Not enough fee amount");

        (bool sent, ) = feeCollector.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit DisburseFee(feeCollector, amount);
    }

    function setFeeCollector(address payable _feeCollector) external onlyOwner whenNotPaused {

        require(_feeCollector != payable(0), "Invalid fee collector address");
        feeCollector = _feeCollector;
        emit SetFeeCollector(_feeCollector);
    }

    function fetchMarketItems() external view returns (MarketItem[] memory) {

        uint256 totalItemCount = itemIds.current();
        uint256 itemCount;
        uint256 currentIndex;

        itemCount = totalItemCount - itemsSold.current();

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i].seller != address(0)) {
                items[currentIndex++] = idToMarketItem[i];
            }
        }

        return items;
    }

    function fetchMyNFTs() external view returns (MarketItem[] memory) {

        uint256 totalItemCount = itemIds.current();
        uint256 itemCount;
        uint256 currentIndex;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i].seller == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i].seller == msg.sender) {
                items[currentIndex++] = idToMarketItem[i];
            }
        }

        return items;
    }


    function safePullETH() external onlyOwner whenPaused {

        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        emit SafePullETH(msg.sender, balance);
    }

    function safePullERC20(address erc20) external onlyOwner {

        uint256 balance = IERC20(erc20).balanceOf(address(this));
        IERC20(erc20).safeTransfer(msg.sender, balance);
        emit SafePullERC20(msg.sender, balance);
    }

    function pause() external onlyOwner {

        _pause();
        emit Pause();
    }

    function unpause() external onlyOwner {

        _unpause();
        emit Unpause();
    }
}