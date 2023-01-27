



pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}





pragma solidity ^0.8.0;

contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}





pragma solidity ^0.8.0;

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





pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}





pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}





pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





pragma solidity ^0.8.6;


contract Meat is ERC20Burnable, Ownable {
    
    uint256 private maxSupply;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) {
        maxSupply = maxSupply_;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        uint256 totalSupply = totalSupply();
        if(totalSupply + _amount > maxSupply){
            _amount = maxSupply - totalSupply;
        }
        _mint(_to, _amount);
    }
    
}





pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
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





pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}





pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}





pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}





pragma solidity ^0.8.0;








contract ERC721SerialMint is Context, ERC165, IERC721, IERC721Metadata, Ownable {
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    mapping (uint256 => address) private _owners;
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    uint256 public maxBatchSize;
    uint256 public totalSupply;
    string public baseURI;
    bool private started;
    mapping (uint256 => string) private _tokenURIs;

    modifier mintStarted(){
        require(started, "mint not started");
        _;
    }

    constructor (string memory name_, string memory symbol_, uint256 maxBatchSize_) {
        _name = name_;
        _symbol = symbol_;
        maxBatchSize = maxBatchSize_;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    function setStart(bool _start) public onlyOwner {
        started = _start;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }


    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721SerialMint: owner query for nonexistent token");

        uint256 lowestTokenToCheck = 1; //collection starts from 1
        if (tokenId >= maxBatchSize) {
            lowestTokenToCheck = tokenId - maxBatchSize + 1;
        }

        for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
            address owner = _owners[curr];
            if (owner != address(0)){
                return owner;
            }
        }

        revert("ERC721SerialMint: unable to determine the owner of token");
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }


    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId >0 &&tokenId <= totalSupply;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _batchMint(address to, uint256 times) internal virtual mintStarted{
        require(times <= maxBatchSize, "batch too big");
        for(uint256 i=1; i<= times; i++){
            uint256 curr = totalSupply + i;
            _beforeTokenTransfer(address(0), to, curr);
            emit Transfer(address(0), to, curr);
        }
        _balances[to] += times;
        _owners[totalSupply + 1] = to;
        totalSupply += times;
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual{
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        
        uint256 nextToken = tokenId + 1;
        if(_exists(nextToken) && _owners[nextToken] == address(0)){
            _owners[nextToken] = from;
        }

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}





pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}





pragma solidity ^0.8.6;

abstract contract RandomPickInRange {
    
    struct RandomPickArray {
        uint256 length; 
        uint256 shifted;
        mapping(uint256=>uint256) altered;
    }

    function _getPosition(RandomPickArray storage _array, uint256 _position) internal view returns(uint256){
        require(_position <= _array.length, "index out of range");
        return _array.altered[_position] == 0? _position : _array.altered[_position];
    }

    function _randomPick(RandomPickArray storage _array) internal returns (uint256){
        require(_array.length >0 , "array exhausted");
        uint256 rand = uint256(keccak256(abi.encodePacked(_array.length, msg.sender, block.difficulty, block.timestamp)));
        uint256 position = (rand % _array.length) + 1;
        uint256 choosen = _getPosition(_array, position);
        _array.altered[position] = _getPosition(_array, _array.length);
        if(_getPosition(_array, _array.length) != _array.length){
            delete _array.altered[_array.length];
        }
        _array.length -= 1;
        return choosen + _array.shifted;
    }
}





pragma solidity ^0.8.6;

contract  Signature {


    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

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
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function verifySignature(bytes32 _message , bytes memory _signature, address _signer) public pure returns (bool){
        return recoverSigner(_message, _signature) == _signer;
    }
}





pragma solidity ^0.8.6;

abstract contract Verification2 is Signature {

    modifier Verify2(bytes memory _signature, address signer) {
        bytes32 message = prefixed(
            keccak256(abi.encodePacked(
                msg.sender,
                address(this)
            ))
        );
        require(verifySignature(message, _signature, signer),"verification failed");
        _;
    }
}





pragma solidity ^0.8.0;





contract CrouchingTigerHiddenKitten is
    ERC721SerialMint,
    ReentrancyGuard,
    RandomPickInRange,
    Verification2
{
    enum stage {
        whitelistSale,
        preSale,
        publicSale
    }

    event Evolve(uint256 tokenId);
    mapping(uint256=>bool) public evolved;
    mapping(address=>uint256) public whiteListSaleCounts;

    Meat public meat;
    stage public stg = stage.whitelistSale;
    uint256 public constant whiteListPrice = 68800000000000000;
    uint256 public constant preSalePrice = 88800000000000000;
    uint256 public constant publicSalePrice = 138800000000000000;

    uint256 private _secret;

    constructor(
        string memory name_,
        string memory symbol_,
        address meat_
    ) ERC721SerialMint(name_, symbol_, 10) {
        meat = Meat(meat_);
    }

    function changeStage(stage _stg) public onlyOwner {
        stg = _stg;
        setStart(true);
    }

    function checkSpecies(uint256 _tokenId) public view returns (uint256){
        if(_secret == 0 || !_exists(_tokenId)){
            return 0;
        }
        if(evolved[_tokenId]){
            return 2;
        }
        uint256 rand = uint256(keccak256(abi.encodePacked(_tokenId, _secret)));
        if(rand % 3 == 0){
            return 2;
        }else{
            return 1;
        }
    }

    function setSecret(uint256 _s) public onlyOwner {
        _secret = _s;
    }

    function evolve(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == _msgSender(), "not yours");
        require(checkSpecies(_tokenId) == 1, "not a cat");
        meat.transferFrom(_msgSender(),owner(), 100000000000000000000); //100 meat
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, _tokenId, msg.sender, block.difficulty)));
        if(rand % 3 > 0){
            evolved[_tokenId] = true;
            emit Evolve(_tokenId);
        }
    }

    function whiteListSale(bytes memory _ticket, uint256 _times) payable public Verify2(_ticket, owner()) {
        require(stg == stage.whitelistSale, "require white list sale stage");
        require(whiteListSaleCounts[_msgSender()] + _times <= 2, "reach white list mint limit");
        require(msg.value == whiteListPrice * _times, "value error");
        payable(owner()).transfer(msg.value);
        _batchMint(_msgSender(), _times);
        whiteListSaleCounts[_msgSender()] += _times;
    }

    function preSale(uint256 _times) payable public {
        require(totalSupply + _times <= 2000, "reach pre sale goal");
        require(stg == stage.preSale, "require pre sale stage");
        require(_times <= 2, "max batch 2");
        require(msg.value == preSalePrice * _times, "value error");
        payable(owner()).transfer(msg.value);
        _batchMint(_msgSender(), _times);
    }

    function publicSale(uint256 _times) payable public{
        require(totalSupply + _times <= 3333, "mint too much");
        require(stg == stage.publicSale, "require public sale stage");
        require(msg.value == publicSalePrice * _times, "value error");
        payable(owner()).transfer(msg.value);
        _batchMint(_msgSender(), _times);
    }
    
}





pragma solidity ^0.8.6;





contract CTHKHuntingGround is ERC721Holder, ReentrancyGuard, Ownable {

    event Deposit(address indexed user, uint256[] tokenIds);
    event Withdraw(address indexed user, uint256[] tokenIds);
    event Claim(address indexed user, uint256 amount);

    struct userInfo {
        uint256 power;
        uint256 lastModifiedTime;
    }

    Meat public meat;
    CrouchingTigerHiddenKitten public cthk;

    mapping(address => userInfo) public userInfos;

    uint256 public huntingSpeed = 11574074074074;
    uint256 constant public catPower = 3;
    uint256 constant public tigerPower = 5;

    constructor(address meat_, address cthk_) {
        meat = Meat(meat_);
        cthk = CrouchingTigerHiddenKitten(cthk_);
    }

    function changeSPD(uint256 _speed) public onlyOwner {
        huntingSpeed = _speed;
    }

    function _getFelinePower(uint256 _species) internal pure returns (uint256){
        if(_species == 1){
            return catPower;
        }else if (_species == 2){
            return tigerPower;
        }else{
            return 0;
        }
    }

    function pendingMeat(address _userAddress) public view returns(uint256){
        userInfo memory info = userInfos[_userAddress];
        uint256 meatEarned = info.power * huntingSpeed * (block.timestamp - info.lastModifiedTime);
        return meatEarned;
    }

    function claim() public {
        address sender = _msgSender();
        uint256 meatEarned = pendingMeat(sender);
        if(meatEarned > 0){
            meat.mint(sender, meatEarned);
            emit Claim(sender, meatEarned);
        }
        userInfos[sender].lastModifiedTime = block.timestamp;
    }

    function deposit(uint256[] memory _tokenIds) public {
        claim();
        address sender = _msgSender();
        uint256 powerAdded;
        for(uint256 i; i < _tokenIds.length; i++){
            uint256 id = _tokenIds[i];
            cthk.transferFrom(sender, address(this), id);
            cthk.approve(sender, id);
            powerAdded += _getFelinePower(cthk.checkSpecies(id));
        }
        userInfos[sender].power += powerAdded;
        emit Deposit(sender, _tokenIds);
    }

    function withdraw(uint256[] memory _tokenIds) public {
        claim();
        address sender = _msgSender();
        uint256 powerRemoved;
        for(uint256 i; i < _tokenIds.length; i++){
            uint256 id = _tokenIds[i];
            cthk.transferFrom(address(this), sender, id);
            powerRemoved += _getFelinePower(cthk.checkSpecies(id));
        }
        userInfos[sender].power -= powerRemoved;
        emit Withdraw(sender, _tokenIds);
    }
}