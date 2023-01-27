
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
}// MIT License
pragma solidity 0.8.10;


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
}

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
}



contract CryptoPhunksMarket is ReentrancyGuard, Pausable, Ownable {


    IERC721 phunksContract;     // instance of the CryptoPhunks contract

    struct Offer {
        bool isForSale;
        uint phunkIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;
    }

    struct Bid {
        bool hasBid;
        uint phunkIndex;
        address bidder;
        uint value;
    }

    mapping (uint => Offer) public phunksOfferedForSale;

    mapping (uint => Bid) public phunkBids;

    mapping (address => uint) public pendingWithdrawals;

    event PhunkOffered(uint indexed phunkIndex, uint minValue, address indexed toAddress);
    event PhunkBidEntered(uint indexed phunkIndex, uint value, address indexed fromAddress);
    event PhunkBidWithdrawn(uint indexed phunkIndex, uint value, address indexed fromAddress);
    event PhunkBought(uint indexed phunkIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event PhunkNoLongerForSale(uint indexed phunkIndex);

    constructor(address initialPhunksAddress) {
        IERC721(initialPhunksAddress).balanceOf(address(this));
        phunksContract = IERC721(initialPhunksAddress);
    }

    function pause() public whenNotPaused onlyOwner {

        _pause();
    }

    function unpause() public whenPaused onlyOwner {

        _unpause();
    }

    function phunksAddress() public view returns (address) {

      return address(phunksContract);
    }

    function setPhunksContract(address newPhunksAddress) public onlyOwner {

      phunksContract = IERC721(newPhunksAddress);
    }

    function phunkNoLongerForSale(uint phunkIndex) public nonReentrant() {

        if (phunkIndex >= 10000) revert('token index not valid');
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert('you are not the owner of this token');
        phunksOfferedForSale[phunkIndex] = Offer(false, phunkIndex, msg.sender, 0, address(0x0));
        emit PhunkNoLongerForSale(phunkIndex);
    }

    function offerPhunkForSale(uint phunkIndex, uint minSalePriceInWei) public whenNotPaused nonReentrant()  {

        if (phunkIndex >= 10000) revert('token index not valid');
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert('you are not the owner of this token');
        phunksOfferedForSale[phunkIndex] = Offer(true, phunkIndex, msg.sender, minSalePriceInWei, address(0x0));
        emit PhunkOffered(phunkIndex, minSalePriceInWei, address(0x0));
    }

    function offerPhunkForSaleToAddress(uint phunkIndex, uint minSalePriceInWei, address toAddress) public whenNotPaused nonReentrant() {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert('you are not the owner of this token');
        phunksOfferedForSale[phunkIndex] = Offer(true, phunkIndex, msg.sender, minSalePriceInWei, toAddress);
        emit PhunkOffered(phunkIndex, minSalePriceInWei, toAddress);
    }
    

    function buyPhunk(uint phunkIndex) payable public whenNotPaused nonReentrant() {

        if (phunkIndex >= 10000) revert('token index not valid');
        Offer memory offer = phunksOfferedForSale[phunkIndex];
        if (!offer.isForSale) revert('phunk is not for sale'); // phunk not actually for sale
        if (offer.onlySellTo != address(0x0) && offer.onlySellTo != msg.sender) revert();                
        if (msg.value != offer.minValue) revert('not enough ether');          // Didn't send enough ETH
        address seller = offer.seller;
        if (seller == msg.sender) revert('seller == msg.sender');
        if (seller != phunksContract.ownerOf(phunkIndex)) revert('seller no longer owner of phunk'); // Seller no longer owner of phunk


        phunksOfferedForSale[phunkIndex] = Offer(false, phunkIndex, msg.sender, 0, address(0x0));
        phunksContract.safeTransferFrom(seller, msg.sender, phunkIndex);
        pendingWithdrawals[seller] += msg.value;
        emit PhunkBought(phunkIndex, msg.value, seller, msg.sender);

        Bid memory bid = phunkBids[phunkIndex];
        if (bid.bidder == msg.sender) {
            pendingWithdrawals[msg.sender] += bid.value;
            phunkBids[phunkIndex] = Bid(false, phunkIndex, address(0x0), 0);
        }
    }



    function withdraw() public nonReentrant() {

        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function enterBidForPhunk(uint phunkIndex) payable public whenNotPaused nonReentrant() {

        if (phunkIndex >= 10000) revert('token index not valid');
        if (phunksContract.ownerOf(phunkIndex) == msg.sender) revert('you already own this phunk');
        if (msg.value == 0) revert('cannot enter bid of zero');
        Bid memory existing = phunkBids[phunkIndex];
        if (msg.value <= existing.value) revert('your bid is too low');
        if (existing.value > 0) {
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        phunkBids[phunkIndex] = Bid(true, phunkIndex, msg.sender, msg.value);
        emit PhunkBidEntered(phunkIndex, msg.value, msg.sender);
    }

    function acceptBidForPhunk(uint phunkIndex, uint minPrice) public whenNotPaused nonReentrant() {

        if (phunkIndex >= 10000) revert('token index not valid');
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert('you do not own this token');
        address seller = msg.sender;
        Bid memory bid = phunkBids[phunkIndex];
        if (bid.value == 0) revert('cannot enter bid of zero');
        if (bid.value < minPrice) revert('your bid is too low');

        address bidder = bid.bidder;
        if (seller == bidder) revert('you already own this token');
        phunksOfferedForSale[phunkIndex] = Offer(false, phunkIndex, bidder, 0, address(0x0));
        uint amount = bid.value;
        phunkBids[phunkIndex] = Bid(false, phunkIndex, address(0x0), 0);
        phunksContract.safeTransferFrom(msg.sender, bidder, phunkIndex);
        pendingWithdrawals[seller] += amount;
        emit PhunkBought(phunkIndex, bid.value, seller, bidder);
    }

    function withdrawBidForPhunk(uint phunkIndex) public nonReentrant() {

        if (phunkIndex >= 10000) revert('token index not valid');
        Bid memory bid = phunkBids[phunkIndex];
        if (bid.bidder != msg.sender) revert('the bidder is not message sender');
        emit PhunkBidWithdrawn(phunkIndex, bid.value, msg.sender);
        uint amount = bid.value;
        phunkBids[phunkIndex] = Bid(false, phunkIndex, address(0x0), 0);
        payable(msg.sender).transfer(amount);
    }

}