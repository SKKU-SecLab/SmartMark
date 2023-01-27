
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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;


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
}// contracts/Peach.sol
pragma solidity 0.8.9;



contract Peach is ERC20, Pausable, Ownable {
    uint256 public constant RESERVE = 6727500 ether;
    uint256 public constant MAX_SUPPLY = 250000000 ether;
    uint256 public constant WUKONG_DAILY_REWARD = 20 ether;
    uint256 public constant BAEPE_DAILY_REWARD = 10 ether;

    uint256 public constant NUM_WUKONGS = 2222;
    uint256 public constant NUM_BAEPES = 2221;

    address public authSigner;

    mapping(uint256 => uint256) public stakedTime;
    mapping(uint256 => address) public staker;

    event AuthSignerSet(address indexed newSigner);

    constructor(address _authSigner) ERC20("PEACH", "PEACH") {
        require(_authSigner != address(0), "Invalid addr");
        authSigner = _authSigner;
        _mint(msg.sender, RESERVE);
        stakedTime[
            0
        ] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setAuthSigner(address _authSigner) external onlyOwner {
        require(_authSigner != address(0), "Invalid addr");
        authSigner = _authSigner;
        emit AuthSignerSet(_authSigner);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "Token paused");
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= MAX_SUPPLY, "MAX_SUPPLY");
        super._mint(account, amount);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65, "invalid sig");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function sendPrevEarnings(uint256 tokenId) private {
        _mint(staker[tokenId], claimable(tokenId));
    }

    function claim(uint256[] calldata tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(staker[tokenIds[i]] == msg.sender, "Access denied.");
            _mint(msg.sender, claimable(tokenIds[i]));
            stakedTime[tokenIds[i]] = block.timestamp - (block.timestamp - stakedTime[tokenIds[i]]) % 1 days;
        }
    }

    function claimable(uint256 tokenId) public view returns (uint256 sum) {
        if (stakedTime[tokenId] == 0) return 0;
        uint256 daysStaked = (block.timestamp - stakedTime[tokenId]) / 1 days;
        uint256 dailyReward = isBaepe(tokenId)
            ? BAEPE_DAILY_REWARD
            : WUKONG_DAILY_REWARD;
        sum = daysStaked * dailyReward;
    }

    function isBaepe(uint256 tokenId) internal pure returns (bool) {
        return tokenId > NUM_WUKONGS ? true : false;
    }

    function stake(
        uint256[] calldata tokenIds,
        uint256 ts,
        bytes memory sig
    ) external {
        bytes memory b = abi.encodePacked(tokenIds, msg.sender, ts);
        require(recoverSigner(keccak256(b), sig) == authSigner, "Invalid sig");
        require(ts <= block.timestamp, "Invalid ts");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(staker[tokenIds[i]] != msg.sender, "Staked");
            require(
                tokenIds[i] <= NUM_BAEPES + NUM_WUKONGS,
                "Invalid token id"
            );
            require(stakedTime[tokenIds[i]] < ts, "Time is a river");
            if (stakedTime[tokenIds[i]] > 0) sendPrevEarnings(tokenIds[i]);
            stakedTime[tokenIds[i]] = ts;
            staker[tokenIds[i]] = msg.sender;
        }
    }

    function listStakedTokens(address wallet)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256 count = countStakedTokens(wallet);
        uint256[] memory staked = new uint256[](count);
        uint256[] memory stakeTimes = new uint256[](count);
        uint256 j;
        for (uint256 i = 0; i <= NUM_BAEPES + NUM_WUKONGS; i++) {
            if (staker[i] == wallet) {
                staked[j] = i;
                stakeTimes[j++] = stakedTime[i];
            }
        }
        return (staked, stakeTimes);
    }

    function countStakedTokens(address wallet)
        public
        view
        returns (uint256 count)
    {
        count = 0;
        for (uint256 i = 0; i <= NUM_BAEPES + NUM_WUKONGS; i++) {
            if (staker[i] == wallet) count++;
        }
    }
}