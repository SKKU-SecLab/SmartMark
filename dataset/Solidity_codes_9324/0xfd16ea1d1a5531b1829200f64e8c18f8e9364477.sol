



pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




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
}




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
}




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
}




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
}




pragma solidity ^0.8.0;

interface IBoringToken is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}




pragma solidity ^0.8.0;

struct SwapInParams {
    address to;
    uint amount1;
    uint feeAmountFix; 
    uint remainAmount;
    address feeToDev;
    uint chainID;
}




pragma solidity ^0.8.0;

interface ISwapPair {
    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address from,
        address to,
        uint256 amount,
        address feeTo,
        uint256 feeAmount
    )
        external
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        );

    function token0() external returns (address);

    function swapOut(
        address to,
        uint256 amount,
        uint256 chainid
    ) external; // direction: token0 -> token1 or token1 -> token0



    function swapIn(
        SwapInParams memory params
    ) external;

    function getReserves(uint256 chainid) external view returns (uint256, uint256);

    function update() external;

    function diff0() external returns (uint256);

    function addChainIDs(uint256[] memory chainids) external;

    function removeChainIDs(uint256[] memory chainids) external;
}




pragma solidity ^0.8.0;


interface ISwapPairV1 is IERC20 {
    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address from,
        address to,
        uint256 amount,
        address feeTo,
        uint256 feeAmount
    )
        external
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        );

    function token0() external returns (address);

    function swapOut(
        address to,
        uint256 amount,
        uint256 chainid
    ) external; // direction: token0 -> token1 or token1 -> token0



    function swapIn(
        SwapInParams memory params
    ) external;

    function getReserves(uint256 chainid) external view returns (uint256, uint256);

    function update() external;

    function diff0() external returns (uint256);

    function addChainIDs(uint256[] memory chainids) external;

    function removeChainIDs(uint256[] memory chainids) external;
    function getSupportChainIDs() external view returns(uint256[] memory);
    function getLPAmount(uint256 amount) external view returns (uint256 lpAmount);

    function reserve0() external view returns(uint256);
    function twoWay() external view returns(address);
    function reserve1s(uint256 chainId) external view returns(uint256);
    function totalReserve1s() external view returns(uint256); 
}



pragma solidity ^0.8.0;


library SafeDecimalMath {
    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {
        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {
        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {
        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {
        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {
        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}




pragma solidity ^0.8.0;












contract SwapPairV2 is ERC20, Ownable, ISwapPair {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ISwapPairV1;
    using SafeDecimalMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    ISwapPairV1 public oldSwapPair;

    address public override token0; // origin erc20 token

    uint256 public reserve0;

    EnumerableSet.UintSet private supportChainids;
    mapping(uint256 => uint256) public reserve1s;
    uint256 public totalReserve1s;

    address public twoWay;

    uint256 public override diff0;

    event Mint(address indexed sender, uint256 amount);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amountIn, uint256 amountOut, address indexed to);

    constructor(
        ISwapPairV1 _oldSwapPair,
        string memory _name,
        string memory _symbol,
        address _token0,
        uint256[] memory chainIds
    ) ERC20(_name, _symbol) {
        oldSwapPair = _oldSwapPair;
        uint256 token0Decimals = IERC20Metadata(_token0).decimals();
        require(token0Decimals < 19, "token0 decimals too big");
        token0 = _token0;
        diff0 = 10**(18 - token0Decimals);
        updateOld(chainIds);
    }

    function updateOld(uint256[] memory chainIds) public onlyOwner {
        updateReserve0();
        updateReserve1s(chainIds);
        updateSupportChainids(chainIds);
        updateTwoWay();
    }

    function updateReserve0() internal {
        reserve0 = oldSwapPair.reserve0();
    }

    function updateReserve1s(uint256[] memory chainIds) internal {
        for (uint256 i; i < chainIds.length; i++) {
            reserve1s[chainIds[i]] = oldSwapPair.reserve1s(chainIds[i]);
        }

        totalReserve1s = oldSwapPair.totalReserve1s();
    }

    function updateSupportChainids(uint256[] memory chainids) internal {
        for (uint256 i; i < chainids.length; i++) {
            supportChainids.add(chainids[i]);
        }
    }

    function updateTwoWay() internal {
        twoWay = oldSwapPair.twoWay();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account) + oldBalanceOf(account);
    }
    function oldBalanceOf(address account) public view returns (uint256) {
        return oldSwapPair.balanceOf(account);
    }

    function totalSupply() public view override returns (uint256) {
        return super.totalSupply() + oldTotalSupply();
    }


    function oldTotalSupply() public view returns (uint256) {
        return oldSwapPair.totalSupply() - oldSwapPair.balanceOf(address(1));
    }

    function getReserves(uint256 chainId) public view override returns (uint256, uint256) {
        return (reserve0, reserve1s[chainId]);
    }

    function getSupportChainIDs() external view returns (uint256[] memory) {
        uint256[] memory chainids = new uint256[](supportChainids.length());
        for (uint256 i; i < supportChainids.length(); i++) {
            chainids[i] = supportChainids.at(i);
        }
        return chainids;
    }

    function setTwoWay(address _twoWay) external onlyOwner {
        twoWay = _twoWay;
    }

    function addChainIDs(uint256[] memory chainids) external override onlyTwoWay {
        for (uint256 i; i < chainids.length; i++) {
            supportChainids.add(chainids[i]);
        }
    }

    function removeChainIDs(uint256[] memory chainids) external override onlyTwoWay {
        for (uint256 i; i < chainids.length; i++) {
            supportChainids.remove(chainids[i]);
        }
    }

    function oldMint() public {
        uint256 oldBalance = oldSwapPair.balanceOf(msg.sender);
        if (oldBalance > 0) {
            oldSwapPair.safeTransferFrom(msg.sender, address(1), oldBalance);
            _mint(msg.sender, oldBalance);
        }
    }

    function mint(address to) external override onlyTwoWay needOldMint(to) returns (uint256 lpAmount) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 amount0 = balance0.sub(reserve0);

        lpAmount = getLPAmount(amount0);

        require(lpAmount > 0, "SwapPair: insufficient liquidity minted");
        _mint(to, lpAmount);
        reserve0 = balance0;

        emit Mint(msg.sender, lpAmount);
    }

    function getLPAmount(uint256 amount) public view returns (uint256 lpAmount) {
        uint256 amountAdjust = amount * diff0;
        uint256 _reserve0 = reserve0 * diff0;
        uint256 total = totalSupply();
        if (total == 0) {
            lpAmount = amountAdjust;
        } else {
            lpAmount = (amountAdjust * total) / (totalReserve1s + _reserve0);
        }
    }

    function burn(
        address from,
        address to,
        uint256 lpAmount,
        address feeTo,
        uint256 feeAmount
    )
        external
        override
        onlyTwoWay
        needOldMint(from)
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        (uint256 amount0, uint256[] memory chainids, uint256[] memory amount1s) = calculateBurn(lpAmount);
        IERC20(token0).safeTransfer(from, amount0 - feeAmount);
        if (feeAmount > 0) {
            IERC20(token0).safeTransfer(feeTo, feeAmount);
        }
        uint256 totalRemove;
        for (uint256 i; i < chainids.length; i++) {
            if (amount1s[i] > 0) {
                reserve1s[chainids[i]] -= amount1s[i];
                totalRemove += amount1s[i];
            }
        }

        _burn(from, lpAmount);

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        reserve0 = balance0;
        totalReserve1s -= totalRemove;

        emit Burn(msg.sender, amount0, totalRemove, to);
        return (amount0, chainids, amount1s);
    }

    function calculateBurn(uint256 lpAmount)
        public
        view
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256 _reserve0 = reserve0 * diff0;
        uint256 _totalSupply = totalSupply();
        uint256 value = (lpAmount * (_reserve0 + totalReserve1s)) / _totalSupply;

        if (value <= _reserve0) {
            uint256 amount0 = value / diff0;
            uint256[] memory chainids = new uint256[](0);
            uint256[] memory amounts = new uint256[](0);
            return (amount0, chainids, amounts);
        } else {
            uint256 amount = value - _reserve0;
            uint256 chainidLength = supportChainids.length();
            uint256[] memory chainids = new uint256[](chainidLength);
            uint256[] memory amounts = new uint256[](chainidLength);
            for (uint256 i; i < chainidLength; i++) {
                uint256 chainid = supportChainids.at(i);
                if (reserve1s[chainid] >= amount) {
                    chainids[i] = chainid;
                    amounts[i] = amount;
                    break;
                } else {
                    chainids[i] = chainid;
                    amounts[i] = reserve1s[chainid];
                    amount = amount - reserve1s[chainid];
                }
            }
            return (reserve0, chainids, amounts);
        }
    }

    function update() external override onlyTwoWay {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        reserve0 = balance0;
    }

    function swapOut(
        address to,
        uint256 amount0,
        uint256 chainID
    ) external override onlyTwoWay onlySupportChainID(chainID) {
        (, uint256 _reserve1) = getReserves(chainID);

        require(_reserve1 >= amount0 * diff0, "SwapPair: insuffient liquidity");

        reserve1s[chainID] -= amount0 * diff0;
        totalReserve1s -= amount0 * diff0;

        uint256 balance0 = IERC20(token0).balanceOf(address(this));

        reserve0 = balance0;

        emit Swap(msg.sender, amount0, amount0 * diff0, to);
    }

    function swapIn(SwapInParams memory params) external override onlyTwoWay onlySupportChainID(params.chainID) {
        uint256 _reserve0 = reserve0;

        require(_reserve0 >= params.amount1, "Insuffient liquidity");
        require(params.amount1 > 0, "Swap amount should be greater than 0");

        IERC20(token0).safeTransfer(params.to, params.remainAmount);
        if (params.feeAmountFix > 0) {
            IERC20(token0).safeTransfer(params.feeToDev, params.feeAmountFix);
        }
        reserve1s[params.chainID] += params.amount1 * diff0;
        totalReserve1s += params.amount1 * diff0;

        uint256 balance0 = IERC20(token0).balanceOf(address(this));

        reserve0 = balance0;

        emit Swap(msg.sender, params.amount1 * diff0, params.amount1 * diff0, params.to);
    }

    modifier onlyTwoWay() {
        require(msg.sender == twoWay, "SwapPair: only twoWay can invoke it");
        _;
    }

    modifier onlySupportChainID(uint256 chainID) {
        require(supportChainids.contains(chainID), "not support chainID");
        _;
    }

    modifier needOldMint(address acc) {
        uint256 oldBalance = oldSwapPair.balanceOf(acc);
        if (oldBalance > 0) {
            oldSwapPair.safeTransferFrom(acc, address(1), oldBalance);
            _mint(acc, oldBalance);
        }
        _;
    }
}