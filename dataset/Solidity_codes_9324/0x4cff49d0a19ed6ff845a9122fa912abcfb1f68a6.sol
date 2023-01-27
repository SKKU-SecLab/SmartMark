

pragma solidity 0.8.0;

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

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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


contract WadzPayToken is Context, IERC20, IERC20Metadata, Ownable {

    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;


    mapping(address => bool) public blackList;
    mapping(address => uint256) private lastTxTimestamp;
    bool private antibotPaused = true;

    struct WhitelistRound {
        uint256 duration;
        uint256 amountMax;
        mapping(address => bool) addresses;
        mapping(address => uint256) purchased;
    }

    WhitelistRound[] public _tgeWhitelistRounds;

    uint256 public _tgeTimestamp;
    address public _tgePairAddress;

    uint256 private maxTxPercent = 100;
    uint256 private transferDelay = 0;

    constructor() {
        _name = "WadzPay Token";
        _symbol = "WTK";
        _mint(msg.sender, 250000000 * (10**uint256(decimals())));
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

    function mint(address account, uint256 amount) public onlyOwner {

        _mint(account, amount * (10**uint256(decimals())));
    }

    function destroy(address account, uint256 amount) public onlyOwner {

        _burn(account, amount * (10**uint256(decimals())));
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (!antibotPaused) {
            if (sender != owner() && recipient != owner()) {
                require(
                    amount <= (totalSupply() * maxTxPercent) / 100,
                    "Overflow max transfer amount"
                );
            }
            require(!blackList[sender], "Blacklisted seller");
            _applyTGEWhitelist(sender, recipient, amount);
            lastTxTimestamp[recipient] = block.timestamp;
        }

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

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

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


    function addBlackList(address _bot) external onlyOwner {

        blackList[_bot] = true;
        emit AddedBlackList(_bot);
    }

    function removeBlackList(address _addr) external onlyOwner {

        blackList[_addr] = false;
        emit RemovedBlackList(_addr);
    }

    function destroyBlackFunds(address _blackListedUser) external onlyOwner {

        require(blackList[_blackListedUser], "This user is not a member of blacklist");
        uint dirtyFunds = balanceOf(_blackListedUser);
        _balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);



    function createTGEWhitelist(address pairAddress, uint256[] calldata durations, uint256[] calldata amountsMax) external onlyOwner {

        require(durations.length == amountsMax.length, "Invalid whitelist(s)");

        _tgePairAddress = pairAddress;

        if(durations.length > 0) {

            delete _tgeWhitelistRounds;
            
            for (uint256 i = 0; i < durations.length; i++) {
                _tgeWhitelistRounds.push();
                WhitelistRound storage wlRound = _tgeWhitelistRounds[i];
                wlRound.duration = durations[i];
                wlRound.amountMax = amountsMax[i];
            }

        }
    }


    function modifyTGEWhitelist(uint256 index, uint256 duration, uint256 amountMax, address[] calldata addresses, bool enabled) external onlyOwner {

        require(index < _tgeWhitelistRounds.length, "Invalid index");
        require(amountMax > 0, "Invalid amountMax");

        if(duration != _tgeWhitelistRounds[index].duration)
            _tgeWhitelistRounds[index].duration = duration;

        if(amountMax != _tgeWhitelistRounds[index].amountMax)
            _tgeWhitelistRounds[index].amountMax = amountMax;

        for (uint256 i = 0; i < addresses.length; i++) {
            _tgeWhitelistRounds[index].addresses[addresses[i]] = enabled;
        }
    }


    function getTGEWhitelistRound() public view returns (uint256, uint256, uint256, uint256, bool, uint256) {


        if(_tgeTimestamp > 0) {

            uint256 wlCloseTimestampLast = _tgeTimestamp;

            for (uint256 i = 0; i < _tgeWhitelistRounds.length; i++) {

                WhitelistRound storage wlRound = _tgeWhitelistRounds[i];

                wlCloseTimestampLast = wlCloseTimestampLast + wlRound.duration;
                if(block.timestamp <= wlCloseTimestampLast)
                    return (i+1, wlRound.duration, wlCloseTimestampLast, wlRound.amountMax, wlRound.addresses[_msgSender()], wlRound.purchased[_msgSender()]);
            }

        }

        return (0, 0, 0, 0, false, 0);
    }


    function _applyTGEWhitelist(address sender, address recipient, uint256 amount) internal {


        if(_tgePairAddress == address(0) || _tgeWhitelistRounds.length == 0)
            return;

        if(_tgeTimestamp == 0 && sender != _tgePairAddress && recipient == _tgePairAddress && amount > 0)
            _tgeTimestamp = block.timestamp;

        if(sender == _tgePairAddress && recipient != _tgePairAddress) {

            (uint256 wlRoundNumber,,,,,) = getTGEWhitelistRound();

            if(wlRoundNumber > 0) {

                WhitelistRound storage wlRound = _tgeWhitelistRounds[wlRoundNumber-1];

                require(wlRound.addresses[recipient], "TGE - Buyer is not whitelisted");

                uint256 amountRemaining = 0;

                if(wlRound.purchased[recipient] < wlRound.amountMax)
                    amountRemaining = wlRound.amountMax - wlRound.purchased[recipient];

                require(amount <= amountRemaining, "TGE - Amount exceeds whitelist maximum");
                wlRound.purchased[recipient] = wlRound.purchased[recipient] + amount;

            }

        }

    }


    function setMaxTxPercent(uint256 _maxTxPercent) external onlyOwner {

        maxTxPercent = _maxTxPercent;
    }

    function setTransferDelay(uint256 _transferDelay) external onlyOwner {

        transferDelay = _transferDelay;
    }

    function setAntibotPaused(bool _antibotPaused) external onlyOwner {

        antibotPaused = _antibotPaused;
    }
}