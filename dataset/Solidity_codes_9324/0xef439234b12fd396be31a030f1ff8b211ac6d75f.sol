



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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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



abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
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




pragma solidity ^0.8.0;


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




pragma solidity 0.8.4;




contract ShredToken is ERC20, ERC20Burnable, Ownable {
  
  constructor() ERC20("Shred", "HRED") { }

  mapping(address => bool) controllers;

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    _mint(to, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }

}



pragma solidity 0.8.4;







contract CryptAxx is ERC721Enumerable, Ownable{

    using Strings for uint256;

    string internal baseURI;                                    // This is the baseURI after reveal, changeable via setBaseURI
    string internal baseExtension = ".json";                    // The URI extention to use, changeable via setBaseExtension
    string internal notRevealedUri;                             // This is the baseURI before reveal, changeable via setNotRevealedURI

    uint256 public cost = 0.1 ether;                            // Cost of the NFT, changeable via setCost
    uint256 public maxSupply = 10000;                           // Max supply of this NFT, only decreasable

    uint256 public maxBurn = 7777;                              // Max amount of NFTs that can be burned by owner, not changeable

    uint256 public maxPerTransaction = 10;                       // Max amount of NFTs mintable per session, changeable via setMaxPerTransaction
    uint256 public maxPerAddress = 10;                           // Max amount of NFTs mintable per address, changeable via setMaxPerAddress

    uint256 public whitelistMaxLimit = 5000;                    // Max amount of NFTs available to mint during whitelist mint, changeable via setWhitelistMaxLimit

    uint256 public publicMaxLimit = 4799;                       // Max amount of NFTs available to mint during public mint, changeable via setPublicMaxLimit

    uint256 public adminMintLimit = 180;                        // Max amount of NFTs held for promotions & community giveaways, not changeable
    uint256 public teamMintLimit = 20;                          // Max amount of NFTs held for CryptAxx team, not changeable

    bool public paused = true;                                  // Is contract paused, changeable via setPaused
    bool public revealed = false;                               // Is final metadata revealed, changeable via setRevealed
    bool public whitelistMintLive = false;                      // Is the whitelist mint live, changeable via setWhitelistMintLive
    bool public publicMintLive = false;                         // Is the public mint live, changeable via setPublicMintLive
    bool public mythicDropped = false;                          // Has the mythic been airdropped, changeable via setMythicDropped

    address[] public whitelistedAddresses;                      // Array of whitelist addresses, changeable via setWhitelistedAddresses
    mapping(address => uint256) public addressMintedBalance;    // How many NFTs have been minted from this address

    receive() external payable {}

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    )   ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    modifier transCheck(uint256 qty) {
        require(!paused, "MINTING IS NOT LIVE");
        uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        require(msg.value >= cost * qty, "NOT ENOUGH ETH TO COMPLETE TRANSACTION");
        require(ownerMintedCount + qty <= maxPerAddress, "CAN ONLY MINT 5 NFTS PER ADDRESS");
        require(qty > 0, "MUST MINT AT LEAST 1 NFT");
        require(qty <= maxPerTransaction, "CAN ONLY MINT 5 NFTS PER TRANSACTION");
		require(totalSupply() + qty <= maxSupply, "NOT ENOUGH NFTS LEFT TO MINT");
        require(tx.origin == msg.sender, "CANNOT MINT THROUGH A CUSTOM CONTRACT");
        _;
    }

    modifier transCheckAdmin(uint256 qty) {
        require(qty > 0, "MUST MINT AT LEAST 1 NFT");
		require(totalSupply() + qty <= maxSupply, "NOT ENOUGH NFTS LEFT TO MINT");
        _;
    }

    modifier whitelistCheck() {
        require(whitelistMintLive, "WHITELIST MINT IS NOT LIVE"); 
        require(isWhitelisted(msg.sender), "ADDRESS NOT ON WHITELIST");
        require(whitelistMaxLimit > 0, "NOT ENOUGH WHITELIST NFTS LEFT TO MINT");
        _;
    }

    modifier publicCheck() {
        require(publicMintLive, "PUBLIC MINT IS NOT LIVE"); 
        require(publicMaxLimit > 0, "NOT ENOUGH PUBLIC NFTS LEFT TO MINT");
        _;
    }

    function whitelistMint(uint256 qty) public payable transCheck(qty) whitelistCheck() {
		for (uint256 i = 0; i < qty; i++) {
            whitelistMaxLimit--;
            addressMintedBalance[msg.sender]++;
			_safeMint(msg.sender, totalSupply() + 1);
		}
	}

    function publicMint(uint256 qty) public payable transCheck(qty) publicCheck() {
		for (uint256 i = 0; i < qty; i++) {
            publicMaxLimit--;
            addressMintedBalance[msg.sender]++;
			_safeMint(msg.sender, totalSupply() + 1);
		}
	}

	function adminMint(uint256 qty, address to) public onlyOwner transCheckAdmin(qty) {
        require(adminMintLimit - qty >= 0, "NOT ENOUGH ADMIN NFTS LEFT TO MINT");
		for (uint256 i = 0; i < qty; i++) {
            adminMintLimit--;
			_safeMint(to, totalSupply() + 1);
		}
	}

    function teamMint(uint256 qty, address to) public onlyOwner transCheckAdmin(qty) {
        require(teamMintLimit - qty >= 0, "NOT ENOUGH TEAM NFTS LEFT TO MINT");
		for (uint256 i = 0; i < qty; i++) {
            teamMintLimit--;
			_safeMint(to, totalSupply() + 1);
		}
	}

    function burnTokens(uint256 qty) public onlyOwner transCheckAdmin(qty) {
        require(maxBurn - qty >= 0, "CANNOT BURN ANYMORE TOKEN WITH THIS FUNCTION");
		for (uint256 i = 0; i < qty; i++) {
            maxBurn--;
			_safeMint(0x000000000000000000000000000000000000dEaD, totalSupply() + 1);
		}
	}

    function isWhitelisted(address _user) internal view returns (bool) {
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function mythicMint(address to, uint256 tokenId) public onlyOwner {
        require(mythicDropped == false, "MYTHIC AIRDROP ALREADY MINTED");
        mythicDropped = true;
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI QUERY FOR NONEXISTENT TOKEN");

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setNotRevealedURI(string memory _newNotRevealedURI) public onlyOwner {
        notRevealedUri = _newNotRevealedURI;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setMaxPerTransaction(uint256 _newMaxPerTransaction) public onlyOwner {
        maxPerTransaction = _newMaxPerTransaction;
    }

    function setMaxPerAddress(uint256 _newMaxPerAddress) public onlyOwner {
        maxPerAddress = _newMaxPerAddress;
    }

    function setWhitelistMaxLimit(uint256 _newWhitelistMaxLimit) public onlyOwner {
        whitelistMaxLimit = _newWhitelistMaxLimit;
    }

    function setPublicMaxLimit(uint256 _newPublicMaxLimit) public onlyOwner {
        publicMaxLimit = _newPublicMaxLimit;
    }

    function setPaused(bool _newPausedState) public onlyOwner {
        paused = _newPausedState;
    }

    function setRevealed(bool _newRevealedState) public onlyOwner {
        revealed = _newRevealedState;
    }

    function setWhitelistMintLive(bool _newWhitelistMintLiveState) public onlyOwner {
        whitelistMintLive = _newWhitelistMintLiveState;
    }

    function setPublicMintLive(bool _newPublicMintLiveState) public onlyOwner {
        publicMintLive = _newPublicMintLiveState;
    }

    function setWhitelistedAddresses(address[] calldata _newWhitelistedAddresses) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _newWhitelistedAddresses;
    }

    function decreaseMaxSupply(uint256 newMaxSupply) public onlyOwner {
		require(newMaxSupply < maxSupply, "CAN ONLY DECREASE SUPPLY");
		maxSupply = newMaxSupply;
	}

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}



pragma solidity 0.8.4;




contract ShredVault is Ownable, IERC721Receiver {

    using Strings for uint256;

    uint256[] public scores;
    uint256[] public boosts;
    uint256 public totalStaked;
    bool public boostsLive = false;
    address contractOwner;

    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
    }

    event NftStaked(address owner, uint256 tokenId, uint256 value);
    event NftUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    CryptAxx nft;
    ShredToken token;

    mapping(uint256 => Stake) public vault; 

    constructor(CryptAxx _nft, ShredToken _token) { 
        nft = _nft;
        token = _token;
        contractOwner = msg.sender;
    }

    function setScores(uint256[] calldata tokenScores) public onlyOwner {
        delete scores;
        scores = tokenScores;
    }

    function resetScore(uint256 tokenId, uint256 newScore) public onlyOwner {
        uint256 tokenIndex = tokenId - 1;
        scores[tokenIndex] = newScore;
    }

    function getScoreIndex() public view onlyOwner returns (uint256) {
        return scores.length;
    }

    function addToScores(uint256[] calldata tokenScores) public onlyOwner {
        for (uint i = 0; i < tokenScores.length; i++) {
            uint256 tokenScore = tokenScores[i];
            scores.push(tokenScore);
        }
    }

    function getScore(uint256 tokenId) public view returns (uint256) {
        uint256 tokenIndex = tokenId - 1;
        uint256 tokenScore = scores[tokenIndex];
        return tokenScore;
    }

    function setBoosts(uint256[] calldata tokenBoosts) public onlyOwner {
        delete boosts;
        boosts = tokenBoosts;
    }

    function resetBoost(uint256 tokenId, uint256 newBoost) public onlyOwner {
        uint256 tokenIndex = tokenId - 1;
        boosts[tokenIndex] = newBoost;
    }

    function getBoostIndex() public view onlyOwner returns (uint256) {
        return boosts.length;
    }

    function addToBoosts(uint256[] calldata tokenBoosts) public onlyOwner {
        for (uint i = 0; i < tokenBoosts.length; i++) {
            uint256 tokenBoost = tokenBoosts[i];
            boosts.push(tokenBoost);
        }
    }

    function getBoost(uint256 tokenId) public view returns (uint256) {
        uint256 tokenIndex = tokenId - 1;
        uint256 tokenBoost = boosts[tokenIndex];
        return tokenBoost;
    }

    function setBoostsLive(bool _boostsLive) public onlyOwner {
        boostsLive = _boostsLive;
    }
    
    function moveToVault(uint256[] calldata tokenIds) public {
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            nft.transferFrom(msg.sender, address(this), tokenId);
            vault[tokenId] = Stake({
                owner: msg.sender,
                tokenId: uint24(tokenId),
                timestamp: uint48(block.timestamp)
            });
            emit NftStaked(msg.sender, tokenId, block.timestamp);
        }
        totalStaked += tokenIds.length;
    }

    function moveFromVault(uint256[] calldata tokenIds) public {
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == msg.sender || contractOwner == msg.sender , "not an owner or not staked");
            _claim(tokenId);
            nft.transferFrom(address(this), staked.owner, tokenId);
            emit NftUnstaked(staked.owner, tokenId, block.timestamp);
            delete vault[tokenId];
        }
        totalStaked -= tokenIds.length;
    }

    function _claim(uint256 tokenId) internal {
        uint256[4] memory earned = _earningInfo(tokenId);
        if (earned[0] > 0) {
            Stake memory staked = vault[tokenId];
            emit Claimed(staked.owner, earned[0]);
            token.mint(staked.owner, earned[0]);
        }
    }

    function _earningInfo(uint256 tokenId) internal view returns (uint256[4] memory info) {
        uint256 totalBlockTime;
        uint256 nftScore;
        uint256 earned;

        Stake memory staked = vault[tokenId];

        uint256 stakedAt = staked.timestamp;
                    
        if(stakedAt == 0){
            earned = 0;
        } else {
            if(boostsLive == true){
                nftScore = _boostMultiplier(tokenId);
            } else {
                nftScore = getScore(tokenId);
            }
            earned += 1 ether * nftScore * (block.timestamp - stakedAt) / 1 days;
            totalBlockTime += block.timestamp - stakedAt;
        }

        uint256 earnRatePerDay = nftScore * 1 ether;
        uint256 earnRatePerSecond = earnRatePerDay / 1 days;

        return [earned, earnRatePerSecond, earnRatePerDay, totalBlockTime];
    }

    function claim(uint256[] calldata tokenIds) public {
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == msg.sender, "not an owner or not staked");
            uint256[4] memory earned = _earningInfo(tokenId);
            if (earned[0] > 0) {
                vault[tokenId] = Stake({
                    owner: staked.owner,
                    tokenId: uint24(tokenId),
                    timestamp: uint48(block.timestamp)
                });
                emit Claimed(staked.owner, earned[0]);
                token.mint(staked.owner, earned[0]);
            }
        }
    }

    function earningInfo(uint256[] calldata tokenIds) public view returns (uint256[4] memory info) {
        uint256 totalBlockTime;
        uint256 totalNftScore;
        uint256 totalEarned;

        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 nftScore;
            uint256 earned;

            Stake memory staked = vault[tokenId];

            uint256 stakedAt = staked.timestamp;
                        
            if(stakedAt == 0){
                earned = 0;
            } else {
                if(boostsLive == true){
                    nftScore = _boostMultiplier(tokenId);
                } else {
                    nftScore = getScore(tokenId);
                }
                
                earned += 1 ether * nftScore * (block.timestamp - stakedAt) / 1 days;
                totalBlockTime += block.timestamp - stakedAt;
                totalNftScore += nftScore;
                totalEarned += earned;
            }

        }

        uint256 totalEarnRatePerDay = totalNftScore * 1 ether;
        uint256 totalEarnRatePerSecond = totalEarnRatePerDay / 1 days;
        
        return [totalEarned, totalEarnRatePerSecond, totalEarnRatePerDay, totalBlockTime];
    }

    function _boostMultiplier(uint256 tokenId) public view returns (uint256) {
        Stake memory staked = vault[tokenId];
        uint256 finalScore;
        address tokenOwner = staked.owner;
        address deadAddy =  0x0000000000000000000000000000000000000000;
        if(balanceOf(tokenOwner) >= 3 && tokenOwner != deadAddy){
            uint256 tokenIndex = tokenId - 1;
            uint256 tokenScore = scores[tokenIndex];
            if(boosts[tokenIndex] > 0){
                uint256 tokenBoost = tokenScore / (100 / boosts[tokenIndex]);
                finalScore = tokenScore + tokenBoost;
            } else {
                finalScore = tokenScore;
            }
            return finalScore;
        } else {
            uint256 tokenIndex = tokenId - 1;
            finalScore = scores[tokenIndex];
            return finalScore;
        }
    }

    function balanceOf(address account) public view returns (uint256) {
        uint256 balance = 0;
        uint256 supply = nft.totalSupply();
        for(uint i = 1; i <= supply; i++) {
            if (vault[i].owner == account) {
                balance += 1;
            }
        }
        return balance;
    }

    function ownerOfStaked(uint256 tokenId) public view returns (address) {
        Stake memory staked = vault[tokenId];
        address tokenOwner = staked.owner;
        return tokenOwner;
    }

    function tokensOfOwner(address account) public view returns (uint256[] memory ownerTokens) {
        uint256 supply = nft.totalSupply();
        uint256[] memory tmp = new uint256[](supply);
        uint256 index = 0;
        for(uint tokenId = 1; tokenId <= supply; tokenId++) {
            if (vault[tokenId].owner == account) {
                tmp[index] = vault[tokenId].tokenId;
                index +=1;
            }
        }
        uint256[] memory tokens = new uint256[](index);
        for(uint i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }
        return tokens;
    }

    function onERC721Received(address, address from, uint256, bytes calldata) external view override returns (bytes4) {
        require(from == address(this), "Cannot send nfts to Vault directly");
        return IERC721Receiver.onERC721Received.selector;
    }

}