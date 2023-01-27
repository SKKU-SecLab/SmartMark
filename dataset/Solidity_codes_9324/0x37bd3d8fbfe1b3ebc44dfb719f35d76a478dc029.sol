



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
}




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
}




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
}




pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}




pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}




pragma solidity ^0.8.2;



abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}




pragma solidity ^0.8.0;

abstract contract UUPSUpgradeable is ERC1967Upgrade {
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}



pragma solidity ^0.8.0;

contract Owned {

    address public owner;
    address public nominatedOwner;

    function initializeOwner(address _owner) internal {

        require(owner == address(0), "Already initialized");
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}



pragma solidity ^0.8.0;

contract Pausable is Owned {

    uint public lastPauseTime;
    bool public paused;

    function initializePausable(address _owner) internal {

        super.initializeOwner(_owner);

        require(owner != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {

        if (_paused == paused) {
            return;
        }

        paused = _paused;

        if (paused) {
            lastPauseTime = block.timestamp;
        }

        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {

        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}



pragma solidity ^0.8.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    function initializeReentrancyGuard() internal {

        require(_guardCounter == 0, "Already initialized");
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}



pragma solidity >=0.5.0 <0.9.0;

interface IDepositCompound {

    function underlying_coins(int128 arg0) external view returns (address);


    function token() external view returns (address);


    function add_liquidity(uint256[2] calldata uamounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 _amount, uint256[2] calldata min_uamounts) external;


    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount, bool donate_dust) external;

}



pragma solidity >=0.5.0 <0.9.0;

interface IConvexBaseRewardPool {


    function rewards(address account) external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function earned(address account) external view returns (uint256);


    function getRewardForDuration() external view returns (uint256);


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function stakingToken() external view returns (address);


    function rewardToken() external view returns (address);


    function totalSupply() external view returns (uint256);



    function getReward(address _account, bool _claimExtras) external returns (bool);


    function stake(uint256 _amount) external returns (bool);


    function withdraw(uint256 amount, bool claim) external returns (bool);


    function withdrawAll(bool claim) external returns (bool);


    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);


    function withdrawAllAndUnwrap(bool claim) external returns (bool);

}



pragma solidity >=0.5.0 <0.9.0;

interface IConvexBooster {

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }
    function poolInfo(uint256 _pid) view external returns (PoolInfo memory);


    function crv() external view returns (address);


    function minter() external view returns (address);


    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);


    function depositAll(uint256 _pid, bool _stake) external returns(bool);

}



pragma solidity >=0.5.0 <0.9.0;

interface IPancakePair {

    function token0() external returns (address);

    function token1() external returns (address);

}



pragma solidity >=0.5.0 <0.9.0;

interface IConverterUniV3 {

    function NATIVE_TOKEN() external view returns (address);


    function convert(
        address _inTokenAddress,
        uint256 _amount,
        uint256 _convertPercentage,
        address _outTokenAddress,
        uint256 _minReceiveAmount,
        address _recipient
    ) external;


    function convertAndAddLiquidity(
        address _inTokenAddress,
        uint256 _amount,
        address _outTokenAddress,
        uint256 _minReceiveAmountSwap,
        uint256 _minInTokenAmountAddLiq,
        uint256 _minOutTokenAmountAddLiq,
        address _recipient
    ) external;


    function removeLiquidityAndConvert(
        IPancakePair _lp,
        uint256 _lpAmount,
        uint256 _minToken0Amount,
        uint256 _minToken1Amount,
        uint256 _token0Percentage,
        address _recipient
    ) external;


    function convertUniV3(
        address _inTokenAddress,
        uint256 _amount,
        uint256 _convertPercentage,
        address _outTokenAddress,
        uint256 _minReceiveAmount,
        address _recipient,
        bytes memory _path
    ) external;

}



pragma solidity >=0.7.0;

interface IWETH {

    function balanceOf(address account) external view returns (uint256);


    function deposit() external payable;


    function withdraw(uint256 amount) external;


    function transfer(address dst, uint256 wad) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

}



pragma solidity ^0.8.0;










contract AutoCompoundCurveConvex is ReentrancyGuard, Pausable, UUPSUpgradeable {

    using SafeERC20 for IERC20;

    struct BalanceDiff {
        uint256 balBefore;
        uint256 balAfter;
        uint256 balDiff;
    }


    string public name;
    uint256 public pid; // Pool ID in Convex Booster
    IConverterUniV3 public converter;
    IERC20 public lp;
    IERC20 public token0;
    IERC20 public token1;
    IERC20 public crv;
    IERC20 public cvx;
    IERC20 public BCNT;

    IDepositCompound public curveDepositCompound;
    IConvexBooster public convexBooster;
    IConvexBaseRewardPool public convexBaseRewardPool;

    mapping(address => uint256) internal _userRewardPerTokenPaid;
    mapping(address => uint256) internal _rewards;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;

    uint256 public lpAmountCompounded;
    address public operator;

    bytes public cvxUniV3SwapPath;
    bytes public bcntUniV3SwapPath;


    receive() external payable {}


    function initialize(
        string memory _name,
        uint256 _pid,
        address _owner,
        address _operator,
        IConverterUniV3 _converter,
        address _curveDepositCompound,
        address _convexBooster,
        address _convexBaseRewardPool,
        address _BCNT
    ) external {

        require(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("")), "Already initialized");
        super.initializePausable(_owner);
        super.initializeReentrancyGuard();

        name = _name;
        pid = _pid;
        operator = _operator;
        converter = _converter;
        curveDepositCompound = IDepositCompound(_curveDepositCompound);
        lp = IERC20(curveDepositCompound.token());
        token0 = IERC20(curveDepositCompound.underlying_coins(0));
        token1 = IERC20(curveDepositCompound.underlying_coins(1));
        convexBooster = IConvexBooster(_convexBooster);
        convexBaseRewardPool = IConvexBaseRewardPool(_convexBaseRewardPool);
        crv = IERC20(convexBaseRewardPool.rewardToken());
        require(address(convexBooster.crv()) == address(crv));
        cvx = IERC20(convexBooster.minter());
        BCNT = IERC20(_BCNT);
    }


    function implementation() external view returns (address) {

        return _getImplementation();
    }

    function totalSupply() external view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {

        return _balances[account];
    }

    function _share(address account) public view returns (uint256) {

        uint256 rewardPerToken = convexBaseRewardPool.rewardPerToken();
        return (_balances[account] * (rewardPerToken - _userRewardPerTokenPaid[account]) / (1e18)) + _rewards[account];
    }

    function _shareTotal() public view returns (uint256) {

        uint256 rewardPerToken = convexBaseRewardPool.rewardPerToken();
        return (_totalSupply * (rewardPerToken - _userRewardPerTokenPaid[address(this)]) / (1e18)) + _rewards[address(this)];
    }

    function earned(address account) public view returns (uint256) {

        uint256 rewardsShare;
        if (account == address(this)){
            rewardsShare = _shareTotal();
        } else {
            rewardsShare = _share(account);
        }

        uint256 earnedCompoundedLPAmount;
        if (rewardsShare > 0) {
            uint256 totalShare = _shareTotal();
            earnedCompoundedLPAmount = lpAmountCompounded * rewardsShare / totalShare;
        }
        return earnedCompoundedLPAmount;
    }


    function _convertAndAddLiquidity(
        bool isToken0,
        bool shouldTransferFromSender, 
        uint256 amount,
        uint256 minLiqAddedAmount
    ) internal returns (uint256 lpAmount) {

        require(amount > 0, "Cannot stake 0");
        uint256 lpAmountBefore = lp.balanceOf(address(this));
        uint256 token0AmountBefore = token0.balanceOf(address(this));
        uint256 token1AmountBefore = token1.balanceOf(address(this));

        uint256[2] memory uamounts;
        if (isToken0) {
            if (shouldTransferFromSender) {
                token0.safeTransferFrom(msg.sender, address(this), amount);
            }
            uamounts[0] = amount;
            uamounts[1] = 0;
            token0.safeApprove(address(curveDepositCompound), amount);
            curveDepositCompound.add_liquidity(uamounts, minLiqAddedAmount);
        } else {
            if (shouldTransferFromSender) {
                token1.safeTransferFrom(msg.sender, address(this), amount);
            }
            uamounts[0] = 0;
            uamounts[1] = amount;
            token1.safeApprove(address(curveDepositCompound), amount);
            curveDepositCompound.add_liquidity(uamounts, minLiqAddedAmount);

        }

        uint256 lpAmountAfter = lp.balanceOf(address(this));
        uint256 token0AmountAfter = token0.balanceOf(address(this));
        uint256 token1AmountAfter = token1.balanceOf(address(this));

        lpAmount = (lpAmountAfter - lpAmountBefore);

        if (shouldTransferFromSender && (token0AmountAfter - token0AmountBefore) > 0) {
            token0.safeTransfer(msg.sender, (token0AmountAfter - token0AmountBefore));
        }
        if (shouldTransferFromSender && (token1AmountAfter - token1AmountBefore) > 0) {
            token1.safeTransfer(msg.sender, (token1AmountAfter - token1AmountBefore));
        }
    }

    function _stake(address staker, uint256 lpAmount) internal {

        lp.safeApprove(address(convexBooster), lpAmount);
        convexBooster.deposit(
            pid,
            lpAmount,
            true // True indicate to also stake into BaseRewardPool
        );
        _totalSupply = _totalSupply + lpAmount;
        _balances[staker] = _balances[staker] + lpAmount;
        emit Staked(staker, lpAmount);
    }

    function stake(
        bool isToken0,
        uint256 amount,
        uint256 minLiqAddedAmount
    ) public nonReentrant notPaused updateReward(msg.sender) {

        uint256 lpAmount = _convertAndAddLiquidity(isToken0, true, amount, minLiqAddedAmount);
        _stake(msg.sender, lpAmount);
    }

    function stakeWithLP(uint256 lpAmount) public nonReentrant notPaused updateReward(msg.sender) {

        lp.safeTransferFrom(msg.sender, address(this), lpAmount);
        _stake(msg.sender, lpAmount);
    }


    function _removeLP(IERC20 token, bool toToken0, uint256 amount, uint256 minAmountReceived) internal returns (uint256) {

        uint256 balBefore = token.balanceOf(address(this));

        lp.safeApprove(address(curveDepositCompound), amount);
        curveDepositCompound.remove_liquidity_one_coin(
            amount,
            toToken0 ? int128(0) : int128(1),
            minAmountReceived,
            true // Donate dust
        );
        uint256 balAfter = token.balanceOf(address(this));
        return balAfter - balBefore;
    }

    function withdraw(
        bool toToken0,
        uint256 minAmountReceived,
        uint256 amount
    ) public nonReentrant updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");

        _totalSupply = (_totalSupply - amount);
        _balances[msg.sender] = (_balances[msg.sender] - amount);

        convexBaseRewardPool.withdrawAndUnwrap(
            amount,
            false // No need to getReward when withdraw
        );

        IERC20 token = toToken0 ? token0 : token1;
        uint256 receivedTokenAmount = _removeLP(token, toToken0, amount, minAmountReceived);
        token.safeTransfer(msg.sender, receivedTokenAmount);

        emit Withdrawn(msg.sender, amount);
    }

    function withdrawWithLP(uint256 lpAmount) public nonReentrant notPaused updateReward(msg.sender) {

        require(lpAmount > 0, "Cannot withdraw 0");

        _totalSupply = (_totalSupply - lpAmount);
        _balances[msg.sender] = (_balances[msg.sender] - lpAmount);

        convexBaseRewardPool.withdrawAndUnwrap(
            lpAmount,
            false // No need to getReward when withdraw
        );
        lp.safeTransfer(msg.sender, lpAmount);

        emit Withdrawn(msg.sender, lpAmount);
    }



    function getReward(
        uint256 minAmountToken0Received,
        uint256 minAmountBCNTReceived
    ) public updateReward(msg.sender)  {        

        uint256 reward = _rewards[msg.sender];
        uint256 totalReward = _rewards[address(this)];
        if (reward > 0) {
            uint256 compoundedLPRewardAmount = lpAmountCompounded * reward / totalReward;

            _rewards[msg.sender] = 0;
            _rewards[address(this)] = (totalReward - reward);
            lpAmountCompounded = (lpAmountCompounded - compoundedLPRewardAmount);

            convexBaseRewardPool.withdrawAndUnwrap(
                compoundedLPRewardAmount,
                false // No need to getReward when withdraw
            );

            uint256 receivedToken0Amount = _removeLP(token0, true, compoundedLPRewardAmount, minAmountToken0Received);
            token0.approve(address(converter), receivedToken0Amount);
            converter.convertUniV3(address(token0), receivedToken0Amount, 100, address(BCNT), minAmountBCNTReceived, msg.sender, bcntUniV3SwapPath);

            emit RewardPaid(msg.sender, compoundedLPRewardAmount);
        }
    }

    function exit(bool toToken0, uint256 minAmountReceived, uint256 minAmountBCNTReceived) external {

        withdraw(toToken0, minAmountReceived, _balances[msg.sender]);
        getReward(minAmountReceived, minAmountBCNTReceived);
    }

    function exitWithLP(uint256 minAmountReceived, uint256 minAmountBCNTReceived) external {

        withdrawWithLP(_balances[msg.sender]);
        getReward(minAmountReceived, minAmountBCNTReceived);
    }



    function compound(
        uint256 minCrvToToken0Swap,
        uint256 minCvxToToken0Swap,
        uint256 minLiqAddedAmount
    ) external nonReentrant updateReward(address(0)) onlyOperator {

        convexBaseRewardPool.getReward(address(this), true);

        BalanceDiff memory lpAmountDiff;
        lpAmountDiff.balBefore = lp.balanceOf(address(this));
        BalanceDiff memory token0Diff;
        token0Diff.balBefore = token0.balanceOf(address(this));

        uint256 crvBalance = crv.balanceOf(address(this));
        if (crvBalance > 0) {
            crv.approve(address(converter), crvBalance);
            try converter.convert(address(crv), crvBalance, 100, address(token0), minCrvToToken0Swap, address(this)) {

            } catch Error(string memory reason) {
                emit ConvertFailed(address(crv), address(token0), crvBalance, reason, bytes(""));
            } catch (bytes memory lowLevelData) {
                emit ConvertFailed(address(crv), address(token0), crvBalance, "", lowLevelData);
            }
        }
        uint256 cvxBalance = cvx.balanceOf(address(this));
        if (cvxBalance > 0) {
            cvx.approve(address(converter), cvxBalance);
            try converter.convertUniV3(address(cvx), cvxBalance, 100, address(token0), minCvxToToken0Swap, address(this), cvxUniV3SwapPath) {

            } catch Error(string memory reason) {
                emit ConvertFailed(address(cvx), address(token0), cvxBalance, reason, bytes(""));
            } catch (bytes memory lowLevelData) {
                emit ConvertFailed(address(cvx), address(token0), cvxBalance, "", lowLevelData);
            }
        }
        token0Diff.balAfter = token0.balanceOf(address(this));
        token0Diff.balDiff = (token0Diff.balAfter - token0Diff.balBefore);

        if (token0Diff.balDiff > 0) {
            uint256[2] memory uamounts;
            uamounts[0] = token0Diff.balDiff;
            uamounts[1] = 0;
            token0.safeApprove(address(curveDepositCompound), token0Diff.balDiff);
            curveDepositCompound.add_liquidity(uamounts, minLiqAddedAmount);
            lpAmountDiff.balAfter = lp.balanceOf(address(this));
            lpAmountDiff.balDiff = (lpAmountDiff.balAfter - lpAmountDiff.balBefore);
            lpAmountCompounded = lpAmountCompounded + lpAmountDiff.balDiff;

            lp.safeApprove(address(convexBooster), lpAmountDiff.balDiff);
            convexBooster.deposit(
                pid,
                lpAmountDiff.balDiff,
                true // True indicate to also stake into BaseRewardPool
            );
            emit Compounded(lpAmountDiff.balDiff);
        }
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

        require(tokenAddress != address(lp), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function updateCVXUniV3SwapPath(bytes calldata newPath) external onlyOperator {

        cvxUniV3SwapPath = newPath;

        emit UpdateCVXUniV3SwapPath(newPath);
    }

    function updateBCNTUniV3SwapPath(bytes calldata newPath) external onlyOperator {

        bcntUniV3SwapPath = newPath;

        emit UpdateBCNTUniV3SwapPath(newPath);
    }

    function updateOperator(address newOperator) external onlyOwner {

        operator = newOperator;

        emit UpdateOperator(newOperator);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {}



    modifier updateReward(address account) {

        uint256 rewardPerTokenStored = convexBaseRewardPool.rewardPerToken();
        if (account != address(0)) {
            _rewards[account] = _share(account);
            _userRewardPerTokenPaid[account] = rewardPerTokenStored;

            _rewards[address(this)] = _shareTotal();
            _userRewardPerTokenPaid[address(this)] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOperator() {

        require(msg.sender == operator, "Only the contract operator may perform this action");
        _;
    }


    event UpdateCVXUniV3SwapPath(bytes newPath);
    event UpdateBCNTUniV3SwapPath(bytes newPath);
    event UpdateOperator(address newOperator);
    event Staked(address indexed user, uint256 amount);
    event ConvertFailed(address fromToken, address toToken, uint256 fromAmount, string reason, bytes lowLevelData);
    event Compounded(uint256 lpAmount);
    event RewardPaid(address indexed user, uint256 rewardLPAmount);
    event Withdrawn(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
}