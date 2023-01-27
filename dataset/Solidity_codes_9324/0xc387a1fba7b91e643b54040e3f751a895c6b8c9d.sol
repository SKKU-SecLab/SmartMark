

pragma solidity ^0.6.0;

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

library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

interface IUniswapV2Router01 {

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

}


interface IUniswapV2Router02 is IUniswapV2Router01 {

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

}

contract LGEWhitelisted is ContextUpgradeSafe {

    
    using SafeMath for uint256;
    
    struct WhitelistRound {
        uint256 duration;
        uint256 amountMax;
        mapping(address => bool) addresses;
        mapping(address => uint256) purchased;
    }
  
    WhitelistRound[] public _lgeWhitelistRounds;
    
    uint256 public _lgeTimestamp;
    address public _lgePairAddress;
    
    address public _whitelister;
    
    event WhitelisterTransferred(address indexed previousWhitelister, address indexed newWhitelister);
    
	function __LGEWhitelisted_init() internal initializer {

        __Context_init_unchained();
        __LGEWhitelisted_init_unchained();
    }
	
	function __LGEWhitelisted_init_unchained() internal initializer {

		_whitelister = _msgSender();

    }
    
    modifier onlyWhitelister() {

        require(_whitelister == _msgSender(), "Caller is not the whitelister");
        _;
    }
    
    function renounceWhitelister() external onlyWhitelister {

        emit WhitelisterTransferred(_whitelister, address(0));
        _whitelister = address(0);
    }
    
    function transferWhitelister(address newWhitelister) external onlyWhitelister {

        _transferWhitelister(newWhitelister);
    }
    
    function _transferWhitelister(address newWhitelister) internal {

        require(newWhitelister != address(0), "New whitelister is the zero address");
        emit WhitelisterTransferred(_whitelister, newWhitelister);
        _whitelister = newWhitelister;
    }
    
  
    function createLGEWhitelist(address pairAddress, uint256[] calldata durations, uint256[] calldata amountsMax) external onlyWhitelister() {

        require(durations.length == amountsMax.length, "Invalid whitelist(s)");
        
        _lgePairAddress = pairAddress;
        
        if(durations.length > 0) {
            
            delete _lgeWhitelistRounds;
        
            for (uint256 i = 0; i < durations.length; i++) {
                _lgeWhitelistRounds.push(WhitelistRound(durations[i], amountsMax[i]));
            }
        
        }
    }
    
    
    function modifyLGEWhitelist(uint256 index, uint256 duration, uint256 amountMax, address[] calldata addresses, bool enabled) external onlyWhitelister() {

        require(index < _lgeWhitelistRounds.length, "Invalid index");
        require(amountMax > 0, "Invalid amountMax");

        if(duration != _lgeWhitelistRounds[index].duration)
            _lgeWhitelistRounds[index].duration = duration;
        
        if(amountMax != _lgeWhitelistRounds[index].amountMax)  
            _lgeWhitelistRounds[index].amountMax = amountMax;
        
        for (uint256 i = 0; i < addresses.length; i++) {
            _lgeWhitelistRounds[index].addresses[addresses[i]] = enabled;
        }
    }
    
    
    function getLGEWhitelistRound() public view returns (uint256, uint256, uint256, uint256, bool, uint256) {

        
        if(_lgeTimestamp > 0) {
            
            uint256 wlCloseTimestampLast = _lgeTimestamp;
        
            for (uint256 i = 0; i < _lgeWhitelistRounds.length; i++) {
                
                WhitelistRound storage wlRound = _lgeWhitelistRounds[i];
                
                wlCloseTimestampLast = wlCloseTimestampLast.add(wlRound.duration);
                if(now <= wlCloseTimestampLast)
                    return (i.add(1), wlRound.duration, wlCloseTimestampLast, wlRound.amountMax, wlRound.addresses[_msgSender()], wlRound.purchased[_msgSender()]);
            }
        
        }
        
        return (0, 0, 0, 0, false, 0);
    }
    
    
    function _applyLGEWhitelist(address sender, address recipient, uint256 amount) internal {

        
        if(_lgePairAddress == address(0) || _lgeWhitelistRounds.length == 0)
            return;
        
        if(_lgeTimestamp == 0 && sender != _lgePairAddress && recipient == _lgePairAddress && amount > 0)
            _lgeTimestamp = now;
        
        if(sender == _lgePairAddress && recipient != _lgePairAddress) {
            
            (uint256 wlRoundNumber,,,,,) = getLGEWhitelistRound();
        
            if(wlRoundNumber > 0) {
                
                WhitelistRound storage wlRound = _lgeWhitelistRounds[wlRoundNumber.sub(1)];
                
                require(wlRound.addresses[recipient], "LGE - Buyer is not whitelisted");
                
                uint256 amountRemaining = 0;
                
                if(wlRound.purchased[recipient] < wlRound.amountMax)
                    amountRemaining = wlRound.amountMax.sub(wlRound.purchased[recipient]);
    
                require(amount <= amountRemaining, "LGE - Amount exceeds whitelist maximum");
                wlRound.purchased[recipient] = wlRound.purchased[recipient].add(amount);
                
            }
            
        }
        
    }
    
}

contract TokenPool is OwnableUpgradeSafe {

    
    IERC20 public token;
    
    function initialize(address _token)
        public
        initializer
    {

        __Ownable_init();
        
        token = IERC20(_token);
    }

    function balance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }
    
    function approve(address spender, uint256 amount) external onlyOwner returns (bool) {

        return token.approve(spender, amount);
    }

    function transfer(address to, uint256 value) external onlyOwner returns (bool) {

        return token.transfer(to, value);
    }

    function rescueFunds(address tokenToRescue, address to, uint256 amount) external onlyOwner returns (bool) {

        require(address(token) != tokenToRescue, 'TokenPool: Cannot claim token held by the contract');

        return IERC20(tokenToRescue).transfer(to, amount);
    }
}

contract NFTL is IERC20, OwnableUpgradeSafe, LGEWhitelisted {

    
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    
    uint256 private _cap;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    mapping(address => bool) public _feeExcluded;

	uint256 public _feeBurnPct;
	
	address[] public _reserveSwapPath;	
	
	uint256 public _feeFundPct;
	address public _feeFundAddress;
	
	uint256 public _feeRewardPct;
	address public _feeRewardAddress;
	
	uint256 public _feeEcoPct;
	address public _feeEcoAddress;
	
	uint256 public _feeCharityPct;
	address public _feeCharityAddress;	

	mapping(address => bool) public _pair;
	
	address public _router;
	
	TokenPool public _reserveTokenPool;
	
	event Distributed(uint256 feeFundAmount, uint256 feeRewardAmount, uint256 feeEcoAmount, uint256 feeCharityAmount);
    
    function initialize(
                address router,
                uint256 feeBurnPct, 
                uint256 feeFundPct, 
                address feeFundAddress, 
                uint256 feeRewardPct, 
                address feeRewardAddress, 
                uint256 feeEcoPct, 
                address feeEcoAddress, 
                uint256 feeCharityPct, 
                address feeCharityAddress
        )
        public
        initializer
    {

        
        _name = "NFTLAUNCH.network";
        _symbol = "NFTL";
        
        _decimals = 18;
        
        _cap = 1000000000e18;
        
        __Ownable_init();
		__LGEWhitelisted_init();
		
		_router = router;
		
		setFees(
		    feeBurnPct,
		    feeFundPct,
		    feeFundAddress,
		    feeRewardPct,
		    feeRewardAddress,
		    feeEcoPct,
		    feeEcoAddress,
		    feeCharityPct,
		    feeCharityAddress
		    );
		
		IUniswapV2Router02 r = IUniswapV2Router02(_router);
		IUniswapV2Factory f = IUniswapV2Factory(r.factory());
		
        setPair(f.createPair(address(this), r.WETH()), true);
        
        address[] memory reserveSwapPath = new address[](2);
            
        reserveSwapPath[0] = address(this);
        reserveSwapPath[1] = r.WETH();
                    
        setReserveSwapPath(reserveSwapPath);
		
		setFeeExcluded(_msgSender(), true);
		setFeeExcluded(address(this), true);
    }

    function setRouter(address r) public onlyOwner {

        _router = r;
    }
    
    function setFees(
                uint256 feeBurnPct, 
                uint256 feeFundPct, 
                address feeFundAddress, 
                uint256 feeRewardPct, 
                address feeRewardAddress, 
                uint256 feeEcoPct, 
                address feeEcoAddress, 
                uint256 feeCharityPct, 
                address feeCharityAddress
                ) public onlyOwner {

        
		require((feeBurnPct + feeFundPct + feeRewardPct + feeEcoPct + feeCharityPct) <= 10000, "Fees must not total more than 100%");
		
		require(feeFundAddress != address(0), "Fund address must not be zero address");
		require(feeRewardAddress != address(0), "Reward address must not be zero address");
		require(feeEcoAddress != address(0), "Eco address must not be zero address");
		require(feeCharityAddress != address(0), "Charity address must not be zero address");
		
		_feeBurnPct = feeBurnPct;
		
		_feeFundPct = feeFundPct;
		_feeFundAddress = feeFundAddress;
		
		_feeRewardPct = feeRewardPct;
		_feeRewardAddress = feeRewardAddress;
		
		_feeEcoPct = feeEcoPct;
		_feeEcoAddress = feeEcoAddress;
		
		_feeCharityPct = feeCharityPct;
		_feeCharityAddress = feeCharityAddress;		
		
    }
    
    function setReserveSwapPath(address[] memory path) public onlyOwner {

        
        require(path.length > 1, "Invalid path");

        distributeFees();
        
        _reserveSwapPath = path;
        
        _reserveTokenPool = new TokenPool();
		_reserveTokenPool.initialize(_reserveSwapPath[_reserveSwapPath.length-1]);
		
    }
    
    
    function collectedFees() public view returns (uint256 totalAmount, uint256 feeFundAmount, uint256 feeRewardAmount, uint256 feeEcoAmount, uint256 feeCharityAmount) {

            
            totalAmount = 0;
            
            if(address(_reserveTokenPool) != address(0))
                totalAmount = _reserveTokenPool.balance();
            
            if(totalAmount > 0) {
                
                uint256 totalPct = _feeFundPct + _feeRewardPct + _feeEcoPct + _feeCharityPct;
            
                feeFundAmount = totalAmount.mul(_feeFundPct).div(totalPct);
                feeRewardAmount = totalAmount.mul(_feeRewardPct).div(totalPct);
                feeEcoAmount = totalAmount.mul(_feeEcoPct).div(totalPct);
                
                feeCharityAmount = totalAmount.sub(feeFundAmount).sub(feeRewardAmount).sub(feeEcoAmount);
            
            }
            
    }
    
    function distributeFees() public onlyOwner {

        
        (uint256 totalAmount, uint256 feeFundAmount, uint256 feeRewardAmount, uint256 feeEcoAmount, uint256 feeCharityAmount) = collectedFees();
        
        if(totalAmount > 0) {
            
            IWETH weth = IWETH(IUniswapV2Router02(_router).WETH());
            
            if(_reserveSwapPath[_reserveSwapPath.length-1] == address(weth)) {
            
                _reserveTokenPool.transfer(address(this), totalAmount);
                
                weth.withdraw(totalAmount);
                
                if(feeFundAmount > 0)
                    TransferHelper.safeTransferETH(_feeFundAddress, feeFundAmount);
                if(feeRewardAmount > 0)    
                    TransferHelper.safeTransferETH(_feeRewardAddress, feeRewardAmount);
                if(feeEcoAmount > 0)    
                    TransferHelper.safeTransferETH(_feeEcoAddress, feeEcoAmount);
                if(feeCharityAmount > 0)      
                    TransferHelper.safeTransferETH(_feeCharityAddress, feeCharityAmount);
            
            } else {
                
                if(feeFundAmount > 0)
                    _reserveTokenPool.transfer(_feeFundAddress, feeFundAmount);
                if(feeRewardAmount > 0)
                    _reserveTokenPool.transfer(_feeRewardAddress, feeRewardAmount);
                if(feeEcoAmount > 0)
                    _reserveTokenPool.transfer(_feeEcoAddress, feeEcoAmount);
                if(feeCharityAmount > 0)
                    _reserveTokenPool.transfer(_feeCharityAddress, feeCharityAmount);
                
            }
            
            emit Distributed(feeFundAmount, feeRewardAmount, feeEcoAmount, feeCharityAmount);
            
        }
        
    }
    
    receive() external payable {}

	function setPair(address a, bool pair) public onlyOwner {

        _pair[a] = pair;
    }

	function setFeeExcluded(address a, bool excluded) public onlyOwner {

        _feeExcluded[a] = excluded;
    }
    
    function mint(address _to, uint256 _amount) public onlyOwner {

        _mint(_to, _amount);
    }
    
    function _beforeTokenTransfer(address sender, address recipient, uint256 amount) internal {

        
		LGEWhitelisted._applyLGEWhitelist(sender, recipient, amount);
		
        if (sender == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
	
	function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
		
        _beforeTokenTransfer(sender, recipient, amount);
		
		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		
		if(_pair[recipient] && !_feeExcluded[sender]) {
			
			uint256 feeBurnAmount = 0;
			
			if(_feeBurnPct > 0) {
			
				feeBurnAmount = amount.mul(_feeBurnPct).div(10000);
				
				_cap = _cap.sub(feeBurnAmount);
				_totalSupply = _totalSupply.sub(feeBurnAmount);
				emit Transfer(sender, address(0), feeBurnAmount);
				
			}
			
			uint256 feeToReservePct = _feeFundPct + _feeRewardPct + _feeEcoPct + _feeCharityPct;
			uint256 feeToReserveAmount = 0;
			
			if(feeToReservePct > 0)  {
			    
				feeToReserveAmount = amount.mul(feeToReservePct).div(10000);
				
				if(_router != address(0)) {
				    
				    _balances[address(this)] = _balances[address(this)].add(feeToReserveAmount);
				    emit Transfer(sender, address(this), feeToReserveAmount);

    				IUniswapV2Router02 r = IUniswapV2Router02(_router);
                    
                    _approve(address(this), _router, feeToReserveAmount);
    
                    r.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        feeToReserveAmount,
                        0,
                        _reserveSwapPath,
                        address(_reserveTokenPool),
                        block.timestamp
                    );
                
				} else {
				    _balances[_feeFundAddress] = _balances[_feeFundAddress].add(feeToReserveAmount);
				    emit Transfer(sender, _feeFundAddress, feeToReserveAmount);
				}
				
			}
			
			amount = amount.sub(feeBurnAmount).sub(feeToReserveAmount);
			
		}

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
	
	function burn(uint256 amount) external {

        _cap=_cap.sub(amount);
        _burn(_msgSender(), amount);
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function decimals() public view override returns (uint8) {

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
    
    function rescueFunds(address tokenToRescue, address to, uint256 amount) external onlyOwner returns (bool) {

        return IERC20(tokenToRescue).transfer(to, amount);
    }
    
    function rescuePoolFunds(address tokenToRescue, address to, uint256 amount) external onlyOwner returns (bool) {

        return _reserveTokenPool.rescueFunds(tokenToRescue, to, amount);
    }
	
}