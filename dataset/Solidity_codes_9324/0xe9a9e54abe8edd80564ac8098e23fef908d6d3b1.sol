pragma solidity 0.8.9;



interface ICurveGauge {

    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;

    function claim_rewards() external;

    function reward_tokens(uint256) external view returns(address);//v2

    function rewarded_token() external view returns(address);//v1

    function lp_token() external view returns(address);

}

interface ICurveVoteEscrow {

    function create_lock(uint256, uint256) external;

    function increase_amount(uint256) external;

    function increase_unlock_time(uint256) external;

    function withdraw() external;

    function smart_wallet_checker() external view returns (address);

}

interface IWalletChecker {

    function check(address) external view returns (bool);

}

interface IVoting {

    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided

    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory);

    function vote_for_gauge_weights(address,uint256) external;

}

interface IMinter {

    function mint(address) external;

}

interface IRegistry {

    function get_registry() external view returns(address);

    function get_address(uint256 _id) external view returns(address);

    function gauge_controller() external view returns(address);

    function get_lp_token(address) external view returns(address);

    function get_gauges(address) external view returns(address[10] memory,uint128[10] memory);

}

interface IStaker {

    function deposit(address, address) external;

    function withdraw(address) external;

    function withdraw(address, address, uint256) external;

    function withdrawAll(address, address) external;

    function createLock(uint256, uint256) external;

    function increaseAmount(uint256) external;

    function increaseTime(uint256) external;

    function release() external;

    function claimCrv(address) external returns (uint256);

    function claimRewards(address) external;

    function claimFees(address,address) external;

    function setStashAccess(address, bool) external;

    function vote(uint256,address,bool) external;

    function voteGaugeWeight(address,uint256) external;

    function balanceOfPool(address) external view returns (uint256);

    function operator() external view returns (address);

    function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);

}

interface IRewards {

    function stake(address, uint256) external;

    function stakeFor(address, uint256) external;

    function withdraw(address, uint256) external;

    function exit(address) external;

    function getReward(address) external;

    function queueNewRewards(uint256) external;

    function notifyRewardAmount(uint256) external;

    function addExtraReward(address) external;

    function stakingToken() external view returns (address);

    function rewardToken() external view returns(address);

    function earned(address account) external view returns (uint256);

}

interface IStash {

    function stashRewards() external returns (bool);

    function processStash() external returns (bool);

    function claimRewards() external returns (bool);

    function initialize(uint256 _pid, address _operator, address _staker, address _gauge, address _rewardFactory) external;

}

interface IFeeDistro {

    function claim() external;

    function token() external view returns(address);

}

interface ITokenMinter{

    function mint(address,uint256) external;

    function burn(address,uint256) external;

}

interface IDeposit {

    function isShutdown() external view returns(bool);

    function balanceOf(address _account) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function poolInfo(uint256) external view returns(address,address,address,address,address, bool);

    function rewardClaimed(uint256,address,uint256) external;

    function withdrawTo(uint256,uint256,address) external;

    function claimRewards(uint256,address) external returns(bool);

    function rewardArbitrator() external returns(address);

    function setGaugeRedirect(uint256 _pid) external returns(bool);

    function owner() external returns(address);

}

interface ICrvDeposit {

    function deposit(uint256, bool) external;

    function lockIncentive() external view returns(uint256);

}

interface IRewardFactory {

    function setAccess(address,bool) external;

    function CreateCrvRewards(uint256,address) external returns(address);

    function CreateTokenRewards(address,address,address) external returns(address);

    function CreateFeePool(address,address) external returns(address);

    function activeRewardCount(address) external view returns(uint256);

    function addActiveReward(address,uint256) external returns(bool);

    function removeActiveReward(address,uint256) external returns(bool);

}

interface IStashFactory {

    function CreateStash(uint256,address,address,uint256) external returns(address);

}

interface ITokenFactory {

    function CreateDepositToken(address) external returns(address);

}

interface IPools {

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);

    function setLiquidityLimit(uint256 _pid, uint256 _limit) external;

    function shutdownPool(uint256 _pid) external returns(bool);

    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);

    function poolLength() external view returns (uint256);

    function gaugeMap(address) external view returns(bool);

    function setPoolManager(address _poolM) external;

}

interface IVestedEscrow {

    function fund(address[] calldata _recipient, uint256[] calldata _amount) external returns(bool);

}

interface IProxyFactory {

    function clone(address _target) external returns(address);

}

interface ISmartWalletWhitelist {

    function approveWallet(address _wallet) external;

}

interface IGaugeController {

    function get_gauge_weight(address _gauge) external view returns(uint256);

    function gauge_relative_weight(address _gauge) external view returns(uint256);

    function vote_user_slopes(address,address) external view returns(uint256,uint256,uint256);//slope,power,end

}

interface IVault {

    function collaterals(address asset, address owner) external view returns(uint256);

}

interface IRewardHook {

    function onRewardClaim() external;

}

interface IBurner {

    function withdraw_admin_fees(address) external;

    function burn(address) external;

    function execute() external returns(bool);

}

interface IPreDepositChecker {

    function canDeposit(address, uint, uint) external view returns(bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
pragma solidity 0.8.9;



contract StashFactoryV2 {

    using Address for address;

    bytes4 private constant rewarded_token = 0x16fa50b1; //rewarded_token()
    bytes4 private constant reward_tokens = 0x54c49fe9; //reward_tokens(uint256)
    bytes4 private constant rewards_receiver = 0x01ddabf1; //rewards_receiver(address)
    address public constant proxyFactory = 0x66807B5598A848602734B82E432dD88DBE13fC8f;

    address public immutable operator; // booster
    address public immutable rewardFactory;

    address public v1Implementation;
    address public v2Implementation;
    address public v3Implementation;

    constructor(address _operator, address _rewardFactory) {
        operator = _operator;
        rewardFactory = _rewardFactory;
    }

    function setImplementation(address _v1, address _v2, address _v3) external {

        require(msg.sender == IDeposit(operator).owner(), "!auth");

        v1Implementation = _v1;
        v2Implementation = _v2;
        v3Implementation = _v3;
    }

    function CreateStash(uint256 _pid, address _gauge, address _staker, uint256 _stashVersion) external returns(address) {

        require(msg.sender == operator, "!authorized");

        if (_stashVersion == uint256(3) && IsV3(_gauge)) {
            require(v3Implementation != address(0), "0 impl");
            address stash = IProxyFactory(proxyFactory).clone(v3Implementation);
            IStash(stash).initialize(_pid, operator, _staker, _gauge, rewardFactory);
            return stash;
        } else if (_stashVersion == uint256(1) && IsV1(_gauge)) {
            require(v1Implementation != address(0), "0 impl");
            address stash = IProxyFactory(proxyFactory).clone(v1Implementation);
            IStash(stash).initialize(_pid, operator, _staker, _gauge, rewardFactory);
            return stash;
        } else if (_stashVersion == uint256(2) && !IsV3(_gauge) && IsV2(_gauge)) {
            require(v2Implementation != address(0), "0 impl");
            address stash = IProxyFactory(proxyFactory).clone(v2Implementation);
            IStash(stash).initialize(_pid, operator, _staker, _gauge, rewardFactory);
            return stash;
        }
        bool isV1 = IsV1(_gauge);
        bool isV2 = IsV2(_gauge);
        bool isV3 = IsV3(_gauge);
        require(!isV1 && !isV2 && !isV3, "stash version mismatch");
        return address(0);
    }

    function IsV1(address _gauge) private returns(bool) {

        bytes memory data = abi.encode(rewarded_token);
        (bool success,) = _gauge.call(data);
        return success;
    }

    function IsV2(address _gauge) private returns(bool) {

        bytes memory data = abi.encodeWithSelector(reward_tokens,uint256(0));
        (bool success,) = _gauge.call(data);
        return success;
    }

    function IsV3(address _gauge) private returns(bool) {

        bytes memory data = abi.encodeWithSelector(rewards_receiver,address(0));
        (bool success,) = _gauge.call(data);
        return success;
    }
}