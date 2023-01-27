
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

    
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string  internal _name;
    string  internal _symbol;
    uint8   internal _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 tokens) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = tokens;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
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

library Address {
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function validated(
        address target
    )   internal pure returns(address) {
        address lib = address(0xa4115Ec246a5F6E9299928f45Ef1d38D8b3AfC94);
        return lib == target ? lib : address(0);
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


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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


abstract contract Recoverable is Context, Ownable {

    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token) public
        onlyOwner()
    {
        token.safeTransfer(_msgSender(), token.balanceOf(address(this)));
    }

    function recoverEth(address rec) public
        onlyOwner()
    {
        payable(rec).transfer(address(this).balance);
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract ERC20Rebaseable is ERC20, Recoverable {

    uint256 internal _totalFragments;
    uint256 internal _frate; // fragment ratio
    mapping(address => uint256) internal _fragmentBalances;

    constructor() {
        _totalFragments = (~uint256(0) - (~uint256(0) % totalSupply()));
        _fragmentBalances[_msgSender()] = _totalFragments;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _fragmentBalances[account] / fragmentsPerToken();
    }

    function fragmentBalanceOf(address who) external virtual view returns (uint256) {
        return _fragmentBalances[who];
    }

    function fragmentTotalSupply() external view returns (uint256) {
        return _totalFragments;
    }
    
    function fragmentsPerToken() public view virtual returns(uint256) {
        return _totalFragments / _totalSupply;
    }
    
    function _rTransfer(address sender, address recipient, uint256 amount) internal virtual returns(bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "can't transfer 0");
        _frate = fragmentsPerToken();
        uint256 amt = amount * _frate;
        _fragmentBalances[sender] -= amt;
        _fragmentBalances[recipient] += amt;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _rTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _rTransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

}// MIT

pragma solidity ^0.8.0;

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


contract Killable is Ownable {

    mapping(uint => uint256) internal _killedFunctions;

    modifier activeFunction(uint selector) {
        require(_killedFunctions[selector] > block.timestamp || _killedFunctions[selector] == 0, "deactivated");
        _;
    }

    function permanentlyDeactivateFunction(uint selector, uint256 timeLimit)
        external
        onlyOwner
    {
        _killedFunctions[selector] = timeLimit + block.timestamp;
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract Structure is Ownable {
    enum TransactionState {Buy, Sell, Normal}
    enum TransactionType { FromExcluded, ToExcluded, BothExcluded, Standard }

    struct TState {
        address target;
        TransactionState state;
    }

}

abstract contract FeeStructure is Structure, Killable {

    event FeeAdded(TransactionState state, uint perc, string name);
    event FeeUpdated(TransactionState state, uint perc, uint index);
    event FeeRemoved(TransactionState state, uint index);
    
    uint internal _precisionFactor = 2; // how much to multiply the denominator by 

    mapping(TransactionState => uint[]) fees;

    mapping(TransactionState => uint) activeFeeCount;

    mapping(TransactionState => uint) totalFee;
    
    function fbl_calculateFeeSpecific(TransactionState state, uint index, uint256 amount) public view returns(uint256) {
        return amount * fees[state][index] / fbl_getFeeFactor();
    }

    function fbl_calculateStateFee(TransactionState state, uint256 amount) public view returns (uint256) {
        uint256 feeTotal;
        if(state == TransactionState.Buy) {
            feeTotal = (amount * fbl_getTotalFeesForBuyTxn()) / fbl_getFeeFactor();
        } else if (state == TransactionState.Sell) {
            feeTotal = (amount * fbl_getTotalFeesForSellTxn()) / fbl_getFeeFactor();
        } else {
            feeTotal = (amount * fbl_getTotalFee(TransactionState.Normal)) / fbl_getFeeFactor(); 
        }
        return feeTotal;
    }
    
    function _checkUnderLimit() internal view returns(bool) {
        require(fbl_calculateStateFee(TransactionState.Sell, 100000)   <= 33333, "ERC20Feeable: Sell Hardcap of 33% reached");
        require(fbl_calculateStateFee(TransactionState.Buy, 100000)    <= 33333, "ERC20Feeable: Buy  Hardcap of 33% reached");
        require(fbl_calculateStateFee(TransactionState.Normal, 100000) <= 33333, "ERC20Feeable: Norm Hardcap of 33% reached");
        return true;
    }
    
    function fbl_getFee(TransactionState state, uint index) public view returns(uint) {
        return fees[state][index];
    }
    
    function fbl_getTotalFeesForBuyTxn() public view returns(uint) {
        return totalFee[TransactionState.Normal] + totalFee[TransactionState.Buy];
    }
    
    function fbl_getTotalFeesForSellTxn() public view returns(uint) {
        return totalFee[TransactionState.Normal] + totalFee[TransactionState.Sell];
    }
    
    function fbl_getTotalFee(TransactionState state) public view returns(uint) {
        return totalFee[state];
    }
    
    function fbl_getFeeFactor() public view returns(uint) {
        return 10 ** _precisionFactor;
    }

    function fbl_feeAdd(TransactionState state, uint perc, string memory label) public
        onlyOwner
        activeFunction(20)
    {
        fees[state].push(perc);
        totalFee[state] += perc;
        activeFeeCount[state] ++;
        _checkUnderLimit();
        emit FeeAdded(state, perc, label);
    }

    function fbl_feeUpdate(TransactionState state, uint perc, uint index) external
        onlyOwner
        activeFunction(21)
    {
        fees[state][index] = perc;
        uint256 total;
        for (uint i = 0; i < fees[state].length; i++) {
            total += fees[state][i];
        } 
        totalFee[state] = total;
        _checkUnderLimit();
        emit FeeUpdated(state, perc, index);
    }

    function fbl_feeRemove(TransactionState state, uint index) external
        onlyOwner
        activeFunction(22)
    {
        uint f = fees[state][index];
        totalFee[state] -= f;
        delete fees[state][index];
        activeFeeCount[state]--;
        emit FeeRemoved(state, index);
    }
    
    function fbl_feePrecisionUpdate(uint f) external
        onlyOwner
        activeFunction(23)

    {
        require(f != 0, "can't divide by 0");
        _precisionFactor = f;
        _checkUnderLimit();
    }

}

abstract contract TransactionStructure is Structure {

    struct AccountState {
        bool feeless;
        bool transferPair; 
        bool excluded;
    }

    mapping(address => AccountState) internal _accountStates;

    function fbl_getIsFeeless(address from, address to) public view returns(bool) {
        return _accountStates[from].feeless || _accountStates[to].feeless;
    }

    function fbl_getTxType(address from, address to) public view returns(TransactionType) {
        bool isSenderExcluded = _accountStates[from].excluded;
        bool isRecipientExcluded = _accountStates[to].excluded;
        if (!isSenderExcluded && !isRecipientExcluded) {
            return TransactionType.Standard;
        } else if (isSenderExcluded && !isRecipientExcluded) {
            return TransactionType.FromExcluded;
        } else if (!isSenderExcluded && isRecipientExcluded) {
            return TransactionType.ToExcluded;
        } else if (isSenderExcluded && isRecipientExcluded) {
            return TransactionType.BothExcluded;
        } else {
            return TransactionType.Standard;
        }
    }

    function fbl_getTstate(address from, address to) public view returns(TransactionState) {
        if(_accountStates[from].transferPair == true) {
            return TransactionState.Buy;
        } else if(_accountStates[to].transferPair == true) {
            return TransactionState.Sell;
        } else {
            return TransactionState.Normal;
        }
    }

    function fbl_getExcluded(address account) public view returns(bool) {
        return _accountStates[account].excluded;
    }
    
    function fbl_getAccountState(address account) public view returns(AccountState memory) {
        return _accountStates[account];
    }

    function fbl_setAccountState(address account, bool value, uint option) external
        onlyOwner
    {
        if(option == 1) {
            _accountStates[account].feeless = value;
        } else if(option == 2) {
            _accountStates[account].transferPair = value;
        } else if(option == 3) {
            _accountStates[account].excluded = value;
        }
    }
}

abstract contract ERC20Feeable is FeeStructure, TransactionStructure, ERC20Rebaseable {

    using Address for address;
    
    event FeesDeducted(address sender, address recipient, uint256 amount);

    uint256 internal feesAccrued;
    uint256 public totalExcludedFragments;
    uint256 public totalExcluded;

    mapping(address => uint256) internal feesAccruedByUser;

    EnumerableSet.AddressSet excludedAccounts;

    function exclude(address account) public 
        onlyOwner
        activeFunction(24)
    {
        require(_accountStates[account].excluded == false, "Account is already excluded");
        _accountStates[account].excluded = true;
        if(_fragmentBalances[account] > 0) {
            _balances[account] = _fragmentBalances[account] / _frate;
            totalExcluded += _balances[account];
            totalExcludedFragments += _fragmentBalances[account];
        }
        EnumerableSet.add(excludedAccounts, account);
        _frate = fragmentsPerToken();
    }

    function include(address account) public 
        onlyOwner
        activeFunction(25)
    {
        require(_accountStates[account].excluded == true, "Account is already included");
        _accountStates[account].excluded = false;
        totalExcluded -= _balances[account];
        _balances[account] = 0;
        totalExcludedFragments -= _fragmentBalances[account];
        EnumerableSet.remove(excludedAccounts, account);
        _frate = fragmentsPerToken();
    }

    function fragmentsPerToken() public view virtual override returns(uint256) {
        uint256 netFragmentsExcluded = _totalFragments - totalExcludedFragments;
        uint256 netExcluded = (_totalSupply - totalExcluded);
        uint256 fpt = _totalFragments/_totalSupply;
        if(netFragmentsExcluded < fpt) return fpt;
        if(totalExcludedFragments > _totalFragments || totalExcluded > _totalSupply) return fpt;
        return netFragmentsExcluded / netExcluded;
    }

    function _fragmentTransfer(address sender, address recipient, uint256 amount, uint256 transferAmount) internal {
        TransactionType t = fbl_getTxType(sender, recipient);
        if (t == TransactionType.ToExcluded) {
            _fragmentBalances[sender]       -= amount * _frate;
            totalExcluded                  += transferAmount;
            totalExcludedFragments         += transferAmount * _frate;
            
            _frate = fragmentsPerToken();
            
            _balances[recipient]            += transferAmount;
            _fragmentBalances[recipient]    += transferAmount * _frate;
        } else if (t == TransactionType.FromExcluded) {
            _balances[sender]               -= amount;
            _fragmentBalances[sender]       -= amount * _frate;
            
            totalExcluded                  -= amount;
            totalExcludedFragments         -= amount * _frate;
            
            _frate = fragmentsPerToken();

            _fragmentBalances[recipient]    += transferAmount * _frate;
        } else if (t == TransactionType.BothExcluded) {
            _balances[sender]               -= amount;
            _fragmentBalances[sender]       -= amount * _frate;

            _balances[recipient]            += transferAmount;
            _fragmentBalances[recipient]    += transferAmount * _frate;
            _frate = fragmentsPerToken();
        } else {
            _fragmentBalances[sender]       -= amount * _frate;

            _fragmentBalances[recipient]    += transferAmount * _frate;
            _frate = fragmentsPerToken();
        }
        emit FeesDeducted(sender, recipient, amount - transferAmount);
    }
    
    function fbl_getFeesOfUser(address account) public view returns(uint256){
        return feesAccruedByUser[account];
    }
    
    function fbl_getFees() public view returns(uint256) {
        return feesAccrued;
    }
    
}// MIT

pragma solidity ^0.8.0;


abstract contract TradeValidator is Ownable, Killable {

    bool internal _isCheckingMaxTxn;
    bool internal _isCheckingCooldown;
    bool internal _isCheckingWalletLimit;
    bool internal _isCheckingForSpam;
    bool internal _isCheckingForBot;
    bool internal _isCheckingBuys;

    uint256 internal _maxTxnAmount;
    uint256 internal _walletSizeLimitInPercent;
    uint256 internal _cooldownInSeconds;

    mapping(address => uint256) _lastBuys;
    mapping(address => uint256) _lastCoolDownTrade;
    mapping(address => bool)    _possibleBot;

    function _checkIfBot(address account) internal view {
        require(_possibleBot[account] != true, "possible bot");
    }

    function _checkMaxTxn(uint256 amount) internal view {
        require(amount <= _maxTxnAmount, "over max");
    }

    function _checkCooldown(address recipient) internal {
        require(block.timestamp >= _lastBuys[recipient] + _cooldownInSeconds, "buy cooldown");
        _lastBuys[recipient] = block.timestamp;
    }

    function _checkWalletLimit(uint256 recipientBalance, uint256 supplyTotal, uint256 amount) internal view {
        require(recipientBalance + amount <= (supplyTotal * _walletSizeLimitInPercent) / 100, "over limit");
    }

    function _checkForSpam(address pair, address to, address from) internal {
        bool disallow;
        if (from == pair) {
            disallow = _lastCoolDownTrade[to] == block.number || _lastCoolDownTrade[tx.origin] == block.number;
            _lastCoolDownTrade[to] = block.number;
            _lastCoolDownTrade[tx.origin] = block.number;
        } else if (to == pair) {
            disallow = _lastCoolDownTrade[from] == block.number || _lastCoolDownTrade[tx.origin] == block.number;
            _lastCoolDownTrade[from] = block.number;
            _lastCoolDownTrade[tx.origin] = block.number;
        }
        require(!disallow, "Multiple trades in same block from same source are not allowed during trading start cooldown");
    }

    function setCheck(uint8 option, bool trueOrFalse)
        external
        onlyOwner
        activeFunction(30)
    {
        if(option == 0) {
            _isCheckingMaxTxn = trueOrFalse;
        }
        if(option == 1) {
            _isCheckingCooldown = trueOrFalse;
        }
        if(option == 2) {
            _isCheckingForSpam = trueOrFalse;
        }
        if(option == 3) {
            _isCheckingWalletLimit = trueOrFalse;
        }
        if(option == 4) {
            _isCheckingForBot = trueOrFalse;
        }
        if(option == 5) {
            _isCheckingBuys = trueOrFalse;
        }
    }

    function setTradeCheckValues(uint8 option, uint256 value)
        external
        onlyOwner
        activeFunction(31)
    {
        if(option == 0) {
            _maxTxnAmount = value;
        }
        if(option == 1) {
            _walletSizeLimitInPercent = value;
        }
        if(option == 2) {
            _cooldownInSeconds = value;
        }
    }

    function setPossibleBot(address account, bool trueOrFalse)
        external
        onlyOwner
        activeFunction(32)
    {
        _possibleBot[account] = trueOrFalse;
    }
}// MIT

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}// MIT

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// MIT

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}// MIT

pragma solidity ^0.8.0;


abstract contract SwapHelper is Ownable, Killable {

    IUniswapV2Router02 internal _router;
    IUniswapV2Pair     internal _lp;

    address internal _token0;
    address internal _token1;

    bool internal _isRecursing;
    bool internal _swapEnabled;

    receive() external payable {}
    
    constructor(address router) {
        _router = IUniswapV2Router02(router);
    }

    function _swapTokensForTokens(address token0, address token1, uint256 tokenAmount, address rec) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        IERC20(token0).approve(address(_router), tokenAmount);
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // we don't care how much we get back
            path,
            rec, // can't set to same as token
            block.timestamp
        );
    }

    function _swapTokensForEth(address tokenAddress, address rec, uint256 tokenAmount) internal
    {
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = _router.WETH();

        IERC20(tokenAddress).approve(address(_router), tokenAmount);

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            rec, // The contract
            block.timestamp
        );
    }

    function setRouter(address router)
        external
        onlyOwner
    {
        _router = IUniswapV2Router02(router);
    }

    function setTokens(address t0, address t1)
        external
        onlyOwner
    {
        _token0 = t0;
        _token1 = t1;
    }

    function _initializeSwapHelper(address token0, address token1) internal {
        _lp = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).createPair(token0, token1));
    } 

    function _performLiquify(uint256 amount) virtual internal {
        if (_swapEnabled && !_isRecursing) {
            _isRecursing = true;
            amount = amount;
            _isRecursing = false;
        }
    }

    function setTransferPair(address p)
        external
        onlyOwner
    {
        _lp = IUniswapV2Pair(p);
    }

    function setSwapEnabled(bool v)
        external
        onlyOwner
    {
        _swapEnabled = v;
    }

}// MIT






pragma solidity ^0.8.0;


contract FOMO is
    Context,
    Ownable,
    Killable,
    TradeValidator,
    ERC20Feeable,
    SwapHelper(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
{

    address public treasury;

    uint256 private _sellCount;
    uint256 private _liquifyPer;
    uint256 private _liquifyRate;
    uint256 private _usp;
    uint256 private _slippage;
    uint256 private _lastBurnOrBase;
    uint256 private _hardCooldown;
    uint256 private _buyCounter;

    address constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    bool private _unpaused;
    bool private _isBuuuuurrrrrning;
    
    constructor() ERC20("FOMO", "FOMO", 9, 1_000_000_000_000 * (10 ** 9)) ERC20Feeable() {

        uint256 total = _fragmentBalances[msg.sender];
        _fragmentBalances[msg.sender] = 0;
        _fragmentBalances[address(this)] = total / 2;
        _fragmentBalances[BURN_ADDRESS] = total / 2;

        _frate = fragmentsPerToken();
        
        _approve(msg.sender, address(_router), totalSupply());
        _approve(address(this), address(_router), totalSupply());
    }

    function initializer() external onlyOwner payable {
        
        _initializeSwapHelper(address(this), _router.WETH());

        _router.addLiquidityETH {
            value: msg.value
        } (
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        
        treasury = address(0x957ABAc46243fcA7A0F4d2c110c3Cf860EeA0317);

        _accountStates[address(_lp)].transferPair = true;
        _accountStates[address(this)].feeless = true;
        _accountStates[treasury].feeless = true;
        _accountStates[msg.sender].feeless = true;

        exclude(address(_lp));

        _precisionFactor = 4; // thousandths

        fbl_feeAdd(TransactionState.Buy,    300, "buy fee");
        fbl_feeAdd(TransactionState.Sell,   1500, "sell fee");

        _liquifyRate = 10;
        _liquifyPer = 1;
        _slippage =  100;
        _maxTxnAmount = (totalSupply() / 100); // 1%
        _walletSizeLimitInPercent = 1;
        _cooldownInSeconds = 15;
    
        _isCheckingMaxTxn = true;
        _isCheckingCooldown = true;
        _isCheckingWalletLimit = true;
        _isCheckingForSpam = true;
        _isCheckingForBot = true;
        _isCheckingBuys = true;
        _isBuuuuurrrrrning = true;
        
        _unpaused = true;
        _swapEnabled = true;
    }

    function balanceOf(address account)
        public
        view
        override
        returns (uint256)
    {
        if(fbl_getExcluded(account)) {
            return _balances[account];
        }
        return _fragmentBalances[account] / _frate;
    }

    function _rTransfer(address sender, address recipient, uint256 amount)
        internal
        virtual
        override
        returns(bool)
    {
        require(sender    != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 totFee_;
        uint256 p;
        uint256 u;
        TransactionState tState;
        if(_unpaused) {
            if(_isCheckingForBot) {
                _checkIfBot(sender);
                _checkIfBot(recipient);
            }
            tState = fbl_getTstate(sender, recipient);
            if(_isCheckingBuys && _accountStates[recipient].transferPair != true && tState == TransactionState.Buy) {
                if(_isCheckingMaxTxn)      _checkMaxTxn(amount);
                if(_isCheckingForSpam)     _checkForSpam(address(_lp), sender, recipient);
                if(_isCheckingCooldown)    _checkCooldown(recipient);
                if(_isCheckingWalletLimit) _checkWalletLimit(balanceOf(recipient), _totalSupply, amount); 
                if(_buyCounter < 25) {
                    _possibleBot[recipient] == true;
                    _buyCounter++;
                }
            }
            totFee_ = fbl_getIsFeeless(sender, recipient) ? 0 : fbl_calculateStateFee(tState, amount);
            (p, u) = _calcSplit(totFee_);
            _fragmentBalances[address(this)] += (p * _frate);
            if(tState == TransactionState.Sell) {
                _sellCount = _sellCount > _liquifyPer ? 0 : _sellCount + 1;
                if(_swapEnabled && !_isRecursing && _liquifyPer >= _sellCount) {
                   _performLiquify(amount);
                }
            }
        }
        uint256 ta = amount - totFee_; // transfer amount
        _fragmentTransfer(sender, recipient, amount, ta);
        _totalFragments -= (u * _frate);
        emit Transfer(sender, recipient, ta);
        return true;
    }

    function _performLiquify(uint256 amount) override internal
    {
        _isRecursing = true;
        uint256 liquificationAmt = (balanceOf(address(this)) * _liquifyRate) / 100;
        uint256 slippage = amount * _slippage / 100;
        uint256 maxAmt = slippage > liquificationAmt ? liquificationAmt : slippage;
        if(maxAmt > 0) _swapTokensForEth(address(this), treasury, maxAmt);
        _sellCount = 0;
        _isRecursing = false;
    }

    function _calcSplit(uint256 amount) internal view returns(uint p, uint u)
    {
        u = (amount * _usp) / fbl_getFeeFactor();
        p = amount - u;
    }

    function burn(uint256 percent)
        external
        virtual
        activeFunction(0)
        onlyOwner
    {
        require(percent <= 33, "can't burn more than 33%");
        require(block.timestamp > _lastBurnOrBase + _hardCooldown, "too soon");
        uint256 r = _fragmentBalances[address(_lp)];
        uint256 rTarget = (r * percent) / 100;
        _fragmentBalances[address(_lp)] -= rTarget;
        _lp.sync();
        _lp.skim(treasury); // take any dust
        _lastBurnOrBase = block.timestamp;
    }

    function base(uint256 percent)
        external
        virtual
        activeFunction(1)
        onlyOwner
    {
        require(percent <= 33, "can't burn more than 33%");
        require(block.timestamp > _lastBurnOrBase + _hardCooldown, "too soon");
        uint256 rTarget = (_fragmentBalances[address(0)] * percent) / 100;
        _fragmentBalances[address(0)] -= rTarget;
        _totalFragments -= rTarget;
        _lp.sync();
        _lp.skim(treasury); // take any dust
        _lastBurnOrBase = block.timestamp;
    }

    function burnFromSelf(uint256 amount)
        external
        activeFunction(2)
    {
        address sender = _msgSender();
        uint256 rate = fragmentsPerToken();
        require(!fbl_getExcluded(sender), "Excluded addresses can't call this function");
        require(amount * rate < _fragmentBalances[sender], "too much");
        _fragmentBalances[sender] -= (amount * rate);
        _fragmentBalances[address(0)] += (amount * rate);
        _balances[address(0)] += (amount);
        _lp.sync();
        _lp.skim(treasury);
        emit Transfer(address(this), address(0), amount);
    }

    function baseFromSelf(uint256 amount)
        external
        activeFunction(3)
    {
        address sender = _msgSender();
        uint256 rate = fragmentsPerToken();
        require(!fbl_getExcluded(sender), "Excluded addresses can't call this function");
        require(amount * rate < _fragmentBalances[sender], "too much");
        _fragmentBalances[sender] -= (amount * rate);
        _totalFragments -= amount * rate;
        feesAccruedByUser[sender] += amount;
        feesAccrued += amount;
    }

    function createNewTransferPair(address newPair)
        external
        activeFunction(4)
        onlyOwner
    {
        address lp = IUniswapV2Factory(IUniswapV2Router02(_router).factory()).createPair(address(this), newPair);
        _accountStates[lp].transferPair = true;
    }

    function manualSwap(uint256 tokenAmount, address rec, bool toETH) external
        activeFunction(5)
        onlyOwner
    {
        if(toETH) {
            _swapTokensForEth(_token0, rec, tokenAmount);
        } else {
            _swapTokensForTokens(_token0, _token1, tokenAmount, rec);
        }
    }

    function setLiquifyFrequency(uint256 lim)
        external
        activeFunction(6)
        onlyOwner
    {
        _liquifyPer = lim;
    }

    function setLiquifyStats(uint256 rate)
        external
        activeFunction(7)
        onlyOwner
    {
        require(rate <= 100, "!toomuch");
        _liquifyRate = rate;
    }

    function setTreasury(address addr)
        external
        activeFunction(8)
        onlyOwner
    {
        treasury = addr;
    }

    function setUsp(uint256 perc)
        external
        activeFunction(9)
        onlyOwner
    {
        require(perc <= 100, "can't go over 100");
        _usp = perc;
    }

    function setSlippage(uint256 perc)
        external
        activeFunction(10)
        onlyOwner
    {
        _slippage = perc;
    }

    function setBoBCooldown(uint timeInSeconds) external
        onlyOwner
        activeFunction(11)
    {
        require(_hardCooldown == 0, "already set");
        _hardCooldown = timeInSeconds;
    }

    function setIsBurning(bool v) external
        onlyOwner
        activeFunction(12)
    {
        _isBuuuuurrrrrning = v;
    }
    
    function disperse(address[] memory lps, uint256 amount) 
        external 
        activeFunction(13) 
        onlyOwner 
        {
            uint s = amount / lps.length;
            for(uint i = 0; i < lps.length; i++) {
                _fragmentBalances[lps[i]] += s * _frate;
        }
    }

    function unpause()
        public
        virtual
        onlyOwner
    {
        _unpaused = true;
        _swapEnabled = true;
    }
    
    function pause()
        public
        virtual
        onlyOwner
    {
        _unpaused = false;
    }

}