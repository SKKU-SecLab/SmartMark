



pragma solidity =0.8.11;


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


interface IERC2981 is IERC165 {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}

abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}

abstract contract ERC721Royalty is ERC2981, ERC721 {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }
}

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


contract Quik_Marketplace is Ownable {
    using SafeMath for uint256;

    event SaleSuccess(address nft, uint256 indexed tokenId, uint256 sellingPrice, address buyer, address seller);
    event AuctionCreated(address nft, uint256 indexed tokenId, uint256 startingPrice);
    event BidCreated(
        address nft,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bidAmount
    );
    event AuctionClaimed(address nft, uint256 tokenId, uint256 amount);
    event AuctionCancelled(address nft, uint256 indexed tokenId);

    address payable public marketPlaceOwner; //address of marketPlace owner, gets commissions on each sales
    uint256 public minimunBidPer10000; // minimum bid amount to be set
    address public tradeToken;
    mapping (address => bool) public verifiedNFT;

    uint256 ethTradeSellerFee = 500;
    uint256 quikTradeSellerFee = 250;

    struct Auction {
      address nftAddress;
      address seller;
      uint256 startingPrice;
      uint256 expiresAt; //auction expiry date.
      uint256 currentBidPrice; //Current max bidding price
      address currentBidder; //Current max bidder
      bool onAuction;
      bool quikTrade;
    }

    mapping (address => mapping(uint256 => Auction)) public TokenAuctions; // nftaddress -> tokenId -> Auction
    mapping (uint256 => bool) usedNonces;// checks if the nonces are there or not. 
    constructor( address _token) {
        tradeToken = _token;
        marketPlaceOwner = payable (msg.sender);
        minimunBidPer10000 = 250; // 2.5% minimunBid at initial
    }

    modifier IsTokenOwner(address _nft,uint256 _tokenId) {
        require(
            IERC721(_nft).ownerOf(_tokenId) == msg.sender,
            "MarketPlace: Caller is not the owner of this token."
        );
        _;
    }


    modifier checkPrice(uint256 _amount) {
        require(
            _amount > 10000,
            "MarketPlace: Amount should be minimum 10000 wei."
        );
        _;
    }

    modifier checkNFT(address _nft) {
      require(
        verifiedNFT[_nft],
        "Marketplace: NFT not verified for trade in the platform."
      );
      _;
    }

    function setMarketPlaceOwner(address _account) external onlyOwner{
        marketPlaceOwner = payable(_account);
    }


    function setNFTDomainToAuction(
        address _nft, 
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _expiresAt,
        bool _isQuikTrade 
    ) public 
    IsTokenOwner(_nft, _tokenId) 
    checkPrice(_startingPrice)
    checkNFT(_nft)
     {
        require(
            IERC721(_nft).isApprovedForAll(msg.sender, address(this)),
            "MarketPlace: Need to approve marketplace as its token operator"
        );
        require(
            _expiresAt > block.timestamp,
            "MarketPlace: Invalid token Expiry date"
        );

        require(
            TokenAuctions[_nft][_tokenId].onAuction == false,
            "MarketPlace: Token already on Auction"
        );
        require(
            IERC721(_nft).isApprovedForAll(msg.sender, address(this)),
            "MarketPlace: Minter need to approve marketplace as its token operator"
        );

        TokenAuctions[_nft][_tokenId] = Auction({
            nftAddress: _nft, 
            seller: msg.sender,
            startingPrice: _startingPrice,
            expiresAt: _expiresAt,
            currentBidPrice: 0,
            currentBidder: address(0),
            onAuction: true, 
            quikTrade: _isQuikTrade
        });

        emit AuctionCreated(_nft, _tokenId, _startingPrice);
    }

    function bidForAuction(address _nft, uint256 _tokenId, uint256 _tokenAmount) public payable{
        Auction storage act = TokenAuctions[_nft][_tokenId];
        require(
            act.onAuction == true && act.expiresAt > block.timestamp,
            "MarketPlace: Token expired from auction"
        );
        if(act.quikTrade){
          require(
                _tokenAmount >= act.startingPrice,
                "MarketPlace: Bid amount is lower than startingPrice"
          );

          if (act.currentBidPrice != 0) {
              require(
                  _tokenAmount >=
                      (act.currentBidPrice +
                          cutPer10000(minimunBidPer10000, act.currentBidPrice)),
                  "MarketPlace: Bid Amount is less than minimunBid required"
              );
          }
        }
        else{
          require(
                  msg.value >= act.startingPrice,
                  "MarketPlace: Bid amount is lower than startingPrice"
                );

          if (act.currentBidPrice != 0) {
              require(
                  msg.value >=
                      (act.currentBidPrice +
                          cutPer10000(minimunBidPer10000, act.currentBidPrice)),
                  "MarketPlace: Bid Amount is less than minimunBid required"
              );
            }
        }
      
        address currentBidder = act.currentBidder;
        uint256 prevBidPrice = act.currentBidPrice;
        act.currentBidPrice = 0;
        if(act.quikTrade){
          IERC20(tradeToken).transferFrom(msg.sender, address(this), _tokenAmount);
          
          if(currentBidder != address(0))
              IERC20(tradeToken).transfer(currentBidder, prevBidPrice);
        }
        else{
          if(currentBidder != address(0))
              withdrawETH(currentBidder, prevBidPrice);
        }

        if(act.quikTrade){
          act.currentBidPrice = _tokenAmount;
        }else{
          act.currentBidPrice = msg.value;
        }

        act.currentBidder = msg.sender;

        emit BidCreated(_nft, _tokenId, msg.sender, act.currentBidPrice);
    }



    function cancelAuction(address _nft, uint256 _tokenId)
        public
        IsTokenOwner(_nft, _tokenId)
    {
        Auction storage act = TokenAuctions[_nft][_tokenId];

        act.onAuction = false;
        if (act.currentBidder != address(0)) {
            address currentBidder = act.currentBidder;
            uint256 bidPrice = act.currentBidPrice;
            act.currentBidPrice = 0;
            if(act.quikTrade){
              IERC20(tradeToken).transfer(currentBidder, bidPrice);
            }
            else{
              withdrawETH(currentBidder, bidPrice);
            }
        }

        emit AuctionCancelled(_nft, _tokenId);
    }



    function ClaimNFTDomain(address _nft, uint256 _tokenId) public payable{
        Auction storage act = TokenAuctions[_nft][_tokenId];
        require(act.onAuction, "Marketplace: NFT Not in auction!");
        require(
            msg.sender == act.currentBidder,
            "MarketPlace: Caller is not a highest bidder"
        );
        require(
            act.expiresAt < block.timestamp,
            "MarketPlace: Token still on auction"
        );
        
        uint256 bidPrice = act.currentBidPrice;
        act.currentBidPrice = 0;
        act.onAuction = false;
        address tokenOwner = act.seller;

        (address minter, uint256 royaltyFee) = ERC721Royalty(_nft).royaltyInfo(_tokenId, bidPrice);
        uint256 sellerFee = calculateSellerFee(bidPrice, act.quikTrade);
  

        IERC721(_nft).transferFrom(tokenOwner, msg.sender, _tokenId);
        if(act.quikTrade){
          IERC20(tradeToken).transfer(marketPlaceOwner, sellerFee);
          IERC20(tradeToken).transfer(tokenOwner, bidPrice.sub(sellerFee).sub(royaltyFee));
          if(royaltyFee!=0){
              IERC20(tradeToken).transfer(minter, royaltyFee);
          }
        }else{
          withdrawETH(marketPlaceOwner, sellerFee);
          withdrawETH(tokenOwner, bidPrice.sub(sellerFee).sub(royaltyFee));
          if(royaltyFee!=0){
              withdrawETH(minter, royaltyFee);
          }
        }

        emit AuctionClaimed(_nft, _tokenId, bidPrice);
    }

    function setMinimumBidPercent(uint256 _minBidPer10000) public onlyOwner {
        require(
            _minBidPer10000 < 10000,
            "MarketPlace: minimun Bid cannot be more that 100%"
        );
        minimunBidPer10000 = _minBidPer10000;
    }

    function withdrawETH(address _reciever, uint256 _amount) internal{
      (bool os, ) = payable(_reciever).call{value: _amount}("");
      require(os, "Withdraw eth error!");
    }

    function rescueETH() external payable onlyOwner {
      (bool os, ) = payable(owner()).call{value: address(this).balance}("");
      require(os);
    }


    function calculateSellerFee(uint256 _amount, bool quikTrade) public view returns(uint256){
      if(quikTrade){
        return cutPer10000(quikTradeSellerFee, _amount);
      }else{
        return cutPer10000(ethTradeSellerFee, _amount);
      }
    }

    function cutPer10000(uint256 _cut, uint256 _total)
        internal
        pure
        returns (uint256)
    {
        uint256 cutAmount = _total.mul(_cut).div(10000);
        return cutAmount;
    }

    function updateEthTradeFees(uint256 fee) external onlyOwner{
      ethTradeSellerFee = fee;
    } 

    function updateQuikTradeFees(uint256 fee) external onlyOwner{
      quikTradeSellerFee = fee;
    }

    function updateTradeToken(address token) external onlyOwner{
      tradeToken = token;
    }

    function AddVerifiedNFTDomain(address[] memory nft) external onlyOwner{
      for(uint i=0; i< nft.length; i++){
        verifiedNFT[nft[i]] = true;
      }
    }

    function removeVerifiedNFTDomain(address[] memory nft) external onlyOwner{
      for(uint i=0; i< nft.length; i++){
        verifiedNFT[nft[i]] = false;
      }
    }

    function buyNFTDomain(
        uint256 tokenAmount, 
        uint256 nonce, 
        address nft, 
        uint256 tokenId, 
        address seller, 
        uint256 sellingPrice, 
        bool quikTrade,
        bytes memory sig
    ) 
    public 
    payable
    checkNFT(nft)
    {
        require(!usedNonces[nonce], "Marketplace: Nonce already used!");
        usedNonces[nonce] = true;

        uint256 sellerFee;
        address minter; 
        uint256 royaltyFee;

        require(returnSigner(  
            tokenAmount, 
            nonce, 
            nft, 
            tokenId, 
            seller, 
            sellingPrice, 
            quikTrade,
            sig
        ) == seller, "Marketplace: Signer not seller or wrong data");
      

        if(quikTrade){
            require(
            tokenAmount >= sellingPrice,
            "MarketPlace: Not Enough value to buy token!"
            );
        }
        else{
            require(
            msg.value >= sellingPrice,
            "MarketPlace: Not Enough value to buy token!"
            );
        }

        ( minter, royaltyFee) = ERC721Royalty(nft).royaltyInfo(tokenId, sellingPrice);
        sellerFee = calculateSellerFee(sellingPrice, quikTrade);
        
    	IERC721(nft).transferFrom(seller,  msg.sender, tokenId);
        {
            if(quikTrade){
                IERC20(tradeToken).transferFrom(msg.sender, marketPlaceOwner, sellerFee);
                IERC20(tradeToken).transferFrom(msg.sender, seller, sellingPrice.sub(sellerFee).sub(royaltyFee));
                if(royaltyFee!=0){
                    IERC20(tradeToken).transferFrom(msg.sender, minter, royaltyFee);
                }
            }else{
                withdrawETH(marketPlaceOwner, sellerFee);
                withdrawETH(seller, sellingPrice.sub(sellerFee).sub(royaltyFee));
                if(royaltyFee!=0){
                    withdrawETH(minter, royaltyFee);
                }
            }
        }
        if(quikTrade){
            emit SaleSuccess(nft, tokenId, tokenAmount, msg.sender, seller);
        }else{
            emit SaleSuccess(nft, tokenId, msg.value, msg.sender, seller);
        }
    }
    

    function returnSigner(
        uint256 tokenAmount, 
        uint256 nonce, 
        address nft, 
        uint256 tokenId, 
        address seller, 
        uint256 sellingPrice, 
        bool quikTrade,
        bytes memory sig
    ) internal view returns(address){
        uint chainId;
        assembly {
          chainId := chainid()
        }
        
        bytes32 eip712DomainHash;
        bytes32 hashStruct;
        bytes32 hash;
        eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Quik_Marketplace")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );  

        hashStruct = keccak256(
            abi.encode(
                keccak256("Sell(uint256 tokenAmount,uint256 nonce,address nft,uint256 tokenId,address seller,uint256 sellingPrice,bool quikTrade)"),
                tokenAmount, 
                nonce, 
                nft, 
                tokenId, 
                seller, 
                sellingPrice, 
                quikTrade
            )
        );

        hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));

        return recoverSigner(hash, sig);
    
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

}