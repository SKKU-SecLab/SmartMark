


pragma solidity ^0.8.4;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

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

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}
    
    abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ERC20 {

    function totalSupply() external returns (uint);

    function balanceOf(address who) external returns (uint);

    function transferFrom(address from, address to, uint value) external;

    function transfer(address to, uint value) external;

    event Transfer(address indexed from, address indexed to, uint value);
}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    
    
    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
    
    function ceil(uint a, uint m) internal pure returns (uint r) {

        return (a + m - 1) / m * m;
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract fUSDC is IERC20, ReentrancyGuard {

    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    enum TxType { FromExcluded, ToExcluded, BothExcluded, Standard }

    mapping (address => uint256) private rUsdcBalance;
    mapping (address => uint256) private tUsdcBalance;
    mapping (address => mapping (address => uint256)) private _allowances;

    EnumerableSet.AddressSet excluded;

    uint256 private tUsdcSupply;
    uint256 private rUsdcSupply;
    uint256 private feesAccrued;
 
    string private _name = 'FEG Wrapped USDC'; 
    string private _symbol = 'fUSDC';
    uint8  private _decimals = 6;
    
    address private op;
    address private op2;
    IERC20 public lpToken;
    
    event  Deposit(address indexed dst, uint amount);
    event  Withdrawal(address indexed src, uint amount);

    constructor (address _lpToken) {
        op = address(0x4c9BC793716e8dC05d1F48D8cA8f84318Ec3043C);
        op2 = op;
        lpToken = IERC20(_lpToken);
        EnumerableSet.add(excluded, address(0)); // stablity - zen.
        emit Transfer(address(0), msg.sender, 0);
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

    function totalSupply() public view override returns (uint256) {

        return tUsdcSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (EnumerableSet.contains(excluded, account)) return tUsdcBalance[account];
        (uint256 r, uint256 t) = currentSupply();
        return (rUsdcBalance[account] * t)  / r;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function isExcluded(address account) public view returns (bool) {

        return EnumerableSet.contains(excluded, account);
    }

    function totalFees() public view returns (uint256) {

        return feesAccrued;
    }
    
    function deposit(uint256 _amount) public  {

        require(_amount > 0, "can't deposit nothing");
        lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = _amount / 100; 
        uint256 df = fee / 10;
        uint256 net = fee != 0 ? (_amount - (fee)) : _amount;
        tUsdcSupply += _amount;
        if(isExcluded(msg.sender)){
            tUsdcBalance[msg.sender] += (_amount- fee);
        } 
        feesAccrued += df;
        rUsdcBalance[op] += ((df * r) / t);
        rUsdcSupply += (((net + df) * r) / t);
        rUsdcBalance[msg.sender] += ((net * r) / t);
        emit Deposit(msg.sender, _amount);
    }
    
    function withdraw(uint256 _amount) public  {

        require(balanceOf(msg.sender) >= _amount && _amount <= totalSupply(), "invalid _amount");
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = _amount / 100;
        uint256 wf = fee / 10;
        uint256 net = _amount - fee;
        if(isExcluded(msg.sender)) {
            tUsdcBalance[msg.sender] -= _amount;
            rUsdcBalance[msg.sender] -= ((_amount * r) / t);
        } else {
            rUsdcBalance[msg.sender] -= ((_amount * r) / t);
        }
        tUsdcSupply -= (net + wf);
        rUsdcSupply -= (((net + wf) * r ) / t);
        rUsdcBalance[op] += ((wf * r) / t);
        feesAccrued += wf;
        lpToken.safeTransfer(msg.sender, net);
        emit Withdrawal(msg.sender, net);
    }
    
    function rUsdcToEveryone(uint256 amt) public {

        require(!isExcluded(msg.sender), "not allowed");
        (uint256 r, uint256 t) = currentSupply();
        rUsdcBalance[msg.sender] -= ((amt * r) / t);
        rUsdcSupply -= ((amt * r) / t);
        feesAccrued += amt;
    }

    function excludeFromFees(address account) external {

        require(msg.sender == op2, "op only");
        require(!EnumerableSet.contains(excluded, account), "address excluded");
        if(rUsdcBalance[account] > 0) {
            (uint256 r, uint256 t) = currentSupply();
            tUsdcBalance[account] = (rUsdcBalance[account] * (t)) / (r);
        }
        EnumerableSet.add(excluded, account);
    }

    function includeInFees(address account) external {

        require(msg.sender == op2, "op only");
        require(EnumerableSet.contains(excluded, account), "address excluded");
        tUsdcBalance[account] = 0;
        EnumerableSet.remove(excluded, account);
    }
    
    function tUsdcFromrUsdc(uint256 rUsdcAmount) external view returns (uint256) {

        (uint256 r, uint256 t) = currentSupply();
        return (rUsdcAmount * t) / r;
    }


    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getTtype(address sender, address recipient) internal view returns (TxType t) {

        bool isSenderExcluded = EnumerableSet.contains(excluded, sender);
        bool isRecipientExcluded = EnumerableSet.contains(excluded, recipient);
        if (isSenderExcluded && !isRecipientExcluded) {
            t = TxType.FromExcluded;
        } else if (!isSenderExcluded && isRecipientExcluded) {
            t = TxType.ToExcluded;
        } else if (!isSenderExcluded && !isRecipientExcluded) {
            t = TxType.Standard;
        } else if (isSenderExcluded && isRecipientExcluded) {
            t = TxType.BothExcluded;
        } else {
            t = TxType.Standard;
        }
        return t;
    }
    function _transfer(address sender, address recipient, uint256 amt) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amt > 0, "Transfer amt must be greater than zero");
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = amt / 100;
        TxType tt = getTtype(sender, recipient);
        if (tt == TxType.ToExcluded) {
            rUsdcBalance[sender] -= ((amt * r) / t);
            tUsdcBalance[recipient] += (amt - fee);
            rUsdcBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.FromExcluded) {
            tUsdcBalance[sender] -= (amt);
            rUsdcBalance[sender] -= ((amt * r) / t);
            rUsdcBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.BothExcluded) {
            tUsdcBalance[sender] -= (amt);
            rUsdcBalance[sender] -= ((amt * r) / t);
            tUsdcBalance[recipient] += (amt - fee);
            rUsdcBalance[recipient] += (((amt - fee) * r) / t);
        } else {
            rUsdcBalance[sender] -= ((amt * r) / t);
            rUsdcBalance[recipient] += (((amt - fee) * r) / t);
        }
        rUsdcSupply  -= ((fee * r) / t);
        feesAccrued += fee;
        emit Transfer(sender, recipient, amt - fee);
    }

    function currentSupply() public view returns(uint256, uint256) {

        if(rUsdcSupply == 0 || tUsdcSupply == 0) return (1000000000, 1);
        uint256 rSupply = rUsdcSupply;
        uint256 tSupply = tUsdcSupply;
        for (uint256 i = 0; i < EnumerableSet.length(excluded); i++) {
            if (rUsdcBalance[EnumerableSet.at(excluded, i)] > rSupply || tUsdcBalance[EnumerableSet.at(excluded, i)] > tSupply) return (rUsdcSupply, tUsdcSupply);
            rSupply -= (rUsdcBalance[EnumerableSet.at(excluded, i)]);
            tSupply -= (tUsdcBalance[EnumerableSet.at(excluded, i)]);
        }
        if (rSupply < rUsdcSupply / tUsdcSupply) return (rUsdcSupply, tUsdcSupply);
        return (rSupply, tSupply);
    }
    
    function setOp(address opper, address opper2) external {

        require(msg.sender == op, "only op can call");
        op = opper;
        op2 = opper2;
    }
}