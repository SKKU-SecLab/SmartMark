
pragma solidity 0.8.4;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity 0.8.4;


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

pragma solidity 0.8.4;

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
}// MIT

pragma solidity 0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity 0.8.4;

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
}// MIT

pragma solidity 0.8.4;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity 0.8.4;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}pragma solidity >=0.8.4 <= 0.8.6;

interface ILockable {


    event SetLock(uint256 _tokenId, bool _isLock);

    function lock(uint256 _tokenId) external;


    function unlock(uint256 _tokenId) external;


    function isLock(uint256 _tokenId) external view returns(bool);

}pragma solidity >=0.8.4 <= 0.8.6;

contract ERC721Receiver {

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  )
    external
    returns(bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}// MIT

pragma solidity >=0.8.4 <=0.8.6;


contract ERC721 is Context, ERC165, IERC721, IERC721Enumerable, IERC721Metadata, ILockable, ERC721Receiver {

    using Address for address;
    using Strings for uint256;

    event AdminSet(address _admin, bool _isAdmin);
    
    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;

    address payable owner;

    string private _name;

    string private _symbol;

    uint256[] internal _allTokens;

    mapping(uint256 => address) internal _owners;

    mapping(address => uint256) internal _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => bool) admins;
    
    mapping(uint256 => bool) lockedTokens;

    mapping(uint256 => string) internal _tokenURIs;

    mapping(address => mapping(uint256 => uint256)) internal _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    mapping(uint256 => uint256) private _allTokensIndex;

    struct Token {
        uint256 id;
        uint256 price;
        address token;
        address owner;
        address creator;
        string uri;
        bool status;
        bool isLocked;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "Only owner");
        _;
    }

     modifier onlyAdmin() {

        require(admins[msg.sender] || owner == msg.sender, "Only admin or owner");
        _;
    }

    modifier tokenNotFound(uint256 _tokenId) {

        require(exists(_tokenId), "Token isn't exist");
        _;
    }

    modifier isUnlock(uint256 _tokenId) {

        require(!isLock(_tokenId), "Token is locked");
        _;
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address _owner) public view virtual override returns (uint256) {

        require(_owner != address(0), "ERC721: balance query for the zero address");
        return _balances[_owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address _owner = _owners[tokenId];
        require(_owner != address(0), "ERC721: owner query for nonexistent token");
        return _owner;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address _owner = ERC721.ownerOf(tokenId);
        require(to != _owner, "ERC721: approval to current owner");

        require(
            _msgSender() == _owner || isApprovedForAll(_owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address _owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[_owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {

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

    function exists(uint256 tokenId) public view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(exists(tokenId), "ERC721: operator query for nonexistent token");
        address _owner = ERC721.ownerOf(tokenId);
        return (spender == _owner || getApproved(tokenId) == spender || isApprovedForAll(_owner, spender));
    }

    function _safeMint(address to, uint256 tokenId, string memory uri) internal virtual {

        _safeMint(to, tokenId, "", uri);
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data,
        string memory _uri
    ) internal virtual {

        _mint(to, tokenId, _uri);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId, string memory uri) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;
        _setTokenURI(tokenId, uri);

        emit Transfer(address(0), to, tokenId);
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
            try ERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == ERC721Receiver(to).onERC721Received.selector;
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

    function tokenOfOwnerByIndex(address _owner, uint256 index) public view virtual override returns (uint256) {

        require(index < ERC721.balanceOf(_owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[_owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        if (from == address(0)) {
            _allTokensIndex[tokenId] = _allTokens.length;
            _allTokens.push(tokenId);
        } else if (from != to) {
            uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
            uint256 tokenIndex = _ownedTokensIndex[tokenId];

            if (tokenIndex != lastTokenIndex) {
                uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

                _ownedTokens[from][tokenIndex] = lastTokenId; 
                _ownedTokensIndex[lastTokenId] = tokenIndex;
            }

            delete _ownedTokensIndex[tokenId];
            delete _ownedTokens[from][lastTokenIndex];
        }
        if (to == address(0)) {
            uint256 lastTokenIndex = _allTokens.length - 1;
            uint256 tokenIndex = _allTokensIndex[tokenId];

            uint256 lastTokenId = _allTokens[lastTokenIndex];

            _allTokens[tokenIndex] = lastTokenId; 
            _allTokensIndex[lastTokenId] = tokenIndex;

            delete _allTokensIndex[tokenId];
            _allTokens.pop();
        } else if (to != from) {
            uint256 length = ERC721.balanceOf(to);
            _ownedTokens[to][length] = tokenId;
            _ownedTokensIndex[tokenId] = length;
        }
    }
 
  function name() external override view returns (string memory) {

    return _name;
  }

  function symbol() external override view returns (string memory) {

    return _symbol;
  }

  function tokenURI(uint256 tokenId) external override view returns (string memory) {

    require(ERC721.exists(tokenId));
    return _tokenURIs[tokenId];
  }

  function _setTokenURI(uint256 tokenId, string memory uri) internal {

    require(ERC721.exists(tokenId));
    _tokenURIs[tokenId] = uri;
  }

    function lock(uint256 _tokenId) public override tokenNotFound(_tokenId) isUnlock(_tokenId) onlyAdmin{

        _transfer(ownerOf(_tokenId), address(0), _tokenId);
        _lock(_tokenId);
    }

    function _lock(uint256 _tokenId) internal {

        lockedTokens[_tokenId] = true;

        emit SetLock(_tokenId, true);
    }

    function unlock(uint256 _tokenId) public override tokenNotFound(_tokenId) onlyAdmin{

        require(isLock(_tokenId), "Token is already unlocked");
        lockedTokens[_tokenId] = false;

        emit SetLock(_tokenId, false);
    }

    function _unlock(uint256 _tokenId) internal {

        lockedTokens[_tokenId] = false;

        emit SetLock(_tokenId, false);
    }

    function isLock(uint256 _tokenId) public view override returns(bool) {

        return lockedTokens[_tokenId];
    }

    function setAdmin(address _user, bool _isAdmin) public onlyOwner() {

        require(!isAdmin(_user), "User is already admin");
        admins[_user] = _isAdmin;

        emit AdminSet(_user, _isAdmin);
    }

    function isAdmin(address _admin) public view returns(bool) {

        return admins[_admin];
    }
}// MIT

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
}pragma solidity >=0.8.4 <= 0.8.6;

interface IERC721Pausable {


    event Paused(uint256 _tokenId);//, uint256 _timeSec);
    event Resumed(uint256 _tokenId);
    
    function pause(uint256 _tokenId) external;



    function resume(uint256 _tokenId) external;

}// MIT

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
}//MIT

pragma solidity >=0.8.4 <=0.8.6;


contract PaybNftMarketplace is ERC721, IERC721Pausable{

    using Address for address;
    using SafeMath for uint256;

    event PriceChanged(uint256 _tokenId, uint256 _price, address _tokenAddress, address _user);
    event RoyaltyChanged(uint256 _tokenId, uint256 _royalty, address _user);
    event FundsTransfer(uint256 _tokenId, uint256 _amount, address _user);

    mapping(uint256 => bool) tokenStatus;

    mapping(uint256 => uint256) prices;

    mapping(uint256 => address) tokenAddress;

    mapping(uint256 => uint256) royalties; // in decimals (min 0.01%, max 100%)

    mapping(uint256 => address) tokenCreators;

    mapping(address => uint256[]) creatorsTokens;

    uint256 tokenId;

    uint256 platformFee = 0;

    constructor(string memory name_, string memory symbol_, address payable owner_, address admin_) ERC721(name_, symbol_) {
        tokenId = 1;
        owner = owner_;
        admins[admin_] = true;
    }

    function withdraw() external onlyOwner() {

        owner.transfer(getBalance());
    }

    function withdraw(address _user, uint256 _amount) external onlyOwner() {

        uint256 _balance = getBalance();
        require(_balance > 0, "Balance is null");
        require(_balance >= _amount, "Amount is greater than the balance of contract");

        payable(_user).transfer(_amount);
    }

    function withdraw(address _tokenErc20, address _user) external onlyOwner() {

        require(_tokenErc20.isContract(), "Token address isn`t a contract address");
        uint256 _totalBalance = IERC20(_tokenErc20).balanceOf(address(this));

        require(_totalBalance > 0, "Total balance is zero");

        IERC20(_tokenErc20).transfer(_user, _totalBalance);
    }

    function setPlatformFee(uint256 _newFee) public onlyAdmin {

        require(_newFee < 10000, "Royalty can be 100 percent of the total amount");
        platformFee = _newFee;
    }

    function getPlatformFee() public view returns(uint256) {

        return platformFee;
    }

    function getBalance() public view returns(uint256){

        address _self = address(this);
        uint256 _balance = _self.balance;
        return _balance;
    }

    function mint(address _to, address _token, uint256 _price, string memory _uri, uint256 _royalty) public payable {

        require(_token == address(0) || _token.isContract(), "Token address isn`t a contract address");
        require(_royalty + platformFee < 10000, "Creator royalty plus platform fee must be less than 100%");

        prices[tokenId] = _price;
        tokenAddress[tokenId] = _token;
        tokenStatus[tokenId] = true;
        royalties[tokenId] = _royalty;
        tokenCreators[tokenId] = _to;
        creatorsTokens[_to].push(tokenId);

        if((isAdmin(msg.sender) && msg.sender != _to) || msg.sender == address(this)){
            _pause(tokenId);
        }

        _safeMint(_to, tokenId, _uri);

        emit PriceChanged(tokenId++, _price, _token, msg.sender);
    }

    function setPriceAndSell(uint256 _tokenId, uint256 _price) public tokenNotFound(_tokenId) isUnlock(_tokenId){

        require(ownerOf(_tokenId) == msg.sender, "Sender isn`t owner of token");

        prices[_tokenId] = _price;
        _resume(_tokenId);

        emit PriceChanged(_tokenId, _price, tokenAddress[_tokenId], msg.sender);
    }

    function buy(uint256 _tokenId) public payable tokenNotFound(_tokenId) isUnlock(_tokenId){

        require(tokenStatus[_tokenId], "Token not for sale");
        require(ownerOf(_tokenId) != msg.sender, "Sender is already owner of token");

        uint256 _price = prices[_tokenId];
        uint256 _creatorRoyalty = (_price.mul(royalties[_tokenId])).div(10000);
        uint256 _platformFee = (_price.mul(platformFee)).div(10000);

        if(tokenAddress[_tokenId] == address(0)) {
            require(_price == msg.value, "Value isn`t equal to price!");
            payable(ownerOf(_tokenId)).transfer(_price.sub(_creatorRoyalty + _platformFee));
            payable(tokenCreators[_tokenId]).transfer(_creatorRoyalty);
            owner.transfer(_platformFee);
        }else {
            require(IERC20(tokenAddress[_tokenId]).balanceOf(msg.sender) >= _price, "Insufficient funds");
            IERC20(tokenAddress[_tokenId]).transferFrom(msg.sender, address(this), _price);

            IERC20(tokenAddress[_tokenId]).transfer(ownerOf(_tokenId), _price.sub(_creatorRoyalty + _platformFee));
            IERC20(tokenAddress[_tokenId]).transfer(owner, _platformFee);
            IERC20(tokenAddress[_tokenId]).transfer(tokenCreators[_tokenId], _creatorRoyalty);
        }

        _pause(_tokenId);

        _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
    }

    function balanceOf(address _user, uint256 _tokenId) public view returns(uint256) {

        return IERC20(tokenAddress[_tokenId]).balanceOf(_user);
    }

    function getPriceInTokens(uint256 _tokenId) public view tokenNotFound(_tokenId) isUnlock(_tokenId) returns(uint256, address){

        return (prices[_tokenId], tokenAddress[_tokenId]);
    }

    function pause(uint256 _tokenId) external override tokenNotFound(_tokenId) isUnlock(_tokenId){

        require(ownerOf(_tokenId) == msg.sender, "User isn`t owner of token!");

        _pause(_tokenId);
    }

    function _pause(uint256 _tokenId) internal {

        tokenStatus[_tokenId] = false;

        emit Paused(_tokenId);
    }

    function resume(uint256 _tokenId) external override tokenNotFound(_tokenId) isUnlock(_tokenId){

        require(ownerOf(_tokenId) == msg.sender, "User isn`t owner of token!");

        _resume(_tokenId);
    }

    function _resume(uint256 _tokenId) internal {

        tokenStatus[_tokenId] = true;

        emit Resumed(_tokenId);
    }

    function getTokenStatus(uint256 _tokenId) public view returns(bool) {

        return isLock(_tokenId);
    }

    function isForSale(uint256 _tokenId) public view returns(bool) {

        return tokenStatus[_tokenId];
    }

    function getRoyalty(uint256 _tokenId) public view returns(uint256) {

        return royalties[_tokenId];
    }

    function setNewRoyalty(uint256 _tokenId, uint256 _newRoyalty) public tokenNotFound(_tokenId) isUnlock(_tokenId){

        require(msg.sender == ownerOf(_tokenId), "Sender isn`t an owner of token");
        require(_newRoyalty > royalties[_tokenId] && _newRoyalty <= 10000 && _newRoyalty + platformFee <= 10000, "New royalty cannot be less than the old one or more than 100%");

        royalties[_tokenId] = _newRoyalty;

        emit RoyaltyChanged(_tokenId, _newRoyalty, msg.sender);
    }

    function sendToken(uint256 _tokenId, address _from, address _to) public tokenNotFound(_tokenId) onlyAdmin() {

        require(isLock(_tokenId), "Token is unlocked");
        _transfer(_from, _to, _tokenId);
        _unlock(_tokenId);
        _pause(_tokenId);
    }

    function sendTo(uint256 _tokenId, address payable _to) public onlyAdmin() tokenNotFound(_tokenId) payable{

        require(ownerOf(_tokenId) == _to, "To isn`t an owner of token");

        uint256 _price = prices[_tokenId];
        address _token = tokenAddress[_tokenId];


        uint256 _creatorRoyalty = (_price.mul(royalties[_tokenId])).div(10000);
        uint256 _platformFee = (_price.mul(platformFee)).div(10000);

        if(_token == address(0)){
            require(_price == msg.value, "Amount isn`t equal to price");
            _to.transfer(_price.sub(_creatorRoyalty + _platformFee));
            payable(tokenCreators[_tokenId]).transfer(_creatorRoyalty);
            owner.transfer(_platformFee);
        }else {
            require(IERC20(_token).balanceOf(msg.sender) >= _price, "Insufficient funds");
            IERC20(_token).transferFrom(msg.sender, _to, _price.sub(_creatorRoyalty + _platformFee));
            IERC20(_token).transferFrom(msg.sender, tokenCreators[_tokenId], _creatorRoyalty);
        }

        _lock(_tokenId);
        _pause(_tokenId);
    }

    function sendToAdmin(address _token, address _admin, uint256 _amount, uint256 _tokenId) public payable{

        require(_token.isContract() || _token == address(0), "Token isn`t a contract address");

         if(_token == address(0)){
            payable(_admin).transfer(msg.value);
        }else {
            require(IERC20(_token).balanceOf(msg.sender) >= _amount, "Insufficient funds");
            IERC20(_token).transferFrom(msg.sender, _admin, _amount);
        }

        emit FundsTransfer(_tokenId, _amount == 0? msg.value : _amount, msg.sender);
    }

    function getAllTokensObjs() public view returns(Token[] memory) {

        Token[] memory _tokensObj = new Token[](_allTokens.length);

        uint256 _id = 1;
        while(_allTokens.length >= _id){
            Token memory _token = Token({
                id:    _id,
                price: prices[_id],
                token: tokenAddress[_id],
                owner: _owners[_id],
                creator: tokenCreators[_id],
                uri:   _tokenURIs[_id],
                status: isForSale(_id),
                isLocked: isLock(_id)
            });

            _tokensObj[_id-1] = _token;
            _id++;
        }

        return _tokensObj;
    }

    function getAllTokensByPage(uint256 _from, uint256 _to) public view returns(Token[] memory) {

        require(_from < _to, "From is bigger than to");

        uint256 _last = (_to > _allTokens.length) ? _allTokens.length : _to;

        Token[] memory _tokens = new Token[](_to-_from + 1);

        uint256 _j = 0;

        for(uint256 i=_from; i<=_last; i++) {
            Token memory _token = Token({
                id:    i,
                price: prices[i],
                token: tokenAddress[i],
                owner: _owners[i],
                creator: tokenCreators[i],
                uri:   _tokenURIs[i],
                status: isForSale(i),
                isLocked: isLock(i)
            });

            _tokens[_j++] = _token;
        }

        return _tokens;
    }

    function getTokensByUserObjs(address _user) public view returns(Token[] memory) {

        Token[] memory _tokens = new Token[](_balances[_user]);

        for(uint256 i=0; i<_tokens.length; i++) {
            if(_ownedTokens[_user][i] != 0) {
                uint256 _tokenId = _ownedTokens[_user][i];
                Token memory _token = Token({
                    id:    _tokenId,
                    price: prices[_tokenId],
                    token: tokenAddress[_tokenId],
                    owner: _user,
                    creator: tokenCreators[_tokenId],
                    uri:   _tokenURIs[_tokenId],
                    status: isForSale(_tokenId),
                    isLocked: isLock(_tokenId)
                });

                _tokens[i] = _token;
            }
        }

        return _tokens;
    }

    function getTokenInfo(uint256 _tokenId) public view returns(Token memory) {

        Token memory _token = Token({
            id: _tokenId,
            price: prices[_tokenId],
            token: tokenAddress[_tokenId],
            owner: _owners[_tokenId],
            creator: tokenCreators[_tokenId],
            uri: _tokenURIs[_tokenId],
            status: isForSale(_tokenId),
            isLocked: isLock(_tokenId)
        });

        return _token;
    }

    function getCreatorsTokens(address _creator) public view returns(uint256[] memory) {

        return creatorsTokens[_creator];
    }

    function getCreatorsTokensObj(address _creator) public view returns(Token[] memory) {

        Token[] memory _tokens = new Token[](creatorsTokens[_creator].length);

        for(uint256 i=0; i<_tokens.length; i++) {
            uint256 _tokenId = creatorsTokens[_creator][i];
            Token memory _token = Token({
                id: _tokenId,
                price: prices[_tokenId],
                token: tokenAddress[_tokenId],
                owner: _owners[_tokenId],
                creator: _creator,
                uri: _tokenURIs[_tokenId],
                status: isForSale(_tokenId),
                isLocked: isLock(_tokenId)
            });

            _tokens[i] = _token;
        }


        return _tokens;
    }
}