



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





pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}




pragma solidity ^0.8.0;

contract LuckyCoin is ERC20Burnable {
    uint256 constant WEEKLY_INTEREST_RATE_X10000 = 25;

    uint256 constant MINIMUM_MINT_RATE_X100 = 100;

    uint256 constant MAXIMUM_MINT_RATE_X100 = 100000;

    uint256 constant MAX_MINT_TOTAL_AMOUNT_RATE_X100 = 50;

    uint256 constant INITIAL_MINT_MAX_AMOUNT = 1e25;

    uint256 constant RANDOM_MINT_MIN_INTERVAL = 1 weeks - 10 minutes;

    uint256 constant RANDOM_MINT_DEFAULT_LAST_TIMESTAMP = 1640995200;

    uint8 constant RANDOM_NUM_BITS = 32;

    uint256 public totalAddresses;

    mapping(uint256 => address) private indexToAddress;

    mapping(address => uint256) private addressToIndex;

    uint256 public randomMintLastTimeStamp;

    uint256 public randomMintStartBlockNumber;

    address[10] public owner;

    uint32 public buyExchangeRate;

    constructor() ERC20("LuckyCoin", "LCK") {
        totalAddresses = 0;
        randomMintLastTimeStamp = RANDOM_MINT_DEFAULT_LAST_TIMESTAMP;
        randomMintStartBlockNumber = 0;
        owner[0] = msg.sender;
        for (uint8 i = 1; i < owner.length; i++) owner[i] = address(0);
        buyExchangeRate = 0;
    }

    function buy() external payable {
        require(buyExchangeRate > 0, "Purchases are closed");
        require(
            block.timestamp < RANDOM_MINT_DEFAULT_LAST_TIMESTAMP,
            "ICO period ended"
        );
        require(
            totalSupply() + msg.value * buyExchangeRate <=
                INITIAL_MINT_MAX_AMOUNT,
            "Total coin amount has been reached"
        );
        _mint(msg.sender, msg.value * buyExchangeRate);
    }

    function setBuyExchangeRate(uint32 newBuyExchangeRate) external {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        buyExchangeRate = newBuyExchangeRate;
    }

    function mint(address to, uint256 amount) external {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        require(
            totalSupply() + amount <= INITIAL_MINT_MAX_AMOUNT,
            "Total coin amount has been reached"
        );
        require(
            block.timestamp < RANDOM_MINT_DEFAULT_LAST_TIMESTAMP,
            "ICO period ended"
        );
        _mint(to, amount);
    }

    function withdraw(address to) external {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        payable(to).transfer(address(this).balance);
    }

    function setRandomMintLastTimeStamp(uint256 newRandomMintLastTimeStamp)
        external
    {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        require(
            block.timestamp < RANDOM_MINT_DEFAULT_LAST_TIMESTAMP,
            "ICO period ended"
        );
        require(
            newRandomMintLastTimeStamp <= RANDOM_MINT_DEFAULT_LAST_TIMESTAMP,
            "Value has to be set earlier than 2022-01-01"
        );
        randomMintLastTimeStamp = newRandomMintLastTimeStamp;
    }

    function randomMintStart() external {
        require(
            block.timestamp >
                randomMintLastTimeStamp + RANDOM_MINT_MIN_INTERVAL,
            "You have to wait one week after the last random mint"
        );
        require(randomMintStartBlockNumber == 0, "Random mint already started");
        _randomMintStart();
    }

    function _randomMintStart() internal {
        randomMintLastTimeStamp = block.timestamp;
        randomMintStartBlockNumber = block.number;
    }

    function randomMintEnd() external {
        require(randomMintStartBlockNumber > 0, "Random mint not started");
        require(
            block.number > randomMintStartBlockNumber + RANDOM_NUM_BITS,
            "You have to wait 32 blocks after start"
        );
        _randomMintEnd();
    }

    function _randomMintEnd() internal {
        randomMintStartBlockNumber = 0;
        if (block.timestamp > randomMintLastTimeStamp + 1 days) return;
        uint256 randomNumer = uint256(blockhash(block.number - RANDOM_NUM_BITS - 1)) <<
                RANDOM_NUM_BITS;
        for (uint8 i = 0; i < RANDOM_NUM_BITS; i++)
            randomNumer |=
                (uint256(blockhash(block.number - i - 1)) & 0x01) <<
                i;
        uint256 randomIndex = (uint256(
            keccak256(abi.encodePacked(randomNumer))
        ) % totalAddresses) + 1;
        uint256 mintRateX100 = (totalAddresses * WEEKLY_INTEREST_RATE_X10000) /
            100;
        uint256 numExctractions = (mintRateX100 - 1) /
            MAXIMUM_MINT_RATE_X100 +
            1;
        while (mintRateX100 > 0) {
            address randomAddress = indexToAddress[randomIndex];
            uint256 mintAmount = (balanceOf(randomAddress) *
                min(
                    max(mintRateX100, MINIMUM_MINT_RATE_X100),
                    MAXIMUM_MINT_RATE_X100
                )) / 100;
            mintAmount = min(
                mintAmount,
                (totalSupply() * MAX_MINT_TOTAL_AMOUNT_RATE_X100) / 100
            );
            _mint(randomAddress, mintAmount);
            randomIndex =
                ((randomIndex - 1 + totalAddresses / numExctractions) %
                    totalAddresses) +
                1;
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
                randomMintLastTimeStamp + RANDOM_MINT_MIN_INTERVAL
            ) {
                _randomMintStart();
            }
        } else {
            if (block.number > randomMintStartBlockNumber + RANDOM_NUM_BITS) {
                _randomMintEnd();
            } else {
                revert("Random mint in progress, transactions are suspended");
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

        if (to != address(0) && !_isOwnerAddress(to) && balanceOf(to) == amount)
            _insertInMapping(to);

        if (from != address(0) && !_isOwnerAddress(from) && balanceOf(from) == 0)
            _removeFromMapping(from);
    }

    function _insertInMapping(address a) internal {
        totalAddresses++;
        indexToAddress[totalAddresses] = a;
        addressToIndex[a] = totalAddresses;
    }

    function _removeFromMapping(address a) internal {
        indexToAddress[addressToIndex[a]] = indexToAddress[totalAddresses];
        addressToIndex[indexToAddress[totalAddresses]] = addressToIndex[a];
        totalAddresses--;
    }

    function _isInMapping(address a) internal view returns (bool) {
        uint256 index = addressToIndex[a];
        return
            index > 0 && index <= totalAddresses && indexToAddress[index] == a;
    }

    function _isOwnerAddress(address a) internal view returns (bool) {
        for (uint8 i = 0; i < owner.length; i++) {
            if (owner[i] == address(0)) return false;
            if (owner[i] == a) return true;
        }
        return false;
    }

    function addOwnerAddress(address a) external {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        require(randomMintStartBlockNumber == 0, "Random mint in progress");
        for (uint8 i = 0; i < owner.length; i++) {
            if (owner[i] == a) revert("Duplicate address");
            if (owner[i] == address(0)) {
                owner[i] = a;
                if (balanceOf(a) > 0 && _isInMapping(a)) _removeFromMapping(a);
                return;
            }
        }
        revert("Too many owners");
    }

    function removeOwnerAddress(address a) external {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        require(randomMintStartBlockNumber == 0, "Random mint in progress");
        for (uint8 i = 1; i < owner.length; i++) {
            if (owner[i] == address(0)) revert("Address not found");
            if (owner[i] == a) {
                for (uint8 j = i + 1; j < owner.length; j++) {
                    if (owner[j] == address(0)) {
                        owner[i] = owner[j - 1];
                        owner[j - 1] = address(0);
                        if (balanceOf(a) > 0 && !_isInMapping(a))
                            _insertInMapping(a);
                        return;
                    }
                }
                owner[i] = owner[owner.length - 1];
                owner[owner.length - 1] = address(0);
                if (balanceOf(a) > 0 && !_isInMapping(a)) _insertInMapping(a);
                return;
            }
        }
        revert("Address not found");
    }

    function changeOwnerAddress(address a) external {
        require(
            msg.sender == owner[0],
            "This function can only be called by the owner"
        );
        require(randomMintStartBlockNumber == 0, "Random mint in progress");
        for (uint8 i = 0; i < owner.length; i++) {
            if (owner[i] == a) {
                owner[i] = owner[0];
                owner[0] = a;
                return;
            }
            if (owner[i] == address(0)) {
                owner[i] = owner[0];
                owner[0] = a;
                if (balanceOf(a) > 0 && _isInMapping(a)) _removeFromMapping(a);
                return;
            }
        }
        revert("Too many owners");
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
}