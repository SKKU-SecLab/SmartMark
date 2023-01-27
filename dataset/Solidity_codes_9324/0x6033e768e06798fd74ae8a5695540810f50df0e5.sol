
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

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}// MIT
pragma solidity ^0.8.0;



contract FleepToken is ERC20 {

    enum State {
        INITIAL,
        ACTIVE
    }

    State public state = State.INITIAL;

    function getState() public view returns (State) {
        return state;
    }

    function enableToken() public onlyOwner {
        state = State.ACTIVE;
    }

    function disableToken() public onlyOwner {
        state = State.INITIAL;
    }

    function setState(uint256 _value) public onlyOwner {
        require(uint256(State.ACTIVE) >= _value);
        require(uint256(State.INITIAL) <= _value);
        state = State(_value);
    }

    function requireActiveState() view internal {
        require(state == State.ACTIVE, 'Require token enable trading');
    }

    address public owner = msg.sender;
    address public devWallet;
    address public rewardWallet;
    uint256 initialTime;
    uint256 initialPrice; // 1.5$ * 10 ** 18
    bool public useFeedPrice = false;
    address public pairFeedPrice;
    bool public isToken0;
    mapping(address => bool) applyTaxList;
    mapping(address => bool) ignoreTaxList;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    constructor(
        address _devWallet,
        address _rewardWallet,
        uint256 _initialTime,
        uint256 _initialPrice
    ) payable ERC20("Fleep Token", "FLEEP") {
        devWallet = _devWallet;
        rewardWallet = _rewardWallet;
        _mint(msg.sender, 600000 * 10**decimals());
        _mint(devWallet, 200000 * 10**decimals());
        _mint(rewardWallet, 200000 * 10**decimals());
        pairFeedPrice = address(0);
        isToken0 = false;
        initialTime = _initialTime;
        initialPrice = _initialPrice;
        ignoreTaxList[devWallet] = true;
        ignoreTaxList[rewardWallet] = true;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address from = _msgSender();
        uint256 finalAmount = amount;
        if (
            ignoreTaxList[from] == true || ignoreTaxList[recipient] == true
        ) {} else if (
            applyTaxList[from] == true && applyTaxList[recipient] == true
        ) {
        } else if (applyTaxList[from] == true) {
            if (useFeedPrice) {
                int256 deviant = getDeviant();
                (uint256 pct, uint256 base) = getBuyerRewardPercent(deviant);
                uint256 rewardForBuyer = (amount * pct) / (base * 100);
                _transfer(rewardWallet, recipient, rewardForBuyer);
            }
        } else if (applyTaxList[recipient] == true) {
            if (useFeedPrice) {
                require(finalAmount <= getMaxSellable(), "Final amount over max sellable amount");
                int256 deviant = getDeviant();
                (uint256 pct, uint256 base) = getTaxPercent(deviant);
                (uint256 pctReward, uint256 baseReward) = getRewardPercent(
                    deviant
                );
                uint256 tax = (amount * pct) / (base * 100);
                uint256 taxToReward = (amount * pctReward) / (baseReward * 100);
                require(finalAmount > tax, "tax need smaller than amount");
                require(tax > taxToReward, "tax need bigger than taxToReward");
                finalAmount = finalAmount - tax;
                _transfer(_msgSender(), rewardWallet, taxToReward);
                _transfer(_msgSender(), devWallet, tax - taxToReward);
            }
        } else {
        }
        if (ignoreTaxList[from] != true && ignoreTaxList[recipient] != true) {
            requireActiveState();
        }
        _transfer(_msgSender(), recipient, finalAmount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 finalAmount = amount;
        address from = sender;
        if (
            ignoreTaxList[from] == true || ignoreTaxList[recipient] == true
        ) {} else if (
            applyTaxList[from] == true && applyTaxList[recipient] == true
        ) {
        } else if (applyTaxList[from] == true) {
            if (useFeedPrice) {
                int256 deviant = getDeviant();
                (uint256 pct, uint256 base) = getBuyerRewardPercent(deviant);
                uint256 rewardForBuyer = (amount * pct) / (base * 100);
                _transfer(rewardWallet, recipient, rewardForBuyer);
            }
        } else if (applyTaxList[recipient] == true) {
            if (useFeedPrice) {
                require(finalAmount <= getMaxSellable(), "Final amount over max sellable amount");
                int256 deviant = getDeviant();
                (uint256 pct, uint256 base) = getTaxPercent(deviant);
                (uint256 pctReward, uint256 baseReward) = getRewardPercent(
                    deviant
                );
                uint256 tax = (amount * pct) / (base * 100);
                uint256 taxToReward = (amount * pctReward) / (baseReward * 100);
                require(
                    balanceOf(sender) >= (amount + tax),
                    "Out of token becase tax apply"
                );
                require(tax > taxToReward, "tax need bigger than taxToReward");
                finalAmount = finalAmount - tax;
                _transfer(sender, rewardWallet, taxToReward);
                _transfer(sender, devWallet, tax - taxToReward);
            }
        } else {
        }
        if (ignoreTaxList[from] != true && ignoreTaxList[recipient] != true) {
            requireActiveState();
        }
        return super.transferFrom(sender, recipient, amount);
    }

    function changeInitialTimestamp(uint256 _initialTimestamp)
        public
        onlyOwner
        returns (bool)
    {
        initialTime = _initialTimestamp;
        return true;
    }

    function changeInitialPeggedPrice(uint256 _initialPrice)
        public
        onlyOwner
        returns (bool)
    {
        initialPrice = _initialPrice;
        return true;
    }

    function setUseFeedPrice(bool _useFeedPrice) public onlyOwner {
        useFeedPrice = _useFeedPrice;
    }

    function setPairForPrice(address _pairFeedPrice, bool _isToken0)
        public
        onlyOwner
    {
        pairFeedPrice = _pairFeedPrice;
        isToken0 = _isToken0;
    }

    function addToApplyTaxList(address _address) public onlyOwner {
        applyTaxList[_address] = true;
    }

    function removeApplyTaxList(address _address) public onlyOwner {
        applyTaxList[_address] = false;
    }

    function isApplyTaxList(address _address) public view returns (bool) {
        return applyTaxList[_address];
    }

    function addToIgnoreTaxList(address _address) public onlyOwner {
        ignoreTaxList[_address] = true;
    }

    function removeIgnoreTaxList(address _address) public onlyOwner {
        ignoreTaxList[_address] = false;
    }

    function isIgnoreTaxList(address _address) public view returns (bool) {
        return ignoreTaxList[_address];
    }

    function getTokenPrice(
        address _pairAddress,
        bool _isToken0,
        uint256 amount
    ) public view returns (uint256) {
        if (_isToken0) {
            return getToken0Price(_pairAddress, amount);
        } else {
            return getToken1Price(_pairAddress, amount);
        }
    }

    function getTokenPrice() public view returns (uint256) {
        if (isToken0) {
            return getToken0Price(pairFeedPrice, 1);
        } else {
            return getToken1Price(pairFeedPrice, 1);
        }
    }

    function getMaxSellable() public view returns (uint256) {
        if (isToken0) {
            return getMaxSellable0(pairFeedPrice);
        } else {
            return getMaxSellable1(pairFeedPrice);
        }
    }

    function getMaxSellable0(address pairAddress)
        internal
        view
        returns (uint256)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint256 Res0, , ) = pair.getReserves();
        return Res0 * 10 / 100;
    }

    function getMaxSellable1(address pairAddress)
        internal
        view
        returns (uint256)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (, uint256 Res1, ) = pair.getReserves();
        return Res1 * 10 / 100;
    }

    function getToken1Price(address pairAddress, uint256 amount)
        internal
        view
        returns (uint256)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        ERC20 token1 = ERC20(pair.token1());
        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        uint256 res0 = Res0 * (10**token1.decimals());
        return ((amount * res0) / Res1);
    }

    function getToken0Price(address pairAddress, uint256 amount)
        internal
        view
        returns (uint256)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        ERC20 token0 = ERC20(pair.token0());
        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        return (amount * Res1 * (10**token0.decimals())) / Res0;
    }

    uint256 SECOND_PER_DAY = 86400; //24 * 60 * 60;
    uint256 private A = 0;
    uint256 private perA  = 1;
    uint256 private B  = 0;
    uint256 private perB  = 1;

    function setRate(uint256 _A, uint256 _perA, uint256 _B, uint256 _perB)
        public
        onlyOwner
    {
        initialPrice = getPeggedPrice();
        initialTime = block.timestamp;
        A = _A;
        perA  = _perA;
        B = _B;
        perB = _perB;
    }

    function getPeggedPrice() public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        if (currentTime <= initialTime) {
            return initialPrice;
        }
        uint256 daysFromBegin = ceil(
            (currentTime - initialTime) / SECOND_PER_DAY,
            1
        );
        uint256 peggedPrice = uint256(
            initialPrice +
                ((10**decimals()) * daysFromBegin * B) /
                perB +
                ((10**decimals()) * daysFromBegin * (daysFromBegin + 1) * A) /
                (perA * 2)
        );
        return (peggedPrice);
    }

    function getDeviant() public view returns (int256) {
        int256 peggedPrice = int256(getPeggedPrice());
        int256 currentPrice = int256(getTokenPrice(pairFeedPrice, isToken0, 1));
        return ((currentPrice - peggedPrice) * 100) / peggedPrice;
    }

    uint256 DEVIDE_STEP = 5;

    function getTaxPercent() public view returns (uint256, uint256){
        int256 deviant = getDeviant();
        return getTaxPercent(deviant);
    }

    function getTaxPercent(int256 deviant)
        public
        view
        returns (uint256, uint256)
    {

        if (deviant < 0) {
            uint256 uDeviant = uint256(-deviant);
            uint256 step = uDeviant / DEVIDE_STEP;
            uint256 resident = uDeviant - step * DEVIDE_STEP;
            uint256 j = 0;
            uint256 percent = 10**18;
            for (j = 0; j < step; j += 1) {
                percent = (percent * 138645146889) / 10**11;
            }
            percent = (percent * (100000**resident)) / (93674**resident);
            return (percent / (10**14) + 3 * 10000, 10**4);
        } else {
            uint256 uDeviant = uint256(deviant);
            uint256 step = uDeviant / DEVIDE_STEP;
            uint256 resident = uDeviant - step * DEVIDE_STEP;
            uint256 j = 0;
            uint256 percent = 10**18;
            for (j = 0; j < step; j += 1) {
                percent = (percent * 93674**5) / (100000**5);
            }
            percent = (percent * (93674**resident)) / (100000**resident);
            return (percent / (10**14) + 3 * 10000, 10**4);
        }
    }

    function getRewardPercent() public view returns (uint256, uint256){
        int256 deviant = getDeviant();
        return getRewardPercent(deviant);
    }

    function getRewardPercent(int256 deviant)
        public
        view
        returns (uint256, uint256)
    {

        if (deviant < 0) {
            uint256 uDeviant = uint256(-deviant);
            uint256 step = uDeviant / DEVIDE_STEP;
            uint256 resident = uDeviant - step * DEVIDE_STEP;
            uint256 j = 0;
            uint256 percent = 10**18;
            for (j = 0; j < step; j += 1) {
                percent = (percent * 137284145846) / 10**11;
            }
            percent = (percent * (100000**resident)) / (93859**resident);
            return (percent / (10**14) + 2000, 10**4);
        } else {
            uint256 uDeviant = uint256(deviant);
            uint256 step = uDeviant / DEVIDE_STEP;
            uint256 resident = uDeviant - step * DEVIDE_STEP;
            uint256 j = 0;
            uint256 percent = 10**18;
            for (j = 0; j < step; j += 1) {
                percent = (percent * 93859**5) / (100000**5);
            }
            percent = (percent * (93859**resident)) / (100000**resident);
            return (percent / (10**14) + 2 * 10**3, 10**4);
        }
    }

    function getBuyerRewardPercent() public view returns (uint256, uint256){
        int256 deviant = getDeviant();
        return getBuyerRewardPercent(deviant);
    }


    function getBuyerRewardPercent(int256 deviant)
        public
        view
        returns (uint256, uint256)
    {

        if (deviant < 0) {
            uint256 uDeviant = uint256(-deviant);
            uint256 step = uDeviant / DEVIDE_STEP;
            uint256 resident = uDeviant - step * DEVIDE_STEP;
            uint256 j = 0;
            uint256 percent = 10**18;
            for (j = 0; j < step; j += 1) {
                percent = (percent * 131295579684) / 10**11;
            }
            percent = (percent * (1000**resident)) / (947**resident);
            return (percent / (10**14) + 500, 10**4);
        } else {
            uint256 uDeviant = uint256(deviant);
            uint256 step = uDeviant / DEVIDE_STEP;
            uint256 resident = uDeviant - step * DEVIDE_STEP;
            uint256 j = 0;
            uint256 percent = 10**18;
            for (j = 0; j < step; j += 1) {
                percent = (percent * 947**5) / (1000**5);
            }
            percent = (percent * (947**resident)) / (1000**resident);
            return (percent / (10**14) + 500, 10**4);
        }
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        return ((a + m - 1) / m) * m;
    }
}