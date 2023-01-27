

pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;




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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

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

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


pragma solidity 0.6.6;

interface IEpochUtils {

    function epochPeriodInSeconds() external view returns (uint256);


    function firstEpochStartTimestamp() external view returns (uint256);


    function getCurrentEpochNumber() external view returns (uint256);


    function getEpochNumber(uint256 timestamp) external view returns (uint256);

}


pragma solidity 0.6.6;


interface IKyberDao is IEpochUtils {

    event Voted(
        address indexed staker,
        uint256 indexed epoch,
        uint256 indexed campaignID,
        uint256 option
    );

    function getLatestNetworkFeeDataWithCache()
        external
        returns (uint256 feeInBps, uint256 expiryTimestamp);


    function getLatestBRRDataWithCache()
        external
        returns (
            uint256 burnInBps,
            uint256 rewardInBps,
            uint256 rebateInBps,
            uint256 epoch,
            uint256 expiryTimestamp
        );


    function handleWithdrawal(address staker, uint256 penaltyAmount) external;


    function vote(uint256 campaignID, uint256 option) external;


    function getLatestNetworkFeeData()
        external
        view
        returns (uint256 feeInBps, uint256 expiryTimestamp);


    function shouldBurnRewardForEpoch(uint256 epoch)
        external
        view
        returns (bool);


    function getPastEpochRewardPercentageInPrecision(
        address staker,
        uint256 epoch
    ) external view returns (uint256);


    function getCurrentEpochRewardPercentageInPrecision(address staker)
        external
        view
        returns (uint256);

}


pragma solidity 0.6.6;


interface IExtendedKyberDao is IKyberDao {

    function kncToken() external view returns (address);


    function staking() external view returns (address);


    function feeHandler() external view returns (address);

}


pragma solidity 0.6.6;


interface IKyberFeeHandler {

    event RewardPaid(
        address indexed staker,
        uint256 indexed epoch,
        IERC20 indexed token,
        uint256 amount
    );
    event RebatePaid(
        address indexed rebateWallet,
        IERC20 indexed token,
        uint256 amount
    );
    event PlatformFeePaid(
        address indexed platformWallet,
        IERC20 indexed token,
        uint256 amount
    );
    event KncBurned(uint256 kncTWei, IERC20 indexed token, uint256 amount);

    function handleFees(
        IERC20 token,
        address[] calldata eligibleWallets,
        uint256[] calldata rebatePercentages,
        address platformWallet,
        uint256 platformFee,
        uint256 networkFee
    ) external payable;


    function claimReserveRebate(address rebateWallet)
        external
        returns (uint256);


    function claimPlatformFee(address platformWallet)
        external
        returns (uint256);


    function claimStakerReward(address staker, uint256 epoch)
        external
        returns (uint256 amount);

}


pragma solidity 0.6.6;


interface IExtendedKyberFeeHandler is IKyberFeeHandler {

    function rewardsPerEpoch(uint256) external view returns (uint256);

}


pragma solidity 0.6.6;


interface IKyberStaking is IEpochUtils {

    event Delegated(
        address indexed staker,
        address indexed representative,
        uint256 indexed epoch,
        bool isDelegated
    );
    event Deposited(uint256 curEpoch, address indexed staker, uint256 amount);
    event Withdraw(
        uint256 indexed curEpoch,
        address indexed staker,
        uint256 amount
    );

    function initAndReturnStakerDataForCurrentEpoch(address staker)
        external
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );


    function deposit(uint256 amount) external;


    function delegate(address dAddr) external;


    function withdraw(uint256 amount) external;


    function getStakerData(address staker, uint256 epoch)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );


    function getLatestStakerData(address staker)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );


    function getStakerRawData(address staker, uint256 epoch)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );

}


pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;








contract KyberPoolMaster is Ownable {

    using SafeMath for uint256;

    uint256 internal constant MINIMUM_EPOCH_NOTICE = 1;
    uint256 internal constant MAX_DELEGATION_FEE = 10000;
    uint256 internal constant PRECISION = (10**18);
    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    uint256 public immutable epochNotice;

    mapping(uint256 => mapping(address => mapping(address => bool)))
        public claimedDelegateReward;

    struct Claim {
        bool claimedByPool;
        uint256 totalRewards;
        uint256 totalStaked;
    }
    mapping(uint256 => mapping(address => Claim)) public epochFeeHandlerClaims;

    struct DFeeData {
        uint256 fromEpoch;
        uint256 fee;
        bool applied;
    }

    DFeeData[] public delegationFees;

    IERC20 public immutable kncToken;
    IExtendedKyberDao public immutable kyberDao;
    IKyberStaking public immutable kyberStaking;

    address[] public feeHandlersList;
    mapping(address => IERC20) public rewardTokenByFeeHandler;

    uint256 public immutable firstEpoch;

    mapping(address => bool) public successfulClaimByFeeHandler;

    struct RewardInfo {
        IExtendedKyberFeeHandler kyberFeeHandler;
        IERC20 rewardToken;
        uint256 totalRewards;
        uint256 totalFee;
        uint256 rewardsAfterFee;
        uint256 poolMembersShare;
        uint256 poolMasterShare;
    }

    struct UnclaimedRewardData {
        uint256 epoch;
        address feeHandler;
        uint256 rewards;
        IERC20 rewardToken;
    }

    event CommitNewFees(uint256 deadline, uint256 feeRate);
    event NewFees(uint256 fromEpoch, uint256 feeRate);

    event MemberClaimReward(
        uint256 indexed epoch,
        address indexed poolMember,
        address indexed feeHandler,
        IERC20 rewardToken,
        uint256 reward
    );

    event MasterClaimReward(
        uint256 indexed epoch,
        address indexed feeHandler,
        address indexed poolMaster,
        IERC20 rewardToken,
        uint256 totalRewards,
        uint256 feeApplied,
        uint256 feeAmount,
        uint256 poolMasterShare
    );

    event AddFeeHandler(address indexed feeHandler, IERC20 indexed rewardToken);

    event RemoveFeeHandler(address indexed feeHandler);

    constructor(
        address _kyberDao,
        uint256 _epochNotice,
        uint256 _delegationFee,
        address[] memory _kyberFeeHandlers,
        IERC20[] memory _rewardTokens
    ) public {
        require(_kyberDao != address(0), "ctor: kyberDao is missing");
        require(
            _epochNotice >= MINIMUM_EPOCH_NOTICE,
            "ctor: Epoch Notice too low"
        );
        require(
            _delegationFee <= MAX_DELEGATION_FEE,
            "ctor: Delegation Fee greater than 100%"
        );
        require(
            _kyberFeeHandlers.length > 0,
            "ctor: at least one _kyberFeeHandlers required"
        );
        require(
            _kyberFeeHandlers.length == _rewardTokens.length,
            "ctor: _kyberFeeHandlers and _rewardTokens uneven"
        );

        IExtendedKyberDao _kyberDaoContract = IExtendedKyberDao(_kyberDao);
        kyberDao = _kyberDaoContract;

        kncToken = IERC20(_kyberDaoContract.kncToken());
        kyberStaking = IKyberStaking(_kyberDaoContract.staking());

        epochNotice = _epochNotice;

        uint256 _firstEpoch = _kyberDaoContract.getCurrentEpochNumber();
        firstEpoch = _firstEpoch;

        delegationFees.push(DFeeData(_firstEpoch, _delegationFee, true));

        for (uint256 i = 0; i < _kyberFeeHandlers.length; i++) {
            require(
                _kyberFeeHandlers[i] != address(0),
                "ctor: feeHandler is missing"
            );
            require(
                rewardTokenByFeeHandler[_kyberFeeHandlers[i]] ==
                    IERC20(address(0)),
                "ctor: repeated feeHandler"
            );

            feeHandlersList.push(_kyberFeeHandlers[i]);
            rewardTokenByFeeHandler[_kyberFeeHandlers[i]] = _rewardTokens[i];

            emit AddFeeHandler(
                _kyberFeeHandlers[i],
                rewardTokenByFeeHandler[_kyberFeeHandlers[i]]
            );
        }

        emit CommitNewFees(_firstEpoch, _delegationFee);
        emit NewFees(_firstEpoch, _delegationFee);
    }

    function addFeeHandler(address _feeHandler, IERC20 _rewardToken)
        external
        onlyOwner
    {

        require(
            _feeHandler != address(0),
            "addFeeHandler: _feeHandler is missing"
        );
        require(
            rewardTokenByFeeHandler[_feeHandler] == IERC20(address(0)),
            "addFeeHandler: already added"
        );

        feeHandlersList.push(_feeHandler);
        rewardTokenByFeeHandler[_feeHandler] = _rewardToken;

        emit AddFeeHandler(_feeHandler, rewardTokenByFeeHandler[_feeHandler]);
    }

    function removeFeeHandler(address _feeHandler) external onlyOwner {

        require(
            rewardTokenByFeeHandler[_feeHandler] != IERC20(address(0)),
            "removeFeeHandler: not added"
        );
        require(
            !successfulClaimByFeeHandler[_feeHandler],
            "removeFeeHandler: can not remove FeeHandler successfully claimed"
        );

        if (feeHandlersList[feeHandlersList.length - 1] != _feeHandler) {
            for (uint256 i = 0; i < feeHandlersList.length; i++) {
                if (feeHandlersList[i] == _feeHandler) {
                    feeHandlersList[i] = feeHandlersList[feeHandlersList
                        .length - 1];
                    break;
                }
            }
        }

        feeHandlersList.pop();
        delete rewardTokenByFeeHandler[_feeHandler];

        emit RemoveFeeHandler(_feeHandler);
    }

    function masterDeposit(uint256 amount) external onlyOwner {

        require(
            amount > 0,
            "masterDeposit: amount to deposit should be positive"
        );

        require(
            kncToken.transferFrom(msg.sender, address(this), amount),
            "masterDeposit: can not get token"
        );

        kncToken.approve(address(kyberStaking), amount);

        kyberStaking.deposit(amount);
    }

    function masterWithdraw(uint256 amount) external onlyOwner {

        require(amount > 0, "masterWithdraw: amount is 0");

        kyberStaking.withdraw(amount);

        require(
            kncToken.transfer(msg.sender, amount),
            "masterWithdraw: can not transfer knc to the pool master"
        );
    }

    function vote(uint256 campaignID, uint256 option) external onlyOwner {

        kyberDao.vote(campaignID, option);
    }

    function commitNewFee(uint256 _fee) external onlyOwner {

        require(
            _fee <= MAX_DELEGATION_FEE,
            "commitNewFee: Delegation Fee greater than 100%"
        );

        uint256 curEpoch = kyberDao.getCurrentEpochNumber();
        uint256 fromEpoch = curEpoch.add(epochNotice);

        DFeeData storage lastFee = delegationFees[delegationFees.length - 1];

        if (lastFee.fromEpoch > curEpoch) {
            lastFee.fromEpoch = fromEpoch;
            lastFee.fee = _fee;
        } else {
            if (!lastFee.applied) {
                applyFee(lastFee);
            }

            delegationFees.push(DFeeData(fromEpoch, _fee, false));
        }
        emit CommitNewFees(fromEpoch.sub(1), _fee);
    }

    function applyPendingFee() public {

        DFeeData storage lastFee = delegationFees[delegationFees.length - 1];
        uint256 curEpoch = kyberDao.getCurrentEpochNumber();

        if (lastFee.fromEpoch <= curEpoch && !lastFee.applied) {
            applyFee(lastFee);
        }
    }

    function applyFee(DFeeData storage fee) internal {

        fee.applied = true;
        emit NewFees(fee.fromEpoch, fee.fee);
    }

    function getEpochDFeeDataId(uint256 _epoch, uint256 _from)
        internal
        view
        returns (uint256)
    {

        if (delegationFees[_from].fromEpoch > _epoch) {
            return _from;
        }

        uint256 left = _from;
        uint256 right = delegationFees.length;

        while (left < right) {
            uint256 m = (left + right).div(2);
            if (delegationFees[m].fromEpoch > _epoch) {
                right = m;
            } else {
                left = m + 1;
            }
        }

        return right - 1;
    }

    function getEpochDFeeData(uint256 epoch)
        public
        view
        returns (DFeeData memory epochDFee)
    {

        epochDFee = delegationFees[getEpochDFeeDataId(epoch, 0)];
    }

    function delegationFee() public view returns (DFeeData memory) {

        uint256 curEpoch = kyberDao.getCurrentEpochNumber();
        return getEpochDFeeData(curEpoch);
    }

    function getUnclaimedRewards(
        uint256 _epoch,
        IExtendedKyberFeeHandler _feeHandler
    ) public view returns (uint256) {

        if (epochFeeHandlerClaims[_epoch][address(_feeHandler)].claimedByPool) {
            return 0;
        }

        uint256 perInPrecision = kyberDao
            .getPastEpochRewardPercentageInPrecision(address(this), _epoch);
        if (perInPrecision == 0) {
            return 0;
        }

        uint256 rewardsPerEpoch = _feeHandler.rewardsPerEpoch(_epoch);
        if (rewardsPerEpoch == 0) {
            return 0;
        }

        return rewardsPerEpoch.mul(perInPrecision).div(PRECISION);
    }

    function getUnclaimedRewardsData()
        external
        view
        returns (UnclaimedRewardData[] memory)
    {

        uint256 currentEpoch = kyberDao.getCurrentEpochNumber();
        uint256 maxEpochNumber = currentEpoch.sub(firstEpoch);
        uint256[] memory epochGroup = new uint256[](maxEpochNumber);
        uint256 e = 0;
        for (uint256 epoch = firstEpoch; epoch < currentEpoch; epoch++) {
            epochGroup[e] = epoch;
            e++;
        }

        return _getUnclaimedRewardsData(epochGroup, feeHandlersList);
    }

    function getUnclaimedRewardsData(
        uint256[] calldata _epochGroup,
        address[] calldata _feeHandlerGroup
    ) external view returns (UnclaimedRewardData[] memory) {

        return _getUnclaimedRewardsData(_epochGroup, _feeHandlerGroup);
    }

    function _getUnclaimedRewardsData(
        uint256[] memory _epochGroup,
        address[] memory _feeHandlerGroup
    ) internal view returns (UnclaimedRewardData[] memory) {


            UnclaimedRewardData[] memory epochFeeHanlderRewards
         = new UnclaimedRewardData[](
            _epochGroup.length.mul(_feeHandlerGroup.length)
        );
        uint256 rewardsCounter = 0;
        for (uint256 e = 0; e < _epochGroup.length; e++) {
            for (uint256 f = 0; f < _feeHandlerGroup.length; f++) {
                uint256 unclaimed = getUnclaimedRewards(
                    _epochGroup[e],
                    IExtendedKyberFeeHandler(_feeHandlerGroup[f])
                );

                if (unclaimed > 0) {
                    epochFeeHanlderRewards[rewardsCounter] = UnclaimedRewardData(
                        _epochGroup[e],
                        _feeHandlerGroup[f],
                        unclaimed,
                        rewardTokenByFeeHandler[_feeHandlerGroup[f]]
                    );
                    rewardsCounter++;
                }
            }
        }

        UnclaimedRewardData[] memory result = new UnclaimedRewardData[](
            rewardsCounter
        );
        for (uint256 i = 0; i < (rewardsCounter); i++) {
            result[i] = epochFeeHanlderRewards[i];
        }

        return result;
    }

    function claimRewardsMaster(uint256[] memory _epochGroup) public {

        claimRewardsMaster(_epochGroup, feeHandlersList);
    }

    function claimRewardsMaster(
        uint256[] memory _epochGroup,
        address[] memory _feeHandlerGroup
    ) public {

        require(_epochGroup.length > 0, "cRMaster: _epochGroup required");
        require(
            isOrderedSet(_epochGroup),
            "cRMaster: order and uniqueness required"
        );
        require(
            _feeHandlerGroup.length > 0,
            "cRMaster: _feeHandlerGroup required"
        );

        uint256[] memory accruedByFeeHandler = new uint256[](
            _feeHandlerGroup.length
        );

        uint256 feeId = 0;

        for (uint256 j = 0; j < _epochGroup.length; j++) {
            uint256 _epoch = _epochGroup[j];
            feeId = getEpochDFeeDataId(_epoch, feeId);
            DFeeData storage epochDFee = delegationFees[feeId];

            if (!epochDFee.applied) {
                applyFee(epochDFee);
            }

            (uint256 stake, uint256 delegatedStake, ) = kyberStaking
                .getStakerRawData(address(this), _epoch);

            for (uint256 i = 0; i < _feeHandlerGroup.length; i++) {
                RewardInfo memory rewardInfo = _claimRewardsFromKyber(
                    _epoch,
                    _feeHandlerGroup[i],
                    epochDFee,
                    stake,
                    delegatedStake
                );

                if (rewardInfo.totalRewards == 0) {
                    continue;
                }

                accruedByFeeHandler[i] = accruedByFeeHandler[i].add(
                    rewardInfo.poolMasterShare
                );

                if (!successfulClaimByFeeHandler[_feeHandlerGroup[i]]) {
                    successfulClaimByFeeHandler[_feeHandlerGroup[i]] = true;
                }
            }
        }

        address poolMaster = owner();
        for (uint256 k = 0; k < accruedByFeeHandler.length; k++) {
            _sendTokens(
                rewardTokenByFeeHandler[_feeHandlerGroup[k]],
                poolMaster,
                accruedByFeeHandler[k],
                "cRMaster: poolMaster share transfer failed"
            );
        }
    }

    function _claimRewardsFromKyber(
        uint256 _epoch,
        address _feeHandlerAddress,
        DFeeData memory epochDFee,
        uint256 stake,
        uint256 delegatedStake
    ) internal returns (RewardInfo memory rewardInfo) {

        rewardInfo.kyberFeeHandler = IExtendedKyberFeeHandler(
            _feeHandlerAddress
        );
        uint256 unclaimed = getUnclaimedRewards(
            _epoch,
            rewardInfo.kyberFeeHandler
        );

        if (unclaimed > 0) {
            rewardInfo
                .rewardToken = rewardTokenByFeeHandler[_feeHandlerAddress];

            rewardInfo.kyberFeeHandler.claimStakerReward(address(this), _epoch);

            rewardInfo.totalRewards = unclaimed;

            rewardInfo.totalFee = rewardInfo
                .totalRewards
                .mul(epochDFee.fee)
                .div(MAX_DELEGATION_FEE);
            rewardInfo.rewardsAfterFee = rewardInfo.totalRewards.sub(
                rewardInfo.totalFee
            );

            rewardInfo.poolMembersShare = calculateRewardsShare(
                delegatedStake,
                stake.add(delegatedStake),
                rewardInfo.rewardsAfterFee
            );
            rewardInfo.poolMasterShare = rewardInfo.totalRewards.sub(
                rewardInfo.poolMembersShare
            ); // fee + poolMaster stake share

            epochFeeHandlerClaims[_epoch][_feeHandlerAddress] = Claim(
                true,
                rewardInfo.poolMembersShare,
                delegatedStake
            );

            emit MasterClaimReward(
                _epoch,
                _feeHandlerAddress,
                payable(owner()),
                rewardInfo.rewardToken,
                rewardInfo.totalRewards,
                epochDFee.fee,
                rewardInfo.totalFee,
                rewardInfo.poolMasterShare.sub(rewardInfo.totalFee)
            );
        }
    }

    function _sendTokens(
        IERC20 _token,
        address _receiver,
        uint256 _value,
        string memory _errorMsg
    ) internal {

        if (_value == 0) {
            return;
        }

        if (_token == ETH_TOKEN_ADDRESS) {
            (bool success, ) = _receiver.call{value: _value}("");
            require(success, _errorMsg);
        } else {
            SafeERC20.safeTransfer(_token, _receiver, _value);
        }
    }

    function getUnclaimedRewardsMember(
        address _poolMember,
        uint256 _epoch,
        address _feeHandler
    ) public view returns (uint256) {

        if (
            !epochFeeHandlerClaims[_epoch][address(_feeHandler)].claimedByPool
        ) {
            return 0;
        }

        if (claimedDelegateReward[_epoch][_poolMember][_feeHandler]) {
            return 0;
        }

        (uint256 stake, , address representative) = kyberStaking.getStakerData(
            _poolMember,
            _epoch
        );

        if (stake == 0) {
            return 0;
        }

        if (representative != address(this)) {
            return 0;
        }


            Claim memory rewardForEpoch
         = epochFeeHandlerClaims[_epoch][_feeHandler];

        return
            calculateRewardsShare(
                stake,
                rewardForEpoch.totalStaked,
                rewardForEpoch.totalRewards
            );
    }

    function getAllUnclaimedRewardsDataMember(address _poolMember)
        external
        view
        returns (UnclaimedRewardData[] memory)
    {

        uint256 currentEpoch = kyberDao.getCurrentEpochNumber();
        return
            _getAllUnclaimedRewardsDataMember(
                _poolMember,
                firstEpoch,
                currentEpoch
            );
    }

    function getAllUnclaimedRewardsDataMember(
        address _poolMember,
        uint256 _fromEpoch,
        uint256 _toEpoch
    ) external view returns (UnclaimedRewardData[] memory) {

        return
            _getAllUnclaimedRewardsDataMember(
                _poolMember,
                _fromEpoch,
                _toEpoch
            );
    }

    function _getAllUnclaimedRewardsDataMember(
        address _poolMember,
        uint256 _fromEpoch,
        uint256 _toEpoch
    ) internal view returns (UnclaimedRewardData[] memory) {

        uint256 maxEpochNumber = _toEpoch.sub(_fromEpoch).add(1);
        uint256[] memory epochGroup = new uint256[](maxEpochNumber);
        uint256 e = 0;
        for (uint256 epoch = _fromEpoch; epoch <= _toEpoch; epoch++) {
            epochGroup[e] = epoch;
            e++;
        }

        return
            _getUnclaimedRewardsDataMember(
                _poolMember,
                epochGroup,
                feeHandlersList
            );
    }

    function _getUnclaimedRewardsDataMember(
        address _poolMember,
        uint256[] memory _epochGroup,
        address[] memory _feeHandlerGroup
    ) internal view returns (UnclaimedRewardData[] memory) {


            UnclaimedRewardData[] memory epochFeeHanlderRewards
         = new UnclaimedRewardData[](
            _epochGroup.length.mul(_feeHandlerGroup.length)
        );

        uint256 rewardsCounter = 0;
        for (uint256 e = 0; e < _epochGroup.length; e++) {
            for (uint256 f = 0; f < _feeHandlerGroup.length; f++) {
                uint256 unclaimed = getUnclaimedRewardsMember(
                    _poolMember,
                    _epochGroup[e],
                    _feeHandlerGroup[f]
                );

                if (unclaimed > 0) {
                    epochFeeHanlderRewards[rewardsCounter] = UnclaimedRewardData(
                        _epochGroup[e],
                        _feeHandlerGroup[f],
                        unclaimed,
                        rewardTokenByFeeHandler[_feeHandlerGroup[f]]
                    );
                    rewardsCounter++;
                }
            }
        }

        UnclaimedRewardData[] memory result = new UnclaimedRewardData[](
            rewardsCounter
        );
        for (uint256 i = 0; i < (rewardsCounter); i++) {
            result[i] = epochFeeHanlderRewards[i];
        }

        return result;
    }

    function claimRewardsMember(
        address _poolMember,
        uint256[] memory _epochGroup
    ) public {

        _claimRewardsMember(_poolMember, _epochGroup, feeHandlersList);
    }

    function claimRewardsMember(
        address _poolMember,
        uint256[] memory _epochGroup,
        address[] memory _feeHandlerGroup
    ) public {

        _claimRewardsMember(_poolMember, _epochGroup, _feeHandlerGroup);
    }

    function _claimRewardsMember(
        address _poolMember,
        uint256[] memory _epochGroup,
        address[] memory _feeHandlerGroup
    ) internal {

        require(_epochGroup.length > 0, "cRMember: _epochGroup required");
        require(
            _feeHandlerGroup.length > 0,
            "cRMember: _feeHandlerGroup required"
        );

        uint256[] memory accruedByFeeHandler = new uint256[](
            _feeHandlerGroup.length
        );

        for (uint256 j = 0; j < _epochGroup.length; j++) {
            uint256 _epoch = _epochGroup[j];

            for (uint256 i = 0; i < _feeHandlerGroup.length; i++) {
                uint256 poolMemberShare = getUnclaimedRewardsMember(
                    _poolMember,
                    _epoch,
                    _feeHandlerGroup[i]
                );


                    IERC20 rewardToken
                 = rewardTokenByFeeHandler[_feeHandlerGroup[i]];

                if (poolMemberShare == 0) {
                    continue;
                }

                accruedByFeeHandler[i] = accruedByFeeHandler[i].add(
                    poolMemberShare
                );

                claimedDelegateReward[_epoch][_poolMember][_feeHandlerGroup[i]] = true;

                emit MemberClaimReward(
                    _epoch,
                    _poolMember,
                    _feeHandlerGroup[i],
                    rewardToken,
                    poolMemberShare
                );
            }
        }

        for (uint256 k = 0; k < accruedByFeeHandler.length; k++) {
            _sendTokens(
                rewardTokenByFeeHandler[_feeHandlerGroup[k]],
                _poolMember,
                accruedByFeeHandler[k],
                "cRMember: poolMember share transfer failed"
            );
        }
    }


    function calculateRewardsShare(
        uint256 stake,
        uint256 totalStake,
        uint256 rewards
    ) internal pure returns (uint256) {

        return stake.mul(rewards).div(totalStake);
    }

    function delegationFeesLength() public view returns (uint256) {

        return delegationFees.length;
    }

    function feeHandlersListLength() public view returns (uint256) {

        return feeHandlersList.length;
    }

    function isOrderedSet(uint256[] memory numbers)
        internal
        pure
        returns (bool)
    {

        bool isOrdered = true;

        if (numbers.length > 1) {
            for (uint256 i = 0; i < numbers.length - 1; i++) {
                if (numbers[i] >= numbers[i + 1]) {
                    isOrdered = false;
                    break;
                }
            }
        }

        return isOrdered;
    }

    receive() external payable {
        require(
            rewardTokenByFeeHandler[msg.sender] == ETH_TOKEN_ADDRESS,
            "only accept ETH from a KyberFeeHandler"
        );
    }
}