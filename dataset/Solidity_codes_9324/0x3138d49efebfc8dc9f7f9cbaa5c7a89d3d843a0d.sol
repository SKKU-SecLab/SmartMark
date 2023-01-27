



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity =0.6.6;


library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}


pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}



pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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



pragma solidity >=0.6.0 <0.8.0;

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
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
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

        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
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

        uint256 newAllowance =
            token.allowance(address(this), spender).sub(value);
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


        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}



pragma solidity >=0.6.0 <0.8.0;

contract ERC20TransferBlacklistCheckpointWhitelist is Context, IERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public blacklistManager;
    address public whitelistManager;
    mapping(address => bool) public sendBlacklist;
    mapping(address => bool) public receiveBlacklist;
    mapping(address => bool) public checkpointWhitelist;

    mapping(address => Checkpoint[]) private balances;
    mapping(address => Checkpoint[]) private balancesWhitelisted;
    uint256 private totalWhitelisted;
    Checkpoint[] private totalsWhitelisted;
    struct Checkpoint {
        uint128 fromBlock;
        uint128 value;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 amount,
        address blacklistManager_,
        address whitelistManager_
    ) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        blacklistManager = blacklistManager_;
        whitelistManager = whitelistManager_;
        _mint(msg.sender, amount);
    }

    modifier onlyBlacklistManager() {

        require(
            msg.sender == blacklistManager,
            "ERC20TransferBlacklistCheckpointWhitelist: sender is not blacklistManager"
        );
        _;
    }

    modifier onlyWhitelistManager() {

        require(
            msg.sender == whitelistManager,
            "ERC20TransferBlacklistCheckpointWhitelist: sender is not blacklistManager"
        );
        _;
    }

    function setReceiveBlacklist(address recipient, bool isBlacklisted)
        external
        onlyBlacklistManager
    {

        receiveBlacklist[recipient] = isBlacklisted;
    }

    function setSendBlacklist(address sender, bool isBlacklisted)
        external
        onlyBlacklistManager
    {

        sendBlacklist[sender] = isBlacklisted;
    }

    function setCheckpointWhitelist(address holder, bool isWhitelisted)
        external
        onlyWhitelistManager
    {

        checkpointWhitelist[holder] = isWhitelisted;
    }

    function whitelistAll(address[] calldata holders)
        external
        onlyWhitelistManager
    {

        for (uint256 i = 0; i < holders.length; i++) {
            checkpointWhitelist[holders[i]] = true;
        }
    }

    function transferWhitelistManager(address whitelistManager_)
        external
        onlyWhitelistManager
    {

        whitelistManager = whitelistManager_;
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount)
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
            _allowances[_msgSender()][spender].sub(subtractedValue)
        );
        return true;
    }


    function balanceWhitelistedOfAt(address _owner, uint256 _blockNumber)
        public
        view
        returns (uint256)
    {

        if (balancesWhitelisted[_owner].length == 0) return 0;
        return getValueAt(balancesWhitelisted[_owner], _blockNumber);
    }

    function balanceOfAt(address _owner, uint256 _blockNumber)
        public
        view
        returns (uint256)
    {

        if (balances[_owner].length == 0) return 0;
        return getValueAt(balances[_owner], _blockNumber);
    }

    function totalWhitelistedSupplyAt(uint256 _blockNumber)
        public
        view
        returns (uint256)
    {

        if (totalsWhitelisted.length == 0) return 0;
        return getValueAt(totalsWhitelisted, _blockNumber);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!sendBlacklist[sender], "ERC20Blacklist: sender blacklisted");
        require(
            !receiveBlacklist[recipient],
            "ERC20Blacklist: recipient blacklisted"
        );

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount);
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

        _balances[account] = _balances[account].sub(amount);
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
    ) internal virtual {

        _updateValueAtNow(balances[from], balanceOf(from).sub(amount));
        _updateValueAtNow(balances[to], balanceOf(to).add(amount));
        if (checkpointWhitelist[from] && !checkpointWhitelist[to]) {
            _updateValueAtNow(
                balancesWhitelisted[from],
                balanceOf(from).sub(amount)
            );
            totalWhitelisted = totalWhitelisted.sub(amount);
            _updateValueAtNow(totalsWhitelisted, totalWhitelisted);
        } else if (!checkpointWhitelist[from] && checkpointWhitelist[to]) {
            _updateValueAtNow(
                balancesWhitelisted[to],
                balanceOf(to).add(amount)
            );
            totalWhitelisted = totalWhitelisted.add(amount);
            _updateValueAtNow(totalsWhitelisted, totalWhitelisted);
        } else if (checkpointWhitelist[from] && checkpointWhitelist[to]) {
            _updateValueAtNow(
                balancesWhitelisted[from],
                balanceOf(from).sub(amount)
            );
            _updateValueAtNow(
                balancesWhitelisted[to],
                balanceOf(to).add(amount)
            );
        }
    }


    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block)
        internal
        view
        returns (uint256)
    {

        if (checkpoints.length == 0) return 0;

        if (_block >= checkpoints[checkpoints.length - 1].fromBlock)
            return checkpoints[checkpoints.length - 1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        uint256 min = 0;
        uint256 max = checkpoints.length - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return checkpoints[min].value;
    }

    function _updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value)
        internal
    {

        if (
            (checkpoints.length == 0) ||
            (checkpoints[checkpoints.length - 1].fromBlock < block.number)
        ) {
            Checkpoint storage newCheckPoint =
                checkpoints[checkpoints.length + 1];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint =
                checkpoints[checkpoints.length - 1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}



pragma solidity >=0.6.0 <0.8.0;

contract ERC20TransferTax is Context, IERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public taxBips;
    address public taxMan;
    mapping(address => bool) public isNotTaxed;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 amount,
        address taxMan_,
        uint256 taxBips_
    ) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _mint(msg.sender, amount);
        taxMan = taxMan_;
        taxBips = taxBips_;
    }

    function setIsTaxed(address account, bool isTaxed_) external {

        require(msg.sender == taxMan, "!taxMan");
        isNotTaxed[account] = !isTaxed_;
    }

    function transferTaxman(address taxMan_) external {

        require(msg.sender == taxMan, "!taxMan");
        taxMan = taxMan_;
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount)
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
            _allowances[_msgSender()][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (isNotTaxed[sender] || isNotTaxed[recipient]) {
            _beforeTokenTransfer(sender, recipient, amount);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else {
            uint256 tax = amount.mul(taxBips) / 10000;
            uint256 postTaxAmount = amount.sub(tax);

            _beforeTokenTransfer(sender, recipient, postTaxAmount);
            _beforeTokenTransfer(sender, taxMan, tax);

            _balances[sender] = _balances[sender].sub(amount);

            _balances[recipient] = _balances[recipient].add(postTaxAmount);
            _balances[taxMan] = _balances[taxMan].add(tax);

            emit Transfer(sender, recipient, postTaxAmount);
            emit Transfer(sender, taxMan, tax);
        }
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

        _balances[account] = _balances[account].sub(amount);
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


pragma solidity =0.6.6;

interface IXEth is IERC20 {
    function deposit() external payable;

    function xlockerMint(uint256 wad, address dst) external;

    function withdraw(uint256 wad) external;

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
    event XlockerMint(uint256 wad, address dst);
}


pragma solidity ^0.6.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint256(_at(set._inner, index)));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}


pragma solidity >=0.4.24 <0.7.0;

contract Initializable {
    bool private initialized;

    bool private initializing;

    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;

abstract contract AccessControlUpgradeSafe is
    Initializable,
    ContextUpgradeSafe
{
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index)
        public
        view
        returns (address)
    {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to grant"
        );

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to revoke"
        );

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}


pragma solidity =0.6.6;

contract XETH is IXEth, AccessControlUpgradeSafe {
    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;

    bytes32 public constant XETH_LOCKER_ROLE = keccak256("XETH_LOCKER_ROLE");
    bytes32 public immutable PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public override balanceOf;
    mapping(address => uint256) public override nonces;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor() public {
        name = "xlock.eth Wrapped Ether";
        symbol = "XETH";
        decimals = 18;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable override {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function grantXethLockerRole(address account) external {
        grantRole(XETH_LOCKER_ROLE, account);
    }

    function revokeXethLockerRole(address account) external {
        revokeRole(XETH_LOCKER_ROLE, account);
    }

    function xlockerMint(uint256 wad, address dst) external override {
        require(
            hasRole(XETH_LOCKER_ROLE, msg.sender),
            "Caller is not xeth locker"
        );
        balanceOf[dst] += wad;
        totalSupply += wad;
        emit Transfer(address(0), dst, wad);
    }

    function withdraw(uint256 wad) external override {
        require(balanceOf[msg.sender] >= wad, "!balance");
        balanceOf[msg.sender] -= wad;
        totalSupply -= wad;
        (bool success, ) = msg.sender.call{value: wad}("");
        require(success, "!withdraw");
        emit Withdrawal(msg.sender, wad);
    }

    function _approve(
        address src,
        address guy,
        uint256 wad
    ) internal {
        allowance[src][guy] = wad;
        emit Approval(src, guy, wad);
    }

    function approve(address guy, uint256 wad)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad)
        external
        override
        returns (bool)
    {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public override returns (bool) {
        require(balanceOf[src] >= wad, "!balance");

        if (src != msg.sender && allowance[src][msg.sender] != uint256(-1)) {
            require(allowance[src][msg.sender] >= wad, "!allowance");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(block.timestamp <= deadline, "XETH::permit: Expired permit");

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        bytes32 DOMAIN_SEPARATOR =
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256(bytes("1")),
                    chainId,
                    address(this)
                )
            );

        bytes32 hashStruct =
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    owner,
                    spender,
                    value,
                    nonces[owner]++,
                    deadline
                )
            );

        bytes32 hash =
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct)
            );

        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == owner,
            "XETH::permit: invalid permit"
        );

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}


pragma solidity >=0.4.0;

library Babylonian {
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}


pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}


pragma solidity ^0.6.0;

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}


pragma solidity =0.6.6;

contract XethLiqManager is Initializable, OwnableUpgradeSafe {
    IXEth private _xeth;
    IUniswapV2Router02 private _router;
    IUniswapV2Pair private _pair;
    IUniswapV2Factory private _factory;
    uint256 private _maxBP;
    uint256 private _maxLiq;
    bool private isPairInitialized;

    using SafeMath for uint256;

    function initialize(
        IXEth xeth_,
        IUniswapV2Router02 router_,
        IUniswapV2Factory factory_,
        uint256 maxBP_,
        uint256 maxLiq_
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        _xeth = xeth_;
        _router = router_;
        _factory = factory_;
        _maxBP = maxBP_;
        _maxLiq = maxLiq_;
    }

    receive() external payable {}

    function setMaxBP(uint256 maxBP_) external onlyOwner {
        require(maxBP_ < 10000, "maxBP too large");
        _maxBP = maxBP_;
    }

    function setMaxLiq(uint256 maxLiq_) external onlyOwner {
        _maxLiq = maxLiq_;
    }

    function initializePair() external onlyOwner {
        require(!isPairInitialized, "weth/xeth pair already initialized");
        isPairInitialized = true;
        uint256 wadXeth = address(_xeth).balance.mul(_maxBP) / 10000;
        _xeth.xlockerMint(wadXeth.mul(2), address(this));
        _xeth.withdraw(wadXeth);

        _xeth.approve(address(_router), uint256(-1));
        _router.addLiquidityETH{value: wadXeth}(
            address(_xeth),
            wadXeth,
            wadXeth,
            wadXeth,
            address(this),
            now
        );

        _pair = IUniswapV2Pair(
            _factory.getPair(address(_xeth), _router.WETH())
        );
    }

    function updatePair() external onlyOwner {
        require(address(_xeth).balance < 150 ether, "xeth has too much ETH");
        rebalance();

        uint256 currentLockedXeth =
            _xeth.balanceOf(address(_pair)).mul(
                _pair.balanceOf(address(this))
            ) / _pair.totalSupply();

        uint256 delta;
        if (currentLockedXeth > 150 ether) {
            delta = 150 ether - address(_xeth).balance;
        } else {
            delta = currentLockedXeth / 2;
        }

        _router.removeLiquidityETH(
            address(_xeth),
            _pair.totalSupply().mul(delta) / _xeth.balanceOf(address(_pair)),
            delta.sub(0.1 ether),
            delta.sub(0.1 ether),
            address(this),
            now
        );
        _xeth.deposit{value: address(this).balance}();
        _xeth.transfer(address(0x0), _xeth.balanceOf(address(this)));
    }

    function rebalance() public onlyOwner {
        uint256 xethReserves = _xeth.balanceOf(address(_pair));
        uint256 wethReserves = IERC20(_router.WETH()).balanceOf(address(_pair));

        address[] memory path = new address[](2);
        if (xethReserves.sub(0.01 ether) > wethReserves) {
            path[0] = _router.WETH();
            path[1] = address(_xeth);
            uint256 wadDif =
                Babylonian.sqrt(xethReserves.mul(wethReserves)).sub(
                    wethReserves
                );
            _xeth.xlockerMint(wadDif, address(this));
            _xeth.withdraw(wadDif);
            _router.swapExactETHForTokens{value: wadDif}(
                wadDif.sub(0.01 ether),
                path,
                address(0x0),
                now
            );
            _xeth.transfer(address(0x0), _xeth.balanceOf(address(this)));
        } else if (xethReserves.add(0.01 ether) < wethReserves) {
            path[0] = address(_xeth);
            path[1] = _router.WETH();
            uint256 wadDif =
                Babylonian.sqrt(xethReserves.mul(wethReserves)).sub(
                    xethReserves
                );
            _xeth.xlockerMint(wadDif, address(this));
            _router.swapExactTokensForETH(
                wadDif,
                wadDif.sub(0.01 ether),
                path,
                address(this),
                now
            );
            _xeth.deposit{value: address(this).balance}();
            _xeth.transfer(address(0x0), _xeth.balanceOf(address(this)));
        }
    }
}


pragma solidity >=0.5.0;

library UniswapV2Library {
    using SafeMath for uint256;

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                    )
                )
            )
        );
    }

    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) =
            IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) =
                getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) =
                getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


pragma solidity =0.6.6;

interface IXLocker {
    function launchERC20(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth
    ) external returns (address token_, address pair_);

    function launchERC20TransferTax(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth,
        uint256 taxBips,
        address taxMan
    ) external returns (address token_, address pair_);

    function launchERC20TransferBlacklistCheckpointWhitelist(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth,
        address blacklistManager,
        address whitelistManager
    ) external returns (address token_, address pair_);

    function setBlacklistUniswapBuys(
        address pair,
        address token,
        bool isBlacklisted
    ) external;
}


pragma solidity =0.6.6;

contract XLOCKER is Initializable, IXLocker, OwnableUpgradeSafe {
    using SafeMath for uint256;

    IUniswapV2Router02 private _uniswapRouter;
    IXEth private _xeth;
    address private _uniswapFactory;

    address public _sweepReceiver;
    uint256 public _maxXEthWad;
    uint256 public _maxTokenWad;

    mapping(address => uint256) public pairSwept;
    mapping(address => bool) public pairRegistered;
    address[] public allRegisteredPairs;
    uint256 public totalRegisteredPairs;

    mapping(address => address) public pairBlacklistManager;

    function initialize(
        IXEth xeth_,
        address sweepReceiver_,
        uint256 maxXEthWad_,
        uint256 maxTokenWad_,
        IUniswapV2Router02 uniswapRouter_,
        address uniswapFactory_
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        _uniswapRouter = uniswapRouter_;
        _uniswapFactory = uniswapFactory_;
        _xeth = xeth_;
        _sweepReceiver = sweepReceiver_;
        _maxXEthWad = maxXEthWad_;
        _maxTokenWad = maxTokenWad_;
    }

    function registerPair(address pair) external onlyOwner {
        require(!pairRegistered[pair], "Pair already registered.");
        pairRegistered[pair] = true;
        allRegisteredPairs.push(pair);
        totalRegisteredPairs = totalRegisteredPairs.add(1);
    }

    function setSweepReceiver(address sweepReceiver_) external onlyOwner {
        _sweepReceiver = sweepReceiver_;
    }

    function setMaxXEthWad(uint256 maxXEthWad_) external onlyOwner {
        _maxXEthWad = maxXEthWad_;
    }

    function setMaxTokenWad(uint256 maxTokenWad_) external onlyOwner {
        _maxTokenWad = maxTokenWad_;
    }

    function setUniswapRouter(IUniswapV2Router02 uniswapRouter_)
        external
        onlyOwner
    {
        _uniswapRouter = uniswapRouter_;
    }

    function setUniswapFactory(address uniswapFactory_) external onlyOwner {
        _uniswapFactory = uniswapFactory_;
    }

    function launchERC20(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth
    ) external override returns (address token_, address pair_) {
        _preLaunchChecks(wadToken, wadXeth);

        token_ = address(
            new ERC20TransferBlacklistCheckpointWhitelist(
                name,
                symbol,
                wadToken,
                address(0x0),
                address(0x0)
            )
        );

        pair_ = _lockLiquidity(wadToken, wadXeth, token_);

        _registerPair(pair_);

        return (token_, pair_);
    }

    function launchERC20TransferBlacklistCheckpointWhitelist(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth,
        address blacklistManager,
        address whitelistManager
    ) external override returns (address token_, address pair_) {
        _preLaunchChecks(wadToken, wadXeth);

        token_ = address(
            new ERC20TransferBlacklistCheckpointWhitelist(
                name,
                symbol,
                wadToken,
                address(this),
                whitelistManager
            )
        );

        pair_ = _lockLiquidity(wadToken, wadXeth, token_);

        _registerPair(pair_);

        pairBlacklistManager[pair_] = blacklistManager;

        return (token_, pair_);
    }

    function launchERC20TransferTax(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth,
        uint256 taxBips,
        address taxMan
    ) external override returns (address token_, address pair_) {
        _preLaunchChecks(wadToken, wadXeth);
        require(taxBips <= 1000, "taxBips>1000");

        ERC20TransferTax token =
            new ERC20TransferTax(
                name,
                symbol,
                wadToken,
                address(this),
                taxBips
            );
        token.setIsTaxed(address(this), false);
        token.transferTaxman(taxMan);
        token_ = address(token);

        pair_ = _lockLiquidity(wadToken, wadXeth, token_);

        _registerPair(pair_);

        return (token_, pair_);
    }

    function setBlacklistUniswapBuys(
        address pair,
        address token,
        bool isBlacklisted
    ) external override {
        require(
            msg.sender == pairBlacklistManager[pair],
            "xlocker: sender not blacklist manager for pair."
        );
        ERC20TransferBlacklistCheckpointWhitelist(token).setSendBlacklist(
            pair,
            isBlacklisted
        );
    }

    function sweep(IUniswapV2Pair[] calldata pairs) external {
        require(pairs.length < 256, "pairs.length>=256");
        uint8 i;
        for (i = 0; i < pairs.length; i++) {
            IUniswapV2Pair pair = pairs[i];

            uint256 availableToSweep = sweepAmountAvailable(pair);
            if (availableToSweep != 0) {
                pairSwept[address(pair)] += availableToSweep;
                _xeth.xlockerMint(availableToSweep, _sweepReceiver);
            }
        }
    }

    function sweepAmountAvailable(IUniswapV2Pair pair)
        public
        view
        returns (uint256 amountAvailable)
    {
        require(pairRegistered[address(pair)], "!pairRegistered[pair]");

        bool xethIsToken0 = false;
        IERC20 token;
        if (pair.token0() == address(_xeth)) {
            xethIsToken0 = true;
            token = IERC20(pair.token1());
        } else {
            require(
                pair.token1() == address(_xeth),
                "!pair.tokenX==address(_xeth)"
            );
            token = IERC20(pair.token0());
        }

        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

        uint256 burnedLP = pair.balanceOf(address(0));
        uint256 totalLP = pair.totalSupply();

        uint256 reserveLockedXeth =
            uint256(xethIsToken0 ? reserve0 : reserve1).mul(burnedLP) / totalLP;
        uint256 reserveLockedToken =
            uint256(xethIsToken0 ? reserve1 : reserve0).mul(burnedLP) / totalLP;

        uint256 burnedXeth;
        if (reserveLockedToken == token.totalSupply()) {
            burnedXeth = reserveLockedXeth;
        } else {
            burnedXeth = reserveLockedXeth.sub(
                UniswapV2Library.getAmountOut(
                    token
                        .totalSupply()
                        .sub(
                        token.balanceOf(
                            0x000000000000000000000000000000000000dEaD //burn address
                        )
                    )
                        .sub(reserveLockedToken),
                    reserveLockedToken,
                    reserveLockedXeth
                )
            );
        }

        return burnedXeth.sub(pairSwept[address(pair)]);
    }

    function _preLaunchChecks(uint256 wadToken, uint256 wadXeth) internal view {
        require(wadToken <= _maxTokenWad, "wadToken>_maxTokenWad");
        require(wadXeth <= _maxXEthWad, "wadXeth>_maxXEthWad");
    }

    function _lockLiquidity(
        uint256 wadToken,
        uint256 wadXeth,
        address token
    ) internal returns (address pair) {
        _xeth.xlockerMint(wadXeth, address(this));

        IERC20(token).approve(address(_uniswapRouter), wadToken);
        _xeth.approve(address(_uniswapRouter), wadXeth);

        pair = _addLiquidity(IERC20(token), IERC20(_xeth), wadToken, wadXeth);

        pairSwept[pair] = wadXeth;
        return pair;
    }

    function _registerPair(address pair) internal {
        pairRegistered[pair] = true;
        allRegisteredPairs.push(pair);
        totalRegisteredPairs = totalRegisteredPairs.add(1);
    }

    function _addLiquidity(
        IERC20 token,
        IERC20 xeth,
        uint256 wadToken,
        uint256 wadXeth
    ) internal returns (address pair) {
        pair = IUniswapV2Factory(_uniswapFactory).createPair(
            address(xeth),
            address(token)
        );
        (uint256 reserve0, uint256 reserve1, ) =
            IUniswapV2Pair(pair).getReserves();
        require(reserve0 == 0 && reserve1 == 0, "Pair already has reserves");

        require(token.transfer(pair, wadToken), "Transfer Failed");
        require(xeth.transfer(pair, wadXeth), "Transfer Failed");
        IUniswapV2Pair(pair).mint(address(0x0));
    }
}