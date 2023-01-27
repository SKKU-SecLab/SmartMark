



pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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
        return msg.data;
    }
}



pragma solidity ^0.8.0;









contract ERC721A is
Context,
ERC165,
IERC721,
IERC721Metadata,
IERC721Enumerable
{

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
    }

    struct AddressData {
        uint128 balance;
        uint128 numberMinted;
    }

    uint256 private currentIndex = 0;

    uint256 internal immutable maxBatchSize;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) private _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_
    ) {
        require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
        _name = name_;
        _symbol = symbol_;
        maxBatchSize = maxBatchSize_;
    }

    function totalSupply() public view override returns (uint256) {

        return currentIndex;
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        require(index < totalSupply(), "ERC721A: global index out of bounds");
        return index;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    override
    returns (uint256)
    {

        require(index < balanceOf(owner), "ERC721A: owner index out of bounds");
        uint256 numMintedSoFar = totalSupply();
        uint256 tokenIdsIdx = 0;
        address currOwnershipAddr = address(0);
        for (uint256 i = 0; i < numMintedSoFar; i++) {
            TokenOwnership memory ownership = _ownerships[i];
            if (ownership.addr != address(0)) {
                currOwnershipAddr = ownership.addr;
            }
            if (currOwnershipAddr == owner) {
                if (tokenIdsIdx == index) {
                    return i;
                }
                tokenIdsIdx++;
            }
        }
        revert("ERC721A: unable to get token of owner by index");
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
    {

        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721A: balance query for the zero address");
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        require(
            owner != address(0),
            "ERC721A: number minted query for the zero address"
        );
        return uint256(_addressData[owner].numberMinted);
    }

    function ownershipOf(uint256 tokenId)
    internal
    view
    returns (TokenOwnership memory)
    {

        require(_exists(tokenId), "ERC721A: owner query for nonexistent token");

        uint256 lowestTokenToCheck;
        if (tokenId >= maxBatchSize) {
            lowestTokenToCheck = tokenId - maxBatchSize + 1;
        }

        for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
            TokenOwnership memory ownership = _ownerships[curr];
            if (ownership.addr != address(0)) {
                return ownership;
            }
        }

        revert("ERC721A: unable to determine the owner of token");
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {

        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
        bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        require(to != owner, "ERC721A: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721A: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721A: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {

        require(operator != _msgSender(), "ERC721A: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
    {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721A: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return tokenId < currentIndex;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, "");
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        uint256 startTokenId = currentIndex;
        require(to != address(0), "ERC721A: mint to the zero address");
        require(!_exists(startTokenId), "ERC721A: token already minted");
        require(quantity <= maxBatchSize, "ERC721A: quantity to mint too high");

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        AddressData memory addressData = _addressData[to];
        _addressData[to] = AddressData(
            addressData.balance + uint128(quantity),
            addressData.numberMinted + uint128(quantity)
        );
        _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 updatedIndex = startTokenId;

        for (uint256 i = 0; i < quantity; i++) {
            emit Transfer(address(0), to, updatedIndex);
            require(
                _checkOnERC721Received(address(0), to, updatedIndex, _data),
                "ERC721A: transfer to non ERC721Receiver implementer"
            );
            updatedIndex++;
        }

        currentIndex = updatedIndex;
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
        getApproved(tokenId) == _msgSender() ||
        isApprovedForAll(prevOwnership.addr, _msgSender()));

        require(
            isApprovedOrOwner,
            "ERC721A: transfer caller is not owner nor approved"
        );

        require(
            prevOwnership.addr == from,
            "ERC721A: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721A: transfer to the zero address");

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        _addressData[from].balance -= 1;
        _addressData[to].balance += 1;
        _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 nextTokenId = tokenId + 1;
        if (_ownerships[nextTokenId].addr == address(0)) {
            if (_exists(nextTokenId)) {
                _ownerships[nextTokenId] = TokenOwnership(
                    prevOwnership.addr,
                    prevOwnership.startTimestamp
                );
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    uint256 public nextOwnerToExplicitlySet = 0;

    function _setOwnersExplicit(uint256 quantity) internal {

        uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
        require(quantity > 0, "quantity must be nonzero");
        uint256 endIndex = oldNextOwnerToSet + quantity - 1;
        if (endIndex > currentIndex - 1) {
            endIndex = currentIndex - 1;
        }
        require(_exists(endIndex), "not enough minted yet for this cleanup");
        for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
            if (_ownerships[i].addr == address(0)) {
                TokenOwnership memory ownership = ownershipOf(i);
                _ownerships[i] = TokenOwnership(
                    ownership.addr,
                    ownership.startTimestamp
                );
            }
        }
        nextOwnerToExplicitlySet = endIndex + 1;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try
            IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721A: transfer to non ERC721Receiver implementer");
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

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
}


pragma solidity ^0.8.0;








contract DegenToken is ERC20, Ownable, ReentrancyGuard{

    IERC721 Punkx;

    uint public punkXStart;
    uint public lockoutTime = 10 days;

    mapping(uint=>bool) public mintRewardClaimed;
    uint[] public rewards = [13,12,11,10];
    uint[] public multiplier = [0,0,1,2,3,4,5];
    mapping(uint=>uint) externallyClaimed;
    mapping(address=>bool) isApproved;

    mapping(uint=>stake) public stakedTokens;
    mapping(address=>uint[]) public userStaked;

    bool public isPaused;

    struct stake{
        address tokenOwner;
        uint lockTime;
        uint lastClaim;
        uint stakeTime;
        uint lockedPieces;
        uint arrayPosition;
    }

    constructor(address punkxAddress) ERC20("DEGEN","DEGEN"){
        Punkx = IERC721(punkxAddress);
        punkXStart = block.timestamp;
    }

    function deleteRewards () external onlyOwner {
        rewards.pop();
    }

    function deleteMultiplier () external onlyOwner {
        multiplier.pop();
    }

    function addMultiplier (uint value) external onlyOwner {
        multiplier.push(value);
    }

    function addRewards (uint value) external onlyOwner {
        rewards.push(value);
    }

    function ownerMint (uint _amount) external onlyOwner {
        _mint(msg.sender, _amount * 1 ether);
    }

    function getStakedUserTokens(address _query) public view returns (uint[] memory){
        return userStaked[_query];
    }

    modifier isNotPaused(){
        require(!isPaused,"Execution is paused");
        _;
    }

    function stakeTokens (uint[] memory tokenIds,bool lock) external isNotPaused{
        for (uint i=0;i<tokenIds.length;i++) {
            require(Punkx.ownerOf(tokenIds[i]) == msg.sender,"Not Owner"); //Can't stake unowned tokens
            stakedTokens[tokenIds[i]] = stake(msg.sender,0,block.timestamp,block.timestamp,0,userStaked[msg.sender].length);
            userStaked[msg.sender].push(tokenIds[i]);
            Punkx.safeTransferFrom(msg.sender,address(this),tokenIds[i]);
        }
        if(lock){
            require (tokenIds.length > 1,'Min Lock Amount Is 2');
            lockInternal(tokenIds);
        }
    }

    function lockTokens(uint[] memory tokenIds) public isNotPaused{
        require (tokenIds.length > 1,'Min Lock Amount Is 2');
        claimRewards(tokenIds);
        lockInternal(tokenIds);
    }

    function lockInternal(uint[] memory tokenIds) internal {
        for(uint i=0;i<tokenIds.length;i++){
            stake storage currentToken = stakedTokens[tokenIds[i]];
            require(currentToken.tokenOwner == msg.sender,"Only owner can lock"); //Needs to be owner to lock
            require(block.timestamp - currentToken.lockTime > lockoutTime,"Already locked"); //Need to not be locked to lock
            currentToken.lockTime = currentToken.lastClaim;
            tokenIds.length > 6 ? currentToken.lockedPieces = 6 : currentToken.lockedPieces = tokenIds.length ;
        }
    }

    function unstakeTokens(uint[] memory tokenIds) external isNotPaused{
        claimRewards(tokenIds);
        for (uint i; i< tokenIds.length; i++) {
            require(Punkx.ownerOf(tokenIds[i]) == address(this),"Token not staked"); //Needs to not be staked
            stake storage currentToken = stakedTokens[tokenIds[i]];
            require(currentToken.tokenOwner == msg.sender,"Only owner can unstake"); //Needs to be sender's token
            require(block.timestamp - currentToken.lockTime > lockoutTime,"Not unlocked"); //Needs to be unlocked
            userStaked[msg.sender][currentToken.arrayPosition] = userStaked[msg.sender][userStaked[msg.sender].length-1];
            stakedTokens[userStaked[msg.sender][currentToken.arrayPosition]].arrayPosition = currentToken.arrayPosition;
            userStaked[msg.sender].pop();
            delete stakedTokens[tokenIds[i]];
            Punkx.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
        }
    }

    function rewardFromMint(uint[] memory tokenIds) external isNotPaused{
        require(block.timestamp - punkXStart > 7 days, "It's not birthday yet");
        uint totalAmount;
        for(uint i=0;i<tokenIds.length;i++){
            require(tokenIds[i] < 2222,"Reward only till 2222");
            require (Punkx.ownerOf(tokenIds[i])==msg.sender || stakedTokens[tokenIds[i]].tokenOwner == _msgSender());
            require(!mintRewardClaimed[tokenIds[i]],"Already Claimed");
            mintRewardClaimed[tokenIds[i]] == true;
            totalAmount += 32*rewards[0];
        }
        _mint(msg.sender,totalAmount*1 ether);
    }

    function claimRewards(uint[] memory tokenIds) public nonReentrant isNotPaused{
        uint totalAmount; 
        for(uint i=0;i<tokenIds.length;i++){
            stake storage currentToken = stakedTokens[tokenIds[i]];
            require(currentToken.tokenOwner == msg.sender,"Only owner can claim"); //Needs to be sender's token
            totalAmount += getReward(tokenIds[i]);
            delete externallyClaimed[tokenIds[i]];
            currentToken.lastClaim += ((block.timestamp - currentToken.lastClaim)/ 1 days) * 1 days;
        }
        _mint(msg.sender,totalAmount);
    }

    function claimExternally(address from,uint amount,uint[] memory tokenIds) external isNotPaused {
        require(isApproved[msg.sender],"Not approved caller");
        uint totalAmount;
        for(uint i=0;i<tokenIds.length;i++) {
            stake storage currentToken = stakedTokens[tokenIds[i]];
            require(currentToken.tokenOwner == from,"Only owner can lock"); //Needs to be owner to lock
            uint reward = getReward(tokenIds[i]);
            if(amount > reward + totalAmount) {
                externallyClaimed[tokenIds[i]] = reward;
                totalAmount += reward;
            }
            else {
                externallyClaimed[tokenIds[i]] = amount - totalAmount;
                totalAmount = amount;
                break;
            }
        }
        require(totalAmount == amount,"Not enough DEGEN");
        _mint(msg.sender,amount);
    }

    function getReward(uint tokenId) public view returns(uint){
            require(Punkx.ownerOf(tokenId) == address(this),"Token not staked"); //Needs to not be staked
            stake storage currentToken = stakedTokens[tokenId];
            uint reward;
            if(block.timestamp - currentToken.lockTime <= lockoutTime) {
                uint timeInDays = (block.timestamp - currentToken.lastClaim)/1 days;
                uint combo = currentToken.lockedPieces;
                reward = 1 ether*timeInDays*rewards[tokenId/2222]*(10+multiplier[combo])/10 - externallyClaimed[tokenId]; //Assuming tokenId starts from 1
            }
            else {
                uint unlockTime = currentToken.lockTime + lockoutTime;
                if(block.timestamp > unlockTime && currentToken.lastClaim < unlockTime){
                    uint timeLocked = (currentToken.lockTime + lockoutTime - currentToken.lastClaim)/1 days;
                    uint timeUnlocked = (block.timestamp - (currentToken.lockTime + lockoutTime))/1 days;
                    uint combo = currentToken.lockedPieces;
                    reward = 1 ether*timeLocked*rewards[tokenId/2222]*(10+multiplier[combo])/10;
                    reward += 1 ether*timeUnlocked*rewards[tokenId/2222];
                    reward -= externallyClaimed[tokenId];
                }
                else{
                    uint timeInDays = (block.timestamp - currentToken.lastClaim)/1 days;
                    reward = 1 ether*timeInDays*rewards[tokenId/2222] - externallyClaimed[tokenId];
                }
            }
        return reward;
    }

    function mintExternally(uint _amount) external isNotPaused{
        require(isApproved[msg.sender], "Not approved yet");
        _mint(_msgSender(), _amount);
    }

    function burnExternally(address _from, uint _amount) external isNotPaused{
        require(isApproved[msg.sender], "Not approved yet");
        _burn(_from, _amount);
    }

    function approveAddress(address toBeApproved,bool approveIt) external onlyOwner{
        isApproved[toBeApproved] = approveIt;
    }

    function pauseExecution(bool pause) external onlyOwner{
        isPaused = pause;
    }
    
    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public pure returns (bytes4) {
        return 0x150b7a02;
    }
}