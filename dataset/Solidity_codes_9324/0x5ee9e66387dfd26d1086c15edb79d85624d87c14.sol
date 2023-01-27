
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
}//Unlicense
pragma solidity 0.8.13;


contract EIP712Whitelisting {

  using ECDSA for bytes32;

  address whitelistSigningKey = address(0);

  bytes32 public DOMAIN_SEPARATOR;

  bytes32 public constant MINTER_TYPEHASH = keccak256("Minter(address wallet)");

  constructor(string memory tokenName, string memory version) {
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(tokenName)),
        keccak256(bytes(version)),
        block.chainid,
        address(this)
      )
    );
  }

  function _setWhitelistSigningAddress(address newSigningKey) internal {

    whitelistSigningKey = newSigningKey;
  }

  modifier requiresWhitelist(bytes calldata signature) {

    require(whitelistSigningKey != address(0), "Whitelist not enabled; please set the private key.");
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(MINTER_TYPEHASH, msg.sender))));
    address recoveredAddress = digest.recover(signature);
    require(recoveredAddress == whitelistSigningKey, "Invalid signature");
    _;
  }
}// MIT

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
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


contract PaymentSplitter is Context {

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function totalShares() public view returns (uint256) {

        return _totalShares;
    }

    function totalReleased() public view returns (uint256) {

        return _totalReleased;
    }

    function totalReleased(IERC20 token) public view returns (uint256) {

        return _erc20TotalReleased[token];
    }

    function shares(address account) public view returns (uint256) {

        return _shares[account];
    }

    function released(address account) public view returns (uint256) {

        return _released[account];
    }

    function released(IERC20 token, address account) public view returns (uint256) {

        return _erc20Released[token][account];
    }

    function payee(uint256 index) public view returns (address) {

        return _payees[index];
    }

    function release(address payable account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function release(IERC20 token, address account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {

        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares_) private {

        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
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
}//UNLICENSED
pragma solidity 0.8.13;



interface INFT {

    function mint(address recipient, uint256 quantity) external;


    function areReservesMinted() external view returns (bool);


    function maxSupply() external view returns (uint256);


    function totalSupply() external view returns (uint256);

}

contract MintingRouter is Ownable, EIP712Whitelisting, ReentrancyGuard {

    enum SaleRoundType {
        WHITELIST,
        PUBLIC
    }

    struct SaleRound {
        SaleRoundType saleType;
        uint256 price;
        uint256 totalAmount;
        uint256 limitAmountPerWallet;
        uint256 maxAmountPerMint;
        bool enabled;
    }
    uint256 public constant UNLIMITED_AMOUNT = 0;
    SaleRound public currentSaleRound;
    uint256 public currentSaleIndex;
    INFT private _nftContract;
    PaymentSplitter public splitter;
    mapping(uint256 => uint256) private _mintedAmountPerRound;
    mapping(uint256 => mapping(address => uint256))
        private _mintedAmountPerAddress;

    constructor(
        INFT nftContract,
        string memory tokenName,
        string memory version,
        address[] memory payees,
        uint256[] memory shares
    ) EIP712Whitelisting(tokenName, version) {
        _nftContract = nftContract;
        splitter = new PaymentSplitter(payees, shares);
        currentSaleIndex = type(uint256).max;
    }

    modifier validateSaleRoundParams(
        bool isNewRound,
        uint256 totalAmount,
        uint256 limitAmountPerWallet,
        uint256 maxAmountPerMint
    ) {

        require(
            _totalTokensLeft() > 0 &&
            totalAmount <= _totalTokensLeft(),
            "INVALID_TOTAL_AMOUNT"
        );

        if (!isNewRound) {
            require(totalAmount >= _mintedAmountPerRound[currentSaleIndex], "INVALID_TOTAL_AMOUNT");
        }

        if (totalAmount != UNLIMITED_AMOUNT) {
            require(limitAmountPerWallet <= totalAmount,"INVALID_LIMIT_PER_WALLET");
            require(maxAmountPerMint <= totalAmount, "INVALID_MAX_PER_MINT");
        }

        if (limitAmountPerWallet != UNLIMITED_AMOUNT) {
            require(maxAmountPerMint <= limitAmountPerWallet, "INVALID_MAX_PER_MINT");
        }

        _;
    }

    function changePayees(address[] memory payees, uint256[] memory shares)
        external
        onlyOwner
    {

        splitter = new PaymentSplitter(payees, shares);
    }

    function changeSaleRoundParams(
        uint256 price,
        uint256 totalAmount,
        uint256 limitAmountPerWallet,
        uint256 maxAmountPerMint
    ) external onlyOwner validateSaleRoundParams(
        false,
        totalAmount,
        limitAmountPerWallet,
        maxAmountPerMint
    ) {

        currentSaleRound.price = price;
        currentSaleRound.totalAmount = totalAmount;
        currentSaleRound.limitAmountPerWallet = limitAmountPerWallet;
        currentSaleRound.maxAmountPerMint = maxAmountPerMint;
    }

    function createSaleRound(
        SaleRoundType saleType,
        uint256 price,
        uint256 totalAmount,
        uint256 limitAmountPerWallet,
        uint256 maxAmountPerMint
    ) external onlyOwner validateSaleRoundParams(
        true,
        totalAmount,
        limitAmountPerWallet,
        maxAmountPerMint
    ) {

        require(
            currentSaleRound.enabled == false,
            "SALE_ROUND_IS_ENABLED"
        );

        bool reservesMinted = _nftContract.areReservesMinted();
        require(
            reservesMinted == true,
            "ALL_RESERVED_TOKENS_NOT_MINTED"
        );

        currentSaleRound.price = price;
        currentSaleRound.totalAmount = totalAmount;
        currentSaleRound.limitAmountPerWallet = limitAmountPerWallet;
        currentSaleRound.maxAmountPerMint = maxAmountPerMint;
        currentSaleRound.saleType = saleType;
        if (currentSaleIndex == type(uint256).max) {
            currentSaleIndex = 0;
        } else {
            currentSaleIndex += 1;
        }
    }

    function enableSaleRound() external onlyOwner {

        require(currentSaleIndex != type(uint256).max, "NO_SALE_ROUND_CREATED");
        require(currentSaleRound.enabled == false, "SALE_ROUND_ENABLED_ALREADY");
        currentSaleRound.enabled = true;
    }

    function disableSaleRound() external onlyOwner {

        require(currentSaleRound.enabled == true, "SALE_ROUND_DISABLED_ALREADY");
        currentSaleRound.enabled = false;
    }

    function whitelistMint(
        address recipient,
        uint256 quantity,
        bytes calldata signature
    ) external payable requiresWhitelist(signature) nonReentrant {

        require(
            currentSaleRound.saleType == SaleRoundType.WHITELIST && currentSaleRound.enabled,
            "WHITELIST_ROUND_NOT_ENABLED"
        );
        _mint(recipient, quantity);
    }

    function publicMint(address recipient, uint256 quantity)
        external
        payable
        nonReentrant
    {

        require(
            currentSaleRound.saleType == SaleRoundType.PUBLIC && currentSaleRound.enabled,
            "PUBLIC_ROUND_NOT_ENABLED"
        );
        _mint(recipient, quantity);
    }

    function setWhitelistSigningAddress(address signer) public onlyOwner {

        _setWhitelistSigningAddress(signer);
    }

    function release(address payable account) public onlyOwner {

        splitter.release(account);
    }

    function allowedTokenCount(address minter) public view returns (uint256) {

        if (currentSaleRound.enabled == false) {
            return 0;
        }

        uint256 allowedWalletCount = _totalTokensLeft();
        if (currentSaleRound.limitAmountPerWallet != UNLIMITED_AMOUNT) {
            allowedWalletCount = currentSaleRound.limitAmountPerWallet - _mintedAmountPerAddress[currentSaleIndex][minter];
        }

        uint256 allowedAmountPerMint = _totalTokensLeft();
        if (currentSaleRound.maxAmountPerMint != UNLIMITED_AMOUNT) {
            allowedAmountPerMint = currentSaleRound.maxAmountPerMint;
        }

        return _min(
            allowedAmountPerMint,
            _min(allowedWalletCount, tokensLeft())
        );
    }

    function tokensLeft() public view returns (uint256) {

        if (currentSaleRound.enabled == false) {
            return 0;
        }

        if (currentSaleRound.totalAmount == UNLIMITED_AMOUNT) {
            return _totalTokensLeft();
        }

        return currentSaleRound.totalAmount - _mintedAmountPerRound[currentSaleIndex];
    }

    function _mint(
        address recipient,
        uint256 quantity
    ) private {

        require(quantity > 0, "ZERO_QUANTITY_NOT_ALLOWED");
        require(allowedTokenCount(recipient) >= quantity, "MAX_MINTS_EXCEEDED");
        require(msg.value >= currentSaleRound.price * quantity, "INSUFFICIENT_FUNDS");
        _mintedAmountPerAddress[currentSaleIndex][recipient] += quantity;
        _mintedAmountPerRound[currentSaleIndex] += quantity;
        _nftContract.mint(recipient, quantity);
        (bool sent, ) = payable(splitter).call{value: msg.value}("");
        require(sent, "FAIL_FUNDS_TRANSFER");
    }

    function _totalTokensLeft() private view returns(uint256) {

        return _nftContract.maxSupply() - _nftContract.totalSupply();
    }

    function _min(uint256 a, uint256 b) private pure returns(uint256) {

        if (a < b) {
            return a;
        }

        return b;
    }
}