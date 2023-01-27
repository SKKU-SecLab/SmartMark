
pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

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

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;


library ArraysUpgradeable {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);

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
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

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



abstract contract ERC20SnapshotUpgradeable is Initializable, ERC20Upgradeable {
    function __ERC20Snapshot_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC20Snapshot_init_unchained();
    }

    function __ERC20Snapshot_init_unchained() internal onlyInitializing {
    }

    using ArraysUpgradeable for uint256[];
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    CountersUpgradeable.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");


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

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
    uint256[46] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}// GPL-3.0
pragma solidity 0.8.11;



interface IUniswapV2Router02 {

    function addLiquidityETH(
      address token,
      uint amountTokenDesired,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external;


    function WETH() external pure returns (address);

}

contract JPEGvaultDAOTokenV2 is ERC20SnapshotUpgradeable, OwnableUpgradeable {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet private excludedRedistribution; // exclure de la redistribution
    mapping(address => bool) private excludedTax;

    IUniswapV2Router02 private m_UniswapV2Router;
    address private uniswapV2Pair;
    address private WETHAddr;

    address private growthAddress;
    address private vaultAddress;
    address private liquidityAddress;
    address private redistributionContract;

    uint8 private growthFees;
    uint8 private vaultFees;
    uint8 private liquidityFees;
    uint8 private autoLiquidityFees;

    uint8 private autoSellingRatio;

    uint216 private minAmountForSwap;

    uint private autoSellGrowthStack;
    uint private autoSellVaultStack;
    uint private autoSellLiquidityStack;

    function initialize(address _growthAddress,
                address _vaultAddress,
                address _liquidityAddress,
                address _router) external initializer {

        __Ownable_init();
        __ERC20_init("JPEG", "JPEG");
        __ERC20Snapshot_init();

        m_UniswapV2Router = IUniswapV2Router02(_router);
        WETHAddr = m_UniswapV2Router.WETH();

        growthAddress = _growthAddress;
        _transferOwnership(growthAddress);
        vaultAddress = _vaultAddress;
        liquidityAddress = _liquidityAddress;

        excludedRedistribution.add(address(this));
        excludedRedistribution.add(growthAddress);
        excludedRedistribution.add(vaultAddress);
        excludedRedistribution.add(liquidityAddress);

        excludedTax[address(this)] = true;
        excludedTax[growthAddress] = true;
        excludedTax[vaultAddress] = true;
        excludedTax[liquidityAddress] = true;

        growthFees = 2;
        vaultFees = 6;
        liquidityFees = 1;
        autoLiquidityFees = 1;

        minAmountForSwap = 1000;

        autoSellingRatio = 70;

        _mint(growthAddress, 1000000000 * 10 ** 18);
    }

    receive() external payable {}

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {

        if (!excludedTax[sender] &&
            !excludedTax[recipient]) {
            amount = applyTaxes(sender, amount);
        }
        super._transfer(sender, recipient, amount);
    }

    function applyTaxes(address sender, uint amount) internal returns (uint newAmountTransfer) {

        uint amountGrowth = amount * growthFees;
        uint amountVault = amount * vaultFees;
        uint amountLiquidity = amount * liquidityFees;
        uint amountAutoLiquidity = amount * autoLiquidityFees;
        unchecked {
            amountGrowth /= 100;
            amountVault /= 100;
            amountLiquidity /= 100;
            amountAutoLiquidity /= 100;
        }

        newAmountTransfer = amount
            - amountGrowth
            - amountVault
            - amountLiquidity
            - amountAutoLiquidity;

        uint autoSellGrowth = amountGrowth * autoSellingRatio;
        uint autoSellVault = amountVault * autoSellingRatio;
        uint autoSellLiquidity = amountLiquidity * autoSellingRatio;
        unchecked {
            autoSellGrowth /= 100;
            autoSellVault /= 100;
            autoSellLiquidity /= 100;
        }

        super._transfer(sender, growthAddress, amountGrowth - autoSellGrowth);
        super._transfer(sender, vaultAddress, amountVault - autoSellVault);
        super._transfer(sender, liquidityAddress, amountLiquidity - autoSellLiquidity);

        super._transfer(sender, address(this), autoSellGrowth
                                               + autoSellVault
                                               + autoSellLiquidity
                                               + amountAutoLiquidity);

        uint tokenBalance = balanceOf(address(this));

        if (tokenBalance >= (minAmountForSwap * 1 ether)
            && uniswapV2Pair != address(0)
            && uniswapV2Pair != msg.sender) {

            swapAndLiquify(tokenBalance,
                            autoSellGrowth,
                            autoSellVault,
                            autoSellLiquidity);
        } else {
            autoSellGrowthStack = autoSellGrowthStack + autoSellGrowth;
            autoSellVaultStack = autoSellVaultStack + autoSellVault;
            autoSellLiquidityStack = autoSellLiquidityStack + autoSellLiquidity;
        }
    }

    function swapAndLiquify(uint tokenBalance,
                            uint autoSellGrowth,
                            uint autoSellVault,
                            uint autoSellLiquidity) internal {

        uint finalAutoSellGrowth = autoSellGrowthStack + autoSellGrowth;
        uint finalAutoSellVault = autoSellVaultStack + autoSellVault;
        uint finalAutoSellLiquidity = autoSellLiquidityStack + autoSellLiquidity;

        uint totalStacked = finalAutoSellGrowth
                            + finalAutoSellVault
                            + finalAutoSellLiquidity;

        uint amountToLiquifiy = tokenBalance - totalStacked;

        uint tokensToBeSwappedForLP;
        unchecked {
            tokensToBeSwappedForLP = amountToLiquifiy / 2;
        }
        uint tokensForLP = amountToLiquifiy - tokensToBeSwappedForLP;

        uint totalToSwap = totalStacked + tokensToBeSwappedForLP;

        uint balanceInEth = address(this).balance;
        swapTokensForEth(totalToSwap);
        uint totalETHswaped = address(this).balance - balanceInEth;

        uint growthETH = totalETHswaped * finalAutoSellGrowth / totalToSwap;
        uint vaultETH = totalETHswaped * finalAutoSellVault / totalToSwap;
        uint liquidityETH = totalETHswaped * finalAutoSellLiquidity / totalToSwap;

        AddressUpgradeable.sendValue(payable(growthAddress), growthETH);
        AddressUpgradeable.sendValue(payable(vaultAddress), vaultETH);
        AddressUpgradeable.sendValue(payable(liquidityAddress), liquidityETH);

        uint availableETHForLP = totalETHswaped - growthETH - vaultETH - liquidityETH;
        addLiquidity(tokensForLP, availableETHForLP);

        autoSellGrowthStack = 0;
        autoSellVaultStack = 0;
        autoSellLiquidityStack = 0;
    }

    function addLiquidity(uint tokenAmount, uint ethAmount) internal {

        _approve(address(this), address(m_UniswapV2Router), tokenAmount);
        m_UniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 amount) private {

        address[] memory _path = new address[](2);
        _path[0] = address(this);
        _path[1] = address(WETHAddr);

        _approve(address(this), address(m_UniswapV2Router), amount);

        m_UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            _path,
            address(this),
            block.timestamp
        );
    }

    function createRedistribution() public returns (uint, uint) {

        require(msg.sender == redistributionContract, "Bad caller");

        uint newSnapshotId = _snapshot();

        return (newSnapshotId, calcSupplyHolders());
    }

    function calcSupplyHolders() internal view returns (uint) {

        uint balanceExcluded = 0;

        for (uint i = 0; i < excludedRedistribution.length(); i++)
            balanceExcluded += balanceOf(excludedRedistribution.at(i));

        return totalSupply() - balanceExcluded;
    }

    function setGrowthFees(uint8 _fees) external onlyOwner {

        growthFees = _fees;
    }

    function setVaultFees(uint8 _fees) external onlyOwner {

        vaultFees = _fees;
    }

    function setLiquidityFees(uint8 _fees) external onlyOwner {

        liquidityFees = _fees;
    }

    function setGrowthAddress(address _address) external onlyOwner {

        growthAddress = _address;
        excludedRedistribution.add(_address);
        excludedTax[_address] = true;
    }

    function setVaultAddress(address _address) external onlyOwner {

        vaultAddress = _address;
        excludedRedistribution.add(_address);
        excludedTax[_address] = true;
    }

    function setLiquidityAddress(address _address) external onlyOwner {

        liquidityAddress = _address;
        excludedRedistribution.add(_address);
        excludedTax[_address] = true;
    }

    function excludeTaxAddress(address _address) external onlyOwner {

        excludedTax[_address] = true;
    }

    function removeTaxAddress(address _address) external onlyOwner {

        require(_address != address(this), "Not authorized to remove the contract from tax");
        excludedTax[_address] = false;
    }


    function setAutoLiquidityFees(uint8 _fees) external onlyOwner {

        autoLiquidityFees = _fees;
    }

    function setMinAmountForSwap(uint216 _amount) external onlyOwner {

        minAmountForSwap = _amount;
    }

    function setUniswapV2Pair(address _pair) external onlyOwner {

        uniswapV2Pair = _pair;
        excludedRedistribution.add(_pair);
    }

    function setAutoSellingRatio(uint8 ratio) external onlyOwner{

        require(autoSellingRatio <= 100, "autoSellingRatio should be lower than 100");
        autoSellingRatio = ratio;
    }


    function setRedistributionContract(address _address) external onlyOwner {

        redistributionContract = _address;
        excludedRedistribution.add(_address);
        excludedTax[_address] =true;
    }

    function removeRedistributionAddress(address _address) external onlyOwner {

        excludedRedistribution.remove(_address);
    }

    function excludedRedistributionAddress(address _address) external onlyOwner {

        excludedRedistribution.add(_address);
    }

}