
pragma solidity 0.8.10;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity 0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity 0.8.10;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity 0.8.10;


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
}// MIT

pragma solidity 0.8.10;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity 0.8.10;


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

}// MIT

pragma solidity 0.8.10;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity 0.8.10;

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
}// MIT

pragma solidity 0.8.10;

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
}// MIT

pragma solidity 0.8.10;


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
}// MIT

pragma solidity 0.8.10;


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
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {

        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {

        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
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

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {

        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {

        require(operator != _msgSender(), "ERC721: approve to caller");

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
    ) public virtual override {

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

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

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {

        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
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

        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
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
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
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

pragma solidity 0.8.10;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity 0.8.10;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721.balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721Enumerable.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
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

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {

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
}// MIT LICENSE

pragma solidity 0.8.10;

interface IPunkedPup {
    function getPaidTokens() external view returns (uint256);
}// MIT LICENSE

pragma solidity 0.8.10;

interface IShelter {
    function addManyToShelterAndPack(
        address account,
        uint16[] calldata tokenIds
    ) external;

    struct PupCat {
        bool isPup;
        uint8 alphaIndex;
        bool isDogCatcher;
    }
}// MIT

pragma solidity 0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// MIT

pragma solidity 0.8.10;


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}// MIT

pragma solidity 0.8.10;


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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
}// MIT LICENSE

pragma solidity 0.8.10;








contract BONE is ERC20, Ownable {
    mapping(address => uint256) private lastWrite;

    mapping(address => bool) private admins;

    constructor() ERC20("BONE", "BONE") {}

    function addAdmin(address addr) external onlyOwner {
        admins[addr] = true;
    }

    function removeAdmin(address addr) external onlyOwner {
        admins[addr] = false;
    }

    function mint(address to, uint256 amount) external {
        require(admins[msg.sender], "Only admins can mint");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(admins[msg.sender], "Only admins can burn");
        _burn(from, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20) returns (bool) {
        if (admins[_msgSender()]) {
            _transfer(sender, recipient, amount);
            return true;
        }

        return super.transferFrom(sender, recipient, amount);
    }


    modifier disallowIfStateIsChanging() {
        require(
            admins[_msgSender()] || lastWrite[tx.origin] < block.number,
            "hmmmm what doing?"
        );
        _;
    }

    function updateOriginAccess() external {
        require(admins[_msgSender()], "Only admins can call this");
        lastWrite[tx.origin] = block.number;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        disallowIfStateIsChanging
        returns (uint256)
    {
        require(
            admins[_msgSender()] || lastWrite[account] < block.number,
            "hmmmm what doing?"
        );
        return super.balanceOf(account);
    }
}// MIT

pragma solidity 0.8.10;

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
}// MIT LICENSE

pragma solidity 0.8.10;

contract PunkedPup is
    IPunkedPup,
    ReentrancyGuard,
    ERC721Enumerable,
    Ownable,
    Pausable
{
    struct Whitelist {
        bool isWhitelisted;
        uint16 numMinted;
    }

    uint256 public constant MINT_PRICE = .055 ether;
    uint256 public constant WHITELIST_PRICE = .025 ether;
    uint256 public immutable MAX_TOKENS;
    uint256 public PAID_TOKENS = 10000;
    uint256 public PRE_SALE_TOKENS = 1500;
    uint16 public minted;
    mapping(address => uint256) public _count;

    IShelter public shelter;
    BONE public bone;
    string public baseUri = "https://api.punkedpups.com/nftMetadata/";
    string public contractUri =
        "https://api.punkedpups.com/nftCollectionMetadata/";

    mapping(uint256 => string) private _tokenURIs;

    uint256 mintLimit = 10;
    uint256 whitelistMintLimit = 20;
    mapping(address => Whitelist) private _whitelistAddresses;

    event Mint(
        address indexed _to,
        uint256 indexed tokenId,
        uint8 indexed alphaIndex
    );

    constructor(
        address _bone,
        uint256 _maxTokens,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        bone = BONE(_bone);
        MAX_TOKENS = _maxTokens;
        _pause();
    }


    function mint(uint256 amount) external payable whenNotPaused nonReentrant {
        require(tx.origin == _msgSender(), "Only EOA");
        require(minted + amount <= MAX_TOKENS, "All tokens minted");
        if (_msgSender() != owner()) {
            require(amount > 0 && amount <= 10, "Invalid mint amount");
            if (_whitelistAddresses[_msgSender()].isWhitelisted) {
                require(
                    _count[_msgSender()] + amount <= whitelistMintLimit,
                    "Exceeds mint limit"
                );
            } else {
                require(
                    _count[_msgSender()] + amount <= mintLimit,
                    "Exceeds mint limit"
                );
            }
            if (minted < PRE_SALE_TOKENS) {
                require(
                    minted + amount <= PRE_SALE_TOKENS,
                    "All tokens on-pre-sale already sold"
                );
                if (
                    _whitelistAddresses[_msgSender()].isWhitelisted &&
                    _whitelistAddresses[_msgSender()].numMinted + amount <= 10
                ) {
                    require(
                        amount * WHITELIST_PRICE == msg.value,
                        "Invalid payment amount"
                    );
                    _whitelistAddresses[_msgSender()].numMinted += uint16(
                        amount
                    );
                } else {
                    require(
                        amount * MINT_PRICE == msg.value,
                        "Invalid payment amount"
                    );
                }
            } else if (minted < PAID_TOKENS) {
                require(
                    minted + amount <= PAID_TOKENS,
                    "All tokens on-sale already sold"
                );
                require(
                    amount * MINT_PRICE == msg.value,
                    "Invalid payment amount"
                );
            } else {
                require(msg.value == 0);
            }
        }

        uint256 totalBoneCost = 0;
        uint16[] memory tokenIds = new uint16[](amount);
        uint256 seed;
        for (uint256 i = 0; i < amount; i++) {
            minted++;
            seed = random(minted);
            uint8 alphaIndex = uint8(randomWithRange(seed, 5)) + 1;
            _safeMint(address(shelter), minted);
            _count[_msgSender()]++;
            emit Mint(address(shelter), minted, alphaIndex);
            tokenIds[i] = minted;
            totalBoneCost += mintCost(minted);
        }

        if (totalBoneCost > 0) bone.burn(_msgSender(), totalBoneCost);
        shelter.addManyToShelterAndPack(_msgSender(), tokenIds);
    }

    function mintCost(uint256 tokenId) public view returns (uint256) {
        if (tokenId <= PAID_TOKENS) return 0;
        if (tokenId <= 20000) return 20000 ether;
        return 40000 ether;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        if (_msgSender() != address(shelter))
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        _transfer(from, to, tokenId);
    }

    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _msgSender(),
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }

    function randomWithRange(uint256 seed, uint256 mod)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _msgSender(),
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            ) % mod;
    }

    function getPaidTokens() external view override returns (uint256) {
        return PAID_TOKENS;
    }


    function setShelter(address _shelter) external onlyOwner {
        shelter = IShelter(_shelter);
    }

    function addToWhitelist(address[] calldata addressesToAdd)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addressesToAdd.length; i++) {
            _whitelistAddresses[addressesToAdd[i]] = Whitelist(true, 0);
        }
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setPaidTokens(uint256 _paidTokens) external onlyOwner {
        PAID_TOKENS = _paidTokens;
    }

    function setPreSaleTokens(uint256 _preSaleToken) external onlyOwner {
        PRE_SALE_TOKENS = _preSaleToken;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function baseTokenURI() public view returns (string memory) {
        return baseUri;
    }

    function setBaseTokenURI(string memory uri) public onlyOwner {
        baseUri = uri;
    }

    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    function setContractURI(string memory uri) public onlyOwner {
        contractUri = uri;
    }

    function setMintLimit(uint256 newLimit) public onlyOwner {
        mintLimit = newLimit;
    }


    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        if (
            keccak256(abi.encodePacked(_tokenURIs[tokenId])) ==
            keccak256(abi.encodePacked(""))
        ) {
            return
                string(
                    abi.encodePacked(baseTokenURI(), Strings.toString(tokenId))
                );
        }
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        public
        onlyOwner
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }
}// MIT LICENSE

pragma solidity 0.8.10;


contract Shelter is
    IShelter,
    Ownable,
    ReentrancyGuard,
    IERC721Receiver,
    Pausable
{
    uint8 public constant MAX_ALPHA = 9;

    struct Stake {
        uint16 tokenId;
        uint80 value;
        address owner;
    }

    event TokenStaked(address owner, uint256 tokenId, uint256 value);
    event PupClaimed(uint256 tokenId, uint256 earned, bool unstaked);
    event CatClaimed(uint256 tokenId, uint256 earned, bool unstaked);
    event TokenUnstaked(uint256 tokenId);

    PunkedPup private punkedPup;
    BONE private bone;

    mapping(uint256 => Stake) public shelter;
    mapping(uint256 => Stake[]) public pack;
    uint256[] public dogHouse;
    mapping(uint256 => address) public stakedDogCatcher;
    mapping(uint256 => uint256) public packIndices;
    mapping(uint256 => uint256) public dogHouseIndices;
    mapping(uint256 => PupCat) private tokenTraits;
    uint256 public totalAlphaStaked = 0;
    uint256 public unaccountedRewards = 0;
    uint256 public bonePerAlpha = 0;
    uint256 public constant DAILY_BONE_RATE = 100 ether;
    uint256 public constant MINIMUM_TO_EXIT = 2 days;
    uint256 public constant BONE_CLAIM_TAX_PERCENTAGE = 20;
    uint256 public constant MAXIMUM_GLOBAL_BONE = 10000000000 ether;

    uint256 public totalBoneEarned;
    uint256 public totalPupStaked;
    uint256 public lastClaimTimestamp;

    bool public rescueEnabled = false;

    constructor(address _punkedPup, address _bone) {
        punkedPup = PunkedPup(_punkedPup);
        bone = BONE(_bone);
        _pause();
    }


    function addManyToShelterAndPack(
        address account,
        uint16[] calldata tokenIds
    ) external nonReentrant {
        require(
            tx.origin == _msgSender() || _msgSender() == address(punkedPup),
            "Only EOA"
        );
        require(account == tx.origin, "account to sender mismatch");
        uint256 seed;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            seed = random(tokenIds[i]);
            uint8 alphaIndex = uint8(randomWithRange(seed, 5)) + 1;

            if (tokenTraits[tokenIds[i]].alphaIndex == 0) {
                tokenTraits[tokenIds[i]] = PupCat(true, alphaIndex, false);
            }
            if (_msgSender() != address(punkedPup)) {
                require(
                    punkedPup.ownerOf(tokenIds[i]) == _msgSender(),
                    "You don't own this token"
                );
                punkedPup.transferFrom(
                    _msgSender(),
                    address(this),
                    tokenIds[i]
                );
            } else if (tokenIds[i] == 0) {
                continue; // there may be gaps in the array for stolen tokens
            }
            if (isPup(tokenIds[i])) _addPupToShelter(account, tokenIds[i]);
            else _addCatToPack(account, tokenIds[i]);
        }
    }

    function _addPupToShelter(address account, uint256 tokenId)
        internal
        whenNotPaused
        _updateEarnings
    {
        shelter[tokenId] = Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        });
        totalPupStaked += 1;
        emit TokenStaked(account, tokenId, block.timestamp);
    }

    function _addCatToPack(address account, uint256 tokenId) internal {
        uint256 alpha = _alphaForCat(tokenId);
        totalAlphaStaked += alpha; // Portion of earnings ranges from 8 to 5
        packIndices[tokenId] = pack[alpha].length; // Store the location of the cat in the Pack
        pack[alpha].push(
            Stake({
                owner: account,
                tokenId: uint16(tokenId),
                value: uint80(bonePerAlpha)
            })
        ); // Add the cat to the Pack

        if (isDogCatcher(tokenId)) {
            dogHouse.push(tokenId);
            stakedDogCatcher[tokenId] = account;
            dogHouseIndices[tokenId] = dogHouse.length; // Store the location of the dogCatcher in the dogHouse
        }
        emit TokenStaked(account, tokenId, bonePerAlpha);
    }


    function claimManyFromShelterAndPack(
        uint16[] calldata tokenIds,
        bool unstake
    ) external whenNotPaused _updateEarnings nonReentrant {
        require(
            tx.origin == _msgSender() || _msgSender() == address(punkedPup),
            "Only EOA"
        );
        uint256 owed = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (isPup(tokenIds[i]))
                owed += _claimPupFromShelter(tokenIds[i], unstake);
            else owed += _claimCatFromPack(tokenIds[i], unstake);
        }
        bone.updateOriginAccess();
        if (owed == 0) return;
        bone.mint(_msgSender(), owed);
    }

    function _claimPupFromShelter(uint256 tokenId, bool unstake)
        internal
        returns (uint256 owed)
    {
        Stake memory stake = shelter[tokenId];
        uint8 alpha = tokenTraits[tokenId].alphaIndex;
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        require(
            !(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT),
            "GONNA BE COLD WITHOUT TWO DAY'S BONE"
        );
        if (totalBoneEarned < MAXIMUM_GLOBAL_BONE) {
            owed =
                ((block.timestamp - stake.value) * DAILY_BONE_RATE * alpha) /
                1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0; // $BONE production stopped already
        } else {
            owed =
                ((lastClaimTimestamp - stake.value) * DAILY_BONE_RATE * alpha) /
                1 days; // stop earning additional $BONE if it's all been earned
        }
        if (unstake) {
            address recipient = _msgSender();
            if (random(tokenId) & 1 == 1) {
                recipient = getRandomDogCatcher(random(tokenId));
                if (recipient == address(0x0)) {
                    recipient = _msgSender();
                    _payCatTax(owed);
                    owed = 0;
                }
            }
            delete shelter[tokenId];
            totalPupStaked -= 1;
            punkedPup.safeTransferFrom(address(this), recipient, tokenId, ""); // send back Pup
            emit TokenUnstaked(tokenId);
        } else {
            _payCatTax((owed * BONE_CLAIM_TAX_PERCENTAGE) / 100); // percentage tax to staked cats
            owed = (owed * (100 - BONE_CLAIM_TAX_PERCENTAGE)) / 100; // remainder goes to Pup owner
            shelter[tokenId] = Stake({
                owner: _msgSender(),
                tokenId: uint16(tokenId),
                value: uint80(block.timestamp)
            }); // reset stake
        }
        emit PupClaimed(tokenId, owed, unstake);
    }

    function _claimCatFromPack(uint256 tokenId, bool unstake)
        internal
        returns (uint256 owed)
    {
        require(
            punkedPup.ownerOf(tokenId) == address(this),
            "AINT A PART OF THE PACK"
        );
        uint8 alpha = _alphaForCat(tokenId);
        Stake memory stake = pack[alpha][packIndices[tokenId]];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        owed = (alpha) * (bonePerAlpha - stake.value); // Calculate portion of tokens based on Alpha
        if (unstake) {
            totalAlphaStaked -= alpha; // Remove Alpha from total staked
            Stake memory lastStake = pack[alpha][pack[alpha].length - 1];
            pack[alpha][packIndices[tokenId]] = lastStake; // Shuffle last Cat to current position
            dogHouse[dogHouseIndices[tokenId]] = dogHouse[dogHouse.length - 1]; // Shuffle last DogCatcher to current position
            packIndices[lastStake.tokenId] = packIndices[tokenId];
            dogHouseIndices[dogHouse[dogHouse.length - 1]] = dogHouseIndices[
                tokenId
            ];
            pack[alpha].pop(); // Remove duplicate
            delete packIndices[tokenId]; // Delete old mapping
            dogHouse.pop(); // Remove duplicate
            delete dogHouseIndices[tokenId]; // Delete old mapping
            address recipient = _msgSender();
            if (random(tokenId) & 1 == 1) {
                recipient = getRandomDogCatcher(random(tokenId));
                if (recipient == address(0x0)) {
                    recipient = _msgSender();
                }
            }
            punkedPup.safeTransferFrom(address(this), recipient, tokenId, ""); // Send back Cat
            emit TokenUnstaked(tokenId);
        } else {
            pack[alpha][packIndices[tokenId]] = Stake({
                owner: _msgSender(),
                tokenId: uint16(tokenId),
                value: uint80(bonePerAlpha)
            }); // reset stake
        }
        emit CatClaimed(tokenId, owed, unstake);
    }

    function rescue(uint256[] calldata tokenIds) external nonReentrant {
        require(rescueEnabled, "RESCUE DISABLED");
        uint256 tokenId;
        Stake memory stake;
        Stake memory lastStake;
        uint256 alpha;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            if (isPup(tokenId)) {
                stake = shelter[tokenId];
                require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
                delete shelter[tokenId];
                totalPupStaked -= 1;
                punkedPup.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    tokenId,
                    ""
                ); // send back Pup
                emit PupClaimed(tokenId, 0, true);
            } else {
                alpha = _alphaForCat(tokenId);
                stake = pack[alpha][packIndices[tokenId]];
                require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
                totalAlphaStaked -= alpha; // Remove Alpha from total staked
                lastStake = pack[alpha][pack[alpha].length - 1];
                pack[alpha][packIndices[tokenId]] = lastStake; // Shuffle last Cat to current position
                packIndices[lastStake.tokenId] = packIndices[tokenId];
                pack[alpha].pop(); // Remove duplicate
                delete packIndices[tokenId]; // Delete old mapping
                punkedPup.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    tokenId,
                    ""
                ); // Send back Cat
                emit CatClaimed(tokenId, 0, true);
            }
        }
    }


    function _payCatTax(uint256 amount) internal {
        if (totalAlphaStaked == 0) {
            unaccountedRewards += amount; // keep track of $BONE due to cats
            return;
        }
        bonePerAlpha += (amount + unaccountedRewards) / totalAlphaStaked;
        unaccountedRewards = 0;
    }

    modifier _updateEarnings() {
        if (totalBoneEarned < MAXIMUM_GLOBAL_BONE) {
            totalBoneEarned +=
                ((block.timestamp - lastClaimTimestamp) *
                    totalPupStaked *
                    DAILY_BONE_RATE) /
                1 days;
            lastClaimTimestamp = block.timestamp;
        }
        _;
    }


    function setRescueEnabled(bool _enabled) external onlyOwner {
        rescueEnabled = _enabled;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }


    function isPup(uint256 tokenId) public view returns (bool pup) {
        return tokenTraits[tokenId].isPup;
    }

    function isDogCatcher(uint256 tokenId)
        public
        view
        returns (bool dogCatcher)
    {
        return tokenTraits[tokenId].isDogCatcher;
    }

    function _alphaForCat(uint256 tokenId) internal view returns (uint8) {
        uint8 alphaIndex = tokenTraits[tokenId].alphaIndex;
        return MAX_ALPHA - alphaIndex; // alpha index is 1-4
    }

    function setTokenTraits(
        uint256[] calldata tokenIds,
        PupCat[] calldata pupcats
    ) external onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenTraits[tokenIds[i]] = pupcats[i];
        }
    }

    function getTokenTraits(uint256 tokenId)
        external
        view
        onlyOwner
        returns (PupCat memory)
    {
        return tokenTraits[tokenId];
    }

    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _msgSender(),
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }

    function randomWithRange(uint256 seed, uint256 mod)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _msgSender(),
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            ) % mod;
    }

    function getRandomDogCatcher(uint256 seed)
        internal
        view
        returns (address dogCatcher)
    {
        if (seed % 2 == 0 || dogHouse.length == 0) {
            return address(0x0);
        }
        uint256 tokenId = dogHouse[randomWithRange(seed, dogHouse.length)];
        return stakedDogCatcher[tokenId];
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send tokens to Shelter directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}