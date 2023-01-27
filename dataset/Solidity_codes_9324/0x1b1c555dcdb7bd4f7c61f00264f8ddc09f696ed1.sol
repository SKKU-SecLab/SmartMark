



pragma solidity ^0.8.4;

interface IERC20 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


pragma solidity ^0.8.4;

interface IParassetGovernance {

    function setGovernance(address addr, uint flag) external;


    function getGovernance(address addr) external view returns (uint);


    function checkGovernance(address addr, uint flag) external view returns (bool);

}

pragma solidity ^0.8.4;

contract ParassetBase {


    uint256 _locked;

    function initialize(address governance) public virtual {

        require(_governance == address(0), "Log:ParassetBase!initialize");
        _governance = governance;
        _locked = 0;
    }

    address public _governance;

    function update(address newGovernance) public virtual {


        address governance = _governance;
        require(governance == msg.sender || IParassetGovernance(governance).checkGovernance(msg.sender, 0), "Log:ParassetBase:!gov");
        _governance = newGovernance;
    }

    function getDecimalConversion(
        address inputToken, 
        uint256 inputTokenAmount, 
        address outputToken
    ) public view returns(uint256) {

    	uint256 inputTokenDec = 18;
    	uint256 outputTokenDec = 18;
    	if (inputToken != address(0x0)) {
    		inputTokenDec = IERC20(inputToken).decimals();
    	}
    	if (outputToken != address(0x0)) {
    		outputTokenDec = IERC20(outputToken).decimals();
    	}
    	return inputTokenAmount * (10**outputTokenDec) / (10**inputTokenDec);
    }


    modifier onlyGovernance() {

        require(IParassetGovernance(_governance).checkGovernance(msg.sender, 0), "Log:ParassetBase:!gov");
        _;
    }

    modifier nonReentrant() {

        require(_locked == 0, "Log:ParassetBase:!_locked");
        _locked = 1;
        _;
        _locked = 0;
    }
}

pragma solidity ^0.8.4;

interface IPTokenFactory {

    function getGovernance() external view returns(address);


    function getPTokenOperator(address contractAddress) external view returns(bool);


    function getPTokenAuthenticity(address pToken) external view returns(bool);

    function getPTokenAddress(uint256 index) external view returns(address);

}

pragma solidity ^0.8.4;

interface IParasset {

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function destroy(uint256 amount, address account) external;

    function issuance(uint256 amount, address account) external;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.4;

contract PToken is IParasset {


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 public _totalSupply = 0;                                        
    string public name = "";
    string public symbol = "";
    uint8 public decimals = 18;

    IPTokenFactory pTokenFactory;

    constructor (string memory _name, 
                 string memory _symbol) public {
    	name = _name;                                                               
    	symbol = _symbol;
    	pTokenFactory = IPTokenFactory(address(msg.sender));
    }


    modifier onlyGovernance() {

        require(address(msg.sender) == pTokenFactory.getGovernance(), "Log:PToken:!governance");
        _;
    }

    modifier onlyPool() {

    	require(pTokenFactory.getPTokenOperator(address(msg.sender)), "Log:PToken:!Pool");
    	_;
    }


    function getPTokenFactory() public view returns(address) {

        return address(pTokenFactory);
    }

    function totalSupply() override public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) override public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) override public view returns (uint256) {

        return _allowed[owner][spender];
    }


    function changeFactory(address factory) public onlyGovernance {

        pTokenFactory = IPTokenFactory(address(factory));
    }

    function rename(string memory _name, 
                    string memory _symbol) public onlyGovernance {

        name = _name;                                                               
        symbol = _symbol;
    }

    function transfer(address to, uint256 value) override public returns (bool) 
    {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) override public returns (bool) 
    {

        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool) 
    {

        _allowed[from][msg.sender] = _allowed[from][msg.sender] - value;
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender] + addedValue;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender] - subtractedValue;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;
        emit Transfer(from, to, value);
    }

    function destroy(uint256 amount, address account) override external onlyPool{

    	require(_balances[account] >= amount, "Log:PToken:!destroy");
    	_balances[account] = _balances[account] - amount;
    	_totalSupply = _totalSupply - amount;
    	emit Transfer(account, address(0x0), amount);
    }

    function issuance(uint256 amount, address account) override external onlyPool{

    	_balances[account] = _balances[account] + amount;
    	_totalSupply = _totalSupply + amount;
    	emit Transfer(address(0x0), account, amount);
    }
}

pragma solidity ^0.8.4;

contract PTokenFactory is ParassetBase, IPTokenFactory {


    address public _owner;
	mapping(address=>bool) _allowAddress;
	mapping(address=>bool) _pTokenMapping;
    address[] public _pTokenList;

    event createLog(address pTokenAddress);
    event pTokenOperator(address contractAddress, bool allow);


    function strSplicing(string memory _a, string memory _b) public pure returns (string memory){

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint s = 0;
        for (uint i = 0; i < _ba.length; i++) {
            bret[s++] = _ba[i];
        } 
        for (uint i = 0; i < _bb.length; i++) {
            bret[s++] = _bb[i];
        } 
        return string(ret);
    }

    function getGovernance() external override view returns(address) {

        return _owner;
    }

    function getPTokenOperator(address contractAddress) external override view returns(bool) {

    	return _allowAddress[contractAddress];
    }

    function getPTokenAuthenticity(address pToken) external override view returns(bool) {

    	return _pTokenMapping[pToken];
    }

    function getPTokenAddress(uint256 index) external override view returns(address) {

        return _pTokenList[index];
    }


    function setOwner(address add) external onlyGovernance {

    	_owner = add;
    }

    function setPTokenOperator(address contractAddress, 
                               bool allow) external onlyGovernance {

        _allowAddress[contractAddress] = allow;
        emit pTokenOperator(contractAddress, allow);
    }

    function addPTokenList(address add) external onlyGovernance {

        _pTokenList.push(add);
    }

    function setPTokenMapping(address add, bool isTrue) external onlyGovernance {

        _pTokenMapping[add] = isTrue;
    }

    function createPToken(string memory name) external onlyGovernance {

    	PToken pToken = new PToken(strSplicing("PToken_", name), strSplicing("P", name));
    	_pTokenMapping[address(pToken)] = true;
        _pTokenList.push(address(pToken));
    	emit createLog(address(pToken));
    }
}