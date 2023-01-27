
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

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

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}// MIT
pragma solidity 0.8.6;

contract Administration is Ownable {
    
    event SetAdmin(address indexed admin, bool active);
    
    mapping (address => bool) private admins;
    
    modifier onlyAdmin(){
        require(admins[_msgSender()] || owner() == _msgSender(), "Admin: caller is not an admin");
        _;
    }
    
    function setAdmin(address admin, bool active) external onlyOwner {
        admins[admin] = active;
        emit SetAdmin(admin, active);
    }
    
}// MIT
pragma solidity 0.8.6;

contract NFTEvents {
    event NewTotalSupply(address indexed caller, uint newSupply);
    event NewStripperPrice(address indexed caller, uint newPrice);
    event NewMaxMint(address indexed caller, uint newMaxMint);
    event MintStripper(address indexed buyer, uint qty);
    event MintClub(address indexed caller, string clubName);
    event CloseClub(address indexed caller, uint tokenId);
    event ReopenClub(address indexed caller, uint tokenId);
    event NewAssetName(address indexed caller, uint indexed tokenId, string newName);
    event Giveaway(address indexed from, address indexed to, uint qty);
}// MIT
pragma solidity 0.8.6;

interface IStrip {
    function balanceOf(address account) external view returns (uint256);
    function buy(uint price) external;
    function decimals() external view returns (uint);
}// MIT
pragma solidity 0.8.6;


contract Assets is Administration, NFTEvents {
    
    uint public strippersCount = 0;
    uint public clubsCount = 0;
    uint public namePriceStripper = 200 ether;
    uint public stripperSupply = 3000;
    uint8 public STRIPPER = 0;
    uint8 public CLUB = 1;
    
    IStrip public COIN;
    
    struct Asset {
        uint id;
        uint tokenType;
        uint earn;
        uint withdraw;
        uint born;
        string name;
        bool active;
    }
    
    Asset[] public assets;
    
    function setCoinAddress(address addr) public onlyAdmin {
        COIN = IStrip(addr);
    }
    
    function getAssetByTokenId(uint tokenId) public view returns(Asset memory, uint idx) {
        uint i = 0;
        Asset memory asset;
        while(i < assets.length){
            if(assets[i].id == tokenId){
                asset = assets[i];
                return(assets[i],i);
            }
            i++;
        }
        revert("tokenId not found");
    }
    
    function setNamePriceStripper(uint newPrice) external onlyAdmin {
        namePriceStripper = newPrice;
    }
    
    function adminSetAssetName(uint tokenId, string calldata name) external onlyAdmin {
        (,uint idx) = getAssetByTokenId(tokenId);
        assets[idx].name = name;
        emit NewAssetName(_msgSender(), tokenId, name);
    }
    
    function setStripperSupply(uint supply) external onlyAdmin {
        stripperSupply = supply;
        emit NewTotalSupply(_msgSender(), supply);
    }
    
    function totalSupply() external view returns (uint) {
        return stripperSupply + clubsCount;
    }
    
    function withdraw() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
    
}// MIT
pragma solidity >=0.8.6;


contract Strip is ERC20, Administration {

    uint256 private _initialTokens = 500000000 ether;
    address public game;
    
    constructor() ERC20("STRIP", "STRIP") {
        
    }
    
    function setGameAddress(address game_) external onlyAdmin {
        game = game_;
    }
    
    function buy(uint price) external onlyAdmin {
        _burn(tx.origin, price);
    }
    
    function initialMint() external onlyAdmin {
        require(totalSupply() == 0, "ERROR: Assets found");
        _mint(owner(), _initialTokens);
    }

    function mintTokens(uint amount) public onlyAdmin {
        _mint(owner(), amount);
    }
    
    function burnTokens(uint amount) external onlyAdmin {
        _burn(tx.origin, amount);
    }
    
    function approveOwnerTokensToGame() external onlyAdmin {
        _approve(owner(), game, _initialTokens);
    }
    
    function approveHolderTokensToGame(uint amount) external {
       _approve(tx.origin, game, amount);
    }

    function withdraw() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
}// MIT
pragma solidity 0.8.6;


contract StripperVille is Assets, ERC721 {
    
    uint public stripperPrice = 0.095 ether;
    uint private _maxMint = 0;
    string public baseTokenURI = 'https://strippervillebackend.herokuapp.com/';
    
    constructor() ERC721("StripperVille", "SpV") {}
    
    modifier isMine(uint tokenId){
        require(_msgSender() == ownerOf(tokenId), "OWNERSHIP: sender is not the owner");
        _;
    }
    
    modifier canMint(uint qty){
        require((qty + strippersCount) <= stripperSupply, "SUPPLY: qty exceeds total suply");
        _;
    }
    
    function setStripperPrice(uint newPrice) external onlyAdmin {
        stripperPrice = newPrice;
        emit NewStripperPrice(_msgSender(), newPrice);
    }
    
    function setMaxMint(uint newMaxMint) external onlyAdmin {
        _maxMint = newMaxMint;
        emit NewMaxMint(_msgSender(), newMaxMint);
    }
    
    function buyStripper(uint qty) external payable canMint(qty) {
        require((msg.value == stripperPrice * qty),"BUY: wrong value");
        require((qty <= _maxMint), "MINT LIMIT: cannot mint more than allowed");
        for(uint i=0; i < qty; i++) {
            _mintTo(_msgSender());
        }
        emit MintStripper(_msgSender(), qty);
    }
    
    function giveaway(address to, uint qty) external onlyOwner canMint(qty) {
        for(uint i=0; i < qty; i++) {
            _mintTo(to);
        }
        emit Giveaway(_msgSender(), to, qty);
    }
    
    function _mintTo(address to) internal {
        require(strippersCount < stripperSupply, "SUPPLY: qty exceeds total suply");
        uint rand = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender, assets.length)));
        uint earn = ((rand % 31) + 70)  * (10 ** 18);
        uint tokenId = strippersCount + 1;
        assets.push(Asset(tokenId, STRIPPER, earn, 0, block.timestamp, "", true));
        _safeMint(to, tokenId);
        strippersCount++;
    }
    
    function createClub(string calldata clubName) external onlyAdmin {
        uint tokenId = clubsCount + 1000000;
        assets.push(Asset(tokenId, CLUB, 0, 0, block.timestamp, clubName, true));
        _safeMint(owner(), tokenId);
        clubsCount++;
        emit MintClub(_msgSender(), clubName);
    }
    
    function closeClub(uint tokenId) external onlyAdmin {
        require(ownerOf(tokenId) == owner(), "Ownership: Cannot close this club");
        (Asset memory asset, uint i) = getAssetByTokenId(tokenId);
        require(asset.tokenType == CLUB, "CLUB: asset is not a club");
        assets[i].active = false;
        emit CloseClub(_msgSender(), tokenId);
    }
    
    function reopenClub(uint tokenId) external onlyAdmin {
        (Asset memory asset, uint i) = getAssetByTokenId(tokenId);
        require(asset.tokenType == CLUB, "CLUB: asset is not a club");
        assets[i].active = true;
        emit ReopenClub(_msgSender(), tokenId);
    }
    
    function setStripperName(uint tokenId, string calldata name) external isMine(tokenId) {
        (Asset memory asset, uint i) = getAssetByTokenId(tokenId);
        require(asset.tokenType == STRIPPER, "ASSET: Asset is not a stripper");
        require(COIN.balanceOf(_msgSender()) >= namePriceStripper, "COIN: Insuficient funds");
        COIN.buy(namePriceStripper);
        assets[i].name = name;
        emit NewAssetName(_msgSender(), tokenId, name);
    }
    
    function withdrawAsset(uint tokenId, uint amount) external onlyAdmin {
        require(tx.origin == ownerOf(tokenId),  "OWNERSHIP: sender is not the owner");
        (, uint i) = getAssetByTokenId(tokenId);
        assets[i].withdraw += amount;
    }
    
    function getAssetsByOwner(address owner) public view returns (Asset[] memory) {
        uint balance = balanceOf(owner);
        Asset[] memory assets_ = new Asset[](balance);
        uint j = 0;
        for(uint i = 0; i < assets.length; i++){
            if(ownerOf(assets[i].id) == owner){
                assets_[j] = assets[i];
                j++;
                if(balance == j){
                 break;
                }
            }
            i++;
        }
        return assets_;
    }
    
    function setBaseTokenURI(string calldata uri) external onlyOwner {
        baseTokenURI = uri;
    }

    function _baseURI() internal override view returns (string memory) {
        return baseTokenURI;
    }
    
}// MIT
pragma solidity >=0.8.6;


contract StripperVilleGame is Administration {
    
    event Claim(address indexed caller, uint tokenId, uint qty);
    event Work(uint tokenId, uint gameId);
    event BuyWorker(address indexed to, uint gameId, bool isThief);
    event WorkerAction(address indexed owner, uint gameId);
    event BuyWearable(uint stripper, uint wearable);
    
    mapping(uint => mapping (uint => uint)) private _poolStripClub;
    mapping(uint => mapping (uint => uint)) private _poolClubEarn;
    mapping(uint => mapping (uint => uint)) public poolClubPercentage;
    mapping(uint => mapping (uint => uint)) private _poolClubStrippersCount;
    mapping(uint => uint) public stripperWearable;
    mapping(uint => Worker[]) private _poolThieves;
    mapping(uint => Worker[]) private _poolCustomers;
    mapping(address => uint) private _addressWithdraw;

    Wearable[] public wearables;
    Strip public COIN;
    StripperVille public NFT;
    Game[] public games;
    uint public weeklyPrize = 250000 ether;
    uint public gamePrize = 250000 ether;
    uint public thiefPrice = 100 ether;
    uint public customerPrice = 100 ether;
    uint constant WEEK = 604800;
    
    modifier ownerOf(uint tokenId) {
        require(NFT.ownerOf(tokenId) == _msgSender(), "OWNERSHIP: Sender is not onwer");
        _;
    }
    
    modifier gameOn(uint gameId){
        require(games[gameId].paused == false && games[gameId].endDate == 0, "GAME FINISHED");
        _;
    }
    
    struct Worker {
        address owner;
        uint tokenId;
    }
    
    struct Game {
        uint prize;
        uint startDate;
        uint endDate;
        uint price;
        uint maxThieves;
        uint maxCustomers;
        uint customerMultiplier;
        bool paused;
    }
    
    struct Wearable {
        string name;
        uint price;
        uint increase;
        bool canBuy;
    }
    
    constructor(){
        wearables.push(Wearable('', 0, 0, false));
    }
    
    function giveawayWorker(uint gameId, address to, bool thief) external onlyAdmin gameOn(gameId) {
        _worker(gameId, to, thief);
    }
    
    function buyWorker(uint gameId, bool thief) external gameOn(gameId) {
        if(thief){
            require(COIN.balanceOf(_msgSender()) >= thiefPrice, "BALANCE: insuficient funds");
        } else {
             require(COIN.balanceOf(_msgSender()) >= customerPrice, "BALANCE: insuficient funds");
        }
        _worker(gameId, _msgSender(), thief);
    }
    
    function _worker(uint gameId, address to, bool thief) internal {
        (, uint index) = _getWorker(gameId,to,thief);
        require(index == 9999, "already had this worker type for this game");
        if(thief){
            require(_poolThieves[gameId].length < games[gameId].maxThieves, "MAX THIEVES REACHED");
            _poolThieves[gameId].push(Worker(to, 0));
        } else {
            require(_poolCustomers[gameId].length < games[gameId].maxCustomers, "MAX CUSTOMERS REACHED");
            _poolCustomers[gameId].push(Worker(to, 0));
        }
        emit BuyWorker(to,gameId, thief);
    }
    
    function putThief(uint gameId, uint clubId) external {
        _workerAction(gameId, clubId, true);
    }
    
    function putCustomer(uint gameId, uint stripperId) external {
        _workerAction(gameId,  stripperId, false);
    }
    
    function _workerAction(uint gameId, uint tokenId, bool thief) internal gameOn(gameId) {
        require((thief && tokenId >= 1000000) || (!thief && tokenId < 1000000), "Incompatible");
        (, uint index) = thief ?  getMyThief(gameId) : getMyCustomer(gameId);
        require(index != 9999, "NOT OWNER");
        if(thief){
            _poolThieves[gameId][index].tokenId = tokenId;
        } else {
            _poolCustomers[gameId][index].tokenId = tokenId;
        }
        emit WorkerAction(_msgSender(), gameId);
    }
    
    function getMyThief(uint gameId) public view returns (Worker memory,uint) {
        return _getWorker(gameId, _msgSender(), true);
    }
    
    function getMyCustomer(uint gameId) public view returns (Worker memory,uint) {
        return _getWorker(gameId, _msgSender(), false);
    }
    
    function _getWorker(uint gameId, address owner, bool thief) internal view returns (Worker memory,uint) {
        Worker memory worker;
        uint index = 9999;
        Worker[] memory workers = thief ? _poolThieves[gameId] : _poolCustomers[gameId];
        for(uint i=0; i< workers.length; i++){
            if(workers[i].owner == owner){
                worker = workers[i];
                index = i;
                break;
            }
        }
        return (worker, index);
    }
    
    function _getThievesByClubId(uint gameId, uint clubId) private view returns (uint) {
        Worker[] memory workers = _poolThieves[gameId];
        uint total = 0;
        for(uint i=0; i< workers.length; i++){
            if(workers[i].tokenId == clubId){
                total++;
            }
        }
        return total;
    }
    
    function wearablesCount() public view returns (uint){
        return wearables.length;
    }
    
    function addWearable(string calldata name, uint price, uint increase, bool canBuy) external onlyAdmin {
        wearables.push(Wearable(name, price, increase, canBuy));
    }
    
    function updateWearable(uint index, bool canBuy) external onlyAdmin {
        wearables[index].canBuy = canBuy;
    }
    
    function buyWearable(uint stripperId, uint wearableId) external ownerOf(stripperId) {
        Wearable memory wearable = wearables[wearableId];
        require(stripperId < 1000000, "wearable is just for strippers");
        require(COIN.balanceOf(_msgSender()) >= wearable.price, "BALANCE: insuficient funds");
        require(wearable.canBuy, "WEARABLE: cannot buy this");
        if(wearable.price > 0) {
            COIN.burnTokens(wearable.price);
        }
        stripperWearable[stripperId] = wearableId;
        emit BuyWearable(stripperId, wearableId);
    }
    
    function setGamePrize(uint newPrize) public onlyAdmin {
        gamePrize = newPrize;
    }
    
    function setWeeklyPrize(uint newPrize) public onlyAdmin {
        weeklyPrize = newPrize;
    }
    
    function setCustomerThiefPrices(uint customer, uint thief) external onlyAdmin {
        thiefPrice = thief;
        customerPrice = customer;
    }
    
    function createGame(uint price, uint maxThieves, uint maxCustomers, uint customersMultiply) external onlyAdmin {
        games.push(Game(gamePrize, block.timestamp, 0, price, maxThieves, maxCustomers, customersMultiply, false));
    }
    
    function pauseGame(uint index) public onlyAdmin {
        games[index].paused = true;
    }
    
    function getActiveGame() public view returns (uint) {
        uint active;
        for(uint i=0; i< games.length; i++){
            Game memory game = games[i];
            if(game.endDate == 0 && !game.paused){
                active = i;
                break;
            }
        }
        return active;
    }
    
    function setStripAddress(address newAddress) public onlyAdmin {
        COIN = Strip(newAddress);
    }
    
    function setStripperVilleAddress(address newAddress) public onlyAdmin {
        NFT = StripperVille(newAddress);
    }
    
    function setContracts(address coin, address nft) public onlyAdmin {
        setStripAddress(coin);
        setStripperVilleAddress(nft);
    }
    
    function nftsBalance() external view returns (uint){
        StripperVille.Asset[] memory assets = NFT.getAssetsByOwner(_msgSender());
        uint balance = 0;
        uint withdrawals = 0;
        if(assets.length == 0){
            return balance;
        }
        for(uint i = 0; i < assets.length; i++){
            balance += assets[i].earn;
            withdrawals += assets[i].withdraw;
        }
        if(withdrawals > balance){
            return 0;
        }
        return balance - withdrawals;
    }
    
    function work(uint stripperId, uint clubId, uint gameId) public ownerOf(stripperId) {
        require(_poolStripClub[gameId][stripperId] < 100000, "GAME: already set for this game");
        require(clubId >= 1000000, "CLUB: token is not a club or is not active");
        (Assets.Asset memory stripper,) = NFT.getAssetByTokenId(stripperId);
        Game memory game = games[gameId];
        require(game.endDate == 0 && !game.paused, "GAME: closed or invalid");
        require(COIN.balanceOf(_msgSender()) >= game.price, "BALANCE: insuficient funds");
        if(game.price > 0) {
            COIN.burnTokens(game.price);
        }
        uint earn = stripper.earn;
        Worker[] memory workers = _poolCustomers[gameId];
        for(uint i=0; i< workers.length; i++){
            if(workers[i].tokenId == stripperId){
                earn = earn * game.customerMultiplier;
                break;
            }
        }
        _poolStripClub[gameId][stripperId] = clubId;
        _poolClubEarn[gameId][clubId] += earn; 
        _poolClubStrippersCount[gameId][clubId]++;
        emit Work(stripperId, gameId);
    }
    
    function getClubStrippersCount(uint gameId, uint clubId) public view returns (uint) {
        Game memory game = games[gameId];
        require(game.endDate > 0, "GAME: not closed");
        return  _poolClubStrippersCount[gameId][clubId];
    }
    
    function closeGame(uint index) public onlyAdmin {
        Game storage game = games[index];
        game.endDate = block.timestamp;
        uint[] memory clubIds = getClubIds();
        for(uint i=0; i < clubIds.length; i++){
            uint one = clubIds[i];
            uint position = 1;
            uint thievesOne = _getThievesByClubId(index, one);
            uint totalOne = thievesOne > 0 ? thievesOne > 9 ? 0 : (_poolClubEarn[index][one] / 10) * (10 - thievesOne) : _poolClubEarn[index][one];
            if(totalOne > 0){
                for(uint j=0; j < clubIds.length; j++){
                    uint two = clubIds[j];
                    if(one != two){
                        uint thievesTwo = _getThievesByClubId(index, two);
                        uint totalTwo = thievesTwo > 0 ? thievesTwo > 9 ? 0 : (_poolClubEarn[index][two] / 10) * (10 - thievesTwo) : _poolClubEarn[index][two];
                        if(totalOne < totalTwo){
                            position++;
                        }
                    }
                }
            } else {
                position = 6;
            }
            if(position < 6){
                uint earn = 5;
                if(position > 2){
                    earn = earn * (6 - position);
                } else if(position == 2){
                    earn = 30;
                } else {
                    earn = 40;
                }
                poolClubPercentage[index][one] = earn;
            }
        }
    }
    
    function getClubIds() public view  returns (uint[] memory){
        uint[] memory ids = new uint[](NFT.clubsCount());
        uint j=0;
        uint initial = 1000000;
        for(uint i=0;i<ids.length;i++){
            ids[j] = i + initial;
            j++;
        }
        return ids;
    }
    
    
    function getWeeklyEarnings(uint earn, uint born) public view returns (uint) {
         return getWeeks(born) * getEarn(earn);
    }
    
    function getWeeks(uint born) public view returns (uint) {
        return ((block.timestamp - born) / WEEK) + 1;
    }
    
    function getEarn(uint value) public view returns (uint) {
        if(value > 100 ether){
            value = 100 ether;
        }
        return ((weeklyPrize / NFT.stripperSupply()) / 100) * (value / 10 ** 18);
    }
    
    function getCustomerMultiply(uint gameId, uint stripperId) public view returns(uint){
        (Worker memory worker, uint index) = getMyCustomer(gameId);
        if(index != 9999 && worker.tokenId == stripperId && games[gameId].customerMultiplier > 1){
            return games[gameId].customerMultiplier;
        }
        return 1;
    }  
    
    function getClaimableTokens(uint tokenId) public view returns (uint) {
        (Assets.Asset memory asset,) = NFT.getAssetByTokenId(tokenId);
        uint earn=0;
        if(asset.tokenType == 0){
            uint  wearableEarn = 0;
            if(stripperWearable[tokenId] > 0){
                Wearable memory wearable = wearables[stripperWearable[tokenId]];
                wearableEarn += wearable.increase;
            }
            uint totalEarn = asset.earn + wearableEarn > 100 ether ? 100 ether : asset.earn + wearableEarn;
            for(uint i=0;i<games.length;i++){
                uint baseEarn = poolClubPercentage[i][_poolStripClub[i][tokenId]];
                uint gameEarn= 0;
                if(games[i].endDate > 0 && baseEarn > 0){
                    gameEarn += (gamePrize / baseEarn) - ((gamePrize / baseEarn) / 10);
                    earn += ((gameEarn / _poolClubStrippersCount[i][_poolStripClub[i][tokenId]] / 100) * (totalEarn / 10 ** 18) * getCustomerMultiply(i, tokenId));
                }
            }
            return earn + getWeeklyEarnings(totalEarn, asset.born) - asset.withdraw;
        } else {
            for(uint i=0;i<games.length;i++){
                uint baseEarn = poolClubPercentage[i][tokenId];
                if(games[i].endDate > 0 && baseEarn > 0){
                    earn += (gamePrize / baseEarn) / 10;
                }
            }
            return earn - asset.withdraw;
        }
    }
    
    function claimTokens(uint tokenId) public ownerOf(tokenId) {
        uint balance = getClaimableTokens(tokenId);
        COIN.approveHolderTokensToGame(balance);
        COIN.transferFrom(COIN.owner(), _msgSender(), balance);
        NFT.withdrawAsset(tokenId, balance);
        emit Claim(_msgSender(), tokenId, balance);
    }

}