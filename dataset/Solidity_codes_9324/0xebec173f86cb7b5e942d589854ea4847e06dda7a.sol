
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

}// MIT

pragma solidity ^0.8.0;

interface ISwap {
  struct Order {
    uint256 nonce;
    uint256 expiry;
    address signerWallet;
    address signerToken;
    uint256 signerAmount;
    address senderWallet;
    address senderToken;
    uint256 senderAmount;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  event Swap(
    uint256 indexed nonce,
    uint256 timestamp,
    address indexed signerWallet,
    address signerToken,
    uint256 signerAmount,
    uint256 protocolFee,
    address indexed senderWallet,
    address senderToken,
    uint256 senderAmount
  );

  event Cancel(uint256 indexed nonce, address indexed signerWallet);

  event Authorize(address indexed signer, address indexed signerWallet);

  event Revoke(address indexed signer, address indexed signerWallet);

  event SetProtocolFee(uint256 protocolFee);

  event SetProtocolFeeLight(uint256 protocolFeeLight);

  event SetProtocolFeeWallet(address indexed feeWallet);

  event SetRebateScale(uint256 rebateScale);

  event SetRebateMax(uint256 rebateMax);

  event SetStaking(address indexed staking);

  function swap(
    address recipient,
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function light(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function buyNFT(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function sellNFT(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function swapNFTs(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function authorize(address sender) external;

  function revoke() external;

  function cancel(uint256[] calldata nonces) external;

  function nonceUsed(address, uint256) external view returns (bool);

  function authorized(address) external view returns (address);

  function calculateProtocolFee(address, uint256)
    external
    view
    returns (uint256);
}// MIT

pragma solidity ^0.8.0;


contract Swap is ISwap, Ownable {
  using SafeERC20 for IERC20;

  bytes32 public constant DOMAIN_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "uint256 chainId,",
        "address verifyingContract",
        ")"
      )
    );

  bytes32 public constant ORDER_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "Order(",
        "uint256 nonce,",
        "uint256 expiry,",
        "address signerWallet,",
        "address signerToken,",
        "uint256 signerAmount,",
        "uint256 protocolFee,",
        "address senderWallet,",
        "address senderToken,",
        "uint256 senderAmount",
        ")"
      )
    );

  bytes32 public constant DOMAIN_NAME = keccak256("SWAP");
  bytes32 public constant DOMAIN_VERSION = keccak256("3");
  uint256 public immutable DOMAIN_CHAIN_ID;
  bytes32 public immutable DOMAIN_SEPARATOR;

  uint256 internal constant MAX_PERCENTAGE = 100;
  uint256 internal constant MAX_SCALE = 77;
  uint256 internal constant MAX_ERROR_COUNT = 6;
  uint256 public constant FEE_DIVISOR = 10000;

  mapping(address => mapping(uint256 => uint256)) internal _nonceGroups;

  mapping(address => address) public override authorized;

  uint256 public protocolFee;
  uint256 public protocolFeeLight;
  address public protocolFeeWallet;
  uint256 public rebateScale;
  uint256 public rebateMax;
  address public staking;

  constructor(
    uint256 _protocolFee,
    uint256 _protocolFeeLight,
    address _protocolFeeWallet,
    uint256 _rebateScale,
    uint256 _rebateMax,
    address _staking
  ) {
    require(_protocolFee < FEE_DIVISOR, "INVALID_FEE");
    require(_protocolFeeLight < FEE_DIVISOR, "INVALID_FEE");
    require(_protocolFeeWallet != address(0), "INVALID_FEE_WALLET");
    require(_rebateScale <= MAX_SCALE, "SCALE_TOO_HIGH");
    require(_rebateMax <= MAX_PERCENTAGE, "MAX_TOO_HIGH");
    require(_staking != address(0), "INVALID_STAKING");

    uint256 currentChainId = getChainId();
    DOMAIN_CHAIN_ID = currentChainId;
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        DOMAIN_TYPEHASH,
        DOMAIN_NAME,
        DOMAIN_VERSION,
        currentChainId,
        this
      )
    );

    protocolFee = _protocolFee;
    protocolFeeLight = _protocolFeeLight;
    protocolFeeWallet = _protocolFeeWallet;
    rebateScale = _rebateScale;
    rebateMax = _rebateMax;
    staking = _staking;
  }

  function swap(
    address recipient,
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {
    _checkValidOrder(
      nonce,
      expiry,
      signerWallet,
      signerToken,
      signerAmount,
      senderToken,
      senderAmount,
      v,
      r,
      s
    );

    IERC20(senderToken).safeTransferFrom(
      msg.sender,
      signerWallet,
      senderAmount
    );

    IERC20(signerToken).safeTransferFrom(signerWallet, recipient, signerAmount);

    _transferProtocolFee(signerToken, signerWallet, signerAmount);

    emit Swap(
      nonce,
      block.timestamp,
      signerWallet,
      signerToken,
      signerAmount,
      protocolFee,
      msg.sender,
      senderToken,
      senderAmount
    );
  }

  function light(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {
    require(DOMAIN_CHAIN_ID == getChainId(), "CHAIN_ID_CHANGED");

    require(expiry > block.timestamp, "EXPIRY_PASSED");

    address signatory = ecrecover(
      keccak256(
        abi.encodePacked(
          "\x19\x01",
          DOMAIN_SEPARATOR,
          keccak256(
            abi.encode(
              ORDER_TYPEHASH,
              nonce,
              expiry,
              signerWallet,
              signerToken,
              signerAmount,
              protocolFeeLight,
              msg.sender,
              senderToken,
              senderAmount
            )
          )
        )
      ),
      v,
      r,
      s
    );

    require(signatory != address(0), "SIGNATURE_INVALID");

    require(_markNonceAsUsed(signatory, nonce), "NONCE_ALREADY_USED");

    if (signerWallet != signatory) {
      require(authorized[signerWallet] == signatory, "UNAUTHORIZED");
    }

    IERC20(senderToken).safeTransferFrom(
      msg.sender,
      signerWallet,
      senderAmount
    );

    IERC20(signerToken).safeTransferFrom(
      signerWallet,
      msg.sender,
      signerAmount
    );

    IERC20(signerToken).safeTransferFrom(
      signerWallet,
      protocolFeeWallet,
      (signerAmount * protocolFeeLight) / FEE_DIVISOR
    );

    emit Swap(
      nonce,
      block.timestamp,
      signerWallet,
      signerToken,
      signerAmount,
      protocolFeeLight,
      msg.sender,
      senderToken,
      senderAmount
    );
  }

  function buyNFT(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerID,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override {
    _checkValidOrder(
      nonce,
      expiry,
      signerWallet,
      signerToken,
      signerID,
      senderToken,
      senderAmount,
      v,
      r,
      s
    );

    IERC20(senderToken).safeTransferFrom(
      msg.sender,
      signerWallet,
      senderAmount
    );

    IERC721(signerToken).transferFrom(signerWallet, msg.sender, signerID);

    _transferProtocolFee(senderToken, msg.sender, senderAmount);

    emit Swap(
      nonce,
      block.timestamp,
      signerWallet,
      signerToken,
      signerID,
      protocolFee,
      msg.sender,
      senderToken,
      senderAmount
    );
  }

  function sellNFT(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderID,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override {
    _checkValidOrder(
      nonce,
      expiry,
      signerWallet,
      signerToken,
      signerAmount,
      senderToken,
      senderID,
      v,
      r,
      s
    );

    IERC721(senderToken).transferFrom(msg.sender, signerWallet, senderID);

    IERC20(signerToken).safeTransferFrom(
      signerWallet,
      msg.sender,
      signerAmount
    );

    _transferProtocolFee(signerToken, signerWallet, signerAmount);

    emit Swap(
      nonce,
      block.timestamp,
      signerWallet,
      signerToken,
      signerAmount,
      protocolFee,
      msg.sender,
      senderToken,
      senderID
    );
  }

  function swapNFTs(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerID,
    address senderToken,
    uint256 senderID,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override {
    _checkValidOrder(
      nonce,
      expiry,
      signerWallet,
      signerToken,
      signerID,
      senderToken,
      senderID,
      v,
      r,
      s
    );

    IERC721(senderToken).transferFrom(msg.sender, signerWallet, senderID);

    IERC721(signerToken).transferFrom(signerWallet, msg.sender, signerID);

    emit Swap(
      nonce,
      block.timestamp,
      signerWallet,
      signerToken,
      signerID,
      0,
      msg.sender,
      senderToken,
      senderID
    );
  }

  function setProtocolFee(uint256 _protocolFee) external onlyOwner {
    require(_protocolFee < FEE_DIVISOR, "INVALID_FEE");
    protocolFee = _protocolFee;
    emit SetProtocolFee(_protocolFee);
  }

  function setProtocolFeeLight(uint256 _protocolFeeLight) external onlyOwner {
    require(_protocolFeeLight < FEE_DIVISOR, "INVALID_FEE_LIGHT");
    protocolFeeLight = _protocolFeeLight;
    emit SetProtocolFeeLight(_protocolFeeLight);
  }

  function setProtocolFeeWallet(address _protocolFeeWallet) external onlyOwner {
    require(_protocolFeeWallet != address(0), "INVALID_FEE_WALLET");
    protocolFeeWallet = _protocolFeeWallet;
    emit SetProtocolFeeWallet(_protocolFeeWallet);
  }

  function setRebateScale(uint256 _rebateScale) external onlyOwner {
    require(_rebateScale <= MAX_SCALE, "SCALE_TOO_HIGH");
    rebateScale = _rebateScale;
    emit SetRebateScale(_rebateScale);
  }

  function setRebateMax(uint256 _rebateMax) external onlyOwner {
    require(_rebateMax <= MAX_PERCENTAGE, "MAX_TOO_HIGH");
    rebateMax = _rebateMax;
    emit SetRebateMax(_rebateMax);
  }

  function setStaking(address newstaking) external onlyOwner {
    require(newstaking != address(0), "INVALID_FEE_WALLET");
    staking = newstaking;
    emit SetStaking(newstaking);
  }

  function authorize(address signer) external override {
    require(signer != address(0), "SIGNER_INVALID");
    authorized[msg.sender] = signer;
    emit Authorize(signer, msg.sender);
  }

  function revoke() external override {
    address tmp = authorized[msg.sender];
    delete authorized[msg.sender];
    emit Revoke(tmp, msg.sender);
  }

  function cancel(uint256[] calldata nonces) external override {
    for (uint256 i = 0; i < nonces.length; i++) {
      uint256 nonce = nonces[i];
      if (_markNonceAsUsed(msg.sender, nonce)) {
        emit Cancel(nonce, msg.sender);
      }
    }
  }

  function check(
    address senderWallet,
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view returns (uint256, bytes32[] memory) {
    bytes32[] memory errors = new bytes32[](MAX_ERROR_COUNT);
    Order memory order;
    uint256 errCount;
    order.nonce = nonce;
    order.expiry = expiry;
    order.signerWallet = signerWallet;
    order.signerToken = signerToken;
    order.signerAmount = signerAmount;
    order.senderToken = senderToken;
    order.senderAmount = senderAmount;
    order.v = v;
    order.r = r;
    order.s = s;
    order.senderWallet = senderWallet;
    bytes32 hashed = _getOrderHash(
      order.nonce,
      order.expiry,
      order.signerWallet,
      order.signerToken,
      order.signerAmount,
      order.senderWallet,
      order.senderToken,
      order.senderAmount
    );
    address signatory = _getSignatory(hashed, order.v, order.r, order.s);

    if (signatory == address(0)) {
      errors[errCount] = "SIGNATURE_INVALID";
      errCount++;
    }

    if (order.expiry < block.timestamp) {
      errors[errCount] = "EXPIRY_PASSED";
      errCount++;
    }

    if (
      order.signerWallet != signatory &&
      authorized[order.signerWallet] != signatory
    ) {
      errors[errCount] = "UNAUTHORIZED";
      errCount++;
    } else {
      if (nonceUsed(signatory, order.nonce)) {
        errors[errCount] = "NONCE_ALREADY_USED";
        errCount++;
      }
    }

    uint256 signerBalance = IERC20(order.signerToken).balanceOf(
      order.signerWallet
    );

    uint256 signerAllowance = IERC20(order.signerToken).allowance(
      order.signerWallet,
      address(this)
    );

    uint256 feeAmount = (order.signerAmount * protocolFee) / FEE_DIVISOR;

    if (signerAllowance < order.signerAmount + feeAmount) {
      errors[errCount] = "SIGNER_ALLOWANCE_LOW";
      errCount++;
    }

    if (signerBalance < order.signerAmount + feeAmount) {
      errors[errCount] = "SIGNER_BALANCE_LOW";
      errCount++;
    }
    return (errCount, errors);
  }

  function calculateDiscount(uint256 stakingBalance, uint256 feeAmount)
    public
    view
    returns (uint256)
  {
    uint256 divisor = (uint256(10)**rebateScale) + stakingBalance;
    return (rebateMax * stakingBalance * feeAmount) / divisor / 100;
  }

  function calculateProtocolFee(address wallet, uint256 amount)
    public
    view
    override
    returns (uint256)
  {
    uint256 feeAmount = (amount * protocolFee) / FEE_DIVISOR;
    if (feeAmount > 0) {
      uint256 discountAmount = calculateDiscount(
        IERC20(staking).balanceOf(wallet),
        feeAmount
      );
      return feeAmount - discountAmount;
    }
    return feeAmount;
  }

  function nonceUsed(address signer, uint256 nonce)
    public
    view
    override
    returns (bool)
  {
    uint256 groupKey = nonce / 256;
    uint256 indexInGroup = nonce % 256;
    return (_nonceGroups[signer][groupKey] >> indexInGroup) & 1 == 1;
  }

  function getChainId() public view returns (uint256 id) {
    assembly {
      id := chainid()
    }
  }

  function _markNonceAsUsed(address signer, uint256 nonce)
    internal
    returns (bool)
  {
    uint256 groupKey = nonce / 256;
    uint256 indexInGroup = nonce % 256;
    uint256 group = _nonceGroups[signer][groupKey];

    if ((group >> indexInGroup) & 1 == 1) {
      return false;
    }

    _nonceGroups[signer][groupKey] = group | (uint256(1) << indexInGroup);

    return true;
  }

  function _checkValidOrder(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {
    require(DOMAIN_CHAIN_ID == getChainId(), "CHAIN_ID_CHANGED");

    require(expiry > block.timestamp, "EXPIRY_PASSED");

    bytes32 hashed = _getOrderHash(
      nonce,
      expiry,
      signerWallet,
      signerToken,
      signerAmount,
      msg.sender,
      senderToken,
      senderAmount
    );

    address signatory = _getSignatory(hashed, v, r, s);

    require(signatory != address(0), "SIGNATURE_INVALID");

    require(_markNonceAsUsed(signatory, nonce), "NONCE_ALREADY_USED");

    if (signerWallet != signatory) {
      require(authorized[signerWallet] == signatory, "UNAUTHORIZED");
    }
  }

  function _getOrderHash(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderWallet,
    address senderToken,
    uint256 senderAmount
  ) internal view returns (bytes32) {
    return
      keccak256(
        abi.encode(
          ORDER_TYPEHASH,
          nonce,
          expiry,
          signerWallet,
          signerToken,
          signerAmount,
          protocolFee,
          senderWallet,
          senderToken,
          senderAmount
        )
      );
  }

  function _getSignatory(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal view returns (address) {
    return
      ecrecover(
        keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hash)),
        v,
        r,
        s
      );
  }

  function _transferProtocolFee(
    address sourceToken,
    address sourceWallet,
    uint256 amount
  ) internal {
    uint256 feeAmount = (amount * protocolFee) / FEE_DIVISOR;
    if (feeAmount > 0) {
      uint256 discountAmount = calculateDiscount(
        IERC20(staking).balanceOf(msg.sender),
        feeAmount
      );
      if (discountAmount > 0) {
        IERC20(sourceToken).safeTransferFrom(
          sourceWallet,
          msg.sender,
          discountAmount
        );
        IERC20(sourceToken).safeTransferFrom(
          sourceWallet,
          protocolFeeWallet,
          feeAmount - discountAmount
        );
      } else {
        IERC20(sourceToken).safeTransferFrom(
          sourceWallet,
          protocolFeeWallet,
          feeAmount
        );
      }
    }
  }
}