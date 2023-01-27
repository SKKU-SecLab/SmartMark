pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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
}// MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);


    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function approve(address spender, uint256 id) public virtual {
        address owner = ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(ownerOf[id] == address(0), "ALREADY_MINTED");

        unchecked {
            balanceOf[to]++;
        }

        ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(ownerOf[id] != address(0), "NOT_MINTED");

        unchecked {
            balanceOf[owner]--;
        }

        delete ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }


    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

interface ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);
}// UNLICENSED

pragma solidity ^0.8.13;




struct MintSchedule {
    uint256 price;
    uint256 cadence;
    uint256 rounds;
}

struct Recipient {
    uint256 tokenId;
    uint256 timestamp;
    address recipient;
    address referrer;
}

contract ShibPixelPups is ERC721, Ownable, Pausable {
    using Counters for Counters.Counter;

    uint256 public constant MAX_SUPPLY = 42069;

    uint256 public constant MINT_PRICE = 6500000000000000000000000;

    uint256 private constant MAX_PRICE_FEEDS = 6;

    Counters.Counter private _mintCounter;

    Counters.Counter private _mintScheduleCounter;

    Counters.Counter private _totalMintScheduleCounter;

    Counters.Counter private _roundCounter;

    Counters.Counter private _totalRoundCounter;

    Counters.Counter private _totalPriceFeedCounter;

    ERC20Burnable private _burnToken;
    address private _burnTokenAddress;

    mapping(uint256 => AggregatorV3Interface) private _priceFeeds;
    mapping(uint256 => MintSchedule) private _mintSchedules;

    mapping(uint256 => Recipient) private _recipients;

    mapping(uint256 => address) private _referrers;

    uint256 private _antiCheatNonce = 1;

    uint256 private _communityAntiCheatNonce = 1;

    constructor(address burnTokenAddress, address[] memory priceFeeds)
        ERC721("SHIB PIXEL PUPS", "SHIBPUPS")
    {
        _addMintSchedule(MINT_PRICE, 69, 1);

        _addMintSchedule(MINT_PRICE, 50, 840);

        _mintCounter.increment();

        _burnTokenAddress = burnTokenAddress;
        _burnToken = ERC20Burnable(_burnTokenAddress);

        require(priceFeeds.length <= MAX_PRICE_FEEDS, "Max price feeds hit");
        for (uint256 i = 0; i < priceFeeds.length; i = _unsafeIncrement(i)) {
            _addPriceFeed(priceFeeds[i]);
        }
    }

    function _addMintSchedule(
        uint256 price,
        uint256 cadence,
        uint256 rounds
    ) private onlyOwner {
        _mintSchedules[_totalMintScheduleCounter.current()] = MintSchedule(
            price,
            cadence,
            rounds
        );
        _totalMintScheduleCounter.increment();
    }

    function _addPriceFeed(address priceFeedAddress) private onlyOwner {
        require(
            _totalPriceFeedCounter.current() < MAX_PRICE_FEEDS,
            "Max price feeds hit"
        );
        _priceFeeds[_totalPriceFeedCounter.current()] = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, uint256 timestamp, , ) = _priceFeeds[
            _totalPriceFeedCounter.current()
        ].latestRoundData();
        require(price != 0, "Invalid AggregatorV3 address");
        _totalPriceFeedCounter.increment();
    }

    function getRecipientTokenByRound(uint256 index)
        public
        view
        returns (uint256)
    {
        return _recipients[index].tokenId;
    }

    function getRecipientAddressByRound(uint256 index)
        public
        view
        returns (address)
    {
        return _recipients[index].recipient;
    }

    function getRecipientInfoByRound(uint256 index)
        public
        view
        returns (Recipient memory)
    {
        return _recipients[index];
    }

    function getTotalCompletedRounds() public view returns (uint256) {
        return _totalRoundCounter.current();
    }

    function getTotalSchedules() public view returns (uint256) {
        return _totalMintScheduleCounter.current();
    }

    function totalSupply() public view returns (uint256) {
        return _mintCounter.current() - 1;
    }

    function getMintsRemaining() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    function getCurrentSchedule() public view returns (uint256) {
        return _mintScheduleCounter.current();
    }

    function getCurrentPool() public view returns (uint256) {
        return getPoolByIndex(getCurrentSchedule());
    }

    function getPoolByIndex(uint256 index) public view returns (uint256) {
        return _mintSchedules[index].cadence * _mintSchedules[index].price;
    }


    function mint(uint256 count, address referrer)
        external
        whenNotPaused
        returns (uint256)
    {
        return _mintTo(msg.sender, count, referrer);
    }

    function gift(
        address receiver,
        uint256 count,
        address referrer
    ) external whenNotPaused returns (uint256) {
        return _mintTo(receiver, count, referrer);
    }


    function _mintTo(
        address receiver,
        uint256 count,
        address referrer
    ) internal returns (uint256) {
        require(count > 0 && count <= 5, "Count must be between 1 and 5");
        require(totalSupply() <= MAX_SUPPLY, "MAX_SUPPLY hit");
        require(totalSupply() + count <= MAX_SUPPLY, "MAX_SUPPLY exceeded");

        uint256 total = _mintSchedules[getCurrentSchedule()].price * count;
        require(_burnToken.balanceOf(msg.sender) >= total, "Invalid balance");
        require(
            _burnToken.allowance(msg.sender, address(this)) >= total,
            "Invalid allowance"
        );
        _burnToken.transferFrom(msg.sender, address(this), total);

        uint256 totalBurnAmount = (total * 40) / 100;
        _burnToken.burn(totalBurnAmount);

        for (uint256 i = 0; i < count; i = _unsafeIncrement(i)) {
            _safeMint(receiver, _mintCounter.current());

            if (referrer != address(0)) {
                _referrers[_mintCounter.current()] = referrer;
            }

            if (
                _mintScheduleCounter.current() <
                _totalMintScheduleCounter.current() &&
                (_mintCounter.current() - _sumCompletedRounds()) %
                    _mintSchedules[_mintScheduleCounter.current()].cadence ==
                0
            ) {
                uint256 selectedTokenId = _selectTokenId(
                    _mintCounter.current()
                );
                _recipients[_totalRoundCounter.current()] = Recipient(
                    selectedTokenId,
                    block.timestamp,
                    this.ownerOf(selectedTokenId),
                    _referrers[selectedTokenId]
                );

                uint256 currentPool = getCurrentPool();

                delete _referrers[selectedTokenId];

                if (
                    _roundCounter.current() ==
                    _mintSchedules[_mintScheduleCounter.current()].rounds - 1
                ) {
                    _mintScheduleCounter.increment();
                    _roundCounter.reset();
                } else {
                    _roundCounter.increment();
                }

                if (
                    _recipients[_totalRoundCounter.current()].referrer !=
                    address(0)
                ) {
                    _burnToken.transfer(
                        _recipients[_totalRoundCounter.current()].recipient,
                        ((((currentPool * 40) / 100) * 85) / 100)
                    );
                    _burnToken.transfer(
                        _recipients[_totalRoundCounter.current()].referrer,
                        ((((currentPool * 40) / 100) * 15) / 100)
                    );
                } else {
                    _burnToken.transfer(
                        _recipients[_totalRoundCounter.current()].recipient,
                        ((currentPool * 40) / 100)
                    );
                }

                _totalRoundCounter.increment();
            }
            _mintCounter.increment();
        }
        return
            _totalRoundCounter.current() > 0
                ? _recipients[_totalRoundCounter.current() - 1].tokenId
                : 0;
    }

    function _sumCompletedRounds() private view returns (uint256) {
        uint256 aggregateTotal;
        if (_mintScheduleCounter.current() > 0) {
            for (
                uint256 i = 0;
                i < _mintScheduleCounter.current();
                i = _unsafeIncrement(i)
            ) {
                unchecked {
                    aggregateTotal =
                        aggregateTotal +
                        (_mintSchedules[i].cadence * _mintSchedules[i].rounds);
                }
            }
        }
        return aggregateTotal;
    }

    function _selectTokenId(uint256 maxValue) private view returns (uint256) {
        return (uint256((_random() % maxValue) + 1));
    }

    function _unsafeIncrement(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function _random() private view returns (uint256) {
        (, int256 priceSeed0, uint256 timestampSeed0, , ) = _priceFeeds[
            (block.timestamp + block.number + gasleft()) %
                _totalPriceFeedCounter.current()
        ].latestRoundData();

        (, int256 priceSeed1, uint256 timestampSeed1, , ) = _priceFeeds[
            (block.timestamp + uint256(priceSeed0) + block.number + gasleft()) %
                _totalPriceFeedCounter.current()
        ].latestRoundData();

        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        gasleft() +
                        _mintCounter.current() +
                        ((uint256(priceSeed0) * timestampSeed1) /
                            (block.timestamp)) +
                        ((uint256(priceSeed1) * timestampSeed0) /
                            (block.timestamp)) +
                        ((uint256(priceSeed0) * _antiCheatNonce) /
                            (block.timestamp)) +
                        ((uint256(priceSeed1) * _communityAntiCheatNonce) /
                            (block.timestamp)) +
                        ((timestampSeed1 * _antiCheatNonce) /
                            (block.timestamp)) +
                        ((timestampSeed0 * _communityAntiCheatNonce) /
                            (block.timestamp)) +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );
        return (seed - (seed / _mintCounter.current()));
    }

    function setAntiCheatNonce(uint256 nonce) external onlyOwner {
        require(totalSupply() != MAX_SUPPLY, "Max supply hit");
        require(nonce > 0, "Nonce must be greater than zero");
        _antiCheatNonce = nonce;
    }

    function setCommunityAntiCheatNonce(uint256 nonce) external {
        require(totalSupply() != MAX_SUPPLY, "Max supply hit");
        require(
            _mintCounter.current() %
                _mintSchedules[_mintScheduleCounter.current()].cadence <
                _mintSchedules[_mintScheduleCounter.current()].cadence - 10,
            "Too close to round end"
        );
        require(nonce > 0, "Nonce must be greater than zero");
        _communityAntiCheatNonce = nonce;
    }


    function lock() external onlyOwner {
        _pause();
    }

    function unlock() external onlyOwner {
        _unpause();
    }


    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function withdrawBurnToken() external onlyOwner {
        require(
            _burnToken.balanceOf(address(this)) > 0,
            "Insufficient balance"
        );

        uint256 reserved = totalSupply() < MAX_SUPPLY
            ? ((totalSupply() - _sumCompletedRounds()) *
                _mintSchedules[getCurrentSchedule()].price *
                80) / 100
            : 0;

        require(
            _burnToken.balanceOf(address(this)) > reserved,
            "Balance must be greater than reserved balance"
        );

        bool success = _burnToken.transfer(
            address(owner()),
            _burnToken.balanceOf(address(this)) - reserved
        );

        require(success, "Withdraw failed");
    }

    function withdrawERC20(address tokenContract) external onlyOwner {
        require(
            address(tokenContract) != address(_burnTokenAddress),
            "Cannot withdraw burn token from this method"
        );
        bool success = IERC20(tokenContract).transfer(
            address(owner()),
            IERC20(tokenContract).balanceOf(address(this))
        );
        require(success, "Withdraw failed");
    }


    function baseTokenURI() public pure returns (string memory) {
        return "https://pixelpups-api.shibtoken.art/api/traits/";
    }

    function tokenURI(uint256 _tokenId)
        public
        pure
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseTokenURI(), Strings.toString(_tokenId))
            );
    }
}