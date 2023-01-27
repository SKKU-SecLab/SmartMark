

pragma experimental ABIEncoderV2;



pragma solidity ^0.5.0;

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


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
}


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




library Math {

    using SafeMath for uint256;


    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(numerator).div(denominator);
    }

    function to128(
        uint256 number
    )
        internal
        pure
        returns (uint128)
    {

        uint128 result = uint128(number);
        require(
            result == number,
            "Math: Unsafe cast to uint128"
        );
        return result;
    }

    function to96(
        uint256 number
    )
        internal
        pure
        returns (uint96)
    {

        uint96 result = uint96(number);
        require(
            result == number,
            "Math: Unsafe cast to uint96"
        );
        return result;
    }

    function to32(
        uint256 number
    )
        internal
        pure
        returns (uint32)
    {

        uint32 result = uint32(number);
        require(
            result == number,
            "Math: Unsafe cast to uint32"
        );
        return result;
    }

    function min(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }

    function max(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a > b ? a : b;
    }
}



library Decimal {

    using SafeMath for uint256;


    uint256 constant BASE = 10**18;


    struct D256 {
        uint256 value;
    }


    function one()
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: BASE });
    }

    function onePlus(
        D256 memory d
    )
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: d.value.add(BASE) });
    }

    function mul(
        uint256 target,
        D256 memory d
    )
        internal
        pure
        returns (uint256)
    {

        return Math.getPartial(target, d.value, BASE);
    }

    function mul(
        D256 memory d1,
        D256 memory d2
    )
        internal
        pure
        returns (D256 memory)
    {

        return Decimal.D256({ value: Math.getPartial(d1.value, d2.value, BASE) });
    }

    function div(
        uint256 target,
        D256 memory d
    )
        internal
        pure
        returns (uint256)
    {

        return Math.getPartial(target, BASE, d.value);
    }

    function add(
        D256 memory d,
        uint256 amount
    )
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: d.value.add(amount) });
    }

    function sub(
        D256 memory d,
        uint256 amount
    )
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: d.value.sub(amount) });
    }

}




interface ISyntheticToken {


    function symbolKey()
        external
        view
        returns (bytes32);


    function mint(
        address to,
        uint256 value
    )
        external;


    function burn(
        address to,
        uint256 value
    )
        external;


    function transferCollateral(
        address token,
        address to,
        uint256 value
    )
        external
        returns (bool);



}




interface IMintableToken {


    function mint(
        address to,
        uint256 value
    )
        external;


    function burn(
        address to,
        uint256 value
    )
        external;


}




interface IOracle {


    function fetchCurrentPrice()
        external
        view
        returns (Decimal.D256 memory);


}




library TypesV1 {


    using Math for uint256;
    using SafeMath for uint256;


    enum AssetType {
        Collateral,
        Synthetic
    }


    struct MarketParams {
        Decimal.D256 collateralRatio;
        Decimal.D256 liquidationUserFee;
        Decimal.D256 liquidationArcFee;
    }

    struct Position {
        address owner;
        AssetType collateralAsset;
        AssetType borrowedAsset;
        Par collateralAmount;
        Par borrowedAmount;
    }

    struct RiskParams {
        uint256 collateralLimit;
        uint256 syntheticLimit;
        uint256 positionCollateralMinimum;
    }


    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par  // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }


    function oppositeAsset(
        AssetType assetType
    )
        internal
        pure
        returns (AssetType)
    {

        return assetType == AssetType.Collateral ? AssetType.Synthetic : AssetType.Collateral;
    }


    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    function zeroPar()
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: false,
            value: 0
        });
    }

    function positiveZeroPar()
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: true,
            value: 0
        });
    }

    function sub(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (Par memory)
    {

        return add(a, negative(b));
    }

    function add(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (Par memory)
    {

        Par memory result;
        if (a.sign == b.sign) {
            result.sign = a.sign;
            result.value = SafeMath.add(a.value, b.value).to128();
        } else {
            if (a.value >= b.value) {
                result.sign = a.sign;
                result.value = SafeMath.sub(a.value, b.value).to128();
            } else {
                result.sign = b.sign;
                result.value = SafeMath.sub(b.value, a.value).to128();
            }
        }
        return result;
    }

    function equals(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (bool)
    {

        if (a.value == b.value) {
            if (a.value == 0) {
                return true;
            }
            return a.sign == b.sign;
        }
        return false;
    }

    function negative(
        Par memory a
    )
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: !a.sign,
            value: a.value
        });
    }

    function isNegative(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return !a.sign && a.value > 0;
    }

    function isPositive(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.sign && a.value > 0;
    }

    function isZero(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.value == 0;
    }

}




interface IKYFV2 {


    function checkVerified(
        address _user
    )
        external
        view
        returns (bool);


}




interface IStateV1 {


    function getPosition(
        uint256 id
    )
        external
        view
        returns (TypesV1.Position memory);


}



contract RewardCampaign is Ownable {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct Staker {
        uint256 positionId;
        uint256 debtSnapshot;
        uint256 balance;
        uint256 rewardPerTokenStored;
        uint256 rewardPerTokenPaid;
        uint256 rewardsEarned;
        uint256 rewardsReleased;
    }


    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    IStateV1 public stateContract;

    address public arcDAO;
    address public rewardsDistributor;

    mapping (address => Staker) public stakers;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    Decimal.D256 public daoAllocation;
    Decimal.D256 public slasherCut;

    uint256 public hardCap;
    uint256 public vestingEndDate;
    uint256 public debtToStake;

    bool public tokensClaimable;

    uint256 private _totalSupply;

    mapping (address => bool) public kyfInstances;

    address[] public kyfInstancesArray;


    event RewardAdded (uint256 reward);

    event Staked(address indexed user, uint256 amount);

    event Withdrawn(address indexed user, uint256 amount);

    event RewardPaid(address indexed user, uint256 reward);

    event RewardsDurationUpdated(uint256 newDuration);

    event Recovered(address token, uint256 amount);

    event HardCapSet(uint256 _cap);

    event KyfStatusUpdated(address _address, bool _status);

    event PositionStaked(address _address, uint256 _positionId);

    event ClaimableStatusUpdated(bool _status);

    event UserSlashed(address _user, address _slasher, uint256 _amount);


    modifier updateReward(address account) {

        rewardPerTokenStored = actualRewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            stakers[account].rewardsEarned = actualEarned(account);
            stakers[account].rewardPerTokenPaid = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyRewardsDistributor() {

        require(
            msg.sender == rewardsDistributor,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }


    function setRewardsDistributor(
        address _rewardsDistributor
    )
        external
        onlyOwner
    {

        rewardsDistributor = _rewardsDistributor;
    }

    function setRewardsDuration(
        uint256 _rewardsDuration
    )
        external
        onlyOwner
    {

        require(
            periodFinish == 0 || getCurrentTimestamp() > periodFinish,
            "Prev period must be complete before changing duration for new period"
        );

        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function notifyRewardAmount(
        uint256 reward
    )
        external
        onlyRewardsDistributor
        updateReward(address(0))
    {

        if (getCurrentTimestamp() >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(getCurrentTimestamp());
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        uint balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = getCurrentTimestamp();
        periodFinish = getCurrentTimestamp().add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    )
        public
        onlyOwner
    {

        require(
            tokenAddress != address(stakingToken) && tokenAddress != address(rewardsToken),
            "Cannot withdraw the staking or rewards tokens"
        );

        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setTokensClaimable(
        bool _enabled
    )
        public
        onlyOwner
    {

        tokensClaimable = _enabled;

        emit ClaimableStatusUpdated(_enabled);
    }

    function init(
        address _arcDAO,
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
        Decimal.D256 memory _daoAllocation,
        Decimal.D256 memory _slasherCut,
        address _stateContract,
        uint256 _vestingEndDate,
        uint256 _debtToStake,
        uint256 _hardCap
    )
        public
    {

        require(
            owner() == address(0) || owner() == msg.sender,
            "Must be the owner to deploy"
        );

        transferOwnership(msg.sender);

        arcDAO = _arcDAO;
        rewardsDistributor = _rewardsDistribution;
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);

        daoAllocation = _daoAllocation;
        slasherCut = _slasherCut;
        rewardsToken = IERC20(_rewardsToken);
        stateContract = IStateV1(_stateContract);
        vestingEndDate = _vestingEndDate;
        debtToStake = _debtToStake;
        hardCap = _hardCap;
    }

    function setApprovedKYFInstance(
        address _kyfContract,
        bool _status
    )
        public
        onlyOwner
    {

        if (_status == true) {
            kyfInstancesArray.push(_kyfContract);
            kyfInstances[_kyfContract] = true;
            emit KyfStatusUpdated(_kyfContract, true);
            return;
        }

        for (uint i = 0; i < kyfInstancesArray.length; i++) {
            if (address(kyfInstancesArray[i]) == _kyfContract) {
                delete kyfInstancesArray[i];
                kyfInstancesArray[i] = kyfInstancesArray[kyfInstancesArray.length - 1];

                kyfInstancesArray.length--;
                break;
            }
        }

        delete kyfInstances[_kyfContract];
        emit KyfStatusUpdated(_kyfContract, false);
    }


    function totalSupply()
        public
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(
        address account
    )
        public
        view
        returns (uint256)
    {

        return stakers[account].balance;
    }

    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {

        return getCurrentTimestamp() < periodFinish ? getCurrentTimestamp() : periodFinish;
    }

    function actualRewardPerToken()
        internal
        view
        returns (uint256)
    {

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function rewardPerToken()
        public
        view
        returns (uint256)
    {

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored.add(
                Decimal.mul(
                    lastTimeRewardApplicable()
                        .sub(lastUpdateTime)
                        .mul(rewardRate)
                        .mul(1e18)
                        .div(_totalSupply),
                    userAllocation()
                )
            );
    }

    function actualEarned(
        address account
    )
        internal
        view
        returns (uint256)
    {

        return stakers[account]
            .balance
            .mul(actualRewardPerToken().sub(stakers[account].rewardPerTokenPaid))
            .div(1e18)
            .add(stakers[account].rewardsEarned);
    }

    function earned(
        address account
    )
        public
        view
        returns (uint256)
    {

        return Decimal.mul(
            actualEarned(account),
            userAllocation()
        );
    }

    function getRewardForDuration()
        public
        view
        returns (uint256)
    {

        return rewardRate.mul(rewardsDuration);
    }

     function getCurrentTimestamp()
        public
        view
        returns (uint256)
    {

        return block.timestamp;
    }

    function isVerified(
        address _user
    )
        public
        view
        returns (bool)
    {

        for (uint256 i = 0; i < kyfInstancesArray.length; i++) {
            IKYFV2 kyfContract = IKYFV2(kyfInstancesArray[i]);
            if (kyfContract.checkVerified(_user) == true) {
                return true;
            }
        }

        return false;
    }

    function isMinter(
        address _user,
        uint256 _amount,
        uint256 _positionId
    )
        public
        view
        returns (bool)
    {

        TypesV1.Position memory position = stateContract.getPosition(_positionId);

        if (position.owner != _user) {
            return false;
        }

        return uint256(position.borrowedAmount.value) >= _amount;
    }

    function  userAllocation()
        public
        view
        returns (Decimal.D256 memory)
    {
        return Decimal.sub(
            Decimal.one(),
            daoAllocation.value
        );
    }


    function stake(
        uint256 amount,
        uint256 positionId
    )
        external
        updateReward(msg.sender)
    {

        uint256 totalBalance = balanceOf(msg.sender).add(amount);

        require(
            totalBalance <= hardCap,
            "Cannot stake more than the hard cap"
        );

        require(
            isVerified(msg.sender) == true,
            "Must be KYF registered to participate"
        );

        uint256 debtRequirement = amount.div(debtToStake);

        require(
            isMinter(msg.sender, debtRequirement, positionId),
            "Must be a valid minter"
        );

        Staker storage staker = stakers[msg.sender];


        require(
            debtRequirement >= staker.debtSnapshot,
            "Your new debt requiremen cannot be lower than last time"
        );

        staker.positionId = positionId;
        staker.debtSnapshot = debtRequirement;
        staker.balance = staker.balance.add(amount);

        _totalSupply = _totalSupply.add(amount);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function slash(
        address user
    )
        external
        updateReward(user)
    {

        require(
            user != msg.sender,
            "You cannot slash yourself"
        );

        require(
            getCurrentTimestamp() < vestingEndDate,
            "You cannot slash after the vesting end date"
        );

        Staker storage userStaker = stakers[user];

        require(
            isMinter(user, userStaker.debtSnapshot, userStaker.positionId) == false,
            "You can't slash a user who is a valid minter"
        );

        uint256 penalty = userStaker.rewardsEarned;
        uint256 bounty = Decimal.mul(penalty, slasherCut);

        stakers[msg.sender].rewardsEarned = stakers[msg.sender].rewardsEarned.add(bounty);
        stakers[rewardsDistributor].rewardsEarned = stakers[rewardsDistributor].rewardsEarned.add(
            penalty.sub(bounty)
        );

        userStaker.rewardsEarned = 0;

        emit UserSlashed(user, msg.sender, penalty);

    }

    function getReward(address user)
        public
        updateReward(user)
    {

        require(
            tokensClaimable == true,
            "Tokens cannnot be claimed yet"
        );

        if (getCurrentTimestamp() < periodFinish) {
            return;
        }

        Staker storage staker = stakers[user];

        uint256 totalAmount = staker.rewardsEarned.sub(staker.rewardsReleased);
        uint256 payableAmount = totalAmount;
        uint256 duration = vestingEndDate.sub(periodFinish);

        if (getCurrentTimestamp() < vestingEndDate) {
            payableAmount = totalAmount.mul(getCurrentTimestamp().sub(periodFinish)).div(duration);
        }

        staker.rewardsReleased = staker.rewardsReleased.add(payableAmount);

        uint256 daoPayable = Decimal.mul(payableAmount, daoAllocation);

        rewardsToken.safeTransfer(arcDAO, daoPayable);
        rewardsToken.safeTransfer(user, payableAmount.sub(daoPayable));

        emit RewardPaid(user, payableAmount);
    }

    function withdraw(
        uint256 amount
    )
        public
        updateReward(msg.sender)
    {

        require(
            amount >= 0,
            "Cannot withdraw less than 0"
        );

        _totalSupply = _totalSupply.sub(amount);
        stakers[msg.sender].balance = stakers[msg.sender].balance.sub(amount);

        stakingToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function exit()
        public
    {

        getReward(msg.sender);
        withdraw(balanceOf(msg.sender));
    }

}