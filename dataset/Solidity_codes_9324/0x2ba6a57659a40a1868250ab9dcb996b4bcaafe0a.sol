
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
pragma solidity 0.8.13;


contract EIP712 {

  using ECDSA for bytes32;

  bytes32 public DOMAIN_SEPARATOR;


  constructor(string memory name, string memory version) {
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(name)),
        keccak256(bytes(version)),
        block.chainid,
        address(this)
      )
    );
  }

  function _isValidSignature(
    bytes32 structHash,
    bytes calldata signature,
    address expectedSigner
  ) internal view returns (bool) {

    if (expectedSigner == address(0)) {
      return false;
    }

    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    address recoveredAddress = digest.recover(signature);
    return recoveredAddress == expectedSigner;
  }
}

pragma solidity ^0.8.13;

interface IDEXRouter {

  function factory() external pure returns (address);


  function WETH() external pure returns (address);


  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );


  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );


  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;


  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;


  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;


  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);

}
pragma solidity 0.8.13;


contract ClaimRewards is EIP712, Ownable, ReentrancyGuard {

  bytes32 private constant _BATCH_TYPE = keccak256("Batch(uint256 batchId,uint256 issuedTimestamp)");
  bytes32 private constant _TICKET_TYPE = keccak256("Ticket(uint8 rewardType,address tokenAddress,uint256 amount,address claimerAddress,uint256 ticketId,bytes32 batchProofSignature)");

  uint256 public maxTicketsPerBatch = 1_000_000;
  uint256 public minCharityDonationPercent = 15;
  uint256 public maxCharityDonationPercent = 100;

  uint256 public durationToConvertETHToTokens = 5 days;

  address public charityAddress;
  address public batchSigner;
  address public ticketSigner;

  uint256 public totalETHClaimedAmount;
  uint256 public totalETHDonatedAmount;
  mapping(address => uint256) public totalERC20ClaimedAmount;
  mapping(address => uint256) public totalERC20DonatedAmount;

  IDEXRouter public dexRouter;

  constructor(
    string memory contractName,
    string memory contractVersion,
    address _dexRouter,
    address _charityAddress
  ) EIP712(contractName, contractVersion) {
    dexRouter = IDEXRouter(_dexRouter);
    charityAddress = _charityAddress;
  }

  enum RewardType {
    ETH,
    ERC20
  }

  struct Batch {
    uint256 batchId;
    uint256 issuedTimestamp;
  }

  struct Ticket {
    uint8 rewardType;
    address tokenAddress;
    uint256 amount;
    address claimerAddress;
    uint256 ticketId;
    Batch batch;
    bytes batchProofSignature;
    bytes ticketProofSignature;
  }

  mapping(uint256 => bool) public isTicketClaimed;

  function _hashBatch(Batch calldata batch) private pure returns (bytes32) {

    return keccak256(abi.encode(_BATCH_TYPE, batch.batchId, batch.issuedTimestamp));
  }

  function _hashTicket(Ticket calldata ticket) private pure returns (bytes32) {

    return keccak256(abi.encode(_TICKET_TYPE, ticket.rewardType, ticket.tokenAddress, ticket.amount, ticket.claimerAddress, ticket.ticketId, keccak256(ticket.batchProofSignature)));
  }

  function setDexRouter(address router) external onlyOwner {

    dexRouter = IDEXRouter(router);
  }

  function setCharityAddress(address address_) external onlyOwner {

    charityAddress = address_;
  }

  function setBatchSignerAddress(address signer) external onlyOwner {

    batchSigner = signer;
  }

  function setTicketSignerAddress(address signer) external onlyOwner {

    ticketSigner = signer;
  }

  function setSigners(address _batchSigner, address _ticketSigner) external onlyOwner {

    batchSigner = _batchSigner;
    ticketSigner = _ticketSigner;
  }

  function setParams(
    uint256 _maxTicketsPerBatch,
    uint256 _minCharityDonationPercent,
    uint256 _maxCharityDonationPercent,
    uint256 _durationToConvertETHToTokensInSeconds
  ) external onlyOwner {

    maxTicketsPerBatch = _maxTicketsPerBatch;
    minCharityDonationPercent = _minCharityDonationPercent;
    maxCharityDonationPercent = _maxCharityDonationPercent;
    durationToConvertETHToTokens = _durationToConvertETHToTokensInSeconds;
  }

  function getBatchIdOfTicket(uint256 ticketId) private view returns (uint256) {

    return ticketId - (ticketId % maxTicketsPerBatch);
  }

  function _validateDonationPercent(uint256 percent) private view {

    require(percent >= minCharityDonationPercent && percent <= maxCharityDonationPercent, "INVALID_CHARITY_DONATION_PERCENT");
  }

  function _convertETHToTokenAmount(uint256 amountETH, address tokenAddress) private view returns (uint256) {

    address[] memory path = new address[](2);
    path[0] = dexRouter.WETH();
    path[1] = tokenAddress;
    uint256[] memory amounts = dexRouter.getAmountsOut(amountETH, path);
    return amounts[1];
  }

  function _swapTokensForETH(address tokenAddress, uint256 tokenAmount) internal returns (uint256) {

    uint256 balanceBefore = address(this).balance;
    address[] memory path = new address[](2);
    path[0] = tokenAddress;
    path[1] = dexRouter.WETH();

    if (IERC20(tokenAddress).allowance(address(this), address(dexRouter)) < tokenAmount) {
      IERC20(tokenAddress).approve(address(dexRouter), type(uint256).max);
    }

    dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    uint256 amountETH = address(this).balance - balanceBefore;
    return amountETH;
  }

  function _validateTicket(Ticket calldata ticket, RewardType expectedRewardType) private view {

    require(!isTicketClaimed[ticket.ticketId], "ALREADY_CLAIMED");
    require(RewardType(ticket.rewardType) == expectedRewardType, "INVALID_REWARD_TYPE");
    require(_isValidSignature(_hashBatch(ticket.batch), ticket.batchProofSignature, batchSigner), "INVALID_BATCH_SIGNATURE");
    require(_isValidSignature(_hashTicket(ticket), ticket.ticketProofSignature, ticketSigner), "INVALID_TICKET_SIGNATURE");
    require(ticket.batch.batchId == getBatchIdOfTicket(ticket.ticketId), "MISMATCHED_TICKET_ID");
    require(ticket.claimerAddress == msg.sender, "CALLER_ADDRESS_MUST_MATCH_CLAIMER_ADDRESS");
  }

  function claimETH(
    Ticket[] calldata tickets,
    uint256 charityDonationPercent,
    bool shouldConvertToToken,
    address tokenAddress
  ) external nonReentrant {

    require(tickets.length != 0, "NO_TICKET_TO_PROCESS");
    _validateDonationPercent(charityDonationPercent);

    uint256 totalETHForClaimAmount;
    for (uint256 i; i < tickets.length; i++) {
      _validateTicket(tickets[i], RewardType.ETH);
      totalETHForClaimAmount += tickets[i].amount;
      isTicketClaimed[tickets[i].ticketId] = true;
    }

    require(totalETHForClaimAmount > 0, "INVALID_REWARD_AMOUNT");

    uint256 charityAmount = (totalETHForClaimAmount * charityDonationPercent) / 100;
    _safeTransferETH(charityAddress, charityAmount);
    totalETHForClaimAmount -= charityAmount;

    uint256 convertDeadline = tickets[0].batch.issuedTimestamp + durationToConvertETHToTokens;
    if (shouldConvertToToken && block.timestamp <= convertDeadline) {
      uint256 tokenAmount = _convertETHToTokenAmount(totalETHForClaimAmount, tokenAddress);
      require(IERC20(tokenAddress).transfer(msg.sender, tokenAmount), "FAILED_TO_TRANSFER_TOKENS");
      totalERC20ClaimedAmount[tokenAddress] += tokenAmount;
    } else {
      _safeTransferETH(msg.sender, totalETHForClaimAmount);
      totalETHClaimedAmount += totalETHForClaimAmount;
    }

    totalETHDonatedAmount += charityAmount;
  }

  function claimERC20(
    Ticket[] calldata tickets,
    uint256 charityDonationPercent,
    bool shouldSwapRewardTokenToETH
  ) external nonReentrant {

    require(tickets.length != 0, "NO_TICKET_TO_PROCESS");
    _validateDonationPercent(charityDonationPercent);

    address tokenAddress = tickets[0].tokenAddress;
    require(tokenAddress != address(0), "MUST_BE_A_VALID_TOKEN_ADDRESS");

    uint256 tokenForClaimAmount;
    for (uint256 i; i < tickets.length; i++) {
      _validateTicket(tickets[i], RewardType.ERC20);
      require(tickets[i].tokenAddress == tokenAddress, "ALL_TICKETS_MUST_HAVE_SAME_TOKEN_ADDRESS");

      tokenForClaimAmount += tickets[i].amount;
      isTicketClaimed[tickets[i].ticketId] = true;
    }

    require(tokenForClaimAmount > 0, "INVALID_REWARD_AMOUNT");

    uint256 charityAmount = (tokenForClaimAmount * charityDonationPercent) / 100;
    if (shouldSwapRewardTokenToETH) {
      uint256 amountETHForClaim = _swapTokensForETH(tokenAddress, tokenForClaimAmount);
      uint256 charityAmountETH = (amountETHForClaim * charityDonationPercent) / 100;
      if (charityAmountETH > 0) {
        _safeTransferETH(charityAddress, charityAmountETH);
        amountETHForClaim = amountETHForClaim - charityAmountETH;
      }

      _safeTransferETH(msg.sender, amountETHForClaim);
      tokenForClaimAmount -= charityAmount;
    } else {
      require(IERC20(tokenAddress).transfer(charityAddress, charityAmount), "FAILED_TO_TRANSFER_TOKENS");
      tokenForClaimAmount -= charityAmount;
      require(IERC20(tokenAddress).transfer(msg.sender, tokenForClaimAmount), "FAILED_TO_TRANSFER_TOKENS");
    }

    totalERC20ClaimedAmount[tokenAddress] += tokenForClaimAmount;
    totalERC20DonatedAmount[tokenAddress] += charityAmount;
  }

  function _safeTransferETH(address to, uint256 value) internal {

    require(address(this).balance >= value, "INSUFFICIENT_BALANCE");
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "SafeTransferETH: ETH transfer failed");
  }

  function withdraw() external onlyOwner {

    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawErc20(IERC20 token) external onlyOwner {

    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

  receive() external payable {}
}
