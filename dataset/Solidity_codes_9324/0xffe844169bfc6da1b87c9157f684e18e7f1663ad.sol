


pragma solidity ^0.8.0;


contract AddressChecksumStringUtil {


    function toChecksumString(address account) internal pure returns (string memory asciiString) {

        bytes20 data = bytes20(account);

        bytes memory asciiBytes = new bytes(40);

        uint8 b;
        uint8 leftNibble;
        uint8 rightNibble;
        bool leftCaps;
        bool rightCaps;
        uint8 asciiOffset;

        bool[40] memory caps = _toChecksumCapsFlags(account);

        for (uint256 i = 0; i < data.length; i++) {
            b = uint8(uint160(data) / (2**(8*(19 - i))));
            leftNibble = b / 16;
            rightNibble = b - 16 * leftNibble;

            leftCaps = caps[2*i];
            rightCaps = caps[2*i + 1];

            asciiOffset = _getAsciiOffset(leftNibble, leftCaps);

            asciiBytes[2 * i] = bytes1(leftNibble + asciiOffset);

            asciiOffset = _getAsciiOffset(rightNibble, rightCaps);

            asciiBytes[2 * i + 1] = bytes1(rightNibble + asciiOffset);
        }

        return string(abi.encodePacked("0x", string(asciiBytes)));
    }

    function _getAsciiOffset(uint8 nibble, bool caps) internal pure returns (uint8 offset) {

        if (nibble < 10) {
            offset = 48;
        } else if (caps) {
            offset = 55;
        } else {
            offset = 87;
        }
    }

    function _toChecksumCapsFlags(address account) internal pure returns (bool[40] memory characterCapitalized) {

        bytes20 a = bytes20(account);

        bytes32 b = keccak256(abi.encodePacked(_toAsciiString(a)));

        uint8 leftNibbleAddress;
        uint8 rightNibbleAddress;
        uint8 leftNibbleHash;
        uint8 rightNibbleHash;

        for (uint256 i; i < a.length; i++) {
            rightNibbleAddress = uint8(a[i]) % 16;
            leftNibbleAddress = (uint8(a[i]) - rightNibbleAddress) / 16;
            rightNibbleHash = uint8(b[i]) % 16;
            leftNibbleHash = (uint8(b[i]) - rightNibbleHash) / 16;

            characterCapitalized[2 * i] = (leftNibbleAddress > 9 && leftNibbleHash > 7);
            characterCapitalized[2 * i + 1] = (rightNibbleAddress > 9 && rightNibbleHash > 7);
        }
    }

    function _toAsciiString(bytes20 data) internal pure returns (string memory asciiString) {

        bytes memory asciiBytes = new bytes(40);

        uint8 b;
        uint8 leftNibble;
        uint8 rightNibble;

        for (uint256 i = 0; i < data.length; i++) {
            b = uint8(uint160(data) / (2 ** (8 * (19 - i))));
            leftNibble = b / 16;
            rightNibble = b - 16 * leftNibble;

            asciiBytes[2 * i] = bytes1(leftNibble + (leftNibble < 10 ? 48 : 87));
            asciiBytes[2 * i + 1] = bytes1(rightNibble + (rightNibble < 10 ? 48 : 87));
        }

        return string(asciiBytes);
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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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


pragma solidity 0.8.12;

interface IAwooToken is IERC20 {

    function increaseVirtualBalance(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;

    function balanceOfVirtual(address account) external view returns(uint256);

    function spendVirtualAwoo(bytes32 hash, bytes memory sig, string calldata nonce, address account, uint256 amount) external;

}



pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


pragma solidity 0.8.12;

contract AwooToken is IAwooToken, ERC20, ReentrancyGuard, Ownable, AddressChecksumStringUtil {
    using ECDSA for bytes32;
    using Strings for uint256;

    bool public isActive = true;

    uint256 public awooFeePercentage = 10;
    address public awooStudiosAccount;

    address[2] private _admins;
    bool private _adminsSet;   

    mapping(address => bool) private _authorizedContracts;
    mapping(address => uint256) private _virtualBalance;
    mapping(string => bool) private _usedNonces;

    event AuthorizedContractAdded(address contractAddress, address addedBy);
    event AuthorizedContractRemoved(address contractAddress, address removedBy);
    event VirtualAwooSpent(address spender, uint256 amount);

    constructor(address awooAccount) ERC20("Awoo Token", "AWOO") {
        require(awooAccount != address(0), "Invalid awooAccount");
        awooStudiosAccount = awooAccount;
    }

    function mint(address account, uint256 amount) external nonReentrant onlyAuthorizedContract {
        require(account != address(0), "Cannot mint to the zero address");
        require(amount > 0, "Amount cannot be zero");
        _mint(account, amount);
    }

    function addAuthorizedContract(address contractAddress) external onlyOwnerOrAdmin {
        require(isContract(contractAddress), "Not a contract address");
        _authorizedContracts[contractAddress] = true;
        emit AuthorizedContractAdded(contractAddress, _msgSender());
    }

    function removeAuthorizedContract(address contractAddress) external onlyOwnerOrAdmin {
        _authorizedContracts[contractAddress] = false;
        emit AuthorizedContractRemoved(contractAddress, _msgSender());
    }

    function withdraw(uint256 amount) external whenActive hasBalance(amount, _virtualBalance[_msgSender()]) nonReentrant {
        _mint(_msgSender(), amount);
        _virtualBalance[_msgSender()] -= amount;
    }

    function deposit(uint256 amount) external whenActive hasBalance(amount, balanceOf(_msgSender())) nonReentrant {
        _burn(_msgSender(), amount);
        _virtualBalance[_msgSender()] += amount;
    }

    function balanceOfVirtual(address account) external view returns(uint256) {
        return _virtualBalance[account];
    }

    function totalBalanceOf(address account) external view returns(uint256) {
        return _virtualBalance[account] + balanceOf(account);
    }

    function increaseVirtualBalance(address account, uint256 amount) external onlyAuthorizedContract {
        _virtualBalance[account] += amount;
    }

    function spendVirtualAwoo(bytes32 hash, bytes memory sig, string calldata nonce, address account, uint256 amount)
        external onlyAuthorizedContract hasBalance(amount, _virtualBalance[account]) nonReentrant {
            require(_usedNonces[nonce] == false, "Duplicate nonce");
            require(matchAddresSigner(account, hash, sig), "Message signer mismatch"); // Make sure that the spend request was authorized (signed) by the holder
            require(hashTransaction(account, amount) == hash, "Hash check failed"); // Make sure that only the amount authorized by the holder can be spent
        
            _virtualBalance[account]-=amount;

            _mint(awooStudiosAccount, ((amount * awooFeePercentage)/100));

            _usedNonces[nonce] = true;

            emit VirtualAwooSpent(account, amount);
    }

    function setAdmins(address[2] calldata adminAddresses) external onlyOwner {
        require(adminAddresses[0] != address(0) && adminAddresses[1] != address(0), "Invalid admin address");
        _admins = adminAddresses;
        _adminsSet = true;
    }

    function setActiveState(bool active) external onlyOwnerOrAdmin {
        isActive = active;
    }

    function setAwooStudiosAccount(address awooAccount) external onlyOwner {
        require(awooAccount != address(0), "Invalid awooAccount");
        awooStudiosAccount = awooAccount;
    }

    function setFeePercentage(uint256 feePercentage) external onlyOwner {
        awooFeePercentage = feePercentage; // We're intentionally allowing the fee percentage to be set to 0%, incase no fees need to be collected
    }

    function rescueEth() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function matchAddresSigner(address account, bytes32 hash, bytes memory signature) private pure returns (bool) {
        return account == hash.recover(signature);
    }

    function hashTransaction(address sender, uint256 amount) private pure returns (bytes32) {
        require(amount == ((amount/1e18)*1e18), "Invalid amount");
        amount = amount/1e18;
        
        string memory message = string(abi.encodePacked(
            "As the owner of Ethereum address\r\n",
            toChecksumString(sender),
            "\r\nI authorize the spending of ",
            amount.toString()," virtual $AWOO"
        ));
        uint256 messageLength = bytes(message).length;

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n",messageLength.toString(),
                message
            )
        );
        return hash;
    }
    
    modifier onlyAuthorizedContract() {
        require(_authorizedContracts[_msgSender()], "Sender is not authorized");
        _;
    }

    modifier whenActive() {
        require(isActive, "Contract is not active");
        _;
    }

    modifier hasBalance(uint256 amount, uint256 balance) {
        require(amount > 0, "Amount cannot be zero");
        require(balance >= amount, "Insufficient Balance");
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(
            _msgSender() == owner() ||
                (_adminsSet &&
                    (_msgSender() == _admins[0] || _msgSender() == _admins[1])),
            "Caller is not the owner or an admin"
        );
        _;
    }
}