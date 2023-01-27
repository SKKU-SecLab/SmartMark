
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

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
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
}//Unlicense
pragma solidity ^0.8.0;


contract PurchaseGiftcard is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct Purchase {
    string orderID;
    uint256 cryptoAmount;
    address cryptoContract;
    uint256 purchaseTime;
  }

  address public adminAddress;
  mapping(address => bool) public operators;
  mapping(address => Purchase[]) public purchaseHistory;
  mapping(string => bool) public refundHistory;
  mapping(address => bool) public tokens;

  event PurchaseByCurrency(
    string voucherID,
    string fromFiatID,
    string toCryptoID,
    uint256 fiatDenomination,
    uint256 cryptoAmount,
    string orderID,
    uint256 purchaseTime
  );
  event PurchaseByToken(
    string voucherID,
    string fromFiatID,
    string toCryptoID,
    uint256 fiatDenomination,
    uint256 cryptoAmount,
    string orderID,
    uint256 purchaseTime
  );
  event WithdrawCurrency(address adminAddress, uint256 currencyAmount);
  event WithdrawToken(
    address adminAddress,
    uint256 tokenAmount,
    address tokenAddress
  );
  event RefundCurrency(string orderID);
  event RefundToken(string orderID);

  constructor() {
    adminAddress = msg.sender;
  }

  function setupOperator(address operatorAddress)
    external
    onlyOwner
    isValidAddress(operatorAddress)
  {
    require(!operators[operatorAddress], "Operator already exists.");
    operators[operatorAddress] = true;
  }

  function removeOperator(address operatorAddress)
    external
    onlyOwner
    isValidAddress(operatorAddress)
  {
    require(operators[operatorAddress], "Operator not setup yet.");
    operators[operatorAddress] = false;
  }

  function setAdminAddress(address _adminAddress)
    external
    onlyOwner
    isValidAddress(_adminAddress)
  {
    adminAddress = _adminAddress;
  }

  function setupToken(address _token) external onlyOperater {
    require(!tokens[_token], "Token already setup.");

    tokens[_token] = true;
  }

  function removeToken(address _token) external onlyOperater {
    require(tokens[_token], "Token not setup yet.");

    tokens[_token] = false;
  }

  function withdrawCurrency(uint256 currencyAmount) external onlyOperater {
    require(currencyAmount > 0, "Withdraw amount invalid.");

    require(
      currencyAmount <= address(this).balance,
      "Not enough amount to withdraw."
    );

    require(adminAddress != address(0), "Invalid admin address.");

    payable(adminAddress).transfer(currencyAmount);

    emit WithdrawCurrency(adminAddress, currencyAmount);
  }

  function withdrawToken(uint256 tokenAmount, address tokenAddress)
    external
    onlyOperater
    isTokenExist(tokenAddress)
  {
    require(tokenAmount > 0, "Withdraw amount invalid.");

    require(
      tokenAmount <= IERC20(tokenAddress).balanceOf(address(this)),
      "Not enough amount to withdraw."
    );

    require(adminAddress != address(0), "Invalid admin address.");

    IERC20(tokenAddress).safeTransfer(adminAddress, tokenAmount);

    emit WithdrawToken(adminAddress, tokenAmount, tokenAddress);
  }

  function refundOrder(string memory orderID, address buyer)
    external
    onlyOperater
    isValidAddress(buyer)
  {
    (
      string memory existingOrderID,
      uint256 cryptoAmount,
      address cryptoContract
    ) = _findPurchase(orderID, buyer);

    require(bytes(existingOrderID).length > 0, "Order not found.");

    require(
      !refundHistory[existingOrderID],
      "Purchase has been already refunded."
    );

    require(cryptoAmount > 0, "Refund amount invalid.");

    if (cryptoContract == address(0)) {
      require(
        cryptoAmount <= address(this).balance,
        "Not enough amount of native token to refund."
      );

      payable(buyer).transfer(cryptoAmount);

      refundHistory[existingOrderID] = true;

      emit RefundCurrency(existingOrderID);
    } else {
      require(
        cryptoAmount <= IERC20(cryptoContract).balanceOf(address(this)),
        "Not enough amount of token to refund."
      );

      IERC20(cryptoContract).safeTransfer(buyer, cryptoAmount);

      refundHistory[existingOrderID] = true;

      emit RefundToken(existingOrderID);
    }
  }

  function purchaseByCurrency(
    string memory _voucherID,
    string memory _fromFiatID,
    string memory _toCryptoID,
    uint256 _fiatDenomination,
    string memory _orderID
  ) external payable {
    require(msg.value >= 0, "Transfer amount invalid.");

    require(msg.sender.balance >= msg.value, "Insufficient token balance.");

    Purchase memory purchase = Purchase({
      orderID: _orderID,
      cryptoAmount: msg.value,
      cryptoContract: address(0),
      purchaseTime: block.timestamp
    });

    purchaseHistory[msg.sender].push(purchase);

    emit PurchaseByCurrency(
      _voucherID,
      _fromFiatID,
      _toCryptoID,
      _fiatDenomination,
      msg.value,
      _orderID,
      block.timestamp
    );
  }

  function purchaseByToken(
    string memory _voucherID,
    string memory _fromFiatID,
    string memory _toCryptoID,
    uint256 _fiatDenomination,
    uint256 _cryptoAmount,
    address token,
    string memory _orderID
  ) external isTokenExist(token) {
    require(_cryptoAmount >= 0, "Transfer amount invalid.");

    require(
      IERC20(token).balanceOf(msg.sender) >= _cryptoAmount,
      "Insufficient token balance."
    );

    IERC20(token).safeTransferFrom(msg.sender, address(this), _cryptoAmount);

    Purchase memory purchase = Purchase({
      orderID: _orderID,
      cryptoAmount: _cryptoAmount,
      cryptoContract: token,
      purchaseTime: block.timestamp
    });

    purchaseHistory[msg.sender].push(purchase);

    emit PurchaseByToken(
      _voucherID,
      _fromFiatID,
      _toCryptoID,
      _fiatDenomination,
      _cryptoAmount,
      _orderID,
      block.timestamp
    );
  }

  modifier onlyOperater() {
    require(operators[msg.sender], "You are not Operator");
    _;
  }

  modifier isValidAddress(address _address) {
    require(_address != address(0), "Invalid address.");
    _;
  }

  modifier isTokenExist(address _address) {
    require(tokens[_address] == true, "Token is not exist.");
    _;
  }

  function _findPurchase(string memory _orderID, address _buyer)
    internal
    view
    isValidAddress(_buyer)
    returns (
      string memory orderID,
      uint256 cryptoAmount,
      address cryptoContract
    )
  {
    require(bytes(_orderID).length > 0, "OrderID must not be empty.");

    for (uint256 i = 0; i < purchaseHistory[_buyer].length; i++) {
      if (
        keccak256(abi.encodePacked(purchaseHistory[_buyer][i].orderID)) ==
        keccak256(abi.encodePacked(_orderID))
      ) {
        return (
          purchaseHistory[_buyer][i].orderID,
          purchaseHistory[_buyer][i].cryptoAmount,
          purchaseHistory[_buyer][i].cryptoContract
        );
      }
    }
  }
}