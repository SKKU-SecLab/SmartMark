pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

interface KineOracleInterface {


    function getUnderlyingPrice(address kToken) external view returns (uint);


    function postPrices(bytes[] calldata messages, bytes[] calldata signatures, string[] calldata symbols) external;


    function postMcdPrice(uint mcdPrice) external;


    function reporter() external returns (address);

}pragma solidity ^0.5.16;



contract KineControllerInterface {

    bool public constant isController = true;

    function getOracle() external view returns (address);



    function enterMarkets(address[] calldata kTokens) external;


    function exitMarket(address kToken) external;



    function mintAllowed(address kToken, address minter, uint mintAmount) external returns (bool, string memory);


    function mintVerify(address kToken, address minter, uint mintAmount, uint mintTokens) external;


    function redeemAllowed(address kToken, address redeemer, uint redeemTokens) external returns (bool, string memory);


    function redeemVerify(address kToken, address redeemer, uint redeemTokens) external;


    function borrowAllowed(address kToken, address borrower, uint borrowAmount) external returns (bool, string memory);


    function borrowVerify(address kToken, address borrower, uint borrowAmount) external;


    function repayBorrowAllowed(
        address kToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (bool, string memory);


    function repayBorrowVerify(
        address kToken,
        address payer,
        address borrower,
        uint repayAmount) external;


    function liquidateBorrowAllowed(
        address kTokenBorrowed,
        address kTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (bool, string memory);


    function liquidateBorrowVerify(
        address kTokenBorrowed,
        address kTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;


    function seizeAllowed(
        address kTokenCollateral,
        address kTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (bool, string memory);


    function seizeVerify(
        address kTokenCollateral,
        address kTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;


    function transferAllowed(address kToken, address src, address dst, uint transferTokens) external returns (bool, string memory);


    function transferVerify(address kToken, address src, address dst, uint transferTokens) external;



    function liquidateCalculateSeizeTokens(
        address target,
        address kTokenBorrowed,
        address kTokenCollateral,
        uint repayAmount) external view returns (uint);

}pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.5.16;


contract KUSDMinterDelegate is Ownable {

    event NewImplementation(address oldImplementation, address newImplementation);

    address public implementation;
}pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;



library KineSafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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
}pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using KineSafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using KineSafeMath for uint256;
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
}pragma solidity ^0.5.16;


interface IKineUSD {

    function mint(address account, uint amount) external;


    function burn(address account, uint amount) external;


    function balanceOf(address account) external view returns (uint256);

}

interface IKMCD {

    function borrowBehalf(address payable borrower, uint borrowAmount) external;


    function repayBorrowBehalf(address borrower, uint repayAmount) external;


    function liquidateBorrowBehalf(address liquidator, address borrower, uint repayAmount, address kTokenCollateral, uint minSeizeKToken) external;


    function borrowBalance(address account) external view returns (uint);


    function totalBorrows() external view returns (uint);

}

contract IRewardDistributionRecipient is KUSDMinterDelegate {

    event NewRewardDistribution(address oldRewardDistribution, address newRewardDistribution);

    address public rewardDistribution;

    function notifyRewardAmount(uint reward) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {

        address oldRewardDistribution = rewardDistribution;
        rewardDistribution = _rewardDistribution;
        emit NewRewardDistribution(oldRewardDistribution, _rewardDistribution);
    }
}

contract KUSDMinter is IRewardDistributionRecipient {

    using KineSafeMath for uint;
    using SafeERC20 for IERC20;

    event NewKMCD(address oldKMCD, address newKMCD);
    event NewKUSD(address oldKUSD, address newKUSD);
    event NewKine(address oldKine, address newKine);
    event NewRewardDuration(uint oldRewardDuration, uint newRewardDuration);
    event NewRewardReleasePeriod(uint oldRewardReleasePeriod, uint newRewardReleasePeriod);
    event NewBurnCooldownTime(uint oldCooldown, uint newCooldownTime);
    event Mint(address indexed user, uint mintKUSDAmount, uint stakedKMCDAmount, uint userStakesNew, uint totalStakesNew);
    event Burn(address indexed user, uint burntKUSDAmount, uint unstakedKMCDAmount, uint userStakesNew, uint totalStakesNew);
    event BurnMax(address indexed user, uint burntKUSDAmount, uint unstakedKMCDAmount, uint userStakesNew, uint totalStakesNew);
    event Liquidate(address indexed liquidator, address indexed staker, uint burntKUSDAmount, uint unstakedKMCDAmount, uint stakerStakesNew, uint totalStakesNew);
    event RewardAdded(uint reward);
    event RewardPaid(address indexed user, uint reward);
    event TreasuryMint(uint amount);
    event TreasuryBurn(uint amount);
    event NewTreasury(address oldTreasury, address newTreasury);
    event NewVault(address oldVault, address newVault);
    event NewController(address oldController, address newController);

    uint public constant REWARD_OVERFLOW_CHECK = 1.15792e59;

    address public implementation;

    bool public initialized;

    IKMCD public kMCD;

    IKineUSD public kUSD;

    KineControllerInterface public controller;

    address public treasury;

    address public vault;


    IERC20 public kine;
    uint public rewardDuration;
    uint public rewardReleasePeriod;
    uint public startTime;
    uint public periodFinish = 0;
    uint public rewardRate = 0;
    uint public rewardPerTokenStored;
    uint public lastUpdateTime;
    uint public burnCooldownTime;

    struct AccountRewardDetail {
        uint lastClaimTime;
        uint rewardPerTokenUpdated;
        uint accruedReward;
        uint lastMintTime;
    }

    mapping(address => AccountRewardDetail) public accountRewardDetails;

    function initialize(address kine_, address kUSD_, address kMCD_, address controller_, address treasury_, address vault_, address rewardDistribution_, uint startTime_, uint rewardDuration_, uint rewardReleasePeriod_) external {

        require(initialized == false, "KUSDMinter can only be initialized once");
        kine = IERC20(kine_);
        kUSD = IKineUSD(kUSD_);
        kMCD = IKMCD(kMCD_);
        controller = KineControllerInterface(controller_);
        treasury = treasury_;
        vault = vault_;
        rewardDistribution = rewardDistribution_;
        startTime = startTime_;
        rewardDuration = rewardDuration_;
        rewardReleasePeriod = rewardReleasePeriod_;
        initialized = true;
    }

    struct CalculateVars {
        uint equivalentKMCDAmount;
        uint equivalentKUSDAmount;
    }

    modifier checkStart() {

        require(block.timestamp >= startTime, "not started yet");
        _;
    }

    modifier onlyTreasury() {

        require(msg.sender == treasury, "only treasury account is allowed");
        _;
    }

    modifier afterCooldown(address staker) {

        require(accountRewardDetails[staker].lastMintTime.add(burnCooldownTime) < block.timestamp, "burn still cooling down");
        _;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            accountRewardDetails[account].accruedReward = earned(account);
            accountRewardDetails[account].rewardPerTokenUpdated = rewardPerTokenStored;
            if (accountRewardDetails[account].lastClaimTime == 0) {
                accountRewardDetails[account].lastClaimTime = block.timestamp;
            }
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint) {

        uint totalStakes = totalStakes();
        if (totalStakes == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalStakes)
        );
    }

    function earned(address account) public view returns (uint) {

        return accountStakes(account)
        .mul(rewardPerToken().sub(accountRewardDetails[account].rewardPerTokenUpdated))
        .div(1e18)
        .add(accountRewardDetails[account].accruedReward);
    }

    function claimable(address account) external view returns (uint) {

        uint accountNewAccruedReward = earned(account);
        uint pastTime = block.timestamp.sub(accountRewardDetails[account].lastClaimTime);
        uint maturedReward = rewardReleasePeriod == 0 ? accountNewAccruedReward : accountNewAccruedReward.mul(pastTime).div(rewardReleasePeriod);
        if (maturedReward > accountNewAccruedReward) {
            maturedReward = accountNewAccruedReward;
        }
        return maturedReward;
    }

    function mint(uint kUSDAmount) external checkStart updateReward(msg.sender) {

        address payable msgSender = _msgSender();
        accountRewardDetails[msgSender].lastMintTime = block.timestamp;

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "Mint: get Kine MCD price zero");

        CalculateVars memory vars;


        vars.equivalentKMCDAmount = kUSDAmount.mul(1e18).div(kMCDPriceMantissa);

        kMCD.borrowBehalf(msgSender, vars.equivalentKMCDAmount);

        kUSD.mint(msgSender, kUSDAmount);

        emit Mint(msgSender, kUSDAmount, vars.equivalentKMCDAmount, accountStakes(msgSender), totalStakes());
    }

    function burn(uint kUSDAmount) external checkStart afterCooldown(msg.sender) updateReward(msg.sender) {

        address msgSender = _msgSender();

        kUSD.burn(msgSender, kUSDAmount);

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "Burn: get Kine MCD price zero");

        CalculateVars memory vars;


        vars.equivalentKMCDAmount = kUSDAmount.mul(1e18).div(kMCDPriceMantissa);

        kMCD.repayBorrowBehalf(msgSender, vars.equivalentKMCDAmount);

        emit Burn(msgSender, kUSDAmount, vars.equivalentKMCDAmount, accountStakes(msgSender), totalStakes());
    }

    function burnMax() external checkStart afterCooldown(msg.sender) updateReward(msg.sender) {

        address msgSender = _msgSender();

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "BurnMax: get Kine MCD price zero");

        CalculateVars memory vars;


        uint userStakes = accountStakes(msgSender);
        vars.equivalentKMCDAmount = userStakes;
        vars.equivalentKUSDAmount = userStakes.mul(kMCDPriceMantissa).div(1e18);

        uint kUSDbalance = kUSD.balanceOf(msgSender);
        if (vars.equivalentKUSDAmount > kUSDbalance) {
            vars.equivalentKUSDAmount = kUSDbalance;
            vars.equivalentKMCDAmount = kUSDbalance.mul(1e18).div(kMCDPriceMantissa);
        }

        kUSD.burn(msgSender, vars.equivalentKUSDAmount);

        kMCD.repayBorrowBehalf(msgSender, vars.equivalentKMCDAmount);

        emit BurnMax(msgSender, vars.equivalentKUSDAmount, vars.equivalentKMCDAmount, accountStakes(msgSender), totalStakes());
    }

    function liquidate(address staker, uint unstakeKMCDAmount, uint maxBurnKUSDAmount, address kTokenCollateral, uint minSeizeKToken) external checkStart updateReward(staker) {

        address msgSender = _msgSender();

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "Liquidate: get Kine MCD price zero");

        CalculateVars memory vars;


        vars.equivalentKUSDAmount = unstakeKMCDAmount.mul(kMCDPriceMantissa).div(1e18);

        require(maxBurnKUSDAmount >= vars.equivalentKUSDAmount, "Liquidate: reach out max burn KUSD amount limit");

        kUSD.burn(msgSender, vars.equivalentKUSDAmount);

        kMCD.liquidateBorrowBehalf(msgSender, staker, unstakeKMCDAmount, kTokenCollateral, minSeizeKToken);

        emit Liquidate(msgSender, staker, vars.equivalentKUSDAmount, unstakeKMCDAmount, accountStakes(staker), totalStakes());
    }

    function accountStakes(address account) public view returns (uint) {

        return kMCD.borrowBalance(account);
    }

    function totalStakes() public view returns (uint) {

        return kMCD.totalBorrows();
    }

    function getReward() external checkStart updateReward(msg.sender) {

        uint reward = accountRewardDetails[msg.sender].accruedReward;
        if (reward > 0) {
            uint pastTime = block.timestamp.sub(accountRewardDetails[msg.sender].lastClaimTime);
            uint maturedReward = rewardReleasePeriod == 0 ? reward : reward.mul(pastTime).div(rewardReleasePeriod);
            if (maturedReward > reward) {
                maturedReward = reward;
            }

            accountRewardDetails[msg.sender].accruedReward = reward.sub(maturedReward);
            accountRewardDetails[msg.sender].lastClaimTime = block.timestamp;
            kine.safeTransfer(msg.sender, maturedReward);
            emit RewardPaid(msg.sender, maturedReward);
        }
    }

    function notifyRewardAmount(uint reward) external onlyRewardDistribution updateReward(address(0)) {

        if (block.timestamp > startTime) {
            if (block.timestamp >= periodFinish) {
                require(reward < REWARD_OVERFLOW_CHECK, "reward rate will overflow");
                rewardRate = reward.div(rewardDuration);
            } else {
                uint remaining = periodFinish.sub(block.timestamp);
                uint leftover = remaining.mul(rewardRate);
                require(reward.add(leftover) < REWARD_OVERFLOW_CHECK, "reward rate will overflow");
                rewardRate = reward.add(leftover).div(rewardDuration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(rewardDuration);
            emit RewardAdded(reward);
        } else {
            require(reward < REWARD_OVERFLOW_CHECK, "reward rate will overflow");
            rewardRate = reward.div(rewardDuration);
            lastUpdateTime = startTime;
            periodFinish = startTime.add(rewardDuration);
            emit RewardAdded(reward);
        }
    }

    function _setRewardDuration(uint newRewardDuration) external onlyOwner updateReward(address(0)) {

        uint oldRewardDuration = rewardDuration;
        rewardDuration = newRewardDuration;

        if (block.timestamp > startTime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = 0;
            } else {
                uint remaining = periodFinish.sub(block.timestamp);
                uint leftover = remaining.mul(rewardRate);
                rewardRate = leftover.div(rewardDuration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(rewardDuration);
        } else {
            rewardRate = rewardRate.mul(oldRewardDuration).div(rewardDuration);
            lastUpdateTime = startTime;
            periodFinish = startTime.add(rewardDuration);
        }

        emit NewRewardDuration(oldRewardDuration, newRewardDuration);
    }

    function _setRewardReleasePeriod(uint newRewardReleasePeriod) external onlyOwner updateReward(address(0)) {

        uint oldRewardReleasePeriod = rewardReleasePeriod;
        rewardReleasePeriod = newRewardReleasePeriod;
        emit NewRewardReleasePeriod(oldRewardReleasePeriod, newRewardReleasePeriod);
    }

    function _setCooldownTime(uint newCooldownTime) external onlyOwner {

        uint oldCooldown = burnCooldownTime;
        burnCooldownTime = newCooldownTime;
        emit NewBurnCooldownTime(oldCooldown, newCooldownTime);
    }

    function treasuryMint(uint amount) external onlyTreasury {

        kUSD.mint(vault, amount);
        emit TreasuryMint(amount);
    }

    function treasuryBurn(uint amount) external onlyTreasury {

        kUSD.burn(vault, amount);
        emit TreasuryBurn(amount);
    }

    function _setTreasury(address newTreasury) external onlyOwner {

        address oldTreasury = treasury;
        treasury = newTreasury;
        emit NewTreasury(oldTreasury, newTreasury);
    }

    function _setVault(address newVault) external onlyOwner {

        address oldVault = vault;
        vault = newVault;
        emit NewVault(oldVault, newVault);
    }

    function _setKMCD(address newKMCD) external onlyOwner {

        address oldKMCD = address(kMCD);
        kMCD = IKMCD(newKMCD);
        emit NewKMCD(oldKMCD, newKMCD);
    }

    function _setKUSD(address newKUSD) external onlyOwner {

        address oldKUSD = address(kUSD);
        kUSD = IKineUSD(newKUSD);
        emit NewKUSD(oldKUSD, newKUSD);
    }

    function _setKine(address newKine) external onlyOwner {

        address oldKine = address(kine);
        kine = IERC20(newKine);
        emit NewKine(oldKine, newKine);
    }
    function _setController(address newController) external onlyOwner {

        address oldController = address(controller);
        controller = KineControllerInterface(newController);
        emit NewController(oldController, newController);
    }
}pragma solidity ^0.5.16;


interface LiquidatorWhitelistInterface {

    function isListed(address liquidatorToVerify) external view returns (bool);

}

contract KUSDMinterV3 is IRewardDistributionRecipient {

    using KineSafeMath for uint;
    using SafeERC20 for IERC20;

    event NewKMCD(address oldKMCD, address newKMCD);
    event NewKUSD(address oldKUSD, address newKUSD);
    event NewRewardToken(address oldRewardToken, address newRewardToken, uint scaleParam, uint leftOverReward, uint replaceReward, address leftoverTokenReceipient);
    event NewRewardDuration(uint oldRewardDuration, uint newRewardDuration);
    event NewRewardReleasePeriod(uint oldRewardReleasePeriod, uint newRewardReleasePeriod);
    event NewBurnCooldownTime(uint oldCooldown, uint newCooldownTime);
    event Mint(address indexed user, uint mintKUSDAmount, uint stakedKMCDAmount, uint userStakesNew, uint totalStakesNew);
    event Burn(address indexed user, uint burntKUSDAmount, uint unstakedKMCDAmount, uint userStakesNew, uint totalStakesNew);
    event BurnMax(address indexed user, uint burntKUSDAmount, uint unstakedKMCDAmount, uint userStakesNew, uint totalStakesNew);
    event Liquidate(address indexed liquidator, address indexed staker, uint burntKUSDAmount, uint unstakedKMCDAmount, uint stakerStakesNew, uint totalStakesNew);
    event RewardAdded(uint reward);
    event RewardPaid(address indexed user, uint reward);
    event TreasuryMint(uint amount);
    event TreasuryBurn(uint amount);
    event NewTreasury(address oldTreasury, address newTreasury);
    event NewVault(address oldVault, address newVault);
    event NewController(address oldController, address newController);
    event NewLiquidatorWhitelist(address oldLiquidatorWhitelist, address newLiquidatorWhitelist);

    uint public constant REWARD_OVERFLOW_CHECK = 1.15792e59;

    address public implementation;

    bool public initialized;

    IKMCD public kMCD;

    IKineUSD public kUSD;

    KineControllerInterface public controller;

    address public treasury;

    address public vault;


    IERC20 public rewardToken;
    uint public rewardDuration;
    uint public rewardReleasePeriod;
    uint public startTime;
    uint public periodFinish = 0;
    uint public rewardRate = 0;
    uint public rewardPerTokenStored;
    uint public lastUpdateTime;
    uint public burnCooldownTime;

    struct AccountRewardDetail {
        uint lastClaimTime;
        uint rewardPerTokenUpdated;
        uint accruedReward;
        uint lastMintTime;
        uint scaleParamIndex;
    }

    mapping(address => AccountRewardDetail) public accountRewardDetails;

    uint public currentScaleParamIndex;
    uint[] public scaleParams;

    LiquidatorWhitelistInterface public liquidatorWhitelist;

    function initialize(address rewardToken_, address kUSD_, address kMCD_, address controller_, address treasury_, address vault_, address rewardDistribution_, uint startTime_, uint rewardDuration_, uint rewardReleasePeriod_) external {

        require(initialized == false, "KUSDMinter can only be initialized once");
        rewardToken = IERC20(rewardToken_);
        kUSD = IKineUSD(kUSD_);
        kMCD = IKMCD(kMCD_);
        controller = KineControllerInterface(controller_);
        treasury = treasury_;
        vault = vault_;
        rewardDistribution = rewardDistribution_;
        startTime = startTime_;
        rewardDuration = rewardDuration_;
        rewardReleasePeriod = rewardReleasePeriod_;
        initialized = true;
    }

    struct CalculateVars {
        uint equivalentKMCDAmount;
        uint equivalentKUSDAmount;
    }

    modifier checkStart() {

        require(block.timestamp >= startTime, "not started yet");
        _;
    }

    modifier onlyTreasury() {

        require(msg.sender == treasury, "only treasury account is allowed");
        _;
    }

    modifier afterCooldown(address staker) {

        require(accountRewardDetails[staker].lastMintTime.add(burnCooldownTime) < block.timestamp, "burn still cooling down");
        _;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            accountRewardDetails[account].accruedReward = earned(account);
            accountRewardDetails[account].rewardPerTokenUpdated = rewardPerTokenStored;
            accountRewardDetails[account].scaleParamIndex = currentScaleParamIndex;
            if (accountRewardDetails[account].lastClaimTime == 0) {
                accountRewardDetails[account].lastClaimTime = block.timestamp;
            }
        }
        _;
    }

    modifier checkLiquidator() {

        LiquidatorWhitelistInterface lc = liquidatorWhitelist;
        require(address(lc) != address(0) && lc.isListed(msg.sender), "not valid liquidator");
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint) {

        uint totalStakes = totalStakes();
        if (totalStakes == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalStakes)
        );
    }

    function earned(address account) public view returns (uint) {

        AccountRewardDetail memory detail = accountRewardDetails[account];
        uint scaledRewardPerTokenUpdated = detail.rewardPerTokenUpdated;
        uint scaledAccruedReward = detail.accruedReward;
        for (uint i = detail.scaleParamIndex; i < currentScaleParamIndex; i++) {
            scaledRewardPerTokenUpdated = scaledRewardPerTokenUpdated.mul(scaleParams[i]).div(1e18);
            scaledAccruedReward = scaledAccruedReward.mul(scaleParams[i]).div(1e18);
        }

        return accountStakes(account)
        .mul(rewardPerToken().sub(scaledRewardPerTokenUpdated))
        .div(1e18)
        .add(scaledAccruedReward);
    }

    function claimable(address account) external view returns (uint) {

        uint accountNewAccruedReward = earned(account);
        uint pastTime = block.timestamp.sub(accountRewardDetails[account].lastClaimTime);
        uint maturedReward = rewardReleasePeriod == 0 ? accountNewAccruedReward : accountNewAccruedReward.mul(pastTime).div(rewardReleasePeriod);
        if (maturedReward > accountNewAccruedReward) {
            maturedReward = accountNewAccruedReward;
        }
        return maturedReward;
    }

    function mint(uint kUSDAmount) external checkStart updateReward(msg.sender) {

        address payable msgSender = _msgSender();
        accountRewardDetails[msgSender].lastMintTime = block.timestamp;

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "Mint: get Kine MCD price zero");

        CalculateVars memory vars;


        vars.equivalentKMCDAmount = kUSDAmount.mul(1e18).div(kMCDPriceMantissa);

        kMCD.borrowBehalf(msgSender, vars.equivalentKMCDAmount);

        kUSD.mint(msgSender, kUSDAmount);

        emit Mint(msgSender, kUSDAmount, vars.equivalentKMCDAmount, accountStakes(msgSender), totalStakes());
    }

    function burn(uint kUSDAmount) external checkStart afterCooldown(msg.sender) updateReward(msg.sender) {

        address msgSender = _msgSender();

        kUSD.burn(msgSender, kUSDAmount);

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "Burn: get Kine MCD price zero");

        CalculateVars memory vars;


        vars.equivalentKMCDAmount = kUSDAmount.mul(1e18).div(kMCDPriceMantissa);

        kMCD.repayBorrowBehalf(msgSender, vars.equivalentKMCDAmount);

        emit Burn(msgSender, kUSDAmount, vars.equivalentKMCDAmount, accountStakes(msgSender), totalStakes());
    }

    function burnMax() external checkStart afterCooldown(msg.sender) updateReward(msg.sender) {

        address msgSender = _msgSender();

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "BurnMax: get Kine MCD price zero");

        CalculateVars memory vars;


        uint userStakes = accountStakes(msgSender);
        vars.equivalentKMCDAmount = userStakes;
        vars.equivalentKUSDAmount = userStakes.mul(kMCDPriceMantissa).div(1e18);

        uint kUSDbalance = kUSD.balanceOf(msgSender);
        if (vars.equivalentKUSDAmount > kUSDbalance) {
            vars.equivalentKUSDAmount = kUSDbalance;
            vars.equivalentKMCDAmount = kUSDbalance.mul(1e18).div(kMCDPriceMantissa);
        }

        kUSD.burn(msgSender, vars.equivalentKUSDAmount);

        kMCD.repayBorrowBehalf(msgSender, vars.equivalentKMCDAmount);

        emit BurnMax(msgSender, vars.equivalentKUSDAmount, vars.equivalentKMCDAmount, accountStakes(msgSender), totalStakes());
    }

    function liquidate(address staker, uint unstakeKMCDAmount, uint maxBurnKUSDAmount, address kTokenCollateral, uint minSeizeKToken) external checkLiquidator checkStart updateReward(staker) {

        address msgSender = _msgSender();

        uint kMCDPriceMantissa = KineOracleInterface(controller.getOracle()).getUnderlyingPrice(address(kMCD));
        require(kMCDPriceMantissa != 0, "Liquidate: get Kine MCD price zero");

        CalculateVars memory vars;


        vars.equivalentKUSDAmount = unstakeKMCDAmount.mul(kMCDPriceMantissa).div(1e18);

        require(maxBurnKUSDAmount >= vars.equivalentKUSDAmount, "Liquidate: reach out max burn KUSD amount limit");

        kUSD.burn(msgSender, vars.equivalentKUSDAmount);

        kMCD.liquidateBorrowBehalf(msgSender, staker, unstakeKMCDAmount, kTokenCollateral, minSeizeKToken);

        emit Liquidate(msgSender, staker, vars.equivalentKUSDAmount, unstakeKMCDAmount, accountStakes(staker), totalStakes());
    }

    function accountStakes(address account) public view returns (uint) {

        return kMCD.borrowBalance(account);
    }

    function totalStakes() public view returns (uint) {

        return kMCD.totalBorrows();
    }

    function getReward() external checkStart updateReward(msg.sender) {

        uint reward = accountRewardDetails[msg.sender].accruedReward;
        if (reward > 0) {
            uint pastTime = block.timestamp.sub(accountRewardDetails[msg.sender].lastClaimTime);
            uint maturedReward = rewardReleasePeriod == 0 ? reward : reward.mul(pastTime).div(rewardReleasePeriod);
            if (maturedReward > reward) {
                maturedReward = reward;
            }

            accountRewardDetails[msg.sender].accruedReward = reward.sub(maturedReward);
            accountRewardDetails[msg.sender].lastClaimTime = block.timestamp;
            rewardToken.safeTransfer(msg.sender, maturedReward);
            emit RewardPaid(msg.sender, maturedReward);
        }
    }

    function notifyRewardAmount(uint reward) external onlyRewardDistribution updateReward(address(0)) {

        if (block.timestamp > startTime) {
            if (block.timestamp >= periodFinish) {
                require(reward < REWARD_OVERFLOW_CHECK, "reward rate will overflow");
                rewardRate = reward.div(rewardDuration);
            } else {
                uint remaining = periodFinish.sub(block.timestamp);
                uint leftover = remaining.mul(rewardRate);
                require(reward.add(leftover) < REWARD_OVERFLOW_CHECK, "reward rate will overflow");
                rewardRate = reward.add(leftover).div(rewardDuration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(rewardDuration);
            emit RewardAdded(reward);
        } else {
            require(reward < REWARD_OVERFLOW_CHECK, "reward rate will overflow");
            rewardRate = reward.div(rewardDuration);
            lastUpdateTime = startTime;
            periodFinish = startTime.add(rewardDuration);
            emit RewardAdded(reward);
        }
    }

    function _setRewardDuration(uint newRewardDuration) external onlyOwner updateReward(address(0)) {

        uint oldRewardDuration = rewardDuration;
        rewardDuration = newRewardDuration;

        if (block.timestamp > startTime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = 0;
            } else {
                uint remaining = periodFinish.sub(block.timestamp);
                uint leftover = remaining.mul(rewardRate);
                rewardRate = leftover.div(rewardDuration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(rewardDuration);
        } else {
            rewardRate = rewardRate.mul(oldRewardDuration).div(rewardDuration);
            lastUpdateTime = startTime;
            periodFinish = startTime.add(rewardDuration);
        }

        emit NewRewardDuration(oldRewardDuration, newRewardDuration);
    }

    function _setRewardReleasePeriod(uint newRewardReleasePeriod) external onlyOwner updateReward(address(0)) {

        uint oldRewardReleasePeriod = rewardReleasePeriod;
        rewardReleasePeriod = newRewardReleasePeriod;
        emit NewRewardReleasePeriod(oldRewardReleasePeriod, newRewardReleasePeriod);
    }

    function _setCooldownTime(uint newCooldownTime) external onlyOwner {

        uint oldCooldown = burnCooldownTime;
        burnCooldownTime = newCooldownTime;
        emit NewBurnCooldownTime(oldCooldown, newCooldownTime);
    }

    function treasuryMint(uint amount) external onlyTreasury {

        kUSD.mint(vault, amount);
        emit TreasuryMint(amount);
    }

    function treasuryBurn(uint amount) external onlyTreasury {

        kUSD.burn(vault, amount);
        emit TreasuryBurn(amount);
    }

    function _setTreasury(address newTreasury) external onlyOwner {

        address oldTreasury = treasury;
        treasury = newTreasury;
        emit NewTreasury(oldTreasury, newTreasury);
    }

    function _setVault(address newVault) external onlyOwner {

        address oldVault = vault;
        vault = newVault;
        emit NewVault(oldVault, newVault);
    }

    function _setKMCD(address newKMCD) external onlyOwner {

        address oldKMCD = address(kMCD);
        kMCD = IKMCD(newKMCD);
        emit NewKMCD(oldKMCD, newKMCD);
    }

    function _setKUSD(address newKUSD) external onlyOwner {

        address oldKUSD = address(kUSD);
        kUSD = IKineUSD(newKUSD);
        emit NewKUSD(oldKUSD, newKUSD);
    }

    function _setController(address newController) external onlyOwner {

        address oldController = address(controller);
        controller = KineControllerInterface(newController);
        emit NewController(oldController, newController);
    }

    function _changeRewardToken(address newRewardToken, uint scaleParam, address tokenHolder) external onlyOwner updateReward(address(0)) {

        require(block.timestamp > periodFinish, "period not finished yet");
        rewardPerTokenStored = rewardPerTokenStored.mul(scaleParam).div(1e18);
        rewardRate = rewardRate.mul(scaleParam).div(1e18);

        scaleParams.push(scaleParam);
        currentScaleParamIndex++;

        uint leftOverReward = rewardToken.balanceOf(address(this));
        rewardToken.safeTransfer(tokenHolder, leftOverReward);

        address oldRewardToken = address(rewardToken);
        rewardToken = IERC20(newRewardToken);

        uint replaceReward = leftOverReward.mul(scaleParam).div(1e18);
        rewardToken.safeTransferFrom(tokenHolder, address(this), replaceReward);

        emit NewRewardToken(oldRewardToken, newRewardToken, scaleParam, leftOverReward, replaceReward, tokenHolder);
    }

    function _setLiquidatorWhitelist(address newLiquidatorWhitelist) external onlyOwner {

        address oldLiquidatorWhitelist = address(liquidatorWhitelist);
        require(oldLiquidatorWhitelist != newLiquidatorWhitelist, "same address");
        liquidatorWhitelist = LiquidatorWhitelistInterface(newLiquidatorWhitelist);
        emit NewLiquidatorWhitelist(oldLiquidatorWhitelist, newLiquidatorWhitelist);
    }
}