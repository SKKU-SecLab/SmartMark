



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
}




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
}




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}




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
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




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

}




pragma solidity ^0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}




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
}




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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}




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

}




pragma solidity ^0.8.0;





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}


pragma solidity 0.8.10;









contract HexagonMarketplace is Ownable, ReentrancyGuard, ERC1155Holder {

    
    using SafeERC20 for IERC20;

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    uint constant BASIS_POINTS = 10000;

    uint public constant MAX_FEE = 1000;

    uint public minAuctionIncrement = 500;

    struct PaymentToken {

        address contractAddress;
        uint fee;
    }

    PaymentToken[] public paymentTokens;

    mapping(uint => uint) public claimableAmount;

    mapping(address => bool) authorizedAddresses;

    struct FeeAllocation {
        address wallet;
        uint percent;
    }

    FeeAllocation[] feeAllocations;

    struct Collection {
        address royaltyRecipient;
        uint royaltyFee;
        uint royaltiesEarned;
        uint currencyType;
        uint minPrice;
    }

    struct Signature {
        address contractAddress;
        address userAddress;
        uint256 tokenId;
        uint256 quantity;
        uint256 pricePerItem;
        uint256 expiry;
        uint256 nonce;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct AuctionData {
        uint tokenId;
        uint highestBid;
        uint expiry;
        uint minBid;
        uint quantity;
        address highestBidder;
        address collectionAddress;

    }

    mapping(address => mapping(uint => mapping(address => AuctionData))) public AuctionMapping;

    mapping(address => Collection) whitelistedCollections;

    mapping(bytes32 => bool) invalidSignatures;

    event CollectionWhitelisted(address nftAddress, address royaltyRecipient, uint royaltyFee, uint minPrice);

    event CollectionRemoved(address nftAddress);

    event CollectionUpdated(address nftAddress, address royaltyRecipient, uint royaltyFee, uint minPrice);

    event BidAccepted(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address indexed owner,
        address buyer,
        uint256 marketplaceFee,
        uint256 creatorFee,
        uint256 ownerRevenue,
        uint256 value,
        uint256 nonce
    );

    event BidCanceled(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 nonce
    );

    event ListingAccepted(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address indexed owner,
        address buyer,
        uint256 marketplaceFee,
        uint256 creatorFee,
        uint256 ownerRevenue,
        uint256 value,
        uint256 nonce
    );

    event ListingCanceled(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address indexed owner,
        uint256 nonce
    );

    event AuctionBid(address indexed collectionAddress, uint indexed tokenId, address indexed bidder, uint bid, address owner);

    event AuctionPlaced(address indexed collectionAddress, uint indexed tokenId, address indexed owner);

    event AuctionConcluded(address indexed collectionAddress, uint indexed tokenId, address indexed bidder, uint bid, address owner);

    bytes32 private DOMAIN_SEPARATOR;

    string private constant NAME = "HEXAGONMarketplace";

    bytes32 private constant ACCEPT_BID_TYPEHASH =
        keccak256("AcceptBid(address contractAddress,uint256 tokenId,address userAddress,uint256 pricePerItem,uint256 quantity,uint256 expiry,uint256 nonce)");

    bytes32 private constant ACCEPT_LISTING_TYPEHASH =
        keccak256("AcceptListing(address contractAddress,uint256 tokenId,address userAddress,uint256 pricePerItem,uint256 quantity,uint256 expiry,uint256 nonce)");

    function _initializeSignatures(uint chainId) internal {

       
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(NAME)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    modifier onlyWhitelisted(address nft) {

        require(whitelistedCollections[nft].royaltyFee > 0, "nft not whitelisted");
        _;
    }

    constructor(uint chainId) {
        _initializeSignatures(chainId);
    }

    function AcceptListing(Signature calldata listing) external nonReentrant onlyWhitelisted(listing.contractAddress) {


        bytes32 signature = getSignature(ACCEPT_LISTING_TYPEHASH, listing);

        require(recover(signature, listing.v, listing.r, listing.s) == listing.userAddress && invalidSignatures[signature] == false, "AcceptListing: Invalid Signature");

        invalidSignatures[signature] = true;
        
        require(listing.expiry > block.timestamp, "AcceptListing: EXPIRED");

        require(listing.pricePerItem >= whitelistedCollections[listing.contractAddress].minPrice, "Invalid Price");

        if (IERC165(listing.contractAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721(listing.contractAddress).transferFrom(listing.userAddress, msg.sender, listing.tokenId);
            require(listing.quantity == 1, "Only 1 nft can be sold");
        } else {
            IERC1155(listing.contractAddress).safeTransferFrom(listing.userAddress, msg.sender, listing.tokenId, listing.quantity, bytes(""));
            require(listing.quantity > 0, "Needs a quantity to sell");
        }

        uint256 value = listing.pricePerItem * listing.quantity;

        (uint256 marketplaceFee, uint256 creatorFee, uint256 ownerRevenue) = _distributeFunds(
            value,
            listing.userAddress,
            msg.sender,
            listing.contractAddress
        );

        emit ListingAccepted(
            listing.contractAddress,
            listing.tokenId,
            listing.userAddress,
            msg.sender,
            marketplaceFee,
            creatorFee,
            ownerRevenue,
            value,
            listing.nonce
        );
    }

    function CancelListing(Signature calldata listing) external {


        bytes32 signature = getSignature(ACCEPT_LISTING_TYPEHASH, listing);

        require(recover(signature, listing.v, listing.r, listing.s) == msg.sender, "CancelListing: INVALID_SIGNATURE");

        invalidSignatures[signature] = true;

        emit ListingCanceled(
            listing.contractAddress,
            listing.tokenId,
            msg.sender,
            listing.nonce
        );

    }

    function AcceptBid (Signature calldata bid) external nonReentrant onlyWhitelisted(bid.contractAddress) {

        bytes32 signature = getSignature(ACCEPT_BID_TYPEHASH, bid);

        require(recover(signature, bid.v, bid.r, bid.s) == bid.userAddress && invalidSignatures[signature] == false, "AcceptBid: Invalid Signature");

        invalidSignatures[signature] = true;
        
        require(bid.expiry > block.timestamp, "AcceptBid: EXPIRED");

        require(bid.pricePerItem >= whitelistedCollections[bid.contractAddress].minPrice, "Invalid Price");

        if (IERC165(bid.contractAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721(bid.contractAddress).safeTransferFrom(msg.sender, bid.userAddress, bid.tokenId);
            require(bid.quantity == 1, "Only 1 nft can be sold");
        } else {
            IERC1155(bid.contractAddress).safeTransferFrom(msg.sender, bid.userAddress, bid.tokenId, bid.quantity, bytes(""));
             require(bid.quantity > 0, "Needs a quantity to sell");
        }

        uint256 value = bid.pricePerItem * bid.quantity;

        (uint256 marketplaceFee, uint256 creatorFee, uint256 ownerRevenue) = _distributeFunds(
            value,
            msg.sender,
            bid.userAddress,
            bid.contractAddress
        );

        emit BidAccepted(
            bid.contractAddress,
            bid.tokenId,
            msg.sender,
            bid.userAddress,
            marketplaceFee,
            creatorFee,
            ownerRevenue,
            value,
            bid.nonce
        );
    }

    function CancelBid(Signature calldata bid) external {


        bytes32 signature = getSignature(ACCEPT_BID_TYPEHASH, bid);

        require(recover(signature, bid.v, bid.r, bid.s) == msg.sender, "CancelBid: INVALID_SIGNATURE");

        invalidSignatures[signature] = true;

        emit BidCanceled(
            bid.contractAddress,
            bid.tokenId,
            msg.sender,
            bid.nonce
        );
    }

    function _distributeFunds(
        uint256 _value,
        address _owner,
        address _sender,
        address _nftAddress
       
    ) internal returns(uint256 marketplaceFee, uint256 creatorFee, uint256 ownerRevenue){


        if(_value > 0) {

            Collection memory collection = whitelistedCollections[_nftAddress];

            PaymentToken memory paymentToken = paymentTokens[collection.currencyType];

            IERC20 token = IERC20(paymentToken.contractAddress);

            marketplaceFee = (_value * paymentToken.fee) / BASIS_POINTS;

            creatorFee = (_value * collection.royaltyFee) / BASIS_POINTS;


            if(marketplaceFee > 0) {

                if(_sender != address(this)) {

                    token.transferFrom(_sender, address(this), marketplaceFee);

                }

                claimableAmount[collection.currencyType] += marketplaceFee;

            }

            if(creatorFee > 0) {

                whitelistedCollections[_nftAddress].royaltiesEarned += creatorFee;
                
                token.transferFrom(_sender, collection.royaltyRecipient, creatorFee);

            }

            ownerRevenue = (_value - marketplaceFee) - creatorFee;

            token.transferFrom(_sender, _owner, ownerRevenue);

        }
    }
    

    function placeAuctionBid(address _collectionAddress, uint _tokenId, address _owner, uint _amount) external nonReentrant
    {


        require(msg.sender == tx.origin, "Contracts cannot place an bid");
        
        AuctionData memory auctionData = AuctionMapping[_collectionAddress][_tokenId][_owner];

        require(auctionData.quantity > 0, "Auction doesn't exist");

        require(auctionData.expiry > block.timestamp, "Auction is over");

        require(msg.sender != _owner, "Can't bid on your own item");

        uint highestBid = auctionData.highestBid;
        address highestBidder = auctionData.highestBidder;

        auctionData.highestBidder = msg.sender;
        auctionData.highestBid = _amount;

        AuctionMapping[_collectionAddress][_tokenId][_owner] = auctionData;

        Collection memory collection = whitelistedCollections[_collectionAddress];

        PaymentToken memory paymentToken = paymentTokens[collection.currencyType];

        IERC20 token = IERC20(paymentToken.contractAddress);

        if(highestBid > 0) {

            uint minIncrement = (highestBid * minAuctionIncrement) / BASIS_POINTS;

            require(_amount >= highestBid + minIncrement, "Amount needs to be more than last bid, plus increment");

            token.safeTransfer(highestBidder, highestBid);


        } else {

            require(_amount >= auctionData.minBid, "Amount needs to be more than the min bid");

        }

        token.transferFrom(msg.sender, address(this), _amount);


        emit AuctionBid(_collectionAddress, _tokenId, msg.sender, _amount, _owner);


    }

    function placeAuction(AuctionData memory _auctionData) external onlyWhitelisted(_auctionData.collectionAddress) nonReentrant {


        require(msg.sender == tx.origin, "Contracts cannot place an auction");

        require(_auctionData.expiry > block.timestamp, "Auction needs to have a duration");

        require(AuctionMapping[_auctionData.collectionAddress][_auctionData.tokenId][msg.sender].quantity == 0, "Auction already exists");

        require(_auctionData.minBid >= whitelistedCollections[_auctionData.collectionAddress].minPrice, "Invalid Price");

        AuctionMapping[_auctionData.collectionAddress][_auctionData.tokenId][msg.sender] = _auctionData;

        if (IERC165(_auctionData.collectionAddress).supportsInterface(INTERFACE_ID_ERC721)) {

            IERC721(_auctionData.collectionAddress).transferFrom(msg.sender, address(this), _auctionData.tokenId);
            require(_auctionData.quantity == 1, "Can't have more than 1 nft of this type");

            
        } else {
            
            IERC1155(_auctionData.collectionAddress).safeTransferFrom(msg.sender, address(this), _auctionData.tokenId, _auctionData.quantity, bytes(""));

            require(_auctionData.quantity > 0, "Quantity can't be zero");
        }

        emit AuctionPlaced(_auctionData.collectionAddress, _auctionData.tokenId, msg.sender);

    }

    function concludeAuction(address _collectionAddress, uint _tokenId, address _owner) external nonReentrant {


        AuctionData memory auctionData = AuctionMapping[_collectionAddress][_tokenId][_owner];

        require(auctionData.quantity > 0, "Auction doesn't exist");

        require(auctionData.expiry <= block.timestamp, "Auction isn't over");

        address nftReciever;

        if(auctionData.highestBid > 0) {

            nftReciever = auctionData.highestBidder;

            _distributeFunds(auctionData.highestBid, _owner, address(this), auctionData.collectionAddress);

        } else {

            nftReciever = _owner;

        }

        if (IERC165(auctionData.collectionAddress).supportsInterface(INTERFACE_ID_ERC721)) {

            IERC721(auctionData.collectionAddress).safeTransferFrom(address(this), nftReciever, auctionData.tokenId);

            
        } else {
            
            IERC1155(auctionData.collectionAddress).safeTransferFrom(address(this), nftReciever, auctionData.tokenId, auctionData.quantity, bytes(""));

        }

        delete AuctionMapping[_collectionAddress][_tokenId][_owner];

        emit AuctionConcluded(_collectionAddress, _tokenId, nftReciever, auctionData.highestBid, _owner);


    }


    function getSignature(bytes32 _TYPEHASH, Signature memory signature) internal view returns(bytes32) {


        return keccak256(
        abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(_TYPEHASH, signature.contractAddress, signature.tokenId, signature.userAddress, signature.pricePerItem, signature.quantity, signature.expiry, signature.nonce))
            )
        );
    }

    function getCollectionInfo(address _collectionAddress) external view returns (Collection memory) {

        return whitelistedCollections[_collectionAddress];
    }

    function getRoyaltiesGenerated(address _collectionAddress, uint _currencyType) external view returns (uint) {


        Collection memory collection = whitelistedCollections[_collectionAddress];

        if(collection.currencyType != _currencyType) {
            return 0;
        } else {
            return collection.royaltiesEarned;
        }

    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }


    function claimFees() external onlyOwner {


        FeeAllocation[] memory _feeAllocations = feeAllocations;

        require(_feeAllocations.length > 0, "Fee allocations not set");

        PaymentToken[] memory tokens = paymentTokens;

        require(tokens.length > 0, "No tokens set");

        for(uint i = 0; i < tokens.length; i++) {

            IERC20 token = IERC20(tokens[i].contractAddress);

            uint _claimableAmount = claimableAmount[i];

            if(_claimableAmount == 0) {
                continue;
            }

            for(uint j = 0; j < _feeAllocations.length; j++) {

                uint toClaim = (_claimableAmount * _feeAllocations[i].percent) / BASIS_POINTS;

                if(toClaim > 0) {

                    token.safeTransfer(_feeAllocations[i].wallet, toClaim);

                }

            }

            claimableAmount[i] = 0;

        }

    }

    function setPaymentToken(address _tokenAddress, uint256 _fee, uint256 _index) external onlyOwner {


        require(_tokenAddress != address(0), "Zero Address");

        require(_index <= paymentTokens.length, "index out of range");
        require(_fee <= MAX_FEE, "Attempting to set too high of a fee");

        IERC20(_tokenAddress).approve(address(this), 2**256 - 1);

        if(_index == paymentTokens.length) {

            paymentTokens.push(PaymentToken(_tokenAddress, _fee));

        } else {

            paymentTokens[_index].fee = _fee;
        }

    }

    function setApprovalForTokenTransfer(address _tokenAddress) external onlyOwner {


        IERC20(_tokenAddress).approve(address(this), 2**256 - 1);

    }

    function setFeeAllocations(address[] calldata wallets, uint[] calldata percents) external onlyOwner {


        require(wallets.length == percents.length, "wallets and percents need to be the same length");

        if(feeAllocations.length > 0) {
            delete feeAllocations;
        }

        uint totalPercent;

        for(uint i = 0; i < wallets.length; i++) {

            FeeAllocation memory feeAllocation = FeeAllocation(wallets[i], percents[i]);

            totalPercent += feeAllocation.percent;
           
            feeAllocations.push(feeAllocation);

        }

        require(totalPercent == BASIS_POINTS, "Total percent does not add to 100%");

    }

    function setAuthorizedAddress(address _authorizedAddress, bool value) external onlyOwner {

        authorizedAddresses[_authorizedAddress] = value;
    }

    function addToWhitelist(address _nft, address _royaltyRecipient, uint _royaltyFee, uint _currencyType, uint _minPrice) external onlyOwner {

        require(whitelistedCollections[_nft].royaltyRecipient == address(0), "nft already whitelisted");
        require(_royaltyRecipient != address(0), "Can't be zero address");
        require(_currencyType < paymentTokens.length, "payment token doesn't exist");
        whitelistedCollections[_nft] = Collection(_royaltyRecipient, _royaltyFee, 0, _currencyType, _minPrice);
        emit CollectionWhitelisted(_nft, _royaltyRecipient, _royaltyFee, _minPrice);
    }

    function changeMinAuctionPercentIncrement(uint _percentIncrement) external onlyOwner {


        require(_percentIncrement <= 1000, "Min auction percent can't be above 10%");

        minAuctionIncrement = _percentIncrement;

    }

    function removeFromWhitelist(address _nft) external onlyOwner onlyWhitelisted(_nft) {

        delete whitelistedCollections[_nft];
        emit CollectionRemoved(_nft);
    }

    function updateWhitelist(address _nftAddress, address _royaltyRecipient, uint _royaltyFee, uint _minPrice) external onlyWhitelisted(_nftAddress) {


        require(authorizedAddresses[msg.sender], "Only authorized addresses can call");

        require(_royaltyRecipient != address(0), "Can't be zero address");

        Collection storage _collection = whitelistedCollections[_nftAddress];

        _collection.royaltyFee = _royaltyFee;
        _collection.royaltyRecipient = _royaltyRecipient;
        _collection.minPrice = _minPrice;

        emit CollectionUpdated(_nftAddress, _royaltyRecipient, _royaltyFee, _minPrice);

    }
    
}