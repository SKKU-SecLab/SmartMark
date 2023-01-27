



library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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





abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




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




contract UpgradableProduct {

    address public impl;

    event ImplChanged(address indexed _oldImpl, address indexed _newImpl);

    constructor() public {
        impl = msg.sender;
    }

    modifier requireImpl() {

        require(msg.sender == impl, "FORBIDDEN");
        _;
    }

    function upgradeImpl(address _newImpl) public requireImpl {

        require(_newImpl != address(0), "INVALID_ADDRESS");
        require(_newImpl != impl, "NO_CHANGE");
        address lastImpl = impl;
        impl = _newImpl;
        emit ImplChanged(lastImpl, _newImpl);
    }
}

contract UpgradableGovernance {

    address public governor;

    event GovernorChanged(
        address indexed _oldGovernor,
        address indexed _newGovernor
    );

    constructor() public {
        governor = msg.sender;
    }

    modifier requireGovernor() {

        require(msg.sender == governor, "FORBIDDEN");
        _;
    }

    function upgradeGovernance(address _newGovernor) public requireGovernor {

        require(_newGovernor != address(0), "INVALID_ADDRESS");
        require(_newGovernor != governor, "NO_CHANGE");
        address lastGovernor = governor;
        governor = _newGovernor;
        emit GovernorChanged(lastGovernor, _newGovernor);
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

    constructor (string memory name_, string memory symbol_) public {
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma experimental ABIEncoderV2;


contract Convert {
	using SafeMath for uint256;

	function convertTokenAmount(
		address _fromToken,
		address _toToken,
		uint256 _fromAmount
	) public view returns (uint256 toAmount) {
		uint256 fromDecimals = uint256(ERC20(_fromToken).decimals());
		uint256 toDecimals = uint256(ERC20(_toToken).decimals());
		if (fromDecimals > toDecimals) {
			toAmount = _fromAmount.div(10**(fromDecimals.sub(toDecimals)));
		} else if (toDecimals > fromDecimals) {
			toAmount = _fromAmount.mul(10**(toDecimals.sub(fromDecimals)));
		} else {
			toAmount = _fromAmount;
		}
		return toAmount;
	}
}




interface IERC20Burnable {
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}




interface IDetailedERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}



pragma solidity >=0.6.5 <0.8.0;



contract Oven is ReentrancyGuard, UpgradableProduct, Convert {
	using SafeMath for uint256;
	using TransferHelper for address;
	using Address for address;

	address public constant ZERO_ADDRESS = address(0);
	uint256 public EXCHANGE_PERIOD;

	address public friesToken;
	address public token;

	mapping(address => uint256) public depositedFriesTokens;
	mapping(address => uint256) public tokensInBucket;
	mapping(address => uint256) public realisedTokens;
	mapping(address => uint256) public lastDividendPoints;

	mapping(address => bool) public userIsKnown;
	mapping(uint256 => address) public userList;
	uint256 public nextUser;

	uint256 public totalSupplyFriesTokens;
	uint256 public buffer;
	uint256 public lastDepositBlock;

	uint256 public pointMultiplier = 10**18;

	uint256 public totalDividendPoints;
	uint256 public unclaimedDividends;

	address public upgradeAddress;
	uint256 public upgradeTime;
	uint256 public upgradeAmount;

	mapping(address => bool) public whiteList;

	event UpgradeSettingUpdate(address upgradeAddress, uint256 upgradeTime, uint256 upgradeAmount);
	event Upgrade(address upgradeAddress, uint256 upgradeAmount);
	event ExchangerPeriodUpdated(uint256 newTransmutationPeriod);

	constructor(address _friesToken, address _token) public {
		friesToken = _friesToken;
		token = _token;
		EXCHANGE_PERIOD = 50;
	}

	function dividendsOwing(address account) public view returns (uint256) {
		uint256 newDividendPoints = totalDividendPoints.sub(lastDividendPoints[account]);
		return depositedFriesTokens[account].mul(newDividendPoints).div(pointMultiplier);
	}

	modifier updateAccount(address account) {
		uint256 owing = dividendsOwing(account);
		if (owing > 0) {
			unclaimedDividends = unclaimedDividends.sub(owing);
			tokensInBucket[account] = tokensInBucket[account].add(owing);
		}
		lastDividendPoints[account] = totalDividendPoints;
		_;
	}
	modifier checkIfNewUser() {
		if (!userIsKnown[msg.sender]) {
			userList[nextUser] = msg.sender;
			userIsKnown[msg.sender] = true;
			nextUser++;
		}
		_;
	}

	modifier runPhasedDistribution() {
		uint256 _lastDepositBlock = lastDepositBlock;
		uint256 _currentBlock = block.number;
		uint256 _toDistribute = 0;
		uint256 _buffer = buffer;

		if (_buffer > 0) {

			uint256 deltaTime = _currentBlock.sub(_lastDepositBlock);

			if (deltaTime >= EXCHANGE_PERIOD) {
				_toDistribute = _buffer;
			} else {
				if (_buffer.mul(deltaTime) > EXCHANGE_PERIOD) {
					_toDistribute = _buffer.mul(deltaTime).div(EXCHANGE_PERIOD);
				}
			}

			if (_toDistribute > 0) {
				buffer = _buffer.sub(_toDistribute);

				increaseAllocations(_toDistribute);
			}
		}

		lastDepositBlock = _currentBlock;
		_;
	}

	modifier onlyWhitelisted() {
		require(whiteList[msg.sender], '!whitelisted');
		_;
	}

	function setExchangePeriod(uint256 newExchangePeriod) public requireImpl {
		EXCHANGE_PERIOD = newExchangePeriod;
		emit ExchangerPeriodUpdated(EXCHANGE_PERIOD);
	}

	function claim() public nonReentrant {
		address sender = msg.sender;
		require(realisedTokens[sender] > 0);
		uint256 value = realisedTokens[sender];
		realisedTokens[sender] = 0;
		token.safeTransfer(sender, value);
	}

	function unstake(uint256 amount) public nonReentrant runPhasedDistribution() updateAccount(msg.sender) {
		address sender = msg.sender;

		uint256 tokenAmount = convertTokenAmount(friesToken, token, amount);
		amount = convertTokenAmount(token, friesToken, tokenAmount);
		require(tokenAmount > 0, 'The amount is too small');

		require(depositedFriesTokens[sender] >= amount, 'unstake amount exceeds deposited amount');
		depositedFriesTokens[sender] = depositedFriesTokens[sender].sub(amount);
		totalSupplyFriesTokens = totalSupplyFriesTokens.sub(amount);
		friesToken.safeTransfer(sender, amount);
	}

	function stake(uint256 amount)
		public
		nonReentrant
		runPhasedDistribution()
		updateAccount(msg.sender)
		checkIfNewUser()
	{
		uint256 tokenAmount = convertTokenAmount(friesToken, token, amount);
		amount = convertTokenAmount(token, friesToken, tokenAmount);
		require(tokenAmount > 0, 'The amount is too small');

		address sender = msg.sender;
		friesToken.safeTransferFrom(sender, address(this), amount);
		totalSupplyFriesTokens = totalSupplyFriesTokens.add(amount);
		depositedFriesTokens[sender] = depositedFriesTokens[sender].add(amount);
	}

	function exchange() public nonReentrant runPhasedDistribution() updateAccount(msg.sender) {
		address sender = msg.sender;
		uint256 pendingz = tokensInBucket[sender]; //
		uint256 pendingzToFries = convertTokenAmount(token, friesToken, pendingz); // fries
		uint256 diff; // token

		require(pendingz > 0 && pendingzToFries > 0, 'need to have pending in bucket');

		tokensInBucket[sender] = 0;

		if (pendingzToFries > depositedFriesTokens[sender]) {
			diff = convertTokenAmount(friesToken, token, pendingzToFries.sub(depositedFriesTokens[sender]));
			pendingzToFries = depositedFriesTokens[sender];
			pendingz = convertTokenAmount(friesToken, token, pendingzToFries);
			require(pendingz > 0 && pendingzToFries > 0, 'need to have pending in bucket');
		}

		depositedFriesTokens[sender] = depositedFriesTokens[sender].sub(pendingzToFries);

		IERC20Burnable(friesToken).burn(pendingzToFries);

		totalSupplyFriesTokens = totalSupplyFriesTokens.sub(pendingzToFries);

		increaseAllocations(diff);

		realisedTokens[sender] = realisedTokens[sender].add(pendingz);
	}

	function forceExchange(address toExchange)
		public
		nonReentrant
		runPhasedDistribution()
		updateAccount(msg.sender)
		updateAccount(toExchange)
	{
		address sender = msg.sender;
		uint256 pendingz = tokensInBucket[toExchange];
		uint256 pendingzToFries = convertTokenAmount(token, friesToken, pendingz);
		require(pendingzToFries > depositedFriesTokens[toExchange], '!overflow');

		tokensInBucket[toExchange] = 0;

		address _toExchange = toExchange;

		uint256 diff = convertTokenAmount(friesToken, token, pendingzToFries.sub(depositedFriesTokens[_toExchange]));

		pendingzToFries = depositedFriesTokens[_toExchange];

		depositedFriesTokens[_toExchange] = 0;

		IERC20Burnable(friesToken).burn(pendingzToFries);

		totalSupplyFriesTokens = totalSupplyFriesTokens.sub(pendingzToFries);

		tokensInBucket[sender] = tokensInBucket[sender].add(diff);

		uint256 payout = convertTokenAmount(friesToken, token, pendingzToFries);

		realisedTokens[_toExchange] = realisedTokens[_toExchange].add(payout);

		if (realisedTokens[_toExchange] > 0) {
			uint256 value = realisedTokens[_toExchange];
			realisedTokens[_toExchange] = 0;
			token.safeTransfer(_toExchange, value);
		}
	}

	function exit() public {
		exchange();
		uint256 toWithdraw = depositedFriesTokens[msg.sender];
		unstake(toWithdraw);
	}

	function exchangeAndClaim() public {
		exchange();
		claim();
	}

	function exchangeClaimAndWithdraw() public {
		exchange();
		claim();
		uint256 toWithdraw = depositedFriesTokens[msg.sender];
		unstake(toWithdraw);
	}

	function distribute(address origin, uint256 amount) public onlyWhitelisted runPhasedDistribution {
		token.safeTransferFrom(origin, address(this), amount);
		buffer = buffer.add(amount);
	}

	function increaseAllocations(uint256 amount) internal {
		if (totalSupplyFriesTokens > 0 && amount > 0) {
			totalDividendPoints = totalDividendPoints.add(amount.mul(pointMultiplier).div(totalSupplyFriesTokens));
			unclaimedDividends = unclaimedDividends.add(amount);
		} else {
			buffer = buffer.add(amount);
		}
	}


	function userInfo(address user)
		public
		view
		returns (
			uint256 depositedToken,
			uint256 pendingdivs,
			uint256 inbucket,
			uint256 realised
		)
	{
		uint256 _depositedToken = depositedFriesTokens[user];
		uint256 _toDistribute = buffer.mul(block.number.sub(lastDepositBlock)).div(EXCHANGE_PERIOD);
		if (block.number.sub(lastDepositBlock) > EXCHANGE_PERIOD) {
			_toDistribute = buffer;
		}
		uint256 _pendingdivs = 0;

		if (totalSupplyFriesTokens > 0) {
			_pendingdivs = _toDistribute.mul(depositedFriesTokens[user]).div(totalSupplyFriesTokens);
		}
		uint256 _inbucket = tokensInBucket[user].add(dividendsOwing(user));
		uint256 _realised = realisedTokens[user];
		return (_depositedToken, _pendingdivs, _inbucket, _realised);
	}

	function getMultipleUserInfo(uint256 from, uint256 to)
		public
		view
		returns (address[] memory theUserList, uint256[] memory theUserData)
	{
		uint256 i = from;
		uint256 delta = to - from;
		address[] memory _theUserList = new address[](delta); //user
		uint256[] memory _theUserData = new uint256[](delta * 2); //deposited-bucket
		uint256 y = 0;
		uint256 _toDistribute = buffer.mul(block.number.sub(lastDepositBlock)).div(EXCHANGE_PERIOD);
		if (block.number.sub(lastDepositBlock) > EXCHANGE_PERIOD) {
			_toDistribute = buffer;
		}
		for (uint256 x = 0; x < delta; x += 1) {
			_theUserList[x] = userList[i];
			_theUserData[y] = depositedFriesTokens[userList[i]];

			uint256 pending = 0;
			if (totalSupplyFriesTokens > 0) {
				pending = _toDistribute.mul(depositedFriesTokens[userList[i]]).div(totalSupplyFriesTokens);
			}

			_theUserData[y + 1] = dividendsOwing(userList[i]).add(tokensInBucket[userList[i]]).add(pending);
			y += 2;
			i += 1;
		}
		return (_theUserList, _theUserData);
	}

	function bufferInfo()
		public
		view
		returns (
			uint256 _toDistribute,
			uint256 _deltaBlocks,
			uint256 _buffer
		)
	{
		_deltaBlocks = block.number.sub(lastDepositBlock);
		_buffer = buffer;
		_toDistribute = _buffer.mul(_deltaBlocks).div(EXCHANGE_PERIOD);
	}

	function setWhitelist(address _toWhitelist, bool _state) external requireImpl {
		whiteList[_toWhitelist] = _state;
	}

	function upgradeSetting(
		address _upgradeAddress,
		uint256 _upgradeTime,
		uint256 _upgradeAmount
	) external requireImpl {
		require(_upgradeAddress != address(0) && _upgradeAddress != address(this), '!upgradeAddress');
		require(_upgradeTime > block.timestamp, '!upgradeTime');
		require(_upgradeAmount > 0, '!upgradeAmount');

		upgradeAddress = _upgradeAddress;
		upgradeTime = _upgradeTime;
		upgradeAmount = _upgradeAmount;
		emit UpgradeSettingUpdate(upgradeAddress, upgradeTime, upgradeAmount);
	}

	function upgrade() external requireImpl {
		require(
			upgradeAddress != address(0) && upgradeAmount > 0 && block.timestamp > upgradeTime && upgradeTime > 0,
			'!upgrade'
		);
		token.safeApprove(upgradeAddress, upgradeAmount);
		Oven(upgradeAddress).distribute(address(this), upgradeAmount);
		upgradeAddress = address(0);
		upgradeAmount = 0;
		upgradeTime = 0;
		emit Upgrade(upgradeAddress, upgradeAmount);
	}
}