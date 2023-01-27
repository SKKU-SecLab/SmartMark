
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
pragma solidity ^0.8.4;


library SafeERC20 {

    function safeSymbol(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x95d89b41)
        );
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x06fdde03)
        );
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) public view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x313ce567)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: Transfer failed"
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x23b872dd, from, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: TransferFrom failed"
        );
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
}// MIT
pragma solidity ^0.8.4;


contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Transaction is not available");
        _;
    }

    modifier whenPaused() {

        require(paused, "Transaction is available");
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
        emit Unpause();
    }
}// MIT

pragma solidity ^0.8.4;

library Math {

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

    function abs(int256 n) internal pure returns (uint256) {

        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}// MIT
pragma solidity ^0.8.4;
library Data {


enum State {
        NONE,
        PENDING,
        READY
    }
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
pragma solidity ^0.8.4;


contract AlphaToken is ERC20, Ownable {

    address alphaStrategy;
    address admin;

    mapping(address => uint256[]) public  amountDepositPerAddress;
    mapping(address => uint256[]) public  timeDepositPerAddress; 
    constructor() ERC20("Formation Fi: ALPHA TOKEN", "ALPHA") {}

    modifier onlyProxy() {
        require(
            (alphaStrategy != address(0)) && (admin != address(0)),
            "Formation.Fi: proxy is the zero address"
        );

        require(
            (msg.sender == alphaStrategy) || (msg.sender == admin),
             "Formation.Fi: Caller is not the proxy"
        );
        _;
    }
    modifier onlyAlphaStrategy() {
        require(alphaStrategy != address(0),
            "Formation.Fi: alphaStrategy is the zero address"
        );

        require(msg.sender == alphaStrategy,
             "Formation.Fi: Caller is not the alphaStrategy"
        );
        _;
    }

    function setAlphaStrategy(address _alphaStrategy) external onlyOwner {
        require(
            _alphaStrategy!= address(0),
            "Formation.Fi: alphaStrategy is the zero address"
        );
         alphaStrategy = _alphaStrategy;
    } 
    function setAdmin(address _admin) external onlyOwner {
        require(
            _admin!= address(0),
            "Formation.Fi: admin is the zero address"
        );
         admin = _admin;
    } 

    function addTimeDeposit(address _account, uint256 _time) external onlyAlphaStrategy {
         require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
         require(
            _time!= 0,
            "Formation.Fi: deposit time is zero"
        );
        timeDepositPerAddress[_account].push(_time);
    } 

    function addAmountDeposit(address _account, uint256 _amount) external onlyAlphaStrategy {
        require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
        require(
            _amount!= 0,
            "Formation.Fi: deposit amount is zero"
        );
        amountDepositPerAddress[_account].push(_amount);

    } 
    
   function mint(address _account, uint256 _amount) external onlyProxy {
       require(
          _account!= address(0),
           "Formation.Fi: account is the zero address"
        );
         require(
            _amount!= 0,
            "Formation.Fi: amount is zero"
        );
       _mint(_account,  _amount);
   }

    function burn(address _account, uint256 _amount) external onlyProxy {
        require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
         require(
            _amount!= 0,
            "Formation.Fi: amount is zero"
        );
        _burn( _account, _amount);
    }
    

    function ChecklWithdrawalRequest(address _account, uint256 _amount, uint256 _period) 
     external view returns (bool){

        require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
        require(
           _amount!= 0,
            "Formation.Fi: amount is zero"
        );
        uint256 [] memory _amountDeposit = amountDepositPerAddress[_account];
        uint256 [] memory _timeDeposit = timeDepositPerAddress[_account];
        uint256 _amountTotal = 0;
        for (uint256 i = 0; i < _amountDeposit.length; i++) {
            require ((block.timestamp - _timeDeposit[i]) >= _period, 
            "Formation.Fi: user position locked");
            if (_amount<= (_amountTotal + _amountDeposit[i])){
                break; 
            }
            _amountTotal = _amountTotal + _amountDeposit[i];
        }
        return true;
    }

    function updateDepositDataExternal( address _account,  uint256 _amount) 
        external onlyAlphaStrategy {
        require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
        require(
            _amount!= 0,
            "Formation.Fi: amount is zero"
        );
        uint256 [] memory _amountDeposit = amountDepositPerAddress[ _account];
        uint256 _amountlocal = 0;
        uint256 _amountTotal = 0;
        uint256 _newAmount;
        for (uint256 i = 0; i < _amountDeposit.length; i++) {
            _amountlocal  = Math.min(_amountDeposit[i], _amount- _amountTotal);
            _amountTotal = _amountTotal + _amountlocal;
            _newAmount = _amountDeposit[i] - _amountlocal;
            amountDepositPerAddress[_account][i] = _newAmount;
            if (_newAmount==0){
               deleteDepositData(_account, i);
            }
            if (_amountTotal == _amount){
               break; 
            }
        }
    }
    function updateDepositDataInernal( address _account,  uint256 _amount) internal {
        require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
        require(
            _amount!= 0,
            "Formation.Fi: amount is zero"
        );
        uint256 [] memory _amountDeposit = amountDepositPerAddress[ _account];
        uint256 _amountlocal = 0;
        uint256 _amountTotal = 0;
        uint256 _newAmount;
        for (uint256 i = 0; i < _amountDeposit.length; i++) {
            _amountlocal  = Math.min(_amountDeposit[i], _amount- _amountTotal);
            _amountTotal = _amountTotal +  _amountlocal;
            _newAmount = _amountDeposit[i] - _amountlocal;
            amountDepositPerAddress[_account][i] = _newAmount;
            if (_newAmount==0){
               deleteDepositData(_account, i);
            }
            if (_amountTotal == _amount){
               break; 
            }
        }
    }
    function deleteDepositData(address _account, uint256 _ind) internal {
        require(
            _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
        uint256 size = amountDepositPerAddress[_account].length-1;
        
        require( _ind <= size,
            " index is out of the range"
        );
        for (uint256 i = _ind; i< size; i++){
            amountDepositPerAddress[ _account][i] = amountDepositPerAddress[ _account][i+1];
            timeDepositPerAddress[ _account][i] = timeDepositPerAddress[ _account][i+1];
        }
        amountDepositPerAddress[ _account].pop();
        timeDepositPerAddress[ _account].pop();
       
    }
   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
      ) internal virtual override{
      
       if ((to != address(0)) && (to != alphaStrategy) 
       && (to != admin) && (from != address(0)) )
       {
          updateDepositDataInernal(from, amount);
          amountDepositPerAddress[to].push(amount);
          timeDepositPerAddress[to].push(block.timestamp);
        }
    }

}// MIT
pragma solidity ^0.8.4;


contract AdminInterface is Pausable {
    using SafeERC20 for IERC20;

    uint256 public COEFF_SCALE_DECIMALS_F = 1e4; // for fees
    uint256 public COEFF_SCALE_DECIMALS_P = 1e6; // for price
    uint256 public AMOUNT_SCALE_DECIMALS = 1; // for stable token

    uint256 public DEPOSIT_FEE_RATE = 50; // 
    uint256 public MANAGEMENT_FEE_RATE = 200;
    uint256 public PERFORMANCE_FEE_RATE = 2000;
    
    uint256 public SECONDES_PER_YEAR = 86400 * 365;  
    uint256 public PERFORMANCE_FEES = 0;
    uint256 public MANAGEMENT_FEES = 0;
    uint256 public MANAGEMENT_FEE_TIME = 0;

    uint256 public ALPHA_PRICE = 1000000;
    uint256 public ALPHA_PRICE_WAVG = 1000000;

    uint256 public MIN_AMOUNT = 1000 * 1e18;
    bool public CAN_CANCEL = true;
    
    uint256 public LOCKUP_PERIOD_MANAGER = 2 hours; 
    uint256 public LOCKUP_PERIOD_USER = 0 days; 
    uint256 public TIME_WITHDRAW_MANAGER = 0;
   
    uint public netDepositInd= 0;
    uint256 public netAmountEvent =0;
    uint256 public SLIPPAGE_TOLERANCE = 200;
    address public manager;
    address public treasury;
    address public alphaStrategy;

    AlphaToken public alphaToken;
    IERC20 public stableToken;
    constructor( address _manager, address _treasury, address _stableTokenAddress,
     address _alphaToken) {
        require(
            _manager != address(0),
            "Formation.Fi: manager address is the zero address"
        );
        require(
           _treasury != address(0),
            "Formation.Fi:  treasury address is the zero address"
            );
        require(
            _stableTokenAddress != address(0),
            "Formation.Fi: Stable token address is the zero address"
        );
        require(
           _alphaToken != address(0),
            "Formation.Fi: ALPHA token address is the zero address"
        );
        manager = _manager;
        treasury = _treasury; 
        stableToken = IERC20(_stableTokenAddress);
        alphaToken = AlphaToken(_alphaToken);
        uint8 _stableTokenDecimals = ERC20( _stableTokenAddress).decimals();
        if ( _stableTokenDecimals == 6) {
            AMOUNT_SCALE_DECIMALS= 1e12;
        }
    }

      modifier onlyAlphaStrategy() {
        require(alphaStrategy != address(0),
            "Formation.Fi: alphaStrategy is the zero address"
        );
        require(msg.sender == alphaStrategy,
             "Formation.Fi: Caller is not the alphaStrategy"
        );
        _;
    }

     modifier onlyManager() {
        require(msg.sender == manager, 
        "Formation.Fi: Caller is not the manager");
        _;
    }
    modifier canCancel() {
        require(CAN_CANCEL == true, "Formation Fi: Cancel feature is not available");
        _;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(
            _treasury != address(0),
            "Formation.Fi: manager address is the zero address"
        );
        treasury = _treasury;
    }

    function setManager(address _manager) external onlyOwner {
        require(
            _manager != address(0),
            "Formation.Fi: manager address is the zero address"
        );
        manager = _manager;
    }

    function setAlphaStrategy(address _alphaStrategy) public onlyOwner {
         require(
            _alphaStrategy!= address(0),
            "Formation.Fi: alphaStrategy is the zero address"
        );
         alphaStrategy = _alphaStrategy;
    } 


    function setStableToken(address _stableTokenAddress) public onlyOwner {
        require(
             _stableTokenAddress!= address(0),
            "Formation.Fi: stable token address is the zero address"
        );
        stableToken = IERC20(_stableTokenAddress);
        uint8 _stableTokenDecimals = ERC20(_stableTokenAddress).decimals();
        if (_stableTokenDecimals == 6) {
           AMOUNT_SCALE_DECIMALS= 1e12;
        }
        else {
           AMOUNT_SCALE_DECIMALS = 1;   
        }
    } 
     function setCancel(bool _cancel) external onlyManager {
        CAN_CANCEL = _cancel;
    }
     function setLockupPeriodManager(uint256 _lockupPeriodManager) external onlyManager {
        LOCKUP_PERIOD_MANAGER = _lockupPeriodManager;
    }

    function setLockupPeriodUser(uint256 _lockupPeriodUser) external onlyManager {
        LOCKUP_PERIOD_USER = _lockupPeriodUser;
    }
 
    function setDepositFeeRate(uint256 _rate) external onlyManager {
        DEPOSIT_FEE_RATE = _rate;
    }

    function setManagementFeeRate(uint256 _rate) external onlyManager {
        MANAGEMENT_FEE_RATE = _rate;
    }

    function setPerformanceFeeRate(uint256 _rate) external onlyManager {
        PERFORMANCE_FEE_RATE  = _rate;
    }
    function setMinAmount(uint256 _minAmount) external onlyManager {
        MIN_AMOUNT = _minAmount;
     }

    function setCoeffScaleDecimalsFees (uint256 _scale) external onlyManager {
        require(
             _scale > 0,
            "Formation.Fi: decimal fees factor is 0"
        );

       COEFF_SCALE_DECIMALS_F  = _scale;
     }

    function setCoeffScaleDecimalsPrice (uint256 _scale) external onlyManager {
        require(
             _scale > 0,
            "Formation.Fi: decimal price factor is 0"
        );
       COEFF_SCALE_DECIMALS_P  = _scale;
     }

    function updateAlphaPrice(uint256 _price) external onlyManager{
        require(
             _price > 0,
            "Formation.Fi: ALPHA price is 0"
        );
        ALPHA_PRICE = _price;
    }

    function updateAlphaPriceWAVG(uint256 _price_WAVG) external onlyAlphaStrategy {
        require(
             _price_WAVG > 0,
            "Formation.Fi: ALPHA price WAVG is 0"
        );
        ALPHA_PRICE_WAVG  = _price_WAVG;
    }
    function updateManagementFeeTime(uint256 _time) external onlyAlphaStrategy {
        MANAGEMENT_FEE_TIME = _time;
    }
  
    function calculatePerformanceFees() external onlyManager {
        require(PERFORMANCE_FEES == 0, "Formation.Fi: performance fees pending minting");
        uint256 _deltaPrice = 0;
        if (ALPHA_PRICE > ALPHA_PRICE_WAVG) {
            _deltaPrice = ALPHA_PRICE - ALPHA_PRICE_WAVG;
            ALPHA_PRICE_WAVG = ALPHA_PRICE;
            PERFORMANCE_FEES = (alphaToken.totalSupply() *
            _deltaPrice * PERFORMANCE_FEE_RATE) / (ALPHA_PRICE * COEFF_SCALE_DECIMALS_F); 
        }
    }
    function calculateManagementFees() external onlyManager {
        require(MANAGEMENT_FEES == 0, "Formation.Fi: management fees pending minting");
        if (MANAGEMENT_FEE_TIME!= 0){
           uint256 _deltaTime;
           _deltaTime = block.timestamp -  MANAGEMENT_FEE_TIME; 
           MANAGEMENT_FEES = (alphaToken.totalSupply() * MANAGEMENT_FEE_RATE * _deltaTime ) 
           /(COEFF_SCALE_DECIMALS_F * SECONDES_PER_YEAR);
           MANAGEMENT_FEE_TIME = block.timestamp; 
        }
    }
     
    function mintFees() external onlyManager {
        if ((PERFORMANCE_FEES + MANAGEMENT_FEES) > 0){
           alphaToken.mint(treasury, PERFORMANCE_FEES + MANAGEMENT_FEES);
           PERFORMANCE_FEES = 0;
           MANAGEMENT_FEES = 0;
        }
    }

    function calculateNetDepositInd(uint256 _depositAmountTotal, uint256 _withdrawAmountTotal)
     public onlyAlphaStrategy returns( uint) {
        if ( _depositAmountTotal >= 
        ((_withdrawAmountTotal * ALPHA_PRICE) / COEFF_SCALE_DECIMALS_P)){
            netDepositInd = 1 ;
        }
        else {
            netDepositInd = 0;
        }
        return netDepositInd;
    }

    function calculateNetAmountEvent(uint256 _depositAmountTotal, uint256 _withdrawAmountTotal,
        uint256 _MAX_AMOUNT_DEPOSIT, uint256 _MAX_AMOUNT_WITHDRAW) 
        public onlyAlphaStrategy returns(uint256) {
        uint256 _netDeposit;
        if (netDepositInd == 1) {
             _netDeposit = _depositAmountTotal - 
             (_withdrawAmountTotal * ALPHA_PRICE) / COEFF_SCALE_DECIMALS_P;
             netAmountEvent = Math.min( _netDeposit, _MAX_AMOUNT_DEPOSIT);
        }
        else {
            _netDeposit= ((_withdrawAmountTotal * ALPHA_PRICE) / COEFF_SCALE_DECIMALS_P) -
            _depositAmountTotal;
            netAmountEvent = Math.min(_netDeposit, _MAX_AMOUNT_WITHDRAW);
        }
        return netAmountEvent;
    }

    function protectAgainstSlippage(uint256 _withdrawAmount) public onlyManager 
         whenNotPaused   returns (uint256) {
        require(netDepositInd == 0, "Formation.Fi: it is not a slippage case");
        require(_withdrawAmount != 0, "Formation.Fi: amount is zero");
       uint256 _amount = 0; 
       uint256 _deltaAmount =0;
       uint256 _slippage = 0;
       uint256  _alphaAmount = 0;
       uint256 _balanceAlphaTreasury = alphaToken.balanceOf(treasury);
       uint256 _balanceStableTreasury = stableToken.balanceOf(treasury) * AMOUNT_SCALE_DECIMALS;
      
        if (_withdrawAmount< netAmountEvent){
          _amount = netAmountEvent - _withdrawAmount;   
          _slippage = _amount  / netAmountEvent;
            if ((_slippage * COEFF_SCALE_DECIMALS_F) >= SLIPPAGE_TOLERANCE) {
             return netAmountEvent;
            }
            else {
              _deltaAmount = Math.min( _amount, _balanceStableTreasury);
                if ( _deltaAmount  > 0){
                   stableToken.safeTransferFrom(treasury, alphaStrategy, _deltaAmount/AMOUNT_SCALE_DECIMALS);
                   _alphaAmount = (_deltaAmount * COEFF_SCALE_DECIMALS_P)/ALPHA_PRICE;
                   alphaToken.mint(treasury, _alphaAmount);
                   return _amount - _deltaAmount;
               }
               else {
                   return _amount; 
               }  
            }    
        
        }
        else  {
          _amount = _withdrawAmount - netAmountEvent;   
          _alphaAmount = (_amount * COEFF_SCALE_DECIMALS_P)/ALPHA_PRICE;
          _alphaAmount = Math.min(_alphaAmount, _balanceAlphaTreasury);
          if (_alphaAmount >0) {
             _deltaAmount = (_alphaAmount * ALPHA_PRICE)/COEFF_SCALE_DECIMALS_P;
             stableToken.safeTransfer(treasury, _deltaAmount/AMOUNT_SCALE_DECIMALS);   
             alphaToken.burn( treasury, _alphaAmount);
            }
           if ((_amount - _deltaAmount)>0) {
              stableToken.safeTransfer(manager, (_amount - _deltaAmount)/AMOUNT_SCALE_DECIMALS); 
            }
        }
        return 0;

    } 

    function sendStableTocontract(uint256 _amount) external 
      whenNotPaused onlyManager {
      require( _amount > 0,  "Formation.Fi: amount is zero");
      stableToken.safeTransferFrom(msg.sender, address(this), _amount/AMOUNT_SCALE_DECIMALS);
      }

    function sendStableFromcontract() external 
        whenNotPaused onlyManager {
        require(alphaStrategy != address(0),
            "Formation.Fi: alphaStrategy is the zero address"
        );
         stableToken.safeTransfer(alphaStrategy, stableToken.balanceOf(address(this)));
      }
  


}// MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
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

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}// MIT
pragma solidity ^0.8.4;



contract DepositNFT is ERC721, Ownable {

    struct PendingDeposit {
        Data.State state;
        uint256 amountStable;
        uint256 listPointer;
    }

    address public proxy;
    
    mapping(address => PendingDeposit) public pendingDepositPerAddress;
    address[] public usersOnPendingDeposit;
    
    

    mapping(address => uint256) private tokenIdPerAddress;

    constructor ()  ERC721 ("Deposit Proof", "DEPOSIT"){
    }

    modifier onlyProxy() {
        require(
            proxy != address(0),
            "Formation.Fi: proxy is the zero address"
        );
        require(msg.sender == proxy, "Formation.Fi: Caller is not the proxy");
        _;
    }

    function getTokenId(address _account) public view returns (uint256) {
        require(
           _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
        return tokenIdPerAddress[_account];
    }
    function userSize() public view  returns (uint256) {
        return usersOnPendingDeposit.length;
    }

    function getArray() public view returns (address[] memory) {
        return usersOnPendingDeposit;
    }

    function setProxy(address _proxy) public onlyOwner {
        require(
            _proxy != address(0),
            "Formation.Fi: proxy is the zero address"
        );
        proxy = _proxy;
    }    
    
    function mint(address _account, uint256 _tokenId, uint256 _amount) 
       external onlyProxy {
       require (balanceOf(_account) == 0, "Formation.Fi: account has already a deposit NfT");
       _safeMint(_account,  _tokenId);
       updateDepositData( _account,  _tokenId, _amount, true);
    }
    function burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        require (pendingDepositPerAddress[owner].state != Data.State.PENDING,
        "Formation.Fi: position is on pending");
        deleteDepositData(owner);
        _burn(tokenId); 
    }
     
    function updateDepositData(address _account, uint256 _tokenId, 
        uint256 _amount, bool add) public onlyProxy {
        require (_exists(_tokenId), "Formation.Fi: token does not exist");
        require (ownerOf(_tokenId) == _account , "Formation.Fi: account is not the token owner");
        if( _amount > 0){
           if (add){
              if(pendingDepositPerAddress[_account].amountStable == 0){
                  pendingDepositPerAddress[_account].state = Data.State.PENDING;
                  pendingDepositPerAddress[_account].listPointer = usersOnPendingDeposit.length;
                  tokenIdPerAddress[_account] = _tokenId;
                  usersOnPendingDeposit.push(_account);
                }
              pendingDepositPerAddress[_account].amountStable = pendingDepositPerAddress[_account].amountStable 
              +  _amount;
            }
            else {
               require(pendingDepositPerAddress[_account].amountStable >= _amount, 
               "Formation Fi:  amount excedes pending deposit");
               uint256 _newAmount = pendingDepositPerAddress[_account].amountStable - _amount;
               pendingDepositPerAddress[_account].amountStable = _newAmount;
               if (_newAmount == 0){
                  pendingDepositPerAddress[_account].state = Data.State.NONE;
                  burn(_tokenId);
                }
            }
        }
    }    

    function deleteDepositData(address _account) internal {
        require(
           _account!= address(0),
            "Formation.Fi: account is the zero address"
        );
         uint256 _ind = pendingDepositPerAddress[_account].listPointer;
         address _user = usersOnPendingDeposit[usersOnPendingDeposit.length - 1];
         usersOnPendingDeposit[_ind] = _user;
         pendingDepositPerAddress[_user].listPointer = _ind;
         usersOnPendingDeposit.pop();
         delete pendingDepositPerAddress[_account]; 
         delete tokenIdPerAddress[_account];    
    }

    function _beforeTokenTransfer(
       address from,
       address to,
       uint256 tokenId
    )   internal virtual override {
        if ((to != address(0)) && (from != address(0))){
            require ((to != proxy), 
            "Formation.Fi: destination address cannot be the proxy"
            );
            uint256 indFrom = pendingDepositPerAddress[from].listPointer;
            pendingDepositPerAddress[to] = pendingDepositPerAddress[from];
            pendingDepositPerAddress[from].state = Data.State.NONE;
            pendingDepositPerAddress[from].amountStable =0;
            usersOnPendingDeposit[indFrom] = to; 
            tokenIdPerAddress[to] = tokenIdPerAddress[from];
            delete pendingDepositPerAddress[from];
            delete tokenIdPerAddress[from];
        }
    }
   
}// MIT
pragma solidity ^0.8.4;


contract WithdrawalNFT is ERC721, Ownable {

    address proxy;  

    struct PendingWithdrawal {
        Data.State state;
        uint256 amountAlpha;
        uint256 listPointer;
    }
    mapping(address => PendingWithdrawal) public pendingWithdrawPerAddress;
    address[] public usersOnPendingWithdraw;

    mapping(address => uint256) private tokenIdPerAddress;

    constructor () ERC721 ("Withdrawal Proof", "WITHDRAW"){
     }

    modifier onlyProxy() {
        require(
            proxy != address(0),
            "Formation.Fi: proxy is the zero address"
        );
        require(msg.sender == proxy, "Formation.Fi: Caller is not the proxy");
         _;
    }

    function getTokenId(address _owner) public view returns (uint256) {
        return tokenIdPerAddress[ _owner];
    }
     function userSize() public view returns (uint256) {
        return usersOnPendingWithdraw.length;
    }
    function getArray() public view returns (address[] memory) {
        return usersOnPendingWithdraw;
    }

    function setProxy(address _proxy) public onlyOwner {
        require(
            _proxy != address(0),
            "Formation.Fi: proxy is the zero address"
        );
        proxy = _proxy;
    }    

    function mint(address _account, uint256 _tokenId, uint256 _amount) 
       external onlyProxy {
       require (pendingWithdrawPerAddress[msg.sender].state != Data.State.PENDING, 
       "Formation.Fi: withdraw is pending");
       _safeMint(_account,  _tokenId);
       tokenIdPerAddress[_account] = _tokenId;
       updateWithdrawData (_account,  _tokenId,  _amount, true);
    }

    function burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        require (pendingWithdrawPerAddress[owner].state != Data.State.PENDING, 
        "Formation.Fi: position is on pending");
        deleteWithdrawData(owner);
        _burn(tokenId);   
    }

    function updateWithdrawData (address _account, uint256 _tokenId, 
        uint256 _amount, bool add) public onlyProxy {
        require (_exists(_tokenId), "Formation Fi: token does not exist");
        require (ownerOf(_tokenId) == _account , 
         "Formation.Fi: account is not the token owner");
        if( _amount > 0){
            if (add){
               pendingWithdrawPerAddress[_account].state = Data.State.PENDING;
               pendingWithdrawPerAddress[_account].amountAlpha = _amount;
               pendingWithdrawPerAddress[_account].listPointer = usersOnPendingWithdraw.length;
               usersOnPendingWithdraw.push(_account);
            }
            else {
               require(pendingWithdrawPerAddress[_account].amountAlpha >= _amount, 
               "Formation.Fi: amount excedes pending withdraw");
               uint256 _newAmount = pendingWithdrawPerAddress[_account].amountAlpha - _amount;
               pendingWithdrawPerAddress[_account].amountAlpha = _newAmount;
               if (_newAmount == 0){
                   pendingWithdrawPerAddress[_account].state = Data.State.NONE;
                   burn(_tokenId);
                }
            }     
       }
    }

    function deleteWithdrawData(address _account) internal {
        require(
          _account!= address(0),
          "Formation.Fi: account is the zero address"
        );
        uint256 _ind = pendingWithdrawPerAddress[_account].listPointer;
        address _user = usersOnPendingWithdraw[usersOnPendingWithdraw.length -1];
        usersOnPendingWithdraw[ _ind] = _user ;
        pendingWithdrawPerAddress[ _user].listPointer = _ind;
        usersOnPendingWithdraw.pop();
        delete pendingWithdrawPerAddress[_account]; 
        delete tokenIdPerAddress[_account];    
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
       if ((to != address(0)) && (from != address(0))){
          require ((to != proxy), 
           "Formation Fi: destination address is the proxy"
          );
          uint256 indFrom = pendingWithdrawPerAddress[from].listPointer;
          pendingWithdrawPerAddress[to] = pendingWithdrawPerAddress[from];
          pendingWithdrawPerAddress[from].state = Data.State.NONE;
          pendingWithdrawPerAddress[from].amountAlpha =0;
          usersOnPendingWithdraw[indFrom] = to; 
          tokenIdPerAddress[to] = tokenIdPerAddress[from];
          delete pendingWithdrawPerAddress[from];
          delete tokenIdPerAddress[from];
        }
    }
   
}// MIT
pragma solidity ^0.8.4;


contract AlphaStrategy is Pausable {
    using SafeERC20 for IERC20;
    using Math for uint256;

    uint256 public AMOUNT_SCALE_DECIMALS = 1; // for stable token 
    uint256 public COEFF_SCALE_DECIMALS_F;  // for fees
    uint256 public COEFF_SCALE_DECIMALS_P; // for ALPHA price
    
    uint256 public MAX_AMOUNT_DEPOSIT = 1000000 * 1e18;
    uint256 public MAX_AMOUNT_WITHDRAW = 1000000 * 1e18;

    uint256 public  DEPOSIT_FEE_RATE;

    uint256 public ALPHA_PRICE;
    uint256 public ALPHA_PRICE_WAVG;
 
    uint public netDepositInd;
    uint256 public netAmountEvent;
    uint256 public maxDepositAmount;
    uint256 public maxWithdrawAmount;
    uint256 public withdrawAmountTotal;
    uint256 public depositAmountTotal;
    uint256 public TIME_WITHDRAW_MANAGER = 0;
     
    uint256 public totalSupply;
   
    uint256 tokenIdDeposit;
    uint256 tokenIdWithdraw;

    bool public CAN_CANCEL = false; 
    address public treasury;
    mapping(address => uint256) public acceptedWithdrawPerAddress;
    
    AdminInterface public admin;
    IERC20 public stableToken;
    AlphaToken public alphaToken;
    DepositNFT public depositNFT;
    WithdrawalNFT public withdrawalNFT;
    constructor(address _admin, address _stableTokenAddress, address _alphaToken,
        address _depositNFTAdress, address _withdrawalNFTAdress) {
        require(
            _admin != address(0),
            "Formation.Fi: admin address is the zero address"
        );
        require(
            _stableTokenAddress != address(0),
            "Formation.Fi: Stable token address is the zero address"
        );
        require(
           _alphaToken != address(0),
            "Formation.Fi: ALPHA token address is the zero address"
        );
        require(
           _depositNFTAdress != address(0),
            "Formation.Fi: withdrawal NFT address is the zero address"
        );
        require(
            _withdrawalNFTAdress != address(0),
            "Formation.Fi: withdrawal NFT address is the zero address"
        );
        
        admin = AdminInterface(_admin);
        stableToken = IERC20(_stableTokenAddress);
        alphaToken = AlphaToken(_alphaToken);
        depositNFT = DepositNFT(_depositNFTAdress);
        withdrawalNFT = WithdrawalNFT(_withdrawalNFTAdress);
        uint8 _stableTokenDecimals = ERC20(_stableTokenAddress).decimals();
        if (_stableTokenDecimals == 6) {
           AMOUNT_SCALE_DECIMALS = 1e12;
        }
    }

    
    
    modifier onlyManager() {
        address _manager = admin.manager();
        require(msg.sender == _manager, "Formation.Fi: Caller is not the manager");
        _;
    }

    modifier canCancel() {
        bool  _CAN_CANCEL = admin.CAN_CANCEL();
        require( _CAN_CANCEL == true, "Formation.Fi: Cancel feature is not available");
        _;
    }

    
    function getTVL() public view returns (uint256) {
        return (admin.ALPHA_PRICE() * alphaToken.totalSupply()) 
        / admin.COEFF_SCALE_DECIMALS_P();
    }

    function set_MAX_AMOUNT_DEPOSIT(uint256 _MAX_AMOUNT_DEPOSIT) external 
         onlyManager {
         MAX_AMOUNT_DEPOSIT = _MAX_AMOUNT_DEPOSIT;

    }
    function set_MAX_AMOUNT_WITHDRAW(uint256 _MAX_AMOUNT_WITHDRAW) external 
      onlyManager{
         MAX_AMOUNT_WITHDRAW = _MAX_AMOUNT_WITHDRAW;      
    }
    function updateAdminData() internal {
      COEFF_SCALE_DECIMALS_F = admin.COEFF_SCALE_DECIMALS_F();
      COEFF_SCALE_DECIMALS_P= admin.COEFF_SCALE_DECIMALS_P(); 
      DEPOSIT_FEE_RATE = admin.DEPOSIT_FEE_RATE();
      ALPHA_PRICE = admin.ALPHA_PRICE();
      ALPHA_PRICE_WAVG = admin.ALPHA_PRICE_WAVG();
      totalSupply = alphaToken.totalSupply();
      treasury = admin.treasury();
    }
    
    function calculateNetDepositInd() public onlyManager {
        updateAdminData();
        netDepositInd = admin.calculateNetDepositInd(depositAmountTotal, withdrawAmountTotal);
    }
    function calculateNetAmountEvent() public onlyManager {
        netAmountEvent = admin.calculateNetAmountEvent(depositAmountTotal,  withdrawAmountTotal,
        MAX_AMOUNT_DEPOSIT,  MAX_AMOUNT_WITHDRAW);
    }
    function calculateMaxDepositAmount( ) external 
        whenNotPaused onlyManager {
        if (netDepositInd == 1) {
            maxDepositAmount = (netAmountEvent + ((withdrawAmountTotal * 
            ALPHA_PRICE) / COEFF_SCALE_DECIMALS_P));
        }
        else {
            maxDepositAmount = Math.min(depositAmountTotal, MAX_AMOUNT_DEPOSIT);
        }
    }
    
    function calculateMaxWithdrawAmount( ) external 
        whenNotPaused onlyManager
        {
        maxWithdrawAmount = ((netAmountEvent + depositAmountTotal) 
          * COEFF_SCALE_DECIMALS_P) /( ALPHA_PRICE * withdrawAmountTotal);
    }

    function calculateAcceptedWithdrawRequests(address[] memory _users) 
        internal {
        require (_users.length > 0, "Formation.Fi: no users provided");
        uint256 _amountLP;
        Data.State _state;
        for (uint256 i = 0; i < _users.length; i++) {
            require(
            _users[i]!= address(0),
            "Formation.Fi: user address is the zero address"
            );
           ( _state , _amountLP, )= withdrawalNFT.pendingWithdrawPerAddress(_users[i]);
            if (_state != Data.State.PENDING) {
                continue;
            }
        _amountLP = Math.min((maxWithdrawAmount * _amountLP), _amountLP); 
        acceptedWithdrawPerAddress[_users[i]] = _amountLP;
        }   
    }

    function finalizeDeposits( address[] memory _users) external 
        whenNotPaused onlyManager {
        uint256 _amountStable;
        uint256 _amountStableTotal = 0;
        uint256 _depositAlpha;
        uint256 _depositAlphaTotal = 0;
        uint256 _feeStable;
        uint256 _feeStableTotal = 0;
        uint256 _tokenIdDeposit;
        Data.State _state;
        require (_users.length > 0, "Formation.Fi: no users provided ");
        
        for (uint256 i = 0; i < _users.length  ; i++) {
            ( _state , _amountStable, )= depositNFT.pendingDepositPerAddress(_users[i]);
           
            if (_state != Data.State.PENDING) {
                continue;
              }
            if (maxDepositAmount <= _amountStableTotal) {
                break;
             }
             _tokenIdDeposit = depositNFT.getTokenId(_users[i]);
             _amountStable = Math.min(maxDepositAmount  - _amountStableTotal ,  _amountStable);
             _feeStable =  (_amountStable * DEPOSIT_FEE_RATE ) /
              COEFF_SCALE_DECIMALS_F;
             depositAmountTotal =  depositAmountTotal - _amountStable;
             _feeStableTotal = _feeStableTotal + _feeStable;
             _depositAlpha = (( _amountStable - _feeStable) *
             COEFF_SCALE_DECIMALS_P) / ALPHA_PRICE;
             _depositAlphaTotal = _depositAlphaTotal + _depositAlpha;
             _amountStableTotal = _amountStableTotal + _amountStable;
             alphaToken.mint(_users[i], _depositAlpha);
             depositNFT.updateDepositData( _users[i],  _tokenIdDeposit, _amountStable, false);
             alphaToken.addAmountDeposit(_users[i],  _depositAlpha );
             alphaToken.addTimeDeposit(_users[i], block.timestamp);
        }
        maxDepositAmount = maxDepositAmount - _amountStableTotal;
        if (_depositAlphaTotal >0){
            ALPHA_PRICE_WAVG  = (( totalSupply * ALPHA_PRICE_WAVG) + ( _depositAlphaTotal * ALPHA_PRICE)) /
            ( totalSupply + _depositAlphaTotal);
            }
            admin.updateAlphaPriceWAVG( ALPHA_PRICE_WAVG);

        if (admin.MANAGEMENT_FEE_TIME() == 0){
            admin.updateManagementFeeTime(block.timestamp);   
        }
        if ( _feeStableTotal >0){
           stableToken.safeTransfer( treasury, _feeStableTotal/AMOUNT_SCALE_DECIMALS);
        }
    }

    function finalizeWithdrawals(address[] memory _users) external
        whenNotPaused onlyManager {
        uint256 tokensToBurn = 0;
        uint256 _amountLP;
        uint256 _amountStable;
        uint256 _tokenIdWithdraw;
        Data.State _state;
        calculateAcceptedWithdrawRequests(_users);
        for (uint256 i = 0; i < _users.length; i++) {
            ( _state , _amountLP, )= withdrawalNFT.pendingWithdrawPerAddress(_users[i]);
         
            if (_state != Data.State.PENDING) {
                continue;
            }
            _amountLP = acceptedWithdrawPerAddress[_users[i]];
            withdrawAmountTotal = withdrawAmountTotal - _amountLP ;
            _amountStable = (_amountLP *  ALPHA_PRICE) / 
            ( COEFF_SCALE_DECIMALS_P * AMOUNT_SCALE_DECIMALS);
            stableToken.safeTransfer(_users[i], _amountStable);
            _tokenIdWithdraw = withdrawalNFT.getTokenId(_users[i]);
            withdrawalNFT.updateWithdrawData( _users[i],  _tokenIdWithdraw, _amountLP, false);
            tokensToBurn = tokensToBurn + _amountLP;
            alphaToken.updateDepositDataExternal(_users[i], _amountLP);
            delete acceptedWithdrawPerAddress[_users[i]]; 
        }
        if ((tokensToBurn) > 0){
           alphaToken.burn(address(this), tokensToBurn);
        }
    }


    function depositRequest(uint256 _amount) external whenNotPaused {
        require(_amount >= admin.MIN_AMOUNT(), 
        "Formation.Fi: amount is lower than the minimum deposit amount");
        if (depositNFT.balanceOf(msg.sender)==0){
            tokenIdDeposit = tokenIdDeposit +1;
            depositNFT.mint(msg.sender, tokenIdDeposit, _amount);
        }
        else {
            uint256 _tokenIdDeposit = depositNFT.getTokenId(msg.sender);
            depositNFT.updateDepositData (msg.sender,  _tokenIdDeposit, _amount, true);
        }
        depositAmountTotal = depositAmountTotal + _amount; 
        stableToken.safeTransferFrom(msg.sender, address(this), _amount/AMOUNT_SCALE_DECIMALS);
    }

    function cancelDepositRequest(uint256 _amount) external whenNotPaused canCancel {
        uint256 _tokenIdDeposit = depositNFT.getTokenId(msg.sender);
        require( _tokenIdDeposit > 0, 
        "Formation.Fi: deposit request doesn't exist"); 
        depositNFT.updateDepositData(msg.sender,  _tokenIdDeposit, _amount, false);
        depositAmountTotal = depositAmountTotal - _amount; 
        stableToken.safeTransfer(msg.sender, _amount/AMOUNT_SCALE_DECIMALS);
        
    }
    
    function withdrawRequest(uint256 _amount) external whenNotPaused {
        require ( _amount > 0, "Formation Fi: amount is zero");
        require((alphaToken.balanceOf(msg.sender)) >= _amount,
         "Formation Fi: amount exceeds user balance");
        require (alphaToken.ChecklWithdrawalRequest(msg.sender, _amount, admin.LOCKUP_PERIOD_USER()),
         "Formation Fi: user Position locked");
        tokenIdWithdraw = tokenIdWithdraw +1;
        withdrawalNFT.mint(msg.sender, tokenIdWithdraw, _amount);
        withdrawAmountTotal = withdrawAmountTotal + _amount;
        alphaToken.transferFrom(msg.sender, address(this), _amount);
         
    }

    function cancelWithdrawalRequest( uint256 _amount) external whenNotPaused {
        require ( _amount > 0, "Formation Fi: amount is zero");
        uint256 _tokenIdWithdraw = withdrawalNFT.getTokenId(msg.sender);
        require( _tokenIdWithdraw > 0, 
        "Formation.Fi: withdrawal request doesn't exist"); 
        withdrawalNFT.updateWithdrawData(msg.sender, _tokenIdWithdraw, _amount, false);
        alphaToken.transfer(msg.sender, _amount);
    }
    
    function availableBalanceWithdrawal(uint256 _amount) external 
        whenNotPaused onlyManager {
        require(block.timestamp - TIME_WITHDRAW_MANAGER >= admin.LOCKUP_PERIOD_MANAGER(), 
         "Formation.Fi: Manager Position locked");
        uint256 _amountScaled = _amount/AMOUNT_SCALE_DECIMALS;
        require(
            stableToken.balanceOf(address(this)) >= _amountScaled,
            "Formation Fi: requested amount exceeds contract balance"
        );
        TIME_WITHDRAW_MANAGER = block.timestamp;
        stableToken.safeTransfer(admin.manager(), _amountScaled);
    }
    
    function sendStableTocontract(uint256 _amount) external 
      whenNotPaused onlyManager {
      require( _amount > 0,  "amount is zero");
      stableToken.safeTransferFrom(msg.sender, address(this), _amount/AMOUNT_SCALE_DECIMALS);
    } 
    
}