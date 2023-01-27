




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
    address private _rol;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();
        _rol = _msgSender();
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender() || _rol == _msgSender(), "Ownable: caller is not the owner");
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




pragma solidity ^0.8.0;

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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




pragma solidity ^0.8.0;








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



pragma solidity ^0.8.0;


contract SpectraNFT is ERC721 {

    uint256 _tokenCounter;

    mapping(string => uint256) _getNFTId;
    mapping(uint256 => string) _uriFromId;

    constructor() ERC721("Spectra NFT", "SPCNFT") {
        _tokenCounter = 0;
    }

    function mintNFT(string memory _tokenHash) external payable returns (uint256) {
        _mint(msg.sender, _tokenCounter);
        _getNFTId[_tokenHash] = _tokenCounter;
        _setTokenUri(_tokenCounter, _tokenHash);
        _tokenCounter++;
        return _tokenCounter;
    }

    function tranferNFT(address _from, address _to, string memory _tokenHash) external payable {
        transferFrom(_from, _to, _getNFTId[_tokenHash]);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        super.tokenURI(_tokenId);
        return _uriFromId[_tokenId];
    }

    function _setTokenUri(uint256 _tokenId, string memory _uri) internal {
        _uriFromId[_tokenId] = _uri;
    }
}


pragma solidity ^ 0.8.0;




contract SaleManager is Ownable {

    uint8 constant IS_RESELLER = 1;
    uint8 constant IS_CREATOR = 2;

    struct SaleInfo {
        uint256 tokenId;
        string tokenHash;
        address creator;
        address currentOwner;
        uint256 startPrice;
        address maxBidder;
        uint256 maxBid;
        uint256 startTime;
        uint256 interval;
        uint24 royaltyRatio;
        uint8 kindOfCoin;
        bool _isOnSale;
    }

    enum AuctionState { 
        OPEN,
        CANCELLED,
        ENDED,
        DIRECT_BUY
    }

    address mkOwner;
    address mkNFTaddress;
    SpectraNFT mkNFT;
    IERC20 SPCToken;

    uint _saleIdCounter;
    bool _status;
    bool _isMinting;

    mapping(uint => SaleInfo) _allSaleInfo;
    mapping(string => uint) _getSaleId;
    mapping(string => bool) _tokenHashExists;
    mapping(address => uint8) _isCreator;
    mapping(address => uint256) _mintingFees;
    mapping(address => uint24) _sellingRatio;

    modifier onlyAdmin() {
        require(_isCreator[msg.sender] == IS_CREATOR || mkOwner == msg.sender, "Not NFT creater...");
        _;
    }

    modifier onlyReseller() {
        require(_isCreator[msg.sender] == IS_RESELLER || _isCreator[msg.sender] == IS_CREATOR || mkOwner == msg.sender, "Not NFT reseller...");
        _;
    }

    modifier notOnlyNFTOwner(string memory _tokenHash) {
        require(_allSaleInfo[_getSaleId[_tokenHash]].currentOwner != msg.sender, "NFT Owner cannot bid...");
        _;
    }

    modifier nonReentrant() {
        require(_status != true, "ReentrancyGuard: reentrant call");
        _status = true;
        _;
        _status = false;
    }

    constructor(address _nftAddress, address _spcAddress) {
        mkOwner = msg.sender;
        mkNFTaddress = _nftAddress;
        SPCToken = IERC20(_spcAddress);
        _saleIdCounter = 0;
        _status = false;
        _isMinting = false;
    }

    function mintSingleNFT(string memory _tokenHash) internal {
        require(!_tokenHashExists[_tokenHash], "Existing NFT hash value....");
        mkNFT = SpectraNFT(mkNFTaddress);
        mkNFT.mintNFT(_tokenHash);
        _tokenHashExists[_tokenHash] = true;
        _isMinting = true;
    }

    function mintMultipleNFT(string[] memory _tokenHashs) internal {
        for (uint256 i = 0; i < _tokenHashs.length; i++) {
            require(!_tokenHashExists[_tokenHashs[i]], "Existing NFT hash value....");
            mkNFT = SpectraNFT(mkNFTaddress);
            mkNFT.mintNFT(_tokenHashs[i]);
            _tokenHashExists[_tokenHashs[i]] = true;
        }
        _isMinting = true;
    }

    function createSale(string memory _tokenHash, uint _interval, uint _startPrice, uint24 _royalty, uint8 _kind) public nonReentrant onlyReseller returns (bool) {
        require(_interval >= 0, "Invalid auction interval....");
        require(_royalty >= 0, "Invalid royalty value....");
        require(_tokenHashExists[_tokenHash], "Non-Existing NFT hash value....");

        SaleInfo memory saleInfo;

        if (!_isMinting) {
            mkNFT.tranferNFT(msg.sender, address(this), _tokenHash);
            saleInfo = SaleInfo(_saleIdCounter, _tokenHash, _allSaleInfo[_getSaleId[_tokenHash]].creator, msg.sender, _startPrice, address(0), 0, block.timestamp, _interval, _royalty, _kind, true);
        } else {
            saleInfo = SaleInfo(_saleIdCounter, _tokenHash, msg.sender, msg.sender, _startPrice, address(0), 0, block.timestamp, _interval, _royalty, _kind, true);
        }
              
        _allSaleInfo[_saleIdCounter] = saleInfo;
        _getSaleId[_tokenHash] = _saleIdCounter;
        _saleIdCounter++;
        return true;
    }

    function createBatchSale(string[] memory _tokenHashs, uint _startPrice, uint24 _royalty, uint8 _kind) public {
        for (uint256 i = 0; i < _tokenHashs.length; i++) {
            createSale(_tokenHashs[i], 0, _startPrice, _royalty, _kind);
        }
    }

    function singleMintOnSale(string memory _tokenHash, uint _interval, uint _startPrice, uint24 _royalty, uint8 _kind) external payable onlyAdmin {
        mintSingleNFT(_tokenHash);
        createSale(_tokenHash, _interval, _startPrice, _royalty, _kind);
        _isMinting = false;
    }

    function batchMintOnSale(string[] memory _tokenHashs, uint _startPrice, uint24 _royalty, uint8 _kind) external payable onlyAdmin {
        mintMultipleNFT(_tokenHashs);
        createBatchSale(_tokenHashs, _startPrice, _royalty, _kind);
        _isMinting = false;
    }

    function destroySale(string memory _tokenHash) external onlyReseller nonReentrant returns (bool) {
        require(_tokenHashExists[_tokenHash], "Non-Existing NFT hash value....");
        require(getAuctionState(_tokenHash) != AuctionState.CANCELLED, "Auction state is already cancelled...");

        if (_allSaleInfo[_getSaleId[_tokenHash]].maxBid != 0) {
            customizedTransfer(payable(_allSaleInfo[_getSaleId[_tokenHash]].maxBidder), _allSaleInfo[_getSaleId[_tokenHash]].maxBid, _allSaleInfo[_getSaleId[_tokenHash]].kindOfCoin);
        }

        mkNFT.tranferNFT(address(this), _allSaleInfo[_getSaleId[_tokenHash]].currentOwner, _tokenHash);
        _allSaleInfo[_getSaleId[_tokenHash]]._isOnSale = false;
        emit DestroySale(_tokenHash);
        return true;
    }

    function placeBid(string memory _tokenHash) payable external nonReentrant notOnlyNFTOwner(_tokenHash) returns (bool) {
        require(_tokenHashExists[_tokenHash], "Non-Existing NFT hash value....");
        require(getAuctionState(_tokenHash) == AuctionState.OPEN || getAuctionState(_tokenHash) == AuctionState.DIRECT_BUY, "Auction state is not open...");
        require(msg.value >= _allSaleInfo[_getSaleId[_tokenHash]].startPrice, "Starting price is too low...");

        address lastHightestBidder = _allSaleInfo[_getSaleId[_tokenHash]].maxBidder;
        uint256 lastHighestBid = _allSaleInfo[_getSaleId[_tokenHash]].maxBid;
        _allSaleInfo[_getSaleId[_tokenHash]].maxBid = msg.value;
        _allSaleInfo[_getSaleId[_tokenHash]].maxBidder = msg.sender;

        if (lastHighestBid != 0) {
            customizedTransfer(payable(lastHightestBidder), lastHighestBid, _allSaleInfo[_getSaleId[_tokenHash]].kindOfCoin);
        }
    
        emit PlaceBid(msg.sender, msg.value);
        
        return true;
    } 

    function performBid(string memory _tokenHash) external nonReentrant returns (bool) {
        require(_tokenHashExists[_tokenHash], "Non-Existing NFT hash value....");
        require(getAuctionState(_tokenHash) == AuctionState.OPEN || getAuctionState(_tokenHash) == AuctionState.ENDED || getAuctionState(_tokenHash) == AuctionState.DIRECT_BUY, "Auction state is not correct...");
        SaleInfo memory saleInfo = _allSaleInfo[_getSaleId[_tokenHash]];
        uint256 royaltyAmount = saleInfo.maxBid * saleInfo.royaltyRatio / 100;
        uint256 salePrice = saleInfo.maxBid - saleInfo.maxBid * _sellingRatio[saleInfo.currentOwner] / 100 - royaltyAmount;

        mkNFT.tranferNFT(address(this), saleInfo.maxBidder, _tokenHash);

        customizedTransfer(payable(saleInfo.creator), royaltyAmount, saleInfo.kindOfCoin);
        customizedTransfer(payable(saleInfo.currentOwner), salePrice, saleInfo.kindOfCoin);

        saleInfo.currentOwner = saleInfo.maxBidder;
        saleInfo.startPrice = saleInfo.maxBid;
        saleInfo._isOnSale = false;

        _allSaleInfo[_getSaleId[_tokenHash]] = saleInfo;

        emit PerformBid(msg.sender, saleInfo.maxBidder, saleInfo.maxBid);
        return true;
    }

    function getAuthentication(address _addr) external view returns (uint8) {
        require(_addr != address(0), "Invalid input address...");
        return _isCreator[_addr];
    }

    function getAuctionState(string memory _tokenHash) public view returns (AuctionState) {
        if (!_allSaleInfo[_getSaleId[_tokenHash]]._isOnSale) return AuctionState.CANCELLED;
        if (_allSaleInfo[_getSaleId[_tokenHash]].interval == 0) return AuctionState.DIRECT_BUY;
        if (block.timestamp >= _allSaleInfo[_getSaleId[_tokenHash]].startTime + _allSaleInfo[_getSaleId[_tokenHash]].interval) return AuctionState.ENDED;
        return AuctionState.OPEN;
    } 

    function getSaleInfo(string memory _tokenHash) public view returns (SaleInfo memory) {
        require(_tokenHashExists[_tokenHash], "Non-Existing NFT hash value....");

        return _allSaleInfo[_getSaleId[_tokenHash]];
    }

    function getWithdrawBalance(uint8 _kind) public view returns (uint256) {
        require(_kind >= 0, "Invalid cryptocurrency...");

        if (_kind == 0) {
          return address(this).balance;
        } else {
          return SPCToken.balanceOf(address(this));
        }
    }

    function setOwner(address payable _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid input address...");
        mkOwner = _newOwner;
        transferOwnership(mkOwner);
    }

    function setAuthentication(address _addr, uint8 _flag) external onlyOwner {
        require(_addr != address(0), "Invalid input address...");
        _isCreator[_addr] = _flag;
    }

    function setMintingFee(address _creater, uint256 _amount) external onlyOwner {
        require(_creater != address(0), "Invalid input address...");
        require(_amount >= 0, "Too small amount");
        _mintingFees[_creater] = _amount;
    }

    function setSellingFee(address _seller, uint24 _ratio) external onlyOwner {
        require(_seller != address(0), "Invalid input address...");
        require(_ratio >= 0, "Too small ratio");
        require(_ratio < 100, "Too large ratio");
        _sellingRatio[_seller] = _ratio;
    }

    function customizedTransfer(address payable _to, uint256 _amount, uint8 _kind) internal {
        require(_to != address(0), "Invalid address...");
        require(_amount >= 0, "Invalid transferring amount...");
        require(_kind >= 0, "Invalid cryptocurrency...");
        
        if (_kind == 0) {
          _to.transfer(_amount);
        } else {
          SPCToken.transfer(_to, _amount);
        }
    }

    function withDraw(uint256 _amount, uint8 _kind) external onlyOwner {
        require(_amount > 0, "Invalid withdraw amount...");
        require(_kind >= 0, "Invalid cryptocurrency...");
        require(getWithdrawBalance(_kind) > _amount, "None left to withdraw...");

        customizedTransfer(payable(msg.sender), _amount, _kind);
    }

    function withDrawAll(uint8 _kind) external onlyOwner {
        require(_kind >= 0, "Invalid cryptocurrency...");
        uint256 remaining = getWithdrawBalance(_kind);
        require(remaining > 0, "None left to withdraw...");

        customizedTransfer(payable(msg.sender), remaining, _kind);
    }

    receive() payable external {

    }

    fallback() payable external {

    }

    event PlaceBid(address bidder, uint bid);
    event PerformBid(address nftSeller, address nftBuyer, uint256 amount);
    event DestroySale(string tokenHash);
}