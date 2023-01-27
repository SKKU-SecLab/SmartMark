
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.8.6;


interface IBridgeSwap {

    function swap(
        IERC20 tokenIn,
        uint amount,
        IERC20 tokenOut,
        address to,
        address[] calldata swapPath
    ) external returns (uint out);

    function swapToNative(
        IERC20 tokenIn,
        uint amount,
        address payable to,
        address[] calldata swapPath
    ) external returns (uint out);

    function swapFromNative(
        IERC20 tokenOut,
        address to,
        address[] calldata swapPath
    ) external payable returns (uint out);

}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Trustable is Ownable {
    mapping(address=>bool) public trusted;

    modifier onlyTrusted {
        require(trusted[msg.sender] || msg.sender == owner(), "not trusted");
        _;
    }

    function setTrusted(address user, bool isTrusted) public onlyOwner {
        trusted[user] = isTrusted;
    }
}// MIT

pragma solidity ^0.8.6;



contract Bridge is Trustable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for ERC20;

    struct Order {
        uint id;
        uint8 tokenId;
        address sender;
        bytes32 target;
        uint amount;
        uint feeAmount;
        uint8 decimals;
        uint8 destination;
        address tokenIn;
        bytes32 tokenOut;
    }

    struct Token {
        ERC20 token;
        address feeTarget;
        uint16 defaultFee;
        uint defaultFeeBase;
        uint defaultMinAmount;
        uint defaultMaxAmount;
        uint bonus;
    }

    struct Config {
        uint16 fee;
        uint feeBase;
        uint minAmount;
        uint maxAmount;
        bool directTransferAllowed;
    }

    struct CompleteParams {
        uint orderId;
        uint8 dstFrom;
        uint8 tokenId;
        address payable to;
        uint amount;
        uint decimals;
        ERC20 tokenOut;
        address[] swapPath;
    }

    event OrderCreated(uint indexed id, Order order);
    event OrderCompleted(uint indexed id, uint8 indexed dstFrom);

    uint nextOrderId = 0;
    uint8 tokensLength = 0;
    uint8 nativeTokenId = 255;

    IBridgeSwap public swapper;
    bool public swapsAllowed = false;
    uint8 public swapDefaultTokenId = 0;

    mapping (uint8 => Token) public tokens;
    mapping (address => uint8) public addresses;
    mapping (uint8 => mapping (uint8 => Config)) public configs;
    mapping (uint => Order) public orders;
    EnumerableSet.UintSet private orderIds;
    mapping (bytes32 => bool) public completed;

    function setToken(
        uint8 tokenId,
        ERC20 token,
        address feeTarget,
        uint16 defaultFee,
        uint defaultFeeBase,
        uint defaultMinAmount,
        uint defaultMaxAmount,
        uint8 inputDecimals,
        uint bonus
    ) external onlyOwner {
        require(defaultFee <= 10000, "invalid fee");
        tokens[tokenId] = Token(
            token,
            feeTarget,
            defaultFee,
            convertAmount(token, defaultFeeBase, inputDecimals),
            convertAmount(token, defaultMinAmount, inputDecimals),
            convertAmount(token, defaultMaxAmount, inputDecimals),
            bonus
        );
        addresses[address(token)] = tokenId;

        if (tokenId + 1 > tokensLength) {
            tokensLength = tokenId + 1;
        }
    }

    function setFeeTarget(uint8 tokenId, address feeTarget) external onlyOwner {
        tokens[tokenId].feeTarget = feeTarget;
    }

    function setDefaultFee(uint8 tokenId, uint16 defaultFee) external onlyOwner {
        require(defaultFee <= 10000, "invalid fee");
        tokens[tokenId].defaultFee = defaultFee;
    }

    function setDefaultFeeBase(uint8 tokenId, uint defaultFeeBase, uint8 inputDecimals) external onlyOwner {
        tokens[tokenId].defaultFeeBase = convertAmount(tokens[tokenId].token, defaultFeeBase, inputDecimals);
    }

    function setDefaultMinAmount(uint8 tokenId, uint defaultMinAmount, uint8 inputDecimals) external onlyOwner {
        tokens[tokenId].defaultMinAmount = convertAmount(tokens[tokenId].token, defaultMinAmount, inputDecimals);
    }

    function setDefaultMaxAmount(uint8 tokenId, uint defaultMaxAmount, uint8 inputDecimals) external onlyOwner {
        tokens[tokenId].defaultMaxAmount = convertAmount(tokens[tokenId].token, defaultMaxAmount, inputDecimals);
    }

    function setBonus(uint8 tokenId, uint bonus) external onlyOwner {
        tokens[tokenId].bonus = bonus;
    }

    function setFee(uint8 tokenId, uint8 destination, uint16 fee) external onlyOwner {
        require(fee <= 10000, "invalid fee");
        configs[tokenId][destination].fee = fee;
    }

    function setFeeBase(uint8 tokenId, uint8 destination, uint feeBase, uint8 inputDecimals) external onlyOwner {
        configs[tokenId][destination].feeBase = convertAmount(tokens[tokenId].token, feeBase, inputDecimals);
    }

    function setMinAmount(uint8 tokenId, uint8 destination, uint minAmount, uint8 inputDecimals) external onlyOwner {
        configs[tokenId][destination].minAmount = convertAmount(tokens[tokenId].token, minAmount, inputDecimals);
    }

    function setMaxAmount(uint8 tokenId, uint8 destination, uint maxAmount, uint8 inputDecimals) external onlyOwner {
        configs[tokenId][destination].maxAmount = convertAmount(tokens[tokenId].token, maxAmount, inputDecimals);
    }

    function setDirectTransferAllowed(uint8 tokenId, uint8 destination, bool directTransferAllowed) external onlyOwner {
        configs[tokenId][destination].directTransferAllowed = directTransferAllowed;
    }

    function setConfig(uint8 tokenId, uint8 destination, Config calldata config) external onlyOwner {
        configs[tokenId][destination] = config;
    }

    function setSwapper(IBridgeSwap newSwapper) external onlyOwner {
        swapper = newSwapper;
    }

    function setSwapSettings(bool allowed, uint8 tokenId) external onlyOwner {
        swapsAllowed = allowed;
        swapDefaultTokenId = tokenId;
    }

    function createWithSwap(
        ERC20 tokenIn,
        uint amount,
        uint8 destination,
        bytes32 target,
        bytes32 tokenOut,
        address[] calldata swapPath
    ) external payable {
        require(swapsAllowed && address(swapper) != address(0), "swaps currently disabled");

        if (address(tokenIn) == address(1)) {
            require (amount == msg.value, "native token amount must be equal amount parameter");
        } else {
            tokenIn.safeTransferFrom(msg.sender, address(this), amount);
        }

        uint8 tokenId = swapDefaultTokenId;

        uint8 tokenInId = addresses[address(tokenIn)];
        if (tokens[tokenInId].token == tokenIn && configs[tokenInId][destination].directTransferAllowed) {
            tokenId = tokenInId;
        }

        Token memory tok = tokens[tokenId];

        if (tok.token != tokenIn) {
            if (address(tokenIn) == address(1)) {
                amount = swapper.swapFromNative{ value: amount }(tok.token, address(this), swapPath);
            } else {
                tokenIn.approve(address(swapper), amount);
                amount = swapper.swap(tokenIn, amount, tok.token, address(this), swapPath);
            }
        }

        require(checkAmount(tokenId, destination, amount), "amount must be in allowed range");

        uint feeAmount = transferFee(tokenId, destination, amount);

        orders[nextOrderId] = Order(
            nextOrderId,
            tokenId,
            msg.sender,
            target,
            amount - feeAmount,
            feeAmount,
            tokenDecimals(tok.token),
            destination,
            address(tokenIn),
            tokenOut
        );
        orderIds.add(nextOrderId);

        emit OrderCreated(nextOrderId, orders[nextOrderId]);
        nextOrderId++;
    }

    function create(uint8 tokenId, uint amount, uint8 destination, bytes32 target) public payable {
        Token storage tok = tokens[tokenId];
        require(address(tok.token) != address(0), "unknown token");

        require(checkAmount(tokenId, destination, amount), "amount must be in allowed range");

        if (address(tok.token) == address(1)) {
            require (amount == msg.value, "native token amount must be equal amount parameter");
        } else {
            tok.token.safeTransferFrom(msg.sender, address(this), amount);
        }

        uint feeAmount = transferFee(tokenId, destination, amount);

        orders[nextOrderId] = Order(
            nextOrderId,
            tokenId,
            msg.sender,
            target,
            amount - feeAmount,
            feeAmount,
            tokenDecimals(tok.token),
            destination,
            address(0),
            bytes32(0)
        );
        orderIds.add(nextOrderId);

        emit OrderCreated(nextOrderId, orders[nextOrderId]);
        nextOrderId++;
    }

    function closeOrder(uint orderId) external onlyTrusted {
        orderIds.remove(orderId);
    }

    function closeManyOrders(uint[] calldata _orderIds) external onlyTrusted {
        for (uint i = 0; i < _orderIds.length; i++) {
            orderIds.remove(_orderIds[i]);
        }
    }

    function completeOrder(
        uint orderId,
        uint8 dstFrom,
        uint8 tokenId,
        address payable to,
        uint amount,
        uint decimals,
        ERC20 tokenOut,
        address[] calldata swapPath
    ) public onlyTrusted {
        bytes32 orderHash = keccak256(abi.encodePacked(orderId, dstFrom));
        require (completed[orderHash] == false, "already transfered");
        require (!Address.isContract(to), "contract targets not supported");

        Token storage tok = tokens[tokenId];
        require(address(tok.token) != address(0), "unknown token");

        amount = convertAmount(tok.token, amount, decimals);

        if (address(tokenOut) != address(0) && tok.token != tokenOut) {
            tok.token.approve(address(swapper), amount);
            if (address(tokenOut) == address(1)) {
                swapper.swapToNative(tok.token, amount, to, swapPath);
            } else {
                swapper.swap(tok.token, amount, tokenOut, to, swapPath);
            }
        } else if (address(tok.token) == address(1)) {
            to.transfer(amount);
        } else {
            tok.token.safeTransfer(to, amount);
        }

        completed[orderHash] = true;

        uint bonus = Math.min(tok.bonus, address(this).balance);
        if (bonus > 0) {
            to.transfer(bonus);
        }

        emit OrderCompleted(orderId, dstFrom);
    }

    function completeManyOrders(CompleteParams[] calldata params) external onlyTrusted {
        for (uint i = 0; i < params.length; i++) {
            completeOrder(
                params[i].orderId,
                params[i].dstFrom,
                params[i].tokenId,
                params[i].to,
                params[i].amount,
                params[i].decimals,
                params[i].tokenOut,
                params[i].swapPath
            );
        }
    }

    function withdraw(uint8 tokenId, address payable to, uint amount, uint8 inputDecimals) external onlyTrusted {
        Token storage tok = tokens[tokenId];

        if (address(tok.token) == address(1)) {
            to.transfer(convertAmount(tok.token, amount, inputDecimals));
        } else {
            tok.token.safeTransfer(to, convertAmount(tok.token, amount, inputDecimals));
        }
    }

    function withdrawToken(ERC20 token, address payable to, uint amount, uint8 inputDecimals) external onlyTrusted {
        if (address(token) == address(1)) {
            to.transfer(convertAmount(token, amount, inputDecimals));
        } else {
            token.safeTransfer(to, convertAmount(token, amount, inputDecimals));
        }
    }

    function isCompleted(uint orderId, uint8 dstFrom) external view returns (bool) {
        return completed[keccak256(abi.encodePacked(orderId, dstFrom))];
    }

    function listOrders() external view returns (Order[] memory) {
        Order[] memory list = new Order[](orderIds.length());
        for (uint i = 0; i < orderIds.length(); i++) {
            list[i] = orders[orderIds.at(i)];
        }

        return list;
    }

    function listTokensNames() external view returns (string[] memory) {
        string[] memory list = new string[](tokensLength);
        for (uint8 i = 0; i < tokensLength; i++) {
            if (address(tokens[i].token) != address(0)) {
                list[i] = tokens[i].token.symbol();
            }
        }

        return list;
    }

    receive() external payable {}

    function convertAmount(ERC20 token, uint amount, uint fromDecimals) view private returns (uint) {
        return amount * (10 ** tokenDecimals(token)) / (10 ** fromDecimals);
    }

    function tokenDecimals(ERC20 token) private view returns (uint8) {
        if (address(token) == address(1)) {
            return 18;
        } else {
            return token.decimals();
        }
    }

    function checkAmount(uint8 tokenId, uint8 destination, uint amount) private view returns (bool) {
        Token memory tok = tokens[tokenId];
        Config memory config = configs[tokenId][destination];

        uint min = tok.defaultMinAmount;
        uint max = tok.defaultMaxAmount;

        if (config.minAmount > 0) {
            min = config.minAmount;
        }
        if (config.maxAmount > 0) {
            max = config.maxAmount;
        }

        return amount >= min && amount <= max;
    }

    function transferFee(uint8 tokenId, uint8 destination, uint amount) private returns (uint feeAmount) {
        Token memory tok = tokens[tokenId];
        Config memory config = configs[tokenId][destination];

        uint fee = tok.defaultFee;
        uint feeBase = tok.defaultFeeBase;

        if (config.fee > 0) {
            fee = config.fee;
        }
        if (config.feeBase > 0) {
            feeBase = config.feeBase;
        }

        feeAmount = feeBase + amount * fee / 10000;
        if (feeAmount > 0 && tok.feeTarget != address(this)) {
            tok.token.safeTransfer(tok.feeTarget, feeAmount);
        }
    }
}