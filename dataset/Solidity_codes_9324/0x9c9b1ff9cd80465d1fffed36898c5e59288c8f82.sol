
pragma solidity >=0.6.0 <0.8.0;

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
}// UNLICENSED

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// UNLICENSED

pragma solidity 0.6.12;

interface ISwapPriceCalculator
{

    function calc(uint256 fromAmount,
                  uint256 expectedToAmount,
                  uint16  slippage,
                  uint256 fromReserve,
                  uint256 toSoldAmount,
                  bool 	  excludeFee) external view returns (uint256 actualToAmount,
															 uint256 fromFeeAdd,
															 uint256 actualFromAmount);

}// UNLICENSED

pragma solidity 0.6.12;


interface IUSDT
{

    function balanceOf(address who) external view returns (uint);

    function transfer(address to, uint value) external;

    function allowance(address owner, address spender) external view returns (uint);

    function transferFrom(address from, address to, uint value) external;

}

contract SwapperUsdtToToken
{

    using SafeMath for uint256;
    
    address public admin;
    IUSDT public usdtToken;
    IERC20 public sellToken;
    ISwapPriceCalculator public priceCalculator;
    
    uint256 public usdtReserve;
    uint256 public usdtFee;
    uint256 public tokensSold;
    
    string private constant ERR_MSG_SENDER = "ERR_MSG_SENDER";
    string private constant ERR_AMOUNT = "ERR_AMOUNT";
    string private constant ERR_ZERO_PAYMENT = "ERR_ZERO_PAYMENT";
    
    event Swap(uint256 fromAmount,
               uint256 expectedToAmount,
               uint16 slippage,
               uint256 fromFeeAdd,
               uint256 actualToAmount,
               uint256 tokensSold);
    
    constructor(address _admin, address _usdtToken, address _sellToken, address _priceCalculator) public
    {
        admin = _admin;
        usdtToken = IUSDT(_usdtToken);
        sellToken = IERC20(_sellToken);
        priceCalculator = ISwapPriceCalculator(_priceCalculator);
    }
    
    function sendUsdt(address _to) external returns (uint256 usdtReserveTaken_, uint256 usdtFeeTaken_)
    {

        require(msg.sender == admin, ERR_MSG_SENDER);
        
        usdtToken.transfer(_to, usdtToken.balanceOf(address(this)));
        
        usdtReserveTaken_ = usdtReserve;
        usdtFeeTaken_ = usdtFee;
        
        usdtReserve = 0;
        usdtFee = 0;
    }
    
    function sendSellTokens(address _to, uint256 _amount) external
    {

        require(msg.sender == admin, ERR_MSG_SENDER);
        
        if(_amount == 0)
        {
            sellToken.transfer(_to, sellToken.balanceOf(address(this)));
        }
        else
        {
            sellToken.transfer(_to, _amount);
        }
    }
    
    function setPriceCalculator(address _priceCalculator) external
    {

        require(msg.sender == admin, ERR_MSG_SENDER);
        
        priceCalculator = ISwapPriceCalculator(_priceCalculator);
    }
    
    function calcPrice(uint256 _fromAmount, bool _excludeFee) external view returns (uint256 _actualToAmount,
                                                                                     uint256 _fromFeeAdd,
                                                                                     uint256 _actualFromAmount)
    {

        require(_fromAmount > 0, ERR_ZERO_PAYMENT);
        
        return priceCalculator.calc(_fromAmount, 0, 0, usdtReserve, tokensSold, _excludeFee);
    }
    
    function swap(uint256 _expectedToAmount, uint16 _slippage, bool _excludeFee) external
    {

        require(_expectedToAmount > 0, "ERR_ZERO_EXP_AMOUNT");
        require(_slippage <= 500, "ERR_SLIPPAGE_TOO_BIG");
        
        uint256 usdtAmount = usdtToken.allowance(msg.sender, address(this));
        require(usdtAmount > 0, ERR_ZERO_PAYMENT);
        
        (uint256 actualToAmount, uint256 usdtFeeAdd, uint256 actualUsdtAmount)
            = priceCalculator.calc(usdtAmount, _expectedToAmount, _slippage, usdtReserve, tokensSold, _excludeFee);
            
        require(actualToAmount > 0, "ERR_ZERO_ACTUAL_TO_AMOUNT");
        require(actualUsdtAmount == usdtAmount, "ERR_WRONG_PAYMENT_AMOUNT");
        
        usdtToken.transferFrom(msg.sender, address(this), usdtAmount);
        
        usdtFee = usdtFee.add(usdtFeeAdd);
        usdtReserve = usdtReserve.add(usdtAmount.sub(usdtFeeAdd));
        tokensSold = tokensSold.add(actualToAmount);
        
        sellToken.transfer(msg.sender, actualToAmount);
     
        emit Swap(usdtAmount, _expectedToAmount, _slippage, usdtFeeAdd, actualToAmount, tokensSold);
    }
}// UNLICENSED

pragma solidity >=0.6.0 <0.8.0;


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1363Receiver {


    function onTransferReceived(address operator, address sender, uint256 amount, bytes calldata data) external returns (bytes4);

}

interface IERC1363Spender {


    function onApprovalReceived(address sender, uint256 amount, bytes calldata data) external returns (bytes4);

}

interface IERC1363 is IERC20, IERC165 {



    function transferAndCall(address recipient, uint256 amount) external returns (bool);


    function transferAndCall(address recipient, uint256 amount, bytes calldata data) external returns (bool);


    function transferFromAndCall(address sender, address recipient, uint256 amount) external returns (bool);


    function transferFromAndCall(address sender, address recipient, uint256 amount, bytes calldata data) external returns (bool);


    function approveAndCall(address spender, uint256 amount) external returns (bool);


    function approveAndCall(address spender, uint256 amount, bytes calldata data) external returns (bool);

}

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
}

library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC1363 is ERC20, IERC1363, ERC165 {
    using Address for address;

    bytes4 internal constant _INTERFACE_ID_ERC1363_TRANSFER = 0x4bbee2df;

    bytes4 internal constant _INTERFACE_ID_ERC1363_APPROVE = 0xfb9ec8ce;

    bytes4 private constant _ERC1363_RECEIVED = 0x88a7ca5c;

    bytes4 private constant _ERC1363_APPROVED = 0x7b04a2d0;

    constructor (string memory name, string memory symbol) public ERC20(name, symbol) {
        _registerInterface(_INTERFACE_ID_ERC1363_TRANSFER);
        _registerInterface(_INTERFACE_ID_ERC1363_APPROVE);
    }

    function transferAndCall(address recipient, uint256 amount) public virtual override returns (bool) {
        return transferAndCall(recipient, amount, "");
    }

    function transferAndCall(address recipient, uint256 amount, bytes memory data) public virtual override returns (bool) {
        transfer(recipient, amount);
        require(_checkAndCallTransfer(_msgSender(), recipient, amount, data), "ERC1363: _checkAndCallTransfer reverts");
        return true;
    }

    function transferFromAndCall(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        return transferFromAndCall(sender, recipient, amount, "");
    }

    function transferFromAndCall(address sender, address recipient, uint256 amount, bytes memory data) public virtual override returns (bool) {
        transferFrom(sender, recipient, amount);
        require(_checkAndCallTransfer(sender, recipient, amount, data), "ERC1363: _checkAndCallTransfer reverts");
        return true;
    }

    function approveAndCall(address spender, uint256 amount) public virtual override returns (bool) {
        return approveAndCall(spender, amount, "");
    }

    function approveAndCall(address spender, uint256 amount, bytes memory data) public virtual override returns (bool) {
        approve(spender, amount);
        require(_checkAndCallApprove(spender, amount, data), "ERC1363: _checkAndCallApprove reverts");
        return true;
    }

    function _checkAndCallTransfer(address sender, address recipient, uint256 amount, bytes memory data) internal virtual returns (bool) {
        if (!recipient.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Receiver(recipient).onTransferReceived(
            _msgSender(), sender, amount, data
        );
        return (retval == _ERC1363_RECEIVED);
    }

    function _checkAndCallApprove(address spender, uint256 amount, bytes memory data) internal virtual returns (bool) {
        if (!spender.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Spender(spender).onApprovalReceived(
            _msgSender(), amount, data
        );
        return (retval == _ERC1363_APPROVED);
    }
}