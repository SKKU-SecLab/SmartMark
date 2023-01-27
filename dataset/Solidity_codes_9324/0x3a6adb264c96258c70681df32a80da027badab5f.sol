
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

}// MIT License
pragma solidity 0.8.10;


contract CryptoPhunksMarket {


    IERC721 phunksContract;     // instance of the CryptoPhunks contract
    address contractOwner;      // owner can change phunksContract

    struct Offer {
        bool isForSale;
        uint phunkIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
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
        if (initialPhunksAddress == address(0x0)) revert();
        phunksContract = IERC721(initialPhunksAddress);
        contractOwner = 0x25B331609e45c52eb3b069AbEb2F426D9985eF1f;
    }

    function phunksAddress() public view returns (address) {

      return address(phunksContract);
    }

    function setPhunksContract(address newPhunksAddress) public {

      if (msg.sender != contractOwner) revert();
      phunksContract = IERC721(newPhunksAddress);
    }

    function phunkNoLongerForSale(uint phunkIndex) public {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert();
        phunksOfferedForSale[phunkIndex] = Offer(false, phunkIndex, msg.sender, 0, address(0x0));
        emit PhunkNoLongerForSale(phunkIndex);
    }

    function offerPhunkForSale(uint phunkIndex, uint minSalePriceInWei) public {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert();
        phunksOfferedForSale[phunkIndex] = Offer(true, phunkIndex, msg.sender, minSalePriceInWei, address(0x0));
        emit PhunkOffered(phunkIndex, minSalePriceInWei, address(0x0));
    }

    function offerPhunkForSaleToAddress(uint phunkIndex, uint minSalePriceInWei, address toAddress) public {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert();
        if (phunksContract.getApproved(phunkIndex) != address(this)) revert();
        phunksOfferedForSale[phunkIndex] = Offer(true, phunkIndex, msg.sender, minSalePriceInWei, toAddress);
        emit PhunkOffered(phunkIndex, minSalePriceInWei, toAddress);
    }

    function buyPhunk(uint phunkIndex) payable public {

        if (phunkIndex >= 10000) revert();
        Offer memory offer = phunksOfferedForSale[phunkIndex];
        if (!offer.isForSale) revert();                // phunk not actually for sale
        if (offer.onlySellTo != address(0x0) && offer.onlySellTo != msg.sender) revert();  // phunk not supposed to be sold to this user
        if (msg.value < offer.minValue) revert();      // Didn't send enough ETH
        address seller = offer.seller;
        if (seller != phunksContract.ownerOf(phunkIndex)) revert(); // Seller no longer owner of phunk

        phunksContract.safeTransferFrom(seller, msg.sender, phunkIndex);
        phunkNoLongerForSale(phunkIndex);
        pendingWithdrawals[seller] += msg.value;
        emit PhunkBought(phunkIndex, msg.value, seller, msg.sender);

        Bid memory bid = phunkBids[phunkIndex];
        if (bid.bidder == msg.sender) {
            pendingWithdrawals[msg.sender] += bid.value;
            phunkBids[phunkIndex] = Bid(false, phunkIndex, address(0x0), 0);
        }
    }

    function withdraw() public {

        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function enterBidForPhunk(uint phunkIndex) payable public {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) == address(0x0)) revert();
        if (phunksContract.ownerOf(phunkIndex) == msg.sender) revert();
        if (msg.value == 0) revert();
        Bid memory existing = phunkBids[phunkIndex];
        if (msg.value <= existing.value) revert();
        if (existing.value > 0) {
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        phunkBids[phunkIndex] = Bid(true, phunkIndex, msg.sender, msg.value);
        emit PhunkBidEntered(phunkIndex, msg.value, msg.sender);
    }

    function acceptBidForPhunk(uint phunkIndex, uint minPrice) public {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) != msg.sender) revert();
        address seller = msg.sender;
        Bid memory bid = phunkBids[phunkIndex];
        if (bid.value == 0) revert();
        if (bid.value < minPrice) revert();

        address bidder = bid.bidder;
        phunksContract.safeTransferFrom(msg.sender, bidder, phunkIndex);
        phunksOfferedForSale[phunkIndex] = Offer(false, phunkIndex, bidder, 0, address(0x0));
        uint amount = bid.value;
        phunkBids[phunkIndex] = Bid(false, phunkIndex, address(0x0), 0);
        pendingWithdrawals[seller] += amount;
        emit PhunkBought(phunkIndex, bid.value, seller, bidder);
    }

    function withdrawBidForPhunk(uint phunkIndex) public {

        if (phunkIndex >= 10000) revert();
        if (phunksContract.ownerOf(phunkIndex) == address(0x0)) revert();
        if (phunksContract.ownerOf(phunkIndex) == msg.sender) revert();
        Bid memory bid = phunkBids[phunkIndex];
        if (bid.bidder != msg.sender) revert();
        emit PhunkBidWithdrawn(phunkIndex, bid.value, msg.sender);
        uint amount = bid.value;
        phunkBids[phunkIndex] = Bid(false, phunkIndex, address(0x0), 0);
        payable(msg.sender).transfer(amount);
    }

}