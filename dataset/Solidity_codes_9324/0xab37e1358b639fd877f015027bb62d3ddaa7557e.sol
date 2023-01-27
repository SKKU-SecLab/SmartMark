


pragma solidity ^0.6.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;

            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}



pragma solidity ^0.6.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transferFrom.selector,
                from,
                to,
                value
            )
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(
            address(token).isContract(),
            "SafeERC20: call to non-contract"
        );

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}



pragma solidity ^0.6.0;

contract Context {

    constructor() internal {}

    function _msgSender() internal virtual view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
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

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        public
        override
        view
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
        virtual
        override
        view
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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(
            recipient != address(0),
            "ERC20: transfer to the zero address"
        );

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


pragma solidity 0.6.5;

abstract contract ERC20Vestable is ERC20 {
    using SafeMath for uint256;

    struct Grant {
        uint256 amount; // total of deposited tokens to the grant
        uint256 claimed; // total of claimed vesting of the grant
        uint128 startTime; // the time when the grant starts
        uint128 endTime; // the time when the grant ends
    }

    mapping(address => Grant[]) private grants;

    mapping(address => uint256) private remainingGrants;

    uint256 public totalRemainingGrants;

    event CreateGrant(
        address indexed beneficiary,
        uint256 indexed id,
        address indexed creator,
        uint256 endTime
    );
    event DepositToGrant(
        address indexed beneficiary,
        uint256 indexed id,
        address indexed depositor,
        uint256 amount
    );
    event ClaimVestedTokens(address beneficiary, uint256 id, uint256 amount);

    modifier spendable(address account, uint256 amount) {
        require(
            balanceOf(account).sub(remainingGrants[account]) >= amount,
            "transfer amount exceeds spendable balance"
        );
        _;
    }

    function createGrant(address beneficiary, uint256 endTime)
        public
        returns (uint256)
    {
        require(endTime > now, "endTime is before now");
        Grant memory g = Grant(0, 0, uint128(now), uint128(endTime));
        address creator = msg.sender;
        grants[beneficiary].push(g);
        uint256 id = grants[beneficiary].length;
        emit CreateGrant(beneficiary, id, creator, endTime);
        return id;
    }

    function depositToGrant(
        address beneficiary,
        uint256 id,
        uint256 amount
    ) public {
        Grant storage g = _getGrant(beneficiary, id);
        address depositor = msg.sender;
        _transfer(depositor, beneficiary, amount);
        g.amount = g.amount.add(amount);
        remainingGrants[beneficiary] = remainingGrants[beneficiary].add(
            amount
        );
        totalRemainingGrants = totalRemainingGrants.add(amount);
        emit DepositToGrant(beneficiary, id, depositor, amount);
    }

    function claimVestedTokens(address beneficiary, uint256 id) public {
        Grant storage g = _getGrant(beneficiary, id);
        uint256 amount = _vestedAmount(g);
        require(amount != 0, "vested amount is zero");
        uint256 newClaimed = g.claimed.add(amount);
        g.claimed = newClaimed;
        remainingGrants[beneficiary] = remainingGrants[beneficiary].sub(
            amount
        );
        totalRemainingGrants = totalRemainingGrants.sub(amount);
        if (newClaimed == g.amount) {
            _deleteGrant(beneficiary, id);
        }
        emit ClaimVestedTokens(beneficiary, id, amount);
    }

    function getLastGrantID(address beneficiary)
        public
        view
        returns (uint256)
    {
        return grants[beneficiary].length;
    }

    function getGrant(address beneficiary, uint256 id)
        public
        view
        returns (
            uint256 amount,
            uint256 claimed,
            uint256 vested,
            uint256 startTime,
            uint256 endTime
        )
    {
        Grant memory g = _getGrant(beneficiary, id);
        amount = g.amount;
        claimed = g.claimed;
        vested = _vestedAmount(g);
        startTime = g.startTime;
        endTime = g.endTime;
    }

    function remainingGrantOf(address account) public view returns (uint256) {
        return remainingGrants[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override spendable(from, amount) {
        super._transfer(from, to, amount);
    }

    function _deleteGrant(address beneficiary, uint256 id) private {
        delete grants[beneficiary][id - 1];
    }

    function _getGrant(address beneficiary, uint256 id)
        private
        view
        returns (Grant storage)
    {
        require(id != 0, "0 is invalid as id");
        id = id - 1;
        require(id < grants[beneficiary].length, "grant does not exist");
        Grant storage g = grants[beneficiary][id];
        require(
            g.endTime != 0,
            "cannot get grant which is already claimed entirely"
        );
        return g;
    }

    function _vestedAmount(Grant memory g) private view returns (uint256) {
        uint256 n = now;
        if (g.endTime > n) {
            uint256 elapsed = n - g.startTime;
            uint256 duration = g.endTime - g.startTime;
            return g.amount.mul(elapsed).div(duration).sub(g.claimed);
        }
        return g.amount.sub(g.claimed);
    }
}



pragma solidity ^0.6.0;

library Arrays {
    function findUpperBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}



pragma solidity ^0.6.0;

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}



pragma solidity ^0.6.0;

abstract contract ERC20Snapshot is ERC20 {

    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId)
        public
        view
        returns (uint256)
    {
        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _accountBalanceSnapshots[account]
        );

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _totalSupplySnapshots
        );

        return snapshotted ? value : totalSupply();
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);

        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal virtual override {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal virtual override {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._burn(account, value);
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(
            snapshotId <= _currentSnapshotId.current(),
            "ERC20Snapshot: nonexistent id"
        );


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}


pragma solidity 0.6.5;

abstract contract ERC20RegularlyRecord is ERC20Snapshot {
    using SafeMath for uint256;

    uint256 public immutable interval;

    uint256 public immutable initialTime;

    mapping(uint256 => uint256) private snapshotsOfTermEnd;

    modifier termValidation(uint256 _term) {
        require(_term != 0, "0 is invalid value as term");
        _;
    }

    constructor(uint256 _interval) public {
        interval = _interval;
        initialTime = now;
    }

    function termOfTime(uint256 time) public view returns (uint256) {
        return time.sub(initialTime, "time is invalid").div(interval).add(1);
    }

    function currentTerm() public view returns (uint256) {
        return termOfTime(now);
    }

    function startOfTerm(uint256 term)
        public
        view
        termValidation(term)
        returns (uint256)
    {
        return initialTime.add(term.sub(1).mul(interval));
    }

    function endOfTerm(uint256 term)
        public
        view
        termValidation(term)
        returns (uint256)
    {
        return initialTime.add(term.mul(interval)).sub(1);
    }

    function balanceOfAtTermEnd(address account, uint256 term)
        public
        view
        termValidation(term)
        returns (uint256)
    {
        uint256 _currentTerm = currentTerm();
        for (uint256 i = term; i < _currentTerm; i++) {
            if (_isSnapshottedOnTermEnd(i)) {
                return balanceOfAt(account, snapshotsOfTermEnd[i]);
            }
        }
        return balanceOf(account);
    }

    function totalSupplyAtTermEnd(uint256 term)
        public
        view
        termValidation(term)
        returns (uint256)
    {
        uint256 _currentTerm = currentTerm();
        for (uint256 i = term; i < _currentTerm; i++) {
            if (_isSnapshottedOnTermEnd(i)) {
                return totalSupplyAt(snapshotsOfTermEnd[i]);
            }
        }
        return totalSupply();
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        _snapshotOnTermEnd();
        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal virtual override {
        _snapshotOnTermEnd();
        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal virtual override {
        _snapshotOnTermEnd();
        super._burn(account, value);
    }

    function _snapshotOnTermEnd() private {
        uint256 _currentTerm = currentTerm();
        if (_currentTerm > 1 && !_isSnapshottedOnTermEnd(_currentTerm - 1)) {
            snapshotsOfTermEnd[_currentTerm - 1] = _snapshot();
        }
    }

    function _isSnapshottedOnTermEnd(uint256 term)
        private
        view
        returns (bool)
    {
        return snapshotsOfTermEnd[term] != 0;
    }
}


pragma solidity 0.6.5;

contract LienToken is ERC20RegularlyRecord, ERC20Vestable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public constant ETH_ADDRESS = address(0);

    struct Balances {
        uint256 profit;
        uint256 paid;
    }

    uint256 public immutable expiration;

    mapping(address => mapping(address => uint256)) public lastTokenReceived;

    mapping(uint256 => mapping(address => Balances)) private balancesMap;

    event SettleProfit(
        address indexed token,
        uint256 indexed term,
        uint256 amount
    );
    event ReceiveDividend(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );

    constructor(
        uint256 _interval,
        uint256 _expiration,
        uint256 totalSupply
    ) public ERC20RegularlyRecord(_interval) ERC20("lien", "LIEN") {
        _setupDecimals(8);
        ERC20._mint(msg.sender, totalSupply);
        expiration = _expiration;
    }

    receive() external payable {}

    function settleProfit(address token) external {
        uint256 amount = unsettledProfit(token);
        uint256 currentTerm = currentTerm();
        Balances storage b = balancesMap[currentTerm][token];
        uint256 newProfit = b.profit.add(amount);
        b.profit = newProfit;
        emit SettleProfit(token, currentTerm, newProfit);
    }

    function receiveDividend(address token, address recipient) external {
        uint256 i;
        uint256 total;
        uint256 divAt;
        uint256 currentTerm = currentTerm();
        for (
            i = Math.max(
                _oldestValidTerm(),
                lastTokenReceived[recipient][token]
            );
            i < currentTerm;
            i++
        ) {
            divAt = dividendAt(token, recipient, i);
            balancesMap[i][token].paid = balancesMap[i][token].paid.add(divAt);
            total = total.add(divAt);
        }
        lastTokenReceived[recipient][token] = i;
        emit ReceiveDividend(token, recipient, total);
        if (token == ETH_ADDRESS) {
            (bool success, ) = recipient.call{value: total}("");
            require(success, "transfer failed");
        } else {
            IERC20(token).safeTransfer(recipient, total);
        }
    }

    function profitAt(address token, uint256 term)
        public
        view
        returns (uint256)
    {
        return balancesMap[term][token].profit;
    }

    function paidAt(address token, uint256 term)
        public
        view
        returns (uint256)
    {
        return balancesMap[term][token].paid;
    }

    function dividendAt(
        address token,
        address account,
        uint256 term
    ) public view returns (uint256) {
        return
            _dividend(
                profitAt(token, term),
                balanceOfAtTermEnd(account, term),
                totalSupply()
            );
    }

    function unsettledProfit(address token) public view returns (uint256) {
        uint256 remain;
        uint256 tokenBalance;
        uint256 currentTerm = currentTerm();
        for (uint256 i = _oldestValidTerm(); i <= currentTerm; i++) {
            Balances memory b = balancesMap[i][token];
            uint256 remainAt = b.profit.sub(b.paid);
            remain = remain.add(remainAt);
        }
        if (token == ETH_ADDRESS) {
            tokenBalance = address(this).balance;
        } else {
            tokenBalance = IERC20(token).balanceOf(address(this));
        }
        return tokenBalance.sub(remain);
    }

    function unreceivedDividend(address token, address recipient)
        external
        view
        returns (uint256)
    {
        uint256 i;
        uint256 total;
        uint256 divAt;
        uint256 currentTerm = currentTerm();
        for (
            i = Math.max(
                _oldestValidTerm(),
                lastTokenReceived[recipient][token]
            );
            i < currentTerm;
            i++
        ) {
            divAt = dividendAt(token, recipient, i);
            total = total.add(divAt);
        }
        return total;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    )
        internal
        virtual
        override(ERC20Vestable, ERC20RegularlyRecord)
        spendable(from, value)
    {
        ERC20RegularlyRecord._transfer(from, to, value);
    }

    function _burn(address account, uint256 value)
        internal
        virtual
        override(ERC20, ERC20RegularlyRecord)
    {
        ERC20RegularlyRecord._burn(account, value);
    }

    function _mint(address account, uint256 value)
        internal
        virtual
        override(ERC20, ERC20RegularlyRecord)
    {
        ERC20RegularlyRecord._mint(account, value);
    }

    function _oldestValidTerm() private view returns (uint256) {
        uint256 currentTerm = currentTerm();
        if (currentTerm <= expiration) {
            return 1;
        }
        return currentTerm.sub(expiration);
    }

    function _dividend(
        uint256 profit,
        uint256 balance,
        uint256 totalSupply
    ) private pure returns (uint256) {
        return profit.mul(balance).div(totalSupply);
    }
}