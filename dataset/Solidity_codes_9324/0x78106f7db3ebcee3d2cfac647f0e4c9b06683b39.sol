
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
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library SafeTransferLib {


    function safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
    }
}// AGPL-3.0
pragma solidity ^0.8.13;

abstract contract Trustus {

    struct TrustusPacket {
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 request;
        uint256 deadline;
        bytes payload;
    }


    error Trustus__InvalidPacket();


    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;


    mapping(address => bool) internal isTrusted;


    modifier verifyPacket(bytes32 request, TrustusPacket calldata packet) {
        if (!_verifyPacket(request, packet)) revert Trustus__InvalidPacket();
        _;
    }


    constructor() {
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }


    function _verifyPacket(bytes32 request, TrustusPacket calldata packet)
    internal
    virtual
    returns (bool success)
    {
        if (block.timestamp > packet.deadline) return false;

        if (request != packet.request) return false;

        address recoveredAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "VerifyPacket(bytes32 request,uint256 deadline,bytes payload)"
                            ),
                            packet.request,
                            packet.deadline,
                            packet.payload
                        )
                    )
                )
            ),
            packet.v,
            packet.r,
            packet.s
        );
        return (recoveredAddress != address(0)) && isTrusted[recoveredAddress];
    }

    function _setIsTrusted(address signer, bool isTrusted_) internal virtual {
        isTrusted[signer] = isTrusted_;
    }


    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
        block.chainid == INITIAL_CHAIN_ID
        ? INITIAL_DOMAIN_SEPARATOR
        : _computeDomainSeparator();
    }

    function _computeDomainSeparator() internal view virtual returns (bytes32) {
        return
        keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("Trustus"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }
}// UNLICENSED
pragma solidity ^0.8.13;


contract DustSweeper is Ownable, ReentrancyGuard, Trustus {

  using SafeTransferLib for ERC20;

  event Sweep(address indexed makerAddress, address indexed tokenAddress, uint256 tokenAmount, uint256 ethAmount);
  event ProtocolPayout(uint256 protocolSplit, uint256 governorSplit);
  error ZeroAddress();
  error NoBalance();
  error NotContract();
  error NoTokenPrice(address tokenAddress);
  error NoSweepableOrders();
  error InsufficientNative(uint256 sendAmount, uint256 remainingBalance);
  error OutOfRange(uint256 param);

  struct Token {
    bool tokenSetup;
    uint8 decimals;
    uint8 takerDiscountTier;
  }

  struct CurrentToken {
    address tokenAddress;
    uint8 decimals;
    uint256 price;
  }

  struct TokenPrice {
    address addr;
    uint256 price;
  }

  struct Native {
    uint256 balance;
    uint256 total;
    uint256 protocol;
  }

  struct Order {
    uint256 nativeAmount;
    uint256 tokenAmount;
    uint256 distributionAmount;
    address payable destinationAddress;
  }

  address payable public protocolWallet;
  address payable public governorWallet;
  uint256 public protocolFee;
  uint256 public protocolPayoutSplit;

  mapping(address => Token) private tokens;
  mapping(uint8 => uint256) public takerDiscountTiers;
  mapping(address => address payable) public destinations;

  bytes32 public constant TRUSTUS_REQUEST_VALUE = 0xfc7ecbf4f091085173dad8d1d3c2dfd218c018596a572201cd849763d1114e7a;

  bool public sweepWhitelistOn;
  mapping(address => bool) public sweepWhitelist;

  uint256 public constant MAX_TAKER_DISCOUNT_PCT = 10000;
  uint256 public constant MAX_PROTOCOL_FEE_PCT = 5000;
  uint256 public constant MAX_PROTOCOL_PAYOUT_SPLIT_PCT = 10000;
  uint256 public constant MIN_OVERAGE_RETURN_WEI = 7000;
  uint256 public constant MAX_SWEEP_ORDER_SIZE = 200;

  constructor(
    address payable _protocolWallet,
    address payable _governorWallet,
    uint256[] memory _takerDiscountTiers,
    uint256 _protocolFeePercent,
    uint256 _protocolPayoutSplitPercent
  ) {
    if (_protocolWallet == address(0))
      revert ZeroAddress();
    if (_governorWallet == address(0))
      revert ZeroAddress();
    if (_protocolFeePercent > MAX_PROTOCOL_FEE_PCT)
      revert OutOfRange(_protocolFeePercent);
    if (_protocolPayoutSplitPercent > MAX_PROTOCOL_PAYOUT_SPLIT_PCT)
      revert OutOfRange(_protocolPayoutSplitPercent);
    uint256 _takerDiscountTierslength = _takerDiscountTiers.length;
    for (uint8 t = 0;t < _takerDiscountTierslength;++t) {
      if (_takerDiscountTiers[t] > MAX_TAKER_DISCOUNT_PCT)
        revert OutOfRange(_takerDiscountTiers[t]);
      takerDiscountTiers[t] = _takerDiscountTiers[t];
    }
    protocolWallet = _protocolWallet;
    governorWallet = _governorWallet;
    protocolFee = _protocolFeePercent;
    protocolPayoutSplit = _protocolPayoutSplitPercent;
  }

  function sweepDust(
    address[] calldata makers,
    address[] calldata tokenAddresses,
    TrustusPacket calldata packet
  ) external payable nonReentrant verifyPacket(TRUSTUS_REQUEST_VALUE, packet) {

    if (sweepWhitelistOn && !sweepWhitelist[msg.sender])
      revert NoSweepableOrders();
    TokenPrice[] memory tokenPrices = abi.decode(packet.payload, (TokenPrice[]));
    Native memory native = Native(msg.value, 0, 0);
    uint256 makerLength = makers.length;
    if (makerLength == 0 || makerLength > MAX_SWEEP_ORDER_SIZE || makerLength != tokenAddresses.length)
      revert NoSweepableOrders();
    CurrentToken memory currentToken = CurrentToken(address(0), 0, 0);
    for (uint256 i = 0; i < makerLength; ++i) {
      Order memory order = Order(0, 0, 0, payable(address(0)));
      order.tokenAmount = getTokenAmount(tokenAddresses[i], makers[i]);
      if (order.tokenAmount <= 0)
        continue;

      if (currentToken.tokenAddress != tokenAddresses[i]) {
        currentToken.tokenAddress = tokenAddresses[i];
        if (!tokens[tokenAddresses[i]].tokenSetup)
          setupToken(tokenAddresses[i]);
        currentToken.decimals = getTokenDecimals(tokenAddresses[i]);
        currentToken.price = getPrice(tokenAddresses[i], tokenPrices);
        if (currentToken.price == 0)
          revert NoTokenPrice(tokenAddresses[i]);
      }

      ERC20(tokenAddresses[i]).safeTransferFrom(makers[i], msg.sender, order.tokenAmount);

      order.nativeAmount = ((order.tokenAmount * currentToken.price) / (10**currentToken.decimals));
      native.total += order.nativeAmount;

      order.distributionAmount = (order.nativeAmount * (1e4 - takerDiscountTiers[getTokenTakerDiscountTier(tokenAddresses[i])])) / 1e4;
      if (order.distributionAmount > native.balance)
        revert InsufficientNative(order.distributionAmount, native.balance);
      native.balance -= order.distributionAmount;

      order.destinationAddress = destinations[makers[i]] == address(0) ? payable(makers[i]) : destinations[makers[i]];
      SafeTransferLib.safeTransferETH(order.destinationAddress, order.distributionAmount);
      emit Sweep(makers[i], tokenAddresses[i], order.tokenAmount, order.distributionAmount);
    }
    native.protocol = (native.total * protocolFee) / 1e4;
    if (native.protocol > native.balance)
      revert InsufficientNative(native.protocol, native.balance);
    native.balance -= native.protocol;

    if (native.balance > MIN_OVERAGE_RETURN_WEI) {
      SafeTransferLib.safeTransferETH(payable(msg.sender), native.balance);
    }
  }

  function getTokenAmount(address _tokenAddress, address _makerAddress) private view returns(uint256) {

    uint256 allowance = ERC20(_tokenAddress).allowance(_makerAddress, address(this));
    if (allowance == 0)
      return 0;
    uint256 balance = ERC20(_tokenAddress).balanceOf(_makerAddress);
    return balance < allowance ? balance : allowance;
  }

  function getPrice(address _tokenAddress, TokenPrice[] memory _tokenPrices) private pure returns(uint256) {

    uint256 tokenPricesLength = _tokenPrices.length;
    for (uint256 i = 0;i < tokenPricesLength;++i) {
      if (_tokenAddress == _tokenPrices[i].addr) {
        return _tokenPrices[i].price;
      }
    }
    return 0;
  }

  function setupToken(address _tokenAddress) public {

    (bool success, bytes memory result) = _tokenAddress.staticcall(abi.encodeWithSignature("decimals()"));
    uint8 decimals = 18;
    if (success)
      decimals = abi.decode(result, (uint8));
    tokens[_tokenAddress].tokenSetup = true;
    tokens[_tokenAddress].decimals = decimals;
  }

  function getTokenDecimals(address _tokenAddress) public view returns(uint8) {

    return tokens[_tokenAddress].decimals;
  }

  function getTokenTakerDiscountTier(address _tokenAddress) public view returns(uint8) {

    return tokens[_tokenAddress].takerDiscountTier;
  }

  function setDestinationAddress(address _destinationAddress) external {

    if (_destinationAddress == address(0))
      revert ZeroAddress();
    destinations[msg.sender] = payable(_destinationAddress);
  }

  function setTokenDecimals(address _tokenAddress, uint8 _decimals) external onlyOwner {

    if (_tokenAddress == address(0))
      revert ZeroAddress();
    tokens[_tokenAddress].decimals = _decimals;
  }

  function setTokenTakerDiscountTier(address _tokenAddress, uint8 _tier) external onlyOwner {

    if (_tokenAddress == address(0))
      revert ZeroAddress();
    if (takerDiscountTiers[_tier] == 0)
      revert OutOfRange(_tier);
    tokens[_tokenAddress].takerDiscountTier = _tier;
  }

  function setTakerDiscountPercent(uint256 _takerDiscountPercent, uint8 _tier) external onlyOwner {

    if (_takerDiscountPercent == 0 || _takerDiscountPercent > MAX_TAKER_DISCOUNT_PCT)
      revert OutOfRange(_takerDiscountPercent);
    takerDiscountTiers[_tier] = _takerDiscountPercent;
  }

  function setProtocolFeePercent(uint256 _protocolFeePercent) external onlyOwner {

    if (_protocolFeePercent > MAX_PROTOCOL_FEE_PCT)
      revert OutOfRange(_protocolFeePercent);
    protocolFee = _protocolFeePercent;
  }

  function setProtocolWallet(address payable _protocolWallet) external onlyOwner {

    if (_protocolWallet == address(0))
      revert ZeroAddress();
    protocolWallet = _protocolWallet;
  }

  function setGovernorWallet(address payable _governorWallet) external onlyOwner {

    if (_governorWallet == address(0))
      revert ZeroAddress();
    governorWallet = _governorWallet;
  }

  function setProtocolPayoutSplit(uint256 _protocolPayoutSplitPercent) external onlyOwner {

    if (_protocolPayoutSplitPercent > MAX_PROTOCOL_PAYOUT_SPLIT_PCT)
      revert OutOfRange(_protocolPayoutSplitPercent);
    protocolPayoutSplit = _protocolPayoutSplitPercent;
  }

  function toggleIsTrusted(address _trustedProviderAddress) external onlyOwner {

    if (_trustedProviderAddress == address(0))
      revert ZeroAddress();
    bool _isTrusted = isTrusted[_trustedProviderAddress] ? false : true;
    _setIsTrusted(_trustedProviderAddress, _isTrusted);
  }

  function getIsTrusted(address _trustedProviderAddress) external view returns(bool) {

    return isTrusted[_trustedProviderAddress];
  }

  function toggleSweepWhitelist() external onlyOwner {

    sweepWhitelistOn = sweepWhitelistOn ? false : true;
  }

  function toggleSweepWhitelistAddress(address _whitelistAddress) external onlyOwner {

    if (_whitelistAddress == address(0))
      revert ZeroAddress();
    sweepWhitelist[_whitelistAddress] = sweepWhitelist[_whitelistAddress] ? false : true;
  }

  function payoutProtocolFees() external nonReentrant {

    uint256 balance = address(this).balance;
    if (balance <= 0)
      revert NoBalance();
    uint256 protocolSplit = (balance * protocolPayoutSplit) / 1e4;
    if (protocolSplit > 0)
      SafeTransferLib.safeTransferETH(protocolWallet, protocolSplit);
    uint256 governorSplit = address(this).balance;
    if (governorSplit > 0)
      SafeTransferLib.safeTransferETH(governorWallet, governorSplit);
    emit ProtocolPayout(protocolSplit, governorSplit);
  }

  function withdrawToken(address _tokenAddress) external onlyOwner {

    uint256 tokenBalance = ERC20(_tokenAddress).balanceOf(address(this));
    if (tokenBalance <= 0)
      revert NoBalance();
    ERC20(_tokenAddress).safeTransfer(msg.sender, tokenBalance);
  }

  receive() external payable {}
  fallback() external payable {}
}