pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.5.0;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}
pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}
pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
pragma solidity ^0.5.0;


contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }


    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
pragma solidity ^0.5.0;


contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}
pragma solidity ^0.5.0;


contract ERC20Capped is ERC20Mintable {

    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}
pragma solidity ^0.5.0;


contract MorpheusToken is ERC20, ERC20Detailed, ERC20Capped {

    
    address public deployerAddress;
    address public gameControllerAddress;
    
    bool public locked = true; 
    

    
    constructor(address _deployer, address _gameAddress) public ERC20Detailed("MorpheusGameToken", "MGT", 18) ERC20Capped(500000000*1E18) {
              deployerAddress =_deployer;
              gameControllerAddress = _gameAddress;
    }

    modifier onlyGameController() {

        require(msg.sender == gameControllerAddress);
        _;
    }
    
    modifier onlyDeployer() {

        require(msg.sender == deployerAddress);
        _;
    }
    
    function eraseDeployerAddress() public onlyDeployer(){

        deployerAddress = address(0x0);
    }
    
    
    function unlock() public onlyDeployer {

        locked = false;
    } 
    
    function _isLocked() private view returns(bool) {

        if(now > 1607788800){
            return true;
        }
        else{
            return locked;
        } 
    }

    
    function transfer(address to, uint256 amount) public returns(bool) {

        if(_isLocked()) {
            require(msg.sender == deployerAddress,"Token is locked until December 12 2020 at 16h UTC");
            super.transfer(to, amount);
        } else{
            super.transfer(to, amount);
        }

    }

    function transferFrom(address from, address to, uint256 amount) public returns(bool) {

        if(_isLocked()) {
            require(msg.sender == deployerAddress,"Token is locked until December 12 2020 at 16h UTC");
            super.transferFrom(from, to, amount);
        } else{
            super.transferFrom(from, to, amount); 
        }

    }


    function burnTokens(uint256 _amount) public  {

        _burn(msg.sender, _amount);
    }

    function mintTokensForWinner(uint256 _amount) public onlyGameController() {

        _mint(gameControllerAddress, _amount);
    }
}
pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}
pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}
pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.5.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}
pragma solidity ^0.5.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity ^0.5.0;


contract ERC721 is Context, ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}
pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}
pragma solidity ^0.5.0;


contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}
pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}
pragma solidity ^0.5.0;


contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    string private _baseURI;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_tokenURI).length == 0) {
            return "";
        } else {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI) internal {

        _baseURI = baseURI;
    }

    function baseURI() external view returns (string memory) {

        return _baseURI;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
pragma solidity ^0.5.0;


contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}
pragma solidity 0.5.17;




contract Rabbits is ERC721Full, Ownable {

    mapping(uint256 => string) public colorRabbit;

    address public gameControllerAddress;
    address public farmControllerAddress;

    constructor() public ERC721Full("RabbitsToken", "RBTS") {

        for (uint256 i = 1; i < 11; i++) {
            colorRabbit[i] = "White";
        }

        for (uint256 i = 11; i < 61; i++) {
            colorRabbit[i] = "Blue";
        }

        for (uint256 i = 61; i < 161; i++) {
            colorRabbit[i] = "Red";
        }
    }

    modifier onlyGameController() {

        require(msg.sender == gameControllerAddress);
        _;
    }
    
    modifier onlyFarmingController() {

        require(msg.sender == farmControllerAddress);
        _;
    }

    event GameAddressChanged(address newGameAddress);
    
    event FarmAddressChanged(address newFarmAddress);
    

    function setGameAddress(address _gameAddress) public onlyOwner() {

        gameControllerAddress = _gameAddress;
        emit GameAddressChanged(_gameAddress);
    }
    
    function setFarmingAddress(address _farmAddress) public onlyOwner() {

        farmControllerAddress = _farmAddress;
        emit FarmAddressChanged(_farmAddress);
    }

    function mintRabbit(address _to, uint256 _id) public onlyFarmingController() {

        _mint(_to, _id);
    }

    function burnRabbitsTrilogy(
        address _ownerOfRabbit,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3
    ) public onlyGameController() {

        require(
            keccak256(abi.encodePacked(colorRabbit[_id1])) ==
                keccak256(abi.encodePacked("White")) &&
                keccak256(abi.encodePacked(colorRabbit[_id2])) ==
                keccak256(abi.encodePacked("Blue")) &&
                keccak256(abi.encodePacked(colorRabbit[_id3])) ==
                keccak256(abi.encodePacked("Red"))
        );
        _burn(_ownerOfRabbit, _id1);
        _burn(_ownerOfRabbit, _id2);
        _burn(_ownerOfRabbit, _id3);
    }
}
pragma solidity ^0.5.17;



contract randomOracle {


    address public gameAddress;
    MorpheusGameController public game;
    uint256 nonce = 17;
    uint8 mod = 2;
    address public deployer;
    
    using SafeMath for uint256;
    
   constructor() public{
    deployer = msg.sender;
    }
    
    modifier onlyGame() {

        require(msg.sender == gameAddress);
        _;
    }
    
    function setGame(MorpheusGameController _game, address _gameAddress) public{

        require(msg.sender==deployer,"Not your Oracle");
        game = _game;
        gameAddress = _gameAddress;
    }
    
    function getRandom(bytes32 _id) external onlyGame() returns(uint){

        return _getRandom(_id);
    }
    
    
    function _getRandom(bytes32 _id) private returns(uint256){

        uint256 _random = (uint256(keccak256(abi.encodePacked(now,_id, block.difficulty,nonce,block.number)))) % mod; 
        nonce = nonce.add(1);
        returnResult(_id,_random);
    }
    
    
    function returnResult(bytes32 _id, uint _result) private{

        game.callback(_id,_result);
    }
    
    
}
pragma solidity 0.5.17;



contract MorpheusGameController is Ownable {

    using SafeMath for uint256;
    
    constructor(randomOracle _oracle, address _oracleAddress)
        public
    {
        _lastRewardTime = now;
        beginningTime = now;
        
        oracle = _oracle;
        oracleAddress = _oracleAddress;
    }

    MorpheusToken public morpheus;
    Rabbits public rabbits;
    randomOracle public oracle;
    
    address public oracleAddress;
    
    uint256 public beginningTime;

    uint256 private _lastRewardTime;
    uint256 private _rewardPool;

    uint256 private _numberOfPeriod = 1;

    uint256 private _totalValuePlayed;
    uint256 private _totalValueBurned;
    
    uint256 private _totalValuePlayedOnPeriod;
    
    uint256 public minimumBalanceForClaim = 10000*1E18;

    address[] public _playersFromPeriod;

    address[] private _zionStackers;


    mapping(address => uint256) private _myRewardTokens;

    mapping(address => uint256) private _myPeriodLoss;
    mapping(address => uint256) private _myPeriodBets;

    address public kingOfTheMountain;

    event alertEvent(string alert);
    
    event rewardClaimed(address claimer,uint256 claimerGain,uint256 burntValue);
    event newKingOfTheMountain(address king);
    event gotAResult(address _player, uint8 _result);
    

    

    function setMorpheusToken(MorpheusToken _morpheusToken) public onlyOwner() {

        morpheus = _morpheusToken;
        emit alertEvent("Morpheus token has been set");
    }

    function setRabbitsToken(Rabbits _rabbits) public onlyOwner() {

        rabbits = _rabbits;
        emit alertEvent("Rabbits token has been set");
    }
    
    function setMinimumBalanceForClaim(uint256 _amount) public onlyOwner() {

        minimumBalanceForClaim = _amount.mul(1E18);
        emit alertEvent("Minimum balance for claim has been updated");
    }
    
    
    
    uint256 _zionStackingValue = 50000;
    
    function setStackingValue(uint256 _amount) public onlyOwner(){

        _zionStackingValue = _amount;
    }
    
    function getZionStackersNumber() public view returns(uint256 _numberOfStackers){

        return(_zionStackers.length);
    }

    function becomeZionStacker() public {

        require(morpheus.balanceOf(msg.sender)>_zionStackingValue.mul(1E18),"Not enough balance");
        require(!isStacker(msg.sender),"Already a Zion stacker");
        require(_zionStackers.length<50, "There's no place place for you");
        morpheus.transferFrom(msg.sender, address(this), _zionStackingValue.mul(1E18));
        _zionStackers.push(msg.sender);
    }
    
    function _eraseZionStackers() private {

        address[] memory _emptyArray;
        _zionStackers = _emptyArray;
    }
    
    function isStacker(address _user) public view returns(bool){

        bool _isStacker = false;
        for(uint256 i = 0 ; i<_zionStackers.length ; i++){
            if(_zionStackers[i] == _user){
                _isStacker = true;
                break;
            }
        }
        return _isStacker;
    }



    function getGameData()
        public
        view
        returns (
            uint256 totalPeriod,
            uint256 totalValuePlayed,
            uint256 totalValuePlayedOnPeriod,
            uint256 totalValueBurned,
            uint256 lastRewardTime,
            uint256 actualPool,
            uint256 totalPlayersForThosePeriod
        )
    {

        return (
            _numberOfPeriod,
            _totalValuePlayed,
            _totalValuePlayedOnPeriod,
            _totalValueBurned,
            _lastRewardTime,
            _rewardPool,
            _playersFromPeriod.length
        );
    }

    function getPersonnalData(address _user)
        public
        view
        returns (
            uint256 playerRewardTokens,
            uint256 playerPeriodLoss,
            uint256 playerPeriodBets
        )
    {

        return (
            _myRewardTokens[_user],
            _myPeriodLoss[_user],
            _myPeriodBets[_user]
        );
    }



    struct gameInstance {
        address player;
        uint8 choice;
        uint256 amount;
    }
    
    uint256 public gameInstanceNumber = 0;

    mapping(bytes32 => gameInstance) gamesInstances;

    function choosePils(uint256 amount, uint8 _choice) public payable {

        require(amount > 0 && amount <= 250000,"Your bet must be between 0 to 250 000 MGT");
        uint256 _amount = amount.mul(1E18);
        require(morpheus.balanceOf(msg.sender) > _amount, "You don't have suffisant balance");
        require(_choice == 0 || _choice == 1, "Choice must be 0 or 1" );

        morpheus.transferFrom(msg.sender, address(this), _amount);
        
        gameInstanceNumber = gameInstanceNumber.add(1);
         
        if(!_isPlayerInList(msg.sender)){
          _playersFromPeriod.push(msg.sender);
        }

        _totalValuePlayed = _totalValuePlayed.add(_amount);
        
        _totalValuePlayedOnPeriod = _totalValuePlayedOnPeriod.add(_amount);

        _myPeriodBets[msg.sender] = _myPeriodBets[msg.sender].add(_amount);

        if (_myPeriodBets[msg.sender] > _myPeriodBets[kingOfTheMountain]) {
            kingOfTheMountain = msg.sender;
            emit newKingOfTheMountain(msg.sender);
        }

        bytes32 _id = keccak256(abi.encodePacked(
            _rewardPool.add(1),
            _totalValuePlayed,
            _lastRewardTime,
            _totalValueBurned.add(1)
            ));
            
        gamesInstances[_id] = gameInstance(msg.sender, _choice, _amount);
        oracle.getRandom(_id);
    }

    function callback(bytes32 _id,uint _result) external {

        require(msg.sender == oracleAddress, "Callback doesn't come from good Oracle");
        require(gamesInstances[_id].player != address(0x0), "Instance dosn't exist");

            if (_result == gamesInstances[_id].choice) {
                morpheus.mintTokensForWinner(gamesInstances[_id].amount);
                morpheus.transfer(
                    gamesInstances[_id].player,
                    gamesInstances[_id].amount.mul(2)
                );
                emit gotAResult(gamesInstances[_id].player,1);
                    
            } else {
                _myPeriodLoss[gamesInstances[_id].player] = (_myPeriodLoss[gamesInstances[_id].player]).add(gamesInstances[_id].amount);
    
                _rewardPool = _rewardPool.add(gamesInstances[_id].amount);
    
                emit gotAResult(gamesInstances[_id].player, 0);
                
            }

        delete gamesInstances[_id];
        gameInstanceNumber = gameInstanceNumber.sub(1);
    }
    
    function _isPlayerInList(address _player) internal view returns (bool) {

        bool exist = false;
        for (uint8 i = 0; i < _playersFromPeriod.length; i++) {
            if (_playersFromPeriod[i] == _player) {
                exist = true;
                break;
            }
        }
        return exist;
    }

    function _getKingOfLoosers() public view returns (address) {

        address _kingOfLoosers;
        uint256 _valueLost = 0;
        for (uint256 i = 0; i < _playersFromPeriod.length; i++) {
            if (
                _myPeriodBets[_playersFromPeriod[i]].div(2) <
                _myPeriodLoss[_playersFromPeriod[i]]
            ) {
                uint256 _lostByi = _myPeriodLoss[_playersFromPeriod[i]].sub(
                    _myPeriodBets[_playersFromPeriod[i]].div(2)
                );
                if (_valueLost < _lostByi) {
                    _valueLost = _lostByi;
                    _kingOfLoosers = _playersFromPeriod[i];
                }
            }
        }
        return (_kingOfLoosers);
    }


    function claimRewards() public {

        require(gameInstanceNumber == 0, "There is a game instance pending please wait");
        require(_rewardPool > 0,"Reward pool is empty !!!");
        require(morpheus.balanceOf(msg.sender)>minimumBalanceForClaim,"You don't have enough MGT for call this function");

        uint256 _tempRewardPool = _rewardPool;
        uint256 _originalLostValue = _rewardPool;
        _rewardPool = 0;
        _totalValuePlayedOnPeriod = 0;
        _lastRewardTime = now;

        _numberOfPeriod = _numberOfPeriod.add(1);

        uint256 rewardForKings = (_tempRewardPool.mul(100)).div(10000);
        _transferToKingOfMountain(rewardForKings);
        
        if(_getKingOfLoosers() != address(0x0)){
            _transferToKingOfLoosers(rewardForKings);
        }

        
        uint256 _claimerPercentage = _getClaimerPercentage();
        uint256 rewardForClaimer = (_tempRewardPool.mul(_claimerPercentage)).div(10000);
        morpheus.transfer(msg.sender, rewardForClaimer);

        uint256 burnPercentage = _getBurnPercentage();
        uint256 totalToBurn = (_tempRewardPool.mul(burnPercentage)).div(10000);
        morpheus.burnTokens(totalToBurn);
        _totalValueBurned = _totalValueBurned.add(totalToBurn);

        if(_getKingOfLoosers() != address(0x0)){
            _tempRewardPool = _tempRewardPool.sub(rewardForKings);
        }
        _tempRewardPool = _tempRewardPool.sub(rewardForKings);
        _tempRewardPool = _tempRewardPool.sub(rewardForClaimer);
        _tempRewardPool = _tempRewardPool.sub(totalToBurn);

        if(_zionStackers.length>0){
            
            uint256 rewardForZionStackers = (_tempRewardPool.mul(1000)).div(10000);
            _transferToZionStackers(rewardForZionStackers);

            _tempRewardPool = _tempRewardPool.sub(rewardForZionStackers);
        }

        _setRewards(_tempRewardPool,_originalLostValue);

        emit rewardClaimed(msg.sender, rewardForClaimer, totalToBurn);
    }

    function claimMyReward() public {

        require(_myRewardTokens[msg.sender] > 0, "You don't have any token to claim");
        uint256 _myTempRewardTokens = _myRewardTokens[msg.sender];
        _myRewardTokens[msg.sender] = 0;
        morpheus.transfer(msg.sender, _myTempRewardTokens);
    }
    
    function _getClaimerPercentage() public view returns (uint256) {

        uint256 _timeSinceLastReward = now.sub(_lastRewardTime);
        uint256 _claimPercentage = 50;

        if (_timeSinceLastReward > 1 days && _timeSinceLastReward < 2 days) {
            _claimPercentage = 100;
        }
        if (_timeSinceLastReward >= 2 days && _timeSinceLastReward < 3 days) {
            _claimPercentage = 150;
        }
        if (_timeSinceLastReward >= 3 days && _timeSinceLastReward < 4 days) {
            _claimPercentage = 200;
        }
        if (_timeSinceLastReward >= 4 days && _timeSinceLastReward < 5 days) {
            _claimPercentage = 250;
        }
        if (_timeSinceLastReward >= 5 days) {
            _claimPercentage = 300;
        }
        return _claimPercentage;
    }

    function _getBurnPercentage() public view returns (uint256) {

        uint256 _timeSinceLastReward = now.sub(_lastRewardTime);
        uint256 _burnPercentage = 8950;

        if (_timeSinceLastReward > 1 days && _timeSinceLastReward < 2 days) {
            _burnPercentage = 7900;
        }
        if (_timeSinceLastReward >= 2 days && _timeSinceLastReward < 3 days) {
            _burnPercentage = 6850;
        }
        if (_timeSinceLastReward >= 3 days && _timeSinceLastReward < 4 days) {
            _burnPercentage = 5800;
        }
        if (_timeSinceLastReward >= 4 days && _timeSinceLastReward < 5 days) {
            _burnPercentage = 4750;
        }
        if (_timeSinceLastReward >= 5 days ) {
            _burnPercentage = 3700;
        }
        return _burnPercentage;
    }

    function _setRewards(uint256 _rewardAmmount, uint256 _originalLostValue) private {

        require(_originalLostValue > 0 && _playersFromPeriod.length > 0);
        uint256 _tempTotalRewardPart = _originalLostValue.mul(100);

        for (uint256 i = 0; i < _playersFromPeriod.length; i++) {
            if (_myPeriodLoss[_playersFromPeriod[i]] > 0) {
                uint256 _myTempRewardPart
                 = _myPeriodLoss[_playersFromPeriod[i]].mul(100);
                _myPeriodLoss[_playersFromPeriod[i]] = 0;

                uint256 _oldPersonnalReward
                 = _myRewardTokens[_playersFromPeriod[i]];
                _myRewardTokens[_playersFromPeriod[i]] = 0;

                uint256 personnalReward = (
                    _rewardAmmount.mul(_myTempRewardPart)
                )
                    .div(_tempTotalRewardPart);

                _myRewardTokens[_playersFromPeriod[i]] = _oldPersonnalReward
                    .add(personnalReward);
            }
        }
        _deleteAllPlayersFromPeriod();
    }

    function _deleteAllPlayersFromPeriod() private {

        for (uint256 i = 0; i < _playersFromPeriod.length; i++) {
            _myPeriodLoss[_playersFromPeriod[i]] = 0;
            _myPeriodBets[_playersFromPeriod[i]] = 0;
        }
        address[] memory _newArray;
        _playersFromPeriod =_newArray;
    }

    function _transferToZionStackers(uint256 _amount) private {

        uint256 amountModuloStackersNumber = _amount.sub(_amount % _zionStackers.length);
        uint256 _toTransfer = amountModuloStackersNumber.div(_zionStackers.length);
        _toTransfer = _toTransfer.add(_zionStackingValue.mul(1E18));
        for (uint256 i = 0; i < _zionStackers.length; i++) {
            morpheus.transfer(
                _zionStackers[i],
                _toTransfer
            );
        }
        _eraseZionStackers();
    }

    function _transferToKingOfMountain(uint256 _amount) private {

        require(kingOfTheMountain != address(0x0), "There is no king of the mountain ");
        address _kingOfTheMountain = kingOfTheMountain;
        kingOfTheMountain = address(0x0);

        morpheus.transfer(_kingOfTheMountain, _amount);
    }

    function _transferToKingOfLoosers(uint256 _amount) private {

        if(_getKingOfLoosers() != address(0x0)){
            morpheus.transfer(_getKingOfLoosers(), _amount);           
        }
    }

    

    function superClaim(
        uint256 _id1,
        uint256 _id2,
        uint256 _id3
    ) public {

        require(gameInstanceNumber == 0, "There is a game instance pending please wait");
        require(_rewardPool > 0, "There is no reward on pool");
        require(now.sub(beginningTime) >= 40 days);
        require(
            (rabbits.ownerOf(_id1) == msg.sender &&
            rabbits.ownerOf(_id2) == msg.sender &&
            rabbits.ownerOf(_id3) == msg.sender),
            "You don't have the required Rabbits !!!"
        );
        uint256 _tempRewardPool = _rewardPool;
        _rewardPool = 0;
        
        _numberOfPeriod = _numberOfPeriod.add(1);
        _lastRewardTime = now;
        
        uint256 rewardForKings = (_tempRewardPool.mul(1)).div(100);
        _transferToKingOfMountain(rewardForKings);
        _transferToKingOfLoosers(rewardForKings);
        
        uint256 rewardForClaimer = _tempRewardPool.div(2);
        morpheus.transfer(msg.sender, rewardForClaimer);
        
        _tempRewardPool = _tempRewardPool.sub(rewardForClaimer);
        _tempRewardPool = _tempRewardPool.sub(rewardForKings.mul(2));
        
        morpheus.burnTokens(_tempRewardPool);
        _totalValueBurned = _totalValueBurned.add(_tempRewardPool);

        rabbits.burnRabbitsTrilogy(msg.sender, _id1, _id2, _id3);
        _deleteAllPlayersFromPeriod();

    }
    

}
pragma solidity 0.5.17;


contract Airdrop is Ownable {

    
    using SafeMath for uint256;
    
    MorpheusToken public morpheus;
    
    mapping(address => bool) asBeenAirdroped;
    
    constructor(MorpheusToken _morpheusToken) public {
        setMorpheusToken(_morpheusToken);
    }
    
    function setMorpheusToken(MorpheusToken _morpheusToken) public onlyOwner() {

        morpheus = _morpheusToken;
    }
    
    function sendToken(uint256 _amount) public onlyOwner(){

        uint256 amount = _amount.mul(1E18);
        morpheus.transferFrom(msg.sender, address(this), amount);
    }
    
    function airdrop(uint256 _amount, address[] memory _recipients)public onlyOwner(){

        uint256 amount = _amount.mul(1E18);
        for(uint256 i=0; i<_recipients.length;i++){
            if(asBeenAirdroped[_recipients[i]] == false){
                asBeenAirdroped[_recipients[i]] == true;
                morpheus.transfer(_recipients[i],amount);   
            }

        }
    }
}
pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}
pragma solidity ^0.5.0;


contract Crowdsale is Context, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;

    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    function () external payable {
        buyTokens(_msgSender());
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function wallet() public view returns (address payable) {

        return _wallet;
    }

    function rate() public view returns (uint256) {

        return _rate;
    }

    function weiRaised() public view returns (uint256) {

        return _weiRaised;
    }

    function buyTokens(address beneficiary) public nonReentrant payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _deliverTokens(beneficiary, tokenAmount);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.mul(_rate);
    }

    function _forwardFunds() internal {

        _wallet.transfer(msg.value);
    }
}
pragma solidity ^0.5.0;


contract CappedCrowdsale is Crowdsale {

    using SafeMath for uint256;

    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "CappedCrowdsale: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function capReached() public view returns (bool) {

        return weiRaised() >= _cap;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiRaised().add(weiAmount) <= _cap, "CappedCrowdsale: cap exceeded");
    }
}
pragma solidity ^0.5.0;


contract ERC721Burnable is Context, ERC721 {

    function burn(uint256 tokenId) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}
pragma solidity 0.5.17;



contract MarketPlace is Ownable {

    
    using SafeMath for uint256;
    
    Rabbits public rabbits;
    MorpheusToken public morpheus;
    
    constructor(Rabbits _rabbits, MorpheusToken _morpheusToken) public{
        setRabbitsToken(_rabbits);
        setMorpheusToken(_morpheusToken);
    }
    
    event newSellingInstance(uint256 _tokenId, uint256 _amountAsked);
    event rabbitSold(uint256 _tokenId, address _newOwner);
    event sellingCanceled(uint256 _tokenId);
    

    
    function setRabbitsToken(Rabbits _rabbits) public onlyOwner() {

        rabbits = _rabbits;
    }
    
    function setMorpheusToken(MorpheusToken _morpheusToken) public onlyOwner() {

        morpheus = _morpheusToken;
    }
    

    uint256 onSaleQuantity = 0;
    uint256[] public tokensOnSale;

    struct sellInstance{
        uint256 tokenId;
        uint256 amountAsked;
        bool onSale;
        address owner;
    }
    
    mapping(uint256 => sellInstance) public sellsInstances;
    
    function sellingMyRabbit(uint256 _tokenId, uint256 _amountAsked) public {

        require(rabbits.ownerOf(_tokenId) == msg.sender, "Not your Rabbit");
        rabbits.transferFrom(msg.sender,address(this),_tokenId);
        sellsInstances[_tokenId] = sellInstance(_tokenId,_amountAsked,true,msg.sender);
        onSaleQuantity = onSaleQuantity.add(1);
        tokensOnSale.push(_tokenId);
        emit newSellingInstance(_tokenId,_amountAsked);
    }
    
    function cancelMySellingInstance(uint256 _tokenId)public{

        require(sellsInstances[_tokenId].owner == msg.sender, "Not your Rabbit");
        rabbits.transferFrom(address(this),msg.sender,_tokenId);
        uint256 index = getSellingIndexOfToken(_tokenId);
        delete tokensOnSale[index];
        delete sellsInstances[_tokenId];
        onSaleQuantity = onSaleQuantity.sub(1);
        emit sellingCanceled(_tokenId);
    }
    
    function buyTheRabbit(uint256 _tokenId, uint256 _amount)public{

        require(sellsInstances[_tokenId].onSale == true,"Not on Sale");
        require(_amount == sellsInstances[_tokenId].amountAsked,"Not enough Value");
        uint256 amount = _amount.mul(1E18);
        require(morpheus.balanceOf(msg.sender) > amount, "You don't got enough MGT");
        morpheus.transferFrom(msg.sender,sellsInstances[_tokenId].owner,amount);
        rabbits.transferFrom(address(this),msg.sender,_tokenId);
        uint256 index = getSellingIndexOfToken(_tokenId);
        delete tokensOnSale[index];
        delete sellsInstances[_tokenId];
        onSaleQuantity = onSaleQuantity.sub(1);
        emit rabbitSold(_tokenId,msg.sender);
    }
    
    function getSellingIndexOfToken(uint256 _tokenId) private view returns(uint256){

        require(sellsInstances[_tokenId].onSale == true, "Not on sale");
        uint256 index;
        for(uint256 i = 0 ; i< tokensOnSale.length ; i++){
            if(tokensOnSale[i] == _tokenId){
                index = i;
                break;
            }
        }
        return index;
    }
    
}
pragma solidity ^0.5.0;


contract TimedCrowdsale is Crowdsale {

    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

    modifier onlyWhileOpen {

        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    constructor (uint256 openingTime, uint256 closingTime) public {
        require(openingTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        require(closingTime > openingTime, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    function openingTime() public view returns (uint256) {

        return _openingTime;
    }

    function closingTime() public view returns (uint256) {

        return _closingTime;
    }

    function isOpen() public view returns (bool) {

        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    function hasClosed() public view returns (bool) {

        return block.timestamp > _closingTime;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {

        super._preValidatePurchase(beneficiary, weiAmount);
    }

    function _extendTime(uint256 newClosingTime) internal {

        require(!hasClosed(), "TimedCrowdsale: already closed");
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}
pragma solidity ^0.5.0;


contract MintedCrowdsale is Crowdsale {

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        require(
            ERC20Mintable(address(token())).mint(beneficiary, tokenAmount),
                "MintedCrowdsale: minting failed"
        );
    }
}
pragma solidity 0.5.17;



contract MGTCrowdsale is Crowdsale, TimedCrowdsale, CappedCrowdsale, MintedCrowdsale{

    

    constructor(address payable _deployer, address _gameAddress)
        public
        Crowdsale(
            50000,
            _deployer,
            new MorpheusToken(_deployer, _gameAddress)
        )
        TimedCrowdsale(1607180400, 1607785200)  // time began is 1607180400
        CappedCrowdsale(600*1E18)
    {

    _deliverTokens(_deployer, 12022556*1E18);
    }
}
pragma solidity >=0.4.22 <0.8.0;

contract Migrations {

  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {

    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }
}
pragma solidity 0.5.17; // Incompatible compiler version - please select a compiler within the stated pragma range, or use a different version of the provableAPI!

contract solcChecker {

    function f(bytes calldata x) external;

}

contract ProvableI {

    address public cbAddress;

    function setProofType(bytes1 _proofType) external;


    function setCustomGasPrice(uint256 _gasPrice) external;


    function getPrice(string memory _datasource)
        public
        returns (uint256 _dsprice);


    function randomDS_getSessionPubKeyHash()
        external
        view
        returns (bytes32 _sessionKeyHash);


    function getPrice(string memory _datasource, uint256 _gasLimit)
        public
        returns (uint256 _dsprice);


    function queryN(
        uint256 _timestamp,
        string memory _datasource,
        bytes memory _argN
    ) public payable returns (bytes32 _id);


    function query(
        uint256 _timestamp,
        string calldata _datasource,
        string calldata _arg
    ) external payable returns (bytes32 _id);


    function query2(
        uint256 _timestamp,
        string memory _datasource,
        string memory _arg1,
        string memory _arg2
    ) public payable returns (bytes32 _id);


    function query_withGasLimit(
        uint256 _timestamp,
        string calldata _datasource,
        string calldata _arg,
        uint256 _gasLimit
    ) external payable returns (bytes32 _id);


    function queryN_withGasLimit(
        uint256 _timestamp,
        string calldata _datasource,
        bytes calldata _argN,
        uint256 _gasLimit
    ) external payable returns (bytes32 _id);


    function query2_withGasLimit(
        uint256 _timestamp,
        string calldata _datasource,
        string calldata _arg1,
        string calldata _arg2,
        uint256 _gasLimit
    ) external payable returns (bytes32 _id);

}

contract OracleAddrResolverI {

    function getAddress() public returns (address _address);

}

library Buffer {

    struct buffer {
        bytes buf;
        uint256 capacity;
    }

    function init(buffer memory _buf, uint256 _capacity) internal pure {

        uint256 capacity = _capacity;
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        _buf.capacity = capacity; // Allocate space for the buffer data
        assembly {
            let ptr := mload(0x40)
            mstore(_buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(ptr, capacity))
        }
    }

    function resize(buffer memory _buf, uint256 _capacity) private pure {

        bytes memory oldbuf = _buf.buf;
        init(_buf, _capacity);
        append(_buf, oldbuf);
    }

    function max(uint256 _a, uint256 _b) private pure returns (uint256 _max) {

        if (_a > _b) {
            return _a;
        }
        return _b;
    }

    function append(buffer memory _buf, bytes memory _data)
        internal
        pure
        returns (buffer memory _buffer)
    {

        if (_data.length + _buf.buf.length > _buf.capacity) {
            resize(_buf, max(_buf.capacity, _data.length) * 2);
        }
        uint256 dest;
        uint256 src;
        uint256 len = _data.length;
        assembly {
            let bufptr := mload(_buf) // Memory address of the buffer data
            let buflen := mload(bufptr) // Length of existing buffer data
            dest := add(add(bufptr, buflen), 32) // Start address = buffer address + buffer length + sizeof(buffer length)
            mstore(bufptr, add(buflen, mload(_data))) // Update buffer length
            src := add(_data, 32)
        }
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint256 mask = 256**(32 - len) - 1; // Copy remaining bytes
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
        return _buf;
    }

    function append(buffer memory _buf, uint8 _data) internal pure {

        if (_buf.buf.length + 1 > _buf.capacity) {
            resize(_buf, _buf.capacity * 2);
        }
        assembly {
            let bufptr := mload(_buf) // Memory address of the buffer data
            let buflen := mload(bufptr) // Length of existing buffer data
            let dest := add(add(bufptr, buflen), 32) // Address = buffer address + buffer length + sizeof(buffer length)
            mstore8(dest, _data)
            mstore(bufptr, add(buflen, 1)) // Update buffer length
        }
    }

    function appendInt(
        buffer memory _buf,
        uint256 _data,
        uint256 _len
    ) internal pure returns (buffer memory _buffer) {

        if (_len + _buf.buf.length > _buf.capacity) {
            resize(_buf, max(_buf.capacity, _len) * 2);
        }
        uint256 mask = 256**_len - 1;
        assembly {
            let bufptr := mload(_buf) // Memory address of the buffer data
            let buflen := mload(bufptr) // Length of existing buffer data
            let dest := add(add(bufptr, buflen), _len) // Address = buffer address + buffer length + sizeof(buffer length) + len
            mstore(dest, or(and(mload(dest), not(mask)), _data))
            mstore(bufptr, add(buflen, _len)) // Update buffer length
        }
        return _buf;
    }
}

library CBOR {

    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    function encodeType(
        Buffer.buffer memory _buf,
        uint8 _major,
        uint256 _value
    ) private pure {

        if (_value <= 23) {
            _buf.append(uint8((_major << 5) | _value));
        } else if (_value <= 0xFF) {
            _buf.append(uint8((_major << 5) | 24));
            _buf.appendInt(_value, 1);
        } else if (_value <= 0xFFFF) {
            _buf.append(uint8((_major << 5) | 25));
            _buf.appendInt(_value, 2);
        } else if (_value <= 0xFFFFFFFF) {
            _buf.append(uint8((_major << 5) | 26));
            _buf.appendInt(_value, 4);
        } else if (_value <= 0xFFFFFFFFFFFFFFFF) {
            _buf.append(uint8((_major << 5) | 27));
            _buf.appendInt(_value, 8);
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory _buf, uint8 _major)
        private
        pure
    {

        _buf.append(uint8((_major << 5) | 31));
    }

    function encodeUInt(Buffer.buffer memory _buf, uint256 _value)
        internal
        pure
    {

        encodeType(_buf, MAJOR_TYPE_INT, _value);
    }

    function encodeInt(Buffer.buffer memory _buf, int256 _value) internal pure {

        if (_value >= 0) {
            encodeType(_buf, MAJOR_TYPE_INT, uint256(_value));
        } else {
            encodeType(_buf, MAJOR_TYPE_NEGATIVE_INT, uint256(-1 - _value));
        }
    }

    function encodeBytes(Buffer.buffer memory _buf, bytes memory _value)
        internal
        pure
    {

        encodeType(_buf, MAJOR_TYPE_BYTES, _value.length);
        _buf.append(_value);
    }

    function encodeString(Buffer.buffer memory _buf, string memory _value)
        internal
        pure
    {

        encodeType(_buf, MAJOR_TYPE_STRING, bytes(_value).length);
        _buf.append(bytes(_value));
    }

    function startArray(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_ARRAY);
    }

    function startMap(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_MAP);
    }

    function endSequence(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_CONTENT_FREE);
    }
}

contract usingProvable {

    using CBOR for Buffer.buffer;

    ProvableI provable;
    OracleAddrResolverI OAR;

    uint256 constant day = 60 * 60 * 24;
    uint256 constant week = 60 * 60 * 24 * 7;
    uint256 constant month = 60 * 60 * 24 * 30;

    bytes1 constant proofType_NONE = 0x00;
    bytes1 constant proofType_Ledger = 0x30;
    bytes1 constant proofType_Native = 0xF0;
    bytes1 constant proofStorage_IPFS = 0x01;
    bytes1 constant proofType_Android = 0x40;
    bytes1 constant proofType_TLSNotary = 0x10;

    string provable_network_name;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_consensys = 161;

    mapping(bytes32 => bytes32) provable_randomDS_args;
    mapping(bytes32 => bool) provable_randomDS_sessionKeysHashVerified;

    modifier provableAPI {

        if ((address(OAR) == address(0)) || (getCodeSize(address(OAR)) == 0)) {
            provable_setNetwork(networkID_auto);
        }
        if (address(provable) != OAR.getAddress()) {
            provable = ProvableI(OAR.getAddress());
        }
        _;
    }

    modifier provable_randomDS_proofVerify(
        bytes32 _queryId,
        string memory _result,
        bytes memory _proof
    ) {

        require(
            (_proof[0] == "L") &&
                (_proof[1] == "P") &&
                (uint8(_proof[2]) == uint8(1))
        );
        bool proofVerified = provable_randomDS_proofVerify__main(
            _proof,
            _queryId,
            bytes(_result),
            provable_getNetworkName()
        );
        require(proofVerified);
        _;
    }

    function provable_setNetwork(uint8 _networkID)
        internal
        returns (bool _networkSet)
    {

        _networkID; // NOTE: Silence the warning and remain backwards compatible
        return provable_setNetwork();
    }

    function provable_setNetworkName(string memory _network_name) internal {

        provable_network_name = _network_name;
    }

    function provable_getNetworkName()
        internal
        view
        returns (string memory _networkName)
    {

        return provable_network_name;
    }

    function provable_setNetwork() internal returns (bool _networkSet) {

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed) > 0) {
            OAR = OracleAddrResolverI(
                0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed
            );
            provable_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1) > 0) {
            OAR = OracleAddrResolverI(
                0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1
            );
            provable_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e) > 0) {
            OAR = OracleAddrResolverI(
                0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e
            );
            provable_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48) > 0) {
            OAR = OracleAddrResolverI(
                0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48
            );
            provable_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0xa2998EFD205FB9D4B4963aFb70778D6354ad3A41) > 0) {
            OAR = OracleAddrResolverI(
                0xa2998EFD205FB9D4B4963aFb70778D6354ad3A41
            );
            provable_setNetworkName("eth_goerli");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475) > 0) {
            OAR = OracleAddrResolverI(
                0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475
            );
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF) > 0) {
            OAR = OracleAddrResolverI(
                0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF
            );
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA) > 0) {
            OAR = OracleAddrResolverI(
                0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA
            );
            return true;
        }
        return false;
    }

    function __callback(bytes32 _myid, string memory _result) public {

        __callback(_myid, _result, new bytes(0));
    }

    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    ) public {

        _myid;
        _result;
        _proof;
        provable_randomDS_args[bytes32(0)] = bytes32(0);
    }

    function provable_getPrice(string memory _datasource)
        internal
        provableAPI
        returns (uint256 _queryPrice)
    {

        return provable.getPrice(_datasource);
    }

    function provable_getPrice(string memory _datasource, uint256 _gasLimit)
        internal
        provableAPI
        returns (uint256 _queryPrice)
    {

        return provable.getPrice(_datasource, _gasLimit);
    }

    function provable_query(string memory _datasource, string memory _arg)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query.value(price)(0, _datasource, _arg);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string memory _arg
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query.value(price)(_timestamp, _datasource, _arg);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string memory _arg,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return
            provable.query_withGasLimit.value(price)(
                _timestamp,
                _datasource,
                _arg,
                _gasLimit
            );
    }

    function provable_query(
        string memory _datasource,
        string memory _arg,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return
            provable.query_withGasLimit.value(price)(
                0,
                _datasource,
                _arg,
                _gasLimit
            );
    }

    function provable_query(
        string memory _datasource,
        string memory _arg1,
        string memory _arg2
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return provable.query2.value(price)(0, _datasource, _arg1, _arg2);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string memory _arg1,
        string memory _arg2
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        return
            provable.query2.value(price)(_timestamp, _datasource, _arg1, _arg2);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string memory _arg1,
        string memory _arg2,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return
            provable.query2_withGasLimit.value(price)(
                _timestamp,
                _datasource,
                _arg1,
                _arg2,
                _gasLimit
            );
    }

    function provable_query(
        string memory _datasource,
        string memory _arg1,
        string memory _arg2,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        return
            provable.query2_withGasLimit.value(price)(
                0,
                _datasource,
                _arg1,
                _arg2,
                _gasLimit
            );
    }

    function provable_query(string memory _datasource, string[] memory _argN)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return provable.queryN.value(price)(0, _datasource, args);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[] memory _argN
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return provable.queryN.value(price)(_timestamp, _datasource, args);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[] memory _argN,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return
            provable.queryN_withGasLimit.value(price)(
                _timestamp,
                _datasource,
                args,
                _gasLimit
            );
    }

    function provable_query(
        string memory _datasource,
        string[] memory _argN,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = stra2cbor(_argN);
        return
            provable.queryN_withGasLimit.value(price)(
                0,
                _datasource,
                args,
                _gasLimit
            );
    }

    function provable_query(string memory _datasource, string[1] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[1] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[1] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        string[1] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[2] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[2] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[2] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        string[2] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[3] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[3] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[3] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        string[3] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[4] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[4] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[4] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        string[4] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, string[5] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[5] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        string[5] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        string[5] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[] memory _argN)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return provable.queryN.value(price)(0, _datasource, args);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[] memory _argN
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource);
        if (price > 1 ether + tx.gasprice * 200000) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return provable.queryN.value(price)(_timestamp, _datasource, args);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[] memory _argN,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return
            provable.queryN_withGasLimit.value(price)(
                _timestamp,
                _datasource,
                args,
                _gasLimit
            );
    }

    function provable_query(
        string memory _datasource,
        bytes[] memory _argN,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        uint256 price = provable.getPrice(_datasource, _gasLimit);
        if (price > 1 ether + tx.gasprice * _gasLimit) {
            return 0; // Unexpectedly high price
        }
        bytes memory args = ba2cbor(_argN);
        return
            provable.queryN_withGasLimit.value(price)(
                0,
                _datasource,
                args,
                _gasLimit
            );
    }

    function provable_query(string memory _datasource, bytes[1] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[1] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[1] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        bytes[1] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = _args[0];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[2] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[2] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[2] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        bytes[2] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[3] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[3] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[3] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        bytes[3] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[4] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[4] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[4] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        bytes[4] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_query(string memory _datasource, bytes[5] memory _args)
        internal
        provableAPI
        returns (bytes32 _id)
    {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[5] memory _args
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs);
    }

    function provable_query(
        uint256 _timestamp,
        string memory _datasource,
        bytes[5] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);
    }

    function provable_query(
        string memory _datasource,
        bytes[5] memory _args,
        uint256 _gasLimit
    ) internal provableAPI returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = _args[0];
        dynargs[1] = _args[1];
        dynargs[2] = _args[2];
        dynargs[3] = _args[3];
        dynargs[4] = _args[4];
        return provable_query(_datasource, dynargs, _gasLimit);
    }

    function provable_setProof(bytes1 _proofP) internal provableAPI {

        return provable.setProofType(_proofP);
    }

    function provable_cbAddress()
        internal
        provableAPI
        returns (address _callbackAddress)
    {

        return provable.cbAddress();
    }

    function getCodeSize(address _addr) internal view returns (uint256 _size) {

        assembly {
            _size := extcodesize(_addr)
        }
    }

    function provable_setCustomGasPrice(uint256 _gasPrice)
        internal
        provableAPI
    {

        return provable.setCustomGasPrice(_gasPrice);
    }

    function provable_randomDS_getSessionPubKeyHash()
        internal
        provableAPI
        returns (bytes32 _sessionKeyHash)
    {

        return provable.randomDS_getSessionPubKeyHash();
    }

    function parseAddr(string memory _a)
        internal
        pure
        returns (address _parsedAddress)
    {

        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function strCompare(string memory _a, string memory _b)
        internal
        pure
        returns (int256 _returnCode)
    {

        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint256 minLength = a.length;
        if (b.length < minLength) {
            minLength = b.length;
        }
        for (uint256 i = 0; i < minLength; i++) {
            if (a[i] < b[i]) {
                return -1;
            } else if (a[i] > b[i]) {
                return 1;
            }
        }
        if (a.length < b.length) {
            return -1;
        } else if (a.length > b.length) {
            return 1;
        } else {
            return 0;
        }
    }

    function indexOf(string memory _haystack, string memory _needle)
        internal
        pure
        returns (int256 _returnCode)
    {

        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if (h.length < 1 || n.length < 1 || (n.length > h.length)) {
            return -1;
        } else if (h.length > (2**128 - 1)) {
            return -1;
        } else {
            uint256 subindex = 0;
            for (uint256 i = 0; i < h.length; i++) {
                if (h[i] == n[0]) {
                    subindex = 1;
                    while (
                        subindex < n.length &&
                        (i + subindex) < h.length &&
                        h[i + subindex] == n[subindex]
                    ) {
                        subindex++;
                    }
                    if (subindex == n.length) {
                        return int256(i);
                    }
                }
            }
            return -1;
        }
    }

    function strConcat(string memory _a, string memory _b)
        internal
        pure
        returns (string memory _concatenatedString)
    {

        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(
            _ba.length + _bb.length + _bc.length + _bd.length + _be.length
        );
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        uint256 i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function safeParseInt(string memory _a)
        internal
        pure
        returns (uint256 _parsedInt)
    {

        return safeParseInt(_a, 0);
    }

    function safeParseInt(string memory _a, uint256 _b)
        internal
        pure
        returns (uint256 _parsedInt)
    {

        bytes memory bresult = bytes(_a);
        uint256 mint = 0;
        bool decimals = false;
        for (uint256 i = 0; i < bresult.length; i++) {
            if (
                (uint256(uint8(bresult[i])) >= 48) &&
                (uint256(uint8(bresult[i])) <= 57)
            ) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint256(uint8(bresult[i])) - 48;
            } else if (uint256(uint8(bresult[i])) == 46) {
                require(
                    !decimals,
                    "More than one decimal encountered in string!"
                );
                decimals = true;
            } else {
                revert("Non-numeral character encountered in string!");
            }
        }
        if (_b > 0) {
            mint *= 10**_b;
        }
        return mint;
    }

    function parseInt(string memory _a)
        internal
        pure
        returns (uint256 _parsedInt)
    {

        return parseInt(_a, 0);
    }

    function parseInt(string memory _a, uint256 _b)
        internal
        pure
        returns (uint256 _parsedInt)
    {

        bytes memory bresult = bytes(_a);
        uint256 mint = 0;
        bool decimals = false;
        for (uint256 i = 0; i < bresult.length; i++) {
            if (
                (uint256(uint8(bresult[i])) >= 48) &&
                (uint256(uint8(bresult[i])) <= 57)
            ) {
                if (decimals) {
                    if (_b == 0) {
                        break;
                    } else {
                        _b--;
                    }
                }
                mint *= 10;
                mint += uint256(uint8(bresult[i])) - 48;
            } else if (uint256(uint8(bresult[i])) == 46) {
                decimals = true;
            }
        }
        if (_b > 0) {
            mint *= 10**_b;
        }
        return mint;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] memory _arr)
        internal
        pure
        returns (bytes memory _cborEncoding)
    {

        safeMemoryCleaner();
        Buffer.buffer memory buf;
        Buffer.init(buf, 1024);
        buf.startArray();
        for (uint256 i = 0; i < _arr.length; i++) {
            buf.encodeString(_arr[i]);
        }
        buf.endSequence();
        return buf.buf;
    }

    function ba2cbor(bytes[] memory _arr)
        internal
        pure
        returns (bytes memory _cborEncoding)
    {

        safeMemoryCleaner();
        Buffer.buffer memory buf;
        Buffer.init(buf, 1024);
        buf.startArray();
        for (uint256 i = 0; i < _arr.length; i++) {
            buf.encodeBytes(_arr[i]);
        }
        buf.endSequence();
        return buf.buf;
    }

    function provable_newRandomDSQuery(
        uint256 _delay,
        uint256 _nbytes,
        uint256 _customGasLimit
    ) internal returns (bytes32 _queryId) {

        require((_nbytes > 0) && (_nbytes <= 32));
        _delay *= 10; // Convert from seconds to ledger timer ticks
        bytes memory nbytes = new bytes(1);
        nbytes[0] = bytes1(uint8(_nbytes));
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);

            bytes32 sessionKeyHash_bytes32
         = provable_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(
                add(unonce, 0x20),
                xor(blockhash(sub(number, 1)), xor(coinbase, timestamp))
            )
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly {
            mstore(add(delay, 0x20), _delay)
        }
        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);
        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = provable_query("random", args, _customGasLimit);
        bytes memory delay_bytes8_left = new bytes(8);
        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(
                add(delay_bytes8_left, 0x27),
                div(
                    x,
                    0x100000000000000000000000000000000000000000000000000000000000000
                )
            )
            mstore8(
                add(delay_bytes8_left, 0x26),
                div(
                    x,
                    0x1000000000000000000000000000000000000000000000000000000000000
                )
            )
            mstore8(
                add(delay_bytes8_left, 0x25),
                div(
                    x,
                    0x10000000000000000000000000000000000000000000000000000000000
                )
            )
            mstore8(
                add(delay_bytes8_left, 0x24),
                div(
                    x,
                    0x100000000000000000000000000000000000000000000000000000000
                )
            )
            mstore8(
                add(delay_bytes8_left, 0x23),
                div(
                    x,
                    0x1000000000000000000000000000000000000000000000000000000
                )
            )
            mstore8(
                add(delay_bytes8_left, 0x22),
                div(x, 0x10000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x21),
                div(x, 0x100000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x20),
                div(x, 0x1000000000000000000000000000000000000000000000000)
            )
        }
        provable_randomDS_setCommitment(
            queryId,
            keccak256(
                abi.encodePacked(
                    delay_bytes8_left,
                    args[1],
                    sha256(args[0]),
                    args[2]
                )
            )
        );
        return queryId;
    }

    function provable_randomDS_setCommitment(
        bytes32 _queryId,
        bytes32 _commitment
    ) internal {

        provable_randomDS_args[_queryId] = _commitment;
    }

    function verifySig(
        bytes32 _tosignh,
        bytes memory _dersig,
        bytes memory _pubkey
    ) internal returns (bool _sigVerified) {

        bool sigok;
        address signer;
        bytes32 sigr;
        bytes32 sigs;
        bytes memory sigr_ = new bytes(32);
        uint256 offset = 4 + (uint256(uint8(_dersig[3])) - 0x20);
        sigr_ = copyBytes(_dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(
            _dersig,
            offset + (uint256(uint8(_dersig[offset - 1])) - 0x20),
            32,
            sigs_,
            0
        );
        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }
        (sigok, signer) = safer_ecrecover(_tosignh, 27, sigr, sigs);
        if (address(uint160(uint256(keccak256(_pubkey)))) == signer) {
            return true;
        } else {
            (sigok, signer) = safer_ecrecover(_tosignh, 28, sigr, sigs);
            return (address(uint160(uint256(keccak256(_pubkey)))) == signer);
        }
    }

    function provable_randomDS_proofVerify__sessionKeyValidity(
        bytes memory _proof,
        uint256 _sig2offset
    ) internal returns (bool _proofVerified) {

        bool sigok;
        bytes memory sig2 = new bytes(
            uint256(uint8(_proof[_sig2offset + 1])) + 2
        );
        copyBytes(_proof, _sig2offset, sig2.length, sig2, 0);
        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(_proof, 3 + 1, 64, appkey1_pubkey, 0);
        bytes memory tosign2 = new bytes(1 + 65 + 32);
        tosign2[0] = bytes1(uint8(1)); //role
        copyBytes(_proof, _sig2offset - 65, 65, tosign2, 1);

            bytes memory CODEHASH
         = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1 + 65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);
        if (!sigok) {
            return false;
        }

            bytes memory LEDGERKEY
         = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";
        bytes memory tosign3 = new bytes(1 + 65);
        tosign3[0] = 0xFE;
        copyBytes(_proof, 3, 65, tosign3, 1);
        bytes memory sig3 = new bytes(uint256(uint8(_proof[3 + 65 + 1])) + 2);
        copyBytes(_proof, 3 + 65, sig3.length, sig3, 0);
        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);
        return sigok;
    }

    function provable_randomDS_proofVerify__returnCode(
        bytes32 _queryId,
        string memory _result,
        bytes memory _proof
    ) internal returns (uint8 _returnCode) {

        if (
            (_proof[0] != "L") ||
            (_proof[1] != "P") ||
            (uint8(_proof[2]) != uint8(1))
        ) {
            return 1;
        }
        bool proofVerified = provable_randomDS_proofVerify__main(
            _proof,
            _queryId,
            bytes(_result),
            provable_getNetworkName()
        );
        if (!proofVerified) {
            return 2;
        }
        return 0;
    }

    function matchBytes32Prefix(
        bytes32 _content,
        bytes memory _prefix,
        uint256 _nRandomBytes
    ) internal pure returns (bool _matchesPrefix) {

        bool match_ = true;
        require(_prefix.length == _nRandomBytes);
        for (uint256 i = 0; i < _nRandomBytes; i++) {
            if (_content[i] != _prefix[i]) {
                match_ = false;
            }
        }
        return match_;
    }

    function provable_randomDS_proofVerify__main(
        bytes memory _proof,
        bytes32 _queryId,
        bytes memory _result,
        string memory _contextName
    ) internal returns (bool _proofVerified) {

        uint256 ledgerProofLength = 3 +
            65 +
            (uint256(uint8(_proof[3 + 65 + 1])) + 2) +
            32;
        bytes memory keyhash = new bytes(32);
        copyBytes(_proof, ledgerProofLength, 32, keyhash, 0);
        if (
            !(keccak256(keyhash) ==
                keccak256(
                    abi.encodePacked(
                        sha256(abi.encodePacked(_contextName, _queryId))
                    )
                ))
        ) {
            return false;
        }
        bytes memory sig1 = new bytes(
            uint256(uint8(_proof[ledgerProofLength + (32 + 8 + 1 + 32) + 1])) +
                2
        );
        copyBytes(
            _proof,
            ledgerProofLength + (32 + 8 + 1 + 32),
            sig1.length,
            sig1,
            0
        );
        if (
            !matchBytes32Prefix(
                sha256(sig1),
                _result,
                uint256(uint8(_proof[ledgerProofLength + 32 + 8]))
            )
        ) {
            return false;
        }
        bytes memory commitmentSlice1 = new bytes(8 + 1 + 32);
        copyBytes(
            _proof,
            ledgerProofLength + 32,
            8 + 1 + 32,
            commitmentSlice1,
            0
        );
        bytes memory sessionPubkey = new bytes(64);
        uint256 sig2offset = ledgerProofLength +
            32 +
            (8 + 1 + 32) +
            sig1.length +
            65;
        copyBytes(_proof, sig2offset - 64, 64, sessionPubkey, 0);
        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (
            provable_randomDS_args[_queryId] ==
            keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))
        ) {
            delete provable_randomDS_args[_queryId];
        } else return false;
        bytes memory tosign1 = new bytes(32 + 8 + 1 + 32);
        copyBytes(_proof, ledgerProofLength, 32 + 8 + 1 + 32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) {
            return false;
        }
        if (!provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash]) {
            provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = provable_randomDS_proofVerify__sessionKeyValidity(
                _proof,
                sig2offset
            );
        }
        return provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    function copyBytes(
        bytes memory _from,
        uint256 _fromOffset,
        uint256 _length,
        bytes memory _to,
        uint256 _toOffset
    ) internal pure returns (bytes memory _copiedBytes) {

        uint256 minLength = _length + _toOffset;
        require(_to.length >= minLength); // Buffer too small. Should be a better way?
        uint256 i = 32 + _fromOffset; // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint256 j = 32 + _toOffset;
        while (i < (32 + _fromOffset + _length)) {
            assembly {
                let tmp := mload(add(_from, i))
                mstore(add(_to, j), tmp)
            }
            i += 32;
            j += 32;
        }
        return _to;
    }

    function safer_ecrecover(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal returns (bool _success, address _recoveredAddress) {

        bool ret;
        address addr;
        assembly {
            let size := mload(0x40)
            mstore(size, _hash)
            mstore(add(size, 32), _v)
            mstore(add(size, 64), _r)
            mstore(add(size, 96), _s)
            ret := call(3000, 1, 0, size, 128, size, 32) // NOTE: we can reuse the request memory because we deal with the return code.
            addr := mload(size)
        }
        return (ret, addr);
    }

    function ecrecovery(bytes32 _hash, bytes memory _sig)
        internal
        returns (bool _success, address _recoveredAddress)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;
        if (_sig.length != 65) {
            return (false, address(0));
        }
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return (false, address(0));
        }
        return safer_ecrecover(_hash, v, r, s);
    }

    function safeMemoryCleaner() internal pure {

        assembly {
            let fmem := mload(0x40)
            codecopy(fmem, codesize, sub(msize, fmem))
        }
    }
}
pragma solidity 0.5.17;


contract RabbitsFarming is Ownable {

    
    using SafeMath for uint256;
    
    Rabbits public rabbits;
    MorpheusToken public morpheus;
    
    constructor(Rabbits _rabbits, MorpheusToken _morpheusToken) public{
        setRabbitsToken(_rabbits);
        setMorpheusToken(_morpheusToken);
    }
    
    mapping(uint256 => bool) public canBeFarmed;
    mapping(uint256 => bool) public farmed;
    mapping(uint256 => bool) public onFarming;
    mapping(uint256 => address) private _farmingBy;
    
    uint256[] private _spots;
    
    uint256 public MGTStackedOnFarming;
    
    uint256 public whiteRabbitsFarmingTime = 30 days;
    uint256 public blueRabbitsFarmingTime = 20 days;
    uint256 public redRabbitsFarmingTime = 10 days;
    
    uint256 public amountForWhiteRabbits = 100000; 
    uint256 public amountForBlueRabbits = 50000;
    uint256 public amountForRedRabbits = 25000;
 
    

    
    function setRabbitsToken(Rabbits _rabbits) public onlyOwner() {

        rabbits = _rabbits;
    }
    
    function setMorpheusToken(MorpheusToken _morpheusToken) public onlyOwner() {

        morpheus = _morpheusToken;
    }
    
    


    function setFarmingTimeWhiteRabbits(uint256 _time) public onlyOwner(){

        whiteRabbitsFarmingTime = _time;
    }
    
    function setFarmingTimeBlueRabbits(uint256 _time) public onlyOwner(){

        blueRabbitsFarmingTime = _time;
    }
    
    function setFarmingTimeRedRabbits(uint256 _time) public onlyOwner(){

        redRabbitsFarmingTime = _time;
    }
    
    function setAmountForFarmingWhiteRabbit(uint256 _amount) public onlyOwner(){

        amountForWhiteRabbits = _amount;
    }
    
    function setAmountForFarmingBlueRabbit(uint256 _amount) public onlyOwner(){

        amountForBlueRabbits = _amount;
    }
    
    function setAmountForFarmingRedRabbit(uint256 _amount) public onlyOwner(){

        amountForRedRabbits = _amount;
    }
    

    function setRabbitIdCanBeFarmed(uint256 _id) public onlyOwner(){

        require(_id>=1 && _id<=160);
        require(farmed[_id] == false,"Already farmed");
        canBeFarmed[_id] = true;
        _spots.push(_id);
    }
    

    struct farmingInstance {
        uint256 rabbitId;
        uint256 farmingBeginningTime;
        uint256 amount;
        bool isActive;
    }
    
    mapping(address => farmingInstance) public farmingInstances;

    function farmingRabbit(uint256 _id) public{

        require(canBeFarmed[_id] == true,"This Rabbit can't be farmed");
        require(morpheus.balanceOf(msg.sender) > _rabbitAmount(_id), "Value isn't good");
        delete _spots[_getSpotIndex(_id)];
        canBeFarmed[_id] = false;
        morpheus.transferFrom(msg.sender,address(this),_rabbitAmount(_id).mul(1E18));
        farmingInstances[msg.sender] = farmingInstance(_id,now,_rabbitAmount(_id),true);
        MGTStackedOnFarming = MGTStackedOnFarming.add(_rabbitAmount(_id));
    }
    
    function renounceFarming() public {

        require(farmingInstances[msg.sender].isActive == true, "You don't have any farming instance");
        morpheus.transferFrom(address(this),msg.sender,farmingInstances[msg.sender].amount.mul(1E18));
        canBeFarmed[farmingInstances[msg.sender].rabbitId] = false;
        delete farmingInstances[msg.sender];
        _spots.push(farmingInstances[msg.sender].rabbitId);
        MGTStackedOnFarming = MGTStackedOnFarming.sub(_rabbitAmount(farmingInstances[msg.sender].rabbitId));
        
    }
    
    function claimRabbit() public {

        require(farmingInstances[msg.sender].isActive == true, "You don't have any farming instance");
        require(now.sub(farmingInstances[msg.sender].farmingBeginningTime) >= _rabbitDuration(farmingInstances[msg.sender].rabbitId));
        
        morpheus.transferFrom(address(this),msg.sender,farmingInstances[msg.sender].amount.mul(1E18));
        farmed[farmingInstances[msg.sender].rabbitId] = true;
        rabbits.mintRabbit(msg.sender, farmingInstances[msg.sender].rabbitId);
        delete farmingInstances[msg.sender];
        MGTStackedOnFarming = MGTStackedOnFarming.sub(_rabbitAmount(farmingInstances[msg.sender].rabbitId));
    }
    
    function _rabbitAmount(uint256 _id) private view returns(uint256){

        uint256 _amount;
        if(_id >= 1 && _id <= 10){
            _amount = amountForWhiteRabbits;
        } else if(_id >= 11 && _id <= 60){
            _amount = amountForBlueRabbits;
        } else if(_id >= 61 && _id <= 160){
            _amount = amountForRedRabbits;
        }
        return _amount;
    }
    
    function _rabbitDuration(uint256 _id) private view returns(uint256){

        uint256 _duration;
        if(_id >= 1 && _id <= 10){
            _duration = whiteRabbitsFarmingTime;
        } else if(_id >= 11 && _id <= 60){
            _duration = blueRabbitsFarmingTime;
        } else if(_id >= 61 && _id <= 160){
            _duration = redRabbitsFarmingTime;
        }
        return _duration;
    }
    
    function _getSpotIndex(uint256 _id) private view returns(uint256){

        uint256 index;
        for( uint256 i = 0 ; i< _spots.length ; i++){
            if(_spots[i] == _id){
                index = i;
                break;
            }
        }
        return index;
    }
    
    function rabbitsSpot() public view returns(uint256[] memory spots){

        return _spots;
    }
    
    function mintRabbitFor(uint256 _id, address _winner ) public onlyOwner(){

        require(farmed[_id]==false);
        farmed[_id] = true;
        rabbits.mintRabbit(_winner,_id);
    }

    
}
