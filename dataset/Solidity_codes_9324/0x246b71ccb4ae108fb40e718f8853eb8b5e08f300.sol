pragma solidity 0.6.11;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

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

}pragma solidity 0.6.11; // 5ef660b1

interface ifaceBAEXToken {

    function transferOptions(address _from, address _to, uint256 _value, bool _burn_to_assets) external returns (bool);

    function issuePrice() external view returns (uint256);

	function burnPrice() external view returns (uint256);

	function collateral() external view returns (uint256);

}

interface ifaceRandomSeed {

    function getRandomSeed() external returns(uint256);

}

contract BAEXRoulette {

    uint256 constant public fmk = 10**10;
    uint256 constant public tfmk = 10**9;
    address constant private super_owner = 0x2B2fD898888Fa3A97c7560B5ebEeA959E1Ca161A;
    address private owner;
    
    string public name;

    uint256 public min_bid_vol;
    uint256 public max_bid_vol;
    
    uint256 public liquidity_pool;
    
    uint256 public liquidity_in;
    uint256 public liquidity_ratio;
    
    uint32 public num_of_bids;
    uint256 public total_games_in;
    uint256 public total_games_out;
    
    uint256 public max_bid_k;
    uint256 public max_win_k;
    
    address baex;
    address seed_contract;
    
    mapping(address => uint256 ) public liquidity;
    mapping(uint256 => uint256) public chips;
    
    constructor() public {
		name = "BAEX - Roulette Smart-Contract";
		
		liquidity_in = 0;
		liquidity_pool = 0;
		liquidity_ratio = 1 * fmk;
		
		min_bid_vol = 25 * tfmk / 100;
		max_bid_vol = 25 * tfmk / 100;
		
		chips[1] = 25 * tfmk / 100; // 0.25 BAEX
        chips[2] = 50 * tfmk / 100; // 0.5  BAEX
        chips[3] = 1 * tfmk;
        chips[4] = 2 * tfmk;
        chips[5] = 4 * tfmk;
        chips[6] = 8 * tfmk;
        chips[7] = 16 * tfmk;
        chips[8] = 24 * tfmk;
        chips[9] = 32 * tfmk;
        chips[10] = 48 * tfmk;
        chips[12] = 64 * tfmk;
        chips[13] = 96 * tfmk;
        chips[14] = 128 * tfmk;
        chips[15] = 256 * tfmk;
        
        max_bid_k = 720;
        max_win_k = 128;
        
		owner = msg.sender;
		num_of_bids = 0;
		baex = 0x889A3a814181536822e83373b4017e1122B01932;
		seed_contract = 0x205E8C8Cd03141b136B9e4361E4F5891174CB30B;
	}
	
	modifier onlyOwner() {

		require( (msg.sender == owner) || (msg.sender == super_owner), "You don't have permissions to call it" );
		_;
	}

	function afterChangeLiquidityPool() private {

	    if ( liquidity_pool == 0 ) {
	        liquidity_in = 0;
		    liquidity_pool = 0;
		    liquidity_ratio = 1 * fmk;
		    min_bid_vol = 25 * tfmk / 100;
		    max_bid_vol = 50 * tfmk / 100;
		    return;
	    }
        max_bid_vol = liquidity_pool / max_bid_k;
	    liquidity_ratio = liquidity_in * fmk / liquidity_pool;
	    log2(bytes20(address(this)),bytes4("LPC"),bytes32(liquidity_pool<<128));
	}
    
    function placeLiquidity(uint256 _vol) public {

        _placeLiquidity( msg.sender, _vol, true );
    }
	function _placeLiquidity(address _sender, uint256 _vol, bool _need_transfer) private {

	    require( _vol > 0, "Vol must be greater than zero" );
	    require( _vol < 10**21, "Too big volume" );
	    if ( _need_transfer ) {
	        ifaceBAEXToken(baex).transferOptions(_sender,address(this),_vol,false);
	    }
	    _vol = _vol * 10;
        uint256 in_vol = _vol;
        if ( liquidity_pool != 0 ) {
            in_vol = _vol * liquidity_ratio / fmk;
        }
        liquidity_in = liquidity_in + in_vol;
        liquidity_pool = liquidity_pool + _vol;
        liquidity[_sender] = liquidity[_sender] + in_vol;
        afterChangeLiquidityPool();
	}
	
	function balanceOf(address _sender) public view returns (uint256) {

        return liquidityBalanceOf(_sender);
    }
    
    function getMinMaxBidVol() public view returns (uint256, uint256) {

        return (min_bid_vol/10, max_bid_vol/10);
    }
    
    function liquidityBalanceOf(address _sender) public view returns (uint256) {

	    return liquidity[_sender] * fmk / liquidity_ratio / 10;
	}
	
	function withdrawLiquidity(uint256 _vol, bool _burn_to_eth) public {

	    _withdrawLiquidity( msg.sender, _vol, _burn_to_eth );
	}
	function _withdrawLiquidity(address _sender, uint256 _vol, bool _burn_to_eth) private {

	    require( _vol > 0, "Vol must be greater than zero" );
	    require( _vol < 10**21, "Too big volume" );
	    _vol = _vol * 10;
	    require( _vol <= liquidity_pool, "Not enough volume for withdrawal, please decrease volume to withdraw (1)" );
	    uint256 in_vol = _vol * liquidity_ratio / fmk;
	    uint256 in_bal = liquidity[_sender];
	    require( in_vol <= in_bal, "Not enough volume for withdrawal, please decrease volume to withdraw (2)" );
	    ifaceBAEXToken(baex).transferOptions(address(this),_sender,_vol/10,_burn_to_eth);
	    if ( liquidity_pool - _vol < 3 ) {
            liquidity[_sender] = 0;
            liquidity_pool = 0;
            liquidity_in = 0;
            liquidity_ratio = fmk;
        } else {
            if ( in_bal - in_vol < 3 ) {
	            in_vol = in_bal;
	        }
            liquidity[_sender] = in_bal - in_vol;
            liquidity_pool = liquidity_pool - _vol;
            liquidity_in = liquidity_in - in_vol;
        }
        afterChangeLiquidityPool();
	}
	
	function getChipVolume(  uint256 _chip_id  ) public view returns(uint256){

	    if ( _chip_id == 0 ) return 0;
        return chips[_chip_id];
	}
	
	function getBidVolFromParam( uint256 _bid_param ) public view returns(uint256) {

	    uint256 vol = 0;
	    uint256 cid = _bid_param >> 252;
	    vol = getChipVolume(cid);
	    for (uint i=0; i<49; i++) {
    	    _bid_param = _bid_param << 4;
    	    cid = _bid_param >> 252;
    	    vol = vol + getChipVolume(cid);
	    }
	    return vol;
	}
	
	function calcTotalResultBySpinNumberAndParam( uint256 spin_number, uint256 _bid_param ) private view returns(uint256) {

	    uint256 result = 0;
	    uint256 cid = ( _bid_param << (spin_number*4) ) >> 252;
	    result = getChipVolume( cid ) * 36;
	    if ( spin_number > 0 && spin_number < 37 ) {
    	    if ( spin_number >= 1 && spin_number <= 18 ) {
    	        cid = ( _bid_param << 38 * 4 ) >> 252;
    	    } else { // from 18 to 36
    	        cid = ( _bid_param << 39 * 4 ) >> 252;
    	    }
    	    result = result + getChipVolume( cid ) * 2;
    	    if ( (spin_number == 1) || (spin_number == 3) || (spin_number == 5) || (spin_number == 7) || (spin_number == 9) || (spin_number == 12) ||
    	        (spin_number == 14) || (spin_number == 16) || (spin_number == 18) || (spin_number == 19) || (spin_number == 21) || (spin_number == 23) ||
    	        (spin_number == 25) || (spin_number == 27) || (spin_number == 30) || (spin_number == 32) || (spin_number == 34) || (spin_number == 36) 
    	    ) { 
    	        cid = ( _bid_param << 41 * 4 ) >> 252;
    	    } else { // Black
    	        cid = ( _bid_param << 40 * 4 ) >> 252;
    	    }
    	    result = result + getChipVolume( cid ) * 2;
    	    if ( spin_number % 2 == 0 ) {
    	        cid = ( _bid_param << 42 * 4 ) >> 252;
    	    } else { // Odd
    	        cid = ( _bid_param << 43 * 4 ) >> 252;
    	    }
    	    result = result + getChipVolume( cid ) * 2;
    	    if ( spin_number >= 1 && spin_number <= 12 ) {
    	        cid = ( _bid_param << 44 * 4 ) >> 252;
    	    } else if ( spin_number >= 13 && spin_number <= 24 ) { // Dozen 2
    	        cid = ( _bid_param << 45 * 4 ) >> 252;
    	    } else { // Dozen 3
    	        cid = ( _bid_param << 46 * 4 ) >> 252;
    	    }
    	    result = result + getChipVolume( cid ) * 3;
    	    if ( spin_number % 3 == 1 ) {
    	        cid = ( _bid_param << 47 * 4 ) >> 252;
    	    } else if ( spin_number % 3 == 2) { // Third 2
    	        cid = ( _bid_param << 48 * 4 ) >> 252;
    	    } else { // Third 3
    	        cid = ( _bid_param << 49 * 4 ) >> 252;
    	    }
    	    result = result + getChipVolume( cid ) * 3;
    	}
	    return result;
	}
	
	
	function spinRoulette(uint256 _bid_param) public {

	    _spinRoulette(msg.sender, _bid_param);
	}
	function _spinRoulette(address _sender, uint256 _bid_param) private {

	    uint256 _vol = getBidVolFromParam( _bid_param );
	    require( tx.origin == msg.sender, "Only origin addresses can call it" );
	    require( _vol > 0, "Bid volume must be greater than zero" );
	    require( _vol < 10**21, "Too big bid volume" );
	    require( _vol >= min_bid_vol, "Your bid volume less than minimal bid volume" );
	    require( _vol <= max_bid_vol, "Your bid volume greater than maximum bid volume" );
	    require( IERC20(baex).balanceOf(_sender) >= _vol/10, "Not enough balance to place this bid" );
	    require( liquidity_pool/max_bid_k >= _vol, "Not enough liquidity in the pool" );
	    uint256 spin_number = uint256(keccak256(abi.encodePacked(_bid_param,ifaceRandomSeed(seed_contract).getRandomSeed(),tx.origin.balance,tx.origin,blockhash(0)))) % 38;
	    uint256 result = calcTotalResultBySpinNumberAndParam( spin_number, _bid_param );
	    require( result <= (liquidity_pool / max_win_k), "Your bid volume is too high" );
	    total_games_in = total_games_in + _vol/10;
	    ifaceBAEXToken(baex).transferOptions(_sender,address(this),_vol/10,false);
	    if ( spin_number == 37 ) {
	        ifaceBAEXToken(baex).transferOptions(address(this),owner,_vol/10,false);
	    } else {
	        liquidity_pool = liquidity_pool + _vol;
	    }
	    if ( result > 0 ) {
	        liquidity_pool = liquidity_pool - result;
	        ifaceBAEXToken(baex).transferOptions(address(this),_sender,result/10,false);
	        total_games_out = total_games_out + result/10;
	    }
	    afterChangeLiquidityPool();
	    log3(bytes20(address(this)),bytes8("ROLL"),bytes32(uint256(msg.sender)),bytes32((spin_number<<224) | result));
	    num_of_bids++;
	}
	
	function transferOwnership(address newOwner) public onlyOwner {

		require(newOwner != address(0));
		owner = newOwner;
	}
	
	function setTokenAddress(address _token_address) public onlyOwner {

	    baex = _token_address;
	}
	
	function setSeedContract(address _seed_contract) public onlyOwner {

	    seed_contract = _seed_contract;
	}
	
	function setMaxBidAndWin(uint256 _max_bid_k, uint256 _max_win_k) public onlyOwner {

	    max_bid_k = _max_bid_k;
	    max_win_k = _max_win_k;
	}
	
	function setChip(uint256 _chip_id, uint256 _vol) public onlyOwner {

	    chips[_chip_id] = _vol;
	    if (_chip_id == 1) {
	        min_bid_vol = _vol;
	    }
	}
	
	function onTransferTokens(address _from, address _to, uint256 _value) public returns (bool) {

	    require( msg.sender == address(baex), "You don't have permission to call it" );
	    if ( _to == address(this) ) {
	        _placeLiquidity( _from, _value, false );
	    }
	}
	
	function transferWrongSendedERC20FromContract(address _contract) public {

	    require( _contract != address(baex), "Transfer of BAEX token is fortradeen");
	    require( msg.sender == super_owner, "Your are not super owner");
	    IERC20(_contract).transfer( super_owner, IERC20(_contract).balanceOf(address(this)) );
	}
	
	receive() external payable  {
        msg.sender.transfer(msg.value);
	}
	
}

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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
pragma solidity >=0.6.0 <0.8.0;


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
}