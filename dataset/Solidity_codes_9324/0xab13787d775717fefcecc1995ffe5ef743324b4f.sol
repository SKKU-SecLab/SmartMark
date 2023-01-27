
pragma solidity 0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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
}
interface IwrappedToken {

    
     function burn(uint256 amount) external ;

     function mint(address account , uint256 amount) external ;

}


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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_ , uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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

}



contract WrappedToken is ERC20 ,Ownable {
    constructor (string memory _name ,  string memory _symbol ,uint8 _decimals)  ERC20(_name , _symbol ,_decimals){
        
    } 
    function burn(uint256 amount) public   onlyOwner {
        _burn(_msgSender(), amount);
    }
    function mint(address account, uint256 amount) public  onlyOwner{
     _mint( account,  amount) ;   
    }
    
    
}
abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}
interface IController {
    function isAdmin(address account) external view returns (bool);
    function isRegistrar(address account) external view returns (bool);
    function isOracle(address account) external view returns (bool);
    function isValidator(address account) external view returns (bool);
    function owner() external view returns (address);
    
}


contract BridgePool is Context , ReentrancyGuard {
  
    struct  pool{
        address wrappedAsset;
        uint256 deposited;
        uint256 debt;
        uint256 overFlow;
        uint256 debtThreshold;
        bool isSet;
        
    }
    IController public controller;
    address public bridge;
    address public pendingBridge;
    uint256 public bridgeUpdateInnitiatedAt;
    mapping(address => pool) public pools;
    address[] public poolAddresses;
    uint256 public poolCount;
    uint256 public bridgeUpdateDelay = 1 days;
    
    event PoolToppedUp(address indexed poolAddress,uint256 amount);
    event AssetSentOut(address indexed  poolAddress, address indexed  reciever ,uint256 amount);
    event AssetWithdrawn(address indexed poolAddress , address indexed receiver,uint256  amount);
    event AssetDeposited(address indexed poolAddress , uint256  amount);
    event PoolCreated(address indexed poolAddress, address indexed wrappedAsset); 
    event NewBridgeInnitiated(address indexed curentBridge ,address indexed pendingBridge);
    event NewBridgeActivated(address indexed prevBridge , address indexed newBridge);
    event PoolDebtThresholdUpdated(
        address indexed poolAddress,
        uint256 oldDebtThreshold,
        uint256 newDebtThreshold
    );
    bool initialized;
     modifier onlyBridge() {
         require(bridge == _msgSender(), "Only Bridge Callable");
        _; 
     }
     modifier poolInitialized() {
         require(initialized, "pool not initialized");
        _; 
     }
    
    
    constructor(IController _controller ) {
        require(address(_controller) != address(0), "Zero address Err");
        controller = _controller;
    }
    
    function initializePool(address _bridge) public {
        isOwner();
        require(_bridge != address(0) && !initialized , "Er");
        bridge = _bridge;
        initialized = true;

    }

    function innitiateBridgeUpdate(address newBridge) public poolInitialized{
        isOwner();
        require(pendingBridge == address(0) , "pending Bridge already innitiated");
        pendingBridge = newBridge;
        emit NewBridgeInnitiated(bridge , pendingBridge);
        bridgeUpdateInnitiatedAt = block.timestamp;
    }
    function suspendBridgeUpdate() public poolInitialized{
        isOwner();
        require(pendingBridge != address(0) , "new bridge not innitiated");
        pendingBridge = address(0);
    }
    function activateNewBridge() public  poolInitialized{
        isOwner();
        require(pendingBridge != address(0) , "new bridge not innitiated");
        require(block.timestamp - bridgeUpdateInnitiatedAt > bridgeUpdateDelay , "update delay active");
        emit NewBridgeActivated(bridge , pendingBridge);
        bridge = pendingBridge;
        pendingBridge = address(0);
    }


    function updatePoolDebtThreshold(address poolAddress , uint256 debtThreshold) public poolInitialized{
        isOwner();
        require(pools[poolAddress].isSet , "invalid Pool");
        require(debtThreshold > 0 , "cant be zero");
        emit PoolDebtThresholdUpdated(poolAddress ,pools[poolAddress].debtThreshold , debtThreshold);
        pools[poolAddress].debtThreshold = debtThreshold;
     
    }
     

    function createPool(
        address poolAddress,
        uint256 debtThreshold
    ) 
        public
        onlyBridge
        poolInitialized
    {
        require(!pools[poolAddress].isSet , "pool already Created");
        require(debtThreshold > 0 , "cant be zero");
        WrappedToken wrappedAsset;
        if(poolAddress == address(0)){

           wrappedAsset =    new WrappedToken("ETHEREUM" , "brETH" , 18);
        }else{
            IERC20Metadata token = IERC20Metadata(poolAddress);
            wrappedAsset =    new WrappedToken(token.name() , string(abi.encodePacked("br" , token.symbol())) , token.decimals());
        }
        
        pools[poolAddress] = pool(address(wrappedAsset), 0 , 0 , 0, debtThreshold , true);
        poolAddresses.push(poolAddress);
        poolCount++;
        emit PoolCreated(poolAddress , address(wrappedAsset));       
    }
    

    function deposit(address poolAddress, uint256 amount) public payable nonReentrant poolInitialized{
        require(pools[poolAddress].isSet , "invalid Pool");
         (bool success , uint256 amountRecieved) = processedPayment(poolAddress , amount);
         require(success && amountRecieved > 0, "I_F");
         pools[poolAddress].deposited += amountRecieved;
         IwrappedToken(pools[poolAddress].wrappedAsset).mint(msg.sender , amountRecieved);
         emit AssetDeposited(poolAddress , amountRecieved);
        
    }

    function withdraw(address poolAddress , uint256 amount) public nonReentrant poolInitialized{ 

         require(pools[poolAddress].isSet , "invalid Pool");  
         IERC20 token = IERC20(poolAddress);
         IERC20 wrappedToken = IERC20(pools[poolAddress].wrappedAsset);
      
         require(pools[poolAddress].deposited  >= amount && token.balanceOf(address(this)) >= amount , "Insufficent Pool Balance");
         require(wrappedToken.allowance(_msgSender(), address(this)) >= amount , "I_F");
         uint256 balanceBefore = IERC20(pools[poolAddress].wrappedAsset).balanceOf(address(this));
         wrappedToken.transferFrom(_msgSender() , address(this) , amount);
         uint256 balanceAfter = wrappedToken.balanceOf(address(this));
         require(balanceAfter - balanceBefore > 0 , "I_F");
         uint256 amountRecieved = balanceAfter - balanceBefore;
         IwrappedToken(pools[poolAddress].wrappedAsset).burn(amountRecieved);
         payoutUser(payable(_msgSender()) , poolAddress , amountRecieved);
         pools[poolAddress].deposited -= amountRecieved;
         emit AssetWithdrawn(poolAddress , _msgSender() , amountRecieved);

    }


    function sendOut(address poolAddress , address receiver , uint256 amount) public onlyBridge poolInitialized{
        require(receiver != address(0) , "Z_A_E");
       require(pools[poolAddress].isSet , "invalid Pool");
        IERC20 token = IERC20(poolAddress);
        require( pools[poolAddress].overFlow + pools[poolAddress].deposited >= amount && token.balanceOf(address(this)) >= amount , "Insufficent Pool Balance");
        if (pools[poolAddress].overFlow > 0) {
            if (pools[poolAddress].overFlow >= amount){
                pools[poolAddress].overFlow -= amount;
            } else {
                uint256 _debt = amount - pools[poolAddress].overFlow;
                 pools[poolAddress].debt +=  _debt;
                 pools[poolAddress].overFlow = 0;
            }
        } else {
           pools[poolAddress].debt +=  amount;
        }
        require(pools[poolAddress].debt < pools[poolAddress].debtThreshold , "Dept Threshold Exceeded");
        payoutUser(payable(receiver) , poolAddress , amount);
        emit AssetSentOut(poolAddress , receiver , amount);

    }


    function topUp(address poolAddress, uint256 amount) public onlyBridge poolInitialized{
        
        (bool success , uint256 amountRecieved) = processedPayment(poolAddress , amount);
        require(pools[poolAddress].isSet  && success, "invalid Pool");
        if (pools[poolAddress].debt > 0) {
            if (pools[poolAddress].debt >= amountRecieved){
                pools[poolAddress].debt -= amountRecieved;
            } else {
                uint256 _overFlow = amountRecieved - pools[poolAddress].debt;
                 pools[poolAddress].overFlow +=  _overFlow;
                 pools[poolAddress].debt = 0;
            }
        } else {
           pools[poolAddress].overFlow +=  amountRecieved;
        }
        
        emit PoolToppedUp( poolAddress, amountRecieved);

    }
     function processedPayment(address assetAddress , uint256 amount) internal   returns (bool , uint256) {
        if (assetAddress == address(0)) {
            if(msg.value >= amount ){
                uint256 value = msg.value;
                return (true , value);
            } else {
                return (false , 0);
            }
            
        } else {
            IERC20 token = IERC20(assetAddress);
            if (token.allowance(_msgSender(), address(this)) >= amount) {
                uint256 balanceBefore = token.balanceOf(address(this));
                require(token.transferFrom(_msgSender() , address(this) , amount), "I_F");
                uint256 balanceAfter = token.balanceOf(address(this));
               return (true , balanceAfter - balanceBefore);
            } else {
                return (false , 0);
            }
        }
    }

    function payoutUser(address payable recipient , address _paymentMethod , uint256 amount) private {
       require(recipient  != address(0) , "Z_A_E");
        if (_paymentMethod == address(0)) {
          recipient.transfer(amount);
        } else {
             IERC20 currentPaymentMethod = IERC20(_paymentMethod);
             require(currentPaymentMethod.transfer(recipient , amount) ,"I_F");
        }
    }


    function validPool(address poolAddress) public view returns (bool) {
        return pools[poolAddress].isSet;
    }
    function getWrappedAsset(address poolAddress) public view returns (address) {
        return pools[poolAddress].wrappedAsset;
    }
    function isOwner() internal view returns (bool) {
        require(controller.owner() == _msgSender()  , "U_A");
        return true;
    }
}