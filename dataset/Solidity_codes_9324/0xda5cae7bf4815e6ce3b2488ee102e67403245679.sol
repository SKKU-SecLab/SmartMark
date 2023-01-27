
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
}
pragma solidity 0.8.10;


interface IDEXRouter {

	function factory() external pure returns (address);


	function WETH() external pure returns (address);


	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);


	function addLiquidityETH(
		address token,
		uint amountTokenDesired,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);


	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint liquidity,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB);


	function removeLiquidityETH(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountToken, uint amountETH);


	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint liquidity,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountA, uint amountB);


	function removeLiquidityETHWithPermit(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountToken, uint amountETH);


	function swapExactTokensForTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);


	function swapTokensForExactTokens(
		uint amountOut,
		uint amountInMax,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);


	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
	external
	payable
	returns (uint[] memory amounts);


	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
	external
	returns (uint[] memory amounts);


	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
	external
	returns (uint[] memory amounts);


	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
	external
	payable
	returns (uint[] memory amounts);


	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);


	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);


	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);


	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);


	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountETH);


	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountETH);


	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;


	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable;


	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;

}pragma solidity 0.8.10;


interface IDEXFactory {

	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function feeTo() external view returns (address);


	function feeToSetter() external view returns (address);


	function getPair(address tokenA, address tokenB) external view returns (address pair);


	function allPairs(uint) external view returns (address pair);


	function allPairsLength() external view returns (uint);


	function createPair(address tokenA, address tokenB) external returns (address pair);


	function setFeeTo(address) external;


	function setFeeToSetter(address) external;

}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

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
}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
pragma solidity 0.8.10;



contract BuybackTreasury is AccessControl {

	uint256 constant MAX_UINT = 2 ^ 256 - 1;
	address constant DEAD_ADDRESS = address(57005);
	IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

	IDEXRouter router;
	IERC20 token;

	uint256 public totalEthDeposited;
	uint256 public totalEthBoughtBack;
	uint256 public totalValueBoughtBack;

	event Deposit(uint256 amount);
	event Buyback(uint256 amount, uint256 value);

	constructor(address routerAddress, address tokenAddress, address ownerAddress) {
		router = IDEXRouter(routerAddress);
		token = IERC20(tokenAddress);

		_grantRole(DEFAULT_ADMIN_ROLE, address(token));
		_grantRole(DEFAULT_ADMIN_ROLE, ownerAddress);
	}

	function _getValueOfEthAmount(uint256 amount) private view returns (uint256) {

		address[] memory path = new address[](2);
		path[0] = router.WETH();
		path[1] = address(USDT);

		return router.getAmountsOut(amount, path)[1];
	}

	function _approveRouter(uint256 amount) private {

		require(token.approve(address(router), amount), "Router approval failed");
	}

	function _buy(uint256 amountIn) private returns (uint256) {

		address[] memory path = new address[](2);
		path[0] = router.WETH();
		path[1] = address(token);

		uint256 previousBalance = token.balanceOf(address(this));

		_approveRouter(amountIn);
		router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : amountIn}(0, path, address(this), block.timestamp);

		return token.balanceOf(address(this)) - previousBalance;
	}

	function _addLiquidity(uint256 amountIn) private {

		uint256 ethForLiquidity = amountIn / 2;
		uint256 tokensForLiquidity = _buy(amountIn - ethForLiquidity);

		_approveRouter(tokensForLiquidity);
		router.addLiquidityETH{value : ethForLiquidity}(address(token), tokensForLiquidity, 0, 0, DEAD_ADDRESS, block.timestamp);
	}

	function buyback(uint256 amountIn) external onlyRole(DEFAULT_ADMIN_ROLE) {

		require(amountIn > 0, "Insufficient value sent");
		require(address(this).balance >= amountIn, "Insufficient balance");

		uint256 value = _getValueOfEthAmount(amountIn);

		_addLiquidity(amountIn);

		totalEthBoughtBack += amountIn;
		totalValueBoughtBack += value;

		emit Buyback(amountIn, value);
	}

	function deposit() external payable onlyRole(DEFAULT_ADMIN_ROLE) {

		totalEthDeposited += msg.value;
		emit Deposit(msg.value);
	}

	function setToken(address value) external onlyRole(DEFAULT_ADMIN_ROLE) {

		token = IERC20(value);
		_grantRole(DEFAULT_ADMIN_ROLE, address(token));
	}

	receive() external payable {}
}pragma solidity 0.8.10;


interface IUnicryptLiquidityLocker {

	function gFees() external view returns (
		uint256 ethFee,
		address secondaryFeeToken,
		uint256 secondaryTokenFee,
		uint256 secondaryTokenDiscount,
		uint256 liquidityFee,
		uint256 referralPercent,
		address referralToken,
		uint256 referralHold,
		uint256 referralDiscount
	);


	function lockLPToken(
		address _lpToken,
		uint256 _amount,
		uint256 _unlock_date,
		address payable _referral,
		bool _fee_in_eth,
		address payable _withdrawer
	) external payable;

}pragma solidity 0.8.10;


interface IAntiSnipe {

	function process(address from, address to) external;


	function launch(address pairAddress) external;

}pragma solidity 0.8.10;



contract HangryBirds is Context, IERC20, Ownable {

	using Address for address payable;

	string constant NAME = "HangryBirds";
	string constant SYMBOL = "HANGRY";
	uint8 constant DECIMALS = 9;

	uint256 constant MAX_UINT = 2 ** 256 - 1;
	address constant ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
	address constant UNICRYPT_LIQUIDITY_LOCKER_ADDRESS = 0x663A5C229c09b049E36dCc11a9B0d4a8Eb9db214;
	address constant ZERO_ADDRESS = address(0);
	address constant DEAD_ADDRESS = address(57005);

	mapping(address => uint256) rOwned;
	mapping(address => uint256) tOwned;

	mapping(address => mapping(address => uint256)) allowances;

	mapping(address => bool) public isExcludedFromFees;
	mapping(address => bool) public isExcludedFromRewards;
	mapping(address => bool) public isExcludedFromMaxWallet;
	address[] excluded;

	uint256 tTotal = 10 ** 12 * 10 ** DECIMALS;
	uint256 rTotal = (MAX_UINT - (MAX_UINT % tTotal));

	uint256 public maxWalletAmount = tTotal / 100;
	uint256 public maxTxAmountBuy = maxWalletAmount / 2;
	uint256 public maxTxAmountSell = maxWalletAmount / 2;

	address payable marketingWalletAddress;

	mapping(address => bool) automatedMarketMakerPairs;

	bool areFeesBeingProcessed = false;
	bool public isFeeProcessingEnabled = true;
	uint256 public feeProcessingThreshold = tTotal / 500;

	IDEXRouter router;
	BuybackTreasury public treasury;
	IAntiSnipe antiSnipe;

	mapping(address => bool) snipers;

	bool hasLaunched;
	uint256 launchedAt;

	FeeSet public buyFees = FeeSet({
		reflectFee: 5,
		marketingFee: 5,
		treasuryFee: 2
	});

	FeeSet public sellFees = FeeSet({
		reflectFee: 8,
		marketingFee: 2,
		treasuryFee: 5
	});

	struct FeeSet {
		uint256 reflectFee;
		uint256 marketingFee;
		uint256 treasuryFee;
	}

	struct ReflectValueSet {
		uint256 rAmount;
		uint256 rTransferAmount;
		uint256 rReflectFee;
		uint256 rOtherFee;
		uint256 tTransferAmount;
		uint256 tReflectFee;
		uint256 tOtherFee;
	}

	event FeesProcessed(uint256 amount);
	event Launched();
	event SniperAdded(address sniper);
	event SniperPunished(address sniper);
	event SniperRemoved(address sniper);

	constructor() {
		address self = address(this);

		rOwned[owner()] = rTotal;

		router = IDEXRouter(ROUTER_ADDRESS);
		treasury = new BuybackTreasury(address(router), self, owner());

		marketingWalletAddress = payable(msg.sender);

		isExcludedFromFees[owner()] = true;
		isExcludedFromFees[marketingWalletAddress] = true;
		isExcludedFromFees[address(treasury)] = true;
		isExcludedFromFees[self] = true;
		isExcludedFromFees[DEAD_ADDRESS] = true;

		isExcludedFromMaxWallet[owner()] = true;
		isExcludedFromMaxWallet[marketingWalletAddress] = true;
		isExcludedFromMaxWallet[address(treasury)] = true;
		isExcludedFromMaxWallet[self] = true;
		isExcludedFromMaxWallet[DEAD_ADDRESS] = true;

		emit Transfer(ZERO_ADDRESS, owner(), tTotal);
	}

	function name() public pure returns (string memory) {

		return NAME;
	}

	function symbol() public pure returns (string memory) {

		return SYMBOL;
	}

	function decimals() public pure returns (uint8) {

		return DECIMALS;
	}

	function totalSupply() public view override returns (uint256) {

		return tTotal;
	}

	function balanceOf(address account) public view override returns (uint256) {

		if (isExcludedFromRewards[account]) return tOwned[account];
		return tokenFromReflection(rOwned[account]);
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {

		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {

		return allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {

		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

		_transfer(sender, recipient, amount);

		uint256 currentAllowance = allowances[sender][_msgSender()];
		require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

		unchecked {
			_approve(sender, _msgSender(), currentAllowance - amount);
		}

		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

		_approve(_msgSender(), spender, allowances[_msgSender()][spender] + addedValue);
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

		uint256 currentAllowance = allowances[_msgSender()][spender];
		require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

		unchecked {
			_approve(_msgSender(), spender, currentAllowance - subtractedValue);
		}

		return true;
	}

	function tokenFromReflection(uint256 rAmount) public view returns (uint256) {

		require(rAmount <= rTotal, "Amount must be less than total reflections");
		uint256 currentRate = _getRate();
		return rAmount / currentRate;
	}

	function _getValues(uint256 tAmount, bool isBuying, bool takeFee) private view returns (ReflectValueSet memory set) {

		set = _getTValues(tAmount, isBuying, takeFee);
		(set.rAmount, set.rTransferAmount, set.rReflectFee, set.rOtherFee) = _getRValues(set, tAmount, takeFee, _getRate());
		return set;
	}

	function _getTValues(uint256 tAmount, bool isBuying, bool takeFee) private view returns (ReflectValueSet memory set) {

		if (!takeFee) {
			set.tTransferAmount = tAmount;
			return set;
		}

		FeeSet memory fees = isBuying ? buyFees : sellFees;

		set.tReflectFee = tAmount * fees.reflectFee / 100;
		set.tOtherFee = tAmount * (fees.marketingFee + fees.treasuryFee) / 100;
		set.tTransferAmount = tAmount - set.tReflectFee - set.tOtherFee;

		return set;
	}

	function _getRValues(ReflectValueSet memory set, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rReflectFee, uint256 rOtherFee) {

		rAmount = tAmount * currentRate;

		if (!takeFee) {
			return (rAmount, rAmount, 0, 0);
		}

		rReflectFee = set.tReflectFee * currentRate;
		rOtherFee = set.tOtherFee * currentRate;
		rTransferAmount = rAmount - rReflectFee - rOtherFee;
		return (rAmount, rTransferAmount, rReflectFee, rOtherFee);
	}

	function _getRate() private view returns (uint256) {

		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply / tSupply;
	}

	function _getCurrentSupply() private view returns (uint256, uint256) {

		uint256 rSupply = rTotal;
		uint256 tSupply = tTotal;

		for (uint256 i = 0; i < excluded.length; i++) {
			if (rOwned[excluded[i]] > rSupply || tOwned[excluded[i]] > tSupply) return (rTotal, tTotal);
			rSupply -= rOwned[excluded[i]];
			tSupply -= tOwned[excluded[i]];
		}

		if (rSupply < rTotal / tTotal) return (rTotal, tTotal);
		return (rSupply, tSupply);
	}

	function _approve(address owner, address spender, uint256 amount) private {

		require(owner != ZERO_ADDRESS, "ERC20: approve from the zero address");
		require(spender != ZERO_ADDRESS, "ERC20: approve to the zero address");

		allowances[owner][spender] = amount;

		emit Approval(owner, spender, amount);
	}

	function _transfer(address from, address to, uint256 amount) private {

		require(from != ZERO_ADDRESS, "ERC20: transfer from the zero address");
		require(to != ZERO_ADDRESS, "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");
		require(amount <= balanceOf(from), "You are trying to transfer more than your balance");
		require(!snipers[from], "Sniper no sniping!");

		bool isBuying = automatedMarketMakerPairs[from];
		bool shouldTakeFees = hasLaunched && !isExcludedFromFees[from] && !isExcludedFromFees[to];

		if (hasLaunched) {
			if (!automatedMarketMakerPairs[to] && !isExcludedFromMaxWallet[to]) {
				require((balanceOf(to) + amount) <= maxWalletAmount, "Cannot transfer more than the max wallet amount");
			}

			if (shouldTakeFees) {
				require(amount <= (isBuying ? maxTxAmountBuy : maxTxAmountSell), "Cannot transfer more than the max buy or sell");
			}

			if (block.number <= (launchedAt + 1)) {
				antiSnipe.process(from, to);
			}

			uint256 balance = balanceOf(address(this));
			if (isFeeProcessingEnabled && !areFeesBeingProcessed && balance >= feeProcessingThreshold && !automatedMarketMakerPairs[from]) {
				areFeesBeingProcessed = true;
				_processFees(balance > maxTxAmountSell ? maxTxAmountSell : balance);
				areFeesBeingProcessed = false;
			}
		}

		_tokenTransfer(from, to, amount, isBuying, shouldTakeFees);
	}

	function _takeReflectFees(uint256 rReflectFee) private {

		rTotal -= rReflectFee;
	}

	function _takeOtherFees(uint256 rOtherFee, uint256 tOtherFee) private {

		address self = address(this);

		rOwned[self] += rOtherFee;

		if (isExcludedFromRewards[self]) {
			tOwned[self] += tOtherFee;
		}
	}

	function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool isBuying, bool shouldTakeFees) private {

		ReflectValueSet memory set = _getValues(tAmount, isBuying, shouldTakeFees);

		if (isExcludedFromRewards[sender]) {
			tOwned[sender] -= tAmount;
		}

		if (isExcludedFromRewards[recipient]) {
			tOwned[recipient] += set.tTransferAmount;
		}

		rOwned[sender] -= set.rAmount;
		rOwned[recipient] += set.rTransferAmount;

		if (shouldTakeFees) {
			_takeReflectFees(set.rReflectFee);
			_takeOtherFees(set.rOtherFee, set.tOtherFee);

			emit Transfer(sender, address(this), set.tOtherFee);
		}

		emit Transfer(sender, recipient, set.tTransferAmount);
	}

	function _processFees(uint256 amount) private {

		uint256 feeSum = buyFees.marketingFee + buyFees.treasuryFee;
		if (feeSum == 0) return;

		_swapExactTokensForETH(amount);

		uint256 amountEth = address(this).balance;
		uint256 amountForMarketing = amountEth * buyFees.marketingFee / feeSum;
		uint256 amountForTreasury = amountEth - amountForMarketing;

		if (amountForMarketing > 0) {
			marketingWalletAddress.transfer(amountForMarketing);
		}

		if (amountForTreasury > 0) {
			treasury.deposit{value : amountForTreasury}();
		}

		emit FeesProcessed(amount);
	}

	function _swapExactTokensForETH(uint256 amountIn) private {

		address self = address(this);

		address[] memory path = new address[](2);
		path[0] = self;
		path[1] = router.WETH();

		_approve(self, address(router), amountIn);
		router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, 0, path, self, block.timestamp);
	}

	function _excludeFromRewards(address account) private {

		require(!isExcludedFromRewards[account], "Account is already excluded from rewards");

		if (rOwned[account] > 0) {
			tOwned[account] = tokenFromReflection(rOwned[account]);
		}

		isExcludedFromRewards[account] = true;
		excluded.push(account);
	}

	function _includeInRewards(address account) private {

		require(isExcludedFromRewards[account], "Account is not excluded from rewards");

		for (uint256 i = 0; i < excluded.length; i++) {
			if (excluded[i] == account) {
				excluded[i] = excluded[excluded.length - 1];
				tOwned[account] = 0;
				isExcludedFromRewards[account] = false;
				excluded.pop();
				break;
			}
		}
	}

	function launch(uint256 daysToLock) external payable onlyOwner {

		address self = address(this);

		require(!hasLaunched, "Already launched");
		require(daysToLock >= 30, "Must lock liquidity for a minimum of 30 days");

		uint256 tokensForLiquidity = balanceOf(self);
		require(tokensForLiquidity >= (tTotal / 4), "Initial liquidity must be at least 25% of total token supply");

		IUnicryptLiquidityLocker locker = IUnicryptLiquidityLocker(UNICRYPT_LIQUIDITY_LOCKER_ADDRESS);

		(uint256 lockFee,,,,,,,,) = locker.gFees();
		require(msg.value > lockFee, "Insufficient ETH for liquidity lock fee");

		uint256 ethForLiquidity = msg.value - lockFee;
		require(ethForLiquidity >= 0.1 ether, "Insufficient ETH for liquidity");

		address pairAddress = IDEXFactory(router.factory()).createPair(self, router.WETH());
		automatedMarketMakerPairs[pairAddress] = true;
		isExcludedFromMaxWallet[pairAddress] = true;

		if (!isExcludedFromRewards[pairAddress]) {
			_excludeFromRewards(pairAddress);
		}

		_approve(self, address(router), tokensForLiquidity);
		router.addLiquidityETH{value : ethForLiquidity}(self, tokensForLiquidity, 0, 0, self, block.timestamp);

		IERC20 lpToken = IERC20(pairAddress);

		uint256 balance = lpToken.balanceOf(self);
		require(lpToken.approve(address(locker), balance), "Liquidity token approval failed");

		locker.lockLPToken{value : lockFee}(address(lpToken), balance, block.timestamp + (daysToLock * (1 days)), payable(0), true, payable(owner()));

		antiSnipe.launch(pairAddress);

		hasLaunched = true;
		launchedAt = block.number;

		emit Launched();
	}

	function recoverLaunchedTokens() external onlyOwner {

		require(!hasLaunched, "Already launched");

		_transfer(address(this), owner(), balanceOf(address(this)));
	}

	function buyback(uint256 amount) external onlyOwner {

		treasury.buyback(amount);
	}

	function addSniper(address account) external {

		require(msg.sender == address(antiSnipe), "Snipers can only be added by the anti-snipe contract");

		if (block.timestamp <= (launchedAt + 1)) {
			snipers[account] = true;
			emit SniperAdded(account);
		}
	}

	function punishSniper(address account) external onlyOwner {

		require(snipers[account], "This account is not a sniper");

		uint256 balance = balanceOf(account);
		require(balance > 0, "Insufficient token balance");

		_transfer(account, address(this), balance);

		emit SniperPunished(account);
	}

	function removeSniper(address account) external onlyOwner {

		require(snipers[account], "This account is not a sniper");
		snipers[account] = false;
		emit SniperRemoved(account);
	}

	function setAntiSnipe(address value) external onlyOwner {

		require(value != ZERO_ADDRESS, "Antisnipe cannot be the zero address");
		require(value != address(antiSnipe), "Antisnipe is already set to this value");
		antiSnipe = IAntiSnipe(value);
	}

	function setFees(bool areBuyFees, uint256 reflectFee, uint256 marketingFee, uint256 treasuryFee) external onlyOwner {

		require((reflectFee + marketingFee + treasuryFee) <= 25, "Cannot set fees to above a combined total of 25%");

		FeeSet memory fees = FeeSet({
			reflectFee: reflectFee,
			marketingFee: marketingFee,
			treasuryFee: treasuryFee
		});

		if (areBuyFees) {
			buyFees = fees;
		} else {
			sellFees = fees;
		}
	}

	function setIsFeeProcessingEnabled(bool value) external onlyOwner {

		isFeeProcessingEnabled = value;
	}

	function setFeeProcessingThreshold(uint256 value) external onlyOwner {

		feeProcessingThreshold = value;
	}

	function setMaxTransactionAmounts(uint256 maxBuy, uint256 maxSell) external onlyOwner {

		require(maxBuy >= (tTotal / 400), "Must set max buy to at least 0.25% of total supply");
		require(maxSell >= (tTotal / 400), "Must set max sell to at least 0.25% of total supply");

		maxTxAmountBuy = maxBuy;
		maxTxAmountSell = maxSell;
	}

	function setMarketingWalletAddress(address payable value) external onlyOwner {

		require(marketingWalletAddress != value, "Marketing wallet address is already set to this value");
		marketingWalletAddress = value;
	}

	function setMaxWalletAmount(uint256 value) external onlyOwner {

		require(value >= (tTotal / 200), "Must set max wallet to at least 0.5% of total supply");
		maxWalletAmount = value;
	}

	function setIsExcludedFromFees(address account, bool value) external onlyOwner {

		require(isExcludedFromFees[account] != value, "Account is already set to this value");
		isExcludedFromFees[account] = value;
	}

	function setIsExcludedFromMaxWallet(address account, bool value) external onlyOwner {

		require(isExcludedFromMaxWallet[account] != value, "Account is already set to this value");
		isExcludedFromMaxWallet[account] = value;
	}

	function excludeFromRewards(address account) external onlyOwner {

		_excludeFromRewards(account);
	}

	function includeInRewards(address account) external onlyOwner {

		_includeInRewards(account);
	}

	receive() external payable {}
}