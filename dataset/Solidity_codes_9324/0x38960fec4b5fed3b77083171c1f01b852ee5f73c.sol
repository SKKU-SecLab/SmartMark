


pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


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

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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

}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract IERC865 {
    event TransferPreSigned(
        address indexed from,
        address indexed to,
        address indexed delegate,
        uint256 value,
        uint256 fee
    );

    function transferPreSigned(
        bytes memory signature,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 nonce
    ) public virtual returns (bool);
}

library ECDSA {
    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
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
            s := and(
                vs,
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
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
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }
}

abstract contract ERC20LockableStandard is
    ERC20Burnable,
    Ownable,
    Pausable,
    IERC865
{
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    uint256 _totalLockuped;
    mapping(address => uint256) private _lockupBalances;

    function totalLockuped() public view returns (uint256) {
        return _totalLockuped;
    }

    function lockupedBalanceOf(address account) public view returns (uint256) {
        return _lockupBalances[account];
    }

    function payableBalanceOf(address account) public view returns (uint256) {
        return super.balanceOf(account) - lockupedBalanceOf(account);
    }

    event IncreaseLockup(address indexed to, uint256 value);
    event DecreaseLockup(address indexed to, uint256 value);

    function increaseLockup(address account, uint256 addedValue)
        public
        onlyOwner
        returns (uint256)
    {
        require(
            payableBalanceOf(account) >= addedValue,
            "LIBEAR: increase amount exceeds balance"
        );

        _lockupBalances[account] += addedValue;
        _totalLockuped += addedValue;

        emit IncreaseLockup(account, addedValue);

        return _lockupBalances[account];
    }

    function decreaseLockup(address account, uint256 subtractedValue)
        public
        onlyOwner
        returns (uint256)
    {
        require(
            lockupedBalanceOf(account) >= subtractedValue,
            "LIBEAR: decrease amount exceeds lockup balance"
        );

        _lockupBalances[account] -= subtractedValue;
        _totalLockuped -= subtractedValue;

        emit DecreaseLockup(account, subtractedValue);
        return _lockupBalances[account];
    }

    function deliverPreSales(
        address[] calldata accounts,
        uint256[] calldata amounts
    ) public onlyOwner returns (bool) {
        require(accounts.length == amounts.length);

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) totalAmount += amounts[i];
        require(totalAmount <= super.balanceOf(_msgSender()));

        for (uint256 i = 0; i < accounts.length; i++) {
            transfer(accounts[i], amounts[i]);
            increaseLockup(accounts[i], amounts[i]);
        }

        return true;
    }

    function lockupExpirations(
        address[] calldata accounts,
        uint256[] calldata amounts
    ) public onlyOwner returns (bool) {
        require(
            accounts.length == amounts.length,
            "LIBEAR: The lengths of accounts and amounts are different."
        );
        for (uint256 i = 0; i < amounts.length; i++)
            require(
                lockupedBalanceOf(accounts[i]) >= amounts[i],
                "LIBEAR: decrease amount exceeds lockup balance"
            );

        for (uint256 i = 0; i < accounts.length; i++)
            decreaseLockup(accounts[i], amounts[i]);

        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(
            payableBalanceOf(_msgSender()) >= amount,
            "LIBEAR: transfer amount exceeds balance"
        );

        super.transfer(recipient, amount);
        return true;
    }

    mapping(bytes => bool) signatures;
    mapping(address => uint256) nonces;

    function transferPreSigned(
        bytes memory signature,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 nonce
    ) public override returns (bool) {
        require(to != address(0), "LIBEAR: Invalid _to address");
        require(
            signatures[signature] == false,
            "LIBEAR: signature hash was already used"
        );

        bytes32 preSignedHashedMessage = getEthSignedMessage(
            address(this),
            to,
            amount,
            fee,
            nonce
        );
        address from = ECDSA.recover(preSignedHashedMessage, signature);

        require(from != address(0), "LIBEAR: Invalid from address recovered");
        require(
            payableBalanceOf(from) >= amount + fee,
            "LIBEAR: amount exceeds payable balance."
        );
        require(
            nonce > nonces[_msgSender()],
            "LIBEAR: It's an old version of the transaction."
        );

        signatures[signature] = true;
        nonces[_msgSender()] = nonce;

        _transfer(from, to, amount);
        _transfer(from, msg.sender, fee);

        emit TransferPreSigned(from, to, msg.sender, amount, fee);
        return true;
    }

    function getTransferPreSignedHash(
        address token,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 nonce
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    bytes4(0x0d98dcb1),
                    token,
                    to,
                    amount,
                    fee,
                    nonce
                )
            );
    }

    function getEthSignedMessage(
        address token,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 nonce
    ) private pure returns (bytes32) {
        bytes32 hashedMessage = getTransferPreSignedHash(
            token,
            to,
            amount,
            fee,
            nonce
        );
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    hashedMessage
                )
            );
    }
}

contract LiBear is ERC20LockableStandard {
    constructor() ERC20("LiBear", "LIBEAR") {
        _mint(_msgSender(), 2000000000 * (uint256(10)**18));
    }
}