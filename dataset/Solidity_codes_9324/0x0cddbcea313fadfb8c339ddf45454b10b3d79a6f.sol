




interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}






interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}






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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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





interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}





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






abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}





library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}






abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}






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




interface IVesting {
    struct VestingEntry {
        uint96 amount;
        uint64 start;
        uint32 lockup;
        uint32 cliff;
        uint32 vesting;
    }

    event AirdropperUpdated(address indexed account, bool status);
    event Airdrop(address indexed account, uint96 amount);
    event VestingEntryUpdated(
        address indexed account,
        uint96 amount,
        uint64 start,
        uint32 lockup,
        uint32 cliff,
        uint32 vesting
    );

    function vestingOf(address account)
        external
        view
        returns (
            uint64 start,
            uint32 lockup,
            uint32 cliff,
            uint32 vesting,
            uint96 balance,
            uint96 vested,
            uint96 locked,
            uint96 unlocked
        );

    function airdrop(
        uint32 lockup,
        uint32 cliff,
        uint32 vesting,
        address account,
        uint96 amount
    ) external returns (bool);

    function airdropBatch(
        uint32 lockup,
        uint32 cliff,
        uint32 vesting,
        address[] memory accounts,
        uint96[] memory amounts
    ) external returns (bool);
}





abstract contract Vesting is ERC20, Ownable, IVesting {
    mapping(address => VestingEntry) private _vestingOf;
    mapping(address => bool) private _isAirdropper;

    function vestingOf(address account)
        external
        view
        override
        returns (
            uint64 start,
            uint32 lockup,
            uint32 cliff,
            uint32 vesting,
            uint96 balance,
            uint96 vested,
            uint96 locked,
            uint96 unlocked
        )
    {
        if (_isVested(account)) {
            start = _vestingOf[account].start;
            lockup = _vestingOf[account].lockup;
            cliff = _vestingOf[account].cliff;
            vesting = _vestingOf[account].vesting;
            vested = _vestingOf[account].amount;
            locked = uint96(_lockedOf(account));
        }
        balance = uint96(balanceOf(account));
        unlocked = balance - locked;
    }

    function _isVested(address account) private view returns (bool) {
        return _vestingOf[account].amount != 0;
    }

    function _lockedOf(address account) private view returns (uint256) {
        return
            _pureLockedOf(
                _vestingOf[account].lockup,
                _vestingOf[account].cliff,
                _vestingOf[account].vesting,
                uint64(block.timestamp) - _vestingOf[account].start,
                uint256(_vestingOf[account].amount)
            );
    }

    function _pureLockedOf(
        uint32 lockupTime,
        uint32 cliffTime,
        uint32 vestingTime,
        uint64 passedTime,
        uint256 amount
    ) private pure returns (uint256) {
        if (passedTime >= (lockupTime + vestingTime)) return 0;
        if (passedTime <= (lockupTime + cliffTime)) return amount;
        return amount - (amount * (passedTime - lockupTime)) / vestingTime;
    }

    function setAirdropper(address account, bool status) external onlyOwner {
        _isAirdropper[account] = status;
        emit AirdropperUpdated(account, status);
    }

    modifier onlyAirdropper() {
        require(_isAirdropper[_msgSender()], "Caller is not allowed");
        _;
    }

    function airdrop(
        uint32 lockup,
        uint32 cliff,
        uint32 vesting,
        address account,
        uint96 amount
    ) external override onlyAirdropper returns (bool) {
        _airdrop(
            _msgSender(),
            uint64(block.timestamp),
            lockup,
            cliff,
            vesting,
            account,
            amount
        );
        return true;
    }

    function airdropBatch(
        uint32 lockup,
        uint32 cliff,
        uint32 vesting,
        address[] memory accounts,
        uint96[] memory amounts
    ) external override onlyAirdropper returns (bool) {
        require(accounts.length == amounts.length, "Mismatch");
        address from = _msgSender();
        uint64 start = uint64(block.timestamp);
        for (uint256 i = 0; i < accounts.length; i++) {
            _airdrop(
                from,
                start,
                lockup,
                cliff,
                vesting,
                accounts[i],
                amounts[i]
            );
        }
        return true;
    }

    function _airdrop(
        address from,
        uint64 start,
        uint32 lockup,
        uint32 cliff,
        uint32 vesting,
        address account,
        uint96 amount
    ) private {
        if (vesting != 0 || cliff != 0 || lockup != 0) {
            if (!_isVested(account)) {
                _vestingOf[account].start = start;
                _vestingOf[account].lockup = lockup;
                _vestingOf[account].cliff = cliff;
                _vestingOf[account].vesting = vesting;
            }
            _vestingOf[account].amount += amount;
            emit VestingEntryUpdated(
                account,
                _vestingOf[account].amount,
                _vestingOf[account].start,
                _vestingOf[account].lockup,
                _vestingOf[account].cliff,
                _vestingOf[account].vesting
            );
        }

        _transfer(from, account, amount);
        emit Airdrop(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (_isVested(from)) {
            uint256 lockedAmount = _lockedOf(from);
            if (lockedAmount == 0) {
                delete _vestingOf[from];
            } else {
                require(
                    (balanceOf(from) - amount) >= lockedAmount,
                    "Transfer amount exceeds locked amount"
                );
            }
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}




interface IRecoverable {
    event RecoveredFunds(
        address indexed token,
        uint256 amount,
        address indexed recipient
    );

    function recoverFunds(
        address token,
        uint256 amount,
        address recipient
    ) external returns (bool);
}





abstract contract Recoverable is Ownable, IRecoverable {
    function _getRecoverableAmount(address token)
        internal
        view
        virtual
        returns (uint256)
    {
        if (token == address(0)) return address(this).balance;
        else return IERC20(token).balanceOf(address(this));
    }

    function recoverFunds(
        address token,
        uint256 amount,
        address recipient
    ) external override onlyOwner returns (bool) {
        uint256 recoverableAmount = _getRecoverableAmount(token);
        require(
            amount <= recoverableAmount,
            "Recoverable: RECOVERABLE_AMOUNT_NOT_ENOUGH"
        );
        if (token == address(0)) _transferEth(amount, recipient);
        else _transferErc20(token, amount, recipient);
        emit RecoveredFunds(token, amount, recipient);
        return true;
    }

    function _transferEth(uint256 amount, address recipient) private {
        address payable toPayable = payable(recipient);
        toPayable.transfer(amount);
    }

    function _transferErc20(
        address token,
        uint256 amount,
        address recipient
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, recipient, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Recoverable: TRANSFER_FAILED"
        );
    }
}




interface ITransferBatch {
    function transferBatch(address[] memory accounts, uint256[] memory amounts)
        external
        returns (bool);

    function transferBatchFrom(
        address from,
        address[] memory accounts,
        uint256[] memory amounts
    ) external returns (bool);
}





abstract contract TransferBatch is ERC20, ITransferBatch {
    modifier checkMismatch(
        address[] memory accounts,
        uint256[] memory amounts
    ) {
        require(accounts.length == amounts.length, "Mismatch");
        _;
    }

    function transferBatch(address[] memory accounts, uint256[] memory amounts)
        external
        override
        checkMismatch(accounts, amounts)
        returns (bool)
    {
        address from = _msgSender();
        for (uint256 i = 0; i < accounts.length; i++) {
            _transfer(from, accounts[i], amounts[i]);
        }
        return true;
    }

    function transferBatchFrom(
        address from,
        address[] memory accounts,
        uint256[] memory amounts
    ) external override checkMismatch(accounts, amounts) returns (bool) {
        address spender = _msgSender();
        for (uint256 i = 0; i < accounts.length; i++) {
            _spendAllowance(from, spender, amounts[i]);
            _transfer(from, accounts[i], amounts[i]);
        }
        return true;
    }
}



pragma solidity 0.8.14;


contract WebMasonCoin is
    ERC20,
    ERC20Permit,
    Ownable,
    Vesting,
    Recoverable,
    TransferBatch
{
    constructor() ERC20("WebMasonCoin", "WMC") ERC20Permit("WebMasonCoin") {
        _mint(_msgSender(), 10_000_000_000 * 10**decimals());
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, Vesting) {
        super._beforeTokenTransfer(from, to, amount);
    }
}