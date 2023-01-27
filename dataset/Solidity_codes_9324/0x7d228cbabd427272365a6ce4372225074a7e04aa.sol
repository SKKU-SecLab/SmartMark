
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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
        unchecked {
            _balances[account] = accountBalance - amount;
        }
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

}// MIT
pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20Mintable is Ownable, ERC20 {
    address public minter;

    constructor (address minter_, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
      minter = minter_;
    }

    function setMinter(address _minter) public onlyOwner {
      minter = _minter;
    }

    modifier onlyMinter() {
        require(minter == _msgSender(), "Only minter can call.");
        _;
    }


    function mint(address account, uint256 amount) onlyMinter public {
        _mint(account, amount);
    }
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

    function toHexStringWithColorPrefix(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 1);
        buffer[0] = "#";
        for (uint256 i = 2 * length; i > 0; --i) {
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
}// MIT

pragma solidity ^0.8.0;

contract Signature {
  function splitSignature(bytes memory sig)
      public pure returns (bytes32 r, bytes32 s, uint8 v)
  {
      require(sig.length == 65, "invalid signature length");

      assembly {
          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
      }

      if (v < 27) v += 27;
  }

  function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
      return _isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s);
  }

  function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
      internal pure returns (bool)
  {
      return ecrecover(messageHash, v, r, s) == _address;
  }

  function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
      internal pure returns (bool)
  {
      bytes memory prefix = "\x19Ethereum Signed Message:\n32";
      return _isSigned(_address, keccak256(abi.encodePacked(prefix, messageHash)), v, r, s);
  }
  
}// MIT

pragma solidity ^0.8.0;


contract LondonBurn is Ownable, ERC721, Signature {

    address public mintingAuthority;
    address public minter;
    string public contractURI;

    mapping(uint256 => string) public tokenIdToUri;
    mapping(uint256 => uint256) public tokenTypeSupply;

    mapping(bytes32 => uint256) contentHashToTokenId;

    string public baseMetadataURI;

    struct MintCheck {
      address to;
      uint256 tokenType;
      string[] uris;
      bytes signature;
    }

    struct ModifyCheck {
      uint256[] tokenIds;
      string[] uris;
      bytes signature;
    }

    event MintCheckUsed(uint256 indexed tokenId, bytes32 indexed mintCheck);
    event ModifyCheckUsed(uint256 indexed tokenId, bytes32 indexed modifyCheck);
    
    constructor (
      string memory name_,
      string memory symbol_
    ) ERC721(name_, symbol_) {
    }

    function setContractURI(string calldata newContractURI) external onlyOwner {
        contractURI = newContractURI;
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function setMintingAuthority(address _mintingAuthority) external onlyOwner {
      mintingAuthority = _mintingAuthority;
    }

    modifier onlyMinter() {
        require(minter == _msgSender(), "Caller is not the minter");
        _;
    }

    function setBaseMetadataURI(string memory _baseMetadataURI) public onlyOwner {
      baseMetadataURI = _baseMetadataURI;
    }

    function _baseURI() override internal view virtual returns (string memory) {
      return baseMetadataURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(abi.encodePacked(tokenIdToUri[tokenId]).length != 0, "ERC721Metadata: URI query for nonexistent token URI");

        return string(abi.encodePacked(_baseURI(), tokenIdToUri[tokenId]));
    }

   function getMintCheckHash(MintCheck calldata _mintCheck) public pure returns (bytes32) {
      bytes memory input = abi.encodePacked(_mintCheck.to, _mintCheck.tokenType);
      for (uint i = 0; i < _mintCheck.uris.length; ++i) {
        input = abi.encodePacked(input, _mintCheck.uris[i]);
      }
      return keccak256(input);
    }

    function verifyMintCheck(
      MintCheck calldata _mintCheck
    ) public view returns (bool) {
      bytes32 signedHash = getMintCheckHash(_mintCheck);
      (bytes32 r, bytes32 s, uint8 v) = splitSignature(_mintCheck.signature);
      return isSigned(mintingAuthority, signedHash, v, r, s);
    }


    function mintTokenType(MintCheck calldata _mintCheck) external onlyMinter {
      bytes32 mintCheckHash = getMintCheckHash(_mintCheck);
      (bytes32 r, bytes32 s, uint8 v) = splitSignature(_mintCheck.signature);
      require(isSigned(mintingAuthority, mintCheckHash, v, r, s), "Mint check is not valid");

      for (uint i = 0; i < _mintCheck.uris.length; ++i) {
        bytes32 contentHash = keccak256(abi.encodePacked(_mintCheck.uris[i]));
        require(contentHashToTokenId[contentHash] == 0, "Mint check has already been used");
        uint tokenId = (_mintCheck.tokenType | ++tokenTypeSupply[_mintCheck.tokenType]);
        _mint(_mintCheck.to, tokenId);
        tokenIdToUri[tokenId] = _mintCheck.uris[i];
        contentHashToTokenId[contentHash] = tokenId;
        emit MintCheckUsed(tokenId, mintCheckHash);
      }
    }

    function getModifyCheckHash(ModifyCheck calldata _modifyCheck) public pure returns (bytes32) {
      bytes memory input = abi.encodePacked("");
      for (uint i = 0; i < _modifyCheck.tokenIds.length; ++i) {
        input = abi.encodePacked(input, _modifyCheck.tokenIds[i]);
      }
      for (uint i = 0; i < _modifyCheck.uris.length; ++i) {
        input = abi.encodePacked(input, _modifyCheck.uris[i]);
      }
      return keccak256(input);
    }

    function verifyModifyCheck(
      ModifyCheck calldata _modifyCheck
    ) public view returns (bool) {
      bytes32 signedHash = getModifyCheckHash(_modifyCheck);
      (bytes32 r, bytes32 s, uint8 v) = splitSignature(_modifyCheck.signature);
      return isSigned(mintingAuthority, signedHash, v, r, s);
    }

    function modifyBaseURIByModifyCheck(ModifyCheck calldata _modifyCheck) external {
      require(_modifyCheck.tokenIds.length == _modifyCheck.uris.length, "tokenIds mismatch with uris");
      bytes32 modifyCheckHash = getModifyCheckHash(_modifyCheck);
      (bytes32 r, bytes32 s, uint8 v) = splitSignature(_modifyCheck.signature);
      require(isSigned(mintingAuthority, modifyCheckHash, v, r, s), "Modify check is not valid");

      for (uint i = 0; i < _modifyCheck.tokenIds.length; ++i) {
        bytes32 contentHash = keccak256(abi.encodePacked(_modifyCheck.uris[i]));
        require(contentHashToTokenId[contentHash] == 0, "Modify check has already been used");
        require(_exists(_modifyCheck.tokenIds[i]), "Tokenid does not exist");
        tokenIdToUri[_modifyCheck.tokenIds[i]] = _modifyCheck.uris[i];
        contentHashToTokenId[contentHash] = _modifyCheck.tokenIds[i];
        emit MintCheckUsed(_modifyCheck.tokenIds[i], modifyCheckHash);
      }
    }
}// MIT

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}// MIT

pragma solidity ^0.8.0;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// MIT

pragma solidity ^0.8.0;


contract LondonBurnMinterBase is Ownable, Signature {
    using Strings for uint256;

    IUniswapV2Router02 public immutable sushiswap;

    LondonBurn public immutable londonBurn;

    ERC20 public immutable payableErc20;

    ERC721 public immutable externalBurnableERC721;

    address public treasury;

    uint256 public ultraSonicForkBlockNumber = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 public revealBlockNumber = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 public burnRevealBlockNumber = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 constant NOBLE_TYPE =    0x8000000000000000000000000000000100000000000000000000000000000000;
    uint256 constant GIFT_TYPE =     0x8000000000000000000000000000000200000000000000000000000000000000;
    uint256 constant PRISTINE_TYPE = 0x8000000000000000000000000000000300000000000000000000000000000000;
    uint256 constant ETERNAL_TYPE =  0x8000000000000000000000000000000400000000000000000000000000000000;
    uint256 constant ASHEN_TYPE =    0x8000000000000000000000000000000500000000000000000000000000000000;
    uint256 constant ULTRA_SONIC_TYPE =   0x8000000000000000000000000000000600000000000000000000000000000000;

    constructor (
      address _mintableNFT, 
      address _payableErc20,
      address _externalBurnableERC721,
      address _sushiswap
    ) {
      londonBurn = LondonBurn(_mintableNFT);
      payableErc20 = ERC20(_payableErc20);
      externalBurnableERC721 = ERC721(_externalBurnableERC721);
      sushiswap = IUniswapV2Router02(_sushiswap);
    }

    function setTreasury(address _treasury) external onlyOwner {
      treasury = _treasury;
    }

    function _payLondon(address from, uint amount) internal {
      if (msg.value == 0) {
        payableErc20.transferFrom(from, treasury, amount);
      } else {
        address[] memory path = new address[](2);
        path[0] = sushiswap.WETH();
        path[1] = address(payableErc20);
        uint[] memory amounts = sushiswap.swapETHForExactTokens{value: msg.value}(amount, path, address(this), block.timestamp);
        payableErc20.transfer(treasury, amount);
        if (msg.value > amounts[0]) msg.sender.call{value: msg.value - amounts[0]}(""); // transfer any overpayment back to payer
      }
    }

    function setUltraSonicForkBlockNumber(uint256 _ultraSonicForkBlockNumber) external onlyOwner {
        ultraSonicForkBlockNumber = _ultraSonicForkBlockNumber;
    }

    function setRevealBlockNumber(uint256 _revealBlockNumber) external onlyOwner {
        revealBlockNumber = _revealBlockNumber;
    }

    function setBurnRevealBlockNumber(uint256 _burnRevealBlockNumber) external onlyOwner {
        burnRevealBlockNumber = _burnRevealBlockNumber;
    }

    fallback() external payable { 
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract LondonBurnAshen is LondonBurnMinterBase {
  uint256 constant MIN_SELF_AMOUNT_PER_BURN =    3;
  uint256 constant MAX_SELF_AMOUNT_PER_BURN =    7;

  constructor(
  ) {
  }

  function numBurnFromSelfAmount(uint256 amount) public pure returns (uint256) {
    return amount - 1;
  }

  function londonNeededFromSelfAmount(uint256 amount) public view returns (uint256) {
    if (block.number >= ultraSonicForkBlockNumber) {
      return 1559 ether;
    } else {
      return 1559 ether * amount;
    }
  }

  function mintAshenType(
    uint256[] calldata tokenIds,
    LondonBurn.MintCheck calldata _mintCheck
  ) payable public {
    require(block.number > burnRevealBlockNumber, 'ASHEN has not been revealed yet');
    require(tokenIds.length >= MIN_SELF_AMOUNT_PER_BURN && tokenIds.length <= MAX_SELF_AMOUNT_PER_BURN , "Exceeded self burn range");
    _payLondon(_msgSender(), londonNeededFromSelfAmount(tokenIds.length));
    for (uint i = 0; i < tokenIds.length; ++i) {
      londonBurn.transferFrom(_msgSender(), address(0xdead), tokenIds[i]);
    }
    require(_mintCheck.uris.length == numBurnFromSelfAmount(tokenIds.length), "MintCheck required mismatch");
    require(_mintCheck.tokenType == (block.number < ultraSonicForkBlockNumber ? ASHEN_TYPE : ULTRA_SONIC_TYPE), "Must be correct tokenType");
    londonBurn.mintTokenType(_mintCheck);
  }
}// MIT

pragma solidity ^0.8.0;


abstract contract LondonBurnGift is LondonBurnMinterBase {
  uint256 constant MIN_GIFT_AMOUNT_PER_BURN =    2;
  uint256 constant MAX_GIFT_AMOUNT_PER_BURN =    15;
  uint256 constant MAX_TOTAL_GIFT_BURN_AMOUNT =    1559;

  uint256 totalGiftBurnAmount;
  uint256 numGiftBurns;

  constructor(
  ) {
  }

  function numBurnFromGiftAmount(uint256 amount) public view returns (uint256) {
    if (block.number >= ultraSonicForkBlockNumber) {
      return 1;
    }
    return (amount * 2) - 1;
  }

  function londonNeededFromGiftAmount(uint256 amount) public view returns (uint256) {
    if (block.number >= ultraSonicForkBlockNumber) {
      return 1559 ether;
    }
    if (amount == 2) {
      return 3375 ether;
    }
    if (amount == 3) {
      return 4629 ether;
    }
    if (amount == 4) {
      return 5359 ether;
    }
    if (amount == 5) {
      return 5832 ether;
    }
    if (amount == 6) {
      return 6162 ether;
    }
    if (amount == 7) {
      return 6405 ether;
    }
    if (amount == 8) {
      return 6591 ether;
    }
    if (amount == 9) {
      return 6739 ether;
    }
    if (amount == 10) {
      return 6859 ether;
    }
    if (amount == 11) {
      return 6958 ether;
    }
    if (amount == 12) {
      return 7041 ether;
    }
    if (amount == 13) {
      return 7111 ether;
    }
    if (amount == 14) {
      return 7173 ether;
    }
    if (amount == 15) {
      return 7226 ether;
    }
    return 0;
  }

  function mintGiftType(
    uint256[] calldata giftTokenIds,
    LondonBurn.MintCheck calldata mintCheck
  ) payable public {
    require(block.number > burnRevealBlockNumber, 'GIFT has not been revealed yet');
    require(totalGiftBurnAmount + giftTokenIds.length <= MAX_TOTAL_GIFT_BURN_AMOUNT, "Max GIFT burnt");
    require(giftTokenIds.length >= MIN_GIFT_AMOUNT_PER_BURN && giftTokenIds.length <= MAX_GIFT_AMOUNT_PER_BURN , "Exceeded gift burn range");
    _payLondon(_msgSender(), londonNeededFromGiftAmount(giftTokenIds.length));
    for (uint i = 0; i < giftTokenIds.length; ++i) {
      externalBurnableERC721.transferFrom(_msgSender(), address(0xdead), giftTokenIds[i]);
    }
    
    require(mintCheck.uris.length == numBurnFromGiftAmount(giftTokenIds.length), "MintCheck required mismatch");
    require(mintCheck.tokenType == (block.number < ultraSonicForkBlockNumber ? GIFT_TYPE : ULTRA_SONIC_TYPE), "Must be correct tokenType");
    londonBurn.mintTokenType(mintCheck);
    totalGiftBurnAmount += giftTokenIds.length;
    numGiftBurns++;
  }
}// MIT

pragma solidity ^0.8.0;


abstract contract LondonBurnNoble is LondonBurnMinterBase {
  enum Nobility {
    Common,
    Baron, 
    Earl, 
    Duke
  }
  
  mapping(Nobility => uint256) airdropAmount;

  constructor(
  ) {
    airdropAmount[Nobility.Baron] = 2;
    airdropAmount[Nobility.Earl] = 5;
    airdropAmount[Nobility.Duke] = 16;
  }

  address public airdropAuthority;

  mapping(address => uint256) public receivedAirdropNum;

  function getAirdropHash(address to, Nobility nobility) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(to, nobility));
  }

  function setAirdropAuthority(address _airdropAuthority) external onlyOwner {
    airdropAuthority = _airdropAuthority;
  }
  
  function verifyAirdrop(
    address to, Nobility nobility, bytes calldata signature
  ) public view returns (bool) {
    bytes32 signedHash = getAirdropHash(to, nobility);
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
    return isSigned(airdropAuthority, signedHash, v, r, s);
  }

  function mintNobleType(
    Nobility nobility, bytes calldata signature, LondonBurn.MintCheck calldata mintCheck
  ) public {
    require(block.number > revealBlockNumber, 'NOBLE has not been revealed yet');
    require(block.number < ultraSonicForkBlockNumber, "ULTRASONIC MODE ENGAGED");
    require(verifyAirdrop(_msgSender(), nobility, signature), "Noble mint is not valid");
    require(mintCheck.uris.length <= airdropAmount[nobility], "MintChecks length mismatch");
    require(receivedAirdropNum[_msgSender()] + mintCheck.uris.length <= airdropAmount[nobility], "Already received airdrop");
    require(mintCheck.tokenType == NOBLE_TYPE, "Must be correct tokenType");
    londonBurn.mintTokenType(mintCheck);
    receivedAirdropNum[_msgSender()] += mintCheck.uris.length;
  }

}// MIT

pragma solidity ^0.8.0;


abstract contract LondonBurnPristine is LondonBurnMinterBase {
  uint256 constant MAX_PRISTINE_AMOUNT_PER_MINT =    4;
  uint256 constant PRISTINE_MINTABLE_SUPPLY =    500;
  uint256 constant PRICE_PER_PRISTINE_MINT =    1559 ether; // since $LONDON is 10^18 we can use ether as a unit of accounting
  address lastMinter;

  constructor(
  ) {
  }
 
  function mintPristineType(
    LondonBurn.MintCheck calldata mintCheck
  ) payable public {
    require(block.number > revealBlockNumber, 'PRISTINE has not been revealed yet');
    require(block.number < ultraSonicForkBlockNumber, "ULTRASONIC MODE ENGAGED");
    require(mintCheck.uris.length <= MAX_PRISTINE_AMOUNT_PER_MINT, "Exceeded per tx mint amount");
    require(lastMinter != tx.origin, "Can't mint consecutively");
    require(londonBurn.tokenTypeSupply(PRISTINE_TYPE) + mintCheck.uris.length <= PRISTINE_MINTABLE_SUPPLY, "Exceeded PRISTINE mint amount");
    _payLondon(_msgSender(), mintCheck.uris.length * PRICE_PER_PRISTINE_MINT);
    require(mintCheck.tokenType == PRISTINE_TYPE, "Must be correct tokenType");
    londonBurn.mintTokenType(mintCheck);
    lastMinter = tx.origin;
  }
}// MIT

pragma solidity ^0.8.0;


abstract contract LondonBurnEternal is LondonBurnMinterBase {
  uint256 constant ETERNAL_MINTABLE_SUPPLY = 100;

  constructor(
  ) {
  }
 
  function mintEternalType(
    LondonBurn.MintCheck calldata _mintCheck
  ) public {
    require(block.number > revealBlockNumber, 'ETERNAL has not been revealed yet');
    require(block.number < ultraSonicForkBlockNumber, "ULTRASONIC MODE ENGAGED");
    require(londonBurn.tokenTypeSupply(ETERNAL_TYPE) + _mintCheck.uris.length <= ETERNAL_MINTABLE_SUPPLY, "Exceeded ETERNAL mint amount");
    require(_mintCheck.to == treasury, 'MintCheck do not mint to treasury');
    require(_mintCheck.tokenType == ETERNAL_TYPE, "Must be correct tokenType");
    londonBurn.mintTokenType(_mintCheck);
  }
}// MIT

pragma solidity ^0.8.0;


contract LondonBurnMinter is LondonBurnMinterBase, LondonBurnNoble, LondonBurnAshen, LondonBurnGift, LondonBurnPristine, LondonBurnEternal {
  constructor(
      address _mintableNFT, 
      address _payableErc20,
      address _externalBurnableERC721,
      address _sushiswap
  ) LondonBurnMinterBase(_mintableNFT, _payableErc20, _externalBurnableERC721, _sushiswap) {
  }
}