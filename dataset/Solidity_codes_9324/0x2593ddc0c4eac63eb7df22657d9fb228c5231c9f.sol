pragma solidity ^0.8.9;

contract Multiownable {



    uint256 public ownersGeneration;
    uint256 public howManyOwnersDecide;
    address[] public owners;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;

    mapping(address => uint) public ownersIndices; // Starts from 1
    mapping(bytes32 => uint) public allOperationsIndicies;

    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;


    event OwnershipTransferred(address[] previousOwners, uint howManyOwnersDecide, address[] newOwners, uint newHowManyOwnersDecide);
    event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);
    event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount,  address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);
    

    function isOwner(address wallet) public view returns(bool) {

        return ownersIndices[wallet] > 0;
    }

    function ownersCount() public view returns(uint) {

        return owners.length;
    }

    function allOperationsCount() public view returns(uint) {

        return allOperations.length;
    }


    modifier onlyAnyOwner {

        if (checkHowManyOwners(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    modifier onlyManyOwners {

        if (checkHowManyOwners(howManyOwnersDecide)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howManyOwnersDecide;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    modifier onlyAllOwners {

        if (checkHowManyOwners(owners.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = owners.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    modifier onlySomeOwners(uint howMany) {

        require(howMany > 0, "onlySomeOwners: howMany argument is zero");
        require(howMany <= owners.length, "onlySomeOwners: howMany argument exceeds the number of owners");
        
        if (checkHowManyOwners(howMany)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howMany;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }


    constructor() {
        owners.push(msg.sender);
        ownersIndices[msg.sender] = 1;
        howManyOwnersDecide = 1;
    }


    function checkHowManyOwners(uint howMany) internal returns(bool) {

        if (insideCallSender == msg.sender) {
            require(howMany <= insideCallCount, "checkHowManyOwners: nested owners modifier check require more owners");
            return true;
        }

        uint ownerIndex = ownersIndices[msg.sender] - 1;
        require(ownerIndex < owners.length, "checkHowManyOwners: msg.sender is not an owner");
        bytes32 operation = keccak256(abi.encodePacked(msg.data, ownersGeneration));

        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0, "checkHowManyOwners: owner already voted for the operation");
        votesMaskByOperation[operation] |= (2 ** ownerIndex);
        uint operationVotesCount = votesCountByOperation[operation] + 1;
        votesCountByOperation[operation] = operationVotesCount;
        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            allOperations.push(operation);
            emit OperationCreated(operation, howMany, owners.length, msg.sender);
        }
        emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);

        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, owners.length, msg.sender);
            return true;
        }

        return false;
    }

    function deleteOperation(bytes32 operation) internal {

        uint index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) { // Not last
            allOperations[index] = allOperations[allOperations.length - 1];
            allOperationsIndicies[allOperations[index]] = index;
        }
        allOperations.pop();

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
    }


    function cancelPending(bytes32 operation) public onlyAnyOwner {

        uint ownerIndex = ownersIndices[msg.sender] - 1;
        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0, "cancelPending: operation not found for this user");
        votesMaskByOperation[operation] &= ~(2 ** ownerIndex);
        uint operationVotesCount = votesCountByOperation[operation] - 1;
        votesCountByOperation[operation] = operationVotesCount;
        emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);
        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    function transferOwnership(address[] memory newOwners) public {

        transferOwnershipWithHowMany(newOwners, newOwners.length);
    }

    function transferOwnershipWithHowMany(address[] memory newOwners, uint256 newHowManyOwnersDecide) public onlyManyOwners {

        require(newOwners.length > 0, "transferOwnershipWithHowMany: owners array is empty");
        require(newOwners.length <= 256, "transferOwnershipWithHowMany: owners count is greater then 256");
        require(newHowManyOwnersDecide > 0, "transferOwnershipWithHowMany: newHowManyOwnersDecide equal to 0");
        require(newHowManyOwnersDecide <= newOwners.length, "transferOwnershipWithHowMany: newHowManyOwnersDecide exceeds the number of owners");

        for (uint j = 0; j < owners.length; j++) {
            delete ownersIndices[owners[j]];
        }
        for (uint i = 0; i < newOwners.length; i++) {
            require(newOwners[i] != address(0), "transferOwnershipWithHowMany: owners array contains zero");
            require(ownersIndices[newOwners[i]] == 0, "transferOwnershipWithHowMany: owners array contains duplicates");
            ownersIndices[newOwners[i]] = i + 1;
        }
        
        emit OwnershipTransferred(owners, howManyOwnersDecide, newOwners, newHowManyOwnersDecide);
        owners = newOwners;
        howManyOwnersDecide = newHowManyOwnersDecide;
        allOperations.push();
        ownersGeneration++;
    }

}// GPL-3.0
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

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
}

abstract contract Editor is Context {
    address private _editor;

    event EditorRoleTransferred(address indexed previousEditor, address indexed newEditor);

    constructor () {
        address msgSender = _msgSender();
        _editor = msgSender;
        emit EditorRoleTransferred(address(0), msgSender);
    }
    
    function editors() public view virtual returns (address) {
        return _editor;
    }

    modifier onlyEditor() {
        require(editors() == _msgSender(), "caller is not the editors");
        _;
    }
	
    function transferEditorRole(address newEditor) public virtual onlyEditor {
        require(newEditor != address(0), "new editor is the zero address");
        emit EditorRoleTransferred(_editor, newEditor);
        _editor = newEditor;
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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
	
    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }
	
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
	
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
	
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract CryptoCartV2 is ERC20, Ownable, Editor {
    using SafeMath for uint256;
	
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool private swapping;
	
	address public immutable vaultAddress;
	uint8 public immutable vaultFee = 200;
	
    mapping (address => bool) public _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
	
    constructor(address payable _vaultAddress) ERC20("CryptoCart V2", "CCv2") {
	    vaultAddress = _vaultAddress;
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;
		
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        excludeFromFees(address(this), true);
		excludeFromFees(owner(), true);
        _mint(owner(), 1000000 * (10**18));
    }

    receive() external payable {
  	}

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "CCv2: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
		
    function excludeFromFees(address account, bool excluded) public OwnerOrEditor{
        require(_isExcludedFromFees[account] != excluded, "CCv2: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
		
	function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
		
		if(automatedMarketMakerPairs[to])
		{
			bool takeFee = true;
			
			if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
				takeFee = false;
			}
			
			if(takeFee) 
			{
				uint256 vfees = amount.div(10000).mul(vaultFee);
				if(vfees > 0) {
				   super._transfer(from, vaultAddress, vfees);
				}
				amount = amount.sub(vfees);
			}
        }
        super._transfer(from, to, amount);
    }
	
	modifier OwnerOrEditor() {
        require(_msgSender() == owner() || _msgSender() == editors(), "caller is not the owner or editor");
        _;
    }
}// GPL-3.0
pragma solidity ^0.8.9;


contract ethBridge is Multiownable {
    CryptoCartV2 private token;

    mapping(address => uint256) public tokensSent;
    mapping(address => uint256) public tokensRecieved;
    mapping(address => uint256) public tokensRecievedButNotSent;
 
    address public tokenAddress; 
    
    constructor (address payable _token) {
        tokenAddress = _token;
        token = CryptoCartV2(_token);
    }
 
    bool transferStatus;
    
    bool avoidReentrancy = false;
 
    function sendTokens(uint256 amount) public {
        require(msg.sender != address(0), "Zero account");
        require(amount > 0,"Amount of tokens should be more then 0");
        require(token.balanceOf(msg.sender) >= amount,"Not enough balance");
        
        transferStatus = token.transferFrom(msg.sender, address(this), amount);
        if (transferStatus == true) {
            tokensRecieved[msg.sender] += amount;
        }
    }
 
    function writeTransaction(address user, uint256 amount) public onlyAllOwners {
        require(user != address(0), "Zero account");
        require(amount > 0,"Amount of tokens should be more then 0");
        require(!avoidReentrancy);
        
        avoidReentrancy = true;
        tokensRecievedButNotSent[user] += amount;
        avoidReentrancy = false;
    }

    function recieveTokens(uint256[] memory commissions) public payable {
        if (tokensRecievedButNotSent[msg.sender] != 0) {
            require(commissions.length == owners.length, "The number of commissions and owners does not match");
            uint256 sum;
            for(uint i = 0; i < commissions.length; i++) {
                sum += commissions[i];
            }
            require(msg.value >= sum, "Not enough BNB (The amount of BNB is less than the amount of commissions.)");
            require(msg.value >= owners.length * 150000 * 10**9, "Not enough BNB (The amount of BNB is less than the internal commission.)");
        
            for (uint i = 0; i < owners.length; i++) {
                address payable owner = payable(owners[i]);
                uint256 commission = commissions[i];
                owner.transfer(commission);
            }
            
            uint256 amountToSent;
            
            amountToSent = tokensRecievedButNotSent[msg.sender] - tokensSent[msg.sender];
            transferStatus = token.transfer(msg.sender, amountToSent);
            if (transferStatus == true) {
                tokensSent[msg.sender] += amountToSent;
            }
        }
    }
 
    function withdrawTokens(uint256 amount, address reciever) public onlyAllOwners {
        require(amount > 0,"Amount of tokens should be more then 0");
        require(reciever != address(0), "Zero account");
        require(token.balanceOf(address(this)) >= amount,"Not enough balance");
        
        token.transfer(reciever, amount);
    }
    
    function withdrawEther(uint256 amount, address payable reciever) public onlyAllOwners {
        require(amount > 0,"Amount of tokens should be more then 0");
        require(reciever != address(0), "Zero account");
        require(address(this).balance >= amount,"Not enough balance");

        reciever.transfer(amount);
    }
}