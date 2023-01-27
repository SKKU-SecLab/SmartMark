

pragma solidity 0.6.11;

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
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

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

contract ReentrancyGuard {


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

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
}

interface CEther {

    function mint() external payable;


    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);


    function supplyRatePerBlock() external returns (uint256);


    function redeem(uint) external returns (uint);


    function redeemUnderlying(uint) external returns (uint);

    
}

interface IUniswapV2Router {

    function WETH() external pure returns (address);

    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}

contract VaultWETH is Ownable, ReentrancyGuard {

    using SafeMath for uint;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    
    
    uint public constant LOCKUP_DURATION = 3 days;
    uint public constant FEE_PERCENT_X_100 = 30;
    uint public constant FEE_PERCENT_TO_BUYBACK_X_100 = 2500;
    
    uint public constant REWARD_INTERVAL = 365 days;
    uint public constant ADMIN_CAN_CLAIM_AFTER = 395 days;
    uint public constant REWARD_RETURN_PERCENT_X_100 = 250;
    
    uint public constant MIN_ETH_FEE_IN_WEI = 40000 * 1 * 10**9;
    
    address public constant TRUSTED_CTOKEN_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    address public constant TRUSTED_PLATFORM_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    
    IUniswapV2Router public constant uniswapRouterV2 = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    uint public constant ONE_HUNDRED_X_100 = 10000;
    uint public immutable contractStartTime;
    
    address public immutable TRUSTED_DEPOSIT_TOKEN_ADDRESS;
    
    constructor() public {
        contractStartTime = block.timestamp;
        TRUSTED_DEPOSIT_TOKEN_ADDRESS = uniswapRouterV2.WETH();
    }
    
    modifier noContractsAllowed() {

        require(tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    
    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);
    
    event EtherRewardDisbursed(uint amount);
    event TokenRewardDisbursed(uint amount);
    
    event PlatformTokenRewardClaimed(address indexed account, uint amount);
    event CompoundRewardClaimed(address indexed account, uint amount);
    event EtherRewardClaimed(address indexed account, uint amount);
    event TokenRewardClaimed(address indexed account, uint amount);
    
    event PlatformTokenAdded(uint amount);
    
    
    EnumerableSet.AddressSet private holders;
    
    function getNumberOfHolders() public view returns (uint) {

        return holders.length();
    }
    
    mapping (address => uint) public tokenBalances;
    
    mapping (address => uint) public cTokenBalance;
    mapping (address => uint) public depositTokenBalance;
    
    mapping (address => uint) public totalTokensDepositedByUser;
    mapping (address => uint) public totalTokensWithdrawnByUser;
    
    mapping (address => uint) public totalEarnedCompoundDivs;
    mapping (address => uint) public totalEarnedEthDivs;
    mapping (address => uint) public totalEarnedTokenDivs;
    mapping (address => uint) public totalEarnedPlatformTokenDivs;
    
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    
    uint public totalCTokens;
    uint public totalDepositedTokens;
    
    
    uint public constant POINT_MULTIPLIER = 1e18;
    
    mapping (address => uint) public lastTokenDivPoints;
    mapping (address => uint) public tokenDivsBalance;
    uint public totalTokenDivPoints;
    
    mapping (address => uint) public lastEthDivPoints;
    mapping (address => uint) public ethDivsBalance;
    uint public totalEthDivPoints;
    
    mapping (address => uint) public platformTokenDivsBalance;
    
    uint public totalEthDisbursed;
    uint public totalTokensDisbursed;
   
    
    function tokenDivsOwing(address account) public view returns (uint) {

        uint newDivPoints = totalTokenDivPoints.sub(lastTokenDivPoints[account]);
        return depositTokenBalance[account].mul(newDivPoints).div(POINT_MULTIPLIER);
    }
    function ethDivsOwing(address account) public view returns (uint) {

        uint newDivPoints = totalEthDivPoints.sub(lastEthDivPoints[account]);
        return depositTokenBalance[account].mul(newDivPoints).div(POINT_MULTIPLIER);
    }
    
    function distributeEthDivs(uint amount) private {

        if (totalDepositedTokens == 0) return;
        totalEthDivPoints = totalEthDivPoints.add(amount.mul(POINT_MULTIPLIER).div(totalDepositedTokens));
        totalEthDisbursed = totalEthDisbursed.add(amount);
        increaseTokenBalance(address(0), amount);
        emit EtherRewardDisbursed(amount);
    }
    function distributeTokenDivs(uint amount) private {

        if (totalDepositedTokens == 0) return;
        totalTokenDivPoints = totalTokenDivPoints.add(amount.mul(POINT_MULTIPLIER).div(totalDepositedTokens));
        totalTokensDisbursed = totalTokensDisbursed.add(amount);
        increaseTokenBalance(TRUSTED_DEPOSIT_TOKEN_ADDRESS, amount);
        emit TokenRewardDisbursed(amount);
    }
    
    
    
    function getDepositorsList(uint startIndex, uint endIndex)
        public
        view
        returns (address[] memory stakers,
            uint[] memory stakingTimestamps,
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {

        require (startIndex < endIndex);

        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);

        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = depositTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositTokenBalance[staker];
        }

        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }

    function updateAccount(address account) private {

        uint tokensOwing = tokenDivsOwing(account);
        lastTokenDivPoints[account] = totalTokenDivPoints;
        if (tokensOwing > 0) {
            tokenDivsBalance[account] = tokenDivsBalance[account].add(tokensOwing);
        }
        
        uint weiOwing = ethDivsOwing(account);
        lastEthDivPoints[account] = totalEthDivPoints;
        if (weiOwing > 0) {
            ethDivsBalance[account] = ethDivsBalance[account].add(weiOwing);
        }
        
        uint platformTokensOwing = platformTokenDivsOwing(account);
        if (platformTokensOwing > 0) {
            platformTokenDivsBalance[account] = platformTokenDivsBalance[account].add(platformTokensOwing);
        }
        
        lastClaimedTime[account] = block.timestamp;
    }
    
    function platformTokenDivsOwing(address account) public view returns (uint) {

        if (!holders.contains(account)) return 0;
        if (depositTokenBalance[account] == 0) return 0;
        
        uint timeDiff;
        uint stakingEndTime = contractStartTime.add(REWARD_INTERVAL);
        uint _now = block.timestamp;
        if (_now > stakingEndTime) {
            _now = stakingEndTime;
        }
        
        if (lastClaimedTime[account] >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastClaimedTime[account]);
        }
        
        uint pendingDivs = depositTokenBalance[account]
                                .mul(REWARD_RETURN_PERCENT_X_100)
                                .mul(timeDiff)
                                .div(REWARD_INTERVAL)
                                .div(ONE_HUNDRED_X_100);
        return pendingDivs;
    }
    
    function getEstimatedCompoundDivsOwing(address account) public view returns (uint) {

        uint convertedBalance = getConvertedBalance(cTokenBalance[account]);
        uint depositedBalance = depositTokenBalance[account];
        return (convertedBalance > depositedBalance ? convertedBalance.sub(depositedBalance) : 0);
    }
    
    function getConvertedBalance(uint _cTokenBalance) public view returns (uint) {

        uint exchangeRateStored = getExchangeRateStored();
        uint convertedBalance = _cTokenBalance.mul(exchangeRateStored).div(10**18);
        return convertedBalance;
    }
    
    function _claimEthDivs() private {

        updateAccount(msg.sender);
        uint amount = ethDivsBalance[msg.sender];
        ethDivsBalance[msg.sender] = 0;
        if (amount == 0) return;
        decreaseTokenBalance(address(0), amount);
        msg.sender.transfer(amount);
        totalEarnedEthDivs[msg.sender] = totalEarnedEthDivs[msg.sender].add(amount);
        
        emit EtherRewardClaimed(msg.sender, amount);
    }
    function _claimTokenDivs() private {

        updateAccount(msg.sender);
        uint amount = tokenDivsBalance[msg.sender];
        tokenDivsBalance[msg.sender] = 0;
        if (amount == 0) return;
        decreaseTokenBalance(TRUSTED_DEPOSIT_TOKEN_ADDRESS, amount);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, amount);
        totalEarnedTokenDivs[msg.sender] = totalEarnedTokenDivs[msg.sender].add(amount);
        
        emit TokenRewardClaimed(msg.sender, amount);
    }
    function _claimCompoundDivs() private {

        updateAccount(msg.sender);
        uint exchangeRateCurrent = getExchangeRateCurrent();
        
        uint convertedBalance = cTokenBalance[msg.sender].mul(exchangeRateCurrent).div(10**18);
        uint depositedBalance = depositTokenBalance[msg.sender];
        
        uint amount = convertedBalance > depositedBalance ? convertedBalance.sub(depositedBalance) : 0;
        
        if (amount == 0) return;
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint oldEtherBalance = address(this).balance;
        require(CEther(TRUSTED_CTOKEN_ADDRESS).redeemUnderlying(amount) == 0, "redeemUnderlying failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint newEtherBalance = address(this).balance;
        
        uint depositTokenReceived = newEtherBalance.sub(oldEtherBalance);
        uint cTokenRedeemed = oldCTokenBalance.sub(newCTokenBalance);
        
        IWETH(TRUSTED_DEPOSIT_TOKEN_ADDRESS).deposit{value: depositTokenReceived}();
        
        require(cTokenRedeemed <= cTokenBalance[msg.sender], "redeem exceeds balance!");
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].sub(cTokenRedeemed);
        totalCTokens = totalCTokens.sub(cTokenRedeemed);
        decreaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenRedeemed);
        
        totalTokensWithdrawnByUser[msg.sender] = totalTokensWithdrawnByUser[msg.sender].add(depositTokenReceived);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, depositTokenReceived);
        
        totalEarnedCompoundDivs[msg.sender] = totalEarnedCompoundDivs[msg.sender].add(depositTokenReceived);
        
        emit CompoundRewardClaimed(msg.sender, depositTokenReceived);
    }
    function _claimPlatformTokenDivs(uint _amountOutMin_platformTokens) private {

        updateAccount(msg.sender);
        uint amount = platformTokenDivsBalance[msg.sender];
        
        if (amount == 0) return;
        
        address[] memory path = new address[](2);
        path[0] = TRUSTED_DEPOSIT_TOKEN_ADDRESS;
        path[1] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(amount, path)[1];
        require(estimatedAmountOut >= _amountOutMin_platformTokens, "_claimPlatformTokenDivs: slippage error!");
        
        if (IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this)) < estimatedAmountOut) {
            return;
        }
        
        platformTokenDivsBalance[msg.sender] = 0;
        
        
        decreaseTokenBalance(TRUSTED_PLATFORM_TOKEN_ADDRESS, estimatedAmountOut);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(msg.sender, estimatedAmountOut);
        totalEarnedPlatformTokenDivs[msg.sender] = totalEarnedPlatformTokenDivs[msg.sender].add(estimatedAmountOut);
        
        emit PlatformTokenRewardClaimed(msg.sender, estimatedAmountOut);
    }
    
    function claimEthDivs() external noContractsAllowed nonReentrant {

        _claimEthDivs();
    }
    function claimTokenDivs() external noContractsAllowed nonReentrant {

        _claimTokenDivs();
    }
    function claimCompoundDivs() external noContractsAllowed nonReentrant {

        _claimCompoundDivs();
    }
    function claimPlatformTokenDivs(uint _amountOutMin_platformTokens) external noContractsAllowed nonReentrant {

        _claimPlatformTokenDivs(_amountOutMin_platformTokens);
    }
    
    function claim(uint _amountOutMin_platformTokens) external noContractsAllowed nonReentrant {

        _claimEthDivs();
        _claimTokenDivs();
        _claimCompoundDivs();
        _claimPlatformTokenDivs(_amountOutMin_platformTokens);
    }
    
    function getExchangeRateCurrent() public returns (uint) {

        uint exchangeRateCurrent = CEther(TRUSTED_CTOKEN_ADDRESS).exchangeRateCurrent();
        return exchangeRateCurrent;
    }
    
    function getExchangeRateStored() public view returns (uint) {

        uint exchangeRateStored = CEther(TRUSTED_CTOKEN_ADDRESS).exchangeRateStored();
        return exchangeRateStored;
    }
    
    function deposit(uint amount, uint _amountOutMin_ethFeeBuyBack, uint deadline) external noContractsAllowed nonReentrant payable {

        require(amount > 0, "invalid amount!");
        
        updateAccount(msg.sender);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), amount);
        

        totalTokensDepositedByUser[msg.sender] = totalTokensDepositedByUser[msg.sender].add(amount);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(TRUSTED_CTOKEN_ADDRESS, 0);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(TRUSTED_CTOKEN_ADDRESS, amount);
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        
        IWETH(TRUSTED_DEPOSIT_TOKEN_ADDRESS).withdraw(amount);
        CEther(TRUSTED_CTOKEN_ADDRESS).mint{value: amount}();
        
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint cTokenReceived = newCTokenBalance.sub(oldCTokenBalance);
        
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].add(cTokenReceived);
        totalCTokens = totalCTokens.add(cTokenReceived);    
        increaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenReceived);
        
        depositTokenBalance[msg.sender] = depositTokenBalance[msg.sender].add(amount);
        totalDepositedTokens = totalDepositedTokens.add(amount);
        
        handleEthFee(msg.value, _amountOutMin_ethFeeBuyBack, deadline);
        
        holders.add(msg.sender);
        depositTime[msg.sender] = block.timestamp;
        
        emit Deposit(msg.sender, amount);
    }
    function withdraw(uint amount, uint _amountOutMin_ethFeeBuyBack, uint _amountOutMin_tokenFeeBuyBack, uint deadline) external noContractsAllowed nonReentrant payable {

        require(amount > 0, "invalid amount!");
        require(amount <= depositTokenBalance[msg.sender], "Cannot withdraw more than deposited!");
        require(block.timestamp.sub(depositTime[msg.sender]) > LOCKUP_DURATION, "You recently deposited, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        depositTokenBalance[msg.sender] = depositTokenBalance[msg.sender].sub(amount);
        totalDepositedTokens = totalDepositedTokens.sub(amount);
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint oldEtherBalance = address(this).balance;
        require(CEther(TRUSTED_CTOKEN_ADDRESS).redeemUnderlying(amount) == 0, "redeemUnderlying failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint newEtherBalance = address(this).balance;
        
        uint depositTokenReceived = newEtherBalance.sub(oldEtherBalance);
        uint cTokenRedeemed = oldCTokenBalance.sub(newCTokenBalance);
        
        IWETH(TRUSTED_DEPOSIT_TOKEN_ADDRESS).deposit{value: depositTokenReceived}();
        
        require(cTokenRedeemed <= cTokenBalance[msg.sender], "redeem exceeds balance!");
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].sub(cTokenRedeemed);
        totalCTokens = totalCTokens.sub(cTokenRedeemed);
        decreaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenRedeemed);
        
        totalTokensWithdrawnByUser[msg.sender] = totalTokensWithdrawnByUser[msg.sender].add(depositTokenReceived);
        
        uint feeAmount = depositTokenReceived.mul(FEE_PERCENT_X_100).div(ONE_HUNDRED_X_100);
        uint depositTokenReceivedAfterFee = depositTokenReceived.sub(feeAmount);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, depositTokenReceivedAfterFee);
        
        handleFee(feeAmount, _amountOutMin_tokenFeeBuyBack, deadline);
        handleEthFee(msg.value, _amountOutMin_ethFeeBuyBack, deadline);
        
        if (depositTokenBalance[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        
        emit Withdraw(msg.sender, depositTokenReceived);
    }
    
    function emergencyWithdraw(uint amount) external noContractsAllowed nonReentrant payable {

        require(amount > 0, "invalid amount!");
        require(amount <= depositTokenBalance[msg.sender], "Cannot withdraw more than deposited!");
        require(block.timestamp.sub(depositTime[msg.sender]) > LOCKUP_DURATION, "You recently deposited, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        depositTokenBalance[msg.sender] = depositTokenBalance[msg.sender].sub(amount);
        totalDepositedTokens = totalDepositedTokens.sub(amount);
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint oldEtherBalance = address(this).balance;
        require(CEther(TRUSTED_CTOKEN_ADDRESS).redeemUnderlying(amount) == 0, "redeemUnderlying failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint newEtherBalance = address(this).balance;
        
        uint depositTokenReceived = newEtherBalance.sub(oldEtherBalance);
        uint cTokenRedeemed = oldCTokenBalance.sub(newCTokenBalance);
        
        IWETH(TRUSTED_DEPOSIT_TOKEN_ADDRESS).deposit{value: depositTokenReceived}();
        
        require(cTokenRedeemed <= cTokenBalance[msg.sender], "redeem exceeds balance!");
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].sub(cTokenRedeemed);
        totalCTokens = totalCTokens.sub(cTokenRedeemed);
        decreaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenRedeemed);
        
        totalTokensWithdrawnByUser[msg.sender] = totalTokensWithdrawnByUser[msg.sender].add(depositTokenReceived);
        
        uint feeAmount = depositTokenReceived.mul(FEE_PERCENT_X_100).div(ONE_HUNDRED_X_100);
        uint depositTokenReceivedAfterFee = depositTokenReceived.sub(feeAmount);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, depositTokenReceivedAfterFee);
        
        
        if (depositTokenBalance[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        
        emit Withdraw(msg.sender, depositTokenReceived);
    }
    
    function handleFee(uint feeAmount, uint _amountOutMin_tokenFeeBuyBack, uint deadline) private {

        uint buyBackFeeAmount = feeAmount.mul(FEE_PERCENT_TO_BUYBACK_X_100).div(ONE_HUNDRED_X_100);
        uint remainingFeeAmount = feeAmount.sub(buyBackFeeAmount);
        
        distributeTokenDivs(remainingFeeAmount);
        
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(address(uniswapRouterV2), 0);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(address(uniswapRouterV2), buyBackFeeAmount);
        
        uint oldPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = TRUSTED_DEPOSIT_TOKEN_ADDRESS;
        path[1] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        
        uniswapRouterV2.swapExactTokensForTokens(buyBackFeeAmount, _amountOutMin_tokenFeeBuyBack, path, address(this), deadline);
        uint newPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(BURN_ADDRESS, platformTokensReceived);
    }
    
    function handleEthFee(uint feeAmount, uint _amountOutMin_ethFeeBuyBack, uint deadline) private {

        require(feeAmount >= MIN_ETH_FEE_IN_WEI, "Insufficient ETH Fee!");
        uint buyBackFeeAmount = feeAmount.mul(FEE_PERCENT_TO_BUYBACK_X_100).div(ONE_HUNDRED_X_100);
        uint remainingFeeAmount = feeAmount.sub(buyBackFeeAmount);
        
        distributeEthDivs(remainingFeeAmount);
        
        
        
        uint oldPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = uniswapRouterV2.WETH();
        path[1] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        
        uniswapRouterV2.swapExactETHForTokens{value: buyBackFeeAmount}(_amountOutMin_ethFeeBuyBack, path, address(this), deadline);
        uint newPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(BURN_ADDRESS, platformTokensReceived);
    }
    
    receive () external payable {
    }
    
    function increaseTokenBalance(address token, uint amount) private {

        tokenBalances[token] = tokenBalances[token].add(amount);
    }
    function decreaseTokenBalance(address token, uint amount) private {

        tokenBalances[token] = tokenBalances[token].sub(amount);
    }
    
    function addPlatformTokenBalance(uint amount) external nonReentrant onlyOwner {

        increaseTokenBalance(TRUSTED_PLATFORM_TOKEN_ADDRESS, amount);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), amount);
        
        emit PlatformTokenAdded(amount);
    }
    
    function claimExtraTokens(address token) external nonReentrant onlyOwner {

        if (token == address(0)) {
            uint ethDiff = address(this).balance.sub(tokenBalances[token]);
            msg.sender.transfer(ethDiff);
            return;
        }
        uint diff = IERC20(token).balanceOf(address(this)).sub(tokenBalances[token]);
        IERC20(token).safeTransfer(msg.sender, diff);
    }
    
    function claimAnyToken(address token, uint amount) external onlyOwner {

        require(now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Contract not expired yet!");
        if (token == address(0)) {
            msg.sender.transfer(amount);
            return;
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}