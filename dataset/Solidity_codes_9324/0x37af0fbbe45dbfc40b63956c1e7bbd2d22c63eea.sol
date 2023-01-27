
pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.4;


interface IRegistrar is IERC721 {

  function isDomainMetadataLocked(uint256 id) external view returns (bool);


  function domainRoyaltyAmount(uint256 id) external view returns (uint256);


  function setDomainRoyaltyAmount(uint256 id, uint256 amount) external;


  function parentOf(uint256 id) external view returns (uint256);


  function minterOf(uint256 id) external view returns (address);

}// MIT
pragma solidity ^0.8.4;


contract ZAuction is Initializable, OwnableUpgradeable {

  using ECDSA for bytes32;

  IERC20 public token;
  IRegistrar public registrar;

  address legacyZAuction;

  struct Listing {
    uint256 price;
    address holder;
  }

  mapping(uint256 => Listing) public priceInfo;
  mapping(address => mapping(uint256 => bool)) public consumed;
  mapping(uint256 => uint256) public topLevelDomainIdCache;
  mapping(uint256 => uint256) public topLevelDomainFee;

  event BidAccepted(
    uint256 auctionId,
    address indexed bidder,
    address indexed seller,
    uint256 amount,
    address nftAddress,
    uint256 tokenId,
    uint256 expireBlock
  );

  event DomainSold(
    address indexed buyer,
    address indexed seller,
    uint256 amount,
    address nftAddress,
    uint256 indexed tokenId
  );

  event BidCancelled(uint256 auctionId, address indexed bidder);

  function getTopLevelId(uint256 tokenId) private returns (uint256) {

    uint256 topLevelId = topLevelDomainIdCache[tokenId];
    if (topLevelId == 0) {
      topLevelId = topLevelDomainIdOf(tokenId);
      topLevelDomainIdCache[tokenId] = topLevelId;
    }
    return topLevelId;
  }

  function initialize(
    IERC20 tokenAddress,
    IRegistrar registrarAddress,
    address legacyZAuctionAddress
  ) public initializer {

    __Ownable_init();
    token = tokenAddress;
    registrar = registrarAddress;
    legacyZAuction = legacyZAuctionAddress;
  }

  function acceptBid(
    bytes memory signature,
    uint256 auctionId,
    address bidder,
    uint256 bid,
    uint256 tokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock
  ) external {

    require(startBlock <= block.number, "zAuction: auction hasn't started");
    require(expireBlock > block.number, "zAuction: auction expired");
    require(minbid <= bid, "zAuction: cannot accept bid below min");
    require(bidder != msg.sender, "zAuction: cannot sell to self");

    bytes32 data = createBid(
      auctionId,
      bid,
      address(registrar),
      tokenId,
      minbid,
      startBlock,
      expireBlock
    );

    if (bidder != recover(toEthSignedMessageHash(data), signature)) {
      bytes32 legacyData = createLegacyBid(
        auctionId,
        bid,
        address(registrar),
        tokenId,
        minbid,
        startBlock,
        expireBlock
      );
      require(
        bidder == recover(toEthSignedMessageHash(legacyData), signature),
        "zAuction: recovered incorrect bidder"
      );
    }
    require(!consumed[bidder][auctionId], "zAuction: data already consumed");

    consumed[bidder][auctionId] = true;

    paymentTransfers(bidder, bid, msg.sender, getTopLevelId(tokenId), tokenId);

    registrar.safeTransferFrom(msg.sender, bidder, tokenId);

    emit BidAccepted(
      auctionId,
      bidder,
      msg.sender,
      bid,
      address(registrar),
      tokenId,
      expireBlock
    );
  }

  function setBuyPrice(uint256 amount, uint256 tokenId) external {

    address owner = registrar.ownerOf(tokenId);
    require(msg.sender == owner, "zAuction: only owner can set price");
    require(
      priceInfo[tokenId].price != amount,
      "zAuction: listing already exists"
    );
    priceInfo[tokenId] = Listing(amount, owner);
  }

  function buyNow(uint256 amount, uint256 tokenId) external {

    require(amount == priceInfo[tokenId].price, "zAuction: wrong sale price");
    address seller = registrar.ownerOf(tokenId);
    require(msg.sender != seller, "zAuction: cannot sell to self");
    require(
      priceInfo[tokenId].holder == seller,
      "zAuction: not listed for sale"
    );
    require(priceInfo[tokenId].price != 0, "zAuction: item not for sale");

    paymentTransfers(
      msg.sender,
      amount,
      seller,
      getTopLevelId(tokenId),
      tokenId
    );

    priceInfo[tokenId].price = 0;

    registrar.safeTransferFrom(seller, msg.sender, tokenId);

    emit DomainSold(msg.sender, seller, amount, address(registrar), tokenId);
  }

  function cancelBid(address account, uint256 auctionId) external {

    require(
      msg.sender == account,
      "zAuction: Cannot cancel someone else's bid"
    );
    require(
      !consumed[account][auctionId],
      "zAuction: Cannot cancel an already consumed bid"
    );

    consumed[account][auctionId] = true;

    emit BidCancelled(auctionId, account);
  }

  function setTopLevelDomainFee(uint256 id, uint256 amount) public {

    require(
      msg.sender == registrar.ownerOf(id),
      "zAuction: Cannot set fee on unowned domain"
    );
    require(amount <= 1000000, "zAuction: Cannot set a fee higher than 10%");
    require(amount != topLevelDomainFee[id], "zAuction: Amount is already set");
    topLevelDomainFee[id] = amount;
  }

  function calculateTopLevelDomainFee(uint256 topLevelId, uint256 bid)
    public
    view
    returns (uint256)
  {

    require(topLevelId > 0, "zAuction: must provide a valid id");
    require(bid > 0, "zAuction: Cannot calculate domain fee on an empty bid");

    uint256 fee = topLevelDomainFee[topLevelId];
    if (fee == 0) return 0;

    uint256 calculatedFee = (bid * fee * 10**13) / (100 * 10**18);

    return calculatedFee;
  }

  function calculateMinterRoyalty(uint256 id, uint256 bid)
    public
    pure
    returns (uint256)
  {

    require(id > 0, "zAuction: must provide a valid id");
    uint256 domainRoyalty = 1000000;
    uint256 royalty = (bid * domainRoyalty * 10**13) / (100 * 10**18);

    return royalty;
  }

  function createBid(
    uint256 auctionId,
    uint256 bid,
    address nftAddress,
    uint256 tokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock
  ) public view returns (bytes32 data) {

    data = keccak256(
      abi.encode(
        auctionId,
        address(this),
        block.chainid,
        bid,
        nftAddress,
        tokenId,
        minbid,
        startBlock,
        expireBlock
      )
    );
    return data;
  }

  function createLegacyBid(
    uint256 auctionId,
    uint256 bid,
    address nftAddress,
    uint256 tokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock
  ) public view returns (bytes32 data) {

    data = keccak256(
      abi.encode(
        auctionId,
        legacyZAuction,
        block.chainid,
        bid,
        nftAddress,
        tokenId,
        minbid,
        startBlock,
        expireBlock
      )
    );
    return data;
  }

  function topLevelDomainIdOf(uint256 id) public view returns (uint256) {

    uint256 parentId = registrar.parentOf(id);
    uint256 holder = id;
    while (parentId != 0) {
      holder = parentId; // Hold on to previous parent
      parentId = registrar.parentOf(parentId);
    }
    return holder;
  }

  function recover(bytes32 hash, bytes memory signature)
    public
    pure
    returns (address)
  {

    return hash.recover(signature);
  }

  function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {

    return hash.toEthSignedMessageHash();
  }

  function paymentTransfers(
    address bidder,
    uint256 bid,
    address owner,
    uint256 topLevelId,
    uint256 tokenId
  ) internal {

    address topLevelOwner = registrar.ownerOf(topLevelId);
    uint256 topLevelFee = calculateTopLevelDomainFee(topLevelId, bid);
    uint256 minterRoyalty = calculateMinterRoyalty(tokenId, bid);

    uint256 bidActual = bid - minterRoyalty - topLevelFee;

    SafeERC20.safeTransferFrom(token, bidder, owner, bidActual);

    SafeERC20.safeTransferFrom(
      token,
      bidder,
      registrar.minterOf(tokenId),
      minterRoyalty
    );

    SafeERC20.safeTransferFrom(token, bidder, topLevelOwner, topLevelFee);
  }
}