


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ParassetERC20 is Context, IERC20 {


	mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply;

    string _name;
    string _symbol;

    constructor() { }

    function name() public view override returns (string memory) {

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

pragma solidity ^0.8.4;

interface ILPStakingMiningPool {

	function getBlock(uint256 endBlock) external view returns(uint256);

	function getBalance(address stakingToken, address account) external view returns(uint256);

	function getChannelInfo(address stakingToken) external view returns(uint256 lastUpdateBlock, uint256 endBlock, uint256 rewardRate, uint256 rewardPerTokenStored, uint256 totalSupply);

	function getAccountReward(address stakingToken, address account) external view returns(uint256);

	function stake(uint256 amount, address stakingToken) external;

	function withdraw(uint256 amount, address stakingToken) external;

	function getReward(address stakingToken) external;

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

interface IInsurancePool {

    
    function destroyPToken(uint256 amount) external;


    function eliminate() external;

}

pragma solidity ^0.8.4;

contract InsurancePool is ParassetBase, IInsurancePool, ParassetERC20 {


    uint256 public _insNegative;
    uint256 public _latestTime;
    uint8 public _flag;      // = 0: pause
    mapping(address => Frozen) _frozenIns;
    struct Frozen {
        uint256 amount;
        uint256 time;                       
    }
    address public _pTokenAddress;
	uint96 public _redemptionCycle;
    address public _underlyingTokenAddress;
	uint96 public _waitCycle;
    address public _mortgagePool;
    uint96 public _feeRate;

    uint constant MINIMUM_LIQUIDITY = 1e9; 

    ILPStakingMiningPool _lpStakingMiningPool;

    event SubNegative(uint256 amount, uint256 allValue);
    event AddNegative(uint256 amount, uint256 allValue);

    function initialize(address governance) public override {

        super.initialize(governance);
        _redemptionCycle = 15 minutes;
        _waitCycle = 30 minutes;
        _feeRate = 2;
        _totalSupply = 0;
    }


    modifier onlyMortgagePool() {

        require(msg.sender == address(_mortgagePool), "Log:InsurancePool:!mortgagePool");
        _;
    }

    modifier whenActive() {

        require(_flag == 1, "Log:InsurancePool:!active");
        _;
    }

    modifier redemptionOnly() {

        require(_flag != 0, "Log:InsurancePool:!0");
        _;
    }


    function getLPStakingMiningPool() external view returns(address) {

        return address(_lpStakingMiningPool);
    }

    function getAllLP(address user) public view returns(uint256) {

        return _balances[user] + _lpStakingMiningPool.getBalance(address(this), user);
    }

    function getRedemptionTime() external view returns(uint256 startTime, uint256 endTime) {

        uint256 time = _latestTime;
        if (block.timestamp > time) {
            uint256 subTime = (block.timestamp - time) / uint256(_waitCycle);
            endTime = time + (uint256(_waitCycle) * (1 + subTime));
        } else {
            endTime = time;
        }
        startTime = endTime - uint256(_redemptionCycle);
    }

    function getFrozenIns(address add) external view returns(uint256, uint256) {

        Frozen memory frozenInfo = _frozenIns[add];
        return (frozenInfo.amount, frozenInfo.time);
    }

    function getFrozenInsInTime(address add) external view returns(uint256) {

        Frozen memory frozenInfo = _frozenIns[add];
        if (block.timestamp > frozenInfo.time) {
            return 0;
        }
        return frozenInfo.amount;
    }

    function getRedemptionAmount(address add) external view returns (uint256) {

        Frozen memory frozenInfo = _frozenIns[add];
        uint256 balanceSelf = _balances[add];
        if (block.timestamp > frozenInfo.time) {
            return balanceSelf;
        } else {
            return balanceSelf - frozenInfo.amount;
        }
    }


    function setTokenInfo(string memory name, string memory symbol) external onlyGovernance {

        _name = name;
        _symbol = symbol;
    }

    function setFlag(uint8 num) external onlyGovernance {

        _flag = num;
    }

    function setMortgagePool(address add) external onlyGovernance {

    	_mortgagePool = add;
    }

    function setLPStakingMiningPool(address add) external onlyGovernance {

        _lpStakingMiningPool = ILPStakingMiningPool(add);
    }

    function setLatestTime(uint256 num) external onlyGovernance {

        _latestTime = num;
    }

    function setFeeRate(uint96 num) external onlyGovernance {

        _feeRate = num;
    }

    function setRedemptionCycle(uint256 num) external onlyGovernance {

        require(num > 0, "Log:InsurancePool:!zero");
        _redemptionCycle = uint96(num * 1 days);
    }

    function setWaitCycle(uint256 num) external onlyGovernance {

        require(num > 0, "Log:InsurancePool:!zero");
        _waitCycle = uint96(num * 1 days);
    }

    function setInfo(address uToken, address pToken) external onlyGovernance {

        _underlyingTokenAddress = uToken;
        _pTokenAddress = pToken;
    }

    function test_insNegative(uint256 amount) external onlyGovernance {

        _insNegative = amount;
    }


    function exchangePTokenToUnderlying(uint256 amount) public redemptionOnly nonReentrant {

        require(amount > 0, "Log:InsurancePool:!amount");

    	uint256 fee = amount * _feeRate / 1000;

        address pTokenAddress = _pTokenAddress;
        TransferHelper.safeTransferFrom(pTokenAddress, msg.sender, address(this), amount);

        uint256 uTokenAmount = getDecimalConversion(pTokenAddress, amount - fee, _underlyingTokenAddress);
        require(uTokenAmount > 0, "Log:InsurancePool:!uTokenAmount");

    	if (_underlyingTokenAddress == address(0x0)) {
            TransferHelper.safeTransferETH(msg.sender, uTokenAmount);
    	} else {
            TransferHelper.safeTransfer(_underlyingTokenAddress, msg.sender, uTokenAmount);
    	}

        eliminate();
    }

    function exchangeUnderlyingToPToken(uint256 amount) public payable redemptionOnly nonReentrant {

        require(amount > 0, "Log:InsurancePool:!amount");

    	uint256 fee = amount * _feeRate / 1000;

    	if (_underlyingTokenAddress == address(0x0)) {
            require(msg.value == amount, "Log:InsurancePool:!msg.value");
    	} else {
            require(msg.value == 0, "Log:InsurancePool:msg.value!=0");
            TransferHelper.safeTransferFrom(_underlyingTokenAddress, msg.sender, address(this), amount);
    	}

        uint256 pTokenAmount = getDecimalConversion(_underlyingTokenAddress, amount - fee, address(0x0));
        require(pTokenAmount > 0, "Log:InsurancePool:!pTokenAmount");

        address pTokenAddress = _pTokenAddress;
        uint256 pTokenBalance = IERC20(pTokenAddress).balanceOf(address(this));
        if (pTokenBalance < pTokenAmount) {
            uint256 subNum = pTokenAmount - pTokenBalance;
            _issuancePToken(subNum);
        }
        TransferHelper.safeTransfer(pTokenAddress, msg.sender, pTokenAmount);
    }

    function subscribeIns(uint256 amount) public payable whenActive nonReentrant {

        require(amount > 0, "Log:InsurancePool:!amount");

    	updateLatestTime();

    	Frozen storage frozenInfo = _frozenIns[msg.sender];
    	if (block.timestamp > frozenInfo.time) {
    		frozenInfo.amount = 0;
    	}

    	uint256 pTokenBalance = IERC20(_pTokenAddress).balanceOf(address(this));
        uint256 tokenBalance;
    	if (_underlyingTokenAddress == address(0x0)) {
            require(msg.value == amount, "Log:InsurancePool:!msg.value");
            tokenBalance = address(this).balance - amount;
    	} else {
            require(msg.value == 0, "Log:InsurancePool:msg.value!=0");
            tokenBalance = getDecimalConversion(_underlyingTokenAddress, IERC20(_underlyingTokenAddress).balanceOf(address(this)), address(0x0));
    	}

    	uint256 insAmount = 0;
    	uint256 insTotal = _totalSupply;
        uint256 allBalance = tokenBalance + pTokenBalance;
    	if (insTotal != 0) {
            require(allBalance > _insNegative, "Log:InsurancePool:allBalanceNotEnough");
            uint256 allValue = allBalance - _insNegative;
    		insAmount = getDecimalConversion(_underlyingTokenAddress, amount, address(0x0)) * insTotal / allValue;
    	} else {
            insAmount = getDecimalConversion(_underlyingTokenAddress, amount, address(0x0)) - MINIMUM_LIQUIDITY;
            _issuance(MINIMUM_LIQUIDITY, address(0x0));
        }

    	if (_underlyingTokenAddress != address(0x0)) {
    		require(msg.value == 0, "Log:InsurancePool:msg.value!=0");
            TransferHelper.safeTransferFrom(_underlyingTokenAddress, msg.sender, address(this), amount);
    	}

    	_issuance(insAmount, msg.sender);

    	frozenInfo.amount = frozenInfo.amount + insAmount;
    	frozenInfo.time = _latestTime;
    }

    function redemptionIns(uint256 amount) public redemptionOnly nonReentrant {

        require(amount > 0, "Log:InsurancePool:!amount");

    	updateLatestTime();

        uint256 tokenTime = _latestTime;
    	require(block.timestamp < tokenTime && block.timestamp > tokenTime - uint256(_redemptionCycle), "Log:InsurancePool:!time");

    	Frozen storage frozenInfo = _frozenIns[msg.sender];
    	if (block.timestamp > frozenInfo.time) {
    		frozenInfo.amount = 0;
    	}
    	
    	uint256 pTokenBalance = IERC20(_pTokenAddress).balanceOf(address(this));
        uint256 tokenBalance;
    	if (_underlyingTokenAddress == address(0x0)) {
            tokenBalance = address(this).balance;
    	} else {
    		tokenBalance = getDecimalConversion(_underlyingTokenAddress, IERC20(_underlyingTokenAddress).balanceOf(address(this)), address(0x0));
    	}

        uint256 allBalance = tokenBalance + pTokenBalance;
        require(allBalance > _insNegative, "Log:InsurancePool:allBalanceNotEnough");
    	uint256 allValue = allBalance - _insNegative;
    	uint256 insTotal = _totalSupply;
    	uint256 underlyingAmount = amount * allValue / insTotal;

        _destroy(amount, msg.sender);
        require(getAllLP(msg.sender) >= frozenInfo.amount, "Log:InsurancePool:frozen");
    	
    	if (_underlyingTokenAddress == address(0x0)) {
            if (tokenBalance >= underlyingAmount) {
                TransferHelper.safeTransferETH(msg.sender, underlyingAmount);
            } else {
                TransferHelper.safeTransferETH(msg.sender, tokenBalance);
                TransferHelper.safeTransfer(_pTokenAddress, msg.sender, underlyingAmount - tokenBalance);
            }
    	} else {
            if (tokenBalance >= underlyingAmount) {
                TransferHelper.safeTransfer(_underlyingTokenAddress, msg.sender, getDecimalConversion(_pTokenAddress, underlyingAmount, _underlyingTokenAddress));
            } else {
                TransferHelper.safeTransfer(_underlyingTokenAddress, msg.sender, getDecimalConversion(_pTokenAddress, tokenBalance, _underlyingTokenAddress));
                TransferHelper.safeTransfer(_pTokenAddress, msg.sender, underlyingAmount - tokenBalance);
            }
    	}
    }

    function destroyPToken(uint256 amount) public override onlyMortgagePool {

        _insNegative = _insNegative + amount;
        emit AddNegative(amount, _insNegative);

        eliminate();
    }

    function _issuancePToken(uint256 amount) private {

        IParasset(_pTokenAddress).issuance(amount, address(this));
        _insNegative = _insNegative + amount;
        emit AddNegative(amount, _insNegative);
    }

    function eliminate() override public {

    	IParasset pErc20 = IParasset(_pTokenAddress);
    	uint256 negative = _insNegative;
    	uint256 pTokenBalance = pErc20.balanceOf(address(this)); 
    	if (negative > 0 && pTokenBalance > 0) {
    		if (negative >= pTokenBalance) {
                pErc20.destroy(pTokenBalance, address(this));
    			_insNegative = _insNegative - pTokenBalance;
                emit SubNegative(pTokenBalance, _insNegative);
    		} else {
                pErc20.destroy(negative, address(this));
    			_insNegative = 0;
                emit SubNegative(negative, _insNegative);
    		}
    	}
    }

    function updateLatestTime() public {

        uint256 time = _latestTime;
    	if (block.timestamp > time) {
    		uint256 subTime = (block.timestamp - time) / uint256(_waitCycle);
    		_latestTime = time + (uint256(_waitCycle) * (1 + subTime));
    	}
    }

    function _destroy(
        uint256 amount, 
        address account
    ) private {

        require(_balances[account] >= amount, "Log:InsurancePool:!destroy");
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0x0), amount);
    }

    function _issuance(
        uint256 amount, 
        address account
    ) private {

        _balances[account] = _balances[account] + amount;
        _totalSupply = _totalSupply + amount;
        emit Transfer(address(0x0), account, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {

        updateLatestTime();

        Frozen storage frozenInfo = _frozenIns[sender];
        if (block.timestamp > frozenInfo.time) {
            frozenInfo.amount = 0;
        }

        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        if (recipient != address(_lpStakingMiningPool)) {
            require(getAllLP(sender) >= frozenInfo.amount, "Log:InsurancePool:frozen");
        }
    }

    function addETH() external payable {}


}