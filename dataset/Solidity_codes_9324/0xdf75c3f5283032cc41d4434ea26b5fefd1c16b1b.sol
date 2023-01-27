
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//Unlicensed
pragma solidity 0.8.4;



contract CliffVesting is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public immutable cliff;
    uint256 public immutable start;
    uint256 public immutable duration;
    uint256 public released;

    address public immutable beneficiary;
    IERC20 public immutable token;

    event TokensReleased(uint256 amount);


    constructor(
        address beneficiary_,
        uint256 cliffDuration_,
        uint256 duration_,
        address token_
    ) {
        require(beneficiary_ != address(0));
        require(token_ != address(0));
        require(cliffDuration_ <= duration_);
        require(duration_ > 0);

        beneficiary = beneficiary_;
        token = IERC20(token_);
        duration = duration_;
        start = block.timestamp;
        cliff = block.timestamp.add(cliffDuration_);
    }


    function release() external {

        uint256 unreleased = _releasableAmount();

        require(unreleased > 0);

        released = released.add(unreleased);

        token.safeTransfer(beneficiary, unreleased);

        emit TokensReleased(unreleased);
    }


    function _releasableAmount() private view returns (uint256) {

        return _vestedAmount().sub(released);
    }

    function _vestedAmount() private view returns (uint256) {

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}//Unlicensed
pragma solidity 0.8.4;


interface IPublicSale {

    function addLiquidity() external;

    function endPublicSale() external;

    function endPrivateSale() external;

    function emergencyWithdrawFunds() external;

    function recoverERC20(address tokenAddress) external;

    function recoverLpToken(address lPTokenAddress) external;

    function addPrivateAllocations(address[] memory investors, uint256[] memory amounts) external;

    function lockCompanyTokens(address marketing, address reserve, address development) external;

    function whitelistUsers(address[] calldata users, uint256 maxEthDeposit) external;

    function getWhitelistedAmount(address user) external view returns (uint256);

    function getUserDeposits(address user) external view returns (uint256);

}//Unlicensed
pragma solidity 0.8.4;



interface IOneUp is IERC20 {

    function burn(uint256 amount) external;

    function setTradingStart(uint256 time) external;

    function mint(address to, uint256 value) external;

}//Unlicensed
pragma solidity 0.8.4;




contract PublicSale is IPublicSale, Ownable {

    using SafeMath for uint256;

    bool public privateSaleFinished;
    bool public liquidityPoolCreated;

    IOneUp public oneUpToken;
    IVesting public immutable vesting;
    ILiquidityProvider public immutable lpProvider;

    address public reserveLockContract;
    address public marketingLockContract;
    address public developerLockContract;
    address payable public immutable publicSaleFund;

    uint256 public totalDeposits;
    uint256 public publicSaleStartTimestamp;
    uint256 public publicSaleFinishedAt;

    uint256 public constant PUBLIC_SALE_DELAY = 7 days;
    uint256 public constant LP_CREATION_DELAY = 30 minutes;
    uint256 public constant TRADING_BLOCK_DELAY = 15 minutes;
    uint256 public constant WHITELISTED_USERS_ACCESS = 2 hours;

    uint256 public constant PUBLIC_SALE_LOCK_PERCENT = 5000;  // 50% of tokens
    uint256 public constant PRIVATE_SALE_LOCK_PERCENT = 1500; // 15% of tokens
    uint256 public constant PUBLIC_SALE_PRICE = 151000;       // 1 ETH = 151,000 token

    uint256 public constant HARD_CAP_ETH_AMOUNT = 300 ether;
    uint256 public constant MIN_DEPOSIT_ETH_AMOUNT = 0.1 ether;
    uint256 public constant MAX_DEPOSIT_ETH_AMOUNT = 3 ether;

    mapping(address => uint256) internal _deposits;
    mapping(address => uint256) internal _whitelistedAmount;

    event Deposited(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
    event EmergencyWithdrawn(address user, uint256 amount);
    event UsersWhitelisted(address[] users, uint256 maxAmount);


    constructor(address oneUpToken_, address payable publicSaleFund_, address uniswapRouter_) {
        require(oneUpToken_ != address(0), 'PublicSale: Empty token address!');
        require(publicSaleFund_ != address(0), 'PublicSale: Empty fund address!');
        require(uniswapRouter_ != address(0), 'PublicSale: Empty uniswap router address!');

        oneUpToken = IOneUp(oneUpToken_);
        publicSaleFund = publicSaleFund_;

        address vestingAddr = address(new InvestorsVesting(oneUpToken_));
        vesting = IVesting(vestingAddr);

        address lpProviderAddr = address(new LiquidityProvider(oneUpToken_, uniswapRouter_));
        lpProvider = ILiquidityProvider(lpProviderAddr);
    }


    receive() external payable {
        deposit();
    }

    function deposit() public payable {

        require(privateSaleFinished, 'PublicSale: Private sale not finished yet!');
        require(publicSaleFinishedAt == 0, 'PublicSale: Public sale already ended!');
        require(block.timestamp >= publicSaleStartTimestamp && block.timestamp <= publicSaleStartTimestamp.add(PUBLIC_SALE_DELAY), 'PublicSale: Time was reached!');
        require(totalDeposits.add(msg.value) <= HARD_CAP_ETH_AMOUNT, 'PublicSale: Deposit limits reached!');
        require(_deposits[msg.sender].add(msg.value) >= MIN_DEPOSIT_ETH_AMOUNT && _deposits[msg.sender].add(msg.value) <= MAX_DEPOSIT_ETH_AMOUNT, 'PublicSale: Limit is reached or not enough amount!');

        if (block.timestamp < publicSaleStartTimestamp.add(WHITELISTED_USERS_ACCESS)) {
            require(_whitelistedAmount[msg.sender] > 0, 'PublicSale: Its time for whitelisted investors only!');
            require(_whitelistedAmount[msg.sender] >= msg.value, 'PublicSale: Sent amount should not be bigger from allowed limit!');
            _whitelistedAmount[msg.sender] = _whitelistedAmount[msg.sender].sub(msg.value);
        }

        _deposits[msg.sender] = _deposits[msg.sender].add(msg.value);
        totalDeposits = totalDeposits.add(msg.value);

        uint256 tokenAmount = msg.value.mul(PUBLIC_SALE_PRICE);
        vesting.submit(msg.sender, tokenAmount, PUBLIC_SALE_LOCK_PERCENT);

        emit Deposited(msg.sender, msg.value);
    }


    function endPublicSale() external override {

        require(publicSaleFinishedAt == 0, 'endPublicSale: Public sale already finished!');
        require(privateSaleFinished, 'endPublicSale: Private sale not finished yet!');
        require(block.timestamp > publicSaleStartTimestamp.add(PUBLIC_SALE_DELAY) || totalDeposits.add(1 ether) >= HARD_CAP_ETH_AMOUNT, 'endPublicSale: Can not be finished!');
        publicSaleFinishedAt = block.timestamp;
    }

    function addLiquidity() external override  {

        require(!liquidityPoolCreated, 'addLiquidity: Pool already created!');
        require(publicSaleFinishedAt != 0, 'addLiquidity: Public sale not finished!');
        require(block.timestamp > publicSaleFinishedAt.add(LP_CREATION_DELAY), 'addLiquidity: Time was not reached!');

        liquidityPoolCreated = true;

        uint256 balance = address(this).balance;
        uint256 liquidityEth = balance.mul(6000).div(10000);

        publicSaleFund.transfer(balance.sub(liquidityEth));
        payable(address(lpProvider)).transfer(liquidityEth);

        lpProvider.addLiquidity();

        vesting.setStart();

        oneUpToken.setTradingStart(block.timestamp.add(TRADING_BLOCK_DELAY));
    }

    function emergencyWithdrawFunds() external override {

      require(!liquidityPoolCreated, 'emergencyWithdrawFunds: Liquidity pool already created!');
      require(publicSaleFinishedAt != 0, 'emergencyWithdrawFunds: Public sale not finished!');
      require(block.timestamp > publicSaleFinishedAt.add(LP_CREATION_DELAY).add(1 days), 'emergencyWithdrawFunds: Not allowed to call now!');

      uint256 investedAmount = _deposits[msg.sender];
      require(investedAmount > 0, 'emergencyWithdrawFunds: No funds to receive!');

      vesting.reset(msg.sender);

      _deposits[msg.sender] = 0;
      payable(msg.sender).transfer(investedAmount);

      emit EmergencyWithdrawn(msg.sender, investedAmount);
    }


    function addPrivateAllocations(address[] memory investors, uint256[] memory amounts) external override onlyOwner {

        require(!privateSaleFinished, 'addPrivateAllocations: Private sale is ended!');
        require(investors.length > 0, 'addPrivateAllocations: Array can not be empty!');
        require(investors.length == amounts.length, 'addPrivateAllocations: Arrays should have the same length!');

        vesting.submitMulti(investors, amounts, PRIVATE_SALE_LOCK_PERCENT);
    }

    function endPrivateSale() external override onlyOwner {

        require(!privateSaleFinished, 'endPrivateSale: Private sale is ended!');

        privateSaleFinished = true;
        publicSaleStartTimestamp = block.timestamp;
    }

    function recoverERC20(address tokenAddress) external override onlyOwner {

        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, balance);
        emit Recovered(tokenAddress, balance);
    }

    function recoverLpToken(address lPTokenAddress) external override onlyOwner {

        lpProvider.recoverERC20(lPTokenAddress, msg.sender);
    }

    function lockCompanyTokens(address developerReceiver, address marketingReceiver, address reserveReceiver) external override {

        require(marketingReceiver != address(0) && reserveReceiver != address(0) && developerReceiver != address(0), 'lockCompanyTokens: Can not be zero address!');
        require(marketingLockContract == address(0) && reserveLockContract == address(0) && developerLockContract == address(0), 'lockCompanyTokens: Already locked!');
        require(block.timestamp > publicSaleFinishedAt.add(LP_CREATION_DELAY), 'lockCompanyTokens: Should be called after LP creation!');
        require(liquidityPoolCreated, 'lockCompanyTokens: Pool was not created!');

        developerLockContract = address(new CliffVesting(developerReceiver, 30 days, 180 days, address(oneUpToken)));    //  1 month cliff  6 months vesting
        marketingLockContract = address(new CliffVesting(marketingReceiver, 7 days, 90 days, address(oneUpToken)));      //  7 days cliff   3 months vesting
        reserveLockContract = address(new CliffVesting(reserveReceiver, 270 days, 360 days, address(oneUpToken)));        //  9 months cliff 3 months vesting

        oneUpToken.mint(developerLockContract, 2000000 ether);  // 2 mln tokens
        oneUpToken.mint(marketingLockContract, 2000000 ether);  // 2 mln tokens
        oneUpToken.mint(reserveLockContract, 500000 ether);    // 500k tokens
    }

    function whitelistUsers(address[] calldata users, uint256 maxEthDeposit) external override onlyOwner {

        require(users.length > 0, 'setWhitelistUsers: Empty array!');

        uint256 usersLength = users.length;
        for (uint256 i = 0; i < usersLength; i++) {
            address user = users[i];
            _whitelistedAmount[user] = _whitelistedAmount[user].add(maxEthDeposit);
        }

        emit UsersWhitelisted(users, maxEthDeposit);
    }



    function getWhitelistedAmount(address user) external override view returns (uint256) {

        return _whitelistedAmount[user];
    }

    function getUserDeposits(address user) external override view returns (uint256) {

        return _deposits[user];
    }

    function getTotalDeposits() external view returns (uint256) {

        return totalDeposits;
    }
 }//Unlicensed
pragma solidity 0.8.4;


interface IVesting {

    function submit(address investor, uint256 amount, uint256 lockPercent) external;

    function submitMulti(address[] memory investors, uint256[] memory amounts, uint256 lockPercent) external;

    function setStart() external;

    function claimTgeTokens() external;

    function claimLockedTokens() external;

    function reset(address investor) external;

    function isPrivilegedInvestor(address account) external view returns (bool);

    function getReleasableLockedTokens(address investor) external view returns (uint256);

    function getUserData(address investor) external view returns (uint256 tgeAmount, uint256 releasedLockedTokens, uint256 totalLockedTokens);

}//Unlicensed
pragma solidity 0.8.4;



contract InvestorsVesting is IVesting, Ownable {

    using SafeMath for uint256;

    uint256 public start;
    uint256 public finish;

    uint256 public constant RATE_BASE = 10000; // 100%
    uint256 public constant VESTING_DELAY = 90 days;

    IOneUp public immutable oneUpToken;

    struct Investor {
        bool isPrivileged;

        uint256 tgeTokens;

        uint256 releasedLockedTokens;

        uint256 totalLockedTokens;
    }

    mapping(address => Investor) internal _investors;

    event NewPrivilegedUser(address investor);
    event TokensReceived(address investor, uint256 amount, bool isLockedTokens);


    constructor(address token_) {
        oneUpToken = IOneUp(token_);
    }


    function submit(
        address investor,
        uint256 amount,
        uint256 lockPercent
    ) public override onlyOwner {

        require(start == 0, 'submit: Can not be added after liquidity pool creation!');

        uint256 tgeTokens = amount.mul(lockPercent).div(RATE_BASE);
        uint256 lockedAmount = amount.sub(tgeTokens);

        _investors[investor].tgeTokens = _investors[investor].tgeTokens.add(tgeTokens);
        _investors[investor].totalLockedTokens = _investors[investor].totalLockedTokens.add(lockedAmount);
    }

    function reset(address investor) public override onlyOwner {

      delete _investors[investor];
    }

    function submitMulti(
        address[] memory investors,
        uint256[] memory amounts,
        uint256 lockPercent
    ) external override onlyOwner {

        uint256 investorsLength = investors.length;

        for (uint i = 0; i < investorsLength; i++) {
            submit(investors[i], amounts[i], lockPercent);
        }
    }

    function setStart() external override onlyOwner {

        start = block.timestamp;
        finish = start.add(VESTING_DELAY);
    }


    function claimTgeTokens() external override {

        require(start > 0, 'claimTgeTokens: TGE tokens not available now!');

        uint256 amount = _investors[msg.sender].tgeTokens;
        require(amount > 0, 'claimTgeTokens: No available tokens!');

        _investors[msg.sender].tgeTokens = 0;

        oneUpToken.mint(msg.sender, amount);

        emit TokensReceived(msg.sender, amount, false);
    }

    function claimLockedTokens() external override {

        require(start > 0, 'claimLockedTokens: Locked tokens not available now!');

        uint256 availableAmount = _releasableAmount(msg.sender);
        require(availableAmount > 0, 'claimLockedTokens: No available tokens!');

        if (_investors[msg.sender].releasedLockedTokens == 0 && block.timestamp > finish) {
            _investors[msg.sender].isPrivileged = true;

            emit NewPrivilegedUser(msg.sender);
        }

        _investors[msg.sender].releasedLockedTokens = _investors[msg.sender].releasedLockedTokens.add(availableAmount);

        oneUpToken.mint(msg.sender, availableAmount);

        emit TokensReceived(msg.sender, availableAmount, true);
    }


    function getReleasableLockedTokens(address investor) external override view returns (uint256) {

        return _releasableAmount(investor);
    }

    function getUserData(address investor) external override view returns (
        uint256 tgeAmount,
        uint256 releasedLockedTokens,
        uint256 totalLockedTokens
    ) {

        return (
            _investors[investor].tgeTokens,
            _investors[investor].releasedLockedTokens,
            _investors[investor].totalLockedTokens
        );
    }

    function isPrivilegedInvestor(address account) external override view returns (bool) {

        return _investors[account].isPrivileged;
    }


    function _releasableAmount(address investor) private view returns (uint256) {

        return _vestedAmount(investor).sub(_investors[investor].releasedLockedTokens);
    }

    function _vestedAmount(address investor) private view returns (uint256) {

        uint256 userMaxTokens = _investors[investor].totalLockedTokens;

        if (start == 0 || block.timestamp < start) {
            return 0;
        } else if (block.timestamp >= finish) {
            return userMaxTokens;
        } else {
            uint256 timeSinceStart = block.timestamp.sub(start);
            return userMaxTokens.mul(timeSinceStart).div(VESTING_DELAY);
        }
    }

    function getStartTime() external view returns (uint256) {

        return start;
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

}//Unlicensed
pragma solidity 0.8.4;


interface ILiquidityProvider {

    function addLiquidity() external;

    function recoverERC20(address lpTokenAddress, address receiver) external;

}//Unlicensed
pragma solidity 0.8.4;



contract LiquidityProvider is ILiquidityProvider, Ownable {

    using SafeMath for uint256;

    uint256 public lock;
    uint256 public constant UNISWAP_TOKEN_PRICE = 120000; // 1 ETH = 120,000 1-UP
    uint256 public constant LP_TOKENS_LOCK_DELAY = 180 days;

    IOneUp public immutable oneUpToken;
    IUniswapV2Router02 public immutable uniswap;

    event Provided(uint256 token, uint256 amount);
    event Recovered(address token, uint256 amount);


    constructor(address oneUpToken_, address uniswapRouter_) {
        oneUpToken = IOneUp(oneUpToken_);
        uniswap = IUniswapV2Router02(uniswapRouter_);
    }

    receive() external payable {
    }


    function addLiquidity() public override onlyOwner {

        uint256 balance = address(this).balance;
        require(balance > 0, 'addLiquidity: ETH balance is zero!');

        uint256 amountTokenDesired = balance.mul(UNISWAP_TOKEN_PRICE);
        oneUpToken.mint(address(this), amountTokenDesired);
        oneUpToken.approve(address(uniswap), amountTokenDesired);

        uniswap.addLiquidityETH{value: (balance)}(
            address(oneUpToken),
            amountTokenDesired,
            amountTokenDesired,
            balance,
            address(this),
            block.timestamp.add(2 hours)
        );

        lock = block.timestamp;
        emit Provided(amountTokenDesired, balance);
    }

    function recoverERC20(address lpTokenAddress, address receiver) public override onlyOwner {

        require(lock != 0, 'recoverERC20: Liquidity not added yet!');
        require(block.timestamp >= lock.add(LP_TOKENS_LOCK_DELAY), 'recoverERC20: You can claim LP tokens after 180 days!');

        IERC20 lpToken = IERC20(lpTokenAddress);
        uint256 balance = lpToken.balanceOf(address(this));
        lpToken.transfer(receiver, balance);

        emit Recovered(lpTokenAddress, balance);
    }
}