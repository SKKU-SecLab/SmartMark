
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

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


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

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {

    return
      functionStaticCall(target, data, "Address: low-level static call failed");
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


library SafeERC20 {

  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
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
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, value)
    );
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(
        oldAllowance >= value,
        "SafeERC20: decreased allowance below zero"
      );
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(
        token,
        abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
      );
    }
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {


    bytes memory returndata = address(token).functionCall(
      data,
      "SafeERC20: low-level call failed"
    );
    if (returndata.length > 0) {
      require(
        abi.decode(returndata, (bool)),
        "SafeERC20: ERC20 operation did not succeed"
      );
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


interface IZNSHub {

  function addRegistrar(uint256 rootDomainId, address registrar) external;


  function isController(address controller) external returns (bool);


  function getRegistrarForDomain(uint256 domainId)
    external
    view
    returns (IRegistrar);


  function ownerOf(uint256 domainId) external view returns (address);


  function domainExists(uint256 domainId) external view returns (bool);


  function owner() external view returns (address);


  function registrarBeacon() external view returns (address);


  function domainTransferred(
    address from,
    address to,
    uint256 tokenId
  ) external;


  function domainCreated(
    uint256 id,
    string calldata name,
    uint256 nameHash,
    uint256 parent,
    address minter,
    address controller,
    string calldata metadataUri,
    uint256 royaltyAmount
  ) external;


  function metadataLockChanged(
    uint256 id,
    address locker,
    bool isLocked
  ) external;


  function metadataChanged(uint256 id, string calldata uri) external;


  function royaltiesAmountChanged(uint256 id, uint256 amount) external;


  function parentOf(uint256 id) external view returns (uint256);

}// MIT
pragma solidity ^0.8.4;


contract ZAuction is Initializable, OwnableUpgradeable {

  using ECDSA for bytes32;
  using SafeERC20 for IERC20;

  IERC20 public defaultPaymentToken;

  IRegistrar public registrar;

  struct Listing {
    uint256 price;
    address holder;
    IERC20 paymentToken;
  }

  mapping(uint256 => Listing) public priceInfo;
  mapping(address => mapping(uint256 => bool)) public consumed;
  mapping(uint256 => uint256) public topLevelDomainIdCache;
  mapping(uint256 => uint256) public topLevelDomainFee;

  event BidAccepted(
    uint256 bidNonce,
    address indexed bidder,
    address indexed seller,
    uint256 amount,
    address nftAddress,
    uint256 tokenId,
    uint256 expireBlock
  );

  event BidAcceptedV2(
    uint256 bidNonce,
    address indexed bidder,
    address indexed seller,
    uint256 amount,
    address nftAddress,
    uint256 tokenId,
    uint256 expireBlock,
    address paymentToken,
    uint256 topLevelDomainId
  );

  event DomainSold(
    address indexed buyer,
    address indexed seller,
    uint256 amount,
    address nftAddress,
    uint256 indexed tokenId
  );

  event DomainSoldV2(
    address indexed buyer,
    address indexed seller,
    uint256 amount,
    address nftAddress,
    uint256 indexed tokenId,
    address paymentToken,
    uint256 topLevelDomainId
  );

  event BuyNowPriceSet(uint256 indexed tokenId, uint256 amount);

  event BuyNowPriceSetV2(
    uint256 indexed tokenId,
    uint256 amount,
    address paymentToken
  );

  event BidCancelled(uint256 bidNonce, address indexed bidder);

  IZNSHub public hub;

  mapping(uint256 => IERC20) public networkPaymentToken;

  IERC20 public wildToken;

  bytes32 internal constant _ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  function initialize(IERC20 tokenAddress, IRegistrar registrarAddress)
    public
    initializer
  {

    __Ownable_init();
    defaultPaymentToken = tokenAddress;
    registrar = registrarAddress;
  }

  function getProxyAdmin() public view returns (address) {

    return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
  }

  function upgradeFromV2(address _defaultToken, address _wildToken) public {

    address proxyAdmin = getProxyAdmin();
    require(
      msg.sender == proxyAdmin,
      "zAuction: Only the Proxy Admin can call to upgrade this contract."
    );

    defaultPaymentToken = IERC20(_defaultToken);
    wildToken = IERC20(_wildToken);
  }

  function token() external view returns (IERC20) {

    return wildToken;
  }

  function acceptBid(
    bytes memory signature,
    uint256 bidNonce,
    address bidder,
    uint256 bid,
    uint256 domainTokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock
  ) external {

    require(startBlock <= block.number, "zAuction: auction hasn't started");
    require(expireBlock > block.number, "zAuction: auction expired");
    require(minbid <= bid, "zAuction: cannot accept bid below min");
    require(bidder != msg.sender, "zAuction: cannot sell to self");
    require(msg.sender == hub.ownerOf(domainTokenId), "Only Owner");

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(domainTokenId);

    bytes32 data = createBid(
      bidNonce,
      bid,
      address(domainRegistrar),
      domainTokenId,
      minbid,
      startBlock,
      expireBlock
    );

    require(
      bidder == recover(toEthSignedMessageHash(data), signature),
      "zAuction: recovered incorrect bidder"
    );
    require(!consumed[bidder][bidNonce], "zAuction: data already consumed");

    consumed[bidder][bidNonce] = true;

    uint256 topLevelDomainId = getTopLevelIdWithUpdate(domainTokenId);
    paymentTransfers(
      bidder,
      bid,
      msg.sender,
      topLevelDomainId,
      domainTokenId,
      wildToken
    );

    domainRegistrar.safeTransferFrom(msg.sender, bidder, domainTokenId);

    emit BidAccepted(
      bidNonce,
      bidder,
      msg.sender,
      bid,
      address(domainRegistrar),
      domainTokenId,
      expireBlock
    );
  }

  function acceptBidV2(
    bytes memory signature,
    uint256 bidNonce,
    address bidder,
    uint256 bid,
    uint256 domainTokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock,
    IERC20 bidToken
  ) external {

    require(startBlock <= block.number, "zAuction: auction hasn't started");
    require(expireBlock > block.number, "zAuction: auction expired");
    require(minbid <= bid, "zAuction: cannot accept bid below min");
    require(bidder != msg.sender, "zAuction: cannot sell to self");
    require(msg.sender == hub.ownerOf(domainTokenId), "Only Owner");

    IERC20 paymentToken = getPaymentTokenForDomain(domainTokenId);
    require(
      paymentToken == bidToken,
      "zAuction: Only bids made with the network's token can be accepted"
    );

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(domainTokenId);

    bytes32 data = createBidV2(
      bidNonce,
      bid,
      domainTokenId,
      minbid,
      startBlock,
      expireBlock,
      address(bidToken)
    );

    require(
      bidder == recover(toEthSignedMessageHash(data), signature),
      "zAuction: recovered incorrect bidder"
    );
    require(!consumed[bidder][bidNonce], "zAuction: data already consumed");

    consumed[bidder][bidNonce] = true;

    uint256 topLevelDomainId = getTopLevelIdWithUpdate(domainTokenId);
    paymentTransfers(
      bidder,
      bid,
      msg.sender,
      topLevelDomainId,
      domainTokenId,
      bidToken
    );

    domainRegistrar.safeTransferFrom(msg.sender, bidder, domainTokenId);

    emit BidAcceptedV2(
      bidNonce,
      bidder,
      msg.sender,
      bid,
      address(domainRegistrar),
      domainTokenId,
      expireBlock,
      address(bidToken),
      topLevelDomainId
    );
  }

  function setNetworkToken(uint256 domainNetworkId, IERC20 domainNetworkToken)
    external
    onlyOwner
  {

    require(
      networkPaymentToken[domainNetworkId] != domainNetworkToken,
      "zAuction: No state change"
    );
    networkPaymentToken[domainNetworkId] = domainNetworkToken;
  }

  function setWildToken(IERC20 token) external onlyOwner {

    require(token != wildToken, "zAuction: No state change");
    wildToken = token;
  }

  function setDefaultPaymentToken(IERC20 newDefaultToken) external onlyOwner {

    require(
      newDefaultToken != IERC20(address(0)),
      "zAuction: Cannot give a zero address for the default payment token"
    );
    require(
      newDefaultToken != defaultPaymentToken,
      "zAuction: No state change"
    );
    defaultPaymentToken = newDefaultToken;
  }

  function setBuyPrice(uint256 amount, uint256 domainTokenId) external {

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(domainTokenId);
    address owner = domainRegistrar.ownerOf(domainTokenId);

    require(msg.sender == owner, "zAuction: only owner can set price");

    require(
      priceInfo[domainTokenId].price != amount,
      "zAuction: listing already exists"
    );

    IERC20 paymentToken = getPaymentTokenForDomain(domainTokenId);

    priceInfo[domainTokenId] = Listing(amount, owner, paymentToken);
    emit BuyNowPriceSetV2(domainTokenId, amount, address(paymentToken));
  }

  function buyNow(uint256 amount, uint256 domainTokenId) external {

    require(priceInfo[domainTokenId].price != 0, "zAuction: item not for sale");
    require(
      amount == priceInfo[domainTokenId].price,
      "zAuction: wrong sale price"
    );

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(domainTokenId);
    address seller = domainRegistrar.ownerOf(domainTokenId);

    require(msg.sender != seller, "zAuction: cannot sell to self");
    require(
      priceInfo[domainTokenId].holder == seller,
      "zAuction: not listed for sale"
    );

    paymentTransfers(
      msg.sender,
      amount,
      seller,
      getTopLevelIdWithUpdate(domainTokenId),
      domainTokenId,
      wildToken
    );

    priceInfo[domainTokenId].price = 0;

    domainRegistrar.safeTransferFrom(seller, msg.sender, domainTokenId);

    emit DomainSold(
      msg.sender,
      seller,
      amount,
      address(domainRegistrar),
      domainTokenId
    );
  }

  function buyNowV2(uint256 amount, uint256 domainTokenId) external {

    require(priceInfo[domainTokenId].price != 0, "zAuction: item not for sale");
    require(
      amount == priceInfo[domainTokenId].price,
      "zAuction: wrong sale price"
    );

    IERC20 listingPaymentToken = priceInfo[domainTokenId].paymentToken;
    IERC20 domainPaymentToken = getPaymentTokenForDomain(domainTokenId);
    require(
      domainPaymentToken == listingPaymentToken,
      "zAuction: Listing not set in correct domain token"
    );

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(domainTokenId);
    address seller = domainRegistrar.ownerOf(domainTokenId);

    require(msg.sender != seller, "zAuction: cannot sell to self");
    require(
      priceInfo[domainTokenId].holder == seller,
      "zAuction: not listed for sale"
    );

    paymentTransfers(
      msg.sender,
      amount,
      seller,
      getTopLevelIdWithUpdate(domainTokenId),
      domainTokenId,
      listingPaymentToken
    );

    uint256 topLevelId = getTopLevelIdWithUpdate(domainTokenId);

    priceInfo[domainTokenId].price = 0;

    domainRegistrar.safeTransferFrom(seller, msg.sender, domainTokenId);

    emit DomainSoldV2(
      msg.sender,
      seller,
      amount,
      address(domainRegistrar),
      domainTokenId,
      address(listingPaymentToken),
      topLevelId
    );
  }

  function cancelBid(address account, uint256 bidNonce) external {

    require(
      msg.sender == account,
      "zAuction: Cannot cancel someone else's bid"
    );
    require(
      !consumed[account][bidNonce],
      "zAuction: Cannot cancel an already consumed bid"
    );

    consumed[account][bidNonce] = true;

    emit BidCancelled(bidNonce, account);
  }

  function setZNSHub(IZNSHub hubAddress) public onlyOwner {

    require(
      address(hubAddress) != address(0),
      "zAuction: Cannot set the zNSHub to an empty address"
    );
    require(hubAddress != hub, "zAuction: Cannot set to the same hub");
    hub = hubAddress;
  }

  function setTopLevelDomainFee(uint256 id, uint256 amount) external {

    require(
      msg.sender == hub.ownerOf(id),
      "zAuction: Cannot set fee on unowned domain"
    );
    require(amount <= 1000000, "zAuction: Cannot set a fee higher than 10%");
    require(amount != topLevelDomainFee[id], "zAuction: Amount is already set");
    topLevelDomainFee[id] = amount;
  }

  function getPaymentTokenForDomain(uint256 domainTokenId)
    public
    view
    returns (IERC20)
  {

    require(domainTokenId != 0, "zAuction: Must provide a valid domainId");

    uint256 topLevelDomainId = getTopLevelId(domainTokenId);
    IERC20 paymentToken = networkPaymentToken[topLevelDomainId];

    if (paymentToken == IERC20(address(0))) {
      return defaultPaymentToken;
    } else {
      return paymentToken;
    }
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
    uint256 bidNonce,
    uint256 bid,
    address nftAddress,
    uint256 tokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock
  ) public view returns (bytes32 data) {

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(tokenId);
    return
      keccak256(
        abi.encode(
          bidNonce,
          address(this),
          block.chainid,
          bid,
          address(domainRegistrar),
          tokenId,
          minbid,
          startBlock,
          expireBlock
        )
      );
  }

  function createBidV2(
    uint256 bidNonce,
    uint256 bid,
    uint256 tokenId,
    uint256 minbid,
    uint256 startBlock,
    uint256 expireBlock,
    address bidToken
  ) public view returns (bytes32 data) {

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(tokenId);
    return
      keccak256(
        abi.encode(
          bidNonce,
          address(this),
          block.chainid,
          bid,
          address(domainRegistrar),
          tokenId,
          minbid,
          startBlock,
          expireBlock,
          bidToken
        )
      );
  }

  function getTopLevelId(uint256 domainTokenId) public view returns (uint256) {

    uint256 topLevelDomainId = topLevelDomainIdCache[domainTokenId];
    if (topLevelDomainId != 0) {
      return topLevelDomainId;
    }

    uint256 parentId = hub.parentOf(domainTokenId);
    uint256 holder = domainTokenId;
    while (parentId != 0) {
      holder = parentId;
      parentId = hub.parentOf(parentId);
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
    uint256 tokenId,
    IERC20 paymentToken
  ) internal {

    address topLevelOwner = hub.ownerOf(topLevelId);
    uint256 topLevelFee = calculateTopLevelDomainFee(topLevelId, bid);
    uint256 minterRoyalty = calculateMinterRoyalty(tokenId, bid);

    uint256 bidActual = bid - minterRoyalty - topLevelFee;

    SafeERC20.safeTransferFrom(paymentToken, bidder, owner, bidActual);

    IRegistrar domainRegistrar = hub.getRegistrarForDomain(tokenId);

    SafeERC20.safeTransferFrom(
      paymentToken,
      bidder,
      domainRegistrar.minterOf(tokenId),
      minterRoyalty
    );

    SafeERC20.safeTransferFrom(
      paymentToken,
      bidder,
      topLevelOwner,
      topLevelFee
    );
  }

  function getTopLevelIdWithUpdate(uint256 tokenId) private returns (uint256) {

    uint256 topLevelId = topLevelDomainIdCache[tokenId];
    if (topLevelId == 0) {
      topLevelId = getTopLevelId(tokenId);
      topLevelDomainIdCache[tokenId] = topLevelId;
    }
    return topLevelId;
  }
}