
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.1;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface ITokenInterface {

    function underlying() external view returns (address);


    function supplyRatePerBlock() external view returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function redeem(uint256 redeemTokens) external returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface StakingRewardsInterface {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function lastTimeRewardApplicable(address _rewardsToken)
        external
        view
        returns (uint256);


    function rewardPerToken(address _rewardsToken)
        external
        view
        returns (uint256);


    function earned(address _rewardsToken, address account)
        external
        view
        returns (uint256);


    function getRewardRate(address _rewardsToken)
        external
        view
        returns (uint256);


    function getRewardForDuration(address _rewardsToken)
        external
        view
        returns (uint256);


    function getRewardsTokenCount() external view returns (uint256);


    function getAllRewardsTokens() external view returns (address[] memory);


    function getStakingToken() external view returns (address);


    function stake(uint256 amount) external;


    function stakeFor(address account, uint256 amount) external;


    function withdraw(uint256 amount) external;


    function withdrawFor(address account, uint256 amount) external;


    function getReward() external;


    function getRewardFor(address account) external;


    function exit() external;

}// MIT

pragma solidity ^0.8.0;

interface StakingRewardsFactoryInterface {

    function getStakingRewardsCount() external view returns (uint256);


    function getAllStakingRewards() external view returns (address[] memory);


    function getStakingRewards(address stakingToken)
        external
        view
        returns (address);


    function getStakingToken(address underlying)
        external
        view
        returns (address);

}// MIT

pragma solidity ^0.8.0;


contract StakingRewardsHelper is Ownable {

    using SafeERC20 for IERC20;

    StakingRewardsFactoryInterface public immutable factory;

    event TokenSeized(address token, uint256 amount);


    constructor(address _factory) {
        factory = StakingRewardsFactoryInterface(_factory);
    }


    struct RewardTokenInfo {
        address rewardTokenAddress;
        string rewardTokenSymbol;
        uint8 rewardTokenDecimals;
    }

    struct RewardClaimable {
        RewardTokenInfo rewardToken;
        uint256 amount;
    }

    struct UserStaked {
        address stakingTokenAddress;
        uint256 balance;
    }

    struct StakingInfo {
        address stakingTokenAddress;
        uint256 totalSupply;
        uint256 supplyRatePerBlock;
        uint256 exchangeRate;
        RewardRate[] rewardRates;
    }

    struct RewardRate {
        address rewardTokenAddress;
        uint256 rate;
    }

    function getRewardTokenInfo(address rewardToken)
        public
        view
        returns (RewardTokenInfo memory)
    {

        return
            RewardTokenInfo({
                rewardTokenAddress: rewardToken,
                rewardTokenSymbol: IERC20Metadata(rewardToken).symbol(),
                rewardTokenDecimals: IERC20Metadata(rewardToken).decimals()
            });
    }

    function getUserClaimableRewards(
        address account,
        address[] calldata rewardTokens
    ) public view returns (RewardClaimable[] memory) {

        RewardClaimable[] memory rewardsClaimable = new RewardClaimable[](
            rewardTokens.length
        );

        address[] memory allStakingRewards = factory.getAllStakingRewards();
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            uint256 amount;
            for (uint256 j = 0; j < allStakingRewards.length; j++) {
                address stakingRewards = allStakingRewards[j];
                amount += StakingRewardsInterface(stakingRewards).earned(
                    rewardTokens[i],
                    account
                );
            }

            rewardsClaimable[i] = RewardClaimable({
                rewardToken: getRewardTokenInfo(rewardTokens[i]),
                amount: amount
            });
        }
        return rewardsClaimable;
    }

    function getUserStaked(address account)
        public
        view
        returns (UserStaked[] memory)
    {

        address[] memory allStakingRewards = factory.getAllStakingRewards();
        UserStaked[] memory stakedInfo = new UserStaked[](
            allStakingRewards.length
        );
        for (uint256 i = 0; i < allStakingRewards.length; i++) {
            address stakingRewards = allStakingRewards[i];
            address stakingToken = StakingRewardsInterface(stakingRewards)
                .getStakingToken();
            uint256 balance = StakingRewardsInterface(stakingRewards).balanceOf(
                account
            );
            stakedInfo[i] = UserStaked({
                stakingTokenAddress: stakingToken,
                balance: balance
            });
        }
        return stakedInfo;
    }

    function getStakingInfo() public view returns (StakingInfo[] memory) {

        address[] memory allStakingRewards = factory.getAllStakingRewards();
        StakingInfo[] memory stakingRewardRates = new StakingInfo[](
            allStakingRewards.length
        );
        for (uint256 i = 0; i < allStakingRewards.length; i++) {
            address stakingRewards = allStakingRewards[i];
            address[] memory allRewardTokens = StakingRewardsInterface(
                stakingRewards
            ).getAllRewardsTokens();

            RewardRate[] memory rewardRates = new RewardRate[](
                allRewardTokens.length
            );
            for (uint256 j = 0; j < allRewardTokens.length; j++) {
                address rewardToken = allRewardTokens[j];
                uint256 rate = StakingRewardsInterface(stakingRewards)
                    .getRewardRate(rewardToken);
                rewardRates[j] = RewardRate({
                    rewardTokenAddress: rewardToken,
                    rate: rate
                });
            }

            address stakingToken = StakingRewardsInterface(stakingRewards)
                .getStakingToken();
            uint256 totalSupply = StakingRewardsInterface(stakingRewards)
                .totalSupply();
            uint256 supplyRatePerBlock = ITokenInterface(stakingToken)
                .supplyRatePerBlock();
            uint256 exchangeRate = ITokenInterface(stakingToken)
                .exchangeRateStored();
            stakingRewardRates[i] = StakingInfo({
                stakingTokenAddress: stakingToken,
                totalSupply: totalSupply,
                supplyRatePerBlock: supplyRatePerBlock,
                exchangeRate: exchangeRate,
                rewardRates: rewardRates
            });
        }
        return stakingRewardRates;
    }


    function stake(address underlying, uint256 amount) public {

        require(amount > 0, "invalid amount");
        address stakingToken = factory.getStakingToken(underlying);
        require(stakingToken != address(0), "invalid staking token");
        address stakingRewards = factory.getStakingRewards(stakingToken);
        require(stakingRewards != address(0), "staking rewards not exist");

        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);

        IERC20(underlying).approve(stakingToken, amount);
        require(ITokenInterface(stakingToken).mint(amount) == 0, "mint failed");

        uint256 balance = IERC20(stakingToken).balanceOf(address(this));
        IERC20(stakingToken).approve(stakingRewards, balance);
        StakingRewardsInterface(stakingRewards).stakeFor(msg.sender, balance);

        assert(IERC20(stakingToken).balanceOf(address(this)) == 0);
    }

    function unstake(address stakingRewards, uint256 amount) public {

        require(amount > 0, "invalid amount");
        address stakingToken = StakingRewardsInterface(stakingRewards)
            .getStakingToken();
        require(stakingToken != address(0), "invalid staking token");
        address underlying = ITokenInterface(stakingToken).underlying();
        require(underlying != address(0), "invalid underlying");

        StakingRewardsInterface(stakingRewards).withdrawFor(msg.sender, amount);

        require(
            ITokenInterface(stakingToken).redeem(amount) == 0,
            "redeem failed"
        );

        uint256 balance = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).transfer(msg.sender, balance);

        assert(IERC20(underlying).balanceOf(address(this)) == 0);
    }

    function exitAll() public {

        address[] memory allStakingRewards = factory.getAllStakingRewards();
        exit(allStakingRewards);
    }

    function exit(address[] memory stakingRewards) public {

        for (uint256 i = 0; i < stakingRewards.length; i++) {
            uint256 balance = StakingRewardsInterface(stakingRewards[i])
                .balanceOf(msg.sender);
            unstake(stakingRewards[i], balance);
            StakingRewardsInterface(stakingRewards[i]).getRewardFor(msg.sender);
        }
    }

    function claimAllRewards() public {

        address[] memory allStakingRewards = factory.getAllStakingRewards();
        claimRewards(allStakingRewards);
    }

    function claimRewards(address[] memory stakingRewards) public {

        for (uint256 i = 0; i < stakingRewards.length; i++) {
            StakingRewardsInterface(stakingRewards[i]).getRewardFor(msg.sender);
        }
    }


    function seize(address token, uint256 amount) external onlyOwner {

        IERC20(token).safeTransfer(owner(), amount);
        emit TokenSeized(token, amount);
    }
}