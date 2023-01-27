
pragma solidity 0.8.9;

interface ITuxERC20 {

    function mint(address to, uint256 amount) external;


    function feature(
        uint256 auctionId,
        uint256 amount,
        address from
    ) external;


    function cancel(
        uint256 auctionId,
        address from
    ) external;


    function updateFeatured() external;

    function payouts() external;

}// MIT

pragma solidity ^0.8.0;

library OrderedSet {


    struct Set {
        uint256 count;
        mapping (uint256 => uint256) _next;
        mapping (uint256 => uint256) _prev;
    }

    function insert(Set storage set, uint256 prev_, uint256 value, uint256 next_) internal {

        set._next[prev_] = value;
        set._next[value] = next_;
        set._prev[next_] = value;
        set._prev[value] = prev_;
        set.count += 1;
    }

    function add(Set storage set, uint256 value) internal {

        insert(set, 0, value, set._next[0]);
    }

    function append(Set storage set, uint256 value) internal {

        insert(set, set._prev[0], value, 0);
    }

    function remove(Set storage set, uint256 value) internal {

        set._next[set._prev[value]] = set._next[value];
        set._prev[set._next[value]] = set._prev[value];
        delete set._next[value];
        delete set._prev[value];
        if (set.count > 0) {
            set.count -= 1;
        }
    }

    function head(Set storage set) internal view returns (uint256) {

        return set._next[0];
    }

    function tail(Set storage set) internal view returns (uint256) {

        return set._prev[0];
    }

    function length(Set storage set) internal view returns (uint256) {

        return set.count;
    }

    function next(Set storage set, uint256 _value) internal view returns (uint256) {

        return set._next[_value];
    }

    function prev(Set storage set, uint256 _value) internal view returns (uint256) {

        return set._prev[_value];
    }

    function contains(Set storage set, uint256 value) internal view returns (bool) {

        return set._next[0] == value ||
               set._next[value] != 0 ||
               set._prev[value] != 0;
    }

    function values(Set storage set) internal view returns (uint256[] memory) {

        uint256[] memory _values = new uint256[](set.count);
        uint256 value = set._next[0];
        uint256 i = 0;
        while (value != 0) {
            _values[i] = value;
            value = set._next[value];
            i += 1;
        }
        return _values;
    }

    function valuesFromN(Set storage set, uint256 from, uint256 n) internal view returns (uint256[] memory) {

        uint256[] memory _values = new uint256[](n);
        uint256 value = set._next[from];
        uint256 i = 0;
        while (i < n) {
            _values[i] = value;
            value = set._next[value];
            i += 1;
        }
        return _values;
    }
}// MIT

pragma solidity ^0.8.0;


library RankedSet {

    using OrderedSet for OrderedSet.Set;

    struct RankGroup {
        uint256 count;
        uint256 start;
        uint256 end;
    }

    struct Set {
        uint256 highScore;
        mapping(uint256 => RankGroup) rankgroups;
        mapping(uint256 => uint256) scores;
        OrderedSet.Set rankedScores;
        OrderedSet.Set rankedItems;
    }

    function add(Set storage set, uint256 item) internal {

        set.rankedItems.append(item);
        set.rankgroups[0].end = item;
        set.rankgroups[0].count += 1;
        if (set.rankgroups[0].start == 0) {
            set.rankgroups[0].start = item;
        }
    }

    function remove(Set storage set, uint256 item) internal {

        uint256 score = set.scores[item];
        delete set.scores[item];

        RankGroup storage rankgroup = set.rankgroups[score];
        if (rankgroup.count > 0) {
            rankgroup.count -= 1;
        }

        if (rankgroup.count == 0) {
            rankgroup.start = 0;
            rankgroup.end = 0;
            if (score == set.highScore) {
                set.highScore = set.rankedScores.next(score);
            }
            if (score > 0) {
                set.rankedScores.remove(score);
            }
        } else {
            if (rankgroup.start == item) {
                rankgroup.start = set.rankedItems.next(item);
            }
            if (rankgroup.end == item) {
                rankgroup.end = set.rankedItems.prev(item);
            }
        }

        set.rankedItems.remove(item);
    }

    function head(Set storage set) internal view returns (uint256) {

        return set.rankedItems._next[0];
    }

    function tail(Set storage set) internal view returns (uint256) {

        return set.rankedItems._prev[0];
    }

    function length(Set storage set) internal view returns (uint256) {

        return set.rankedItems.count;
    }

    function next(Set storage set, uint256 _value) internal view returns (uint256) {

        return set.rankedItems._next[_value];
    }

    function prev(Set storage set, uint256 _value) internal view returns (uint256) {

        return set.rankedItems._prev[_value];
    }

    function contains(Set storage set, uint256 value) internal view returns (bool) {

        return set.rankedItems._next[0] == value ||
               set.rankedItems._next[value] != 0 ||
               set.rankedItems._prev[value] != 0;
    }

    function scoreOf(Set storage set, uint256 value) internal view returns (uint256) {

        return set.scores[value];
    }

    function values(Set storage set) internal view returns (uint256[] memory) {

        uint256[] memory _values = new uint256[](set.rankedItems.count);
        uint256 value = set.rankedItems._next[0];
        uint256 i = 0;
        while (value != 0) {
            _values[i] = value;
            value = set.rankedItems._next[value];
            i += 1;
        }
        return _values;
    }

    function valuesFromN(Set storage set, uint256 from, uint256 n) internal view returns (uint256[] memory) {

        uint256[] memory _values = new uint256[](n);
        uint256 value = set.rankedItems._next[from];
        uint256 i = 0;
        while (i < n) {
            _values[i] = value;
            value = set.rankedItems._next[value];
            i += 1;
        }
        return _values;
    }

    function rankScore(Set storage set, uint256 item, uint256 newScore) internal {

        RankGroup storage rankgroup = set.rankgroups[newScore];

        if (newScore > set.highScore) {
            remove(set, item);
            rankgroup.start = item;
            set.highScore = newScore;
            set.rankedItems.add(item);
            set.rankedScores.add(newScore);
        } else {
            uint256 score = set.scores[item];
            uint256 prevScore = set.rankedScores.prev(score);

            if (set.rankgroups[score].count == 1) {
                score = set.rankedScores.next(score);
            }

            remove(set, item);

            while (prevScore > 0 && newScore > prevScore) {
                prevScore = set.rankedScores.prev(prevScore);
            }

            set.rankedItems.insert(
                set.rankgroups[prevScore].end,
                item,
                set.rankgroups[set.rankedScores.next(prevScore)].start
            );

            if (rankgroup.count == 0) {
                set.rankedScores.insert(prevScore, newScore, score);
                rankgroup.start = item;
            }
        }

        rankgroup.end = item;
        rankgroup.count += 1;

        set.scores[item] = newScore;
    }
}// MIT

pragma solidity ^0.8.0;

library AddressSet {


    struct Set {
        address[] _values;
        mapping(address => uint256) _indexes;
    }

    function add(Set storage set, address value) internal returns (bool) {

        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(Set storage set, address value) internal returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                address lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function contains(Set storage set, address value) internal view returns (bool) {

        return set._indexes[value] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {

        return set._values.length;
    }

    function at(Set storage set, uint256 index) internal view returns (address) {

        return set._values[index];
    }

    function values(Set storage set) internal view returns (address[] memory) {

        return set._values;
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

pragma solidity 0.8.9;


contract TuxERC20 is
    ITuxERC20,
    ERC20Burnable
{
    using RankedSet for RankedSet.Set;
    using AddressSet for AddressSet.Set;

    address public owner;

    address public minter;

    uint256 public featured;

    uint256 public nextFeaturedTime;

    uint256 constant public featuredDuration = 3600; // 1 hour -> 3600 seconds

    uint256 constant public payoutsFrequency = 604800; // 7 days -> 604800 seconds

    uint256 public nextPayoutsTime = block.timestamp + payoutsFrequency;

    uint256 public payoutAmount = 100 * 10**18;

    AddressSet.Set private _payoutAddresses;

    RankedSet.Set private _featuredQueue;

    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        owner = msg.sender;

        _mint(owner, 100000 * 10**18);

        _payoutAddresses.add(0x71C7656EC7ab88b098defB751B7401B5f6d8976F); // Etherscan
    }

    function setMinter(address minter_)
        external
    {
        require(
            msg.sender == owner,
            "Not owner address");

        minter = minter_;
    }

    function addPayoutAddress(address payoutAddress)
        external
    {
        require(
            msg.sender == owner,
            "Not owner address");
        require(
            _payoutAddresses.length() < 10,
            "Maximum reached");

        _payoutAddresses.add(payoutAddress);
    }

    function removePayoutAddress(address payoutAddress)
        external
    {
        require(
            msg.sender == owner,
            "Not owner address");

        _payoutAddresses.remove(payoutAddress);
    }

    function updatePayoutAmount(uint256 amount)
        external
    {
        require(
            msg.sender == owner,
            "Not owner address");
        require(
            amount < 1000 * 10**18,
            "Amount too high");

        payoutAmount = amount;
    }

    function renounceOwnership()
        external
    {
        require(
            msg.sender == owner,
            "Not owner address");

        owner = address(0);
    }

    function mint(address to, uint256 amount)
        external
        virtual
        override
    {
        require(
            msg.sender == minter,
            "Not minter address");

        _mint(to, amount);
    }

    function burn(uint256 amount)
        public
        override(ERC20Burnable)
    {
        _burn(msg.sender, amount);
    }

    function feature(uint256 auctionId, uint256 amount, address from)
        external
        virtual
        override
    {
        require(
            msg.sender == minter,
            "Not minter address");
        require(
            balanceOf(from) >= amount,
            "Not enough TUX");
        require(
            _featuredQueue.contains(auctionId) == false,
            "Already queued");
        require(
            amount >= 1 * 10**18,
            "Price too low");

        updateFeatured();

        _burn(from, amount);

        _featuredQueue.add(auctionId);
        _featuredQueue.rankScore(auctionId, amount);

        payouts();
    }

    function cancel(uint256 auctionId, address from)
        external
        virtual
        override
    {
        require(
            msg.sender == minter,
            "Not minter address");
        require(
            _featuredQueue.contains(auctionId) == true,
            "Not queued");

        _mint(from, _featuredQueue.scoreOf(auctionId));

        _featuredQueue.remove(auctionId);

        updateFeatured();
        payouts();
    }

    function getFeatured(uint256 from, uint256 n)
        view
        public
        returns(uint256[] memory)
    {
        return _featuredQueue.valuesFromN(from, n);
    }

    function getFeaturedLength()
        view
        public
        returns(uint256 length)
    {
        return _featuredQueue.length();
    }

    function getFeaturedContains(uint auctionId)
        view
        public
        returns(bool)
    {
        return _featuredQueue.contains(auctionId);
    }

    function getNextFeaturedTime()
        view
        public
        returns(uint256 timestamp)
    {
        return nextFeaturedTime;
    }

    function getFeaturedPrice(uint256 auctionId)
        view
        public
        returns(uint256 price)
    {
        return _featuredQueue.scoreOf(auctionId);
    }

    function updateFeatured()
        public
        override
    {
        if (block.timestamp < nextFeaturedTime || _featuredQueue.length() == 0) {
            return;
        }

        nextFeaturedTime = block.timestamp + featuredDuration;
        uint256 auctionId = _featuredQueue.head();
        _featuredQueue.remove(auctionId);
        featured = auctionId;

        _mint(msg.sender, 1 * 10**18);
    }

    function payouts()
        public
        override
    {
        if (block.timestamp < nextPayoutsTime) {
            return;
        }

        nextPayoutsTime = block.timestamp + payoutsFrequency;

        for (uint i = 0; i < _payoutAddresses.length(); i++) {
            _mint(_payoutAddresses.at(i), payoutAmount);
        }

        _mint(msg.sender, 1 * 10**18);
    }
}