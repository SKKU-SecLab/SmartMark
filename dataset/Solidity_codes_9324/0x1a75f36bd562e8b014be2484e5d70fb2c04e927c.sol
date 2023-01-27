pragma solidity ^0.5.16;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity ^0.5.16;



 
 
contract PAXImplementation {



    using SafeMath for uint256;


    bool private initialized = false;

    mapping(address => uint256) internal balances;
    uint256 internal totalSupply_;
    string public constant name = "PAX"; // solium-disable-line uppercase
    string public constant symbol = "PAX"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    mapping (address => mapping (address => uint256)) internal allowed;

    address public owner;

    bool public paused = false;

    address public lawEnforcementRole;
    mapping(address => bool) internal frozen;

    address public supplyController;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    event Pause();
    event Unpause();

    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);
    event LawEnforcementRoleSet (
        address indexed oldLawEnforcementRole,
        address indexed newLawEnforcementRole
    );

    event SupplyIncreased(address indexed to, uint256 value);
    event SupplyDecreased(address indexed from, uint256 value);
    event SupplyControllerSet(
        address indexed oldSupplyController,
        address indexed newSupplyController
    );



    function initialize() public {

        require(!initialized, "already initialized");
        owner = msg.sender;
        lawEnforcementRole = address(0);
        totalSupply_ = 0;
        supplyController = msg.sender;
        initialized = true;
    }

    constructor() public {
        initialize();
        pause();
    }


    function totalSupply() public view returns (uint256) {

        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(_to != address(0), "cannot transfer to address zero");
        require(!frozen[_to] && !frozen[msg.sender], "address frozen");
        require(_value <= balances[msg.sender], "insufficient funds");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _addr) public view returns (uint256) {

        return balances[_addr];
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    whenNotPaused
    returns (bool)
    {

        require(_to != address(0), "cannot transfer to address zero");
        require(!frozen[_to] && !frozen[_from] && !frozen[msg.sender], "address frozen");
        require(_value <= balances[_from], "insufficient funds");
        require(_value <= allowed[_from][msg.sender], "insufficient allowance");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {

        require(!frozen[_spender] && !frozen[msg.sender], "address frozen");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {

        return allowed[_owner][_spender];
    }


    modifier onlyOwner() {

        require(msg.sender == owner, "onlyOwner");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), "cannot transfer ownership to address zero");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }


    modifier whenNotPaused() {

        require(!paused, "whenNotPaused");
        _;
    }

    function pause() public onlyOwner {

        require(!paused, "already paused");
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner {

        require(paused, "already unpaused");
        paused = false;
        emit Unpause();
    }


    function setLawEnforcementRole(address _newLawEnforcementRole) public {

        require(msg.sender == lawEnforcementRole || msg.sender == owner, "only lawEnforcementRole or Owner");
        emit LawEnforcementRoleSet(lawEnforcementRole, _newLawEnforcementRole);
        lawEnforcementRole = _newLawEnforcementRole;
    }

    modifier onlyLawEnforcementRole() {

        require(msg.sender == lawEnforcementRole, "onlyLawEnforcementRole");
        _;
    }

    function freeze(address _addr) public onlyLawEnforcementRole {

        require(!frozen[_addr], "address already frozen");
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    function unfreeze(address _addr) public onlyLawEnforcementRole {

        require(frozen[_addr], "address already unfrozen");
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    function wipeFrozenAddress(address _addr) public onlyLawEnforcementRole {

        require(frozen[_addr], "address is not frozen");
        uint256 _balance = balances[_addr];
        balances[_addr] = 0;
        totalSupply_ = totalSupply_.sub(_balance);
        emit FrozenAddressWiped(_addr);
        emit SupplyDecreased(_addr, _balance);
        emit Transfer(_addr, address(0), _balance);
    }

    function isFrozen(address _addr) public view returns (bool) {

        return frozen[_addr];
    }


    function setSupplyController(address _newSupplyController) public {

        require(msg.sender == supplyController || msg.sender == owner, "only SupplyController or Owner");
        require(_newSupplyController != address(0), "cannot set supply controller to address zero");
        emit SupplyControllerSet(supplyController, _newSupplyController);
        supplyController = _newSupplyController;
    }

    modifier onlySupplyController() {

        require(msg.sender == supplyController, "onlySupplyController");
        _;
    }

    function increaseSupply(uint256 _value) public onlySupplyController returns (bool success) {

        totalSupply_ = totalSupply_.add(_value);
        balances[supplyController] = balances[supplyController].add(_value);
        emit SupplyIncreased(supplyController, _value);
        emit Transfer(address(0), supplyController, _value);
        return true;
    }

    function decreaseSupply(uint256 _value) public onlySupplyController returns (bool success) {

        require(_value <= balances[supplyController], "not enough supply");
        balances[supplyController] = balances[supplyController].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit SupplyDecreased(supplyController, _value);
        emit Transfer(supplyController, address(0), _value);
        return true;
    }
}
pragma solidity ^0.5.16;


contract globalcontract {


    constructor(address paxtoken) public{
        token = PAXImplementation(paxtoken);
        deployTime = now;
        tokenAdd = paxtoken;
        mAd = msg.sender;
        sAd = msg.sender;
        veAm = 1000000000000000; 
    }
     
    insurancesub public insurance;
    using SafeMath for uint256;
    
    PAXImplementation token;
    address public tokenAdd;
    address public mAd;
    address public sAd;
    address public lastContractAddress;
    address _contractaddress;
    address _phcontractaddress;
    address public insuranceAdd;

    uint256 public deployTime;
    uint256 public totalInsuranceSubContract;
    uint256 public totalPhSubContract;
    uint256 public veAm;

    Contracts[] public contractDatabase;
    
    PHcontracts[] public phcontractDatabase;
    
    GHamounts[] public ghamountDatabase;
    
    address[] public contracts;
    address[] public phcontracts;

    mapping (string => address) public orderIDdetail;
    mapping (address => uint256) public getInsPosition;
    mapping (address => uint256) public getPhPosition;
    mapping (address => uint256) public balances;
    mapping (string => uint256) public ghOrderID;
    
    struct Contracts {
        string orderid;
        address contractadd;
        uint256 totalamount;
        address registeredUserAdd;
    }
    
    struct PHcontracts {
        string phorderid;
        address phcontractadd;
        uint256 phtotalamount;
        address phregisteredUserAdd;
    }
    
    struct GHamounts {
        string ghorderid;
        uint256 ghtotalamount;
        address ghregisteredUserAdd;
    }
    
    event ContractGenerated (
        uint256 _ID,
        string indexed _orderid, 
        address _contractadd, 
        uint256 _totalamount,
        address _userAddress
    );
    
    event PhContractGenerated (
        uint256 _phID,
        string indexed _phorderid, 
        address _phcontractadd, 
        uint256 _phtotalamount,
        address registeredUserAdd
    );
    
    event GhGenerated (
        uint256 _ghID,
        string indexed _ghorderid, 
        uint256 _ghtotalamount,
        address _ghuserAddress
    );

    event InsuranceFundUpdate(
        address indexed user, 
        uint256 insuranceAmount
    );
    
    event FundsTransfered(
        string indexed AmountType, 
        uint256 Amount
    );
    
    modifier onSad() {

        require(msg.sender == sAd, "only sAd");
        _;
    }
    
    modifier onMan() {

        require(msg.sender == mAd || msg.sender == sAd, "only mAn");
        _;
    }
    
    function adMan(address _manAd) public onSad {

        mAd = _manAd;
    
    }
    
    function remMan() public onSad {

        mAd = sAd;
    }
    
    function addInsuranceContract(address _insuranceContractAdd) public onSad{

        insuranceAdd = _insuranceContractAdd;
    }

    function () external payable {
        balances[msg.sender] += msg.value;
    }
    
    function feeC() public view returns (uint256) {

        return address(this).balance;
    }
    
    function witE() public onMan{

        msg.sender.transfer(address(this).balance);
        emit FundsTransfered("eth", address(this).balance);
    }
    
    function tokC() public view returns (uint256){

        return token.balanceOf(address(this));
    }

    function gethelp(address userAddress, uint256 tokens, string memory OrderID) public onMan {

        require(token.balanceOf(address(this)) >= tokens);
        token.transfer(userAddress, tokens);
        
        
        ghamountDatabase.push(GHamounts({
            ghorderid: OrderID,
            ghtotalamount : tokens,
            ghregisteredUserAdd : userAddress
        }));
        ghOrderID[OrderID] = ghamountDatabase.length - 1;
        emit FundsTransfered("Send GH", tokens);
    }
    

	function generateInsuranceOrder(uint256 amount, string memory OrderID, address userAddress)
		public onMan
		payable
		returns(address newContract) 
	{

	   
		insurancesub c = (new insurancesub).value(msg.value)(OrderID, tokenAdd, amount, mAd, insuranceAdd,userAddress);
		_contractaddress = address(c);
		orderIDdetail[OrderID] = _contractaddress;

		contractDatabase.push(Contracts({
            orderid: OrderID,
            contractadd: _contractaddress,
            totalamount : amount,
            registeredUserAdd : userAddress
        }));
        
        getInsPosition[_contractaddress] = contractDatabase.length - 1;
        totalInsuranceSubContract = contractDatabase.length;
		contracts.push(address(c));
		lastContractAddress = address(c);
		
        emit ContractGenerated (
            contractDatabase.length - 1, 
            OrderID,
            address(c),
            amount,
            userAddress
        );
		return address(c);
	}
	

	function generatePHorder(uint256 amount, string memory OrderID, address userAddress)
		public onMan
		payable
		returns(address newContract) 
	{

	   
		phsubcontract p = (new phsubcontract).value(msg.value)(OrderID, tokenAdd, amount, mAd, address(this) ,userAddress);
		_phcontractaddress = address(p);
		orderIDdetail[OrderID] = _phcontractaddress;

		phcontractDatabase.push(PHcontracts({
            phorderid: OrderID,
            phcontractadd: _phcontractaddress,
            phtotalamount : amount,
            phregisteredUserAdd : userAddress
        }));
        
        getPhPosition[_phcontractaddress] = phcontractDatabase.length - 1;
        totalPhSubContract = phcontractDatabase.length;
		phcontracts.push(address(p));
		lastContractAddress = address(p);
		
        emit PhContractGenerated (
            phcontractDatabase.length - 1, 
            OrderID,
            _phcontractaddress,
            amount,
            userAddress
        );
		return address(p);
	}
	
	function getInsContractCount()
		public
		view
		returns(uint InsContractCount)
	{

		return contracts.length;
	}
	
	function getPhContractCount()
		public
		view
		returns(uint phContractCount)
	{

		return phcontracts.length;
	}
	

	function upVerAm(uint256 _nAm) public onSad{

	    veAm = _nAm;
	}


    function verifyAccount(address userAdd) public view returns(bool){

        if (balances[userAdd] >= veAm){
            return true;
        }
        else{
            return false;
        }
    }
    
    function contractAddress() public view returns(address){

        return address(this);
    }
 
}



contract phsubcontract {



    constructor(string memory OrderID, address tokenAdd, uint256 amount, address mAd, address _mainAdd, address _userAddress) public payable{
      order = OrderID;
      deployTime = now;
      mainconractAdd = _mainAdd;
      contractAmount = amount;
      manAdd = mAd;
      tokenAddress = tokenAdd;
      userAdd = _userAddress;
      token = PAXImplementation(tokenAddress);
      Deployer = msg.sender;
    }
    
    address payable Deployer;
    string public order;
    address public manAdd;
    address public mainconractAdd;
    address public userAdd;
    uint256 public deployTime;
    address public tokenAddress;
    uint256 public contractAmount;
    uint256 public withdrawedToken;
    PAXImplementation token;
    
    mapping (address => uint256) public balances;
    mapping (address => uint256) public tokenBalance;

    modifier onMan() {

        require(msg.sender == manAdd, "onMan");
        _;
      }
   
    function () external payable {
        balances[msg.sender] += msg.value;
        
    }
    
    function feeC() public view returns (uint256) {

            return address(this).balance;
    }
    
    function witAl() public onMan {

        require(token.balanceOf(address(this)) >= contractAmount, 'greater b');
        withdrawedToken = token.balanceOf(address(this));
        token.transfer(mainconractAdd, token.balanceOf(address(this)));
    }
    

    function witE(uint256 amount) public onMan{

        require(address(this).balance >= amount);
        msg.sender.transfer(amount);
    }
    
    function checkAmount() public view returns(bool){

        if (token.balanceOf(address(this)) == contractAmount){
            return true;
        }
        else{
            return false;
        }
    }
    
    function checkUser(address _userAddress) public view returns(bool) {

        if(userAdd == _userAddress){
            return true;
        }
        else{
            return false;
        }
    }
    
    function tokC() public view returns (uint256){

       return token.balanceOf(address(this));
    }

   
     
}


contract insurancesub {



    constructor(string memory OrderID, address tokenAdd, uint256 amount, address mAd, address _insuranceAdd, address _userAddress) public payable{
      order = OrderID;
      deployTime = now;
      insuranceAdd = _insuranceAdd;
      contractAmount = amount;
      manAdd = mAd;
      tokenAddress = tokenAdd;
      userAdd = _userAddress;
      token = PAXImplementation(tokenAddress);
      Deployer = msg.sender;
    }
    
    address payable Deployer;
    string public order;
    address public manAdd;
    address public insuranceAdd;
    address public userAdd;
    uint256 public deployTime;
    address public tokenAddress;
    uint256 public contractAmount;
    uint256 public withdrawedToken;
    PAXImplementation token;
    
    mapping (address => uint256) public balances;
    mapping (address => uint256) public tokenBalance;

    modifier onMan() {

        require(msg.sender == manAdd, "onMan");
        _;
      }
   
    function () external payable {
        balances[msg.sender] += msg.value;
       
    }
    
    function feeC() public view returns (uint256) {

            return address(this).balance;
    }
    
    function witAl() public onMan {

        require(token.balanceOf(address(this)) >= contractAmount, 'GH');
        withdrawedToken = token.balanceOf(address(this));
        token.transfer(insuranceAdd, token.balanceOf(address(this)));
    }
    
    
    function witE(uint256 amount) public onMan{

        require(address(this).balance >= amount);
        msg.sender.transfer(amount);
    }
    
    function checkAmount() public view returns(bool){

        if (token.balanceOf(address(this)) == contractAmount){
            return true;
        }
        else{
            return false;
        }
    }
    
    function checkUser(address _userAddress) public view returns(bool) {

        if(userAdd == _userAddress){
            return true;
        }
        else{
            return false;
        }
    }
    
    function tokC() public view returns (uint256){

       return token.balanceOf(address(this));
    }
    
}