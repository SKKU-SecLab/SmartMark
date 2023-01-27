pragma solidity ^0.5.0;


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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
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

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract IOneSplitConsts {

    uint256 internal constant FLAG_DISABLE_UNISWAP = 0x01;
    uint256 internal constant DEPRECATED_FLAG_DISABLE_KYBER = 0x02; // Deprecated
    uint256 internal constant FLAG_DISABLE_BANCOR = 0x04;
    uint256 internal constant FLAG_DISABLE_OASIS = 0x08;
    uint256 internal constant FLAG_DISABLE_COMPOUND = 0x10;
    uint256 internal constant FLAG_DISABLE_FULCRUM = 0x20;
    uint256 internal constant FLAG_DISABLE_CHAI = 0x40;
    uint256 internal constant FLAG_DISABLE_AAVE = 0x80;
    uint256 internal constant FLAG_DISABLE_SMART_TOKEN = 0x100;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_ETH = 0x200; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_BDAI = 0x400;
    uint256 internal constant FLAG_DISABLE_IEARN = 0x800;
    uint256 internal constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
    uint256 internal constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 internal constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 internal constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_DAI = 0x10000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDC = 0x20000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 internal constant FLAG_DISABLE_WETH = 0x80000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_COMPOUND = 0x100000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_CHAI = 0x200000; // Works only when ETH<>DAI or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_AAVE = 0x400000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_IDLE = 0x800000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP = 0x1000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2 = 0x2000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ETH = 0x4000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_DAI = 0x8000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_USDC = 0x10000000;
    uint256 internal constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x20000000;
    uint256 internal constant FLAG_DISABLE_ALL_WRAP_SOURCES = 0x40000000;
    uint256 internal constant FLAG_DISABLE_CURVE_PAX = 0x80000000;
    uint256 internal constant FLAG_DISABLE_CURVE_RENBTC = 0x100000000;
    uint256 internal constant FLAG_DISABLE_CURVE_TBTC = 0x200000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDT = 0x400000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_WBTC = 0x800000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_TBTC = 0x1000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_RENBTC = 0x2000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_DFORCE_SWAP = 0x4000000000;
    uint256 internal constant FLAG_DISABLE_SHELL = 0x8000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN = 0x10000000000;
    uint256 internal constant FLAG_DISABLE_MSTABLE_MUSD = 0x20000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_SBTC = 0x40000000000;
    uint256 internal constant FLAG_DISABLE_DMM = 0x80000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_ALL = 0x100000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_ALL = 0x200000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ALL = 0x400000000000;
    uint256 internal constant FLAG_DISABLE_SPLIT_RECALCULATION = 0x800000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_ALL = 0x1000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_1 = 0x2000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_2 = 0x4000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_3 = 0x8000000000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_UNISWAP_RESERVE = 0x10000000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_OASIS_RESERVE = 0x20000000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_BANCOR_RESERVE = 0x40000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_ENABLE_REFERRAL_GAS_SPONSORSHIP = 0x80000000000000; // Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_COMP = 0x100000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_KYBER_ALL = 0x200000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_1 = 0x400000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_2 = 0x800000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_3 = 0x1000000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_4 = 0x2000000000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN_BY_ORIGIN = 0x4000000000000000;
}


contract IOneSplit is IOneSplitConsts {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        external
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );


    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        external
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );


    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags
    )
        external
        payable
        returns(uint256 returnAmount);

}


contract IOneSplitMulti is IOneSplit {

    function getExpectedReturnWithGasMulti(
        IERC20[] calldata tokens,
        uint256 amount,
        uint256[] calldata parts,
        uint256[] calldata flags,
        uint256[] calldata destTokenEthPriceTimesGasPrices
    )
        external
        view
        returns(
            uint256[] memory returnAmounts,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );


    function swapMulti(
        IERC20[] calldata tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256[] calldata flags
    )
        external
        payable
        returns(uint256 returnAmount);

}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    function __init() internal {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}pragma solidity 0.5.17;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}pragma solidity 0.5.17;



interface IOracle{

	function getiTokenDetails(uint _poolIndex) external returns(string memory, string memory,string memory); 

     function getTokenDetails(uint _poolIndex) external returns(address[] memory,uint[] memory,uint ,uint);

}

interface Iitokendeployer{

	function createnewitoken(string calldata _name, string calldata _symbol) external returns(address);

}

interface Iitoken{

	function mint(address account, uint256 amount) external returns (bool);

	function burn(address account, uint256 amount) external returns (bool);

	function balanceOf(address account) external view returns (uint256);

	function totalSupply() external view returns (uint256);

}

interface IMAsterChef{

	function depositFromDaaAndDAO(uint256 _pid, uint256 _amount, uint256 vault, address _sender,bool isPremium) external;

	function distributeExitFeeShare(uint256 _amount) external;

}

interface IPoolConfiguration{

	 function checkDao(address daoAddress) external returns(bool);

	 function getperformancefees() external view returns(uint256);

	 function getmaxTokenSupported() external view returns(uint256);

	 function getslippagerate() external view returns(uint256);

	 function getoracleaddress() external view returns(address);

	 function getEarlyExitfees() external view returns(uint256);

	 function checkStableCoin(address _stable) external view returns(bool);

}

contract PoolV1 is ReentrancyGuard,Initializable {

    
    using SafeMath for uint;
	using SafeERC20 for IERC20;

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

	address public EXCHANGE_CONTRACT = 0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e;
	address public WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	address public baseStableCoin = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

	address public ASTRTokenAddress;
	address public managerAddresses;
	address public _poolConf;
	address public poolChef;
    address public itokendeployer;
	struct PoolInfo {
        address[] tokens;    
        uint256[]  weights;        
        uint256 totalWeight;
        bool active; 
        uint256 rebaltime;
        uint256 threshold;
        uint256 currentRebalance;
        uint256 lastrebalance;
		address itokenaddr;
		address owner;
		string description;
    }
    struct PoolUser 
    {   
        uint256 currentBalance;
        uint256 currentPool; 
        uint256 pendingBalance; 
		uint256 USDTdeposit;
		uint256 Itokens;
        bool active;
        bool isenabled;
    } 
    
    mapping ( uint256 =>mapping(address => PoolUser)) public poolUserInfo; 

    PoolInfo[] public poolInfo;
    
    uint256[] private buf; 
    
    
    address[] private _TokensStable;
    uint256[] private _ValuesStable;

	mapping(uint256 => mapping(address => uint256)) public tokenBalances;
	mapping(uint256 => uint256) public totalPoolbalance;
	mapping(uint256 => uint256) public poolPendingbalance;
	mapping(address =>mapping (uint256 => uint256)) public initialDeposit;
	mapping(address =>mapping (uint256 => bool)) public existingUser;

	bool public active = true; 

	mapping(address => bool) public systemAddresses;
	
	modifier systemOnly {

	    require(systemAddresses[msg.sender], "EO1");
	    _;
	}

	event Transfer(address indexed src, address indexed dst, uint wad);
	event Withdrawn(address indexed from, uint value);
	event WithdrawnToken(address indexed from, address indexed token, uint amount);
	
	
	function initialize(address _ASTRTokenAddress, address poolConfiguration,address _itokendeployer, address _chef) public initializer{

		require(_ASTRTokenAddress != address(0), "E15");
		require(poolConfiguration != address(0), "E15");
		require(_itokendeployer != address(0), "E15");
		require(_chef != address(0), "E15");
		ReentrancyGuard.__init();
		systemAddresses[msg.sender] = true;
		ASTRTokenAddress = _ASTRTokenAddress;
		managerAddresses = msg.sender;
		_poolConf = poolConfiguration;
		itokendeployer = _itokendeployer;
		poolChef = _chef;
	}
	
     

    function whitelistaddress(address _address, uint _poolIndex) external {

		require(_address != address(0), "E15");
		require(_poolIndex<poolInfo.length, "E02");
	    require(!poolUserInfo[_poolIndex][_address].active,"E03");
		if(poolInfo[_poolIndex].owner == address(this)){
			require(managerAddresses == msg.sender, "E04");
		}else{
			require(poolInfo[_poolIndex].owner == msg.sender, "E05");
		}
	    PoolUser memory newPoolUser = PoolUser(0, poolInfo[_poolIndex].currentRebalance,0,0,0,true,true);
        poolUserInfo[_poolIndex][_address] = newPoolUser;
	}

	function calculateTotalWeight(uint[] memory _weights) internal view returns(uint){

		uint _totalWeight;
		for(uint i = 0; i < _weights.length; i++) {
			_totalWeight = _totalWeight.add(_weights[i]);
		}
		return _totalWeight;
	}
	function addPublicPool(address[] memory _tokens, uint[] memory _weights,uint _threshold,uint _rebalanceTime,string memory _name,string memory _symbol,string memory _description) public{

		address _itokenaddr;
		address _poolOwner;
		uint _poolIndex = poolInfo.length;
		address _OracleAddress = IPoolConfiguration(_poolConf).getoracleaddress();

		if(_tokens.length == 0){
			require(systemAddresses[msg.sender], "EO1");
			(_tokens, _weights,_threshold,_rebalanceTime) = IOracle(_OracleAddress).getTokenDetails(_poolIndex);
		    (_name,_symbol,_description) = IOracle(_OracleAddress).getiTokenDetails(_poolIndex);
			_poolOwner = address(this);
		}else{
			_poolOwner = msg.sender;
		}

		require (_tokens.length == _weights.length, "E06");
        require (_tokens.length <= IPoolConfiguration(_poolConf).getmaxTokenSupported(), "E16");
        _itokenaddr = Iitokendeployer(itokendeployer).createnewitoken(_name, _symbol);
		
		poolInfo.push(PoolInfo({
            tokens : _tokens,   
            weights : _weights,        
            totalWeight : calculateTotalWeight(_weights),      
            active : true,          
            rebaltime : _rebalanceTime,
            currentRebalance : 0,
            threshold: _threshold,
            lastrebalance: block.timestamp,
		    itokenaddr: _itokenaddr,
			owner: _poolOwner,
			description:_description
        }));
    }

	function buyAstraToken(uint _Amount) internal returns(uint256){ 

		uint _amount;
		uint[] memory _distribution;
		IERC20(baseStableCoin).approve(EXCHANGE_CONTRACT, _Amount);
	 	(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(baseStableCoin), IERC20(ASTRTokenAddress), _Amount, 2, 0);
		uint256 minReturn = calculateMinimumReturn(_amount);
		IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(baseStableCoin), IERC20(ASTRTokenAddress), _Amount, minReturn, _distribution, 0);
		return _amount;
	}

	function stakeAstra(uint _amount,bool premium)internal{

		IERC20(ASTRTokenAddress).approve(address(poolChef),_amount);
		IMAsterChef(poolChef).depositFromDaaAndDAO(0,_amount,6,msg.sender,premium);
	}	


	 function calculatefee(address _account, uint _amount,uint _poolIndex)internal returns(uint256){

		 uint256 feeRate = IPoolConfiguration(_poolConf).getEarlyExitfees();
		 uint256 startBlock = initialDeposit[_account][_poolIndex];
		 uint256 withdrawBlock = block.number;
		 uint256 Averageblockperday = 6500;
		 uint256 feeconstant = 182;
		 uint256 blocks = withdrawBlock.sub(startBlock);
		 uint feesValue = feeRate.mul(blocks).div(100);
		 feesValue = feesValue.div(Averageblockperday).div(feeconstant);
		 feesValue = _amount.mul(feeRate).div(100).sub(feesValue);
		 return feesValue;
	 }
		
    function buytokens(uint _poolIndex) internal {

     require(_poolIndex<poolInfo.length, "E02");
     address[] memory returnedTokens;
	 uint[] memory returnedAmounts;
     uint ethValue = poolPendingbalance[_poolIndex]; 
     uint[] memory buf3;
	 buf = buf3;
     (returnedTokens, returnedAmounts) = swap2(baseStableCoin, ethValue, poolInfo[_poolIndex].tokens, poolInfo[_poolIndex].weights, poolInfo[_poolIndex].totalWeight,buf);
      for (uint i = 0; i < returnedTokens.length; i++) {
			tokenBalances[_poolIndex][returnedTokens[i]] = tokenBalances[_poolIndex][returnedTokens[i]].add(returnedAmounts[i]);
	  }
	  totalPoolbalance[_poolIndex] = totalPoolbalance[_poolIndex].add(ethValue);
	  poolPendingbalance[_poolIndex] = 0;
	  if (poolInfo[_poolIndex].currentRebalance == 0){
	      poolInfo[_poolIndex].currentRebalance = poolInfo[_poolIndex].currentRebalance.add(1);
	  }
		
    }

    
    function updateuserinfo(uint _amount,uint _poolIndex) internal { 

        if(poolUserInfo[_poolIndex][msg.sender].active){
            if(poolUserInfo[_poolIndex][msg.sender].currentPool < poolInfo[_poolIndex].currentRebalance){
                poolUserInfo[_poolIndex][msg.sender].currentBalance = poolUserInfo[_poolIndex][msg.sender].currentBalance.add(poolUserInfo[_poolIndex][msg.sender].pendingBalance);
                poolUserInfo[_poolIndex][msg.sender].currentPool = poolInfo[_poolIndex].currentRebalance;
                poolUserInfo[_poolIndex][msg.sender].pendingBalance = _amount;
            }
            else{
               poolUserInfo[_poolIndex][msg.sender].pendingBalance = poolUserInfo[_poolIndex][msg.sender].pendingBalance.add(_amount); 
            }
        }
       
    } 

    function getIndexTokenDetails(uint _poolIndex) external view returns(address[] memory){

        return (poolInfo[_poolIndex].tokens);
    }

    function getIndexWeightDetails(uint _poolIndex) external view returns(uint[] memory){

        return (poolInfo[_poolIndex].weights);
    }

	function calculateMinimumReturn(uint _amount) internal view returns (uint){

		uint256 sliprate= IPoolConfiguration(_poolConf).getslippagerate();
        uint rate = _amount.mul(sliprate).div(100);
		return _amount.sub(rate);
        
    }
	function getItokenValue(uint256 outstandingValue, uint256 indexValue, uint256 depositValue, uint256 totalDepositValue) public view returns(uint256){

		if(indexValue == uint(0)){
			return depositValue;
		}else if(outstandingValue>0){
			return depositValue.mul(outstandingValue).div(indexValue);
		}
		else{
			return depositValue;
		}
	}

	function poolIn(address[] calldata _tokens, uint[] calldata _values, uint _poolIndex) external payable nonReentrant {

		require(poolUserInfo[_poolIndex][msg.sender].isenabled, "E07");
		require(_poolIndex<poolInfo.length, "E02");
		require(_tokens.length <2 && _values.length<2, "E08");
		if(!existingUser[msg.sender][_poolIndex]){
			existingUser[msg.sender][_poolIndex] = true;
			initialDeposit[msg.sender][_poolIndex] = block.number;
		}

		uint ethValue;
		uint fees;
		uint stableValue;
		address[] memory returnedTokens;
	    uint[] memory returnedAmounts;
	    
	    _TokensStable = returnedTokens;
	    _ValuesStable = returnedAmounts;
		if(_tokens.length == 0) {
			require (msg.value > 0.001 ether, "E09");

			ethValue = msg.value;
			_TokensStable.push(baseStableCoin);
			_ValuesStable.push(1);
    	    (returnedTokens, returnedAmounts) = swap(ETH_ADDRESS, ethValue, _TokensStable, _ValuesStable, 1);
    	    stableValue = returnedAmounts[0];
     
		} else {
			require(IPoolConfiguration(_poolConf).checkStableCoin(_tokens[0]) == true,"E10");
			require(IERC20(_tokens[0]).balanceOf(msg.sender) >= _values[0], "E11");

			if(address(_tokens[0]) == address(baseStableCoin)){
				
				stableValue = _values[0];
				IERC20(baseStableCoin).safeTransferFrom(msg.sender,address(this),stableValue);
			}else{
                IERC20(_tokens[0]).safeTransferFrom(msg.sender,address(this),_values[0]);
			    stableValue = sellTokensForStable(_tokens, _values); 
			}
			require(stableValue > 0.001 ether,"E09");			
		}

		uint256 ItokenValue = getItokenValue(Iitoken(poolInfo[_poolIndex].itokenaddr).totalSupply(), getPoolValue(_poolIndex), stableValue, totalPoolbalance[_poolIndex]);	
		 poolPendingbalance[_poolIndex] = poolPendingbalance[_poolIndex].add(stableValue);
		 uint checkbalance = totalPoolbalance[_poolIndex].add(poolPendingbalance[_poolIndex]);
		 poolUserInfo[_poolIndex][msg.sender].Itokens = poolUserInfo[_poolIndex][msg.sender].Itokens.add(ItokenValue);
		 updateuserinfo(stableValue,_poolIndex);

		  if (poolInfo[_poolIndex].currentRebalance == 0){
		     if(poolInfo[_poolIndex].threshold <= checkbalance){
		        buytokens( _poolIndex);
		     }     
		  }
		updateuserinfo(0,_poolIndex);
		Iitoken(poolInfo[_poolIndex].itokenaddr).mint(msg.sender, ItokenValue);
	}


	function withdraw(uint _poolIndex, bool stakeEarlyFees,bool stakePremium, uint withdrawAmount) external nonReentrant{

	    require(_poolIndex<poolInfo.length, "E02");
		require(Iitoken(poolInfo[_poolIndex].itokenaddr).balanceOf(msg.sender)>=withdrawAmount, "E11");
		updateuserinfo(0,_poolIndex);
		uint userShare = poolUserInfo[_poolIndex][msg.sender].currentBalance.add(poolUserInfo[_poolIndex][msg.sender].pendingBalance).mul(withdrawAmount).div(poolUserInfo[_poolIndex][msg.sender].Itokens);
		uint _balance;
		uint _pendingAmount;

		if(userShare>poolUserInfo[_poolIndex][msg.sender].pendingBalance){
			_balance = userShare.sub(poolUserInfo[_poolIndex][msg.sender].pendingBalance);
			_pendingAmount = poolUserInfo[_poolIndex][msg.sender].pendingBalance;
		}else{
			_pendingAmount = userShare;
		}
		uint256 _totalAmount = withdrawTokens(_poolIndex,_balance);
		uint fees;
		uint256 earlyfees;
		uint256 pendingEarlyfees;
		if(_totalAmount>_balance){
			fees = _totalAmount.sub(_balance).mul(IPoolConfiguration(_poolConf).getperformancefees()).div(100);
		}
         
		earlyfees = earlyfees.add(calculatefee(msg.sender,_totalAmount.sub(fees),_poolIndex));
		pendingEarlyfees =calculatefee(msg.sender,_pendingAmount,_poolIndex);
		poolUserInfo[_poolIndex][msg.sender].Itokens = poolUserInfo[_poolIndex][msg.sender].Itokens.sub(withdrawAmount);
        poolPendingbalance[_poolIndex] = poolPendingbalance[_poolIndex].sub( _pendingAmount);
        poolUserInfo[_poolIndex][msg.sender].pendingBalance = poolUserInfo[_poolIndex][msg.sender].pendingBalance.sub(_pendingAmount);
        totalPoolbalance[_poolIndex] = totalPoolbalance[_poolIndex].sub(_balance);
		poolUserInfo[_poolIndex][msg.sender].currentBalance = poolUserInfo[_poolIndex][msg.sender].currentBalance.sub(_balance);
		Iitoken(poolInfo[_poolIndex].itokenaddr).burn(msg.sender, withdrawAmount);
		withdrawUserAmount(_poolIndex,fees,_totalAmount.sub(fees).sub(earlyfees),_pendingAmount.sub(pendingEarlyfees),earlyfees.add(pendingEarlyfees),stakeEarlyFees,stakePremium);
		emit Withdrawn(msg.sender, _balance);
	}
	function withdrawUserAmount(uint _poolIndex,uint fees,uint totalAmount,uint _pendingAmount, uint earlyfees,bool stakeEarlyFees,bool stakePremium) internal{

		if(stakeEarlyFees == true){
			uint returnAmount= buyAstraToken(earlyfees);
			stakeAstra(returnAmount,false);
		}else{
			fees = fees.add(earlyfees);
		}

		if(stakePremium == true){
            uint returnAmount= buyAstraToken(totalAmount);
			stakeAstra(returnAmount,true);
		}
		else{
			transferTokens(baseStableCoin,msg.sender,totalAmount);
		}
		transferTokens(baseStableCoin,msg.sender,_pendingAmount);

        if(fees>0){
		uint distribution = fees.mul(80).div(100);
			if(poolInfo[_poolIndex].owner==address(this)){
				transferTokens(baseStableCoin,managerAddresses,distribution);
			}else{
				transferTokens(baseStableCoin,poolInfo[_poolIndex].owner,distribution);
			}
			uint returnAmount= buyAstraToken(fees.sub(distribution));
			transferTokens(ASTRTokenAddress,address(poolChef),returnAmount);
			IMAsterChef(poolChef).distributeExitFeeShare(returnAmount);
		}
	}

	function transferTokens(address _token, address _reciever,uint _amount) internal{

		IERC20(_token).safeTransfer(_reciever, _amount);
	}


	function withdrawTokens(uint _poolIndex,uint _balance) internal returns(uint256){

		uint localWeight;

		if(totalPoolbalance[_poolIndex]>0){
			localWeight = _balance.mul(1 ether).div(totalPoolbalance[_poolIndex]);
		}  
		
		uint _totalAmount;

		for (uint i = 0; i < poolInfo[_poolIndex].tokens.length; i++) {
			uint _amount;
		    uint[] memory _distribution;
			uint tokenBalance = tokenBalances[_poolIndex][poolInfo[_poolIndex].tokens[i]];
		    uint withdrawBalance = tokenBalance.mul(localWeight).div(1 ether);
		    if (withdrawBalance == 0) {
		        continue;
		    }
		    if (poolInfo[_poolIndex].tokens[i] == baseStableCoin) {
		        _totalAmount = _totalAmount.add(withdrawBalance);
		        continue;
		    }
		    IERC20(poolInfo[_poolIndex].tokens[i]).approve(EXCHANGE_CONTRACT, withdrawBalance);
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(poolInfo[_poolIndex].tokens[i]), IERC20(baseStableCoin), withdrawBalance, 2, 0);
			if (_amount == 0) {
		        continue;
		    }
		    _totalAmount = _totalAmount.add(_amount);
			tokenBalances[_poolIndex][poolInfo[_poolIndex].tokens[i]] = tokenBalance.sub(withdrawBalance);
			IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(poolInfo[_poolIndex].tokens[i]), IERC20(baseStableCoin), withdrawBalance, _amount, _distribution, 0);
		}
		return _totalAmount;
	}


	function withdrawPendingAmount(uint256 _poolIndex,uint _pendingAmount)internal returns(uint256){

		uint _earlyfee;
         if(_pendingAmount>0){
		 _earlyfee = calculatefee(msg.sender,_pendingAmount,_poolIndex);
		 IERC20(baseStableCoin).safeTransfer(msg.sender, _pendingAmount.sub(_earlyfee));
		}
		return _earlyfee;
	}

	function updatePool(address[] memory _tokens,uint[] memory _weights,uint _threshold,uint _rebalanceTime,uint _poolIndex) public nonReentrant{	    

	    require(block.timestamp >= poolInfo[_poolIndex].rebaltime,"E12");
		if(poolInfo[_poolIndex].owner != address(this)){
		    require(_tokens.length == _weights.length, "E02");
			require(poolInfo[_poolIndex].owner == msg.sender, "E13");
		}else{
			(_tokens, _weights,_threshold,_rebalanceTime) = IOracle(IPoolConfiguration(_poolConf).getoracleaddress()).getTokenDetails(_poolIndex);
		}
		require (_tokens.length <= IPoolConfiguration(_poolConf).getmaxTokenSupported(), "E16");

	    address[] memory newTokens;
	    uint[] memory newWeights;
	    uint newTotalWeight;
		
		uint _newTotalWeight;

		for(uint i = 0; i < _tokens.length; i++) {
			require (_tokens[i] != ETH_ADDRESS && _tokens[i] != WETH_ADDRESS);			
			_newTotalWeight = _newTotalWeight.add(_weights[i]);
		}
		
		newTokens = _tokens;
		newWeights = _weights;
		newTotalWeight = _newTotalWeight;
		poolInfo[_poolIndex].threshold = _threshold;
		poolInfo[_poolIndex].rebaltime = _rebalanceTime;
		rebalance(newTokens, newWeights,newTotalWeight,_poolIndex);
		

		if(poolPendingbalance[_poolIndex]>0){
		 buytokens(_poolIndex);   
		}
		
	}

	function setPoolStatus(address _exchange, address _weth, address _stable) external systemOnly {

		EXCHANGE_CONTRACT = _exchange;
	    WETH_ADDRESS = _weth;
	    baseStableCoin = _stable;

	}	
	

	function rebalance(address[] memory newTokens, uint[] memory newWeights,uint newTotalWeight, uint _poolIndex) internal {

	    require(poolInfo[_poolIndex].currentRebalance >0, "E14");
		uint[] memory buf2;
		buf = buf2;
		uint ethValue;
		address[] memory returnedTokens;
	    uint[] memory returnedAmounts;

		for (uint i = 0; i < poolInfo[_poolIndex].tokens.length; i++) {
			buf.push(tokenBalances[_poolIndex][poolInfo[_poolIndex].tokens[i]]);
			tokenBalances[_poolIndex][poolInfo[_poolIndex].tokens[i]] = 0;
		}
		
		if(totalPoolbalance[_poolIndex]>0){
		 ethValue = sellTokensForStable(poolInfo[_poolIndex].tokens, buf);   
		}

		poolInfo[_poolIndex].tokens = newTokens;
		poolInfo[_poolIndex].weights = newWeights;
		poolInfo[_poolIndex].totalWeight = newTotalWeight;
		poolInfo[_poolIndex].currentRebalance = poolInfo[_poolIndex].currentRebalance.add(1);
		poolInfo[_poolIndex].lastrebalance = block.timestamp;
		
		if (ethValue == 0) {
		    return;
		}
		
		uint[] memory buf3;
		buf = buf3;
		
		if(totalPoolbalance[_poolIndex]>0){
		 (returnedTokens, returnedAmounts) = swap2(baseStableCoin, ethValue, newTokens, newWeights,newTotalWeight,buf);
		for(uint i = 0; i < poolInfo[_poolIndex].tokens.length; i++) {
			tokenBalances[_poolIndex][poolInfo[_poolIndex].tokens[i]] = buf[i];
	    	
		}  
		}
		
	}


	function getPoolValue(uint256 _poolIndex)public view returns(uint256){

		uint _amount;
		uint[] memory _distribution;
		uint _totalAmount;

		for (uint i = 0; i < poolInfo[_poolIndex].tokens.length; i++) {
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(poolInfo[_poolIndex].tokens[i]), IERC20(baseStableCoin), tokenBalances[_poolIndex][poolInfo[_poolIndex].tokens[i]], 2, 0);
			if (_amount == 0) {
		        continue;
		    }
		    _totalAmount = _totalAmount.add(_amount);
		}

		return _totalAmount;
	}


	function swap(address _token, uint _value, address[] memory _tokens, uint[] memory _weights, uint _totalWeight) internal returns(address[] memory, uint[] memory) {

		uint _tokenPart;
		uint _amount;
		uint[] memory _distribution;
		for(uint i = 0; i < _tokens.length; i++) { 
		    _tokenPart = _value.mul(_weights[i]).div(_totalWeight);

			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_token), IERC20(_tokens[i]), _tokenPart, 2, 0);
			uint256 minReturn = calculateMinimumReturn(_amount);
		    _weights[i] = _amount;

			if (_token == ETH_ADDRESS) {
				_amount = IOneSplit(EXCHANGE_CONTRACT).swap.value(_tokenPart)(IERC20(_token), IERC20(_tokens[i]), _tokenPart, minReturn, _distribution, 0);
			} else {
			    IERC20(_tokens[i]).approve(EXCHANGE_CONTRACT, _tokenPart);
				_amount = IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(_token), IERC20(_tokens[i]), _tokenPart, minReturn, _distribution, 0);
			}
			
		}
		
		return (_tokens, _weights);
	}

	
	function swap2(address _token, uint _value, address[] memory newTokens, uint[] memory newWeights,uint newTotalWeight, uint[] memory _buf) internal returns(address[] memory, uint[] memory) {

		uint _tokenPart;
		uint _amount;
		buf = _buf;
		uint[] memory _distribution;
		IERC20(_token).approve(EXCHANGE_CONTRACT, _value);
		for(uint i = 0; i < newTokens.length; i++) {
            
			_tokenPart = _value.mul(newWeights[i]).div(newTotalWeight);
			
			if(_tokenPart == 0) {
			    buf.push(0);
			    continue;
			}
			
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_token), IERC20(newTokens[i]), _tokenPart, 2, 0);
			uint256 minReturn = calculateMinimumReturn(_amount);
			buf.push(_amount);
            newWeights[i] = _amount;
			_amount= IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(_token), IERC20(newTokens[i]), _tokenPart, minReturn, _distribution, 0);
		}
		return (newTokens, newWeights);
	}

	function sellTokensForStable(address[] memory _tokens, uint[] memory _amounts) internal returns(uint) {

		uint _amount;
		uint[] memory _distribution;

		uint _totalAmount;
		
		for(uint i = 0; i < _tokens.length; i++) {
		    if (_amounts[i] == 0) {
		        continue;
		    }
		    
		    if (_tokens[i] == baseStableCoin) {
		        _totalAmount = _totalAmount.add(_amounts[i]);
		        continue;
		    }

		    IERC20(_tokens[i]).approve(EXCHANGE_CONTRACT, _amounts[i]);
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_tokens[i]), IERC20(baseStableCoin), _amounts[i], 2, 0);
			if (_amount == 0) {
		        continue;
		    }
		    uint256 minReturn = calculateMinimumReturn(_amount);
		    _totalAmount = _totalAmount.add(_amount);
			_amount = IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(_tokens[i]), IERC20(baseStableCoin), _amounts[i], minReturn, _distribution, 0);

			
		}

		return _totalAmount;
	}

}