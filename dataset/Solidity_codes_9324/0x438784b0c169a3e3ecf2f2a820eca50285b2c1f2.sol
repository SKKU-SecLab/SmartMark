
pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

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
}pragma solidity 0.6.6;

interface IStrategiesWhitelist {

    function isWhitelisted(address _allocationStrategy) external returns (uint8 answer);

}pragma solidity 0.6.6;

interface IAllocationStrategy {

    function balanceOfUnderlying() external returns (uint256);

    function balanceOfUnderlyingView() external view returns(uint256);

    function investETH(uint256 _amountOutMin, uint256 _deadline) external payable returns (uint256);

    function investUnderlying(uint256 _investAmount, uint256 _deadline) external returns (uint256);

    function invest(address _tokenIn, uint256 _investAmount, uint256 _amountOutMin, uint256 _deadline) external returns (uint256);

    function redeemUnderlying(uint256 _redeemAmount) external returns (uint256);

    function redeemAll() external;

}pragma solidity 0.6.6;


contract Ownable {


    bytes32 constant public oSlot = keccak256("Ownable.storage.location");

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    struct os {
        address owner;
    }

    modifier onlyOwner(){

        require(msg.sender == los().owner, "Ownable.onlyOwner: msg.sender not owner");
        _;
    }

    function owner() public view returns(address) {

        return los().owner;
    }

    function transferOwnership(address _newOwner) onlyOwner external {

        _setOwner(_newOwner);
    }

    function _setOwner(address _newOwner) internal {

        emit OwnerChanged(los().owner, _newOwner);
        los().owner = _newOwner;
    }

    function los() internal pure returns (os storage s) {

        bytes32 loc = oSlot;
        assembly {
            s_slot := loc
        }
    }

}pragma solidity 0.6.6;

interface IUniswapV2Router {

    function WETH() external pure returns (address);


    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint[] memory amounts);


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


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}pragma solidity 0.6.6;


contract OTokenStorage {


    bytes32 constant public otSlot = keccak256("OToken.storage.location");

    struct ots {
        IAllocationStrategy allocationStrategy;
        IERC20 underlying;
        uint256 fee;
        uint256 lastTotalUnderlying;
        string name;
        string symbol;
        uint8 decimals;
        mapping(address => mapping(address => uint256)) internalAllowances;
        mapping(address => uint256) internalBalanceOf;
        uint256 internalTotalSupply;
        bool initialised;
        address admin;
        IStrategiesWhitelist strategiesWhitelist;
    }

    function allocationStrategy() external view returns(address) {

        return address(lots().allocationStrategy);
    }

    function admin() external view returns(address) {

        return lots().admin;
    }

    function strategiesWhitelist() external view returns(address) {

        return address(lots().strategiesWhitelist);
    }

    function underlying() external view returns(address) {

        return address(lots().underlying);
    }

    function fee() external view returns(uint256) {

        return lots().fee;
    }

    function lastTotalUnderlying() external view returns(uint256) {

        return lots().lastTotalUnderlying;
    }

    function name() external view returns(string memory) {

        return lots().name;
    }

    function symbol() external view returns(string memory) {

        return lots().symbol;
    }

    function decimals() external view returns(uint8) {

        return lots().decimals;
    }

    function internalBalanceOf(address _who) external view returns(uint256) {

        return lots().internalBalanceOf[_who];
    }

    function internalTotalSupply() external view returns(uint256) {

        return lots().internalTotalSupply;
    }

    function lots() internal pure returns(ots storage s) {

        bytes32 loc = otSlot;
        assembly {
            s_slot := loc
        }
    }
}pragma solidity 0.6.6;

contract ReentryProtection {


    bytes32 constant public rpSlot = keccak256("ReentryProtection.storage.location");

    struct rps {
        uint256 lockCounter;
    }

    modifier noReentry {

        lrps().lockCounter ++;
        uint256 lockValue = lrps().lockCounter;
        _;
        require(lockValue == lrps().lockCounter, "ReentryProtection.noReentry: reentry detected");
    }

    function lrps() internal pure returns (rps storage s) {

        bytes32 loc = rpSlot;
        assembly {
            s_slot := loc
        }
    }

}pragma solidity 0.6.6;


contract OToken is OTokenStorage, IERC20, Ownable, ReentryProtection {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MAX_FEE = 10**18 / 10;
    uint256 public constant INITIAL_EXCHANGE_RATE = 50 ether;
    uint256 public constant WITHDRAW_FEE = 10**18 / 200;

    event FeeChanged(address indexed owner, uint256 oldFee, uint256 newFee);
    event AllocationStrategyChanged(address indexed owner, address indexed oldAllocationStrategy, address indexed newAllocationStrategy);
    event Withdrawn(address indexed from, address indexed receiver, uint256 amount);
    event Deposited(address indexed from, address indexed receiver, uint256 amount);
    event AdminChanged(address newAdmin);

    function init(
        address _initialAllocationStrategy,
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        address _underlying,
        address _admin,
        address _strategiesWhitelist
    ) public  {

        ots storage s = lots();
        require(!s.initialised, "Already initialised");
        s.initialised = true;
        s.allocationStrategy = IAllocationStrategy(_initialAllocationStrategy);
        s.name = _name;
        s.symbol = _symbol;
        s.underlying = IERC20(_underlying);
        s.decimals = uint8(_decimals);
        s.admin = _admin;
        s.strategiesWhitelist = IStrategiesWhitelist(_strategiesWhitelist);
        _setOwner(msg.sender);
    }


    function depositETH(uint256 _amountOutMin, address _receiver, uint256 _deadline) external payable noReentry {

        ots storage s = lots();
        handleFeesInternal();
        uint256 strategyUnderlyingBalanceBefore = s.allocationStrategy.balanceOfUnderlying();
        uint256 amount = s.allocationStrategy.investETH{value: msg.value}(_amountOutMin, _deadline);
        _deposit(amount, _receiver, strategyUnderlyingBalanceBefore);
    }


    function depositUnderlying(uint256 _amount, address _receiver, uint256 _deadline) external noReentry {

        ots storage s = lots();
        handleFeesInternal();
        uint256 strategyUnderlyingBalanceBefore = s.allocationStrategy.balanceOfUnderlying();
        s.underlying.safeTransferFrom(msg.sender, address(s.allocationStrategy), _amount);
        uint256 amount = s.allocationStrategy.investUnderlying(_amount, _deadline);
        _deposit(amount, _receiver, strategyUnderlyingBalanceBefore);
    }

    function deposit(address _tokenIn, uint256 _amount, uint256 _amountOutMin, address _receiver, uint256 _deadline) external noReentry {

        ots storage s = lots();

        handleFeesInternal();
        uint256 strategyUnderlyingBalanceBefore = s.allocationStrategy.balanceOfUnderlying();

        IERC20 tokenIn = IERC20(_tokenIn);
        tokenIn.safeTransferFrom(msg.sender, address(s.allocationStrategy), _amount);
        uint256 amount = s.allocationStrategy.invest(_tokenIn, _amount, _amountOutMin, _deadline);
        _deposit(amount, _receiver, strategyUnderlyingBalanceBefore);
    }

    function _deposit(uint256 _amount, address _receiver, uint256 _strategyUnderlyingBalanceBefore) internal {

        ots storage s = lots();

        if(s.internalTotalSupply == 0) {
            uint256 internalToMint = _amount.mul(INITIAL_EXCHANGE_RATE).div(10**18);
            s.internalBalanceOf[_receiver] = internalToMint;
            s.internalTotalSupply = internalToMint;
            emit Transfer(address(0), _receiver, _amount);
            emit Deposited(msg.sender, _receiver, _amount);
            s.lastTotalUnderlying = s.allocationStrategy.balanceOfUnderlying();
            return;
        } else {
            uint256 internalToMint = s.internalTotalSupply.mul(_amount).div(_strategyUnderlyingBalanceBefore);
            s.internalBalanceOf[_receiver] = s.internalBalanceOf[_receiver].add(internalToMint);
            s.internalTotalSupply = s.internalTotalSupply.add(internalToMint);
            emit Transfer(address(0), _receiver, _amount);
            emit Deposited(msg.sender, _receiver, _amount);
            s.lastTotalUnderlying = s.allocationStrategy.balanceOfUnderlying();
            return;
        }
    }

    function withdrawUnderlying(uint256 _redeemAmount, address _receiver) external noReentry {

        ots storage s = lots();
        handleFeesInternal();
        uint256 internalAmount = s.internalTotalSupply.mul(_redeemAmount).div(s.allocationStrategy.balanceOfUnderlying());
        s.internalBalanceOf[msg.sender] = s.internalBalanceOf[msg.sender].sub(internalAmount);
        s.internalTotalSupply = s.internalTotalSupply.sub(internalAmount);
        uint256 redeemedAmount = s.allocationStrategy.redeemUnderlying(_redeemAmount);
        uint256 withdrawFee = redeemedAmount.mul(WITHDRAW_FEE).div(10**18);
        redeemedAmount = redeemedAmount.sub(withdrawFee);
        s.underlying.safeTransfer(_receiver, redeemedAmount);
        s.underlying.safeTransfer(owner(), withdrawFee);
        s.lastTotalUnderlying = s.allocationStrategy.balanceOfUnderlying();
        emit Transfer(msg.sender, address(0), redeemedAmount);
        emit Withdrawn(msg.sender, _receiver, redeemedAmount);
    }

    function allowance(address _owner, address _spender) external view override returns(uint256) {

        ots storage s = lots();
        return s.internalAllowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external override noReentry returns(bool) {

        ots storage s = lots();
        s.internalAllowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function balanceOf(address _account) external view override returns(uint256) {

        ots storage s = lots();
        if(s.internalTotalSupply == 0) {
            return 0;
        }
        return s.allocationStrategy.balanceOfUnderlyingView().mul(s.internalBalanceOf[_account]).div(s.internalTotalSupply.add(calcFeeMintAmount()));
    }

    function totalSupply() external view override returns(uint256) {

        ots storage s = lots();
        return s.allocationStrategy.balanceOfUnderlyingView();
    }

    function transfer(address _to, uint256 _amount) external override noReentry returns(bool) {

        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external override noReentry returns(bool) {

        ots storage s = lots();
        require(
            msg.sender == _from ||
            s.internalAllowances[_from][_to] >= _amount,
            "OToken.transferFrom: Insufficient allowance"
        );

        if(s.internalAllowances[_from][msg.sender] != uint256(-1)) {
            s.internalAllowances[_from][msg.sender] = s.internalAllowances[_from][msg.sender].sub(_amount);
        }
        _transfer(_from, _to, _amount);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {

        ots storage s = lots();
        handleFeesInternal();

        uint256 internalAmount = s.internalTotalSupply.mul(_amount).div(s.allocationStrategy.balanceOfUnderlyingView());
        uint256 sanityAmount = internalAmount.mul(s.allocationStrategy.balanceOfUnderlyingView()).div(s.internalTotalSupply);

        if(_amount != sanityAmount) {
            internalAmount = internalAmount.add(1);
        }

        s.internalBalanceOf[_from] = s.internalBalanceOf[_from].sub(internalAmount);
        s.internalBalanceOf[_to] = s.internalBalanceOf[_to].add(internalAmount);
        emit Transfer(_from, _to, _amount);

        s.lastTotalUnderlying = s.allocationStrategy.balanceOfUnderlyingView();
    }

    function handleFees() public noReentry {

        handleFeesInternal();
    }

    function handleFeesInternal() internal {

        ots storage s = lots();
        uint256 mintAmount = calcFeeMintAmount();
        if(mintAmount == 0) {
            return;
        }

        s.internalBalanceOf[owner()] = s.internalBalanceOf[owner()].add(mintAmount);
        s.internalTotalSupply = s.internalTotalSupply.add(mintAmount);

        s.lastTotalUnderlying = s.allocationStrategy.balanceOfUnderlyingView();
    }

    function calcFeeMintAmount() public view returns(uint256) {

        ots storage s = lots();
        uint256 newUnderlyingAmount = s.allocationStrategy.balanceOfUnderlyingView();
        if(newUnderlyingAmount <= s.lastTotalUnderlying) {
            return 0;
        }
        uint256 interestEarned = newUnderlyingAmount.sub(s.lastTotalUnderlying);
        if(interestEarned == 0) {
            return 0;
        }
        uint256 feeAmount = interestEarned.mul(s.fee).div(10**18);

        return s.internalTotalSupply.mul(feeAmount).div(newUnderlyingAmount.sub(feeAmount));
    }

    function setFee(uint256 _newFee) external onlyOwner noReentry {

        require(_newFee <= MAX_FEE, "OToken.setFee: Fee too high");
        ots storage s = lots();
        emit FeeChanged(msg.sender, s.fee, _newFee);
        s.fee = _newFee;
    }

    function setAdmin(address _newAdmin) external onlyOwner noReentry {

        ots storage s = lots();
        emit AdminChanged(_newAdmin);
        s.admin = _newAdmin;
    }

    function changeAllocationStrategy(address _newAllocationStrategy, uint256 _deadline) external noReentry {


        ots storage s = lots();
        require(msg.sender == s.admin, "OToken.changeAllocationStrategy: msg.sender not admin");
        require(s.strategiesWhitelist.isWhitelisted(_newAllocationStrategy) == 1, "OToken.changeAllocationStrategy: allocations strategy not whitelisted");

        emit AllocationStrategyChanged(msg.sender, address(s.allocationStrategy), _newAllocationStrategy);

        s.allocationStrategy.redeemAll();
        s.underlying.safeApprove(address(s.allocationStrategy), 0);
        s.allocationStrategy = IAllocationStrategy(_newAllocationStrategy);
        s.underlying.safeApprove(_newAllocationStrategy, uint256(-1));

        uint256 balance = s.underlying.balanceOf(address(this));

        s.underlying.safeTransfer(_newAllocationStrategy, balance);
        s.allocationStrategy.investUnderlying(balance, _deadline);
    }

    function withdrawLockedERC20(address _token) external onlyOwner noReentry {

        IERC20 token = IERC20(_token);
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }
}