
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
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}pragma solidity >=0.6.2;

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

}pragma solidity >=0.6.2;


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

}// GPL-3.0
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;


interface IStaking {

	function stake(uint256 amount) external;

	function unstake(uint256 amount) external;


    function claimProfit(IERC20 token) external returns (uint256);

    function claimAllProfits() external returns (uint256[] memory profits);


    function addClaimableToken(IERC20 newClaimableToken) external;

    function removeClaimableToken(IERC20 removedClaimableToken) external;


    function addToken(IERC20 newToken) external;

    function removeToken(IERC20 removedToken) external;


    function convertFunds() external;


    function setStakingLockupTime(uint256 newLockupTime) external;


    function profitOf(address account, IERC20 token) external view returns (uint256);


    function getClaimableTokens() external view returns (IERC20[] memory);

    function getOtherTokens() external view returns (IERC20[] memory);


    receive() external payable;
}// GPL-3.0
pragma solidity ^0.6.2;


interface IFeesCollector {

    function sendProfit(uint256 amount, IERC20 token) external;

}// MIT
pragma solidity ^0.6.2;

interface IWETH {

    function deposit() external payable;

    function withdraw(uint256) external;

}// GPL-3.0
pragma solidity 0.6.12;


contract Staking is IStaking, IFeesCollector, Ownable {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant PRECISION_DECIMALS = 1e18;

    uint256 public totalStaked;

    IERC20[] private claimableTokens;
    IERC20[] private otherTokens;

	mapping(IERC20 => bool) private claimableTokensSupported;
    mapping(IERC20 => bool) private otherTokensSupported;

	mapping(IERC20 => uint256) public totalProfits;

    mapping(address => mapping(IERC20 => uint256)) private lastProfits;
    mapping(address => mapping(IERC20 => uint256)) private savedProfits;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeTimestamps;

    IERC20 private immutable cviToken;
    IWETH private immutable wethToken;
    address public immutable fallbackRecipient;

    IUniswapV2Router02 private immutable uniswapRouter;

    uint256 public stakeLockupTime = 1 hours;

	uint256 public creationTimestamp;

    constructor(IERC20 _cviToken, IUniswapV2Router02 _uniswapRouter) public {
    	cviToken = _cviToken;
    	uniswapRouter = _uniswapRouter;
    	wethToken = IWETH(_uniswapRouter.WETH());
    	fallbackRecipient = msg.sender;
		creationTimestamp = block.timestamp;
    }

    receive() external payable override {

    }

    function sendProfit(uint256 _amount, IERC20 _token) external override {

        bool isClaimableToken = claimableTokensSupported[_token];
        bool isOtherToken = otherTokensSupported[_token];
    	require(isClaimableToken || isOtherToken, "Token not supported");

    	if (totalStaked > 0) {
            if (isClaimableToken) {
    		  addProfit(_amount, _token);
            }
    		_token.safeTransferFrom(msg.sender, address(this), _amount);
    	} else {
    		_token.safeTransferFrom(msg.sender, fallbackRecipient, _amount);
    	}
    }

    function stake(uint256 _amount) external override {

    	require(_amount > 0, "Amount must be positive");

    	if (stakes[msg.sender] > 0) {
    		saveProfit(claimableTokens, msg.sender, stakes[msg.sender]);
    	}

    	stakes[msg.sender] = stakes[msg.sender].add(_amount);
    	stakeTimestamps[msg.sender] = block.timestamp;
    	totalStaked = totalStaked.add(_amount);

    	for (uint256 tokenIndex = 0; tokenIndex < claimableTokens.length; tokenIndex = tokenIndex.add(1)) {
    		IERC20 token = claimableTokens[tokenIndex];
	    	lastProfits[msg.sender][token] = totalProfits[token];	    	
	    }

	    cviToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function unstake(uint256 _amount) external override {

    	require(_amount > 0, "Amount must be positive");
    	require(_amount <= stakes[msg.sender], "Not enough staked");
    	require(stakeTimestamps[msg.sender].add(stakeLockupTime) <= block.timestamp, "Funds locked");

    	totalStaked = totalStaked.sub(_amount);
    	stakes[msg.sender] = stakes[msg.sender].sub(_amount);
    	saveProfit(claimableTokens, msg.sender, _amount);
    	cviToken.safeTransfer(msg.sender, _amount);
    }

    function claimProfit(IERC20 token) external override returns (uint256 profit) {

    	_saveProfit(token, msg.sender, stakes[msg.sender]);
    	
    	profit = _claimProfit(token);
    	require(profit > 0, "No profit for token");
    }

    function claimAllProfits() external override returns (uint256[] memory) {

        uint256[] memory profits = new uint256[](claimableTokens.length); 
    	saveProfit(claimableTokens, msg.sender, stakes[msg.sender]);

    	uint256 totalProfit = 0;
    	for (uint256 tokenIndex = 0; tokenIndex < claimableTokens.length; tokenIndex++) {
            uint256 currProfit = _claimProfit(claimableTokens[tokenIndex]);
    		profits[tokenIndex] = currProfit;
            totalProfit = totalProfit.add(currProfit);
    	}

    	require(totalProfit > 0, "No profit");

        return profits;
    }

    function addClaimableToken(IERC20 _newClaimableToken) external override onlyOwner {

        _addToken(claimableTokens, claimableTokensSupported, _newClaimableToken);
    }

    function removeClaimableToken(IERC20 _removedClaimableToken) external override onlyOwner {

        _removeToken(claimableTokens, claimableTokensSupported, _removedClaimableToken);
    }

    function addToken(IERC20 _newToken) external override onlyOwner {

        _addToken(otherTokens, otherTokensSupported, _newToken);
        _newToken.safeApprove(address(uniswapRouter), uint256(-1));
    }

    function removeToken(IERC20 _removedToken) external override onlyOwner {

        _removeToken(otherTokens, otherTokensSupported, _removedToken);
        _removedToken.safeApprove(address(uniswapRouter), 0);
    }

    function convertFunds() external override {

        bool didConvert = false;
    	for (uint256 tokenIndex = 0; tokenIndex < otherTokens.length; tokenIndex++) {
    		IERC20 token = otherTokens[tokenIndex];
            uint256 balance = token.balanceOf(address(this));

            if (balance > 0) {
                didConvert = true;

        		address[] memory path = new address[](2);
            	path[0] = address(token);
            	path[1] = address(wethToken);

        		uint256[] memory amounts = 
        			uniswapRouter.swapExactTokensForTokens(token.balanceOf(address(this)), 
        				0, path, address(this), block.timestamp);
                addProfit(amounts[1], IERC20(address(wethToken)));
            }
    	}

        require(didConvert, "No funds to convert");
    }

    function setStakingLockupTime(uint256 _newLockupTime) external override onlyOwner {

        stakeLockupTime = _newLockupTime;
    }

    function profitOf(address _account, IERC20 _token) external view override returns (uint256) {

        return savedProfits[_account][_token].add(unsavedProfit(_account, stakes[_account], _token));
    }

    function getClaimableTokens() external view override returns (IERC20[] memory) {

        return claimableTokens;
    }

    function getOtherTokens() external view override returns (IERC20[] memory) {

        return otherTokens;
    }

    function _claimProfit(IERC20 _token) private returns (uint256 profit) {

    	require(claimableTokensSupported[_token], "Token not supported");
		profit = savedProfits[msg.sender][_token];

		if (profit > 0) {
			savedProfits[msg.sender][_token] = 0;
			lastProfits[msg.sender][_token] = totalProfits[_token];

			if (address(_token) == address(wethToken)) {
				wethToken.withdraw(profit);
                msg.sender.transfer(profit);
			} else {
				_token.safeTransfer(msg.sender, profit);
			}
		}
    }

    function _addToken(IERC20[] storage _tokens, mapping(IERC20 => bool) storage _supportedTokens, IERC20 _newToken) private {

    	require(!_supportedTokens[_newToken], "Token already added");
    	_supportedTokens[_newToken] = true;
    	_tokens.push(_newToken);
    }

    function _removeToken(IERC20[] storage _tokens, mapping(IERC20 => bool) storage _supportedTokens, IERC20 _removedTokenAddress) private {

    	require(_supportedTokens[_removedTokenAddress], "Token not supported");

    	bool isFound = false;
    	for (uint256 tokenIndex = 0; tokenIndex < _tokens.length; tokenIndex = tokenIndex.add(1)) {
    		if (_tokens[tokenIndex] == _removedTokenAddress) {
    			isFound = true;
    			_tokens[tokenIndex] = _tokens[_tokens.length.sub(1)];
    			_tokens.pop();
    			break;
    		}
    	}
    	require(isFound, "Token not found");

    	_supportedTokens[_removedTokenAddress] = false;
    }

    function addProfit(uint256 _amount, IERC20 _token) private {

    	totalProfits[_token] = totalProfits[_token].add(_amount.mul(PRECISION_DECIMALS).div(totalStaked));
    }

    function saveProfit(IERC20[] storage _claimableTokens, address _account, uint256 _amount) private {

    	for (uint256 tokenIndex = 0; tokenIndex < _claimableTokens.length; tokenIndex = tokenIndex.add(1)) {
    		IERC20 token = _claimableTokens[tokenIndex];
    		_saveProfit(token, _account, _amount);
    	}
    }

    function _saveProfit(IERC20 _token, address _account, uint256 _amount) private {

    	savedProfits[_account][_token] = 
    			savedProfits[_account][_token].add(unsavedProfit(_account, _amount, _token));
    }

    function unsavedProfit(address _account, uint256 _amount, IERC20 _token) private view returns (uint256) {

    	return totalProfits[_token].sub(lastProfits[_account][_token]).mul(_amount).div(PRECISION_DECIMALS);
    }
}