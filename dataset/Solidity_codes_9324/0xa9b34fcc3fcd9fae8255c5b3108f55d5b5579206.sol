
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

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;


interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}// MIT LICENSE
pragma solidity ^0.8.0;


contract Metadata is Ownable {
    using Strings for uint256;

    struct Trait {
        string name;
        string image;
    }

    string[4] categoryNames = ["Color", "Expression", "Accesory", "Hat"];

    mapping(uint8=>mapping(uint8=>Trait)) public traitData;

    constructor() {}

    function uploadTraits(uint8 category, Trait[] calldata traits)
        public
        onlyOwner
    {
        require(traits.length == 16, "Wrong length");
        for (uint8 i = 0; i < traits.length; i++) {
            traitData[category][i] = Trait(traits[i].name, traits[i].image);
        }
    }

    function drawTrait(Trait memory trait)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<image x="0" y="0" width="64" height="64" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    trait.image,
                    '"/>'
                )
            );
    }

    function drawSVG(bool isFox, uint8[] memory traits)
        public
        view
        returns (string memory)
    {
        uint8 offset = isFox ? 4 : 0;
        string memory svgString = string(
            abi.encodePacked(
                drawTrait(traitData[offset][traits[0]]),
                drawTrait(traitData[1 + offset][traits[1]]),
                drawTrait(traitData[2 + offset][traits[2]]),
                drawTrait(traitData[3 + offset][traits[3]])
            )
        );

        return
            string(
                abi.encodePacked(
                    '<svg id="foxhen" width="100%" height="100%" version="1.1" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    svgString,
                    "</svg>"
                )
            );
    }

    function attributeForTypeAndValue(
        string memory categoryName,
        string memory value
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                    categoryName,
                    '","value":"',
                    value,
                    '"}'
                )
            );
    }

    function compileAttributes(
        bool isFox,
        uint8[] memory traits,
        uint256 tokenId
    ) public view returns (string memory) {
        uint8 offset = isFox ? 4 : 0;
        string memory attributes = string(
            abi.encodePacked(
                attributeForTypeAndValue(
                    categoryNames[0],
                    traitData[offset][traits[0]].name
                ),
                ",",
                attributeForTypeAndValue(
                    categoryNames[1],
                    traitData[offset + 1][traits[1]].name
                ),
                ",",
                attributeForTypeAndValue(
                    categoryNames[2],
                    traitData[offset + 2][traits[2]].name
                ),
                ",",
                attributeForTypeAndValue(
                    categoryNames[3],
                    traitData[offset + 3][traits[3]].name
                ),
                ","
            )
        );
        return
            string(
                abi.encodePacked(
                    "[",
                    attributes,
                    '{"trait_type":"Generation","value":',
                    tokenId <= 10000 ? '"Gen 0"' : '"Gen 1"',
                    '},{"trait_type":"Type","value":',
                    isFox ? '"Fox"' : '"Hen"',
                    "}]"
                )
            );
    }

    function tokenMetadata(
        bool isFox,
        uint256 traitId,
        uint256 tokenId
    ) public view returns (string memory) {
        uint8[] memory traits = new uint8[](4);
        uint256 traitIdBackUp = traitId;
        for (uint8 i = 0; i < 4; i++) {
            uint8 exp = 3 - i;
            uint8 tmp = uint8(traitIdBackUp / (16**exp));
            traits[i] = tmp;
            traitIdBackUp -= tmp * 16**exp;
        }

        string memory svg = drawSVG(isFox, traits);

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "',
                isFox ? "Fox #" : "Hen #",
                tokenId.toString(),
                '", "description": "A sunny day in the Summer begins, with the Farmlands and the Forest In its splendor, it seems like a normal day. But the cunning planning of the Foxes has begun, they know that the hens will do everything to protect their precious $EGG but can they keep them all without risk of losing them? A Risk-Reward economic game, where every action matters. No IPFS. No API. All stored and generated 100% on-chain", "image": "data:image/svg+xml;base64,',
                base64(bytes(svg)),
                '", "attributes":',
                compileAttributes(isFox, traits, tokenId),
                "}"
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    base64(bytes(metadata))
                )
            );
    }


    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function base64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)

                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}// MIT LICENSE

pragma solidity ^0.8.0;


contract FoxHen is ERC721Enumerable, Ownable, VRFConsumerBase {
  uint256 public constant ETH_PRICE = 0.065 ether;
  uint256 public constant MAX_TOKENS = 20000;
  uint256 public constant ETH_TOKENS = 7000;
  uint16 public purchased = 0;

  uint24 public constant poolFee = 3000;
  address public WETH9;

  struct Minting {
    address minter;
    uint256 tokenId;
    bool fulfilled;
  }
  mapping(bytes32=>Minting) mintings;

  struct TokenWithMetadata {
    uint256 tokenId;
    bool isFox;
    string metadata;
  }

  mapping(uint256=>bool) public isFox;
  uint256[] public foxes;
  uint16 public stolenMints;
  mapping(uint256=>uint256) public traitsOfToken;
  mapping(uint256=>bool) public traitsTaken;
  bool public mainSaleStarted;
  mapping(bytes=>bool) public signatureUsed;

  IERC20 eggs;
  ISwapRouter swapRouter;
  AggregatorV3Interface priceFeed;
  Metadata metadata;

  bytes32 internal keyHash;
  uint256 internal fee;

  constructor(address _eggs, address _vrf, address _link, bytes32 _keyHash, uint256 _fee, address _swapRouter, address _metadata, address _WETH, address _feed) ERC721("FoxHen", 'FH') VRFConsumerBase(_vrf, _link) {
    eggs = IERC20(_eggs);
    swapRouter = ISwapRouter(_swapRouter);
    priceFeed = AggregatorV3Interface(_feed);
    metadata = Metadata(_metadata);
    keyHash = _keyHash;
    fee = _fee;
    WETH9 = _WETH;
    require(IERC20(_link).approve(msg.sender, type(uint256).max));
    require(eggs.approve(msg.sender, type(uint256).max));
  }

  function swapEthForLINK(uint256 amount) internal {
    if (LINK.balanceOf(address(this)) < amount * fee) {
      uint256 minAmount = 99 * linkPrice() * msg.value / 100;
      ISwapRouter.ExactInputSingleParams memory params =
        ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH9,
            tokenOut: address(LINK),
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: msg.value,
            amountOutMinimum: minAmount,
            sqrtPriceLimitX96: 0
        });
      swapRouter.exactInputSingle{ value: msg.value }(params);
    }
  }

  function setTraits(uint256 tokenId, uint256 seed) internal returns (uint256) {
    uint256 maxTraits = 16 ** 4;
    uint256 nextRandom = uint256(keccak256(abi.encode(seed, 1)));
    uint256 traitsID = nextRandom % maxTraits;
    while(traitsTaken[traitsID]) {
      nextRandom = uint256(keccak256(abi.encode(nextRandom, 1)));
      traitsID = nextRandom % maxTraits;
    }
    traitsTaken[traitsID] = true;
    traitsOfToken[tokenId] = traitsID;
    return traitsID;
  }

  function setSpecies(uint256 tokenId, uint256 seed) internal returns (bool) {
    uint256 random = uint256(keccak256(abi.encode(seed, 2))) % 10;
    if (random == 0) {
      isFox[tokenId] = true;
      foxes.push(tokenId);
      return true;
    }
    return false;
  }

  function getRecipient(uint256 tokenId, address minter, uint256 seed) internal view returns (address) {
    if (tokenId > ETH_TOKENS && (uint256(keccak256(abi.encode(seed, 3))) % 10) == 0) {
      uint256 fox = foxes[uint256(keccak256(abi.encode(seed, 4))) % foxes.length];
      address owner = ownerOf(fox);
      if (owner != address(0)) {
        return owner;
      }
    }
    return minter;
  }

  function eggsPrice() public view returns (uint256) {
    require(purchased >= ETH_TOKENS);
    uint16 secondGen = purchased - uint16(ETH_TOKENS);
    if (secondGen < 5000) {
      return 30 ether;
    }
    if (secondGen < 10000) {
      return 60 ether;
    }
    return 120 ether;
  }

  function foxCount() public view returns (uint256) {
    return foxes.length;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return metadata.tokenMetadata(isFox[tokenId], traitsOfToken[tokenId], tokenId);
  }

  function linkPrice() public view returns (uint256) {
    (, int price,,,) = priceFeed.latestRoundData();
    return uint256(price);
  }

  function allTokensOfOwner(address owner) public view returns (TokenWithMetadata[] memory) {
    uint256 balance = balanceOf(owner);
    TokenWithMetadata[] memory tokens = new TokenWithMetadata[](balance);
    for (uint256 i = 0; i < balance; i++) {
      uint256 tokenId = tokenOfOwnerByIndex(owner, i);
      string memory data = tokenURI(tokenId);
      tokens[i] = TokenWithMetadata(tokenId, isFox[tokenId], data);
    }
    return tokens;
  }

  function buyFromWhitelist(bytes memory signature, uint256 seed) public payable {
    address minter = _msgSender();
    require(tx.origin == minter, "Contracts not allowed");
    require(purchased + 1 <= ETH_TOKENS, "Sold out");
    require(ETH_PRICE <= msg.value, "You need to send enough eth");
    require(!signatureUsed[signature], "Signature already used");

    bytes32 messageHash = keccak256(abi.encodePacked("foxhen", msg.sender, seed));
    bytes32 digest = ECDSA.toEthSignedMessageHash(messageHash);

    address signer = ECDSA.recover(digest, signature);
    require(signer == owner(), "Invalid signature");
    signatureUsed[signature] = true;
    
    purchased += 1;

    swapEthForLINK(1);

    bytes32 requestId = requestRandomness(keyHash, fee);
    mintings[requestId] = Minting(minter, purchased, false);
  }

  function buyWithEth(uint16 amount) public payable {
    require(mainSaleStarted, "Main Sale hasn't started yet");
    address minter = _msgSender();
    require(tx.origin == minter, "Contracts not allowed");
    require(amount > 0 && amount <= 20, "Max 20 mints per tx");
    require(purchased + amount <= ETH_TOKENS, "Sold out");
    require(amount * ETH_PRICE <= msg.value, "You need to send enough eth");

    uint256 initialPurchased = purchased;
    purchased += amount;
    swapEthForLINK(amount);

    for (uint16 i = 1; i <= amount; i++) {
      bytes32 requestId = requestRandomness(keyHash, fee);
      mintings[requestId] = Minting(minter, initialPurchased + i, false);
    }
  }

  function buyWithEggs(uint16 amount) public {
    address minter = _msgSender();
    require(mainSaleStarted, "Main Sale hasn't started yet");
    require(tx.origin == minter, "Contracts not allowed");
    require(amount > 0 && amount <= 20, "Max 20 mints per tx");
    require(purchased > ETH_TOKENS, "Eggs sale not active");
    require(purchased + amount <= MAX_TOKENS, "Sold out");

    uint256 price = amount * eggsPrice();
    require(price <= eggs.allowance(minter, address(this)) && price <= eggs.balanceOf(minter), "You need to send enough eggs");
    
    uint256 initialPurchased = purchased;
    purchased += amount;
    require(eggs.transferFrom(minter, address(this), price));

    for (uint16 i = 1; i <= amount; i++) {
      bytes32 requestId = requestRandomness(keyHash, fee);
      mintings[requestId] = Minting(minter, initialPurchased + i, false);
    }
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    Minting storage minting = mintings[requestId];
    require(minting.minter != address(0));
    setSpecies(minting.tokenId, randomness);
    setTraits(minting.tokenId, randomness);

    address recipient = getRecipient(minting.tokenId, minting.minter, randomness);
    if (recipient != minting.minter) {
      stolenMints++;
    }
    _mint(recipient, minting.tokenId);
  }

  function withdraw(uint256 amount) external onlyOwner {
    payable(owner()).transfer(amount);
  }

  function toggleMainSale() public onlyOwner {
    mainSaleStarted = !mainSaleStarted;
  }
}// MIT LICENSE

pragma solidity ^0.8.0;


contract HenHouse is Ownable, VRFConsumerBase {
    FoxHen fh;
    IERC20 eggs;
    AggregatorV3Interface priceFeed;
    uint24 public constant poolFee = 3000;
    struct Staking {
        uint256 timestamp;
        address owner;
        uint16 stolen;
    }

    struct CurrentValue {
        uint256 tokenId;
        uint256 timestamp;
        uint256 value;
        string metadata;
    }

    struct Fox {
        uint256 timestamp;
        uint256 dailyCount;
        uint256 foxValue;
    }

    mapping(uint256 => Staking) public stakings;
    mapping(address => uint256[]) public stakingsByOwner;

    uint256 public foxValue;
    uint256 public foxCount;
    uint256 public eggsHeistedAmount;
    uint256 public heistAmount;
    uint256 public totalTaxAmount;
    mapping(uint256 => Fox) public foxes;
    mapping(bytes32 => uint256) heists;

    uint16 public taxPercentage = 15;
    uint16 public heistPercentage = 30;
    uint16 public taxFreeDays = 3;

    bytes32 internal keyHash;
    uint256 internal fee;

    bool public paused;

    event Heist(
        address indexed owner,
        uint256 indexed fox,
        uint256 hen,
        uint256 amount
    );

    constructor(
        address _fh,
        address _eggs,
        address _vrf,
        address _link,
        address _feed,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrf, _link) {
        fh = FoxHen(_fh);
        eggs = IERC20(_eggs);
        priceFeed = AggregatorV3Interface(_feed);
        IERC20(_link).approve(msg.sender, type(uint256).max);
        keyHash = _keyHash;
        fee = _fee;
    }

    function daysStaked(uint256 tokenId) public view returns (uint256) {
        Staking storage staking = stakings[tokenId];
        uint256 diff = block.timestamp - staking.timestamp;
        return uint256(diff) / 1 days;
    }

    function calculateReward(uint256 tokenId) public view returns (uint256) {
        require(fh.ownerOf(tokenId) == address(this), "The hen must be staked");
        uint256 balance = eggs.balanceOf(address(this));
        Staking storage staking = stakings[tokenId];
        uint256 baseReward = 100000 ether / uint256(1 days);
        uint256 diff = block.timestamp - staking.timestamp;
        uint256 dayCount = uint256(diff) / (1 days);
        if (dayCount < 1 || balance == 0) {
            return 0;
        }
        uint256 yesterday = dayCount - 1;
        uint256 dayRewards = (yesterday * yesterday + yesterday) /
            2 +
            10 *
            dayCount;
        uint256 ratio = (((dayRewards / dayCount) *
            (diff - dayCount * 1 days)) / 1 days) + dayRewards;
        uint256 reward = baseReward * ratio;
        return reward < balance ? reward : balance;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (uint256)
    {
        return stakingsByOwner[owner][index];
    }

    function balanceOf(address owner) public view returns (uint256) {
        return stakingsByOwner[owner].length;
    }

    function allStakingsOfOwner(address owner)
        public
        view
        returns (CurrentValue[] memory)
    {
        uint256 balance = balanceOf(owner);
        CurrentValue[] memory list = new CurrentValue[](balance);
        for (uint16 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            Staking storage staking = stakings[tokenId];
            uint256 reward = calculateReward(tokenId) - staking.stolen;
            string memory metadata = fh.tokenURI(tokenId);
            list[i] = CurrentValue(tokenId, staking.timestamp, reward, metadata);
        }
        return list;
    }

    function linkPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function heistCost(uint256 tokenId) public view returns (uint256) {
        Fox storage fox = foxes[tokenId];
        uint256 diff = block.timestamp - fox.timestamp;
        uint256 exp = diff > 1 days ? 1 : fox.dailyCount + 1;
        return ((2**exp) * linkPrice() * 102) / 100;
    }


    function stakeHen(uint256 tokenId) public {
        require(!paused, "Contract paused");
        require(fh.ownerOf(tokenId) == msg.sender, "You must own that hen");
        require(!fh.isFox(tokenId), "You can only stake hens");
        require(fh.isApprovedForAll(msg.sender, address(this)));

        Staking memory staking = Staking(block.timestamp, msg.sender, 0);
        stakings[tokenId] = staking;
        stakingsByOwner[msg.sender].push(tokenId);
        fh.transferFrom(msg.sender, address(this), tokenId);
    }

    function multiStakeHen(uint256[] memory henIds) public {
        for (uint8 i = 0; i < henIds.length; i++) {
            stakeHen(henIds[i]);
        }
    }

    function unstakeHen(uint256 tokenId) public {
        require(fh.ownerOf(tokenId) == address(this), "The hen must be staked");
        Staking storage staking = stakings[tokenId];
        require(staking.owner == msg.sender, "You must own that hen");
        uint256[] storage stakedHens = stakingsByOwner[msg.sender];
        uint16 index = 0;
        for (; index < stakedHens.length; index++) {
            if (stakedHens[index] == tokenId) {
                break;
            }
        }
        require(index < stakedHens.length, "Hen not found");
        stakedHens[index] = stakedHens[stakedHens.length - 1];
        stakedHens.pop();
        staking.owner = address(0);
        fh.transferFrom(address(this), msg.sender, tokenId);
    }

    function claimHenRewards(uint256 tokenId, bool unstake) public {
        require(!paused, "Contract paused");
        uint256 netRewards = _claimHenRewards(tokenId);
        if (unstake) {
            unstakeHen(tokenId);
        }
        if (netRewards > 0) {
            require(eggs.transfer(msg.sender, netRewards));
        }
    }

    function claimManyHenRewards(uint256[] calldata hens, bool unstake) public {
        require(!paused, "Contract paused");
        uint256 netRewards = 0;
        for (uint8 i = 0; i < hens.length; i++) {
            netRewards += _claimHenRewards(hens[i]);
        }
        if (netRewards > 0) {
            require(eggs.transfer(msg.sender, netRewards));
        }
        if (unstake) {
            for (uint8 i = 0; i < hens.length; i++) {
                unstakeHen(hens[i]);
            }
        }
    }

    function claimManyFoxesRewards(uint256[] calldata claimingFoxes) public {
        for (uint8 i = 0; i < claimingFoxes.length; i++) {
            heist(claimingFoxes[i], false);
        }
    }

    function heist(uint256 tokenId, bool enterHenHouse) public payable {
        require(!paused, "Contract paused");
        require(
            fh.ownerOf(tokenId) == msg.sender && fh.isFox(tokenId),
            "You must own that fox"
        );
        Fox storage fox = foxes[tokenId];

        if (fox.timestamp == 0) {
            fox.timestamp = block.timestamp;
            fox.foxValue = foxValue;
            foxCount++;
        }

        if (enterHenHouse) {
            uint256 cost = heistCost(tokenId);

            require(msg.value >= cost, "You must pay the correct amount");

            uint256 diff = block.timestamp - fox.timestamp;
            if (diff > 1 days) {
                fox.timestamp = block.timestamp;
                fox.dailyCount = 1;
            } else {
                fox.dailyCount++;
            }

            heistAmount++;
            bytes32 requestId = requestRandomness(keyHash, fee);
            heists[requestId] = tokenId;
        }

        if (fox.foxValue < foxValue) {
            uint256 tax = foxValue - fox.foxValue;
            fox.foxValue = foxValue;
            totalTaxAmount += tax;
            eggs.transfer(msg.sender, tax);
        }
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        uint256 foxId = heists[requestId];
        address foxOwner = fh.ownerOf(foxId);
        require(foxOwner != address(0));
        uint256 henIndex = randomness % fh.balanceOf(address(this));
        uint256 henId = fh.tokenOfOwnerByIndex(address(this), henIndex);
        Staking storage staking = stakings[henId];

        uint256 rewards = calculateReward(henId) - staking.stolen;
        uint256 stealAmount = (heistPercentage * rewards) / 100;

        if (stealAmount > 0) {
            eggsHeistedAmount += stealAmount;
            eggs.transfer(foxOwner, stealAmount);
        }
        emit Heist(foxOwner, foxId, henId, stealAmount);
    }

    function _claimHenRewards(uint256 tokenId) internal returns (uint256) {
        require(fh.ownerOf(tokenId) == address(this), "The hen must be staked");
        Staking storage staking = stakings[tokenId];
        require(staking.owner == msg.sender, "You must own that hen");

        uint256 rewards = calculateReward(tokenId);
        require(rewards >= staking.stolen, "You have no rewards at this time");
        rewards -= staking.stolen;

        uint256 tax = foxCount == 0 || daysStaked(tokenId) >= taxFreeDays
            ? 0
            : (taxPercentage * rewards) / 100;
        uint256 netRewards = rewards - tax;

        if (foxCount > 0 && tax > 0) {
            foxValue += tax / foxCount;
        }

        staking.stolen = 0;
        staking.timestamp = block.timestamp;

        return netRewards;
    }

    function withdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }
}