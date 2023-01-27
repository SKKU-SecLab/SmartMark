
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity 0.8.11;

interface IJaxAdmin {


  function userIsAdmin (address _user) external view returns (bool);
  function userIsGovernor (address _user) external view returns (bool);
  function userIsAjaxPrime (address _user) external view returns (bool);
  function userIsOperator (address _user) external view returns (bool);
  function jaxSwap() external view returns (address);

  function system_status () external view returns (uint);
  function electGovernor (address _governor) external;  
  function blacklist(address _user) external view returns (bool);

  function priceImpactLimit() external view returns (uint);

}// MIT

pragma solidity 0.8.11;


interface IPancakeFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;


    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

}


interface IPancakePair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface IPancakeRouter01 {

    function factory() external view returns (address);

    function WETH() external view returns (address);


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

}// MIT

pragma solidity 0.8.11;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.8.11;

contract JaxOwnable {


  address public owner;
  address public new_owner;
  uint public new_owner_locktime;
  
  event Set_New_Owner(address newOwner, uint newOwnerLocktime);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {

      require(owner == msg.sender, "JaxOwnable: caller is not the owner");
      _;
  }

  function setNewOwner(address newOwner) external onlyOwner {

    require(newOwner != address(0x0), "New owner cannot be zero address");
    new_owner = newOwner;
    new_owner_locktime = block.timestamp + 2 days;
    emit Set_New_Owner(newOwner, new_owner_locktime);
  }

  function updateOwner() external {

    require(msg.sender == new_owner, "Only new owner");
    require(block.timestamp >= new_owner_locktime, "New admin is not unlocked yet");
    _transferOwnership(new_owner);
    new_owner = address(0x0);
  }

  function renounceOwnership() external onlyOwner {

    _transferOwnership(address(0));
  }

  function _transferOwnership(address newOwner) internal virtual {

    address oldOwner = owner;
    owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}// MIT
 pragma solidity ^0.8.11;


library JaxLibrary {


  function swapWithPriceImpactLimit(address router, uint amountIn, uint limit, address[] memory path, address to) internal returns(uint[] memory) {

    IPancakeRouter01 pancakeRouter = IPancakeRouter01(router);
    
    IPancakePair pair = IPancakePair(IPancakeFactory(pancakeRouter.factory()).getPair(path[0], path[1]));
    (uint res0, uint res1, ) = pair.getReserves();
    uint reserveIn;
    uint reserveOut;
    if(pair.token0() == path[0]) {
      reserveIn = res0;
      reserveOut = res1;
    } else {
      reserveIn = res1;
      reserveOut = res0;
    }
    uint amountOut = pancakeRouter.getAmountOut(amountIn, reserveIn, reserveOut);
    require(reserveOut * 1e36 * (1e8 - limit) / 1e8 / reserveIn <= amountOut * 1e36 / amountIn, "Price Impact too high");
    return pancakeRouter.swapExactTokensForTokens(amountIn, 0, path, to, block.timestamp);
  }
}// MIT

pragma solidity 0.8.11;

contract JaxProtection {


    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    modifier runProtection() {

        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
        protection.sender = msg.sender;
        protection.data_hash = keccak256(msg.data);
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return;
        }
        require(protection.executed == false, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 2 days, "Running is Locked");
        _;
        protection.executed = true;
    }
}// MIT

pragma solidity 0.8.11;


interface IYield {

    function deposit_reward(uint amount) external;

}

contract TxFeeWallet is Initializable, JaxOwnable, JaxProtection {


    using JaxLibrary for TxFeeWallet;

    event Set_Jax_Admin(address old_jax_admin, address new_jax_admin);
    event Set_Yield_Tokens(address[] tokens);
    event Set_Reward_Token(address rewardToken);
    event Set_Yield_Info(YieldInfo[] info);
    event Pay_Yield();    
    event Swap_Tokens(address[] tokens);
    event Withdraw_By_Admin(address token, uint amount);

    struct YieldInfo {
        uint allocPoint; // How many allocation points assigned to this yield
        address yield_address;
        bool isContract;
    }

    uint256 public constant totalAllocPoint = 1000;

    address[] public yieldTokens;

    YieldInfo[] public yieldInfo;

    address public rewardToken;
    IJaxAdmin public jaxAdmin;

    address public pancakeRouter;

    modifier onlyAdmin() {

        require(jaxAdmin.userIsAdmin(msg.sender) || msg.sender == owner, "Only Admin can perform this operation.");
        _;
    }

    modifier onlyGovernor() {

        require(jaxAdmin.userIsGovernor(msg.sender), "Only Governor can perform this operation.");
        _;
    }

    modifier checkZeroAddress(address account) {

        require(account != address(0x0), "Only non-zero address");
        _;
    }

    constructor() initializer {}

    function initialize(address _admin_address, address _pancakeRouter, address _rewardToken) public initializer 
        checkZeroAddress(_admin_address) checkZeroAddress(_pancakeRouter) checkZeroAddress(_rewardToken)
    {

        jaxAdmin = IJaxAdmin(_admin_address);
        pancakeRouter = _pancakeRouter; // 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3
        rewardToken = _rewardToken;
        owner = msg.sender;
    }

    function set_yield_info(YieldInfo[] calldata newYieldInfo) public onlyGovernor {

        delete yieldInfo;
        uint yieldLength = newYieldInfo.length;
        uint sumAllocPoint;
        for (uint i=0; i < yieldLength; i++) {
            YieldInfo memory yield = newYieldInfo[i];
            sumAllocPoint += yield.allocPoint;
            yieldInfo.push(yield);
            if(yield.isContract) {
                require(IERC20(rewardToken).approve(yield.yield_address, type(uint).max), "reward token yield approval failed)");
            }
        }
        require(sumAllocPoint == totalAllocPoint, "sum of alloc point should be 1000");
        emit Set_Yield_Info(newYieldInfo);
    }

    function set_yield_tokens(address[] calldata newYieldTokens) public onlyGovernor {

        delete yieldTokens;
        uint tokenLength = newYieldTokens.length;
        for (uint i=0; i < tokenLength; i++) {
            yieldTokens.push(newYieldTokens[i]);
            require(IERC20(newYieldTokens[i]).approve(pancakeRouter, type(uint256).max), "yield token pancake router approval failed");
        }
        emit Set_Yield_Tokens(newYieldTokens);
    }

    function set_reward_token(address _rewardToken) public checkZeroAddress(_rewardToken) onlyGovernor {

        rewardToken = _rewardToken;
        emit Set_Reward_Token(_rewardToken);
    }

    function pay_yield() public onlyGovernor {

        _swap_tokens(3e6); // 3%
        uint yieldLength = yieldInfo.length;
        uint tokenBalance = IERC20(rewardToken).balanceOf(address(this));
        for (uint i=0; i < yieldLength; i++) {
            YieldInfo memory yield = yieldInfo[i];
            if(yield.isContract) {
                IYield(yield.yield_address).deposit_reward(tokenBalance * yield.allocPoint / totalAllocPoint);
            } else {
                IERC20(rewardToken).transfer(yield.yield_address, tokenBalance * yield.allocPoint / totalAllocPoint);
            }
        }
        emit Pay_Yield();
    }

    function swap_tokens(uint slippage) external onlyGovernor {

        _swap_tokens(slippage);
    }

    function _swap_tokens(uint slippage) internal { // slippage has 8 decimals

        uint tokenCount = yieldTokens.length;
        for(uint i = 0; i < tokenCount; i++) {
            uint amountIn = IERC20(yieldTokens[i]).balanceOf(address(this));
            if(amountIn == 0) continue;
            _swap_specific_token(i, amountIn, slippage);
        }
        emit Swap_Tokens(yieldTokens);
    }

    function swap_specific_token(uint tokenId, uint amountIn, uint slippage) external onlyGovernor returns(uint){

        return _swap_specific_token(tokenId, amountIn, slippage);
    }

    function _swap_specific_token(uint tokenId, uint amountIn, uint slippage) internal returns(uint){

        require(tokenId < yieldTokens.length, "Invalid token id");
        if(amountIn == 0) {
            amountIn = IERC20(yieldTokens[tokenId]).balanceOf(address(this));
        }
        address yieldToken = yieldTokens[tokenId];
        address[] memory path = new address[](2);
        path[0] = yieldToken;
        path[1] = rewardToken;
        require(amountIn <= IERC20(yieldToken).balanceOf(address(this)), "Insufficient yield token in this contract");
        uint[] memory amounts = JaxLibrary.swapWithPriceImpactLimit(pancakeRouter, amountIn, slippage, path, address(this));
        return amounts[1];
    }

    function withdrawByAdmin(address token, uint amount) external onlyAdmin runProtection {

        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
    }

    function setJaxAdmin(address newJaxAdmin) external onlyAdmin runProtection {

        address oldJaxAdmin = address(jaxAdmin);
        jaxAdmin = IJaxAdmin(newJaxAdmin);
        require(jaxAdmin.system_status() >= 0, "Invalid jax admin");
        emit Set_Jax_Admin(oldJaxAdmin, newJaxAdmin);
    }

}