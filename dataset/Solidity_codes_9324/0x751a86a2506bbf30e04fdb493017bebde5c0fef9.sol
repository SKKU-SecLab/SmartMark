
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

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
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

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

pragma solidity ^0.8.0;


contract SwapERC1155UAE is Ownable, Pausable, ReentrancyGuard, ERC1155Holder {

    uint256 private constant _TOKENS_PER_RECIPIENT = 1;
    bool private _batchReception;
    bool private _unlimitedReception;
    uint256 private _releaseTime;

    mapping(address => bool) private _whitelistedTokens;

    mapping(address => mapping(address => uint256)) private _receivedTokens;

    event AddToTokenWhitelist(address tokenAddress);
    event RemoveFromTokenWhitelist(address tokenAddress);

    event BatchReceptionUpdated(bool batchReception);

    event UnlimitedReceptionUpdated(bool unlimitedReception);

    event TokenReceived(address indexed account, address tokenAddress, uint256 tokenId, uint256 amount);
    event TokenWithdrawn(address indexed account, address tokenAddress, uint256 tokenId, uint256 amount);

    constructor(uint256 releaseTime_) {
        _batchReception = false;
        _unlimitedReception = false;
        _releaseTime = releaseTime_;
    }

    function isWhiteListedToken(address tokenAddress_) external view virtual returns (bool) {

        return _whitelistedTokens[tokenAddress_];
    }

    function isWhiteListedTokenBatch(address[] memory tokenAddresses_) external view virtual returns (bool[] memory) {

        bool[] memory batchWhiteListedTokens = new bool[](tokenAddresses_.length);
        for (uint256 i = 0; i < tokenAddresses_.length; ++i) {
            batchWhiteListedTokens[i] = _whitelistedTokens[tokenAddresses_[i]];
        }
        return batchWhiteListedTokens;
    }

    function batchReceptionAllowed() external view virtual returns (bool) {

        return _batchReception;
    }

    function unlimitedReceptionAllowed() external view virtual returns (bool) {

        return _unlimitedReception;
    }

    function tokenBalance(address tokenAddress_, uint256 tokenId_) public view virtual returns (uint256 balance) {

        if (tokenAddress_ != address(0)) {
            balance = IERC1155(tokenAddress_).balanceOf(address(this), tokenId_);
        }
        return balance;
    }

    function tokenBalanceBatch(address[] memory tokenAddresses_, uint256[] memory tokenIds_)
        public
        view
        virtual
        returns (uint256[] memory batchBalances)
    {

        require(tokenAddresses_.length == tokenIds_.length, "SwapERC1155UAE: arrays length mismatch");
        batchBalances = new uint256[](tokenAddresses_.length);
        for (uint256 i = 0; i < tokenAddresses_.length; ++i) {
            if (tokenAddresses_[i] != address(0)) {
                batchBalances[i] = IERC1155(tokenAddresses_[i]).balanceOf(address(this), tokenIds_[i]);
            }
        }
        return batchBalances;
    }

    function releaseTime() external view virtual returns (uint256) {

        return _releaseTime;
    }

    function checkBeforeClaimToken(
        address recipient_,
        address tokenAddress_,
        uint256 tokenId_
    ) external view virtual returns (bool)
    {

        bool releaseCheck = _releaseTime <= block.timestamp;
        bool balanceCheck = tokenBalance(tokenAddress_, tokenId_) > 0;
        bool recipientCheck = _unlimitedReception || _receivedTokens[recipient_][tokenAddress_] == 0;
        return !paused() && releaseCheck && _whitelistedTokens[tokenAddress_] && balanceCheck && recipientCheck;
    }

    function checkBeforeClaimTokenBatch(
        address recipient_,
        address[] memory tokenAddresses_,
        uint256[] memory tokenIds_
    ) external view virtual returns (bool[] memory)
    {

        require(tokenAddresses_.length == tokenIds_.length, "SwapERC1155UAE: arrays length mismatch");
        bool releaseCheck = _releaseTime <= block.timestamp;
        bool[] memory batchCheckBeforeClaim = new bool[](tokenAddresses_.length);
        uint256[] memory batchBalances = tokenBalanceBatch(tokenAddresses_, tokenIds_);
        for (uint256 i = 0; i < tokenAddresses_.length; ++i) {
            bool balanceCheck = batchBalances[i] > 0;
            bool recipientCheck = _unlimitedReception || _receivedTokens[recipient_][tokenAddresses_[i]] == 0;
            batchCheckBeforeClaim[i] = !paused() && releaseCheck && _batchReception && _whitelistedTokens[tokenAddresses_[i]] && balanceCheck && recipientCheck;
        }
        return batchCheckBeforeClaim;
    }

    function claimToken(
        address tokenAddress_,
        uint256 tokenId_,
        bytes calldata data_
    )
        external
        virtual
        nonReentrant
        whenNotPaused
    {

        require(_releaseTime <= block.timestamp, "SwapERC1155UAE: release time has not come");
        _claim(_msgSender(), tokenAddress_, tokenId_, data_);
    }

    function claimTokenBatch(
        address[] memory tokenAddresses_,
        uint256[] memory tokenIds_,
        bytes calldata data_
    )
        external
        virtual
        nonReentrant
        whenNotPaused
    {

        require(_batchReception, "SwapERC1155UAE: batch reception is not allowed");
        require(tokenAddresses_.length == tokenIds_.length, "SwapERC1155UAE: arrays length mismatch");
        require(_releaseTime <= block.timestamp, "SwapERC1155UAE: release time has not come");
        for (uint256 i = 0; i < tokenAddresses_.length; ++i) {
            _claim(_msgSender(), tokenAddresses_[i], tokenIds_[i], data_);
        }
    }

    function pause() external virtual onlyOwner {

        _pause();
    }

    function unpause() external virtual onlyOwner {

        _unpause();
    }

    function addToTokenWhitelist(address tokenAddress_) external virtual onlyOwner {

        require(tokenAddress_ != address(0), "SwapERC1155UAE: invalid tokenAddress");
        _whitelistedTokens[tokenAddress_] = true;
        emit AddToTokenWhitelist(tokenAddress_);
    }

    function removeFromTokenWhitelist(address tokenAddress_) external virtual onlyOwner {

        require(tokenAddress_ != address(0), "SwapERC1155UAE: invalid tokenAddress");
        _whitelistedTokens[tokenAddress_] = false;
        emit RemoveFromTokenWhitelist(tokenAddress_);
    }

    function updateBatchReception(bool batchReception_) external virtual onlyOwner {

        _batchReception = batchReception_;
        emit BatchReceptionUpdated(batchReception_);
    }

    function updateUnlimitedReception(bool unlimitedReception_) external virtual onlyOwner {

        _unlimitedReception = unlimitedReception_;
        emit UnlimitedReceptionUpdated(unlimitedReception_);
    }

    function withdrawToken(
        address tokenAddress_,
        uint256 tokenId_,
        uint256 amount_,
        bytes calldata data_
    )
        external
        virtual
        onlyOwner
        nonReentrant
    {

        _withdraw(_msgSender(), tokenAddress_, tokenId_, amount_, data_);
    }

    function _claim(
        address recipient_,
        address tokenAddress_,
        uint256 tokenId_,
        bytes calldata data_
    ) internal virtual {

        require(_whitelistedTokens[tokenAddress_], "SwapERC1155UAE: tokenAddress is not whitelisted");
        require(_unlimitedReception || _receivedTokens[recipient_][tokenAddress_] == 0, "SwapERC1155UAE: recipient has already received token");

        _receivedTokens[recipient_][tokenAddress_] += _TOKENS_PER_RECIPIENT;
        IERC1155(tokenAddress_).safeTransferFrom(address(this), recipient_, tokenId_, _TOKENS_PER_RECIPIENT, data_);

        emit TokenReceived(recipient_, tokenAddress_, tokenId_, _TOKENS_PER_RECIPIENT);
    }

    function _withdraw(
        address recipient_,
        address tokenAddress_,
        uint256 tokenId_,
        uint256 amount_,
        bytes calldata data_
    ) internal virtual {

        require(tokenAddress_ != address(0), "SwapERC1155UAE: invalid tokenAddress");

        IERC1155(tokenAddress_).safeTransferFrom(address(this), recipient_, tokenId_, amount_, data_);

        emit TokenWithdrawn(recipient_, tokenAddress_, tokenId_, amount_);
    }
}