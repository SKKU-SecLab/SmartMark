


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


library SafeMathUpgradeable {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

library AddressUpgradeable {

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



pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}



pragma solidity ^0.8.0;


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}



pragma solidity ^0.8.0;




contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    uint256[45] private __gap;
}



pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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
    uint256[49] private __gap;
}


pragma solidity ^0.8.2;

interface BancorBondingCurveV1Interface {


  function calculatePriceForNTokens(
    uint32 _supply,
    uint256 _reserveBalance,
    uint32 _reserveRatio,
    uint32 _amount
  )
    external
    view
    returns (
      uint256
    );


  function calculatePurchaseReturn(
    uint32 _supply,
    uint256 _reserveBalance,
    uint32 _reserveRatio,
    uint256 _depositAmount
  )
    external
    view
    returns (
      uint32
    );


  function calculateSaleReturn(
    uint32 _supply,
    uint256 _reserveBalance,
    uint32 _reserveRatio,
    uint32 _sellAmount
  )
    external
    view
    returns(
      uint256
    );

}



pragma solidity ^0.8.2;

contract Escrow {


  enum escrowState {
    INITIAL,
    AWAITING_PROCESSING,
    COMPLETE_USER_REFUND,
    COMPLETE
  }

  struct escrowInfo {
    escrowState state;
    uint32 amount;
    uint256 value;
  }

  mapping(address => escrowInfo[]) public escrowList;       // A list of user to escrow being saved

  event escrowStateUpdated(address, uint256, escrowInfo);   // Event that's fired when a new redeem request has been created.

  function _addEscrow(uint32 _amount, uint256 _value) internal virtual returns (uint256){

    require(_amount > 0, 'Invalid Amount');
    escrowInfo memory info;
    info.state = escrowState.AWAITING_PROCESSING;
    info.amount = _amount;
    info.value = _value;
    escrowList[msg.sender].push(info);
    uint256 _id = escrowList[msg.sender].length -1;
    emit escrowStateUpdated(msg.sender, _id, info);
    return _id;
  }

  function _updateUserCompleted(address _buyer, uint256 _id) internal virtual {

    require(_id >=  0 || _id < escrowList[_buyer].length, "Invalid id");
    require(!isStateCompleted(escrowList[_buyer][_id].state), "already completed");

    escrowList[_buyer][_id].state = escrowState.COMPLETE;
    emit escrowStateUpdated(_buyer, _id, escrowList[_buyer][_id]);
  }

  function _updateUserRefund(address _buyer, uint256 _id) internal virtual returns (uint) {

    require(_id >=  0 || _id < escrowList[_buyer].length, "Invalid id");
    require(!isStateCompleted(escrowList[_buyer][_id].state), "already completed");

    escrowList[_buyer][_id].state = escrowState.COMPLETE_USER_REFUND;
    emit escrowStateUpdated(_buyer, _id, escrowList[_buyer][_id]);
    return escrowList[_buyer][_id].value;
  }

  function isStateCompleted(escrowState _state) public pure virtual returns (bool) {

    return _state == escrowState.COMPLETE ||
         _state == escrowState.COMPLETE_USER_REFUND;
  }

  function getEscrowHistory(address _buyer) external view virtual returns (escrowInfo [] memory) {

    return escrowList[_buyer];
  }

  function getRedeemStatus(address _buyer, uint256 _id) external view virtual returns (escrowState) {

    require(_id >=  0 || _id < escrowList[_buyer].length, "Invalid id");
    return escrowList[_buyer][_id].state;
  }

}



pragma solidity ^0.8.2;







contract ProductToken is ERC20Upgradeable, Escrow, OwnableUpgradeable {

	using SafeMathUpgradeable for uint256;

	event Buy(address indexed sender, uint32 amount, uint256 price);		// event to fire when a new token is minted
  event Sell(address indexed sender, uint32 amount, uint256 price);		// event to fire when a token has been sold back
  event Tradein(address indexed sender, uint32 amount);							// event to fire when a token is redeemed in the real world
  event Tradable(bool isTradable);

  bool private isTradable;
  uint256 public reserveBalance;      // amount of liquidity in the pool
  uint256 public tradeinReserveBalance;      // amount of liquidity in the pool
  uint32 public reserveRatio;         // computed from the exponential factor in the
  uint32 public maxTokenCount;        // max token count, determined by the supply of our physical product
  uint32 public tradeinCount;         // number of tokens burned through redeeming procedure. This will drive price up permanently
  uint32 internal supplyOffset;       // an initial value used to set an initial price. This is not included in the total supply.
  address private _manager;

  BancorBondingCurveV1Interface internal bondingCurve;

  modifier onlyIfTradable {

      require(
          isTradable,
          "unable to trade now"
      );
      _;
  }

  function initialize(string memory _name, string memory _symbol, address _bondingCurveAddress,
      uint32 _reserveRatio, uint32 _maxTokenCount, uint32 _supplyOffset, uint256 _baseReserve) public virtual initializer{

    __Ownable_init();
    __ERC20_init(_name, _symbol);
    __ProductToken_init_unchained(_bondingCurveAddress, _reserveRatio, _maxTokenCount, _supplyOffset, _baseReserve);
  }

  function __ProductToken_init_unchained(address _bondingCurveAddress, uint32 _reserveRatio, uint32 _maxTokenCount, uint32 _supplyOffset, uint256 _baseReserve) internal initializer{

    require(_maxTokenCount > 0, "Invalid max token count.");
    require(_reserveRatio > 0, "Invalid reserve ratio");
    bondingCurve = BancorBondingCurveV1Interface(_bondingCurveAddress);
    reserveBalance = _baseReserve;
    tradeinReserveBalance = _baseReserve;
    supplyOffset = _supplyOffset;
    reserveRatio = _reserveRatio;
    maxTokenCount = _maxTokenCount;
  }

  function decimals() public view virtual override returns (uint8) {

      return 0;
  }

  function setBondingCurve(address _address) external virtual onlyOwner {

    require(_address!=address(0), "Invalid address");
    bondingCurve = BancorBondingCurveV1Interface(_address);
  }

  function launch() external virtual onlyOwner {

    require(!isTradable, 'The product token is already launched');
    isTradable = true;
    emit Tradable(isTradable);
  }

  function pause() external virtual onlyOwner {

    require(isTradable, 'The product token is already paused');
    isTradable = false;
    emit Tradable(isTradable);
  }

  fallback () external { }

  function getAvailability()
    public view virtual returns (uint32 available)
  {

    return maxTokenCount - uint32(totalSupply()) - tradeinCount;    // add safemath for uint32 later
  }

  function _getTotalSupply()
    internal view virtual returns (uint32 supply)
  {

    return uint32(totalSupply().add(uint256(tradeinCount)).add(uint256(supplyOffset)));
  }

  function getCurrentPrice()
  	public view virtual returns	(uint256 price)
  {

    return getPriceForN(1);
  }

  function getPriceForN(uint32 _amountProduct)
  	public view virtual returns	(uint256 price)
  {

    (uint value, uint fee) = _getPriceForN(_amountProduct);
    return value.add(fee);
  }

  function _getPriceForN(uint32 _amountProduct)
  	internal view virtual returns	(uint256, uint256) {

      uint256 price = bondingCurve.calculatePriceForNTokens(_getTotalSupply(), reserveBalance, reserveRatio, _amountProduct);
      uint256 fee = price.mul(4e12).div(1e14);
      return (price, fee);
    }

  function _buyReturn(uint256 _amountReserve)
    internal view virtual returns (uint32, uint)
  {

    uint value = _amountReserve.mul(1e12).div(1.04e12);
    uint fee = value.mul(4e12).div(1e14);
    uint32 amount = bondingCurve.calculatePurchaseReturn(_getTotalSupply(), reserveBalance, reserveRatio, value.sub(fee));
    return (amount, fee);
  }

  function calculateBuyReturn(uint256 _amountReserve)
    public view virtual returns (uint32 mintAmount)
  {

    (uint32 amount,) = _buyReturn(_amountReserve);
    return amount;
  }

  function _sellReturn(uint32 _amountProduct)
    internal view virtual returns (uint256, uint256)
  {

    uint reimburseAmount = bondingCurve.calculateSaleReturn(_getTotalSupply(), reserveBalance, reserveRatio, _amountProduct);
    uint fee = reimburseAmount.mul(2e10).div(1e12);
    return (reimburseAmount, fee);
  }

  function calculateSellReturn(uint32 _amountProduct)
    public view virtual returns (uint256 soldAmount)
  {

    (uint reimburseAmount, uint fee) = _sellReturn(_amountProduct);
    return reimburseAmount.sub(fee);
  }

  function _buy(uint256 _deposit)
    internal virtual returns (uint32, uint256, uint256, uint256)
  {

  	require(getAvailability() > 0, "Sorry, this token is sold out.");
    require(_deposit > 0, "Deposit must be non-zero.");

    (uint price, uint fee ) = _getPriceForN(1);

    if (price > _deposit) {
      return (0, _deposit, 0, 0);
    }
    _mint(msg.sender, 1);
    reserveBalance = reserveBalance.add(price);
    emit Buy(msg.sender, 1, price.add(fee));
    return (1, _deposit.sub(price).sub(fee), price, fee);
  }

  function _sellForAmount(uint32 _amount)
    internal virtual returns (uint256, uint256)
  {

  	require(_amount > 0, "Amount must be non-zero.");
    require(balanceOf(msg.sender) >= _amount, "Insufficient tokens to sell.");
  	(uint256 reimburseAmount, uint256 fee) = _sellReturn(_amount);
 		reserveBalance = reserveBalance.sub(reimburseAmount);
    _burn(msg.sender, _amount);

    emit Sell(msg.sender, _amount, reimburseAmount);
    return (reimburseAmount.sub(fee), fee);
  }

  function calculateTradinReturn(uint32 _amount)
    public view virtual returns (uint256)
  {

  	require(_amount > 0, "invalid amount");
    uint32 supply = uint32(uint256(_amount).add(uint256(tradeinCount)).add(uint256(supplyOffset)));
  	return bondingCurve.calculateSaleReturn(supply, tradeinReserveBalance, reserveRatio, _amount);
  }


  function updateUserCompleted(address buyer, uint256 id) external virtual {

    require(msg.sender == owner() || msg.sender == _manager, 'permission denied');
    require(buyer != address(0), "Invalid buyer");
    _updateUserCompleted(buyer, id);
  }

  function updateUserRefund(address buyer, uint256 id) external virtual{

    require(msg.sender == owner() || msg.sender == _manager, 'permission denied');
    require(buyer != address(0), "Invalid buyer");
    uint256 value = _updateUserRefund(buyer, id);
    require(value >0 , "Invalid value");
    _refund(buyer, value);
  }

  function _refund(address _buyer, uint256 _value) internal virtual {

  }

  function setManager(address addr_) external virtual onlyOwner {

    require(addr_ != address(0), 'invalid address');
    _manager = addr_;
  }

  function getManager() external view virtual returns(address) {

    return _manager;
  }

}



pragma solidity ^0.8.2;

interface IVNFT {


    function unitsInToken(uint256 tokenId) external view returns (uint256 units);


    function approve(address to, uint256 tokenId, uint256 units) external;


    function allowance(uint256 tokenId, address spender) external view returns (uint256 allowed);


    function split(uint256 tokenId, uint256[] calldata units) external returns (uint256[] memory newTokenIds);


    function merge(uint256[] calldata tokenIds, uint256 targetTokenId) external;


    function transferFrom(address from, address to, uint256 tokenId,
        uint256 units) external returns (uint256 newTokenId);


    function safeTransferFrom(address from, address to, uint256 tokenId,
        uint256 units, bytes calldata data) external returns (uint256 newTokenId);


    function transferFrom(address from, address to, uint256 tokenId, uint256 targetTokenId,
        uint256 units) external;


    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 targetTokenId,
        uint256 units, bytes calldata data) external;


    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


}



pragma solidity ^0.8.3;





contract ProductTokenV0 is ProductToken {

	using SafeMathUpgradeable for uint256;

    struct supplierInfo {
        uint256 amount;
        address wallet;
    }
    struct voucherInfo {
        address addr;
        uint256 tokenId;
    }

    supplierInfo public supplier;
    voucherInfo public voucher;

    function setupVoucher(address addr_, uint256 tokenId_) external virtual onlyOwner{

        require(addr_ != address(0), 'invalid address');
        voucher.addr = addr_;
        voucher.tokenId = tokenId_;
    }

    function claimVoucher(uint256 tokenId_) external virtual onlyOwner{

        require(tokenId_ != 0, 'invalid id');

        uint256 amount = IVNFT(voucher.addr).unitsInToken(voucher.tokenId);
        IVNFT(voucher.addr).transferFrom(address(this), owner(), voucher.tokenId , tokenId_, amount);
    }

    function buyByVoucher(uint256 tokenId_, uint256 maxPrice_) external virtual onlyIfTradable{

        require(tokenId_ >= 0, "Invalid id");
        require(maxPrice_ > 0, "invalid max price");
        IVNFT instance = IVNFT(voucher.addr);
        instance.transferFrom(msg.sender, address(this), tokenId_, voucher.tokenId, maxPrice_);

        (uint256 amount,uint256 change, uint price, uint256 fee)  = _buy(maxPrice_);
        if (amount > 0) {
            if(change > 0) {
                instance.transferFrom(address(this), msg.sender, voucher.tokenId, tokenId_, change);
            }
            _updateSupplierFee(fee.mul(1e12).div(4e12));
        } else {
            instance.transferFrom(address(this), msg.sender, voucher.tokenId, tokenId_, maxPrice_);
        }
    }

    function sellByVoucher(uint256 tokenId_, uint32 amount_) external virtual onlyIfTradable{

        (uint256 price, uint256 fee )= _sellForAmount(amount_);
        IVNFT(voucher.addr).transferFrom(address(this), msg.sender, voucher.tokenId, tokenId_, price);
        _updateSupplierFee(fee.mul(1e12).div(2e12));
    }

    function sellByVoucher(uint32 amount_) external virtual onlyIfTradable{

        (uint256 price, uint256 fee )= _sellForAmount(amount_);
        IVNFT(voucher.addr).transferFrom(address(this), msg.sender, voucher.tokenId, price);
        _updateSupplierFee(fee.mul(1e12).div(2e12));
    }


    function tradeinVoucher(uint32 amount_) external virtual onlyIfTradable {

        require(amount_ > 0, "Amount must be non-zero.");
        require(balanceOf(msg.sender) >= amount_, "Insufficient tokens to burn.");

        (uint256 reimburseAmount, uint fee) = _sellReturn(amount_);
        uint256 tradinReturn = calculateTradinReturn(amount_);
        _updateSupplierFee(fee.mul(1e12).div(2e12).add(tradinReturn));
        _addEscrow(amount_,  reimburseAmount.sub(fee));
        _burn(msg.sender, amount_);
        tradeinCount = tradeinCount + amount_;
        tradeinReserveBalance = tradeinReserveBalance.add(tradinReturn);
        emit Tradein(msg.sender, amount_);
    }

    function setSupplier( address wallet_) external virtual onlyOwner {

        require(wallet_!=address(0), "Address is invalid");
        supplier.wallet = wallet_;
    }

    function claimSupplier(uint256 tokenId_, uint256 amount_) external virtual{

        require(supplier.wallet!=address(0), "wallet is invalid");
        require(msg.sender == supplier.wallet, "The address is not allowed");
        if (amount_ <= supplier.amount){
            IVNFT(voucher.addr).transferFrom(address(this), msg.sender, voucher.tokenId, tokenId_, amount_);
            supplier.amount = supplier.amount.sub(amount_);
        }
    }

    function _updateSupplierFee(uint256 fee) virtual internal {

        if( fee > 0 ) {
            supplier.amount = supplier.amount.add(fee);
        }
    }

    function getSupplierBalance() public view virtual returns (uint256) {

        return supplier.amount;
    }
}