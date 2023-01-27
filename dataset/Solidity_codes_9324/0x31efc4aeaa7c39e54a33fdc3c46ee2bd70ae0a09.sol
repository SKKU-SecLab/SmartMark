
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
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
}// UNLICENSED
pragma solidity 0.8.4;

abstract contract ProposedOwnable {
  address private _owner;

  address private _proposed;
  uint256 private _proposedOwnershipTimestamp;

  bool private _routerOwnershipRenounced;
  uint256 private _routerOwnershipTimestamp;

  bool private _assetOwnershipRenounced;
  uint256 private _assetOwnershipTimestamp;

  uint256 private constant _delay = 7 days;

  event RouterOwnershipRenunciationProposed(uint256 timestamp);

  event RouterOwnershipRenounced(bool renounced);

  event AssetOwnershipRenunciationProposed(uint256 timestamp);

  event AssetOwnershipRenounced(bool renounced);

  event OwnershipProposed(address indexed proposedOwner);

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _setOwner(msg.sender);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  function proposed() public view virtual returns (address) {
    return _proposed;
  }

  function proposedTimestamp() public view virtual returns (uint256) {
    return _proposedOwnershipTimestamp;
  }

  function routerOwnershipTimestamp() public view virtual returns (uint256) {
    return _routerOwnershipTimestamp;
  }

  function assetOwnershipTimestamp() public view virtual returns (uint256) {
    return _assetOwnershipTimestamp;
  }

  function delay() public view virtual returns (uint256) {
    return _delay;
  }

  modifier onlyOwner() {
      require(_owner == msg.sender, "#OO:029");
      _;
  }

  modifier onlyProposed() {
      require(_proposed == msg.sender, "#OP:035");
      _;
  }

  function isRouterOwnershipRenounced() public view returns (bool) {
    return _owner == address(0) || _routerOwnershipRenounced;
  }

  function proposeRouterOwnershipRenunciation() public virtual onlyOwner {
    require(!_routerOwnershipRenounced, "#PROR:038");

    _setRouterOwnershipTimestamp();
  }

  function renounceRouterOwnership() public virtual onlyOwner {
    require(!_routerOwnershipRenounced, "#RRO:038");

    require(_routerOwnershipTimestamp > 0, "#RRO:037");

    require((block.timestamp - _routerOwnershipTimestamp) > _delay, "#RRO:030");

    _setRouterOwnership(true);
  }

  function isAssetOwnershipRenounced() public view returns (bool) {
    return _owner == address(0) || _assetOwnershipRenounced;
  }

  function proposeAssetOwnershipRenunciation() public virtual onlyOwner {
    require(!_assetOwnershipRenounced, "#PAOR:038");

    _setAssetOwnershipTimestamp();
  }

  function renounceAssetOwnership() public virtual onlyOwner {
    require(!_assetOwnershipRenounced, "#RAO:038");

    require(_assetOwnershipTimestamp > 0, "#RAO:037");

    require((block.timestamp - _assetOwnershipTimestamp) > _delay, "#RAO:030");

    _setAssetOwnership(true);
  }

  function renounced() public view returns (bool) {
    return _owner == address(0);
  }

  function proposeNewOwner(address newlyProposed) public virtual onlyOwner {
    require(_proposed != newlyProposed || newlyProposed == address(0), "#PNO:036");

    require(_owner != newlyProposed, "#PNO:038");

    _setProposed(newlyProposed);
  }

  function renounceOwnership() public virtual onlyOwner {
    require(_proposedOwnershipTimestamp > 0, "#RO:037");

    require((block.timestamp - _proposedOwnershipTimestamp) > _delay, "#RO:030");

    require(_proposed == address(0), "#RO:036");

    _setOwner(_proposed);
  }

  function acceptProposedOwner() public virtual onlyProposed {
    require(_owner != _proposed, "#APO:038");


    require((block.timestamp - _proposedOwnershipTimestamp) > _delay, "#APO:030");

    _setOwner(_proposed);
  }


  function _setRouterOwnershipTimestamp() private {
    _routerOwnershipTimestamp = block.timestamp;
    emit RouterOwnershipRenunciationProposed(_routerOwnershipTimestamp);
  }

  function _setRouterOwnership(bool value) private {
    _routerOwnershipRenounced = value;
    _routerOwnershipTimestamp = 0;
    emit RouterOwnershipRenounced(value);
  }

  function _setAssetOwnershipTimestamp() private {
    _assetOwnershipTimestamp = block.timestamp;
    emit AssetOwnershipRenunciationProposed(_assetOwnershipTimestamp);
  }

  function _setAssetOwnership(bool value) private {
    _assetOwnershipRenounced = value;
    _assetOwnershipTimestamp = 0;
    emit AssetOwnershipRenounced(value);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    _proposedOwnershipTimestamp = 0;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  function _setProposed(address newlyProposed) private {
    _proposedOwnershipTimestamp = block.timestamp;
    _proposed = newlyProposed;
    emit OwnershipProposed(_proposed);
  }
}// UNLICENSED
pragma solidity 0.8.4;

interface IFulfillInterpreter {


  event Executed(
    bytes32 indexed transactionId,
    address payable callTo,
    address assetId,
    address payable fallbackAddress,
    uint256 amount,
    bytes callData,
    bytes returnData,
    bool success,
    bool isContract
  );

  function getTransactionManager() external returns (address);


  function execute(
    bytes32 transactionId,
    address payable callTo,
    address assetId,
    address payable fallbackAddress,
    uint256 amount,
    bytes calldata callData
  ) external payable returns (bool success, bool isContract, bytes memory returnData);

}// UNLICENSED
pragma solidity 0.8.4;

interface ITransactionManager {


  struct InvariantTransactionData {
    address receivingChainTxManagerAddress;
    address user;
    address router;
    address initiator; // msg.sender of sending side
    address sendingAssetId;
    address receivingAssetId;
    address sendingChainFallback; // funds sent here on cancel
    address receivingAddress;
    address callTo;
    uint256 sendingChainId;
    uint256 receivingChainId;
    bytes32 callDataHash; // hashed to prevent free option
    bytes32 transactionId;
  }

  struct VariantTransactionData {
    uint256 amount;
    uint256 expiry;
    uint256 preparedBlockNumber;
  }

  struct TransactionData {
    address receivingChainTxManagerAddress;
    address user;
    address router;
    address initiator; // msg.sender of sending side
    address sendingAssetId;
    address receivingAssetId;
    address sendingChainFallback;
    address receivingAddress;
    address callTo;
    bytes32 callDataHash;
    bytes32 transactionId;
    uint256 sendingChainId;
    uint256 receivingChainId;
    uint256 amount;
    uint256 expiry;
    uint256 preparedBlockNumber; // Needed for removal of active blocks on fulfill/cancel
  }

  struct SignedFulfillData {
    bytes32 transactionId;
    uint256 relayerFee;
    string functionIdentifier; // "fulfill" or "cancel"
    uint256 receivingChainId; // For domain separation
    address receivingChainTxManagerAddress; // For domain separation
  }

  struct SignedCancelData {
    bytes32 transactionId;
    string functionIdentifier;
    uint256 receivingChainId;
    address receivingChainTxManagerAddress; // For domain separation
  }

  struct PrepareArgs {
    InvariantTransactionData invariantData;
    uint256 amount;
    uint256 expiry;
    bytes encryptedCallData;
    bytes encodedBid;
    bytes bidSignature;
    bytes encodedMeta;
  }

  struct FulfillArgs {
    TransactionData txData;
    uint256 relayerFee;
    bytes signature;
    bytes callData;
    bytes encodedMeta;
  }

  struct CancelArgs {
    TransactionData txData;
    bytes signature;
    bytes encodedMeta;
  }

  event RouterAdded(address indexed addedRouter, address indexed caller);

  event RouterRemoved(address indexed removedRouter, address indexed caller);

  event AssetAdded(address indexed addedAssetId, address indexed caller);

  event AssetRemoved(address indexed removedAssetId, address indexed caller);

  event LiquidityAdded(address indexed router, address indexed assetId, uint256 amount, address caller);

  event LiquidityRemoved(address indexed router, address indexed assetId, uint256 amount, address recipient);

  event TransactionPrepared(
    address indexed user,
    address indexed router,
    bytes32 indexed transactionId,
    TransactionData txData,
    address caller,
    PrepareArgs args
  );

  event TransactionFulfilled(
    address indexed user,
    address indexed router,
    bytes32 indexed transactionId,
    FulfillArgs args,
    bool success,
    bool isContract,
    bytes returnData,
    address caller
  );

  event TransactionCancelled(
    address indexed user,
    address indexed router,
    bytes32 indexed transactionId,
    CancelArgs args,
    address caller
  );

  function getChainId() external view returns (uint256);


  function getStoredChainId() external view returns (uint256);


  function addRouter(address router) external;


  function removeRouter(address router) external;


  function addAssetId(address assetId) external;


  function removeAssetId(address assetId) external;


  function addLiquidityFor(uint256 amount, address assetId, address router) external payable;


  function addLiquidity(uint256 amount, address assetId) external payable;


  function removeLiquidity(
    uint256 amount,
    address assetId,
    address payable recipient
  ) external;


  function prepare(
    PrepareArgs calldata args
  ) external payable returns (TransactionData memory);


  function fulfill(
    FulfillArgs calldata args
  ) external returns (TransactionData memory);


  function cancel(CancelArgs calldata args) external returns (TransactionData memory);

}// UNLICENSED
pragma solidity 0.8.4;



library LibAsset {

  address constant NATIVE_ASSETID = address(0);

  function isNativeAsset(address assetId) internal pure returns (bool) {

    return assetId == NATIVE_ASSETID;
  }

  function getOwnBalance(address assetId) internal view returns (uint256) {

    return
      isNativeAsset(assetId)
        ? address(this).balance
        : IERC20(assetId).balanceOf(address(this));
  }

  function transferNativeAsset(address payable recipient, uint256 amount)
      internal
  {

    Address.sendValue(recipient, amount);
  }

  function transferERC20(
      address assetId,
      address recipient,
      uint256 amount
  ) internal {

    SafeERC20.safeTransfer(IERC20(assetId), recipient, amount);
  }

  function transferFromERC20(
    address assetId,
    address from,
    address to,
    uint256 amount
  ) internal {

    SafeERC20.safeTransferFrom(IERC20(assetId), from, to, amount);
  }

  function increaseERC20Allowance(
    address assetId,
    address spender,
    uint256 amount
  ) internal {

    require(!isNativeAsset(assetId), "#IA:034");
    SafeERC20.safeIncreaseAllowance(IERC20(assetId), spender, amount);
  }

  function decreaseERC20Allowance(
    address assetId,
    address spender,
    uint256 amount
  ) internal {

    require(!isNativeAsset(assetId), "#DA:034");
    SafeERC20.safeDecreaseAllowance(IERC20(assetId), spender, amount);
  }

  function transferAsset(
      address assetId,
      address payable recipient,
      uint256 amount
  ) internal {

    isNativeAsset(assetId)
      ? transferNativeAsset(recipient, amount)
      : transferERC20(assetId, recipient, amount);
  }
}// UNLICENSED
pragma solidity 0.8.4;


contract FulfillInterpreter is ReentrancyGuard, IFulfillInterpreter {

  address private immutable _transactionManager;

  constructor(address transactionManager) {
    _transactionManager = transactionManager;
  }

  modifier onlyTransactionManager {

    require(msg.sender == _transactionManager, "#OTM:027");
    _;
  }

  function getTransactionManager() override external view returns (address) {

    return _transactionManager;
  }

  function execute(
    bytes32 transactionId,
    address payable callTo,
    address assetId,
    address payable fallbackAddress,
    uint256 amount,
    bytes calldata callData
  ) override external payable onlyTransactionManager returns (bool, bool, bytes memory) {

    bool isNative = LibAsset.isNativeAsset(assetId);
    if (!isNative) {
      LibAsset.increaseERC20Allowance(assetId, callTo, amount);
    }

    bool success;
    bytes memory returnData;
    bool isContract = Address.isContract(callTo);
    if (isContract) {
      (success, returnData) = callTo.call{value: isNative ? amount : 0}(callData);
    }

    if (!success) {
      LibAsset.transferAsset(assetId, fallbackAddress, amount);
      if (!isNative) {
        LibAsset.decreaseERC20Allowance(assetId, callTo, amount);
      }
    }

    emit Executed(
      transactionId,
      callTo,
      assetId,
      fallbackAddress,
      amount,
      callData,
      returnData,
      success,
      isContract
    );
    return (success, isContract, returnData);
  }
}// UNLICENSED
pragma solidity 0.8.4;



contract TransactionManager is ReentrancyGuard, ProposedOwnable, ITransactionManager {

  mapping(address => mapping(address => uint256)) public routerBalances;

  mapping(address => bool) public approvedRouters;

  mapping(address => bool) public approvedAssets;

  mapping(bytes32 => bytes32) public variantTransactionData;

  uint256 private immutable chainId;

  uint256 public constant MIN_TIMEOUT = 1 days; // 24 hours

  uint256 public constant MAX_TIMEOUT = 30 days; // 720 hours

  IFulfillInterpreter public immutable interpreter;

  constructor(uint256 _chainId) {
    chainId = _chainId;
    interpreter = new FulfillInterpreter(address(this));
  }

  function getChainId() public view override returns (uint256 _chainId) {

    uint256 chain = chainId;
    if (chain == 0) {
      chain = block.chainid;
    }
    return chain;
  }

  function getStoredChainId() external view override returns (uint256) {

    return chainId;
  }

  function addRouter(address router) external override onlyOwner {

    require(router != address(0), "#AR:001");

    require(approvedRouters[router] == false, "#AR:032");

    approvedRouters[router] = true;

    emit RouterAdded(router, msg.sender);
  }

  function removeRouter(address router) external override onlyOwner {

    require(router != address(0), "#RR:001");

    require(approvedRouters[router] == true, "#RR:033");

    approvedRouters[router] = false;

    emit RouterRemoved(router, msg.sender);
  }

  function addAssetId(address assetId) external override onlyOwner {

    require(approvedAssets[assetId] == false, "#AA:032");

    approvedAssets[assetId] = true;

    emit AssetAdded(assetId, msg.sender);
  }

  function removeAssetId(address assetId) external override onlyOwner {

    require(approvedAssets[assetId] == true, "#RA:033");

    approvedAssets[assetId] = false;

    emit AssetRemoved(assetId, msg.sender);
  }

  function addLiquidityFor(uint256 amount, address assetId, address router) external payable override nonReentrant {

    _addLiquidityForRouter(amount, assetId, router);
  }

  function addLiquidity(uint256 amount, address assetId) external payable override nonReentrant {

    _addLiquidityForRouter(amount, assetId, msg.sender);
  }

  function removeLiquidity(
    uint256 amount,
    address assetId,
    address payable recipient
  ) external override nonReentrant {

    require(recipient != address(0), "#RL:007");

    require(amount > 0, "#RL:002");

    uint256 routerBalance = routerBalances[msg.sender][assetId];
    require(routerBalance >= amount, "#RL:008");

    unchecked {
      routerBalances[msg.sender][assetId] = routerBalance - amount;
    }

    LibAsset.transferAsset(assetId, recipient, amount);

    emit LiquidityRemoved(msg.sender, assetId, amount, recipient);
  }

  function prepare(
    PrepareArgs calldata args
  ) external payable override nonReentrant returns (TransactionData memory) {

    require(args.invariantData.user != address(0), "#P:009");

    require(args.invariantData.router != address(0), "#P:001");

    require(isRouterOwnershipRenounced() || approvedRouters[args.invariantData.router], "#P:003");

    require(args.invariantData.sendingChainFallback != address(0), "#P:010");

    require(args.invariantData.receivingAddress != address(0), "#P:026");

    require(args.invariantData.sendingChainId != args.invariantData.receivingChainId, "#P:011");

    uint256 _chainId = getChainId();
    require(args.invariantData.sendingChainId == _chainId || args.invariantData.receivingChainId == _chainId, "#P:012");

    { // Expiry scope
      uint256 buffer = args.expiry - block.timestamp;
      require(buffer >= MIN_TIMEOUT, "#P:013");

      require(buffer <= MAX_TIMEOUT, "#P:014");
    }

    bytes32 digest = keccak256(abi.encode(args.invariantData));
    require(variantTransactionData[digest] == bytes32(0), "#P:015");


    uint256 amount = args.amount;

    if (args.invariantData.sendingChainId == _chainId) {
      require(msg.sender == args.invariantData.initiator, "#P:039");

      require(args.amount > 0, "#P:002");

      require(isAssetOwnershipRenounced() || approvedAssets[args.invariantData.sendingAssetId], "#P:004");


      amount = transferAssetToContract(
        args.invariantData.sendingAssetId,
        args.amount
      );

      variantTransactionData[digest] = hashVariantTransactionData(
        amount,
        args.expiry,
        block.number
      );
    } else {

      require(args.invariantData.callTo == address(0) || Address.isContract(args.invariantData.callTo), "#P:031");

      require(isAssetOwnershipRenounced() || approvedAssets[args.invariantData.receivingAssetId], "#P:004");

      require(msg.sender == args.invariantData.router, "#P:016");

      require(msg.value == 0, "#P:017");

      uint256 balance = routerBalances[args.invariantData.router][args.invariantData.receivingAssetId];
      require(balance >= amount, "#P:018");

      variantTransactionData[digest] = hashVariantTransactionData(
        amount,
        args.expiry,
        block.number
      );

      unchecked {
        routerBalances[args.invariantData.router][args.invariantData.receivingAssetId] = balance - amount;
      }
    }

    TransactionData memory txData = TransactionData({
      receivingChainTxManagerAddress: args.invariantData.receivingChainTxManagerAddress,
      user: args.invariantData.user,
      router: args.invariantData.router,
      initiator: args.invariantData.initiator,
      sendingAssetId: args.invariantData.sendingAssetId,
      receivingAssetId: args.invariantData.receivingAssetId,
      sendingChainFallback: args.invariantData.sendingChainFallback,
      callTo: args.invariantData.callTo,
      receivingAddress: args.invariantData.receivingAddress,
      callDataHash: args.invariantData.callDataHash,
      transactionId: args.invariantData.transactionId,
      sendingChainId: args.invariantData.sendingChainId,
      receivingChainId: args.invariantData.receivingChainId,
      amount: amount,
      expiry: args.expiry,
      preparedBlockNumber: block.number
    });

    emit TransactionPrepared(
      txData.user,
      txData.router,
      txData.transactionId,
      txData,
      msg.sender,
      args
    );

    return txData;
  }



  function fulfill(
    FulfillArgs calldata args
  ) external override nonReentrant returns (TransactionData memory) {


    { // scope: validation and effects
      bytes32 digest = hashInvariantTransactionData(args.txData);

      require(variantTransactionData[digest] == hashVariantTransactionData(
        args.txData.amount,
        args.txData.expiry,
        args.txData.preparedBlockNumber
      ), "#F:019");

      require(args.txData.expiry >= block.timestamp, "#F:020");

      require(args.txData.preparedBlockNumber > 0, "#F:021");

      require(keccak256(args.callData) == args.txData.callDataHash, "#F:024");

      variantTransactionData[digest] = hashVariantTransactionData(
        args.txData.amount,
        args.txData.expiry,
        0
      );
    }

    bool success;
    bool isContract;
    bytes memory returnData;

    uint256 _chainId = getChainId();

    if (args.txData.sendingChainId == _chainId) {

      require(msg.sender == args.txData.router, "#F:016");

      require(
        recoverFulfillSignature(
          args.txData.transactionId,
          args.relayerFee,
          args.txData.receivingChainId,
          args.txData.receivingChainTxManagerAddress,
          args.signature
        ) == args.txData.user, "#F:022"
      );

      routerBalances[args.txData.router][args.txData.sendingAssetId] += args.txData.amount;

    } else {
      require(
        recoverFulfillSignature(
          args.txData.transactionId,
          args.relayerFee,
          _chainId,
          address(this),
          args.signature
        ) == args.txData.user, "#F:022"
      );

      require(args.relayerFee <= args.txData.amount, "#F:023");

      (success, isContract, returnData) = _receivingChainFulfill(
        args.txData,
        args.relayerFee,
        args.callData
      );
    }

    emit TransactionFulfilled(
      args.txData.user,
      args.txData.router,
      args.txData.transactionId,
      args,
      success,
      isContract,
      returnData,
      msg.sender
    );

    return args.txData;
  }

  function cancel(CancelArgs calldata args)
    external
    override
    nonReentrant
    returns (TransactionData memory)
  {


    bytes32 digest = hashInvariantTransactionData(args.txData);

    require(variantTransactionData[digest] == hashVariantTransactionData(args.txData.amount, args.txData.expiry, args.txData.preparedBlockNumber), "#C:019");

    require(args.txData.preparedBlockNumber > 0, "#C:021");

    variantTransactionData[digest] = hashVariantTransactionData(args.txData.amount, args.txData.expiry, 0);

    uint256 _chainId = getChainId();

    if (args.txData.sendingChainId == _chainId) {
      if (args.txData.expiry >= block.timestamp) {
        require(msg.sender == args.txData.router, "#C:025");
      }

      LibAsset.transferAsset(
        args.txData.sendingAssetId,
        payable(args.txData.sendingChainFallback),
        args.txData.amount
      );

    } else {
      if (args.txData.expiry >= block.timestamp) {
        require(msg.sender == args.txData.user || recoverCancelSignature(args.txData.transactionId, _chainId, address(this), args.signature) == args.txData.user, "#C:022");

      }

      routerBalances[args.txData.router][args.txData.receivingAssetId] += args.txData.amount;
    }

    emit TransactionCancelled(
      args.txData.user,
      args.txData.router,
      args.txData.transactionId,
      args,
      msg.sender
    );

    return args.txData;
  }


  function _addLiquidityForRouter(
    uint256 amount,
    address assetId,
    address router
  ) internal {

    require(router != address(0), "#AL:001");

    require(amount > 0, "#AL:002");

    require(isRouterOwnershipRenounced() || approvedRouters[router], "#AL:003");

    require(isAssetOwnershipRenounced() || approvedAssets[assetId], "#AL:004");

    amount = transferAssetToContract(assetId, amount);

    routerBalances[router][assetId] += amount;

    emit LiquidityAdded(router, assetId, amount, msg.sender);
  }

  function transferAssetToContract(address assetId, uint256 specifiedAmount) internal returns (uint256) {

    uint256 trueAmount = specifiedAmount;

    if (LibAsset.isNativeAsset(assetId)) {
      require(msg.value == specifiedAmount, "#TA:005");
    } else {
      uint256 starting = LibAsset.getOwnBalance(assetId);
      require(msg.value == 0, "#TA:006");
      LibAsset.transferFromERC20(assetId, msg.sender, address(this), specifiedAmount);
      trueAmount = LibAsset.getOwnBalance(assetId) - starting;
    }

    return trueAmount;
  }

  function recoverCancelSignature(
    bytes32 transactionId,
    uint256 receivingChainId,
    address receivingChainTxManagerAddress,
    bytes calldata signature
  ) internal pure returns (address) {

    SignedCancelData memory payload = SignedCancelData({
      transactionId: transactionId,
      functionIdentifier: "cancel",
      receivingChainId: receivingChainId,
      receivingChainTxManagerAddress: receivingChainTxManagerAddress
    });

    return recoverSignature(abi.encode(payload), signature);
  }

  function recoverFulfillSignature(
    bytes32 transactionId,
    uint256 relayerFee,
    uint256 receivingChainId,
    address receivingChainTxManagerAddress,
    bytes calldata signature
  ) internal pure returns (address) {

    SignedFulfillData memory payload = SignedFulfillData({
      transactionId: transactionId,
      relayerFee: relayerFee,
      functionIdentifier: "fulfill",
      receivingChainId: receivingChainId,
      receivingChainTxManagerAddress: receivingChainTxManagerAddress
    });

    return recoverSignature(abi.encode(payload), signature);
  }

  function recoverSignature(bytes memory encodedPayload, bytes calldata  signature) internal pure returns (address) {

    return ECDSA.recover(
      ECDSA.toEthSignedMessageHash(keccak256(encodedPayload)),
      signature
    );
  }

  function hashInvariantTransactionData(TransactionData calldata txData) internal pure returns (bytes32) {

    InvariantTransactionData memory invariant = InvariantTransactionData({
      receivingChainTxManagerAddress: txData.receivingChainTxManagerAddress,
      user: txData.user,
      router: txData.router,
      initiator: txData.initiator,
      sendingAssetId: txData.sendingAssetId,
      receivingAssetId: txData.receivingAssetId,
      sendingChainFallback: txData.sendingChainFallback,
      callTo: txData.callTo,
      receivingAddress: txData.receivingAddress,
      sendingChainId: txData.sendingChainId,
      receivingChainId: txData.receivingChainId,
      callDataHash: txData.callDataHash,
      transactionId: txData.transactionId
    });
    return keccak256(abi.encode(invariant));
  }

  function hashVariantTransactionData(uint256 amount, uint256 expiry, uint256 preparedBlockNumber) internal pure returns (bytes32) {

    VariantTransactionData memory variant = VariantTransactionData({
      amount: amount,
      expiry: expiry,
      preparedBlockNumber: preparedBlockNumber
    });
    return keccak256(abi.encode(variant));
  }

  function _receivingChainFulfill(
    TransactionData calldata txData,
    uint256 relayerFee,
    bytes calldata callData
  ) internal returns (bool, bool, bytes memory) {


    uint256 toSend;
    unchecked {
      toSend = txData.amount - relayerFee;
    }

    if (relayerFee > 0) {
      LibAsset.transferAsset(txData.receivingAssetId, payable(msg.sender), relayerFee);
    }

    if (txData.callTo == address(0)) {
      if (toSend > 0) {
        LibAsset.transferAsset(txData.receivingAssetId, payable(txData.receivingAddress), toSend);
      }
      return (false, false, new bytes(0));
    } else {

      bool isNativeAsset = LibAsset.isNativeAsset(txData.receivingAssetId);

      if (!isNativeAsset && toSend > 0) {
        LibAsset.transferERC20(txData.receivingAssetId, address(interpreter), toSend);
      }

      return interpreter.execute{ value: isNativeAsset ? toSend : 0}(
        txData.transactionId,
        payable(txData.callTo),
        txData.receivingAssetId,
        payable(txData.receivingAddress),
        toSend,
        callData
      );
    }
  }
}