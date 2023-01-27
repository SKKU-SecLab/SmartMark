

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}






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
}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


















interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}







interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





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
}









abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}







interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}







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





contract Auction  {


    address private _owner;
    string  private _assetHash;
    uint256 private _startTime;
    uint256 private _basePrice;
    uint256 private _totalAmount;
 
    bool private _canceled;
    bool private _finished;
    address private _highestBidder;
    address[] private _bidders;
    mapping(address => uint256) private _bidderBidPriceMappings;

    IERC20 private _token;

    constructor(address owner_,uint256 basePrice_, string memory assetHash_,IERC20 token_)   {
        require(basePrice_ > 0 , "Base price should be greater than 0" );
        _owner = owner_;
        _assetHash = assetHash_;
        _basePrice = basePrice_;
        _startTime = block.timestamp;
        _token = token_;
    }

    function placeBid(address bidder_, uint256 bidPrice_) public 
        onlyAfterStart
        onlyNotCanceled
        returns (bool )
    {
        uint256 newBid = _bidderBidPriceMappings[bidder_] + bidPrice_;
        uint256 _highestBid = _bidderBidPriceMappings[_highestBidder];
        _bidderBidPriceMappings[bidder_] = newBid;
        if(!_isBidderAlreadyPresent(bidder_)) {
            _bidders.push(bidder_);
        }
        if (newBid > _highestBid) {
            if (msg.sender != _highestBidder) {
                _highestBidder = bidder_;
            }
        }
        _totalAmount += bidPrice_;
        return true;
    }

    function validateBid(address bidder_, uint256 bidPrice_) public view returns (bool) {
        require (bidder_ != _owner,"Owner cannont place a bid");
        if(!_isBidderAlreadyPresent(bidder_)) {
            require  (bidPrice_ > _basePrice, "Bid amount less than base price") ;
        } else {
            require  (bidPrice_ > 0, "Bid amount should not be 0") ;
        }
         return true;
    }

    function _isBidderAlreadyPresent(address bidder_) internal view returns (bool ) {
        for (uint256 i; i < _bidders.length ; i++) {
                if(_bidders[i] == bidder_)
                    return true;
        }
        return false;
    }

    function getStartTime(address owner_) public view returns(uint256 ) {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        return _startTime;
    }

    function getTotalBidAmount(address owner_) public view returns(uint256 ) {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        return _totalAmount;
    }    

    function getCurrentHighestBid(address owner_) public view returns(uint256 ) {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        uint256 _highestBid = _bidderBidPriceMappings[_highestBidder];
        return _highestBid;
    }

    function cancelAuction(address owner_) public 
        onlyNotCanceled
        onlyNotFinished
        returns (bool )
    {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        _canceled = true;
        _startTime = 0;
        return true;
    }

    function getERC20() public view returns(IERC20 ) {
        return _token;
    } 

    function isActive() public view returns(bool ) {
        return (_startTime > 0 &&  !_finished && !_canceled);
    } 

    function getHighestBidder(address owner_) public view returns(address ) {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
         return _highestBidder;
    }

    function getAllBidders(address owner_) public view returns(address[] memory ) {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        return _bidders;
    }

    function getBidderBidPrice(address owner_,address bidder_) public view returns(uint256 ) {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        return _bidderBidPriceMappings[bidder_];
    }

    function auctionFinished(address owner_) public   {
        require(owner_ == _owner, "Only Auction owner can perform this operation");
        _finished = true;
        _canceled = false;
    }
   
    modifier onlyAfterStart {
        require(_startTime > 0, "Auction has not been started");
        _;

    }

    modifier onlyNotCanceled {
        require(_canceled != true, "Auction has been cancelled");
           _;
    }

    modifier onlyNotFinished {
        require(_finished != true, "Auction has been cancelled");
           _;
    }
}


contract UnicusNft is ERC721Enumerable, Ownable {
    using Strings for uint256;
    uint256 private _GAS_LIMIT = 80000000;
    uint256  private _COUNTER;
    mapping(string => Auction) private _assetHashAuctionMappings;
    mapping(uint256 => string) private _tokenIdAssetHashMappings;    
    uint256[] private _nfts;
    string[] private _ongoingAuctions;

    event EthPaymentSuccess(bool success,bytes data,address from, address to,uint256 amount);

    event ERC20PaymentSuccess(bool success,address from, address to,uint256 amount);

    event AuctionStarted(string hash,uint256 basePrice,uint256 timestamp);

    event BidPlaced(string hash,address bidder, uint bid, address highestBidder, uint highestBid);   

    event AuctionFinished(string hash,uint256 tokenId,address highestBidder, uint highestBid);

    event AuctionCancelled(string hash);    

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {

    }

    function auctionStart(string memory assetHash_,uint256 basePrice_) public onlyOwner {
        _auctionStart(assetHash_,basePrice_,IERC20(address(0)));
    }

    function auctionStartERC20(string memory assetHash_,uint256 basePrice_,IERC20 token_) public onlyOwner {
        _auctionStart(assetHash_,basePrice_,token_);
    }

    function placeBid(string memory assetHash_) public payable returns (bool){
        Auction auction = _assetHashAuctionMappings[assetHash_];
        require( address(auction) != address(0), "Auction not started for this asset");
        if(auction.validateBid(msg.sender,msg.value) == true) {
            auction.placeBid(msg.sender,msg.value);
            emit BidPlaced(assetHash_,msg.sender, msg.value, auction.getHighestBidder(owner()), auction.getCurrentHighestBid(owner()));
            return true;
        }
        return false;
    }

    function placeBidERC20(string memory assetHash_,uint256 amount_) public returns (bool){
        Auction auction = _assetHashAuctionMappings[assetHash_];
        require( address(auction) != address(0), "Auction not started for this asset");
        IERC20 token = auction.getERC20();
        require( address(token) != address(0), "This Auction does not support ERC20 tokens");
        if(auction.validateBid(msg.sender,amount_) == true) {
            _transferERC20(token,msg.sender,address(this), amount_);
            auction.placeBid(msg.sender,amount_);
            emit BidPlaced(assetHash_,msg.sender, amount_, auction.getHighestBidder(owner()), auction.getCurrentHighestBid(owner()));
            return true;
        }
        return false;
    } 

    function auctionEnd(string memory assetHash_) public onlyOwner returns (uint256 )  {
        Auction auction = _assetHashAuctionMappings[assetHash_];
        address winner = _returnBidAmountExceptWinner(auction);
        uint256 id = mint(winner);
        _nfts.push(id);
        _tokenIdAssetHashMappings[id] = assetHash_;
        auction.auctionFinished(msg.sender);
        _removeFinishedAuction(assetHash_);
        emit AuctionFinished(assetHash_,id,winner,auction.getCurrentHighestBid(owner()));
        return id;
    }

    function auctionCancel(string memory assetHash_) public onlyOwner returns (bool )  {
        Auction auction = _assetHashAuctionMappings[assetHash_];
        _returnBidAmount(auction);
        auction.cancelAuction(msg.sender);
        _removeFinishedAuction(assetHash_);
        delete _assetHashAuctionMappings[assetHash_];
        emit AuctionCancelled(assetHash_);
        return true;
    }

    function withdraw() public payable onlyOwner {
        uint256 withdrawBalance = address(this).balance - _getOngoingAuctionsBalances(false);
        _transferETH(msg.sender,withdrawBalance);
    }

    function withdrawERC20(IERC20 token_) public payable onlyOwner {
        uint256 balance = token_.balanceOf(address(this)) - _getOngoingAuctionsBalances(true);
        require(balance >= 0, "Insufficient balance.to transfer");
        _transferERC20(token_,address(this),msg.sender,balance);
    }  

    function ethBalance() public onlyOwner view returns(uint256) {
        return address(this).balance - _getOngoingAuctionsBalances(false);
    }

    function erc20Balance(IERC20 token_, address holder_) public onlyOwner view returns(uint256) {
        return token_.balanceOf(holder_) - _getOngoingAuctionsBalances(true);
    } 

    function erc20TotalBalance(IERC20 token_, address holder_) public onlyOwner view returns(uint256) {
        return token_.balanceOf(holder_) ;
    }        


    function _auctionStart(string memory assetHash_,uint256 basePrice_,IERC20 token_) internal  {
        require(address(_assetHashAuctionMappings[assetHash_]) == address(0) , "Auction already started for this Asset" );
        require(msg.sender == owner() , "Auction can be started only by owner" );
        Auction newAuction = new Auction(owner(),basePrice_,assetHash_,token_);
        _assetHashAuctionMappings[assetHash_] = newAuction;
        _ongoingAuctions.push(assetHash_);
        emit AuctionStarted(assetHash_,basePrice_,newAuction.getStartTime(msg.sender));
    }   
    
    function _approveTransferERC20(IERC20 token_,address from_, address to_,uint256 amount_) private onlyOwner returns (bool) {
        if(from_ == address(this)) {
            if(to_ != owner()) {
                token_.approve(to_,amount_);
                _validateTransferERC20(token_,from_,to_,amount_);
            }
            return token_.transfer(to_, amount_);
        }
        return false;
    }

    function _validateTransferERC20(IERC20 token_,address from_, address to_,uint256 amount_) private view {
         uint256 allowance_ = token_.allowance(from_, to_);
        require(allowance_ >= amount_, "Insufficient allowance....");
        require(token_.balanceOf(from_) >= amount_, "Insufficient balance.");
    }

    function _transferERC20(IERC20 token_,address from_, address to_,uint256 amount_) private   {
        require(amount_ > 0, "Amount to transfer should not be zero.");
        bool success;
        if(msg.sender == owner()) {
            success =_approveTransferERC20(token_,from_,to_,amount_);
        } else {
            success = token_.transferFrom(from_,to_, amount_);           
        }
        emit ERC20PaymentSuccess(success,from_, to_,amount_);        
        require(success);
    }  

    function _transferETH(address bidder_, uint256 amount_) private onlyOwner {
        require(amount_ > 0, "Amount to transfer should not be zero.");
        (bool success,bytes memory data ) = payable(bidder_).call{value:amount_,gas:_GAS_LIMIT}("");
        emit EthPaymentSuccess(success,data,address(this), bidder_, amount_);
        require(success, "Transfer failed.");
    }

    function _returnBidAmountExceptWinner(Auction auction_) private onlyOwner returns(address ){
        require( address(auction_) != address(0), "Auction not started for this asset");
        IERC20 token = auction_.getERC20();
        address winner = auction_.getHighestBidder(msg.sender);
        address[] memory bidders = auction_.getAllBidders(msg.sender);
        for (uint256 i; i < bidders.length ; i++) {
            address bidder = bidders[i];
            if(bidder != winner) {
                uint256 amount = auction_.getBidderBidPrice(msg.sender,bidder);
                if(amount > 0) {
                    if(address(token) != address(0)) {
                       _transferERC20(token,address(this),bidder,amount);
                    } else {
                        _transferETH(bidder,amount);
                    }
                }
            }
        }
        return winner;
    }

    function _returnBidAmount(Auction auction_) private onlyOwner {
        require( address(auction_) != address(0), "Auction not started for this asset");
        IERC20 token = auction_.getERC20();
        address[] memory bidders = auction_.getAllBidders(msg.sender);
        for (uint256 i; i < bidders.length ; i++) {
            address bidder = bidders[i];
            uint256 amount = auction_.getBidderBidPrice(msg.sender,bidder);
            if(amount > 0) {
                if(address(token) != address(0)) {
                    _transferERC20(token,address(this),bidder,amount);
                } else {
                    _transferETH(bidder,amount);
                }
            }
        }
    }

    function setGasLimit(uint256  gasLimit_) public  onlyOwner{
        _GAS_LIMIT = gasLimit_;
    }    

    function balanceOf() public view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    function mint(address winner_) internal returns (uint256 ){
        uint256 id = _COUNTER;
       _safeMint(winner_, id);
        _COUNTER++;
        return id;
    }

    function getNfts() public view returns (uint256[] memory) {
        return _nfts;
    }

    function walletOfOwner(address owner_)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(owner_);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner_, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId_)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId_),
        "ERC721Metadata: URI query for nonexistent token"
        );
        return _tokenIdAssetHashMappings[tokenId_];       
    }

    function _getOngoingAuctionsBalances(bool erc20_)  internal view onlyOwner returns(uint256) {
        uint256 totalAmount;
        for (uint256 i; i < _ongoingAuctions.length ; i++) {
            string memory hash = _ongoingAuctions[i];
            Auction auction = _assetHashAuctionMappings[hash];
            if(auction.isActive() ) {
                if(!erc20_) {
                    totalAmount += auction.getTotalBidAmount(msg.sender);
                } else {
                    if(_isAuctionERC(auction)) {
                        totalAmount += auction.getTotalBidAmount(msg.sender);
                    }
                }
            }
        }
        return totalAmount;
    }

    function _isAuctionERC(Auction auction_) private onlyOwner view returns(bool) {
        IERC20 token = auction_.getERC20();
        return (address(token) != address(0));
    }

    function _removeFinishedAuction(string memory assetHash_) private onlyOwner{
        int index = _getIndexOfOngoingAuction(assetHash_);
        if(index >= 0) {
            _ongoingAuctions[uint256(index)] = _ongoingAuctions[_ongoingAuctions.length-1];
            _ongoingAuctions.pop();
        }
    }

    function _getIndexOfOngoingAuction(string memory assetHash_) private view returns (int index_) {
        int index = -1;
        for (uint256 i; i < _ongoingAuctions.length ; i++) {
            string memory assetHash = _ongoingAuctions[i];
            if((keccak256(abi.encodePacked((assetHash))) == keccak256(abi.encodePacked((assetHash_))))) {
                return int(i);
            }
        }
        return index;
    }

}