
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


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}// MIT
pragma solidity 0.8.9;


contract LuckyCoin is ERC20Burnable {
    uint256 constant WEEKLY_INTEREST_RATE_X10000 = 25;

    uint256 constant WEEKLY_DEFLATION_RATE_X10000 = 25;

    uint256 constant MINIMUM_MINT_RATE_X100 = 1e2;

    uint256 constant MAXIMUM_MINT_RATE_X100 = 1e5;

    uint256 constant MAX_MINT_TOTAL_AMOUNT_RATE_X100 = 5;

    uint256 constant INITIAL_MINT_AMOUNT = 1e26;

    uint256 constant MINIMUM_TOTAL_SUPPLY = 1e24;

    uint256 constant RANDOM_MINT_MIN_INTERVAL = 1 weeks - 1 minutes;

    uint256 constant RANDOM_MINT_TIMEOUT = 1 days;

    uint256 constant RANDOM_MINT_MIN_TOTAL_ADDRESSES = 100;

    address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint8 constant RANDOM_NUM_BITS = 32;

    uint256 constant MAXIMUM_TRANSACTION_BURN_RATE_X10000 = 1000;

    uint256 constant MEAN_VOLUME_SMOOTHING_FACTOR_X10000 = 1000;

    uint256 constant MAXIMUM_SINGLE_TRADE_VOLUME_X10000 = 500;

    uint256 constant BURN_RATE_TIME_HORIZON_MULTIPLICATOR_X10000 = 9000;

    uint256 constant INITIAL_MEAN_WEEK_VOLUME_X10000 = 1500;

    uint256 constant MAXIMUM_WEEK_BURN_EXCESS_X10000 = 200;

    uint256 public totalAddresses;

    mapping(uint256 => address) private indexToAddress;

    mapping(address => uint256) private addressToIndex;

    uint256 public randomMintLastTimeStamp;

    uint256 public randomMintStartBlockNumber;

    uint256 public transactionBurnRateX10000;

    uint256 public currentWeekVolume;

    uint256 public currentWeekBurnAmount;

    uint256 public meanWeekVolumeX10000;

    uint256 public expectedSupply;

    uint256 public maximumWeekBurnAmount;

    constructor() ERC20("LuckyCoin", "LCK") {
        totalAddresses = 0;
        randomMintLastTimeStamp = 0;
        randomMintStartBlockNumber = 0;
        transactionBurnRateX10000 = 0;
        currentWeekVolume = 0;
        meanWeekVolumeX10000 = INITIAL_MEAN_WEEK_VOLUME_X10000;
        expectedSupply = INITIAL_MINT_AMOUNT;
        maximumWeekBurnAmount = 0;
        currentWeekBurnAmount = 0;
        _mint(msg.sender, INITIAL_MINT_AMOUNT);
    }

    function randomMintStart() external {
        require(
            block.timestamp >
                randomMintLastTimeStamp + RANDOM_MINT_MIN_INTERVAL,
            "You have to wait one week after the last random mint"
        );
        require(
            !(randomMintStartBlockNumber > 0),
            "Random mint already started"
        );
        require(
            randomMintLastTimeStamp > 0,
            "Minimum number of addresses has not been reached"
        );
        _randomMintStart();
    }

    function _randomMintStart() internal {
        randomMintLastTimeStamp = block.timestamp;
        randomMintStartBlockNumber = block.number;
    }

    function randomMintEnd() external {
        require(randomMintStartBlockNumber > 0, "Random mint not started");
        require(
            block.number > randomMintStartBlockNumber + RANDOM_NUM_BITS + 1,
            "You have to wait 32 blocks after start"
        );
        _randomMintEnd();
    }

    function _randomMintEnd() internal {
        randomMintStartBlockNumber = 0;

        if (block.timestamp < randomMintLastTimeStamp + RANDOM_MINT_TIMEOUT) {
            _randomMint();

            _updateBurnRate();
        }
    }

    function _updateBurnRate() internal {
        uint256 RealTotalSupply = realTotalSupply();

        meanWeekVolumeX10000 =
            (MEAN_VOLUME_SMOOTHING_FACTOR_X10000 * currentWeekVolume) /
            RealTotalSupply +
            ((10000 - MEAN_VOLUME_SMOOTHING_FACTOR_X10000) *
                meanWeekVolumeX10000) /
            10000;

        currentWeekVolume = 0;
        currentWeekBurnAmount = 0;

        expectedSupply = max(
            (expectedSupply * (10000 - WEEKLY_DEFLATION_RATE_X10000)) / 10000,
            MINIMUM_TOTAL_SUPPLY
        );

        if (RealTotalSupply > expectedSupply) {
            transactionBurnRateX10000 = min(
                (100000000 -
                    (BURN_RATE_TIME_HORIZON_MULTIPLICATOR_X10000 +
                        ((10000 - BURN_RATE_TIME_HORIZON_MULTIPLICATOR_X10000) *
                            expectedSupply) /
                        RealTotalSupply) *
                    (10000 -
                        WEEKLY_INTEREST_RATE_X10000 -
                        WEEKLY_DEFLATION_RATE_X10000)) /
                    max(meanWeekVolumeX10000, 1),
                MAXIMUM_TRANSACTION_BURN_RATE_X10000
            );
            maximumWeekBurnAmount =
                RealTotalSupply -
                expectedSupply +
                (expectedSupply * MAXIMUM_WEEK_BURN_EXCESS_X10000) /
                10000;
        } else {
            transactionBurnRateX10000 = 0;
            maximumWeekBurnAmount = 0;
        }
    }

    function _randomMint() internal {
        uint256 selectedIndex = generateSafePRNG(
            RANDOM_NUM_BITS,
            totalAddresses
        ) + 1;
        uint256 mintRateX100 = (totalAddresses * WEEKLY_INTEREST_RATE_X10000) /
            100;
        uint256 numSelected = (mintRateX100 - 1) /
            MAXIMUM_MINT_RATE_X100 +
            1;
        while (mintRateX100 > 0) {
            address selectedAddress = indexToAddress[selectedIndex];
            uint256 mintAmount = (balanceOf(selectedAddress) *
                min(
                    max(mintRateX100, MINIMUM_MINT_RATE_X100),
                    MAXIMUM_MINT_RATE_X100
                )) / 100;
            mintAmount = min(
                mintAmount,
                (realTotalSupply() * MAX_MINT_TOTAL_AMOUNT_RATE_X100) / 100
            );
            if (mintAmount > 0 && !isContract(selectedAddress))
                _mint(selectedAddress, mintAmount);
            selectedIndex += totalAddresses / numSelected;
            if (selectedIndex > totalAddresses) selectedIndex -= totalAddresses;
            mintRateX100 -= min(mintRateX100, MAXIMUM_MINT_RATE_X100);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (randomMintStartBlockNumber == 0) {
            if (
                block.timestamp >
                randomMintLastTimeStamp + RANDOM_MINT_MIN_INTERVAL &&
                randomMintLastTimeStamp > 0
            ) {
                _randomMintStart();
            }
        } else {
            if (
                block.number > randomMintStartBlockNumber + RANDOM_NUM_BITS + 1
            ) {
                _randomMintEnd();
            } else {
                if (block.number > randomMintStartBlockNumber)
                    revert(
                        "Random mint in progress, transactions are suspended"
                    );
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);

        if (amount == 0 || from == to) return;

        if (
            to != address(0) &&
            to != DEAD_ADDRESS &&
            balanceOf(to) == amount &&
            !isContract(to)
        ) {
            totalAddresses++;
            indexToAddress[totalAddresses] = to;
            addressToIndex[to] = totalAddresses;
            if (
                randomMintLastTimeStamp == 0 &&
                totalAddresses >= RANDOM_MINT_MIN_TOTAL_ADDRESSES
            ) {
                randomMintLastTimeStamp = block.timestamp;
                expectedSupply = realTotalSupply();
            }
        }

        if (
            from != address(0) && from != DEAD_ADDRESS && balanceOf(from) == 0
        ) {
            uint256 fromIndex = addressToIndex[from];
            if (fromIndex > 0) {
                address lastAddress = indexToAddress[totalAddresses];
                indexToAddress[fromIndex] = lastAddress;
                addressToIndex[lastAddress] = fromIndex;
                addressToIndex[from] = 0;
                totalAddresses--;
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 burnAmount = 0;
        if (currentWeekBurnAmount < maximumWeekBurnAmount) {
            burnAmount = (transactionBurnRateX10000 * amount) / 10000;
            if (currentWeekBurnAmount + burnAmount > maximumWeekBurnAmount)
                burnAmount = maximumWeekBurnAmount - currentWeekBurnAmount;
        }
        if (burnAmount > 0) _burn(from, burnAmount);
        super._transfer(from, to, amount - burnAmount);
        if (randomMintLastTimeStamp > 0) {
            currentWeekVolume += min(
                amount,
                (MAXIMUM_SINGLE_TRADE_VOLUME_X10000 * realTotalSupply()) / 10000
            );
            currentWeekBurnAmount += burnAmount;
        }
    }

    function realTotalSupply() public view returns (uint256) {
        return totalSupply() - balanceOf(DEAD_ADDRESS);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function generateSafePRNG(uint8 numBlocks, uint256 maxValue)
        internal
        view
        returns (uint256)
    {
        uint256 rnd = uint256(blockhash(block.number - numBlocks - 1)) <<
            numBlocks;
        for (uint8 i = 0; i < numBlocks; i++)
            rnd |= (uint256(blockhash(block.number - i - 1)) & 0x01) << i;
        rnd = uint256(keccak256(abi.encodePacked(rnd)));
        return rnd - maxValue * (rnd / maxValue);
    }

    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

}