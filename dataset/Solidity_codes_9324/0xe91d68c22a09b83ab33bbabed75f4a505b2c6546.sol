
            

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




            

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




            

pragma solidity ^0.8.0;

interface IERC20 {

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
}




            

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

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




            

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

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

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}




            

pragma solidity ^0.8.0;


library SafeMath {

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

}




pragma solidity ^0.8.0;


interface ISingleNFT {

	function safeTransferFrom(address from, address to, uint256 tokenId) external;    

    function creatorOf(uint256 _tokenId) external view returns (address);

	function royalties(uint256 _tokenId) external view returns (uint256);        

}

contract SingleAuction is Ownable, ERC721Holder {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 constant public PERCENTS_DIVIDER = 100;
    uint256 constant public MIN_BID_INCREMENT_PERCENT = 3; // 3%
	uint256 public swapFee = 10;	
	address public feeAddress;
    uint256 public totalEarnedCoin = 0;
	uint256 public totalEarnedToken = 0;
    
    struct AuctionBid {
        address from;
        uint256 bidPrice;
    }

    struct Auction {
        uint256 auctionId;
        address collectionId;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        address tokenAdr;
		uint256 startPrice;
        address creator;
        address owner;
        bool active;       
    }

    Auction[] public auctions;
    
    mapping (uint256 => AuctionBid[]) public auctionBids;
    
    mapping (address => uint256[]) public ownedAuctions;
    
    event AuctionBidSuccess(address _from, Auction auction, uint256 price, uint256 _bidIndex);

    event AuctionCreated(Auction auction);

    event AuctionCanceled(Auction auction);

    event AuctionFinalized(address buyer, uint256 price, Auction auction);

    constructor (address _feeAddress) {		
		feeAddress = _feeAddress;
	}   
    
    function setFee(address _feeAddress) external onlyOwner {		

        feeAddress = _feeAddress;		
    }

    function createAuction(address _collectionId, uint256 _tokenId, address _tokenAdr, uint256 _startPrice, uint256 _startTime, uint256 _endTime) 
        onlyTokenOwner(_collectionId, _tokenId) public 
    {   

        require(block.timestamp < _endTime, "end timestamp have to be bigger than current time");
        
        ISingleNFT nft = ISingleNFT(_collectionId); 

        uint256 auctionId = auctions.length;
        Auction memory newAuction;
        newAuction.auctionId = auctionId;
        newAuction.collectionId = _collectionId;
        newAuction.tokenId = _tokenId;
        newAuction.startPrice = _startPrice;
        newAuction.tokenAdr = _tokenAdr;
        newAuction.startTime = _startTime;
        newAuction.endTime = _endTime;
        newAuction.owner = msg.sender;
        newAuction.creator = nft.creatorOf(_tokenId);
        newAuction.active = true;
        
        auctions.push(newAuction);        
        ownedAuctions[msg.sender].push(auctionId);
        
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);        
        emit AuctionCreated(newAuction);       
    }
    
    function finalizeAuction(uint256 _auctionId) public {

        Auction memory myAuction = auctions[_auctionId];
        uint256 bidsLength = auctionBids[_auctionId].length;
        require(msg.sender == myAuction.owner || msg.sender == owner(), "only auction owner can finalize");
        
        if(bidsLength == 0) {
            ISingleNFT(myAuction.collectionId).safeTransferFrom(address(this), myAuction.owner, myAuction.tokenId);
            auctions[_auctionId].active = false;           
            emit AuctionCanceled(auctions[_auctionId]);
        }else{
            AuctionBid memory lastBid = auctionBids[_auctionId][bidsLength - 1];

            address _creator = ISingleNFT(myAuction.collectionId).creatorOf(myAuction.tokenId);
            uint256 royalty = ISingleNFT(myAuction.collectionId).royalties(myAuction.tokenId);

            uint256 _feeValue = lastBid.bidPrice.mul(swapFee).div(PERCENTS_DIVIDER);
            uint256 _creatorValue = lastBid.bidPrice.mul(royalty).div(PERCENTS_DIVIDER);
            uint256 _sellerValue = lastBid.bidPrice.sub(_feeValue).sub(_creatorValue);
            
            if (myAuction.tokenAdr == address(0x0)) {
                
                payable(myAuction.owner).transfer(_sellerValue);
                payable(feeAddress).transfer(_feeValue);
                payable(_creator).transfer(_creatorValue);
                totalEarnedCoin = totalEarnedCoin + _feeValue;
            } else {
                IERC20 governanceToken = IERC20(myAuction.tokenAdr);

                require(governanceToken.transfer(myAuction.owner, _sellerValue), "transfer to seller failed");
                if(_feeValue > 0) require(governanceToken.transfer(feeAddress, _feeValue));
                if(_creatorValue > 0) require(governanceToken.transfer(_creator, _creatorValue));
                totalEarnedToken = totalEarnedToken + _feeValue;
            }
            
            ISingleNFT(myAuction.collectionId).safeTransferFrom(address(this), lastBid.from, myAuction.tokenId);		
            auctions[_auctionId].active = false;

            emit AuctionFinalized(lastBid.from,lastBid.bidPrice, myAuction);
        }
    }
    
    function bidOnAuction(uint256 _auctionId, uint256 amount) external payable {

        require(_auctionId <= auctions.length && auctions[_auctionId].auctionId == _auctionId, "Could not find item");
        Auction memory myAuction = auctions[_auctionId];
        require(myAuction.owner != msg.sender, "owner can not bid");
        require(myAuction.active, "not exist");

        require(block.timestamp < myAuction.endTime, "auction is over");
        require(block.timestamp >= myAuction.startTime, "auction is not started");

        uint256 bidsLength = auctionBids[_auctionId].length;
        uint256 tempAmount = myAuction.startPrice;
        AuctionBid memory lastBid;

        if( bidsLength > 0 ) {
            lastBid = auctionBids[_auctionId][bidsLength - 1];
            tempAmount = lastBid.bidPrice.mul(PERCENTS_DIVIDER + MIN_BID_INCREMENT_PERCENT).div(PERCENTS_DIVIDER);
        }

        if (myAuction.tokenAdr == address(0x0)) {
            require(msg.value >= tempAmount, "too small amount");
            require(msg.value >= amount, "too small balance");
            if( bidsLength > 0 ) {
                payable(lastBid.from).transfer(lastBid.bidPrice);
            }

        } else {
            require(amount >= tempAmount, "too small amount");

            IERC20 governanceToken = IERC20(myAuction.tokenAdr);
            require(governanceToken.transferFrom(msg.sender, address(this), amount), "transfer to contract failed");
        
            if( bidsLength > 0 ) {
                require(governanceToken.transfer(lastBid.from, lastBid.bidPrice), "refund to last bidder failed");
            }
        }        

        AuctionBid memory newBid;
        newBid.from = msg.sender;
        newBid.bidPrice = amount;
        auctionBids[_auctionId].push(newBid);
        emit AuctionBidSuccess(msg.sender, myAuction, newBid.bidPrice, bidsLength);
    }



    modifier AuctionExists(uint256 auctionId){

        require(auctionId <= auctions.length && auctions[auctionId].auctionId == auctionId, "Could not find item");
        _;
    }


    function getAuctionsLength() public view returns(uint) {

        return auctions.length;
    }
    
    function getBidsAmount(uint256 _auctionId) public view returns(uint) {

        return auctionBids[_auctionId].length;
    } 
    
    function getOwnedAuctions(address _owner) public view returns(uint[] memory) {

        uint[] memory ownedAllAuctions = ownedAuctions[_owner];
        return ownedAllAuctions;
    }
    
    function getCurrentBids(uint256 _auctionId) public view returns(uint256, address) {

        uint256 bidsLength = auctionBids[_auctionId].length;
        if (bidsLength >= 0) {
            AuctionBid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            return (lastBid.bidPrice, lastBid.from);
        }    
        return (0, address(0));
    }
    
    function getAuctionsAmount(address _owner) public view returns(uint) {

        return ownedAuctions[_owner].length;
    }

    modifier onlyAuctionOwner(uint256 _auctionId) {

        require(auctions[_auctionId].owner == msg.sender);
        _;
    }

    modifier onlyTokenOwner(address _collectionId, uint256 _tokenId) {

        address tokenOwner = IERC721(_collectionId).ownerOf(_tokenId);
        require(tokenOwner == msg.sender);
        _;
    }
}