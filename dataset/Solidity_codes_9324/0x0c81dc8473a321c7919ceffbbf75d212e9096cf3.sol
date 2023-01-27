
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
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


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
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

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity ^0.8.0;


contract GoldBux is ERC20, ERC20Burnable, Ownable {
    using ECDSA for bytes32;
    using SafeMath for uint256;

    event Claimed(address account, uint256 amount);
    event Deposited(address account, uint256 amount);
    event Airdropped(address account, uint256 amount);
    event Burned(uint256 amount);

    address public claimSigner;

    uint256 public buyTax = 5;
    uint256 public sellTax = 10;
    bool public taxEnabled = false;
    mapping(address => bool) private taxExempt;
    mapping(address => bool) private dexPairs;
    uint256 public collectedTax = 0;
    address public devWallet;

    bool public paused = false;
    bool public limitsEnabled = true;
    bool public tradingEnabled = false;
    uint256 public tradingStartBlock;
    bool public transferDelayEnabled = true;
    uint256 public maxTransactionAmount;
    uint256 public maxPerWallet;
    mapping(address => bool) private maxExempt;
    mapping(address => uint256) private lastTransferBlock;

    mapping(address => bool) private blacklisted;

    mapping(uint256 => bool) private usedNonces;

    constructor(address devAddress, address signer) ERC20("GoldBux", "GDBX") {
        devWallet = devAddress;
        claimSigner = signer;
        _mint(address(this), 1_750_000 * 1e18);
        _mint(devWallet, 750_000 * 1e18);

        taxExempt[address(this)] = true;
        taxExempt[devWallet] = true;
        maxExempt[address(this)] = true;
        maxExempt[devWallet] = true;

        maxTransactionAmount = totalSupply() * 30 / 10000; // 0.3%
        maxPerWallet = totalSupply() * 100 / 10000; // 1%
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function setSigner(address signer) external onlyOwner {
        claimSigner = signer;
    }

    function setDevWallet(address account) external onlyOwner {
        devWallet = account;
    }


    function claim(uint256 amount, uint256 nonce, uint256 expires, bytes memory signature) external {
        require(!paused, "Paused");
        require(!usedNonces[nonce], "Nonce already used");
        require(amount <= balanceOf(address(this)), "Not enough $GoldBux left");
        require(block.timestamp < expires, "Claim window expired");

        bytes32 msgHash = keccak256(abi.encodePacked(_msgSender(), nonce, expires, amount));
        require(isValidSignature(msgHash, signature), "Invalid signature");
        usedNonces[nonce] = true;

        _transfer(address(this), _msgSender(), amount);
        emit Claimed(_msgSender(), amount);
    }

    function isValidSignature(bytes32 hash, bytes memory signature) internal view returns (bool isValid) {
        bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return signedHash.recover(signature) == claimSigner;
    }

    function deposit(uint256 amount) external {
        require(!paused, "Paused");
        _transfer(_msgSender(), address(this), amount);
        emit Deposited(_msgSender(), amount);
    }

    function airdrop(address account, uint256 amount) external onlyOwner {
        _transfer(address(this), account, amount);
        emit Airdropped(account, amount);
    }

    function burnSupply(uint256 amount) external onlyOwner {
        _burn(address(this), amount);
        emit Burned(amount);
    }


    function setLimitsEnabled(bool enabled) external onlyOwner {
        limitsEnabled = enabled;
    }

    function startTrading() external onlyOwner {
        tradingEnabled = true;
        tradingStartBlock = block.number;
    }

    function pauseTrading() external onlyOwner {
        tradingEnabled = false;
    }

    function setMaxTransactionAmount(uint256 amount) external onlyOwner {
        require(amount >= ((totalSupply() * 2) / 1000), "Cannot set lower than 0.2%");
        maxTransactionAmount = amount;
    }

    function setMaxPerWallet(uint256 max) external onlyOwner {
        require(max >= ((totalSupply() * 2) / 1000), "Cannot set lower than 0.2%");
        maxPerWallet = max;
    }

    function addBlacklisted(address[] memory accounts) external onlyOwner {
        require(accounts.length > 0, "No accounts");
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklisted[accounts[i]] = true;
        }
    }

    function removeBlacklisted(address[] memory accounts) external onlyOwner {
        require(accounts.length > 0, "No accounts");
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklisted[accounts[i]] = false;
        }
    }

    function isBlacklisted(address account) public view virtual returns(bool) {
        return blacklisted[account];
    }

    function addMaxExempt(address[] memory accounts) external onlyOwner {
        require(accounts.length > 0, "No accounts");
        for (uint256 i = 0; i < accounts.length; i++) {
            maxExempt[accounts[i]] = true;
        }
    }

    function removeMaxExempt(address[] memory accounts) external onlyOwner {
        require(accounts.length > 0, "No accounts");
        for (uint256 i = 0; i < accounts.length; i++) {
            maxExempt[accounts[i]] = false;
        }
    }

    function isMaxExempt(address account) public view virtual returns(bool) {
        return maxExempt[account];
    }


    function setTax(bool enabled, uint256 buyPercentage, uint256 sellPercentage) external onlyOwner {
        require(buyPercentage <= 20, "Buy tax should be less than or equal 20%");
        require(sellPercentage <= 20, "Sell tax should be less than or equal 20%");
        taxEnabled = enabled;
        buyTax = buyPercentage;
        sellTax = sellPercentage;
    }

    function addTaxExempt(address[] memory accounts) external onlyOwner {
        require(accounts.length > 0, "No accounts");
        for (uint256 i = 0; i < accounts.length; i++) {
            taxExempt[accounts[i]] = true;
        }
    }

    function removeTaxExempt(address[] memory accounts) external onlyOwner {
        require(accounts.length > 0, "No accounts");
        for (uint256 i = 0; i < accounts.length; i++) {
            taxExempt[accounts[i]] = false;
        }
    }

    function isTaxExempt(address account) public view virtual returns(bool) {
        return taxExempt[account];
    }

    function setDexPair(address pair, bool enabled) external onlyOwner {
        dexPairs[pair] = enabled;
    }

    function isDexPairEnabled(address pair) public view virtual returns(bool) {
        return dexPairs[pair];
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(to != address(0xdead), "Transfer to dead address");
        require(balanceOf(from) >= amount, "Transfer amount exceeds balance");
        require(!blacklisted[from] && !blacklisted[to], "Blacklisted");

        if (limitsEnabled && from != owner() && to != owner()) {
            if (!tradingEnabled) {
                require(taxExempt[from] || taxExempt[to], "Trading is not active");
            }

            require(block.number > tradingStartBlock, "0 block blackslist");

            if (transferDelayEnabled && !dexPairs[to]) {
                require(lastTransferBlock[tx.origin] < block.number, "One purchase per block allowed");
                lastTransferBlock[tx.origin] = block.number;
            }

            if (dexPairs[from] && !maxExempt[to]) {
                require(amount <= maxTransactionAmount, "Amount exceeds the max");
                require(amount + balanceOf(to) <= maxPerWallet, "Max per wallet exceeded");
            }
            else if (dexPairs[to] && !maxExempt[from]) {
                require(amount <= maxTransactionAmount, "Amount exceeds the max");
            }
            else if (!maxExempt[to]) {
                require(amount + balanceOf(to) <= maxPerWallet, "Max per wallet exceeded");
            }
        }

        if (taxEnabled) {
            uint256 tax = 0;
            if (dexPairs[from] && !taxExempt[to] && buyTax > 0) {
                tax = amount.mul(buyTax).div(100);
            }
            else if (dexPairs[to] && !taxExempt[from] && sellTax > 0) {
                tax = amount.mul(sellTax).div(100);
            }

            if (tax > 0) {
                super._transfer(from, address(this), tax);
                amount -= tax;
                collectedTax += tax;
            }
        }

        super._transfer(from, to, amount);
    }

    function withdrawTax() external onlyOwner {
        require(collectedTax > 0, "No tax to withdraw");
        require(devWallet != address(0), "Dev wallet not set");
        super._transfer(address(this), devWallet, collectedTax);
        collectedTax = 0;
    }
}