pragma solidity >=0.6.0 <0.7.0;

interface IPUSH {

  function born() external view returns(uint);

  function totalSupply() external view returns(uint);

  function resetHolderWeight(address holder) external;

  function returnHolderUnits(address account, uint atBlock) external view returns (uint);

}pragma solidity >=0.6.0 <0.7.0;

interface IADai {

    function redeem(uint256 _amount) external;

    function balanceOf(address _user) external view returns(uint256) ;

    function principalBalanceOf(address _user) external view returns(uint256);

    function getInterestRedirectionAddress(address _user) external view returns(address);

}pragma solidity >=0.6.0 <0.7.0;

interface ILendingPool {

    function addressesProvider() external view returns (address);

    
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;


    function redeemUnderlying(address _reserve, address _user, uint256 _amount) external;


    function borrow(address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode) external;


    function repay(address _reserve, uint256 _amount, address _onBehalfOf) external payable;


    function swapBorrowRateMode(address _reserve) external;


    function rebalanceFixedBorrowRate(address _reserve, address _user) external;


    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;


    function liquidationCall(address _collateral, address _reserve, address _user, uint256 _purchaseAmount, bool _receiveAToken) external payable;


    function flashLoan(address _receiver, address _reserve, uint256 _amount, bytes calldata _params) external;


    function getReserveConfigurationData(address _reserve) external view returns (uint256 ltv, uint256 liquidationThreshold, uint256 liquidationDiscount, address interestRateStrategyAddress, bool usageAsCollateralEnabled, bool borrowingEnabled, bool fixedBorrowRateEnabled, bool isActive);


    function getReserveData(address _reserve) external view returns (uint256 totalLiquidity, uint256 availableLiquidity, uint256 totalBorrowsFixed, uint256 totalBorrowsVariable, uint256 liquidityRate, uint256 variableBorrowRate, uint256 fixedBorrowRate, uint256 averageFixedBorrowRate, uint256 utilizationRate, uint256 liquidityIndex, uint256 variableBorrowIndex, address aTokenAddress, uint40 lastUpdateTimestamp);


    function getUserAccountData(address _user) external view returns (uint256 totalLiquidityETH, uint256 totalCollateralETH, uint256 totalBorrowsETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor);


    function getUserReserveData(address _reserve, address _user) external view returns (uint256 currentATokenBalance, uint256 currentUnderlyingBalance, uint256 currentBorrowBalance, uint256 principalBorrowBalance, uint256 borrowRateMode, uint256 borrowRate, uint256 liquidityRate, uint256 originationFee, uint256 variableBorrowIndex, uint256 lastUpdateTimestamp, bool usageAsCollateralEnabled);


    function getReserves() external view;

}pragma solidity >=0.6.0 <0.7.0;

interface IUniswapV2Router {

    function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external returns (uint[] memory amounts); 

}pragma solidity >=0.6.0 <0.7.0;

interface IEPNSCommV1 {

 	function subscribeViaCore(address _channel, address _user) external returns(bool);

}pragma solidity >=0.6.0 <0.7.0;

interface ILendingPoolAddressesProvider {

    function getLendingPoolCore() external view returns (address payable);


    function getLendingPool() external view returns (address);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
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
}pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;




contract EPNSCoreV1 is Initializable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    enum ChannelType {
        ProtocolNonInterest,
        ProtocolPromotion,
        InterestBearingOpen,
        InterestBearingMutual
    }
    enum ChannelAction {
        ChannelRemoved,
        ChannelAdded,
        ChannelUpdated
    }

    struct Channel {
        ChannelType channelType;

        uint8 channelState;

        address verifiedBy;

        uint256 poolContribution;

        uint256 channelHistoricalZ;

        uint256 channelFairShareCount;

        uint256 channelLastUpdate;

        uint256 channelStartBlock;

        uint256 channelUpdateBlock;

        uint256 channelWeight;
    }


    mapping(address => Channel) public channels;
    mapping(uint256 => address) public channelById;
    mapping(address => string) public channelNotifSettings;

    string public constant name = "EPNS CORE V1";
    bool oneTimeCheck;
    bool public isMigrationComplete;

    address public pushChannelAdmin;
    address public governance;
    address public daiAddress;
    address public aDaiAddress;
    address public WETH_ADDRESS;
    address public epnsCommunicator;
    address public UNISWAP_V2_ROUTER;
    address public PUSH_TOKEN_ADDRESS;
    address public lendingPoolProviderAddress;

    uint256 public REFERRAL_CODE;
    uint256 ADJUST_FOR_FLOAT;
    uint256 public channelsCount;

    uint256 public groupNormalizedWeight;
    uint256 public groupHistoricalZ;
    uint256 public groupLastUpdate;
    uint256 public groupFairShareCount;

    uint256 public POOL_FUNDS;
    uint256 public PROTOCOL_POOL_FEES;
    uint256 public ADD_CHANNEL_MIN_FEES;
    uint256 public CHANNEL_DEACTIVATION_FEES;
    uint256 public ADD_CHANNEL_MIN_POOL_CONTRIBUTION;

    event UpdateChannel(address indexed channel, bytes identity);
    event ChannelVerified(address indexed channel, address indexed verifier);
    event ChannelVerificationRevoked(address indexed channel, address indexed revoker);

    event DeactivateChannel(
        address indexed channel,
        uint256 indexed amountRefunded
    );
    event ReactivateChannel(
        address indexed channel,
        uint256 indexed amountDeposited
    );
    event ChannelBlocked(
        address indexed channel
    );
    event AddChannel(
        address indexed channel,
        ChannelType indexed channelType,
        bytes identity
    );
    event ChannelNotifcationSettingsAdded(
        address _channel,
        uint256 totalNotifOptions,
        string _notifSettings,
        string _notifDescription
    );

    modifier onlyPushChannelAdmin() {

        require(msg.sender == pushChannelAdmin, "EPNSCoreV1::onlyPushChannelAdmin: Caller not pushChannelAdmin");
        _;
    }

    modifier onlyGovernance() {

        require(msg.sender == governance, "EPNSCoreV1::onlyGovernance: Caller not Governance");
        _;
    }

    modifier onlyInactiveChannels(address _channel) {

        require(
            channels[_channel].channelState == 0,
            "EPNSCoreV1::onlyInactiveChannels: Channel already Activated"
        );
        _;
    }
    modifier onlyActivatedChannels(address _channel) {

        require(
            channels[_channel].channelState == 1,
            "EPNSCoreV1::onlyActivatedChannels: Channel Deactivated, Blocked or Does Not Exist"
        );
        _;
    }

    modifier onlyDeactivatedChannels(address _channel) {

        require(
            channels[_channel].channelState == 2,
            "EPNSCoreV1::onlyDeactivatedChannels: Channel is not Deactivated Yet"
        );
        _;
    }

    modifier onlyUnblockedChannels(address _channel) {

        require(
            ((channels[_channel].channelState != 3) &&
              (channels[_channel].channelState != 0)),
            "EPNSCoreV1::onlyUnblockedChannels: Channel is BLOCKED Already or Not Activated Yet"
        );
        _;
    }

    modifier onlyChannelOwner(address _channel) {

        require(
            ((channels[_channel].channelState == 1 && msg.sender == _channel) ||
                (msg.sender == pushChannelAdmin &&
                    _channel == address(0x0))),
            "EPNSCoreV1::onlyChannelOwner: Channel not Exists or Invalid Channel Owner"
        );
        _;
    }

    modifier onlyUserAllowedChannelType(ChannelType _channelType) {

        require(
            (_channelType == ChannelType.InterestBearingOpen ||
                _channelType == ChannelType.InterestBearingMutual),
            "EPNSCoreV1::onlyUserAllowedChannelType: Channel Type Invalid"
        );

        _;
    }


    function initialize(
        address _pushChannelAdmin,
        address _pushTokenAddress,
        address _wethAddress,
        address _uniswapRouterAddress,
        address _lendingPoolProviderAddress,
        address _daiAddress,
        address _aDaiAddress,
        uint256 _referralCode
    ) public initializer returns (bool success) {

        pushChannelAdmin = _pushChannelAdmin;
        governance = _pushChannelAdmin; // Will be changed on-Chain governance Address later
        daiAddress = _daiAddress;
        aDaiAddress = _aDaiAddress;
        WETH_ADDRESS = _wethAddress;
        REFERRAL_CODE = _referralCode;
        PUSH_TOKEN_ADDRESS = _pushTokenAddress;
        UNISWAP_V2_ROUTER = _uniswapRouterAddress;
        lendingPoolProviderAddress = _lendingPoolProviderAddress;

        CHANNEL_DEACTIVATION_FEES = 10 ether; // 10 DAI out of total deposited DAIs is charged for Deactivating a Channel
        ADD_CHANNEL_MIN_POOL_CONTRIBUTION = 50 ether; // 50 DAI or above to create the channel
        ADD_CHANNEL_MIN_FEES = 50 ether; // can never be below ADD_CHANNEL_MIN_POOL_CONTRIBUTION

        ADJUST_FOR_FLOAT = 10**7;
        groupLastUpdate = block.number;
        groupNormalizedWeight = ADJUST_FOR_FLOAT; // Always Starts with 1 * ADJUST FOR FLOAT

        success = true;
    }

    function updateWETHAddress(address _newAddress) external onlyPushChannelAdmin() {

        WETH_ADDRESS = _newAddress;
    }

    function updateUniswapRouterAddress(address _newAddress) external onlyPushChannelAdmin() {

        UNISWAP_V2_ROUTER = _newAddress;
    }

    function setEpnsCommunicatorAddress(address _commAddress)
        external
        onlyPushChannelAdmin()
    {

        epnsCommunicator = _commAddress;
    }

    function setGovernanceAddress(address _governanceAddress)
        external
        onlyPushChannelAdmin()
    {

      governance = _governanceAddress;
    }

    function setMigrationComplete() external onlyPushChannelAdmin() {

        isMigrationComplete = true;
    }

    function setChannelDeactivationFees(uint256 _newFees) external onlyGovernance() {

        require(
            _newFees > 0,
            "EPNSCoreV1::setChannelDeactivationFees: Channel Deactivation Fees must be greater than ZERO"
        );
        CHANNEL_DEACTIVATION_FEES = _newFees;
    }
    function setMinChannelCreationFees(uint256 _newFees) external onlyGovernance() {

        require(
            _newFees >= ADD_CHANNEL_MIN_POOL_CONTRIBUTION,
            "EPNSCoreV1::setMinChannelCreationFees: Fees should be greater than ADD_CHANNEL_MIN_POOL_CONTRIBUTION"
        );
        ADD_CHANNEL_MIN_FEES = _newFees;
    }


    function transferPushChannelAdminControl(address _newAdmin) public onlyPushChannelAdmin() {

        require(_newAdmin != address(0), "EPNSCoreV1::transferPushChannelAdminControl: Invalid Address");
        require(_newAdmin != pushChannelAdmin, "EPNSCoreV1::transferPushChannelAdminControl: Admin address is same");
        pushChannelAdmin = _newAdmin;
    }

    function getChannelState(address _channel) external view returns(uint256 state) {

        state = channels[_channel].channelState;
    }
    function updateChannelMeta(address _channel, bytes calldata _newIdentity)
        external
        onlyChannelOwner(_channel)
    {

        emit UpdateChannel(_channel, _newIdentity);

        _updateChannelMeta(_channel);
    }

    function _updateChannelMeta(address _channel) internal {

        channels[_channel].channelUpdateBlock = block.number;
    }

    function createChannelForPushChannelAdmin() external onlyPushChannelAdmin() {

        require (!oneTimeCheck, "EPNSCoreV1::createChannelForPushChannelAdmin: Channel for Admin is already Created");



        _createChannel(pushChannelAdmin, ChannelType.ProtocolNonInterest, 0); // should the owner of the contract be the channel? should it be pushChannelAdmin in this case?
         emit AddChannel(
            pushChannelAdmin,
            ChannelType.ProtocolNonInterest,
            "1+QmSbRT16JVF922yAB26YxWFD6DmGsnSHm8VBrGUQnXTS74"
        );

        _createChannel(
            address(0x0),
            ChannelType.ProtocolNonInterest,
            0
        );
        emit AddChannel(
        address(0x0),
        ChannelType.ProtocolNonInterest,
        "1+QmTCKYL2HRbwD6nGNvFLe4wPvDNuaYGr6RiVeCvWjVpn5s"
        );

        oneTimeCheck = true;
    }

    function createChannelWithFees(
        ChannelType _channelType,
        bytes calldata _identity,
        uint256 _amount
    )
        external
        onlyInactiveChannels(msg.sender)
        onlyUserAllowedChannelType(_channelType)
    {

        emit AddChannel(msg.sender, _channelType, _identity);

        _createChannelWithFees(msg.sender, _channelType, _amount);
    }

    function _createChannelWithFees(
        address _channel,
        ChannelType _channelType,
        uint256 _amount
    ) private {

        require(
            _amount >= ADD_CHANNEL_MIN_FEES,
            "EPNSCoreV1::_createChannelWithFees: Insufficient Deposit Amount"
        );
        IERC20(daiAddress).safeTransferFrom(_channel, address(this), _amount);
        _depositFundsToPool(_amount);
        _createChannel(_channel, _channelType, _amount);
    }

    function migrateChannelData(
        uint256 _startIndex,
        uint256 _endIndex,
        address[] calldata _channelAddresses,
        ChannelType[] calldata _channelTypeList,
        bytes[] calldata _identityList,
        uint256[] calldata _amountList
    ) external onlyPushChannelAdmin returns (bool) {

        require(
            !isMigrationComplete,
            "EPNSCoreV1::migrateChannelData: Migration is already done"
        );

        require(
            (_channelAddresses.length == _channelTypeList.length) &&
            (_channelAddresses.length == _identityList.length) &&
            (_channelAddresses.length == _amountList.length),
            "EPNSCoreV1::migrateChannelData: Unequal Arrays passed as Argument"
        );

        for (uint256 i = _startIndex; i < _endIndex; i++) {
                if(channels[_channelAddresses[i]].channelState != 0){
                    continue;
            }else{
                IERC20(daiAddress).safeTransferFrom(msg.sender, address(this), _amountList[i]);
                _depositFundsToPool(_amountList[i]);
                emit AddChannel(_channelAddresses[i], _channelTypeList[i], _identityList[i]);
                _createChannel(_channelAddresses[i], _channelTypeList[i], _amountList[i]);
            }
        }
        return true;
    }

    function _createChannel(
        address _channel,
        ChannelType _channelType,
        uint256 _amountDeposited
    ) private {

        uint256 _channelWeight = _amountDeposited.mul(ADJUST_FOR_FLOAT).div(
            ADD_CHANNEL_MIN_POOL_CONTRIBUTION
        );

        channels[_channel].channelState = 1;

        channels[_channel].poolContribution = _amountDeposited;
        channels[_channel].channelType = _channelType;
        channels[_channel].channelStartBlock = block.number;
        channels[_channel].channelUpdateBlock = block.number;
        channels[_channel].channelWeight = _channelWeight;

        channelById[channelsCount] = _channel;
        channelsCount = channelsCount.add(1);

        if (
            _channelType == ChannelType.ProtocolPromotion ||
            _channelType == ChannelType.InterestBearingOpen ||
            _channelType == ChannelType.InterestBearingMutual
        ) {
            (
                groupFairShareCount,
                groupNormalizedWeight,
                groupHistoricalZ,
                groupLastUpdate
            ) = _readjustFairShareOfChannels(
                ChannelAction.ChannelAdded,
                _channelWeight,
                0,
                groupFairShareCount,
                groupNormalizedWeight,
                groupHistoricalZ,
                groupLastUpdate
            );
        }

        if (_channel != pushChannelAdmin) {
            IEPNSCommV1(epnsCommunicator).subscribeViaCore(
                _channel,
                _channel
            );
        }

        if (_channel != address(0x0)) {
            IEPNSCommV1(epnsCommunicator).subscribeViaCore(
                address(0x0),
                _channel
            );
            IEPNSCommV1(epnsCommunicator).subscribeViaCore(
                _channel,
                pushChannelAdmin
            );
        }
    }

    function createChannelSettings(
        uint256 _notifOptions,
        string calldata _notifSettings,
        string calldata _notifDescription
    ) external onlyActivatedChannels(msg.sender) {

        string memory notifSetting = string(
            abi.encodePacked(
                Strings.toString(_notifOptions),
                "+",
                _notifSettings
            )
        );
        channelNotifSettings[msg.sender] = notifSetting;
        emit ChannelNotifcationSettingsAdded(
            msg.sender,
            _notifOptions,
            notifSetting,
            _notifDescription
        );
    }


    function deactivateChannel(uint256 _amountsOutValue) external onlyActivatedChannels(msg.sender) {

        Channel storage channelData = channels[msg.sender];

        uint256 totalAmountDeposited = channelData.poolContribution;
        uint256 totalRefundableAmount = totalAmountDeposited.sub(
            CHANNEL_DEACTIVATION_FEES
        );

        uint256 _oldChannelWeight = channelData.channelWeight;
        uint256 _newChannelWeight = CHANNEL_DEACTIVATION_FEES
            .mul(ADJUST_FOR_FLOAT)
            .div(ADD_CHANNEL_MIN_POOL_CONTRIBUTION);

        (
            groupFairShareCount,
            groupNormalizedWeight,
            groupHistoricalZ,
            groupLastUpdate
        ) = _readjustFairShareOfChannels(
            ChannelAction.ChannelUpdated,
            _newChannelWeight,
            _oldChannelWeight,
            groupFairShareCount,
            groupNormalizedWeight,
            groupHistoricalZ,
            groupLastUpdate
        );

        channelData.channelState = 2;
        POOL_FUNDS = POOL_FUNDS.sub(totalRefundableAmount);
        channelData.channelWeight = _newChannelWeight;
        channelData.poolContribution = CHANNEL_DEACTIVATION_FEES;

        swapAndTransferPUSH(msg.sender, totalRefundableAmount, _amountsOutValue);
        emit DeactivateChannel(msg.sender, totalRefundableAmount);
    }


    function reactivateChannel(uint256 _amount)
        external
        onlyDeactivatedChannels(msg.sender)
    {

        require(
            _amount >= ADD_CHANNEL_MIN_POOL_CONTRIBUTION,
            "EPNSCoreV1::reactivateChannel: Insufficient Funds Passed for Channel Reactivation"
        );
        IERC20(daiAddress).safeTransferFrom(msg.sender, address(this), _amount);
        _depositFundsToPool(_amount);

        uint256 _oldChannelWeight = channels[msg.sender].channelWeight;
        uint newChannelPoolContribution = _amount.add(CHANNEL_DEACTIVATION_FEES);
        uint256 _channelWeight = newChannelPoolContribution.mul(ADJUST_FOR_FLOAT).div(
            ADD_CHANNEL_MIN_POOL_CONTRIBUTION
        );
        (
            groupFairShareCount,
            groupNormalizedWeight,
            groupHistoricalZ,
            groupLastUpdate
        ) = _readjustFairShareOfChannels(
            ChannelAction.ChannelUpdated,
            _channelWeight,
            _oldChannelWeight,
            groupFairShareCount,
            groupNormalizedWeight,
            groupHistoricalZ,
            groupLastUpdate
        );

        channels[msg.sender].channelState = 1;
        channels[msg.sender].poolContribution += _amount;
        channels[msg.sender].channelWeight = _channelWeight;

        emit ReactivateChannel(msg.sender, _amount);
    }


     function blockChannel(address _channelAddress)
     external
     onlyPushChannelAdmin()
     onlyUnblockedChannels(_channelAddress){

       Channel storage channelData = channels[_channelAddress];

       uint256 totalAmountDeposited = channelData.poolContribution;
       uint256 totalRefundableAmount = totalAmountDeposited.sub(
           CHANNEL_DEACTIVATION_FEES
       );

       uint256 _oldChannelWeight = channelData.channelWeight;
       uint256 _newChannelWeight = CHANNEL_DEACTIVATION_FEES
           .mul(ADJUST_FOR_FLOAT)
           .div(ADD_CHANNEL_MIN_POOL_CONTRIBUTION);

       channelsCount = channelsCount.sub(1);

       channelData.channelState = 3;
       channelData.channelWeight = _newChannelWeight;
       channelData.channelUpdateBlock = block.number;
       channelData.poolContribution = CHANNEL_DEACTIVATION_FEES;
       PROTOCOL_POOL_FEES = PROTOCOL_POOL_FEES.add(totalRefundableAmount);
       (
           groupFairShareCount,
           groupNormalizedWeight,
           groupHistoricalZ,
           groupLastUpdate
       ) = _readjustFairShareOfChannels(
           ChannelAction.ChannelRemoved,
           _newChannelWeight,
           _oldChannelWeight,
           groupFairShareCount,
           groupNormalizedWeight,
           groupHistoricalZ,
           groupLastUpdate
       );

       emit ChannelBlocked(_channelAddress);
     }


    function getChannelVerfication(address _channel)
      public
      view
      returns (uint8 verificationStatus)
    {

      address verifiedBy = channels[_channel].verifiedBy;
      bool logicComplete = false;

      if (verifiedBy == pushChannelAdmin || _channel == address(0x0) || _channel == pushChannelAdmin) {
        verificationStatus = 1;
      }
      else {
        while (!logicComplete) {
          if (verifiedBy == address(0x0)) {
            verificationStatus = 0;
            logicComplete = true;
          }
          else if (verifiedBy == pushChannelAdmin) {
            verificationStatus = 2;
            logicComplete = true;
          }
          else {
            verifiedBy = channels[verifiedBy].verifiedBy;
          }
        }
      }
    }

    function batchVerification(uint256 _startIndex, uint256 _endIndex, address[] calldata _channelList) external onlyPushChannelAdmin returns(bool){

      for(uint256 i =_startIndex; i < _endIndex; i++){
        verifyChannel(_channelList[i]);
      }
      return true;
    }

    function batchRevokeVerification(uint256 _startIndex, uint256 _endIndex, address[] calldata _channelList) external onlyPushChannelAdmin returns(bool){

      for(uint256 i =_startIndex; i < _endIndex; i++){
        unverifyChannel(_channelList[i]);
      }
      return true;
    }
    function verifyChannel(address _channel) public onlyActivatedChannels(_channel) {

      uint8 callerVerified = getChannelVerfication(msg.sender);
      require(callerVerified > 0, "EPNSCoreV1::verifyChannel: Caller is not verified");

      uint8 channelVerified = getChannelVerfication(_channel);
      require(
        (callerVerified >= 1 && channelVerified == 0) ||
        (msg.sender == pushChannelAdmin),
        "EPNSCoreV1::verifyChannel: Channel already verified"
      );

      channels[_channel].verifiedBy = msg.sender;

      emit ChannelVerified(_channel, msg.sender);
    }

    function unverifyChannel(address _channel) public {

      require(
        channels[_channel].verifiedBy == msg.sender || msg.sender == pushChannelAdmin,
        "EPNSCoreV1::unverifyChannel: Only channel who verified this or Push Channel Admin can revoke"
      );

      channels[_channel].verifiedBy = address(0x0);

      emit ChannelVerificationRevoked(_channel, msg.sender);
    }

    function _depositFundsToPool(uint256 amount) private {

        POOL_FUNDS = POOL_FUNDS.add(amount);

        ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(
            lendingPoolProviderAddress
        );
        ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
        IERC20(daiAddress).approve(provider.getLendingPoolCore(), amount);
        lendingPool.deposit(daiAddress, amount, uint16(REFERRAL_CODE)); // set to 0 in constructor presently
    }

    function swapAndTransferPUSH(address _user, uint256 _userAmount, uint256 _amountsOutValue)
        internal
        returns (bool)
    {

        swapADaiForDai(_userAmount);
        IERC20(daiAddress).approve(UNISWAP_V2_ROUTER, _userAmount);

        address[] memory path = new address[](3);
        path[0] = daiAddress;
        path[1] = WETH_ADDRESS;
        path[2] = PUSH_TOKEN_ADDRESS;

        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            _userAmount,
            _amountsOutValue,
            path,
            _user,
            block.timestamp
        );
        return true;
    }

    function swapADaiForDai(uint256 _amount) private{

      ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(
        lendingPoolProviderAddress
      );
      ILendingPool lendingPool = ILendingPool(provider.getLendingPool());

      IADai(aDaiAddress).redeem(_amount);
    }

    function _readjustFairShareOfChannels(
        ChannelAction _action,
        uint256 _channelWeight,
        uint256 _oldChannelWeight,
        uint256 _groupFairShareCount,
        uint256 _groupNormalizedWeight,
        uint256 _groupHistoricalZ,
        uint256 _groupLastUpdate
    )
        private
        view
        returns (
            uint256 groupNewCount,
            uint256 groupNewNormalizedWeight,
            uint256 groupNewHistoricalZ,
            uint256 groupNewLastUpdate
        )
    {

        uint256 groupModCount = _groupFairShareCount;
        uint256 adjustedNormalizedWeight = _groupNormalizedWeight;
        uint256 totalWeight = adjustedNormalizedWeight.mul(groupModCount);

        if (_action == ChannelAction.ChannelAdded) {
            groupModCount = groupModCount.add(1);
            totalWeight = totalWeight.add(_channelWeight);

        } else if (_action == ChannelAction.ChannelRemoved) {
            groupModCount = groupModCount.sub(1);
            totalWeight = totalWeight.add(_channelWeight).sub(_oldChannelWeight);

        } else if (_action == ChannelAction.ChannelUpdated) {
            totalWeight = totalWeight.add(_channelWeight).sub(_oldChannelWeight);

        }
        else {
            revert("EPNSCoreV1::_readjustFairShareOfChannels: Invalid Channel Action");
        }
        uint256 n = groupModCount;
        uint256 x = block.number.sub(_groupLastUpdate);
        uint256 w = totalWeight.div(groupModCount);
        uint256 z = _groupHistoricalZ;

        uint256 nx = n.mul(x);
        uint256 nxw = nx.mul(w);

        z = z.add(nxw);

        if (n == 1) {
            z = 0;
        }

        groupNewCount = groupModCount;
        groupNewNormalizedWeight = w;
        groupNewHistoricalZ = z;
        groupNewLastUpdate = block.number;
    }

    function getChainId() internal pure returns (uint256) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}