

pragma solidity ^0.8.0;

interface IStaking {

    enum StakeType {
        NU,
        KEEP,
        T
    }


    function stake(
        address stakingProvider,
        address payable beneficiary,
        address authorizer,
        uint96 amount
    ) external;


    function stakeKeep(address stakingProvider) external;


    function stakeNu(
        address stakingProvider,
        address payable beneficiary,
        address authorizer
    ) external;


    function refreshKeepStakeOwner(address stakingProvider) external;


    function setMinimumStakeAmount(uint96 amount) external;



    function approveApplication(address application) external;


    function increaseAuthorization(
        address stakingProvider,
        address application,
        uint96 amount
    ) external;


    function requestAuthorizationDecrease(
        address stakingProvider,
        address application,
        uint96 amount
    ) external;


    function requestAuthorizationDecrease(address stakingProvider) external;


    function approveAuthorizationDecrease(address stakingProvider)
        external
        returns (uint96);


    function forceDecreaseAuthorization(
        address stakingProvider,
        address application
    ) external;


    function pauseApplication(address application) external;


    function disableApplication(address application) external;


    function setPanicButton(address application, address panicButton) external;


    function setAuthorizationCeiling(uint256 ceiling) external;



    function topUp(address stakingProvider, uint96 amount) external;


    function topUpKeep(address stakingProvider) external;


    function topUpNu(address stakingProvider) external;



    function unstakeT(address stakingProvider, uint96 amount) external;


    function unstakeKeep(address stakingProvider) external;


    function unstakeNu(address stakingProvider, uint96 amount) external;


    function unstakeAll(address stakingProvider) external;



    function notifyKeepStakeDiscrepancy(address stakingProvider) external;


    function notifyNuStakeDiscrepancy(address stakingProvider) external;


    function setStakeDiscrepancyPenalty(
        uint96 penalty,
        uint256 rewardMultiplier
    ) external;


    function setNotificationReward(uint96 reward) external;


    function pushNotificationReward(uint96 reward) external;


    function withdrawNotificationReward(address recipient, uint96 amount)
        external;


    function slash(uint96 amount, address[] memory stakingProviders) external;


    function seize(
        uint96 amount,
        uint256 rewardMultipier,
        address notifier,
        address[] memory stakingProviders
    ) external;


    function processSlashing(uint256 count) external;



    function authorizedStake(address stakingProvider, address application)
        external
        view
        returns (uint96);


    function stakes(address stakingProvider)
        external
        view
        returns (
            uint96 tStake,
            uint96 keepInTStake,
            uint96 nuInTStake
        );


    function getStartStakingTimestamp(address stakingProvider)
        external
        view
        returns (uint256);


    function stakedNu(address stakingProvider) external view returns (uint256);


    function rolesOf(address stakingProvider)
        external
        view
        returns (
            address owner,
            address payable beneficiary,
            address authorizer
        );


    function getApplicationsLength() external view returns (uint256);


    function getSlashingQueueLength() external view returns (uint256);


    function getMinStaked(address stakingProvider, StakeType stakeTypes)
        external
        view
        returns (uint96);


    function getAvailableToAuthorize(
        address stakingProvider,
        address application
    ) external view returns (uint96);

}

pragma solidity ^0.8.0;




contract SimplePREApplication {


    event OperatorBonded(address indexed stakingProvider, address indexed operator, uint256 startTimestamp);

    event OperatorConfirmed(address indexed stakingProvider, address indexed operator);

    struct StakingProviderInfo {
        address operator;
        bool operatorConfirmed;
        uint256 operatorStartTimestamp;
    }

    uint256 public immutable minAuthorization;
    uint256 public immutable minOperatorSeconds;

    IStaking public immutable tStaking;

    mapping (address => StakingProviderInfo) public stakingProviderInfo;
    address[] public stakingProviders;
    mapping(address => address) internal _stakingProviderFromOperator;


    constructor(
        IStaking _tStaking,
        uint256 _minAuthorization,
        uint256 _minOperatorSeconds
    ) {
        require(
            _tStaking.authorizedStake(address(this), address(this)) == 0,
            "Wrong input parameters"
        );
        minAuthorization = _minAuthorization;
        tStaking = _tStaking;
        minOperatorSeconds = _minOperatorSeconds;
    }

    modifier onlyOwnerOrStakingProvider(address _stakingProvider)
    {

        require(isAuthorized(_stakingProvider), "Not owner or provider");
        if (_stakingProvider != msg.sender) {
            (address owner,,) = tStaking.rolesOf(_stakingProvider);
            require(owner == msg.sender, "Not owner or provider");
        }
        _;
    }


    function stakingProviderFromOperator(address _operator) public view returns (address) {

        return _stakingProviderFromOperator[_operator];
    }

    function getOperatorFromStakingProvider(address _stakingProvider) public view returns (address) {

        return stakingProviderInfo[_stakingProvider].operator;
    }

    function authorizedStake(address _stakingProvider) public view returns (uint96) {

        (uint96 tStake, uint96 keepInTStake, uint96 nuInTStake) = tStaking.stakes(_stakingProvider);
        return tStake + keepInTStake + nuInTStake;
    }

    function getActiveStakingProviders(uint256 _startIndex, uint256 _maxStakingProviders)
        external view returns (uint256 allAuthorizedTokens, uint256[2][] memory activeStakingProviders)
    {

        uint256 endIndex = stakingProviders.length;
        require(_startIndex < endIndex, "Wrong start index");
        if (_maxStakingProviders != 0 && _startIndex + _maxStakingProviders < endIndex) {
            endIndex = _startIndex + _maxStakingProviders;
        }
        activeStakingProviders = new uint256[2][](endIndex - _startIndex);
        allAuthorizedTokens = 0;

        uint256 resultIndex = 0;
        for (uint256 i = _startIndex; i < endIndex; i++) {
            address stakingProvider = stakingProviders[i];
            StakingProviderInfo storage info = stakingProviderInfo[stakingProvider];
            uint256 eligibleAmount = authorizedStake(stakingProvider);
            if (eligibleAmount < minAuthorization || !info.operatorConfirmed) {
                continue;
            }
            activeStakingProviders[resultIndex][0] = uint256(uint160(stakingProvider));
            activeStakingProviders[resultIndex++][1] = eligibleAmount;
            allAuthorizedTokens += eligibleAmount;
        }
        assembly {
            mstore(activeStakingProviders, resultIndex)
        }
    }

    function getBeneficiary(address _stakingProvider) public view returns (address payable beneficiary) {

        (, beneficiary,) = tStaking.rolesOf(_stakingProvider);
    }

    function isAuthorized(address _stakingProvider) public view returns (bool) {

        return authorizedStake(_stakingProvider) >= minAuthorization;
    }

    function isOperatorConfirmed(address _operator) public view returns (bool) {

        address stakingProvider = _stakingProviderFromOperator[_operator];
        StakingProviderInfo storage info = stakingProviderInfo[stakingProvider];
        return info.operatorConfirmed;
    }

    function getStakingProvidersLength() external view returns (uint256) {

        return stakingProviders.length;
    }

    function bondOperator(address _stakingProvider, address _operator)
        external onlyOwnerOrStakingProvider(_stakingProvider)
    {

        StakingProviderInfo storage info = stakingProviderInfo[_stakingProvider];
        require(_operator != info.operator, "Specified operator is already bonded with this provider");
        if (info.operator != address(0)) {
            require(
                block.timestamp >= info.operatorStartTimestamp + minOperatorSeconds,
                "Not enough time passed to change operator"
            );
            _stakingProviderFromOperator[info.operator] = address(0);
        }

        if (_operator != address(0)) {
            require(_stakingProviderFromOperator[_operator] == address(0), "Specified operator is already in use");
            require(
                _operator == _stakingProvider || getBeneficiary(_operator) == address(0),
                "Specified operator is a provider"
            );
            _stakingProviderFromOperator[_operator] = _stakingProvider;
        }

        if (info.operatorStartTimestamp == 0) {
            stakingProviders.push(_stakingProvider);
        }

        info.operator = _operator;
        info.operatorStartTimestamp = block.timestamp;
        info.operatorConfirmed = false;
        emit OperatorBonded(_stakingProvider, _operator, block.timestamp);
    }

    function confirmOperatorAddress() external {

        address stakingProvider = _stakingProviderFromOperator[msg.sender];
        require(isAuthorized(stakingProvider), "No stake associated with the operator");
        StakingProviderInfo storage info = stakingProviderInfo[stakingProvider];
        require(!info.operatorConfirmed, "Operator address is already confirmed");
        require(msg.sender == tx.origin, "Only operator with real address can make a confirmation");
        info.operatorConfirmed = true;
        emit OperatorConfirmed(stakingProvider, msg.sender);
    }

}
