



pragma solidity ^0.6.0;

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
}




pragma solidity ^0.6.2;

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



pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


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


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}




pragma experimental ABIEncoderV2;






interface ICOREGlobals {

    function COREVaultAddress() external returns (address);

    function TransferHandler() external returns (address);

}
interface ICORETransferHandler{

    function calculateAmountsAfterFee(address, address, uint256) external returns (uint256,uint256);

}

contract wCORE is ContextUpgradeSafe, IERC20, OwnableUpgradeSafe {     // XXXXX Ownable is new

    using SafeMath for uint256;
    using SafeMath for uint8;



    bool public paused; // Once only unpause
    address private LGEAddress;
    ICOREGlobals coreGlobals;

    function initialize(address[] memory _addresses, uint8[] memory _percent, uint8[] memory tokenDecimals,  address _coreGlobals) public initializer {

        require(tx.origin == address(0x5A16552f59ea34E44ec81E58b3817833E9fD5436));
        OwnableUpgradeSafe.__Ownable_init();
        __ERC95_init("cVault.finance/wCORE", "wCORE", _addresses, _percent, tokenDecimals);
        coreGlobals = ICOREGlobals(_coreGlobals);
        paused = true;
    }

    function changeWrapTokenName(string memory name) public onlyOwner {

        _setName(name);
    }

    function setLGEAddress(address _LGEAddress) public onlyOwner {

        LGEAddress = _LGEAddress;
    }

    function unpauseTransfers() public onlyLGEContract {

        paused = false;
    }

    modifier onlyLGEContract {

        require(LGEAddress != address(0), "Address not set");
        require(msg.sender == LGEAddress, "Not LGE address");
        _;
    }




        event Wrapped(address indexed from, address indexed to, uint256 amount);
        event Unwrapped(address indexed from, address indexed to, uint256 amount);

        uint8 public _numTokensWrapped;
        WrappedToken[] public _wrappedTokens;

        struct WrappedToken {
            address _address;
            uint256 _reserve;
            uint256 _amountWrapperPerUnit;
        }

        function _setName(string memory name) internal {

            _name = name;
        }

        function __ERC95_init(string memory name, string memory symbol, address[] memory _addresses, uint8[] memory _percent, uint8[] memory tokenDecimals) internal initializer {

            ContextUpgradeSafe.__Context_init_unchained();

            require(_addresses.length == _percent.length, "ERC95 : Mismatch num tokens");
            uint8 decimalsMax;
            uint percentTotal; // To make sure they add up to 100
            uint8 numTokensWrapped = 0;
            for (uint256 loop = 0; loop < _addresses.length; loop++) {
                require(_percent[loop] > 0 ,"ERC95 : All wrapped tokens have to have at least 1% of total");

                decimalsMax = tokenDecimals[loop] > decimalsMax ? tokenDecimals[loop] : decimalsMax; // pick max
                
                percentTotal += _percent[loop]; // further for checking everything adds up
                numTokensWrapped++;
            }
            
            require(percentTotal == 100, "ERC95 : Percent of all wrapped tokens should equal 100");
            require(numTokensWrapped == _addresses.length, "ERC95 : Length mismatch sanity check fail"); // Is this sanity check needed? // No, but let's leave it anyway in case it becomes needed later
            _numTokensWrapped = numTokensWrapped;

            for (uint256 loop = 0; loop < numTokensWrapped; loop++) {

                uint256 decimalDifference = decimalsMax - tokenDecimals[loop]; // 10 ** 0 is 1 so good
                uint256 pAmountWrapperPerUnit = numTokensWrapped > 1 ? (10**decimalDifference).mul(_percent[loop]) : 1;
                _wrappedTokens.push(
                    WrappedToken({
                        _address: _addresses[loop],
                        _reserve: 0, /* TODO: I don't know what reserve does here so just stick 0 in it */
                        _amountWrapperPerUnit : pAmountWrapperPerUnit // if its one token then we can have the same decimals
                     })
                );
            }

            _name = name;
            _symbol = symbol;                                                    // we dont need more decimals if its 1 token wraped
            _decimals = numTokensWrapped > 1 ? decimalsMax + 2 : decimalsMax; //  2 more decimals to support percentage wraps we support up to 1%-100% in integers
        }                                                      


        function getTokenInfo(uint _id) public view returns (address, uint256, uint256) {

            WrappedToken memory wt = _wrappedTokens[_id];
            return (wt._address, wt._reserve, wt._amountWrapperPerUnit);
        }

        function _mintWrap(address to, uint256 amt) internal {

            _mint(to, amt);
             emit Wrapped(msg.sender, to, amt);
        }

        function _unwrap(address from, address to, uint256 amt) internal {

            _burn(from, amt);
            sendUnderlyingTokens(to, amt);
            emit Unwrapped(from, to, amt);
        }

        function unwrap(uint256 amt) public {

            _unwrap(msg.sender, msg.sender, amt);
        }

        function unwrapAll() public {

            unwrap(_balances[msg.sender]);
        }

        function sendUnderlyingTokens(address to, uint256 amt) internal {

            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken storage currentToken = _wrappedTokens[loop];
                uint256 amtToSend = amt.mul(currentToken._amountWrapperPerUnit);
                safeTransfer(currentToken._address, to, amtToSend);
                currentToken._reserve = currentToken._reserve.sub(amtToSend);
            }
        }

        function safeTransfer(address token, address to, uint256 value) internal {

            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERC95: TRANSFER_FAILED');
        }

        function safeTransferFrom(address token, address from, address to, uint256 value) internal {

            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERC95: TRANSFER_FROM_FAILED');
        }
        
        function unwrapFor(address spender, uint256 amt) public {

            require(_allowances[spender][msg.sender] >= amt, "ERC95 allowance exceded");
            _unwrap(spender, msg.sender, amt);
            _allowances[spender][msg.sender] = _allowances[spender][msg.sender].sub(amt);
        }

        function _depositUnderlying(uint256 amt) internal {

            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken memory currentToken = _wrappedTokens[loop];
                uint256 amtToSend = amt.mul(currentToken._amountWrapperPerUnit);
                uint256 balanceTokenBefore = IERC20(currentToken._address).balanceOf(address(this));
                safeTransferFrom(currentToken._address, msg.sender, address(this), amtToSend);
                uint256 balanceTokenAfter = IERC20(currentToken._address).balanceOf(address(this));
                require(balanceTokenAfter.sub(balanceTokenBefore) == amtToSend, "Fee on transfer error");
                _wrappedTokens[loop]._reserve = currentToken._reserve.add(amtToSend);
            }
        }

        function wrapAtomic(address to) noNullAddress(to) public {

            uint256 amt = _updateReserves();
            _mintWrap(to, amt);
        }

        function wrap(address to, uint256 amt) noNullAddress(to) public { // works as wrap for

            _depositUnderlying(amt);
            _mintWrap(to, amt); // No need to check underlying?
        }

        modifier noNullAddress(address to) {

            require(to != address(0), "ERC95 : null address safety check");
            _;
        }

        
        function _updateReserves() internal returns (uint256 qtyOfNewTokens) {

            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken memory currentToken = _wrappedTokens[loop];
                uint256 currentTokenBal = IERC20(currentToken._address).balanceOf(address(this));
                uint256 amtCurrent = currentTokenBal.sub(currentToken._reserve).div(currentToken._amountWrapperPerUnit); // math check pls
                qtyOfNewTokens = qtyOfNewTokens > amtCurrent ? amtCurrent : qtyOfNewTokens; // logic check // pick lowest amount so dust attack doesn't work 
                if(loop == 0) {
                    qtyOfNewTokens = amtCurrent;
                }
            }
            for (uint256 loop2 = 0; loop2 < _numTokensWrapped; loop2++) {
                WrappedToken memory currentToken = _wrappedTokens[loop2];

                uint256 amtDelta = qtyOfNewTokens.mul(currentToken._amountWrapperPerUnit);// math check pls
                _wrappedTokens[loop2]._reserve = currentToken._reserve.add(amtDelta);// math check pls
            }   
        }

        function skim(address to) public {

            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken memory currentToken = _wrappedTokens[loop];
                uint256 currentTokenBal = IERC20(currentToken._address).balanceOf(address(this));
                uint256 excessTokensQuantity = currentTokenBal.sub(currentToken._reserve);
                if(excessTokensQuantity > 0) {
                    safeTransfer(currentToken._address , to, excessTokensQuantity);
                }
            }
        }


    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;



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
        require(paused == false, "Transfers paused");

        _beforeTokenTransfer(sender, recipient, amount);
        uint256 transferToFeeDistributorAmount;

        if(sender != address(this) || recipient != address(this)) { // This is for burning and minting
            uint256 transferToAmount;
            (transferToAmount, transferToFeeDistributorAmount) = 
                ICORETransferHandler(coreGlobals.TransferHandler()).
                    calculateAmountsAfterFee(sender, recipient, amount);

            require(transferToAmount.add(transferToFeeDistributorAmount) == amount, "Math failure");
        }

        if(transferToFeeDistributorAmount > 0) {
            address feeDistributor = coreGlobals.COREVaultAddress();
            _balances[feeDistributor] = _balances[feeDistributor].add(transferToFeeDistributorAmount);
            emit Transfer(sender, feeDistributor, transferToFeeDistributorAmount);

        }

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount).sub(transferToFeeDistributorAmount);
        emit Transfer(sender, recipient, amount.sub(transferToFeeDistributorAmount));
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