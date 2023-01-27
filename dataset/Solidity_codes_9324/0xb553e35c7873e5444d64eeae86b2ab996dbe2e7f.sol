

pragma solidity ^0.8.0;
//pragma experimental ABIEncoderV2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
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

interface IMozikERC721Token is IERC721Enumerable {
   

    function getBaseTokenURI() external view returns (string memory); 

    function setBaseTokenURI(string memory url) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function isMozikNftToken(address tokenAddress) external view returns(bool);

    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

    function exists(uint256 tokenId) external view returns (bool);

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


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Authentication is Ownable {
    address private _owner;//合约拥有者
    mapping(address=>bool) _managers;//管理员

    constructor() {    
        _owner = msg.sender;
    }

    modifier onlyAuthorized(address target) {
        require(isOwner()||isManager(target),"Only for manager or owner!");
        _;
    }    

    function addManager(address manager) public onlyOwner{    
        _managers[manager] = true;
    }    

    function removeManager(address manager) public onlyOwner{    
        _managers[manager] = false;
    }  

    function isManager(address manager) public view returns (bool) {    
        return(_managers[manager]);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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


enum TokenType {ETH, ERC20}

contract Goods is Ownable {
    using Strings for string;
    using Address for address;    
    using SafeMath for *;
   
    string constant public _name = "GOODS contract as ERC721 NFT for sale with version 1.0";

    address private _nftContractAddress;
    uint256 public _tokenID;
    TokenType public _expectedTokenType;
    address payable public _sellerAddress;
    address private _expectedTokenAddress;
    uint256 public _expectedValue;
    uint private _startTime;
    bool private _isForSale = false;

    constructor(address ContractAddress) {
        require(true == Address.isContract(ContractAddress), "ContractAddress is not a contract address!");

        if(IERC721(ContractAddress).supportsInterface(0x80ac58cd))
        {
            _nftContractAddress = ContractAddress;
        }
        else
        {
            revert();
        }
        
    }  

    function getGoodsInfo() external view returns (address, uint256, TokenType,address,address,uint256,uint,bool) {  
        return (_nftContractAddress,_tokenID,_expectedTokenType,_sellerAddress,_expectedTokenAddress,_expectedValue,_startTime,_isForSale);
    }  

    function onSale(uint256 saleTokenID,address payable sellerAddress,TokenType expectedTokenType, address tokenAddress, uint256 value, uint256 startTime) external onlyOwner returns (bool) {  
        if(_isForSale|| sellerAddress == address(0) )
        {
            return false;
        }
        
        if(!isApprovedOrOwner(sellerAddress,saleTokenID )) 
        {
            return false;
        }   

        if((expectedTokenType != TokenType.ETH) && (!Address.isContract(tokenAddress)) )
        {
             return false;
        }

        if(startTime < block.timestamp)
        {
             return false;
        }

        _tokenID = saleTokenID;
        _expectedTokenType = expectedTokenType;
        _sellerAddress = sellerAddress;
        _expectedTokenAddress = tokenAddress;
        _expectedValue = value;
        _startTime = startTime;
        _isForSale = true;        

        return true;
    }  

    function offSale() external onlyOwner{ 
        _tokenID = 0;
        _expectedTokenType = TokenType.ETH;
        _sellerAddress = payable(address(0));
        _expectedTokenAddress = address(0);
        _expectedValue = 0;
        _startTime = 0;        
        _isForSale = false;
    }  

    function isApprovedOrOwner(address seller, uint256 tokenId) public view returns (bool) {
        address owner = IERC721(_nftContractAddress).ownerOf(tokenId);

        return (seller == owner || IERC721(_nftContractAddress).getApproved(tokenId) == seller || IERC721(_nftContractAddress).isApprovedForAll(owner, seller));
    }

    function isOnSale() public view returns(bool) {
        return(_isForSale && (block.timestamp >= _startTime));
    }
}


contract Exchange is Authentication {
    using Strings for string;
    using Address for address;    
    using SafeMath for *;

    string constant public _name = "Exchange contract as ERC721 NFT exchange with ETH or mozik ERC20 version 1.0";    
    
    mapping(uint256 => address) private _saleGoodsAddr;//token ID对应的商品合约地址
    address private _mozikNftAddress;//MOZIK NFT智能合约
    address private _mozikErc20Address;//MOZIK ERC20智能合约

    constructor(address mozikNftAddress, address mozikErc20Address) {
        require(Address.isContract(mozikNftAddress), "the first parameter should be MozikERC721Token address!" );     
        require(Address.isContract(mozikErc20Address), "the second parameter should be mozik ERC20 address!" );     

        require(IMozikERC721Token(mozikNftAddress).isMozikNftToken(mozikNftAddress), "the first parameter should be MozikERC721Token address!");

        _mozikNftAddress = mozikNftAddress;
        
        _mozikErc20Address = mozikErc20Address;
        
    }  

    function isOnSale(uint256 tokenId) public view returns(bool) {
        address goodsAddress = _saleGoodsAddr[tokenId];

        if( address(0) != goodsAddress && Goods(goodsAddress).isOnSale() )
        {
            return true;
        }

        return false;

    }   

    function getSaleGoodsInfo(uint256 tokenID) external view 
    returns (address nftContractAddress, uint256 tokenid, TokenType expectedTokenType,address sellerAddress,address expectedTokenAddress,uint256 expectedValue,uint startTime,bool isForSale) {
       
        address goodsAddress = _saleGoodsAddr[tokenID];

        require(address(0) != goodsAddress, "It's not an invalid goods.");

        return( Goods(goodsAddress).getGoodsInfo() );


    }    

    function hasRightToSale(address targetAddr, uint256 tokenId) public view returns(bool) {
  
        return (IMozikERC721Token(_mozikNftAddress).isApprovedOrOwner(targetAddr, tokenId));
    }

    function IsTokenOwner(address targetAddr, uint256 tokenId) public view returns(bool) {
        if(!IMozikERC721Token(_mozikNftAddress).exists(tokenId))
        {
            return false;
        }
        
        return (targetAddr == IMozikERC721Token(_mozikNftAddress).ownerOf(tokenId) );
    }

    function hasEnoughTokenToBuy(address buyer, uint256 tokenId) public view returns(bool) {
        
        if( (address(0) == buyer) || (!IMozikERC721Token(_mozikNftAddress).exists(tokenId)) )
        {
            return false;
        }

        address goodsAddress = _saleGoodsAddr[tokenId];
        if(address(0) == goodsAddress)
        {
            return false;
        }
        
        if(TokenType.ETH ==  Goods(goodsAddress)._expectedTokenType() )
        {
            buyer.balance >= Goods(goodsAddress)._expectedValue();
            return true;
        }
        else if(TokenType.ERC20 ==  Goods(goodsAddress)._expectedTokenType() )
        {
                IERC20(_mozikErc20Address).balanceOf(buyer) >= Goods(goodsAddress)._expectedValue();
                return true;
        }
        else
        {
            return false;
        }           
  
    }

    function sellNFT(uint256 saleTokenID, TokenType expectedTokenType, address tokenAddress, uint256 value, uint256 startTime) external {
        Goods goods;
        bool result;

        require(hasRightToSale(address(this), saleTokenID),"the exchange contracct is not the approved of the TOKEN.");


        require(!Address.isContract(msg.sender),"the sender should be a person, not a contract!");

        require(IsTokenOwner(msg.sender, saleTokenID),"the sender isn't the owner of the token id nft!");

        require((expectedTokenType == TokenType.ETH) || (expectedTokenType == TokenType.ERC20),
                "expectedTokenType must be ETH or ERC20 in this version!");

        if(expectedTokenType == TokenType.ERC20)
        {
            require((tokenAddress == _mozikErc20Address), "the expected token must be mozik ERC20 token.");
        }
        
        require((startTime >= block.timestamp), "startTime for sale must be bigger than now.");

        if( address(0) != _saleGoodsAddr[saleTokenID] )
        {
            goods = Goods(_saleGoodsAddr[saleTokenID] );
            goods.onSale(saleTokenID,payable(msg.sender),expectedTokenType, tokenAddress, value, startTime);
        }
        else
        {
            goods = new Goods(_mozikNftAddress);
            result = goods.onSale(saleTokenID, payable(msg.sender), expectedTokenType, tokenAddress, value, startTime);
            require(result, "set goods on sale is failed.");

            _saleGoodsAddr[saleTokenID] = address(goods);
        }
    }    

    function cancelSell(uint256 tokenID) external onlyAuthorized(msg.sender){
        _saleGoodsAddr[tokenID] = address(0);

    }    

    function buyNFT(uint256 tokenID) payable external {
        require(isOnSale(tokenID),"The nft token(tokenID) is not on sale.");

        require(hasRightToSale(address(this), tokenID),"the exchange contracct is not the approved of the TOKEN.");

        require(hasEnoughTokenToBuy(msg.sender, tokenID), "No enough token to buy the NFT(tokenID)");
        
        address goodsAddress = _saleGoodsAddr[tokenID];
        require(address(0) != goodsAddress, "The token ID isn't on sale status!");

        require(msg.sender != Goods(goodsAddress)._sellerAddress(), "the buyer can't be same to the seller.");

        IMozikERC721Token(_mozikNftAddress).safeTransferFrom(Goods(goodsAddress)._sellerAddress(), msg.sender, tokenID);

        uint256 amount = Goods(goodsAddress)._expectedValue();

        if(TokenType.ETH ==  Goods(goodsAddress)._expectedTokenType() )
        {
            Goods(goodsAddress)._sellerAddress().transfer(amount);
        }
        else if(TokenType.ERC20 ==  Goods(goodsAddress)._expectedTokenType() )
        {
            require(IERC20(_mozikErc20Address).allowance(msg.sender, address(this)) >= amount, 
                    "the approved MOZ ERC20 tokens to the contract address should greater than the _expectedValue." );
                                
            IERC20(_mozikErc20Address).transferFrom(msg.sender, Goods(goodsAddress)._sellerAddress(), amount);
        }

        _saleGoodsAddr[tokenID] = address(0x0);
    }   

    function getTokenAddress() external view returns (address, address){
        return(_mozikNftAddress, _mozikErc20Address);
    }    

    function destroyContract() external onlyOwner {
        uint256 amount = IERC20(_mozikErc20Address).balanceOf(address(this));
        IERC20(_mozikErc20Address).transfer(owner(), amount);

            
        selfdestruct(payable(owner()));
    } 
}