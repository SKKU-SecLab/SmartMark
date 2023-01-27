
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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

}// MIT

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
}//NONE
pragma solidity ^0.8.7;




contract NFTContract {
    function ownerOf(uint256 tokenId) external view returns (address owner) {}

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {}
}

contract GoofToken is Ownable, ERC20("Goofball Gang Token", "GOOF"), ERC20Burnable {
    uint256 public constant DAILY_RATE = 10 ether;

    uint256 public constant START_TIME = 1634250000; /* ~Oct 15th 2021 */
    uint256 public constant TIME_BLOCKSIZE = 10_000;

    uint256 public constant BONUS_TIME_LIMIT_1 = 1638316800; /* Dec 1st 2021 */
    uint256 public constant BONUS_TIME_LIMIT_2 = 1640995200; /* Jan 1st 2022 */

    uint256 public constant MIN_NAME_LENGTH = 2;
    uint256 public constant MAX_NAME_LENGTH = 30;

    event ChangeCommit(uint256 indexed tokenId, uint256 price, bytes changeData);
    event NameChange(uint256 indexed tokenId, bytes newName);

    NFTContract private delegate;
    uint256 public nameChangePrice = 1000 ether;
    uint256 public distributionEndTime = 1798761600; /* Jan 1st 2027 */
    uint256 public gweiPerGoof = 0;

    mapping(uint256 => uint256) public lastUpdateMap;

    mapping(uint256 => bytes) public goofNameMap;
    mapping(bytes => uint256) public nameOwnerMap;

    mapping(address => uint256) public permittedContracts;

    constructor(address nftContract, uint256 initialSupply) {
        delegate = NFTContract(nftContract);
        _mint(msg.sender, initialSupply);
    }

    function getUpdateTime(uint256 id) public view returns (uint256 updateTime) {
        uint256 value = lastUpdateMap[id >> 4];
        value = (value >> ((id & 0xF) << 4)) & 0xFFFF;
        return value * TIME_BLOCKSIZE + START_TIME;
    }
    function setUpdateTime(uint256 id, uint256 time) internal returns (uint256 roundedTime) {
        require(time > START_TIME, "invalid time");
        uint256 currentValue = lastUpdateMap[id >> 4];
        uint256 shift = ((id & 0xF) << 4);
        uint256 mask = ~(0xFFFF << shift);
        uint256 newEncodedValue = (time - START_TIME + TIME_BLOCKSIZE - 1) / TIME_BLOCKSIZE;
        lastUpdateMap[id >> 4] = ((currentValue & mask) | (newEncodedValue << shift));
        return newEncodedValue * TIME_BLOCKSIZE + START_TIME;
    }

    function setPermission(address addr, uint256 permitted) public onlyOwner {
        permittedContracts[addr] = permitted;
    }

    function setGweiPerGoof(uint256 value) public onlyOwner {
        gweiPerGoof = value;
    }

    function getName(uint256 id) public view returns (string memory) {
        return string(abi.encodePacked(goofNameMap[id]));
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function setNameChangePrice(uint256 price) public onlyOwner {
        nameChangePrice = price;
    }

    function setDistributionEndTime(uint256 endTime) public onlyOwner {
        distributionEndTime = endTime;
    }

    function getInitialGrant(uint256 t) public pure returns (uint256) {
        if (t < BONUS_TIME_LIMIT_1) {
            return 1000 ether;
        }
        if (t < BONUS_TIME_LIMIT_2) {
            return 500 ether;
        } else {
            return 0;
        }
    }

    function getGrantBetween(uint256 beginTime, uint256 endTime) public pure returns (uint256) {
        if (beginTime > BONUS_TIME_LIMIT_2) {
            return ((endTime - beginTime) * DAILY_RATE) / 86400;
        }
        uint256 weightedTime = 0;
        if (beginTime < BONUS_TIME_LIMIT_1) {
            weightedTime += (min(endTime, BONUS_TIME_LIMIT_1) - beginTime) * 4;
        }
        if (beginTime < BONUS_TIME_LIMIT_2 && endTime > BONUS_TIME_LIMIT_1) {
            weightedTime += (min(endTime, BONUS_TIME_LIMIT_2) - max(beginTime, BONUS_TIME_LIMIT_1)) * 2;
        }
        if (endTime > BONUS_TIME_LIMIT_2) {
            weightedTime += endTime - max(beginTime, BONUS_TIME_LIMIT_2);
        }
        return (weightedTime * DAILY_RATE) / 86400;
    }

    function claim(uint256 tokenId) internal returns (uint256) {
        uint256 lastUpdate = getUpdateTime(tokenId);
        uint256 timeUpdate = min(block.timestamp, distributionEndTime);
        timeUpdate = setUpdateTime(tokenId, timeUpdate);
        if (lastUpdate == START_TIME) {
            return getInitialGrant(timeUpdate);
        } else {
            return getGrantBetween(lastUpdate, timeUpdate);
        }
    }

    function claimReward(uint256[] memory id) public {
        uint256 totalReward = 0;
        for (uint256 i = 0; i < id.length; i++) {
            require(delegate.ownerOf(id[i]) == msg.sender, "id not owned");
            totalReward += claim(id[i]);
        }
        if (totalReward > 0) {
            _mint(msg.sender, totalReward);
        }
    }

    function claimFull() public {
        claimFullFor(msg.sender);
    }

    function claimFullFor(address addr) public {
        uint256[] memory id = delegate.walletOfOwner(addr);
        uint256 totalReward = 0;
        for (uint256 i = 0; i < id.length; i++) {
            totalReward += claim(id[i]);
        }
        if (totalReward > 0) {
            _mint(addr, totalReward);
        }
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function burnTokens(uint256 amount) private {
        if (msg.value > 0 && gweiPerGoof > 0) {
            uint256 converted = (msg.value * 1 gwei) / gweiPerGoof;
            if (converted >= amount) {
                amount = 0;
            } else {
                amount -= converted;
            }
        }
        if (amount > 0) {
            _burn(msg.sender, amount);
        }
    }

    function commitChange(
        uint256 tokenId,
        uint256 pricePaid,
        bytes memory changeData
    ) public payable {
        require(delegate.ownerOf(tokenId) == msg.sender, "not owner");
        burnTokens(pricePaid);
        emit ChangeCommit(tokenId, pricePaid, changeData);
    }

    function isValidName(bytes memory nameBytes) public pure returns (bool) {
        if (nameBytes.length < MIN_NAME_LENGTH || nameBytes.length > MAX_NAME_LENGTH) {
            return false;
        }
        uint8 prevChar = 32;
        for (uint256 i = 0; i < nameBytes.length; i++) {
            uint8 ch = uint8(nameBytes[i]);
            if (ch == 32 && prevChar == 32) {
                return false; // no repeated spaces (and also checks first character)
            }
            if (!(ch >= 32 && ch <= 126) || ch == 60 || ch == 62 || ch == 35) {
                return false;
            }
            prevChar = ch;
        }
        if (prevChar == 32) {
            return false;
        }
        return true;
    }

    function toLower(bytes memory name) private pure returns (bytes memory) {
        bytes memory lowerCased = new bytes(name.length);
        for (uint256 i = 0; i < name.length; i++) {
            uint8 ch = uint8(name[i]);
            if (ch >= 65 && ch <= 90) {
                lowerCased[i] = bytes1(
                    ch +
                        97 - /* 'a' */
                        65 /* 'A' */
                );
            } else {
                lowerCased[i] = bytes1(ch);
            }
        }
        return lowerCased;
    }

    function changeName(uint256 tokenId, bytes memory newName) public payable {
        require(newName.length == 0 || isValidName(newName), "not valid name");
        require(delegate.ownerOf(tokenId) == msg.sender, "not owner");

        bytes memory lowerCased = toLower(newName);
        if (newName.length > 0) {
            uint256 nameOwner = nameOwnerMap[lowerCased];
            require(nameOwner == 0 || nameOwner == tokenId + 1, "name duplicate");
        }
        burnTokens(nameChangePrice);

        bytes memory currentName = goofNameMap[tokenId];
        if (currentName.length > 0) {
            delete nameOwnerMap[toLower(currentName)];
        }
        goofNameMap[tokenId] = newName;
        if (newName.length > 0) {
            nameOwnerMap[lowerCased] = tokenId + 1;
        }
        emit NameChange(tokenId, newName);
    }

    function permittedMint(address destination, uint256 amount) public {
        require(permittedContracts[msg.sender] == 1);
        _mint(destination, amount);
    }

    function permittedBurn(address src, uint256 amount) public {
        require(permittedContracts[msg.sender] == 1);
        _burn(src, amount);
    }

    function permittedTransfer(
        address src,
        address dest,
        uint256 amount
    ) public {
        require(permittedContracts[msg.sender] == 1);
        _transfer(src, dest, amount);
    }

    function withdrawBalance(address to, uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = address(this).balance;
        }
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Transfer failed.");
    }
}