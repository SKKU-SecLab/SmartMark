



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}




pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}




pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}




pragma solidity ^0.6.0;


contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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


pragma solidity >=0.5.0 <0.7.0;




abstract contract ERC20DecentrToken {
    function mintToken(address to, uint256 value) external virtual returns (bool success);

    function pause() external virtual;

    function unpause() external virtual;
}

contract DecentrSaleContract is Ownable, Pausable {
    uint256 private _maxMintable = 10**27;

    uint256 private _totalMinted;

    uint private _startBlock;
    uint private _lastBlock;

    uint private _exchangeRate;

    address payable private ETHWallet;

    ERC20DecentrToken public DecentrToken;
    bool private tokenInitialized;

    struct TimeLockedTokenInfo {
        uint256 tokensAmount;
        uint releaseDate;
        uint createdAt;
        bool isEntity; // Represents check for whether struct exists.
    }

    mapping(address => TimeLockedTokenInfo) private timeLockedTokens;

    bool private _initializationCompleted = false;

    event ExchangeRateUpdate(uint amountOfTokensForEthereum);
    event TimeLockedTokensRelease(address to, uint256 tokensAmount);
    event Contribution(address from, uint256 amount);
    event ContractStateUpdated(bool isPaused);

    constructor () public {
        closeTrade();

        _startBlock = block.number;
    }

    function registerTimeLockedTokens(address receiver, uint tokensAmount, uint releaseDate) public onlyOwner returns (bool success) {

        require(receiver != address(0), 'DecentrSaleContract: Receiver address must not be empty.');
        require(tokensAmount > 0, 'DecentrSaleContract: Tokens amount should be defined.');
        require(releaseDate >= now, 'DecentrSaleContract: Release date should be in future.');

        uint256 total = _totalMinted + tokensAmount;

        require(total <= _maxMintable, 'DecentrSaleContract: Amount of tokens to be minted exceeds the max tokens allowed amount.');

        timeLockedTokens[receiver] = TimeLockedTokenInfo(tokensAmount, releaseDate, now, true);

        _totalMinted += tokensAmount;

        return true;
    }

    function canReceiveTimeLockedTokens() public view returns (bool canReceive) {
        return _canReleaseTimeLockedTokens(msg.sender);
    }

    function canReleaseTimeLockedTokens(address receiver) public view onlyOwner returns (bool canRelease) {
        return _canReleaseTimeLockedTokens(receiver);
    }

    function _canReleaseTimeLockedTokens(address receiver) private view returns (bool canRelease) {
        TimeLockedTokenInfo memory timeLockedTokenInfo = timeLockedTokens[receiver];

        require(isValidTimeLockedTokenInfo(timeLockedTokenInfo), 'DecentrSaleContract: There are no time locked tokens for current address');

        return timeLockedTokenInfo.releaseDate <= now;
    }

    function receiveTimeLockedTokens() public returns (bool success) {
        return _releaseTimeLockedTokensForAddress(msg.sender);
    }

    function releaseTimeLockedTokensForAddress(address receiver) public onlyOwner returns (bool success) {
        return _releaseTimeLockedTokensForAddress(receiver);
    }

    function _releaseTimeLockedTokensForAddress(address receiver) private returns (bool success) {

        TimeLockedTokenInfo memory timeLockedTokenInfo = timeLockedTokens[receiver];

        require(isValidTimeLockedTokenInfo(timeLockedTokenInfo), 'DecentrSaleContract: There are no time locked tokens for address');
        require(timeLockedTokenInfo.releaseDate <= now);

        DecentrToken.mintToken(receiver, timeLockedTokenInfo.tokensAmount);

        TimeLockedTokensRelease(receiver, timeLockedTokenInfo.tokensAmount);

        delete timeLockedTokens[receiver];

        _lastBlock = block.number;

        return true;
    }

    function removeTimeLockedTokensForAddress(address receiver) public onlyOwner returns (bool success) {
        TimeLockedTokenInfo memory timeLockedTokenInfo = timeLockedTokens[receiver];

        require(isValidTimeLockedTokenInfo(timeLockedTokenInfo), 'DecentrSaleContract: There are no time locked tokens for receiver address.');

        _totalMinted -= timeLockedTokenInfo.tokensAmount;

        delete timeLockedTokens[receiver];

        return true;
    }

    function getTimeLockedTokens() public view returns (uint256 tokensAmount, uint releaseDate, bool canBeReleased) {
        return (timeLockedTokens[msg.sender].tokensAmount, timeLockedTokens[msg.sender].releaseDate, timeLockedTokens[msg.sender].releaseDate <= now);
    }

    function getTimeLockedTokensForAddress(address _address) public view onlyOwner returns (uint256 tokensAmount, uint releaseDate, uint createdAt, bool canBeReleased) {
        return (timeLockedTokens[_address].tokensAmount, timeLockedTokens[_address].releaseDate, timeLockedTokens[_address].createdAt, timeLockedTokens[msg.sender].releaseDate <= now);
    }

    function setup(address tokenAddress) public pendingInitialization {
        DecentrToken = ERC20DecentrToken(tokenAddress);

        _initializationCompleted = true;
    }

    function setExchangeRate(uint exchangeRate) public onlyOwner whenNotPaused {
        _exchangeRate = exchangeRate;

        ExchangeRateUpdate(exchangeRate);
    }

    function pauseToken() public onlyOwner {
        DecentrToken.pause();
    }

    function unpauseToken() public onlyOwner {
        DecentrToken.unpause();
    }

    function closeTrade() public onlyOwner whenNotPaused {
        _pause();

        ContractStateUpdated(true);
    }

    function openTrade() public onlyOwner whenPaused {
        _unpause();

        ContractStateUpdated(false);
    }

    function startBlock() public view returns (uint) {
        return _startBlock;
    }

    function lastBlock() public view returns (uint) {
        return _lastBlock;
    }

    function setICOWallet(address payable _wallet) public onlyOwner returns (bool isSet) {
        ETHWallet = _wallet;

        return true;
    }

    function getICOWallet() public view returns (address icoWallet) {
        return ETHWallet;
    }

    function isValidTimeLockedTokenInfo(TimeLockedTokenInfo memory timeLockedTokenInfo) private pure returns (bool isValid) {
        return timeLockedTokenInfo.isEntity;
    }

    modifier pendingInitialization() {
        require(!_initializationCompleted, 'DecentrSaleContract: Initialization is already completed.');
        _;
    }

    modifier initializationCompleted() {
        require(_initializationCompleted, 'DecentrSaleContract: Initialization is not completed.');
        _;
    }

    function buyToken() external payable {
        _buyToken();
    }

    function _buyToken() private whenNotPaused initializationCompleted {
        require(msg.value > 0);

        uint256 amount = msg.value * _exchangeRate;

        uint256 total = _totalMinted + amount;

        require(total <= _maxMintable, 'DecentrSaleContract: Amount of tokens to be minted exceeds the max tokens allowed amount.');

        _totalMinted += total;

        ETHWallet.transfer(msg.value);

        DecentrToken.mintToken(msg.sender, amount);

        Contribution(msg.sender, amount);

        _lastBlock = block.number;
    }

    receive() external payable {
        _buyToken();
    }

    fallback() external payable {
        _buyToken();
    }
}