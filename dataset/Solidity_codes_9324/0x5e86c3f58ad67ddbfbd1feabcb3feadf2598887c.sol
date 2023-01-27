
pragma solidity ^0.6.8;
library EnumerableUintSet {

    struct Set {
        bytes32[] _values;
        uint256[] _collection;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value, uint256 savedValue) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._collection.push(savedValue);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastValue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastValue;
            set._values.pop();

            uint256 lastvalueAddress = set._collection[lastIndex];
            set._collection[toDeleteIndex] = lastvalueAddress;
            set._collection.pop();

            set._indexes[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
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
    function _collection(Set storage set) private view returns (uint256[] memory) {

        return set._collection;    
    }

    function _at(Set storage set, uint256 index) private view returns (uint256) {

        require(set._collection.length > index, "EnumerableSet: index out of bounds");
        return set._collection[index];
    }
    struct UintSet {
        Set _inner;
    }
    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)), value);
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }
    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }
    function collection(UintSet storage set) internal view returns (uint256[] memory) {

        return _collection(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return _at(set._inner, index);
    }
}
pragma solidity ^0.6.8;
library EnumerableSet {

    struct Set {
        bytes32[] _values;
        address[] _collection;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value, address addressValue) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._collection.push(addressValue);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastValue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastValue;
            set._values.pop();

            address lastvalueAddress = set._collection[lastIndex];
            set._collection[toDeleteIndex] = lastvalueAddress;
            set._collection.pop();

            set._indexes[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
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
    function _collection(Set storage set) private view returns (address[] memory) {

        return set._collection;    
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)), value);
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }
    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }
    function collection(AddressSet storage set) internal view returns (address[] memory) {

        return _collection(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }
}
pragma solidity ^0.6.8;
library SafeMath {

     function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

         if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

pragma solidity >=0.6.0 <0.8.0;

interface IBEP721Receiver {

    function onBEP721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity ^0.6.8;
interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.8;

interface IBEP165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.6.8;

interface IBEP721 is IBEP165 {

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

}

pragma solidity >=0.6.0 <0.8.0;
interface IBEP1155Receiver is IBEP165 {


    function onBEP1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onBEP1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}

pragma solidity >=0.6.2 <0.8.0;
interface IBEP1155 is IBEP165 {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.6.8;


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

library SafeBEP20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IBEP20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeBEP20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

interface STARSEASNFT {

	function mint(string memory tokenUri, uint256 royalties) external returns(uint256);

	function getNFTData(uint _tokenId) external view returns (address,uint256);

}


contract STARSEASAuction is IBEP721Receiver,IBEP1155Receiver,Ownable {

	 using SafeBEP20 for IBEP20;
	 
	uint256 private _weiDecimal = 18;
	uint256 private _divRate = 10000;
	
	bool private withMint = false;
	
	address private _WBNB;
	
    uint256 public platform_fee = 150; //1.5%
    address public feeReceiver;
	
    using SafeMath for uint256;
	
    using EnumerableUintSet for EnumerableUintSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Auction {
        address tokenAddress;
        address seller;
        address latestBidder;
        uint256 latestBidTime;
        uint256 deadline;
        uint256 price;
        uint256 amountReceive;
        uint256 bidCount;
        uint256 latestBidPrice;
    }
	
	struct SendTransaction {
        uint256 balanceBeforeSend;
        uint256 balanceAfterSend;
        uint256 amountReceive;
        uint256 sellerAmount;
        uint256 platformFeeAmount;
        uint256 royaltiesFeeAmount;
        uint256 royaltiesFee;
        address royaltiesFeeAddress;
    }

    mapping(uint256 => Auction) private _contractsPlusTokenIdsAuction;
    mapping(address => EnumerableUintSet.UintSet) private _contractsTokenIdsList;
    mapping(address => uint256) private _consumersDealFirstDate;
    mapping(uint256 => address) private _auctionIDtoSellerAddress;
	mapping(address => bool) public registeredToken;
	
	event TokenStatus(address tokenAddress, bool tokenStatus);
	event ListingSell(address seller, address tokenAddress, address contractNFT, uint tokenId, uint256 price, uint256 datetime);
	event SaleBuy(address buyer, address tokenAddress, address seller, address contractNFT, uint tokenId, uint256 price, uint256 datetime);
	event SaleBuy(address buyer,address seller, address contractNFT, uint tokenId, uint256 price, uint256 datetime);
	event ListingAuction(address seller, address tokenAddress, address contractNFT, uint256 tokenId,uint256 price,uint256 deadline, bool isBEP1155, uint256 datetime);
	event BidAuction(address buyer,address tokenAddress, address contractNFT, uint256 tokenId,uint256 price,uint256 deadline, bool isBEP1155,address seller, bool isDeal, uint256 datetime);
	event ListingAuctionCanceled(address seller, address tokenAddress, address contractNFT, uint256 tokenId,uint256 price,uint256 deadline, bool isBEP1155, uint256 datetime);
	event ListingAuctionFinished(address seller, address tokenAddress, address contractNFT, uint256 tokenId, uint256 datetime);
	
	receive() external payable {}
	
	constructor (
        address wbnb
		,address _feeReceiver
		,uint256 _platform_fee
    ) public {
        require(_platform_fee <= 500, "Max 5%");
		_WBNB = wbnb;
		platform_fee = _platform_fee;
		feeReceiver = _feeReceiver;
		
		registeredToken[_WBNB] = true;
    }
	
	function setRegisterdTokenStatus(address _tokenAddress, bool _tokenStatus) external onlyOwner{

		registeredToken[_tokenAddress] = _tokenStatus;
		
		emit TokenStatus(
			_tokenAddress
			, _tokenStatus
		);
	}
	
    function getNFTsAuctionList( address _contractNFT) public view returns (uint256[] memory) {

        return _contractsTokenIdsList[_contractNFT].collection();
    }
	
    function sellerAddressFor( uint256 _auctionID) public view returns (address) {

        return _auctionIDtoSellerAddress[_auctionID];
    }
	
    function getAuction(
        address _contractNFT,
        uint256 _tokenId
    ) public view returns
    (
        address tokenAddress,
        address seller,
        address latestBidder,
        uint256 latestBidTime,
        uint256 deadline,
        uint price,
        uint latestBidPrice
    ) {

        uint256 index = uint256(_contractNFT).add(_tokenId);
        return 
        (
            _contractsPlusTokenIdsAuction[index].tokenAddress,
            _contractsPlusTokenIdsAuction[index].seller,
            _contractsPlusTokenIdsAuction[index].latestBidder,
            _contractsPlusTokenIdsAuction[index].latestBidTime,
            _contractsPlusTokenIdsAuction[index].deadline,
            _contractsPlusTokenIdsAuction[index].price,
            _contractsPlusTokenIdsAuction[index].latestBidPrice
        );
    }

    function sellWithMint(
		string memory tokenUri
		, address _tokenAddress
		, address _contractNFT
		, uint256 _royalties
		, uint256 _price
		, bool _isBEP1155
	) public {

		require(registeredToken[_tokenAddress], "Token are not Active or not registered");
		
		STARSEASNFT _STARSEASNFT = STARSEASNFT(_contractNFT);
		uint256 _tokenId = _STARSEASNFT.mint(tokenUri,_royalties);
		
		withMint = true;
		sell(_tokenAddress, _contractNFT, _tokenId, _price,_isBEP1155);
		withMint = false;
	}
	
    function sell(
		address _tokenAddress
		, address _contractNFT
		, uint256 _tokenId
		, uint256 _price
		, bool _isBEP1155
	) public {

        require(!_contractsTokenIdsList[_contractNFT].contains(uint256(msg.sender).add(_tokenId)), "Auction is already created");
        require(registeredToken[_tokenAddress], "Token are not Active or not registered");
		
		if(!withMint){
			if (_isBEP1155) {
				IBEP1155(_contractNFT).safeTransferFrom( msg.sender, address(this), _tokenId,1, "0x0");
			} else {
				IBEP721(_contractNFT).transferFrom( msg.sender, address(this), _tokenId);
			}
		}
		
        Auction memory _auction = Auction({
            tokenAddress: _tokenAddress,
            seller: msg.sender,
            latestBidder: address(0),
            latestBidTime: 0,
            deadline: 0,
            price:_price,
            amountReceive:0,
			bidCount:0,
			latestBidPrice:0
        });
		
        _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)] = _auction;
        _auctionIDtoSellerAddress[uint256(msg.sender).add(_tokenId)] = msg.sender;
        _contractsTokenIdsList[_contractNFT].add(uint256(msg.sender).add(_tokenId));
		
		emit ListingSell(
			msg.sender
			, _tokenAddress
			, _contractNFT
			, _tokenId
			, _price
			, block.timestamp
		);
    }
		
    function buy (
        bool _isBEP1155
		, address _contractNFT
		, uint256 _tokenId
    ) external payable  {
        Auction storage auction = _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)];
        require(auction.seller != address(0), "Wrong seller address");
        require(auction.deadline == 0, "Item is on auction");
        SendTransaction memory safeSend;
        
		require(_contractsTokenIdsList[_contractNFT].contains(uint256(auction.seller).add(_tokenId)), "Auction is not created"); // BEP1155 can have more than 1 auction with same ID and , need mix tokenId with seller address
        
		if (_isBEP1155) {
            IBEP1155(_contractNFT).safeTransferFrom( address(this), msg.sender, _tokenId, 1, "0x0");
        } else {
            IBEP721(_contractNFT).safeTransferFrom( address(this), msg.sender, _tokenId);
        }
        
		STARSEASNFT _STARSEASNFT = STARSEASNFT(_contractNFT);
		
		(safeSend.royaltiesFeeAddress, safeSend.royaltiesFee) = _STARSEASNFT.getNFTData(_tokenId);
		
		if(auction.tokenAddress == _WBNB) {
			require(msg.value >= auction.price, "Price rate changed");
			if(msg.value > auction.price){
				payable(msg.sender).transfer(msg.value.sub(auction.price));
			}
			safeSend.amountReceive = auction.price;
		} else {
			safeSend.balanceBeforeSend = IBEP20(auction.tokenAddress).balanceOf(address(this));
			IBEP20(auction.tokenAddress).transferFrom(msg.sender, address(this), _getTokenAmount(auction.tokenAddress,auction.price));
			safeSend.balanceAfterSend = IBEP20(auction.tokenAddress).balanceOf(address(this));
			safeSend.amountReceive = safeSend.balanceAfterSend - safeSend.balanceBeforeSend;
			safeSend.amountReceive = _getReverseTokenAmount(auction.tokenAddress, safeSend.amountReceive);
		}
	
		safeSend.sellerAmount = safeSend.amountReceive;
		safeSend.platformFeeAmount = 0;
		safeSend.royaltiesFeeAmount = 0;
		
		if(platform_fee > 0){
			safeSend.platformFeeAmount = safeSend.amountReceive * platform_fee / _divRate;
			safeSend.sellerAmount -= safeSend.platformFeeAmount;
		}
		
		if(safeSend.royaltiesFee > 0){
			safeSend.royaltiesFeeAmount = safeSend.amountReceive  * safeSend.royaltiesFee / _divRate;
			safeSend.sellerAmount -= safeSend.royaltiesFeeAmount;
		}
		
		if(auction.tokenAddress == _WBNB) {
			payable(feeReceiver).transfer(safeSend.platformFeeAmount);
			payable(safeSend.royaltiesFeeAddress).transfer(safeSend.royaltiesFeeAmount);
			payable(auction.seller).transfer(safeSend.sellerAmount);
		} else {
			IBEP20(auction.tokenAddress).transfer(feeReceiver, _getTokenAmount(auction.tokenAddress, safeSend.platformFeeAmount));
			IBEP20(auction.tokenAddress).transfer(safeSend.royaltiesFeeAddress, _getTokenAmount(auction.tokenAddress, safeSend.royaltiesFeeAmount));
			IBEP20(auction.tokenAddress).transfer(auction.seller, _getTokenAmount(auction.tokenAddress, safeSend.sellerAmount));
		}
		
		emit SaleBuy(msg.sender,auction.tokenAddress,auction.seller, _contractNFT, _tokenId, auction.price, block.timestamp);
		
        _contractsTokenIdsList[_contractNFT].remove(uint256(auction.seller).add(_tokenId));
        delete _auctionIDtoSellerAddress[uint256(auction.seller).add(_tokenId)];
        delete _contractsPlusTokenIdsAuction[ uint256(_contractNFT).add(_tokenId)];
	}
    	
	function createAuctionWithMint(
		string memory tokenUri
		, address _tokenAddress
		, address _contractNFT
		, uint256 _royalties
		, uint256 _price
		, uint256 _deadline
		, bool _isBEP1155
	) public {

		require(registeredToken[_tokenAddress], "Token are not Active or not registered");
		
		STARSEASNFT _STARSEASNFT = STARSEASNFT(_contractNFT);
		uint256 _tokenId = _STARSEASNFT.mint(tokenUri,_royalties);
		
		withMint = true;
		createAuction(_tokenAddress, _contractNFT, _tokenId, _price, _deadline, _isBEP1155);
		withMint = false;
	}
	
    function createAuction(
		address _tokenAddress
		, address _contractNFT
		, uint256 _tokenId
		, uint256 _price
		, uint256 _deadline
		, bool _isBEP1155 
	) public {

        require(!_contractsTokenIdsList[_contractNFT].contains(uint256(msg.sender).add(_tokenId)), "Auction is already created");
		require(registeredToken[_tokenAddress], "Token are not Active or not registered");
		
		if(!withMint){
			if (_isBEP1155) {
				IBEP1155(_contractNFT).safeTransferFrom( msg.sender, address(this), _tokenId,1, "0x0");
			} else {
				IBEP721(_contractNFT).transferFrom( msg.sender, address(this), _tokenId);
			}
		}
		
        Auction memory _auction = Auction({
            tokenAddress: _tokenAddress,
            seller: msg.sender,
            latestBidder: address(0),
            latestBidTime: 0,
            deadline: _deadline,
            price:_price,
            amountReceive:0,
			bidCount:0,
			latestBidPrice:_price
        });
        _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)] = _auction;
        _auctionIDtoSellerAddress[uint256(msg.sender).add(_tokenId)] = msg.sender;
        _contractsTokenIdsList[_contractNFT].add(uint256(msg.sender).add(_tokenId));
        emit ListingAuction( msg.sender,  _tokenAddress, _contractNFT, _tokenId, _price, _deadline, _isBEP1155, block.timestamp);
    }
	
    function _bidWin (
        bool _isBEP1155,
        address _contractNFT,
        uint256 _tokenId
    ) private  {
		Auction storage auction = _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)];
        SendTransaction memory safeSend;
		
		STARSEASNFT _STARSEASNFT = STARSEASNFT(_contractNFT);
		
		(safeSend.royaltiesFeeAddress, safeSend.royaltiesFee) = _STARSEASNFT.getNFTData(_tokenId);
		
		safeSend.sellerAmount = auction.amountReceive;
		safeSend.platformFeeAmount = 0;
		safeSend.royaltiesFeeAmount = 0;
		
		if(platform_fee > 0){
			safeSend.platformFeeAmount = safeSend.amountReceive * platform_fee / _divRate;
			safeSend.sellerAmount -= safeSend.platformFeeAmount;
		}
		
		if(safeSend.royaltiesFee > 0){
			safeSend.royaltiesFeeAmount = safeSend.amountReceive  * safeSend.royaltiesFee / _divRate;
			safeSend.sellerAmount -= safeSend.royaltiesFeeAmount;
		}
		
		if(auction.tokenAddress == _WBNB) {
			payable(feeReceiver).transfer(safeSend.platformFeeAmount);
			payable(safeSend.royaltiesFeeAddress).transfer(safeSend.royaltiesFeeAmount);
			payable(auction.seller).transfer(safeSend.sellerAmount);
		} else {
			IBEP20(auction.tokenAddress).transfer(feeReceiver, _getTokenAmount(auction.tokenAddress, safeSend.platformFeeAmount));
			IBEP20(auction.tokenAddress).transfer(safeSend.royaltiesFeeAddress, _getTokenAmount(auction.tokenAddress, safeSend.royaltiesFeeAmount));
			IBEP20(auction.tokenAddress).transfer(auction.seller, _getTokenAmount(auction.tokenAddress, safeSend.sellerAmount));
		}
		
		if (_isBEP1155) {
            IBEP1155(_contractNFT).safeTransferFrom( address(this), auction.latestBidder, _tokenId, 1, "0x0");
        } else {
            IBEP721(_contractNFT).safeTransferFrom( address(this), auction.latestBidder, _tokenId);
        }
		
		emit SaleBuy(auction.latestBidder,auction.tokenAddress,auction.seller, _contractNFT, _tokenId, auction.latestBidPrice, block.timestamp);
		emit ListingAuctionFinished(auction.seller,auction.tokenAddress, _contractNFT,_tokenId, block.timestamp);
        
        _contractsTokenIdsList[_contractNFT].remove(uint256(auction.seller).add(_tokenId));
        delete _auctionIDtoSellerAddress[uint256(auction.seller).add(_tokenId)];
		delete _contractsPlusTokenIdsAuction[ uint256(_contractNFT).add(_tokenId)];
	}

    function bid(
		address _contractNFT
		,uint256 _tokenId
		,uint256 _price
		,bool _isBEP1155 
	) external payable returns (bool, uint256, address) {

        Auction storage auction = _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)];
        
		require(auction.seller != address(0), "Wrong seller address");
        require(block.timestamp <= auction.deadline, "Auction is ended");
        require(_contractsTokenIdsList[_contractNFT].contains(uint256(auction.seller).add(_tokenId)), "Auction is not created"); // BEP1155 can have more than 1 auction with same ID and , need mix tokenId with seller address
        
		uint256 balanceBeforeSendPrice = 0;
		uint256 balanceAfterSendPrice = 0;
		uint256 amountReceive = 0;
		
		if(auction.tokenAddress == _WBNB) {
			require(_price >= auction.latestBidPrice, "Price must be more than previous bid");
			if(msg.value > _price){
				payable(msg.sender).transfer(msg.value.sub(_price));
			}
			amountReceive = _price;
		} else {
			balanceBeforeSendPrice = IBEP20(auction.tokenAddress).balanceOf(address(this));
			IBEP20(auction.tokenAddress).transferFrom(msg.sender, address(this), _getTokenAmount(auction.tokenAddress,auction.price));
			balanceAfterSendPrice = IBEP20(auction.tokenAddress).balanceOf(address(this));
			amountReceive = balanceAfterSendPrice - balanceBeforeSendPrice;
			amountReceive = _getReverseTokenAmount(auction.tokenAddress, amountReceive);
		}
				
		if(auction.bidCount > 0){
			if(auction.tokenAddress == _WBNB) {
				payable(auction.latestBidder).transfer(auction.amountReceive);
			} else {
				IBEP20(auction.tokenAddress).transfer(auction.latestBidder, auction.amountReceive);
			}			
		}
		
		auction.latestBidPrice = _price;
		auction.latestBidder = msg.sender;
		auction.latestBidTime = block.timestamp;
		auction.bidCount += 1;
		auction.amountReceive = amountReceive;
		
		emit BidAuction(msg.sender, auction.tokenAddress, _contractNFT,_tokenId,_price,auction.deadline,_isBEP1155,auction.seller, false, block.timestamp);
		if (auction.latestBidder != address(0)) {
			return (false,auction.price,auction.latestBidder);
		}        
    }
    
    function _cancelAuction( address _contractNFT, uint256 _tokenId, address _sender, bool _isBEP1155, bool _isAdmin ) private {

        uint256 index = uint256(_contractNFT).add(_tokenId);
        Auction storage auction = _contractsPlusTokenIdsAuction[index];
        if (!_isAdmin) require(auction.seller == _sender, "Only seller can cancel");
        
		if(auction.bidCount > 0){
			if(auction.tokenAddress == _WBNB) {
				payable(auction.latestBidder).transfer(auction.amountReceive);
			} else {
				IBEP20(auction.tokenAddress).transfer(auction.latestBidder, auction.amountReceive);
			}			
		}
			
		if (_isBEP1155) {
            IBEP1155(_contractNFT).safeTransferFrom(address(this),auction.seller, _tokenId,1,"0x0");
        } else {
            IBEP721(_contractNFT).safeTransferFrom(address(this),auction.seller, _tokenId);
        }
		
        address auctionSeller = address(auction.seller);
        emit ListingAuctionCanceled(auction.seller, auction.tokenAddress, _contractNFT,_tokenId,auction.price,auction.deadline,_isBEP1155, block.timestamp);
        delete _contractsPlusTokenIdsAuction[index];
        delete _auctionIDtoSellerAddress[uint256(auctionSeller).add(_tokenId)];
        _contractsTokenIdsList[_contractNFT].remove(uint256(auctionSeller).add(_tokenId));
    }

    function adminCancelAuction( address _contractNFT, uint256 _tokenId, bool _isBEP1155) external onlyOwner {

        _cancelAuction( _contractNFT, _tokenId, msg.sender, _isBEP1155, true );
    }
	
    function cancelAuction( address _contractNFT, uint256 _tokenId, bool _isBEP1155) public {

        require(_contractsTokenIdsList[_contractNFT].contains(uint256(msg.sender).add(_tokenId)), "Auction is not created");
        _cancelAuction( _contractNFT, _tokenId, msg.sender, _isBEP1155, false );
    }
	
    function finishAuction( address _contractNFT, uint256 _tokenId, bool _isBEP1155 ) public {

        Auction storage auction = _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)];

		require(msg.sender == auction.seller || msg.sender == auction.latestBidder, "Auction is not seller or winner");

		if(msg.sender == auction.latestBidder){
			require(block.timestamp > auction.deadline && msg.sender == auction.latestBidder, "Auction still running");
		}
		
		require(auction.bidCount > 0, "No Bid, use cancel auction");
		
		_bidWin(
			_isBEP1155,
			_contractNFT,
			_tokenId
		);
    }
	
    function onBEP721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onBEP721Received.selector;
    }

    function onBEP1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata 
    )
    external
    override
    returns(bytes4)
    {

        return this.onBEP1155Received.selector;
    }

    function onBEP1155BatchReceived(
        address ,
        address ,
        uint256[] calldata,
        uint256[] calldata ,
        bytes calldata 
    )
    external
    override
    returns(bytes4)
    {

        return this.onBEP1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return this.supportsInterface(interfaceId);
    }
	
	function setPlatformFee(uint256 _platform_fee, address _feeReceiver) external onlyOwner{

		require(_platform_fee <= 500, "Max 5%");
		platform_fee = _platform_fee;
		feeReceiver = _feeReceiver;
	}
	
	function _getTokenAmount(address _tokenAddress, uint256 _amount) internal view returns (uint256 quotient) {

		IBEP20 tokenAddress = IBEP20(_tokenAddress);
		uint256 tokenDecimal = tokenAddress.decimals();
		uint256 decimalDiff;
		uint256 decimalDiffConverter;
		uint256 amount;
			
		if(_weiDecimal != tokenDecimal){
			if(_weiDecimal > tokenDecimal){
				decimalDiff = _weiDecimal - tokenDecimal;
				decimalDiffConverter = 10**decimalDiff;
				amount = _amount.div(decimalDiffConverter);
			} else {
				decimalDiff = tokenDecimal - _weiDecimal;
				decimalDiffConverter = 10**decimalDiff;
				amount = _amount.mul(decimalDiffConverter);
			}		
		} else {
			amount = _amount;
		}
		
		uint256 _quotient = amount;
		
		return (_quotient);
    }
	
	function _getReverseTokenAmount(address _tokenAddress, uint256 _amount) internal view returns (uint256 quotient) {

		IBEP20 tokenAddress = IBEP20(_tokenAddress);
		uint256 tokenDecimal = tokenAddress.decimals();
		uint256 decimalDiff;
		uint256 decimalDiffConverter;
		uint256 amount;
			
		if(_weiDecimal != tokenDecimal){
			if(_weiDecimal > tokenDecimal){
				decimalDiff = _weiDecimal - tokenDecimal;
				decimalDiffConverter = 10**decimalDiff;
				amount = _amount.mul(decimalDiffConverter);
			} else {
				decimalDiff = tokenDecimal - _weiDecimal;
				decimalDiffConverter = 10**decimalDiff;
				amount = _amount.div(decimalDiffConverter);
			}		
		} else {
			amount = _amount;
		}
		
		uint256 _quotient = amount;
		
		return (_quotient);
    }
}