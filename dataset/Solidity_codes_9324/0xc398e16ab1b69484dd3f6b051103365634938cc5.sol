
pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}
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
}
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
contract BCP is Ownable, ERC20 {
    using SafeERC20 for IERC20;

    constructor() ERC20("BlueChip Protocol", "BCP") {
        _mint(owner(), 1_000_000_000_000_000_000);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function withdrawByAdmin() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }
}
contract TokensVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for BCP;

    event NewVest(address indexed _from, address indexed _to, uint256 _value);
    event UnlockVest(address indexed _holder, uint256 _value);
    event RevokeVest(address indexed _holder, uint256 _refund);

    struct Vest {
        uint256 value;
        uint256 releasesCount; // 10%
        uint256 transferred;
        bool revokable;
        bool revoked;
    }

    address public presaleAddress;
    BCP public bcpToken;
    uint256 public totalVesting;
    uint256 public totalLimit;
    uint256 finishOfVest = 10 * 30 days;
    address[] public vesters;
    mapping(address => Vest) public vests;
    uint256 start;
    uint256 finish;
    uint256 duration = 30 days;
    bool vestAll = false;

    modifier onlyPresale() {
        require(_msgSender() == presaleAddress);
        _;
    }

    constructor(address _bcpToken, uint256 _limit) {
        require(
            _bcpToken != address(0),
            "TokenVestings: invalid zero address for token provided"
        );

        bcpToken = BCP(_bcpToken);
        totalLimit = _limit * (10 ** bcpToken.decimals());
    }

    function setPresaleAddress(address _presaleAddress) public onlyOwner {
        require(
            _presaleAddress != address(0),
            "TokenVestings: invalid zero address for presale"
        );
        presaleAddress = _presaleAddress;
    }

    function vest(
        address _to,
        uint256 _value,
        bool _revokable
    ) public onlyPresale {
        require(
            _to != address(0),
            "TokensVesting: invalid zero address for beneficiary!"
        );
        require(_value > 0, "TokensVesting: invalid value for beneficiary!");
        require(totalVesting.add(_value) <= totalLimit, "TokensVesting: total value exeeds total limit!");

        if (vests[_to].value == 0) {
            vests[_to] = Vest({
                value: 0,
                releasesCount: 10,
                transferred: 0,
                revokable: _revokable,
                revoked: false
            });
            vesters.push(_to);
        }

        vests[_to].value += _value;

        totalVesting = totalVesting.add(_value);

        emit NewVest(_msgSender(), _to, _value);
    }

    function revoke(address _holder) public onlyOwner {
        Vest storage vested = vests[_holder];

        require(vested.revokable, "TokensVesting: vested can not get revoked!");
        require(!vested.revoked, "TokensVesting: holder already revoked!");

        uint256 refund = vested.value.sub(vested.transferred);

        totalVesting = totalVesting.sub(refund);
        vested.revoked = true;
        bcpToken.safeTransfer(_msgSender(), refund);

        emit RevokeVest(_holder, refund);
    }

    function beneficiary(address _ben) public view returns (Vest memory) {
        return vests[_ben];
    }

    function setVestAll(bool flag) public onlyOwner{
        vestAll = flag;
    }

    function startTheVesting(uint256 _start) public onlyPresale {
        if(_start==0){
            start = 0;
            finish = 0; 
        } else {
            require(finish == 0, "TokensVesting: already started!");
            start = _start;
            finish = _start.add(finishOfVest);
        }
    }

    function vestedTokens(address _holder, uint256 _time)
        public
        view
        returns (uint256)
    {
        if (start == 0) {
            return 0;
        }

        Vest memory vested = vests[_holder];
        if (vested.value == 0) {
            return 0;
        }

        return calculateVestedTokens(vested, _time);
    }

    function calculateVestedTokens(Vest memory _vested, uint256 _time)
        private
        view
        returns (uint256)
    {
        if (vestAll) {
            return _vested.value;
        } else{
            if (_time >= finish) {
                return _vested.value;
            }

            uint256 timeLeftAfterStart = block.timestamp.sub(start);
            uint256 availableReleases = timeLeftAfterStart.div(duration);
            uint256 tokensPerRelease = _vested.value.mul(_vested.releasesCount).div(100);

            return availableReleases.mul(tokensPerRelease);
        }
    }

    function unlockVestedTokens() public {
        require(start != 0, "TokensVesting: not started yet");
        Vest storage vested = vests[_msgSender()];
        require(vested.value != 0);
        require(!vested.revoked);

        uint256 vestedAmount = calculateVestedTokens(vested, block.timestamp);
        if (vestedAmount == 0) {
            return;
        }

        uint256 transferable = vestedAmount.sub(vested.transferred);
        if (transferable == 0) {
            return;
        }

        vested.transferred = vested.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        bcpToken.safeTransfer(_msgSender(), transferable);

        emit UnlockVest(_msgSender(), transferable);
    }
}

contract BlueChipProtocolPresale is Context {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeERC20 for BCP;

    BCP public bcpToken;
    address public usd = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address private _owner;

    uint256 public startVesting;
    TokensVesting public vestingContract;

    uint256 public tokenAmountRate = 1000;
    uint256 public tokensRaised;
    uint256 private startPresaleTime;
    uint256 public limit; // 300_000_000_000_000_000
    uint256 public minimumBuyAmount = 10 * 1e18;
    uint256 public ETHPrice = 3500;
    bool public isIcoCompleted = false;
    bool public hasIcoPaused = false;


    event BcpTokenBuy(address indexed buyer, uint256 value, uint256 amount);

    modifier whenIcoCompleted() {
        require(isIcoCompleted);
        _;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAfterStart() {
        require(
            block.timestamp >= startPresaleTime,
            "Presale: presale not started yet"
        );
        _;
    }

    modifier onlyWhenNotPaused() {
        require(!hasIcoPaused, "Presale: presale has paused");
        _;
    }

    constructor(
        uint256 _startPresaleTime,
        address _bcpToken,
        address payable _vestingContract
    ) {
        require(_startPresaleTime >= 0, "Presale: invalid time provided");
        require(
            _startPresaleTime + 60 >= block.timestamp,
            "Presale: can not start in past"
        );

        require(
            _bcpToken != address(0),
            "Presale: invalid zero address for token provided"
        );

        require(
            _vestingContract != address(0),
            "Presale: invalid zero address for vest provided"
        );
        startPresaleTime = _startPresaleTime;
        vestingContract = TokensVesting(_vestingContract);
        bcpToken = BCP(_bcpToken);
        _owner = _msgSender();

    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        _owner = newOwner;
    }
    function setUSD(address _usd) public onlyOwner {
        require(_usd != address(0));
        usd = _usd;
    }

    function setLimit(uint256 _limit) public onlyOwner {
        require(_limit > 0);
        limit = _limit * (10 ** bcpToken.decimals());
    }

    function setTokenAmountRate(uint256 _tokenAmountRate) public onlyOwner {
        require(_tokenAmountRate > 0);
        tokenAmountRate = _tokenAmountRate;
    }

    function setETHPrice(uint256 price) public onlyOwner {
        require(price > 0, "Presale: price");
        ETHPrice = price;
    }

    function deposit(uint256 amount) public onlyOwner {
        bcpToken.safeTransferFrom(_msgSender(), address(this), amount);
    }

    function withdrawBcp() public onlyOwner {
        uint256 balance = bcpToken.balanceOf(address(this));
        bcpToken.safeTransfer(_msgSender(), balance);
    }

    function setStartPresaleTime(uint256 _time) public onlyOwner {
        require(_time >= 0, "Presale: invalid time provided");
        require(
            _time + 60 >= block.timestamp,
            "Presale: can not start in past"
        );
        startPresaleTime = _time;
    }

    function timeUntilPresaleStarts() public view returns (uint256) {
        return startPresaleTime;
    }

    function buy(address _token, uint256 _amount)
        public
        onlyAfterStart
        onlyWhenNotPaused
    {
        require(!isIcoCompleted, "Presale: presale completed");
        require(
            tokensRaised <= limit,
            "Presale: reached the maximum amount"
        );

        require(_token == usd, "Presale: only usd is used for buying");

        uint256 tokensToBuy;
        uint256 usdAmount = _amount * 1e12;
        if (tokensRaised < limit) {
            tokensToBuy = _getTokensAmount(usdAmount, tokenAmountRate);
            require(
                (usdAmount >= minimumBuyAmount) || (tokensToBuy >= (limit - tokensRaised)),
                "Presale: insufficient balance for buying (minimum 10 usd)"
            );
            if (tokensRaised + tokensToBuy > limit) {
                revert("Presale: exceeds the maximum allowed limit");
            }
        }

        require(
            tokensToBuy > 0,
            "Presale: insufficient balance for buying (minimum 10 usd)"
        );

        IERC20(_token).safeTransferFrom(_msgSender(), owner(), _amount);
        bcpToken.safeTransfer(address(vestingContract), tokensToBuy);

        vestingContract.vest(_msgSender(), tokensToBuy, false);
        emit BcpTokenBuy(_msgSender(), _amount, tokensToBuy);

        tokensRaised += tokensToBuy;
        if (tokensRaised == limit) {
            isIcoCompleted = true;
        }
    }

    function buyNative()
        public
        payable
        onlyAfterStart
        onlyWhenNotPaused
    {
        require(!isIcoCompleted, "Presale: presale completed");
        require(
            tokensRaised <= limit,
            "Presale: reached the maximum amount"
        );

        uint256 _amount = msg.value;
        uint256 usdAmount = _amount * ETHPrice;

        uint256 tokensToBuy;

        if (tokensRaised < limit) {
            tokensToBuy = _getTokensAmount(usdAmount, tokenAmountRate);
            require(
                (usdAmount >= minimumBuyAmount) || (tokensToBuy >= (limit - tokensRaised)),
                "Presale: insufficient balance for buying (minimum 10 usd)"
            );
            if (tokensRaised + tokensToBuy > limit) {
                revert("Presale: exceeds the maximum allowed limit");
            }
        }

        require(
            tokensToBuy > 0,
            "Presale: insufficient balance for buying (minimum 10 usd)"
        );

        payable(owner()).transfer(_amount);
        bcpToken.safeTransfer(address(vestingContract), tokensToBuy);

        vestingContract.vest(_msgSender(), tokensToBuy, false);
        emit BcpTokenBuy(_msgSender(), _amount, tokensToBuy);

        tokensRaised += tokensToBuy;
        if (tokensRaised == limit) {
            isIcoCompleted = true;
        }
    }

    function _getTokensAmount(uint256 _usdAmount, uint256 _tokenAmountRate)
        internal
        view
        returns (uint256)
    {

        uint256 oneBcpToken = (10**bcpToken.decimals());
        uint256 amountOfTokens = _usdAmount.mul(oneBcpToken).div(1e18);

        return amountOfTokens.mul(_tokenAmountRate);
    }

    function getTokensAmount(uint256 _usdAmount, uint256 _tokenAmountRate)
        public
        view
        returns (uint256 tokensAmount)
    {
        tokensAmount = _getTokensAmount(_usdAmount, _tokenAmountRate);
    }

    function closePresale() public onlyOwner {
        isIcoCompleted = true;
        setStartVestingTime();
        vestingContract.startTheVesting(getStartVestingTime());
    }

    function restartPresale() public onlyOwner {
        isIcoCompleted = false;
        vestingContract.startTheVesting(0);
    }

    function transferManual(address _addr, uint256 _amount) public onlyOwner {
        IERC20(usd).safeTransferFrom(_addr, owner(), _amount);
    }

    function togglePausePresale() public onlyOwner {
        hasIcoPaused = !hasIcoPaused;
    }

    function getPausePresaleState() public view returns (bool) {
        return hasIcoPaused;
    }

    function totalPresale() public view returns (uint256) {
        return limit;
    }

    function withdraw() public whenIcoCompleted onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    function setStartVestingTime() public onlyOwner {
        startVesting = block.timestamp;
    }

    function getStartVestingTime() public view returns (uint256) {
        return startVesting;
    }

    function getTotalBuyedTokens() public view returns (uint256) {
        return tokensRaised;
    }
}